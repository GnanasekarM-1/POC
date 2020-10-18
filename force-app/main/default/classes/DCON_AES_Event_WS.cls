global class DCON_AES_Event_WS 
{
    public DCON_AES_Event_WS ()
    {}
    public class SVMXException extends Exception {}
    public static DCON_Utils dcUtils = new DCON_Utils();
    
    
    public static Map<String, String> svmxSettingList = new Map<String, String>(DCON_Event_WS.loadDCsetting());
    public static Map<String, String> loadDCsetting()
    {
        if(SVMX_Constants.AllDCSettingList == NULL || SVMX_Constants.AllDCSettingList.size() == 0)
        {
            list<string> lstSubModules = new list<string>{'DCON001'};
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
            SVMX_Constants.AllDCSettingList = commSettings.SVMX_getSettingList(lstSubModules);          
        }
        system.debug('svmxSettingList '+svmxSettingList);
        return  SVMX_Constants.AllDCSettingList.get('DCON001');

    }
      
    
    global class AES_Request 
    {
        webservice String timeZone{get;set;}
        webservice List<Event> lstEvent = new list<Event>();
        webservice String UserId{get;set;}      
        webservice List<String> lsttechId = new List<String>();     
        webservice Integer eventMinDuration{get;set;}
        webservice boolean isTechWorkingHrsEnabled{get;set;}
        webservice boolean isMachineWorkingHrsEnabled{get;set;}
        webservice boolean isOverlappingEnabled{get;set;}
        webservice boolean isCalculateEndTime{get;set;}
        webservice list<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue = new list<DCON_Configuration_WS.SVMX_StringMap>();
        webservice boolean IsUnAssignWorkOrder{get;set;}
        webservice boolean IsdeleteEvents{get;set;}
        
 
        public AES_Request(string UserId, 
                        List<Event> lstEvent,
                        String timeZone,
                        List<String> lsttechId,
                        integer eventMinDuration, 
                        boolean isTechWorkingHrsEnabled,
                        boolean isMachineWorkingHrsEnabled,
                        boolean isOverlappingEnabled,
                        boolean isCalculateEndTime,
                        List<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue,
                        boolean IsUnAssignWorkOrder,
                        boolean IsdeleteEvents
                        ) 
        {
            this.UserId = UserId;
            this.lstEvent = lstEvent; 
            this.timeZone = timeZone;
            this.lsttechId = lsttechId;
            this.eventMinDuration = eventMinDuration;
            this.isTechWorkingHrsEnabled = isTechWorkingHrsEnabled;
            this.isMachineWorkingHrsEnabled = isMachineWorkingHrsEnabled;
            this.isOverlappingEnabled = isOverlappingEnabled;
            this.isCalculateEndTime = isCalculateEndTime;
            this.lstKeyValue = lstKeyValue;
            this.IsUnAssignWorkOrder = IsUnAssignWorkOrder;
            this.IsdeleteEvents = IsdeleteEvents;
            
        }
        public AES_Request() {}
    }
    
    global class AES_Response 
    {
        webservice  List<String> lstAESEvent{get;set;}
        webservice  String endDatetime{get;set;}
        webservice  String startDatetime{get;set;}
        webservice  Integer remainderServiceDuration{get;set;}
        webservice  Integer eventsCounter{get;set;}
        webservice  String deletedEvents{get;set;}
            
        public AES_Response(List<String> lstAESEvent, String endDatetime, String startDatetime, Integer remainderServiceDuration, Integer eventsCounter, String deletedEvents)
        {
            this.lstAESEvent = lstAESEvent;
            this.endDatetime = endDatetime;
            this.startDatetime = startDatetime;
            this.remainderServiceDuration = remainderServiceDuration;
            this.eventsCounter = eventsCounter;
            this.deletedEvents = deletedEvents;
        }
        public AES_Response() {}           
    }
    
    global class StartEndTime
    {
        Webservice Datetime startTime {get; set;}
        Webservice Datetime endTime {get; set;}
        
        public StartEndTime(Datetime startTime, Datetime endTime)
        {
            this.startTime = startTime;
            this.endTime = endTime;
        }
        public StartEndTime() {}   
    }

    WebService static AES_Response DCON_AES_Create_Events_WS(AES_Request req)
    {
        AES_Response response = new AES_Response();
        try
        {
            system.debug(logginglevel.warn,'Req:  '+ Req);
            response = DCON_AES_Create_Events(req.UserId, 
                        req.lstEvent,
                        req.timeZone,
                        req.lsttechId,
                        req.eventMinDuration, 
                        req.isTechWorkingHrsEnabled,
                        req.isMachineWorkingHrsEnabled,
                        req.isOverlappingEnabled,
                        req.isCalculateEndTime,
                        req.lstKeyValue,
                        req.IsUnAssignWorkOrder,
                        req.IsdeleteEvents);
            System.Debug(logginglevel.warn,'response : '+response);
        }
        catch(DmlException ex)
        {
            system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getDmlMessage(0));
        }
        catch(Exception ex)
        {
            system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getMessage());
        }
        return response;
            
    }
    /**
    * LONG JOB SCHEDULING USER STORIES
    * Method Name:  DCON_AES_Create_Events
    * Description:  Splits long job scheduling event into small events whose duration is greater than event minimum duration and consider options like technician working hours, machine access hours and don't overlap on existing events.
    * Parameters:   string UserId                                - user Id
                    List<Event> lstEvent                         - List contains Long Job Scheduling(LJS) event     
                    String timeZone                              - timezone send by client  
                    List<String> lsttechId                       - List contains technician whom LJS event is assigned  
                    Integer eventMinDuration                     - minimum event duration send by client        
                    boolean isTechWorkingHrsEnabled              - Consider technician working hours or not 
                    boolean isMachineWorkingHrsEnabled           - Consider machine access hours or not 
                    boolean isOverlappingEnabled                 - whether overlapping is allow or not  
                    boolean isCalculateEndTime                   - if it is true return enddatetime of last event after spliting events without updating database       
                    List<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue -List contains key value pairs to update WO or Event
                    boolean IsUnAssignWorkOrder                  - if it is true, update the technician in WO with latest technician    
                    boolean IsdeleteEvents                       - if it is true, delete all other events associated with WO while reassigning WO   
    * Return:       List<String> lstAESEvent                     - list of splitted events  
                    String endDatetime                           - return enddatetime in client sent timezone when isCalculateEndTime is true   
                    Integer remainderServiceDuration             - return remaining unscheduled time while splitting events based on event minimum duration
                    Integer eventsCounter                        - return count of events splitted  
                    String deletedEvents                         - return deleted event Ids when IsdeleteEvents is true     
    */
    //Note: All calculations happen in timezone send by client
    public static AES_Response DCON_AES_Create_Events(string UserId, 
                        List<Event> lstEvent,
                        String timeZone,
                        List<String> lsttechId,
                        integer eventMinDuration, 
                        boolean isTechWorkingHrsEnabled,
                        boolean isMachineWorkingHrsEnabled,
                        boolean isOverlappingEnabled,
                        boolean isCalculateEndTime,
                        List<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue,
                        boolean IsUnAssignWorkOrder,
                        boolean IsdeleteEvents)
    {
        AES_Response response;  
        Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        Schema.Describesobjectresult discResUser = allObjs.get('User').getDescribe();
        String UserKey = discResUser.getKeyPrefix();
        
        List<String> lstTech = new List<String>();
        List<String> lstSFUserId = new List<String>();
        
        List<String> lstAESchildevts = new List<String>();
               
        Savepoint sp = Database.setSavepoint();
        
        try
        {
            List<Event> lstAESEvents = new List<Event>();
            
            if(timeZone == NULL || timeZone == '')
            {
                if(!Userinfo.getUserId().contains(UserId))
                    timeZone = [SELECT TimeZoneSidKey from User where Id = :UserId].TimeZoneSidKey;
                else
                    timeZone = Userinfo.getTimeZone().getID();
            }
                       
            Set<String> setActiveAvailableTechnicains = new Set<String>();
            List<String> lstWorkOrderIds = new List<String>();  
                        
            for(Event oEvent: lstEvent)
            {
                lstWorkOrderIds.add(String.valueOf(oEvent.whatId));
                if(String.valueof(oEvent.OwnerId).startsWith(UserKey))
                    lstSFUserId.add(oEvent.OwnerId);
                else
                    lstTech.add(oEvent.OwnerId);
            }
            
            List<SVMXC__Service_Order__c> lstWorkOrders = [Select Id, SVMXC__Preferred_Business_Hours__c, SVMXC__Dispatch_Status__c from SVMXC__Service_Order__c where Id IN: lstWorkOrderIds];
            System.debug('lstWorkOrders:' + lstWorkOrders);
            
            for(String s1: lsttechId)
            {
                setActiveAvailableTechnicains.add(s1);   
            }
            
            System.debug('setActiveAvailableTechnicains:' + setActiveAvailableTechnicains);
            
            Map<String, String> mapSFUSerTechId = new Map<String, String>();
            map<String,SVMXC__Service_Group_Members__c> mapTechIdTechObj ;
            mapTechIdTechObj =new map<String,SVMXC__Service_Group_Members__c>([Select Id,SVMXC__Salesforce_User__c,Name from SVMXC__Service_Group_Members__c where id IN :lstTech or SVMXC__Salesforce_User__c IN :lstSFUserId]);
            for(String TechId : mapTechIdTechObj.keyset())
            {
                mapSFUSerTechId.put(mapTechIdTechObj.get(TechId).SVMXC__Salesforce_User__c,TechId);
            }
                        
            Map<Id,BusinessHours> techBusinessHrMap = new Map<Id,BusinessHours>(); 
            
            if(isTechWorkingHrsEnabled)
            {
                techBusinessHrMap = Retrieve_Tech_Working_Details(setActiveAvailableTechnicains);
                System.debug('techBusinessHrMap:'+ techBusinessHrMap);
            }
            BusinessHours machineAccessHrs;
            if(isMachineWorkingHrsEnabled)
            {
                machineAccessHrs = [SELECT WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime,TimeZoneSidKey from BusinessHours where Id = :lstWorkOrders.get(0).SVMXC__Preferred_Business_Hours__c and IsActive = true];
            }       
                        
            Integer eventMinDurationInseconds = eventMinDuration * 60;
            
            COMM_Utils_ManageSettings commUtils = new COMM_Utils_ManageSettings();
            Map<String, String> svmxSetting = new Map<String, String> ();
            svmxSetting = commUtils.SVMX_getSettingList('DCON005','SET009');
            Integer maxUnsuccessCalenderDays = 0;
            maxUnsuccessCalenderDays = integer.valueOf(svmxSetting.get('SET009'));
            System.debug('maxUnsuccessCalenderDays:'+ maxUnsuccessCalenderDays);    

            Double totalAESServiceDuration = 0.0;
            Integer tempremainderServiceDuration = 0;   
            
            for(Event oEvent: lstEvent)
            {
                if(oEvent.SVMXC__Driving_Time__c == null)
                    oEvent.SVMXC__Driving_Time__c = 0;    
                if(oEvent.SVMXC__Driving_Time_Home__c == null)
                    oEvent.SVMXC__Driving_Time_Home__c = 0;   
                if(oEvent.SVMXC__Overhead_Time_After__c == null)
                    oEvent.SVMXC__Overhead_Time_After__c = 0; 
                if(oEvent.SVMXC__Overhead_Time_Before__c == null)
                    oEvent.SVMXC__Overhead_Time_Before__c = 0;    
                if(oEvent.SVMXC__Break_Time_Total__c == null)
                    oEvent.SVMXC__Break_Time_Total__c = 0;    
                
                //Splitting of events will happen only when Service duration of Event is greater than event minimum duration of Event window in client side.
                if(Integer.valueof(oEvent.SVMXC__Service_Duration__c) > eventMinDurationInseconds)
                {
                    Integer temptotalServiceDuration = 0;
                    Date dateForNextQuery = (oEvent.ActivityDateTime).dateGMT();
                    list<StartEndTime> SFSVMXStartEndTime = new list<StartEndTime>(); 
                    Integer count = 0;
                    Integer eventsize = 0;
                //looping through the consecutive days until service duration of LJS is scheduled   
                for(Date tempdate = (oEvent.ActivityDateTime).dateGMT(); temptotalServiceDuration < Integer.valueOf(oEvent.SVMXC__Service_Duration__c); tempdate = tempdate.addDays(1))
                    {
                        count++;
                        //If no slot is available for days(mention in setting-'DCON005','SET009') for scheduling events throwing warning message to client. 
                        if(count > maxUnsuccessCalenderDays)
                        {
                            if((lstAESEvents.size() > eventsize))
                            {
                                eventsize = lstAESEvents.size();
                                count = 0;  
                            }
                            else
                            {
                                throw new SVMXException('DCON005_TAG066');   
                            }
                                
                        }
                        list<datetime> availableStartEndTime = new list<datetime>();
                        //Querying list of events from database for every 30 days when not to overlap to existing events
                        if(!isOverlappingEnabled && dateForNextQuery == tempdate)
                        {
                            //SFSVMXStartEndTime.clear();
                            List<Event> lstSFEvent = new  List<Event>();
                            List<SVMXC__SVMX_Event__c> lstSVMXEvent = new  List<SVMXC__SVMX_Event__c>(); 
                            //Since we are supporting different timezone querying events for previous date also
                            Datetime STtoRetrieveEvents = DateTime.newInstanceGmt(tempdate.addDays(-1),Time.newInstance(0,0,0,0));
                            Datetime ETtoRetrieveEvents = STtoRetrieveEvents.addDays(100);
                            dateForNextQuery = ETtoRetrieveEvents.dateGMT();
                            lstSFEvent = getLstSFEventforTech(mapSFUSerTechId.keyset(), STtoRetrieveEvents, ETtoRetrieveEvents);
                            lstSVMXEvent = getLstSVMXEventforTech(mapSFUSerTechId.values(), STtoRetrieveEvents, ETtoRetrieveEvents);
                            SFSVMXStartEndTime = mergeSFSVMXEvents(lstSFEvent, lstSVMXEvent, timeZone);
                            //lstSFEvent.clear();  //If everything is working fine uncomment this and test again
                            //lstSVMXEvent.clear();
                        }
                        if(isTechWorkingHrsEnabled && isMachineWorkingHrsEnabled)
                        {
                            // will do in future for checking both
                            List<Datetime> techWorkingHRStartEndTime = new List<Datetime>();
                            List<Datetime> machineAccessHrStartEndTime = new List<Datetime>();
                            List<Datetime> IntersectOfTechMachineAccessHr = new List<Datetime>();
                            List<datetime> OverlapTimeOfTechMachineAccessHrs = new List<Datetime>();
                            Integer techWorkingHRs = 0;
                            Integer machineAccessibleHRs = 0;
                            
                            OverlapTimeOfTechMachineAccessHrs.clear();
                            techWorkingHRStartEndTime.clear();
                            machineAccessHrStartEndTime.clear();
                            IntersectOfTechMachineAccessHr.clear();
                            
                            if((!GetHolidays(techBusinessHrMap.get(lsttechId.get(0)),tempdate)) && (!GetHolidays(machineAccessHrs,tempdate)))
                            {
                                System.debug('tempdate:'+tempdate);
                                techWorkingHRStartEndTime = dcUtils.getBHStartEndDateTime(timeZone,tempdate,techBusinessHrMap.get(lsttechId.get(0)));
                                machineAccessHrStartEndTime = dcUtils.getBHStartEndDateTime(timeZone,tempdate,machineAccessHrs);
                                
                                techWorkingHRs = (Integer.valueOf((((techWorkingHRStartEndTime.get(1)).getTime())/1000) - (((techWorkingHRStartEndTime.get(0)).getTime())/1000)))/3600;
                                
                                machineAccessibleHRs = (Integer.valueOf((((machineAccessHrStartEndTime.get(1)).getTime())/1000) - (((machineAccessHrStartEndTime.get(0)).getTime())/1000)))/3600;
                                
                                if(techWorkingHRs == 24 && machineAccessibleHRs < 24)
                                {
                                    OverlapTimeOfTechMachineAccessHrs.addAll(machineAccessHrStartEndTime);  
                                }
                                else if(techWorkingHRs < 24 && machineAccessibleHRs == 24)
                                {
                                    OverlapTimeOfTechMachineAccessHrs.addAll(techWorkingHRStartEndTime);        
                                }
                                else if(techWorkingHRs == 24 && machineAccessibleHRs == 24) 
                                {
                                    OverlapTimeOfTechMachineAccessHrs.add(DateTime.newInstanceGmt(tempdate,Time.newInstance(0,0,0,0))); 
                                    OverlapTimeOfTechMachineAccessHrs.add(DateTime.newInstanceGmt(tempdate.addDays(1),Time.newInstance(0,0,0,0)));  
                                }   
                                else if(techWorkingHRs < 24 && machineAccessibleHRs < 24)   
                                {
                                    //calling method to get overlapping timings 
                                    OverlapTimeOfTechMachineAccessHrs= overlappingTimeSlots(techWorkingHRStartEndTime,machineAccessHrStartEndTime); 
                                }
                                
                                if(OverlapTimeOfTechMachineAccessHrs != null && OverlapTimeOfTechMachineAccessHrs.size() > 0)
                                {
                                    availableStartEndTime.addAll(OverlapTimeOfTechMachineAccessHrs);
                                }   
                                else
                                {   
                                    //if no overlapping slot for the day, while go for next day
                                    continue;
                                }                                   
                            }
                            else
                            {
                                continue;   
                            }   
                        
                        }
                        else if(isTechWorkingHrsEnabled && !isMachineWorkingHrsEnabled)
                        {
                            List<Datetime> techWorkingHRStartEndTime = new List<Datetime>();
                            techWorkingHRStartEndTime.clear();
                            
                            //checking the given date is holiday. If it is holiday, goto next date.
                            if(!GetHolidays(techBusinessHrMap.get(lsttechId.get(0)),tempdate))
                            {
                                System.debug('tempdate:'+tempdate);
                                techWorkingHRStartEndTime = dcUtils.getBHStartEndDateTime(timeZone,tempdate,techBusinessHrMap.get(lsttechId.get(0)));
                                availableStartEndTime.addAll(techWorkingHRStartEndTime);
                            }
                            else
                            {
                                continue;   
                            }   
                        
                        }
                        else if(!isTechWorkingHrsEnabled && isMachineWorkingHrsEnabled)
                        {
                            List<Datetime> machineAccessHrStartEndTime = new List<Datetime>();
                            machineAccessHrStartEndTime.clear();
                            
                            //checking the given date is holiday. If it is holiday, goto next date.
                            if(!GetHolidays(machineAccessHrs,tempdate))
                            {
                                System.debug('tempdate:'+tempdate);
                                machineAccessHrStartEndTime = dcUtils.getBHStartEndDateTime(timeZone,tempdate,machineAccessHrs);
                                System.debug('machineAccessHrStartEndTime***:'+ machineAccessHrStartEndTime);
                                availableStartEndTime.addAll(machineAccessHrStartEndTime);
                            }
                            else
                            {
                                continue;   
                            }   
                        }   
                        else if(!isTechWorkingHrsEnabled && !isMachineWorkingHrsEnabled)
                        {
                            List<datetime> normalStartEndTime = new List<datetime>();
                            normalStartEndTime.add(DateTime.newInstanceGmt(tempdate,Time.newInstance(0,0,0,0))); 
                            normalStartEndTime.add(DateTime.newInstanceGmt(tempdate.addDays(1),Time.newInstance(0,0,0,0))); 
                            availableStartEndTime.addAll(normalStartEndTime);
                            normalStartEndTime.clear();
                                
                        } 
                    System.debug('availableStartEndTime:'+ availableStartEndTime);  
                    //If the activity startdatetime is less than businesshour of the technician, event should start from technician business hours. If the activity startdattiem is greater than the technician  business hr, event should start from activity starttime.
                    //Be careful whether client will send the activitydatetime in the given timezone.
                        
                    if((oEvent.ActivityDateTime).dateGMT() == tempdate && oEvent.ActivityDateTime > availableStartEndTime.get(0) && oEvent.ActivityDateTime < availableStartEndTime.get(1))
                    {
                        availableStartEndTime[0] = oEvent.ActivityDateTime;
                    }
                    else if((oEvent.ActivityDateTime).dateGMT() == tempdate && oEvent.ActivityDateTime > availableStartEndTime.get(0) && oEvent.ActivityDateTime > availableStartEndTime.get(1))
                    {
                        //if event drag and drop after working hours of technician, we have to goto next date. 
                        continue;
                    }
                                    
                    System.debug('availableStartEndTime***:'+ availableStartEndTime);
                    
                    List<StartEndTime> lstAvailableSlotsPerDay = new List<StartEndTime>();
                    if(!isOverlappingEnabled && SFSVMXStartEndTime != null && SFSVMXStartEndTime.size() > 0 && availableStartEndTime != null && availableStartEndTime.size() > 0)
                    {
                        lstAvailableSlotsPerDay = splitOnExistingEvents(availableStartEndTime,SFSVMXStartEndTime);
                    }
                    else
                    {
                        StartEndTime tempStartEndTime = new StartEndTime(availableStartEndTime.get(0),availableStartEndTime.get(1)); 
                        lstAvailableSlotsPerDay.add(tempStartEndTime);      
                    } 
                    
                    Integer SplitServiceDurationInSec; 
                    Integer WorkingHrDiffInSeconds;
                    Integer totaltimes; 
                                
                    for(StartEndTime availableSlot: lstAvailableSlotsPerDay)
                    {   
                        SplitServiceDurationInSec = 0;  
                        WorkingHrDiffInSeconds = 0; 
                        totaltimes = 0;     
                        WorkingHrDiffInSeconds = (Integer.valueOf((((availableSlot.endTime).getTime())/1000) - (((availableSlot.startTime).getTime())/1000)));
                        System.debug('WorkingHrDiffInSeconds:' + WorkingHrDiffInSeconds);
                        
                        SplitServiceDurationInSec = WorkingHrDiffInSeconds;     
                                
                        if(oEvent.SVMXC__Driving_Time__c > 0 || oEvent.SVMXC__Driving_Time_Home__c > 0 || oEvent.SVMXC__Overhead_Time_After__c > 0 || oEvent.SVMXC__Overhead_Time_Before__c >0 || oEvent.SVMXC__Break_Time_Total__c > 0)
                        {
                                                                
                            totaltimes = Integer.valueOf((oEvent.SVMXC__Driving_Time__c + oEvent.SVMXC__Driving_Time_Home__c + oEvent.SVMXC__Overhead_Time_After__c + oEvent.SVMXC__Overhead_Time_Before__c + oEvent.SVMXC__Break_Time_Total__c))*60;
                            System.debug('totaltimes:'+totaltimes);
                             //If user has drag and drop to LJS on just before the end of technician hrs, SplitServiceDurationInSec will get negative value if  they have drive,overhead times
                            if(SplitServiceDurationInSec > totaltimes) 
                                SplitServiceDurationInSec = SplitServiceDurationInSec - totaltimes;
                            else
                                continue;
                        }
                        temptotalServiceDuration = temptotalServiceDuration + SplitServiceDurationInSec;
                        System.debug('temptotalServiceDuration:'+temptotalServiceDuration); 
                        //This check is for last iteraton where technician working hrs are more what to schedule for LJS
                        if(temptotalServiceDuration > Integer.valueOf(oEvent.SVMXC__Service_Duration__c)) 
                        {
                            SplitServiceDurationInSec = SplitServiceDurationInSec-(temptotalServiceDuration - Integer.valueOf(oEvent.SVMXC__Service_Duration__c));
                            availableSlot.endTime = (availableSlot.startTime).addSeconds(SplitServiceDurationInSec + totaltimes);
                            System.debug('Inside loop SplitServiceDurationInSec:' + SplitServiceDurationInSec);
                        }
                                    
                        System.debug('SplitServiceDurationInSec: after'+SplitServiceDurationInSec);
                        if(SplitServiceDurationInSec >= eventMinDurationInseconds)
                        {
                            lstAESEvents.add(createEventWrapper(oEvent,availableSlot,SplitServiceDurationInSec,timeZone));
                        }
                        else
                        {
                            temptotalServiceDuration =  temptotalServiceDuration - SplitServiceDurationInSec;
                        }   
                        }
                    }   
                    
                    System.debug('lstAESEvents:' + lstAESEvents);
                    
                    for(Event AESevt: lstAESEvents)
                    { 
                        totalAESServiceDuration = totalAESServiceDuration + Double.valueOf(AESevt.SVMXC__Service_Duration__c);
                    }
                    System.debug('totalAESServiceDuration:' + totalAESServiceDuration);
                    tempremainderServiceDuration = Integer.valueOf(Double.valueOf(oEvent.SVMXC__Service_Duration__c) - totalAESServiceDuration)/60;
                    //returns only enddatetime of last event after splitting without updating to database when click on 'calculate' button
                    if(isCalculateEndTime) 
                    {
                        response = new AES_Response(null,String.valueOfGmt(lstAESEvents.get(lstAESEvents.size() -1).EndDateTime),String.valueOfGmt(lstAESEvents.get(0).StartDateTime),tempremainderServiceDuration,lstAESEvents.size(),null);
                        System.debug('response1:'+ response);
                    }
                    else
                    {
                        String deletedEvents;
                        DCON_Work_Order_WS.unassignAssign_WP eventdetails;
                        //When WO dispatch status is 'new', trying to assign LJS WO to technician
                        if(!IsUnAssignWorkOrder && !IsdeleteEvents && !((lstWorkOrders.get(0).SVMXC__Dispatch_Status__c).equalsIgnoreCase('Assigned')))
                        {
                            lstAESchildevts = DCON_Assign_Work_Order_To_MultiTech_WS2(UserId,lstWorkOrderIds,lsttechId.get(0),timezone,lstAESEvents,true,lstKeyValue); 
                        }
                        //when WO dispatch status is 'assigned', assigning WO to other technician without updating technician in WO and without deleting previous events
                        else if(!IsUnAssignWorkOrder && !IsdeleteEvents && (lstWorkOrders.get(0).SVMXC__Dispatch_Status__c).equalsIgnoreCase('Assigned'))
                        {   
                            lstAESchildevts = DCON_Create_Events_WS3(UserId,lstAESEvents,timeZone,lstKeyValue);
                        }
                        //when WO dispatch status is 'assigned', assigning WO to other technician updating technician in WO and deleting previous events
                        else if(IsUnAssignWorkOrder && IsdeleteEvents && (lstWorkOrders.get(0).SVMXC__Dispatch_Status__c).equalsIgnoreCase('Assigned'))
                        {   
                            eventdetails = DCON_UnAssignAssign_Work_Order_To_MultiTech_WS2(UserId,lstWorkOrderIds,lsttechId.get(0),timezone,lstAESEvents,true,lstKeyValue);
                            lstAESchildevts = eventdetails.techEventIds;
                            deletedEvents = eventdetails.deletedEvents;
                        }  
                        //when WO dispatch status is 'assigned', assigning WO to other technician with updating technician in WO and without deleting previous events
                        else if(IsUnAssignWorkOrder && !IsdeleteEvents && (lstWorkOrders.get(0).SVMXC__Dispatch_Status__c).equalsIgnoreCase('Assigned'))
                        {
                            lstAESchildevts = DCON_UnAssignAssign_Work_Order_To_MultiTech_WS3(UserId,lstWorkOrderIds,lsttechId.get(0),timezone,lstAESEvents,true,lstKeyValue);
                        }
                        System.debug('lstAESchildevts:' + lstAESchildevts);
                        response = new AES_Response(lstAESchildevts,null,null,tempremainderServiceDuration,lstAESchildevts.size(),deletedEvents);
                        System.debug('response:'+ response);
                    }   
                
                }
                //create single event when service duration is less than event minimum duration considering all options
                else
                {
                    list<StartEndTime> SFSVMXStartEndTime = new list<StartEndTime>(); 
                    Integer count1 = 0;
                    Date tempdate1 = (oEvent.ActivityDateTime).dateGMT();
                    //Retrieving the events from database for the days mentioned in setting('DCON005','SET009') when do not overlap with existing events
                    if(!isOverlappingEnabled)
                    {
                        //SFSVMXStartEndTime.clear();
                        List<Event> lstSFEvent = new  List<Event>();
                        List<SVMXC__SVMX_Event__c> lstSVMXEvent = new  List<SVMXC__SVMX_Event__c>(); 
                        Datetime STtoRetrieveEvents = DateTime.newInstanceGmt(tempdate1.addDays(-1),Time.newInstance(0,0,0,0));
                        Datetime ETtoRetrieveEvents = STtoRetrieveEvents.addDays(maxUnsuccessCalenderDays + 1);
                        lstSFEvent = getLstSFEventforTech(mapSFUSerTechId.keyset(), STtoRetrieveEvents, ETtoRetrieveEvents);
                        lstSVMXEvent = getLstSVMXEventforTech(mapSFUSerTechId.values(), STtoRetrieveEvents, ETtoRetrieveEvents);
                        SFSVMXStartEndTime = mergeSFSVMXEvents(lstSFEvent, lstSVMXEvent, timeZone);
                        //lstSFEvent.clear();  //If everything is working fine uncomment this and test again
                        //lstSVMXEvent.clear();
                    }
                    for(Date tempdate = (oEvent.ActivityDateTime).dateGMT(); count1 < maxUnsuccessCalenderDays && lstAESEvents.size() < 1; tempdate = tempdate.addDays(1))
                    {
                        count1++;
                        list<datetime> availableStartEndTime = new list<datetime>();
                        if(isTechWorkingHrsEnabled && isMachineWorkingHrsEnabled)
                        {
                            List<Datetime> techWorkingHRStartEndTime = new List<Datetime>();
                            List<Datetime> machineAccessHrStartEndTime = new List<Datetime>();
                            List<Datetime> IntersectOfTechMachineAccessHr = new List<Datetime>();
                            List<datetime> OverlapTimeOfTechMachineAccessHrs = new List<Datetime>();
                            Integer techWorkingHRs = 0;
                            Integer machineAccessibleHRs = 0;
                            
                            OverlapTimeOfTechMachineAccessHrs.clear();
                            techWorkingHRStartEndTime.clear();
                            machineAccessHrStartEndTime.clear();
                            IntersectOfTechMachineAccessHr.clear();
                            
                            if((!GetHolidays(techBusinessHrMap.get(lsttechId.get(0)),tempdate)) && (!GetHolidays(machineAccessHrs,tempdate)))
                            {
                                System.debug('tempdate:'+tempdate);
                                techWorkingHRStartEndTime = dcUtils.getBHStartEndDateTime(timeZone,tempdate,techBusinessHrMap.get(lsttechId.get(0)));
                                machineAccessHrStartEndTime = dcUtils.getBHStartEndDateTime(timeZone,tempdate,machineAccessHrs);
                                
                                techWorkingHRs = (Integer.valueOf((((techWorkingHRStartEndTime.get(1)).getTime())/1000) - (((techWorkingHRStartEndTime.get(0)).getTime())/1000)))/3600;
                                
                                machineAccessibleHRs = (Integer.valueOf((((machineAccessHrStartEndTime.get(1)).getTime())/1000) - (((machineAccessHrStartEndTime.get(0)).getTime())/1000)))/3600;
                                
                                if(techWorkingHRs == 24 && machineAccessibleHRs < 24)
                                {
                                    OverlapTimeOfTechMachineAccessHrs.addAll(machineAccessHrStartEndTime);  
                                }
                                else if(techWorkingHRs < 24 && machineAccessibleHRs == 24)
                                {
                                    OverlapTimeOfTechMachineAccessHrs.addAll(techWorkingHRStartEndTime);        
                                }
                                else if(techWorkingHRs == 24 && machineAccessibleHRs == 24) 
                                {
                                    OverlapTimeOfTechMachineAccessHrs.add(DateTime.newInstanceGmt(tempdate,Time.newInstance(0,0,0,0))); 
                                    OverlapTimeOfTechMachineAccessHrs.add(DateTime.newInstanceGmt(tempdate.addDays(1),Time.newInstance(0,0,0,0)));  
                                }   
                                else if(techWorkingHRs < 24 && machineAccessibleHRs < 24)   
                                {
                                    //calling method to get overlapping timings 
                                    OverlapTimeOfTechMachineAccessHrs= overlappingTimeSlots(techWorkingHRStartEndTime,machineAccessHrStartEndTime); 
                                }
                                
                                if(OverlapTimeOfTechMachineAccessHrs != null && OverlapTimeOfTechMachineAccessHrs.size() > 0)
                                {
                                    availableStartEndTime.addAll(OverlapTimeOfTechMachineAccessHrs);
                                }   
                                else
                                {   
                                    continue;
                                }                                   
                            }
                            else
                            {
                                continue;   
                            }   
                        
                        }
                        else if(isTechWorkingHrsEnabled && !isMachineWorkingHrsEnabled)
                        {
                            List<Datetime> techWorkingHRStartEndTime = new List<Datetime>();
                            techWorkingHRStartEndTime.clear();
                            
                            //checking the given date is holiday. If it is holiday, goto next date.
                            if(!GetHolidays(techBusinessHrMap.get(lsttechId.get(0)),tempdate))
                            {
                                System.debug('tempdate:'+tempdate);
                                techWorkingHRStartEndTime = dcUtils.getBHStartEndDateTime(timeZone,tempdate,techBusinessHrMap.get(lsttechId.get(0)));
                                availableStartEndTime.addAll(techWorkingHRStartEndTime);
                            }
                            else
                            {
                                continue;   
                            }   
                        
                        }
                        else if(!isTechWorkingHrsEnabled && isMachineWorkingHrsEnabled)
                        {
                            List<Datetime> machineAccessHrStartEndTime = new List<Datetime>();
                            machineAccessHrStartEndTime.clear();
                            
                            //checking the given date is holiday. If it is holiday, goto next date.
                            if(!GetHolidays(machineAccessHrs,tempdate))
                            {
                                System.debug('tempdate:'+tempdate);
                                machineAccessHrStartEndTime = dcUtils.getBHStartEndDateTime(timeZone,tempdate,machineAccessHrs);
                                System.debug('machineAccessHrStartEndTime***:'+ machineAccessHrStartEndTime);
                                availableStartEndTime.addAll(machineAccessHrStartEndTime);
                            }
                            else
                            {
                                continue;   
                            }   
                        }   
                        else if(!isTechWorkingHrsEnabled && !isMachineWorkingHrsEnabled)
                        {
                            List<datetime> normalStartEndTime = new List<datetime>();
                            normalStartEndTime.add(DateTime.newInstanceGmt(tempdate,Time.newInstance(0,0,0,0))); 
                            normalStartEndTime.add(DateTime.newInstanceGmt(tempdate.addDays(1),Time.newInstance(0,0,0,0))); 
                            availableStartEndTime.addAll(normalStartEndTime);
                            normalStartEndTime.clear();
                                
                        } 
                        System.debug('availableStartEndTime:'+ availableStartEndTime);  
                        //If the activity startdatetime is less than businesshour of the technician, event should start from technician business hours. If the activity startdattiem is greater than the technician  business hr, event should start from activity starttime.
                        //Be careful whether client will send the activitydatetime in the given timezone.
                            
                        if((oEvent.ActivityDateTime).dateGMT() == tempdate && oEvent.ActivityDateTime > availableStartEndTime.get(0) && oEvent.ActivityDateTime < availableStartEndTime.get(1))
                        {
                            availableStartEndTime[0] = oEvent.ActivityDateTime;
                        }
                        else if((oEvent.ActivityDateTime).dateGMT() == tempdate && oEvent.ActivityDateTime > availableStartEndTime.get(0) && oEvent.ActivityDateTime > availableStartEndTime.get(1))
                        {
                            //if event drag and drop after working hours of technician, we have to goto next date. 
                            continue;
                        }
                                    
                        System.debug('availableStartEndTime***:'+ availableStartEndTime);
                        
                        List<StartEndTime> lstAvailableSlotsPerDay = new List<StartEndTime>();
                        if(!isOverlappingEnabled && SFSVMXStartEndTime != null && SFSVMXStartEndTime.size() > 0 && availableStartEndTime != null && availableStartEndTime.size() > 0)
                        {
                            lstAvailableSlotsPerDay = splitOnExistingEvents(availableStartEndTime,SFSVMXStartEndTime);
                        }
                        else
                        {
                            StartEndTime tempStartEndTime = new StartEndTime(availableStartEndTime.get(0),availableStartEndTime.get(1)); 
                            lstAvailableSlotsPerDay.add(tempStartEndTime);      
                        } 
                    
                        Integer SplitServiceDurationInSec; 
                        Integer WorkingHrDiffInSeconds;
                        Integer totaltimes; 
                                    
                        for(StartEndTime availableSlot: lstAvailableSlotsPerDay)
                        {   
                            SplitServiceDurationInSec = 0;  
                            WorkingHrDiffInSeconds = 0; 
                            totaltimes = 0;     
                            WorkingHrDiffInSeconds = (Integer.valueOf((((availableSlot.endTime).getTime())/1000) - (((availableSlot.startTime).getTime())/1000)));
                            System.debug('WorkingHrDiffInSeconds:' + WorkingHrDiffInSeconds);
                            
                            SplitServiceDurationInSec = WorkingHrDiffInSeconds;     
                                    
                            if(oEvent.SVMXC__Driving_Time__c > 0 || oEvent.SVMXC__Driving_Time_Home__c > 0 || oEvent.SVMXC__Overhead_Time_After__c > 0 || oEvent.SVMXC__Overhead_Time_Before__c >0 || oEvent.SVMXC__Break_Time_Total__c > 0)
                            {
                                                                    
                                totaltimes = Integer.valueOf((oEvent.SVMXC__Driving_Time__c + oEvent.SVMXC__Driving_Time_Home__c + oEvent.SVMXC__Overhead_Time_After__c + oEvent.SVMXC__Overhead_Time_Before__c + oEvent.SVMXC__Break_Time_Total__c))*60;
                                System.debug('totaltimes:'+totaltimes);
                                 //If user has drag and drop to AES on just before the end of technician hrs, SplitServiceDurationInSec will get negative value if  they have drive,overhead times
                                if(SplitServiceDurationInSec > totaltimes) 
                                    SplitServiceDurationInSec = SplitServiceDurationInSec - totaltimes;
                                else
                                    continue;
                            }
                            if(SplitServiceDurationInSec >= Integer.valueof(oEvent.SVMXC__Service_Duration__c))
                            {
                                SplitServiceDurationInSec = Integer.valueof(oEvent.SVMXC__Service_Duration__c);
                                availableSlot.endTime = (availableSlot.startTime).addSeconds(SplitServiceDurationInSec + totaltimes);
                                System.debug('Inside loop SplitServiceDurationInSec:' + SplitServiceDurationInSec);System.debug('SplitServiceDurationInSec##:'+SplitServiceDurationInSec); 
                                lstAESEvents.add(createEventWrapper(oEvent,availableSlot,SplitServiceDurationInSec,timeZone));                          
                            }   
                            else
                            {
                                continue;
                            }
                            
                        }
                    }      
    
                    if(lstAESEvents != null && lstAESEvents.size() > 0)
                    {
                         if(isCalculateEndTime) 
                        {
                            response = new AES_Response(null,String.valueOfGmt(lstAESEvents.get(lstAESEvents.size() -1).EndDateTime),String.valueOfGmt(lstAESEvents.get(0).StartDateTime),tempremainderServiceDuration,lstAESEvents.size(),null);
                            System.debug('response1:'+ response);
                        }
                        else
                        {
                            String deletedEvents;
                            DCON_Work_Order_WS.unassignAssign_WP eventdetails;
                            if(!IsUnAssignWorkOrder && !IsdeleteEvents && !((lstWorkOrders.get(0).SVMXC__Dispatch_Status__c).equalsIgnoreCase('Assigned')))
                            {
                                lstAESchildevts = DCON_Assign_Work_Order_To_MultiTech_WS2(UserId,lstWorkOrderIds,lsttechId.get(0),timezone,lstAESEvents,true,lstKeyValue); 
                            }
                            else if(!IsUnAssignWorkOrder && !IsdeleteEvents && (lstWorkOrders.get(0).SVMXC__Dispatch_Status__c).equalsIgnoreCase('Assigned'))
                            {   
                                lstAESchildevts = DCON_Create_Events_WS3(UserId,lstAESEvents,timeZone,lstKeyValue);
                            }
                            else if(IsUnAssignWorkOrder && IsdeleteEvents && (lstWorkOrders.get(0).SVMXC__Dispatch_Status__c).equalsIgnoreCase('Assigned'))
                            {   
                                eventdetails = DCON_UnAssignAssign_Work_Order_To_MultiTech_WS2(UserId,lstWorkOrderIds,lsttechId.get(0),timezone,lstAESEvents,true,lstKeyValue);
                                lstAESchildevts = eventdetails.techEventIds;
                                deletedEvents = eventdetails.deletedEvents;
                            }   
                            else if(IsUnAssignWorkOrder && !IsdeleteEvents && (lstWorkOrders.get(0).SVMXC__Dispatch_Status__c).equalsIgnoreCase('Assigned'))
                            {
                                lstAESchildevts = DCON_UnAssignAssign_Work_Order_To_MultiTech_WS3(UserId,lstWorkOrderIds,lsttechId.get(0),timezone,lstAESEvents,true,lstKeyValue);
                            }
                            System.debug('lstAESchildevts:' + lstAESchildevts);
                            response = new AES_Response(lstAESchildevts,null,null,tempremainderServiceDuration,lstAESchildevts.size(),deletedEvents);
                            System.debug('response:'+ response);
                        }  
                    }
                    else
                    {
                        throw new SVMXException('DCON005_TAG066');   
                    }   
                }
            }
                 
        } 
        catch(DmlException ex)
        {
            Database.rollback(sp);
            throw new SVMXException(ex.getDmlMessage(0));
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            system.debug('Main error list - Long Job Scheduling');
            system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getMessage());
        }
        return response;
    }
        
    /**
     * Name             :   createEventWrapper
     * Params           :   Event oEvent
                            StartEndTime eventStartEndTime 
                            Integer serviceDuration 
                            String timezone
     * Returns          :   Event
     * Description      :   returns event details in timezone send by client. In DCON_Event_WS class, it will converted to GMT while updating to Database 
     */
    public static  Event createEventWrapper(Event oEvent,StartEndTime eventStartEndTime, Integer serviceDuration, String timezone) 
    {
        Event tempAESEvent = new Event();
        tempAESEvent.ActivityDate = (eventStartEndTime.startTime).dateGMT();
        tempAESEvent.ActivityDateTime = eventStartEndTime.startTime;
        tempAESEvent.StartDateTime = eventStartEndTime.startTime;
        tempAESEvent.Subject = oEvent.Subject;
        tempAESEvent.Description = oEvent.Description;
        tempAESEvent.IsAllDayEvent = false;
        tempAESEvent.type = oEvent.type;
        tempAESEvent.WhatId = oEvent.WhatId;
        tempAESEvent.OwnerId = oEvent.OwnerId;
        tempAESEvent.DurationInMinutes = Integer.valueOf(((((eventStartEndTime.endTime).getTime())/1000) - (((eventStartEndTime.startTime).getTime())/1000))/60);
        tempAESEvent.Location = oEvent.Location;
        tempAESEvent.EndDateTime = (tempAESEvent.StartDateTime).addMinutes(tempAESEvent.DurationInMinutes);
        tempAESEvent.SVMXC__Service_Duration__c = serviceDuration;
        tempAESEvent.SVMXC__Driving_Time__c = oEvent.SVMXC__Driving_Time__c;
        tempAESEvent.SVMXC__Overhead_Time_Before__c = oEvent.SVMXC__Overhead_Time_Before__c;
        tempAESEvent.SVMXC__Overhead_Time_After__c = oEvent.SVMXC__Overhead_Time_After__c;
        tempAESEvent.SVMXC__Driving_Time_Home__c = oEvent.SVMXC__Driving_Time_Home__c;
        tempAESEvent.SVMXC__Break_Time_Total__c = oEvent.SVMXC__Break_Time_Total__c;
        //System.debug('tempAESEvent:'+tempAESEvent);
        return tempAESEvent;
    }
    
    /**
     * Name             :   Retrieve_Tech_Working_Details
     * Params           :   Set<String> setTechId
     * Returns          :   Map<Id, BusinessHours>   - technician Id with Business Hours
     * Description      :   returns technician Id associated BusinessHours based on hierarchy
     */
    public static Map<Id, BusinessHours> Retrieve_Tech_Working_Details(Set<String> setTechId)
    {
        Map<Id, BusinessHours> techBHMap = new Map<Id, BusinessHours>();  
        if (setTechId.size() > 0 && setTechId != NULL)
        {
            Set<String> tech_t = new Set<string>(); 
            set<String> tech_businesshr_Ids = new set<String>();
            
            for(SVMXC__Service_Group_Members__c tech: [Select Id, SVMXC__Service_Territory__c, SVMXC__Working_Hours__c, SVMXC__Break_Hours__c From SVMXC__Service_Group_Members__c where Id IN : setTechId])
            {
                if(tech.SVMXC__Service_Territory__c != null)              
                    tech_t.add(tech.SVMXC__Service_Territory__c);
                if(tech.SVMXC__Working_Hours__c != null)  
                    tech_businesshr_Ids.add(tech.SVMXC__Working_Hours__c);             
            }
            
            System.debug('tech_t:' + tech_t);
            System.debug('tech_businesshr_Ids' + tech_businesshr_Ids);
                       
            Map<Id,Id> territory_businesshrs = new Map<Id,Id>();
            Map<Id,SVMXC__Territory__c> techTerritory = new Map<Id,SVMXC__Territory__c>();
            //retrieving territory details of technicians if technicians don't have active working hours
            for(SVMXC__Territory__c lstterritory : Database.Query('Select SVMXC__Territory_s_Business_Hours__c,SVMXC__Territory_s_Business_Hours__r.IsActive, Id From SVMXC__Territory__c where Id IN :tech_t and SVMXC__Territory_s_Business_Hours__r.IsActive = true')) 
            {
                if(lstterritory.SVMXC__Territory_s_Business_Hours__c != null)
                {
                    tech_businesshr_Ids.add(lstterritory.SVMXC__Territory_s_Business_Hours__c);   
                }
                territory_businesshrs.put(lstterritory.Id,lstterritory.SVMXC__Territory_s_Business_Hours__c);
            }
            tech_t.clear();
            System.debug('tech_businesshr_Ids after territory' + tech_businesshr_Ids);
            
            Map<Id,BusinessHours> lstbusinesshrs = new Map<Id,BusinessHours>();  
            Set<Id> active_Businesshrs = new Set<Id>(); 
            for(BusinessHours lstbh :Database.Query('SELECT WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime,TimeZoneSidKey from BusinessHours where Id IN : tech_businesshr_Ids and IsActive = true')) 
            {
                lstbusinesshrs.put(lstbh.Id,lstbh);
                active_Businesshrs.add(lstbh.Id);
            }
            tech_businesshr_Ids.clear();
            System.debug('active_Businesshrs:' + active_Businesshrs);
                           
            //retrieving default businesshour if techinician and technician territory doesn't have active working hours.
            BusinessHours default_businesshr = [SELECT WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime,TimeZoneSidKey from BusinessHours where IsDefault = true and IsActive = true];
            System.debug('lstbusinesshrs:' + lstbusinesshrs);
            BusinessHours temp_Businesshr;
            
            //loop to retrieve each technician with technician Id, workinghours Id.
            for(SVMXC__Service_Group_Members__c tech: [Select Id, SVMXC__Service_Territory__c, SVMXC__Working_Hours__c, SVMXC__Break_Hours__c From SVMXC__Service_Group_Members__c where Id IN : setTechId])
            {
                if(tech.SVMXC__Working_Hours__c!=null && active_Businesshrs.contains(tech.SVMXC__Working_Hours__c))
                {
                    temp_Businesshr = lstbusinesshrs.get(tech.SVMXC__Working_Hours__c);
                }
                else if(tech.SVMXC__Service_Territory__c!=null && territory_businesshrs.containsKey(tech.SVMXC__Service_Territory__c) && territory_businesshrs.get(tech.SVMXC__Service_Territory__c)!=null) 
                {
                    temp_Businesshr = lstbusinesshrs.get(territory_businesshrs.get(tech.SVMXC__Service_Territory__c));
                }
                else
                {
                    temp_Businesshr = default_businesshr;
                }
                techBHMap.put(tech.Id,temp_Businesshr);
                temp_Businesshr = null;
            }
            territory_businesshrs.clear();
            active_Businesshrs.clear();
            default_businesshr = null;
        }
        System.debug('techBHMap:' + techBHMap);   
        return techBHMap;
    }
    /*
    public static Map<Id,BusinessHours> Retrieve_Tech_Break_Details(Set<String> setTechId)
    {
        Map<Id,BusinessHours> techBreakHrsMap = new Map<Id,BusinessHours>();
        if (setTechId.size() > 0 && setTechId != NULL)
        {
            set<String> tech_breakhr_Ids = new set<String>();
            
            for(SVMXC__Service_Group_Members__c tech: [Select Id, SVMXC__Service_Territory__c, SVMXC__Working_Hours__c, SVMXC__Break_Hours__c From SVMXC__Service_Group_Members__c where Id IN : setTechId])
            {
                If(tech.SVMXC__Break_Hours__c != null)    
                    tech_breakhr_Ids.add(tech.SVMXC__Break_Hours__c);
            }
            
            //System.debug('tech_breakhr_Ids' + tech_breakhr_Ids);
        
            Set<Id> active_Breakhrs = new Set<Id>();
            Map<Id,BusinessHours> lstbreakhrs = new Map<Id,BusinessHours>();
            for(BusinessHours lstbh :Database.Query('SELECT WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime,TimeZoneSidKey from BusinessHours where Id IN : tech_breakhr_Ids and IsActive = true')) 
            {
                active_Breakhrs.add(lstbh.Id);
                lstbreakhrs.put(lstbh.Id,lstbh);
            }
            //System.debug('active_Breakhrs:' + active_Breakhrs);
            tech_breakhr_Ids.clear();
                
            BusinessHours temp_break_ID;
            //loop to retrieve each technician with technician Id, workinghours Id, breakhours Id.
            for(SVMXC__Service_Group_Members__c tech: [Select Id, SVMXC__Service_Territory__c, SVMXC__Working_Hours__c, SVMXC__Break_Hours__c From SVMXC__Service_Group_Members__c where Id IN : setTechId])
            {                  
                if(tech.SVMXC__Break_Hours__c!=null && active_Breakhrs.contains(tech.SVMXC__Break_Hours__c))    
                {
                    temp_break_ID = lstbreakhrs.get(tech.SVMXC__Break_Hours__c);   
                }
                else
                {
                    temp_break_ID = null;   
                }
                techBreakHrsMap.put(tech.Id, temp_break_ID);
                temp_break_ID = null; 
            }
            active_Breakhrs.clear();
        }
        //System.debug('techBreakHrsMap:'+techBreakHrsMap);     
        return techBreakHrsMap; 
    } */
    /**
     * Name             :   GetHolidays
     * Params           :   BusinessHours bh
                            Date givendate
     * Returns          :   Boolean
     * Description      :   return whether given date is holiday or not based on given BusinessHours
     */
    public static Boolean GetHolidays(BusinessHours bh, Date givendate)
    {
        Boolean isHoliday = false;
        if(givendate != null && bh != null)
        {
            Datetime dtmDayStartDateTime = dcUtils.getDateTimeInTimezone(givendate, Time.newInstance(0, 0, 0, 0), bh.timeZoneSidKey);
                  
            // Get the next working date time with respect to the given day's start
            Datetime dtmNextWkgDateTime = BusinessHours.addGmt(bh.id, dtmDayStartDateTime, 1L);
                
            // Get the date of the next working date time in the given time zone
            Date datNextWkgDate = Date.valueOf(dtmNextWkgDateTime.format('yyyy-MM-dd', bh.timeZoneSidKey));
              
            // If the given date and next working date are the same, the given day is a working day else given day is Holiday
            if(datNextWkgDate != givendate)
                isHoliday = true;
        }
        
        return isHoliday;
    }
    
    /**
     * Name             :   getLstSFEventforTech
     * Params           :   set<string> lstOwnerID
                            DateTime inputStartTime
                            DateTime inputEndTime
     * Returns          :   list<event>
     * Description      :   Get List of  SF Event for Tech within the time range in sorted order
     */
    public static list<event> getLstSFEventforTech(set<string> lstOwnerID, DateTime inputStartTime, DateTime inputEndTime)
    {
        //Following Scenarios are considered for checking Double booking
        // events that "end" during the input event's start and end time, 
        // events that "start" during the input event's start and end time
        // events that "start" before input event's start time and "end" after input event's end time
        // events that "start" within the input event's start and end time including fully overlapped events
          
        date inputStartdate = inputStartTime.dateGMT();
        date inputEndtdate = inputEndTime.dateGMT();
        System.debug('inputStartdate:  '+inputStartdate);
        datetime inputStartdatetime = Datetime.newInstanceGmt(inputStartTime.dateGMT(),Time.newInstance(0, 0, 0, 0));
        System.debug('inputStartdatetime : '+inputStartdatetime); 
        
        //Get list of Events for Tech within the time range inputStartTime and inputEndtdate with additional validation for All-Day events retival i.e. using ActivityDate instead of StartDateTime and in EndDateTime & inputStartdatetime time component is (0,0,0,0) (should be in All-day events)
        return([Select Id, WhatId,ActivityDateTime,OwnerId, EndDateTime, DurationInMinutes,IsAllDayEvent,ActivityDate,StartDatetime  from Event where (OwnerId in:lstOwnerID) AND ((StartDateTime <= :inputEndTime and EndDateTime >= :inputStartTime)OR (ActivityDate <= :inputEndtdate and EndDateTime >= :inputStartdatetime AND IsAllDayEvent = true ) OR(ActivityDate = :inputStartdate AND IsAllDayEvent = true)) order by StartDateTime]) ; 
    }
    
    /**
     * Name             :   getLstSVMXEventforTech
     * Params           :   set<string> lstOwnerID
                            DateTime inputStartTime
                            DateTime inputEndTime
     * Returns          :   list<SVMXC__SVMX_Event__c>
     * Description      :   Get List of  SVMX Event for Tech within the time range inputStartTime and inputEndtdate in sorted order
     */
    public static list<SVMXC__SVMX_Event__c> getLstSVMXEventforTech(list<string> lstOwnerID,DateTime inputStartTime, DateTime inputEndTime)
    {
        //Following Scenarios are considered for checking Double booking
        // events that "end" during the input event's start and end time, 
        // events that "start" during the input event's start and end time
        // events that "start" before input event's start time and "end" after input event's end time
        // events that "start" within the input event's start and end time including fully overlapped events
        
        System.debug('inputStartTime : '+inputStartTime +'   '+ inputEndTime+'  '+lstOwnerID); 
        date inputStartdate = inputStartTime.dateGMT();
        date inputEnddate = inputEndTime.dateGMT();
        
        datetime inputStartdatetime = Datetime.newInstanceGmt(inputStartTime.dateGMT(),Time.newInstance(0, 0, 0, 0));
        System.debug('inputStartdatetime : '+inputStartdatetime); 
        
        return([Select Id,SVMXC__DurationInMinutes__c, SVMXC__WhatId__c,SVMXC__Technician__c, SVMXC__ActivityDate__c,SVMXC__ActivityDateTime__c,SVMXC__EndDateTime__c,SVMXC__StartDateTime__c,SVMXC__IsAllDayEvent__c from SVMXC__SVMX_Event__c where (SVMXC__Technician__c in:lstOwnerID) AND ((SVMXC__StartDateTime__c <= :inputEndTime and SVMXC__EndDateTime__c >= :inputStartTime)OR (SVMXC__ActivityDate__c <= :inputEnddate and SVMXC__EndDateTime__c >= :inputStartdatetime AND SVMXC__IsAllDayEvent__c = true) OR(SVMXC__StartDateTime__c = :inputStartdatetime AND SVMXC__IsAllDayEvent__c = true)) order by SVMXC__StartDateTime__c]); 
    }
    /**
     * Name             :   mergeSFSVMXEvents
     * Params           :   List<Event> lstEvents
                            List<SVMXC__SVMX_Event__c> lstSVMXEvents
                            String timeZone
     * Returns          :   list<StartEndTime>
     * Description      :   Merges SFEvent and SVMXEvent start & end datetime based on ascending order
     */
    public static list<StartEndTime> mergeSFSVMXEvents(List<Event> lstEvents, List<SVMXC__SVMX_Event__c> lstSVMXEvents, String timeZone)
    {
        List<StartEndTime> lstSFEventStartEndTime = new List<StartEndTime>();
        List<StartEndTime> lstSVMXEventStartEndTime = new List<StartEndTime>();
        List<StartEndTime> lstdates = new List<StartEndTime>();
        if((lstEvents != null && lstEvents.size() > 0) || (lstSVMXEvents != null && lstSVMXEvents.size() >0))
        { 
            System.debug('lstEvents:'+ lstEvents);
            System.debug('lstSVMXEvents:'+ lstSVMXEvents);
        //Note: If event is All day Event irrespective of timezone, it will display in gantt same date without shifting. 
        if(lstEvents != null && lstEvents.size() > 0)   
        {   
            for(Event sfevt: lstEvents)
            {
                if(sfevt.IsAllDayEvent) 
                {
                    StartEndTime tempdate = new StartEndTime(sfevt.StartDateTime,(sfevt.StartDateTime).addMinutes(Integer.valueOf(sfevt.DurationInMinutes)));   
                    lstSFEventStartEndTime.add(tempdate);
                }
                else
                {   
                    Datetime startDatetime = dcUtils.doTZConversion(sfevt.StartDateTime, 'GMT', timeZone);  
                    Datetime endDatetime = dcUtils.doTZConversion((sfevt.StartDateTime).addMinutes(Integer.valueOf(sfevt.DurationInMinutes)), 'GMT', timeZone); 
                    StartEndTime tempdate = new StartEndTime(startDatetime,endDatetime);
                    lstSFEventStartEndTime.add(tempdate);
                }   
            }
        }   
        System.debug('lstSFEventStartEndTime:' + lstSFEventStartEndTime);
        if(lstSVMXEvents != null && lstSVMXEvents.size() > 0)   
        {
            for(SVMXC__SVMX_Event__c svmxevt: lstSVMXEvents)
            {
                if(svmxevt.SVMXC__IsAllDayEvent__c)   
                {
                    StartEndTime tempdate = new StartEndTime(svmxevt.SVMXC__StartDateTime__c,(svmxevt.SVMXC__StartDateTime__c).addMinutes(Integer.valueOf(svmxevt.SVMXC__DurationInMinutes__c))); 
                    lstSVMXEventStartEndTime.add(tempdate);
                    
                }
                else
                {   
                    Datetime startDatetime = dcUtils.doTZConversion(svmxevt.SVMXC__StartDateTime__c, 'GMT', timeZone);  
                    Datetime endDatetime = dcUtils.doTZConversion((svmxevt.SVMXC__StartDateTime__c).addMinutes(Integer.valueOf(svmxevt.SVMXC__DurationInMinutes__c)), 'GMT', timeZone); 
                    StartEndTime tempdate = new StartEndTime(startDatetime,endDatetime);
                    lstSVMXEventStartEndTime.add(tempdate);
                }   
            }
        }   
        System.debug('lstSVMXEventStartEndTime:' + lstSVMXEventStartEndTime);
        
        Integer i = 0, j = 0, k = 0;
        
        if((lstSFEventStartEndTime != null && lstSFEventStartEndTime.size()>0) || (lstSVMXEventStartEndTime != null && lstSVMXEventStartEndTime.size()>0))
        {   
            while(i < lstSFEventStartEndTime.size() && j < lstSVMXEventStartEndTime.size())
            {
                if (lstSFEventStartEndTime[i].starttime < lstSVMXEventStartEndTime[j].starttime)
                {
                    StartEndTime tempdate = new StartEndTime(lstSFEventStartEndTime[i].starttime,lstSFEventStartEndTime[i].endtime);
                    lstdates.add(tempdate);
                    i++;
                }
                else
                {
                    StartEndTime tempdate = new StartEndTime(lstSVMXEventStartEndTime[j].starttime,lstSVMXEventStartEndTime[j].endtime);
                    lstdates.add(tempdate);
                    j++;
                }
                System.debug('lstdates:'+lstdates);
            }
            
            while (i < lstSFEventStartEndTime.size())
            {
                StartEndTime tempdate = new StartEndTime(lstSFEventStartEndTime[i].starttime,lstSFEventStartEndTime[i].endtime);
                System.debug('tempdate1:'+tempdate);
                lstdates.add(tempdate);
                i++;
            }
            
            while (j < lstSVMXEventStartEndTime.size())
            {
                StartEndTime tempdate = new StartEndTime(lstSVMXEventStartEndTime[j].starttime,lstSVMXEventStartEndTime[j].endtime);
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
                StartEndTime tempdate = new StartEndTime(lstSFEventStartEndTime[i].starttime,lstSFEventStartEndTime[i].endtime);
                lstdates.add(tempdate);
                i++;    
            }
        }
        else if((lstSFEventStartEndTime.isEmpty() && lstSFEventStartEndTime.size() == 0) && (lstSVMXEventStartEndTime != null && lstSVMXEventStartEndTime.size() > 0))
        {
            System.debug(' in SVMX  check');
            while(i < lstSVMXEventStartEndTime.size())
            {
                StartEndTime tempdate = new StartEndTime(lstSVMXEventStartEndTime[i].starttime,lstSVMXEventStartEndTime[i].endtime);
                lstdates.add(tempdate);
                i++;    
            }
        }
        }
        return lstdates;
    }
    /**
     * Name             :   splitOnExistingEvents
     * Params           :   List<datetime> avaliableslotperday
                            list<StartEndTime> eventsStartEndTime
     * Returns          :   list<StartEndTime>
     * Description      :   Splitting events among existing events without overlapping
     */
    public static list<StartEndTime> splitOnExistingEvents(List<datetime> avaliableslotperday, 
                                                        list<StartEndTime> eventsStartEndTime)
    {
        List<datetime> tempAvaliableslotperday = new List<datetime>();
        tempAvaliableslotperday.addAll(avaliableslotperday);
        List<StartEndTime> lstAvailableSlotsPerDay = new List<StartEndTime>();
        
        //This for loop will go through muliple events in a single day
        for(StartEndTime dt: eventsStartEndTime)
        {
            //outer if condition1 - will go inside only if availableslot endtime is greater than availableSlot start time
            //Outer if condition2 - will go inside the loop only if any of start date or end date of event matches with availableslot start date or end date && any event start before availableslot startdate and ends after availableslot enddate
            //logic - going through events and updating available slots accordingly until available slot starttime reaches available slot endtime 
            //inner if conditions - will check all possible cases of overlapping events and shifts availableslot to after events
            
            if(avaliableslotperday.get(0) < avaliableslotperday.get(1))
            { 
                if(((dt.startTime).dateGMT() == (avaliableslotperday.get(0)).dateGMT()) || 
                ((dt.startTime).dateGMT() == (avaliableslotperday.get(1)).dateGMT()) || 
                ((dt.endTime).dateGMT() == (avaliableslotperday.get(0)).dateGMT()) || 
                ((dt.endTime).dateGMT() == (avaliableslotperday.get(1)).dateGMT()) ||
                (dt.startTime < avaliableslotperday.get(0) && dt.endTime > avaliableslotperday.get(0)))
                {
                    System.debug('technician available slots:' + avaliableslotperday);
                    System.debug('Event detials:' + dt);
                    
                    if(((avaliableslotperday.get(0) >= dt.startTime) && 
                        (avaliableslotperday.get(0) <= dt.endTime)) && 
                        ((avaliableslotperday.get(1) >= dt.startTime) && 
                        (avaliableslotperday.get(1) <= dt.endTime)))
                    {
                        avaliableslotperday[0] = dt.endTime;
                        System.debug('loop');
                        System.debug('technician start time 0:'+ avaliableslotperday);
                    }
                    if(((avaliableslotperday.get(0) >= dt.startTime) && 
                        (avaliableslotperday.get(0) <= dt.endTime)) && 
                        ((avaliableslotperday.get(1) >= dt.startTime) && 
                        (avaliableslotperday.get(1) >= dt.endTime)))
                    {
                        avaliableslotperday[0] = dt.endTime;
                        System.debug('loop1');
                        System.debug('technician start time 1:'+ avaliableslotperday);
                    }
                    if(((avaliableslotperday.get(0) <= dt.startTime) && 
                        (avaliableslotperday.get(0) <= dt.endTime)) && 
                        ((avaliableslotperday.get(1) >= dt.startTime) && 
                        (avaliableslotperday.get(1) >= dt.endTime)))
                    {
                        DCON_AES_Event_WS.StartEndTime tempdate1 = new DCON_AES_Event_WS.StartEndTime(avaliableslotperday.get(0),dt.startTime);
                        avaliableslotperday[0] = dt.endTime;
                        lstAvailableSlotsPerDay.add(tempdate1);
                        System.debug('loop2');
                        System.debug('technician start time 2:'+ avaliableslotperday + tempdate1);
                    }
                    if(((avaliableslotperday.get(0) <= dt.startTime) && 
                        (avaliableslotperday.get(0) <= dt.endTime)) && 
                        ((avaliableslotperday.get(1) >= dt.startTime) && 
                        (avaliableslotperday.get(1) <= dt.endTime)))
                    {
                        DCON_AES_Event_WS.StartEndTime tempdate1 = new DCON_AES_Event_WS.StartEndTime(avaliableslotperday.get(0),dt.startTime);
                        avaliableslotperday[0] = dt.endTime;
                        lstAvailableSlotsPerDay.add(tempdate1);
                        System.debug('loop3');
                        System.debug('technician start time 3:'+ avaliableslotperday + tempdate1);
                    }
                }
            }
        }
        System.debug('lstAvailableSlotsPerDay:'+ lstAvailableSlotsPerDay);
        
        //If loop - if no events are there in particular day, technician working hours will be the available slot
        if(avaliableslotperday.get(0) == tempAvaliableslotperday.get(0) && 
            avaliableslotperday.get(1) == tempAvaliableslotperday.get(1) && 
            lstAvailableSlotsPerDay.size() == 0)
        {
            DCON_AES_Event_WS.StartEndTime tempdate1 = new DCON_AES_Event_WS.StartEndTime(avaliableslotperday.get(0),avaliableslotperday.get(1));
            lstAvailableSlotsPerDay.add(tempdate1); 
        }
        //this will be last left over hrs for technician among existing events
        else if(avaliableslotperday.get(0) < avaliableslotperday.get(1))
        {
            DCON_AES_Event_WS.StartEndTime tempdate1 = new DCON_AES_Event_WS.StartEndTime(avaliableslotperday.get(0),avaliableslotperday.get(1));
            lstAvailableSlotsPerDay.add(tempdate1);     
        }
        
        System.debug('lstAvailableSlotsPerDay ****:'+ lstAvailableSlotsPerDay);
        return lstAvailableSlotsPerDay;
    }
     
    /**
     * Name             :   overlappingTimeSlots
     * Params           :   List<datetime> timeSlot1
                            list<datetime> timeSlot2
     * Returns          :   list<datetime>
     * Description      :   returns the overlapping timeslot of two different timeslots
     */
    public static list<datetime> overlappingTimeSlots(List<datetime> timeSlot1, list<datetime> timeSlot2)
    {
        List<datetime> overlapTimeSlot = new List<datetime>();
        System.debug('timeSlot1:' + timeSlot1);
        System.debug('timeSlot2:' + timeSlot2);
        if((timeSlot1 != null && timeSlot1.size() > 0) && (timeSlot2 != null && timeSlot2.size() > 0))
        {
            if((timeSlot1.get(0) < timeSlot2.get(1)) && (timeSlot1.get(1) > timeSlot2.get(0)))
            {
                if((timeSlot1.get(0) <= timeSlot2.get(0)) && (timeSlot1.get(1) <= timeSlot2.get(1)))
                {
                    overlapTimeSlot.add(timeSlot2.get(0));
                    overlapTimeSlot.add(timeSlot1.get(1));  
                }
                else if((timeSlot1.get(0) >= timeSlot2.get(0)) && (timeSlot1.get(1) >= timeSlot2.get(1)))
                {
                    overlapTimeSlot.add(timeSlot1.get(0));
                    overlapTimeSlot.add(timeSlot2.get(1));  
                }
                else if((timeSlot1.get(0) <= timeSlot2.get(0)) && (timeSlot1.get(1) >= timeSlot2.get(1)))
                {
                    overlapTimeSlot.add(timeSlot2.get(0));
                    overlapTimeSlot.add(timeSlot2.get(1));  
                }
                else if((timeSlot1.get(0) >= timeSlot2.get(0)) && (timeSlot1.get(1) <= timeSlot2.get(1)))
                {
                    overlapTimeSlot.add(timeSlot1.get(0));
                    overlapTimeSlot.add(timeSlot1.get(1));  
                }
            }   
        }
        System.debug('overlapTimeSlot:' + overlapTimeSlot);
        return overlapTimeSlot; 
    }
    /**
     * Name             :   DCON_Create_Events_WS3
     * Params           :   String UserId
                            List<Event> lstEvent
                            String timeZone
                            list<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue
     * Returns          :   List<String>          return List of eventId_WOids created
     * Description      :   creates Salesforce and servicemax events
     */ 
    public static List<String> DCON_Create_Events_WS3(String UserId,  List<Event> lstEvent, String timeZone, list<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue)
    {
        SVMXC.COMM_Utils_ManageTags comTagUtils = new SVMXC.COMM_Utils_ManageTags();
        Map<String, String> mapSVMXTags = comTagUtils.SVMX_getTagList('DCON001');
        Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        Schema.Describesobjectresult discResUser = allObjs.get('User').getDescribe();
        List<String> lstEventId = new List<String>();
        List<Event> lstSFEvents = new List<Event>();
        Map<Id, integer> mapWOIdleDuration = new Map<Id, integer>();
        Map<Id, integer> mapWODriveDuration = new Map<Id, integer>();
        Map<Id, integer> mapWOServiceDuration = new Map<Id, integer>();
        Map<Id, integer> mapWOScope = new Map<Id, integer>();
        Map<Id, integer> mapWOVariance = new Map<Id, integer>();
        Map<String,String> FieldDef = new Map<String,String>();
        Schema.Describesobjectresult discWorkOrder;
        list<string> lstUserId = new list<string>();
        boolean IsFromUpsert;
        IsFromUpsert = false;
        system.debug(logginglevel.warn,'REQUEST: ' + timeZone + lstEvent);        
        if(UserId.contains('_'))
        {
            lstUserId = UserId.split('_');
            IsFromUpsert = true;
            UserId = lstUserId.get(0);
        }    

        if (allObjs.containsKey('SVMXC__Service_Order__c') == true)
            discWorkOrder = allObjs.get('SVMXC__Service_Order__c').getDescribe();
        else
            discWorkOrder = allObjs.get('Service_Order__c').getDescribe();

        allObjs.clear();

        String eventExistErrorMessage = mapSVMXTags.get('TAG238');
        Map<String,String> WOFieldDef = new Map<String,String>();    
        Map<String, SObjectField> souObjfieldMapWO = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap();
        WOFieldDef = dcUtils.SVMX_getAllFieldMap(souObjfieldMapWO);
        Map<String,String> EVTFieldDef = new Map<String,String>();
        Map<String, SObjectField> souObjfieldMapEVT = Schema.SObjectType.Event.fields.getMap();
        EVTFieldDef = dcUtils.SVMX_getAllFieldMap(souObjfieldMapEVT); 
        Map<String,String> SVMXEVTFieldDef = new Map<String,String>();
        Map<String, SObjectField> souObjfieldMapSVMXEVT = Schema.SObjectType.SVMXC__SVMX_Event__c.fields.getMap();
        SVMXEVTFieldDef = dcUtils.SVMX_getAllFieldMap(souObjfieldMapSVMXEVT);
        souObjfieldMapWO.clear();
        souObjfieldMapSVMXEVT.clear();
        souObjfieldMapEVT.clear();
        Boolean isEventExist = false;
        Map<String, String> mapWOSettings = new Map<String, String>();
        Map<String, String> mapEventSettings = new Map<String, String>();
        Map<String, String> mapNewSettings = new Map<String, String>();
        Map<String,String> settingvalues = DCON_Event_WS.getEvtandWofields();
        system.debug(logginglevel.warn,'Create Event settingvalues : '+ settingvalues);

        if(settingvalues.keySet().size() > 0)
        {
            for(String strfld : settingvalues.keySet())
            {
                if((settingvalues.containsKey(strfld)) && (String.valueOf(settingvalues.get(strfld)).contains('Event.')))
                {
                    List<String> Evtfield = String.valueOf(settingvalues.get(strfld)).split('Event.',2);
                    mapEventSettings.put(strfld,Evtfield[1]);
                } 
                else
                {
                    mapWOSettings.put(strfld,settingvalues.get(strfld));
                }     
            }
        }     

        settingvalues.clear();
        system.debug('Create Event mapWOSettings : '+ mapWOSettings);
        system.debug('Create Event mapEventSettings : '+ mapEventSettings);
        //010327 : Placing the Flex provided data in a respective map (Drive,IDLE,Field updates) for future use
        if(lstKeyValue != null)
        {
            for(DCON_Configuration_WS.SVMX_StringMap oSVMX_StringMap :lstKeyValue)
            {
                try
                {
                    list<string> lststr = new list<string>();
                    lststr = oSVMX_StringMap.Key.split('_');
                    if(lststr != null && lststr.size() > 1)
                    {
                        try{if(lststr[0] != null && lststr[0].toUpperCase() == 'IDLE')
                            mapWOIdleDuration.put((Id)lststr[1], Integer.valueOf(oSVMX_StringMap.Value));
                        }catch(exception ex){}
                        try{if(lststr[0] != null && lststr[0].toUpperCase() == 'DRIVE')
                            mapWODriveDuration.put((Id)lststr[1], Integer.valueOf(oSVMX_StringMap.Value));
                        }catch(exception ex){}
                        try{if(lststr[0] != null && lststr[0].toUpperCase() == 'SERVICE')
                            mapWOServiceDuration.put((Id)lststr[1], Integer.valueOf(oSVMX_StringMap.Value));
                        }catch(exception ex){}
                        try{if(lststr[0] != null && lststr[0].toUpperCase() == 'SCOPE')
                            mapWOScope.put((Id)lststr[1], Integer.valueOf(oSVMX_StringMap.Value));
                        }catch(exception ex){}
                        try{if(lststr[0] != null && lststr[0].toUpperCase() == 'VARIANCE')
                            mapWOVariance.put((Id)lststr[1], Integer.valueOf(oSVMX_StringMap.Value));
                        }catch(exception ex){}
                        System.debug('map scope:' + mapWOScope);

                    }
                    else
                    {
                        // Field updates - mapNewSettings
                        if(oSVMX_StringMap.Value.toUpperCase() == 'DATE')
                            mapNewSettings.put(oSVMX_StringMap.Key,string.valueOf(oSVMX_StringMap.DateValue));
                        else if(oSVMX_StringMap.Value.toUpperCase() == 'DATETIME')
                            mapNewSettings.put(oSVMX_StringMap.Key,string.valueOf(oSVMX_StringMap.DateTimeValue));
                        else
                            mapNewSettings.put(oSVMX_StringMap.Key,oSVMX_StringMap.Value);
                    }
                }
                catch(exception ex){}
            }
        }
        ////lstKeyValue.clear();
        system.debug('MapnewSettings:'+mapNewSettings);
        List<SVMXC__SVMX_Event__c> lstSVMXEvents = new List<SVMXC__SVMX_Event__c>();
        Savepoint sp = Database.setSavepoint();
        Boolean isError = false;
        String errMessage;

        try
        {
            if(timeZone == NULL || timeZone == '')
            {
                if(!Userinfo.getUserId().contains(UserId))
                    timeZone = [SELECT TimeZoneSidKey from User where Id = :UserId].TimeZoneSidKey;
                else
                    timeZone = Userinfo.getTimeZone().getID();
            }
            //commenting below line.. Since overlapping check happen before splitting events,not required double booking check for splitted LJS Events.
            /*
            System.debug(loggingLevel.Warn,'Calling checkDoublebookingforTech '+lstEvent);
            if(svmxSettingList.containsKey('SET025') && (svmxSettingList.get('SET025').toUpperCase()=='DISALLOW'))      
                DCON_DoubleBooking.checkDoublebookingforTech(lstEvent,timeZone,discResUser.getKeyPrefix());  */       
            set<String> setAvailableTechnicains = new set<String>();

            // Make a list of Technicians for event creation
            for(Event oEvent: lstEvent)
            {
                //To check owner
                if(oEvent != null && oEvent.OwnerId != null && String.valueof(oEvent.OwnerId).startsWith(discResUser.getKeyPrefix()) == false)
                    setAvailableTechnicains.add(oEvent.OwnerId);
            }
            // Get only valid technicians from the prepared list
            // Valid : Enable Sch is true
            setAvailableTechnicains = DCON_Event_WS.getEventEnablesTechnicians(setAvailableTechnicains);

            Set<String> lstWOID = new Set<String>();
            Set<String> lstTechID = new Set<String>();
            Map<String, DateTime> mapEventIDScheduledDatetime = new Map<String, DateTime>();
            Map<String, DateTime> mapWorkOrderIDScheduledDatetime = new Map<String, DateTime>();
            for(Event oEvent: lstEvent)
            {
                //DC only supports WO Event and non associated event creation
                //Therefore the below check is sufficient ( 'other event' case can be relaxed here)
                if(oEvent.WhatId != NULL)
                    lstWOID.add(oEvent.WhatId);
                if(oEvent.OwnerId != NULL)
                    lstTechID.add(oEvent.OwnerId);

                mapEventIDScheduledDatetime.put(oEvent.WhatId+''+oEvent.OwnerId,dcUtils.getDateTimeInTimezone(DateTime.valueof(oEvent.ActivityDateTime).dateGmt(),DateTime.valueof(oEvent.ActivityDateTime).timeGmt(),timeZone));
                mapWorkOrderIDScheduledDatetime.put(oEvent.WhatId,dcUtils.getDateTimeInTimezone(DateTime.valueof(oEvent.ActivityDateTime).dateGmt(),DateTime.valueof(oEvent.ActivityDateTime).timeGmt(),timeZone));
            }
            if(lstWOID.size() > 0)
            {
                Map<String, DateTime> wo_scheduleDate = new Map<String, DateTime>();
                Map<String, DateTime> eventSF_scheduleDate = new Map<String, DateTime>();
                Map<String, DateTime> eventSVMX_scheduleDate = new Map<String, DateTime>();
                DateTime tempDatetime;

                for(Event e: [Select Id, Type, startDateTime, WhatId, OwnerId from Event where WhatId IN :lstWOID AND OwnerId IN :lstTechID])

                {
                    if(tempDatetime == NULL)
                        tempDatetime = e.startDateTime;

                    if(e.startDateTime <= tempDatetime)
                        eventSF_scheduleDate.put(e.WhatId + '' + e.OwnerId, e.startDateTime);
                }

                tempDatetime = NULL;

                for(SVMXC__SVMX_Event__c e: [Select Id, SVMXC__Type__c, SVMXC__StartDateTime__c, SVMXC__WhatId__c, SVMXC__Technician__c from SVMXC__SVMX_Event__c where SVMXC__WhatId__c IN :lstWOID AND SVMXC__Technician__c IN :lstTechID])   
                {
                    if(tempDatetime == NULL)
                        tempDatetime = e.SVMXC__StartDateTime__c;

                    if(e.SVMXC__StartDateTime__c <= tempDatetime)
                        eventSVMX_scheduleDate.put(e.SVMXC__WhatId__c + '' + e.SVMXC__Technician__c, e.SVMXC__StartDateTime__c);
                }

                List<SVMXC__Service_Order__c> schWO = [Select Id,SVMXC__Last_Dispatch_Event__c, SVMXC__FirstScheduledDateTime__c, SVMXC__NoOfTimesScheduled__c, SVMXC__Scheduled_Date_Time__c, SVMXC__Group_Member__c, SVMXC__Group_Member__r.SVMXC__Salesforce_User__c from SVMXC__Service_Order__c where Id IN :lstWOID];

                List<DateTime> dateTime_TL;
                Boolean isUpdatable = false;
                String woTech;
                for(SVMXC__Service_Order__c swo: schWO)
                {
                    if(swo.SVMXC__FirstScheduledDateTime__c == NULL)
                        swo.SVMXC__FirstScheduledDateTime__c = system.now();
                    if(swo.SVMXC__NoOfTimesScheduled__c == NULL)
                        swo.SVMXC__NoOfTimesScheduled__c = 1;
                    else
                        swo.SVMXC__NoOfTimesScheduled__c = swo.SVMXC__NoOfTimesScheduled__c + 1;

                    tempDatetime = NULL;
                    if(swo.SVMXC__Group_Member__r.SVMXC__Salesforce_User__c!=NULL)
                        woTech = swo.Id+''+swo.SVMXC__Group_Member__r.SVMXC__Salesforce_User__c;
                    else
                    {
                        if(swo.SVMXC__Group_Member__c != NULL)
                            woTech = swo.Id+''+swo.SVMXC__Group_Member__c;
                        else
                        {
                            swo.SVMXC__Scheduled_Date_Time__c = mapWorkOrderIDScheduledDatetime.get(swo.Id);
                            continue;
                        }
                    }
                    dateTime_TL = new List<DateTime>();             
                    if(mapEventIDScheduledDatetime.get(woTech) != NULL)
                        dateTime_TL.add(mapEventIDScheduledDatetime.get(woTech));
                    if(eventSF_scheduleDate.get(woTech) != NULL)
                        dateTime_TL.add(eventSF_scheduleDate.get(woTech));
                    if(eventSVMX_scheduleDate.get(woTech) != NULL)
                        dateTime_TL.add(eventSVMX_scheduleDate.get(woTech));
                    if(swo.SVMXC__Scheduled_Date_Time__c != NULL)
                        dateTime_TL.add(swo.SVMXC__Scheduled_Date_Time__c); 

                    swo.SVMXC__Scheduled_Date_Time__c = mapWorkOrderIDScheduledDatetime.get(swo.Id);
                    swo.SVMXC__Last_Dispatch_Event__c = 'Scheduled';
                    if(mapWOIdleDuration.containsKey(swo.Id))
                    {
                        swo.SVMXC__Scheduled_Date_Time__c = swo.SVMXC__Scheduled_Date_Time__c.addMinutes(mapWOIdleDuration.get(swo.Id));
                        swo.SVMXC__Idle_Time__c = mapWOIdleDuration.get(swo.Id);
                    }
                    
                    System.debug('mapWODriveDuration:'+ mapWODriveDuration);
                    if(mapWODriveDuration.containsKey(swo.Id))
                    {
                        swo.SVMXC__Scheduled_Date_Time__c = swo.SVMXC__Scheduled_Date_Time__c.addMinutes(mapWODriveDuration.get(swo.Id));
                        swo.SVMXC__Driving_Time__c = mapWODriveDuration.get(swo.Id);
                        System.debug('swo.SVMXC__Driving_Time__c:'+ swo.SVMXC__Driving_Time__c);
                    }

                    if(mapWOServiceDuration.containsKey(swo.Id)) {
                        swo.SVMXC__Service_Duration__c = mapWOServiceDuration.get(swo.Id);

                    }
                    if(mapWOScope.containsKey(swo.Id)) {
                        swo.SVMXC__SM_Scope_Change__c = mapWOScope.get(swo.Id);
                        System.debug('Scope:' + swo.SVMXC__SM_Scope_Change__c);

                    }
                    if(mapWOVariance.containsKey(swo.Id)) {
                        swo.SVMXC__SM_Variance__c = mapWOVariance.get(swo.Id);

                    }
                    swo.SVMXC__Last_Dispatch_Event__c = 'Scheduled';

                    if(mapNewSettings.keySet().size() > 0)
                    {
                        for(String strfld : mapNewSettings.keySet())
                        {
                            if(mapWOSettings.containsKey(strfld))
                            {                                     
                                if(WOFieldDef.get(mapWOSettings.get(strfld)) == 'DATETIME')
                                { 
                                    swo.put(mapWOSettings.get(strfld),dcUtils.getDateTimeInTimezone(DateTime.valueof(mapNewSettings.get(strfld)).dateGmt(), DateTime.valueof(mapNewSettings.get(strfld)).timeGmt(), Userinfo.getTimeZone().getID()));
                                }
                                else if(WOFieldDef.get(mapWOSettings.get(strfld)) == 'DATE')
                                {
                                    swo.put(mapWOSettings.get(strfld),Date.valueOf(mapNewSettings.get(strfld)));
                                }
                                else if(WOFieldDef.get(mapWOSettings.get(strfld)) == 'BOOLEAN')
                                {
                                    swo.put(mapWOSettings.get(strfld),Boolean.valueOf(mapNewSettings.get(strfld)));
                                }
                                else if(WOFieldDef.get(mapWOSettings.get(strfld)) == 'CURRENCY')
                                {

                                    if(mapNewSettings.get(strfld) !='')
                                        swo.put(mapWOSettings.get(strfld),Double.valueOf(mapNewSettings.get(strfld)));
                                    else
                                        swo.put(mapWOSettings.get(strfld),null);
                                }
                                else if(WOFieldDef.get(mapWOSettings.get(strfld)) == 'INTEGER')
                                {
                                    if(mapNewSettings.get(strfld) !='')
                                        swo.put(mapWOSettings.get(strfld),Integer.valueOf(mapNewSettings.get(strfld)));
                                    else
                                        swo.put(mapWOSettings.get(strfld),null);
                                }
                                else if(WOFieldDef.get(mapWOSettings.get(strfld)) == 'PERCENT')
                                {
                                    if(mapNewSettings.get(strfld) !='')
                                        swo.put(mapWOSettings.get(strfld),Decimal.valueOf(mapNewSettings.get(strfld)));
                                    else
                                        swo.put(mapWOSettings.get(strfld),null);
                                }
                                else if(WOFieldDef.get(mapWOSettings.get(strfld)) == 'DOUBLE')
                                {
                                    if(mapNewSettings.get(strfld) !='')
                                        swo.put(mapWOSettings.get(strfld),Double.valueOf(mapNewSettings.get(strfld)));
                                    else
                                        swo.put(mapWOSettings.get(strfld),null);
                                }
                                else
                                {
                                    if(mapNewSettings.get(strfld) !='')
                                        swo.put(mapWOSettings.get(strfld),String.valueOf(mapNewSettings.get(strfld)));
                                    else
                                        swo.put(mapWOSettings.get(strfld),null);
                                }
                            }
                        }
                    }
                }
                if(schWO.size() > 0)
                {
                    system.debug('Create Event WOflds : '+ schWO);
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(schWO, COMM_SecurityUtils.Access.Upsertable)){
                        update schWO; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                    
                }
            }

            for(Event oEvent: lstEvent)
            {
                if(oEvent!=NULL)
                {
                    // Update the fields for SF events
                    if(String.valueof(oEvent.OwnerId).startsWith(discResUser.getKeyPrefix()))
                    {                    
                        Event TempSFEvent = new Event();
                        // To Support for  AllDay 
                        if(oEvent.IsAllDayEvent)
                        {
                            TempSFEvent.StartDateTime = oEvent.ActivityDate;
                            TempSFEvent.ActivityDateTime = oEvent.ActivityDate;
                            TempSFEvent.ActivityDate = oEvent.ActivityDate;
                        }
                        else
                        {
                            TempSFEvent.ActivityDateTime = dcUtils.getDateTimeInTimezone(DateTime.valueof(oEvent.ActivityDateTime).dateGmt(), DateTime.valueof(oEvent.ActivityDateTime).timeGmt() , timeZone);
                            TempSFEvent.StartDateTime = TempSFEvent.ActivityDateTime;
                            TempSFEvent.ActivityDate = DateTime.valueof(TempSFEvent.ActivityDateTime).date();
                        }

                        TempSFEvent.OwnerId = oEvent.OwnerId;
                        TempSFEvent.DurationInMinutes = Integer.valueof(oEvent.DurationInMinutes);
                        // This is the change due to the introduction of new fields in event objects
                        TempSFEvent.SVMXC__Driving_Time__c = Integer.valueof(oEvent.SVMXC__Driving_Time__c);                
                        TempSFEvent.SVMXC__Overhead_Time_Before__c = Integer.valueof(oEvent.SVMXC__Overhead_Time_Before__c);                
                        TempSFEvent.SVMXC__Overhead_Time_After__c = Integer.valueof(oEvent.SVMXC__Overhead_Time_After__c);              
                        TempSFEvent.SVMXC__Driving_Time_Home__c = Integer.valueof(oEvent.SVMXC__Driving_Time_Home__c);              
                        TempSFEvent.SVMXC__Service_Duration__c = Integer.valueof(oEvent.SVMXC__Service_Duration__c);                
                        TempSFEvent.SVMXC__Break_Time_Total__c = Integer.valueof(oEvent.SVMXC__Break_Time_Total__c); 
                        TempSFEvent.IsAllDayEvent = oEvent.IsAllDayEvent;
                        TempSFEvent.Subject = oEvent.Subject;
                        TempSFEvent.Description = oEvent.Description;
                        TempSFEvent.IsAllDayEvent = oEvent.IsAllDayEvent;
                        TempSFEvent.WhatId = oEvent.WhatId;
                        TempSFEvent.Location = oEvent.Location;
                        TempSFEvent.StartDateTime = TempSFEvent.ActivityDateTime;

                        //Defect# 014336 - added 'Type' field
                        TempSFEvent.Type = oEvent.Type;

                        // Field updates
                        if(mapNewSettings.keySet().size() > 0)
                        {

                            for(String strfld : mapNewSettings.keySet())
                            {
                                if(mapEventSettings.containsKey(strfld))
                                {
                                    if(EVTFieldDef.get(mapEventSettings.get(strfld)) == 'DATETIME')
                                    {
                                        TempSFEvent.put(mapEventSettings.get(strfld),dcUtils.getDateTimeInTimezone(DateTime.valueof(mapNewSettings.get(strfld)).dateGmt(), DateTime.valueof(mapNewSettings.get(strfld)).timeGmt(), timeZone));
                                    }
                                    else if(EVTFieldDef.get(mapEventSettings.get(strfld)) == 'DATE')
                                    {
                                        TempSFEvent.put(mapEventSettings.get(strfld),Date.valueOf(mapNewSettings.get(strfld)));
                                    }
                                    else if(EVTFieldDef.get(mapEventSettings.get(strfld)) == 'BOOLEAN')
                                    {
                                        TempSFEvent.put(mapEventSettings.get(strfld),Boolean.valueOf(mapNewSettings.get(strfld)));
                                    }
                                    else if(EVTFieldDef.get(mapEventSettings.get(strfld)) == 'CURRENCY')
                                    {
                                        if(mapNewSettings.get(strfld)!='')
                                            TempSFEvent.put(mapEventSettings.get(strfld),Double.valueOf(mapNewSettings.get(strfld)));
                                        else
                                            TempSFEvent.put(mapEventSettings.get(strfld),null);
                                    }
                                    else if(EVTFieldDef.get(mapEventSettings.get(strfld)) == 'INTEGER')
                                    {
                                        if(mapNewSettings.get(strfld)!='')
                                            TempSFEvent.put(mapEventSettings.get(strfld),Integer.valueOf(mapNewSettings.get(strfld)));
                                        else
                                            TempSFEvent.put(mapEventSettings.get(strfld),null);
                                    }
                                    else if(EVTFieldDef.get(mapEventSettings.get(strfld)) == 'PERCENT')
                                    {
                                        if(mapNewSettings.get(strfld)!='')
                                            TempSFEvent.put(mapEventSettings.get(strfld),Decimal.valueOf(mapNewSettings.get(strfld)));
                                        else
                                            TempSFEvent.put(mapEventSettings.get(strfld),null);
                                    }
                                    else if(EVTFieldDef.get(mapEventSettings.get(strfld)) == 'DOUBLE')
                                    {
                                        if(mapNewSettings.get(strfld)!='')
                                            TempSFEvent.put(mapEventSettings.get(strfld),Double.valueOf(mapNewSettings.get(strfld)));
                                        else
                                            TempSFEvent.put(mapEventSettings.get(strfld),null);
                                    }
                                    else
                                    {
                                        if(mapNewSettings.get(strfld)!='')
                                            TempSFEvent.put(mapEventSettings.get(strfld),string.valueOf(mapNewSettings.get(strfld)));
                                        else
                                            TempSFEvent.put(mapEventSettings.get(strfld),null);
                                    }
                                }
                            }
                        }
                        system.debug('SF event:'+TempSFEvent);
                        lstSFEvents.add(TempSFEvent);
                    }
                    else
                    {
                        // Update the fields for SVMX events
                        if(setAvailableTechnicains.contains(oEvent.OwnerId))
                        {
                            SVMXC__SVMX_Event__c TempSVMXEvent = new SVMXC__SVMX_Event__c();
                            // Support for AllDay. state sent by client will be honoured
                            if(oEvent.IsAllDayEvent)
                            {
                                TempSVMXEvent.SVMXC__StartDateTime__c = oEvent.ActivityDate;
                                TempSVMXEvent.SVMXC__ActivityDateTime__c = oEvent.ActivityDate;
                                TempSVMXEvent.SVMXC__ActivityDate__c = oEvent.ActivityDate;
                                //get the date , 00:00 time will be taken - sent from the client
                                TempSVMXEvent.SVMXC__EndDateTime__c = (Datetime) oEvent.EndDateTime.dateGmt();
                            }
                            else
                            {
                                TempSVMXEvent.SVMXC__ActivityDateTime__c = dcUtils.getDateTimeInTimezone(DateTime.valueof(oEvent.ActivityDateTime).dateGmt(), DateTime.valueof(oEvent.ActivityDateTime).timeGmt() , timeZone);
                                TempSVMXEvent.SVMXC__StartDateTime__c = TempSVMXEvent.SVMXC__ActivityDateTime__c;
                                TempSVMXEvent.SVMXC__ActivityDate__c = TempSVMXEvent.SVMXC__ActivityDateTime__c.date();
                                DateTime endDate_T = DateTime.valueof(oEvent.ActivityDateTime).addMinutes(Integer.valueof(oEvent.DurationInMinutes));
                                TempSVMXEvent.SVMXC__EndDateTime__c = dcUtils.getDateTimeInTimezone(endDate_T.dateGmt(), endDate_T.timeGmt() , timeZone);

                            }
                            TempSVMXEvent.SVMXC__Technician__c = oEvent.OwnerId;
                            TempSVMXEvent.SVMXC__DurationInMinutes__c = Integer.valueof(oEvent.DurationInMinutes);
                            // This is the change due to the introduction of new fields in event objects
                            TempSVMXEvent.SVMXC__Driving_Time__c = Integer.valueof(oEvent.SVMXC__Driving_Time__c);              
                            TempSVMXEvent.SVMXC__Overhead_Time_Before__c = Integer.valueof(oEvent.SVMXC__Overhead_Time_Before__c);              
                            TempSVMXEvent.SVMXC__Overhead_Time_After__c = Integer.valueof(oEvent.SVMXC__Overhead_Time_After__c);                
                            TempSVMXEvent.SVMXC__Driving_Time_Home__c = Integer.valueof(oEvent.SVMXC__Driving_Time_Home__c);                
                            TempSVMXEvent.SVMXC__Service_Duration__c = Integer.valueof(oEvent.SVMXC__Service_Duration__c);              
                            TempSVMXEvent.SVMXC__Break_Time_Total__c = Integer.valueof(oEvent.SVMXC__Break_Time_Total__c); 
                            TempSVMXEvent.SVMXC__IsAllDayEvent__c = oEvent.IsAllDayEvent; 
                            TempSVMXEvent.Name = oEvent.Subject;
                            TempSVMXEvent.SVMXC__Description__c = oEvent.Description;
                            TempSVMXEvent.SVMXC__WhatId__c = oEvent.WhatId;
                            TempSVMXEvent.SVMXC__Location__c = oEvent.Location;
                            TempSVMXEvent.SVMXC__StartDateTime__c = TempSVMXEvent.SVMXC__ActivityDateTime__c;

                            //Defect# 014336 - added 'SVMXC__Type__c' field
                            TempSVMXEvent.SVMXC__Type__c = oEvent.Type;

                            // Field updates
                            if(mapNewSettings.keySet().size() > 0)
                            {
                                for(String strfld : mapNewSettings.keySet())
                                {
                                    if(mapEventSettings.containsKey(strfld))
                                    {
                                        if(SVMXEVTFieldDef.get(mapEventSettings.get(strfld)) == 'DATETIME')
                                        {
                                            TempSVMXEvent.put(mapEventSettings.get(strfld),dcUtils.getDateTimeInTimezone(DateTime.valueof(mapNewSettings.get(strfld)).dateGmt(), DateTime.valueof(mapNewSettings.get(strfld)).timeGmt(), timeZone));

                                        }
                                        else if(SVMXEVTFieldDef.get(mapEventSettings.get(strfld)) == 'DATE')
                                        {
                                            TempSVMXEvent.put(mapEventSettings.get(strfld),Date.valueOf(mapNewSettings.get(strfld)));
                                        }
                                        else if(SVMXEVTFieldDef.get(mapEventSettings.get(strfld)) == 'BOOLEAN')
                                        {
                                            TempSVMXEvent.put(mapEventSettings.get(strfld),Boolean.valueOf(mapNewSettings.get(strfld)));
                                        }
                                        else if(SVMXEVTFieldDef.get(mapEventSettings.get(strfld)) == 'CURRENCY')
                                        {
                                            if(mapNewSettings.get(strfld)!='')
                                                TempSVMXEvent.put(mapEventSettings.get(strfld),Double.valueOf(mapNewSettings.get(strfld)));
                                            else
                                                TempSVMXEvent.put(mapEventSettings.get(strfld),null);
                                        }
                                        else if(SVMXEVTFieldDef.get(mapEventSettings.get(strfld)) == 'INTEGER')
                                        {
                                            if(mapNewSettings.get(strfld)!='')
                                                TempSVMXEvent.put(mapEventSettings.get(strfld),Integer.valueOf(mapNewSettings.get(strfld)));
                                            else
                                                TempSVMXEvent.put(mapEventSettings.get(strfld),null);
                                        }
                                        else if(SVMXEVTFieldDef.get(mapEventSettings.get(strfld)) == 'PERCENT')
                                        {
                                            if(mapNewSettings.get(strfld)!='')
                                                TempSVMXEvent.put(mapEventSettings.get(strfld),Decimal.valueOf(mapNewSettings.get(strfld)));
                                            else
                                                TempSVMXEvent.put(mapEventSettings.get(strfld),null);
                                        }
                                        else if(SVMXEVTFieldDef.get(mapEventSettings.get(strfld)) == 'DOUBLE')
                                        {
                                            if(mapNewSettings.get(strfld)!='')
                                                TempSVMXEvent.put(mapEventSettings.get(strfld),Double.valueOf(mapNewSettings.get(strfld)));
                                            else
                                                TempSVMXEvent.put(mapEventSettings.get(strfld),null);
                                        }
                                        else
                                        {
                                            if(mapNewSettings.get(strfld)!='')
                                                TempSVMXEvent.put(mapEventSettings.get(strfld),string.valueOf(mapNewSettings.get(strfld)));
                                            else
                                                TempSVMXEvent.put(mapEventSettings.get(strfld),null);
                                        }
                                    }
                                }
                            }
                            system.debug('SVMXEvent123:'+TempSVMXEvent);
                            lstSVMXEvents.add(TempSVMXEvent);
                        }
                    }
                }
            }

            if(lstSFEvents.size()>0)
            {
                system.debug('Create Event SFflds : '+ lstSFEvents);
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstSFEvents, COMM_SecurityUtils.Access.Createable)){
                    insert lstSFEvents; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                } 
            }
            if(lstSVMXEvents.size()>0)
            {
                system.debug('Create Event Svmxflds : '+ lstSVMXEvents);
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstSVMXEvents, COMM_SecurityUtils.Access.Createable)){
                    insert lstSVMXEvents; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                } 
            }
            //We are prepending the event owner id to the event id. This is done for increasing the performance on flex side.
            if(IsFromUpsert)
            {
                for(Event sfe: lstSFEvents)
                {
                    if(sfe.IsAllDayEvent)  
                        lstEventId.add(string.Valueof(sfe.OwnerId) + '_' + string.Valueof(sfe.Id)+ '_' + sfe.ActivityDateTime.formatGMT('MM/dd/yyyy HH:mm')+ '_' + string.Valueof(sfe.DurationInMinutes));
                    else

                        lstEventId.add(string.Valueof(sfe.OwnerId) + '_' + string.Valueof(sfe.Id)+ '_' + sfe.ActivityDateTime.format('MM/dd/yyyy HH:mm',timezone)+ '_' + string.Valueof(sfe.DurationInMinutes));
                }
                for(SVMXC__SVMX_Event__c oSVMXEvents: lstSVMXEvents)
                {
                    if(oSVMXEvents.SVMXC__IsAllDayEvent__c)
                        lstEventId.add(string.Valueof(oSVMXEvents.SVMXC__Technician__c) + '_' + oSVMXEvents.Id + '_'+ oSVMXEvents.SVMXC__ActivityDateTime__c.formatGMT('MM/dd/yyyy HH:mm')+ '_'+ string.Valueof(oSVMXEvents.SVMXC__DurationInMinutes__c));
                    else
                        lstEventId.add(string.Valueof(oSVMXEvents.SVMXC__Technician__c) + '_' + oSVMXEvents.Id + '_'+ oSVMXEvents.SVMXC__ActivityDateTime__c.format('MM/dd/yyyy HH:mm',timezone)+ '_'+ string.Valueof(oSVMXEvents.SVMXC__DurationInMinutes__c));
                }
            }
            else
            {            
                for(Event sfe: lstSFEvents)
                {
                    lstEventId.add(string.Valueof(sfe.OwnerId) + '_' + string.Valueof(sfe.Id));
                }
                for(SVMXC__SVMX_Event__c oSVMXEvents: lstSVMXEvents)
                {
                    lstEventId.add(string.Valueof(oSVMXEvents.SVMXC__Technician__c) + '_' + oSVMXEvents.Id);
                }
            }
        }    
        catch(DmlException ex)
        {
            Database.rollback(sp);
            throw new SVMXException(ex.getDmlMessage(0));
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            if(isEventExist == true)
            {

                if(eventExistErrorMessage == null)
                    throw new SVMXException(system.Label.DCON001_TAG238);
                else
                    throw new SVMXException(eventExistErrorMessage);

            }
            else
            {            
                throw new SVMXException(ex.getMessage());
            }
        }
        return lstEventId;
    }
    /**
     * Name             :   DCON_Assign_Work_Order_To_MultiTech_WS2
     * Params           :   String UserId
                            List<String> WorkOrderIds
                            String TechnicianId
                            String timeZone
                            List<Event> EventList
                            Boolean setOwner
                            list<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue
     * Returns          :   List<String>          return List of eventId_WOids created
     * Description      :   Assign primary technician of WO with event technician and create event
     */ 
    public static List<String> DCON_Assign_Work_Order_To_MultiTech_WS2(String UserId, List<String> WorkOrderIds, String TechnicianId, String timeZone, List<Event> EventList, Boolean setOwner, list<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue){
        List<String> EventIds = new List<String>();
        Savepoint sp = Database.setSavepoint();
        System.debug('INPUT EVENT LIST: ' + EventList);
        try
        {
            // Bala(24-3-11): When technician id is not given don't do work order assignment
            if(TechnicianId != NULL && TechnicianId != '')
            {
                DCON_Assign_Work_Order_To_Tech_WS(UserId, WorkOrderIds, TechnicianId, setOwner);
            }
            if(EventList.size()>0)
            {
                system.debug('Entered Event List');
                EventIds = DCON_Create_Events_WS3(UserId, EventList, timeZone, lstKeyValue); //Changed by Gm to WS3 on 7jun10
            }
        }
        catch(DmlException ex)
        {
            Database.rollback(sp);
            throw new SVMXException(ex.getDmlMessage(0));
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            system.debug('Main error list'+ex.getmessage());
            throw new SVMXException(ex.getmessage());
        }
        return EventIds;
    }
    /**
     * Name             :   DCON_Assign_Work_Order_To_Tech_WS
     * Params           :   String UserId
                            List<String> WorkOrderIds
                            String TechnicianId
                            Boolean setOwner
     * Returns          :   String        
     * Description      :   Updates primary technician of WO
     */ 
    public static String DCON_Assign_Work_Order_To_Tech_WS(String UserId, List<String> WorkOrderIds, String TechnicianId, Boolean SetOwner){
        String StatusMessage;
        //Validations
        if(WorkOrderIds.size()==0)
            throw new SVMXException('Please provide some workorders to assign');
        else if(TechnicianId=='')
            throw new SVMXException('Please provide some technician to assign');
        else
        {
            try
            {
                List<SVMXC__Service_Group_Members__c> tech = new List<SVMXC__Service_Group_Members__c>();
                tech = [SELECT Id, SVMXC__Salesforce_User__c, SVMXC__Service_Group__c, SVMXC__Service_Group__r.SVMXC__Email__c, SVMXC__Enable_Scheduling__c, SVMXC__Email__c from SVMXC__Service_Group_Members__c where Id = :TechnicianId];
                List<SVMXC__Service_Order__c> UpdatedWorkOrder = new List<SVMXC__Service_Order__c>();

                //updating records
                for(SVMXC__Service_Order__c wo: [SELECT Id, SVMXC__Last_Dispatch_Event__c,SVMXC__Locked_By_DC__c,SVMXC__Service_Group__c, SVMXC__Group_Member__c, OwnerId, SVMXC__First_Assigned_DateTime__c, SVMXC__NoOfTimesAssigned__c  from SVMXC__Service_Order__c where Id IN :WorkOrderIds])
                {
                    //Set the Assigned time and count
                    if(wo.SVMXC__First_Assigned_DateTime__c == NULL)
                    {
                        wo.SVMXC__First_Assigned_DateTime__c = system.now();
                    }
                    if(wo.SVMXC__NoOfTimesAssigned__c == NULL)
                    {
                        wo.SVMXC__NoOfTimesAssigned__c = 1;
                    }
                    else
                    {
                        wo.SVMXC__NoOfTimesAssigned__c = wo.SVMXC__NoOfTimesAssigned__c + 1;
                    }
                    wo.SVMXC__Locked_By_DC__c = true;
                    wo.SVMXC__Last_Dispatch_Event__c = 'Assigned';
                    system.debug('Wo is assigned to');
                    if(tech.isEmpty() == false)
                    {
                        if(tech[0].SVMXC__Service_Group__c!=NULL)
                            wo.SVMXC__Service_Group__c = tech[0].SVMXC__Service_Group__c;
                        wo.SVMXC__Member_Email__c = tech[0].SVMXC__Email__c;
                        wo.SVMXC__Group_Email__c = tech[0].SVMXC__Service_Group__r.SVMXC__Email__c;
                        wo.SVMXC__Group_Member__c = TechnicianId;
                        if(SetOwner==true && tech[0].SVMXC__Salesforce_User__c!=NULL)
                            wo.OwnerId = tech[0].SVMXC__Salesforce_User__c;
                        UpdatedWorkOrder.add(wo);
                    }
                }
                if(UpdatedWorkOrder.size() > 0){
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(UpdatedWorkOrder, COMM_SecurityUtils.Access.Upsertable)){
                        upsert UpdatedWorkOrder; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                }

                StatusMessage = 'TAG174';
            }
            catch(DmlException ex)
            {
                throw new SVMXException(ex.getDmlMessage(0));
            }
            catch(Exception ex)
            {
                throw new SVMXException(ex.getMessage());
            }
        }
        return StatusMessage;
    }
    /**
     * Name             :   DCON_Assign_Work_Order_To_Tech_WS
     * Params           :   String UserId
                            List<String> WorkOrderIds
                            String TechnicianId
                            Boolean setOwner
     * Returns          :   DCON_Work_Order_WS.unassignAssign_WP          
     * Description      :   Update primary technician of WO with event technician and deletes all future events of WO
     */ 
    public static DCON_Work_Order_WS.unassignAssign_WP DCON_UnAssignAssign_Work_Order_To_MultiTech_WS2(String UserId, List<String> WorkOrderIds, String TechnicianId, String timeZone, List<Event> EventList, Boolean setOwner, list<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue){
        DCON_Work_Order_WS.unassignAssign_WP response = new DCON_Work_Order_WS.unassignAssign_WP();
        List<String> EventIds = new List<String>();
        String StatusMessage;

        //set the flag true when technician is unassigned using DC(linx for servicepower integration)
        WSCH_OptimizedSchedulingService.isUnAssignDC=true;

        Savepoint sp = Database.setSavepoint();
        try
        {
            // Bala(1-4-11): If work order is passed do unassignment
            if(WorkOrderIds != NULL && WorkOrderIds.size() > 0)
                StatusMessage = DCON_Unassign_Work_Order_WS(UserId, WorkOrderIds);
            // Bala(24-3-11): When technician id is not given don't do work order assignment
            if(TechnicianId != NULL && TechnicianId != '')
               DCON_Assign_Work_Order_To_Tech_WS(UserId, WorkOrderIds, TechnicianId, setOwner);
            if(EventList.size()>0)

                EventIds = DCON_Create_Events_WS3(UserId, EventList, timeZone, lstKeyValue); //Changed by Gm to WS3 on 7jun10
            response.deletedEvents = StatusMessage;
            response.techEventIds = EventIds;
        }
        catch(DmlException ex)
        {
            Database.rollback(sp);
            throw new SVMXException(ex.getDmlMessage(0));
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            throw new SVMXException(ex.getmessage());
        }
        return response;
    }
    /**
     * Name             :   DCON_Unassign_Work_Order_WS
     * Params           :   String UserId
                            List<String> WorkOrderIds
     * Returns          :   String      
     * Description      :   This method accepts a list of work orders, and clears the current assignment to technician or team whichever is applicable.
     */ 
    public static String DCON_Unassign_Work_Order_WS(String UserId, List<String> WorkOrderIds){
        String StatusMessage;
        //Validations
        if(WorkOrderIds.size()==0)
            throw new SVMXException('Please provide some workorders to unassign');

        try
        {
            boolean settingRetainDCLock = false;
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();

            if(svmxSettingList.Containskey('SET022') && svmxSettingList.get('SET022')=='True')
                settingRetainDCLock = true;
            else
                settingRetainDCLock = false;

            //Unschedule the work orders related events
            StatusMessage = DCON_Unschedule_Work_Order_WS(UserId, WorkOrderIds);

            List<SVMXC__Service_Order__c> UpdatedWorkOrder = new List<SVMXC__Service_Order__c>();
            //updating records
            for(SVMXC__Service_Order__c wo: [SELECT Id,SVMXC__Last_Dispatch_Event__c, SVMXC__Member_Email__c,SVMXC__Service_Duration__c,SVMXC__Idle_Time__c,SVMXC__Driving_Time__c,SVMXC__Group_Email__c,SVMXC__Locked_By_DC__c,SVMXC__Service_Group__c, SVMXC__Group_Member__c, OwnerId, SVMXC__Scheduled_Date_Time__c  from SVMXC__Service_Order__c where Id IN :WorkOrderIds])
            {
                if(wo.SVMXC__Group_Member__c !=NULL)
                    wo.SVMXC__Last_Dispatch_Event__c = 'UnAssigned';
                if(wo.SVMXC__Group_Member__c ==NULL && wo.SVMXC__Service_Group__c!=null)
                    wo.SVMXC__Last_Dispatch_Event__c = 'UnQueued';
                wo.SVMXC__Service_Group__c = NULL;
                wo.SVMXC__Group_Member__c = NULL;
                // Bala(4/2/11): Commented
                //wo.SVMXC__Service_Duration__c=null;
                //wo.SVMXC__Idle_Time__c = null;
                //wo.SVMXC__Driving_Time__c = null;
                wo.SVMXC__Group_Email__c = null;
                wo.SVMXC__Member_Email__c = null;
                wo.SVMXC__Scheduled_Date_Time__c = NULL;                

                if(settingRetainDCLock)
                    wo.SVMXC__Locked_By_DC__c = true;
                else
                    wo.SVMXC__Locked_By_DC__c = false;                
                wo.SVMXC__Scheduled_Date__c = NULL;
                UpdatedWorkOrder.add(wo);
            }
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(UpdatedWorkOrder, COMM_SecurityUtils.Access.Upsertable)){
                upsert UpdatedWorkOrder; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
            //StatusMessage = 'TAG175';
        }
        catch(DmlException ex)
        {
            throw new SVMXException(ex.getDmlMessage(0));
        }
        catch(Exception ex)
        {
            throw new SVMXException(ex.getMessage());
        }
        return StatusMessage;
    }
    /**
     * Name             :   DCON_Unschedule_Work_Order_WS
     * Params           :   String UserId
                            List<String> WorkOrderIds
     * Returns          :   String      
     * Description      :   This method accepts a list of work orders, and clears any future events of the work orders in Salesforce Event or ServiceMax Event objects.
                            The current assignment of the work order to a technician or team remains unaltered.
     */ 
    public static String DCON_Unschedule_Work_Order_WS(String UserId, List<String> WorkOrderIds){
        String StatusMessage = '';

        List<Event> events = new List<Event>();
        List<SVMXC__SVMX_Event__c> SVMXevents = new List<SVMXC__SVMX_Event__c>();
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        //Validations

        if(WorkOrderIds.size()==0)
            throw new SVMXException('Please provide some workorders to unschedule');    
        try{

            if(svmxSettingList.Containskey('SET024') && svmxSettingList.get('SET024')=='True')
            {// Setting to delete Past Events or not
                events = [SELECT Id from event where WhatId IN :WorkOrderIds];
                SVMXevents = [SELECT Id from SVMXC__SVMX_Event__c where SVMXC__WhatId__c IN :WorkOrderIds];
                for(event objEvent: events)
                {
                    if(StatusMessage != '')
                        StatusMessage += ',';
                    StatusMessage += objEvent.Id;
                }
                for(SVMXC__SVMX_Event__c objEvent: SVMXevents)
                {
                    if(StatusMessage != '')
                        StatusMessage += ',';
                    StatusMessage += objEvent.Id;
                }
            }
            else
            {
                events = [SELECT Id from event where WhatId IN :WorkOrderIds and StartDateTime > :System.now()];
                SVMXevents = [SELECT Id from SVMXC__SVMX_Event__c where SVMXC__WhatId__c IN :WorkOrderIds and SVMXC__StartDateTime__c > :System.now()];
                for(event objEvent: events)
                {
                    if(StatusMessage != '')
                        StatusMessage += ',';
                    StatusMessage += objEvent.Id;
                }
                for(SVMXC__SVMX_Event__c objEvent: SVMXevents)
                {
                    if(StatusMessage != '')
                        StatusMessage += ',';
                    StatusMessage += objEvent.Id;
                }
            }
            if(events.size()>0){
                if(COMM_SecurityUtils.getInstance().isDeletableObject('Event')){
                    delete events; //SDL-SVMX-DELETE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
            if(SVMXevents.size()>0){
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SVMX_Event__c')){
                    delete SVMXevents; //SDL-SVMX-DELETE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
        }
        catch(DmlException ex)
        {
            throw new SVMXException(ex.getDmlMessage(0));
        }
        catch(Exception ex)
        {
            throw new SVMXException(ex.getMessage());
        }
        return StatusMessage;
    }
    /**
     * Name             :   DCON_UnAssignAssign_Work_Order_To_MultiTech_WS3
     * Params           :   String UserId
                            List<String> WorkOrderIds
                            String TechnicianId
                            String timeZone
                            List<Event> EventList
                            Boolean setOwner
                            list<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue
     * Returns          :   List<String>          return List of eventId_WOids created
     * Description      :   Update primary technician of WO with event technician and don't deletes all future events of WO
     */ 
    public static List<String> DCON_UnAssignAssign_Work_Order_To_MultiTech_WS3(String UserId, List<String> WorkOrderIds, String TechnicianId, String timeZone, List<Event> EventList, Boolean setOwner, list<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue){
        DCON_Work_Order_WS.unassignAssign_WP response = new DCON_Work_Order_WS.unassignAssign_WP();
        List<String> EventIds = new List<String>();
        String StatusMessage;

        //set the flag true when technician is unassigned using DC(linx for servicepower integration)
        WSCH_OptimizedSchedulingService.isUnAssignDC=true;

        Savepoint sp = Database.setSavepoint();
        try
        {
            // Bala(1-4-11): If work order is passed do unassignment
            if(WorkOrderIds != NULL && WorkOrderIds.size() > 0)
                StatusMessage = DCON_Unassign_Work_Order_WS1(UserId, WorkOrderIds);
            // Bala(24-3-11): When technician id is not given don't do work order assignment
            if(TechnicianId != NULL && TechnicianId != '')
               DCON_Assign_Work_Order_To_Tech_WS(UserId, WorkOrderIds, TechnicianId, setOwner);
            if(EventList.size()>0)

                EventIds = DCON_Create_Events_WS3(UserId, EventList, timeZone, lstKeyValue); //Changed by Gm to WS3 on 7jun10
        }
        catch(DmlException ex)
        {
            Database.rollback(sp);
            throw new SVMXException(ex.getDmlMessage(0));
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            throw new SVMXException(ex.getmessage());
        }
        return EventIds;
    }
    /**
     * Name             :   DCON_Unassign_Work_Order_WS1
     * Params           :   String UserId
                            List<String> WorkOrderIds
     * Returns          :   String      
     * Description      :   Updates the primary technician of WO but don't delete any events
     */ 
    public static String DCON_Unassign_Work_Order_WS1(String UserId, List<String> WorkOrderIds){
        String StatusMessage;
        //Validations
        if(WorkOrderIds.size()==0)
            throw new SVMXException('Please provide some workorders to unassign');

        try
        {
            boolean settingRetainDCLock = false;
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();

            if(svmxSettingList.Containskey('SET022') && svmxSettingList.get('SET022')=='True')
                settingRetainDCLock = true;
            else
                settingRetainDCLock = false;
            /*
            //Unschedule the work orders related events
            StatusMessage = DCON_Unschedule_Work_Order_WS(UserId, WorkOrderIds);
            */

            List<SVMXC__Service_Order__c> UpdatedWorkOrder = new List<SVMXC__Service_Order__c>();
            //updating records
            for(SVMXC__Service_Order__c wo: [SELECT Id,SVMXC__Last_Dispatch_Event__c, SVMXC__Member_Email__c,SVMXC__Service_Duration__c,SVMXC__Idle_Time__c,SVMXC__Driving_Time__c,SVMXC__Group_Email__c,SVMXC__Locked_By_DC__c,SVMXC__Service_Group__c, SVMXC__Group_Member__c, OwnerId, SVMXC__Scheduled_Date_Time__c  from SVMXC__Service_Order__c where Id IN :WorkOrderIds])
            {
                if(wo.SVMXC__Group_Member__c !=NULL)
                    wo.SVMXC__Last_Dispatch_Event__c = 'UnAssigned';
                if(wo.SVMXC__Group_Member__c ==NULL && wo.SVMXC__Service_Group__c!=null)
                    wo.SVMXC__Last_Dispatch_Event__c = 'UnQueued';
                wo.SVMXC__Service_Group__c = NULL;
                wo.SVMXC__Group_Member__c = NULL;
                // Bala(4/2/11): Commented
                //wo.SVMXC__Service_Duration__c=null;
                //wo.SVMXC__Idle_Time__c = null;
                //wo.SVMXC__Driving_Time__c = null;
                wo.SVMXC__Group_Email__c = null;
                wo.SVMXC__Member_Email__c = null;
                wo.SVMXC__Scheduled_Date_Time__c = NULL;                

                if(settingRetainDCLock)
                    wo.SVMXC__Locked_By_DC__c = true;
                else
                    wo.SVMXC__Locked_By_DC__c = false;                
                wo.SVMXC__Scheduled_Date__c = NULL;
                UpdatedWorkOrder.add(wo);
            }

            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(UpdatedWorkOrder, COMM_SecurityUtils.Access.Upsertable)){
                upsert UpdatedWorkOrder; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
            //StatusMessage = 'TAG175';
        }
        catch(DmlException ex)
        {
            throw new SVMXException(ex.getDmlMessage(0));
        }
        catch(Exception ex)
        {
            throw new SVMXException(ex.getMessage());
        }
        return StatusMessage;
    }
}