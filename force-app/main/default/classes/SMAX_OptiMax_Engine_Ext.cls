public with sharing class SMAX_OptiMax_Engine_Ext
{
    /*
     *Type : Extension class
     *Used : "SMAX_OptiMax_Engine_WS" Class
     *Desc : Used to return exception where ever required
     */
    public class SVMXException extends Exception{}
    public static map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP> mapTechniciansOngoingActivity = new map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
    
    public static SMAX_OptiMax_Engine_WS.ExcSetting_WP setOrganizationParameters( String key, String value)
    {
            SMAX_OptiMax_Engine_WS.ExcSetting_WP orgParam = new SMAX_OptiMax_Engine_WS.ExcSetting_WP();
            orgParam.name = key;
            orgParam.value = value;
            return orgParam;
    }
    
    public Boolean isFullRun;
    public Boolean isDays;
    public DateTime dtmSchedulingHorizonStartDateTime; 
    public Map<id, Map<datetime, SMAX_OptiMax_Engine_WS.DblLocation_WP>> mapTechLatitudeLongitude = new Map<id, Map<datetime, SMAX_OptiMax_Engine_WS.DblLocation_WP>>();
    list<Id> lstCurrentWorkOrders = new list<Id>();
    
    public String strLoggerString = '';
    public static DCON_Utils dcUtils = new DCON_Utils();
    public static String strSfEventKeyPrefix='';
    public static String strSvmxEventKeyPrefix='';
    
    public SMAX_OptiMax_Engine_Ext()
    {
    }

    /*  This function returns the Start Time or the End Time of the given day for the given Business Hours
        Input parameters:
        strDayOfWeek - Monday, Tuesday, etc.
        strStartEnd - StartTime or EndTime
    */
    public static Time getStartEndTime(BusinessHours objBusinessHours, String strDayOfWeek, String strStartEnd)
    {
        try
        {
            return (Time)objBusinessHours.get(strDayOfWeek + strStartEnd);
        }
        catch(Exception ex)
        {
            return NULL;
        }
    }
    
    /*  This function returns the a DateTime object that equals next Working Day's Start Time
        Following scenarios illustrate this:
        Business Hour: 8 AM to 5 PM, Mon to Fri
        Scenario (All date times in local: 1. Before start time; 2. During the day; 3. After end time)
        dtmGivenDateTime   |dtmNextWkgDateTime |startDateTime      |Returned dtmNextWkgDateTime
        2/Dec/2010 7:00 AM |2/Dec/2010 8:00 AM |2/Dec/2010 8:00 AM |2/Dec/2010 8:00 AM
        2/Dec/2010 9:00 AM |2/Dec/2010 9:00 AM |2/Dec/2010 8:00 AM |3/Dec/2010 8:00 AM
        2/Dec/2010 6:00 PM |3/Dec/2010 8:00 AM |3/Dec/2010 8:00 AM |3/Dec/2010 8:00 AM
        
        From the above, it is clear that where dtmNextWkgDateTime (column2) and startDateTime (column3) are the same (date and time),
        dtmNextWkgDateTime is returned as is. Where they are different, we need to skip to the next business day.
    */
    
    public Datetime getNextWorkingHour(BusinessHours objBusinessHour, Datetime dtmGivenDateTime)
    {
        // Get the next working date time with respect to the given date time dtmGivenDateTime
        Datetime dtmNextWkgDateTime = BusinessHours.addGmt(objBusinessHour.id, dtmGivenDateTime, 1L);

        // Get the start time of the next working day
        Time timStartTime = getStartEndTime(objBusinessHour, dtmNextWkgDateTime.format('EEEE', objBusinessHour.timezonesidkey), 'StartTime');

        // Get the start date time of the next working day
        Datetime startDateTime = dcUtils.getDateTimeInTimezone(Date.valueOf(dtmNextWkgDateTime.format('yyyy-MM-dd', objBusinessHour.timeZoneSidKey)), timStartTime, objBusinessHour.timeZoneSidKey);
        
        // Check if the above start date time is different from the next working date time
        // If different, skip to the start of the following working day by getting the
        // end time of the current working day and adding 1 milli sec to it using BusinessHours
        if(dtmNextWkgDateTime.format('yyyy-MM-dd HH:mm:ss') != startDateTime.format('yyyy-MM-dd HH:mm:ss'))
        {
            Time timEndTime = getStartEndTime(objBusinessHour, dtmNextWkgDateTime.format('EEEE', objBusinessHour.timezonesidkey), 'EndTime');
            if(timStartTime == timEndTime) //24 Hours Business Day, so skip to the next day
            {
                dtmNextWkgDateTime = dtmNextWkgDateTime.addDays(1);
            }
            Datetime dtmEndDateTime = dcUtils.getDateTimeInTimezone(Date.valueOf(dtmNextWkgDateTime.format('yyyy-MM-dd', objBusinessHour.timeZoneSidKey)), timEndTime, objBusinessHour.timeZoneSidKey);
            dtmNextWkgDateTime = BusinessHours.addGmt(objBusinessHour.id, dtmEndDateTime, 1L);
        }
    
        return dtmNextWkgDateTime;
    }
    
    // Return TRUE if the given date is a working day in the given Business Hours. Else return FALSE
    public boolean isWorkingDay(BusinessHours objBusinessHour, Date datRequestedDate)
    {
        
        //system.debug('datRequestedDate - ' + datRequestedDate);
        // Get the start time of the given date (i.e. start of the day in the given time zone)
        Datetime dtmDayStartDateTime = dcUtils.getDateTimeInTimezone(datRequestedDate, Time.newInstance(0, 0, 0, 0), objBusinessHour.timeZoneSidKey);
        
        //system.debug('dtmDayStartDateTime - ' + dtmDayStartDateTime);
        
        // Get the next working date time with respect to the given day's start
        Datetime dtmNextWkgDateTime = BusinessHours.addGmt(objBusinessHour.id, dtmDayStartDateTime, 1L);
        
        // Get the date of the next working date time in the given time zone
        Date datNextWkgDate = Date.valueOf(dtmNextWkgDateTime.format('yyyy-MM-dd', objBusinessHour.timeZoneSidKey));

        // If the given date and next working date are the same, the given day is a working day
        if(datNextWkgDate == datRequestedDate)
            return TRUE;
        else
            return FALSE;
    }

    // Output structure (CapacityResult class)
    public class capacityResult
    {
        // Updated number of days in scheduling horizon (calendar days)
        //public Integer intUpdatedNoOfDays{ get; set;}

        // String of work orders to be rescheduled & their related events
        public String strWOsToReschedAndEvents{ get; set;}
        
        public set<Id> setReschedExternalWOs{ get; set;}

        // Work order list (includes the new work orders and the work orders [existing on techniciansï¿½ calendar already] to be rescheduled)
        public List<SVMXC__Service_Order__c> lstWOsForOptiMax{ get; set;}

        // Available time windows for each technician (Map<Tech Id, Map<Date, Time Windows>>)
        public Map<id, Map<date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> > mapTechAvailability = new Map<id, Map<date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> >();
        
        // Additional details of the event like address, latitude, longitude and type of event
        public Map<String, SMAX_OptiMax_Engine_WS.TechniciansEventsAdditonalDetails_WP> mapTechAdditionalDetails = new Map<String, SMAX_OptiMax_Engine_WS.TechniciansEventsAdditonalDetails_WP>();
        
        // Map of technician with start date time and event Id
        //public Map<Id, Map<DateTime, Id>> mapTechIdStrtDtTEventId = new Map<Id, Map<DateTime, Id>>();               
        
        //Map of Technician with eventId and start and end datetime
        public Map<Id, Map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> mapTechIdExecTimeEventId = new Map<Id, Map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>();
        
        //Map of Technician with ONS eventId and start and end datetime
        public Map<Id, Map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> mapTechIdONSExecTimeEventId = new Map<Id, Map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>();
        
        //Map of Technician with BreakHour start and end datetime
        public Map<Id, Map<Date, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> mapTechIdBreakEventExecTime = new Map<Id, Map<Date, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>();
    }
    
   
    //Get List of  SF Event for Tech within the time range
    public static Map<Id, Event> getMapSFEventforTech(set<string> lstOwnerID,DateTime inputStartTime, DateTime inputEndTime)
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
         
        //system.debug('getMapSFEventforTech inputStartTime:- : '+inputStartTime +' inputEndTime:-  '+ inputEndTime+' Technicians :  '+lstOwnerID); 
        
        //Get list of Events for Tech within the time range inputStartTime and inputEndtdate with additional validation for All-Day events retival i.e. using ActivityDate instead of StartDateTime and in EndDateTime & inputStartdatetime time component is (0,0,0,0) (should be in All-day events)
        //Map<Id, Event> tempEvents = new Map<Id, Event>([Select Id, WhatId, Subject, Description, ActivityDateTime, OwnerId, EndDateTime, DurationInMinutes,IsAllDayEvent,ActivityDate,StartDatetime, Location, SVMXC__SM_Site__r.SVMXC__Street__c, SVMXC__SM_Site__r.SVMXC__City__c, SVMXC__SM_Site__r.SVMXC__State__c, SVMXC__SM_Site__r.SVMXC__Zip__c, SVMXC__SM_Site__r.SVMXC__Country__c, SVMXC__SM_Site__r.SVMXC__Latitude__c, SVMXC__SM_Site__r.SVMXC__Longitude__c from Event where (OwnerId in:lstOwnerID) AND ((StartDateTime <= :inputEndTime and EndDateTime >= :inputStartTime)OR (ActivityDate <= :inputEndtdate and EndDateTime >= :inputStartdatetime AND IsAllDayEvent = true ) OR(ActivityDate = :inputStartdate AND IsAllDayEvent = true))]);
        Map<Id, Event> tempEvents = new Map<Id, Event>([Select Id, WhatId, Subject, Description, ActivityDateTime, OwnerId, EndDateTime, DurationInMinutes,IsAllDayEvent,ActivityDate,StartDatetime, Location,SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c,SVMXC__SM_Status__c,Type, SVMXC__Service_Duration__c,SVMXC__Driving_Time_Home__c,SVMXC__Driving_Time__c from Event where (OwnerId in:lstOwnerID) AND (SVMXC__Service_Duration__c > 0) AND  IsRecurrence = false AND ((StartDateTime <= :inputEndTime and EndDateTime >= :inputStartTime)OR (ActivityDate <= :inputEndtdate and EndDateTime >= :inputStartdatetime AND IsAllDayEvent = true) OR(ActivityDate = :inputStartdate AND IsAllDayEvent = true))]);
            
        return tempEvents;
    }
    
    //Get List of  SVMX Event for Tech within the time range inputStartTime and inputEndtdate
    public static Map<Id, SVMXC__SVMX_Event__c> getMapSVMXEventforTech(set<String> lstOwnerID,DateTime inputStartTime, DateTime inputEndTime)
    {
        //Following Scenarios are considered for checking Double booking
        // events that "end" during the input event's start and end time, 
        // events that "start" during the input event's start and end time
        // events that "start" before input event's start time and "end" after input event's end time
        // events that "start" within the input event's start and end time including fully overlapped events
        
        //system.debug('getMapSVMXEventforTech inputStartTime:- : '+inputStartTime +' inputEndTime:-  '+ inputEndTime+' Technicians :  '+lstOwnerID); 
        date inputStartdate = inputStartTime.dateGMT();
        date inputEnddate = inputEndTime.dateGMT();
        datetime inputStartdatetime = Datetime.newInstanceGmt(inputStartTime.dateGMT(),Time.newInstance(0, 0, 0, 0));
        //WSCH_AuditLogger.debug('inputStartdatetime After GMT (For Event window) : '+inputStartdatetime);
        
        //Map<Id, SVMXC__SVMX_Event__c> tempEvents = new Map<Id, SVMXC__SVMX_Event__c>([Select Id, Name, SVMXC__Location__c, SVMXC__Description__c, SVMXC__DurationInMinutes__c, SVMXC__WhatId__c,SVMXC__Technician__c, SVMXC__ActivityDate__c,SVMXC__ActivityDateTime__c,SVMXC__EndDateTime__c,SVMXC__StartDateTime__c, SVMXC__IsAllDayEvent__c, SVMXC__SM_Site__r.SVMXC__Street__c, SVMXC__SM_Site__r.SVMXC__City__c, SVMXC__SM_Site__r.SVMXC__State__c, SVMXC__SM_Site__r.SVMXC__Zip__c, SVMXC__SM_Site__r.SVMXC__Country__c, SVMXC__SM_Site__r.SVMXC__Latitude__c, SVMXC__SM_Site__r.SVMXC__Longitude__c from SVMXC__SVMX_Event__c where (SVMXC__Technician__c in:lstOwnerID) AND ((SVMXC__StartDateTime__c <= :inputEndTime and SVMXC__EndDateTime__c >= :inputStartTime)OR (SVMXC__ActivityDate__c <= :inputEnddate and SVMXC__EndDateTime__c >= :inputStartdatetime AND SVMXC__IsAllDayEvent__c = true) OR(SVMXC__StartDateTime__c = :inputStartdatetime AND SVMXC__IsAllDayEvent__c = true))]);
        Map<Id, SVMXC__SVMX_Event__c> tempEvents = new Map<Id, SVMXC__SVMX_Event__c>([Select Id, Name, SVMXC__Location__c, SVMXC__Description__c, SVMXC__DurationInMinutes__c, SVMXC__WhatId__c,SVMXC__Technician__c, SVMXC__ActivityDate__c,SVMXC__ActivityDateTime__c,SVMXC__EndDateTime__c,SVMXC__StartDateTime__c, SVMXC__IsAllDayEvent__c, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c, SVMXC__Service_Order__r.SVMXC__Latitude__c, SVMXC__Service_Order__r.SVMXC__Longitude__c, SVMXC__Service_Order__r.SVMXC__Street__c, SVMXC__Service_Order__r.SVMXC__City__c, SVMXC__Service_Order__r.SVMXC__State__c, SVMXC__Service_Order__r.SVMXC__Zip__c, SVMXC__Service_Order__r.SVMXC__Country__c,SVMXC__SM_Status__c,SVMXC__Type__c,SVMXC__Driving_Time__c,SVMXC__Driving_Time_Home__c from SVMXC__SVMX_Event__c where (SVMXC__Technician__c in:lstOwnerID) AND ((SVMXC__StartDateTime__c <= :inputEndTime and SVMXC__EndDateTime__c >= :inputStartTime)OR (SVMXC__ActivityDate__c <= :inputEnddate and SVMXC__EndDateTime__c >= :inputStartdatetime AND SVMXC__IsAllDayEvent__c = true) OR(SVMXC__StartDateTime__c = :inputStartdatetime AND SVMXC__IsAllDayEvent__c = true))]); 
        
        return tempEvents;
        
    }
    
    /*
     * Name: getTechiniciansAvailability()
     * Input:
     * ======
     * List technician ==> (Map<date, ExecutionTime_WP>) [Output param, will be NULL when this function is invoked],
     * List of technicians, Map of Business Hours, Map of technicians' non-Work Order events,
     * Scheduling Horizon Dates
     * Output:
     * =======
     * List technician => (Map<date, ExecutionTime_WP>)
     * Description:
     * ============
     * This is a wrapper method to which all the technicians' data is passed
     * It calls the function techAvailabilityWindow to get available time windows for each technician
    */
    public Map<id, Map<date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>> getTechiniciansAvailability(Map<id, Map<date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>> mapTempTechAvailability, List<SVMXC__Service_Group_Members__c> tech_LO, Map<String, BusinessHours> businessHours_LO, Map<String, List<Date>> maptechAllDayEventDates, set<Date> setSchedHorizonDates, Map<String, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>> mapTechMultiDayEvents){
        
        
        for(SVMXC__Service_Group_Members__c tech: tech_LO)
        {
            set<Date> setRemovalDates = new set<Date>();
            set<Date> setFinalDates = new set<Date>(setSchedHorizonDates);
            List<Date> lstAllDays = new list<Date>();
            list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstMultiDays = new list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
            if(mapTechMultiDayEvents != null && mapTechMultiDayEvents.size() > 0){
                lstMultiDays = mapTechMultiDayEvents.get(tech.id);
            }
            if(maptechAllDayEventDates != null && maptechAllDayEventDates.size() > 0)
                lstAllDays = maptechAllDayEventDates.get(tech.id);
                
            if(lstAllDays != null && lstAllDays.size() > 0){
                for(Date dt : lstAllDays){
                    if(setSchedHorizonDates.contains(dt)){
                        setRemovalDates.add(dt);
                    }
                }
            }
            setFinalDates.removeAll(setRemovalDates);
            strLoggerString += system.now() + ': Capacity Calculation - getTechiniciansAvailability:Horizon dates after removing all day event for tech - ' + tech.Name +'setFinalDates -'+setFinalDates+ '\n';
            
            try
            {
                mapTempTechAvailability = techAvailabilityWindow(mapTempTechAvailability, tech.Id, businessHours_LO.get(tech.SVMXC__Working_Hours__c), businessHours_LO.get(tech.SVMXC__Break_Hours__c), null, setFinalDates, lstMultiDays);
            }
            catch(Exception e)
            {
                strLoggerString += system.now() + ': Capacity Calculation - getTechiniciansAvailability exception for: ' + tech.Id + '\n';
                strLoggerString += system.now()+': Exception type caught: ' + e.getTypeName()+'\n' +'Message: ' + e.getMessage()+'\n'+'Cause: ' + e.getCause()+'\n'+'Line number: ' + e.getLineNumber()+'\n'+'Stack trace: ' + e.getStackTraceString()+'\n';
                throw new SVMXException(strLoggerString);
            }
        }
        return mapTempTechAvailability;
    }
    
    public Map<id, Map<date, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> getTechniciansBreakHoursWindow(List<SVMXC__Service_Group_Members__c> lstOfTechnicians, Map<String, BusinessHours> mapBusinessHours, set<Date> setSchedHorizonDates) {
        
        DateTime dtmBusinessHourStartDateTime, dtmBusinessHourEndDateTime, dtmBreakHourStartDateTime, dtmBreakHourEndDateTime;
        Map<id, Map<date, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> mapTempTechBreakHour = new Map<id, Map<date, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>();
        
        strLoggerString += system.now() + ': Capacity Calculation getTechniciansBreakHoursWindow() : setSchedHorizonDates:' + setSchedHorizonDates + '\n';
        
        for(SVMXC__Service_Group_Members__c tech: lstOfTechnicians)
        {
            Map<Date,SMAX_OptiMax_Engine_WS.ExecutionTime_WP> mapOfEachDateBreakHourWindow = new Map<Date,SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
            try
            {
                if(tech.SVMXC__Break_Hours__c == null){
                    continue;
                }
                BusinessHours techBreakHours = mapBusinessHours.get(tech.SVMXC__Break_Hours__c);
                BusinessHours techBusinessHours = mapBusinessHours.get(tech.SVMXC__Working_Hours__c);
                strLoggerString += system.now() + ': Capacity Calculation getTechniciansBreakHoursWindow() : Tech:-' + tech.Name +'; Tech Break Hours:-'+techBreakHours.Id+'; Tech Working Hours:-'+techBusinessHours.Id+ '\n';
                         
               // Build technician's Break Hour windows for each working day in the scheduling horizon
                for(Date calendarDate : setSchedHorizonDates)
                {
                    // Check if the date is a working day
                    if(isWorkingDay(techBusinessHours, calendarDate))
                    {
                        string datesDay = (datetime.newInstanceGmt(calendarDate, Time.newinstance(0, 0, 0, 0))).formatGmt('EEEE');
                        
                        //strLoggerString += system.now() + ': Capacity Calculation getTechniciansBreakHoursWindow() : datesDay:' + datesDay + '\n';
                        //strLoggerString += system.now() + ': Capacity Calculation getTechniciansBreakHoursWindow() : techBusinessHours:' + techBusinessHours + '\n';
                        
                        // Get the start and end times for the given date
                        Time timTechStartTime = getStartEndTime(techBusinessHours, datesDay, 'StartTime');
                        Time timTechEndTime = getStartEndTime(techBusinessHours, datesDay, 'EndTime');
                        
                        //strLoggerString += system.now() + ': Capacity Calculation getTechniciansBreakHoursWindow() : calendarDate: ' + calendarDate + '\n';
                        //strLoggerString += system.now() + ': Capacity Calculation getTechniciansBreakHoursWindow() : timTechStartTime: ' + timTechStartTime + '\n';
                        //strLoggerString += system.now() + ': Capacity Calculation getTechniciansBreakHoursWindow() : timTechEndTime: ' + timTechEndTime + '\n';
                        
                        dtmBusinessHourStartDateTime = dcUtils.getDateTimeInTimezone(calendarDate, timTechStartTime, techBusinessHours.TimeZoneSidKey);
                        dtmBusinessHourEndDateTime = dcUtils.getDateTimeInTimezone(calendarDate, timTechEndTime, techBusinessHours.TimeZoneSidKey);
                        
                        // If Incremental run OR Full Run's Start After Unit is Hours
                        if(isFullRun == FALSE || isDays == FALSE)
                        {
                            // if day's start time is < Scheduling Horizon's Start Date Time, set day's start time = Scheduling Horizon's Start Date Time
                            if(dtmBusinessHourStartDateTime < dtmSchedulingHorizonStartDateTime)
                                dtmBusinessHourStartDateTime = dtmSchedulingHorizonStartDateTime;
                        }
                        
                        // If the available working window is valid
                        if(dtmBusinessHourStartDateTime < dtmBusinessHourEndDateTime)
                        {
                            // If break hours are there, validate the start & end time and build time windows and add to event list
                            if(techBreakHours != NULL)
                            {
                                if(techBusinessHours.TimeZoneSidKey == techBreakHours.TimeZoneSidKey) {
                                    Time timTechBreakStart = getStartEndTime(techBreakHours, datesDay, 'StartTime');
                                    Time timTechBreakEnd = getStartEndTime(techBreakHours, datesDay, 'EndTime');
                                    // fix to consider break hours with start and/or end times outside the boundary of working hours
                                    // if(timTechBreakStart != NULL && timTechBreakStart != timTechBreakEnd && timTechBreakStart > timTechStartTime && timTechBreakEnd < timTechEndTime)
                                    if(timTechBreakStart != NULL && timTechBreakEnd != NULL && timTechBreakStart != timTechBreakEnd)
                                    {
                                        dtmBreakHourStartDateTime = dcUtils.getDateTimeInTimezone(calendarDate, timTechBreakStart, techBreakHours.TimeZoneSidKey);
                                        dtmBreakHourEndDateTime = dcUtils.getDateTimeInTimezone(calendarDate, timTechBreakEnd, techBreakHours.TimeZoneSidKey);
                                        SMAX_OptiMax_Engine_WS.ExecutionTime_WP breakHourWindow = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(dtmBreakHourStartDateTime, dtmBreakHourEndDateTime);
                                        mapOfEachDateBreakHourWindow.put(calendarDate, breakHourWindow);
                                    }
                                }
                            }
                        }
                    }
                }
                mapTempTechBreakHour.put(tech.Id, mapOfEachDateBreakHourWindow);            
            } catch(Exception e) {
                strLoggerString += system.now() + ': Capacity Calculation - getTechniciansBreakHoursWindow exception for: ' + tech.Id + '\n';
                strLoggerString += system.now()+': Exception type caught: ' + e.getTypeName()+'\n' +'Message: ' + e.getMessage()+'\n'+'Cause: ' + e.getCause()+'\n'+'Line number: ' + e.getLineNumber()+'\n'+'Stack trace: ' + e.getStackTraceString()+'\n';
                throw new SVMXException(strLoggerString);
            }
        }
        return mapTempTechBreakHour;  
    }

    /*
     * Name: techAvailabilityWindow()
     * Input:
     * ======
     * List technician ==> (Map<date, ExecutionTime_WP>) [Output param, will be NULL when this function is invoked for the first time],
     * Technician Id, Working Hours, Break Hours, List of Technician's non-Work Order events,
     * Scheduling Horizon Dates
     * Output:
     * =======
     * List technician => (Map<date, ExecutionTime_WP>)
     * Description:
     * ============
     * This gets the available time windows for each technician when called by the function getTechiniciansAvailability
     */
    public Map<id, Map<date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>> techAvailabilityWindow(Map<id, Map<date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>> mapTempTechAvailability, id techId, BusinessHours oBusinessHours, BusinessHours obreakHours, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> eventExeTime, set<Date> setSchedHorizonDates, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstMultiDayEvent)
    {
        DateTime dtmBusinessHourStartDateTime, dtmBusinessHourEndDateTime, dtmBreakHourStartDateTime, dtmBreakHourEndDateTime;
        list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstEventExecutionTime = new list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
        
        Boolean isValidBusinessHour = TRUE;
        
        Map<id, Map<date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>> techAvail = new Map<id, Map<date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>>();
        Map<date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> availableWindow = new Map<date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>();
        Map<date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> eventWindow = new Map<date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>();
        
        if(eventExeTime != NULL && eventExeTime.size() > 0)
            lstEventExecutionTime.addAll(eventExeTime);
        
        //strLoggerString += system.now() + ': Capacity Calculation - In techAvailabilityWindow for technician: ' + techId + '\n';
        if(mapTempTechAvailability != NULL) // Will be TRUE from the second tech onwards
            techAvail = mapTempTechAvailability;
        
        //strLoggerString += system.now() + ': Capacity Calculation techAvailabilityWindow() : setSchedHorizonDates:' + setSchedHorizonDates + '\n';
        
        if(isValidBusinessHour == TRUE)
        {
            // Build technician's working time windows for each working day in the scheduling horizon
            for(Date calendarDate : setSchedHorizonDates)
            {
                // Check if the date is a working day
                if(isWorkingDay(oBusinessHours, calendarDate))
                {
                    list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstEventTimeWindows = new list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
                    string datesDay = (datetime.newInstanceGmt(calendarDate, Time.newinstance(0, 0, 0, 0))).formatGmt('EEEE');
                    
                    //strLoggerString += system.now() + ': Capacity Calculation techAvailabilityWindow() : datesDay:' + datesDay + '\n';
                    //strLoggerString += system.now() + ': Capacity Calculation techAvailabilityWindow() : oBusinessHours:' + oBusinessHours + '\n';
                    
                    // Get the start and end times for the given date
                    Time timTechStartTime = getStartEndTime(oBusinessHours, datesDay, 'StartTime');
                    Time timTechEndTime = getStartEndTime(oBusinessHours, datesDay, 'EndTime');
                    
                    //strLoggerString += system.now() + ': Capacity Calculation techAvailabilityWindow() : timTechStartTime:' + timTechStartTime + '\n';
                    //strLoggerString += system.now() + ': Capacity Calculation techAvailabilityWindow() : timTechEndTime:' + timTechEndTime + '\n';
                    
                    // If it is a 24 Hours Business Day, not valid for technician; skip
                    if(timTechStartTime == timTechEndTime)
                        continue;
                    
                    dtmBusinessHourStartDateTime = dcUtils.getDateTimeInTimezone(calendarDate, timTechStartTime, oBusinessHours.TimeZoneSidKey);
                    dtmBusinessHourEndDateTime = dcUtils.getDateTimeInTimezone(calendarDate, timTechEndTime, oBusinessHours.TimeZoneSidKey);
                    
                    // If Incremental run OR Full Run's Start After Unit is Hours
                    if(isFullRun == FALSE || isDays == FALSE)
                    {
                        // if day's start time is < Scheduling Horizon's Start Date Time, set day's start time = Scheduling Horizon's Start Date Time
                        if(dtmBusinessHourStartDateTime < dtmSchedulingHorizonStartDateTime)
                            dtmBusinessHourStartDateTime = dtmSchedulingHorizonStartDateTime;
                    }
 
                    // Multiday in Batch
                    if(lstMultiDayEvent != null && lstMultiDayEvent.size() > 0){
                        //WSCH_AuditLogger.debug('SMAX_OptiMax_Engine_Ext:: getTechAvailabilityWindow:calendarDate- ' + calendarDate);
                        strLoggerString += system.now() + ': Capacity Calculation getTechAvailabilityWindow:calendarDate- ' + calendarDate + '\n';
                        for(WSCH_Provider_ECO_Stubs.ExecutionTime_WP exeTime : lstMultiDayEvent){
                            //Date startDate = exeTime.workingHoursBegin.dateGmt();
                            //Date endDate = exeTime.workingHoursEnd.dateGmt();
                            //WSCH_AuditLogger.debug('SMAX_OptiMax_Engine_Ext:: getTechAvailabilityWindow:exeTime.workingHoursBegin- ' + exeTime.workingHoursBegin);
                            //WSCH_AuditLogger.debug('SMAX_OptiMax_Engine_Ext:: getTechAvailabilityWindow:exeTime.workingHoursEnd- ' + exeTime.workingHoursEnd);
                            strLoggerString += system.now() + ': Capacity Calculation getTechAvailabilityWindow:exeTime.workingHoursBegin- ' + exeTime.workingHoursBegin + 'getTechAvailabilityWindow:exeTime.workingHoursEnd- ' + exeTime.workingHoursEnd + '\n';
                            
                            DateTime startDateTimeTerrTZ = WSCH_DateUtils.doTZConversion(exeTime.workingHoursBegin, 'GMT', oBusinessHours.TimeZoneSidKey);
                            DateTime endDateTimeTerrTZ = WSCH_DateUtils.doTZConversion(exeTime.workingHoursEnd, 'GMT', oBusinessHours.TimeZoneSidKey);
                            //WSCH_AuditLogger.debug('SMAX_OptiMax_Engine_Ext:: getTechAvailabilityWindow:startDateTimeTerrTZ- ' + startDateTimeTerrTZ);
                            //WSCH_AuditLogger.debug('SMAX_OptiMax_Engine_Ext:: getTechAvailabilityWindow:endDateTimeTerrTZ- ' + endDateTimeTerrTZ);
                            strLoggerString += system.now() + ': Capacity Calculation getTechAvailabilityWindow:startDateTimeTerrTZ- ' + startDateTimeTerrTZ + 'getTechAvailabilityWindow:endDateTimeTerrTZ- ' + endDateTimeTerrTZ + '\n';
                    
                            Date startDate = startDateTimeTerrTZ.dateGmt();
                            Date endDate = endDateTimeTerrTZ.dateGmt();
                     
                            //WSCH_AuditLogger.debug('SMAX_OptiMax_Engine_Ext:: getTechAvailabilityWindow:startDate TerrTZ- ' + startDate);
                            //WSCH_AuditLogger.debug('SMAX_OptiMax_Engine_Ext:: getTechAvailabilityWindow:endDate TerrTZ- ' + endDate);
                            strLoggerString += system.now() + ': Capacity Calculation getTechAvailabilityWindow:startDate TerrTZ- ' + startDate + 'getTechAvailabilityWindow:endDate TerrTZ- ' + endDate + '\n';
                            
                            if(calendarDate >= startDate){
                                if(dtmBusinessHourStartDateTime < exeTime.workingHoursBegin){
                                    dtmBusinessHourStartDateTime = exeTime.workingHoursBegin;
                                    //WSCH_AuditLogger.debug('SMAX_OptiMax_Engine_Ext:: getTechAvailabilityWindow:inside if()dtmBusinessHourStartDateTime- ' + dtmBusinessHourStartDateTime);
                                    strLoggerString += system.now() + ': Capacity Calculation getTechAvailabilityWindow:inside if()dtmBusinessHourStartDateTime- ' + dtmBusinessHourStartDateTime + '\n';
                                }
                                //break;
                            }else if(calendarDate >= endDate){
                                if(exeTime.workingHoursEnd < dtmBusinessHourEndDateTime){ // if it is last day than BH end override by last day time
                                    dtmBusinessHourEndDateTime = exeTime.workingHoursEnd;
                                    //WSCH_AuditLogger.debug('SMAX_OptiMax_Engine_Ext:: getTechAvailabilityWindow:inside if()dtmBusinessHourEndDateTime- ' + dtmBusinessHourEndDateTime);
                                    strLoggerString += system.now() + ': Capacity Calculation getTechAvailabilityWindow:inside if()dtmBusinessHourEndDateTime- ' + dtmBusinessHourEndDateTime + '\n';
                                }
                                //break;                            
                            }
                        }
                    }
                    
                    // If the available working window is valid
                    if(dtmBusinessHourStartDateTime < dtmBusinessHourEndDateTime)
                    {
                        // Setup technician's Business Hours as available window
                        SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpTempAvailableWindow = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(dtmBusinessHourStartDateTime, dtmBusinessHourEndDateTime);
                        lstEventTimeWindows.add(wrpTempAvailableWindow);
                        availableWindow.put(calendarDate, lstEventTimeWindows);
                        
                    }
                }
            }
            
               
            //Added the below code after commenting the above code                
            Map<date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> tempAvailableWindow = new Map<date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>();
            for(Date eachDate : setSchedHorizonDates)
            {
                if(availableWindow.containsKey(eachDate) && availableWindow.get(eachDate).size() > 0)
                {
                    list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstEventTimeWindows = availableWindow.get(eachDate);
                    if(lstEventTimeWindows.size() > 1)
                        lstEventTimeWindows = sortExecutionTime(lstEventTimeWindows);
                    
                    tempAvailableWindow.put(eachDate, lstEventTimeWindows);
                }
            }
            
            strLoggerString += system.now() + ': Capacity Calculation - Actual available time window size: ' + tempAvailableWindow.size() + '\n';
            
            if(tempAvailableWindow.size() > 0)
                techAvail.put(techId, tempAvailableWindow);
        }
        
        //TODO: techAvail map needs to clear in future  
        //Cleaned for Event Heap size issue
        //actualAvailableWindow.clear();
        //availableWindow.clear();
        //eventWindow.clear();
        
        return techAvail;
    }
    
    /*
     * Name: generateBusinessHourDetails ()
     * Input:
     * ======
     * List of Business Hours, First Day's Start DateTime (not used),
     * Scheduling Horizon Dates (these are local dates in Territory's Business Hours)
     * Output:
     * =======
     * List Map<Business hour Id, Map<date, ExecutionTime_WP>>
     * Description:
     * ============
     * Returns the list of time windows for each Business Hour (1 window per Scheduling Horizon Date)
     */
    public Map<String, Map<Date, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> generateBusinessHourDetails(List<BusinessHours> bh_L, Datetime startDateTime, set<Date> availableDates_S){
        Map<String, Map<Date, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> mapBusinessHourDetails = new Map<String, Map<Date, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>();
        for(BusinessHours bh: bh_L)
        {
            if(bh != null){
                Map<Date, SMAX_OptiMax_Engine_WS.ExecutionTime_WP> dateTime_M = new Map<Date, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
                strLoggerString += system.now() + ': Getting time windows for Business Hours: ' + bh.Id + '\n';
                for(Date date_T: availableDates_S)
                {
                    if(isWorkingDay(bh, date_T))
                    {
                        SMAX_OptiMax_Engine_WS.ExecutionTime_WP exeTime = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP();
                        Time startTime_T = getStartEndTime(bh, datetime.newInstanceGmt(date_T, Time.newInstance(0, 0, 0, 0)).formatGmt('EEEE'), 'StartTime');
                        Time endTime_T = getStartEndTime(bh, datetime.newInstanceGmt(date_T, Time.newInstance(0, 0, 0, 0)).formatGmt('EEEE'), 'EndTime');
                        if(startTime_T == endTime_T)
                        {   // 24 hours Business Day
                            endTime_T = Time.newInstance(23, 59, 59, 999);
                        }
                        exeTime.startDateTime = exeTime.startDate = dcUtils.getDateTimeInTimezone(date_T, startTime_T, bh.timeZoneSidKey);
                        
                        if(startDateTime != NULL && exeTime.startDateTime < startDateTime)
                        {
                            exeTime.startDateTime = exeTime.startDate = startDateTime;
                        }
                        
                        exeTime.endDateTime = exeTime.endDate = dcUtils.getDateTimeInTimezone(date_T, endTime_T, bh.timeZoneSidKey);
                        dateTime_M.put(date_T, exeTime);
                    }
                }
                mapBusinessHourDetails.put(String.valueof(bh.Id), dateTime_M);
            }
        }
        return mapBusinessHourDetails;
    }
    
    
    public double getAvailablity(Map<id, Map<date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>> techAvailability)
    {
        double dblTotalAvailablity = 0;
        
        if(techAvailability != NULL)
            // Loop for each tech
            for(string str : techAvailability.keyset())
            {
                Map<date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> mapDateExeTime = techAvailability.get(str);
                
                // Loop for each date
                for(date dDate : mapDateExeTime.keySet())
                {
                    if(mapDateExeTime.get(dDate) != NULL)
                    {
                        // Loop for each actual available time window
                        for(SMAX_OptiMax_Engine_WS.ExecutionTime_WP oExecutionTime_WP : mapDateExeTime.get(dDate))
                            dblTotalAvailablity += ((oExecutionTime_WP.endDateTime.getTime() - oExecutionTime_WP.startDateTime.getTime())/1000);
                    }
                }
            }
        return dblTotalAvailablity;
    }
    
    public double computeIdleTime(Datetime startTime, Datetime endTime, double serviceDuration)
    {
        double actualWoSec = (endTime.getTime() - startTime.getTime()) / 1000; // MilliSec to Seconds
        double idleTime = (actualWoSec - serviceDuration) / 60; // Seconds to minutes
        if(idleTime < 0)
            idleTime = 0;
        return idleTime;
    }

    // Get the latitude and longitude of the given Tech at the given Date Time
    public SMAX_OptiMax_Engine_WS.DblLocation_WP getLocation_WP(Id strTechId, datetime dtmTechStartDateTime, datetime dtmTodaysStart, Decimal techLatitude, Decimal techLongitude)
    {
        Map<datetime, SMAX_OptiMax_Engine_WS.DblLocation_WP> eventLatLng = new Map<datetime, SMAX_OptiMax_Engine_WS.DblLocation_WP>();
        List<datetime> techEventTime = new List<datetime>();
        SMAX_OptiMax_Engine_WS.DblLocation_WP wrpTechLastLatLong = new SMAX_OptiMax_Engine_WS.DblLocation_WP(techLatitude, techLongitude);
        eventLatLng = mapTechLatitudeLongitude.get(strTechId);
        
        if(eventLatLng != NULL && eventLatLng.size() > 0)
        {
            //Sort the eventLatLng map keyset (event end date time)
            techEventTime.addAll(eventLatLng.keySet());
            techEventTime.sort();
            for(datetime dtmEventEndTime : techEventTime)
            {
                if(dtmEventEndTime < dtmTodaysStart) continue;// Old events
                if(dtmEventEndTime == dtmTechStartDateTime) 
                    return eventLatLng.get(dtmEventEndTime);
                if(dtmEventEndTime < dtmTechStartDateTime)
                    wrpTechLastLatLong = eventLatLng.get(dtmEventEndTime);
                else
                    return wrpTechLastLatLong;
            }
        }
        
        return wrpTechLastLatLong;
    }
    
    // Sort ExecutionTime_WP list by startDateTime
    public List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> sortExecutionTime(List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstInputTimeWindows)
    {
        List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstOutputTimeWindows = new List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
        List<DateTime> lstStartDateTime = new List<DateTime>();
        Map<DateTime, Integer> mapStartDateTimeIndex = new Map<DateTime, Integer>();
        Integer intListIndex = 0;
        for(SMAX_OptiMax_Engine_WS.ExecutionTime_WP timeWindow: lstInputTimeWindows)
        {
            mapStartDateTimeIndex.put(timeWindow.startDateTime, intListIndex);
            intListIndex++;
        }
        lstStartDateTime.addall(mapStartDateTimeIndex.keyset());
        lstStartDateTime.sort();
        for(DateTime startDt: lstStartDateTime)
            lstOutputTimeWindows.add(lstInputTimeWindows.get(mapStartDateTimeIndex.get(startDt)));
        return lstOutputTimeWindows;
    }

    
    // Return the InitiateJob WS response structure as string - this contains work orders, technicians, events, and job parameters
    public String logInitiateJob(SMAX_OptiMax_Engine_WS.opInitateJobs_WP outputResult){
        String response = '';
        response += 'Work Orders:\n';
        for(SMAX_OptiMax_Engine_WS.WorkOrder_WP wrpWO: outputResult.workOrder_LWP)
        {
            response += wrpWO.toString() + '\n';
        }
        response += '\nTechnicians:\n';
        for(SMAX_OptiMax_Engine_WS.Technician_WP wrpTech: outputResult.technician_LWP)
        {
            response += wrpTech.toString() + '\n';
        }
        response += '\nTechnician Events:\n';
        for(SMAX_OptiMax_Engine_WS.TechniciansEvents_WP wrpTechEvent: outputResult.technicianEvent_LWP)
        {
            response += wrpTechEvent.toString() + '\n';
        }
        response += '\nJob Parameters:\n';
        for(SMAX_OptiMax_Engine_WS.ExcSetting_WP wrpSetting: outputResult.Exec_SettingsMap)
        {
            response += wrpSetting.toString().replace('JOpt', 'OptiMax') + '\n';
            
        }
        return response;
    }
    
    public List<BusinessHours> getCompleteBusinessHour(List<BusinessHours> lstBusinessHours)
    {
        for(BusinessHours objBusinessHour : lstBusinessHours)
        {
            if(objBusinessHour.MondayStartTime != NULL && objBusinessHour.MondayStartTime == objBusinessHour.MondayEndTime)
            {
                objBusinessHour.MondayEndTime = Time.newInstance(23, 59, 0, 00);
            }
            if(objBusinessHour.TuesdayStartTime != NULL && objBusinessHour.TuesdayStartTime == objBusinessHour.TuesdayEndTime)
            {
                objBusinessHour.TuesdayEndTime = Time.newInstance(23, 59, 0, 00);
            }
            if(objBusinessHour.WednesdayStartTime != NULL && objBusinessHour.WednesdayStartTime == objBusinessHour.WednesdayEndTime)
            {
                objBusinessHour.WednesdayEndTime = Time.newInstance(23, 59, 0, 00);
            }
            if(objBusinessHour.ThursdayStartTime != NULL && objBusinessHour.ThursdayStartTime == objBusinessHour.ThursdayEndTime)
            {
                objBusinessHour.ThursdayEndTime = Time.newInstance(23, 59, 0, 00);
            }
            if(objBusinessHour.FridayStartTime != NULL && objBusinessHour.FridayStartTime == objBusinessHour.FridayEndTime)
            {
                objBusinessHour.FridayEndTime = Time.newInstance(23, 59, 0, 00);
            }
            if(objBusinessHour.SaturdayStartTime != NULL && objBusinessHour.SaturdayStartTime == objBusinessHour.SaturdayEndTime)
            {
                objBusinessHour.SaturdayEndTime = Time.newInstance(23, 59, 0, 00);
            }
            if(objBusinessHour.SundayStartTime != NULL && objBusinessHour.SundayStartTime == objBusinessHour.SundayEndTime)
            {
                objBusinessHour.SundayEndTime = Time.newInstance(23, 59, 0, 00);
            }
        }
        return lstBusinessHours;
    }
    
    public list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> removeOngoingActivityFromAvailability(Id techId, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> execTimeWindow, Integer leadTime, Map<String,SVMXC__SM_Overnight_Stay_Policy__c> technicianOvernightMap){
        list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> response = new list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
        // If technician is currently working, than remove the technician availability

         SMAX_OptiMax_Engine_WS.ExecutionTime_WP executionTime = null;
        if(mapTechniciansOngoingActivity.containsKey(techId))
        {
            SMAX_OptiMax_Engine_WS.ExecutionTime_WP techCurrentExecTime = mapTechniciansOngoingActivity.get(techId);
            techCurrentExecTime.endDateTime = techCurrentExecTime.endDateTime.addminutes(leadTime);
            for(SMAX_OptiMax_Engine_WS.ExecutionTime_WP availTime : execTimeWindow)
            {
                if(techCurrentExecTime.startDateTime <= availTime.startDateTime)
                {
                    if(availTime.endDateTime >= techCurrentExecTime.endDateTime)
                        executionTime = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(techCurrentExecTime.endDateTime, availTime.endDateTime);
                        executionTime.isAvailableForOvernightStay = isOvernightAllowedThisDay(executionTime,technicianOvernightMap,techId);
                        response.add(executionTime);
                }
                else{
                        executionTime = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(availTime.startDateTime, availTime.endDateTime);
                        executionTime.isAvailableForOvernightStay = isOvernightAllowedThisDay(executionTime,technicianOvernightMap,techId);
                        response.add(executionTime);
                }
            }
        }
        else
        {
            for(SMAX_OptiMax_Engine_WS.ExecutionTime_WP availTime : execTimeWindow)
            {
                executionTime =new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(availTime.startDateTime, availTime.endDateTime);
                executionTime.isAvailableForOvernightStay = isOvernightAllowedThisDay(executionTime,technicianOvernightMap,techId);
                response.add(executionTime);
            }
        }
            
        return response;
    }
    
    
    // This method returns the 'Date' for the 'start Day of the week' selected in ONS policy
    public DateTime getStartOfTheWeekDt(DateTime schedulingHorizonStartDateTime, String selectedDay) {
        
        DateTime startOfTheWeekDtm = null;
        for(integer i = 0; i < 7; i++) {
            if(schedulingHorizonStartDateTime.addDays(-i).formatGmt('EEEE') == selectedDay) {
                startOfTheWeekDtm = schedulingHorizonStartDateTime.addDays(-i);
            }
        }
        return startOfTheWeekDtm;   
    }
    
    public class WorkItem{  
        public List<ErrorDetail> errorDetails { get; set; }
        public Id workItemId { get; set; }
        public string workItemName {get; set;}
    }
    
    public class ErrorDetail {
        public string errorType { get; set; }
        public string errorMessage {get; set;}
    }
    
    public String getOMAX002TAG029(){ return system.label.OMAX002_TAG029;}//Dispatch Parameter Error.
    public String getOMAX002TAG030(){ return system.label.OMAX002_TAG030;}//Invalid Service Duration.
    public String getOMAX002TAG031(){ return system.label.OMAX002_TAG031;}//Not a valid address or zipcode.
    public String getOMAX002TAG032(){ return system.label.OMAX002_TAG032;}//Invalid Dispatch Priority.
    public String getOMAX002TAG033(){ return system.label.OMAX002_TAG033;}//QTL Error.
    public String getOMAX002TAG034(){ return system.label.OMAX002_TAG034;}//Workorder disallowed due to No Qualified Technicians computed.
    public String getOMAX002TAG038(){ return system.label.OMAX002_TAG038;}//Error from server side
    
    public String doValidateWorkOrder(SVMXC__Service_Order__c objWorkOrder, Map<String, BusinessHours> mapBusinessHours, String strDefaultBHourId, Boolean isTZvalidation)
    {
        String strBadWorkOrderDetail='';
        List<ErrorDetail> lstErrDetail = new List<ErrorDetail>();
        WorkItem objWorkItem = new WorkItem();
        if(objWorkOrder.SVMXC__Service_Duration__c == NULL || objWorkOrder.SVMXC__Service_Duration__c < 1){
            ErrorDetail err = new ErrorDetail();
            //err.errorType='Dispatch Parameter Error';
            err.errorType=getOMAX002TAG029();
            //err.errorMessage='Invalid Service Duration';
            err.errorMessage=getOMAX002TAG030();
            lstErrDetail.add(err);
        }
        if(objWorkOrder.SVMXC__Latitude__c == NULL && objWorkOrder.SVMXC__Longitude__c == NULL){
        //if(objWorkOrder.SVMXC__Zip__c == NULL && (objWorkOrder.SVMXC__Street__c == NULL || objWorkOrder.SVMXC__City__c == NULL || objWorkOrder.SVMXC__State__c == NULL || objWorkOrder.SVMXC__Country__c == NULL)){
        if(objWorkOrder.SVMXC__Zip__c == null || objWorkOrder.SVMXC__Country__c == null){   
                ErrorDetail err = new ErrorDetail();
                //err.errorType='Dispatch Parameter Error';
                err.errorType=getOMAX002TAG029();
                //err.errorMessage='Not a valid address or zipcode';
                err.errorMessage=getOMAX002TAG031();
                lstErrDetail.add(err);
            }
        }           
        if(objWorkOrder.SVMXC__Dispatch_Priority__c == NULL || objWorkOrder.SVMXC__Dispatch_Priority__c < 1){
            ErrorDetail err = new ErrorDetail();
            //err.errorType='Dispatch Parameter Error';
            err.errorType=getOMAX002TAG029();
            //err.errorMessage='Invalid Dispatch Priority';
            err.errorMessage=getOMAX002TAG032();
            lstErrDetail.add(err);
        }
        if(objWorkOrder.SVMXC__QTL_Status__c == 'No Qualified Technicians (Disallow)'){
            ErrorDetail err = new ErrorDetail();
            //err.errorType='QTL Error';
            err.errorType=getOMAX002TAG033();
            //err.errorMessage='Workorder disallowed due to No Qualified Technicians computed.';
            err.errorMessage=getOMAX002TAG034();
            lstErrDetail.add(err);
        }
        
        String territoryTimeZone = '';
        String woTimeZone = '';
        String orgDefaultBHTimezone = '';
        BusinessHours bhObj = null;
        
        if(objWorkOrder.SVMXC__Preferred_Business_Hours__c != null && mapBusinessHours != null && mapBusinessHours.size() > 0)
        {
            if(!objWorkOrder.SVMXC__Preferred_Business_Hours__r.IsActive){           
                //strInvalidDataMssg += 'business hours of the workorder is not active.'+' WO: '+wo.name+'\n';
                //strInvalidDataMssg += getOMAX002TAG020()+' WO: '+objWorkOrder.name+'\n';
                ErrorDetail err = new ErrorDetail();
                err.errorType=getOMAX002TAG029();
                err.errorMessage=getOMAX002TAG020();
                lstErrDetail.add(err);
            }               
            //code fix for HACH customer. Allow timezones other then territory tz based on the Setting value.
            else if(isTZvalidation){
                bhObj = mapBusinessHours.get(objWorkOrder.SVMXC__Preferred_Business_Hours__c);
                if(bhObj != null){
                    woTimeZone = bhObj.TimeZoneSidKey;
                }                   
                if(objWorkOrder.SVMXC__Primary_Territory__r.SVMXC__Territory_s_Business_Hours__c != null && objWorkOrder.SVMXC__Primary_Territory__r.SVMXC__Territory_s_Business_Hours__r.IsActive){
                    bhObj = mapBusinessHours.get(objWorkOrder.SVMXC__Primary_Territory__r.SVMXC__Territory_s_Business_Hours__c);          
                    If(bhObj != null)
                        territoryTimeZone = bhObj.TimeZoneSidKey;           
                    if(!woTimeZone.equalsIgnoreCase(territoryTimeZone)){
                        //strInvalidDataMssg += 'timezone is not common between the workorder and the territory, please review.'+' WO: '+wo.name+', Terr: '+wo.SVMXC__Primary_Territory__r.id+'\n';
                        //strInvalidDataMssg += getOMAX002TAG021()+' WO: '+objWorkOrder.name+', Terr: '+objWorkOrder.SVMXC__Primary_Territory__r.name+'\n';
                        ErrorDetail err = new ErrorDetail();
                        err.errorType=getOMAX002TAG029();
                        err.errorMessage=getOMAX002TAG021();
                        lstErrDetail.add(err);
                    }         
                }else{
                    bhObj = mapBusinessHours.get(strDefaultBHourId);
                    If(bhObj != null)
                        orgDefaultBHTimezone = bhObj.TimeZoneSidKey;
                    if(!woTimeZone.equalsIgnoreCase(orgDefaultBHTimezone)){
                        //strInvalidDataMssg += 'timezone is not common between the workorder and org default business, please review.'+' WO: '+wo.name+'\n';
                        //strInvalidDataMssg += getOMAX002TAG022()+' WO: '+objWorkOrder.name+'\n';
                        ErrorDetail err = new ErrorDetail();
                        err.errorType=getOMAX002TAG029();
                        err.errorMessage=getOMAX002TAG022();
                        lstErrDetail.add(err);
                    }
                }
            }  
        } 
            
        if(lstErrDetail != null && lstErrDetail.size() >0 ){
            objWorkItem.workItemId=objWorkOrder.Id;
            objWorkItem.workItemName=objWorkOrder.Name;
            objWorkItem.errorDetails=lstErrDetail;
            strBadWorkOrderDetail=JSON.serialize(objWorkItem);
        }
        return strBadWorkOrderDetail;
    }
    
    public Map<String, String> doCreateWOErrorMap(Map<String, String> mapInvalidWOErrors, Id objSvmxJobId, string strLogger){
        
        // From SVMX Job record, get the list of invalid work orders and update the errors. 
        String strSvmxJobMsg1 = '';
        Attachment objgetInvalidWOAttach;
        try
        {
            objgetInvalidWOAttach = [SELECT Body from Attachment where Name = 'Invalid WorkOrders' and ParentId = :objSvmxJobId];
            strSvmxJobMsg1 = objgetInvalidWOAttach.Body.toString();
            //delete objgetAdditionalInfoAttach;
            
            if(strSvmxJobMsg1 != NULL && strSvmxJobMsg1.length() > 0){ 
                List<String> lstInvalidWOs = new List<String>();
                lstInvalidWOs = strSvmxJobMsg1.split(';');
                strLogger += system.now() + 'No of invalid workorders read from SVMX Job attachment...'+lstInvalidWOs.size();   
                for(String errorWo :lstInvalidWOs){
                    WorkItem workItem = (WorkItem)JSON.deserialize(errorWo, SMAX_OptiMax_Engine_Ext.WorkItem.class);
                    //strLogger += system.now() + 'Error details for workorder - '+workItem;
                    if(workItem.errorDetails != null && workItem.errorDetails.size() > 0){
                        String strErrors=''; 
                        for(ErrorDetail errors :workItem.errorDetails){
                            if(strErrors != ''){
                                strErrors += errors.errorType +':'+errors.errorMessage + '\n';
                            }else{
                                strErrors += DateTime.now().format('dd/MM/yyyy hh:mm:ss.mmm') + ' - ' + errors.errorType +':'+errors.errorMessage + '\n';
                            }
                        }
                        String woName = workItem.workItemName;
                        mapInvalidWOErrors.put(woName,strErrors);
                    }
                }
                //delete the attachment after creating WO error map. to avoid processing multiple times during route wise completeJob.
                delete objgetInvalidWOAttach;
            }
        }
        catch(QueryException ex)
        {
            // No attachment available
        }
        return mapInvalidWOErrors;  
    }
    
    public Map<String, String> doCreateWOErrorMap(Map<String, String> mapInvalidWOErrors, string strSvmxJobMsg1, string strLogger){
        
        // From SVMX Job record, get the list of invalid work orders and update the errors. 
        //String strSvmxJobMsg1 = '';
        //Attachment objgetInvalidWOAttach;
        try
        {
            //objgetInvalidWOAttach = [SELECT Body from Attachment where Name = 'Invalid WorkOrders' and ParentId = :objSvmxJobId];
            //strSvmxJobMsg1 = objgetInvalidWOAttach.Body.toString();
            //delete objgetAdditionalInfoAttach;
            
            if(strSvmxJobMsg1 != NULL && strSvmxJobMsg1.length() > 0){ 
                List<String> lstInvalidWOs = new List<String>();
                lstInvalidWOs = strSvmxJobMsg1.split(';');
                strLogger += system.now() + 'No of invalid workorders read from SVMX Job attachment...'+lstInvalidWOs.size();   
                for(String errorWo :lstInvalidWOs){
                    WorkItem workItem = (WorkItem)JSON.deserialize(errorWo, SMAX_OptiMax_Engine_Ext.WorkItem.class);
                    //strLogger += system.now() + 'Error details for workorder - '+workItem;
                    if(workItem.errorDetails != null && workItem.errorDetails.size() > 0){
                        String strErrors=''; 
                        for(ErrorDetail errors :workItem.errorDetails){
                            if(strErrors != ''){
                                strErrors += errors.errorType +':'+errors.errorMessage + '\n';
                            }else{
                                strErrors += DateTime.now().format('dd/MM/yyyy hh:mm:ss.mmm') + ' - ' + errors.errorType +':'+errors.errorMessage + '\n';
                            }
                        }
                        String woName = workItem.workItemName;
                        mapInvalidWOErrors.put(woName,strErrors);
                    }
                }
                //delete the attachment after creating WO error map. to avoid processing multiple times during route wise completeJob.
                //delete objgetInvalidWOAttach;
            }
        }
        catch(QueryException ex)
        {
            // No attachment available
        }
        return mapInvalidWOErrors;  
    }  
    
    //Story OPT-116(check invalid data) for Workorder,Territory,Technician 
    public String getOMAX002TAG020(){ return system.label.OMAX002_TAG020;}//business hours of the workorder is not active.
    public String getOMAX002TAG021(){ return system.label.OMAX002_TAG021;}//timezone is not common between the workorder and the territory, please review.
    public String getOMAX002TAG022(){ return system.label.OMAX002_TAG022;}//timezone is not common between the workorder and org default business, please review.
    public String getOMAX002TAG023(){ return system.label.OMAX002_TAG023;}//territory doesnt have business hours.
    public String getOMAX002TAG024(){ return system.label.OMAX002_TAG024;}//business hours of the territory is not active.
    public String getOMAX002TAG025(){ return system.label.OMAX002_TAG025;}//technician doesnt have working hours.
    public String getOMAX002TAG026(){ return system.label.OMAX002_TAG026;}//timezone is not common between the working hours of the technician and the org default business hours, please review.
    public String getOMAX002TAG027(){ return system.label.OMAX002_TAG027;}//timezone is not common between the working hours of the technician and the territory business hours of the technician, please review.
    public String getOMAX002TAG028(){ return system.label.OMAX002_TAG028;}//there is no valid address available for the technician.
    
    
    // Story OPT-116(check invalid data) for Technician 
    public String checkTechnicianInvalidData(SVMXC__Service_Group_Members__c techObj, Map<String, BusinessHours> mapBusinessHours, String strDefaultBHourId, String strInvalidDataMssg, String strLogger, Boolean isTZvalidation){

        BusinessHours bhObj = null;
        String techWHTimezone = '';
        String territoryTimeZone = '';
        String orgDefaultBHTimezone = '';

        if(techObj.SVMXC__Working_Hours__c != null && mapBusinessHours != null && mapBusinessHours.size() > 0)
        {
            if(!techObj.SVMXC__Working_Hours__r.IsActive){           
                strInvalidDataMssg += 'business hours of the technician is not active.'+' Tech: '+techObj.name+'\n';
            }else if(isTZvalidation){
                bhObj = mapBusinessHours.get(techObj.SVMXC__Working_Hours__c);
                if(bhObj != null)
                    techWHTimezone = bhObj.TimeZoneSidKey;
                if(techObj.SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c != null && techObj.SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.IsActive){
                    bhObj = mapBusinessHours.get(techObj.SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c);          
                    If(bhObj != null)
                        territoryTimeZone = bhObj.TimeZoneSidKey;           
                    if(!techWHTimezone.equalsIgnoreCase(territoryTimeZone)){
                        //strInvalidDataMssg += 'timezone is not common between the working hours of the technician and the territory business hours of the technician, please review.'+' Tech: '+techObj.name+' , Terr: '+bhObj.name+'\n';
                        strInvalidDataMssg += getOMAX002TAG027()+' Tech: '+techObj.name+' , Terr: '+bhObj.name+'\n';
                    }         
                }else{
                    bhObj = mapBusinessHours.get(strDefaultBHourId);
                    If(bhObj != null)
                        orgDefaultBHTimezone = bhObj.TimeZoneSidKey;
                    if(!techWHTimezone.equalsIgnoreCase(orgDefaultBHTimezone)){
                        //strInvalidDataMssg += 'timezone is not common between the working hours of the technician and the org default business hours, please review.'+' Tech: '+techObj.name+'\n';
                        strInvalidDataMssg += getOMAX002TAG026()+' Tech: '+techObj.name+'\n';
                    }
                }
            }               
        }
        if(techObj.SVMXC__Latitude_Home__c == null || techObj.SVMXC__Longitude_Home__c == null){
            if(techObj.SVMXC__Zip__c == null){
                if(techObj.SVMXC__Street__c == null || techObj.SVMXC__City__c == null || techObj.SVMXC__State__c == null || techObj.SVMXC__Country__c == null){
                    //strInvalidDataMssg += 'there is no valid address available for the technician.' + ' Tech: '+techObj.name+'\n';
                    strInvalidDataMssg += getOMAX002TAG028() + ' Tech: '+techObj.name+'\n';
                }
            }
        } 
        return  strInvalidDataMssg;
    }
    
    // Begin : Spr17 - Sadiya - Overnight - Utlity Methods for Overnight 
     // this method returns whether a day of the execution time is allowed for overnight
     public Boolean isOvernightAllowedThisDay(SMAX_OptiMax_Engine_WS.ExecutionTime_WP executionTime,Map<String,SVMXC__SM_Overnight_Stay_Policy__c> technicianOvernightMap,Id techId){
        Boolean isOvernightAllowed = false;
        String tech  = techId;
        String dayOfWeek = getDayOfDateTime(executionTime.startDate);
        SVMXC__SM_Overnight_Stay_Policy__c overnightPolicy = null;
        if(technicianOvernightMap.containsKey(techId) && technicianOvernightMap.get(techId)!=null){
            overnightPolicy = technicianOvernightMap.get(tech);
                if(dayOfWeek == 'Sunday'){
                        isOvernightAllowed = overnightPolicy.SVMXC__SM_Allow_Sunday_ONS__c;
                }
                else if(dayOfWeek == 'Monday'){
                    isOvernightAllowed = overnightPolicy.SVMXC__SM_Allow_Monday_ONS__c;
                }else if(dayOfWeek == 'Tuesday'){
                    isOvernightAllowed = overnightPolicy.SVMXC__SM_Allow_Tuesday_ONS__c;
                }else if(dayOfWeek == 'Wednesday'){
                    isOvernightAllowed = overnightPolicy.SVMXC__SM_Allow_Wednesday_ONS__c;
                }else if(dayOfWeek == 'Thursday'){
                    isOvernightAllowed = overnightPolicy.SVMXC__SM_Allow_Thursday_ONS__c;
                }else if(dayOfWeek == 'Friday'){
                    isOvernightAllowed = overnightPolicy.SVMXC__SM_Allow_Friday_ONS__c;
                }else if(dayOfWeek == 'Saturday'){
                    isOvernightAllowed = overnightPolicy.SVMXC__SM_Allow_Saturday_ONS__c;
                } 
        }
    
     return isOvernightAllowed;
    
    }
    
    //Returns the day of the give date
    public String getDayOfDateTime(DateTime tdate){
            return tdate.formatGmt('EEEE');
    }   
    
    
      //This method returns the working day's start time form the business hours
     public DateTime returnDayBHEndTime(DateTime presentDay,BusinessHours businessHourObj){
        Datetime sameDayBusinessHourEndime=null;
        Date presentDayTZ = Date.valueOf((presentDay).format('yyyy-MM-dd', businessHourObj.TimeZoneSidKey));
        if(isWorkingDay(businessHourObj,presentDayTZ)){
            datetime inputStartdatetime = Datetime.newInstanceGmt(presentDayTZ,Time.newInstance(0, 0, 0, 0));
            //strLoggerString += system.now() + ' SMAX_OptiMax_Engine_Ext::returnDayBHEndTime(): inputStartdatetime '+inputStartdatetime+ '\n';
            Time bhEndTime = getStartEndTime(businessHourObj,inputStartdatetime.formatGmt('EEEE'),'EndTime');
            sameDayBusinessHourEndime = dcUtils.getDateTimeInTimezone(presentDayTZ,bhEndTime,businessHourObj.TimeZoneSidKey);           
        }
        //strLoggerString += system.now() + ' SMAX_OptiMax_Engine_Ext::returnDayBHEndTime(): sameDayBusinessHourEndime '+sameDayBusinessHourEndime+ '\n';
        return sameDayBusinessHourEndime;
        
     }     
    
    
    public Map<String,Set<Date>> getTechnicianConfirmedOvernightEventDates(set<String> setScheduledTechs){
        
        //strLoggerString += system.now() +' SMAX_OptiMax_Engine_Ext - Fetch all confirmed overnight events \n';
        system.debug('SMAX_OptiMax_Engine_Ext::getTechnicianConfirmedOvernightEventDates() Fetch all confirmed overnight events..');
        
        Map<String,Set<Date>> technicianOvernightEventsMap = new Map<String,Set<Date>>();
         Map<String,Event> overnightSFEvents = new Map<String,Event>([Select id,StartDateTime,EndDateTime,WhatId from Event where WhatId IN :setScheduledTechs AND SVMXC__SM_Status__c = 'Confirmed' AND Type = 'Overnight Stay']);
         Map<String,SVMXC__SVMX_Event__c> overnightSVMXEvents = new Map<String,SVMXC__SVMX_Event__c>([Select id,SVMXC__StartDateTime__c,SVMXC__EndDateTime__c,SVMXC__WhatId__c,SVMXC__Technician__c from SVMXC__SVMX_Event__c where SVMXC__Technician__c IN :setScheduledTechs AND SVMXC__SM_Status__c = 'Confirmed' AND SVMXC__Type__c = 'Overnight Stay']);
            
         Set<Date> overnightEventDates;
         for(Event sfEvent : overnightSFEvents.values()){
            if(technicianOvernightEventsMap.containsKey(sfEvent.WhatId)){
                overnightEventDates = technicianOvernightEventsMap.get(sfEvent.WhatId);
            }else{
                overnightEventDates = new Set<Date>();
            }
            overnightEventDates.add(sfEvent.EndDateTime.dateGMT());
            technicianOvernightEventsMap.put(sfEvent.WhatId,overnightEventDates);
         }
         for(SVMXC__SVMX_Event__c svmxevent : overnightSVMXEvents.values()){
            if(technicianOvernightEventsMap.containsKey(svmxevent.SVMXC__Technician__c)){
                overnightEventDates = technicianOvernightEventsMap.get(svmxevent.SVMXC__Technician__c);
            }else{
                overnightEventDates = new Set<Date>();
            }
            overnightEventDates.add(svmxevent.SVMXC__EndDateTime__c.dateGMT());
            technicianOvernightEventsMap.put(svmxevent.SVMXC__Technician__c,overnightEventDates);
         }
        //strLoggerString += system.now() +' SMAX_OptiMax_Engine_Ext - All confirmed overnight events size'+technicianOvernightEventsMap.size()+'Confirmed Overnight Events'+technicianOvernightEventsMap+'\n';
        system.debug('SMAX_OptiMax_Engine_Ext::getTechnicianConfirmedOvernightEventDates():All confirmed overnight events size'+technicianOvernightEventsMap.size()+' Confirmed Overnight Events '+technicianOvernightEventsMap);
        return technicianOvernightEventsMap;
    }
    
    //Removing Expansion of capacity computation
    public capacityResult doCapacityComputation(Integer intNoOfDays, List<SVMXC__Service_Order__c> lstNewWorkOrders, Map<String, BusinessHours> mapBusinessHours, List<SVMXC__Service_Group_Members__c> lstTechnicians, Integer intCapExtendedByDays, Decimal decAvgDriveTime, BusinessHours objDefTerritoryBH, String strDispatchProcessId)
    {
        Integer intLimitHeapSize = Limits.getLimitHeapSize();
        Integer intLimitCpuTime = Limits.getLimitCpuTime();
        capacityResult resultSet = new capacityResult();
        try
        {
            DateTime dtmStartDateTime = dtmSchedulingHorizonStartDateTime;
            resultSet.strWOsToReschedAndEvents = '';
            Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
            
            // Get the unique 3 character key prefix of Work Order object. This is used to check if events are related to Work Orders
            Schema.Describesobjectresult woDefinitions;
            if (allObjs.containsKey('SVMXC__Service_Order__c') == TRUE)
                woDefinitions = allObjs.get('SVMXC__Service_Order__c').getDescribe();
            else
                woDefinitions = allObjs.get('Service_Order__c').getDescribe();
            String woKeyPrefix = woDefinitions.getKeyPrefix();
            //Apurva/Pavitra: Heap size issue
            allObjs.clear();
            woDefinitions = null;
            // Calculate the end date of the initial scheduling horizon. Get end date time from end date.
            Date datStartDate = Date.valueOf(dtmStartDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
            //Date datActualStartDate = datStartDate;
            Date datEndDate = datStartDate.addDays(intNoOfDays - 1);
            DateTime dtmLastDaysEndDateTime = dcUtils.getDateTimeInTimezone(datEndDate, Time.newInstance(23, 59, 59, 0), objDefTerritoryBH.timeZoneSidKey);
            Double dblRequiredCapacity = 0;
            Double dblActualCapacity = 0;
            
            set<String> setAvailTechAsSFUserList = new set<String>();
            set<String> setAvailTechAsSVMXUserList = new set<String>();
            set<String> setAvailTech = new set<String>();
            set<Date> setSchedHorizonDates = new set<Date>();
            set<Date> setCurrentSchedHorizonDates;
            
            Map<String, List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> mapEventNonWO = new Map<String, List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>();
            Map<String, String> mapUsersTechnicians = new Map<String, String>();
            Map<String, String> mapTechTimeZone = new Map<String, String>();
            Map<Id, List<Id>> mapWrkOrdrEvent = new Map<Id, List<Id>>(); 
            set<Id> setExternalWorkOrders = new set<Id>();
            set<Id> setWrkOrdsToReschedule = new set<Id>();
            set<Id> setWrkOrdsToForceFix = new set<Id>();
            Map<String, SMAX_OptiMax_Engine_WS.TechniciansEventsAdditonalDetails_WP> mapTechAdditionalDetails = new Map<String, SMAX_OptiMax_Engine_WS.TechniciansEventsAdditonalDetails_WP>();
            //Map<Id, Map<DateTime, Id>> mapTechIdStrtDtTEventId = new Map<Id, Map<DateTime, Id>>();
            
            Map<Id, Map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> mapTechIdExecTimeEventId = new Map<Id, Map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>();
            Map<Id, Map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> mapTechIdONSExecTimeEventId = new Map<Id, Map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>();
            String strTZSidKey;
            
           
            // BEGIN : Sadiya - Overnight - Confirmed WO Change
            Map<String,SVMXC__Service_Group_Members__c> mapTechnicians = new Map<String, SVMXC__Service_Group_Members__c>();
           
            //  Prepare lists of Technicians associated with Salesforce Users & Technicians with
            //   only Enable Scheduling checked
            //    As it is possible for one Salesforce User to be associated with >1 Technician,
            //    prepare a map associating one Salesforce User with only one Technician
            
            for(SVMXC__Service_Group_Members__c tech : lstTechnicians)
            {
                setAvailTech.add(tech.Id);
                mapTechTimeZone.put(tech.Id, mapBusinessHours.get(tech.SVMXC__Working_Hours__c).timeZoneSidKey);
                mapTechnicians.put(tech.Id,tech);
                if(tech.SVMXC__Salesforce_User__c != NULL)
                {   
                    setAvailTechAsSFUserList.add(tech.SVMXC__Salesforce_User__c);
                    mapUsersTechnicians.put(tech.SVMXC__Salesforce_User__c, tech.Id);
                }
                else
                    setAvailTechAsSVMXUserList.add(tech.Id);

                //if technician don't have working hours than set territory business hour as working hour.
                if(tech.SVMXC__Working_Hours__c == null){
                    tech.SVMXC__Working_Hours__c = tech.SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c;
                }
                strTZSidKey = mapBusinessHours.get(tech.SVMXC__Working_Hours__c).timeZoneSidKey;
            }
            // if(lstTechnicians != null && !lstTechnicians.isEmpty()) {                
            //     strTZSidKey = lstTechnicians.get(0).SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey; 
            // }
            //system.debug('lstTechnicians :: '+lstTechnicians + ' , strTZSidKey :: '+strTZSidKey);
            // Calculate the initial Required Capacity
            for(SVMXC__Service_Order__c wo : lstNewWorkOrders)
            {
                dblRequiredCapacity += (decAvgDriveTime + wo.SVMXC__Service_Duration__c);
            }
            
            Boolean isAdditionalCapacity = FALSE;
            Date datLastCalcEndDate;
            // Repeat the following steps till available capacity >= required capacity & scheduling horizon calendar days after expansion is <= than maximum limit for the same
            //do
            //{
                //strLoggerString += system.now() + ': Capacity Calculation - Start Date: ' + datStartDate + '\n';
                
                setCurrentSchedHorizonDates = new set<Date>();
                for(integer i = 0; i < intNoOfDays; i++)
                {
                    // Prepare a set of all scheduling horizon dates from datStartDate to datEndDate. These dates are in Territory's time zone
                    setSchedHorizonDates.add(datStartDate.addDays(i));
                    setCurrentSchedHorizonDates.add(datStartDate.addDays(i));
                }
                strLoggerString += system.now() + ': Scheduling Horizon Dates: ' + setSchedHorizonDates + '\n';
                strLoggerString += system.now() + ': Current Scheduling Horizon Dates: ' + setCurrentSchedHorizonDates + '\n';
                datLastCalcEndDate = datStartDate.addDays(intNoOfDays - 1);
                //strLoggerString += system.now() + ': Capacity Calculation - Original End Date: ' + datLastCalcEndDate + '\n';
                //strLoggerString += system.now() + ': Capacity Calculation - dtmLastDaysEndDateTime: ' + dtmLastDaysEndDateTime + '\n';
                //  For technician records with Salesforce_User__c != NULL, retrieve records from Event where 
                //    StartDateTime is between firstDaysStartDateTime and lastDaysEndDateTime OR
                //    StartDateTime is before firstDaysStartDateTime, but EndDateTime is after firstDaysStartDateTime
                //
                set<Id> setEventWorkOrderIds = new set<Id>();
                Map<Id, Event> mapSFEvent = new Map<Id, Event>();
                
                //added the below logger for debugging. TO DELETE
                strLoggerString += system.now() + ': setAvailTechAsSFUserList: ' + setAvailTechAsSFUserList + '\n';
                
                //system.debug(': Usage Details: Before fetch SFevent \n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n');
                //strLoggerString += system.now() + ': Usage Details: Before fetch SFevent \n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
                strLoggerString += system.now() + ': Capacity Calculation - Start Time end time to fecth SF events ' + dtmStartDateTime+' - '+dtmLastDaysEndDateTime+ '\n';
                mapSFEvent = getMapSFEventforTech(setAvailTechAsSFUserList, dtmStartDateTime, dtmLastDaysEndDateTime);
                //system.debug(': Usage Details: After fetch SFevent \n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n');
                //strLoggerString += system.now() +': Usage Details: After fetch SFevent \n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';         
                //WSCH_AuditLogger.debug('SMAX_OptiMax_Engine_Ext::doCapacityComputation(): - Salesforce Event list size: ' + mapSFEvent.size());
                strLoggerString += system.now() + ': Capacity Calculation - SF Event list size: ' + mapSFEvent.size() + '\n';
                map<Id, List<Event>> mapWOIdlstSFEvnt = new map<Id, list<Event>>();
                Map<String, List<Date>> mapTechAllDayEvents = new Map<String, List<Date>>();
                Map<String, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>> mapTechMultiDayEvents = new Map<String, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>();
                for(Event e: mapSFEvent.values())
                {
                    String techId = mapUsersTechnicians.get(e.ownerId);
                    // If it is a work order event, add the work order to the list of work orders
                    if(e.WhatId != NULL && String.valueof(e.WhatId).startsWith(woKeyPrefix) == TRUE)
                    {
                        setEventWorkOrderIds.add(e.WhatId);
                        
                        //Multi-resource and Multi-appointment Batch
                        list<Event> listSFEvnt = new list<Event>();
                        if(mapWOIdlstSFEvnt.containsKey(e.WhatId)){
                            list<Event> tmpLstSFEvnt = mapWOIdlstSFEvnt.get(e.WhatId);
                            tmpLstSFEvnt.add(e);
                            mapWOIdlstSFEvnt.put(e.WhatId,tmpLstSFEvnt);
                        }else{
                            listSFEvnt.add(e);
                            mapWOIdlstSFEvnt.put(e.WhatId,listSFEvnt);
                        }
                    }
                    //Convert event start and end dateime into technician TZ.
                    DateTime startDatetimeBH = WSCH_DateUtils.doTZConversion(e.StartDateTime, 'GMT', strTZSidKey);
                    DateTime endDatetimeBH = WSCH_DateUtils.doTZConversion(e.EndDateTime, 'GMT', strTZSidKey);
                    integer intDays =  startDatetimeBH.DateGMT().daysBetween(endDatetimeBH.DateGMT());
                    //integer intDays =  e.StartDateTime.DateGMT().daysBetween(e.EndDateTime.DateGMT());
                    //get all day event and create list of all day event
                    if(e.IsAllDayEvent == true){
                        List<Date> lstAlldays = new List<Date>();
                        //integer intDays =  e.StartDateTime.DateGMT().daysBetween(e.EndDateTime.DateGMT());
                        if(intDays > 0){//multiday all day event
                            if(!mapTechAllDayEvents.containsKey(techId))
                                mapTechAllDayEvents.put(techId,lstAlldays);

                            for(integer i = 0; i <= intDays; i++) {
                                mapTechAllDayEvents.get(techId).add(e.StartDateTime.addDays(i).dateGMT());
                            }
                            
                        }else{//single day all day event
                            if(!mapTechAllDayEvents.containsKey(techId)){
                                mapTechAllDayEvents.put(techId,lstAlldays);
                            }
                            mapTechAllDayEvents.get(techId).add(e.StartDateTime.dateGMT());
                        }
                    }else if(intDays == 1){ //added below code for multiday event but not set isAllDayEvent flag to true.
                        list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstMultiDays = new list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
                        WSCH_Provider_ECO_Stubs.ExecutionTime_WP exeTime = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP();
                        exeTime.workingHoursBegin = e.EndDateTime;
                        exeTime.workingHoursEnd = e.StartDateTime; 
                        if(!mapTechMultiDayEvents.containsKey(techId))
                            mapTechMultiDayEvents.put(techId,lstMultiDays);
    
                        mapTechMultiDayEvents.get(techId).add(exeTime);
    
                    }else if(intDays > 1){
                        for(integer i = 0; i <= intDays; i++) {
                            if(i==0){
                                list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstMultiDays = new list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
                                WSCH_Provider_ECO_Stubs.ExecutionTime_WP exeTime = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP();
                                exeTime.workingHoursBegin = e.EndDateTime;
                                exeTime.workingHoursEnd = e.StartDateTime;
                                if(!mapTechMultiDayEvents.containsKey(techId))
                                    mapTechMultiDayEvents.put(techId,lstMultiDays);
            
                                mapTechMultiDayEvents.get(techId).add(exeTime);
                                continue;
                            }
                            if(i==intDays){
                                continue;
                            }
                            List<Date> lstAlldays = new List<Date>();
                            if(!mapTechAllDayEvents.containsKey(techId)){
                                mapTechAllDayEvents.put(techId,lstAlldays);
                            }
                            mapTechAllDayEvents.get(techId).add(e.StartDateTime.addDays(i).dateGMT());
                        }
                    }
                    
                }
                //strLoggerString += system.now() + 'SF event All day event Maps end of iteration' + mapTechAllDayEvents + '\n';
                
                //  For technician records with Salesforce_User__c = NULL and Enable_Scheduling__c = TRUE, retrieve records from ServiceMax_Event__c where
                //    StartDateTime is between firstDaysStartDateTime and lastDaysEndDateTime OR
                //    StartDateTime is before firstDaysStartDateTime, but EndDateTime is after firstDaysStartDateTime
                
                // Pavitra : Get events from SVMXC__SVMX_Event__c for technician records with Salesforce_User__c != NULL and Enable_Scheduling__c = TRUE too  
                Map<Id, SVMXC__SVMX_Event__c> mapSVMXEvent = new Map<Id, SVMXC__SVMX_Event__c>();
                
                
                //added the below logger for debugging. TO DELETE
                strLoggerString += system.now() + ': setAvailTech: ' + setAvailTech + '\n';
                // Pavitra modified to resolve the missing events issues
                //Getting SVMX events with given time span and for the given Tech 
                //system.debug(': Usage Details: Before fetch SVMXEvent \n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n');
                //strLoggerString += system.now() + ': Usage Details: Before fetch SVMXEvent \n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
                mapSVMXEvent = getMapSVMXEventforTech(setAvailTech, dtmStartDateTime, dtmLastDaysEndDateTime);
                //system.debug(': Usage Details: After fetch SVMXEvent \n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n');
                //strLoggerString += system.now() + ': Usage Details: After fetch SVMXEvent \n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';   
                strLoggerString += system.now() + ': Capacity Calculation - SVMX Event list size: ' + mapSVMXEvent.size() + '\n';
                //strLoggerString += system.now() + ': Capacity Calculation - SVMX Event list size: ' + mapSVMXEvent.keyset() + '\n';
                
                map<Id, List<SVMXC__SVMX_Event__c>> mapWOIdLstSvmxEvnt = new map<Id, list<SVMXC__SVMX_Event__c>>();
                for(SVMXC__SVMX_Event__c e: mapSVMXEvent.values())
                {
                    // If it is a work order event, add the work order to the list of work orders
                    if(e.SVMXC__WhatId__c != NULL && String.valueof(e.SVMXC__WhatId__c).startsWith(woKeyPrefix) == TRUE)
                    {
                        setEventWorkOrderIds.add(e.SVMXC__WhatId__c);
                        
                        //Multi-resource and Multi-appointment Batch
                        list<SVMXC__SVMX_Event__c> listSVMXEvnt = new list<SVMXC__SVMX_Event__c>();
                        if(mapWOIdLstSvmxEvnt.containsKey(e.SVMXC__WhatId__c)){
                            list<SVMXC__SVMX_Event__c> tmpLstSvmxEvnt = mapWOIdLstSvmxEvnt.get(e.SVMXC__WhatId__c);
                            tmpLstSvmxEvnt.add(e);
                            mapWOIdLstSvmxEvnt.put(e.SVMXC__WhatId__c,tmpLstSvmxEvnt);
                        }else{
                            listSVMXEvnt.add(e);
                            mapWOIdLstSvmxEvnt.put(e.SVMXC__WhatId__c,listSVMXEvnt);
                        }
                    }
                    strLoggerString += system.now() + ': Capacity Calculation - mapWOIdLstSvmxEvnt: ' + mapWOIdLstSvmxEvnt.size() + '\n';

                    //Convert event start and end dateime into technician TZ.
                    DateTime startDatetimeBH = WSCH_DateUtils.doTZConversion(e.SVMXC__StartDateTime__c, 'GMT', strTZSidKey);
                    DateTime endDatetimeBH = WSCH_DateUtils.doTZConversion(e.SVMXC__EndDateTime__c, 'GMT', strTZSidKey);
                    //system.debug('startDatetimeBH :: '+startDatetimeBH+' , endDatetimeBH :: '+endDatetimeBH + ' , strTZSidKey :: '+strTZSidKey);
                    integer intDays =  startDatetimeBH.DateGMT().daysBetween(endDatetimeBH.DateGMT());
                    //integer intDays =  e.SVMXC__StartDateTime__c.DateGMT().daysBetween(e.SVMXC__EndDateTime__c.DateGMT());
                    //get all day event and create list of all day event 
                    if(e.SVMXC__IsAllDayEvent__c == true){ 
                        List<Date> lstAlldaysSVMX = new List<Date>();
                        //integer intDays =  e.SVMXC__StartDateTime__c.DateGMT().daysBetween(e.SVMXC__EndDateTime__c.DateGMT());
                        if(intDays > 0){//Multiday all day event
                            if(!mapTechAllDayEvents.containsKey(e.SVMXC__Technician__c))
                                mapTechAllDayEvents.put(e.SVMXC__Technician__c,lstAlldaysSVMX);

                            for(integer i = 0; i <= intDays; i++) {
                                mapTechAllDayEvents.get(e.SVMXC__Technician__c).add(e.SVMXC__StartDateTime__c.addDays(i).dateGMT());
                            }
                            
                        }else{ // single day all day event
                            if(!mapTechAllDayEvents.containsKey(e.SVMXC__Technician__c)){
                                mapTechAllDayEvents.put(e.SVMXC__Technician__c,lstAlldaysSVMX);
                            }
                            mapTechAllDayEvents.get(e.SVMXC__Technician__c).add(e.SVMXC__StartDateTime__c.dateGMT());
                        }
                    }else if(intDays == 1){ //added below code for multiday event but not set isAllDayEvent flag to true.
                        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():Multiday event span 1 day...Start-'+e.SVMXC__StartDateTime__c+' End- '+e.SVMXC__EndDateTime__c);
                        list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstMultiDays = new list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
                        WSCH_Provider_ECO_Stubs.ExecutionTime_WP exeTime = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP();
                        exeTime.workingHoursBegin = e.SVMXC__EndDateTime__c;
                        exeTime.workingHoursEnd = e.SVMXC__StartDateTime__c;
                        if(!mapTechMultiDayEvents.containsKey(e.SVMXC__Technician__c))
                            mapTechMultiDayEvents.put(e.SVMXC__Technician__c,lstMultiDays);
    
                        mapTechMultiDayEvents.get(e.SVMXC__Technician__c).add(exeTime);
                        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():exeTime- ' + exeTime);
                    }else if(intDays > 1){
                        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():Multiday event span > 1 day...Start-'+e.SVMXC__StartDateTime__c+' End- '+e.SVMXC__EndDateTime__c);
                        for(integer i = 0; i <= intDays; i++) {
                            //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():i- ' + i);
                            if(i==0){
                                list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstMultiDays = new list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
                                WSCH_Provider_ECO_Stubs.ExecutionTime_WP exeTime = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP();
                                exeTime.workingHoursBegin = e.SVMXC__EndDateTime__c;
                                exeTime.workingHoursEnd = e.SVMXC__StartDateTime__c;
                                if(!mapTechMultiDayEvents.containsKey(e.SVMXC__Technician__c))
                                    mapTechMultiDayEvents.put(e.SVMXC__Technician__c,lstMultiDays);
            
                                mapTechMultiDayEvents.get(e.SVMXC__Technician__c).add(exeTime);
                                //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():exeTime- ' + exeTime);
                                continue;
                            }
                            if(i==intDays){
                                continue;
                            }
                            List<Date> lstAlldays = new List<Date>();
                            if(!mapTechAllDayEvents.containsKey(e.SVMXC__Technician__c)){
                                mapTechAllDayEvents.put(e.SVMXC__Technician__c,lstAlldays);
                            }
                            mapTechAllDayEvents.get(e.SVMXC__Technician__c).add(e.SVMXC__StartDateTime__c.addDays(i).dateGMT());
                            //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():svmxEvent.SVMXC__StartDateTime__c.addDays(i).dateGMT()- ' + e.SVMXC__StartDateTime__c.addDays(i).dateGMT());
                        }
                    }
                }
                strLoggerString += system.now() + 'All SF and SVMX all day events technician wize size :- '+mapTechAllDayEvents.size()+'\n';                
                // Of the above work orders from events, get Id and Service Duration for externally scheduled work orders & work orders of current dispatch process
                //Pavitra: Linx and Immediate DP events WO won't be picked by below query
                Map<Id, SVMXC__Service_Order__c> mapAllEventWorkOrders = new Map<Id, SVMXC__Service_Order__c>();
                // Modified the query add all WOs, irrespective of Dispatch_Process
                mapAllEventWorkOrders.putAll([Select Id, SVMXC__Service_Duration__c, SVMXC__Dispatch_Process__c, SVMXC__Latitude__c, SVMXC__Longitude__c, SVMXC__Locked_By_DC__c, SVMXC__SM_Lock_Appointment_Schedule__c, SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Zip__c, SVMXC__Country__c
                                                from SVMXC__Service_Order__c
                                                where Id IN: setEventWorkOrderIds]);
                //system.debug(': Usage Details: After fetch Workorders from event \n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n');
                //strLoggerString += system.now() + ': Usage Details: After fetch Workorders from event \n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
        
              //Option 2: Handling external work orders into events based on the locked by dc
                //a. create list of forcefix work orders(all wos other then current DP with locked by dc is true).
                //b. create list of rescheduled work orders(current DP wos and locked by dc is false).
                
                 //strLoggerString += system.now() + 'All SF and SVMX Event Workorders :- '+mapAllEventWorkOrders.keySet()+'\n';
                for(Id woId: mapAllEventWorkOrders.keySet())
                {
                    SVMXC__Service_Order__c objExternalWorkOrders = mapAllEventWorkOrders.get(woId);
                    if((objExternalWorkOrders.SVMXC__Dispatch_Process__c != NULL) && ( objExternalWorkOrders.SVMXC__Dispatch_Process__c == strDispatchProcessId)) // Work order belongs to current dispatch process
                    {
                        if(objExternalWorkOrders.SVMXC__Locked_By_DC__c == true || objExternalWorkOrders.SVMXC__SM_Lock_Appointment_Schedule__c == WSCH_ECO_Constants.SCHEDULE_LOCK_IN_PLACE){
                            setWrkOrdsToForceFix.add(woId);
                        }else{
                            //Multi-resource and Multi-appointment Batch
                            if(mapWOIdLstSvmxEvnt != null && mapWOIdLstSvmxEvnt.get(woId) != null && mapWOIdLstSvmxEvnt.get(woId).size() > 1){
                                setWrkOrdsToForceFix.add(woId);
                            }else if(mapWOIdlstSFEvnt != null && mapWOIdlstSFEvnt.get(woId) != null && mapWOIdlstSFEvnt.get(woId).size() > 1){
                                setWrkOrdsToForceFix.add(woId);
                            }else{  
                                setWrkOrdsToReschedule.add(woId);
                            }
                        }
                    }else{
                        setWrkOrdsToForceFix.add(woId);
                    }
                }
                
                //strLoggerString += system.now() + ': Capacity Calculation - Forcefix Work Orders(all wos other then current DP with locked by dc is true)==> ' + setWrkOrdsToForceFix +'\n';   
                strLoggerString += system.now() + ': Capacity Calculation - Forcefix Work Orders size(): ' + setWrkOrdsToForceFix.size() + '\n';                
                
                //strLoggerString += system.now() + ': Capacity Calculation - Work Orders of current dispatch process to be rescheduled(current DP wos and locked by dc is false)==>: ' + setWrkOrdsToReschedule + '\n';
                strLoggerString += system.now() + ': Capacity Calculation - Rescheduled WOs size() :'+setWrkOrdsToReschedule.size() + '\n';
                
                //system.debug(': Usage Details: Before iterate SFevent and create maps like workorderwise events, technicianwise events, ongoing events, nonWO events.. \n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n');
                //strLoggerString += system.now() + ': Usage Details: Before iterate SFevent and create maps like workorderwise events, technicianwise events, ongoing events, nonWO events.. \n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
                // From Salesforce Events map, build the list of work orders to be rescheduled and events related to them + map of tech's non-Work order events
                for(Event e: mapSFEvent.values())
                {
                    if(e.IsAllDayEvent == true){
                        continue;
                    }
                    DateTime startDatetimeBH = WSCH_DateUtils.doTZConversion(e.StartDateTime, 'GMT', strTZSidKey);
                    DateTime endDatetimeBH = WSCH_DateUtils.doTZConversion(e.EndDateTime, 'GMT', strTZSidKey);
                    //integer intDays =  e.StartDateTime.DateGMT().daysBetween(e.EndDateTime.DateGMT());
                    integer intDays =  startDatetimeBH.DateGMT().daysBetween(endDatetimeBH.DateGMT());
                    if(intDays > 0){
                        continue;
                    }
                    //Updating the event start and End datetime using drive time and return drive time
                    /*Integer driveTime = Integer.valueOf(e.SVMXC__Driving_Time__c);
                    Integer returnDriveTime = Integer.valueOf(e.SVMXC__Driving_Time_Home__c);
                    DateTime updatedStartDT = e.StartDateTime.addMinutes(driveTime);
                    DateTime updatedEndDT = e.EndDatetime.addMinutes(-returnDriveTime);*/
                    //TODO: To add drive time into start datetime with precision.
                    Integer driveTimeSec =Integer.valueOf(e.SVMXC__Driving_Time__c * 60);
                    Integer returnDriveTimeSec =Integer.valueOf(e.SVMXC__Driving_Time_Home__c * 60);
                    DateTime updatedStartDT = e.StartDateTime.addSeconds(driveTimeSec);
                    DateTime updatedEndDT = e.EndDatetime.addSeconds(-returnDriveTimeSec);
                    
                    //strLoggerString += system.now() +'SF Event Drive time:'+driveTime+'\n'+' Return Drive time: '+returnDriveTime+'\n'+'Adjusted Start Datetime: '+updatedStartDT+'\n'+' Adjusted End Datetime: '+updatedEndDT+'\n';
                    DateTime dtmEventEndDateTime = updatedEndDT;
                    Boolean isCurrentEvent = false;
                    //strLoggerString += system.now() + ': Capacity Calculation - SF Event Overnight Status: ' + e.SVMXC__SM_Status__c + '\n';
                    // Find technician current event and add to mapTechniciansOngoingActivity 
                    if(!isFullRun && e.StartDateTime <= dtmSchedulingHorizonStartDateTime && dtmSchedulingHorizonStartDateTime <= dtmEventEndDateTime)
                    {
                        mapTechniciansOngoingActivity.put(mapUsersTechnicians.get(e.OwnerId), new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(e.StartDateTime, dtmEventEndDateTime));
                        if(( e.WhatId != NULL && String.valueof(e.WhatId).startsWith(woKeyPrefix) == TRUE ))
                            lstCurrentWorkOrders.add(e.WhatId);
                        isCurrentEvent = true;
                    }
                    
                    // If it is a work order event to be rescheduled and (it is a Full Run or initial scheduling horizon), add the work order to the list of work orders
                    if(( e.WhatId != NULL && String.valueof(e.WhatId).startsWith(woKeyPrefix) == TRUE ) && ( setWrkOrdsToReschedule.contains(e.WhatId) ) && (isFullRun || !isAdditionalCapacity))
                    {
                        if(isCurrentEvent) continue;
                        List<Id> eventIds = new List<Id>();
                        if(mapWrkOrdrEvent.containsKey(e.WhatId) && mapWrkOrdrEvent.get(e.WhatId).size() > 0)
                            eventIds.addAll(mapWrkOrdrEvent.get(e.WhatId));
                        eventIds.add( e.Id);
                        mapWrkOrdrEvent.put(e.WhatId,eventIds);
                        dblRequiredCapacity += (decAvgDriveTime + mapAllEventWorkOrders.get(e.WhatId).SVMXC__Service_Duration__c); // Use the work order's service duration
                    }
                    
                    // if it is an event for an externally scheduled work order and (it is a Full Run or initial scheduling horizon), add the work order the list of work orders
                    else if(( e.WhatId != NULL && String.valueof(e.WhatId).startsWith(woKeyPrefix) == TRUE ) && ( setExternalWorkOrders.contains(e.WhatId) ) && (isFullRun || !isAdditionalCapacity))
                    {
                        
                        //Lat-Long update for external WO events
                        String technicianId = mapUsersTechnicians.get(e.OwnerId);
                        /*if(!mapTechIdStrtDtTEventId.ContainsKey(technicianId)){
                            mapTechIdStrtDtTEventId.put(technicianId, new Map<DateTime, Id>());
                        }     
                        mapTechIdStrtDtTEventId.get(technicianId).put(e.StartDatetime, e.Id);*/
                        
                        SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpEventTimeWindow = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(e.StartDatetime, e.EndDateTime);
                        if(!mapTechIdExecTimeEventId.ContainsKey(technicianId)){
                            mapTechIdExecTimeEventId.put(technicianId, new Map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>());
                        }     
                        mapTechIdExecTimeEventId.get(technicianId).put(e.Id, wrpEventTimeWindow);
                        
                        if(isCurrentEvent) continue;
                        List<Id> eventIds = new List<Id>();
                        if(mapWrkOrdrEvent.containsKey(e.WhatId) && mapWrkOrdrEvent.get(e.WhatId).size() > 0)
                            eventIds.addAll(mapWrkOrdrEvent.get(e.WhatId));
                        eventIds.add(e.Id);
                        mapWrkOrdrEvent.put(e.WhatId,eventIds);
                        dblRequiredCapacity += (decAvgDriveTime + e.DurationInMinutes); // Use the event's duration
                    }
                    // forcefix work orders
                    else if(( e.WhatId != NULL && String.valueof(e.WhatId).startsWith(woKeyPrefix) == TRUE ) && ( setWrkOrdsToForceFix.contains(e.WhatId) ) && (isFullRun || !isAdditionalCapacity))
                    {
                        String technicianId = mapUsersTechnicians.get(e.OwnerId);  
                        
                        //Lat-Long update for external WO events
                        /*if(!mapTechIdStrtDtTEventId.ContainsKey(technicianId)){
                            mapTechIdStrtDtTEventId.put(technicianId, new Map<DateTime, Id>());
                        } 
                        
                        //remove drivetime from event start datetime
                        mapTechIdStrtDtTEventId.get(technicianId).put(updatedStartDT, e.Id);
                        //mapTechIdStrtDtTEventId.get(technicianId).put(e.StartDatetime, e.Id);*/
                        
                        SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpEventTimeWindow = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(updatedStartDT, dtmEventEndDateTime);
                        if(!mapTechIdExecTimeEventId.ContainsKey(technicianId)){
                            mapTechIdExecTimeEventId.put(technicianId, new Map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>());
                        }     
                        mapTechIdExecTimeEventId.get(technicianId).put(e.Id, wrpEventTimeWindow);
                        
                        list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstEventTimeWindows = new list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
                        //SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpEventTimeWindow = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(e.StartDateTime, dtmEventEndDateTime);
                        //SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpEventTimeWindow = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(updatedStartDT, dtmEventEndDateTime);
                        if(mapEventNonWO.containsKey(technicianId) && mapEventNonWO.get(technicianId).size() > 0) // TRUE from the second event for each technician
                            lstEventTimeWindows = mapEventNonWO.get(technicianId);
                        if(mapTechTimeZone.containsKey(technicianId))
                            lstEventTimeWindows.addAll(wrpEventTimeWindow.doSplitDays(mapTechTimeZone.get(technicianId), setCurrentSchedHorizonDates));
                        mapEventNonWO.put(mapUsersTechnicians.get(e.OwnerId), lstEventTimeWindows);                                        
                        dblRequiredCapacity += (decAvgDriveTime + e.DurationInMinutes); // Use the event's duration
                        
                        //TODO check the location lookup for each event and create mapTechAdditionalDetails 
                        //String strTechStartDtTime = technicianId + '_' + e.StartDateTime;
                        String strTechStartDtTime = technicianId + '_' + updatedStartDT;
                        strLoggerString += system.now() + ': Capacity Calculation - External WO : Technician Event Additional details SMAX event strTechStartDtTime == ' + strTechStartDtTime + '\n';
                        SMAX_OptiMax_Engine_WS.TechniciansEventsAdditonalDetails_WP techAddtnlDetail = new SMAX_OptiMax_Engine_WS.TechniciansEventsAdditonalDetails_WP();
                        //If event have geo location then set it. else take it from work order.
                        if(e.SVMXC__SM_Latitude__c != null && e.SVMXC__SM_Longitude__c != null){
                            techAddtnlDetail.latitude = e.SVMXC__SM_Latitude__c;
                            techAddtnlDetail.longitude = e.SVMXC__SM_Longitude__c;
                            techAddtnlDetail.eventtype = 'CalendarGeoItem';
                            techAddtnlDetail.address = null;
                        }else{
                            String strWrkOrdrAddress = ((mapAllEventWorkOrders.get(e.WhatId).SVMXC__Street__c != NULL && mapAllEventWorkOrders.get(e.WhatId).SVMXC__Street__c.length() > 0) ? mapAllEventWorkOrders.get(e.WhatId).SVMXC__Street__c : '') + ((mapAllEventWorkOrders.get(e.WhatId).SVMXC__City__c != NULL && mapAllEventWorkOrders.get(e.WhatId).SVMXC__City__c.length() > 0) ?  (((mapAllEventWorkOrders.get(e.WhatId).SVMXC__Street__c != NULL && mapAllEventWorkOrders.get(e.WhatId).SVMXC__Street__c.length() > 0)) ? ', ' : '') + mapAllEventWorkOrders.get(e.WhatId).SVMXC__City__c : '') + ((mapAllEventWorkOrders.get(e.WhatId).SVMXC__State__c != NULL && mapAllEventWorkOrders.get(e.WhatId).SVMXC__State__c.length() > 0) ?  (((mapAllEventWorkOrders.get(e.WhatId).SVMXC__City__c != NULL && mapAllEventWorkOrders.get(e.WhatId).SVMXC__City__c.length() > 0) || ((mapAllEventWorkOrders.get(e.WhatId).SVMXC__Street__c != NULL && mapAllEventWorkOrders.get(e.WhatId).SVMXC__Street__c.length() > 0))) ? ', ' : '') + mapAllEventWorkOrders.get(e.WhatId).SVMXC__State__c : '') + ((mapAllEventWorkOrders.get(e.WhatId).SVMXC__Zip__c != NULL && mapAllEventWorkOrders.get(e.WhatId).SVMXC__Zip__c.length() > 0) ?  (((mapAllEventWorkOrders.get(e.WhatId).SVMXC__State__c != NULL && mapAllEventWorkOrders.get(e.WhatId).SVMXC__State__c.length() > 0) || (mapAllEventWorkOrders.get(e.WhatId).SVMXC__City__c != NULL && mapAllEventWorkOrders.get(e.WhatId).SVMXC__City__c.length() > 0) || ((mapAllEventWorkOrders.get(e.WhatId).SVMXC__Street__c != NULL && mapAllEventWorkOrders.get(e.WhatId).SVMXC__Street__c.length() > 0))) ? ', ' : '') + mapAllEventWorkOrders.get(e.WhatId).SVMXC__Zip__c : '') + ((mapAllEventWorkOrders.get(e.WhatId).SVMXC__Country__c != NULL && mapAllEventWorkOrders.get(e.WhatId).SVMXC__Country__c.length() > 0) ?  (((mapAllEventWorkOrders.get(e.WhatId).SVMXC__Zip__c != NULL && mapAllEventWorkOrders.get(e.WhatId).SVMXC__Zip__c.length() > 0) || (mapAllEventWorkOrders.get(e.WhatId).SVMXC__State__c != NULL && mapAllEventWorkOrders.get(e.WhatId).SVMXC__State__c.length() > 0) || (mapAllEventWorkOrders.get(e.WhatId).SVMXC__City__c != NULL && mapAllEventWorkOrders.get(e.WhatId).SVMXC__City__c.length() > 0) || ((mapAllEventWorkOrders.get(e.WhatId).SVMXC__Street__c != NULL && mapAllEventWorkOrders.get(e.WhatId).SVMXC__Street__c.length() > 0))) ? ', ' : '') + mapAllEventWorkOrders.get(e.WhatId).SVMXC__Country__c : '');
                            if(mapAllEventWorkOrders.get(e.WhatId).SVMXC__Latitude__c != null && mapAllEventWorkOrders.get(e.WhatId).SVMXC__Longitude__c != null){
                                techAddtnlDetail.latitude = mapAllEventWorkOrders.get(e.WhatId).SVMXC__Latitude__c;
                                techAddtnlDetail.longitude = mapAllEventWorkOrders.get(e.WhatId).SVMXC__Longitude__c;
                                techAddtnlDetail.eventtype = 'CalendarGeoItem';
                                techAddtnlDetail.address = strWrkOrdrAddress;
                            }else if(!String.isBlank(strWrkOrdrAddress)){
                                techAddtnlDetail.eventtype = 'CalendarGeoItem';
                                techAddtnlDetail.address = strWrkOrdrAddress;
                            }else{
                                techAddtnlDetail.eventtype = 'CalendarItem';
                            }
                        }
                        techAddtnlDetail.isForcedStayNode = false ; 
                        mapTechAdditionalDetails.put(strTechStartDtTime, techAddtnlDetail);       
                        //strLoggerString += system.now() + ': Capacity Calculation - Technician Event Additional details SMAX event mapTechAdditionalDetails == ' + mapTechAdditionalDetails +'\n';              
                    
                    }
                     
                    //Begin : Sadiya - create a technican event for the overnight events
                    else if(e.Type == 'Overnight Stay'){
                        
                        //If Overnight Stay not confirmed, skip to process the event
                        if(e.SVMXC__SM_Status__c == 'Pending')
                            continue;
                
                        //strLoggerString += system.now() + ': Capacity Calculation - SF Event, Technician Hours for Confirmed Overnight Events '+e.id+e.SVMXC__SM_Status__c;
                        String technicianId = mapUsersTechnicians.get(e.OwnerId);
                        //strLoggerString += system.now() + ': Capacity Calculation - SF Confirmed Overnight Event  :technicianId == ' + technicianId + '\n';
                        //DateTime startTimeForOvernight = returnDayBHEndTime(e.StartDateTime,mapBusinessHours.get(mapTechnicians.get(technicianId).SVMXC__Working_Hours__c)).addminutes(-1);
                        DateTime startTimeForOvernight = returnDayBHEndTime(updatedStartDT,mapBusinessHours.get(mapTechnicians.get(technicianId).SVMXC__Working_Hours__c)).addminutes(-1);
                        //strLoggerString += system.now() + ': Capacity Calculation - SF Confirmed Overnight Event  :startTimeForOvernight == ' + startTimeForOvernight + '\n';
  
                        /*if(!mapTechIdStrtDtTEventId.ContainsKey(technicianId)){
                            mapTechIdStrtDtTEventId.put(technicianId, new Map<DateTime, Id>());
                        }       
                        mapTechIdStrtDtTEventId.get(technicianId).put(startTimeForOvernight, e.Id);*/
                        
                        SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpONSEventTimeWindow = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(startTimeForOvernight.addMinutes(-29), startTimeForOvernight.addMinutes(-14));
                        if(!mapTechIdONSExecTimeEventId.ContainsKey(technicianId)){
                            mapTechIdONSExecTimeEventId.put(technicianId, new Map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>());
                        }       
                        mapTechIdONSExecTimeEventId.get(technicianId).put(e.Id, wrpONSEventTimeWindow);
                        
                        //Below code commented because technician working hours should not adjusted based on this ONS event.
                        list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstEventTimeWindows = new list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
                        //SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpEventTimeWindow = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(startTimeForOvernight, e.EndDateTime);
                        //Sometimes ONS event have more drive time, to avoid adjusting technician working hours, keep 15 minutes event window
                        SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpEventTimeWindow = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(startTimeForOvernight, startTimeForOvernight.addMinutes(15));                      
                        
                        if(mapEventNonWO.containsKey(technicianId) && mapEventNonWO.get(technicianId).size() > 0) // TRUE from the second event for each technician
                         {
                            lstEventTimeWindows = mapEventNonWO.get(technicianId);
                         }
                         lstEventTimeWindows.add(wrpEventTimeWindow);
                         mapEventNonWO.put(technicianId, lstEventTimeWindows); 
                                                               
                        //dblRequiredCapacity += (decAvgDriveTime + e.DurationInMinutes); // Use the event's duration
                        
                        //TODO check the location lookup for each event and create mapTechAdditionalDetails 
                       
                        SMAX_OptiMax_Engine_WS.TechniciansEventsAdditonalDetails_WP techAddtnlDetail = new SMAX_OptiMax_Engine_WS.TechniciansEventsAdditonalDetails_WP();
                        techAddtnlDetail.eventtype = 'CalendarGeoItem';
                        techAddtnlDetail.isForcedStayNode = true ;
                         techAddtnlDetail.latitude = e.SVMXC__SM_Latitude__c;
                        techAddtnlDetail.longitude = e.SVMXC__SM_Longitude__c;
                        //mapTechAdditionalDetails.put(technicianId + '_' + startTimeForOvernight, techAddtnlDetail);
                        
                        //commented the above map and introduced the modified map. Added the startTimeForOvernight.addMinutes(-29)
                        //so that the while retrieving the value for this key becomes easier in engine_ws class.
                        mapTechAdditionalDetails.put(technicianId + '_' + startTimeForOvernight.addMinutes(-29), techAddtnlDetail);
                    }
                   //END : Sadiya - create a technican event for the overnight events
                    // Non-Work order events SF
                    else
                    {
                        //Lat-Long update for non WO events
                        String technicianId = mapUsersTechnicians.get(e.OwnerId);
                        //mapStrtDtTEventId.put(e.StartDatetime, e.Id);
                        //mapTechIdStrtDtTEventId.put(technicianId, mapStrtDtTEventId);
                        /*if(!mapTechIdStrtDtTEventId.ContainsKey(technicianId)){
                            mapTechIdStrtDtTEventId.put(technicianId, new Map<DateTime, Id>());
                        }
                        mapTechIdStrtDtTEventId.get(technicianId).put(updatedStartDT, e.Id);*/
                        //mapTechIdStrtDtTEventId.get(technicianId).put(e.StartDatetime, e.Id);
                        
                        SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpEventTimeWindow = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(updatedStartDT, dtmEventEndDateTime);
                        if(!mapTechIdExecTimeEventId.ContainsKey(technicianId)){
                            mapTechIdExecTimeEventId.put(technicianId, new Map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>());
                        }     
                        mapTechIdExecTimeEventId.get(technicianId).put(e.Id, wrpEventTimeWindow);
                        
                        // If latitude and longitude (event Location) are non-null, add an entry to mapTechLatitudeLongitude
                        
                            if(e.SVMXC__SM_Latitude__c != null && e.SVMXC__SM_Longitude__c != null)
                            {
                                Map<datetime, SMAX_OptiMax_Engine_WS.DblLocation_WP> techLatLng = new Map<datetime, SMAX_OptiMax_Engine_WS.DblLocation_WP>();
                                if(mapTechLatitudeLongitude.containsKey(technicianId)) // TRUE from the second event for each technician
                                    techLatLng = mapTechLatitudeLongitude.get(technicianId);
                                try
                                {
                                //techLatLng.put(dtmEventEndDateTime, new SMAX_OptiMax_Engine_WS.DblLocation_WP(latLng[0], latLng[1]));
                                techLatLng.put(dtmEventEndDateTime, new SMAX_OptiMax_Engine_WS.DblLocation_WP(e.SVMXC__SM_Latitude__c, e.SVMXC__SM_Longitude__c));
                                mapTechLatitudeLongitude.put(technicianId, techLatLng);
                                //Cleaned for Event Heap size issue
                                techLatLng.clear();
                                }
                                catch(exception ex)
                                {
                                    //If not valid latitude/longitude. Donot add to technician latitude/longitude map
                                }
                            }
                        
                        // Put the event execution time window in a map of <Technician, List of Event Time Windows>. Split multi-day events into one time window per day
                        list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstEventTimeWindows = new list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
                        //SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpEventTimeWindow = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(e.StartDateTime, dtmEventEndDateTime);
                        //SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpEventTimeWindow = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(updatedStartDT, dtmEventEndDateTime);
                        if(mapEventNonWO.containsKey(technicianId) && mapEventNonWO.get(technicianId).size() > 0) // TRUE from the second event for each technician
                            lstEventTimeWindows = mapEventNonWO.get(technicianId);
                        if(mapTechTimeZone.containsKey(technicianId))
                            lstEventTimeWindows.addAll(wrpEventTimeWindow.doSplitDays(mapTechTimeZone.get(technicianId), setCurrentSchedHorizonDates));
                        mapEventNonWO.put(mapUsersTechnicians.get(e.OwnerId), lstEventTimeWindows);

                        //TODO check the location lookup for each event and create mapTechAdditionalDetails 
                        //String strTechStartDtTime = technicianId + '_' + e.StartDateTime;
                        String strTechStartDtTime = technicianId + '_' + updatedStartDT;
                        strLoggerString += system.now() + ': Capacity Calculation - Non WO: Technician Event Additional details SF event strTechStartDtTime == ' + strTechStartDtTime + '\n';
                        SMAX_OptiMax_Engine_WS.TechniciansEventsAdditonalDetails_WP techAddtnlDetail = new SMAX_OptiMax_Engine_WS.TechniciansEventsAdditonalDetails_WP();
                        if(e.SVMXC__SM_Latitude__c != null && e.SVMXC__SM_Longitude__c != null){
                            techAddtnlDetail.latitude = e.SVMXC__SM_Latitude__c;
                            techAddtnlDetail.longitude = e.SVMXC__SM_Longitude__c;
                            techAddtnlDetail.eventtype = 'CalendarGeoItem';
                        }
                        if(e.Location != null){
                            techAddtnlDetail.address = e.Location;
                            techAddtnlDetail.eventtype = 'CalendarGeoItem'; 
                        }
                        if(e.SVMXC__SM_Latitude__c == null && e.SVMXC__SM_Longitude__c == null && e.Location == null){
                            techAddtnlDetail.eventtype = 'CalendarItem';
                        }
                        techAddtnlDetail.isForcedStayNode = false ;
                        mapTechAdditionalDetails.put(strTechStartDtTime, techAddtnlDetail);       
                        //strLoggerString += system.now() + ': Capacity Calculation - Technician Event Additional details SMAX event mapTechAdditionalDetails == ' + mapTechAdditionalDetails +'\n';              
                    }
                   
                }
                //system.debug(': Usage Details:  iterate SFevent and create maps like workorderwise events, technicianwise events, ongoing events, nonWO events.. \n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n');
                //strLoggerString += system.now() + ': Usage Details:  iterate SFevent and create maps like workorderwise events, technicianwise events, ongoing events, nonWO events.. \n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
                //Apurva/Pavitra: Heap size issue
                mapSFEvent.clear();
                //mapUsersTechnicians.clear();
                //WSCH_AuditLogger.debug('SMAX_OptiMax_Engine_Ext::doCapacityComputation():WorkOrder Events - Same DP : -->'+mapEventNonWO);
                //WSCH_AuditLogger.debug('SMAX_OptiMax_Engine_Ext::doCapacityComputation():External WorkOrder Events : -->'+setExternalWorkOrders);
                system.debug('SMAX_OptiMax_Engine_Ext::doCapacityComputation(): Non WorkOrders : -'+mapEventNonWO);   
                strLoggerString += system.now() + 'SMAX_OptiMax_Engine_Ext::doCapacityComputation(): Non WorkOrders mapEventNonWO : -'+mapEventNonWO+'\n';             
                //strLoggerString += system.now() + ': Usage Details: Before SVMXEvent iteration  .. \n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
                // From ServiceMax Events map, build the list of work orders to be rescheduled and events related to them + map of tech's non-Work order events
                for(SVMXC__SVMX_Event__c e: mapSVMXEvent.values())
                {
                    
                    if(e.SVMXC__IsAllDayEvent__c == true){ 
                        continue;
                    }  
                    DateTime startDatetimeBH = WSCH_DateUtils.doTZConversion(e.SVMXC__StartDateTime__c, 'GMT', strTZSidKey);
                    DateTime endDatetimeBH = WSCH_DateUtils.doTZConversion(e.SVMXC__EndDateTime__c, 'GMT', strTZSidKey);
                    //system.debug('startDatetimeBH :: '+startDatetimeBH+' , endDatetimeBH :: '+endDatetimeBH + ' , strTZSidKey :: '+strTZSidKey);
                    //integer intDays =  e.SVMXC__StartDateTime__c.DateGMT().daysBetween(e.SVMXC__EndDateTime__c.DateGMT());
                    integer intDays =  startDatetimeBH.DateGMT().daysBetween(endDatetimeBH.DateGMT());
                    if(intDays > 0){
                        continue;
                    }
                    
                    //Updating the event start and End datetime using drive time and return drive time
                    /*Integer driveTime = Integer.valueOf(e.SVMXC__Driving_Time__c);
                    Integer returnDriveTime = Integer.valueOf(e.SVMXC__Driving_Time_Home__c);
                    DateTime updatedStartDT = e.SVMXC__StartDateTime__c.addMinutes(driveTime);
                    DateTime updatedEndDT = e.SVMXC__EndDateTime__c.addMinutes(-returnDriveTime);*/
                    //TODO: To add drive time into start datetime with precision.
                    Integer driveTimeSec =Integer.valueOf(e.SVMXC__Driving_Time__c * 60);
                    Integer returnDriveTimeSec =Integer.valueOf(e.SVMXC__Driving_Time_Home__c * 60);
                    DateTime updatedStartDT = e.SVMXC__StartDateTime__c.addSeconds(driveTimeSec);
                    DateTime updatedEndDT = e.SVMXC__EndDateTime__c.addSeconds(-returnDriveTimeSec);
                    
                    //strLoggerString += system.now() +'SVMX Event Drive time:'+driveTime+'\n'+' Return Drive time: '+returnDriveTime+'\n'+'Adjusted Start Datetime: '+updatedStartDT+'\n'+' Adjusted End Datetime: '+updatedEndDT+'\n';
                    
                    //DateTime dtmEventEndDateTime = (e.SVMXC__StartDateTime__c).addMinutes((e.SVMXC__DurationInMinutes__c).intValue());
                    DateTime dtmEventEndDateTime = updatedEndDT;
                    Boolean isCurrentEvent = false;
                    
                    //strLoggerString += system.now() + ': Capacity Calculation - Event Info: ' + e.SVMXC__StartDateTime__c + ':' + e.SVMXC__DurationInMinutes__c + ':' + dtmSchedulingHorizonStartDateTime + '\n';
                    //strLoggerString += system.now() + ': Capacity Calculation - Event Info: ' + 'e.SVMXC__StartDateTime__c :' + e.SVMXC__StartDateTime__c + ' :e.SVMXC__EndDateTime__c:' + e.SVMXC__EndDateTime__c + '\n';
                    //strLoggerString += system.now() + ': Capacity Calculation - Event Info: ' + ' dtmSchedulingHorizonStartDateTime: ' + dtmSchedulingHorizonStartDateTime + ':dtmEventEndDateTime: ' + dtmEventEndDateTime + '\n';
                
                    // Find technician current event and add to mapTechniciansOngoingActivity 
                    if(!isFullRun && e.SVMXC__StartDateTime__c <= dtmSchedulingHorizonStartDateTime && dtmSchedulingHorizonStartDateTime <= dtmEventEndDateTime)
                    {
                        //strLoggerString += system.now() + ': Capacity Calculation - SVMX - Not Full Run \n';
                        mapTechniciansOngoingActivity.put(e.SVMXC__Technician__c, new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(e.SVMXC__StartDateTime__c, dtmEventEndDateTime));
                        if(( e.SVMXC__WhatId__c != NULL && String.valueof(e.SVMXC__WhatId__c).startsWith(woKeyPrefix) == TRUE ))
                            lstCurrentWorkOrders.add(e.SVMXC__WhatId__c);
                        isCurrentEvent = true;
                    }
                    
                    // If it is a work order event to be rescheduled and (it is a Full Run or initial scheduling horizon), add the work order to the list of work orders
                    if(( e.SVMXC__WhatId__c != NULL ) && ( String.valueof(e.SVMXC__WhatId__c).startsWith(woKeyPrefix) == TRUE ) && ( setWrkOrdsToReschedule.contains(e.SVMXC__WhatId__c) ) && (isFullRun || !isAdditionalCapacity))
                    {
                        //strLoggerString += system.now() + ': Capacity Calculation - SVMX event rescheduled : ' + e.SVMXC__WhatId__c + '\n'; 
                        //strLoggerString += system.now() + ': Capacity Calculation - SVMX - WO reschedule section \n';
                        if(isCurrentEvent) continue;
                        List<Id> eventIds = new List<Id>();
                        if(mapWrkOrdrEvent.containsKey(e.SVMXC__WhatId__c) && mapWrkOrdrEvent.get(e.SVMXC__WhatId__c).size() > 0)
                            eventIds.addAll(mapWrkOrdrEvent.get(e.SVMXC__WhatId__c));
                        eventIds.add( e.Id);
                        mapWrkOrdrEvent.put(e.SVMXC__WhatId__c,eventIds);
                        dblRequiredCapacity += (decAvgDriveTime + mapAllEventWorkOrders.get(e.SVMXC__WhatId__c).SVMXC__Service_Duration__c);
                    }
                    
                    // if it is an event for an externally scheduled work order and (it is a Full Run or initial scheduling horizon), add the work order the list of work orders
                    else if(( e.SVMXC__WhatId__c != NULL ) && ( String.valueof(e.SVMXC__WhatId__c).startsWith(woKeyPrefix) == TRUE ) && ( setExternalWorkOrders.contains(e.SVMXC__WhatId__c) ) && (isFullRun || !isAdditionalCapacity))
                    {
                        //strLoggerString += system.now() + ': Capacity Calculation - SVMX event externally scheduled work order : ' + e.SVMXC__WhatId__c + '\n'; 
                        //Lat-Long update for external WO events
                        String technicianId = e.SVMXC__Technician__c;
                        /*if(!mapTechIdStrtDtTEventId.ContainsKey(technicianId)){
                            mapTechIdStrtDtTEventId.put(technicianId, new Map<DateTime, Id>());
                        }       
                        mapTechIdStrtDtTEventId.get(technicianId).put(e.SVMXC__StartDateTime__c, e.Id);*/
                        
                        SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpEventTimeWindow = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(e.SVMXC__StartDateTime__c, e.SVMXC__EndDateTime__c);
                        if(!mapTechIdExecTimeEventId.ContainsKey(technicianId)){
                            mapTechIdExecTimeEventId.put(technicianId, new Map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>());
                        }     
                        mapTechIdExecTimeEventId.get(technicianId).put(e.Id, wrpEventTimeWindow);
                        
                        if(isCurrentEvent) continue;
                        List<Id> eventIds = new List<Id>();
                        if(mapWrkOrdrEvent.containsKey(e.SVMXC__WhatId__c) && mapWrkOrdrEvent.get(e.SVMXC__WhatId__c).size() > 0)
                            eventIds.addAll(mapWrkOrdrEvent.get(e.SVMXC__WhatId__c));
                        eventIds.add( e.Id);
                        mapWrkOrdrEvent.put(e.SVMXC__WhatId__c,eventIds);
                        dblRequiredCapacity += (decAvgDriveTime + e.SVMXC__DurationInMinutes__c);
                    }
                    
                    // forcefix work orders
                    else if(( e.SVMXC__WhatId__c != NULL ) && ( String.valueof(e.SVMXC__WhatId__c).startsWith(woKeyPrefix) == TRUE ) && ( setWrkOrdsToForceFix.contains(e.SVMXC__WhatId__c) ) && (isFullRun || !isAdditionalCapacity))
                    {
                        //strLoggerString += system.now() + ': Capacity Calculation - SVMX - Force Fix WO Section \n';
                        //strLoggerString += system.now() + ': Capacity Calculation - SVMX event forcefix work orders : ' + e.SVMXC__WhatId__c + '\n'; 
                       
                        String technicianId = e.SVMXC__Technician__c;
                        //Lat-Long update for external WO events
                        /*if(!mapTechIdStrtDtTEventId.ContainsKey(technicianId)){
                            mapTechIdStrtDtTEventId.put(technicianId, new Map<DateTime, Id>());
                        }       
                        //mapTechIdStrtDtTEventId.get(technicianId).put(e.SVMXC__StartDateTime__c, e.Id);
                        mapTechIdStrtDtTEventId.get(technicianId).put(updatedStartDT, e.Id);*/
                        
                        SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpEventTimeWindow = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(updatedStartDT, dtmEventEndDateTime);
                        if(!mapTechIdExecTimeEventId.ContainsKey(technicianId)){
                            mapTechIdExecTimeEventId.put(technicianId, new Map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>());
                        }     
                        mapTechIdExecTimeEventId.get(technicianId).put(e.Id, wrpEventTimeWindow);
                        
                        
                        // Put the event execution time window in a map of <Technician, List of Event Time Windows>. Split multi-day events into one time window per day
                        list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstEventTimeWindows = new list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
                        
                        //SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpEventTimeWindow = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(e.SVMXC__StartDateTime__c, dtmEventEndDateTime);
                        //SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpEventTimeWindow = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(updatedStartDT, dtmEventEndDateTime);
                        
                        if(mapEventNonWO.containsKey(e.SVMXC__Technician__c) && mapEventNonWO.get(e.SVMXC__Technician__c).size() > 0) // TRUE from the second event for each technician
                            lstEventTimeWindows = mapEventNonWO.get(e.SVMXC__Technician__c);
                        if(mapTechTimeZone.containsKey(e.SVMXC__Technician__c))
                            lstEventTimeWindows.addAll(wrpEventTimeWindow.doSplitDays(mapTechTimeZone.get(e.SVMXC__Technician__c), setCurrentSchedHorizonDates));
                        
                        mapEventNonWO.put(e.SVMXC__Technician__c, lstEventTimeWindows);
                        
                        dblRequiredCapacity += (decAvgDriveTime + e.SVMXC__DurationInMinutes__c); // Use the event's duration
                        
                        //TODO check the location lookup for each event and create mapTechAdditonalDetails
                        //String strTechStartDtTime = e.SVMXC__Technician__c + '_' + e.SVMXC__StartDateTime__c;
                        String strTechStartDtTime = e.SVMXC__Technician__c + '_' + updatedStartDT;
                        //strLoggerString += system.now() + ': Capacity Calculation - External WO : Technician Event Additional details SVMX event strTechStartDtTime == ' + strTechStartDtTime + '\n';
                       
                        SMAX_OptiMax_Engine_WS.TechniciansEventsAdditonalDetails_WP techAddtnlDetail = new SMAX_OptiMax_Engine_WS.TechniciansEventsAdditonalDetails_WP();
                        //If event have geo location then set it. else take it from work order.
                        if(e.SVMXC__SM_Latitude__c != null && e.SVMXC__SM_Longitude__c != null){
                            techAddtnlDetail.latitude = e.SVMXC__SM_Latitude__c;
                            techAddtnlDetail.longitude = e.SVMXC__SM_Longitude__c;
                            techAddtnlDetail.eventtype = 'CalendarGeoItem';
                            techAddtnlDetail.address = null;
                        }else{
                            String strWrkOrdrAddress = ((e.SVMXC__Service_Order__r.SVMXC__Street__c != NULL && e.SVMXC__Service_Order__r.SVMXC__Street__c.length() > 0) ? e.SVMXC__Service_Order__r.SVMXC__Street__c : '') + ((e.SVMXC__Service_Order__r.SVMXC__City__c != NULL && e.SVMXC__Service_Order__r.SVMXC__City__c.length() > 0) ?  (((e.SVMXC__Service_Order__r.SVMXC__Street__c != NULL && e.SVMXC__Service_Order__r.SVMXC__Street__c.length() > 0)) ? ', ' : '') + e.SVMXC__Service_Order__r.SVMXC__City__c : '') + ((e.SVMXC__Service_Order__r.SVMXC__State__c != NULL && e.SVMXC__Service_Order__r.SVMXC__State__c.length() > 0) ?  (((e.SVMXC__Service_Order__r.SVMXC__City__c != NULL && e.SVMXC__Service_Order__r.SVMXC__City__c.length() > 0) || ((e.SVMXC__Service_Order__r.SVMXC__Street__c != NULL && e.SVMXC__Service_Order__r.SVMXC__Street__c.length() > 0))) ? ', ' : '') + e.SVMXC__Service_Order__r.SVMXC__State__c : '') + ((e.SVMXC__Service_Order__r.SVMXC__Zip__c != NULL && e.SVMXC__Service_Order__r.SVMXC__Zip__c.length() > 0) ?  (((e.SVMXC__Service_Order__r.SVMXC__State__c != NULL && e.SVMXC__Service_Order__r.SVMXC__State__c.length() > 0) || (e.SVMXC__Service_Order__r.SVMXC__City__c != NULL && e.SVMXC__Service_Order__r.SVMXC__City__c.length() > 0) || ((e.SVMXC__Service_Order__r.SVMXC__Street__c != NULL && e.SVMXC__Service_Order__r.SVMXC__Street__c.length() > 0))) ? ', ' : '') + e.SVMXC__Service_Order__r.SVMXC__Zip__c : '') + ((e.SVMXC__Service_Order__r.SVMXC__Country__c != NULL && e.SVMXC__Service_Order__r.SVMXC__Country__c.length() > 0) ?  (((e.SVMXC__Service_Order__r.SVMXC__Zip__c != NULL && e.SVMXC__Service_Order__r.SVMXC__Zip__c.length() > 0) || (e.SVMXC__Service_Order__r.SVMXC__State__c != NULL && e.SVMXC__Service_Order__r.SVMXC__State__c.length() > 0) || (e.SVMXC__Service_Order__r.SVMXC__City__c != NULL && e.SVMXC__Service_Order__r.SVMXC__City__c.length() > 0) || ((e.SVMXC__Service_Order__r.SVMXC__Street__c != NULL && e.SVMXC__Service_Order__r.SVMXC__Street__c.length() > 0))) ? ', ' : '') + e.SVMXC__Service_Order__r.SVMXC__Country__c : '');
                            if(e.SVMXC__Service_Order__c != null && e.SVMXC__Service_Order__r.SVMXC__Latitude__c != null && e.SVMXC__Service_Order__r.SVMXC__Longitude__c != null ){
                                techAddtnlDetail.latitude = e.SVMXC__Service_Order__r.SVMXC__Latitude__c;
                                techAddtnlDetail.longitude = e.SVMXC__Service_Order__r.SVMXC__Longitude__c;
                                techAddtnlDetail.eventtype = 'CalendarGeoItem';
                                techAddtnlDetail.address = strWrkOrdrAddress;
                            }else if(!String.isBlank(strWrkOrdrAddress)){
                                techAddtnlDetail.eventtype = 'CalendarGeoItem';
                                techAddtnlDetail.address = strWrkOrdrAddress;                           
                            }else {
                                techAddtnlDetail.eventtype = 'CalendarItem';
                            }
                        }
                        techAddtnlDetail.isForcedStayNode = false; 
                        mapTechAdditionalDetails.put(strTechStartDtTime, techAddtnlDetail);
                        //strLoggerString += system.now() + ': Capacity Calculation - Technician Event Additional details SVMX event mapTechAdditionalDetails == ' + mapTechAdditionalDetails + '\n';
                    }                 
                    //Begin : Sadiya - create a technican event for the overnight events
                    else if(e.SVMXC__Type__c == 'Overnight Stay'){
                        
                        //If Overnight Stay not confirmed, skip to process the event
                        if(e.SVMXC__SM_Status__c == 'Pending')
                            continue;

                        //strLoggerString += system.now() + ': Capacity Calculation - SVMX Event, Confirmed Overnight Events section: eventId -'+e.id+'; Status - '+e.SVMXC__SM_Status__c+'\n';
                        //DateTime startTimeForOvernight = returnDayBHEndTime(e.SVMXC__StartDateTime__c,mapBusinessHours.get(mapTechnicians.get(e.SVMXC__Technician__c).SVMXC__Working_Hours__c)).addminutes(-1);
                        DateTime startTimeForOvernight = returnDayBHEndTime(updatedStartDT,mapBusinessHours.get(mapTechnicians.get(e.SVMXC__Technician__c).SVMXC__Working_Hours__c)).addminutes(-1);
                        
                        //strLoggerString += system.now() + ': Capacity Calculation - Confirmed Overnight Event  :startTimeForOvernight == ' + startTimeForOvernight + '\n';

                        /*if(!mapTechIdStrtDtTEventId.ContainsKey(e.SVMXC__Technician__c)){
                            mapTechIdStrtDtTEventId.put(e.SVMXC__Technician__c, new Map<DateTime, Id>());
                        }       
                        mapTechIdStrtDtTEventId.get(e.SVMXC__Technician__c).put(startTimeForOvernight, e.Id);*/
                        
                        SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpONSEventTimeWindow = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(startTimeForOvernight.addMinutes(-29), startTimeForOvernight.addMinutes(-14));
                        if(!mapTechIdONSExecTimeEventId.ContainsKey(e.SVMXC__Technician__c)){
                            mapTechIdONSExecTimeEventId.put(e.SVMXC__Technician__c, new Map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>());
                        }       
                        mapTechIdONSExecTimeEventId.get(e.SVMXC__Technician__c).put(e.Id, wrpONSEventTimeWindow);
                                               
                        // Put the event execution time window in a map of <Technician, List of Event Time Windows>. Split multi-day events into one time window per day
                        // below code commented because this overnight time window is removed from the technician working hours which is incorrect.
                        //ex. ONS event created for the whole day like only travel and stay scenarios. This is going to remove the working hours of the tech for the day.
                        list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstEventTimeWindows = new list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
                        //SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpEventTimeWindow = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(startTimeForOvernight, e.SVMXC__EndDateTime__c);
                        //Sometimes ONS event have more drive time, to avoid adjusting technician working hours, keep 15 minutes event window
                        SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpEventTimeWindow = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(startTimeForOvernight, startTimeForOvernight.addMinutes(15));
                        //strLoggerString += system.now() + ': Capacity Calculation - Confirmed Overnight Event  :wrpEventTimeWindow == ' + wrpEventTimeWindow + '\n';
                        //strLoggerString += system.now() + ': Capacity Calculation - Confirmed Overnight Event Before :mapEventNonWO == ' + mapEventNonWO + '\n';
                        
                        if(mapEventNonWO.containsKey(e.SVMXC__Technician__c) && mapEventNonWO.get(e.SVMXC__Technician__c).size() > 0) // TRUE from the second event for each technician
                            lstEventTimeWindows = mapEventNonWO.get(e.SVMXC__Technician__c);

                        lstEventTimeWindows.add(wrpEventTimeWindow);
                        mapEventNonWO.put(e.SVMXC__Technician__c, lstEventTimeWindows);
                        
                        //dblRequiredCapacity += (decAvgDriveTime + e.SVMXC__DurationInMinutes__c); // Use the event's duration
                        SMAX_OptiMax_Engine_WS.TechniciansEventsAdditonalDetails_WP techAddtnlDetail = new SMAX_OptiMax_Engine_WS.TechniciansEventsAdditonalDetails_WP();
                        techAddtnlDetail.eventtype = 'CalendarGeoItem';
                        techAddtnlDetail.isForcedStayNode = true ;
                        techAddtnlDetail.latitude = e.SVMXC__SM_Latitude__c;
                        techAddtnlDetail.longitude = e.SVMXC__SM_Longitude__c;
                        //mapTechAdditionalDetails.put(e.SVMXC__Technician__c + '_' + startTimeForOvernight, techAddtnlDetail);
                        
                        //commented the above map and introduced the modified map. Added the startTimeForOvernight.addMinutes(-29)
                        //so that the while retrieving the value for this key becomes easier in engine_ws class.
                        mapTechAdditionalDetails.put(e.SVMXC__Technician__c + '_' + startTimeForOvernight.addMinutes(-29), techAddtnlDetail);
                    }
                   //END : Sadiya - create a technican event for the overnight events
                      
                    // Non-Work order events SVMX
                    else
                    {
                        strLoggerString += system.now() + ': Capacity Calculation - Non WO : updatedStartDT:' + updatedStartDT +':dtmEventEndDateTime:' + dtmEventEndDateTime + '\n';
                        strLoggerString += system.now() + ': Capacity Calculation - Non WO : mapEventNonWO.containsKey(e.SVMXC__Technician__c): '+ mapEventNonWO.containsKey(e.SVMXC__Technician__c) + '\n';
                        strLoggerString += system.now() + ': Capacity Calculation - Non WO : mapTechTimeZone.containsKey(e.SVMXC__Technician__c): '+ mapTechTimeZone.containsKey(e.SVMXC__Technician__c) + '\n';
                        
                        if(e.SVMXC__IsAllDayEvent__c){
                            strLoggerString += system.now() + ': Capacity Calculation - All Day Event:' + e + '\n';
                        }
                        //Lat-Long update for non WO events
                        String technicianId = e.SVMXC__Technician__c;
                        //mapStrtDtTEventId.put(e.SVMXC__StartDateTime__c, e.Id);
                        //mapTechIdStrtDtTEventId.put(technicianId, mapStrtDtTEventId); 
                        /*if(!mapTechIdStrtDtTEventId.ContainsKey(technicianId)){
                            mapTechIdStrtDtTEventId.put(technicianId, new Map<DateTime, Id>());
                        }       
                        //mapTechIdStrtDtTEventId.get(technicianId).put(e.SVMXC__StartDateTime__c, e.Id);
                        mapTechIdStrtDtTEventId.get(technicianId).put(updatedStartDT, e.Id);*/
                        
                        SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpEventTimeWindow = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(updatedStartDT, dtmEventEndDateTime);
                        if(!mapTechIdExecTimeEventId.ContainsKey(technicianId)){
                            mapTechIdExecTimeEventId.put(technicianId, new Map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>());
                        }     
                        mapTechIdExecTimeEventId.get(technicianId).put(e.Id, wrpEventTimeWindow);
                        
                        // If latitude and longitude (event Location) are non-null, add an entry to mapTechLatitudeLongitude
                            if(e.SVMXC__SM_Latitude__c != null && e.SVMXC__SM_Longitude__c != null)
                            {
                                Map<datetime, SMAX_OptiMax_Engine_WS.DblLocation_WP> techLatLng = new Map<datetime, SMAX_OptiMax_Engine_WS.DblLocation_WP>();
                                if(mapTechLatitudeLongitude.containsKey(technicianId) && mapTechLatitudeLongitude.get(technicianId).size() > 0) // TRUE from the second event for each technician
                                    techLatLng = mapTechLatitudeLongitude.get(technicianId);
                                try
                                {
                                //techLatLng.put(dtmEventEndDateTime, new SMAX_OptiMax_Engine_WS.DblLocation_WP(latLng[0], latLng[1]));
                                techLatLng.put(dtmEventEndDateTime, new SMAX_OptiMax_Engine_WS.DblLocation_WP(e.SVMXC__SM_Latitude__c, e.SVMXC__SM_Longitude__c));
                                mapTechLatitudeLongitude.put(technicianId, techLatLng);
                                //Cleaned for Event Heap size issue
                                techLatLng.clear();
                                }
                                catch(exception ex)
                                {
                                    //If not valid latitude/longitude. Donot add to technician latitude/longitude map
                                }
                            }
                        
                        // Put the event execution time window in a map of <Technician, List of Event Time Windows>. Split multi-day events into one time window per day
                        list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstEventTimeWindows = new list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
                        //SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpEventTimeWindow = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(updatedStartDT, dtmEventEndDateTime);
                        //SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpEventTimeWindow = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(e.SVMXC__StartDateTime__c, dtmEventEndDateTime);
                        if(mapEventNonWO.containsKey(e.SVMXC__Technician__c) && mapEventNonWO.get(e.SVMXC__Technician__c).size() > 0) // TRUE from the second event for each technician
                            lstEventTimeWindows = mapEventNonWO.get(e.SVMXC__Technician__c);
                        if(mapTechTimeZone.containsKey(e.SVMXC__Technician__c)) {
                            lstEventTimeWindows.addAll(wrpEventTimeWindow.doSplitDays(mapTechTimeZone.get(e.SVMXC__Technician__c), setCurrentSchedHorizonDates));
                            strLoggerString += system.now() + ': Capacity Calculation - Non WO : wrapper data' + wrpEventTimeWindow.doSplitDays(mapTechTimeZone.get(e.SVMXC__Technician__c), setCurrentSchedHorizonDates) + '\n';
                        }
                        mapEventNonWO.put(e.SVMXC__Technician__c, lstEventTimeWindows);
                        
                        //TODO check the location lookup for each event and create mapTechAdditionalDetails
                        //String strTechStartDtTime = e.SVMXC__Technician__c + '_' + e.SVMXC__StartDateTime__c;
                        String strTechStartDtTime = e.SVMXC__Technician__c + '_' + updatedStartDT;
                        
                        strLoggerString += system.now() + ': Capacity Calculation - Non WO : Technician Event Additional details SVMX event strTechStartDtTime == ' + strTechStartDtTime + '\n';
                        SMAX_OptiMax_Engine_WS.TechniciansEventsAdditonalDetails_WP techAddtnlDetail = new SMAX_OptiMax_Engine_WS.TechniciansEventsAdditonalDetails_WP();
                        if(e.SVMXC__SM_Latitude__c != null && e.SVMXC__SM_Longitude__c != null){
                            strLoggerString += system.now() + 'CalendarGeoItem 1 \n';
                            techAddtnlDetail.latitude = e.SVMXC__SM_Latitude__c;
                            techAddtnlDetail.longitude = e.SVMXC__SM_Longitude__c;
                            techAddtnlDetail.eventtype = 'CalendarGeoItem';
                        }
                        if(e.SVMXC__Location__c != null){
                            strLoggerString += system.now() + 'CalendarGeoItem 2\n';
                            techAddtnlDetail.address = e.SVMXC__Location__c;
                            techAddtnlDetail.eventtype = 'CalendarGeoItem';
                        }
                        if(e.SVMXC__SM_Latitude__c == null && e.SVMXC__SM_Longitude__c == null && e.SVMXC__Location__c == null){
                            strLoggerString += system.now() + 'CalendarItem 2\n';
                            techAddtnlDetail.eventtype = 'CalendarItem';
                        }
                         techAddtnlDetail.isForcedStayNode = false ;
                        mapTechAdditionalDetails.put(strTechStartDtTime, techAddtnlDetail);
                        //strLoggerString += system.now() + ': Capacity Calculation - Technician Event Additional details SVMX event mapTechAdditionalDetails == ' + mapTechAdditionalDetails + '\n'; 
                    }
                }
                //strLoggerString += system.now() + ': Usage Details: After SVMXEvent iteration.. . \n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
                  strLoggerString += system.now() + 'SMAX_OptiMax_Engine_Ext::doCapacityComputation() mapEventNonWO==> : ' + mapEventNonWO + '\n';
                //Technician Event Additional details 
                //system.debug('SMAX_OptiMax_Engine_Ext::doCapacityComputation() outside loop mapTechAdditionalDetails : '+mapTechAdditionalDetails);
                
                //strLoggerString += system.now() + 'SMAX_OptiMax_Engine_Ext::doCapacityComputation() outside loop mapTechAdditionalDetails : ' + mapTechAdditionalDetails + '\n';
               
                if(mapTechAdditionalDetails != NULL && mapTechAdditionalDetails.size() > 0)
                     resultSet.mapTechAdditionalDetails = mapTechAdditionalDetails;
                 
                //Commented the below map as we have introduced two separate maps. One for NonWOEvents and ONSEvents
                /*if(mapTechIdStrtDtTEventId != NULL && mapTechIdStrtDtTEventId.size() > 0){
                    resultSet.mapTechIdStrtDtTEventId = mapTechIdStrtDtTEventId;
                }*/
                
                //Map which stores the Tech Events
                if(mapTechIdExecTimeEventId != NULL && mapTechIdExecTimeEventId.size() > 0){
                    resultSet.mapTechIdExecTimeEventId = mapTechIdExecTimeEventId;
                }
                
                //Map which stores the ONS Events
                if(mapTechIdONSExecTimeEventId != NULL && mapTechIdONSExecTimeEventId.size() > 0){
                    resultSet.mapTechIdONSExecTimeEventId = mapTechIdONSExecTimeEventId;
                }     
                
                //strLoggerString += system.now() + 'SMAX_OptiMax_Engine_Ext::doCapacityComputation() outside loop mapTechIdStrtDtTEventId : ' + mapTechIdStrtDtTEventId + '\n';
                     
                //Apurva/Pavitra: Heap size issue
                mapSVMXEvent.clear();
                // Capacity calculation for initial scheduling horizon
                if(!isAdditionalCapacity)
                {
                    resultSet.mapTechAvailability = getTechiniciansAvailability(NULL, lstTechnicians, mapBusinessHours, mapTechAllDayEvents, setCurrentSchedHorizonDates, mapTechMultiDayEvents);
                    resultSet.mapTechIdBreakEventExecTime = getTechniciansBreakHoursWindow(lstTechnicians, mapBusinessHours, setCurrentSchedHorizonDates);
                    // Find the actual capacity (sum of free time of all technicians in the scheduling horizon)
                    //dblActualCapacity = getAvailablity(resultSet.mapTechAvailability);
                    strLoggerString += system.now() + ': Capacity Calculation - Initial Required Capacity calculated: ' + dblRequiredCapacity + '\n';
                    strLoggerString += system.now() + ': Capacity Calculation - Initial Actual Capacity: ' + dblActualCapacity + '\n';
                    //strLoggerString += system.now() + ': Usage Details: End of Capacity calculation for initial scheduling horizon. . \n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
                }
                //Cleaned for Event Heap size issue
                setEventWorkOrderIds.clear();
                mapAllEventWorkOrders.clear();
                
            //}
            //while (dblActualCapacity < dblRequiredCapacity && (datActualStartDate.daysBetween(datEndDate) + 1) < intCapExtendedByDays);
            //strLoggerString += system.now() + ': Usage Details: End of While Loop.... \n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
            
            //Heap size issue
            mapUsersTechnicians.clear();
            //resultSet.intUpdatedNoOfDays = datActualStartDate.daysBetween(datLastCalcEndDate) + 1;
            
            // For the work orders to be rescheduled, build the string of work orders & events (format: WOId1,WOId2~|~EventId1,EventId2) from the Work Order Event Map
            String log_WO = '';
            String log_WOEvent = '';
            
            for(String wo : mapWrkOrdrEvent.keyset())
            {
                if(log_WO != '')
                    log_WO += ',';
                log_WO += wo;
                for(Id woEventId: mapWrkOrdrEvent.get(wo))
                {
                    if(log_WOEvent != '')
                        log_WOEvent += ',';
                    log_WOEvent += woEventId;
                }
            }
            resultSet.setReschedExternalWOs = mapWrkOrdrEvent.keyset();
            resultSet.strWOsToReschedAndEvents += log_WO + '~|~' + log_WOEvent;
            //Begin : Spring17 - Overnight - Set the Overngiht Events ids that needs to be deleted if the run is a second run only if it is a full run
            
            if(isFullRun){
                //Map<String,Event> overnightSFEvents = new Map<String,Event>([Select id from Event where WhatId IN :setAvailTech AND SVMXC__SM_Status__c != 'Confirmed' AND Type = 'Overnight Stay']);
                //Map<String,SVMXC__SVMX_Event__c> overnightSVMXEvents = new Map<String,SVMXC__SVMX_Event__c>([Select id from SVMXC__SVMX_Event__c where SVMXC__Technician__c IN :setAvailTech AND SVMXC__SM_Status__c != 'Confirmed' AND SVMXC__Type__c = 'Overnight Stay']);
                date inputEnddate = dtmLastDaysEndDateTime.dateGMT();
                datetime inputStartdatetime = Datetime.newInstanceGmt(dtmStartDateTime.dateGMT(),Time.newInstance(0, 0, 0, 0));

                Map<String,Event> overnightSFEvents = new Map<String,Event>([Select id from Event where WhatId IN :setAvailTech AND SVMXC__SM_Status__c != 'Confirmed' AND Type = 'Overnight Stay' AND ((StartDateTime <= :dtmLastDaysEndDateTime and EndDateTime >= :dtmStartDateTime)OR (ActivityDate <= :inputEnddate and EndDateTime >= :inputStartdatetime AND IsAllDayEvent = true) OR(StartDateTime = :inputStartdatetime AND IsAllDayEvent = true))]);
                Map<String,SVMXC__SVMX_Event__c> overnightSVMXEvents = new Map<String,SVMXC__SVMX_Event__c>([Select id from SVMXC__SVMX_Event__c where SVMXC__Technician__c IN :setAvailTech AND SVMXC__SM_Status__c != 'Confirmed' AND SVMXC__Type__c = 'Overnight Stay' AND ((SVMXC__StartDateTime__c <= :dtmLastDaysEndDateTime and SVMXC__EndDateTime__c >= :dtmStartDateTime)OR (SVMXC__ActivityDate__c <= :inputEnddate and SVMXC__EndDateTime__c >= :inputStartdatetime AND SVMXC__IsAllDayEvent__c = true) OR(SVMXC__StartDateTime__c = :inputStartdatetime AND SVMXC__IsAllDayEvent__c = true))]);
                String  overnightSFEventsStr = String.join(new List<String>(overnightSFEvents.keyset()), ',');
                String  overnightSMAXEventStr = String.join(new List<String>(overnightSVMXEvents.keyset()), ',');
                String overnightEventsStr;
                 
                if(overnightSFEventsStr != '' && overnightSMAXEventStr != '' ){
                    overnightEventsStr  = overnightSFEventsStr + ', '+overnightSMAXEventStr;
                }else if(overnightSFEventsStr == '' && overnightSMAXEventStr != ''){
                        overnightEventsStr  = overnightSMAXEventStr;
                 }else if(overnightSFEventsStr != '' && overnightSMAXEventStr == ''){
                        overnightEventsStr  = overnightSFEventsStr;
                 }
                  resultSet.strWOsToReschedAndEvents += '~|~' +overnightEventsStr;
                  
                //Cleaned for Event Heap size issue
                overnightSFEvents.clear();
                overnightSVMXEvents.clear(); 
            }else{
                resultSet.strWOsToReschedAndEvents += '~|~' +'';
            }
           
            //End : Spring17 -  Overnight - Set the Overngiht Events ids that needs to be deleted if the run is a second run only if it is a full run
            
            //Cleaned for Event Heap size issue
            mapEventNonWO.clear();
            mapTechTimeZone.clear();
            setWrkOrdsToReschedule.clear();
            setWrkOrdsToForceFix.clear();
            mapTechnicians.clear();
        }
        catch(Exception e)
        {
            strLoggerString += system.now() + ': Capacity Calculation - Failed with the exception: ' + e.getMessage() + '\n';
            strLoggerString += system.now()+':Exception type caught: ' + e.getTypeName()+'\n' +'Message: ' + e.getMessage()+'\n'+'Cause: ' + e.getCause()+'\n'+'Line number: ' + e.getLineNumber()+'\n'+'Stack trace: ' + e.getStackTraceString()+'\n';
            system.debug('strLoggerString - ' + strLoggerString);
            //WSCH_AuditLogger.debug('SMAX_OptiMax_Engine_Ext::doCapacityComputation(): Capacity Calculation Ends');
            //WSCH_AuditLogger.finish();
            throw new SVMXException(strLoggerString);
        }
        //WSCH_AuditLogger.debug('SMAX_OptiMax_Engine_Ext::doCapacityComputation(): resultSet '+resultSet);
        //WSCH_AuditLogger.debug('SMAX_OptiMax_Engine_Ext::doCapacityComputation(): Capacity Calculation Ends');
        //WSCH_AuditLogger.finish();
        //strLoggerString += system.now() + ': Usage Details: End of doCapacityComputation() before return... \n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
          
        return resultSet;
    }    
//**********************Begin :  Sadiya : Methods to handle Complete Job Failures
public map<String,Map<String,String>> handleCJFailurePartial(SMAX_OptiMax_Engine_WS.ipCompleteJobs_WP completeJobDetail){
    map<String,Map<String,String>> errorMap=new map<String,Map<String,String>>();
    if(completeJobDetail.workOrderError_WPL != NULL && completeJobDetail.workOrderError_WPL.size() > 0 )
    {
        system.debug('Handling  WO Error workOrderError_WPL ');
        errorMap = processCJErrorWOPartial(completeJobDetail);
    }
    if(completeJobDetail.technicianError_WPL != NULL && completeJobDetail.technicianError_WPL.size() > 0)
         
    {
        system.debug('Handling  Tecnician Error technicianError_WPL ');
        processCJErrorTechnician(completeJobDetail);
    }
    if(completeJobDetail.technicianEventError_WPL != NULL && completeJobDetail.technicianEventError_WPL.size() > 0)
    {
        system.debug('Handling  TechEvent Error technicianEventError_WPL ');
        errorMap = processCJErrorTechEventPartial(completeJobDetail);
    }
    return errorMap;
 }
 
 
 public void handleCJFailureComplete(SMAX_OptiMax_Engine_WS.ipCompleteJobs_WP completeJobDetail, SVMXC__SVMX_Jobs__c objSvmxJob){
        DateTime dtmCurrentDateTime = System.now();
        String strExecLogMsgEncoded = '';
        objSvmxJob.SVMXC__End_Time__c = dtmCurrentDateTime;
        objSvmxJob.SVMXC__Status__c = String.valueof(-1);
        objSvmxJob.SVMXC__OptiMax_Message__c = 'Failure';
        String exeLogMessage = '';
        String woErrorText = '';
        boolean isProcessingError = false;
        
        //TODO:processing work order, technician and technician event and update the error text.
        if(completeJobDetail.exeLog_WPL != NULL && completeJobDetail.exeLog_WPL.size() > 0)
        {
            for(SMAX_OptiMax_Engine_WS.ExeLog_WP exeLog : completeJobDetail.exeLog_WPL)
            {
                if(exeLog.logLevel == -1)
                {
                    objSvmxJob.SVMXC__Status__c = String.valueof(-1);
                    objSvmxJob.SVMXC__OptiMax_Message__c = 'Initiate Error'; // Initiate Error
                }
                else if(exeLog.logLevel == -2)
                {
                    objSvmxJob.SVMXC__Status__c = String.valueof(-2);
                    objSvmxJob.SVMXC__OptiMax_Message__c = 'Processing Error'; // Processing Error
                    objSVMxJob.SVMXC__Message__c = exeLog.message;
                    exeLogMessage = String.valueOf(exeLog.message);
                     isProcessingError = true;
                }
                else if(exeLog.logLevel == -3)
                {
                    objSvmxJob.SVMXC__Status__c = String.valueof(-3);
                    objSvmxJob.SVMXC__OptiMax_Message__c = 'Complete Error'; // Complete Error
                }
                strExecLogMsgEncoded += String.valueof(exeLog.timeStamp) + ':' + String.valueof(exeLog.logLevel) + ':' + String.valueof(exeLog.operation) + ':' + String.valueof(exeLog.message);
                strExecLogMsgEncoded += '\n' + exeLog.message + ':' + isProcessingError + '\n';
            }
            }
        update objSvmxJob; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(completeJobDetail.workOrderError_WPL != NULL && completeJobDetail.workOrderError_WPL.size() > 0 )
        {
                processCJErrorWOComplete(completeJobDetail);
        }
        if(completeJobDetail.technicianError_WPL != NULL && completeJobDetail.technicianError_WPL.size() > 0)
        {
            processCJErrorTechnician(completeJobDetail);
        }
        if(completeJobDetail.technicianEventError_WPL != NULL && completeJobDetail.technicianEventError_WPL.size() > 0)
        {
            processCJErrorTechEventComplete(completeJobDetail);
        }
 
 }
 
private static map<String, String> retrieveCompleteJobSettings(){
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
    return mapSettingValues;
 }
 
private static void creatAttachment(String name,String parentId,String strExecLogMsgEncoded){
    map<String, String> mapSettingValues = retrieveCompleteJobSettings();
if(mapSettingValues.containsKey('OMAX003_SET018') && mapSettingValues.get('OMAX003_SET018').toUpperCase() == 'TRUE'){
     Attachment objAttachment = new Attachment(Name = name, ParentId = parentId, Body = Blob.valueOf(strExecLogMsgEncoded), IsPrivate = TRUE);
     insert objAttachment; 
}
}

private static void processCJErrorWOComplete(SMAX_OptiMax_Engine_WS.ipCompleteJobs_WP completeJobDetail){
  String strExecLogMsgEncoded = '';
  list<String> woNames = new list<String>();
  Map<String,String> woErrorMap=new Map<String,String>();
  if(completeJobDetail.workOrderError_WPL != null) {
    strExecLogMsgEncoded = strExecLogMsgEncoded + ' ' + completeJobDetail.workOrderError_WPL;
    for(SMAX_OptiMax_Engine_WS.Status_WP errorWO : completeJobDetail.workOrderError_WPL)
    {
        system.debug(errorWO.message);
        system.debug(errorWO);
        woNames.add(errorWO.event);
        woErrorMap.put(errorWO.event,errorWO.message);
        strExecLogMsgEncoded = strExecLogMsgEncoded + ' ' + errorWO.message;
    }
  }
  system.debug('processCompleteJobErrorWOComplete woErrorMap'+woErrorMap);
  creatAttachment('CompleteJob-WorkOrder Error Log',completeJobDetail.jobId,strExecLogMsgEncoded);
  system.debug('Updating the work order'+woNames);
  List<SVMXC__Service_Order__c> lstErrorWOs = [Select Id, Name, SVMXC__OptiMax_Error_Text__c,SVMXC__Violation_Message__c,SVMXC__Violation_Status2__c from SVMXC__Service_Order__c where Name in : woNames];
  for(SVMXC__Service_Order__c eachWO : lstErrorWOs)
    {                        
        eachWO.SVMXC__Violation_Message__c = woErrorMap.get(eachWO.Name);
        eachWO.SVMXC__Violation_Status2__c ='Unscheduled - Bad Data';
        eachWO.SVMXC__OptiMax_Error_Text__c = woErrorMap.get(eachWO.Name);
        
    }
    WSCH_OptimizedSchedulingService.triggerExecuted = true;
    WSCH_OptimizedSchedulingService.isCallOutExecuted = true;
  system.debug('creatAttachment for WO'+strExecLogMsgEncoded);
  if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstErrorWOs, COMM_SecurityUtils.Access.Updateable)){  //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
        update lstErrorWOs;
 } else {
        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
 }    
}

