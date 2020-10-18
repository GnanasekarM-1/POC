/**
@Name: WSCH_Provider_SP_Appointments_Calendar
@Author: Zubair
@Description: This is a Controller class for the appointments page, WSCH_Provider_SP_Appointments_Calendar
**/

public with sharing class WSCH_Provider_SP_Appointments_Calendar{
    WSCH_AppointmentsResponse technicianSlotResponse = new WSCH_AppointmentsResponse();
    public String eventsJson { get; set; } 
    public String selectedRowId { get; set; }
    public String strWorkOrderID { get; set; }
    public String strWORecordID { get; set; }
    public String strSPInstance { get; set; }
    public String calendarStartDate {get; set;} 
    public Integer minEventStartTime {get; set;}
    public Integer maxEventEndTime {get; set;}
    public String bookedTechnician {get; set;}
    public String bookedTimings {get; set;}
    public WSCH_Appointment currentAppointment {get; set;}
    
    //CRUD security related functions
    public static COMM_SecurityUtils securityUtils = COMM_SecurityUtils.getInstance();
    
    
    public String strOfferApptErrorMsg { get; set; }
    public String strBookApptErrorMsg { get; set; }
    
    public List<WSCH_Appointment> lstOfTechnicianSlot { get; set; }
    
    public boolean isBookApptFailed = false;
    public boolean isBookApptExecuted = false;
    public boolean isBookApptSuccess = false;
    
    //public boolean isViewMoreApptExecuted = false;
    //public boolean isViewMoreApptFailed = false;
    //public boolean displayViewMore = true;
    
    public static Map<String, String> mapOfWeekDays = new Map<String, String>();
    //public Integer nextAppointmentIndex = 1;
    
    public String strBookApptSuccessMsg { get; set; }
    public boolean isForceBookJob = true;
    public String strCurrentApptMsg { get; set; }
    public boolean isDisplayCurrentAppt = false;
    
    public boolean isDisplayForceBookMsg = false;
    public String strForceBookMsg { get; set; }
    
    public String strCalStartDate { get; set; }
    public String strCalEndDate { get; set; }
    
    public String strNoOfDaysInCalSetting { get; set; }
    public String strIsEarlyArrivalEnabled { get; set; }
    public String strApiToUse { get; set; }
    
    public boolean isEarlyArrival = false;
    public String strIsEarlyArrivalSelected { get; set; }
    public static Boolean isEarlyArrivalSelected;
    public boolean isOutsideSLA {get; set;}
    
    /* boolean variables to control calendar components based on settings   */
    /*Kundan- Commented below lines of code because setting 'DCON003,SET004' is updated to text*/
    //public boolean isDisplayTechName = true;
    public boolean isEnableUnresourcedTray = true;
    public boolean isEnableFetchApptByStartEndDt = true;
    public boolean isEnableCancelAppt = true;
    public boolean isEnableHelpText = true;
    
    public String strTimeZone;
    
    public static String strOldApptPromiseSlot;
    public static String strOldApptBookedSlot;
    public BusinessHours woBusinessHour { get; set; }
    
    public String localeDateTimeFormat { get; set; }
    
    public WSCH_ApptParam apptParamObj = new WSCH_ApptParam();
    
    public String strtechFieldSetting;
    
    static {
        /* Static initialization of Week Days map */
        mapOfWeekDays.put('Mon',getTAG013());
        mapOfWeekDays.put('Tue',getTAG014());
        mapOfWeekDays.put('Wed',getTAG015());
        mapOfWeekDays.put('Thu',getTAG016());
        mapOfWeekDays.put('Fri',getTAG017());
        mapOfWeekDays.put('Sat',getTAG018());
        mapOfWeekDays.put('Sun',getTAG022());
        
        //static initialization of DCON003_SET004 setting
        //strtechFieldSetting = String.valueof(WSCH_CommonUtils.getSettingValue('DCON003','SET004'));
    }
    
    /* Non - static initialization of variables to initialize instance variables*/
    {
        //Initialising below variable to avoid javascript compilation error invisual force page.
        minEventStartTime = 23;
        maxEventEndTime = 0;
        eventsJson = '[]';
    }
    public boolean displayViewMore = true;
    public String strXMLData { get; set; }
    public Integer strNextAppointmentIndex = 1;
    public static Map<String, String> mapOfPromiseType = new Map<String, String>();
    public boolean isViewMoreApptExecuted = false;
    public boolean isViewMoreApptFailed = false;
    public Integer slotsSize{ get; set; }
    public String strLocaleDateFormat { get; set; }
    public String strUserLanguage{get; set;}
    
    static {
        /* Static initialization of Promise Types Map */
        mapOfPromiseType.put('D',getTAG019());
        mapOfPromiseType.put('T',getTAG020());
        mapOfPromiseType.put('P',getTAG021());
    }
    public WSCH_Provider_SP_Appointments_Calendar() {
        
        getCalendarSettings();
        strLocaleDateFormat = WSCH_DateUtils.getLocaleDateFormat();
    }
    
    
    public void getCalendarSettings() {
        
        String strTempCalDaysSetting = WSCH_CommonUtils.getSettingValue('DCON003','SET008');
        
        if(strTempCalDaysSetting != null && String.isNotBlank(strTempCalDaysSetting)) {
            
            strNoOfDaysInCalSetting = strTempCalDaysSetting;
        } else {
            
            strNoOfDaysInCalSetting = '7';  /* Set 7 as default value if there is not setting value */
        }
        WSCH_AuditLogger.debug('strNoOfDaysInCalSetting - ' + strNoOfDaysInCalSetting);
        
        /* Setting to display technician fields for a event. */
        strtechFieldSetting = WSCH_CommonUtils.getSettingValue('DCON003','SET004');
        
        WSCH_AuditLogger.debug('strtechFieldSetting - ' + strtechFieldSetting);
        
        String strTempIsEarlyArrivalEnabled = WSCH_CommonUtils.getSettingValue('DCON003','SET005');
        if(strTempIsEarlyArrivalEnabled != null && String.isNotBlank(strTempIsEarlyArrivalEnabled)) {
            
            strIsEarlyArrivalEnabled = strTempIsEarlyArrivalEnabled.touppercase();  //this will contain either 'TRUE' or 'FALSE'
        } else {
            
            strIsEarlyArrivalEnabled = 'FALSE';
        }
        
        String strTempApiToUse = WSCH_CommonUtils.getSettingValue('DCON003','SET002');
        if(strTempApiToUse != null && String.isNotBlank(strTempApiToUse)) {
            
            strApiToUse = strTempApiToUse.touppercase();
        } else {
            
            strApiToUse = 'APPOINTMENT';
        }
        
        if(strApiToUse != null && String.isNotBlank(strApiToUse) && strApiToUse.equalsIgnoreCase('SLA job')) {
            if(strIsEarlyArrivalEnabled != null && String.isNotBlank(strIsEarlyArrivalEnabled) && strIsEarlyArrivalEnabled.equalsIgnoreCase('TRUE')) {
                isEarlyArrival = true;
            }
        }
        
        /* Setting to display technician name for a event in calendar or not */
        /*Kundan- Commented below lines of code because setting 'DCON003,SET004' is updated to text*/
        /*String strTempIsDisplayTechName = WSCH_CommonUtils.getSettingValue('DCON003','SET004');
        if(strTempIsDisplayTechName != null && String.isNotBlank(strTempIsDisplayTechName)) {
        
        if(strTempIsDisplayTechName.touppercase().equalsIgnoreCase('FALSE')) {
        isDisplayTechName = false;
        } else {
        isDisplayTechName = true;
        }
        }*/
        
        /* Setting to display 'Send to unresourced tray' button or not  */
        String strTempIsEnableUnresourcedTray = WSCH_CommonUtils.getSettingValue('DCON003','SET009');
        if(strTempIsEnableUnresourcedTray != null && String.isNotBlank(strTempIsEnableUnresourcedTray)) {
            
            if(strTempIsEnableUnresourcedTray.touppercase().equalsIgnoreCase('FALSE')) {
                isEnableUnresourcedTray = false;
            } else {
                isEnableUnresourcedTray = true;
            }
        }
        
        /* Setting to display 'Start Date' and 'End Date' to fetch appointments  */
        String strTempIsEnableFetchApptByStartEndDt = WSCH_CommonUtils.getSettingValue('DCON003','SET010');
        if(strTempIsEnableFetchApptByStartEndDt != null && String.isNotBlank(strTempIsEnableFetchApptByStartEndDt)) {
            
            if(strTempIsEnableFetchApptByStartEndDt.touppercase().equalsIgnoreCase('FALSE')) {
                isEnableFetchApptByStartEndDt = false;
            } else {
                isEnableFetchApptByStartEndDt = true;
            }
        }
        
        /* Setting to display 'Cancel' appointments button  */
        String strTempIsEnableCancelAppt = WSCH_CommonUtils.getSettingValue('DCON003','SET011');
        if(strTempIsEnableCancelAppt != null && String.isNotBlank(strTempIsEnableCancelAppt)) {
            
            if(strTempIsEnableCancelAppt.touppercase().equalsIgnoreCase('FALSE')) {
                isEnableCancelAppt = false;
            } else {
                isEnableCancelAppt = true;
            }
        }
        
        /* Setting to display 'Help Text' */
        String strTempIsEnableHelpText = WSCH_CommonUtils.getSettingValue('DCON003','SET012');
        if(strTempIsEnableHelpText != null && String.isNotBlank(strTempIsEnableHelpText)) {
            
            if(strTempIsEnableHelpText.touppercase().equalsIgnoreCase('FALSE')) {
                isEnableHelpText = false;
            } else {
                isEnableHelpText = true;
            }
        }
    }
    
    /**  This method gets the start and end date from the work order which will be set in the calendar start and end date resp. **/
    public void populateCalendarDates() {
        
        WSCH_AuditLogger.debug('Inside populateCalendarDates()');
        try{
            
            strWORecordID = System.currentPageReference().getParameters().get('workorderID');
            WSCH_AuditLogger.debug('WSCH_Provider_SP_Appointments_Calendar::populateCalendarDates:: strWORecordID -'+strWORecordID);
            
            if(strWORecordID != null)
                strWORecordID = strWORecordID.substring(0,18).trim();
            
            SVMXC__Service_Order__c currWorkOrder = WSCH_CommonUtils.fetchWorkOrderById(strWORecordID);
            if(currWorkOrder.SVMXC__SLA_Terms__c != null){
                WSCH_Constants.setSLAIds.add(currWorkOrder.SVMXC__SLA_Terms__c);
            }
            if(currWorkOrder.SVMXC__Service_Contract__c != null){
                WSCH_Constants.setServiceContractIds.add(currWorkOrder.SVMXC__Service_Contract__c);
            }
            WSCH_AuditLogger.debug('WSCH_Provider_SP_Appointments_Calendar::populateCalendarDates:: setServiceContracts -'+WSCH_Constants.setServiceContractIds.size());
            String strCalOffset, strCalLength;
            
            //get the time zone info from Work Order preferred business hours, if not available, get it from LoggedIn user
            List<BusinessHours> lstOfBusinessHours = getBusinessHoursById(currWorkOrder.SVMXC__Preferred_Business_Hours__c);
            
            //String strTimeZone;
            if(lstOfBusinessHours != null && lstOfBusinessHours.size() > 0) {
                strTimeZone = lstOfBusinessHours[0].TimeZoneSidKey;
            } else if(UserInfo.getTimeZone() != null) {
                strTimeZone = String.valueOf(UserInfo.getTimeZone());
            }
            
            DateTime startDateTime, endDateTime;
            WSCH_Provider_SP_RealTimeOptimizer.getSpURL('');
            System.debug(logginglevel.ERROR,'%%%spInstance: ' + System.currentPageReference().getParameters().get('spInstance'));
            if(System.currentPageReference().getParameters().get('spInstance') != null) {
                strSPInstance = System.currentPageReference().getParameters().get('spInstance');
            }
            if((strSPInstance == null) || (String.isBlank(strSPInstance))){
                strSPInstance = WSCH_Provider_SP_RealTimeOptimizer.strDefaultConnection;
            }
            //String strMapId = WSCH_Provider_SP_DataMapper.getSFMMappingId(WSCH_Constants.API_OFFER_APPT);
            String strMapId = WSCH_Provider_SP_DataMapper.getSpSFMMappingId(WSCH_Constants.API_OFFER_APPT, strSPInstance);
            map<String,Object> mapfieldvalues = new map<String,Object>();
            if(String.isNotBlank(strMapId)) {
                WSCH_AuditLogger.debug('Start of getSmartObjectRecords(): No of Queries used in this transaction so far: ' + Limits.getQueries());
                mapfieldvalues = WSCH_Provider_SP_DataMapper.getSmartObjectRecords(strMapId, currWorkOrder);
                WSCH_AuditLogger.debug('End of getSmartObjectRecords(): No of Queries used in this transaction so far: ' + Limits.getQueries());
                WSCH_AuditLogger.debug('WSCH_Provider_SP_DataMapper::mapOfferApptRequest:mapfieldvalues: '+mapfieldvalues);
            }
            
            //get the calendar startDate and end date from mapping, if not present in mapping, consider start as today and 
            // end as today + no. of calendar days from setting
            if(mapfieldvalues != null && (mapfieldvalues.get('start.date') != null || mapfieldvalues.get('end.date') != null)) {
                if(mapfieldvalues.get('end.date') == null){
                    startDateTime = (DateTime)mapfieldvalues.get('start.date');
                    endDateTime = startDateTime.addDays(Integer.valueOf(strNoOfDaysInCalSetting) - 1);
                }
                else if(mapfieldvalues.get('start.date') == null){
                    startDateTime = DateTime.now();
                    endDateTime = (DateTime)mapfieldvalues.get('end.date');
                }
                else{
                    startDateTime = (DateTime)mapfieldvalues.get('start.date');
                    endDateTime = (DateTime)mapfieldvalues.get('end.date');
                }
            } else {
                startDateTime = DateTime.now();
                endDateTime = DateTime.now().addDays(Integer.valueOf(strNoOfDaysInCalSetting) - 1);
            }
            
            if(startDateTime != null && endDateTime != null) {
                if((strCalStartDate == null || strCalStartDate == '') && ( strCalEndDate == null || strCalEndDate =='' )){
                    //UI fields 
                    //strCalStartDate = startDateTime.format('yyyy-MM-dd', strTimeZone);
                    //strCalEndDate = endDateTime.format('yyyy-MM-dd', strTimeZone);
                    
                    String localeFormat = strLocaleDateFormat.replace('%m', 'MM');
                    localeFormat = localeFormat.replace('%d', 'dd');
                    localeFormat = localeFormat.replace('%Y', 'yyyy');
                    
                    WSCH_AuditLogger.debug('localeFormat - ' + localeFormat);
                    WSCH_AuditLogger.debug('strLocaleDateFormat - ' + strLocaleDateFormat);
                    
                    strCalStartDate = startDateTime.format(localeFormat, strTimeZone);
                    strCalEndDate = endDateTime.format(localeFormat, strTimeZone);
                    
                    WSCH_AuditLogger.debug('if start date in calendar is null, strCalStartDate - ' + strCalStartDate);
                    WSCH_AuditLogger.debug('if end date in calendar is null, strCalEndDate - ' + strCalEndDate);
                    
                    system.debug('if start date in calendar is null, strCalStartDate - ' + strCalStartDate);
                    system.debug('if start date in calendar is null, strCalStartDate - ' + strCalStartDate);
                } else {
                    WSCH_AuditLogger.debug('if start date in calendar is not null, strCalStartDate - ' + strCalStartDate);
                    WSCH_AuditLogger.debug('if end date in calendar is not null, strCalEndDate - ' + strCalEndDate);
                    
                    system.debug('if start date in calendar is not null, strCalStartDate - ' + strCalStartDate);
                    system.debug('if end date in calendar is not null, strCalEndDate - ' + strCalEndDate);
                    
                    //below code converts Locale specific date into the yyyy-MM-dd format
                    String strCalStart = String.valueOf(Date.parse(strCalStartDate));
                    String strCalEnd = String.valueOf(Date.parse(strCalEndDate));
                    
                    DateTime startDateTimeUsr = WSCH_DateUtils.parseDateTimeNew(strCalStart + ' 00:00:00');
                    DateTime endDateTimeUsr = WSCH_DateUtils.parseDateTimeNew(strCalEnd + ' 23:59:59');
                    
                    //commented the below code and replaced with the above two lines by changing the time stamp from 23:00:00 to 23:59:59
                    //DateTime startDateTimeUsr = WSCH_DateUtils.parseDateTimeNew(strCalStart + ' 00:00:00');
                    //DateTime endDateTimeUsr = WSCH_DateUtils.parseDateTimeNew(strCalEnd + ' 23:00:00');
                    
                    //DateTime startDateTimeUsr = WSCH_DateUtils.parseDateTimeNew(strCalStartDate + ' 00:00:00');
                    //DateTime endDateTimeUsr = WSCH_DateUtils.parseDateTimeNew(strCalEndDate + ' 23:00:00');
                    
                    //set the start and end dates on the ApptParam object which can be later used to retrieve the appointments for the
                    // selected start and end date when 'Search' is clicked
                    apptParamObj.startDateTime = startDateTimeUsr;
                    apptParamObj.endDateTime = endDateTimeUsr;
                    WSCH_AuditLogger.debug('apptParamObj.startDateTime - ' + apptParamObj.startDateTime);
                    WSCH_AuditLogger.debug('apptParamObj.endDateTime - ' + apptParamObj.endDateTime);
                }
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_Appointments_Calendar :: populateCalendarDates :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
    
    private static List<BusinessHours> getBusinessHoursById(String strId) {
        List<BusinessHours> lstOfBusinessHours;
        try{
            if(null != strId){
                lstOfBusinessHours = [SELECT Id,IsActive,IsDefault,TimeZoneSidKey,MondayStartTime,MondayEndTime,
                                      TuesdayStartTime,TuesdayEndTime,WednesdayStartTime,WednesdayEndTime,
                                      ThursdayStartTime,ThursdayEndTime,FridayStartTime,FridayEndTime,SaturdayStartTime,
                                      SaturdayEndTime,SundayStartTime,SundayEndTime FROM BusinessHours
                                      WHERE Id =: strId AND IsActive = TRUE];
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_Appointments_Calendar :: getBusinessHoursById :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return lstOfBusinessHours;
    }
    
    /**  This method builds the JSON data with the appointment slots after retrieving it from the Service Power  **/
    public PageReference buildResponseData() {
        WSCH_AuditLogger.debug('Inside buildResponsedata()');
        
        //fetch User Language
        strUserLanguage = UserInfo.getLanguage();
        //getCalendarSettings();
        populateCalendarDates();
        
        //set the Mode Of Booking in Global map to be accessed by API Hook
        WSCH_CommonUtils.putGlobalUtilValMap('isCalendarBooking','true');
        
        WSCH_AuditLogger.debug('Out of populateCalendarDates()');
        
        /* Logic to check global settings GBL007 is set to True and GBL022 contains ServicePower */
        String settingsGBL007 = WSCH_CommonUtils.getSettingValue('GLOB001', 'GBL007');
        String settingsGBL022 = WSCH_CommonUtils.getSettingValue('GLOB001', 'GBL022');
        if(settingsGBL007 != null && settingsGBL007.touppercase() == 'FALSE') {
            /* Dispatch optimization settings value is set to false.Please make it to true to get appointments' */
            strOfferApptErrorMsg = getTAG026();
            /*      Disable 'Send to Unresourced Tray' button when continuous optimization is disabled      */
            isForceBookJob = false;
            //WSCH_AuditLogger.finish();
            return null;
        }
        Set<String> providersSet = new Set<String>();
        if(settingsGBL022 != null ) {
            for(String StrProvider : settingsGBL022.split(',')){
                providersSet.add(StrProvider.touppercase());
            }
            if(!(providersSet.contains('SERVICEPOWER') || providersSet.contains('SERVICE POWER'))) {
                /* 'GBL022 Setting is not set to Service Power. Please set it to Service Power to get the appointments' */
                strOfferApptErrorMsg = getTAG027();
                /*      Disable 'Send to Unresourced Tray' button when Service Provider is not ServicePower     */
                isForceBookJob = false;
                //WSCH_AuditLogger.finish();
                return null;
            }
        }
        
        if(System.currentPageReference().getParameters().get('woNumber') != null) {
            strWorkOrderID = System.currentPageReference().getParameters().get('woNumber');
        }
        
        if(System.currentPageReference().getParameters().get('workorderID') != null) {
            strWORecordID = System.currentPageReference().getParameters().get('workorderID');
        }
        WSCH_Provider_SP_RealTimeOptimizer.getSpURL('');
        if(System.currentPageReference().getParameters().get('spInstance') != null) {
            strSPInstance = System.currentPageReference().getParameters().get('spInstance');
        }
        if((strSPInstance == null) || (String.isBlank(strSPInstance))){
            strSPInstance = WSCH_Provider_SP_RealTimeOptimizer.strDefaultConnection;
        }
        
        /* set isDisplayCurrentAppt to true if there is already a current appointment on the WO along with the new list of appointments. */
        if(getCurrentAppointment(strWORecordID) != null) {
            isDisplayCurrentAppt = true;
        }
        
        /* Checks if the work order qualifies for book appointment , if already booked before. */
        SVMXC__Service_Order__c currWorkOrder = WSCH_CommonUtils.fetchWorkOrderById(strWORecordID);
        
        //get the Work Order businessHours
        List<BusinessHours> lstOfWOBusinessHour = getWOBusinessHours(currWorkOrder);
        if(lstOfWOBusinessHour != null && lstOfWOBusinessHour.size() > 0) {
            woBusinessHour = lstOfWOBusinessHour[0];
        }
        
        /*      Disable 'Send to Unresourced Tray' when the Work Order is already force booked*/
        if(currWorkOrder != null && String.isNotBlank(currWorkOrder.SVMXC__Scheduling_Change_Token__c) && currWorkOrder.SVMXC__Scheduling_Change_Token__c.equalsIgnoreCase('FORCE_SCHEDULE')) {
            isForceBookJob = false;
        }
        
        if(isWOValidToGetAppointments(currWorkOrder) != null) {
            strOfferApptErrorMsg = isWOValidToGetAppointments(currWorkOrder);
           //WSCH_AuditLogger.finish();
            return null;
        }
        
        //currWorkOrder.SVMXC__Optimizer_Connection_Name__c = strSPInstance;
        WSCH_Provider_SP_RealTimeOptimizer.mapWoConName = new Map<Id, String>();
        WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.put(currWorkOrder.id, strSPInstance);
        
        /* Get the limit value for displaying the technician slots from settings */
        Integer slotsSize = 99; //Default size.
        String settingsSlotSize = WSCH_CommonUtils.getSettingValue('DCON003','SET003');
        if(String.isNotBlank(settingsSlotSize)) {
            slotsSize = Integer.valueOf(settingsSlotSize) > WSCH_Constants.APPOINTMENT_SLOTS_MAX_SIZE ? WSCH_Constants.APPOINTMENT_SLOTS_MAX_SIZE : Integer.valueOf(settingsSlotSize);
        }
        //WSCH_AuditLogger.debug('WSCH_Provider_SP_Appointments_Calendar.mapWoConName: ' + WSCH_Provider_SP_RealTimeOptimizer.mapWoConName);
        //WSCH_AppointmentsResponse technicianSlotResponse = null;
        /* get the technician slots by sending workOrderID, size and the index */
        try {
            technicianSlotResponse = WSCH_OptimizedSchedulingService.getAvailableAppointments(strWORecordID, apptParamObj, slotsSize, 1);
            WSCH_AuditLogger.debug('After getAvailableAppointments() call, technicianSlotResponse - ' + technicianSlotResponse);
            if(technicianSlotResponse == null) {
                /* 'Exception occurred while making Offer Appointments call to SP' */
                strOfferApptErrorMsg = getTAG028();
                //WSCH_AuditLogger.finish();
                return null;
            }
        }catch(WSCH_Exception ex) {
            strOfferApptErrorMsg = getTAG028() + ex.getMessage();
            WSCH_AuditLogger.error('WSCH_Provider_SP_Appointments_Calendar::buildResponseData(): ' +ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            //WSCH_AuditLogger.finish();
            return null;
        }
        //WSCH_AuditLogger.finish();
        /* if the response is successful, get the technician slots */
        if(technicianSlotResponse.statusCode == 0) 
        {        
            WSCH_DefaultAppointmentHook hook = getAppointmentHook();
            WSCH_AuditLogger.debug('hook - ' + hook);
            Boolean isDefault = hook.canShowAppointmentsPage(currWorkOrder,technicianSlotResponse.appointmentList);
            //isDefault = false;
            if(isDefault)
            {
                /* This is required for viewing more appointments */
                displayViewMore = technicianSlotResponse.viewMore != null ? technicianSlotResponse.viewMore : displayViewMore;
                PageReference pageInstance  = pageLoad();
                
                if(pageInstance != null)
                {
                    pageInstance.setredirect(false);
                    //WSCH_AuditLogger.finish();
                    return pageInstance;
                    
                }
                
                /* This is required for viewing more appointments */
                //displayViewMore = technicianSlotResponse.viewMore != null ? technicianSlotResponse.viewMore : displayViewMore;
                
                lstOfTechnicianSlot = technicianSlotResponse.appointmentList;
                WSCH_AuditLogger.debug('If getAvailableAppts() is success, lstOfTechnicianSlot ' + lstOfTechnicianSlot);
                /* update the index for next list of appointments based on the size of current technician slot list */
                //nextAppointmentIndex = nextAppointmentIndex + lstOfTechnicianSlot.size();
                //eventsJson = createEventsJson(lstOfTechnicianSlot, woBusinessHour);
                eventsJson = createEventsJson(lstOfTechnicianSlot);
            }
            else
            {
                
                WSCH_DefaultAppointmentHook.ProcessWOActions action = hook.processWorkOrder();
                WSCH_AuditLogger.debug('action - ' + action);
                PageReference workOrderPage;
                //commented this class as we have the associated mehtod in the same class
                //WSCH_Provider_SP_WOApptsController objPrv_SP_WOApptsCntrl = new WSCH_Provider_SP_WOApptsController();
                if(action == WSCH_DefaultAppointmentHook.ProcessWOActions.FORCE_TO_UNRESOURCED)
                {
                    try
                    {
                        List<String> lstOfWOIds = new List<String>();
                        lstOfWOIds.add(strWORecordID);
                        List<SVMXC__Service_Order__c> scheduleWorkOrderList = WSCH_CommonUtils.fetchWorkOrders(lstOfWOIds);
                        
                        for(SVMXC__Service_Order__c workOrder: scheduleWorkOrderList) {
                            workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_PENDING;
                            workOrder.SVMXC__Scheduling_Change_Token__c = 'FORCE_SCHEDULE';
                        }
                        
                        WSCH_OptimizedSchedulingService.triggerExecuted = true;
                        WSCH_OptimizedSchedulingService.manageWorkOrders(scheduleWorkOrderList);
                        
                        //do not display the available appointments panel after foce book is executed
                        isBookApptSuccess = true;
                        
                        //after booking job navigate back to this Work Order page
                        //workOrderPage = objPrv_SP_WOApptsCntrl.navigateToWorkOrder();
                        //using local navigate method
                        workOrderPage = navigateToWorkOrder();
                        
                    }
                    catch(Exception ex) 
                    {
                        WSCH_AuditLogger.error('Exception caught:WSCH_Provider_SP_Appointments_Calendar:buildResponseData()::action is forcebook ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
                    }
                    
                }
                else if(action == WSCH_DefaultAppointmentHook.ProcessWOActions.BOOK_SLA_JOB)
                {
                    try
                    {
                        List<String> lstOfWOIds = new List<String>();
                        lstOfWOIds.add(strWORecordID);
                        List<SVMXC__Service_Order__c> scheduleWorkOrderList = WSCH_CommonUtils.fetchWorkOrders(lstOfWOIds);
                        
                        for(SVMXC__Service_Order__c workOrder: scheduleWorkOrderList) {
                            workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_PENDING;
                            workOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CREATE_WO';
                        }
                        
                        WSCH_OptimizedSchedulingService.triggerExecuted = true;
                        WSCH_OptimizedSchedulingService.manageWorkOrders(scheduleWorkOrderList);
                        
                        //do not display the available appointments panel after foce book is executed
                        isBookApptSuccess = true;
                        
                        //after booking job navigate back to this Work Order page
                        //workOrderPage = objPrv_SP_WOApptsCntrl.navigateToWorkOrder();
                        //using local naviate method
                        workOrderPage = navigateToWorkOrder();
                        
                    }
                    catch(Exception ex) 
                    {
                        WSCH_AuditLogger.error('Exception caught:WSCH_Provider_SP_Appointments_Calendar:buildResponseData()::action is SLA Job ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
                    }
                    //return hook.displayErrorPage();
                }
                //WSCH_AuditLogger.finish();
                return hook.displayCustomPage();
                
            }
        }
        else 
        {
            //enable force booking if no appointments are returned
            isForceBookJob = true;
            //if there are no technician slots, set the response data string to null
            eventsJson = null;
            //and set the error message
            strOfferApptErrorMsg = technicianSlotResponse.statusMessage;
        }
        //Commiting the logs to Audit Logger.
        //WSCH_AuditLogger.finish();
        return null;
    }
    
    /**  This method books an appointment selected by the User for a Work Order  **/
    public PageReference bookAppointment() {
        
        WSCH_AuditLogger.debug('Inside bookAppointment() call ');
        WSCH_CommonUtils.putGlobalUtilValMap('isCalendarBooking','true');
        PageReference workOrderPage;
        workOrderPage = navigateToWorkOrder();
        
        String strHorizonStartGmtDt, strHorizonEndGmtDt;
        strBookApptSuccessMsg = null;
        isBookApptExecuted = true;
        /* get the selected row data using the event Id selected from appointments UI */
        WSCH_Appointment technicianSlot = lstOfTechnicianSlot.get(Integer.valueOf(selectedRowId));
        Datetime startDateTimeUsr = technicianSlot.getStartDateTime();
        String strStartTimeUsr = startDateTimeUsr.formatGmt('HH:mm');
        WSCH_AuditLogger.debug('Inside bookAppointment(), startDateTimeUsr - ' + startDateTimeUsr);
        DateTime startDateTimeGmt = WSCH_DateUtils.doTZConversion(startDateTimeUsr, strTimeZone, 'GMT',technicianSlot.getIntTimeZoneOffset());
        String strDate = startDateTimeGmt.formatGmt('yyyy-MM-dd');
        WSCH_AuditLogger.debug('converted strDate - ' + strDate);
        String strStartTime = startDateTimeGmt.formatGmt('HH:mm');
        WSCH_AuditLogger.debug('converted strStartTime - ' + strStartTime);        
        
        Datetime endDateTimeUsr = technicianSlot.getEndDateTime();
        String strEndTimeUsr = endDateTimeUsr.formatGmt('HH:mm');
        WSCH_AuditLogger.debug('Inside bookAppointment(), endDateTimeUsr - ' + endDateTimeUsr);
        DateTime endDateTimeGmt = WSCH_DateUtils.doTZConversion(endDateTimeUsr, strTimeZone, 'GMT',technicianSlot.getIntTimeZoneOffset());
        String strEndTime = endDateTimeGmt.formatGmt('HH:mm');
        //String strDay = getWeekDay().get(technicianSlot.getDay());
        SVMXC__Service_Order__c workOrder = WSCH_CommonUtils.fetchWorkOrderById(strWORecordID);
        
        workOrder.SVMXC__Optimizer_Connection_Name__c = strSPInstance;
        WSCH_Provider_SP_RealTimeOptimizer.mapWoConName = new Map<Id, String>();
        //WSCH_AuditLogger.debug('bookAppointment:workOrder.id: ' + workOrder.id + ' strSPInstance: ' + strSPInstance);
        WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.put(workOrder.id, strSPInstance);
        
        //setting the Horizon start and end date as same date, as there is no early arrival option for book appt
        strHorizonStartGmtDt = strDate;
        strHorizonEndGmtDt = strDate;
        
        //strore the old booked_slot value in a static variable
        if(String.isNotEmpty(workOrder.SVMXC__Booked_Appointment_Slot__c)) {
            WSCH_Provider_SP_Appointments_Calendar.strOldApptBookedSlot = String.valueOf(workOrder.SVMXC__Booked_Appointment_Slot__c);
        }
        
        //store the booked slot on the WO field SVMXC__Booked_Appointment_Slot__c
        workOrder.SVMXC__Booked_Appointment_Slot__c = String.format('{0} - {1}, {2}, {3}', new List<String>{strStartTimeUsr, strEndTimeUsr, technicianSlot.getDay(), startDateTimeUsr.formatGmt('yyyy-MM-dd')});
        
        //store the old appointment_promise_slot value in a static variable
        WSCH_Provider_SP_Appointments_Calendar.strOldApptPromiseSlot = String.valueOf(workOrder.SVMXC__Appointment_Promised_Time_Slot__c);
        
        //boolean is set to distinguish whether the call is initiated from bookAppt or bookJob. BookAppt is true and bookJob is false
        workOrder.SVMXC__Appointment_Promised_Time_Slot__c = String.format(' {0} - {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}', new List<String>{strStartTime, strEndTime, technicianSlot.getDay(), strDate, 'true', strHorizonStartGmtDt, strHorizonEndGmtDt, String.valueOf(technicianSlot.getIntTimeZoneOffset()), startDateTimeGmt.formatGMT('yyyy-MM-dd HH:mm:ss'), endDateTimeGmt.formatGMT('yyyy-MM-dd HH:mm:ss')});
        workOrder.SVMXC__Scheduling_Change_Token__c='CHANGE_CREATE_WO';
        WSCH_AuditLogger.debug('workOrder.SVMXC__Appointment_Promised_Time_Slot__c - ' + workOrder.SVMXC__Appointment_Promised_Time_Slot__c);
        WSCH_AuditLogger.debug('Before WSCH_OptimizedSchedulingService.bookAppointment() call');
        
        WSCH_AppointmentsResponse techSlotResponse = null;
        try {
            
            /*Dependency_Management__c depManagementRecord = new Dependency_Management__c();
            List<Service_Order_Dependency__c> reBookDependencyGroupList = new List<Service_Order_Dependency__c>();
            if(workOrder.SVMXC__Dependency_Group__c != null){             
            depManagementRecord = [SELECT Id, Name from Dependency_Management__c where Id =: workOrder.SVMXC__Dependency_Group__c];               
            List<Service_Order_Dependency__c> dependencyGroupList = WSCH_CommonUtils.fetchGroupDependency(depManagementRecord.Name);                
            for(Service_Order_Dependency__c dependencyGroup: dependencyGroupList){
            if(!(dependencyGroup.SVMXC__Primary_Work_Order__c == workOrder.Id ||dependencyGroup.SVMXC__Secondary_Work_Order__c == workOrder.Id)){
            reBookDependencyGroupList.add(dependencyGroup);
            }
            }
            }
            if(reBookDependencyGroupList != null){
            WSCH_OptimizedSchedulingService.manageDependencyGroup(depManagementRecord.Name, reBookDependencyGroupList);
            }
            workOrder.SVMXC__Dependency_Group__c = null;*/
            
            techSlotResponse = WSCH_OptimizedSchedulingService.bookAppointment(workOrder, technicianSlot);
            if((WSCH_Provider_SP_RealTimeOptimizer.lstTerrUpd != null) && (!WSCH_Provider_SP_RealTimeOptimizer.lstTerrUpd.isEmpty())){
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( WSCH_Provider_SP_RealTimeOptimizer.lstTerrUpd, COMM_SecurityUtils.Access.Updateable) ) {
                    Database.update(WSCH_Provider_SP_RealTimeOptimizer.lstTerrUpd);
                }
            }
            if(techSlotResponse == null) {
                /* 'Exception occurred while making Book Appointment call to SP' */
                strBookApptErrorMsg = getTAG029();
                isBookApptFailed = true;
                isDisplayCurrentAppt = false;   //added to hide current appt when bookAppt timeout ex occurs
                WSCH_AuditLogger.finish();
                return workOrderPage;
            }
        }catch(WSCH_Exception ex) {
            strBookApptErrorMsg = getTAG029();
            isBookApptFailed = true;
            isDisplayCurrentAppt = false;   //added to hide current appt when bookAppt ex occurs
            WSCH_AuditLogger.error('Exception caught:WSCH_Provider_SP_Appointments_Calendar:bookAppointment()::' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            return workOrderPage;
        }
        
        SVMXC__Service_Order__c workOrderBooked = WSCH_CommonUtils.fetchWorkOrderById(strWORecordID);
        if(techSlotResponse.statusCode == 0) {
            strBookApptErrorMsg = null;
            isBookApptSuccess = true;
            /* if appointment is booked successfully, do not display the previously booked appointment in case if there is any */
            isDisplayCurrentAppt = false;
            currentAppointment = technicianSlot;
            WSCH_AuditLogger.debug('Inside bookAppointment(), currentAppointment.getStartDateTime()- ' + currentAppointment.getStartDateTime());
            WSCH_AuditLogger.debug('Inside bookAppointment(), currentAppointment.getEndDateTime()- ' + currentAppointment.getEndDateTime());
            //eventsJson = createEventsJson(lstOfTechnicianSlot, woBusinessHour);
            eventsJson = createEventsJson(lstOfTechnicianSlot);
            if(workOrderBooked.SVMXC__Scheduled_Date_Time__c != null && String.isNotBlank(workOrder.SVMXC__Appointment_Promised_Time_Slot__c)) {
                
                //"strStartTime - strEndTime, strDay, strDate, 'true', strHorizonStartGmtDt, strHorizonEndGmtDt"
                String[] apptPromiseSlotArray = workOrder.SVMXC__Appointment_Promised_Time_Slot__c.split(',',9);
                if(apptPromiseSlotArray != null && apptPromiseSlotArray.size() == 9) {
                    
                    String[] startEndTimeSplit = apptPromiseSlotArray[0].split('-');
                    String startTimeGmt = startEndTimeSplit[0].trim();
                    String endTimeGmt = startEndTimeSplit[1].trim();
                    
                    startDateTimeGMT = WSCH_DateUtils.parseDateTimeNew(apptPromiseSlotArray[2] + ' ' + startTimeGmt + ':00');
                    WSCH_AuditLogger.debug('bookAppointment::startDateTimeGMT '+startDateTimeGMT);
                    
                    startDateTimeUsr = WSCH_DateUtils.doTZConversion(startDateTimeGMT, 'GMT', strTimeZone, -1*Integer.valueOf(apptPromiseSlotArray[6].trim()));
                    WSCH_AuditLogger.debug('bookAppointment::startDateTimeUsr '+startDateTimeUsr);
                    String strStartDate = startDateTimeUsr.formatGmt('yyyy-MM-dd');
                    strStartTime = startDateTimeUsr.formatGmt('HH:mm');
                    WSCH_AuditLogger.debug('bookAppointment::strStartTime '+strStartTime);
                    
                    endDateTimeGMT = WSCH_DateUtils.parseDateTimeNew(apptPromiseSlotArray[2] + ' ' + endTimeGmt + ':00');
                    WSCH_AuditLogger.debug('bookAppointment::endDateTimeGMT '+endDateTimeGMT);
                    
                    endDateTimeUsr = WSCH_DateUtils.doTZConversion(endDateTimeGMT, 'GMT', strTimeZone, -1*Integer.valueOf(apptPromiseSlotArray[6].trim()));
                    WSCH_AuditLogger.debug('bookAppointment::endDateTimeUsr '+endDateTimeUsr);
                    strEndTime = endDateTimeUsr.formatGmt('HH:mm');
                    WSCH_AuditLogger.debug('getCurrentAppointment::strEndTime '+strEndTime);
                    
                    //Getting the date as per user locale
                    String strDateAsPerLocale = startDateTimeUsr.dateGmt().format();
                    
                    strBookApptSuccessMsg = String.format('{0} {1}, {2}, {3}.', new List<String>{getTAG001(), strStartTime + ' - ' + strEndTime, getWeekDay().get(apptPromiseSlotArray[1].trim()), strDateAsPerLocale });
                    bookedTimings = String.format('{0}, {1}, {2}.', new List<String>{strStartTime + ' - ' + strEndTime, getWeekDay().get(apptPromiseSlotArray[1].trim()), strDateAsPerLocale });
                }
            } else {
                strBookApptSuccessMsg = workOrderBooked.SVMXC__OptiMax_Error_Text__c;
            }
        } else {
            /* if the bookAppointment() fails, set the error message */
            strBookApptSuccessMsg = null;
            strBookApptErrorMsg = techSlotResponse.statusMessage;
            isBookApptFailed = true;
        }
        
        //To display technician name and Book timings in cancel pop up.
        //bookedTimings = workOrder.SVMXC__Appointment_Promised_Time_Slot__c;
        
        /*if(workOrder.SVMXC__Appointment_Promised_Time_Slot__c != null && String.isNotBlank(workOrder.SVMXC__Appointment_Promised_Time_Slot__c)) {
        //"strStartTime - strEndTime, strDay, strDate, 'true', strHorizonStartGmtDt, strHorizonEndGmtDt"
        String[] apptPromiseSlotArray = workOrder.SVMXC__Appointment_Promised_Time_Slot__c.split(',',9);
        
        //Getting the date as per user locale
        DateTime dateTimeGmt = WSCH_DateUtils.parseDateTimeNew(strDate + ' ' + strStartTime + ':00');
        DateTime dateTimeUsr = WSCH_DateUtils.doTZConversion(dateTimeGmt, 'GMT', strTimeZone);
        String strDateAsPerLocale = dateTimeUsr.dateGmt().format();
        if(apptPromiseSlotArray != null && apptPromiseSlotArray.size() == 9) {
        bookedTimings = String.format('{0}, {1}, {2}.', new List<String>{apptPromiseSlotArray[0], getWeekDay().get(apptPromiseSlotArray[1].trim()), strDateAsPerLocale});
        }
        }*/
        
        if(workOrderBooked.SVMXC__Group_Member__c != null) {
            bookedTechnician = WSCH_CommonUtils.fetchTechnicianById(workOrderBooked.SVMXC__Group_Member__c).Name;
        }
        
        /* Commiting the logs to Audit Logger. */
        WSCH_AuditLogger.finish();
        return workOrderPage;
    }
    
    
    /*
        Following method checks if the work order is already booked once and if so verifies whether the work order now qualifies for book appointment.
        The verification done on the basis of following three steps.
        1. The work order is not fixed and dispatch process is not null.Then If Dispatch process belongs to Service power.
        If different from Service Power returns error message.
        2. If Scheduling status is not null , checks if it is other than Tentetive . If found so returns error message.
        3. Checks if Optimax status is OPT_PENDING. If so it returns error message.
        */
    public String isWOValidToGetAppointments(SVMXC__Service_Order__c currWorkOrder) {
        
        WSCH_AuditLogger.debug('Inside isWOValidToGetAppointments() - before qualification logic');
        boolean isExecutedOnce = false;
        /* Logic to check the valid dispatch process. */
        if(currWorkOrder != null && currWorkOrder.SVMXC__Locked_By_DC__c != true && currWorkOrder.SVMXC__Dispatch_Process__c != NULL){
            Map<Id,SVMXC__ServiceMax_Processes__c> svmxProcessMap = WSCH_CommonUtils.getContinuousDP();
            if(!svmxProcessMap.ContainsKey(currWorkOrder.SVMXC__Dispatch_Process__c)) {
                WSCH_AuditLogger.debug('Inside if dispatchProcess is not Continuous Optimization');
                /* 'Work order is already qualified for a dispatch process of different service provider other than Service Power.' */
                strOfferApptErrorMsg = getTAG030();
                /*      Disable 'Send to Unresourced Tray' button when Dispatch Process is not Continuous Optimization  */
                isForceBookJob = false;
                isExecutedOnce = true;
            }
        }
        
        if(!isExecutedOnce && currWorkOrder.SVMXC__Work_Order_Scheduling_Status__c != null) {
            if(!('Tentative'.equalsIgnoreCase(currWorkOrder.SVMXC__Work_Order_Scheduling_Status__c)) && 
               !('Cancelled'.equalsIgnoreCase(currWorkOrder.SVMXC__Work_Order_Scheduling_Status__c))) {
                   /* 'No appointments as this Work Order has already been dispatched' */
                   strOfferApptErrorMsg = getTAG031();
                   isExecutedOnce = true;
               }
        }
        
        
        if(!isExecutedOnce && currWorkOrder.SVMXC__OptiMax_Status__c != null && WSCH_Constants.STATUS_OPT_PENDING.equalsIgnoreCase(currWorkOrder.SVMXC__OptiMax_Status__c)) {
            /* 'No appointments as this Work Order is already in the process to be booked' */
            strOfferApptErrorMsg = getTAG032();
            isExecutedOnce = true;
        }
        
        if(currWorkOrder.SVMXC__Dependency_Group__c != null){
            strOfferApptErrorMsg = system.label.DCON003_TAG092;
            isEnableUnresourcedTray = false;
            isEnableCancelAppt = false;
        }
        return strOfferApptErrorMsg;
    }
    
    public Map<String,String> getWeekDay() {
        return mapOfWeekDays;
    }
    
    public boolean getIsWOApptEmpty() {
        
        system.debug(logginglevel.warn,'eventsJson: '+eventsJson+'  '+strXMLData);
        if((eventsJson == null || eventsJson == '[]') && (strXMLData == null || strXMLData == '')) {
            return true;
        } else if((eventsJson != null || eventsJson != '[]' || strXMLData != null || strXMLData != '') && (isBookApptExecuted && isBookApptFailed)) {
            return true;    // This is the case when book appointment has executed, but failed
        } else {
            return false;
        }
        
    }
    
    /*public boolean getIsMoreApptEmpty() {

    if(eventsJson != null && (isViewMoreApptExecuted == true && isViewMoreApptFailed == true)) {
    return true;
    } else {
    return false;
    }
    }*/
    
    public boolean getIsBookApptFailure() {
        
        boolean temp;
        if(eventsJson != null && (isBookApptExecuted == false && isBookApptFailed == false)) {
            temp = false;
        } else if(eventsJson != null && (isBookApptExecuted == true && isBookApptFailed == false)) {
            temp = false;
            isBookApptSuccess = true;
        } else if(eventsJson != null && (isBookApptExecuted == true && isBookApptFailed == true)) {
            temp = true;
            isBookApptSuccess = false;
        } else if(eventsJson == null && (isBookApptExecuted = false && isBookApptFailed == false)) {
            temp = false;
            isBookApptSuccess = false;
        }
        return temp;
    }
    
    public boolean getIsBookApptSuccess() {
        
        if(eventsJson != null && (isBookApptExecuted == true && isBookApptFailed == false)) {
            return true;
        } else if(eventsJson != null && (isBookApptExecuted == true && isBookApptFailed == true)) {
            return true;    //changed from false to true when bookAppt is executed, but failed
        } else if(eventsJson == null && (isBookApptExecuted = false && isBookApptFailed == false)){
            return false;
        } else if(isForceBookJob && isDisplayForceBookMsg) {
            return true;
        } else {
            return false;
        }
    }
    
    public static List<BusinessHours> getWOBusinessHours(SVMXC__Service_Order__c workOrder) {
        
        List<BusinessHours> lstOfBusinessHours;
        if(workOrder.SVMXC__Preferred_Business_Hours__c != null) {
            lstOfBusinessHours = getBusinessHoursById(workOrder.SVMXC__Preferred_Business_Hours__c);
        } else {
            lstOfBusinessHours = getBusinessHoursByWO(workOrder);
        }
        
        return lstOfBusinessHours;
    }
    
    public static List<BusinessHours> getBusinessHoursByWO(SVMXC__Service_Order__c workOrder) {
        List<BusinessHours> lstOfBusinessHours;
        boolean isfound=false;
        try{
            if(workOrder.SVMXC__SLA_Terms__c != null) {
                List<SVMXC__Service_Level__c> slaList = new List<SVMXC__Service_Level__c>();
                slaList=[SELECT SVMXC__Business_Hours__c,Id FROM SVMXC__Service_Level__c WHERE Id =: workOrder.SVMXC__SLA_Terms__c];
                if(slaList[0].SVMXC__Business_Hours__c != null){
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_Appointments_Calendar::getBusinessHoursByWO:: SLA Business Hr : '+slaList[0].SVMXC__Business_Hours__c);
                    lstOfBusinessHours=getBusinessHoursById(slaList[0].SVMXC__Business_Hours__c);
                    isfound=true;
                }
            }
            
            if(!isfound && workOrder.SVMXC__Service_Contract__c != null){
                SVMXC__Service_Contract__c serviceContr = [SELECT Id,SVMXC__Active__c,SVMXC__Business_Hours__c FROM SVMXC__Service_Contract__c WHERE Id =: workOrder.SVMXC__Service_Contract__c AND SVMXC__Active__c = true];
                if(serviceContr != null && serviceContr.SVMXC__Business_Hours__c != null){
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_Appointments_Calendar::getBusinessHoursByWO:: Contract Business Hr : '+serviceContr.SVMXC__Business_Hours__c);
                    lstOfBusinessHours=getBusinessHoursById(serviceContr.SVMXC__Business_Hours__c);
                    isfound=true;
                }
            }
            
            if(!isfound && workOrder.SVMXC__Primary_Territory__c != null) {
                SVMXC__Territory__c territory = [SELECT Id,SVMXC__Territory_s_Business_Hours__c FROM SVMXC__Territory__c WHERE Id =: workOrder.SVMXC__Primary_Territory__c];
                if(territory != null && territory.SVMXC__Territory_s_Business_Hours__c != null){
                    //WSCH_AuditLogger.debug('WSCH_Provider_SP_Appointments_Calendar::getBusinessHoursByWO:: Territory Business Hr : '+territory.SVMXC__Territory_s_Business_Hours__c);
                    lstOfBusinessHours=getBusinessHoursById(territory.SVMXC__Territory_s_Business_Hours__c);
                    isfound=true;
                }
            }
            
            if(lstOfBusinessHours == null){
                //fetch default business hour
                lstOfBusinessHours = [SELECT Id,IsActive,IsDefault,TimeZoneSidKey,MondayStartTime,MondayEndTime,
                                      TuesdayStartTime,TuesdayEndTime,WednesdayStartTime,WednesdayEndTime,
                                      ThursdayStartTime,ThursdayEndTime,FridayStartTime,FridayEndTime,SaturdayStartTime,
                                      SaturdayEndTime,SundayStartTime,SundayEndTime FROM BusinessHours
                                      WHERE IsDefault = TRUE AND IsActive = TRUE];
                WSCH_AuditLogger.debug('WSCH_Provider_SP_Appointments_Calendar::getBusinessHoursByWO:: Default Business Hr : '+lstOfBusinessHours[0]);              
            }
        }catch(Exception ex){
            String exceptionMsg = 'WSCH_Provider_SP_Appointments_Calendar :: getBusinessHoursByWO() :: ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return lstOfBusinessHours;
    }
    
    /**
        Following method creates the Json string required for the displaying calendar view from appointment list.
        **/
    //public String createEventsJson(List<WSCH_Appointment> lstTechnicianSlot, BusinessHours woBusinessHour) {
    public static String getTAG161() {
        return system.label.DCON001_TAG161;     //Email
    }
    
    public static String getTAG117() {
        return system.label.IPAD018_TAG117;     //Name
    }
    public static String getTAG118() {
        return system.label.CONF027_TAG011;     //Zip
    }
    
    public String createEventsJson(List<WSCH_Appointment> lstTechnicianSlot) {
        isOutsideSLA = false;
        WSCH_AuditLogger.debug('Inside createEventsJson()');
        
        WSCH_AuditLogger.debug('localeDateTimeFormat - ' + localeDateTimeFormat);
        JSONGenerator jsonGenerator = JSON.createGenerator(true);
        try{
            jsonGenerator.writeStartArray();
            DateTime minStartDate, startDateTimeGMT,endDateTimeGMT, currApptStartDateTimeUsr, currApptEndDateTimeUsr;
            
            SMAX_OptiMax_Engine_Ext optExt = new SMAX_OptiMax_Engine_Ext();
            
            //Adding current Appointment if exists.
            if (currentAppointment != null && String.isNotBlank(currentAppointment.getStrStartDateTime())) {
                lstOfTechnicianSlot.add(currentAppointment);
                currApptStartDateTimeUsr = currentAppointment.getStartDateTime();
                currApptEndDateTimeUsr = currentAppointment.getEndDateTime();
                WSCH_AuditLogger.debug('createEventsJson()::currentAppointment '+currentAppointment);
                WSCH_AuditLogger.debug('createEventsJson()::getStrStartDateTime '+currentAppointment.getStrStartDateTime());
            }
            
            
            SVMXC__Service_Order__c currentWO = WSCH_CommonUtils.fetchWorkOrderById(strWORecordID);
            integer appointmentIndex=-1;
            if(currentAppointment.getStartDateTime() != null){
                for(Integer index = 0; index < lstTechnicianSlot.size()-1; index ++) {
                    if(currentWO.SVMXC__Appointment_Promised_Time_Slot__c != null){
                        if((lstOfTechnicianSlot[index].getStartDateTime()) == currentAppointment.getStartDateTime()){
                            appointmentIndex = index;
                        }
                    }
                    else if(currentWO.SVMXC__Appointment_Promised_Time_Slot__c == null){
                        if(lstOfTechnicianSlot[index].getStartDateTime() == currentAppointment.getStartDateTime()) {
                            break;
                        }
                        else if(lstOfTechnicianSlot[index].getStartDateTime() != currentAppointment.getStartDateTime() && index == lstOfTechnicianSlot.size()-2){
                            lstOfTechnicianSlot.remove(lstOfTechnicianSlot.size()-1);
                        }               
                    }             
                }
            }       
            
            
            Set<Id> techIds = new Set<Id>();
            for(Integer index = 0; index < lstTechnicianSlot.size(); index ++){
                if(lstTechnicianSlot[index].getTechnician() != null){
                    techIds.add(lstTechnicianSlot[index].getTechnician().Id);
                }
            }
            //System.debug(logginglevel.ERROR,'****DCON003_SET0004 ' + String.valueof(WSCH_CommonUtils.getSettingValue('DCON003','SET004')));
            //String strtechFieldSetting = String.valueof(WSCH_CommonUtils.getSettingValue('DCON003','SET004'));
            //String strtechFieldSetting = 'Name,TAG161:SVMXC__Email__c,SVMXC__Zip__c,SVMXC__Service_Group__c,SVMXC__Service_Territory__c,SVMXC__Member_information__c';
            Map<Id, SVMXC__Service_Group_Members__c> mapTechIds = new Map<Id, SVMXC__Service_Group_Members__c>();    
            Map<String, String> referenceMap = new Map<String, String>();     
            String commaSeperatedFields= '';       
            String uniqueFieldApiNames= '';
            
            if(String.isNotBlank(strtechFieldSetting)){
                //ApexClass cs =[select NamespacePrefix from ApexClass where Name =:'WSCH_Provider_SP_Appointments_Calendar' ];
                List<String> tempStr = strtechFieldSetting.split(',',0);               
                Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.SVMXC__Service_Group_Members__c.fields.getMap();
                //String replacableText = cs.NamespacePrefix + '__';
                List<String> objectNames = new List<String>();
                List<String> referenceObjects = new List<String>();
                for(integer i=0; i < tempStr.size(); i++){
                    WSCH_AuditLogger.debug('tempStr'+tempStr);
                    List<String> tempBreakString = tempStr[i].split(':');
                    if(tempBreakString.size()==2){
                        String strTechField = tempBreakString[1].trim();//.replace(replacableText,'');
                        
                        
                        if(fieldMap.containskey(strTechField)){                    
                            String fieldType = String.ValueOf(fieldMap.get(strTechField).getDescribe().getType());
                            if(fieldType == 'REFERENCE'){
                                String sObjectName = String.ValueOf(fieldMap.get(strTechField).getDescribe().getReferenceTo());
                                sObjectName = sObjectName.replace('(','');
                                sObjectName = sObjectName.replace(')','');
                                referenceObjects.add(String.valueof(sObjectName));
                                objectNames.add(tempBreakString[1].trim());
                            }
                            if(fieldType != 'encryptedstring' && fieldType != 'TextArea' && tempBreakString[1].trim()!= '' && fieldMap.containskey(tempBreakString[1].trim())){
                                if(commaSeperatedFields == ''){
                                    uniqueFieldApiNames = tempBreakString[1].trim();
                                    commaSeperatedFields = tempBreakString[1].trim();
                                }
                                else{
                                    if(!commaSeperatedFields.contains(strTechField)){
                                        uniqueFieldApiNames = uniqueFieldApiNames + ',' + tempBreakString[1].trim();
                                    }
                                    commaSeperatedFields = commaSeperatedFields + ',' + tempBreakString[1].trim();
                                }
                            }
                        }
                    }
                    else if(tempBreakString.size()==1){
                        String strTechField = tempBreakString[0].trim();//.replace(replacableText,'');
                        
                        if(fieldMap.containskey(strTechField)){
                            String fieldType = String.ValueOf(fieldMap.get(strTechField).getDescribe().getType());
                            if(fieldType == 'REFERENCE'){
                                String sObjectName = String.ValueOf(fieldMap.get(strTechField).getDescribe().getReferenceTo());
                                sObjectName = sObjectName.replace('(','');
                                sObjectName = sObjectName.replace(')','');
                                referenceObjects.add(String.valueof(sObjectName));
                                objectNames.add(tempBreakString[0].trim());
                            }
                            if(fieldType != 'encryptedstring' && fieldType != 'TextArea' && tempBreakString[0].trim()!= '' && fieldMap.containskey(tempBreakString[0].trim())){
                                if(commaSeperatedFields ==''){
                                    uniqueFieldApiNames = tempBreakString[0].trim();
                                    commaSeperatedFields = tempBreakString[0].trim();
                                }
                                else{
                                    if(!commaSeperatedFields.contains(strTechField)){
                                        uniqueFieldApiNames = uniqueFieldApiNames + ',' + tempBreakString[0].trim();
                                    }    
                                    commaSeperatedFields = commaSeperatedFields + ',' + tempBreakString[0].trim();
                                }
                            }
                        }
                    }
                }
                WSCH_AuditLogger.debug('commaSeperatedFields'+commaSeperatedFields);
                WSCH_AuditLogger.debug('uniqueFieldApiNames'+uniqueFieldApiNames);
                if(commaSeperatedFields != ''){
                    
                    List<String> valName = new List<String>();
                    String techQuery = 'SELECT '+uniqueFieldApiNames+' from SVMXC__Service_Group_Members__c where Id in: '+'techIds';
                    SVMXC__Service_Group_Members__c[] techData = Database.query(techQuery);
                    List<String> referenceIds = new List<String>();
                    Set<String> mySet = new Set<String>();
                    
                    List<String> allReferenceObjects = new List<String>();
                    for(integer i=0; i<techData.size();i++){
                        for(integer j=0;j<referenceObjects.size();j++){
                            mySet.addAll(referenceIds);
                            if(!mySet.contains(String.valueof(techdata[i].get(objectNames[j])))){
                                if(String.valueof(techdata[i].get(objectNames[j]))!=null){
                                    referenceIds.add(String.valueof(techdata[i].get(objectNames[j])));
                                    allReferenceObjects.add(referenceObjects[j]);
                                }
                            }
                        }
                    }
                    for(integer i=0;i<referenceIds.size();i++){
                        String str = referenceIds[i];
                        String referenceQuery = 'SELECT Name from '+ allReferenceObjects[i] +' where Id =: str';
                        System.debug('referenceQuery '+referenceQuery );
                        sObject testquery = Database.query(referenceQuery);
                        referenceMap.put(referenceIds[i],String.valueof(testquery.GET('Name')));
                        WSCH_AuditLogger.debug('testQuery'+testQuery);
                    }
                    
                    for(integer i=0;i<techData.size();i++){
                        mapTechIds.put(techData[i].Id,techData[i]);
                    }
                }
                
            }
            
            SVMXC__Service_Order__c currWorkOrder = WSCH_CommonUtils.fetchWorkOrderById(strWORecordID);
            for(Integer index = 0; index < lstTechnicianSlot.size(); index ++) {
                
                if(index != appointmentIndex){
                    WSCH_Appointment technicianSlot = lstOfTechnicianSlot.get(index);
                    Datetime startDateTimeUsr = technicianSlot.getStartDateTime();
                    WSCH_AuditLogger.debug('createEventsJson(), startDateTime - ' + startDateTimeUsr);
                    WSCH_AuditLogger.debug('createEventsJson(), strTimeZone - ' + strTimeZone);
                    startDateTimeGMT = WSCH_DateUtils.doTZConversion(startDateTimeUsr, strTimeZone, 'GMT', technicianSlot.getIntTimeZoneOffset());
                    
                    //checking if the slot date is a Holiday or not for this business hour
                    //If it is Holiday, do not add this slot info for JSON Event
                    /*Date slotDateGmt = startDateTimeGMT.DateGMT();
WSCH_AuditLogger.debug(' slotDateGmt - ' + slotDateGmt);
if(!optExt.isWorkingDay(woBusinessHour, slotDateGmt)) {
WSCH_AuditLogger.debug(slotDateGmt + ' is a holiday');
continue;
}*/
                    
                    //String strStartTime = startDateTimeUsr.formatGmt('hh:mm a');
                    /*String strDate = startDateTimeGMT.dateGmt().format();      //gets the date as per user locale to display in UI
String strStartDateTimeUsr = startDateTimeGMT.format(); //output will be 2/13/2015 6:03 PM
String strStartTime = strStartDateTimeUsr.replace(strDate,'').trim(); //output will be 6:03 PM*/
                    
                    //converting the start dateTime as per user locale
                    //String strStartDateTimeUsr = startDateTimeUsr.format();   //output will be 2/13/2015 6:03 PM
                    String strDate = startDateTimeUsr.dateGmt().format();  //output will be 2/13/2015
                    //String strStartTime = strStartDateTimeUsr.replace(strDate,'').trim(); //output will be 6:03 PM
                    String strStartTime = startDateTimeUsr.formatGmt('hh:mm a');
                    
                    WSCH_AuditLogger.debug('strDate - ' + strDate);
                    //WSCH_AuditLogger.debug('strStartDateTimeUsr - ' + strStartDateTimeUsr);
                    WSCH_AuditLogger.debug('createEventsJson(), strStartTime - ' + strStartTime);
                    
                    Datetime endDateTimeUsr = technicianSlot.getEndDateTime();
                    WSCH_AuditLogger.debug('createEventsJson(), EndDateTime - ' + endDateTimeUsr);
                    String strEndTime;
                    if(endDateTimeUsr != null){
                        endDateTimeGMT = WSCH_DateUtils.doTZConversion(endDateTimeUsr, strTimeZone, 'GMT', technicianSlot.getIntTimeZoneOffset());
                        //strEndTime = endDateTimeUsr.formatGmt('hh:mm a');             
                        /*String strEndDateTimeUsr = endDateTimeGMT.format();   //output will be 2/13/2015 6:03 PM
String strEndDate = endDateTimeGMT.dateGmt().format(); //output will be 2/13/2015
strEndTime = strEndDateTimeUsr.replace(strEndDate,'').trim(); //output will be 6:03 PM*/
                        
                        //converting the end dateTime as per user locale
                        //String strEndDateTimeUsr = endDateTimeUsr.format();   //output will be 2/13/2015 6:03 PM
                        //String strEndDate = endDateTimeUsr.dateGmt().format();   //output will be 2/13/2015
                        //strEndTime = strEndDateTimeUsr.replace(strEndDate,'').trim(); //output will be 6:03 PM
                        strEndTime = endDateTimeUsr.formatGmt('hh:mm a');
                        
                        WSCH_AuditLogger.debug('strEndTime - ' + strEndTime);            
                    }
                    
                    //convert the datetime from technician timezone to GMT using the BusinessHr timezone
                    //DateTime startDateTimeGMT2 = WSCH_DateUtils.doTZConversion(startDateTimeUsr, woBusinessHour.TimeZoneSidKey, 'GMT', technicianSlot.getIntTimeZoneOffset());
                    //DateTime endDateTimeGMT2 = WSCH_DateUtils.doTZConversion(endDateTimeUsr, woBusinessHour.TimeZoneSidKey, 'GMT', technicianSlot.getIntTimeZoneOffset());
                    
                    //checking if the slot date is a Holiday or not for this business hour
                    //If it is Holiday, do not add this slot info for JSON Event
                    /*if(!Businesshours.isWithin(woBusinessHour.Id, startDateTimeGMT) || !Businesshours.isWithin(woBusinessHour.Id, endDateTimeGMT)) {
WSCH_AuditLogger.debug(startDateTimeGMT + ' is a holiday');
WSCH_AuditLogger.debug(endDateTimeGMT + ' is a holiday');
continue;
}*/
                    
                    WSCH_AuditLogger.debug('createEventsJson(), strEndTime - ' + strEndTime);
                    String strDay = getWeekDay().get(technicianSlot.getDay());
                    
                    WSCH_AuditLogger.debug('technicianSlot.getTechExternalId() - ' + technicianSlot.getTechExternalId());
                    String technicianName = technicianSlot.getTechnician() != null ? technicianSlot.getTechnician().Name : '';
                    technicianName = String.isNotBlank(technicianName) ? technicianName : getTAG033() + ':' + technicianSlot.getTechExternalId(); /* Technician not Found in ServiceMax' */
                    WSCH_AuditLogger.debug('Inside createRows(), technicianName - ' + technicianName);
                    
                    //Calendar initilization Date.
                    if (minStartDate != null) {
                        if(minStartDate.getTime() > startDateTimeUsr.getTime()) {
                            minStartDate = startDateTimeUsr;
                        }
                    } else {
                        minStartDate = startDateTimeUsr;
                    }
                    
                    WSCH_AuditLogger.debug('createEventsJson(), minEventStartTime initial - ' + minEventStartTime);
                    WSCH_AuditLogger.debug('createEventsJson(), maxEventEndTime initial - ' + maxEventEndTime);
                    
                    //Start Hour of a day . Min start time out of all events.
                    Integer startTime = Integer.valueOf(startDateTimeUsr.formatGmt('HH'));      //HH
                    WSCH_AuditLogger.debug('Inside createEventsJson(), startTime - ' + startTime);
                    if(startTime < minEventStartTime) {
                        minEventStartTime = startTime;
                    }
                    //End Hour of a day . Max end time out of all events.
                    Integer endTime = Integer.valueOf(endDateTimeUsr.formatGmt('HH'));      //HH
                    WSCH_AuditLogger.debug('Inside createEventsJson(), endTime - ' + endTime);
                    if(endTime > maxEventEndTime) {
                        maxEventEndTime = endTime;
                    }
                    
                    //WSCH_AuditLogger.debug('createEventsJson(), startTime - ' + startTime + 'endTime - ' + endTime);
                    
                    jsonGenerator.writeStartObject();
                    String strText ='';
                    /* Commented this code to comment 'select' option in the appointment calendar window.
if(isEnableHelpText) {
//strText = '<br/><center>' + getTAG067() + '</center>';
// strText = '<br/>' + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + getTAG067() ;
strText = '<br/>' + '<center>' + getTAG067() +'</center>';
}*/
                    
                    /* display technician name on calendar event only if setting is true */
                    /*Kundan- Commented below lines of code because setting 'DCON003,SET004' is updated to text*/
                    /*if(isDisplayTechName) {
//jsonGenerator.writeStringField('text', technicianName);
if(strText != null && String.IsNotBlank(strText)) {
strText = strText + '<br/>' + technicianName;
} else {
strText = '<br/>' + technicianName;
}
}*/
                    strStartTime = WSCH_DateUtils.userTimeFormat(startDateTimeUsr);
                    strEndTime = WSCH_DateUtils.userTimeFormat(endDateTimeUsr);            
                    String descContent = '';
                    String technicianNotInSVMX = '';
                    if(technicianSlot.getTechnician() == null){       
                        
                        //String str1 = startDateTimeUsr.format(WSCH_DateUtils.getLocaleTimeFormat());
                        technicianNotInSVMX = technicianName;
                        descContent = '<b>' + getTAG068() + '</b> ' + technicianName;                          
                        descContent = descContent + '<br/><b>' + getTAG069() + '</b> ' + String.format(' {0} - {1}, {2}, {3}.', new List<String>{strStartTime, strEndTime, strDay, strDate});
                        //descContent = descContent + '<b>' + getTAG069() + '</b> ' + String.format(' {0} - {1}, {2}, {3}.', new List<String>{strStartTime, strEndTime, strDay, strDate});
                    }
                    //String slotTime = String.format('{0} - {1}', new List<String>{strStartTime, strEndTime});
                    String slotTime = String.format('{0}-{1}', new List<String>{strStartTime.replace( ' ', ''), strEndTime.replace( ' ', '')});
                    // if(strText != null && String.IsNotBlank(strText)) {
                    //String jsonString = string.valueof(jsonGenerator);
                    //String jsonString = jsonGenerator.getAsString();
                    strText = '<center><b>'+slotTime+ '</b></center>' + strText + technicianNotInSVMX + displayMoreTechnicianFields(technicianSlot,mapTechIds , referenceMap, commaSeperatedFields);
                    // strText =strText + technicianNotInSVMX + displayMoreTechnicianFields(technicianSlot,mapTechIds , referenceMap, commaSeperatedFields);
                    jsonGenerator.writeStringField('text', strText);
                    
                    //}
                    
                    if(index == 0) {
                        jsonGenerator.writeStringField('textColor', '#29BB04');     //event textcolor which includes slot time and technician name
                    } else {
                        jsonGenerator.writeStringField('textColor', 'black');
                    }
                    
                    if(technicianSlot.getTechnician() != null){
                        //String descContent = '<b>' + getTAG068() + '</b> ' + technicianName;
                        descContent = descContent + '<b>' + getTAG069() + '</b> ' + String.format(' {0} - {1}, {2}, {3}.', new List<String>{strStartTime, strEndTime, strDay, strDate});
                        
                        descContent = descContent + '<br/>' + displayMoreTechnicianFields(technicianSlot,mapTechIds , referenceMap, commaSeperatedFields);
                    }        
                    
                    
                    //descContent = descContent + '<br/><br/><b>Warning Message :</b> Falls outside the time required by the service level agreement.';
                    //jsonGenerator.writeStringField('message',descContent);
                    
                    
                    jsonGenerator.writeStringField('start_date', startDateTimeUsr.formatGmt('yyyy-MM-dd HH:mm'));  //HH:mm    hh:mm a
                    jsonGenerator.writeStringField('end_date', endDateTimeUsr.formatGmt('yyyy-MM-dd HH:mm'));  //HH:mm      hh:mm a          
                    jsonGenerator.writeStringField('id', String.valueOf(index));
                    //jsonGenerator.writeStringField('color', '#D7D7D0');
                    jsonGenerator.writeStringField('color', '#FFFFFF'); 
                    
                    //below logic to compare the dates and notify the user by color change in slots if the slot is out of SLA
                    //SVMXC__Service_Order__c currWorkOrder = WSCH_CommonUtils.fetchWorkOrderById(strWORecordID);
                    if(currWorkOrder != null && currWorkOrder.SVMXC__Preferred_Start_Time__c != null && currWorkOrder.SVMXC__Preferred_End_Time__c != null) {
                        
                        if(!(endDateTimeGMT <= currWorkOrder.SVMXC__Preferred_Start_Time__c || startDateTimeGMT >= currWorkOrder.SVMXC__Preferred_End_Time__c)) {
                            // Within SLA, set a different color for this event in calendar
                            //descContent = descContent + '<br/><br/><b>Warning Message :</b> Falls outside the time required by the service level agreement.';
                            jsonGenerator.writeStringField('color', '#cfcb4a'); //CFCB4A  FFF493
                        }else {//outside SLA
                            //descContent = descContent + '<br/><br/><b>' + getTAG070() + '</b>' + '&nbsp;' + getTAG072();
                            String strWarnMessage = '<b>' + getTAG070() + '</b>' + '&nbsp;' + getTAG072();
                            jsonGenerator.writeStringField('warnmessage',strWarnMessage);
                            isOutsideSLA = true;
                        }
                    }
                    
                    if(currentWO.SVMXC__Appointment_Promised_Time_Slot__c != null){
                        if (index == lstTechnicianSlot.size()-1 && currentAppointment != null && String.isNotBlank(currentAppointment.getStrStartDateTime())) {
                            //jsonGenerator.writeStringField('color', 'red');
                            jsonGenerator.writeStringField('color', 'orange');
                        }
                    }
                    jsonGenerator.writeStringField('message',descContent);
                    jsonGenerator.writeEndObject();
                }
            }
            //below logic has been added to display the booked appointment slot when it has been booked in the
            //early hours of the day or when the booked slot is falling before the slots that are actually displayed in UI
            Integer currApptStartTime, currApptEndTime;
            if(currApptStartDateTimeUsr != null) {
                WSCH_AuditLogger.debug('Inside createEventsJson(), currApptStartDateTimeUsr- ' + currApptStartDateTimeUsr);
                currApptStartTime = Integer.valueOf(currApptStartDateTimeUsr.formatGmt('HH'));      //HH
                WSCH_AuditLogger.debug('Inside createEventsJson(), currApptStartTime- ' + currApptStartTime);
                WSCH_AuditLogger.debug('Inside createEventsJson(), minEventStartTime- ' + minEventStartTime);
                if(currApptStartTime < minEventStartTime) {
                    minEventStartTime = currApptStartTime;
                }
                WSCH_AuditLogger.debug('Inside createEventsJson(), minEventStartTime after comparison- ' + minEventStartTime);
            }
            
            if(currApptEndDateTimeUsr != null) {
                WSCH_AuditLogger.debug('Inside createEventsJson(), currApptEndDateTimeUsr- ' + currApptEndDateTimeUsr);
                currApptEndTime = Integer.valueOf(currApptEndDateTimeUsr.formatGmt('HH'));      //HH
                WSCH_AuditLogger.debug('Inside createEventsJson(), currApptEndTime- ' + currApptEndTime);
                WSCH_AuditLogger.debug('Inside createEventsJson(), maxEventEndTime- ' + maxEventEndTime);
                if(currApptEndTime > maxEventEndTime) {
                    maxEventEndTime = currApptEndTime;
                }
                WSCH_AuditLogger.debug('Inside createEventsJson(), maxEventEndTime after comparison- ' + maxEventEndTime);
            }
            
            if (currentAppointment != null && String.isNotBlank(currentAppointment.getStrStartDateTime())) {
                lstOfTechnicianSlot.remove(lstTechnicianSlot.size()-1);
            }
            
            WSCH_AuditLogger.debug('createEventsJson(), minEventStartTime final - ' + minEventStartTime);
            WSCH_AuditLogger.debug('createEventsJson(), maxEventEndTime final - ' + maxEventEndTime);
            
            //minEventStartTime = minEventStartTime;
            maxEventEndTime = maxEventEndTime + 1;
            calendarStartDate = minStartDate.formatGmt('yyyy-MM-dd HH:mm');     //'yyyy-MM-dd HH:mm'  hh:mm a
            jsonGenerator.writeEndArray();
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_Appointments_Calendar :: createEventsJson :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return jsonGenerator.getAsString();
    }
    
    /**  Force book a job when there are no appointments available for a Work Order  **/
    
    //Method to display more technician fields on the get Appointments Calendar UI
    public String displayMoreTechnicianFields(WSCH_Appointment technicianSlot, Map<Id, SVMXC__Service_Group_Members__c> mapTechIds,Map<String, String> referenceMap, String commaSeperatedFields){
        WSCH_AuditLogger.debug('inside displayMoreTechnicianFields()');
        //String strtechFieldSetting = String.valueof(WSCH_CommonUtils.getSettingValue('DCON003','SET004'));
        //String strtechFieldSetting = WSCH_CommonUtils.getSettingValue('DCON003','SET004');
        //String strtechFieldSetting = 'Name,TAG161:SVMXC__Email__c,SVMXC__Zip__c,SVMXC__Service_Group__c,SVMXC__Service_Territory__c,SVMXC__Member_information__c';
        String descContent = '';
        //if(!(strtechFieldSetting == '' || strtechFieldSetting == null)){
        if(String.isNotBlank(strtechFieldSetting)){
            List<String> tempStr = strtechFieldSetting.split(',',0);
            String commaSeperatedFieldLabels= '';
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.SVMXC__Service_Group_Members__c.fields.getMap();
            
            for(integer i=0; i < tempStr.size(); i++){
                List<String> tempBreakString1 = tempStr[i].split(':');
                if(tempStr[i].contains(':') && tempBreakString1.size() ==1){
                    if(commaSeperatedFieldLabels == ''){
                        commaSeperatedFieldLabels = tempBreakString1[0].trim();
                    }
                    else{
                        commaSeperatedFieldLabels = commaSeperatedFieldLabels + ',' + tempBreakString1[0].trim();
                    }
                }
                if(tempBreakString1.size()==2){
                    if(commaSeperatedFieldLabels==''){
                        commaSeperatedFieldLabels = tempBreakString1[0].trim();
                    }
                    else{
                        commaSeperatedFieldLabels = commaSeperatedFieldLabels + ',' + tempBreakString1[0].trim();
                    }
                }
            }
            if(technicianSlot.getTechnician() != null){
                SVMXC__Service_Group_Members__c techData = mapTechIds.get(technicianSlot.getTechnician().id);
                
                List<String> varNames = new list<String>();
                varNames=(commaSeperatedFields.Split(',',0));
                List<String> tagNames = new List<String>();
                tagNames=(commaSeperatedFieldLabels.Split(',',0));
                List<String> tagAndVariable = new List<String>();
                
                Integer tagIndex = 0;
                Integer fieldIndex = 0;
                for(integer i=0; i < tempStr.size(); i++){
                    List<String> tempBreakString = tempStr[i].split(':');
                    if(tempStr[i].contains(':') && tempBreakString.size() ==1){
                        tempBreakString.add(' ');
                    }
                    if(tempBreakString.size() == 2){
                        String myLabel = tagNames[tagIndex];
                        tagIndex = tagIndex +1;
                        try{
                            Component.Apex.OutputText output;
                            output = new Component.Apex.OutputText();
                            output.expressions.value = '{!$Label.' + myLabel + '}';
                            string labelValue = '';
                            
                            if(output!= null && output.value != null ){        
                                labelValue = string.valueOf(output.value);        
                                descContent = descContent + '<b>' + labelValue  +':</b> ';
                            }
                            else{
                                descContent = descContent + '<b>' +':</b> ';
                            }
                        }
                        catch(Exception ex){
                            WSCH_AuditLogger.error('Exception caught:WSCH_Provider_SP_Appointments_Calendar:displayMoreTechnicianFields() ' + ex.getMessage());
                        }
                        if((tempBreakString[1]) != ' ' && fieldMap.containskey(tempBreakString[1].trim()) && String.ValueOf(fieldMap.get(tempBreakString[1].trim()).getDescribe().getType()) != 'TextArea' && String.ValueOf(fieldMap.get(tempBreakString[1].trim()).getDescribe().getType()) != 'encryptedstring'){
                            if(referenceMap.containsKey(String.valueof(techData.get(varNames[fieldIndex].trim())))){
                                descContent = descContent +referenceMap.get(String.valueof(techData.get(varNames[fieldIndex].trim()))) + '<br/>';
                            }
                            else{
                                System.debug('2techData.get(varNames[i])'+techData.get(String.valueof(varNames[fieldIndex].trim())));
                                if(techData.get(varNames[fieldIndex]) != null){
                                    //descContent = descContent + techData.get(String.valueof(varNames[fieldIndex].trim())) + '<br/>';
                                    descContent = descContent + getUserFormattedData(varNames, fieldIndex, techData, technicianSlot);
                                }
                                else{
                                    descContent = descContent + '<br/>';
                                }
                            }
                            fieldIndex = fieldIndex+1;
                        }
                        else{
                            
                            descContent = descContent  + '<br/>';
                            // fieldIndex = fieldIndex+1;
                        }
                    }
                    else if(tempBreakString.size() == 1){
                        if(fieldMap.containskey(tempBreakString[0].trim()) && String.ValueOf(fieldMap.get(tempBreakString[0].trim()).getDescribe().getType()) != 'TextArea' &&  String.ValueOf(fieldMap.get(tempBreakString[0].trim()).getDescribe().getType()) != 'encryptedstring'){
                            if(referenceMap.containsKey(String.valueof(techData.get(varNames[fieldIndex].trim())))){
                                descContent = descContent +referenceMap.get(String.valueof(techData.get(varNames[fieldIndex].trim())))  + '<br/>';
                                fieldIndex =fieldIndex+1;
                            }
                            else{
                                if(techData.get(varNames[fieldIndex].trim()) != null){
                                    descContent = descContent + getUserFormattedData(varNames, fieldIndex, techData, technicianSlot);
                                }
                                else{
                                    descContent = descContent + '';
                                }
                                fieldIndex =fieldIndex+1;
                            }
                            
                            // continue;
                        }
                        else{
                            
                            descContent = descContent  + '';
                            // fieldIndex = fieldIndex+1;
                        }
                    }
                    
                    /*  if(referenceMap.containsKey(String.valueof(techData.get(varNames[i])))){
                    descContent = descContent + '<br/>' +referenceMap.get(String.valueof(techData.get(varNames[i])));
                    }
                    else{
                    System.debug('2techData.get(varNames[i])'+techData.get(String.valueof(varNames[i])));
                    if(techData.get(varNames[i]) != null){
                    descContent = descContent + techData.get(String.valueof(varNames[i]));
                    }
                    }*/
                }
            }
        }
        return descContent;
    }
    
    public String getUserFormattedData(List<String> varNames, Integer fieldIndex, SVMXC__Service_Group_Members__c techData, WSCH_Appointment technicianSlot){
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.SVMXC__Service_Group_Members__c.fields.getMap();
        String fieldType = String.ValueOf(fieldMap.get(varNames[fieldIndex].trim()).getDescribe().getType());
        String descContent = '';                            
        if(fieldType == 'DATE'){
            String dateField = String.valueof(techData.get(String.valueof(varNames[fieldIndex].trim()))).replace('00:00:00','').trim();
            Date myDate = date.valueOf(dateField);
            String dateLocateFormatted = myDate.format();
            descContent = descContent  +dateLocateFormatted + '<br/>';
            //fieldIndex = fieldIndex+1;
        }
        else if(fieldType == 'DATETIME'){
            Datetime myDatetime = datetime.valueof(techData.get(String.valueof(varNames[fieldIndex].trim())));
            String strDateTimeLocale = myDatetime.format();
            descContent = descContent  +strDateTimeLocale + '<br/>';
            //fieldIndex = fieldIndex+1;
        }
        else if(fieldType == 'DOUBLE' || fieldType == 'PERCENT' || fieldType == 'CURRENCY'){
            Decimal result = decimal.valueOf(string.valueof(techData.get(String.valueof(varNames[fieldIndex].trim()))));
            descContent = descContent +result.format()+ '<br/>';
        }
        else{
            descContent = descContent +techData.get(String.valueof(varNames[fieldIndex].trim())) + '<br/>';
            //fieldIndex =fieldIndex+1;
        }
        return descContent;
    }
    
    public PageReference forceSchedule() {
        
        PageReference workOrderPage;
        WSCH_CommonUtils.putGlobalUtilValMap('isCalendarBooking','true');
        try{
            List<String> lstOfWOIds = new List<String>();
            lstOfWOIds.add(strWORecordID);
            List<SVMXC__Service_Order__c> scheduleWorkOrderList = WSCH_CommonUtils.fetchWorkOrders(lstOfWOIds);
            
            WSCH_Provider_SP_RealTimeOptimizer.mapWoConName = new Map<Id, String>();            
            for(SVMXC__Service_Order__c workOrder: scheduleWorkOrderList) {
                workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_PENDING;
                workOrder.SVMXC__Scheduling_Change_Token__c = 'FORCE_SCHEDULE';
                workOrder.SVMXC__Optimizer_Connection_Name__c = strSPInstance;
                WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.put(workOrder.id, strSPInstance);
            }
            WSCH_AuditLogger.debug('WSCH_Provider_SP_Appointments_Calendar.mapWoConName: ' + WSCH_Provider_SP_RealTimeOptimizer.mapWoConName);
            WSCH_OptimizedSchedulingService.triggerExecuted = true;
            WSCH_OptimizedSchedulingService.manageWorkOrders(scheduleWorkOrderList);
            
            //do not display the available appointments panel after foce book is executed
            isBookApptSuccess = true;
            
            //after booking job navigate back to this Work Order page
            workOrderPage = navigateToWorkOrder();
            
        } catch(Exception ex) {
            WSCH_AuditLogger.debug('Exception caught:WSCH_Provider_SP_Appointments_Calendar:forceSchedule() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return workOrderPage;
    }
    
    /**  Book Job when ok to arrive option is selected in book appointment light box. **/
    public PageReference bookJob() {
        
        WSCH_AuditLogger.debug('Inside bookJob()');
        WSCH_CommonUtils.putGlobalUtilValMap('isCalendarBooking','true');
        PageReference workOrderPage;
        
        try{
            String strHorizonStartGmtDt, strHorizonEndGmtDt;
            WSCH_Appointment technicianSlot = lstOfTechnicianSlot.get(Integer.valueOf(selectedRowId));
            Datetime startDateTimeUsr = technicianSlot.getStartDateTime();
            String strStartTimeUsr = startDateTimeUsr.formatGmt('HH:mm');
            WSCH_AuditLogger.debug('StartDateTime before TZ conversion - ' + startDateTimeUsr);
            DateTime startDateTimeGmt = WSCH_DateUtils.doTZConversion(startDateTimeUsr, strTimeZone, 'GMT',technicianSlot.getIntTimeZoneOffset());
            String strDate = startDateTimeGmt.formatGmt('yyyy-MM-dd');
            WSCH_AuditLogger.debug('converted strStartDate - ' + strDate);
            String strStartTime = startDateTimeGmt.formatGmt('HH:mm');
            
            
            Datetime endDateTimeUsr = technicianSlot.getEndDateTime();
            String strEndTimeUsr = endDateTimeUsr.formatGmt('HH:mm');
            //converting the start datetime from pref business hrs/user time zone to GMT
            WSCH_AuditLogger.debug('EndDateTime before TZ conversion - ' + endDateTimeUsr);
            //converting the start datetime from pref business hrs/user time zone to GMT
            DateTime endDateTimeGmt = WSCH_DateUtils.doTZConversion(endDateTimeUsr, strTimeZone, 'GMT',technicianSlot.getIntTimeZoneOffset());
            String strEndTime = endDateTimeGmt.formatGmt('HH:mm');
            //String strStartTime = WSCH_DateUtils.userTimeFormat(startDateTimeUsr);
            //String strEndTime = WSCH_DateUtils.userTimeFormat(endDateTimeUsr);
            WSCH_AuditLogger.debug('converted strEndTime - ' + strEndTime);
            WSCH_AuditLogger.debug('converted strStartTime - ' + strStartTime);
            //String strDay = getWeekDay().get(technicianSlot.getDay());
            
            SVMXC__Service_Order__c workOrder = WSCH_CommonUtils.fetchWorkOrderById(strWORecordID);
            workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_PENDING;
            workOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CREATE_WO';
            
            WSCH_Provider_SP_RealTimeOptimizer.mapWoConName = new Map<Id, String>();
            //WSCH_AuditLogger.debug('bookAppointment:workOrder.id: ' + workOrder.id + ' strSPInstance: ' + strSPInstance);
            workOrder.SVMXC__Optimizer_Connection_Name__c = strSPInstance;
            WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.put(workOrder.id, strSPInstance);
            
            WSCH_AuditLogger.debug('strIsEarlyArrivalSelected - ' + strIsEarlyArrivalSelected);
            if(strIsEarlyArrivalSelected.equalsIgnoreCase('true')) {
                
                //below code converts Locale specific date into the yyyy-MM-dd format
                String strCalStart = String.valueOf(Date.parse(strCalStartDate));
                String strCalEnd = String.valueOf(Date.parse(strCalEndDate));
                WSCH_AuditLogger.debug('strCalStart - ' + strCalStart);
                WSCH_AuditLogger.debug('strCalEnd - ' + strCalEnd);
                
                DateTime calStartDateTimeUsr = WSCH_DateUtils.parseDateTimeNew(strCalStart +' 00:00:00');
                DateTime calStartDateTimeGmt = WSCH_DateUtils.doTZConversion(calStartDateTimeUsr, strTimeZone, 'GMT',technicianSlot.getIntTimeZoneOffset());
                WSCH_AuditLogger.debug('calStartDateTimeUsr - ' + calStartDateTimeUsr);
                WSCH_AuditLogger.debug('calStartDateTimeGmt - ' + calStartDateTimeGmt);
                strHorizonStartGmtDt = calStartDateTimeGmt.formatGmt('yyyy-MM-dd');
                
                DateTime calEndDateTimeUsr = WSCH_DateUtils.parseDateTimeNew(strCalEnd +' 23:00:00');
                DateTime calEndDateTimeGmt = WSCH_DateUtils.doTZConversion(calEndDateTimeUsr, strTimeZone, 'GMT',technicianSlot.getIntTimeZoneOffset());
                strHorizonEndGmtDt = calEndDateTimeGmt.formatGmt('yyyy-MM-dd');
                WSCH_AuditLogger.debug('strHorizonStartGmtDt - ' + strHorizonStartGmtDt);
                WSCH_AuditLogger.debug('strHorizonEndGmtDt - ' + strHorizonEndGmtDt);
                WSCH_AuditLogger.debug('strTimeZone - ' + strTimeZone);
                WSCH_AuditLogger.debug('OFFSET - ' + technicianSlot.getIntTimeZoneOffset());
                isEarlyArrivalSelected = true;
            } else {
                strHorizonStartGmtDt = strDate;
                strHorizonEndGmtDt = strDate;
                isEarlyArrivalSelected = false;
            }
            putOTAE(workOrder);
            //strore the old booked_slot value in a static variable
            if(String.isNotEmpty(workOrder.SVMXC__Booked_Appointment_Slot__c)) {
                WSCH_Provider_SP_Appointments_Calendar.strOldApptBookedSlot = String.valueOf(workOrder.SVMXC__Booked_Appointment_Slot__c);
            }
            
            //store the booked slot on the WO field SVMXC__Booked_Appointment_Slot__c
            workOrder.SVMXC__Booked_Appointment_Slot__c = String.format('{0} - {1}, {2}, {3}', new List<String>{strStartTimeUsr, strEndTimeUsr, technicianSlot.getDay(), startDateTimeUsr.formatGmt('yyyy-MM-dd')});
            
            //store the old appointment_promise_slot value in a static variable
            WSCH_Provider_SP_Appointments_Calendar.strOldApptPromiseSlot = String.valueOf(workOrder.SVMXC__Appointment_Promised_Time_Slot__c);
            
            //boolean is set to distinguish whether the call is coming from bookAppt or bookJob. BookAppt is true and bookJob is false
            workOrder.SVMXC__Appointment_Promised_Time_Slot__c = String.format(' {0} - {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}', new List<String>{strStartTime, strEndTime, technicianSlot.getDay(), strDate, 'false', strHorizonStartGmtDt, strHorizonEndGmtDt, String.valueOf(technicianSlot.getIntTimeZoneOffset()), startDateTimeGmt.formatGMT('yyyy-MM-dd HH:mm:ss'), endDateTimeGmt.formatGMT('yyyy-MM-dd HH:mm:ss')});
            List<SVMXC__Service_Order__c> scheduleWorkOrderList = new List<SVMXC__Service_Order__c>();
            scheduleWorkOrderList.add(workOrder);
            
            WSCH_AuditLogger.debug('workOrder.SVMXC__Appointment_Promised_Time_Slot__c - ' + workOrder.SVMXC__Appointment_Promised_Time_Slot__c);
            WSCH_AuditLogger.debug('Before manageWorkOrders() call ');
            WSCH_OptimizedSchedulingService.triggerExecuted = true;
            WSCH_OptimizedSchedulingService.manageWorkOrders(scheduleWorkOrderList);
            //WSCH_AuditLogger.debug('After manageWorkOrders() call ');
            
            isBookApptSuccess = true;
            workOrderPage = navigateToWorkOrder();
        } catch(Exception ex) {
            WSCH_AuditLogger.debug('Exception caught:WSCH_Provider_SP_WOApptsController:bookJob() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        WSCH_AuditLogger.finish();
        return workOrderPage;
    }
    public static void putOTAE(SVMXC__Service_Order__c workOrder){
        /*FIX for OTAE Begins*/
        try{
            //check if this action was invoked from Calendar Appointment page, bychecking for null value of the variable
            if(WSCH_Provider_SP_Appointments_Calendar.isEarlyArrivalSelected != null){
                String strFieldName = '', descStr;
                //get the field name form the setting
                strFieldName = WSCH_CommonUtils.getSettingValue('DCON003','SET00999');
                if(String.isNotBlank(strFieldName)){
                    descStr = String.valueOf(workOrder.get(strFieldName));
                    if(String.isBlank(descStr)){
                        descStr = '';
                    }
                    //check if OTAE is already added to request
                    if((descStr.containsIgnoreCase(System.Label.DCON003_TAG059))){
                        //splitting the string before the OTAE string to append the current OTAE status.
                        descStr = descStr.substringBefore('|| ' + System.Label.DCON003_TAG059+ ':');
                        if(WSCH_Provider_SP_Appointments_Calendar.isEarlyArrivalSelected){
                            //append the OTAE True string to description
                            descStr = descStr +' || ' + System.Label.DCON003_TAG059+ ':' + System.Label.CONF039_TAG033;
                        }else{
                            //append the OTAE False string to description
                            descStr = descStr + ' || ' + System.Label.DCON003_TAG059+ ':' + System.Label.CONF039_TAG034;
                        }
                        
                    }//if OTAE is not present in the request update it with the current OTAE status
                    else{
                        if(WSCH_Provider_SP_Appointments_Calendar.isEarlyArrivalSelected){
                            //append the OTAE True string to description
                            descStr = descStr +' || ' + System.Label.DCON003_TAG059+ ':' + System.Label.CONF039_TAG033;
                        }else{
                            //append the OTAE False string to description
                            descStr = descStr + ' || ' + System.Label.DCON003_TAG059+ ':' + System.Label.CONF039_TAG034;
                        }
                    }
                    //assign the value of Description to Problem Description Field of Work Order
                    workOrder.put(strFieldName,descStr);
                }
                if(WSCH_Provider_SP_Appointments_Calendar.isEarlyArrivalSelected){
                    //append the OTAE True information to the field
                    workOrder.put('SVMXC__SM_Ok_To_Arrive_Early__c',true);
                }else{
                    //append the OTAE False information to the field
                    workOrder.put('SVMXC__SM_Ok_To_Arrive_Early__c',false);
                }
            }
        }catch(Exception ex){
            WSCH_AuditLogger.debug('Exception caught:WSCH_Provider_SP_Appointments_Calendar:putOTAE() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        /*FIX for OTAE Ends*/
    }
    
    /**  Cancel the work order appointment **/
    public PageReference cancelAppointment() {
        
        PageReference workOrderPage;
        Set<SVMXC__Service_Order__c> setWOToCancel = new Set<SVMXC__Service_Order__c>();
        try{
            List<String> lstOfWOIds = new List<String>();
            lstOfWOIds.add(strWORecordID);
            List<SVMXC__Service_Order__c> scheduleWorkOrderList = WSCH_CommonUtils.fetchWorkOrders(lstOfWOIds);
            for(SVMXC__Service_Order__c workOrder: scheduleWorkOrderList) {
                workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_PENDING;
                workOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CANCEL_WO';
            }
            
            WSCH_OptimizedSchedulingService.triggerExecuted = true;
            WSCH_OptimizedSchedulingService.manageWorkOrders(scheduleWorkOrderList);
            WSCH_AuditLogger.debug('WSCH_Provider_SP_WOApptsController:cancelAppointment:lstOfWOIds ' + lstOfWOIds);
            /*Filtering the WorkOrders which were Successfuly cancelled in ServicePower*/
            for(SVMXC__Service_Order__c cancWO: scheduleWorkOrderList) {
                if(cancWO.SVMXC__OptiMax_Status__c == WSCH_Constants.STATUS_OPT_COMPLETED ){
                    setWOToCancel.add(cancWO);
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_WOApptsController:cancelAppointment:Cancel WO ID ' + cancWO.id);
                }
            }
            //WSCH_CommonUtils.deleteWORelatedEventsOnCancel(new Set<SVMXC__Service_Order__c>(scheduleWorkOrderList));
            WSCH_CommonUtils.deleteWORelatedEventsOnCancel(setWOToCancel);
            if(scheduleWorkOrderList != null && scheduleWorkOrderList.size() > 0) 
            {
                WSCH_CommonUtils.getWorkorderFields();
                if((WSCH_CommonUtils.strSetOfUpdateableFields != null) && (!WSCH_CommonUtils.strSetOfUpdateableFields.isEmpty())){
                    List<SVMXC__Service_Order__c> lstUpdateWos = new List<SVMXC__Service_Order__c>();
                    lstUpdateWos.addAll(scheduleWorkOrderList);
                    scheduleWorkOrderList = new List<SVMXC__Service_Order__c>();
                    scheduleWorkOrderList.addAll(WSCH_CommonUtils.getMapOfWorkOrders(WSCH_CommonUtils.strSetOfUpdateableFields, lstUpdateWos).values());
                }else{
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_Appointments_Calendar:scheduleWorkOrderList:strSetOfUpdateableFields: ' + WSCH_CommonUtils.strSetOfUpdateableFields);
                }
                    if (!securityUtils.verifyFieldAccess(scheduleWorkOrderList, COMM_SecurityUtils.Access.Updateable, false))
                        {
                            WSCH_AuditLogger.debug(System.label.COMM001_TAG142);
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));

                        }           
                        else
                        {
                            update scheduleWorkOrderList;   
                        }
            }
            workOrderPage = navigateToWorkOrder();
        } catch(Exception ex) {
            WSCH_AuditLogger.debug('Exception caught:WSCH_Provider_SP_WOApptsController:cancelAppointment() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        WSCH_AuditLogger.finish();
        return workOrderPage;
    }
    
    /** This method is used to get the already booked appointments on a Work Order **/
    public String getCurrentAppointment(String strWORecordID) {
        
        WSCH_AuditLogger.debug('Inside getCurrentAppointment()');
        String strStartTime, strEndTime, strDay, strStartDate;
        /* 'This Work Order is already booked for the slot ' */
        String strMsg = getTAG034();
        SVMXC__Service_Order__c workOrder = WSCH_CommonUtils.fetchWorkOrderById(strWORecordID);
        WSCH_Appointment existingAppointment = new WSCH_Appointment();
        if(String.isNotBlank(workOrder.SVMXC__Appointment_Promised_Time_Slot__c) && workOrder.SVMXC__Scheduled_Date_Time__c != null){
            
            //"strStartTime - strEndTime, strDay, strDate, 'true', strHorizonStartGmtDt, strHorizonEndGmtDt"
            String[] apptPromiseSlotArray = workOrder.SVMXC__Appointment_Promised_Time_Slot__c.split(',',9);
            
            if(apptPromiseSlotArray != null && apptPromiseSlotArray.size() == 9) {
                
                String[] startEndTimeSplit = apptPromiseSlotArray[0].split('-');
                String startTimeGmt = startEndTimeSplit[0].trim();
                String endTimeGmt = startEndTimeSplit[1].trim();
                
                DateTime startDateTimeGMT = WSCH_DateUtils.parseDateTimeNew(apptPromiseSlotArray[2].trim() + ' ' + startTimeGmt + ':00');
                WSCH_AuditLogger.debug('getCurrentAppointment::startDateTimeGMT '+startDateTimeGMT);
                DateTime startDateTimeUsr = WSCH_DateUtils.doTZConversion(startDateTimeGMT, 'GMT', strTimeZone, -1*Integer.valueOf(apptPromiseSlotArray[6].trim()));
                WSCH_AuditLogger.debug('getCurrentAppointment::startDateTimeUsr '+startDateTimeUsr);
                strStartDate = startDateTimeUsr.formatGmt('yyyy-MM-dd');
                //strStartTime = startDateTimeUsr.formatGmt('HH:mm');
                
                DateTime endDateTimeGMT = WSCH_DateUtils.parseDateTimeNew(apptPromiseSlotArray[2].trim() + ' ' + endTimeGmt + ':00');
                DateTime endDateTimeUsr = WSCH_DateUtils.doTZConversion(endDateTimeGMT, 'GMT', strTimeZone, -1*Integer.valueOf(apptPromiseSlotArray[6].trim()));
                WSCH_AuditLogger.debug('getCurrentAppointment::endDateTimeGMT '+endDateTimeGMT);
                WSCH_AuditLogger.debug('getCurrentAppointment::endDateTimeUsr '+endDateTimeUsr);
                //strEndTime = endDateTimeUsr.formatGmt('HH:mm');
                strStartTime = WSCH_DateUtils.userTimeFormat(startDateTimeUsr);                
                strEndTime = WSCH_DateUtils.userTimeFormat(endDateTimeUsr);
                WSCH_AuditLogger.debug('getCurrentAppointment::strStartTime '+strStartTime);
                
                WSCH_AuditLogger.debug('getCurrentAppointment::strEndTime '+strEndTime);
                
                //Getting the date as per user locale
                String strDateAsPerLocale = startDateTimeUsr.dateGmt().format();
                
                strCurrentApptMsg = String.format('{0} {1}, {2}, {3}.', new List<String>{strMsg, strStartTime + ' - ' + strEndTime, getWeekDay().get(apptPromiseSlotArray[1].trim()), strDateAsPerLocale });
                bookedTimings = String.format('{0}, {1}, {2}.', new List<String>{strStartTime + ' - ' + strEndTime, getWeekDay().get(apptPromiseSlotArray[1].trim()), strDateAsPerLocale });
            }
            existingAppointment = extractCurrentAppointment(workOrder.SVMXC__Appointment_Promised_Time_Slot__c);
        } else if(workOrder.SVMXC__Scheduled_Date_Time__c != null) {
            WSCH_Appointment technicianSlot;
            Integer intOffset=-1;
            if(lstOfTechnicianSlot != null && lstOfTechnicianSlot.size() > 0) {
                technicianSlot = lstOfTechnicianSlot.get(0);
                intOffset = technicianSlot.getIntTimeZoneOffset();
            }
            
            DateTime scheduledDateTime = workOrder.SVMXC__Scheduled_Date_Time__c;
            WSCH_AuditLogger.debug('Work Order scheduledDateTime - ' + scheduledDateTime);
            DateTime scheduledEndTime = scheduledDateTime.addSeconds(Integer.valueOf(workOrder.SVMXC__Service_Duration__c));
            
            DateTime startDateTimeUsr = WSCH_DateUtils.doTZConversion(scheduledDateTime, 'GMT', strTimeZone, -1*intOffset);
            WSCH_AuditLogger.debug('startDateTimeUsr - ' + startDateTimeUsr);
            
            DateTime endDateTimeUsr = WSCH_DateUtils.doTZConversion(scheduledEndTime, 'GMT', strTimeZone, -1*intOffset);
            
            String day = scheduledDateTime.format('EEE', strTimeZone);
            strDay = getWeekDay().get(day);
            strStartDate = startDateTimeUsr.formatGmt('yyyy-MM-dd');
            WSCH_AuditLogger.debug('User strStartDate - ' + strStartDate);
            //strStartTime = startDateTimeUsr.formatGmt('HH:mm');
            //strEndTime = endDateTimeUsr.formatGmt('HH:mm');
            strStartTime = WSCH_DateUtils.userTimeFormat(startDateTimeUsr);
            strEndTime = WSCH_DateUtils.userTimeFormat(endDateTimeUsr);
            WSCH_AuditLogger.debug('startDateTimeUsr.dateGmt() - ' + startDateTimeUsr.dateGmt());
            String strDateAsPerLocale = startDateTimeUsr.dateGmt().format();
            WSCH_AuditLogger.debug('strDateAsPerLocale - ' + strDateAsPerLocale);
            
            if(workOrder.SVMXC__Appointment_Promised_Time_Slot__c == null){
                /*if(System.currentPageReference().getParameters().get('woNumber') != null) {
                strWorkOrderID = System.currentPageReference().getParameters().get('woNumber');
                }
                
                if(System.currentPageReference().getParameters().get('workorderID') != null) {
                strWORecordID = System.currentPageReference().getParameters().get('workorderID');
                }
                
                SVMXC__Service_Order__c currWorkOrder = WSCH_CommonUtils.fetchWorkOrderById(strWORecordID);*/
                String strMsg1 = getTAG077();
                String strMsg2 = getTAG078();            
                if(!('Tentative'.equalsIgnoreCase(workOrder.SVMXC__Work_Order_Scheduling_Status__c)) && !('Cancelled'.equalsIgnoreCase(workOrder.SVMXC__Work_Order_Scheduling_Status__c))) {
                    strCurrentApptMsg = String.format('{0} {1} - {2}, {3}, {4}', new List<String>{strMsg1, strStartTime, strEndTime, strDay, strDateAsPerLocale});
                    bookedTimings = String.format('{0} - {1}, {2}, {3}', new List<String>{strStartTime, strEndTime, strDay, strDateAsPerLocale});    
                    
                }
                else{
                    strCurrentApptMsg = String.format('{0} {1} - {2}, {3}, {4}. {5}', new List<String>{strMsg1, strStartTime, strEndTime, strDay, strDateAsPerLocale,strMsg2});
                    bookedTimings = String.format('{0} - {1}, {2}, {3}', new List<String>{strStartTime, strEndTime, strDay, strDateAsPerLocale});
                }
            }/*
                else{
                strCurrentApptMsg = String.format('{0} {1} - {2}, {3}, {4}.', new List<String>{strMsg, strStartTime, strEndTime, strDay, strDateAsPerLocale});
                bookedTimings = String.format('{0} - {1}, {2}, {3}', new List<String>{strStartTime, strEndTime, strDay, strDateAsPerLocale});
                }*/
            existingAppointment.setStartDateTime(startDateTimeUsr);
            existingAppointment.setEndDateTime(endDateTimeUsr);
            String strStartHr = startDateTimeUsr.formatGmt('HH');
            String strStartMin = startDateTimeUsr.formatGmt('mm');
            existingAppointment.setStrStartDateTime(strStartDate + 'T' + strStartHr + ':' + strStartMin);
            
            //if the job is booked as book appointment(non SLA job) get the details from Appt_promise_slot field
            /*if(String.isNotBlank(workOrder.SVMXC__Appointment_Promised_Time_Slot__c) && 
(workOrder.SVMXC__Appointment_Promised_Time_Slot__c.contains('true'))) {

WSCH_AuditLogger.debug('Appointment promise slot is not null');
String[] apptPromiseSlotArray = workOrder.SVMXC__Appointment_Promised_Time_Slot__c.split(',',9);
if(apptPromiseSlotArray != null && apptPromiseSlotArray.size() == 9) {

String[] startEndTimeSplit = apptPromiseSlotArray[0].split('-');
String startTimeGmt = startEndTimeSplit[0].trim();
String endTimeGmt = startEndTimeSplit[1].trim();

DateTime startDateTimeGMT = WSCH_DateUtils.parseDateTimeNew(scheduledDateTime.formatGmt('yyyy-MM-dd') + ' ' + startTimeGmt + ':00');
WSCH_AuditLogger.debug('getCurrentAppointment::startDateTimeGMT '+startDateTimeGMT);
startDateTimeUsr = WSCH_DateUtils.doTZConversion(startDateTimeGMT, 'GMT', strTimeZone, -1*Integer.valueOf(apptPromiseSlotArray[6].trim()));
WSCH_AuditLogger.debug('getCurrentAppointment::startDateTimeUsr '+startDateTimeUsr);
strStartDate = startDateTimeUsr.formatGmt('yyyy-MM-dd');
WSCH_AuditLogger.debug('User strStartDate - ' + strStartDate);
strStartTime = startDateTimeUsr.formatGmt('HH:mm');
WSCH_AuditLogger.debug('getCurrentAppointment::strStartTime '+strStartTime);

DateTime endDateTimeGMT = WSCH_DateUtils.parseDateTimeNew(scheduledDateTime.formatGmt('yyyy-MM-dd') + ' ' + endTimeGmt + ':00');
endDateTimeUsr = WSCH_DateUtils.doTZConversion(endDateTimeGMT, 'GMT', strTimeZone, -1*Integer.valueOf(apptPromiseSlotArray[6].trim()));
WSCH_AuditLogger.debug('getCurrentAppointment::endDateTimeGMT '+endDateTimeGMT);
WSCH_AuditLogger.debug('getCurrentAppointment::endDateTimeUsr '+endDateTimeUsr);
strEndTime = endDateTimeUsr.formatGmt('HH:mm');
WSCH_AuditLogger.debug('getCurrentAppointment::strEndTime '+strEndTime);

//Getting the date as per user locale
strDateAsPerLocale = startDateTimeUsr.dateGmt().format();
WSCH_AuditLogger.debug('strDateAsPerLocale - ' + strDateAsPerLocale);

strCurrentApptMsg = String.format('{0} {1} - {2}, {3}, {4}.', new List<String>{strMsg, strStartTime, strEndTime, strDay, strDateAsPerLocale});
bookedTimings = String.format('{1} - {2}, {3}, {4}.', new List<String>{strMsg, strStartTime, strEndTime, strDay, strDateAsPerLocale});
}
}*/
        }
        
        if(workOrder.SVMXC__Group_Member__c != null) {
            
            SVMXC__Service_Group_Members__c technician =  WSCH_CommonUtils.fetchTechnicianById(workOrder.SVMXC__Group_Member__c);
            bookedTechnician = technician.Name;
            existingAppointment.setTechnician(technician);
        }
        currentAppointment = existingAppointment;
        return strCurrentApptMsg;
    }
    
    /**
Following method extracts the current appointment from the current appointment string.
**/
    private WSCH_Appointment extractCurrentAppointment (String currentAppointmentStr) {
        
        WSCH_Appointment existingAppointment = new WSCH_Appointment();
        String[] splitedApptStr = currentAppointmentStr.split(',');
        String[] splitedTimeStr = splitedApptStr.get(0).split(' - ');
        String strStartTime =  splitedTimeStr.get(0).trim();
        String strEndTime =  splitedTimeStr.get(1).trim();
        String strDay = splitedApptStr.get(1).trim();
        //String strDate = splitedApptStr.get(2).trim();
        String[] strStartDateSplit = splitedApptStr.get(7).trim().split(' ');
        String[] strEndDateSplit = splitedApptStr.get(8).trim().split(' ');
        String strStartDate = strStartDateSplit.get(0).trim();
        String strEndDate = strEndDateSplit.get(0).trim();
        
        String strStartTimeHour = strStartTime.split(' ').get(0).trim().split(':').get(0).trim();
        String strStartTimeMin = strStartTime.split(' ').get(0).trim().split(':').get(1).trim();
        String strEndTimeHour = strEndTime.split(' ').get(0).trim().split(':').get(0).trim();
        String strEndTimeMin = strEndTime.split(' ').get(0).trim().split(':').get(1).trim();
        
        //String strStartDateTime = strDate + ' ' + strStartTimeHour + ':' + strStartTimeMin + ':00';
        //String strEndDateTime = strDate + ' ' + strEndTimeHour + ':' + strEndTimeMin + ':00';
        String strStartDateTime = strStartDate + ' ' + strStartTimeHour + ':' + strStartTimeMin + ':00';
        String strEndDateTime = strEndDate + ' ' + strEndTimeHour + ':' + strEndTimeMin + ':00';
        
        DateTime startDateTimeGmt = WSCH_DateUtils.parseDateTimeNew(strStartDateTime);
        DateTime endDateTimeGmt = WSCH_DateUtils.parseDateTimeNew(strEndDateTime);
        
        //existingAppointment.setStrStartDateTime(strDate + 'T' + strStartTimeHour + ':' + strStartTimeMin);
        existingAppointment.setStrStartDateTime(strStartDate + 'T' + strStartTimeHour + ':' + strStartTimeMin);
        integer tempOffSet=0;
        if(splitedApptStr.size() > 6){
            tempOffSet = Integer.ValueOf(splitedApptStr[6].trim());
        }
        existingAppointment.setStartDateTime(WSCH_DateUtils.doTZConversion(startDateTimeGmt,'GMT',strTimeZone,-1*tempOffSet));
        existingAppointment.setEndDateTime(WSCH_DateUtils.doTZConversion(endDateTimeGmt,'GMT',strTimeZone, -1*tempOffSet));
        existingAppointment.setDay(strDay);
        WSCH_AuditLogger.debug('extractCurrentAppointment()::existingAppointment :'+existingAppointment);
        return existingAppointment;
    }
    
    public boolean getIsDisplayCurrentAppt() {
        return isDisplayCurrentAppt;
    }
    
    public boolean getIsDisplayForceBookMsg() {
        return isDisplayForceBookMsg;
    }
    
    public boolean getIsEarlyArrival() {
        return isEarlyArrival;
    }
    
    /*Kundan- Commented below lines of code because setting 'DCON003,SET004' is updated to text*/
    /*public boolean getIsDisplayTechName() {
    return isDisplayTechName;
    }*/
    
    public boolean getIsEnableUnresourcedTray() {
        return isEnableUnresourcedTray;
    }
    
    public boolean getIsEnableFetchApptByStartEndDt() {
        return isEnableFetchApptByStartEndDt;
    }
    
    public boolean getIsEnableCancelAppt() {
        return isEnableCancelAppt;
    }
    
    public boolean getIsEnableHelpText() {
        return isEnableHelpText;
    }
    
    public void saveSelectedAppt() {
        WSCH_AuditLogger.debug('Selected row id is ' + selectedRowId);
    }
    
    public PageReference navigateToWorkOrder() {
        
        String strWORecordID = System.currentPageReference().getParameters().get('workorderID');
        PageReference workOrderPage = new PageReference('/' + strWORecordID);
        workOrderPage.setRedirect(true);
        return workOrderPage;
    }
    
    public PageReference cancelApptSelection() {
        
        String strWORecordID = System.currentPageReference().getParameters().get('workorderID');
        PageReference workOrderPage = new PageReference('/' + strWORecordID);
        workOrderPage.setRedirect(true);
        return workOrderPage;
    }
    
    public String getAppointmentsTitle() {
        String strTitle = getTAG008() + ' ' + strWorkOrderID;
        return strTitle;
    }
    
    public void setIsForceBookJob(boolean isForceBook) {
        isForceBookJob = isForceBook;
    }
    
    public boolean getIsForceBookJob() {
        return isForceBookJob;
    }
    
    /*public boolean getDisplayViewMore() {
    return (getIsWOApptEmpty() || !displayViewMore);
    }*/
    
    /* Custom Labels section */
    
    public static String getTAG001() {
        return system.label.DCON003_TAG001;     //Appointment has been booked for this slot:
    }
    
    public static String getTAG002() {
        return system.label.DCON003_TAG002;     //Select
    }
    
    public static String getTAG003() {
        return system.label.DCON003_TAG003;     //Promise Type
    }
    
    public static String getTAG004() {
        return system.label.DCON003_TAG004;     //Appointment Day
    }
    
    public static String getTAG005() {
        return system.label.DCON003_TAG005;     //Promise Date
    }
    
    public static String getTAG006() {
        return system.label.DCON003_TAG006;     //Start Time
    }
    
    public static String getTAG007() {
        return system.label.DCON003_TAG007;     //End Time
    }
    
    public static String getTAG008() {
        return system.label.DCON003_TAG008;     //Appointments for Work Order:
    }
    
    public static String getTAG009() {
        return system.label.DCON003_TAG009;     //Available Appointments
    }
    
    public static String getTAG010() {
        return system.label.DCON003_TAG010;     //Book Appointment
    }
    
    public static String getTAG011() {
        return system.label.DCON003_TAG011;     //Cancel
    }
    
    public static String getTAG012() {
        return system.label.DCON003_TAG012;     //Back To Work Order
    }
    
    public static String getTAG013() {
        return system.label.DCON003_TAG013;     //Monday
    }
    
    public static String getTAG014() {
        return system.label.DCON003_TAG014;     //Tuesday
    }
    
    public static String getTAG015() {
        return system.label.DCON003_TAG015;     //Wednesday
    }
    
    public static String getTAG016() {
        return system.label.DCON003_TAG016;     //Thursday
    }
    
    public static String getTAG017() {
        return system.label.DCON003_TAG017;     //Friday
    }
    
    public static String getTAG018() {
        return system.label.DCON003_TAG018;     //Saturday
    }
    
    public static String getTAG019() {
        return system.label.DCON003_TAG019;     //Day
    }
    
    public static String getTAG020() {
        return system.label.DCON003_TAG020;     //Two Hour
    }
    
    public static String getTAG021() {
        return system.label.DCON003_TAG021;     //Part Day
    }
    
    public static String getTAG022() {
        return system.label.DCON003_TAG022;     //Sunday
    }
    
    public static String getTAG023() {
        return system.label.DCON003_TAG023;     //View More
    }
    
    public static String getTAG024() {
        return system.label.DCON003_TAG024;     //Send to Unresourced Tray
    }
    
    public static String getTAG025() {
        return system.label.DCON003_TAG025;     //Technician
    }
    
    /* Dispatch optimization settings value is set to false.Please make it to true to get appointments */
    public static String getTAG026() {
        return system.label.DCON003_TAG026;
    }
    
    /* GBL022 Setting is not set to Service Power. Please set it to Service Power to get the appointments */
    public static String getTAG027() {
        return system.label.DCON003_TAG027;
    }
    
    /* Exception occurred while making Offer Appointments call to SP */
    public static String getTAG028() {
        return system.label.DCON003_TAG028;
    }
    
    /* Exception occurred while making Book Appointment call to SP */
    public static String getTAG029() {
        return system.label.DCON003_TAG029;
    }
    
    /* Work order is already qualified for a dispatch process of different service provider other than Service Power */
    public static String getTAG030() {
        return system.label.DCON003_TAG030;
    }
    
    /* No appointments as this Work Order has already been dispatched */
    public static String getTAG031() {
        return system.label.DCON003_TAG031;
    }
    
    /* No appointments as this Work Order is already in the process to be booked */
    public static String getTAG032() {
        return system.label.DCON003_TAG032;
    }
    
    /* Error: The technician specified by the ServicePower system does not exist in the ServiceMax system */
    public static String getTAG033() {
        return system.label.DCON003_TAG033;
    }
    
    /* This Work Order is already booked for the slot  */
    public static String getTAG034() {
        return system.label.DCON003_TAG034;
    }
    
    /* Current Appointments */
    public static String getTAG037() {
        return system.label.DCON003_TAG037;
    }
    /* Date */
    public static String getIPAD004_TAG018(){
        return system.label.IPAD004_TAG018;
    }
    
    
    //custom labels specific to Appointments Calendar UI
    public static String getTAG038() { return system.label.DCON003_TAG038; } //Calendar Settings
    public static String getTAG039() { return system.label.DCON003_TAG039; } //Cancel Appointment
    public static String getTAG040() { return system.label.DCON003_TAG040; } //Booked Time Slot:
    public static String getTAG041() { return system.label.DCON003_TAG041; } //Technician: 
    public static String getTAG042() { return system.label.DCON003_TAG042; } //Calender View Options
    public static String getTAG043() { return system.label.DCON003_TAG043; } //Show
    public static String getTAG044() { return system.label.DCON003_TAG044; } //This Week Only
    public static String getTAG045() { return system.label.DCON003_TAG045; } //This Week and Next Week
    public static String getTAG046() { return system.label.DCON003_TAG046; } //This Week and Next 2 Weeks
    public static String getTAG047() { return system.label.DCON003_TAG047; } //Hide Weekends
    public static String getTAG048() { return system.label.DCON003_TAG048; } //Yes
    public static String getTAG049() { return system.label.DCON003_TAG049; } //No
    public static String getTAG050() { return system.label.DCON003_TAG050; } //Week Begins on
    public static String getTAG051() { return system.label.DCON003_TAG051; } //Sunday
    public static String getTAG052() { return system.label.DCON003_TAG052; } //Monday
    public static String getTAG053() { return system.label.DCON003_TAG053; } //OK
    public static String getTAG054() { return system.label.DCON003_TAG054; } //Escalate Appointment
    public static String getTAG055() { return system.label.DCON003_TAG055; } //The appointment will be placed in the escalation queue for manual scheduling.
    public static String getTAG056() { return system.label.DCON003_TAG056; } //Cancel
    public static String getTAG057() { return system.label.DCON003_TAG057; } //Escalate
    public static String getTAG058() { return system.label.DCON003_TAG058; } //Keep Appointment
    public static String getTAG059() { return system.label.DCON003_TAG059; } //Ok to arrive early
    public static String getTAG060() { return system.label.DCON003_TAG060; } //Book
    public static String getTAG061() { return system.label.DCON003_TAG061; } //Service Appointment Quick Select
    public static String getTAG062() { return system.label.DCON003_TAG062; } //We invite you to select from the following short list of available Appointments.
    public static String getTAG063() { return system.label.DCON003_TAG063; } //Work Order:
    public static String getTAG064() { return system.label.DCON003_TAG064; } //Search
    public static String getTAG065() { return system.label.DCON003_TAG065; } //Legend:
    public static String getTAG066() { return system.label.DCON003_TAG066; } //This appointment period is within your service level agreement. However feel free to choose any available appointment period that is most convenient to you.
    public static String getTAG067() { return system.label.DCON003_TAG067; } //Select
    public static String getTAG068() { return system.label.DCON003_TAG068; } //Technician Name:
    public static String getTAG069() { return system.label.DCON003_TAG069; } //Time slot:
    public static String getTAG070() { return system.label.DCON003_TAG070; } //Warning Message:
    public static String getTAG071() { return system.label.DCON003_TAG071; } //Appointment Booking Calendar
    public static String getTAG072() { return system.label.DCON003_TAG072; } //Falls outside the time required by the service level agreement.
    public static String getTAG351() { return system.label.DCON001_TAG351; } //Start Date:
    public static String getTAG352() { return system.label.DCON001_TAG352; } //End Date:
    public static String getTAG077() { return system.label.DCON003_TAG077; } //This work order is currently scheduled for
    public static String getTAG078() { return system.label.DCON003_TAG078; } //If you want to rebook this work order, please select an appointment below.
    public string getHLPURL() { return system.label.DCON003_HLPURL; } //http://userdocs.servicemax.com:8080/ServiceMaxHelp/Summer14/en_us/svmx_redirector.htm?uid=DNS04_08_04
    public string getHLPTITLE() { return system.label.COMM001_TAG064; } // 'Help'
    public string getProcessingText() { return system.label.COMM001_TAG041; } //Processing...
    
    // List Related section
    
    
    //Build data necessary for populating the list view
    //Build data necessary for populating the list view
    public void buildListData()
    {
        /* if the response is successful, get the technician slots */
        //System.debug(logginglevel.warn,'technicianSlotResponse: '+technicianSlotResponse);
        
        populateCalendarDates();
        
        /* Get the limit value for displaying the technician slots from settings */
        Integer slotsSize = 99; //Default size.
        String settingsSlotSize = WSCH_CommonUtils.getSettingValue('DCON003','SET001');
        if(String.isNotBlank(settingsSlotSize)) {
            slotsSize = Integer.valueOf(settingsSlotSize) > WSCH_Constants.APPOINTMENT_SLOTS_MAX_SIZE ? WSCH_Constants.APPOINTMENT_SLOTS_MAX_SIZE : Integer.valueOf(settingsSlotSize);
        }
        if(System.currentPageReference().getParameters().get('woNumber') != null) {
            strWorkOrderID = System.currentPageReference().getParameters().get('woNumber');
        }
        WSCH_Provider_SP_RealTimeOptimizer.getSpURL('');
        if(System.currentPageReference().getParameters().get('spInstance') != null) {
            strSPInstance = System.currentPageReference().getParameters().get('spInstance');
        }
        if((strSPInstance == null) || (String.isBlank(strSPInstance))){
            strSPInstance = WSCH_Provider_SP_RealTimeOptimizer.strDefaultConnection;
        }
        WSCH_AuditLogger.debug('WSCH_Provider_SP_Appointments_Calendar::buildListData()::strWorkOrderID - ' +strWorkOrderID);
        /*if(System.currentPageReference().getParameters().get('workorderID') != null) {
        strWORecordID = System.currentPageReference().getParameters().get('workorderID');
        }*/
        WSCH_AuditLogger.debug('WSCH_Provider_SP_Appointments_Calendar::buildListData():: strWORecordID -'+strWORecordID);
        /* set isDisplayCurrentAppt to true if there is already a current appointment on the WO along with the new list of appointments. */
        if(getCurrentAppointment(strWORecordID) != null) {
            isDisplayCurrentAppt = true;
        }
        
        /* Checks if the work order qualifies for book appointment , if already booked before. */
        SVMXC__Service_Order__c currWorkOrder = WSCH_CommonUtils.fetchWorkOrderById(strWORecordID);
        
        /*      Disable 'Send to Unresourced Tray' when the Work Order is already force booked*/
        if(currWorkOrder != null && String.isNotBlank(currWorkOrder.SVMXC__Scheduling_Change_Token__c) && currWorkOrder.SVMXC__Scheduling_Change_Token__c.equalsIgnoreCase('FORCE_SCHEDULE')) {
            isForceBookJob = false;
        }
        
        if(isWOValidToGetAppointments(currWorkOrder) != null) {
            strOfferApptErrorMsg = isWOValidToGetAppointments(currWorkOrder);
            //WSCH_AuditLogger.finish();
            return;
        }
        
        //populateCalendarDates();
        //currWorkOrder.SVMXC__Optimizer_Connection_Name__c = strSPInstance;
        WSCH_Provider_SP_RealTimeOptimizer.mapWoConName = new Map<Id, String>();
        WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.put(currWorkOrder.id, strSPInstance);
        
        System.debug(logginglevel.warn,'strWorkOrderID: '+strWorkOrderID+'   '+strWORecordID+'  '+slotsSize+'  '+apptParamObj);
        try {
            technicianSlotResponse = WSCH_OptimizedSchedulingService.getAvailableAppointments(strWORecordID, null, slotsSize, 1);
        }catch(WSCH_Exception ex) {
            strOfferApptErrorMsg = getTAG028() + ex.getMessage();
            WSCH_AuditLogger.error('Exception occurred while getting appointments.' + ex.getMessage());
        }
        
        System.debug(logginglevel.warn,'technicianSlotResponse: '+technicianSlotResponse);
        //System.debug(logginglevel.warn,'technicianSlotResponse: '+technicianSlotResponse.statusCode);
        
        if(technicianSlotResponse != null && technicianSlotResponse.statusCode == 0) {
            
            /* This is required for viewing more appointments */
            displayViewMore = technicianSlotResponse.viewMore != null ? technicianSlotResponse.viewMore : displayViewMore;
            
            //strXMLData = '<?xml version=\"1.0\" encoding=\"UTF-8\"?><rows>';
            lstOfTechnicianSlot = technicianSlotResponse.appointmentList;
            
            WSCH_AuditLogger.debug('strNextAppointmentIndex before setting - ' + strNextAppointmentIndex);
            /* update the index for next list of appointments based on the size of current technician slot list */
            strNextAppointmentIndex = strNextAppointmentIndex + lstOfTechnicianSlot.size();
            WSCH_AuditLogger.debug('strNextAppointmentIndex after setting - ' + strNextAppointmentIndex);
            
            strXMLData = createRows(lstOfTechnicianSlot);
            System.debug(logginglevel.warn,'strXMLData: '+strXMLData);
            
            //strXMLData = strXMLData + '</rows>';
        } else {
            //if status code is 8 - SP_NO_TIME_AVAILABLE (8), then the appointments are not available due to the insufficient criteria supplied
            /*if(technicianSlotResponse.statusCode == 8) {
isForceBookJob = true;
}*/
            //enable force booking if no appointments are returned
            isForceBookJob = true;
            
            //if there are no technician slots, set the response data string to null
            strXMLData = null;
            if(technicianSlotResponse != null) {
                //and set the error message
                strOfferApptErrorMsg = technicianSlotResponse.statusMessage;
            }            
            //uncomment below line to check forcejob as no appointments will be shown for this error code.
            //strOfferApptErrorMsg = strStatusMsg;
            
            //return;
        }
        //WSCH_AuditLogger.finish();
    }
    public boolean getDisplayViewMore() {
        return (getIsWOApptEmpty() || !displayViewMore);
    }
    public String createRows(List<WSCH_Appointment> lstTechnicianSlot) {
        
        WSCH_AuditLogger.debug('Inside createRows()');
        String strMoreData; 
        strMoreData = '<?xml version=\"1.0\" encoding=\"UTF-8\"?><rows>'; 
        
        WSCH_Appointment technicianSlot;
        for(Integer i=0; i<lstTechnicianSlot.size(); i++) {
            technicianSlot = lstTechnicianSlot.get(i);
            
            WSCH_AuditLogger.debug('technicianSlot.getTechExternalId() - ' + technicianSlot.getTechExternalId());
            WSCH_AuditLogger.debug('technicianSlot - ' + technicianSlot);
            //Datetime StartDateTime = technicianSlot.getStartDateTime();
            //String strStartFinalDate = StartDateTime.format('yyyy-MM-dd');      //contains 12/28/2012
            /*Datetime StartDateTime = WSCH_DateUtils.getDateTimeInUserLocale(technicianSlot.getStrStartDateTime());
            * String strStartFinalDate = StartDateTime.dateGmt().format();      //contains 12/28/2012
            * String strStartFinalTime = StartDateTime.format('hh:mm a');      //contains  4:30 PM
            * Datetime EndDateTime = technicianSlot.getEndDateTime();
            * String strEndFinalDate =  EndDateTime.dateGmt().format();
            * String strEndFinalTime = EndDateTime.format('hh:mm a');*/
            
            //added the below code after commenting above. This code is same as calendar dates code 
            Datetime startDateTimeUsr = technicianSlot.getStartDateTime();
            //String strStartFinalTime = startDateTimeUsr.formatGmt('hh:mm a');
            String strStartFinalTime = WSCH_DateUtils.userTimeFormat(startDateTimeUsr);           
            String strStartFinalDate = startDateTimeUsr.dateGmt().format();
            
            Datetime endDateTimeUsr = technicianSlot.getEndDateTime();
            //String strEndFinalTime = endDateTimeUsr.formatGmt('hh:mm a');
            String strEndFinalTime = WSCH_DateUtils.userTimeFormat(endDateTimeUsr);
            
            String strDay = getWeekDay().get(technicianSlot.getDay());
            String strPromiseType = getPromiseType().get(technicianSlot.getPromType());
            String technicianName = technicianSlot.getTechnician() != null ? technicianSlot.getTechnician().Name : '';
            technicianName = String.isNotBlank(technicianName) ? technicianName : getTAG033() + ':' + technicianSlot.getTechExternalId(); /* Technician not Found in ServiceMax' */
            WSCH_AuditLogger.debug('Inside createRows(), technicianName - ' + technicianName);
            strMoreData = strMoreData + '<row id="' + i + '">';
            /* create a first empty cell for the radio button */
            strMoreData = strMoreData + '<cell></cell>';
            /* populate the other cells for that row with the data */
            String strEachRow = '<cell>' + strDay + ' </cell><cell>' + strStartFinalDate + ' </cell><cell>' + strStartFinalTime + ' - ' + strEndFinalTime + ' </cell><cell>' + technicianName +'</cell></row>';
            strMoreData = strMoreData + strEachRow;
            
        }
        strMoreData = strMoreData + '</rows>';
        WSCH_AuditLogger.debug('WSCH_Provider_SP_Appointments_Calendar::CreateRows::Appointment XML:'+strMoreData);
        return strMoreData;
    }
    public Map<String, String> getPromiseType() {
        return mapOfPromiseType;
    }
    /**  This method builds the XML data with more appointments to view on a Work Order  **/
    public void viewMoreAppointments() {
        
        
        String strMoreXMLData;
        isViewMoreApptExecuted = true;
        Id idWoId;
        
        /* Get the limit value for displaying the technician slots from settings. */
        String settingsSlotSize = WSCH_CommonUtils.getSettingValue('DCON003','SET001');
        if(String.isNotBlank(settingsSlotSize)) {
            slotsSize = Integer.valueOf(settingsSlotSize) > WSCH_Constants.APPOINTMENT_SLOTS_MAX_SIZE ? WSCH_Constants.APPOINTMENT_SLOTS_MAX_SIZE : Integer.valueOf(settingsSlotSize);
        } else {
            slotsSize = 5;
        }
        
        technicianSlotResponse = null;
        //List<WSCH_Appointment> tempLstOfTechnicianSlot;
        /* get the technician slots by sending workOrderID, size and the index */
        try {
            if(String.isNotBlank(strWORecordID)){
                idWoId = Id.valueOf(strWORecordID);
                WSCH_Provider_SP_RealTimeOptimizer.mapWoConName = new Map<Id, String>();
                WSCH_Provider_SP_RealTimeOptimizer.mapWoConName.put(idWoId, strSPInstance);
            }
            WSCH_AuditLogger.debug('WSCH_Provider_SP_Appointments_Calendar::viewMoreAppointments: woID: ' + idWoId + ' strSPInstance: ' + strSPInstance + ' strNextAppointmentIndex: ' + strNextAppointmentIndex + ' slotsSize: ' + slotsSize);
            // technicianSlotResponse = WSCH_OptimizedSchedulingService.getAvailableAppointments(strWORecordID, null, slotsSize, strNextAppointmentIndex);
            technicianSlotResponse =  WSCH_OptimizedSchedulingService.getAvailableAppointments(strWORecordID, null, ((strNextAppointmentIndex+slotsSize)-1), 1);
            
            if(technicianSlotResponse == null) {
                /* 'Exception occurred while making Offer Appointments call to SP' */
                strOfferApptErrorMsg = getTAG028();
                return;
            }
        }catch(WSCH_Exception ex) {
            strOfferApptErrorMsg = getTAG028() + ex.getMessage();
            WSCH_AuditLogger.debug('Exception caught:WSCH_Provider_SP_Appointments_Calendar:viewMoreAppointments() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            WSCH_AuditLogger.finish();
            return ;
        }
        
        WSCH_AuditLogger.debug('technicianSlotResponse.statusCode ' + technicianSlotResponse.statusCode);
        //technicianSlotResponse.statusCode = 21;               //uncomment this to check the error scenario when no more appts are available to view
        if(technicianSlotResponse.statusCode == 0) {
            
            /* define temp technicianSlotList to build the XML data with more appointments */
            List<WSCH_Appointment> tempLstOfTechnicianSlot = technicianSlotResponse.appointmentList;
            
            
            
            /* update the global variable lstOfTechnicianSlot with the new appointmentList. This list contains all slots including the
            //additional slots requested. So that same can be used for booking an appointment. */
            //lstOfTechnicianSlot.addAll(tempLstOfTechnicianSlot);
            
            lstOfTechnicianSlot = tempLstOfTechnicianSlot;
            WSCH_AuditLogger.debug('More Appointment List  '+lstOfTechnicianSlot);
            //strMoreXMLData = '';
            strXMLData = createRows(tempLstOfTechnicianSlot);
            /* replace the string </rows> in strXMLData with the new list of appointments data */
            //strXMLData = strXMLData.replace('</rows>', strMoreXMLData);
            /* finally append this updated strXMLData with string </rows> */
            //strXMLData = strXMLData + '</rows>';
            
            WSCH_AuditLogger.debug(' view more tempLstOfTechnicianSlot.size() - ' + tempLstOfTechnicianSlot.size());
            WSCH_AuditLogger.debug('strNextAppointmentIndex  before view more - ' + strNextAppointmentIndex);
            
            /* update the index for next list of appointments based on the size of current technician slot list */
            strNextAppointmentIndex = strNextAppointmentIndex + slotsSize;
            
            WSCH_AuditLogger.debug('strNextAppointmentIndex  after view more - ' + strNextAppointmentIndex);
            
            /* This is required for viewing more appointments */
            displayViewMore = technicianSlotResponse.viewMore != null ? technicianSlotResponse.viewMore : displayViewMore;
        } else {
            isViewMoreApptFailed = true;
            /* if there are no additional technician slots, set the response data string to null and set the error message */
            strMoreXMLData = null;
            strOfferApptErrorMsg = technicianSlotResponse.statusMessage;
        }
        /* Commiting the logs to Audit Logger. */
         WSCH_AuditLogger.finish();
    }
    
    public boolean getIsMoreApptEmpty() {
        
        if(strXMLData != null && (isViewMoreApptExecuted == true && isViewMoreApptFailed == true)) {
            return true;
        } else {
            return false;
        }
    }
    //This method is to get page reference if Appoinment View Type is List
    public PageReference pageLoad()
    {
        String setngApmntViewType = WSCH_CommonUtils.getSettingValue('DCON003', 'SET006');
        if(setngApmntViewType == null)
            setngApmntViewType = 'Calendar View';
        //setngApmntViewType = 'List';
        if(setngApmntViewType == 'List View')
        {
            PageReference listPageRef = Page.WSCH_Provider_SP_Appointments;
            WSCH_AuditLogger.debug('WSCH_Provider_SP_Appointments_Calendar::pageLoad()::workorderID - '+System.currentPageReference().getParameters().get('workorderID').trim());
            listPageRef.getParameters().put('woNumber', System.currentPageReference().getParameters().get('woNumber').trim());
            listPageRef.getParameters().put('workorderID', System.currentPageReference().getParameters().get('workorderID').trim());
            listPageRef.setredirect(false);
            return listPageRef;
        }
        return null;
    }
    public static WSCH_DefaultAppointmentHook getAppointmentHook() {
        WSCH_DefaultAppointmentHook hook;
        try{
            String settingValue = WSCH_CommonUtils.getSettingValue('DCON003','SET007');
            //settingValue='WSCH_CustomAppointmentHook';
            WSCH_AuditLogger.debug('Setting Value '+settingValue);
            if(String.isNotEmpty(settingValue)) {
                Type t = Type.forName(settingValue);
                hook = (WSCH_DefaultAppointmentHook) t.newInstance();
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('Exception caught:WSCH_Provider_SP_Appointments_Calendar:getAppointmentHook() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }finally{
            if(null == hook){
                hook = new WSCH_DefaultAppointmentHook();
                WSCH_AuditLogger.debug('Default hook ');
                
            }
        }
        return hook;
    }
    /** Start - NPS Related code **/
    public string getUserLocaleKey(){
        return UserInfo.getLanguage();
    }
    public string getUserID(){
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID(){
        return UserInfo.getOrganizationId().substring(0, 15);
    }
    /** End - NPS Related code **/}