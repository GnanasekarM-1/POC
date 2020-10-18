@isTest(SeeAllData=true)
Public class SFM_BizRuleUtils_UT
{
    static String SFMPrcId1 = '';
    static String RuleRecordTypeId = '';
    static String TargetManager = '';
    static String ProcessNodeObj = '';
    static String ProBizRuleRTypeId = '';
    static String ExpressionRTypeId = '';
    static List<SVMXC__ServiceMax_Config_Data__c> lstBizRuleExpr = new List<SVMXC__ServiceMax_Config_Data__c>();
    static SVMXC__ServiceMax_Processes__c BizRule1 = new SVMXC__ServiceMax_Processes__c();
    static SVMXC__ServiceMax_Config_Data__c BizRuleExpr11 = new SVMXC__ServiceMax_Config_Data__c();
    static SVMXC__ServiceMax_Config_Data__c BizRuleExpr12 = new SVMXC__ServiceMax_Config_Data__c();
    static SVMXC__ServiceMax_Processes__c BizRule2 = new SVMXC__ServiceMax_Processes__c();
    static SVMXC__ServiceMax_Config_Data__c BizRuleExpr21 = new SVMXC__ServiceMax_Config_Data__c();
    static SVMXC__ServiceMax_Config_Data__c BizRuleExpr22 = new SVMXC__ServiceMax_Config_Data__c();
    static List<SVMXC__ServiceMax_Processes__c> lstProBizRule = new List<SVMXC__ServiceMax_Processes__c>();
    
    static void createTestData()
    {
        for(RecordType RType : [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' OR SobjectType = 'SVMXC__ServiceMax_Config_Data__c'])
        {
            if(RType.Name == 'Business Rule')
                RuleRecordTypeId = RType.id;
            else if(RType.Name == 'Expressions')
                ExpressionRTypeId = RType.id;
            if(RType.Name == 'Target Manager')
                TargetManager = RType.id;
            else if(RType.Name == 'Process Node Objects')    
                ProcessNodeObj = RType.id;
            else if(RType.Name == 'Process Business Rule')
                ProBizRuleRTypeId = RType.id;
        }
        
        SVMXC__ServiceMax_Processes__c SFMPro1 = new SVMXC__ServiceMax_Processes__c();
        SFMPro1.RecordTypeId = TargetManager;
        SFMPro1.SVMXC__Name__c = 'process1';
        SFMPro1.SVMXC__Description__c = 'newprocess1';
        SFMPro1.SVMXC__ProcessID__c = 'process1';
        SFMPro1.SVMXC__IsStandard__c = true;
        insert SFMPro1;
        SFMPrcId1 = SFMPro1.Id;
        
        SVMXC__ServiceMax_Processes__c NodeObject1 = new SVMXC__ServiceMax_Processes__c();
        NodeObject1.SVMXC__ProcessID__c = 'process2';
        NodeObject1.SVMXC__Source_Object_Name__c = 'Case';
        NodeObject1.SVMXC__Type__c = 'TARGET';
        NodeObject1.SVMXC__Target_Object_label__c = 'Test Label - 1';
        NodeObject1.SVMXC__Process__c = SFMPro1.Id;
        NodeObject1.RecordTypeId =  ProcessNodeObj;
        upsert NodeObject1;
        
        SVMXC__ServiceMax_Processes__c NodeObject2 = new SVMXC__ServiceMax_Processes__c();
        NodeObject2.SVMXC__ProcessID__c = 'process3';
        NodeObject2.SVMXC__Source_Object_Name__c = 'Case';
        NodeObject2.SVMXC__Type__c = 'TARGETCHILD';
        NodeObject2.SVMXC__Target_Object_label__c = 'Test Label - 2';
        NodeObject2.SVMXC__Process__c = SFMPro1.Id;
        NodeObject2.RecordTypeId =  ProcessNodeObj;
        upsert NodeObject2;
        
        BizRule1.RecordTypeId = RuleRecordTypeId;
        BizRule1.SVMXC__Name__c = 'Test Biz Rule 001';
        BizRule1.SVMXC__ProcessID__c = 'My_Biz_Rule_001';
        BizRule1.SVMXC__Description__c = 'Test Biz Rule 001';
        BizRule1.SVMXC__Source_Object_Name__c = 'Case';
        BizRule1.SVMXC__Advance_Expression__c = '1 AND 2';
        BizRule1.SVMXC__Parent_Error_Msg__c = 'Case should be High Priority, should not be Low priority';
        BizRule1.SVMXC__Message_Type__c = 'Error';
        insert BizRule1;
        system.assert(BizRule1.SVMXC__ProcessID__c != NULL);
        system.assert(BizRule1.SVMXC__Source_Object_Name__c != NULL);
        
        BizRuleExpr11.RecordTypeId = ExpressionRTypeId;
        BizRuleExpr11.SVMXC__Expression_Rule__c = BizRule1.Id;
        BizRuleExpr11.SVMXC__Expression_Type__c = 'Business_Rule';
        BizRuleExpr11.SVMXC__Sequence__c = 1;
        BizRuleExpr11.SVMXC__Object_Name__c = 'Case';
        BizRuleExpr11.SVMXC__Field_Name__c = 'Priority';
        BizRuleExpr11.SVMXC__Operator__c = 'eq';
        BizRuleExpr11.SVMXC__Operand__c = 'High';
        BizRuleExpr11.SVMXC__Parameter_Type__c = 'FIELD VALUE';
        BizRuleExpr11.SVMXC__Object_Name2__c = 'Case';
        BizRuleExpr11.SVMXC__Display_Type__c = 'PICKLIST';
        BizRuleExpr11.SVMXC__Field_Relationship_Name__c = NULL;
        BizRuleExpr11.SVMXC__FKey_Name_Field__c = NULL;
        lstBizRuleExpr.add(BizRuleExpr11);
        
        BizRuleExpr12.RecordTypeId = ExpressionRTypeId;
        BizRuleExpr12.SVMXC__Expression_Rule__c = BizRule1.Id;
        BizRuleExpr12.SVMXC__Expression_Type__c = 'Business_Rule';
        BizRuleExpr12.SVMXC__Sequence__c = 2;
        BizRuleExpr12.SVMXC__Object_Name__c = 'Case';
        BizRuleExpr12.SVMXC__Field_Name__c = 'ParentId';
        BizRuleExpr12.SVMXC__Operator__c = 'ne';
        BizRuleExpr12.SVMXC__Parameter_Type__c = 'FIELD VALUE';
        BizRuleExpr12.SVMXC__Operand__c = NULL;
        BizRuleExpr12.SVMXC__Object_Name2__c = 'Case';
        BizRuleExpr12.SVMXC__Display_Type__c = 'REFERENCE';
        BizRuleExpr12.SVMXC__Field_Relationship_Name__c = NULL;
        BizRuleExpr12.SVMXC__FKey_Name_Field__c = NULL;
        lstBizRuleExpr.add(BizRuleExpr12);
        
        SVMXC__ServiceMax_Config_Data__c BizRuleExpr13 = new SVMXC__ServiceMax_Config_Data__c();
        BizRuleExpr13.RecordTypeId = ExpressionRTypeId;
        BizRuleExpr13.SVMXC__Expression_Rule__c = BizRule1.Id;
        BizRuleExpr13.SVMXC__Expression_Type__c = 'Business_Rule';
        BizRuleExpr13.SVMXC__Sequence__c = 3;
        BizRuleExpr13.SVMXC__Object_Name__c = 'Case';
        BizRuleExpr13.SVMXC__Field_Name__c = 'SVMXC__Is_PM_Case__c';
        BizRuleExpr13.SVMXC__Operator__c = 'eq';
        BizRuleExpr13.SVMXC__Operand__c = 'true';
        BizRuleExpr13.SVMXC__Object_Name2__c = 'Case';
        BizRuleExpr13.SVMXC__Display_Type__c = 'BOOLEAN';
        BizRuleExpr13.SVMXC__Field_Relationship_Name__c = NULL;
        BizRuleExpr13.SVMXC__Parameter_Type__c = 'FIELD VALUE';
        BizRuleExpr13.SVMXC__FKey_Name_Field__c = NULL;
        lstBizRuleExpr.add(BizRuleExpr13);
        
        SVMXC__ServiceMax_Config_Data__c BizRuleExpr14 = new SVMXC__ServiceMax_Config_Data__c();
        BizRuleExpr14.RecordTypeId = ExpressionRTypeId;
        BizRuleExpr14.SVMXC__Expression_Rule__c = BizRule1.Id;
        BizRuleExpr14.SVMXC__Expression_Type__c = 'Business_Rule';
        BizRuleExpr14.SVMXC__Sequence__c = 4;
        BizRuleExpr14.SVMXC__Object_Name__c = 'Case';
        BizRuleExpr14.SVMXC__Field_Name__c = 'SVMXC__Scheduled_Date__c';
        BizRuleExpr14.SVMXC__Operator__c = 'ne';
        BizRuleExpr14.SVMXC__Operand__c = NULL;
        BizRuleExpr14.SVMXC__Object_Name2__c = 'Case';
        BizRuleExpr14.SVMXC__Display_Type__c = 'DATE';
        BizRuleExpr14.SVMXC__Field_Relationship_Name__c = NULL;
        BizRuleExpr14.SVMXC__FKey_Name_Field__c = NULL;
        BizRuleExpr14.SVMXC__Parameter_Type__c = 'FIELD VALUE';
        lstBizRuleExpr.add(BizRuleExpr14);
        
        SVMXC__ServiceMax_Config_Data__c BizRuleExpr15 = new SVMXC__ServiceMax_Config_Data__c();
        BizRuleExpr15.RecordTypeId = ExpressionRTypeId;
        BizRuleExpr15.SVMXC__Expression_Rule__c = BizRule1.Id;
        BizRuleExpr15.SVMXC__Expression_Type__c = 'Business_Rule';
        BizRuleExpr15.SVMXC__Sequence__c = 5;
        BizRuleExpr15.SVMXC__Object_Name__c = 'Case';
        BizRuleExpr15.SVMXC__Field_Name__c = 'Subject';
        BizRuleExpr15.SVMXC__Operator__c = 'eq';
        BizRuleExpr15.SVMXC__Operand__c = 'Test Subject';
        BizRuleExpr15.SVMXC__Object_Name2__c = 'Case';
        BizRuleExpr15.SVMXC__Display_Type__c = 'STRING';
        BizRuleExpr15.SVMXC__Field_Relationship_Name__c = NULL;
        BizRuleExpr15.SVMXC__FKey_Name_Field__c = NULL;
        BizRuleExpr15.SVMXC__Parameter_Type__c = 'FIELD VALUE';
        lstBizRuleExpr.add(BizRuleExpr15);
        
        SVMXC__ServiceMax_Config_Data__c BizRuleExpr16 = new SVMXC__ServiceMax_Config_Data__c();
        BizRuleExpr16.RecordTypeId = ExpressionRTypeId;
        BizRuleExpr16.SVMXC__Expression_Rule__c = BizRule1.Id;
        BizRuleExpr16.SVMXC__Expression_Type__c = 'Business_Rule';
        BizRuleExpr16.SVMXC__Sequence__c = 6;
        BizRuleExpr16.SVMXC__Object_Name__c = 'Case';
        BizRuleExpr16.SVMXC__Field_Name__c = 'SuppliedEmail';
        BizRuleExpr16.SVMXC__Operator__c = 'eq';
        BizRuleExpr16.SVMXC__Operand__c = 'a@b.com';
        BizRuleExpr16.SVMXC__Object_Name2__c = 'Case';
        BizRuleExpr16.SVMXC__Display_Type__c = 'EMAIL';
        BizRuleExpr16.SVMXC__Field_Relationship_Name__c = NULL;
        BizRuleExpr16.SVMXC__FKey_Name_Field__c = NULL;
        BizRuleExpr16.SVMXC__Parameter_Type__c = 'FIELD VALUE';
        lstBizRuleExpr.add(BizRuleExpr16);
        
        SVMXC__ServiceMax_Config_Data__c BizRuleExpr17 = new SVMXC__ServiceMax_Config_Data__c();
        BizRuleExpr17.RecordTypeId = ExpressionRTypeId;
        BizRuleExpr17.SVMXC__Expression_Rule__c = BizRule1.Id;
        BizRuleExpr17.SVMXC__Expression_Type__c = 'Business_Rule';
        BizRuleExpr17.SVMXC__Sequence__c = 7;
        BizRuleExpr17.SVMXC__Object_Name__c = 'Case';
        BizRuleExpr17.SVMXC__Field_Name__c = 'SVMXC__Site__c';
        BizRuleExpr17.SVMXC__Operator__c = 'ne';
        BizRuleExpr17.SVMXC__Operand__c = NULL;
        BizRuleExpr17.SVMXC__Object_Name2__c = 'Case';
        BizRuleExpr17.SVMXC__Display_Type__c = 'REFERENCE';
        BizRuleExpr17.SVMXC__Field_Relationship_Name__c = NULL;
        BizRuleExpr17.SVMXC__FKey_Name_Field__c = NULL;
        BizRuleExpr17.SVMXC__Parameter_Type__c = 'FIELD VALUE';
        lstBizRuleExpr.add(BizRuleExpr17);
        
        SVMXC__ServiceMax_Config_Data__c BizRuleExpr18 = new SVMXC__ServiceMax_Config_Data__c();
        BizRuleExpr18.RecordTypeId = ExpressionRTypeId;
        BizRuleExpr18.SVMXC__Expression_Rule__c = BizRule1.Id;
        BizRuleExpr18.SVMXC__Expression_Type__c = 'Business_Rule';
        BizRuleExpr18.SVMXC__Sequence__c = 8;
        BizRuleExpr18.SVMXC__Object_Name__c = 'Case';
        BizRuleExpr18.SVMXC__Field_Name__c = 'SVMXC__Preferred_Start_Time__c';
        BizRuleExpr18.SVMXC__Operator__c = 'ne';
        BizRuleExpr18.SVMXC__Operand__c = NULL;
        BizRuleExpr18.SVMXC__Object_Name2__c = 'Case';
        BizRuleExpr18.SVMXC__Display_Type__c = 'DATETIME';
        BizRuleExpr18.SVMXC__Field_Relationship_Name__c = NULL;
        BizRuleExpr18.SVMXC__Parameter_Type__c = 'FIELD VALUE';
        BizRuleExpr18.SVMXC__FKey_Name_Field__c = NULL;
        BizRuleExpr18.SVMXC__Parameter_Type__c = 'FIELD VALUE';
        lstBizRuleExpr.add(BizRuleExpr18);

        SVMXC__ServiceMax_Config_Data__c BizRuleExpr19 = new SVMXC__ServiceMax_Config_Data__c();
        BizRuleExpr19.RecordTypeId = ExpressionRTypeId;
        BizRuleExpr19.SVMXC__Expression_Rule__c = BizRule1.Id;
        BizRuleExpr19.SVMXC__Expression_Type__c = 'Business_Rule';
        BizRuleExpr19.SVMXC__Sequence__c = 9;
        BizRuleExpr19.SVMXC__Object_Name__c = 'Case';
        BizRuleExpr19.SVMXC__Field_Name__c = 'SVMXC__BW_Slots_Before__c';
        BizRuleExpr19.SVMXC__Operator__c = 'eq';
        BizRuleExpr19.SVMXC__Operand__c = '10';
        BizRuleExpr19.SVMXC__Object_Name2__c = 'Case';
        BizRuleExpr19.SVMXC__Display_Type__c = 'DOUBLE';
        BizRuleExpr19.SVMXC__Field_Relationship_Name__c = NULL;
        BizRuleExpr19.SVMXC__FKey_Name_Field__c = NULL;
        BizRuleExpr19.SVMXC__Parameter_Type__c = 'FIELD VALUE';
        lstBizRuleExpr.add(BizRuleExpr19);
        
        BizRule2.RecordTypeId = RuleRecordTypeId;
        BizRule2.SVMXC__Name__c = 'Test Biz Rule 002';
        BizRule2.SVMXC__ProcessID__c = 'My_Test_Biz_Rule_002';
        BizRule2.SVMXC__Description__c = 'Test Biz Rule 002';
        BizRule2.SVMXC__Source_Object_Name__c = 'Case';
        BizRule2.SVMXC__Advance_Expression__c = '1 AND 2';
        BizRule2.SVMXC__Parent_Error_Msg__c = 'Case should be High Priority, should not be Low priority';
        BizRule2.SVMXC__Message_Type__c = 'Error';
        insert BizRule2;
        system.assert(BizRule2.SVMXC__ProcessID__c != NULL);
        system.assert(BizRule2.SVMXC__Source_Object_Name__c != NULL);
        
        BizRuleExpr21.RecordTypeId = ExpressionRTypeId;
        BizRuleExpr21.SVMXC__Expression_Rule__c = BizRule2.Id;
        BizRuleExpr21.SVMXC__Expression_Type__c = 'Business_Rule';
        BizRuleExpr21.SVMXC__Sequence__c = 1;
        BizRuleExpr21.SVMXC__Object_Name__c = 'Case';
        BizRuleExpr21.SVMXC__Field_Name__c = 'Priority';
        BizRuleExpr21.SVMXC__Operator__c = 'eq';
        BizRuleExpr21.SVMXC__Operand__c = 'High';
        BizRuleExpr21.SVMXC__Object_Name2__c = 'Case';
        BizRuleExpr21.SVMXC__Display_Type__c = 'String';
        BizRuleExpr21.SVMXC__Field_Relationship_Name__c = NULL;
        BizRuleExpr21.SVMXC__FKey_Name_Field__c = NULL;
        lstBizRuleExpr.add(BizRuleExpr21);
        
        BizRuleExpr22.RecordTypeId = ExpressionRTypeId;
        BizRuleExpr22.SVMXC__Expression_Rule__c = BizRule2.Id;
        BizRuleExpr22.SVMXC__Expression_Type__c = 'Business_Rule';
        BizRuleExpr22.SVMXC__Sequence__c = 2;
        BizRuleExpr22.SVMXC__Object_Name__c = 'Case';
        BizRuleExpr22.SVMXC__Field_Name__c = 'Priority';
        BizRuleExpr22.SVMXC__Operator__c = 'ne';
        BizRuleExpr22.SVMXC__Operand__c = 'Low';
        BizRuleExpr22.SVMXC__Object_Name2__c = 'Case';
        BizRuleExpr22.SVMXC__Display_Type__c = 'String';
        BizRuleExpr22.SVMXC__Field_Relationship_Name__c = NULL;
        BizRuleExpr22.SVMXC__FKey_Name_Field__c = NULL;
        lstBizRuleExpr.add(BizRuleExpr22);
        insert lstBizRuleExpr;
        system.assert(lstBizRuleExpr != NULL);
        
        //Process Biz Rule
        SVMXC__ServiceMax_Processes__c ProBizRule = new SVMXC__ServiceMax_Processes__c();
        ProBizRule.RecordTypeId = ProBizRuleRTypeId;
        ProBizRule.SVMXC__Process1__c = SFMPro1.Id;
        ProBizRule.SVMXC__Process2__c = NodeObject1.Id;
        ProBizRule.SVMXC__Process3__c = BizRule1.Id;
        lstProBizRule.add(ProBizRule);
        
        SVMXC__ServiceMax_Processes__c ProBizRule1 = new SVMXC__ServiceMax_Processes__c();
        ProBizRule1.RecordTypeId = ProBizRuleRTypeId;
        ProBizRule1.SVMXC__Process1__c = SFMPro1.Id;
        ProBizRule1.SVMXC__Process2__c = NodeObject2.Id;
        ProBizRule1.SVMXC__Process3__c = BizRule1.Id;
        lstProBizRule.add(ProBizRule1);
        
        SVMXC__ServiceMax_Processes__c ProBizRule2 = new SVMXC__ServiceMax_Processes__c();
        ProBizRule2.RecordTypeId = ProBizRuleRTypeId;
        ProBizRule2.SVMXC__Process1__c = SFMPro1.Id;
        ProBizRule2.SVMXC__Process2__c = NodeObject1.Id;
        ProBizRule2.SVMXC__Process3__c = BizRule1.Id;
        lstProBizRule.add(ProBizRule2);
        
        SVMXC__ServiceMax_Processes__c ProBizRule3 = new SVMXC__ServiceMax_Processes__c();
        ProBizRule3.RecordTypeId = ProBizRuleRTypeId;
        ProBizRule3.SVMXC__Process1__c = SFMPro1.Id;
        ProBizRule3.SVMXC__Process2__c = NodeObject2.Id;
        ProBizRule3.SVMXC__Process3__c = BizRule2.Id;
        lstProBizRule.add(ProBizRule3);
        
        insert lstProBizRule;
    }
    
    static testMethod void SFM_BizRuleUtils_Test1()
    {
        createTestData();
        SFM_BizRuleUtils objBizRuleUtils = new SFM_BizRuleUtils();
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
        request.stringListMap = new List<SVMXC.SFM_WrapperDef.SFM_StringListMap>();
        List<String> lstStr = new List<String>();
        request.stringListMap.add(new SVMXC.SFM_WrapperDef.SFM_StringListMap('OBJECTAPINAME', lstStr));
        objBizRuleUtils.SFM_GetBizRuleIds(request);
        lstStr = new List<String>{'Case'};
        request.stringListMap.add(new SVMXC.SFM_WrapperDef.SFM_StringListMap('OBJECTAPINAME', lstStr));
        objBizRuleUtils.SFM_GetBizRuleIds(request);
    }
        
    static testMethod void SFM_BizRuleUtils_Test2()
    {
        createTestData();
        SFM_BizRuleUtils objBizRuleUtils = new SFM_BizRuleUtils();
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
        request.stringListMap = new List<SVMXC.SFM_WrapperDef.SFM_StringListMap>();
        List<String> lstStr = new List<String>{BizRule1.Id, BizRule2.Id};
        request.stringListMap.add(new SVMXC.SFM_WrapperDef.SFM_StringListMap('BUSINESSRULEIDS', lstStr));
        objBizRuleUtils.SFM_GetBizRuleInfo(request);
    }
    
    static testMethod void SFM_BizRuleUtils_Test3()
    {
        createTestData();
        SFM_BizRuleUtils objBizRuleUtils = new SFM_BizRuleUtils();
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
        List<SVMXC__ServiceMax_Config_Data__c> BizRuleExprs = new List<SVMXC__ServiceMax_Config_Data__c>();
        BizRuleExprs.add(BizRuleExpr11);
        BizRuleExprs.add(BizRuleExpr12);
        request.bizRuleInfo = new SVMXC.SFM_WrapperDef.SFM_BizRuleInfo(BizRule1, BizRuleExprs);
        objBizRuleUtils.SFM_SaveBizRules(request);
    }
    
    static testMethod void SFM_BizRuleUtils_Test4()
    {
        createTestData();
        SFM_BizRuleUtils objBizRuleUtils = new SFM_BizRuleUtils();
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
        request.stringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        request.stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('RECORDID', BizRule1.Id));
        objBizRuleUtils.SFM_DeleteBizRules(request);
    }
    
    static testMethod void SFM_BizRuleUtils_Test5()
    {
        createTestData();
        SFM_BizRuleUtils objBizRuleUtils = new SFM_BizRuleUtils();
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
        request.stringListMap = new List<SVMXC.SFM_WrapperDef.SFM_StringListMap>();
        objBizRuleUtils.SFM_GetBizRulesForProcess('');
    }
    
    static testMethod void SFM_BizRuleUtils_Test6()
    {
        createTestData();
        SFM_BizRuleUtils objBizRuleUtils = new SFM_BizRuleUtils();
        objBizRuleUtils.bizRuleMetaInfo(SFMPrcId1);
    }
    
    static testMethod void SFM_BizRuleUtils_Test7()
    {
        createTestData();
        SFM_BizRuleUtils objBizRuleUtils = new SFM_BizRuleUtils();
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
        request.stringListMap = new List<SVMXC.SFM_WrapperDef.SFM_StringListMap>();
		request.stringListMap.add(new SVMXC.SFM_WrapperDef.SFM_StringListMap('OBJECTAPINAME', new List<String>{'Case'}));
		objBizRuleUtils.SFM_GetBizRuleProcesses(request);
    }
    
    static testMethod void SFM_BizRuleUtils_Test8()
    {
        createTestData();
        SFM_BizRuleUtils objBizRuleUtils = new SFM_BizRuleUtils();
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
        request.stringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        request.stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('RECORDID', BizRule1.Id));
        request.stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('PROCESSID', SFMPrcId1));
        objBizRuleUtils.SFM_DeleteBizRules(request);
    }
}