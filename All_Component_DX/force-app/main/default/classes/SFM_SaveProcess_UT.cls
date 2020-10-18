@isTest
private class SFM_SaveProcess_UT
{
    static String RuleRecordTypeId = '';
    static String TargetManagerRTypeId = '';
    static String ProcessNodeObjRTypeId = '';
    static String ProBizRuleRTypeId = '';
    static String ExpressionRTypeId = '';
    static String LinkedProcessRTypeId = '';
    static SVMXC__ServiceMax_Processes__c SFMProc1 = new SVMXC__ServiceMax_Processes__c();
    static SVMXC__ServiceMax_Processes__c sourceNodeObj = new SVMXC__ServiceMax_Processes__c();
    static SVMXC__ServiceMax_Processes__c sourceChildNodeObj = new SVMXC__ServiceMax_Processes__c();
    static SVMXC__ServiceMax_Processes__c targetNodeObj = new SVMXC__ServiceMax_Processes__c();
    static SVMXC__ServiceMax_Processes__c targetChildNodeObj = new SVMXC__ServiceMax_Processes__c();
    static SVMXC__ServiceMax_Config_Data__c SourceUpdate1 = new SVMXC__ServiceMax_Config_Data__c();
    static SVMXC__ServiceMax_Config_Data__c SourceUpdate2 = new SVMXC__ServiceMax_Config_Data__c();    
    static List<SVMXC__ServiceMax_Config_Data__c> processSourceUpdates = new List<SVMXC__ServiceMax_Config_Data__c>();
    static SFM_WrapperDef.SFM_Request_ProcessNodeInfo processNodeinfo;
    static List<SVMXC__ServiceMax_Config_Data__c> lstBizRuleExpr = new List<SVMXC__ServiceMax_Config_Data__c>();
    static SVMXC__ServiceMax_Processes__c BizRule1 = new SVMXC__ServiceMax_Processes__c();
    static SVMXC__ServiceMax_Config_Data__c BizRuleExpr11 = new SVMXC__ServiceMax_Config_Data__c();
    static SVMXC__ServiceMax_Config_Data__c BizRuleExpr12 = new SVMXC__ServiceMax_Config_Data__c();
    static SVMXC__ServiceMax_Processes__c BizRule2 = new SVMXC__ServiceMax_Processes__c();
    static SVMXC__ServiceMax_Config_Data__c BizRuleExpr21 = new SVMXC__ServiceMax_Config_Data__c();
    static SVMXC__ServiceMax_Config_Data__c BizRuleExpr22 = new SVMXC__ServiceMax_Config_Data__c();
    static List<SVMXC__ServiceMax_Processes__c> lstProBizRule = new List<SVMXC__ServiceMax_Processes__c>();
    
