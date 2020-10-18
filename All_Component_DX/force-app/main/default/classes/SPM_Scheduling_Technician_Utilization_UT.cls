@isTest
private class SPM_Scheduling_Technician_Utilization_UT {

    private static testMethod void testComputeUtilizationBasicFlow() {
        Test.startTest();
        setupConfigData();
        setup();
        
        //Invoke the utilization batch apex.
        SVMXC__SVMX_Jobs__c job = [select Name from SVMXC__SVMX_Jobs__c limit 1];
        List<String> jobIds = new List<String>();
        jobIds.add(job.Name);
        System.debug('Job Summary - ' + job.Name);
        
        
        SPM_Scheduling_Action action = new SPM_Scheduling_Action();
        action.computeUtilization(jobIds);
         Test.stopTest();
    }
    
    private static testMethod void testBusinessHoursFlow() {
        Test.startTest();
		RecordType optimaxRecordTypes = [SELECT Id, Name FROM RecordType WHERE Name = 'SPM Scheduling Optimization Rule'];
        //String query = 'Select Id from SVMXC__SM_Scheduling_Event_Summary__c';
		SVMXC__ServiceMax_Processes__c optimaxProcess1 = new SVMXC__ServiceMax_Processes__c();
        optimaxProcess1.SVMXC__Dispatch_Process_Status__c = 'Complete';
        optimaxProcess1.SVMXC__Dispatch_Method__c = 'Optimized Batch';
        optimaxProcess1.SVMXC__Weight_Route_Distance__c = 35;                   // Weight Route Distance
        optimaxProcess1.SVMXC__Weight_Route_Time__c = 81;                        // Weight Route Time
        optimaxProcess1.SVMXC__Weight_Time_Window__c = 26;                       // Weight Time Window
        optimaxProcess1.SVMXC__Weight_Total_Distance__c = 57;                    // Weight Total Distance
        optimaxProcess1.SVMXC__Name__c = 'Dispatch For NA Region';
        optimaxProcess1.RecordTypeId = optimaxRecordTypes.Id;
        insert optimaxProcess1;
        SPM_Scheduling_Technician_Utilization objTechUtilization = new SPM_Scheduling_Technician_Utilization('');
        //Database.executeBatch(objTechUtilization);
        
        BusinessHours bizHour = [SELECT id From BusinessHours Where IsDefault=true];
        Long minutes;
        minutes = objTechUtilization.calculateTime('day1', bizHour);
        System.assertEquals(1440,minutes);
        minutes = objTechUtilization.calculateTime('day2', bizHour);
        System.assertEquals(60,minutes);
        minutes = objTechUtilization.calculateTime('day3', bizHour);
        System.assertEquals(60,minutes);
        minutes = objTechUtilization.calculateTime('day4', bizHour);
        System.assertEquals(60,minutes);
        Test.stopTest();
    }
    
    
    private static void setup() {
       
       RecordType optimaxRecordType = [SELECT Id, Name FROM RecordType WHERE 
                                       SobjectType = 'SVMXC__ServiceMax_Processes__c' 
                                       and Name = 'Dispatch Process'];
        
       //RecordType optimaxRecordTypes = [SELECT Id, Name FROM RecordType WHERE Name = 'SPM Scheduling Optimization Rule'];
       //System.debug('optimaxProcess - '+optimaxProcess);

        
        //Create Business Hours
        BusinessHours bhs=[select id from BusinessHours where IsDefault=true];
        
        //Create a territory
        SVMXC__Territory__c localTerritory = new SVMXC__Territory__c(
          Name = 'California',                                 // Territory Name
          SVMXC__Territory_Code__c = 'CA',                     // Territory Code
          SVMXC__Active__c = true,                             // Active
          SVMXC__Mode_Of_Travel__c = 'Driving'                // Mode Of Travel
        );
        insert localTerritory;

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
        
        insert technician;

        //create an optimax process, job, record types and configuration row for testing
        SVMXC__ServiceMax_Processes__c optimaxProcess = new SVMXC__ServiceMax_Processes__c();
        optimaxProcess.SVMXC__Dispatch_Process_Status__c = 'Complete';
        optimaxProcess.SVMXC__Dispatch_Method__c = 'Optimized Batch';
        optimaxProcess.SVMXC__Weight_Route_Distance__c = 35;                   // Weight Route Distance
        optimaxProcess.SVMXC__Weight_Route_Time__c = 81;                        // Weight Route Time
        optimaxProcess.SVMXC__Weight_Time_Window__c = 26;                       // Weight Time Window
        optimaxProcess.SVMXC__Weight_Total_Distance__c = 57;                    // Weight Total Distance
        optimaxProcess.SVMXC__Name__c = 'Dispatch For NA Region';
        optimaxProcess.RecordTypeId = optimaxRecordType.Id;
        insert optimaxProcess;
		
		
        
       //Create a job for the above process.
        SVMXC__SVMX_Jobs__c objSVMXJob = new SVMXC__SVMX_Jobs__c();
        objSVMXJob.SVMXC__SVMX_Process__c = optimaxProcess.Id;
        objSVMXJob.SVMXC__Territory__c = localTerritory.Id;
        objSVMXJob.SVMXC__OptiMax_Message__c = 'Optimax Run Completed';
        objSVMXJob.SVMXC__Start_Time__c = system.now();
        objSVMXJob.SVMXC__Initiated_By__c = Userinfo.getUserId();
        objSVMXJob.SVMXC__Status__c = 'Complete';
        objSVMXJob.SVMXC__Type__c = 'FULL';
        insert objSVMXJob;
        
        //Create job summary and event summary records.
        /*
       SVMXC__SM_Scheduling_Job_Summary__c jobSummary = new SVMXC__SM_Scheduling_Job_Summary__c(
          //SVMXC__Dispatch_Process_Id__c = 'a1j2A000001LWli',                           // Dispatch Process Id
          SVMXC__Dispatch_Process_Name__c = 'Dispatch Configuration for North America',  // Dispatch Process Name
          //SVMXC__Optimax_JobId__c = 'a1f2A000001yOCM',                                   // Optimax JobId
          //SVMXC__Job_Start_Time__c = Date.valueOf('10-18-2016'),                         // Job Start Time
          //SVMXC__Job_End_Time__c = Date.valueOf('10-18-2016'),                           // Job End Time
          SVMXC__Horizon_Start_Date__c = Date.valueOf('10-20-2016'),                     // Horizon Start Date
          SVMXC__Horizon_End_Date__c = Date.valueOf('10-27-2016')                       // Horizon End Date
        );*/
        SVMXC__SM_Scheduling_Job_Summary__c jobSummary = new SVMXC__SM_Scheduling_Job_Summary__c();
        jobSummary.SVMXC__SM_Dispatch_Process_Id__c = optimaxProcess.Id;
        jobSummary.SVMXC__SM_JobId__c = objSVMXJob.Id;
        jobSummary.SVMXC__SM_Job_Start_Time__c = System.now().date(); //Date.newInstance(2016, 10, 10);
        jobSummary.SVMXC__SM_Job_End_Time__c = System.now().date();
        Date tempDate = Date.newInstance(2016, 10, 9);
        jobSummary.SVMXC__SM_Horizon_Start_Date__c = tempDate;
        
        jobSummary.SVMXC__SM_Horizon_End_Date__c = tempDate.addDays(3);
        
        insert jobSummary;

        System.debug('jobSummary - '+jobSummary);

        //Create event summary
        SVMXC__SM_Scheduling_Event_Summary__c eventSummary = new SVMXC__SM_Scheduling_Event_Summary__c(
          //SVMXC__Event_Date__c = Date.valueOf('2016-10-10'),  // Event Date
          SVMXC__SM_Event_Duration__c = 60,                      // Event Duration
          SVMXC__SM_Drive_Time__c = 10,                           // Drive Time (mins)
          SVMXC__SM_Overhead_time__c = 0,                        // Overhead time (mins)
          SVMXC__SM_Break_Minutes__c = 0                        // Break Minutes
        );
        
        //myDate = Date.newInstance(2016, 10, 10);
        //eventSummary.SVMXC__Event_Date__c = myDate;
        eventSummary.SVMXC__SM_Event_Date__c = tempDate.addDays(1);

        eventSummary.SVMXC__SM_Technician__c = technician.Id;
        eventSummary.SVMXC__SM_Job_Summary__c = jobSummary.Id;
        eventSummary.SVMXC__SM_JobId__c = objSVMXJob.Id;
        insert eventSummary;
        
         eventSummary = new SVMXC__SM_Scheduling_Event_Summary__c(
          //SVMXC__Event_Date__c = Date.valueOf('2016-10-10'),  // Event Date
          SVMXC__SM_Event_Duration__c = 160,                      // Event Duration
          SVMXC__SM_Drive_Time__c = 10,                           // Drive Time (mins)
          SVMXC__SM_Overhead_time__c = 10,                        // Overhead time (mins)
          SVMXC__SM_Break_Minutes__c = 0                        // Break Minutes
        );
        
        //myDate = Date.newInstance(2016, 10, 10);
        //eventSummary.SVMXC__Event_Date__c = myDate;
        eventSummary.SVMXC__SM_Event_Date__c = tempDate.addDays(1);

        eventSummary.SVMXC__SM_Technician__c = technician.Id;
        eventSummary.SVMXC__SM_Job_Summary__c = jobSummary.Id;
        eventSummary.SVMXC__SM_JobId__c = objSVMXJob.Id;
        insert eventSummary;
        
        
        eventSummary = new SVMXC__SM_Scheduling_Event_Summary__c(
          //SVMXC__Event_Date__c = Date.valueOf('2016-10-10'),  // Event Date
          SVMXC__SM_Event_Duration__c = 260,                      // Event Duration
          SVMXC__SM_Drive_Time__c = 10,                           // Drive Time (mins)
          SVMXC__SM_Overhead_time__c = 10,                        // Overhead time (mins)
          SVMXC__SM_Break_Minutes__c = 0                        // Break Minutes
        );
        
        //myDate = Date.newInstance(2016, 10, 10);
        //eventSummary.SVMXC__Event_Date__c = myDate;
        eventSummary.SVMXC__SM_Event_Date__c = tempDate.addDays(2);

        eventSummary.SVMXC__SM_Technician__c = technician.Id;
        eventSummary.SVMXC__SM_Job_Summary__c = jobSummary.Id;
        eventSummary.SVMXC__SM_JobId__c = objSVMXJob.Id;
        insert eventSummary;
        
        System.debug('objSVMXJob - '+objSVMXJob);
    }
    
