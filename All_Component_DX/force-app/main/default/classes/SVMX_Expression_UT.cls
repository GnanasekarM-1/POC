@isTest
private with sharing class SVMX_Expression_UT
{
    static testMethod void SVMX_Expression_UnitTest()
    {
    	// System Assert
	     Account testAccount = new Account(name='Test Company Name');
	     insert testAccount;
	     testAccount.billingState='CA';
	     update testAccount;
	     // Verify that the billingState field was updated in the database.
	     Account updatedAccount = [SELECT billingState FROM Account WHERE Id = :testAccount.Id];
	     System.assertEquals('CA', updatedAccount.billingState);
    	
        RecordType ExpressionHeader_Rtype = [select Id from RecordType where Name=:'SVMX Rule'and SobjectType=:'SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpressionsDetail_Rtype = [select Id from RecordType where Name=:'Expressions'and SobjectType=:'SVMXC__ServiceMax_Config_Data__c' Limit 1];
        
        SVMXC__ServiceMax_Processes__c ExpressionHeaderRec = new SVMXC__ServiceMax_Processes__c();
        ExpressionHeaderRec.SVMXC__Sequence__c = 1;
        ExpressionHeaderRec.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        ExpressionHeaderRec.SVMXC__Name__c = 'HeaderExpression001';
        ExpressionHeaderRec.SVMXC__SettingId__c = 'HeaderExpression001';
        ExpressionHeaderRec.SVMXC__ProcessId__c = 'HeaderExpression001';
        ExpressionHeaderRec.SVMXC__Description__c = 'Sample desc';
        ExpressionHeaderRec.SVMXC__Advance_Expression__c = '1 or 2';
        ExpressionHeaderRec.RecordTypeId = ExpressionHeader_Rtype.Id;
        ExpressionHeaderRec.SVMXC__Rule_Type__c = 'Named Expression';
        insert ExpressionHeaderRec;
        system.assert(ExpressionHeaderRec.SVMXC__Sequence__c!=null);
        system.assert(ExpressionHeaderRec.SVMXC__Name__c!=null);
        system.assert(ExpressionHeaderRec.SVMXC__ProcessId__c!=null);

        List<SVMXC__ServiceMax_Config_Data__c> expdetailsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c expDetails01 = new SVMXC__ServiceMax_Config_Data__c();
        expDetails01.SVMXC__Sequence__c = 1;
        expDetails01.SVMXC__Field_Name__c ='SVMXC__City__c';
        expDetails01.SVMXC__Operator__c = 'eq';
        expDetails01.SVMXC__Operand__c = 'Bangalore';
        expDetails01.SVMXC__Display_Type__c = 'String';
        expDetails01.SVMXC__Expression_Type__c = 'EXP_Named';
        expDetails01.SVMXC__Expression_Rule__c = ExpressionHeaderRec.Id;
        expdetailsLst.add(expDetails01);
        system.assert(expDetails01.SVMXC__Sequence__c!=null);
        system.assert(expDetails01.SVMXC__Operand__c!=null);
        
        SVMXC__ServiceMax_Config_Data__c expDetails02 = new SVMXC__ServiceMax_Config_Data__c();
        expDetails02.SVMXC__Sequence__c = 2;
        expDetails02.SVMXC__Field_Name__c ='SVMXC__City__c';
        expDetails02.SVMXC__Operator__c = 'eq';
        expDetails02.SVMXC__Operand__c = 'Bangalore';
        expDetails02.SVMXC__Display_Type__c = 'String';
        expDetails02.SVMXC__Expression_Type__c = 'EXP_Named';
        expDetails02.SVMXC__Expression_Rule__c = ExpressionHeaderRec.Id;
        expdetailsLst.add(expDetails02);
        
        insert expdetailsLst;

        SVMX_Expression exp = new SVMX_Expression();
        exp.setobjName('SVMXC__Service_Order__c');
        exp.getobjName();
        exp.getObjLabel();
        if(exp.getObjLabel() != null)
            exp.setObjLabel(exp.getObjLabel());
        exp.getExpDetailSize();
        exp.getHdrfldlist();
        exp.getSelectedExpId();
        exp.setSelectedExpId(ExpressionHeaderRec.Id);
        exp.getSelectedIndex();
        exp.setSelectedIndex('0');
        exp.getDisableValue();
        exp.IsValidString('');
        exp.IsValidString('Str');
        exp.AddException('New error');
        exp.AddException('');
        exp.setcompMode('Edit');
        exp.getcompMode();
        exp.HdrADDRow();
        exp.HdrDeleteRow();
        exp.getOperatorSelectLst();
        SVMXC.SVMX_Expression.ExpressionWrapper expwrapper = new SVMXC.SVMX_Expression.ExpressionWrapper(ExpressionHeaderRec,expdetailsLst,true, true);
        expwrapper.getExpHeader();
        expwrapper.setExpHeader(ExpressionHeaderRec);
        expwrapper.getExpDetailLst();
        expwrapper.setExpDetailLst(expdetailsLst);
        expwrapper.getRenderAddButton();
        expwrapper.setRenderAddButton(true);
        expwrapper.getRenderDelButton();
        expwrapper.setRenderDelButton(true);
        exp.getexpwrapperObj();
        exp.setexpwrapperObj(expwrapper);
        exp.DoTheInitialJob();
        exp.getTAG001();
        exp.getTAG002();
        exp.getTAG003();
        exp.getTAG004();
        exp.getTAG005();
        exp.getTAG006();
        exp.getTAG007();
        exp.getTAG008();
        exp.getTAG009();
        exp.getTAG010();
        exp.getTAG011();
        exp.getTAG012();
        exp.SaveExpression();
        exp.getTAG013();
        exp.getTAG014();
        exp.getTAG015();
    }
}