private static map<String,Map<String,String>> processCJErrorWOPartial(SMAX_OptiMax_Engine_WS.ipCompleteJobs_WP completeJobDetail){
  String strExecLogMsgEncoded = '';
  map<String, String> mapUnassignedWorkOrders = new map<String, String>();
  map<String, String> mapInvalidWOErrors = new map<String, String>();
  map<String,Map<String,String>> woErrorMap = new map<String,Map<String,String>>();
  system.debug('handleCompleteJobErrorWO Stayed Creatng attachemnt');
  if(completeJobDetail.workOrderError_WPL != null) {
    strExecLogMsgEncoded = strExecLogMsgEncoded + ' ' + completeJobDetail.workOrderError_WPL;
    for(SMAX_OptiMax_Engine_WS.Status_WP errorWO : completeJobDetail.workOrderError_WPL)
    {
        system.debug(errorWO.message);
        system.debug(errorWO);
        strExecLogMsgEncoded = strExecLogMsgEncoded + ' ' + errorWO.message;
        if(errorWO.message == 'Unassigned'){
            mapUnassignedWorkOrders.put(errorWO.event, errorWO.tag);    
        }else{
            mapInvalidWOErrors.put(errorWO.event,errorWO.message); // Bad workorder
        }
    }
  }
  system.debug('creatAttachment for WO'+strExecLogMsgEncoded);
  creatAttachment('CompleteJob-WorkOrder Error Log',completeJobDetail.jobId,strExecLogMsgEncoded);
  woErrorMap.put('unassignedwomap',mapUnassignedWorkOrders);
  woErrorMap.put('invalidwomap',mapInvalidWOErrors);
  return woErrorMap;
  
}