    private static void setupConfigData(){
        System.debug(LoggingLevel.DEBUG,'In setupConfigData');
       
       	RecordType recordTypeSPMOptimaxRule = [SELECT Id, Name FROM RecordType 
        					WHERE Name = 'SPM Scheduling Optimization Rule' limit 1]; 
        					
        System.debug(LoggingLevel.DEBUG,'RecordTypeSPMOptimaxRule '+recordTypeSPMOptimaxRule);
        
        SVMXC__ServiceMax_Processes__c optTechUtilProcess = new SVMXC__ServiceMax_Processes__c();
        optTechUtilProcess.RecordTypeId = recordTypeSPMOptimaxRule.Id;
        optTechUtilProcess.SVMXC__Name__c = 'Optimax Technician Utilization';
        insert optTechUtilProcess;
        
        System.debug(LoggingLevel.DEBUG,'dispatchProcess '+optTechUtilProcess);
        System.debug(LoggingLevel.DEBUG,'record type name '+optTechUtilProcess.RecordType);
        
          
        RecordType recordTypeSPMDetails = [SELECT Id, Name FROM RecordType 
        WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name ='SPM Details' limit 1];   
      
        SVMXC__ServiceMax_Config_Data__c configuration = new SVMXC__ServiceMax_Config_Data__c();
        configuration.RecordTypeId = recordTypeSPMDetails.Id;
        configuration.SVMXC__Formula__c = '{"settings":{"emailId":"praveen.rajendra@servicemax.com","availableHours":{"data":"Other,Holiday,Military Leave,Personal"},"productiveHours":{"data":"Call,Meeting,Other,Email"}}}';
        configuration.SVMXC__Dispatch_Process__c = optTechUtilProcess.Id;
        insert configuration;
        System.debug(LoggingLevel.DEBUG, ' Saved new configuration object '+configuration);         
    }
}