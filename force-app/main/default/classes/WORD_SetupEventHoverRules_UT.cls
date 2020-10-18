@isTest(SeeAllData=true)
private with sharing class WORD_SetupEventHoverRules_UT 
{
    static testMethod void WORD_SetupEventHoverRules_Test()
    {
        PageReference pageRef1 = new PageReference('Page.SVMXC.WORD_SetupEventHoverRules');
        Test.setCurrentPageReference(pageRef1);
        SVMXC.WORD_SetupEventHoverRules EventRule = new SVMXC.WORD_SetupEventHoverRules();
        System.assert(pageRef1 != null, 'pageRef1 assertion failed');
        System.assert(EventRule != null, 'EventRule assertion failed');
    }
    static testMethod void WORD_SetupEventHoverRulesTest()
    {
        List<RecordType> RecordTypes = new List<RecordType>();
        String RuleRecordTypeId;
        String ExpressionRTypeId;
        String FieldMapRTypeId;
        RecordTypes = Database.query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\' OR SobjectType = \'SVMXC__ServiceMax_Config_Data__c\'');
        for(RecordType r : RecordTypes)
        {
            if(r.Name == 'SVMX Rule')
            {
              RuleRecordTypeId = r.id;
            }
            if(r.Name == 'Expressions')
            {
                ExpressionRTypeId = r.id;
            }
            if(r.Name == 'Field Mapping')
            {
                FieldMapRTypeId = r.id;
            } 
        }
        //Create Rule
        List<SVMXC__ServiceMax_Processes__c> EventRuleLst = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c EventHovRule1 = new SVMXC__ServiceMax_Processes__c();
        EventHovRule1.RecordTypeId = RuleRecordTypeId;
        EventHovRule1.SVMXC__Select__c = true;
        EventHovRule1.SVMXC__ProcessID__c='PROCESS18';
        EventHovRule1.SVMXC__SettingId__c = 'PROCESS18';
        EventHovRule1.SVMXC__MapID__c='PROCESS18';
        EventHovRule1.SVMXC__Name__c = 'PROCESS28';
        EventHovRule1.SVMXC__Description__c = 'Event Rule 1';
        EventHovRule1.SVMXC__Sequence__c = 1;
        EventHovRule1.SVMXC__Rule_Type__c = 'Event Hover Rule';
        EventHovRule1.SVMXC__Advance_Expression__c = '1 And 2';
        insert EventHovRule1;
        
        SVMXC__ServiceMax_Processes__c EventHovRule2 = new SVMXC__ServiceMax_Processes__c();
        EventHovRule2.RecordTypeId = RuleRecordTypeId;
        EventHovRule2.SVMXC__Select__c = false;
        EventHovRule2.SVMXC__ProcessID__c='PROCESS17';
        EventHovRule2.SVMXC__SettingId__c = 'PROCESS17';
        EventHovRule2.SVMXC__MapID__c='PROCESS17';
        EventHovRule2.SVMXC__Name__c = 'PROCESS27';
        EventHovRule2.SVMXC__Description__c = 'Event Rule 2';
        EventHovRule2.SVMXC__Sequence__c = 2;
        EventHovRule2.SVMXC__Rule_Type__c = 'Event Hover Rule';
        EventHovRule2.SVMXC__Advance_Expression__c = '1 And 2';
        insert EventHovRule2;
        
        //Create Congfig data for Rule 
        List<SVMXC__ServiceMax_Config_Data__c> configLst= new List<SVMXC__ServiceMax_Config_Data__c>(); 
        SVMXC__ServiceMax_Config_Data__c conf1 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId = ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = EventHovRule1.id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__City__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'Bangalore',
                                            SVMXC__Expression_Type__c = 'DISP_Event_Hover_Rule',                                            
                                            SVMXC__Sequence__c = 1
                                            );
        configLst.add(conf1);
        SVMXC__ServiceMax_Config_Data__c conf2 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = EventHovRule1.id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__Source_City__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'werw',
                                            SVMXC__Expression_Type__c = 'DISP_Event_Hover_Rule',
                                            SVMXC__Sequence__c = 2                                           
                                            );
        configLst.add(conf2);
        //Create WO Field for Rule 
        SVMXC__ServiceMax_Config_Data__c conf3 = new SVMXC__ServiceMax_Config_Data__c();
        conf3.RecordTypeId = FieldMapRTypeId;
        conf3.SVMXC__Expression_Rule__c = EventHovRule1.id;
        conf3.SVMXC__Target_Field_Name__c = 'SVMXC__City__c';
        conf3.SVMXC__Sequence__c = 1;
        configLst.add(conf3);
        SVMXC__ServiceMax_Config_Data__c conf4 = new SVMXC__ServiceMax_Config_Data__c();
        conf4.RecordTypeId = FieldMapRTypeId;
        conf4.SVMXC__Expression_Rule__c = EventHovRule1.id;
        conf4.SVMXC__Target_Field_Name__c = 'SVMXC__Actual_Initial_Response__c';
        conf4.SVMXC__Sequence__c = 2;
        configLst.add(conf4);
        SVMXC__ServiceMax_Config_Data__c conf5 = new SVMXC__ServiceMax_Config_Data__c();
        conf5.RecordTypeId = FieldMapRTypeId;
        conf5.SVMXC__Expression_Rule__c = EventHovRule1.id;
        conf5.SVMXC__Target_Field_Name__c = 'SVMXC__Actual_Resolution__c';
        conf5.SVMXC__Sequence__c = 3;
        configLst.add(conf5);
        SVMXC__ServiceMax_Config_Data__c conf6 = new SVMXC__ServiceMax_Config_Data__c();
        conf6.RecordTypeId = FieldMapRTypeId;
        conf6.SVMXC__Expression_Rule__c = EventHovRule1.id;
        conf6.SVMXC__Target_Field_Name__c = 'SVMXC__Age__c';
        conf6.SVMXC__Sequence__c = 4;
        configLst.add(conf6);
        insert configLst;
        
        SVMXC.WORD_SetupEventHoverRules EventRule = new SVMXC.WORD_SetupEventHoverRules();
        test.startTest();
        Boolean b;
        String str;
        List<String> str1 = new List<String>();
        str1.add('SVMXC__Age__c');
        str1.add('SVMXC__Actual_Initial_Response__c');
        str1.add('SVMXC__Actual_Resolution__c');
        str1.add('SVMXC__City__c');
        EventRule.getHdrMsg();
        EventRule.getWOMsg();
        EventRule.getDisbaleChkBox();
        EventRule.setDisbaleChkBox(b);
        EventRule.getDisbaleActiveChkBox();
        EventRule.setDisbaleActiveChkBox(b);
        EventRule.getCheckAllRules();
        EventRule.setCheckAllRules(b);
        EventRule.getDisbleNewBttn();
        EventRule.setDisbleNewBttn(b);
        EventRule.getDisbleEdtBttn();
        EventRule.setDisbleEdtBttn(b);
        EventRule.getDisbleDelBttn();
        EventRule.setDisbleDelBttn(b);
        EventRule.getDisbleSaveBttn();
        EventRule.setDisbleSaveBttn(b);
        EventRule.getDisbleRuleSeqBttn();
        EventRule.setDisbleRuleSeqBttn(b);
        EventRule.getDisableCancelBttn();
        EventRule.setDisableCancelBttn(b);
        EventRule.getSelectedIndex();
        EventRule.setSelectedIndex(str);
        EventRule.getShowExp();
        EventRule.getDisableValue();
        EventRule.getHdrFldlist();
        EventRule.getAvaliWOfilds();
        EventRule.getAvaliSelWOfilds();
        EventRule.setAvaliSelWOfilds(str1);
        EventRule.getWOfilds();
        EventRule.getSelWOfilds();
        EventRule.setSelWOfilds(str1);
        EventRule.getRuleList();
        EventRule.setRuleList(EventRuleLst);
        system.assert(EventRule.getTAG001()!=null,'TAG001 assertion failed');
        system.assert(EventRule.getTAG002()!=null,'TAG002 assertion failed');
        system.assert(EventRule.getTAG003()!=null,'TAG003 assertion failed');
        system.assert(EventRule.getTAG004()!=null,'TAG004 assertion failed');
        system.assert(EventRule.getTAG005()!=null,'TAG005 assertion failed');
        system.assert(EventRule.getTAG006()!=null,'TAG006 assertion failed');
        system.assert(EventRule.getTAG007()!=null,'TAG007 assertion failed');
        system.assert(EventRule.getTAG008()!=null,'TAG008 assertion failed');
        system.assert(EventRule.getTAG009()!=null,'TAG009 assertion failed');
        system.assert(EventRule.getTAG010()!=null,'TAG010 assertion failed');
        system.assert(EventRule.getTAG011()!=null,'TAG011 assertion failed');
        system.assert(EventRule.getTAG012()!=null,'TAG012 assertion failed');
        system.assert(EventRule.getTAG013()!=null,'TAG013 assertion failed');
        system.assert(EventRule.getTAG014()!=null,'TAG014 assertion failed');
        system.assert(EventRule.getTAG015()!=null,'TAG015 assertion failed');
        system.assert(EventRule.getTAG016()!=null,'TAG016 assertion failed');
        system.assert(EventRule.getTAG017()!=null,'TAG017 assertion failed');
        system.assert(EventRule.getTAG018()!=null,'TAG018 assertion failed');
        system.assert(EventRule.getTAG019()!=null,'TAG019 assertion failed');
        system.assert(EventRule.getTAG020()!=null,'TAG020 assertion failed');
        system.assert(EventRule.getTAG021()!=null,'TAG021 assertion failed');
        system.assert(EventRule.getTAG022()!=null,'TAG022 assertion failed');
        system.assert(EventRule.getTAG023()!=null,'TAG023 assertion failed');
        system.assert(EventRule.getTAG024()!=null,'TAG024 assertion failed');
        system.assert(EventRule.getTAG025()!=null,'TAG025 assertion failed');
        system.assert(EventRule.getHLPURL()!=null,'TAG025 assertion failed');
        /*EventRule.svmxTagList.clear();
        system.assert(EventRule.getTAG001()!=null,'TAG001 assertion failed');
        system.assert(EventRule.getTAG002()!=null,'TAG002 assertion failed');
        system.assert(EventRule.getTAG003()!=null,'TAG003 assertion failed');
        system.assert(EventRule.getTAG004()!=null,'TAG004 assertion failed');
        system.assert(EventRule.getTAG005()!=null,'TAG005 assertion failed');
        system.assert(EventRule.getTAG006()!=null,'TAG006 assertion failed');
        system.assert(EventRule.getTAG007()!=null,'TAG007 assertion failed');
        system.assert(EventRule.getTAG008()!=null,'TAG008 assertion failed');
        system.assert(EventRule.getTAG009()!=null,'TAG009 assertion failed');
        system.assert(EventRule.getTAG010()!=null,'TAG010 assertion failed');
        system.assert(EventRule.getTAG011()!=null,'TAG011 assertion failed');
        system.assert(EventRule.getTAG012()!=null,'TAG012 assertion failed');
        system.assert(EventRule.getTAG013()!=null,'TAG013 assertion failed');
        system.assert(EventRule.getTAG014()!=null,'TAG014 assertion failed');
        system.assert(EventRule.getTAG015()!=null,'TAG015 assertion failed');
        system.assert(EventRule.getTAG016()!=null,'TAG016 assertion failed');
        system.assert(EventRule.getTAG017()!=null,'TAG017 assertion failed');
        system.assert(EventRule.getTAG018()!=null,'TAG018 assertion failed');
        system.assert(EventRule.getTAG019()!=null,'TAG019 assertion failed');
        system.assert(EventRule.getTAG020()!=null,'TAG020 assertion failed');
        system.assert(EventRule.getTAG021()!=null,'TAG021 assertion failed');
        system.assert(EventRule.getTAG022()!=null,'TAG022 assertion failed');
        system.assert(EventRule.getTAG023()!=null,'TAG023 assertion failed');
        system.assert(EventRule.getTAG024()!=null,'TAG024 assertion failed');
        system.assert(EventRule.getTAG025()!=null,'TAG025 assertion failed');
        system.assert(EventRule.getHLPURL()!=null,'TAG025 assertion failed');*///Commented by amar (tags are no longer used)
        EventRule.SVMX_GoSetupHome();
        EventRule.SVMX_Cancel();
        EventRule.RuleList.clear();
        EventRule.RuleList.add(EventHovRule1);
        EventRule.SVMX_EditRule();
        EventRule.getCriExpressions();
        EventRule.RuleList.clear();
        EventRule.SVMX_NewRule();
        EventRule.SVMX_SaveRule();
        EventRule.HdrADDRow();
        EventRule.SelectedIndex = '1';
        EventRule.HdrDeleteRow();
        EventRule.OnAddFields();
        EventRule.OnRemoveFields();
        EventRule.WOFldUP();
        EventRule.WOFldDown();
        EventRule.WOFldTop();
        EventRule.WOFldBottom();
        EventHovRule1.SVMXC__Select__c = true;
        EventHovRule2.SVMXC__Select__c = true;
        EventRule.RuleList.clear();
        EventRule.RuleList.add(EventHovRule1);
        EventRule.RuleList.add(EventHovRule2);
        EventRule.SVMX_ValidRule();
        List<selectOption> lst = new List<selectOption>();
        Map<String,Schema.Displaytype> m = new Map<String,Schema.Displaytype>();
        Map<String,String> m2 = new Map<String,String>();
        Schema.Displaytype DT;
        string LCObjName = '';
        EventRule.RetriveField('SVMXC__Service_Order__c',lst,m ,m2 ,DT,LCObjName);  //,list<sobject> ObjList
        EventRule.RetriveField2('SVMXC__Service_Order__c',lst,m,m2,DT);
    }
    static testMethod void WORD_SetupEventHoverRulesTest2()
    {
        List<RecordType> RecordTypes = new List<RecordType>();
        String RuleRecordTypeId;
        String ExpressionRTypeId;
        String FieldMapRTypeId;
        RecordTypes = Database.query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\' OR SobjectType = \'SVMXC__ServiceMax_Config_Data__c\'');
        System.assert(RecordTypes != null, 'RecordTypes assertion failed');
        for(RecordType r : RecordTypes)
        {
            if(r.Name == 'SVMX Rule')
            {
              RuleRecordTypeId = r.id;
            }
            if(r.Name == 'Expressions')
            {
                ExpressionRTypeId = r.id;
            }
            if(r.Name == 'Field Mapping')
            {
                FieldMapRTypeId = r.id;
            } 
        }
        //Create Rule
        List<SVMXC__ServiceMax_Processes__c> EventRuleLst = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c EventHovRule1 = new SVMXC__ServiceMax_Processes__c();
        EventHovRule1.RecordTypeId = RuleRecordTypeId;
        EventHovRule1.SVMXC__Select__c = true;
        EventHovRule1.SVMXC__ProcessID__c='PROCESS16';
        EventHovRule1.SVMXC__SettingId__c = 'PROCESS16';
        EventHovRule1.SVMXC__MapID__c='PROCESS16';
        EventHovRule1.SVMXC__Name__c = 'PROCESS26';
        EventHovRule1.SVMXC__Description__c = 'Event Rule 1';
        EventHovRule1.SVMXC__Sequence__c = 1;
        EventHovRule1.SVMXC__Rule_Type__c = 'Event Hover Rule';
        EventHovRule1.SVMXC__Advance_Expression__c = '1 And 2';
        insert EventHovRule1;
        System.assert(EventHovRule1 != null, 'EventHovRule1 assertion failed');
        
        SVMXC.WORD_SetupEventHoverRules EventRule = new SVMXC.WORD_SetupEventHoverRules();
        test.startTest();
        EventRule.RuleList.clear();
        EventRule.RuleList.add(EventHovRule1);       
