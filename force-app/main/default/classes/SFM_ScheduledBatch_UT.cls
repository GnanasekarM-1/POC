@isTest
private class SFM_ScheduledBatch_UT {

    private static testMethod void validClassNameTest() {
        SVMXC__Installed_Product__c IB1 = new SVMXC__Installed_Product__c();
        IB1.SVMXC__Status__c = 'Shipped';
        insert IB1; 
        
        SVMXC__Installed_Product__c IB2 = new SVMXC__Installed_Product__c();
        IB2.SVMXC__Status__c = 'Installed';
        insert IB2;
        
        SVMXC__Installed_Product__c IB3 = new SVMXC__Installed_Product__c();
        IB3.SVMXC__Status__c = 'Loaned';
        insert IB3;
        
        SVMXC__Installed_Product__c IB4 = new SVMXC__Installed_Product__c();
        IB4.SVMXC__Status__c = 'Leased';
        insert IB4;
        
        SVMXC__ServiceMax_Processes__c expressionRule = new SVMXC__ServiceMax_Processes__c();
        expressionRule.SVMXC__Source_Object_Name__c = 'SVMXC__Installed_Product__c';
        expressionRule.SVMXC__MapID__c = 'IB-Expression';
        expressionRule.SVMXC__Advance_Expression__c = '1 or 2 or 3 or 4';
        expressionRule.Parent_Object_Criteria__c = 'SVMXC__Status__c = \'Shipped\' or SVMXC__Status__c = \'Installed\' or SVMXC__Status__c = \'Loaned\' or SVMXC__Status__c = \'Leased\'';
        expressionRule.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'SVMX Rule' AND SobjectType ='SVMXC__ServiceMax_Processes__c' limit 1].Id;
        insert expressionRule;
        
