@isTest
private class TMST_TimesheetManager_UT {
  
    static testMethod void testGetObjectMappingAndSVMXRules() {

        Object result = TMST_TimesheetManager.getObjectMappingAndSVMXRules( null );
        
        System.assert( result != null );
        System.assert( ( (String) result).contains( '"success":true' ) );
        Object eresult = TMST_TimesheetManager.executeBatch( '{"timesheetProcessId":"Demo Tim1437029871014","scheduleType":"TimesheetAutofill"}' );
    }
    
    static testMethod void testGetWorkDetailOwnership() {

        Object result = TMST_TimesheetManager.getWorkDetailOwnership( null );
        
        System.assert( result != null );
        System.assert( ( (String) result).contains( '"success":true' ) );        
    }
    
    static testMethod void testGetBusinessHours() {

        Object result = TMST_TimesheetManager.getBusinessHours( null );
        
        System.assert( result != null );
        System.assert( ( (String) result).contains( '"success":true' ) );        
    }
    
    static testMethod void testGetAllTimezones() {

        Object result = TMST_TimesheetManager.getAllTimezones( null );
        
        System.assert( result != null );
        System.assert( ( (String) result).contains( '"success":true' ) );        
    }
    
    static testMethod void testGetAllTimesheetProcess_Empty_Result() {

        new TMST_TimesheetManager();
        Object result = TMST_TimesheetManager.getAllTimesheetProcess( null );
        
        System.assert( result != null );
        System.assert( ( (String) result).contains( '"success":true' ) );
        System.assert( ( (String) result).contains( '"timesheetInfoList":[]' ) );
    }
    
    static testMethod void testGetAllTimesheetProcess() {
    
        Test.startTest();

        RecordType timesheetRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name =: TMST_Consts.RECORD_TYPE_TIMESHEET LIMIT 1];
        
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = timesheetRecordType.Id;
        process.SVMXC__Name__c = 'Timesheet';
        process.SVMXC__Description__c = 'Timesheet';
        process.SVMXC__ProcessID__c = 'Timesheet_Process_ID';
        
        insert process;
        
