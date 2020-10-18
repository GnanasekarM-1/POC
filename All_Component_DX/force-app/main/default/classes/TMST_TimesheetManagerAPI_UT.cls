@isTest
private class TMST_TimesheetManagerAPI_UT {

    static testMethod void testGetAllTimesheetProcess_Empty_Records() {

        Test.startTest();
        
        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();        
        TMST_WrapperDef.TMST_Response response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testGetAllTimesheetProcess_Without_Schedular() {

        Test.startTest();
        
        RecordType timesheetRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name =: TMST_Consts.RECORD_TYPE_TIMESHEET LIMIT 1];
        
        SVMXC__ServiceMax_Processes__c timesheetProcesses = new SVMXC__ServiceMax_Processes__c();
        timesheetProcesses.RecordTypeId = timesheetRecordType.Id;
        timesheetProcesses.SVMXC__Name__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__Description__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__ProcessID__c = 'Timesheet_1';
        
        insert timesheetProcesses;
                
        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();        
        TMST_WrapperDef.TMST_Response response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( !response.timesheetConfigurationList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testGetAllTimesheetProcess_Timesheet_Name_Validation() {

        Test.startTest();
        
        RecordType timesheetRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name =: TMST_Consts.RECORD_TYPE_TIMESHEET LIMIT 1];
        
        SVMXC__ServiceMax_Processes__c timesheetProcesses = new SVMXC__ServiceMax_Processes__c();
        timesheetProcesses.RecordTypeId = timesheetRecordType.Id;
        timesheetProcesses.SVMXC__Name__c = null;
        timesheetProcesses.SVMXC__Description__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__ProcessID__c = 'Timesheet_1';
        
        insert timesheetProcesses;
                
        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();        
        TMST_WrapperDef.TMST_Response response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testGetAllTimesheetProcess_ProcessID_Validation() {

        Test.startTest();
        
        RecordType timesheetRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name =: TMST_Consts.RECORD_TYPE_TIMESHEET LIMIT 1];
        
        SVMXC__ServiceMax_Processes__c timesheetProcesses = new SVMXC__ServiceMax_Processes__c();
        timesheetProcesses.RecordTypeId = timesheetRecordType.Id;
        timesheetProcesses.SVMXC__Name__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__Description__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__ProcessID__c = '';
        
        insert timesheetProcesses;
                
        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();        
        TMST_WrapperDef.TMST_Response response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );
        
        timesheetProcesses.SVMXC__ProcessID__c = null;        
        update timesheetProcesses;
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testGetAllTimesheetProcess_Without_Timesheet_Access() {

        Test.startTest();
        
        RecordType timesheetRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name =: TMST_Consts.RECORD_TYPE_TIMESHEET LIMIT 1];
        
        SVMXC__ServiceMax_Processes__c timesheetProcesses = new SVMXC__ServiceMax_Processes__c();
        timesheetProcesses.RecordTypeId = timesheetRecordType.Id;
        timesheetProcesses.SVMXC__Name__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__Description__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__ProcessID__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__Start_Date__c = Date.today();
        timesheetProcesses.SVMXC__End_Date__c = Date.today() + 1;
        
        insert timesheetProcesses;
        
        RecordType scheduleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name =: TMST_Consts.RECORD_TYPE_SCHEDULE LIMIT 1];
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.SVMXC__Dispatch_Process__c = timesheetProcesses.Id;
        configData.RecordTypeId = scheduleRecordType.Id;
        configData.SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_HEADER;
        
        insert configData;
                
        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();        
        TMST_WrapperDef.TMST_Response response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( !response.timesheetConfigurationList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testGetAllTimesheetProcess_Null_Schedule_Type() {

        Test.startTest();
        
        RecordType timesheetRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name =: TMST_Consts.RECORD_TYPE_TIMESHEET LIMIT 1];
        
        SVMXC__ServiceMax_Processes__c timesheetProcesses = new SVMXC__ServiceMax_Processes__c();
        timesheetProcesses.RecordTypeId = timesheetRecordType.Id;
        timesheetProcesses.SVMXC__Name__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__Description__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__ProcessID__c = 'Timesheet_1';
        
        insert timesheetProcesses;
        
        RecordType scheduleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name =: TMST_Consts.RECORD_TYPE_SCHEDULE LIMIT 1];
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.SVMXC__Dispatch_Process__c = timesheetProcesses.Id;
        configData.RecordTypeId = scheduleRecordType.Id;
        configData.SVMXC__Schedule_Type__c = null;
        configData.SVMXC__Active__c = true;
        
        insert configData;
                
        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();        
        TMST_WrapperDef.TMST_Response response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testGetAllTimesheetProcess_Invalid_Schedule_Type() {

        Test.startTest();
        
        RecordType timesheetRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name =: TMST_Consts.RECORD_TYPE_TIMESHEET LIMIT 1];
        
        SVMXC__ServiceMax_Processes__c timesheetProcesses = new SVMXC__ServiceMax_Processes__c();
        timesheetProcesses.RecordTypeId = timesheetRecordType.Id;
        timesheetProcesses.SVMXC__Name__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__Description__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__ProcessID__c = 'Timesheet_1';
        
        insert timesheetProcesses;
        
