@isTest(SeeAllData=false)
private class SPM_Scheduling_Service_UT {
	private static String dispatchMethodName = 'Optimized Batch';
    private static String statusComplete = 'Complete';
    private static String configRecordTypeName = 'SPM Details';
    private static String dispatchProcessRecordTypeName = 'SPM Scheduling Optimization Rule';
    private static String jobId ;
    
	static testMethod void testPurgeLatestRun() {
        Test.startTest();
        System.debug(LoggingLevel.DEBUG,'START testPurgeLatestRun');
        setupOptimaxProcess();
        setupJobs();
        Object result = SPM_Scheduling_Service.purgeLatestRun('temp');
        String resultStr = String.valueOf(result);
        System.assert(resultStr.contains('"success":true'));
        
        System.debug(LoggingLevel.DEBUG,' END testPurgeLatestRun'+resultStr);
        Test.stopTest();
	}
    
	static testMethod void testProcessLatestRun(){
        Test.startTest();
        System.debug(LoggingLevel.DEBUG,'START testProcessLatestRun');
        setupOptimaxProcess();
        setupJobs();
        
        Object result = SPM_Scheduling_Service.processLatestRun('temp');
        String resultStr = String.valueOf(result);
        System.assert(resultStr.contains('"success":true'));
        System.debug(LoggingLevel.DEBUG,' END testProcessLatestRun '+resultStr);
        Test.stopTest();
        
    }
    
    static testMethod void testReportSelectedRuns(){
        Test.startTest();
        System.debug(LoggingLevel.DEBUG,'START testReportSelectedRuns');
        setupOptimaxProcess();
        setupJobs();
        
        SVMXC__SVMX_Jobs__c jobs = [Select Id from SVMXC__SVMX_Jobs__c limit 1];
        
        String jobsId = jobs.Id;
        String inputJson = '{"jobsId":"'+String.valueOf(jobsId)+'"}';
        Object result = SPM_Scheduling_Service.reportSelectedRuns(inputJson);
        String resultStr = String.valueOf(result);
        
        System.assert(resultStr.contains('"success":true'));
        System.debug(LoggingLevel.DEBUG,'END testReportSelectedRuns');
        Test.stopTest();
        
    }
    
    static testMethod void testPurgeSelectedRuns(){
        Test.startTest();
        System.debug(LoggingLevel.DEBUG,'START testPurgeSelectedRuns');
        setupOptimaxProcess();
        setupJobs();
        
        SVMXC__SVMX_Jobs__c jobs = [Select Id from SVMXC__SVMX_Jobs__c limit 1];
        
        String jobsId = jobs.Id;
        String inputJson = '{"jobsId":"'+String.valueOf(jobsId)+'"}';
        Object result = SPM_Scheduling_Service.purgeSelectedRuns(inputJson);
        String resultStr = String.valueOf(result);
        
        System.assert(resultStr.contains('"success":true'));
        System.debug(LoggingLevel.DEBUG,'END testPurgeSelectedRuns');
        Test.stopTest();
        
    }
    
     static testMethod void testGetJobs() {
        
        Test.startTest();
        System.debug(LoggingLevel.DEBUG,'START testGetJobs');
        Date yesterDay = Date.today().addDays(-1);
		Date tomorrow = Date.today().addDays(1);
	    setupOptimaxProcess();
        setupJobs();
        String requestStr='{"startDate":"2016-1-1","endDate":"2016-12-12","processName":""}';
        Object result =  SPM_Scheduling_Service.getJobsList(requestStr);
       
        String resultStr = String.valueOf(result);
        System.assert(resultStr.contains('"success":true'));
        System.debug(LoggingLevel.DEBUG,'END testGetJobs');
        Test.stopTest();
    }


     static testMethod void testGetJobsWithProcessName() {
        
        Test.startTest();
        System.debug(LoggingLevel.DEBUG,'START testGetJobs');
        Date yesterDay = Date.today().addDays(-1);
		Date tomorrow = Date.today().addDays(1);
	    setupOptimaxProcess();
        setupJobs();
        String requestStr='{"startDate":"2016-1-1","endDate":"2016-12-12","processName":"Dispatch Process for North America"}';
        Object result =  SPM_Scheduling_Service.getJobsList(requestStr);
       
        String resultStr = String.valueOf(result);
        System.assert(resultStr.contains('"success":true'));
        System.debug(LoggingLevel.DEBUG,'END testGetJobs');
        Test.stopTest();
    }
    
    static testMethod void testLoadConfiguration() {
        
        Test.startTest();
        System.debug(LoggingLevel.DEBUG,'START testLoadConfiguration');
        setupConfigData();
        Object result =  SPM_Scheduling_Service.loadConfiguration('temp');
        String resultStr = String.valueOf(result);
        System.debug(resultStr);
        //System.assert(resultStr.contains('"success":true'));
        System.debug(LoggingLevel.DEBUG,'END testLoadConfiguration');   
        Test.stopTest();
    }
    
    static testMethod void testSaveConfiguration() {
        
        Test.startTest();
        System.debug(LoggingLevel.DEBUG,'START testSaveConfiguration');
        setupOptimaxProcess();
        setupConfigData();
        String testJson = '{"testfield":"testvalue"}';
        Object result =  SPM_Scheduling_Service.saveConfiguration(testJson);
        String resultStr = String.valueOf(result);
        
        System.debug(resultStr);
        System.assert(resultStr.contains('"success":true'));
        System.debug(LoggingLevel.DEBUG,'END testSaveConfiguration');   
        Test.stopTest();
    }
    
    static testMethod void testGetJobsListWithNoData() {
        
        Test.startTest();
        System.debug(LoggingLevel.DEBUG,'START testGetJobsListWithNoData');
        Date yesterDay = Date.today().addDays(-1);
		Date tomorrow = Date.today().addDays(1);
        SPM_Scheduling_Action action = new SPM_Scheduling_Action();
        
        List<Map<String, String>> jobList = action.getJobs(yesterDay,tomorrow,'Dispatch For NA Region');
           
        System.assert(jobList.size() == 0 );
        System.debug(LoggingLevel.DEBUG,'SIZE jobList = '+jobList.size());
        System.debug(LoggingLevel.DEBUG,'END testGetJobsListWithNoData');   
        Test.stopTest();
    }
    
    private static void setupJobs() {
       System.debug(LoggingLevel.DEBUG,'In setupJobs');
     	
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
        
       //Create a job for the above process
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
        
        System.debug(LoggingLevel.DEBUG,'objSVMXJob - '+objSVMXJob);
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
        
        System.debug(LoggingLevel.DEBUG,'setupJobs - Job objSVMXJob2 - '+objSVMXJob2);
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
        
        SVMXC__ServiceMax_Processes__c optimaxTechUtilProcess = new SVMXC__ServiceMax_Processes__c();
     	optimaxTechUtilProcess.SVMXC__Dispatch_Process_Status__c = statusComplete;
     	optimaxTechUtilProcess.SVMXC__Dispatch_Method__c = dispatchMethodName;
        optimaxTechUtilProcess.SVMXC__Name__c = 'Optimax Technician Utilization';
        
        RecordType recordType = [SELECT Id, Name FROM RecordType WHERE Name = :dispatchProcessRecordTypeName limit 1];
       	optimaxTechUtilProcess.RecordTypeId = recordType.Id;
       	insert optimaxTechUtilProcess;
        
      	System.debug(LoggingLevel.DEBUG,'Setup optimaxProcess - '+optimaxProcess+' ,optimaxTechUtilProcess=  '+optimaxTechUtilProcess);
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
    
}