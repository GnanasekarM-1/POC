@isTest
Private class CONF_SetupSCONBillingProcess_UT
{
    static testMethod void CONF_SetupSCONBillingProcess_UnitTest()
    {
        System.currentPageReference().getParameters().put('SVMX_Mode', 'New');
        
        RecordType SCONBilProcess_Rtype = [select Id from RecordType where Name='Contract Billing Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        
        CONF_SetupSCONBillingProcess SCONPro = new CONF_SetupSCONBillingProcess();
        SCONPro.selectedSCONFld1 = 'Contract';
        SCONPro.onChngSCONFld1();
        SCONPro.selectedSCONFld1 = 'Account';
        SCONPro.onChngSCONFld1();
        
        SCONPro.NewExp();
        SCONPro.HdrDeleteRowExp();
        
        SCONPro.srcUpdateHdrDeleteRow();
        
        SCONPro.GeneralInfo();
        SCONPro.InvoiceRules();
        SCONPro.SrcUpd();
        SCONPro.Schedules();
        
        SCONPro.setSCONBillingProcess(SCONPro.getSCONBillingProcess());
        SCONPro.setlstSrcUpdates(SCONPro.getlstSrcUpdates());
        SCONPro.setlstSchedules(SCONPro.getlstSchedules());
        SCONPro.setExpDetailSize(SCONPro.getExpDetailSize());
        SCONPro.setsrcUpdateHdrSize(SCONPro.getsrcUpdateHdrSize());
        SCONPro.getlstCriteria();
        SCONPro.setlstUpdateOperator(SCONPro.getlstUpdateOperator());
        SCONPro.getSCONFldLst();
        SCONPro.getSCONFldLst1();
        SCONPro.getSCONFldLst2();
        SCONPro.getOperatorSelectLst();
        SCONPro.getObjMapSCtoInvoiceLst();
        SCONPro.getObjMapSCtoInvoiceDtlLst();
        SCONPro.setExpSCON(SCONPro.getExpSCON());
        SCONPro.setsavedExpressionResultId(SCONPro.getsavedExpressionResultId());
        SCONPro.cancel();
        SCONPro.getHLPURL();
        SCONPro.getHLPTITLE();
        SCONPro.getTAG001();
        SCONPro.getTAG002();
        SCONPro.getTAG003();
        SCONPro.getTAG004();
        SCONPro.getTAG005();
        SCONPro.getTAG006();
        SCONPro.getTAG007();
        SCONPro.getTAG008();
        SCONPro.getTAG010();
        SCONPro.getTAG011();
        SCONPro.getTAG012();
        SCONPro.getTAG013();
        SCONPro.getTAG014();
        SCONPro.getTAG015();
        SCONPro.getTAG016();
        SCONPro.getTAG017();
        SCONPro.getTAG018();
        SCONPro.getTAG019();
        SCONPro.getTAG020();
        SCONPro.getTAG021();
        SCONPro.getTAG022();
        SCONPro.getTAG023();
        SCONPro.getTAG024();
        SCONPro.getTAG025();
        SCONPro.getTAG027();
        SCONPro.getTAG028();
        SCONPro.getTAG029();
        SCONPro.getTAG030();
        SCONPro.getTAG031();
        SCONPro.getTAG032();
        SCONPro.getTAG033();
        SCONPro.getTAG034();
        SCONPro.getTAG038();
        SCONPro.getTAG043();
        SCONPro.getTAG044();
        SCONPro.getTAG045();
        SCONPro.getTAG048();
        SCONPro.getTAG049();
        SCONPro.getTAG050();
        SCONPro.getTAG051();
        SCONPro.getTAG052();
        SCONPro.getTAG053();
        SCONPro.getTAG054();
        SCONPro.getTAG055();
        SCONPro.getTAG056();
        SCONPro.getTAG057();
        SCONPro.getTAG058();
        SCONPro.getTAG059();
        SCONPro.getTAG083();
        
        SVMXC__ServiceMax_Processes__c SCONBillingProcess = new SVMXC__ServiceMax_Processes__c();
        SCONBillingProcess.SVMXC__Name__c = 'SCONProcess000100';
        SCONBillingProcess.SVMXC__ProcessID__c = 'SCONProcess000100';
        SCONBillingProcess.SVMXC__Description__c = 'SCONProcess000100';
        SCONBillingProcess.SVMXC__Primary_Consolidation_Rule__c = 'One Per Contract';
        SCONBillingProcess.SVMXC__Secondary_Consolidation_Rule__c = '';
        SCONBillingProcess.SVMXC__Tertiary_Consolidation_Rule__c = '';
        SCONBillingProcess.SVMXC__Include_Product__c = true;
        SCONBillingProcess.SVMXC__Include_Parent__c = false;
        SCONBillingProcess.SVMXC__Email_On_Success__c = 'abc@abc.com';
        SCONBillingProcess.SVMXC__Email_On_Error__c = 'abc@abc.com';
        SCONBillingProcess.RecordTypeId = SCONBilProcess_Rtype.Id;
        //SCONBillingProcess.SVMXC__Module__c
        //SCONBillingProcess.SVMXC__Node_Parent__c
        //SCONBillingProcess.SVMXC__Process__c
        insert SCONBillingProcess;
        
        System.currentPageReference().getParameters().put('SVMX_Mode', 'Edit');
        System.currentPageReference().getParameters().put('SVMX_RecordId', SCONBillingProcess.Id);
        CONF_SetupSCONBillingProcess SCONPro1 = new CONF_SetupSCONBillingProcess();
        SCONPro1.quickSave();
        SCONPro1.saveClose();
        
        System.currentPageReference().getParameters().put('SVMX_Mode', 'Clone');
        CONF_SetupSCONBillingProcess SCONPro2 = new CONF_SetupSCONBillingProcess();
        
        SCONPro2.onChngExp();
        SCONPro2.EditExp();
        SCONPro2.HdrADDRowExp();
    }
    
    static testMethod void CONF_SetupSCONBillingProcess_UnitTest1()
    {
        System.currentPageReference().getParameters().put('SVMX_Mode', 'New');
        
        RecordType SCONBilProcess_Rtype = [select Id from RecordType where Name='Contract Billing Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpHdr_Rtype = [select Id from RecordType where Name='SVMX Rule'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpDtl_Rtype = [select Id from RecordType where Name='Expressions'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        RecordType ExpSrcUpdate_Rtype = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        RecordType Schedule_Rtype = [select Id from RecordType where Name='Schedule'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        
        CONF_SetupSCONBillingProcess SCONPro = new CONF_SetupSCONBillingProcess();
        SCONPro.processName = 'SCONProcess000101';
        SCONPro.processID = 'SCONProcess000101';
        SCONPro.processDesc = 'SCONProcess000101';
        SCONPro.selectedSCONFld1 = 'One Per Account';
        SCONPro.selectedSCONFld2 = 'SVMXC__Active__c';
        SCONPro.selectedSCONFld3 = 'Name';
        SCONPro.isEnableLogging = true;
        SCONPro.isIncludeNonBillableLines = false;
        
        SCONPro.SCONBillingProcess.SVMXC__Email_On_Error__c = 'abc@abc.com';
        SCONPro.SCONBillingProcess.SVMXC__Email_On_Success__c = 'abc@abc.com';
        
        SCONPro.NewExp();
        SCONPro.ExpSCON.namedExpression.SVMXC__Name__c = 'TestExp000100';
        SCONPro.ExpSCON.namedExpression.SVMXC__ProcessID__c = 'TestExp000100';
        
        SVMXC__ServiceMax_Config_Data__c confData = new SVMXC__ServiceMax_Config_Data__c();
        confData.RecordTypeId = ExpDtl_Rtype.Id;
        confData.SVMXC__Field_Name__c = 'SVMXC__Active__c';
        confData.SVMXC__Operator__c = 'eq';
        confData.SVMXC__Operand__c = 'true';
        SCONPro.ExpSCON.expressionDetails.add(confData);
        
        SVMXC__ServiceMax_Config_Data__c confData1 = new SVMXC__ServiceMax_Config_Data__c();
        confData1.SVMXC__Sequence__c = 1;
        confData1.SVMXC__Target_Field_Name__c = 'SVMXC__Active__c';
        confData1.SVMXC__Action__c = 'Set';
        confData1.SVMXC__Display_Value__c = 'true';
        SCONPro.lstSrcUpdates.add(confData1);
        
        SVMXC__ServiceMax_Config_Data__c confData2 = new SVMXC__ServiceMax_Config_Data__c();
        confData2.SVMXC__Sequence__c = 1;
        confData2.SVMXC__Run_At__c = '00:00 AM';
        confData2.SVMXC__Schedule_Days__c = 'Sunday';
        confData2.SVMXC__Run_Type__c='Day of Week';
        SCONPro.Chngruntype();
        SCONPro.lstSchedules.add(confData2);
        
        SCONPro.quickSave();
        
        SCONPro.SelectedRow = '1';
        SCONPro.lstSchedules_DelRow();
        
        SVMXC__ServiceMax_Config_Data__c confData3 = new SVMXC__ServiceMax_Config_Data__c();
        confData3.SVMXC__Sequence__c = 1;
        confData3.SVMXC__Target_Field_Name__c = 'SVMXC__Active__c';
        confData3.SVMXC__Action__c = 'Set';
        confData3.SVMXC__Display_Value__c = 'true';
        SCONPro.lstSrcUpdates.add(confData3);
        
        SCONPro.quickSave();
    }
}