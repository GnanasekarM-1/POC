@isTest
global class SPM_ContractPenetration_UT {
    
    private static RecordType spmRuleRecordType;
    private static RecordType spmDetailsRecordType;
    
    static testMethod void testConstructor() {
        
        Test.startTest();
        
        setup();
        
        Id processId = insertProcess();
        insertConfigData( processId );
        insertIBWithServiceContractAndWarranty();
        
        SPM_ContractPenetration contractPenetration = new SPM_ContractPenetration(null);
        System.assert(contractPenetration != null );
        
        Database.QueryLocator queryLocator = contractPenetration.start( null );
        System.assert( queryLocator != null );
        
        List<SObject> records = Database.query( queryLocator.getQuery() );
        
        contractPenetration.execute(null, records);
        contractPenetration.execute(null, records);
        
        contractPenetration.finish( null );
        
        Test.stopTest();
    }
	static testMethod void test_with_TrendingEnabled_Setting() {
        
        Test.startTest();
        
        setup();
        
        Id processId = insertProcess();
        insertConfigData( processId );
        insertIBWithServiceContractAndWarranty();
        
        SPM_ContractPenetration contractPenetration = new SPM_ContractPenetration(null);
		contractPenetration.isTrendingEnabled=true;
        System.assert(contractPenetration != null );
        
        Database.QueryLocator queryLocator = contractPenetration.start( null );
        System.assert( queryLocator != null );
        
        List<SObject> records = Database.query( queryLocator.getQuery() );
        
        contractPenetration.execute(null, records);
        contractPenetration.execute(null, records);
        
        contractPenetration.finish( null );
        
        Test.stopTest();
    }
    
    static testMethod void testConstructor_With_Schedule() {
        
        Test.startTest();
        
        setup();
        
        Id processId = insertProcess();
        insertConfigData( processId );
        insertIBWithServiceContractAndWarranty();

		SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
		scheduleData.SVMXC__Previous_Execution_Started_On__c = System.now().addMonths(-1);
        
        SPM_ContractPenetration contractPenetration = new SPM_ContractPenetration(scheduleData);
        System.assert(contractPenetration != null );
        
        Database.QueryLocator queryLocator = contractPenetration.start( null );
        System.assert( queryLocator != null );
        
        List<SObject> records = Database.query( queryLocator.getQuery() );
        
        contractPenetration.execute(null, records);
        contractPenetration.execute(null, records);
        
        contractPenetration.finish( null );
        
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
    
    private static void insertIBWithServiceContractAndWarranty() {
        
        Account company = new Account();
        company.Name = 'Account Name';
        insert company;
        
        Product2 product = new Product2();
        product.Name = 'Product Name';
        product.IsActive = true;
        insert product;
        
        BusinessHours defaultBusinessHours = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1];
        
        SVMXC__Service_Contract__c contract = new SVMXC__Service_Contract__c();
        contract.Name = 'New SPM Service Contract '+Math.round(Math.random()*500);
        contract.SVMXC__Active__c = true;
        contract.SVMXC__Company__c = company.id;
        contract.SVMXC__Start_Date__c = System.today().addDays(-40);
        contract.SVMXC__End_Date__c = System.today().addDays(Math.round(Math.random()*30));
        contract.SVMXC__Business_Hours__c = defaultBusinessHours.Id;
        insert contract;
        
        SVMXC__Installed_Product__c installProduct = new SVMXC__Installed_Product__c();
        installProduct.Name = 'IB00'+Math.round(Math.random()*30);
        installProduct.SVMXC__Product__c = product.id;
        installProduct.SVMXC__Status__c = 'Installed';
        installProduct.SVMXC__Company__c = company.id;
        installProduct.SVMXC__Serial_Lot_Number__c = 'SN000'+Math.round(Math.random()*30);
        installProduct.SVMXC__Date_Installed__c = System.today();
        insert installProduct;
        
        SVMXC__Service_Contract_Products__c coveredProduct = new SVMXC__Service_Contract_Products__c ();
        coveredProduct.SVMXC__Service_Contract__c = contract.id;
        coveredProduct.SVMXC__Installed_Product__c = installProduct.id;
        coveredProduct.SVMXC__Start_Date__c = contract.SVMXC__Start_Date__c;
        coveredProduct.SVMXC__End_Date__c = contract.SVMXC__End_Date__c;
        insert coveredProduct;
        
        SVMXC__Service_Order__c serviceOrder = new SVMXC__Service_Order__c();
        serviceOrder.SVMXC__Product__c = product.Id;
        serviceOrder.SVMXC__Company__c = company.Id;
        serviceOrder.SVMXC__Top_Level__c = installProduct.id;
        serviceOrder.SVMXC__Component__c = installProduct.id;
        serviceOrder.SVMXC__Service_Contract__c = contract.id;
        insert serviceOrder;
                
        SVMXC__Warranty__c warranty = new SVMXC__Warranty__c();
        warranty.SVMXC__Installed_Product__c = installProduct.Id;
        //insert warranty;
    }
    
    private static Id insertProcess() {
        
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__ProcessID__c = SPM_Schema.Report.ContractPenetration.name();
        process.SVMXC__Name__c = 'Contract Penetration';
        
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
        calculationMethod.replace( 'a10F0000006AhEQIA0', configData.Id );
        
    }
    
    private static String calculationMethod = '{"sourceObjectName":"SVMXC__Installed_Product__c","recordId":"a10F0000006AhEQIA0","parameterInfoList":[{"sourceObjectName":null,"sourceObjectField":"Account","sourceFieldName":"SVMXC__Company__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"Account","label":"Choose the field to consolidate by Account","displayType":"REFERENCE"}],"name":null,"methodDisplayName":null,"method":"SPMCP: Validity Check","lastModifiedOn":"11/10/2015 10:15 PM","expressionDetailsList":[{"sourceObjectName":null,"label":"Choose an expression to qualify records for the metrics generation","expressionType":"QualificationCriteria","expressionRuleList":null,"expressionRuleId":"Account_not_null._Date_instaled_today"}],"appliesTo":"This is the default configuration for the Contract Penetration metrics generation."}';
}