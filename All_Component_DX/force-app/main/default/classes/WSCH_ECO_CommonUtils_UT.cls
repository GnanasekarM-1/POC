@isTest
	public with sharing class WSCH_ECO_CommonUtils_UT {
	    
	     static testMethod void test_ECO_CommonUtils() {
	     	
	     	SVMXC__Territory__c testTer = createECOTerritory('Ter-UT');
		 	SVMXC__ServiceMax_Processes__c testProcess = createECODispatchProcess(testTer.id);
		 	SVMXC__Service_Group_Members__c tectTechnician = createECOTechnician(testTer.id);
		 	
		 	List<String> techniciands = new List<String>();
		 	techniciands.add(tectTechnician.id);
		 	
		 	Event sfTestEvent = createSFEvent(tectTechnician.id);
		 	List<Event> sfEevents = new List<Event>();
		 	sfEevents.add(sfTestEvent);  
		 	
		 	SVMXC__SVMX_Event__c svmxEvent = createSVMXECOEVENT(tectTechnician.id);
		 	List<SVMXC__SVMX_Event__c> svmxEvents = new List<SVMXC__SVMX_Event__c>();
		 	svmxEvents.add(svmxEvent);
		 	
		 	SVMXC__SVMX_Optimizer__c sftestOptimizer = createOptimizer(sfTestEvent.id);
		 	List<SVMXC__SVMX_Optimizer__c> sftestOptimizers = new List<SVMXC__SVMX_Optimizer__c>();
		 	sftestOptimizers.add(sftestOptimizer);
		 	
		 	SVMXC__SVMX_Optimizer__c svmxtestOptimizer = createOptimizer(sfTestEvent.id);
		 	List<SVMXC__SVMX_Optimizer__c> svmxtestOptimizers = new List<SVMXC__SVMX_Optimizer__c>();
		 	svmxtestOptimizers.add(svmxtestOptimizer);
		 	
		 	//Invoke the methods now
		 	WSCH_ECO_CommonUtils.getOptimizerWhatIds(sftestOptimizers);
		 	WSCH_ECO_CommonUtils.fetchOptimizerWhatTypes(sftestOptimizers);
		 	WSCH_ECO_CommonUtils.getEventIdAndOptimizers(sftestOptimizers);
		 	WSCH_ECO_CommonUtils.getSFEventWhatIds(sfEevents);
		 	WSCH_ECO_CommonUtils.getSVMXEventWhatIDs(svmxEvents);
		 	
		 	Map<Id,SVMXC__Service_Group_Members__c> testTechniciansMap = WSCH_ECO_CommonUtils.getTechnicians(techniciands);
		 	Map<Id,SVMXC__Territory__c> testteritoriesMap = WSCH_ECO_CommonUtils.getTerritoriesByTechnicians(testTechniciansMap);
		 	Map<String,SVMXC__ServiceMax_Processes__c> testProcesses = WSCH_ECO_CommonUtils.getDispatchProcessesByTeritories(testteritoriesMap);
		 	
		 	WSCH_ECO_CommonUtils.getNonWOTechniciansFromSFEvents(sfEevents);
		 	WSCH_ECO_CommonUtils.getNonWOTechniciansFromSVMXEvents(svmxEvents);
		 	
		 	
		 	SVMXC__Territory__c testTer1 = createECOTerritory('Ter-UT1');
		 	String terId = String.valueOf(testTer.Id);
		 	SVMXC__SVMX_Jobs__c job = createJob(terId);
		 	
		 	List<String> testTers = new List<String>();
		 	testTers.add(testTer.id);
		 	testTers.add(testTer1.id);
		 	WSCH_ECO_CommonUtils.getSVMXJobsByTerritories(testTers);
	     	
	     }
	     
	     private static SVMXC__SVMX_Optimizer__c createOptimizer(String eventId){
	     	SVMXC__SVMX_Optimizer__c obj = new SVMXC__SVMX_Optimizer__c();
	     	obj.SVMXC__WhatType__c = 'NON_WO_EVENT';
	        obj.SVMXC__WhatId__c = eventId;
	        obj.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CREATE_EVENT' ;
	     	insert obj;
	     	return obj;
	     }
	     
	  //private supporting methods
	    private static Event createSFEvent(String techId){
	    	Event ev = new Event();
	    	ev.EventSubtype  = 'Event';
	    	ev.StartDateTime = system.today();
	    	ev.EndDateTime = system.today() + 1;
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
	    	insert technician;
	    	return technician;
	    	
	    }
	    
	    private static String createServiceGroupId(){
	     SVMXC__Service_Group__c segroup = new SVMXC__Service_Group__c();
	     segroup.Name = 'TestGroup-UT';
	     insert segroup;
	     return segroup.id;
	    }
	    
	    private static SVMXC__Territory__c createECOTerritory(String name){
	    	SVMXC__Territory__c ecoTeritory = new SVMXC__Territory__c();
	    	 ecoTeritory.Name = name;
		 	 insert ecoTeritory;
		 	 return ecoTeritory;
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
	    
	    public static SVMXC__SVMX_Jobs__c createJob(String terId){
	    	SVMXC__SVMX_Jobs__c job = new SVMXC__SVMX_Jobs__c();
		 	job.SVMXC__Territory__c = terId;
		 	job.SVMXC__Type__c = 'ECO';
		 	insert job;
		 	return job;
	    }
	    
	    
	    
	    
	    
	}