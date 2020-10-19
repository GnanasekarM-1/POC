 @isTest(SeeAllData=false)
global class SPM_TechUtilization_UT{
    
    private static RecordType spmRuleRecordType;
    private static RecordType spmDetailsRecordType;
    
    static testMethod void testWithRecrods(){
        Test.startTest();
        setup();
        Id processId = insertProcess();
        insertConfigData(processId);
        insertTimeSheetData();
        
        SPM_TechUtilization objTechUtilization = new SPM_TechUtilization(null);
        System.assert(objTechUtilization != null);
        
        Database.QueryLocator queryLocator = objTechUtilization.start( null );
        List<SObject> records = Database.query( queryLocator.getQuery() );
        
        objTechUtilization.execute(null, records);
        objTechUtilization.execute(null, records);
        
        objTechUtilization.finish(null);
        BusinessHours bizHour = [SELECT id From BusinessHours Where IsDefault=true];
        Long minutes;
        minutes = objTechUtilization.calculateBreakTime('day1', bizHour);
        System.assertEquals(1440,minutes);
        minutes = objTechUtilization.calculateBreakTime('day2', bizHour);
        System.assertEquals(60,minutes);
        minutes = objTechUtilization.calculateBreakTime('day3', bizHour);
        System.assertEquals(60,minutes);
        minutes = objTechUtilization.calculateBreakTime('day4', bizHour);
        System.assertEquals(60,minutes);

        
        List<SVMXC__SPM_Utilization__c> lstSPMUtilization = [Select Id,SVMXC__Available_Time__c,SVMXC__Break_Minutes__c,SVMXC__Country__c,SVMXC__Drive_Time__c,SVMXC__Non_Productive_Time__c,SVMXC__Off_Time__c,SVMXC__Productive_Time__c,SVMXC__Service_Manager__c,SVMXC__Service_Team__c,SVMXC__Technician__c,SVMXC__Timesheet_Daily_Summary__c,SVMXC__User__c,SVMXC__Utilization__c,SVMXC__Utilization_Without_Drive_Time__c,SVMXC__Utilization_On__c,SVMXC__Working_Minutes__c FROM SVMXC__SPM_Utilization__c];
        /* System.assert(lstSPMUtilization.size() == 2);
        System.debug( LoggingLevel.DEBUG, 'UtilizationRecord1 : ' + lstSPMUtilization[0]);
        System.debug( LoggingLevel.DEBUG, 'UtilizationRecord2 : ' + lstSPMUtilization[1]); */
        Test.stopTest();
    }
    
    static testMethod void testConstructor_With_Schedule(){
        Test.startTest();
        setup();
        Id processId = insertProcess();
        insertConfigData( processId );
        insertTimeSheetData();

        SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
        scheduleData.SVMXC__Previous_Execution_Started_On__c = System.now().addMonths(-1);
        
        SPM_TechUtilization objTechUtilization = new SPM_TechUtilization(scheduleData);
        System.assert(objTechUtilization != null );
        
        Database.QueryLocator queryLocator = objTechUtilization.start( null );
        List<SObject> records = Database.query( queryLocator.getQuery() );
        
        objTechUtilization.execute(null, records);
        objTechUtilization.execute(null, records);
        
        objTechUtilization.finish( null );
        BusinessHours bizHour = [SELECT id From BusinessHours Where IsDefault=true];
        Long minutes;
        minutes = objTechUtilization.calculateBreakTime('day1', bizHour);
        System.assertEquals(1440,minutes);
        minutes = objTechUtilization.calculateBreakTime('day2', bizHour);
        System.assertEquals(60,minutes);
        minutes = objTechUtilization.calculateBreakTime('day3', bizHour);
        System.assertEquals(60,minutes);
        minutes = objTechUtilization.calculateBreakTime('day4', bizHour);
        System.assertEquals(60,minutes);
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
    
    private static void insertTimeSheetData(){
        String strBusinessHoursId = [SELECT id From BusinessHours Where IsDefault=true].Id;
        
        SVMXC__Service_Group__c objTeam = new SVMXC__Service_Group__c();
        objTeam.Name = 'India team';
        objTeam.SVMXC__Active__c = true;
        objTeam.SVMXC__City__c = 'Bangalore';
        objTeam.SVMXC__Country__c = 'India';
        objTeam.SVMXC__Group_Type__c = 'Both';
        objTeam.SVMXC__Zip__c = '560001';
        insert objTeam;
        
        SVMXC__Service_Group_Members__c objTech = new SVMXC__Service_Group_Members__c();
        objTech.SVMXC__Service_Group__c = objTeam.id;
        objTech.SVMXC__Salesforce_User__c = UserInfo.getUserId();
        objTech.SVMXC__Active__c = true;
        objTech.Name = 'TestTech';
        objTech.SVMXC__Break_Hours__c = strBusinessHoursId;
        insert objTech;
        
        SVMXC__Timesheet__c objTSHeader = new SVMXC__Timesheet__c();
        objTSHeader.SVMXC__User__c = UserInfo.getUserId();
        objTSHeader.SVMXC__Start_Date__c = System.Today().addDays(-5);
        objTSHeader.SVMXC__End_Date__c = System.Today().addDays(5);
        objTSHeader.SVMXC__Period__c = 'Weekly';
        objTSHeader.SVMXC__Status__c = 'Approved';
        objTSHeader.SVMXC__Total_Hours__c = 8;
        insert objTSHeader;
        
        List<SVMXC__Timesheet_Day_Entry__c> lstTMDayEntry = new List<SVMXC__Timesheet_Day_Entry__c>();
        SVMXC__Timesheet_Day_Entry__c objTSDayEntry1 = new SVMXC__Timesheet_Day_Entry__c();
        objTSDayEntry1.SVMXC__Timesheet__c = objTSHeader.id;
        objTSDayEntry1.SVMXC__Timsheet_Day__c = System.Today().addDays(1);
        objTSDayEntry1.SVMXC__Total_Hours__c = 8;
        objTSDayEntry1.SVMXC__SM_Working_Minutes__c = 480;
        lstTMDayEntry.add(objTSDayEntry1);
        
        SVMXC__Timesheet_Day_Entry__c objTSDayEntry2 = new SVMXC__Timesheet_Day_Entry__c();
        objTSDayEntry2.SVMXC__Timesheet__c = objTSHeader.id;
        objTSDayEntry2.SVMXC__Timsheet_Day__c = System.Today().addDays(2);
        objTSDayEntry2.SVMXC__Total_Hours__c = 8;
        objTSDayEntry2.SVMXC__SM_Working_Minutes__c = 480;
        lstTMDayEntry.add(objTSDayEntry2);
        insert lstTMDayEntry;
        
        List<SVMXC__Timesheet_Entry__c> lstTimesheetEntry = new List<SVMXC__Timesheet_Entry__c>();
        SVMXC__Timesheet_Entry__c objTSEntry1 = new SVMXC__Timesheet_Entry__c();
        objTSEntry1.SVMXC__Timesheet__c = objTSHeader.id;
        objTSEntry1.SVMXC__Timesheet_Day__c = lstTMDayEntry[0].id;
        objTSEntry1.SVMXC__Activity__c  = 'Task';
        objTSEntry1.SVMXC__Duration__c = 4;
        objTSEntry1.SVMXC__SM_Type__c = 'Labor';
        lstTimesheetEntry.add(objTSEntry1);
        
        SVMXC__Timesheet_Entry__c objTSEntry2 = new SVMXC__Timesheet_Entry__c();
        objTSEntry2.SVMXC__Timesheet__c = objTSHeader.id;
        objTSEntry2.SVMXC__Timesheet_Day__c = lstTMDayEntry[0].id;
        objTSEntry2.SVMXC__Activity__c  = 'Travel'; 
        objTSEntry2.SVMXC__Duration__c = 1;
        objTSEntry2.SVMXC__SM_Type__c = 'Labor';
        lstTimesheetEntry.add(objTSEntry2);
        
        SVMXC__Timesheet_Entry__c objTSEntry3 = new SVMXC__Timesheet_Entry__c();
        objTSEntry3.SVMXC__Timesheet__c = objTSHeader.id;
        objTSEntry3.SVMXC__Timesheet_Day__c = lstTMDayEntry[0].id;
        objTSEntry3.SVMXC__Activity__c  = 'Labor';  
        objTSEntry3.SVMXC__Duration__c = 1;
        objTSEntry3.SVMXC__SM_Type__c = 'PTO';
        lstTimesheetEntry.add(objTSEntry3);
        
        SVMXC__Timesheet_Entry__c objTSEntry4 = new SVMXC__Timesheet_Entry__c();
        objTSEntry4.SVMXC__Timesheet__c = objTSHeader.id;
        objTSEntry4.SVMXC__Timesheet_Day__c = lstTMDayEntry[0].id;
        objTSEntry4.SVMXC__Activity__c  = 'Labor';  
        objTSEntry4.SVMXC__Duration__c = 1;
        objTSEntry4.SVMXC__SM_Type__c = 'Meeting';
        lstTimesheetEntry.add(objTSEntry4);
        
        //Time entry for another day
        SVMXC__Timesheet_Entry__c objTSEntry21 = new SVMXC__Timesheet_Entry__c();
        objTSEntry21.SVMXC__Timesheet__c = objTSHeader.id;
        objTSEntry21.SVMXC__Timesheet_Day__c = lstTMDayEntry[1].id;
        objTSEntry21.SVMXC__Activity__c = 'Task';
        objTSEntry21.SVMXC__Duration__c = 8;
        objTSEntry21.SVMXC__SM_Type__c = 'Labor';
        lstTimesheetEntry.add(objTSEntry21);
        
        insert lstTimesheetEntry;
    }
    
    private static Id insertProcess() {
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = spmRuleRecordType.Id;
        process.SVMXC__ProcessID__c = SPM_Schema.Report.Utilization.name();
        process.SVMXC__Name__c = 'Utilization';
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
        
        calculationMethod = calculationMethod.replace( 'a10F0000005OlkPIAS', configData.Id );
        configData.SVMXC__Formula__c = calculationMethod;
        update configData;
    }
    
    private static String calculationMethod = '{"targetObjectName":"SVMXC__SPM_Utilization__c","targetObjectLabel":"SPM - Utilization","sourceObjectName":"SVMXC__Timesheet__c","sourceObjectLabel":"Timesheet","recordId":"a10F0000005OlkPIAS","parameterInfoList":[{"sourceObjectName":"SVMXC__Timesheet_Entry__c","sourceObjectField":"NonProductiveTime","sourceFieldName":"Training;Meeting;Administration","sourceFieldLabel":"","sourceFieldInfoList":null,"referenceTo":null,"label":"Select the one or more type(s) for Non Productive Time","isPicklistValue":true,"isMultiSelect":true,"displayType":"MULTIPICKLIST"},{"sourceObjectName":"SVMXC__Timesheet_Entry__c","sourceObjectField":"Leaves","sourceFieldName":"PTO;Sick Leave","sourceFieldLabel":"","sourceFieldInfoList":null,"referenceTo":null,"label":"Select one or more activity types for leaves","isPicklistValue":true,"isMultiSelect":true,"displayType":"MULTIPICKLIST"},{"sourceObjectName":null,"sourceObjectField":"isActiveTechnician","sourceFieldName":"Yes","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":null,"label":"Consider active technician","isPicklistValue":false,"isMultiSelect":false,"displayType":"PICKLIST"},{"sourceObjectName":null,"sourceObjectField":"BreakTime","sourceFieldName":"Break Hours","sourceFieldLabel":null,"sourceFieldInfoList":null,"referenceTo":null,"label":"Select the source for the Break Time from Technician","isPicklistValue":false,"isMultiSelect":false,"displayType":"PICKLIST"}],"objectMappingDetailsList":[{"targetObjectName":"SVMXC__SPM_Utilization__c","sourceObjectName":"SVMXC__Timesheet__c","referenceObjectName":false,"objectMappingList":null,"mapId":"NONE","label":"Select the Object Mapping to be applied for this metrics"}],"name":null,"methodDisplayName":null,"method":"SPMUTILIZATION: Standard","lastModifiedOn":null,"isActive":true,"expressionDetailsList":[{"sourceObjectName":null,"label":"Select the expression to qualify Timesheet for this metrics","expressionType":"QualificationCriteria","expressionRuleList":null,"expressionRuleId":"SPM:_To_Identify_Approved_Timesheets"}],"appliesTo":""}';  
}