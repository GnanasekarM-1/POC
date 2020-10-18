@isTest(SeeAllData=false)
global class SPM_Scheduling_Action_UT {
	
    private static String dispatchMethodName = 'Optimized Batch';
    private static String statusComplete = 'Complete';
    private static String configRecordTypeName = 'SPM Details';
    private static String dispatchProcessRecordTypeName = 'SPM Scheduling Optimization Rule';
    private static String jobId ;
    
   static testMethod void testReportLatestRun(){
        Test.startTest();
        System.debug(LoggingLevel.DEBUG,'START testReportLatestRun');
        setupOptimaxProcess();
        setupJobs();
        
        SPM_Scheduling_Action action = new SPM_Scheduling_Action();
       	String message = action.reportLatestRun();
        
       	System.assert(true);
        Test.stopTest();
    }
    
    static testMethod void testReportLatestRunWithNoJob(){
        Test.startTest();
        System.debug(LoggingLevel.DEBUG,' START testReportLatestRunWithNoJob');
        setupOptimaxProcess();
        
        SPM_Scheduling_Action action = new SPM_Scheduling_Action();
        String message = action.reportLatestRun();
        
        System.assert(true);
       
        Test.stopTest();
    }
    
    static testMethod void testPurgeLatestRun(){
        Test.startTest();
        System.debug(LoggingLevel.DEBUG,'START testPurgeLatestRun');
        setupOptimaxProcess();
        setupJobs();
        
        SPM_Scheduling_Action action = new SPM_Scheduling_Action();
        String message = action.purgeLatestRun ();
        
        System.assert(true);
        Test.stopTest();
    }
    

    
    static testMethod void testPurgeLatestRunWithNoJob(){
        Test.startTest();
        System.debug(LoggingLevel.DEBUG,' START testPurgeLatestRunWithNoJob');
        setupOptimaxProcess();
        
        SPM_Scheduling_Action action = new SPM_Scheduling_Action();
        String message = action.purgeLatestRun ();
        
        System.assert(true);
        Test.stopTest();
    }
    
 	static testMethod void testGetLatestRunWithNoJob() {
        
        Test.startTest();
        System.debug(LoggingLevel.DEBUG,'START testGetLatestRun');
        setupOptimaxProcess();
        
        SPM_Scheduling_Action action = new SPM_Scheduling_Action();
        List<String> jobIdList ;
        jobIdList = action.getLatestRun();
        System.assert(jobIdList.size() == 0 );     
        Test.stopTest();
    }

	

    static testMethod void testGetLatestRun() {
        
        Test.startTest();
        System.debug(LoggingLevel.DEBUG,'START testGetLatestRun');
        setupOptimaxProcess();
        setupJobs();
        
        SPM_Scheduling_Action action = new SPM_Scheduling_Action();
        List<String> jobIdList = action.getLatestRun();
        if(jobIdList != null){
            System.assert(jobIdList.size() ==1, 'Invalid jobIdList Size - '+jobIdList.size());
        }
        else{
            System.assert(false);
            System.debug(LoggingLevel.DEBUG,'Unable to find latest job');
        }
        Test.stopTest();
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
       // objSVMXJob.SVMXC__OptiMax_Message__c = 'Optimax Run Completed';
        objSVMXJob.SVMXC__Start_Time__c = system.now();
        objSVMXJob.SVMXC__End_Time__c = system.now();
        objSVMXJob.SVMXC__Initiated_By__c = Userinfo.getUserId();
        objSVMXJob.SVMXC__Status__c = 'Complete';
        objSVMXJob.SVMXC__Type__c = 'FULL';
        objSVMXJob.SVMXC__OptiMax_Message__c = 'Success';
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
        objSVMXJob.SVMXC__OptiMax_Message__c = 'Success';
        insert objSVMXJob2;
        
        System.debug(LoggingLevel.DEBUG,'testGetJobs --- Job objSVMXJob2 - '+objSVMXJob2);
       
    }
    
    private static void setupJobSummary() {
        
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
        
        SVMXC__SM_Scheduling_Job_Summary__c jobSummary = new SVMXC__SM_Scheduling_Job_Summary__c();
        jobSummary.SVMXC__SM_Dispatch_Process_Id__c = optimaxProcess.Id;
        jobSummary.SVMXC__SM_JobId__c = jobId;
        jobSummary.SVMXC__SM_Job_Start_Time__c = System.now().date(); //Date.newInstance(2016, 10, 10);
        jobSummary.SVMXC__SM_Job_End_Time__c = System.now().date();
        Date tempDate = Date.newInstance(2016, 10, 9);
        jobSummary.SVMXC__SM_Horizon_Start_Date__c = tempDate;
        
        jobSummary.SVMXC__SM_Horizon_End_Date__c = tempDate.addDays(3);
        
        insert jobSummary;
    }
    
    
        private static void setupLargeSetOfJobSummary() {
        
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
        
        SVMXC__SM_Scheduling_Job_Summary__c jobSummary = new SVMXC__SM_Scheduling_Job_Summary__c();
        jobSummary.SVMXC__SM_Dispatch_Process_Id__c = optimaxProcess.Id;
        jobSummary.SVMXC__SM_JobId__c = jobId;
        jobSummary.SVMXC__SM_Job_Start_Time__c = System.now().date(); //Date.newInstance(2016, 10, 10);
        jobSummary.SVMXC__SM_Job_End_Time__c = System.now().date();
        Date tempDate = Date.newInstance(2016, 10, 9);
        jobSummary.SVMXC__SM_Horizon_Start_Date__c = tempDate;
        
        jobSummary.SVMXC__SM_Horizon_End_Date__c = tempDate.addDays(3);
        
        insert jobSummary;
        
        //second set
        objSVMXJob = new SVMXC__SVMX_Jobs__c();
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
        
        jobSummary = new SVMXC__SM_Scheduling_Job_Summary__c();
        jobSummary.SVMXC__SM_Dispatch_Process_Id__c = optimaxProcess.Id;
        jobSummary.SVMXC__SM_JobId__c = jobId;
        jobSummary.SVMXC__SM_Job_Start_Time__c = System.now().date(); //Date.newInstance(2016, 10, 10);
        jobSummary.SVMXC__SM_Job_End_Time__c = System.now().date();
        tempDate = Date.newInstance(2016, 10, 9);
        jobSummary.SVMXC__SM_Horizon_Start_Date__c = tempDate;
        jobSummary.SVMXC__SM_Horizon_End_Date__c = tempDate.addDays(3);
        insert jobSummary;
        
         //third set
        objSVMXJob = new SVMXC__SVMX_Jobs__c();
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
        
        jobSummary = new SVMXC__SM_Scheduling_Job_Summary__c();
        jobSummary.SVMXC__SM_Dispatch_Process_Id__c = optimaxProcess.Id;
        jobSummary.SVMXC__SM_JobId__c = jobId;
        jobSummary.SVMXC__SM_Job_Start_Time__c = System.now().date(); //Date.newInstance(2016, 10, 10);
        jobSummary.SVMXC__SM_Job_End_Time__c = System.now().date();
        tempDate = Date.newInstance(2016, 10, 9);
        jobSummary.SVMXC__SM_Horizon_Start_Date__c = tempDate;
        jobSummary.SVMXC__SM_Horizon_End_Date__c = tempDate.addDays(3);
        insert jobSummary;
        
         //fourth set
        objSVMXJob = new SVMXC__SVMX_Jobs__c();
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
        
        jobSummary = new SVMXC__SM_Scheduling_Job_Summary__c();
        jobSummary.SVMXC__SM_Dispatch_Process_Id__c = optimaxProcess.Id;
        jobSummary.SVMXC__SM_JobId__c = jobId;
        jobSummary.SVMXC__SM_Job_Start_Time__c = System.now().date(); //Date.newInstance(2016, 10, 10);
        jobSummary.SVMXC__SM_Job_End_Time__c = System.now().date();
        tempDate = Date.newInstance(2016, 10, 9);
        jobSummary.SVMXC__SM_Horizon_Start_Date__c = tempDate;
        jobSummary.SVMXC__SM_Horizon_End_Date__c = tempDate.addDays(3);
        insert jobSummary;
        
         //fifth set
        objSVMXJob = new SVMXC__SVMX_Jobs__c();
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
        
        jobSummary = new SVMXC__SM_Scheduling_Job_Summary__c();
        jobSummary.SVMXC__SM_Dispatch_Process_Id__c = optimaxProcess.Id;
        jobSummary.SVMXC__SM_JobId__c = jobId;
        jobSummary.SVMXC__SM_Job_Start_Time__c = System.now().date(); //Date.newInstance(2016, 10, 10);
        jobSummary.SVMXC__SM_Job_End_Time__c = System.now().date();
        tempDate = Date.newInstance(2016, 10, 9);
        jobSummary.SVMXC__SM_Horizon_Start_Date__c = tempDate;
        jobSummary.SVMXC__SM_Horizon_End_Date__c = tempDate.addDays(3);
        insert jobSummary;
        
        
         //sixth set
        objSVMXJob = new SVMXC__SVMX_Jobs__c();
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
        
        jobSummary = new SVMXC__SM_Scheduling_Job_Summary__c();
        jobSummary.SVMXC__SM_Dispatch_Process_Id__c = optimaxProcess.Id;
        jobSummary.SVMXC__SM_JobId__c = jobId;
        jobSummary.SVMXC__SM_Job_Start_Time__c = System.now().date(); //Date.newInstance(2016, 10, 10);
        jobSummary.SVMXC__SM_Job_End_Time__c = System.now().date();
        tempDate = Date.newInstance(2016, 10, 9);
        jobSummary.SVMXC__SM_Horizon_Start_Date__c = tempDate;
        jobSummary.SVMXC__SM_Horizon_End_Date__c = tempDate.addDays(3);
        insert jobSummary;
        
        
         //seventh set
        objSVMXJob = new SVMXC__SVMX_Jobs__c();
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
        
        jobSummary = new SVMXC__SM_Scheduling_Job_Summary__c();
        jobSummary.SVMXC__SM_Dispatch_Process_Id__c = optimaxProcess.Id;
        jobSummary.SVMXC__SM_JobId__c = jobId;
        jobSummary.SVMXC__SM_Job_Start_Time__c = System.now().date(); //Date.newInstance(2016, 10, 10);
        jobSummary.SVMXC__SM_Job_End_Time__c = System.now().date();
        tempDate = Date.newInstance(2016, 10, 9);
        jobSummary.SVMXC__SM_Horizon_Start_Date__c = tempDate;
        jobSummary.SVMXC__SM_Horizon_End_Date__c = tempDate.addDays(3);
        insert jobSummary;
        
        
        //eighth set
        objSVMXJob = new SVMXC__SVMX_Jobs__c();
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
        
        jobSummary = new SVMXC__SM_Scheduling_Job_Summary__c();
        jobSummary.SVMXC__SM_Dispatch_Process_Id__c = optimaxProcess.Id;
        jobSummary.SVMXC__SM_JobId__c = jobId;
        jobSummary.SVMXC__SM_Job_Start_Time__c = System.now().date(); //Date.newInstance(2016, 10, 10);
        jobSummary.SVMXC__SM_Job_End_Time__c = System.now().date();
        tempDate = Date.newInstance(2016, 10, 9);
        jobSummary.SVMXC__SM_Horizon_Start_Date__c = tempDate;
        jobSummary.SVMXC__SM_Horizon_End_Date__c = tempDate.addDays(3);
        insert jobSummary;
        
        //ninth set
        objSVMXJob = new SVMXC__SVMX_Jobs__c();
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
        
        jobSummary = new SVMXC__SM_Scheduling_Job_Summary__c();
        jobSummary.SVMXC__SM_Dispatch_Process_Id__c = optimaxProcess.Id;
        jobSummary.SVMXC__SM_JobId__c = jobId;
        jobSummary.SVMXC__SM_Job_Start_Time__c = System.now().date(); //Date.newInstance(2016, 10, 10);
        jobSummary.SVMXC__SM_Job_End_Time__c = System.now().date();
        tempDate = Date.newInstance(2016, 10, 9);
        jobSummary.SVMXC__SM_Horizon_Start_Date__c = tempDate;
        jobSummary.SVMXC__SM_Horizon_End_Date__c = tempDate.addDays(3);
        insert jobSummary;
        
        //tenth set
        objSVMXJob = new SVMXC__SVMX_Jobs__c();
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
        
        jobSummary = new SVMXC__SM_Scheduling_Job_Summary__c();
        jobSummary.SVMXC__SM_Dispatch_Process_Id__c = optimaxProcess.Id;
        jobSummary.SVMXC__SM_JobId__c = jobId;
        jobSummary.SVMXC__SM_Job_Start_Time__c = System.now().date(); //Date.newInstance(2016, 10, 10);
        jobSummary.SVMXC__SM_Job_End_Time__c = System.now().date();
        tempDate = Date.newInstance(2016, 10, 9);
        jobSummary.SVMXC__SM_Horizon_Start_Date__c = tempDate;
        jobSummary.SVMXC__SM_Horizon_End_Date__c = tempDate.addDays(3);
        insert jobSummary;
    }
    
    
    private static void setupOptimaxProcess(){
        System.debug(LoggingLevel.DEBUG,'In setupOptimaxProcessNoJob');
     	
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
    
    private static void setupOptimaxProcessNoJob(){
        System.debug('In setupOptimaxProcessNoJob');
     	
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
       
      	System.debug('optimaxProcess - '+optimaxProcess);
    }
    
     static testMethod void sourceSchedulingData(){
        Test.startTest();
        System.debug('START sourceSchedulingData');
        Date date1 = System.today();
        setupOptimaxProcess();
        setupJobs();
        setupEvents();
        //Date dToday = System.Today();
		//Datetime dtToday = datetime.newInstance(dToday.year(), dToday.month(),dToday.day()-1);
        //Datetime dtTomorrow = datetime.newInstance(dToday.year(), dToday.month(),dToday.day()+1);
        //System.debug('dtToday = '+dtToday);
        //System.debug('dtTomorrow = '+dtTomorrow);
        //System.debug('------------ jobId = '+jobId);
        //DateTime.newInstanceGmt(date1.addDays(1))
        SPM_Scheduling_Action action = new SPM_Scheduling_Action();
        SVMXC__SVMX_Jobs__c job = [select Id, Name from SVMXC__SVMX_Jobs__c limit 1];
        action.sourceSchedulingData(job.Id, System.Today().addDays(-1), System.Today().addDays(1));
        //setupEvents();
        Test.stopTest();
    }
    
    private static void setupEvents(){
        System.debug(LoggingLevel.DEBUG,'In setupEvents');
        
        //Create Business Hours
        BusinessHours bhs=[select id from BusinessHours where IsDefault=true];
        Date dToday = System.Today();
		Datetime dtToday = datetime.newInstance(dToday.year(), dToday.month(),dToday.day()-1);
        Datetime dtTomorrow = datetime.newInstance(dToday.year(), dToday.month(),dToday.day()+1);
        
        //Create a territory
        /*
        SVMXC__Territory__c localTerritory = new SVMXC__Territory__c(
          Name = 'California',                                 // Territory Name
          SVMXC__Territory_Code__c = 'CA',                     // Territory Code
          SVMXC__Active__c = true,                             // Active
          SVMXC__Mode_Of_Travel__c = 'Driving'                // Mode Of Travel
        );
        insert localTerritory;
		*/
        
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
        
        /*
        SVMXC__Service_Order__c workorder = new SVMXC__Service_Order__c(
            SVMXC__Order_Status__c = 'Open',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Order_Type__c = 'Field Service',
            SVMXC__OptiMax_Status__c = 'Initiated',
            SVMXC__Scheduled_Date_Time__c = system.now() + 120
        );
		insert workorder;

        SVMXC__Service_Order__c nextWorkorder = new SVMXC__Service_Order__c(
            SVMXC__Order_Status__c = 'Open',
            SVMXC__Priority__c = 'High',
            SVMXC__Order_Type__c = 'Field Service',
            SVMXC__OptiMax_Status__c = 'Initiated',
            SVMXC__Scheduled_Date_Time__c = system.now() + 120
        );
        insert nextWorkorder;
        */
        
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
		System.debug('Inserted SVMX Event  '+svmxEvent);
        
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
        System.debug(LoggingLevel.DEBUG,'SVMXC__Salesforce_User__c = '+technician.SVMXC__Salesforce_User__c);
        sfmEvent.OwnerId = UserInfo.getUserId();
		insert sfmEvent;
           
    }
    
     
    static testMethod void testGetJobs() {
        
        Test.startTest();
        System.debug(LoggingLevel.DEBUG,'START testGetJobs');
        Date yesterDay = Date.today().addDays(-1);
		Date tomorrow = Date.today().addDays(1);
	    setupOptimaxProcess();
        setupJobs();
       
        SPM_Scheduling_Action action = new SPM_Scheduling_Action();
        
        List<Map<String, String>> jobList = action.getJobs(yesterDay,tomorrow,'Dispatch For NA Region');
        System.debug(LoggingLevel.DEBUG,'testGetJobs SIZE jobList = '+jobList.size());
        System.assert(jobList.size() == 0, 'Actual Job Size '+ jobList.size());         
        
        Test.stopTest();
    }
    
    
    static testMethod void testGetJobsWithNoJobData() {
        
        Test.startTest();
        System.debug(LoggingLevel.DEBUG,'START testGetJobsWithNoJobData');
        Date yesterDay = Date.today().addDays(-1);
		Date tomorrow = Date.today().addDays(1);
        SPM_Scheduling_Action action = new SPM_Scheduling_Action();
        
        List<Map<String, String>> jobList = action.getJobs(yesterDay,tomorrow,'Dispatch For NA Region');
           
        System.assert(jobList.size() == 0 );
        System.debug(LoggingLevel.DEBUG,'SIZE jobList = '+jobList.size());
        
        Test.stopTest();
    }
    
    static testMethod void testPurgeData() {
        
        Test.startTest();
        System.debug(LoggingLevel.DEBUG,'START testPurgeData');
        setupOptimaxProcess();
        setupJobSummary();
        setupJobs();
        List<String> jobList = new List<String>();
        
        SVMXC__ServiceMax_Processes__c optimaxProcess = [SELECT ID from SVMXC__ServiceMax_Processes__c
                                        where SVMXC__Name__c='Dispatch For NA Region' 
                                        and SVMXC__Dispatch_Process_Status__c = 'Complete' ];
                                        
        List<SVMXC__SVMX_Jobs__c> jobs = [Select Id, Name from SVMXC__SVMX_Jobs__c where SVMXC__Status__c = 'Complete'
        					and SVMXC__OptiMax_Message__c = 'Optimax Run Completed' and 
        					SVMXC__SVMX_Process__c = :optimaxProcess.id];
        for(SVMXC__SVMX_Jobs__c job : jobs){
        	jobList.add(String.valueOf(job.Name));
        }
        SPM_Scheduling_Action action = new SPM_Scheduling_Action();
        
        action.purgeData(jobList);
        System.assert(true);
       
        Test.stopTest();
    }
    
    
    static testMethod void testPurgeDataWithLargeDataSet() {
        
        Test.startTest();
        System.debug(LoggingLevel.DEBUG,'START testPurgeData');
        setupOptimaxProcess();
        setupLargeSetOfJobSummary();
        setupJobs();
        List<String> jobList = new List<String>();
        
        SVMXC__ServiceMax_Processes__c optimaxProcess = [SELECT ID from SVMXC__ServiceMax_Processes__c
                                        where SVMXC__Name__c='Dispatch For NA Region' 
                                        and SVMXC__Dispatch_Process_Status__c = 'Complete' ];
                                        
        List<SVMXC__SVMX_Jobs__c> jobs = [Select Id, Name from SVMXC__SVMX_Jobs__c where SVMXC__Status__c = 'Complete'
        					and SVMXC__OptiMax_Message__c = 'Optimax Run Completed' and 
        					SVMXC__SVMX_Process__c = :optimaxProcess.id];
        for(SVMXC__SVMX_Jobs__c job : jobs){
        	jobList.add(String.valueOf(job.Name));
        }
        SPM_Scheduling_Action action = new SPM_Scheduling_Action();
        
        action.purgeData(jobList);
        
        List<SVMXC__SM_Scheduling_Job_Summary__c> jobSummaryList = [Select Id from SVMXC__SM_Scheduling_Job_Summary__c];
        //System.assert(jobSummaryList.size() == 0, 'Not all jobsummaries were purged');
        Test.stopTest();
    }
   
    static testMethod void testPurgeDataWithMoreJobSummary() {
        
        Test.startTest();
        System.debug(LoggingLevel.DEBUG,'START testPurgeData');
        setupOptimaxProcess();
        setupJobSummary();
        setupJobs();
        List<String> jobList = new List<String>();
        
        SVMXC__ServiceMax_Processes__c optimaxProcess = [SELECT ID from SVMXC__ServiceMax_Processes__c
                                        where SVMXC__Name__c='Dispatch For NA Region' 
                                        and SVMXC__Dispatch_Process_Status__c = 'Complete' ];
                                        
        List<SVMXC__SVMX_Jobs__c> jobs = [Select Id, Name from SVMXC__SVMX_Jobs__c where SVMXC__Status__c = 'Complete'
        					and SVMXC__OptiMax_Message__c = 'Optimax Run Completed' and 
        					SVMXC__SVMX_Process__c = :optimaxProcess.id];
        for(SVMXC__SVMX_Jobs__c job : jobs){
        	jobList.add(String.valueOf(job.Name));
        }
        SPM_Scheduling_Action action = new SPM_Scheduling_Action();
        
        action.purgeData(jobList);
        System.assert(true);
       
        Test.stopTest();
    }
    
    static testMethod void testReportSelectedRuns() {
        
        Test.startTest();
        System.debug(LoggingLevel.DEBUG,'START testReportSelectedRun');
        setupOptimaxProcess();
        setupJobs();
        List<String> jobList = new List<String>();
        
        SVMXC__ServiceMax_Processes__c optimaxProcess = [SELECT ID from SVMXC__ServiceMax_Processes__c
                                        where SVMXC__Name__c='Dispatch For NA Region' 
                                        and SVMXC__Dispatch_Process_Status__c = 'Complete' ];
                                        
        List<SVMXC__SVMX_Jobs__c> jobs = [Select Id from SVMXC__SVMX_Jobs__c where SVMXC__Status__c = 'Complete'
        					and SVMXC__OptiMax_Message__c = 'Optimax Run Completed' and 
        					SVMXC__SVMX_Process__c = :optimaxProcess.id];
        for(SVMXC__SVMX_Jobs__c job : jobs){
        	jobList.add(String.valueOf(job.Id));
        }
        SPM_Scheduling_Action action = new SPM_Scheduling_Action();
        
        action.reportSelectedRuns(jobList);
        System.assert(true);
       
        Test.stopTest();
    }
    
    private static void setupConfigData(){
        System.debug(LoggingLevel.DEBUG,'In setupConfigData');
       
       	RecordType recordTypeSPMOptimaxRule = [SELECT Id, Name FROM RecordType 
        					WHERE Name =:dispatchProcessRecordTypeName limit 1]; 
        					
        System.debug(LoggingLevel.DEBUG,'RecordTypeSPMOptimaxRule '+recordTypeSPMOptimaxRule);
        
        SVMXC__ServiceMax_Processes__c optTechUtilProcess = new SVMXC__ServiceMax_Processes__c();
        optTechUtilProcess.RecordTypeId = recordTypeSPMOptimaxRule.Id;
        optTechUtilProcess.SVMXC__Name__c = 'Optimax Technician Utilization';
        insert optTechUtilProcess;
        
        System.debug(LoggingLevel.DEBUG,'dispatchProcess '+optTechUtilProcess);
        System.debug(LoggingLevel.DEBUG,'record type name '+optTechUtilProcess.RecordType);
        
          
        RecordType recordTypeSPMDetails = [SELECT Id, Name FROM RecordType 
        WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name =:configRecordTypeName limit 1];   
      
        SVMXC__ServiceMax_Config_Data__c configuration = new SVMXC__ServiceMax_Config_Data__c();
        configuration.RecordTypeId = recordTypeSPMDetails.Id;
        configuration.SVMXC__Formula__c = 'Sample Json for testing';
        configuration.SVMXC__Dispatch_Process__c = optTechUtilProcess.Id;
        insert configuration;
        System.debug(LoggingLevel.DEBUG, ' Saved new configuration object '+configuration);   
        
    }
    
    static testMethod void testLoadConfiguration() {
        
        Test.startTest();
        System.debug(LoggingLevel.DEBUG,'START testLoadConfiguration');
        
        setupConfigData();
        SPM_Scheduling_Action action = new SPM_Scheduling_Action();
        String configData = action.loadConfiguration();
        System.debug(LoggingLevel.DEBUG, ' configData = '+configData);
        //System.assert(String.isNotEmpty(configData));
        
        Test.stopTest();
    }
    
    static testMethod void testSaveConfiguration() {
        
        Test.startTest();
        System.debug(LoggingLevel.DEBUG,'START testSaveConfiguration');
        
        setupConfigData();
        SPM_Scheduling_Action action = new SPM_Scheduling_Action();
        String configData = 'testjson';
        action.saveConfiguration(configData);
        String savedConfigData = action.loadConfiguration();
        System.debug(LoggingLevel.DEBUG, ' configData = '+configData);
        //System.assert(configData.equals(savedConfigData));
        
        Test.stopTest();
    }
    
    static testMethod void testDispatchProcessList() {
        
        Test.startTest();
        System.debug(LoggingLevel.DEBUG,' START testDispatchProcessList');
        
        setupOptimaxProcess();
        SPM_Scheduling_Action action = new SPM_Scheduling_Action();
        List<String> dispatchProcessList = action.getDispatchProcessList();
        System.debug(LoggingLevel.DEBUG,dispatchProcessList);
        System.assert(dispatchProcessList.size() > 0);
        
        Test.stopTest();
    }
    
    //List<String> getDispatchProcessList()
    static testMethod void testDispatchProcessListWithNoData() {
        
        Test.startTest();
        System.debug(LoggingLevel.DEBUG,'START testDispatchProcessList');
        
        SPM_Scheduling_Action action = new SPM_Scheduling_Action();
        List<String> dispatchProcessList = action.getDispatchProcessList();
        System.debug(LoggingLevel.DEBUG,dispatchProcessList);
        System.assert(dispatchProcessList.size() == 1);
        
        Test.stopTest();
    }
    
    
    static testMethod void testGetEventTypes() {
        
        Test.startTest();
        System.debug(LoggingLevel.DEBUG,' START testGetEventTypePickListValues');
        
        SPM_Scheduling_Action action = new SPM_Scheduling_Action();
		List<String> eventPickList = action.getEventTypes();
        System.debug(LoggingLevel.DEBUG,eventPickList);
        System.assert(eventPickList.size() > 0);
        
        Test.stopTest();
    }
}