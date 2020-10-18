/**
    DataMapper class is used to form the WorkOrder data into the request the object
    before invoking call
*/
public with sharing class WSCH_Provider_ECO_DataMapper {
    // public static List<BusinessHours> lstOfDefaultBussHr;
    public static map<String, String> mapSettingValues;
    
    public static Boolean isMile = false;
    public static Boolean isKilometer = false;
    public static Decimal dclDefaultPerKmCost = 0;
    public static Decimal dclDefaultMaxDistance = 0;
    public static Decimal dclDefaultAverageSpeed = 0;
    public static Decimal dclDefaultFixedCost = 0;
    public static Decimal dclDefaultPerHourCost = 0;
    public static Map<String, BusinessHours> mapBusinessHours = new Map<String, BusinessHours>();
    public static map<Id, WSCH_Provider_ECO_Stubs.ExecutionTime_WP> mapTechniciansOngoingActivity = new map<Id, WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
    public static map<id, Map<datetime, WSCH_Provider_ECO_Stubs.Location_WP>> mapTechLatitudeLongitude = new Map<id, Map<datetime, WSCH_Provider_ECO_Stubs.Location_WP>>();
    public static String strDefaultBHourId=null;
    public static DateTime dtmSchedulingHorizonStartDateTime;
    public static Boolean isFullRun;
    public static Boolean isDays = FALSE;
    public static BusinessHours objDefTerritoryBH;
    public static set<Date> setSchedHorizDates= new set<Date>();
    public static SVMXC__ServiceMax_Processes__c objSVMXProcess;
    public static Integer intNoOfDays=0;
    
    public static DCON_Utils dcUtils = new DCON_Utils();
    
    static {
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::Inside static block: Begin');
        initializeSetting();
        // initializeBussHr();
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::Inside static block: End');
    }

    public static void initializeSetting() {
        SVMXC.COMM_Utils_ManageSettings clsCommSettings = new SVMXC.COMM_Utils_ManageSettings();
        list<string> lstSettings = new list<string>{'OMAX001_SET001','OMAX001_SET002','OMAX001_SET003','OMAX001_SET004','OMAX001_SET005','OMAX001_SET006','OMAX001_SET007','OMAX001_SET008','OMAX001_SET009','OMAX001_SET011','OMAX001_SET012','OMAX001_SET013',
            'OMAX002_SET002','OMAX002_SET003','OMAX002_SET004','OMAX002_SET005','OMAX002_SET006','OMAX002_SET007','OMAX002_SET008','OMAX002_SET009','OMAX002_SET010','OMAX003_SET004','OMAX003_SET018','OMAX003_SET012','OMAX003_SET020','OMAX003_SET021',
            'OMAX003_SET022','OMAX003_SET023','OMAX003_SET024','OMAX003_SET025','OMAX003_SET026','OMAX003_SET027','OMAX003_SET028','OMAX003_SET029','OMAX003_SET037','OMAX003_SET038','OMAX003_SET039','OMAX003_SET040','OMAX003_SET041',
            'OMAX001_SET015','OMAX001_SET016','OMAX001_SET017','GLOB001_GBL005','GLOB001_GBL006','GLOB001_GBL007', 'OMAX001_SET014', 'DCON001_SET071'};
        mapSettingValues = clsCommSettings.SVMX_getGlobalSettingList(lstSettings);      
    }
    
    /*  Querying the default business hour  */
    public static void initializeBussHr(SVMXC__Territory__c objTerritory) {
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::initializeDefaultBussHr(): start');
        try{
            // Condition to load only default business hours or those in territory time zone
            String territoryTZsidKey = objTerritory.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey;
        // Get the list of all the active Business Hours and put them in a map.
        List<BusinessHours> lstBusinessHours = new List<BusinessHours>();
        lstBusinessHours = [Select Id, Name, IsDefault, IsActive, TimeZoneSidKey, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
                            ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime
                            from BusinessHours
                            where IsActive = TRUE AND (IsDefault = TRUE OR TimeZoneSidKey = :territoryTZsidKey)];
        //lstBusinessHours = getCompleteBusinessHour(lstBusinessHours);
        for(BusinessHours bh : lstBusinessHours)
        {
            mapBusinessHours.put(bh.Id, bh);
            if(bh.IsDefault == TRUE)
                strDefaultBHourId = bh.Id;
                 
        }
       
        //Heap size issue
        lstBusinessHours.clear();
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::initializeBussHr(): end');
        //WSCH_AuditLogger.rca('The Business Hours'+mapBusinessHours);
         //WSCH_AuditLogger.rca('The Default Business Hour '+mapBusinessHours.get(strDefaultBHourId));
       
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_ECO_DataMapper :: initializeBussHr :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }

                
    public static WSCH_Provider_ECO_Stubs.InitJobRequest_WP initJobRequest(SVMXC__Territory__c objTerritory, List<SVMXC__Service_Order__c> workOrders) {
        //WSCH_AuditLogger.rca('Construting Request to invoke Init Job');
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::initJobRequest():workOrders size..'+workOrders.size());
        initializeBussHr(objTerritory);
        WSCH_Provider_ECO_Stubs.InitJobRequest_WP request;
        Id dispatchProcessId;
        //setting work order details
        List<WSCH_Provider_ECO_Stubs.WorkOrder_WP> lstWorkOrderWP = new List<WSCH_Provider_ECO_Stubs.WorkOrder_WP>();
        
        dispatchProcessId = workOrders[0].SVMXC__Dispatch_Process__c;
         //For Appointment page, init job 
        if(dispatchProcessId == null) {
           RecordType recordType = [SELECT Id,Name,SobjectType FROM RecordType WHERE Name = 'SVMX Rule' limit 1] ;           
           SVMXC__ServiceMax_Processes__c processes = [ SELECT SVMXC__Process__c FROM SVMXC__ServiceMax_Processes__c WHERE RecordTypeId = :recordType.id 
                                                          AND SVMXC__Territory__c = :objTerritory.Id AND SVMXC__Rule_Type__c ='Territory Access' limit 1];
           dispatchProcessId = processes.SVMXC__Process__c ;
        }
        //WSCH_AuditLogger.rca('The number of Work Orders in the request'+workOrders.size());
        //WSCH_AuditLogger.rca('The Dispatch Process of the Work Orders'+dispatchProcessId);
        
        // Retrieve technician records from Service_Group_Members__c for the given territory ID
        List<SVMXC__Service_Group_Members__c> lstTechnicians = [Select Id, Name, SVMXC__Service_Territory__c, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey, SVMXC__Service_Territory__r.SVMXC__Per_Mile_Cost__c,
                SVMXC__Service_Territory__r.SVMXC__Per_Hour_Cost__c, SVMXC__Service_Territory__r.SVMXC__Fixed_Cost__c, SVMXC__Service_Territory__r.SVMXC__Max_Hours__c,
                SVMXC__Service_Territory__r.SVMXC__Average_Speed__c, SVMXC__Service_Territory__r.SVMXC__Max_Daily_Hours__c, SVMXC__Max_Hours__c,
                SVMXC__Service_Territory__r.SVMXC__Max_Distance__c, 
                SVMXC__Salesforce_User__c, SVMXC__Salesforce_User__r.IsActive, SVMXC__Fixed_Cost__c, SVMXC__Latitude_Home__c, SVMXC__Longitude_Home__c, SVMXC__Per_hour_Cost__c,
                SVMXC__Per_Mile_Cost__c, SVMXC__Average_Speed__c, SVMXC__Max_Daily_Hours__c, SVMXC__Max_Distance__c,
                SVMXC__Working_Hours__c , SVMXC__Working_Hours__r.TimeZoneSidKey,
                SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Zip__c, SVMXC__Country__c , SVMXC__Break_Hours__c, SVMXC__Enable_Scheduling__c
                from SVMXC__Service_Group_Members__c 
                where SVMXC__Active__c = TRUE AND SVMXC__Service_Territory__c = :objTerritory.Id AND ((SVMXC__Enable_Scheduling__c = TRUE AND SVMXC__Salesforce_User__c = NULL) OR (SVMXC__Salesforce_User__c != NULL AND SVMXC__Salesforce_User__r.IsActive = true) )];
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::initJobRequest():lstTechnicians size ..'+lstTechnicians.size());
        
        //setting technician and technician event details for initJob
        Map<String, SVMXC__SVMX_Optimizer__c> mapTechIdOptTrnObj;
        //request = getTechnicianAndEventDetails(objTerritory,dispatchProcessId,lstTechnicians,mapTechIdOptTrnObj);

        //Decouple Technician and Events
        request = getTechnicianAndEventDetails(objTerritory,dispatchProcessId,lstTechnicians,mapTechIdOptTrnObj);
        
        //setting work orders and its opening hours for initJob
        if(workOrders[0].SVMXC__Dispatch_Process__c != null) {
            lstWorkOrderWP = getWorkOrdersDetails(objTerritory, workOrders,dispatchProcessId); 
            request.workOrders = lstWorkOrderWP;
        }
        
        request.parameters = getParameters(objTerritory);

        //Capacity Limitation in RTO
        Map<Id, SVMXC__ServiceMax_Processes__c> mapCapacityRules = new Map<Id, SVMXC__ServiceMax_Processes__c>();   
        mapCapacityRules.putAll([SELECT Id, Name, SVMXC__Sequence__c, SVMXC__Name__c, SVMXC__Rule_Type__c, SVMXC__Process__c, SVMXC__SM_Capacity_Threshold__c, RecordType.Name from SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =:dispatchProcessId And RecordType.Name = 'SVMX Rule' and SVMXC__Rule_Type__c = 'Capacity Reservation' order by SVMXC__Sequence__c]);

        List<WSCH_Provider_ECO_Stubs.ExcSetting_WP> lstExcSetting_WP_CapacityReservtn = new List<WSCH_Provider_ECO_Stubs.ExcSetting_WP>();      

        if(mapCapacityRules != null && mapCapacityRules.size() > 0){
            for(SVMXC__ServiceMax_Processes__c capacityRule : mapCapacityRules.values()){
                lstExcSetting_WP_CapacityReservtn.add(setOrganizationParameters('CapacityReservation.Category.'+capacityRule.SVMXC__Name__c+'', String.valueof(capacityRule.SVMXC__SM_Capacity_Threshold__c)));
            }                      
        }

        if(lstExcSetting_WP_CapacityReservtn != null && lstExcSetting_WP_CapacityReservtn.size() > 0){
            request.parameters.addAll(lstExcSetting_WP_CapacityReservtn);
        }

        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::initJobRequest()::request.parameters::'+request.parameters);

        
        //setting basic job details
        request.dispatchProcessId=dispatchProcessId;
        request.territoryId=objTerritory.Id;
        request.orgId=Userinfo.getOrganizationId().substring(0,15);
        request.svmxVersion='16.29023'; 
        request.geoCodingEnabled='true';
                
        return request; 
    }
    
    public static WSCH_Provider_ECO_Stubs.ManageWorkOrderRequest_WP manageJobRequest(SVMXC__Territory__c objTerritory, List<SVMXC__Service_Order__c> workOrders) {
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::manageJobRequest():workOrders size..'+workOrders.size());
        initializeBussHr(objTerritory);
        WSCH_Provider_ECO_Stubs.ManageWorkOrderRequest_WP request = new WSCH_Provider_ECO_Stubs.ManageWorkOrderRequest_WP();
        Id dispatchProcessId;
        List<SVMXC__SVMX_Jobs__c> lstSVMXJob = [Select id, Name, SVMXC__OptiMax_Message__c, SVMXC__SVMX_Process__c, 
        SVMXC__Territory__c,SVMXC__Start_Time__c,SVMXC__Age__c, SVMXC__Status__c, 
        SVMXC__End_Time__c,SVMXC__Type__c from SVMXC__SVMX_Jobs__c where 
        SVMXC__Territory__c = :objTerritory.Id and SVMXC__Type__c = 'ECO' and 
        SVMXC__OptiMax_Message__c !='IDLE'];
         if(lstSVMXJob != null && lstSVMXJob.size() > 0) {
            dispatchProcessId = lstSVMXJob.get(0).SVMXC__SVMX_Process__c;
         }
         if(dispatchProcessId == null){
			dispatchProcessId = workOrders[0].SVMXC__Dispatch_Process__c;
		 }
        //setting work order details
        List<WSCH_Provider_ECO_Stubs.WorkOrder_WP> lstWorkOrderWP = new List<WSCH_Provider_ECO_Stubs.WorkOrder_WP>();
        //setting work order details
        lstWorkOrderWP = getWorkOrdersDetails(objTerritory, workOrders,dispatchProcessId); 
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::manageJobRequest():lstWorkOrderWP: '+lstWorkOrderWP);
        //setting basic job details
        //dispatchProcessId = workOrders[0].SVMXC__Dispatch_Process__c;        
        request.dispatchProcessId=dispatchProcessId;
        request.territoryId=objTerritory.Id;
        request.orgId=Userinfo.getOrganizationId().substring(0,15);
        request.svmxVersion='16.29023'; 
        request.geoCodingEnabled='true';
        request.workOrders = lstWorkOrderWP;
        
        return request; 
    }
    
  
    public static WSCH_Provider_ECO_Stubs.AppointmentOfferRequest_WP manageOfferAppointmentRequest(SVMXC__Territory__c objTerritory, SVMXC__Service_Order__c workOrder, WSCH_ApptParam apptParamObj) {
        
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::offerAppointmentRequest()::start');
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::offerAppointmentRequest()::objTerritory: ' + objTerritory);
        initializeBussHr(objTerritory);
        WSCH_Provider_ECO_Stubs.AppointmentOfferRequest_WP request = new WSCH_Provider_ECO_Stubs.AppointmentOfferRequest_WP();
        List<WSCH_Provider_ECO_Stubs.WorkOrder_WP> lstWorkOrderWP = new List<WSCH_Provider_ECO_Stubs.WorkOrder_WP>();
        List<SVMXC__Service_Order__c> lstOfWOs = new List<SVMXC__Service_Order__c>();
        lstOfWOs.add(workOrder);
        Set<String> setTerritoryId = new Set<String>();
        setTerritoryId.add(objTerritory.Id);
        
        List<SVMXC__SVMX_Jobs__c> lstSVMXJob = [Select id, Name, SVMXC__OptiMax_Message__c, SVMXC__SVMX_Process__c, 
                                    SVMXC__Territory__c,SVMXC__Start_Time__c,SVMXC__Age__c, SVMXC__Status__c, 
                                    SVMXC__End_Time__c,SVMXC__Type__c from SVMXC__SVMX_Jobs__c where 
                                    SVMXC__Territory__c = :objTerritory.Id and SVMXC__Type__c = 'ECO' and 
                                    SVMXC__OptiMax_Message__c !='IDLE'];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        BusinessHours territoryBusinessHrs = [SELECT Id,IsActive,IsDefault,Name,TimeZoneSidKey FROM BusinessHours WHERE Id =: objTerritory.SVMXC__Territory_s_Business_Hours__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        Id dispatchProcessId;
        if(lstSVMXJob != null && lstSVMXJob.size() > 0) {
            dispatchProcessId = lstSVMXJob.get(0).SVMXC__SVMX_Process__c;
        }
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::offerAppointmentRequest()::dispatchProcessId: ' + dispatchProcessId);
        //create executiontime wrapper
        List<SVMXC__Service_Order__c> lstOfWorkOrders = new List<SVMXC__Service_Order__c>();
        lstOfWorkOrders.add(workOrder);
        //invoke skill computation if not calculated during precalc
        if(String.isBlank(lstOfWorkOrders[0].SVMXC__Skill_Set__c))
        {
            SMAX_OptiMax_EngineUtils clsSkillComputation = new SMAX_OptiMax_EngineUtils();
            clsSkillComputation.buildSkills(lstOfWorkOrders);
        } 
        //invoke QTL computation if work order not qualified for RTO dp and QTL not calculated during precalc.
        if(String.isBlank(lstOfWorkOrders[0].SVMXC__Dispatch_Process__c) && String.isBlank(lstOfWorkOrders[0].SVMXC__Qualified_Technicians__c))
        {
            map<string, Map<String, String>> mapAllSettings = WSCH_Constants.allDMSettings;
            SMAX_OptiMax_EngineUtils.OMAX_MultiCriteriaTechMatch multiCritrTechMatch = new SMAX_OptiMax_EngineUtils.OMAX_MultiCriteriaTechMatch();
            map<Id, SVMXC__ServiceMax_Processes__c> mapWorkOrdersDP = new map<Id, SVMXC__ServiceMax_Processes__c>();
            map<Id, SVMXC__Service_Order__c> mapServiceOrder = new map<Id, SVMXC__Service_Order__c>();
            mapServiceOrder = multiCritrTechMatch.buildQualifiedTechnicians(lstOfWorkOrders, mapAllSettings, setTerritoryId, mapWorkOrdersDP);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::offerAppointmentRequest():: mapServiceOrder '+mapServiceOrder.size());
            if(mapServiceOrder != null && mapServiceOrder.size() > 0 && mapServiceOrder.get(lstOfWorkOrders[0].id) != null){
                lstOfWorkOrders[0] = mapServiceOrder.get(lstOfWorkOrders[0].id);
            }
        }
        
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::offerAppointmentRequest():: After QTL computation Heap Size : ' + Limits.getHeapSize() + '\n');
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::offerAppointmentRequest():: Number of Queries used in this apex code After QTL computation : ' + Limits.getQueries() + '\n');
        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::offerAppointmentRequest():: manageOfferApptReq workOrder - ' + workOrder);
        
        //setting work order details
        lstWorkOrderWP = setHorizonForApptWO(objTerritory, lstOfWorkOrders, apptParamObj, dispatchProcessId);
        
        //get the Arrival Windows for the Appointment Type mentioned on the WO
        List<SVMXC__SM_Appointment_Window__c> lstOfApptWindowDefinition = [Select SVMXC__SM_Appointment_Type__r.SVMXC__SM_Appointment_Type_Name__c, SVMXC__SM_Time_Window__r.SVMXC__SM_Time_Window_Name__c, 
                                        SVMXC__SM_Time_Window__r.SVMXC__SM_Window_Start_Time__c, SVMXC__SM_Time_Window__r.SVMXC__SM_Window_End_Time__c 
                                        From SVMXC__SM_Appointment_Window__c WHERE RecordType.Name = 'Appointment Type Definition' 
                                        AND SVMXC__SM_Appointment_Type__c = :lstOfWorkOrders[0].SVMXC__SM_Appointment_Type__c];
                                        
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::offerAppointmentRequest()::lstOfApptWindowDefinition: ' + lstOfApptWindowDefinition.size());
        List<WSCH_Provider_ECO_Stubs.ArrivalWindow_WP> arrivalWindows = new List<WSCH_Provider_ECO_Stubs.ArrivalWindow_WP>();
        WSCH_Provider_ECO_Stubs.ArrivalWindow_WP arrivalWindow;
        
        WSCH_Provider_ECO_Stubs.ApptOfferType_WP appOfferType = new WSCH_Provider_ECO_Stubs.ApptOfferType_WP();
        
        if(lstOfApptWindowDefinition != null && lstOfApptWindowDefinition.size() > 0) {
            /*Anush added time Formatting - START*/
            String StartTimeString,EndTimeString;
            //calculate territory current date.
            Datetime currentDTterritory = WSCH_DateUtils.doTZConversion(Datetime.now(), 'GMT',territoryBusinessHrs.TimeZoneSidKey);
            Date currentDateterritory = currentDTterritory.DateGMT();
            //WSCH_AuditLogger.debug('Current datetime in territory tz....'+currentDTterritory);
            //WSCH_AuditLogger.debug('Current date in territory tz...'+currentDateterritory);
            DateTime terrStartDateTime, terrEndDateTime, gmtStartDateTime, gmtEndDateTime;
            /*Anush added time Formatting - END*/
            for(SVMXC__SM_Appointment_Window__c eachApptWindowDef : lstOfApptWindowDefinition) {
                arrivalWindow = new WSCH_Provider_ECO_Stubs.ArrivalWindow_WP();
                arrivalWindow.arrivalWindowName = eachApptWindowDef.SVMXC__SM_Time_Window__r.SVMXC__SM_Time_Window_Name__c;
                /*Anush added time Formatting - START*/
                StartTimeString = eachApptWindowDef.SVMXC__SM_Time_Window__r.SVMXC__SM_Window_Start_Time__c;
                EndTimeString = eachApptWindowDef.SVMXC__SM_Time_Window__r.SVMXC__SM_Window_End_Time__c;
                
                if(!StartTimeString.contains(':')) {
                    StartTimeString = StartTimeString + ':00';
                }
                
                if(!EndTimeString.contains(':')) {
                    EndTimeString = EndTimeString + ':00';
                }
                
                WSCH_AuditLogger.debug('*******starttime ******** '+StartTimeString);
                WSCH_AuditLogger.debug('*******endtime ******** '+EndTimeString);
                terrStartDateTime = Datetime.newInstanceGMT(currentDateterritory.year(),currentDateterritory.month(),currentDateterritory.day(),Integer.valueOf(StartTimeString.split(':')[0]),Integer.valueOf(StartTimeString.split(':')[1]),00);
                terrEndDateTime = Datetime.newInstanceGMT(currentDateterritory.year(),currentDateterritory.month(),currentDateterritory.day(),Integer.valueOf(EndTimeString.split(':')[0]),Integer.valueOf(EndTimeString.split(':')[1]),00);
                
                //WSCH_AuditLogger.debug('terrStartDateTime - ' + terrStartDateTime);
                //WSCH_AuditLogger.debug('terrEndDateTime - ' + terrEndDateTime);
                //WSCH_AuditLogger.debug('territoryBusinessHrs.TimeZoneSidKey - ' + territoryBusinessHrs.TimeZoneSidKey);

                gmtStartDateTime = WSCH_DateUtils.doTZConversion(terrStartDateTime, territoryBusinessHrs.TimeZoneSidKey, 'GMT');
                gmtEndDateTime = WSCH_DateUtils.doTZConversion(terrEndDateTime, territoryBusinessHrs.TimeZoneSidKey, 'GMT');

                //WSCH_AuditLogger.debug('gmtStartDateTime - ' + gmtStartDateTime);
                //WSCH_AuditLogger.debug('gmtEndDateTime - ' + gmtEndDateTime);
                
                String strGmtSlotStart = gmtStartDateTime.formatGmt('HH:mm');
                String strGmtSlotEnd = gmtEndDateTime.formatGmt('HH:mm');
                
                //WSCH_AuditLogger.debug('strGmtSlotStart - ' + strGmtSlotStart);
                //WSCH_AuditLogger.debug('strGmtSlotEnd - ' + strGmtSlotEnd);
                
                arrivalWindow.startTime = strGmtSlotStart;
                arrivalWindow.endTime = strGmtSlotEnd;
                arrivalWindows.add(arrivalWindow);
            }
            appOfferType.appointmentOfferTypeName = lstOfApptWindowDefinition.get(0).SVMXC__SM_Appointment_Type__r.SVMXC__SM_Appointment_Type_Name__c;
            appOfferType.arrivalWindows = arrivalWindows;
            
            request.dispatchProcessId=dispatchProcessId;
            request.territoryId=objTerritory.Id;
            request.orgId=Userinfo.getOrganizationId().substring(0,15);
            //request.workOrder = lstWorkOrderWP[0];      //workOrderWP
            if(lstWorkOrderWP != null && lstWorkOrderWP.size() > 0 && lstWorkOrderWP[0] != null) {
                //request.workOrder = lstWorkOrderWP[0];      //workOrderWP
                //WSCH_Provider_ECO_Stubs.WorkOrder_WP workOrderWP = lstWorkOrderWP[0];
                //setHorizonDateWithArrivalWindow(lstOfApptWindowDefinition, workOrderWP, territoryBusinessHrs, workOrder);
                
                request.workOrder = lstWorkOrderWP[0];
                if(workOrder.SVMXC__Dispatch_Status__c != null && workOrder.SVMXC__Dispatch_Status__c.equalsIgnoreCase('assigned')) {
                    request.workOrder.operationType = 'update';
                } else {
                    request.workOrder.operationType = 'add';
                }
            }
            request.appointmentOfferType = appOfferType;
        }
        return request; 
    }
    

    public static void manageOfferAppointmentResponse(WSCH_Provider_ECO_Stubs.AppointmentOfferResponse_WP apptOfferResponse, WSCH_AppointmentsResponse techSlotResponse, WSCH_ApptParam apptParamObj) {
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_SchedulingService :: manageOfferAppointmentResponseNew() :: bookedApptSlot : ' + WSCH_Provider_ECO_Appointment_Impl.bookedApptSlot);
                
        List<WSCH_Appointment> appointmentList = new List<WSCH_Appointment>();
        WSCH_Appointment techSlot;
        if(apptOfferResponse != null ) {
            techSlotResponse.statusMessage = apptOfferResponse.errorMessage;
            techSlotResponse.statusCode = apptOfferResponse.statusCode;
            if(apptOfferResponse.appointmentOffers != null) { 
                
                // TODO: Make it performant!            
                // Creating UI objects in this loop
                for(WSCH_Provider_ECO_Stubs.Offer_WP slot : apptOfferResponse.appointmentOffers){
                    techSlot = new WSCH_Appointment();
                    techSlot.setStrEndDateTime(slot.endDateTime);
                    techSlot.setStrStartDateTime(slot.startDateTime);
                    techSlot.setSlotCategory(slot.slotCategory);
                    appointmentList.add(techSlot);
                }
                // Sort the list based - Date
                WSCH_Appointment.sortBy = apptParamObj.costOrDates;
                appointmentList.sort();
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_SchedulingService :: manageOfferAppointmentResponseNew() :: appointmentList from server : ' + appointmentList);
                
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_SchedulingService :: manageOfferAppointmentResponseNew() :: apptParamObj : ' + apptParamObj);
                               
                // Filter based on slotcategory
                
                integer slotsWithPoor = 0;
                integer slotsWithoutPoor = 0;
                integer slotsSize = apptParamObj.numberOfOfferAppts;
                String bookedAppt = WSCH_Provider_ECO_Appointment_Impl.bookedApptSlot;               
                List<WSCH_Appointment> apptListWithOutPoor = new List<WSCH_Appointment>();
                List<WSCH_Appointment> apptListWithPoor = new List<WSCH_Appointment>();
                if(!String.isEmpty(bookedAppt)) {
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_SchedulingService :: manageOfferAppointmentResponseNew() :: Filtered appointment offers: bookedAppt from WO : ' + bookedAppt);
                    for(integer i = 0; i < appointmentList.size(); i++) {
                        if(bookedAppt.equalsIgnoreCase(String.valueOfGMT(appointmentList.get(i).getStartDateTime())+','+String.valueOfGMT(appointmentList.get(i).getEndDateTime()))) {  
                            apptListWithOutPoor.add(appointmentList.get(i));
                            apptListWithPoor.add(appointmentList.get(i));
                            slotsWithoutPoor = slotsWithoutPoor+1;
                            slotsWithPoor = slotsWithPoor + 1;
                            WSCH_AuditLogger.debug('WSCH_Provider_ECO_SchedulingService :: manageOfferAppointmentResponseNew() :: Filtered appointment offers: bookedAppt : ' + appointmentList.get(i));
                            break;
                        }
                    }
                }
                                             
                List<WSCH_Appointment> filteredApptList = new List<WSCH_Appointment>();
                for(integer i = 0; i < appointmentList.size(); i++) {
                    if(slotsWithoutPoor >= slotsSize) {
                        break;  
                    }
                    if(appointmentList.get(i).getSlotCategory() == 'RECOMMENDED') {
                        if(!String.isEmpty(bookedAppt) && bookedAppt.equalsIgnoreCase(String.valueOfGMT(appointmentList.get(i).getStartDateTime())+','+String.valueOfGMT(appointmentList.get(i).getEndDateTime()))) {
    
                            } else {
                                apptListWithOutPoor.add(appointmentList.get(i));                            
                                slotsWithoutPoor = slotsWithoutPoor + 1; 
                            
                        }
                    }
                }            
                for(integer i = 0; i < appointmentList.size(); i++) {
                    if(slotsWithoutPoor >= slotsSize) {
                        break;  
                    }
                    if(appointmentList.get(i).getSlotCategory() == 'OK') {
                        if(!String.isEmpty(bookedAppt) && bookedAppt.equalsIgnoreCase(String.valueOfGMT(appointmentList.get(i).getStartDateTime())+','+String.valueOfGMT(appointmentList.get(i).getEndDateTime()))) {
    
                            } else {
                                apptListWithOutPoor.add(appointmentList.get(i));                            
                                slotsWithoutPoor = slotsWithoutPoor + 1;
                        }
                    }
                }
                                            
                for(integer i = 0; i < appointmentList.size(); i++) {
                    if(slotsWithPoor >= slotsSize) {
                        break;  
                    }
                    if(!String.isEmpty(bookedAppt) && bookedAppt.equalsIgnoreCase(String.valueOfGMT(appointmentList.get(i).getStartDateTime())+','+String.valueOfGMT(appointmentList.get(i).getEndDateTime()))) {

                    } else {                          
                        apptListWithPoor.add(appointmentList.get(i));
                        slotsWithPoor = slotsWithPoor + 1;
                    }
                }
                               
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_SchedulingService :: manageOfferAppointmentResponseNew() :: Filtered appointment offers: apptListWithOutPoor : ' + apptListWithOutPoor);
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_SchedulingService :: manageOfferAppointmentResponseNew() :: Filtered appointment offers: apptListWithPoor : ' + apptListWithPoor);
                       
                
                techSlotResponse.appointmentList = apptListWithOutPoor;
                //techSlotResponse.appointmentWithPoorSlotList = apptListWithPoor;
                WSCH_Provider_ECO_Appointment_Impl.appointmentWithPoorSlotList = apptListWithPoor;
            }
        }
    }
    
    public static WSCH_Provider_ECO_Stubs.BookAppointmentRequest_WP manageBookAppointmentRequest(SVMXC__Territory__c objTerritory, SVMXC__Service_Order__c workOrder, WSCH_Appointment slot) {
        
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::bookAppointmentRequest()::start');
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::bookAppointmentRequest()::objTerritory: ' + objTerritory);
        initializeBussHr(objTerritory);
        WSCH_Provider_ECO_Stubs.BookAppointmentRequest_WP request = new WSCH_Provider_ECO_Stubs.BookAppointmentRequest_WP();
        
        List<SVMXC__Service_Order__c> lstOfWorkOrders = new List<SVMXC__Service_Order__c>();
        lstOfWorkOrders.add(workOrder);
        
        
        Set<String> setTerritoryId = new Set<String>();
        setTerritoryId.add(objTerritory.Id);

        if(String.isBlank(lstOfWorkOrders[0].SVMXC__Skill_Set__c))
        {
            SMAX_OptiMax_EngineUtils clsSkillComputation = new SMAX_OptiMax_EngineUtils();
            clsSkillComputation.buildSkills(lstOfWorkOrders);
        } 

        if(String.isBlank(lstOfWorkOrders[0].SVMXC__Dispatch_Process__c) && String.isBlank(lstOfWorkOrders[0].SVMXC__Qualified_Technicians__c))
        {
            map<string, Map<String, String>> mapAllSettings = WSCH_Constants.allDMSettings;
            SMAX_OptiMax_EngineUtils.OMAX_MultiCriteriaTechMatch multiCritrTechMatch = new SMAX_OptiMax_EngineUtils.OMAX_MultiCriteriaTechMatch();
            map<Id, SVMXC__ServiceMax_Processes__c> mapWorkOrdersDP = new map<Id, SVMXC__ServiceMax_Processes__c>();
            map<Id, SVMXC__Service_Order__c> mapServiceOrder = new map<Id, SVMXC__Service_Order__c>();
            mapServiceOrder = multiCritrTechMatch.buildQualifiedTechnicians(lstOfWorkOrders, mapAllSettings, setTerritoryId, mapWorkOrdersDP);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::manageBookAppointmentRequest():: mapServiceOrder '+mapServiceOrder);
            if(mapServiceOrder != null && mapServiceOrder.size() > 0 && mapServiceOrder.get(lstOfWorkOrders[0].id) != null){
                lstOfWorkOrders[0] = mapServiceOrder.get(lstOfWorkOrders[0].id);
            }
        }
        
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::manageBookAppointmentRequest():: After QTL computation Heap Size : ' + Limits.getHeapSize() + '\n');
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::manageBookAppointmentRequest():: Number of Queries used in this apex code After QTL computation : ' + Limits.getQueries() + '\n');
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::manageBookAppointmentRequest():: manageBookApptReq workOrder - ' + workOrder);
        
                
        List<SVMXC__SVMX_Jobs__c> lstSVMXJob = [Select id, Name, SVMXC__OptiMax_Message__c, SVMXC__SVMX_Process__c, 
                                    SVMXC__Territory__c,SVMXC__Start_Time__c,SVMXC__Age__c, SVMXC__Status__c, 
                                    SVMXC__End_Time__c,SVMXC__Type__c from SVMXC__SVMX_Jobs__c where 
                                    SVMXC__Territory__c = :objTerritory.Id and SVMXC__Type__c = 'ECO' and 
                                    SVMXC__OptiMax_Message__c !='IDLE']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        Id dispatchProcessId;
        if(lstSVMXJob != null && lstSVMXJob.size() > 0) {
            dispatchProcessId = lstSVMXJob.get(0).SVMXC__SVMX_Process__c;
        }
        
        BusinessHours territoryBusinessHrs = [SELECT Id,IsActive,IsDefault,Name,TimeZoneSidKey FROM BusinessHours WHERE Id =: objTerritory.SVMXC__Territory_s_Business_Hours__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        slot.setTerritoryTimeZone(territoryBusinessHrs.TimeZoneSidKey);
        
        List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> woExeTime = new List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
        WSCH_Provider_ECO_Stubs.ExecutionTime_WP execTime = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP();
        //convert the string datetime received from the UI and set it here
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::bookAppointmentRequest()::slot.getStrStartDateTime() - ' + slot.getStrStartDateTime());
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::bookAppointmentRequest()::slot.getStrEndDateTime() - ' + slot.getStrEndDateTime());
              
        //Datetime startDt = WSCH_DateUtils.doTZConversion(DateTime.valueOfGmt(slot.getStrStartDateTime()), String.valueOf(UserInfo.getTimeZone()), territoryBusinessHrs.TimeZoneSidKey);
        //execTime.workingHoursBegin = WSCH_DateUtils.doTZConversion(startDt, territoryBusinessHrs.TimeZoneSidKey, 'GMT');
        execTime.workingHoursBegin = Datetime.valueOfGmt(slot.getStrStartDateTime());
        
        //Datetime endDt = WSCH_DateUtils.doTZConversion(DateTime.valueOfGmt(slot.getStrEndDateTime()), String.valueOf(UserInfo.getTimeZone()), territoryBusinessHrs.TimeZoneSidKey);
        //execTime.workingHoursEnd = WSCH_DateUtils.doTZConversion(endDt, territoryBusinessHrs.TimeZoneSidKey, 'GMT');
        execTime.workingHoursEnd = Datetime.valueOfGmt(slot.getStrEndDateTime());
        
        WSCH_AuditLogger.debug('execTime.workingHoursBegin - ' + execTime.workingHoursBegin);
        WSCH_AuditLogger.debug('execTime.workingHoursEnd - ' + execTime.workingHoursEnd);
        woExeTime.add(execTime);
        
        //if the work order manually scheduled through DC then it was force fixed in Optimax Server, 
        //Following values needs to update while making book appointment for the same work order
        //set the scheduing change token to CHANGE_CREATE_WO
        workOrder.SVMXC__Scheduling_Change_Token__c ='CHANGE_CREATE_WO';
        WSCH_Provider_ECO_Stubs.WorkOrder_WP workOrderWP = new WSCH_Provider_ECO_Stubs.WorkOrder_WP(lstOfWorkOrders[0], woExeTime, null, null);
        if(workOrder.SVMXC__Dispatch_Status__c != null && workOrder.SVMXC__Dispatch_Status__c.equalsIgnoreCase('assigned')) {
            workOrderWP.operationType = 'update';
        } else {
            workOrderWP.operationType = 'add';
        }
        if(workOrder.SVMXC__SM_Schedule_Violation_Penalty__c != null) {
            workOrderWP.scheduleViolationPenalty = workOrder.SVMXC__SM_Schedule_Violation_Penalty__c;
        }
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::manageBookAppointmentRequest():: manageBookApptReq workOrderWP- ' + workOrderWP);
         
        request.dispatchProcessId = dispatchProcessId;
        request.territoryId = objTerritory.Id;
        request.orgId = Userinfo.getOrganizationId().substring(0,15);
        //request.workOrder = workOrderWP;
        //request.slotCost = slot.getSlotCost();        
        request.slotCategory = slot.getSlotCategory();
        request.goAhead = slot.getGoAhead();
        //request.violationPenalty = slot.getViolationPenalty();
        request.workOrder = workOrderWP;
    
        return request;
    }
    
    public static void manageBookAppointmentResponse(WSCH_Provider_ECO_Stubs.BookAppointmentResponse_WP bookApptResponse, WSCH_AppointmentsResponse techSlotResponse) {
        WSCH_AuditLogger.debug('Inside WSCH_Provider_ECO_DataMapper::manageBookAppointmentResponse()');
        if(bookApptResponse !=null){
            techSlotResponse.statusCode = bookApptResponse.statusCode;
        }
    }
    
    public static WSCH_Provider_ECO_Stubs.ManageWorkOrderRequest_WP cancelJobRequest(List<String> lstWOs) {
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::cancelJobRequest():workOrders size..'+lstWOs.size());
        WSCH_Provider_ECO_Stubs.ManageWorkOrderRequest_WP request = new WSCH_Provider_ECO_Stubs.ManageWorkOrderRequest_WP();
        //setting work order details
        List<WSCH_Provider_ECO_Stubs.WorkOrder_WP> lstWorkOrderWP = new List<WSCH_Provider_ECO_Stubs.WorkOrder_WP>();
        String[] lstIds;
        for(String strWONameDPTerritory :lstWOs){
            lstIds = strWONameDPTerritory.split('_');
            if(lstIds != null && lstIds.size() > 0){
                WSCH_Provider_ECO_Stubs.WorkOrder_WP wo_wp = new WSCH_Provider_ECO_Stubs.WorkOrder_WP();
                wo_wp.workOrderId=lstIds[0];
                wo_wp.operationType='remove';
                lstWorkOrderWP.add(wo_wp);
            }
        }
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::cancelJobRequest():lstWorkOrderWP size..'+lstWorkOrderWP);
        
        //setting basic job details
        request.dispatchProcessId=lstIds[1];
        request.territoryId=lstIds[2];
        request.orgId=Userinfo.getOrganizationId().substring(0,15);
        request.svmxVersion='16.29023'; 
        request.geoCodingEnabled='true';
        request.workOrders = lstWorkOrderWP;
        
        return request; 
    }
    
    public static WSCH_Provider_ECO_Stubs.ManageTechnicianRequest_WP manageTechnicianRequest(SVMXC__Territory__c objTerritory, List<SVMXC__Service_Group_Members__c> lstTech, Map<String, SVMXC__SVMX_Optimizer__c> mapTechIdOptimizerObj, String strDispatchProcessId) {
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::manageTechnicianRequest():Technician size..'+lstTech.size());
        initializeBussHr(objTerritory);
        //WSCH_Provider_ECO_Stubs.InitJobRequest_WP initRequest;
        WSCH_Provider_ECO_Stubs.ManageTechnicianRequest_WP request = new WSCH_Provider_ECO_Stubs.ManageTechnicianRequest_WP();
        Id dispatchProcessId = strDispatchProcessId;
        
        //setting technician and technician event details for initJob
        //initRequest = getTechnicianAndEventDetails(objTerritory,dispatchProcessId,lstTech,mapTechIdOptimizerObj);        

        Date datStartDate;
        Date datEndDate;
        Datetime dtmNow = system.now();
        Datetime dtmLastProcessedDateTime;
        initializeBussHr(objTerritory);
        //Integer intNoOfDays=0;
        
        setDefaultParameter(objTerritory);
        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::manageTechnicianRequest():Default values from territory ..'+dclDefaultPerKmCost+','+dclDefaultMaxDistance+','+dclDefaultAverageSpeed+','+dclDefaultFixedCost+','+dclDefaultPerHourCost);
        
        //setting horizon dates
        setHorizonDates(objTerritory,dispatchProcessId);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::manageTechnicianRequest():Horizon Dates : '+setSchedHorizDates);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::manageTechnicianRequest():Territory BH : '+objDefTerritoryBH);               

        String strDPId = dispatchProcessId;
        
        //get tech availabilty window
        Map<id, Map<date, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>> mapTechAvailability = new Map<id, Map<date, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>>();
        mapTechAvailability = getTechnicianTimeWindows(intNoOfDays,mapBusinessHours, lstTech,setSchedHorizDates);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::manageTechnicianRequest():mapTechAvailability size ..'+mapTechAvailability.size());

        //Create Technician Wrapper
        List<WSCH_Provider_ECO_Stubs.Technician_WP> resources = doBuildResourceWrapper(lstTech,mapTechAvailability,objTerritory,objSVMXProcess,mapTechIdOptimizerObj);      
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::manageTechnicianRequest():resources size ..'+resources.size());
        
        //setting basic job details
        request.dispatchProcessId=dispatchProcessId;
        request.territoryId=objTerritory.Id;
        request.orgId=Userinfo.getOrganizationId().substring(0,15);
        request.svmxVersion='16.29023'; 
        request.geoCodingEnabled='true';
        
        request.resources = resources;
        return request; 
    }
    
    public static WSCH_Provider_ECO_Stubs.ManageWorkOrdersResultRequest_WP manageWorkOrdersResultRequest(String str_DPId_TerrId_OrgId) {
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::manageWorkOrdersResultRequest():str_DPId_TerrId_OrgId..'+str_DPId_TerrId_OrgId);
        WSCH_Provider_ECO_Stubs.ManageWorkOrdersResultRequest_WP request = new WSCH_Provider_ECO_Stubs.ManageWorkOrdersResultRequest_WP();
        
        String[] strIdsSplit = str_DPId_TerrId_OrgId.split('_');
        
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::manageWorkOrdersResultRequest():String of Ids..'+strIdsSplit);
        if(strIdsSplit != null && strIdsSplit.size() == 3) {
            //setting basic job details
            request.dispatchProcessGuid=strIdsSplit.get(0).trim();
            request.territoryGuid=strIdsSplit.get(1).trim();
            request.orgGuid=strIdsSplit.get(2).trim();
        }
        return request; 
    }

    public static WSCH_Provider_ECO_Stubs.ManageTechnicianRequest_WP cancelTechnicianRequest(List<String> lstTechId) {
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::cancelTechnicianRequest():Technician size..'+lstTechId.size());
        WSCH_Provider_ECO_Stubs.ManageTechnicianRequest_WP request = new WSCH_Provider_ECO_Stubs.ManageTechnicianRequest_WP();
        
        List<WSCH_Provider_ECO_Stubs.Technician_WP> lstTechnicianWP = new List<WSCH_Provider_ECO_Stubs.Technician_WP>();
        String[] lstIds;
        for(String strTechIdDPTerritory :lstTechId){
            lstIds = strTechIdDPTerritory.split('_');
            if(lstIds != null && lstIds.size() > 0){
                WSCH_Provider_ECO_Stubs.Technician_WP tech_wp = new WSCH_Provider_ECO_Stubs.Technician_WP();
                tech_wp.resourceId=lstIds[0]+'_'+lstIds[1]; //Technician Id_Technician Name
                tech_wp.operationType='remove';
                lstTechnicianWP.add(tech_wp);
            }
        }
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::cancelTechnicianRequest():lstWorkOrderWP size..'+lstTechnicianWP);        
        
        //setting basic job details
        request.dispatchProcessId=lstIds[2];
        request.territoryId=lstIds[3];
        request.orgId=Userinfo.getOrganizationId().substring(0,15);
        request.svmxVersion='16.29023'; 
        request.geoCodingEnabled='true';
        
        request.resources = lstTechnicianWP;
        return request; 
    }        
    public static List<WSCH_Provider_ECO_Stubs.WorkOrder_WP> getWorkOrdersDetails(SVMXC__Territory__c objTerritory, List<SVMXC__Service_Order__c> lstWorkOrderObj,Id dispatchProcessId){
        List<WSCH_Provider_ECO_Stubs.WorkOrder_WP> workOrders = new List<WSCH_Provider_ECO_Stubs.WorkOrder_WP>();
        list<BusinessHours> lstWOBusinessHours = new list<BusinessHours>();
        Map<String, Map<Date, WSCH_Provider_ECO_Stubs.ExecutionTime_WP>> mapBHTimeWindows = new Map<String, Map<Date, WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>();
        Map<String, List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>> mapWOTimeWindows = new Map<String, List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>();
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails():workOrders size..'+lstWorkOrderObj.size());
        set<BusinessHours> setWOBH = new set<BusinessHours>();

        system.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails():dispatchProcessId - ' + dispatchProcessId);
        setHorizonDates(objTerritory,dispatchProcessId);        
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails():Horizon Dates : '+setSchedHorizDates);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails():Territory BH : '+objDefTerritoryBH);
        //get the horizon end date from the above set of Horizon Dates
        Date horizonEndDate = getHorizonLastDate(setSchedHorizDates);
        DateTime horStartDateTimeTerr = WSCH_DateUtils.doTZConversion(system.now(), 'GMT' , objDefTerritoryBH.timeZoneSidKey);
        DateTime horEndDateTimeTerr = WSCH_DateUtils.doTZConversion(DateTime.newInstanceGMT(horizonEndDate,Time.newInstance(0,0,0,0)), 'GMT' , objDefTerritoryBH.timeZoneSidKey);
        //Date horStartDate = horStartDateTimeTerr.dateGMT();
        
        //adding territory business hr into set.
        setWOBH.add(objDefTerritoryBH); 
        DateTime tempEndDT = horEndDateTimeTerr;
        Boolean isPETlaterThanHorizonEnd = false;
        for(SVMXC__Service_Order__c objWorkOrder: lstWorkOrderObj)
        {
            if('CHANGE_CANCEL_WO'.equalsIgnoreCase(objWorkOrder.SVMXC__Scheduling_Change_Token__c)){
                continue;
            }            
            //create list of BH from qualified work orders preferred BH
            if(objWorkOrder.SVMXC__Preferred_Business_Hours__c != null && objWorkOrder.SVMXC__Preferred_Business_Hours__r.IsActive){
                setWOBH.add(mapBusinessHours.get(objWorkOrder.SVMXC__Preferred_Business_Hours__r.Id));
            }
            //below logic finds the later most PreferredEndDateTime after iterating all the WOs
            if(objWorkOrder.SVMXC__Preferred_End_Time__c != null) {
                DateTime prefEndDateTimeTerr = WSCH_DateUtils.doTZConversion(objWorkOrder.SVMXC__Preferred_End_Time__c, 'GMT' , objDefTerritoryBH.timeZoneSidKey);
                if(prefEndDateTimeTerr > tempEndDT) {
                    tempEndDT = prefEndDateTimeTerr;
                    isPETlaterThanHorizonEnd = true;
                }
            }
            
            //set Dispatch process for the work order if work order booked through appointment booking and don't have dispatch process or External work orders have differnt dispatch process.
            //if (objWorkOrder.SVMXC__Dispatch_Process__c == null)
                objWorkOrder.SVMXC__Dispatch_Process__c =  dispatchProcessId;
        }
        //got the later most PrefferedEndDateTime from the above iteration. So this will be the HorizonEndDateTime
        //for Horizon calculation
        horEndDateTimeTerr = tempEndDT;
        Set<Date> setOfHorDatesFromPstPet = new Set<Date>();
        //call the below method only if there is one PET greater than horizonEndDate
        if(isPETlaterThanHorizonEnd) {
            setOfHorDatesFromPstPet = setHorizonFromPrefEndDate(horStartDateTimeTerr, horEndDateTimeTerr, objTerritory);
        }
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails():setOfHorDatesFromPstPet : '+setOfHorDatesFromPstPet);

        if(setWOBH != null && setWOBH.size() > 0){
            lstWOBusinessHours.addAll(setWOBH);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): work orders BH size : '+lstWOBusinessHours.size());
            if(setOfHorDatesFromPstPet != null && !setOfHorDatesFromPstPet.isEmpty()) {
                mapBHTimeWindows = generateBusinessHourDetails(lstWOBusinessHours, NULL, NULL, setOfHorDatesFromPstPet);
            } else {
                mapBHTimeWindows = generateBusinessHourDetails(lstWOBusinessHours, NULL, NULL, setSchedHorizDates);
            }
            //mapBHTimeWindows = generateBusinessHourDetails(lstWOBusinessHours, NULL, NULL, setSchedHorizDates);
        }
      
            WSCH_AuditLogger.debug(': dispatchProcessId:  '+dispatchProcessId + ' , objTerritory.Id : '+objTerritory.Id);
            
            List<SVMXC__ServiceMax_Processes__c> lstOfDPProcessObj = [SELECT Id, SVMXC__Calendar_Start_Days__c, SVMXC__Calendar_End_Days__c, SVMXC__Dispatch_Method__c, SVMXC__Frequency__c, SVMXC__Full_Run_Unit__c from SVMXC__ServiceMax_Processes__c 
                where RecordType.Name = 'Dispatch Process' AND Id =:dispatchProcessId];
            
            /*SVMXC__Territory__c territoryObj = [Select SVMXC__Territory_s_Business_Hours__r.Id from SVMXC__Territory__c where Id =:objTerritory.Id]; 
            
            BusinessHours bh = [Select Id, Name, IsDefault, IsActive, TimeZoneSidKey, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, 
                WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, 
                SaturdayEndTime, SundayStartTime, SundayEndTime from BusinessHours where IsActive = TRUE AND Id =: territoryObj.SVMXC__Territory_s_Business_Hours__r.Id ];*/
        Map<String, String> mapWoIdEventId = new Map<String, String>();
        mapWoIdEventId = WSCH_Provider_ECO_DataMapper.getEventId(lstWorkOrderObj);
        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): mapWoIdEventId: ' + mapWoIdEventId + ' , lstWorkOrderObj : '+lstWorkOrderObj);

        for(SVMXC__Service_Order__c objWorkOrder: lstWorkOrderObj)
        {

            String workOrderType = 'NEW';
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): objWorkOrder.SVMXC__Scheduling_Change_Token__c : '+objWorkOrder.SVMXC__Scheduling_Change_Token__c); 
            String strOperationType=getOperationType(objWorkOrder);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): strOperationType : '+strOperationType);
            if(strOperationType != null && strOperationType.equalsIgnoreCase('remove')){
                workOrders.add(new WSCH_Provider_ECO_Stubs.WorkOrder_WP(objWorkOrder, null, null,strOperationType));
                continue;
            }else if(strOperationType != null && strOperationType.equalsIgnoreCase('update')){
                workOrderType='ASSIGNED';
                //handling CHANGE_ZIP_CODE token work orders
                //if the work order zip changed then we need to clear the work order latitude and longitude details to recalculate new lat,long for thiz zipcode
                if ('CHANGE_ZIP_CODE'.equalsIgnoreCase(objWorkOrder.SVMXC__Scheduling_Change_Token__c)) {
                    objWorkOrder.SVMXC__Latitude__c=null;
                    objWorkOrder.SVMXC__Longitude__c=null;
                }            
            }

            String scheduleFixType;
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): Building time windows for Work Order: ' + objWorkOrder.Name);
            List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstWOTimeWindows = new List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
            Map<Date, WSCH_Provider_ECO_Stubs.ExecutionTime_WP> mapWrkOrdrTimeWindows = new Map<Date, WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
            BusinessHours objWrkOrdBH;
            if(objWorkOrder.SVMXC__Preferred_Business_Hours__c != NULL && mapBusinessHours.containsKey(objWorkOrder.SVMXC__Preferred_Business_Hours__c))
            {
                if(mapBHTimeWindows != null && mapBHTimeWindows.size() >0 )
                    mapWrkOrdrTimeWindows = mapBHTimeWindows.get(objWorkOrder.SVMXC__Preferred_Business_Hours__c);
                    
                objWrkOrdBH = mapBusinessHours.get(objWorkOrder.SVMXC__Preferred_Business_Hours__c);
            }
            else
            {
                //set work order preferred BH to null, so that territory bh will be used to construct access hours
                objWorkOrder.SVMXC__Preferred_Business_Hours__c = NULL;
                //set access hours from territory bh
                if(mapBHTimeWindows != null && mapBHTimeWindows.size() >0 )
                    mapWrkOrdrTimeWindows = mapBHTimeWindows.get(objDefTerritoryBH.id);
            }
            
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonForApptWO(): mapWrkOrdrTimeWindows.size(): ' + mapWrkOrdrTimeWindows.size());
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonForApptWO(): mapWrkOrdrTimeWindows.keyset(): ' + mapWrkOrdrTimeWindows.keyset());

            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): Validate preferred start & end dates: PST:' + objWorkOrder.SVMXC__Preferred_Start_Time__c +'; PET:'+ objWorkOrder.SVMXC__Preferred_End_Time__c+'; dtmSchedulingHorizonStartDateTime: '+dtmSchedulingHorizonStartDateTime);
       
            //Timewindow for Forcefix job
             if(WSCH_Eco_Constants.FORCEFIXJOB_SCHDL_CHANGE_TOKENS.contains(objWorkOrder.SVMXC__Scheduling_Change_Token__c)){
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): Forcefix workorder time window added..' );
                Datetime endDT = objWorkOrder.SVMXC__Scheduled_Date_Time__c.addSeconds(Integer.valueOf(objWorkOrder.SVMXC__Service_Duration__c));
                WSCH_Provider_ECO_Stubs.ExecutionTime_WP wrpExecTime = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP(objWorkOrder.SVMXC__Scheduled_Date_Time__c, endDT);
                lstWOTimeWindows.add(wrpExecTime);
            }
            //Timewindow for ScheduleFix Job
            else if(WSCH_Eco_Constants.SCHEDULEFIX_SCHDL_CHANGE_TOKENS.contains(objWorkOrder.SVMXC__Scheduling_Change_Token__c)){
                WSCH_AuditLogger.debug('Inside Schedule Fix Job section');
                //TODO: Based on the picklist value set the access hours for the work order.
                //If Locking arrival window. Need to get arrival window where arrival time fall in.
                //invoke the method getArrivalWindow(objWorkOrder.SVMXC__Scheduled_Date_Time__c,)
                WSCH_Provider_ECO_Stubs.ExecutionTime_WP wrpExecTime;
                if(objWorkOrder.SVMXC__SM_Appointment_Type__c == null){
                    WSCH_AuditLogger.debug('As Appointment Type is NULL, so creating access hours based on scheduled datetime... ');
                    Datetime endDT = objWorkOrder.SVMXC__Scheduled_Date_Time__c.addSeconds(Integer.valueOf(objWorkOrder.SVMXC__Service_Duration__c));
                    wrpExecTime = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP(objWorkOrder.SVMXC__Scheduled_Date_Time__c, endDT);
                    scheduleFixType = 'LOCK_ARRIVAL_TIME';
                    //set SVMXC__Appointment_Promised_Time_Slot__c
                    //objWorkOrder.SVMXC__Appointment_Promised_Time_Slot__c = String.valueOfGMT(objWorkOrder.SVMXC__Scheduled_Date_Time__c);
                    WSCH_AuditLogger.debug('Appointment Type is NULL - scheduleFixType - ' + scheduleFixType);
                }else{
                    wrpExecTime = WSCH_CommonUtils.getWorkOrderArrivalWindow(objWorkOrder,objDefTerritoryBH);
                    scheduleFixType = 'LOCK_ARRIVAL_WINDOW';
                    WSCH_AuditLogger.debug('Appointment Type is NOT NULL - scheduleFixType - ' + scheduleFixType);
                }
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): ScheduleFix workorder time window added..'+wrpExecTime);
                if(wrpExecTime != null){
                    WSCH_AuditLogger.debug('wrpExecTime NOT NULL - scheduleFixType - ' + scheduleFixType);
                    lstWOTimeWindows.add(wrpExecTime);
                    Datetime startDT = wrpExecTime.workingHoursBegin;
                    Datetime endDT = wrpExecTime.workingHoursEnd;
                    //objWorkOrder.SVMXC__Appointment_Promised_Time_Slot__c = startDT.formatGmt('yyyy-MM-dd')+','+startDT.formatGmt('HH:mm')+','+endDT.formatGmt('HH:mm');
                    if(scheduleFixType.equalsIgnoreCase('LOCK_ARRIVAL_TIME')) {
                        objWorkOrder.SVMXC__Appointment_Promised_Time_Slot__c = String.valueOfGMT(objWorkOrder.SVMXC__Scheduled_Date_Time__c);
                    } else if(scheduleFixType.equalsIgnoreCase('LOCK_ARRIVAL_WINDOW')) {
                        objWorkOrder.SVMXC__Appointment_Promised_Time_Slot__c = String.valueOfGmt(startDT) +','+String.valueOfGmt(endDT);
                    }
                }else{
                    WSCH_AuditLogger.debug('As arrival window does not match with current scheduled datetime of the work order, so creating access hours based on scheduled dattime.');
                    Datetime endDT = objWorkOrder.SVMXC__Scheduled_Date_Time__c.addSeconds(Integer.valueOf(objWorkOrder.SVMXC__Service_Duration__c));
                    wrpExecTime = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP(objWorkOrder.SVMXC__Scheduled_Date_Time__c, endDT);
                    lstWOTimeWindows.add(wrpExecTime);
                    scheduleFixType = 'LOCK_ARRIVAL_TIME';
                    objWorkOrder.SVMXC__Appointment_Promised_Time_Slot__c = String.valueOfGMT(objWorkOrder.SVMXC__Scheduled_Date_Time__c);
                    WSCH_AuditLogger.debug('wrpExecTime is NULL - scheduleFixType - ' + scheduleFixType);
                }
            }
            // if workorder booked through appointment booking, consider appointment slot as SLA of the work order.
            //if it is appointment WO and if has been updated/changed with scheduling data like PST, PET, Service Duration etc consider it for update job call
            else if(objWorkOrder.SVMXC__Appointment_Promised_Time_Slot__c != null && !WSCH_Eco_Constants.UPDATEJOB_SCHDL_CHANGE_TOKENS.contains(objWorkOrder.SVMXC__Scheduling_Change_Token__c)){
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails():objWorkOrder.SVMXC__Appointment_Promised_Time_Slot__c - ' + objWorkOrder.SVMXC__Appointment_Promised_Time_Slot__c);
                String[] apptPromiseSlotArray = objWorkOrder.SVMXC__Appointment_Promised_Time_Slot__c.split(',',3);
                if(apptPromiseSlotArray != null && (apptPromiseSlotArray.size() == 3 || apptPromiseSlotArray.size() == 2)) {
                    Datetime apptStartDateTime = DateTime.valueOfGmt(apptPromiseSlotArray[0].trim());
                    Datetime apptEndDateTime = DateTime.valueOfGmt(apptPromiseSlotArray[1].trim()); 
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): Work order with Appointment slots..startDT-'+apptStartDateTime+' ;EndDT - '+apptEndDateTime);
                    WSCH_Provider_ECO_Stubs.ExecutionTime_WP wrpExecTime = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP(apptStartDateTime, apptEndDateTime);
                    lstWOTimeWindows.add(wrpExecTime);
                    scheduleFixType = 'LOCK_ARRIVAL_WINDOW'; //fix for the defect OPT-4463                                 
                } else if(apptPromiseSlotArray != null && apptPromiseSlotArray.size() == 1) {
                    Datetime apptStartDateTime = DateTime.valueOfGmt(apptPromiseSlotArray[0].trim());
                    //Datetime apptEndDateTime = DateTime.valueOfGmt(apptPromiseSlotArray[1].trim());
                    Datetime apptEndDateTime = apptStartDateTime.addSeconds(Integer.valueOf(objWorkOrder.SVMXC__Service_Duration__c)); 
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): Work order with Appointment slots..startDT-'+apptStartDateTime+' ;EndDT - '+apptEndDateTime);
                    WSCH_Provider_ECO_Stubs.ExecutionTime_WP wrpExecTime = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP(apptStartDateTime, apptEndDateTime);
                    lstWOTimeWindows.add(wrpExecTime);
                }
            } 
            //Introduced this below logic to match with the SLA logic from Appointment booking
            //Validate preferred start and end dates against the Horizon and construct the Execution Time Windows
            else if(objWorkOrder.SVMXC__Preferred_Start_Time__c == NULL || objWorkOrder.SVMXC__Preferred_End_Time__c == NULL ||
                        objWorkOrder.SVMXC__Preferred_Start_Time__c != NULL || objWorkOrder.SVMXC__Preferred_End_Time__c != NULL) {
                
                Datetime territoryPrefStartDT;
                Datetime territoryPrefEndDT;
                //Datetime territoryHorizonStartDT;
                //Datetime territoryHorizonEndDT;
                Datetime tempStartDateTime;
                Datetime tempEndDateTime;
                Boolean considerPST = false;
                Boolean considerPET = false;
                
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): objTerritory.SVMXC__Territory_s_Business_Hours__c - ' + objTerritory.SVMXC__Territory_s_Business_Hours__c);
                DateTime dtmSchedulingHorizonEndDateTime;
                if((lstOfDPProcessObj != null && lstOfDPProcessObj.size() > 0) && mapBusinessHours.containsKey(objTerritory.SVMXC__Territory_s_Business_Hours__c)){
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): lstOfDPProcessObj[0].Id - ' + lstOfDPProcessObj[0].Id);
                    List<DateTime> lstHorizonStartAndEndDateTime = WSCH_CommonUtils.getDPHorizonStartAndEndDates(lstOfDPProcessObj[0], 
                                                                    mapBusinessHours.get(objTerritory.SVMXC__Territory_s_Business_Hours__c));
                    if(lstHorizonStartAndEndDateTime != null && lstHorizonStartAndEndDateTime.size() == 2) {
                        dtmSchedulingHorizonStartDateTime = lstHorizonStartAndEndDateTime[0];
                        dtmSchedulingHorizonEndDateTime = lstHorizonStartAndEndDateTime[1];
                    }
                }
                
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): dtmSchedulingHorizonStartDateTime - ' + dtmSchedulingHorizonStartDateTime);
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): dtmSchedulingHorizonEndDateTime - ' + dtmSchedulingHorizonEndDateTime);
                
                if(objWorkOrder.SVMXC__Preferred_Start_Time__c != NULL) {
                    //convert the PST territory time zone and compare it with the horizon start and end dates appropriately to find
                    //if they are well within the horizon and determine the start and end dates to be sent to the server.
                                
                    territoryPrefStartDT = WSCH_DateUtils.doTZConversion(objWorkOrder.SVMXC__Preferred_Start_Time__c, 'GMT' , objDefTerritoryBH.timeZoneSidKey);
                    
                    if(territoryPrefStartDT >= dtmSchedulingHorizonStartDateTime && territoryPrefStartDT <= dtmSchedulingHorizonEndDateTime) {
                        considerPST = true;
                    }
                }
                
                if(objWorkOrder.SVMXC__Preferred_End_Time__c != NULL) {
                    //Allow PET only if PST is already allowed, other wise PET will be considered even if PST is outside horizon.
                    if(considerPST) {
                        considerPET = true;
                    }
                    //checking if PET is present within horizon or not. This change is made to allow the accesshour calculation to include the 
                    //PET. This gives more room for the optimizer to optimize this WO.
                    //convert the PET to the territory time zone and compare it with the horizon start and end dates appropriately to find
                    //if they are well within the horizon and determine the start and end dates to be sent to the server.
                    if(considerPST == false) {
                        territoryPrefEndDT = WSCH_DateUtils.doTZConversion(objWorkOrder.SVMXC__Preferred_End_Time__c, 'GMT' , objDefTerritoryBH.timeZoneSidKey);                    
                        if(territoryPrefEndDT >= dtmSchedulingHorizonStartDateTime && territoryPrefEndDT <= dtmSchedulingHorizonEndDateTime) {
                            considerPET = true;
                        }                    
                    }
                }
                
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): territoryPrefStartDT - ' + territoryPrefStartDT);
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): territoryPrefEndDT - ' + territoryPrefEndDT);
                
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): dtmSchedulingHorizonStartDateTime - ' + dtmSchedulingHorizonStartDateTime);
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): dtmSchedulingHorizonEndDateTime - ' + dtmSchedulingHorizonEndDateTime);
                
                //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): territoryHorizonStartDT - ' + territoryHorizonStartDT);
                //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): territoryHorizonEndDT - ' + territoryHorizonEndDT);
                
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): considerPST - ' + considerPST + 'considerPET ' + considerPET);
                
                if(objWorkOrder.SVMXC__Preferred_Start_Time__c != NULL && objWorkOrder.SVMXC__Preferred_End_Time__c != NULL &&
                        objWorkOrder.SVMXC__Preferred_Start_Time__c < objWorkOrder.SVMXC__Preferred_End_Time__c) {
                            
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): PST != NULL && PET != NULL');
                            
                    if(considerPST && considerPET) {
                        tempStartDateTime = objWorkOrder.SVMXC__Preferred_Start_Time__c;
                        tempEndDateTime = objWorkOrder.SVMXC__Preferred_End_Time__c;
                        //Construct the execution time windows for the above start and end dates
                        WSCH_Provider_ECO_DataMapper.constructExecTimeWIndows(tempStartDateTime, tempEndDateTime, lstWOTimeWindows, mapWrkOrdrTimeWindows, objWorkOrder);
                        
                    } else if(considerPST == false && considerPET == false) {
                        WSCH_AuditLogger.debug('As both PST and PET are out of the Horizon, skipping this WO - ' + objWorkOrder.Id);
                        /*tempStartDateTime = dtmSchedulingHorizonStartDateTime;
                        tempEndDateTime = dtmSchedulingHorizonEndDateTime;
                        //Construct the execution time windows for the above start and end dates
                        WSCH_Provider_ECO_DataMapper.constructExecTimeWIndows(tempStartDateTime, tempEndDateTime, lstWOTimeWindows, mapWrkOrdrTimeWindows, objWorkOrder);*/
                        String errorText = 'As both PST and PET are out of the Horizon, skipping this WO from scheduling';
                        objWorkOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_SKIPPED;
                        WSCH_CommonUtils.setOptimizerErrorText(objWorkOrder, errorText);
                        continue;
                        
                    } else if(considerPST && considerPET == false) {
                        tempStartDateTime = objWorkOrder.SVMXC__Preferred_Start_Time__c;
                        tempEndDateTime = WSCH_DateUtils.doTZConversion(dtmSchedulingHorizonEndDateTime, objDefTerritoryBH.timeZoneSidKey, 'GMT');
                        //Construct the execution time windows for the above start and end dates
                        WSCH_Provider_ECO_DataMapper.constructExecTimeWIndows(tempStartDateTime, tempEndDateTime, lstWOTimeWindows, mapWrkOrdrTimeWindows, objWorkOrder);
                        
                    } else if(considerPST == false && considerPET) {
                        tempStartDateTime = WSCH_DateUtils.doTZConversion(dtmSchedulingHorizonStartDateTime, objDefTerritoryBH.timeZoneSidKey, 'GMT');
                        tempEndDateTime = objWorkOrder.SVMXC__Preferred_End_Time__c;
                        //Construct the execution time windows for the above start and end dates
                        WSCH_Provider_ECO_DataMapper.constructExecTimeWIndows(tempStartDateTime, tempEndDateTime, lstWOTimeWindows, mapWrkOrdrTimeWindows, objWorkOrder);
                    }
                            
                } else if(objWorkOrder.SVMXC__Preferred_Start_Time__c != NULL && objWorkOrder.SVMXC__Preferred_End_Time__c == NULL) {
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): PST != NULL && PET == NULL');
                    //if PST is not null check if PST has to be considered, else consider horizon start datetime
                    if(considerPST) {
                        tempStartDateTime = objWorkOrder.SVMXC__Preferred_Start_Time__c;
                        tempEndDateTime = WSCH_DateUtils.doTZConversion(dtmSchedulingHorizonEndDateTime, objDefTerritoryBH.timeZoneSidKey, 'GMT');
                    } else {
                        WSCH_AuditLogger.debug('PST is out of the Horizon and PET is null, skipping this WO - ' + objWorkOrder.Id);
                        //tempStartDateTime = dtmSchedulingHorizonStartDateTime;
                        String errorText = 'As PST is out of the Horizon and PET is null, skipping this WO from scheduling';
                        objWorkOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_SKIPPED;
                        WSCH_CommonUtils.setOptimizerErrorText(objWorkOrder, errorText);
                        continue;
                    }
                    //setting Horizon end datetime as the SLA enddatetime sicne PreferredEndTime is null
                    //tempEndDateTime = dtmSchedulingHorizonEndDateTime;
                    //Construct the execution time windows for the above start and end dates
                    WSCH_Provider_ECO_DataMapper.constructExecTimeWIndows(tempStartDateTime, tempEndDateTime, lstWOTimeWindows, mapWrkOrdrTimeWindows, objWorkOrder);
                    
                } else if(objWorkOrder.SVMXC__Preferred_Start_Time__c == NULL && objWorkOrder.SVMXC__Preferred_End_Time__c != NULL) {
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): PST == NULL && PET != NULL');
                    //setting Horizon start datetime as the SLA startdatetime since PreferredEndTime is null
                    //tempStartDateTime = dtmSchedulingHorizonStartDateTime;
                    if(considerPET) {
                        tempStartDateTime = WSCH_DateUtils.doTZConversion(dtmSchedulingHorizonStartDateTime, objDefTerritoryBH.timeZoneSidKey, 'GMT');
                        tempEndDateTime = objWorkOrder.SVMXC__Preferred_End_Time__c;
                    } else {
                        WSCH_AuditLogger.debug('PST is NULL and PET is out of Horizon, skipping this WO - ' + objWorkOrder.Id);
                        String errorText = 'As PST is NULL and PET is out of Horizon, skipping this WO from scheduling';
                        objWorkOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_SKIPPED;
                        WSCH_CommonUtils.setOptimizerErrorText(objWorkOrder, errorText);
                        //tempEndDateTime = dtmSchedulingHorizonEndDateTime;
                        continue;
                    }
                    //Construct the execution time windows for the above start and end dates
                    WSCH_Provider_ECO_DataMapper.constructExecTimeWIndows(tempStartDateTime, tempEndDateTime, lstWOTimeWindows, mapWrkOrdrTimeWindows, objWorkOrder);
                    
                } else if(objWorkOrder.SVMXC__Preferred_Start_Time__c == NULL && objWorkOrder.SVMXC__Preferred_End_Time__c == NULL) {
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): PST == NULL && PET == NULL');
                    //since both PST and PET are null set Horizon start and end datetime as SLA
                    tempStartDateTime = WSCH_DateUtils.doTZConversion(dtmSchedulingHorizonStartDateTime, objDefTerritoryBH.timeZoneSidKey, 'GMT');
                    tempEndDateTime = WSCH_DateUtils.doTZConversion(dtmSchedulingHorizonEndDateTime, objDefTerritoryBH.timeZoneSidKey, 'GMT');
                    //Construct the execution time windows for the above start and end dates
                    WSCH_Provider_ECO_DataMapper.constructExecTimeWIndows(tempStartDateTime, tempEndDateTime, lstWOTimeWindows, mapWrkOrdrTimeWindows, objWorkOrder);
                } else if(objWorkOrder.SVMXC__Preferred_Start_Time__c != NULL && objWorkOrder.SVMXC__Preferred_End_Time__c != NULL &&
                        (objWorkOrder.SVMXC__Preferred_Start_Time__c > objWorkOrder.SVMXC__Preferred_End_Time__c || 
                            objWorkOrder.SVMXC__Preferred_Start_Time__c == objWorkOrder.SVMXC__Preferred_End_Time__c)) {
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): PST > PET or PST == PET. Skipping this WO.');
                    String errorText = 'PST is greater than PET or PST equals PET. Correct the data to proceed further';
                    objWorkOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_ERROR;
                    WSCH_CommonUtils.setOptimizerErrorText(objWorkOrder, errorText);
                    continue;   
                }
            }
            
            if(lstWOTimeWindows != NULL && lstWOTimeWindows.size() > 0)
            {
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): lstWOTimeWindows.size() - ' + lstWOTimeWindows.size());
                List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> woCOExeTime = new List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
                for(WSCH_Provider_ECO_Stubs.ExecutionTime_WP exeTime : lstWOTimeWindows)
                {
                    woCOExeTime.add(new WSCH_Provider_ECO_Stubs.ExecutionTime_WP(exeTime.workingHoursBegin, exeTime.workingHoursEnd));
                }
                mapWOTimeWindows.put(objWorkOrder.id, woCOExeTime);
            }

        /*    String workOrderType = 'NEW';
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): objWorkOrder.SVMXC__Scheduling_Change_Token__c : '+objWorkOrder.SVMXC__Scheduling_Change_Token__c); 
            String strOperationType=getOperationType(objWorkOrder);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getWorkOrdersDetails(): strOperationType : '+strOperationType);
            if(strOperationType != null && strOperationType.equalsIgnoreCase('remove')){
                workOrders.add(new WSCH_Provider_ECO_Stubs.WorkOrder_WP(objWorkOrder, null, null,strOperationType));
                continue;
            }else if(strOperationType != null && strOperationType.equalsIgnoreCase('update')){
                workOrderType='ASSIGNED';
                //handling CHANGE_ZIP_CODE token work orders
                //if the work order zip changed then we need to clear the work order latitude and longitude details to recalculate new lat,long for thiz zipcode
                if ('CHANGE_ZIP_CODE'.equalsIgnoreCase(objWorkOrder.SVMXC__Scheduling_Change_Token__c)) {
                    objWorkOrder.SVMXC__Latitude__c=null;
                    objWorkOrder.SVMXC__Longitude__c=null;
                }            
            }*/
            Map<String, String> parameters = new Map<String, String>();
            if(strOperationType != null && strOperationType.equalsIgnoreCase('ecoReplaceWithWorkorder') && mapWoIdEventId != null){
                String strRelatedElementId = 'Event_'+mapWoIdEventId.get(objWorkOrder.Id)+'_'+objWorkOrder.SVMXC__Group_Member__r.Name; //Event_EventId_TechName
                parameters.put('relatedElementId',strRelatedElementId);
            }    
            // Building the execution time window for New and Assigned Work Orders
            if(mapWOTimeWindows.containsKey(objWorkOrder.Id) && mapWOTimeWindows.get(objWorkOrder.Id).size() > 0 )
            {
                workOrders.add(new WSCH_Provider_ECO_Stubs.WorkOrder_WP(objWorkOrder, mapWOTimeWindows.get(objWorkOrder.Id), workOrderType,strOperationType,scheduleFixType,parameters));
            }
            
        } 

        mapWOTimeWindows.clear();
        mapBHTimeWindows.clear();
        //mapWrkOrdrTimeWindows.clear();
        //lstWOTimeWindows.clear();
        return workOrders;      
    }
    
    //Below method construct the execution time windows based on the horizon dates passed to it
    public static void constructExecTimeWIndows(DateTime tempStartDateTime, DateTime tempEndDateTime, List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstWOTimeWindows,
                    Map<Date, WSCH_Provider_ECO_Stubs.ExecutionTime_WP> mapWrkOrdrTimeWindows, SVMXC__Service_Order__c objWorkOrder) {
        
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows(): tempStartDateTime: ' + tempStartDateTime + ' tempEndDateTime: '+ tempEndDateTime);
        //system.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows(): tempStartDateTime: ' + tempStartDateTime + ' tempEndDateTime: '+ tempEndDateTime);
        
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows():mapWrkOrdrTimeWindows - ' + mapWrkOrdrTimeWindows);
        
        Date tempStartDate = Date.valueOf(tempStartDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
        Date tempEndDate = Date.valueOf(tempEndDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
        
        Integer intSLADays = tempStartDate.daysBetween(tempEndDate);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows(): Work order with SLA; BH: ' + objDefTerritoryBH.id + '; Start date: ' + tempStartDate + '; End date: ' + tempEndDate + '; SLA Days: ' + intSLADays + '; WO Preferred Start: ' + tempStartDateTime + '; WO Preferred End: ' + tempEndDateTime);
        //system.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows(): Work order with SLA; BH: ' + objDefTerritoryBH.id + '; Start date: ' + tempStartDate + '; End date: ' + tempEndDate + '; SLA Days: ' + intSLADays + '; WO Preferred Start: ' + tempStartDateTime + '; WO Preferred End: ' + tempEndDateTime);
        
        // Get the execution time windows in the SLA time window range
        for(Integer i = 0; i <= intSLADays; i++)
        {
            if(mapWrkOrdrTimeWindows.containsKey(tempStartDate.addDays(i)) && mapWrkOrdrTimeWindows.get(tempStartDate.addDays(i)) != NULL)
            {
                WSCH_Provider_ECO_Stubs.ExecutionTime_WP wrpExecTime = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP();
                wrpExecTime.workingHoursBegin = mapWrkOrdrTimeWindows.get(tempStartDate.addDays(i)).workingHoursBegin;
                wrpExecTime.workingHoursEnd = mapWrkOrdrTimeWindows.get(tempStartDate.addDays(i)).workingHoursEnd;
                                
                //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows():wrpExecTime.workingHoursBegin - ' + wrpExecTime.workingHoursBegin);
                //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows():wrpExecTime.workingHoursEnd - ' + wrpExecTime.workingHoursEnd);
                //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows():current date - ' + tempStartDate.addDays(i));
            
                if(i==0) {
                    if(tempStartDateTime > wrpExecTime.workingHoursEnd) {
                        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows(): skipping the working hours creation for the date '+ tempStartDateTime  +' as PST > BH End');
                        String errorText = 'skipping the working hours creation for the date '+ tempStartDateTime  +' as PST > BusinessHour EndTime.';
                        objWorkOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_ERROR;
                        WSCH_CommonUtils.setOptimizerErrorText(objWorkOrder, errorText);
                        continue;
                    } else if(tempEndDateTime < wrpExecTime.workingHoursBegin) {
                        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows(): skipping the working hours creation for the date '+ tempEndDateTime +' as PET < BH Start');
                        String errorText = 'skipping the working hours creation for the date '+ tempEndDateTime +' as PET < BusinessHour StartTime.';
                        objWorkOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_ERROR;
                        WSCH_CommonUtils.setOptimizerErrorText(objWorkOrder, errorText);
                        continue;
                    } 
                    //checking if PST(tempStartDateTime is within BH start and end). If so set the PST as the start of the BH
                    else if(tempStartDateTime > wrpExecTime.workingHoursBegin && tempStartDateTime < wrpExecTime.workingHoursEnd) {
                        wrpExecTime.workingHoursBegin = tempStartDateTime;

                        //check if PET(tempEndDateTime) is within the BH endTime. If so set PET as the end of the BH
                        if(tempEndDateTime < wrpExecTime.workingHoursEnd) {
                            wrpExecTime.workingHoursEnd = tempEndDateTime;
                        }
                        if(wrpExecTime.workingHoursBegin < wrpExecTime.workingHoursEnd) {
                            lstWOTimeWindows.add(wrpExecTime);
                        }
                        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows():Wrapper added.');
                        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows():wrpExecTime.workingHoursBegin - ' + wrpExecTime.workingHoursBegin);
                        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows():wrpExecTime.workingHoursEnd - ' + wrpExecTime.workingHoursEnd);
                        continue;
                    } else if(tempEndDateTime < wrpExecTime.workingHoursEnd && tempEndDateTime > wrpExecTime.workingHoursBegin) {
                        wrpExecTime.workingHoursEnd = tempEndDateTime;

                        //check if PST(tempStartDateTime) is after the BH startTime. If so set PST as the start of the BH
                        if(tempStartDateTime > wrpExecTime.workingHoursBegin) {
                            wrpExecTime.workingHoursBegin = tempStartDateTime;
                        }
                        if(wrpExecTime.workingHoursBegin < wrpExecTime.workingHoursEnd) {
                            lstWOTimeWindows.add(wrpExecTime);
                        }
                        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows():Wrapper added.');
                        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows():wrpExecTime.workingHoursBegin - ' + wrpExecTime.workingHoursBegin);
                        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows():wrpExecTime.workingHoursEnd - ' + wrpExecTime.workingHoursEnd);
                        continue;
                    }
                }

                //This is the case of last date
                if(tempStartDate.addDays(i) == tempEndDate) {
                    if(tempEndDateTime < wrpExecTime.workingHoursEnd && tempEndDateTime > wrpExecTime.workingHoursBegin) {
                        wrpExecTime.workingHoursEnd = tempEndDateTime;
                        if(wrpExecTime.workingHoursBegin < wrpExecTime.workingHoursEnd) {
                            lstWOTimeWindows.add(wrpExecTime);
                        }
                        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows():Wrapper added.');                        
                    } else if(tempEndDateTime < wrpExecTime.workingHoursBegin) {
                        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows(): skipping wrapper creation for the date '+ tempEndDate +'as PET < BH Start');
                        continue;
                    } else {
                        lstWOTimeWindows.add(wrpExecTime);
                        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows():Wrapper added.');                        
                    }
                } 
                //This is the case of intermediate days(within first and last date of horizon)
                else {
                    lstWOTimeWindows.add(wrpExecTime);
                    //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows():Wrapper added.');                    
                }
                //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows():wrpExecTime.workingHoursBegin - ' + wrpExecTime.workingHoursBegin);
                //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::constructExecTimeWIndows():wrpExecTime.workingHoursEnd - ' + wrpExecTime.workingHoursEnd);              
            }
         }         
    }
    
    public static List<WSCH_Provider_ECO_Stubs.WorkOrder_WP> setHorizonForApptWO(SVMXC__Territory__c objTerritory, List<SVMXC__Service_Order__c> lstWorkOrderObj, WSCH_ApptParam apptParam, String dispatchProcessId){
        List<WSCH_Provider_ECO_Stubs.WorkOrder_WP> workOrders = new List<WSCH_Provider_ECO_Stubs.WorkOrder_WP>();
        list<BusinessHours> lstWOBusinessHours = new list<BusinessHours>();
        Map<String, Map<Date, WSCH_Provider_ECO_Stubs.ExecutionTime_WP>> mapBHTimeWindows = new Map<String, Map<Date, WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>();
        Map<String, List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>> mapWOTimeWindows = new Map<String, List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>();
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonForApptWO():workOrders size..'+lstWorkOrderObj.size());
        set<BusinessHours> setWOBH = new set<BusinessHours>();
        
        for(SVMXC__Service_Order__c objWorkOrder: lstWorkOrderObj)
        {
            //create list of BH from qualified work orders preferred BH
            if(objWorkOrder.SVMXC__Preferred_Business_Hours__c != null && objWorkOrder.SVMXC__Preferred_Business_Hours__r.IsActive){
                setWOBH.add(mapBusinessHours.get(objWorkOrder.SVMXC__Preferred_Business_Hours__r.Id));
            }
        }        
        //setting horizon dates based on the appointment booking calendar dates
        setHorizonDatesForApptWO(objTerritory,apptParam);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonForApptWO():Updated Horizon Dates for Appointment : '+setSchedHorizDates);
        
        //setting start and end datetime using PST and PET
        setApptParamDates(lstWorkOrderObj[0],objTerritory,apptParam);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonForApptWO(): after validate PST and PET Start DateTime in GMT TZ: ' + apptParam.startDatetime);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonForApptWO(): after validate PST and PET End DateTime in GMT TZ: ' + apptParam.endDatetime);
        
        //adding territory business hr into set.
        setWOBH.add(objDefTerritoryBH); 
                       
        if(setWOBH != null && setWOBH.size() > 0){
            lstWOBusinessHours.addAll(setWOBH);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonForApptWO(): work orders BH size : '+lstWOBusinessHours.size());
            //mapBHTimeWindows = generateBusinessHourDetails(lstWOBusinessHours, apptParam.startDateTime, apptParam.endDateTime, setSchedHorizDates);
            mapBHTimeWindows = generateBusinessHourDetails(lstWOBusinessHours, NULL, NULL, setSchedHorizDates);
        }
        
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonForApptWO():: dispatchProcessId:  '+dispatchProcessId + ' , objTerritory.Id : '+objTerritory.Id);
        
        List<SVMXC__ServiceMax_Processes__c> lstOfDPProcessObj = [SELECT Id, SVMXC__Calendar_Start_Days__c, SVMXC__Calendar_End_Days__c, SVMXC__Dispatch_Method__c, SVMXC__Frequency__c, SVMXC__Full_Run_Unit__c from SVMXC__ServiceMax_Processes__c 
                where RecordType.Name = 'Dispatch Process' AND Id =:dispatchProcessId];
        
        for(SVMXC__Service_Order__c objWorkOrder: lstWorkOrderObj)
        {
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonForApptWO(): Building time windows for Work Order: ' + objWorkOrder.Name);
            List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstWOTimeWindows = new List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
            Map<Date, WSCH_Provider_ECO_Stubs.ExecutionTime_WP> mapWrkOrdrTimeWindows = new Map<Date, WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
            BusinessHours objWrkOrdBH;

            if(objWorkOrder.SVMXC__Preferred_Business_Hours__c != NULL && mapBusinessHours.containsKey(objWorkOrder.SVMXC__Preferred_Business_Hours__c))
            {
                if(mapBHTimeWindows != null && mapBHTimeWindows.size() >0 )
                    mapWrkOrdrTimeWindows = mapBHTimeWindows.get(objWorkOrder.SVMXC__Preferred_Business_Hours__c);
                    
            }
            else
            {
                if(mapBHTimeWindows != null && mapBHTimeWindows.size() >0 )
                    mapWrkOrdrTimeWindows = mapBHTimeWindows.get(objDefTerritoryBH.id);
            }
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonForApptWO(): mapWrkOrdrTimeWindows.size(): ' + mapWrkOrdrTimeWindows.size());
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonForApptWO(): mapWrkOrdrTimeWindows.keyset(): ' + mapWrkOrdrTimeWindows.keyset());
            //It was always considering the PST and PET in the WO for horizon calculation. Not considering the dates selected from the calendar
            WSCH_Provider_ECO_DataMapper.constructExecTimeWIndows(apptParam.startDateTime, apptParam.endDateTime, lstWOTimeWindows, mapWrkOrdrTimeWindows, objWorkOrder);
                
            if(lstWOTimeWindows != NULL && lstWOTimeWindows.size() > 0)
            {
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonForApptWO(): lstWOTimeWindows.size() - ' + lstWOTimeWindows.size());
                List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> woCOExeTime = new List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
                for(WSCH_Provider_ECO_Stubs.ExecutionTime_WP exeTime : lstWOTimeWindows)
                {
                    woCOExeTime.add(new WSCH_Provider_ECO_Stubs.ExecutionTime_WP(exeTime.workingHoursBegin, exeTime.workingHoursEnd));
                }
                mapWOTimeWindows.put(objWorkOrder.id, woCOExeTime);
            }
            //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonForApptWO(): mapWOTimeWindows: ' + mapWOTimeWindows);
        }

        // Build the list of work orders: Include only those work orders that have time windows
        String workOrderType = 'NEW';
        for(SVMXC__Service_Order__c objWorkOrder : lstWorkOrderObj)
        {
            String strOperationType=getOperationType(objWorkOrder);
            if(strOperationType != null && strOperationType.equalsIgnoreCase('remove')){
                workOrders.add(new WSCH_Provider_ECO_Stubs.WorkOrder_WP(objWorkOrder, null, null,strOperationType));
                continue;
            }else if(strOperationType != null && strOperationType.equalsIgnoreCase('update')){
                workOrderType='ASSIGNED';
                //handling CHANGE_ZIP_CODE token work orders
                //if the work order zip changed then we need to clear the work order latitude and longitude details to recalculate new lat,long for thiz zipcode
                if ('CHANGE_ZIP_CODE'.equalsIgnoreCase(objWorkOrder.SVMXC__Scheduling_Change_Token__c)) {
                    objWorkOrder.SVMXC__Latitude__c=null;
                    objWorkOrder.SVMXC__Longitude__c=null;
                }            
            }
            // Building the execution time window for New and Assigned Work Orders
            if(mapWOTimeWindows.containsKey(objWorkOrder.Id) && mapWOTimeWindows.get(objWorkOrder.Id).size() > 0 )
            {
                workOrders.add(new WSCH_Provider_ECO_Stubs.WorkOrder_WP(objWorkOrder, mapWOTimeWindows.get(objWorkOrder.Id), workOrderType,strOperationType));
            }                
        }
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonForApptWO(): workOrders: ' + workOrders.size());
        return workOrders;      
    }

    public static WSCH_Provider_ECO_Stubs.InitJobRequest_WP getTechnicianAndEventDetails(SVMXC__Territory__c objTerritory, Id dpId, List<SVMXC__Service_Group_Members__c> lstTechnicians, Map<String, SVMXC__SVMX_Optimizer__c> mapTechIdOptimizerTrn){
        Map<id, Map<date, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>> mapTechAvailability = new Map<id, Map<date, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>>();
        WSCH_Provider_ECO_Stubs.InitJobRequest_WP initJobWrapper = new WSCH_Provider_ECO_Stubs.InitJobRequest_WP();
        Date datStartDate;
        Date datEndDate;
        Datetime dtmNow = system.now();
        Datetime dtmLastProcessedDateTime;
        initializeBussHr(objTerritory);
        //Integer intNoOfDays=0;
        
        setDefaultParameter(objTerritory);
        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianAndEventDetails():Default values from territory ..'+dclDefaultPerKmCost+','+dclDefaultMaxDistance+','+dclDefaultAverageSpeed+','+dclDefaultFixedCost+','+dclDefaultPerHourCost);
        
        //setting horizon dates
        setHorizonDates(objTerritory,dpId);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianAndEventDetails():Horizon Dates : '+setSchedHorizDates);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianAndEventDetails():Territory BH : '+objDefTerritoryBH);               

        String strDPId = dpId;
        
        //get tech availabilty window
        mapTechAvailability = getTechnicianTimeWindows(intNoOfDays,mapBusinessHours, lstTechnicians,setSchedHorizDates);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianAndEventDetails():mapTechAvailability size ..'+mapTechAvailability.size());

        //Create Technician Wrapper
        List<WSCH_Provider_ECO_Stubs.Technician_WP> resources = doBuildResourceWrapper(lstTechnicians,mapTechAvailability,objTerritory,objSVMXProcess,mapTechIdOptimizerTrn);      
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianAndEventDetails():resources size ..'+resources.size());
        
        //get non WO event details
        List<WSCH_Provider_ECO_Stubs.TechniciansEvent_WP> resourcesEvent = doBuildResourceEventWrapper(intNoOfDays,mapBusinessHours, lstTechnicians,objDefTerritoryBH, strDPId);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianAndEventDetails():resourcesEvent size ..'+resourcesEvent.size());
        initJobWrapper.resources = resources;
        initJobWrapper.technicianEvents = resourcesEvent;
        //heap size issue
        lstTechnicians.clear();
        mapTechAvailability.clear();
        return initJobWrapper;
    } 
    
    public static Map<id, Map<date, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>> getTechnicianTimeWindows(Integer intNoOfCalDays, Map<String, BusinessHours> mapBHours, List<SVMXC__Service_Group_Members__c> lstTechnicians, set<Date> setSchedHorizonDates){
        Map<id, Map<date, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>> mapTechAvailableTW = new Map<id, Map<date, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>>();
        String strTZSidKey;
        String territoryBHId;
        try
        {
            Map<Id, SVMXC__Service_Group_Members__c> mapUsersTechnicians = new Map<Id, SVMXC__Service_Group_Members__c>();
            set<String> setAvailTechAsSFUserList = new set<String>();
            set<String> setAvailTechAsSVMXUserList = new set<String>();
            String strGBL025 = WSCH_CommonUtils.getSettingValue('GLOB001', 'GBL025');            
            for(SVMXC__Service_Group_Members__c tech : lstTechnicians)
            {
                if(tech.SVMXC__Salesforce_User__c != NULL)
                {
                    if(String.isNotEmpty(strGBL025) && strGBL025.equalsIgnoreCase('ServiceMax Event')) {
                        setAvailTechAsSVMXUserList.add(tech.Id);
                    }else{
                        setAvailTechAsSFUserList.add(tech.SVMXC__Salesforce_User__c);
                    }
                    mapUsersTechnicians.put(tech.SVMXC__Salesforce_User__c, tech);
                }
                else
                    setAvailTechAsSVMXUserList.add(tech.Id);
                //if technician don't have working hours than set territory business hour as working hour.
                if(tech.SVMXC__Working_Hours__c == null){
                    tech.SVMXC__Working_Hours__c = tech.SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c;
                }
            }
            if(lstTechnicians != null && !lstTechnicians.isEmpty()) {
                strTZSidKey = lstTechnicians.get(0).SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey;
                territoryBHId = lstTechnicians.get(0).SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c;
            }

            //getting horizon start and end datetime (+ or - 1 days) for reducing event queries.
            /*DateTime dtmStartDateTime = dtmSchedulingHorizonStartDateTime.addDays(-1);
            integer noOfDays=0;
            if( objSVMXProcess != null && objSVMXProcess.SVMXC__Calendar_End_Days__c != null)
                noOfDays = (objSVMXProcess.SVMXC__Calendar_End_Days__c).intValue();
            Datetime dtmEndDatetime = dtmStartDateTime.addDays(noOfDays+1);*/
            integer noOfDays = (objSVMXProcess.SVMXC__Calendar_End_Days__c).intValue();
            DateTime dtmSchedulingHorizonStartDateTime;
            DateTime dtmSchedulingHorizonEndDateTime;

            List<DateTime> lstHorizonStartAndEndDateTime = WSCH_CommonUtils.getDPHorizonStartAndEndDates(objSVMXProcess, mapBHours.get(territoryBHId));
            if(lstHorizonStartAndEndDateTime != null && lstHorizonStartAndEndDateTime.size() == 2) {
                dtmSchedulingHorizonStartDateTime = lstHorizonStartAndEndDateTime[0];
                dtmSchedulingHorizonEndDateTime = lstHorizonStartAndEndDateTime[1];
            }

            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():no Of horizon Days in DP - ' + noOfDays);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():dtmSchedulingHorizonStartDateTime - ' + dtmSchedulingHorizonStartDateTime);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():dtmSchedulingHorizonEndDateTime - ' + dtmSchedulingHorizonEndDateTime);

            DateTime horizonStartDateTimeGmt = WSCH_DateUtils.doTZConversion(dtmSchedulingHorizonStartDateTime, strTZSidKey , 'GMT');
            DateTime horizonEndDateTimeGmt = WSCH_DateUtils.doTZConversion(dtmSchedulingHorizonEndDateTime, strTZSidKey , 'GMT');

            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():horizonStartDateTimeGmt - ' + horizonStartDateTimeGmt);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():horizonEndDateTimeGmt - ' + horizonEndDateTimeGmt);

            //Map<Id, Event> mapSFEvent = new Map<Id, Event>([Select Id, WhatId, Subject, Description, ActivityDateTime, OwnerId, EndDateTime, DurationInMinutes,IsAllDayEvent,ActivityDate,StartDatetime, Location,SVMXC__Driving_Time__c, SVMXC__Driving_Time_Home__c, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c from Event where OwnerId in:setAvailTechAsSFUserList AND (StartDateTime <= :dtmEndDatetime AND EndDateTime >= :dtmStartDateTime)]);
            Map<Id, Event> mapSFEvent = new Map<Id, Event>([Select Id, WhatId, Subject, Description, ActivityDateTime, OwnerId, EndDateTime, DurationInMinutes,IsAllDayEvent,ActivityDate,StartDatetime, Location,SVMXC__Driving_Time__c, SVMXC__Driving_Time_Home__c, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c from Event where OwnerId in:setAvailTechAsSFUserList AND (IsRecurrence != true) AND (StartDateTime <= :horizonEndDateTimeGmt AND EndDateTime >= :horizonStartDateTimeGmt)]);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows(): - Salesforce Event list size: ' + mapSFEvent.size());
            Map<String, List<Date>> mapTechAllDayEvents = new Map<String, List<Date>>();
            Map<String, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>> mapTechMultiDayEvents = new Map<String, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>();
            for(Event ev : mapSFEvent.values()){
                SVMXC__Service_Group_Members__c technician = mapUsersTechnicians.get(ev.ownerId);
                //Convert event start and end dateime into technician TZ.
                DateTime startDatetimeBH = WSCH_DateUtils.doTZConversion(ev.StartDateTime, 'GMT', strTZSidKey);
                DateTime endDatetimeBH = WSCH_DateUtils.doTZConversion(ev.EndDateTime, 'GMT', strTZSidKey);
                
                integer intDays =  startDatetimeBH.DateGMT().daysBetween(endDatetimeBH.DateGMT());
                //integer intDays =  ev.StartDateTime.DateGMT().daysBetween(ev.EndDateTime.DateGMT());
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():intDays- ' + intDays);
                if(ev.IsAllDayEvent == true){
                    List<Date> lstAlldays = new List<Date>();
                    //integer intDays =  ev.StartDateTime.DateGMT().daysBetween(ev.EndDateTime.DateGMT());
                    if(intDays > 0){//multiday all day event
                        if(!mapTechAllDayEvents.containsKey(technician.Id))
                            mapTechAllDayEvents.put(technician.Id,lstAlldays);
                        for(integer i = 0; i <= intDays; i++) {
                            mapTechAllDayEvents.get(technician.Id).add(ev.StartDateTime.addDays(i).dateGMT());
                        }
                    }else{//single day all day event
                        if(!mapTechAllDayEvents.containsKey(technician.Id)){
                            mapTechAllDayEvents.put(technician.Id,lstAlldays);
                        }
                        mapTechAllDayEvents.get(technician.Id).add(ev.StartDateTime.dateGMT());
                    }
                }else if(intDays == 1){ //multiday event but not set isAllDayEvent flag to true.
                    list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstMultiDays = new list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
                    WSCH_Provider_ECO_Stubs.ExecutionTime_WP exeTime = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP();
                    exeTime.workingHoursBegin = ev.EndDateTime;
                    exeTime.workingHoursEnd = ev.StartDateTime; 
                    if(!mapTechMultiDayEvents.containsKey(technician.Id))
                        mapTechMultiDayEvents.put(technician.Id,lstMultiDays);

                    mapTechMultiDayEvents.get(technician.Id).add(exeTime);

                }else if(intDays > 1){
                    for(integer i = 0; i <= intDays; i++) {
                        if(i==0){
                            list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstMultiDays = new list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
                            WSCH_Provider_ECO_Stubs.ExecutionTime_WP exeTime = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP();
                            exeTime.workingHoursBegin = ev.EndDateTime;
                            exeTime.workingHoursEnd = ev.StartDateTime;
                            if(!mapTechMultiDayEvents.containsKey(technician.Id))
                                mapTechMultiDayEvents.put(technician.Id,lstMultiDays);
        
                            mapTechMultiDayEvents.get(technician.Id).add(exeTime);
                            continue;
                        }
                        if(i==intDays){
                            continue;
                        }
                        List<Date> lstAlldays = new List<Date>();
                        if(!mapTechAllDayEvents.containsKey(technician.Id)){
                            mapTechAllDayEvents.put(technician.Id,lstAlldays);
                        }
                        mapTechAllDayEvents.get(technician.Id).add(ev.StartDateTime.addDays(i).dateGMT());
                    }
                }
            }
            //Map<Id, SVMXC__SVMX_Event__c> mapSVMXEvent = new Map<Id, SVMXC__SVMX_Event__c>([Select Id, Name, SVMXC__Location__c, SVMXC__Description__c, SVMXC__DurationInMinutes__c, SVMXC__WhatId__c,SVMXC__Technician__c, SVMXC__ActivityDate__c,SVMXC__ActivityDateTime__c,SVMXC__EndDateTime__c,SVMXC__StartDateTime__c,SVMXC__IsAllDayEvent__c, SVMXC__Driving_Time__c, SVMXC__Driving_Time_Home__c, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c from SVMXC__SVMX_Event__c where SVMXC__Technician__c in:setAvailTechAsSVMXUserList AND (SVMXC__StartDateTime__c <= :dtmEndDateTime and SVMXC__EndDateTime__c >= :dtmStartDateTime)]);
            Map<Id, SVMXC__SVMX_Event__c> mapSVMXEvent = new Map<Id, SVMXC__SVMX_Event__c>([Select Id, Name, SVMXC__Location__c, SVMXC__Description__c, SVMXC__DurationInMinutes__c, SVMXC__WhatId__c,SVMXC__Technician__c, SVMXC__ActivityDate__c,SVMXC__ActivityDateTime__c,SVMXC__EndDateTime__c,SVMXC__StartDateTime__c,SVMXC__IsAllDayEvent__c, SVMXC__Driving_Time__c, SVMXC__Driving_Time_Home__c, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c from SVMXC__SVMX_Event__c where SVMXC__Technician__c in:setAvailTechAsSVMXUserList AND (SVMXC__StartDateTime__c <= :horizonEndDateTimeGmt and SVMXC__EndDateTime__c >= :horizonStartDateTimeGmt)]);       
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():: SVMX event list size: ' + mapSVMXEvent.size());
            for(SVMXC__SVMX_Event__c svmxEvent : mapSVMXEvent.values()){
                //Convert event start and end dateime into technician TZ.
                DateTime startDatetimeBH = WSCH_DateUtils.doTZConversion(svmxEvent.SVMXC__StartDateTime__c, 'GMT', strTZSidKey);
                DateTime endDatetimeBH = WSCH_DateUtils.doTZConversion(svmxEvent.SVMXC__EndDateTime__c, 'GMT', strTZSidKey);
                
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():strTZSidKey- ' + strTZSidKey);
                //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():startDatetimeBH- ' + startDatetimeBH);
                //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():endDatetimeBH- ' + endDatetimeBH);
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():svmxEvent.SVMXC__StartDateTime__c- ' + svmxEvent.SVMXC__StartDateTime__c);
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():svmxEvent.SVMXC__EndDateTime__c- ' + svmxEvent.SVMXC__EndDateTime__c);

                integer intDays =  startDatetimeBH.DateGMT().daysBetween(endDatetimeBH.DateGMT());
                //integer intDays =  svmxEvent.SVMXC__StartDateTime__c.DateGMT().daysBetween(svmxEvent.SVMXC__EndDateTime__c.DateGMT());
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():intDays- ' + intDays);
                //get all day event and create list of all day event
                if(svmxEvent.SVMXC__IsAllDayEvent__c == true){
                    List<Date> lstAlldaysSVMX = new List<Date>();
                    //integer intDays =  svmxEvent.SVMXC__StartDateTime__c.DateGMT().daysBetween(svmxEvent.SVMXC__EndDateTime__c.DateGMT());
                    if(intDays > 0){//Multiday all day event
                        if(!mapTechAllDayEvents.containsKey(svmxEvent.SVMXC__Technician__c))
                            mapTechAllDayEvents.put(svmxEvent.SVMXC__Technician__c,lstAlldaysSVMX);

                        for(integer i = 0; i <= intDays; i++) {
                            mapTechAllDayEvents.get(svmxEvent.SVMXC__Technician__c).add(svmxEvent.SVMXC__StartDateTime__c.addDays(i).dateGMT());
                        }
                    }else{ // single day all day event
                        if(!mapTechAllDayEvents.containsKey(svmxEvent.SVMXC__Technician__c)){
                            mapTechAllDayEvents.put(svmxEvent.SVMXC__Technician__c,lstAlldaysSVMX);
                        }
                        mapTechAllDayEvents.get(svmxEvent.SVMXC__Technician__c).add(svmxEvent.SVMXC__StartDateTime__c.dateGMT());
                    }
                }else if(intDays == 1){ //multiday event but not set isAllDayEvent flag to true.
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():Multiday event span 1 day...Start-'+svmxEvent.SVMXC__StartDateTime__c+' End- '+svmxEvent.SVMXC__EndDateTime__c);
                    list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstMultiDays = new list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
                    WSCH_Provider_ECO_Stubs.ExecutionTime_WP exeTime = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP();
                    exeTime.workingHoursBegin = svmxEvent.SVMXC__EndDateTime__c;
                    exeTime.workingHoursEnd = svmxEvent.SVMXC__StartDateTime__c;
                    if(!mapTechMultiDayEvents.containsKey(svmxEvent.SVMXC__Technician__c))
                        mapTechMultiDayEvents.put(svmxEvent.SVMXC__Technician__c,lstMultiDays);

                    mapTechMultiDayEvents.get(svmxEvent.SVMXC__Technician__c).add(exeTime);
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():exeTime- ' + exeTime);
                }else if(intDays > 1){
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():Multiday event span > 1 day...Start-'+svmxEvent.SVMXC__StartDateTime__c+' End- '+svmxEvent.SVMXC__EndDateTime__c);
                    for(integer i = 0; i <= intDays; i++) {
                        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():i- ' + i);
                        if(i==0){
                            list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstMultiDays = new list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
                            WSCH_Provider_ECO_Stubs.ExecutionTime_WP exeTime = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP();
                            exeTime.workingHoursBegin = svmxEvent.SVMXC__EndDateTime__c;
                            exeTime.workingHoursEnd = svmxEvent.SVMXC__StartDateTime__c;
                            if(!mapTechMultiDayEvents.containsKey(svmxEvent.SVMXC__Technician__c))
                                mapTechMultiDayEvents.put(svmxEvent.SVMXC__Technician__c,lstMultiDays);
        
                            mapTechMultiDayEvents.get(svmxEvent.SVMXC__Technician__c).add(exeTime);
                            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():exeTime- ' + exeTime);
                            continue;
                        }
                        if(i==intDays){
                            continue;
                        }
                        List<Date> lstAlldays = new List<Date>();
                        if(!mapTechAllDayEvents.containsKey(svmxEvent.SVMXC__Technician__c)){
                            mapTechAllDayEvents.put(svmxEvent.SVMXC__Technician__c,lstAlldays);
                        }
                        mapTechAllDayEvents.get(svmxEvent.SVMXC__Technician__c).add(svmxEvent.SVMXC__StartDateTime__c.addDays(i).dateGMT());
                        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():svmxEvent.SVMXC__StartDateTime__c.addDays(i).dateGMT()- ' + svmxEvent.SVMXC__StartDateTime__c.addDays(i).dateGMT());
                    }
                }

            }
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():: SF and SVMX Allday event dates for all techs: '+mapTechAllDayEvents);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():: SF and SVMX Multi day event dates for all techs ' + mapTechMultiDayEvents);

            for(SVMXC__Service_Group_Members__c tech: lstTechnicians)
            {
                set<Date> setRemovalDates = new set<Date>();
                set<Date> setFinalDates = new set<Date>(setSchedHorizonDates);
                List<Date> lstAllDays = mapTechAllDayEvents.get(tech.id);
                list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstMultiDays = mapTechMultiDayEvents.get(tech.id);
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():: allday event dates for tech: '+tech.name+ ': list of all day events..'+lstAllDays);                
                if(lstAllDays != null && lstAllDays.size() > 0){
                    for(Date dt : lstAllDays){
                        if(setSchedHorizonDates.contains(dt)){
                            setRemovalDates.add(dt);
                        }
                    }
                }
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():: allday event dates for tech: ' + tech.Name +'- '+setRemovalDates);
                setFinalDates.removeAll(setRemovalDates);
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():: after removing :setFinalDates(): ' + setFinalDates);
                try
                {
                    mapTechAvailableTW = getTechAvailabilityWindow(mapTechAvailableTW, tech.Id, mapBHours.get(tech.SVMXC__Working_Hours__c), mapBHours.get(tech.SVMXC__Break_Hours__c), setFinalDates, lstMultiDays);
                    //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():mapTechAvailableTW..size : ' + mapTechAvailableTW.size());                
                }
                catch(Exception ex)
                {
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows() exception for: ' + tech.Id +' exception...'+ex.getStackTraceString());
                }
            }           
        }
        catch(Exception ex)
        {
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows(): Failed with the exception: ' + ex.getMessage() + '\n' + 'stackTrace - ' + ex.getStackTraceString());
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows() Ends');
            //WSCH_AuditLogger.finish();
        }
        return mapTechAvailableTW;
    }

    public static Map<id, Map<date, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>> getTechAvailabilityWindow(Map<id, Map<date, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>> mapTechAvailableTW, id techId, BusinessHours oBusinessHours, BusinessHours breakBH, set<Date> setSchedHorizonDates, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstMultiDayEvent)
    {
        DateTime dtmBusinessHourStartDateTime, dtmBusinessHourEndDateTime, dtmBreakHourStartDateTime, dtmBreakHourEndDateTime;
        
        Boolean isValidBusinessHour = TRUE;
        
        Map<id, Map<date, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>> techAvail = new Map<id, Map<date, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>>();
        Map<date, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>> actualAvailableWindow = new Map<date, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>();
        Map<date, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>> availableWindow = new Map<date, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>();
        Map<date, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>> eventWindow = new Map<date, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>();
        
       
        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::techAvailabilityWindow():In techAvailabilityWindow for technician: ' + techId);
        if(mapTechAvailableTW != NULL) // Will be TRUE from the second tech onwards
            techAvail = mapTechAvailableTW;
        
        if(isValidBusinessHour == TRUE)
        {
            // Build technician's working time windows for each working day in the scheduling horizon
            for(Date calendarDate : setSchedHorizonDates)
            {
                // Check if the date is a working day
                if(isWorkingDay(oBusinessHours, calendarDate))
                {
                    list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstEventTimeWindows = new list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
                    string datesDay = (datetime.newInstanceGmt(calendarDate, Time.newinstance(0, 0, 0, 0))).formatGmt('EEEE');

                    // Get the start and end times for the given date
                    Time timTechStartTime = getStartEndTime(oBusinessHours, datesDay, 'StartTime');
                    Time timTechEndTime = getStartEndTime(oBusinessHours, datesDay, 'EndTime');
                    
                    // If it is a 24 Hours Business Day, not valid for technician; skip
                    if(timTechStartTime == timTechEndTime)
                        continue;
                    
                    dtmBusinessHourStartDateTime = dcUtils.getDateTimeInTimezone(calendarDate, timTechStartTime, oBusinessHours.TimeZoneSidKey);
                    dtmBusinessHourEndDateTime = dcUtils.getDateTimeInTimezone(calendarDate, timTechEndTime, oBusinessHours.TimeZoneSidKey);
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechAvailabilityWindow:dtmBusinessHourStartDateTime- ' + dtmBusinessHourStartDateTime);
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechAvailabilityWindow:dtmBusinessHourEndDateTime- ' + dtmBusinessHourEndDateTime);

                    //if BH startTime is < horizonStartTime, set horizonStartTime as the startTime
                    if(dtmBusinessHourStartDateTime < dtmSchedulingHorizonStartDateTime) {
                        dtmBusinessHourStartDateTime = dtmSchedulingHorizonStartDateTime;
                    }
                    
                    // If Incremental run OR Full Run's Start After Unit is Hours
                    // if(isFullRun == FALSE || isDays == FALSE)
                    // {
                    //     // if day's start time is < Scheduling Horizon's Start Date Time, set day's start time = Scheduling Horizon's Start Date Time
                    //     if(dtmBusinessHourStartDateTime < dtmSchedulingHorizonStartDateTime){
                    //         dtmBusinessHourStartDateTime = dtmSchedulingHorizonStartDateTime;
                    //     }            
                    // }
                    //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechAvailabilityWindow:dtmBusinessHourStartDateTime- ' + dtmBusinessHourStartDateTime);
                    //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechAvailabilityWindow:dtmBusinessHourEndDateTime- ' + dtmBusinessHourEndDateTime);
                    if(lstMultiDayEvent != null && lstMultiDayEvent.size() > 0){
                        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechAvailabilityWindow:calendarDate- ' + calendarDate);
                        for(WSCH_Provider_ECO_Stubs.ExecutionTime_WP exeTime : lstMultiDayEvent){
                            //Date startDate = exeTime.workingHoursBegin.dateGmt();
                            //Date endDate = exeTime.workingHoursEnd.dateGmt();
                            //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechAvailabilityWindow:exeTime.workingHoursBegin- ' + exeTime.workingHoursBegin);
                            //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechAvailabilityWindow:exeTime.workingHoursEnd- ' + exeTime.workingHoursEnd);
                            
                            DateTime startDateTimeTerrTZ = WSCH_DateUtils.doTZConversion(exeTime.workingHoursBegin, 'GMT', oBusinessHours.TimeZoneSidKey);
                            DateTime endDateTimeTerrTZ = WSCH_DateUtils.doTZConversion(exeTime.workingHoursEnd, 'GMT', oBusinessHours.TimeZoneSidKey);
                            //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechAvailabilityWindow:startDateTimeTerrTZ- ' + startDateTimeTerrTZ);
                            //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechAvailabilityWindow:endDateTimeTerrTZ- ' + endDateTimeTerrTZ);

                            Date startDate = startDateTimeTerrTZ.dateGmt();
                            Date endDate = endDateTimeTerrTZ.dateGmt();

                            //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechAvailabilityWindow:startDate TerrTZ- ' + startDate);
                            //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechAvailabilityWindow:endDate TerrTZ- ' + endDate);
                            
                            if(calendarDate >= startDate){
                                if(dtmBusinessHourStartDateTime < exeTime.workingHoursBegin){
                                    dtmBusinessHourStartDateTime = exeTime.workingHoursBegin;
                                    //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechAvailabilityWindow:inside if()dtmBusinessHourStartDateTime- ' + dtmBusinessHourStartDateTime);
                                }
                                //break;
                            }else if(calendarDate >= endDate){
                                if(exeTime.workingHoursEnd < dtmBusinessHourEndDateTime){ // if it is last day than BH end override by last day time
                                    dtmBusinessHourEndDateTime = exeTime.workingHoursEnd;
                                    //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechAvailabilityWindow:inside if()dtmBusinessHourEndDateTime- ' + dtmBusinessHourEndDateTime);
                                }
                                //break;                            
                            }
                        }
                    }

                    // If the available working window is valid
                    if(dtmBusinessHourStartDateTime < dtmBusinessHourEndDateTime)
                    {
                        // Setup technician's Business Hours as available window
                        WSCH_Provider_ECO_Stubs.ExecutionTime_WP wrpTempAvailableWindow = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP(dtmBusinessHourStartDateTime, dtmBusinessHourEndDateTime);
                        lstEventTimeWindows.add(wrpTempAvailableWindow);
                        lstEventTimeWindows = sortExecutionTime(lstEventTimeWindows);
                        availableWindow.put(calendarDate, lstEventTimeWindows);
                    }
                }
            }
            //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::techAvailabilityWindow() Available time window size: ' + availableWindow.size() + '; Available time windows: ' + availableWindow.size());
            
            if(availableWindow.size() > 0)
                techAvail.put(techId, availableWindow);
        }
        return techAvail;
    }   

    
    public static List<WSCH_Provider_ECO_Stubs.Technician_WP> doBuildResourceWrapper(List<SVMXC__Service_Group_Members__c> lstTechs, Map<id, Map<date, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>> mapTechAvailabilityTW, SVMXC__Territory__c objTerritory,SVMXC__ServiceMax_Processes__c objSVMXProc,Map<String, SVMXC__SVMX_Optimizer__c> mapTechOptTrnObj){
        List<WSCH_Provider_ECO_Stubs.Technician_WP> resources = new List<WSCH_Provider_ECO_Stubs.Technician_WP>();      
        // Create Technician Window 
        /*Boolean isDailyMode = FALSE;
        if(mapSettingValues.containsKey('OMAX001_SET003') == TRUE)
        {
            if(String.valueof(mapSettingValues.get('OMAX001_SET003')) == 'DAILY')
            isDailyMode = TRUE;
        }*/

        //Integer intTechnicianCount = 0;
        Integer intTechOnlyCount = lstTechs.size();
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::doBuildResourceWrapper():: intTechOnlyCount: ' + intTechOnlyCount);
        Map<String, List<WSCH_Provider_ECO_Stubs.Expertise_WP>> mapTechSkill = new Map<String, List<WSCH_Provider_ECO_Stubs.Expertise_WP>>();
        mapTechSkill = getTechExpertiseMap(lstTechs);
        for(SVMXC__Service_Group_Members__c tech : lstTechs)
        {
            String strOperationType=null;
            if(mapTechOptTrnObj != null && mapTechOptTrnObj.size()>0)
                strOperationType=getOperationType(mapTechOptTrnObj.get(tech.Id+'_'+tech.Name));
                
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::doBuildResourceWrapper():: strOperationType: ' + strOperationType);
            if(strOperationType != null && strOperationType.equalsIgnoreCase('updateZip')){
                //handling CHANGE_ZIP_CODE token for technician
                //if the technician zip changed then we need to clear the technician latitude and longitude details to recalculate new lat,long for this zipcode
                tech.SVMXC__Latitude_Home__c=null;
                tech.SVMXC__Longitude_Home__c=null;
                strOperationType = 'update';
            }                
            setTechnicianParams(tech);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::doBuildResourceWrapper():: Updating technician: ' + tech.id + '(' + tech.Name + ')');
            
            if(mapTechAvailabilityTW.containsKey(tech.Id) && mapTechAvailabilityTW.get(tech.Id).size() > 0) {
                List<WSCH_Provider_ECO_Stubs.Expertise_WP> lstTechSkill = new List<WSCH_Provider_ECO_Stubs.Expertise_WP>();
                lstTechSkill = mapTechSkill.get(tech.Id);
                //Integer intEventCount = 0;
                //Double dblMaxMinutes = 0;
                // Updating technician max hours 
                //if technician level not defined then take it from territory
                if(tech.SVMXC__Max_Hours__c == null || (tech.SVMXC__Max_Hours__c != null && tech.SVMXC__Max_Hours__c < 0)) {
                    if(tech.SVMXC__Service_Territory__c != null && tech.SVMXC__Service_Territory__r.SVMXC__Max_Hours__c != null) {
                        if(tech.SVMXC__Service_Territory__r.SVMXC__Max_Hours__c < 0 ){
                            tech.SVMXC__Max_Hours__c = 0;
                        } else {
                            tech.SVMXC__Max_Hours__c = tech.SVMXC__Service_Territory__r.SVMXC__Max_Hours__c;
                        }
                    } else {
                        tech.SVMXC__Max_Hours__c = 0;
                    }
                }
                Map<date, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>> mapTechTimeWindows = mapTechAvailabilityTW.get(tech.Id);
                List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstDailyModeExeTime = new List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();            
                for(date dt : mapTechTimeWindows.keySet()){
                    List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstTechTimeWindow = mapTechTimeWindows.get(dt);
                    lstDailyModeExeTime.addAll(lstTechTimeWindow);               
                }
                // Don't sent technician if availability is null
                if(lstDailyModeExeTime.size() == 0)
                    continue;
                //sending overtime tolerance value to optimax engine.
                Double dblOverTimeInSecs=null;
                if(objSVMXProc.SVMXC__Tolerance__c != NULL && objSVMXProc.SVMXC__Tolerance__c > 0){
                    dblOverTimeInSecs = 60 * objSVMXProc.SVMXC__Tolerance__c.intValue();
                }    
                //sending drive time before shift start value to optimax engine.
                //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::doBuildResourceWrapper():: objSVMXProc.SVMXC__SM_Drive_Before_Shift_Start__c: ' + objSVMXProc.SVMXC__SM_Drive_Before_Shift_Start__c);
                
                List<WSCH_Provider_ECO_Stubs.ExcSetting_WP> listTechParameters = new List<WSCH_Provider_ECO_Stubs.ExcSetting_WP>();
                if(objSVMXProc.SVMXC__SM_Drive_Before_Shift_Start__c != NULL && objSVMXProc.SVMXC__SM_Drive_Before_Shift_Start__c > 0){
                    listTechParameters.add(setOrganizationParameters('driveBeforeShiftStartInSecs', (60 * objSVMXProc.SVMXC__SM_Drive_Before_Shift_Start__c.intValue()) + ''));
                } else {
                    listTechParameters.add(setOrganizationParameters('driveBeforeShiftStartInSecs', '0'));
                }
                if(objSVMXProc.SVMXC__SM_Drive_After_Shift_End__c != NULL && objSVMXProc.SVMXC__SM_Drive_After_Shift_End__c > 0){
                    listTechParameters.add(setOrganizationParameters('driveAfterShiftEndInSecs', (60 * objSVMXProc.SVMXC__SM_Drive_After_Shift_End__c.intValue()) + ''));
                } else {
                    listTechParameters.add(setOrganizationParameters('driveAfterShiftEndInSecs', '0'));
                }
                //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::doBuildResourceWrapper():: listTechParameters: ' + listTechParameters);
                WSCH_Provider_ECO_Stubs.Technician_WP tempTechWP = new WSCH_Provider_ECO_Stubs.Technician_WP(tech, lstDailyModeExeTime,lstTechSkill,strOperationType,dblOverTimeInSecs,listTechParameters);
                resources.add(tempTechWP);
                //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::doBuildResourceWrapper():: resources: size() ' + resources.size());
                //intTechnicianCount++;
            }else{
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::doBuildResourceWrapper():: This technician not having timewindows within the horizon');
                WSCH_Provider_ECO_Stubs.Technician_WP tempTechWP = new WSCH_Provider_ECO_Stubs.Technician_WP(tech, null,null,null,null,null);
                resources.add(tempTechWP);

            }
        }
        return resources;      
    }
    
    public static List<WSCH_Provider_ECO_Stubs.TechniciansEvent_WP> doBuildResourceEventWrapper(Integer intNoOfCalDays, Map<String, BusinessHours> mapBHours, List<SVMXC__Service_Group_Members__c> lstTechnicians, BusinessHours defTerritoryBH, String strDispatchProcessId){
            Map<String, Map<String, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>> mapTechIdEventNonWO = new Map<String, Map<String, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>>();
            List<WSCH_Provider_ECO_Stubs.TechniciansEvent_WP> lstTechEvent = new List<WSCH_Provider_ECO_Stubs.TechniciansEvent_WP>();

        try
        {
            DateTime dtmStartDateTime = dtmSchedulingHorizonStartDateTime;
            Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
            
            // Get the unique 3 character key prefix of Work Order object. This is used to check if events are related to Work Orders
            Schema.Describesobjectresult woDefinitions;
            if (allObjs.containsKey('SVMXC__Service_Order__c') == TRUE)
                woDefinitions = allObjs.get('SVMXC__Service_Order__c').getDescribe();
            else
                woDefinitions = allObjs.get('Service_Order__c').getDescribe();
            String woKeyPrefix = woDefinitions.getKeyPrefix();
            allObjs.clear();
            woDefinitions = null;
            // Calculate the end date of the initial scheduling horizon. Get end date time from end date.
            /*Date datStartDate = Date.valueOf(dtmStartDateTime.format('yyyy-MM-dd', defTerritoryBH.timeZoneSidKey));
            Date datActualStartDate = datStartDate;
            Date datEndDate = datStartDate.addDays(intNoOfCalDays - 1);
            DateTime dtmLastDaysEndDateTime = dcUtils.getDateTimeInTimezone(datEndDate, Time.newInstance(23, 59, 59, 0), defTerritoryBH.timeZoneSidKey);*/
            Double dblRequiredCapacity = 0;
            Double dblActualCapacity = 0;
            
            set<String> setAvailTechAsSFUserList = new set<String>();
            set<String> setAvailTechAsSVMXUserList = new set<String>();
            set<String> setAvailTech = new set<String>();
            set<Date> setCurrentSchedHorizonDates;
            
            //Map<String, List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>> mapEventNonWO = new Map<String, List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>();
            Map<Id, SVMXC__Service_Group_Members__c> mapUsersTechnicians = new Map<Id, SVMXC__Service_Group_Members__c>();
            Map<Id,SVMXC__Service_Group_Members__c> mapIdTechnicians = new Map<Id,SVMXC__Service_Group_Members__c>();
            Map<String, String> mapTechTimeZone = new Map<String, String>();
            set<Id> setWrkOrdsToReschedule = new set<Id>();
            set<Id> setWrkOrdsToForceFix = new set<Id>();

            /*  Prepare lists of Technicians associated with Salesforce Users & Technicians with
                only Enable Scheduling checked
                As it is possible for one Salesforce User to be associated with >1 Technician,
                prepare a map associating one Salesforce User with only one Technician
            */
            for(SVMXC__Service_Group_Members__c tech : lstTechnicians)
            {
                //setAvailTech.add(tech.Id);
                mapIdTechnicians.put(tech.Id, tech);
        
                if(tech.SVMXC__Salesforce_User__c != NULL)
                {
                    setAvailTechAsSFUserList.add(tech.SVMXC__Salesforce_User__c);
                    mapUsersTechnicians.put(tech.SVMXC__Salesforce_User__c, tech);
                }
                else
                    setAvailTechAsSVMXUserList.add(tech.Id);
            }
            
            /*Date datLastCalcEndDate;
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::doBuildResourceEventWrapper(): Start Date: ' + datStartDate);
            setCurrentSchedHorizonDates = new set<Date>();
            for(integer i = 0; i < intNoOfCalDays; i++)
            {
                // Prepare a set of all scheduling horizon dates from datStartDate to datEndDate. These dates are in Territory's time zone
                setCurrentSchedHorizonDates.add(datStartDate.addDays(i));
            }
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::doBuildResourceEventWrapper():: Current Scheduling Horizon Dates: ' + setCurrentSchedHorizonDates);
            datLastCalcEndDate = datStartDate.addDays(intNoOfCalDays - 1);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::doBuildResourceEventWrapper():: Original End Date: ' + datLastCalcEndDate);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::doBuildResourceEventWrapper():: dtmLastDaysEndDateTime: ' + dtmLastDaysEndDateTime);*/

            //commented the above logic and introduced the below to get the horizonstartDateTime and horizonEndDateTime
            integer noOfDays = (objSVMXProcess.SVMXC__Calendar_End_Days__c).intValue();
            DateTime dtmSchedulingHorizonStartDateTime;
            DateTime dtmSchedulingHorizonEndDateTime;

            List<DateTime> lstHorizonStartAndEndDateTime = WSCH_CommonUtils.getDPHorizonStartAndEndDates(objSVMXProcess, defTerritoryBH);
            if(lstHorizonStartAndEndDateTime != null && lstHorizonStartAndEndDateTime.size() == 2) {
                dtmSchedulingHorizonStartDateTime = lstHorizonStartAndEndDateTime[0];
                dtmSchedulingHorizonEndDateTime = lstHorizonStartAndEndDateTime[1];
            }

            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():no Of horizon Days in DP - ' + noOfDays);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():dtmSchedulingHorizonStartDateTime - ' + dtmSchedulingHorizonStartDateTime);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():dtmSchedulingHorizonEndDateTime - ' + dtmSchedulingHorizonEndDateTime);

            DateTime horizonStartDateTimeGmt = WSCH_DateUtils.doTZConversion(dtmSchedulingHorizonStartDateTime, defTerritoryBH.TimeZoneSidKey , 'GMT');
            DateTime horizonEndDateTimeGmt = WSCH_DateUtils.doTZConversion(dtmSchedulingHorizonEndDateTime, defTerritoryBH.TimeZoneSidKey , 'GMT');

            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():horizonStartDateTimeGmt - ' + horizonStartDateTimeGmt);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechnicianTimeWindows():horizonEndDateTimeGmt - ' + horizonEndDateTimeGmt);
            /*  For technician records with Salesforce_User__c != NULL, retrieve records from Event where 
                StartDateTime is between firstDaysStartDateTime and lastDaysEndDateTime OR
                StartDateTime is before firstDaysStartDateTime, but EndDateTime is after firstDaysStartDateTime
            */
            set<Id> setEventWorkOrderIds = new set<Id>();
            Map<Id, Event> mapSFEvent = new Map<Id, Event>();
            mapSFEvent = getMapSFEventforTech(setAvailTechAsSFUserList, horizonStartDateTimeGmt, horizonEndDateTimeGmt);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::doBuildResourceEventWrapper(): - Salesforce Event list size: ' + mapSFEvent.size());
            for(Event e: mapSFEvent.values())
            {
                // If it is a work order event, add the work order to the list of work orders
                if(e.WhatId != NULL && String.valueof(e.WhatId).startsWith(woKeyPrefix) == TRUE)
                {
                    setEventWorkOrderIds.add(e.WhatId);
                }
            }
            /*  For technician records with Salesforce_User__c = NULL and Enable_Scheduling__c = TRUE, retrieve records from ServiceMax_Event__c where
                StartDateTime is between firstDaysStartDateTime and lastDaysEndDateTime OR
                StartDateTime is before firstDaysStartDateTime, but EndDateTime is after firstDaysStartDateTime
            */
            Map<Id, SVMXC__SVMX_Event__c> mapSVMXEvent = new Map<Id, SVMXC__SVMX_Event__c>();
            
            mapSVMXEvent = getMapSVMXEventforTech(setAvailTechAsSVMXUserList, horizonStartDateTimeGmt, horizonEndDateTimeGmt);
            
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::doBuildResourceEventWrapper():: SVMX Event list size: ' + mapSVMXEvent.size());
            
            for(SVMXC__SVMX_Event__c e: mapSVMXEvent.values())
            {
                // If it is a work order event, add the work order to the list of work orders
                if(e.SVMXC__WhatId__c != NULL && String.valueof(e.SVMXC__WhatId__c).startsWith(woKeyPrefix) == TRUE)
                {
                    setEventWorkOrderIds.add(e.SVMXC__WhatId__c);
                }
            }
            
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::doBuildResourceEventWrapper():: setEventWorkOrderIds: ' + setEventWorkOrderIds);
            
            Map<Id, SVMXC__Service_Order__c> mapAllEventWorkOrders = new Map<Id, SVMXC__Service_Order__c>();
            mapAllEventWorkOrders.putAll([Select Id, Name, SVMXC__Service_Duration__c, SVMXC__Dispatch_Process__c, SVMXC__Latitude__c, SVMXC__Longitude__c, SVMXC__Locked_By_DC__c, SVMXC__Appointment_Promised_Time_Slot__c,SVMXC__Street__c,SVMXC__City__c,SVMXC__State__c,SVMXC__Zip__c,SVMXC__Country__c
                                            from SVMXC__Service_Order__c
                                            where Id IN: setEventWorkOrderIds]);
            
       
          //Option 2: Handling external work orders into events based on the locked by dc
            //a. create list of forcefix work orders(all wos other then current DP with locked by dc is true).
            //b. create list of rescheduled work orders(current DP wos and locked by dc is false).
            //c. create list of rescheduled work orders if work orders are booked through Book appointment.
            for(Id woId: mapAllEventWorkOrders.keySet())
            {
                SVMXC__Service_Order__c objExternalWorkOrders = mapAllEventWorkOrders.get(woId);
                if((objExternalWorkOrders.SVMXC__Dispatch_Process__c != NULL) && ( objExternalWorkOrders.SVMXC__Dispatch_Process__c == strDispatchProcessId) || objExternalWorkOrders.SVMXC__Appointment_Promised_Time_Slot__c != null) // Work order belongs to current dispatch process
                {
                    if(objExternalWorkOrders.SVMXC__Locked_By_DC__c == true){
                        setWrkOrdsToForceFix.add(woId);
                    }else{
                        setWrkOrdsToReschedule.add(woId);
                    }
                }else{
                    setWrkOrdsToForceFix.add(woId);
                }
            }
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::doBuildResourceEventWrapper(): Forcefix Work Orders: ' + setWrkOrdsToForceFix.size());                
            
            // From Salesforce Events map, build the list of work orders to be rescheduled and events related to them + map of tech's non-Work order events
            String technicianId;
            String territoryId;
            String eventId;
            Datetime evStartTime = null;
            DateTime evEndTime = null;
            Integer driveTime = 0;
            Integer returnDriveTime = 0;
            String relatedElementId = '';

            for(Event e: mapSFEvent.values())
            {
                WSCH_Provider_ECO_Stubs.TechniciansEvent_WP techevent;               
                SVMXC__Service_Group_Members__c technician = mapUsersTechnicians.get(e.OwnerId); 
                technicianId = technician.Id+'_'+technician.Name;
                territoryId = technician.SVMXC__Service_Territory__c;
                eventId = 'Event_'+e.id+'_'+technician.name;
                WSCH_Provider_ECO_Stubs.Location_WP wrpEventLocation;
                String eventAddress = '';
                String strOperationType = 'add';
                Map<String,String> parameters = new Map<String,String>();

                //Convert event start and end dateime into technician TZ.
                DateTime startDatetimeBH = WSCH_DateUtils.doTZConversion(e.StartDateTime, 'GMT', defTerritoryBH.timeZoneSidKey);
                DateTime endDatetimeBH = WSCH_DateUtils.doTZConversion(e.EndDatetime, 'GMT', defTerritoryBH.timeZoneSidKey);        
                integer intDays =  startDatetimeBH.DateGMT().daysBetween(endDatetimeBH.DateGMT());
                if(intDays > 0){
                    continue;    
                }                
               //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::doBuildResourceEventWrapper():technicianId:-  '+technicianId+' ; territoryId:-  '+territoryId+' ; eventID:-  '+eventId);
                
                // forcefix work orders
                if((e.WhatId != NULL && String.valueof(e.WhatId).startsWith(woKeyPrefix) == TRUE ) && ( setWrkOrdsToForceFix.contains(e.WhatId) ))
                {
                    driveTime = Integer.valueOf(e.SVMXC__Driving_Time__c);
                    returnDriveTime = Integer.valueOf(e.SVMXC__Driving_Time_Home__c);
                    evStartTime = e.StartDateTime.addMinutes(driveTime);
                    evEndTime = e.EndDatetime.addMinutes(-returnDriveTime); 
                    //Set the latitude and longitude from work order.
                    SVMXC__Service_Order__c objWorkOrder = mapAllEventWorkOrders.get(e.WhatId);
                    if(objWorkOrder.SVMXC__Latitude__c != null && objWorkOrder.SVMXC__Longitude__c != null){
                        wrpEventLocation = new WSCH_Provider_ECO_Stubs.Location_WP();
                        wrpEventLocation.latitude = objWorkOrder.SVMXC__Latitude__c;
                        wrpEventLocation.longitude = objWorkOrder.SVMXC__Longitude__c;
                    }
                    eventAddress = ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0) ? objWorkOrder.SVMXC__Street__c : '') + ((objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) ?  (((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0)) ? ', ' : '') + objWorkOrder.SVMXC__City__c : '') + ((objWorkOrder.SVMXC__State__c != NULL && objWorkOrder.SVMXC__State__c.length() > 0) ?  (((objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) || ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objWorkOrder.SVMXC__State__c : '') + ((objWorkOrder.SVMXC__Zip__c != NULL && objWorkOrder.SVMXC__Zip__c.length() > 0) ?  (((objWorkOrder.SVMXC__State__c != NULL && objWorkOrder.SVMXC__State__c.length() > 0) || (objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) || ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objWorkOrder.SVMXC__Zip__c : '') + ((objWorkOrder.SVMXC__Country__c != NULL && objWorkOrder.SVMXC__Country__c.length() > 0) ?  (((objWorkOrder.SVMXC__Zip__c != NULL && objWorkOrder.SVMXC__Zip__c.length() > 0) || (objWorkOrder.SVMXC__State__c != NULL && objWorkOrder.SVMXC__State__c.length() > 0) || (objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) || ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objWorkOrder.SVMXC__Country__c : '');
                    //Multi-resource and Multi-appointment
                    //If the event is workorder order event then pass the workorder id and isForceFix value to the server in the technician event wrapper(TechniciansEvent_WP)
                    //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::doBuildResourceEventWrapper() SF e.WhatId: '+e.WhatId+' , mapAllEventWorkOrders.get(e.WhatId): '+mapAllEventWorkOrders.get(e.WhatId)+' , mapAllEventWorkOrders: '+mapAllEventWorkOrders);
                    if(e.WhatId != NULL){
                        SVMXC__Service_Order__c woObj = mapAllEventWorkOrders.get(e.WhatId);
                        if(woObj != null){
                            parameters.put('relatedElementId', woObj.Name);
                            strOperationType = 'ecoReplaceWithEvent';
                        }
                    }
                //techevent = new WSCH_Provider_ECO_Stubs.TechniciansEvent_WP(territoryId,technicianId,eventId,evStartTime,evEndTime,0,0,1,'add', wrpEventLocation, eventAddress); 
                techevent = new WSCH_Provider_ECO_Stubs.TechniciansEvent_WP(territoryId,technicianId,eventId,evStartTime,evEndTime,0,0,1,strOperationType, wrpEventLocation, eventAddress, parameters); 
                lstTechEvent.add(techevent);
                }
                else if((e.WhatId != NULL && String.valueof(e.WhatId).startsWith(woKeyPrefix) == TRUE ) && ( setWrkOrdsToReschedule.contains(e.WhatId) ))
                {
                    //TODO: What to do this event because this work order event
                }
                // Non-Work order events
                else
                {
                    driveTime = Integer.valueOf(e.SVMXC__Driving_Time__c);
                    returnDriveTime = Integer.valueOf(e.SVMXC__Driving_Time_Home__c);
                    evStartTime = e.StartDateTime.addMinutes(driveTime);
                    evEndTime = e.EndDatetime.addMinutes(-returnDriveTime); 
                    if(e.SVMXC__SM_Latitude__c != null && e.SVMXC__SM_Longitude__c != null){
                        wrpEventLocation = new WSCH_Provider_ECO_Stubs.Location_WP();
                        wrpEventLocation.latitude = e.SVMXC__SM_Latitude__c;
                        wrpEventLocation.longitude = e.SVMXC__SM_Longitude__c;
                    }
                    if(e.Location != null){
                        eventAddress = e.Location;
                    }
                //techevent = new WSCH_Provider_ECO_Stubs.TechniciansEvent_WP(territoryId,technicianId,eventId,evStartTime,evEndTime,0,0,1,'add', wrpEventLocation, eventAddress); 
                techevent = new WSCH_Provider_ECO_Stubs.TechniciansEvent_WP(territoryId,technicianId,eventId,evStartTime,evEndTime,0,0,1,strOperationType, wrpEventLocation, eventAddress, parameters); 
                lstTechEvent.add(techevent);
                }
            }
            mapSFEvent.clear();
            //mapUsersTechnicians.clear();
            //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::doBuildTechnicianTimeWindows(): Non WorkOrders : -'+mapEventNonWO.size());                

            // From ServiceMax Events map, build the list of work orders to be rescheduled and events related to them + map of tech's non-Work order events
            for(SVMXC__SVMX_Event__c e: mapSVMXEvent.values())
            {
                WSCH_Provider_ECO_Stubs.TechniciansEvent_WP techevent;
                SVMXC__Service_Group_Members__c technician = mapIdTechnicians.get(e.SVMXC__Technician__c); 
                technicianId = technician.Id+'_'+technician.Name;
                territoryId = technician.SVMXC__Service_Territory__c;
                eventId = 'Event_'+e.id+'_'+technician.name;
                WSCH_Provider_ECO_Stubs.Location_WP wrpEventLocation;
                String eventAddress = '';
                Map<String, String> parameters = new Map<String, String>();
                String strOperationType = 'add';


                //Convert event start and end dateime into technician TZ.
                DateTime startDatetimeBH = WSCH_DateUtils.doTZConversion(e.SVMXC__StartDateTime__c, 'GMT', defTerritoryBH.timeZoneSidKey);
                DateTime endDatetimeBH = WSCH_DateUtils.doTZConversion(e.SVMXC__EndDateTime__c, 'GMT', defTerritoryBH.timeZoneSidKey);        
                integer intDays =  startDatetimeBH.DateGMT().daysBetween(endDatetimeBH.DateGMT());
                if(intDays > 0){
                    continue;    
                }
               //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::doBuildResourceEventWrapper():Process SVMX Event....technicianId:-  '+technicianId+' ; territoryId:-  '+territoryId+' ; eventID:-  '+eventId);
                
                // forcefix work orders
                if(( e.SVMXC__WhatId__c != NULL ) && ( String.valueof(e.SVMXC__WhatId__c).startsWith(woKeyPrefix) == TRUE ) && ( setWrkOrdsToForceFix.contains(e.SVMXC__WhatId__c) ) ) {
                    driveTime = Integer.valueOf(e.SVMXC__Driving_Time__c);
                    returnDriveTime = Integer.valueOf(e.SVMXC__Driving_Time_Home__c);
                    evStartTime = e.SVMXC__StartDateTime__c.addMinutes(driveTime);
                    evEndTime = e.SVMXC__EndDateTime__c.addMinutes(-returnDriveTime); 
                    //Set the latitude and longitude from work order.
                    SVMXC__Service_Order__c objWorkOrder = mapAllEventWorkOrders.get(e.SVMXC__WhatId__c);
                    if(objWorkOrder.SVMXC__Latitude__c != null && objWorkOrder.SVMXC__Longitude__c != null){
                        wrpEventLocation = new WSCH_Provider_ECO_Stubs.Location_WP();
                        wrpEventLocation.latitude = objWorkOrder.SVMXC__Latitude__c;
                        wrpEventLocation.longitude = objWorkOrder.SVMXC__Longitude__c;
                    }
                    eventAddress = ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0) ? objWorkOrder.SVMXC__Street__c : '') + ((objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) ?  (((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0)) ? ', ' : '') + objWorkOrder.SVMXC__City__c : '') + ((objWorkOrder.SVMXC__State__c != NULL && objWorkOrder.SVMXC__State__c.length() > 0) ?  (((objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) || ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objWorkOrder.SVMXC__State__c : '') + ((objWorkOrder.SVMXC__Zip__c != NULL && objWorkOrder.SVMXC__Zip__c.length() > 0) ?  (((objWorkOrder.SVMXC__State__c != NULL && objWorkOrder.SVMXC__State__c.length() > 0) || (objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) || ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objWorkOrder.SVMXC__Zip__c : '') + ((objWorkOrder.SVMXC__Country__c != NULL && objWorkOrder.SVMXC__Country__c.length() > 0) ?  (((objWorkOrder.SVMXC__Zip__c != NULL && objWorkOrder.SVMXC__Zip__c.length() > 0) || (objWorkOrder.SVMXC__State__c != NULL && objWorkOrder.SVMXC__State__c.length() > 0) || (objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) || ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objWorkOrder.SVMXC__Country__c : '');
                    //Multi-resource and Multi-appointment
                    //If the event is workorder order event then pass the workorder id and isForceFix value to the server in the technician event wrapper(TechniciansEvent_WP)
                    //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::doBuildResourceEventWrapper() SVMX e.SVMXC__WhatId__c: '+e.SVMXC__WhatId__c+' , mapAllEventWorkOrders.get(e.SVMXC__WhatId__c): '+mapAllEventWorkOrders.get(e.SVMXC__WhatId__c)+' , mapAllEventWorkOrders: '+mapAllEventWorkOrders);
                    if(e.SVMXC__WhatId__c != NULL){
                        SVMXC__Service_Order__c woObj = mapAllEventWorkOrders.get(e.SVMXC__WhatId__c);
                        if(woObj != null){
                            parameters.put('relatedElementId', woObj.Name);
                            strOperationType = 'ecoReplaceWithEvent';
                        }
                    }
                    //techevent = new WSCH_Provider_ECO_Stubs.TechniciansEvent_WP(territoryId,technicianId,eventId,evStartTime,evEndTime,0,0,1,'add', wrpEventLocation, eventAddress); 
                    techevent = new WSCH_Provider_ECO_Stubs.TechniciansEvent_WP(territoryId,technicianId,eventId,evStartTime,evEndTime,0,0,1,strOperationType, wrpEventLocation, eventAddress, parameters);
                    lstTechEvent.add(techevent);
                }
                else if(( e.SVMXC__WhatId__c != NULL ) && ( String.valueof(e.SVMXC__WhatId__c).startsWith(woKeyPrefix) == TRUE ) && (setWrkOrdsToReschedule.contains(e.SVMXC__WhatId__c) ) )
                {

                }
                // Non-Work order events 
                //else if(e.SVMXC__WhatId__c == NULL)
                else
                {
                    driveTime = Integer.valueOf(e.SVMXC__Driving_Time__c);
                    returnDriveTime = Integer.valueOf(e.SVMXC__Driving_Time_Home__c);
                    evStartTime = e.SVMXC__StartDateTime__c.addMinutes(driveTime);
                    evEndTime = e.SVMXC__EndDateTime__c.addMinutes(-returnDriveTime); 
                    if(e.SVMXC__SM_Latitude__c != null && e.SVMXC__SM_Longitude__c != null){
                        wrpEventLocation = new WSCH_Provider_ECO_Stubs.Location_WP();
                        wrpEventLocation.latitude = e.SVMXC__SM_Latitude__c;
                        wrpEventLocation.longitude = e.SVMXC__SM_Longitude__c;
                    }
                    if(e.SVMXC__Location__c!= null){
                        eventAddress = e.SVMXC__Location__c;
                    }
                    //techevent = new WSCH_Provider_ECO_Stubs.TechniciansEvent_WP(territoryId,technicianId,eventId,evStartTime,evEndTime,0,0,1,'add', wrpEventLocation, eventAddress); 
                    techevent = new WSCH_Provider_ECO_Stubs.TechniciansEvent_WP(territoryId,technicianId,eventId,evStartTime,evEndTime,0,0,1,strOperationType, wrpEventLocation, eventAddress, parameters);
                    lstTechEvent.add(techevent);
                }
            }           
            mapSVMXEvent.clear();
            mapUsersTechnicians.clear();
        }
        catch(Exception ex)
        {
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::doBuildResourceEventWrapper()(): Failed with the exception: ' + ex.getMessage());
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::doBuildResourceEventWrapper() Ends');
            //WSCH_AuditLogger.finish();
        }
        return lstTechEvent;
    }
    
   // First level wrapper to get actual available time window for a tech for a given date
    // Input: List of working time windows & list of event windows for the tech for that date
    public static list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> updateExecutionTime(list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstExecutionTime_WP, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstEvent)
    {
        list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> templstExecutionTime_WP = new list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
        list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstRetExecTimeWP = new list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
        
        lstEvent = sortExecutionTime(lstEvent);
        for(WSCH_Provider_ECO_Stubs.ExecutionTime_WP tempoExecutionTime_WP : lstExecutionTime_WP)
        {
            for(WSCH_Provider_ECO_Stubs.ExecutionTime_WP oEvent : lstEvent)
            {
                // If there is available time window list, send the last available time window from the list to updateExecutionTime (from the second iteration of the for loop)
                if(templstExecutionTime_WP.size() > 0)
                    templstExecutionTime_WP = updateExecutionTime(templstExecutionTime_WP.get(templstExecutionTime_WP.size()-1), oEvent.workingHoursBegin, oEvent.workingHoursEnd);
                // For the first iteration of the loop, send the given date�s working time window to updateExecutionTime
                else
                    templstExecutionTime_WP = updateExecutionTime(tempoExecutionTime_WP, oEvent.workingHoursBegin, oEvent.workingHoursEnd);
                
                //WSCH_AuditLogger.debug('SMAX_OptiMax_Engine_Ext::updateExecutionTime():templstExecutionTime_WP : ' + templstExecutionTime_WP);
                // If there are no available time windows returned by the last invocation of updateExecutionTime
                if(templstExecutionTime_WP.size() == 0) break;
                // If two available time windows are returned, add the first window to the final list of available time windows to be returned
                if(templstExecutionTime_WP.size() == 2)
                    lstRetExecTimeWP.add(templstExecutionTime_WP.get(0));
            }
            //strLoggerString += system.now() + ': Updated avail window list: ' + lstRetExecTimeWP + '\n';
        }
        if(templstExecutionTime_WP.size() > 0)
            lstRetExecTimeWP.add(templstExecutionTime_WP.get(templstExecutionTime_WP.size() - 1));
        //strLoggerString += system.now() + ': Updated avail window list: ' + lstRetExecTimeWP + '\n';
    
        return lstRetExecTimeWP;
    }
    
    // Second level wrapper to get actual available time windows for a tech for a given date    
    // Input: Single working tindow, and start date time & end date time for a single event
    public static list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> updateExecutionTime(WSCH_Provider_ECO_Stubs.ExecutionTime_WP oExecutionTime_WP, datetime StartTime, datetime EndTime)
    {
        list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> templstExecutionTime_WP = new list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
        
        // If the event covers a part (beginning, middle, end, or full part) of the given working time window, get the actual available time windows
        // E.g. working window - 8 - 12: event start should be <= 12; event end >= 8
        // Sample qualifying events: 7-8, 7-11, 7-12, 7-1, 8-11, 8-12, 8-1, 9-11, 9-12, 9-1, 12-1
        if(oExecutionTime_WP.workingHoursBegin <= EndTime && oExecutionTime_WP.workingHoursEnd >= startTime)
        {
            // If working window starts at or before event start = event start: >= 8
            // Sample qualifying events: 8-11, 8-12, 8-1, 9-11, 9-12, 9-1, 12-1
            if((oExecutionTime_WP.workingHoursBegin <= startTime))
            {
                // If working window ends at or after event end = event end <= 12
                // Sample qualifying events: 8-11, 8-12, 9-11, 9-12
                if(oExecutionTime_WP.workingHoursEnd >= EndTime)
                {
                    // If event starts after working time window start = event start != 8
                    // Output time windows: 9-11 event: 8-9; 9-12 event: 8-9
                    if(oExecutionTime_WP.workingHoursBegin != startTime)
                    {
                        templstExecutionTime_WP.add(new WSCH_Provider_ECO_Stubs.ExecutionTime_WP(oExecutionTime_WP.workingHoursBegin, startTime));
                    }
                    // 8-11 event: Nothing; 8-12 event: Nothing
                    
                    // If event ends before working time window end = event end != 12
                    // Output time windows: 8-11 event: 11-12; 9-11 event: 11-12
                    if(endTime != oExecutionTime_WP.workingHoursEnd)
                    {
                        templstExecutionTime_WP.add(new WSCH_Provider_ECO_Stubs.ExecutionTime_WP(endTime, oExecutionTime_WP.workingHoursEnd));
                    }
                    // 8-12 event: Nothing; 9-12 event: Nothing
                }
                // Working window ends before event end; but as event started at or after working window start, set working window end = event start
                // Sample qualifying events: 8-1, 9-1, 12-1
                // Output time windows: 8-1 event: Nothing; 9-1 event: 8-9; 12-1 event: 8-12
                else
                {
                    oExecutionTime_WP.workingHoursEnd = StartTime;
                    // If working window starts after event start, add the beginning part of working window
                    if(oExecutionTime_WP.workingHoursBegin != oExecutionTime_WP.workingHoursEnd)
                        templstExecutionTime_WP.add(oExecutionTime_WP);
                }
            }
            // If the working window starts after event start = event start < 8
            // Sample qualifying events: 7-8, 7-11, 7-12, 7-1
            else
            {
                // If the working window ends at or after event end; set working window start = event end
                // Output time windows: 7-8 event: 8-12; 7-11 event: 11-12; 7-12 event: Nothing
                if(oExecutionTime_WP.workingHoursEnd >= EndTime)
                {
                    oExecutionTime_WP.workingHoursBegin = endTime;
                    // if the working window ends after the event end, add the ending part of working window
                    if(oExecutionTime_WP.workingHoursBegin != oExecutionTime_WP.workingHoursEnd)
                        templstExecutionTime_WP.add(oExecutionTime_WP);
                }
                // 7-1 event: Nothing
            }
        }
        // If the event does not cover any part of the working window, take the working window as is
        // TRUE if event (starts AND ends) (before working window start OR after working window end)
        // Sample events: 6-7, 1-2
        else
            templstExecutionTime_WP.add(oExecutionTime_WP);
        
        return templstExecutionTime_WP;
    }
            
    public static Map<Id, Event> getMapSFEventforTech(set<string> lstOwnerID,DateTime inputStartTime, DateTime inputEndTime)
    {
        //Following Scenarios are considered for checking Double booking
        // events that "end" during the input event's start and end time, 
        // events that "start" during the input event's start and end time
        // events that "start" before input event's start time and "end" after input event's end time
        // events that "start" within the input event's start and end time including fully overlapped events
          
        date inputStartdate = inputStartTime.dateGMT();
        date inputEndtdate = inputEndTime.dateGMT();
        datetime inputStartdatetime = Datetime.newInstanceGmt(inputStartTime.dateGMT(),Time.newInstance(0, 0, 0, 0));

        Map<Id, Event> tempEvents = new Map<Id, Event>([Select Id, WhatId, Subject, Description, ActivityDateTime, OwnerId, EndDateTime, DurationInMinutes,IsAllDayEvent,ActivityDate,StartDatetime, Location,SVMXC__Driving_Time__c, SVMXC__Driving_Time_Home__c, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c from Event where (OwnerId in:lstOwnerID) AND (StartDateTime <= :inputEndTime and EndDateTime >= :inputStartTime) AND (IsAllDayEvent = false)]);
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
        
        date inputStartdate = inputStartTime.dateGMT();
        date inputEnddate = inputEndTime.dateGMT();
        datetime inputStartdatetime = Datetime.newInstanceGmt(inputStartTime.dateGMT(),Time.newInstance(0, 0, 0, 0));
                
        Map<Id, SVMXC__SVMX_Event__c> tempEvents = new Map<Id, SVMXC__SVMX_Event__c>([Select Id, Name, SVMXC__Location__c, SVMXC__Description__c, SVMXC__DurationInMinutes__c, SVMXC__WhatId__c,SVMXC__Technician__c, SVMXC__ActivityDate__c,SVMXC__ActivityDateTime__c,SVMXC__EndDateTime__c,SVMXC__StartDateTime__c,SVMXC__IsAllDayEvent__c, SVMXC__Driving_Time__c, SVMXC__Driving_Time_Home__c, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c from SVMXC__SVMX_Event__c where (SVMXC__Technician__c in:lstOwnerID) AND (SVMXC__StartDateTime__c <= :inputEndTime and SVMXC__EndDateTime__c >= :inputStartTime) AND (SVMXC__IsAllDayEvent__c = false)]);        
        return tempEvents;
    }
        
    
    public static List<BusinessHours> getCompleteBusinessHour(List<BusinessHours> lstBusinessHours)
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
        
    public static Datetime getNextWorkingHour(BusinessHours objBusinessHour, Datetime dtmGivenDateTime)
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
        
    // Sort ExecutionTime_WP list by startDateTime
    public static List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> sortExecutionTime(List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstInputTimeWindows)
    {
        List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstOutputTimeWindows = new List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
        List<DateTime> lstStartDateTime = new List<DateTime>();
        Map<DateTime, Integer> mapStartDateTimeIndex = new Map<DateTime, Integer>();
        Integer intListIndex = 0;
        for(WSCH_Provider_ECO_Stubs.ExecutionTime_WP timeWindow: lstInputTimeWindows)
        {
            mapStartDateTimeIndex.put(timeWindow.workingHoursBegin, intListIndex);
            intListIndex++;
        }
        lstStartDateTime.addall(mapStartDateTimeIndex.keyset());
        lstStartDateTime.sort();
        for(DateTime startDt: lstStartDateTime)
            lstOutputTimeWindows.add(lstInputTimeWindows.get(mapStartDateTimeIndex.get(startDt)));
        return lstOutputTimeWindows;
    }

    // Get the latitude and longitude of the given Tech at the given Date Time
    public static WSCH_Provider_ECO_Stubs.Location_WP getLocation_WP(Id strTechId, datetime dtmTechStartDateTime, datetime dtmTodaysStart, Decimal techLatitude, Decimal techLongitude)
    {
        
        Map<datetime, WSCH_Provider_ECO_Stubs.Location_WP> eventLatLng = new Map<datetime, WSCH_Provider_ECO_Stubs.Location_WP>();
        List<datetime> techEventTime = new List<datetime>();
        WSCH_Provider_ECO_Stubs.Location_WP wrpTechLastLatLong = new WSCH_Provider_ECO_Stubs.Location_WP();
        wrpTechLastLatLong.latitude = techLatitude;
        wrpTechLastLatLong.longitude =techLongitude;
        eventLatLng = mapTechLatitudeLongitude.get(strTechId);
        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getLocation_WP: eventLatLng'+eventLatLng);
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
    
    public static list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> removeOngoingActivityFromAvailability(Id techId, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> execTimeWindow, Integer leadTime){
        list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> response = new list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
        // If technician is currently working, than remove the technician availability
        if(mapTechniciansOngoingActivity.containsKey(techId))
        {
            WSCH_Provider_ECO_Stubs.ExecutionTime_WP techCurrentExecTime = mapTechniciansOngoingActivity.get(techId);
            techCurrentExecTime.workingHoursEnd = techCurrentExecTime.workingHoursEnd.addminutes(leadTime);
            for(WSCH_Provider_ECO_Stubs.ExecutionTime_WP availTime : execTimeWindow)
            {
                if(techCurrentExecTime.workingHoursBegin <= availTime.workingHoursBegin)
                {
                    if(availTime.workingHoursEnd >= techCurrentExecTime.workingHoursEnd)
                        response.add(new WSCH_Provider_ECO_Stubs.ExecutionTime_WP(techCurrentExecTime.workingHoursEnd, availTime.workingHoursEnd));
                }
                else
                    response.add(new WSCH_Provider_ECO_Stubs.ExecutionTime_WP(availTime.workingHoursBegin, availTime.workingHoursEnd));
            }
        }
        else
        {
            for(WSCH_Provider_ECO_Stubs.ExecutionTime_WP availTime : execTimeWindow)
            {
                response.add(new WSCH_Provider_ECO_Stubs.ExecutionTime_WP(availTime.workingHoursBegin, availTime.workingHoursEnd));
            }
        }
            
        return response;
    }
        
    public static List<WSCH_Provider_ECO_Stubs.ExcSetting_WP> getParameters(SVMXC__Territory__c objTerritory){
        List<WSCH_Provider_ECO_Stubs.ExcSetting_WP> lstExcSetting_WP = new List<WSCH_Provider_ECO_Stubs.ExcSetting_WP>();
        // String tempValue = WSCH_CommonUtils.getSettingValue('DCON001','SET071');
        String tempValue = String.valueof(mapSettingValues.get('DCON001_SET071'));
        lstExcSetting_WP.add(setOrganizationParameters('Optimax.Geocoding', tempValue));
        if(mapSettingValues.containsKey('OMAX001_SET011') == TRUE && mapSettingValues.containsKey('OMAX001_SET012') == TRUE)
        {   // Optimax.debug && Optimax.debugMail
            lstExcSetting_WP.add(setOrganizationParameters('Optimax.debug', String.valueof(mapSettingValues.get('OMAX001_SET011')) ));
            lstExcSetting_WP.add(setOrganizationParameters('Optimax.debugMail', String.valueof(mapSettingValues.get('OMAX001_SET012')) ));
        }
        if(mapSettingValues.containsKey('OMAX001_SET001') == TRUE)
        {   // JOpt.Assisted
            lstExcSetting_WP.add(setOrganizationParameters('JOpt.Assisted', String.valueof(mapSettingValues.get('OMAX001_SET001')) ));
        }
        /*if(mapSettingValues.containsKey('OMAX001_SET002') == TRUE)
        {   // JOpt.AssistedMode
            lstExcSetting_WP.add(setOrganizationParameters('JOpt.AssistedMode', String.valueof(mapSettingValues.get('OMAX001_SET002')) ));
        }
        if(mapSettingValues.containsKey('OMAX001_SET003') == TRUE)
        {   // JOpt.OptimizationRule
            lstExcSetting_WP.add(setOrganizationParameters('JOpt.OptimizationRule', String.valueof(mapSettingValues.get('OMAX001_SET003')) ));
        }
        if(mapSettingValues.containsKey('OMAX001_SET004') == TRUE)
        {   // JOptExitCondition.Type
            String value = String.valueof(mapSettingValues.get('OMAX001_SET004'));
            value = value.replace('OptiMax', 'JOpt');
            lstExcSetting_WP.add(setOrganizationParameters('JOptExitCondition.Type', value ));
        }
        if(mapSettingValues.containsKey('OMAX001_SET005') == TRUE)
        {   // JOptExitCondition.Count
            lstExcSetting_WP.add(setOrganizationParameters('JOptExitCondition.Count', String.valueof(mapSettingValues.get('OMAX001_SET005')) ));
        }
        if(mapSettingValues.containsKey('OMAX001_SET006') == TRUE)
        {   // JOptExitCondition.JOptGenerationCount
            lstExcSetting_WP.add(setOrganizationParameters('JOptExitCondition.JOptConvergencyCount', String.valueof(mapSettingValues.get('OMAX001_SET006')) ));
        }*/
        if(mapSettingValues.containsKey('OMAX001_SET007') == TRUE)
        {   // JOptExitCondition.JOptGenerationCount
            lstExcSetting_WP.add(setOrganizationParameters('JOptExitCondition.JOptGenerationCount', String.valueof(mapSettingValues.get('OMAX001_SET007')) ));
        }
        /*if(mapSettingValues.containsKey('OMAX001_SET008') == TRUE)
        {   // JOptWeight.Capacity
            lstExcSetting_WP.add(setOrganizationParameters('JOptWeight.Capacity', String.valueof(mapSettingValues.get('OMAX001_SET008')) ));
        }
        if(mapSettingValues.containsKey('OMAX001_SET009') == TRUE)
        {   // JOptWeight.ResourceLoadBalance
            lstExcSetting_WP.add(setOrganizationParameters('JOptWeight.ResourceLoadBalance', String.valueof(mapSettingValues.get('OMAX001_SET009')) ));
        }
        if(mapSettingValues.containsKey('OMAX001_SET013') == TRUE)
        {   // Optimax.CompactingFactor
            lstExcSetting_WP.add(setOrganizationParameters('JOptWeight.CompactingFactor', String.valueof(mapSettingValues.get('OMAX001_SET013')) ));
        }*/
        if(objSVMXProcess.SVMXC__Route_Type__c != NULL)
        {   // JOpt.RouteType
            lstExcSetting_WP.add(setOrganizationParameters('JOpt.RouteType', objSVMXProcess.SVMXC__Route_Type__c ));
        }
        if(objSVMXProcess.SVMXC__Weight_Time_Window__c != NULL)
        {   // JOptWeight.TimeWindow
             lstExcSetting_WP.add(setOrganizationParameters('JOptWeight.TimeWindow', String.valueof(objSVMXProcess.SVMXC__Weight_Time_Window__c * Integer.valueOf(mapSettingValues.get('OMAX003_SET040')))));
        }
        if(objSVMXProcess.SVMXC__Weight_Total_Distance__c != NULL)
        {   // JOptWeight.TotalDistance
            lstExcSetting_WP.add(setOrganizationParameters('JOptWeight.TotalDistance', String.valueof(objSVMXProcess.SVMXC__Weight_Total_Distance__c * Integer.valueOf(mapSettingValues.get('OMAX003_SET041')))));
        }
        if(objSVMXProcess.SVMXC__Weight_Route_Distance__c != NULL)
        {   // JOptWeight.RouteDistance
            lstExcSetting_WP.add(setOrganizationParameters('JOptWeight.RouteDistance', String.valueof(objSVMXProcess.SVMXC__Weight_Route_Distance__c * Integer.valueOf(mapSettingValues.get('OMAX003_SET038')))));
        }
        if(objSVMXProcess.SVMXC__Weight_Route_Time__c != NULL)
        {   // JOptWeight.RouteTime
            lstExcSetting_WP.add(setOrganizationParameters('JOptWeight.RouteTime', String.valueof(objSVMXProcess.SVMXC__Weight_Route_Time__c * Integer.valueOf(mapSettingValues.get('OMAX003_SET039')))));
        }
        if(objSVMXProcess.SVMXC__Weight_Node_Type__c != NULL)
        {   // JOptWeight.NodeType
             lstExcSetting_WP.add(setOrganizationParameters('JOptWeight.PreferableResource', String.valueof(objSVMXProcess.SVMXC__Weight_Node_Type__c * Integer.valueOf(mapSettingValues.get('OMAX003_SET037')))));
        }
        if(objSVMXProcess.SVMXC__Weight_Total_Distance__c != NULL)
        {
            lstExcSetting_WP.add(setOrganizationParameters('distanceWeightage', String.valueof(objSVMXProcess.SVMXC__Weight_Total_Distance__c)));
        }
        if(objSVMXProcess.SVMXC__Weight_Node_Type__c != NULL)
        {
             lstExcSetting_WP.add(setOrganizationParameters('MCTMWeightage', String.valueof(objSVMXProcess.SVMXC__Weight_Node_Type__c)));
        }
        if(mapSettingValues.containsKey('OMAX001_SET017') == TRUE)
        {
            lstExcSetting_WP.add(setOrganizationParameters('distanceProvider', String.valueof(mapSettingValues.get('OMAX001_SET017')) ));
        }
        if(objTerritory.SVMXC__Mode_Of_Travel__c != NULL)
        {
            lstExcSetting_WP.add(setOrganizationParameters('modeOfTravel', String.valueOf(objTerritory.SVMXC__Mode_Of_Travel__c) ));
        }
        else
        {
            lstExcSetting_WP.add(setOrganizationParameters('modeOfTravel', 'Driving' ));
        }
        
        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getParameters():properties for the job is..'+lstExcSetting_WP);
        return lstExcSetting_WP;
    }
    
    public static Map<String, Map<Date, WSCH_Provider_ECO_Stubs.ExecutionTime_WP>> generateBusinessHourDetails(List<BusinessHours> bh_L, Datetime startDateTime, Datetime endDateTime, set<Date> availableDates_S){
        Map<String, Map<Date, WSCH_Provider_ECO_Stubs.ExecutionTime_WP>> mapBusinessHourDetails = new Map<String, Map<Date, WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>();
        for(BusinessHours bh: bh_L)
        {
            if(bh ==null ){
                continue;
            }
            Map<Date, WSCH_Provider_ECO_Stubs.ExecutionTime_WP> dateTime_M = new Map<Date, WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::generateBusinessHourDetails(): Getting time windows for Business Hours: ' + bh.Id);
            for(Date date_T: availableDates_S)
            {
                if(isWorkingDay(bh, date_T))
                {
                    //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::generateBusinessHourDetails(): working day details...: ' + date_T);
                    WSCH_Provider_ECO_Stubs.ExecutionTime_WP exeTime = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP();
                    Time startTime_T = getStartEndTime(bh, datetime.newInstanceGmt(date_T, Time.newInstance(0, 0, 0, 0)).formatGmt('EEEE'), 'StartTime');
                    Time endTime_T = getStartEndTime(bh, datetime.newInstanceGmt(date_T, Time.newInstance(0, 0, 0, 0)).formatGmt('EEEE'), 'EndTime');
                    //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::generateBusinessHourDetails(): startTime_T...: ' + startTime_T);
                    //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::generateBusinessHourDetails(): endTime_T...: ' + endTime_T);
                    if(startTime_T == endTime_T)
                    {   // 24 hours Business Day
                        endTime_T = Time.newInstance(23, 59, 59, 999);
                    }

                    exeTime.workingHoursBegin = dcUtils.getDateTimeInTimezone(date_T, startTime_T, bh.timeZoneSidKey);
                    if(startDateTime != NULL && exeTime.workingHoursBegin < startDateTime)
                    {
                        exeTime.workingHoursBegin = startDateTime;
                    }

                    exeTime.workingHoursEnd = dcUtils.getDateTimeInTimezone(date_T, endTime_T, bh.timeZoneSidKey);
                    if(endDateTime != NULL && exeTime.workingHoursEnd > endDateTime)
                    {
                        exeTime.workingHoursEnd = endDateTime;
                    }                    
                    dateTime_M.put(date_T, exeTime);
                    //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::generateBusinessHourDetails(): exeTime.workingHoursBegin: ' + exeTime.workingHoursBegin);
                    //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::generateBusinessHourDetails(): exeTime.workingHoursEnd: ' + exeTime.workingHoursEnd);
                }
            }
            mapBusinessHourDetails.put(String.valueof(bh.Id), dateTime_M);
        }
        return mapBusinessHourDetails;
    }
        
    // Return TRUE if the given date is a working day in the given Business Hours. Else return FALSE
    public static boolean isWorkingDay(BusinessHours objBusinessHour, Date datRequestedDate)
    {
        // Get the start time of the given date (i.e. start of the day in the given time zone)
        Datetime dtmDayStartDateTime = dcUtils.getDateTimeInTimezone(datRequestedDate, Time.newInstance(0, 0, 0, 0), objBusinessHour.timeZoneSidKey);
        
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
        
    public static String getOperationType(SVMXC__Service_Order__c workOrder){
        String operationType=null;
        if(WSCH_ECO_Constants.BOOKJOB_SCHDL_CHANGE_TOKENS.contains(workOrder.SVMXC__Scheduling_Change_Token__c)) {
            operationType='add';
        }else if (WSCH_ECO_Constants.UPDATEJOB_SCHDL_CHANGE_TOKENS.contains(workOrder.SVMXC__Scheduling_Change_Token__c) || WSCH_Eco_Constants.FORCEFIXJOB_SCHDL_CHANGE_TOKENS.contains(workOrder.SVMXC__Scheduling_Change_Token__c) || WSCH_Eco_Constants.SCHEDULEFIX_SCHDL_CHANGE_TOKENS.contains(workOrder.SVMXC__Scheduling_Change_Token__c)) {
            operationType='update';
        }else if ('CHANGE_CANCEL_WO'.equalsIgnoreCase(workOrder.SVMXC__Scheduling_Change_Token__c) ) {
            operationType='remove';
        }else if ('CHANGE_COMPLETED_STATUS'.equalsIgnoreCase(workOrder.SVMXC__Scheduling_Change_Token__c)) {
            operationType='remove';
        }else if('CHANGE_JOB_UNFIXED'.equalsIgnoreCase(workOrder.SVMXC__Scheduling_Change_Token__c)){
            operationType='ecoReplaceWithWorkorder';
        }

        //added the below logic to determine the operation type for dependency WOs
        if(workOrder.SVMXC__Dependency_Group__c != null) {
            if(workOrder.SVMXC__Dispatch_Status__c.equalsIgnoreCase('NEW')) {
                operationType='add';
            } else if(workOrder.SVMXC__Dispatch_Status__c.equalsIgnoreCase('ASSIGNED')) {
                operationType='update';
            }
        }
        return operationType;
    }
    
    public static String getOperationType(SVMXC__SVMX_Optimizer__c optimizer){
        String operationType=null;
        if(WSCH_ECO_Constants.ADDTECH_CHANGE_TOKENS.contains(optimizer.SVMXC__Optimizer_Change_Token__c)) {
            operationType='add';
        }else if (WSCH_ECO_Constants.UPDATETECH_CHANGE_TOKENS.contains(optimizer.SVMXC__Optimizer_Change_Token__c)) {
            if('CHANGE_TECH_ZIP'.equalsIgnoreCase(optimizer.SVMXC__Optimizer_Change_Token__c)){
                operationType='updateZip';
            }else{
                operationType='update';
            }
        }else if (WSCH_ECO_Constants.REMOVETECH_CHANGE_TOKENS.contains(optimizer.SVMXC__Optimizer_Change_Token__c)) {
            operationType='remove';
        }
        return operationType;
    }
        
    public static void setDefaultParameter(SVMXC__Territory__c objTerritory){
        if(mapSettingValues.containsKey('GLOB001_GBL006') && mapSettingValues.get('GLOB001_GBL006').toUpperCase() == 'MILE'){
            isMile = true;
            if(objTerritory.SVMXC__Per_Mile_Cost__c != NULL)
                dclDefaultPerKmCost = objTerritory.SVMXC__Per_Mile_Cost__c * (0.621371192);
            else
                dclDefaultPerKmCost = Decimal.valueOf(mapSettingValues.get('OMAX002_SET006')) * (0.621371192);
            if(objTerritory.SVMXC__Max_Distance__c != NULL)
                dclDefaultMaxDistance = objTerritory.SVMXC__Max_Distance__c * (1.609344);
            else
                dclDefaultMaxDistance = Decimal.valueOf(mapSettingValues.get('OMAX002_SET009')) * (1.609344);
            if(objTerritory.SVMXC__Average_Speed__c != NULL)
                dclDefaultAverageSpeed = objTerritory.SVMXC__Average_Speed__c * (0.44704);
            else
                dclDefaultAverageSpeed = Decimal.valueOf(mapSettingValues.get('OMAX002_SET008')) * (0.44704);
        } else {
            if(objTerritory.SVMXC__Per_Mile_Cost__c != NULL)
                dclDefaultPerKmCost = objTerritory.SVMXC__Per_Mile_Cost__c;
            else
                dclDefaultPerKmCost = Decimal.valueOf(mapSettingValues.get('OMAX002_SET006'));
            if(objTerritory.SVMXC__Max_Distance__c != NULL)
                dclDefaultMaxDistance = objTerritory.SVMXC__Max_Distance__c;
            else
                dclDefaultMaxDistance = Decimal.valueOf(mapSettingValues.get('OMAX002_SET009'));
            if(objTerritory.SVMXC__Average_Speed__c != NULL)
                dclDefaultAverageSpeed = objTerritory.SVMXC__Average_Speed__c * (0.27778);
            else
                dclDefaultAverageSpeed = Decimal.valueOf(mapSettingValues.get('OMAX002_SET008')) * (0.27778);
        }
        
        if(objTerritory.SVMXC__Fixed_Cost__c != NULL)
            dclDefaultFixedCost = objTerritory.SVMXC__Fixed_Cost__c;
        else
            dclDefaultFixedCost = Decimal.valueOf(mapSettingValues.get('OMAX002_SET007'));
        if(objTerritory.SVMXC__Per_hour_Cost__c != NULL)
            dclDefaultPerHourCost = objTerritory.SVMXC__Per_hour_Cost__c;
        else
            dclDefaultPerHourCost = Decimal.valueOf(mapSettingValues.get('OMAX002_SET005'));
    }
    
    public static void setTechnicianParams(SVMXC__Service_Group_Members__c tech){
                // Converting Distance from Miles to KM, Per Mile Cost to Per KM Cost, & Average Speed from Miles/Hr to Meter/Sec if setting is Miles
                if(isMile)
                {
                    if(tech.SVMXC__Per_Mile_Cost__c != NULL)
                        tech.SVMXC__Per_Mile_Cost__c = tech.SVMXC__Per_Mile_Cost__c * (0.621371192);
                    else 
                        tech.SVMXC__Per_Mile_Cost__c = dclDefaultPerKmCost;
                    if(tech.SVMXC__Max_Distance__c != NULL)
                        tech.SVMXC__Max_Distance__c = tech.SVMXC__Max_Distance__c * (1.609344);
                    else 
                        tech.SVMXC__Max_Distance__c = dclDefaultMaxDistance;
                    if(tech.SVMXC__Average_Speed__c != NULL)
                        tech.SVMXC__Average_Speed__c = tech.SVMXC__Average_Speed__c * (0.44704);
                    else 
                        tech.SVMXC__Average_Speed__c = dclDefaultAverageSpeed;
                }
                // Converting Average Speed from KM/Hr to Meter/Sec if setting is not Miles
                else
                {
                    if(tech.SVMXC__Per_Mile_Cost__c == NULL)
                        tech.SVMXC__Per_Mile_Cost__c = dclDefaultPerKmCost;
                    if(tech.SVMXC__Max_Distance__c == NULL)
                        tech.SVMXC__Max_Distance__c = dclDefaultMaxDistance;
                    if(tech.SVMXC__Average_Speed__c != NULL)
                        tech.SVMXC__Average_Speed__c = tech.SVMXC__Average_Speed__c * (0.27778);
                    else 
                        tech.SVMXC__Average_Speed__c = dclDefaultAverageSpeed;
                }
                if(tech.SVMXC__Fixed_Cost__c == NULL)
                    tech.SVMXC__Fixed_Cost__c = dclDefaultFixedCost;
                if(tech.SVMXC__Per_hour_Cost__c == NULL)
                    tech.SVMXC__Per_hour_Cost__c = dclDefaultPerHourCost;
    }
    
    public static void setHorizonDates(SVMXC__Territory__c objTerritory, Id dpId){
        Date datStartDate;
        Date datEndDate;
        Datetime dtmNow = system.now();
        Datetime dtmLastProcessedDateTime;
        //Integer intNoOfDays=0;
                
        // Retrieve the process definition record from ServiceMax_Processes__c by matching the ID with the given dispatch process ID
        objSVMXProcess = [Select Id, SVMXC__Child_Object_Criteria__c, SVMXC__Frequency__c, SVMXC__Full_Run_Unit__c, SVMXC__Retain_Appointment__c,
                        SVMXC__Retain_Assignment__c, SVMXC__Route_Type__c, SVMXC__Weight_Time_Window__c, SVMXC__Weight_Total_Distance__c, SVMXC__Weight_Route_Distance__c,
                        SVMXC__Weight_Node_Type__c, SVMXC__Calendar_Start_Type__c, SVMXC__Calendar_End_Type__c, 
                        SVMXC__Weight_Route_Time__c,
                        SVMXC__Tolerance__c, SVMXC__Calendar_Start_Days__c, SVMXC__Calendar_End_Days__c, SVMXC__Preferred_Tech_Enabled__c, SVMXC__Expertise_Match_Enabled__c,
                        SVMXC__Product_Match_Enabled__c,SVMXC__SM_Drive_Before_Shift_Start__c,
                        SVMXC__SM_Drive_After_Shift_End__c, SVMXC__Dispatch_Method__c
                        from SVMXC__ServiceMax_Processes__c
                        where Id =:dpId];
        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonDates()::objSVMXProcess ' + objSVMXProcess);
    
        
        /*  If Territory business hours is NULL or is not active, set it to the Org's Default business hours.
            This is the default Business Hours to be used for this Dispatch job.
        */
        if(objTerritory.SVMXC__Territory_s_Business_Hours__c == NULL || (mapBusinessHours.containsKey(objTerritory.SVMXC__Territory_s_Business_Hours__c) == FALSE ))
            objTerritory.SVMXC__Territory_s_Business_Hours__c = strDefaultBHourId;
        
        objDefTerritoryBH = mapBusinessHours.get(objTerritory.SVMXC__Territory_s_Business_Hours__c);
        
        // If territory's break hours is inactive, set it to NULL
        if (objTerritory.SVMXC__Break_Hours__c != NULL && mapBusinessHours.containsKey(objTerritory.SVMXC__Break_Hours__c) == FALSE)
            objTerritory.SVMXC__Break_Hours__c = NULL;
            
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonDates()::Default Business Hours for this job: ' + objDefTerritoryBH.Id);    
    
        intNoOfDays = (objSVMXProcess.SVMXC__Calendar_End_Days__c).intValue();
        if(intNoOfDays < 1)
            intNoOfDays = 1;
            
        dtmSchedulingHorizonStartDateTime = BusinessHours.addGmt(objDefTerritoryBH.id, dtmNow,1l);
                      
        // Get the date of the first day in the scheduling horizon in Business Hour time zone
        datStartDate = Date.valueOf(dtmSchedulingHorizonStartDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
        
        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonDates()::Start Date : ' + datStartDate);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonDates()::First Day Start Time:: ' +dtmSchedulingHorizonStartDateTime);
        
        // Starting from the first day, get all the dates in the scheduling horizon
        Date tempDate = datStartDate;
        dtmlastProcessedDateTime = dtmSchedulingHorizonStartDateTime;
        //commented the below line of code as the loop now starts from 0 instead of 1 earlier
        //setSchedHorizDates.add(tempDate);       //already the first date of the Horizon is added to the horizonSet
        
        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonDates()::Initial scheduling horizon in business days: ' +intNoOfDays);
        
        for(integer i = 0; i < intNoOfDays; i++)    //changed the index from to 1 from 0
        {
            tempDate = Date.valueOf(dtmlastProcessedDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
            //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonDates()::tempDate in loop : ' + tempDate);
                
            setSchedHorizDates.add(tempDate);
            
            dtmlastProcessedDateTime = getNextWorkingHour(objDefTerritoryBH, dtmlastProcessedDateTime.addMinutes(5));  //changed the addMinutes value from 1 to 5
            //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonDates()::dtmlastProcessedDateTime in loop : ' + dtmlastProcessedDateTime);
            //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonDates()::dtmlastProcessedDateTime in loop terr TZ : ' + dtmlastProcessedDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
            datEndDate = tempDate;
        }
        
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonDates()::End Date : ' + datEndDate);
        
        if(datEndDate != NULL)
            intNoOfDays = datStartDate.daysBetween(datEndDate) + 1; //changed backed +1 from -1
        
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonDates()::Initial scheduling horizon in calendar days: ' +intNoOfDays);        
    }

    public static Date getHorizonLastDate(Set<Date> setOfHorizonDates) {
        Date horizonEndDate;
        Integer i=0;
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getHorizonLastDate:setOfHorizonDates.size() - ' + setOfHorizonDates.size());
        //get the last date from the set. This will be the last date in the horizon as per the DP
        for(Date eachDate: setOfHorizonDates) {
            if(i==setOfHorizonDates.size()-1) {
                horizonEndDate = eachDate;
            }
            i++;
        }
        return horizonEndDate;
    }
    
    //Below method returns the set of horizon dates between two dates
    public static Set<Date> setHorizonFromPrefEndDate(DateTime horStartDateTime, DateTime horEndDateTime, SVMXC__Territory__c objTerritory) {

        Set<Date> setOfHorDatesFromPet = new Set<Date>();
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonFromPSTAndPET()::horStartDateTime in terr TZ:: ' +horStartDateTime);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonFromPSTAndPET()::horEndDateTime in terr TZ:: ' +horEndDateTime);

        DateTime horStartDateTimeGmt = WSCH_DateUtils.doTZConversion(horStartDateTime , objDefTerritoryBH.timeZoneSidKey, 'GMT');
        DateTime horEndDateTimeGmt = WSCH_DateUtils.doTZConversion(horEndDateTime, objDefTerritoryBH.timeZoneSidKey, 'GMT' );

        /*  If Territory business hours is NULL or is not active, set it to the Org's Default business hours.
            This is the default Business Hours to be used for this Dispatch job.
        */
        if(objTerritory.SVMXC__Territory_s_Business_Hours__c == NULL || (mapBusinessHours.containsKey(objTerritory.SVMXC__Territory_s_Business_Hours__c) == FALSE ))
            objTerritory.SVMXC__Territory_s_Business_Hours__c = strDefaultBHourId;
        
        objDefTerritoryBH = mapBusinessHours.get(objTerritory.SVMXC__Territory_s_Business_Hours__c);
        
        // If territory's break hours is inactive, set it to NULL
        if (objTerritory.SVMXC__Break_Hours__c != NULL && mapBusinessHours.containsKey(objTerritory.SVMXC__Break_Hours__c) == FALSE)
            objTerritory.SVMXC__Break_Hours__c = NULL;
            
        DateTime dtmSchedulingHorizonStartDateTime = BusinessHours.addGmt(objDefTerritoryBH.id, horStartDateTimeGmt, 1L);
        // Get the date of the first day in the scheduling horizon in Business Hour time zone
        Date datStartDate = Date.valueOf(dtmSchedulingHorizonStartDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
        Date datEndDate = Date.valueOf(horEndDateTimeGmt.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
        Integer intNoOfDays = datStartDate.daysBetween(datEndDate) + 1;
        Date territoryEndDate = datEndDate;

        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonFromPSTAndPET()::horStartDateTimeGmt:: ' +horStartDateTimeGmt);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonFromPSTAndPET()::horEndDateTimeGmt:: ' +horEndDateTimeGmt);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonFromPSTAndPET()::First Day Start Time:: ' +dtmSchedulingHorizonStartDateTime);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonFromPSTAndPET()::Start Date : ' + datStartDate);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonFromPSTAndPET()::End Date : ' + datEndDate);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonFromPSTAndPET()::Initial scheduling horizon in business days: ' + intNoOfDays);

        for(integer i = 0; i < intNoOfDays; i++) {
            Date tempDate = Date.valueOf(dtmSchedulingHorizonStartDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
            //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonFromPSTAndPET()::tempDate in loop : ' + tempDate);
            if(tempDate > territoryEndDate)
                break;
                
                setOfHorDatesFromPet.add(tempDate);
            
            dtmSchedulingHorizonStartDateTime = getNextWorkingHour(objDefTerritoryBH, dtmSchedulingHorizonStartDateTime.addMinutes(5));  //changed the addMinutes value from 1 to 5
            //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonFromPSTAndPET()::dtmlastProcessedDateTime in loop : ' + dtmlastProcessedDateTime);
            //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonFromPSTAndPET()::dtmlastProcessedDateTime in loop terr TZ : ' + dtmlastProcessedDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
            datEndDate = tempDate;
        }
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonFromPSTAndPET()::startDate and endDate after horizon calculation: StartDate:'+ datStartDate + 'endDate:' + datEndDate);
        
        if(datEndDate != NULL)
            intNoOfDays = datStartDate.daysBetween(datEndDate) + 1;
        
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonFromPSTAndPET()::Initial scheduling horizon in calendar days: ' +intNoOfDays); 
        return setOfHorDatesFromPet;
    }
    
    public static void setHorizonDatesForApptWO(SVMXC__Territory__c objTerritory, WSCH_ApptParam apptParam){
        Date datStartDate;
        Date datEndDate;
        //Datetime dtmNow = system.now();
        Datetime dtmLastProcessedDateTime;
        //Integer intNoOfDays=0;
        
        DateTime calStartDatetime = apptParam.startDateTime;
        DateTime calEndDatetime = apptParam.endDateTime;
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonDatesForApptWO():calendar start datetime in GMT TZ: ' + calStartDatetime);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonDatesForApptWO():calendar end datetime in GMT TZ: ' + calEndDatetime);
                
        /*  If Territory business hours is NULL or is not active, set it to the Org's Default business hours.
            This is the default Business Hours to be used for this Dispatch job.
        */
        if(objTerritory.SVMXC__Territory_s_Business_Hours__c == NULL || (mapBusinessHours.containsKey(objTerritory.SVMXC__Territory_s_Business_Hours__c) == FALSE ))
            objTerritory.SVMXC__Territory_s_Business_Hours__c = strDefaultBHourId;
        
        objDefTerritoryBH = mapBusinessHours.get(objTerritory.SVMXC__Territory_s_Business_Hours__c);
        
        // If territory's break hours is inactive, set it to NULL
        if (objTerritory.SVMXC__Break_Hours__c != NULL && mapBusinessHours.containsKey(objTerritory.SVMXC__Break_Hours__c) == FALSE)
            objTerritory.SVMXC__Break_Hours__c = NULL;
            
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonDatesForApptWO()::Default Business Hours for this job: ' + objDefTerritoryBH.Id);    
        
        dtmSchedulingHorizonStartDateTime = BusinessHours.addGmt(objDefTerritoryBH.id, calStartDatetime, 1L);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonDatesForApptWO()::First Day Start Time:: ' +dtmSchedulingHorizonStartDateTime);
                      
        // Get the date of the first day in the scheduling horizon in Business Hour time zone
        datStartDate = Date.valueOf(dtmSchedulingHorizonStartDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
        
        //get the endDate based on the territory timezone to get the daysbetween the start and end date
        datEndDate = Date.valueOf(calEndDatetime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
        Date territoryEndDate = datEndDate;
        //commented the above two lines of code and introduced the below. First get the endDateTime from the calEndDateTime as per the
        // BH as done in getting the startDateTime above.
        /*Datetime dtmSchedulingHorizonEndDateTime = BusinessHours.addGmt(objDefTerritoryBH.id, calEndDatetime, 1L);
        datEndDate = Date.valueOf(dtmSchedulingHorizonEndDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
        Date territoryEndDate = datEndDate;*/
        
        //get the no. of days from the difference between territory based endDate and startDate
        intNoOfDays = datStartDate.daysBetween(datEndDate) + 1;
        
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonDatesForApptWO()::Start Date : ' + datStartDate);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonDatesForApptWO()::End Date : ' + datEndDate);
        
        // Starting from the first day, get all the dates in the scheduling horizon
        //dtmlastProcessedDateTime = dtmSchedulingHorizonStartDateTime.addDays(-1); // setting the start to the previous day as the loop 
                                                                                    // starts checking for the working days starting the next day 
        //commented the above line(where 1 day is subtracted) and added the below line for testing.
        dtmlastProcessedDateTime = dtmSchedulingHorizonStartDateTime;
        
        //added the below line for testing.
        //adding the first date in the horizon.
        //setSchedHorizDates.add(datStartDate);
        
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonDatesForApptWO()::dtmlastProcessedDateTime: ' + dtmlastProcessedDateTime);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonDatesForApptWO()::Initial scheduling horizon in business days: ' + intNoOfDays);
        
         for(integer i = 0; i < intNoOfDays; i++)
        {
            Date tempDate = Date.valueOf(dtmlastProcessedDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
            //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonDates()::tempDate in loop : ' + tempDate);
            
            if(tempDate > territoryEndDate)
                break;
                
            setSchedHorizDates.add(tempDate);
            
            dtmlastProcessedDateTime = getNextWorkingHour(objDefTerritoryBH, dtmlastProcessedDateTime.addMinutes(5));  //changed the addMinutes value from 1 to 5
            //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonDates()::dtmlastProcessedDateTime in loop : ' + dtmlastProcessedDateTime);
            //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonDates()::dtmlastProcessedDateTime in loop terr TZ : ' + dtmlastProcessedDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
            datEndDate = tempDate;
         }
        
        WSCH_AuditLogger.debug('startDate and endDate after horizon calculation: StartDate:'+ datStartDate + 'endDate:' + datEndDate);
        
        if(datEndDate != NULL)
            intNoOfDays = datStartDate.daysBetween(datEndDate) + 1;
        
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setHorizonDates()::Initial scheduling horizon in calendar days: ' +intNoOfDays);        
    }
    
    public static WSCH_Provider_ECO_Stubs.ExcSetting_WP setOrganizationParameters( String key, String value)
    {
            WSCH_Provider_ECO_Stubs.ExcSetting_WP orgParam = new WSCH_Provider_ECO_Stubs.ExcSetting_WP();
            orgParam.name = key;
            orgParam.value = value;
            return orgParam;
    }   
    
       public static Map<String, WSCH_Provider_ECO_Stubs.ManageTechnicianEventRequest_WP> createManageTechnicianEventRequest(List<SVMXC__SVMX_Optimizer__c> optimizers)
         {
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper createManageTechnicianEventRequest optimizers:- '+optimizers);
            WSCH_Provider_ECO_Stubs.TechniciansEvent_WP techevent;      
            //WSCH_Provider_ECO_Stubs.TechniciansEventsAdditonalDetails_WP techeventAdditionalDetails;
            Map<String, WSCH_Provider_ECO_Stubs.ManageTechnicianEventRequest_WP> teritoryAndRequestMap = new  Map<String,WSCH_Provider_ECO_Stubs.ManageTechnicianEventRequest_WP>();
            SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
            map<String,String> teritoryIdAndProcessIdMap = new map<String,String>();
            List<String> technicianIds = new List<String>();
            map<String,SVMXC__SVMX_Event__c> svmxEvents ;
            map<String,Event> sfEvents;
            List<String> sfEventIds = new List<String>();
            List<String> svmxEventIds = new List<String>();
            SVMXC__SVMX_Optimizer__c optTrans;
            String technicianId;
            String territoryId;
            String dispatchProcessId;
            String eventId;
            Datetime evStartTime = null;
            DateTime evEndTime = null;
            Integer driveTime = 0;
            Integer returnDriveTime = 0;
            
            Map<String,SVMXC__SVMX_Optimizer__c> whatIdsAndOptimizerMap = new Map<String,SVMXC__SVMX_Optimizer__c>();    
            for(SVMXC__SVMX_Optimizer__c optimizer : optimizers) {
                if(WSCH_CommonUtils.isSFEvent(optimizer)) {
                    sfEventIds.add(optimizer.SVMXC__WhatId__c.split('_')[0]);
                } else if(WSCH_CommonUtils.isSVMXEvent(optimizer)) {
                     svmxEventIds.add(optimizer.SVMXC__WhatId__c.split('_')[0]);
                }
                teritoryIdAndProcessIdMap.put(optimizer.SVMXC__Optimizer_Connection_ID__c.split('_')[1],optimizer.SVMXC__Optimizer_Connection_ID__c.split('_')[0]);
                technicianIds.add(optimizer.SVMXC__Optimizer_Connection_ID__c.split('_')[2]);
            }            
             WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper createManageTechnicianEventRequest sfEventIds:- '+sfEventIds+' , svmxEventIds:- '+svmxEventIds);

            // Fetch all SF events
            sfEvents = new Map<String,Event>([Select Id,WhatId,StartDateTime,EndDateTime,SVMXC__Driving_Time__c,SVMXC__Driving_Time_Home__c, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c, Location from EVENT where Id in : sfEventIds]);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::createManageTechnicianEventRequest:: sfEvents' + sfEvents.size());
            
            // Fetch all SVMX events
            svmxEvents = new Map<String,SVMXC__SVMX_Event__c>( [Select Id,SVMXC__WhatId__c,SVMXC__StartDateTime__c,SVMXC__EndDateTime__c,SVMXC__Technician__c,SVMXC__Driving_Time__c,SVMXC__Driving_Time_Home__c, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c, SVMXC__Location__c from SVMXC__SVMX_Event__c where Id in : svmxEventIds]);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::createManageTechnicianEventRequest:: svmxEvents ' + svmxEvents.size());
            
            //Multi-resource and Multi-appointment
            set<Id> setEventWorkOrderIds = new set<Id>();
            set<Id> setEventExternalWorkOrderIds = new set<Id>();
            Map<Id, List<Double>> mapWoIdLatLong = new Map<Id, List<Double>>();
            Map<Id, String> mapWoIdAddress = new Map<Id, String>();
            String woKeyPrfx = Schema.SObjectType.SVMXC__Service_Order__c.getKeyPrefix();
            for(Event e: sfEvents.values())
            {
                // If it is a work order event, add the work order to the list of work orders
                if(e.WhatId != NULL && String.valueof(e.WhatId).startsWith(woKeyPrfx) == TRUE)
                {
                    setEventWorkOrderIds.add(e.WhatId);
                }
            }
            
            for(SVMXC__SVMX_Event__c e: svmxEvents.values())
            {
                // If it is a work order event, add the work order to the list of work orders
                if(e.SVMXC__WhatId__c != NULL && String.valueof(e.SVMXC__WhatId__c).startsWith(woKeyPrfx) == TRUE)
                {
                    setEventWorkOrderIds.add(e.SVMXC__WhatId__c);
                }
            }
            
            Map<Id, SVMXC__Service_Order__c> mapAllEventWorkOrders = new Map<Id, SVMXC__Service_Order__c>();
            mapAllEventWorkOrders.putAll([Select Id, Name, SVMXC__Latitude__c, SVMXC__Longitude__c, SVMXC__Dispatch_Process__c, SVMXC__Zip__c, SVMXC__Country__c, SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c from SVMXC__Service_Order__c where Id IN: setEventWorkOrderIds]);
            //end Multi-resource and Multi-appointment
            //Fetch the technincians
            Map<Id,SVMXC__Service_Group_Members__c> technicians = WSCH_ECO_CommonUtils.getTechnicians(technicianIds);
            // WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper: technicians '+technicians.size());
            // //Fetch all technician BHs 
            // set<Id> bhIDs = new set<Id>();
            // for(SVMXC__Service_Group_Members__c tech : technicians.values()){
            //     if(tech.SVMXC__Working_Hours__c != null){
            //         bhIDs.add(tech.SVMXC__Working_Hours__c);
            //     } else if(tech.SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c != null){
            //         bhIDs.add(tech.SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c);
            //         tech.SVMXC__Working_Hours__c = tech.SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c;
            //     }                
            // }
            // List<BusinessHours> lstBusinessHours  = [Select Id, Name, IsDefault, IsActive, TimeZoneSidKey, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
            //                     ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime
            //                     from BusinessHours where Id in :bhIDs AND isActive = True];                
            // Map<Id, BusinessHours> mapBusinessHours = new Map<Id, BusinessHours>();
            // for(BusinessHours bh : lstBusinessHours)
            // {
            //     mapBusinessHours.put(bh.Id, bh);                        
            // }
            // //Heap size issue
            // lstBusinessHours.clear();
            String optWhatId;
            //List<WSCH_Provider_ECO_Stubs.TechniciansEvent_WP> lstTechEvent = new List<WSCH_Provider_ECO_Stubs.TechniciansEvent_WP>();   
             for(SVMXC__SVMX_Optimizer__c optimizer : optimizers){
                //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper: CREATING REQUEST '+teritoryAndRequestMap);
                technician = technicians.get(optimizer.SVMXC__Optimizer_Connection_ID__c.split('_')[2]);
                // Check if technician corresponding to this optimizer transaction exits or not
                if(technician == null) {
                    WSCH_AuditLogger.warn('Skipping optimizer transaction ' + optimizer + ' as no corresponding technician found!');
                    continue;
                }
                technicianId = technician.id+'_'+technician.name;
                territoryId = optimizer.SVMXC__Optimizer_Connection_ID__c.split('_')[1];
                eventId = 'Event_'+optimizer.SVMXC__WhatId__c;
                
               WSCH_AuditLogger.debug('technicianId:-  '+technicianId+' ; territoryId:-  '+territoryId+' ; eventID:-  '+eventId);

                // Reset values before setting them from event object to avoid sending time from previous event to next one in case it does not satify checks below
                evStartTime = null;
                evEndTime = null;
                driveTime = 0;
                returnDriveTime = 0;
                String eventAddress = '';
                WSCH_Provider_ECO_Stubs.Location_WP wrpEventLocation;
                Map<String, String> parameters = new Map<String, String>();   
                String strOperationType = getOperationType(optimizer.SVMXC__Optimizer_Change_Token__c);
                
               optWhatId = optimizer.SVMXC__WhatId__c.split('_')[0];
               WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper createManageTechnicianEventRequest optWhatId:- '+optWhatId);
                if((null != sfEvents &&  sfEvents.containsKey(optWhatId))) {
                        driveTime = Integer.valueOf(sfEvents.get(optWhatId).SVMXC__Driving_Time__c);
                        returnDriveTime = Integer.valueOf(sfEvents.get(optWhatId).SVMXC__Driving_Time_Home__c);
                        evStartTime = sfEvents.get(optWhatId).StartDateTime.addMinutes(driveTime);
                        evEndTime = sfEvents.get(optWhatId).EndDatetime.addMinutes(-returnDriveTime);                    
                        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::createManageTechnicianEventRequest::StartDateTime:'+sfEvents.get(optWhatId).StartDateTime.addMinutes(driveTime));
                        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::createManageTechnicianEventRequest::EndDatetime:'+sfEvents.get(optWhatId).EndDatetime.addMinutes(-returnDriveTime));
                        if(sfEvents.get(optWhatId).SVMXC__SM_Latitude__c != null && sfEvents.get(optWhatId).SVMXC__SM_Longitude__c != null){
                            wrpEventLocation = new WSCH_Provider_ECO_Stubs.Location_WP();
                            wrpEventLocation.latitude = sfEvents.get(optWhatId).SVMXC__SM_Latitude__c;
                            wrpEventLocation.longitude = sfEvents.get(optWhatId).SVMXC__SM_Longitude__c;
                        }
                        if(sfEvents.get(optWhatId).Location != null){
                            eventAddress = sfEvents.get(optWhatId).Location;
                        }
                        String woId = sfEvents.get(optWhatId).WhatId;
                        if(mapAllEventWorkOrders != null && mapAllEventWorkOrders.get(woId) != null){
                            if(strOperationType.equals('add')){ // To create the pillar only in case of new event creation
                                parameters.put('relatedElementId', mapAllEventWorkOrders.get(woId).Name);
                                strOperationType = 'ecoReplaceWithEvent';
                            }
                            if(wrpEventLocation == null){
                                wrpEventLocation = new WSCH_Provider_ECO_Stubs.Location_WP();
                                if(mapAllEventWorkOrders.get(woId).SVMXC__Latitude__c != null && mapAllEventWorkOrders.get(woId).SVMXC__Longitude__c != null){
                                    wrpEventLocation.latitude = mapAllEventWorkOrders.get(woId).SVMXC__Latitude__c;
                                    wrpEventLocation.longitude = mapAllEventWorkOrders.get(woId).SVMXC__Longitude__c;
                                }else{
                                    eventAddress = ((mapAllEventWorkOrders.get(woId).SVMXC__Street__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__Street__c.length() > 0) ? mapAllEventWorkOrders.get(woId).SVMXC__Street__c : '') + ((mapAllEventWorkOrders.get(woId).SVMXC__City__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__City__c.length() > 0) ?  (((mapAllEventWorkOrders.get(woId).SVMXC__Street__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__Street__c.length() > 0)) ? ', ' : '') + mapAllEventWorkOrders.get(woId).SVMXC__City__c : '') + ((mapAllEventWorkOrders.get(woId).SVMXC__State__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__State__c.length() > 0) ?  (((mapAllEventWorkOrders.get(woId).SVMXC__City__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__City__c.length() > 0) || ((mapAllEventWorkOrders.get(woId).SVMXC__Street__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__Street__c.length() > 0))) ? ', ' : '') + mapAllEventWorkOrders.get(woId).SVMXC__State__c : '') + ((mapAllEventWorkOrders.get(woId).SVMXC__Zip__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__Zip__c.length() > 0) ?  (((mapAllEventWorkOrders.get(woId).SVMXC__State__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__State__c.length() > 0) || (mapAllEventWorkOrders.get(woId).SVMXC__City__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__City__c.length() > 0) || ((mapAllEventWorkOrders.get(woId).SVMXC__Street__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__Street__c.length() > 0))) ? ', ' : '') + mapAllEventWorkOrders.get(woId).SVMXC__Zip__c : '') + ((mapAllEventWorkOrders.get(woId).SVMXC__Country__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__Country__c.length() > 0) ?  (((mapAllEventWorkOrders.get(woId).SVMXC__Zip__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__Zip__c.length() > 0) || (mapAllEventWorkOrders.get(woId).SVMXC__State__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__State__c.length() > 0) || (mapAllEventWorkOrders.get(woId).SVMXC__City__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__City__c.length() > 0) || ((mapAllEventWorkOrders.get(woId).SVMXC__Street__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__Street__c.length() > 0))) ? ', ' : '') + mapAllEventWorkOrders.get(woId).SVMXC__Country__c : '');
                                }
                            }
                        }
                } else if(null != svmxEvents &&  svmxEvents.containsKey(optWhatId)) {
                        driveTime = Integer.valueOf(svmxEvents.get(optWhatId).SVMXC__Driving_Time__c);
                        returnDriveTime = Integer.valueOf(svmxEvents.get(optWhatId).SVMXC__Driving_Time_Home__c);
                        evStartTime = svmxEvents.get(optWhatId).SVMXC__StartDateTime__c.addMinutes(driveTime);
                        evEndTime = svmxEvents.get(optWhatId).SVMXC__EndDateTime__c.addMinutes(-returnDriveTime);                    
                        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::createManageTechnicianEventRequest::SVMXC__StartDateTime__c:'+svmxEvents.get(optWhatId).SVMXC__StartDateTime__c);
                        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::createManageTechnicianEventRequest::SVMXC__EndDateTime__c:'+svmxEvents.get(optWhatId).SVMXC__EndDateTime__c);
                        if(svmxEvents.get(optWhatId).SVMXC__SM_Latitude__c != null && svmxEvents.get(optWhatId).SVMXC__SM_Longitude__c != null){
                            wrpEventLocation = new WSCH_Provider_ECO_Stubs.Location_WP();
                            wrpEventLocation.latitude = svmxEvents.get(optWhatId).SVMXC__SM_Latitude__c;
                            wrpEventLocation.longitude = svmxEvents.get(optWhatId).SVMXC__SM_Longitude__c; 
                        }
                        if(svmxEvents.get(optWhatId).SVMXC__Location__c != null){
                            eventAddress = svmxEvents.get(optWhatId).SVMXC__Location__c;
                        }
                        String woId = svmxEvents.get(optWhatId).SVMXC__WhatId__c;
                        if(mapAllEventWorkOrders != null && mapAllEventWorkOrders.get(woId) != null){
                            if(strOperationType.equals('add')){ // To create the pillar only in case of new event creation
                                parameters.put('relatedElementId', mapAllEventWorkOrders.get(woId).Name);
                                strOperationType = 'ecoReplaceWithEvent';
                            }
                            if(wrpEventLocation == null){
                                wrpEventLocation = new WSCH_Provider_ECO_Stubs.Location_WP();
                                if(mapAllEventWorkOrders.get(woId).SVMXC__Latitude__c != null && mapAllEventWorkOrders.get(woId).SVMXC__Longitude__c != null){
                                    wrpEventLocation.latitude = mapAllEventWorkOrders.get(woId).SVMXC__Latitude__c;
                                    wrpEventLocation.longitude = mapAllEventWorkOrders.get(woId).SVMXC__Longitude__c;
                                }else{
                                    eventAddress = ((mapAllEventWorkOrders.get(woId).SVMXC__Street__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__Street__c.length() > 0) ? mapAllEventWorkOrders.get(woId).SVMXC__Street__c : '') + ((mapAllEventWorkOrders.get(woId).SVMXC__City__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__City__c.length() > 0) ?  (((mapAllEventWorkOrders.get(woId).SVMXC__Street__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__Street__c.length() > 0)) ? ', ' : '') + mapAllEventWorkOrders.get(woId).SVMXC__City__c : '') + ((mapAllEventWorkOrders.get(woId).SVMXC__State__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__State__c.length() > 0) ?  (((mapAllEventWorkOrders.get(woId).SVMXC__City__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__City__c.length() > 0) || ((mapAllEventWorkOrders.get(woId).SVMXC__Street__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__Street__c.length() > 0))) ? ', ' : '') + mapAllEventWorkOrders.get(woId).SVMXC__State__c : '') + ((mapAllEventWorkOrders.get(woId).SVMXC__Zip__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__Zip__c.length() > 0) ?  (((mapAllEventWorkOrders.get(woId).SVMXC__State__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__State__c.length() > 0) || (mapAllEventWorkOrders.get(woId).SVMXC__City__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__City__c.length() > 0) || ((mapAllEventWorkOrders.get(woId).SVMXC__Street__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__Street__c.length() > 0))) ? ', ' : '') + mapAllEventWorkOrders.get(woId).SVMXC__Zip__c : '') + ((mapAllEventWorkOrders.get(woId).SVMXC__Country__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__Country__c.length() > 0) ?  (((mapAllEventWorkOrders.get(woId).SVMXC__Zip__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__Zip__c.length() > 0) || (mapAllEventWorkOrders.get(woId).SVMXC__State__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__State__c.length() > 0) || (mapAllEventWorkOrders.get(woId).SVMXC__City__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__City__c.length() > 0) || ((mapAllEventWorkOrders.get(woId).SVMXC__Street__c != NULL && mapAllEventWorkOrders.get(woId).SVMXC__Street__c.length() > 0))) ? ', ' : '') + mapAllEventWorkOrders.get(woId).SVMXC__Country__c : '');
                                }
                            }
                        }
                } 
                //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::createManageTechnicianEventRequest() parameters.size(): '+parameters.size()+' , parameters: '+parameters+' , wrpEventLocation: '+wrpEventLocation+' , eventAddress: '+eventAddress);
                techevent = new WSCH_Provider_ECO_Stubs.TechniciansEvent_WP(territoryId,technicianId,eventId,evStartTime,evEndTime,0,0,1,strOperationType, wrpEventLocation, eventAddress,parameters);
                //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::createManageTechnicianEventRequest() strOperationType: '+strOperationType+' , techevent: '+techevent+'\n');
                teritoryAndRequestMap = createTechnicianEventRequest(territoryId,teritoryIdAndProcessIdMap,teritoryAndRequestMap,techevent);
                //lstTechEvent.add(techevent);
            }
            // if(lstTechEvent != null && !lstTechEvent.isEmpty()){
            //     teritoryAndRequestMap = createTechnicianEventRequest(territoryId,teritoryIdAndProcessIdMap,teritoryAndRequestMap,lstTechEvent);
            //     WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::createManageTechnicianEventRequest() teritoryAndRequestMap size(): '+teritoryAndRequestMap.size()+'\n');    
            // }
            return teritoryAndRequestMap;
        }
        
        public static Map<String, WSCH_Provider_ECO_Stubs.ManageTechnicianEventRequest_WP> createTechnicianEventRequest(String teritoryId, Map<String,String> teritoryAndProcessMap,Map<String, WSCH_Provider_ECO_Stubs.ManageTechnicianEventRequest_WP> teritoryAndRequestMap,
                    WSCH_Provider_ECO_Stubs.TechniciansEvent_WP techevent){
                         
           //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper: createTechnicianEventRequest '+teritoryAndRequestMap+'  ;teritoryId:-' +teritoryId +' techevent'+techevent+ ' teritoryAndProcessMap :  '+ teritoryAndProcessMap);
                         
            //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper: createTechnicianEventRequest '+teritoryAndRequestMap+'  ;teritoryId:-' +teritoryId +' lstTechEvent: '+lstTechEvents+ ' teritoryAndProcessMap :  '+ teritoryAndProcessMap);
            
            WSCH_Provider_ECO_Stubs.ManageTechnicianEventRequest_WP terRequest= new WSCH_Provider_ECO_Stubs.ManageTechnicianEventRequest_WP();
            List<WSCH_Provider_ECO_Stubs.TechniciansEvent_WP> techEventsRequestList;
            
                if(teritoryAndRequestMap.containsKey(teritoryId)){
                     WSCH_AuditLogger.debug('update request'); 
                         
                        terRequest = teritoryAndRequestMap.get(teritoryId);
                        
                        techEventsRequestList = terRequest.TechnicianEvents;
                        techEventsRequestList.add(techevent);
                        terRequest.TechnicianEvents = techEventsRequestList;
                    }
                    else{
                         WSCH_AuditLogger.debug('Create Request');
                         
                        terRequest = new WSCH_Provider_ECO_Stubs.ManageTechnicianEventRequest_WP();
                        techEventsRequestList = new List<WSCH_Provider_ECO_Stubs.TechniciansEvent_WP>();
                        techEventsRequestList.add(techevent);
                       
                        terRequest.dispatchProcessId = teritoryAndProcessMap.get(teritoryId);
                        terRequest.territoryId = teritoryId;
                        terRequest.orgId = Userinfo.getOrganizationId().substring(0,15);
                        terRequest.svmxVersion = '16.29023';
                        terRequest.geoCodingEnabled = true ;
                        terRequest.TechnicianEvents = techEventsRequestList;
                    }
            
            teritoryAndRequestMap.put(teritoryId,terRequest);
            return teritoryAndRequestMap;
        }

        // public static Map<String, WSCH_Provider_ECO_Stubs.ManageTechnicianEventRequest_WP> createTechnicianEventRequest(String teritoryId, Map<String,String> teritoryAndProcessMap,Map<String, WSCH_Provider_ECO_Stubs.ManageTechnicianEventRequest_WP> teritoryAndRequestMap,
        //             List<WSCH_Provider_ECO_Stubs.TechniciansEvent_WP> lstTechEvents){
                         
        //     WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper: createTechnicianEventRequest '+teritoryAndRequestMap+'  ;teritoryId:-' +teritoryId +' lstTechEvent: '+lstTechEvents+ ' teritoryAndProcessMap :  '+ teritoryAndProcessMap);
            
        //     WSCH_Provider_ECO_Stubs.ManageTechnicianEventRequest_WP terRequest= new WSCH_Provider_ECO_Stubs.ManageTechnicianEventRequest_WP();
        //     List<WSCH_Provider_ECO_Stubs.TechniciansEvent_WP> techEventsRequestList;
            
        //         if(teritoryAndRequestMap.containsKey(teritoryId)){
        //              WSCH_AuditLogger.debug('update request'); 
                         
        //                 terRequest = teritoryAndRequestMap.get(teritoryId);
                        
        //                 techEventsRequestList = terRequest.TechnicianEvents;
        //                 terRequest.TechnicianEvents = lstTechEvents;
        //             }
        //             else{
        //                  WSCH_AuditLogger.debug('Create Request');
                         
        //                 terRequest = new WSCH_Provider_ECO_Stubs.ManageTechnicianEventRequest_WP();
        //                 techEventsRequestList = new List<WSCH_Provider_ECO_Stubs.TechniciansEvent_WP>();                       
        //                 terRequest.dispatchProcessId = teritoryAndProcessMap.get(teritoryId);
        //                 terRequest.territoryId = teritoryId;
        //                 terRequest.orgId = Userinfo.getOrganizationId().substring(0,15);
        //                 terRequest.svmxVersion = '16.29023';
        //                 terRequest.geoCodingEnabled = true ;
        //                 terRequest.TechnicianEvents = lstTechEvents;
        //             }
            
        //     teritoryAndRequestMap.put(teritoryId,terRequest);
        //     return teritoryAndRequestMap;
        // }
        
        
        private static String getOperationType(String changeToken){
          String operationType = '' ;
          if(changeToken == WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_CREATE){
                operationType = WSCH_ECO_Constants.OPT_OPERATION_TYPE_ADD;
           }
           else if(WSCH_ECO_Constants.UPDATEEVENT_CHANGE_TOKENS.contains(changeToken)){ //Multi-resource and Multi-appointment
           //else if(changeToken == WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_UPDATE){
                operationType =  WSCH_ECO_Constants.OPT_OPERATION_TYPE_UPDATE;
           }
             else if(changeToken == WSCH_ECO_Constants.OPT_OPTIMIZER_CHANGE_TOKEN_DELETE){
                operationType = WSCH_ECO_Constants.OPT_OPERATION_TYPE_DELETE;
           }
           return   operationType;
        }
        
        // public static Map<String, List<String>> getTechSkillMap(List<SVMXC__Service_Group_Members__c> lstTechs){
        //     Map<String, List<String>> mapTechIdSkills = new Map<String, List<String>>();
        //     set<Id> setTechIds = new set<Id>();
        //     for(SVMXC__Service_Group_Members__c tech : lstTechs){
        //         setTechIds.add(tech.Id);
        //     }
        //     List<SVMXC__Service_Group_Skills__c> lstTechSkills = [SELECT Id,IsDeleted,Name,SVMXC__Availability_Start_Date__c, SVMXC__Availability_End_Date__c, SVMXC__Group_Member__c,SVMXC__Skill__r.Id, SVMXC__Skill__r.Name,SVMXC__Skill__r.SVMXC__Active__c FROM SVMXC__Service_Group_Skills__c WHERE SVMXC__Group_Member__c in :setTechIds AND IsDeleted = false AND SVMXC__Skill__r.SVMXC__Active__c = true limit 49999];
        //     //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechSkillMap():: lstTechSkills' +lstTechSkills);
        //     for(SVMXC__Service_Group_Skills__c groupSkill : lstTechSkills){
        //         //String skillName = groupSkill.Name+'_'+groupSkill.SVMXC__Skill__r.Id+'_'+groupSkill.SVMXC__Skill__r.Name;
        //         //TODO: need to validate experitise expiration from star and end datetime
        //         String skillName = groupSkill.SVMXC__Skill__r.Id;
        //         if(!mapTechIdSkills.containsKey(groupSkill.SVMXC__Group_Member__c))
        //             mapTechIdSkills.put(groupSkill.SVMXC__Group_Member__c, new List<String>());
                
        //         mapTechIdSkills.get(groupSkill.SVMXC__Group_Member__c).add(skillName);
        //     }
        //     return mapTechIdSkills;
        // }
        
       // Expertise expiry 
       public static Map<String, List<WSCH_Provider_ECO_Stubs.Expertise_WP>> getTechExpertiseMap(List<SVMXC__Service_Group_Members__c> lstTechs){
            Map<String, List<WSCH_Provider_ECO_Stubs.Expertise_WP>> mapTechIdSkills = new Map<String, List<WSCH_Provider_ECO_Stubs.Expertise_WP>>();
            set<Id> setTechIds = new set<Id>();
            for(SVMXC__Service_Group_Members__c tech : lstTechs){
                setTechIds.add(tech.Id);
            }
            List<SVMXC__Service_Group_Skills__c> lstTechSkills = [SELECT Id,IsDeleted,Name,SVMXC__Availability_Start_Date__c, SVMXC__Availability_End_Date__c, SVMXC__Group_Member__c,SVMXC__Skill__r.Id, SVMXC__Skill__r.Name,SVMXC__Skill__r.SVMXC__Active__c,SVMXC__Skill_Level__c FROM SVMXC__Service_Group_Skills__c WHERE SVMXC__Group_Member__c in :setTechIds AND IsDeleted = false AND SVMXC__Skill__r.SVMXC__Active__c = true limit 49999];
            //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechExpertiseMap():: lstTechSkills' +lstTechSkills);
            for(SVMXC__Service_Group_Skills__c groupSkill : lstTechSkills){
                WSCH_Provider_ECO_Stubs.Expertise_WP expertiseWP = new WSCH_Provider_ECO_Stubs.Expertise_WP();
                expertiseWP.id=groupSkill.SVMXC__Skill__r.Id;
                expertiseWP.validFrom=groupSkill.SVMXC__Availability_Start_Date__c;
                expertiseWP.validTo=groupSkill.SVMXC__Availability_End_Date__c;
                expertiseWP.level = groupSkill.SVMXC__Skill_Level__c;
                //String skill;
                //skill = groupSkill.SVMXC__Skill__r.Id+'_'+groupSkill.SVMXC__Availability_Start_Date__c+'_'+groupSkill.SVMXC__Availability_End_Date__c;
                //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechExpertiseMap():: groupSkill.SVMXC__Availability_Start_Date__c: ' +groupSkill.SVMXC__Availability_Start_Date__c + ' , groupSkill.SVMXC__Availability_End_Date__c: '+groupSkill.SVMXC__Availability_End_Date__c);
                //if(groupSkill.SVMXC__Availability_Start_Date__c != null && groupSkill.SVMXC__Availability_End_Date__c != null ){
                    //skill = groupSkill.SVMXC__Skill__r.Id+'_'+groupSkill.SVMXC__Skill__r.Name+'_'+groupSkill.SVMXC__Availability_Start_Date__c+'_'+groupSkill.SVMXC__Availability_End_Date__c;
                //}else{
                   // skill = groupSkill.SVMXC__Skill__r.Id+'_'+groupSkill.SVMXC__Skill__r.Name;
                //}
                //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::getTechExpertiseMap():: skill' +skill);
                if(!mapTechIdSkills.containsKey(groupSkill.SVMXC__Group_Member__c))
                    mapTechIdSkills.put(groupSkill.SVMXC__Group_Member__c, new List<WSCH_Provider_ECO_Stubs.Expertise_WP>());
                
                mapTechIdSkills.get(groupSkill.SVMXC__Group_Member__c).add(expertiseWP);
            }
            return mapTechIdSkills;
        } 
        

    public static void setApptParamDates(SVMXC__Service_Order__c workOrderRecord,SVMXC__Territory__c objTerritory, WSCH_ApptParam apptParam){
        /*  If Territory business hours is NULL or is not active, set it to the Org's Default business hours.
            This is the default Business Hours to be used for this Dispatch job.
        */
        if(objTerritory.SVMXC__Territory_s_Business_Hours__c == NULL || (mapBusinessHours.containsKey(objTerritory.SVMXC__Territory_s_Business_Hours__c) == FALSE ))
            objTerritory.SVMXC__Territory_s_Business_Hours__c = strDefaultBHourId;
        
        objDefTerritoryBH = mapBusinessHours.get(objTerritory.SVMXC__Territory_s_Business_Hours__c);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setApptParamDates()::Default Business Hours for this job: ' + objDefTerritoryBH.Id);
        String territoryTimezone =  objDefTerritoryBH.TimeZoneSidKey;   

        DateTime calStartDatetime = apptParam.startDateTime;
        DateTime calEndDatetime = apptParam.endDateTime;
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setApptParamDates(): calendar start datetime in GMT: ' + calStartDatetime);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setApptParamDates(): calendar end datetime in GMT: ' + calEndDatetime);

        DateTime startDatetimeBH = WSCH_DateUtils.doTZConversion(calStartDatetime, 'GMT', territoryTimezone);
        DateTime endDatetimeBH = WSCH_DateUtils.doTZConversion(calEndDatetime, 'GMT', territoryTimezone);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setApptParamDates(): calendar start datetime in TerritoryTZ ::' +startDatetimeBH);  
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setApptParamDates(): calendar end datetime in TerritoryTZ ::' +endDatetimeBH);  

        Date stDate = startDatetimeBH.DateGMT();
        Date edDate = endDatetimeBH.DateGMT();
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setApptParamDates(): for Date comparision startDate ::' +stDate);  
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setApptParamDates(): for Date comparision endDate ::' +edDate);                         

        List<DateTime> lstOfBhStEndDateTimeForStartDay = WSCH_CommonUtils.getBHStartEndDateTime(startDatetimeBH.dateGmt(),objDefTerritoryBH);
        if(lstOfBhStEndDateTimeForStartDay != null && lstOfBhStEndDateTimeForStartDay.size() == 2) {
            startDatetimeBH = WSCH_DateUtils.doTZConversion(lstOfBhStEndDateTimeForStartDay.get(0), territoryTimezone, 'GMT');
        }
        
        List<DateTime> lstOfBhStEndDateTimeForEndDay = WSCH_CommonUtils.getBHStartEndDateTime(endDatetimeBH.dateGmt(),objDefTerritoryBH);
        if(lstOfBhStEndDateTimeForEndDay != null && lstOfBhStEndDateTimeForEndDay.size() == 2) {
            endDatetimeBH = WSCH_DateUtils.doTZConversion(lstOfBhStEndDateTimeForEndDay.get(1), territoryTimezone, 'GMT');
        }        
        
        Datetime pSTStartDt = workOrderRecord.SVMXC__Preferred_Start_Time__c;
        Datetime pETEndDt = workOrderRecord.SVMXC__Preferred_End_Time__c;
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setApptParamDates(): work order PST GMT DT ::' +pSTStartDt);  
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper::setApptParamDates(): work order PET GMT DT ::' +pETEndDt);  

        if(pSTStartDt != null){
            //if((pSTStartDt == calStartDatetime) || (pSTStartDt.dateGMT()==calStartDatetime.DateGMT())){
            //We used territory TZ dates for date comparision.Due to DST with 24 hours BHz scenarios
            if((pSTStartDt == calStartDatetime) || (pSTStartDt.dateGMT()==stDate)){
                apptParam.startDateTime = pSTStartDt;               
            }else if(pSTStartDt.DateGMT() != calStartDatetime.DateGMT()){
                apptParam.startDateTime = startDatetimeBH;
            }
        }else{
            apptParam.startDateTime = startDatetimeBH;          
        }

        if(pETEndDt != null){
            //if((pETEndDt == calEndDatetime) || (pETEndDt.DateGMT()==calEndDatetime.DateGMT())){
            //We used territory TZ dates for date comparision.Due to DST with 24 hours BHz scenarios
            if((pETEndDt == calEndDatetime) || (pETEndDt.DateGMT()==edDate)){  
                apptParam.endDateTime = pETEndDt;               
            }else if(pETEndDt.DateGMT() != calEndDatetime.DateGMT()){
                apptParam.endDatetime = endDatetimeBH;              
            }
        }else{
            apptParam.endDatetime = endDatetimeBH;          
        }
    }

    public static WSCH_Provider_ECO_Stubs.InitJobRequest_WP initjobDependencyRequest(SVMXC__Territory__c objTerritory, 
                List<SVMXC__Service_Order_Dependency__c>  lstOfServiceOrderGroupDependency, List<SVMXC__Service_Order__c> lstOfAllDepWorkOrders) {
        
        WSCH_AuditLogger.debug('Inside initjobDependencyRequest()');
        //Create the wrapper for all the WOs
        WSCH_Provider_ECO_Stubs.InitJobRequest_WP initJobWorkOrderReq_WP = WSCH_Provider_ECO_DataMapper.initJobRequest(objTerritory, lstOfAllDepWorkOrders);
        List<WSCH_Provider_ECO_Stubs.WorkOrder_WP> lstWorkOrderWP = initJobWorkOrderReq_WP.workOrders;
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:initjobDependencyRequest:lstWorkOrderWP.size() - ' + lstWorkOrderWP.size());
        
        WSCH_Provider_ECO_DataMapper.constructDependencyWrapper(lstWorkOrderWP, lstOfServiceOrderGroupDependency, lstOfAllDepWorkOrders);
        
        return initJobWorkOrderReq_WP;
    }
    
    public static WSCH_Provider_ECO_Stubs.ManageWorkOrderRequest_WP manageJobDependencyRequest(SVMXC__Territory__c objTerritory, 
                List<SVMXC__Service_Order_Dependency__c>  lstOfServiceOrderGroupDependency, List<SVMXC__Service_Order__c> lstOfAllDepWorkOrders) {
        
        WSCH_AuditLogger.debug('Inside manageJobDependencyRequest()');
        //Create the wrapper for all the WOs
        WSCH_Provider_ECO_Stubs.ManageWorkOrderRequest_WP manageWorkOrderReq_WP = WSCH_Provider_ECO_DataMapper.manageJobRequest(objTerritory, lstOfAllDepWorkOrders);
        List<WSCH_Provider_ECO_Stubs.WorkOrder_WP> lstWorkOrderWP = manageWorkOrderReq_WP.workOrders;
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:manageJobDependencyRequest:lstWorkOrderWP.size() - ' + lstWorkOrderWP.size());
        
        WSCH_Provider_ECO_DataMapper.constructDependencyWrapper(lstWorkOrderWP, lstOfServiceOrderGroupDependency, lstOfAllDepWorkOrders);

        //creating the map of WOId and WO Object
        /*Map<String, SVMXC__Service_Order__c> mapOfWONameAndWOObject = new Map<String, SVMXC__Service_Order__c>();
        for(SVMXC__Service_Order__c eachWO:lstOfAllDepWorkOrders) {
            mapOfWONameAndWOObject.put(eachWO.Name,eachWO);
        }
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:manageJobDependencyRequest:mapOfWONameAndWOObject.size() - ' + mapOfWONameAndWOObject.size());
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:manageJobDependencyRequest:mapOfWONameAndWOObject - ' + mapOfWONameAndWOObject);
        
        //creating the map of WOID and WO wrapper
        Map<String, WSCH_Provider_ECO_Stubs.WorkOrder_WP> mapOfWOIdAndWOWrapper =  new Map<String, WSCH_Provider_ECO_Stubs.WorkOrder_WP>();
        for(WSCH_Provider_ECO_Stubs.WorkOrder_WP eachWorkOrderWP:lstWorkOrderWP) {
            mapOfWOIdAndWOWrapper.put(mapOfWONameAndWOObject.get(eachWorkOrderWP.workOrderId).Id, eachWorkOrderWP);
        }
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:manageJobDependencyRequest:mapOfWONameAndWOWrapper.size() - ' + mapOfWOIdAndWOWrapper.size());
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:manageJobDependencyRequest:mapOfWONameAndWOWrapper - ' + mapOfWOIdAndWOWrapper);

        

        //Iterate each dependency Relation object. Fetch the secondary WO for that dependency and fetch the corresponding
        //wrapper for that secondary WO from the wrapper map constructed above. To this seconday WO wrapper, set the PrimaryWOId
        // as the masterNodeId by fetching the PrimaryWO name from the another WO map constructed above.
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:manageJobDependencyRequest:lstOfServiceOrderGroupDependency.size() - ' + lstOfServiceOrderGroupDependency.size());
        WSCH_Provider_ECO_Stubs.Relation_WP relation_wp;
        for(SVMXC__Service_Order_Dependency__c eachWODependencyObj: lstOfServiceOrderGroupDependency) {
            if(mapOfWOIdAndWOWrapper.containsKey(eachWODependencyObj.SVMXC__Secondary_Work_Order__c)) {
                
                WSCH_Provider_ECO_Stubs.WorkOrder_WP eachWorkOrderWP = mapOfWOIdAndWOWrapper.get(eachWODependencyObj.SVMXC__Secondary_Work_Order__c);
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:manageJobDependencyRequest:eachWorkOrderWP - ' + eachWorkOrderWP);
                
                relation_wp = new WSCH_Provider_ECO_Stubs.Relation_WP();
                if(String.isNotBlank(eachWODependencyObj.SVMXC__Time_Dependency__c)) {
                    relation_wp.relationshipType = WSCH_CommonUtils.getServerTimeDepVal((eachWODependencyObj.SVMXC__Time_Dependency__c).trim()); //string
                }

                relation_wp.masterNodeId = mapOfWOIdAndWOWrapper.get(eachWODependencyObj.SVMXC__Primary_Work_Order__c).workOrderId;

                if(String.isNotBlank(eachWODependencyObj.SVMXC__Resource_Dependency__c) && eachWODependencyObj.SVMXC__Resource_Dependency__c.equalsIgnoreCase('Same Resource')) {
                    relation_wp.resourceDependencyType = 'SAMERESOURCE'; //String
                } else if(String.isNotBlank(eachWODependencyObj.SVMXC__Resource_Dependency__c) && eachWODependencyObj.SVMXC__Resource_Dependency__c.equalsIgnoreCase('Different Resource')) {
                    relation_wp.resourceDependencyType = 'DIFFERENTRESOURCE'; //String
                } else {
                    relation_wp.resourceDependencyType = 'NONE'; //String
                }
                //calculate the Maximum deviation values based on the units.
                if(String.isNotBlank(eachWODependencyObj.SVMXC__Maximum_Time_Deviation_Units__c) && 
                eachWODependencyObj.SVMXC__Maximum_Time_Deviation_Units__c.equalsIgnoreCase('Minutes')) {
                    relation_wp.maximalDeviationSec = (eachWODependencyObj.SVMXC__Maximum_Time_Deviation__c * 60).longValue(); //Double
                } else if(String.isNotBlank(eachWODependencyObj.SVMXC__Maximum_Time_Deviation_Units__c) && 
                        eachWODependencyObj.SVMXC__Maximum_Time_Deviation_Units__c.equalsIgnoreCase('Hours')) {
                        relation_wp.maximalDeviationSec = (eachWODependencyObj.SVMXC__Maximum_Time_Deviation__c * 60 * 60).longValue(); //Double
                } else if(String.isNotBlank(eachWODependencyObj.SVMXC__Maximum_Time_Deviation_Units__c) && 
                        eachWODependencyObj.SVMXC__Maximum_Time_Deviation_Units__c.equalsIgnoreCase('Days')) {
                        relation_wp.maximalDeviationSec = (eachWODependencyObj.SVMXC__Maximum_Time_Deviation__c * 24 * 60 * 60).longValue(); //Double
                }
                
                //calculate the Minimum deviation values based on the units.
                if(String.isNotBlank(eachWODependencyObj.SVMXC__Minimum_Time_Deviation_Units__c) && 
                        eachWODependencyObj.SVMXC__Minimum_Time_Deviation_Units__c.equalsIgnoreCase('Minutes')) {
                            relation_wp.minimalDeviationSec = (eachWODependencyObj.SVMXC__Minimum_Time_Deviation__c * 60).longValue(); //Double
                } else if(String.isNotBlank(eachWODependencyObj.SVMXC__Minimum_Time_Deviation_Units__c) && 
                        eachWODependencyObj.SVMXC__Minimum_Time_Deviation_Units__c.equalsIgnoreCase('Hours')) {
                            relation_wp.minimalDeviationSec = (eachWODependencyObj.SVMXC__Minimum_Time_Deviation__c * 60 * 60).longValue(); //Double
                } else if(String.isNotBlank(eachWODependencyObj.SVMXC__Minimum_Time_Deviation_Units__c) && 
                        eachWODependencyObj.SVMXC__Minimum_Time_Deviation_Units__c.equalsIgnoreCase('Days')) {
                            relation_wp.minimalDeviationSec = (eachWODependencyObj.SVMXC__Minimum_Time_Deviation__c * 24 * 60 * 60).longValue(); //Double
                }
                eachWorkOrderWP.relations.add(relation_wp);
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:manageJobDependencyRequest:eachWorkOrderWP - ' + eachWorkOrderWP);
            }
        }*/
        return manageWorkOrderReq_WP;
    }

    public static void constructDependencyWrapper(List<WSCH_Provider_ECO_Stubs.WorkOrder_WP> lstWorkOrderWP, List<SVMXC__Service_Order_Dependency__c>  lstOfServiceOrderGroupDependency, List<SVMXC__Service_Order__c> lstOfAllDepWorkOrders) {

        //creating the map of WOId and WO Object
        Map<String, SVMXC__Service_Order__c> mapOfWONameAndWOObject = new Map<String, SVMXC__Service_Order__c>();
        Map<Id, SVMXC__Service_Order__c> mapOfWOIdAndWOObject = new Map<Id, SVMXC__Service_Order__c>();
        //List<SVMXC__Service_Order_Dependency__c>  lstOfQualifiedDependencyObjects = new List<SVMXC__Service_Order_Dependency__c>();
        List<SVMXC__Service_Order__c> lstOfQualifiedDepWOs = new List<SVMXC__Service_Order__c>();
        //List<WSCH_Provider_ECO_Stubs.WorkOrder_WP> lstFilteredWorkOrderWP = new List<WSCH_Provider_ECO_Stubs.WorkOrder_WP>();

        for(SVMXC__Service_Order__c eachWO:lstOfAllDepWorkOrders) {
            mapOfWONameAndWOObject.put(eachWO.Name,eachWO);
            mapOfWOIdAndWOObject.put(eachWO.Id,eachWO);
        }
        //first check if the WO fields that are set a value in the above method is available here. 
        //If this is happening, below logic works

        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:lstOfServiceOrderGroupDependency.size() - ' + lstOfServiceOrderGroupDependency.size());
        system.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:lstOfServiceOrderGroupDependency.size() - ' + lstOfServiceOrderGroupDependency.size());

        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:mapOfWONameAndWOObject.size() - ' + mapOfWONameAndWOObject.size());
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:mapOfWONameAndWOObject - ' + mapOfWONameAndWOObject);

        //system.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:mapOfWONameAndWOObject.size() - ' + mapOfWONameAndWOObject.size());
        //system.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:mapOfWONameAndWOObject - ' + mapOfWONameAndWOObject);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:lstWorkOrderWP.size() before filtering - ' + lstWorkOrderWP.size());
        
        //creating the map of WOID and WO wrapper
        Map<String, WSCH_Provider_ECO_Stubs.WorkOrder_WP> mapOfWOIdAndWOWrapper =  new Map<String, WSCH_Provider_ECO_Stubs.WorkOrder_WP>();
        for(WSCH_Provider_ECO_Stubs.WorkOrder_WP eachWorkOrderWP:lstWorkOrderWP) {
            mapOfWOIdAndWOWrapper.put(mapOfWONameAndWOObject.get(eachWorkOrderWP.workOrderId).Id, eachWorkOrderWP);
        }

        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:lstFilteredWorkOrderWP.size() - ' + lstFilteredWorkOrderWP.size());
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:lstWorkOrderWP.size() after filtering - ' + lstWorkOrderWP.size());
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:mapOfWOIdAndWOWrapper.size() - ' + mapOfWOIdAndWOWrapper.size());
        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:mapOfWOIdAndWOWrapper - ' + mapOfWOIdAndWOWrapper);

        system.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:mapOfWOIdAndWOWrapper.size() - ' + mapOfWOIdAndWOWrapper.size());
        system.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:mapOfWOIdAndWOWrapper - ' + mapOfWOIdAndWOWrapper);

        //Iterate each dependency Relation object. Fetch the secondary WO for that dependency and fetch the corresponding
        //wrapper for that secondary WO from the wrapper map constructed above. To this seconday WO wrapper, set the PrimaryWOId
        // as the masterNodeId by fetching the PrimaryWO name from the another WO map constructed above.
        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:lstOfQualifiedDependencyObjects.size() - ' + lstOfQualifiedDependencyObjects.size());
        //system.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:lstOfQualifiedDependencyObjects.size() - ' + lstOfQualifiedDependencyObjects.size());

        WSCH_Provider_ECO_Stubs.Relation_WP relation_wp;
        for(SVMXC__Service_Order_Dependency__c eachWODependencyObj: lstOfServiceOrderGroupDependency) {
            relation_wp = new WSCH_Provider_ECO_Stubs.Relation_WP();
            //If secondary WO is present in the wrapper send the wrapper along with the Primary WO info
            if(mapOfWOIdAndWOWrapper.containsKey(eachWODependencyObj.SVMXC__Secondary_Work_Order__c)) {
                
                WSCH_Provider_ECO_Stubs.WorkOrder_WP eachWorkOrderWP = mapOfWOIdAndWOWrapper.get(eachWODependencyObj.SVMXC__Secondary_Work_Order__c);
                eachWorkOrderWP.relations.clear();
                //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:eachWorkOrderWP - ' + eachWorkOrderWP);
                //system.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:eachWorkOrderWP - ' + eachWorkOrderWP);
                
                //relation_wp = new WSCH_Provider_ECO_Stubs.Relation_WP();
                if(String.isNotBlank(eachWODependencyObj.SVMXC__Time_Dependency__c)) {
                    relation_wp.relationshipType = WSCH_CommonUtils.getServerTimeDepVal((eachWODependencyObj.SVMXC__Time_Dependency__c).trim()); //string
                }
                //if primary WO is also part of the WO Wrapper then it is not skipped
                if(mapOfWOIdAndWOWrapper.containsKey(eachWODependencyObj.SVMXC__Primary_Work_Order__c)) {
                    relation_wp.masterNodeId = mapOfWOIdAndWOWrapper.get(eachWODependencyObj.SVMXC__Primary_Work_Order__c).workOrderId;
                }
                //Primary WO is skipped or already present in server. Hence it is not present in the wrapper. Get the WO name from a diff map
                else {
                    relation_wp.masterNodeId = mapOfWOIdAndWOObject.get(eachWODependencyObj.SVMXC__Primary_Work_Order__c).Name;
                }

                if(String.isNotBlank(eachWODependencyObj.SVMXC__Resource_Dependency__c) && eachWODependencyObj.SVMXC__Resource_Dependency__c.equalsIgnoreCase('Same Resource')) {
                    relation_wp.resourceDependencyType = 'SAMERESOURCE'; //String
                } else if(String.isNotBlank(eachWODependencyObj.SVMXC__Resource_Dependency__c) && eachWODependencyObj.SVMXC__Resource_Dependency__c.equalsIgnoreCase('Different Resource')) {
                    relation_wp.resourceDependencyType = 'DIFFERENTRESOURCE'; //String
                } else {
                    relation_wp.resourceDependencyType = 'NONE'; //String
                }
                //calculate the Maximum deviation values based on the units.
                if(String.isNotBlank(eachWODependencyObj.SVMXC__Maximum_Time_Deviation_Units__c) && 
                eachWODependencyObj.SVMXC__Maximum_Time_Deviation_Units__c.equalsIgnoreCase('Minutes')) {
                    relation_wp.maximalDeviationSec = (eachWODependencyObj.SVMXC__Maximum_Time_Deviation__c * 60).longValue(); //Double
                } else if(String.isNotBlank(eachWODependencyObj.SVMXC__Maximum_Time_Deviation_Units__c) && 
                        eachWODependencyObj.SVMXC__Maximum_Time_Deviation_Units__c.equalsIgnoreCase('Hours')) {
                        relation_wp.maximalDeviationSec = (eachWODependencyObj.SVMXC__Maximum_Time_Deviation__c * 60 * 60).longValue(); //Double
                } else if(String.isNotBlank(eachWODependencyObj.SVMXC__Maximum_Time_Deviation_Units__c) && 
                        eachWODependencyObj.SVMXC__Maximum_Time_Deviation_Units__c.equalsIgnoreCase('Days')) {
                        relation_wp.maximalDeviationSec = (eachWODependencyObj.SVMXC__Maximum_Time_Deviation__c * 24 * 60 * 60).longValue(); //Double
                }
                //calculate the Minimum deviation values based on the units.
                if(String.isNotBlank(eachWODependencyObj.SVMXC__Minimum_Time_Deviation_Units__c) && 
                        eachWODependencyObj.SVMXC__Minimum_Time_Deviation_Units__c.equalsIgnoreCase('Minutes')) {
                            relation_wp.minimalDeviationSec = (eachWODependencyObj.SVMXC__Minimum_Time_Deviation__c * 60).longValue(); //Double
                } else if(String.isNotBlank(eachWODependencyObj.SVMXC__Minimum_Time_Deviation_Units__c) && 
                        eachWODependencyObj.SVMXC__Minimum_Time_Deviation_Units__c.equalsIgnoreCase('Hours')) {
                            relation_wp.minimalDeviationSec = (eachWODependencyObj.SVMXC__Minimum_Time_Deviation__c * 60 * 60).longValue(); //Double
                } else if(String.isNotBlank(eachWODependencyObj.SVMXC__Minimum_Time_Deviation_Units__c) && 
                        eachWODependencyObj.SVMXC__Minimum_Time_Deviation_Units__c.equalsIgnoreCase('Days')) {
                            relation_wp.minimalDeviationSec = (eachWODependencyObj.SVMXC__Minimum_Time_Deviation__c * 24 * 60 * 60).longValue(); //Double
                }
                eachWorkOrderWP.relations.add(relation_wp);
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:eachWorkOrderWP - ' + eachWorkOrderWP);
            }
        }
    }

    /*public static void constructDependencyWrapper(List<WSCH_Provider_ECO_Stubs.WorkOrder_WP> lstWorkOrderWP, List<SVMXC__Service_Order_Dependency__c>  lstOfServiceOrderGroupDependency, List<SVMXC__Service_Order__c> lstOfAllDepWorkOrders) {

        //creating the map of WOId and WO Object
        Map<String, SVMXC__Service_Order__c> mapOfWONameAndWOObject = new Map<String, SVMXC__Service_Order__c>();
        Map<Id, SVMXC__Service_Order__c> mapOfWOIdAndWOObject = new Map<Id, SVMXC__Service_Order__c>();
        List<SVMXC__Service_Order_Dependency__c>  lstOfQualifiedDependencyObjects = new List<SVMXC__Service_Order_Dependency__c>();
        List<SVMXC__Service_Order__c> lstOfQualifiedDepWOs = new List<SVMXC__Service_Order__c>();
        //List<WSCH_Provider_ECO_Stubs.WorkOrder_WP> lstFilteredWorkOrderWP = new List<WSCH_Provider_ECO_Stubs.WorkOrder_WP>();

        for(SVMXC__Service_Order__c eachWO:lstOfAllDepWorkOrders) {
            mapOfWONameAndWOObject.put(eachWO.Name,eachWO);
            mapOfWOIdAndWOObject.put(eachWO.Id,eachWO);
        }
        //first check if the WO fields that are set a value in the above method is available here. 
        //If this is happening, below logic works

        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:lstOfServiceOrderGroupDependency.size() - ' + lstOfServiceOrderGroupDependency.size());
        system.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:lstOfServiceOrderGroupDependency.size() - ' + lstOfServiceOrderGroupDependency.size());

        //iterate all the dependency objects. for each dependency object, use the above mapOfWOIdAndWOObject
        //get the wo Object for the primaryWO and the SecondaryWO. Check if the optimax_status of the primary WO is OPT_SKIPPED.
        //if so then set the same status for the secondaryWO along with appropriate error msg.
        //remove this dependency Object from the main dependencyList and use this list below. Also remove these WOs also from
        //the WO list.

        for(SVMXC__Service_Order_Dependency__c eachDependencyObj: lstOfServiceOrderGroupDependency) {
            //get the PrimaryWO and check if its status is already marked as OPT_SKIPPED.
            //if so, then mark the secondaryWO also as OPT_SKIPPED and update the error message appropriately
            SVMXC__Service_Order__c depPrimaryWO = mapOfWOIdAndWOObject.get(eachDependencyObj.SVMXC__Primary_Work_Order__c);
            SVMXC__Service_Order__c depSecondaryWO = mapOfWOIdAndWOObject.get(eachDependencyObj.SVMXC__Secondary_Work_Order__c);
            if(depPrimaryWO.SVMXC__OptiMax_Status__c.equalsIgnoreCase('OPT_SKIPPED')) {
                depSecondaryWO.SVMXC__OptiMax_Status__c = 'OPT_SKIPPED';
                depSecondaryWO.SVMXC__OptiMax_Error_Text__c = 'Skipping this secondary WO also from dependency booking as its primary WO, ' + depPrimaryWO.Name + ' is skipped for being out of the horizon';
            } else {
                //create a filtered listOfDependencyObjects and lstOfQualifiedDepWOs after skipping the primary and secondary WOs
                lstOfQualifiedDependencyObjects.add(eachDependencyObj);
                lstOfQualifiedDepWOs.add(depPrimaryWO);
                lstOfQualifiedDepWOs.add(depSecondaryWO);
            }
        }
        
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:mapOfWONameAndWOObject.size() - ' + mapOfWONameAndWOObject.size());
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:mapOfWONameAndWOObject - ' + mapOfWONameAndWOObject);

        system.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:mapOfWONameAndWOObject.size() - ' + mapOfWONameAndWOObject.size());
        system.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:mapOfWONameAndWOObject - ' + mapOfWONameAndWOObject);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:lstWorkOrderWP.size() before filtering - ' + lstWorkOrderWP.size());
        
        //creating the map of WOID and WO wrapper
        Map<String, WSCH_Provider_ECO_Stubs.WorkOrder_WP> mapOfWOIdAndWOWrapper =  new Map<String, WSCH_Provider_ECO_Stubs.WorkOrder_WP>();
        //for(WSCH_Provider_ECO_Stubs.WorkOrder_WP eachWorkOrderWP:lstWorkOrderWP) {
            //remove the wrapper for the secondaryWO, if primaryWO is already skipped. Use the above filteredList
            //to find if the secondaryWO is also skipped.
            //if the filteredList does not contain this secondaryWO, then ignore this WO from the wrapper
            //else create a filteredWrapperList with qualified WOs.
        //    if(!lstOfQualifiedDepWOs.contains(mapOfWONameAndWOObject.get(eachWorkOrderWP.workOrderId))) {
        //        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:removed the wrapper for the WO - ' + mapOfWONameAndWOObject.get(eachWorkOrderWP.workOrderId).Name);
        //    } else {
        //        lstFilteredWorkOrderWP.add(eachWorkOrderWP);
        //        mapOfWOIdAndWOWrapper.put(mapOfWONameAndWOObject.get(eachWorkOrderWP.workOrderId).Id, eachWorkOrderWP);
        //    }
        //}

        for(Integer i= lstWorkOrderWP.size()-1; i>=0; i--) {
            //remove the wrapper for the secondaryWO, if primaryWO is already skipped. Use the above filtered List
            //lstOfQualifiedDepWOs to find if the secondaryWO is also skipped.
            //if the lstOfQualifiedDepWOs does not contain this secondaryWO, then remove this WO from the wrapper
            if(!lstOfQualifiedDepWOs.contains(mapOfWONameAndWOObject.get(lstWorkOrderWP.get(i).workOrderId))) {
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:removed the wrapper for the WO - ' + mapOfWONameAndWOObject.get(lstWorkOrderWP.get(i).workOrderId).Name);
                lstWorkOrderWP.remove(i);
            } else {
                //creating the map of WOID and WO wrapper
                mapOfWOIdAndWOWrapper.put(mapOfWONameAndWOObject.get(lstWorkOrderWP.get(i).workOrderId).Id, lstWorkOrderWP.get(i));
            }
        }

        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:lstFilteredWorkOrderWP.size() - ' + lstFilteredWorkOrderWP.size());
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:lstWorkOrderWP.size() after filtering - ' + lstWorkOrderWP.size());
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:mapOfWOIdAndWOWrapper.size() - ' + mapOfWOIdAndWOWrapper.size());
        //WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:mapOfWOIdAndWOWrapper - ' + mapOfWOIdAndWOWrapper);

        system.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:mapOfWOIdAndWOWrapper.size() - ' + mapOfWOIdAndWOWrapper.size());
        system.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:mapOfWOIdAndWOWrapper - ' + mapOfWOIdAndWOWrapper);

        //Iterate each dependency Relation object. Fetch the secondary WO for that dependency and fetch the corresponding
        //wrapper for that secondary WO from the wrapper map constructed above. To this seconday WO wrapper, set the PrimaryWOId
        // as the masterNodeId by fetching the PrimaryWO name from the another WO map constructed above.
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:lstOfQualifiedDependencyObjects.size() - ' + lstOfQualifiedDependencyObjects.size());
        system.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:lstOfQualifiedDependencyObjects.size() - ' + lstOfQualifiedDependencyObjects.size());

        WSCH_Provider_ECO_Stubs.Relation_WP relation_wp;
        for(SVMXC__Service_Order_Dependency__c eachWODependencyObj: lstOfQualifiedDependencyObjects) {
            if(mapOfWOIdAndWOWrapper.containsKey(eachWODependencyObj.SVMXC__Secondary_Work_Order__c)) {
                
                WSCH_Provider_ECO_Stubs.WorkOrder_WP eachWorkOrderWP = mapOfWOIdAndWOWrapper.get(eachWODependencyObj.SVMXC__Secondary_Work_Order__c);
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:eachWorkOrderWP - ' + eachWorkOrderWP);
                system.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:eachWorkOrderWP - ' + eachWorkOrderWP);
                
                relation_wp = new WSCH_Provider_ECO_Stubs.Relation_WP();
                if(String.isNotBlank(eachWODependencyObj.SVMXC__Time_Dependency__c)) {
                    relation_wp.relationshipType = WSCH_CommonUtils.getServerTimeDepVal((eachWODependencyObj.SVMXC__Time_Dependency__c).trim()); //string
                }

                relation_wp.masterNodeId = mapOfWOIdAndWOWrapper.get(eachWODependencyObj.SVMXC__Primary_Work_Order__c).workOrderId;

                if(String.isNotBlank(eachWODependencyObj.SVMXC__Resource_Dependency__c) && eachWODependencyObj.SVMXC__Resource_Dependency__c.equalsIgnoreCase('Same Resource')) {
                    relation_wp.resourceDependencyType = 'SAMERESOURCE'; //String
                } else if(String.isNotBlank(eachWODependencyObj.SVMXC__Resource_Dependency__c) && eachWODependencyObj.SVMXC__Resource_Dependency__c.equalsIgnoreCase('Different Resource')) {
                    relation_wp.resourceDependencyType = 'DIFFERENTRESOURCE'; //String
                } else {
                    relation_wp.resourceDependencyType = 'NONE'; //String
                }
                //calculate the Maximum deviation values based on the units.
                if(String.isNotBlank(eachWODependencyObj.SVMXC__Maximum_Time_Deviation_Units__c) && 
                eachWODependencyObj.SVMXC__Maximum_Time_Deviation_Units__c.equalsIgnoreCase('Minutes')) {
                    relation_wp.maximalDeviationSec = (eachWODependencyObj.SVMXC__Maximum_Time_Deviation__c * 60).longValue(); //Double
                } else if(String.isNotBlank(eachWODependencyObj.SVMXC__Maximum_Time_Deviation_Units__c) && 
                        eachWODependencyObj.SVMXC__Maximum_Time_Deviation_Units__c.equalsIgnoreCase('Hours')) {
                        relation_wp.maximalDeviationSec = (eachWODependencyObj.SVMXC__Maximum_Time_Deviation__c * 60 * 60).longValue(); //Double
                } else if(String.isNotBlank(eachWODependencyObj.SVMXC__Maximum_Time_Deviation_Units__c) && 
                        eachWODependencyObj.SVMXC__Maximum_Time_Deviation_Units__c.equalsIgnoreCase('Days')) {
                        relation_wp.maximalDeviationSec = (eachWODependencyObj.SVMXC__Maximum_Time_Deviation__c * 24 * 60 * 60).longValue(); //Double
                }
                
                //calculate the Minimum deviation values based on the units.
                if(String.isNotBlank(eachWODependencyObj.SVMXC__Minimum_Time_Deviation_Units__c) && 
                        eachWODependencyObj.SVMXC__Minimum_Time_Deviation_Units__c.equalsIgnoreCase('Minutes')) {
                            relation_wp.minimalDeviationSec = (eachWODependencyObj.SVMXC__Minimum_Time_Deviation__c * 60).longValue(); //Double
                } else if(String.isNotBlank(eachWODependencyObj.SVMXC__Minimum_Time_Deviation_Units__c) && 
                        eachWODependencyObj.SVMXC__Minimum_Time_Deviation_Units__c.equalsIgnoreCase('Hours')) {
                            relation_wp.minimalDeviationSec = (eachWODependencyObj.SVMXC__Minimum_Time_Deviation__c * 60 * 60).longValue(); //Double
                } else if(String.isNotBlank(eachWODependencyObj.SVMXC__Minimum_Time_Deviation_Units__c) && 
                        eachWODependencyObj.SVMXC__Minimum_Time_Deviation_Units__c.equalsIgnoreCase('Days')) {
                            relation_wp.minimalDeviationSec = (eachWODependencyObj.SVMXC__Minimum_Time_Deviation__c * 24 * 60 * 60).longValue(); //Double
                }
                eachWorkOrderWP.relations.add(relation_wp);
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_DataMapper:constructDependencyWrapper:eachWorkOrderWP - ' + eachWorkOrderWP);
            }
        }
    }*/
    
    //Get eventId from the optimizer records
    public static Map<String, String> getEventId(List<SVMXC__Service_Order__c> workOrders){
        list<SVMXC__SVMX_Optimizer__c> lstOptimizerRcrd = new list<SVMXC__SVMX_Optimizer__c> ();  
        if(workOrders != null && workOrders.size() > 0){
            lstOptimizerRcrd = [Select id,  SVMXC__SM_Work_Order__c, SVMXC__WhatId__c  from SVMXC__SVMX_Optimizer__c  where SVMXC__SM_Work_Order__c in: workOrders and SVMXC__WhatType__c = 'NON_WO_EVENT'];
        } 
        Map<String, String> mapWoIdEventId = new Map<String, String>();
        for(SVMXC__SVMX_Optimizer__c optRcrd : lstOptimizerRcrd){
            mapWoIdEventId.put(optRcrd.SVMXC__SM_Work_Order__c, optRcrd.SVMXC__WhatId__c.split('_')[0]);
        }
        return mapWoIdEventId;
    }
    
      
}