@isTest
global class SPM_FirstTimeFix_UT {
    
    private static RecordType spmRuleRecordType;
    private static RecordType spmDetailsRecordType;
    
    static testMethod void testConstructor() {
        
        Test.startTest();
        
        setup();
        
        Id processId = insertProcess();
        insertConfigData( processId );
        insertWorkOrder();
        
        SPM_FirstTimeFix firstTimeFix = new SPM_FirstTimeFix(null);
        System.assert(firstTimeFix != null );
        
        Database.QueryLocator queryLocator = firstTimeFix.start( null );
        List<SObject> records = Database.query( queryLocator.getQuery() );
        
        firstTimeFix.execute(null, records);
        firstTimeFix.execute(null, records);
        
        firstTimeFix.finish( null );
        
        Test.stopTest();
    }
    
    static testMethod void testConstructor_With_Schedule() {
        
        Test.startTest();
        
        setup();
        
        Id processId = insertProcess();
        insertConfigData( processId );
        insertWorkOrder();

		SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
		scheduleData.SVMXC__Previous_Execution_Started_On__c = System.now().addMonths(-1);
        
        SPM_FirstTimeFix firstTimeFix = new SPM_FirstTimeFix(scheduleData);
        System.assert(firstTimeFix != null );
        
        Database.QueryLocator queryLocator = firstTimeFix.start( null );
        List<SObject> records = Database.query( queryLocator.getQuery() );
        
        firstTimeFix.execute(null, records);
        firstTimeFix.execute(null, records);
        
        firstTimeFix.finish( null );
        
        Test.stopTest();
    }
    static testMethod void testWithCaseAsTopLevel() {
        //Populate configuration and process table
        //Populate WO data with case as a reference 
        //Run the engine
    }
    
    static testMethod void testWithCaseAsTopLevelWithFollowupWOCheck() {
        //Populate configuration and process table
        //Populate WO data with case as a reference 
        //Run the engine
    }
    
    static testMethod void testWithCaseAsTopLevelWithWorkDetailsCheck() {
        //Populate configuration and process table
        //Populate WO data with case as a reference 
        //Run the engine
    }
    
    static testMethod void testWithWorkOrderAsTopLevel() {
        
    }
    
    static testMethod void testWithServiceRequestAsTopLevel() {
        
    }
    
    private static void setupBusinessConfigurationData() {
        
        String jsonInput = '';
        SVMXC__ServiceMax_Processes__c  newProcess = new SVMXC__ServiceMax_Processes__c();
        newProcess.SVMXC__Name__c='Business Process Config';
        newProcess.recordTypeId = spmRuleRecordType.Id;
        insert newProcess;
        
        SVMXC__ServiceMax_Config_Data__c newData = new SVMXC__ServiceMax_Config_Data__c();
        newData.SVMXC__Dispatch_Process__c = newProcess.Id;
        newData.SVMXC__Formula__c = jsonInput;
        newData.recordTypeId = spmDetailsRecordType.Id;
        insert newData;
        
    } 
        
    private static void setup() {
        
        if( spmRuleRecordType == null ) {
        	spmRuleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'SPM Rule'];    
        }
        
        if( spmDetailsRecordType == null ) {
        	spmDetailsRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name = 'SPM Details'];    
        }        
    }
    
    private static void insertWorkOrder() {
        
        SVMXC__Service_Group__c serviceTeam = new SVMXC__Service_Group__c();
        serviceTeam.Name = 'Team Name';
        
        insert serviceTeam;
        
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
		technician.Name = 'Team Member';
        technician.SVMXC__Service_Group__c = serviceTeam.Id;
        
        insert technician;
        
        Account acc = new Account();
        acc.Name = 'Account Name';
        
        insert acc;
        
        Product2 pro = new Product2();
        pro.Name = 'Product Name';
        
        insert pro;
        
        SVMXC__Service_Order__c serviceOrder = new SVMXC__Service_Order__c();
        serviceOrder.SVMXC__Preferred_Technician__c = technician.Id; 
        serviceOrder.SVMXC__Scheduled_Date__c = System.today().addDays(-1);
        serviceOrder.SVMXC__Scheduled_Date_Time__c = System.now().addDays(-1);
        serviceOrder.SVMXC__Service_Duration__c = 30; 
        serviceOrder.SVMXC__Driving_Time__c = 15;
        serviceOrder.SVMXC__Closed_On__c = System.today();
        //serviceOrder.SVMXC__Component__c = installedProductList.get(index).Id;
        serviceOrder.SVMXC__Product__c = pro.Id;
        serviceOrder.SVMXC__Company__c = acc.Id;
        
        insert serviceOrder;
    }
    
    private static Id insertProcess() {
        
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__ProcessID__c = SPM_Schema.Report.FirstTimeFix.name();
        process.SVMXC__Name__c = 'First Time Fix';
        
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
        calculationMethod.replace( 'a10F0000006AabmIAC', configData.Id );
        
    }
    
    private static String calculationMethod = '{"sourceObjectName":"SVMXC__Service_Order__c","recordId":"a10F0000006AabmIAC","parameterInfoList":[{"sourceObjectName":null,"sourceObjectField":"Account","sourceFieldName":"SVMXC__Company__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"Account","label":"Choose the field to consolidate by Account","displayType":"REFERENCE"},{"sourceObjectName":null,"sourceObjectField":"Technician","sourceFieldName":"SVMXC__Preferred_Technician__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"SVMXC__Service_Group_Members__c","label":"Choose the field to consolidate by Technician","displayType":"REFERENCE"},{"sourceObjectName":null,"sourceObjectField":"Product","sourceFieldName":"SVMXC__Product__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"Product2","label":"Choose the field to consolidate by Product","displayType":"REFERENCE"},{"sourceObjectName":null,"sourceObjectField":"ClosedOn","sourceFieldName":"SVMXC__Closed_On__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":null,"label":"Choose the field to consider as Fixed On date","displayType":"DATETIME"}],"name":null,"method":"Work Order As Source","lastModifiedOn":"11/7/2015 7:44 PM","expressionDetailsList":[{"sourceObjectName":"SVMXC__Service_Order__c","label":"Select the expression below, indicate how work order was first time fixed","expressionType":"CriteriaForFirstTimeFixed","expressionRuleList":null,"expressionRuleId":"a12F0000006jC45IAE"},{"sourceObjectName":null,"label":"Choose an expression to qualify records for the metrics generation","expressionType":"QualificationCriteria","expressionRuleList":null,"expressionRuleId":"a12F0000002KDmHIAW"}],"appliesTo":"This is the default configuration for the First Time Fix metrics generation."}';  
}