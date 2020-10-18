@isTest(seeAllData = false)
public with sharing class WSCH_TechnicianTriggerHandler_UT {
	
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
    
    private static String getSVMXRuleRecordId(){
    	String svmxRuleRecordType;
    	RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' ];
    	for(RecordType rt : rts)
        {
            if(rt.Name == 'SVMX Rule' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               svmxRuleRecordType = rt.ID;
        }
        return svmxRuleRecordType;
    	
    }
	
	static testMethod void testTechTriggerHandler1() {
		
		list<BusinessHours> lBH = [ select WednesdayStartTime, timeZoneSidKey, WednesdayEndTime, TuesdayStartTime, 
		TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, 
		SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime
		 from BusinessHours where IsActive = true limit 1];
		
		SVMXC__Territory__c territory = new SVMXC__Territory__c();
		territory.SVMXC__Active__c = true;
		territory.SVMXC__Territory_s_Business_Hours__c = lBH[0].Id;
		insert territory;
		
		SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
		team.Name = 'team1';
		team.SVMXC__Active__c = true;
		insert team;
		
		SVMXC__SVMX_Jobs__c svmxJob = new SVMXC__SVMX_Jobs__c();
		svmxJob.SVMXC__Territory__c = territory.Id;
		svmxJob.SVMXC__Type__c = 'ECO';
		insert svmxJob;
		
		Date dt = Date.today();
		dt = dt.addDays(1);
		
		SVMXC__ServiceMax_Processes__c dprocessParent = new SVMXC__ServiceMax_Processes__c();
    	dprocessParent.SVMXC__Dispatch_Method__c = 'Real Time Optimization';
    	dprocessParent.SVMXC__Dispatch_Process_Status__c ='Complete';
    	dprocessParent.SVMXC__Dispatch_Timezone__c= 'Asia/Colombo';
    	dprocessParent.SVMXC__Name__c = 'Process-UT';
    	dprocessParent.RecordTypeId = getDispatchProcessRecordId();
    	dprocessParent.SVMXC__End_Date__c = dt;
    	insert dprocessParent;
    	
    	SVMXC__ServiceMax_Processes__c dprocess = new SVMXC__ServiceMax_Processes__c();
    	dprocess.SVMXC__Process__c = dprocessParent.Id;
    	dprocess.SVMXC__Rule_Type__c = 'Territory Access';
    	dprocess.SVMXC__Territory__c = territory.Id;
    	dprocess.RecordTypeId = getSVMXRuleRecordId();
    	insert dprocess;
		
		SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c();
		tech1.SVMXC__Service_Territory__c = territory.Id;
		tech1.SVMXC__Service_Group__c = team.Id;
		tech1.SVMXC__Enable_Scheduling__c = true;
		insert tech1;
		
		List<SVMXC__Service_Group_Members__c> techInsert = new List<SVMXC__Service_Group_Members__c>();
		techInsert.add(tech1);
		
		/* Technician Insert scenario */
		
		WSCH_TechnicianTriggerHandler.handleTechnicianInsert(techInsert);
		
		/* Technician Update scenario */
		
		SVMXC__Service_Group_Members__c tech2 = new SVMXC__Service_Group_Members__c();
		tech2.Name = 'tech2';
		tech2.SVMXC__Service_Territory__c = territory.Id;
		tech2.SVMXC__Service_Group__c = team.Id;
		tech2.SVMXC__Enable_Scheduling__c = true;
		insert tech2;
		
		SVMXC__SVMX_Optimizer__c optTransObj1 = new SVMXC__SVMX_Optimizer__c();
		optTransObj1.SVMXC__WhatId__c = tech2.Id +'_'+ tech2.Name;
		insert optTransObj1;
		
		SVMXC__Service_Group_Members__c tech3 = new SVMXC__Service_Group_Members__c();
		tech3.Name = 'tech3';
		tech3.SVMXC__Service_Territory__c = territory.Id;
		tech3.SVMXC__Service_Group__c = team.Id;
		tech3.SVMXC__Enable_Scheduling__c = true;
		insert tech3;
		
		SVMXC__SVMX_Optimizer__c optTransObj2 = new SVMXC__SVMX_Optimizer__c();
		optTransObj2.SVMXC__WhatId__c = tech3.Id +'_'+ tech3.Name;
		insert optTransObj2;
		
		List<SVMXC__Service_Group_Members__c> newTech = new List<SVMXC__Service_Group_Members__c>();
		newTech.add(tech2);
		
		List<SVMXC__Service_Group_Members__c> oldTech = new List<SVMXC__Service_Group_Members__c>();
		oldTech.add(tech3);
		
		WSCH_TechnicianTriggerHandler.handleTechnicianUpdate(newTech, oldTech);
		
		/* Technician Delete scenario */
		WSCH_TechnicianTriggerHandler.handleTechnicianDelete(newTech);
		
	}
    
}