        RecordType scheduleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name =: TMST_Consts.RECORD_TYPE_SCHEDULE LIMIT 1];
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.SVMXC__Dispatch_Process__c = timesheetProcesses.Id;
        configData.RecordTypeId = scheduleRecordType.Id;
        configData.SVMXC__Schedule_Type__c = 'Invalid';
        configData.SVMXC__Active__c = true;
        
        insert configData;
                
        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();        
        TMST_WrapperDef.TMST_Response response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testGetAllTimesheetProcess_Schedule_Type_Validation() {

        Test.startTest();
        
        RecordType timesheetRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name =: TMST_Consts.RECORD_TYPE_TIMESHEET LIMIT 1];
        
        SVMXC__ServiceMax_Processes__c timesheetProcesses = new SVMXC__ServiceMax_Processes__c();
        timesheetProcesses.RecordTypeId = timesheetRecordType.Id;
        timesheetProcesses.SVMXC__Name__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__Description__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__ProcessID__c = 'Timesheet_1';
                
        insert timesheetProcesses;
        
        RecordType scheduleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name =: TMST_Consts.RECORD_TYPE_SCHEDULE LIMIT 1];
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.SVMXC__Dispatch_Process__c = timesheetProcesses.Id;
        configData.RecordTypeId = scheduleRecordType.Id;
        configData.SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_HEADER;
        
        insert configData;
                
        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();        
        TMST_WrapperDef.TMST_Response response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( !response.timesheetConfigurationList.isEmpty() );
        
        Test.stopTest();
    }

    static testMethod void testGetAllTimesheetProcess_Invalid_Profile_Reference() {

        Test.startTest();
        
        RecordType timesheetRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name =: TMST_Consts.RECORD_TYPE_TIMESHEET LIMIT 1];
        
        SVMXC__ServiceMax_Processes__c timesheetProcesses = new SVMXC__ServiceMax_Processes__c();
        timesheetProcesses.RecordTypeId = timesheetRecordType.Id;
        timesheetProcesses.SVMXC__Name__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__Description__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__ProcessID__c = 'Timesheet_1';
                
        insert timesheetProcesses;
        
        RecordType scheduleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name =: TMST_Consts.RECORD_TYPE_SCHEDULE LIMIT 1];
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.SVMXC__Dispatch_Process__c = timesheetProcesses.Id;
        configData.RecordTypeId = scheduleRecordType.Id;
        configData.SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_HEADER;
        
        insert configData;

        RecordType profileRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name =: TMST_Consts.RECORD_TYPE_CONFIGURATION_PROFILE LIMIT 1];
        
        SVMXC__ServiceMax_Config_Data__c configProfile = new SVMXC__ServiceMax_Config_Data__c();
        configProfile.SVMXC__Profile_Name__c = 'Timesheet_Profile';
        configProfile.RecordTypeId = profileRecordType.Id;
        configProfile.SVMXC__Description__c = 'Timesheet_Profile';
        configProfile.SVMXC__Active__c = true;
        
        insert configProfile;
        
        RecordType timesheetAccessRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name =: TMST_Consts.RECORD_TYPE_TIMESHEET_ACCESS LIMIT 1];
        
        SVMXC__ServiceMax_Config_Data__c timesheetAccess = new SVMXC__ServiceMax_Config_Data__c();
        timesheetAccess.SVMXC__Access_Configuration_Profile__c = configProfile.Id;
        timesheetAccess.RecordTypeId = timesheetAccessRecordType.Id;
        timesheetAccess.SVMXC__Dispatch_Process__c = timesheetProcesses.Id;
        
        insert timesheetAccess;
        
        delete configProfile;
                
        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();        
        TMST_WrapperDef.TMST_Response response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.warning );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( !response.timesheetConfigurationList.isEmpty() );
        
        Test.stopTest();
    }

    static testMethod void testGetAllTimesheetProcess() {

        Test.startTest();
        
        RecordType timesheetRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name =: TMST_Consts.RECORD_TYPE_TIMESHEET LIMIT 1];
        
        SVMXC__ServiceMax_Processes__c timesheetProcesses = new SVMXC__ServiceMax_Processes__c();
        timesheetProcesses.RecordTypeId = timesheetRecordType.Id;
        timesheetProcesses.SVMXC__Name__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__Description__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__ProcessID__c = 'Timesheet_1';
        
        insert timesheetProcesses;
        
        RecordType scheduleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name =: TMST_Consts.RECORD_TYPE_SCHEDULE LIMIT 1];
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.SVMXC__Dispatch_Process__c = timesheetProcesses.Id;
        configData.RecordTypeId = scheduleRecordType.Id;
        configData.SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_HEADER;
        
        insert configData;

        RecordType profileRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name =: TMST_Consts.RECORD_TYPE_CONFIGURATION_PROFILE LIMIT 1];
        
        SVMXC__ServiceMax_Config_Data__c configProfile = new SVMXC__ServiceMax_Config_Data__c();
        configProfile.SVMXC__Profile_Name__c = 'Timesheet_Profile';
        configProfile.RecordTypeId = profileRecordType.Id;
        configProfile.SVMXC__Description__c = 'Timesheet_Profile';
        configProfile.SVMXC__Active__c = true;
        timesheetProcesses.SVMXC__Start_Date__c = Date.today();
        timesheetProcesses.SVMXC__End_Date__c = Date.today() + 1;
        
        insert configProfile;
        
        RecordType timesheetAccessRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name =: TMST_Consts.RECORD_TYPE_TIMESHEET_ACCESS LIMIT 1];
        
        SVMXC__ServiceMax_Config_Data__c timesheetAccess = new SVMXC__ServiceMax_Config_Data__c();
        timesheetAccess.SVMXC__Access_Configuration_Profile__c = configProfile.Id;
        timesheetAccess.RecordTypeId = timesheetAccessRecordType.Id;
        timesheetAccess.SVMXC__Dispatch_Process__c = timesheetProcesses.Id;
        
        insert timesheetAccess;
                
        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();        
        TMST_WrapperDef.TMST_Response response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( !response.timesheetConfigurationList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testDeleteTimesheetProcess_Null_Request() {

        Test.startTest();
        
        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();        
        TMST_WrapperDef.TMST_Response response = timesheetManager.deleteTimesheetProcess( null );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( response.timesheetConfigurationList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testDeleteTimesheetProcess_Empty_ConfigurationList() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();
        
        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();        
        TMST_WrapperDef.TMST_Response response = timesheetManager.deleteTimesheetProcess( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( response.timesheetConfigurationList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testDeleteTimesheetProcess_Null_ProcessID() {

        Test.startTest();

        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = new TMST_WrapperDef.TMST_TimesheetConfiguration();
        timesheetConfiguration.timesheetProcess = new SVMXC__ServiceMax_Processes__c();
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );
        
        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();        
        TMST_WrapperDef.TMST_Response response = timesheetManager.deleteTimesheetProcess( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( response.timesheetConfigurationList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testDeleteTimesheetProcess_Invalid_ProcessID() {

        Test.startTest();

        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = new TMST_WrapperDef.TMST_TimesheetConfiguration();
        
        SVMXC__ServiceMax_Processes__c timesheetProcesses = new SVMXC__ServiceMax_Processes__c();
        timesheetProcesses.SVMXC__ProcessID__c = 'Invalid';
        
        timesheetConfiguration.timesheetProcess = timesheetProcesses;
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );
        
        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();        
        TMST_WrapperDef.TMST_Response response = timesheetManager.deleteTimesheetProcess( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( response.timesheetConfigurationList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testDeleteTimesheetProcess_ReadOnlyMode() {

        Test.startTest();
        
        RecordType timesheetRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name =: TMST_Consts.RECORD_TYPE_TIMESHEET LIMIT 1];
        
        SVMXC__ServiceMax_Processes__c timesheetProcesses = new SVMXC__ServiceMax_Processes__c();
        timesheetProcesses.RecordTypeId = timesheetRecordType.Id;
        timesheetProcesses.SVMXC__Name__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__Description__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__ProcessID__c = 'Timesheet_1';
        
        insert timesheetProcesses;
        
        RecordType scheduleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name =: TMST_Consts.RECORD_TYPE_SCHEDULE LIMIT 1];
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.SVMXC__Dispatch_Process__c = timesheetProcesses.Id;
        configData.RecordTypeId = scheduleRecordType.Id;
        
        insert configData;
        
        Test.setReadOnlyApplicationMode(true);
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = new TMST_WrapperDef.TMST_TimesheetConfiguration();
        timesheetConfiguration.timesheetProcess = timesheetProcesses;
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );
        
        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.deleteTimesheetProcess( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( response.messageList != null );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG006) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testDeleteTimesheetProcess() {

        Test.startTest();
        
        RecordType timesheetRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name =: TMST_Consts.RECORD_TYPE_TIMESHEET LIMIT 1];
        
        SVMXC__ServiceMax_Processes__c timesheetProcesses = new SVMXC__ServiceMax_Processes__c();
        timesheetProcesses.RecordTypeId = timesheetRecordType.Id;
        timesheetProcesses.SVMXC__Name__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__Description__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__ProcessID__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__Start_Date__c = Date.today();
        timesheetProcesses.SVMXC__End_Date__c = Date.today() + 1;
        
        insert timesheetProcesses;
        
        RecordType scheduleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name =: TMST_Consts.RECORD_TYPE_SCHEDULE LIMIT 1];
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.SVMXC__Dispatch_Process__c = timesheetProcesses.Id;
        configData.RecordTypeId = scheduleRecordType.Id;
        configData.SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_HEADER;
        
        insert configData;
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = new TMST_WrapperDef.TMST_TimesheetConfiguration();
        timesheetConfiguration.timesheetProcess = timesheetProcesses;
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );
        
        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();        
        TMST_WrapperDef.TMST_Response response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( !response.timesheetConfigurationList.isEmpty() );
        
        response = timesheetManager.deleteTimesheetProcess( request );
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );        
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_Null_Request() {

        Test.startTest();
        
        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();        
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( null );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG001) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_Empty_ConfigurationList() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();
        
        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();        
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG001) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_Null_Timesheet_Configuration() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();
        request.timesheetConfigurationList.add( null );
        
        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();        
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG001) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );
        
        Test.stopTest();
    }

    static testMethod void testSaveTimesheetConfiguration_Null_ProcessID() {

        Test.startTest();
        
        RecordType timesheetRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name =: TMST_Consts.RECORD_TYPE_TIMESHEET LIMIT 1];
        
        SVMXC__ServiceMax_Processes__c timesheetProcesses = new SVMXC__ServiceMax_Processes__c();
        timesheetProcesses.RecordTypeId = timesheetRecordType.Id;
        timesheetProcesses.SVMXC__Name__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__Description__c = 'Timesheet_1';
                
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = new TMST_WrapperDef.TMST_TimesheetConfiguration();
        timesheetConfiguration.timesheetProcess = timesheetProcesses;
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );
        
        TMST_WrapperDef.TMST_Response response;
        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );
        
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( !response.timesheetConfigurationList.isEmpty() );   
        
        timesheetConfiguration = response.timesheetConfigurationList[0];
        
        System.Assert( timesheetConfiguration.timesheetProcess != null );
        System.Assert( timesheetConfiguration.timesheetProcess.Id != null );
        System.Assert( timesheetConfiguration.timesheetProcess.SVMXC__Name__c == 'Timesheet_1' );
        
        System.Assert( timesheetConfiguration.scheduleDetailsList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_Null_Timesheet_Access() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();
        timesheetConfiguration.assignedProfilesList.clear();
        timesheetConfiguration.assignedProfilesList.add( null );
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );
        
        TMST_WrapperDef.TMST_Response response;
        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );
        
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG007) );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );   
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_ReadOnlyMode() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();
        Test.setReadOnlyApplicationMode(true);
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );
        
        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();        
        
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG006) );
        
        Test.stopTest();
    }
   
    static testMethod void testSaveTimesheetConfiguration() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );
        
        TMST_WrapperDef.TMST_Response response;
        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );
        
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( !response.timesheetConfigurationList.isEmpty() );   
        
        TMST_WrapperDef.TMST_TimesheetConfiguration responseTimesheetConfiguration = response.timesheetConfigurationList[0];
        
        System.Assert( responseTimesheetConfiguration.timesheetProcess != null );
        System.Assert( responseTimesheetConfiguration.timesheetProcess.Id != null );
        System.Assert( responseTimesheetConfiguration.timesheetProcess.SVMXC__Name__c == 'Timesheet_1' );
        System.Assert( responseTimesheetConfiguration.timesheetProcess.SVMXC__ProcessID__c == 'Timesheet_1' );
        System.Assert( responseTimesheetConfiguration.timesheetProcess.SVMXC__Business_Hours__c == timesheetConfiguration.timesheetProcess.SVMXC__Business_Hours__c );
        System.Assert( responseTimesheetConfiguration.timesheetProcess.SVMXC__Event_Type__c == 'Event' );
        System.Assert( responseTimesheetConfiguration.timesheetProcess.SVMXC__Field_Name__c == 'Work_Detail_Ownership' );
        
        System.Assert( ! responseTimesheetConfiguration.scheduleDetailsList.isEmpty(), response.messageList );
        System.Assert( responseTimesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Dispatch_Process__c == responseTimesheetConfiguration.timesheetProcess.Id );     
        
        request.timesheetConfigurationList.get(0).scheduleDetailsList.get(0).Id = responseTimesheetConfiguration.scheduleDetailsList.get(0).Id;
        
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        
        request.timesheetConfigurationList.get(0).scheduleDetailsList.get(0).Id = null;
        
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( !response.timesheetConfigurationList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_Null_Schedule_Details() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();
        timesheetConfiguration.scheduleDetailsList = null;
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );

        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG008), response.messageList.get(0) );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_Timesheet_Name_Validation() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();
        timesheetConfiguration.timesheetProcess.SVMXC__Name__c = null;
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );

        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        timesheetConfiguration.timesheetProcess.SVMXC__Name__c = '';
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        timesheetConfiguration.timesheetProcess.SVMXC__Name__c = '    ';
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        String longString = '';
        for( Integer i = 0; i < 256; i++ ) { longString += 'A'; }
        
        timesheetConfiguration.timesheetProcess.SVMXC__Name__c = longString;
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG010), response.messageList.get(0) );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_Timesheet_ProcessID_Validation() {

        Test.startTest();
        
        String longString = '';
        for( Integer i = 0; i < 200; i++ ) { longString += 'A'; }
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();
        timesheetConfiguration.timesheetProcess.SVMXC__Active__c = false;
        timesheetConfiguration.timesheetProcess.SVMXC__Name__c = longString;
        timesheetConfiguration.timesheetProcess.SVMXC__Description__c = longString;
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();
        request.timesheetConfigurationList.add( timesheetConfiguration );

        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_Timesheet_Description_Validation() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();
        timesheetConfiguration.timesheetProcess.SVMXC__Description__c = null;
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );

        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        timesheetConfiguration.timesheetProcess.SVMXC__Description__c = '';
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        timesheetConfiguration.timesheetProcess.SVMXC__Description__c = '    ';
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        String longString = '';
        for( Integer i = 0; i < 32001; i++ ) { longString += 'A'; }
        
        timesheetConfiguration.timesheetProcess.SVMXC__Description__c = longString;
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG011), response.messageList.get(0) );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_Timezone_Validation() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();
        timesheetConfiguration.timesheetProcess.SVMXC__Dispatch_Timezone__c = null;        
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );

        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_With_Period_Daily() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();
        timesheetConfiguration.timesheetProcess.SVMXC__Active__c = false;
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Period__c = TMST_Consts.PERIOD_DAILY;
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_AUTOFILL;
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );

        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( !response.timesheetConfigurationList.isEmpty() );   
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_With_Period_Weekly() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );

        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( !response.timesheetConfigurationList.isEmpty() );   
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_With_Period_Monthly() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Period__c = TMST_Consts.PERIOD_MONTHLY;
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Run_Type__c = TMST_Consts.RUN_TYPE_DATE_OF_MONTH;
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );

        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( !response.timesheetConfigurationList.isEmpty() );   
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_With_Period_Bi_Monthly() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Period__c = TMST_Consts.PERIOD_BI_MONTHLY;
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Run_Type__c = TMST_Consts.RUN_TYPE_DATE_OF_MONTH;
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );

        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( !response.timesheetConfigurationList.isEmpty() );   
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_With_Unsupported_Period() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();        
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Period__c = 'Unsupported';
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );

        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Period__c = TMST_Consts.PERIOD_DAILY;
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_HEADER;
        
        request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );

        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_Email_On_Success_Validation() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();
        timesheetConfiguration.timesheetProcess.SVMXC__Email_On_Success__c = 'Invalid';
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );

        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        timesheetConfiguration.timesheetProcess.SVMXC__Email_On_Success__c = null;
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( response.success );
        
        timesheetConfiguration.timesheetProcess.SVMXC__Email_On_Success__c = 'test@servicemax.com';
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( response.success );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( !response.timesheetConfigurationList.isEmpty() );   
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_Email_On_Error_Validation() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();
        timesheetConfiguration.timesheetProcess.SVMXC__Email_On_Error__c = 'Invalid';
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );

        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        timesheetConfiguration.timesheetProcess.SVMXC__Email_On_Error__c = null;
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( response.success );
        
        timesheetConfiguration.timesheetProcess.SVMXC__Email_On_Error__c = 'test@servicemax.com';
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( response.success );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( !response.timesheetConfigurationList.isEmpty() );   
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_Active_Validation() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();
        timesheetConfiguration.timesheetProcess.SVMXC__Active__c = true;
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Period__c = 'Unsupported';
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );

        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );   
        
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Active__c = false;
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Period__c = TMST_Consts.PERIOD_MONTHLY;
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_Rules_Validation() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();        
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Period__c = TMST_Consts.PERIOD_DAILY;
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_AUTOFILL;
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );

        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG014), response.messageList.get(0) );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );   
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_Schedule_StartEndDate_Validation() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();
        timesheetConfiguration.timesheetProcess.SVMXC__Start_Date__c = Date.today();
        timesheetConfiguration.timesheetProcess.SVMXC__End_Date__c  = Date.today() - 1;
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );

        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
                
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG012), response.messageList.get(0) );
        
        timesheetConfiguration.timesheetProcess.SVMXC__Start_Date__c = null;
        timesheetConfiguration.timesheetProcess.SVMXC__End_Date__c  = null;
        
        request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );
        
        response = timesheetManager.saveTimesheetConfiguration( request );
                
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_Schedule_Days_Validation() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Period__c = TMST_Consts.PERIOD_DAILY;
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Schedule_Days__c = null;
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );

        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Period__c = TMST_Consts.PERIOD_WEEKLY;
        
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Schedule_Days__c = 'Invalid';
        
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_Schedule_Type_Validation() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Period__c = TMST_Consts.PERIOD_DAILY;
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Schedule_Type__c = null;
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );

        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_HEADER;
        
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_Run_Type_Validation() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Period__c = TMST_Consts.PERIOD_DAILY;
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Run_Type__c = null;
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );

        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Run_Type__c = 'Invalid';
        
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Run_Type__c = TMST_Consts.RUN_TYPE_DATE_OF_MONTH;
        
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_Day_to_Run_Validation() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();
        timesheetConfiguration.timesheetProcess.SVMXC__Active__c = true;
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Period__c = TMST_Consts.PERIOD_MONTHLY;
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Day_to_Run__c = null;
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );

        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Period__c = TMST_Consts.PERIOD_BI_MONTHLY;
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Day_to_Run__c = null;
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Day_to_Run__c = 'Invalid';
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Day_to_Run__c = '0';
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Day_to_Run__c = '32';
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );   
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_Run_At_Validation() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();            
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Run_At__c = null;
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );

        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Run_At__c = 'Invalid';
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Period__c = TMST_Consts.PERIOD_DAILY;
        timesheetConfiguration.timesheetProcess.SVMXC__Active__c = true;        
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Run_At__c = null;
        
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );   
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_Start_Period_Date_Validation() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();        
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Period_Start_On__c = -1;
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );

        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG009), response.messageList.get(0) );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );
        
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Period_Start_On__c = 100;
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Period_Start_On__c = null;
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( response.success );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( !response.timesheetConfigurationList.isEmpty() );   
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_Work_Details_Validation() {

        Test.startTest();
        
        Id sampleId = '01pF0000003we8q';
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();        
        timesheetConfiguration.timesheetProcess.SVMXC__Process__c = sampleId;
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_AUTOFILL;
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );

        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG027), response.messageList.get(0) );
        
        timesheetConfiguration.timesheetProcess.SVMXC__Process__c = null;
        timesheetConfiguration.timesheetProcess.SVMXC__Process1__c = sampleId;
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        System.Assert( !response.messageList.isEmpty() );
        System.Assert( response.messageList.get(0).startsWithIgnoreCase( System.Label.TMST001_TAG027), response.messageList.get(0) );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_Salesforce_Event_Validation() {

        Test.startTest();
        
        Id sampleId = '01pF0000003we8q';
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();        
        timesheetConfiguration.timesheetProcess.SVMXC__Parent_Object__c = sampleId;
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_AUTOFILL;
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );

        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        
        timesheetConfiguration.timesheetProcess.SVMXC__Parent_Object__c = null;
        timesheetConfiguration.timesheetProcess.SVMXC__Process3__c = sampleId;
        
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        
        timesheetConfiguration.timesheetProcess.SVMXC__Parent_Object__c = null;
        timesheetConfiguration.timesheetProcess.SVMXC__Event_Type__c = TMST_Consts.EVENT_TYPE_BOTH;
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_AUTOFILL;
                
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_ServiceMax_Event_Validation() {

        Test.startTest();
        
        Id sampleId = '01pF0000003we8q';
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();        
        timesheetConfiguration.timesheetProcess.SVMXC__Submodule__c = sampleId;
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_AUTOFILL;
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );

        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        
        timesheetConfiguration.timesheetProcess.SVMXC__Submodule__c = null;
        timesheetConfiguration.timesheetProcess.SVMXC__Module__c = sampleId;
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_Task_Validation() {

        Test.startTest();
        
        Id sampleId = '01pF0000003we8q';
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();        
        timesheetConfiguration.timesheetProcess.SVMXC__Node_Parent__c = sampleId;
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_AUTOFILL;
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );

        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        
        timesheetConfiguration.timesheetProcess.SVMXC__Node_Parent__c = null;
        timesheetConfiguration.timesheetProcess.SVMXC__Process2__c = sampleId;
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_End_Period_Date_Validation() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();        
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Period_End_On__c = -1;
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );

        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );
        
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Period_Start_On__c = 5;
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Period_End_On__c = 2;
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Period_End_On__c = 100;
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Period_End_On__c = null;
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( response.success );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( !response.timesheetConfigurationList.isEmpty() );   
        
        Test.stopTest();
    }
    
    /*
    static testMethod void testSaveTimesheetConfiguration_Run_Every_Validation() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration(); 
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Run_Frequency__c = -1;
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );

        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Period__c = TMST_Consts.PERIOD_DAILY;
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Run_Frequency__c = 7;
        
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Period__c = TMST_Consts.PERIOD_MONTHLY;
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Run_Frequency__c = 13;
        
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );
        
        timesheetConfiguration.timesheetProcess.SVMXC__Active__c = true;
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Period__c = TMST_Consts.PERIOD_DAILY;
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Run_Frequency__c = null;
        
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        
        timesheetConfiguration.timesheetProcess.SVMXC__Active__c = false;
        timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Run_Frequency__c = null;
        
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( response.success );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( !response.timesheetConfigurationList.isEmpty() );   
        
        Test.stopTest();
    }
    */
    
    static testMethod void testSaveTimesheetConfiguration_With_Profile_Mapping() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );
        
        TMST_WrapperDef.TMST_Response response;
        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );
        
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( !response.timesheetConfigurationList.isEmpty() );   
        
        timesheetConfiguration = response.timesheetConfigurationList[0];
        
        System.Assert( timesheetConfiguration.timesheetProcess != null );
        System.Assert( timesheetConfiguration.timesheetProcess.Id != null );
        System.Assert( timesheetConfiguration.timesheetProcess.SVMXC__Name__c == 'Timesheet_1' );
        System.Assert( timesheetConfiguration.timesheetProcess.SVMXC__ProcessID__c == 'Timesheet_1' );
        
        System.Assert( ! timesheetConfiguration.scheduleDetailsList.isEmpty() );
        System.Assert( timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Dispatch_Process__c == timesheetConfiguration.timesheetProcess.Id );     
        
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveTimesheetConfiguration_Save_Removed_Profile_Mapping() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration();
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );
        
        TMST_WrapperDef.TMST_Response response;
        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( response.timesheetConfigurationList.isEmpty() );
        
        response = timesheetManager.saveTimesheetConfiguration( request );
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( !response.timesheetConfigurationList.isEmpty() );   
        
        timesheetConfiguration = response.timesheetConfigurationList[0];
        
        System.Assert( timesheetConfiguration.timesheetProcess != null );
        System.Assert( timesheetConfiguration.timesheetProcess.Id != null );
        System.Assert( timesheetConfiguration.timesheetProcess.SVMXC__Name__c == 'Timesheet_1' );
        System.Assert( timesheetConfiguration.timesheetProcess.SVMXC__ProcessID__c == 'Timesheet_1' );
        
        System.Assert( ! timesheetConfiguration.scheduleDetailsList.isEmpty() );
        System.Assert( timesheetConfiguration.scheduleDetailsList.get(0).SVMXC__Dispatch_Process__c == timesheetConfiguration.timesheetProcess.Id );     
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfigurationAfterRemoveProfile = buildTimesheetConfiguration();
        timesheetConfigurationAfterRemoveProfile.assignedProfilesList.clear();
        timesheetConfigurationAfterRemoveProfile.timesheetProcess.SVMXC__Active__c = false;
        
        request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfigurationAfterRemoveProfile );
        
        response = timesheetManager.saveTimesheetConfiguration( request );

        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        
        response = timesheetManager.getAllTimesheetProcess();
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        System.Assert( !response.timesheetConfigurationList.isEmpty() );
        
        timesheetConfiguration = response.timesheetConfigurationList[0];
        System.Assert( timesheetConfiguration.assignedProfilesList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testExecuteBatch_Null_Request() {

        Test.startTest();
                
        TMST_WrapperDef.TMST_Response response = new TMST_TimesheetManagerAPI().executeBatch( null );
        
        System.Assert( response != null );
        System.Assert( !response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        
        Test.stopTest();
    }
    
    static testMethod void testExecuteBatch_InActive_Processes() {

        Test.startTest();
        
        RecordType timesheetRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name =: TMST_Consts.RECORD_TYPE_TIMESHEET LIMIT 1];
        
        SVMXC__ServiceMax_Processes__c timesheetProcesses = new SVMXC__ServiceMax_Processes__c();
        timesheetProcesses.RecordTypeId = timesheetRecordType.Id;
        timesheetProcesses.SVMXC__Name__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__Description__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__ProcessID__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__Start_Date__c = Date.today();
        timesheetProcesses.SVMXC__End_Date__c = Date.today() + 1;
        timesheetProcesses.SVMXC__Active__c = false;
        
        insert timesheetProcesses;
        
        RecordType scheduleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name =: TMST_Consts.RECORD_TYPE_SCHEDULE LIMIT 1];
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.SVMXC__Dispatch_Process__c = timesheetProcesses.Id;
        configData.RecordTypeId = scheduleRecordType.Id;
        configData.SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_HEADER;
        
        insert configData;
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = new TMST_WrapperDef.TMST_TimesheetConfiguration();
        timesheetConfiguration.timesheetProcess = timesheetProcesses;
        timesheetConfiguration.scheduleDetailsList.add(configData);
        timesheetConfiguration.scheduleType = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_HEADER;
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );
                
        TMST_WrapperDef.TMST_Response response = new TMST_TimesheetManagerAPI().executeBatch( request );
        
        System.Assert( response != null );
        System.Assert( !response.success );
        
        Test.stopTest();
    }

    static testMethod void testExecuteBatch() {

        Test.startTest();
        
        RecordType timesheetRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name =: TMST_Consts.RECORD_TYPE_TIMESHEET LIMIT 1];
        
        SVMXC__ServiceMax_Processes__c timesheetProcesses = new SVMXC__ServiceMax_Processes__c();
        timesheetProcesses.RecordTypeId = timesheetRecordType.Id;
        timesheetProcesses.SVMXC__Name__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__Description__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__ProcessID__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__Start_Date__c = Date.today();
        timesheetProcesses.SVMXC__End_Date__c = Date.today() + 1;
        timesheetProcesses.SVMXC__Active__c = true;
        
        insert timesheetProcesses;
        
        RecordType scheduleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name =: TMST_Consts.RECORD_TYPE_SCHEDULE LIMIT 1];
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.SVMXC__Dispatch_Process__c = timesheetProcesses.Id;
        configData.RecordTypeId = scheduleRecordType.Id;
        configData.SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_HEADER;
        configData.SVMXC__Active__c = true;
        
        insert configData;
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = new TMST_WrapperDef.TMST_TimesheetConfiguration();
        timesheetConfiguration.timesheetProcess = timesheetProcesses;
        timesheetConfiguration.scheduleDetailsList.add(configData);
        timesheetConfiguration.scheduleType = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_HEADER;
        
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        request.timesheetConfigurationList.add( timesheetConfiguration );
                
        TMST_WrapperDef.TMST_Response response = new TMST_TimesheetManagerAPI().executeBatch( request );
        
        System.Assert( response != null );
        System.Assert( response.success, TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK ) );
        
        Test.stopTest();
    }
   
    private static TMST_WrapperDef.TMST_TimesheetConfiguration buildTimesheetConfiguration() {
        
        RecordType timesheetRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name =: TMST_Consts.RECORD_TYPE_TIMESHEET LIMIT 1];
        BusinessHours businessHour = [SELECT Id,Name FROM BusinessHours WHERE IsActive = true LIMIT 1];
        RecordType scheduleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name =: TMST_Consts.RECORD_TYPE_SCHEDULE LIMIT 1];
                
        return buildTimesheetConfiguration(timesheetRecordType, businessHour, scheduleRecordType, true);
    }
    
    private static TMST_WrapperDef.TMST_TimesheetConfiguration buildTimesheetConfiguration( RecordType timesheetRecordType, BusinessHours businessHour, RecordType scheduleRecordType, Boolean withProfile ) {
    
        SVMXC__ServiceMax_Processes__c timesheetProcesses = new SVMXC__ServiceMax_Processes__c();
    
        timesheetProcesses.RecordTypeId = timesheetRecordType.Id;
        timesheetProcesses.SVMXC__Name__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__Description__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__ProcessID__c = 'Timesheet_1';
        timesheetProcesses.SVMXC__Active__c = true;
        timesheetProcesses.SVMXC__Dispatch_Timezone__c = 'Asia/Kolkata';
        
        timesheetProcesses.SVMXC__Start_Date__c = Date.today();
        timesheetProcesses.SVMXC__End_Date__c = Date.today() + 1;
        
        timesheetProcesses.SVMXC__Business_Hours__c = businessHour.Id;
        timesheetProcesses.SVMXC__Event_Type__c = 'Event';
        timesheetProcesses.SVMXC__Field_Name__c = 'Work_Detail_Ownership';
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.RecordTypeId = scheduleRecordType.Id;
        configData.SVMXC__Active__c = true;
        configData.SVMXC__Period__c = TMST_Consts.PERIOD_WEEKLY;
        configData.SVMXC__Schedule_Days__c = 'Monday';
        configData.SVMXC__Run_At__c = '8:00 AM';
        configData.SVMXC__Day_to_Run__c = '1';
        //configData.SVMXC__Run_Frequency__c = 1;
        configData.SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_HEADER;
        configData.SVMXC__Run_Type__c = TMST_Consts.RUN_TYPE_DAY_OF_WEEK;
        
        SVMXC__ServiceMax_Config_Data__c configProfile = new SVMXC__ServiceMax_Config_Data__c();
        
        if( withProfile ) {
            
            RecordType profileRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name =: TMST_Consts.RECORD_TYPE_CONFIGURATION_PROFILE LIMIT 1];
            
            configProfile.SVMXC__Profile_Name__c = 'Timesheet_Profile';
            configProfile.RecordTypeId = profileRecordType.Id;
            configProfile.SVMXC__Description__c = 'Timesheet_Profile';
            configProfile.SVMXC__Active__c = true;
            configProfile.SVMXC__Configuration_Type__c = TMST_Consts.CONFIGURATION_TYPE_GROUP;
            
            insert configProfile;
        }
        
        TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = new TMST_WrapperDef.TMST_TimesheetConfiguration();
        timesheetConfiguration.timesheetProcess = timesheetProcesses;
        timesheetConfiguration.scheduleDetailsList.add( configData );
        
        if( withProfile ) {
            
            TMST_WrapperDef.TMST_TimesheetAccess timesheetAccess = new TMST_WrapperDef.TMST_TimesheetAccess();
            timesheetAccess.configProfile = new SVMXC__ServiceMax_Config_Data__c( Id = configProfile.Id );

            timesheetConfiguration.assignedProfilesList.add( timesheetAccess );
        }
        
        return timesheetConfiguration;
    } 
    
    static testMethod void loadTesting_10() {
    
        Test.startTest();
        
        TMST_WrapperDef.TMST_Request request = buildTMST_Request(10);
        
        Integer queries = Limits.getQueries();
        Integer dmlRows = Limits.getDmlRows();
        Integer dmlStatements = Limits.getDmlStatements();
        Integer cpuTime = Limits.getCpuTime();
        Integer heapSize = Limits.getHeapSize();
        
        Long startTime = System.currentTimeMillis();            
        
        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
        
        Long processTime = System.currentTimeMillis() - startTime;
        
        System.debug('Load Test - Execution Time ' + processTime );
        System.debug('Load Test - Queries ' + ( Limits.getQueries() - queries ) );
        System.debug('Load Test - Dml Rows ' + ( Limits.getDmlRows() - dmlRows ) );
        System.debug('Load Test - DML Statements ' + ( Limits.getDmlStatements() - dmlStatements ) );
        System.debug('Load Test - Cpu Time ' + Limits.getCpuTime() );
        System.debug('Load Test - Heap Size ' + ( Limits.getHeapSize() - heapSize ) );
        
        System.assert( ( Limits.getQueries() - queries ) < 10, 'Actual: ' + ( Limits.getQueries() - queries ) );
        //System.assert( ( Limits.getDmlRows() - dmlRows ) == 21, 'Actual: ' + ( Limits.getDmlRows() - dmlRows ) );
        System.assert( ( Limits.getDmlStatements() - dmlStatements ) < 10, 'Actual: ' + ( Limits.getDmlStatements() - dmlStatements ) );        
        //System.assert( ( Limits.getHeapSize() - heapSize ) < 1200, ( Limits.getHeapSize() - heapSize ) );
                
        Test.stopTest();
    }
    
    static testMethod void loadTesting_50() {
    
        Test.startTest();
        {
            TMST_WrapperDef.TMST_Request request = buildTMST_Request(50);
            
            Integer queries = Limits.getQueries();
            Integer dmlRows = Limits.getDmlRows();
            Integer dmlStatements = Limits.getDmlStatements();
            Integer cpuTime = Limits.getCpuTime();
            Integer heapSize = Limits.getHeapSize();
            
            Long startTime = System.currentTimeMillis();            
            
            TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
            TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
            
            Long processTime = System.currentTimeMillis() - startTime;
            
            System.debug('Load Test - Execution Time ' + processTime );
            System.debug('Load Test - Queries ' + ( Limits.getQueries() - queries ) );
            System.debug('Load Test - Dml Rows ' + ( Limits.getDmlRows() - dmlRows ) );
            System.debug('Load Test - DML Statements ' + ( Limits.getDmlStatements() - dmlStatements ) );
            System.debug('Load Test - Cpu Time ' + Limits.getCpuTime() );
            System.debug('Load Test - Heap Size ' + ( Limits.getHeapSize() - heapSize ) );
                    
            System.assert( ( Limits.getQueries() - queries ) < 10, 'Actual: ' + ( Limits.getQueries() - queries ) );
            //System.assert( ( Limits.getDmlRows() - dmlRows ) == 101, 'Actual: ' + ( Limits.getDmlRows() - dmlRows ) );
            System.assert( ( Limits.getDmlStatements() - dmlStatements ) < 10, 'Actual: ' + ( Limits.getDmlStatements() - dmlStatements ) );
            //System.assert( ( Limits.getHeapSize() - heapSize ) < 1200, ( Limits.getHeapSize() - heapSize ) );
        }        
        Test.stopTest();
    }
    
    static testMethod void loadTesting_100() {
    
        Test.startTest();
        {
            TMST_WrapperDef.TMST_Request request = buildTMST_Request(100);
            
            Integer queries = Limits.getQueries();
            Integer dmlRows = Limits.getDmlRows();
            Integer dmlStatements = Limits.getDmlStatements();
            Integer cpuTime = Limits.getCpuTime();
            Integer heapSize = Limits.getHeapSize();
            
            Long startTime = System.currentTimeMillis();            
            
            TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
            TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
            
            Long processTime = System.currentTimeMillis() - startTime;
            
            System.debug('Load Test - Execution Time ' + processTime );
            System.debug('Load Test - Queries ' + ( Limits.getQueries() - queries ) );
            System.debug('Load Test - Dml Rows ' + ( Limits.getDmlRows() - dmlRows ) );
            System.debug('Load Test - DML Statements ' + ( Limits.getDmlStatements() - dmlStatements ) );
            System.debug('Load Test - Cpu Time ' + Limits.getCpuTime() );
            System.debug('Load Test - Heap Size ' + ( Limits.getHeapSize() - heapSize ) );
                    
            System.assert( ( Limits.getQueries() - queries ) < 10, 'Actual: ' + ( Limits.getQueries() - queries ) );
            //System.assert( ( Limits.getDmlRows() - dmlRows ) == 201, 'Actual: ' + ( Limits.getDmlRows() - dmlRows ) );
            System.assert( ( Limits.getDmlStatements() - dmlStatements ) < 10, 'Actual: ' + ( Limits.getDmlStatements() - dmlStatements ) );
            //System.assert( ( Limits.getHeapSize() - heapSize ) < 1200, ( Limits.getHeapSize() - heapSize ) );
        }        
        Test.stopTest();
    }
    
    /* commented loadTesting_500 and loadTesting_1000 methods as part of cpu time issue during package upload 
     * 
     * static testMethod void loadTesting_500() {
    
        Test.startTest();
        {
            TMST_WrapperDef.TMST_Request request = buildTMST_Request(500);
            
            Integer queries = Limits.getQueries();
            Integer dmlRows = Limits.getDmlRows();
            Integer dmlStatements = Limits.getDmlStatements();
            Integer cpuTime = Limits.getCpuTime();
            Integer heapSize = Limits.getHeapSize();
            
            Long startTime = System.currentTimeMillis();            
            
            TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
            TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
            
            Long processTime = System.currentTimeMillis() - startTime;
            
            System.debug('Load Test - Execution Time ' + processTime );
            System.debug('Load Test - Queries ' + ( Limits.getQueries() - queries ) );
            System.debug('Load Test - Dml Rows ' + ( Limits.getDmlRows() - dmlRows ) );
            System.debug('Load Test - DML Statements ' + ( Limits.getDmlStatements() - dmlStatements ) );
            System.debug('Load Test - Cpu Time ' + Limits.getCpuTime() );
            System.debug('Load Test - Heap Size ' + ( Limits.getHeapSize() - heapSize ) );
                    
            System.assert( ( Limits.getQueries() - queries ) < 15, 'Actual: ' + ( Limits.getQueries() - queries ) );
            //System.assert( ( Limits.getDmlRows() - dmlRows ) == 1001, 'Actual: ' + ( Limits.getDmlRows() - dmlRows ) );
            System.assert( ( Limits.getDmlStatements() - dmlStatements ) < 10, 'Actual: ' + ( Limits.getDmlStatements() - dmlStatements ) );        
            //System.assert( ( Limits.getHeapSize() - heapSize ) < 1200, ( Limits.getHeapSize() - heapSize ) );
        }        
        Test.stopTest();
    }
    */
    /*
      static testMethod void loadTesting_1000() {
       {
            TMST_WrapperDef.TMST_Request request = buildTMST_Request(1000);
            
            Integer queries = Limits.getQueries();
            Integer dmlRows = Limits.getDmlRows();
            Integer dmlStatements = Limits.getDmlStatements();
            Integer cpuTime = Limits.getCpuTime();
            Integer heapSize = Limits.getHeapSize();
            
            Long startTime = System.currentTimeMillis();            
            
            TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
            Test.startTest();
            TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
            Test.stopTest();
            Long processTime = System.currentTimeMillis() - startTime;
            
            System.debug('Load Test - Execution Time ' + processTime );
            System.debug('Load Test - Queries ' + ( Limits.getQueries() - queries ) );
            System.debug('Load Test - Dml Rows ' + ( Limits.getDmlRows() - dmlRows ) );
            System.debug('Load Test - DML Statements ' + ( Limits.getDmlStatements() - dmlStatements ) );
            System.debug('Load Test - Cpu Time ' + Limits.getCpuTime() );
            System.debug('Load Test - Heap Size ' + ( Limits.getHeapSize() - heapSize ) );
                    
            System.assert( ( Limits.getQueries() - queries ) < 16, 'Actual: ' + ( Limits.getQueries() - queries ) );
            //System.assert( ( Limits.getDmlRows() - dmlRows ) == 2001, 'Actual: ' + ( Limits.getDmlRows() - dmlRows ) );
            System.assert( ( Limits.getDmlStatements() - dmlStatements ) < 10, 'Actual: ' + ( Limits.getDmlStatements() - dmlStatements ) );        
            //System.assert( ( Limits.getHeapSize() - heapSize ) < 1200, ( Limits.getHeapSize() - heapSize ) );
        }        
        
    }*/
    
    private static TMST_WrapperDef.TMST_Request buildTMST_Request( Integer requestCount ) {
    
        RecordType timesheetRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name =: TMST_Consts.RECORD_TYPE_TIMESHEET LIMIT 1];
        TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();        
        
        BusinessHours businessHour = [SELECT Id,Name FROM BusinessHours WHERE IsActive = true LIMIT 1];
        RecordType scheduleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name =: TMST_Consts.RECORD_TYPE_SCHEDULE LIMIT 1];
        
        for( Integer i = 0; i < requestCount; i++ ) {
          
            TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = buildTimesheetConfiguration(timesheetRecordType, businessHour, scheduleRecordType, false);
            
            timesheetConfiguration.timesheetProcess.RecordTypeId = timesheetRecordType.Id;
            timesheetConfiguration.timesheetProcess.SVMXC__Name__c = 'Timesheet_' + i;
            timesheetConfiguration.timesheetProcess.SVMXC__Description__c = 'Timesheet_' + i;
            timesheetConfiguration.timesheetProcess.SVMXC__ProcessID__c = 'Timesheet_' + i;
            timesheetConfiguration.timesheetProcess.SVMXC__Active__c = false;
            
            request.timesheetConfigurationList.add( timesheetConfiguration );
        }
        
        return request;
    }
}