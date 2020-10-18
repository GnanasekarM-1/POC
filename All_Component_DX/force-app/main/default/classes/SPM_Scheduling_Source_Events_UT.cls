@isTest
public with sharing class SPM_Scheduling_Source_Events_UT {
	
	private static String dispatchMethodName = 'Optimized Batch';
    private static String statusComplete = 'Complete';
    private static String configRecordTypeName = 'SPM Details';
    private static String dispatchProcessRecordTypeName = 'SPM Optimax Rule';
    private static String jobId ;
	
	static testMethod void testConstructor() {
        
        Test.startTest();
      
        setupSchedulingProcess();
        setupJobs();
        setupEvents();
       

 		SPM_Scheduling_Action action = new SPM_Scheduling_Action();
        SVMXC__SVMX_Jobs__c job = [select Id, Name from SVMXC__SVMX_Jobs__c limit 1];
        action.sourceSchedulingData(job.Id, System.Today().addDays(-1), System.Today().addDays(1));   
      	
        Test.stopTest();
    }
    
    private static void setupEvents(){
        System.debug('In setupEvents');
        
        //Create Business Hours
        BusinessHours bhs=[select id from BusinessHours where IsDefault=true];
        Date dToday = System.Today();
		Datetime dtToday = datetime.newInstance(dToday.year(), dToday.month(),dToday.day()-1);
        Datetime dtTomorrow = datetime.newInstance(dToday.year(), dToday.month(),dToday.day()+1);

        SVMXC__Territory__c localTerritory = [select id from SVMXC__Territory__c limit 1];
        
        //Create Team
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c(
          Name = 'Team California',                    // Service Team Name
          SVMXC__Active__c = true,                     // Active
          SVMXC__Country__c = 'United States'         // Country
        );
        insert team;
         //Create Technician
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c(
          Name = 'Jack Dauson',                               // Member Name
          SVMXC__Active__c = true,                          // Active
          SVMXC__Break_Type__c = 'Time Window',             // Break Type
          SVMXC__Enable_Scheduling__c = true,               // Enable Scheduling
          SVMXC__Select__c = false,                         // Select
          SVMXC__Third_Party__c = false,     
          SVMXC__City__c = 'California',                    // City
          SVMXC__Zip__c = '90010',                          // Zip
          SVMXC__Country__c = 'United States'             // Country
        );
        technician.SVMXC__Service_Group__c = team.Id;                 // Service Team
        technician.SVMXC__Service_Territory__c = localTerritory.Id;  // Service Territory
        technician.SVMXC__Working_Hours__c = bhs.Id;
        technician.SVMXC__Salesforce_User__c = UserInfo.getUserId();
        insert technician;
        

        
        //Date date1 = System.today();
     	SVMXC__SVMX_Event__c svmxEvent = new SVMXC__SVMX_Event__c();
        svmxEvent.Name = 'Work Order WO-test1';                                     
        //svmxEvent.SVMXC__ActivityDateTime__c = date1.addDays(3); 
        svmxEvent.SVMXC__Location__c = '34.043479919433594,-118.2519302368164';          
        svmxEvent.SVMXC__Technician__c = technician.Id;                                      
        //svmxEvent.SVMXC__WhatId__c = workorder.Id;                              
        svmxEvent.SVMXC__StartDateTime__c = System.now(); //.addDays(-1);    
        svmxEvent.SVMXC__EndDateTime__c = System.now().addMinutes(20);//date1; //DateTime.newInstanceGmt(date1.addDays(1),Time.newInstance(8,45,0,0));              
        svmxEvent.SVMXC__DurationInMinutes__c = 65;                                     
        //svmxEvent.SVMXC__Service_Order__c = workorder.Id;                          
        svmxEvent.SVMXC__IsAllDayEvent__c = false;                                       
        svmxEvent.SVMXC__Driving_Time__c = 5;                                          
        svmxEvent.SVMXC__Driving_Time_Home__c = 0;                                       
        svmxEvent.SVMXC__Overhead_Time_Before__c = 0;                                    
        svmxEvent.SVMXC__Overhead_Time_After__c = 0;                                    
        svmxEvent.SVMXC__Service_Duration__c = 3616;                                   
        svmxEvent.SVMXC__Break_Time_Total__c = 0  ;
        svmxEvent.SVMXC__Technician__c = technician.Id;
        
		insert svmxEvent;
        
		Event sfmEvent = new Event();
        sfmEvent.StartDateTime = System.now();
        sfmEvent.Type = 'SFDC Event';
        sfmEvent.EndDateTime = System.now().addMinutes(30); //dtTomorrow;
        sfmEvent.SVMXC__Driving_Time__c = 60;
        sfmEvent.SVMXC__Driving_Time_Home__c = 40;
        sfmEvent.SVMXC__Overhead_Time_Before__c= 20;
        sfmEvent.SVMXC__Overhead_Time_After__c = 20;
        sfmEVent.SVMXC__Break_Time_Total__c = 30;
        sfmEvent.SVMXC__Service_Duration__c = 100;
        System.debug('SVMXC__Salesforce_User__c = '+technician.SVMXC__Salesforce_User__c);
        sfmEvent.OwnerId = UserInfo.getUserId();
		insert sfmEvent;
           
    }
    
    
      private static void setupJobs() {
       System.debug(LoggingLevel.DEBUG,'In setup');
     	
       RecordType optimaxRecordType = [SELECT Id, Name FROM RecordType WHERE 
                                       SobjectType = 'SVMXC__ServiceMax_Processes__c' 
                                       and Name = 'Dispatch Process'];
       //create an optimax process, job, record types and configuration row for testing
       SVMXC__ServiceMax_Processes__c optimaxProcess = [SELECT ID from SVMXC__ServiceMax_Processes__c
                                        where SVMXC__Name__c='Dispatch For NA Region' 
                                        and SVMXC__Dispatch_Process_Status__c = 'Complete' ];
          
       System.debug(LoggingLevel.DEBUG,'optimaxProcess - '+optimaxProcess);
       //Create a territory
        SVMXC__Territory__c localTerritory = new SVMXC__Territory__c();
        localTerritory.name = 'Bangalore';
        insert localTerritory;
        System.debug(LoggingLevel.DEBUG,'localTerritory - '+localTerritory);
        
        //Create two job for the above process
        SVMXC__SVMX_Jobs__c objSVMXJob = new SVMXC__SVMX_Jobs__c();
        objSVMXJob.SVMXC__SVMX_Process__c = optimaxProcess.id;
        objSVMXJob.SVMXC__Territory__c = localTerritory.id;
        objSVMXJob.SVMXC__OptiMax_Message__c = 'Optimax Run Completed';
        objSVMXJob.SVMXC__Start_Time__c = system.now();
        objSVMXJob.SVMXC__End_Time__c = system.now();
        objSVMXJob.SVMXC__Initiated_By__c = Userinfo.getUserId();
        objSVMXJob.SVMXC__Status__c = 'Complete';
        objSVMXJob.SVMXC__Type__c = 'FULL';
        insert objSVMXJob;
        jobId = String.valueOf(objSVMXJob.Id);
        
        System.debug('testGetJobs --- objSVMXJob - '+objSVMXJob);
       	SVMXC__SVMX_Jobs__c objSVMXJob2 = new SVMXC__SVMX_Jobs__c();
        objSVMXJob2.SVMXC__SVMX_Process__c = optimaxProcess.id;
        objSVMXJob2.SVMXC__Territory__c = localTerritory.id;
        objSVMXJob2.SVMXC__OptiMax_Message__c = 'Optimax Run Completed';
        objSVMXJob2.SVMXC__Start_Time__c = system.now();
        objSVMXJob2.SVMXC__End_Time__c = system.now();
        objSVMXJob2.SVMXC__Initiated_By__c = Userinfo.getUserId();
        objSVMXJob2.SVMXC__Status__c = 'Complete';
        objSVMXJob2.SVMXC__Type__c = 'FULL';
        insert objSVMXJob2;
        
        System.debug(LoggingLevel.DEBUG,'testGetJobs --- Job objSVMXJob2 - '+objSVMXJob2);
       
    }
       private static void setupSchedulingProcess(){
        System.debug(LoggingLevel.DEBUG,'In setupSchedulingProcess');
     	
     	//create an optimax process & record type  for testing
     	SVMXC__ServiceMax_Processes__c optimaxProcess = new SVMXC__ServiceMax_Processes__c();
     	optimaxProcess.SVMXC__Dispatch_Process_Status__c = statusComplete;
     	optimaxProcess.SVMXC__Dispatch_Method__c = dispatchMethodName;
        optimaxProcess.SVMXC__Name__c = 'Dispatch For NA Region';
        RecordType optimaxRecordType = [SELECT Id, Name FROM RecordType WHERE 
                                       SobjectType = 'SVMXC__ServiceMax_Processes__c' 
                                       and Name = 'Dispatch Process'];
       	optimaxProcess.RecordTypeId = optimaxRecordType.Id;
       	insert optimaxProcess;
       
      	System.debug(LoggingLevel.DEBUG,'Setup optimaxProcess - '+optimaxProcess);
    }
    
}