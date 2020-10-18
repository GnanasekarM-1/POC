@isTest
public class SPM_ConfigurationImpl_UT {
    
    static testMethod void testGetAllSPMProcess_No_Process() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().getAllSPMProcess();
		
       
        
        Test.stopTest();
    }
    
    static testMethod void testGetAllSPMProcess() {
        
        Test.startTest();
        
        setup();
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().getAllSPMProcess();
        
        System.assert( response.success );
        System.assert( response.messageList.isEmpty() );
        System.assert( !response.spmProcessDetailsList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testGetSPMConfiguration_Null_Request() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().getSPMConfiguration( null );
        
        System.assert( !response.success );
        System.assert( !response.messageList.isEmpty() );
        System.assert( response.messageList.get(0).equalsIgnoreCase( System.Label.SPM001_TAG004 ) );
        
        Test.stopTest();
    }
    
    static testMethod void testGetSPMConfiguration_Null_Process_Details_List() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
        request.spmProcessDetailsList = null;
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().getSPMConfiguration( request );
        
        System.assert( !response.success );
        System.assert( !response.messageList.isEmpty() );
        System.assert( response.messageList.get(0).equalsIgnoreCase( System.Label.SPM001_TAG004 ) );
        
        Test.stopTest();
    }
    
    static testMethod void testGetSPMConfiguration_Empty_Process_Details_List() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().getSPMConfiguration( new SPM_WrapperDef.SPM_Request() );
        
        System.assert( !response.success );
        System.assert( !response.messageList.isEmpty() );
        System.assert( response.messageList.get(0).equalsIgnoreCase( System.Label.SPM001_TAG004 ) );
        
        Test.stopTest();
    }
    
    static testMethod void testGetSPMConfiguration_Null_Process_Detail() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
        request.spmProcessDetailsList.add( null );
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().getSPMConfiguration( request );
        
        System.assert( !response.success );
        System.assert( !response.messageList.isEmpty() );
        System.assert( response.messageList.get(0).equalsIgnoreCase( System.Label.SPM001_TAG004 ) );
        
        Test.stopTest();
    }
    
    static testMethod void testGetSPMConfiguration_Null_ProcessID() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_ProcessDetails spmProcessDetails = new SPM_WrapperDef.SPM_ProcessDetails();
        spmProcessDetails.processId = null;
        
        SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
        request.spmProcessDetailsList.add( spmProcessDetails );
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().getSPMConfiguration( request );
        
        System.assert( !response.success );
        System.assert( !response.messageList.isEmpty() );
        System.assert( response.messageList.get(0).equalsIgnoreCase( System.Label.SPM001_TAG004 ) );
        
        Test.stopTest();
    }
    
    static testMethod void testGetSPMConfiguration_Unsupported_Process() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_ProcessDetails spmProcessDetails = new SPM_WrapperDef.SPM_ProcessDetails();
        spmProcessDetails.processId = SPM_Schema.Report.FirstTimeFix.name();
        
        SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
        request.spmProcessDetailsList.add( spmProcessDetails );
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().getSPMConfiguration( request );
        
        System.assert( !response.success );
        System.assert( !response.messageList.isEmpty() );
        System.assert( response.messageList.get(0).contains( System.Label.SPM001_TAG008 ) );
        
        Test.stopTest();
    }
    
    static testMethod void testGetSPMConfiguration() {
        
        Test.startTest();
        
        setup();
        
        SPM_WrapperDef.SPM_ProcessDetails spmProcessDetails = new SPM_WrapperDef.SPM_ProcessDetails();
        spmProcessDetails.processId = SPM_Schema.Report.FirstTimeFix.name();
        
        SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
        request.spmProcessDetailsList.add( spmProcessDetails );
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().getSPMConfiguration( request );
        
        System.assert( response.success );        
        
        Test.stopTest();
    }
    
    static testMethod void testSaveSPMConfiguration_Null_Request() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().saveSPMConfiguration( null );
        
        System.assert( !response.success );
        System.assert( !response.messageList.isEmpty() );
        System.assert( response.messageList.get(0).equalsIgnoreCase( System.Label.SPM001_TAG004 ) );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveSPMConfiguration_Null_Process_Details_List() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
        request.spmProcessDetailsList = null;
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().saveSPMConfiguration( request );
        
        
        System.assert( !response.success );
        System.assert( !response.messageList.isEmpty() );
        System.assert( response.messageList.get(0).equalsIgnoreCase( System.Label.SPM001_TAG004 ) );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveSPMConfiguration_Empty_Process_Details_List() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().saveSPMConfiguration( request );
        
        System.assert( !response.success );
        System.assert( !response.messageList.isEmpty() );
        System.assert( response.messageList.get(0).equalsIgnoreCase( System.Label.SPM001_TAG004 ) );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveSPMConfiguration_Null_Process_Detail() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
        request.spmProcessDetailsList.add(null);
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().saveSPMConfiguration( request );
        
        System.assert( !response.success );
        System.assert( !response.messageList.isEmpty() );
        System.assert( response.messageList.get(0).equalsIgnoreCase( System.Label.SPM001_TAG004 ) );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveSPMConfiguration_Null_Process_Id() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_ProcessDetails spmProcessDetails = new SPM_WrapperDef.SPM_ProcessDetails();
        spmProcessDetails.processId = null;
        
        SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
        request.spmProcessDetailsList.add(spmProcessDetails);
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().saveSPMConfiguration( request );
        
        System.assert( !response.success );
        System.assert( !response.messageList.isEmpty() );
        System.assert( response.messageList.get(0).equalsIgnoreCase( System.Label.SPM001_TAG004 ) );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveSPMConfiguration_Invalid_Process_Id() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_ProcessDetails spmProcessDetails = new SPM_WrapperDef.SPM_ProcessDetails();
        spmProcessDetails.processId = 'UnsupportedReport';
        
        SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
        request.spmProcessDetailsList.add(spmProcessDetails);
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().saveSPMConfiguration( request );
        
        System.assert( !response.success );
        System.assert( !response.messageList.isEmpty() );
        System.assert( response.messageList.get(0).contains( System.Label.SPM001_TAG008 ) );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveSPMConfiguration_Exception() {
        
        Test.startTest();
        
        setup();
        
        Test.setReadOnlyApplicationMode(true);
        
        RecordType spmDetailsRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name = 'SPM Details'];
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();        
        configData.RecordTypeId = spmDetailsRecordType.Id;
        
        SPM_WrapperDef.SPM_ProcessDetails spmProcessDetails = new SPM_WrapperDef.SPM_ProcessDetails();
        spmProcessDetails.processId = SPM_Schema.Report.FirstTimeFix.name();
        spmProcessDetails.spmDetailsList.add( configData );
        
        SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
        request.spmProcessDetailsList.add( spmProcessDetails );
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().saveSPMConfiguration( request );
        
        System.assert( !response.success );
        System.assert( !response.messageList.isEmpty() );
        //System.assert( response.messageList.get(0).contains( System.Label.SPM001_TAG015 ), SPM_Utilities.getInstance().buildString( response.messageList, SPM_Consts.SEMICOLON ) );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveSPMConfiguration() {
        
        Test.startTest();
        
        setup();
        
        RecordType spmDetailsRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name = 'SPM Details'];
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();        
        configData.RecordTypeId = spmDetailsRecordType.Id;
        
        SPM_WrapperDef.SPM_ProcessDetails spmProcessDetails = new SPM_WrapperDef.SPM_ProcessDetails();
        spmProcessDetails.processId = SPM_Schema.Report.FirstTimeFix.name();
        spmProcessDetails.spmDetailsList.add( configData );
        spmProcessDetails.isActive = true;
        
        SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
        request.spmProcessDetailsList.add( spmProcessDetails );
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().saveSPMConfiguration( request );
        
        System.assert( response.success, response.messageList.get(0) );
        
        Test.stopTest();
    }
    
    static testMethod void testGetAllScheduleConfiguration_Empty_List() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().getAllScheduleConfiguration();
        
        System.assert( !response.success );
        System.assert( response.messageList != null );
        System.assert( response.messageList.get(0).contains( System.Label.SPM001_TAG016 ) );
        
        Test.stopTest();
    }
    
    static testMethod void testGetAllScheduleConfiguration() {
        
        Test.startTest();
        
        setup();
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().getAllScheduleConfiguration();
        
        System.assert( response.success );
        System.assert( response.spmProcessDetailsList != null );
        System.assert( !response.spmProcessDetailsList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveScheduleConfiguration_Null_Request() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().saveScheduleConfiguration( null );
        
        System.assert( !response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveScheduleConfiguration_Null_Process_Details_List() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
        request.spmProcessDetailsList = null;
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().saveScheduleConfiguration( request );
        
        System.assert( !response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveScheduleConfiguration_Empty_Process_Details_List() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().saveScheduleConfiguration( request );
        
        System.assert( !response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveScheduleConfiguration_Null_Process_Detail() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
        request.spmProcessDetailsList.add(null);
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().saveScheduleConfiguration( request );
        
        System.assert( !response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveScheduleConfiguration_Null_ProcessId() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_ProcessDetails spmProcessDetails = new SPM_WrapperDef.SPM_ProcessDetails();
        spmProcessDetails.processId = null;
        
        SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
        request.spmProcessDetailsList.add(spmProcessDetails);
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().saveScheduleConfiguration( request );
        
        System.assert( !response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveScheduleConfiguration_Invalid_ProcessId() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_ProcessDetails spmProcessDetails = new SPM_WrapperDef.SPM_ProcessDetails();
        spmProcessDetails.processId = 'InvalidProcessId';
        
        SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
        request.spmProcessDetailsList.add(spmProcessDetails);
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().saveScheduleConfiguration( request );
        
        System.assert( !response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveScheduleConfiguration_Exception() {
        
        Test.startTest();
        
        RecordType spmRuleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'SPM Rule'];
        
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.SVMXC__ProcessID__c = SPM_Schema.Report.FirstTimeFix.name();
        process.SVMXC__Name__c = SPM_Consts.REPORT_NAME_FIRST_TIME_FIX;
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__Active__c = true;
        
        insert process;
        
        Test.setReadOnlyApplicationMode(true);
        
        RecordType scheduleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name = 'Schedule'];
        
        SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
        scheduleData.SVMXC__Dispatch_Process__c = process.Id;
        scheduleData.RecordTypeId = scheduleRecordType.Id;
        
        SPM_WrapperDef.SPM_ProcessDetails spmProcessDetails = new SPM_WrapperDef.SPM_ProcessDetails();
        spmProcessDetails.processId = SPM_Schema.Report.FirstTimeFix.name();
        spmProcessDetails.spmDetailsList.add( scheduleData );
        
        SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
        request.spmProcessDetailsList.add( spmProcessDetails );
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().saveScheduleConfiguration( request );
        
        System.assert( !response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveScheduleConfiguration() {
        
        Test.startTest();
        
        RecordType spmRuleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'SPM Rule'];
        
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.SVMXC__ProcessID__c = SPM_Schema.Report.FirstTimeFix.name();
        process.SVMXC__Name__c = SPM_Consts.REPORT_NAME_FIRST_TIME_FIX;
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__Active__c = true;
        
        insert process;
        
        RecordType scheduleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name = 'Schedule'];
        
        SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
        scheduleData.SVMXC__Dispatch_Process__c = process.Id;
        scheduleData.RecordTypeId = scheduleRecordType.Id;
        
        SPM_WrapperDef.SPM_ProcessDetails spmProcessDetails = new SPM_WrapperDef.SPM_ProcessDetails();
        spmProcessDetails.processId = SPM_Schema.Report.FirstTimeFix.name();
        spmProcessDetails.spmDetailsList.add( scheduleData );
        
        SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
        request.spmProcessDetailsList.add( spmProcessDetails );
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().saveScheduleConfiguration( request );
        
        System.assert( response.success, response.messageList.get(0) );
        
        response = new SPM_ConfigurationImpl().getAllScheduleConfiguration();
        
        System.assert( response.success );
        System.assert( response.spmProcessDetailsList != null );
        System.assert( !response.spmProcessDetailsList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testExecuteBatch_Null_ProcessId() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().executeBatch( null );        
        System.assert( !response.success);
        
        Test.stopTest();
    }
    
    static testMethod void testExecuteBatch_Invalid_ProcessId() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().executeBatch( 'Invalid' );        
        System.assert( !response.success);
        
        Test.stopTest();
    }
    
    static testMethod void testExecuteBatch() {
        
        Test.startTest();
        
        createProcessAndSchedule( SPM_Consts.FIRST_TIME_FIX, SPM_Schema.Report.FirstTimeFix );
        createProcessAndSchedule( SPM_Consts.MEAN_TIME_TO_REPAIR, SPM_Schema.Report.MeanTimeToRepair );
        createProcessAndSchedule( SPM_Consts.MEAN_TIME_TO_COMPLETE, SPM_Schema.Report.MeanTimeToComplete );
        createProcessAndSchedule( SPM_Consts.AVERAGE_RESPONSE_TIME, SPM_Schema.Report.AverageResponseTime );
        createProcessAndSchedule( SPM_Consts.CONTRACT_PENETRATION, SPM_Schema.Report.ContractPenetration );
        createProcessAndSchedule( SPM_Consts.CONTRACT_UP_TIME, SPM_Schema.Report.UpDownTime );
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().executeBatch( SPM_Schema.Report.FirstTimeFix.name() );        
        System.assert( response.success, response.messageList.get(0) );
        
        response = new SPM_ConfigurationImpl().executeBatch( SPM_Schema.Report.MeanTimeToRepair.name() );
        response = new SPM_ConfigurationImpl().executeBatch( SPM_Schema.Report.MeanTimeToComplete.name() );
        response = new SPM_ConfigurationImpl().executeBatch( SPM_Schema.Report.AverageResponseTime.name() );
        response = new SPM_ConfigurationImpl().executeBatch( SPM_Schema.Report.ContractPenetration.name() );
        response = new SPM_ConfigurationImpl().executeBatch( SPM_Schema.Report.UpDownTime.name() );
        
        Test.stopTest();
    }
    
    static testMethod void testDeleteCalculationMethod_Null_Request() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().deleteCalculationMethod( null );        
        System.assert( !response.success, response.messageList.get(0) );
        
        Test.stopTest();
    }
    
    static testMethod void testDeleteCalculationMethod_Null_Process_Details_List() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
        request.spmProcessDetailsList = null;
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().deleteCalculationMethod( request );        
        System.assert( !response.success, response.messageList.get(0) );
        
        Test.stopTest();
    }
    
    static testMethod void testDeleteCalculationMethod_Empty_Process_Details_List() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().deleteCalculationMethod( request );        
        System.assert( !response.success, response.messageList.get(0) );
        
        Test.stopTest();
    }
    
    static testMethod void testDeleteCalculationMethod_Null_Process_Detail() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
        request.spmProcessDetailsList.add( null );
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().deleteCalculationMethod( request );        
        System.assert( !response.success, response.messageList.get(0) );
        
        Test.stopTest();
    }
    
    static testMethod void testDeleteCalculationMethod_Null_Process_Id() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_ProcessDetails spmProcessDetails = new SPM_WrapperDef.SPM_ProcessDetails();
        spmProcessDetails.processId = null;
        
        SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
        request.spmProcessDetailsList.add( spmProcessDetails );
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().deleteCalculationMethod( request );        
        System.assert( !response.success, response.messageList.get(0) );
        
        Test.stopTest();
    }
    
    static testMethod void testDeleteCalculationMethod_Exception() {
        
        Test.startTest();
        
        RecordType spmRuleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'SPM Rule'];
        
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.SVMXC__ProcessID__c = SPM_Schema.Report.FirstTimeFix.name();
        process.SVMXC__Name__c = SPM_Consts.REPORT_NAME_FIRST_TIME_FIX;
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__Active__c = true;
        
        insert process;
        
        RecordType spmDetailsRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name = 'SPM Details'];
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.SVMXC__Dispatch_Process__c = process.Id;
        configData.RecordTypeId = spmDetailsRecordType.Id;
        
        insert configData;
        
        Test.setReadOnlyApplicationMode(true);
        
        SPM_WrapperDef.SPM_ProcessDetails spmProcessDetails = new SPM_WrapperDef.SPM_ProcessDetails();
        spmProcessDetails.processId = SPM_Schema.Report.FirstTimeFix.name();
        spmProcessDetails.spmDetailsList.add( configData );
        
        SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
        request.spmProcessDetailsList.add( spmProcessDetails );
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().deleteCalculationMethod( request );        
        System.assert( !response.success, response.messageList.get(0) );
        
        Test.stopTest();
    }
    
    static testMethod void testDeleteCalculationMethod() {
        
        Test.startTest();
        
        RecordType spmRuleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'SPM Rule'];
        
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.SVMXC__ProcessID__c = SPM_Schema.Report.FirstTimeFix.name();
        process.SVMXC__Name__c = SPM_Consts.REPORT_NAME_FIRST_TIME_FIX;
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__Active__c = true;
        
        insert process;
        
        RecordType spmDetailsRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name = 'SPM Details'];
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.SVMXC__Dispatch_Process__c = process.Id;
        configData.RecordTypeId = spmDetailsRecordType.Id;
        
        insert configData;
        
        SPM_WrapperDef.SPM_ProcessDetails spmProcessDetails = new SPM_WrapperDef.SPM_ProcessDetails();
        spmProcessDetails.processId = SPM_Schema.Report.FirstTimeFix.name();
        spmProcessDetails.spmDetailsList.add( configData );
        
        SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
        request.spmProcessDetailsList.add( spmProcessDetails );
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().deleteCalculationMethod( request );        
        System.assert( response.success, response.messageList.get(0) );
        
        response = new SPM_ConfigurationImpl().getSPMConfiguration( request );        
        System.assert( response.success ); //, response.messageList.get(0)  );
        System.assert( response.spmProcessDetailsList.isEmpty() );
                
        Test.stopTest();
    }
    
    static testMethod void testGetJobLogs_Null_Request() {
        
        Test.startTest();
        
        setupJobLog();
            
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().getSPMJobs( null );
        
        System.assert( !response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testGetJobLogs() {
        
        Test.startTest();
        
        setupJobLog();
            
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().getSPMJobs( SPM_Schema.Report.FirstTimeFix.name() );
        
        System.assert( response.success );
        System.assert( response.spmJobsList != null );
        System.assert( !response.spmJobsList.isEmpty() );
        
        Test.stopTest();
    }
    
    private static void createProcessAndSchedule( String reportName, SPM_Schema.Report report ) {
        
        RecordType spmRuleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'SPM Rule'];
        
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.SVMXC__ProcessID__c = report.name();
        process.SVMXC__Name__c = reportName;
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__Active__c = true;
        
        insert process;
        
        RecordType scheduleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name = 'Schedule'];
        
        SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
        scheduleData.SVMXC__Dispatch_Process__c = process.Id;
        scheduleData.RecordTypeId = scheduleRecordType.Id;
        
        insert scheduleData;
    }
    
    private static void setup() {
        
        RecordType spmRuleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'SPM Rule'];
        List<SVMXC__ServiceMax_Processes__c> lstSMaxProcess=new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.SVMXC__ProcessID__c = SPM_Schema.Report.FirstTimeFix.name();
        process.SVMXC__Name__c = SPM_Consts.REPORT_NAME_FIRST_TIME_FIX;
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__Active__c = true;
        
        lstSMaxProcess.add(process);
		
		SVMXC__ServiceMax_Processes__c process1 = new SVMXC__ServiceMax_Processes__c();
        process1.SVMXC__ProcessID__c = SPM_Schema.Report.MeanTimeToRepair.name();
        process1.SVMXC__Name__c = SPM_Consts.MEAN_TIME_TO_REPAIR;
        process1.RecordTypeId = spmRuleRecordType.Id;
        process1.SVMXC__Active__c = true;
        
        lstSMaxProcess.add(process1);
		
		SVMXC__ServiceMax_Processes__c process2 = new SVMXC__ServiceMax_Processes__c();
        process2.SVMXC__ProcessID__c = SPM_Schema.Report.RepeatVisit.name();
        process2.SVMXC__Name__c = SPM_Consts.REPEATVISIT;
        process2.RecordTypeId = spmRuleRecordType.Id;
        process2.SVMXC__Active__c = true;
        
        lstSMaxProcess.add(process2);
		
		SVMXC__ServiceMax_Processes__c process3 = new SVMXC__ServiceMax_Processes__c();
        process3.SVMXC__ProcessID__c = SPM_Schema.Report.UpDownTime.name();
        process3.SVMXC__Name__c = SPM_Consts.CONTRACT_UP_TIME;
        process3.RecordTypeId = spmRuleRecordType.Id;
        process3.SVMXC__Active__c = true;
        
        lstSMaxProcess.add(process3);
		
		SVMXC__ServiceMax_Processes__c process4 = new SVMXC__ServiceMax_Processes__c();
        process4.SVMXC__ProcessID__c = SPM_Schema.Report.AverageResponseTime.name();
        process4.SVMXC__Name__c = SPM_Consts.AVERAGE_RESPONSE_TIME;
        process4.RecordTypeId = spmRuleRecordType.Id;
        process4.SVMXC__Active__c = true;
        
        lstSMaxProcess.add(process4);
		
		SVMXC__ServiceMax_Processes__c process5 = new SVMXC__ServiceMax_Processes__c();
        process5.SVMXC__ProcessID__c = SPM_Schema.Report.ContractPenetration.name();
        process5.SVMXC__Name__c = SPM_Consts.CONTRACT_PENETRATION;
        process5.RecordTypeId = spmRuleRecordType.Id;
        process5.SVMXC__Active__c = true;
        
        lstSMaxProcess.add(process5);
		
		SVMXC__ServiceMax_Processes__c process6 = new SVMXC__ServiceMax_Processes__c();
        process6.SVMXC__ProcessID__c = SPM_Schema.Report.MeanTimeToComplete.name();
        process6.SVMXC__Name__c = SPM_Consts.MEAN_TIME_TO_COMPLETE;
        process6.RecordTypeId = spmRuleRecordType.Id;
        process6.SVMXC__Active__c = true;
        
        lstSMaxProcess.add(process6);
		
		SVMXC__ServiceMax_Processes__c process7 = new SVMXC__ServiceMax_Processes__c();
        process7.SVMXC__ProcessID__c = SPM_Schema.Report.AccountSummary.name();
        process7.SVMXC__Name__c = SPM_Consts.ACCOUNT_SUMMARY;
        process7.RecordTypeId = spmRuleRecordType.Id;
        process7.SVMXC__Active__c = true;
        
        lstSMaxProcess.add(process7);
		
		SVMXC__ServiceMax_Processes__c process8 = new SVMXC__ServiceMax_Processes__c();
        process8.SVMXC__ProcessID__c = 'MTBF';
        process8.SVMXC__Name__c = 'MTBF';
        process8.RecordTypeId = spmRuleRecordType.Id;
        process8.SVMXC__Active__c = true;
        
        lstSMaxProcess.add(process8);
        insert lstSMaxProcess;
        RecordType spmDetailsRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name = 'SPM Details'];
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.SVMXC__Dispatch_Process__c = process.Id;
        configData.RecordTypeId = spmDetailsRecordType.Id;
        
        insert configData;
        
        RecordType scheduleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name = 'Schedule'];
        
        SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
        scheduleData.SVMXC__Dispatch_Process__c = process.Id;
        scheduleData.RecordTypeId = scheduleRecordType.Id;
        
        insert scheduleData;
    }
    
    private static void setupJobLog() {
        
        RecordType spmRuleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'SPM Rule'];
        
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.SVMXC__ProcessID__c = SPM_Schema.Report.FirstTimeFix.name();
        process.SVMXC__Name__c = SPM_Consts.REPORT_NAME_FIRST_TIME_FIX;
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__Active__c = true;
        
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
}