        SVMXC__ServiceMax_Config_Data__c IBExpression1 = new  SVMXC__ServiceMax_Config_Data__c();
        IBExpression1.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Expressions' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' limit 1].Id;
        IBExpression1.SVMXC__Expression_Type__c = 'EXP_Named';
        IBExpression1.SVMXC__Field_Name__c = 'SVMXC__Status__c';
        IBExpression1.SVMXC__Expression_Rule__c = expressionRule.id;
        IBExpression1.SVMXC__Operand__c = 'Shipped';
        IBExpression1.SVMXC__Operator__c = 'eq';
        insert IBExpression1;
        
        SVMXC__ServiceMax_Config_Data__c IBExpression2 = new  SVMXC__ServiceMax_Config_Data__c();
        IBExpression2.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Expressions' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' limit 1].Id;
        IBExpression2.SVMXC__Expression_Type__c = 'EXP_Named';
        IBExpression2.SVMXC__Field_Name__c = 'SVMXC__Status__c';
        IBExpression2.SVMXC__Expression_Rule__c = expressionRule.id;
        IBExpression2.SVMXC__Operand__c = 'Installed';
        IBExpression2.SVMXC__Operator__c = 'eq';
        insert IBExpression2;
        
        SVMXC__ServiceMax_Config_Data__c IBExpression3 = new  SVMXC__ServiceMax_Config_Data__c();
        IBExpression3.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Expressions' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' limit 1].Id;
        IBExpression3.SVMXC__Expression_Type__c = 'EXP_Named';
        IBExpression3.SVMXC__Field_Name__c = 'SVMXC__Status__c';
        IBExpression3.SVMXC__Expression_Rule__c = expressionRule.id;
        IBExpression3.SVMXC__Operand__c = 'Loaned';
        IBExpression3.SVMXC__Operator__c = 'eq';
        insert IBExpression3;
        
        SVMXC__ServiceMax_Config_Data__c IBExpression4 = new  SVMXC__ServiceMax_Config_Data__c();
        IBExpression4.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Expressions' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' limit 1].Id;
        IBExpression4.SVMXC__Expression_Type__c = 'EXP_Named';
        IBExpression4.SVMXC__Field_Name__c = 'SVMXC__Status__c';
        IBExpression4.SVMXC__Expression_Rule__c = expressionRule.id;
        IBExpression4.SVMXC__Operand__c = 'Leased';
        IBExpression4.SVMXC__Operator__c = 'eq';
        insert IBExpression4;
        
        
        SVMXC__ServiceMax_Processes__c tsProcess = new SVMXC__ServiceMax_Processes__c();
        tsProcess.SVMXC__Name__c = 'Schedule SFM Header';
        tsProcess.SVMXC__ProcessID__c = 'SCHEDULESFMHEADER';
        tsProcess.SVMXC__MapID__c = 'SCHEDULESFMHEADER';
        tsProcess.SVMXC__Dispatch_Timezone__c = 'Asia/Kolkata';
        tsProcess.SVMXC__Capture_Log__c = true;
        tsProcess.SVMXC__Assign_To_Dispatcher__c = [Select id From User limit 1].id; 
        insert tsProcess;
        
        SVMXC__ServiceMax_Config_Data__c servicesConfigdata = new SVMXC__ServiceMax_Config_Data__c();
        servicesConfigdata.Object_Name__c = 'SVMXC__Installed_Product__c';
        servicesConfigdata.Expression_Rule__c= expressionRule.id; 
        servicesConfigdata.SVMXC__Class_Name__c = 'SFM_CreateCounterReadings';
        servicesConfigdata.SVMXC__Namespace__c = '';
        servicesConfigdata.SVMXC__Dispatch_Process__c = tsProcess.id;
        servicesConfigdata.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Schedule Detail' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' limit 1].Id;
        
        insert servicesConfigdata;
        
        SVMXC__ServiceMax_Config_Data__c configRec = [SELECT Id, Namespace__c,
                                                             Class_Name__c,
                                                             Previous_Execution_Completed_On__c, Previous_Execution_Status__c, 
                                                             Previous_Execution_Started_On__c, Object_Name__c, 
                                                             Expression_Rule__r.Parent_Object_Criteria__c,
                                                             SVMXC__Dispatch_Process__r.SVMXC__Name__c, SVMXC__Dispatch_Process__r.SVMXC__ProcessID__c, 
                                                             SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Timezone__c, SVMXC__Dispatch_Process__r.SVMXC__Assign_To_Dispatcher__c,
                                                             SVMXC__Dispatch_Process__r.SVMXC__Capture_Log__c
                                                             FROM SVMXC__ServiceMax_Config_Data__c WHERE ID = :servicesConfigdata.id];
        
        Test.startTest();
        SFM_ScheduledBatch batchCounterReadingObj = new SFM_ScheduledBatch();
        batchCounterReadingObj.scheduleDetailConfig = configRec;
        Database.executebatch(batchCounterReadingObj);
        Test.stopTest();
    }
    
    private static testMethod void invalidClassNameTest() {
        SVMXC__Installed_Product__c IB1 = new SVMXC__Installed_Product__c();
        IB1.SVMXC__Status__c = 'Shipped';
        insert IB1; 
        
        SVMXC__Installed_Product__c IB2 = new SVMXC__Installed_Product__c();
        IB2.SVMXC__Status__c = 'Installed';
        insert IB2;
        
        SVMXC__Installed_Product__c IB3 = new SVMXC__Installed_Product__c();
        IB3.SVMXC__Status__c = 'Loaned';
        insert IB3;
        
        SVMXC__Installed_Product__c IB4 = new SVMXC__Installed_Product__c();
        IB4.SVMXC__Status__c = 'Leased';
        insert IB4;
        
        SVMXC__ServiceMax_Processes__c expressionRule = new SVMXC__ServiceMax_Processes__c();
        expressionRule.SVMXC__Source_Object_Name__c = 'SVMXC__Installed_Product__c';
        expressionRule.SVMXC__MapID__c = 'IB-Expression';
        expressionRule.SVMXC__Advance_Expression__c = '1 or 2 or 3 or 4';
        expressionRule.Parent_Object_Criteria__c = 'SVMXC__Status__c = \'Shipped\' or SVMXC__Status__c = \'Installed\' or SVMXC__Status__c = \'Loaned\' or SVMXC__Status__c = \'Leased\'';
        expressionRule.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'SVMX Rule' AND SobjectType ='SVMXC__ServiceMax_Processes__c' limit 1].Id;
        insert expressionRule;
        
        SVMXC__ServiceMax_Config_Data__c IBExpression1 = new  SVMXC__ServiceMax_Config_Data__c();
        IBExpression1.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Expressions' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' limit 1].Id;
        IBExpression1.SVMXC__Expression_Type__c = 'EXP_Named';
        IBExpression1.SVMXC__Field_Name__c = 'SVMXC__Status__c';
        IBExpression1.SVMXC__Expression_Rule__c = expressionRule.id;
        IBExpression1.SVMXC__Operand__c = 'Shipped';
        IBExpression1.SVMXC__Operator__c = 'eq';
        insert IBExpression1;
        
        SVMXC__ServiceMax_Config_Data__c IBExpression2 = new  SVMXC__ServiceMax_Config_Data__c();
        IBExpression2.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Expressions' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' limit 1].Id;
        IBExpression2.SVMXC__Expression_Type__c = 'EXP_Named';
        IBExpression2.SVMXC__Field_Name__c = 'SVMXC__Status__c';
        IBExpression2.SVMXC__Expression_Rule__c = expressionRule.id;
        IBExpression2.SVMXC__Operand__c = 'Installed';
        IBExpression2.SVMXC__Operator__c = 'eq';
        insert IBExpression2;
        
        SVMXC__ServiceMax_Config_Data__c IBExpression3 = new  SVMXC__ServiceMax_Config_Data__c();
        IBExpression3.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Expressions' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' limit 1].Id;
        IBExpression3.SVMXC__Expression_Type__c = 'EXP_Named';
        IBExpression3.SVMXC__Field_Name__c = 'SVMXC__Status__c';
        IBExpression3.SVMXC__Expression_Rule__c = expressionRule.id;
        IBExpression3.SVMXC__Operand__c = 'Loaned';
        IBExpression3.SVMXC__Operator__c = 'eq';
        insert IBExpression3;
        
        SVMXC__ServiceMax_Config_Data__c IBExpression4 = new  SVMXC__ServiceMax_Config_Data__c();
        IBExpression4.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Expressions' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' limit 1].Id;
        IBExpression4.SVMXC__Expression_Type__c = 'EXP_Named';
        IBExpression4.SVMXC__Field_Name__c = 'SVMXC__Status__c';
        IBExpression4.SVMXC__Expression_Rule__c = expressionRule.id;
        IBExpression4.SVMXC__Operand__c = 'Leased';
        IBExpression4.SVMXC__Operator__c = 'eq';
        insert IBExpression4;
        
        
        SVMXC__ServiceMax_Processes__c tsProcess = new SVMXC__ServiceMax_Processes__c();
        tsProcess.SVMXC__Name__c = 'Schedule SFM Header';
        tsProcess.SVMXC__ProcessID__c = 'SCHEDULESFMHEADER';
        tsProcess.SVMXC__MapID__c = 'SCHEDULESFMHEADER';
        tsProcess.SVMXC__Dispatch_Timezone__c = 'Asia/Kolkata';
        tsProcess.SVMXC__Capture_Log__c = true;
        tsProcess.SVMXC__Assign_To_Dispatcher__c = [Select id From User limit 1].id; 
        insert tsProcess;
        
        SVMXC__ServiceMax_Config_Data__c servicesConfigdata = new SVMXC__ServiceMax_Config_Data__c();
        servicesConfigdata.Object_Name__c = 'SVMXC__Installed_Product__c';
        servicesConfigdata.Expression_Rule__c= expressionRule.id; 
        servicesConfigdata.SVMXC__Class_Name__c = 'TestClass';
        servicesConfigdata.SVMXC__Namespace__c = '';
        servicesConfigdata.SVMXC__Dispatch_Process__c = tsProcess.id;
        servicesConfigdata.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Schedule Detail' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' limit 1].Id;
        
        insert servicesConfigdata;
        
        SVMXC__ServiceMax_Config_Data__c configRec = [SELECT Id, Namespace__c,
                                                             Class_Name__c,
                                                             Previous_Execution_Completed_On__c, Previous_Execution_Status__c, 
                                                             Previous_Execution_Started_On__c, Object_Name__c, 
                                                             Expression_Rule__r.Parent_Object_Criteria__c,
                                                             SVMXC__Dispatch_Process__r.SVMXC__Name__c, SVMXC__Dispatch_Process__r.SVMXC__ProcessID__c, 
                                                             SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Timezone__c, SVMXC__Dispatch_Process__r.SVMXC__Assign_To_Dispatcher__c,
                                                             SVMXC__Dispatch_Process__r.SVMXC__Capture_Log__c
                                                             FROM SVMXC__ServiceMax_Config_Data__c WHERE ID = :servicesConfigdata.id];
        
        Test.startTest();
        SFM_ScheduledBatch batchCounterReadingObj = new SFM_ScheduledBatch();
        batchCounterReadingObj.scheduleDetailConfig = configRec;
        Database.executebatch(batchCounterReadingObj);
        Test.stopTest();
    }
    
    private static testMethod void ValidClassNoInterfaceTest() {
        SVMXC__Installed_Product__c IB1 = new SVMXC__Installed_Product__c();
        IB1.SVMXC__Status__c = 'Shipped';
        insert IB1; 
        
        SVMXC__Installed_Product__c IB2 = new SVMXC__Installed_Product__c();
        IB2.SVMXC__Status__c = 'Installed';
        insert IB2;
        
        SVMXC__Installed_Product__c IB3 = new SVMXC__Installed_Product__c();
        IB3.SVMXC__Status__c = 'Loaned';
        insert IB3;
        
        SVMXC__Installed_Product__c IB4 = new SVMXC__Installed_Product__c();
        IB4.SVMXC__Status__c = 'Leased';
        insert IB4;
        
        SVMXC__ServiceMax_Processes__c expressionRule = new SVMXC__ServiceMax_Processes__c();
        expressionRule.SVMXC__Source_Object_Name__c = 'SVMXC__Installed_Product__c';
        expressionRule.SVMXC__MapID__c = 'IB-Expression';
        expressionRule.SVMXC__Advance_Expression__c = '1 or 2 or 3 or 4';
        expressionRule.Parent_Object_Criteria__c = 'SVMXC__Status__c = \'Shipped\' or SVMXC__Status__c = \'Installed\' or SVMXC__Status__c = \'Loaned\' or SVMXC__Status__c = \'Leased\'';
        expressionRule.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'SVMX Rule' AND SobjectType ='SVMXC__ServiceMax_Processes__c' limit 1].Id;
        insert expressionRule;
        
        SVMXC__ServiceMax_Config_Data__c IBExpression1 = new  SVMXC__ServiceMax_Config_Data__c();
        IBExpression1.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Expressions' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' limit 1].Id;
        IBExpression1.SVMXC__Expression_Type__c = 'EXP_Named';
        IBExpression1.SVMXC__Field_Name__c = 'SVMXC__Status__c';
        IBExpression1.SVMXC__Expression_Rule__c = expressionRule.id;
        IBExpression1.SVMXC__Operand__c = 'Shipped';
        IBExpression1.SVMXC__Operator__c = 'eq';
        insert IBExpression1;
        
        SVMXC__ServiceMax_Config_Data__c IBExpression2 = new  SVMXC__ServiceMax_Config_Data__c();
        IBExpression2.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Expressions' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' limit 1].Id;
        IBExpression2.SVMXC__Expression_Type__c = 'EXP_Named';
        IBExpression2.SVMXC__Field_Name__c = 'SVMXC__Status__c';
        IBExpression2.SVMXC__Expression_Rule__c = expressionRule.id;
        IBExpression2.SVMXC__Operand__c = 'Installed';
        IBExpression2.SVMXC__Operator__c = 'eq';
        insert IBExpression2;
        
        SVMXC__ServiceMax_Config_Data__c IBExpression3 = new  SVMXC__ServiceMax_Config_Data__c();
        IBExpression3.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Expressions' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' limit 1].Id;
        IBExpression3.SVMXC__Expression_Type__c = 'EXP_Named';
        IBExpression3.SVMXC__Field_Name__c = 'SVMXC__Status__c';
        IBExpression3.SVMXC__Expression_Rule__c = expressionRule.id;
        IBExpression3.SVMXC__Operand__c = 'Loaned';
        IBExpression3.SVMXC__Operator__c = 'eq';
        insert IBExpression3;
        
        SVMXC__ServiceMax_Config_Data__c IBExpression4 = new  SVMXC__ServiceMax_Config_Data__c();
        IBExpression4.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Expressions' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' limit 1].Id;
        IBExpression4.SVMXC__Expression_Type__c = 'EXP_Named';
        IBExpression4.SVMXC__Field_Name__c = 'SVMXC__Status__c';
        IBExpression4.SVMXC__Expression_Rule__c = expressionRule.id;
        IBExpression4.SVMXC__Operand__c = 'Leased';
        IBExpression4.SVMXC__Operator__c = 'eq';
        insert IBExpression4;
        
        
        SVMXC__ServiceMax_Processes__c tsProcess = new SVMXC__ServiceMax_Processes__c();
        tsProcess.SVMXC__Name__c = 'Schedule SFM Header';
        tsProcess.SVMXC__ProcessID__c = 'SCHEDULESFMHEADER';
        tsProcess.SVMXC__MapID__c = 'SCHEDULESFMHEADER';
        tsProcess.SVMXC__Dispatch_Timezone__c = 'Asia/Kolkata';
        tsProcess.SVMXC__Capture_Log__c = true;
        tsProcess.SVMXC__Assign_To_Dispatcher__c = [Select id From User limit 1].id; 
        insert tsProcess;
        
        SVMXC__ServiceMax_Config_Data__c servicesConfigdata = new SVMXC__ServiceMax_Config_Data__c();
        servicesConfigdata.Object_Name__c = 'SVMXC__Installed_Product__c';
        servicesConfigdata.Expression_Rule__c= expressionRule.id; 
        servicesConfigdata.SVMXC__Class_Name__c = 'APL_Entitlement';
        servicesConfigdata.SVMXC__Namespace__c = '';
        servicesConfigdata.SVMXC__Dispatch_Process__c = tsProcess.id;
        servicesConfigdata.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Schedule Detail' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' limit 1].Id;
        
        insert servicesConfigdata;
        
        SVMXC__ServiceMax_Config_Data__c configRec = [SELECT Id, Namespace__c,
                                                             Class_Name__c,
                                                             Previous_Execution_Completed_On__c, Previous_Execution_Status__c, 
                                                             Previous_Execution_Started_On__c, Object_Name__c, 
                                                             Expression_Rule__r.Parent_Object_Criteria__c,
                                                             SVMXC__Dispatch_Process__r.SVMXC__Name__c, SVMXC__Dispatch_Process__r.SVMXC__ProcessID__c, 
                                                             SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Timezone__c, SVMXC__Dispatch_Process__r.SVMXC__Assign_To_Dispatcher__c,
                                                             SVMXC__Dispatch_Process__r.SVMXC__Capture_Log__c
                                                             FROM SVMXC__ServiceMax_Config_Data__c WHERE ID = :servicesConfigdata.id];
        
        Test.startTest();
        SFM_ScheduledBatch batchCounterReadingObj = new SFM_ScheduledBatch();
        batchCounterReadingObj.scheduleDetailConfig = configRec;
        Database.executebatch(batchCounterReadingObj);
        Test.stopTest();
    }

}