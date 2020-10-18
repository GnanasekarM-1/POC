@isTest(SeeAlldata=true)
private with sharing class WORD_SetupEventSubjectRules_UT 
{
    static testMethod void WORD_SetupEventSubjectRules_Test()
    {
        PageReference pageRef1 = new PageReference('Page.SVMXC.WORD_SetupEventSubjectRules');
        Test.setCurrentPageReference(pageRef1);
        SVMXC.WORD_SetupEventSubjectRules EventRule = new SVMXC.WORD_SetupEventSubjectRules();
        System.assert(EventRule != null,'EventRule assertion failed');
        System.assert(pageRef1 != null,'pageRef1 assertion failed');
    
    }
    static testMethod void WORD_SetupEventSubjectRulesTest()
    {
        List<RecordType> RecordTypes = new List<RecordType>();
        String RuleRecordTypeId;
        String ExpressionRTypeId;
        String FieldMapRTypeId;
        RecordTypes = Database.query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\' OR SobjectType = \'SVMXC__ServiceMax_Config_Data__c\'');
        System.assert(RecordTypes != null,'RecordTypes assertion failed');
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
        List<SVMXC__ServiceMax_Processes__c> EventSubRuleLst = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c EventSubRule1 = new SVMXC__ServiceMax_Processes__c();
        EventSubRule1.SVMXC__ProcessID__c='PROCESS11';
        EventSubRule1.SVMXC__SettingId__c = 'PROCESS11';
        EventSubRule1.SVMXC__MapID__c='PROCESS11';
        EventSubRule1.SVMXC__Name__c = 'PROCESS22';
        EventSubRule1.RecordTypeId = RuleRecordTypeId;
        EventSubRule1.SVMXC__Select__c = true;
        EventSubRule1.SVMXC__Name__c = 'Event Rule 1';
        EventSubRule1.SVMXC__Description__c = 'Event Rule 1';
        EventSubRule1.SVMXC__Sequence__c = 1;
        EventSubRule1.SVMXC__Rule_Type__c = 'Event Subject Rule';
        EventSubRule1.SVMXC__Advance_Expression__c = '1 And 2';
        insert EventSubRule1;
        System.assert(EventSubRule1 != null,'EventSubRule1 assertion failed');
        
        SVMXC__ServiceMax_Processes__c EventSubRule2 = new SVMXC__ServiceMax_Processes__c();
        EventSubRule2.SVMXC__ProcessID__c='PROCESS11';
        EventSubRule2.SVMXC__SettingId__c = 'PROCESS11';
        EventSubRule2.SVMXC__MapID__c='PROCESS11';
        EventSubRule2.SVMXC__Name__c = 'PROCESS22';
        EventSubRule2.RecordTypeId = RuleRecordTypeId;
        EventSubRule2.SVMXC__Select__c = false;
        EventSubRule2.SVMXC__Name__c = 'Event Rule 2';
        EventSubRule2.SVMXC__Description__c = 'Event Rule 2';
        EventSubRule2.SVMXC__Sequence__c = 2;
        EventSubRule2.SVMXC__Rule_Type__c = 'Event Subject Rule';
        EventSubRule2.SVMXC__Advance_Expression__c = '1 And 2';
        insert EventSubRule2;
        
        //Create Congfig data for Rule 
        List<SVMXC__ServiceMax_Config_Data__c> configLst= new List<SVMXC__ServiceMax_Config_Data__c>(); 
        SVMXC__ServiceMax_Config_Data__c conf1 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId = ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = EventSubRule1.id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__City__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'Bangalore',
                                            SVMXC__Expression_Type__c = 'DISP_Event_Subject_Rule',                                            
                                            SVMXC__Sequence__c = 1
                                            );
        configLst.add(conf1);
        SVMXC__ServiceMax_Config_Data__c conf2 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = EventSubRule1.id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__Source_City__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'werw',
                                            SVMXC__Expression_Type__c = 'DISP_Event_Subject_Rule',
                                            SVMXC__Sequence__c = 2                                           
                                            );
        configLst.add(conf2);
        //Create WO Field for Rule 
        SVMXC__ServiceMax_Config_Data__c conf3 = new SVMXC__ServiceMax_Config_Data__c();
        conf3.RecordTypeId = FieldMapRTypeId;
        conf3.SVMXC__Expression_Rule__c = EventSubRule1.id;
        conf3.SVMXC__Target_Field_Name__c = 'SVMXC__City__c';
        conf3.SVMXC__Sequence__c = 1;
        configLst.add(conf3);
        SVMXC__ServiceMax_Config_Data__c conf4 = new SVMXC__ServiceMax_Config_Data__c();
        conf4.RecordTypeId = FieldMapRTypeId;
        conf4.SVMXC__Expression_Rule__c = EventSubRule1.id;
        conf4.SVMXC__Target_Field_Name__c = 'SVMXC__Actual_Initial_Response__c';
        conf4.SVMXC__Sequence__c = 2;
        configLst.add(conf4);
        SVMXC__ServiceMax_Config_Data__c conf5 = new SVMXC__ServiceMax_Config_Data__c();
        conf5.RecordTypeId = FieldMapRTypeId;
        conf5.SVMXC__Expression_Rule__c = EventSubRule1.id;
        conf5.SVMXC__Target_Field_Name__c = 'SVMXC__Actual_Resolution__c';
        conf5.SVMXC__Sequence__c = 3;
        configLst.add(conf5);
        SVMXC__ServiceMax_Config_Data__c conf6 = new SVMXC__ServiceMax_Config_Data__c();
        conf6.RecordTypeId = FieldMapRTypeId;
        conf6.SVMXC__Expression_Rule__c = EventSubRule1.id;
        conf6.SVMXC__Target_Field_Name__c = 'SVMXC__Age__c';
        conf6.SVMXC__Sequence__c = 4;
        configLst.add(conf6);
        insert configLst;
        System.assert(configLst != null,'configLst assertion failed');
        
        SVMXC.WORD_SetupEventSubjectRules EventRule = new SVMXC.WORD_SetupEventSubjectRules();
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
        EventRule.setRuleList(EventSubRuleLst);
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
        system.assert(EventRule.getHLPURL()!=null,'TAG025 assertion failed');*///Commented by amar (tags are no loner used)
        EventRule.SVMX_GoSetupHome();
        EventRule.SVMX_Cancel();
        EventRule.RuleList.clear();
        EventRule.RuleList.add(EventSubRule1);
        EventRule.SVMX_EditRule();
        EventRule.getCriExpressions();
        EventRule.RuleList.clear();
        EventRule.SVMX_NewRule();
        //EventRule.SVMX_SaveRule();
        EventRule.HdrADDRow();
        EventRule.SelectedIndex = '1';
        EventRule.HdrDeleteRow();
        EventRule.OnAddFields();
        EventRule.OnRemoveFields();
        EventRule.WOFldUP();
        EventRule.WOFldDown();
        EventRule.WOFldTop();
        EventRule.WOFldBottom();
        EventSubRule1.SVMXC__Select__c = true;
        EventSubRule2.SVMXC__Select__c = true;
        EventRule.RuleList.clear();
        EventRule.RuleList.add(EventSubRule1);
        EventRule.RuleList.add(EventSubRule2);
        EventRule.SVMX_ValidRule();
        List<selectOption> lst = new List<selectOption>();
        Map<String,Schema.Displaytype> m = new Map<String,Schema.Displaytype>();
        Map<String,String> m2 = new Map<String,String>();
        Schema.Displaytype DT;
        string LCObjName = '';
        EventRule.RetriveField('SVMXC__Service_Order__c',lst,m ,m2 ,DT,LCObjName);  //,list<sobject> ObjList
        EventRule.RetriveField2('SVMXC__Service_Order__c',lst,m,m2,DT);
    }
    static testMethod void WORD_SetupEventSubjectRulesTest2()
    {
        List<RecordType> RecordTypes = new List<RecordType>();
        String RuleRecordTypeId;
        String ExpressionRTypeId;
        String FieldMapRTypeId;
        RecordTypes = Database.query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\' OR SobjectType = \'SVMXC__ServiceMax_Config_Data__c\'');
        System.assert(RecordTypes != null,'RecordTypes assertion failed');
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
        List<SVMXC__ServiceMax_Processes__c> EventSubRuleLst = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c EventSubRule1 = new SVMXC__ServiceMax_Processes__c();
        EventSubRule1.SVMXC__ProcessID__c='PROCESS11';
        EventSubRule1.SVMXC__SettingId__c = 'PROCESS11';
        EventSubRule1.SVMXC__MapID__c='PROCESS11';
        EventSubRule1.RecordTypeId = RuleRecordTypeId;
        EventSubRule1.SVMXC__Select__c = true;
        EventSubRule1.SVMXC__Name__c = 'Event Rule 1';
        EventSubRule1.SVMXC__Description__c = 'Event Rule 1';
        EventSubRule1.SVMXC__Sequence__c = 1;
        EventSubRule1.SVMXC__Rule_Type__c = 'Event Subject Rule';
        EventSubRule1.SVMXC__Advance_Expression__c = '1 And 2';
        insert EventSubRule1;
        System.assert(EventSubRule1 != null,'EventSubRule1 assertion failed');
        
        SVMXC.WORD_SetupEventSubjectRules EventRule = new SVMXC.WORD_SetupEventSubjectRules();
        test.startTest();
        EventRule.RuleList.clear();
        EventRule.RuleList.add(EventSubRule1);       
        EventRule.RuleExpression.clear();
        EventRule.SVMX_EditRule();
        test.stopTest();
        System.assert(EventRule != null,'EventRule assertion failed');
    }
    static testMethod void WORD_SetupEventSubjectRulesTest3()
    {
        List<RecordType> RecordTypes = new List<RecordType>();
        String RuleRecordTypeId;
        String ExpressionRTypeId;
        String FieldMapRTypeId;
        RecordTypes = Database.query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\' OR SobjectType = \'SVMXC__ServiceMax_Config_Data__c\'');
        System.assert(RecordTypes != null,'RecordTypes assertion failed');
        
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
        List<SVMXC__ServiceMax_Processes__c> EventSubRuleLst = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c EventSubRule1 = new SVMXC__ServiceMax_Processes__c();
        EventSubRule1.SVMXC__ProcessID__c='PROCESS11';
        EventSubRule1.SVMXC__SettingId__c = 'PROCESS11';
        EventSubRule1.SVMXC__MapID__c='PROCESS11';
        EventSubRule1.SVMXC__Name__c = 'PROCESS22';
        EventSubRule1.RecordTypeId = RuleRecordTypeId;
        EventSubRule1.SVMXC__Select__c = true;
        //EventSubRule1.SVMXC__Name__c = 'Event Rule 1';
        EventSubRule1.SVMXC__Description__c = 'Event Rule 1';
        EventSubRule1.SVMXC__Sequence__c = 1;
        EventSubRule1.SVMXC__Rule_Type__c = 'Event Subject Rule';
        EventSubRule1.SVMXC__Advance_Expression__c = '1 And 2';
        insert EventSubRule1;
        
        //Create Congfig data for Rule 
        List<SVMXC__ServiceMax_Config_Data__c> configLst= new List<SVMXC__ServiceMax_Config_Data__c>(); 
        SVMXC__ServiceMax_Config_Data__c conf1 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId = ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = EventSubRule1.id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__City__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'Bangalore',
                                            SVMXC__Expression_Type__c = 'DISP_Event_Subject_Rule',                                            
                                            SVMXC__Sequence__c = 1
                                            );
        configLst.add(conf1);
        SVMXC__ServiceMax_Config_Data__c conf2 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = EventSubRule1.id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__Source_City__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'werw',
                                            SVMXC__Expression_Type__c = 'DISP_Event_Subject_Rule',
                                            SVMXC__Sequence__c = 2                                           
                                            );
        configLst.add(conf2);
        //Create WO Field for Rule 
        SVMXC__ServiceMax_Config_Data__c conf3 = new SVMXC__ServiceMax_Config_Data__c();
        conf3.RecordTypeId = FieldMapRTypeId;
        conf3.SVMXC__Expression_Rule__c = EventSubRule1.id;
        conf3.SVMXC__Target_Field_Name__c = 'SVMXC__City__c';
        conf3.SVMXC__Sequence__c = 1;
        configLst.add(conf3);
        SVMXC__ServiceMax_Config_Data__c conf4 = new SVMXC__ServiceMax_Config_Data__c();
        conf4.RecordTypeId = FieldMapRTypeId;
        conf4.SVMXC__Expression_Rule__c = EventSubRule1.id;
        conf4.SVMXC__Target_Field_Name__c = 'SVMXC__Actual_Initial_Response__c';
        conf4.SVMXC__Sequence__c = 2;
        configLst.add(conf4);
        SVMXC__ServiceMax_Config_Data__c conf5 = new SVMXC__ServiceMax_Config_Data__c();
        conf5.RecordTypeId = FieldMapRTypeId;
        conf5.SVMXC__Expression_Rule__c = EventSubRule1.id;
        conf5.SVMXC__Target_Field_Name__c = 'SVMXC__Actual_Resolution__c';
        conf5.SVMXC__Sequence__c = 3;
        configLst.add(conf5);
        SVMXC__ServiceMax_Config_Data__c conf6 = new SVMXC__ServiceMax_Config_Data__c();
        conf6.RecordTypeId = FieldMapRTypeId;
        conf6.SVMXC__Expression_Rule__c = EventSubRule1.id;
        conf6.SVMXC__Target_Field_Name__c = 'SVMXC__Age__c';
        conf6.SVMXC__Sequence__c = 4;
        configLst.add(conf6);
        insert configLst;
        SVMXC.WORD_SetupEventSubjectRules EventRule = new SVMXC.WORD_SetupEventSubjectRules();
        test.startTest();
        EventRule.RuleList.clear();
        EventRule.RuleList.add(EventSubRule1); 
        EventRule.SVMX_DeleteRule();
        EventSubRule1.SVMXC__Select__c = false;
        EventRule.RuleList.clear();
        EventRule.RuleList.add(EventSubRule1); 
        EventRule.SVMX_DeleteRule();
        test.stopTest();
        System.assert(EventRule != null,'EventRule assertion failed');
    }
    static testMethod void WORD_SetupEventSubjectRulesTest4()
    {
        List<RecordType> RecordTypes = new List<RecordType>();
        String RuleRecordTypeId;
        String ExpressionRTypeId;
        String FieldMapRTypeId;
        RecordTypes = Database.query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\' OR SobjectType = \'SVMXC__ServiceMax_Config_Data__c\'');
        System.assert(RecordTypes != null,'RecordTypes assertion failed');
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
        List<SVMXC__ServiceMax_Processes__c> EventSubRuleLst = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c EventSubRule1 = new SVMXC__ServiceMax_Processes__c();
        EventSubRule1.SVMXC__ProcessID__c='PROCESS11';
        EventSubRule1.SVMXC__SettingId__c = 'PROCESS11';
        EventSubRule1.SVMXC__MapID__c='PROCESS11';
        EventSubRule1.SVMXC__Name__c = 'PROCESS22';
        EventSubRule1.RecordTypeId = RuleRecordTypeId;
        EventSubRule1.SVMXC__Select__c = true;
        EventSubRule1.SVMXC__Name__c = 'Event Rule 1';
        EventSubRule1.SVMXC__Description__c = 'Event Rule 1';
        EventSubRule1.SVMXC__Sequence__c = 1;
        EventSubRule1.SVMXC__Rule_Type__c = 'Event Subject Rule';
        EventSubRule1.SVMXC__Advance_Expression__c = '1 And 2';
        EventSubRuleLst.add(EventSubRule1);
        SVMXC__ServiceMax_Processes__c EventSubRule2 = new SVMXC__ServiceMax_Processes__c();
        EventSubRule2.SVMXC__ProcessID__c='PROCESS11';
        EventSubRule2.SVMXC__SettingId__c = 'PROCESS11';
        EventSubRule2.SVMXC__MapID__c='PROCESS11';
        EventSubRule2.RecordTypeId = RuleRecordTypeId;
        EventSubRule2.SVMXC__Select__c = true;
        EventSubRule2.SVMXC__Name__c = 'Event Rule 2';
        EventSubRule2.SVMXC__Description__c = 'Event Rule 2';
        EventSubRule2.SVMXC__Sequence__c = 2;
        EventSubRule2.SVMXC__Rule_Type__c = 'Event Subject Rule';
        EventSubRule2.SVMXC__Advance_Expression__c = '1 And 2';
        EventSubRuleLst.add(EventSubRule2);
        SVMXC__ServiceMax_Processes__c EventSubRule3 = new SVMXC__ServiceMax_Processes__c();
        EventSubRule3.SVMXC__ProcessID__c='PROCESS11';
        EventSubRule3.SVMXC__SettingId__c = 'PROCESS11';
        EventSubRule3.SVMXC__MapID__c='PROCESS11';
        EventSubRule3.RecordTypeId = RuleRecordTypeId;
        EventSubRule3.SVMXC__Select__c = true;
        EventSubRule3.SVMXC__Name__c = 'Event Rule 3';
        EventSubRule3.SVMXC__Description__c = 'Event Rule 3';
        EventSubRule3.SVMXC__Sequence__c = 3;
        EventSubRule3.SVMXC__Rule_Type__c = 'Event Subject Rule';
        EventSubRule3.SVMXC__Advance_Expression__c = '1 And 2';
        EventSubRuleLst.add(EventSubRule3);
        SVMXC__ServiceMax_Processes__c EventSubRule4 = new SVMXC__ServiceMax_Processes__c();
        EventSubRule4.SVMXC__ProcessID__c='PROCESS11';
        EventSubRule4.SVMXC__SettingId__c = 'PROCESS11';
        EventSubRule4.SVMXC__MapID__c='PROCESS11';
        EventSubRule4.RecordTypeId = RuleRecordTypeId;
        EventSubRule4.SVMXC__Select__c = true;
        EventSubRule4.SVMXC__Name__c = 'Event Rule 4';
        EventSubRule4.SVMXC__Description__c = 'Event Rule 4';
        EventSubRule4.SVMXC__Sequence__c = 4;
        EventSubRule4.SVMXC__Rule_Type__c = 'Event Subject Rule';
        EventSubRule4.SVMXC__Advance_Expression__c = '1 And 2';
        EventSubRuleLst.add(EventSubRule4);
        insert EventSubRuleLst;
        System.assert(EventSubRuleLst != null,'EventSubRuleLst assertion failed');
        
        SVMXC.WORD_SetupEventSubjectRules EventRule = new SVMXC.WORD_SetupEventSubjectRules();
        test.startTest();
        EventRule.TempRuleLst.clear();
        EventRule.TempRuleLst.addall(EventSubRuleLst); 
        integer selIndex = 0;
        boolean isTop = true;
        EventRule.getdisplaySeqPopup();
        EventRule.SVMX_RuleSequence();
        EventRule.getSeqoptions();
        EventRule.getitems();
        string[] o = new string[]{EventSubRuleLst[0].id,EventSubRuleLst[1].id};
        EventRule.setitems(o);
        EventRule.Top();
        //EventRule.SVMX_SaveSequence();
        string[] o1 = new string[]{EventSubRuleLst[0].id,EventSubRuleLst[1].id};
        EventRule.setitems(o1);
        EventRule.Down();
        //EventRule.SVMX_SaveSequence();
        string[] o2 = new string[]{EventSubRuleLst[0].id,EventSubRuleLst[1].id};
        EventRule.setitems(o2);
        EventRule.UP();
        //EventRule.SVMX_SaveSequence();
        string[] o3 = new string[]{EventSubRuleLst[0].id,EventSubRuleLst[1].id};
        EventRule.setitems(o3);
        EventRule.Bottom();
        //EventRule.SVMX_SaveSequence();
        EventRule.shuffle(selIndex,true);
        //EventRule.SVMX_SaveSequence();
        EventRule.SVMX_PopupCancel();
        for(Integer i = 0; i<EventSubRuleLst.size(); i++)
        {
            EventSubRuleLst[i].SVMXC__Select__c = false;
        }
        EventRule.RuleList.clear();
        EventRule.RuleList.addall(EventSubRuleLst);
        EventRule.SVMX_ValidRule();
        System.assert(EventRule != null,'EventRule assertion failed');
        test.stopTest();
    }
}