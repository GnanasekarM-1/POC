@isTest
Private class CONF_SetupWOBillingProcess_UT
{
    static testMethod void CONF_SetupWOBillingProcess_UnitTest()
    {
        System.currentPageReference().getParameters().put('SVMX_Mode', 'New');
        
        RecordType WOBilProcess_Rtype = [select Id from RecordType where Name='Work Order Billing Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpHdr_Rtype = [select Id from RecordType where Name='SVMX Rule'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpDtl_Rtype = [select Id from RecordType where Name='Expressions'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        RecordType ExpSrcUpdate_Rtype = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        RecordType Schedule_Rtype = [select Id from RecordType where Name='Schedule'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        
        CONF_SetupWOBillingProcess WOPro = new CONF_SetupWOBillingProcess();
        WOPro.WOBillingProcess.SVMXC__Name__c = 'WOProcess000101';
        WOPro.WOBillingProcess.SVMXC__ProcessID__c = 'WOProcess000101';
        WOPro.WOBillingProcess.SVMXC__Description__c = 'WOProcess000101';
        WOPro.WOBillingProcess.SVMXC__Active__c = true;
        WOPro.WOBillingProcess.SVMXC__Secondary_Consolidation_Rule__c = WOPro.getTAG009();
        WOPro.WOBillingProcess.SVMXC__Tertiary_Consolidation_Rule__c = WOPro.getTAG009();
        WOPro.WOBillingProcess.SVMXC__Secondary_Consolidation_Rule_Case__c = WOPro.getTAG009();
        WOPro.WOBillingProcess.SVMXC__Tertiary_Consolidation_Rule_Case__c = WOPro.getTAG009();
        WOPro.WOBillingProcess.SVMXC__Capture_Log__c = true;
        WOPro.WOBillingProcess.SVMXC__Include_Product__c = false;
        WOPro.WOBillingProcess.SVMXC__Primary_Consolidation_Rule__c = 'Per Record';
        WOPro.WOBillingProcess.SVMXC__Email_On_Error__c = 'abc@abc.com';
        WOPro.WOBillingProcess.SVMXC__Email_On_Success__c = 'abc@abc.com';
        
        WOPro.quickSave();
         WOPro.Saveclose();
        WOPro.NewExp();
        WOPro.ExpWO.namedExpression.SVMXC__Name__c = 'TestExp000100';
        WOPro.ExpWO.namedExpression.SVMXC__ProcessID__c = 'TestExp000100';
        
        SVMXC__ServiceMax_Config_Data__c confData = new SVMXC__ServiceMax_Config_Data__c();
        confData.RecordTypeId = ExpDtl_Rtype.Id;
        confData.SVMXC__Field_Name__c = 'SVMXC__Active__c';
        confData.SVMXC__Operator__c = 'eq';
        confData.SVMXC__Operand__c = 'true';
        WOPro.ExpWO.expressionDetails.add(confData);
        WOPro.saveExps();
        SVMXC__ServiceMax_Config_Data__c confData1 = new SVMXC__ServiceMax_Config_Data__c();
        confData1.SVMXC__Sequence__c = 1;
        confData1.SVMXC__Target_Field_Name__c = 'SVMXC__Active__c';
        confData1.SVMXC__Action__c = 'Set';
        confData1.SVMXC__Display_Value__c = 'true';
        WOPro.lstSrcUpdates.add(confData1);
        
        SVMXC__ServiceMax_Config_Data__c confData21 = new SVMXC__ServiceMax_Config_Data__c();
        confData21.SVMXC__Sequence__c = 1;
        confData21.SVMXC__Run_At__c = '00:00 AM';
        confData21.SVMXC__Schedule_Days__c = 'Sunday';
        confData21.SVMXC__Run_Type__c='Day of Week';
        WOPro.lstSchedules.add(confData21);
        SVMXC__ServiceMax_Config_Data__c confData31 = new SVMXC__ServiceMax_Config_Data__c();
        confData31.SVMXC__Sequence__c = 2;
        confData31.SVMXC__Run_At__c = '00:00 AM';
        confData31.SVMXC__Schedule_Days__c = 'Sunday';
        confData31.SVMXC__Run_Type__c='Day of Week';
        WOPro.Chngruntype();
        WOPro.lstSchedules.add(confData31);
        WOPro.quickSave();
        WOPro.Saveclose();
        WOPro.SelectedRow = '1';
        WOPro.lstSchedules_DelRow();        
        
        /* WOPro.selectedWOFld1 = 'Account';
        WOPro.selectedWOFld2 = WOPro.getTAG009();
        WOPro.selectedWOFld3 = WOPro.getTAG009(); 
        WOPro.quickSave();
        CONF_SetupWOBillingProcess WOPro1 = new CONF_SetupWOBillingProcess();
        WOPro1.processName = null;
        WOPro1.processID = null;
        WOPro1.processDesc = null;
        WOPro1.selectedWOFld1 = 'Account';
        WOPro1.selectedWOFld2 = WOPro1.getTAG009();
        WOPro1.selectedWOFld3 = WOPro1.getTAG009();
        WOPro1.isEnableLogging = true;
        WOPro1.isIncludeNonBillableLines = false;
        WOPro1.selectedWOFld1 = 'Work Order';
        WOPro1.WOBillingProcess.SVMXC__Email_On_Error__c = null;
         WOPro1.quickSave();
         WOPro1.processID = 'aa';
        */
          //WOPro1.quickSave();
    }
    static testMethod void CONF_SetupWOBillingProcess_UnitTest1()
    {
    
        RecordType WOBilProcess_Rtype = [select Id from RecordType where Name='Work Order Billing Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpHdr_Rtype = [select Id from RecordType where Name='SVMX Rule'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpDtl_Rtype = [select Id from RecordType where Name='Expressions'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        RecordType ExpSrcUpdate_Rtype = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        RecordType Schedule_Rtype = [select Id from RecordType where Name='Schedule'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        User userTimeZone = [Select Id,TimeZoneSidKey from User where Id =: UserInfo.getUserId()];                 
        
        // creating expression for Work Order
        SVMXC__ServiceMax_Processes__c exp_WorkOrder = new SVMXC__ServiceMax_Processes__c();
        exp_WorkOrder.SVMXC__Name__c = 'newTestExpForWO';
        exp_WorkOrder.SVMXC__Rule_Type__c = 'Named Expression';
        exp_WorkOrder.RecordTypeId = ExpHdr_Rtype.Id;
        exp_WorkOrder.SVMXC__ProcessID__c = 'newTestExpForWO';
        exp_WorkOrder.SVMXC__SettingId__c = 'newTestExpForWO';
        exp_WorkOrder.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        insert exp_WorkOrder;
        
        SVMXC__ServiceMax_Config_Data__c confData1 = new SVMXC__ServiceMax_Config_Data__c();
        confData1.SVMXC__Expression_Rule__c = exp_WorkOrder.Id;
        confData1.SVMXC__Expression_Type__c = 'EXP_Named';
        confData1.SVMXC__Field_Name__c = 'SVMXC__Case__c';
        confData1.SVMXC__Operator__c = 'isnotnull';
        confData1.SVMXC__Display_Type__c = 'REFERENCE';
        confData1.SVMXC__Sequence__c = 1;
        confData1.RecordTypeId = ExpDtl_Rtype.Id;
        insert confData1;
        
        // creating expression for Case
        SVMXC__ServiceMax_Processes__c exp_Case = new SVMXC__ServiceMax_Processes__c();
        exp_Case.SVMXC__Name__c = 'newTestExpForCase';
        exp_Case.SVMXC__Rule_Type__c = 'Named Expression';
        exp_Case.RecordTypeId = ExpHdr_Rtype.Id;
        exp_Case.SVMXC__ProcessID__c = 'newTestExpForCase';
        exp_Case.SVMXC__SettingId__c = 'newTestExpForCase';
        exp_Case.SVMXC__Source_Object_Name__c = 'Case';
        insert exp_Case;
        
        SVMXC__ServiceMax_Config_Data__c confData1_Case = new SVMXC__ServiceMax_Config_Data__c();
        confData1_Case.SVMXC__Expression_Rule__c = exp_Case.Id;
        confData1_Case.SVMXC__Expression_Type__c = 'EXP_Named';
        confData1_Case.SVMXC__Field_Name__c = 'AccountId';
        confData1_Case.SVMXC__Operator__c = 'isnotnull';
        confData1_Case.SVMXC__Display_Type__c = 'REFERENCE';
        confData1_Case.SVMXC__Sequence__c = 1;
        confData1_Case.RecordTypeId = ExpDtl_Rtype.Id;
        insert confData1_Case;
        
        // creating work order billing process
        SVMXC__ServiceMax_Processes__c newWOBillingPrcs = new SVMXC__ServiceMax_Processes__c();
        newWOBillingPrcs.SVMXC__Name__c = 'invoiceProcess';
        newWOBillingPrcs.SVMXC__ProcessID__c = 'invoiceProcess';
        newWOBillingPrcs.SVMXC__Description__c = 'invoiceProcess';
        newWOBillingPrcs.SVMXC__Active__c = true;
        newWOBillingPrcs.SVMXC__Module__c = exp_WorkOrder.Id;
        newWOBillingPrcs.SVMXC__Submodule__c = exp_Case.Id;
        newWOBillingPrcs.SVMXC__Primary_Consolidation_Rule__c = '';
        newWOBillingPrcs.SVMXC__Secondary_Consolidation_Rule__c = '';
        newWOBillingPrcs.SVMXC__Tertiary_Consolidation_Rule__c = '';
        newWOBillingPrcs.SVMXC__Secondary_Consolidation_Rule_Case__c = '';
        newWOBillingPrcs.SVMXC__Tertiary_Consolidation_Rule_Case__c = '';
        newWOBillingPrcs.SVMXC__Include_Product__c = true;
        newWOBillingPrcs.SVMXC__Node_Parent__c = null;
        newWOBillingPrcs.SVMXC__Process__c = null;
        newWOBillingPrcs.SVMXC__Process1__c = null;
        newWOBillingPrcs.SVMXC__Process2__c = null;
        newWOBillingPrcs.SVMXC__Process3__c = null;
        newWOBillingPrcs.SVMXC__Dispatch_Timezone__c = userTimeZone.TimeZoneSidKey;
        newWOBillingPrcs.SVMXC__Email_On_Success__c = 'sharad@gmail.com';
        newWOBillingPrcs.SVMXC__Email_On_Error__c = 'sharad@gmail.com';
        newWOBillingPrcs.SVMXC__Capture_Log__c = true;
        newWOBillingPrcs.RecordTypeId = WOBilProcess_Rtype.Id;
        newWOBillingPrcs.SVMXC__Invoice_Scope__c = 'Work Order and Case Both';
        insert newWOBillingPrcs;
        
        SVMXC__ServiceMax_Config_Data__c confData12 = new SVMXC__ServiceMax_Config_Data__c();
        confData12.SVMXC__Sequence__c = 1;
        confData12.SVMXC__Target_Field_Name__c = 'SVMXC__Street__c';
        confData12.SVMXC__Action__c = 'Set';
        confData12.RecordTypeId = ExpSrcUpdate_Rtype.Id;
        confData12.SVMXC__Dispatch_Process__c = newWOBillingPrcs.Id;
        confData12.SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_INVOICE';
        confData12.SVMXC__Display_Value__c = 'MG Road';
        insert confData12;
        
        SVMXC__ServiceMax_Config_Data__c confData2 = new SVMXC__ServiceMax_Config_Data__c();
        confData2.SVMXC__Sequence__c = 1;
        confData2.SVMXC__Target_Field_Name__c = 'Status';
        confData2.SVMXC__Action__c = 'Set';
        confData2.RecordTypeId = ExpSrcUpdate_Rtype.Id;
        confData2.SVMXC__Dispatch_Process__c = newWOBillingPrcs.Id;
        confData2.SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_INVOICE_CASE';
        confData2.SVMXC__Display_Value__c = 'Closed';
        insert confData2;
        
        SVMXC__ServiceMax_Config_Data__c confData21 = new SVMXC__ServiceMax_Config_Data__c();
        confData21.SVMXC__Sequence__c = 1;
        confData21.SVMXC__Run_At__c = '00:00 AM';
        confData21.SVMXC__Schedule_Days__c = 'Sunday';
        confData21.SVMXC__Run_Type__c='Day of Week';
        confData21.SVMXC__Dispatch_Process__c = newWOBillingPrcs.Id;
        confData21.RecordTypeId = Schedule_Rtype.Id;
        insert confData21;
        
        SVMXC__ServiceMax_Config_Data__c confData211 = new SVMXC__ServiceMax_Config_Data__c();
        confData211.SVMXC__Sequence__c = 2;
        confData211.SVMXC__Run_At__c = '00:00 AM';
        confData211.SVMXC__Day_to_Run__c = '2';
        confData211.SVMXC__Run_Type__c='Date of Month';
        confData211.SVMXC__Dispatch_Process__c = newWOBillingPrcs.Id;
        confData211.RecordTypeId = Schedule_Rtype.Id;
        insert confData211;
        
        System.currentPageReference().getParameters().put('SVMX_Mode', 'Edit');
        System.currentPageReference().getParameters().put('SVMX_RecordId', newWOBillingPrcs.Id);
        
        CONF_SetupWOBillingProcess InvoicePro = new CONF_SetupWOBillingProcess();
        InvoicePro.quickSave();
        
        
    }
    static testMethod void CONF_SetupWOBillingProcess_UnitTest3()
    {
    
        RecordType WOBilProcess_Rtype = [select Id from RecordType where Name='Work Order Billing Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpHdr_Rtype = [select Id from RecordType where Name='SVMX Rule'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpDtl_Rtype = [select Id from RecordType where Name='Expressions'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        RecordType ExpSrcUpdate_Rtype = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        RecordType Schedule_Rtype = [select Id from RecordType where Name='Schedule'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        User userTimeZone = [Select Id,TimeZoneSidKey from User where Id =: UserInfo.getUserId()];                 
        
        // creating expression for Work Order
        SVMXC__ServiceMax_Processes__c exp_WorkOrder = new SVMXC__ServiceMax_Processes__c();
        exp_WorkOrder.SVMXC__Name__c = 'newTestExpForWO';
        exp_WorkOrder.SVMXC__Rule_Type__c = 'Named Expression';
        exp_WorkOrder.RecordTypeId = ExpHdr_Rtype.Id;
        exp_WorkOrder.SVMXC__ProcessID__c = 'newTestExpForWO';
        exp_WorkOrder.SVMXC__SettingId__c = 'newTestExpForWO';
        exp_WorkOrder.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        insert exp_WorkOrder;
        
        SVMXC__ServiceMax_Config_Data__c confData1 = new SVMXC__ServiceMax_Config_Data__c();
        confData1.SVMXC__Expression_Rule__c = exp_WorkOrder.Id;
        confData1.SVMXC__Expression_Type__c = 'EXP_Named';
        confData1.SVMXC__Field_Name__c = 'SVMXC__Case__c';
        confData1.SVMXC__Operator__c = 'isnotnull';
        confData1.SVMXC__Display_Type__c = 'REFERENCE';
        confData1.SVMXC__Sequence__c = 1;
        confData1.RecordTypeId = ExpDtl_Rtype.Id;
        insert confData1;
        
        // creating expression for Case
        SVMXC__ServiceMax_Processes__c exp_Case = new SVMXC__ServiceMax_Processes__c();
        exp_Case.SVMXC__Name__c = 'newTestExpForCase';
        exp_Case.SVMXC__Rule_Type__c = 'Named Expression';
        exp_Case.RecordTypeId = ExpHdr_Rtype.Id;
        exp_Case.SVMXC__ProcessID__c = 'newTestExpForCase';
        exp_Case.SVMXC__SettingId__c = 'newTestExpForCase';
        exp_Case.SVMXC__Source_Object_Name__c = 'Case';
        insert exp_Case;
        
        SVMXC__ServiceMax_Config_Data__c confData1_Case = new SVMXC__ServiceMax_Config_Data__c();
        confData1_Case.SVMXC__Expression_Rule__c = exp_Case.Id;
        confData1_Case.SVMXC__Expression_Type__c = 'EXP_Named';
        confData1_Case.SVMXC__Field_Name__c = 'AccountId';
        confData1_Case.SVMXC__Operator__c = 'isnotnull';
        confData1_Case.SVMXC__Display_Type__c = 'REFERENCE';
        confData1_Case.SVMXC__Sequence__c = 1;
        confData1_Case.RecordTypeId = ExpDtl_Rtype.Id;
        insert confData1_Case;
        
        // creating work order billing process
        SVMXC__ServiceMax_Processes__c newWOBillingPrcs = new SVMXC__ServiceMax_Processes__c();
        newWOBillingPrcs.SVMXC__Name__c = 'invoiceProcess';
        newWOBillingPrcs.SVMXC__ProcessID__c = 'invoiceProcess';
        newWOBillingPrcs.SVMXC__Description__c = 'invoiceProcess';
        newWOBillingPrcs.SVMXC__Active__c = true;
        newWOBillingPrcs.SVMXC__Module__c = exp_WorkOrder.Id;
        newWOBillingPrcs.SVMXC__Submodule__c = exp_Case.Id;
        newWOBillingPrcs.SVMXC__Primary_Consolidation_Rule__c = '';
        newWOBillingPrcs.SVMXC__Secondary_Consolidation_Rule__c = '';
        newWOBillingPrcs.SVMXC__Tertiary_Consolidation_Rule__c = '';
        newWOBillingPrcs.SVMXC__Secondary_Consolidation_Rule_Case__c = '';
        newWOBillingPrcs.SVMXC__Tertiary_Consolidation_Rule_Case__c = '';
        newWOBillingPrcs.SVMXC__Include_Product__c = true;
        newWOBillingPrcs.SVMXC__Node_Parent__c = null;
        newWOBillingPrcs.SVMXC__Process__c = null;
        newWOBillingPrcs.SVMXC__Process1__c = null;
        newWOBillingPrcs.SVMXC__Process2__c = null;
        newWOBillingPrcs.SVMXC__Process3__c = null;
        newWOBillingPrcs.SVMXC__Dispatch_Timezone__c = userTimeZone.TimeZoneSidKey;
        newWOBillingPrcs.SVMXC__Email_On_Success__c = 'sharad@gmail.com';
        newWOBillingPrcs.SVMXC__Email_On_Error__c = 'sharad@gmail.com';
        newWOBillingPrcs.SVMXC__Capture_Log__c = true;
        newWOBillingPrcs.RecordTypeId = WOBilProcess_Rtype.Id;
        newWOBillingPrcs.SVMXC__Invoice_Scope__c = 'Work Order and Case Both';
        insert newWOBillingPrcs;
        
        SVMXC__ServiceMax_Config_Data__c confData12 = new SVMXC__ServiceMax_Config_Data__c();
        confData12.SVMXC__Sequence__c = 1;
        confData12.SVMXC__Target_Field_Name__c = 'SVMXC__Street__c';
        confData12.SVMXC__Action__c = 'Set';
        confData12.RecordTypeId = ExpSrcUpdate_Rtype.Id;
        confData12.SVMXC__Dispatch_Process__c = newWOBillingPrcs.Id;
        confData12.SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_INVOICE';
        confData12.SVMXC__Display_Value__c = 'MG Road';
        insert confData12;
        SVMXC__ServiceMax_Config_Data__c confData21 = new SVMXC__ServiceMax_Config_Data__c();
        confData21.SVMXC__Sequence__c = 1;
        confData21.SVMXC__Run_At__c = '00:00 AM';
        confData21.SVMXC__Schedule_Days__c = 'Sunday';
        confData21.SVMXC__Run_Type__c='Day of Week';
        confData21.SVMXC__Dispatch_Process__c = newWOBillingPrcs.Id;
        confData21.RecordTypeId = Schedule_Rtype.Id;
        insert confData21;
        
        SVMXC__ServiceMax_Config_Data__c confData211 = new SVMXC__ServiceMax_Config_Data__c();
        confData211.SVMXC__Sequence__c = 2;
        confData211.SVMXC__Run_At__c = '00:00 AM';
        confData211.SVMXC__Day_to_Run__c = '2';
        confData211.SVMXC__Run_Type__c='Date of Month';
        confData211.SVMXC__Dispatch_Process__c = newWOBillingPrcs.Id;
        confData211.RecordTypeId = Schedule_Rtype.Id;
        insert confData211;
        
        SVMXC__ServiceMax_Config_Data__c confData2 = new SVMXC__ServiceMax_Config_Data__c();
        confData2.SVMXC__Sequence__c = 1;
        confData2.SVMXC__Target_Field_Name__c = 'Status';
        confData2.SVMXC__Action__c = 'Set';
        confData2.RecordTypeId = ExpSrcUpdate_Rtype.Id;
        confData2.SVMXC__Dispatch_Process__c = newWOBillingPrcs.Id;
        confData2.SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_INVOICE_CASE';
        confData2.SVMXC__Display_Value__c = 'Closed';
        insert confData2;
        
        System.currentPageReference().getParameters().put('SVMX_Mode', 'Clone');
        System.currentPageReference().getParameters().put('SVMX_RecordId', newWOBillingPrcs.Id);
        
        CONF_SetupWOBillingProcess InvoicePro = new CONF_SetupWOBillingProcess();
    }
    static testMethod void CONF_SetupWOBillingProcess_UnitTest4()
    {
    
        RecordType WOBilProcess_Rtype = [select Id from RecordType where Name='Work Order Billing Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpHdr_Rtype = [select Id from RecordType where Name='SVMX Rule'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpDtl_Rtype = [select Id from RecordType where Name='Expressions'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        RecordType ExpSrcUpdate_Rtype = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        RecordType Schedule_Rtype = [select Id from RecordType where Name='Schedule'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        User userTimeZone = [Select Id,TimeZoneSidKey from User where Id =: UserInfo.getUserId()];                 
        
        // creating expression for Work Order
        SVMXC__ServiceMax_Processes__c exp_WorkOrder = new SVMXC__ServiceMax_Processes__c();
        exp_WorkOrder.SVMXC__Name__c = 'newTestExpForWO';
        exp_WorkOrder.SVMXC__Rule_Type__c = 'Named Expression';
        exp_WorkOrder.RecordTypeId = ExpHdr_Rtype.Id;
        exp_WorkOrder.SVMXC__ProcessID__c = 'newTestExpForWO';
        exp_WorkOrder.SVMXC__SettingId__c = 'newTestExpForWO';
        exp_WorkOrder.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        insert exp_WorkOrder;
        
        SVMXC__ServiceMax_Config_Data__c confData1 = new SVMXC__ServiceMax_Config_Data__c();
        confData1.SVMXC__Expression_Rule__c = exp_WorkOrder.Id;
        confData1.SVMXC__Expression_Type__c = 'EXP_Named';
        confData1.SVMXC__Field_Name__c = 'SVMXC__Case__c';
        confData1.SVMXC__Operator__c = 'isnotnull';
        confData1.SVMXC__Display_Type__c = 'REFERENCE';
        confData1.SVMXC__Sequence__c = 1;
        confData1.RecordTypeId = ExpDtl_Rtype.Id;
        insert confData1;
        
        // creating expression for Case
        SVMXC__ServiceMax_Processes__c exp_Case = new SVMXC__ServiceMax_Processes__c();
        exp_Case.SVMXC__Name__c = 'newTestExpForCase';
        exp_Case.SVMXC__Rule_Type__c = 'Named Expression';
        exp_Case.RecordTypeId = ExpHdr_Rtype.Id;
        exp_Case.SVMXC__ProcessID__c = 'newTestExpForCase';
        exp_Case.SVMXC__SettingId__c = 'newTestExpForCase';
        exp_Case.SVMXC__Source_Object_Name__c = 'Case';
        insert exp_Case;
        
        SVMXC__ServiceMax_Config_Data__c confData1_Case = new SVMXC__ServiceMax_Config_Data__c();
        confData1_Case.SVMXC__Expression_Rule__c = exp_Case.Id;
        confData1_Case.SVMXC__Expression_Type__c = 'EXP_Named';
        confData1_Case.SVMXC__Field_Name__c = 'AccountId';
        confData1_Case.SVMXC__Operator__c = 'isnotnull';
        confData1_Case.SVMXC__Display_Type__c = 'REFERENCE';
        confData1_Case.SVMXC__Sequence__c = 1;
        confData1_Case.RecordTypeId = ExpDtl_Rtype.Id;
        insert confData1_Case;
        
        // creating work order billing process
        SVMXC__ServiceMax_Processes__c newWOBillingPrcs = new SVMXC__ServiceMax_Processes__c();
        newWOBillingPrcs.SVMXC__Name__c = 'invoiceProcess';
        newWOBillingPrcs.SVMXC__ProcessID__c = 'invoiceProcess';
        newWOBillingPrcs.SVMXC__Description__c = 'invoiceProcess';
        newWOBillingPrcs.SVMXC__Active__c = true;
        newWOBillingPrcs.SVMXC__Module__c = exp_WorkOrder.Id;
        newWOBillingPrcs.SVMXC__Submodule__c = exp_Case.Id;
        newWOBillingPrcs.SVMXC__Primary_Consolidation_Rule__c = '';
        newWOBillingPrcs.SVMXC__Secondary_Consolidation_Rule__c = '';
        newWOBillingPrcs.SVMXC__Tertiary_Consolidation_Rule__c = '';
        newWOBillingPrcs.SVMXC__Secondary_Consolidation_Rule_Case__c = '';
        newWOBillingPrcs.SVMXC__Tertiary_Consolidation_Rule_Case__c = '';
        newWOBillingPrcs.SVMXC__Include_Product__c = true;
        newWOBillingPrcs.SVMXC__Node_Parent__c = null;
        newWOBillingPrcs.SVMXC__Process__c = null;
        newWOBillingPrcs.SVMXC__Process1__c = null;
        newWOBillingPrcs.SVMXC__Process2__c = null;
        newWOBillingPrcs.SVMXC__Process3__c = null;
        newWOBillingPrcs.SVMXC__Dispatch_Timezone__c = userTimeZone.TimeZoneSidKey;
        newWOBillingPrcs.SVMXC__Email_On_Success__c = 'sharad@gmail.com';
        newWOBillingPrcs.SVMXC__Email_On_Error__c = 'sharad@gmail.com';
        newWOBillingPrcs.SVMXC__Capture_Log__c = true;
        newWOBillingPrcs.RecordTypeId = WOBilProcess_Rtype.Id;
        newWOBillingPrcs.SVMXC__Invoice_Scope__c = 'Work Order';
        insert newWOBillingPrcs;
        
        SVMXC__ServiceMax_Config_Data__c confData12 = new SVMXC__ServiceMax_Config_Data__c();
        confData12.SVMXC__Sequence__c = 1;
        confData12.SVMXC__Target_Field_Name__c = 'SVMXC__Street__c';
        confData12.SVMXC__Action__c = 'Set';
        confData12.RecordTypeId = ExpSrcUpdate_Rtype.Id;
        confData12.SVMXC__Dispatch_Process__c = newWOBillingPrcs.Id;
        confData12.SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_INVOICE';
        confData12.SVMXC__Display_Value__c = 'MG Road';
        insert confData12;
        
        SVMXC__ServiceMax_Config_Data__c confData21 = new SVMXC__ServiceMax_Config_Data__c();
        confData21.SVMXC__Sequence__c = 1;
        confData21.SVMXC__Run_At__c = '00:00 AM';
        confData21.SVMXC__Schedule_Days__c = 'Sunday';
        confData21.SVMXC__Run_Type__c='Day of Week';
        confData21.SVMXC__Dispatch_Process__c = newWOBillingPrcs.Id;
        confData21.RecordTypeId = Schedule_Rtype.Id;
        insert confData21;
        
        SVMXC__ServiceMax_Config_Data__c confData211 = new SVMXC__ServiceMax_Config_Data__c();
        confData211.SVMXC__Sequence__c = 2;
        confData211.SVMXC__Run_At__c = '00:00 AM';
        confData211.SVMXC__Day_to_Run__c = '2';
        confData211.SVMXC__Run_Type__c='Date of Month';
        confData211.SVMXC__Dispatch_Process__c = newWOBillingPrcs.Id;
        confData211.RecordTypeId = Schedule_Rtype.Id;
        insert confData211;
        
        SVMXC__ServiceMax_Config_Data__c confData2 = new SVMXC__ServiceMax_Config_Data__c();
        confData2.SVMXC__Sequence__c = 1;
        confData2.SVMXC__Target_Field_Name__c = 'Status';
        confData2.SVMXC__Action__c = 'Set';
        confData2.RecordTypeId = ExpSrcUpdate_Rtype.Id;
        confData2.SVMXC__Dispatch_Process__c = newWOBillingPrcs.Id;
        confData2.SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_INVOICE_CASE';
        confData2.SVMXC__Display_Value__c = 'Closed';
        insert confData2;
        
        System.currentPageReference().getParameters().put('SVMX_Mode', 'Edit');
        System.currentPageReference().getParameters().put('SVMX_RecordId', newWOBillingPrcs.Id);
        
        CONF_SetupWOBillingProcess InvoicePro = new CONF_SetupWOBillingProcess();
        InvoicePro.quickSave();
    }
    static testMethod void CONF_SetupWOBillingProcess_UnitTest5()
    {
    
        RecordType WOBilProcess_Rtype = [select Id from RecordType where Name='Work Order Billing Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpHdr_Rtype = [select Id from RecordType where Name='SVMX Rule'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpDtl_Rtype = [select Id from RecordType where Name='Expressions'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        RecordType ExpSrcUpdate_Rtype = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        RecordType Schedule_Rtype = [select Id from RecordType where Name='Schedule'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        User userTimeZone = [Select Id,TimeZoneSidKey from User where Id =: UserInfo.getUserId()];                 
        
        // creating expression for Work Order
        SVMXC__ServiceMax_Processes__c exp_WorkOrder = new SVMXC__ServiceMax_Processes__c();
        exp_WorkOrder.SVMXC__Name__c = 'newTestExpForWO';
        exp_WorkOrder.SVMXC__Rule_Type__c = 'Named Expression';
        exp_WorkOrder.RecordTypeId = ExpHdr_Rtype.Id;
        exp_WorkOrder.SVMXC__ProcessID__c = 'newTestExpForWO';
        exp_WorkOrder.SVMXC__SettingId__c = 'newTestExpForWO';
        exp_WorkOrder.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        insert exp_WorkOrder;
        
        SVMXC__ServiceMax_Config_Data__c confData1 = new SVMXC__ServiceMax_Config_Data__c();
        confData1.SVMXC__Expression_Rule__c = exp_WorkOrder.Id;
        confData1.SVMXC__Expression_Type__c = 'EXP_Named';
        confData1.SVMXC__Field_Name__c = 'SVMXC__Case__c';
        confData1.SVMXC__Operator__c = 'isnotnull';
        confData1.SVMXC__Display_Type__c = 'REFERENCE';
        confData1.SVMXC__Sequence__c = 1;
        confData1.RecordTypeId = ExpDtl_Rtype.Id;
        insert confData1;
        
        // creating expression for Case
        SVMXC__ServiceMax_Processes__c exp_Case = new SVMXC__ServiceMax_Processes__c();
        exp_Case.SVMXC__Name__c = 'newTestExpForCase';
        exp_Case.SVMXC__Rule_Type__c = 'Named Expression';
        exp_Case.RecordTypeId = ExpHdr_Rtype.Id;
        exp_Case.SVMXC__ProcessID__c = 'newTestExpForCase';
        exp_Case.SVMXC__SettingId__c = 'newTestExpForCase';
        exp_Case.SVMXC__Source_Object_Name__c = 'Case';
        insert exp_Case;
        
        SVMXC__ServiceMax_Config_Data__c confData1_Case = new SVMXC__ServiceMax_Config_Data__c();
        confData1_Case.SVMXC__Expression_Rule__c = exp_Case.Id;
        confData1_Case.SVMXC__Expression_Type__c = 'EXP_Named';
        confData1_Case.SVMXC__Field_Name__c = 'AccountId';
        confData1_Case.SVMXC__Operator__c = 'isnotnull';
        confData1_Case.SVMXC__Display_Type__c = 'REFERENCE';
        confData1_Case.SVMXC__Sequence__c = 1;
        confData1_Case.RecordTypeId = ExpDtl_Rtype.Id;
        insert confData1_Case;
        
        // creating work order billing process
        SVMXC__ServiceMax_Processes__c newWOBillingPrcs = new SVMXC__ServiceMax_Processes__c();
        newWOBillingPrcs.SVMXC__Name__c = 'invoiceProcess';
        newWOBillingPrcs.SVMXC__ProcessID__c = 'invoiceProcess';
        newWOBillingPrcs.SVMXC__Description__c = 'invoiceProcess';
        newWOBillingPrcs.SVMXC__Active__c = true;
        newWOBillingPrcs.SVMXC__Module__c = exp_WorkOrder.Id;
        newWOBillingPrcs.SVMXC__Submodule__c = exp_Case.Id;
        newWOBillingPrcs.SVMXC__Primary_Consolidation_Rule__c = '';
        newWOBillingPrcs.SVMXC__Secondary_Consolidation_Rule__c = '';
        newWOBillingPrcs.SVMXC__Tertiary_Consolidation_Rule__c = '';
        newWOBillingPrcs.SVMXC__Secondary_Consolidation_Rule_Case__c = '';
        newWOBillingPrcs.SVMXC__Tertiary_Consolidation_Rule_Case__c = '';
        newWOBillingPrcs.SVMXC__Include_Product__c = true;
        newWOBillingPrcs.SVMXC__Node_Parent__c = null;
        newWOBillingPrcs.SVMXC__Process__c = null;
        newWOBillingPrcs.SVMXC__Process1__c = null;
        newWOBillingPrcs.SVMXC__Process2__c = null;
        newWOBillingPrcs.SVMXC__Process3__c = null;
        newWOBillingPrcs.SVMXC__Dispatch_Timezone__c = userTimeZone.TimeZoneSidKey;
        newWOBillingPrcs.SVMXC__Email_On_Success__c = 'sharad@gmail.com';
        newWOBillingPrcs.SVMXC__Email_On_Error__c = 'sharad@gmail.com';
        newWOBillingPrcs.SVMXC__Capture_Log__c = true;
        newWOBillingPrcs.RecordTypeId = WOBilProcess_Rtype.Id;
        newWOBillingPrcs.SVMXC__Invoice_Scope__c = 'Case';
        insert newWOBillingPrcs;
        
        SVMXC__ServiceMax_Config_Data__c confData12 = new SVMXC__ServiceMax_Config_Data__c();
        confData12.SVMXC__Sequence__c = 1;
        confData12.SVMXC__Target_Field_Name__c = 'SVMXC__Street__c';
        confData12.SVMXC__Action__c = 'Set';
        confData12.RecordTypeId = ExpSrcUpdate_Rtype.Id;
        confData12.SVMXC__Dispatch_Process__c = newWOBillingPrcs.Id;
        confData12.SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_INVOICE';
        confData12.SVMXC__Display_Value__c = 'MG Road';
        insert confData12;
        
        SVMXC__ServiceMax_Config_Data__c confData2 = new SVMXC__ServiceMax_Config_Data__c();
        confData2.SVMXC__Sequence__c = 1;
        confData2.SVMXC__Target_Field_Name__c = 'Status';
        confData2.SVMXC__Action__c = 'Set';
        confData2.RecordTypeId = ExpSrcUpdate_Rtype.Id;
        confData2.SVMXC__Dispatch_Process__c = newWOBillingPrcs.Id;
        confData2.SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_INVOICE_CASE';
        confData2.SVMXC__Display_Value__c = 'Closed';
        insert confData2;
        
        SVMXC__ServiceMax_Config_Data__c confData21 = new SVMXC__ServiceMax_Config_Data__c();
        confData21.SVMXC__Sequence__c = 1;
        confData21.SVMXC__Run_At__c = '00:00 AM';
        confData21.SVMXC__Schedule_Days__c = 'Sunday';
        confData21.SVMXC__Run_Type__c='Day of Week';
        confData21.SVMXC__Dispatch_Process__c = newWOBillingPrcs.Id;
        confData21.RecordTypeId = Schedule_Rtype.Id;
        insert confData21;
        
        SVMXC__ServiceMax_Config_Data__c confData211 = new SVMXC__ServiceMax_Config_Data__c();
        confData211.SVMXC__Sequence__c = 2;
        confData211.SVMXC__Run_At__c = '00:00 AM';
        confData211.SVMXC__Day_to_Run__c = '2';
        confData211.SVMXC__Run_Type__c='Date of Month';
        confData211.SVMXC__Dispatch_Process__c = newWOBillingPrcs.Id;
        confData211.RecordTypeId = Schedule_Rtype.Id;
        insert confData211;
        
        System.currentPageReference().getParameters().put('SVMX_Mode', 'Edit');
        System.currentPageReference().getParameters().put('SVMX_RecordId', newWOBillingPrcs.Id);
        try{
        CONF_SetupWOBillingProcess InvoicePro = new CONF_SetupWOBillingProcess();
        InvoicePro.quickSave();
        InvoicePro.woBillingProcess.SVMXC__ProcessID__c = 'PINV001_Work_Order';
        InvoicePro.lstSchedules[0].SVMXC__Run_Type__c = 'Day of Week';
        InvoicePro.lstSchedules[0].SVMXC__Schedule_Days__c = null;
        
        InvoicePro.lstSchedules[1].SVMXC__Run_Type__c = 'Date of Month';
        InvoicePro.lstSchedules[1].SVMXC__Schedule_Days__c = null;
        InvoicePro.quickSave();
        
        InvoicePro.DelIndex = '0';
        InvoicePro.HdrDeleteRowExp();
        InvoicePro.HdrDeleteRowExp_Case();
        
        InvoicePro.HdrADDRowExp();
        InvoicePro.HdrADDRowExp_Case();
        
        InvoicePro.srcUpdateHdrDeleteRow();
        InvoicePro.srcUpdateHdrDeleteRow_Case();
        }
        catch(Exception ex){}
    }
    static testMethod void CONF_SetupWOBillingProcess_UnitTestCustomlabelsNgetsetr()
    {
        CONF_SetupWOBillingProcess InvoicePro = new CONF_SetupWOBillingProcess();
        InvoicePro.getwoBillingProcess();
        InvoicePro.setwoBillingProcess(new SVMXC__ServiceMax_Processes__c());
        InvoicePro.getlstSrcUpdates();
        InvoicePro.setlstSrcUpdates(new List<SVMXC__ServiceMax_Config_Data__c>());
        InvoicePro.getlstSchedules();
        InvoicePro.setlstSchedules(new List<SVMXC__ServiceMax_Config_Data__c>());
        InvoicePro.getlstSchedules_toDelete();
        InvoicePro.setlstSchedules_toDelete(new List<SVMXC__ServiceMax_Config_Data__c>());
        InvoicePro.getexpWO();
        InvoicePro.setexpWO(new SFM_WrapperDef.SFM_Expression());
        InvoicePro.getexp_Case();
        InvoicePro.setexp_Case(new SFM_WrapperDef.SFM_Expression());
        InvoicePro.getexpDetailSize();
        InvoicePro.setexpDetailSize(1);
        InvoicePro.getsrcUpdateHdrSize();
        InvoicePro.setsrcUpdateHdrSize(1);
        InvoicePro.getexpDetailSize_Case();
        InvoicePro.setexpDetailSize_Case(1);
        InvoicePro.getsrcUpdateHdrSize_Case();
        InvoicePro.setsrcUpdateHdrSize_Case(1);
        InvoicePro.getintSeqVal();
        InvoicePro.setintSeqVal(1);
        
        InvoicePro.getlstCriteria();
        InvoicePro.getlstUpdateOperator();
        InvoicePro.setlstUpdateOperator(new List<SelectOption>());
        InvoicePro.getwoFldLst();
        InvoicePro.getwoFldLst2();
        InvoicePro.getwoFldLst3();
        InvoicePro.getoperatorSelectLst();
        InvoicePro.getobjMapSCtoInvoiceLst();
        InvoicePro.getobjMapSCtoInvoiceDtlLst();
        InvoicePro.getobjMapWDtoInvoiceLineLst();
        InvoicePro.getlstCriteria_Case();
        InvoicePro.getCaseFldLst();
        InvoicePro.getCaseFldLst2();
        InvoicePro.getCaseFldLst3();
        InvoicePro.getobjMapCasetoInvoiceDtlLst();
        InvoicePro.getobjMapCLtoInvoiceLineLst();
        InvoicePro.getlstSrcUpdates_Case();
        InvoicePro.setlstSrcUpdates_Case(new List<SVMXC__ServiceMax_Config_Data__c>());
        
        InvoicePro.GeneralInfo();
        InvoicePro.ConsolidationRule();
        InvoicePro.MappingRules();
        InvoicePro.SrcUpd();
        InvoicePro.Schedules();

        InvoicePro.IsValidString('');
        InvoicePro.IsValidString('SVMX');

        InvoicePro.AddException('');
        InvoicePro.IsValidString('SVMX');
        InvoicePro.EditExp();
        InvoicePro.EditExp_Case();
        InvoicePro.getsavedExpressionResultId();
        InvoicePro.cancel();
        InvoicePro.onChngWOFld1();
        
        InvoicePro.disabled = false;
        InvoicePro.isConsolidate = true;
        InvoicePro.onChngWOFld1();
        
        InvoicePro.isScopeForWO = true;
        InvoicePro.isScopeForCase = true;
        InvoicePro.onChangeScope();
        
        InvoicePro.isScopeForWO = false;
        InvoicePro.isScopeForCase = false;
        InvoicePro.onChangeScope();
        
        InvoicePro.onChngWOFld2();
        InvoicePro.onChngCaseFld2();
        InvoicePro.woBillingProcess.SVMXC__Secondary_Consolidation_Rule__c = InvoicePro.getTAG009();
        InvoicePro.woBillingProcess.SVMXC__Secondary_Consolidation_Rule_Case__c = InvoicePro.getTAG009();
        InvoicePro.onChngWOFld2();
        InvoicePro.onChngCaseFld2();
        
        InvoicePro.woBillingProcess.SVMXC__Name__c = null;
        InvoicePro.woBillingProcess.SVMXC__ProcessID__c = null;
        InvoicePro.isScopeForWO  = false;
        InvoicePro.validation();
        
        InvoicePro.woBillingProcess.SVMXC__ProcessID__c = 'ddd';
        InvoicePro.validation();
        
        InvoicePro.NewExp_Case();
        InvoicePro.submitExp();
        
        
        //custom labels
        InvoicePro.getHLPURL();
        InvoicePro.getHLPTITLE();
        InvoicePro.getTAG002();
        InvoicePro.getTAG003();
        InvoicePro.getTAG004();
        InvoicePro.getTAG010();
        InvoicePro.getTAG011();
        InvoicePro.getTAG012();
        InvoicePro.getTAG017();
        InvoicePro.getTAG018();
        InvoicePro.getTAG019();
        InvoicePro.getTAG020();
        InvoicePro.getTAG021();
        InvoicePro.getTAG022();
        InvoicePro.getTAG023();
        InvoicePro.getTAG024();
        InvoicePro.getTAG025();
        InvoicePro.getTAG057();
        InvoicePro.getTAG014();
        InvoicePro.getTAG015();
        InvoicePro.getTAG016();
        InvoicePro.getTAG058();
        InvoicePro.getTAG059();
        InvoicePro.getTAG005();
        InvoicePro.getTAG044();
        InvoicePro.getTAG045();
        InvoicePro.getTAG049();
        InvoicePro.getTAG050();
        InvoicePro.getTAG052();
        InvoicePro.getTAG053();
        InvoicePro.getTAG054();
        InvoicePro.getTAG055();
        InvoicePro.getTAG056();
        InvoicePro.getTAG006();
        InvoicePro.getTAG007();
        InvoicePro.getTAG008();
        InvoicePro.getTAG001();
        InvoicePro.getTAG013();
        InvoicePro.getTAG027();
        InvoicePro.getTAG028();
        InvoicePro.getTAG029();
        InvoicePro.getTAG030();
        InvoicePro.getTAG031();
        InvoicePro.getTAG032();
        InvoicePro.getTAG033();
        InvoicePro.getTAG034();
        InvoicePro.getTAG038();
        InvoicePro.getTAG043();
        InvoicePro.getTAG048();
        InvoicePro.getTAG051();
        InvoicePro.getTAG083();
        InvoicePro.getTAG090();
        InvoicePro.getTAG091();
        InvoicePro.getTAG092();
        InvoicePro.getTAG089();
        InvoicePro.getTAG090();
        InvoicePro.getTAG091();
        InvoicePro.getTAG092();
        InvoicePro.getTAG093();
        InvoicePro.getTAG094();
        InvoicePro.getTAG096();
        InvoicePro.getTAG097();
        InvoicePro.getTAG098();
        InvoicePro.getTAG099();
        InvoicePro.getTAG100();
        InvoicePro.getTAG101();
        InvoicePro.getTAG102();
        InvoicePro.getTAG103();
        InvoicePro.getTAG104();
        //InvoicePro.getTAG105();
        InvoicePro.getTAG106();
        InvoicePro.getTAG107();
        InvoicePro.getTAG108();
        //InvoicePro.getTAG109();
        InvoicePro.getTAG110();

    }
}