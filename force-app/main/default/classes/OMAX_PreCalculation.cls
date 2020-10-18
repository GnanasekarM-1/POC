global with sharing class OMAX_PreCalculation
{
    public static map<integer, SVMXC__Service_Order__c> mapWorkOrder = new map<integer, SVMXC__Service_Order__c>();
    public map<integer, SVMXC__Service_Order__c> mapNonOptiMaxWorkOrder = new map<integer, SVMXC__Service_Order__c>();
    public map<Id, SVMXC__ServiceMax_Processes__c> mapSVMXProcess = new map<Id, SVMXC__ServiceMax_Processes__c>();
    public static map<Id, SVMXC__ServiceMax_Processes__c> mapOmaxDispatchProcess = new map<Id, SVMXC__ServiceMax_Processes__c>();
    public static map<Id, SVMXC__ServiceMax_Processes__c> mapECODispatchProcess = new map<Id, SVMXC__ServiceMax_Processes__c>();
    public map<Id, SVMXC__ServiceMax_Processes__c> mapLTPDispatchProcess = new map<Id, SVMXC__ServiceMax_Processes__c>();
    public map<Id, SVMXC__ServiceMax_Processes__c> mapSVMXRule = new map<Id, SVMXC__ServiceMax_Processes__c>();
    public map<Id, SVMXC__ServiceMax_Processes__c> mapTerritoryRules = new map<Id, SVMXC__ServiceMax_Processes__c>();
    public map<Id, set<string>> mapDispProTerritory = new map<Id, set<string>>();
    public map<Id, SVMXC__ServiceMax_Config_Data__c> mapExpression = new map<Id, SVMXC__ServiceMax_Config_Data__c>();
    public map<Id, Account> mapCompany = new map<Id, Account>();
    public map<Id, BusinessHours> mapBusinessHours = new map<Id, BusinessHours>();
    public map<Id, SVMXC__Installed_Product__c> mapComponent = new map<Id, SVMXC__Installed_Product__c>();
    public map<Id, SVMXC__Site__c> mapLoc = new map<Id, SVMXC__Site__c>();
    public map<Id, Case> mapCases = new map<Id, Case>(); 
    public map<Id, SVMXC__Booking_Window__c> mapBookingWindow = new map<Id, SVMXC__Booking_Window__c>();
    public map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapDispProExp = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    public map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapTerritoryFieldMap = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    public map<Id, map<Id, list<SVMXC__ServiceMax_Config_Data__c>>> mapSimpleDispRulesExp = new map<Id, map<Id, list<SVMXC__ServiceMax_Config_Data__c>>>();
    public map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapTerritoryDispRulesExp = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    public map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapMTTSDispRulesExp = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    public map<Id, map<Id, list<SVMXC__ServiceMax_Config_Data__c>>> mapPriorityDispRulesExp = new map<Id, map<Id, list<SVMXC__ServiceMax_Config_Data__c>>>();
    public map<Id, map<Id, list<SVMXC__ServiceMax_Config_Data__c>>> mapCapacityLimitRulesExp = new map<Id, map<Id, list<SVMXC__ServiceMax_Config_Data__c>>>();
    public map<Integer, string> mapWODispPro = new map<Integer, string>();
    public map<Integer, string> mapWODispProOmax = new map<Integer, string>();
    public map<Id, Id> mapTertryDispProcess = new map<Id, Id>();
    public map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapAdvDispProExp = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    public map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapContDispProExp = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    public map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapECODispProExp = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    public map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapLTPDispProExp = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    
    public map<Id, list<SVMXC__ServiceMax_Config_Data__c>> NewMapAdvProExp = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    public map<integer, SVMXC__Service_Order__c> mapWOWithTerritory = new map<integer, SVMXC__Service_Order__c>();
    public map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapAllDispProExp = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();   
    public map<String, String> svmxSettingList;

    public set<string> setBookingWindow = new set<string>();
    public set<string> TechIds = new set<string>();
    public static set<String> setTerritoryIds = new set<String>();
    

    public COMM_SVMXC_Utils4 oUtils = new COMM_SVMXC_Utils4();
    //public SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    public static DCON_Utils dcUtils = new DCON_Utils();
    
    map<integer, integer> mapPriorityValue = new map<integer, integer>();
    map<Id, string> mapTechSFUser = new map<Id, string>();
    map<Id, string> mapSFUser = new map<Id, string>();
    map<Id, string> mapTechNonSFUser = new map<Id, string>();
    map<Id, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> mapTechEvnt = new map<Id, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>();
    map<Id, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> mapSvmxEvnt = new map<Id, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>();
    map<Id, double> MapTechDrivingTime = new map<Id, double>();
    map<Id, SVMXC__Service_Group_Members__c> MapTechIdTechRec = new map<Id, SVMXC__Service_Group_Members__c>();
    map<Id, map<Date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>> mapTechWrpDtSlotlst = null;
    map<Id, Id> mapTechIdWorkingHourId = new map<Id, Id>();
    map<Id, Id> mapTechIdBreakHourId = new map<Id, Id>();
    map<Id, set<Date>> mapBHIdSchedHorizDates = new map<Id, set<Date>>();
    set<Integer> setWOToBeScheduled = new set<Integer>();
    
    list<SVMXC__Service_Group_Members__c> TechList = new list<SVMXC__Service_Group_Members__c>();
    list<Event> TechEvntLst = new list<Event>();
    list<Event> SFEventList = new list<Event>();
    list<SVMXC__SVMX_Event__c> CustEvntLst = new list<SVMXC__SVMX_Event__c>();
    list<SVMXC__SVMX_Event__c> SVMXEventList = new list<SVMXC__SVMX_Event__c>();
    list<BusinessHours> lstBusinessHours = new list<BusinessHours>();
    list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> ListWrpDtSlot = new list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
    
    Boolean isChangeOwnerOnAssignement = true;
    Boolean ConsiderSameDay = true;

    string strWorkOrderExpertiseField = '';
    string strSLATimeStampForWO = ''; 
    string strSLATimeStampWOFieldAPIName;
    string strWorkOrderProductField = '';
    string EvntSubject = 'Name';

    Integer iDefaultPriority = 0;
    Integer iDefaultServiceDuration = 0;  
    Integer INumberofDays;
    Integer AvgDrivTimeinMin = 0;
    Integer ILeadTime = 0;

    DateTime dtmNow;
    DateTime dtmSchedulHorizEndTime;
    Date datSchedHorizEndDateMax;


    BusinessHours objDefaultBH;

    public integer getINumberofDays(){return INumberofDays;}
    public integer getAvgDrivTimeinMin(){return AvgDrivTimeinMin;}
    public boolean getConsiderSameDay(){return ConsiderSameDay;}
    public integer getILeadTime(){return ILeadTime;}
    public string getEvntSubject(){return EvntSubject;}
    
    public static Boolean isPrecalcExecuted = false;
    
    public OMAX_ManagePrecalcData.ObjectsDataWrapper objDataWrapper = new OMAX_ManagePrecalcData.ObjectsDataWrapper();
    
    global OMAX_PreCalculation() {}
    
    global OMAX_PreCalculation(map<String, String> TempsvmxSettingList, list<Account> LstAccount, list<Case> LstCase, list<SVMXC__Installed_Product__c> LstComponent)
    {
        setDefaultData(TempsvmxSettingList, LstAccount, LstCase, LstComponent);
    }
  
    public void setDefaultData(map<String, String> TempsvmxSettingList, list<Account> LstAccount, list<Case> LstCase, list<SVMXC__Installed_Product__c> LstComponent){
        svmxSettingList = TempsvmxSettingList;
        EvntSubject = svmxSettingList.get('SET015');
        for(Account acc: LstAccount)
            mapCompany.put(acc.Id, acc); 
        for(Case oCase: LstCase)
            mapCases.put(oCase.Id, oCase);
        for(SVMXC__Installed_Product__c IB: LstComponent)
            mapComponent.put(IB.Id, IB);
            
            //Set the above data on the Wrapper as well. This data will be used in OMAX_ManagePrecalcData
        objDataWrapper.mapComponent.putAll(mapComponent);
        objDataWrapper.mapCompany.putAll(mapCompany);
        objDataWrapper.mapCases.putAll(mapCases);
    }
    
    global OMAX_PreCalculation(map<String, String> TempsvmxSettingList, list<Account> LstAccount, list<Case> LstCase, list<SVMXC__Installed_Product__c> LstComponent, list<SVMXC__Site__c> lstLoc)
    {
        setDefaultData(TempsvmxSettingList, LstAccount, LstCase, LstComponent);
        mapLoc.putAll(lstLoc);
        
        //Set the location data on the Wrapper as well. This data will be used in OMAX_ManagePrecalcData
        objDataWrapper.mapLoc.putAll(mapLoc);
    }
  
    /* Invoked Pre - Create/Update of Work Order, for dispatch calculations */
    global void DoPrecalculation(list<SVMXC__Service_Order__c> lstworkOrder_LO, list<SVMXC__Service_Order__c> lstworkOrder_Old){
        system.debug(LoggingLevel.INFO, 'OMAX_Precalculation:DoPrecalculation:Start of DoPrecalculation function:No of Queries used in this apex code so far: ' + Limits.getQueries());
        system.debug(LoggingLevel.INFO, 'OMAX_Precalculation:DoPrecalculation:Start: Using Limits.getHeapSize() of total heap: Limits.getLimitHeapSize(): ' + Limits.getHeapSize() +' of ' + Limits.getLimitHeapSize());
        Long startTime = Datetime.now().getTime();
        system.debug('OMAX_Precalculation:DoPrecalculation:Start: startTime in milliseconds' + startTime);
        
        String strIsSkillSetCalcReq = 'true';
        //retrieve the Skill set calculation setting
       if(SVMX_Constants.AllsvmxSettingList.containsKey('OMAX003') && SVMX_Constants.AllsvmxSettingList.get('OMAX003') != null && SVMX_Constants.AllsvmxSettingList.get('OMAX003').size() > 0){
            map<String, String> mapSettingOMAX003 = new map<String, String>();
            mapSettingOMAX003 = SVMX_Constants.AllsvmxSettingList.get('OMAX003');
            system.debug('OMAX_Precalculation:DoPrecalculation:inside settings check: mapSettingOMAX003.get(\'SET056\') - ' + mapSettingOMAX003.get('SET056'));
            if(mapSettingOMAX003.containsKey('SET056') && mapSettingOMAX003.get('SET056') != null){
                strIsSkillSetCalcReq = mapSettingOMAX003.get('SET056');
                system.debug('OMAX_Precalculation:DoPrecalculation:inside condition: strIsSkillSetCalcReq - ' + strIsSkillSetCalcReq);
            }
        }
        
        //WSCH_AuditLogger.logGovernerLimits('Before Optimax Precalculation');
        //GBL007: OptiMax dispatch optimization engine is enabled or disabled using this setting. Work order precalculations are not performed if set to false.
        if(svmxSettingList.containsKey('GBL007') && svmxSettingList.get('GBL007').toUpperCase() == 'TRUE')
        {
            system.debug(LoggingLevel.INFO, 'Start of Precalculation section if GBL007 is True');
            system.debug(LoggingLevel.INFO, 'Number of Queries used in this apex code so far: ' + Limits.getQueries());

            /* From the list of input work orders, identify the work orders that qualify for pre-calc */
            integer iIndex = 0;
            for(SVMXC__Service_Order__c wo: lstworkOrder_LO)
            {
                if(wo != null && (wo.SVMXC__Dispatch_Now__c == 'Yes' || wo.SVMXC__Dispatch_Process__c == NULL || wo.SVMXC__OptiMax_Error_Occurred__c == true || ((svmxSettingList.get('SET002') != null) && (svmxSettingList.get('SET002').toUpperCase() == 'TRUE'))) && (wo.SVMXC__OptiMax_Status__c != 'Processing Complete' || wo.SVMXC__BatchUpdate__c == 'Yes') && wo.SVMXC__Locked_By_DC__c == false)
                //if(wo != null && (wo.SVMXC__Dispatch_Now__c == 'Yes' || wo.SVMXC__OptiMax_Error_Occurred__c == true || ((svmxSettingList.get('SET002') != null) && (svmxSettingList.get('SET002').toUpperCase() == 'TRUE'))) && (wo.SVMXC__OptiMax_Status__c != 'Processing Complete' || wo.SVMXC__BatchUpdate__c == 'Yes') && wo.SVMXC__Locked_By_DC__c == false)
                {
                    mapWorkOrder.put(iIndex, wo);
                    wo.SVMXC__Dispatch_Now__c = 'No';
                    iIndex++;
                }
            }

            //WSCH_AuditLogger.setLogContext(WSCH_AuditLogger.fetchTeritoryName(teritoryStr.split(',')[0]));
            system.debug(LoggingLevel.INFO, 'Start of dispatch parameter calculations: No of Queries used in this apex code so far: ' + Limits.getQueries());
            
            OMAX_ManagePrecalcData managePrecalcData = new OMAX_ManagePrecalcData();

            /* Proceed with pre-calc if there are work orders that qualified */
            if(mapWorkOrder.size() > 0)
            {
                 //system.debug(LoggingLevel.INFO, '1. Work Orders qualifying for pre-calc: Count - ' + mapWorkOrder.size() + '; Index - ' + mapWorkOrder.keySet() + '; Work Orders - ' + mapWorkOrder.values());
                 system.debug(LoggingLevel.INFO, '1. Work Orders qualifying for pre-calc: Count - ' + mapWorkOrder.size());

                /* Get the set & map of booking windows associated with the Cases. The map of Cases is built in constructor */
                //Commented out the below code while optimizing queries for philips. Below mapBookingWindow map not used in this class
                /*for(Case oCase :mapCases.Values())
                    setBookingWindow.add(oCase.SVMXC__Booking_Window__c);
                
                if ( setBookingWindow != null || setBookingWindow.size() > 0) 
                {
                    mapBookingWindow.putAll([SELECT  SVMXC__Start_Time__c, SVMXC__End_Time__c, SVMXC__Average_Slots__c, Id from SVMXC__Booking_Window__c where Id IN :setBookingWindow]);
                }*/
                
                //calling the below method from OMAX_ManagePrecalcData. This method iterates through all process objects across 
                //the org whose RecordType.Name is 'Dispatch Process' and 'SVMX Rule' and populates the respective maps
                managePrecalcData.seggregateProcessData(svmxSettingList);
                
                //get the svmxProcess map from OMAX_ManagePrecalcData class
                mapSVMXProcess = OMAX_ManagePrecalcData.mapSVMXProcess;
                system.debug('OMAX_Precalculation:DoPrecalculation: mapSVMXProcess.size():' + mapSVMXProcess.size());
                
            
                
                
                //get the seggregated maps data from the OMAX_ManagePrecalcData class
                mapDispProExp = managePrecalcData.getMapDispProExp();
                mapOmaxDispatchProcess = managePrecalcData.getMapOmaxDispatchProcess();
                mapAdvDispProExp = managePrecalcData.getMapAdvDispProExp();
                mapContDispProExp = managePrecalcData.getMapContDispProExp();
                mapECODispProExp = managePrecalcData.getMapECODispProExp();
                mapECODispatchProcess = managePrecalcData.getMapECODispatchProcess();
                mapLTPDispProExp = managePrecalcData.getMapLTPDispProExp();
                mapLTPDispatchProcess = managePrecalcData.getMapLTPDispatchProcess();
                mapAllDispProExp = managePrecalcData.getMapAllDispProExp();
                mapTerritoryRules = managePrecalcData.getMapTerritoryRules();
                mapDispProTerritory = managePrecalcData.getMapDispProTerritory();
                mapTertryDispProcess = managePrecalcData.getMapTertryDispProcess();
                mapSimpleDispRulesExp = managePrecalcData.getMapSimpleDispRulesExp();
                mapPriorityDispRulesExp = managePrecalcData.getMapPriorityDispRulesExp();
                mapCapacityLimitRulesExp = managePrecalcData.getMapCapacityLimitRulesExp();
                
                // system.debug('3. Immediate Dispatch Process entry criteria map: ' + mapDispProExp);
                // system.debug('4. Optimized Batch Dispatch Process entry criteria map: ' + mapAdvDispProExp);
                // system.debug('5. Territory Match Rules map: ' + mapTerritoryRules);
                 //system.debug('6. Dispatch Process - Territory set map: ' + mapDispProTerritory);
                 //WSCH_AuditLogger.debug('7. Territory - Dispatch Process map: ' + mapTertryDispProcess);
                // system.debug('8. Immediate Dispatch Process - Assignment Rules map: ' + mapSimpleDispRulesExp);
                // system.debug('9. Optimized Batch Dispatch Process - Prioritization Rules map: ' + mapPriorityDispRulesExp);

                //WSCH_AuditLogger.debug('Real Time Optimization Dispatch Process entry criteria map: ' + mapECODispProExp);
                system.debug(LoggingLevel.INFO, 'OMAX_Precalculation:DoPrecalculation:Before Get the expression rows for all the rules / processes identified');
                system.debug(LoggingLevel.INFO, 'OMAX_Precalculation:DoPrecalculation:Number of Queries used in this apex code so far: ' + Limits.getQueries());
               
                managePrecalcData.seggregateConfigData(mapSVMXProcess, svmxSettingList);
                
                //get the Expression map from OMAX_ManagePrecalcData class
                //mapExpression = managePrecalcData.getMapExpression();
                mapExpression = OMAX_ManagePrecalcData.mapExpression;
                //system.debug(LoggingLevel.INFO, 'OMAX_ManagePrecalcData.mapExpression - ' + OMAX_ManagePrecalcData.mapExpression);
                
                //get the seggregated maps data from the OMAX_ManagePrecalcData class
                mapTerritoryFieldMap = managePrecalcData.getMapTerritoryFieldMap();
                mapMTTSDispRulesExp = managePrecalcData.getMapMTTSDispRulesExp();
                mapTerritoryDispRulesExp = managePrecalcData.getMapTerritoryDispRulesExp();
                
                system.debug('10. Territory Match Rule - Field Map List map: ' + mapTerritoryFieldMap);
                // system.debug('11. MTTS Rules map: ' + mapMTTSDispRulesExp);
                system.debug('12. Territory Match Rules entry criteria map: ' + mapTerritoryDispRulesExp);
                
   
                this.doTerritoryMatchRule();
                
                //system.debug(LoggingLevel.INFO, 'OMAX_Precalculation:DoPrecalculation:after remove Omax DP mapWODispPro -' + mapWODispPro);
                system.debug(LoggingLevel.INFO, 'OMAX_Precalculation:DoPrecalculation:Before doing the dispatch parameter calculations: No of Queries used in this apex code so far: ' + Limits.getQueries());

                // Do the dispatch parameter calculations
                this.doDispatchParamCalculations(mapWorkOrder, svmxSettingList, lstworkOrder_Old);
                
            } // End of dispatch parameter calculations for the list of work orders that qualified for pre-calc

            system.debug(LoggingLevel.INFO, 'OMAX_Precalculation:DoPrecalculation:Start of section that handles data prep and work order update if events have to be scheduled for technicians');
            system.debug(LoggingLevel.INFO, 'OMAX_Precalculation:DoPrecalculation:Number of Queries used in this apex code so far: ' + Limits.getQueries());
            
            // system.debug('19. Scheduling events for ' + setWOToBeScheduled.size() + ' Immediate Dispatch work orders (' + setWOToBeScheduled + ') to Techs: ' + TechIds);
            // If any Work Order has to be scheduled to the assigned Technician immediately, prepare data for Event Scheduling
            
            //TechIds is set in UpdateWorkOrderForSimpleDispatch() only in case of Immediate DP.
            if(TechIds != null && !TechIds.isEmpty()) {
                this.doProcessTechnicians(TechIds, svmxSettingList);
            }
            
            system.debug(LoggingLevel.INFO, 'OMAX_Precalculation:DoPrecalculation:Before Invoke skill match calculation: No of Queries used in this apex code so far: ' + Limits.getQueries());
            
            //Skill computation alone moved back again here(before insert/update). 
            //To avoid explicit wo update for considering PB immediate assignment issue.
            system.debug('OMAX_Precalculation:DoPrecalculation::strIsSkillSetCalcReq -'+strIsSkillSetCalcReq);
            if(strIsSkillSetCalcReq.equalsIgnoreCase('true')) {
                this.doSkillandQTLCompute(mapWorkOrder);
            }
            
            system.debug(LoggingLevel.INFO, 'OMAX_Precalculation:DoPrecalculation:End of pre-calculation section: No of Queries used in this apex code so far: ' + Limits.getQueries());
        } // End of pre-calculation section that gets executed if GBL007 is True
        
        //setting the boolean below to true to mark that precalc has been successfully computed
        OMAX_PreCalculation.isPrecalcExecuted = true;
        
        system.debug(LoggingLevel.INFO, 'OMAX_Precalculation:DoPrecalculation:End: Using Limits.getHeapSize() of total heap: Limits.getLimitHeapSize() :' + Limits.getHeapSize() +' of ' + Limits.getLimitHeapSize());
        system.debug(LoggingLevel.INFO, 'OMAX_Precalculation:DoPrecalculation:End of function DoPrecalculation: No of Queries used in this apex code so far: ' + Limits.getQueries());
        
        //WSCH_AuditLogger.debug('OMAX_Precalculation:DoPrecalculation:End: Using Limits.getHeapSize() of total heap: Limits.getLimitHeapSize() :' + Limits.getHeapSize() +' of ' + Limits.getLimitHeapSize());
        //WSCH_AuditLogger.debug('OMAX_Precalculation:DoPrecalculation:End of function DoPrecalculation: No of Queries used in this apex code so far: ' + Limits.getQueries());
        //WSCH_AuditLogger.logGovernerLimits('After Optimax Precalculation');
    }
    
    private boolean isUpdateDuration(String processId, SVMXC__Service_Order__c newWO, list<SVMXC__Service_Order__c> lstworkOrder_Old, map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapMTTSRulesExp){
        boolean isFieldChanged = false;
        if(lstworkOrder_Old != null){
            for(SVMXC__Service_Order__c oldWO : lstworkOrder_Old){
                if(oldWO.Id == newWO.Id){
                    for(SVMXC__ServiceMax_Config_Data__c cfgData : mapMTTSRulesExp.get(processId)){
                        if(newWO.get(cfgData.SVMXC__Field_Name__c) != oldWO.get(cfgData.SVMXC__Field_Name__c)){
                            isFieldChanged = true;
                            break;
                        }
                    }
                    break;
                }
            }
        }else{
            isFieldChanged = true;
        }
        return isFieldChanged;          
    }

    private boolean isOptiMaxWO(SVMXC__Service_Order__c newWO,map<Id, SVMXC__ServiceMax_Processes__c> mapOptiMaxDP){
        if(newWO != null && newWO.SVMXC__Dispatch_Process__c != NULL){
            if(mapOptiMaxDP.ContainsKey(newWO.SVMXC__Dispatch_Process__c)){
                return true;
            }
        }
        return false;
    }
    
    private boolean isOptiMaxECOWO(SVMXC__Service_Order__c newWO,map<Id, SVMXC__ServiceMax_Processes__c> mapOptiMaxECODP){
        if(newWO != null && newWO.SVMXC__Dispatch_Process__c != NULL){
            if(mapOptiMaxECODP.ContainsKey(newWO.SVMXC__Dispatch_Process__c)){
                return true;
            }
        }
        return false;
    } 
    
    private boolean isOptiMaxLTPWO(SVMXC__Service_Order__c newWO,map<Id, SVMXC__ServiceMax_Processes__c> mapOptiMaxLTPDP){
        if(newWO != null && newWO.SVMXC__Dispatch_Process__c != NULL){
            if(mapOptiMaxLTPDP.ContainsKey(newWO.SVMXC__Dispatch_Process__c)){
                return true;
            }
        }
        return false;
    }   
    
    private boolean isUpdateEndTime(SVMXC__Service_Order__c newWO, list<SVMXC__Service_Order__c> lstworkOrder_Old){
        boolean isFieldChanged = false;
        if(lstworkOrder_Old != null){
            for(SVMXC__Service_Order__c oldWO : lstworkOrder_Old){
                if(oldWO.Id == newWO.Id){
                    /*Datetime slaEndTime = (DateTime)(newWO.get(strSLATimeStampWOFieldAPIName));
                    if(slaEndTime != oldWO.SVMXC__Preferred_End_Time__c){
                        isFieldChanged = true;
                    }
                    break;*/
                    Datetime newSlaEndTime = (DateTime)(newWO.get(strSLATimeStampWOFieldAPIName));
                    Datetime oldSlaEndTime = (DateTime)(oldWO.get(strSLATimeStampWOFieldAPIName));
                    if(newSlaEndTime != oldSlaEndTime && newSlaEndTime != oldWO.SVMXC__Preferred_End_Time__c){
                        isFieldChanged = true;
                    }
                    break;
                }
            }
        }       
        return isFieldChanged;
    }
    
    
    /* Invoked Pre - Create/Update of Work Order, for dispatch calculations */
    global void DoPrecalculation(list<SVMXC__Service_Order__c> lstworkOrder_LO)
    {
        //This code moved to the above method for MTTS recalculation related fix.
    } 
    
    /* Utility function called by DoPrecalculation for putting an expression row associated with an expression, creating the relevant maps & lists as needed */
    public void putExpressionInMap(map<Id, map<Id, list<SVMXC__ServiceMax_Config_Data__c>>> m, SVMXC__ServiceMax_Config_Data__c oExp)
    {
        if(oExp.SVMXC__Expression_Rule__c != null && mapSVMXProcess.get(oExp.SVMXC__Expression_Rule__c) != null && mapSVMXProcess.get(oExp.SVMXC__Expression_Rule__c).SVMXC__Process__c != null)
        {
            if(!m.containsKey(mapSVMXProcess.get(oExp.SVMXC__Expression_Rule__c).SVMXC__Process__c))
            {
                map<Id, list<SVMXC__ServiceMax_Config_Data__c>> maptemp = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
                maptemp.put(oExp.SVMXC__Expression_Rule__c, new list<SVMXC__ServiceMax_Config_Data__c>());
                m.put(mapSVMXProcess.get(oExp.SVMXC__Expression_Rule__c).SVMXC__Process__c, maptemp);
            }
            else if(mapSVMXProcess.get(oExp.SVMXC__Expression_Rule__c).SVMXC__Process__c != null && !m.get(mapSVMXProcess.get(oExp.SVMXC__Expression_Rule__c).SVMXC__Process__c).containsKey(oExp.SVMXC__Expression_Rule__c))
                m.get(mapSVMXProcess.get(oExp.SVMXC__Expression_Rule__c).SVMXC__Process__c).put(oExp.SVMXC__Expression_Rule__c, new list<SVMXC__ServiceMax_Config_Data__c>());
            if(mapSVMXProcess.get(oExp.SVMXC__Expression_Rule__c).SVMXC__Process__c != null && m.get(mapSVMXProcess.get(oExp.SVMXC__Expression_Rule__c).SVMXC__Process__c) != null && m.get(mapSVMXProcess.get(oExp.SVMXC__Expression_Rule__c).SVMXC__Process__c).get(oExp.SVMXC__Expression_Rule__c) != null)
                m.get(mapSVMXProcess.get(oExp.SVMXC__Expression_Rule__c).SVMXC__Process__c).get(oExp.SVMXC__Expression_Rule__c).add(oExp);
        }
    }

    /* Invoked by DoPrecalculation to update the work order based on matched Immediate Dispatch assignment rules */
    public SVMXC__Service_Order__c UpdateWorkOrderForSimpleDispatch(Integer woIndex, SVMXC__Service_Order__c oWO, SVMXC__ServiceMax_Processes__c oProcess)
    {
        if(oProcess.SVMXC__Assign_Work_Order_To__c == 'Technician')
        {
            oWO.SVMXC__Group_Member__c = oProcess.SVMXC__Assign_To_Technician__c;
            oWO.SVMXC__Service_Group__c = oProcess.SVMXC__Technician_Service_Group__c;
            oWO.SVMXC__Member_Email__c = oProcess.SVMXC__Assign_To_Technician__r.SVMXC__Email__c;
            oWO.SVMXC__Last_Dispatch_Event__c = 'Assigned';
            if(oProcess.SVMXC__Schedule_Event__c)
            {
                TechIds.add(oProcess.SVMXC__Assign_To_Technician__c);
                setWOToBeScheduled.add(woIndex);
            }
            if(isChangeOwnerOnAssignement && oProcess.SVMXC__Technician_User__c != null)
                oWO.OwnerId = oProcess.SVMXC__Technician_User__c;
        }
        else if(oProcess.SVMXC__Assign_Work_Order_To__c == 'Dispatcher')
        {
            oWO.SVMXC__Group_Member__c = null;
            oWO.SVMXC__Service_Group__c = null;
            oWO.OwnerId = oProcess.SVMXC__Assign_To_Dispatcher__c;
        }
        else if(oProcess.SVMXC__Assign_Work_Order_To__c == 'Queue')
        {
            oWO.SVMXC__Group_Member__c = null;
            oWO.SVMXC__Service_Group__c = null;
            oWO.OwnerId = oProcess.SVMXC__Assign_To_Queue__c;
        }
        else
        {
            oWO.SVMXC__Group_Member__c = null;
            oWO.SVMXC__Service_Group__c = null;
        }
        return oWO;
    }

    /* Invoked Post - Create/Update of Work Order, for creating Immediate Dispatch Events */
    public void CreateEvents(list<SVMXC__Service_Order__c> lstworkOrderNew, list<SVMXC__Service_Order__c> lstworkOrderold)
    {
        list<Id> TechIds = new list<Id>();
        list<SVMXC__Service_Group_Members__c> TechListnew = new list<SVMXC__Service_Group_Members__c>();
        map<string, string> mapTechSFUsernew = new map<string, string>();
        map<string, string> mapSFUsernew = new map<string, string>();
        map<string, string> mapTechNonSFUsernew = new map<string, string>();
        //system.debug('lstworkOrderNew  '+lstworkOrderNew);
        //system.debug('lstworkOrderold  '+lstworkOrderold);
        // GBL007: OptiMax dispatch optimization engine is enabled or disabled using this setting. Work order precalculations are not performed if set to false. 
        if(svmxSettingList.containsKey('GBL007') && svmxSettingList.get('GBL007').toUpperCase() == 'TRUE')
        {
            // Get the details of technicians assigned to the worked orders
            for(SVMXC__Service_Order__c oWO :lstworkOrderNew)
                TechIds.add(oWO.SVMXC__Group_Member__c);
            // system.debug('32. Techs assigned to work orders: ' + TechIds);
            TechListnew = [Select SVMXC__Working_Hours__c, SVMXC__Salesforce_User__c, SVMXC__Enable_Scheduling__c, Id From SVMXC__Service_Group_Members__c where Id IN: TechIds];
            system.debug('Invoked Post - Create/Update of Work Order, for creating Immediate Dispatch Events : No of Queries used in this apex code so far: ' + Limits.getQueries());            
            for(SVMXC__Service_Group_Members__c tech : TechListnew)
            {
                if(tech.SVMXC__Salesforce_User__c != null)
                {
                    mapTechSFUsernew.put(tech.SVMXC__Salesforce_User__c, tech.Id);
                    MapSFUsernew.put(tech.Id, tech.SVMXC__Salesforce_User__c);               
                }                          
                else
                {
                    if(tech.SVMXC__Enable_Scheduling__c)
                        mapTechNonSFUsernew.put(tech.Id, tech.Id);                   
                } 
            }

            // Build maps with updated work orders' pre-update details and pre-update scheduled date time
            map<string, dateTime> MapOldWOSchdDateTime = new map<string, dateTime>();
            map<string, SVMXC__Service_Order__c> MapOldWOValues = new map<string, SVMXC__Service_Order__c>();
            if(lstworkOrderold != null && lstworkOrderold.size() > 0)
            {
                for(SVMXC__Service_Order__c w : lstworkOrderold)
                {
                    MapOldWOSchdDateTime.put(w.Id, w.SVMXC__Scheduled_Date_Time__c);
                    MapOldWOValues.put(w.Id, w);             
                }             
            }
             system.debug('33. Map of pre-update scheduled date time of updated work orders: ' + MapOldWOSchdDateTime);

            // Process the post-update / new details of the list of work orders
            for(integer i = 0; i < lstworkOrderNew.size(); i++)
            {
                SVMXC__Service_Order__c wo = lstworkOrderNew[i];

                // If it is a DC work order or completed OptiMax work order or work order with error or if the technician or scheduled date time is null, do not proceed
                if(wo == null || wo.SVMXC__Dispatch_Process__c == NULL || wo.SVMXC__OptiMax_Error_Occurred__c == true || wo.SVMXC__OptiMax_Status__c == 'Processing Complete' || wo.SVMXC__Locked_By_DC__c == true || wo.SVMXC__Group_Member__c == null || wo.SVMXC__Scheduled_Date_Time__c == null)
                    continue;
                               
                // if its a ServicePower work order, do not proceed
                if(wo.SVMXC__OptiMax_Status__c == 'OPT_TENTATIVE' || wo.SVMXC__OptiMax_Status__c == 'OPT_COMPLETED' || wo.SVMXC__Scheduling_Change_Token__c != null || wo.SVMXC__SM_Optimizer_Message_Creation_Date_Time__c != null)
                    continue;
                    
                // Get the driving time and service duration and calculate total event duration
                integer DriveSec = 0;
                integer TotalTime = 0;
                if(wo.SVMXC__Service_Duration__c != null && wo.Driving_Time__c != null)
                {
                    DriveSec = wo.Driving_Time__c.intValue() * 60 ;
                    TotalTime = wo.SVMXC__Service_Duration__c.intValue() + DriveSec;
                }

                // If the work order is an updated work order:
                if(MapOldWOValues.containsKey(wo.Id))
                {
                    SVMXC__Service_Order__c Owo = MapOldWOValues.get(wo.Id);

                    // Do not proceed if there is no change in Dispatch Process and Technician and Scheduled Date Time
                    if(wo.SVMXC__Dispatch_Process__c == Owo.SVMXC__Dispatch_Process__c && wo.SVMXC__Group_Member__c == Owo.SVMXC__Group_Member__c && wo.SVMXC__Scheduled_Date_Time__c == Owo.SVMXC__Scheduled_Date_Time__c)
                        continue;
                    
                    // Do not proceed if the work order was previously scheduled and if the old scheduled date time is the same as the new scheduled date time
                    // TBD: What if the scheduled date time is the same, but scheduled tech is different?
                    if(MapOldWOSchdDateTime.containsKey(wo.Id) && MapOldWOSchdDateTime.get(wo.Id) == wo.SVMXC__Scheduled_Date_Time__c)
                        continue;
                }

                 //system.debug('34. Creating event for work order: ' + wo.Id + ' - ' + wo.Name);
                if(MapSFUsernew.containsKey(wo.SVMXC__Group_Member__c))
                {                                                              
                    Event tempEventTech = new Event();
                    try
                    {
                        tempEventTech.Subject = string.valueOf(wo.get(EvntSubject));
                    }
                    catch(Exception ex)
                    {
                        tempEventTech.Subject = wo.Name;
                    }
                    tempEventTech.OwnerId = MapSFUsernew.get(wo.SVMXC__Group_Member__c);
                    tempEventTech.WhatId = wo.Id;
                    tempEventTech.startDateTime = wo.SVMXC__Scheduled_Date_Time__c.addSeconds(-DriveSec);
                    tempEventTech.EndDateTime = tempEventTech.startDateTime.addSeconds(TotalTime);
                    if(wo.SVMXC__Latitude__c != null && wo.SVMXC__Longitude__c != null)
                        tempEventTech.Location = wo.SVMXC__Latitude__c + ', ' + wo.SVMXC__Longitude__c ;
                    SFEventList.add(tempEventTech);
                }
                else if(mapTechNonSFUsernew.containsKey(wo.SVMXC__Group_Member__c))
                {
                    SVMXC__SVMX_Event__c tempEventWo = new SVMXC__SVMX_Event__c();
                    try
                    {
                        tempEventWo.Name = string.valueOf(wo.get(EvntSubject));
                    }
                    catch(Exception ex)
                    {
                        tempEventWo.Name = wo.Name;
                    }
                    tempEventWo.SVMXC__Technician__c = wo.SVMXC__Group_Member__c;
                    tempEventWo.SVMXC__WhatId__c = wo.Id;
                    tempEventWo.SVMXC__StartDateTime__c = wo.SVMXC__Scheduled_Date_Time__c.addSeconds(-DriveSec);    
                    tempEventWo.SVMXC__EndDateTime__c = tempEventWo.SVMXC__StartDateTime__c.addSeconds(TotalTime);
                    tempEventWo.SVMXC__DurationInMinutes__c = TotalTime / 60;
                    if(wo.SVMXC__Latitude__c != null && wo.SVMXC__Longitude__c != null)
                        tempEventWo.SVMXC__Location__c = wo.SVMXC__Latitude__c + ', ' + wo.SVMXC__Longitude__c;
                    SVMXEventList.add(tempEventWo);
                }
            }
            system.debug('OMAX_PreCalculation SFEventList  '+SFEventList);
            system.debug('OMAX_PreCalculation SVMXEventList  '+SVMXEventList);
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( SFEventList, COMM_SecurityUtils.Access.Createable) ) { //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                insert SFEventList;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException(system.label.COMM001_TAG142);
            }
            
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( SVMXEventList, COMM_SecurityUtils.Access.Createable) ) { //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                insert SVMXEventList;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException(system.label.COMM001_TAG142);
            }
        }
    }
    
    public void doTerritoryMatchRule() {
        
        system.debug('OMAX_Precalculation:doTerritoryMatchRule start');
        system.debug('OMAX_Precalculation:doTerritoryMatchRule:Start: Using Limits.getHeapSize() of total heap: Limits.getLimitHeapSize() : ' + Limits.getHeapSize() +' of ' + Limits.getLimitHeapSize());
        //Get the value of the Optimization service providers from settings
        Map<String, boolean> mapOfServiceProvidersAndVal = getServiceProviderValue(svmxSettingList);
        boolean batchOptimization = mapOfServiceProvidersAndVal.get('Batch_Optimization');
        boolean servicePower = mapOfServiceProvidersAndVal.get('Service_Power');
        boolean eCOptimization = mapOfServiceProvidersAndVal.get('Eco_Optimization');
        boolean longTermPlanner = mapOfServiceProvidersAndVal.get('Long_Term_Planner');
        
        // system.debug('10. Territory Match Rule - Field Map List map: ' + mapTerritoryFieldMap);
        // system.debug('11. MTTS Rules map: ' + mapMTTSDispRulesExp);
        // system.debug('12. Territory Match Rules entry criteria map: ' + mapTerritoryDispRulesExp);
        
        string strWhereClause = '';
        string strTempCondition = '';
        map<integer, Id> mapWOIdTerritoryId = new map<integer, Id>();
        map<integer, String> mapWOIdTerritoryIdStr = new map<integer, String>();
        Integer iWOIndex = 0;
        //set<String> setTerritoryIds = new set<String>();
        
        /*Check if Territory Match Rule related calculation is required or not. 
        If required then allow to populate Primary Territory from TMR.
        Else skip the TMR calculation and use the existing Primary Territory in WO*/
        String strTMRrequired='';
        if(SVMX_Constants.AllsvmxSettingList.containsKey('OMAX003') && SVMX_Constants.AllsvmxSettingList.get('OMAX003') != null && SVMX_Constants.AllsvmxSettingList.get('OMAX003').size() > 0){
            map<String, String> mapEachSetting = new map<String, String>();
            mapEachSetting = SVMX_Constants.AllsvmxSettingList.get('OMAX003');
            system.debug('Territory Match Rule calcuation required - ' + mapEachSetting.get('SET049'));
            if(mapEachSetting.containsKey('SET049') && mapEachSetting.get('SET049') != null){
                strTMRrequired = mapEachSetting.get('SET049');
            }
        }
        
        if(strTMRrequired.equalsIgnoreCase('true')){
        /* For each Work Order, get the matching territory and also build the where clause for each territory to get the the territory coverage */
        for(SVMXC__Service_Order__c oWO : mapWorkOrder.values())
        {
            /* Get the Territory Match Rule */
            string IdTerritoryRule = oUtils.SVMX_ExpressionParsing((SObject)oWO, mapTerritoryDispRulesExp, mapSVMXProcess);
            system.debug('Matched Territory Match Rule Id.... ' + IdTerritoryRule);
            /* If the work order has a territory match rule, include the work order field values in the Territory Coverage query where clause */
            if(IdTerritoryRule != null && IdTerritoryRule.length() > 0)
            {
                mapWOIdTerritoryId.put(iWOIndex, IdTerritoryRule);
                if(mapTerritoryFieldMap.get(IdTerritoryRule) != null && mapTerritoryFieldMap.get(IdTerritoryRule).size() > 0)
                {
                    for(SVMXC__ServiceMax_Config_Data__c o :mapTerritoryFieldMap.get(IdTerritoryRule))
                    {
                        if(o.SVMXC__Source_Field_Name__c != 'SVMX.NONE' && o.SVMXC__Target_Field_Name__c != 'SVMX.NONE' && o.SVMXC__Source_Field_Name__c != null && o.SVMXC__Target_Field_Name__c != null && oWO.get(o.SVMXC__Target_Field_Name__c) != NULL)
                        {
                            strTempCondition = ' ( SVMXC__Type__c = \'' + o.SVMXC__Source_Field_Name__c + '\' AND SVMXC__Value__c = \'' + string.escapeSingleQuotes(String.valueOf(oWO.get(o.SVMXC__Target_Field_Name__c))) + '\' ) ';
                            system.debug('Inside doTerritoryMatchRule() - strTempCondition:' + strTempCondition);
                            if (!strWhereClause.contains(strTempCondition))
                            {
                                if(strWhereClause.length() > 0)
                                    strWhereClause += ' OR ';
                                strWhereClause += strTempCondition;
                                system.debug('Inside doTerritoryMatchRule() - strWhereClause:' + strWhereClause);
                            }
                        }
                    }
                }
            }
            iWOIndex++;
        }
        //system.debug(LoggingLevel.INFO, 'OMAX_Precalculation:doTerritoryMatchRule: WO Index - Territory Match Rule Id map: ' + mapWOIdTerritoryId);
        //system.debug('13a. WO Index - Territory Match Rule Id map: ' + mapWOIdTerritoryIdStr);
        
        system.debug('OMAX_Precalculation:doTerritoryMatchRule: Before Get the territory coverage:No of Queries used in this apex code so far: ' + Limits.getQueries());

        /* Get the territory coverage for all the territories based on the where clause built above */
        list<SVMXC__Territory_Coverage__c> lstTerritoryCoverage = new list<SVMXC__Territory_Coverage__c>();
        // system.debug('14. Territory Coverage query: ' + 'select  SVMXC__Value__c, SVMXC__Type__c, SVMXC__Territory__c, Id from SVMXC__Territory_Coverage__c where ( ' + strWhereClause +' )'); // Removed unused fields SVMXC__Record_Type_Name__c, SVMXC__Adjacent_Territory__c, and SVMXC__Active__c  from query string.
        if(strWhereClause != null && strWhereClause.Length() > 0 )
            lstTerritoryCoverage = database.Query('select  SVMXC__Value__c, SVMXC__Type__c, SVMXC__Territory__c, Id from SVMXC__Territory_Coverage__c where ( ' + strWhereClause +' )');

        /* Build a map of territories and associated coverage records */
        map<string, list<SVMXC__Territory_Coverage__c>> mapTerritoryTerritoryCoverage = new map<string, list<SVMXC__Territory_Coverage__c>>();
        if(lstTerritoryCoverage != null)
        {
            for(SVMXC__Territory_Coverage__c oTC :lstTerritoryCoverage)
            {
                if(!mapTerritoryTerritoryCoverage.containsKey(oTC.SVMXC__Territory__c))
                    mapTerritoryTerritoryCoverage.put(oTC.SVMXC__Territory__c, new list<SVMXC__Territory_Coverage__c>());
                mapTerritoryTerritoryCoverage.get(oTC.SVMXC__Territory__c).add(oTC);
            }
        }
        system.debug('15. Number of territories with coverage: ' + mapTerritoryTerritoryCoverage.size() + '; Territory ID - Coverage map: ' + mapTerritoryTerritoryCoverage);

        /* For Work Orders with Territory Match Rule, find the Primary Territory */
        //set<String> setTerritoryIds = new set<String>();
        for(integer iWOIndex2 : mapWOIdTerritoryId.keySet())
        {
            SVMXC__Service_Order__c oWOd = mapWorkOrder.get(iWOIndex2);
            if(oWOd == null)
            {
                // system.debug('16. Work Order Index ' + iWOIndex2 + ' not found in mapWorkOrder');
                continue;
            }
            oWOd.SVMXC__Primary_Territory__c = null;
            list<SVMXC__ServiceMax_Config_Data__c> lstFieldMap = mapTerritoryFieldMap.get(mapWOIdTerritoryId.get(iWOIndex2));
            if(lstFieldMap != null && lstFieldMap.Size() > 0)
            {
                for(string strTerritoryId : mapTerritoryTerritoryCoverage.keyset())
                {
                    Boolean isTerritoryFound = true;                              
                    for(SVMXC__ServiceMax_Config_Data__c fieldMap : lstFieldMap)
                    {
                        if(isTerritoryFound) // If it is the first iteration, or if a match was found for the previous field in the map
                            isTerritoryFound = false;
                        else // If no match was found for the previous field in the map, this territory will not match; so exit this loop and check the next territory
                            break;
                        for(SVMXC__Territory_Coverage__c objTerrCoverage : mapTerritoryTerritoryCoverage.get(strTerritoryId))
                        {
                            if(objTerrCoverage != null && objTerrCoverage.SVMXC__Territory__c != null)
                            {
                                if(objTerrCoverage.SVMXC__Type__c == fieldMap.SVMXC__Source_Field_Name__c)
                                {
                                    // If a match is found for the current field in the map, exit this loop and check the next field
                                    if(objTerrCoverage.SVMXC__Value__c == oWOd.get(fieldMap.SVMXC__Target_Field_Name__c))
                                    {
                                        isTerritoryFound = true;
                                        break;
                                    }
                                }
                            }
                        } // End of Territory Coverage Map loop
                    } // End of Field Map loop

                    // If a matching territory is found after matching all the fields in the match field map, set the primary territory and exit the territory map loop
                    if(isTerritoryFound)
                    {
                        oWOd.SVMXC__Primary_Territory__c = strTerritoryId;
                        setTerritoryIds.add(strTerritoryId);
                        mapWOWithTerritory.put(iWOIndex2, oWOd);
                        break;
                    }
                } // End of Territory Map loop
            }
         }
        }else{
            /*Adding territory Id into set and work order into map for DP calculation. 
            These work orders not qualified for TMR but having Primary Territory in WO*/
            Integer iWOIndex3 = 0;
            for(SVMXC__Service_Order__c oWO : mapWorkOrder.values())
            {
                if(oWO.SVMXC__Primary_Territory__c != null){
                    setTerritoryIds.add(oWO.SVMXC__Primary_Territory__c);
                    mapWOWithTerritory.put(iWOIndex3, oWO);
                }
                iWOIndex3++;
            }                   
        }                 
        //system.debug(LoggingLevel.INFO,'OMAX_Precalculation:doTerritoryMatchRule:setTerritoryIds-'+setTerritoryIds);

        //WSCH_AuditLogger.debug('Real Time Optimization Dispatch Process entry criteria map: ' + mapECODispProExp);
        if(setTerritoryIds != null && setTerritoryIds.size() > 0)
        {
            // Find the Optimized Batch Dispatch Process for the set of Primary Territories found above
            for(String strTerrID : setTerritoryIds)
            {
                system.debug('OMAX_Precalculation:doTerritoryMatchRule:strTerrID: ' + strTerrID);
                if(mapTertryDispProcess.containsKey(strTerrID) && batchOptimization && eCOptimization && longTermPlanner) {
                    // check if entry criteria present in BATCH dp map
                    // else check if entry criteria present in ECO dp map
                    /*list<SVMXC__ServiceMax_Config_Data__c> configData = mapAdvDispProExp.get(mapTertryDispProcess.get(strTerrID));
                    if((configData == null) || (configData != null && configData.size() == 0))
                        configData = mapECODispProExp.get(mapTertryDispProcess.get(strTerrID));
                    NewMapAdvProExp.put(mapTertryDispProcess.get(strTerrID), configData);*/
                    
                    list<SVMXC__ServiceMax_Config_Data__c> configData = mapAdvDispProExp.get(mapTertryDispProcess.get(strTerrID));
                    if((configData == null) || (configData != null && configData.size() == 0)) {
                        configData = mapECODispProExp.get(mapTertryDispProcess.get(strTerrID));
                    }
                    if((configData == null) || (configData != null && configData.size() == 0)) {
                        configData = mapLTPDispProExp.get(mapTertryDispProcess.get(strTerrID));
                    }  
                    NewMapAdvProExp.put(mapTertryDispProcess.get(strTerrID), configData);
                }
            }
            
            //system.debug('OMAX_Precalculation:doTerritoryMatchRule:NewMapAdvProExp: ' + NewMapAdvProExp);
            // If Optimized Batch Dispatch Process has been found for one or more Primary Territories,
            //    calculate the dispatch process for the related work orders using the entry criteria
            if(NewMapAdvProExp.size() > 0)
                mapWODispProOmax = oUtils.SVMX_ExpressionParsing(mapWOWithTerritory, NewMapAdvProExp, mapSVMXProcess);
        }

        //Find applicable dispatch process for all work orders using sequence
        if(mapAllDispProExp.size() > 0){
            mapWODispPro = oUtils.SVMX_ExpressionParsing(mapWorkOrder, mapAllDispProExp, mapSVMXProcess);
        }

        system.debug('OMAX_Precalculation:doTerritoryMatchRule:mapWODispPro size() -'+mapWODispPro.size());
        system.debug('OMAX_Precalculation:doTerritoryMatchRule:mapWODispProOmax size() -'+mapWODispProOmax.size());
        //Remove the optmax dispatch process if primary territory not found in the WO
        if(mapWODispPro.size() > 0 ){
            for(Integer index : mapWODispPro.keySet()){
                Id dispatchProcessId = mapWODispPro.get(index);
                SVMXC__ServiceMax_Processes__c processObj = mapSVMXProcess.get(dispatchProcessId);
                if(processObj != null && (processObj.SVMXC__Dispatch_Method__c == 'Optimized Batch' || processObj.SVMXC__Dispatch_Method__c == 'Real Time Optimization' ||
                                                processObj.SVMXC__Dispatch_Method__c == 'Long-Term Planner')){
                    system.debug('OMAX_Precalculation:doTerritoryMatchRule:Dispatch Method is Optimized Batch. So remove this process if primary territory not found in the WO');
                    system.debug('OMAX_Precalculation:doTerritoryMatchRule:index: ' + index);
                    system.debug('OMAX_Precalculation:doTerritoryMatchRule:mapWODispProOmax: ' + mapWODispProOmax);
                    system.debug('OMAX_Precalculation:doTerritoryMatchRule:mapWODispPro: ' + mapWODispPro);
                    if(mapWODispProOmax.size() == 0 || mapWODispProOmax.size() > 0 && !mapWODispProOmax.containsKey(index)){
                        system.debug('OMAX_Precalculation:doTerritoryMatchRule:Going to remove');
                        mapWODispPro.remove(index);
                    }else{
                        //Overwrite the optmax dispatch process incase the WO has got qualified for 2 or more DPs
                        //In this case, we keep the DP qulaified against the Territory and just the experession
                        system.debug('OMAX_Precalculation:doTerritoryMatchRule:mapWODispProOmax.get(index) -> ' + mapWODispProOmax.get(index));
                        mapWODispPro.put(index,mapWODispProOmax.get(index));
                    }
                }
            }
        }
        //system.debug('OMAX_Precalculation:doTerritoryMatchRule:after remove Omax DP mapWODispPro -' + mapWODispPro);
        system.debug('OMAX_Precalculation:doTerritoryMatchRule:End: Using Limits.getHeapSize() of total heap: Limits.getLimitHeapSize() : ' + Limits.getHeapSize() +' of ' + Limits.getLimitHeapSize());
        system.debug('OMAX_Precalculation:doTerritoryMatchRule:Before doing the dispatch parameter calculations: No of Queries used in this apex code so far: ' + Limits.getQueries());     
    }
    
    public void doDispatchParamCalculations(map<integer, SVMXC__Service_Order__c> mapWorkOrder, map<String, String> svmxSettingList, list<SVMXC__Service_Order__c> lstworkOrder_Old) {

                
        system.debug('OMAX_Precalculation:doDispatchParamCalculations start');
        system.debug('OMAX_Precalculation:doDispatchParamCalculations:Start: Using Limits.getHeapSize() of total heap: Limits.getLimitHeapSize() : ' + Limits.getHeapSize() +' of ' + Limits.getLimitHeapSize());
        //Get the value of the Optimization service providers from settings
        Map<String, boolean> mapOfServiceProvidersAndVal = getServiceProviderValue(svmxSettingList);
        boolean batchOptimization = mapOfServiceProvidersAndVal.get('Batch_Optimization');
        boolean servicePower = mapOfServiceProvidersAndVal.get('Service_Power');
        boolean eCOptimization = mapOfServiceProvidersAndVal.get('Eco_Optimization');
        boolean longTermPlanner = mapOfServiceProvidersAndVal.get('Long_Term_Planner');
        
        system.debug('OMAX_Precalculation:doDispatchParamCalculations: mapOfServiceProvidersAndVal - ' + mapOfServiceProvidersAndVal);

        String strIsSLACalcRequired='true';
        String strPTrequired='';
        if(SVMX_Constants.AllsvmxSettingList.containsKey('OMAX003') && SVMX_Constants.AllsvmxSettingList.get('OMAX003') != null && SVMX_Constants.AllsvmxSettingList.get('OMAX003').size() > 0){
            map<String, String> mapSettingOMAX003 = new map<String, String>();
            mapSettingOMAX003 = SVMX_Constants.AllsvmxSettingList.get('OMAX003');
            if(mapSettingOMAX003.containsKey('SET050') && mapSettingOMAX003.get('SET050') != null){
                strPTrequired = mapSettingOMAX003.get('SET050');
            }
            if(mapSettingOMAX003.containsKey('SET055') && mapSettingOMAX003.get('SET055') != null){
                strIsSLACalcRequired = mapSettingOMAX003.get('SET055');
            }
        }
         
        if(svmxSettingList.get('SET003') != null){
            iDefaultPriority = integer.ValueOf(svmxSettingList.get('SET003'));              
        }
        if(svmxSettingList.get('SET033') != null)
            mapPriorityValue.put(5, integer.ValueOf(svmxSettingList.get('SET033')));
        if(svmxSettingList.get('SET034') != null)
            mapPriorityValue.put(4, integer.ValueOf(svmxSettingList.get('SET034')));
        if(svmxSettingList.get('SET035') != null)
            mapPriorityValue.put(3, integer.ValueOf(svmxSettingList.get('SET035')));
        if(svmxSettingList.get('SET036') != null)
            mapPriorityValue.put(2, integer.ValueOf(svmxSettingList.get('SET036')));
        if(svmxSettingList.get('SET004') != null)
            iDefaultServiceDuration = integer.ValueOf(svmxSettingList.get('SET004'));
        strWorkOrderExpertiseField = svmxSettingList.get('SET006'); //not used anywhere
        strWorkOrderProductField = svmxSettingList.get('SET007');   //not used anywhere

        strSLATimeStampForWO = svmxSettingList.get('SET008');
        if('Onsite Response Customer' == strSLATimeStampForWO)
            strSLATimeStampWOFieldAPIName = 'SVMXC__Onsite_Response_Customer_By__c';
        else if('Initial Response Customer' == strSLATimeStampForWO)
            strSLATimeStampWOFieldAPIName = 'SVMXC__Initial_Response_Customer_By__c';
        else if('Restoration Customer' == strSLATimeStampForWO)
            strSLATimeStampWOFieldAPIName = 'SVMXC__Restoration_Customer_By__c';
        else if('Resolution Customer' == strSLATimeStampForWO)
            strSLATimeStampWOFieldAPIName = 'SVMXC__Resolution_Customer_By__c';
        else if('Onsite Response Internal' == strSLATimeStampForWO)
            strSLATimeStampWOFieldAPIName = 'SVMXC__Onsite_Response_Internal_By__c';
        else if('Initial Response Internal' == strSLATimeStampForWO)
            strSLATimeStampWOFieldAPIName = 'SVMXC__Initial_Response_Internal_By__c';
        else if('Restoration Internal' == strSLATimeStampForWO)
            strSLATimeStampWOFieldAPIName = 'SVMXC__Restoration_Internal_By__c';
        else if('Resolution Internal' == strSLATimeStampForWO)
            strSLATimeStampWOFieldAPIName = 'SVMXC__Resolution_Internal_By__c';
        
        // Do the dispatch parameter calculations
        for(Integer woIndex : mapWorkOrder.keySet())
        {
            SVMXC__Service_Order__c oWO = mapWorkOrder.get(woIndex);
            SVMXC__Installed_Product__c oIB = mapComponent.get(oWO.SVMXC__Component__c);  //set all these maps using a wrapper in the constructor above
            Account oAccount = mapCompany.get(oWO.SVMXC__Company__c);// create a class with all these maps and initialize these maps in the above constructor
            SVMXC__Site__c oLoc = mapLoc.get(oWO.SVMXC__Site__c);
            Case oCase;
            
            // system.debug('18. Starting dispatch parameter calculations for work order index ' + woIndex + ': WO Id - ' + oWO.Id + ' ~ WO Number - ' + oWO.Name);

            /* Clear the error fields. Do not clear Preferred Tech, Preferred Start & End Time, Preferred Business Hours, and Service Duration
                These will retain their values if the dispatch calculation does not result in assigning of new values */
            oWO.SVMXC__OptiMax_Error_Text__c = '';
            oWO.SVMXC__OptiMax_Error_Email1__c = null;
            oWO.SVMXC__OptiMax_Error_Email2__c = null;
            oWO.SVMXC__OptiMax_Error_Occurred__c = false;
            oWO.SVMXC__Dispatch_Priority__c = null;
            system.debug('OMAX_Precalculation:doDispatchParamCalculations:Outside Batch Update');
            if(oWO.SVMXC__BatchUpdate__c != 'Yes')
            {
                system.debug('OMAX_Precalculation:doDispatchParamCalculations:Inside Batch Update');
                //Added condition to auto populate Product in Work Order based on IB, if Global Setting GBL013 is set to true.
                if(svmxSettingList.containsKey('GBL013') && svmxSettingList.get('GBL013').toUpperCase() == 'TRUE' && oIB != null)
                    oWO.SVMXC__Product__c = oIB.SVMXC__Product__c;
                    
                // MTTS calculation
                String strMTTSenable='';
                if(SVMX_Constants.AllsvmxSettingList.containsKey('WORD012') && SVMX_Constants.AllsvmxSettingList.get('WORD012') != null && SVMX_Constants.AllsvmxSettingList.get('WORD012').size() > 0){
                    map<String, String> mapEachSetting = new map<String, String>();
                    mapEachSetting = SVMX_Constants.AllsvmxSettingList.get('WORD012');
                    system.debug(' OMAX_Precalculation:doDispatchParamCalculations:MTTS required - ' + mapEachSetting.get('SET002'));
                    if(mapEachSetting.containsKey('SET002') && mapEachSetting.get('SET002') != null){
                        strMTTSenable = mapEachSetting.get('SET002');
                    }
                }
                system.debug('OMAX_Precalculation:doDispatchParamCalculations::MTTS enabled -'+strMTTSenable);
                                
                if(strMTTSenable.equalsIgnoreCase('true')){
                    this.DoMTTS(oWO, lstworkOrder_Old);
                }
                
                // SLA calculation
                system.debug('OMAX_Precalculation:doDispatchParamCalculations::strIsSLACalcRequired enabled -'+strIsSLACalcRequired);
                if(strIsSLACalcRequired.equalsIgnoreCase('true')) {
                    this.DoSLAHours(oWO, lstworkOrder_Old);
                }
            }
            
            Id IDDispProcess = mapWODispPro.get(woIndex);
            SVMXC__ServiceMax_Processes__c oDispPro = mapSVMXProcess.get(IDDispProcess);
            
            //if this update by batch(Runtime Precal by OptiMax) then reset the work order dispatch process
            //if none of the dispatch process qualified for this wo then clear the existing dispatch process field in wo
            if(oWO.SVMXC__BatchUpdate__c == 'Yes' || oDispPro == null )
            {
                oWO.SVMXC__Dispatch_Process__c=null;
            }
                                
            if(oDispPro != null)
            {
                oWO.SVMXC__Dispatch_Process__c = oDispPro.Id;
                //TODO: need to get the value from Settings
                                 
                
                if((oDispPro.SVMXC__Dispatch_Method__c == 'Optimized Batch' && batchOptimization == true) || (oDispPro.SVMXC__Dispatch_Method__c == 'Linx for ServicePower' && servicePower == true) || (oDispPro.SVMXC__Dispatch_Method__c == 'Real Time Optimization' && eCOptimization == true)
                            || (oDispPro.SVMXC__Dispatch_Method__c == 'Long-Term Planner' && longTermPlanner == true))
                {
                    system.debug('OMAX_Precalculation:doDispatchParamCalculations::strPTrequired enabled -'+strPTrequired);
                    if(strPTrequired.equalsIgnoreCase('true')) {
                        this.DoPreferredTech(oWO);
                    }
                    
                    /* For OptiMax workorder calculate the Dispatch Priority from Disptch process */
                    string IdPriorityRule = oUtils.SVMX_ExpressionParsing((SObject)oWO, mapPriorityDispRulesExp.get(IDDispProcess), mapSVMXProcess, false);
                    if(IdPriorityRule != null && IdPriorityRule.length() > 0)
                          oWO.SVMXC__Dispatch_Priority__c = mapPriorityValue.get(Integer.ValueOf(mapSVMXProcess.get(IdPriorityRule).SVMXC__Sequence__c));
                    
                    /*If Dispatch Priority not derived from the above rules then calculate default for OptiMax and ServicePower workorder. */
                    if(oWO.SVMXC__Dispatch_Priority__c == null)
                       oWO.SVMXC__Dispatch_Priority__c = iDefaultPriority;

                    /* For OptiMax workorder calculate the Capacity Limitation from Disptch process */
                    string IdCapacityRule = oUtils.SVMX_ExpressionParsing((SObject)oWO, mapCapacityLimitRulesExp.get(IDDispProcess), mapSVMXProcess, false);
                    system.debug('OMAX_Precalculation:doDispatchParamCalculations::Capacity Rule qualified.. -'+IdCapacityRule);
                    if(IdCapacityRule != null && IdCapacityRule.length() > 0){
                        SVMXC__ServiceMax_Processes__c capacityRule = mapSVMXProcess.get(IdCapacityRule);
                        oWO.SVMXC__SM_Capacity_Rule_Name__c = capacityRule.SVMXC__Name__c;
                    }
                          

                }

                // For Immediate Dispatch Work Order, find the matching assignment rule or default assignment rule, and update the work order assignment fileds
                else if(oDispPro.SVMXC__Dispatch_Method__c == 'Immediate')
                {                         
                    string IdSimpleRule = oUtils.SVMX_ExpressionParsing((SObject)oWO, mapSimpleDispRulesExp.get(IDDispProcess), mapSVMXProcess);
                    if(IdSimpleRule != null)
                        UpdateWorkOrderForSimpleDispatch(woIndex, oWO, mapSVMXProcess.get(IdSimpleRule));
                    else
                        UpdateWorkOrderForSimpleDispatch(woIndex, oWO, oDispPro);
                }
            }

            // For Work Orders without Dispatch Process / Territory match, set the error fields
            else
            {
                oWO.SVMXC__OptiMax_Error_Occurred__c = true;
                oWO.SVMXC__OptiMax_Error_Email1__c = svmxSettingList.get('SET010');
                if(oWO.SVMXC__Primary_Territory__c == null)
                    oWO.SVMXC__OptiMax_Error_Text__c = system.Label.OMAX003_TAG003 + ' ' + system.Label.OMAX003_TAG004;
                else
                    oWO.SVMXC__OptiMax_Error_Text__c = system.Label.OMAX003_TAG001;
            }
        }
        system.debug('OMAX_Precalculation:doDispatchParamCalculations:End: Using Limits.getHeapSize() of total heap: Limits.getLimitHeapSize() : ' + Limits.getHeapSize() +' of ' + Limits.getLimitHeapSize());
      
    }
    
    public void DoMTTS(SVMXC__Service_Order__c oWO, List<SVMXC__Service_Order__c> lstworkOrder_Old) {
        
        system.debug('OMAX_Precalculation:DoMTTS:Start: Using Limits.getHeapSize() of total heap: Limits.getLimitHeapSize() : ' + Limits.getHeapSize() +' of ' + Limits.getLimitHeapSize());
        string IdMTTSRule = oUtils.SVMX_ExpressionParsing((SObject)oWO, mapMTTSDispRulesExp, mapSVMXProcess);
        if(lstworkOrder_Old !=null){
            //Enters only on update work order trigger
            if(IdMTTSRule != null && IdMTTSRule.length() > 0 && mapSVMXProcess.get(IdMTTSRule).SVMXC__MTTS_Minutes__c != null){
                //Check if recalculate service duration for the work order
                if(isUpdateDuration(IdMTTSRule,oWO,lstworkOrder_Old,mapMTTSDispRulesExp)){
                    oWO.SVMXC__Service_Duration__c = mapSVMXProcess.get(IdMTTSRule).SVMXC__MTTS_Minutes__c * 60;
                }
            }
        }else{
            //Enters only on insert work order trigger
            if(IdMTTSRule != null && IdMTTSRule.length() > 0 && mapSVMXProcess.get(IdMTTSRule).SVMXC__MTTS_Minutes__c != null){
                oWO.SVMXC__Service_Duration__c = mapSVMXProcess.get(IdMTTSRule).SVMXC__MTTS_Minutes__c * 60;
            } else{
                oWO.SVMXC__Service_Duration__c = iDefaultServiceDuration * 60;                                    
            }
        }
        //Service duration is updated with default values if field is empty.
        if(oWO.SVMXC__Service_Duration__c == null || oWO.SVMXC__Service_Duration__c < 1)
            oWO.SVMXC__Service_Duration__c = 60 * 60;
        system.debug('OMAX_Precalculation:DoMTTS:End: Using Limits.getHeapSize() of total heap: Limits.getLimitHeapSize() : ' + Limits.getHeapSize() +' of ' + Limits.getLimitHeapSize());
    }
    
    public void DoSLAHours(SVMXC__Service_Order__c oWO, List<SVMXC__Service_Order__c> lstworkOrder_Old) {
        
        system.debug('OMAX_Precalculation:DoSLAHours:Start: Using Limits.getHeapSize() of total heap: Limits.getLimitHeapSize() : ' + Limits.getHeapSize() +' of ' + Limits.getLimitHeapSize());
        Case oCase;
        SVMXC__Installed_Product__c oIB = mapComponent.get(oWO.SVMXC__Component__c);
        Account oAccount = mapCompany.get(oWO.SVMXC__Company__c);
        SVMXC__Site__c oLoc = mapLoc.get(oWO.SVMXC__Site__c);
        // Preferred Start Date, End Date, and Business Hours calculation 
        if(oWO.SVMXC__Case__c != NULL)
            oCase = mapCases.get(oWO.SVMXC__Case__c);
        
        oWO.SVMXC__Apply_Business_Hours_For_OptiMax__c = false;
                
        if(oWO.SVMXC__Preferred_Business_Hours__c != null)
            oWO.SVMXC__Apply_Business_Hours_For_OptiMax__c = true;
        // If PM work order then skip to update the PST and PET from Case or SLA terms.
        if(oWO.SVMXC__Is_PM_Work_Order__c == false){
        // If Booking Window is applicable, take preferred time from BW
            if(oCase != null && oCase.Preferred_Start_Time__c != null && oCase.Preferred_End_Time__c != null) {
                system.debug('OMAX_Precalculation:doDispatchParamCalculations:Prefrerred Start Tim reset from Case :');
                oWO.SVMXC__Preferred_Start_Time__c = oCase.Preferred_Start_Time__c;
                oWO.SVMXC__Preferred_End_Time__c = oCase.Preferred_End_Time__c;
                oWO.SVMXC__Apply_Business_Hours_For_OptiMax__c = true;
            } // Else, if SLA is applicable, take the SLA time
            else if(oWO.SVMXC__SLA_Terms__c != null) {
                /*system.debug('Prefrerred Start Time reset from SLA:');
                oWO.SVMXC__Preferred_Start_Time__c = dateTime.Now();
                oWO.SVMXC__Preferred_End_Time__c = (DateTime)(oWO.get(strSLATimeStampWOFieldAPIName));
                oWO.SVMXC__Apply_Business_Hours_For_OptiMax__c = true;*/
                //insert and update sla times for optimax work orders
                if(isOptiMaxWO(oWO,mapOmaxDispatchProcess) || isOptiMaxECOWO(oWO,mapECODispatchProcess) || isOptiMaxLTPWO(oWO,mapLTPDispatchProcess)){
                    system.debug('OMAX_Precalculation:doDispatchParamCalculations:OptiMax Workorder Prefrerred Start Time and End time reset from SLA:');
                    oWO.SVMXC__Preferred_Start_Time__c = dateTime.Now();
                    if(String.isNotEmpty(strSLATimeStampWOFieldAPIName))
                        oWO.SVMXC__Preferred_End_Time__c = (DateTime)(oWO.get(strSLATimeStampWOFieldAPIName));
                    oWO.SVMXC__Apply_Business_Hours_For_OptiMax__c = true;
                }else{
                    //if non optimax workorder insert/update
                    //for Insert: no sla terms changes then we are inserting starttime and endtime.
                    //for Update: sla terms changes then we are updating starttime and endtime.
                    if(oWO.SVMXC__Preferred_Start_Time__c == null || isUpdateEndTime(oWO, lstworkOrder_Old)) {
                        oWO.SVMXC__Preferred_Start_Time__c = dateTime.Now();
                        if(String.isNotEmpty(strSLATimeStampWOFieldAPIName))
                            oWO.SVMXC__Preferred_End_Time__c = (DateTime)(oWO.get(strSLATimeStampWOFieldAPIName));
                    }
                }
            }
            // Else, set Preferred Business Hours to IB's or Account's Business Hours, if available
            else if(oWO.SVMXC__Component__c != null && oIB != null && oIB.SVMXC__Access_Hours__c != null) {
                oWO.SVMXC__Preferred_Business_Hours__c = oIB.SVMXC__Access_Hours__c;
                oWO.SVMXC__Apply_Business_Hours_For_OptiMax__c = true;
            } else if(oWO.SVMXC__Site__c != null && oLoc != null && oLoc.SVMXC__Preferred_Business_Hours__c != null) {
                oWO.SVMXC__Preferred_Business_Hours__c = oLoc.SVMXC__Preferred_Business_Hours__c;
                oWO.SVMXC__Apply_Business_Hours_For_OptiMax__c = true;
            } else if(oAccount != null && oAccount.SVMXC__Access_Hours__c != null) {
                oWO.SVMXC__Preferred_Business_Hours__c = oAccount.SVMXC__Access_Hours__c;
                oWO.SVMXC__Apply_Business_Hours_For_OptiMax__c = true;
            }
        }           
        system.debug('OMAX_Precalculation:DoSLAHours:End: Using Limits.getHeapSize() of total heap: Limits.getLimitHeapSize() : ' + Limits.getHeapSize() +' of ' + Limits.getLimitHeapSize());
    }
    
    public void DoPreferredTech(SVMXC__Service_Order__c oWO) {
        
        system.debug('OMAX_Precalculation:DoPreferredTech:Start: Using Limits.getHeapSize() of total heap: Limits.getLimitHeapSize() : ' + Limits.getHeapSize() +' of ' + Limits.getLimitHeapSize());
        /*String strPTrequired='';
        if(SVMX_Constants.AllsvmxSettingList.containsKey('OMAX003') && SVMX_Constants.AllsvmxSettingList.get('OMAX003') != null && SVMX_Constants.AllsvmxSettingList.get('OMAX003').size() > 0){
            map<String, String> mapEachSetting = new map<String, String>();
            mapEachSetting = SVMX_Constants.AllsvmxSettingList.get('OMAX003');
            system.debug('OMAX_Precalculation:doDispatchParamCalculations:Territory Match Rule calcuation required - ' + mapEachSetting.get('SET050'));
            if(mapEachSetting.containsKey('SET050') && mapEachSetting.get('SET050') != null){
                strPTrequired = mapEachSetting.get('SET050');
            }
        }*/
        
        SVMXC__Installed_Product__c oIB = mapComponent.get(oWO.SVMXC__Component__c);
        Account oAccount = mapCompany.get(oWO.SVMXC__Company__c);
        SVMXC__Site__c oLoc = mapLoc.get(oWO.SVMXC__Site__c);
        Case oCase = mapCases.get(oWO.SVMXC__Case__c);
        
        /*Check if Preferred Technician population on workorder is required or not
        if required then OptiMax Work Order, take the Preferred Technician from IB, Case -> Service Contract, or Account
        if not required then skip the logic and use the work order preferred technician.*/
        //if(oWO.SVMXC__BatchUpdate__c != 'Yes' && strPTrequired.equalsIgnoreCase('true'))
        if(oWO.SVMXC__BatchUpdate__c != 'Yes')
        {
            if(oIB != null && oIB.SVMXC__Preferred_Technician__c != null)
                oWO.SVMXC__Preferred_Technician__c = oIB.SVMXC__Preferred_Technician__c;
            else if(oAccount != null && oAccount.SVMXC__Preferred_Technician__c != null)
                oWO.SVMXC__Preferred_Technician__c = oAccount.SVMXC__Preferred_Technician__c;
            else if(oCase != null && oCase.SVMXC__Service_Contract__c != null && oCase.SVMXC__Service_Contract__r.SVMXC__Primary_Technician__c != null)
                oWO.SVMXC__Preferred_Technician__c = oCase.SVMXC__Service_Contract__r.SVMXC__Primary_Technician__c;
        }
        system.debug('OMAX_Precalculation:DoPreferredTech:End: Using Limits.getHeapSize() of total heap: Limits.getLimitHeapSize() : ' + Limits.getHeapSize() +' of ' + Limits.getLimitHeapSize());
    }
    
    public void DoProcessTechnicians(set<string> TechIds, map<String, String> svmxSettingList) {
        
    
        system.debug('OMAX_Precalculation:DoProcessTechnicians:Start: Using Limits.getHeapSize() of total heap: Limits.getLimitHeapSize() : ' + Limits.getHeapSize() +' of ' + Limits.getLimitHeapSize());
        system.debug('OMAX_Precalculation:DoProcessTechnicians: start');
        if(svmxSettingList.get('SET011') != null)
            INumberofDays = integer.ValueOf(svmxSettingList.get('SET011'));
            
            if(svmxSettingList.get('SET012') != null)
            AvgDrivTimeinMin = integer.ValueOf(svmxSettingList.get('SET012'));
            
        if(AvgDrivTimeinMin < 0)
            AvgDrivTimeinMin = 60;
            
            if(svmxSettingList.get('SET014') != null)
            ILeadTime = integer.ValueOf(svmxSettingList.get('SET014'));
        
        if(ILeadTime < 0)
            ILeadTime = 60;
            
            if(svmxSettingList.get('SET013') == 'False')
            ConsiderSameDay = false;
        
        if(TechIds.size() > 0)
        {
            system.debug('OMAX_Precalculation:DoProcessTechnicians:Before build the map of all the active Business Hours: No of Queries used in this apex code so far: ' + Limits.getQueries());
                        
            // Build the map of all the active Business Hours, and get the Org's default Business Hours
            SMAX_OptiMax_Engine_Ext clsOmaxExt = new SMAX_OptiMax_Engine_Ext();
            lstBusinessHours = [Select Id, IsDefault,IsActive, TimeZoneSidKey, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime
                                from BusinessHours
                                where IsActive = TRUE]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            lstBusinessHours = clsOmaxExt.getCompleteBusinessHour(lstBusinessHours);
            for(BusinessHours bh : lstBusinessHours)
            {
                mapBusinessHours.put(bh.Id, bh);
                if(bh.IsDefault == TRUE)
                    objDefaultBH = bh;
            }
            // system.debug('20. Map of active Business Hours: ' + mapBusinessHours);

            system.debug('OMAX_Precalculation:DoProcessTechnicians:Before Get the details of technicians associated with Immediate Dispatch: No of Queries used in this apex code so far: ' + Limits.getQueries());
                        
            /* Get the details of technicians associated with Immediate Dispatch Work Orders
                TechIds list is built in UpdateWorkOrderForSimpleDispatch */
            TechList = [Select SVMXC__Service_Group__r.SVMXC__Email__c, SVMXC__Service_Group__c, 
                        SVMXC__Email__c, SVMXC__Average_Drive_Time__c, SVMXC__Working_Hours__c, SVMXC__Break_Hours__c,
                        SVMXC__Salesforce_User__c, SVMXC__Enable_Scheduling__c, Id,
                        SVMXC__Service_Territory__c, SVMXC__Service_Territory__r.SVMXC__Average_Driving_Time__c,
                        SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c, SVMXC__Service_Territory__r.SVMXC__Break_Hours__c
                        From SVMXC__Service_Group_Members__c 
                        where Id IN: TechIds];
            // system.debug('21. List of technicians to schedule work order events: ' + TechList);

            // Loop through all the techs
            for(SVMXC__Service_Group_Members__c tech : TechList)
            {
                // For each tech, get the average driviving time
                if(tech.SVMXC__Average_Drive_Time__c != null && tech.SVMXC__Average_Drive_Time__c >= 0)
                    MapTechDrivingTime.put(tech.Id, tech.SVMXC__Average_Drive_Time__c);
                else
                {
                    Integer intAvgTerrDriveTimeMin = -1;
                    if(tech.SVMXC__Service_Territory__r.SVMXC__Average_Driving_Time__c != null)
                        intAvgTerrDriveTimeMin = Integer.valueOf(tech.SVMXC__Service_Territory__r.SVMXC__Average_Driving_Time__c);
                    if(intAvgTerrDriveTimeMin < 0)
                        MapTechDrivingTime.put(tech.Id, AvgDrivTimeinMin);
                    else
                        MapTechDrivingTime.put(tech.Id, intAvgTerrDriveTimeMin);
                }
                MapTechIdTechRec.put(tech.Id, tech);

                // For each tech, build placeholder list of SFDC / SVMX Events as applicable
                if(tech.SVMXC__Salesforce_User__c != null)
                {
                    mapTechSFUser.put(tech.SVMXC__Salesforce_User__c, tech.Id);
                    MapSFUser.put(tech.Id, tech.SVMXC__Salesforce_User__c);
                    list<Event> e = new list<Event>();
                    list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> WrpTechEvent = new list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();               
                    mapTechEvnt.put(tech.Id, WrpTechEvent);
                }
                else if(tech.SVMXC__Enable_Scheduling__c)
                {
                    mapTechNonSFUser.put(tech.Id, tech.Id);
                    list<SVMXC__SVMX_Event__c> e = new list<SVMXC__SVMX_Event__c>();
                    list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> WrpSMaxEvent = new list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
                    mapSvmxEvnt.put(tech.Id, WrpSMaxEvent);
                }

                // Build a map of Technician ID and related Working Hours & Break Hours
                // Set valid Working Hours & Break Hours for each Technician
                if(tech.SVMXC__Working_Hours__c != null && mapBusinessHours.containsKey(tech.SVMXC__Working_Hours__c))
                {
                    mapTechIdWorkingHourId.put(tech.Id, tech.SVMXC__Working_Hours__c);
                    if(tech.SVMXC__Break_Hours__c != null && mapBusinessHours.containsKey(tech.SVMXC__Break_Hours__c))
                        mapTechIdBreakHourId.put(tech.Id, tech.SVMXC__Break_Hours__c);
                    else
                        tech.SVMXC__Break_Hours__c = null;
                }
                else if(tech.SVMXC__Service_Territory__c != null && tech.SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c != null && mapBusinessHours.containsKey(tech.SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c))
                {
                    tech.SVMXC__Working_Hours__c = tech.SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c;
                    mapTechIdWorkingHourId.put(tech.Id, tech.SVMXC__Working_Hours__c);
                    if(tech.SVMXC__Service_Territory__r.SVMXC__Break_Hours__c != null && mapBusinessHours.containsKey(tech.SVMXC__Service_Territory__r.SVMXC__Break_Hours__c))
                    {
                        tech.SVMXC__Break_Hours__c = tech.SVMXC__Service_Territory__r.SVMXC__Break_Hours__c;
                        mapTechIdBreakHourId.put(tech.Id, tech.SVMXC__Break_Hours__c);
                    }
                    else
                        tech.SVMXC__Break_Hours__c = null;
                }
                else
                {
                    mapTechIdWorkingHourId.put(tech.Id, objDefaultBH.Id);
                    tech.SVMXC__Working_Hours__c = objDefaultBH.Id;
                }
            }
            // system.debug('22. Map of tech Id - Average Driving Time: ' + MapTechDrivingTime);
            // system.debug('23. Map of tech Id - Working Hours Id: ' + mapTechIdWorkingHourId);
            // system.debug('24. Map of tech Id - Break Hours Id: ' + mapTechIdBreakHourId);
            

            // Get the scheduling horizon dates to schedule work orders as per Immediate Dispatch rules
            // Build it with Technician's Business Hours Id as the key to avoid storing duplicate information
            dtmNow = system.now();
            DateTime dtmEventStart;
            Date datTemp;
            Date datSchedHorizEndDateMax;
            BusinessHours objWorkHour;
            map<Id, DateTime> mapBhIdStartDateTime = new map<Id, DateTime>();
            for (Id techWorkHourId : mapTechIdWorkingHourId.Values())
            {
                if(mapBHIdSchedHorizDates.containsKey(techWorkHourId))
                    continue;

                objWorkHour = mapBusinessHours.get(techWorkHourId);
                set<Date> setSchedHorizonDates = new set<Date>();
                Boolean isTodayWorkingDay = true;
                datTemp = Date.valueOf(dtmNow.format('yyyy-MM-dd', objWorkHour.timeZoneSidKey));

                // Find the first working day
                while (true)
                {
                    if(clsOmaxExt.isWorkingDay(objWorkHour, datTemp))
                    {
                        if(ConsiderSameDay || !isTodayWorkingDay)
                        {
                            setSchedHorizonDates.add(datTemp);
                            break;
                        }
                    }
                    datTemp = datTemp.addDays(1);
                    isTodayWorkingDay = false;
                }

                // If if same day scheduling is enabled and if today is the first working day, add lead time  
                if(ConsiderSameDay && isTodayWorkingDay)
                    dtmEventStart = dtmNow.addMinutes(ILeadTime); // To be corrected to use business hour, if required
                // Else, get the starting date time of the first working day
                else
                {
                    string datesDay = (datetime.newInstanceGmt(datTemp, Time.newinstance(0, 0, 0, 0))).formatGmt('EEEE');
                    Time timDayStartTime = SMAX_OptiMax_Engine_Ext.getStartEndTime(objWorkHour, datesDay, 'StartTime');
                    dtmEventStart = dcUtils.getDateTimeInTimezone(datTemp, timDayStartTime, objWorkHour.timeZoneSidKey);
                }
                mapBhIdStartDateTime.put(techWorkHourId, dtmEventStart);

                // Find the other days in the scheduling horizon
                for(integer i = 1; i < INumberofDays; i++)
                {
                    datTemp = datTemp.addDays(1);
                    if(clsOmaxExt.isWorkingDay(objWorkHour, datTemp))
                        setSchedHorizonDates.add(datTemp);
                    else
                        i--;
                }

                // Also get the maximum end date of the scheduling horizon across business hours and get the maximum end date time from the date
                // This is used for querying for events on technicians' calendar
                if(datSchedHorizEndDateMax == null || datSchedHorizEndDateMax < datTemp)
                    datSchedHorizEndDateMax = datTemp;
                DateTime dtmTemp = dcUtils.getDateTimeInTimezone(datSchedHorizEndDateMax, Time.newInstance(23, 59, 59, 999), objWorkHour.timeZoneSidKey);
                if(dtmSchedulHorizEndTime < dtmTemp)
                    dtmSchedulHorizEndTime = dtmTemp;
                mapBHIdSchedHorizDates.put(techWorkHourId, setSchedHorizonDates);
            }
            // system.debug('25. Map of Work Hours Id - Scheduling Horizon Dates: ' + mapBHIdSchedHorizDates);
            // system.debug('26. Map of Work Hours Id - Scheduling Horizon Start Date Time: ' + mapBhIdStartDateTime);

            system.debug('OMAX_Precalculation:DoProcessTechnicians:Before Get the events on the technicians calendar during the scheduling horizon: No of Queries used in this apex code so far: ' + Limits.getQueries());
                        
            // Get the events on the technicians' calendar during the scheduling horizon
            TechEvntLst = [Select IsAllDayEvent, StartDateTime, WhoID, OwnerId, Id, EndDateTime
                            From Event
                            where OwnerId IN :mapTechSFUser.KeySet()  and
                            (EndDateTime >= :dtmNow and StartDateTime <= :dtmSchedulHorizEndTime) and 
                            IsRecurrence = FALSE
                            order by StartDateTime asc];
            CustEvntLst = [Select SVMXC__WhoId__c, SVMXC__WhatId__c, SVMXC__StartDateTime__c, SVMXC__Technician__c, SVMXC__EndDateTime__c, Id
                            From SVMXC__SVMX_Event__c
                            where SVMXC__Technician__c IN :mapTechNonSFUser.KeySet() and
                            (SVMXC__EndDateTime__c >= :dtmNow and SVMXC__StartDateTime__c <= :dtmSchedulHorizEndTime)
                            order by SVMXC__StartDateTime__c asc];
            
            for(Event tevnt : TechEvntLst)
            {
                if(mapTechEvnt.Containskey(mapTechSFUser.get(tevnt.OwnerId)))
                {
                    SMAX_OptiMax_Engine_WS.ExecutionTime_WP WrpTE = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP();  
                    WrpTE.startDateTime = tevnt.StartDateTime;
                    WrpTE.endDateTime = tevnt.EndDateTime;  
                    mapTechEvnt.get(mapTechSFUser.get(tevnt.OwnerId)).add(WrpTE);                         
                }             
            }                          
            // system.debug('27. Map of Tech Id - Event list: ' + mapTechEvnt);
            
            for(SVMXC__SVMX_Event__c Sevnt : CustEvntLst)
            {
                if(mapSvmxEvnt.Containskey(mapTechNonSFUser.get(Sevnt.SVMXC__Technician__c)))
                {
                    SMAX_OptiMax_Engine_WS.ExecutionTime_WP WrpSE = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP();  
                    WrpSE.startDateTime = Sevnt.SVMXC__StartDateTime__c;
                    WrpSE.endDateTime = Sevnt.SVMXC__EndDateTime__c;        
                    mapSvmxEvnt.get(mapTechNonSFUser.get(Sevnt.SVMXC__Technician__c)).add(WrpSE);             
                }             
            }   
            // system.debug('28. Map of Tech Id - SVMX Event list: ' + mapSvmxEvnt);

            // Get the available time windows of all the technicians over the scheduling horizon by passing Working Hours,
            // Break Hours, Events, and Scheduling Horizon Dates for each technician
            for(SVMXC__Service_Group_Members__c tech : TechList)
            {
                if(tech.SVMXC__Salesforce_User__c != null)
                    mapTechWrpDtSlotlst = clsOmaxExt.techAvailabilityWindow(mapTechWrpDtSlotlst, tech.Id, mapBusinessHours.get(tech.SVMXC__Working_Hours__c), mapBusinessHours.get(tech.SVMXC__Break_Hours__c), mapTechEvnt.get(tech.Id), mapBHIdSchedHorizDates.get(tech.SVMXC__Working_Hours__c), null);
                else if(tech.SVMXC__Enable_Scheduling__c)
                    mapTechWrpDtSlotlst = clsOmaxExt.techAvailabilityWindow(mapTechWrpDtSlotlst, tech.Id, mapBusinessHours.get(tech.SVMXC__Working_Hours__c), mapBusinessHours.get(tech.SVMXC__Break_Hours__c), mapSvmxEvnt.get(tech.Id), mapBHIdSchedHorizDates.get(tech.SVMXC__Working_Hours__c), null);
            }
            // system.debug('28a. Technician availability windows map size: ' + mapTechWrpDtSlotlst.size() + '; Map: ' + mapTechWrpDtSlotlst);

            /* Meenakshi: Not sure about the purpose of building and using this list / map
                This code builds a map of technician ids and driving time for those work orders that are assigned to a tech
                But, UpdateWorkOrderForSimpleDispatch would have updated the technician field for a subset of work orders
                based on the technician assignment rules. And, these technicians would have already been included in 2 maps - 
                MapTechDrivingTime and MapTechIdTechRec */
            /* Code to set drive time for exception technician start */
            list<string> ExceptionTechIds = new list<string>(); 
            map<string, double> MapExcptionTechDrivingTime = new map<string, double>();
            list<SVMXC__Service_Group_Members__c> ExcptionTechList = new list<SVMXC__Service_Group_Members__c>();
            for(Integer woIndex: mapWorkOrder.KeySet())
            {
                SVMXC__Service_Order__c oWO = mapWorkOrder.get(woIndex);
                if(oWO.SVMXC__Group_Member__c != null)
                    ExceptionTechIds.add(oWO.SVMXC__Group_Member__c);
            }
            // system.debug('29. Exception Tech Id list size: ' + ExceptionTechIds.size() + '; List: ' + ExceptionTechIds);

            system.debug('OMAX_Precalculation:DoProcessTechnicians:Before get Exception Tech Id list: No of Queries used in this apex code so far: ' + Limits.getQueries());
                        
            ExcptionTechList = [Select SVMXC__Service_Group__r.SVMXC__Email__c, SVMXC__Service_Group__c, 
                                SVMXC__Email__c, SVMXC__Average_Drive_Time__c, SVMXC__Working_Hours__c, SVMXC__Break_Hours__c,
                                SVMXC__Salesforce_User__c, SVMXC__Enable_Scheduling__c, Id,
                                SVMXC__Service_Territory__c, SVMXC__Service_Territory__r.SVMXC__Average_Driving_Time__c,
                                SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c, SVMXC__Service_Territory__r.SVMXC__Break_Hours__c
                                From SVMXC__Service_Group_Members__c
                                where Id IN :ExceptionTechIds];
            for(SVMXC__Service_Group_Members__c tech : ExcptionTechList)
            {
                if(tech.SVMXC__Average_Drive_Time__c != null && tech.SVMXC__Average_Drive_Time__c >= 0)
                    MapExcptionTechDrivingTime.put(tech.Id, tech.SVMXC__Average_Drive_Time__c);
                else
                {
                    Integer intAvgTerrDriveTimeMin = -1;
                    if(tech.SVMXC__Service_Territory__r.SVMXC__Average_Driving_Time__c != null)
                        intAvgTerrDriveTimeMin = Integer.valueOf(tech.SVMXC__Service_Territory__r.SVMXC__Average_Driving_Time__c);
                    if(intAvgTerrDriveTimeMin < 0)
                        MapExcptionTechDrivingTime.put(tech.Id, AvgDrivTimeinMin);
                    else
                        MapExcptionTechDrivingTime.put(tech.Id, intAvgTerrDriveTimeMin);
                }
                MapTechIdTechRec.put(tech.Id, tech);
            }         
            // system.debug('30. Exception Tech Id - Driving Time map: ' + MapExcptionTechDrivingTime);
            /* Code to set drive time for exception technician End */

            // Update the Average Driving Duration for all the work orders and scheduling information in the Immediate Dispatch work orders
            BusinessHours objWOBH;
            Id idBusinessHour;
            SVMXC__Service_Group_Members__c objTech;
            for(Integer woIndex : mapWorkOrder.KeySet())
            {
                SVMXC__Service_Order__c oWO = mapWorkOrder.get(woIndex);

                // Set the driving time for the work order
                if(MapExcptionTechDrivingTime.containsKey(oWO.SVMXC__Group_Member__c))                                 
                    oWO.Driving_Time__c = MapExcptionTechDrivingTime.get(oWO.SVMXC__Group_Member__c).intvalue();
                else if(MapTechDrivingTime.containsKey(oWO.SVMXC__Group_Member__c))                                  
                    oWO.Driving_Time__c = MapTechDrivingTime.get(oWO.SVMXC__Group_Member__c).intvalue();
                else
                    oWO.Driving_Time__c = AvgDrivTimeinMin;
                integer DrivTimeinSec = Integer.valueOf(oWO.Driving_Time__c * 60);

                // Set the Group Email Id
                if(MapTechIdTechRec.get(oWO.SVMXC__Group_Member__c) != NULL && MapTechIdTechRec.get(oWO.SVMXC__Group_Member__c).SVMXC__Service_Group__r.SVMXC__Email__c != NULL)
                    oWO.SVMXC__Group_Email__c = MapTechIdTechRec.get(oWO.SVMXC__Group_Member__c).SVMXC__Service_Group__r.SVMXC__Email__c;

                // If the work order is not an Immediate Dispatch work order to be scheduled to a technician, skip it
                if(!setWOToBeScheduled.contains(woIndex))
                    continue;

                // Calculate the total event duration in seconds as Service Duration + Driving Time
                integer TotalTime = 0;
                if(oWO.SVMXC__Service_Duration__c != null)
                    TotalTime = oWO.SVMXC__Service_Duration__c.intValue() + DrivTimeinSec;

                // Use the Technician's Business Hours for this work order
                objTech = MapTechIdTechRec.get(oWO.SVMXC__Group_Member__c);
                idBusinessHour = mapTechIdWorkingHourId.get(oWO.SVMXC__Group_Member__c);
                objWOBH = mapBusinessHours.get(idBusinessHour);
                dtmEventStart = mapBhIdStartDateTime.get(idBusinessHour);
                string SlotAvailErrTxt = system.Label.OMAX003_TAG005; // No free slot found for the assigned technician

                // Find the next available slot, and schedule the work order event for technicians that have available time windows
                // For the technicians associated with SF User
                if(objTech.SVMXC__Salesforce_User__c != null && mapTechWrpDtSlotlst.containsKey(objTech.Id))
                {                                  
                    map<Date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> mapDateAvailWind = new map<Date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>();
                    mapDateAvailWind = mapTechWrpDtSlotlst.get(objTech.Id);
                    list<Date> lstTmpSchedDates = new list<Date>();
                    lstTmpSchedDates.addAll(mapDateAvailWind.keySet());
                    lstTmpSchedDates.sort();
                    for(Date schedDate : lstTmpSchedDates)
                    {
                        list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> WrpAvailSlotAfterTechEvent = mapDateAvailWind.get(schedDate);
                        for(integer i = 0; i < WrpAvailSlotAfterTechEvent.size(); i++)
                        {
                            // If the slot ends at or before the event start time, skip it
                            if(dtmEventStart >= WrpAvailSlotAfterTechEvent[i].endDateTime)
                                continue;

                            // If the available slot starts after the earliest event start time, set event start = slot start
                            if(dtmEventStart < WrpAvailSlotAfterTechEvent[i].startDateTime)
                                dtmEventStart = WrpAvailSlotAfterTechEvent[i].startDateTime;

                            // If the available slot can fit the work order event, schedule it, and update the slot to indicate the booking
                            if(dtmEventStart.addSeconds(TotalTime) <= WrpAvailSlotAfterTechEvent[i].endDateTime)
                            {
                                WrpAvailSlotAfterTechEvent[i].startDateTime = dtmEventStart.addSeconds(TotalTime);
                                oWO.SVMXC__Scheduled_Date_Time__c = dtmEventStart.addSeconds(DrivTimeinSec);
                                oWO.SVMXC__Last_Dispatch_Event__c = 'Scheduled';
                                SlotAvailErrTxt = '';
                                break;
                            }
                        }
                        if(oWO.SVMXC__Last_Dispatch_Event__c == 'Scheduled')
                            break;
                    }
                }
                // For the technicians with Enable Scheduling = true
                else if(objTech.SVMXC__Enable_Scheduling__c && mapTechWrpDtSlotlst.containsKey(objTech.Id))
                {
                    map<Date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> mapDateAvailWind = new map<Date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>();
                    mapDateAvailWind = mapTechWrpDtSlotlst.get(objTech.Id);
                    list<Date> lstTmpSchedDates = new list<Date>();
                    lstTmpSchedDates.addAll(mapDateAvailWind.keySet());
                    lstTmpSchedDates.sort();
                    for(Date schedDate : lstTmpSchedDates)
                    {
                        list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> WrpAvailSlotAfterSvmxEvent = mapDateAvailWind.get(schedDate);
                        for(integer i = 0; i < WrpAvailSlotAfterSvmxEvent.size(); i++)
                        {                     
                            // If the slot ends at or before the event start time, skip it
                            if(dtmEventStart >= WrpAvailSlotAfterSvmxEvent[i].endDateTime)
                                continue;

                            // If the available slot starts after the earliest event start time, set event start = slot start
                            if(dtmEventStart < WrpAvailSlotAfterSvmxEvent[i].startDateTime)
                                dtmEventStart = WrpAvailSlotAfterSvmxEvent[i].startDateTime;

                            // If the available slot can fit the work order event, schedule it, and update the slot to indicate the booking
                            if(dtmEventStart.addSeconds(TotalTime) <= WrpAvailSlotAfterSvmxEvent[i].endDateTime)
                            {
                                WrpAvailSlotAfterSvmxEvent[i].startDateTime = dtmEventStart.addSeconds(TotalTime);
                                oWO.SVMXC__Scheduled_Date_Time__c = dtmEventStart.addSeconds(DrivTimeinSec);
                                oWO.SVMXC__Last_Dispatch_Event__c = 'Scheduled';
                                SlotAvailErrTxt = '';
                                break;
                            }
                        }
                        if(oWO.SVMXC__Last_Dispatch_Event__c == 'Scheduled')
                            break;
                    }
                }
                if(SlotAvailErrTxt != null && SlotAvailErrTxt.length() > 0)
                {
                    oWO.SVMXC__OptiMax_Error_Text__c = SlotAvailErrTxt;
                    // system.debug('31. Free slot not found on technician calendar for work order: ' + oWO.Id + ' - ' + oWO.Name);
                }
            } // End of Work Order scheduling info update loop       
        } // End of section that handles data prep and work order update if events have to be scheduled for technicians
        system.debug('OMAX_Precalculation:DoProcessTechnicians:End: Using Limits.getHeapSize() of total heap: Limits.getLimitHeapSize() : ' + Limits.getHeapSize() +' of ' + Limits.getLimitHeapSize());
        
    }
    
    public void doSkillandQTLCompute(map<integer, SVMXC__Service_Order__c> mapWorkOrder) {
        
        system.debug('OMAX_Precalculation:doSkillandQTLCompute: start: Using Limits.getHeapSize() of total heap: Limits.getLimitHeapSize() : ' + Limits.getHeapSize() +' of ' + Limits.getLimitHeapSize());
        //Skill computation alone moved back again here(before insert/update). 
        //To avoid explicit wo update for considering PB immediate assignment issue.
        list<SVMXC__Service_Order__c>  lstWorkOrdersForSkillCompute = new list<SVMXC__Service_Order__c>();
        if(mapWorkOrder.size() > 0){
            //filtering separate list of workorders which is qualified for QTL and Skill
            //Skill alone workorders criteria is Workorder should not be OptiMaxDP and Skill set field is empty. 
            for(Integer woIndex : mapWorkOrder.KeySet()){
                SVMXC__Service_Order__c objWO = mapWorkOrder.get(woIndex);
                if(objWO.SVMXC__Skill_Set__c == null || objWO.SVMXC__Skill_Set__c == ''){
                        lstWorkOrdersForSkillCompute.add(objWO);    
                }
            }
            //system.debug('OMAX_Precalculation:doSkillandQTLCompute:List of Workorders qualified for Skills computation...'+lstWorkOrdersForSkillCompute);
            // Invoke skill match calculation if if GBL007 is True and non OptiMax WorkOrders
            // buildSkills (...) should be called only if WO/s are there, where build calculation is required
            if (lstWorkOrdersForSkillCompute != null && lstWorkOrdersForSkillCompute.size() > 0) {           
                //Skill computation
                SMAX_OptiMax_EngineUtils clsQTLComputation = new SMAX_OptiMax_EngineUtils();
                clsQTLComputation.buildSkills(lstWorkOrdersForSkillCompute);
            }           
        }
        system.debug('OMAX_Precalculation:doSkillandQTLCompute: end: Using Limits.getHeapSize() of total heap: Limits.getLimitHeapSize()');

    }
    
    public Map<String, boolean> getServiceProviderValue(Map<String, String> svmxSettingList) {
        
        Map<String, boolean> mapOfServiceProviderAndValue = new Map<String, boolean>();
        
        //GBL022: Optimization providers is enabled or disabled for this org using this setting.
        String[] providers;
        Set<String> providersSet = new Set<String>();
        boolean batchOptimization=false;
        boolean servicePower=false;
        boolean eCOptimization=false;
        boolean longTermPlanner = false;
        //set<String> setTerritoryIds = new set<String>();
        if(svmxSettingList.containsKey('GBL022')){
            system.debug('OMAX_Precalculation: getServiceProviderValue: Settings value :'+svmxSettingList.get('GBL022'));
            providers = svmxSettingList.get('GBL022').split(',');
            system.debug('Providers : '+providers);
            for(Integer i=0; i < providers.size(); i++){
              String providerCaps = providers[i].touppercase();
              providersSet.add(providerCaps);
            }
            system.debug('ProviderSet '+providersSet);
            if(providersSet.size() > 0 && providersSet.contains('OPTIMAX')){
                batchOptimization = true;
                eCOptimization = true;
                longTermPlanner = true;
            }
            if(providersSet.size() > 0 && (providersSet.contains('SERVICEPOWER') || providersSet.contains('SERVICE POWER'))){
              servicePower = true;
            }
        }
        
        mapOfServiceProviderAndValue.put('Batch_Optimization', batchOptimization);
        mapOfServiceProviderAndValue.put('Eco_Optimization', eCOptimization);
        mapOfServiceProviderAndValue.put('Service_Power', servicePower);
        mapOfServiceProviderAndValue.put('Long_Term_Planner', longTermPlanner);
        
        //system.debug('OMAX_Precalculation: getServiceProviderValue: mapOfServiceProviderAndValue - ' + mapOfServiceProviderAndValue);
        
        return mapOfServiceProviderAndValue;
    }
}