private static void processCJErrorTechnician(SMAX_OptiMax_Engine_WS.ipCompleteJobs_WP completeJobDetail){
String strExecLogMsgEncoded='';
if(completeJobDetail.technicianError_WPL != null) {
    strExecLogMsgEncoded = strExecLogMsgEncoded + ' ' + completeJobDetail.technicianError_WPL;
  }
creatAttachment('CompleteJob-Technician Error Log',completeJobDetail.jobId,strExecLogMsgEncoded);
}



//Handle Error TechEvents
private static void processCJErrorTechEventComplete(SMAX_OptiMax_Engine_WS.ipCompleteJobs_WP completeJobDetail){
    system.debug('Complete Job - processCJErrorTechEventComplete');
    
    map<String,Map<String,String>> errorMap = processCJErrorTechEvents(completeJobDetail);
    map<String, String> mapUnassignedSFEvents = new map<String, String>();
    map<String, String> mapUnassignedSMAXEvents = new map<String, String>();
    List<Event> lstSFEvents = new List<Event>();
    List<SVMXC__SVMX_Event__c> lstSvmxEvents = new List<SVMXC__SVMX_Event__c>();

    if(errorMap !=null && errorMap.size()>0){
        if(errorMap.containsKey('unassignedSFEvents')){
                    mapUnassignedSFEvents = errorMap.get('unassignedSFEvents');
        }
                if(errorMap.containsKey('unassignedSMAXEvents')){
                    mapUnassignedSMAXEvents = errorMap.get('unassignedSMAXEvents');
        }
    }

    system.debug('complete job mapUnassignedSFEvents:- '+mapUnassignedSFEvents);
    system.debug('complete job mapUnassignedSFEvents:- '+mapUnassignedSFEvents);

     try{
            List<Event> lstUnAssignedSFEvents = [SELECT id, SVMXC__SM_Status__c, WhatId, Subject, OwnerId, startDateTime, EndDateTime, Location, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c, SVMXC__Driving_Time__c, SVMXC__SM_Idle_Time__c, SVMXC__Driving_Time_Home__c from event where id IN :mapUnassignedSFEvents.keySet() and isDeleted = false];
            if(lstUnAssignedSFEvents != null && lstUnAssignedSFEvents.size() > 0){
                for(Event eventobj :lstUnAssignedSFEvents){
                    eventobj.SVMXC__SM_Status__c='Non-optimizable';
                    lstSFEvents.add(eventobj);
                }
            }
            system.debug('Unassigned SF events '+lstUnAssignedSFEvents);
            
            List<SVMXC__SVMX_Event__c> lstUnAssignedSMAXEvents = [SELECT id, SVMXC__SM_Status__c, SVMXC__WhatId__c, Name, SVMXC__Technician__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c, SVMXC__ActivityDate__c, SVMXC__ActivityDateTime__c, SVMXC__DurationInMinutes__c, SVMXC__Driving_Time__c, SVMXC__SM_Idle_Time__c, SVMXC__Driving_Time_Home__c from SVMXC__SVMX_Event__c where id IN :mapUnassignedSMAXEvents.keySet() and isDeleted = false];
            
            system.debug('Unassigned SVMX events '+lstUnAssignedSMAXEvents);

            if(lstUnAssignedSMAXEvents != null && lstUnAssignedSMAXEvents.size() > 0){
                for(SVMXC__SVMX_Event__c smaxEventobj :lstUnAssignedSMAXEvents){
                    smaxEventobj.SVMXC__SM_Status__c='Non-optimizable';
                    lstSvmxEvents.add(smaxEventobj);
                }
            }
            system.debug('Unassigned SF events '+lstUnAssignedSFEvents);

        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstSFEvents, COMM_SecurityUtils.Access.Updateable)){  //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            update lstSFEvents;
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
        }    
        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstSvmxEvents, COMM_SecurityUtils.Access.Updateable)){  //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            update lstSvmxEvents;
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
        } 

        } 

        catch(Exception e) {
           system.debug('Execption whule saving Unassigned Events'); 
        }    
    
   
       

}