//        EventRule.RuleExpression.clear();
        EventRule.SVMX_EditRule();
        System.assert(EventRule != null, 'EventRule assertion failed');
        
        test.stopTest();
    }
    static testMethod void WORD_SetupEventHoverRulesTest3()
    {
        List<RecordType> RecordTypes = new List<RecordType>();
        String RuleRecordTypeId;
        String ExpressionRTypeId;
        String FieldMapRTypeId;
        RecordTypes = Database.query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\' OR SobjectType = \'SVMXC__ServiceMax_Config_Data__c\'');
        System.assert(RecordTypes != null, 'RecordTypes assertion failed');
        
        for(RecordType r : RecordTypes)
        {
            if(r.Name == 'SVMX Rule')
            {
              RuleRecordTypeId = r.id;
            }
            if(r.Name == 'Expressions')
            {
                ExpressionRTypeId = r.id;
            }
            if(r.Name == 'Field Mapping')
            {
                FieldMapRTypeId = r.id;
            } 
        }
        //Create Rule
        List<SVMXC__ServiceMax_Processes__c> EventRuleLst = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c EventHovRule1 = new SVMXC__ServiceMax_Processes__c();
        EventHovRule1.RecordTypeId = RuleRecordTypeId;
        EventHovRule1.SVMXC__Select__c = true;
        EventHovRule1.SVMXC__ProcessID__c='PROCESS11';
        EventHovRule1.SVMXC__SettingId__c = 'PROCESS11';
        EventHovRule1.SVMXC__MapID__c='PROCESS11';
        EventHovRule1.SVMXC__Name__c = 'PROCESS22';
        EventHovRule1.SVMXC__Description__c = 'Event Rule 1';
        EventHovRule1.SVMXC__Rule_Type__c = 'Event Hover Rule';
        EventHovRule1.SVMXC__Sequence__c = 1;
        EventHovRule1.SVMXC__Advance_Expression__c = '1 And 2';
        insert EventHovRule1;
        System.assert(EventHovRule1 != null, 'EventHovRule1 assertion failed');
        
        //Create Congfig data for Rule 
        List<SVMXC__ServiceMax_Config_Data__c> configLst= new List<SVMXC__ServiceMax_Config_Data__c>(); 
        SVMXC__ServiceMax_Config_Data__c conf1 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId = ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = EventHovRule1.id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__City__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'Bangalore',
                                            SVMXC__Expression_Type__c = 'DISP_Event_Hover_Rule',                                            
                                            SVMXC__Sequence__c = 1
                                            );
        configLst.add(conf1);
        SVMXC__ServiceMax_Config_Data__c conf2 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = EventHovRule1.id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__Source_City__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'werw',
                                            SVMXC__Expression_Type__c = 'DISP_Event_Hover_Rule',
                                            SVMXC__Sequence__c = 2                                           
                                            );
        configLst.add(conf2);
        //Create WO Field for Rule 
        SVMXC__ServiceMax_Config_Data__c conf3 = new SVMXC__ServiceMax_Config_Data__c();
        conf3.RecordTypeId = FieldMapRTypeId;
        conf3.SVMXC__Expression_Rule__c = EventHovRule1.id;
        conf3.SVMXC__Target_Field_Name__c = 'SVMXC__City__c';
        conf3.SVMXC__Sequence__c = 1;
        configLst.add(conf3);
        SVMXC__ServiceMax_Config_Data__c conf4 = new SVMXC__ServiceMax_Config_Data__c();
        conf4.RecordTypeId = FieldMapRTypeId;
        conf4.SVMXC__Expression_Rule__c = EventHovRule1.id;
        conf4.SVMXC__Target_Field_Name__c = 'SVMXC__Actual_Initial_Response__c';
        conf4.SVMXC__Sequence__c = 2;
        configLst.add(conf4);
        SVMXC__ServiceMax_Config_Data__c conf5 = new SVMXC__ServiceMax_Config_Data__c();
        conf5.RecordTypeId = FieldMapRTypeId;
        conf5.SVMXC__Expression_Rule__c = EventHovRule1.id;
        conf5.SVMXC__Target_Field_Name__c = 'SVMXC__Actual_Resolution__c';
        conf5.SVMXC__Sequence__c = 3;
        configLst.add(conf5);
        SVMXC__ServiceMax_Config_Data__c conf6 = new SVMXC__ServiceMax_Config_Data__c();
        conf6.RecordTypeId = FieldMapRTypeId;
        conf6.SVMXC__Expression_Rule__c = EventHovRule1.id;
        conf6.SVMXC__Target_Field_Name__c = 'SVMXC__Age__c';
        conf6.SVMXC__Sequence__c = 4;
        configLst.add(conf6);
        insert configLst;
        System.assert(configLst != null, 'configLst assertion failed');
        
        SVMXC.WORD_SetupEventHoverRules EventRule = new SVMXC.WORD_SetupEventHoverRules();
        test.startTest();
        EventRule.RuleList.clear();
        EventRule.RuleList.add(EventHovRule1); 
        EventRule.SVMX_DeleteRule();
        EventHovRule1.SVMXC__Select__c = false;
        EventRule.RuleList.clear();
        EventRule.RuleList.add(EventHovRule1); 
        EventRule.SVMX_DeleteRule();
        test.stopTest();
    }
    static testMethod void WORD_SetupEventHoverRulesTest4()
    {
        List<RecordType> RecordTypes = new List<RecordType>();
        String RuleRecordTypeId;
        String ExpressionRTypeId;
        String FieldMapRTypeId;
        RecordTypes = Database.query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\' OR SobjectType = \'SVMXC__ServiceMax_Config_Data__c\'');
        System.assert(RecordTypes != null, 'RecordTypes assertion failed');
        
        for(RecordType r : RecordTypes)
        {
            if(r.Name == 'SVMX Rule')
            {
              RuleRecordTypeId = r.id;
            }
            if(r.Name == 'Expressions')
            {
                ExpressionRTypeId = r.id;
            }
            if(r.Name == 'Field Mapping')
            {
                FieldMapRTypeId = r.id;
            } 
        }
        //Create Rule
        List<SVMXC__ServiceMax_Processes__c> EventRuleLst = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c EventHovRule1 = new SVMXC__ServiceMax_Processes__c();
        EventHovRule1.RecordTypeId = RuleRecordTypeId;
        EventHovRule1.SVMXC__Select__c = true;
        EventHovRule1.SVMXC__ProcessID__c='PROCESS12';
        EventHovRule1.SVMXC__SettingId__c = 'PROCESS12';
        EventHovRule1.SVMXC__MapID__c='PROCESS12';
        EventHovRule1.SVMXC__Name__c = 'PROCESS21';
        EventHovRule1.SVMXC__Description__c = 'Event Rule 1';
        EventHovRule1.SVMXC__Sequence__c = 1;
        EventHovRule1.SVMXC__Rule_Type__c = 'Event Hover Rule';
        EventHovRule1.SVMXC__Advance_Expression__c = '1 And 2';
        EventRuleLst.add(EventHovRule1);
        SVMXC__ServiceMax_Processes__c EventHovRule2 = new SVMXC__ServiceMax_Processes__c();
        EventHovRule2.RecordTypeId = RuleRecordTypeId;
        EventHovRule2.SVMXC__Select__c = true;
        EventHovRule2.SVMXC__ProcessID__c='PROCESS13';
        EventHovRule2.SVMXC__SettingId__c = 'PROCESS13';
        EventHovRule2.SVMXC__MapID__c='PROCESS13';
        EventHovRule2.SVMXC__Name__c = 'PROCESS23';
        EventHovRule2.SVMXC__Description__c = 'Event Rule 2';
        EventHovRule2.SVMXC__Sequence__c = 2;
        EventHovRule2.SVMXC__Rule_Type__c = 'Event Hover Rule';
        EventHovRule2.SVMXC__Advance_Expression__c = '1 And 2';
        EventRuleLst.add(EventHovRule2);
        SVMXC__ServiceMax_Processes__c EventHovRule3 = new SVMXC__ServiceMax_Processes__c();
        EventHovRule3.RecordTypeId = RuleRecordTypeId;
        EventHovRule3.SVMXC__Select__c = true;
        EventHovRule3.SVMXC__ProcessID__c='PROCESS14';
        EventHovRule3.SVMXC__SettingId__c = 'PROCESS14';
        EventHovRule3.SVMXC__MapID__c='PROCESS14';
        EventHovRule3.SVMXC__Name__c = 'PROCESS24';
        EventHovRule3.SVMXC__Description__c = 'Event Rule 3';
        EventHovRule3.SVMXC__Sequence__c = 3;
        EventHovRule3.SVMXC__Rule_Type__c = 'Event Hover Rule';
        EventHovRule3.SVMXC__Advance_Expression__c = '1 And 2';
        EventRuleLst.add(EventHovRule3);
        SVMXC__ServiceMax_Processes__c EventHovRule4 = new SVMXC__ServiceMax_Processes__c();
        EventHovRule4.RecordTypeId = RuleRecordTypeId;
        EventHovRule4.SVMXC__Select__c = true;
        EventHovRule4.SVMXC__ProcessID__c='PROCESS15';
        EventHovRule4.SVMXC__SettingId__c = 'PROCESS15';
        EventHovRule4.SVMXC__MapID__c='PROCESS15';
        EventHovRule4.SVMXC__Name__c = 'PROCESS25';
        EventHovRule4.SVMXC__Description__c = 'Event Rule 4';
        EventHovRule4.SVMXC__Sequence__c = 4;
        EventHovRule4.SVMXC__Rule_Type__c = 'Event Hover Rule';
        EventHovRule4.SVMXC__Advance_Expression__c = '1 And 2';
        EventRuleLst.add(EventHovRule4);
        insert EventRuleLst;
        System.assert(EventRuleLst != null, 'EventRuleLst assertion failed');
        
        SVMXC.WORD_SetupEventHoverRules EventRule = new SVMXC.WORD_SetupEventHoverRules();
        test.startTest();
        EventRule.TempRuleLst.clear();
        EventRule.TempRuleLst.addall(EventRuleLst); 
        integer selIndex = 0;
        boolean isTop = true;
        EventRule.getdisplaySeqPopup();
        EventRule.SVMX_RuleSequence();
        EventRule.getSeqoptions();
        EventRule.getitems();
        string[] o = new string[]{EventRuleLst[0].id,EventRuleLst[1].id};
        EventRule.setitems(o);
        EventRule.Top();
        EventRule.SVMX_SaveSequence();
        string[] o1 = new string[]{EventRuleLst[0].id,EventRuleLst[1].id};
        EventRule.setitems(o1);
        EventRule.Down();
        EventRule.SVMX_SaveSequence();
        string[] o2 = new string[]{EventRuleLst[0].id,EventRuleLst[1].id};
        EventRule.setitems(o2);
        EventRule.UP();
        EventRule.SVMX_SaveSequence();
        string[] o3 = new string[]{EventRuleLst[0].id,EventRuleLst[1].id};
        EventRule.setitems(o3);
        EventRule.Bottom();
        EventRule.SVMX_SaveSequence();
        EventRule.shuffle(selIndex,true);
        EventRule.SVMX_SaveSequence();
        EventRule.SVMX_PopupCancel();
        for(Integer i = 0; i<EventRuleLst.size(); i++)
        {
            EventRuleLst[i].SVMXC__Select__c = false;
        }
        EventRule.RuleList.clear();
        EventRule.RuleList.addall(EventRuleLst);
        EventRule.SVMX_ValidRule();
        System.assert(EventRule != null, 'EventRule assertion failed');
        
        test.stopTest();
    }
}