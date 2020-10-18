public with sharing class WSCH_LTP_StageService_Handler {

    
    public static Map<String, BusinessHours> mapBusinessHours = new Map<String, BusinessHours>();
    public static BusinessHours objDefTerritoryBH;
    public static set<Date> setSchedHorizDates= new set<Date>();
    public static DateTime dtmSchedulingHorizonStartDateTime;
    public static Datetime dtmSchedulingHorizonEndDateTime;
    public static Integer intNoOfDays=0;
    public static String strDefaultBHourId;

    public static DCON_Utils dcUtils = new DCON_Utils();
    

    //  Querying the default business hour  
    public static void initializeBussHr(SVMXC__Territory__c objTerritory) {
        WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::initializeDefaultBussHr(): start');
        try{
            // Condition to load only default business hours or those in territory time zone
            String territoryTZsidKey = objTerritory.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey;
        // Get the list of all the active Business Hours and put them in a map.
        List<BusinessHours> lstBusinessHours = new List<BusinessHours>();
        lstBusinessHours = [Select Id, Name, IsDefault, IsActive, TimeZoneSidKey, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
                            ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime
                            from BusinessHours
                            where IsActive = TRUE AND (IsDefault = TRUE OR TimeZoneSidKey = :territoryTZsidKey)];
        lstBusinessHours = getCompleteBusinessHours(lstBusinessHours);
        for(BusinessHours bh : lstBusinessHours)
        {
            mapBusinessHours.put(bh.Id, bh);
            if(bh.IsDefault == TRUE)
                strDefaultBHourId = bh.Id;
                 
        }
       
        //Heap size issue
        lstBusinessHours.clear();
        WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::initializeBussHr(): end');
       
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_LTP_StageService_Handler :: initializeBussHr :: ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }

    public static WSCH_LTP_Scheduling_Stubs.SchedulingInputResponse_WP doPrepareWorkOrderWP(List<String> woNames, SVMXC__SVMX_Jobs__c objSVMXJob){
        WSCH_LTP_Scheduling_Stubs.SchedulingInputResponse_WP workOrderResponse = new WSCH_LTP_Scheduling_Stubs.SchedulingInputResponse_WP();
        List<WSCH_LTP_Scheduling_Stubs.WorkOrder_WP> lstWorkOrderWP = new List<WSCH_LTP_Scheduling_Stubs.WorkOrder_WP>();
        
        List<SVMXC__Service_Order__c> lstWorkOrder = WSCH_ECO_CommonUtils.fetchWorkOrdersByName(woNames);
        WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::doPrepareWorkOrderWP::lstWorkOrder size:'+lstWorkOrder.size());
        String strTerritoryId;
        String strDPId;
        try{
            if(lstWorkOrder != null && lstWorkOrder.size() > 0 ){
                strDPId = lstWorkOrder[0].SVMXC__Dispatch_Process__c;
                strTerritoryId = lstWorkOrder[0].SVMXC__Primary_Territory__c;
            }       
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::doPrepareWorkOrderWP::Dispatch Process | TerritoryId:-'+strDPId+' | '+strTerritoryId);
            
            SVMXC__Territory__c objTerritory = [Select Id, SVMXC__Territory_s_Business_Hours__c, SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey, SVMXC__Territory_s_Business_Hours__r.Id, SVMXC__Break_Hours__c, SVMXC__Average_Driving_Time__c, SVMXC__Per_Mile_Cost__c,
                            SVMXC__Max_Distance__c, SVMXC__Average_Speed__c, SVMXC__Fixed_Cost__c, SVMXC__Per_hour_Cost__c, SVMXC__Mode_Of_Travel__c,SVMXC__SM_Overnight_Stay_Policy__c
                            from SVMXC__Territory__c
                            where Id = :strTerritoryId];
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::doPrepareWorkOrderWP::objTerritory:'+objTerritory);
            //setting work order details
            initializeBussHr(objTerritory);
            lstWorkOrderWP = getWorkOrdersDetails(objTerritory, lstWorkOrder, objSVMXJob.SVMXC__Type__c); 
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::doPrepareWorkOrderWP::lstWorkOrderWP :'+lstWorkOrderWP.size());
            workOrderResponse.workOrders = lstWorkOrderWP;
            //WSCH_AuditLogger.finish();
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_LTP_StageService_Handler::doPrepareWorkOrderWP:Exception occured..'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());         
            WSCH_AuditLogger.finish();
        }
        return workOrderResponse; 
    }

    public static WSCH_LTP_Scheduling_Stubs.SchedulingInputResponse_WP doPrepareTechnicianWP(List<String> techIds, SVMXC__SVMX_Jobs__c objSVMXJob){
        WSCH_LTP_Scheduling_Stubs.SchedulingInputResponse_WP technicianResponse = new WSCH_LTP_Scheduling_Stubs.SchedulingInputResponse_WP();
        Set<String> lstTechIds = new Set<String>();
        List<SVMXC__Service_Group_Members__c> lstTechnicians = new List<SVMXC__Service_Group_Members__c>();
        String strTerritoryId;
        SVMXC__Territory__c objTerritory = new SVMXC__Territory__c();
        SVMXC__SVMX_Jobs__c objJob = new SVMXC__SVMX_Jobs__c();
        //String strDPId;
        SVMXC__ServiceMax_Processes__c objSVMXProcess = new SVMXC__ServiceMax_Processes__c();
        try{
            for(String techNameId : techIds){
                list<String> lstTempId = techNameId.split('_');
                String techId = lstTempId[0].trim();
                lstTechIds.add(techId);
            }
            // Retrieve technician records from Service_Group_Members__c for the given tech ID
            lstTechnicians = [Select Id, Name, SVMXC__Service_Territory__c, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey, SVMXC__Service_Territory__r.SVMXC__Per_Mile_Cost__c,
                    SVMXC__Service_Territory__r.SVMXC__Per_Hour_Cost__c, SVMXC__Service_Territory__r.SVMXC__Fixed_Cost__c, SVMXC__Service_Territory__r.SVMXC__Max_Hours__c,
                    SVMXC__Service_Territory__r.SVMXC__Average_Speed__c, SVMXC__Service_Territory__r.SVMXC__Max_Daily_Hours__c, SVMXC__Max_Hours__c,
                    SVMXC__Service_Territory__r.SVMXC__Max_Distance__c, 
                    SVMXC__Salesforce_User__c, SVMXC__Salesforce_User__r.IsActive, SVMXC__Fixed_Cost__c, SVMXC__Latitude_Home__c, SVMXC__Longitude_Home__c, SVMXC__Per_hour_Cost__c,
                    SVMXC__Per_Mile_Cost__c, SVMXC__Average_Speed__c, SVMXC__Max_Daily_Hours__c, SVMXC__Max_Distance__c,
                    SVMXC__Working_Hours__c ,
                    SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Zip__c, SVMXC__Country__c , SVMXC__Break_Hours__c, SVMXC__Enable_Scheduling__c
                    from SVMXC__Service_Group_Members__c 
                    where Id =: lstTechIds AND SVMXC__Active__c = TRUE];
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::doPrepareTechnicianWP():lstTechnicians size ..'+lstTechnicians.size());
            strTerritoryId = lstTechnicians[0].SVMXC__Service_Territory__c;
            
            //get territory from technician.
            objTerritory = [Select Id, SVMXC__Territory_s_Business_Hours__c, SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey, SVMXC__Territory_s_Business_Hours__r.Id, SVMXC__Break_Hours__c, SVMXC__Average_Driving_Time__c, SVMXC__Per_Mile_Cost__c,
                            SVMXC__Max_Distance__c, SVMXC__Average_Speed__c, SVMXC__Fixed_Cost__c, SVMXC__Per_hour_Cost__c, SVMXC__Mode_Of_Travel__c,SVMXC__SM_Overnight_Stay_Policy__c
                            from SVMXC__Territory__c
                            where Id = :strTerritoryId];
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::doPrepareTechnicianWP::objTerritory:'+objTerritory);
    
            initializeBussHr(objTerritory);
    
            /*objJob = [Select Id, SVMXC__Status__c, SVMXC__Age__c, SVMXC__Start_Time__c, SVMXC__End_Time__c, SVMXC__SVMX_Process__c,
                        SVMXC__Territory__c from SVMXC__SVMX_Jobs__c where SVMXC__Territory__c = :strTerritoryId AND SVMXC__Type__c =:WSCH_ECO_Constants.SVMXJOB_LTP_TYPE limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::doPrepareTechnicianWP::objJob:'+objJob);*/
            
            //strDPId = objSVMXJob.SVMXC__SVMX_Process__c;
    
            objSVMXProcess = [Select Id, SVMXC__Child_Object_Criteria__c, SVMXC__Frequency__c, SVMXC__Full_Run_Unit__c, SVMXC__Retain_Appointment__c,
                            SVMXC__Retain_Assignment__c, SVMXC__Route_Type__c, SVMXC__Weight_Time_Window__c, SVMXC__Weight_Total_Distance__c, SVMXC__Weight_Route_Distance__c,
                            SVMXC__Weight_Node_Type__c, SVMXC__Calendar_Start_Type__c, SVMXC__Calendar_End_Type__c, 
                            SVMXC__Weight_Route_Time__c,
                            SVMXC__Tolerance__c, SVMXC__Calendar_Start_Days__c, SVMXC__Calendar_End_Days__c, SVMXC__Preferred_Tech_Enabled__c, SVMXC__Expertise_Match_Enabled__c,
                            SVMXC__Product_Match_Enabled__c, SVMXC__SM_Drive_Before_Shift_Start__c, SVMXC__SM_Drive_After_Shift_End__c, SVMXC__Optimization_Goal__c,SVMXC__Window_Height__c,SVMXC__Window_Width__c, SVMXC__Dispatch_Method__c
                            from SVMXC__ServiceMax_Processes__c
                            where Id =:objSVMXJob.SVMXC__SVMX_Process__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::doPrepareTechnicianWP::objSVMXProcess:'+objSVMXProcess);
    
            objDefTerritoryBH = mapBusinessHours.get(objTerritory.SVMXC__Territory_s_Business_Hours__c);
            //setSchedHorizDates = WSCH_LTP_Initiate_Service.doCreateLTPHorizon(objSVMXProcess,objDefTerritoryBH,dtmSchedulingHorizonStartDateTime,dtmSchedulingHorizonEndDateTime);
            Map<String, list<Date>> mapHorizonDetails = new Map<String, list<Date>>();
            if(objSVMXJob.SVMXC__Type__c.equalsIgnoreCase('LTP')){
                mapHorizonDetails = WSCH_LTP_Initiate_Service.doCreateLTPHorizon(objSVMXProcess,objDefTerritoryBH);
            }else if(objSVMXJob.SVMXC__Type__c.equalsIgnoreCase('FULL')){
                mapHorizonDetails = WSCH_LTP_Initiate_Service.doCreateBatchHorizon(objSVMXProcess,objDefTerritoryBH);
            }
            //mapHorizonDetails = WSCH_LTP_Initiate_Service.doCreateLTPHorizon(objSVMXProcess,objDefTerritoryBH);
            List<Date> lstSchedHorizDates = new List<Date>();
            setSchedHorizDates.addAll(mapHorizonDetails.values()[0]);
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::doPrepareTechnicianWP::setSchedHorizDates size:'+setSchedHorizDates.size());
    
            //intNoOfDays = datStartDate.daysBetween(datEndDate) + 1;
            intNoOfDays = 360;
                    
            //get tech availabilty window
            Map<id, Map<date, list<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>>> mapTechAvailability = new Map<id, Map<date, list<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>>>();
            mapTechAvailability = getTechnicianTimeWindows(setSchedHorizDates,mapBusinessHours, lstTechnicians, objSVMXProcess);
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::doPrepareTechnicianWP():mapTechAvailability size ..'+mapTechAvailability.size());
    
            //Create Technician Wrapper
            List<WSCH_LTP_Scheduling_Stubs.Technician_WP> resources = doBuildResourceWrapper(lstTechnicians,mapTechAvailability,objTerritory,objSVMXProcess);      
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::doPrepareTechnicianWP():resources size ..'+resources.size());
            technicianResponse.resources = resources;
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_LTP_StageService_Handler::doPrepareTechnicianWP():Exception occured..'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());         
            WSCH_AuditLogger.finish();          
        }

        return technicianResponse;
    }

    public static WSCH_LTP_Scheduling_Stubs.SchedulingInputResponse_WP doPrepareTechnicianEventWP(List<String> techEventIds, SVMXC__SVMX_Jobs__c objSVMXJob){
        WSCH_LTP_Scheduling_Stubs.SchedulingInputResponse_WP technicianEventResponse = new WSCH_LTP_Scheduling_Stubs.SchedulingInputResponse_WP();
        List<WSCH_LTP_Scheduling_Stubs.TechniciansEvent_WP> lstTechEventWP = new List<WSCH_LTP_Scheduling_Stubs.TechniciansEvent_WP>();
        String strSfEventKeyPrefix;
        String strSvmxEventKeyPrefix;
        set<String> setSFEventIds = new set<String>();
        set<String> setSVMXEVentIds = new set<String>();
        String strTerritoryId;
        SVMXC__ServiceMax_Processes__c objSVMXProcess = new SVMXC__ServiceMax_Processes__c();
        Map<Id, Event> mapSFEvent = new Map<Id, Event>();
        Map<Id, SVMXC__SVMX_Event__c> mapSVMXEvent = new Map<Id, SVMXC__SVMX_Event__c>();
        List<SVMXC__Service_Group_Members__c> lstTech = new List<SVMXC__Service_Group_Members__c>();
        SVMXC__Territory__c objTerritory = new SVMXC__Territory__c();
        SVMXC__SVMX_Jobs__c objJob = new SVMXC__SVMX_Jobs__c();         
        String strDPId;
        //based on the prefix query corresponding events.
        // Get the key prefix for Salesforce Events
        Map<String, Schema.SObjectType> descAllObjs = Schema.getGlobalDescribe();
        Schema.Describesobjectresult descEventObj = descAllObjs.get('Event').getDescribe();
        strSfEventKeyPrefix = descEventObj.getKeyPrefix();
        set<String> setTechIds = new set<String>();

        // Get the key prefix for ServiceMax Events
        Schema.Describesobjectresult descSvmxEventsObj;
        if (descAllObjs.containsKey('SVMXC__SVMX_Event__c') == TRUE)
            descSvmxEventsObj = descAllObjs.get('SVMXC__SVMX_Event__c').getDescribe();
        else
            descSvmxEventsObj = descAllObjs.get('SVMX_Event__c').getDescribe();
        strSvmxEventKeyPrefix = descSvmxEventsObj.getKeyPrefix();
        
        try{
            for(String strFullEventId : techEventIds){
                String strEventId = strFullEventId.split('_')[2];
                String strTechId = strFullEventId.split('_')[1];
                setTechIds.add(strTechId);
                
                if(strEventId.startsWith(strSfEventKeyPrefix))
                    setSFEventIds.add(strEventId);
                else
                    setSVMXEVentIds.add(strEventId);
            }

            //Retrieve technician       
            //Retrieve technician events and collect non workorder events
            if(setSFEventIds != null && setSFEventIds.size() > 0 )
                mapSFEvent = getMapNonWOSFEvents(setSFEventIds);
            
            if(setSVMXEVentIds != null && setSVMXEVentIds.size() > 0 )
                mapSVMXEvent = getMapNonWOSVMXEvents(setSVMXEVentIds);
    
            List<SVMXC__Service_Group_Members__c> lstTechnicians = [Select Id, Name, SVMXC__Service_Territory__c, SVMXC__Salesforce_User__c, SVMXC__Salesforce_User__r.IsActive, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey from SVMXC__Service_Group_Members__c 
                    where Id in : setTechIds];
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::initJobRequest():lstTechnicians size ..'+lstTechnicians.size());
    
            strTerritoryId = lstTechnicians[0].SVMXC__Service_Territory__c;   
            
            //get territory from technician.
            objTerritory = [Select Id, SVMXC__Territory_s_Business_Hours__c, SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey, SVMXC__Territory_s_Business_Hours__r.Id, SVMXC__Break_Hours__c, SVMXC__Average_Driving_Time__c, SVMXC__Per_Mile_Cost__c,
                            SVMXC__Max_Distance__c, SVMXC__Average_Speed__c, SVMXC__Fixed_Cost__c, SVMXC__Per_hour_Cost__c, SVMXC__Mode_Of_Travel__c,SVMXC__SM_Overnight_Stay_Policy__c
                            from SVMXC__Territory__c
                            where Id = :strTerritoryId];
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::doPrepareTechnicianEventWP::objTerritory:'+objTerritory);
            initializeBussHr(objTerritory);                         
            strDPId = objSVMXJob.SVMXC__SVMX_Process__c;    
            
            objSVMXProcess = [Select Id, SVMXC__Child_Object_Criteria__c, SVMXC__Frequency__c, SVMXC__Full_Run_Unit__c, SVMXC__Retain_Appointment__c,
                            SVMXC__Retain_Assignment__c, SVMXC__Route_Type__c, SVMXC__Weight_Time_Window__c, SVMXC__Weight_Total_Distance__c, SVMXC__Weight_Route_Distance__c,
                            SVMXC__Weight_Node_Type__c, SVMXC__Calendar_Start_Type__c, SVMXC__Calendar_End_Type__c, 
                            SVMXC__Weight_Route_Time__c,
                            SVMXC__Tolerance__c, SVMXC__Calendar_Start_Days__c, SVMXC__Calendar_End_Days__c, SVMXC__Preferred_Tech_Enabled__c, SVMXC__Expertise_Match_Enabled__c,
                            SVMXC__Product_Match_Enabled__c, SVMXC__SM_Drive_Before_Shift_Start__c, SVMXC__SM_Drive_After_Shift_End__c, SVMXC__Optimization_Goal__c,SVMXC__Window_Height__c,SVMXC__Window_Width__c
                            from SVMXC__ServiceMax_Processes__c
                            where Id =:objSVMXJob.SVMXC__SVMX_Process__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::doPrepareTechnicianEventWP::objSVMXProcess:'+objSVMXProcess);
    
            objDefTerritoryBH = mapBusinessHours.get(objTerritory.SVMXC__Territory_s_Business_Hours__c);
            //setSchedHorizDates = WSCH_LTP_Initiate_Service.doCreateLTPHorizon(objSVMXProcess,objDefTerritoryBH,dtmSchedulingHorizonStartDateTime,dtmSchedulingHorizonEndDateTime);
            Map<String, list<Date>> mapHorizonDetails = new Map<String, list<Date>>();
            
            if(objSVMXJob.SVMXC__Type__c.equalsIgnoreCase('LTP')){
                mapHorizonDetails = WSCH_LTP_Initiate_Service.doCreateLTPHorizon(objSVMXProcess,objDefTerritoryBH);
            }else if(objSVMXJob.SVMXC__Type__c.equalsIgnoreCase('FULL')){
                mapHorizonDetails = WSCH_LTP_Initiate_Service.doCreateBatchHorizon(objSVMXProcess,objDefTerritoryBH);
            }
    
            //mapHorizonDetails = WSCH_LTP_Initiate_Service.doCreateLTPHorizon(objSVMXProcess,objDefTerritoryBH);
            List<Date> lstSchedHorizDates = new List<Date>();
            setSchedHorizDates.addAll(mapHorizonDetails.values()[0]);
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::doPrepareTechnicianEventWP()::setSchedHorizDates size:'+setSchedHorizDates.size());
    
            lstTechEventWP = doBuildResourceEventWrapper(lstTechnicians,setSchedHorizDates, mapBusinessHours, mapSFEvent,mapSVMXEvent,objDefTerritoryBH, strDPId);
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::doPrepareTechnicianEventWP():lstTechEventWP size ..'+lstTechEventWP.size());
            technicianEventResponse.events = lstTechEventWP;
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_LTP_StageService_Handler::doPrepareTechnicianEventWP():Exception occured..'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());         
            WSCH_AuditLogger.finish();          
        }
        return technicianEventResponse;
    }
    
    
    public static List<WSCH_LTP_Scheduling_Stubs.WorkOrder_WP> getWorkOrdersDetails(SVMXC__Territory__c objTerritory, List<SVMXC__Service_Order__c> workOrders, String strJobType) {
        WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getWorkOrdersDetails():workOrders size..'+workOrders.size());
        List<WSCH_LTP_Scheduling_Stubs.WorkOrder_WP> workOrdersWP = new List<WSCH_LTP_Scheduling_Stubs.WorkOrder_WP>();
        list<BusinessHours> lstWOBusinessHours = new list<BusinessHours>();
        Map<String, Map<Date, WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>> mapBHTimeWindows = new Map<String, Map<Date, WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>>();
        Map<String, List<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>> mapWOTimeWindows = new Map<String, List<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>>();
        set<BusinessHours> setWOBH = new set<BusinessHours>();
        String strDPId;
        if(workOrders.get(0).SVMXC__Dispatch_Process__c != null) {
            strDPId = workOrders.get(0).SVMXC__Dispatch_Process__c;
        }
                        
        // Retrieve the process definition record from ServiceMax_Processes__c by matching the ID with the given dispatch process ID
        SVMXC__ServiceMax_Processes__c objSVMXProcess = [Select Id, SVMXC__Child_Object_Criteria__c, SVMXC__Frequency__c, SVMXC__Full_Run_Unit__c, SVMXC__Retain_Appointment__c,
                        SVMXC__Retain_Assignment__c, SVMXC__Route_Type__c, SVMXC__Weight_Time_Window__c, SVMXC__Weight_Total_Distance__c, SVMXC__Weight_Route_Distance__c,
                        SVMXC__Weight_Node_Type__c, SVMXC__Calendar_Start_Type__c, SVMXC__Calendar_End_Type__c, 
                        SVMXC__Weight_Route_Time__c,
                        SVMXC__Tolerance__c, SVMXC__Calendar_Start_Days__c, SVMXC__Calendar_End_Days__c, SVMXC__Preferred_Tech_Enabled__c, SVMXC__Expertise_Match_Enabled__c,
                        SVMXC__Product_Match_Enabled__c,SVMXC__SM_Drive_Before_Shift_Start__c,
                        SVMXC__SM_Drive_After_Shift_End__c,SVMXC__Window_Height__c,SVMXC__Window_Width__c, SVMXC__Dispatch_Method__c
                        from SVMXC__ServiceMax_Processes__c
                        where Id =:strDPId];
                        
        Boolean isStandAloneLTP = false;
        if('Long-Term Planner'.equalsIgnoreCase(objSVMXProcess.SVMXC__Dispatch_Method__c)){
            isStandAloneLTP = true;
        }

        if(objTerritory.SVMXC__Territory_s_Business_Hours__c == NULL || (mapBusinessHours.containsKey(objTerritory.SVMXC__Territory_s_Business_Hours__c) == FALSE ))
            objTerritory.SVMXC__Territory_s_Business_Hours__c = strDefaultBHourId;
        
        objDefTerritoryBH = mapBusinessHours.get(objTerritory.SVMXC__Territory_s_Business_Hours__c);

        //adding territory business hr into set.
        setWOBH.add(objDefTerritoryBH); 
        
        //set horizon dates.
        //setSchedHorizDates = WSCH_LTP_Initiate_Service.doCreateLTPHorizon(objSVMXProcess,objDefTerritoryBH,dtmSchedulingHorizonStartDateTime,dtmSchedulingHorizonEndDateTime);
        Map<String, list<Date>> mapHorizonDetails = new Map<String, list<Date>>();
        if(strJobType.equalsIgnoreCase('LTP')){
            mapHorizonDetails = WSCH_LTP_Initiate_Service.doCreateLTPHorizon(objSVMXProcess,objDefTerritoryBH);
        }else if(strJobType.equalsIgnoreCase('FULL')){
            mapHorizonDetails = WSCH_LTP_Initiate_Service.doCreateBatchHorizon(objSVMXProcess,objDefTerritoryBH);
        }
        //mapHorizonDetails = WSCH_LTP_Initiate_Service.doCreateLTPHorizon(objSVMXProcess,objDefTerritoryBH);
        List<Date> lstSchedHorizDates = new List<Date>();
        setSchedHorizDates.addAll(mapHorizonDetails.values()[0]);
        List<String> lstString = new List<String>();
        lstString.addAll(mapHorizonDetails.keySet());
        List<String> ltpStartEndDT = lstString[0].split(',');
        dtmSchedulingHorizonStartDateTime = Datetime.valueOfGMT(ltpStartEndDT[0].trim());
        dtmSchedulingHorizonEndDateTime = Datetime.valueOfGMT(ltpStartEndDT[1].trim());
        WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getWorkOrdersDetails():setSchedHorizDates.size() : '+setSchedHorizDates.size() + ' , dtmSchedulingHorizonStartDateTime: '+dtmSchedulingHorizonStartDateTime+' , workOrders.size() : '+workOrders.size());
        for(SVMXC__Service_Order__c objWorkOrder: workOrders)
        {
            //create list of BH from qualified work orders preferred BH
            if(objWorkOrder.SVMXC__Preferred_Business_Hours__c != null && objWorkOrder.SVMXC__Preferred_Business_Hours__r.IsActive){
                setWOBH.add(mapBusinessHours.get(objWorkOrder.SVMXC__Preferred_Business_Hours__r.Id));
            }
        }
        if(setWOBH != null && setWOBH.size() > 0){
            lstWOBusinessHours.addAll(setWOBH);
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getWorkOrdersDetails(): work orders BH size : '+lstWOBusinessHours.size());
            mapBHTimeWindows = generateBusinessHourDetails(lstWOBusinessHours, NULL, NULL, setSchedHorizDates);
        }

        for(SVMXC__Service_Order__c objWorkOrder : workOrders){
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getWorkOrdersDetails(): Building time windows for Work Order: ' + objWorkOrder.Name);
            List<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP> lstWOTimeWindows = new List<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>();
            Map<Date, WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP> mapWrkOrdrTimeWindows = new Map<Date, WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>();
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

            //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getWorkOrdersDetails(): Validate preferred start & end dates: PST:' + objWorkOrder.SVMXC__Preferred_Start_Time__c +'; PET:'+ objWorkOrder.SVMXC__Preferred_End_Time__c+'; dtmSchedulingHorizonStartDateTime: '+dtmSchedulingHorizonStartDateTime);
       
            //Validate preferred start and end dates against the Horizon and construct the Execution Time Windows
            if(objWorkOrder.SVMXC__Preferred_Start_Time__c == NULL || objWorkOrder.SVMXC__Preferred_End_Time__c == NULL ||
                        objWorkOrder.SVMXC__Preferred_Start_Time__c != NULL || objWorkOrder.SVMXC__Preferred_End_Time__c != NULL) {
                
                Datetime territoryPrefStartDT;
                Datetime territoryPrefEndDT;
                Datetime tempStartDateTime;
                Datetime tempEndDateTime;
                Boolean considerPST = false;
                Boolean considerPET = false;
                
                //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getWorkOrdersDetails(): dtmSchedulingHorizonStartDateTime - ' + dtmSchedulingHorizonStartDateTime);
                //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getWorkOrdersDetails(): dtmSchedulingHorizonEndDateTime - ' + dtmSchedulingHorizonEndDateTime);
                
                if(objWorkOrder.SVMXC__Preferred_Start_Time__c != NULL) {
                    //convert the PST territory time zone and compare it with the horizon start and end dates appropriately to find
                    //if they are well within the horizon and determine the start and end dates to be sent to the server.
                                
                    territoryPrefStartDT = WSCH_DateUtils.doTZConversion(objWorkOrder.SVMXC__Preferred_Start_Time__c, 'GMT' , objDefTerritoryBH.timeZoneSidKey);
                    if(territoryPrefStartDT >= dtmSchedulingHorizonStartDateTime && territoryPrefStartDT <= dtmSchedulingHorizonEndDateTime) {
                        considerPST = true;
                    }
                }
                
                if(objWorkOrder.SVMXC__Preferred_End_Time__c != NULL) {
                    //convert the PET to the territory time zone and compare it with the horizon start and end dates appropriately to find
                    //if they are well within the horizon and determine the start and end dates to be sent to the server.
                                
                    territoryPrefEndDT = WSCH_DateUtils.doTZConversion(objWorkOrder.SVMXC__Preferred_End_Time__c, 'GMT' , objDefTerritoryBH.timeZoneSidKey);
                    
                    if(territoryPrefEndDT >= dtmSchedulingHorizonStartDateTime && territoryPrefEndDT <= dtmSchedulingHorizonEndDateTime) {
                        considerPET = true;
                    }
                }
                //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getWorkOrdersDetails(): territoryPrefStartDT - ' + territoryPrefStartDT);
                //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getWorkOrdersDetails(): territoryPrefEndDT - ' + territoryPrefEndDT);
                
                WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getWorkOrdersDetails(): considerPST - ' + considerPST + 'considerPET ' + considerPET);
                
                if(objWorkOrder.SVMXC__Preferred_Start_Time__c != NULL && objWorkOrder.SVMXC__Preferred_End_Time__c != NULL &&
                        objWorkOrder.SVMXC__Preferred_Start_Time__c < objWorkOrder.SVMXC__Preferred_End_Time__c) {
                            
                WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getWorkOrdersDetails(): PST != NULL && PET != NULL');
                            
                    if(considerPST && considerPET) {
                        tempStartDateTime = objWorkOrder.SVMXC__Preferred_Start_Time__c;
                        tempEndDateTime = objWorkOrder.SVMXC__Preferred_End_Time__c;
                        //Construct the execution time windows for the above start and end dates
                        constructExecTimeWIndows(tempStartDateTime, tempEndDateTime, lstWOTimeWindows, mapWrkOrdrTimeWindows, objWorkOrder);
                        
                    } else if(considerPST == false && considerPET == false) {
                        WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getWorkOrdersDetails():As both PST and PET are out of the Horizon, skipping this WO - ' + objWorkOrder.Id);
                        String errorText = 'As both PST and PET are out of the Horizon, skipping this WO from scheduling';
                        WSCH_CommonUtils.setOptimizerErrorText(objWorkOrder, errorText);
                        continue;
                        
                    } else if(considerPST && considerPET == false) {
                        tempStartDateTime = objWorkOrder.SVMXC__Preferred_Start_Time__c;
                        tempEndDateTime = WSCH_DateUtils.doTZConversion(dtmSchedulingHorizonEndDateTime, objDefTerritoryBH.timeZoneSidKey, 'GMT');
                        //Construct the execution time windows for the above start and end dates
                        constructExecTimeWIndows(tempStartDateTime, tempEndDateTime, lstWOTimeWindows, mapWrkOrdrTimeWindows, objWorkOrder);
                        
                    } else if(considerPST == false && considerPET) {                        
                        if(isStandAloneLTP){
                            tempStartDateTime = WSCH_DateUtils.doTZConversion(dtmSchedulingHorizonStartDateTime, objDefTerritoryBH.timeZoneSidKey, 'GMT');
                            tempEndDateTime = objWorkOrder.SVMXC__Preferred_End_Time__c;
                            //Construct the execution time windows for the above start and end dates
                            constructExecTimeWIndows(tempStartDateTime, tempEndDateTime, lstWOTimeWindows, mapWrkOrdrTimeWindows, objWorkOrder);
                        }else{
                            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getWorkOrdersDetails():As PST is inside the Horizon of RTO/BATCH so skipping this WO from scheduling - ' + objWorkOrder.Id);
                            String errorText = 'As PST is inside the Horizon of RTO/BATCH so skipping this WO from scheduling';
                            WSCH_CommonUtils.setOptimizerErrorText(objWorkOrder, errorText);
                            continue;
                        }
                    }
                            
                } else if(objWorkOrder.SVMXC__Preferred_Start_Time__c != NULL && objWorkOrder.SVMXC__Preferred_End_Time__c == NULL) {
                    WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getWorkOrdersDetails(): PST != NULL && PET == NULL');
                    //if PST is not null check if PST has to be considered, else consider horizon start datetime
                    if(considerPST) {
                        tempStartDateTime = objWorkOrder.SVMXC__Preferred_Start_Time__c;
                        tempEndDateTime = WSCH_DateUtils.doTZConversion(dtmSchedulingHorizonEndDateTime, objDefTerritoryBH.timeZoneSidKey, 'GMT');
                    } else {
                        WSCH_AuditLogger.debug('PST is out of the Horizon and PET is null, skipping this WO - ' + objWorkOrder.Id);
                        continue;
                    }
                    //setting Horizon end datetime as the SLA enddatetime sicne PreferredEndTime is null
                    //tempEndDateTime = dtmSchedulingHorizonEndDateTime;
                    //Construct the execution time windows for the above start and end dates
                    constructExecTimeWIndows(tempStartDateTime, tempEndDateTime, lstWOTimeWindows, mapWrkOrdrTimeWindows, objWorkOrder);
                    
                } else if(objWorkOrder.SVMXC__Preferred_Start_Time__c == NULL && objWorkOrder.SVMXC__Preferred_End_Time__c != NULL) {
                    WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getWorkOrdersDetails(): PST == NULL && PET != NULL');
                    //setting Horizon start datetime as the SLA startdatetime since PreferredEndTime is null
                    //tempStartDateTime = dtmSchedulingHorizonStartDateTime;
                    if(considerPET) {
                        tempStartDateTime = WSCH_DateUtils.doTZConversion(dtmSchedulingHorizonStartDateTime, objDefTerritoryBH.timeZoneSidKey, 'GMT');
                        tempEndDateTime = objWorkOrder.SVMXC__Preferred_End_Time__c;
                    } else {
                        WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getWorkOrdersDetails():PST is NULL and PET is out of Horizon, skipping this WO - ' + objWorkOrder.Id);
                        continue;
                    }
                    //Construct the execution time windows for the above start and end dates
                    constructExecTimeWIndows(tempStartDateTime, tempEndDateTime, lstWOTimeWindows, mapWrkOrdrTimeWindows, objWorkOrder);
                    
                } else if(objWorkOrder.SVMXC__Preferred_Start_Time__c == NULL && objWorkOrder.SVMXC__Preferred_End_Time__c == NULL ) {
                    
                    if(strJobType.equalsIgnoreCase('LTP')){
                        WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getWorkOrdersDetails():As both PST and PET are not available, skipping this WO - ' + objWorkOrder.Id);
                        String errorText = 'As both PST and PET are not available, skipping this WO from scheduling';
                        WSCH_CommonUtils.setOptimizerErrorText(objWorkOrder, errorText);
                    }else if(strJobType.equalsIgnoreCase('Full')){
                        WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getWorkOrdersDetails(): As both PST and PET are not available and Batch Job, So consider this WO');
                        //since both PST and PET are null set Horizon start and end datetime as SLA
                        tempStartDateTime = WSCH_DateUtils.doTZConversion(dtmSchedulingHorizonStartDateTime, objDefTerritoryBH.timeZoneSidKey, 'GMT');
                        tempEndDateTime = WSCH_DateUtils.doTZConversion(dtmSchedulingHorizonEndDateTime, objDefTerritoryBH.timeZoneSidKey, 'GMT');
                        constructExecTimeWIndows(tempStartDateTime, tempEndDateTime, lstWOTimeWindows, mapWrkOrdrTimeWindows, objWorkOrder);
                    }
                }
            }
            
            if(lstWOTimeWindows != NULL && lstWOTimeWindows.size() > 0)
            {
                List<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP> woCOExeTime = new List<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>();
                for(WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP exeTime : lstWOTimeWindows)
                {
                    woCOExeTime.add(new WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP(exeTime.HoursBegin, exeTime.HoursEnd));
                }
                mapWOTimeWindows.put(objWorkOrder.id, woCOExeTime);
            }

            String workOrderType = 'NEW';
            // Building the execution time window for New and Assigned Work Orders
            if(mapWOTimeWindows.containsKey(objWorkOrder.Id) && mapWOTimeWindows.get(objWorkOrder.Id).size() > 0 )
            {
                workOrdersWP.add(new WSCH_LTP_Scheduling_Stubs.WorkOrder_WP(objWorkOrder, mapWOTimeWindows.get(objWorkOrder.Id)));
            }
        }
        return workOrdersWP; 
    }
    
    public static List<BusinessHours> getCompleteBusinessHours(List<BusinessHours> lstBusinessHours)
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
    
    public static Map<id, Map<date, list<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>>> getTechnicianTimeWindows(set<Date> setSchedHorizDates, Map<String, BusinessHours> mapBHours, List<SVMXC__Service_Group_Members__c> lstTechnicians, SVMXC__ServiceMax_Processes__c objSVMXProcess){
        Map<id, Map<date, list<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>>> mapTechAvailableTW = new Map<id, Map<date, list<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>>>();
        Map<Id, SVMXC__Service_Group_Members__c> mapUsersTechnicians = new Map<Id, SVMXC__Service_Group_Members__c>();
        set<String> setAvailTechAsSFUserList = new set<String>();
        set<String> setAvailTechAsSVMXUserList = new set<String>();
        String territoryBHId;
        String strTZSidKey;
        try
        {
            //Start Multiday and Allday in LTP
            if(lstTechnicians != null && !lstTechnicians.isEmpty()) {
                strTZSidKey = lstTechnicians.get(0).SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey;
                territoryBHId = lstTechnicians.get(0).SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c;
            }
            for(SVMXC__Service_Group_Members__c tech : lstTechnicians)
            {                
                if(tech.SVMXC__Salesforce_User__c != NULL)
                {
                    setAvailTechAsSFUserList.add(tech.SVMXC__Salesforce_User__c);
                    mapUsersTechnicians.put(tech.SVMXC__Salesforce_User__c, tech);
                }else
                    setAvailTechAsSVMXUserList.add(tech.Id);                
            }
            //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getTechnicianTimeWindows():setAvailTechAsSVMXUserList.size() - ' + setAvailTechAsSVMXUserList.size());
            //integer noOfDays = (objSVMXProcess.SVMXC__Calendar_End_Days__c).intValue();
            DateTime dtmSchedulingHorizonStartDateTime;
            DateTime dtmSchedulingHorizonEndDateTime;
            List<DateTime> lstHorizonStartAndEndDateTime = WSCH_CommonUtils.getDPHorizonStartAndEndDatesForLTP(objSVMXProcess, mapBHours.get(territoryBHId));
            if(lstHorizonStartAndEndDateTime != null && lstHorizonStartAndEndDateTime.size() == 2) {
                dtmSchedulingHorizonStartDateTime = lstHorizonStartAndEndDateTime[0];
                dtmSchedulingHorizonEndDateTime = lstHorizonStartAndEndDateTime[1];
            }

            //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getTechnicianTimeWindows():no Of horizon Days in DP - ' + noOfDays);
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getTechnicianTimeWindows():dtmSchedulingHorizonStartDateTime - ' + dtmSchedulingHorizonStartDateTime);
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getTechnicianTimeWindows():dtmSchedulingHorizonEndDateTime - ' + dtmSchedulingHorizonEndDateTime);
            
            Map<Id, Event> mapSFEvent = new Map<Id, Event>([Select Id, WhatId, Subject, Description, ActivityDateTime, OwnerId, EndDateTime, DurationInMinutes,IsAllDayEvent,ActivityDate,StartDatetime, Location,SVMXC__Driving_Time__c, SVMXC__Driving_Time_Home__c, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c from Event where OwnerId in:setAvailTechAsSFUserList AND (StartDateTime <= :dtmSchedulingHorizonEndDateTime AND EndDateTime >= :dtmSchedulingHorizonStartDateTime)]);
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getTechnicianTimeWindows(): - Salesforce Event list size: ' + mapSFEvent.size());
            Map<String, List<Date>> mapTechAllDayEvents = new Map<String, List<Date>>();
            Map<String, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>> mapTechMultiDayEvents = new Map<String, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>();
            for(Event ev : mapSFEvent.values()){
                SVMXC__Service_Group_Members__c technician = mapUsersTechnicians.get(ev.ownerId);
                //Convert event start and end dateime into technician TZ.
                DateTime startDatetimeBH = WSCH_DateUtils.doTZConversion(ev.StartDateTime, 'GMT', strTZSidKey);
                DateTime endDatetimeBH = WSCH_DateUtils.doTZConversion(ev.EndDateTime, 'GMT', strTZSidKey);
                
                integer intDays =  startDatetimeBH.DateGMT().daysBetween(endDatetimeBH.DateGMT());
                //integer intDays =  ev.StartDateTime.DateGMT().daysBetween(ev.EndDateTime.DateGMT());
                WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getTechnicianTimeWindows():mapSFEvent intDays- ' + intDays);
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
            Map<Id, SVMXC__SVMX_Event__c> mapSVMXEvent = new Map<Id, SVMXC__SVMX_Event__c>([Select Id, Name, SVMXC__Location__c, SVMXC__Description__c, SVMXC__DurationInMinutes__c, SVMXC__WhatId__c,SVMXC__Technician__c, SVMXC__ActivityDate__c,SVMXC__ActivityDateTime__c,SVMXC__EndDateTime__c,SVMXC__StartDateTime__c,SVMXC__IsAllDayEvent__c, SVMXC__Driving_Time__c, SVMXC__Driving_Time_Home__c, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c from SVMXC__SVMX_Event__c where SVMXC__Technician__c in:setAvailTechAsSVMXUserList AND (SVMXC__StartDateTime__c <= :dtmSchedulingHorizonEndDateTime and SVMXC__EndDateTime__c >= :dtmSchedulingHorizonStartDateTime)]);       
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getTechnicianTimeWindows():: SVMX event list size: ' + mapSVMXEvent.size());
            for(SVMXC__SVMX_Event__c svmxEvent : mapSVMXEvent.values()){
                //Convert event start and end dateime into technician TZ.
                DateTime startDatetimeBH = WSCH_DateUtils.doTZConversion(svmxEvent.SVMXC__StartDateTime__c, 'GMT', strTZSidKey);
                DateTime endDatetimeBH = WSCH_DateUtils.doTZConversion(svmxEvent.SVMXC__EndDateTime__c, 'GMT', strTZSidKey);
                
                //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getTechnicianTimeWindows():strTZSidKey- ' + strTZSidKey);
                //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getTechnicianTimeWindows():svmxEvent.SVMXC__StartDateTime__c- ' + svmxEvent.SVMXC__StartDateTime__c);
                //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getTechnicianTimeWindows():svmxEvent.SVMXC__EndDateTime__c- ' + svmxEvent.SVMXC__EndDateTime__c);

                integer intDays =  startDatetimeBH.DateGMT().daysBetween(endDatetimeBH.DateGMT());
                //integer intDays =  svmxEvent.SVMXC__StartDateTime__c.DateGMT().daysBetween(svmxEvent.SVMXC__EndDateTime__c.DateGMT());
                WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getTechnicianTimeWindows(): mapSVMXEvent intDays- ' + intDays);
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
                    WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getTechnicianTimeWindows():Multiday event span 1 day...Start-'+svmxEvent.SVMXC__StartDateTime__c+' End- '+svmxEvent.SVMXC__EndDateTime__c);
                    list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstMultiDays = new list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
                    WSCH_Provider_ECO_Stubs.ExecutionTime_WP exeTime = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP();
                    exeTime.workingHoursBegin = svmxEvent.SVMXC__EndDateTime__c;
                    exeTime.workingHoursEnd = svmxEvent.SVMXC__StartDateTime__c;
                    if(!mapTechMultiDayEvents.containsKey(svmxEvent.SVMXC__Technician__c))
                        mapTechMultiDayEvents.put(svmxEvent.SVMXC__Technician__c,lstMultiDays);

                    mapTechMultiDayEvents.get(svmxEvent.SVMXC__Technician__c).add(exeTime);
                    WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getTechnicianTimeWindows():exeTime- ' + exeTime);
                }else if(intDays > 1){
                    WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getTechnicianTimeWindows():Multiday event span > 1 day...Start-'+svmxEvent.SVMXC__StartDateTime__c+' End- '+svmxEvent.SVMXC__EndDateTime__c);
                    for(integer i = 0; i <= intDays; i++) {
                        WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getTechnicianTimeWindows():i- ' + i);
                        if(i==0){
                            list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstMultiDays = new list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
                            WSCH_Provider_ECO_Stubs.ExecutionTime_WP exeTime = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP();
                            exeTime.workingHoursBegin = svmxEvent.SVMXC__EndDateTime__c;
                            exeTime.workingHoursEnd = svmxEvent.SVMXC__StartDateTime__c;
                            if(!mapTechMultiDayEvents.containsKey(svmxEvent.SVMXC__Technician__c))
                                mapTechMultiDayEvents.put(svmxEvent.SVMXC__Technician__c,lstMultiDays);
        
                            mapTechMultiDayEvents.get(svmxEvent.SVMXC__Technician__c).add(exeTime);
                            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getTechnicianTimeWindows():exeTime- ' + exeTime);
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
                        WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getTechnicianTimeWindows():svmxEvent.SVMXC__StartDateTime__c.addDays(i).dateGMT()- ' + svmxEvent.SVMXC__StartDateTime__c.addDays(i).dateGMT());
                    }
                }

            }
            //End Multiday and Allday in LTP

            for(SVMXC__Service_Group_Members__c tech: lstTechnicians)
            {         
                //Start Multiday and Allday in LTP       
                set<Date> setRemovalDates = new set<Date>();
                set<Date> setFinalDates = new set<Date>(setSchedHorizDates);
                List<Date> lstAllDays = mapTechAllDayEvents.get(tech.id);
                list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstMultiDays = mapTechMultiDayEvents.get(tech.id);
                WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getTechnicianTimeWindows():: allday event dates for tech: '+tech.name+ ': list of all day events..'+lstAllDays);                
                if(lstAllDays != null && lstAllDays.size() > 0){
                    for(Date dt : lstAllDays){
                        if(setSchedHorizDates.contains(dt)){
                            setRemovalDates.add(dt);
                        }
                    }
                }
                WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getTechnicianTimeWindows():: allday event dates for tech: ' + tech.Name +'- '+setRemovalDates);
                setFinalDates.removeAll(setRemovalDates);
                //End Multiday and Allday in LTP

                try
                {
                    mapTechAvailableTW = getTechAvailabilityWindow(mapTechAvailableTW, tech.Id, mapBHours.get(tech.SVMXC__Working_Hours__c), mapBHours.get(tech.SVMXC__Break_Hours__c), setFinalDates, lstMultiDays);
                }
                catch(Exception ex)
                {
                    WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getTechnicianTimeWindows():exception: ' + ex.getStackTraceString());
                }
            }  
            WSCH_AuditLogger.finish();         
        }
        catch(Exception ex)
        {
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getTechnicianTimeWindows():: Failed with the exception: ' + ex.getMessage());
        }
        return mapTechAvailableTW;
    }

    public static Map<id, Map<date, list<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>>> getTechAvailabilityWindow(Map<id, Map<date, list<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>>> mapTechAvailableTW, id techId, BusinessHours oBusinessHours, BusinessHours breakBH, set<Date> setSchedHorizonDates, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstMultiDayEvent)
    {
        DateTime dtmBusinessHourStartDateTime, dtmBusinessHourEndDateTime, dtmBreakHourStartDateTime, dtmBreakHourEndDateTime;
        
        Boolean isValidBusinessHour = TRUE;
        
        Map<id, Map<date, list<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>>> techAvail = new Map<id, Map<date, list<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>>>();
        Map<date, list<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>> actualAvailableWindow = new Map<date, list<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>>();
        Map<date, list<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>> availableWindow = new Map<date, list<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>>();
        Map<date, list<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>> eventWindow = new Map<date, list<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>>();
        
        //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::techAvailabilityWindow():In techAvailabilityWindow for technician: ' + techId);
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
                    list<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP> lstEventTimeWindows = new list<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>();
                    string datesDay = (datetime.newInstanceGmt(calendarDate, Time.newinstance(0, 0, 0, 0))).formatGmt('EEEE');
                    
                    // Get the start and end times for the given date
                    Time timTechStartTime = getStartEndTime(oBusinessHours, datesDay, 'StartTime');
                    Time timTechEndTime = getStartEndTime(oBusinessHours, datesDay, 'EndTime');
                    
                    // If it is a 24 Hours Business Day, not valid for technician; skip
                    if(timTechStartTime == timTechEndTime)
                        continue;
                    
                    dtmBusinessHourStartDateTime = dcUtils.getDateTimeInTimezone(calendarDate, timTechStartTime, oBusinessHours.TimeZoneSidKey);
                    dtmBusinessHourEndDateTime = dcUtils.getDateTimeInTimezone(calendarDate, timTechEndTime, oBusinessHours.TimeZoneSidKey);

                    // Multiday in LTP
                    if(lstMultiDayEvent != null && lstMultiDayEvent.size() > 0){
                        //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler:: getTechAvailabilityWindow:calendarDate- ' + calendarDate);
                        for(WSCH_Provider_ECO_Stubs.ExecutionTime_WP exeTime : lstMultiDayEvent){
                            //Date startDate = exeTime.workingHoursBegin.dateGmt();
                            //Date endDate = exeTime.workingHoursEnd.dateGmt();
                            //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler:: getTechAvailabilityWindow:exeTime.workingHoursBegin- ' + exeTime.workingHoursBegin);
                            //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler:: getTechAvailabilityWindow:exeTime.workingHoursEnd- ' + exeTime.workingHoursEnd);
                                                        
                            DateTime startDateTimeTerrTZ = WSCH_DateUtils.doTZConversion(exeTime.workingHoursBegin, 'GMT', oBusinessHours.TimeZoneSidKey);
                            DateTime endDateTimeTerrTZ = WSCH_DateUtils.doTZConversion(exeTime.workingHoursEnd, 'GMT', oBusinessHours.TimeZoneSidKey);
                            //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler:: getTechAvailabilityWindow:startDateTimeTerrTZ- ' + startDateTimeTerrTZ);
                            //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler:: getTechAvailabilityWindow:endDateTimeTerrTZ- ' + endDateTimeTerrTZ);
                                                
                            Date startDate = startDateTimeTerrTZ.dateGmt();
                            Date endDate = endDateTimeTerrTZ.dateGmt();
                     
                            //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler:: getTechAvailabilityWindow:startDate TerrTZ- ' + startDate);
                            //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler:: getTechAvailabilityWindow:endDate TerrTZ- ' + endDate);
                                                        
                            if(calendarDate >= startDate){
                                if(dtmBusinessHourStartDateTime < exeTime.workingHoursBegin){
                                    dtmBusinessHourStartDateTime = exeTime.workingHoursBegin;
                                    //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler:: getTechAvailabilityWindow:inside if()dtmBusinessHourStartDateTime- ' + dtmBusinessHourStartDateTime);                                    
                                }
                                //break;
                            }else if(calendarDate >= endDate){
                                if(exeTime.workingHoursEnd < dtmBusinessHourEndDateTime){ // if it is last day than BH end override by last day time
                                    dtmBusinessHourEndDateTime = exeTime.workingHoursEnd;
                                    //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler:: getTechAvailabilityWindow:inside if()dtmBusinessHourEndDateTime- ' + dtmBusinessHourEndDateTime);
                                }
                                //break;                            
                            }
                        }
                    }
                    
                    // If the available working window is valid
                    if(dtmBusinessHourStartDateTime < dtmBusinessHourEndDateTime)
                    {
                        // Setup technician's Business Hours as available window
                        WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP wrpTempAvailableWindow = new WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP(dtmBusinessHourStartDateTime, dtmBusinessHourEndDateTime);
                        lstEventTimeWindows.add(wrpTempAvailableWindow);
                        lstEventTimeWindows = sortExecutionTime(lstEventTimeWindows);
                        availableWindow.put(calendarDate, lstEventTimeWindows);
                    }
                }
            }
            //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::techAvailabilityWindow() Available time window size: ' + availableWindow.size() + '; Available time windows: ' + availableWindow.size());
            
            if(availableWindow.size() > 0)
                techAvail.put(techId, availableWindow);
        }
        return techAvail;
    }   

    
    public static List<WSCH_LTP_Scheduling_Stubs.Technician_WP> doBuildResourceWrapper(List<SVMXC__Service_Group_Members__c> lstTechs, Map<id, Map<date, list<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>>> mapTechAvailabilityTW, SVMXC__Territory__c objTerritory,SVMXC__ServiceMax_Processes__c objSVMXProc){
        List<WSCH_LTP_Scheduling_Stubs.Technician_WP> resources = new List<WSCH_LTP_Scheduling_Stubs.Technician_WP>();      
        // Create Technician Window 
        Integer intTechnicianCount = 0;
        Integer intTechOnlyCount = lstTechs.size();
        WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::doBuildResourceWrapper():intTechOnlyCount: ' + intTechOnlyCount);
        //Map<String, List<String>> mapTechSkill = new Map<String, List<String>>();
        //mapTechSkill = getTechSkillMap(lstTechs);
        Map<String, List<WSCH_LTP_Scheduling_Stubs.Expertise_WP>> mapTechSkill = new Map<String, List<WSCH_LTP_Scheduling_Stubs.Expertise_WP>>();
        mapTechSkill = getTechExpertiseMap(lstTechs);
        for(SVMXC__Service_Group_Members__c tech : lstTechs)
        {
            //setTechnicianParams(tech);
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::doBuildResourceWrapper(): Updating technician: ' + tech.id + '(' + tech.Name + ')');
            Integer intEventCount = 0;
            if(mapTechAvailabilityTW.containsKey(tech.Id) && mapTechAvailabilityTW.get(tech.Id).size() > 0)
            {
                List<WSCH_LTP_Scheduling_Stubs.Expertise_WP> lstTechSkill = new List<WSCH_LTP_Scheduling_Stubs.Expertise_WP>();
                lstTechSkill = mapTechSkill.get(tech.Id);
        
                Double dblMaxMinutes = 0;
                // Get the BusinessHours and the Availability time windows of the technician
                if(tech.SVMXC__Working_Hours__c == NULL || mapBusinessHours.containsKey(tech.SVMXC__Working_Hours__c) == FALSE)
                {
                    tech.SVMXC__Working_Hours__c = objTerritory.SVMXC__Territory_s_Business_Hours__c;
                }
                if(tech.SVMXC__Break_Hours__c == NULL || mapBusinessHours.containsKey(tech.SVMXC__Break_Hours__c) == FALSE){
                    tech.SVMXC__Break_Hours__c = objTerritory.SVMXC__Break_Hours__c;
                }
                
                Id idTechBH = tech.SVMXC__Working_Hours__c;
                
                BusinessHours objTechBH = mapBusinessHours.get(idTechBH);
                Map<date, list<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>> mapTechTimeWindows = mapTechAvailabilityTW.get(tech.Id);
                
                Integer intDayCount = 1;
                
                // Sort the availability time windows map by date (local date)
                List<Date> lstSortedDates = new List<Date>();
                lstSortedDates.addAll(mapTechTimeWindows.keyset());
                lstSortedDates.sort();
                
                List<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP> lstDailyModeExeTime = new List<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>();
                for(Date datSelectedDate : lstSortedDates)
                {
                    dblMaxMinutes = 0;
                    // Get the available time windows for the given date
                    List<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP> lstTechTimeWindow = mapTechTimeWindows.get(datSelectedDate);
                    if(lstTechTimeWindow != NULL && lstTechTimeWindow.size() > 0)
                    {
                        // Sort the available time windows of the technician by start date time 
                        lstTechTimeWindow = sortExecutionTime(lstTechTimeWindow);
                        DateTime dtmTodaysBHEnd;
                        DateTime dtmTodaysBHStart;
                        Integer intTimeWindCount = 1;
                        
                        // Get the start and end time for the given date using BusinessHours
                        dtmTodaysBHStart = BusinessHours.addGmt(idTechBH, dcUtils.getDateTimeInTimezone(datSelectedDate, Time.newInstance(0, 0, 0, 0), objTechBH.timeZoneSidKey), 1L);
                        Time timTodaysBHEnd = getStartEndTime(objTechBH, dtmTodaysBHStart.format('EEEE', objTechBH.timeZoneSidKey), 'EndTime');
                        dtmTodaysBHEnd = dcUtils.getDateTimeInTimezone(datSelectedDate, timTodaysBHEnd, objTechBH.timeZoneSidKey);
                        
                        // Use the end time found above to build tech's time windows
                        DateTime dtmTechTimWindStart;
                        DateTime dtmTechTimWindEnd;
                        //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::doBuildResourceWrapper(): Date: ' + datSelectedDate + '; Available time windows: ' + lstTechTimeWindow.size());
                        for(WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP techTimeWindow : lstTechTimeWindow)
                        {
                            // If first time window of the date, set tech time window start = time window start
                            if(intTimeWindCount == 1)
                            {
                                dtmTechTimWindStart = techTimeWindow.HoursBegin;
                            }
                            // If last time window of the date 
                            if(intTimeWindCount == lstTechTimeWindow.size())
                            {
                                dtmTechTimWindEnd = techTimeWindow.HoursEnd;
                            }
                            intTimeWindCount++;
                        }
                        lstDailyModeExeTime.add(new WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP(dtmTechTimWindStart, dtmTechTimWindEnd));
                        intDayCount = intDayCount + 1;
                    }
                }
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
        
                // Don't sent technician if availability is null
                if(lstDailyModeExeTime.size() == 0)
                    continue;
                
                //sending overtime tolerance value to optimax engine.
                Double dblOverTimeInSecs=null;
                if(objSVMXProc.SVMXC__Tolerance__c != NULL && objSVMXProc.SVMXC__Tolerance__c > 0){
                    dblOverTimeInSecs = 60 * objSVMXProc.SVMXC__Tolerance__c.intValue();
                }    
                
                //WSCH_LTP_Scheduling_Stubs.Technician_WP tempTechWP = new WSCH_LTP_Scheduling_Stubs.Technician_WP(tech, lstDailyModeExeTime,lstTechSkill,null,dblOverTimeInSecs,listTechParameters);
                WSCH_LTP_Scheduling_Stubs.Technician_WP tempTechWP = new WSCH_LTP_Scheduling_Stubs.Technician_WP(tech);
                tempTechWP.expertise =lstTechSkill;
                tempTechWP.overTimeTolerance = dblOverTimeInSecs;
                tempTechWP.workingHours=lstDailyModeExeTime;

                if(objSVMXProc.SVMXC__SM_Drive_Before_Shift_Start__c != NULL && objSVMXProc.SVMXC__SM_Drive_Before_Shift_Start__c > 0){
                    tempTechWP.driveBeforeShiftStart= 60 * objSVMXProc.SVMXC__SM_Drive_Before_Shift_Start__c.intValue();
                } else {
                    tempTechWP.driveBeforeShiftStart= 0;
                }
                if(objSVMXProc.SVMXC__SM_Drive_After_Shift_End__c != NULL && objSVMXProc.SVMXC__SM_Drive_After_Shift_End__c > 0){
                    tempTechWP.driveAfterShiftEnd = 60 * objSVMXProc.SVMXC__SM_Drive_After_Shift_End__c.intValue();
                } else {
                    tempTechWP.driveAfterShiftEnd = 0;
                }
                resources.add(tempTechWP);
                intTechnicianCount++;
            }
        }
        return resources;      
    }


    public static List<WSCH_LTP_Scheduling_Stubs.TechniciansEvent_WP> doBuildResourceEventWrapper(List<SVMXC__Service_Group_Members__c> lstTechnicians, Set<Date> setSchedHorizDates, Map<String, BusinessHours> mapBHours, Map<Id, Event> mapSFEvent, Map<Id, SVMXC__SVMX_Event__c> mapSVMXEvent, BusinessHours defTerritoryBH, String strDispatchProcessId){
            List<WSCH_LTP_Scheduling_Stubs.TechniciansEvent_WP> lstTechEvent = new List<WSCH_LTP_Scheduling_Stubs.TechniciansEvent_WP>();

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
            
            Map<Id, SVMXC__Service_Group_Members__c> mapUsersTechnicians = new Map<Id, SVMXC__Service_Group_Members__c>();
            Map<Id,SVMXC__Service_Group_Members__c> mapIdTechnicians = new Map<Id,SVMXC__Service_Group_Members__c>();
            Map<String, String> mapTechTimeZone = new Map<String, String>();
            set<Id> setWrkOrdsToReschedule = new set<Id>();
            set<Id> setWrkOrdsToForceFix = new set<Id>();
            set<Id> setEventWorkOrderIds = new set<Id>();
                       
            for(SVMXC__Service_Group_Members__c tech : lstTechnicians)
            {
                mapIdTechnicians.put(tech.Id, tech);
        
                if(tech.SVMXC__Salesforce_User__c != NULL)
                {
                    mapUsersTechnicians.put(tech.SVMXC__Salesforce_User__c, tech);
                }                
            }

            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::doBuildResourceEventWrapper(): - Salesforce Event list size: ' + mapSFEvent.size());
            Map<String, List<Date>> mapTechAllDayEvents = new Map<String, List<Date>>();
            Map<String, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>> mapTechMultiDayEvents = new Map<String, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>();
            for(Event e: mapSFEvent.values())
            {
                // If it is a work order event, add the work order to the list of work orders
                if(e.WhatId != NULL && String.valueof(e.WhatId).startsWith(woKeyPrefix) == TRUE)
                {
                    setEventWorkOrderIds.add(e.WhatId);
                }            
            }
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::doBuildResourceEventWrapper():: SVMX Event list size: ' + mapSVMXEvent.size());
            
            for(SVMXC__SVMX_Event__c e: mapSVMXEvent.values())
            {
                // If it is a work order event, add the work order to the list of work orders
                if(e.SVMXC__WhatId__c != NULL && String.valueof(e.SVMXC__WhatId__c).startsWith(woKeyPrefix) == TRUE)
                {
                    setEventWorkOrderIds.add(e.SVMXC__WhatId__c);
                }
            }
            Map<Id, SVMXC__Service_Order__c> mapAllEventWorkOrders = new Map<Id, SVMXC__Service_Order__c>();
            mapAllEventWorkOrders.putAll([Select Id, SVMXC__Service_Duration__c, SVMXC__Dispatch_Process__c, SVMXC__Latitude__c, SVMXC__Longitude__c, SVMXC__Locked_By_DC__c, SVMXC__Appointment_Promised_Time_Slot__c,SVMXC__Street__c,SVMXC__City__c,SVMXC__State__c,SVMXC__Zip__c,SVMXC__Country__c
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
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::doBuildResourceEventWrapper(): Forcefix Work Orders: ' + setWrkOrdsToForceFix.size());                
            
            // From Salesforce Events map, build the list of work orders to be rescheduled and events related to them + map of tech's non-Work order events
            String technicianId;
            String territoryId;
            String eventId;
            Datetime evStartTime = null;
            DateTime evEndTime = null;
            Integer driveTime = 0;
            Integer returnDriveTime = 0;

            for(Event e: mapSFEvent.values())
            {
                WSCH_LTP_Scheduling_Stubs.TechniciansEvent_WP techevent;               
                SVMXC__Service_Group_Members__c technician = mapUsersTechnicians.get(e.OwnerId); 
                technicianId = technician.Id+'_'+technician.Name;
                territoryId = technician.SVMXC__Service_Territory__c;
                eventId = 'Event_'+e.id+'_'+technician.name;
                WSCH_LTP_Scheduling_Stubs.Location_WP wrpEventLocation;
                String eventAddress = '';
                
               WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::doBuildResourceEventWrapper():technicianId:-  '+technicianId+' ; territoryId:-  '+territoryId+' ; eventID:-  '+eventId);
                
                // forcefix work orders
                if(( e.WhatId != NULL && String.valueof(e.WhatId).startsWith(woKeyPrefix) == TRUE ) && ( setWrkOrdsToForceFix.contains(e.WhatId) ))
                {
                    driveTime = Integer.valueOf(e.SVMXC__Driving_Time__c);
                    returnDriveTime = Integer.valueOf(e.SVMXC__Driving_Time_Home__c);
                    evStartTime = e.StartDateTime.addMinutes(driveTime);
                    evEndTime = e.EndDatetime.addMinutes(-returnDriveTime); 
                    //Set the latitude and longitude from work order.
                    SVMXC__Service_Order__c objWorkOrder = mapAllEventWorkOrders.get(e.WhatId);
                    if(objWorkOrder.SVMXC__Latitude__c != null && objWorkOrder.SVMXC__Longitude__c != null){
                        wrpEventLocation = new WSCH_LTP_Scheduling_Stubs.Location_WP();
                        wrpEventLocation.latitude = objWorkOrder.SVMXC__Latitude__c;
                        wrpEventLocation.longitude = objWorkOrder.SVMXC__Longitude__c;
                    }
                    eventAddress = ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0) ? objWorkOrder.SVMXC__Street__c : '') + ((objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) ?  (((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0)) ? ', ' : '') + objWorkOrder.SVMXC__City__c : '') + ((objWorkOrder.SVMXC__State__c != NULL && objWorkOrder.SVMXC__State__c.length() > 0) ?  (((objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) || ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objWorkOrder.SVMXC__State__c : '') + ((objWorkOrder.SVMXC__Zip__c != NULL && objWorkOrder.SVMXC__Zip__c.length() > 0) ?  (((objWorkOrder.SVMXC__State__c != NULL && objWorkOrder.SVMXC__State__c.length() > 0) || (objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) || ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objWorkOrder.SVMXC__Zip__c : '') + ((objWorkOrder.SVMXC__Country__c != NULL && objWorkOrder.SVMXC__Country__c.length() > 0) ?  (((objWorkOrder.SVMXC__Zip__c != NULL && objWorkOrder.SVMXC__Zip__c.length() > 0) || (objWorkOrder.SVMXC__State__c != NULL && objWorkOrder.SVMXC__State__c.length() > 0) || (objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) || ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objWorkOrder.SVMXC__Country__c : '');
                }
                // Non-Work order events 
                else
                {
                    driveTime = Integer.valueOf(e.SVMXC__Driving_Time__c);
                    returnDriveTime = Integer.valueOf(e.SVMXC__Driving_Time_Home__c);
                    evStartTime = e.StartDateTime.addMinutes(driveTime);
                    evEndTime = e.EndDatetime.addMinutes(-returnDriveTime); 
                    if(e.SVMXC__SM_Latitude__c != null && e.SVMXC__SM_Longitude__c != null){
                        wrpEventLocation = new WSCH_LTP_Scheduling_Stubs.Location_WP();
                        wrpEventLocation.latitude = e.SVMXC__SM_Latitude__c;
                        wrpEventLocation.longitude = e.SVMXC__SM_Longitude__c;
                    }
                    if(e.Location != null){
                        eventAddress = e.Location;
                    }
                }
                techevent = new WSCH_LTP_Scheduling_Stubs.TechniciansEvent_WP(territoryId,technicianId,eventId,evStartTime,evEndTime,0,0,1,'add', wrpEventLocation, eventAddress); 
                lstTechEvent.add(techevent);
            }
            mapSFEvent.clear();
            //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::doBuildTechnicianTimeWindows(): Non WorkOrders : -'+mapEventNonWO.size());                

            // From ServiceMax Events map, build the list of work orders to be rescheduled and events related to them + map of tech's non-Work order events
            for(SVMXC__SVMX_Event__c e: mapSVMXEvent.values())
            {
                WSCH_LTP_Scheduling_Stubs.TechniciansEvent_WP techevent;
                SVMXC__Service_Group_Members__c technician = mapIdTechnicians.get(e.SVMXC__Technician__c); 
                technicianId = technician.Id+'_'+technician.Name;
                territoryId = technician.SVMXC__Service_Territory__c;
                eventId = 'Event_'+e.id+'_'+technician.name;
                WSCH_LTP_Scheduling_Stubs.Location_WP wrpEventLocation;
                String eventAddress = '';
                
               WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::doBuildResourceEventWrapper():Process SVMX Event....technicianId:-  '+technicianId+' ; territoryId:-  '+territoryId+' ; eventID:-  '+eventId);
                
                // forcefix work orders
                if(( e.SVMXC__WhatId__c != NULL ) && ( String.valueof(e.SVMXC__WhatId__c).startsWith(woKeyPrefix) == TRUE ) && ( setWrkOrdsToForceFix.contains(e.SVMXC__WhatId__c) ) ) {
                    driveTime = Integer.valueOf(e.SVMXC__Driving_Time__c);
                    returnDriveTime = Integer.valueOf(e.SVMXC__Driving_Time_Home__c);
                    evStartTime = e.SVMXC__StartDateTime__c.addMinutes(driveTime);
                    evEndTime = e.SVMXC__EndDateTime__c.addMinutes(-returnDriveTime); 
                    //Set the latitude and longitude from work order.
                    SVMXC__Service_Order__c objWorkOrder = mapAllEventWorkOrders.get(e.SVMXC__WhatId__c);
                    if(objWorkOrder.SVMXC__Latitude__c != null && objWorkOrder.SVMXC__Longitude__c != null){
                        wrpEventLocation = new WSCH_LTP_Scheduling_Stubs.Location_WP();
                        wrpEventLocation.latitude = objWorkOrder.SVMXC__Latitude__c;
                        wrpEventLocation.longitude = objWorkOrder.SVMXC__Longitude__c;
                    }
                    eventAddress = ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0) ? objWorkOrder.SVMXC__Street__c : '') + ((objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) ?  (((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0)) ? ', ' : '') + objWorkOrder.SVMXC__City__c : '') + ((objWorkOrder.SVMXC__State__c != NULL && objWorkOrder.SVMXC__State__c.length() > 0) ?  (((objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) || ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objWorkOrder.SVMXC__State__c : '') + ((objWorkOrder.SVMXC__Zip__c != NULL && objWorkOrder.SVMXC__Zip__c.length() > 0) ?  (((objWorkOrder.SVMXC__State__c != NULL && objWorkOrder.SVMXC__State__c.length() > 0) || (objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) || ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objWorkOrder.SVMXC__Zip__c : '') + ((objWorkOrder.SVMXC__Country__c != NULL && objWorkOrder.SVMXC__Country__c.length() > 0) ?  (((objWorkOrder.SVMXC__Zip__c != NULL && objWorkOrder.SVMXC__Zip__c.length() > 0) || (objWorkOrder.SVMXC__State__c != NULL && objWorkOrder.SVMXC__State__c.length() > 0) || (objWorkOrder.SVMXC__City__c != NULL && objWorkOrder.SVMXC__City__c.length() > 0) || ((objWorkOrder.SVMXC__Street__c != NULL && objWorkOrder.SVMXC__Street__c.length() > 0))) ? ', ' : '') + objWorkOrder.SVMXC__Country__c : '');
                }
                // Non-Work order events 
                else
                {
                    driveTime = Integer.valueOf(e.SVMXC__Driving_Time__c);
                    returnDriveTime = Integer.valueOf(e.SVMXC__Driving_Time_Home__c);
                    evStartTime = e.SVMXC__StartDateTime__c.addMinutes(driveTime);
                    evEndTime = e.SVMXC__EndDateTime__c.addMinutes(-returnDriveTime); 
                    if(e.SVMXC__SM_Latitude__c != null && e.SVMXC__SM_Longitude__c != null){
                        wrpEventLocation = new WSCH_LTP_Scheduling_Stubs.Location_WP();
                        wrpEventLocation.latitude = e.SVMXC__SM_Latitude__c;
                        wrpEventLocation.longitude = e.SVMXC__SM_Longitude__c;
                    }
                    if(e.SVMXC__Location__c!= null){
                        eventAddress = e.SVMXC__Location__c;
                    }
                }
                techevent = new WSCH_LTP_Scheduling_Stubs.TechniciansEvent_WP(territoryId,technicianId,eventId,evStartTime,evEndTime,0,0,1,'add', wrpEventLocation, eventAddress); 
                lstTechEvent.add(techevent);
            }           
            mapSVMXEvent.clear();
            mapUsersTechnicians.clear();
        }
        catch(Exception ex)
        {
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::doBuildResourceEventWrapper()(): Failed with the exception: ' + ex.getMessage());
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::doBuildResourceEventWrapper() Ends');
            WSCH_AuditLogger.finish();
        }
        return lstTechEvent;
    }


    //Get List of  SF Event for Tech within the time range
    public static Map<Id, Event> getMapNonWOSFEvents(set<string> sfEventIds)
    {
        Map<Id, Event> tempEvents = new Map<Id, Event>([Select Id, WhatId, Subject, Description, ActivityDateTime, OwnerId, EndDateTime, DurationInMinutes,IsAllDayEvent,ActivityDate,StartDatetime, Location,SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c,SVMXC__SM_Status__c,Type, SVMXC__Service_Duration__c,SVMXC__Driving_Time_Home__c,SVMXC__Driving_Time__c from Event where Id in:sfEventIds]);
        return tempEvents;
    }
    
    //Get List of  SVMX Event for Tech within the time range inputStartTime and inputEndtdate
    public static Map<Id, SVMXC__SVMX_Event__c> getMapNonWOSVMXEvents(set<String> svmxEventIds)
    {
        Map<Id, SVMXC__SVMX_Event__c> tempEvents = new Map<Id, SVMXC__SVMX_Event__c>([Select Id, Name, SVMXC__Location__c, SVMXC__Description__c, SVMXC__DurationInMinutes__c, SVMXC__WhatId__c,SVMXC__Technician__c, SVMXC__Technician__r.SVMXC__Service_Territory__c, SVMXC__ActivityDate__c,SVMXC__ActivityDateTime__c,SVMXC__EndDateTime__c,SVMXC__StartDateTime__c, SVMXC__IsAllDayEvent__c, SVMXC__SM_Latitude__c, SVMXC__SM_Longitude__c, SVMXC__Service_Order__r.SVMXC__Latitude__c, SVMXC__Service_Order__r.SVMXC__Longitude__c, SVMXC__Service_Order__r.SVMXC__Street__c, SVMXC__Service_Order__r.SVMXC__City__c, SVMXC__Service_Order__r.SVMXC__State__c, SVMXC__Service_Order__r.SVMXC__Zip__c, SVMXC__Service_Order__r.SVMXC__Country__c,SVMXC__SM_Status__c,SVMXC__Type__c,SVMXC__Driving_Time__c,SVMXC__Driving_Time_Home__c from SVMXC__SVMX_Event__c where Id in:svmxEventIds]); 
        return tempEvents;
    }

    public static Map<String, Map<Date, WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>> generateBusinessHourDetails(List<BusinessHours> bh_L, Datetime startDateTime, Datetime endDateTime, set<Date> availableDates_S){
        Map<String, Map<Date, WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>> mapBusinessHourDetails = new Map<String, Map<Date, WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>>();
        for(BusinessHours bh: bh_L)
        {
            if(bh ==null ){
                continue;
            }
            Map<Date, WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP> dateTime_M = new Map<Date, WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>();
            WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::generateBusinessHourDetails(): Getting time windows for Business Hours: ' + bh.Id);
            for(Date date_T: availableDates_S)
            {
                if(isWorkingDay(bh, date_T))
                {
                    WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP exeTime = new WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP();
                    Time startTime_T = getStartEndTime(bh, datetime.newInstanceGmt(date_T, Time.newInstance(0, 0, 0, 0)).formatGmt('EEEE'), 'StartTime');
                    Time endTime_T = getStartEndTime(bh, datetime.newInstanceGmt(date_T, Time.newInstance(0, 0, 0, 0)).formatGmt('EEEE'), 'EndTime');
                    if(startTime_T == endTime_T)
                    {   // 24 hours Business Day
                        endTime_T = Time.newInstance(23, 59, 59, 999);
                    }

                    exeTime.HoursBegin = dcUtils.getDateTimeInTimezone(date_T, startTime_T, bh.timeZoneSidKey);
                    if(startDateTime != NULL && exeTime.HoursBegin < startDateTime)
                    {
                        exeTime.HoursBegin = startDateTime;
                    }

                    exeTime.HoursEnd = dcUtils.getDateTimeInTimezone(date_T, endTime_T, bh.timeZoneSidKey);
                    if(endDateTime != NULL && exeTime.HoursEnd > endDateTime)
                    {
                        exeTime.HoursEnd = endDateTime;
                    }                    
                    dateTime_M.put(date_T, exeTime);
                }
            }
            mapBusinessHourDetails.put(String.valueof(bh.Id), dateTime_M);
        }
        return mapBusinessHourDetails;
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

    public static void constructExecTimeWIndows(DateTime tempStartDateTime, DateTime tempEndDateTime, List<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP> lstWOTimeWindows,
                    Map<Date, WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP> mapWrkOrdrTimeWindows, SVMXC__Service_Order__c objWorkOrder) {
        
        //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::constructExecTimeWIndows(): tempStartDateTime: ' + tempStartDateTime + ' tempEndDateTime: '+ tempEndDateTime);
        
        Date tempStartDate = Date.valueOf(tempStartDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
        Date tempEndDate = Date.valueOf(tempEndDateTime.format('yyyy-MM-dd', objDefTerritoryBH.timeZoneSidKey));
        
        Integer intSLADays = tempStartDate.daysBetween(tempEndDate);
        //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::constructExecTimeWIndows(): Work order with SLA; BH: ' + objDefTerritoryBH.id + '; Start date: ' + tempStartDate + '; End date: ' + tempEndDate + '; SLA Days: ' + intSLADays + '; WO Preferred Start: ' + tempStartDateTime + '; WO Preferred End: ' + tempEndDateTime);
        //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::constructExecTimeWIndows(): mapWrkOrdrTimeWindows size(): ' + mapWrkOrdrTimeWindows.size());
        
        // Get the execution time windows in the SLA time window range
        for(Integer i = 0; i <= intSLADays; i++)
        {
            if(mapWrkOrdrTimeWindows.containsKey(tempStartDate.addDays(i)) && mapWrkOrdrTimeWindows.get(tempStartDate.addDays(i)) != NULL)
            {
                WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP wrpExecTime = new WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP();
                wrpExecTime.HoursBegin = mapWrkOrdrTimeWindows.get(tempStartDate.addDays(i)).HoursBegin;
                wrpExecTime.HoursEnd = mapWrkOrdrTimeWindows.get(tempStartDate.addDays(i)).HoursEnd;
                
                //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::constructExecTimeWIndows():wrpExecTime.HoursBegin - ' + wrpExecTime.HoursBegin);
                //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::constructExecTimeWIndows():wrpExecTime.HoursEnd - ' + wrpExecTime.HoursEnd);
                
                if(intSLAdays == 0 && tempStartDateTime > wrpExecTime.HoursBegin && tempStartDateTime > wrpExecTime.HoursEnd){
                    //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::constructExecTimeWIndows():wrpExecTime.HoursBegin - ' + wrpExecTime.HoursBegin);
                    //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::constructExecTimeWIndows():wrpExecTime.HoursEnd - ' + wrpExecTime.HoursEnd);
                    lstWOTimeWindows.add(wrpExecTime);
                    continue;
                }
                //If it is a first date and PST is present in the WO and if it is later than the BusinessHour startTime for that day, consider
                //PST as the HoursBegin for that day
                if(i==0 && tempStartDateTime > wrpExecTime.HoursBegin && tempStartDateTime < wrpExecTime.HoursEnd) {
                    wrpExecTime.HoursBegin = tempStartDateTime;
                }
                
                if(tempStartDate.addDays(i) == tempEndDate)
                {
                    //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::constructExecTimeWIndows(): Time window for the date ' + tempStartDate.addDays(i) + ': ' + wrpExecTime);
                    // This is the last time window; can also be the first & last time window
                    if(objWorkOrder.SVMXC__Preferred_End_Time__c != null && objWorkOrder.SVMXC__Preferred_End_Time__c > wrpExecTime.HoursBegin)
                    {
                        //commented the below condition to handle the special case due to time zone
                        // Take the earliest end date time
                        if(objWorkOrder.SVMXC__Preferred_End_Time__c < wrpExecTime.HoursEnd)
                            wrpExecTime.HoursEnd = objWorkOrder.SVMXC__Preferred_End_Time__c;
                        
                        // Take this time window if it is valid, i.e., start < end
                        if(wrpExecTime.HoursBegin < wrpExecTime.HoursEnd) {
                            lstWOTimeWindows.add(wrpExecTime);
                        }
                            
                    } else {
                        lstWOTimeWindows.add(wrpExecTime);  //newly added. When PET is null then also we should add the execTimeWindows as we consider HorizonEndDate
                                                            //in place of PET
                    }
                }
                else {
                    lstWOTimeWindows.add(wrpExecTime);
                }
                
                //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::constructExecTimeWIndows():wrpExecTime.HoursBegin - ' + wrpExecTime.HoursBegin);
                //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::constructExecTimeWIndows():wrpExecTime.HoursEnd - ' + wrpExecTime.HoursEnd);  
             }
         }
         //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::constructExecTimeWIndows():lstWOTimeWindows - '+ lstWOTimeWindows);
    }

    public static List<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP> sortExecutionTime(List<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP> lstInputTimeWindows)
    {
        List<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP> lstOutputTimeWindows = new List<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>();
        List<DateTime> lstStartDateTime = new List<DateTime>();
        Map<DateTime, Integer> mapStartDateTimeIndex = new Map<DateTime, Integer>();
        Integer intListIndex = 0;
        for(WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP timeWindow: lstInputTimeWindows)
        {
            mapStartDateTimeIndex.put(timeWindow.HoursBegin, intListIndex);
            intListIndex++;
        }
        lstStartDateTime.addall(mapStartDateTimeIndex.keyset());
        lstStartDateTime.sort();
        for(DateTime startDt: lstStartDateTime)
            lstOutputTimeWindows.add(lstInputTimeWindows.get(mapStartDateTimeIndex.get(startDt)));
        return lstOutputTimeWindows;
    }

    /*(List<SVMXC__Service_Group_Members__c> lstTechs){
        Map<String, List<String>> mapTechIdSkills = new Map<String, List<String>>();
        set<Id> setTechIds = new set<Id>();
        for(SVMXC__Service_Group_Members__c tech : lstTechs){
            setTechIds.add(tech.Id);
        }
        List<SVMXC__Service_Group_Skills__c> lstTechSkills = [SELECT Id,IsDeleted,Name,SVMXC__Group_Member__c,SVMXC__Skill__r.Id, SVMXC__Skill__r.Name,SVMXC__Skill__r.SVMXC__Active__c FROM SVMXC__Service_Group_Skills__c WHERE SVMXC__Group_Member__c in :setTechIds AND IsDeleted = false AND SVMXC__Skill__r.SVMXC__Active__c = true];
        for(SVMXC__Service_Group_Skills__c groupSkill : lstTechSkills){
            //String skillName = groupSkill.Name+'_'+groupSkill.SVMXC__Skill__r.Id+'_'+groupSkill.SVMXC__Skill__r.Name;
            String skillName = groupSkill.SVMXC__Skill__r.Id+'_'+groupSkill.SVMXC__Skill__r.Name;
            if(!mapTechIdSkills.containsKey(groupSkill.SVMXC__Group_Member__c))
                mapTechIdSkills.put(groupSkill.SVMXC__Group_Member__c, new List<String>());
            
            mapTechIdSkills.get(groupSkill.SVMXC__Group_Member__c).add(skillName);
        }
        return mapTechIdSkills;
    }*/

    public static Map<String, List<WSCH_LTP_Scheduling_Stubs.Expertise_WP>> getTechExpertiseMap(List<SVMXC__Service_Group_Members__c> lstTechs){
            Map<String, List<WSCH_LTP_Scheduling_Stubs.Expertise_WP>> mapTechIdSkills = new Map<String, List<WSCH_LTP_Scheduling_Stubs.Expertise_WP>>();
            set<Id> setTechIds = new set<Id>();
            for(SVMXC__Service_Group_Members__c tech : lstTechs){
                setTechIds.add(tech.Id);
            }
            List<SVMXC__Service_Group_Skills__c> lstTechSkills = [SELECT Id,IsDeleted,Name,SVMXC__Availability_Start_Date__c, SVMXC__Availability_End_Date__c, SVMXC__Group_Member__c,SVMXC__Skill__r.Id, SVMXC__Skill__r.Name,SVMXC__Skill__r.SVMXC__Active__c,SVMXC__Skill_Level__c FROM SVMXC__Service_Group_Skills__c WHERE SVMXC__Group_Member__c in :setTechIds AND IsDeleted = false AND SVMXC__Skill__r.SVMXC__Active__c = true limit 49999];
            //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getTechExpertiseMap():: lstTechSkills' +lstTechSkills);
            for(SVMXC__Service_Group_Skills__c groupSkill : lstTechSkills){
                WSCH_LTP_Scheduling_Stubs.Expertise_WP expertiseWP = new WSCH_LTP_Scheduling_Stubs.Expertise_WP();
                expertiseWP.id=groupSkill.SVMXC__Skill__r.Id;
                expertiseWP.validFrom=groupSkill.SVMXC__Availability_Start_Date__c;
                expertiseWP.validTo=groupSkill.SVMXC__Availability_End_Date__c;
                expertiseWP.level = groupSkill.SVMXC__Skill_Level__c;
                //String skill;
                //skill = groupSkill.SVMXC__Skill__r.Id+'_'+groupSkill.SVMXC__Availability_Start_Date__c+'_'+groupSkill.SVMXC__Availability_End_Date__c;
                //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getTechExpertiseMap():: groupSkill.SVMXC__Availability_Start_Date__c: ' +groupSkill.SVMXC__Availability_Start_Date__c + ' , groupSkill.SVMXC__Availability_End_Date__c: '+groupSkill.SVMXC__Availability_End_Date__c);
                //if(groupSkill.SVMXC__Availability_Start_Date__c != null && groupSkill.SVMXC__Availability_End_Date__c != null ){
                    //skill = groupSkill.SVMXC__Skill__r.Id+'_'+groupSkill.SVMXC__Skill__r.Name+'_'+groupSkill.SVMXC__Availability_Start_Date__c+'_'+groupSkill.SVMXC__Availability_End_Date__c;
                //}else{
                   // skill = groupSkill.SVMXC__Skill__r.Id+'_'+groupSkill.SVMXC__Skill__r.Name;
                //}
                //WSCH_AuditLogger.debug('WSCH_LTP_StageService_Handler::getTechExpertiseMap():: skill' +skill);
                if(!mapTechIdSkills.containsKey(groupSkill.SVMXC__Group_Member__c))
                    mapTechIdSkills.put(groupSkill.SVMXC__Group_Member__c, new List<WSCH_LTP_Scheduling_Stubs.Expertise_WP>());
                
                mapTechIdSkills.get(groupSkill.SVMXC__Group_Member__c).add(expertiseWP);
            }
            return mapTechIdSkills;
        } 
}