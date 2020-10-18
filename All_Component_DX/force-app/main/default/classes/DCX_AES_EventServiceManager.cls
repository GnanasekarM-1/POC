public class DCX_AES_EventServiceManager
{
    public DCX_AES_EventServiceManager ()
    {}
    public class SVMXException extends Exception {}
    DCX_CommonServiceManager.DCEvent_WO_WP eventData;
    
    
    public class AES_Request 
    {
        public String timeZone;
        public List<Event> lstEvent = new list<Event>();
        public String UserId;      
        public List<String> lsttechId = new List<String>();     
        public Integer eventMinDuration;
        public boolean isTechWorkingHrsEnabled;
        public boolean isMachineWorkingHrsEnabled;
        public boolean isOverlappingEnabled;
        public boolean isCalculateEndTime;
        public list<DCX_Wrapper.SVMX_StringMap> lstKeyValue = new list<DCX_Wrapper.SVMX_StringMap>();
        public boolean updatePrimaryTech;
        public boolean deleteEventForOtherTechs;
     //   public boolean deleteEventForOtherTechs;
        public String techSFId;
        public List<String> woFields;
 
        public AES_Request(string UserId, 
                        List<Event> lstEvent,
                        String timeZone,
                        List<String> lsttechId,
                        integer eventMinDuration, 
                        boolean isTechWorkingHrsEnabled,
                        boolean isMachineWorkingHrsEnabled,
                        boolean isOverlappingEnabled,
                        boolean isCalculateEndTime,
                        List<DCX_Wrapper.SVMX_StringMap> lstKeyValue,
                        boolean updatePrimaryTech,
                        boolean deleteEventForOtherTechs,
                      //  boolean deleteEventForOtherTechs,
                        String tcSFId,
                        List<String> wFields
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
            this.updatePrimaryTech = updatePrimaryTech;
            this.deleteEventForOtherTechs = deleteEventForOtherTechs;
          //  this.deleteEventForOtherTechs = deleteEventForOtherTechs;
            this.techSFId = tcSFId;
            this.woFields = wFields;
            
        }
        public AES_Request() {}
    }
    
    public class AES_Response 
    {
        public list<DCX_CommonServiceManager.Events_WP> lstEvent {get; set;}
        public DCX_Wrapper.workorder_WP objWorkOrder {get; set;}
        public String strWOAction {get; set;}
        public  String endDatetime{get;set;}
        public  String startDatetime{get;set;}
        public  Integer remainderServiceDuration{get;set;}
        public  Integer eventsCounter{get;set;}
        public  String deletedEvents{get;set;}
            
        public AES_Response(list<DCX_CommonServiceManager.Events_WP> evData, DCX_Wrapper.workorder_WP objWO,String strWOAct,String endDatetime, String startDatetime, Integer remainderServiceDuration, Integer eventsCounter, String deletedEvents)
        {
            this.lstEvent = evData;
            this.objWorkOrder = objWO;
            this.strWOAction = strWOAct;
            this.endDatetime = endDatetime;
            this.startDatetime = startDatetime;
            this.remainderServiceDuration = remainderServiceDuration;
            this.eventsCounter = eventsCounter;
            this.deletedEvents = deletedEvents;
        }
        public AES_Response() {}           
    }
    
    public class StartEndTime
    {
        public Datetime startTime {get; set;}
        public Datetime endTime {get; set;}
        
        public StartEndTime(Datetime startTime, Datetime endTime)
        {
            this.startTime = startTime;
            this.endTime = endTime;
        }
        public StartEndTime() {}   
    }

    public static AES_Response DCX_AES_Create_Events_WS(AES_Request req)
    {
        AES_Response response = new AES_Response();
        try
        {
            
            System.debug('Req:  '+ Req);
            response = DCX_AES_Create_Events(req.UserId, 
                        req.lstEvent,
                        req.timeZone,
                        req.lsttechId,
                        req.eventMinDuration, 
                        req.isTechWorkingHrsEnabled,
                        req.isMachineWorkingHrsEnabled,
                        req.isOverlappingEnabled,
                        req.isCalculateEndTime,
                        req.lstKeyValue,
                        req.updatePrimaryTech,
                        req.deleteEventForOtherTechs,
                       // req.deleteEventForOtherTechs,
                        req.techSFId,
                        req.woFields);
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
                    boolean updatePrimaryTech                  - if it is true, update the technician in WO with latest technician    
                    boolean deleteEventForOtherTechs                       - if it is true, delete all other events associated with WO while reassigning WO   
    * Return:       List<String> lstAESEvent                     - list of splitted events  
                    String endDatetime                           - return enddatetime in client sent timezone when isCalculateEndTime is true   
                    Integer remainderServiceDuration             - return remaining unscheduled time while splitting events based on event minimum duration
                    Integer eventsCounter                        - return count of events splitted  
                    String deletedEvents                         - return deleted event Ids when deleteEventForOtherTechs is true     
    */
    //Note: All calculations happen in timezone send by client
    public static AES_Response DCX_AES_Create_Events(string UserId, 
                        List<Event> lstEvent,
                        String timeZone,
                        List<String> lsttechId,
                        integer eventMinDuration, 
                        boolean isTechWorkingHrsEnabled,
                        boolean isMachineWorkingHrsEnabled,
                        boolean isOverlappingEnabled,
                        boolean isCalculateEndTime,
                        List<DCX_Wrapper.SVMX_StringMap> lstKeyValue,
                        boolean updatePrimaryTech,
                        boolean deleteEventForOtherTechs,
                        String techSFId,
                        List<String> woFields)
    {
        AES_Response response;  
        Schema.Describesobjectresult discResUser = User.sObjectType.getDescribe();
        String UserKey = discResUser.getKeyPrefix();
        
        List<String> lstTech = new List<String>();
        List<String> lstSFUserId = new List<String>();
        
        List<String> lstAESchildevts = new List<String>();
        DCX_CommonServiceManager.DCEvent_WO_WP eventData = 
            new DCX_CommonServiceManager.DCEvent_WO_WP();    
        Savepoint sp = Database.setSavepoint();
        DCX_Utils dcUtils = new DCX_Utils();
        
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
            
            List<SVMXC__Service_Order__c> lstWorkOrders = [Select Id, SVMXC__Preferred_Business_Hours__c, 
                                                            SVMXC__Dispatch_Status__c from 
                                                            SVMXC__Service_Order__c
                                                            where Id IN: lstWorkOrderIds];
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
                machineAccessHrs = [SELECT WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, 
                                    TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, 
                                    SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, 
                                    MondayEndTime, IsDefault, IsActive, Id, FridayStartTime,FridayEndTime,
                                    TimeZoneSidKey from BusinessHours where 
                                    Id = :lstWorkOrders.get(0).SVMXC__Preferred_Business_Hours__c and 
                                    IsActive = true];
            }       
                        
            Integer eventMinDurationInseconds = eventMinDuration * 60;
            List<String> settingIds = new List<String>{'DCON005_SET009'};
            Map<String,String> svmxSetting = COMM_Utils_ManageSettings.SVMX_getSettingValueForList(settingIds);
            Integer maxUnsuccessCalenderDays = 0;
            maxUnsuccessCalenderDays = integer.valueOf(svmxSetting.get('DCON005_SET009'));
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
                            DCX_AES_EventServiceManager_Util eventsUtil = new DCX_AES_EventServiceManager_Util();
                            lstSFEvent = eventsUtil.getLstSFEventforTech(mapSFUSerTechId.keyset(), STtoRetrieveEvents, ETtoRetrieveEvents);
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
                                
                        if(oEvent.SVMXC__Driving_Time__c > 0 || oEvent.SVMXC__Driving_Time_Home__c > 0 || 
                            oEvent.SVMXC__Overhead_Time_After__c > 0 || 
                            oEvent.SVMXC__Overhead_Time_Before__c >0 || oEvent.SVMXC__Break_Time_Total__c > 0)
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
                        response = new AES_Response(null,null,null,String.valueOfGmt(lstAESEvents.get(lstAESEvents.size() -1).EndDateTime),String.valueOfGmt(lstAESEvents.get(0).StartDateTime),tempremainderServiceDuration,lstAESEvents.size(),null);
                         System.debug('response1:'+ response);
                    }
                    else
                    {
                        system.debug('updatePrimaryTech :+deleteEventForOtherTechs+lstWorkOrders.get(0).SVMXC__Dispatch_Status__c'+updatePrimaryTech+'::'+deleteEventForOtherTechs+'::'+lstWorkOrders.get(0).SVMXC__Dispatch_Status__c);

                        String deletedEvents;
                        unassignAssign_WP eventdetails;
                        //When WO dispatch status is 'new', trying to assign LJS WO to technician
                        if(updatePrimaryTech && !deleteEventForOtherTechs && (lstWorkOrders.get(0).SVMXC__Dispatch_Status__c).equalsIgnoreCase('New'))
                            {  
                                system.debug('entryto create event'); 
                                eventData = DCX_EventServiceManager.createEvents(lstAESEvents,timeZone,lstKeyValue,lsttechId.get(0),true,false,techSFId,woFields);
                            }
                        else if(!updatePrimaryTech && !deleteEventForOtherTechs && (lstWorkOrders.get(0).SVMXC__Dispatch_Status__c).equalsIgnoreCase('Queued'))
                        {   
                            system.debug('entryto create event');
                            eventData = DCX_EventServiceManager.createEvents(lstAESEvents,timeZone,lstKeyValue,lsttechId.get(0),true,false,techSFId,woFields);
                        }
                        else if(!updatePrimaryTech && !deleteEventForOtherTechs && !((lstWorkOrders.get(0).SVMXC__Dispatch_Status__c).equalsIgnoreCase('Assigned')))
                        {
                            system.debug('entryto create event1');
                            eventData = DCX_Assign_Work_Order_To_MultiTech_WS2(UserId,lstWorkOrderIds,lsttechId.get(0),timezone,lstAESEvents,true,lstKeyValue,techSFId,woFields); 
                        }
                        //when WO dispatch status is 'assigned', assigning WO to other technician without updating technician in WO and without deleting previous events
                        else if(!updatePrimaryTech && !deleteEventForOtherTechs && (lstWorkOrders.get(0).SVMXC__Dispatch_Status__c).equalsIgnoreCase('Assigned'))
                        {   
                            system.debug('entryto create event2');
                            eventData = DCX_EventServiceManager.createEvents(lstAESEvents,timeZone,lstKeyValue,lsttechId.get(0),false,false,techSFId,woFields);
                        }
                        //when WO dispatch status is 'assigned', assigning WO to other technician updating technician in WO and deleting previous events
                        else if(updatePrimaryTech && deleteEventForOtherTechs && (lstWorkOrders.get(0).SVMXC__Dispatch_Status__c).equalsIgnoreCase('Assigned'))
                        {  
                             
                            system.debug('entryto create event3');
                           // eventdetails = DCX_UnAssignAssign_Work_Order_To_MultiTech_WS2(UserId,lstWorkOrderIds,lsttechId.get(0),timezone,lstAESEvents,true,lstKeyValue,techSFId,woFields,updatePrimaryTech,deleteEventForOtherTechs);
                           // eventData = eventdetails.techEventIds;
                            //deletedEvents = eventdetails.deletedEvents;

                            eventData = DCX_EventServiceManager.createEvents(lstAESEvents,timeZone,lstKeyValue,lsttechId.get(0),true,true,techSFId,woFields);
                          deletedEvents = string.join(eventData.deletedEventIds,',');
                        }  


                        //when WO dispatch status is 'assigned', assigning WO to other technician with updating technician in WO and without deleting previous events
                        else if(updatePrimaryTech && !deleteEventForOtherTechs && (lstWorkOrders.get(0).SVMXC__Dispatch_Status__c).equalsIgnoreCase('Assigned'))
                        {
                            system.debug('entryto create event4');
                            eventData = DCX_UnAssignAssign_Work_Order_To_MultiTech_WS3(UserId,lstWorkOrderIds,lsttechId.get(0),timezone,lstAESEvents,true,lstKeyValue,techSFId,woFields);
                        }
                        response = new AES_Response(eventData.lstEvent,eventData.objWorkOrder,eventData.strWOAction,null,null,tempremainderServiceDuration,lstAESchildevts.size(),deletedEvents);
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
                        DCX_AES_EventServiceManager_Util eventsUtil = new DCX_AES_EventServiceManager_Util();
                        lstSFEvent = eventsUtil.getLstSFEventforTech(mapSFUSerTechId.keyset(), STtoRetrieveEvents, ETtoRetrieveEvents);
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
                            response = new AES_Response(null,null,null,String.valueOfGmt(lstAESEvents.get(lstAESEvents.size() -1).EndDateTime),String.valueOfGmt(lstAESEvents.get(0).StartDateTime),tempremainderServiceDuration,lstAESEvents.size(),null);
                            System.debug('response1:'+ response);
                        }
                        else
                        {
                            String deletedEvents;
                            unassignAssign_WP eventdetails;
                            system.debug('updatePrimaryTech :+deleteEventForOtherTechs+lstWorkOrders.get(0).SVMXC__Dispatch_Status__c'+updatePrimaryTech+'::'+deleteEventForOtherTechs+'::'+lstWorkOrders.get(0).SVMXC__Dispatch_Status__c);
                            if(updatePrimaryTech && !deleteEventForOtherTechs && (lstWorkOrders.get(0).SVMXC__Dispatch_Status__c).equalsIgnoreCase('New'))
                            {  
                                system.debug('entryto create event'); 
                                eventData = DCX_EventServiceManager.createEvents(lstAESEvents,timeZone,lstKeyValue,lsttechId.get(0),true,false,techSFId,woFields);
                            }
                            if(!updatePrimaryTech && !deleteEventForOtherTechs && (lstWorkOrders.get(0).SVMXC__Dispatch_Status__c).equalsIgnoreCase('Queued'))
                            {  
                                system.debug('entryto create event'); 
                                eventData = DCX_EventServiceManager.createEvents(lstAESEvents,timeZone,lstKeyValue,lsttechId.get(0),true,false,techSFId,woFields);
                            }
                            else if(!updatePrimaryTech && !deleteEventForOtherTechs && !((lstWorkOrders.get(0).SVMXC__Dispatch_Status__c).equalsIgnoreCase('Assigned')))
                            {
                                system.debug('entryto create event1');
                                eventData = DCX_Assign_Work_Order_To_MultiTech_WS2(UserId,lstWorkOrderIds,lsttechId.get(0),timezone,lstAESEvents,true,lstKeyValue,techSFId,woFields); 
                            }
                            else if(!updatePrimaryTech && !deleteEventForOtherTechs && (lstWorkOrders.get(0).SVMXC__Dispatch_Status__c).equalsIgnoreCase('Assigned'))
                            {   
                                system.debug('entryto create event2');
                                eventData = DCX_EventServiceManager.createEvents(lstAESEvents,timeZone,lstKeyValue,lsttechId.get(0),false,false,techSFId,woFields);
                            }
                            else if(updatePrimaryTech && deleteEventForOtherTechs && (lstWorkOrders.get(0).SVMXC__Dispatch_Status__c).equalsIgnoreCase('Assigned'))
                            {  
                                system.debug('entryto create event3'); 
                                eventData = DCX_EventServiceManager.createEvents(lstAESEvents,timeZone,lstKeyValue,lsttechId.get(0),true,true,techSFId,woFields);
                               
                                //eventdetails = DCX_UnAssignAssign_Work_Order_To_MultiTech_WS2(UserId,lstWorkOrderIds,lsttechId.get(0),timezone,lstAESEvents,true,lstKeyValue,techSFId,woFields,updatePrimaryTech,deleteEventForOtherTechs);
                               // eventData = eventdetails.techEventIds;
                               deletedEvents = string.join(eventData.deletedEventIds,',');
                               // deletedEvents = eventData.deletedEventIds;
                               system.debug('entryto create event3' +deletedEvents); 
                            }   
                            else if(updatePrimaryTech && !deleteEventForOtherTechs && (lstWorkOrders.get(0).SVMXC__Dispatch_Status__c).equalsIgnoreCase('Assigned'))
                            {
                                system.debug('entryto create event 4');
                                eventData = DCX_UnAssignAssign_Work_Order_To_MultiTech_WS3(UserId,lstWorkOrderIds,lsttechId.get(0),timezone,lstAESEvents,true,lstKeyValue,techSFId,woFields);
                            }
                            System.debug('lstAESchildevts:' + lstAESchildevts);
                            response = new AES_Response(eventData.lstEvent,eventData.objWorkOrder,eventData.strWOAction,null,null,tempremainderServiceDuration,lstAESchildevts.size(),deletedEvents);
                            System.debug('response:'+ response);
                        }  
                    }
                    else
                    {
                        throw new SVMXException('EVENTSTAG066');   
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
        DCX_Utils dcxUtils = new DCX_Utils();
        Boolean isHoliday = false;
        if(givendate != null && bh != null)
        {
            Datetime dtmDayStartDateTime = dcxUtils.getDateTimeInTimezone(givendate, Time.newInstance(0, 0, 0, 0), bh.timeZoneSidKey);
                  
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
                    Datetime startDatetime = DCX_Utils.doTZConversion(sfevt.StartDateTime, 'GMT', timeZone);  
                    Datetime endDatetime = DCX_Utils.doTZConversion((sfevt.StartDateTime).addMinutes(Integer.valueOf(sfevt.DurationInMinutes)), 'GMT', timeZone); 
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
                    Datetime startDatetime = DCX_Utils.doTZConversion(svmxevt.SVMXC__StartDateTime__c, 'GMT', timeZone);  
                    Datetime endDatetime = DCX_Utils.doTZConversion((svmxevt.SVMXC__StartDateTime__c).addMinutes(Integer.valueOf(svmxevt.SVMXC__DurationInMinutes__c)), 'GMT', timeZone); 
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
            while(i < lstSFEventStartEndTime.size())
            {
                StartEndTime tempdate = new StartEndTime(lstSFEventStartEndTime[i].starttime,lstSFEventStartEndTime[i].endtime);
                lstdates.add(tempdate);
                i++;    
            }
        }
        else if((lstSFEventStartEndTime.isEmpty() && lstSFEventStartEndTime.size() == 0) && (lstSVMXEventStartEndTime != null && lstSVMXEventStartEndTime.size() > 0))
        {
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
                        System.debug('technician start time 0:'+ avaliableslotperday);
                    }
                    if(((avaliableslotperday.get(0) >= dt.startTime) && 
                        (avaliableslotperday.get(0) <= dt.endTime)) && 
                        ((avaliableslotperday.get(1) >= dt.startTime) && 
                        (avaliableslotperday.get(1) >= dt.endTime)))
                    {
                        avaliableslotperday[0] = dt.endTime;
                        System.debug('technician start time 1:'+ avaliableslotperday);
                    }
                    if(((avaliableslotperday.get(0) <= dt.startTime) && 
                        (avaliableslotperday.get(0) <= dt.endTime)) && 
                        ((avaliableslotperday.get(1) >= dt.startTime) && 
                        (avaliableslotperday.get(1) >= dt.endTime)))
                    {
                        DCX_AES_EventServiceManager.StartEndTime tempdate1 = 
                            new DCX_AES_EventServiceManager.StartEndTime(avaliableslotperday.get(0),dt.startTime);
                        avaliableslotperday[0] = dt.endTime;
                        lstAvailableSlotsPerDay.add(tempdate1);
                        System.debug('technician start time 2:'+ avaliableslotperday + tempdate1);
                    }
                    if(((avaliableslotperday.get(0) <= dt.startTime) && 
                        (avaliableslotperday.get(0) <= dt.endTime)) && 
                        ((avaliableslotperday.get(1) >= dt.startTime) && 
                        (avaliableslotperday.get(1) <= dt.endTime)))
                    {
                        DCX_AES_EventServiceManager.StartEndTime tempdate1 = new DCX_AES_EventServiceManager.StartEndTime(avaliableslotperday.get(0),dt.startTime);
                        avaliableslotperday[0] = dt.endTime;
                        lstAvailableSlotsPerDay.add(tempdate1);
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
            DCX_AES_EventServiceManager.StartEndTime tempdate1 = new DCX_AES_EventServiceManager.StartEndTime(avaliableslotperday.get(0),avaliableslotperday.get(1));
            lstAvailableSlotsPerDay.add(tempdate1); 
        }
        //this will be last left over hrs for technician among existing events
        else if(avaliableslotperday.get(0) < avaliableslotperday.get(1))
        {
            DCX_AES_EventServiceManager.StartEndTime tempdate1 = new DCX_AES_EventServiceManager.StartEndTime(avaliableslotperday.get(0),avaliableslotperday.get(1));
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
    public static DCX_CommonServiceManager.DCEvent_WO_WP DCX_Assign_Work_Order_To_MultiTech_WS2(String UserId, List<String> WorkOrderIds, String TechnicianId, String timeZone, List<Event> EventList, Boolean setOwner, list<DCX_Wrapper.SVMX_StringMap> lstKeyValue,String techSFId,List<String> woFields){
        List<String> EventIds = new List<String>();
        Savepoint sp = Database.setSavepoint();
        System.debug('INPUT EVENT LIST: ' + EventList);
        DCX_CommonServiceManager.DCEvent_WO_WP eventData = 
            new DCX_CommonServiceManager.DCEvent_WO_WP();
        try
        {
            // Bala(24-3-11): When technician id is not given don't do work order assignment
            if(TechnicianId != NULL && TechnicianId != '')
            {
                DCX_Assign_Work_Order_To_Tech_WS(UserId, WorkOrderIds, TechnicianId, setOwner);
            }
            if(EventList.size()>0)
            {
                eventData = DCX_EventServiceManager.createEvents(EventList, timeZone, lstKeyValue,TechnicianId,true,false,techSFId,woFields); //Changed by Gm to WS3 on 7jun10
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
        return eventData;
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
    public static String DCX_Assign_Work_Order_To_Tech_WS(String UserId, List<String> WorkOrderIds, String TechnicianId, Boolean SetOwner){
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
                for(SVMXC__Service_Order__c wo: [SELECT Id, SVMXC__Last_Dispatch_Event__c,
                                                 SVMXC__Locked_By_DC__c,SVMXC__Service_Group__c, 
                                                 SVMXC__Group_Member__c, OwnerId, 
                                                 SVMXC__First_Assigned_DateTime__c, 
                                                 SVMXC__NoOfTimesAssigned__c  from 
                                                 SVMXC__Service_Order__c where Id IN :WorkOrderIds])
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
                    // if(COMM_SecurityUtils.getInstance().verifyFieldAccess(UpdatedWorkOrder, COMM_SecurityUtils.Access.Upsertable)){
                        COMM_SecurityUtils.getinstance().updateAsUser(UpdatedWorkOrder); //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    // } else {
                    //     throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    // }
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

    public class unassignAssign_WP{
        public String deletedEvents{get; set;}
        public DCX_CommonServiceManager.DCEvent_WO_WP techEventIds{get; set;}
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
    public static unassignAssign_WP DCX_UnAssignAssign_Work_Order_To_MultiTech_WS2(String UserId, List<String> WorkOrderIds, String TechnicianId, String timeZone, List<Event> EventList, Boolean setOwner, list<DCX_Wrapper.SVMX_StringMap> lstKeyValue,String techSFId,List<String> woFields,boolean updatePrimaryTech,boolean deleteEventForOtherTechs){
        unassignAssign_WP response = new unassignAssign_WP();
        List<String> EventIds = new List<String>();
        String StatusMessage;
        DCX_CommonServiceManager.DCEvent_WO_WP eventData = 
            new DCX_CommonServiceManager.DCEvent_WO_WP();

        //set the flag true when technician is unassigned using DC(linx for servicepower integration)
        WSCH_OptimizedSchedulingService.isUnAssignDC=true;

        Savepoint sp = Database.setSavepoint();
        try
        {
            // Bala(1-4-11): If work order is passed do unassignment
            if(WorkOrderIds != NULL && WorkOrderIds.size() > 0)
                StatusMessage = DCX_Unassign_Work_Order_WS(UserId, WorkOrderIds);
            // Bala(24-3-11): When technician id is not given don't do work order assignment
            if(TechnicianId != NULL && TechnicianId != '')
               DCX_Assign_Work_Order_To_Tech_WS(UserId, WorkOrderIds, TechnicianId, setOwner);
            if(EventList.size()>0)
                eventData = DCX_EventServiceManager.createEvents(EventList, timeZone, lstKeyValue,TechnicianId,updatePrimaryTech,deleteEventForOtherTechs,techSFId,woFields); //Changed by Gm to WS3 on 7jun10
            response.deletedEvents = StatusMessage;
            response.techEventIds = eventData;
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
    public static String DCX_Unassign_Work_Order_WS(String UserId, List<String> WorkOrderIds){
        String StatusMessage;
        //Validations
        if(WorkOrderIds.size()==0)
            throw new SVMXException('Please provide some workorders to unassign');

        try
        {
            boolean settingRetainDCLock = false;
            Map<String,String> svmxSettingList = COMM_Utils_ManageSettings.SVMX_getuniqueSettingValue('DCON001','SET022');
            if(svmxSettingList.Containskey('SET022') && svmxSettingList.get('SET022')=='True')
                settingRetainDCLock = true;
            else
                settingRetainDCLock = false;

            //Unschedule the work orders related events
            StatusMessage = DCX_Unschedule_Work_Order_WS(UserId, WorkOrderIds);

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
            // if(COMM_SecurityUtils.getInstance().verifyFieldAccess(UpdatedWorkOrder, COMM_SecurityUtils.Access.Upsertable)){
                COMM_SecurityUtils.getinstance().upsertAsUser(UpdatedWorkOrder); //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            // } else {
            //     throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            // }
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
    public static String DCX_Unschedule_Work_Order_WS(String UserId, List<String> WorkOrderIds){
        String StatusMessage = '';

        List<Event> events = new List<Event>();
        List<SVMXC__SVMX_Event__c> SVMXevents = new List<SVMXC__SVMX_Event__c>();
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        //Validations

        if(WorkOrderIds.size()==0)
            throw new SVMXException('Please provide some workorders to unschedule');    
        try{
           // Map<String,String> svmxSettingList = COMM_Utils_ManageSettings.SVMX_getuniqueSettingValue('DCON001','SET024');

             List<String> settingIds = new List<String>{'DCON001_SET024'};
            Map<String,String> svmxSettingList = COMM_Utils_ManageSettings.SVMX_getSettingValueForList(settingIds);

            if(svmxSettingList.Containskey('DCON001_SET024') && svmxSettingList.get('DCON001_SET024')=='True')
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
                // if(COMM_SecurityUtils.getInstance().isDeletableObject('Event')){
                    COMM_SecurityUtils.getinstance().deleteAsUser(events); //SDL-SVMX-DELETE-FLS-ENFORCED
                // } else {
                //     throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                // }
            }
            if(SVMXevents.size()>0){
                // if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SVMX_Event__c')){
                    COMM_SecurityUtils.getinstance().deleteAsUser(SVMXevents); //SDL-SVMX-DELETE-FLS-ENFORCED
                // } else {
                //     throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                // }
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
    public static DCX_CommonServiceManager.DCEvent_WO_WP DCX_UnAssignAssign_Work_Order_To_MultiTech_WS3(String UserId, List<String> WorkOrderIds, String TechnicianId, String timeZone, List<Event> EventList, Boolean setOwner, list<DCX_Wrapper.SVMX_StringMap> lstKeyValue,String techSFId,List<String> woFields){
        List<String> EventIds = new List<String>();
        String StatusMessage;
        DCX_CommonServiceManager.DCEvent_WO_WP eventData = 
            new DCX_CommonServiceManager.DCEvent_WO_WP();

        //set the flag true when technician is unassigned using DC(linx for servicepower integration)
        WSCH_OptimizedSchedulingService.isUnAssignDC=true;

        Savepoint sp = Database.setSavepoint();
        try
        {
            // Bala(1-4-11): If work order is passed do unassignment
            if(WorkOrderIds != NULL && WorkOrderIds.size() > 0)
                StatusMessage = DCX_Unassign_Work_Order_WS1(UserId, WorkOrderIds);
            // Bala(24-3-11): When technician id is not given don't do work order assignment
            if(TechnicianId != NULL && TechnicianId != '')
               DCX_Assign_Work_Order_To_Tech_WS(UserId, WorkOrderIds, TechnicianId, setOwner);
            //if(EventList.size()>0)
                eventData = DCX_EventServiceManager.createEvents(EventList, timeZone, lstKeyValue,TechnicianId,false,false,techSFId,woFields); //Changed by Gm to WS3 on 7jun10
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
        return eventData;
    }
    /**
     * Name             :   DCON_Unassign_Work_Order_WS1
     * Params           :   String UserId
                            List<String> WorkOrderIds
     * Returns          :   String      
     * Description      :   Updates the primary technician of WO but don't delete any events
     */ 
    public static String DCX_Unassign_Work_Order_WS1(String UserId, List<String> WorkOrderIds){
        String StatusMessage;
        //Validations
        if(WorkOrderIds.size()==0)
            throw new SVMXException('Please provide some workorders to unassign');

        try
        {
            boolean settingRetainDCLock = false;
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
            Map<String,String> svmxSettingList = COMM_Utils_ManageSettings.SVMX_getuniqueSettingValue('DCON001','SET022');
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

            // if(COMM_SecurityUtils.getInstance().verifyFieldAccess(UpdatedWorkOrder, COMM_SecurityUtils.Access.Upsertable)){
                COMM_SecurityUtils.getinstance().upsertAsUser(UpdatedWorkOrder); //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            // } else {
            //     throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            // }
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
    public without sharing class DCX_AES_EventServiceManager_Util {
        public  list<event> getLstSFEventforTech(set<string> lstOwnerID, DateTime inputStartTime, DateTime inputEndTime)
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
    }

}