@isTest
global class SPM_AverageResponseTime_UT{
    
    private static RecordType spmRuleRecordType;
    private static RecordType spmDetailsRecordType;
    
    static testMethod void testWithRecrods(){
        Test.startTest();
        setup();
        Id processId = insertProcess();
        insertConfigData(processId);
        insertWorkOrder();
        
        SPM_AverageResponseTime averageResponseTime = new SPM_AverageResponseTime(null);
        System.assert(averageResponseTime != null);
        
        Database.QueryLocator queryLocator = averageResponseTime.start( null );
        List<SObject> records = Database.query( queryLocator.getQuery() );
        
        averageResponseTime.execute(null, records);
        averageResponseTime.execute(null, records);
        
		averageResponseTime.finish(null);
        Test.stopTest();
    }
    
    static testMethod void testConstructor_With_Schedule(){
        Test.startTest();
        setup();
        Id processId = insertProcess();
        insertConfigData( processId );
        insertWorkOrder();

		SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
		scheduleData.SVMXC__Previous_Execution_Started_On__c = System.now().addMonths(-1);
        
        SPM_AverageResponseTime averageResponseTime = new SPM_AverageResponseTime(scheduleData);
        System.assert(averageResponseTime != null );
        
        Database.QueryLocator queryLocator = averageResponseTime.start( null );
        List<SObject> records = Database.query( queryLocator.getQuery() );
        
        averageResponseTime.execute(null, records);
        averageResponseTime.execute(null, records);
        
        averageResponseTime.finish( null );
        Test.stopTest();
    }
    
    private static void setup() {
        if(spmRuleRecordType == null){
        	spmRuleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'SPM Rule'];    
        }
        
        if(spmDetailsRecordType == null){
        	spmDetailsRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name = 'SPM Details'];    
        }        
    }
    
    private static void insertWorkOrder(){
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
        serviceOrder.SVMXC__Group_Member__c = technician.Id;
        serviceOrder.SVMXC__Closed_On__c = System.today().addDays(1);
        serviceOrder.SVMXC__Product__c = pro.Id;
        serviceOrder.SVMXC__Company__c = acc.Id;
		serviceOrder.SVMXC__Time_to_Initial_Response__c = 10;
        
        insert serviceOrder;
    }
    
    private static Id insertProcess() {
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__ProcessID__c = SPM_Schema.Report.AverageResponseTime.name();
        process.SVMXC__Name__c = 'Average Response Time';
        insert process;
        return process.Id;
    }
    
    private static void insertConfigData(Id processId){
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.RecordTypeId = spmDetailsRecordType.Id;
        configData.SVMXC__Dispatch_Process__c = processId;
        configData.SVMXC__Formula__c = calculationMethod;
        configData.SVMXC__Active__c = true;
        insert configData;
		
        calculationMethod = calculationMethod.replace( 'a10F0000005MsGJIA0', configData.Id );
		configData.SVMXC__Formula__c = calculationMethod;
        update configData;
    }
    
    private static String calculationMethod = '{"targetObjectName":"SVMXC__SPM_Average_Response_Time__c","targetObjectLabel":"SPM - Average Response Time","sourceObjectName":"SVMXC__Service_Order__c","sourceObjectLabel":"Work Order","recordId":"a10F0000005MsGJIA0","parameterInfoList":[{"sourceObjectName":"SVMXC__Service_Order__c","sourceObjectField":"Technician","sourceFieldName":"SVMXC__Group_Member__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"SVMXC__Service_Group_Members__c","label":"Select the source for the Technician field","isPicklistValue":false,"isMultiSelect":false,"displayType":"REFERENCE"},{"sourceObjectName":null,"sourceObjectField":"Account","sourceFieldName":"SVMXC__Company__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"Account","label":"Select the source for the Account field","isPicklistValue":false,"isMultiSelect":false,"displayType":"REFERENCE"},{"sourceObjectName":"SVMXC__Service_Order__c","sourceObjectField":"Product","sourceFieldName":"SVMXC__Product__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"Product2","label":"Select the source for the Product field","isPicklistValue":false,"isMultiSelect":false,"displayType":"REFERENCE"},{"sourceObjectName":null,"sourceObjectField":"ServiceDeliveredOn","sourceFieldName":"SVMXC__Closed_On__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":null,"label":"Select the source for the Service Delivered On Date field","isPicklistValue":false,"isMultiSelect":false,"displayType":"DATETIME"}],"objectMappingDetailsList":[],"name":"CN-0002278858","methodDisplayName":null,"method":"SPMART: Standard","lastModifiedOn":"2/12/2016 11:51 AM","isActive":true,"expressionDetailsList":[{"sourceObjectName":null,"label":"Select the expression to qualify work details for this metric","expressionType":"QualificationCriteria","expressionRuleList":null,"expressionRuleId":"EXPR060"}],"appliesTo":""}';  
}