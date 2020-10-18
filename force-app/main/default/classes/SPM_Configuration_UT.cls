@isTest
global class SPM_Configuration_UT {
    
    private static RecordType spmRuleRecordType;
    private static RecordType spmDetailsRecordType;
    
    static testMethod void testGetAllScheduleConfiguration() {
        
        Test.startTest();
        
        insertConfigData( insertProcess() );        
        String result = (String) SPM_Configuration.getAllScheduleConfiguration(null);
        
        Test.stopTest();
    }
    
    static testMethod void testGetAllSPMProcess() {
        
        Test.startTest();
        
        insertProcess();
        String result = (String) SPM_Configuration.getAllSPMProcess(null);
        
        Test.stopTest();
    }
    
    static testMethod void testGetSPMConfiguration() {
        
        Test.startTest();
        
        insertConfigData( insertProcess() );
        String request = '{"processId":"FirstTimeFix"}';
        String result = (String) SPM_Configuration.getSPMConfiguration( request );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveSPMConfiguration() {
        
        Test.startTest();
        
        insertConfigData( insertProcess() );        
        String result = (String) SPM_Configuration.saveSPMConfiguration( saveRequest );
        
        Test.stopTest();
    }
    
    static testMethod void testExecuteBatch() {
        
        Test.startTest();
        
        insertConfigData( insertProcess() );
        String request = '{"processId":"FirstTimeFix"}';
        String result = (String) SPM_Configuration.executeBatch( request );
        
        Test.stopTest();
    }
    
    static testMethod void testDeleteSPMConfiguration() {
        
        Test.startTest();
        
        insertConfigData( insertProcess() );        
        String result = (String) SPM_Configuration.saveSPMConfiguration( saveRequest );        
        result = (String) SPM_Configuration.deleteCalculationMethod( saveRequest );
        
        Test.stopTest();
    }
    
    static testMethod void testGetSPMJobs() {
        
        Test.startTest();
        
        setupJobLog();
        String request = '{"processId":"FirstTimeFix"}';
        String result = (String) SPM_Configuration.getSPMJobs( request );
        
        Test.stopTest();
    }
    
    
    private static Id insertProcess() {
        
        if( spmRuleRecordType == null ) {
            spmRuleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'SPM Rule'];    
        }
        
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__ProcessID__c = SPM_Schema.Report.FirstTimeFix.name();
        process.SVMXC__Name__c = 'First Time Fix';
        
        insert process;
        
        return process.Id;
    }
    static testMethod void testGetAllSPMProces() {
        
        Test.startTest();
        
        insertConfigData( insertProcess() );
        String result = (String) SPM_Configuration.getAllSPMProcess(null);
        String processConfig = SPM_Configuration.loadBusinessProcessConfiguration();
        String jsonInput = SPM_Configuration.loadExpressions('SVMXC__SPM_First_Time_Fix__c');
        SPM_Configuration.saveBusinessProcessConfiguration('SVMXC__SPM_First_Time_Fix__c');
        SPM_Configuration.saveBusinessProcessConfiguration('');
        Test.stopTest();
    }
    private static void insertConfigData( Id processId ) {
        
        if( spmDetailsRecordType == null ) {
            spmDetailsRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name = 'SPM Details'];    
        } 
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.RecordTypeId = spmDetailsRecordType.Id;
        configData.SVMXC__Dispatch_Process__c = processId;
        configData.SVMXC__Formula__c = calculationMethod;
        
        insert configData;
        calculationMethod.replace( 'a10F0000006AabmIAC', configData.Id );
        saveRequest = saveRequest.replace( 'a10F0000006AhEBIA0', configData.Id );
        
        configData.SVMXC__Formula__c = calculationMethod;
        update configData;
        
        RecordType scheduleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name = 'Schedule'];
        
        SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
        scheduleData.SVMXC__Dispatch_Process__c = processId;
        scheduleData.RecordTypeId = scheduleRecordType.Id;
        
        insert scheduleData;
        
    }
    
    private static void setupJobLog() {
        
        if( spmRuleRecordType == null ) {
            spmRuleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'SPM Rule'];    
        }
        
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.SVMXC__ProcessID__c = SPM_Schema.Report.FirstTimeFix.name();
        process.SVMXC__Name__c = SPM_Consts.REPORT_NAME_FIRST_TIME_FIX;
        process.RecordTypeId = spmRuleRecordType.Id;
        
        insert process;
        
        SVMXC__SVMX_Jobs__c objJob = new SVMXC__SVMX_Jobs__c();
        objJob.SVMXC__SVMX_Process__c = process.Id;
        objJob.SVMXC__Type__c = 'SPM Schedule';
        objJob.SVMXC__Start_Time__c = System.now();
        objJob.SVMXC__End_Time__c = System.now();
        objJob.SVMXC__Batch_Job__c = SPM_Schema.Report.FirstTimeFix.name();
        objJob.SVMXC__Status__c = 'Success';
        
        insert objJob;
        
        Attachment objAttach = new Attachment();
        blob attachBlob = Blob.valueOf( 'Testing' );
        objAttach.Body = attachBlob;
        objAttach.ParentId = objJob.id;
        objAttach.Name = 'SPM Schedule Logs.txt';
        insert objAttach;
    }
    
    private static String calculationMethod = '{"sourceObjectName":"SVMXC__Service_Order__c","recordId":"a10F0000006AabmIAC","parameterInfoList":[{"sourceObjectName":null,"sourceObjectField":"Account","sourceFieldName":"SVMXC__Company__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"Account","label":"Choose the field to consolidate by Account","displayType":"REFERENCE"},{"sourceObjectName":null,"sourceObjectField":"Technician","sourceFieldName":"SVMXC__Preferred_Technician__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"SVMXC__Service_Group_Members__c","label":"Choose the field to consolidate by Technician","displayType":"REFERENCE"},{"sourceObjectName":null,"sourceObjectField":"Product","sourceFieldName":"SVMXC__Product__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":"Product2","label":"Choose the field to consolidate by Product","displayType":"REFERENCE"},{"sourceObjectName":null,"sourceObjectField":"ClosedOn","sourceFieldName":"SVMXC__Closed_On__c","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":null,"label":"Choose the field to consider as Fixed On date","displayType":"DATETIME"}],"name":null,"method":"SPMFTF: Work Order Expression","lastModifiedOn":"11/7/2015 7:44 PM","expressionDetailsList":[{"sourceObjectName":"SVMXC__Service_Order__c","label":"Select the expression below, indicate how work order was first time fixed","expressionType":"CriteriaForFirstTimeFixed","expressionRuleList":null,"expressionRuleId":"a12F0000006jC45IAE"},{"sourceObjectName":null,"label":"Choose an expression to qualify records for the metrics generation","expressionType":"QualificationCriteria","expressionRuleList":null,"expressionRuleId":"a12F0000002KDmHIAW"}],"appliesTo":"This is the default configuration for the First Time Fix metrics generation."}';  
    private static String saveRequest = '[{"processId":"FirstTimeFix","calculationMethodList":[{"sourceObjectName":"SVMXC__Service_Order__c","recordId":"a10F0000006AhEBIA0","parameterInfoList":[{"sourceObjectName":null,"sourceObjectField":"Account","sourceFieldName":"SVMXC__Company__c","sourceFieldLabel":null,"referenceTo":"Account","label":"Choose the field to consolidate by Account","displayType":"REFERENCE"},{"sourceObjectName":"SVMXC__Service_Order__c","sourceObjectField":"Technician","sourceFieldName":"SVMXC__Preferred_Technician__c","sourceFieldLabel":null,"referenceTo":"SVMXC__Service_Group_Members__c","label":"Choose the field to consolidate by Technician","displayType":"REFERENCE"},{"sourceObjectName":"SVMXC__Service_Order__c","sourceObjectField":"Product","sourceFieldName":"SVMXC__Product__c","sourceFieldLabel":null,"referenceTo":"Product2","label":"Choose the field to consolidate by Product","displayType":"REFERENCE"},{"sourceObjectName":null,"sourceObjectField":"ClosedOn","sourceFieldName":"SVMXC__Closed_On__c","sourceFieldLabel":null,"referenceTo":null,"label":"Choose the field to consider as Fixed On date","displayType":"DATETIME"}],"name":null,"methodDisplayName":null,"method":"SPMFTF: Work Order Expression","lastModifiedOn":"11/17/2015 4:12 PM","expressionDetailsList":[{"sourceObjectName":"SVMXC__Service_Order__c","label":"Select the expression below, indicate how work order was first time fixed","expressionType":"CriteriaForFirstTimeFixed","expressionRuleId":"SVMXEXPR_SPM"},{"sourceObjectName":null,"label":"Choose an expression to qualify records for the metrics generation","expressionType":"QualificationCriteria","expressionRuleId":"EXPR060"}],"appliesTo":"This is the default configuration for the First Time Fix metrics generation."}],"scheduleId":"a10F0000006AZF6IAO","period":"Daily","timeAt":"8:00 AM","weekOn":["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],"timezone":"Asia/Kolkata","emailOnSuccess":"ramachandra.mohan@servicemax.com"}]';
}