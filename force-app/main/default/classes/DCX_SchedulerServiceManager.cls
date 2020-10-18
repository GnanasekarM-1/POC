/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * Service manager which has business logic for all the services, related to scheduler component, re-written for DCx
 * @author Vinay Vijay
 * @version 19.2000
 * @since 2019
 */
public with sharing class DCX_SchedulerServiceManager {
/*    
    //This method provides list of teams and territories for building the Team/Technician Tree
    public static TeamTerritoryDCx fetchTeamTerritoryTree(String searchType) {
long t1 = DateTime.now().getTime();
        String type='';
        TeamTerritoryDCx data;
        if(searchType != null)
            type = searchType.toUpperCase();
        if(type !='TERRITORY' && type !='TEAM' && type !='BOTH')
            throw new DCxCommonServiceManager.DCxException('Please specify a valid type (TEAM|TERRITORY|BOTH) for your request');

        if(type.equals('TERRITORY')) {
            data = fetchTerritories();
        } else if(type.equals('TEAM')){
            data = fetchTeams();
        } else if(type.equals('BOTH')) {
            data = fetchTeamsTerritories();
        }

        return data;
    }
*/
    public static SMAX_OptiMax_EngineUtils clsOMAXEngineUtils = new SMAX_OptiMax_EngineUtils();
    public static map<string, string> mapobjectApiLabel = new map<string, string>();
    // public static COMM_SecurityUtils securityUtils = COMM_SecurityUtils.getInstance();
    public static SchedulerDataDCx fetchSchedulerData() {
        String UserId = UserInfo.getUserId();
            SVMXC.DCX_Utils utils = new SVMXC.DCX_Utils();  
            DCX_Utils dcUtils = new DCX_Utils(); 
        String querySelect; 
        
        try {
            Map<String, SObjectField> newSchemaFieldMap = new Map<String, SObjectField>();
            List<String> lstTechFieldsToLoad = new list<string>();
            set<String> setTechFieldsToLoad = new set<string>();
            
            setTechFieldsToLoad = getTechFieldstoLoadDCx();
            
            Map<String, SObjectField> souObjfieldMap = Schema.SObjectType.SVMXC__Service_Group_Members__c.fields.getMap(); // Get field definition map for work order           
            //Get only those WO fields which has to be populated, we can skip the rest
            for (String fieldKey : souObjfieldMap.keySet()) {
                String fieldName='';
                Schema.SObjectField fsObj = souObjfieldMap.get(fieldKey); 
                Schema.DescribeFieldResult f = fsObj.getDescribe();
                fieldName = f.getName();
                if(setTechFieldsToLoad.contains(fieldName))
                    newSchemaFieldMap.put(fieldName, fsObj);
            }
            souObjfieldMap.clear();

                DCX_Utils.referenceFields_WP reference_M = dcUtils.SVMX_getReferenceFields(newSchemaFieldMap,true);
            lstTechFieldsToLoad = reference_M.allFields_L;
            COMM_Utils_V2 objCOMM_UtilV2 = new COMM_Utils_V2();
            lstTechFieldsToLoad = objCOMM_UtilV2.checkDuplicateFields(lstTechFieldsToLoad, 'SVMXC__Service_Group_Members__c');

            querySelect = utils.SVMX_getFieldNamesFromList(lstTechFieldsToLoad);

            String commonTechSoql = 'Select '+querySelect+',SVMXC__Service_Group__r.SVMXC__Latitude__c,SVMXC__Service_Group__r.SVMXC__Longitude__c,SVMXC__Service_Group__r.SVMXC__Street__c,SVMXC__Service_Group__r.SVMXC__City__c,SVMXC__Service_Group__r.SVMXC__State__c,SVMXC__Service_Group__r.SVMXC__Zip__c,SVMXC__Service_Group__r.SVMXC__Country__c,Id  From SVMXC__Service_Group_Members__c where SVMXC__Active__c=true AND ';
            String notDispatcherClause = 'SVMXC__Salesforce_User__c = \''+ UserId+'\'';
            Boolean isDisp = false; 
            //fetch techs for subscribed territories
            ID_WP wp = fetchTerritoryIds();
system.debug('---------------->wp.ids'+wp.ids.size());
            List<String> idList =new List<String>();
            idList.addAll(wp.ids);
            String s = utils.SVMX_getFieldNamesFromList(idList);
            s = s.replaceAll(',','\',\'');
            String dispatcherClause = 'SVMXC__Service_Territory__c IN (\''+s+'\')';
system.debug('---------------->wp.ids after: '+s);
system.debug('Is dispatcher = ' + wp.isDispatcher);
            system.debug('First Query = '+commonTechSoql+dispatcherClause);
            List<Technician_WP> techList = fetchTechs(wp.isDispatcher,commonTechSoql,dispatcherClause,notDispatcherClause);
            List<Technician_WP> technician_LWP = new List<Technician_WP>();
            technician_LWP.addAll(techList);
            if(wp.isDispatcher)
                isDisp = wp.isDispatcher;
system.debug('Number of tech terr wise:'+techList.size());  
                                
            //fetch techs for subscribed teams
            wp = fetchTeamIds();
            system.debug('wp team '+wp);
            idList.clear();
            idList.addAll(wp.ids);
            s = utils.SVMX_getFieldNamesFromList(idList);
            s = s.replaceAll(',','\',\'');
            dispatcherClause = 'SVMXC__Service_Group__c IN (\''+s+'\')';
            system.debug('Second Query = '+commonTechSoql+dispatcherClause);
            techList = fetchTechs(wp.isDispatcher,commonTechSoql,dispatcherClause,notDispatcherClause);
            technician_LWP.addAll(techList);
            if(wp.isDispatcher)
                isDisp = wp.isDispatcher;
system.debug('Number of tech team wise:'+techList.size());
            //eliminate duplicates by putting them into a set
            Set<Technician_WP> techSet = new Set<Technician_WP>(technician_LWP);
            Map<String,Technician_WP> techMap = new Map<String,Technician_WP>();
            for(Technician_WP t : techSet)
                techMap.put(t.technician_O.ID,t);
                
            SchedulerDataDCx schedulerData = new SchedulerDataDCx(techMap,fetchTerritories(),wp.ids,isDisp,UserInfo.getName());
    
            return schedulerData;
        }
        catch (QueryException ex){
            system.debug('StackTrace: '+ex.getStackTraceString());
            throw new DCX_CommonServiceManager.DCxException(ex.getMessage());
        }catch (Exception ex){
            system.debug('StackTrace: '+ex.getStackTraceString());
            throw new DCX_CommonServiceManager.DCxException(ex.getmessage());
        }
    }
    
    private static List<Technician_WP> fetchTechs(Boolean isDispatcher, String commonTechSoql, String dispatcherClause, String notDispatcherClause) {
        List<Technician_WP> technician_LWP = new List<Technician_WP>(); //Result set for the method
        Technician_WP Technician_WP;
        //set<String> tech_s = new set<String>();//Setup the latlong of Home base if exist -- DCH-260
        List<SVMXC__Service_Group_Members__c> techMembers = 
            new List<SVMXC__Service_Group_Members__c>();
        String finalTechSoql;
        if(isDispatcher) {
            finalTechSoql = commonTechSoql + dispatcherClause;
        }
        else {
            finalTechSoql = commonTechSoql + notDispatcherClause;
        }
        for(SVMXC__Service_Group_Members__c tech: Database.query(finalTechSoql)){
            //tech_s.add(tech.Id);  -- DCH-260
            techMembers.add(tech);
        } 
        if(techMembers.size() > 0) {
            Map<String, SVMXC__Service_Group_Site__c> temp_techHB = 
                new Map<String, SVMXC__Service_Group_Site__c>();
            for(SVMXC__Service_Group_Site__c hb: [SELECT SVMXC__Street__c, 
                                                    SVMXC__City__c, SVMXC__State__c, 
                                                    SVMXC__Country__c,
                                                    SVMXC__Latitude__c, SVMXC__Longitude__c, 
                                                    SVMXC__Technician_Equipment__c, SVMXC__Zip__c 
                                                    from SVMXC__Service_Group_Site__c where 
                                                    SVMXC__Technician_Equipment__c IN :techMembers 
                                                    AND SVMXC__Latitude__c != NULL AND 
                                                    SVMXC__Longitude__c != NULL AND 
                                                    SVMXC__IsCurrent__c = TRUE AND 
                                                    RecordType.Name='Home Bases']){
                temp_techHB.put(hb.SVMXC__Technician_Equipment__c, hb);
            }
            //tech_s.clear(); // Defect 24494: releasing the data - not used anymore    -- DCH-260 
            //14494 
            for(SVMXC__Service_Group_Members__c tech: techMembers){
                //DNS-572
                if(temp_techHB.get(tech.id) != NULL)
                    Technician_WP = new Technician_WP(tech,temp_techHB.get(tech.id));  
                else
                    Technician_WP = new Technician_WP(tech,null);   
                system.debug('TEST EACH tech. '+Technician_WP);
                technician_LWP.add(Technician_WP);
            }
        }
        return technician_LWP;
    }


    private static List<SVMXC__Territory__c>    fetchTerritories() {
        List<SVMXC__Territory__c> TerritoryList = new List<SVMXC__Territory__c>();
        ID_WP wp;
        try {
            wp = fetchTerritoryIds();

            //fetch territories
            TerritoryList = [Select Id, Name, SVMXC__Parent_Territory__c, SVMXC__Active__c 
                             From SVMXC__Territory__c where Id IN :wp.ids];
            for(SVMXC__Territory__c tt: TerritoryList) {
                if(wp.ids.contains(tt.SVMXC__Parent_Territory__c) == false)
                    tt.SVMXC__Parent_Territory__c = NULL;
            }
        }
        catch (QueryException ex){
            throw new DCX_CommonServiceManager.DCxException(ex.getMessage());
        }catch (Exception ex){
            throw new DCX_CommonServiceManager.DCxException(ex.getmessage());
        }
        
        return TerritoryList;
    }
    
    private static ID_WP fetchTerritoryIds() {
        String UserId = UserInfo.getUserId();
        List<SVMXC__Dispatcher_Access__c> AvailTerritories = new List<SVMXC__Dispatcher_Access__c>();
        set<String> AvailTrrId = new set<String>();
        Boolean isDispatcher = false;
        String QueryStr = 'Select SVMXC__Territory__c From SVMXC__Dispatcher_Access__c where SVMXC__Dispatcher__c =: UserId';
        
        try {
            //fetch all the team and territory ids
            AvailTerritories = Database.query(QueryStr);
            system.debug('Avail Terrs = '+AvailTerritories);
            if(AvailTerritories.isEmpty()){
                for(SVMXC__Service_Group_Members__c tech: [Select Id, SVMXC__Service_Territory__c 
                                                             from SVMXC__Service_Group_Members__c 
                                                             where SVMXC__Salesforce_User__c = : UserId 
                                                             AND SVMXC__Active__c=true]){
                    if(tech.SVMXC__Service_Territory__c != NULL)
                        AvailTrrId.add(tech.SVMXC__Service_Territory__c);
                }
            }
            else {
                for(SVMXC__Dispatcher_Access__c at: AvailTerritories){
                    system.debug('at.SVMXC__Territory__c: '+at.SVMXC__Territory__c);                    
                    if(at.SVMXC__Territory__c != NULL)
                        AvailTrrId.add(at.SVMXC__Territory__c);
                }
                if(AvailTrrId.size() > 0) {
                    isDispatcher = true;
                }
            }
        }
        catch (QueryException ex){
            throw new DCX_CommonServiceManager.DCxException(ex.getMessage());
        }catch (Exception ex){
            throw new DCX_CommonServiceManager.DCxException(ex.getmessage());
        }
system.debug('Number of territories:'+AvailTerritories.size()+' :'+AvailTrrId.size());      
        //if AvailTerritories is empty then logged in user is not dispatcher, hence set false
        ID_WP wp = new ID_WP(isDispatcher,AvailTrrId);
        
        return wp;
    }

    public static Tech_WorkingHours DCX_Retrieve_Tech_WorkingHrs_WS(List<String> lsttechId, String startdate, String enddate)
    {
        //COMM_Utils_ManageSettings commUtils = new COMM_Utils_ManageSettings();
        Map<String, String> svmxSetting = new Map<String, String> ();
        svmxSetting = COMM_Utils_ManageSettings.SVMX_getuniqueSettingValue('DCON001','SET001');
        List<tech_business_break_hrs> lsttechhrs = new List<tech_business_break_hrs>();
        List<BusinessHours> lstbusinesshrs = new List<BusinessHours>();
        List<Businesshrs_Holidays> lstHolidays = new List<Businesshrs_Holidays>();
        BusinessHours default_businesshr = new BusinessHours();
        System.debug('lsttechId: '+lsttechId);
        System.debug('startdate:' + startdate);
        System.debug('endate:' + enddate);
        Date DstartDate;
        Date DendDate;
            SVMXC.DCX_Utils utils = new SVMXC.DCX_Utils();      
        try
        {
            If (String.isBlank(startDate))
                DstartDate = System.today();
            else
                DstartDate = Date.valueOf(startdate);   
            If (String.isBlank(enddate))
                DendDate = Dstartdate.addDays(integer.valueOf(svmxSetting.get('SET001')) - 1);
            else
                DendDate = Date.valueOf(endDate);   
                
            If (lsttechId.size() > 0 && lsttechId != NULL)
            {
                Set<String> tech_t = new Set<string>(); 
                set<String> techlst = new set<String>();
                set<String> tech_businesshr_Ids = new set<String>();
                Map<Id,Id> territory_businesshrs = new Map<Id,Id>();
                List<SVMXC__Service_Group_Members__c> techMembers = 
                    new List<SVMXC__Service_Group_Members__c>();
                Map<Id,SVMXC__Territory__c> techTerritory = new Map<Id,SVMXC__Territory__c>();
                //set<String> tech_breakhr_Ids = new set<String>();
                techlst.addAll(lsttechId);
                techMembers =  [Select Id,SVMXC__Service_Territory__c,SVMXC__Working_Hours__c,
                                SVMXC__Break_Hours__c,
                                SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c,
                                SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.IsActive
                                From SVMXC__Service_Group_Members__c where Id IN : techlst];
                for(SVMXC__Service_Group_Members__c tech : techMembers)
                {
                    If(tech.SVMXC__Service_Territory__c != null)              
                        tech_t.add(tech.SVMXC__Service_Territory__c);
                    If(tech.SVMXC__Working_Hours__c != null)  
                        tech_businesshr_Ids.add(tech.SVMXC__Working_Hours__c);
                    if(tech.SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.IsActive) {
                        if(tech.SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c != null) {
                            tech_businesshr_Ids.add(tech.SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c);
                        }
                        territory_businesshrs.put(tech.SVMXC__Service_Territory__c,tech.SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c);
                    }
                }
                
                System.debug('tech_t:' + tech_t);
                System.debug('tech_businesshr_Ids' + tech_businesshr_Ids);
                tech_t.clear();
                System.debug('tech_businesshr_Ids after territory' + tech_businesshr_Ids);
                     
                Set<Id> active_Businesshrs = new Set<Id>(); 
                //Set<Id> active_Breakhrs = new Set<Id>();
                for(BusinessHours bh : [Select MondayStartTime, MondayEndTime,TuesdayStartTime, TuesdayEndTime,
                                        WednesdayStartTime, WednesdayEndTime,ThursdayStartTime, ThursdayEndTime,
                                        FridayStartTime, FridayEndTime,SaturdayStartTime, SaturdayEndTime,
                                        SundayStartTime, SundayEndTime,IsDefault, IsActive, Id,TimeZoneSidKey
                                        from BusinessHours where (Id IN : tech_businesshr_Ids OR
                                        IsDefault = true ) and IsActive = true]) {
                    if(tech_businesshr_Ids.contains(bh.Id)) {
                        active_Businesshrs.add(bh.Id);
                    }
                    if(bh.IsDefault) {
                        default_businesshr = bh;                            
                    }
                    lstbusinesshrs.add(bh);
                        lstHolidays.add(new Businesshrs_Holidays(String.valueOf(bh.Id), utils.GetHolidays(bh, DstartDate, DendDate), bh.TimeZoneSidKey));
                }
                tech_businesshr_Ids.clear();
                System.debug('active_Businesshrs:' + active_Businesshrs);
                System.debug('Heap size5: ' + Limits.getHeapSize());        
                
                String temp_Businesshr_ID;
                //String temp_break_ID;
                //loop to retrieve each technician with technician Id, workinghours Id, breakhours Id.
                for(SVMXC__Service_Group_Members__c tech: techMembers) {
                    
                    if(tech.SVMXC__Working_Hours__c!=null && 
                       active_Businesshrs.contains(tech.SVMXC__Working_Hours__c)) {
                        temp_Businesshr_ID = String.valueOf(tech.SVMXC__Working_Hours__c);
                    }
                    else if(tech.SVMXC__Service_Territory__c!=null 
                            && territory_businesshrs.containsKey(tech.SVMXC__Service_Territory__c) 
                            && territory_businesshrs.get(tech.SVMXC__Service_Territory__c)!=null) {
                        temp_Businesshr_ID = String.valueOf(territory_businesshrs.get(tech.SVMXC__Service_Territory__c));
                    }
                    else {
                        temp_Businesshr_ID = String.valueOf(default_businesshr.Id);
                    }
                    lsttechhrs.add(new tech_business_break_hrs(String.valueOf(tech.Id),temp_Businesshr_ID,null));
                }
                techlst.clear();
                territory_businesshrs.clear();
                //active_Breakhrs.clear();
                active_Businesshrs.clear();
                default_businesshr = null;
                System.debug('lsttechhrs: ' + lsttechhrs);  
            }       
        }
        catch (DmlException ex){
            throw new DCX_CommonServiceManager.DCxException(ex.getDmlMessage(0));
        }catch (Exception ex){
            system.debug('printing in catch block'+ ex.getStacktracestring());
            throw new DCX_CommonServiceManager.DCxException(ex.getmessage());
        }
        //System.debug('return value:' + new Tech_WorkingHours(lsttechhrs, lstbusinesshrs, lstbreakhrs, lstHolidays));
        System.debug('return value:' + new Tech_WorkingHours(lsttechhrs, lstbusinesshrs, null, lstHolidays));   
        System.debug('Heap size9: ' + Limits.getHeapSize());    
        //return  new Tech_WorkingHours(lsttechhrs, lstbusinesshrs, lstbreakhrs, lstHolidays);
        return  new Tech_WorkingHours(lsttechhrs, lstbusinesshrs, null, lstHolidays);   
    }

    public static MCTMDetails getMCTMDetails(list<string> lstWorkorderIds)
    {
        MCTMDetails objMCTMDetails = new MCTMDetails();
        list<SVMXC__Service_Order__c> lstWorkOrder = new list<SVMXC__Service_Order__c>();
        //list<Id> lstWorkorderIds = new list<Id>();
        try
        {
            
            System.debug(logginglevel.warn,'lstWorkorderIds '+lstWorkorderIds);
            if(lstWorkorderIds != null || lstWorkorderIds.size() > 0)
            {
                    lstWorkOrder = DCX_WOServiceManager.getWO(lstWorkOrderIds);
            }       
            System.debug(logginglevel.warn,'lstWorkOrder '+lstWorkOrder);
            
            objMCTMDetails.productExpertise = lstWorkOrder.get(0).SVMXC__Product__c;
            objMCTMDetails.lstskill.addAll(getSkillsetFromWO(lstWorkOrder));
            objMCTMDetails.lstEligibility.addAll(getMatchingTechnicianEligibilityRulesforWO(lstWorkOrder));
            objMCTMDetails.lstCandidatePrefTechId.addAll(getAllCandidateTechDetails(lstWorkOrder));
            //list<String> lstEvntHov = new list<String>();
            //lstEvntHov = DCON_Work_Order_WS.DCON_Retrieve_Work_Order_EventHover(lstWorkOrderIds.get(0));
            //if(lstEvntHov.size()>0)
                //objMCTMDetails.lstEventHover.addAll(lstEvntHov);
            System.debug(logginglevel.warn,'objMCTMDetails '+objMCTMDetails);
        }
        catch(Exception ex)
        {
            system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new DCX_CommonServiceManager.DCxException(ex.getmessage());
        }
        return objMCTMDetails;
    
    }

    public static list<skill> getSkillsetFromWO(list<SVMXC__Service_Order__c> lstWorkOrder)
    {
        system.debug('list<SVMXC__Service_Order__c> = ' + lstWorkOrder);
        string strSkillSet = '';
        list<skill> wrpSkillValues = new list<skill>();
        try
        {
            for(SVMXC__Service_Order__c objWorkOrder: lstWorkOrder)
            {
                strSkillSet = objWorkOrder.SVMXC__Skill_Set__c;
            }
            
            if(strSkillSet != null && strSkillSet !='') 
            {
                wrpSkillValues = (List<skill>)JSON.deserialize(strSkillSet, List<skill>.class);
            }  
        }           
        catch(Exception ex)
        {
             system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new DCX_CommonServiceManager.DCxException(ex.getMessage());
        }
        return wrpSkillValues;
    }

    public static list<Eligibility> getMatchingTechnicianEligibilityRulesforWO(list<SVMXC__Service_Order__c> lstWorkOrder)
    {
        list<Eligibility> lstEligibility = new list<Eligibility>();
        map<Id, set<Id>> mapMatchedEligibilityScore = new map<Id, set<Id>>();
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapEligibilityMatchExpressions = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        // Get the list of all valid Expertise Match rules
        map<Id, Id> mapWorkOrderRule = new map<Id, Id>();
        map<Id, SVMXC__ServiceMax_Processes__c> mapOMaxEligibilityRules = new map<Id, SVMXC__ServiceMax_Processes__c>();
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapOMaxEligibilityRulesExpression = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        try
        {
            mapOMaxEligibilityRules.putAll([SELECT Id, SVMXC__Sequence__c, SVMXC__Advance_Expression__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' and SVMXC__Rule_Type__c = 'Tech Eligibility' and SVMXC__Active__c = true order by SVMXC__Sequence__c]);
            
            //get the corresponding Config data (entry criteria) of the process_object list: mapOMaxEligibilityRules
            mapOMaxEligibilityRulesExpression = clsOMAXEngineUtils.getWorkOrderExpression(mapOMaxEligibilityRules,  'Tech_Eligibility');
            system.debug(logginglevel.WARN, 'Technician Eligibility Match: Rule -> Expression ' + mapOMaxEligibilityRules + mapWorkOrderRule.size());
            
            
            mapWorkOrderRule = clsOMAXEngineUtils.parseWorkOrderExpressions(lstWorkOrder, mapOMaxEligibilityRules, mapOMaxEligibilityRulesExpression);
            system.debug(logginglevel.WARN, 'Technician Eligibility Match: Work Order -> Rules: ' + mapWorkOrderRule);
            
            list<SVMXC__ServiceMax_Config_Data__c> eligibilities = [Select Id, SVMXC__Source_Field_Name__c, SVMXC__Target_Field_Name__c, SVMXC__Display_Type__c, SVMXC__Sequence__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Field_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, SVMXC__Display_Value__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Expressions' and SVMXC__Expression_Type__c = 'Tech_Match' and SVMXC__Expression_Rule__c IN :mapWorkOrderRule.values() order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            for(SVMXC__ServiceMax_Config_Data__c confData: eligibilities)
            {
                list<SVMXC__ServiceMax_Config_Data__c> lstEligibilities = new list<SVMXC__ServiceMax_Config_Data__c>();
                if(!mapEligibilityMatchExpressions.containsKey(confData.SVMXC__Expression_Rule__c))
                    mapEligibilityMatchExpressions.put(confData.SVMXC__Expression_Rule__c, null);
                if(mapEligibilityMatchExpressions.get(confData.SVMXC__Expression_Rule__c) != null)
                    lstEligibilities = mapEligibilityMatchExpressions.get(confData.SVMXC__Expression_Rule__c);
                lstEligibilities.add(confData);
                mapEligibilityMatchExpressions.put(confData.SVMXC__Expression_Rule__c, lstEligibilities);
            }
            
            for(SVMXC__Service_Order__c objWorkOrder: lstWorkOrder)
            {
                set<Id> mapTechnicianScore = new set<Id>();
                list<SVMXC__ServiceMax_Config_Data__c> lstEligibilities = new list<SVMXC__ServiceMax_Config_Data__c>();
                //Getting eligibility for this work order
                if(mapEligibilityMatchExpressions.containsKey(mapWorkOrderRule.get(objWorkOrder.Id)))
                    lstEligibilities = mapEligibilityMatchExpressions.get(mapWorkOrderRule.get(objWorkOrder.Id));
                else//Go to next work order, there is no expression to match for tech eligibility
                    continue;
                
                for(SVMXC__ServiceMax_Config_Data__c confElig:lstEligibilities)
                {
                    Eligibility objElig = new Eligibility();
                    objElig.techField = confElig.SVMXC__Field_Name__c;
                    objElig.operator = confElig.SVMXC__Operator__c;
                    objElig.WOfield = confElig.SVMXC__Target_Field_Name__c;
                    objElig.value = confElig.SVMXC__Display_Value__c;
                    lstEligibility.add(objElig);
                }
            }
            
        }
        catch(Exception ex)
        {
             system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new DCX_CommonServiceManager.DCxException(ex.getMessage());
        }
        return lstEligibility;
    }

    public static list<SVMXMap> getAllCandidateTechDetails(list<SVMXC__Service_Order__c> lstWorkOrder)
    {
        list<SVMXMap> ObjNameTechId = new list<SVMXMap>();
        Boolean isWOPrefTechMatchWORes = false;
        try
        {
            if(lstWorkOrder != null && lstWorkOrder.size() >0)
            {
                List<SVMXC__Work_Order_Resource__c> lstWOResources = DataBase.Query('Select Id,SVMXC__Group_Member__c,SVMXC__Preference_Type__c,SVMXC__Work_Order__c from SVMXC__Work_Order_Resource__c where SVMXC__Work_Order__c IN :lstWorkOrder');
                
                for(SVMXC__Work_Order_Resource__c objWOResource: lstWOResources)
                {
                    SVMXMap objSVMXMap1 = new SVMXMap();
                    objSVMXMap1.key = objWOResource.SVMXC__Group_Member__c;
                    objSVMXMap1.value = objWOResource.SVMXC__Preference_Type__c;
                    ObjNameTechId.add(objSVMXMap1); 
                    If(lstWorkOrder.get(0).SVMXC__Preferred_Technician__c != null && String.valueOf(lstWorkOrder.get(0).SVMXC__Preferred_Technician__c).substring(0,15).equals(String.valueOf(objWOResource.SVMXC__Group_Member__c).substring(0,15)))
                    {
                        isWOPrefTechMatchWORes = true; 
                    }
                }
                If(!isWOPrefTechMatchWORes && lstWorkOrder.get(0).SVMXC__Preferred_Technician__c != null)
                {
                    SVMXC__Work_Order_Resource__c insertWORes = new SVMXC__Work_Order_Resource__c();
                    insertWORes.SVMXC__Work_Order__c = lstWorkOrder.get(0).Id;
                    insertWORes.SVMXC__Group_Member__c  = lstWorkOrder.get(0).SVMXC__Preferred_Technician__c;
                    insertWORes.SVMXC__Preference_Type__c = 'Preferred';
                    //CRUD checking
                    // If(!securityUtils.verifyFieldAccess(insertWORes, COMM_SecurityUtils.Access.Createable))
                    //     {
                    //         throw new DCX_CommonServiceManager.DCxException(System.Label.COMM001_TAG142 + ':' + mapobjectApiLabel.get('SVMXC__Work_Order_Resource__c') );  
                    //     }
                    //     else
                    //     {
                            COMM_SecurityUtils.getinstance().insertAsUser(insertWORes); //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        // }
                    SVMXMap objSVMXMap1 = new SVMXMap();
                    objSVMXMap1.key = lstWorkOrder.get(0).SVMXC__Preferred_Technician__c;
                    objSVMXMap1.value = 'Preferred';
                    ObjNameTechId.add(objSVMXMap1); 
                    
                }
            }   
        }
        catch(Exception ex)
        {
             system.debug(LoggingLevel.WARN, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
            throw new DCX_CommonServiceManager.DCxException(ex.getMessage());
        }
        
        System.debug('Result:' + ObjNameTechId);
        return ObjNameTechId;
    }

    //This method provides list of Technicians for building the Tean/Technician Tree or Territory Tree
//    public static List<Technician_WP> fetchTechnicians(String SearchType, /*String timeZone,*/List<String> ServiceTeamTerr) {
//long t1=0,t2=0,t3=0,t4=0,t5=0,t6=0,t7=0,t8=0,t9=0,t10=0,t11=0,t12=0;      
//t1 = DateTime.now().getTime();
//        String UserId = UserInfo.getUserId();
//        if(SearchType.toUpperCase()!='TERRITORY' && SearchType.toUpperCase()!='TEAM')
//            throw new DCX_CommonServiceManager.DCxException('Please specify a valid type (TEAM|TERRITORY) for your request');
        
        /* Import required classes */
//        SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();  
//        DCON_Utils dcUtils = new DCON_Utils(); 
        /* Variable definitions */
//        String querySelect; 
//        Boolean isLocal = false;
//        Boolean isDispatcher = true;
//        List<Technician_WP> technician_LWP = new List<Technician_WP>(); //Result set for the method
        
//        try
//        {
/*            if(!UserId.equals(Userinfo.getUserId()))
                timeZone = [SELECT TimeZoneSidKey from User where Id = :UserId].TimeZoneSidKey;
            else
            {
                timeZone = Userinfo.getTimeZone().getID();
                isLocal = true;
            }
*/            
//t2 = DateTime.now().getTime();
//            Map<String, SObjectField> souObjfieldMap = Schema.SObjectType.SVMXC__Service_Group_Members__c.fields.getMap(); // Get field definition map for work order
/*            map<String,String> mapAPINameLabel = new map<String,String>();
            //Loop it and create map of APIName and label for Map Hover
            if(souObjfieldMap.size() > 0)
            {
                for(String str : souObjfieldMap.keyset())
                {
                    mapAPINameLabel.put(souObjfieldMap.get(str).getDescribe().getName(),souObjfieldMap.get(str).getDescribe().getLabel());
                }
            }
*/            
//t3 = DateTime.now().getTime();
            // Get Hover Info for Technician
/*            SVMXC__ServiceMax_Processes__c objHoverHeader = new SVMXC__ServiceMax_Processes__c();
            list<SVMXC__ServiceMax_Processes__c> lstHoverHeader = new list<SVMXC__ServiceMax_Processes__c>();
            list<SVMXC__ServiceMax_Config_Data__c> lstHoverConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
            lstHoverHeader = [select id, SVMXC__Name__c, SVMXC__Values__c, SVMXC__ProcessID__c, SVMXC__Rule_Type__c, SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' and SVMXC__Rule_Type__c = 'Column Info' and SVMXC__Source_Object_Name__c = 'SVMXC__Service_Group_Members__c']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            system.debug('objHoverHeader: '+objHoverHeader);
            if(lstHoverHeader != null && lstHoverHeader.size() > 0)
            {
                objHoverHeader = lstHoverHeader[0];
            }
            if(objHoverHeader != null && objHoverHeader.id != null)
                lstHoverConfigData = [Select id, SVMXC__Expression_Rule__c, SVMXC__Object_Name2__c, SVMXC__Field_Name__c, SVMXC__Expression_Type__c, SVMXC__Sequence__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Is_Name_Field__c, SVMXC__Display_Type__c, SVMXC__FKey_Name_Field__c, SVMXC__Field_Relationship_Name__c, SVMXC__Object_Name__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =: objHoverHeader.id and RecordType.Name = 'Expressions' and SVMXC__Expression_Type__c = 'Column Field' order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
*/            
/*t4 = DateTime.now().getTime();
            Map<String, SObjectField> newSchemaFieldMap = new Map<String, SObjectField>();
            List<String> lstTechFieldsToLoad = new list<string>();
            set<String> setTechFieldsToLoad = new set<string>();
            setTechFieldsToLoad = DCON_Service_Org_WS.getTechFieldstoLoad();

            //Get only those WO fields which has to be populated, we can skip the rest
            for (String fieldKey : souObjfieldMap.keySet()) 
            {
                String fieldName='';
                Schema.SObjectField fsObj = souObjfieldMap.get(fieldKey); 
                Schema.DescribeFieldResult f = fsObj.getDescribe();
                fieldName = f.getName();
                if(setTechFieldsToLoad.contains(fieldName))
                    newSchemaFieldMap.put(fieldName, fsObj);
            }
t5 = DateTime.now().getTime();
            
            DCON_Utils.referenceFields_WP reference_M = dcUtils.SVMX_getReferenceFields(newSchemaFieldMap,true);
            souObjfieldMap.clear();
            lstTechFieldsToLoad = reference_M.allFields_L;
*//*            List<String> refFields_L = reference_M.referenceFields_L; //Get the reference field list
            List<String> dateTimeFields_L = reference_M.dateTimeFields_L; //Get the dateTime field list
            List<String> dateFields_L = reference_M.dateFields_L; //Get the date field list
            Map<String,String> replacementRef = reference_M.replacementReference_M;  //Get the replacement reference field map
            Map<String,String> replacementNameField = reference_M.replacementField_M;  //Get the name field for reference map
*/
/*            System.debug('lstTechFieldsToLoad: '+lstTechFieldsToLoad);
            querySelect = utils.SVMX_getFieldNamesFromList(lstTechFieldsToLoad);
t6 = DateTime.now().getTime();

            ID_WP wp;
            if(ServiceTeamTerr.size()==0 && SearchType=='TEAM'){
                wp = fetchTeamIds();
t7 = DateTime.now().getTime();
            }
            if(ServiceTeamTerr.size()==0 && SearchType=='TERRITORY'){
                wp = fetchTerritoryIds();
            }
            if(wp != null) {
                ServiceTeamTerr.addAll(wp.ids);
                isDispatcher = wp.isDispatcher;
            }
            
system.debug('TEST WS'+ServiceTeamTerr+ServiceTeamTerr.size());
t8 = DateTime.now().getTime();
            String QueryStr;  
            String idQuery;
//            String serviceTeamInVal = dcUtils.SVMX_get_ListOfValues(ServiceTeamTerr);  
            if(SearchType.toUpperCase()=='TEAM' && ServiceTeamTerr.size()>0){
                if(isDispatcher == true) {
                    QueryStr = 'Select '+querySelect+',SVMXC__Service_Group__r.SVMXC__Latitude__c,SVMXC__Service_Group__r.SVMXC__Longitude__c,SVMXC__Service_Group__r.SVMXC__Street__c,SVMXC__Service_Group__r.SVMXC__City__c,SVMXC__Service_Group__r.SVMXC__State__c,SVMXC__Service_Group__r.SVMXC__Zip__c,SVMXC__Service_Group__r.SVMXC__Country__c  From SVMXC__Service_Group_Members__c where SVMXC__Service_Group__c IN :ServiceTeamTerr AND SVMXC__Active__c=true';
                    idQuery = 'Select Id From SVMXC__Service_Group_Members__c where SVMXC__Service_Group__c IN :ServiceTeamTerr AND SVMXC__Active__c=true';
                }
                else {
                    QueryStr = 'Select '+querySelect+',SVMXC__Service_Group__r.SVMXC__Latitude__c,SVMXC__Service_Group__r.SVMXC__Longitude__c,SVMXC__Service_Group__r.SVMXC__Street__c,SVMXC__Service_Group__r.SVMXC__City__c,SVMXC__Service_Group__r.SVMXC__State__c,SVMXC__Service_Group__r.SVMXC__Zip__c,SVMXC__Service_Group__r.SVMXC__Country__c  From SVMXC__Service_Group_Members__c where SVMXC__Salesforce_User__c = : UserId AND SVMXC__Active__c=true';
                    idQuery = 'Select Id From SVMXC__Service_Group_Members__c where SVMXC__Salesforce_User__c = : UserId AND SVMXC__Active__c=true';
                }
            }
            else if(SearchType.toUpperCase()=='TERRITORY' && ServiceTeamTerr.size()>0){
                if(isDispatcher == true) {
                    QueryStr = 'Select '+querySelect+' From SVMXC__Service_Group_Members__c where SVMXC__Service_Territory__c IN :ServiceTeamTerr AND SVMXC__Active__c=true';
                    idQuery = 'Select Id From SVMXC__Service_Group_Members__c where SVMXC__Service_Territory__c IN :ServiceTeamTerr AND SVMXC__Active__c=true';
                }
                else {
                    QueryStr = 'Select '+querySelect+' From SVMXC__Service_Group_Members__c where SVMXC__Salesforce_User__c = : UserId AND SVMXC__Active__c=true';
                    idQuery = 'Select Id From SVMXC__Service_Group_Members__c where SVMXC__Salesforce_User__c = : UserId AND SVMXC__Active__c=true';
                }
            }
t9 = DateTime.now().getTime();
            system.debug('TECH QUERY: '+QueryStr);
            Technician_WP Technician_WP;
//            List<TechnicianSpecialFields_WP> specialFields_LWP;
            //Setup the latlong of Home base if exist
            set<String> tech_s = new set<String>();
//            Map<String, Address> techHB_M = new Map<String, Address>();
            
            //if((QueryStr != NULL) && (QueryStr != ''))
            //{
                for(SVMXC__Service_Group_Members__c tech: Database.query(idQuery)){
                    tech_s.add(tech.Id);
                }
t10 = DateTime.now().getTime();
                if(tech_s.size() > 0)
                {
                    Map<String, SVMXC__Service_Group_Site__c> temp_techHB = new Map<String, SVMXC__Service_Group_Site__c>();
                    for(SVMXC__Service_Group_Site__c hb: [SELECT SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Country__c, SVMXC__Latitude__c, SVMXC__Longitude__c, SVMXC__Technician_Equipment__c, SVMXC__Zip__c from SVMXC__Service_Group_Site__c where SVMXC__Technician_Equipment__c IN :tech_s AND SVMXC__Latitude__c != NULL AND SVMXC__Longitude__c != NULL AND SVMXC__IsCurrent__c = TRUE AND RecordType.Name='Home Bases']){
/*                        Address tempAddress = new Address();
                        tempAddress.street = hb.SVMXC__Street__c;
                        tempAddress.city = hb.SVMXC__City__c;
                        tempAddress.state = hb.SVMXC__State__c;
                        tempAddress.country = hb.SVMXC__Country__c;
                        tempAddress.zip = hb.SVMXC__Zip__c;
                        tempAddress.latitude = hb.SVMXC__Latitude__c;
                        tempAddress.longitude = hb.SVMXC__Longitude__c;
                        techHB_M.put(hb.SVMXC__Technician_Equipment__c, tempAddress);
*/                        
/*                        temp_techHB.put(hb.SVMXC__Technician_Equipment__c, hb);
                    }
t11 = DateTime.now().getTime();

                    tech_s.clear(); // Defect 24494: releasing the data - not used anymore     
                    //14494 
                    for(SVMXC__Service_Group_Members__c tech: Database.query(QueryStr)){
//                        specialFields_LWP = new List<TechnicianSpecialFields_WP>();
                        //Setup homebase lat lng if any
/*                        if(techHB_M.get(tech.id) != NULL){
                            Address tempAddress = techHB_M.get(tech.id);
                        }
*/                        
/*                        for(String s : refFields_L){
                            TechnicianSpecialFields_WP tRef;
                            Sobject ref_TO;
                            if(setTechFieldsToLoad.contains(s))
                            {
                                system.debug(' s: '+s+' replacementRef.get(s): '+replacementRef.get(s));
                                ref_TO = tech.getSobject(replacementRef.get(s));
                            }
                            if(ref_TO!=NULL){
                                tRef = new TechnicianSpecialFields_WP(s, String.valueof(ref_TO.get(replacementNameField.get(s))) );
                                specialFields_LWP.add(tRef);
                            }
                        }
*/
/*
                        for(String s : dateTimeFields_L){
                            TechnicianSpecialFields_WP tDateTime;
                            if(setTechFieldsToLoad.contains(s) && tech.get(s) != NULL){
                            //if(tech.get(s) != NULL){
                                system.debug('TEST DateTime Local Format '+tech.get(s)+Datetime.valueof(String.valueof(tech.get(s))).format() );
                                tDateTime = new TechnicianSpecialFields_WP(s, dcUtils.getDateTimeInTimezone(Datetime.valueof(tech.get(s)).date(), Datetime.valueof(tech.get(s)).time(), timeZone).format() );
                                specialFields_LWP.add(tDateTime);
                            }
                        }

                        for(String s : dateFields_L){
                            TechnicianSpecialFields_WP tDate;
                            if(setTechFieldsToLoad.contains(s) &&tech.get(s) != NULL){
                            //if(tech.get(s) != NULL){
                                system.debug('TEST EACH local DATE: '+tech.get(s)+Date.valueof(String.valueof(tech.get(s))).format() );
                                tDate = new TechnicianSpecialFields_WP(s, Date.valueof(String.valueof(tech.get(s))).format() );
                                specialFields_LWP.add(tDate);
                            }
                        }
*/                        
/*                        //DNS-572
                        if(temp_techHB.get(tech.id) != NULL)
                        {
                            Technician_WP = new Technician_WP(tech,temp_techHB.get(tech.id));  
                        }
                        else
                        {
                            Technician_WP = new Technician_WP(tech,null);   
                        }
/*
                        if(lstHoverConfigData.size() > 0)
                        {
                            list<String> lstHover = new list<String>();
                            for(Integer j = 0;j<lstHoverConfigData.size();j++)
                            {
                                String str = '';
                                if(lstHoverConfigData[j].SVMXC__Field_Name__c != null && mapAPINameLabel.containskey(lstHoverConfigData[j].SVMXC__Field_Name__c))
                                {
                                    str = '<B>'+mapAPINameLabel.get(lstHoverConfigData[j].SVMXC__Field_Name__c) +'</B>: ';
                                    if(lstHoverConfigData[j].SVMXC__Display_Type__c != null && lstHoverConfigData[j].SVMXC__Display_Type__c.touppercase() == 'REFERENCE' && tech.get(lstHoverConfigData[j].SVMXC__Field_Name__c) != null)
                                    {
                                        Sobject objRef = tech.getSobject(replacementRef.get(lstHoverConfigData[j].SVMXC__Field_Name__c));
                                        if(objRef!=NULL)
                                            str = Str +String.valueof(objRef.get(replacementNameField.get(lstHoverConfigData[j].SVMXC__Field_Name__c)));
                                    }
                                    else if(lstHoverConfigData[j].SVMXC__Display_Type__c != null && lstHoverConfigData[j].SVMXC__Display_Type__c.touppercase() != 'REFERENCE' && tech.get(lstHoverConfigData[j].SVMXC__Field_Name__c) != null)
                                    {
                                        str = str + String.valueof(tech.get(lstHoverConfigData[j].SVMXC__Field_Name__c));
                                    }
                                    lstHover.add(str);
                                }   
                            }
                        }
*/                        
/*                        system.debug('TEST EACH tech. '+Technician_WP);
                        technician_LWP.add(Technician_WP);
                    }
                } 
            //}
t12 = DateTime.now().getTime();
        }
        catch (DmlException ex){
            throw new DCX_CommonServiceManager.DCxException(ex.getDmlMessage(0));
        }catch (Exception ex){
            system.debug('printing in catch block'+ ex.getStacktracestring());
            throw new DCX_CommonServiceManager.DCxException(ex.getmessage());
        }
system.debug('time taken for 1:'+(t2-t1));
system.debug('time taken for 2:'+(t3-t2));
system.debug('time taken for 3:'+(t4-t3));
system.debug('time taken for 4:'+(t5-t4));
system.debug('time taken for 5:'+(t6-t5));
system.debug('time taken for 6:'+(t7-t6));
system.debug('time taken for 7:'+(t8-t7));
system.debug('time taken for 8:'+(t9-t8));
system.debug('time taken for 9:'+(t10-t9));
system.debug('time taken for 10:'+(t11-t10));
system.debug('time taken for 11:'+(t12-t11));
        return technician_LWP;
    }*/
/*  
    private static TeamTerritoryDCx fetchTeams() {
        List<SVMXC__Service_Group__c> TeamList = new List<SVMXC__Service_Group__c>();
        ID_WP wp;
        try {
            wp = fetchTeamIds();

            //fetch the teams
            TeamList = [Select Id, Name, SVMXC__Latitude__c, SVMXC__Longitude__c,SVMXC__Street__c,SVMXC__City__c,SVMXC__State__c,SVMXC__Zip__c,SVMXC__Country__c From SVMXC__Service_Group__c where Id IN :wp.ids];
            
        }
        catch (QueryException ex) {
            throw new DCX_CommonServiceManager.DCxException(ex.getMessage());
        }catch (Exception ex){
            throw new DCX_CommonServiceManager.DCxException(ex.getmessage());
        }
        
        //create the wrapper to be returned
        TeamTerritoryDCx data = new TeamTerritoryDCx(TeamList,null,wp.isDispatcher);
        
        return data;
    }
*/  
    private static ID_WP fetchTeamIds() {
        String UserId = UserInfo.getUserId();
        List<SVMXC__Dispatcher_Access__c> AvailTeams = new List<SVMXC__Dispatcher_Access__c>();
        set<String> AvailTeamId = new set<String>();
        Boolean teamAccess = false;
        String QueryStr = 'Select SVMXC__Service_Team__c From SVMXC__Dispatcher_Access__c where SVMXC__Dispatcher__c =: UserId';
        
        try
        {
            system.debug('QUERY:'+QueryStr);
            //fetch all the team and territory ids
            AvailTeams = Database.query(QueryStr);
            system.debug('AvailTeams ::'+AvailTeams);
            if(AvailTeams.isEmpty()){
                for(SVMXC__Service_Group_Members__c tech: [Select Id, SVMXC__Service_Group__c from SVMXC__Service_Group_Members__c where SVMXC__Salesforce_User__c = : UserId AND SVMXC__Active__c=true]){
                    if(tech.SVMXC__Service_Group__c != NULL)
                        AvailTeamId.add(tech.SVMXC__Service_Group__c);
                }
            }
            else {
                for(SVMXC__Dispatcher_Access__c at: AvailTeams){
system.debug('at.SVMXC__Service_Team__c: '+at.SVMXC__Service_Team__c);
                    if(at.SVMXC__Service_Team__c != NULL)
                        AvailTeamId.add(at.SVMXC__Service_Team__c);
                }
                if(AvailTeamId.size() > 0) {
                    teamAccess = true;
                }
            }

        }
        catch (QueryException ex){
            throw new DCX_CommonServiceManager.DCxException(ex.getMessage());
        }catch (Exception ex){
            throw new DCX_CommonServiceManager.DCxException(ex.getmessage());
        }
system.debug('Number of teams:'+AvailTeams.size()+' :'+AvailTeamId.size());     
        //if AvailTeams is empty then logged in user is not dispatcher, hence set false
        ID_WP wp = new ID_WP(teamAccess,AvailTeamId);
        
        return wp;
    }
    
/*  
    private static TeamTerritoryDCx fetchTeamsTerritories() {
long t1 = DateTime.now().getTime();
        String UserId = UserInfo.getUserId();
        List<SVMXC__Dispatcher_Access__c> AvailTeamsTerritories = new List<SVMXC__Dispatcher_Access__c>();
        set<String> AvailTeamId = new set<String>();
        set<String> AvailTrrId = new set<String>();
        List<SVMXC__Territory__c> TerritoryList = new List<SVMXC__Territory__c>();
        List<SVMXC__Service_Group__c> TeamList = new List<SVMXC__Service_Group__c>();
        String QueryStr = 'Select SVMXC__Service_Team__c, SVMXC__Territory__c From SVMXC__Dispatcher_Access__c where SVMXC__Dispatcher__c =: UserId';
        
        try
        {
            system.debug('QUERY:'+QueryStr);
            //fetch all the team and territory ids
            AvailTeamsTerritories = Database.query(QueryStr);
            if(AvailTeamsTerritories.isEmpty()){
                for(SVMXC__Service_Group_Members__c tech: [Select Id, SVMXC__Service_Group__c, SVMXC__Service_Territory__c from SVMXC__Service_Group_Members__c where SVMXC__Salesforce_User__c = : UserId AND SVMXC__Active__c=true]){
                    if(tech.SVMXC__Service_Group__c != NULL)
                        AvailTeamId.add(tech.SVMXC__Service_Group__c);
                    if(tech.SVMXC__Service_Territory__c != NULL)
                        AvailTrrId.add(tech.SVMXC__Service_Territory__c);
                }
            }
            else {
                for(SVMXC__Dispatcher_Access__c at: AvailTeamsTerritories){
                    if(at.SVMXC__Service_Team__c != NULL)
                        AvailTeamId.add(at.SVMXC__Service_Team__c);
                    if(at.SVMXC__Territory__c != NULL)
                        AvailTrrId.add(at.SVMXC__Territory__c);
                }
            }
system.debug('AvailTeamId: '+AvailTeamId.size());
system.debug('AvailTrrId: '+AvailTeamId.size());            
            //fetch all the teams and territories
            TeamList = [Select Id, Name, SVMXC__Latitude__c, SVMXC__Longitude__c,SVMXC__Street__c,SVMXC__City__c,SVMXC__State__c,SVMXC__Zip__c,SVMXC__Country__c From SVMXC__Service_Group__c where Id IN :AvailTeamId];
            
            TerritoryList = [Select Id, Name, SVMXC__Parent_Territory__c, SVMXC__Active__c From SVMXC__Territory__c where Id IN :AvailTrrId];
            for(SVMXC__Territory__c tt: TerritoryList) {
                if(AvailTrrId.contains(tt.SVMXC__Parent_Territory__c) == false)
                    tt.SVMXC__Parent_Territory__c = NULL;
            }
        }
        catch (QueryException ex){
            throw new DCX_CommonServiceManager.DCxException(ex.getMessage());
        }catch (Exception ex){
            throw new DCX_CommonServiceManager.DCxException(ex.getmessage());
        }
        
        //create the wrapper to be returned
        TeamTerritoryDCx data = new TeamTerritoryDCx(TeamList,TerritoryList,!AvailTeamsTerritories.isEmpty());
long t2 = DateTime.now().getTime();
system.debug('Time taken for fetchTeamTerritoryTree: '+(t2-t1));
        return data;
        
    }
*/
    public class SchedulerDataDCx{
        public Map<String,Technician_WP> technicians {get; set;}
        public List<SVMXC__Territory__c> territoryList {get; set;}
        public set<String> teamIds{get;set;}
        public Boolean isDispatcher{get;set;}
        public String username{get;set;}
        
        public SchedulerDataDCx(Map<String,Technician_WP> techs, List<SVMXC__Territory__c> tList, Set<String> teamIds, Boolean isDisp, String name) {
            this.technicians = techs;
            this.territoryList = tList;
            this.teamIds = teamIds;
            this.isDispatcher = isDisp;
            this.username = name;
        }
    }
/*  
    public class TeamTerritoryDCx{
        public List<SVMXC__Territory__c> territoryList {get; set;}
        public List<SVMXC__Service_Group__c> teamList {get; set;}
        public Boolean isDispatcher {get; set;}
        
        public TeamTerritoryDCx(List<SVMXC__Service_Group__c> pTeamList,List<SVMXC__Territory__c> pTerritoryList, Boolean isDisp) {
            this.teamList = pTeamList;
            this.territoryList = pTerritoryList;
            this.isDispatcher = isDisp;
        }
    }   
 */ 
    public class ID_WP {
        public Boolean isDispatcher {get; set;}
        public Set<String> ids {get; set;}
        
        public ID_WP(Boolean isDisp, Set<String> idSet) {
            this.isDispatcher = isDisp;
            this.ids = idSet;
        }
    }
    
    public class Technician_WP{
        public SVMXC__Service_Group_Members__c technician_O {get;set;}
        //DNS-572: Sending Service_Group_Site object to client for active homebase address
        public SVMXC__Service_Group_Site__c location_O {get;set;}
//        public List<TechnicianSpecialFields_WP> specialFields_LWP {get; set;}
//        public list<String> hoverInfo = new  list<String>();
        public Technician_WP(SVMXC__Service_Group_Members__c t, SVMXC__Service_Group_Site__c l/*, List<TechnicianSpecialFields_WP> references*/){
            technician_O = t;
            location_O = l;
//            specialFields_LWP = references;
        }
//        public list<String> gethoverInfo(){return hoverInfo;}
//        public void sethoverInfo(){this.hoverInfo = hoverInfo;}
    }

    public class Businesshrs_Holidays
    {
        public String BHID{get; set;}
        public List<Date> Holidays{get; set;}
        public String TimeZoneSidKey{get; set;}
        public Businesshrs_Holidays(String bid, List<Date> h, String tz)
        {
            this.BHID = bid;
            this.Holidays = h;
            this.TimeZoneSidKey = tz;
        }
    }

    public class tech_business_break_hrs
    {
        public String techID{get; set;}
        public String businesshrID{get; set;}
        public String breakhrID{get; set;}
        public tech_business_break_hrs(String t, String bs, String br)
        {
            this.techID = t;
            this.businesshrID = bs;
            this.breakhrID = br;    
        }
    }

    public class Tech_WorkingHours{
        public List<tech_business_break_hrs> tech_business_break_Ids {get; set;}
        public List<BusinessHours> tech_business_hrs {get; set;}
        public List<BusinessHours> tech_break_hrs {get; set;}
        public List<Businesshrs_Holidays> businesshrs_lstholidays {get; set;}
        
        public Tech_WorkingHours(List<tech_business_break_hrs> business_break_Ids,List<BusinessHours> business_hrs,List<BusinessHours> break_hrs, List<Businesshrs_Holidays> bh_holidays){
            this.tech_business_break_Ids = business_break_Ids;
            this.tech_business_hrs = business_hrs;
            this.tech_break_hrs = break_hrs;
            this.businesshrs_lstholidays = bh_holidays;
        }
        
    }

    public class MCTMDetails
    {
        
        public string productExpertise{get;set;}
        public list<Eligibility> lstEligibility = new list<Eligibility>();  
        public list<skill> lstskill = new list<skill>();
        public list<SVMXMap> lstCandidatePrefTechId = new list<SVMXMap>();
        public list<String> lstEventHover = new list<String>();
        
        public MCTMDetails(string productExpertise,list<Eligibility> lstEligibility,list<skill>lstskill, list<SVMXMap> lstCandidatePrefTechId)
        {
            
            this.productExpertise = productExpertise;
            this.lstEligibility = lstEligibility;
            this.lstskill = lstskill;
            this.lstCandidatePrefTechId = lstCandidatePrefTechId;
           
            
        }
        public MCTMDetails(string productExpertise,list<Eligibility> lstEligibility,list<skill>lstskill, list<SVMXMap> lstCandidatePrefTechId, list<String> lstEventHover)
        {
            
            this.productExpertise = productExpertise;
            this.lstEligibility = lstEligibility;
            this.lstskill = lstskill;
            this.lstCandidatePrefTechId = lstCandidatePrefTechId;
            this.lstEventHover = lstEventHover;
            
        }
        public MCTMDetails(){}
    }

    public class skill
    {
        public string skillId;
        public String skillName;
        public Boolean isSkillMandatory;
        public Integer skillLevel;
        
        public skill(){}
        public skill(string skillId, String skillName, Boolean isSkillMandatory, Integer skillLevel){
            this.skillId = skillId;
            this.skillName = skillName;
            this.isSkillMandatory = isSkillMandatory;
            this.skillLevel = skillLevel;
        }
    }

    public class Eligibility
    {
        public string techField;
        public string operator;
        public string WOfield;
        public string value;
        //WebService string AdvExp;
        
        
        public Eligibility(){}
        public Eligibility(string techField, String operator,string WOfield,string value)//,string AdvExp)
        {
            this.techField = techField;
            this.operator = operator;
            this.WOfield = WOfield;         
            this.value = value;         
           // this.AdvExp = AdvExp;         
        }
    }

    public class SVMXMap
    {
        public String key{get;set;} // being used for lstCandidatePrefTechId
        public String value{get;set;} // being used for lstCandidatePrefTechId
        public list<String> values {get;set;}
        public List<SVMXMap> valueMap{get;set;} // being used for QTL
        public list<skill> lstSkill{get;set;} // being used for QTL
        public List<sObject> data{get;set;}
        public sObject record{get;set;} // being used for QTL
        
        public SVMXMap()
        {
            values = new list<String>();
            valueMap = new list<SVMXMap>();
            lstSkill = new list<skill>();
        }
        public SVMXMap(String key, String value)
        {
            this.key = key;
            this.value = value;
            values = new list<String>();
            valueMap = new list<SVMXMap>();
        }
        public SVMXMap(String key, String value, List<String> values)
        {
            this.key = key;
            this.value = value;
            this.values = new List<String>();
            this.values = values;
            valueMap = new list<SVMXMap>();
        }
    }
    
    public class SchedulerDataDCxNew{
        public List<SVMXC__Service_Group__c> teamList;
        public List<SVMXC__Territory__c> territoryList;
        public String startDate;
        public String endDate;
        public Map<Id,List<techDetails>> teamTechnicianMap;
        public Map<Id,List<techDetails>> territoryTechnicianMap;
        public String userName;
        public String userId;
        public Boolean isSuperDispatcher;

        public SchedulerDataDCxNew() {}
        
        public SchedulerDataDCxNew(List<SVMXC__Service_Group__c> teams, List<SVMXC__Territory__c> tList, 
                                    String sDate, String eDate, 
                                    Map<Id,List<techDetails>> teamTechMap, 
                                    Map<Id,List<techDetails>> territoryTechMap,
                                    String usrName, String userId, Boolean isDsptcher) {
            this.teamList = teams;
            this.territoryList = tList;
            this.startDate = sDate;
            this.endDate = eDate;
            this.teamTechnicianMap = teamTechMap;
            this.territoryTechnicianMap = territoryTechMap;
            this.userName = usrName;
            this.userId = userId;
            this.isSuperDispatcher = isDsptcher;
        }
    }

    public static SchedulerDataDCxNew fetchSchedulerDataNew() {
            SVMXC.DCX_Utils utils = new SVMXC.DCX_Utils();
        String UserId = UserInfo.getUserId();
        String notDispatcherClause = 'where SVMXC__Salesforce_User__c = \''+ UserId+'\'';
        List<String> Ids = new List<String>();
        String dispatcherClause;
        DCX_CommonServiceManager.UserSetting uSet = DCX_SettingServiceManager.fetchUserSettings();
        List<String> settingIds = 
            new List<String>{'DCON001_SET033','DCON001_SET034','DCON001_SET001','DCON001_SET004'};
        Map<String,String> grpGblSettings = 
            COMM_Utils_ManageSettings.SVMX_getSettingValueForList(settingIds);
        Date startDt, endDt;
        Date today = date.today();
        String condition = uSet.tech_condition;
        Integer noOfDays = Integer.valueOf(uSet.tech_noOfDays);
        Integer daysBatchSize = Integer.valueOf(grpGblSettings.get('DCON001_SET034'));
        String schWindowDuration = grpGblSettings.get('DCON001_SET001');
        ID_WP wp = fetchTeamIds();    
        Ids.addAll(wp.ids);
        String s = utils.SVMX_getFieldNamesFromList(Ids);
        s = s.replaceAll(',','\',\'');
        dispatcherClause = 'where Id IN (\''+s+'\')';
        Map<Id,List<techDetails>> teamTechnicianMap = teamTechnicians(wp.isDispatcher,dispatcherClause,
                                                             notDispatcherClause);
        List<SVMXC__Service_Group__c> teams = [Select Id, Name, SVMXC__Latitude__c,SVMXC__Longitude__c,
                                               SVMXC__Street__c,SVMXC__City__c,SVMXC__State__c,SVMXC__Active__c,
                                               SVMXC__Zip__c,SVMXC__Country__c from SVMXC__Service_Group__c 
                                               where Id in :Ids];
        Ids.clear();
        s = null;
        wp = fetchTerritoryIds();
        Ids.addAll(wp.ids);
        s = utils.SVMX_getFieldNamesFromList(Ids);
        s = s.replaceAll(',','\',\'');
        dispatcherClause = 'where Id IN (\''+s+'\')';
        Map<Id,List<techDetails>> terrTechnicianMap = 
            territoryTechnicians(wp.isDispatcher,dispatcherClause,notDispatcherClause);
        List<SVMXC__Territory__c> terrs = [Select Id, Name, SVMXC__Parent_Territory__c, 
                                           SVMXC__Active__c from SVMXC__Territory__c where Id in :Ids];
        if(condition.equalsIgnoreCase('BEFORE')) {
                startDt = today.addDays(-noOfDays);
        } else {//AFTER
            startDt = today.addDays(noOfDays);
        }
        if(Integer.valueOf(schWindowDuration) != null && Integer.valueOf(schWindowDuration) > 0) 
            endDt = startDt.addDays(Integer.valueOf(schWindowDuration));
        else if(daysBatchSize != null && daysBatchSize > 0)
            endDt = startDt.addDays(daysBatchSize);
        User userRec = [Select Id,SVMXC__Is_Super_Dispatcher__c from User where Id = :userinfo.getUserId()];
        SchedulerDataDCxNew resp = 
            new SchedulerDataDCxNew(teams,terrs,String.valueOf(startDt),String.valueOf(endDt),
                                    teamTechnicianMap,terrTechnicianMap,UserInfo.getName(),UserId,
                                    userRec.SVMXC__Is_Super_Dispatcher__c);
        return resp;
    }
    
    public static Map<Id,Technician_WP> fetchTechDetails (DCX_Wrapper.technicianIds req) {
        List<SVMXC__Service_Group_Members__c> techMembers = new List<SVMXC__Service_Group_Members__c>();
        Map<Id,Technician_WP> techDetailsMap = new Map<Id,Technician_WP>();
        //List<Technician_WP> technician_LWP = new List<Technician_WP>();
        Technician_WP Tech_WP;
            SVMXC.DCX_Utils utils = new SVMXC.DCX_Utils();
        List<String> lstTechFieldsToLoad = new List<string>();
        Set<String> techFieldsSet = new Set<String>();
        Map<String, SObjectField> newSchemaFieldMap = new Map<String, SObjectField>();
            DCX_Utils dcUtils = new DCX_Utils(); 
        Set<String> setTechFieldsToLoad = new Set<string>();
        String querySelect;
        String s = utils.SVMX_getFieldNamesFromList(req.techIds);
        s = s.replaceAll(',','\',\'');
        String whereClause = 'AND Id IN (\''+s+'\')';
        if(req.techFields == null || req.techFields.size() == 0){
            Map<String, SObjectField> souObjfieldMap = 
                Schema.SObjectType.SVMXC__Service_Group_Members__c.fields.getMap();
            SVMXC.DCX_CommonServiceManager.UserSetting userSettings = 
                SVMXC.DCX_SettingServiceManager.fetchUserSettings();
            setTechFieldsToLoad = getTechFieldstoLoadDCx();
            for (String fieldKey : souObjfieldMap.keySet()) {
                String fieldName='';
                Schema.SObjectField fsObj = souObjfieldMap.get(fieldKey); 
                Schema.DescribeFieldResult f = fsObj.getDescribe();
                fieldName = f.getName();
                if(setTechFieldsToLoad.contains(fieldName))
                    newSchemaFieldMap.put(fieldName, fsObj);
            }
            souObjfieldMap.clear();
                DCX_Utils.referenceFields_WP reference_M = dcUtils.SVMX_getReferenceFields(newSchemaFieldMap,true);
            lstTechFieldsToLoad = reference_M.allFields_L;
            
            if(userSettings.tech_techCol != null && userSettings.tech_techCol.size() > 0){
                for(DCX_CommonServiceManager.TechCol techField : userSettings.tech_techCol) {
                    if(techField.name != null) {
                        lstTechFieldsToLoad.add(techField.name);
                    }
                }
            }
            lstTechFieldsToLoad.add('SVMXC__Salesforce_User__c');
            lstTechFieldsToLoad.add('SVMXC__Salesforce_User__r.isActive');
            lstTechFieldsToLoad.add('Id');
            lstTechFieldsToLoad.add('SVMXC__Service_Group__r.SVMXC__Latitude__c');
            lstTechFieldsToLoad.add('SVMXC__Service_Group__r.SVMXC__Longitude__c');
            lstTechFieldsToLoad.add('SVMXC__Service_Group__r.SVMXC__Street__c');
            lstTechFieldsToLoad.add('SVMXC__Service_Group__r.SVMXC__City__c');
            lstTechFieldsToLoad.add('SVMXC__Service_Group__r.SVMXC__State__c');
            lstTechFieldsToLoad.add('SVMXC__Service_Group__r.SVMXC__Zip__c');
            lstTechFieldsToLoad.add('SVMXC__Service_Group__r.SVMXC__Country__c');
            techFieldsSet.addAll(lstTechFieldsToLoad);
            lstTechFieldsToLoad.clear();
            lstTechFieldsToLoad.addAll(techFieldsSet);

            COMM_Utils_V2 objCOMM_UtilV2 = new COMM_Utils_V2();
            lstTechFieldsToLoad = objCOMM_UtilV2.checkDuplicateFields(lstTechFieldsToLoad, 'SVMXC__Service_Group_Members__c');
        
            querySelect = utils.SVMX_getFieldNamesFromList(lstTechFieldsToLoad);
            String commonTechSoql = 'Select '+querySelect+ ' From SVMXC__Service_Group_Members__c where SVMXC__Active__c=true ';
            
            String finalQuery = commonTechSoql + whereClause;
            for(SVMXC__Service_Group_Members__c tech: Database.query(finalQuery)){
                techMembers.add(tech);
            }
            if(techMembers.size() > 0) {
                Map<String, SVMXC__Service_Group_Site__c> temp_techHB = 
                    new Map<String, SVMXC__Service_Group_Site__c>();
                for(SVMXC__Service_Group_Site__c hb: [SELECT SVMXC__Street__c, 
                                                        SVMXC__City__c, SVMXC__State__c, 
                                                        SVMXC__Country__c,
                                                        SVMXC__Latitude__c, SVMXC__Longitude__c, 
                                                        SVMXC__Technician_Equipment__c, SVMXC__Zip__c 
                                                        from SVMXC__Service_Group_Site__c where 
                                                        SVMXC__Technician_Equipment__c IN :techMembers 
                                                        AND SVMXC__Latitude__c != NULL AND 
                                                        SVMXC__Longitude__c != NULL AND 
                                                        SVMXC__IsCurrent__c = TRUE AND 
                                                        RecordType.Name='Home Bases']){
                    temp_techHB.put(hb.SVMXC__Technician_Equipment__c, hb);
                }
                for(SVMXC__Service_Group_Members__c tech: techMembers){
                    if(temp_techHB.get(tech.id) != NULL)
                        Tech_WP = new Technician_WP(tech,temp_techHB.get(tech.id));  
                    else
                        Tech_WP = new Technician_WP(tech,null);   
                    system.debug('TEST EACH tech. '+Tech_WP);
                    techDetailsMap.put(tech.Id,Tech_WP);
                    //technician_LWP.add(Tech_WP);
                }
            }
        } else {
            COMM_Utils_V2 objCOMM_UtilV2 = new COMM_Utils_V2();
            List<String> lstTechFields = objCOMM_UtilV2.checkDuplicateFields(req.techFields, 'SVMXC__Service_Group_Members__c');
    
            querySelect = utils.SVMX_getFieldNamesFromList(lstTechFields);
            String soqlQuery = 'Select ' + querySelect + 
                                ' from SVMXC__Service_Group_Members__c where SVMXC__Active__c=true ' +
                                whereClause;
            for(SVMXC__Service_Group_Members__c tech: Database.query(soqlQuery)){
                Tech_WP = new Technician_WP(tech,null);
                techDetailsMap.put(tech.Id,Tech_WP);
            }
        }
        //return technician_LWP;   
        return techDetailsMap;    
    }

    public static Map<Id,List<techDetails>> teamTechnicians(Boolean isDispatcher, String dispatcherClause, 
                                                    String notDispatcherClause) {
        //Map<Id,List<SVMXC__Service_Group_Members__c>> teamTechIdMap = new Map<Id,List<SVMXC__Service_Group_Members__c>>();
        Map<Id,List<techDetails>> teamTechIdMap = new Map<Id,List<techDetails>>();
        String finalSOQL;
        String UserId = UserInfo.getUserId();
        String commonSoql = 'Select Id, (Select Id, Name from SVMXC__Service_Group_Members__r ORDER BY Name) from SVMXC__Service_Group__c ';
        if(isDispatcher) {
            finalSOQL = commonSoql + dispatcherClause;
        } else {
            finalSOQL = 'Select Id, (Select Id, Name from SVMXC__Service_Group_Members__r where ' + 
                        'SVMXC__Salesforce_User__c = \''+ UserId+'\'' + 
                        ' ORDER BY Name) from SVMXC__Service_Group__c';
        }
        system.debug('Final Soql = '+finalSOQL);

        for (SVMXC__Service_Group__c teamRec : Database.query(finalSOQL)) {
            List<techDetails> techInfoList = new List<techDetails>();
            techDetails techInfo = new techDetails();
            for(SVMXC__Service_Group_Members__c tech : teamRec.SVMXC__Service_Group_Members__r) {
                techInfo = new techDetails(tech.Id,tech.Name);
                techInfoList.add(techInfo);
            }
            teamTechIdMap.put(teamRec.Id,techInfoList);
            //teamTechIdMap.put(teamRec.Id, teamRec.SVMXC__Service_Group_Members__r);
        }
        return teamTechIdMap;
    }

    public static Map<Id,List<techDetails>> territoryTechnicians(Boolean isDispatcher, String dispatcherClause, 
                                                        String notDispatcherClause) {
        //Map<Id,List<SVMXC__Territory__c>> terrTechIdMap = new Map<Id,List<SVMXC__Territory__c>>();
        Map<Id,List<techDetails>> terrTechIdMap = new Map<Id,List<techDetails>>();
        String UserId = UserInfo.getUserId();
        String finalSOQL;
        String commonSoql = 'Select Id, (Select Id, Name from SVMXC__Service_Group_Members__r ORDER BY Name) from SVMXC__Territory__c ';
        if(isDispatcher) {
            finalSOQL = commonSoql + dispatcherClause;
        } else {
            finalSOQL = 'Select Id, (Select Id, Name from SVMXC__Service_Group_Members__r where ' + 
                        'SVMXC__Salesforce_User__c = \''+ UserId+'\'' +
                        ' ORDER BY Name) from SVMXC__Territory__c';
        }
        system.debug('Final Soql = '+finalSOQL);

        for (SVMXC__Territory__c terrRec : Database.query(finalSOQL)) {
            List<techDetails> techInfoList = new List<techDetails>();
            techDetails techInfo = new techDetails();
            for(SVMXC__Service_Group_Members__c tech : terrRec.SVMXC__Service_Group_Members__r) {
                techInfo = new techDetails(tech.Id,tech.Name);
                techInfoList.add(techInfo);
            }
            terrTechIdMap.put(terrRec.Id,techInfoList);
            //teamTechIdMap.put(teamRec.Id, teamRec.SVMXC__Service_Group_Members__r);
        }
        return terrTechIdMap;
    }
    
    public class techDetails{
        public String Id {get; set;}
        public String Name {get; set;}

        public techDetails(){}
        
        public techDetails(String tK, String tV){
            this.Id = tK;
            this.Name = tV;
        }
    }
    
private static Set<String> getTechFieldstoLoadDCx() {
        Set<String> setTechFields = new Set<String>();
        
        //1. Get he default tech fields to load
        setTechFields.addAll(getDefaultTechFieldstoLoad());
        
        //2. Get the configured tech fields from user settings
        DCX_CommonServiceManager.UserSetting userSettings = DCX_SettingServiceManager.fetchUserSettings();
        if(userSettings.tech_techCol != null && userSettings.tech_techCol.size() > 0) {
            for(DCX_CommonServiceManager.TechCol col : userSettings.tech_techCol)
                setTechFields.add(col.name);
        }
        
        return setTechFields;
    }

    public static Set<String> getDefaultTechFieldstoLoad()
    {
        Set<string> setDefaultTechFields = new set<string>();
                
        Set<string> setDefaultTechFieldLabels = new set<string>{'CreatedById', 'LastModifiedById','Name','SVMXC__Service_Group__c','SVMXC__Street__c','SVMXC__City__c','SVMXC__State__c','SVMXC__Country__c','SVMXC__Zip__c','SVMXC__Latitude__c','SVMXC__Longitude__c','SVMXC__Latitude_Home__c','SVMXC__Longitude_Home__c','SVMXC__Enable_Scheduling__c','SVMXC__Salesforce_User__c','SVMXC__Service_Territory__c'};
        
        
        Map<String, SObjectField> souObjfieldMap = Schema.SObjectType.SVMXC__Service_Group_Members__c.fields.getMap();
        map<String,String> mapAPINameLabel = new map<String,String>();
        
        //Loop it and create map of label and APIName for Map Hover
        if(souObjfieldMap.size() > 0)
        {
            for(String str : souObjfieldMap.keyset())
            {
                Schema.SObjectField fsObj = souObjfieldMap.get(str); 
                Schema.DescribeFieldResult field = fsObj.getDescribe();
                if(field.isAccessible())
                {                   
                    mapAPINameLabel.put(souObjfieldMap.get(str).getDescribe().getName(),souObjfieldMap.get(str).getDescribe().getName());
                }
            }
        }
        for(string str:setDefaultTechFieldLabels)
        {
            if(str != '' && str != null && mapAPINameLabel.containskey(str) && mapAPINameLabel.get(str) != null)
            setDefaultTechFields.add(mapAPINameLabel.get(str));
        }
        
        //The fields which have relationship are to be added as below (not all relationship fileds to be added, only the default required)
        if(mapAPINameLabel.containskey('SVMXC__Service_Group__c') && mapAPINameLabel.get('SVMXC__Service_Group__c') != null)
            setDefaultTechFields.add('SVMXC__Service_Group__r.Name');
        
        
        if(mapAPINameLabel.containskey('SVMXC__Service_Territory__c') && mapAPINameLabel.get('SVMXC__Service_Territory__c') != null)
            setDefaultTechFields.add('SVMXC__Service_Territory__r.Name');
    
        if(mapAPINameLabel.containskey('SVMXC__Salesforce_User__c') && mapAPINameLabel.get('SVMXC__Salesforce_User__c') != null)
            setDefaultTechFields.add('SVMXC__Salesforce_User__r.Name');
        
        System.debug(logginglevel.warn,'setDefaultTechFields: '+setDefaultTechFields);
        return setDefaultTechFields;
    }

        public class SVMX_Response{
            public list<string> WoFields{get; set;}
            public list<string> Evntfields{get; set;}
            public List<DCX_Wrapper.SVMX_StringMap> DispatcherList{get;set;} //introduced 29/08/2011 - hh - Reason:parameter needed to hold and return response dispatcher List.
            public List<SObject> RecordList{get; set;}
            public Boolean success{get; set;}
            public string message{get; set;}
            }
/*
    public class TechnicianSpecialFields_WP{
        public String key {get; set;}
        public String value {get; set;}
        public TechnicianSpecialFields_WP(String tK, String tV){
            this.key = tK;
            this.value = tV;
        }
    }
    
    public class Address{
        String street{get; set;}
        String city{get; set;}
        String state{get; set;}
        String zip{get; set;}
        String country{get; set;}
        Double latitude{get; set;}
        Double longitude{get; set;}
    }
 */
}