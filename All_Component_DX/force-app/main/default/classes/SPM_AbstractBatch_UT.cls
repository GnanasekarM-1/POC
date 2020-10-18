@isTest
global class SPM_AbstractBatch_UT {
    
    private static RecordType spmRuleRecordType;
    private static RecordType spmDetailsRecordType;
    
    private static RecordType objectMappingRecordType;
    private static RecordType fieldMappingRecordType;
    
    global class DerivedAbstractBatch extends SPM_AbstractBatch {
        
        public DerivedAbstractBatch( SPM_Schema.Report report ) {
            super(report, null);
        }
        
        global override void initBatchConfiguration() {
            
            addIgnoreNullCheckField( SPM_Schema.Field.ServiceGroup );
            addIgnoreNullCheckField( 'SVMXC__Active__c' );
            addIgnoreNullCheckField( new List<SPM_Schema.Field> {SPM_Schema.Field.ServiceGroup});
            addError('Testing');
            setOrderBy('');
        }

        global override void handleRecords( List<SObject> records ) {
            
            addInfo('Inside handle record.');
            String empty = null;
            if( records != null ) {
                for( SObject record : records ) {
                	getSourceObjectFieldValue( record, empty );
                }
                getAdvancedExpressionCriteria( SPM_Schema.ExpressionType.QualificationCriteria);
                getNumberOfDaysToQualifyRecords();
                addQueryField( SPM_Schema.Field.Name , '' );
            }            
        }
        
        global override void onFinishComplete() {
        }
    }
    
    static testMethod void testSPM_AbstractBatch_Constructor_Null_Report() {
        
        Test.startTest();
        
    	SPM_AbstractBatch testAbstractBatch = new DerivedAbstractBatch( null );
        Map<String, String> SourceObjectFieldMap = testAbstractBatch.getSourceObjectFieldMap();
        
        System.assert( testAbstractBatch.getReport() == null );
        System.assert( SourceObjectFieldMap != null );
        System.assert( SourceObjectFieldMap.isEmpty() );
        
        testAbstractBatch.start( null );
        
        Test.stopTest();
    }
    
    static testMethod void testSPM_AbstractBatch_Constructor_Empty_Data() {
        
        Test.startTest();
        setup();
        
        Id processId = insertProcess();
        insertConfigData( processId );
        
    	SPM_AbstractBatch testAbstractBatch = new DerivedAbstractBatch( SPM_Schema.Report.FirstTimeFix );        
        Map<String, String> SourceObjectFieldMap = testAbstractBatch.getSourceObjectFieldMap();
        
        System.assert( testAbstractBatch.getReport() == SPM_Schema.Report.FirstTimeFix );
        System.assert( SourceObjectFieldMap != null );
        System.assert( !SourceObjectFieldMap.isEmpty() );
        
        testAbstractBatch.start( null );
        
        Test.stopTest();
    }
    
    static testMethod void testSPM_AbstractBatch_Constructor() {
        
        Test.startTest();
        
        setup();
        
        Id processId = insertProcess();
        insertConfigData( processId );
        insertWorkOrder();
        insertMapping();
        
    	DerivedAbstractBatch testAbstractBatch = new DerivedAbstractBatch( SPM_Schema.Report.FirstTimeFix );
        Map<String, String> SourceObjectFieldMap = testAbstractBatch.getSourceObjectFieldMap();
        
        System.assert( testAbstractBatch.getReport() == SPM_Schema.Report.FirstTimeFix );
        System.assert( SourceObjectFieldMap != null );
        System.assert( !SourceObjectFieldMap.isEmpty() );
        
        Database.QueryLocator queryLocator = testAbstractBatch.start( null );
        List<SObject> records = Database.query( queryLocator.getQuery() );
        
        testAbstractBatch.execute( null, null );
        testAbstractBatch.execute( null, records );
        
        List<Id> recordIdList = new List<Id>();
        List<SVMXC__SPM_First_Time_Fix__c> ftfList = new List<SVMXC__SPM_First_Time_Fix__c>();
        for( SObject record : records ) {
            
            Id recordId = (Id) testAbstractBatch.getSourceObjectFieldValue( record, SPM_Schema.Field.Id );
            Datetime closedOn = (Datetime) testAbstractBatch.getSourceObjectFieldValue( record, SPM_Schema.Field.ClosedOn );
            
            recordIdList.add(recordId);
            
            SVMXC__SPM_First_Time_Fix__c firstTimeFix = new SVMXC__SPM_First_Time_Fix__c();
            ftfList.add(firstTimeFix);
            testAbstractBatch.performFieldMapping(record, firstTimeFix);
            testAbstractBatch.performFieldMapping(record.Id, firstTimeFix);
        }
        
        testAbstractBatch.performFieldMapping(records, ftfList);
        testAbstractBatch.performFieldMapping(recordIdList, ftfList);
        
        System.assert( !testAbstractBatch.hasRuleExpressions() );
        System.assert( testAbstractBatch.getSourceObjectField( SPM_Schema.Field.ClosedOn ) != null );
        System.assert( testAbstractBatch.getRuleExpressionList( SPM_Schema.ExpressionType.QualificationCriteria ) == null );
        testAbstractBatch.setWhereClause(testAbstractBatch.getSourceObjectField( SPM_Schema.Field.ClosedOn ) + ' > LAST_MONTH' );
        testAbstractBatch.buildParentObjectCriteria( SPM_Schema.ExpressionType.QualificationCriteria, SPM_Schema.Field.ClosedOn );
        testAbstractBatch.buildParentObjectCriteria( 'CreatedDate=TODAY', SPM_Schema.Field.ClosedOn );
        testAbstractBatch.addError( processId, 'Testing Error' );
        testAbstractBatch.setNullCheckInWhereClause(true);
        testAbstractBatch.addIgnoreNullCheckField( SPM_Schema.Field.ClosedOn );
        testAbstractBatch.getSourceObjectFieldMap('');
        testAbstractBatch.getConfigurationName();
        testAbstractBatch.getCalculationMethodName();
        testAbstractBatch.getCalculationMethodNames();
        
        //System.assert( testAbstractBatch.getRuleExpressionList( SPM_Schema.ExpressionType.CriteriaForFirstTimeFixed ) != null );
        
        testAbstractBatch.finish( null );
        
        Test.stopTest();
    }
    
    private static void setup() {
        
        if( spmRuleRecordType == null ) {
        	spmRuleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'SPM Rule'];    
        }
        
        if( spmDetailsRecordType == null ) {
        	spmDetailsRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name = 'SPM Details'];    
        }        
        
        if( objectMappingRecordType == null ) {
        	objectMappingRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'Object Mapping'];    
        } 
        
        if( fieldMappingRecordType == null ) {
        	fieldMappingRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name = 'Field Mapping'];    
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
        serviceOrder.SVMXC__Group_Member__c = technician.Id; 
        serviceOrder.SVMXC__Scheduled_Date__c = System.today().addDays(-1);
        serviceOrder.SVMXC__Scheduled_Date_Time__c = System.now().addDays(-1);
        serviceOrder.SVMXC__Service_Duration__c = 30; 
        serviceOrder.SVMXC__Driving_Time__c = 15;
        serviceOrder.SVMXC__Closed_On__c = System.today();
        serviceOrder.SVMXC__Completed_Date_Time__c = System.today();
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
        calculationMethod.replace( 'a10F0000006Auz3IAC', configData.Id );
        
    }
    
    private static String insertMapping() {
        
        String mappingId = 'FTF_MAPPING';
        
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = objectMappingRecordType.Id;
        process.SVMXC__MapID__c = mappingId;
        process.SVMXC__ProcessID__c = mappingId;
        process.SVMXC__Name__c = mappingId;
        
        insert process;
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        
        configData.SVMXC__MapID__c = process.ID;
        configData.RecordTypeId = fieldMappingRecordType.Id;
        configData.SVMXC__Source_Field_Name__c = 'SVMXC__City__c';
        configData.SVMXC__Target_Field_Name__c = 'SVMXC__Calculation_Method__c';
            
        insert configData;
        
        return mappingId;
    }
    
    private static String calculationMethod = '{"targetObjectName":"SVMXC__SPM_First_Time_Fix__c","targetObjectLabel":"SPM - First Time Fix","sourceObjectName":"SVMXC__Service_Order__c","sourceObjectLabel":"Work Order","recordId":"a10F0000006Auz3IAC","parameterInfoList":[{"sourceObjectName":null,"sourceObjectField":"Account","sourceFieldName":"SVMXC__Company__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"Account","label":"Select the source for the Account field","isPicklistValue":false,"isMultiSelect":false,"displayType":"REFERENCE"},{"sourceObjectName":"SVMXC__Service_Order__c","sourceObjectField":"Technician","sourceFieldName":"SVMXC__Group_Member__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"SVMXC__Service_Group_Members__c","label":"Select the source for the Technician field","isPicklistValue":false,"isMultiSelect":false,"displayType":"REFERENCE"},{"sourceObjectName":"SVMXC__Service_Order__c","sourceObjectField":"Product","sourceFieldName":"SVMXC__Product__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"Product2","label":"Select the source for the Product field","isPicklistValue":false,"isMultiSelect":false,"displayType":"REFERENCE"},{"sourceObjectName":null,"sourceObjectField":"ClosedOn","sourceFieldName":"SVMXC__Completed_Date_Time__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":null,"label":"Select the source for the Fixed On Date field","isPicklistValue":false,"isMultiSelect":false,"displayType":"DATETIME"}],"objectMappingDetailsList":[{"targetObjectName":"SVMXC__SPM_First_Time_Fix__c","sourceObjectName":"SVMXC__Service_Order__c","objectMappingList":null,"mapId":"FTF_MAPPING","label":"Select the Object Mapping to be applied for this metrics"}],"name":"CN-0001986912","methodDisplayName":null,"method":"SPMFTF: Work Order Expression","lastModifiedOn":"2/10/2016 8:43 AM","isActive":true,"expressionDetailsList":[{"sourceObjectName":null,"label":"Select the expression to qualify work orders for this metric","expressionType":"QualificationCriteria","expressionRuleList":null,"expressionRuleId":"SPMSTD:_To_Qualify_Work_Orders_for_FTF_processing"},{"sourceObjectName":"SVMXC__Service_Order__c","label":"Select the expression to identify work orders that were fixed on first visit","expressionType":"CriteriaForFirstTimeFixed","expressionRuleList":null,"expressionRuleId":"SPMSTD:_To_Identify_Fixed_First_Time"}],"appliesTo":"System-wide configuration to generate First Time Fix metric."}';
}