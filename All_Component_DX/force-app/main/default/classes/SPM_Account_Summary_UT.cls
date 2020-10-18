@isTest
global class SPM_Account_Summary_UT {

    private static RecordType spmRuleRecordType;
    private static RecordType spmDetailsRecordType;

    private static String calculationMethod = '{"targetObjectName":"SVMXC__SPM_Account_Summary__c","targetObjectLabel":"SPM - Account Summary","sourceObjectName":"SVMXC__ServiceMax_Processes__c","sourceObjectLabel":"SPM - First Time Fix, Second","recordId":"a10F0000007h0TvIAI","parameterInfoList":[],"objectMappingDetailsList":[],"name":"CN-0003723482","methodDisplayName":null,"method":null,"lastModifiedOn":"7/19/2016 5:41 PM","isActive":true,"expressionDetailsList":[],"appliesTo":"Load Account Summary"}';
    private static void setup() {
       if( spmRuleRecordType == null ) {
        	spmRuleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'SPM Rule'];    
        }
        
        if( spmDetailsRecordType == null ) {
        	spmDetailsRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name = 'SPM Details'];    
        }   
        
        Id processId = insertProcess();
        insertConfigData( processId );
    }
    
    private static Id insertProcess() {
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__ProcessID__c = SPM_Schema.Report.AccountSummary.name();
        process.SVMXC__Name__c = 'Account Summary';
        insert process;
        return process.Id;
    }
    
        
    private static void insertConfigData( Id processId ) {
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.RecordTypeId = spmDetailsRecordType.Id;
        configData.SVMXC__Dispatch_Process__c = processId;
        configData.SVMXC__Formula__c = calculationMethod;
        configData.SVMXC__Active__c = true;
        
        insert configData;
        calculationMethod.replace( 'a10F0000007h0TvIAI', configData.Id );
        
    }
    
    
    private static void insertMetricProcess() {
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__ProcessID__c = SPM_Schema.Report.FirstTimeFix.name();
        process.SVMXC__Name__c = 'First Time Fix';
        insert process;
        
        process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__ProcessID__c = SPM_Schema.Report.RepeatVisit.name();
        process.SVMXC__Name__c = 'Repeat Fix';
        insert process;
        
        process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__ProcessID__c = SPM_Schema.Report.MeanTimeToComplete.name();
        process.SVMXC__Name__c = 'Mean Time to Complete';
        insert process;
        
        process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__ProcessID__c = SPM_Schema.Report.MeanTimeToRepair.name();
        process.SVMXC__Name__c = 'Mean Time to Repair';
        insert process;
        
        process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__ProcessID__c = SPM_Schema.Report.RepeatVisit.name();
        process.SVMXC__Name__c = 'Repeat Visit';
        insert process;
        
        process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__ProcessID__c = SPM_Schema.Report.UpDownTime.name();
        process.SVMXC__Name__c = 'Contract Uptime';
        insert process;
        
        process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__ProcessID__c = SPM_Schema.Report.AverageResponseTime.name();
        process.SVMXC__Name__c = 'Average Response Time';
        insert process;
        
        process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__ProcessID__c = SPM_Schema.Report.ContractPenetration.name();
        process.SVMXC__Name__c = 'Attach Rate';
        insert process;
    }


    
    
    private static void insertFTFRecords() {
        Account account = new Account();
        account.Name = 'Tesla';
        insert account;
        
        Account account2 = new Account();
        account2.Name = 'Maruthi';
        insert account2;
    
        SVMXC__SPM_First_Time_Fix__c firstTimeFix = new SVMXC__SPM_First_Time_Fix__c();
        Datetime closedOn = System.today().addDays(-1); //(Datetime) getSourceObjectFieldValue(record, SPM_Schema.Field.ClosedOn );
        firstTimeFix.SVMXC__Fixed_On__c = closedOn.date();
        firstTimeFix.SVMXC__Account__c = account.Id;
        firstTimeFix.SVMXC__Configuration_Name__c = 'FirstTimeFix';
        firstTimeFix.SVMXC__Calculation_Method__c = 'SPMFTF:FromWorkorder';
        firstTimeFix.SVMXC__Is_Fixed_First_Time__c = true;
        insert firstTimeFix;
        
        
        firstTimeFix = new SVMXC__SPM_First_Time_Fix__c();
        closedOn = System.today().addDays(-2); //(Datetime) getSourceObjectFieldValue(record, SPM_Schema.Field.ClosedOn );
        firstTimeFix.SVMXC__Fixed_On__c = closedOn.date();
        firstTimeFix.SVMXC__Account__c = account.Id;
        firstTimeFix.SVMXC__Configuration_Name__c = 'FirstTimeFix';
        firstTimeFix.SVMXC__Calculation_Method__c = 'SPMFTF:FromWorkorder';
        firstTimeFix.SVMXC__Is_Fixed_First_Time__c = true;
        insert firstTimeFix;
        
        
        
        firstTimeFix = new SVMXC__SPM_First_Time_Fix__c();
         closedOn = System.today().addDays(-35); //(Datetime) getSourceObjectFieldValue(record, SPM_Schema.Field.ClosedOn );
        firstTimeFix.SVMXC__Fixed_On__c = closedOn.date();
        firstTimeFix.SVMXC__Account__c = account2.Id;
        firstTimeFix.SVMXC__Configuration_Name__c = 'FirstTimeFix';
        firstTimeFix.SVMXC__Calculation_Method__c = 'SPMFTF:FromWorkorder';
        firstTimeFix.SVMXC__Is_Fixed_First_Time__c = true;
        insert firstTimeFix;
        
        
        firstTimeFix = new SVMXC__SPM_First_Time_Fix__c();
         closedOn = System.today().addDays(-40); //(Datetime) getSourceObjectFieldValue(record, SPM_Schema.Field.ClosedOn );
        firstTimeFix.SVMXC__Fixed_On__c = closedOn.date();
        firstTimeFix.SVMXC__Account__c = account2.Id;
        firstTimeFix.SVMXC__Configuration_Name__c = 'FirstTimeFix';
        firstTimeFix.SVMXC__Calculation_Method__c = 'SPMFTF:FromWorkorder';
        firstTimeFix.SVMXC__Is_Fixed_First_Time__c = true;
        insert firstTimeFix;
    }
    
    private static void insertRepeatVisitRecords() {
        Account account = new Account();
        account.Name = 'Tesla';
        insert account;
        
        Account account2 = new Account();
        account2.Name = 'Maruthi';
        insert account2;
        
        SVMXC__SPM_Repeat_Visit__c repeatVisit = new SVMXC__SPM_Repeat_Visit__c();
        Datetime tempDate = System.today().addDays(-1);
        repeatVisit.SVMXC__First_Incident_On__c = tempDate.date();
        repeatVisit.SVMXC__Calculation_Method__c = 'SPMRepeatVisit:FromWorkOrder'; 
        repeatVisit.SVMXC__Configuration_Name__c = 'Repeat Visit for India'; 
        //repeatVisit.SVMXC__Is_Repeat_Visit__c = true;
        repeatVisit.SVMXC__Account__c = account.Id;
        insert repeatVisit;
    }
    
    private static void insertMTTCRecords() {
        Account account = new Account();
        account.Name = 'Tesla';
        insert account;
        
        Account account2 = new Account();
        account2.Name = 'Maruthi';
        insert account2;
        
        SVMXC__SPM_Mean_Time_To_Complete__c meanTimeToComplete = new SVMXC__SPM_Mean_Time_To_Complete__c();
        meanTimeToComplete.SVMXC__Account__c = account.Id;
        meanTimeToComplete.SVMXC__Completion_Time__c = 100;
        Datetime tempDate = System.today().addDays(-1);
        meanTimeToComplete.SVMXC__Service_Delivered_On__c = tempDate.date();
        meanTimeToComplete.SVMXC__Configuration_Name__c = 'MTTC for India';
        meanTimeToComplete.SVMXC__Calculation_Method__c = 'SPMMTTC:WO';
        insert meanTimeToComplete;
        
        meanTimeToComplete = new SVMXC__SPM_Mean_Time_To_Complete__c();
        meanTimeToComplete.SVMXC__Account__c = account.Id;
        meanTimeToComplete.SVMXC__Completion_Time__c = 100;
         tempDate = System.today().addDays(-2);
        meanTimeToComplete.SVMXC__Service_Delivered_On__c = tempDate.date();
        meanTimeToComplete.SVMXC__Configuration_Name__c = 'MTTC for India';
        meanTimeToComplete.SVMXC__Calculation_Method__c = 'SPMMTTC:WO';
        insert meanTimeToComplete;
        
        meanTimeToComplete = new SVMXC__SPM_Mean_Time_To_Complete__c();
        meanTimeToComplete.SVMXC__Account__c = account.Id;
        meanTimeToComplete.SVMXC__Completion_Time__c = 1000;
         tempDate = System.today().addDays(-1);
        meanTimeToComplete.SVMXC__Service_Delivered_On__c = tempDate.date();
        meanTimeToComplete.SVMXC__Configuration_Name__c = 'MTTC for India';
        meanTimeToComplete.SVMXC__Calculation_Method__c = 'SPMMTTC:WO';
        insert meanTimeToComplete;
        
        meanTimeToComplete = new SVMXC__SPM_Mean_Time_To_Complete__c();
        meanTimeToComplete.SVMXC__Account__c = account.Id;
        meanTimeToComplete.SVMXC__Completion_Time__c = 200;
         tempDate = System.today().addDays(-3);
        meanTimeToComplete.SVMXC__Service_Delivered_On__c = tempDate.date();
        meanTimeToComplete.SVMXC__Configuration_Name__c = 'MTTC for India';
        meanTimeToComplete.SVMXC__Calculation_Method__c = 'SPMMTTC:WO';
        insert meanTimeToComplete;
        
        //Second Account
    }
    
    private static void insertMTTRRecords() {
        Account account = new Account();
        account.Name = 'Tesla';
        insert account;
        
        Account account2 = new Account();
        account2.Name = 'Maruthi';
        insert account2;
        
        SVMXC__SPM_Mean_Time_To_Repair__c meanTimeToRepair = new SVMXC__SPM_Mean_Time_To_Repair__c();
        meanTimeToRepair.SVMXC__Account__c = account.Id;
        meanTimeToRepair.SVMXC__Dead_Time__c = 30;
        meanTimeToRepair.SVMXC__Labor_Time__c = 100;
        Datetime tempDate = System.today().addDays(-1);
        meanTimeToRepair.SVMXC__Service_Delivered_On_Date__c = tempDate.date();
        meanTimeToRepair.SVMXC__Configuration_Name__c = 'MTTR for USA';
        meanTimeToRepair.SVMXC__Calculation_Method__c = 'SPMMTTR:WO';
        insert meanTimeToRepair;
        
        meanTimeToRepair = new SVMXC__SPM_Mean_Time_To_Repair__c();
        meanTimeToRepair.SVMXC__Account__c = account.Id;
        meanTimeToRepair.SVMXC__Dead_Time__c = 300;
        meanTimeToRepair.SVMXC__Labor_Time__c = 1000;
        tempDate = System.today().addDays(-2);
        meanTimeToRepair.SVMXC__Service_Delivered_On_Date__c = tempDate.date();
        meanTimeToRepair.SVMXC__Configuration_Name__c = 'MTTR for USA';
        meanTimeToRepair.SVMXC__Calculation_Method__c = 'SPMMTTR:WO';
        insert meanTimeToRepair;
        
        meanTimeToRepair = new SVMXC__SPM_Mean_Time_To_Repair__c();
        meanTimeToRepair.SVMXC__Account__c = account.Id;
        meanTimeToRepair.SVMXC__Dead_Time__c = 30;
        meanTimeToRepair.SVMXC__Labor_Time__c = 1000;
         tempDate = System.today().addDays(-1);
        meanTimeToRepair.SVMXC__Service_Delivered_On_Date__c = tempDate.date();
        meanTimeToRepair.SVMXC__Configuration_Name__c = 'MTTR for USA';
        meanTimeToRepair.SVMXC__Calculation_Method__c = 'SPMMTTR:WO';
        insert meanTimeToRepair;
        
        meanTimeToRepair = new SVMXC__SPM_Mean_Time_To_Repair__c();
        meanTimeToRepair.SVMXC__Account__c = account.Id;
        meanTimeToRepair.SVMXC__Dead_Time__c = 300;
        meanTimeToRepair.SVMXC__Labor_Time__c = 2000;
        tempDate = System.today().addDays(-3);
        meanTimeToRepair.SVMXC__Service_Delivered_On_Date__c = tempDate.date();
        meanTimeToRepair.SVMXC__Configuration_Name__c = 'MTTR for USA';
        meanTimeToRepair.SVMXC__Calculation_Method__c = 'SPMMTTR:WO';
        insert meanTimeToRepair;
        
        //===== second account ==
        
        meanTimeToRepair = new SVMXC__SPM_Mean_Time_To_Repair__c();
        meanTimeToRepair.SVMXC__Account__c = account2.Id;
        meanTimeToRepair.SVMXC__Dead_Time__c = 30;
        meanTimeToRepair.SVMXC__Labor_Time__c = 100;
         tempDate = System.today().addDays(-30);
        meanTimeToRepair.SVMXC__Service_Delivered_On_Date__c = tempDate.date();
        meanTimeToRepair.SVMXC__Configuration_Name__c = 'MTTR for India';
        meanTimeToRepair.SVMXC__Calculation_Method__c = 'SPMMTTR:WO';
        insert meanTimeToRepair;
        
        meanTimeToRepair = new SVMXC__SPM_Mean_Time_To_Repair__c();
        meanTimeToRepair.SVMXC__Account__c = account2.Id;
        meanTimeToRepair.SVMXC__Dead_Time__c = 300;
        meanTimeToRepair.SVMXC__Labor_Time__c = 1000;
        tempDate = System.today().addDays(-45);
        meanTimeToRepair.SVMXC__Service_Delivered_On_Date__c = tempDate.date();
        meanTimeToRepair.SVMXC__Configuration_Name__c = 'MTTR for India';
        meanTimeToRepair.SVMXC__Calculation_Method__c = 'SPMMTTR:WO';
        insert meanTimeToRepair;
        
        meanTimeToRepair = new SVMXC__SPM_Mean_Time_To_Repair__c();
        meanTimeToRepair.SVMXC__Account__c = account2.Id;
        meanTimeToRepair.SVMXC__Dead_Time__c = 30;
        meanTimeToRepair.SVMXC__Labor_Time__c = 1000;
         tempDate = System.today().addDays(-40);
        meanTimeToRepair.SVMXC__Service_Delivered_On_Date__c = tempDate.date();
        meanTimeToRepair.SVMXC__Configuration_Name__c = 'MTTR for India';
        meanTimeToRepair.SVMXC__Calculation_Method__c = 'SPMMTTR:WO';
        insert meanTimeToRepair;
        
        meanTimeToRepair = new SVMXC__SPM_Mean_Time_To_Repair__c();
        meanTimeToRepair.SVMXC__Account__c = account2.Id;
        meanTimeToRepair.SVMXC__Dead_Time__c = 300;
        meanTimeToRepair.SVMXC__Labor_Time__c = 2000;
        tempDate = System.today().addDays(-33);
        meanTimeToRepair.SVMXC__Service_Delivered_On_Date__c = tempDate.date();
        meanTimeToRepair.SVMXC__Configuration_Name__c = 'MTTR for India';
        meanTimeToRepair.SVMXC__Calculation_Method__c = 'SPMMTTR:WO';
        insert meanTimeToRepair;
    }
    
    private static void insertARTRecords() {
        Account account = new Account();
        account.Name = 'Tesla';
        insert account;
        
        Account account2 = new Account();
        account2.Name = 'Maruthi';
        insert account2;
        
        SVMXC__SPM_Average_Response_Time__c objART = new SVMXC__SPM_Average_Response_Time__c();
        objART.SVMXC__Actual_Initial_Response_Time__c = 10;
		objART.SVMXC__Actual_Onsite_Response_Time__c = 20;
		objART.SVMXC__Actual_Restoration_Time__c = 30;
		objART.SVMXC__Actual_Resolution_Time__c = 40;
		Datetime tempDate = System.today().addDays(-1);
		objART.SVMXC__Service_Delivered_On__c = tempDate.date();
		objART.SVMXC__Account__c = account.Id;
		objART.SVMXC__Configuration_Name__c = 'ART for Site';
        objART.SVMXC__Calculation_Method__c = 'SPMART:WO';
        insert objART;
        
        objART = new SVMXC__SPM_Average_Response_Time__c();
        objART.SVMXC__Actual_Initial_Response_Time__c = 100;
		objART.SVMXC__Actual_Onsite_Response_Time__c = 200;
		objART.SVMXC__Actual_Restoration_Time__c = 300;
		objART.SVMXC__Actual_Resolution_Time__c = 400;
		tempDate = System.today().addDays(-10);
		objART.SVMXC__Service_Delivered_On__c = tempDate.date();
		objART.SVMXC__Account__c = account2.Id;
		objART.SVMXC__Configuration_Name__c = 'ART for Site';
        objART.SVMXC__Calculation_Method__c = 'SPMART:WO';
        insert objART;
        
    }
    
    
    private static void insertAttachRateRecords() {
        Account account = new Account();
        account.Name = 'Tesla';
        insert account;
        
        SVMXC__SPM_Contract_Penetration__c contractPenetration = new SVMXC__SPM_Contract_Penetration__c();
        contractPenetration.SVMXC__Account__c = account.Id;      
        contractPenetration.SVMXC__Covered_By__c = 'Not Covered';
        contractPenetration.SVMXC__Configuration_Name__c = 'SPM Attach Rate';
        contractPenetration.SVMXC__Calculation_Method__c = 'CN-0003723482';
        contractPenetration.SVMXC__Processed_On__c = System.today().addDays(-10);
        insert contractPenetration;
        
        contractPenetration = new SVMXC__SPM_Contract_Penetration__c();
        contractPenetration.SVMXC__Account__c = account.Id;      
        contractPenetration.SVMXC__Covered_By__c = 'Not Covered';
        contractPenetration.SVMXC__Configuration_Name__c = 'SPM Attach Rate';
        contractPenetration.SVMXC__Calculation_Method__c = 'CN-0003723482';
        contractPenetration.SVMXC__Processed_On__c = System.today().addDays(-10);
        insert contractPenetration;
        
        
        contractPenetration = new SVMXC__SPM_Contract_Penetration__c();
        contractPenetration.SVMXC__Account__c = account.Id;      
        contractPenetration.SVMXC__Covered_By__c = 'Contract';
        contractPenetration.SVMXC__Configuration_Name__c = 'SPM Attach Rate';
        contractPenetration.SVMXC__Calculation_Method__c = 'CN-0003723482';
        contractPenetration.SVMXC__Processed_On__c = System.today().addDays(-10);
        insert contractPenetration;
        
    }
    
    private static void insertContractUpTimeRecords() {
        Account account = new Account();
        account.Name = 'Tesla';
        insert account;
        
        SVMXC__SPM_Contract_Up_Time__c upTimeDetail = new SVMXC__SPM_Contract_Up_Time__c();                           
		upTimeDetail.SVMXC__Account__c = account.Id;
		upTimeDetail.SVMXC__Gauranteed_Up_Time__c = 1000;
		//upTimeDetail.SVMXC__Total_Down_Time__c = 20;
		upTimeDetail.SVMXC__Start_Date__c = System.today();
		upTimeDetail.SVMXC__Configuration_Name__c = 'SPM Contract Up Time';
		upTimeDetail.SVMXC__Calculation_Method__c = 'CN-0003723481';
		insert upTimeDetail;					
    }
    							
    
    private static void insertMetricData() {
        insertFTFRecords();
        insertMTTCRecords();
        insertMTTRRecords();
        insertRepeatVisitRecords();
        insertARTRecords();
        insertAttachRateRecords();
        insertContractUpTimeRecords();
    }
    
    
	private static testMethod void testForAllFlows() {
    
        Test.startTest();
        
        setup();
        
        insertMetricProcess();
        insertMetricData();
        // checkMTTRCount();
        
		SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
		scheduleData.SVMXC__Previous_Execution_Started_On__c = System.now().addMonths(-1);
        
        SPM_Account_Summary summary = new SPM_Account_Summary(scheduleData);
        System.assert(summary != null );
        Database.QueryLocator queryLocator = summary.start( null );
        List<SObject> records = Database.query( queryLocator.getQuery() );
        
        summary.execute(null, records);
        summary.finish( null );
        
        Test.stopTest();
	}
	
	private static void insertFTFProcess() {
	   SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__ProcessID__c = SPM_Schema.Report.FirstTimeFix.name();
        process.SVMXC__Name__c = 'First Time Fix';
        insert process;
        
	}

	
	/**
	 * Test cases with multiple scenarios.
	 **/
	private static testMethod void testWithNoFTF() {
    
        Test.startTest();
        
        setup();
        insertFTFProcess();
        
		SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
		scheduleData.SVMXC__Previous_Execution_Started_On__c = System.now().addMonths(-1);
        
        SPM_Account_Summary summary = new SPM_Account_Summary(scheduleData);
        System.assert(summary != null );
        Database.QueryLocator queryLocator = summary.start( null );
        List<SObject> records = Database.query( queryLocator.getQuery() );
        
        summary.execute(null, records);
        summary.finish( null );
        
        List<SVMXC__SPM_Account_Summary__c> summaryData = [select id, name, SVMXC__Account__c, SVMXC__Metrics_Description__c, 
	                                                     SVMXC__Metric_Value__c from SVMXC__SPM_Account_Summary__c where 
	                                                     SVMXC__Configuration_Name__c IN ('First Time Fix') ];
        System.assert(summaryData.size() == 0);
        
        Test.stopTest();
	}
	
	private static void insertDataForFTFWithExistingSummary() {
	    
	    Account account1 = new Account();
        account1.Name = 'Tesla';
        insert account1;
        
    
        SVMXC__SPM_First_Time_Fix__c firstTimeFix = new SVMXC__SPM_First_Time_Fix__c();
        Date closedOn = System.today(); //.addDays(-1); //(Datetime) getSourceObjectFieldValue(record, SPM_Schema.Field.ClosedOn );
        closedOn = Date.newInstance(closedOn.year(), closedOn.month(), 1);
        
        firstTimeFix.SVMXC__Fixed_On__c = closedOn;
        firstTimeFix.SVMXC__Account__c = account1.Id;
        firstTimeFix.SVMXC__Configuration_Name__c = 'CN-0003798941';
        firstTimeFix.SVMXC__Calculation_Method__c = 'SPMFTF: Work Order Expression';
        firstTimeFix.SVMXC__Is_Fixed_First_Time__c = true;
        insert firstTimeFix;
        
	    
	    SVMXC__SPM_Account_Summary__c sobj = new SVMXC__SPM_Account_Summary__c();
        sobj.SVMXC__Account__c = account1.Id;                        // Account
        sobj.SVMXC__Start_Date__c = closedOn;                        // Start Date
        //SVMXC__End_Date__c = Date.valueOf('6-30-2016'),                  // End Date
        sobj.SVMXC__Total_Record_Count__c = 1;                                // Total Record Count
        sobj.SVMXC__Value__c = 0;                                         // Sum of Value/Valid Count
        sobj.SVMXC__Metric_Value__c = 0;                                   // Metric Value
        sobj.SVMXC__Unit__c = 'Percent';                                      // Unit
        sobj.SVMXC__Metrics_Description__c = 'FTF for Indian Region';             // Metrics Description
        sobj.SVMXC__Configuration_Name__c = 'CN-0003798941';                  // Configuration Name
        sobj.SVMXC__Calculation_Method__c = 'SPMFTF: Work Order Expression';  // Calculation Method
        insert sobj;
        

	} 
	
	/**
	 * Test cases with multiple scenarios.
	 **/
	private static testMethod void testWithExistingFTF() {
    
        Test.startTest();
        
        setup();
        insertFTFProcess();
        insertDataForFTFWithExistingSummary();
        
		SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
		scheduleData.SVMXC__Previous_Execution_Started_On__c = System.now().addMonths(-1);
        
        SPM_Account_Summary summary = new SPM_Account_Summary(scheduleData);
        System.assert(summary != null );
        Database.QueryLocator queryLocator = summary.start( null );
        List<SObject> records = Database.query( queryLocator.getQuery() );
        
        summary.execute(null, records);
        summary.finish( null );
        
        List<SVMXC__SPM_Account_Summary__c> summaryData = [select id, name, SVMXC__Account__c, SVMXC__Metrics_Description__c, SVMXC__Total_Record_Count__c,SVMXC__Value__c,
	                                                     SVMXC__Metric_Value__c from SVMXC__SPM_Account_Summary__c where 
	                                                     SVMXC__Configuration_Name__c IN ('CN-0003798941') ];
        //System.assert(summaryData.size() == 1);
        System.assertEquals(summaryData.size(), 1, 'Expected and Actual Data size is not matching - '+summaryData.size());
        
        System.assertEquals(summaryData.get(0).SVMXC__Metric_Value__c, 50, 'Expected and Actual Metric value is not matching - ' + summaryData.get(0).SVMXC__Metric_Value__c);
        System.assertEquals(summaryData.get(0).SVMXC__Value__c, 1, 'Expected and Actual Valid Record count is not matching - ' + summaryData.get(0).SVMXC__Value__c);
        System.assertEquals(summaryData.get(0).SVMXC__Total_Record_Count__c, 2, 'Expected and Actual Total Record count is not matching - ' + summaryData.get(0).SVMXC__Total_Record_Count__c);
        
        Test.stopTest();
	}
	
	
	private static void insertDataForFTFWithExistingSummaryForMultipleCalculation() {
	    
	    Account account1 = new Account();
        account1.Name = 'Tesla';
        insert account1;
        
    
        SVMXC__SPM_First_Time_Fix__c firstTimeFix = new SVMXC__SPM_First_Time_Fix__c();
        Date closedOn = System.today(); //.addDays(-1); //(Datetime) getSourceObjectFieldValue(record, SPM_Schema.Field.ClosedOn );
        closedOn = Date.newInstance(closedOn.year(), closedOn.month(), 1);
        
        firstTimeFix.SVMXC__Fixed_On__c = closedOn;
        firstTimeFix.SVMXC__Account__c = account1.Id;
        firstTimeFix.SVMXC__Configuration_Name__c = 'CN-0003798941';
        firstTimeFix.SVMXC__Calculation_Method__c = 'SPMFTF: Work Order Expression';
        firstTimeFix.SVMXC__Is_Fixed_First_Time__c = true;
        insert firstTimeFix;
        
	    
        SVMXC__SPM_Account_Summary__c sobj = new SVMXC__SPM_Account_Summary__c();
        sobj.SVMXC__Account__c = account1.Id;                        // Account
        sobj.SVMXC__Start_Date__c = closedOn;                        // Start Date
        sobj.SVMXC__Total_Record_Count__c = 1;                                // Total Record Count
        sobj.SVMXC__Value__c = 0;                                         // Sum of Value/Valid Count
        sobj.SVMXC__Metric_Value__c = 0;                                   // Metric Value
        sobj.SVMXC__Unit__c = 'Percent';                                      // Unit
        sobj.SVMXC__Metrics_Description__c = 'FTF for Indian Region';             // Metrics Description
        sobj.SVMXC__Configuration_Name__c = 'CN-0003798941';                  // Configuration Name
        sobj.SVMXC__Calculation_Method__c = 'SPMFTF: Work Order Expression';  // Calculation Method
        insert sobj;
        
        sobj = new SVMXC__SPM_Account_Summary__c();
        sobj.SVMXC__Account__c = account1.Id;                        // Account
        sobj.SVMXC__Start_Date__c = closedOn;                        // Start Date
        sobj.SVMXC__Total_Record_Count__c = 1;                                // Total Record Count
        sobj.SVMXC__Value__c = 0;                                         // Sum of Value/Valid Count
        sobj.SVMXC__Metric_Value__c = 0;                                   // Metric Value
        sobj.SVMXC__Unit__c = 'Percent';                                      // Unit
        sobj.SVMXC__Metrics_Description__c = 'FTF for UK Region';             // Metrics Description
        sobj.SVMXC__Configuration_Name__c = 'CN-0003798942';                  // Configuration Name
        sobj.SVMXC__Calculation_Method__c = 'SPMFTF: Work Order Expression';  // Calculation Method
        insert sobj;
	} 
	
	/**
	 * Test cases with multiple scenarios.
	 **/
	private static testMethod void testWithExistingFTFForMultipleCalculation() {
    
        Test.startTest();
        
        setup();
        insertFTFProcess();
        insertDataForFTFWithExistingSummaryForMultipleCalculation();
        
		SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
		scheduleData.SVMXC__Previous_Execution_Started_On__c = System.now().addMonths(-1);
        
        SPM_Account_Summary summary = new SPM_Account_Summary(scheduleData);
        System.assert(summary != null );
        Database.QueryLocator queryLocator = summary.start( null );
        List<SObject> records = Database.query( queryLocator.getQuery() );
        
        summary.execute(null, records);
        summary.finish( null );
        
        List<SVMXC__SPM_Account_Summary__c> summaryData = [select id, name, SVMXC__Account__c, SVMXC__Metrics_Description__c, SVMXC__Total_Record_Count__c,SVMXC__Value__c,
	                                                     SVMXC__Metric_Value__c from SVMXC__SPM_Account_Summary__c where 
	                                                     SVMXC__Configuration_Name__c IN ('CN-0003798941', 'CN-0003798942') order by  SVMXC__Configuration_Name__c];
        //System.assert(summaryData.size() == 1);
        System.assertEquals(summaryData.size(), 2, 'Expected and Actual Data size is not matching - '+summaryData.size());
        
        System.assertEquals(summaryData.get(0).SVMXC__Metric_Value__c, 50, 'Expected and Actual Metric value is not matching - ' + summaryData.get(0).SVMXC__Metric_Value__c);
        System.assertEquals(summaryData.get(0).SVMXC__Value__c, 1, 'Expected and Actual Valid Record count is not matching - ' + summaryData.get(0).SVMXC__Value__c);
        System.assertEquals(summaryData.get(0).SVMXC__Total_Record_Count__c, 2, 'Expected and Actual Total Record count is not matching - ' + summaryData.get(0).SVMXC__Total_Record_Count__c);
        
        Test.stopTest();
	}
	
	//Test for different scenarios for Repeat Visit
    
    private static void insertRepeatVisitProcess() {
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__ProcessID__c = SPM_Schema.Report.RepeatVisit.name();
        process.SVMXC__Name__c = 'Repeat Visit';
        insert process;
	}

	
	/**
	 * Test cases with multiple scenarios.
	 **/
	private static testMethod void testWithNoRepeatVisit() {
        Test.startTest();
        setup();
        insertRepeatVisitProcess();
		SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
		scheduleData.SVMXC__Previous_Execution_Started_On__c = System.now().addMonths(-1);
        SPM_Account_Summary summary = new SPM_Account_Summary(scheduleData);
        System.assert(summary != null );
        Database.QueryLocator queryLocator = summary.start( null );
        List<SObject> records = Database.query( queryLocator.getQuery() );
        summary.execute(null, records);
        summary.finish( null );
        List<SVMXC__SPM_Account_Summary__c> summaryData = [select id, name, SVMXC__Account__c, SVMXC__Metrics_Description__c, 
	                                                     SVMXC__Metric_Value__c from SVMXC__SPM_Account_Summary__c];
        System.assert(summaryData.size() == 0);
        Test.stopTest();
	}
	
	private static void insertDataForRepeatVisitWithExistingSummary() {
	    
	    Account account1 = new Account();
        account1.Name = 'Tesla';
        insert account1;
        
    
        SVMXC__SPM_Repeat_Visit__c metricObject = new SVMXC__SPM_Repeat_Visit__c();
        Date tempDate = System.today(); 
        tempDate = Date.newInstance(tempDate.year(), tempDate.month(), 1);
        
        metricObject.SVMXC__First_Incident_On__c = tempDate;
        metricObject.SVMXC__Account__c = account1.Id;
        metricObject.SVMXC__Configuration_Name__c = 'CN-0003798941';
        metricObject.SVMXC__Calculation_Method__c = 'SPMRECALL: Standard';
        metricObject.SVMXC__Subsequent_Incident_On__c = tempDate;
        insert metricObject;
        
	    
	    SVMXC__SPM_Account_Summary__c sobj = new SVMXC__SPM_Account_Summary__c();
        sobj.SVMXC__Account__c = account1.Id;                        // Account
        sobj.SVMXC__Start_Date__c = tempDate;      
        sobj.SVMXC__Total_Record_Count__c = 1;                                // Total Record Count
        sobj.SVMXC__Value__c = 0;                                         // Sum of Value/Valid Count
        sobj.SVMXC__Metric_Value__c = 0;                                   // Metric Value
        sobj.SVMXC__Unit__c = 'Percent';                                      // Unit
        sobj.SVMXC__Metrics_Description__c = 'Repeat Visit for Indian Region';             // Metrics Description
        sobj.SVMXC__Configuration_Name__c = 'CN-0003798941';                  // Configuration Name
        sobj.SVMXC__Calculation_Method__c = 'SPMRECALL: Standard';  // Calculation Method
        insert sobj;
        

	} 
	
	/**
	 * Test cases with multiple scenarios.
	 **/
	private static testMethod void testWithExistingRepeatVisit() {
    
        Test.startTest();
        
        setup();
        insertRepeatVisitProcess();
        insertDataForRepeatVisitWithExistingSummary();
        
		SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
		scheduleData.SVMXC__Previous_Execution_Started_On__c = System.now().addMonths(-1);
        
        SPM_Account_Summary summary = new SPM_Account_Summary(scheduleData);
        System.assert(summary != null );
        Database.QueryLocator queryLocator = summary.start( null );
        List<SObject> records = Database.query( queryLocator.getQuery() );
        
        summary.execute(null, records);
        summary.finish( null );
        
        List<SVMXC__SPM_Account_Summary__c> summaryData = [select id, name, SVMXC__Account__c, SVMXC__Metrics_Description__c, SVMXC__Total_Record_Count__c,SVMXC__Value__c,
	                                                     SVMXC__Metric_Value__c from SVMXC__SPM_Account_Summary__c where 
	                                                     SVMXC__Configuration_Name__c IN ('CN-0003798941') ];
        //System.assert(summaryData.size() == 1);
        System.assertEquals(summaryData.size(), 1, 'Expected and Actual Data size is not matching - '+summaryData.size());
        
        System.assertEquals(summaryData.get(0).SVMXC__Metric_Value__c, 100, 'Expected and Actual Metric value is not matching - ' + summaryData.get(0).SVMXC__Metric_Value__c);
        System.assertEquals(summaryData.get(0).SVMXC__Value__c, 1, 'Expected and Actual Valid Record count is not matching - ' + summaryData.get(0).SVMXC__Value__c);
        System.assertEquals(summaryData.get(0).SVMXC__Total_Record_Count__c, 1, 'Expected and Actual Total Record count is not matching - ' + summaryData.get(0).SVMXC__Total_Record_Count__c);
        
        Test.stopTest();
	}
	
	
	private static void insertDataForRepeatVisitWithExistingSummaryForMultipleCalculation() {
	    
	    Account account1 = new Account();
        account1.Name = 'Tesla';
        insert account1;
        
        SVMXC__SPM_Repeat_Visit__c metricObject = new SVMXC__SPM_Repeat_Visit__c();
        Date tempDate = System.today(); 
        tempDate = Date.newInstance(tempDate.year(), tempDate.month(), 1);
        
        metricObject.SVMXC__First_Incident_On__c = tempDate;
        metricObject.SVMXC__Account__c = account1.Id;
        metricObject.SVMXC__Configuration_Name__c = 'CN-0003798941';
        metricObject.SVMXC__Calculation_Method__c = 'SPMRECALL: Standard';
        metricObject.SVMXC__Subsequent_Incident_On__c = tempDate;
        //metricObject.SVMXC__Is_Repeat_Visit__c = true;
        insert metricObject;
        
	    
	    SVMXC__SPM_Account_Summary__c sobj = new SVMXC__SPM_Account_Summary__c();
        sobj.SVMXC__Account__c = account1.Id;                        // Account
        sobj.SVMXC__Start_Date__c = tempDate;                        // Start Date
        sobj.SVMXC__Total_Record_Count__c = 1;                                // Total Record Count
        sobj.SVMXC__Value__c = 0;                                         // Sum of Value/Valid Count
        sobj.SVMXC__Metric_Value__c = 0;                                   // Metric Value
        sobj.SVMXC__Unit__c = 'Percent';                                      // Unit
        sobj.SVMXC__Metrics_Description__c = 'Repeat Visit for Indian Region';             // Metrics Description
        sobj.SVMXC__Configuration_Name__c = 'CN-0003798941';                  // Configuration Name
        sobj.SVMXC__Calculation_Method__c = 'SPMRECALL: Standard';  // Calculation Method
        insert sobj;
        
        sobj = new SVMXC__SPM_Account_Summary__c();
        sobj.SVMXC__Account__c = account1.Id;                        // Account
        sobj.SVMXC__Start_Date__c = tempDate;                        // Start Date
        sobj.SVMXC__Total_Record_Count__c = 1;                                // Total Record Count
        sobj.SVMXC__Value__c = 0;                                         // Sum of Value/Valid Count
        sobj.SVMXC__Metric_Value__c = 0;                                   // Metric Value
        sobj.SVMXC__Unit__c = 'Percent';                                      // Unit
        sobj.SVMXC__Metrics_Description__c = 'Repeat Visit for UK Region';             // Metrics Description
        sobj.SVMXC__Configuration_Name__c = 'CN-0003798942';                  // Configuration Name
        sobj.SVMXC__Calculation_Method__c = 'SPMRECALL: Standard';  // Calculation Method
        insert sobj;
	} 
	
	/**
	 * Test cases with multiple scenarios.
	 **/
	private static testMethod void testWithExistingRepeatVisitForMultipleCalculation() {
    
        Test.startTest();
        
        setup();
        insertRepeatVisitProcess();
        insertDataForRepeatVisitWithExistingSummaryForMultipleCalculation();
        
		SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
		scheduleData.SVMXC__Previous_Execution_Started_On__c = System.now().addMonths(-1);
        
        SPM_Account_Summary summary = new SPM_Account_Summary(scheduleData);
        System.assert(summary != null );
        Database.QueryLocator queryLocator = summary.start( null );
        List<SObject> records = Database.query( queryLocator.getQuery() );
        
        summary.execute(null, records);
        summary.finish( null );
        
        List<SVMXC__SPM_Account_Summary__c> summaryData = [select id, name, SVMXC__Account__c, SVMXC__Metrics_Description__c, SVMXC__Total_Record_Count__c,SVMXC__Value__c,
	                                                     SVMXC__Metric_Value__c from SVMXC__SPM_Account_Summary__c where 
	                                                     SVMXC__Configuration_Name__c IN ('CN-0003798941', 'CN-0003798942') order by  SVMXC__Configuration_Name__c];
        //System.assert(summaryData.size() == 1);
        System.assertEquals(summaryData.size(), 2, 'Expected and Actual Data size is not matching - '+summaryData.size());
        
        System.assertEquals(summaryData.get(0).SVMXC__Metric_Value__c, 100, 'Expected and Actual Metric value is not matching - ' + summaryData.get(0).SVMXC__Metric_Value__c);
        System.assertEquals(summaryData.get(0).SVMXC__Value__c, 1, 'Expected and Actual Valid Record count is not matching - ' + summaryData.get(0).SVMXC__Value__c);
        System.assertEquals(summaryData.get(0).SVMXC__Total_Record_Count__c, 1, 'Expected and Actual Total Record count is not matching - ' + summaryData.get(0).SVMXC__Total_Record_Count__c);
        
        Test.stopTest();
	}
	
    //Test cases for Attach Rate Flow
    /**
     * Inserts an entry for Attach Rate Flow aka Contract Penetration
     **/
    private static void insertAttachRateProcess() {
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__ProcessID__c = SPM_Schema.Report.ContractPenetration.name();
        process.SVMXC__Name__c = 'Contract Penetration';
        insert process;
	}

	
	/**
	 * Test cases with multiple scenarios.
	 **/
	private static testMethod void testWithNoAttachRate() {
        Test.startTest();
        setup();
        insertAttachRateProcess();
		SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
		scheduleData.SVMXC__Previous_Execution_Started_On__c = System.now().addMonths(-1);
        SPM_Account_Summary summary = new SPM_Account_Summary(scheduleData);
        System.assert(summary != null );
        Database.QueryLocator queryLocator = summary.start( null );
        List<SObject> records = Database.query( queryLocator.getQuery() );
        summary.execute(null, records);
        summary.finish( null );
        List<SVMXC__SPM_Account_Summary__c> summaryData = [select id, name, SVMXC__Account__c, SVMXC__Metrics_Description__c, 
	                                                     SVMXC__Metric_Value__c from SVMXC__SPM_Account_Summary__c];
        System.assert(summaryData.size() == 0);
        Test.stopTest();
	}
	
	private static void insertDataForAttachRateWithExistingSummary() {
	    
	    Account account1 = new Account();
        account1.Name = 'Tesla';
        insert account1;
        
    
        SVMXC__SPM_Contract_Penetration__c metricObject = new SVMXC__SPM_Contract_Penetration__c();
        Date tempDate = System.today(); 
        tempDate = Date.newInstance(tempDate.year(), tempDate.month(), 1);
        
        metricObject.SVMXC__Processed_On__c = tempDate;
        metricObject.SVMXC__Account__c = account1.Id;
        metricObject.SVMXC__Configuration_Name__c = 'CN-0003798941';
        metricObject.SVMXC__Calculation_Method__c = 'SPMCP: Validity Check';
        metricObject.SVMXC__Covered_By__c = 'Warrenty';
        insert metricObject;
        
	    
	    SVMXC__SPM_Account_Summary__c sobj = new SVMXC__SPM_Account_Summary__c();
        sobj.SVMXC__Account__c = account1.Id;                        // Account
        sobj.SVMXC__Start_Date__c = tempDate;      
        sobj.SVMXC__Total_Record_Count__c = 1;                                // Total Record Count
        sobj.SVMXC__Value__c = 0;                                         // Sum of Value/Valid Count
        sobj.SVMXC__Metric_Value__c = 0;                                   // Metric Value
        sobj.SVMXC__Unit__c = 'Percent';                                      // Unit
        sobj.SVMXC__Metrics_Description__c = 'Attach Rate for Indian Region';             // Metrics Description
        sobj.SVMXC__Configuration_Name__c = 'CN-0003798941';                  // Configuration Name
        sobj.SVMXC__Calculation_Method__c = 'SPMCP: Validity Check';  // Calculation Method
        insert sobj;
        

	} 
	
	/**
	 * Test cases with multiple scenarios.
	 **/
	private static testMethod void testWithExistingAttachRate() {
    
        Test.startTest();
        
        setup();
        insertAttachRateProcess();
        insertDataForAttachRateWithExistingSummary();
        
		SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
		scheduleData.SVMXC__Previous_Execution_Started_On__c = System.now().addMonths(-1);
        
        SPM_Account_Summary summary = new SPM_Account_Summary(scheduleData);
        System.assert(summary != null );
        Database.QueryLocator queryLocator = summary.start( null );
        List<SObject> records = Database.query( queryLocator.getQuery() );
        
        summary.execute(null, records);
        summary.finish( null );
        
       
        
        Test.stopTest();
	}
	
	
	private static void insertDataForAttachRateWithExistingSummaryForMultipleCalculation() {
	    
	    Account account1 = new Account();
        account1.Name = 'Tesla';
        insert account1;
        
 
        SVMXC__SPM_Contract_Penetration__c metricObject = new SVMXC__SPM_Contract_Penetration__c();
        Date tempDate = System.today(); 
        tempDate = Date.newInstance(tempDate.year(), tempDate.month(), 1);
        
        metricObject.SVMXC__Processed_On__c = tempDate;
        metricObject.SVMXC__Account__c = account1.Id;
        metricObject.SVMXC__Configuration_Name__c = 'CN-0003798941';
        metricObject.SVMXC__Calculation_Method__c = 'SPMCP: Validity Check';
        metricObject.SVMXC__Covered_By__c = 'Warrenty';
        insert metricObject;
        
	    
	    SVMXC__SPM_Account_Summary__c sobj = new SVMXC__SPM_Account_Summary__c();
        sobj.SVMXC__Account__c = account1.Id;                        // Account
        sobj.SVMXC__Start_Date__c = tempDate;                        // Start Date
        sobj.SVMXC__Total_Record_Count__c = 1;                                // Total Record Count
        sobj.SVMXC__Value__c = 0;                                         // Sum of Value/Valid Count
        sobj.SVMXC__Metric_Value__c = 0;                                   // Metric Value
        sobj.SVMXC__Unit__c = 'Percent';                                      // Unit
        sobj.SVMXC__Metrics_Description__c = 'Attach Rate for Indian Region';             // Metrics Description
        sobj.SVMXC__Configuration_Name__c = 'CN-0003798941';                  // Configuration Name
        sobj.SVMXC__Calculation_Method__c = 'SPMCP: Validity Check';  // Calculation Method
        insert sobj;
        
        sobj = new SVMXC__SPM_Account_Summary__c();
        sobj.SVMXC__Account__c = account1.Id;                        // Account
        sobj.SVMXC__Start_Date__c = tempDate;                        // Start Date
        sobj.SVMXC__Total_Record_Count__c = 1;                                // Total Record Count
        sobj.SVMXC__Value__c = 0;                                         // Sum of Value/Valid Count
        sobj.SVMXC__Metric_Value__c = 0;                                   // Metric Value
        sobj.SVMXC__Unit__c = 'Percent';                                      // Unit
        sobj.SVMXC__Metrics_Description__c = 'Attach Rate for UK Region';             // Metrics Description
        sobj.SVMXC__Configuration_Name__c = 'CN-0003798942';                  // Configuration Name
        sobj.SVMXC__Calculation_Method__c = 'SPMCP: Validity Check';  // Calculation Method
        insert sobj;
	} 
	
	/**
	 * Test cases with multiple scenarios.
	 **/
	private static testMethod void testWithExistingAttachRateForMultipleCalculation() {
    
        Test.startTest();
        
        setup();
        insertAttachRateProcess();
        insertDataForAttachRateWithExistingSummaryForMultipleCalculation();
        
		SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
		scheduleData.SVMXC__Previous_Execution_Started_On__c = System.now().addMonths(-1);
        
        SPM_Account_Summary summary = new SPM_Account_Summary(scheduleData);
        System.assert(summary != null );
        Database.QueryLocator queryLocator = summary.start( null );
        List<SObject> records = Database.query( queryLocator.getQuery() );
        
        summary.execute(null, records);
        summary.finish( null );
        
        List<SVMXC__SPM_Account_Summary__c> summaryData = [select id, name, SVMXC__Account__c, SVMXC__Metrics_Description__c, SVMXC__Total_Record_Count__c,SVMXC__Value__c,
	                                                     SVMXC__Metric_Value__c from SVMXC__SPM_Account_Summary__c where 
	                                                     SVMXC__Configuration_Name__c IN ('CN-0003798941', 'CN-0003798942') order by  SVMXC__Configuration_Name__c];
        //System.assert(summaryData.size() == 1);
        System.assertEquals(summaryData.size(), 2, 'Expected and Actual Data size is not matching - '+summaryData.size());
        
        System.assertEquals(summaryData.get(0).SVMXC__Metric_Value__c, 100, 'Expected and Actual Metric value is not matching - ' + summaryData.get(0).SVMXC__Metric_Value__c);
        System.assertEquals(summaryData.get(0).SVMXC__Value__c, 1, 'Expected and Actual Valid Record count is not matching - ' + summaryData.get(0).SVMXC__Value__c);
        System.assertEquals(summaryData.get(0).SVMXC__Total_Record_Count__c, 1, 'Expected and Actual Total Record count is not matching - ' + summaryData.get(0).SVMXC__Total_Record_Count__c);
        
        Test.stopTest();
	}
	
    //Test cases for Contract Uptime Flow
    /**
     * Inserts an entry for Contract Uptime Flow
     **/
    private static void insertContractUptimeProcess() {
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__ProcessID__c = SPM_Schema.Report.UpDownTime.name();
        process.SVMXC__Name__c = 'Contract Uptime';
        insert process;
	}

	
	/**
	 * Test cases with multiple scenarios.
	 **/
	private static testMethod void testWithNoContractUptime() {
        Test.startTest();
        setup();
        insertContractUptimeProcess();
		SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
		scheduleData.SVMXC__Previous_Execution_Started_On__c = System.now().addMonths(-1);
        SPM_Account_Summary summary = new SPM_Account_Summary(scheduleData);
        System.assert(summary != null );
        Database.QueryLocator queryLocator = summary.start( null );
        List<SObject> records = Database.query( queryLocator.getQuery() );
        summary.execute(null, records);
        summary.finish( null );
        List<SVMXC__SPM_Account_Summary__c> summaryData = [select id, name, SVMXC__Account__c, SVMXC__Metrics_Description__c, 
	                                                     SVMXC__Metric_Value__c from SVMXC__SPM_Account_Summary__c];
        System.assert(summaryData.size() == 0);
        Test.stopTest();
	}
	
	private static void insertDataForContractUptimeWithExistingSummary() {
	    
	    Account account1 = new Account();
        account1.Name = 'Tesla';
        insert account1;
        
    
        SVMXC__SPM_Contract_Up_Time__c metricObject = new SVMXC__SPM_Contract_Up_Time__c();
        Date tempDate = System.today(); 
        //tempDate = Date.newInstance(tempDate.year(), tempDate.month(), 1);
        
        metricObject.SVMXC__Start_Date__c = tempDate;
        metricObject.SVMXC__Account__c = account1.Id;
        metricObject.SVMXC__Gauranteed_Up_Time__c = 1000;
        //metricObject.SVMXC__Total_Down_Time__c = 400;
        metricObject.SVMXC__Configuration_Name__c = 'CN-0003798941';
        metricObject.SVMXC__Calculation_Method__c = 'SPM Contract Up Time';
        insert metricObject;
        
	    
	    SVMXC__SPM_Account_Summary__c sobj = new SVMXC__SPM_Account_Summary__c();
        sobj.SVMXC__Account__c = account1.Id;                        // Account
        sobj.SVMXC__Start_Date__c = tempDate;      
        sobj.SVMXC__Total_Record_Count__c = 1;                                // Total Record Count
        sobj.SVMXC__Value__c = 1000;                                         // Sum of Value/Valid Count
        sobj.SVMXC__Metric_Value__c = 100;                                   // Metric Value
        sobj.SVMXC__Unit__c = 'Percent';                                      // Unit
        sobj.SVMXC__Metrics_Description__c = 'Contract uptime for Indian Region';             // Metrics Description
        sobj.SVMXC__Configuration_Name__c = 'CN-0003798941';                  // Configuration Name
        sobj.SVMXC__Calculation_Method__c = 'SPMCP: Validity Check';  // Calculation Method
        insert sobj;
        

	} 
	
	/**
	 * Test cases with multiple scenarios.
	 **/
	private static testMethod void testWithExistingContractUptime() {
    
        Test.startTest();
        
        setup();
        insertContractUptimeProcess();
        insertDataForContractUptimeWithExistingSummary();
        
		SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
		scheduleData.SVMXC__Previous_Execution_Started_On__c = System.now().addMonths(-1);
        
        SPM_Account_Summary summary = new SPM_Account_Summary(scheduleData);
        System.assert(summary != null );
        Database.QueryLocator queryLocator = summary.start( null );
        List<SObject> records = Database.query( queryLocator.getQuery() );
        
        summary.execute(null, records);
        summary.finish( null );
        
        List<SVMXC__SPM_Account_Summary__c> summaryData = [select id, name, SVMXC__Account__c, SVMXC__Metrics_Description__c, SVMXC__Total_Record_Count__c,SVMXC__Value__c,
	                                                     SVMXC__Metric_Value__c from SVMXC__SPM_Account_Summary__c where 
	                                                     SVMXC__Configuration_Name__c IN ('CN-0003798941') ];
        //System.assert(summaryData.size() == 1);
        System.assertEquals(summaryData.size(), 1, 'Expected and Actual Data size is not matching - '+summaryData.size());
        
        System.assertEquals(summaryData.get(0).SVMXC__Metric_Value__c, 100, 'Expected and Actual Metric value is not matching - ' + summaryData.get(0).SVMXC__Metric_Value__c);
        System.assertEquals(summaryData.get(0).SVMXC__Value__c, 1000, 'Expected and Actual Valid Record count is not matching - ' + summaryData.get(0).SVMXC__Value__c);
        System.assertEquals(summaryData.get(0).SVMXC__Total_Record_Count__c, 1, 'Expected and Actual Total Record count is not matching - ' + summaryData.get(0).SVMXC__Total_Record_Count__c);
        
        Test.stopTest();
	}
	
	
	private static void insertDataForContractUptimeWithExistingSummaryForMultipleCalculation() {
	    
	    Account account1 = new Account();
        account1.Name = 'Tesla';
        insert account1;
        
 
        SVMXC__SPM_Contract_Up_Time__c metricObject = new SVMXC__SPM_Contract_Up_Time__c();
        Date tempDate = System.today(); 
        //tempDate = Date.newInstance(tempDate.year(), tempDate.month(), 1);
        
        metricObject.SVMXC__Start_Date__c = tempDate;
        metricObject.SVMXC__Account__c = account1.Id;
        metricObject.SVMXC__Gauranteed_Up_Time__c = 1000;
        //metricObject.SVMXC__Total_Down_Time__c = 400;
        metricObject.SVMXC__Configuration_Name__c = 'CN-0003798941';
        metricObject.SVMXC__Calculation_Method__c = 'SPM Contract Up Time';
        insert metricObject;
        
	    
	    SVMXC__SPM_Account_Summary__c sobj = new SVMXC__SPM_Account_Summary__c();
        sobj.SVMXC__Account__c = account1.Id;                        // Account
        sobj.SVMXC__Start_Date__c = tempDate;                        // Start Date
        sobj.SVMXC__Total_Record_Count__c = 1;                                // Total Record Count
        sobj.SVMXC__Value__c = 1000;                                         // Sum of Value/Valid Count
        sobj.SVMXC__Metric_Value__c = 200;                                   // Metric Value
        sobj.SVMXC__Unit__c = 'Percent';                                      // Unit
        sobj.SVMXC__Metrics_Description__c = 'Contract uptime Indian Region';             // Metrics Description
        sobj.SVMXC__Configuration_Name__c = 'CN-0003798941';                  // Configuration Name
        sobj.SVMXC__Calculation_Method__c = 'SPMCP: Validity Check';  // Calculation Method
        insert sobj;
        
        sobj = new SVMXC__SPM_Account_Summary__c();
        sobj.SVMXC__Account__c = account1.Id;                        // Account
        sobj.SVMXC__Start_Date__c = tempDate;                        // Start Date
        sobj.SVMXC__Total_Record_Count__c = 1;                                // Total Record Count
        sobj.SVMXC__Value__c = 1000;                                         // Sum of Value/Valid Count
        sobj.SVMXC__Metric_Value__c = 600;                                   // Metric Value
        sobj.SVMXC__Unit__c = 'Percent';                                      // Unit
        sobj.SVMXC__Metrics_Description__c = 'Contract uptime for UK Region';             // Metrics Description
        sobj.SVMXC__Configuration_Name__c = 'CN-0003798942';                  // Configuration Name
        sobj.SVMXC__Calculation_Method__c = 'SPMCP: Validity Check';  // Calculation Method
        insert sobj;
	} 
	
	/**
	 * Test cases with multiple scenarios.
	 **/
	private static testMethod void testWithExistingContractUptimeForMultipleCalculation() {
    
        Test.startTest();
        
        setup();
        insertContractUptimeProcess();
        insertDataForContractUptimeWithExistingSummaryForMultipleCalculation();
        
		SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
		scheduleData.SVMXC__Previous_Execution_Started_On__c = System.now().addMonths(-1);
        
        SPM_Account_Summary summary = new SPM_Account_Summary(scheduleData);
        System.assert(summary != null );
        Database.QueryLocator queryLocator = summary.start( null );
        List<SObject> records = Database.query( queryLocator.getQuery() );
        
        summary.execute(null, records);
        summary.finish( null );
        
        List<SVMXC__SPM_Account_Summary__c> summaryData = [select id, name, SVMXC__Account__c, SVMXC__Metrics_Description__c, SVMXC__Total_Record_Count__c,SVMXC__Value__c,
	                                                     SVMXC__Metric_Value__c from SVMXC__SPM_Account_Summary__c where 
	                                                     SVMXC__Configuration_Name__c IN ('CN-0003798941', 'CN-0003798942') order by  SVMXC__Configuration_Name__c];
        //System.assert(summaryData.size() == 1);
        System.assertEquals(summaryData.size(), 2, 'Expected and Actual Data size is not matching - '+summaryData.size());
        
        System.assertEquals(summaryData.get(0).SVMXC__Metric_Value__c, 100, 'Expected and Actual Metric value is not matching - ' + summaryData.get(0).SVMXC__Metric_Value__c);
        System.assertEquals(summaryData.get(0).SVMXC__Value__c, 1000, 'Expected and Actual Valid Record count is not matching - ' + summaryData.get(0).SVMXC__Value__c);
        System.assertEquals(summaryData.get(0).SVMXC__Total_Record_Count__c, 1, 'Expected and Actual Total Record count is not matching - ' + summaryData.get(0).SVMXC__Total_Record_Count__c);
        
        Test.stopTest();
	}
	


}