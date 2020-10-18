@isTest
global class SPM_MeanTimeBetweenFailure_UT {
    
    private static Id spmRuleRecordType;
    private static Id spmDetailsRecordType;
    
    
    
    static testMethod void testConstructor_With_Schedule() {
        
        Test.startTest();
        
        setup();
        
        Id processId = insertProcess();
        //insertConfigData( processId );
        
		

        SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
        scheduleData.SVMXC__Previous_Execution_Started_On__c = System.now().addMonths(-1);
		scheduleData.SVMXC__Previous_Execution_Completed_On__c=System.now().addMonths(-1);
		scheduleData.RecordTypeId = spmDetailsRecordType;
        scheduleData.SVMXC__Dispatch_Process__c = processId;
        scheduleData.SVMXC__Formula__c = calculationMethod;
        scheduleData.SVMXC__Active__c = true;
		insert scheduleData;
        List<SVMXC__ServiceMax_Config_Data__c> listserviceMaxConfigD=new List<SVMXC__ServiceMax_Config_Data__c>();
		listserviceMaxConfigD.add(scheduleData);
		insertIBWithServiceContractAndWarranty();
		
        SPM_MeanTimeBetweenFailure meanTimeBetweenFailure = new SPM_MeanTimeBetweenFailure(scheduleData);
        System.assert(meanTimeBetweenFailure != null );
        meanTimeBetweenFailure.listserviceMaxConfigData.addAll(listserviceMaxConfigD);
        Database.QueryLocator queryLocator = meanTimeBetweenFailure.start( null );
        System.assert( queryLocator != null );
        String queryString='SELECT Id,SVMXC__Company__c, SVMXC__Product__c, CreatedDate FROM SVMXC__Installed_Product__c LIMIT 1';
        List<SObject> records = Database.query( queryString );
        System.debug('Query: ' + queryLocator.getQuery() );
        meanTimeBetweenFailure.handleRecords(records);
        //meanTimeBetweenFailure.execute(null, records);
        meanTimeBetweenFailure.finish( null );
        
        Test.stopTest();
    }
	static testMethod void testConstructor_With_Downtime() {
        
        Test.startTest();
        
        setup();
        
        Id processId = insertProcess();
        //insertConfigData( processId );
        
		

        SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
        scheduleData.SVMXC__Previous_Execution_Started_On__c = System.now().addMonths(-1);
		scheduleData.SVMXC__Previous_Execution_Completed_On__c=System.now().addMonths(-1);
		scheduleData.RecordTypeId = spmDetailsRecordType;
        scheduleData.SVMXC__Dispatch_Process__c = processId;
        scheduleData.SVMXC__Formula__c = calculationMethod;
        scheduleData.SVMXC__Active__c = true;
		insert scheduleData;
        List<SVMXC__ServiceMax_Config_Data__c> listserviceMaxConfigD=new List<SVMXC__ServiceMax_Config_Data__c>();
		listserviceMaxConfigD.add(scheduleData);
		insertIBWithServiceContractAndWarranty2();
		
        SPM_MeanTimeBetweenFailure meanTimeBetweenFailure = new SPM_MeanTimeBetweenFailure(scheduleData);
        System.assert(meanTimeBetweenFailure != null );
        meanTimeBetweenFailure.listserviceMaxConfigData.addAll(listserviceMaxConfigD);
        Database.QueryLocator queryLocator = meanTimeBetweenFailure.start( null );
        System.assert( queryLocator != null );
        String queryString='SELECT Id,SVMXC__Company__c, SVMXC__Product__c, CreatedDate FROM SVMXC__Installed_Product__c LIMIT 1';
        List<SObject> records = Database.query( queryString );
        System.debug('Query: ' + queryLocator.getQuery() );
        meanTimeBetweenFailure.handleRecords(records);
        //meanTimeBetweenFailure.execute(null, records);
        meanTimeBetweenFailure.finish( null );
		
		
		
        Test.stopTest();
    }
	static testMethod void testConstructor_With_Schedule2() {
        
        Test.startTest();
        
        setup();
        
        Id processId = insertProcess();
        //insertConfigData( processId );
        

        SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
        scheduleData.SVMXC__Previous_Execution_Started_On__c = System.now().addMonths(-1);
		//scheduleData.SVMXC__Previous_Execution_Completed_On__c=System.now().addMonths(-1);
		scheduleData.RecordTypeId = spmDetailsRecordType;
        scheduleData.SVMXC__Dispatch_Process__c = processId;
        scheduleData.SVMXC__Formula__c = calculationMethod2;
        scheduleData.SVMXC__Active__c = true;
		insert scheduleData;
        List<SVMXC__ServiceMax_Config_Data__c> listserviceMaxConfigD=new List<SVMXC__ServiceMax_Config_Data__c>();
		listserviceMaxConfigD.add(scheduleData);
		insertIBWithServiceContractAndWarranty();
		
        SPM_MeanTimeBetweenFailure meanTimeBetweenFailure = new SPM_MeanTimeBetweenFailure(scheduleData);
        System.assert(meanTimeBetweenFailure != null );
        meanTimeBetweenFailure.listserviceMaxConfigData.addAll(listserviceMaxConfigD);
        Database.QueryLocator queryLocator = meanTimeBetweenFailure.start( null );
        System.assert( queryLocator != null );
        String queryString='SELECT Id,SVMXC__Company__c, SVMXC__Top_Level__c, SVMXC__Product__c, CreatedDate FROM SVMXC__Installed_Product__c LIMIT 1';
        List<SObject> records = Database.query( queryString );
        System.debug('Query: ' + queryLocator.getQuery() );
        meanTimeBetweenFailure.handleRecords(records);
        //meanTimeBetweenFailure.execute(null, records);
        meanTimeBetweenFailure.finish( null );
        
        Test.stopTest();
    }
    public static void createDownTimeRecord(id serviceOrder){
		SVMXC__Down_Time__c dt=new SVMXC__Down_Time__c();
		dt.SVMXC__Duration__c=11.0;
		dt.SVMXC__Service_Order__c=serviceOrder;
		insert dt;
	}
	public static void createDownTimeRecords(id serviceOrder){
		SVMXC__Down_Time__c dt=new SVMXC__Down_Time__c();
		dt.SVMXC__Start_Time__c=Datetime.now().addDays(-2);
		dt.SVMXC__End_Time__c=Datetime.now().addDays(-1);
		dt.SVMXC__Service_Order__c=serviceOrder;
		insert dt;
	}
    private static void setup() {
        
        if( spmRuleRecordType == null ) {
			spmRuleRecordType = Schema.SObjectType.SVMXC__ServiceMax_Processes__c.getRecordTypeInfosByName().get('SPM Rule').getRecordTypeId();
               
        }
        
        if( spmDetailsRecordType == null ) {
			spmDetailsRecordType = Schema.SObjectType.SVMXC__ServiceMax_Config_Data__c.getRecordTypeInfosByName().get('SPM Details').getRecordTypeId();
              
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
        
		createDownTimeRecord(serviceOrder.id);
		
        SVMXC__Warranty__c warranty = new SVMXC__Warranty__c();
        warranty.SVMXC__Installed_Product__c = installProduct.Id;
        //insert warranty;
    }
	private static void insertIBWithServiceContractAndWarranty2() {
        
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
        
		createDownTimeRecords(serviceOrder.id);
		
        SVMXC__Warranty__c warranty = new SVMXC__Warranty__c();
        warranty.SVMXC__Installed_Product__c = installProduct.Id;
        //insert warranty;
    }
    
    private static Id insertProcess() {
        
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = spmRuleRecordType;
        process.SVMXC__ProcessID__c = SPM_Schema.Report.MeanTimeToComplete.name();
        process.SVMXC__Name__c = 'Mean Time Between Failure';
        
        insert process;
        
        return process.Id;
    }
    
    private static void insertConfigData( Id processId ) {
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.RecordTypeId = spmDetailsRecordType;
        configData.SVMXC__Dispatch_Process__c = processId;
        configData.SVMXC__Formula__c = calculationMethod;
        configData.SVMXC__Active__c = true;
        
        insert configData;
        calculationMethod.replace( 'a100G000009GYHqQAO', configData.Id );
        
    }
    
    private static String calculationMethod = '{"targetObjectName":"SVMXC__SPM_Mean_Time_Between_Failure__c","targetObjectLabel":"SPM - Mean Time Between Failure","sourceObjectName":"SVMXC__Installed_Product__c","sourceObjectLabel":"Installed Product","recordId":"a100G000009GYHqQAO","parameterInfoList":[{"sourceObjectName":null,"sourceObjectField":"considerDownTimeFrom","sourceFieldName":"Down Time","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":null,"label":"Consider Downtime from:","isPicklistValue":false,"isMultiSelect":false,"isCriteria":true,"displayType":"PICKLIST"},{"sourceObjectName":"SVMXC__Service_Order__c","sourceObjectField":"CreatedDate","sourceFieldName":"CreatedDate","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":null,"label":"Select the source for the Created On Date field","isPicklistValue":false,"isMultiSelect":false,"isCriteria":true,"displayType":"DATETIME"},{"sourceObjectName":"SVMXC__Service_Order__c","sourceObjectField":"ClosedOn","sourceFieldName":"SVMXC__Closed_On__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":null,"label":"Select the source for Fixed On Date field","isPicklistValue":false,"isMultiSelect":false,"isCriteria":true,"displayType":"DATETIME"},{"sourceObjectName":"SVMXC__Service_Order__c","sourceObjectField":"Account","sourceFieldName":"SVMXC__Company__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"Account","label":"Select the source for Account field","isPicklistValue":false,"isMultiSelect":false,"isCriteria":false,"displayType":"REFERENCE"},{"sourceObjectName":"SVMXC__Service_Order__c","sourceObjectField":"InstallProduct","sourceFieldName":"SVMXC__Component__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"SVMXC__Installed_Product__c","label":"Select the source for Installed Product field","isPicklistValue":false,"isMultiSelect":false,"isCriteria":false,"displayType":"REFERENCE"},{"sourceObjectName":"SVMXC__Service_Contract__c","sourceObjectField":"BusinessHours","sourceFieldName":"SVMXC__Business_Hours__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"BusinessHours","label":"Select the source for Business Hours field","isPicklistValue":false,"isMultiSelect":false,"isCriteria":false,"displayType":"REFERENCE"}],"objectMappingDetailsList":[{"targetObjectName":"SVMXC__SPM_Mean_Time_Between_Failure__c","sourceObjectName":"SVMXC__Installed_Product__c","referenceObjectName":false,"objectMappingList":null,"mapId":"NONE","label":"Select an object mapping to store additional data for this metric"}],"name":"CN-0007108953","methodDisplayName":null,"method":null,"lastModifiedOn":"11/3/2017 3:46 PM","isActive":true,"expressionDetailsList":[{"sourceObjectName":null,"label":"Select the expression to qualify installed products for this metric","expressionType":"QualificationCriteria","expressionRuleList":null,"expressionRuleId":"SPMSTD:_To_Qualify_Top-Level_IBs"},{"sourceObjectName":"SVMXC__Service_Order__c","label":"Select the expression to qualify work orders for this metric","expressionType":"WorkOrderCriteria","expressionRuleList":null,"expressionRuleId":"EXPR060"}],"appliesTo":"Testing MTBF for Bike"}';
	private static String calculationMethod2 = '{"targetObjectName":"SVMXC__SPM_Mean_Time_Between_Failure__c","targetObjectLabel":"SPM - Mean Time Between Failure","sourceObjectName":"SVMXC__Installed_Product__c","sourceObjectLabel":"Installed Product","recordId":"a100G000009GYHqQAO","parameterInfoList":[{"sourceObjectName":null,"sourceObjectField":"considerDownTimeFrom","sourceFieldName":"Down Time","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":null,"label":"Consider Downtime from:","isPicklistValue":false,"isMultiSelect":false,"isCriteria":true,"displayType":"PICKLIST"},{"sourceObjectName":"SVMXC__Service_Order__c","sourceObjectField":"CreatedDate","sourceFieldName":"CreatedDate","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":null,"label":"Select the source for the Created On Date field","isPicklistValue":false,"isMultiSelect":false,"isCriteria":true,"displayType":"DATETIME"},{"sourceObjectName":"SVMXC__Service_Order__c","sourceObjectField":"ClosedOn","sourceFieldName":"SVMXC__Closed_On__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":null,"label":"Select the source for Fixed On Date field","isPicklistValue":false,"isMultiSelect":false,"isCriteria":true,"displayType":"DATETIME"},{"sourceObjectName":"SVMXC__Service_Order__c","sourceObjectField":"Account","sourceFieldName":"SVMXC__Company__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"Account","label":"Select the source for Account field","isPicklistValue":false,"isMultiSelect":false,"isCriteria":false,"displayType":"REFERENCE"},{"sourceObjectName":"SVMXC__Service_Order__c","sourceObjectField":"InstallProduct","sourceFieldName":"SVMXC__Top_Level__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"SVMXC__Installed_Product__c","label":"Select the source for Installed Product field","isPicklistValue":false,"isMultiSelect":false,"isCriteria":false,"displayType":"REFERENCE"},{"sourceObjectName":"SVMXC__Service_Contract__c","sourceObjectField":"BusinessHours","sourceFieldName":"SVMXC__Business_Hours__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"BusinessHours","label":"Select the source for Business Hours field","isPicklistValue":false,"isMultiSelect":false,"isCriteria":false,"displayType":"REFERENCE"}],"objectMappingDetailsList":[{"targetObjectName":"SVMXC__SPM_Mean_Time_Between_Failure__c","sourceObjectName":"SVMXC__Installed_Product__c","referenceObjectName":false,"objectMappingList":null,"mapId":"NONE","label":"Select an object mapping to store additional data for this metric"}],"name":"CN-0007108953","methodDisplayName":null,"method":null,"lastModifiedOn":"11/3/2017 3:46 PM","isActive":true,"expressionDetailsList":[{"sourceObjectName":null,"label":"Select the expression to qualify installed products for this metric","expressionType":"QualificationCriteria","expressionRuleList":null,"expressionRuleId":"SPMSTD:_To_Qualify_Top-Level_IBs"},{"sourceObjectName":"SVMXC__Service_Order__c","label":"Select the expression to qualify work orders for this metric","expressionType":"WorkOrderCriteria","expressionRuleList":null,"expressionRuleId":"EXPR060"}],"appliesTo":"Testing MTBF for Bike"}';
     
}