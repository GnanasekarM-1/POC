@isTest
private class TMST_TimesheetEngine_UT {

    private static testMethod void testtimesheetConfiguration() { 
        //Create the Object Mapping & Expression Rule for Timesheet Configuration
        SVMXC__ServiceMax_Processes__c tsProcess = new SVMXC__ServiceMax_Processes__c(); 
        tsProcess.SVMXC__Active__c = true;
        tsProcess.SVMXC__Start_Date__c = System.today().addDays(-2);
        tsProcess.SVMXC__End_Date__c   = tsProcess.SVMXC__Start_Date__c.addMonths(12);
        tsProcess.SVMXC__Notify_Technician__c = true;
        tsProcess.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Timesheet' AND SobjectType ='SVMXC__ServiceMax_Processes__c' limit 1].Id; 
        insert tsProcess; 
        
        SVMXC__ServiceMax_Config_Data__c tsConfigurationProfile = new  SVMXC__ServiceMax_Config_Data__c();
        tsConfigurationProfile.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                                    WHERE Name = 'Configuration Profile' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' 
                                                    limit 1].Id;
        tsConfigurationProfile.SVMXC__Configuration_Type__c = 'Group';
        tsConfigurationProfile.SVMXC__Profile_Name__c = 'Test Timesheet Profile';
        insert tsConfigurationProfile;
        
        
        SVMXC__ServiceMax_Config_Data__c tsConfigurationAccess = new  SVMXC__ServiceMax_Config_Data__c();
        tsConfigurationAccess.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                                    WHERE Name = 'Configuration Access' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' 
                                                    limit 1].Id;
        tsConfigurationAccess.SVMXC__Access_Configuration_Profile__c = tsConfigurationProfile.id;
        tsConfigurationAccess.SVMXC__Profile__c = String.valueOf([Select Id From Profile Where Name = 'System Administrator' limit 1].id);
        insert tsConfigurationAccess;
                                                    
        
        SVMXC__ServiceMax_Config_Data__c tsAccess = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                                                                                                WHERE Name = 'Timesheet Access' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' 
                                                                                                                limit 1].Id,
                                                                                                SVMXC__Dispatch_Process__c = tsProcess.ID,
                                                                                                SVMXC__Access_Configuration_Profile__c = tsConfigurationProfile.Id);
        insert tsAccess;
        
        Date TodayDate  = Date.today();
        
        SVMXC__ServiceMax_Config_Data__c tsSchedule = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                                                                                                WHERE Name = 'Schedule' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' 
                                                                                                                limit 1].Id,
                                                                                                SVMXC__Dispatch_Process__c = tsProcess.ID,
                                                                                                SVMXC__Schedule_Type__c = 'TimesheetHeader',
                                                                                                SVMXC__Period_Start_On__c =  1,
                                                                                                SVMXC__Period_End_On__c =  6,
                                                                                                SVMXC__Period__c = 'Weekly');
                                                                                                
        insert tsSchedule; 
        
        Test.startTest();
        TMST_TimesheetEngine   c = new TMST_TimesheetEngine  ();
        c.setProcessIds = new set<string>();
        c.timeSheetRecordType = tsSchedule.SVMXC__Schedule_Type__c;
        // Multiple SVMX process Configurations.
        c.setProcessIds.add(tsSchedule.SVMXC__Dispatch_Process__c);
        c.mapTSProcessScheduler.put(tsSchedule.SVMXC__Dispatch_Process__c, tsSchedule);
        Database.executeBatch(c);
        Test.stopTest();
        
        List <User> listUser = [Select id From User where ProfileId IN (Select Id From Profile Where Name = 'System Administrator') AND isActive = true];
        Integer i = [Select COUNT() From User where ProfileId IN (Select Id From Profile Where Name = 'System Administrator') AND isActive = true];
        Integer j = [Select COUNT() From SVMXC__Timesheet__c WHERE SVMXC__User__c In :listUser]; 
        //Check the Number of TimesheetHeaders created. 
        System.assertEquals(j, i*2);
    }
    
    private static testMethod void testUpdatetimesheetHeaderConfiguration() {
        //Create the Object Mapping & Expression Rule for Timesheet Configuration
        SVMXC__ServiceMax_Processes__c tsProcess = new SVMXC__ServiceMax_Processes__c();
        tsProcess.SVMXC__Active__c = true;
        tsProcess.SVMXC__Start_Date__c = System.today().addDays(-2);
        tsProcess.SVMXC__End_Date__c   = tsProcess.SVMXC__Start_Date__c.addMonths(12);
        tsProcess.SVMXC__Notify_Technician__c = true;
        tsProcess.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Timesheet' AND SobjectType ='SVMXC__ServiceMax_Processes__c' limit 1].Id;
        insert tsProcess; 
        
        SVMXC__ServiceMax_Config_Data__c tsConfigurationProfile = new  SVMXC__ServiceMax_Config_Data__c();
        tsConfigurationProfile.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                                    WHERE Name = 'Configuration Profile' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' 
                                                    limit 1].Id;
        tsConfigurationProfile.SVMXC__Configuration_Type__c = 'Group';
        tsConfigurationProfile.SVMXC__Profile_Name__c = 'Test Timesheet Profile';
        insert tsConfigurationProfile;
        
        
        SVMXC__ServiceMax_Config_Data__c tsConfigurationAccess = new  SVMXC__ServiceMax_Config_Data__c();
        tsConfigurationAccess.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                                    WHERE Name = 'Configuration Access' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' 
                                                    limit 1].Id;
        tsConfigurationAccess.SVMXC__Access_Configuration_Profile__c = tsConfigurationProfile.id;
        tsConfigurationAccess.SVMXC__Profile__c = String.valueOf([Select Id From Profile Where Name = 'System Administrator' limit 1].id);
        insert tsConfigurationAccess;
                                                    
        
        SVMXC__ServiceMax_Config_Data__c tsAccess = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                                                                                                WHERE Name = 'Timesheet Access' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' 
                                                                                                                limit 1].Id,
                                                                                                SVMXC__Dispatch_Process__c = tsProcess.ID,
                                                                                                SVMXC__Access_Configuration_Profile__c = tsConfigurationProfile.Id);
        insert tsAccess;
        
        SVMXC__ServiceMax_Config_Data__c tsSchedule = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                                                                                                WHERE Name = 'Schedule' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' 
                                                                                                                limit 1].Id,
                                                                                                SVMXC__Dispatch_Process__c = tsProcess.ID,
                                                                                                SVMXC__Schedule_Type__c = 'TimesheetHeader',
                                                                                                SVMXC__Period_Start_On__c =  1,
                                                                                                SVMXC__Period_End_On__c =  6,
                                                                                                SVMXC__Period__c = 'Weekly');
                                                                                                
        insert tsSchedule; 
        Date TodayDate  = Date.today();
        SVMXC__Timesheet__c tsHeader = new SVMXC__Timesheet__c( SVMXC__Status__c = 'Open' ,
                                                                    SVMXC__Start_Date__c = TodayDate.addDays(1),
                                                                    SVMXC__End_Date__c = TodayDate.addDays(6),
                                                                    SVMXC__Period__c = 'Weekly',
                                                                    SVMXC__User__c = [Select id From User where ProfileId IN (Select Id From Profile Where Name = 'System Administrator') AND isActive = true LIMIT 1].id );
        
        insert tsHeader ;
        
        Test.startTest();
        TMST_TimesheetEngine  c = new TMST_TimesheetEngine ();
        c.setProcessIds = new set<string>();
        c.timeSheetRecordType = tsSchedule.SVMXC__Schedule_Type__c;
        c.setProcessIds.add(tsSchedule.SVMXC__Dispatch_Process__c);
        c.mapTSProcessScheduler.put(tsSchedule.SVMXC__Dispatch_Process__c, tsSchedule);
        Database.executeBatch(c);
        Test.stopTest();
        
        List <User> listUser = [Select id From User where ProfileId IN (Select Id From Profile Where Name = 'System Administrator') AND isActive = true];
        Integer i = [Select COUNT() From User where ProfileId IN (Select Id From Profile Where Name = 'System Administrator') AND isActive = true];
        Integer j = [Select COUNT() From SVMXC__Timesheet__c WHERE SVMXC__User__c In :listUser]; 
        //Check the Number of TimesheetHeaders created. 
        System.assertEquals(j-1, (i*2)-1);
    }
    
    private static testMethod void testChangetimesheetHeaderPeriodConfiguration() {
        //Create the Object Mapping & Expression Rule for Timesheet Configuration
        SVMXC__ServiceMax_Processes__c tsProcess = new SVMXC__ServiceMax_Processes__c();
        tsProcess.SVMXC__Active__c = true;
        tsProcess.SVMXC__Start_Date__c = System.today().addDays(-2);
        tsProcess.SVMXC__End_Date__c   = tsProcess.SVMXC__Start_Date__c.addMonths(12);
        tsProcess.SVMXC__Notify_Technician__c = true;
        tsProcess.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Timesheet' AND SobjectType ='SVMXC__ServiceMax_Processes__c' limit 1].Id;
        insert tsProcess; 
        
        SVMXC__ServiceMax_Config_Data__c tsConfigurationProfile = new  SVMXC__ServiceMax_Config_Data__c();
        tsConfigurationProfile.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                                    WHERE Name = 'Configuration Profile' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' 
                                                    limit 1].Id;
        tsConfigurationProfile.SVMXC__Configuration_Type__c = 'Group';
        tsConfigurationProfile.SVMXC__Profile_Name__c = 'Test Timesheet Profile';
        insert tsConfigurationProfile;
        
        
        SVMXC__ServiceMax_Config_Data__c tsConfigurationAccess = new  SVMXC__ServiceMax_Config_Data__c();
        tsConfigurationAccess.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                                    WHERE Name = 'Configuration Access' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' 
                                                    limit 1].Id;
        tsConfigurationAccess.SVMXC__Access_Configuration_Profile__c = tsConfigurationProfile.id;
        tsConfigurationAccess.SVMXC__Profile__c = String.valueOf([Select Id From Profile Where Name = 'System Administrator' limit 1].id);
        insert tsConfigurationAccess;
                                                    
        
        SVMXC__ServiceMax_Config_Data__c tsAccess = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                                                                                                WHERE Name = 'Timesheet Access' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' 
                                                                                                                limit 1].Id,
                                                                                                SVMXC__Dispatch_Process__c = tsProcess.ID,
                                                                                                SVMXC__Access_Configuration_Profile__c = tsConfigurationProfile.Id);
        insert tsAccess;
        
        SVMXC__ServiceMax_Config_Data__c tsSchedule = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                                                                                                WHERE Name = 'Schedule' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' 
                                                                                                                limit 1].Id,
                                                                                                SVMXC__Dispatch_Process__c = tsProcess.ID,
                                                                                                SVMXC__Schedule_Type__c = 'TimesheetHeader',
                                                                                                SVMXC__Period_Start_On__c =  1,
                                                                                                SVMXC__Period_End_On__c =  6,
                                                                                                SVMXC__Period__c = 'Weekly');
                                                                                                
        insert tsSchedule; 
        Date TodayDate  = Date.today();
        SVMXC__Timesheet__c tsHeader = new SVMXC__Timesheet__c( SVMXC__Status__c = 'Open' ,
                                                                    SVMXC__Start_Date__c = TodayDate.addDays(1),
                                                                    SVMXC__End_Date__c = TodayDate.addDays(6),
                                                                    SVMXC__Period__c = 'Monthly',
                                                                    SVMXC__User__c = [Select id From User where ProfileId IN (Select Id From Profile Where Name = 'System Administrator') AND isActive = true LIMIT 1].id );
        
        insert tsHeader ;
        
        Test.startTest();
        TMST_TimesheetEngine  c = new TMST_TimesheetEngine ();
        c.setProcessIds = new set<string>();
        c.timeSheetRecordType = tsSchedule.SVMXC__Schedule_Type__c;
        c.setProcessIds.add(tsSchedule.SVMXC__Dispatch_Process__c);
        c.mapTSProcessScheduler.put(tsSchedule.SVMXC__Dispatch_Process__c, tsSchedule);
        Database.executeBatch(c);
        Test.stopTest();
        
        List <User> listUser = [Select id From User where ProfileId IN (Select Id From Profile Where Name = 'System Administrator') AND isActive = true];
        Integer i = [Select COUNT() From User where ProfileId IN (Select Id From Profile Where Name = 'System Administrator') AND isActive = true];
        Integer j = [Select COUNT() From SVMXC__Timesheet__c WHERE SVMXC__Status__c = 'Open' AND SVMXC__User__c In :listUser]; 
        //Check the Number of TimesheetHeaders created. 
        System.assertEquals(j, (i*2));
        
        Integer k = [Select COUNT() From SVMXC__Timesheet__c WHERE SVMXC__Status__c = 'Invalid' AND SVMXC__User__c In :listUser];
        System.assertEquals(k, 1);
    } 
    
    private static testMethod void testtimesheetAutofill() {
        /* ---Start OF WO Line Expression----  */ 
        SVMXC__ServiceMax_Processes__c tsWORule = new SVMXC__ServiceMax_Processes__c();
        tsWORule.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order_Line__c';
        tsWORule.SVMXC__Name__c ='WOD-Expression';
        tsWORule.SVMXC__MapID__c = 'WOD-Expression';
        tsWORule.SVMXC__Advance_Expression__c = '1 OR 2';
        tsWORule.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'SVMX Rule' AND SobjectType ='SVMXC__ServiceMax_Processes__c' limit 1].Id;
        insert tsWORule; 
        
        SVMXC__ServiceMax_Config_Data__c tsWOLineExpression1 = new  SVMXC__ServiceMax_Config_Data__c();
        tsWOLineExpression1.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Expressions' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' limit 1].Id;
        tsWOLineExpression1.SVMXC__Expression_Type__c = 'EXP_Named';
        tsWOLineExpression1.SVMXC__Field_Name__c = 'SVMXC__Line_Type__c';
        tsWOLineExpression1.SVMXC__Expression_Rule__c = tsWORule.id;
        tsWOLineExpression1.SVMXC__Operand__c = 'Labor';
        tsWOLineExpression1.SVMXC__Operator__c = 'eq';
        insert tsWOLineExpression1;
        
        SVMXC__ServiceMax_Config_Data__c tsWOLineExpression2 = new  SVMXC__ServiceMax_Config_Data__c();
        tsWOLineExpression2.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Expressions' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' limit 1].Id;
        tsWOLineExpression2.SVMXC__Expression_Type__c = 'EXP_Named';
        tsWOLineExpression2.SVMXC__Field_Name__c = 'SVMXC__Line_Type__c';
        tsWOLineExpression2.SVMXC__Expression_Rule__c = tsWORule.id;
        tsWOLineExpression2.SVMXC__Operand__c = 'Travel';
        tsWOLineExpression2.SVMXC__Operator__c = 'eq';
        insert tsWOLineExpression2;
        /* ---End of WO Line Expression----  */ 
        
        /* ---Start OF Event Expression----  */ 
        SVMXC__ServiceMax_Processes__c tsEventRule = new SVMXC__ServiceMax_Processes__c();
        tsEventRule.SVMXC__Source_Object_Name__c = 'Event';
        tsEventRule.SVMXC__MapID__c = 'Task-Expression';
        tsEventRule.SVMXC__Advance_Expression__c = '1 OR 2';
        tsEventRule.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'SVMX Rule' AND SobjectType ='SVMXC__ServiceMax_Processes__c' limit 1].Id;
        insert tsEventRule; 
        
        SVMXC__ServiceMax_Config_Data__c tsEventExpression1 = new  SVMXC__ServiceMax_Config_Data__c();
        tsEventExpression1.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Expressions' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' limit 1].Id;
        tsEventExpression1.SVMXC__Expression_Type__c = 'EXP_Named';
        tsEventExpression1.SVMXC__Field_Name__c = 'Status';
        tsEventExpression1.SVMXC__Expression_Rule__c = tsEventRule.id;
        tsEventExpression1.SVMXC__Operand__c = 'Completed';
        tsEventExpression1.SVMXC__Operator__c = 'eq';
        insert tsEventExpression1;
        
        SVMXC__ServiceMax_Config_Data__c tsEventExpression2 = new  SVMXC__ServiceMax_Config_Data__c();
        tsEventExpression2.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Expressions' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' limit 1].Id;
        tsEventExpression2.SVMXC__Expression_Type__c = 'EXP_Named';
        tsEventExpression2.SVMXC__Field_Name__c = 'Status';
        tsEventExpression2.SVMXC__Expression_Rule__c = tsEventRule.id;
        tsEventExpression2.SVMXC__Operand__c = 'In Progress';
        tsEventExpression2.SVMXC__Operator__c = 'eq';
        insert tsEventExpression2;
        /* ---End of Event Expression----  */ 
        
        /* ---Start OF WO Line Mapping----  */
        SVMXC__ServiceMax_Processes__c tsWOObjectMapping = new SVMXC__ServiceMax_Processes__c();
        tsWOObjectMapping.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order_Line__c';
        tsWOObjectMapping.SVMXC__Target_Object_Name__c = 'SVMXC__Timesheet_Entry__c';
        tsWOObjectMapping.SVMXC__MapID__c = 'WOD-TSMapping';
        tsWOObjectMapping.SVMXC__Active__c = true;
        tsWOObjectMapping.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Object Mapping' AND SobjectType ='SVMXC__ServiceMax_Processes__c' limit 1].Id;
        insert tsWOObjectMapping; 
        
        SVMXC__ServiceMax_Config_Data__c tsWOLineFieldMapping1 = new  SVMXC__ServiceMax_Config_Data__c();
        tsWOLineFieldMapping1.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Field Mapping' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' limit 1].Id;
        tsWOLineFieldMapping1.SVMXC__MapID__c = tsWOObjectMapping.id;
        tsWOLineFieldMapping1.SVMXC__Source_Field_Name__c = 'SVMXC__Start_Date_and_Time__c';
        tsWOLineFieldMapping1.SVMXC__Target_Field_Name__c = 'SVMXC__Start_Time__c'; 
        tsWOLineFieldMapping1.SVMXC__Active__c = true;
        insert tsWOLineFieldMapping1;
        
        SVMXC__ServiceMax_Config_Data__c tsWOLineFieldMapping2 = new  SVMXC__ServiceMax_Config_Data__c();
        tsWOLineFieldMapping2.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Field Mapping' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' limit 1].Id;
        tsWOLineFieldMapping2.SVMXC__MapID__c = tsWOObjectMapping.id;
        tsWOLineFieldMapping2.SVMXC__Source_Field_Name__c = 'SVMXC__End_Date_and_Time__c';
        tsWOLineFieldMapping2.SVMXC__Target_Field_Name__c = 'SVMXC__End_Time__c';
        tsWOLineFieldMapping2.SVMXC__Active__c = true;
        insert tsWOLineFieldMapping2;
        /* ---End OF WO Line Mapping----  */
        
        /* ---Start OF Event Mapping----  */
        SVMXC__ServiceMax_Processes__c tsEventObjectMapping = new SVMXC__ServiceMax_Processes__c();
        tsEventObjectMapping.SVMXC__Source_Object_Name__c = 'Event';
        tsEventObjectMapping.SVMXC__Target_Object_Name__c = 'SVMXC__Timesheet_Entry__c';
        tsEventObjectMapping.SVMXC__MapID__c = 'Event-TSMapping';
        tsEventObjectMapping.SVMXC__Active__c = true;
        tsEventObjectMapping.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Object Mapping' AND SobjectType ='SVMXC__ServiceMax_Processes__c' limit 1].Id;
        insert tsEventObjectMapping; 
        
        SVMXC__ServiceMax_Config_Data__c tsEventFieldMapping1 = new  SVMXC__ServiceMax_Config_Data__c();
        tsEventFieldMapping1.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Field Mapping' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' limit 1].Id;
        tsEventFieldMapping1.SVMXC__MapID__c = tsEventObjectMapping.id;
        tsEventFieldMapping1.SVMXC__Source_Field_Name__c = 'StartDateTime';
        tsEventFieldMapping1.SVMXC__Target_Field_Name__c = 'SVMXC__Start_Time__c';
        tsEventFieldMapping1.SVMXC__Active__c = true;
        insert tsEventFieldMapping1;
        
        SVMXC__ServiceMax_Config_Data__c tsEventFieldMapping2 = new  SVMXC__ServiceMax_Config_Data__c();
        tsEventFieldMapping2.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Field Mapping' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' limit 1].Id;
        tsEventFieldMapping2.SVMXC__MapID__c = tsEventObjectMapping.id;
        tsEventFieldMapping2.SVMXC__Source_Field_Name__c = 'EndDateTime';
        tsEventFieldMapping2.SVMXC__Target_Field_Name__c = 'SVMXC__End_Time__c';
        tsEventFieldMapping2.SVMXC__Active__c = true;
        insert tsEventFieldMapping2;
        /* ---End OF Event Mapping----  */
        BusinessHours defaultBusinessHourId = [SELECT Id,Name FROM BusinessHours WHERE IsDefault = true];
        
        SVMXC__ServiceMax_Processes__c tsProcess = new SVMXC__ServiceMax_Processes__c();
        tsProcess.SVMXC__Active__c = true;
        tsProcess.SVMXC__Start_Date__c = System.today().addDays(-2);
        tsProcess.SVMXC__End_Date__c   = tsProcess.SVMXC__Start_Date__c.addMonths(12); 
        tsProcess.SVMXC__Process2__c   = tsWOObjectMapping.id; 
        tsProcess.SVMXC__Process3__c   = tsEventObjectMapping.id; 
        tsProcess.SVMXC__Process__c   = tsWORule.id; 
        tsProcess.SVMXC__Node_Parent__c = tsEventRule.id;
        tsProcess.SVMXC__Field_Name__c = 'closed_by__c';
        tsProcess.SVMXC__Allow_Override__c = true;
        tsProcess.SVMXC__Event_Type__c = 'Both';
        tsProcess.SVMXC__Business_Hours__c = defaultBusinessHourId.id;
        tsProcess.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Timesheet' AND SobjectType ='SVMXC__ServiceMax_Processes__c' limit 1].Id;
        insert tsProcess; 
        
        SVMXC__ServiceMax_Config_Data__c tsConfigurationProfile = new  SVMXC__ServiceMax_Config_Data__c();
        tsConfigurationProfile.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                                    WHERE Name = 'Configuration Profile' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' 
                                                    limit 1].Id;
        tsConfigurationProfile.SVMXC__Configuration_Type__c = 'Group';
        tsConfigurationProfile.SVMXC__Profile_Name__c = 'Test Timesheet Profile'; 
        insert tsConfigurationProfile;
        
        
        SVMXC__ServiceMax_Config_Data__c tsConfigurationAccess = new  SVMXC__ServiceMax_Config_Data__c();
        tsConfigurationAccess.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                                    WHERE Name = 'Configuration Access' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' 
                                                    limit 1].Id;
        tsConfigurationAccess.SVMXC__Access_Configuration_Profile__c = tsConfigurationProfile.id;
        tsConfigurationAccess.SVMXC__Profile__c = String.valueOf([Select Id From Profile Where Name = 'System Administrator' limit 1].id);
        insert tsConfigurationAccess;
                                                    
        
        SVMXC__ServiceMax_Config_Data__c tsAccess = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                                                                                                WHERE Name = 'Timesheet Access' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' 
                                                                                                                limit 1].Id,
                                                                                                SVMXC__Dispatch_Process__c = tsProcess.ID,
                                                                                                SVMXC__Access_Configuration_Profile__c = tsConfigurationProfile.Id);
        insert tsAccess;
        
        SVMXC__ServiceMax_Config_Data__c tsSchedule = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                                                                                                WHERE Name = 'Schedule' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' 
                                                                                                                limit 1].Id,
                                                                                                SVMXC__Dispatch_Process__c = tsProcess.ID,
                                                                                                SVMXC__Schedule_Type__c = 'TimesheetAutofill',SVMXC__SM_Scope__c='{"salesforceProfileIds":[{"name":"ServiceMax Admin","Id":"00e0G000001MjlWQAS"},{"name":"System Admin SP","Id":"00e2I000001MjqRQAS"},{"name":"System Administrator","Id":"00eF00000018EmUIAU"}]}',
                                                                                                SVMXC__Active__c = true,
                                                                                                SVMXC__Period__c = 'Weekly');
                                                                                                
        insert tsSchedule;   
        
        Date TodayDate  = Date.today();
        
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        insert workOrder ; 
        
        SVMXC__Service_Order_Line__c insertWOLine = new SVMXC__Service_Order_Line__c(SVMXC__Line_Type__c = 'Travel',
                                                                                            closed_by__c = [Select id From User where ProfileId IN (Select Id From Profile Where Name = 'System Administrator') AND isActive = true LIMIT 1].id, 
                                                                                            SVMXC__Start_Date_and_Time__c = TodayDate,
                                                                                            SVMXC__End_Date_and_Time__c  = TodayDate.addDays(1),
                                                                                            SVMXC__Service_Order__c = workOrder.id
                                                                                        );
        insert    insertWOLine;
        
        SVMXC__Service_Order_Line__c insertWOLine1 = new SVMXC__Service_Order_Line__c(SVMXC__Line_Type__c = 'Travel',
                                                                                            closed_by__c = [Select id From User where ProfileId IN (Select Id From Profile Where Name = 'System Administrator') AND isActive = true LIMIT 1].id, 
                                                                                            SVMXC__Start_Date_and_Time__c = TodayDate,
                                                                                            SVMXC__End_Date_and_Time__c  = TodayDate.addDays(1),
                                                                                            SVMXC__Service_Order__c = workOrder.id
                                                                                        );
        insert    insertWOLine1;
        
        Event insertSFEVent = new Event(StartDateTime =  TodayDate,
                                        EndDateTime  = TodayDate.addDays(1),
                                        OwnerId = [Select id From User where ProfileId IN (Select Id From Profile Where Name = 'System Administrator') AND isActive = true LIMIT 1].id
                                        );
                                                                                            
        insert insertSFEVent; 
        
        Event insertSFEVent1 = new Event(StartDateTime =  TodayDate,
                                        EndDateTime  = TodayDate.addDays(1),
                                        OwnerId = [Select id From User where ProfileId IN (Select Id From Profile Where Name = 'System Administrator') AND isActive = true LIMIT 1].id
                                        );
                                                                                            
        insert insertSFEVent1; 
        /*SVMXC__Service_Group__c insertServiceGroup = new SVMXC__Service_Group__c(RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                                                                                                WHERE Name = 'Technician' AND SobjectType ='SVMXC__Service_Group__c' 
                                                                                                                limit 1].Id,
                                                                                     SVMXC__Active__c = true
                                                                                     );
        insert insertServiceGroup;
        
        SVMXC__Service_Group_Members__c insertechnician =  new SVMXC__Service_Group_Members__c(SVMXC__Salesforce_User__c = [Select id From User where ProfileId IN (Select Id From Profile Where Name = 'System Administrator') AND isActive = true LIMIT 1].id,
                                                                                                    SVMXC__Service_Group__c = insertServiceGroup.Id
                                                                                                    );
        insert insertechnician;
        
        SVMXC__SVMX_Event__c insertSVMXEVent = new SVMXC__SVMX_Event__c(SVMXC__StartDateTime__c =  TodayDate,
                                        SVMXC__EndDateTime__c  = TodayDate.addDays(1),
                                        SVMXC__Technician__c = insertEchnician.id
                                        );
                                                                                            
        insert insertSVMXEVent; 
        
        SVMXC__SVMX_Event__c insertSVMXEVent1 = new SVMXC__SVMX_Event__c(SVMXC__StartDateTime__c =  TodayDate,
                                        SVMXC__EndDateTime__c  = TodayDate.addDays(1),
                                        SVMXC__Technician__c = insertEchnician.id
                                        );
                                                                                             
        insert insertSVMXEVent1; */
        List<SVMXC__Timesheet__c> listInsertTmesheetheaderUser = new List<SVMXC__Timesheet__c>();
        for(User user : [Select id From User where ProfileId IN (Select Id From Profile Where Name = 'System Administrator') AND isActive = true]){
            SVMXC__Timesheet__c tsHeader = new SVMXC__Timesheet__c( SVMXC__Status__c = 'Open' ,
                                                                    SVMXC__Start_Date__c = TodayDate.addDays(-1),
                                                                    SVMXC__End_Date__c = TodayDate.addDays(6),
                                                                    SVMXC__User__c = user.id,
                                                                    SVMXC__SM_Business_Hours__c = defaultBusinessHourId.Id);
        
            listInsertTmesheetheaderUser.add(tsHeader) ;
        }
        
        if(listInsertTmesheetheaderUser != null && listInsertTmesheetheaderUser.size() > 0)
            insert listInsertTmesheetheaderUser;
        
        
        List<SVMXC__Timesheet_Day_Entry__c> insertUserTimesheetDayEntry = new List <SVMXC__Timesheet_Day_Entry__c> ();
        
        for(SVMXC__Timesheet__c userTSH: listInsertTmesheetheaderUser){
            Integer numberDaysDue = userTSH.SVMXC__Start_Date__c.daysBetween(userTSH.SVMXC__End_Date__c);
            for(integer i=0; i < = numberDaysDue ; i++){
                SVMXC__Timesheet_Day_Entry__c createTimesheetDayEntry = new SVMXC__Timesheet_Day_Entry__c();
                createTimesheetDayEntry.SVMXC__Timesheet__c = userTSH.id;
                createTimesheetDayEntry.SVMXC__Timsheet_Day__c = userTSH.SVMXC__Start_Date__c.addDays(i);
                insertUserTimesheetDayEntry.add(createTimesheetDayEntry);    
            }
        }
        
        
        if( insertUserTimesheetDayEntry != null && insertUserTimesheetDayEntry.size() > 0)
            insert insertUserTimesheetDayEntry;
            
        SVMXC__Timesheet_Entry__c timesheetEntry = new SVMXC__Timesheet_Entry__c();
        timesheetEntry.SVMXC__Timesheet__c = listInsertTmesheetheaderUser.get(0).id; 
        timesheetEntry.SVMXC__Timesheet_Day__c = insertUserTimesheetDayEntry[0].id;
        timesheetEntry.SVMXC__Work_Detail__c = insertWOLine.id;
        timesheetEntry.SVMXC__Salesforce_Event__c = insertSFEVent.id;
        timesheetEntry.SVMXC__Start_Time__c = System.today();
        // timesheetEntry.SVMXC__ServiceMax_Event__c = insertSVMXEVent.id;
        insert timesheetEntry;
        
        Test.startTest();
        TMST_TimesheetEngine  c = new TMST_TimesheetEngine ();
        c.setProcessIds = new set<string>();
        c.timeSheetRecordType = tsSchedule.SVMXC__Schedule_Type__c;
        c.setProcessIds.add(tsSchedule.SVMXC__Dispatch_Process__c);
        c.mapTSProcessScheduler.put(tsSchedule.SVMXC__Dispatch_Process__c, tsSchedule);
        Database.executeBatch(c);
        Test.stopTest();
    }
}