    static void createTestData(Boolean isEdit)
    {
        for(RecordType RType : [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' OR SobjectType = 'SVMXC__ServiceMax_Config_Data__c'])
        {
            if(RType.Name == 'Business Rule')
                RuleRecordTypeId = RType.id;
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
        SFMProc1.SVMXC__ProcessID__c = 'PROCESS11';
        SFMProc1.SVMXC__SettingId__c = 'PROCESS11';
        SFMProc1.SVMXC__MapID__c = 'PROCESS11';
        SFMProc1.SVMXC__Name__c = 'PROCESS21';
        SFMProc1.SVMXC__Description__c = 'New Process 1';
        SFMProc1.SVMXC__IsStandard__c = true;
        if(!isEdit)
            insert SFMProc1;
        
        // SOURCE OBJECT
        sourceNodeObj.RecordTypeId = ProcessNodeObjRTypeId; 
        sourceNodeObj.SVMXC__ProcessID__c = 'PROCESS12';
        sourceNodeObj.SVMXC__SettingId__c = 'PROCESS12';
        sourceNodeObj.SVMXC__MapID__c = 'PROCESS12';
        sourceNodeObj.SVMXC__Name__c = 'PROCESS22';
        sourceNodeObj.SVMXC__Source_Object_Name__c = 'Case';
        sourceNodeObj.SVMXC__Node_Source_Object_API__c = 'Case';
        sourceNodeObj.SVMXC__Type__c = 'SOURCE';
        sourceNodeObj.SVMXC__Process__c = SFMProc1.Id;
        if(!isEdit)
            upsert sourceNodeObj;
        
        // SOURCE CHILD OBJECT
        sourceChildNodeObj.RecordTypeId = ProcessNodeObjRTypeId;
        sourceChildNodeObj.SVMXC__ProcessID__c = 'PROCESS13';
        sourceChildNodeObj.SVMXC__SettingId__c = 'PROCESS13';
        sourceChildNodeObj.SVMXC__MapID__c ='PROCESS13';
        sourceChildNodeObj.SVMXC__Name__c = 'PROCESS23';
        sourceChildNodeObj.SVMXC__Source_Object_Name__c = 'SVMXC__Case_Tracker__c';
        sourceChildNodeObj.SVMXC__Node_Source_Object_API__c = 'SVMXC__Case_Tracker__c';
        sourceChildNodeObj.SVMXC__Type__c = 'SOURCECHILD';
        sourceChildNodeObj.SVMXC__Process__c = SFMProc1.Id;
        if(!isEdit)
            upsert sourceChildNodeObj;
        
        // TARGET OBJECT
        targetNodeObj.RecordTypeId = ProcessNodeObjRTypeId;
        targetNodeObj.SVMXC__ProcessID__c ='PROCESS14';
        targetNodeObj.SVMXC__SettingId__c = 'PROCESS14';
        targetNodeObj.SVMXC__MapID__c='PROCESS14';
        targetNodeObj.SVMXC__Target_Object_label__c = 'targetNodeObj';
        targetNodeObj.SVMXC__Name__c = 'PROCESS24';
        targetNodeObj.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        targetNodeObj.SVMXC__Node_Source_Object_API__c = 'SVMXC__Service_Order__c';
        targetNodeObj.SVMXC__Type__c = 'TARGET';
        targetNodeObj.SVMXC__Process__c = SFMProc1.Id;
        if(!isEdit)
            upsert targetNodeObj;
        
        // TARGET CHILD OBJECT
        targetChildNodeObj.RecordTypeId = ProcessNodeObjRTypeId;
        targetChildNodeObj.SVMXC__ProcessID__c='PROCESS15';
        targetChildNodeObj.SVMXC__SettingId__c = 'PROCESS15';
        targetChildNodeObj.SVMXC__MapID__c='PROCESS15';
        targetChildNodeObj.SVMXC__Target_Object_label__c = 'targetChildNodeObj';
        targetChildNodeObj.SVMXC__Name__c = 'PROCESS25';
        targetChildNodeObj.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order_Line__c';
        targetChildNodeObj.SVMXC__Node_Source_Object_API__c = 'SVMXC__Service_Order__c';
        targetChildNodeObj.SVMXC__Type__c = 'TARGETCHILD';
        targetChildNodeObj.SVMXC__Process__c = SFMProc1.Id;
        if(!isEdit)
            upsert targetChildNodeObj;
        
        SourceUpdate1.SVMXC__Dispatch_Process__c = SFMProc1.Id;
        SourceUpdate1.SVMXC__MapID__c = SFMProc1.Id;
        SourceUpdate1.SVMXC__Source_Field_Name__c = 'SVMXconfigData1';
        SourceUpdate1.SVMXC__Setting_ID__c = SFMProc1.Id;
        SourceUpdate1.SVMXC__Configuration_Type__c='Source Update';
        processSourceUpdates.add(SourceUpdate1);
        
        SourceUpdate2.SVMXC__Dispatch_Process__c = SFMProc1.Id;
        SourceUpdate2.SVMXC__MapID__c = SFMProc1.Id;
        SourceUpdate2.SVMXC__Source_Field_Name__c = 'SVMXconfigData2';
        SourceUpdate2.SVMXC__Setting_ID__c = SFMProc1.Id;
        SourceUpdate2.SVMXC__Configuration_Type__c='Source Update';
        processSourceUpdates.add(SourceUpdate2);
        
        
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
        
        //Create Linkd Processe
        List<SVMXC__ServiceMax_Processes__c> linkedProcesses = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c linkedProcess = new SVMXC__ServiceMax_Processes__c();
        linkedProcess.RecordTypeId = LinkedProcessRTypeId;
        linkedProcess.SVMXC__Process1__c = SFMProc1.id;
        linkedProcess.SVMXC__Process2__c = targetChildNodeObj.id;
        linkedProcess.SVMXC__Process3__c = SFMProc1.id;
        linkedProcesses.add(linkedProcess);
        insert linkedProcesses;
        
        //Creating List of ProcessNodeDetail for Source Object
        list<SFM_WrapperDef.SFM_ProcessNodeDetail> lstProcessNodeSourceObj = new list<SFM_WrapperDef.SFM_ProcessNodeDetail>();
        lstProcessNodeSourceObj.add(new SFM_WrapperDef.SFM_ProcessNodeDetail(sourceNodeObj, processSourceUpdates));
        lstProcessNodeSourceObj.add(new SFM_WrapperDef.SFM_ProcessNodeDetail(sourceChildNodeObj, processSourceUpdates));
            
        //ProcessNodeDetail for Target Object
        SFM_WrapperDef.SFM_ProcessNodeDetail processNodeTargetObject1 = new SFM_WrapperDef.SFM_ProcessNodeDetail(targetNodeObj, processSourceUpdates);
        processNodeTargetObject1.processBizRules = lstTargetProBizRule;
        processNodeTargetObject1.linkedProcesses = linkedProcesses;
        SFM_WrapperDef.SFM_ProcessNodeDetail processNodeTargetObject2 = new SFM_WrapperDef.SFM_ProcessNodeDetail(targetChildNodeObj, processSourceUpdates);
        processNodeTargetObject2.processBizRules = lstTargetChildProBizRule;
        processNodeTargetObject2.linkedProcesses = linkedProcesses;
        
        //Creating List of ProcessNodeDetail for Target Object
        list<SFM_WrapperDef.SFM_ProcessNodeDetail> lstProcessNodeTargetObj = new list<SFM_WrapperDef.SFM_ProcessNodeDetail>();
        lstProcessNodeTargetObj.add(processNodeTargetObject1);
        lstProcessNodeTargetObj.add(processNodeTargetObject2);
       
        //Instance of SFM_Request_ProcessNodeInfo Class
        processNodeinfo = new SFM_WrapperDef.SFM_Request_ProcessNodeInfo(SFMProc1, lstProcessNodeSourceObj, lstProcessNodeTargetObj);
    }
    
    static testMethod void SFM_saveProcess_Test1()
    {
        Boolean isEdit = false;
        createTestData(isEdit);
        SFM_saveProcess SFM_saveProcessObj = new SFM_saveProcess();

        SFM_saveProcessObj.saveProcess(processNodeinfo);
    }
    static testMethod void SFM_saveProcess_Test2()
    {
        Boolean isEdit = true;
        createTestData(isEdit);
        SFM_saveProcess SFM_saveProcessObj = new SFM_saveProcess();
        SFM_saveProcessObj.saveProcess(processNodeinfo);
    }
    
    static testMethod void opdocChecklist_TestMethod(){
        SFM_WrapperDef.SFM_Request_ProcessNodeInfo processNodeinfo = new SFM_WrapperDef.SFM_Request_ProcessNodeInfo();
        processNodeinfo.processNodes = new SVMXC__ServiceMax_Processes__c(SVMXC__Active__c = false, SVMXC__Rule_Type__c = 'interactive',
                                                                           SVMXC__IsStandard__c = false,SVMXC__Name__c = 'testChecklistDocProcess',
                                                                           SVMXC__Dispatch_Process_Status__c = 'Complete', SVMXC__IsStandalone__c = false,
                                                                           SVMXC__SM_Include_Skipped_Sections__c = true,SVMXC__ProcessID__c = 'testChecklistDocProcess',
                                                                           SVMXC__Purpose__c = 'OUTPUT DOCUMENT');
        
        SFM_WrapperDef.SFM_ProcessNodeDetail processNodeDetail1 = new SFM_WrapperDef.SFM_ProcessNodeDetail();
        
        processNodeDetail1.processNodeObejct = new SVMXC__ServiceMax_Processes__c(SVMXC__Source_Object_Name__c = 'Account', SVMXC__Sequence__c = 0,
                                                                                    SVMXC__Target_Object_label__c = 'Account',SVMXC__Type__c = 'Target',
                                                                                    SVMXC__Source_Key__c = 0);
        
    SFM_WrapperDef.SFM_ProcessNodeDetail processNodeDetail2 = new SFM_WrapperDef.SFM_ProcessNodeDetail();
        
        processNodeDetail2.processNodeObejct = new SVMXC__ServiceMax_Processes__c(SVMXC__Parent_Column_Name__c = 'SVMXC__Account__c',SVMXC__Source_Object_Name__c = 'SVMXC__Checklist__c', 
                                                                                       SVMXC__Sequence__c = 1,SVMXC__Target_Object_label__c = 'Checklist (Account)',SVMXC__Type__c = 'TARGETCHILD',
                                                                                    SVMXC__Node_Parent_API__c = 'Account', SVMXC__Source_Key__c = 1);        
            
        List<SFM_WrapperDef.SFM_ProcessNodeDetail> processNodeDetailList = new List<SFM_WrapperDef.SFM_ProcessNodeDetail>();
        processNodeDetailList.add(processNodeDetail1);
        processNodeDetailList.add(processNodeDetail2);
        
        processNodeinfo.processNodeTargetObject = processNodeDetailList;  
        
        processNodeinfo.lstSelectedChecklistProcess = insertChecklistProcess();
       
            
        test.startTest();
        SFM_saveProcess SFM_saveProcessObj = new SFM_saveProcess();
    SFM_saveProcessObj.saveProcess(processNodeinfo);
        
        SFM_saveProcessObj.saveProcess(processNodeinfo);
        test.stopTest();
    }
    
    static List<SFM_WrapperDef.SFM_SelectedChecklistProcess> insertChecklistProcess(){
        SFM_CheckListUtils_UT.getRecordTypeIds();
        Id accountId = SFM_CheckListUtils_UT.createTestAccount();
      Id expressionProcessID = SFM_CheckListUtils_UT.createExpressionProcess('Account');
        Id targetManagerProcessId = SFM_CheckListUtils_UT.createTargetManagerProcess('Account', 'Checklist_Test01');
    SFM_CheckListUtils_UT.createNodeObjectProcess(targetManagerProcessId,expressionProcessID, 'Account');
        SFM_CheckListUtils_UT.createChecklistRec(targetManagerProcessId,accountId);
        
        List<SFM_WrapperDef.SFM_SelectedChecklistProcess> opDocSelectedChecklistProcessList = new List<SFM_WrapperDef.SFM_SelectedChecklistProcess>();
        
        SFM_WrapperDef.SFM_SelectedChecklistProcess checklistProcess1 = new SFM_WrapperDef.SFM_SelectedChecklistProcess();
        checklistProcess1.selectedChecklistVersion = 'First Completed';
        checklistProcess1.selectedChecklistId = targetManagerProcessId;
        checklistProcess1.checklistCriteriaProcess = SFM_CheckListUtils_UT.businessProcessRule('SVMXC__Checklist__c');
        List<SVMXC__ServiceMax_Config_Data__c> configRecordsList = new List<SVMXC__ServiceMax_Config_Data__c>();
        configRecordsList.add( SFM_CheckListUtils_UT.businessProcessConfigRecord(checklistProcess1.checklistCriteriaProcess.Id));
        checklistProcess1.lstExpressionRecord = configRecordsList;
        opDocSelectedChecklistProcessList.add(checklistProcess1);
        
        targetManagerProcessId = SFM_CheckListUtils_UT.createTargetManagerProcess('Account', 'Checklist_Test02');
    SFM_CheckListUtils_UT.createNodeObjectProcess(targetManagerProcessId,expressionProcessID, 'Account');
        SFM_CheckListUtils_UT.createChecklistRec(targetManagerProcessId,accountId);

        SFM_WrapperDef.SFM_SelectedChecklistProcess checklistProcess2 = new SFM_WrapperDef.SFM_SelectedChecklistProcess();
        checklistProcess2.selectedChecklistVersion = 'First Completed';
        checklistProcess2.selectedChecklistId = targetManagerProcessId;
        
        opDocSelectedChecklistProcessList.add(checklistProcess2);
        
        return opDocSelectedChecklistProcessList;
    }
}