private static map<String,Map<String,String>> processCJErrorTechEventPartial(SMAX_OptiMax_Engine_WS.ipCompleteJobs_WP completeJobDetail){
     map<String,Map<String,String>> errorMap = processCJErrorTechEvents(completeJobDetail);
     return errorMap;
}

private static map<String,Map<String,String>> processCJErrorTechEvents(SMAX_OptiMax_Engine_WS.ipCompleteJobs_WP completeJobDetail){
    String strExecLogMsgEncoded='';
    map<String, String> mapUnassignedSFEvents = new map<String, String>();
    map<String, String> mapUnassignedSMAXEvents = new map<String, String>();
    map<String,Map<String,String>> errorMap = new map<String,Map<String,String>>();

     // Get the key prefix for Salesforce Events
    Map<String, Schema.SObjectType> descAllObjs = Schema.getGlobalDescribe();
    Schema.Describesobjectresult descEventObj = descAllObjs.get('Event').getDescribe();
    strSfEventKeyPrefix = descEventObj.getKeyPrefix();

    // Get the key prefix for ServiceMax Events
    Schema.Describesobjectresult descSvmxEventsObj;
    if (descAllObjs.containsKey('SVMXC__SVMX_Event__c') == TRUE)
        descSvmxEventsObj = descAllObjs.get('SVMXC__SVMX_Event__c').getDescribe();
    else
        descSvmxEventsObj = descAllObjs.get('SVMX_Event__c').getDescribe();
    strSvmxEventKeyPrefix = descSvmxEventsObj.getKeyPrefix();

    if(completeJobDetail.technicianEventError_WPL != null) {
        strExecLogMsgEncoded = strExecLogMsgEncoded + ' ' + completeJobDetail.technicianEventError_WPL;
        creatAttachment('CompleteJob-TechEvent Error Log',completeJobDetail.jobId,strExecLogMsgEncoded);
        for(SMAX_OptiMax_Engine_WS.Status_WP unassignedWO : completeJobDetail.technicianEventError_WPL)
        {
                //Event_1fora1D2I00000g3dEFUAY_a0v2I00000pHOxMQAW
                system.debug('unassignedWO.event'+unassignedWO.event);
                if(unassignedWO.event.startsWith('Event')){
                    String strEventId = unassignedWO.event.split('_')[2];
                    system.debug('processCJErrorTechEvents strEventId'+strEventId);
                    if(strEventId.startsWith(strSfEventKeyPrefix)){
                        mapUnassignedSFEvents.put(strEventId, unassignedWO.tag);    
                    }else{
                        mapUnassignedSMAXEvents.put(strEventId, unassignedWO.tag);
                    }                           
                }
            
        }
      } 
      system.debug('processCJErrorTechEvents mapUnassignedSFEvents'+mapUnassignedSFEvents);
      system.debug('processCJErrorTechEvents mapUnassignedSMAXEvents'+mapUnassignedSMAXEvents);

      errorMap.put('unassignedSFEvents',mapUnassignedSFEvents);
      errorMap.put('unassignedSMAXEvents',mapUnassignedSMAXEvents);
      return errorMap;
}

//**********************END :  Sadiya : Methods to handle Complete Job Failures    
    
}