@isTest
private class CONF_ManageTranslations_UT
{
    static testMethod void CONF_ManageTranslations_Test1()
    {
        //SFM Search data
        String ProcessRTypeId = [select Id from RecordType where Name = 'Named Search' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1].Id; 
        SVMXC__ServiceMax_Processes__c Search_Process_1 = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ProcessRTypeId, SVMXC__Select__c = true, SVMXC__Active__c = true, SVMXC__Name__C = 'Test Search Process', SVMXC__ProcessID__c = 'Search_Process_1', SVMXC__Description__c = 'Test Search 001', SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH');
        insert Search_Process_1;
        System.assertEquals(true,Search_Process_1.Id != null);
        
        SVMXC__ServiceMax_Processes__c Search_Process_11 = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ProcessRTypeId, SVMXC__Select__c = true, SVMXC__Target_Object_Name__c = 'Account', SVMXC__Name__C = 'Account Search', SVMXC__Description__c = 'Account Search', SVMXC__Module__c = Search_Process_1.Id,SVMXC__Rule_Type__c = 'SRCH_OBJECT',SVMXC__Sequence__c = 1);
        insert Search_Process_11;
        System.assertEquals(true,Search_Process_11.Id != null);
        
        SVMXC__ServiceMax_Processes__c Search_Process_21 = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ProcessRTypeId, SVMXC__Select__c = true, SVMXC__Target_Object_Name__c = 'Case', SVMXC__Name__C = 'Case Search', SVMXC__Description__c = 'Case Search', SVMXC__Module__c = Search_Process_1.Id, SVMXC__Rule_Type__c = 'SRCH_OBJECT', SVMXC__Sequence__c = 2);
        insert Search_Process_21;
        System.assertEquals(true,Search_Process_21.Id != null);
        
        //SFM Wizard data
        String SFMWizardRecTypeId = [Select Id from RecordType where Name = 'Wizard' and SObjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1].Id;
        SVMXC__ServiceMax_Processes__c ServiceFlowWizardRec = new SVMXC__ServiceMax_Processes__c();
        ServiceFlowWizardRec.SVMXC__Select__c = false;
        ServiceFlowWizardRec.SVMXC__ProcessID__c = 'MyServiceFlowWizard0001';
        ServiceFlowWizardRec.SVMXC__Name__c = 'Test MyServiceFlowWizard0001';
        ServiceFlowWizardRec.SVMXC__Description__c = 'Sample Description';
        ServiceFlowWizardRec.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        ServiceFlowWizardRec.SVMXC__IsStandard__c = false;
        ServiceFlowWizardRec.RecordTypeId = SFMWizardRecTypeId;
        insert ServiceFlowWizardRec;
        
        String SFMWizardStepRTId = [Select Id from RecordType where Name = 'Wizard step' and SObjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1].Id;
        List<SVMXC__ServiceMax_Processes__c> lstServiceFlowWizardAction = new List<SVMXC__ServiceMax_Processes__c> ();
        SVMXC__ServiceMax_Processes__c ServiceFlowWizardAction = new SVMXC__ServiceMax_Processes__c();
        ServiceFlowWizardAction.SVMXC__Select__c = false;
        ServiceFlowWizardAction.SVMXC__Sequence__c = 1 ;
        ServiceFlowWizardAction.SVMXC__Module__c = ServiceFlowWizardRec.Id;
        ServiceFlowWizardAction.SVMXC__Name__c = 'ServiceFlowWizardAction001';
        ServiceFlowWizardAction.SVMXC__ProcessID__c = 'ServiceFlowWizardAction001';
        ServiceFlowWizardAction.SVMXC__Description__c = 'Sample Description';
        ServiceFlowWizardAction.SVMXC__Action_Type__c = 'OTHERS';
        ServiceFlowWizardAction.SVMXC__Action_URL__c = 'New url';
        ServiceFlowWizardAction.SVMXC__Confirmation_Message__C = 'Are you sure';
        ServiceFlowWizardAction.SVMXC__IsStandard__c = false;
        ServiceFlowWizardAction.RecordTypeId = SFMWizardStepRTId;
        lstServiceFlowWizardAction.add(ServiceFlowWizardAction);
        
        SVMXC__ServiceMax_Processes__c ServiceFlowWizardAction1 = new SVMXC__ServiceMax_Processes__c();
        ServiceFlowWizardAction1.SVMXC__Select__c = false;
        ServiceFlowWizardAction1.SVMXC__Sequence__c = 1 ;
        ServiceFlowWizardAction1.SVMXC__Module__c = ServiceFlowWizardRec.Id;
        ServiceFlowWizardAction1.SVMXC__Confirmation_Message__C = 'Are you sure';
        ServiceFlowWizardAction1.SVMXC__Name__c = 'ServiceFlowWizardAction1001';
        ServiceFlowWizardAction1.SVMXC__ProcessID__c = 'ServiceFlowWizardAction002';
        ServiceFlowWizardAction1.SVMXC__Description__c = 'Sample Description';
        ServiceFlowWizardAction1.SVMXC__Action_Type__c = 'SFM';
        ServiceFlowWizardAction1.SVMXC__Action_URL__c = 'New url';
        ServiceFlowWizardAction1.SVMXC__IsStandard__c = false;
        ServiceFlowWizardAction1.RecordTypeId = SFMWizardStepRTId;
        lstServiceFlowWizardAction.add(ServiceFlowWizardAction1);
        insert lstServiceFlowWizardAction;
        
        //SFM Transactions
        String BizRuleRecordTypeId = '';
        String TargetManagerRTypeId = '';
        String ProcessNodeObjRTypeId = '';
        String ProBizRuleRTypeId = '';
        String ExpressionRTypeId = '';
        String LinkedProcessRTypeId = '';
        String INVTRecType = '';
        SVMXC__ServiceMax_Processes__c SFMProc1 = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c sourceNodeObj = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c sourceChildNodeObj = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c targetNodeObj = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c targetChildNodeObj = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Config_Data__c SourceUpdate1 = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Config_Data__c SourceUpdate2 = new SVMXC__ServiceMax_Config_Data__c();    
        List<SVMXC__ServiceMax_Config_Data__c> processSourceUpdates = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> lstBizRuleExpr = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Processes__c BizRule1 = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Config_Data__c BizRuleExpr11 = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Config_Data__c BizRuleExpr12 = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Processes__c BizRule2 = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Config_Data__c BizRuleExpr21 = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Config_Data__c BizRuleExpr22 = new SVMXC__ServiceMax_Config_Data__c();
        List<SVMXC__ServiceMax_Processes__c> lstProBizRule = new List<SVMXC__ServiceMax_Processes__c>();
    
        for(RecordType RType : [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' OR SobjectType = 'SVMXC__ServiceMax_Config_Data__c'])
        {
            if(RType.Name == 'Business Rule')
                BizRuleRecordTypeId = RType.id;
            else if(RType.Name == 'Expressions')
                ExpressionRTypeId = RType.id;
            if(RType.Name == 'Target Manager')
                TargetManagerRTypeId = RType.id;
            else if(RType.Name == 'Process Node Objects')    
                ProcessNodeObjRTypeId = RType.id;
            else if(RType.Name == 'Process Business Rule')
                ProBizRuleRTypeId = RType.id;
            else if(RType.Name == 'Linked Process')
                LinkedProcessRTypeId = RType.id;
            else if(RType.Name == 'Inventory Process')
                INVTRecType = RType.id;
        }
        
        SFMProc1.RecordTypeId = TargetManagerRTypeId;
        SFMProc1.SVMXC__ProcessID__c = 'Test_SFM_PROCESS01';
        SFMProc1.SVMXC__Name__c = 'Test SFM_PROCESS01';
        SFMProc1.SVMXC__Description__c = 'Test_SFM_PROCESS01';
        SFMProc1.SVMXC__IsStandard__c = false;
        insert SFMProc1;
        
        sourceNodeObj.RecordTypeId = ProcessNodeObjRTypeId; 
        sourceNodeObj.SVMXC__ProcessID__c = 'PROCESS12';
        sourceNodeObj.SVMXC__SettingId__c = 'PROCESS12';
        sourceNodeObj.SVMXC__MapID__c = 'PROCESS12';
        sourceNodeObj.SVMXC__Name__c = 'PROCESS22';
        sourceNodeObj.SVMXC__Source_Object_Name__c = 'Case';
        sourceNodeObj.SVMXC__Node_Source_Object_API__c = 'Case';
        sourceNodeObj.SVMXC__Type__c = 'SOURCE';
        sourceNodeObj.SVMXC__Process__c = SFMProc1.Id;
        upsert sourceNodeObj;
    
        sourceChildNodeObj.RecordTypeId = ProcessNodeObjRTypeId;
        sourceChildNodeObj.SVMXC__ProcessID__c = 'PROCESS13';
        sourceChildNodeObj.SVMXC__Name__c = 'PROCESS23';
        sourceChildNodeObj.SVMXC__Source_Object_Name__c = 'Case';
        sourceChildNodeObj.SVMXC__Node_Source_Object_API__c = 'Case';
        sourceChildNodeObj.SVMXC__Type__c = 'SOURCECHILD';
        sourceChildNodeObj.SVMXC__Process__c = SFMProc1.Id;
        upsert sourceChildNodeObj;
        
        targetNodeObj.RecordTypeId = ProcessNodeObjRTypeId;
        targetNodeObj.SVMXC__ProcessID__c ='PROCESS14';
        targetNodeObj.SVMXC__SettingId__c = 'PROCESS14';
        targetNodeObj.SVMXC__MapID__c='PROCESS14';
        targetNodeObj.SVMXC__Target_Object_label__c = 'targetNodeObj';
        targetNodeObj.SVMXC__Name__c = 'PROCESS24';
        targetNodeObj.SVMXC__Source_Object_Name__c = 'Case';
        targetNodeObj.SVMXC__Node_Source_Object_API__c = 'Case';
        targetNodeObj.SVMXC__Type__c = 'TARGET';
        targetNodeObj.SVMXC__Process__c = SFMProc1.Id;
        upsert targetNodeObj;
            
        targetChildNodeObj.RecordTypeId = ProcessNodeObjRTypeId;
        targetChildNodeObj.SVMXC__ProcessID__c='PROCESS15';
        targetChildNodeObj.SVMXC__SettingId__c = 'PROCESS15';
        targetChildNodeObj.SVMXC__MapID__c='PROCESS15';
        targetChildNodeObj.SVMXC__Target_Object_label__c = 'targetChildNodeObj';
        targetChildNodeObj.SVMXC__Name__c = 'PROCESS25';
        targetChildNodeObj.SVMXC__Source_Object_Name__c = 'Case';
        targetChildNodeObj.SVMXC__Node_Source_Object_API__c = 'Case';
        targetChildNodeObj.SVMXC__Type__c = 'TARGETCHILD';
        targetChildNodeObj.SVMXC__Process__c = SFMProc1.Id;
        upsert targetChildNodeObj;
        
        BizRule1.RecordTypeId = BizRuleRecordTypeId;
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
        insert lstBizRuleExpr;
        system.assert(lstBizRuleExpr != NULL);
        
        List<SVMXC__ServiceMax_Processes__c> lstTargetProBizRule = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Processes__c> lstTargetChildProBizRule = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c ProBizRule = new SVMXC__ServiceMax_Processes__c();
        ProBizRule.RecordTypeId = ProBizRuleRTypeId;
        ProBizRule.SVMXC__Process1__c = SFMProc1.Id;
        ProBizRule.SVMXC__Process2__c = targetNodeObj.Id;
        ProBizRule.SVMXC__Process3__c = BizRule1.Id;
        lstTargetProBizRule.add(ProBizRule);
        
        SVMXC__ServiceMax_Processes__c ProBizRule1 = new SVMXC__ServiceMax_Processes__c();
        ProBizRule1.RecordTypeId = ProBizRuleRTypeId;
        ProBizRule1.SVMXC__Process1__c = SFMProc1.Id;
        ProBizRule1.SVMXC__Process2__c = targetChildNodeObj.Id;
        ProBizRule1.SVMXC__Process3__c = BizRule1.Id;
        lstTargetChildProBizRule.add(ProBizRule1);
        
        SVMXC__ServiceMax_Processes__c ProBizRule2 = new SVMXC__ServiceMax_Processes__c();
        ProBizRule2.RecordTypeId = ProBizRuleRTypeId;
        ProBizRule2.SVMXC__Process1__c = SFMProc1.Id;
        ProBizRule2.SVMXC__Process2__c = targetNodeObj.Id;
        ProBizRule2.SVMXC__Process3__c = BizRule2.Id;
        lstTargetProBizRule.add(ProBizRule2);
        
        SVMXC__ServiceMax_Processes__c ProBizRule3 = new SVMXC__ServiceMax_Processes__c();
        ProBizRule3.RecordTypeId = ProBizRuleRTypeId;
        ProBizRule3.SVMXC__Process1__c = SFMProc1.Id;
        ProBizRule3.SVMXC__Process2__c = targetChildNodeObj.Id;
        ProBizRule3.SVMXC__Process3__c = BizRule2.Id;
        lstTargetChildProBizRule.add(ProBizRule3);
        insert lstTargetProBizRule;
        insert lstTargetChildProBizRule;
        
        List<SVMXC__ServiceMax_Processes__c> linkedProcesses = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c linkedProcess = new SVMXC__ServiceMax_Processes__c();
        linkedProcess.RecordTypeId = LinkedProcessRTypeId;
        linkedProcess.SVMXC__Process1__c = SFMProc1.id;
        linkedProcess.SVMXC__Process2__c = targetChildNodeObj.id;
        linkedProcess.SVMXC__Process3__c = SFMProc1.id;
        linkedProcess.SVMXC__Name__c = 'Linked SFM';
        linkedProcesses.add(linkedProcess);
        insert linkedProcesses;
        
        
        List<SVMXC__ServiceMax_Processes__c> lstINVTProcess = new List<SVMXC__ServiceMax_Processes__c>();
        lstINVTProcess.add(new SVMXC__ServiceMax_Processes__c (SVMXC__ProcessID__c = 'Test_INVT_Process', SVMXC__Name__c = 'Test INVT Process', SVMXC__Description__c = 'Test INVT Process',  SVMXC__Parent_Error_Msg__c = 'Error message for header', SVMXC__Child_Error_Msg__c = 'Error message for details', RecordTypeId = INVTRecType));
        insert lstINVTProcess;
        
        SVMXC.CONF_ManageTranslations.TagWrapper TagWrapObj = new SVMXC.CONF_ManageTranslations.TagWrapper('', '', new SVMXC__ServiceMax_Tags__c(), new SVMXC__ServiceMax_Tags__c());
        SVMXC.CONF_ManageTranslations.TranslationWrapper TranslationWrapObj = new SVMXC.CONF_ManageTranslations.TranslationWrapper(new Set<String>(), new  List<SVMXC__ServiceMax_Processes__c>());
        SVMXC.CONF_ManageTranslations TranslnObj = new SVMXC.CONF_ManageTranslations();
        TranslnObj.selectedProType = 'All';
        TranslnObj.selectedProcess ='Search_Process_1';
        TranslnObj.selectedLanguage = 'Master';
        TranslnObj.UpdateKeysBeforeConstructor();
        TranslnObj.getlstTagsWrapper();
        
        try
        {
            TranslnObj.setstrSearchKeyword('Test');
            TranslnObj.performSearch();
            TranslnObj.selectedProcess ='Search_Process_1';
            TranslnObj.onChngProcess();
            TranslnObj.onChngProcessType();
            
            TranslnObj.selectedProcess = 'All';
            TranslnObj.selectedProType = 'All';
            TranslnObj.onChngProcess();
            TranslnObj.onChngProcessType();
            TranslnObj.performSearch();
            TranslnObj.selectedProType = 'SFM';
            TranslnObj.onChngProcess();
            TranslnObj.onChngProcessType();
            TranslnObj.performSearch();
            TranslnObj.selectedProType = 'SFW';
            TranslnObj.onChngProcess();
            TranslnObj.onChngProcessType();
            TranslnObj.performSearch();
            TranslnObj.selectedProType = 'SFM_Search';
            TranslnObj.onChngProcess();
            TranslnObj.onChngProcessType();
            TranslnObj.performSearch();
            TranslnObj.selectedProType = 'Inventory_Process';
            TranslnObj.onChngProcess();
            TranslnObj.onChngProcessType();
            TranslnObj.performSearch();
            TranslnObj.onChngLanguage();
            TranslnObj.copyMaster();
            TranslnObj.getstrSearchKeyword();
            TranslnObj.getlstSOProcessType();
            TranslnObj.getlstSOLanguage();
            TranslnObj.getlstSOProcesses();
            
        }catch(exception ex){}
        TranslnObj.saveTranslations();
        TranslnObj.POPUP_YES();
        TranslnObj.copyMasterTranslation();
        TranslnObj.POPUP_NO();
        TranslnObj.copyMasterTranslation();
        TranslnObj.POPUP_CANCEL();
        TranslnObj.resetText();
        TranslnObj.BackToSetupHome();
        TranslnObj.sortingSelectOption(new List<SelectOption> ());
        TranslnObj.getHLPTITLE();
        TranslnObj.getHLPURL();
        TranslnObj.getTAG001();
        TranslnObj.getTAG002();
        TranslnObj.getTAG003();
        TranslnObj.getTAG004();
        TranslnObj.getTAG005();
        TranslnObj.getTAG006();
        TranslnObj.getTAG007();
        TranslnObj.getTAG008();
        TranslnObj.getTAG009();
        TranslnObj.getTAG010();
        TranslnObj.getTAG011();
        TranslnObj.getTAG012();
        TranslnObj.getTAG013();
        TranslnObj.getTAG014();
        TranslnObj.getTAG015();
        TranslnObj.getTAG016();
        TranslnObj.getTAG017();
        TranslnObj.getTAG018();
        TranslnObj.getTAG019();
        TranslnObj.getTAG020();
        TranslnObj.getTAG021();
        TranslnObj.getTAG022();
        TranslnObj.getTAG023();
        TranslnObj.getTAG024();
        TranslnObj.getTAG025();
        TranslnObj.getTAG026();
        TranslnObj.getTAG029();
        TranslnObj.getTAG030();
        TranslnObj.getTAG031();
        TranslnObj.getTAG032();
        TranslnObj.getTAG033();
        TranslnObj.getTAG034();
        TranslnObj.getTAG035();
        TranslnObj.getTAG036();
        TranslnObj.getTAG037();
        TranslnObj.getTAG038();
        TranslnObj.getTAG039();
        TranslnObj.getTAG040();
        TranslnObj.getTAG041();
        TranslnObj.getTAG042();
        TranslnObj.getTAG043();
        TranslnObj.getTAG044();
        TranslnObj.getTAG045();
        TranslnObj.getTAG046();
        TranslnObj.getTAG047();
        TranslnObj.getTAG048();
        TranslnObj.getTAG049();
        
        TranslnObj.setlstTagsWrapper(new List<SVMXC.CONF_ManageTranslations.TagWrapper>());
        CONF_ManageTranslations obj = new CONF_ManageTranslations();
        obj.generateMasterTag(SFMProc1.id);
        CONF_ManageTranslations obj1 = new CONF_ManageTranslations();
        obj1.generateMasterTag(ServiceFlowWizardRec.id);
        CONF_ManageTranslations obj2 = new CONF_ManageTranslations();
        obj2.generateMasterTag(Search_Process_1.id);
        CONF_ManageTranslations obj6 = new CONF_ManageTranslations();
        obj6.generateMasterTag(lstINVTProcess[0].id);
        
         SVMXC__ServiceMax_Tags__c tag = new SVMXC__ServiceMax_Tags__c();
        tag.SVMXC__Tag_Key__c = 'TEST_MYSERVICEFLOWWIZARD0002';
        tag.SVMXC__Language__c ='Master';
        tag.SVMXC__Tag_Value__c = 'Test MyServiceFlowWizard0001';
        tag.SVMXC__Tag_Context__c = 'WIZARD_NAME';
        tag.Name ='Test MyServiceFlowWizard0001';
        insert tag;
        SVMXC__ServiceMax_Tags__c tag1 = new SVMXC__ServiceMax_Tags__c();
        tag1.SVMXC__Tag_Key__c = 'TEST_SFM_PROCESS02';
        tag1.SVMXC__Language__c ='Master';
        tag1.SVMXC__Tag_Value__c = 'Test SFM_PROCESS01';
        tag1.SVMXC__Tag_Context__c = 'WIZARD_NAME';
        tag1.Name ='Test SFM_PROCESS01';
        insert tag1;
        CONF_ManageTranslations.TagWrapper confManage = new CONF_ManageTranslations.TagWrapper('TEST_SFM_PROCESS01','en',tag1,tag);
        obj6.lstTagsWrapper.add(confManage);
        obj6.copyMasterTranslation();
        obj6.saveTranslations();
        
        
    }
    
    static testMethod void CONF_ManageTranslations_Test2()
    {
        //SFM Search data
        String ProcessRTypeId = [select Id from RecordType where Name = 'Named Search' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1].Id; 
        SVMXC__ServiceMax_Processes__c Search_Process_1 = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ProcessRTypeId, SVMXC__Select__c = true, SVMXC__Active__c = true, SVMXC__Name__C = 'Test Search Process', SVMXC__ProcessID__c = 'Search_Process_1', SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH');
        insert Search_Process_1;
        System.assertEquals(true,Search_Process_1.Id != null);
        
        SVMXC__ServiceMax_Processes__c Search_Process_11 = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ProcessRTypeId, SVMXC__Select__c = true, SVMXC__Target_Object_Name__c = 'Account', SVMXC__Name__C = 'Account Search',SVMXC__Description__c = 'Account Search', SVMXC__Module__c = Search_Process_1.Id,SVMXC__Rule_Type__c = 'SRCH_OBJECT',SVMXC__Sequence__c = 1);
        insert Search_Process_11;
        System.assertEquals(true,Search_Process_11.Id != null);
        
        SVMXC__ServiceMax_Processes__c Search_Process_21 = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ProcessRTypeId, SVMXC__Select__c = true, SVMXC__Target_Object_Name__c = 'Case', SVMXC__Name__C = 'Case Search', SVMXC__Description__c = 'Case Search', SVMXC__Module__c = Search_Process_1.Id, SVMXC__Rule_Type__c = 'SRCH_OBJECT', SVMXC__Sequence__c = 2);
        insert Search_Process_21;
        System.assertEquals(true,Search_Process_21.Id != null);
        
        //SFM Wizard data
        String SFMWizardRecTypeId = [Select Id from RecordType where Name = 'Wizard' and SObjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1].Id;
        SVMXC__ServiceMax_Processes__c ServiceFlowWizardRec = new SVMXC__ServiceMax_Processes__c();
        ServiceFlowWizardRec.SVMXC__Select__c = false;
        ServiceFlowWizardRec.SVMXC__ProcessID__c = 'MyServiceFlowWizard0001';
        ServiceFlowWizardRec.SVMXC__Name__c = 'Test MyServiceFlowWizard0001';
        ServiceFlowWizardRec.SVMXC__Description__c = 'Sample Description';
        ServiceFlowWizardRec.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        ServiceFlowWizardRec.SVMXC__IsStandard__c = false;
        ServiceFlowWizardRec.RecordTypeId = SFMWizardRecTypeId;
        insert ServiceFlowWizardRec;
        
        String SFMWizardStepRTId = [Select Id from RecordType where Name = 'Wizard step' and SObjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1].Id;
        List<SVMXC__ServiceMax_Processes__c> lstServiceFlowWizardAction = new List<SVMXC__ServiceMax_Processes__c> ();
        SVMXC__ServiceMax_Processes__c ServiceFlowWizardAction = new SVMXC__ServiceMax_Processes__c();
        ServiceFlowWizardAction.SVMXC__Select__c = false;
        ServiceFlowWizardAction.SVMXC__Sequence__c = 1 ;
        ServiceFlowWizardAction.SVMXC__Module__c = ServiceFlowWizardRec.Id;
        ServiceFlowWizardAction.SVMXC__Name__c = 'ServiceFlowWizardAction001';
        ServiceFlowWizardAction.SVMXC__ProcessID__c = 'ServiceFlowWizardAction001';
        ServiceFlowWizardAction.SVMXC__Description__c = 'Sample Description';
        ServiceFlowWizardAction.SVMXC__Action_Type__c = 'OTHERS';
        ServiceFlowWizardAction.SVMXC__Action_URL__c = 'New url';
        ServiceFlowWizardAction.SVMXC__IsStandard__c = false;
        ServiceFlowWizardAction.RecordTypeId = SFMWizardStepRTId;
        lstServiceFlowWizardAction.add(ServiceFlowWizardAction);
        
        SVMXC__ServiceMax_Processes__c ServiceFlowWizardAction1 = new SVMXC__ServiceMax_Processes__c();
        ServiceFlowWizardAction1.SVMXC__Select__c = false;
        ServiceFlowWizardAction1.SVMXC__Sequence__c = 1 ;
        ServiceFlowWizardAction1.SVMXC__Module__c = ServiceFlowWizardRec.Id;
        ServiceFlowWizardAction1.SVMXC__Name__c = 'ServiceFlowWizardAction1001';
        ServiceFlowWizardAction1.SVMXC__ProcessID__c = 'ServiceFlowWizardAction002';
        ServiceFlowWizardAction1.SVMXC__Description__c = 'Sample Description';
        ServiceFlowWizardAction1.SVMXC__Action_Type__c = 'SFM';
        ServiceFlowWizardAction1.SVMXC__Action_URL__c = 'New url';
        ServiceFlowWizardAction1.SVMXC__IsStandard__c = false;
        ServiceFlowWizardAction1.RecordTypeId = SFMWizardStepRTId;
        lstServiceFlowWizardAction.add(ServiceFlowWizardAction1);
        insert lstServiceFlowWizardAction;
        
        //SFM Transactions
        String BizRuleRecordTypeId = '';
        String TargetManagerRTypeId = '';
        String ProcessNodeObjRTypeId = '';
        String ProBizRuleRTypeId = '';
        String ExpressionRTypeId = '';
        String LinkedProcessRTypeId = '';
        SVMXC__ServiceMax_Processes__c SFMProc1 = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c sourceNodeObj = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c sourceChildNodeObj = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c targetNodeObj = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c targetChildNodeObj = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Config_Data__c SourceUpdate1 = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Config_Data__c SourceUpdate2 = new SVMXC__ServiceMax_Config_Data__c();    
        List<SVMXC__ServiceMax_Config_Data__c> processSourceUpdates = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> lstBizRuleExpr = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Processes__c BizRule1 = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Config_Data__c BizRuleExpr11 = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Config_Data__c BizRuleExpr12 = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Processes__c BizRule2 = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Config_Data__c BizRuleExpr21 = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Config_Data__c BizRuleExpr22 = new SVMXC__ServiceMax_Config_Data__c();
        List<SVMXC__ServiceMax_Processes__c> lstProBizRule = new List<SVMXC__ServiceMax_Processes__c>();
    
        for(RecordType RType : [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' OR SobjectType = 'SVMXC__ServiceMax_Config_Data__c'])
        {
            if(RType.Name == 'Business Rule')
                BizRuleRecordTypeId = RType.id;
            else if(RType.Name == 'Expressions')
                ExpressionRTypeId = RType.id;
            if(RType.Name == 'Target Manager')
                TargetManagerRTypeId = RType.id;
            else if(RType.Name == 'Process Node Objects')    
                ProcessNodeObjRTypeId = RType.id;
            else if(RType.Name == 'Process Business Rule')
                ProBizRuleRTypeId = RType.id;
            else if(RType.Name == 'Linked Process')
                LinkedProcessRTypeId = RType.id;
        }
        
        SFMProc1.RecordTypeId = TargetManagerRTypeId;
        SFMProc1.SVMXC__ProcessID__c = 'Test_SFM_PROCESS01';
        SFMProc1.SVMXC__Name__c = 'Test SFM_PROCESS01';
        SFMProc1.SVMXC__Description__c = 'Test_SFM_PROCESS01';
        SFMProc1.SVMXC__IsStandard__c = false;
        insert SFMProc1;
        
        sourceNodeObj.RecordTypeId = ProcessNodeObjRTypeId; 
        sourceNodeObj.SVMXC__ProcessID__c = 'PROCESS12';
        sourceNodeObj.SVMXC__SettingId__c = 'PROCESS12';
        sourceNodeObj.SVMXC__MapID__c = 'PROCESS12';
        sourceNodeObj.SVMXC__Name__c = 'PROCESS22';
        sourceNodeObj.SVMXC__Source_Object_Name__c = 'Case';
        sourceNodeObj.SVMXC__Node_Source_Object_API__c = 'Case';
        sourceNodeObj.SVMXC__Type__c = 'SOURCE';
        sourceNodeObj.SVMXC__Process__c = SFMProc1.Id;
        upsert sourceNodeObj;
    
        sourceChildNodeObj.RecordTypeId = ProcessNodeObjRTypeId;
        sourceChildNodeObj.SVMXC__ProcessID__c = 'PROCESS13';
        sourceChildNodeObj.SVMXC__Name__c = 'PROCESS23';
        sourceChildNodeObj.SVMXC__Source_Object_Name__c = 'Case';
        sourceChildNodeObj.SVMXC__Node_Source_Object_API__c = 'Case';
        sourceChildNodeObj.SVMXC__Type__c = 'SOURCECHILD';
        sourceChildNodeObj.SVMXC__Process__c = SFMProc1.Id;
        upsert sourceChildNodeObj;
        
        targetNodeObj.RecordTypeId = ProcessNodeObjRTypeId;
        targetNodeObj.SVMXC__ProcessID__c ='PROCESS14';
        targetNodeObj.SVMXC__SettingId__c = 'PROCESS14';
        targetNodeObj.SVMXC__MapID__c='PROCESS14';
        targetNodeObj.SVMXC__Target_Object_label__c = 'targetNodeObj';
        targetNodeObj.SVMXC__Name__c = 'PROCESS24';
        targetNodeObj.SVMXC__Source_Object_Name__c = 'Case';
        targetNodeObj.SVMXC__Node_Source_Object_API__c = 'Case';
        targetNodeObj.SVMXC__Type__c = 'TARGET';
        targetNodeObj.SVMXC__Process__c = SFMProc1.Id;
        upsert targetNodeObj;
            
        targetChildNodeObj.RecordTypeId = ProcessNodeObjRTypeId;
        targetChildNodeObj.SVMXC__ProcessID__c='PROCESS15';
        targetChildNodeObj.SVMXC__SettingId__c = 'PROCESS15';
        targetChildNodeObj.SVMXC__MapID__c='PROCESS15';
        targetChildNodeObj.SVMXC__Target_Object_label__c = 'targetChildNodeObj';
        targetChildNodeObj.SVMXC__Name__c = 'PROCESS25';
        targetChildNodeObj.SVMXC__Source_Object_Name__c = 'Case';
        targetChildNodeObj.SVMXC__Node_Source_Object_API__c = 'Case';
        targetChildNodeObj.SVMXC__Type__c = 'TARGETCHILD';
        targetChildNodeObj.SVMXC__Process__c = SFMProc1.Id;
        upsert targetChildNodeObj;
        
        BizRule1.RecordTypeId = BizRuleRecordTypeId;
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
        insert lstBizRuleExpr;
        system.assert(lstBizRuleExpr != NULL);
        
        List<SVMXC__ServiceMax_Processes__c> lstTargetProBizRule = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Processes__c> lstTargetChildProBizRule = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c ProBizRule = new SVMXC__ServiceMax_Processes__c();
        ProBizRule.RecordTypeId = ProBizRuleRTypeId;
        ProBizRule.SVMXC__Process1__c = SFMProc1.Id;
        ProBizRule.SVMXC__Process2__c = targetNodeObj.Id;
        ProBizRule.SVMXC__Process3__c = BizRule1.Id;
        lstTargetProBizRule.add(ProBizRule);
        
        SVMXC__ServiceMax_Processes__c ProBizRule1 = new SVMXC__ServiceMax_Processes__c();
        ProBizRule1.RecordTypeId = ProBizRuleRTypeId;
        ProBizRule1.SVMXC__Process1__c = SFMProc1.Id;
        ProBizRule1.SVMXC__Process2__c = targetChildNodeObj.Id;
        ProBizRule1.SVMXC__Process3__c = BizRule1.Id;
        lstTargetChildProBizRule.add(ProBizRule1);
        
        SVMXC__ServiceMax_Processes__c ProBizRule2 = new SVMXC__ServiceMax_Processes__c();
        ProBizRule2.RecordTypeId = ProBizRuleRTypeId;
        ProBizRule2.SVMXC__Process1__c = SFMProc1.Id;
        ProBizRule2.SVMXC__Process2__c = targetNodeObj.Id;
        ProBizRule2.SVMXC__Process3__c = BizRule2.Id;
        lstTargetProBizRule.add(ProBizRule2);
        
        SVMXC__ServiceMax_Processes__c ProBizRule3 = new SVMXC__ServiceMax_Processes__c();
        ProBizRule3.RecordTypeId = ProBizRuleRTypeId;
        ProBizRule3.SVMXC__Process1__c = SFMProc1.Id;
        ProBizRule3.SVMXC__Process2__c = targetChildNodeObj.Id;
        ProBizRule3.SVMXC__Process3__c = BizRule2.Id;
        lstTargetChildProBizRule.add(ProBizRule3);
        insert lstTargetProBizRule;
        insert lstTargetChildProBizRule;
        
        List<SVMXC__ServiceMax_Processes__c> linkedProcesses = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c linkedProcess = new SVMXC__ServiceMax_Processes__c();
        linkedProcess.RecordTypeId = LinkedProcessRTypeId;
        linkedProcess.SVMXC__Process1__c = SFMProc1.id;
        linkedProcess.SVMXC__Process2__c = targetChildNodeObj.id;
        linkedProcess.SVMXC__Process3__c = SFMProc1.id;
        linkedProcesses.add(linkedProcess);
        insert linkedProcesses;
        
        SVMXC.CONF_ManageTranslations.TagWrapper TagWrapObj = new SVMXC.CONF_ManageTranslations.TagWrapper('', '', new SVMXC__ServiceMax_Tags__c(), new SVMXC__ServiceMax_Tags__c());
        SVMXC.CONF_ManageTranslations.TranslationWrapper TranslationWrapObj = new SVMXC.CONF_ManageTranslations.TranslationWrapper(new Set<String>(), new  List<SVMXC__ServiceMax_Processes__c>());
        SVMXC.CONF_ManageTranslations TranslnObj = new SVMXC.CONF_ManageTranslations();
        TranslnObj.setstrSearchKeyword('Test');
        TranslnObj.selectedProType = 'All';
        TranslnObj.selectedProcess ='Search_Process_1';
        TranslnObj.selectedLanguage = 'Master';
        TranslnObj.UpdateKeysBeforeConstructor();
        TranslnObj.getlstTagsWrapper();
        try{
            
            TranslnObj.setstrSearchKeyword('');
            TranslnObj.selectedProcess ='Search_Process_1';
            TranslnObj.onChngProcess();
            TranslnObj.onChngProcessType();
            TranslnObj.performSearch();
            TranslnObj.selectedProcess = 'All';
            TranslnObj.selectedProType = 'All';
            TranslnObj.onChngProcess();
            TranslnObj.onChngProcessType();
            TranslnObj.performSearch();
            TranslnObj.selectedProType = 'SFM';
            TranslnObj.onChngProcess();
            TranslnObj.onChngProcessType();
            TranslnObj.performSearch();
            TranslnObj.selectedProType = 'SFW';
            TranslnObj.onChngProcess();
            TranslnObj.onChngProcessType();
            TranslnObj.performSearch();
            TranslnObj.selectedProType = 'SFM_Search';
            TranslnObj.onChngProcess();
            TranslnObj.onChngProcessType();
            TranslnObj.performSearch();
            TranslnObj.selectedProType = 'Inventory_Process';
            TranslnObj.onChngProcess();
            TranslnObj.onChngProcessType();
            TranslnObj.performSearch();
            TranslnObj.onChngLanguage();
            TranslnObj.saveTranslations();
        }
        catch(exception ex){}
        TranslnObj.POPUP_YES();
        TranslnObj.POPUP_NO();
        TranslnObj.POPUP_CANCEL();
        TranslnObj.copyMasterTranslation();
        TranslnObj.sortingSelectOption(new List<SelectOption> ());
        SVMXC.I18N_TranslationDelivery_UT objUT = new SVMXC.I18N_TranslationDelivery_UT();
    }
    static testMethod void CONF_ManageTranslations_Test3(){
        SVMXC__QB_Response_Set__c objQBResposeSet = new SVMXC__QB_Response_Set__c();
        objQBResposeSet.Name = 'Test response set';
        objQBResposeSet.SVMXC__Response_Set_Values__c = 'value1;value2;';
        insert objQBResposeSet;
        
        SVMXC__Question_Bank__c objQuestionBank = new SVMXC__Question_Bank__c();
        objQuestionBank.SVMXC__QuestionID__c = 'QUE001';
        objQuestionBank.SVMXC__Question__c = 'Test Question';
        objQuestionBank.SVMXC__Response_Type__c = 'Picklist';
        objQuestionBank.SVMXC__Response_Set__c = objQBResposeSet.id;
        insert objQuestionBank;
        
        SVMXC__Question_Bank__c objQuestionBank1 = new SVMXC__Question_Bank__c();
        objQuestionBank1.SVMXC__QuestionID__c = 'QUE002';
        objQuestionBank1.SVMXC__Question__c = 'Test Question2';
        objQuestionBank1.SVMXC__Response_Type__c = 'Text';
        insert objQuestionBank1;
        
        
        SVMXC__SM_Default_Checklist_Response__c defaultResponeseSet = new SVMXC__SM_Default_Checklist_Response__c();
        defaultResponeseSet.SVMXC__SM_Default_Response__c = '{"literalValue":null,"listOfDefaultValues":["defaultAns"]}';
        defaultResponeseSet.SVMXC__SM_Question__c = objQuestionBank1.id;
        insert defaultResponeseSet;

       
        
        String targetManager;
        String processNodeObjects;
        String SVMXRuleID;
        String ExpressionsID;
        
        List<RecordType> RTypeList = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' OR  SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        
        if(RTypeList.size() > 0)
        {
            for(RecordType r : RTypeList)
            {
                if(r.Name == 'Target Manager')
                    targetManager = r.id; 
                else if(r.Name ==  'Process Node Objects')
                    processNodeObjects = r.id;
                else if(r.Name == 'SVMX Rule')
                    SVMXRuleID = r.id;
                else if(r.Name == 'Expressions')
                    ExpressionsID = r.id;
            }
        }
        
        //creating Rule
        SVMXC__ServiceMax_Processes__c objRule = new SVMXC__ServiceMax_Processes__c();
        objRule.SVMXC__Name__c = 'Testexp';
        objRule.SVMXC__Rule_Type__c = 'Named Expression';
        objRule.SVMXC__ProcessID__c = 'Trans_Manish';
        objRule.RecordTypeId = SVMXRuleID;
        objRule.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objRule.SVMXC__Parent_Error_Msg__c = 'Test msg';
        objRule.SVMXC__SettingID__c = 'Trans_Manish';
        insert objRule;
        
        SVMXC__ServiceMax_Config_Data__c objExpression = new SVMXC__ServiceMax_Config_Data__c();
        objExpression.RecordTypeId = ExpressionsID;
        objExpression.SVMXC__Expression_Rule__c = objRule.id;
        objExpression.SVMXC__Action_Type__c = 'Set Value';
        objExpression.SVMXC__Field_Name__c = 'SVMXC__Order_Status__c';
        objExpression.SVMXC__Display_Type__c = 'PICKLIST';
        objExpression.SVMXC__Expression_Type__c = 'EXP_Named';
        objExpression.SVMXC__Operand__c = 'Open';
        objExpression.SVMXC__Operator__c = 'eq';
        insert objExpression;       
        
        //Create Header Page layout
        SVMXC__Page_Layout__c objHeaderLayout = new SVMXC__Page_Layout__c();
        objHeaderLayout.SVMXC__Object_Name__c = 'SVMXC__Checklist__c';
        objHeaderLayout.SVMXC__Type__c = 'Header';
        insert objHeaderLayout;
        System.assertEquals(true, objHeaderLayout != null);
        
        //Create Sections for header
        SVMXC__Page_Layout_Detail__c objSection1 = new SVMXC__Page_Layout_Detail__c();
        objSection1.SVMXC__Detail_Type__c = 'Section';
        objSection1.SVMXC__Page_Layout_Detail_Id__c = 'sectionLayout1';
        objSection1.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objSection1.SVMXC__Title__c = 'Checklist Section Title';
        objSection1.SVMXC__Sequence__c = 1;
        insert objSection1;
       
        //Create Fields for Header Layout
        List<SVMXC__Page_Layout_Detail__c> lstHeaderFields = new List<SVMXC__Page_Layout_Detail__c>();    
        SVMXC__Page_Layout_Detail__c objfld1 = new SVMXC__Page_Layout_Detail__c();
        objfld1.SVMXC__Detail_Type__c = 'Question';
        objfld1.SVMXC__Question__c = objQuestionBank.id;
        objfld1.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objfld1.SVMXC__Section__c = objSection1.Id;
        objfld1.SVMXC__DataType__c = 'reference';
        objfld1.SVMXC__Sequence__c = 1;
        insert objfld1;
        
        SVMXC__Page_Layout_Detail__c objfld2 = new SVMXC__Page_Layout_Detail__c();
        objfld2.SVMXC__Detail_Type__c = 'Question';
        objfld2.SVMXC__Question__c = objQuestionBank1.id;
        objfld2.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objfld2.SVMXC__Section__c = objSection1.Id;
        objfld2.SVMXC__DataType__c = 'reference';
        objfld2.SVMXC__Sequence__c = 2;
        insert objfld2;
        
        //Create SFM Process Defination
        SVMXC__ServiceMax_Processes__c ChecklistProcess = new SVMXC__ServiceMax_Processes__c();
        ChecklistProcess.SVMXC__Name__c = 'TESTPROCESS001';
        ChecklistProcess.RecordTypeId = targetManager;
        ChecklistProcess.SVMXC__Purpose__c = 'CHECKLIST';
        ChecklistProcess.SVMXC__ProcessID__c = 'TESTPROCESS001';
        ChecklistProcess.SVMXC__Page_Layout__c = objHeaderLayout.id;
        ChecklistProcess.SVMXC__Description__c = 'Test Description';
        insert ChecklistProcess;
        
        //Create Process Node object Records.
        list<SVMXC__ServiceMax_Processes__c> listProcessNodeObjects = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c PNObject1 = new SVMXC__ServiceMax_Processes__c();
        PNObject1.RecordTypeId = processNodeObjects;
        PNObject1.SVMXC__Type__c = 'TARGET';
        PNObject1.SVMXC__Source_Object_Name__c = 'SVMXC__Checklist__c';
        PNObject1.SVMXC__Process__c = ChecklistProcess.id;        
        PNObject1.SVMXC__Node_Source_Object_API__c = 'SVMXC__Service_Order__c';
        PNObject1.SVMXC__Submodule__c  = objRule.id;
        listProcessNodeObjects.add(PNObject1);
        
        SVMXC__ServiceMax_Processes__c PNObject2 = new SVMXC__ServiceMax_Processes__c();
        PNObject2.RecordTypeId = processNodeObjects;
        PNObject2.SVMXC__Type__c = 'SOURCE';
        PNObject2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        PNObject2.SVMXC__Process__c = ChecklistProcess.id;
        listProcessNodeObjects.add(PNObject2);
        insert listProcessNodeObjects;
        
        SVMXC.CONF_ManageTranslations TranslnObj = new SVMXC.CONF_ManageTranslations();
        TranslnObj.UpdateKeysBeforeConstructor();
        TranslnObj.selectedProType = 'Checklist_Process';
        TranslnObj.onChngProcessType();
        
        TranslnObj.selectedProcess = 'All';
        TranslnObj.selectedProType = 'Checklist_Process';
        TranslnObj.onChngProcess();
        
        TranslnObj.selectedLanguage = 'Master';
        TranslnObj.selectedProcess = ChecklistProcess.id;
        TranslnObj.onChngLanguage();
        
        TranslnObj.selectedLanguage = 'Master';
        TranslnObj.strSearchKeyword = 'Test';
        
        //////////---------
        TranslnObj.selectedProType = 'All';
        TranslnObj.selectedProcess = 'All';
        TranslnObj.performSearch();
        TranslnObj.selectedProcess = ChecklistProcess.id;
        TranslnObj.performSearch();
        
        TranslnObj.selectedProType = 'SFM';
        TranslnObj.selectedProcess = 'All';
        TranslnObj.performSearch();
        TranslnObj.selectedProcess = ChecklistProcess.id;
        TranslnObj.performSearch();
        
        TranslnObj.selectedProType = 'SFW';
        TranslnObj.selectedProcess = 'All';
        TranslnObj.performSearch();
        TranslnObj.selectedProcess = ChecklistProcess.id;
        TranslnObj.performSearch();
        
        TranslnObj.selectedProType = 'SFM_Search';
        TranslnObj.selectedProcess = 'All';
        TranslnObj.performSearch();
        TranslnObj.selectedProcess = ChecklistProcess.id;
        TranslnObj.performSearch();
        
        TranslnObj.selectedProType = 'Inventory_Process';
        TranslnObj.selectedProcess = 'All';
        TranslnObj.performSearch();
        TranslnObj.selectedProcess = ChecklistProcess.id;
        TranslnObj.performSearch();
        
        TranslnObj.selectedProType = 'Checklist_Process';
        TranslnObj.selectedProcess = 'All';
        TranslnObj.performSearch();
        TranslnObj.selectedProcess = ChecklistProcess.id;
        TranslnObj.performSearch();
        //////////-----------
        
        /////////-------------
        TranslnObj.strSearchKeyword = null;
        
        TranslnObj.selectedProType = 'All';
        TranslnObj.selectedProcess = 'All';
        TranslnObj.performSearch();
        TranslnObj.selectedProcess = ChecklistProcess.id;
        TranslnObj.performSearch();
        
        TranslnObj.selectedProType = 'SFM';
        TranslnObj.selectedProcess = 'All';
        TranslnObj.performSearch();
        TranslnObj.selectedProcess = ChecklistProcess.id;
        TranslnObj.performSearch();
        
        TranslnObj.selectedProType = 'SFW';
        TranslnObj.selectedProcess = 'All';
        TranslnObj.performSearch();
        TranslnObj.selectedProcess = ChecklistProcess.id;
        TranslnObj.performSearch();
        
        TranslnObj.selectedProType = 'SFM_Search';
        TranslnObj.selectedProcess = 'All';
        TranslnObj.performSearch();
        TranslnObj.selectedProcess = ChecklistProcess.id;
        TranslnObj.performSearch();
        
        TranslnObj.selectedProType = 'Inventory_Process';
        TranslnObj.selectedProcess = 'All';
        TranslnObj.performSearch();
        TranslnObj.selectedProcess = ChecklistProcess.id;
        TranslnObj.performSearch();
        
        TranslnObj.selectedProType = 'Checklist_Process';
        TranslnObj.selectedProcess = 'All';
        TranslnObj.performSearch();
        TranslnObj.selectedProcess = ChecklistProcess.id;
        TranslnObj.performSearch();
        ///////////////---------
        CONF_ManageTranslations obj3 = new CONF_ManageTranslations();
        obj3.generateMasterTag(ChecklistProcess.id);
    }
    static testMethod void CONF_ManageTranslations_Test4()
    {
        SVMXC__ServiceMax_Tags__c tag = new SVMXC__ServiceMax_Tags__c();
        tag.SVMXC__Tag_Key__c = 'TEST_MYSERVICEFLOWWIZARD0001';
        tag.SVMXC__Language__c ='Master';
        tag.SVMXC__Tag_Value__c = 'Test MyServiceFlowWizard0001';
        tag.SVMXC__Tag_Context__c = 'WIZARD_NAME';
        tag.Name ='Test MyServiceFlowWizard0001';
        insert tag;
        SVMXC__ServiceMax_Tags__c tag1 = new SVMXC__ServiceMax_Tags__c();
        tag1.SVMXC__Tag_Key__c = 'TEST_SFM_PROCESS01';
        tag1.SVMXC__Language__c ='Master';
        tag1.SVMXC__Tag_Value__c = 'Test SFM_PROCESS01';
        tag1.SVMXC__Tag_Context__c = 'WIZARD_NAME';
        tag1.Name ='Test SFM_PROCESS01';
        insert tag1;
        

    }
    
}