global class DCON_DoubleBooking
{ 
    public class SVMXException extends Exception {} 
    public static Map<String, String> mapSFUSerTechId = new Map<String, String>();
    //public static set<String> setSFUSerId = new set<String>();
    public static Map<String, String> svmxSettingList = new Map<String, String>(DCON_Event_WS.loadDCsetting());
    public static DCON_Utils dcUtils = new DCON_Utils();
    //Class of SF and SVMX event list
    public class TechEvent_WP
    {
        list<Event> lstSFEvent = new  list<Event>();
        list<SVMXC__SVMX_Event__c> lstSVMXEvent = new  list<SVMXC__SVMX_Event__c>();
    }

    //Check for double booking
    public static void checkDoublebookingforTech(List<Event> lstEvent, String timeZone, String SFuserPrefix)
    {
        if(lstEvent== null ||lstEvent.size() == 0)
            return;
        
            System.debug(logginglevel.error,'Input '+lstEvent +' ' + timeZone + ' '+SFuserPrefix);
            //WSCH_AuditLogger.debug('Input '+lstEvent +' ' + timeZone + ' '+SFuserPrefix);
            //WSCH_AuditLogger.debug('svmxSettingList '+svmxSettingList);
            //If false, check while WO Scheduling for all events
            if(svmxSettingList.containsKey('SET026') && svmxSettingList.get('SET026').toUpperCase()=='FALSE')
            {                
                TechEvent_WP ObjExistingSFSVMXEvents = new TechEvent_WP();
                //Getting Existing SF and SVMX Event for given Event list to be created or updated
                ObjExistingSFSVMXEvents = GetExistingSFSVMXEvents(lstEvent,timeZone,SFuserPrefix);
                System.debug(logginglevel.error,'ObjExistingSFSVMXEvents '+ObjExistingSFSVMXEvents);//WSCH_AuditLogger.debug('ObjExistingSFSVMXEvents '+ObjExistingSFSVMXEvents);             
                //To check whether it is a work order related event or not- only WO events  
                if(svmxSettingList.containsKey('SET028') && svmxSettingList.get('SET028').toUpperCase()=='TRUE')
                {
                    //Display Error if double bookings are there
                    findOverlappingEvents(getmapTechEvent(getWOEvents(ObjExistingSFSVMXEvents.lstSFEvent),getWOEvents(ObjExistingSFSVMXEvents.lstSVMXEvent)),lstEvent,SFuserPrefix,timeZone);
                }
                else
                {
                    //Display Error if double bookings are there
                    findOverlappingEvents(getmapTechEvent(ObjExistingSFSVMXEvents.lstSFEvent,ObjExistingSFSVMXEvents.lstSVMXEvent),lstEvent,SFuserPrefix,timeZone);
                }
                
            }
            //If true, check while WO Scheduling for only work order objects
            if(svmxSettingList.containsKey('SET026') && (svmxSettingList.get('SET026').toUpperCase()=='TRUE'))
            {
                //Getting only WO Events 
                lstEvent = getWOEvents(lstEvent);           
                TechEvent_WP ObjExistingSFSVMXEvents = new TechEvent_WP();
                //Getting Existing SF and SVMX Event overlapping with Given Event list to be created or updated
                if(lstEvent.size() > 0)
                {
                    ObjExistingSFSVMXEvents = GetExistingSFSVMXEvents(lstEvent,timeZone, SFuserPrefix);
                    System.debug(logginglevel.error,'ObjExistingSFSVMXEvents '+ObjExistingSFSVMXEvents);
                    //WSCH_AuditLogger.debug('ObjExistingSFSVMXEvents '+ObjExistingSFSVMXEvents);             
                    if(svmxSettingList.containsKey('SET028') && svmxSettingList.get('SET028').toUpperCase()=='TRUE')
                    {
                        //Display Error if double bookings are there
                        findOverlappingEvents(getmapTechEvent(getWOEvents(ObjExistingSFSVMXEvents.lstSFEvent),getWOEvents(ObjExistingSFSVMXEvents.lstSVMXEvent)),lstEvent, SFuserPrefix,timeZone);
                    }
                    else
                    {
                        //Display Error if double bookings are there
                        findOverlappingEvents(getmapTechEvent(ObjExistingSFSVMXEvents.lstSFEvent,ObjExistingSFSVMXEvents.lstSVMXEvent),lstEvent,SFuserPrefix,timeZone);
                    }
                }
            }
        //WSCH_AuditLogger.finish();

    }
    // Display Double booking details if any. Details Contain Tech Name , Event Start and end duration
    // Parameter: 1 - map of existing events(SF/SVMX) for a TechIDs
    // 2- List of events to be created or updated
    // 4- to check the overlapping scenario in the given time-zone
    public static void findOverlappingEvents(map<String ,TechEvent_WP> mapTechidEvent,List<Event> lstEvent,String sFUserPrefix,String timeZone)
    {
        //WSCH_AuditLogger.debug('mapTechidEvent  '+mapTechidEvent);
        List<String> lstStrOverlappingEventDetails = new List<String>();
        boolean isDoubleBooked = false;
        try
        {
            for(Event objEvent: lstEvent)
            {   
            
                           
                if(objEvent.OwnerId != null && String.valueof(objEvent.OwnerId).startsWith(sFUserPrefix) == true && 
                mapTechidEvent.containskey(getTechId(objEvent.OwnerId)))
                {
                    // Checking overlapping SF Events 
                    lstStrOverlappingEventDetails.addall(getOverlappingEventDetails(objEvent, mapTechidEvent.get(getTechId(objEvent.OwnerId)),timeZone));
                    //WSCH_AuditLogger.debug('mapTechidEvent.get(getTechId(objEvent.OwnerId)) '+mapTechidEvent.get(getTechId(objEvent.OwnerId)));
                    System.debug(logginglevel.error,'lstStrOverlappingEventDetails if '+lstStrOverlappingEventDetails);
                }
                else if(mapTechidEvent.containskey(objEvent.OwnerId))
                {
                    // Checking overlapping SVMX Events 
                    lstStrOverlappingEventDetails.addall(getOverlappingEventDetails(objEvent, mapTechidEvent.get(objEvent.OwnerId),timeZone));
                    //WSCH_AuditLogger.debug('mapTechidEvent.get(objEvent.OwnerId) '+mapTechidEvent.get(objEvent.OwnerId));
                    System.debug(logginglevel.error,'lstStrOverlappingEventDetails else'+lstStrOverlappingEventDetails);
                }
            }
            System.debug(logginglevel.error,'mapTechidEvent '+mapTechidEvent);
            //WSCH_AuditLogger.debug('mapTechidEvent '+mapTechidEvent);             
            System.debug(logginglevel.error,'lstStrOverlappingEventDetails '+lstStrOverlappingEventDetails);
            //Display Overlapping Info
            if(lstStrOverlappingEventDetails.size()>0)
            {
                isDoubleBooked = true;
                // Show the Tech and Event details
                throw new SVMXException();
                
            }
        }
        catch(Exception ex)
        {
            //WSCH_AuditLogger.debug('Stack Trace '+ex.getStackTraceString());
            //Database.rollback(sp);
            if(isDoubleBooked == true)
                throw new SVMXException(system.Label.DCON001_TAG238);
            else
               throw new SVMXException(ex.getMessage());
               
        }
        
    }
    //Returns Existing Overlapping Events for the given list of events
    public static TechEvent_WP GetExistingSFSVMXEvents(List<Event> lstEvent, String timeZone, String SFuserPrefix)
    {
        map<String ,List<TechEvent_WP>> mapTechidEvent = new map<String ,List<TechEvent_WP>>();
        List<Event> lstSFEvent = new  List<Event>();
        List<SVMXC__SVMX_Event__c> lstSVMXEvent = new  List<SVMXC__SVMX_Event__c>();
        List<String> lstTech = new List<String>();
        List<String> lstSFUserId = new List<String>();
        DateTime eventStartTime ;
        DateTime eventEndTime ;
        //Find the time span and Tech to look for overlapping events. 
        // Time span for 2 datetime 18/9/2014 9:00 AM to  19/9/2014 10:00 AM and  20/9/2014 9:00 AM to 22/9/2014 10:00 AM will be : 18/9/2014 9:00 to 22/9/2014 10:00 AM
        for(Event objEvent: lstEvent)
        {
            if(String.valueof(objEvent.OwnerId).startsWith(SFUserPrefix))
                lstSFUserId.add(objEvent.OwnerId);
            else
                lstTech.add(objEvent.OwnerId);
            if(eventStartTime == null)
                eventStartTime = objEvent.StartDateTime;
            else if(eventStartTime != null && objEvent.StartDateTime < eventStartTime)
                eventStartTime = Date.valueOf(objEvent.StartDateTime);
            if(eventEndTime == null)    
                eventEndTime = eventStartTime.addMinutes(Integer.valueof(objEvent.DurationInMinutes)); //DateTime.valueof(eventStartTime).addMinutes(Integer.valueof(objEvent.DurationInMinutes));
            else if(eventEndTime != null && eventEndTime < DateTime.valueof(eventStartTime).addMinutes(Integer.valueof(objEvent.DurationInMinutes)))
                eventEndTime = DateTime.valueof(eventStartTime).addMinutes(Integer.valueof(objEvent.DurationInMinutes));
        }
        mapIdTech = getmapTechIdObj(lstTech,lstSFUserId);
        //Datetime in given timezone
        //WSCH_AuditLogger.debug('eventStartTime : '+eventStartTime);
        //WSCH_AuditLogger.debug('mapIdTech : '+mapIdTech);
        if(eventStartTime!= null)
        eventStartTime = dcUtils.getDateTimeInTimezone(DateTime.valueof(eventStartTime).dateGmt(), DateTime.valueof(eventStartTime).timeGmt(),timeZone).addHours(-12);
        if(eventEndTime!= null)
        eventEndTime = dcUtils.getDateTimeInTimezone(DateTime.valueof(eventEndTime).dateGmt(), DateTime.valueof(eventEndTime).timeGmt(), timeZone).addHours(12);
        //WSCH_AuditLogger.debug('lstTech : '+lstTech+'eventStartTime '+eventStartTime +'eventEndTime '+eventEndTime);
        //Getting SF events  with given time span and for the given Tech 
        //WSCH_AuditLogger.debug('mapSFUSerTechId.keyset():  '+mapSFUSerTechId.keyset());
        lstSFEvent = getLstSFEventforTech(mapSFUSerTechId.keyset(), eventStartTime, eventEndTime);
        //Getting SVMX events with given time span and for the given Tech 
        lstSVMXEvent = getLstSVMXEventforTech(mapSFUSerTechId.values(), eventStartTime, eventEndTime);
        // Populate the {TechID, TechEvent_WP}
        TechEvent_WP ObjExistingSFSVMXEvents = new TechEvent_WP();
        ObjExistingSFSVMXEvents.lstSFEvent.addall(lstSFEvent);
        ObjExistingSFSVMXEvents.lstSVMXEvent.addall(lstSVMXEvent);
        return ObjExistingSFSVMXEvents;
        
    }
    
    //Returns Only WO Events
    public static List<Event>  getWOEvents(List<Event> lstEvent)    
    {
        List<Event> lstWOEvent = new List<Event> ();
        for(Event objEvent:lstEvent)
        {
            //Check if whatid start With WO object Prefix, Which means WO event
            if(objEvent.WhatId!=NULL && String.valueof(objEvent.WhatId).startsWith(SVMXC__Service_Order__c.SObjectType.getDescribe().getKeyPrefix()))
                lstWOEvent.add(objEvent);
        }
        return lstWOEvent;
    }
    //Returns Only WO Events
    public static List<SVMXC__SVMX_Event__c>  getWOEvents(List<SVMXC__SVMX_Event__c> lstEvent)  
    {
        List<SVMXC__SVMX_Event__c> lstWOEvent = new List<SVMXC__SVMX_Event__c> ();
        for(SVMXC__SVMX_Event__c objEvent:lstEvent)
        {
            //Check if whatid start With WO object Prefix, Which means WO event
            if(objEvent.SVMXC__WhatId__c != NULL && String.valueof(objEvent.SVMXC__WhatId__c).startsWith(SVMXC__Service_Order__c.SObjectType.getDescribe().getKeyPrefix()))
                lstWOEvent.add(objEvent);
        }
        return lstWOEvent;
    }
    Public static map<String,SVMXC__Service_Group_Members__c> mapIdTech = new     map<String,SVMXC__Service_Group_Members__c>();
    
    

    //Get List of  SF Event for Tech within the time range
    public static list<event> getLstSFEventforTech(set<string> lstOwnerID,DateTime inputStartTime, DateTime inputEndTime)
    {
        //Following Scenarios are considered for checking Double booking
        // events that "end" during the input event's start and end time, 
        // events that "start" during the input event's start and end time
        // events that "start" before input event's start time and "end" after input event's end time
        // events that "start" within the input event's start and end time including fully overlapped events
          
        //return([Select Id, WhatId,ActivityDateTime,OwnerId, EndDateTime, DurationInMinutes  from Event where (OwnerId in:lstOwnerID) AND (ActivityDateTime <= :inputEndTime and EndDateTime >= :inputStartTime)] ); 
        date inputStartdate = inputStartTime.dateGMT();
        date inputEndtdate = inputEndTime.dateGMT();
        //WSCH_AuditLogger.debug('inputStartdate:  '+inputStartdate);
        datetime inputStartdatetime = Datetime.newInstanceGmt(inputStartTime.dateGMT(),Time.newInstance(0, 0, 0, 0));
        //WSCH_AuditLogger.debug('inputStartdatetime : '+inputStartdatetime); 
        //return([Select Id, WhatId,ActivityDateTime,OwnerId, EndDateTime, DurationInMinutes,IsAllDayEvent,ActivityDate,StartDatetime  from Event where (OwnerId in:lstOwnerID) AND ((StartDateTime <= :inputEndTime and EndDateTime >= :inputStartTime)OR(StartDatetime = :inputStartdatetime AND IsAllDayEvent = true))]) ; 
        //Get list of Events for Tech within the time range inputStartTime and inputEndtdate with additional validation for All-Day events retival i.e. using ActivityDate instead of StartDateTime and in EndDateTime & inputStartdatetime time component is (0,0,0,0) (should be in All-day events)
        return([Select Id, WhatId,ActivityDateTime,OwnerId, EndDateTime, DurationInMinutes,IsAllDayEvent,ActivityDate,StartDatetime  from Event where (OwnerId in:lstOwnerID) AND ((StartDateTime <= :inputEndTime and EndDateTime >= :inputStartTime)OR (ActivityDate <= :inputEndtdate and EndDateTime >= :inputStartdatetime AND IsAllDayEvent = true ) OR(ActivityDate = :inputStartdate AND IsAllDayEvent = true))]) ; 
    }
    //Get List of  SVMX Event for Tech within the time range inputStartTime and inputEndtdate
    public static list<SVMXC__SVMX_Event__c> getLstSVMXEventforTech(list<string> lstOwnerID,DateTime inputStartTime, DateTime inputEndTime)
    {
        //Following Scenarios are considered for checking Double booking
        // events that "end" during the input event's start and end time, 
        // events that "start" during the input event's start and end time
        // events that "start" before input event's start time and "end" after input event's end time
        // events that "start" within the input event's start and end time including fully overlapped events
        
        //WSCH_AuditLogger.debug('inputStartTime : '+inputStartTime +'   '+ inputEndTime+'  '+lstOwnerID); 
        date inputStartdate = inputStartTime.dateGMT();
        //date inputEnddate = inputStartTime.dateGMT(); seems typo, hence the below code - Win16
        date inputEnddate = inputEndTime.dateGMT();
        
        datetime inputStartdatetime = Datetime.newInstanceGmt(inputStartTime.dateGMT(),Time.newInstance(0, 0, 0, 0));
        //WSCH_AuditLogger.debug('inputStartdatetime : '+inputStartdatetime); 
        //return([Select Id,SVMXC__DurationInMinutes__c, SVMXC__WhatId__c,SVMXC__Technician__c, SVMXC__ActivityDate__c,SVMXC__ActivityDateTime__c,SVMXC__EndDateTime__c,SVMXC__StartDateTime__c,SVMXC__IsAllDayEvent__c from SVMXC__SVMX_Event__c where (SVMXC__Technician__c in:lstOwnerID) AND ((SVMXC__StartDateTime__c <= :inputEndTime and SVMXC__EndDateTime__c >= :inputStartTime)OR(SVMXC__StartDateTime__c = :inputStartdatetime AND SVMXC__IsAllDayEvent__c = true))]); 
        return([Select Id,SVMXC__DurationInMinutes__c, SVMXC__WhatId__c,SVMXC__Technician__c, SVMXC__ActivityDate__c,SVMXC__ActivityDateTime__c,SVMXC__EndDateTime__c,SVMXC__StartDateTime__c,SVMXC__IsAllDayEvent__c from SVMXC__SVMX_Event__c where (SVMXC__Technician__c in:lstOwnerID) AND ((SVMXC__StartDateTime__c <= :inputEndTime and SVMXC__EndDateTime__c >= :inputStartTime)OR (SVMXC__ActivityDate__c <= :inputEnddate and SVMXC__EndDateTime__c >= :inputStartdatetime AND SVMXC__IsAllDayEvent__c = true) OR(SVMXC__StartDateTime__c = :inputStartdatetime AND SVMXC__IsAllDayEvent__c = true))]); 
    }
    // Getting map of Tech and corresrponding SF and SVMX event list
    public static map<String ,TechEvent_WP> getmapTechEvent(List<Event> lstSFEvent ,List<SVMXC__SVMX_Event__c> lstSVMXEvent )
    {
            map<String ,TechEvent_WP> mapTechEvent = new map<String ,TechEvent_WP> ();
            //Looping through SF event list to Build map of tech and TechEvent_WP
            for(Event objEvent :lstSFEvent)
            {
                if(mapTechEvent.containskey(getTechId(objEvent.OwnerId)))
                {
                    TechEvent_WP objTechEvent_WP = new TechEvent_WP();
                    objTechEvent_WP =  mapTechEvent.get(getTechId(objEvent.OwnerId));
                    objTechEvent_WP.lstSFEvent.add(objEvent);
                    mapTechEvent.put(getTechId(objEvent.OwnerId),objTechEvent_WP);
                }
                else
                {
                    TechEvent_WP objTechEvent_WP = new TechEvent_WP();
                    objTechEvent_WP.lstSFEvent.add(objEvent);
                    mapTechEvent.put(getTechId(objEvent.OwnerId),objTechEvent_WP);
                }
                
            }
            //Looping through SVMX event list to Build map of tech and TechEvent_WP
            for(SVMXC__SVMX_Event__c objEvent :lstSVMXEvent)
            {
                if(mapTechEvent.containskey(objEvent.SVMXC__Technician__c))
                {
                    TechEvent_WP objTechEvent_WP = new TechEvent_WP();
                    objTechEvent_WP =  mapTechEvent.get(objEvent.SVMXC__Technician__c);
                    objTechEvent_WP.lstSVMXEvent.add(objEvent);
                    mapTechEvent.put(objEvent.SVMXC__Technician__c,objTechEvent_WP);
                }
                else
                {
                    TechEvent_WP objTechEvent_WP = new TechEvent_WP();
                    objTechEvent_WP.lstSVMXEvent.add(objEvent);
                    mapTechEvent.put(objEvent.SVMXC__Technician__c,objTechEvent_WP);
                }
            }
            return mapTechEvent;
    }

    //Returns map of Tech and SFuserId
    public static map<String,SVMXC__Service_Group_Members__c> getmapTechIdObj(list<String> lstTechId, list<String> lstSFUserId)
    {
        map<String,SVMXC__Service_Group_Members__c> mapTechIdTechObj ;
        mapTechIdTechObj =new map<String,SVMXC__Service_Group_Members__c>([Select Id,SVMXC__Salesforce_User__c,Name from SVMXC__Service_Group_Members__c where id IN :lstTechId or SVMXC__Salesforce_User__c IN :lstSFUserId]);
        
        
        for(String TechId : mapTechIdTechObj.keyset())
        {
            // Later, we need to have the SF userID too for the TechID to query the 'SF Event Object' against this Technician ID
            mapSFUSerTechId.put(mapTechIdTechObj.get(TechId).SVMXC__Salesforce_User__c,TechId);
            
            //setSFUSerId.add(mapTechIdTechObj.get(TechId).SVMXC__Salesforce_User__c);
        }
        //WSCH_AuditLogger.debug('mapSFUSerTechId: '+mapSFUSerTechId);
        return mapTechIdTechObj;
       
    }

   
    // Returns Tech for given SF user Id
    public Static string getTechId(string sFUser)
    {
        /* if(mapIdTech.containsKey(sFUser))
            return mapIdTech.get(sFUser).id;
        else
            return null; */
            
            if(mapSFUSerTechId.containsKey(sFUser))
            return mapSFUSerTechId.get(sFUser);
        else
            return null;
    }
    // Returns Tech name  for given Techid
    public static string getTechName(String techId)
    {
        if(mapIdTech.containsKey(techId))
            return mapIdTech.get(techId).Name;
        else
            return null;
    }

    // Returns Overlapping details for the given event if any.Details Contains Tech Name Start and end time
    public static List<String> getOverlappingEventDetails(Event objEvent,TechEvent_WP objTechEvent_WP,String timeZone)
    {
        //Following Scenarios are considered for checking Double booking
        // events that "end" during the input event's start and end time, 
        // events that "start" during the input event's start and end time
        // events that "start" before input event's start time and "end" after input event's end time
        // events that "start" within the input event's start and end time including fully overlapped events
        
        
        List<String> lstStrOverlappingEventDetails = new List<String>();
        //Converting incoming event's StartDateTime to user timezone
        DateTime eventStartTime = dcUtils.getDateTimeInTimezone(DateTime.valueof(objEvent.StartDateTime).dateGmt(), DateTime.valueof(objEvent.StartDateTime).timeGmt(),timeZone);
        //eventEndTime = DateTime.newInstance(DateTime.valueof(eventEndTime).dateGmt(), DateTime.valueof(eventEndTime).timeGmt());
        DateTime eventEndTime = DateTime.valueof(eventStartTime).addMinutes(Integer.valueof(objEvent.DurationInMinutes));
        DateTime eventstartDate;
        if(objEvent.isAllDayEvent)
            eventstartDate = objEvent.ActivityDate;
        else
            eventstartDate = eventStartTime.dateGMT();// Why can't we take it directly from ActivityDate. Need to find if it is being passed from client in case of non-All Day event
        //WSCH_AuditLogger.debug('objEvent'+objEvent+'   '+objTechEvent_WP+'     '+eventEndTime);
        //WSCH_AuditLogger.debug('eventstartDate '+eventstartDate);
        for(Event SFEvent: objTechEvent_WP.lstSFEvent)
        {
            String idEvt = objEvent.id;
            if(objEvent != null && objEvent.id != null && String.IsNotBlank(idEvt))
            {
                //lstStrOverlappingEventDetails is just for message to the client..Not yet implemented
                if(SFEvent.isAllDayEvent && objEvent.Id != SFEvent.id)
                {
                    //WSCH_AuditLogger.debug('SFEvent.StartDateTime.dateGMT() '+SFEvent.StartDateTime.dateGMT());
                    //WSCH_AuditLogger.debug('SFEvent.EndDateTime.dateGMT() '+SFEvent.EndDateTime.dateGMT());
                    // Start And end time in selected globes time zone
                    // Temporarily provide the stored ALL day event, end time - in later release we need to work, to have it persisted
                    DateTime stored_eventStartTime = SFEvent.StartDateTime;
                    DateTime stored_eventEndTime = SFEvent.StartDateTime.addMinutes(Integer.valueof(SFEvent.DurationInMinutes));
                    
                    DateTime incomingEventStartTime = objEvent.StartDateTime; // getting back to the User's timezone, for All day event test
                    DateTime incomingEventEndTime = objEvent.StartDateTime.addMinutes(Integer.valueof(objEvent.DurationInMinutes));
                    //WSCH_AuditLogger.debug('stored_eventStartTime = '+stored_eventStartTime + ' < ' + incomingEventEndTime);
                    //WSCH_AuditLogger.debug('stored_eventEndTime = '+stored_eventEndTime + ' > ' + incomingEventStartTime );
                    //if(SFEvent.ActivityDate == eventstartDate && objEvent.Id != SFEvent.id)
                    //Pavi - Commented if(SFEvent.StartDateTime.dateGMT() == eventstartDate && objEvent.Id != SFEvent.id)
                    
                    if((stored_eventStartTime < incomingEventEndTime  && stored_eventEndTime > incomingEventStartTime) && objEvent.Id != SFEvent.id)
                    lstStrOverlappingEventDetails.add('Technician Name: ' + getTechName(getTechId(objEvent.OwnerId)) +' '+' Start Time: '+eventStartTime+' End Time: '+eventEndTime);   
                }
                else if((SFEvent.StartDateTime < eventEndTime  && SFEvent.EndDateTime > eventStartTime) && objEvent.Id != SFEvent.id)
                    lstStrOverlappingEventDetails.add('Technician Name: ' + getTechName(getTechId(objEvent.OwnerId)) +' '+' Start Time: '+eventStartTime+' End Time: '+eventEndTime);
            }
            else 
            {
                if(SFEvent.isAllDayEvent)
                {
                    //WSCH_AuditLogger.debug('SFEvent.StartDateTime.dateGMT() '+SFEvent.StartDateTime.dateGMT());
                   // if(SFEvent.ActivityDate == eventstartDate)
                    //if(SFEvent.StartDateTime.dateGMT() == eventstartDate)
                    // Start And end time in selected globes time zone
                    // Temporarily provide the stored ALL day event, end time - in later release we need to work, to have it persisted

                    DateTime stored_eventStartTime = SFEvent.StartDateTime;
                    DateTime stored_eventEndTime = SFEvent.StartDateTime.addMinutes(Integer.valueof(SFEvent.DurationInMinutes));

                    DateTime incomingEventStartTime = objEvent.StartDateTime; // getting back to the User's timezone, for All day event test
                    DateTime incomingEventEndTime = objEvent.StartDateTime.addMinutes(Integer.valueof(objEvent.DurationInMinutes));

                    if(stored_eventStartTime < incomingEventEndTime  && stored_eventEndTime > incomingEventStartTime)
                    lstStrOverlappingEventDetails.add('Technician Name: ' + getTechName(getTechId(objEvent.OwnerId)) +' '+' Start Time: '+stored_eventStartTime+' End Time: '+stored_eventEndTime);   
                }
                else if((SFEvent.StartDateTime < eventEndTime  && SFEvent.EndDateTime > eventStartTime))
                    lstStrOverlappingEventDetails.add('Technician Name: ' + getTechName(getTechId(objEvent.OwnerId)) +' '+' Start Time: '+eventStartTime+' End Time: '+eventEndTime);
            }
            
        }
        for(SVMXC__SVMX_Event__c SVMXEvent: objTechEvent_WP.lstSVMXEvent)
        {
            String idEvt = objEvent.id;
            if(objEvent != null && objEvent.id != null && String.IsNotBlank(idEvt))
            {  //update case         
                if(SVMXEvent.SVMXC__IsAllDayEvent__c && objEvent.Id != SVMXEvent.id)
                {
                    //WSCH_AuditLogger.debug('SVMXEvent.SVMXC__StartDateTime__c.dateGMT() '+SVMXEvent.SVMXC__StartDateTime__c.dateGMT());
                    //if(SVMXEvent.SVMXC__ActivityDate__c == eventstartDate)
                    //if(SVMXEvent.SVMXC__StartDateTime__c.dateGMT() == eventstartDate)
                    // Start And end time in selected globes time zone
                    // Temporarily provide the stored ALL day event, end time - in later release we need to work, to have it persisted

                    DateTime stored_eventStartTime = SVMXEvent.SVMXC__StartDateTime__c;
                    DateTime stored_eventEndTime = SVMXEvent.SVMXC__StartDateTime__c.addMinutes(Integer.valueof(SVMXEvent.SVMXC__DurationInMinutes__c));

                    DateTime incomingEventStartTime = objEvent.StartDateTime; // getting back to the User's timezone, for All day event test
                    DateTime incomingEventEndTime = objEvent.StartDateTime.addMinutes(Integer.valueof(objEvent.DurationInMinutes));
                    
                    //WSCH_AuditLogger.debug('stored_eventStartTime = ' + stored_eventStartTime + ' < ' + incomingEventEndTime);
                    //WSCH_AuditLogger.debug('calculated_eventEndTime = ' + stored_eventEndTime + ' > ' + incomingEventStartTime );
                    //WSCH_AuditLogger.debug('stored_eventEndTime = ' + SVMXEvent.SVMXC__EndDateTime__c);
                    system.debug(logginglevel.error,'Update case objEvent.id =: ' + objEvent.id + 'stored_eventStartTime: '+stored_eventStartTime+'  incomingEventEndTime:  '+incomingEventEndTime+'  stored_eventEndTime  '+stored_eventEndTime+'  incomingEventStartTime  '+incomingEventStartTime);
                    if((stored_eventStartTime < incomingEventEndTime  && stored_eventEndTime > incomingEventStartTime) && objEvent.Id != SVMXEvent.id)  
                        lstStrOverlappingEventDetails.add('Technician Name: ' + getTechName(getTechId(objEvent.OwnerId)) +' '+' Start Time: '+stored_eventStartTime+' End Time: '+stored_eventEndTime);
                }
                if((SVMXEvent.SVMXC__StartDateTime__c < eventEndTime  && SVMXEvent.SVMXC__EndDateTime__c > eventStartTime) && objEvent.Id != SVMXEvent.id)
                {
                    lstStrOverlappingEventDetails.add('Technician Name: ' + getTechName(getTechId(objEvent.OwnerId)) +' '+' Start Time: '+eventStartTime+' End Time: '+eventEndTime);
                    //WSCH_AuditLogger.debug('lstStrOverlappingEventDetails '+lstStrOverlappingEventDetails);
                }
            }
            else 
            { //create case 
                if(SVMXEvent.SVMXC__IsAllDayEvent__c)
                {
                    //WSCH_AuditLogger.debug('SVMXEvent.SVMXC__StartDateTime__c.dateGMT() '+SVMXEvent.SVMXC__StartDateTime__c.dateGMT());
                   // if(SVMXEvent.SVMXC__ActivityDate__c == eventstartDate)
                    //if(SVMXEvent.SVMXC__StartDateTime__c.dateGMT() == eventstartDate)
                    // Start And end time in selected globes time zone
                    // Temporarily provide the stored ALL day event, end time - in later release we need to work, to have it persisted

                    DateTime stored_eventStartTime = SVMXEvent.SVMXC__StartDateTime__c;
                    DateTime stored_eventEndTime = SVMXEvent.SVMXC__StartDateTime__c.addMinutes(Integer.valueof(SVMXEvent.SVMXC__DurationInMinutes__c));

                    DateTime incomingEventStartTime = objEvent.StartDateTime; // getting back to the User's timezone, for All day event test
                    DateTime incomingEventEndTime = objEvent.StartDateTime.addMinutes(Integer.valueof(objEvent.DurationInMinutes ));
                    
                    //WSCH_AuditLogger.debug('stored_eventStartTime = '+stored_eventStartTime + ' < ' + incomingEventEndTime);
                   // //WSCH_AuditLogger.debug('calculated_eventEndTime = '+stored_eventEndTime + ' > ' + incomingEventStartTime );
                   // //WSCH_AuditLogger.debug('stored_eventEndTime = ' + SVMXEvent.SVMXC__EndDateTime__c);
                    
                    system.debug(logginglevel.error,'Create case objEvent.id =: ' + objEvent.id + 'stored_eventStartTime: '+stored_eventStartTime+'  incomingEventEndTime:  '+incomingEventEndTime+'  stored_eventEndTime  '+stored_eventEndTime+'  incomingEventStartTime  '+incomingEventStartTime);
                    
                    if(stored_eventStartTime < incomingEventEndTime  && stored_eventEndTime > incomingEventStartTime)   
                        lstStrOverlappingEventDetails.add('Technician Name: ' + getTechName(getTechId(objEvent.OwnerId)) +' '+' Start Time: '+stored_eventStartTime+' End Time: '+stored_eventEndTime);
                }
                else if((SVMXEvent.SVMXC__StartDateTime__c < eventEndTime  && SVMXEvent.SVMXC__EndDateTime__c > eventStartTime))
                {
                    lstStrOverlappingEventDetails.add('Technician Name: ' + getTechName(getTechId(objEvent.OwnerId)) +' '+' Start Time: '+eventStartTime+' End Time: '+eventEndTime);
                    //WSCH_AuditLogger.debug('lstStrOverlappingEventDetails '+lstStrOverlappingEventDetails);
                    system.debug(logginglevel.error,'In else block for non All day event');
                    system.debug(logginglevel.error,'SVMXEvent.SVMXC__StartDateTime__c  '+SVMXEvent.SVMXC__StartDateTime__c+'eventEndTime  '+eventEndTime+'  SVMXEvent.SVMXC__EndDateTime__c  '+SVMXEvent.SVMXC__EndDateTime__c+'eventStartTime '+eventStartTime);
                }
            }
            
        }
        system.debug(logginglevel.error,'lstStrOverlappingEventDetails: '+lstStrOverlappingEventDetails);
        return lstStrOverlappingEventDetails;
    }
    
  
  }