global class DCON_Event_WS {

    public class SVMXException extends Exception {}
    public static DCON_Utils dcUtils = new DCON_Utils();

    //CRUD security related functions
    public static COMM_SecurityUtils securityUtils = COMM_SecurityUtils.getInstance();

    public static boolean isSplRelatedHandling = false;
    public static string apiName = 'SVMXC__Service_Group_Members__c';
    public static set<string> setApiName = new set<string>();
    public static Map<String, String> dcon005SettingList = new Map<String, String>();
    public static Map<String, String> svmxSettingList = new Map<String, String>(DCON_Event_WS.loadDCsetting());    

    public static Map<String, String> loadDCsetting()
    { 
        try
        {
            if(SVMX_Constants.AllDCSettingList == NULL || SVMX_Constants.AllDCSettingList.size() == 0)
            {
                list<string> lstSubModules = new list<string>{'DCON001','GLOB001','DCON005','OMAX003'};
                SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
                SVMX_Constants.AllDCSettingList = commSettings.SVMX_getSettingList(lstSubModules);
            }
            system.debug('svmxSettingList '+svmxSettingList);
            if(SVMX_Constants.AllDCSettingList.containsKey('DCON005') && SVMX_Constants.AllDCSettingList.get('DCON005') != null)
                dcon005SettingList = SVMX_Constants.AllDCSettingList.get('DCON005');
            if(dcon005SettingList.size()>0 && dcon005SettingList.ContainsKey('SET001'))
                isSplRelatedHandling =  boolean.valueOf(dcon005SettingList.get('SET001'));
            if(dcon005SettingList.size()>0 && dcon005SettingList.ContainsKey('SET002') && dcon005SettingList.get('SET002') != null && dcon005SettingList.get('SET002') != '')
                apiName = dcon005SettingList.get('SET002');
            set<string> ApiNameset = new set<string>();
            if(apiName.length()>0)
                ApiNameset.addAll(apiName.split(','));
            for(string str:ApiNameset){
                if (str != '' && str.length() > 0)
                    setApiName.add(str.trim());
                isSplRelatedHandling = false;
                //if(SVMX_Constants.AllDCSettingList.containsKey('OMAX003') && SVMX_Constants.AllDCSettingList.get('OMAX003') != null)
                //dcon005SettingList = SVMX_Constants.AllDCSettingList.get('OMAX003');
            }
        } catch(Exception ex)
        {
            throw new SVMXException(ex.getMessage());
        }
        return  SVMX_Constants.AllDCSettingList.get('DCON001');
    }

    global class DCEvent_WO_WP
    {
        WebService list<Events_WP> lstEvent {get; set;}
        WebService DCON_Work_Order_WS.workorder_WP objWorkOrder {get; set;}
        WebService String strWOAction {get; set;}
    }

    global class DCEvent_WP
    {
        WebService String id{get; set;}
        WebService String subject {get; set;}
        WebService String durationInMinutes {get; set;}
        WebService String description {get; set;}
        WebService String whatId {get; set;}
        WebService String whoId {get; set;}
        WebService String activityDate {get; set;}
        WebService String activityDateTime {get; set;}
        WebService String startDateTime {get; set;}
        WebService String endDateTime {get; set;}
        WebService String location {get; set;}
        WebService String ownerId {get; set;}
        WebService String TechId {get; set;}
        WebService Boolean isWorkOrder {get; set;}// To find is it WO event
        WebService String additionalInfo {get; set;}// Provides find is it WO event
        WebService DateTime lastModifiedDateTime {get; set;}
        webservice list<KeyValuePair_WP> lstKeyValuePair{get; set;}
        webservice list<string> EvntHovrAdditionalInfo{get; set;}

        // These below fields are being introduced or being moved from WO (2 fields)
        WebService String Driving_Time {get; set;}
        WebService String Overhead_Time_Before {get; set;}
        WebService String Overhead_Time_After {get; set;}
        WebService String Driving_Time_Home {get; set;}
        WebService String Service_Duration {get; set;} //from WO
        WebService String Break_Time_Total {get; set;} //from WO
        WebService String Type {get; set;}
        WebService boolean IsAllDayEvent {get; set;}
        WebService String latitude {get; set;}
        WebService String longitude {get; set;}


    }

    global class Events_WP
    {
        WebService DCEvent_WP event_WP {get;set;}
        WebService long lastSyncedTime;
        WebService boolean isEventThresholdMet {get; set;}
        Events_WP(){

        }
        Events_WP(DCEvent_WP e){
            event_WP = e;
        }
    }

    global class KeyValuePair_WP
    {
        WebService String keyType{get; set;}
        WebService String key{get; set;}
        WebService String value{get; set;}
        KeyValuePair_WP(String keyType, String key, String value)
        {
            this.keyType = keyType;
            this.key = key;
            this.value = value;
        }   
    }

    // This call is to get work order updated information once event has been created or edited
    WebService static DCEvent_WO_WP GetEventWOInfo_WS(List<String> lstEventIds, String UserId, List<String> keyValPairs, String ViewId, List<String> DispatchStatus, String timeZoneDateTimeFormat, List<String> workorderIds)
    {        
        Boolean isLocal = false;        
        DCEvent_WO_WP response = new DCEvent_WO_WP();        
        List<Event> lstSalesforceEvents = new List<Event>();
        List<SVMXC__SVMX_Event__c> lstServiceMaxEvents = new List<SVMXC__SVMX_Event__c>();        
        List<Events_WP> lstEventWP = new List<Events_WP>();
        List<DCON_Work_Order_WS.workorder_WP> lstWorkOrderWP = new List<DCON_Work_Order_WS.workorder_WP>();        
        Map<String,String> mapValidSettingsForUpdate = new Map<String,String>();
        mapValidSettingsForUpdate = getValidateSettingsFrom38To47();
        set<String> flds = new set<String>();
        string timeZone;
        try
        {
            System.debug(logginglevel.warn,'TEST LOG: ' + lstEventIds);
            if(lstEventIds != NULL && lstEventIds.size() > 0)
            {
                // When passing null as value for lstEventIds, there is data mismatch. So flex will set the value of the lstEventIds as String 'null'. When it is null we just skip the event retrieval 
                Boolean isValid = TRUE;
                if(lstEventIds.size() == 1)
                {
                    if(lstEventIds[0].toUpperCase() == 'NULL')
                        isValid = FALSE;
                }
                if(isValid == TRUE)
                {
                    // Salesforce/ServiceMax events are retrieved for the requested Ids
                    if(mapValidSettingsForUpdate.keySet().size() > 0)
                    {
                        for(String strfld : mapValidSettingsForUpdate.keySet())
                        {
                            flds.add(mapValidSettingsForUpdate.get(strfld)); 
                        }
                        
                        flds.add('SVMXC__Driving_Time__c');
                        flds.add('SVMXC__Driving_Time_Home__c');
                        flds.add('SVMXC__Overhead_Time_Before__c');
                        flds.add('SVMXC__Overhead_Time_After__c');
                        flds.add('SVMXC__Service_Duration__c');
                        flds.add('SVMXC__Break_Time_Total__c');
                        flds.add('SVMXC__SM_Latitude__c');
                        flds.add('SVMXC__SM_Longitude__c');
                        
                        // This is the change due to the introduction of new fields in event objects
                        lstSalesforceEvents = Database.query('Select Id, Type, ActivityDate, ActivityDateTime, IsAllDayEvent, OwnerId, DurationInMinutes, Subject, Description, WhatId, StartDateTime, EndDateTime, Location, LastModifiedDate, ' + SVMX_getFieldNamesFromList(flds) +' from Event where Id IN :lstEventIds and IsRecurrence = false' );
                        
                        lstServiceMaxEvents = Database.query('Select Id, SVMXC__Type__c, SVMXC__ActivityDate__c, SVMXC__ActivityDateTime__c, SVMXC__Technician__c, SVMXC__DurationInMinutes__c, Name,SVMXC__Description__c, SVMXC__WhatId__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c, SVMXC__Location__c, SVMXC__IsAllDayEvent__c, LastModifiedDate,     ' + SVMX_getFieldNamesFromList(flds) +' from SVMXC__SVMX_Event__c where Id IN :lstEventIds' );

                    }
                    else
                    {
                        // This is the change due to the introduction of new fields in event objects
                        lstSalesforceEvents = [Select Id, Type, ActivityDate, ActivityDateTime, IsAllDayEvent, OwnerId, DurationInMinutes, Subject, Description, WhatId, StartDateTime, EndDateTime, Location, LastModifiedDate,SVMXC__Driving_Time__c, SVMXC__Overhead_Time_Before__c, SVMXC__Overhead_Time_After__c, SVMXC__Driving_Time_Home__c, SVMXC__Service_Duration__c,SVMXC__Break_Time_Total__c,SVMXC__SM_Latitude__c,SVMXC__SM_Longitude__c from Event where Id IN :lstEventIds and IsRecurrence = false];
                        
                        lstServiceMaxEvents = [Select Id, SVMXC__Type__c, SVMXC__ActivityDate__c, SVMXC__ActivityDateTime__c, SVMXC__Technician__c, SVMXC__DurationInMinutes__c, Name,SVMXC__Description__c, SVMXC__WhatId__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c, SVMXC__Location__c, LastModifiedDate,SVMXC__Driving_Time__c, SVMXC__IsAllDayEvent__c,SVMXC__Overhead_Time_Before__c, SVMXC__Overhead_Time_After__c, SVMXC__Driving_Time_Home__c, SVMXC__Service_Duration__c,SVMXC__Break_Time_Total__c,SVMXC__SM_Latitude__c,SVMXC__SM_Longitude__c from SVMXC__SVMX_Event__c where Id IN :lstEventIds];
                    }
                    mapValidSettingsForUpdate.clear();
                    list<string> lstTimeZoneDateTime = new list<string>();
                    lstTimeZoneDateTime = timeZoneDateTimeFormat.split('@');
                    timeZone = lstTimeZoneDateTime.get(0);
                   
                    if(timeZone != NULL && timeZone != '')
                    {
                        if(Userinfo.getTimeZone().getID() == timeZone)
                            isLocal = true;
                    }
                    else
                    {
                        timeZone = Userinfo.getTimeZone().getID();
                        isLocal = true;
                    } 
                    
                    lstEventWP = DCON_Retrieve_Events_WS(lstSalesforceEvents, lstServiceMaxEvents, UserId, timeZoneDateTimeFormat, isLocal);
                    System.debug('TEST LOG: ' + lstEventWP);
                    
                    if(lstEventWP.size() > 0)
                        response.lstEvent = lstEventWP;
                }
            }
            lstSalesforceEvents.clear();
            lstServiceMaxEvents.clear();

            if(workorderIds != NULL && workorderIds.size() > 0)
            {
                lstWorkOrderWP = DCON_Work_Order_WS.DCON_Retrieve_Work_Orders(UserId, ViewId, DispatchStatus, timeZone, workorderIds, keyValPairs);

                if(lstWorkOrderWP.size() > 0)
                {
                    response.objWorkOrder = lstWorkOrderWP[0]; // Since we will be sending only one work order we consider only the first record
                    if(response.objWorkOrder.workorder_O != null)
                        response.strWOAction = 'WO_ACTION_UPDATE';
                    else 
                        response.strWOAction = 'WO_ACTION_ELIMINATED';
                }
                else
                {
                    lstWorkOrderWP = DCON_Work_Order_WS.DCON_Retrieve_Eliminated_Work_Order_Info(UserId, timeZone, workorderIds);
                    if(lstWorkOrderWP.size() > 0)
                    {
                        response.objWorkOrder = lstWorkOrderWP[0];   
                        response.strWOAction = 'WO_ACTION_ELIMINATED';
                    }

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
        System.debug(logginglevel.Warn,'response: '+ response);
        return response;
    }
    
    WebService static List<Events_WP> Retrieve_Updated_Events_WS(String UserId, String StartDate, String EndDate, String EventType, String timeZoneDateTimeFormat, String lastRetrievedDate, List<String> TechnicianIds)
    {
        SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils(); 
        Boolean isLocal = false;
        system.debug(LoggingLevel.WARN,'Input Data '+StartDate+'  '+EndDate+'  '+lastRetrievedDate+' '+TechnicianIds);  
        Datetime dtmLastRetrievedDateTime;        
        List<String> SFUSerIds = new List<String>();
        List<String> SVMXUserIds = new List<String>();
        List<Event> lstSalesforceEvents = new List<Event>();
        List<SVMXC__SVMX_Event__c> lstServiceMaxEvents = new List<SVMXC__SVMX_Event__c>();        
        set<String> techlst = new set<String>();        
        List<Events_WP> resultSet = new List<Events_WP>();
        Map<String,String> mapValidSettingsForUpdate = new Map<String,String>();
        mapValidSettingsForUpdate = getValidateSettingsFrom38To47();

        try
        {
            dtmLastRetrievedDateTime = Datetime.valueOf(long.valueOf(lastRetrievedDate));
            techlst.addAll(TechnicianIds);            
            list<string> lstTimeZoneDateTime = new list<string>();
            lstTimeZoneDateTime = timeZoneDateTimeFormat.split('@');
            string timeZone = lstTimeZoneDateTime.get(0);

            if(timeZone != NULL && timeZone != '')
            {
                if(Userinfo.getTimeZone().getID() == timeZone)
                    isLocal = true;
            }
            else
            {
                timeZone = Userinfo.getTimeZone().getID();
                isLocal = true;
            }

            for(SVMXC__Service_Group_Members__c tl: [Select id,SVMXC__Salesforce_User__c from SVMXC__Service_Group_Members__c where Id IN :techlst])  
            {
                //Get all user Id associated with SF tech to retrieve SF event
                if(tl.SVMXC__Salesforce_User__c!=NULL)
                    SFUSerIds.add(tl.SVMXC__Salesforce_User__c);
            }
            techlst.clear();
            system.debug(LoggingLevel.WARN,'SFUSerIds'+SFUSerIds);

            if(EventType.toUpperCase()=='SALESFORCEEVENT' || EventType.toUpperCase()=='ALL')
            {
                Date DStartDate = Date.valueOf(StartDate);
                Date DEndDate = Date.valueOf(EndDate);
                try
                {
                    DateTime dtmStartDateTime = dcUtils.getDateTimeInTimezone(Date.valueOf(StartDate), Time.newInstance(0, 0, 0, 0), timeZone);
                    DateTime dtmEndDateTime = dcUtils.getDateTimeInTimezone(Date.valueOf(EndDate), Time.newInstance(23, 59, 59, 59), timeZone);

                    if(mapValidSettingsForUpdate.keySet().size() > 0)
                    {
                        set<String> flds = new set<String>();
                        for(String strfld : mapValidSettingsForUpdate.keySet())
                        {
                            flds.add(mapValidSettingsForUpdate.get(strfld)); 
                        }
                        String whereStr = ' where LastModifiedDate >= :dtmLastRetrievedDateTime and ((StartDateTime >= : dtmStartDateTime and StartDateTime <= : dtmEndDateTime) OR (EndDateTime >= : dtmStartDateTime and StartDateTime <= : dtmEndDateTime)) and OwnerId IN :SFUSerIds and IsRecurrence = false';
                        system.debug(LoggingLevel.WARN,'SFEvent where clause'+whereStr);  

                        flds.add('SVMXC__Driving_Time__c');
                        flds.add('SVMXC__Overhead_Time_Before__c');
                        flds.add('SVMXC__Overhead_Time_After__c');
                        flds.add('SVMXC__Driving_Time_Home__c');
                        flds.add('SVMXC__Service_Duration__c');
                        flds.add('SVMXC__Break_Time_Total__c');
                        flds.add('SVMXC__SM_Latitude__c');
                        flds.add('SVMXC__SM_Longitude__c');
                        
                        // This is the change due to the introduction of new fields in event objects
                        lstSalesforceEvents = Database.query('Select Id, Type, ActivityDate, ActivityDateTime, IsAllDayEvent, OwnerId, DurationInMinutes, Subject, Description, WhatId, StartDateTime, EndDateTime, Location, LastModifiedDate, ' + SVMX_getFieldNamesFromList(flds) +' from Event ' + whereStr );
                    }
                    else
                    {
                        // This is the change due to the introduction of new fields in event objects
                        lstSalesforceEvents = [Select Id, Type, ActivityDate, ActivityDateTime, IsAllDayEvent, OwnerId, DurationInMinutes, Subject, Description, WhatId, StartDateTime, EndDateTime, Location, LastModifiedDate,SVMXC__Driving_Time__c, SVMXC__Overhead_Time_Before__c, SVMXC__Overhead_Time_After__c, SVMXC__Driving_Time_Home__c, SVMXC__Service_Duration__c,SVMXC__Break_Time_Total__c,SVMXC__SM_Latitude__c,SVMXC__SM_Longitude__c from Event where LastModifiedDate >= :dtmLastRetrievedDateTime and ((StartDateTime >= : dtmStartDateTime and StartDateTime <= : dtmEndDateTime) OR (EndDateTime >= : dtmStartDateTime and StartDateTime <= : dtmEndDateTime)) and OwnerId IN :SFUSerIds and IsRecurrence = false];

                    }
                }
                catch(Exception ex)
                {
                    throw new SVMXException(ex);
                }
            }

            // Getting ServiceMax events
            if(EventType.toUpperCase()=='SERVICEMAXEVENT' || EventType.toUpperCase()=='ALL')
            {
                //lstServiceMaxEvents = DCON_Event_WS.DCON_Retrieve_ServiceMax_Events_WS(timeZone, StartDate, EndDate, SVMXUserIds);
                Date DStartDate = Date.valueOf(StartDate);
                Date DEndDate = Date.valueOf(EndDate);
                try
                {
                    DateTime dtmStartDateTime = dcUtils.getDateTimeInTimezone(Date.valueOf(StartDate), Time.newInstance(0, 0, 0, 0), timeZone);
                    DateTime dtmEndDateTime = dcUtils.getDateTimeInTimezone(Date.valueOf(EndDate), Time.newInstance(23, 59, 59, 59), timeZone);
                    
                    if(mapValidSettingsForUpdate.keySet().size() > 0)
                    {
                        set<String> flds = new set<String>();
                        for(String strfld : mapValidSettingsForUpdate.keySet())
                        {
                            flds.add(mapValidSettingsForUpdate.get(strfld)); 
                        }
                        String whereStr = ' where LastModifiedDate >= :dtmLastRetrievedDateTime and ((SVMXC__StartDateTime__c >= : dtmStartDateTime and SVMXC__StartDateTime__c <= : dtmEndDateTime) OR (SVMXC__EndDateTime__c >= : dtmStartDateTime and SVMXC__StartDateTime__c <= : dtmEndDateTime)) and SVMXC__Technician__c IN :TechnicianIds';

                        flds.add('SVMXC__Driving_Time__c');
                        flds.add('SVMXC__Overhead_Time_Before__c');
                        flds.add('SVMXC__Overhead_Time_After__c');
                        flds.add('SVMXC__Driving_Time_Home__c');
                        flds.add('SVMXC__Service_Duration__c');
                        flds.add('SVMXC__Break_Time_Total__c');
                        flds.add('SVMXC__IsAllDayEvent__c');
                        flds.add('SVMXC__Description__c');
                        flds.add('SVMXC__Location__c');
                        flds.add('SVMXC__SM_Latitude__c');
                        flds.add('SVMXC__SM_Longitude__c');
                        
                        // This is the change due to the introduction of new fields in event objects
                        lstServiceMaxEvents = Database.query('Select Id, SVMXC__Type__c, SVMXC__ActivityDate__c, SVMXC__ActivityDateTime__c, SVMXC__Technician__c, SVMXC__DurationInMinutes__c, Name, SVMXC__WhatId__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c, LastModifiedDate, ' + SVMX_getFieldNamesFromList(flds) +' from SVMXC__SVMX_Event__c ' + whereStr );
                    }
                    else
                    {
                        // This is the change due to the introduction of new fields in event objects
                        lstServiceMaxEvents = [Select Id, SVMXC__Type__c, SVMXC__ActivityDate__c, SVMXC__ActivityDateTime__c, SVMXC__Technician__c, SVMXC__DurationInMinutes__c, Name,SVMXC__Description__c, SVMXC__WhatId__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c, SVMXC__Location__c, LastModifiedDate,SVMXC__Driving_Time__c, SVMXC__IsAllDayEvent__c,SVMXC__Overhead_Time_Before__c, SVMXC__Overhead_Time_After__c, SVMXC__Driving_Time_Home__c, SVMXC__Service_Duration__c,SVMXC__Break_Time_Total__c,SVMXC__SM_Latitude__c,SVMXC__SM_Longitude__c from SVMXC__SVMX_Event__c where LastModifiedDate >= :dtmLastRetrievedDateTime and ((SVMXC__StartDateTime__c >= : dtmStartDateTime and SVMXC__StartDateTime__c <= : dtmEndDateTime) OR (SVMXC__EndDateTime__c >= : dtmStartDateTime and SVMXC__StartDateTime__c <= : dtmEndDateTime)) and SVMXC__Technician__c IN :TechnicianIds];
                    }
                    mapValidSettingsForUpdate.clear();
                }
                catch(Exception ex)
                {
                    throw new SVMXException(ex);
                }
            }
            resultSet = DCON_Retrieve_Events_WS(lstSalesforceEvents, lstServiceMaxEvents,UserId, timeZoneDateTimeFormat, isLocal);
            
            if(resultSet != null && resultSet.size() > 0 )
            {
                resultSet.get(resultSet.size()-1).lastSyncedTime = DateTime.now().getTime();
            }
            else
            {
                Events_WP obj = new Events_WP();
                obj.lastSyncedTime = DateTime.now().getTime();
                resultSet.add(obj);
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
        return resultSet;
    }

    WebService static List<String> Retrieve_Deleted_Events_WS(String UserId, String StartDate, String EndDate, String EventType, String timeZone, String lastRetrievedDate, List<String> TechnicianIds)
    {
        List<String> lstDeletedEvents = new List<String>();
        SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();
        Boolean isLocal = false;        
        Datetime dtmLastRetrievedDateTime;        
        List<String> SFUSerIds = new List<String>();
        List<String> SVMXUserIds = new List<String>();
        List<SVMXC__SVMX_Event__c> lstServiceMaxEvents = new List<SVMXC__SVMX_Event__c>();        
        set<String> techlst = new set<String>();

        try
        {
            dtmLastRetrievedDateTime = Datetime.valueOf(long.valueOf(lastRetrievedDate));
            techlst.addAll(TechnicianIds);

            if(timeZone != NULL && timeZone != '')
            {
                if(Userinfo.getTimeZone().getID() == timeZone)
                    isLocal = true;
            }
            else
            {
                timeZone = Userinfo.getTimeZone().getID();
                isLocal = true;
            }

            for(SVMXC__Service_Group_Members__c tl: [Select id,SVMXC__Salesforce_User__c from SVMXC__Service_Group_Members__c where Id IN :techlst])  
            {
                if(tl.SVMXC__Salesforce_User__c!=NULL)
                    SFUSerIds.add(tl.SVMXC__Salesforce_User__c);
                else
                    SVMXUserIds.add(tl.Id);
            }

            if(EventType.toUpperCase()=='SALESFORCEEVENT' || EventType.toUpperCase()=='ALL')
            {
                Date DStartDate = Date.valueOf(StartDate);
                Date DEndDate = Date.valueOf(EndDate);
                DateTime dtmStartDateTime = dcUtils.getDateTimeInTimezone(Date.valueOf(StartDate), Time.newInstance(0, 0, 0, 0), timeZone);
                DateTime dtmEndDateTime = dcUtils.getDateTimeInTimezone(Date.valueOf(EndDate), Time.newInstance(23, 59, 59, 59), timeZone);
                try
                {

                    // This is the change due to the introduction of new fields in event objects
                    for(Event objEvent: [Select Id, Type, ActivityDate, ActivityDateTime, IsAllDayEvent, OwnerId, DurationInMinutes, Subject, Description, WhatId, StartDateTime, EndDateTime, Location,SVMXC__Driving_Time__c, SVMXC__Overhead_Time_Before__c, SVMXC__Overhead_Time_After__c, SVMXC__Driving_Time_Home__c, SVMXC__Service_Duration__c,SVMXC__Break_Time_Total__c from Event where LastModifiedDate >= :dtmLastRetrievedDateTime and ( ( (EndDateTime < :dtmStartDateTime or StartDateTime > :dtmEndDateTime) and OwnerId NOT IN :TechnicianIds and IsRecurrence = false) or ( isdeleted= true ) ) ALL ROWS])
                    {
                        lstDeletedEvents.add(objEvent.Id);
                    }
                }
                catch(Exception ex)
                {
                    throw new SVMXException(ex);
                }

            }

            if(EventType.toUpperCase()=='SERVICEMAXEVENT' || EventType.toUpperCase()=='ALL')
            {
                Date DStartDate = Date.valueOf(StartDate);
                Date DEndDate = Date.valueOf(EndDate);
                DateTime dtmStartDateTime = dcUtils.getDateTimeInTimezone(Date.valueOf(StartDate), Time.newInstance(0, 0, 0, 0), timeZone);
                DateTime dtmEndDateTime = dcUtils.getDateTimeInTimezone(Date.valueOf(EndDate), Time.newInstance(23, 59, 59, 59), timeZone);
                
                try
                {

                    // This is the change due to the introduction of new fields in event objects
                    for(SVMXC__SVMX_Event__c objEvent: [Select Id, SVMXC__Type__c, SVMXC__ActivityDate__c, SVMXC__ActivityDateTime__c, SVMXC__Technician__c, SVMXC__DurationInMinutes__c, Name,SVMXC__Description__c, SVMXC__WhatId__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c, SVMXC__Location__c, SVMXC__Driving_Time__c, SVMXC__IsAllDayEvent__c,SVMXC__Overhead_Time_Before__c, SVMXC__Overhead_Time_After__c, SVMXC__Driving_Time_Home__c, SVMXC__Service_Duration__c,SVMXC__Break_Time_Total__c from SVMXC__SVMX_Event__c where LastModifiedDate >= :dtmLastRetrievedDateTime and ( ( (SVMXC__EndDateTime__c < :dtmStartDateTime or SVMXC__StartDateTime__c > :dtmEndDateTime) and SVMXC__Technician__c NOT IN :TechnicianIds) or ( isdeleted= true ) ) ALL ROWS])
                    {
                        lstDeletedEvents.add(objEvent.Id);
                    }

                }
                catch(Exception ex)
                {
                    throw new SVMXException(ex);
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
        return lstDeletedEvents;
    }
    
    //This method retrieve events based on technicians Ids
    WebService static List<Events_WP> DCON_Retrieve_Events_WS(String UserId, String StartDate, String EndDate, String EventType, String timeZoneDateTimeFormat, List<String> TechnicianIds)
    {
        SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils(); 
        Boolean isLocal = false;
        List<String> SFUSerIds = new List<String>();
        List<String> SVMXUserIds = new List<String>();
        List<Event> lstSalesforceEvents = new List<Event>();
        List<SVMXC__SVMX_Event__c> lstServiceMaxEvents = new List<SVMXC__SVMX_Event__c>();
        set<String> techlst = new set<String>();
        List<Events_WP> resultSet = new List<Events_WP>();
        try
        {
            techlst.addAll(TechnicianIds);
            list<string> lstTimeZoneDateTime = new list<string>();
            lstTimeZoneDateTime = timeZoneDateTimeFormat.split('@');
            string timeZone = lstTimeZoneDateTime.get(0);
            lstTimeZoneDateTime.clear();

            if(timeZone != NULL && timeZone != '')
            {
                if(Userinfo.getTimeZone().getID() == timeZone)
                    isLocal = true;
            }
            else
            {
                timeZone = Userinfo.getTimeZone().getID();
                isLocal = true;
            }    
            //To support more than 14 day event for SF Tech, we are creating SVMX event based on the Config setting.According to the new logic we are retrieving both SF and SVMX Event for a technician
            for(SVMXC__Service_Group_Members__c tl: [Select id, SVMXC__Salesforce_User__c from SVMXC__Service_Group_Members__c where Id IN :techlst]) 
            {
                //Get all user Id associated with SF tech to retrieve SF event
                if(tl.SVMXC__Salesforce_User__c != NULL)
                    SFUSerIds.add(tl.SVMXC__Salesforce_User__c);
            } 

            lstSalesforceEvents = DCON_Event_WS.DCON_Retrieve_Salesforce_Events_WS(timeZone, StartDate, EndDate, SFUSerIds);
            lstServiceMaxEvents = DCON_Event_WS.DCON_Retrieve_ServiceMax_Events_WS(timeZone, StartDate, EndDate, TechnicianIds);
            
            resultSet = DCON_Retrieve_Events_WS(lstSalesforceEvents, lstServiceMaxEvents, UserId, timeZoneDateTimeFormat, isLocal);

            if(resultSet != null && resultSet.size() > 0 )
            {
                resultSet.get(resultSet.size()-1).lastSyncedTime = DateTime.now().getTime();
            }
            else
            {
                Events_WP obj = new Events_WP();
                obj.lastSyncedTime = DateTime.now().getTime();
                resultSet.add(obj);
            }

        }
        catch(Exception ex)
        {
            system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex);
        }

        system.debug(logginglevel.warn,'Event wrapper: ' + resultSet);
        return resultSet;
    }

    // Process the events and build custom Event wrapper with Hover rules for the given Salesforce Events and ServiceMax Evnets
    public static List<Events_WP> DCON_Retrieve_Events_WS(List<Event> lstSalesforceEvents, List<SVMXC__SVMX_Event__c> lstServiceMaxEvents, String UserId, String timeZoneDateTimeFormat, Boolean isLocal)
    {
        string timeZone;
        string DatetimeFormat;
        system.debug(LoggingLevel.WARN, 'Count of Salesforce Events: ' + lstSalesforceEvents.size() + '; Events: ' + lstSalesforceEvents);
        system.debug(LoggingLevel.WARN, 'Count of ServiceMax Events: ' + lstServiceMaxEvents.size() + '; Events: ' + lstServiceMaxEvents);
        map<string,string> mapSFIDTechId = new map<string,string>();
        mapSFIDTechId = getmapSFuserTechId(lstSalesforceEvents);
        SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();
        string FieldMapRTypeId;
        string RuleRecordTypeId;
        string ExpressionRTypeId;
        boolean supportNonWorkOrdEvent = true;        
        Map<id, sObject> mapWorkOrder;   
        Map<Id, List<Id>> mapEventHoverRuleIdFieldIdList = new Map<Id, List<Id>>();
        Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        Map<Id, List<DCEvent_WP>> mapWorkOrderEvents = new Map<Id, List<DCEvent_WP>>();
        Map<Id, SVMXC__ServiceMax_Processes__c> mapEventHoverRules  = new Map<Id, SVMXC__ServiceMax_Processes__c>();  
        Map<Id, SVMXC__ServiceMax_Config_Data__c> mapEventHoverFields = new Map<Id, SVMXC__ServiceMax_Config_Data__c>();
        Map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapEventHoverRuleIdExpr  = new Map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        set<String> WOIdsAddedtoResponse = new set<String>();
        List<String> WorkOrderIds = new List<String>();
        List<Events_WP> resultSet = new List<Events_WP>();

        for(RecordType recType : [Select SobjectType, Id, Name From RecordType where (SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'SVMX Rule') OR (SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name IN ('Expressions', 'Field Mapping'))])   
        {
            if(recType.Name == 'SVMX Rule')
                RuleRecordTypeId = recType.id;
            else if(recType.Name == 'Expressions')
                ExpressionRTypeId = recType.id;
            else if(recType.Name == 'Field Mapping')
                FieldMapRTypeId = recType.id;
        }

        try
        {        
            list<string> lstTimeZoneDateTime = new list<string>();

            lstTimeZoneDateTime = timeZoneDateTimeFormat.split('@');
            if(lstTimeZoneDateTime.size() == 2)
            {   
                timeZone = lstTimeZoneDateTime.get(0);                
                DatetimeFormat = lstTimeZoneDateTime.get(1);
            }
            system.debug(LoggingLevel.WARN, 'lstTimeZoneDateTime '+lstTimeZoneDateTime+'DatetimeFormat: ' + DatetimeFormat);        
            Schema.Describesobjectresult woDefinitions = allObjs.get('Service_Order__c').getDescribe();
            allObjs.clear();
            set<String> setDateTimeFields = new set<String>();
            set<String> setDateFields = new set<String>();
            set<String> setRefFields = new set<String>();
            Map<String, String> mapWOFieldNameLabel = new Map<String, String>();
            Set<String> setWOQueryFields = new Set<String>();
            setWOQueryFields.add('Id');
            setWOQueryFields.add('Name');
            setWOQueryFields.add('SVMXC__Service_Duration__c');
            setWOQueryFields.add('SVMXC__Driving_Time__c');

                // Get the labels for all the fields of Work Order and put them against field APIName
                Map<String, SObjectField> objWorkOrderFieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap();
                Map<String,Map<String,String>> mapFieldToPckLstValLbl = new Map<String,Map<String,String>>();
                Map<String,String> mapPicklistValLable = new Map<String,String>();
                for (String fieldKey : objWorkOrderFieldMap.keySet())
                {
                    Schema.SObjectField fsObj = objWorkOrderFieldMap.get(fieldKey); 
                    Schema.DescribeFieldResult field = fsObj.getDescribe();
                    if(field.isAccessible())
                    {
                        mapWOFieldNameLabel.put(field.getName(), field.getLabel());
                    }
                    if(String.valueOf(field.getType()) == 'PICKLIST') 
                    {
                        List<Schema.PicklistEntry> plv = field.getPicklistValues();
                        for( Schema.PicklistEntry f : plv)
                        {
                            mapPicklistValLable.put(f.getValue(),f.getLabel());
                        }
                        mapFieldToPckLstValLbl.put(fieldKey,mapPicklistValLable);
                    }
                }

            DCON_Utils.referenceFields_WP reference_M = dcUtils.SVMX_getReferenceFields(objWorkOrderFieldMap,true);
            objWorkOrderFieldMap.clear();
            List<String> allFields_L = reference_M.allFields_L; //Get the all field list
            List<String> refFields_L = reference_M.referenceFields_L; //Get the reference field list
            List<String> dateTimeFields_L = reference_M.dateTimeFields_L; //Get the dateTime field list
            List<String> dateFields_L = reference_M.dateFields_L; //Get the date field list
            Map<String,String> replacementRef = reference_M.replacementReference_M;  //Get the replacement reference field map
            Map<String,String> replacementNameField = reference_M.replacementField_M;  //Get the name field for reference map

            setDateTimeFields.addAll(dateTimeFields_L);
            setDateFields.addAll(dateFields_L);
            setRefFields.addAll(refFields_L);        
            Map<String, String> mapEventSettings = new Map<String, String>();
            // Get the custom Event fields to be displayed in Event Create/Edit window, from DCON001 SET038 to SET047
            mapEventSettings = getValidateSettingsFrom38To47();
            System.debug('mapEventSettings   '+mapEventSettings);
            
            // Get setting value to support Non-Work Order event
            if(svmxSettingList != NULL && svmxSettingList.containsKey('SET062') && svmxSettingList.get('SET062') != NULL)
                supportNonWorkOrdEvent = boolean.valueOf(svmxSettingList.get('SET062'));
            
            Map<String,String> EVTFieldDef = new Map<String,String>();
            Map<String, SObjectField> souObjfieldMapEVT = Schema.SObjectType.Event.fields.getMap();
            EVTFieldDef = dcUtils.SVMX_getAllFieldMap(souObjfieldMapEVT);
            souObjfieldMapEVT.clear();

            Map<String,String> SVMXEVTFieldDef = new Map<String,String>();
            Map<String, SObjectField> souObjfieldMapSVMXEVT = Schema.SObjectType.SVMXC__SVMX_Event__c.fields.getMap();
            SVMXEVTFieldDef = dcUtils.SVMX_getAllFieldMap(souObjfieldMapSVMXEVT);
            souObjfieldMapSVMXEVT.clear();
            Map<String, String> mapWOSettings = new Map<String, String>();
            // Get WO and event fields to be displayed in Event Create/Edit window, from DCON001 SET038 to SET047
            Map<String,String> mapValidSettingsForUpdate = DCON_Event_WS.getEvtandWofields();
            // Get WO fields to be displayed in Event Create/Edit window
            
            if(mapValidSettingsForUpdate.keySet().size() > 0)
            {
                for(String strfld : mapValidSettingsForUpdate.keySet())
                {
                    if((mapValidSettingsForUpdate.containsKey(strfld)) &&(!String.valueOf(mapValidSettingsForUpdate.get(strfld)).contains('Event.')))
                    {
                        mapWOSettings.put(strfld, mapValidSettingsForUpdate.get(strfld));
                    }

                }
            }

            // Process Salesforce events
            for(Event e: lstSalesforceEvents)
            {
                DCEvent_WP event_TWO = new DCEvent_WP();
                event_TWO.description = CheckNull(e.Description);
                event_TWO.IsAllDayEvent = e.IsAllDayEvent;
                event_TWO.durationInMinutes = CheckNull(String.valueof(e.DurationInMinutes));
                // This is the change due to the introduction of new fields in event objects
                // To make the event management smooth
                event_TWO.Driving_Time = CheckNull(String.valueof(e.SVMXC__Driving_Time__c));
                event_TWO.Overhead_Time_Before = CheckNull(String.valueof(e.SVMXC__Overhead_Time_Before__c));
                event_TWO.Overhead_Time_After = CheckNull(String.valueof(e.SVMXC__Overhead_Time_After__c));
                event_TWO.Driving_Time_Home = CheckNull(String.valueof(e.SVMXC__Driving_Time_Home__c));
                event_TWO.Service_Duration = CheckNull(String.valueof(e.SVMXC__Service_Duration__c));
                event_TWO.Break_Time_Total = CheckNull(String.valueof(e.SVMXC__Break_Time_Total__c));
                event_TWO.id = e.Id;
                event_TWO.ownerId = CheckNull(e.ownerId);
                
                if(mapSFIDTechId.containsKey(e.ownerId))
                    event_TWO.TechId = mapSFIDTechId.get(e.ownerId);
                
                event_TWO.subject = CheckNull(e.Subject);
                event_TWO.lastModifiedDateTime = e.LastModifiedDate;
                event_TWO.location = CheckNull(e.location); 

                //Defect# 014336 - added 'Type' field
                event_TWO.Type = CheckNull(e.Type);
                
                if(e.SVMXC__SM_Latitude__c == null)
                    {
                        event_TWO.latitude = 'undefined';
                    }
                else
                    {
                        event_TWO.latitude = String.valueOf(e.SVMXC__SM_Latitude__c);
                    }   
                if(e.SVMXC__SM_Longitude__c == null)
                    {
                        event_TWO.longitude = 'undefined';  
                    }
                else
                    {
                        event_TWO.longitude = String.valueOf(e.SVMXC__SM_Longitude__c);
                    }


                //To support non Work Order event, set whatId to null.
                if(supportNonWorkOrdEvent == true && e.WhatId != NULL)
                {
                    //Pavitra : Add additional checks to identify the non-WO
                    if(String.valueof(e.WhatId).startsWith(woDefinitions.getKeyPrefix()) == false)
                    {                       
                        if(isSplRelatedHandling == false|| (isSplRelatedHandling == true && setApiName != null && setApiName.size()> 0 && !setApiName.contains(String.valueOf((Id.ValueOf(e.WhatId).getsobjectType())))))
                            event_TWO.additionalInfo = 'SVMX.NONWO';
                        else
                            event_TWO.additionalInfo = '';
                        
                        e.WhatId = NULL;    
                    } 
                    else
                    {
                        event_TWO.additionalInfo = '';                             
                        // nothing, it should be considered NonWork order, with no association                      
                    }
                }
                else
                {
                    event_TWO.additionalInfo = '';
                }

                event_TWO.whatId = CheckNull(e.WhatId);            

                // Format the datetime in fixed 'MM/dd/yyyy hh:mm a' format, but in applicable time zone
                // Because, Flex needs the date time string to be in this format
                if(e.IsAllDayEvent)
                {
                    if(e.StartDateTime != NULL)
                    {
                        event_TWO.startDateTime = e.StartDateTime.formatGMT('MM/dd/yyyy hh:mm a');
                        if(e.DurationInMinutes != NULL)
                        {
                            event_TWO.endDateTime = e.StartDateTime.addMinutes(Integer.valueof(e.DurationInMinutes)).formatGMT('MM/dd/yyyy hh:mm a');
                        }
                    }
                }
                else if(isLocal == true)
                {
                    if(e.StartDateTime != NULL)
                    {
                        event_TWO.startDateTime = e.StartDateTime.format('MM/dd/yyyy hh:mm a');
                        if(e.DurationInMinutes != NULL)
                        {
                            event_TWO.endDateTime = e.StartDateTime.addMinutes(Integer.valueof(e.DurationInMinutes)).format('MM/dd/yyyy hh:mm a');
                        }
                    }
                }
                else
                {
                    if(e.StartDateTime != NULL)
                    {
                        event_TWO.startDateTime = e.StartDateTime.format('MM/dd/yyyy hh:mm a', timeZone);
                        if(e.DurationInMinutes != NULL)
                        {
                            event_TWO.endDateTime = e.StartDateTime.addMinutes(Integer.valueof(e.DurationInMinutes)).format('MM/dd/yyyy hh:mm a', timeZone);
                        }
                    }
                }

                // If there are custom Event fields to be displayed in Event Create/Edit window, add their values
                if(mapEventSettings.keySet().size() > 0)
                {
                    List<KeyValuePair_WP> lstEvtKeyVal = new List<KeyValuePair_WP>();
                    for(String strCurrentSetting : mapEventSettings.keySet())
                    {
                        if(mapEventSettings.containskey(strCurrentSetting) && mapEventSettings.get(strCurrentSetting) != null && EVTFieldDef.containskey(mapEventSettings.get(strCurrentSetting)) && EVTFieldDef.get(mapEventSettings.get(strCurrentSetting)) == 'DATETIME')
                        {                                              
                            if( e.get(mapEventSettings.get(strCurrentSetting)) != null ) 
                            {               
                                if(isLocal == true)
                                    lstEvtKeyVal.add(new KeyValuePair_WP('Settingfield',strCurrentSetting, ((Datetime)(e.get(mapEventSettings.get(strCurrentSetting)))).format('MM/dd/yyyy hh:mm a')));

                                else                            
                                    lstEvtKeyVal.add(new KeyValuePair_WP('Settingfield',strCurrentSetting, ((Datetime)(e.get(mapEventSettings.get(strCurrentSetting)))).format('MM/dd/yyyy hh:mm a', timeZone)));

                            }
                        }
                        else if(mapEventSettings.containskey(strCurrentSetting) && mapEventSettings.get(strCurrentSetting) != null && EVTFieldDef.containskey(mapEventSettings.get(strCurrentSetting)) && EVTFieldDef.get(mapEventSettings.get(strCurrentSetting)) == 'DATE')
                        {

                            if( e.get(mapEventSettings.get(strCurrentSetting)) != null )         
                                lstEvtKeyVal.add(new KeyValuePair_WP('Settingfield', strCurrentSetting, Date.valueof(e.get(mapEventSettings.get(strCurrentSetting))).format()));
                        }
                        else 
                            lstEvtKeyVal.add(new KeyValuePair_WP('Settingfield', strCurrentSetting, String.valueOf(e.get(mapEventSettings.get(strCurrentSetting)))));                                   
                    }
                    event_TWO.lstKeyValuePair = lstEvtKeyVal;
                    System.debug(logginglevel.warn,' Event Key Val'+lstEvtKeyVal);
                }  
                // Check What Id, and if Work Order, set the IsWorkOrder Flag
                if(e.WhatId != NULL)
                {
                    if(String.valueof(e.WhatId).startsWith(woDefinitions.getKeyPrefix()) == true)
                    {
                        event_TWO.isWorkOrder = true;
                        WorkOrderIds.add(e.WhatId);

                        List<DCEvent_WP> lstEventWP = new List<DCEvent_WP>();
                        lstEventWP.add(event_TWO);
                        if(mapWorkOrderEvents.get(e.WhatId) != NULL)
                            lstEventWP.addAll(mapWorkOrderEvents.get(e.WhatId));
                        mapWorkOrderEvents.put(e.WhatId, lstEventWP);
                    } 
                    //To support the setting based non-associated event identification
                    else 
                    {
                        If(isSplRelatedHandling == false|| (isSplRelatedHandling == true && setApiName != null && setApiName.size()> 0 && !setApiName.contains(String.valueOf((Id.ValueOf(e.WhatId).getsobjectType())))))
                        {
                            event_TWO.isWorkOrder = false;
                            Events_WP event_TWP = new Events_WP(event_TWO);
                            resultSet.add(event_TWP); 
                        }
                        else 
                        {
                            // nothing, it should be considered as NonWork order, with no association
                        }
                    }
                }
                else
                {
                    event_TWO.isWorkOrder = false;
                    Events_WP event_TWP = new Events_WP(event_TWO);
                    resultSet.add(event_TWP);
                }
            }
            EVTFieldDef.clear();

            // Process ServiceMax events
            for(SVMXC__SVMX_Event__c e: lstServiceMaxEvents)
            {
                DCEvent_WP event_TWO = new DCEvent_WP();
                event_TWO.description = CheckNull(e.SVMXC__Description__c);
                event_TWO.IsAllDayEvent = e.SVMXC__IsAllDayEvent__c;
                event_TWO.durationInMinutes = CheckNull(String.valueof(e.SVMXC__DurationInMinutes__c));
                // This is the change due to the introduction of new fields in event objects
                event_TWO.Driving_Time = CheckNull(String.valueof(e.SVMXC__Driving_Time__c));
                event_TWO.Overhead_Time_Before = CheckNull(String.valueof(e.SVMXC__Overhead_Time_Before__c));
                event_TWO.Overhead_Time_After = CheckNull(String.valueof(e.SVMXC__Overhead_Time_After__c));
                event_TWO.Driving_Time_Home = CheckNull(String.valueof(e.SVMXC__Driving_Time_Home__c));
                event_TWO.Service_Duration = CheckNull(String.valueof(e.SVMXC__Service_Duration__c));
                event_TWO.Break_Time_Total = CheckNull(String.valueof(e.SVMXC__Break_Time_Total__c));                
                event_TWO.id = e.Id;
                event_TWO.ownerId = CheckNull(e.SVMXC__Technician__c);
                event_TWO.TechId = CheckNull(e.SVMXC__Technician__c);
                event_TWO.subject = CheckNull(e.Name);
                event_TWO.lastModifiedDateTime = e.LastModifiedDate;
                event_TWO.location = CheckNull(e.SVMXC__Location__c);

                //Defect# 014336 - added 'Type' field
                event_TWO.Type = CheckNull(e.SVMXC__Type__c);
                
                if(e.SVMXC__SM_Latitude__c == null)
                    {
                        event_TWO.latitude = 'undefined';
                    }
                else
                    {
                        event_TWO.latitude = String.valueOf(e.SVMXC__SM_Latitude__c);
                    }   
                if(e.SVMXC__SM_Longitude__c == null)
                    {
                        event_TWO.longitude = 'undefined';  
                    }
                else
                    {
                        event_TWO.longitude = String.valueOf(e.SVMXC__SM_Longitude__c);
                    }


                //To support non Work Order event, set whatId to null.
                if(supportNonWorkOrdEvent == true && e.SVMXC__WhatId__c != NULL)
                {
                    if(String.valueof(e.SVMXC__WhatId__c).startsWith(woDefinitions.getKeyPrefix()) == false)
                    {
                        if(isSplRelatedHandling == false|| (isSplRelatedHandling == true && setApiName != null && setApiName.size()> 0 && !setApiName.contains(String.valueOf((Id.ValueOf(e.SVMXC__WhatId__c).getsobjectType())))))
                        {
                            event_TWO.additionalInfo = 'SVMX.NONWO';
                        }
                        else
                        {
                            event_TWO.additionalInfo = '';
                            // nothing, it should be considered NonWork order, with no association
                        }
                        e.SVMXC__WhatId__c = NULL;
                    }
                }
                else
                {
                    event_TWO.additionalInfo = '';
                }

                event_TWO.whatId = CheckNull(e.SVMXC__WhatId__c);

                if(e.SVMXC__IsAllDayEvent__c)
                {
                    if(e.SVMXC__StartDateTime__c != NULL)
                    {
                        event_TWO.startDateTime = e.SVMXC__StartDateTime__c.formatGMT('MM/dd/yyyy hh:mm a');
                        if(e.SVMXC__DurationInMinutes__c != NULL)
                        {
                            event_TWO.endDateTime = e.SVMXC__StartDateTime__c.addMinutes(Integer.valueof(e.SVMXC__DurationInMinutes__c)).formatGMT('MM/dd/yyyy hh:mm a');
                        }
                    }
                }
                else if(isLocal == true)
                {
                    if(e.SVMXC__StartDateTime__c != NULL)
                    {
                        event_TWO.startDateTime = e.SVMXC__StartDateTime__c.format('MM/dd/yyyy hh:mm a');
                        if(e.SVMXC__DurationInMinutes__c != NULL)
                        {
                            event_TWO.endDateTime = e.SVMXC__StartDateTime__c.addMinutes(Integer.valueof(e.SVMXC__DurationInMinutes__c)).format('MM/dd/yyyy hh:mm a');
                        }
                    }
                }
                else
                {
                    if(e.SVMXC__StartDateTime__c != NULL)
                    {
                        event_TWO.startDateTime = e.SVMXC__StartDateTime__c.format('MM/dd/yyyy hh:mm a', timeZone);
                        if(e.SVMXC__DurationInMinutes__c != NULL)
                        {
                            event_TWO.endDateTime = e.SVMXC__StartDateTime__c.addMinutes(Integer.valueof(e.SVMXC__DurationInMinutes__c)).format('MM/dd/yyyy hh:mm a', timeZone);
                        }
                    }
                }            
                // If there are custom Event fields to be displayed in Event Create/Edit window, add their values
                if(mapEventSettings.keySet().size() > 0)
                {
                    List<KeyValuePair_WP> lstEvtKeyVal = new List<KeyValuePair_WP>();
                    for(String strCurrentSetting : mapEventSettings.keySet())
                    {
                        if(mapEventSettings.containskey(strCurrentSetting) && mapEventSettings.get(strCurrentSetting) != null && SVMXEVTFieldDef.containskey(mapEventSettings.get(strCurrentSetting)) && SVMXEVTFieldDef.get(mapEventSettings.get(strCurrentSetting)) == 'DATETIME')
                        {
                            if( e.get(mapEventSettings.get(strCurrentSetting)) != null ) 
                            {               
                                if(isLocal == true)
                                    lstEvtKeyVal.add(new KeyValuePair_WP('Settingfield',strCurrentSetting, ((Datetime)(e.get(mapEventSettings.get(strCurrentSetting)))).format('MM/dd/yyyy hh:mm a')));

                                else                            
                                    lstEvtKeyVal.add(new KeyValuePair_WP('Settingfield',strCurrentSetting, ((Datetime)(e.get(mapEventSettings.get(strCurrentSetting)))).format('MM/dd/yyyy hh:mm a', timeZone)));

                            }
                        }
                        else if(mapEventSettings.containskey(strCurrentSetting) && mapEventSettings.get(strCurrentSetting) != null && SVMXEVTFieldDef.containskey(mapEventSettings.get(strCurrentSetting)) && SVMXEVTFieldDef.get(mapEventSettings.get(strCurrentSetting)) == 'DATE')
                        {

                            if( e.get(mapEventSettings.get(strCurrentSetting)) != null )         
                                lstEvtKeyVal.add(new KeyValuePair_WP('Settingfield', strCurrentSetting, Date.valueof(e.get(mapEventSettings.get(strCurrentSetting))).format()));
                        }
                        else 
                            lstEvtKeyVal.add(new KeyValuePair_WP('Settingfield', strCurrentSetting, String.valueOf(e.get(mapEventSettings.get(strCurrentSetting)))));
                    }
                    event_TWO.lstKeyValuePair = lstEvtKeyVal;
                    System.debug(logginglevel.warn,' Event Key Val'+lstEvtKeyVal);
                }
                //mapEventSettings.clear();

                // Check What Id, and if Work Order, set the IsWorkOrder Flag
                if(e.SVMXC__WhatId__c != NULL)
                {
                    if(String.valueof(e.SVMXC__WhatId__c).startsWith(woDefinitions.getKeyPrefix()) == true)
                    {
                        event_TWO.isWorkOrder = true;
                        WorkOrderIds.add(e.SVMXC__WhatId__c);

                        List<DCEvent_WP> lstEventWP = new List<DCEvent_WP>();
                        lstEventWP.add(event_TWO);
                        if(mapWorkOrderEvents.get(e.SVMXC__WhatId__c) != NULL)
                            lstEventWP.addAll(mapWorkOrderEvents.get(e.SVMXC__WhatId__c));
                        mapWorkOrderEvents.put(e.SVMXC__WhatId__c, lstEventWP);
                    }
                    //To support the setting based non-associated event identification
                    else 
                    {
                        if(isSplRelatedHandling == true && setApiName != null && setApiName.size()> 0 && setApiName.contains(String.valueOf((Id.ValueOf(e.SVMXC__WhatId__c).getsobjectType()))))
                        {
                            event_TWO.isWorkOrder = false;
                            Events_WP event_TWP = new Events_WP(event_TWO);
                            resultSet.add(event_TWP); 
                        }
                        else 
                        {
                            // nothing, it should be considered NonWork order, with no association
                        }
                    }
                }
                else
                {
                    event_TWO.isWorkOrder = false;
                    Events_WP event_TWP = new Events_WP(event_TWO);
                    resultSet.add(event_TWP);
                }
            }     
            //30476
            mapEventSettings.clear();
            
            // Get the Event Hover Rules' header definition
            for(SVMXC__ServiceMax_Processes__c oPro : [Select SVMXC__Sequence__c, SVMXC__Advance_Expression__c, Id From SVMXC__ServiceMax_Processes__c  where RecordTypeId =:RuleRecordTypeId and SVMXC__Rule_Type__c = 'Event Hover Rule'])  
            {
                mapEventHoverRules.put(oPro.Id, oPro);
            }

            if(mapEventHoverRules.size() > 0)
            {
                // Get the Event Hover Rules' entry criteria
                for(SVMXC__ServiceMax_Config_Data__c oExp : [Select Id, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Display_Type__c, SVMXC__Expression_Rule__c From SVMXC__ServiceMax_Config_Data__c where RecordTypeId = :ExpressionRTypeId and SVMXC__Expression_Type__c = 'DISP_Event_Hover_Rule' and SVMXC__Expression_Rule__c IN :mapEventHoverRules.keyset() Order By SVMXC__Sequence__c])  
                {
                    if(!mapEventHoverRuleIdExpr.ContainsKey(oExp.SVMXC__Expression_Rule__c))
                        mapEventHoverRuleIdExpr.put(oExp.SVMXC__Expression_Rule__c, new list<SVMXC__ServiceMax_Config_Data__c>());
                    
                    mapEventHoverRuleIdExpr.get(oExp.SVMXC__Expression_Rule__c).add(oExp);
                    setWOQueryFields.add(oExp.SVMXC__Field_Name__c);
                }

                // Get the Hover Fields and store against the Rule Id
                for(SVMXC__ServiceMax_Config_Data__c objEventHoverField: [Select Id, SVMXC__Target_Field_Name__c, SVMXC__Sequence__c, SVMXC__Expression_Rule__c From SVMXC__ServiceMax_Config_Data__c where RecordTypeId = :FieldMapRTypeId and SVMXC__Expression_Rule__c IN :mapEventHoverRules.keyset() order by SVMXC__Sequence__c DESC])
                {
                    mapEventHoverFields.put(objEventHoverField.Id, objEventHoverField);
                    List<Id> lstHoverFieldId = new List<Id>();
                    lstHoverFieldId.add(objEventHoverField.Id);
                    
                    if(mapEventHoverRuleIdFieldIdList.get(objEventHoverField.SVMXC__Expression_Rule__c) != NULL)
                        lstHoverFieldId.addAll(mapEventHoverRuleIdFieldIdList.get(objEventHoverField.SVMXC__Expression_Rule__c));
                    
                    mapEventHoverRuleIdFieldIdList.put(objEventHoverField.SVMXC__Expression_Rule__c, lstHoverFieldId);
                    setWOQueryFields.add(objEventHoverField.SVMXC__Target_Field_Name__c);
                }
            }

            // Get the list of Work Orders associated with the events retrieved
            for(String fieldName : allFields_L)
            {
                // Add the name fields for the reference fields
                if(fieldName.contains('.'))
                {
                    if(setWOQueryFields.contains(fieldName.split('\\.',2)[0].replace('__r','__c')))
                        setWOQueryFields.add(fieldName);
                    else if((fieldName == 'Owner.Name' && setWOQueryFields.contains('OwnerId')) || (fieldName == 'CreatedBy.Name' && setWOQueryFields.contains('CreatedById')) || (fieldName == 'LastModifiedBy.Name' && setWOQueryFields.contains('LastModifiedById')) || (fieldName == 'RecordType.Name' && setWOQueryFields.contains('RecordTypeId')))
                        setWOQueryFields.add(fieldName);
                }
            }
            setWOQueryFields.addall(mapWOSettings.values());
            setWOQueryFields.retainAll(allFields_L);
            String querySelect = SVMX_getFieldNamesFromList(setWOQueryFields); //Convert the set of strings to comma separated string

            system.debug(LoggingLevel.WARN, 'Work Order select clause fields: ' + querySelect);
            mapWorkOrder = new Map<id, SVMXC__Service_Order__c>();
            map<string, list<KeyValuePair_WP>> mapWOIdUpdateKeyVal = new map<string, list<KeyValuePair_WP>>();

            for(SVMXC__Service_Order__c wo: Database.query('SELECT ' + querySelect + ' FROM SVMXC__Service_Order__c WHERE Id IN:WorkOrderIds')) 
            {
                mapWorkOrder.put(wo.Id, (sObject)wo);
                if(mapWOSettings.size() > 0)
                {
                    List<KeyValuePair_WP> lstWOUpdateFieldKeyVal = new List<KeyValuePair_WP>();
                    List<KeyValuePair_WP> lstWOKeyVal = new List<KeyValuePair_WP>();
                    for(String strCurrentSetting : mapWOSettings.keySet())
                    {

                        //If the field is datetime field, it has to be  converted globes timezone if it is other than logged in user timezone
                        if(mapWOSettings.containskey(strCurrentSetting) && mapWOSettings.get(strCurrentSetting) != null && setDateTimeFields.contains(mapWOSettings.get(strCurrentSetting)))
                        {

                            if( wo.get(mapWOSettings.get(strCurrentSetting)) != null )
                            {
                                if(isLocal == true)
                                    lstWOKeyVal.add(new KeyValuePair_WP('Settingfield',strCurrentSetting, ((Datetime)(wo.get(mapWOSettings.get(strCurrentSetting)))).format('MM/dd/yyyy hh:mm a')));

                                else
                                    lstWOKeyVal.add(new KeyValuePair_WP('Settingfield',strCurrentSetting, ((Datetime)(wo.get(mapWOSettings.get(strCurrentSetting)))).format('MM/dd/yyyy hh:mm a', timeZone)));
                            }
                        }
                    }
                    lstWOUpdateFieldKeyVal.addall(lstWOKeyVal);
                    mapWOIdUpdateKeyVal.put(wo.id,lstWOUpdateFieldKeyVal);
                    System.debug(logginglevel.warn,' WO Key Val'+lstWOUpdateFieldKeyVal);
                }
            }
            WorkOrderIds.clear();
            System.debug(logginglevel.warn,' mapWOIdUpdateKeyVal'+mapWOIdUpdateKeyVal);
            
            for(id idWorkOrder : mapWorkOrderEvents.keySet())
            {
                if(mapWorkOrderEvents.get(idWorkOrder) != NULL)
                {
                    list<DCEvent_WP> lstDCEvent_WP = new list<DCEvent_WP>();
                    for(DCEvent_WP event: mapWorkOrderEvents.get(idWorkOrder))
                    {                    
                        if( event.lstKeyValuePair == null && mapWOIdUpdateKeyVal.get(idWorkOrder) != null)
                            event.lstKeyValuePair = mapWOIdUpdateKeyVal.get(idWorkOrder);
                        else if( mapWOIdUpdateKeyVal.get(idWorkOrder) != null)
                            event.lstKeyValuePair.addAll(mapWOIdUpdateKeyVal.get(idWorkOrder));                    
                        lstDCEvent_WP.add(event);
                        mapWorkOrderEvents.put(idWorkOrder,lstDCEvent_WP);
                    }
                }
            }
            system.debug(LoggingLevel.WARN, 'Size of mapWorkOrder: ' + mapWorkOrder.size() + '; Map: ' + mapWorkOrder);

            // For each Work Order, find the matching Event Hover Rule Id if any
            COMM_SVMXC_Utils4 oUtils = new COMM_SVMXC_Utils4();
            set<string> setEventHoverRuleIds = new set<string>();
            Map<Id, string> mapWOIdEventHoverRuleId = oUtils.SVMX_ExpressionParsing(mapWorkOrder, mapEventHoverRuleIdExpr, mapEventHoverRules);
            mapEventHoverRuleIdExpr.clear();
            mapEventHoverRules.clear();

            if(mapWOIdEventHoverRuleId != null)
            {
                // Get the set of unique matched Event Hover Rule Ids
                for(id WOId : mapWOIdEventHoverRuleId.keySet())
                {
                    setEventHoverRuleIds.add(mapWOIdEventHoverRuleId.get(WOId));
                }

                // Build the Event Hover info per Work Order and attach to the associated events
                if(mapEventHoverFields != null && mapEventHoverFields.size() > 0)
                {
                    // Build the Event Hover info for each Work Order as HTML formatted string
                    Map<Id, List<String>> mapWOIdEventHoverInfo = new Map<Id, List<String>>();
                    for(id idWorkOrder : mapWOIdEventHoverRuleId.keySet())
                    {
                        List<String> lstEventHoverInfo = new List<String>();
                        if(mapEventHoverRuleIdFieldIdList.get(mapWOIdEventHoverRuleId.get(idWorkOrder)) != NULL)
                        {
                            sObject objWO = mapWorkOrder.get(idWorkOrder);
                            for(Id idHoverField: mapEventHoverRuleIdFieldIdList.get(mapWOIdEventHoverRuleId.get(idWorkOrder)))
                            {
                                SVMXC__ServiceMax_Config_Data__c objHoverField = mapEventHoverFields.get(idHoverField);
                                if(!setWOQueryFields.contains(objHoverField.SVMXC__Target_Field_Name__c))
                                    continue;
                                if(mapWOFieldNameLabel.containsKey(objHoverField.SVMXC__Target_Field_Name__c))
                                {
                                    String strFieldValue;

                                    // For reference fields: Process the reference field and get the name field for the lookup
                                    if(setRefFields.contains(objHoverField.SVMXC__Target_Field_Name__c))
                                    {
                                        Sobject ref_TO = objWO.getSobject(replacementRef.get(objHoverField.SVMXC__Target_Field_Name__c));
                                        if(ref_TO != NULL)
                                        {
                                            strFieldValue = String.valueof(ref_TO.get(replacementNameField.get(objHoverField.SVMXC__Target_Field_Name__c)));
                                        }
                                        if(strFieldValue == NULL)
                                            strFieldValue = '--';
                                    }
                                    // For datetime fields: Get the datetime formatted in logged in user's timezone
                                    else if(setDateTimeFields.contains(objHoverField.SVMXC__Target_Field_Name__c))
                                    {
                                        if(objWO.get(objHoverField.SVMXC__Target_Field_Name__c) != NULL)
                                        {
                                            strFieldValue = ((Datetime)(objWO.get(objHoverField.SVMXC__Target_Field_Name__c))).format(DatetimeFormat, timeZone);
                                            System.debug('strFieldValue: '+strFieldValue);
                                        }
                                        else
                                            strFieldValue = '--';
                                    }
                                    // For date fields: Get the date formatted in logged in user's timezone
                                    else if(setDateFields.contains(objHoverField.SVMXC__Target_Field_Name__c))
                                    {
                                        strFieldValue = String.valueOf(objWO.get(objHoverField.SVMXC__Target_Field_Name__c));
                                        if(strFieldValue != NULL)
                                            strFieldValue = Date.valueof(strFieldValue).format();
                                        else
                                            strFieldValue = '--';
                                    }
                                        // For picklist fields get proper translations
                                        else if(objWorkOrderFieldMap.containskey(objHoverField.SVMXC__Target_Field_Name__c) && String.valueOf(objWorkOrderFieldMap.get(objHoverField.SVMXC__Target_Field_Name__c).getDescribe().getType()) == 'PICKLIST') 
                                        {
                                            strFieldValue = mapFieldToPckLstValLbl.get(objHoverField.SVMXC__Target_Field_Name__c).get(String.valueOf(objWO.get(objHoverField.SVMXC__Target_Field_Name__c)));
                                            if(strFieldValue == NULL)
                                                strFieldValue = '--';
                                        }
                                    // All other fields: Just pass the value as it is stored
                                    else
                                    {
                                        strFieldValue = String.valueOf(objWO.get(objHoverField.SVMXC__Target_Field_Name__c));
                                        if(strFieldValue == NULL)
                                            strFieldValue = '--';
                                    }
                                    //lstEventHoverInfo.add('<font color="#6B6B6B">' + mapWOFieldNameLabel.get(objHoverField.SVMXC__Target_Field_Name__c)  + '</font>' + '\n' + strFieldValue +'\n');
                                    //lstEventHoverInfo.add('<B>' + mapWOFieldNameLabel.get(objHoverField.SVMXC__Target_Field_Name__c)  + '</B>' + ': '+ '\n' + strFieldValue + '\n');
                                    lstEventHoverInfo.add('<B>' + mapWOFieldNameLabel.get(objHoverField.SVMXC__Target_Field_Name__c)  + '</B>' + ': ' + strFieldValue);
                                }
                            }
                        }
                        if(lstEventHoverInfo.size() > 0)
                            mapWOIdEventHoverInfo.put(idWorkOrder, lstEventHoverInfo);
                    }

                    // Add the Event Hover Info + additional info (WO Number, Service & Driving Duration) to the associated events
                    for(id idWorkOrder : mapWOIdEventHoverRuleId.keySet())
                    {
                        if(mapWorkOrderEvents.get(idWorkOrder) != NULL)
                        {
                            for(DCEvent_WP event: mapWorkOrderEvents.get(idWorkOrder))
                            {
                                Events_WP event_TWP = new Events_WP(event);
                                // Add the Event Hover Info to the event
                                if(mapWOIdEventHoverInfo.get(idWorkOrder) != NULL)
                                {
                                    event_TWP.event_WP.EvntHovrAdditionalInfo = mapWOIdEventHoverInfo.get(idWorkOrder);
                                }

                                // Add the additional info (WO Number, Service & Driving Duration) to the event
                                sObject objWO = mapWorkOrder.get(idWorkOrder);
                                List<KeyValuePair_WP> lstWorkOrderKeyVal = new List<KeyValuePair_WP>();
                                if(objWO.get('Name') != NULL)
                                {
                                    lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'Name', String.valueOf(objWO.get('Name'))));
                                }
                                if(objWO.get('SVMXC__Service_Duration__c') != NULL)
                                {
                                    lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'SVMXC__Service_Duration__c', String.valueOf(objWO.get('SVMXC__Service_Duration__c'))));
                                }
                                if(objWO.get('SVMXC__Driving_Time__c') != NULL)
                                {
                                    lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'SVMXC__Driving_Time__c', String.valueOf(objWO.get('SVMXC__Driving_Time__c'))));
                                }

                                if( event_TWP.event_WP.lstKeyValuePair == null)
                                    event_TWP.event_WP.lstKeyValuePair = lstWorkOrderKeyVal;
                                else
                                    event_TWP.event_WP.lstKeyValuePair.addAll(lstWorkOrderKeyVal);
                                
                                resultSet.add(event_TWP);
                                WOIdsAddedtoResponse.add(idWorkOrder);
                            }
                        }
                    }
                }
            }
            
            mapEventHoverFields.clear();
            mapWOFieldNameLabel.clear();
            mapEventHoverRuleIdFieldIdList.clear();
            
            // For Events of Work Orders with no Event Hover Rule, add additional info (WO Number, Service & Driving Duration)
            for(Id idWorkOrder: mapWorkOrder.keySet())
            {
                if(!mapWOIdEventHoverRuleId.containsKey(idWorkOrder))
                {
                    if(mapWorkOrderEvents.get(idWorkOrder) != NULL)
                    {
                        for(DCEvent_WP event: mapWorkOrderEvents.get(idWorkOrder))
                        {
                            Events_WP event_TWP = new Events_WP(event);
                            sObject objWO = mapWorkOrder.get(idWorkOrder);
                            List<KeyValuePair_WP> lstWorkOrderKeyVal = new List<KeyValuePair_WP>();
                            
                            if(objWO.get('Name') != NULL)
                            {
                                lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'Name', String.valueOf(objWO.get('Name'))));
                            }
                            if(objWO.get('SVMXC__Service_Duration__c') != NULL)
                            {
                                lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'SVMXC__Service_Duration__c', String.valueOf(objWO.get('SVMXC__Service_Duration__c'))));
                            }
                            if(objWO.get('SVMXC__Driving_Time__c') != NULL)
                            {
                                lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'SVMXC__Driving_Time__c', String.valueOf(objWO.get('SVMXC__Driving_Time__c'))));
                            }

                            if(event_TWP.event_WP.lstKeyValuePair == null)
                                event_TWP.event_WP.lstKeyValuePair = lstWorkOrderKeyVal;
                            else
                                event_TWP.event_WP.lstKeyValuePair.addAll(lstWorkOrderKeyVal);
                            
                            resultSet.add(event_TWP);
                            WOIdsAddedtoResponse.add(idWorkOrder);
                        }
                    }
                }
            }   
            /*(Defect # 011533 ) : There may be a case when there will be a set of Events wrapper (event_TWP)in the
                mapWorkOrderEvents which has not been added to the resultSet. 
                This happens because the associated WO has been deleted, but having events
                which needs to be plotted - This functionality will be removed, when PM 
                confirms about 'no child events for deleted Parent WO' */
            for(String WOId:mapWorkOrderEvents.keyset())
            {
                if(!WOIdsAddedtoResponse.contains(WOId))
                {
                    for(DCEvent_WP event: mapWorkOrderEvents.get(WOId))
                    {
                        Events_WP event_TWP = new Events_WP(event);
                        resultSet.add(event_TWP);
                    }
                }
            }   
        }
        catch(Exception ex)
        {
            system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex);
        }
        system.debug(LoggingLevel.WARN,'resultSet: '+resultSet); 
        return resultSet;
    }

    public static String SVMX_getFieldNamesFromList(set<String> fieldList)
    {
        String fieldNames = '';
        for (String field : fieldList) {
            if (fieldNames.length()>0) {
                fieldNames += ',';
            }
            fieldNames += field;
        }
        return fieldNames;

    }  
    //This method returns a list of Salesforce calendar events for one or more technicians.
    //We are using UserId as Timezone
    //Depending upon the type of technician record, events are retrieved either from Salesforce Events or ServiceMax Events.
    WebService static List<Event> DCON_Retrieve_Salesforce_Events_WS(String UserId, String StartDate, String EndDate, List<String> EventOwnerIds)
    {
        List<Event> EventList = new List<Event>();
        Date DStartDate = Date.valueOf(StartDate);
        Date DEndDate = Date.valueOf(EndDate);
        Datetime DStartDatetime = Datetime.newInstanceGMT(DStartDate,Time.newInstance(0, 0, 0, 0));
        Map<String,String> mapValidSettingsForUpdate = new Map<String,String>();
        mapValidSettingsForUpdate = getValidateSettingsFrom38To47();
        set<String> EventOwners = new set<String>();
        set<String> flds = new set<String>();
        set<String> Eventflds = new set<String>();
        EventOwners.addAll(EventOwnerIds);
        try
        {
            DateTime dtmStartDateTime = dcUtils.getDateTimeInTimezone(Date.valueOf(StartDate), Time.newInstance(0, 0, 0, 0), UserId);
            DateTime dtmEndDateTime = dcUtils.getDateTimeInTimezone(Date.valueOf(EndDate), Time.newInstance(23, 59, 59, 59), UserId);
            if(mapValidSettingsForUpdate.size() > 0)
            {
                for(String strfld : mapValidSettingsForUpdate.keySet())
                {
                    flds.add(mapValidSettingsForUpdate.get(strfld));    
                }
                String whereStr = ' where (((StartDateTime >= : dtmStartDateTime and StartDateTime <= : dtmEndDateTime) OR (EndDateTime >= : dtmStartDateTime and StartDateTime <= : dtmEndDateTime)) OR (ActivityDate <= :DEndDate and EndDateTime >= :DStartDatetime AND IsAllDayEvent = true ) OR(ActivityDate = :DStartDate AND IsAllDayEvent = true)) and OwnerId IN :EventOwners and IsRecurrence = false';
                system.debug('SFEvent where clause'+whereStr);  

                // This is the change due to the introduction of new fields in event objects
                flds.add('SVMXC__Driving_Time__c');
                flds.add('SVMXC__Overhead_Time_Before__c'); 
                flds.add('SVMXC__Overhead_Time_After__c'); 
                flds.add('SVMXC__Driving_Time_Home__c'); 
                flds.add('SVMXC__Service_Duration__c');
                flds.add('SVMXC__Break_Time_Total__c');
                flds.add('SVMXC__SM_Latitude__c');
                flds.add('SVMXC__SM_Longitude__c');
                
               EventList = Database.query('Select Id, Type, ActivityDate, IsAllDayEvent, ActivityDateTime, OwnerId, DurationInMinutes, Subject, Description, WhatId, StartDateTime, EndDateTime, Location, LastModifiedDate,' + SVMX_getFieldNamesFromList(flds) +' from Event ' + whereStr );
            }
            else
            {
               
                EventList = [Select Id, Type, ActivityDate, ActivityDateTime, IsAllDayEvent, OwnerId, DurationInMinutes, Subject, Description, WhatId, StartDateTime, EndDateTime, Location, LastModifiedDate,SVMXC__Driving_Time__c, SVMXC__Overhead_Time_Before__c, SVMXC__Overhead_Time_After__c, SVMXC__Driving_Time_Home__c, SVMXC__Service_Duration__c,SVMXC__Break_Time_Total__c,SVMXC__SM_Longitude__c,SVMXC__SM_Latitude__c from Event where (((StartDateTime >= : dtmStartDateTime and StartDateTime <= : dtmEndDateTime) OR (EndDateTime >= : dtmStartDateTime and StartDateTime <= : dtmEndDateTime)) OR (ActivityDate <= :DEndDate and EndDateTime >= :DStartDatetime AND IsAllDayEvent = true ) OR(ActivityDate = :DStartDate AND IsAllDayEvent = true)) and OwnerId IN :EventOwners and IsRecurrence = false];
            }
        }
        catch(Exception ex)
        {
            system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex);
        }
        return EventList;
    }

    //This method returns a list of ServiceMax calendar events for one or more technicians.
    //Depending upon the type of technician record, events are retrieved either from Salesforce Events or ServiceMax Events.
    WebService static List<SVMXC__SVMX_Event__c> DCON_Retrieve_ServiceMax_Events_WS(String UserId, String StartDate, String EndDate, List<String> ServiceMaxEventOwnerIds)
    {
        List<SVMXC__SVMX_Event__c> EventList = new List<SVMXC__SVMX_Event__c>();
        Date DStartDate = Date.valueOf(StartDate);
        Date DEndDate = Date.valueOf(EndDate);
        Datetime DStartDatetime = Datetime.newInstanceGMT(DStartDate,Time.newInstance(0, 0, 0, 0));
        Map<String,String> mapValidSettingsForUpdate = new Map<String,String>();
        mapValidSettingsForUpdate = getValidateSettingsFrom38To47();
        set<String> flds = new set<String>();
        set<String> Eventflds = new set<String>();
        try{
            set<String> EventOwners = new set<String>();
            EventOwners.addAll(ServiceMaxEventOwnerIds);
            DateTime dtmStartDateTime = dcUtils.getDateTimeInTimezone(Date.valueOf(StartDate), Time.newInstance(0, 0, 0, 0), UserId);
            DateTime dtmEndDateTime = dcUtils.getDateTimeInTimezone(Date.valueOf(EndDate), Time.newInstance(23, 59, 59, 59), UserId);
            if(mapValidSettingsForUpdate.keySet().size() > 0)
            {
                for(String strfld : mapValidSettingsForUpdate.keySet())
                {
                    flds.add(mapValidSettingsForUpdate.get(strfld));    
                }
                String whereStr = ' where (((SVMXC__StartDateTime__c >= : dtmStartDateTime and SVMXC__StartDateTime__c <= : dtmEndDateTime) OR (SVMXC__EndDateTime__c >= : dtmStartDateTime and SVMXC__StartDateTime__c <= : dtmEndDateTime)) OR (SVMXC__ActivityDate__c <= :DEndDate and SVMXC__EndDateTime__c >= :DStartDatetime AND SVMXC__IsAllDayEvent__c = true) OR(SVMXC__StartDateTime__c = :DStartDatetime AND SVMXC__IsAllDayEvent__c = true)) and SVMXC__Technician__c IN :EventOwners';
                // This is the change due to the introduction of new fields in event objects
                //Defect# 014336 - added 'SVMXC__Type__c' field
                //In future due to any moficications, if we are facing duplicate field error while querying, we may have to use the 
                //set 'flds' below to add new fields
                flds.add('SVMXC__Driving_Time__c');
                flds.add('SVMXC__Overhead_Time_Before__c'); 
                flds.add('SVMXC__Overhead_Time_After__c'); 
                flds.add('SVMXC__Driving_Time_Home__c'); 
                flds.add('SVMXC__Service_Duration__c');
                flds.add('SVMXC__Break_Time_Total__c');
                flds.add('SVMXC__IsAllDayEvent__c');
                flds.add('SVMXC__SM_Latitude__c');
                flds.add('SVMXC__SM_Longitude__c');
                
                
                EventList = Database.query('SELECT Id, SVMXC__Type__c, SVMXC__ActivityDate__c, SVMXC__ActivityDateTime__c,  SVMXC__Technician__c, SVMXC__DurationInMinutes__c, Name, SVMXC__Description__c, SVMXC__WhatId__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c, SVMXC__Location__c, LastModifiedDate,' + SVMX_getFieldNamesFromList(flds) +' from SVMXC__SVMX_Event__c  '+whereStr);
            }
            else
            {
                //Defect# 014336 - added 'SVMXC__Type__c' field
                EventList = [Select Id, SVMXC__Type__c, SVMXC__ActivityDate__c, SVMXC__ActivityDateTime__c, SVMXC__Technician__c, SVMXC__DurationInMinutes__c, Name, SVMXC__Description__c, SVMXC__WhatId__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c, SVMXC__Location__c, LastModifiedDate,SVMXC__Driving_Time__c, SVMXC__IsAllDayEvent__c,SVMXC__Overhead_Time_Before__c, SVMXC__Overhead_Time_After__c, SVMXC__Driving_Time_Home__c, SVMXC__Service_Duration__c,SVMXC__Break_Time_Total__c,SVMXC__SM_Longitude__c,SVMXC__SM_Latitude__c from SVMXC__SVMX_Event__c where (((SVMXC__StartDateTime__c >= : dtmStartDateTime and SVMXC__StartDateTime__c <= : dtmEndDateTime) OR (SVMXC__EndDateTime__c >= : dtmStartDateTime and SVMXC__StartDateTime__c <= : dtmEndDateTime)) OR (SVMXC__ActivityDate__c <= :DEndDate and SVMXC__EndDateTime__c >= :DStartDatetime AND SVMXC__IsAllDayEvent__c = true) OR(SVMXC__StartDateTime__c = :DStartDatetime AND SVMXC__IsAllDayEvent__c = true)) and SVMXC__Technician__c IN :EventOwners];
            }
        }catch(Exception ex){
            throw new SVMXException(ex);
        }
        return EventList;
    }

    //This method accepts a list of calendar event IDs and deletes the records from Salesforce events or ServiceMax events or both.
    WebService static String DCON_Delete_Events_WS(String UserId, List<String> Events)
    {
        system.debug('Input Parameters: '+UserId+Events);
        String StatusMessage;
        Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        Schema.Describesobjectresult objE = allObjs.get('Event').getDescribe();
        allObjs.clear();
        List<String> SFEvents = new List<String>();
        List<String> SMEvents = new List<String>();
        Set<String> wo_TL = new Set<String>();
        Set<String> owners_TL = new Set<String>();
        Set<String> otechnician_TL = new Set<String>();
        Set<Datetime> woAssigned_TL = new Set<Datetime>();

        try
        {
            //Validations
            if(Events == null || Events.size()==0)
                throw new SVMXException('Please provide some events to delete');
            for(String e: Events)
            {
                if(e.startsWith(objE.getKeyPrefix()))
                    SFEvents.add(e);
                else
                    SMEvents.add(e);
            }

            List<Event> SalesforceEventList = new List<Event>();
            SalesforceEventList = [SELECT Id, ActivityDateTime, WhatId, OwnerId from Event where Id IN :SFEvents];
            List<SVMXC__SVMX_Event__c> ServiceMaxEventList = new List<SVMXC__SVMX_Event__c>();
            ServiceMaxEventList = [SELECT Id, SVMXC__ActivityDateTime__c, SVMXC__WhatId__c, SVMXC__Technician__c from SVMXC__SVMX_Event__c where Id IN :SMEvents];

            for(Event e: SalesforceEventList){
                if(e.WhatId != NULL)
                    wo_TL.add(e.WhatId);
                if(e.ActivityDateTime != NULL)
                    woAssigned_TL.add(e.ActivityDateTime);
                if(e.OwnerId != NULL)
                    owners_TL.add(e.OwnerId);
            }

            for(SVMXC__SVMX_Event__c e: ServiceMaxEventList){
                if(e.SVMXC__WhatId__c != NULL)
                    wo_TL.add(e.SVMXC__WhatId__c);
                if(e.SVMXC__ActivityDateTime__c != NULL)
                    woAssigned_TL.add(e.SVMXC__ActivityDateTime__c);
                if(e.SVMXC__Technician__c != NULL)
                    otechnician_TL.add(e.SVMXC__Technician__c);
            }

            List<SVMXC__Service_Order__c> schWO = [Select Id, SVMXC__Last_Dispatch_Event__c,SVMXC__FirstScheduledDateTime__c, SVMXC__NoOfTimesScheduled__c, SVMXC__Scheduled_Date_Time__c, SVMXC__Group_Member__c, SVMXC__Group_Member__r.SVMXC__Salesforce_User__c from SVMXC__Service_Order__c where Id IN :wo_TL AND SVMXC__Scheduled_Date_Time__c IN :woAssigned_TL AND (SVMXC__Group_Member__c IN :otechnician_TL OR SVMXC__Group_Member__r.SVMXC__Salesforce_User__c IN :owners_TL) ];
            for(SVMXC__Service_Order__c wo: schWO){
                wo.SVMXC__Scheduled_Date_Time__c = NULL;
                wo.SVMXC__Last_Dispatch_Event__c='UnScheduled';
            }
            if(schWO.size() > 0) {
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(schWO,COMM_SecurityUtils.Access.Updateable)){
                    update schWO; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
            //updating records
            if(SalesforceEventList.size()>0) {
                if( COMM_SecurityUtils.getInstance().isDeletableObject('Event') ){
                    delete SalesforceEventList; //SDL-SVMX-DELETE-FLS-ENFORCED
                } else {
                   throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
            if(ServiceMaxEventList.size()>0) {
                if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SVMX_Event__c') ){
                    delete ServiceMaxEventList; //SDL-SVMX-DELETE-FLS-ENFORCED
                } else {
                   throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
            StatusMessage = 'Events deleted successfully';
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

    //This method retrieve events based on WO Ids
    WebService static List<Events_WP> DCON_Retrieve_WO_Events_WS(String UserId, String StartDate, String EndDate, String timeZone, String strWOid)
    {
        SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils(); 
        Boolean isLocal = false;
        List<String> SFUSerIds = new List<String>();
        List<String> SVMXUserIds = new List<String>();
        List<Event> lstSalesforceEvents = new List<Event>();
        List<SVMX_Event__c> lstServiceMaxEvents = new List<SVMX_Event__c>();
        set<String> techlst = new set<String>();
        List<Events_WP> resultSet = new List<Events_WP>();          

        // Check for User TimeZone
        //User UserDetail = [SELECT TimeZoneSidKey from User where Id = :UserId];
        if(timeZone != NULL && timeZone != '')
        {
            if(Userinfo.getTimeZone().getID() == timeZone)
                isLocal = true;
        }
        else
        {
            timeZone = Userinfo.getTimeZone().getID();
            isLocal = true;
        }
        // Getting Salesforce Events

        lstSalesforceEvents = DCON_Event_WS.DCON_Retrieve_Salesforce_WO_Events_WS(timeZone, StartDate, EndDate, strWOid);
        // Getting ServiceMax events            
        lstServiceMaxEvents = DCON_Event_WS.DCON_Retrieve_ServiceMax_WO_Events_WS(timeZone, StartDate, EndDate, strWOid);        
        resultSet = DCON_Retrieve_WO_Events_WS(lstSalesforceEvents, lstServiceMaxEvents, UserId, timeZone, isLocal);
        System.debug(logginglevel.warn,'Event wrapper: ' + resultSet);
        return resultSet;
    }

    // Process the events and build custom Event wrapper with Hover rules for the given Salesforce Events and ServiceMax Evnets for a WO
    public static List<Events_WP> DCON_Retrieve_WO_Events_WS(List<Event> lstSalesforceEvents, List<SVMX_Event__c> lstServiceMaxEvents, String UserId, String timeZone, Boolean isLocal)
    {
        system.debug(LoggingLevel.WARN, 'Count of Salesforce Events: ' + lstSalesforceEvents.size() + '; Events: ' + lstSalesforceEvents);
        system.debug(LoggingLevel.WARN, 'Count of ServiceMax Events: ' + lstServiceMaxEvents.size() + '; Events: ' + lstServiceMaxEvents);
        system.debug(LoggingLevel.WARN, 'User Id: ' + UserId + '; Time zone: ' + timeZone + '; Is Local?: ' + isLocal);
        map<string,string> mapSFIDTechId = new map<string,string>();
        // Getting all SF Id and corresponding Tech Id 
        mapSFIDTechId = getmapSFuserTechId(lstSalesforceEvents);
        SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();
        string FieldMapRTypeId;
        string RuleRecordTypeId;
        string ExpressionRTypeId;
        boolean supportNonWorkOrdEvent = true;   
        Map<id, sObject> mapWorkOrder;   
        Map<Id, List<Id>> mapEventHoverRuleIdFieldIdList = new Map<Id, List<Id>>();
        Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        Map<Id, List<DCEvent_WP>> mapWorkOrderEvents = new Map<Id, List<DCEvent_WP>>();
        Map<Id, SVMXC__ServiceMax_Processes__c> mapEventHoverRules  = new Map<Id, SVMXC__ServiceMax_Processes__c>();  
        Map<Id, SVMXC__ServiceMax_Config_Data__c> mapEventHoverFields = new Map<Id, SVMXC__ServiceMax_Config_Data__c>();
        Map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapEventHoverRuleIdExpr  = new Map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();    
        List<String> lstTechnId = new List<String>();
        List<String> lstUserId = new List<String>();
        set<String> setTechnId = new set<String>();
        set<String> setUserId = new set<String>();
        List<String> WorkOrderIds = new List<String>();
        List<Events_WP> resultSet = new List<Events_WP>();

        for(RecordType recType : [Select SobjectType, Id, Name From RecordType where (SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'SVMX Rule') OR (SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name IN ('Expressions', 'Field Mapping'))])   
        {
            if(recType.Name == 'SVMX Rule')
                RuleRecordTypeId = recType.id;
            else if(recType.Name == 'Expressions')
                ExpressionRTypeId = recType.id;
            else if(recType.Name == 'Field Mapping')
                FieldMapRTypeId = recType.id;
        }
        
        Schema.Describesobjectresult woDefinitions = allObjs.get('Service_Order__c').getDescribe();
        allObjs.clear();
        
        set<String> setDateTimeFields = new set<String>();
        set<String> setDateFields = new set<String>();
        set<String> setRefFields = new set<String>();
        Map<String, String> mapWOFieldNameLabel = new Map<String, String>();

        Set<String> setWOQueryFields = new Set<String>();
        setWOQueryFields.add('Id');
        setWOQueryFields.add('Name');
        setWOQueryFields.add('SVMXC__Service_Duration__c');
        setWOQueryFields.add('SVMXC__Driving_Time__c');

        // Get the labels for all the fields of Work Order and put them against field APIName
        Map<String, SObjectField> objWorkOrderFieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap();
        for (String fieldKey : objWorkOrderFieldMap.keySet())
        {
            Schema.SObjectField fsObj = objWorkOrderFieldMap.get(fieldKey); 
            Schema.DescribeFieldResult field = fsObj.getDescribe();
            if(field.isAccessible())
            {
                mapWOFieldNameLabel.put(field.getName(), field.getLabel());
            }
        }

        DCON_Utils.referenceFields_WP reference_M = dcUtils.SVMX_getReferenceFields(objWorkOrderFieldMap,true);
        objWorkOrderFieldMap.clear();
        
        List<String> allFields_L = reference_M.allFields_L; //Get the all field list
        List<String> refFields_L = reference_M.referenceFields_L; //Get the reference field list
        List<String> dateTimeFields_L = reference_M.dateTimeFields_L; //Get the dateTime field list
        List<String> dateFields_L = reference_M.dateFields_L; //Get the date field list
        Map<String,String> replacementRef = reference_M.replacementReference_M;  //Get the replacement reference field map
        Map<String,String> replacementNameField = reference_M.replacementField_M;  //Get the name field for reference map

        setDateTimeFields.addAll(dateTimeFields_L);
        setDateFields.addAll(dateFields_L);
        setRefFields.addAll(refFields_L);

        Map<String, String> mapEventSettings = new Map<String, String>();
        // Get the custom Event fields to be displayed in Event Create/Edit window, from DCON001 SET038 to SET047
        mapEventSettings = getValidateSettingsFrom38To47();

        Map<String,String> EVTFieldDef = new Map<String,String>();
        Map<String, SObjectField> souObjfieldMapEVT = Schema.SObjectType.Event.fields.getMap();
        EVTFieldDef = dcUtils.SVMX_getAllFieldMap(souObjfieldMapEVT);

        Map<String,String> SVMXEVTFieldDef = new Map<String,String>();
        Map<String, SObjectField> souObjfieldMapSVMXEVT = Schema.SObjectType.SVMXC__SVMX_Event__c.fields.getMap();
        SVMXEVTFieldDef = dcUtils.SVMX_getAllFieldMap(souObjfieldMapSVMXEVT);
        souObjfieldMapSVMXEVT.clear();
        
        // Get setting value to support Non-Work Order event
        if(svmxSettingList != NULL && svmxSettingList.containsKey('SET062') && svmxSettingList.get('SET062') != NULL)
            supportNonWorkOrdEvent = boolean.valueOf(svmxSettingList.get('SET062'));

        // Process Salesforce events
        for(Event e: lstSalesforceEvents)
        {
            DCEvent_WP event_TWO = new DCEvent_WP();
            event_TWO.description = CheckNull(e.Description);
            event_TWO.IsAllDayEvent = e.IsAllDayEvent;
            event_TWO.durationInMinutes = CheckNull(String.valueof(e.DurationInMinutes));
            // This is the change due to the introduction of new fields in event objects
            event_TWO.Driving_Time = CheckNull(String.valueof(e.SVMXC__Driving_Time__c));
            event_TWO.Overhead_Time_Before = CheckNull(String.valueof(e.SVMXC__Overhead_Time_Before__c));
            event_TWO.Overhead_Time_After = CheckNull(String.valueof(e.SVMXC__Overhead_Time_After__c));
            event_TWO.Driving_Time_Home = CheckNull(String.valueof(e.SVMXC__Driving_Time_Home__c));
            event_TWO.Service_Duration = CheckNull(String.valueof(e.SVMXC__Service_Duration__c));
            event_TWO.Break_Time_Total = CheckNull(String.valueof(e.SVMXC__Break_Time_Total__c));
            event_TWO.id = e.Id;
            event_TWO.ownerId = CheckNull(e.ownerId);
            if(mapSFIDTechId.containsKey(e.ownerId))
                event_TWO.TechId = mapSFIDTechId.get(e.ownerId);
            event_TWO.subject = CheckNull(e.Subject);
            event_TWO.lastModifiedDateTime = e.LastModifiedDate;
            event_TWO.location = CheckNull(e.location);
            if(e.ownerId != null)
                setUserId.add(e.ownerId);

            //To support non Work Order event, set whatId to null.
            if(supportNonWorkOrdEvent == true && e.WhatId != NULL)
            {
                if(String.valueof(e.WhatId).startsWith(woDefinitions.getKeyPrefix()) == false)
                {
                    If(isSplRelatedHandling == false|| (isSplRelatedHandling == true && setApiName != null && setApiName.size()> 0 && !setApiName.contains(String.valueOf((Id.ValueOf(e.WhatId).getsobjectType())))))
                    {
                        event_TWO.additionalInfo = 'SVMX.NONWO';
                    }
                    else
                    {
                        event_TWO.additionalInfo = '';                          
                        // nothing, it should be considered NonWork order, with no association
                    }
                    e.WhatId = NULL;
                }
            }
            else
                event_TWO.additionalInfo = '';

            event_TWO.whatId = CheckNull(e.WhatId);

            // Format the datetime in fixed 'MM/dd/yyyy hh:mm a' format, but in applicable time zone
            // Because, Flex needs the date time string to be in this format
            if(e.IsAllDayEvent)
            {
                if(e.StartDateTime != NULL)
                {
                    event_TWO.startDateTime = e.StartDateTime.formatGMT('MM/dd/yyyy hh:mm a');
                    if(e.DurationInMinutes != NULL)
                    {
                        event_TWO.endDateTime = e.StartDateTime.addMinutes(Integer.valueof(e.DurationInMinutes)).formatGMT('MM/dd/yyyy hh:mm a');
                    }
                }
            }
            else if(isLocal == true)
            {
                if(e.StartDateTime != NULL)
                {
                    event_TWO.startDateTime = e.StartDateTime.format('MM/dd/yyyy hh:mm a');
                    if(e.DurationInMinutes != NULL)
                    {
                        event_TWO.endDateTime = e.StartDateTime.addMinutes(Integer.valueof(e.DurationInMinutes)).format('MM/dd/yyyy hh:mm a');
                    }
                }
            }
            else
            {
                if(e.StartDateTime != NULL)
                {
                    event_TWO.startDateTime = e.StartDateTime.format('MM/dd/yyyy hh:mm a', timeZone);
                    if(e.DurationInMinutes != NULL)
                    {
                        event_TWO.endDateTime = e.StartDateTime.addMinutes(Integer.valueof(e.DurationInMinutes)).format('MM/dd/yyyy hh:mm a', timeZone);
                    }
                }
            }

            // If there are custom Event fields to be displayed in Event Create/Edit window, add their values
            if(mapEventSettings.keySet().size() > 0)
            {
                List<KeyValuePair_WP> lstEvtKeyVal = new List<KeyValuePair_WP>();
                for(String strCurrentSetting : mapEventSettings.keySet())
                {
                    if(mapEventSettings.containskey(strCurrentSetting) && mapEventSettings.get(strCurrentSetting) != null && EVTFieldDef.containskey(mapEventSettings.get(strCurrentSetting)) && EVTFieldDef.get(mapEventSettings.get(strCurrentSetting)) == 'DATETIME')
                    {
                        if( e.get(mapEventSettings.get(strCurrentSetting)) != null ) 
                        {               
                            if(isLocal == true)
                                lstEvtKeyVal.add(new KeyValuePair_WP('Settingfield',strCurrentSetting, ((Datetime)(e.get(mapEventSettings.get(strCurrentSetting)))).format('MM/dd/yyyy hh:mm a')));

                            else                            
                                lstEvtKeyVal.add(new KeyValuePair_WP('Settingfield',strCurrentSetting, ((Datetime)(e.get(mapEventSettings.get(strCurrentSetting)))).format('MM/dd/yyyy hh:mm a', timeZone)));

                        }
                    }
                    else if(mapEventSettings.containskey(strCurrentSetting) && mapEventSettings.get(strCurrentSetting) != null && EVTFieldDef.containskey(mapEventSettings.get(strCurrentSetting)) && EVTFieldDef.get(mapEventSettings.get(strCurrentSetting)) == 'DATE')
                    {

                        if( e.get(mapEventSettings.get(strCurrentSetting)) != null )         
                            lstEvtKeyVal.add(new KeyValuePair_WP('Settingfield', strCurrentSetting, Date.valueof(e.get(mapEventSettings.get(strCurrentSetting))).format()));
                    }               
                    else 
                        lstEvtKeyVal.add(new KeyValuePair_WP('Settingfield', strCurrentSetting, String.valueOf(e.get(mapEventSettings.get(strCurrentSetting)))));



                }
                event_TWO.lstKeyValuePair = lstEvtKeyVal;
                System.debug(logginglevel.warn,' Event update info '+lstEvtKeyVal);

            } 

            // Check What Id, and if Work Order, set the IsWorkOrder Flag
            if(e.WhatId != NULL)
            {
                if(String.valueof(e.WhatId).startsWith(woDefinitions.getKeyPrefix()) == true)
                {
                    event_TWO.isWorkOrder = true;
                    WorkOrderIds.add(e.WhatId);

                    List<DCEvent_WP> lstEventWP = new List<DCEvent_WP>();
                    lstEventWP.add(event_TWO);
                    if(mapWorkOrderEvents.get(e.WhatId) != NULL)
                        lstEventWP.addAll(mapWorkOrderEvents.get(e.WhatId));
                    mapWorkOrderEvents.put(e.WhatId, lstEventWP);
                }
                //To support the setting based non-associated event identification
                else 
                {
                    If(isSplRelatedHandling == false|| (isSplRelatedHandling == true && setApiName != null && setApiName.size()> 0 && !setApiName.contains(String.valueOf((Id.ValueOf(e.WhatId).getsobjectType())))))
                    {
                        event_TWO.isWorkOrder = false;
                        Events_WP event_TWP = new Events_WP(event_TWO);
                        resultSet.add(event_TWP); 
                    }
                }
            }
            else
            {
                event_TWO.isWorkOrder = false;
                Events_WP event_TWP = new Events_WP(event_TWO);
                resultSet.add(event_TWP);
            }
        }

        // Process ServiceMax events
        for(SVMX_Event__c e: lstServiceMaxEvents)
        {
            DCEvent_WP event_TWO = new DCEvent_WP();
            event_TWO.description = CheckNull(e.SVMXC__Description__c);
            event_TWO.IsAllDayEvent = e.SVMXC__IsAllDayEvent__c;
            event_TWO.durationInMinutes = CheckNull(String.valueof(e.SVMXC__DurationInMinutes__c));
            // This is the change due to the introduction of new fields in event objects
            event_TWO.Driving_Time = CheckNull(String.valueof(e.SVMXC__Driving_Time__c));
            event_TWO.Overhead_Time_Before = CheckNull(String.valueof(e.SVMXC__Overhead_Time_Before__c));
            event_TWO.Overhead_Time_After = CheckNull(String.valueof(e.SVMXC__Overhead_Time_After__c));
            event_TWO.Driving_Time_Home = CheckNull(String.valueof(e.SVMXC__Driving_Time_Home__c));
            event_TWO.Service_Duration = CheckNull(String.valueof(e.SVMXC__Service_Duration__c));
            event_TWO.Break_Time_Total = CheckNull(String.valueof(e.SVMXC__Break_Time_Total__c));
            event_TWO.id = e.Id;
            event_TWO.ownerId = CheckNull(e.SVMXC__Technician__c);
            event_TWO.TechId = CheckNull(e.SVMXC__Technician__c);
            event_TWO.subject = CheckNull(e.Name);
            event_TWO.lastModifiedDateTime = e.LastModifiedDate;
            event_TWO.location = CheckNull(e.SVMXC__Location__c);
            if(e.SVMXC__Technician__c != null)
                setTechnId.add(e.SVMXC__Technician__c);

            //To support non Work Order event, set whatId to null.
            if(supportNonWorkOrdEvent == true && e.SVMXC__WhatId__c != NULL)
            {
                if(String.valueof(e.SVMXC__WhatId__c).startsWith(woDefinitions.getKeyPrefix()) == false)
                {
                    If(isSplRelatedHandling == false|| (isSplRelatedHandling == true && setApiName != null && setApiName.size()> 0 && !setApiName.contains(String.valueOf((Id.ValueOf(e.SVMXC__WhatId__c).getsobjectType())))))
                    {
                        event_TWO.additionalInfo = 'SVMX.NONWO';
                    }
                    else
                    {
                        event_TWO.additionalInfo = '';
                    }
                    e.SVMXC__WhatId__c = NULL;
                }
            }
            else
                event_TWO.additionalInfo = '';

            event_TWO.whatId = CheckNull(e.SVMXC__WhatId__c);

            // Format the datetime in fixed 'MM/dd/yyyy hh:mm a' format, but in applicable time zone
            // Because, Flex needs the date time string to be in this format
            if(e.SVMXC__IsAllDayEvent__c)
            {
                if(e.SVMXC__StartDateTime__c != NULL)
                {
                    event_TWO.startDateTime = e.SVMXC__StartDateTime__c.formatGMT('MM/dd/yyyy hh:mm a');
                    if(e.SVMXC__DurationInMinutes__c != NULL)
                    {
                        event_TWO.endDateTime = e.SVMXC__StartDateTime__c.addMinutes(Integer.valueof(e.SVMXC__DurationInMinutes__c)).formatGMT('MM/dd/yyyy hh:mm a');
                    }
                }
            }
            else if(isLocal == true)
            {
                if(e.SVMXC__StartDateTime__c != NULL)
                {
                    event_TWO.startDateTime = e.SVMXC__StartDateTime__c.format('MM/dd/yyyy hh:mm a');
                    if(e.SVMXC__DurationInMinutes__c != NULL)
                    {
                        event_TWO.endDateTime = e.SVMXC__StartDateTime__c.addMinutes(Integer.valueof(e.SVMXC__DurationInMinutes__c)).format('MM/dd/yyyy hh:mm a');
                    }
                }
            }
            else
            {
                if(e.SVMXC__StartDateTime__c != NULL)
                {
                    event_TWO.startDateTime = e.SVMXC__StartDateTime__c.format('MM/dd/yyyy hh:mm a', timeZone);
                    if(e.SVMXC__DurationInMinutes__c != NULL)
                    {
                        event_TWO.endDateTime = e.SVMXC__StartDateTime__c.addMinutes(Integer.valueof(e.SVMXC__DurationInMinutes__c)).format('MM/dd/yyyy hh:mm a', timeZone);
                    }
                }
            }

            // If there are custom Event fields to be displayed in Event Create/Edit window, add their values
            if(mapEventSettings.keySet().size() > 0)
            {
                List<KeyValuePair_WP> lstEvtKeyVal = new List<KeyValuePair_WP>();
                for(String strCurrentSetting : mapEventSettings.keySet())
                {
                    if(mapEventSettings.containskey(strCurrentSetting) && mapEventSettings.get(strCurrentSetting) != null && SVMXEVTFieldDef.containskey(mapEventSettings.get(strCurrentSetting)) && SVMXEVTFieldDef.get(mapEventSettings.get(strCurrentSetting)) == 'DATETIME')
                    {
                        if( e.get(mapEventSettings.get(strCurrentSetting)) != null ) 
                        {               
                            if(isLocal == true)
                                lstEvtKeyVal.add(new KeyValuePair_WP('Settingfield',strCurrentSetting, ((Datetime)(e.get(mapEventSettings.get(strCurrentSetting)))).format('MM/dd/yyyy hh:mm a')));

                            else                            
                                lstEvtKeyVal.add(new KeyValuePair_WP('Settingfield',strCurrentSetting, ((Datetime)(e.get(mapEventSettings.get(strCurrentSetting)))).format('MM/dd/yyyy hh:mm a', timeZone)));

                        }
                    }
                    else if(mapEventSettings.containskey(strCurrentSetting) && mapEventSettings.get(strCurrentSetting) != null && SVMXEVTFieldDef.containskey(mapEventSettings.get(strCurrentSetting)) && SVMXEVTFieldDef.get(mapEventSettings.get(strCurrentSetting)) == 'DATE')
                    {

                        if( e.get(mapEventSettings.get(strCurrentSetting)) != null )         
                            lstEvtKeyVal.add(new KeyValuePair_WP('Settingfield', strCurrentSetting, Date.valueof(e.get(mapEventSettings.get(strCurrentSetting))).format()));
                    }
                    else 
                        lstEvtKeyVal.add(new KeyValuePair_WP('Settingfield', strCurrentSetting, String.valueOf(e.get(mapEventSettings.get(strCurrentSetting)))));
                }
                event_TWO.lstKeyValuePair = lstEvtKeyVal;
                System.debug(logginglevel.warn,' Event update info '+lstEvtKeyVal);
            }
            
            // Check What Id, and if Work Order, set the IsWorkOrder Flag
            if(e.SVMXC__WhatId__c != NULL)
            {
                if(String.valueof(e.SVMXC__WhatId__c).startsWith(woDefinitions.getKeyPrefix()) == true)
                {
                    event_TWO.isWorkOrder = true;
                    WorkOrderIds.add(e.SVMXC__WhatId__c);

                    List<DCEvent_WP> lstEventWP = new List<DCEvent_WP>();
                    lstEventWP.add(event_TWO);
                    if(mapWorkOrderEvents.get(e.SVMXC__WhatId__c) != NULL)
                        lstEventWP.addAll(mapWorkOrderEvents.get(e.SVMXC__WhatId__c));
                    mapWorkOrderEvents.put(e.SVMXC__WhatId__c, lstEventWP);
                }
                else
                {
                    If(isSplRelatedHandling!= null && isSplRelatedHandling == true && setApiName != null && setApiName.size()> 0 && e.SVMXC__WhatId__c != null && !setApiName.contains(String.valueOf((Id.ValueOf(e.SVMXC__WhatId__c).getsobjectType()))))
                    {
                        event_TWO.isWorkOrder = false;
                        Events_WP event_TWP = new Events_WP(event_TWO);
                        resultSet.add(event_TWP); 
                    }   
                }                       
            }
            else
            {
                event_TWO.isWorkOrder = false;
                Events_WP event_TWP = new Events_WP(event_TWO);
                resultSet.add(event_TWP);
            }
        }
        
        list<string> lstTeamid = new list<string>();
        list<string> lstTerrid = new list<string>();
        System.debug('SVMX Tech'+setTechnId );
        System.debug('SF User'+setUserId );
        lstTechnId.addall(setTechnId);
        lstUserId.addall(setUserId);

        map<id, SVMXC__Service_Group_Members__c> mapTech = new map<id, SVMXC__Service_Group_Members__c>([select id, Name,SVMXC__Service_Group__r.Name,SVMXC__Service_Territory__r.Name, SVMXC__Salesforce_User__c from SVMXC__Service_Group_Members__c where id in : lstTechnId]);
        map<id, SVMXC__Service_Group_Members__c> mapTechForUSer = new map<id, SVMXC__Service_Group_Members__c>([select SVMXC__Salesforce_User__c,id, Name,SVMXC__Service_Group__r.Name,SVMXC__Service_Territory__r.Name from SVMXC__Service_Group_Members__c  where SVMXC__Salesforce_User__c in : lstUserId and SVMXC__Active__c=true]);

        System.debug('SVMX mapTech'+mapTech );
        System.debug('SF mapTechForUSer'+mapTechForUSer );
        map<id, SVMXC__Service_Group_Members__c> mapUSeridTech = new map<id, SVMXC__Service_Group_Members__c>();

        for(id TechId : mapTechForUSer.keyset())
        {   
            mapUSeridTech.put(mapTechForUSer.get(TechId).SVMXC__Salesforce_User__c,mapTechForUSer.get(TechId));
        }
        System.debug('SF mapUSeridTech'+mapUSeridTech );

        for(SVMXC__ServiceMax_Processes__c oPro : [Select SVMXC__Sequence__c, SVMXC__Advance_Expression__c, Id From SVMXC__ServiceMax_Processes__c  where RecordTypeId =:RuleRecordTypeId and SVMXC__Rule_Type__c = 'Event Hover Rule'])  
        {
            mapEventHoverRules.put(oPro.Id, oPro);
        }
        system.debug(LoggingLevel.WARN, 'Size of mapEventHoverRules: ' + mapEventHoverRules.size() + '; Map: ' + mapEventHoverRules);

        if(mapEventHoverRules.size() > 0)
        {
            // Get the Event Hover Rules' entry criteria
            for(SVMXC__ServiceMax_Config_Data__c oExp : [Select Id, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Display_Type__c, SVMXC__Expression_Rule__c From SVMXC__ServiceMax_Config_Data__c where RecordTypeId = :ExpressionRTypeId and SVMXC__Expression_Type__c = 'DISP_Event_Hover_Rule' and SVMXC__Expression_Rule__c IN :mapEventHoverRules.keyset() Order By SVMXC__Sequence__c])  
            {
                if(!mapEventHoverRuleIdExpr.ContainsKey(oExp.SVMXC__Expression_Rule__c))
                    mapEventHoverRuleIdExpr.put(oExp.SVMXC__Expression_Rule__c, new list<SVMXC__ServiceMax_Config_Data__c>());
                mapEventHoverRuleIdExpr.get(oExp.SVMXC__Expression_Rule__c).add(oExp);
                setWOQueryFields.add(oExp.SVMXC__Field_Name__c);
            }
            system.debug(LoggingLevel.WARN, 'Size of mapEventHoverRuleIdExpr: ' + mapEventHoverRuleIdExpr.size() + '; Map: ' + mapEventHoverRuleIdExpr);

            // Get the Hover Fields and store against the Rule Id
            for(SVMXC__ServiceMax_Config_Data__c objEventHoverField: [Select Id, SVMXC__Target_Field_Name__c, SVMXC__Sequence__c, SVMXC__Expression_Rule__c From SVMXC__ServiceMax_Config_Data__c where RecordTypeId = :FieldMapRTypeId and SVMXC__Expression_Rule__c IN :mapEventHoverRules.keyset() order by SVMXC__Sequence__c DESC])
            {
                mapEventHoverFields.put(objEventHoverField.Id, objEventHoverField);
                List<Id> lstHoverFieldId = new List<Id>();
                lstHoverFieldId.add(objEventHoverField.Id);
                
                if(mapEventHoverRuleIdFieldIdList.get(objEventHoverField.SVMXC__Expression_Rule__c) != NULL)
                    lstHoverFieldId.addAll(mapEventHoverRuleIdFieldIdList.get(objEventHoverField.SVMXC__Expression_Rule__c));
                
                mapEventHoverRuleIdFieldIdList.put(objEventHoverField.SVMXC__Expression_Rule__c, lstHoverFieldId);
                setWOQueryFields.add(objEventHoverField.SVMXC__Target_Field_Name__c);
            }
            system.debug(LoggingLevel.WARN, 'Size of mapEventHoverRuleIdFieldIdList: ' +mapEventHoverRuleIdFieldIdList.size() + '; Map: ' + mapEventHoverRuleIdFieldIdList);
        }

        // Get the list of Work Orders associated with the events retrieved
        for(String fieldName : allFields_L)
        {
            // Add the name fields for the reference fields
            if(fieldName.contains('.'))
            {
                if(setWOQueryFields.contains(fieldName.split('\\.',2)[0].replace('__r','__c')))
                    setWOQueryFields.add(fieldName);
                else if((fieldName == 'Owner.Name' && setWOQueryFields.contains('OwnerId')) || (fieldName == 'CreatedBy.Name' && setWOQueryFields.contains('CreatedById')) || (fieldName == 'LastModifiedBy.Name' && setWOQueryFields.contains('LastModifiedById')) || (fieldName == 'RecordType.Name' && setWOQueryFields.contains('RecordTypeId')))
                    setWOQueryFields.add(fieldName);
            }
        }
        setWOQueryFields.retainAll(allFields_L);
        String querySelect = SVMX_getFieldNamesFromList(setWOQueryFields); //Convert the set of strings to comma separated string
        
        mapWorkOrder = new Map<id, SVMXC__Service_Order__c>();
        for(SVMXC__Service_Order__c wo: Database.query('SELECT ' + querySelect + ' FROM SVMXC__Service_Order__c WHERE Id IN:WorkOrderIds')) 
        {
            mapWorkOrder.put(wo.Id, (sObject)wo);
        }
        
        WorkOrderIds.clear();

        // For each Work Order, find the matching Event Hover Rule Id if any
        COMM_SVMXC_Utils4 oUtils = new COMM_SVMXC_Utils4();
        set<string> setEventHoverRuleIds = new set<string>();
        Map<Id, string> mapWOIdEventHoverRuleId = oUtils.SVMX_ExpressionParsing(mapWorkOrder, mapEventHoverRuleIdExpr, mapEventHoverRules);

        mapEventHoverRuleIdExpr.clear();
        mapEventHoverRules.clear();
        system.debug(LoggingLevel.WARN, 'Size of mapWOIdEventHoverRuleId: ' + mapWOIdEventHoverRuleId.size() + '; Map: ' + mapWOIdEventHoverRuleId);

        if(mapWOIdEventHoverRuleId != null)
        {
            // Get the set of unique matched Event Hover Rule Ids
            for(id WOId : mapWOIdEventHoverRuleId.keySet())
            {
                setEventHoverRuleIds.add(mapWOIdEventHoverRuleId.get(WOId));
            }

            // Build the Event Hover info per Work Order and attach to the associated events
            if(mapEventHoverFields != null && mapEventHoverFields.size() > 0)
            {
                // Build the Event Hover info for each Work Order as HTML formatted string
                Map<Id, List<String>> mapWOIdEventHoverInfo = new Map<Id, List<String>>();
                for(id idWorkOrder : mapWOIdEventHoverRuleId.keySet())
                {
                    List<String> lstEventHoverInfo = new List<String>();
                    if(mapEventHoverRuleIdFieldIdList.get(mapWOIdEventHoverRuleId.get(idWorkOrder)) != NULL)
                    {
                        sObject objWO = mapWorkOrder.get(idWorkOrder);
                        for(Id idHoverField: mapEventHoverRuleIdFieldIdList.get(mapWOIdEventHoverRuleId.get(idWorkOrder)))
                        {
                            SVMXC__ServiceMax_Config_Data__c objHoverField = mapEventHoverFields.get(idHoverField);
                            if(!setWOQueryFields.contains(objHoverField.SVMXC__Target_Field_Name__c))
                                continue;
                            if(mapWOFieldNameLabel.containsKey(objHoverField.SVMXC__Target_Field_Name__c))
                            {
                                String strFieldValue;

                                // For reference fields: Process the reference field and get the name field for the lookup
                                if(setRefFields.contains(objHoverField.SVMXC__Target_Field_Name__c))
                                {
                                    Sobject ref_TO = objWO.getSobject(replacementRef.get(objHoverField.SVMXC__Target_Field_Name__c));
                                    if(ref_TO != NULL)
                                    {
                                        strFieldValue = String.valueof(ref_TO.get(replacementNameField.get(objHoverField.SVMXC__Target_Field_Name__c)));
                                    }
                                    if(strFieldValue == NULL)
                                        strFieldValue = '--';
                                }
                                // For datetime fields: Get the datetime formatted in logged in user's timezone
                                else if(setDateTimeFields.contains(objHoverField.SVMXC__Target_Field_Name__c))
                                {
                                    if(objWO.get(objHoverField.SVMXC__Target_Field_Name__c) != NULL)
                                    {
                                        strFieldValue = ((Datetime)(objWO.get(objHoverField.SVMXC__Target_Field_Name__c))).format();
                                        System.debug('strFieldValue: '+strFieldValue);
                                    }
                                    else
                                        strFieldValue = '--';
                                }
                                // For date fields: Get the date formatted in logged in user's timezone
                                else if(setDateFields.contains(objHoverField.SVMXC__Target_Field_Name__c))
                                {
                                    strFieldValue = String.valueOf(objWO.get(objHoverField.SVMXC__Target_Field_Name__c));
                                    if(strFieldValue != NULL)
                                        strFieldValue = Date.valueof(strFieldValue).format();
                                    else
                                        strFieldValue = '--';
                                }
                                // All other fields: Just pass the value as it is stored
                                else
                                {
                                    strFieldValue = String.valueOf(objWO.get(objHoverField.SVMXC__Target_Field_Name__c));
                                    if(strFieldValue == NULL)
                                        strFieldValue = '--';
                                }
                                //lstEventHoverInfo.add('<font color="#6B6B6B">' + mapWOFieldNameLabel.get(objHoverField.SVMXC__Target_Field_Name__c)  + '</font>' + '\n' + strFieldValue +'\n');
                                //lstEventHoverInfo.add('<B>' + mapWOFieldNameLabel.get(objHoverField.SVMXC__Target_Field_Name__c)  + '</B>' + ': ' + strFieldValue);
                                lstEventHoverInfo.add('<B>' + mapWOFieldNameLabel.get(objHoverField.SVMXC__Target_Field_Name__c)  + '</B>' + ': ' + strFieldValue);
                            }
                        }
                    }
                    if(lstEventHoverInfo.size() > 0)
                        mapWOIdEventHoverInfo.put(idWorkOrder, lstEventHoverInfo);
                }


                // Add the Event Hover Info + additional info (WO Number, Service & Driving Duration) to the associated events
                for(id idWorkOrder : mapWOIdEventHoverRuleId.keySet())
                {
                    if(mapWorkOrderEvents.get(idWorkOrder) != NULL)
                    {
                        for(DCEvent_WP event: mapWorkOrderEvents.get(idWorkOrder))
                        {
                            Events_WP event_TWP = new Events_WP(event);
                            // Add the Event Hover Info to the event
                            if(mapWOIdEventHoverInfo.get(idWorkOrder) != NULL)
                            {
                                event_TWP.event_WP.EvntHovrAdditionalInfo = mapWOIdEventHoverInfo.get(idWorkOrder);
                            }

                            // Add the additional info (WO Number, Service & Driving Duration) to the event
                            sObject objWO = mapWorkOrder.get(idWorkOrder);
                            List<KeyValuePair_WP> lstWorkOrderKeyVal = new List<KeyValuePair_WP>();
                            if(objWO.get('Name') != NULL)
                            {
                                lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'Name', String.valueOf(objWO.get('Name'))));
                            }
                            if(objWO.get('SVMXC__Service_Duration__c') != NULL)
                            {
                                lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'SVMXC__Service_Duration__c', String.valueOf(objWO.get('SVMXC__Service_Duration__c'))));
                            }
                            if(objWO.get('SVMXC__Driving_Time__c') != NULL)
                            {
                                lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'SVMXC__Driving_Time__c', String.valueOf(objWO.get('SVMXC__Driving_Time__c'))));
                            }
                            if(mapTech.containsKey(event.ownerId) && mapTech.get(event.ownerId).name != null)
                            {
                                lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'SVMXC__Group_Member__c', String.valueOf(mapTech.get(event.ownerId).name)));
                            }
                            else if(mapUSeridTech.containsKey(event.ownerId) && mapUSeridTech.get(event.ownerId).name != null)
                            {
                                lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'SVMXC__Group_Member__c', String.valueOf(mapUSeridTech.get(event.ownerId).name)));
                            }
                            if(mapTech.containsKey(event.ownerId) && mapTech.get(event.ownerId).id != null)
                            {
                                lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'TechnicianID', String.valueOf(mapTech.get(event.ownerId).id)));
                            }
                            else if(mapUSeridTech.containsKey(event.ownerId) && mapUSeridTech.get(event.ownerId).id != null)
                            {
                                lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'TechnicianID', String.valueOf(mapUSeridTech.get(event.ownerId).id)));
                            }
                            if(mapTech.containsKey(event.ownerId) && mapTech.get(event.ownerId).SVMXC__Service_Group__c != null)
                            {                               
                                lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'SVMXC__Service_Group__c', 
                                        String.valueOf(mapTech.get(event.ownerId).SVMXC__Service_Group__r.name)));
                            }
                            else if(mapUSeridTech.containsKey(event.ownerId) && mapUSeridTech.get(event.ownerId).SVMXC__Service_Group__c != null)
                            {                               
                                lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'SVMXC__Service_Group__c', 
                                        String.valueOf(mapUSeridTech.get(event.ownerId).SVMXC__Service_Group__r.name)));
                            }

                            if((mapTech.containsKey(event.ownerId) && mapTech.get(event.ownerId).SVMXC__Service_Territory__c != null ))
                            {
                                lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'SVMXC__Service_Territory__c', String.valueOf(mapTech.get(event.ownerId).SVMXC__Service_Territory__r.name)));
                            }
                            else if((mapUSeridTech.containsKey(event.ownerId) && mapUSeridTech.get(event.ownerId).SVMXC__Service_Territory__c != null ))
                            {
                                lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'SVMXC__Service_Territory__c', String.valueOf(mapUSeridTech.get(event.ownerId).SVMXC__Service_Territory__r.name)));
                            }

                            if( event_TWP.event_WP.lstKeyValuePair == null)
                                event_TWP.event_WP.lstKeyValuePair = lstWorkOrderKeyVal;
                            else
                                event_TWP.event_WP.lstKeyValuePair.addAll(lstWorkOrderKeyVal);
                            resultSet.add(event_TWP);
                        }
                    }
                }
            }
        }
        mapEventHoverRuleIdFieldIdList.clear();
        mapEventHoverFields.clear();
        mapWOFieldNameLabel.clear();
        System.debug('mapWorkOrderEvents '+mapWorkOrderEvents );
        
        // For Events of Work Orders with no Event Hover Rule, add additional info (WO Number, Service & Driving Duration)
        for(Id idWorkOrder: mapWorkOrder.keySet())
        {
            if(!mapWOIdEventHoverRuleId.containsKey(idWorkOrder))
            {
                if(mapWorkOrderEvents.get(idWorkOrder) != NULL)
                {
                    for(DCEvent_WP event: mapWorkOrderEvents.get(idWorkOrder))
                    {
                        Events_WP event_TWP = new Events_WP(event);
                        sObject objWO = mapWorkOrder.get(idWorkOrder);
                        List<KeyValuePair_WP> lstWorkOrderKeyVal = new List<KeyValuePair_WP>();
                        if(objWO.get('Name') != NULL)
                        {
                            lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'Name', String.valueOf(objWO.get('Name'))));
                        }
                        if(objWO.get('SVMXC__Service_Duration__c') != NULL)
                        {
                            lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'SVMXC__Service_Duration__c', String.valueOf(objWO.get('SVMXC__Service_Duration__c'))));
                        }
                        if(objWO.get('SVMXC__Driving_Time__c') != NULL)
                        {
                            lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'SVMXC__Driving_Time__c', String.valueOf(objWO.get('SVMXC__Driving_Time__c'))));
                        }
                        if(mapTech.containsKey(event.ownerId) && mapTech.get(event.ownerId).name != null)
                        {
                            lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'SVMXC__Group_Member__c', String.valueOf(mapTech.get(event.ownerId).name)));
                        }
                        else if(mapUSeridTech.containsKey(event.ownerId) && mapUSeridTech.get(event.ownerId).name != null)
                        {
                            lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'SVMXC__Group_Member__c', String.valueOf(mapUSeridTech.get(event.ownerId).name)));
                        }
                        if(mapTech.containsKey(event.ownerId) && mapTech.get(event.ownerId).id != null)
                        {
                            lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'TechnicianID', String.valueOf(mapTech.get(event.ownerId).id)));
                        }
                        else if(mapUSeridTech.containsKey(event.ownerId) && mapUSeridTech.get(event.ownerId).id != null)
                        {
                            lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'TechnicianID', String.valueOf(mapUSeridTech.get(event.ownerId).id)));
                        }
                        if(mapTech.containsKey(event.ownerId) && mapTech.get(event.ownerId).SVMXC__Service_Group__c != null)
                        {
                            lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'SVMXC__Service_Group__c', 
                                    String.valueOf(mapTech.get(event.ownerId).SVMXC__Service_Group__r.name)));
                        }
                        else if(mapUSeridTech.containsKey(event.ownerId) && mapUSeridTech.get(event.ownerId).SVMXC__Service_Group__c != null)
                        {
                            lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'SVMXC__Service_Group__c', 
                                    String.valueOf(mapUSeridTech.get(event.ownerId).SVMXC__Service_Group__r.name)));
                        }
                        if((mapTech.containsKey(event.ownerId) && mapTech.get(event.ownerId).SVMXC__Service_Territory__c != null ))
                        {
                            lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'SVMXC__Service_Territory__c', String.valueOf(mapTech.get(event.ownerId).SVMXC__Service_Territory__r.name)));
                        }
                        else if((mapUSeridTech.containsKey(event.ownerId) && mapUSeridTech.get(event.ownerId).SVMXC__Service_Territory__c != null ))
                        {
                            lstWorkOrderKeyVal.add(new KeyValuePair_WP('FIELDVALUE', 'SVMXC__Service_Territory__c', String.valueOf(mapUSeridTech.get(event.ownerId).SVMXC__Service_Territory__r.name)));
                        }

                        if(event_TWP.event_WP.lstKeyValuePair == null)
                            event_TWP.event_WP.lstKeyValuePair = lstWorkOrderKeyVal;
                        else
                            event_TWP.event_WP.lstKeyValuePair.addAll(lstWorkOrderKeyVal);
                        resultSet.add(event_TWP);
                    }
                }
            }
        }   

        return resultSet;
    }
    
    //This method returns a list of Salesforce calendar events for a WO.
    WebService static List<Event> DCON_Retrieve_Salesforce_WO_Events_WS(String UserId, String StartDate, String EndDate, String strWOid)
    {
        List<Event> EventList = new List<Event>();
        Date DStartDate;
        Date DEndDate;        
        Map<String,String> mapValidSettingsForUpdate = new Map<String,String>();
        mapValidSettingsForUpdate = getValidateSettingsFrom38To47();
        set<String> EventOwners = new set<String>();
        set<String> flds = new set<String>();
        set<String> Eventflds = new set<String>();
        DateTime dtmStartDateTime;
        DateTime dtmEndDateTime ;
        
        if(StartDate != null && StartDate != '')
            dtmStartDateTime = dcUtils.getDateTimeInTimezone(Date.valueOf(StartDate), Time.newInstance(0, 0, 0, 0), UserId);
        if(EndDate != null && EndDate != '')
            dtmEndDateTime = dcUtils.getDateTimeInTimezone(Date.valueOf(EndDate), Time.newInstance(23, 59, 59, 59), UserId);
        
        if(mapValidSettingsForUpdate.keySet().size() > 0)
        {
            for(String strfld : mapValidSettingsForUpdate.keySet())
            {
                flds.add(mapValidSettingsForUpdate.get(strfld));    
            }
            String whereStr;
            if(StartDate != null && StartDate != '' && EndDate != null && EndDate != '')
                whereStr = ' where ((StartDateTime >= : dtmStartDateTime and StartDateTime <= : dtmEndDateTime) OR (EndDateTime >= : dtmStartDateTime and StartDateTime <= : dtmEndDateTime)) and whatid = :strWOid and IsRecurrence = false';
            else if((StartDate == null || StartDate == '') && (EndDate != null && EndDate != ''))
                whereStr = ' where (StartDateTime <= : dtmEndDateTime) and whatid = :strWOid and IsRecurrence = false';
            else if((StartDate != null && StartDate != '') && (EndDate == null || EndDate == ''))
                whereStr = ' where (StartDateTime >= : dtmStartDateTime ) and whatid = :strWOid and IsRecurrence = false';
            else
                whereStr = ' where whatid = :strWOid and IsRecurrence = false';
            system.debug('SFEvent where clause'+whereStr);
            
            flds.add('SVMXC__Driving_Time__c');
            flds.add('SVMXC__Overhead_Time_Before__c'); 
            flds.add('SVMXC__Overhead_Time_After__c'); 
            flds.add('SVMXC__Driving_Time_Home__c'); 
            flds.add('SVMXC__Service_Duration__c');
            flds.add('SVMXC__Break_Time_Total__c');

            // This is the change due to the introduction of new fields in event objects
            EventList = Database.query('Select Id, ActivityDate, IsAllDayEvent, ActivityDateTime, OwnerId, DurationInMinutes, Subject, Description, WhatId, StartDateTime, EndDateTime, Location, LastModifiedDate,  ' + SVMX_getFieldNamesFromList(flds) +' from Event ' + whereStr );

        }
        else
        {
            if(StartDate != null && StartDate != '' && EndDate != null && EndDate != '')
                EventList = [Select Id, ActivityDate, ActivityDateTime, IsAllDayEvent, OwnerId, DurationInMinutes, Subject, Description, WhatId, StartDateTime, EndDateTime, Location, LastModifiedDate, SVMXC__Driving_Time__c, SVMXC__Overhead_Time_Before__c, SVMXC__Overhead_Time_After__c, SVMXC__Driving_Time_Home__c, SVMXC__Service_Duration__c,SVMXC__Break_Time_Total__c from Event where ((StartDateTime >= : dtmStartDateTime and StartDateTime <= : dtmEndDateTime) OR (EndDateTime >= : dtmStartDateTime and StartDateTime <= : dtmEndDateTime)) and whatid = :strWOid and IsRecurrence = false];
            else if((StartDate == null || StartDate == '') && (EndDate != null && EndDate != ''))           
                EventList = [Select Id, ActivityDate, ActivityDateTime, IsAllDayEvent, OwnerId, DurationInMinutes, Subject, Description, WhatId, StartDateTime, EndDateTime, Location, LastModifiedDate,SVMXC__Driving_Time__c, SVMXC__Overhead_Time_Before__c, SVMXC__Overhead_Time_After__c, SVMXC__Driving_Time_Home__c, SVMXC__Service_Duration__c,SVMXC__Break_Time_Total__c from Event where (StartDateTime <= : dtmEndDateTime) and whatid = :strWOid and IsRecurrence = false];   

            else if((StartDate != null && StartDate != '') && (EndDate == null || EndDate == ''))         
                EventList = [Select Id, ActivityDate, ActivityDateTime, IsAllDayEvent, OwnerId, DurationInMinutes, Subject, Description, WhatId, StartDateTime, EndDateTime, Location, LastModifiedDate, SVMXC__Driving_Time__c, SVMXC__Overhead_Time_Before__c, SVMXC__Overhead_Time_After__c, SVMXC__Driving_Time_Home__c, SVMXC__Service_Duration__c,SVMXC__Break_Time_Total__c from Event where (StartDateTime >= : dtmStartDateTime )  and whatid = :strWOid and IsRecurrence = false];           
            else            
                EventList = [Select Id, ActivityDate, ActivityDateTime, IsAllDayEvent, OwnerId, DurationInMinutes, Subject, Description, WhatId, StartDateTime, EndDateTime, Location, LastModifiedDate, SVMXC__Driving_Time__c, SVMXC__Overhead_Time_Before__c, SVMXC__Overhead_Time_After__c, SVMXC__Driving_Time_Home__c, SVMXC__Service_Duration__c,SVMXC__Break_Time_Total__c from Event where whatid = :strWOid and IsRecurrence = false];
        }
        return EventList;
    }
    
    //This method returns a list of ServiceMax calendar events for a WO.
    WebService static List<SVMX_Event__c> DCON_Retrieve_ServiceMax_WO_Events_WS(String UserId, String StartDate, String EndDate, String strWOid)
    {
        List<SVMX_Event__c> EventList = new List<SVMX_Event__c>();        
        Map<String,String> mapValidSettingsForUpdate = new Map<String,String>();
        mapValidSettingsForUpdate = getValidateSettingsFrom38To47();
        set<String> flds = new set<String>();
        set<String> Eventflds = new set<String>();        
        set<String> EventOwners = new set<String>();            
        DateTime dtmStartDateTime;
        DateTime dtmEndDateTime ;

        if(StartDate != null && StartDate != '')
            dtmStartDateTime = dcUtils.getDateTimeInTimezone(Date.valueOf(StartDate), Time.newInstance(0, 0, 0, 0), UserId);

        if(EndDate != null && EndDate != '')
            dtmEndDateTime = dcUtils.getDateTimeInTimezone(Date.valueOf(EndDate), Time.newInstance(23, 59, 59, 59), UserId);
        
        if(mapValidSettingsForUpdate.keySet().size() > 0)
        {
            for(String strfld : mapValidSettingsForUpdate.keySet())
            {
                flds.add(mapValidSettingsForUpdate.get(strfld));    
            }
            
            String whereStr;
            if(StartDate != null && StartDate != '' && EndDate != null && EndDate != '')
                whereStr = ' where ((SVMXC__StartDateTime__c >= : dtmStartDateTime and SVMXC__StartDateTime__c <= : dtmEndDateTime) OR (SVMXC__EndDateTime__c >= : dtmStartDateTime and SVMXC__StartDateTime__c <= : dtmEndDateTime)) and SVMXC__WhatId__c =:strWOid';
            else if((StartDate == null || StartDate == '') && (EndDate != null && EndDate != ''))           
                whereStr = ' where (SVMXC__StartDateTime__c <= : dtmEndDateTime) and SVMXC__WhatId__c =:strWOid';

            else if((StartDate != null && StartDate != '') && (EndDate == null || EndDate == ''))         
                whereStr = ' where (SVMXC__StartDateTime__c >= : dtmStartDateTime ) and SVMXC__WhatId__c =:strWOid';        
            else            
                whereStr = ' where  SVMXC__WhatId__c =:strWOid';
            system.debug('SVMXEvent where clause'+whereStr);

            flds.add('SVMXC__Driving_Time__c');
            flds.add('SVMXC__Overhead_Time_Before__c'); 
            flds.add('SVMXC__Overhead_Time_After__c'); 
            flds.add('SVMXC__Driving_Time_Home__c'); 
            flds.add('SVMXC__Service_Duration__c');
            flds.add('SVMXC__Break_Time_Total__c');
            flds.add('SVMXC__IsAllDayEvent__c');

            // This is the change due to the introduction of new fields in event objects
            EventList = Database.query('SELECT Id, SVMXC__ActivityDate__c, SVMXC__ActivityDateTime__c, SVMXC__Technician__c, SVMXC__DurationInMinutes__c, Name, SVMXC__Description__c, SVMXC__WhatId__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c, SVMXC__Location__c, LastModifiedDate, ' + SVMX_getFieldNamesFromList(flds) +' from SVMX_Event__c  '+whereStr);              
        }
        else
        {
            if(StartDate != null && StartDate != '' && EndDate != null && EndDate != '')
                EventList = [Select Id, SVMXC__ActivityDate__c, SVMXC__ActivityDateTime__c, SVMXC__Technician__c, SVMXC__DurationInMinutes__c, Name, SVMXC__Description__c, SVMXC__WhatId__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c, SVMXC__Location__c, LastModifiedDate, SVMXC__Driving_Time__c, SVMXC__IsAllDayEvent__c,SVMXC__Overhead_Time_Before__c, SVMXC__Overhead_Time_After__c, SVMXC__Driving_Time_Home__c, SVMXC__Service_Duration__c,SVMXC__Break_Time_Total__c from SVMX_Event__c where ((SVMXC__StartDateTime__c >= : dtmStartDateTime and SVMXC__StartDateTime__c <= : dtmEndDateTime) OR (SVMXC__EndDateTime__c >= : dtmStartDateTime and SVMXC__StartDateTime__c <= : dtmEndDateTime)) and SVMXC__WhatId__c =:strWOid];
            else if((StartDate == null || StartDate == '') && (EndDate != null && EndDate != ''))           
                EventList = [Select Id, SVMXC__ActivityDate__c, SVMXC__ActivityDateTime__c, SVMXC__Technician__c, SVMXC__DurationInMinutes__c, Name, SVMXC__Description__c, SVMXC__WhatId__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c, SVMXC__Location__c, LastModifiedDate, SVMXC__Driving_Time__c, SVMXC__IsAllDayEvent__c,SVMXC__Overhead_Time_Before__c, SVMXC__Overhead_Time_After__c, SVMXC__Driving_Time_Home__c, SVMXC__Service_Duration__c,SVMXC__Break_Time_Total__c from SVMX_Event__c where  (SVMXC__StartDateTime__c <= : dtmEndDateTime) and SVMXC__WhatId__c =:strWOid];

            else if((StartDate != null && StartDate != '') && (EndDate == null || EndDate == ''))         
                EventList = [Select Id, SVMXC__ActivityDate__c, SVMXC__ActivityDateTime__c, SVMXC__Technician__c, SVMXC__DurationInMinutes__c, Name, SVMXC__Description__c, SVMXC__WhatId__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c, SVMXC__Location__c, LastModifiedDate, SVMXC__Driving_Time__c, SVMXC__IsAllDayEvent__c,SVMXC__Overhead_Time_Before__c, SVMXC__Overhead_Time_After__c, SVMXC__Driving_Time_Home__c, SVMXC__Service_Duration__c,SVMXC__Break_Time_Total__c from SVMX_Event__c where (SVMXC__StartDateTime__c >= : dtmStartDateTime )  and SVMXC__WhatId__c =:strWOid];
            else            
                EventList = [Select Id, SVMXC__ActivityDate__c, SVMXC__ActivityDateTime__c, SVMXC__Technician__c, SVMXC__DurationInMinutes__c, Name, SVMXC__Description__c, SVMXC__WhatId__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c, SVMXC__Location__c, LastModifiedDate, SVMXC__Driving_Time__c, SVMXC__IsAllDayEvent__c,SVMXC__Overhead_Time_Before__c, SVMXC__Overhead_Time_After__c, SVMXC__Driving_Time_Home__c, SVMXC__Service_Duration__c,SVMXC__Break_Time_Total__c from SVMX_Event__c where  SVMXC__WhatId__c =:strWOid];
        }
        return EventList;
    }

    //This method accepts a list of calendar events with technician, type of event, work order, start time and duration, and creates the events either in Salesforce Events or ServiceMax events or both. 
    //If an event already exists, it also updates the record.
    WebService static String DCON_Upsert_Events_WS(String UserId, String timeZone, List<Event> Events){
        return null;
    }

    public static set<String> getEventEnablesTechnicians(set<String> technicianIds)
    {
        set<String> availabeltech = new set<String>();
        if(technicianIds.size() > 0){
            for(SVMXC__Service_Group_Members__c tech: [Select Id from SVMXC__Service_Group_Members__c where id IN :technicianIds and  SVMXC__Enable_Scheduling__c = true]){
                //for(SVMXC__Service_Group_Members__c tech: techList){    
                availabeltech.add(tech.Id);
            }
        }
        return availabeltech;
    }

    public static DateTime getLeastDateTime(List<DateTime> dateTimes)
    {
        DateTime leastDateTime;
        if(dateTimes.size() > 0)
        {
            for(DateTime dt: dateTimes)
            {
                if(leastDateTime == NULL)
                    leastDateTime = dt;
                else
                    if(dt < leastDateTime)
                        leastDateTime = dt;     
            }
        }

        return leastDateTime;
    }
    
    //This method accepts a calendar event with technician, type of event, work order, start time and duration, and creates the events either in Salesforce Events or ServiceMax events or both. 
    WebService static List<String> DCON_Create_Events_WS(String UserId, String timeZone, List<Event> EventList){
        return null;
    }

    public static String CheckNull(String s){
        if(s == NULL)
            return '';
        else
            return s;
    }
    
    //Method to Set the subject of an Event : created by Akash on 20th May 2010
    WebService static List<String> DCON_Event_SubjectDef(String WOIdUserId)
    {
        //WOIdUserId will have work order id followed by UserId
        //Since this is a webservice, we could not change the arguments, hence we are sending both WoId and UserId in one string
        List<String> splitFileds = WOIdUserId.split(',');
        string WId = splitFileds[0];
        COMM_SVMXC_Utils4 oUtils = new COMM_SVMXC_Utils4();
        list<string> APIList = new list<string>();
        SVMXC__Service_Order__c Wo = new SVMXC__Service_Order__c();
        Map<Id,SVMXC__ServiceMax_Processes__c> RuleMap  = new Map<Id,SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Processes__c> EvntSubRuleList = new list<SVMXC__ServiceMax_Processes__c>();  
        list<SVMXC__ServiceMax_Config_Data__c> ConfigDataList = new list<SVMXC__ServiceMax_Config_Data__c>();
        Map<Id,list<SVMXC__ServiceMax_Config_Data__c>> RuleExpMap  = new Map<Id,list<SVMXC__ServiceMax_Config_Data__c>>();  
        list<SVMXC__ServiceMax_Config_Data__c> FieldMapList = new list<SVMXC__ServiceMax_Config_Data__c>();        
        string RuleRecordTypeId;
        string ExpressionRTypeId;
        string FieldMapRTypeId;

        for(RecordType r : [Select SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId From RecordType r where SobjectType = 'SVMXC__ServiceMax_Processes__c' OR SobjectType = 'SVMXC__ServiceMax_Config_Data__c'])   
        {
            if(r.Name == 'SVMX Rule'){
                RuleRecordTypeId = r.id;
            }
            if(r.Name == 'Expressions'){
                ExpressionRTypeId = r.id;
            }
            if(r.Name == 'Field Mapping'){
                FieldMapRTypeId = r.id;
            } 
        }

        for(SVMXC__ServiceMax_Processes__c oPro : [Select SystemModstamp, SVMXC__MTTS_Minutes__c, SVMXC__Weight_Total_Distance__c, SVMXC__Weight_Time_Window__c, SVMXC__Weight_Route_Time__c, SVMXC__Weight_Route_Distance__c, SVMXC__Weight_Node_Type__c, SVMXC__Territory__c, SVMXC__Technician_User__c, SVMXC__Technician_Service_Group__c, SVMXC__Start_Time__c, SVMXC__Start_Date__c, SVMXC__Schedule_Event__c, SVMXC__Runs_Every_Wednesday__c, SVMXC__Runs_Every_Tuesday__c, SVMXC__Runs_Every_Thursday__c, SVMXC__Runs_Every_Sunday__c, SVMXC__Runs_Every_Saturday__c, SVMXC__Runs_Every_Monday__c, SVMXC__Runs_Every_Friday__c, SVMXC__Route_Type__c, SVMXC__Retain_Assignment__c, SVMXC__Retain_Appointment__c, SVMXC__Product_Match_Enabled__c, SVMXC__Preferred_Tech_Enabled__c, SVMXC__Frequency__c, SVMXC__Final_Exception_Process__c, SVMXC__Expertise_Match_Enabled__c, SVMXC__End_Date__c, SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c, SVMXC__Distance_And_Time__c, SVMXC__Dispatch_Process_Status__c, SVMXC__Dispatch_Method__c, SVMXC__Calendar_Start_Type__c, SVMXC__Calendar_Start_Days__c, SVMXC__Calendar_End_Type__c, SVMXC__Calendar_End_Days__c, SVMXC__Assign_Work_Order_To__c, SVMXC__Assign_To_Technician__c, SVMXC__Assign_To_Queue__c, SVMXC__Assign_To_Dispatcher__c, SVMXC__Values__c, SVMXC__Target_Record_Type__c, SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c, SVMXC__Settings_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__Setting_Type__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Record_Type_Name__c, SVMXC__Process__c, SVMXC__ProcessID__c, SVMXC__Pick_First_Match__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c, SVMXC__Match_Contact__c, SVMXC__Match_Account__c, SVMXC__MapID__c, SVMXC__IsStandard__c, SVMXC__IsPrivate__c, SVMXC__Installation_Key__c, SVMXC__Include_Top_Level__c, SVMXC__Include_Product__c, SVMXC__Include_Parent__c, SVMXC__Entitlement_Scope__c, SVMXC__Entitlement_By__c, SVMXC__Description__c, SVMXC__Default_Value__c, SVMXC__Data_Type__c, SVMXC__Counter_Vs_Dates_Rule__c, SVMXC__Child_Object_Criteria__c, SVMXC__Advance_Expression__c, SVMXC__Active__c, RecordTypeId, OwnerId, Name, LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__ServiceMax_Processes__c  where RecordTypeId =:RuleRecordTypeId and SVMXC__Rule_Type__c ='Event Subject Rule']){    
            RuleMap.put(oPro.Id,oPro);
        }
        ConfigDataList = [Select SystemModstamp, SVMXC__Dispatch_Process__c, SVMXC__User__c, SVMXC__Target_Field_Name__c, SVMXC__Stock_Status__c, SVMXC__Stock_History_Line_Lookup_Field__c, SVMXC__Stock_History_Header_Lookup_Field__c, SVMXC__Source_Field_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__Setting_ID__c, SVMXC__Setting_Configuration_Profile__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__RecordType_Name__c, SVMXC__Profile__c, SVMXC__Profile_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__MapID__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Location_Type__c, SVMXC__Location_Field_Name__c, SVMXC__Location_Field_From__c, SVMXC__IsDefault__c, SVMXC__Inventory_Process__c, SVMXC__Internal_Value__c, SVMXC__Installation_Key__c, SVMXC__Field_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, SVMXC__Enter_Date__c, SVMXC__Display_Value__c, SVMXC__Display_Type__c, SVMXC__Display_Map_ID__c, SVMXC__Description__c, SVMXC__Configuration_Type__c, SVMXC__Config_Profile_Name__c, SVMXC__Active__c, SVMXC__Action__c, SVMXC__Access_Configuration_Profile__c, RecordTypeId, OwnerId, Name, LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById, SVMXC__Field_Relationship_Name__c From SVMXC__ServiceMax_Config_Data__c where RecordTypeId=:ExpressionRTypeId and SVMXC__Expression_Type__c ='DISP_Event_Subject_Rule' and SVMXC__Expression_Rule__c IN:RuleMap.keyset()];//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        for(SVMXC__ServiceMax_Config_Data__c oExp : ConfigDataList){
            if(!RuleExpMap.ContainsKey(oExp.SVMXC__Expression_Rule__c))
                RuleExpMap.put(oExp.SVMXC__Expression_Rule__c, new list<SVMXC__ServiceMax_Config_Data__c>());
            RuleExpMap.get(oExp.SVMXC__Expression_Rule__c).add(oExp);
        }

        //Instead of querying all fields, query only required fields.
        Set<String> setWOFlds = new Set<String>();
        String strWOFldsQry = ''; 
        for(SVMXC__ServiceMax_Config_Data__c oExpression: ConfigDataList)
        {
            if(oExpression.SVMXC__Field_Name__c != null && oExpression.SVMXC__Field_Name__c.length() > 0 && !setWOFlds.contains(oExpression.SVMXC__Field_Name__c))
            { 
                setWOFlds.add(oExpression.SVMXC__Field_Name__c);
                if(strWOFldsQry.length() > 0)
                    strWOFldsQry += ',';
                strWOFldsQry += oExpression.SVMXC__Field_Name__c;
            }
        }

        try {   
            Wo = database.query('Select ' + strWOFldsQry + ' ,Id From SVMXC__Service_Order__c ' + '  where Id =: WId');
        }
        catch(exception ex) { 
            system.debug(LoggingLevel.DEBUG, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
        }

        string RuleId = oUtils.SVMX_ExpressionParsing((SObject)Wo, RuleExpMap, RuleMap);

        RuleMap.clear();
        RuleExpMap.clear();
        if(RuleId!=null){
            FieldMapList = [Select SVMXC__Target_Field_Name__c, SVMXC__Field_Relationship_Name__c From SVMXC__ServiceMax_Config_Data__c where RecordTypeId=:FieldMapRTypeId and SVMXC__Expression_Rule__c =:RuleId order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        
        List<String> evtSubRuleLst = new List<String>();
        if(FieldMapList!=null && FieldMapList.size()>0){
            for(SVMXC__ServiceMax_Config_Data__c oExp : FieldMapList){
                APIList.add(oExp.SVMXC__Target_Field_Name__c);
            }
        }

        //START: DNS-623
        SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils(); 
        DCON_Utils dcUtils1 = new DCON_Utils(); 
        String queryStr; 
        Boolean isLocal = false;
        List<DCON_Work_Order_WS.workorder_WP> workorder_LWP = new List<DCON_Work_Order_WS.workorder_WP>(); //Result set for the method
        List<SVMXC__Service_Order__c> workorder_LO = new List<SVMXC__Service_Order__c>();
        List<String> refFields_L = new List<String>();
        List<String> dateTimeFields_L = new List<String>();
        List<String> dateFields_L = new List<String>();
        Map<String,String> replacementRef = new Map<String,String>();
        Map<String,String> replacementNameField = new Map<String,String>();
         List<String> pickList_L = new List<String>();
        Map<String, SObjectField> newSchemaFieldMap = new Map<String, SObjectField>();
        Map<String, SObjectField> souObjfieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap(); // Get field definition map for work order
        
        //get the list of WO fields which are to be loaded from a subject rule defined
        Set<String> setWOFields =  new Set<String>(APIList);
        
        //Get only those WO fields which have to be populated
        for (String fieldKey : souObjfieldMap.keySet()) 
        {
            String fieldName='';
            Schema.SObjectField fsObj = souObjfieldMap.get(fieldKey); 
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            fieldName = f.getName();
            
            if(setWOFields.contains(fieldName))
                newSchemaFieldMap.put(fieldName, fsObj);
        }
        DCON_Utils.DCON_referenceFields_WP reference_M = dcUtils1.DCON_getReferenceFields(newSchemaFieldMap,true);  
        
        //DCON_Utils.referenceFields_WP reference_M = dcUtils1.SVMX_getReferenceFields(newSchemaFieldMap,true);    
        newSchemaFieldMap.clear();
        souObjfieldMap.clear();
        
        List<String> limitedFields_L = reference_M.allFields_L; //Get the all field list
        refFields_L = reference_M.referenceFields_L; //Get the reference field list
        dateTimeFields_L = reference_M.dateTimeFields_L; //Get the dateTime field list
        dateFields_L = reference_M.dateFields_L; //Get the date field list
        replacementRef = reference_M.replacementReference_M;  //Get the replacement reference field map
        replacementNameField = reference_M.replacementField_M;  //Get the name field for reference map
        pickList_L = reference_M.pickList_L;
         queryStr = utils.DCON_getFieldNamesFromList(limitedFields_L,pickList_L);
       // queryStr = utils.SVMX_getFieldNamesFromList(limitedFields_L); //Convert the list of strings to coma seperated string

        //Check for User TimeZone
        String timeZone;
        String UserId;
        //Check if UserId exists in the parameter passed
        if(splitFileds.size() > 1)
            UserId = splitFileds[1];
            
        try 
        {
            if(!UserId.equals(Userinfo.getUserId()))
                timeZone = [SELECT TimeZoneSidKey from User where Id = :UserId].TimeZoneSidKey;
            else
                timeZone = Userinfo.getTimeZone().getID();
        }
        catch(Exception ex)
        {
            timeZone = Userinfo.getTimeZone().getID();
        }

        DCON_Work_Order_WS.workorder_WP workorder_WP;
        List<DCON_Work_Order_WS.workorderSpecialFields_WP> specialFields_LWP;

        try
        {
            if(FieldMapList!=null && FieldMapList.size()>0){
                for(SVMXC__Service_Order__c workOrderObj:  Database.query('Select ' + queryStr + ' From SVMXC__Service_Order__c ' + '  where Id =: WId')) {
                    specialFields_LWP = new List<DCON_Work_Order_WS.workorderSpecialFields_WP>();

                    for(String s : refFields_L){
                        DCON_Work_Order_WS.workorderSpecialFields_WP tRef;
                        Sobject ref_TO = workOrderObj.getSobject(replacementRef.get(s));
                        if(ref_TO!=NULL){
                            tRef = new DCON_Work_Order_WS.workorderSpecialFields_WP(s, String.valueof(ref_TO.get(replacementNameField.get(s))) );
                            specialFields_LWP.add(tRef);
                        }
                    }

                    for(String s : dateTimeFields_L){
                        DCON_Work_Order_WS.workorderSpecialFields_WP tDateTime;
                        if(workOrderObj.get(s) != NULL){
                            tDateTime = new DCON_Work_Order_WS.workorderSpecialFields_WP(s, dcUtils1.getDateTimeInTimezone(Datetime.valueof(workOrderObj.get(s)).date(), Datetime.valueof(workOrderObj.get(s)).time(), timeZone).format() );
                            system.debug('yat tDateTime' + tDateTime);
                            specialFields_LWP.add(tDateTime);
                        }
                    }

                    for(String s : dateFields_L){
                        DCON_Work_Order_WS.workorderSpecialFields_WP tDate;
                        if(workOrderObj.get(s) != NULL){
                            tDate = new DCON_Work_Order_WS.workorderSpecialFields_WP(s, Date.valueof(String.valueof(workOrderObj.get(s))).format() );
                            specialFields_LWP.add(tDate);
                        }
                    }
                    workorder_WP = new DCON_Work_Order_WS.workorder_WP(workOrderObj,specialFields_LWP);
                    workorder_LWP.add(workorder_WP);
                }
            }
        }
        catch(Exception ex){
            system.debug(LoggingLevel.DEBUG, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getmessage());
        }

        String jsonStr =  JSON.serialize(workorder_LWP);
        //Defect #034133 - Added below code to display the fields of 'event subject rule' in sequence order. 
        List<DCON_Work_Order_WS.workorderSpecialFields_WP> subjectRuleSequence = new List<DCON_Work_Order_WS.workorderSpecialFields_WP>();
        DCON_Work_Order_WS.workorder_WP workorder_WP_Seq;
        DCON_Work_Order_WS.workorderSpecialFields_WP tempsubjectRuleSequence;
        Integer sequenceNo = 0;
        for (String APIvalue : APIList) 
            {   sequenceNo = sequenceNo + 1;
                tempsubjectRuleSequence = new DCON_Work_Order_WS.workorderSpecialFields_WP(String.valueOf(sequenceNo),APIvalue);
                subjectRuleSequence.add(tempsubjectRuleSequence);
                
            }
        workorder_WP_Seq = new DCON_Work_Order_WS.workorder_WP(null,subjectRuleSequence);
        String jsonStr_Subject_rule_sequence = JSON.serialize(workorder_WP_Seq);
        String jsonStr1 = jsonStr + '~|' + jsonStr_Subject_rule_sequence;
        System.debug('jsonStr1:' + jsonStr1);
        System.debug('jsonStr_Subject_rule_sequence:' + jsonStr_Subject_rule_sequence);
        evtSubRuleLst.add(jsonStr1);
        System.debug('evtSubRuleLst:' + evtSubRuleLst);
        //END: DNS-623
        return evtSubRuleLst;
    }
    
    WebService static List<String> DCON_Create_Events_WS2(String UserId, String timeZone, List<Event> lstEvent, list<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue)
    {
        return null;
    }
    
    WebService static List<String> DCON_Create_Events_WS3(String UserId,  List<Event> lstEvent, String timeZone, list<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue)
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
        Map<String,String> settingvalues = getEvtandWofields();
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
        //lstKeyValue.clear();
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
            System.debug(loggingLevel.Warn,'Calling checkDoublebookingforTech '+lstEvent);
            if(svmxSettingList.containsKey('SET025') && (svmxSettingList.get('SET025').toUpperCase()=='DISALLOW'))      
                DCON_DoubleBooking.checkDoublebookingforTech(lstEvent,timeZone,discResUser.getKeyPrefix());        
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
            setAvailableTechnicains = getEventEnablesTechnicians(setAvailableTechnicains);

            Set<String> lstWOID = new Set<String>();
            Set<String> lstTechID = new Set<String>();
            Map<String, DateTime> mapEventIDScheduledDatetime = new Map<String, DateTime>();
            Map<String, DateTime> mapWorkOrderIDScheduledDatetime = new Map<String, DateTime>();
            for(Event oEvent: lstEvent)
            {
                //DC only supports WO Event and non associated event creation
                //Therefore the below check is sufficient ( 'other event' case can be relaxed here)
                //OPT-493
                //We have added extra check to add only workorder Id if whatID of event as workorder ID
                if(oEvent.WhatId != NULL)
                {
                    String woKeyPrefix = Schema.SObjectType.SVMXC__Service_Order__c.getKeyPrefix();
                    if(woKeyPrefix.equals(String.valueOf(oEvent.WhatId).substring(0,3)))
                    {
                        lstWOID.add(oEvent.WhatId);
                    }   
                }
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
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(schWO,COMM_SecurityUtils.Access.Updateable)){
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
                if (!securityUtils.verifyFieldAccess(lstSFEvents, COMM_SecurityUtils.Access.Createable))
                {

                    throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                }
                else
                {
                    insert lstSFEvents; 
                }
            }
            if(lstSVMXEvents.size()>0)
            {
                system.debug('Create Event Svmxflds : '+ lstSVMXEvents);
                if (!securityUtils.verifyFieldAccess(lstSVMXEvents, COMM_SecurityUtils.Access.Createable))
                {

                    throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                }
                else
                {
                    insert lstSVMXEvents; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
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
    
    WebService static String DCON_Upsert_Events_WS3(String UserId, List<Event> Events, String timeZone, list<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue)
    {
        SVMXC.COMM_Utils_ManageTags comTagUtils = new SVMXC.COMM_Utils_ManageTags();
        Map<String, String> mapSVMXTags = comTagUtils.SVMX_getTagList('DCON001');
        String StatusMessage;
        List<Event> SFEvents = new  List<Event>();
        List<Event> SVMXEvents = new  List<Event>();
        List<String> EventDelList = new  List<String>();
        List<SVMXC__SVMX_Event__c> TempSVMXEventList = new List<SVMXC__SVMX_Event__c>();
        List<Event> UpsertSFEventlist = new List<Event>();
        List<SVMXC__SVMX_Event__c> UpsertSVMXEventlist = new List<SVMXC__SVMX_Event__c>();
        set<String> SVMXEventIds = new set<String>();
        set<String> SFEventIds = new set<String>();
        set<String> givenEventIds = new set<String>();
        Map<Id, integer> mapWOIdleDuration = new Map<Id, integer>();
        Map<Id, integer> mapWODriveDuration = new Map<Id, integer>();
        Map<Id, integer> mapWOServiceDuration = new Map<Id, integer>();
        Map<Id, integer> mapWOScope = new Map<Id, integer>();
        Map<Id, integer> mapWOVariance = new Map<Id, integer>();
        Map<String, String> mapWOSettings = new Map<String, String>();
        Map<String, String> mapEventSettings = new Map<String, String>();
        Map<String, String> mapNewSettings = new Map<String, String>();
        Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        Schema.Describesobjectresult discWorkOrder;        
        system.debug(logginglevel.warn,'Events:  '+Events);        
        if (allObjs.containsKey('SVMXC__Service_Order__c') == true)
            discWorkOrder = allObjs.get('SVMXC__Service_Order__c').getDescribe();
        else
            discWorkOrder = allObjs.get('Service_Order__c').getDescribe();

        Map<String,String> WOFieldDef = new Map<String,String>();    
        Map<String, SObjectField> souObjfieldMapWO = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap();
        WOFieldDef = dcUtils.SVMX_getAllFieldMap(souObjfieldMapWO);        
        Map<String,String> EVTFieldDef = new Map<String,String>();
        Map<String, SObjectField> souObjfieldMapEVT = Schema.SObjectType.Event.fields.getMap();
        EVTFieldDef = dcUtils.SVMX_getAllFieldMap(souObjfieldMapEVT);         
        Map<String,String> SVMXEVTFieldDef = new Map<String,String>();
        Map<String, SObjectField> souObjfieldMapSVMXEVT = Schema.SObjectType.SVMXC__SVMX_Event__c.fields.getMap();
        SVMXEVTFieldDef = dcUtils.SVMX_getAllFieldMap(souObjfieldMapSVMXEVT);        
        //24494

        souObjfieldMapEVT.clear();
        souObjfieldMapWO.clear();
        souObjfieldMapSVMXEVT.clear();
        String eventExistErrorMessage = mapSVMXTags.get('TAG238');
        Map<String,String> settingvalues = getEvtandWofields();
        system.debug('Upsert Event settingvalues : '+ settingvalues);
        //Update fields configured
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
                    }
                    else
                    {
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

        lstKeyValue.clear();
        Map<String, SVMXC__SVMX_Event__c> SVMXEventMap = new Map<String, SVMXC__SVMX_Event__c>();
        Map<String, Event> SFEventMap = new Map<String, Event>();
        
        Savepoint sp = Database.setSavepoint();

        if(Events.size()==0)
            throw new SVMXException('Please provide some events to insert');
        
        Boolean isError = false;
        Boolean isEventExist = false;
        String errMessage;
        boolean supportNonWorkOrdEvent = true;

        try
        {
            //Check for User TimeZone
            if(timeZone == NULL || timeZone == '')
            {
                if(!Userinfo.getUserId().contains(UserId))
                    timeZone = [SELECT TimeZoneSidKey from User where Id = :UserId].TimeZoneSidKey;
                else
                    timeZone = Userinfo.getTimeZone().getID();
            }

            Schema.Describesobjectresult objEvent = allObjs.get('Event').getDescribe();
            String EventKey = objEvent.getKeyPrefix();
            Schema.Describesobjectresult objUser = allObjs.get('User').getDescribe();
            allObjs.clear();
            String UserKey = objUser.getKeyPrefix();
            String TempEventId;
            String TempOwnerId;

            set<String> availableTechnicains = new set<String>();

            // Get setting value to support Non-Work Order event
            if(svmxSettingList != NULL && svmxSettingList.containsKey('SET062') && svmxSettingList.get('SET062') != NULL)
                supportNonWorkOrdEvent = boolean.valueOf(svmxSettingList.get('SET062'));

            // Get the original WhatId of all event except Work Order and update the list of SF Event
            if(supportNonWorkOrdEvent)
            {
                set<string> setEventIDs = new set<string>();
                map<string,Event> mapSFEvent = new map<string,Event>();
                map<string,SVMXC__SVMX_Event__c> mapSVMXEvent = new map<string,SVMXC__SVMX_Event__c>();

                for(Event e : Events)
                {

                    //To support the setting based non-associated event identification
                    if (isSplRelatedHandling!= null && isSplRelatedHandling == true)
                    {
                        If( e.Id != NULL && (e.WhatId == NULL || (setApiName != null && setApiName.size()> 0 && e.WhatId != null && setApiName.contains(String.valueOf((Id.ValueOf(e.WhatId).getsobjectType()))))))
                        setEventIDs.add(e.Id);
                    } 
                    else
                    {
                        if(e.Id != NULL && e.WhatId == NULL)
                            setEventIDs.add(e.Id);
                    }
                }
                if(setEventIDs.size() > 0)
                {
                    //Defect# 014336 - added 'Type' field
                    mapSFEvent.putAll([Select Id, Type, WhatId from Event where Id IN: setEventIDs AND WhatId != NULL]);
                    mapSVMXEvent.putAll([Select Id, SVMXC__Type__c, SVMXC__WhatId__c from SVMXC__SVMX_Event__c where Id IN: setEventIDs AND SVMXC__WhatId__c != NULL]);
                }

                for(Event e : Events)
                {
                    if(mapSFEvent.containsKey(e.Id) && mapSFEvent.get(e.Id).WhatId != NULL)
                        e.WhatId = mapSFEvent.get(e.Id).WhatId;
                    else if(mapSVMXEvent.containsKey(e.Id) && mapSVMXEvent.get(e.Id).SVMXC__WhatId__c != NULL)
                        e.WhatId = mapSVMXEvent.get(e.Id).SVMXC__WhatId__c;
                }
                mapSFEvent.clear();
                mapSVMXEvent.clear();
                setEventIDs.clear();
            }
            if(svmxSettingList != null && svmxSettingList.containskey('SET027') && svmxSettingList.get('SET027').toUpperCase()=='DISALLOW')
                DCON_DoubleBooking.checkDoublebookingforTech(Events,timeZone,UserKey);
            system.debug(logginglevel.warn,'Events: ' + Events);        
            //Check for Technicians with SVMXC__Enable_Scheduling__c = true
            for(Event e: Events)
            {
                Event oEvent = e;             
                DateTime eventStartTime = dcUtils.getDateTimeInTimezone(DateTime.valueof(oEvent.ActivityDateTime).dateGmt(), DateTime.valueof(oEvent.ActivityDateTime).timeGmt(), timeZone);
                DateTime eventEndTime = DateTime.valueof(eventStartTime).addMinutes(Integer.valueof(oEvent.DurationInMinutes));         

                givenEventIds.add(e.Id);
                string eventId = e.Id;
                //Apurva:  Defect - 033903 
                if(eventId != null && eventId != '' && eventId != 'null')
                    SFEventIds.add(eventId);
                if(String.valueof(e.OwnerId).startsWith(UserKey) == false){
                    availableTechnicains.add(e.OwnerId);
                }
            }
            availableTechnicains = getEventEnablesTechnicians(availableTechnicains);

            //Setting the scheduled date time
            Set<String> wo_TL = new Set<String>();
            Set<String> tech_TL = new Set<String>();
            Map<String, DateTime> event_scheduleDate = new Map<String, DateTime>();
            Map<String, DateTime> onlyWo_scheduleDate = new Map<String, DateTime>();
            for(Event EventItm: Events)
            {

                if(EventItm.WhatId != NULL)
                    wo_TL.add(EventItm.WhatId);

                If(isSplRelatedHandling!= null &&  setApiName != null && setApiName.size()> 0 && isSplRelatedHandling == true && EventItm.WhatId != null && !setApiName.contains(String.valueOf((Id.ValueOf(EventItm.WhatId).getsobjectType()))))
                {
                    wo_TL.add(EventItm.WhatId);
                } 
                else if(EventItm.WhatId != NULL)
                {
                    if(EventItm.WhatId != NULL)
                        wo_TL.add(EventItm.WhatId);
                }
                if(EventItm.OwnerId != NULL)
                    tech_TL.add(EventItm.OwnerId);
                
                event_scheduleDate.put(EventItm.WhatId+''+EventItm.OwnerId,dcUtils.getDateTimeInTimezone(DateTime.valueof(EventItm.ActivityDateTime).dateGmt(), DateTime.valueof(EventItm.ActivityDateTime).timeGmt(), timeZone));
                onlyWo_scheduleDate.put(EventItm.WhatId,dcUtils.getDateTimeInTimezone(DateTime.valueof(EventItm.ActivityDateTime).dateGmt(), DateTime.valueof(EventItm.ActivityDateTime).timeGmt(), timeZone));
            }
            if(wo_TL.size() > 0){
                Map<String, DateTime> wo_scheduleDate = new Map<String, DateTime>();
                Map<String, DateTime> eventSF_scheduleDate = new Map<String, DateTime>();
                Map<String, DateTime> eventSVMX_scheduleDate = new Map<String, DateTime>();
                DateTime tempDatetime;

                for(Event e: [Select Id, Type, startDateTime, WhatId, OwnerId from Event where WhatId IN :wo_TL AND OwnerId IN :tech_TL])   
                {
                    if(tempDatetime == NULL && givenEventIds.contains(e.Id) == false)
                        tempDatetime = e.startDateTime;

                    if(tempDatetime != NULL && e.startDateTime <= tempDatetime && givenEventIds.contains(e.Id) == false)
                        eventSF_scheduleDate.put(e.WhatId + '' + e.OwnerId, e.startDateTime);
                }
                tempDatetime = NULL;

                for(SVMXC__SVMX_Event__c e: [Select Id, SVMXC__Type__c, SVMXC__StartDateTime__c, SVMXC__WhatId__c, SVMXC__Technician__c from SVMXC__SVMX_Event__c where SVMXC__WhatId__c IN :wo_TL AND SVMXC__Technician__c IN :tech_TL])   
                {
                    if(tempDatetime == NULL && givenEventIds != NULL && givenEventIds.contains(e.Id) == false)
                        tempDatetime = e.SVMXC__StartDateTime__c;
                    if(tempDatetime != NULL && e.SVMXC__StartDateTime__c <= tempDatetime && givenEventIds != NULL && givenEventIds.contains(e.Id) == false)
                        eventSVMX_scheduleDate.put(e.SVMXC__WhatId__c + '' + e.SVMXC__Technician__c, dcUtils.getDateTimeInTimezone(e.SVMXC__StartDateTime__c.dateGmt(),e.SVMXC__StartDateTime__c.timeGmt(),timeZone));
                }

                List<SVMXC__Service_Order__c> schWO = [Select Id,SVMXC__Last_Dispatch_Event__c, SVMXC__Service_Duration__c, SVMXC__FirstScheduledDateTime__c, SVMXC__NoOfTimesScheduled__c, SVMXC__Scheduled_Date_Time__c, SVMXC__Group_Member__c, SVMXC__Group_Member__r.SVMXC__Salesforce_User__c from SVMXC__Service_Order__c where Id IN :wo_TL];
                List<DateTime> dateTime_TL;
                Boolean isUpdatable = false;
                String woTech;
                for(SVMXC__Service_Order__c swo: schWO){

                    tempDatetime = NULL;
                    if(swo.SVMXC__Group_Member__r.SVMXC__Salesforce_User__c!=NULL){
                        woTech = swo.Id+''+swo.SVMXC__Group_Member__r.SVMXC__Salesforce_User__c;
                    }
                    else{
                        if(swo.SVMXC__Group_Member__c != NULL)
                            woTech = swo.Id+''+swo.SVMXC__Group_Member__c;
                        else{
                            swo.SVMXC__Scheduled_Date_Time__c = onlyWo_scheduleDate.get(swo.Id);                        
                            isUpdatable = true;
                            continue;
                        }
                    }

                    dateTime_TL = new List<DateTime>();
                    if(event_scheduleDate.get(woTech) != NULL)
                        dateTime_TL.add(event_scheduleDate.get(woTech));
                    if(eventSF_scheduleDate.get(woTech) != NULL)
                        dateTime_TL.add(eventSF_scheduleDate.get(woTech));
                    if(eventSVMX_scheduleDate.get(woTech) != NULL)
                        dateTime_TL.add(eventSVMX_scheduleDate.get(woTech));
                    tempDatetime = getLeastDateTime(dateTime_TL);

                    isUpdatable = true;
                    swo.SVMXC__Scheduled_Date_Time__c = onlyWo_scheduleDate.get(swo.Id);
                    swo.SVMXC__Last_Dispatch_Event__c = 'Scheduled';

                    if(mapWOIdleDuration.containsKey(swo.Id))
                    {
                        swo.SVMXC__Scheduled_Date_Time__c = swo.SVMXC__Scheduled_Date_Time__c.addMinutes(mapWOIdleDuration.get(swo.Id));
                        swo.SVMXC__Idle_Time__c = mapWOIdleDuration.get(swo.Id);
                    }
                    if(mapWODriveDuration.containsKey(swo.Id))
                    {
                        swo.SVMXC__Scheduled_Date_Time__c = swo.SVMXC__Scheduled_Date_Time__c.addMinutes(mapWODriveDuration.get(swo.Id));
                        swo.SVMXC__Driving_Time__c = mapWODriveDuration.get(swo.Id);
                    }
                    if(mapWOServiceDuration.containsKey(swo.Id))
                        swo.SVMXC__Service_Duration__c = mapWOServiceDuration.get(swo.Id);
                    if(mapWOScope.containsKey(swo.Id)) {
                        swo.SVMXC__SM_Scope_Change__c = mapWOScope.get(swo.Id);

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
                                    swo.put(mapWOSettings.get(strfld),dcUtils.getDateTimeInTimezone(DateTime.valueof(mapNewSettings.get(strfld)).dateGmt(), DateTime.valueof(mapNewSettings.get(strfld)).timeGmt(), timeZone));

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

                if(isUpdatable == true)
                {
                    system.debug('Upsert Event WOflds : '+ schWO);
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(schWO,COMM_SecurityUtils.Access.Updateable)){
                        update schWO; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                }

            }
            for(Event e: Events){
                TempEventId = e.Id;
                TempOwnerId = e.OwnerId; 
                if(TempEventId.startsWith(EventKey)){
                    if(TempOwnerId.startsWith(UserKey))
                        SFEvents.add(e);
                    else{
                        if(availableTechnicains.contains(e.OwnerId)){
                            //Salesforce event is trying to change as ServiceMax User, delete the existing Event
                            EventDelList.add(e.Id);
                            //Insert the ServiceMax event
                            SVMXC__SVMX_Event__c TempSVMXEvent = new SVMXC__SVMX_Event__c();
    
                            if(e.IsAllDayEvent)
                            {
                                TempSVMXEvent.SVMXC__StartDateTime__c = e.ActivityDate;
                                TempSVMXEvent.SVMXC__ActivityDateTime__c = e.ActivityDate;
                                TempSVMXEvent.SVMXC__ActivityDate__c = e.ActivityDate;
                                System.debug(logginglevel.warn,' If : SVMXC__StartDateTime__c '+TempSVMXEvent.SVMXC__StartDateTime__c+'SVMXC__ActivityDate__c '+TempSVMXEvent.SVMXC__ActivityDate__c);
                                //get the date , 00:00 time will be taken - sent from the client
                                TempSVMXEvent.SVMXC__EndDateTime__c = (Datetime) e.EndDateTime.dateGmt();
                            }
                            else
                            {
                                TempSVMXEvent.SVMXC__ActivityDateTime__c = dcUtils.getDateTimeInTimezone(DateTime.valueof(e.ActivityDateTime).dateGmt(), DateTime.valueof(e.ActivityDateTime).timeGmt() , timeZone);
                                TempSVMXEvent.SVMXC__StartDateTime__c = TempSVMXEvent.SVMXC__ActivityDateTime__c;
                                TempSVMXEvent.SVMXC__ActivityDate__c = TempSVMXEvent.SVMXC__ActivityDateTime__c.date();

                                System.debug(logginglevel.warn,'SVMXC__StartDateTime__c '+TempSVMXEvent.SVMXC__StartDateTime__c+'SVMXC__ActivityDate__c '+TempSVMXEvent.SVMXC__ActivityDate__c);
                                //End date will be automatically calculated based on the start datetime and the duration
                                DateTime endTime_T = DateTime.valueof(e.ActivityDateTime).addMinutes(Integer.valueof(e.DurationInMinutes));
                                TempSVMXEvent.SVMXC__EndDateTime__c = dcUtils.getDateTimeInTimezone(endTime_T.dateGmt(), endTime_T.timeGmt() , timeZone);
                            }

                            TempSVMXEvent.SVMXC__Technician__c = e.OwnerId;
                            TempSVMXEvent.SVMXC__DurationInMinutes__c = Integer.valueof(e.DurationInMinutes);
                            // This is the change due to the introduction of new fields in event objects
                            TempSVMXEvent.SVMXC__Driving_Time__c = Integer.valueof(e.SVMXC__Driving_Time__c);               
                            TempSVMXEvent.SVMXC__Overhead_Time_Before__c = Integer.valueof(e.SVMXC__Overhead_Time_Before__c);               
                            TempSVMXEvent.SVMXC__Overhead_Time_After__c = Integer.valueof(e.SVMXC__Overhead_Time_After__c);             
                            TempSVMXEvent.SVMXC__Driving_Time_Home__c = Integer.valueof(e.SVMXC__Driving_Time_Home__c);             
                            TempSVMXEvent.SVMXC__Service_Duration__c = Integer.valueof(e.SVMXC__Service_Duration__c);               
                            TempSVMXEvent.SVMXC__Break_Time_Total__c = Integer.valueof(e.SVMXC__Break_Time_Total__c);
                            TempSVMXEvent.SVMXC__IsAllDayEvent__c = e.IsAllDayEvent;
                            TempSVMXEvent.Name = e.Subject;
                            TempSVMXEvent.SVMXC__Description__c = e.Description;
                            TempSVMXEvent.SVMXC__WhatId__c = e.WhatId;
                            TempSVMXEvent.SVMXC__Location__c = e.Location;
                            TempSVMXEvent.SVMXC__StartDateTime__c = TempSVMXEvent.SVMXC__ActivityDateTime__c;

                            //Defect# 014336 - added 'SVMXC__Type__c' field
                            TempSVMXEvent.SVMXC__Type__c = e.Type;

                            //End date will be automatically calculated based on the start datetime and the duration
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
                            UpsertSVMXEventlist.add(TempSVMXEvent);
                        }
                    }
                }
                else{
                    if(TempOwnerId.startsWith(UserKey)==false){
                        SVMXEvents.add(e);
                        SVMXEventIds.add(e.Id);
                    }
                    else{
                        //ServiceMax event is trying to change as Salesforce User
                        //Delete the existing Event
                        EventDelList.add(e.Id);
                        //Insert the Salesforce event
                        Event TempSFEvent = new Event();

                        if(e.IsAllDayEvent)
                        {
                            TempSFEvent.StartDateTime = e.ActivityDate;
                            TempSFEvent.ActivityDateTime = e.ActivityDate;
                            TempSFEvent.ActivityDate = e.ActivityDate;
                            system.debug(LoggingLevel.Warn, 'StartDateTime: ' + TempSFEvent.StartDateTime + '; ActivityDate: ' + TempSFEvent.ActivityDate);
                        }
                        else
                        {
                            TempSFEvent.ActivityDateTime = dcUtils.getDateTimeInTimezone(DateTime.valueof(e.ActivityDateTime).dateGmt(), DateTime.valueof(e.ActivityDateTime).timeGmt() , timeZone);
                            TempSFEvent.StartDateTime = TempSFEvent.ActivityDateTime;
                            system.debug(LoggingLevel.Warn, 'StartDateTime: ' + TempSFEvent.StartDateTime + '; ActivityDate: ' + TempSFEvent.ActivityDate);
                        }


                        TempSFEvent.OwnerId = e.OwnerId;
                        TempSFEvent.DurationInMinutes = Integer.valueof(e.DurationInMinutes);
                        // This is the change due to the introduction of new fields in event objects
                        TempSFEvent.SVMXC__Driving_Time__c = Integer.valueof(e.SVMXC__Driving_Time__c);             
                        TempSFEvent.SVMXC__Overhead_Time_Before__c = Integer.valueof(e.SVMXC__Overhead_Time_Before__c);             
                        TempSFEvent.SVMXC__Overhead_Time_After__c = Integer.valueof(e.SVMXC__Overhead_Time_After__c);               
                        TempSFEvent.SVMXC__Driving_Time_Home__c = Integer.valueof(e.SVMXC__Driving_Time_Home__c);               
                        TempSFEvent.SVMXC__Service_Duration__c = Integer.valueof(e.SVMXC__Service_Duration__c);             
                        TempSFEvent.SVMXC__Break_Time_Total__c = Integer.valueof(e.SVMXC__Break_Time_Total__c); 
                        TempSFEvent.IsAllDayEvent = e.IsAllDayEvent; 

                        TempSFEvent.Subject = e.Subject;
                        TempSFEvent.Description = e.Description;
                        TempSFEvent.IsAllDayEvent = e.IsAllDayEvent;
                        TempSFEvent.WhatId = e.WhatId;
                        TempSFEvent.Location = e.Location;
                        TempSFEvent.StartDateTime = TempSFEvent.ActivityDateTime;
                        //Defect# 014336 - added 'Type' field
                        TempSFEvent.Type = e.Type;

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
                        system.debug(LoggingLevel.Warn, 'StartDateTime: ' + TempSFEvent.StartDateTime + '; ActivityDate: ' + TempSFEvent.ActivityDate);
                        UpsertSFEventlist.add(TempSFEvent);
                    }
                }
            }

            if(SVMXEventIds.size()>0){
                for(SVMXC__SVMX_Event__c SVMXe: [Select Id, SVMXC__ActivityDate__c, SVMXC__ActivityDateTime__c, SVMXC__Technician__c, SVMXC__DurationInMinutes__c, Name,SVMXC__Description__c, SVMXC__WhatId__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c from SVMXC__SVMX_Event__c where Id IN :SVMXEventIds]){  
                    SVMXEventMap.put(SVMXe.Id, SVMXe);
                }
            }
            //Apurva:  Defect - 033903 
            if(SFEventIds.size()>0)
            {
                SFEventMap = new map<string,Event>([Select Id, ActivityDate, IsAllDayEvent, ActivityDateTime, OwnerId, DurationInMinutes, Subject,Description, WhatId, StartDateTime from Event Where Id IN :SFEventIds]);
            }
            //Salesforce Events
            for(Event e: SFEvents){
                Event TempSFEvent = new Event();
                //Apurva:  Defect - 033903 
                if(e.Id  != NULL && SFEventMap.containskey(e.Id) && SFEventMap.get(e.Id)!=NULL){
                    
                    system.debug(LoggingLevel.Warn, 'TempSFEvent: ' +TempSFEvent);
                    system.debug(LoggingLevel.Warn, 'ActivityDateTime: ' + e.ActivityDateTime + '; ActivityDate: ' + e.ActivityDate+'  Event Id  '+ e.id);
                    
                    TempSFEvent = SFEventMap.get(e.Id);         
                    //Moved this outside the for loop
                    
                    //TempSFEvent = [Select Id, ActivityDate, IsAllDayEvent, ActivityDateTime, OwnerId, DurationInMinutes, Subject,Description, WhatId, StartDateTime from Event Where Id = :e.Id];
                    //TempSFEvent = e;
                    system.debug(LoggingLevel.Warn, 'TempSFEvent: ' +TempSFEvent);
                    if(e.IsAllDayEvent)
                    {
                        TempSFEvent.StartDateTime = e.ActivityDate;
                        TempSFEvent.ActivityDateTime = e.ActivityDate;
                        TempSFEvent.ActivityDate = e.ActivityDate;
                        system.debug(LoggingLevel.Warn, 'StartDateTime: ' + TempSFEvent.StartDateTime + '; ActivityDate: ' + TempSFEvent.ActivityDate);
                    }
                    else
                    {
                        TempSFEvent.ActivityDateTime = dcUtils.getDateTimeInTimezone(DateTime.valueof(e.ActivityDateTime).dateGmt(), DateTime.valueof(e.ActivityDateTime).timeGmt() , timeZone);
                        TempSFEvent.StartDateTime = TempSFEvent.ActivityDateTime;
                        system.debug(LoggingLevel.Warn, 'StartDateTime: ' + TempSFEvent.StartDateTime + '; ActivityDate: ' + TempSFEvent.ActivityDate);
                    }


                    TempSFEvent.OwnerId = e.OwnerId;
                    TempSFEvent.DurationInMinutes = Integer.valueof(e.DurationInMinutes);
                    // This is the change due to the introduction of new fields in event objects
                    TempSFEvent.SVMXC__Driving_Time__c = Integer.valueof(e.SVMXC__Driving_Time__c);             
                    TempSFEvent.SVMXC__Overhead_Time_Before__c = Integer.valueof(e.SVMXC__Overhead_Time_Before__c);             
                    TempSFEvent.SVMXC__Overhead_Time_After__c = Integer.valueof(e.SVMXC__Overhead_Time_After__c);               
                    TempSFEvent.SVMXC__Driving_Time_Home__c = Integer.valueof(e.SVMXC__Driving_Time_Home__c);               
                    TempSFEvent.SVMXC__Service_Duration__c = Integer.valueof(e.SVMXC__Service_Duration__c);             
                    TempSFEvent.SVMXC__Break_Time_Total__c = Integer.valueof(e.SVMXC__Break_Time_Total__c); 
                    TempSFEvent.IsAllDayEvent = e.IsAllDayEvent; 
                    TempSFEvent.Subject = e.Subject;
                    TempSFEvent.Description = e.Description;
                    TempSFEvent.IsAllDayEvent = e.IsAllDayEvent;
                    TempSFEvent.WhatId = e.WhatId;
                    TempSFEvent.Location = e.Location;
                    TempSFEvent.Type = e.Type;

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
                    UpsertSFEventlist.add(TempSFEvent);
                }
            }
            //ServiceMax Events
            for(Event e: SVMXEvents){
                SVMXC__SVMX_Event__c TempSVMXEvent = new SVMXC__SVMX_Event__c();
                if(SVMXEventMap.get(e.Id)!=NULL){
                    TempSVMXEvent = SVMXEventMap.get(e.Id);

                    if(e.IsAllDayEvent)
                    {
                        TempSVMXEvent.SVMXC__StartDateTime__c = e.ActivityDate;
                        TempSVMXEvent.SVMXC__ActivityDateTime__c = e.ActivityDate;
                        TempSVMXEvent.SVMXC__ActivityDate__c = e.ActivityDate;
                        System.debug(logginglevel.warn,' If : SVMXC__StartDateTime__c '+TempSVMXEvent.SVMXC__StartDateTime__c+'SVMXC__ActivityDate__c '+TempSVMXEvent.SVMXC__ActivityDate__c);
                        //get the date , 00:00 time will be taken - sent from the client
                        TempSVMXEvent.SVMXC__EndDateTime__c = (Datetime) e.EndDateTime.dateGmt();
                    }
                    else
                    {
                        TempSVMXEvent.SVMXC__ActivityDateTime__c = dcUtils.getDateTimeInTimezone(DateTime.valueof(e.ActivityDateTime).dateGmt(), DateTime.valueof(e.ActivityDateTime).timeGmt() , timeZone);
                        TempSVMXEvent.SVMXC__StartDateTime__c = TempSVMXEvent.SVMXC__ActivityDateTime__c;
                        TempSVMXEvent.SVMXC__ActivityDate__c = TempSVMXEvent.SVMXC__ActivityDateTime__c.date();

                        System.debug(logginglevel.warn,'SVMXC__StartDateTime__c '+TempSVMXEvent.SVMXC__StartDateTime__c+'SVMXC__ActivityDate__c '+TempSVMXEvent.SVMXC__ActivityDate__c);
                        //End date will be automatically calculated based on the start datetime and the duration
                        DateTime endDate_T= DateTime.valueof(e.ActivityDateTime).addMinutes(Integer.valueof(e.DurationInMinutes));
                        TempSVMXEvent.SVMXC__EndDateTime__c = dcUtils.getDateTimeInTimezone(endDate_T.dateGmt(), endDate_T.timeGmt() , timeZone);
                    }

                    TempSVMXEvent.SVMXC__Technician__c = e.OwnerId;
                    TempSVMXEvent.SVMXC__DurationInMinutes__c = Integer.valueof(e.DurationInMinutes);
                    // This is the change due to the introduction of new fields in event objects
                    TempSVMXEvent.SVMXC__Driving_Time__c = Integer.valueof(e.SVMXC__Driving_Time__c);               
                    TempSVMXEvent.SVMXC__Overhead_Time_Before__c = Integer.valueof(e.SVMXC__Overhead_Time_Before__c);               
                    TempSVMXEvent.SVMXC__Overhead_Time_After__c = Integer.valueof(e.SVMXC__Overhead_Time_After__c);             
                    TempSVMXEvent.SVMXC__Driving_Time_Home__c = Integer.valueof(e.SVMXC__Driving_Time_Home__c);             
                    TempSVMXEvent.SVMXC__Service_Duration__c = Integer.valueof(e.SVMXC__Service_Duration__c);               
                    TempSVMXEvent.SVMXC__Break_Time_Total__c = Integer.valueof(e.SVMXC__Break_Time_Total__c);
                    TempSVMXEvent.SVMXC__IsAllDayEvent__c = e.IsAllDayEvent;
                    TempSVMXEvent.Name = e.Subject;
                    TempSVMXEvent.SVMXC__Description__c = e.Description;

                    TempSVMXEvent.SVMXC__WhatId__c = e.WhatId;
                    TempSVMXEvent.SVMXC__Location__c = e.Location;
                    //Defect# 014336 - added 'SVMXC__Type__c' field
                    TempSVMXEvent.SVMXC__Type__c = e.Type;

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
                    UpsertSVMXEventlist.add(TempSVMXEvent);
                }
            }

            //If some conflicting events are there is there to delete
            if(EventDelList.size()>0)DCON_Event_WS.DCON_Delete_Events_WS(UserId, EventDelList);
            //If events are there to upsert
            system.debug('Upsert Event SFflds : '+ UpsertSFEventlist);
            system.debug('Upsert Event SVMXflds : '+ UpsertSVMXEventlist);
            if(UpsertSFEventlist.size() > 0 ) {
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(UpsertSFEventlist,COMM_SecurityUtils.Access.Upsertable)){
                    upsert UpsertSFEventlist; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
            if(UpsertSVMXEventlist.size() > 0 ) {
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(UpsertSVMXEventlist,COMM_SecurityUtils.Access.Upsertable)){
                    upsert UpsertSVMXEventlist; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
            StatusMessage = 'TAG174';
        }
        catch(DmlException ex)
        {
            Database.rollback(sp);
            system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new SVMXException(ex.getDmlMessage(0));
        }
        catch(Exception ex)
        {
            system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
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
        if(EventDelList.size()>0)
        {
            StatusMessage += ','+EventDelList.get(0)+',';
            if(UpsertSFEventlist.size() > 0 )
                StatusMessage += UpsertSFEventlist.get(0).id;
            else if(UpsertSVMXEventlist.size() > 0 )
                StatusMessage += UpsertSVMXEventlist.get(0).id; 
        }
        system.debug(LoggingLevel.WARN, 'StatusMessage:  '+StatusMessage);
        return StatusMessage;
    }
    
    WebService static String DCON_Upsert_Events_WS2(String UserId, String timeZone, List<Event> Events, list<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue){
        return null;
    }

    WebService static list<String> DCON_Upsert_Events_WS4(String UserId, List<Event> Events, String timeZone, list<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue)
    {
        SVMXC.COMM_Utils_ManageTags comTagUtils = new SVMXC.COMM_Utils_ManageTags();
        Map<String, String> mapSVMXTags = comTagUtils.SVMX_getTagList('DCON001');
        String StatusMessage;
        List<Event> SFEvents = new  List<Event>();
        List<Event> lstEventstoCreate = new  List<Event>();
        List<Event> SVMXEvents = new  List<Event>();
        List<String> EventDelList = new  List<String>();
        List<SVMXC__SVMX_Event__c> TempSVMXEventList = new List<SVMXC__SVMX_Event__c>();
        List<Event> UpsertSFEventlist = new List<Event>();
        List<SVMXC__SVMX_Event__c> UpsertSVMXEventlist = new List<SVMXC__SVMX_Event__c>();
        set<String> SVMXEventIds = new set<String>();
        set<String> SFEventIds = new set<String>();
        set<String> givenEventIds = new set<String>();
        Map<Id, integer> mapWOIdleDuration = new Map<Id, integer>();
        Map<Id, integer> mapWODriveDuration = new Map<Id, integer>();
        Map<Id, integer> mapWOServiceDuration = new Map<Id, integer>();
        Map<String, String> mapWOSettings = new Map<String, String>();
        Map<String, String> mapEventSettings = new Map<String, String>();
        Map<String, String> mapNewSettings = new Map<String, String>();
        Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        List<String> lstEventId = new List<String>();
        Schema.Describesobjectresult discWorkOrder;        
        system.debug(loggingLevel.warn,'REQUEST: ' + timeZone + Events);
        
        if (allObjs.containsKey('SVMXC__Service_Order__c') == true)
            discWorkOrder = allObjs.get('SVMXC__Service_Order__c').getDescribe();
        else
            discWorkOrder = allObjs.get('Service_Order__c').getDescribe();

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
        souObjfieldMapEVT.clear();
        souObjfieldMapSVMXEVT.clear();
        String eventExistErrorMessage = mapSVMXTags.get('TAG238');
        Map<String,String> settingvalues = getEvtandWofields();
        system.debug('Upsert Event settingvalues : '+ settingvalues);
        
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
                    }
                    else
                    {
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

        Map<String, SVMXC__SVMX_Event__c> SVMXEventMap = new Map<String, SVMXC__SVMX_Event__c>();
        Map<String, Event> SFEventMap = new Map<String, Event>();
       
        Savepoint sp = Database.setSavepoint();

        if(Events.size()==0)
            throw new SVMXException('Please provide some events to insert');
        Boolean isError = false;
        Boolean isEventExist = false;
        String errMessage;
        boolean supportNonWorkOrdEvent = true;

        try
        {
            //Check for User TimeZone
            if(timeZone == NULL || timeZone == '')
            {
                if(!Userinfo.getUserId().contains(UserId))
                    timeZone = [SELECT TimeZoneSidKey from User where Id = :UserId].TimeZoneSidKey;
                else
                    timeZone = Userinfo.getTimeZone().getID();
            }

            Schema.Describesobjectresult objEvent = allObjs.get('Event').getDescribe();
            String EventKey = objEvent.getKeyPrefix();
            Schema.Describesobjectresult objUser = allObjs.get('User').getDescribe();
            allObjs.clear();
            String UserKey = objUser.getKeyPrefix();
            String TempEventId;
            String TempOwnerId;

            set<String> availableTechnicains = new set<String>();

            // Get setting value to support Non-Work Order event
            if(svmxSettingList != NULL && svmxSettingList.containsKey('SET062') && svmxSettingList.get('SET062') != NULL)
                supportNonWorkOrdEvent = boolean.valueOf(svmxSettingList.get('SET062'));

            // Get the original WhatId of all event except Work Order and update the list of SF Event
            if(supportNonWorkOrdEvent)
            {
                set<string> setEventIDs = new set<string>();
                map<string,Event> mapSFEvent = new map<string,Event>();
                map<string,SVMXC__SVMX_Event__c> mapSVMXEvent = new map<string,SVMXC__SVMX_Event__c>();

                for(Event e : Events)
                {
                    if(e.Id != NULL && e.WhatId == NULL)
                        setEventIDs.add(e.Id);
                }

                if(setEventIDs.size() > 0)
                {
                    mapSFEvent.putAll([Select Id, WhatId from Event where Id IN: setEventIDs AND WhatId != NULL]);
                    mapSVMXEvent.putAll([Select Id, SVMXC__WhatId__c from SVMXC__SVMX_Event__c where Id IN: setEventIDs AND SVMXC__WhatId__c != NULL]);
                }

                for(Event e : Events)
                {
                    if(mapSFEvent.containsKey(e.Id) && mapSFEvent.get(e.Id).WhatId != NULL)
                        e.WhatId = mapSFEvent.get(e.Id).WhatId;
                    else if(mapSVMXEvent.containsKey(e.Id) && mapSVMXEvent.get(e.Id).SVMXC__WhatId__c != NULL)
                        e.WhatId = mapSVMXEvent.get(e.Id).SVMXC__WhatId__c;
                }
                mapSFEvent.clear();
                mapSVMXEvent.clear();
                setEventIDs.clear();
            }

            list<event> lstEventUpdated = new list<event>();
            //Check for Technicians with SVMXC__Enable_Scheduling__c = true
            for(Event e: Events)
            {
                Event oEvent = e;
                string eventId;
                eventId = e.id;
                System.debug('eventId: '+eventId);
                if(eventId != null && eventId != '' && eventId != 'null')
                {
                    lstEventUpdated.add(e);
                    //Apurva:  Defect - 033903 
                    SFEventIds.add(eventId);
                }
                DateTime eventStartTime = dcUtils.getDateTimeInTimezone(DateTime.valueof(oEvent.ActivityDateTime).dateGmt(), DateTime.valueof(oEvent.ActivityDateTime).timeGmt(), timeZone);
                DateTime eventEndTime = DateTime.valueof(eventStartTime).addMinutes(Integer.valueof(oEvent.DurationInMinutes));

                givenEventIds.add(e.Id);
                if(String.valueof(e.OwnerId).startsWith(UserKey) == false){
                    availableTechnicains.add(e.OwnerId);
                }
            }

            //Check Double Booking if setting is enabled 
            system.debug('lstEventUpdated: '+lstEventUpdated);
            if(svmxSettingList != NULL && svmxSettingList.containskey('SET027') && svmxSettingList.get('SET027').toUpperCase()=='DISALLOW')
            {
                if(lstEventUpdated.size()>0)
                    DCON_DoubleBooking.checkDoublebookingforTech(lstEventUpdated,timeZone,UserKey);
            }
            system.debug('Before getEventEnablesTechnicians');
            availableTechnicains = getEventEnablesTechnicians(availableTechnicains);
            system.debug('After getEventEnablesTechnicians');
            //Setting the scheduled date time
            Set<String> wo_TL = new Set<String>();
            Set<String> tech_TL = new Set<String>();
            Map<String, DateTime> event_scheduleDate = new Map<String, DateTime>();
            Map<String, DateTime> onlyWo_scheduleDate = new Map<String, DateTime>();
            for(Event EventItm: Events){
                //Make the list of new Events here, to judge when to enable WO triggers execution
                if(EventItm.id == null)
                    lstEventstoCreate.add(EventItm);

                if(EventItm.WhatId != NULL)
                    wo_TL.add(EventItm.WhatId);
                if(EventItm.OwnerId != NULL)
                    tech_TL.add(EventItm.OwnerId);
                event_scheduleDate.put(EventItm.WhatId+''+EventItm.OwnerId,dcUtils.getDateTimeInTimezone(DateTime.valueof(EventItm.ActivityDateTime).dateGmt(), DateTime.valueof(EventItm.ActivityDateTime).timeGmt(), timeZone));
                onlyWo_scheduleDate.put(EventItm.WhatId,dcUtils.getDateTimeInTimezone(DateTime.valueof(EventItm.ActivityDateTime).dateGmt(), DateTime.valueof(EventItm.ActivityDateTime).timeGmt(), timeZone));
            }
            if(wo_TL.size() > 0){
                Map<String, DateTime> wo_scheduleDate = new Map<String, DateTime>();
                Map<String, DateTime> eventSF_scheduleDate = new Map<String, DateTime>();
                Map<String, DateTime> eventSVMX_scheduleDate = new Map<String, DateTime>();
                DateTime tempDatetime;

                for(Event e: [Select Id, startDateTime, WhatId, OwnerId from Event where WhatId IN :wo_TL AND OwnerId IN :tech_TL]) 
                {
                    if(tempDatetime == NULL && givenEventIds.contains(e.Id) == false)
                        tempDatetime = e.startDateTime;

                    if(tempDatetime != NULL && e.startDateTime <= tempDatetime && givenEventIds.contains(e.Id) == false)
                        eventSF_scheduleDate.put(e.WhatId + '' + e.OwnerId, e.startDateTime);
                }

                tempDatetime = NULL;

                for(SVMXC__SVMX_Event__c e: [Select Id, SVMXC__StartDateTime__c, SVMXC__WhatId__c, SVMXC__Technician__c from SVMXC__SVMX_Event__c where SVMXC__WhatId__c IN :wo_TL AND SVMXC__Technician__c IN :tech_TL]) 
                {
                    if(tempDatetime == NULL && givenEventIds != NULL && givenEventIds.contains(e.Id) == false)
                        tempDatetime = e.SVMXC__StartDateTime__c;
                    if(tempDatetime != NULL && e.SVMXC__StartDateTime__c <= tempDatetime && givenEventIds != NULL && givenEventIds.contains(e.Id) == false)
                        eventSVMX_scheduleDate.put(e.SVMXC__WhatId__c + '' + e.SVMXC__Technician__c, dcUtils.getDateTimeInTimezone(e.SVMXC__StartDateTime__c.dateGmt(),e.SVMXC__StartDateTime__c.timeGmt(),timeZone));
                }

                List<SVMXC__Service_Order__c> schWO = [Select Id,SVMXC__Last_Dispatch_Event__c, SVMXC__Service_Duration__c, SVMXC__FirstScheduledDateTime__c, SVMXC__NoOfTimesScheduled__c, SVMXC__Scheduled_Date_Time__c, SVMXC__Group_Member__c, SVMXC__Group_Member__r.SVMXC__Salesforce_User__c from SVMXC__Service_Order__c where Id IN :wo_TL];
                List<DateTime> dateTime_TL;
                Boolean isUpdatable = false;
                String woTech;
                
                for(SVMXC__Service_Order__c swo: schWO){

                    tempDatetime = NULL;
                    if(swo.SVMXC__Group_Member__r.SVMXC__Salesforce_User__c!=NULL){
                        woTech = swo.Id+''+swo.SVMXC__Group_Member__r.SVMXC__Salesforce_User__c;
                    }
                    else{
                        if(swo.SVMXC__Group_Member__c != NULL)
                            woTech = swo.Id+''+swo.SVMXC__Group_Member__c;
                        else{
                            swo.SVMXC__Scheduled_Date_Time__c = onlyWo_scheduleDate.get(swo.Id);                        
                            isUpdatable = true;
                            continue;
                        }
                    }

                    dateTime_TL = new List<DateTime>();
                    if(event_scheduleDate.get(woTech) != NULL)
                        dateTime_TL.add(event_scheduleDate.get(woTech));
                    if(eventSF_scheduleDate.get(woTech) != NULL)
                        dateTime_TL.add(eventSF_scheduleDate.get(woTech));
                    if(eventSVMX_scheduleDate.get(woTech) != NULL)
                        dateTime_TL.add(eventSVMX_scheduleDate.get(woTech));
                    tempDatetime = getLeastDateTime(dateTime_TL);

                    isUpdatable = true;
                    swo.SVMXC__Scheduled_Date_Time__c = onlyWo_scheduleDate.get(swo.Id);
                    swo.SVMXC__Last_Dispatch_Event__c = 'Scheduled';

                    if(mapWOIdleDuration.containsKey(swo.Id))
                    {
                        swo.SVMXC__Scheduled_Date_Time__c = swo.SVMXC__Scheduled_Date_Time__c.addMinutes(mapWOIdleDuration.get(swo.Id));
                        swo.SVMXC__Idle_Time__c = mapWOIdleDuration.get(swo.Id);
                    }
                    if(mapWODriveDuration.containsKey(swo.Id))
                    {
                        swo.SVMXC__Scheduled_Date_Time__c = swo.SVMXC__Scheduled_Date_Time__c.addMinutes(mapWODriveDuration.get(swo.Id));
                        swo.SVMXC__Driving_Time__c = mapWODriveDuration.get(swo.Id);
                    }
                    if(mapWOServiceDuration.containsKey(swo.Id)) {
                        swo.SVMXC__Service_Duration__c = mapWOServiceDuration.get(swo.Id);
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
                                    swo.put(mapWOSettings.get(strfld),dcUtils.getDateTimeInTimezone(DateTime.valueof(mapNewSettings.get(strfld)).dateGmt(), DateTime.valueof(mapNewSettings.get(strfld)).timeGmt(), timeZone));
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

                if(isUpdatable == true)
                {
                    system.debug('Upsert Event WOflds : '+ schWO);
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(schWO,COMM_SecurityUtils.Access.Updateable)){
                        update schWO; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                }
            }
            for(Event e: Events)
            {
                TempEventId = e.Id;
                TempOwnerId = e.OwnerId;
                if(TempEventId == null)
                    continue;
                
                else if(TempEventId.startsWith(EventKey))
                {
                    if(TempOwnerId.startsWith(UserKey))
                        SFEvents.add(e);
                    else
                    {
                        if(availableTechnicains.contains(e.OwnerId))
                        {
                            //Salesforce event is trying to change as ServiceMax User
                            //Delete the existing Event
                            EventDelList.add(e.Id);
                            //Insert the ServiceMax event
                            SVMXC__SVMX_Event__c TempSVMXEvent = new SVMXC__SVMX_Event__c();
                            TempSVMXEvent.SVMXC__ActivityDateTime__c = dcUtils.getDateTimeInTimezone(DateTime.valueof(e.ActivityDateTime).dateGmt(), DateTime.valueof(e.ActivityDateTime).timeGmt() , timeZone);
                            TempSVMXEvent.SVMXC__ActivityDate__c = TempSVMXEvent.SVMXC__ActivityDateTime__c.date();
                            TempSVMXEvent.SVMXC__Technician__c = e.OwnerId;
                            TempSVMXEvent.SVMXC__DurationInMinutes__c = Integer.valueof(e.DurationInMinutes);
                            // This is the change due to the introduction of new fields in event objects
                            TempSVMXEvent.SVMXC__Driving_Time__c = Integer.valueof(e.SVMXC__Driving_Time__c);               
                            TempSVMXEvent.SVMXC__Overhead_Time_Before__c = Integer.valueof(e.SVMXC__Overhead_Time_Before__c);               
                            TempSVMXEvent.SVMXC__Overhead_Time_After__c = Integer.valueof(e.SVMXC__Overhead_Time_After__c);             
                            TempSVMXEvent.SVMXC__Driving_Time_Home__c = Integer.valueof(e.SVMXC__Driving_Time_Home__c);             
                            TempSVMXEvent.SVMXC__Service_Duration__c = Integer.valueof(e.SVMXC__Service_Duration__c);               
                            TempSVMXEvent.SVMXC__Break_Time_Total__c = Integer.valueof(e.SVMXC__Break_Time_Total__c);   
                            TempSVMXEvent.SVMXC__IsAllDayEvent__c = e.IsAllDayEvent;
                            TempSVMXEvent.Name = e.Subject;
                            TempSVMXEvent.SVMXC__Description__c = e.Description;
                            TempSVMXEvent.SVMXC__WhatId__c = e.WhatId;
                            TempSVMXEvent.SVMXC__Location__c = e.Location;
                            TempSVMXEvent.SVMXC__StartDateTime__c = TempSVMXEvent.SVMXC__ActivityDateTime__c;
                            //End date will be automatically calculated based on the start datetime and the duration
                            DateTime endTime_T = DateTime.valueof(e.ActivityDateTime).addMinutes(Integer.valueof(e.DurationInMinutes));
                            TempSVMXEvent.SVMXC__EndDateTime__c = dcUtils.getDateTimeInTimezone(endTime_T.dateGmt(), endTime_T.timeGmt() , timeZone);

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
                            UpsertSVMXEventlist.add(TempSVMXEvent);
                        }
                    }
                }
                else
                {
                    if(TempOwnerId.startsWith(UserKey)==false)
                    {
                        SVMXEvents.add(e);
                        SVMXEventIds.add(e.Id);
                    }
                    else
                    {
                        //ServiceMax event is trying to change as Salesforce User
                        //Delete the existing Event
                        EventDelList.add(e.Id);
                        //Insert the Salesforce event
                        Event TempSFEvent = new Event();
                        TempSFEvent.ActivityDateTime = dcUtils.getDateTimeInTimezone(DateTime.valueof(e.ActivityDateTime).dateGmt(), DateTime.valueof(e.ActivityDateTime).timeGmt() , timeZone);
                        TempSFEvent.ActivityDate = DateTime.valueof(TempSFEvent.ActivityDateTime).date();
                        TempSFEvent.OwnerId = e.OwnerId;
                        TempSFEvent.DurationInMinutes = Integer.valueof(e.DurationInMinutes);
                        // This is the change due to the introduction of new fields in event objects
                        TempSFEvent.SVMXC__Driving_Time__c = Integer.valueof(e.SVMXC__Driving_Time__c);             
                        TempSFEvent.SVMXC__Overhead_Time_Before__c = Integer.valueof(e.SVMXC__Overhead_Time_Before__c);             
                        TempSFEvent.SVMXC__Overhead_Time_After__c = Integer.valueof(e.SVMXC__Overhead_Time_After__c);               
                        TempSFEvent.SVMXC__Driving_Time_Home__c = Integer.valueof(e.SVMXC__Driving_Time_Home__c);               
                        TempSFEvent.SVMXC__Service_Duration__c = Integer.valueof(e.SVMXC__Service_Duration__c);             
                        TempSFEvent.SVMXC__Break_Time_Total__c = Integer.valueof(e.SVMXC__Break_Time_Total__c); 
                        TempSFEvent.IsAllDayEvent = e.IsAllDayEvent; 
                        TempSFEvent.Subject = e.Subject;
                        TempSFEvent.Description = e.Description;
                        TempSFEvent.WhatId = e.WhatId;
                        TempSFEvent.Location = e.Location;
                        TempSFEvent.StartDateTime = TempSFEvent.ActivityDateTime;

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
                        UpsertSFEventlist.add(TempSFEvent);
                    }
                }
            }

            if(SVMXEventIds.size()>0){
                for(SVMXC__SVMX_Event__c SVMXe: [Select Id, SVMXC__ActivityDate__c, SVMXC__ActivityDateTime__c, SVMXC__Technician__c, SVMXC__DurationInMinutes__c, Name,SVMXC__Description__c, SVMXC__WhatId__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c from SVMXC__SVMX_Event__c where Id IN :SVMXEventIds]){  
                    SVMXEventMap.put(SVMXe.Id, SVMXe);
                }
            }
            //Apurva:  Defect - 033903 
            if(SFEventIds.size()>0)
            {
                SFEventMap = new map<string,Event>([Select Id, ActivityDate, IsAllDayEvent, ActivityDateTime, OwnerId, DurationInMinutes, Subject,Description, WhatId, StartDateTime from Event Where Id IN :SFEventIds]);
            }
            //Salesforce Events
            for(Event e: SFEvents)
            {
                
                Event TempSFEvent = new Event();
                //Apurva:  Defect - 033903 
                if(e.Id  != NULL && SFEventMap.containskey(e.Id) && SFEventMap.get(e.Id)!=NULL){
                    
                    system.debug(LoggingLevel.Warn, 'TempSFEvent: ' +TempSFEvent);
                    system.debug(LoggingLevel.Warn, 'ActivityDateTime: ' + e.ActivityDateTime + '; ActivityDate: ' + e.ActivityDate+'  Event Id  '+ e.id);
                    //TempSFEvent = [Select Id, ActivityDate, IsAllDayEvent, ActivityDateTime, OwnerId, DurationInMinutes, Subject,Description, WhatId, StartDateTime from Event Where Id = :e.Id];
                    TempSFEvent = SFEventMap.get(e.Id);
                    system.debug('After query');
                    //'e' containts the latest state ( to be changed)
                    // Therefore AllDay state sent by client will be honoured
                    if(e.IsAllDayEvent)
                    {
                        TempSFEvent.StartDateTime = e.ActivityDate;
                        TempSFEvent.ActivityDateTime = e.ActivityDate;
                        TempSFEvent.ActivityDate = e.ActivityDate;
                    }
                    else
                    {
                        TempSFEvent.ActivityDateTime = dcUtils.getDateTimeInTimezone(DateTime.valueof(e.ActivityDateTime).dateGmt(), DateTime.valueof(e.ActivityDateTime).timeGmt() , timeZone);
                        TempSFEvent.StartDateTime = TempSFEvent.ActivityDateTime;
                    }
                    system.debug(LoggingLevel.Warn, 'ActivityDateTime: ' + TempSFEvent.ActivityDateTime + '; ActivityDate: ' + TempSFEvent.ActivityDate);

                    TempSFEvent.OwnerId = e.OwnerId;
                    TempSFEvent.DurationInMinutes = Integer.valueof(e.DurationInMinutes);
                    // This is the change due to the introduction of new fields in event objects
                    TempSFEvent.SVMXC__Driving_Time__c = Integer.valueof(e.SVMXC__Driving_Time__c);             
                    TempSFEvent.SVMXC__Overhead_Time_Before__c = Integer.valueof(e.SVMXC__Overhead_Time_Before__c);             
                    TempSFEvent.SVMXC__Overhead_Time_After__c = Integer.valueof(e.SVMXC__Overhead_Time_After__c);               
                    TempSFEvent.SVMXC__Driving_Time_Home__c = Integer.valueof(e.SVMXC__Driving_Time_Home__c);               
                    TempSFEvent.SVMXC__Service_Duration__c = Integer.valueof(e.SVMXC__Service_Duration__c);             
                    TempSFEvent.SVMXC__Break_Time_Total__c = Integer.valueof(e.SVMXC__Break_Time_Total__c); 
                    TempSFEvent.IsAllDayEvent = e.IsAllDayEvent;
                    TempSFEvent.Subject = e.Subject;
                    TempSFEvent.Description = e.Description;
                    TempSFEvent.WhatId = e.WhatId;
                    TempSFEvent.Location = e.Location;
                    TempSFEvent.StartDateTime = TempSFEvent.ActivityDateTime;

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
                    UpsertSFEventlist.add(TempSFEvent);
                }
            }
            //ServiceMax Events
            for(Event e: SVMXEvents){
                SVMXC__SVMX_Event__c TempSVMXEvent = new SVMXC__SVMX_Event__c();
                if(SVMXEventMap.get(e.Id)!=NULL){
                    TempSVMXEvent = SVMXEventMap.get(e.Id);
                    //'e' containts the latest state ( to be changed)
                    // Therefore AllDay state sent by client will be honoured
                    if(e.IsAllDayEvent)
                    {
                        TempSVMXEvent.SVMXC__StartDateTime__c = e.ActivityDate;
                        TempSVMXEvent.SVMXC__ActivityDateTime__c = e.ActivityDate;
                        TempSVMXEvent.SVMXC__ActivityDate__c = e.ActivityDate;
                        //get the date , 00:00 time will be taken - sent from the client
                        TempSVMXEvent.SVMXC__EndDateTime__c = (Datetime) e.EndDateTime.dateGmt();
                    }
                    else
                    {
                        TempSVMXEvent.SVMXC__ActivityDateTime__c = dcUtils.getDateTimeInTimezone(DateTime.valueof(e.ActivityDateTime).dateGmt(), DateTime.valueof(e.ActivityDateTime).timeGmt() , timeZone);
                        TempSVMXEvent.SVMXC__StartDateTime__c = TempSVMXEvent.SVMXC__ActivityDateTime__c;
                        //End date will be automatically calculated based on the start datetime and the duration
                        DateTime endDate_T= DateTime.valueof(e.ActivityDateTime).addMinutes(Integer.valueof(e.DurationInMinutes));
                        TempSVMXEvent.SVMXC__EndDateTime__c = dcUtils.getDateTimeInTimezone(endDate_T.dateGmt(), endDate_T.timeGmt() , timeZone);

                    }
                    TempSVMXEvent.SVMXC__ActivityDate__c = TempSVMXEvent.SVMXC__ActivityDateTime__c.date();
                    TempSVMXEvent.SVMXC__Technician__c = e.OwnerId;
                    TempSVMXEvent.SVMXC__DurationInMinutes__c = Integer.valueof(e.DurationInMinutes);
                    // This is the change due to the introduction of new fields in event objects
                    // To make the event management smooth
                    TempSVMXEvent.SVMXC__Driving_Time__c = Integer.valueof(e.SVMXC__Driving_Time__c);               
                    TempSVMXEvent.SVMXC__Overhead_Time_Before__c = Integer.valueof(e.SVMXC__Overhead_Time_Before__c);               
                    TempSVMXEvent.SVMXC__Overhead_Time_After__c = Integer.valueof(e.SVMXC__Overhead_Time_After__c);             
                    TempSVMXEvent.SVMXC__Driving_Time_Home__c = Integer.valueof(e.SVMXC__Driving_Time_Home__c); 
                    System.debug(logginglevel.warn,'Service Duration'+e.SVMXC__Service_Duration__c);
                    TempSVMXEvent.SVMXC__Service_Duration__c = Integer.valueof(e.SVMXC__Service_Duration__c);               
                    TempSVMXEvent.SVMXC__Break_Time_Total__c = Integer.valueof(e.SVMXC__Break_Time_Total__c);   
                    TempSVMXEvent.SVMXC__IsAllDayEvent__c = e.IsAllDayEvent;
                    TempSVMXEvent.Name = e.Subject;
                    TempSVMXEvent.SVMXC__Description__c = e.Description;
                    TempSVMXEvent.SVMXC__WhatId__c = e.WhatId;
                    TempSVMXEvent.SVMXC__Location__c = e.Location;

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
                    UpsertSVMXEventlist.add(TempSVMXEvent);
                }
            }

            //If some conflicting events are there is there to delete
            if(EventDelList.size()>0)DCON_Event_WS.DCON_Delete_Events_WS(UserId, EventDelList);
            //If events are there to upsert
            system.debug('Upsert Event SFflds : '+ UpsertSFEventlist);
            system.debug('Upsert Event SVMXflds : '+ UpsertSVMXEventlist);
            //Defect fixed : BAC-4621 : Condition was wrong
            if(UpsertSFEventlist.size() > 0 ) {
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(UpsertSFEventlist,COMM_SecurityUtils.Access.Upsertable)){
                    upsert UpsertSFEventlist; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
            if(UpsertSVMXEventlist.size() > 0 ) {
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(UpsertSVMXEventlist,COMM_SecurityUtils.Access.Upsertable)){
                    upsert UpsertSVMXEventlist; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
            UserId = UserId +'_Upsert';

            lstEventId = DCON_Create_Events_WS3(UserId, lstEventstoCreate, timeZone, lstKeyValue);

            lstKeyValue.clear();
            for(Event sfe: UpsertSFEventlist)
            {
                if(sfe.IsAllDayEvent)
                    lstEventId.add(string.Valueof(sfe.OwnerId) + '_' + string.Valueof(sfe.Id)+ '_' + sfe.ActivityDateTime.formatGmt('MM/dd/yyyy HH:mm')+ '_' + string.Valueof(sfe.DurationInMinutes));

                else
                    lstEventId.add(string.Valueof(sfe.OwnerId) + '_' + string.Valueof(sfe.Id)+ '_' + sfe.ActivityDateTime.format('MM/dd/yyyy HH:mm',timezone)+ '_' + string.Valueof(sfe.DurationInMinutes));
            }
            for(SVMXC__SVMX_Event__c oSVMXEvents: UpsertSVMXEventlist)
            {
                if(oSVMXEvents.SVMXC__IsAllDayEvent__c)
                    lstEventId.add(string.Valueof(oSVMXEvents.SVMXC__Technician__c) + '_' + oSVMXEvents.Id + '_'+ oSVMXEvents.SVMXC__ActivityDateTime__c.formatGMT('MM/dd/yyyy HH:mm')+ '_'+ string.Valueof(oSVMXEvents.SVMXC__DurationInMinutes__c));
                else
                    lstEventId.add(string.Valueof(oSVMXEvents.SVMXC__Technician__c) + '_' + oSVMXEvents.Id + '_'+ oSVMXEvents.SVMXC__ActivityDateTime__c.format('MM/dd/yyyy HH:mm',timezone)+ '_'+ string.Valueof(oSVMXEvents.SVMXC__DurationInMinutes__c));
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
                system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
                throw new SVMXException(ex.getMessage());
            }
        }
        return lstEventId;
    }

    public static Map<String,String> getSettingsFrom38To47()
    {
        Map<String,String> mapValidSettings = new Map<String,String>();
        if(svmxSettingList.get('SET038') != null)
            mapValidSettings.put('SET038', svmxSettingList.get('SET038'));
        if(svmxSettingList.get('SET039') != null)
            mapValidSettings.put('SET039', svmxSettingList.get('SET039'));
        if(svmxSettingList.get('SET040') != null)
            mapValidSettings.put('SET040', svmxSettingList.get('SET040'));
        if(svmxSettingList.get('SET041') != null)
            mapValidSettings.put('SET041', svmxSettingList.get('SET041'));
        if(svmxSettingList.get('SET042') != null)
            mapValidSettings.put('SET042', svmxSettingList.get('SET042'));
        if(svmxSettingList.get('SET043') != null)
            mapValidSettings.put('SET043', svmxSettingList.get('SET043'));
        if(svmxSettingList.get('SET044') != null)
            mapValidSettings.put('SET044', svmxSettingList.get('SET044'));
        if(svmxSettingList.get('SET045') != null)
            mapValidSettings.put('SET045', svmxSettingList.get('SET045'));
        if(svmxSettingList.get('SET046') != null)
            mapValidSettings.put('SET046', svmxSettingList.get('SET046'));
        if(svmxSettingList.get('SET047') != null)
            mapValidSettings.put('SET047', svmxSettingList.get('SET047'));
        return mapValidSettings;

    }

    public static Map<String,String> getEvtandWofields()
    {
        Map<String,String> mapValidSettings = getSettingsFrom38To47();
        system.debug(LoggingLevel.WARN, 'Map of settings defining Work Order & Event fields to be updated in DC Event window: ' + mapValidSettings);
        Map<String,String> mapValidSettingsForUpdate = new Map<String,String>();
        Map<String,Schema.DescribeFieldResult> EventFields = new Map<String,Schema.DescribeFieldResult>();
        Map<String,Schema.DescribeFieldResult> ServiceMaxEventFields = new Map<String,Schema.DescribeFieldResult>();        
        MAP<String,Schema.SObjectType> allObjs = Schema.getGlobalDescribe();        
        Schema.SObjectType objTEvent = allObjs.get('Event') ;
        Map<String,Schema.SObjectField> EventfieldMapping = objTEvent.getDescribe().fields.getMap();
        for(Schema.SObjectField fieldMap: EventfieldMapping.values()){
            Schema.DescribeFieldResult Eventfield = fieldMap.getDescribe();
            if(Eventfield.isUpdateable() && Eventfield.isCustom())
                EventFields.put(Eventfield.getName(),Eventfield);
        }
        EventfieldMapping.clear();

        Schema.SObjectType objTSVMXEvent = allObjs.get('SVMX_Event__c') ;
        allObjs.clear();
        Map<String,Schema.SObjectField> SVMXEventfieldMapping = objTSVMXEvent.getDescribe().fields.getMap();
        for(Schema.SObjectField fieldMap: SVMXEventfieldMapping.values()){
            Schema.DescribeFieldResult SVMXEventfield = fieldMap.getDescribe();
            if(SVMXEventfield.isUpdateable() && SVMXEventfield.isCustom())
                ServiceMaxEventFields.put(SVMXEventfield.getName(),SVMXEventfield);
        }
        Schema.DescribeFieldResult EvtobjFieldRes;
        Schema.DescribeFieldResult SvmxEvtobjFieldRes;

        if(mapValidSettings.keySet().size() > 0)
        {
            for(String strfld : mapValidSettings.keySet())
            {
                if((mapValidSettings.containsKey(strfld)) && (String.valueOf(mapValidSettings.get(strfld)).contains('Event.')))
                {
                    List<String> Evtfield = String.valueOf(mapValidSettings.get(strfld)).split('Event.',2);
                    EvtobjFieldRes = EventFields.get(Evtfield[1]);
                    SvmxEvtobjFieldRes = ServiceMaxEventFields.get(Evtfield[1]);

                    if((EventFields.ContainsKey(Evtfield[1]) && ServiceMaxEventFields.ContainsKey(Evtfield[1])) && ((EvtobjFieldRes.getType() == SvmxEvtobjFieldRes.getType())) && ((EvtobjFieldRes.getLength() == SvmxEvtobjFieldRes.getLength())))
                    {
                        mapValidSettingsForUpdate.put(strfld,mapValidSettings.get(strfld));
                    }
                }
                else
                {
                    mapValidSettingsForUpdate.put(strfld,mapValidSettings.get(strfld));
                }    
            }
        }

        return mapValidSettingsForUpdate;
    }

    // Get the list of valid, updateable Work Order & Event fields to be displayed in DC Event window from DCON001 SET038 - SET047
    public static Map<String, String> getValidateSettingsFrom38To47()
    {
        Map<String, String> mapValidSettings = getSettingsFrom38To47();
        system.debug(LoggingLevel.WARN, 'Map of settings defining Work Order & Event fields to be updated in DC Event window: ' + mapValidSettings);

        Map<String, String> mapValidSettingsForUpdate = new Map<String,String>();
        Map<String, Schema.DescribeFieldResult> EventFields = new Map<String, Schema.DescribeFieldResult>();
        Map<String, Schema.DescribeFieldResult> ServiceMaxEventFields = new Map<String, Schema.DescribeFieldResult>();

        MAP<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();

        Schema.SObjectType objTEvent = allObjs.get('Event') ;
        Map<String, Schema.SObjectField> EventfieldMapping = objTEvent.getDescribe().fields.getMap();
        for(Schema.SObjectField fieldMap: EventfieldMapping.values()){
            Schema.DescribeFieldResult Eventfield = fieldMap.getDescribe();
            if(Eventfield.isUpdateable() && Eventfield.isCustom())
                EventFields.put(Eventfield.getName(), Eventfield);
        }
        EventfieldMapping.clear();

        Schema.SObjectType objTSVMXEvent = allObjs.get('SVMX_Event__c') ;
        allObjs.clear();
        Map<String,Schema.SObjectField> SVMXEventfieldMapping = objTSVMXEvent.getDescribe().fields.getMap();
        for(Schema.SObjectField fieldMap: SVMXEventfieldMapping.values()){
            Schema.DescribeFieldResult SVMXEventfield = fieldMap.getDescribe();
            if(SVMXEventfield.isUpdateable() && SVMXEventfield.isCustom())
                ServiceMaxEventFields.put(SVMXEventfield.getName(), SVMXEventfield);
        }
        Schema.DescribeFieldResult EvtobjFieldRes;
        Schema.DescribeFieldResult SvmxEvtobjFieldRes;

        if(mapValidSettings.keySet().size() > 0)
        {
            for(String strfld : mapValidSettings.keySet())
            {
                if(String.valueOf(mapValidSettings.get(strfld)).contains('Event.'))
                {
                    List<String> Evtfield = String.valueOf(mapValidSettings.get(strfld)).split('Event.', 2);
                    EvtobjFieldRes = EventFields.get(Evtfield[1]);
                    SvmxEvtobjFieldRes = ServiceMaxEventFields.get(Evtfield[1]);

                    if((EventFields.ContainsKey(Evtfield[1]) && ServiceMaxEventFields.ContainsKey(Evtfield[1])) && ((EvtobjFieldRes.getType() == SvmxEvtobjFieldRes.getType())) && ((EvtobjFieldRes.getLength() == SvmxEvtobjFieldRes.getLength())))
                    {
                        mapValidSettingsForUpdate.put(strfld, Evtfield[1]);
                    }
                }       
            }
        }
        return mapValidSettingsForUpdate;
    }

    //Returns map of SFuserId and TechId
    public static map<String,String> getmapSFuserTechId(list<Event>  lstEvent)
    {
        list<string> lstSFuserId = new list<string>();
        map<string,string> mapSFIdTechId = new map<string,string>();
        for(Event objEvent: lstEvent)
            lstSFuserId.add(objEvent.OwnerId);

        for(SVMXC__Service_Group_Members__c objTech: [Select Id,SVMXC__Salesforce_User__c,Name, SVMXC__Enable_Scheduling__c from SVMXC__Service_Group_Members__c where SVMXC__Salesforce_User__c IN :lstSFuserId and SVMXC__Active__c=true])    
            mapSFIdTechId.put(objTech.SVMXC__Salesforce_User__c,objTech.Id);
        return mapSFIdTechId;
    }

    // Deprecated - Won't be using the below function as the logic consumes many SOQLs
    public static list<event> getOverlappingSFEventforTech(string inputOwnerID,DateTime inputStartTime, DateTime inputEndTime ,String inputEventId )
    {
        // 1) events that "end" during the input event's start and end time
        // 2) events that "start" during the input event's start and end time
        // 3) events that "start" before input event's start time and "end" after input event's end time
        // 4) events that "start" within the input event's start and end time including fully overlapped events
        if(inputEventId != null)
            return([Select Id, WhatId from Event Where (OwnerId = :inputOwnerID) AND  (Id != :inputEventId) AND
            ((ActivityDateTime < :inputStartTime AND EndDateTime > :inputStartTime) OR 
             (ActivityDateTime < :inputEndTime AND EndDateTime > :inputEndTime) OR
             (ActivityDateTime < :inputStartTime AND EndDateTime > :inputEndTime)OR 
             (ActivityDateTime >= :inputStartTime AND EndDateTime <= :inputEndTime))]);
        else
             return([Select Id, WhatId from Event Where (OwnerId = :inputOwnerID) AND  
            ((ActivityDateTime < :inputStartTime AND EndDateTime > :inputStartTime) OR 
             (ActivityDateTime < :inputEndTime AND EndDateTime > :inputEndTime) OR
             (ActivityDateTime < :inputStartTime AND EndDateTime > :inputEndTime)OR 
             (ActivityDateTime >= :inputStartTime AND EndDateTime <= :inputEndTime))]);
    }
    
    // Deprecated - Won't be using the below function as the logic consumes many SOQLs
    public static list<SVMXC__SVMX_Event__c> getOverlappingSVMXEventforTech(string inputOwnerID,DateTime inputStartTime, DateTime inputEndTime ,String inputEventId )
    {
        // 1) events that "end" during the input event's start and end time
        // 2) events that "start" during the input event's start and end time
        // 3) events that "start" before input event's start time and "end" after input event's end time
        // 4) events that "start" within the input event's start and end time including fully overlapped events
        if(inputEventId != null)
            return([Select Id, SVMXC__WhatId__c from SVMXC__SVMX_Event__c where (SVMXC__Technician__c = :inputOwnerID) AND (Id != :inputEventId) AND
            ((SVMXC__ActivityDateTime__c < = :inputStartTime AND SVMXC__EndDateTime__c > :inputStartTime) OR 
             (SVMXC__ActivityDateTime__c < :inputEndTime AND SVMXC__EndDateTime__c >= :inputEndTime) OR 
             (SVMXC__ActivityDateTime__c < :inputStartTime AND SVMXC__EndDateTime__c > :inputEndTime) OR 
             (SVMXC__ActivityDateTime__c >= :inputStartTime AND SVMXC__EndDateTime__c <= :inputEndTime))]);
        else
            return([Select Id, SVMXC__WhatId__c from SVMXC__SVMX_Event__c where (SVMXC__Technician__c = :inputOwnerID) AND (SVMXC__ActivityDateTime__c < :inputEndTime and SVMXC__EndDateTime__c > :inputStartTime)]); 
    }

    //Deprecated: not in use, this webservice can be used to fetch events for all the technicians passed
    WebService static List<Events_WP> DCON_Fetch_Events_WS(String UserId, String timeZoneDateTimeFormat, List<String> TechnicianIds)
    {
        //@Deprecated, this is retained as we do not have permission to remove 'webservice'
        List<Events_WP> resultSet = new List<Events_WP>();
        return resultSet;
    }

    //START: DNS-924: Fetch events based on the threshold limit i.e SET070 (Module: Dispatch Management, SubModule: Dispatch Console Flex)
    //This method retrieve events for the list of technicians and work orders passed
    WebService static List<Events_WP> DCON_Fetch_All_Events_WS(List<String> WOIds, 
                                                            String UserId, 
                                                            List<String> TechnicianIds, 
                                                            String timeZoneDateTimeFormat)
    {
        Boolean isLocal = false;
        List<String> SFUSerIds = new List<String>();
        List<Event> lstSalesforceEvents = new List<Event>();
        List<SVMXC__SVMX_Event__c> lstServiceMaxEvents = new List<SVMXC__SVMX_Event__c>();
        set<String> techlst = new set<String>();
        List<Events_WP> resultSet = new List<Events_WP>();

        try
        {
            techlst.addAll(TechnicianIds);
            list<string> lstTimeZoneDateTime = new list<string>();
            lstTimeZoneDateTime = timeZoneDateTimeFormat.split('@');
            string timeZone = lstTimeZoneDateTime.get(0);

            // Check for User TimeZone
            if(timeZone != NULL && timeZone != '')
            {
                if(Userinfo.getTimeZone().getID() == timeZone)
                    isLocal = true;
            }
            else
            {
                timeZone = Userinfo.getTimeZone().getID();
                isLocal = true;
            }

            //To support more than 14 day event for SF Tech, we are creating SVMX event based on the Config setting. 
            //According to the new logic we are retrieving both SF and SVMX Event for a technician
            List<SVMXC__Service_Group_Members__c> TechnicianList = [Select id, SVMXC__Salesforce_User__c from SVMXC__Service_Group_Members__c where Id IN :techlst];
            for(SVMXC__Service_Group_Members__c tl: TechnicianList)
            {
                //Get all user Id associated with SF tech to retrieve SF event
                if(tl.SVMXC__Salesforce_User__c != NULL)
                    SFUSerIds.add(tl.SVMXC__Salesforce_User__c);
            } 

            //get the threshold value from the setting SET070
            COMM_Utils_ManageSettings commUtils = new COMM_Utils_ManageSettings();
            Map<String, String> svmxSetting = new Map<String, String> ();
            svmxSetting = commUtils.SVMX_getSettingList('DCON001','SET070');
            Integer eventThresholdVal = 0;
            eventThresholdVal = integer.valueOf(svmxSetting.get('SET070'));

            //retrieve salesforce and servicemax events in 50:50 ratio
            Integer roundEventNum = eventThresholdVal/2;

            List<Event> tempLstSalesforceEvents = new List<Event>();
            List<SVMXC__SVMX_Event__c> tempLstServiceMaxEvents = new List<SVMXC__SVMX_Event__c>();

            Integer i = 0;
            Integer chunkSize = 500;
            Integer remainingWOCount = WOIds.size();
            Integer currentWOCount = 0;
            Integer tempTotEvents = 0;
            List<String> tempListWOId = new List<String>();

            //if the number of work orders are less than or equal to defined chunk size, then process at once
            if(WOIds.size() <= chunkSize)
            {
                lstSalesforceEvents = DCON_Event_WS.DCON_Fetch_Salesforce_Events(SFUSerIds, WOIds, roundEventNum);

                //if number of salesforce events are less than 50% of threshold value, 
                //then update the servicemax events limit to new roundEventNum
                if(lstSalesforceEvents.size() < roundEventNum)
                    roundEventNum = roundEventNum + (roundEventNum - lstSalesforceEvents.size());

                lstServiceMaxEvents = DCON_Event_WS.DCON_Fetch_ServiceMax_Events(TechnicianIds, WOIds, roundEventNum);               
            }
            //if the work orders count is more than the defined chunk size, then process by chunks
            else
            {
                //Process workorders in chunks, since too many work orders may cause a delay and which inturn may throw timeout exception
                for(i = 0; i < WOIds.size(); i++)
                {
                    currentWOCount++;
                    tempListWOId.add(WOIds[i]);

                    //process work orders once the number of work orders equals to chunk size and
                    //total events retrieved so far are less than the threshold limit (i.e. SET070 value)
                    if((currentWOCount == chunkSize) && (tempTotEvents < eventThresholdVal))
                    {
                        //get the number of work orders remaining after processing a chunk
                        remainingWOCount = remainingWOCount - currentWOCount;
                        //once the chunk is processed, initialize current work orders count to zero to start from next chunk
                        currentWOCount = 0;

                        tempLstSalesforceEvents = DCON_Event_WS.DCON_Fetch_Salesforce_Events(SFUSerIds, tempListWOId, roundEventNum);
                        lstSalesforceEvents.addall(tempLstSalesforceEvents);

                        //if the number of salesforce events are not same as roundEventNum, retrieve service max events by updating roundEventNum 
                        if(lstSalesforceEvents.size() < roundEventNum)
                            roundEventNum = roundEventNum + (roundEventNum - lstSalesforceEvents.size());

                        tempLstServiceMaxEvents = DCON_Event_WS.DCON_Fetch_ServiceMax_Events(TechnicianIds, tempListWOId, roundEventNum);
                        lstServiceMaxEvents.addall(tempLstServiceMaxEvents);

                        //update number of events fetched, and clear the lists to process next chunk and get remaining events
                        tempTotEvents = lstSalesforceEvents.size() + lstServiceMaxEvents.size();
                        tempListWOId.clear();
                        tempLstSalesforceEvents.clear();
                        tempLstServiceMaxEvents.clear();
                        
                        //once the number of events retrieved(threshold limit) are equal to tempTotEvents, we need not to retrieve anymore events
                        if(tempTotEvents == eventThresholdVal)
                        {
                            resultSet = DCON_Retrieve_Events_WS(lstSalesforceEvents, lstServiceMaxEvents, UserId, timeZoneDateTimeFormat, isLocal);
                            //set last synced time to current time
                            if(resultSet != null && resultSet.size() > 0 ) 
                            {
                                resultSet.get(resultSet.size()-1).lastSyncedTime = DateTime.now().getTime();

                                //Display an alert message when the threshold limit is met
                                //DCON001_TAG473 for displaying Alert message
                                System.debug('eventThresholdVal:' + eventThresholdVal);
                                if(resultSet.size() >= eventThresholdVal)
                                    resultSet.get(resultSet.size()-1).isEventThresholdMet = true;
                            }
                            else 
                            {
                                Events_WP obj = new Events_WP();
                                obj.lastSyncedTime = DateTime.now().getTime();
                                resultSet.add(obj);
                            }
                            system.debug('Size of resultSet before returning = ' + resultSet.size());        
                            return resultSet;
                        }
                        else
                        {
                            integer tempEventThresholdVal = 0;
                            tempEventThresholdVal = eventThresholdVal - tempTotEvents; //recalculate eventThresholdVal based on the number of events fetched so far and update roundEventNum value
                            roundEventNum = tempEventThresholdVal/2;
                        }
                    }
                    //Process last chunk of work orders
                    else if((remainingWOCount == currentWOCount) && (tempTotEvents < eventThresholdVal))
                    {
                        //retrieve salesforce and servicemax events in 50:50 ratio for the left over number of events
                        //Integer roundEventNum = eventThresholdVal/2;
                        
                        tempLstSalesforceEvents = DCON_Event_WS.DCON_Fetch_Salesforce_Events(SFUSerIds, tempListWOId, roundEventNum);
                        lstSalesforceEvents.addall(tempLstSalesforceEvents);

                        if(lstSalesforceEvents.size() < roundEventNum)
                            roundEventNum = roundEventNum + (roundEventNum - lstSalesforceEvents.size());

                        tempLstServiceMaxEvents = DCON_Event_WS.DCON_Fetch_ServiceMax_Events(TechnicianIds, tempListWOId, roundEventNum);
                        lstServiceMaxEvents.addall(tempLstServiceMaxEvents);
                    }
                }
            }

            resultSet = DCON_Retrieve_Events_WS(lstSalesforceEvents, lstServiceMaxEvents, UserId, timeZoneDateTimeFormat, isLocal);

            //set last synced time to current time
            if(resultSet != null && resultSet.size() > 0 ) 
            {
                resultSet.get(resultSet.size()-1).lastSyncedTime = DateTime.now().getTime();

                //Display an alert message when the threshold limit is met
                //DCON001_TAG473 for displaying Alert message
                System.debug('eventThresholdVal:' + eventThresholdVal);
                if(resultSet.size() >= eventThresholdVal)
                    resultSet.get(resultSet.size()-1).isEventThresholdMet = true;
            }
            else 
            {
                Events_WP obj = new Events_WP();
                obj.lastSyncedTime = DateTime.now().getTime();
                resultSet.add(obj);
            }
        }
        catch(Exception ex)
        {
            throw new SVMXException(ex);
        }
        system.debug('Size of resultSet before returning = ' + resultSet.size());        
        return resultSet;
    }

    //This method returns a list of Salesforce calendar events for one or more technicians
    //Depending upon the type of technician record, salesforce events are retrieved
    Public static List<Event> DCON_Fetch_Salesforce_Events(List<String> EventOwnerIds, 
                                                        List<String> WOIds, 
                                                        Integer roundEventNum)
    {
        Map<String,String> mapValidSettingsForUpdate = new Map<String,String>();
        mapValidSettingsForUpdate = getValidateSettingsFrom38To47();
        set<String> flds = new set<String>();

        try
        {
            set<String> EventOwners = new set<String>();
            EventOwners.addAll(EventOwnerIds);
            if(mapValidSettingsForUpdate.size() > 0)
            {
                for(String strfld : mapValidSettingsForUpdate.keySet())
                {
                    flds.add(mapValidSettingsForUpdate.get(strfld));    
                }

                flds.add('SVMXC__Driving_Time_Home__c');
                flds.add('SVMXC__Driving_Time__c');
                flds.add('SVMXC__Overhead_Time_Before__c');
                flds.add('SVMXC__Overhead_Time_After__c');
                flds.add('SVMXC__Service_Duration__c');
                flds.add('SVMXC__Break_Time_Total__c');
                flds.add('SVMXC__SM_Latitude__c');
                flds.add('SVMXC__SM_Longitude__c');
                
                return(Database.query('Select Id, Type, ActivityDate, ActivityDateTime, IsAllDayEvent, OwnerId, DurationInMinutes, Subject, Description, WhatId, StartDateTime, EndDateTime, Location, LastModifiedDate, ' + SVMX_getFieldNamesFromList(flds) +' from Event where OwnerId IN :EventOwners AND WhatId IN :WOIds and IsRecurrence = false order by StartDateTime Desc LIMIT :roundEventNum'));
            }
            else
            {
                return([Select Id, Type, ActivityDate, ActivityDateTime, IsAllDayEvent, OwnerId, DurationInMinutes, Subject, Description, WhatId, StartDateTime, EndDateTime, Location, LastModifiedDate,SVMXC__Driving_Time__c, SVMXC__Overhead_Time_Before__c, SVMXC__Overhead_Time_After__c, SVMXC__Driving_Time_Home__c, SVMXC__Service_Duration__c,SVMXC__Break_Time_Total__c,SVMXC__SM_Latitude__c,SVMXC__SM_Longitude__c from Event where OwnerId IN :EventOwners AND WhatId IN :WOIds and IsRecurrence = false order by StartDateTime Desc LIMIT :roundEventNum]);
            }
        }
        catch(Exception ex)
        {
            throw new SVMXException(ex);
        }
    }

    //This method returns a list of ServiceMax calendar events for one or more technicians
    //Depending upon the type of technician record, events are retrieved either from ServiceMax Events
    Public static List<SVMXC__SVMX_Event__c> DCON_Fetch_ServiceMax_Events(List<String> ServiceMaxEventOwnerIds, 
                                                                        List<String> WOIds, 
                                                                        Integer roundEventNum)
    {
        Map<String,String> mapValidSettingsForUpdate = new Map<String,String>();
        mapValidSettingsForUpdate = getValidateSettingsFrom38To47();
        set<String> flds = new set<String>();

        try
        {
            set<String> EventOwners = new set<String>();
            EventOwners.addAll(ServiceMaxEventOwnerIds);

            if(mapValidSettingsForUpdate.keySet().size() > 0)
            {
                for(String strfld : mapValidSettingsForUpdate.keySet())
                {
                    flds.add(mapValidSettingsForUpdate.get(strfld));    
                }

                flds.add('SVMXC__DurationInMinutes__c');
                flds.add('SVMXC__Description__c');
                flds.add('SVMXC__StartDateTime__c');
                flds.add('SVMXC__EndDateTime__c');
                flds.add('SVMXC__Driving_Time__c');
                flds.add('SVMXC__Driving_Time_Home__c');
                flds.add('SVMXC__IsAllDayEvent__c');
                flds.add('SVMXC__Overhead_Time_Before__c');
                flds.add('SVMXC__Overhead_Time_After__c');
                flds.add('SVMXC__Service_Duration__c');
                flds.add('SVMXC__Break_Time_Total__c');
                flds.add('SVMXC__Location__c');
                flds.add('SVMXC__SM_Latitude__c');
                flds.add('SVMXC__SM_Longitude__c');
                
                return(Database.query('Select Id, SVMXC__Type__c, SVMXC__ActivityDate__c, SVMXC__ActivityDateTime__c, SVMXC__Technician__c, Name, SVMXC__WhatId__c, LastModifiedDate,' + SVMX_getFieldNamesFromList(flds) +' from SVMXC__SVMX_Event__c where SVMXC__Technician__c IN :EventOwners AND SVMXC__Service_Order__c IN :WOIds order by SVMXC__StartDateTime__c Desc LIMIT :roundEventNum'));              
            }
            else
            {
                return([Select Id, SVMXC__Type__c, SVMXC__ActivityDate__c, SVMXC__ActivityDateTime__c, SVMXC__Technician__c, SVMXC__DurationInMinutes__c, Name, SVMXC__Description__c, SVMXC__WhatId__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c, SVMXC__Location__c, LastModifiedDate,SVMXC__Driving_Time__c, SVMXC__IsAllDayEvent__c,SVMXC__Overhead_Time_Before__c, SVMXC__Overhead_Time_After__c, SVMXC__Driving_Time_Home__c, SVMXC__Service_Duration__c,SVMXC__Break_Time_Total__c,SVMXC__SM_Latitude__c,SVMXC__SM_Longitude__c from SVMXC__SVMX_Event__c where SVMXC__Technician__c IN :EventOwners AND SVMXC__Service_Order__c IN :WOIds order by SVMXC__StartDateTime__c Desc LIMIT :roundEventNum]);
            }
        }
        catch(Exception ex)
        {
            throw new SVMXException(ex);
        }
    }
    //END: DNS-924: Code changes made to fetch events based on threshold limit ends
    //1481 - overnight user story starts
        global class Overnight_Events_Output_WP
        {
            WebService String id{get; set;}
            WebService String startTime {get; set;}
            WebService String endTime {get; set;}
            WebService String location {get; set;}
            WebService Double latitude {get; set;}
            WebService Double longitude {get; set;}
            WebService String lat{get; set;}
            WebService String lng {get; set;}
            WebService String Type {get; set;}
            WebService Boolean isWOEvent {get; set;}  
            WebService String Subject {get; set;}  
              
        }
        global class Overnight_Events_Input_WP
            {
                WebService String UserId{get; set;}
                WebService String StartDate {get; set;}
                WebService String EndDate {get; set;}
                WebService String timeZoneDateTimeFormat {get; set;}
                WebService List<String> TechnicianIds {get; set;}
                     
            }   
        WebService static List<Overnight_Events_Output_WP> DCON_Retrieve_Overnight_Events_WS(Overnight_Events_Input_WP req)
            {
                Boolean isLocal = false;
                List<String> SFUSerIds = new List<String>();
                List<Event> lstWOSalesforceEvents = new List<Event>();
                List<SVMXC__SVMX_Event__c> lstWOServiceMaxEvents = new List<SVMXC__SVMX_Event__c>();
                List<Event> lstWOSalesforceEvents1 = new List<Event>();
                List<SVMXC__SVMX_Event__c> lstWOServiceMaxEvents1 = new List<SVMXC__SVMX_Event__c>();
                set<String> techlst = new set<String>();
                List<Overnight_Events_Output_WP> resultSet = new List<Overnight_Events_Output_WP>();
                try
                {
                    String woKeyPrefix = Schema.SObjectType.SVMXC__Service_Order__c.getKeyPrefix();
                    techlst.addAll(req.TechnicianIds);
                    list<string> lstTimeZoneDateTime = new list<string>();
                    lstTimeZoneDateTime = req.timeZoneDateTimeFormat.split('@');
                    string timeZone = lstTimeZoneDateTime.get(0);
                    lstTimeZoneDateTime.clear();

                    if(timeZone != NULL && timeZone != '')
                    {
                        if(Userinfo.getTimeZone().getID() == timeZone)
                            isLocal = true;
                    }
                    else
                    {
                        timeZone = Userinfo.getTimeZone().getID();
                        isLocal = true;
                    }    
                    
                    for(SVMXC__Service_Group_Members__c tl: [Select id, SVMXC__Salesforce_User__c from SVMXC__Service_Group_Members__c where Id IN :techlst]) 
                    {
                        //Get all user Id associated with SF tech to retrieve SF event
                        if(tl.SVMXC__Salesforce_User__c != NULL)
                            SFUSerIds.add(tl.SVMXC__Salesforce_User__c);
                    } 

                    
                    Date tempStartDate = (Date.valueOf(req.StartDate)).addDays(-1); 
                    Date tempEndDate = (Date.valueOf(req.EndDate)).addDays(1); 
                    
                    lstWOSalesforceEvents = DCON_Event_WS.DCON_Retrieve_Salesforce_Events_WS(timeZone, String.valueOf(tempStartDate), String.valueOf(tempEndDate), SFUSerIds);
                    
                    lstWOServiceMaxEvents = DCON_Event_WS.DCON_Retrieve_ServiceMax_Events_WS(timeZone, String.valueOf(tempStartDate), String.valueOf(tempEndDate), req.TechnicianIds);
                    
                            
                    for(Event e: lstWOSalesforceEvents)
                    {
                        Overnight_Events_Output_WP sf_WO_event = new Overnight_Events_Output_WP();
                        sf_WO_event.id = e.Id;
                        sf_WO_event.location = CheckNull(e.location); 
                        sf_WO_event.Type = CheckNull(e.Type);
                        sf_WO_event.latitude = e.SVMXC__SM_Latitude__c;
                        sf_WO_event.Longitude = e.SVMXC__SM_Longitude__c;
                        if(sf_WO_event.latitude == null)
                        {
                            sf_WO_event.lat = 'undefined';
                        }
                        else
                        {
                            sf_WO_event.lat = String.valueOf(sf_WO_event.latitude);
                        }   
                        if(sf_WO_event.Longitude == null)
                        {
                            sf_WO_event.lng = 'undefined';  
                        }
                        else
                        {
                            sf_WO_event.lng = String.valueOf(sf_WO_event.Longitude);
                        }
                        sf_WO_event.Subject = e.Subject;
                        if(String.valueOf(e.WhatId) != null && !String.isBlank(String.valueOf(e.WhatId)))
                            {   
                                if(woKeyPrefix.equals(String.valueOf(e.WhatId).substring(0,3)))
                                {
                                    sf_WO_event.isWOEvent = true;
                                }
                                else
                                {
                                    sf_WO_event.isWOEvent = false;  
                                }       
                            }   
                        else    
                            {       
                                sf_WO_event.isWOEvent = false;  
                            }   
                            // Format the datetime in fixed 'MM/dd/yyyy hh:mm a' format, but in applicable time zone
                            // Because, Flex needs the date time string to be in this format
                        if(e.IsAllDayEvent)
                            {
                                if(e.StartDateTime != NULL)
                                {
                                    sf_WO_event.startTime = e.StartDateTime.formatGMT('MM/dd/yyyy hh:mm a');
                                    if(e.DurationInMinutes != NULL)
                                    {
                                        sf_WO_event.endTime = e.StartDateTime.addMinutes(Integer.valueof(e.DurationInMinutes)).formatGMT('MM/dd/yyyy hh:mm a');
                                    }
                                }
                            }
                        else if(isLocal == true)
                            {
                                if(e.StartDateTime != NULL)
                                {
                                    sf_WO_event.startTime = e.StartDateTime.format('MM/dd/yyyy hh:mm a');
                                    if(e.DurationInMinutes != NULL)
                                    {
                                        sf_WO_event.endTime = e.StartDateTime.addMinutes(Integer.valueof(e.DurationInMinutes)).format('MM/dd/yyyy hh:mm a');
                                    }
                                }
                            }
                        else
                            {
                                if(e.StartDateTime != NULL)
                                {
                                    sf_WO_event.startTime = e.StartDateTime.format('MM/dd/yyyy hh:mm a', timeZone);
                                    if(e.DurationInMinutes != NULL)
                                    {
                                        sf_WO_event.endTime = e.StartDateTime.addMinutes(Integer.valueof(e.DurationInMinutes)).format('MM/dd/yyyy hh:mm a', timeZone);
                                    }
                                }
                            }
                        resultSet.add(sf_WO_event);
                            
                    }
                    
                    for(SVMXC__SVMX_Event__c e: lstWOServiceMaxEvents)
                    {
                        Overnight_Events_Output_WP svmx_WO_event = new Overnight_Events_Output_WP();
                        svmx_WO_event.id = e.Id;
                        svmx_WO_event.location = CheckNull(e.SVMXC__Location__c);
                        svmx_WO_event.Type = CheckNull(e.SVMXC__Type__c);
                        svmx_WO_event.latitude = e.SVMXC__SM_Latitude__c;
                        svmx_WO_event.Longitude = e.SVMXC__SM_Longitude__c;
                        svmx_WO_event.Subject = e.Name;
                        if(svmx_WO_event.latitude == null)
                        {
                            svmx_WO_event.lat = 'undefined';
                        }
                        else
                        {
                            svmx_WO_event.lat = String.valueOf(svmx_WO_event.latitude);
                        }   
                        if(svmx_WO_event.Longitude == null)
                        {
                            svmx_WO_event.lng = 'undefined';    
                        }
                        else
                        {
                            svmx_WO_event.lng = String.valueOf(svmx_WO_event.Longitude);
                        }
                        if(String.valueOf(e.SVMXC__WhatId__c) != null && !String.isBlank(String.valueOf(e.SVMXC__WhatId__c)))
                            {   
                                if(woKeyPrefix.equals(String.valueOf(e.SVMXC__WhatId__c).substring(0,3)))
                                {
                                    svmx_WO_event.isWOEvent = true;
                                }
                                else
                                {
                                    svmx_WO_event.isWOEvent = false;    
                                }       
                            }   
                        else    
                            {       
                                svmx_WO_event.isWOEvent = false;    
                            }       
                                                        
                        if(e.SVMXC__IsAllDayEvent__c)
                            {
                                if(e.SVMXC__StartDateTime__c != NULL)
                                {
                                    svmx_WO_event.startTime = e.SVMXC__StartDateTime__c.formatGMT('MM/dd/yyyy hh:mm a');
                                    if(e.SVMXC__DurationInMinutes__c != NULL)
                                    {
                                        svmx_WO_event.endTime = e.SVMXC__StartDateTime__c.addMinutes(Integer.valueof(e.SVMXC__DurationInMinutes__c)).formatGMT('MM/dd/yyyy hh:mm a');
                                    }
                                }
                            }
                        else if(isLocal == true)
                            {
                                if(e.SVMXC__StartDateTime__c != NULL)
                                {
                                    svmx_WO_event.startTime = e.SVMXC__StartDateTime__c.format('MM/dd/yyyy hh:mm a');
                                    if(e.SVMXC__DurationInMinutes__c != NULL)
                                    {
                                        svmx_WO_event.endTime = e.SVMXC__StartDateTime__c.addMinutes(Integer.valueof(e.SVMXC__DurationInMinutes__c)).format('MM/dd/yyyy hh:mm a');
                                    }
                                }
                            }
                        else
                            {
                                if(e.SVMXC__StartDateTime__c != NULL)
                                {
                                    svmx_WO_event.startTime = e.SVMXC__StartDateTime__c.format('MM/dd/yyyy hh:mm a', timeZone);
                                    if(e.SVMXC__DurationInMinutes__c != NULL)
                                    {
                                        svmx_WO_event.endTime = e.SVMXC__StartDateTime__c.addMinutes(Integer.valueof(e.SVMXC__DurationInMinutes__c)).format('MM/dd/yyyy hh:mm a', timeZone);
                                    }
                                }
                            }            
                        resultSet.add(svmx_WO_event);
                    }
                }
                catch(Exception ex)
                {
                    system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
                    throw new SVMXException(ex);
                }

                system.debug(logginglevel.warn,'Event wrapper: ' + resultSet);
                return resultSet;
            }
            //1481 - overnight user story ends
            //1790 - collapse and expand of team and territory user story
        WebService static List<String> getListOfTechScheduled(List<String> lstworkOrderId)
        {
            List<String> lstTechnicians = new List<String>();
            if(lstworkOrderId != null && lstworkOrderId.size()>0)
            {
                List<Event> lstEvents = new List<Event>();
                lstEvents = [Select Id,DurationInMinutes,IsAllDayEvent,OwnerId,StartDateTime,SVMXC__Driving_Time_Home__c,SVMXC__Driving_Time__c,EndDateTime,SVMXC__Overhead_Time_After__c,SVMXC__Overhead_Time_Before__c,SVMXC__Service_Duration__c,WhatId from Event where WhatId IN :lstworkOrderId];   
               
                List<SVMXC__SVMX_Event__c> lstSVMXEvents = new List<SVMXC__SVMX_Event__c>();
                lstSVMXEvents = [Select Id,SVMXC__DurationInMinutes__c,SVMXC__IsAllDayEvent__c,OwnerId,SVMXC__StartDateTime__c,SVMXC__Driving_Time_Home__c,SVMXC__Driving_Time__c,SVMXC__EndDateTime__c,SVMXC__Overhead_Time_After__c,SVMXC__Overhead_Time_Before__c,SVMXC__Service_Duration__c,SVMXC__Technician__c,SVMXC__WhatId__c from SVMXC__SVMX_Event__c where SVMXC__WhatId__c IN :lstworkOrderId OR SVMXC__Service_Order__c IN :lstworkOrderId];   
                                            
                System.debug('lstEvents:' + lstEvents);
                System.debug('lstSVMXEvents:' + lstSVMXEvents);
                Set<String> setownerIds = new set<String>();
                for(Event evt: lstEvents)
                {
                    setownerIds.add(evt.OwnerId);   
                }
                
                List<SVMXC__Service_Group_Members__c> lsttech = new List<SVMXC__Service_Group_Members__c>();
                lsttech = [Select Id, SVMXC__Salesforce_User__c from SVMXC__Service_Group_Members__c where SVMXC__Salesforce_User__c IN :setownerIds];
                
                for(SVMXC__Service_Group_Members__c tech: lsttech)    
                {
                    lstTechnicians.add(tech.Id);
                        
                }
                
                for(SVMXC__SVMX_Event__c svmxevt: lstSVMXEvents)
                {
                    lstTechnicians.add(svmxevt.SVMXC__Technician__c);
                }
               
            }
            return lstTechnicians;
        }
        //1790 - End
}