        RecordType scheduleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name =: TMST_Consts.RECORD_TYPE_SCHEDULE LIMIT 1];
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.SVMXC__Dispatch_Process__c = process.Id;
        configData.RecordTypeId = scheduleRecordType.Id;
        configData.SVMXC__Day_to_Run__c = '1';
        configData.SVMXC__Sequence__c = 1;
        configData.SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_HEADER;
        
        insert configData;
        
        configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.SVMXC__Dispatch_Process__c = process.Id;
        configData.RecordTypeId = scheduleRecordType.Id;
        configData.SVMXC__Day_to_Run__c = '1';
        configData.SVMXC__Sequence__c = 2;
        configData.SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_HEADER;
        
        insert configData;
        
        configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.SVMXC__Dispatch_Process__c = process.Id;
        configData.RecordTypeId = scheduleRecordType.Id;
        configData.SVMXC__Day_to_Run__c = '1';
        configData.SVMXC__Sequence__c = 1;
        configData.SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_AUTOFILL;
        
        insert configData;
        
        configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.SVMXC__Dispatch_Process__c = process.Id;
        configData.RecordTypeId = scheduleRecordType.Id;
        configData.SVMXC__Day_to_Run__c = '1';
        configData.SVMXC__Sequence__c = 2;
        configData.SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_AUTOFILL;
        
        insert configData;
        
        RecordType profileRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name =: TMST_Consts.RECORD_TYPE_CONFIGURATION_PROFILE LIMIT 1];
        
        SVMXC__ServiceMax_Config_Data__c configProfile = new SVMXC__ServiceMax_Config_Data__c();
        configProfile.SVMXC__Profile_Name__c = 'Timesheet_Profile';
        configProfile.RecordTypeId = profileRecordType.Id;
        configProfile.SVMXC__Description__c = 'Timesheet_Profile';
        configProfile.SVMXC__Active__c = true;        
        configProfile.SVMXC__Configuration_Type__c = TMST_Consts.CONFIGURATION_TYPE_GROUP;
        
        insert configProfile;
        
        RecordType timesheetAccessRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name =: TMST_Consts.RECORD_TYPE_TIMESHEET_ACCESS LIMIT 1];
        
        SVMXC__ServiceMax_Config_Data__c timesheetAccess = new SVMXC__ServiceMax_Config_Data__c();
        timesheetAccess.SVMXC__Access_Configuration_Profile__c = configProfile.Id;
        timesheetAccess.RecordTypeId = timesheetAccessRecordType.Id;
        timesheetAccess.SVMXC__Dispatch_Process__c = process.Id;
        
        insert timesheetAccess;
        
        Object result = TMST_TimesheetManager.getAllTimesheetProcess( null );
        
        System.assert( result != null );
        //System.assert( ( (String) result).contains( '"success":true' ) );
        //System.assert( ( (String) result).contains( '"timesheetProcessId":"Timesheet_Process_ID"') , (String) result );
        //System.assert( ( (String) result).contains( '"timesheetName":"Timesheet"' ) ); 
        
        String request = '{"timesheetProcessId":"Timesheet_Process_ID","timesheetName":"Timesheet","thresholdHoursPerPeriod":null,"thresholdHoursPerDay":null,"status":false,"showWeekends":null,"period":null,"notifyOnTimesheetCreation":false,"minimumIncrement":null,"minimumHoursPerPeriod":null,"minimumHoursPerDay":null,"maximumHoursPerPeriod":null,"maximumHoursPerDay":null,"lastModified":"2015-04-16","description":"Timesheet","assignedProfilesList":[{"timesheetProcessName":"Timesheet","timesheetProcessId":"Timesheet_Process_ID","status":true,"profileName":"Timesheet_Profile","profileId":"' + configProfile.Id +'","description":"Timesheet_Profile"}],"allowAutofill":null}';
        
        result = TMST_TimesheetManager.saveTimesheetConfiguration( request );
        
        System.assert( result != null );
        System.assert( ( (String) result).contains( '"success":true' ), (String) result ); 
        
        Test.stopTest();      
    }
    
    static testMethod void testDeleteTimesheetProcess_Null_Result() {

        Object result = TMST_TimesheetManager.deleteTimesheetProcess( null );
        
        System.assert( result != null );
        System.assert( ( (String) result).contains( '"success":false' ) );
        System.assert( ( (String) result).contains( '"message":"Invalid Argument"' ) );        
    }
    
    static testMethod void testDeleteTimesheetProcess_Invalid_Result() {

        String request = 'Invalid';
        Object result = TMST_TimesheetManager.deleteTimesheetProcess( request );
        
        System.assert( result != null );
        System.assert( ( (String) result).contains( '"success":false' ) );
        System.assert( ( (String) result).contains( '"message":"Invalid JSON request :' ), (String) result );        
    }
    
    static testMethod void testDeleteTimesheetProcess() {

        RecordType timesheetRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name =: TMST_Consts.RECORD_TYPE_TIMESHEET LIMIT 1];
        
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = timesheetRecordType.Id;
        process.SVMXC__Name__c = 'Timesheet';
        process.SVMXC__Description__c = 'Timesheet';
        process.SVMXC__ProcessID__c = 'Timesheet_Process_ID';
        
        insert process;
        
        RecordType scheduleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name =: TMST_Consts.RECORD_TYPE_SCHEDULE LIMIT 1];
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.SVMXC__Dispatch_Process__c = process.Id;
        configData.RecordTypeId = scheduleRecordType.Id;
        configData.SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_HEADER;
        
        insert configData;
        
        Object result = TMST_TimesheetManager.getAllTimesheetProcess( null );
        
        System.assert( result != null );
        System.assert( ( (String) result).contains( '"success":true' ) );
        System.assert( ( (String) result).contains( '"timesheetProcessId":"Timesheet_Process_ID"' ), (String) result );
        System.assert( ( (String) result).contains( '"timesheetName":"Timesheet"' ) ); 
        
        String request = '{"timesheetProcessId":"Timesheet_Process_ID"}';
        
        result = TMST_TimesheetManager.deleteTimesheetProcess( request );
        
        System.assert( result != null );
        System.assert( ( (String) result).contains( '"success":true' ) );
        
        result = TMST_TimesheetManager.getAllTimesheetProcess( null );
        
        System.assert( result != null );
        System.assert( ( (String) result).contains( '"success":true' ) );
        System.assert( ( (String) result).contains( '"timesheetInfoList":[]' ) );
    }
    
    static testMethod void testSaveTimesheetConfiguration_Null_Result() {

        Object result = TMST_TimesheetManager.saveTimesheetConfiguration( null );
        
        System.assert( result != null );
        System.assert( ( (String) result).contains( '"success":false' ) );
        System.assert( ( (String) result).contains( '"message":"Invalid Argument"' ) );        
    }
    
    static testMethod void testSaveTimesheetConfiguration_Invalid_Result() {

        String request = 'Invalid';
        Object result = TMST_TimesheetManager.saveTimesheetConfiguration( request );
        
        System.assert( result != null );
        System.assert( ( (String) result).contains( '"success":false' ) );
        System.assert( ( (String) result).contains( '"message":"Invalid JSON request :' ), (String) result );        
    }
    
    static testMethod void testSaveTimesheetConfiguration() {

        Object result = TMST_TimesheetManager.getAllTimesheetProcess( null );

        System.assert( result != null );
        System.assert( ( (String) result).contains( '"success":true' ) );
        System.assert( ( (String) result).contains( '"timesheetInfoList":[]' ) );

        String request = '{"timesheetProcessId":"Timesheet_Process_ID","timesheetName":"Timesheet","Description":"Timesheet"}';
        
        result = TMST_TimesheetManager.saveTimesheetConfiguration( request );
        
        System.assert( result != null );
        System.assert( ( (String) result).contains( '"success":true' ), (String) result );
        
        result = TMST_TimesheetManager.getAllTimesheetProcess( null );
        
        System.assert( ( (String) result).contains( '"success":true' ) );
        System.assert( ( (String) result).contains( '"timesheetProcessId":"Timesheet_Process_ID"' ) );
        System.assert( ( (String) result).contains( '"timesheetName":"Timesheet"' ) ); 
    }
    
    static testMethod void testSaveTimesheetConfiguration_With_Autofill() {

        Object result = TMST_TimesheetManager.getAllTimesheetProcess( null );

        System.assert( result != null );
        System.assert( ( (String) result).contains( '"success":true' ) );
        System.assert( ( (String) result).contains( '"timesheetInfoList":[]' ) );

        String request = '{"status":false,"timesheetName":"Timesheet Sample 1","description":"Timesheet Sample 1","period":"Bi-Monthly","startOfPeriodDate":null,"endOfPeriodDate":null,"dayToRun":1,"weekOn":null,"runEvery":null,"secondRecurrenceDay":14,"timeAt":10,"startingon":"2015-05-18T18:30:00.000Z","continuingthrough":"2015-06-22T18:30:00.000Z","notifyOnTimesheetCreation":true,"minimumIncrement":30,"thresholdHoursPerPeriod":null,"minimumHoursPerPeriod":null,"thresholdHoursPerDay":null,"minimumHoursPerDay":null,"maximumHoursPerPeriod":null,"maximumHoursPerDay":null,"timesheetProcessId":null,"scheduleId":null,"secondRecurrenceScheduleId":null,"autofillInfo":{"status":false,"businessHoursName":null,"workDetailOwnership":null,"workDetailsCriteria":null,"workDetailTimeEntryMapping":null,"taskCriteria":null,"taskTimeEntryMapping":null,"eventType":null,"eventCriteria":null,"eventTimeEntryMapping":null,"period":"Bi-Monthly","startOfPeriodDate":1,"endOfPeriodDate":1,"dayToRun":null,"weekOn":null,"runEvery":1,"secondRecurrenceDay":null,"timeAt":10,"startingon":null,"continuingthrough":null,"timesheetProcessId":null,"scheduleId":null,"secondRecurrenceScheduleId":null},"assignedProfilesList":[]}';
        
        result = TMST_TimesheetManager.saveTimesheetConfiguration( request );
        
        System.assert( result != null );
        System.assert( ( (String) result).contains( '"success":true' ), (String) result );
        
        result = TMST_TimesheetManager.getAllTimesheetProcess( null );
        
        System.assert( ( (String) result).contains( '"success":true' ) );        
        System.assert( ( (String) result).contains( '"timesheetName":"Timesheet Sample 1"' ) ); 
    }
}