@isTest
public with sharing class WSCH_Provider_ECO_DataMapper_UT {
    
    
     //TEst Method for Non Work Event : To cover the methods  createManageTechnicianEventRequest, createTechnicianEventRequest,getOperationType
     static testMethod void test_ECO_NONWOEvents() {
        
        SVMXC__Territory__c testTer = createECOTerritory();
        SVMXC__ServiceMax_Processes__c testProcess = createECODispatchProcess(testTer.id);
        SVMXC__Service_Group_Members__c tectTechnician = createECOTechnician(testTer.id);
        
        String connectionId = testProcess.Id+'_'+testTer.Id+'_'+tectTechnician.Id;
        List<String> techniciands = new List<String>();
        techniciands.add(tectTechnician.id);
        
        Event sfTestEvent1 = createSFEvent(tectTechnician.id);
        Event sfTestEvent2 = createSFEvent(tectTechnician.id);
        List<Event> sfEevents = new List<Event>();
        sfEevents.add(sfTestEvent1); 
        sfEevents.add(sfTestEvent2); 
        
        Map<Id, SVMXC__Service_Order__c> mapAllEventWorkOrders = new Map<Id, SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c();
        objWorkOrder.SVMXC__OptiMax_Status__c = 'xyz';
        objWorkOrder.SVMXC__Preferred_Technician__c = tectTechnician.id;
       
        mapAllEventWorkOrders.put(objWorkOrder.Id,objWorkOrder);
        
        SVMXC__SVMX_Event__c svmxEvent1 = createSVMXECOEVENT(tectTechnician.id);
        SVMXC__SVMX_Event__c svmxEvent2 = createSVMXECOEVENT(tectTechnician.id);
        List<SVMXC__SVMX_Event__c> svmxEvents = new List<SVMXC__SVMX_Event__c>();
        svmxEvents.add(svmxEvent2);
        svmxEvents.add(svmxEvent1);
        
        SVMXC__SVMX_Optimizer__c sftestOptimizer1 = createOptimizer(sfTestEvent1.id,'CHANGE_CREATE_EVENT',connectionId);
        SVMXC__SVMX_Optimizer__c sftestOptimizer2 = createOptimizer(sfTestEvent2.id,'CHANGE_UPDATE_EVENT',connectionId);
        
        List<SVMXC__SVMX_Optimizer__c> sftestOptimizers = new List<SVMXC__SVMX_Optimizer__c>();
        sftestOptimizers.add(sftestOptimizer1);
        sftestOptimizers.add(sftestOptimizer2);
        
        SVMXC__SVMX_Optimizer__c svmxtestOptimizer1 = createOptimizer(svmxEvent1.id,'CHANGE_CREATE_EVENT',connectionId);
        SVMXC__SVMX_Optimizer__c svmxtestOptimizer2 = createOptimizer(svmxEvent2.id,'CHANGE_UPDATE_EVENT',connectionId);
        List<SVMXC__SVMX_Optimizer__c> svmxtestOptimizers = new List<SVMXC__SVMX_Optimizer__c>();
        svmxtestOptimizers.add(svmxtestOptimizer1);
        svmxtestOptimizers.add(svmxtestOptimizer2);
        
        WSCH_Provider_ECO_DataMapper.createManageTechnicianEventRequest(sftestOptimizers);
        WSCH_Provider_ECO_DataMapper.createManageTechnicianEventRequest(svmxtestOptimizers);
        
        List<SVMXC__SVMX_Optimizer__c> sfupdateOptimizers = new List<SVMXC__SVMX_Optimizer__c>();
        sftestOptimizer1.SVMXC__Optimizer_Change_Token__c = 'CHANGE_UPDATE_EVENT';
        update sftestOptimizer1;
        sfupdateOptimizers.add(sftestOptimizer1);
        WSCH_Provider_ECO_DataMapper.createManageTechnicianEventRequest(sfupdateOptimizers);
        
        
        List<SVMXC__SVMX_Optimizer__c> svupdateOptimizers = new List<SVMXC__SVMX_Optimizer__c>();
        svmxtestOptimizer1.SVMXC__Optimizer_Change_Token__c = 'CHANGE_UPDATE_EVENT';
        update svmxtestOptimizer1;
        svupdateOptimizers.add(svmxtestOptimizer1);
        WSCH_Provider_ECO_DataMapper.createManageTechnicianEventRequest(svupdateOptimizers);
        
        
        List<SVMXC__SVMX_Optimizer__c> sfdeleteOptimizers = new List<SVMXC__SVMX_Optimizer__c>();
        sftestOptimizer1.SVMXC__Optimizer_Change_Token__c = 'CHANGE_DELETE_EVENT';
        update sftestOptimizer1;
        sfdeleteOptimizers.add(sftestOptimizer1);
        WSCH_Provider_ECO_DataMapper.createManageTechnicianEventRequest(sfdeleteOptimizers);
        
        
        List<SVMXC__SVMX_Optimizer__c> svdeleteOptimizers = new List<SVMXC__SVMX_Optimizer__c>();
        svmxtestOptimizer1.SVMXC__Optimizer_Change_Token__c = 'CHANGE_DELETE_EVENT';
        update svmxtestOptimizer1;
        svdeleteOptimizers.add(svmxtestOptimizer1);
        WSCH_Provider_ECO_DataMapper.createManageTechnicianEventRequest(svdeleteOptimizers);
        
     }
     
    
    private static SVMXC__SVMX_Optimizer__c createOptimizer(String eventId,String changeToken,String conId){
        SVMXC__SVMX_Optimizer__c obj = new SVMXC__SVMX_Optimizer__c();
        obj.SVMXC__WhatType__c = changeToken;
        obj.SVMXC__WhatId__c = eventId;
        obj.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CREATE_EVENT' ;
        obj.SVMXC__Optimizer_Connection_ID__c=conId;
        insert obj;
        return obj;
     }
     
  //private supporting methods
    private static Event createSFEvent(String techId){
        Event ev = new Event();
        ev.EventSubtype  = 'Event';
        ev.StartDateTime = system.today();
        ev.EndDateTime = system.today() + 1;
        ev.SVMXC__Driving_Time__c = 60;
        ev.SVMXC__Driving_Time_Home__c = 30;
        ev.WhatId = techId;
        insert ev;
        return ev;
    }
    
    private  static SVMXC__SVMX_Event__c createSVMXECOEVENT(String technician){
        SVMXC__SVMX_Event__c svmxEv = new SVMXC__SVMX_Event__c();
        svmxEv.Name = 'EVMX_EV_UT';
        svmxEv.SVMXC__Technician__c =  technician;
        svmxEv.SVMXC__StartDateTime__c= system.today();
        svmxEv.SVMXC__EndDateTime__c = system.today() + 1;
        svmxEv.SVMXC__Driving_Time__c = 60;
        svmxEv.SVMXC__Driving_Time_Home__c = 30;
         insert svmxEv;
         return svmxEv;
    }
    
    private static SVMXC__Service_Group_Members__c createECOTechnician(String terId){
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'ECO_Tech_UT';
        technician.SVMXC__City__c = 'Bangalore';
        technician.SVMXC__Country__c = 'India';
        technician.SVMXC__Zip__c = '560030';
        technician.SVMXC__Service_Territory__c = terId;
        technician.SVMXC__Service_Group__c= createServiceGroupId();
        BusinessHours[] bh = [Select Id from BusinessHours where IsActive=true];
        if (bh.size() > 0)
            technician.SVMXC__Working_Hours__c = bh[0].Id;
        insert technician;
        return technician;
        
    }
    
    private static String createServiceGroupId(){
     SVMXC__Service_Group__c segroup = new SVMXC__Service_Group__c();
     segroup.Name = 'TestGroup-UT';
     insert segroup;
     return segroup.id;
    }
    
    private static SVMXC__Territory__c createECOTerritory(){
        SVMXC__Territory__c ecoTeritory = new SVMXC__Territory__c();
         ecoTeritory.Name = 'Ter-UT';
         BusinessHours[] bh = [Select Id from BusinessHours where IsActive=true];
         if (bh.size() > 0)
            ecoTeritory.SVMXC__Territory_s_Business_Hours__c = bh[0].Id;
         insert ecoTeritory;
         return ecoTeritory;
    }
    
    private static SVMXC__ServiceMax_Processes__c createECODispatchProcess(String terId){
        SVMXC__ServiceMax_Processes__c dprocess = new SVMXC__ServiceMax_Processes__c();
        dprocess.SVMXC__Dispatch_Method__c = 'Real Time Optimization';
        dprocess.SVMXC__Dispatch_Process_Status__c ='Complete';
        dprocess.SVMXC__Dispatch_Timezone__c= 'Asia/Colombo';
        dprocess.SVMXC__Name__c = 'Process-UT';
        dprocess.SVMXC__Calendar_Start_Days__c = 2; 
        dprocess.SVMXC__Calendar_End_Days__c = 4; 
        dprocess.SVMXC__Frequency__c = 2; 
        dprocess.SVMXC__Full_Run_Unit__c = 'DAYS';
        dprocess.RecordTypeId = getDispatchProcessRecordId();
        dprocess.SVMXC__Territory__c = terId;
        
        insert dprocess;
        return dprocess;
    }
    
    
    private static String getDispatchProcessRecordId(){
        String dispatchProcessRecordType;
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' ];
        for(RecordType rt : rts)
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               dispatchProcessRecordType = rt.ID;
        }
        return dispatchProcessRecordType;
        
    }
    
    static testMethod void testSetTechParams() {
        
        list<BusinessHours> lBH = [ select WednesdayStartTime, timeZoneSidKey, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where IsActive = true limit 2];
        
        SVMXC__Territory__c objTerritory = new SVMXC__Territory__c();
        objTerritory.Name = 'TestTerritory';
        insert objTerritory;
        
        SVMXC__Service_Group__c objGroup = new SVMXC__Service_Group__c();
        objGroup.Name = 'TestGroup';
        objGroup.SVMXC__Active__c = true;
        objGroup.SVMXC__Select__c = true;
        insert objGroup;
        
        SVMXC__Service_Group_Members__c objTechnician = new SVMXC__Service_Group_Members__c();
        objTechnician.Name = 'TestTechnician';
        objTechnician.SVMXC__Service_Group__c = objGroup.id;
        objTechnician.SVMXC__Active__c = true;
        objTechnician.SVMXC__City__c = 'Bangalore';
        objTechnician.SVMXC__Service_Territory__c = objTerritory.id;
        objTechnician.SVMXC__Working_Hours__c = lBH[0].id;
        objTechnician.SVMXC__Per_Mile_Cost__c = 10;
        objTechnician.SVMXC__Max_Distance__c = 10;
        objTechnician.SVMXC__Average_Speed__c = 10;
        objTechnician.SVMXC__Fixed_Cost__c = 10;
        objTechnician.SVMXC__Per_hour_Cost__c = 10;
        insert objTechnician;
        
        WSCH_Provider_ECO_DataMapper.isMile = true;
        WSCH_Provider_ECO_DataMapper.dclDefaultPerKmCost = 10;
        WSCH_Provider_ECO_DataMapper.dclDefaultMaxDistance = 10;
        WSCH_Provider_ECO_DataMapper.dclDefaultAverageSpeed = 10;
        WSCH_Provider_ECO_DataMapper.dclDefaultPerKmCost = 10;
        WSCH_Provider_ECO_DataMapper.dclDefaultMaxDistance = 10;
        WSCH_Provider_ECO_DataMapper.dclDefaultAverageSpeed = 10;
        WSCH_Provider_ECO_DataMapper.dclDefaultFixedCost = 10;
        WSCH_Provider_ECO_DataMapper.dclDefaultPerHourCost = 10;
        
        WSCH_Provider_ECO_DataMapper.setTechnicianParams(objTechnician);
        
        SVMXC__Service_Group_Members__c objTechnician1 = new SVMXC__Service_Group_Members__c();
        objTechnician1.Name = 'TestTechnician';
        objTechnician1.SVMXC__Service_Group__c = objGroup.id;
        objTechnician1.SVMXC__Active__c = true;
        objTechnician1.SVMXC__City__c = 'Bangalore';
        objTechnician1.SVMXC__Service_Territory__c = objTerritory.id;
        objTechnician1.SVMXC__Working_Hours__c = lBH[0].id;
        objTechnician1.SVMXC__Per_Mile_Cost__c = null;
        objTechnician1.SVMXC__Max_Distance__c = null;
        objTechnician1.SVMXC__Average_Speed__c = null;
        objTechnician1.SVMXC__Fixed_Cost__c = 10;
        objTechnician1.SVMXC__Per_hour_Cost__c = 10;
        insert objTechnician1;
        
        WSCH_Provider_ECO_DataMapper.setTechnicianParams(objTechnician1);
        
        WSCH_Provider_ECO_DataMapper.isMile = false;
        SVMXC__Service_Group_Members__c objTechnician2 = new SVMXC__Service_Group_Members__c();
        objTechnician2.Name = 'TestTechnician';
        objTechnician2.SVMXC__Service_Group__c = objGroup.id;
        objTechnician2.SVMXC__Active__c = true;
        objTechnician2.SVMXC__City__c = 'Bangalore';
        objTechnician2.SVMXC__Service_Territory__c = objTerritory.id;
        objTechnician2.SVMXC__Working_Hours__c = lBH[0].id;
        objTechnician2.SVMXC__Per_Mile_Cost__c = null;
        objTechnician2.SVMXC__Max_Distance__c = null;
        objTechnician2.SVMXC__Average_Speed__c = 10;
        objTechnician2.SVMXC__Fixed_Cost__c = null;
        objTechnician2.SVMXC__Per_hour_Cost__c = null;
        insert objTechnician2;
        
        WSCH_Provider_ECO_DataMapper.setTechnicianParams(objTechnician2);
    }
    
    static testMethod void testDoBuildTechnicianTimeWindows() {
        Integer noOfCalDays = 3;
        SVMXC__Territory__c ecoTer = createECOTerritory();
        SVMXC__ServiceMax_Processes__c ecoDP = createECODispatchProcess(ecoTer.id);
        ecoDP.SVMXC__Calendar_Start_Days__c = 2;
        ecoDP.SVMXC__Calendar_End_Days__c = 4;
        ecoDP.SVMXC__Full_Run_Unit__c = 'DAYS';
        upsert ecoDP;

        WSCH_Provider_ECO_DataMapper.initializeBussHr(ecoTer);
        WSCH_Provider_ECO_DataMapper.setHorizonDates(ecoTer, ecoDP.id);
        
        List<SVMXC__Service_Group_Members__c> lstTechnicians = new List<SVMXC__Service_Group_Members__c>();
        SVMXC__Service_Group_Members__c tech1 = createECOTechnician(ecoTer.id);
        lstTechnicians.add(tech1);
        
        WSCH_Provider_ECO_DataMapper.objDefTerritoryBH = WSCH_Provider_ECO_DataMapper.mapBusinessHours.get(ecoTer.SVMXC__Territory_s_Business_Hours__c);
        
        String dpID = ecoDP.id;
        
        String connId = ecoDP.Id+'_' + ecoTer.Id + '_' + tech1.Id;
        SVMXC__SVMX_Event__c svmxEvent1 = createSVMXECOEVENT(tech1.id);
        svmxEvent1.SVMXC__StartDateTime__c = WSCH_Provider_ECO_DataMapper.dtmSchedulingHorizonStartDateTime;
        svmxEvent1.SVMXC__EndDateTime__c = WSCH_Provider_ECO_DataMapper.dtmSchedulingHorizonStartDateTime + 1;
        upsert svmxEvent1;
        SVMXC__SVMX_Event__c svmxEvent2 = createSVMXECOEVENT(tech1.id);
        svmxEvent2.SVMXC__StartDateTime__c = WSCH_Provider_ECO_DataMapper.dtmSchedulingHorizonStartDateTime;
        svmxEvent2.SVMXC__EndDateTime__c = WSCH_Provider_ECO_DataMapper.dtmSchedulingHorizonStartDateTime + 1;
        upsert svmxEvent2;
        SVMXC__SVMX_Optimizer__c svmxtestOptimizer1 = createOptimizer(svmxEvent1.id,'CHANGE_CREATE_EVENT',connId);
        SVMXC__SVMX_Optimizer__c svmxtestOptimizer2 = createOptimizer(svmxEvent2.id,'CHANGE_UPDATE_EVENT',connId);
        
        Date dt1 = Date.today();
        Set<Date> setOfHorizonDates = new Set<Date>();
        setOfHorizonDates.add(dt1);
        setOfHorizonDates.add(dt1 + 1);
        setOfHorizonDates.add(dt1 + 2);
        
        //WSCH_Provider_ECO_DataMapper.doBuildTechnicianTimeWindows(noOfCalDays, WSCH_Provider_ECO_DataMapper.mapBusinessHours, lstTechnicians, WSCH_Provider_ECO_DataMapper.objDefTerritoryBH, dpID);
        WSCH_Provider_ECO_DataMapper.getTechnicianTimeWindows(noOfCalDays, WSCH_Provider_ECO_DataMapper.mapBusinessHours, lstTechnicians, setOfHorizonDates);

    }
    
    static testMethod void testManageTechnicianRequest() {
        
        list<BusinessHours> lBH = [ select WednesdayStartTime, timeZoneSidKey, WednesdayEndTime, TuesdayStartTime, 
        TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, 
        SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime
         from BusinessHours where IsActive = true limit 1];
        
        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.SVMXC__Active__c = true;
        territory.SVMXC__Territory_s_Business_Hours__c = lBH[0].Id;
        territory.SVMXC__Per_Mile_Cost__c = 1234;
        territory.SVMXC__Max_Distance__c = 2345;
        territory.SVMXC__Average_Speed__c = 4567;
        territory.SVMXC__Fixed_Cost__c = 4366;
        territory.SVMXC__Per_hour_Cost__c = 7373;
        insert territory;
        
        WSCH_Provider_ECO_DataMapper.mapSettingValues = new Map<String, String>();
        WSCH_Provider_ECO_DataMapper.mapSettingValues.put('GLOB001_GBL006', 'MILE');
        
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'ECO_Tech_UT';
        technician.SVMXC__City__c = 'Bangalore';
        technician.SVMXC__Country__c = 'India';
        technician.SVMXC__Zip__c = '560030';
        technician.SVMXC__Service_Territory__c = territory.Id;
        technician.SVMXC__Service_Group__c= createServiceGroupId();
        insert technician;
        
        List<SVMXC__Service_Group_Members__c> lstTech = new List<SVMXC__Service_Group_Members__c>();
        lstTech.add(technician);
        
        SVMXC__SVMX_Optimizer__c svmxOptTrans1 = new SVMXC__SVMX_Optimizer__c();
        //svmxOptTrans1.Name = 'optTrans1';
        svmxOptTrans1.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CREATE_TECH';
        svmxOptTrans1.SVMXC__WhatId__c = technician.id;
        insert svmxOptTrans1;
        
        Map<String, SVMXC__SVMX_Optimizer__c> mapTechIdOptimizerObj = new Map<String, SVMXC__SVMX_Optimizer__c>();
        mapTechIdOptimizerObj.put(technician.Id+'_'+technician.Name, svmxOptTrans1);
        
        SVMXC__ServiceMax_Processes__c dprocessParent = new SVMXC__ServiceMax_Processes__c();
        dprocessParent.SVMXC__Dispatch_Method__c = 'Real Time Optimization';
        dprocessParent.SVMXC__Dispatch_Process_Status__c ='Complete';
        dprocessParent.SVMXC__Dispatch_Timezone__c= 'Asia/Colombo';
        dprocessParent.SVMXC__Name__c = 'Process-UT';
        dprocessParent.RecordTypeId = getDispatchProcessRecordId();
        dprocessParent.SVMXC__End_Date__c = Date.today();
        dprocessParent.SVMXC__Calendar_End_Days__c = 4;
        dprocessParent.SVMXC__Full_Run_Unit__c = 'DAYS';
        dprocessParent.SVMXC__Calendar_Start_Days__c = 2;
        dprocessParent.SVMXC__Frequency__c = 2;
        insert dprocessParent;
        
        SVMXC__SVMX_Jobs__c svmxJob = new SVMXC__SVMX_Jobs__c();
        svmxJob.SVMXC__Territory__c = territory.Id;
        svmxJob.SVMXC__Type__c = 'ECO';
        svmxJob.SVMXC__SVMX_Process__c = dprocessParent.Id;
        insert svmxJob;
        
        WSCH_ECO_Constants ecoConstants = new WSCH_ECO_Constants();
        
        WSCH_Provider_ECO_DataMapper.manageTechnicianRequest(territory, lstTech, mapTechIdOptimizerObj, dprocessParent.Id);
    }  
    
    static testMethod void testUpdateExecutionTime() {
        
        DateTime dtmBusinessHourStartDateTime = Datetime.now();
        DateTime dtmBusinessHourEndDateTime = dtmBusinessHourStartDateTime.addHours(5);
        DateTime dtmBreakHourStartDateTime = dtmBusinessHourStartDateTime.addHours(2);
        DateTime dtmBreakHourEndDateTime = dtmBusinessHourStartDateTime.addHours(3);
        
        list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstEventTimeWindows = new list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
        WSCH_Provider_ECO_Stubs.ExecutionTime_WP wrpTempAvailableWindow = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP(dtmBusinessHourStartDateTime, dtmBusinessHourEndDateTime);
        lstEventTimeWindows.add(wrpTempAvailableWindow);
        
        WSCH_Provider_ECO_Stubs.ExecutionTime_WP ex_T1 = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP(dtmBreakHourStartDateTime, dtmBreakHourEndDateTime);
        list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstEventTimeWindows1 = new list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
        lstEventTimeWindows1.add(ex_T1);
        
        WSCH_Provider_ECO_DataMapper.updateExecutionTime(lstEventTimeWindows, lstEventTimeWindows1);
    }
    
    static testMethod void testGetWorkOrdersDetails() {
        
        list<BusinessHours> lBH = [ select WednesdayStartTime, timeZoneSidKey, WednesdayEndTime, TuesdayStartTime, 
        TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, 
        SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime
         from BusinessHours where IsActive = true limit 1];
        
        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.SVMXC__Active__c = true;
        territory.SVMXC__Territory_s_Business_Hours__c = lBH[0].Id;
        territory.SVMXC__Per_Mile_Cost__c = 1234;
        territory.SVMXC__Max_Distance__c = 2345;
        territory.SVMXC__Average_Speed__c = 4567;
        territory.SVMXC__Fixed_Cost__c = 4366;
        territory.SVMXC__Per_hour_Cost__c = 7373;
        insert territory;
        
        WSCH_Provider_ECO_DataMapper.initializeBussHr(territory);
        
        String svmxRuleRecordType;
        RecordType[] rtRule = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' ];
        for(RecordType rt : rtRule)
        {
            if(rt.Name == 'SVMX Rule' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               svmxRuleRecordType = rt.ID;
        }
        
        SVMXC__ServiceMax_Processes__c dprocessParent = new SVMXC__ServiceMax_Processes__c();
        dprocessParent.SVMXC__Dispatch_Method__c = 'Real Time Optimization';
        dprocessParent.SVMXC__Dispatch_Process_Status__c ='Complete';
        dprocessParent.SVMXC__Dispatch_Timezone__c= 'Asia/Colombo';
        dprocessParent.SVMXC__Name__c = 'Process-UT';
        dprocessParent.RecordTypeId = getDispatchProcessRecordId();
        dprocessParent.SVMXC__End_Date__c = Date.today();
        dprocessParent.SVMXC__Calendar_End_Days__c = 4;
        dprocessParent.SVMXC__Full_Run_Unit__c = 'DAYS';
        dprocessParent.SVMXC__Calendar_Start_Days__c = 2;
        dprocessParent.SVMXC__Frequency__c = 2;
        insert dprocessParent;
        
        SVMXC__ServiceMax_Processes__c dprocess = new SVMXC__ServiceMax_Processes__c();
        dprocess.SVMXC__Process__c = dprocessParent.Id;
        dprocess.SVMXC__Rule_Type__c = 'Territory Access';
        dprocess.SVMXC__Territory__c = territory.Id;
        dprocess.RecordTypeId = svmxRuleRecordType;
        insert dprocess;
        
        SVMXC__SVMX_Jobs__c objSVMXJob = new SVMXC__SVMX_Jobs__c();
        objSVMXJob.SVMXC__SVMX_Process__c = dprocessParent.id;
        objSVMXJob.SVMXC__Territory__c = territory.Id;
        objSVMXJob.SVMXC__OptiMax_Message__c = 'Running';
        objSVMXJob.SVMXC__Start_Time__c = system.now();
        objSVMXJob.SVMXC__Initiated_By__c = Userinfo.getUserId();
        objSVMXJob.SVMXC__Status__c = '100';
        objSVMXJob.SVMXC__Type__c = 'ECO';   
        
        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        workOrder1.SVMXC__Service_Duration__c = 3600;
        workOrder1.SVMXC__Zip__c = '560022';
        workOrder1.SVMXC__Primary_Territory__c = territory.Id;
        workOrder1.SVMXC__Dispatch_Process__c = dprocessParent.Id;
        workOrder1.SVMXC__Preferred_Business_Hours__c = lBH[0].Id;
        workOrder1.SVMXC__Preferred_Start_Time__c = Datetime.now();
        workOrder1.SVMXC__Preferred_End_Time__c = Datetime.now() + 1;
        workOrder1.SVMXC__Apply_Business_Hours_For_OptiMax__c = true;
        
        List<SVMXC__Service_Order__c> lstWorkOrderObj = new List<SVMXC__Service_Order__c>();
        lstWorkOrderObj.add(workOrder1);
        insert lstWorkOrderObj;
        
        WSCH_Provider_ECO_DataMapper.getWorkOrdersDetails(territory, lstWorkOrderObj,dprocessParent.Id);
        
        SVMXC__Service_Order__c workOrder11 = new SVMXC__Service_Order__c();
        workOrder11.SVMXC__Service_Duration__c = 3600;
        workOrder11.SVMXC__Zip__c = '560022';
        workOrder11.SVMXC__Primary_Territory__c = territory.Id;
        workOrder11.SVMXC__Dispatch_Process__c = dprocessParent.Id;
        workOrder11.SVMXC__Preferred_Business_Hours__c = null;
        workOrder11.SVMXC__Preferred_Start_Time__c = Datetime.now();
        workOrder11.SVMXC__Preferred_End_Time__c = Datetime.now() + 1;
        workOrder11.SVMXC__Apply_Business_Hours_For_OptiMax__c = true;
        
        List<SVMXC__Service_Order__c> lstWorkOrderObj11 = new List<SVMXC__Service_Order__c>();
        lstWorkOrderObj11.add(workOrder11);
        insert lstWorkOrderObj11;
        
        WSCH_Provider_ECO_DataMapper.getWorkOrdersDetails(territory, lstWorkOrderObj11,dprocessParent.Id);
        
        Datetime dt1 = Datetime.now();
        WSCH_Provider_ECO_DataMapper.dtmSchedulingHorizonStartDateTime = dt1 + 2;
        
        SVMXC__Service_Order__c workOrder2 = new SVMXC__Service_Order__c();
        workOrder2.SVMXC__Service_Duration__c = 3600;
        workOrder2.SVMXC__Zip__c = '560022';
        workOrder2.SVMXC__Primary_Territory__c = territory.Id;
        workOrder2.SVMXC__Dispatch_Process__c = dprocessParent.Id;
        workOrder2.SVMXC__Preferred_Business_Hours__c = lBH[0].Id;
        workOrder2.SVMXC__Preferred_Start_Time__c = dt1;
        workOrder2.SVMXC__Preferred_End_Time__c = dt1 + 3;
        workOrder2.SVMXC__Apply_Business_Hours_For_OptiMax__c = false;
        
        List<SVMXC__Service_Order__c> lstWorkOrderObj2 = new List<SVMXC__Service_Order__c>();
        lstWorkOrderObj2.add(workOrder2);
        insert lstWorkOrderObj2;
        
        WSCH_Provider_ECO_DataMapper.getWorkOrdersDetails(territory, lstWorkOrderObj2,dprocessParent.Id);
        
        SVMXC__Service_Order__c workOrder3 = new SVMXC__Service_Order__c();
        workOrder3.SVMXC__Service_Duration__c = 3600;
        workOrder3.SVMXC__Zip__c = '560022';
        workOrder3.SVMXC__Primary_Territory__c = territory.Id;
        workOrder3.SVMXC__Dispatch_Process__c = dprocessParent.Id;
        workOrder3.SVMXC__Preferred_Business_Hours__c = null;
        workOrder3.SVMXC__Preferred_Start_Time__c = dt1;
        workOrder3.SVMXC__Preferred_End_Time__c = dt1 + 3;
        workOrder3.SVMXC__Apply_Business_Hours_For_OptiMax__c = true;
        
        List<SVMXC__Service_Order__c> lstWorkOrderObj3 = new List<SVMXC__Service_Order__c>();
        lstWorkOrderObj3.add(workOrder3);
        insert lstWorkOrderObj3;
        
        WSCH_Provider_ECO_DataMapper.getWorkOrdersDetails(territory, lstWorkOrderObj3,dprocessParent.Id);
    }
    
    static testMethod void testSortExecutionTime() {
        
        List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstInputTimeWindows = new List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
        
        WSCH_Provider_ECO_Stubs.ExecutionTime_WP execTimeWP = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP();
        execTimeWP.setworkingHoursBegin(datetime.now());
        lstInputTimeWindows.add(execTimeWP);
        
        WSCH_Provider_ECO_DataMapper.sortExecutionTime(lstInputTimeWindows);
    }
    
    static testMethod void testTechAvailabilityWindow() {
    
        Map<id, Map<date, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>> mapTechAvail = new Map<id, Map<date, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>>();
        DateTime dtmBusinessHourStartDateTime = Datetime.now();
        DateTime dtmBreakHourStartDateTime = dtmBusinessHourStartDateTime.addHours(2);
        DateTime dtmBreakHourEndDateTime = dtmBusinessHourStartDateTime.addHours(3);
        
        WSCH_Provider_ECO_Stubs.ExecutionTime_WP ex_T1 = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP(dtmBreakHourStartDateTime, dtmBreakHourEndDateTime);
        list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstEventTimeWindows1 = new list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
        lstEventTimeWindows1.add(ex_T1);
        
        Date tody = Date.newinstance(2016, 12, 8); 
        Map<date, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>> eventWindow = new Map<date, list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>>();
        eventWindow.put(tody, lstEventTimeWindows1);
        
        list<BusinessHours> lBH = [ select WednesdayStartTime, timeZoneSidKey, WednesdayEndTime, TuesdayStartTime, 
        TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, 
        SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime
        from BusinessHours where IsActive = true limit 1];
        
        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.SVMXC__Active__c = true;
        territory.SVMXC__Territory_s_Business_Hours__c = lBH[0].Id;
        territory.SVMXC__Per_Mile_Cost__c = 1234;
        territory.SVMXC__Max_Distance__c = 2345;
        territory.SVMXC__Average_Speed__c = 4567;
        territory.SVMXC__Fixed_Cost__c = 4366;
        territory.SVMXC__Per_hour_Cost__c = 7373;
        insert territory;
        
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'ECO_Tech_UT';
        technician.SVMXC__City__c = 'Bangalore';
        technician.SVMXC__Country__c = 'India';
        technician.SVMXC__Zip__c = '560030';
        technician.SVMXC__Service_Territory__c = territory.Id;
        technician.SVMXC__Service_Group__c= createServiceGroupId();
        insert technician;
        
        mapTechAvail.put(technician.id, eventWindow);
        
        set<Date> setCurrentSchedHorizonDates = new set<Date>();
        setCurrentSchedHorizonDates.add(tody.addDays(2));

        List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstMultiday = new List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
        WSCH_Provider_ECO_Stubs.ExecutionTime_WP execTimeWP = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP();
        execTimeWP.setWorkingHoursBegin(Datetime.now());
        execTimeWP.setWorkingHoursEnd(Datetime.now() + 1);
        lstMultiday.add(execTimeWP);
        //WSCH_Provider_ECO_DataMapper.techAvailabilityWindow(mapTechAvail, technician.id, lBH[0], lBH[0], lstEventTimeWindows1, setCurrentSchedHorizonDates);
        WSCH_Provider_ECO_DataMapper.getTechAvailabilityWindow(mapTechAvail, technician.id, lBH[0], lBH[0], setCurrentSchedHorizonDates,lstMultiday);

    }
    
    static testMethod void testGetOperationType() {
        
        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        workOrder1.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CREATE_WO';
        insert workOrder1;
        WSCH_Provider_ECO_DataMapper.getOperationType(workOrder1);
        
        SVMXC__Service_Order__c workOrder2 = new SVMXC__Service_Order__c();
        workOrder2.SVMXC__Scheduling_Change_Token__c = 'CHANGE_ZIP_CODE';
        insert workOrder2;
        WSCH_Provider_ECO_DataMapper.getOperationType(workOrder2);
        
        SVMXC__Service_Order__c workOrder3 = new SVMXC__Service_Order__c();
        workOrder3.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CANCEL_WO';
        insert workOrder3;
        WSCH_Provider_ECO_DataMapper.getOperationType(workOrder3);
        
        
        SVMXC__SVMX_Optimizer__c optimizer1 = new SVMXC__SVMX_Optimizer__c();
        optimizer1.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CREATE_TECH';
        insert optimizer1;
        WSCH_Provider_ECO_DataMapper.getOperationType(optimizer1);
        
        SVMXC__SVMX_Optimizer__c optimizer2 = new SVMXC__SVMX_Optimizer__c();
        optimizer2.SVMXC__Optimizer_Change_Token__c = 'CHANGE_UPDATE_TECH';
        insert optimizer2;
        WSCH_Provider_ECO_DataMapper.getOperationType(optimizer2);
        
        SVMXC__SVMX_Optimizer__c optimizer3 = new SVMXC__SVMX_Optimizer__c();
        optimizer3.SVMXC__Optimizer_Change_Token__c = 'CHANGE_REMOVE_TECH';
        insert optimizer3;
        WSCH_Provider_ECO_DataMapper.getOperationType(optimizer3);
    }
    
    static testMethod void testGetLocation_WP() {
        SVMXC__Territory__c ecoTer = createECOTerritory();
        SVMXC__Service_Group_Members__c tech1 = createECOTechnician(ecoTer.id);
        
        DateTime dt = system.now();
        
        Map<datetime, WSCH_Provider_ECO_Stubs.Location_WP> techLatLng = new Map<datetime, WSCH_Provider_ECO_Stubs.Location_WP>();
        WSCH_Provider_ECO_Stubs.Location_WP loc = new WSCH_Provider_ECO_Stubs.Location_WP();
        loc.latitude = Double.valueOf('12.944150');
        loc.longitude = Double.valueOf('77.607623');
        techLatLng.put(dt, loc);
        WSCH_Provider_ECO_DataMapper.mapTechLatitudeLongitude.put(tech1.id, techLatLng);
        
        WSCH_Provider_ECO_DataMapper.getLocation_WP(tech1.id, dt, dt, loc.latitude, loc.longitude);
    }
    
     static testMethod void testsetDefaultParameter() {
        WSCH_Provider_ECO_DataMapper.mapSettingValues = new Map<String, String>();
        WSCH_Provider_ECO_DataMapper.mapSettingValues.put('GLOB001_GBL006', 'MILE');
        
        list<BusinessHours> lBH = [ select WednesdayStartTime, timeZoneSidKey, WednesdayEndTime, TuesdayStartTime, 
        TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, 
        SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime
        from BusinessHours where IsActive = true limit 1];
        
        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.SVMXC__Active__c = true;
        territory.SVMXC__Territory_s_Business_Hours__c = lBH[0].Id;
        territory.SVMXC__Per_Mile_Cost__c = 1234;
        territory.SVMXC__Max_Distance__c = 2345;
        territory.SVMXC__Average_Speed__c = 4567;
        territory.SVMXC__Fixed_Cost__c = 4366;
        territory.SVMXC__Per_hour_Cost__c = 7373;
        insert territory;
        
        WSCH_Provider_ECO_DataMapper.setDefaultParameter(territory);
        
        WSCH_Provider_ECO_DataMapper.mapSettingValues.put('GLOB001_GBL006', 'KILOMETER');
        WSCH_Provider_ECO_DataMapper.setDefaultParameter(territory);
        
        SVMXC__Territory__c territory1 = new SVMXC__Territory__c();
        territory1.SVMXC__Active__c = true;
        territory1.SVMXC__Territory_s_Business_Hours__c = lBH[0].Id;
        insert territory1;
        WSCH_Provider_ECO_DataMapper.mapSettingValues.put('OMAX002_SET005', '1234');
        WSCH_Provider_ECO_DataMapper.mapSettingValues.put('OMAX002_SET006', '3456');
        WSCH_Provider_ECO_DataMapper.mapSettingValues.put('OMAX002_SET007', '5454');
        WSCH_Provider_ECO_DataMapper.mapSettingValues.put('OMAX002_SET008', '6677');
        WSCH_Provider_ECO_DataMapper.mapSettingValues.put('OMAX002_SET009', '5454');
        WSCH_Provider_ECO_DataMapper.setDefaultParameter(territory1);
        
        WSCH_Provider_ECO_DataMapper.mapSettingValues.put('GLOB001_GBL006', 'MILE');
        WSCH_Provider_ECO_DataMapper.setDefaultParameter(territory1);
        
    }
    
    static testMethod void testRemoveOngoingActivityFromAvailability() {
        
        SVMXC__Territory__c ecoTer = createECOTerritory();
        SVMXC__Service_Group_Members__c tech1 = createECOTechnician(ecoTer.Id);
        
        Id techId = tech1.Id;
        
        WSCH_Provider_ECO_Stubs.ExecutionTime_WP execTimeWP = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP();
        execTimeWP.setWorkingHoursBegin(Datetime.now());
        execTimeWP.setWorkingHoursEnd(Datetime.now() + 1);
        
        WSCH_Provider_ECO_DataMapper.mapTechniciansOngoingActivity = new map<Id, WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
        WSCH_Provider_ECO_DataMapper.mapTechniciansOngoingActivity.put(techId, execTimeWP);
        
        list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstOfExecTimeWindow = new list<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
        lstOfExecTimeWindow.add(execTimeWP);
        
        Integer leadTime = 30;
        
        WSCH_Provider_ECO_DataMapper.removeOngoingActivityFromAvailability(techId, lstOfExecTimeWindow, leadTime);
        
        SVMXC__Service_Group_Members__c tech2 = createECOTechnician(ecoTer.Id);
        
        WSCH_Provider_ECO_DataMapper.removeOngoingActivityFromAvailability(tech2.Id, lstOfExecTimeWindow, leadTime);
        
    }
    
    static testMethod void testgetParameters() {
    
        WSCH_Provider_ECO_DataMapper.mapSettingValues = new Map<String, String>();
        WSCH_Provider_ECO_DataMapper.mapSettingValues.put('OMAX001_SET011', 'True');
        WSCH_Provider_ECO_DataMapper.mapSettingValues.put('OMAX001_SET001', 'True');
        WSCH_Provider_ECO_DataMapper.mapSettingValues.put('OMAX001_SET002', 'MULTIDEPOT_MIXEDFLEET');
        WSCH_Provider_ECO_DataMapper.mapSettingValues.put('OMAX001_SET003', 'DAILY');
        WSCH_Provider_ECO_DataMapper.mapSettingValues.put('OMAX001_SET005', '1000');
        WSCH_Provider_ECO_DataMapper.mapSettingValues.put('OMAX001_SET006', '500');
        WSCH_Provider_ECO_DataMapper.mapSettingValues.put('OMAX001_SET004', 'JOptCostConvergency');
        WSCH_Provider_ECO_DataMapper.mapSettingValues.put('OMAX001_SET007', '20000');
        WSCH_Provider_ECO_DataMapper.mapSettingValues.put('OMAX001_SET008', '1');
        WSCH_Provider_ECO_DataMapper.mapSettingValues.put('OMAX001_SET009', '1');
        WSCH_Provider_ECO_DataMapper.mapSettingValues.put('OMAX001_SET013', '1000');
        WSCH_Provider_ECO_DataMapper.mapSettingValues.put('OMAX001_SET012', 'test@servicemax.com');
        WSCH_Provider_ECO_DataMapper.mapSettingValues.put('OMAX001_SET017', 'Cache');
        WSCH_Provider_ECO_DataMapper.mapSettingValues.put('OMAX003_SET037', '1');
        WSCH_Provider_ECO_DataMapper.mapSettingValues.put('OMAX003_SET038', '1');
        WSCH_Provider_ECO_DataMapper.mapSettingValues.put('OMAX003_SET039', '1');
        WSCH_Provider_ECO_DataMapper.mapSettingValues.put('OMAX003_SET040', '1');
        WSCH_Provider_ECO_DataMapper.mapSettingValues.put('OMAX003_SET041', '1');
        
        list<BusinessHours> lBH = [ select WednesdayStartTime, timeZoneSidKey, WednesdayEndTime, TuesdayStartTime, 
        TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, 
        SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime
        from BusinessHours where IsActive = true limit 1];
        
        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.SVMXC__Active__c = true;
        territory.SVMXC__Territory_s_Business_Hours__c = lBH[0].Id;
        insert territory;
        
        SVMXC__ServiceMax_Processes__c dprocessParent = new SVMXC__ServiceMax_Processes__c();
        dprocessParent.SVMXC__Dispatch_Method__c = 'Real Time Optimization';
        dprocessParent.SVMXC__Dispatch_Process_Status__c ='Complete';
        dprocessParent.SVMXC__Dispatch_Timezone__c= 'Asia/Colombo';
        dprocessParent.SVMXC__Name__c = 'Process-UT';
        dprocessParent.RecordTypeId = getDispatchProcessRecordId();
        dprocessParent.SVMXC__End_Date__c = Date.today();
        dprocessParent.SVMXC__Calendar_End_Days__c = 4;
        dprocessParent.SVMXC__Full_Run_Unit__c = 'DAYS';
        dprocessParent.SVMXC__Calendar_Start_Days__c = 2;        
        dprocessParent.SVMXC__Route_Type__c = 'CLOSED';
        dprocessParent.SVMXC__Weight_Time_Window__c = 10.0000;
        dprocessParent.SVMXC__Weight_Total_Distance__c = 1000.0000;
        dprocessParent.SVMXC__Weight_Route_Distance__c = 100.0000;
        dprocessParent.SVMXC__Weight_Route_Time__c = 600.0000;
        dprocessParent.SVMXC__Weight_Node_Type__c = 1;
        dprocessParent.SVMXC__Weight_Total_Distance__c = 1.0000;
        dprocessParent.SVMXC__Weight_Node_Type__c = 1;
        dprocessParent.SVMXC__Territory__c = territory.id;
        insert dprocessParent;
        
        WSCH_Provider_ECO_DataMapper.objSVMXProcess = dprocessParent;
        WSCH_Provider_ECO_DataMapper.getParameters(territory);
        
    }
    
    static testMethod void testOfferAppointmentReq() {
        
        //Test.startTest();
        list<BusinessHours> lBH = [ select WednesdayStartTime, timeZoneSidKey, WednesdayEndTime, TuesdayStartTime, 
        TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, 
        SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime
        from BusinessHours where IsActive = true limit 1];
        
        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.SVMXC__Active__c = true;
        territory.SVMXC__Territory_s_Business_Hours__c = lBH[0].Id;
        insert territory;
        
        SVMXC__SM_Appointment_Window__c appointmentType = new SVMXC__SM_Appointment_Window__c();
        appointmentType.Name = 'GoldType';
        appointmentType.SVMXC__SM_Appointment_Type_Name__c = 'GoldType';
        appointmentType.RecordTypeId = Schema.SObjectType.SVMXC__SM_Appointment_Window__c.getRecordTypeInfosByName().get('Appointment Type').getRecordTypeId();
        insert appointmentType;
        
        SVMXC__SM_Appointment_Window__c ArrivalWindow = new SVMXC__SM_Appointment_Window__c();
        ArrivalWindow.name = 'Test window';
        ArrivalWindow.SVMXC__SM_Window_Start_Time__c = '09:00';
        ArrivalWindow.SVMXC__SM_Window_End_Time__c = '12:00';
        ArrivalWindow.RecordTypeId = Schema.SObjectType.SVMXC__SM_Appointment_Window__c.getRecordTypeInfosByName().get('Time Window').getRecordTypeId();
        //ArrivalWindow.SVMXC__Appointment_Type__c = appointmentType.Id;        
        insert ArrivalWindow;
        
        SVMXC__SM_Appointment_Window__c appointmentTypeDef = new SVMXC__SM_Appointment_Window__c();
        appointmentTypeDef.Name = 'GoldTypeDef';
        appointmentTypeDef.SVMXC__SM_Appointment_Type__c = appointmentType.Id;
        appointmentTypeDef.SVMXC__SM_Time_Window__c = ArrivalWindow.Id;
        appointmentTypeDef.RecordTypeId = Schema.SObjectType.SVMXC__SM_Appointment_Window__c.getRecordTypeInfosByName().get('Appointment Type Definition').getRecordTypeId();
        insert appointmentTypeDef;
        
        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        workOrder1.SVMXC__Service_Duration__c = 3600;
        workOrder1.SVMXC__Zip__c = '560022';
        workOrder1.SVMXC__Primary_Territory__c = territory.Id;
        workOrder1.SVMXC__SM_Appointment_Type__c = appointmentType.Id;
        
        //WSCH_Provider_ECO_DataMapper.manageOfferAppointmentRequest(territory, workOrder1);
        
        WSCH_ApptParam apptParam = new WSCH_ApptParam();
        apptParam.startDateTime = DateTime.now();
        apptParam.endDateTime = DateTime.now() + 2;
        
        //WSCH_Provider_ECO_DataMapper.manageOfferAppointmentRequest(territory, workOrder1, apptParam);
        
        //Test.stopTest();
    }
    
    static testMethod void testOfferAppointmentRes() {
        
        WSCH_Provider_ECO_Stubs.AppointmentOfferResponse_WP apptOfferResponse = new WSCH_Provider_ECO_Stubs.AppointmentOfferResponse_WP();
        WSCH_AppointmentsResponse techSlotResponse = new WSCH_AppointmentsResponse();
        String dateOrCost = 'date';
        
        List<WSCH_Provider_ECO_Stubs.Offer_WP> appointmentOffers = new List<WSCH_Provider_ECO_Stubs.Offer_WP>();
        
        WSCH_Provider_ECO_Stubs.Offer_WP offerWP = new WSCH_Provider_ECO_Stubs.Offer_WP();
        offerWP.startDateTime = String.valueOf(Datetime.now());
        offerWP.endDateTime = String.valueOf(Datetime.now() + 2);
        offerWP.slotCost = 100.0;
        offerWP.slotType = 'Low';
        List<String> technicians = new List<String>();
        technicians.add('tech1');
        technicians.add('tech2');
        offerWP.technicians = technicians;
        
        appointmentOffers.add(offerWP);
        apptOfferResponse.appointmentOffers = appointmentOffers;
        
        WSCH_ApptParam apptParam = new WSCH_ApptParam();
        apptParam.startDateTime = system.now();
        apptParam.endDateTime = system.now();
        apptParam.costOrDates = 'date';
        apptParam.numberOfOfferAppts = 10;
        
        WSCH_Provider_ECO_DataMapper.manageOfferAppointmentResponse(apptOfferResponse, techSlotResponse, apptParam);
    }
    
    static testMethod void testBookAppointmentReq() {
        
        list<BusinessHours> lBH = [ select WednesdayStartTime, timeZoneSidKey, WednesdayEndTime, TuesdayStartTime, 
        TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, 
        SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime
        from BusinessHours where IsActive = true limit 1];
        
        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.SVMXC__Active__c = true;
        territory.SVMXC__Territory_s_Business_Hours__c = lBH[0].Id;
        insert territory;
        
        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        workOrder1.SVMXC__Service_Duration__c = 3600;
        workOrder1.SVMXC__Zip__c = '560022';
        workOrder1.SVMXC__Primary_Territory__c = territory.Id;
        
        WSCH_Appointment slot = new WSCH_Appointment();
        slot.setStrStartDateTime(String.valueOf(Datetime.now()));
        slot.setStrEndDateTime(String.valueOf(Datetime.now() + 1));
        slot.setSlotCost(100);
        slot.setGoAhead(false);
        
        WSCH_Provider_ECO_DataMapper.manageBookAppointmentRequest(territory, workOrder1, slot);
    }
    
    static testMethod void testBookAppointmentResponse() {
        
        WSCH_Provider_ECO_Stubs.BookAppointmentResponse_WP bookApptResponse = new WSCH_Provider_ECO_Stubs.BookAppointmentResponse_WP();
        bookApptResponse.statusCode = 0;
        
        WSCH_AppointmentsResponse techSlotResponse = new WSCH_AppointmentsResponse();
        
        WSCH_Provider_ECO_DataMapper.manageBookAppointmentResponse(bookApptResponse, techSlotResponse);
    }
}