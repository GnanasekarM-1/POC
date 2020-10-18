/**
        @Name: WSCH_Provider_SP_WOApptsController
        @Author: Zubair
        @Description: This is a Controller class for the appointments page, WSCH_Provider_SP_Appointments
 **/

public with sharing class WSCH_Provider_SP_WOApptsController {
    
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
    /** End - NPS Related code **/

    public String strXMLData { get; set; }
    public String selectedRowId { get; set; }
    public String strWorkOrderID { get; set; }
    public String strWORecordID { get; set; }

    public String strOfferApptErrorMsg { get; set; }
    public String strBookApptErrorMsg { get; set; }

    public List<WSCH_Appointment> lstOfTechnicianSlot { get; set; }

    public boolean isBookApptFailed = false;
    public boolean isBookApptExecuted = false;
    public boolean isBookApptSuccess = false;

    public boolean isViewMoreApptExecuted = false;
    public boolean isViewMoreApptFailed = false;
    public boolean displayViewMore = true;

    public static Map<String, String> mapOfWeekDays = new Map<String, String>();
    public static Map<String, String> mapOfPromiseType = new Map<String, String>();
    public Integer strNextAppointmentIndex = 1;

    public String strMoreXMLData { get; set; }
    public String strBookApptSuccessMsg { get; set; }
    public boolean isForceBookJob = true;
    public String strCurrentApptMsg { get; set; }
    public boolean isDisplayCurrentAppt = false;

    public boolean isDisplayForceBookMsg = false;
    public String strForceBookMsg { get; set; }

    static {
        /* Static initialization of Week Days map */
        mapOfWeekDays.put('Mon',getTAG013());
        mapOfWeekDays.put('Tue',getTAG014());
        mapOfWeekDays.put('Wed',getTAG015());
        mapOfWeekDays.put('Thu',getTAG016());
        mapOfWeekDays.put('Fri',getTAG017());
        mapOfWeekDays.put('Sat',getTAG018());
        mapOfWeekDays.put('Sun',getTAG022());

        /* Static initialization of Promise Types Map */
        mapOfPromiseType.put('D',getTAG019());
        mapOfPromiseType.put('T',getTAG020());
        mapOfPromiseType.put('P',getTAG021());
    }

    /**  This method builds the XML data with the appointment slots after retrieving it from the Service Power  **/
    public void buildResponseData() {
        //isBookApptFailed = false;
        WSCH_AuditLogger.debug('Entered buildResponseData()');
        /* Logic to check global settings GBL007 is set to True and GBL022 contains ServicePower */
        String settingsGBL007 = WSCH_CommonUtils.getSettingValue('GLOB001', 'GBL007');
        String settingsGBL022 = WSCH_CommonUtils.getSettingValue('GLOB001', 'GBL022');
        if(settingsGBL007 != null && settingsGBL007.touppercase() == 'FALSE') {
            /* Dispatch optimization settings value is set to false.Please make it to true to get appointments' */
            strOfferApptErrorMsg = getTAG026();
            /*  Disable 'Send to Unresourced Tray' button when continuous optimization is disabled  */
            isForceBookJob = false;
            return;
        }
        Set<String> providersSet = new Set<String>();
        if(settingsGBL022 != null ) {
            for(String StrProvider : settingsGBL022.split(',')){
                providersSet.add(StrProvider.touppercase());
            }
            if(!(providersSet.contains('SERVICEPOWER') || providersSet.contains('SERVICE POWER'))) {
                /* 'GBL022 Setting is not set to Service Power. Please set it to Service Power to get the appointments' */
                strOfferApptErrorMsg = getTAG027();
                /*  Disable 'Send to Unresourced Tray' button when Service Provider is not ServicePower */
                isForceBookJob = false;
                return;
            }
        }

        if(System.currentPageReference().getParameters().get('woNumber') != null) {
            strWorkOrderID = System.currentPageReference().getParameters().get('woNumber');
        }

        if(System.currentPageReference().getParameters().get('workorderID') != null) {
            strWORecordID = System.currentPageReference().getParameters().get('workorderID');
        }

        /* set isDisplayCurrentAppt to true if there is already a current appointment on the WO along with the new list of appointments. */
        if(getCurrentAppointment(strWORecordID) != null) {
            isDisplayCurrentAppt = true;
        }

        /* Checks if the work order qualifies for book appointment , if already booked before. */
        SVMXC__Service_Order__c currWorkOrder = WSCH_CommonUtils.fetchWorkOrderById(strWORecordID);

        /*  Disable 'Send to Unresourced Tray' when the Work Order is already force booked*/
        if(currWorkOrder != null && String.isNotBlank(currWorkOrder.SVMXC__Scheduling_Change_Token__c) && currWorkOrder.SVMXC__Scheduling_Change_Token__c.equalsIgnoreCase('FORCE_SCHEDULE')) {
            isForceBookJob = false;
        }

        WSCH_AuditLogger.debug('Inside buildResponseData() - before qualification logic');
        if(isWOValidToGetAppointments(currWorkOrder) != null) {
            strOfferApptErrorMsg = isWOValidToGetAppointments(currWorkOrder);
            return;
        }

        /* Get the limit value for displaying the technician slots from settings */
        Integer slotsSize;
        String settingsSlotSize = WSCH_CommonUtils.getSettingValue('DCON003','SET001');
        if(String.isNotBlank(settingsSlotSize)) {
            slotsSize = Integer.valueOf(settingsSlotSize) > WSCH_Constants.APPOINTMENT_SLOTS_MAX_SIZE ? WSCH_Constants.APPOINTMENT_SLOTS_MAX_SIZE : Integer.valueOf(settingsSlotSize);
        } else {
            slotsSize = 5;
        }

        WSCH_AppointmentsResponse technicianSlotResponse = null;
        /* get the technician slots by sending workOrderID, size and the index */
        try {
            technicianSlotResponse = WSCH_OptimizedSchedulingService.getAvailableAppointments(strWORecordID, null, slotsSize, 1);
            //technicianSlotResponse = WSCH_OptimizedSchedulingService.getAvailableAppointments(strWORecordID, slotsSize, 1);
            WSCH_AuditLogger.debug('Inside buildResponseData(), technicianSlotResponse ' + technicianSlotResponse);
            WSCH_AuditLogger.debug('Inside buildResponseData(), isBookApptFailed : ' + isBookApptFailed);

            if(technicianSlotResponse == null) {
                /* 'Exception occurred while making Offer Appointments call to SP' */
                strOfferApptErrorMsg = getTAG028();
                return;
            }
        }catch(WSCH_Exception ex) {
            strOfferApptErrorMsg = ex.getMessage();
            WSCH_AuditLogger.error('WSCH_Provider_SP_WOApptsController :: buildResponseData() :: '+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            return ;
        }

        //uncomment below 2 lines to check forcejob as no appointments will be shown for this error code.
        //technicianSlotResponse.statusCode = 8;
        //String strStatusMsg = WSCH_Provider_SP_ErrorCodesMapper.getStatusMsg(technicianSlotResponse.statusCode, WSCH_Provider_SP_ErrorCodesMapper.OFFER_APPT);

        /* if the response is successful, get the technician slots */
        if(technicianSlotResponse.statusCode == 0) {

            /* This is required for viewing more appointments */
            displayViewMore = technicianSlotResponse.viewMore != null ? technicianSlotResponse.viewMore : displayViewMore;

            strXMLData = '<?xml version=\"1.0\" encoding=\"UTF-8\"?><rows>';
            lstOfTechnicianSlot = technicianSlotResponse.appointmentList;

            WSCH_AuditLogger.debug('strNextAppointmentIndex before setting - ' + strNextAppointmentIndex);
            /* update the index for next list of appointments based on the size of current technician slot list */
            strNextAppointmentIndex = strNextAppointmentIndex + lstOfTechnicianSlot.size();
            WSCH_AuditLogger.debug('strNextAppointmentIndex after setting - ' + strNextAppointmentIndex);

            strXMLData = createRows(strXMLData, lstOfTechnicianSlot);
            strXMLData = strXMLData + '</rows>';
        } else {
            //if status code is 8 - SP_NO_TIME_AVAILABLE (8), then the appointments are not available due to the insufficient criteria supplied
            /*if(technicianSlotResponse.statusCode == 8) {
                        isForceBookJob = true;
                }*/
            //enable force booking if no appointments are returned
            isForceBookJob = true;

            //if there are no technician slots, set the response data string to null
            strXMLData = null;
            //and set the error message
            strOfferApptErrorMsg = technicianSlotResponse.statusMessage;

            //uncomment below line to check forcejob as no appointments will be shown for this error code.
            //strOfferApptErrorMsg = strStatusMsg;

            //return;
        }

        // set isDisplayCurrentAppt to true if there is already a current appointment on the WO along with the new list of appointments.
        /*if(getCurrentAppointment(strWORecordID) != null) {
                isDisplayCurrentAppt = true;
            }*/
        //Commiting the logs to Audit Logger.
        WSCH_AuditLogger.finish();
    }

    /**  This method books an appointment selected by the User for a Work Order  **/
    public void bookAppointment() {

        strBookApptSuccessMsg = null;
        isBookApptExecuted = true;

        WSCH_AuditLogger.debug('strWORecordID inside bookAppointment ' + strWORecordID);

        WSCH_AuditLogger.debug('lstOfTechnicianSlot inside bookAppointment - ' + lstOfTechnicianSlot);
        WSCH_AuditLogger.debug('SelectedRowId - ' + SelectedRowId);

        /* get the selected row data using the row id selected from appointments UI */
        WSCH_Appointment technicianSlot = lstOfTechnicianSlot.get(Integer.valueOf(selectedRowId));
        Datetime StartDateTime = technicianSlot.getStartDateTime();
        String strDate = StartDateTime.format('yyyy-MM-dd');
        String strStartTime = StartDateTime.format('hh:mm a');
        Datetime EndDateTime = technicianSlot.getEndDateTime();
        String strEndTime = EndDateTime.format('hh:mm a');
        String strDay = getWeekDay().get(technicianSlot.getDay());
        SVMXC__Service_Order__c workOrder = WSCH_CommonUtils.fetchWorkOrderById(strWORecordID);
        workOrder.SVMXC__Appointment_Promised_Time_Slot__c = String.format(' {0} - {1}, {2}, {3}', new List<String>{strStartTime, strEndTime, strDay, strDate});
        WSCH_AppointmentsResponse techSlotResponse = null;
        try {
            techSlotResponse = WSCH_OptimizedSchedulingService.bookAppointment(workOrder, technicianSlot);
            //techSlotResponse = null;  //explicitly setting to null to check bookAppt timeout ex
            WSCH_AuditLogger.debug('Inside WSCH_Provider_SP_WOApptsController: bookAppointment(), techSlotResponse - ' + techSlotResponse);
            if(techSlotResponse == null) {
                /* 'Exception occurred while making Book Appointment call to SP' */
                strBookApptErrorMsg = getTAG029();
                isBookApptFailed = true;
                WSCH_AuditLogger.debug('Inside bookAppt: if response null, strBookApptErrorMsg - ' + strBookApptErrorMsg);
                isDisplayCurrentAppt = false;   //added to hide current appt when bookAppt timeout ex occurs
                return;
            }
        }catch(WSCH_Exception ex) {
            strBookApptErrorMsg = ex.getMessage();
            isBookApptFailed = true;
            isDisplayCurrentAppt = false;   //added to hide current appt when bookAppt ex occurs
            WSCH_AuditLogger.error('WSCH_Provider_SP_WOApptsController :: bookAppointment() :: '+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            return ;
        }

        SVMXC__Service_Order__c workOrderBooked = WSCH_CommonUtils.fetchWorkOrderById(strWORecordID);
        if(techSlotResponse.statusCode == 0) {
            strBookApptErrorMsg = null;

            if(workOrderBooked.SVMXC__Scheduled_Date_Time__c != null) {
                strBookApptSuccessMsg = String.format(' {0} - {1}.', new List<String>{getTAG001(), workOrder.SVMXC__Appointment_Promised_Time_Slot__c});
            } else {
                strBookApptSuccessMsg = workOrderBooked.SVMXC__OptiMax_Error_Text__c;
            }
            /* if appointment is booked successfully, do not display the previously booked appointment in case if there is any */
            isDisplayCurrentAppt = false;
        } else {
            /* if the bookAppointment() fails, set the error message */
            strBookApptSuccessMsg = null;
            strBookApptErrorMsg = techSlotResponse.statusMessage;
            isBookApptFailed = true;
        }

        WSCH_AuditLogger.debug('Inside bookAppt strBookApptSuccessMsg - ' + strBookApptSuccessMsg);
        /* Commiting the logs to Audit Logger. */
        WSCH_AuditLogger.finish();
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
                /*  Disable 'Send to Unresourced Tray' button when Dispatch Process is not Continuous Optimization  */
                isForceBookJob = false;
                isExecutedOnce = true;
            }
        }

        if(!isExecutedOnce && currWorkOrder.SVMXC__Work_Order_Scheduling_Status__c != null) {
            if(!('Tentative'.equalsIgnoreCase(currWorkOrder.SVMXC__Work_Order_Scheduling_Status__c))) {
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
        return strOfferApptErrorMsg;
    }

    public Map<String,String> getWeekDay() {
        return mapOfWeekDays;
    }

    public Map<String, String> getPromiseType() {
        return mapOfPromiseType;
    }

    public boolean getIsWOApptEmpty() {

        if(strXMLData == null || strXMLData == '') {
            return true;
        } else if((strXMLData != null || strXMLData != '') && (isBookApptExecuted && isBookApptFailed)) {
            return true;    // This is the case when book appointment has executed, but failed
        } else {
            return false;
        }
    }

    public boolean getIsMoreApptEmpty() {

        if(strXMLData != null && (isViewMoreApptExecuted == true && isViewMoreApptFailed == true)) {
            return true;
        } else {
            return false;
        }
    }

    public boolean getIsBookApptFailure() {

        boolean temp;
        if(strXMLData != null && (isBookApptExecuted == false && isBookApptFailed == false)) {
            temp = false;
        } else if(strXMLData != null && (isBookApptExecuted == true && isBookApptFailed == false)) {
            temp = false;
            isBookApptSuccess = true;
        } else if(strXMLData != null && (isBookApptExecuted == true && isBookApptFailed == true)) {
            temp = true;
            isBookApptSuccess = false;
        } else if(strXMLData == null && (isBookApptExecuted = false && isBookApptFailed == false)) {
            temp = false;
            isBookApptSuccess = false;
        }
        return temp;
    }

    public boolean getIsBookApptSuccess() {

        if(strXMLData != null && (isBookApptExecuted == true && isBookApptFailed == false)) {
            return true;
        } else if(strXMLData != null && (isBookApptExecuted == true && isBookApptFailed == true)) {
            return true;    //changed from false to true when bookAppt is executed, but failed
        } else if(strXMLData == null && (isBookApptExecuted = false && isBookApptFailed == false)){
            return false;
        } else if(isForceBookJob && isDisplayForceBookMsg) {
            return true;
        } else {
            return false;
        }
    }

    /**  This method builds the XML data with more appointments to view on a Work Order  **/
    public void viewMoreAppointments() {

        Integer slotsSize;
        String strMoreXMLData;
        isViewMoreApptExecuted = true;

        /* Get the limit value for displaying the technician slots from settings. */
        String settingsSlotSize = WSCH_CommonUtils.getSettingValue('DCON003','SET001');
        if(String.isNotBlank(settingsSlotSize)) {
            slotsSize = Integer.valueOf(settingsSlotSize) > WSCH_Constants.APPOINTMENT_SLOTS_MAX_SIZE ? WSCH_Constants.APPOINTMENT_SLOTS_MAX_SIZE : Integer.valueOf(settingsSlotSize);
        } else {
            slotsSize = 5;
        }

        WSCH_AppointmentsResponse technicianSlotResponse = null;
        /* get the technician slots by sending workOrderID, size and the index */
        try {
            technicianSlotResponse = WSCH_OptimizedSchedulingService.getAvailableAppointments(strWORecordID, null, slotsSize, strNextAppointmentIndex);
            //technicianSlotResponse = WSCH_OptimizedSchedulingService.getAvailableAppointments(strWORecordID, slotsSize, strNextAppointmentIndex);
            if(technicianSlotResponse == null) {
                /* 'Exception occurred while making Offer Appointments call to SP' */
                strOfferApptErrorMsg = getTAG028();
                return;
            }
        }catch(WSCH_Exception ex) {
            strOfferApptErrorMsg = ex.getMessage();
            WSCH_AuditLogger.error('WSCH_Provider_SP_WOApptsController :: viewMoreAppointments() :: '+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            return ;
        }

        WSCH_AuditLogger.debug('technicianSlotResponse.statusCode ' + technicianSlotResponse.statusCode);
        //technicianSlotResponse.statusCode = 21;               //uncomment this to check the error scenario when no more appts are available to view
        if(technicianSlotResponse.statusCode == 0) {

            /* define temp technicianSlotList to build the XML data with more appointments */
            List<WSCH_Appointment> tempLstOfTechnicianSlot = technicianSlotResponse.appointmentList;

            WSCH_AuditLogger.debug('More Appointment List  '+lstOfTechnicianSlot);

            /* update the global variable lstOfTechnicianSlot with the new appointmentList. This list contains all slots including the
            additional slots requested. So that same can be used for booking an appointment. */
            lstOfTechnicianSlot.addAll(tempLstOfTechnicianSlot);

            strMoreXMLData = createRows(strMoreXMLData, tempLstOfTechnicianSlot);
            /* replace the string </rows> in strXMLData with the new list of appointments data */
            strXMLData = strXMLData.replace('</rows>', strMoreXMLData);
            /* finally append this updated strXMLData with string </rows> */
            strXMLData = strXMLData + '</rows>';

            WSCH_AuditLogger.debug(' view more tempLstOfTechnicianSlot.size() - ' + tempLstOfTechnicianSlot.size());
            WSCH_AuditLogger.debug('strNextAppointmentIndex  before view more - ' + strNextAppointmentIndex);

            /* update the index for next list of appointments based on the size of current technician slot list */
            strNextAppointmentIndex = strNextAppointmentIndex + tempLstOfTechnicianSlot.size();

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

    public String createRows(String strMoreData, List<WSCH_Appointment> lstTechnicianSlot) {

        /* interimIndex stores the start index in case of additional rows */
        Integer viewMoreIndex = 0;

        /* if strMoreData is null then set the start index to begin at the end of last row
         strMoreData will be null initially only in case of additional appointments */
        if(strMoreData == null) {
            viewMoreIndex = strNextAppointmentIndex - 1;
        }
        WSCH_Appointment technicianSlot;
        for(Integer i=0; i<lstTechnicianSlot.size(); i++) {
            technicianSlot = lstTechnicianSlot.get(i);

            //Datetime StartDateTime = technicianSlot.getStartDateTime();
            //String strStartFinalDate = StartDateTime.format('yyyy-MM-dd');      //contains 12/28/2012
            Datetime StartDateTime = WSCH_DateUtils.getDateTimeInUserLocale(technicianSlot.getStrStartDateTime());
            String strStartFinalDate = StartDateTime.date().format();      //contains 12/28/2012
            String strStartFinalTime = StartDateTime.format('hh:mm a');      //contains  4:30 PM
            Datetime EndDateTime = technicianSlot.getEndDateTime();
            String strEndFinalDate =  EndDateTime.date().format();
            String strEndFinalTime = EndDateTime.format('hh:mm a');
            String strDay = getWeekDay().get(technicianSlot.getDay());
            String strPromiseType = getPromiseType().get(technicianSlot.getPromType());
            String technicianName = technicianSlot.getTechnician() != null ? technicianSlot.getTechnician().Name : '';
            technicianName = String.isNotBlank(technicianName) ? technicianName : getTAG033(); /* Technician not Found in ServiceMax' */

            strMoreData = strMoreData + '<row id="' + (viewMoreIndex + i) + '">';
            /* create a first empty cell for the radio button */
            strMoreData = strMoreData + '<cell></cell>';
            /* populate the other cells for that row with the data */
            String strEachRow = '<cell>' + strPromiseType + ' </cell><cell>' + strDay + ' </cell><cell>' + strStartFinalDate + ' </cell><cell>' + strStartFinalTime + ' - ' + strEndFinalTime + ' </cell><cell>' + technicianName +'</cell></row>';
            strMoreData = strMoreData + strEachRow;
        }
        return strMoreData;
    }

    /**  Force book a job when there are no appointments available for a Work Order  **/
    public PageReference forceSchedule() {

        PageReference workOrderPage;
        try{
            List<String> lstOfWOIds = new List<String>();
            lstOfWOIds.add(strWORecordID);
            List<SVMXC__Service_Order__c> scheduleWorkOrderList = WSCH_CommonUtils.fetchWorkOrders(lstOfWOIds);

            for(SVMXC__Service_Order__c workOrder: scheduleWorkOrderList) {
                workOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_PENDING;
                workOrder.SVMXC__Scheduling_Change_Token__c = 'FORCE_SCHEDULE';
            }

            WSCH_OptimizedSchedulingService.triggerExecuted = true;
            WSCH_OptimizedSchedulingService.manageWorkOrders(scheduleWorkOrderList);

            //SVMXC__Service_Order__c workOrder = WSCH_CommonUtils.fetchWorkOrderById(strWORecordID);

            //set the Optimax_error_text to display in UI.Currently commented as we navigate back to WO immediately after forcebook
            //strForceBookMsg = workOrder.SVMXC__OptiMax_Error_Text__c;

            //do not display current appointment when force book is executed
            //isDisplayCurrentAppt = false;

            //do not display the available appointments panel after foce book is executed
            isBookApptSuccess = true;

            //display the appropriate message after force booking.Currently commented as we navigate back to WO immediately after forcebook
            //isDisplayForceBookMsg = true;

            //after booking job navigate back to this Work Order page
            workOrderPage = navigateToWorkOrder();

        } catch(Exception ex) {
            WSCH_AuditLogger.error('Exception caught:WSCH_Provider_SP_WOApptsController:forceSchedule() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return workOrderPage;
    }

    /** This method is used to get the already booked appointments on a Work Order **/
    public String getCurrentAppointment(String strWORecordID) {

        String strStartTime, strEndTime, strDay, strDate;
        /* 'This Work Order is already booked for the slot ' */
        String strMsg = getTAG034();
        SVMXC__Service_Order__c workOrder = WSCH_CommonUtils.fetchWorkOrderById(strWORecordID);

        if(String.isNotBlank(workOrder.SVMXC__Appointment_Promised_Time_Slot__c)){

            strCurrentApptMsg = String.format('{0} {1}.', new List<String>{strMsg, workOrder.SVMXC__Appointment_Promised_Time_Slot__c});
        } else if(workOrder.SVMXC__Scheduled_Date_Time__c != null) {

            DateTime scheduledDateTime = workOrder.SVMXC__Scheduled_Date_Time__c;
            DateTime scheduledEndTime = scheduledDateTime.addSeconds(Integer.valueOf(workOrder.SVMXC__Service_Duration__c));

            String day = scheduledDateTime.format('EEE');
            strDay = getWeekDay().get(day);

            String strStartDateTime = scheduledDateTime.format('yyyy-MM-dd hh:mm a');  //returns 02/06/2014 07:56 PM
            strDate =  scheduledDateTime.format('yyyy-MM-dd');
            strStartTime =  scheduledDateTime.format('hh:mm a');

            String strEndDateTime = scheduledEndTime.format('yyyy-MM-dd hh:mm a');    //returns 02/06/2014 07:56 PM
            strEndTime =  scheduledEndTime.format('hh:mm a');

            //strCurrentApptMsg = strMessage + strStartTime + ' - ' + strEndTime + ', ' + strDay + ', ' + strDate ;
            strCurrentApptMsg = String.format('{0}: {1} - {2}, {3}, {4}.', new List<String>{strMsg, strStartTime, strEndTime, strDay, strDate});
        }

        return strCurrentApptMsg;
    }

    public boolean getIsDisplayCurrentAppt() {
        return isDisplayCurrentAppt;
    }

    public boolean getIsDisplayForceBookMsg() {
        return isDisplayForceBookMsg;
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

    public boolean getDisplayViewMore() {
        return (getIsWOApptEmpty() || !displayViewMore);
    }

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

    /*  Dispatch optimization settings value is set to false.Please make it to true to get appointments */
    public static String getTAG026() {
        return system.label.DCON003_TAG026;
    }

    /*  GBL022 Setting is not set to Service Power. Please set it to Service Power to get the appointments  */
    public static String getTAG027() {
        return system.label.DCON003_TAG027;
    }

    /*  Exception occurred while making Offer Appointments call to SP   */
    public static String getTAG028() {
        return system.label.DCON003_TAG028;
    }

    /*  Exception occurred while making Book Appointment call to SP */
    public static String getTAG029() {
        return system.label.DCON003_TAG029;
    }

    /*  Work order is already qualified for a dispatch process of different service provider other than Service Power   */
    public static String getTAG030() {
        return system.label.DCON003_TAG030;
    }

    /*  No appointments as this Work Order has already been dispatched  */
    public static String getTAG031() {
        return system.label.DCON003_TAG031;
    }

    /*  No appointments as this Work Order is already in the process to be booked   */
    public static String getTAG032() {
        return system.label.DCON003_TAG032;
    }

    /*  Error: The technician specified by the ServicePower system does not exist in the ServiceMax system  */
    public static String getTAG033() {
        return system.label.DCON003_TAG033;
    }

    /*  This Work Order is already booked for the slot  */
    public static String getTAG034() {
        return system.label.DCON003_TAG034;
    }

    /*  Current Appointments    */
    public static String getTAG037() {
        return system.label.DCON003_TAG037;
    }
}