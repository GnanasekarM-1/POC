@isTest
public with sharing class WSCH_ECO_EventTriggerHandler_UT {
    
     static testMethod void test_handleSFECOEventInsert() {
         WSCH_ECO_EventTriggerHandler handler = new WSCH_ECO_EventTriggerHandler();
         List<BusinessHours> lstBHs = [Select Id, Name, IsDefault, IsActive, TimeZoneSidKey, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
         ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime
         from BusinessHours where IsActive = TRUE AND IsDefault = TRUE ];
             
        SVMXC__Territory__c testTer = createECOTerritory();
        SVMXC__SVMX_Jobs__c ecoJob = createEcoJob(testTer);
        Map<Id,SVMXC__SVMX_Jobs__c> mapTeritoryEcoJobs = new Map<Id,SVMXC__SVMX_Jobs__c>();
        mapTeritoryEcoJobs.put(ecoJob.SVMXC__Territory__c, ecoJob);

        SVMXC__ServiceMax_Processes__c testProcess = createECODispatchProcess(testTer.id);
        SVMXC__Service_Group_Members__c tectTechnician = createECOTechnician(testTer.id);
        SVMXC__Service_Group_Members__c sfTechnician = createECOSFTechnician(testTer.id);
        Map<Id, SVMXC__Service_Group_Members__c> technicianMap = new Map<Id, SVMXC__Service_Group_Members__c>();
        technicianMap.put(tectTechnician.Id, tectTechnician);
        
        Map<Id, SVMXC__Service_Group_Members__c> sfTechnicianMap = new Map<Id, SVMXC__Service_Group_Members__c>();
        sfTechnicianMap.put(sfTechnician.Id, sfTechnician);
        
        SVMXC__Service_Order__c woObj = getWO(testProcess);
        Map<Id, SVMXC__Service_Order__c> mapWoIdWoObj = new Map<Id, SVMXC__Service_Order__c>();
        mapWoIdWoObj.put(woObj.id, woObj);
        
        List<SVMXC__Service_Order__c> lstWO = new List<SVMXC__Service_Order__c>();
        lstWO.add(woObj);
                
        Event sfTestEvent = createSFEvent(sfTechnician.id, woObj);
        List<Event> sfEevents = new List<Event>();
        sfEevents.add(sfTestEvent);  
        
        List<Event> sfEeventsOld = new List<Event>();
        sfEeventsOld = sfEevents;  
        
        Map<Id, List<Event>> mapWoIdListSFEvent = new Map<Id, List<Event>>();
        mapWoIdListSFEvent.put(woObj.id, sfEevents);
        
        SVMXC__SVMX_Event__c svmxEvent = createSVMXECOEVENT(tectTechnician.id, woObj);
        List<SVMXC__SVMX_Event__c> svmxEvents = new List<SVMXC__SVMX_Event__c>();
        svmxEvents.add(svmxEvent);

        List<SVMXC__SVMX_Event__c> svmxEventsOld = new List<SVMXC__SVMX_Event__c>();
        svmxEventsOld = svmxEvents;
        
        Map<Id, List<SVMXC__SVMX_Event__c>> mapWoIdListSvmxEvent = new Map<Id, List<SVMXC__SVMX_Event__c>>();
        mapWoIdListSvmxEvent.put(woObj.id, svmxEvents);
        
        list<String> listWOEventWhatIds = new List<String>();
        listWOEventWhatIds.add(sfTestEvent.WhatId);
        listWOEventWhatIds.add(svmxEvent.SVMXC__WhatId__c);
        
        WSCH_ECO_EventTriggerHandler.createPillar(listWOEventWhatIds);
        WSCH_ECO_EventTriggerHandler.updateSVMXEventLatLong(listWOEventWhatIds, svmxEvents);
        WSCH_ECO_EventTriggerHandler.updateSFEventLatLong(sfEevents);
                
        WSCH_ECO_EventTriggerHandler.handleSFECOEventInsertNew(sfEevents);
        WSCH_ECO_EventTriggerHandler.handleSFECOEventUpdateNew(sfEevents,sfEevents);
        WSCH_ECO_EventTriggerHandler.createPillarSFECOSingleEventNew(sfEevents);
        WSCH_ECO_EventTriggerHandler.handleSFECOEventDeleteNew(sfEevents);
        WSCH_ECO_EventTriggerHandler.singleEvntListSFCreatePillar(sfEevents, sfTechnicianMap);
        WSCH_ECO_EventTriggerHandler.checkSingleOrMultiSFEvents(listWOEventWhatIds,lstBHs[0].Id);     
        WSCH_ECO_EventTriggerHandler.isNonWOSFEvent(sfTestEvent);       
        WSCH_ECO_EventTriggerHandler.multiRsrcEcoSFCreatePillar(mapWoIdWoObj, sfTechnicianMap, mapWoIdListSFEvent);
                        
        WSCH_ECO_EventTriggerHandler.handleSVMXECOEventInsertNew(svmxEvents);
        WSCH_ECO_EventTriggerHandler.handleSVMXECOEventUpdateNew(svmxEvents,svmxEventsOld);
        WSCH_ECO_EventTriggerHandler.handleSVMXECOEventDeleteNew(svmxEvents);
        WSCH_ECO_EventTriggerHandler.createPillarSVMXECOSingleEventNew(svmxEvents);
        WSCH_ECO_EventTriggerHandler.singleEvntListSvmxCreatePillar(svmxEvents, technicianMap);
        WSCH_ECO_EventTriggerHandler.checkSingleOrMultiSVMXEvents(listWOEventWhatIds,lstBHs[0].Id);
        WSCH_ECO_EventTriggerHandler.multiRsrcEcoSvmxCreatePillar(mapWoIdWoObj, technicianMap, mapWoIdListSvmxEvent);
                
        WSCH_ECO_EventTriggerHandler.checkForEcoWOs(listWOEventWhatIds, mapTeritoryEcoJobs);
        WSCH_ECO_EventTriggerHandler.checkForEcoWOIds(lstWO);
        WSCH_ECO_EventTriggerHandler.checkForExternalWOs(listWOEventWhatIds,mapTeritoryEcoJobs);
        
        
        //WSCH_ECO_EventTriggerHandler.createOptimizerObject('eventId', 'token', 'eventType', 'teetDP', 'testTerr' , tectTechnician,'woId');
        SVMXC__SVMX_Optimizer__c optimizer = new SVMXC__SVMX_Optimizer__c();
        optimizer.SVMXC__WhatType__c = 'TECHNICIAN';
        optimizer.SVMXC__WhatId__c = tectTechnician.Id + '_' + tectTechnician.Name;
        optimizer.SVMXC__Optimizer_Connection_ID__c = testProcess.id + '_' + testTer.id;
        optimizer.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CREATE_TECH';
        optimizer.SVMXC__Optimizer_Status__c = 'OPT_COMPLETED';
        optimizer.SVMXC__Optimizer_Error_Text__c = 'Technician added through initJob call';
        insert optimizer;
        WSCH_ECO_EventTriggerHandler.updateOptimizerObject('eventId', optimizer, 'token', 'testDP', 'testTerr' , tectTechnician, null);
        List<SVMXC__SVMX_Optimizer__c> listOptimizer = new List<SVMXC__SVMX_Optimizer__c>();
        listOptimizer.add(optimizer);
        WSCH_ECO_EventTriggerHandler.saveOptimizerList(listOptimizer);
            
        //Negative Test Cases to cover the catch block
        WSCH_ECO_EventTriggerHandler.manageNonWorkOrderECOEvents(null);
     }

    
    //private supporting methods
    private static Event createSFEvent(String techId, SVMXC__Service_Order__c woObj){
        Event ev = new Event();
        ev.EventSubtype  = 'Event';
        ev.StartDateTime = system.today();
        ev.EndDateTime = system.today();
        ev.WhatId = woObj.Id;
        insert ev;
        return ev;
    }
    
    private  static SVMXC__SVMX_Event__c createSVMXECOEVENT(String technician, SVMXC__Service_Order__c woObj){
        SVMXC__SVMX_Event__c svmxEv = new SVMXC__SVMX_Event__c();
        DateTime dt = DateTime.now();
        svmxEv.Name = 'EVMX_EV_UT';
        svmxEv.SVMXC__Technician__c =  technician;
        svmxEv.SVMXC__StartDateTime__c= dt;
        svmxEv.SVMXC__EndDateTime__c = dt.addMinutes(30);
        svmxEv.SVMXC__WhatId__c = woObj.Id;
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
        technician.SVMXC__Service_Group__c = createServiceGroupId();
        insert technician;
        return technician;
        
    }
    
    private static SVMXC__Service_Group_Members__c createECOSFTechnician(String terId){
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'ECO_Tech_UT';
        technician.SVMXC__City__c = 'Bangalore';
        technician.SVMXC__Country__c = 'India';
        technician.SVMXC__Zip__c = '560030';
        technician.SVMXC__Service_Territory__c = terId;
        technician.SVMXC__Service_Group__c = createServiceGroupId();
        technician.SVMXC__Salesforce_User__c = Userinfo.getUserId();
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
        List<BusinessHours> lstBusinessHours = [Select Id, Name, IsDefault, IsActive, TimeZoneSidKey, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
                            ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime
                            from BusinessHours where IsActive = TRUE AND IsDefault = TRUE ];
        
        SVMXC__Territory__c ecoTeritory = new SVMXC__Territory__c();
         ecoTeritory.Name = 'Ter-UT';
         ecoTeritory.SVMXC__Territory_s_Business_Hours__c = lstBusinessHours[0].Id;
         insert ecoTeritory;
         return ecoTeritory;
    }
    
    private static SVMXC__SVMX_Jobs__c createEcoJob(SVMXC__Territory__c terr){
        SVMXC__SVMX_Jobs__c ecoJob = new SVMXC__SVMX_Jobs__c();
         ecoJob.SVMXC__Type__c = 'ECO';
         ecoJob.SVMXC__OptiMax_Message__c = 'RUNNING';
         ecoJob.SVMXC__Territory__c = terr.Id;
         insert ecoJob;
         return ecoJob;
    }
    
    
    private static SVMXC__ServiceMax_Processes__c createECODispatchProcess(String terId){
        SVMXC__ServiceMax_Processes__c dprocess = new SVMXC__ServiceMax_Processes__c();
        dprocess.SVMXC__Dispatch_Method__c = 'Real Time Optimization';
        dprocess.SVMXC__Dispatch_Process_Status__c ='Complete';
        dprocess.SVMXC__Dispatch_Timezone__c= 'Asia/Colombo';
        dprocess.SVMXC__Name__c = 'Process-UT';
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
    
    private static SVMXC__Service_Order__c getWO(SVMXC__ServiceMax_Processes__c svmxprocess){
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrder.SVMXC__Street__c = 'Street1';
        workOrder.SVMXC__City__c = 'BANGALORE';
        workOrder.SVMXC__State__c = 'Karnataka';
        workOrder.SVMXC__Country__c = 'India';
        workOrder.SVMXC__Zip__c = '11111111';
        workOrder.SVMXC__Dispatch_Process__c = svmxprocess.Id;
        insert workOrder;
        return workOrder;
        
    }
    
}