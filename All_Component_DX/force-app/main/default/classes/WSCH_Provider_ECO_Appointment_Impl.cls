public with sharing class WSCH_Provider_ECO_Appointment_Impl{
        
    public String numberOfDays;
    public String numberOfOfferAppts;
    Static String considerCostOrDates;
    public Static String bookedApptSlot; 
    public Static List<WSCH_Appointment> appointmentWithPoorSlotList = new List<WSCH_Appointment>();
    
    public WSCH_Provider_ECO_Appointment_Impl(){
    }
        
    public WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Response getWOAppointmentSettings(WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request request) {
        
        
        WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Settings defaultSettingValues = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Settings(); 
        WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Response response = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Response();
        response.success = true;
        
        String settingsGBL007 = WSCH_CommonUtils.getSettingValue('GLOB001', 'GBL007');
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getWOAppointmentSettings :: settingsGBL007 :: ' + settingsGBL007);
        //getting active real time optimization provider
        String strActiveProvider = WSCH_CommonUtils.getActiveRealTimeOptimizationEngine();
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getWOAppointmentSettings :: strActiveProvider :: ' + strActiveProvider);
        try{
        //Invokes the OptiMax ECO API?s based on the type of change in work order
        if(String.isEmpty(settingsGBL007) || String.isEmpty(strActiveProvider)) {
            response.success = false;
            response.messageList.add(system.label.OMAX004_TAG098);
            return response;    
        }
        if(String.isNotBlank(settingsGBL007) && settingsGBL007.touppercase() == 'FALSE' && String.isNotBlank(strActiveProvider) && !strActiveProvider.equals('OPTIMAXECO')) {
            response.success = false;
            response.messageList.add(system.label.OMAX004_TAG098);
            return response;     
        }
        BusinessHours bh;
        
        defaultSettingValues.numberOfOfferAppts = WSCH_CommonUtils.getSettingValue('DCON003','SET001'); //Number of appointments to be fetched for list view
        String showPoorCheckBox = 'false';
        String setVal = WSCH_CommonUtils.getSettingValue('DCON003','SET013');        
        if(String.isNotBlank(setVal)){
            showPoorCheckBox = setVal;
        }        
        defaultSettingValues.showPoorCheckBoxSettingVal = showPoorCheckBox; 
        defaultSettingValues.numberOfOfferAppts = WSCH_CommonUtils.getSettingValue('DCON003','SET001'); //Number of appointments to be fetched for list view
        //defaultSettingValues.numberOfDays = WSCH_CommonUtils.getSettingValue('DCON004','SET012'); //Preferred scheduling horizon in days for job book requests
        String numberOfDays = WSCH_CommonUtils.getSettingValue('DCON004','SET012'); //Preferred scheduling horizon in days for job book requests
        defaultSettingValues.considerCostOrDates= 'Date';
        String workOrderId = request.headerId;
        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getWOAppointmentSettings :: workOrderId ::' +workOrderId);      
        SVMXC__Service_Order__c workOrderRecord = WSCH_CommonUtils.fetchWorkOrderById(workOrderId);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getWOAppointmentSettings :: workOrderRecord ::' +workOrderRecord);
        String territoryId = '';
        String territoryTimezone ='';
        String bookedApptPromisedSlot = '';        
        String appointmentType = '';      
        String schedulingStatus = '';
        String optiMaxStatus = '';
        String dependencyGroup = '';
        String zip = '';
        String serviceDuration = '';
        String country = '';
        Decimal latitude;
        Decimal longitude;
        if(workOrderRecord != null) {
            bookedApptPromisedSlot = workOrderRecord.SVMXC__Appointment_Promised_Time_Slot__c;
            territoryId = workOrderRecord.SVMXC__Primary_Territory__c;
            appointmentType = workOrderRecord.SVMXC__SM_Appointment_Type__c;
            schedulingStatus = workOrderRecord.SVMXC__Work_Order_Scheduling_Status__c;            
            optiMaxStatus = workOrderRecord.SVMXC__OptiMax_Status__c;
            dependencyGroup = workOrderRecord.SVMXC__Dependency_Group__c;
            zip = workOrderRecord.SVMXC__Zip__c;
            serviceDuration = (workOrderRecord.SVMXC__Service_Duration__c != null) ? String.valueOf(workOrderRecord.SVMXC__Service_Duration__c) : '';
            country = workOrderRecord.SVMXC__Country__c;
            latitude = workOrderRecord.SVMXC__Latitude__c;
            longitude = workOrderRecord.SVMXC__Longitude__c;
            Boolean isError = false;
            String errorMsg = '';
            Boolean isLatLongThere = false;
            
            if(!String.isEmpty(dependencyGroup)) {
                errorMsg = errorMsg+ system.label.OMAX004_TAG084+'\n';
                isError = true; 
            } 
            if(String.isEmpty(territoryId)) {
                errorMsg = errorMsg+ system.label.OMAX004_TAG099 +'\n';
                isError = true; 
            }
            if(latitude != NULL && longitude != NULL) {
                isLatLongThere = true;
            }
            if(!isLatLongThere && (String.isEmpty(zip) || String.isEmpty(country))) {
                errorMsg = errorMsg+ system.label.OMAX004_TAG100 +'\n';
                isError = true; 
            }  
            if(String.isEmpty(serviceDuration)) {
                errorMsg = errorMsg+ system.label.OMAX004_TAG101 +'\n';
                isError = true; 
            } 
            if(String.isEmpty(appointmentType)) {
                errorMsg = errorMsg+ system.label.OMAX004_TAG102 +'\n';
                isError = true; 
            }  
            if(!String.isEmpty(schedulingStatus) && ('Dispatched'.equalsIgnoreCase(schedulingStatus) || 'Cancelled'.equalsIgnoreCase(schedulingStatus))) {
                errorMsg = errorMsg+ system.label.OMAX004_TAG103 + schedulingStatus +'\n'; 
                isError = true;
            } 
            if(!String.isEmpty(optiMaxStatus) && 'OPT_PENDING'.equalsIgnoreCase(optiMaxStatus)) {
                errorMsg = errorMsg+ system.label.OMAX004_TAG104 + optiMaxStatus;
                isError = true; 
            }
            if(workOrderRecord.SVMXC__Locked_By_DC__c == true) {
                errorMsg = errorMsg + system.label.OMAX004_TAG116; 
                isError = true;
            }
            
            if(isError) {
                response.success = false;
                response.messageList.add(errorMsg);
                WSCH_AuditLogger.finish();
                return response;    
            }
            SVMXC__Territory__c terrObj = [Select  Id,
                                                     Name, 
                                                     SVMXC__Active__c, 
                                                     SVMXC__Territory_s_Business_Hours__c, 
                                                     SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey,
                                                     SVMXC__Break_Hours__c,
                                                     SVMXC__Average_Driving_Time__c,
                                                     SVMXC__Per_Mile_Cost__c,
                                                     SVMXC__Max_Distance__c,
                                                     SVMXC__Average_Speed__c,
                                                     SVMXC__Fixed_Cost__c,
                                                     SVMXC__Per_hour_Cost__c,
                                                     SVMXC__Mode_Of_Travel__c
                                                from SVMXC__Territory__c 
                                               WHERE Id =:territoryId
                                            ];
            List<SVMXC__SVMX_Jobs__c> lstSVMXJob = [Select id, Name, SVMXC__OptiMax_Message__c, SVMXC__SVMX_Process__c, 
                                    SVMXC__Territory__c,SVMXC__Start_Time__c,SVMXC__Age__c, SVMXC__Status__c, 
                                    SVMXC__End_Time__c,SVMXC__Type__c from SVMXC__SVMX_Jobs__c where 
                                    SVMXC__Territory__c = :terrObj.Id and SVMXC__Type__c = 'ECO'];
            
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getWOAppointmentSettings :: lstSVMXJob ::' +lstSVMXJob);                        
            
            
            List<SVMXC__ServiceMax_Processes__c> lstProcessObj = [SELECT SVMXC__Process__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Territory__c =: terrObj.Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getWOAppointmentSettings :: lstProcessObj ::' +lstProcessObj);
            if(lstProcessObj == null || lstProcessObj.size() == 0) {                               
                response.success = false;
                response.messageList.add(system.label.OMAX004_TAG094+' '+terrObj.name);
                return response;    
            }
            SVMXC__ServiceMax_Processes__c dp = [SELECT Id, SVMXC__Calendar_End_Days__c FROM SVMXC__ServiceMax_Processes__c WHERE Id =: lstProcessObj[0].SVMXC__Process__c];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getWOAppointmentSettings :: dp ::' +dp);
            if(dp != null) {                
                defaultSettingValues.territoryId = terrObj.Id;
                defaultSettingValues.dispatchProcessId = dp.Id;
                if(lstSVMXJob == null || lstSVMXJob.size() == 0) {  
                                            
                    defaultSettingValues.jobStatus = '';
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: startOptimaxJob:: workOrderRecord ::' +workOrderRecord);
                    List<SVMXC__Service_Order__c> listworkOrderRecords= new List<SVMXC__Service_Order__c>();
                    listworkOrderRecords.add(workOrderRecord);
                    //added the below message to notify the user that the job is being initiated even before the initJob call
                    defaultSettingValues.jobStatusWarningMsg = (system.label.OMAX004_TAG095+' '+terrObj.name);
                            
                    List<String> lstOfWOIds = new List<String>();
                    lstOfWOIds.add(workOrderRecord.Id);
                    response.success = false;
                    response.messageList.add(system.label.OMAX004_TAG095+' '+terrObj.name);
                    response.appointmentSettings= defaultSettingValues;
                    initJob(lstOfWOIds);
                    return response;
                    
                    //WSCH_Provider_ECO_Stubs.Response_WP response_x = initJob(terrObj, listworkOrderRecords);                    
                    /*WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: startOptimaxJob:: response_x ::' +response_x);
                    if(response_x.status == '200') {                      
                        defaultSettingValues.jobStatusWarningMsg = (system.label.OMAX004_TAG095+' '+terrObj.name);     
                    } else {
                        defaultSettingValues.jobStatusWarningMsg = (system.label.OMAX004_TAG096 +' '+terrObj.name +'. '+response_x.message);
                    }*/
                } else {                
                    if(lstSVMXJob[0].SVMXC__OptiMax_Message__c =='RUNNING') {
                        defaultSettingValues.jobStatus = 'RUNNING'; 
                        defaultSettingValues.jobStatusWarningMsg = '';
                    } else if(lstSVMXJob[0].SVMXC__OptiMax_Message__c =='RESUMING') {
                        defaultSettingValues.jobStatus = 'RESUMING'; 
                        defaultSettingValues.jobStatusWarningMsg = (system.label.OMAX004_TAG095+' '+terrObj.name);
                    } else if(lstSVMXJob[0].SVMXC__OptiMax_Message__c =='SUSPENDED') {
                        defaultSettingValues.jobStatus = 'SUSPENDED';
                        //added the below message to notify the user that the job is being resumed even before the resumeJob call
                        defaultSettingValues.jobStatusWarningMsg = (system.label.OMAX004_TAG095+' '+terrObj.name);

                        String strDPIdTerrId = dp.Id + '-' + terrObj.Id;
                        List<String> lstOfDPIdTerrId = new List<String>();
                        lstOfDPIdTerrId.add(strDPIdTerrId);
                        response.success = false;
                        response.messageList.add(system.label.OMAX004_TAG095+' '+terrObj.name);
                        response.appointmentSettings= defaultSettingValues;
                        resumeJob(lstOfDPIdTerrId);
                        return response;

                        //WSCH_Provider_ECO_Stubs.Response_WP  responseWP = resumeJob(dp.Id, terrObj.Id);
                        /*if(responseWP.status == '202') {
            
                            List<SVMXC__SVMX_Jobs__c> lstSVMXJobs = [Select id, Name, SVMXC__OptiMax_Message__c, SVMXC__SVMX_Process__c, 
                                    SVMXC__Territory__c,SVMXC__Start_Time__c,SVMXC__Age__c, SVMXC__Status__c, 
                                    SVMXC__End_Time__c,SVMXC__Type__c from SVMXC__SVMX_Jobs__c where 
                                    SVMXC__Territory__c = :terrObj.Id and SVMXC__Type__c = 'ECO' limit 1];
                            lstSVMXJobs[0].SVMXC__OptiMax_Message__c = 'RESUMING';
                            update lstSVMXJobs[0];
                                    
                             
                            //defaultSettingValues.jobStatusWarningMsg = (system.label.OMAX004_TAG095+' '+terrObj.name);
                        } else {
                            defaultSettingValues.jobStatusWarningMsg = (system.label.OMAX004_TAG096 +' '+terrObj.name);
                        }*/
                    } else {
                            //lstSVMXJob[0].SVMXC__OptiMax_Message__c =='IDLE' or 'FAILED'
                            defaultSettingValues.jobStatus = lstSVMXJob[0].SVMXC__OptiMax_Message__c;
                            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: startOptimaxJob:: workOrderRecord ::' +workOrderRecord);
                            List<SVMXC__Service_Order__c> listworkOrderRecords= new List<SVMXC__Service_Order__c>();
                            listworkOrderRecords.add(workOrderRecord);
                            //added the below message to notify the user that the job is being initiated even before the initJob call
                            defaultSettingValues.jobStatusWarningMsg = (system.label.OMAX004_TAG095+' '+terrObj.name);
                            
                            List<String> lstOfWOIds = new List<String>();
                            lstOfWOIds.add(workOrderRecord.Id);
                            response.success = false;
                            response.messageList.add(system.label.OMAX004_TAG095+' '+terrObj.name);
                            response.appointmentSettings= defaultSettingValues;
                            initJob(lstOfWOIds);
                            return response;
                            
                            //WSCH_Provider_ECO_Stubs.Response_WP response_x = initJob(terrObj, listworkOrderRecords);
                            /*if(response_x.status == '200') {                      
                                defaultSettingValues.jobStatusWarningMsg = (system.label.OMAX004_TAG095+' '+terrObj.name);     
                            } else {
                                defaultSettingValues.jobStatusWarningMsg = (system.label.OMAX004_TAG096 +' '+terrObj.name +'. '+response_x.message); 
                            }*/
                    }
                }
            } else {                
                response.success = false;
                response.messageList.add(system.label.OMAX004_TAG094+' '+terrObj.name);
                return response;
            }
            
            if(dp != null && dp.SVMXC__Calendar_End_Days__c != null && dp.SVMXC__Calendar_End_Days__c > 0) {
                numberOfDays = String.valueOf(dp.SVMXC__Calendar_End_Days__c);
                defaultSettingValues.numberOfDays = numberOfDays;
            } else {
                defaultSettingValues.numberOfDays = numberOfDays;    
            }
            
            //defaultSettingValues.numberOfDays = (dp != null && dp.SVMXC__Calendar_End_Days__c != null) ? String.valueOf(dp.SVMXC__Calendar_End_Days__c) : 7;
            bh = [Select Id, Name, IsDefault, IsActive, TimeZoneSidKey, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
                            ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime
                            from BusinessHours WHERE Id =: terrObj.SVMXC__Territory_s_Business_Hours__c];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            territoryTimezone = bh !=null ? bh.TimeZoneSidKey : '';
        }
        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getWOAppointmentSettings :: territoryTimezone ::' +territoryTimezone);
        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getWOAppointmentSettings :: UserInfo.getTimeZone() ::' +UserInfo.getTimeZone());
        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getWOAppointmentSettings :: Datetime.now() ::' +Datetime.now());
        
        DateTime fromDt = Datetime.now();
        //DateTime toDt = fromDt.addDays(integer.valueOf(defaultSettingValues.numberOfDays)-1);
        WSCH_AuditLogger.debug('fromDt - ' + fromDt);
        integer numOfDays = Integer.valueof(numberOfDays.trim());
        numOfDays = numOfDays - 1;// BusinessHours.nextStartDate will give next working day, if the current day is working day it gives current day

        //get next startDT in GMT tz        
        Datetime nextStart = BusinessHours.nextStartDate(bh.id, fromDt);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getWOAppointmentSettings :: next working day ::' +nextStart);
        Datetime territoryStartDt = WSCH_DateUtils.doTZConversion(nextStart, 'GMT' , territoryTimezone);
        
        for (integer i = 0; i < numOfDays; i++) {
            nextStart = BusinessHours.nextStartDate(bh.id, nextStart.addDays(1));
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getWOAppointmentSettings :: nextStart ::i '+i +'---'+nextStart);
        }
        DateTime toDT = nextStart;
        
        //get the current datetime in territory tz
        Datetime territoryEndDt = WSCH_DateUtils.doTZConversion(toDT, 'GMT' , territoryTimezone);
        //getting the datetime with actual endTime for this BH
        List<DateTime> lstOfBhStEndDateTimeForStartDay = WSCH_CommonUtils.getBHStartEndDateTime(territoryEndDt.dateGmt(),bh);
        if(lstOfBhStEndDateTimeForStartDay != null && lstOfBhStEndDateTimeForStartDay.size() == 2) {
            territoryEndDt = lstOfBhStEndDateTimeForStartDay.get(1);
        }

        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getWOAppointmentSettings :: Current GMT DT to territory DT ::' +territoryStartDt);                        
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getWOAppointmentSettings :: End GMT DT to territory DT ::' +territoryEndDt);  
        
        
        
        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getWOAppointmentSettings :: territoryTimezone time ::' +WSCH_DateUtils.doTZConversion(Datetime.now(), UserInfo.getTimeZone().getDisplayName() , territoryTimezone));
        defaultSettingValues.territoryTimezoneOffset = getGMTOffSet(territoryStartDt, territoryTimezone);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getWOAppointmentSettings :: defaultSettingValues.territoryTimezoneOffset ::' +defaultSettingValues.territoryTimezoneOffset);
        
        defaultSettingValues.territoryTimezone = territoryTimezone;
        //defaultSettingValues.startDate= localeDateFormat(territoryStartDt.date());
        //defaultSettingValues.endDate= localeDateFormat(territoryEndDt.date());
        
        String territoryStartDtStr = String.valueOfGMT(territoryStartDt);
        String[] territoryStartDtStrArray = territoryStartDtStr.split(' ');
        //defaultSettingValues.startDate = territoryStartDtStrArray[0];
        
        String territoryEndDtStr = String.valueOfGMT(territoryEndDt);
        String[] territoryEndDtStrArray = territoryEndDtStr.split(' ');
        //defaultSettingValues.endDate = territoryEndDtStrArray[0];
        
        //Setting horizon start and enddate in territory tz
        defaultSettingValues.horizonStartDate = territoryStartDtStrArray[0];
        defaultSettingValues.horizonEndDate = territoryEndDtStrArray[0];        
        //defaultSettingValues.horizonStartDate = territoryStartDtStr;
        //defaultSettingValues.horizonEndDate = territoryEndDtStr;        

        
        //check the work order have PST and PET then set the calendar start and end as PST and PET
        //convert PST and PET to territory TZ
        //compare with horizon start and end
        //set two new dt for calender display purpose
        if(workOrderRecord != null) {
            if(workOrderRecord.SVMXC__Preferred_Start_Time__c != null && workOrderRecord.SVMXC__Preferred_End_Time__c != null) {
                Datetime pSTStartDt = WSCH_DateUtils.doTZConversion(workOrderRecord.SVMXC__Preferred_Start_Time__c, 'GMT' , territoryTimezone);
                Datetime pETEndDt = WSCH_DateUtils.doTZConversion(workOrderRecord.SVMXC__Preferred_End_Time__c, 'GMT' , territoryTimezone);
                
                String pSTStartDtStr = String.valueOfGMT(pSTStartDt);
                String[] pSTStartDtStrArray = pSTStartDtStr .split(' ');
                String pETEndDtStr = String.valueOfGMT(pETEndDt);
                String[] pETEndDtStrArray = pETEndDtStr.split(' ');
                Boolean considerPST = true;
                Boolean considerPET = true;
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getWOAppointmentSettings :: pSTStartDt territory DT ::' +pSTStartDt);  
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getWOAppointmentSettings :: pETEndDt territory DT ::' +pETEndDt);  
       
                if(pSTStartDt >= territoryStartDt && pSTStartDt <= territoryEndDt ) {
                                
                } else {
                    considerPST = false;
                }            
                
                if(pETEndDt>= territoryStartDt && pETEndDt<= territoryEndDt) {
                } else {               
                    considerPET = false; 
                }
                if(considerPST && considerPET) {
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getWOAppointmentSettings :: consider PST and PET');  
                    defaultSettingValues.startDate = pSTStartDtStrArray [0];
                    defaultSettingValues.endDate = pETEndDtStrArray[0];
                    defaultSettingValues.startDateTime = pSTStartDtStr;
                    defaultSettingValues.endDateTime = pETEndDtStr;
                    
                } else if(considerPST == false && considerPET == false) {
                    defaultSettingValues.startDate = territoryStartDtStrArray[0];
                    defaultSettingValues.endDate = territoryEndDtStrArray[0];
                    defaultSettingValues.startDateTime = territoryStartDtStr;
                    defaultSettingValues.endDateTime = territoryEndDtStr;
                    defaultSettingValues.outSideHzDtWarningMsg = system.label.OMAX004_TAG105;        
                } else {
                    if(considerPST) {
                        defaultSettingValues.startDate = pSTStartDtStrArray[0];                        
                        defaultSettingValues.startDateTime = pSTStartDtStr;
                    }else {
                        defaultSettingValues.startDate = territoryStartDtStrArray[0];
                        defaultSettingValues.startDateTime = territoryStartDtStr;
                        defaultSettingValues.outSideHzDtWarningMsg = system.label.OMAX004_TAG106;        
                    }
                    
                    if(considerPET) {
                        defaultSettingValues.endDate = pETEndDtStrArray[0];                        
                        defaultSettingValues.endDateTime = pETEndDtStr;
                    } else {
                        defaultSettingValues.endDate = territoryEndDtStrArray[0];
                        defaultSettingValues.endDateTime = territoryEndDtStr;
                        defaultSettingValues.outSideHzDtWarningMsg = system.label.OMAX004_TAG107;        
                    }
                }
            
            } else {
                if(workOrderRecord.SVMXC__Preferred_Start_Time__c == null && workOrderRecord.SVMXC__Preferred_End_Time__c == null) {
                    defaultSettingValues.startDate = territoryStartDtStrArray[0];
                    defaultSettingValues.endDate = territoryEndDtStrArray[0];       
                    defaultSettingValues.startDateTime = territoryStartDtStr;
                    defaultSettingValues.endDateTime = territoryEndDtStr;       
                } else {
                    if(workOrderRecord.SVMXC__Preferred_Start_Time__c != null) {
                        Datetime pSTStartDt = WSCH_DateUtils.doTZConversion(workOrderRecord.SVMXC__Preferred_Start_Time__c, 'GMT' , territoryTimezone);   
                        String pSTStartDtStr = String.valueOfGMT(pSTStartDt);
                        String[] pSTStartDtStrArray = pSTStartDtStr .split(' ');
                        Boolean considerPST = true;
                        if(!(pSTStartDt >= territoryStartDt && pSTStartDt <= territoryEndDt) ) {
                            considerPST = false;            
                        }
                        if(considerPST) {
                            defaultSettingValues.startDate = pSTStartDtStrArray[0];
                            defaultSettingValues.startDateTime = pSTStartDtStr;
                        } else {
                            defaultSettingValues.startDate = territoryStartDtStrArray[0];                           
                            defaultSettingValues.startDateTime = territoryStartDtStr;
                            defaultSettingValues.outSideHzDtWarningMsg = system.label.OMAX004_TAG106;        
                        }
                    } else {
                        defaultSettingValues.startDate = territoryStartDtStrArray[0]; 
                        defaultSettingValues.startDateTime = territoryStartDtStr;   
                    } 
                    if(workOrderRecord.SVMXC__Preferred_End_Time__c != null) {
                        Datetime pETEndDt = WSCH_DateUtils.doTZConversion(workOrderRecord.SVMXC__Preferred_End_Time__c, 'GMT' , territoryTimezone);
                        String pETEndDtStr = String.valueOfGMT(pETEndDt);
                        String[] pETEndDtStrArray = pETEndDtStr.split(' ');                        
                        Boolean considerPET = true;
                        if(!(pETEndDt>= territoryStartDt && pETEndDt<= territoryEndDt)) {
                            considerPET = false;
                        } 
                        if(considerPET) {
                            defaultSettingValues.endDate = pETEndDtStrArray[0];                        
                            defaultSettingValues.endDateTime = pETEndDtStr;
                        } else {
                            defaultSettingValues.endDate = territoryEndDtStrArray[0];
                            defaultSettingValues.endDateTime = territoryEndDtStr;
                            defaultSettingValues.outSideHzDtWarningMsg = system.label.OMAX004_TAG107;        
                        }
                    } else {
                        defaultSettingValues.endDate = territoryEndDtStrArray[0];  
                        defaultSettingValues.endDateTime = territoryEndDtStr;   
                    }   
                }
            
            }
        }
        
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getWOAppointmentSettings :: defaultSettingValues.startDate ::' +defaultSettingValues.startDate);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getWOAppointmentSettings :: defaultSettingValues.endDate ::' +defaultSettingValues.endDate);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getWOAppointmentSettings :: defaultSettingValues.horizonStartDate ::' +defaultSettingValues.horizonStartDate);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getWOAppointmentSettings :: defaultSettingValues.horizonEndDate ::' +defaultSettingValues.horizonEndDate);
        
        
        //String bookedApptSlotCost = '';
        //String bookedApptSlotCategory = '';
        String bookedApptSlot = '';
        if(!String.isEmpty(bookedApptPromisedSlot)) {
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getWOAppointmentSettings :: bookedApptPromisedSlot ::' +bookedApptPromisedSlot);
            List<String> bookedApptSlotArray = bookedApptPromisedSlot.split(',', -1);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getWOAppointmentSettings :: bookedApptSlotArray ::' +bookedApptSlotArray);
            if(bookedApptSlotArray != null && bookedApptSlotArray.size() > 1) {
                if(!String.isEmpty(bookedApptSlotArray[0]) && !String.isEmpty(bookedApptSlotArray[1])) {
                    bookedApptSlot = bookedApptSlotArray[0].trim() + ','+ bookedApptSlotArray[1].trim();    
                }
                /*if(!String.isEmpty(bookedApptSlotArray[2])) {
                    bookedApptSlotCost = bookedApptSlotArray[2];    
                }
                if(!String.isEmpty(bookedApptSlotArray[3])) {
                    bookedApptSlotCategory = bookedApptSlotArray[3];    
                }  */         
            }   
        }
        //defaultSettingValues.bookedApptSlotCost = bookedApptSlotCost;        
        //defaultSettingValues.bookedApptSlotCategory = bookedApptSlotCategory;
        defaultSettingValues.bookedApptSlot = bookedApptSlot;
        defaultSettingValues.considerPoorSlots = 'HidePoor'; 
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getWOAppointmentSettings :: defaultSettingValues ::' +defaultSettingValues);
        
        response.appointmentSettings= defaultSettingValues;
        WSCH_AuditLogger.finish();    
        return response;
        }catch(Exception e){
            WSCH_AuditLogger.error('WSCH_Provider_ECO_Appointment_Impl :: getWOAppointmentSettings :: exception  ::' +e);        
            WSCH_AuditLogger.finish();          
            response.success = false;
            response.messageList.add('Error while getting WorkOrder Appointment Settings');
            return response;            
        }
    }
    
   /*public String getGMTOffSet(DateTime resDateTime, String strTimeZone) {
        integer offSet;
        TimeZone targetTimeZone;
        if(resDateTime != null && String.isNotBlank(strTimeZone)) {
            targetTimeZone= TimeZone.getTimeZone(strTimeZone);
            offSet = targetTimeZone.getOffset(resDateTime);
        }
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getGMTOffSet :: offSet ::' + offSet );
        return String.valueOf(offSet);
    }*/
    
    
    
   public String getGMTOffSet(DateTime resDateTime, String strTimeZone) {
        Integer offSet;
        TimeZone targetTimeZone;
        if(resDateTime != null && String.isNotBlank(strTimeZone)) {
            targetTimeZone= TimeZone.getTimeZone(strTimeZone);
            offSet = targetTimeZone.getOffset(resDateTime);
        }
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getGMTOffSet :: offSet integer ::' + offSet );
        
        String OffsetSign = '+', Hours = '00', Minutes = '00';
        
        try{
            Integer TimeZoneOffsetMiliSec = offSet;
            if(TimeZoneOffsetMiliSec < 0) OffsetSign = '-';
            Integer TimeZoneOffsetMinutes = Integer.valueOf((math.abs(TimeZoneOffsetMiliSec))/60000);
            if(TimeZoneOffsetMinutes >= 60){
                Hours = String.valueOf(TimeZoneOffsetMinutes/60);
                Minutes = String.valueOf(math.mod(TimeZoneOffsetMinutes, 60));
            }
            else
                Minutes = String.valueOf(TimeZoneOffsetMinutes);
            
            if(Hours != NULL && Hours.length() < 2)
                Hours = '0' + Hours;
                
            if(Minutes != NULL && Minutes.length() < 2)
                Minutes = '0' + Minutes;
        }
        catch(Exception ex){
            System.debug('Error: '+ ex.getMessage());
        }
        String retOffset = OffsetSign + Hours + ':' + Minutes;
        System.debug('Offset: '+ retOffset);        
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getGMTOffSet :: retOffset ::' + retOffset );
        return retOffset;
    }
    
    public String localeDateFormat(Date dateValue){
        return (dateValue != null) ? dateValue.format() : null;
    }
    
    public WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Response getWorkOrderDetails (WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request request) {
        
        WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Response response = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Response();
        response.success = true;
        if(request == null || request.headerId == null){
            response.success = false;
            response.messageList.add(System.Label.EVER001_TAG087); //Invalid Request
            return response;
        }
        String workOrderId = request.headerId;
        String queryString;
        try{
            
            queryString = 'select Id, Name, SVMXC__Company__r.Name, SVMXC__Contact__r.Name, SVMXC__Component__r.SVMXC__Product_Name__c ';
            queryString = queryString + ' FROM SVMXC__Service_Order__c WHERE Id = \'' + workOrderId + '\'';
            SVMXC__Service_Order__c workOrderRecord = Database.query(queryString); 
            WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_HeaderRecord headerRecord = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_HeaderRecord();   
            headerRecord.recordID = workOrderRecord.Id;
            headerRecord.recordName = workOrderRecord.Name;
            headerRecord.accountName = workOrderRecord.SVMXC__Company__r.Name;
            headerRecord.contactName = workOrderRecord.SVMXC__Contact__r.Name;
            headerRecord.productName = workOrderRecord.SVMXC__Component__r.SVMXC__Product_Name__c;
            response.headerRecord = headerRecord;           
        }catch(Exception ex){
            response.success = false;
            response.messageList.add( ex.getMessage() );
        }
        return response; 
    }   
    
    
    public WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Response getOfferAppointments(WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request request) {
        WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Response response = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Response();
        WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_HeaderRecord headerRecord = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_HeaderRecord();
        List<WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_OfferAppointments> offerAppointmentsList = new List<WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_OfferAppointments>(); 
        List<WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_OfferAppointments> offerApptWithPoorList = new List<WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_OfferAppointments>();
        Map<String,List<WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_OfferAppointments>> offerAppointmentsMap = new Map<String,List<WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_OfferAppointments>>();
        Map<String,List<WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_OfferAppointments>> offerApptMapWithPoorMap = new Map<String,List<WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_OfferAppointments>>();
      
        String strWORecordID = request.headerId;
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getOfferAppointments :: Request.appointmentSettings' + request.appointmentSettings);  
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getOfferAppointments :: strWORecordID' + strWORecordID);        
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getOfferAppointments :: request.headerId' + request.headerId);
        //Integer slotsSize = 99;
        Integer slotsSize = integer.valueOf(request.appointmentSettings.numberOfOfferAppts);
        String bookedApptPromisedSlot = request.appointmentSettings.bookedApptSlot;
        String territoryTimezone = request.appointmentSettings.territoryTimezone;
        WSCH_AuditLogger.debug('slotsSize: ' + slotsSize);
        
        WSCH_AppointmentsResponse technicianSlotResponse = new WSCH_AppointmentsResponse();
        WSCH_ApptParam apptParamObj = new WSCH_ApptParam();
        apptParamObj.numberOfOfferAppts = Integer.valueOf(request.appointmentSettings.numberOfOfferAppts);
        apptParamObj.costOrDates = request.appointmentSettings.considerCostOrDates;
                        
        apptParamObj.endDateTime = Datetime.valueOfGmt(request.appointmentSettings.endDateTime);
        
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getOfferAppointments :: apptParamObj.endDateTime in Ter TZ before converstion..' + apptParamObj.endDateTime);       
        
        //converting the datetime from User TZ to Territory TZ.commenting below line as already the datetime is coming in territory timezone
        //apptParamObj.endDateTime = WSCH_DateUtils.doTZConversion(apptParamObj.endDateTime, String.valueOf(UserInfo.getTimeZone()), territoryTimezone);
        //converting the datetime from Territory TZ to GMT        
        apptParamObj.endDateTime = WSCH_DateUtils.doTZConversion(apptParamObj.endDateTime, territoryTimezone , 'GMT');
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getOfferAppointments ::apptParamObj.endDateTime in GMT timezone ' + apptParamObj.endDateTime);
        
        apptParamObj.startDateTime = Datetime.valueOfGmt(request.appointmentSettings.startDateTime);
        
        //apptParamObj.startDateTime = Datetime.valueOfGmt(request.appointmentSettings.startDate);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getOfferAppointments ::apptParamObj.startDateTime in territoryTZ..' + apptParamObj.startDateTime);
        //converting the datetime from User TZ to Territory TZ.commenting below line as already the datetime is coming in territory timezone
        //apptParamObj.startDateTime = WSCH_DateUtils.doTZConversion(apptParamObj.startDateTime, String.valueOf(UserInfo.getTimeZone()), territoryTimezone);
        //converting the datetime to GMT from Territory TZ
        apptParamObj.startDateTime = WSCH_DateUtils.doTZConversion(apptParamObj.startDateTime, territoryTimezone, 'GMT');
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getOfferAppointments ::apptParamObj.startDateTime in GMT timezone ' + apptParamObj.startDateTime);
            
        String settingsGBL007 = WSCH_CommonUtils.getSettingValue('GLOB001', 'GBL007');
        WSCH_AuditLogger.debug('settingsGBL007: ' + settingsGBL007);
        //getting active real time optimization provider
        String strActiveProvider = WSCH_CommonUtils.getActiveRealTimeOptimizationEngine();
        WSCH_AuditLogger.debug('Active Provider: ' + strActiveProvider);
        
        //Invokes the OptiMax ECO API?s based on the type of change in work order
        if(String.isNotBlank(settingsGBL007) && settingsGBL007.touppercase() == 'FALSE' && String.isNotBlank(strActiveProvider) && !strActiveProvider.equals('OPTIMAXECO')) {
            return null;    
        }
        WSCH_Provider_ECO_Appointment_Impl.bookedApptSlot = bookedApptPromisedSlot;            
        response.success = true;
        try {
            technicianSlotResponse = WSCH_OptimizedSchedulingService.getAvailableAppointments(strWORecordID, apptParamObj, slotsSize, 1);
            //String jsonString = JSON.serialize(technicianSlotResponse);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getOfferAppointments :: technicianSlotResponse:' + technicianSlotResponse);
           
            if(technicianSlotResponse == null) {
                response.success = false;
                response.messageList.add(system.label.OMAX004_TAG108);
                //return response;    
            } else {
                if(technicianSlotResponse.statusCode == 0) {
                    response.success = true;
                } else if(technicianSlotResponse.statusCode == 1) {
                    response.success = false;
                    response.messageList.add(system.label.OMAX004_TAG042);
                    //return response;    
                } else if(technicianSlotResponse.statusCode == 2) {
                    response.success = false;
                    response.messageList.add(system.label.OMAX004_TAG044);
                    //return response;    
                } else if(technicianSlotResponse.statusCode == 3) {
                    response.success = false;
                    response.messageList.add(system.label.OMAX004_TAG046);
                    //return response;    
                } else if(technicianSlotResponse.statusCode == 4) {
                    response.success = false;
                    response.messageList.add(system.label.OMAX004_TAG048);
                    //return response;    
                } else if(technicianSlotResponse.statusCode == 6) {
                    response.success = false;
                    response.messageList.add(system.label.OMAX004_TAG057);
                    //return response;    
                }else if(technicianSlotResponse.statusCode == 7) {
                    response.success = false;
                    response.messageList.add(system.label.OMAX004_TAG093);
                    //response.messageList.add('Unfortunately, there is no appointment windows for non working day. Please contact administrator.');
                    //return response;    
                } else {
                    response.success = false;
                    response.messageList.add(system.label.OMAX004_TAG108);
                    //return response;    
                }
            }
            
            if(!response.success) {             
                WSCH_AuditLogger.finish();
                return response;  
            }
            List<WSCH_Appointment> appointmentList = technicianSlotResponse.appointmentList;
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getOfferAppointments :: appointmentList :===>' + appointmentList);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getOfferAppointments :: appointmentList :===>' + appointmentList.size());
            List<WSCH_Appointment> appointmentWithPoorSlotList = WSCH_Provider_ECO_Appointment_Impl.appointmentWithPoorSlotList;
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getOfferAppointments :: appointmentWithPoorSlotList:===>' + appointmentWithPoorSlotList);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getOfferAppointments :: appointmentWithPoorSlotList:===>' + appointmentWithPoorSlotList.size());
            
            String isPoorSlotsAvailable = 'no';
            if(appointmentList != null && appointmentList.size() > 0) {
                for (integer i = 0; i<appointmentList.size(); i++) {
                    WSCH_Appointment appointment = appointmentList.get(i);
                    //WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getOfferAppointments :: appointmentList:===>' + i);
                    //WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getOfferAppointments :: appointmentList:===>' + appointment );
              
                    String apptOfferDay = '';
                    String apptOfferTime = '';
                    String technicians = '';                    
                    String slotCost = '';
                    String offerApptStDateTime = '';
                    String offerApptEndDateTime = '';
                    String costCategory = '';
                    String slotCategoryCost = '';                    
                    String slotCategory = '';
                    if(appointment != null) {
                        if(appointment.getStartDateTime() != null && appointment.getEndDateTime() != null) {
                            DateTime apptSlotStartDate = WSCH_DateUtils.doTZConversion(appointment.getStartDateTime(), 'GMT' , territoryTimezone);
                            DateTime apptSlotEndDate =  WSCH_DateUtils.doTZConversion(appointment.getEndDateTime(), 'GMT' , territoryTimezone);                         
                            offerApptStDateTime = String.valueOfGMT(appointment.getStartDateTime());
                            offerApptEndDateTime = String.valueOfGMT(appointment.getEndDateTime());
                            //apptOfferDay = apptSlotStartDate.formatGmt('E, MMM dd');
                            //apptOfferDay = String.valueOfGMT(appointment.getStartDateTime());
                            apptOfferDay = String.valueOfGMT(apptSlotStartDate);
                            apptOfferTime = apptSlotStartDate.formatGmt('hh:mm a') + '-' + apptSlotEndDate.formatGmt('hh:mm a');
                        }
                        List<String> techniciansList = appointment.getTechnicians();
                        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getOfferAppointments :: appointment : techniciansList ===>' + techniciansList);
                        if(techniciansList != null && techniciansList.size() > 0 ) {
                            technicians = String.join(techniciansList, ', ');
                        }
                        
                        costCategory =  appointment.getSlotCategory() != null ? appointment.getSlotCategory() : '';
                        if(i==0 && !String.isEmpty(bookedApptPromisedSlot)) {                            
                            if(!String.isEmpty(bookedApptPromisedSlot) && bookedApptPromisedSlot.equalsIgnoreCase(offerApptStDateTime+','+offerApptEndDateTime)) {
                                costCategory = costCategory  + ' scheduledSlot';                                  
                            }    
                        } 
                        slotCategory = appointment.getSlotCategory() != null ? appointment.getSlotCategory() : '';
                    }
                    WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_OfferAppointments offerAppt = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_OfferAppointments();
                    offerAppt.recordName = strWORecordID;
                    offerAppt.recordId = strWORecordID;
                    offerAppt.apptOfferDay = apptOfferDay;//Territory TZ
                    offerAppt.apptOfferTime = apptOfferTime;//Territory TZ
                    offerAppt.technician = technicians;
                    offerAppt.costRange = costCategory;
                    offerAppt.slotCategoryCost = slotCategoryCost;                
                    offerAppt.offerApptStDateTime = offerApptStDateTime;//string GMT TZ
                    offerAppt.offerApptEndDateTime = offerApptEndDateTime;//string GMT TZ        
                    offerAppt.slotCost = slotCost;
                    offerAppt.slotCategory = slotCategory;
                    
                    offerAppointmentsList.add(offerAppt);
                }
            }
            if(appointmentWithPoorSlotList != null && appointmentWithPoorSlotList .size() > 0) {
                for (integer i = 0; i<appointmentWithPoorSlotList .size(); i++) {
                    WSCH_Appointment appointment = appointmentWithPoorSlotList .get(i);
                    
                    //WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getOfferAppointments :: appointmentWithPoorSlotList:===>' + i);
                    //WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getOfferAppointments :: appointmentWithPoorSlotList:===>' + appointment );
              
                    String apptOfferDay = '';
                    String apptOfferTime = '';
                    String technicians = '';                    
                    String slotCost = '';
                    String offerApptStDateTime = '';
                    String offerApptEndDateTime = '';
                    String costCategory = '';
                    String slotCategoryCost = '';                    
                    String slotCategory = '';
                    if(appointment != null) {
                        if(appointment.getStartDateTime() != null && appointment.getEndDateTime() != null) {
                            DateTime apptSlotStartDate = WSCH_DateUtils.doTZConversion(appointment.getStartDateTime(), 'GMT' , territoryTimezone);
                            DateTime apptSlotEndDate =  WSCH_DateUtils.doTZConversion(appointment.getEndDateTime(), 'GMT' , territoryTimezone);                         
                            offerApptStDateTime = String.valueOfGMT(appointment.getStartDateTime());
                            offerApptEndDateTime = String.valueOfGMT(appointment.getEndDateTime());
                            //apptOfferDay = apptSlotStartDate.formatGmt('E, MMM dd');
                            //apptOfferDay = String.valueOfGMT(appointment.getStartDateTime());
                            apptOfferDay = String.valueOfGMT(apptSlotStartDate);
                            apptOfferTime = apptSlotStartDate.formatGmt('hh:mm a') + '-' + apptSlotEndDate.formatGmt('hh:mm a');
                        }
                        List<String> techniciansList = appointment.getTechnicians();
                        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: getOfferAppointments :: appointment : techniciansList ===>' + techniciansList);
                        if(techniciansList != null && techniciansList.size() > 0 ) {
                            technicians = String.join(techniciansList, ', ');
                        }
                        
                        costCategory =  appointment.getSlotCategory() != null ? appointment.getSlotCategory() : '';
                        if(i==0 && !String.isEmpty(bookedApptPromisedSlot)) {                            
                            if(!String.isEmpty(bookedApptPromisedSlot) && bookedApptPromisedSlot.equalsIgnoreCase(offerApptStDateTime+','+offerApptEndDateTime)) {
                                costCategory = costCategory + ' scheduledSlot';
                            }    
                        }
                        slotCategory = appointment.getSlotCategory() != null ? appointment.getSlotCategory() : '';
                    }
                    WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_OfferAppointments offerAppt = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_OfferAppointments();
                    offerAppt.recordName = strWORecordID;
                    offerAppt.recordId = strWORecordID;
                    offerAppt.apptOfferDay = apptOfferDay;//Territory TZ
                    offerAppt.apptOfferTime = apptOfferTime;//Territory TZ
                    offerAppt.technician = technicians;
                    offerAppt.costRange = costCategory;
                    offerAppt.slotCategoryCost = slotCategoryCost;                
                    offerAppt.offerApptStDateTime = offerApptStDateTime;//string GMT TZ
                    offerAppt.offerApptEndDateTime = offerApptEndDateTime;//string GMT TZ        
                    offerAppt.slotCost = slotCost;
                    offerAppt.slotCategory = slotCategory;
                    
                    if(offerAppt.slotCategory == 'POOR') {
                        isPoorSlotsAvailable = 'yes';
                    }
                    
                    offerApptWithPoorList.add(offerAppt);
                }
            }
            offerAppointmentsMap.put(request.headerID, offerAppointmentsList);
            offerApptMapWithPoorMap.put(request.headerID, offerApptWithPoorList);
            headerRecord.isPoorSlotsAvailable = isPoorSlotsAvailable;
            headerRecord.offerAppointmentMap = offerAppointmentsMap;
            headerRecord.offerApptMapWithPoorMap = offerApptMapWithPoorMap;
            headerRecord.recordID = request.headerID;
            response.headerRecord = headerRecord;
            WSCH_AuditLogger.finish();
            return response;
            
        } catch(Exception ex) {
            WSCH_AuditLogger.error('WSCH_Provider_ECO_Appointment::buildListView(): ' +ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            WSCH_AuditLogger.finish();
            system.debug('****Exception****'+ex.getMessage());
            system.debug('****Exception Trace****'+ex.getStackTraceString());
            return null;
        }
    }
    
    public WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Response bookAppointment(WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request request) {
        
        WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Response response = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Response();
        WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_HeaderRecord headerRecord = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_HeaderRecord();
       
        try{
            WSCH_Appointment appointmentSlot = new WSCH_Appointment();
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: bookAppointment :: request :===>' + request);
            WSCH_Provider_ECO_AppointmentWrapperDef.BookAppointmentRequest_WP bookAppointmentReq = request.bookAppointmentReq;
            if(bookAppointmentReq != null) {
                appointmentSlot.setStrStartDateTime(bookAppointmentReq.offerApptStDateTime);
                appointmentSlot.setstrEndDateTime(bookAppointmentReq.offerApptEndDateTime);                
                appointmentSlot.setSlotCategory(bookAppointmentReq.slotCategory);
                //appointmentSlot.setSlotCost(Double.valueOf(bookAppointmentReq.slotCost));
                //appointmentSlot.setSlotCategoryCost(Double.valueOf(bookAppointmentReq.slotCategoryCost));
                appointmentSlot.setGoAhead(Boolean.valueOf(bookAppointmentReq.goAhead));
                //appointmentSlot.setSlotType(bookAppointmentReq.costRange);
            }
            String workOrderId = request.headerId;
            SVMXC__Service_Order__c workOrder = WSCH_CommonUtils.fetchWorkOrderById(workOrderId);
            WSCH_AppointmentsResponse techSlotResponse = WSCH_OptimizedSchedulingService.bookAppointment(workOrder, appointmentSlot);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: bookAppointment :: techSlotResponse :===>' + techSlotResponse);
            Integer statusCode = techSlotResponse.statusCode;
            headerRecord.recordID = request.headerID;
            headerRecord.bookApptResponseCode = String.valueOf(statusCode);
            response.headerRecord = headerRecord;           
            WSCH_AuditLogger.finish();
            return response;
        } catch(Exception ex) {
            WSCH_AuditLogger.error('WSCH_Provider_ECO_Appointment_Impl::bookAppointment(): ' +ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            WSCH_AuditLogger.finish();
            return null;
        }
    }
    
    /*private WSCH_Provider_ECO_Stubs.Response_WP resumeJob(String dispatchProcessId, String territoryId){
        //Make a rest call to the rest webservice 
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: startOptimaxJob:: Teritory '+territoryId);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: startOptimaxJob:: Process '+dispatchProcessId);
        
        WSCH_Provider_ECO_Stubs.ResumeJobRequest_WP resumeRequest = new WSCH_Provider_ECO_Stubs.ResumeJobRequest_WP();
        resumeRequest.dispatchProcessGuid = dispatchProcessId;
        resumeRequest.territoryGuid = territoryId;
        resumeRequest.orgGuid =  Userinfo.getOrganizationId().substring(0,15);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: startOptimaxJob:: Request'+resumeRequest);
        
        String requestJson=JSON.serialize(resumeRequest); 
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: startOptimaxJob:: Request string'+requestJson);
         
        WSCH_Provider_ECO_Stubs.Response_WP responseWP =  WSCH_Provider_ECO_Callout_Helper.callOut(requestJson,WSCH_Provider_ECO_Callout_Helper.ECO_JOB_SERVICE_PATH,WSCH_Provider_ECO_Callout_Helper.ECO_RESUME_JOB_METHOD);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: startOptimaxJob:: responseWP.status '+responseWP.status);
        return responseWP;
    }*/

    @future(callout=true)
    private static void resumeJob(List<String> strDPIdTerrId) {
        try {
            String[] strDPisTerrIdSplit = strDPIdTerrId.get(0).split('-',-1);
            String dispatchProcessId = strDPisTerrIdSplit[0];
            String  territoryId = strDPisTerrIdSplit[1];

            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: resumeJob():: Teritory '+territoryId);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: resumeJob():: Process '+dispatchProcessId);
            
            WSCH_Provider_ECO_Stubs.ResumeJobRequest_WP resumeRequest = new WSCH_Provider_ECO_Stubs.ResumeJobRequest_WP();
            resumeRequest.dispatchProcessGuid = dispatchProcessId;
            resumeRequest.territoryGuid = territoryId;
            resumeRequest.orgGuid =  Userinfo.getOrganizationId().substring(0,15);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: resumeJob():: Request'+resumeRequest);
            
            String requestJson=JSON.serialize(resumeRequest); 
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: resumeJob():: Request string'+requestJson);
            
            WSCH_Provider_ECO_Stubs.Response_WP responseWP =  WSCH_Provider_ECO_Callout_Helper.callOut(requestJson,WSCH_Provider_ECO_Callout_Helper.ECO_JOB_SERVICE_PATH,WSCH_Provider_ECO_Callout_Helper.ECO_RESUME_JOB_METHOD);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: resumeJob():: responseWP.status '+responseWP.status);
            if(responseWP.status == '202') {
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: resumeJob():: job resume is successful. Updating the job status to resuming ');
                List<SVMXC__SVMX_Jobs__c> lstSVMXJobs = [Select id, Name, SVMXC__OptiMax_Message__c, SVMXC__SVMX_Process__c, 
                        SVMXC__Territory__c,SVMXC__Start_Time__c,SVMXC__Age__c, SVMXC__Status__c, 
                        SVMXC__End_Time__c,SVMXC__Type__c from SVMXC__SVMX_Jobs__c where 
                        SVMXC__Territory__c = :territoryId and SVMXC__Type__c = 'ECO' limit 1];
                lstSVMXJobs[0].SVMXC__OptiMax_Message__c = 'RESUMING';
                update lstSVMXJobs[0];
            }
            WSCH_AuditLogger.finish();
        } catch(Exception ex) {
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: resumeJob(): Exception occured- '+ ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            WSCH_AuditLogger.finish();
        }
    }
    
    @future(callout=true)
    private static void initJob(List<String> lstWOIds){
        try {
            List<SVMXC__Service_Order__c> lstWOs = WSCH_CommonUtils.fetchWorkOrders(lstWOIds);
            SVMXC__Territory__c terrObj;
            if(lstWOs != null && lstWOs.size() > 0) {
                String territoryId = lstWOs.get(0).SVMXC__Primary_Territory__c;
                terrObj = [Select  Id, Name, SVMXC__Active__c, SVMXC__Territory_s_Business_Hours__c, SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey,
                        SVMXC__Break_Hours__c, SVMXC__Average_Driving_Time__c, SVMXC__Per_Mile_Cost__c, SVMXC__Max_Distance__c, SVMXC__Average_Speed__c, SVMXC__Fixed_Cost__c, 
                        SVMXC__Per_hour_Cost__c, SVMXC__Mode_Of_Travel__c from SVMXC__Territory__c WHERE Id =:territoryId];
            }
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl::initJob():territory -'+terrObj.Name +'-'+terrObj.Id);
            boolean isBatched = WSCH_ECO_CommonUtils.getIsRTOBatched();
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl::initJob(): isBatched - ' + isBatched);

            //instantiate the list so that it is empty for initJobSyncIds
            List<SVMXC__Service_Order__c> emptyLstOfWOs = new List<SVMXC__Service_Order__c>();
            if(isBatched) {
                WSCH_Provider_ECO_SchedulingService.initJobSyncIds(terrObj,emptyLstOfWOs);   //passing null in place of WOs as we just need to initiate job without WOs
            } else {
                WSCH_Provider_ECO_Stubs.InitJobRequest_WP request_x = WSCH_Provider_ECO_DataMapper.initJobRequest(terrObj,lstWOs);
                if(request_x.resources == null || request_x.resources.size() == 0) {
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl::initJob(): initjob failed..There is no valid technician..');
                    WSCH_AuditLogger.finish();
                    return;
                }
                String requestJson=JSON.serialize(request_x); 
                request_x.workOrders = null ;
                String serviceName = WSCH_Provider_ECO_Callout_Helper.ECO_SCHEDULING_SERVICE_PATH;
                String methodName = WSCH_Provider_ECO_Callout_Helper.ECO_INTI_JOB_METHOD;
                WSCH_Provider_ECO_Stubs.Response_WP response_x = WSCH_Provider_ECO_Callout_Helper.callOut(requestJson,serviceName,methodName);
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl::initJob():response_x..'+response_x);
            }
            WSCH_AuditLogger.finish();
        } catch(Exception ex) {
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl :: initJob(): Exception occured- '+ ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            WSCH_AuditLogger.finish();
        }
    }

    /*private WSCH_Provider_ECO_Stubs.Response_WP initJob(SVMXC__Territory__c objTerritory, List<SVMXC__Service_Order__c> lstWOs){
        //Invoking InitJob api call     
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Appointment_Impl::initJob():territory -'+objTerritory.Name +'-'+objTerritory.Id);
        WSCH_Provider_ECO_Stubs.InitJobRequest_WP request_x = WSCH_Provider_ECO_DataMapper.initJobRequest(objTerritory,lstWOs);
        if(request_x.resources == null || request_x.resources.size() == 0) {
             WSCH_Provider_ECO_Stubs.Response_WP noTechnicianRespone = new WSCH_Provider_ECO_Stubs.Response_WP();
             noTechnicianRespone.status ='';
             noTechnicianRespone.message ='There is no valid technician.';
            return noTechnicianRespone;
        }
        String requestJson=JSON.serialize(request_x); 
        request_x.workOrders = null ;
        String serviceName = WSCH_Provider_ECO_Callout_Helper.ECO_SCHEDULING_SERVICE_PATH;
        String methodName = WSCH_Provider_ECO_Callout_Helper.ECO_INTI_JOB_METHOD;
        WSCH_Provider_ECO_Stubs.Response_WP response_x = WSCH_Provider_ECO_Callout_Helper.callOut(requestJson,serviceName,methodName);
        return response_x;
    }*/

}