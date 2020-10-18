@isTest
global class SPM_MeanTimeToComplete_UT {
    
    private static RecordType spmRuleRecordType;
    private static RecordType spmDetailsRecordType;
    
    static testMethod void testConstructor() {
        
        Test.startTest();
        
        setup();
        
        Id processId = insertProcess();
        insertConfigData( processId );
        insertWorkOrderAndWorkDetails();
        
        SPM_MeanTimeToComplete meanTimeToRepair = new SPM_MeanTimeToComplete(null);
        System.assert(meanTimeToRepair != null );
        
        Database.QueryLocator queryLocator = meanTimeToRepair.start( null );
        System.assert( queryLocator != null );
        
        List<SObject> records = Database.query( queryLocator.getQuery() );
        
        meanTimeToRepair.execute(null, records);
        meanTimeToRepair.execute(null, records);
        
        meanTimeToRepair.finish( null );
        
        Test.stopTest();
    }
    
    static testMethod void testConstructor_With_Schedule() {
        
        Test.startTest();
        
        setup();
        
        Id processId = insertProcess();
        insertConfigData( processId );
        insertWorkOrderAndWorkDetails();

        SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
        scheduleData.SVMXC__Previous_Execution_Started_On__c = System.now().addMonths(-1);
        
        SPM_MeanTimeToComplete meanTimeToComplete = new SPM_MeanTimeToComplete(scheduleData);
        System.assert(meanTimeToComplete != null );
        
        Database.QueryLocator queryLocator = meanTimeToComplete.start( null );
        System.assert( queryLocator != null );
        
        List<SObject> records = Database.query( queryLocator.getQuery() );
        System.debug('Query: ' + queryLocator.getQuery() );
        
        meanTimeToComplete.execute(null, records);
        //meanTimeToRepair.execute(null, records);
        
        meanTimeToComplete.finish( null );
        
        Test.stopTest();
    }
    
    private static void setup() {
        
        if( spmRuleRecordType == null ) {
            spmRuleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'SPM Rule'];    
        }
        
        if( spmDetailsRecordType == null ) {
            spmDetailsRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name = 'SPM Details'];    
        }        
    }
    
    private static void insertWorkOrderAndWorkDetails() {
        
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
        serviceOrder.SVMXC__Preferred_Start_Time__c = System.now().addDays(-1);
        serviceOrder.SVMXC__Service_Duration__c = 30; 
        serviceOrder.SVMXC__Driving_Time__c = 15;
        serviceOrder.SVMXC__Completed_Date_Time__c = System.today();
        //serviceOrder.SVMXC__Component__c = installedProductList.get(index).Id;
        serviceOrder.SVMXC__Product__c = pro.Id;
        serviceOrder.SVMXC__Company__c = acc.Id;
        
        insert serviceOrder;
        
        SVMXC__Service_Order_Line__c workDetail = new SVMXC__Service_Order_Line__c();
        workDetail.SVMXC__Actual_Quantity2__c = 2;
        workDetail.SVMXC__Service_Order__c = serviceOrder.Id;
        
        insert workDetail;
        
        workDetail = new SVMXC__Service_Order_Line__c();
        workDetail.SVMXC__Start_Date_and_Time__c = System.now().addMinutes(-60);
        workDetail.SVMXC__End_Date_and_Time__c = System.now();
        workDetail.SVMXC__Service_Order__c = serviceOrder.Id;
        
        insert workDetail;
    }
    
    private static Id insertProcess() {
        
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__ProcessID__c = SPM_Schema.Report.MeanTimeToComplete.name();
        process.SVMXC__Name__c = 'Mean Time To Complete';
        
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
        calculationMethod.replace( 'a10F0000005MgmvIAC', configData.Id );
        
    }
    
    private static String calculationMethod = '{"targetObjectName":"SVMXC__SPM_Mean_Time_To_Complete__c","targetObjectLabel":"SPM - Mean Time To Complete","sourceObjectName":"SVMXC__Service_Order__c","sourceObjectLabel":"Work Order","recordId":"a10F0000005MgmvIAC","parameterInfoList":[{"sourceObjectName":"SVMXC__Service_Order__c","sourceObjectField":"Technician","sourceFieldName":"SVMXC__Preferred_Technician__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"SVMXC__Service_Group_Members__c","label":"Select the source for the Technician field","isPicklistValue":false,"isMultiSelect":false,"displayType":"REFERENCE"},{"sourceObjectName":"SVMXC__Service_Order__c","sourceObjectField":"Product","sourceFieldName":"SVMXC__Product__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"Product2","label":"Select the source for the Product field","isPicklistValue":false,"isMultiSelect":false,"displayType":"REFERENCE"},{"sourceObjectName":null,"sourceObjectField":"CreatedDate","sourceFieldName":"CreatedDate","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":null,"label":"Select the source for the Service Created On Date field","isPicklistValue":false,"isMultiSelect":false,"displayType":"DATETIME"},{"sourceObjectName":null,"sourceObjectField":"CompletedDate","sourceFieldName":"SVMXC__Completed_Date_Time__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":null,"label":"Select the source for the Service Completed On Date field","isPicklistValue":false,"isMultiSelect":false,"displayType":"DATETIME"}],"name":"CN-0002238875","methodDisplayName":null,"method":"SPMMTTR: Sum of Labor Details","lastModifiedOn":"2/2/2016 11:52 AM","expressionDetailsList":[{"sourceObjectName":null,"label":"Select the expression to qualify work details for this metric","expressionType":"QualificationCriteria","expressionRuleList":null,"expressionRuleId":"EXPR100456"}],"appliesTo":"test"}';
     
}