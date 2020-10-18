/**
This class stores all the config data and the process data that is required for performing Precalculation.
Author: Zubair
**/
public with sharing class OMAX_ManagePrecalcData {
    
    public static map<Id, SVMXC__ServiceMax_Processes__c> mapSVMXProcess = new map<Id, SVMXC__ServiceMax_Processes__c>();
    public static map<Id, SVMXC__ServiceMax_Config_Data__c> mapExpression = new map<Id, SVMXC__ServiceMax_Config_Data__c>();
    
    private map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapDispProExp = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    private map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapAdvDispProExp = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    private map<Id, SVMXC__ServiceMax_Processes__c> mapOmaxDispatchProcess = new map<Id, SVMXC__ServiceMax_Processes__c>();
    private map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapContDispProExp = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    private map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapECODispProExp = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    private map<Id, SVMXC__ServiceMax_Processes__c> mapECODispatchProcess = new map<Id, SVMXC__ServiceMax_Processes__c>();
    
    private map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapLTPDispProExp = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    private map<Id, SVMXC__ServiceMax_Processes__c> mapLTPDispatchProcess = new map<Id, SVMXC__ServiceMax_Processes__c>();
    
    private map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapAllDispProExp = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    private map<Id, SVMXC__ServiceMax_Processes__c> mapTerritoryRules = new map<Id, SVMXC__ServiceMax_Processes__c>();
    private map<Id, set<string>> mapDispProTerritory = new map<Id, set<string>>();
    private map<Id, Id> mapTertryDispProcess = new map<Id, Id>();
    private map<Id, map<Id, list<SVMXC__ServiceMax_Config_Data__c>>> mapSimpleDispRulesExp = new map<Id, map<Id, list<SVMXC__ServiceMax_Config_Data__c>>>();
    private map<Id, map<Id, list<SVMXC__ServiceMax_Config_Data__c>>> mapPriorityDispRulesExp = new map<Id, map<Id, list<SVMXC__ServiceMax_Config_Data__c>>>();
    private map<Id, map<Id, list<SVMXC__ServiceMax_Config_Data__c>>> mapCapacityLimitRulesExp = new map<Id, map<Id, list<SVMXC__ServiceMax_Config_Data__c>>>();
    
    private map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapTerritoryFieldMap = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    private map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapMTTSDispRulesExp = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    private map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapTerritoryDispRulesExp = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    
    public map<String, String> svmxSettingList = new map<String, String>();
    
    /**
    below static method executes the runSOQLs method when the class gets loaded for the first time
    **/
    static {
        runSOQLs();
    }
    
    /*public OMAX_ManagePrecalcData(map<String, String> TempsvmxSettingList) {
        svmxSettingList = TempsvmxSettingList;
    }*/
    
    public OMAX_ManagePrecalcData() {
        
    }
    
    public static void runSOQLs() {
        
        /* Get the list of all valid dispatch processes and all rules */
        mapSVMXProcess.putAll([SELECT Name, SVMXC__Sequence__c, SVMXC__Name__c, SVMXC__MTTS_Minutes__c, SVMXC__Advance_Expression__c, 
                SVMXC__Rule_Type__c, SVMXC__Process__c, SVMXC__Process__r.SVMXC__Dispatch_Process_Status__c , SVMXC__Territory__c, 
                SVMXC__Technician_User__c, SVMXC__Technician_Service_Group__c, SVMXC__Start_Time__c, SVMXC__Start_Date__c, SVMXC__Schedule_Event__c,
                SVMXC__Product_Match_Enabled__c, SVMXC__Preferred_Tech_Enabled__c, SVMXC__Final_Exception_Process__c, SVMXC__Expertise_Match_Enabled__c, 
                SVMXC__End_Date__c, SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c, SVMXC__Distance_And_Time__c, SVMXC__Dispatch_Method__c,
                SVMXC__Calendar_Start_Type__c, SVMXC__Calendar_Start_Days__c, SVMXC__Calendar_End_Type__c, SVMXC__Calendar_End_Days__c, 
                SVMXC__Assign_Work_Order_To__c, SVMXC__Assign_To_Technician__c, SVMXC__Assign_To_Technician__r.SVMXC__Email__c, 
                SVMXC__Assign_To_Queue__c, SVMXC__Assign_To_Dispatcher__c, Id, SVMXC__Weight_Tech_Eligibility__c, SVMXC__Weight_Skill_Match__c, 
                SVMXC__Weight_Product_Specialization__c, SVMXC__Weight_Preferred_Technician__c, RecordType.Name from SVMXC__ServiceMax_Processes__c 
                where (RecordType.Name = 'Dispatch Process' and SVMXC__Dispatch_Process_Status__c = 'Complete' and 
                        (SVMXC__Dispatch_Method__c = 'Immediate' OR 
                            (SVMXC__Dispatch_Method__c = 'Optimized Batch' OR 
                                (SVMXC__Dispatch_Method__c = 'Linx for ServicePower' OR 
                                    (SVMXC__Dispatch_Method__c = 'Real Time Optimization' OR 
                                        (SVMXC__Dispatch_Method__c = 'Long-Term Planner' and 
                                            (SVMXC__End_Date__c >=: system.now().dateGMT() or SVMXC__End_Date__c=null)
                                        )
                                    )
                                )
                            )
                        )
                      ) or RecordType.Name = 'SVMX Rule' order by SVMXC__Sequence__c]);
    }
    
    /**
    This method interates through all process objects across the org whose RecordType.Name is 'Dispatch Process' and 'SVMX Rule' and populates the respective maps
    **/
    public void seggregateProcessData(map<String, String> svmxSettingList) {
        
        //Get the value of the Optimization service providers from settings
        Map<String, boolean> mapOfServiceProvidersAndVal = getServiceProviderValue(svmxSettingList);
        boolean batchOptimization = mapOfServiceProvidersAndVal.get('Batch_Optimization');
        boolean servicePower = mapOfServiceProvidersAndVal.get('Service_Power');
        boolean eCOptimization = mapOfServiceProvidersAndVal.get('Eco_Optimization');
        boolean longTermPlanner = mapOfServiceProvidersAndVal.get('Long_Term_Planner');
        
        system.debug('OMAX_ManagePrecalcData:seggregateProcessData: mapOfServiceProvidersAndVal - ' + mapOfServiceProvidersAndVal);
        
        /* Process all the ServiceMax Process records retrieved */
        for(SVMXC__ServiceMax_Processes__c oSVMXProcess: mapSVMXProcess.values())
        {
            /* Build maps of entry criteria expressions (placeholder list) for the Immediate Dispatch Processes & Optimized Batch & Linx for ServicePower Dispatch Processes */
            if(oSVMXProcess.RecordType.Name == 'Dispatch Process')
            {
                if(oSVMXProcess.SVMXC__Dispatch_Method__c == 'Immediate'){
                    mapDispProExp.put(oSVMXProcess.Id, new list<SVMXC__ServiceMax_Config_Data__c>());
                }else if(oSVMXProcess.SVMXC__Dispatch_Method__c == 'Optimized Batch' && batchOptimization == true) { //optimax
                    mapAdvDispProExp.put(oSVMXProcess.Id, new list<SVMXC__ServiceMax_Config_Data__c>());
                    //creating optimax dispatch process map for updating sla datetimes.
                    mapOmaxDispatchProcess.put(oSVMXProcess.Id,oSVMXProcess);
                }else if(oSVMXProcess.SVMXC__Dispatch_Method__c == 'Linx for ServicePower' && servicePower == true) {
                    mapContDispProExp.put(oSVMXProcess.Id, new list<SVMXC__ServiceMax_Config_Data__c>()); //Linx for ServicePower
                }else if(oSVMXProcess.SVMXC__Dispatch_Method__c == 'Real Time Optimization' && eCOptimization == true) {
                    mapECODispProExp.put(oSVMXProcess.Id, new list<SVMXC__ServiceMax_Config_Data__c>()); //Real Time Optimization
                    mapECODispatchProcess.put(oSVMXProcess.Id,oSVMXProcess);
                } else if(oSVMXProcess.SVMXC__Dispatch_Method__c == 'Long-Term Planner' && longTermPlanner == true) {
                    mapLTPDispProExp.put(oSVMXProcess.Id, new list<SVMXC__ServiceMax_Config_Data__c>()); //Long-Term Planner
                    mapLTPDispatchProcess.put(oSVMXProcess.Id,oSVMXProcess);
                    system.debug('OMAX_ManagePrecalcData:seggregateProcessData():mapLTPDispatchProcess - ' + mapLTPDispatchProcess);
                }
                //TODO - create single map of all dispatch process
                mapAllDispProExp.put(oSVMXProcess.Id, new list<SVMXC__ServiceMax_Config_Data__c>());
            }
            else if(oSVMXProcess.RecordType.Name == 'SVMX Rule')
            {
                /* Build map of Territory Match Rules */
                if(oSVMXProcess.SVMXC__Rule_Type__c == 'Work Order Territory') {
                    if(mapTerritoryRules != null) { // Previous condition if(mapTerritoryRules != null && mapTerritoryRules.isEmpty())
                        mapTerritoryRules.put(oSVMXProcess.Id, oSVMXProcess);
                    }
                }

                /* Build map of Dispatch Process & Associated Territories and map of Territory & Associated Dispatch Process */
                else if(oSVMXProcess.SVMXC__Rule_Type__c == 'Territory Access')
                {
                    if(oSVMXProcess.SVMXC__Territory__c != null && oSVMXProcess.SVMXC__Process__c != null && oSVMXProcess.SVMXC__Process__r.SVMXC__Dispatch_Process_Status__c != 'Incomplete')
                    {
                        if(!mapDispProTerritory.ContainsKey(oSVMXProcess.SVMXC__Process__c))
                            mapDispProTerritory.put(oSVMXProcess.SVMXC__Process__c, new set<string>());                       
                        
                        //mapDispProTerritory is not being used below
                        mapDispProTerritory.get(oSVMXProcess.SVMXC__Process__c).add(oSVMXProcess.SVMXC__Territory__c);
                        mapTertryDispProcess.put(oSVMXProcess.SVMXC__Territory__c, oSVMXProcess.SVMXC__Process__c);
                    }
                }

                /* Build map of expressions(placeholder list) for Immediate Dispatch Processes' Assignment Rules */
                else if(oSVMXProcess.SVMXC__Rule_Type__c == 'Simple Assignment')
                {
                    if(!mapSimpleDispRulesExp.containsKey(oSVMXProcess.SVMXC__Process__c))
                        mapSimpleDispRulesExp.put(oSVMXProcess.SVMXC__Process__c, new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>());
                    if(!mapSimpleDispRulesExp.get(oSVMXProcess.SVMXC__Process__c).containsKey(oSVMXProcess.Id))
                        mapSimpleDispRulesExp.get(oSVMXProcess.SVMXC__Process__c).put(oSVMXProcess.Id, new list<SVMXC__ServiceMax_Config_Data__c>());
                }

                /* Build map of expressions(placeholder list) for Optimized Batch Dispatch Processes' Prioritization Rules */
                else if(oSVMXProcess.SVMXC__Rule_Type__c == 'Priortization')
                {
                    if(!mapPriorityDispRulesExp.containsKey(oSVMXProcess.SVMXC__Process__c))
                        mapPriorityDispRulesExp.put(oSVMXProcess.SVMXC__Process__c, new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>());
                    if(!mapPriorityDispRulesExp.get(oSVMXProcess.SVMXC__Process__c).containsKey(oSVMXProcess.Id))
                        mapPriorityDispRulesExp.get(oSVMXProcess.SVMXC__Process__c).put(oSVMXProcess.Id, new list<SVMXC__ServiceMax_Config_Data__c>());
                }
                
                /* Build map of expressions(placeholder list) for Optimized Dispatch Processes' Capacity Reservation Rules */
                else if(oSVMXProcess.SVMXC__Rule_Type__c == 'Capacity Reservation')
                {
                    if(!mapCapacityLimitRulesExp.containsKey(oSVMXProcess.SVMXC__Process__c))
                        mapCapacityLimitRulesExp.put(oSVMXProcess.SVMXC__Process__c, new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>());
                    if(!mapCapacityLimitRulesExp.get(oSVMXProcess.SVMXC__Process__c).containsKey(oSVMXProcess.Id))
                        mapCapacityLimitRulesExp.get(oSVMXProcess.SVMXC__Process__c).put(oSVMXProcess.Id, new list<SVMXC__ServiceMax_Config_Data__c>());
                }
                
            }
        }   
    }
    
    /**
    This method queries all the config objects across the org whose RecordType.Name is 'Expressions' and 'Field Mapping' and populates the respective maps
    **/
    public void seggregateConfigData(map<Id, SVMXC__ServiceMax_Processes__c> mapSVMXProcess, map<String, String> svmxSettingList) {
        
         /* Get the expression rows for all the rules / processes identified above */
        /*mapExpression.putAll([SELECT Id, RecordType.Name, SVMXC__Source_Field_Name__c, SVMXC__Target_Field_Name__c, SVMXC__Dispatch_Process__c, 
            SVMXC__Display_Type__c, SVMXC__Sequence__c, SVMXC__RecordType_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, 
            SVMXC__Lookup_Field_API_Name__c, SVMXC__Inventory_Process__c, SVMXC__Field_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Expression_Type__c, 
            SVMXC__Expression_Rule__c, SVMXC__Field_Relationship_Name__c from SVMXC__ServiceMax_Config_Data__c 
            where (RecordType.Name='Expressions' AND SVMXC__Expression_Rule__c IN :mapSVMXProcess.KeySet()) OR 
            (RecordType.Name='Field Mapping' AND SVMXC__Expression_Rule__c IN :mapTerritoryRules.KeySet()) order by SVMXC__Sequence__c]);*/
        
        system.debug('OMAX_ManagePrecalcData:seggregateConfigData: mapExpression size() - ' + mapExpression.size());
        
        //Get the value of the Optimization service providers from settings
        Map<String, boolean> mapOfServiceProvidersAndVal = getServiceProviderValue(svmxSettingList);
        boolean batchOptimization = mapOfServiceProvidersAndVal.get('Batch_Optimization');
        boolean servicePower = mapOfServiceProvidersAndVal.get('Service_Power');
        boolean eCOptimization = mapOfServiceProvidersAndVal.get('Eco_Optimization');
        boolean longTermPlanner = mapOfServiceProvidersAndVal.get('Long_Term_Planner');
        
        //system.debug('OMAX_ManagePrecalcData:seggregateConfigData: mapOfServiceProvidersAndVal - ' + mapOfServiceProvidersAndVal);
         
        for(SVMXC__ServiceMax_Config_Data__c oExp: mapExpression.values())
        {
            //system.debug(LoggingLevel.INFO, 'OMAX_ManagePrecalcData:seggregateConfigData: oExp - ' + oExp);
            /* Territory and Work Order fields to be matched for Territory Match Rules */
            if(oExp.RecordType.Name == 'Field Mapping')
            {
                if(oExp.SVMXC__Target_Field_Name__c != null && oExp.SVMXC__Source_Field_Name__c != null && oExp.SVMXC__Target_Field_Name__c != 'SVMX.NONE' && oExp.SVMXC__Source_Field_Name__c != 'SVMX.NONE')
                {
                    if(!mapTerritoryFieldMap.containsKey(oExp.SVMXC__Expression_Rule__c))
                        mapTerritoryFieldMap.put(oExp.SVMXC__Expression_Rule__c, new list<SVMXC__ServiceMax_Config_Data__c>());
                    mapTerritoryFieldMap.get(oExp.SVMXC__Expression_Rule__c).add(oExp);
                }
            }
            else
            {
                /* Entry criteria for Dispatch Processes */
                if(oExp.SVMXC__Expression_Type__c == 'DISP_Process_Entry') {
                    if(mapDispProExp.containsKey(oExp.SVMXC__Expression_Rule__c)){
                        mapDispProExp.get(oExp.SVMXC__Expression_Rule__c).add(oExp);                            
                    }else if(mapAdvDispProExp.containsKey(oExp.SVMXC__Expression_Rule__c) && batchOptimization == true) {//optimax
                        mapAdvDispProExp.get(oExp.SVMXC__Expression_Rule__c).add(oExp);
                    }else if(mapContDispProExp.containsKey(oExp.SVMXC__Expression_Rule__c) && servicePower == true){
                      mapContDispProExp.get(oExp.SVMXC__Expression_Rule__c).add(oExp); //Linx for ServicePower
                    }else if(mapECODispProExp.containsKey(oExp.SVMXC__Expression_Rule__c) && eCOptimization == true){
                      mapECODispProExp.get(oExp.SVMXC__Expression_Rule__c).add(oExp); //Real Time Optimization
                    }else if(mapLTPDispProExp.containsKey(oExp.SVMXC__Expression_Rule__c) && longTermPlanner == true){
                      mapLTPDispProExp.get(oExp.SVMXC__Expression_Rule__c).add(oExp); //Long-Term Planner
                    }
                    //TODO - adding all DP expression into single map
                    if(mapAllDispProExp.containsKey(oExp.SVMXC__Expression_Rule__c)){
                        mapAllDispProExp.get(oExp.SVMXC__Expression_Rule__c).add(oExp);   
                    }
                }
                /* Immediate Dispatch Assignment Rules */
                else if(oExp.SVMXC__Expression_Type__c == 'DISP_Simple_Assignment') {
                    putExpressionInMap(mapSimpleDispRulesExp, oExp);
                }
                /* MTTS Rules */
                else if(oExp.SVMXC__Expression_Type__c == 'WORD_MTTS') {
                    if(!mapMTTSDispRulesExp.ContainsKey(oExp.SVMXC__Expression_Rule__c))
                        mapMTTSDispRulesExp.put(oExp.SVMXC__Expression_Rule__c, new list<SVMXC__ServiceMax_Config_Data__c>());
                    mapMTTSDispRulesExp.get(oExp.SVMXC__Expression_Rule__c).add(oExp);
                }
                /* Optimized Batch Dispatch Process Prioritization Rules */
                else if(oExp.SVMXC__Expression_Type__c == 'DISP_Priortization') {
                    putExpressionInMap(mapPriorityDispRulesExp, oExp);
                }
                /* Territory Match Rule entry criteria */
                else if(oExp.SVMXC__Expression_Type__c == 'WORD_Territory') {
                    if(!mapTerritoryDispRulesExp.ContainsKey(oExp.SVMXC__Expression_Rule__c))
                        mapTerritoryDispRulesExp.put(oExp.SVMXC__Expression_Rule__c, new list<SVMXC__ServiceMax_Config_Data__c>());
                    mapTerritoryDispRulesExp.get(oExp.SVMXC__Expression_Rule__c).add(oExp);
                }
                /* Capacity Reservation Rule entry criteria */
                else if(oExp.SVMXC__Expression_Type__c == 'DISP_Capacity_Reservation') {
                    putExpressionInMap(mapCapacityLimitRulesExp, oExp);
                }
            }
        }
    }
    
    /* Below method creates a mapTerritoryRules from Process records retrieved */
    public void populateTerritoryRuleMap() {
        
        system.debug('OMAX_ManagePrecalcData:populateTerritoryRuleMap: mapSVMXProcess.size() - ' + mapSVMXProcess.size());
        /* Process all the ServiceMax Process records retrieved */
        for(SVMXC__ServiceMax_Processes__c oSVMXProcess: mapSVMXProcess.values())
        {
            /* Build map of Territory Match Rules */
            if(oSVMXProcess.RecordType.Name == 'SVMX Rule')
            {
                if(oSVMXProcess.SVMXC__Rule_Type__c == 'Work Order Territory') {
                    if(mapTerritoryRules != null) {  // previous condition was if(mapTerritoryRules != null && mapTerritoryRules.isEmpty())
                        mapTerritoryRules.put(oSVMXProcess.Id, oSVMXProcess);
                    }
                }
            }
        }
        system.debug('OMAX_ManagePrecalcData:populateTerritoryRuleMap: mapTerritoryRules - ' + mapTerritoryRules);
    }
    
    /* Below method creates a list of all the API names stored under field SVMXC__Field_Name__c for the following expression types*/
    public Set<String> getLstOfFieldNameFromConfigData() {
        
        Set<String> lstOfFieldNames = new Set<String>();
        
        //call the below method to create a territory rule map from the SVMXProcess object.
        populateTerritoryRuleMap();
        
        /* Get the expression rows for all the rules / processes identified above */
        mapExpression.putAll([SELECT Id, RecordType.Name, SVMXC__Source_Field_Name__c, SVMXC__Target_Field_Name__c, SVMXC__Dispatch_Process__c, 
            SVMXC__Display_Type__c, SVMXC__Sequence__c, SVMXC__RecordType_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, 
            SVMXC__Lookup_Field_API_Name__c, SVMXC__Inventory_Process__c, SVMXC__Field_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Expression_Type__c, 
            SVMXC__Expression_Rule__c, SVMXC__Field_Relationship_Name__c from SVMXC__ServiceMax_Config_Data__c 
            where (RecordType.Name='Expressions' AND SVMXC__Expression_Rule__c IN :mapSVMXProcess.KeySet()) OR 
            (RecordType.Name='Field Mapping' AND SVMXC__Expression_Rule__c IN :mapTerritoryRules.KeySet()) order by SVMXC__Sequence__c]);
            
        system.debug('OMAX_ManagePrecalcData:getLstOfFieldNameFromConfigData: mapExpression.size() - ' + mapExpression.size());
            
        for(SVMXC__ServiceMax_Config_Data__c oExp: mapExpression.values())
        {
            /* Territory and Work Order fields to be matched for Territory Match Rules */
            if(oExp.RecordType.Name == 'Field Mapping' && oExp.SVMXC__Field_Name__c != null)
            {
                lstOfFieldNames.add(oExp.SVMXC__Field_Name__c);
            }
            else
            {
                /* Entry criteria for Dispatch Processes */
                if(oExp.SVMXC__Expression_Type__c == 'DISP_Process_Entry' && oExp.SVMXC__Field_Name__c != null) {
                    lstOfFieldNames.add(oExp.SVMXC__Field_Name__c);
                }
                /* Immediate Dispatch Assignment Rules */
                else if(oExp.SVMXC__Expression_Type__c == 'DISP_Simple_Assignment' && oExp.SVMXC__Field_Name__c != null) {
                    lstOfFieldNames.add(oExp.SVMXC__Field_Name__c);
                }
                /* MTTS Rules */
                else if(oExp.SVMXC__Expression_Type__c == 'WORD_MTTS' && oExp.SVMXC__Field_Name__c != null) {
                    lstOfFieldNames.add(oExp.SVMXC__Field_Name__c);
                }
                /* Optimized Batch Dispatch Process Prioritization Rules */
                else if(oExp.SVMXC__Expression_Type__c == 'DISP_Priortization' && oExp.SVMXC__Field_Name__c != null) {
                    lstOfFieldNames.add(oExp.SVMXC__Field_Name__c);
                }
                /* Territory Match Rule entry criteria */
                else if(oExp.SVMXC__Expression_Type__c == 'WORD_Territory' && oExp.SVMXC__Field_Name__c != null) {
                   lstOfFieldNames.add(oExp.SVMXC__Field_Name__c);
                }
                /* Capacity Reservation Rule entry criteria */
                else if(oExp.SVMXC__Expression_Type__c == 'DISP_Capacity_Reservation' && oExp.SVMXC__Field_Name__c != null) {
                   lstOfFieldNames.add(oExp.SVMXC__Field_Name__c);
                }
            }
        }
        //system.debug(LoggingLevel.INFO, 'OMAX_ManagePrecalcData:getLstOfFieldNameFromConfigData: lstOfFieldNames - ' + lstOfFieldNames);
        
        return lstOfFieldNames;
    }
    
    /* Utility function for putting an expression row associated with an expression, creating the relevant maps & lists as needed */
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
    
    public Map<String, boolean> getServiceProviderValue(Map<String, String> svmxSettingList) {
        
        Map<String, boolean> mapOfServiceProviderAndValue = new Map<String, boolean>();
        
        //GBL022: Optimization providers is enabled or disabled for this org using this setting.
        String[] providers;
        Set<String> providersSet = new Set<String>();
        boolean batchOptimization = false;
        boolean servicePower = false;
        boolean eCOptimization = false;
        boolean longTermPlanner = false;
        //set<String> setTerritoryIds = new set<String>();
        if(svmxSettingList.containsKey('GBL022')){
            //system.debug('OMAX_Precalculation: getServiceProviderValue: Settings value :'+svmxSettingList.get('GBL022'));
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
    
    /*public void setMapSVMXProcess(map<Id, SVMXC__ServiceMax_Processes__c> mapSVMXProcess) {
        this.mapSVMXProcess = mapSVMXProcess;
    }
    
    public map<Id, SVMXC__ServiceMax_Processes__c> getMapSVMXProcess() {
        return this.mapSVMXProcess;
    }
    
    public void setMapExpression(map<Id, SVMXC__ServiceMax_Config_Data__c> mapExpression) {
        this.mapExpression = mapExpression;
    }
    
    public map<Id, SVMXC__ServiceMax_Config_Data__c> getMapExpression() {
        return this.mapExpression;
    }*/
    
    public void setMapDispProExp(map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapDispProExp) {
        this.mapDispProExp = mapDispProExp;
    }
    
    public map<Id, list<SVMXC__ServiceMax_Config_Data__c>> getMapDispProExp() {
        return this.mapDispProExp;
    }
    
    public void setMapOmaxDispatchProcess(map<Id, SVMXC__ServiceMax_Processes__c> mapOmaxDispatchProcess) {
        this.mapOmaxDispatchProcess = mapOmaxDispatchProcess;
    }
    
    public map<Id, SVMXC__ServiceMax_Processes__c> getMapOmaxDispatchProcess() {
        return this.mapOmaxDispatchProcess;
    }
    
    public void setMapAdvDispProExp(map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapAdvDispProExp) {
        this.mapAdvDispProExp = mapAdvDispProExp;
    }
    
    public map<Id, list<SVMXC__ServiceMax_Config_Data__c>> getMapAdvDispProExp() {
        return this.mapAdvDispProExp;
    }
    
    public void setMapContDispProExp(map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapContDispProExp) {
        this.mapContDispProExp = mapContDispProExp;
    }
    
    public map<Id, list<SVMXC__ServiceMax_Config_Data__c>> getMapContDispProExp() {
        return this.mapContDispProExp;
    }
    
    public void setMapECODispProExp(map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapECODispProExp) {
        this.mapECODispProExp = mapECODispProExp;
    }
    
    public map<Id, list<SVMXC__ServiceMax_Config_Data__c>> getMapECODispProExp() {
        return this.mapECODispProExp;
    }
    
    public void setMapLTPDispProExp(map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapLTPDispProExp) {
        this.mapLTPDispProExp = mapLTPDispProExp;
    }
    
    public map<Id, list<SVMXC__ServiceMax_Config_Data__c>> getMapLTPDispProExp() {
        return this.mapLTPDispProExp;
    }
    
    public void setMapECODispatchProcess(map<Id, SVMXC__ServiceMax_Processes__c> mapECODispatchProcess) {
        this.mapECODispatchProcess = mapECODispatchProcess;
    }
    
    public map<Id, SVMXC__ServiceMax_Processes__c> getMapECODispatchProcess() {
        return this.mapECODispatchProcess;
    }
    
    public void setMapLTPDispatchProcess(map<Id, SVMXC__ServiceMax_Processes__c> mapLTPDispatchProcess) {
        this.mapLTPDispatchProcess = mapLTPDispatchProcess;
    }
    
    public map<Id, SVMXC__ServiceMax_Processes__c> getMapLTPDispatchProcess() {
        return this.mapLTPDispatchProcess;
    }
    
    public void setMapAllDispProExp(map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapAllDispProExp) {
        this.mapAllDispProExp = mapAllDispProExp;
    }
    
    public map<Id, list<SVMXC__ServiceMax_Config_Data__c>> getMapAllDispProExp() {
        return this.mapAllDispProExp;
    }
    
    public void setMapTerritoryRules(map<Id, SVMXC__ServiceMax_Processes__c> mapTerritoryRules) {
        this.mapTerritoryRules = mapTerritoryRules;
    }
    
    public map<Id, SVMXC__ServiceMax_Processes__c> getMapTerritoryRules() {
        return this.mapTerritoryRules;
    }
    
    public void setMapDispProTerritory(map<Id, set<string>> mapDispProTerritory) {
        this.mapDispProTerritory = mapDispProTerritory;
    }
    
    public map<Id, set<string>> getMapDispProTerritory() {
        return this.mapDispProTerritory;
    }
    
    public void setMapTertryDispProcess(map<Id, Id> mapTertryDispProcess) {
        this.mapTertryDispProcess = mapTertryDispProcess;
    }
    
    public map<Id, Id> getMapTertryDispProcess() {
        return this.mapTertryDispProcess;
    }
    
    public void setMapSimpleDispRulesExp(map<Id, map<Id, list<SVMXC__ServiceMax_Config_Data__c>>> mapSimpleDispRulesExp) {
        this.mapSimpleDispRulesExp = mapSimpleDispRulesExp;
    }
    
    public map<Id, map<Id, list<SVMXC__ServiceMax_Config_Data__c>>> getMapSimpleDispRulesExp() {
        return this.mapSimpleDispRulesExp;
    }
    
    public void setMapPriorityDispRulesExp(map<Id, map<Id, list<SVMXC__ServiceMax_Config_Data__c>>> mapPriorityDispRulesExp) {
        this.mapPriorityDispRulesExp = mapPriorityDispRulesExp;
    }
    
    public map<Id, map<Id, list<SVMXC__ServiceMax_Config_Data__c>>> getMapPriorityDispRulesExp() {
        return this.mapPriorityDispRulesExp;
    }
    
    public void setMapTerritoryFieldMap(map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapTerritoryFieldMap) {
        this.mapTerritoryFieldMap = mapTerritoryFieldMap;
    }
    
    public map<Id, list<SVMXC__ServiceMax_Config_Data__c>> getMapTerritoryFieldMap() {
        return this.mapTerritoryFieldMap;
    }
    
    public void setMapMTTSDispRulesExp(map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapMTTSDispRulesExp) {
        this.mapMTTSDispRulesExp = mapMTTSDispRulesExp;
    }
    
    public map<Id, list<SVMXC__ServiceMax_Config_Data__c>> getMapMTTSDispRulesExp() {
        return this.mapMTTSDispRulesExp;
    }
    
    public void setMapTerritoryDispRulesExp(map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapTerritoryDispRulesExp) {
        this.mapTerritoryDispRulesExp = mapTerritoryDispRulesExp;
    }
    
    public map<Id, list<SVMXC__ServiceMax_Config_Data__c>> getMapTerritoryDispRulesExp() {
        return this.mapTerritoryDispRulesExp;
    }
    
    public void setMapCapacityLimitRulesExp(map<Id, map<Id, list<SVMXC__ServiceMax_Config_Data__c>>> mapCapacityLimitRulesExp) {
        this.mapCapacityLimitRulesExp = mapCapacityLimitRulesExp;
    }
    
    public map<Id, map<Id, list<SVMXC__ServiceMax_Config_Data__c>>> getMapCapacityLimitRulesExp() {
        return this.mapCapacityLimitRulesExp;
    }
    
    public class ObjectsDataWrapper {
        
        public map<Id, SVMXC__Installed_Product__c> mapComponent = new map<Id, SVMXC__Installed_Product__c>();
        public map<Id, Account> mapCompany = new map<Id, Account>();
        public map<Id, SVMXC__Site__c> mapLoc = new map<Id, SVMXC__Site__c>();
        public map<Id, Case> mapCases = new map<Id, Case>();
    }
}