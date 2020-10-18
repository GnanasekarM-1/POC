@isTest
private with sharing class CONF_ManageOutboundRouting_UT
{
    static testMethod void CONF_ManageOutboundRouting_UnitTest() 
    {
        RecordType outboundRule_Rtype = [select Id from RecordType where Name='Outbound Route Calculation'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType loc_Rtype = [select Id from RecordType where Name='Depot'and SobjectType='SVMXC__Site__c' Limit 1];
        RecordType ExpressionHeader_Rtype = [select Id from RecordType where Name='SVMX Rule'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpressionsDetail_Rtype = [select Id from RecordType where Name='Expressions'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        
        SVMXC__Site__c loc = new SVMXC__Site__c();
        loc.RecordTypeId = loc_Rtype.Id;
        loc.Name = 'Bangalore';
        insert loc;
        
        SVMXC__Site__c loc1 = new SVMXC__Site__c();
        loc1.RecordTypeId = loc_Rtype.Id; 
        loc1.Name = 'Mysore';
        insert loc1;
        
        SVMXC__ServiceMax_Processes__c expression1Process = new SVMXC__ServiceMax_Processes__c();
        expression1Process.RecordTypeId = ExpressionHeader_Rtype.Id;
        expression1Process.SVMXC__Name__c = 'TestExp00001';
        expression1Process.SVMXC__ProcessID__c = 'TestExp00001';
        expression1Process.SVMXC__Rule_Type__c = 'Named Expression';
        expression1Process.SVMXC__SettingId__c = 'TestExp00001';
        insert expression1Process;
        
        List<SVMXC__ServiceMax_Config_Data__c> lstConfData = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c confData1 = new SVMXC__ServiceMax_Config_Data__c();
        confData1.RecordTypeId = ExpressionsDetail_Rtype.Id;
        confData1.SVMXC__Sequence__c = 1;
        confData1.SVMXC__Field_Name__c = 'SVMXC__City__c';
        confData1.SVMXC__Operator__c = 'isnotnull';
        confData1.SVMXC__Expression_Rule__c = expression1Process.Id;
        confData1.SVMXC__Expression_Type__c = 'EXP_Named';
        lstConfData.add(confData1);
        
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = outboundRule_Rtype.Id;
        process.SVMXC__Name__c = 'Process00001';
        process.SVMXC__ProcessID__c = 'Process00001';
        process.SVMXC__Description__c = 'Process00001';
        process.SVMXC__Rule_Type__c ='Outbound Route Calculation';
        process.SVMXC__Active__c = true;
        process.SVMXC__IsStandard__c = false;
        process.SVMXC__Location__c = loc.Id;
        process.SVMXC__Node_Parent__c = expression1Process.Id;
        process.SVMXC__Advance_Expression__c = '1 AND 2';
        process.SVMXC__Select__c = true;
        insert process;
        
        SVMXC__ServiceMax_Config_Data__c confData2 = new SVMXC__ServiceMax_Config_Data__c();
        confData2.RecordTypeId = ExpressionsDetail_Rtype.Id;
        confData2.SVMXC__Sequence__c = 1;
        confData2.SVMXC__Object_Name__c = 'SVMXC__RMA_Shipment_Order__c';
        confData2.SVMXC__Field_Name__c = 'SVMXC__Service_Order__c';
        confData2.SVMXC__Operator__c = 'isnotnull';
        confData2.SVMXC__Expression_Rule__c = process.Id;
        confData2.SVMXC__Expression_Type__c = 'EXP_Named';
        lstConfData.add(confData2);
        
        SVMXC__ServiceMax_Config_Data__c confData3 = new SVMXC__ServiceMax_Config_Data__c();
        confData3.RecordTypeId = ExpressionsDetail_Rtype.Id;
        confData3.SVMXC__Sequence__c = 1;
        confData3.SVMXC__Object_Name__c = 'SVMXC__RMA_Shipment_Line__c';
        confData3.SVMXC__Field_Name__c = 'SVMXC__Case_Line__c';
        confData3.SVMXC__Operator__c = 'isnotnull';
        confData3.SVMXC__Expression_Rule__c = process.Id;
        confData3.SVMXC__Expression_Type__c = 'EXP_Named';
        lstConfData.add(confData3);
        
        insert lstConfData;
        
        CONF_ManageOutboundRouting outboundRule = new CONF_ManageOutboundRouting();
        outboundRule.newRule();
        outboundRule.cancel();
        //outboundRule.selectedDepot = process.Id;
        //outboundRule.onChngDepot();
        outboundRule.selectedCriteriaWOExp = expression1Process.Id;
        outboundRule.quickSave();
        outboundRule.onChngWOExp();
        outboundRule.EditCriteriaWOExp();
        //outboundRule.saveClose();
        
        outboundRule.editRule();
        outboundRule.deleteRule();
        outboundRule.HdrADDRowWOExp();
        outboundRule.HdrDeleteRowWOExp();
        outboundRule.ADDRowRuleDetailLst();
        outboundRule.DeleteRowRuleDetailLst();
        outboundRule.NewCriteriaWOExp();
        outboundRule.editRule();
        outboundRule.cancelToProcess();
        
        SVMXC__ServiceMax_Processes__c o = outboundRule.getoutboundProcess();
        outboundRule.setoutboundProcess(o);
        List<SVMXC__ServiceMax_Processes__c> c = outboundRule.getoutboundProcessLst();
        outboundRule.setoutboundProcessLst(c);
        //List<SelectOption> lst = outboundRule.getlstDepots();
        //outboundRule.setlstDepots(lst);
        List<SelectOption> lst = outboundRule.getlstHubs();
        outboundRule.setlstHubs(lst);
        lst = outboundRule.getOperatorSelectLst();
        lst = outboundRule.getWOfldlist();
        lst = outboundRule.getPOfldlist();
        lst = outboundRule.getlstCriteriaWOExp();
        outboundRule.setlstCriteriaWOExp(lst);
        Integer i = outboundRule.getWOExpDetailSize();
        SFM_WrapperDef.SFM_Expression Exp = outboundRule.getExp();
        outboundRule.setExp(Exp);
        Exp = outboundRule.getExpWO();
        outboundRule.setExpWO(Exp);
        String val = outboundRule.getsavedExpressionResultId();
        outboundRule.setsavedExpressionResultId(val);
        outboundRule.getObjPOName();
        outboundRule.getObjPOLineName();
        List<SVMXC__ServiceMax_Config_Data__c> cnf = outboundRule.getruleExpDetailLst();
        outboundRule.setruleExpDetailLst(cnf);
        lst = outboundRule.getPOLineFieldLst();
        lst = outboundRule.getObjectSelectLst();
        outboundRule.setObjectSelectLst(lst);
        i = outboundRule.getruleExpDetailLstSize();
        
        outboundRule.fillingConfigData(confData3);
        
        outboundRule.getTag001();
        outboundRule.getTag002();
        //outboundRule.getTag003();
        outboundRule.getTag004();
        outboundRule.getTag005();
        outboundRule.getTag006();
        outboundRule.getTag007();
        //outboundRule.getTag008();
        outboundRule.getTag009();
        outboundRule.getTag010();
        outboundRule.getTag011();
        outboundRule.getTag012();
        outboundRule.getTag013();
        outboundRule.getTag014();
        outboundRule.getTag015();
        outboundRule.getTag016();
        outboundRule.getTag017();
        outboundRule.getTag018();
        outboundRule.getTag019();
        outboundRule.getTag020();
        outboundRule.getTag021();
        outboundRule.getTag022();
        outboundRule.getTag023();
        outboundRule.getTag024();
        outboundRule.getTag025();
        outboundRule.getTag040();
        outboundRule.getTag041();
        outboundRule.getTag042();
        outboundRule.getTag043();
        outboundRule.getTag044();
        outboundRule.getTag046();
        outboundRule.getTAG047();
        outboundRule.getTAG045();
        outboundRule.getTag048();
        outboundRule.getTag049();
        outboundRule.getTag050();
        outboundRule.getTag051();
        outboundRule.getTag053();
        outboundRule.getTag054();
        outboundRule.getTag055();
        
        SVMXC__ServiceMax_Processes__c process1 = new SVMXC__ServiceMax_Processes__c();
        process1.RecordTypeId = outboundRule_Rtype.Id;
        process1.SVMXC__Name__c = 'Process00002';
        process1.SVMXC__ProcessID__c = 'Process00002';
        process1.SVMXC__Description__c = 'Process00002';
        process1.SVMXC__Rule_Type__c ='Outbound Route Calculation';
        process1.SVMXC__Active__c = true;
        process1.SVMXC__IsStandard__c = false;
        process1.SVMXC__Location__c = loc.Id;
        process1.SVMXC__Node_Parent__c = expression1Process.Id;
        process1.SVMXC__Advance_Expression__c = '1 AND 2';
        process1.SVMXC__Select__c = true;
        insert process1;
        
        SVMXC__ServiceMax_Processes__c process2 = new SVMXC__ServiceMax_Processes__c();
        process2.RecordTypeId = outboundRule_Rtype.Id;
        process2.SVMXC__Name__c = 'Process00003';
        process2.SVMXC__ProcessID__c = 'Process00003';
        process2.SVMXC__Description__c = 'Process00003';
        process2.SVMXC__Rule_Type__c ='Outbound Route Calculation';
        process2.SVMXC__Active__c = true;
        process2.SVMXC__IsStandard__c = false;
        process2.SVMXC__Location__c = loc.Id;
        process2.SVMXC__Node_Parent__c = expression1Process.Id;
        process2.SVMXC__Advance_Expression__c = '1 AND 2';
        process2.SVMXC__Select__c = true;
        insert process2;
        
        outboundRule.deleteRule();
    }
    static testMethod void CONF_ManageOutboundRouting_UnitTest1() 
    {
        RecordType outboundRule_Rtype = [select Id from RecordType where Name='Outbound Route Calculation'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType loc_Rtype = [select Id from RecordType where Name='Depot'and SobjectType='SVMXC__Site__c' Limit 1];
        
        SVMXC__Site__c loc = new SVMXC__Site__c();
        loc.RecordTypeId = loc_Rtype.Id;
        loc.Name = 'Bangalore';
        insert loc;
        
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = outboundRule_Rtype.Id;
        process.SVMXC__Name__c = 'Process00001';
        process.SVMXC__ProcessID__c = 'Process00001';
        process.SVMXC__Description__c = 'Process00001';
        process.SVMXC__Rule_Type__c ='Outbound Route Calculation';
        process.SVMXC__Advance_Expression__c = null;
        process.SVMXC__Active__c = true;
        process.SVMXC__IsStandard__c = false;
        process.SVMXC__Location__c = loc.Id;
        process.SVMXC__Select__c = true;
        insert process;
        
        System.currentPageReference().getParameters().put('SVMX_RecordId', loc.Id);
        System.currentPageReference().getParameters().put('SVMX_RetURL', '/apex/CONF_SetupHome');
        CONF_ManageOutboundRouting outboundRule = new CONF_ManageOutboundRouting();
        //outboundRule.saveClose();
        outboundRule.editRule();
        outboundRule.quickSave();
        outboundRule.cancel();
        System.currentPageReference().getParameters().put('SVMX_RetURL', '/apex/CONF_ManageOutboundRouting');
        outboundRule = new CONF_ManageOutboundRouting();
    }
}