@isTest(SeeAllData = false)
public class SFMDesigner2ServiceIntf_UT{
    public Static RestRequest req;
    public Static RestResponse res;
    public Static Map<String,Id> recordTypeIdMap = new Map<String,Id>();

    Static void getRecordTypes(){
        for(RecordType rec : [SELECT Id, Name FROM RecordType WHERE SobjectType IN ('SVMXC__ServiceMax_Processes__c','SVMXC__ServiceMax_Config_Data__c') AND isActive = true]){
            recordTypeIdMap.put(rec.Name, rec.Id);
        }
    }

    @testSetup static void test_SFMData() {
        getRecordTypes();

        /*
            Custom Settings: Property Elements
        */
        SVMXC__ServiceMax_Properties__c propertyRecord = new SVMXC__ServiceMax_Properties__c(Name = 'PROP001', SVMXC__Value__c = 'Titanium');
        insert propertyRecord;

        List<SVMXC__ServiceMax_Property_Elements__c> elementsList = new List<SVMXC__ServiceMax_Property_Elements__c>();
        SVMXC__ServiceMax_Property_Elements__c propertyElementRecord1 = new SVMXC__ServiceMax_Property_Elements__c(Name= 'PELE001', SVMXC__Property_Key__c = 'BLOCKED SOURCE HEADER', SVMXC__Element_Value__c = 'SVMXC__ServiceMax_Processes__c');
        elementsList.add(propertyElementRecord1);
        SVMXC__ServiceMax_Property_Elements__c propertyElementRecord2 = new SVMXC__ServiceMax_Property_Elements__c(Name='PELE002', SVMXC__Property_Key__c = 'Titanium', SVMXC__Element_Value__c = 'Account');
        elementsList.add(propertyElementRecord2);
        insert elementsList;

        /*
            Response Set
        */
        SVMXC__QB_Response_Set__c responseSet1 = new SVMXC__QB_Response_Set__c();
        responseSet1.Name = 'yes or no';
        responseSet1.SVMXC__Response_Set_Values__c = 'Yes;No;';
        insert responseSet1;

        /*
            Questions
        */
        SVMXC__Question_Bank__c qb1 = new SVMXC__Question_Bank__c();
        qb1.SVMXC__Question__c = 'Servicemax Question?';
        qb1.SVMXC__QuestionID__c = 'testqb0002';
        qb1.SVMXC__Response_Type__c = 'Checkbox';
        qb1.SVMXC__Response_Set__c = responseSet1.Id;
        insert qb1;
        /*
            Page Layout Header
        */
        SVMXC__Page_Layout__c pageLayoutRecord = new SVMXC__Page_Layout__c();
        pageLayoutRecord.SVMXC__Name__c = 'SVMXDESIGNER2: Sample Layout';
        pageLayoutRecord.SVMXC__Page_Layout_ID__c = 'designer2_Sample_Layout';
        pageLayoutRecord.SVMXC__Type__c = 'Header';
        pageLayoutRecord.SVMXC__Object_Name__c = 'Case';
        insert pageLayoutRecord;

        SVMXC__Page_Layout_Detail__c pageLayoutSectionRecord = new SVMXC__Page_Layout_Detail__c();
        pageLayoutSectionRecord.SVMXC__Page_Layout__c = pageLayoutRecord.Id;
        pageLayoutSectionRecord.SVMXC__No_Of_Columns__c = 2;
        pageLayoutSectionRecord.SVMXC__Sequence__c = 1;
        pageLayoutSectionRecord.SVMXC__Title__c = 'Test Title';
        pageLayoutSectionRecord.SVMXC__Detail_Type__c = 'Section';
        insert pageLayoutSectionRecord;

        /*
            Page Layout Detail
        */
        SVMXC__Page_Layout__c pageLayoutDetailRecord = new SVMXC__Page_Layout__c();
        pageLayoutDetailRecord.SVMXC__Name__c = 'Case Lines';
        pageLayoutDetailRecord.SVMXC__Sequence__c = 1;
        pageLayoutDetailRecord.SVMXC__Type__c = 'Detail';
        pageLayoutDetailRecord.SVMXC__Object_Name__c = 'SVMXC__Case_Line__c';
        pageLayoutDetailRecord.SVMXC__Page_Layout_ID__c = 'Case Lines';
        pageLayoutDetailRecord.SVMXC__Header_Page_Layout__c = pageLayoutRecord.Id;
        insert pageLayoutDetailRecord;

        List<SVMXC__Page_Layout_Detail__c> layoutElementsList = new List<SVMXC__Page_Layout_Detail__c>();
        SVMXC__Page_Layout_Detail__c pageLayoutElementRecord = new SVMXC__Page_Layout_Detail__c();
        pageLayoutElementRecord.SVMXC__Page_Layout__c = pageLayoutRecord.Id;
        pageLayoutElementRecord.SVMXC__Field_API_Name__c = 'SVMXC__Service_Contract__c';
        pageLayoutElementRecord.SVMXC__Detail_Type__c = 'Field';
        pageLayoutElementRecord.SVMXC__Related_Object_Name__c = 'SVMXC__Service_Contract__c';
        pageLayoutElementRecord.SVMXC__Related_Object_Name_Field__c = 'Name';
        pageLayoutElementRecord.SVMXC__Sequence__c = 1;
        pageLayoutElementRecord.SVMXC__Section__c = pageLayoutSectionRecord.Id;
        layoutElementsList.add(pageLayoutElementRecord);

        SVMXC__Page_Layout_Detail__c pageLayoutElementRecord1 = new SVMXC__Page_Layout_Detail__c();
        pageLayoutElementRecord1.SVMXC__Field_API_Name__c = 'Name';
        pageLayoutElementRecord1.SVMXC__Detail_Type__c = 'Field';
        pageLayoutElementRecord1.SVMXC__Related_Object_Name__c = 'SVMXC__Case_Line__c';
        pageLayoutElementRecord1.SVMXC__Related_Object_Name_Field__c = 'Name';
        pageLayoutElementRecord.SVMXC__Sequence__c = 1;
        pageLayoutElementRecord1.SVMXC__Page_Layout__c = pageLayoutDetailRecord.Id;
        layoutElementsList.add(pageLayoutElementRecord1);

        SVMXC__Page_Layout_Detail__c questionElement1 = new SVMXC__Page_Layout_Detail__c();
        questionElement1.SVMXC__Page_Layout__c = pageLayoutRecord.Id;
        questionElement1.SVMXC__Detail_Type__c = 'Question';
        questionElement1.SVMXC__Question__c = qb1.Id;
        questionElement1.SVMXC__Section__c = pageLayoutSectionRecord.Id;
        layoutElementsList.add(questionElement1);

        insert layoutElementsList;

        SVMXC__SFM_Event__c eventRecord = new SVMXC__SFM_Event__c();
        eventRecord.SVMXC__Event_Call_Type__c = 'WEBSERVICE';
        eventRecord.SVMXC__Event_Type__c = 'Field Change';
        eventRecord.SVMXC__Target_Call__c = 'test.test';
        eventRecord.SVMXC__Page_Layout_Detail__c = pageLayoutElementRecord.Id;
        insert eventRecord;

        /*
            Opdoc Template
        */
        SVMXC__Doc_Template__c docTemplate = new SVMXC__Doc_Template__c();
        docTemplate.SVMXC__Name__c = 'doc Template Designer 2';
        docTemplate.SVMXC__IsStandard__c = false;
        docTemplate.SVMXC__Template_Id__c = 'doc_Template_Designer_2';
        docTemplate.SVMXC__Media_Resources__c = 'ServiceMaxLogo';
        insert docTemplate;

        Attachment attachTemplate = new Attachment(Name= 'SFM_Doc_Template.html', Body = Blob.valueOf('abc'), ParentId = docTemplate.Id);
        insert attachTemplate;

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'SFM_Doc_Template.html';
        contentVersion.PathOnClient = 'SFM_Doc_Template.html';
        contentVersion.IsMajorVersion = false;
        contentVersion.VersionData = Blob.valueOf('Test Template Content');
        insert contentVersion;
        List<SVMXC__Doc_Template_Details__c> docTemplateDetailList = new List<SVMXC__Doc_Template_Details__c>();
        SVMXC__Doc_Template_Details__c docTemplateDetail = new SVMXC__Doc_Template_Details__c();
        docTemplateDetail.SVMXC__Object_Name__c = 'Account';
        docTemplateDetail.SVMXC__Doc_Template__c = docTemplate.Id;
        docTemplateDetail.SVMXC__Doc_Template_Detail_Id__c = 'MyAccount';
        docTemplateDetail.SVMXC__Alias__c = 'My Account';
        docTemplateDetail.SVMXC__Type__c = 'Header_Object';
        docTemplateDetailList.add(docTemplateDetail);

        SVMXC__Doc_Template_Details__c docTemplateDetail1 = new SVMXC__Doc_Template_Details__c();
        docTemplateDetail1.SVMXC__Object_Name__c = 'Contact';
        docTemplateDetail1.SVMXC__Doc_Template__c = docTemplate.Id;
        docTemplateDetail1.SVMXC__Doc_Template_Detail_Id__c = 'MyContact';
        docTemplateDetail1.SVMXC__Alias__c = 'My_Contact';
        docTemplateDetail1.SVMXC__Type__c = 'Detail_Object';
        docTemplateDetail1.SVMXC__Header_Reference_Field__c = 'Account';
        docTemplateDetailList.add(docTemplateDetail1);

        insert docTemplateDetailList;

        List<SVMXC__ServiceMax_Processes__c> nodeRecordsList = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Processes__c> nodeRecordsList1 = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Processes__c> processList = new List<SVMXC__ServiceMax_Processes__c>();

        SVMXC__ServiceMax_Processes__c subprocessRecord = new SVMXC__ServiceMax_Processes__c();
        subprocessRecord.SVMXC__Name__c = 'subTestProcess';
        subprocessRecord.SVMXC__ProcessID__c = 'subTestProcess';
        subprocessRecord.SVMXC__Purpose__c = 'SOURCE TO TARGET ALL';
        subprocessRecord.SVMXC__Description__c = 'Sub Test Process';
        subprocessRecord.SVMXC__Dispatch_Process_Status__c = 'Complete';
        subprocessRecord.SVMXC__Page_Layout__c = pageLayoutRecord.Id;
        subprocessRecord.RecordTypeId = recordTypeIdMap.get('Target Manager');
        processList.add(subprocessRecord);

        SVMXC__ServiceMax_Processes__c globalModuleInv = new SVMXC__ServiceMax_Processes__c();
        globalModuleInv.SVMXC__SubmoduleID__c = 'Inventory';
        globalModuleInv.RecordTypeId = recordTypeIdMap.get('Submodule');
        processList.add(globalModuleInv);
        
        insert processList;
        processList = new List<SVMXC__ServiceMax_Processes__c>(); 
            
        SVMXC__ServiceMax_Processes__c processRecord = new SVMXC__ServiceMax_Processes__c();
        processRecord.SVMXC__Name__c = 'designer2TestProcess';
        processRecord.SVMXC__ProcessID__c = 'designer2TestProcess';
        processRecord.SVMXC__Purpose__c = 'SOURCE TO TARGET ALL';
        processRecord.SVMXC__Description__c = 'Test Process';
        processRecord.SVMXC__Dispatch_Process_Status__c = 'Complete';
        processRecord.SVMXC__Page_Layout__c = pageLayoutRecord.Id;
        processRecord.RecordTypeId = recordTypeIdMap.get('Target Manager');
        processRecord.SVMXC__Enable_Sub_Process__c = true;
        processRecord.SVMXC__Process2__c = subprocessRecord.Id;
        processRecord.SVMXC__Sub_Process_Source_Field__c = 'Account';
        processList.add(processRecord);

        SVMXC__ServiceMax_Processes__c outputDoc = new SVMXC__ServiceMax_Processes__c();
        outputDoc.SVMXC__Name__c = 'designer2TestOpdocProcess';
        outputDoc.SVMXC__ProcessID__c = 'designer2TestOpdocProcess';
        outputDoc.SVMXC__Purpose__c = 'OUTPUT DOCUMENT';
        outputDoc.SVMXC__Description__c = 'Test Opdoc Process';
        outputDoc.SVMXC__Dispatch_Process_Status__c = 'Complete';
        outputDoc.SVMXC__Doc_Template__c = docTemplate.Id;
        outputDoc.RecordTypeId = recordTypeIdMap.get('Target Manager');
        processList.add(outputDoc);

        SVMXC__ServiceMax_Processes__c checklist1 = new SVMXC__ServiceMax_Processes__c();
        checklist1.SVMXC__Name__c = 'designer2TestChecklistProcess';
        checklist1.SVMXC__ProcessID__c = 'designer2TestChecklistProcess';
        checklist1.SVMXC__Purpose__c = 'CHECKLIST';
        checklist1.SVMXC__Description__c = 'Test checklist Process';
        checklist1.SVMXC__Dispatch_Process_Status__c = 'Complete';
        checklist1.RecordTypeId = recordTypeIdMap.get('Target Manager');
        checklist1.SVMXC__Page_Layout__c = pageLayoutRecord.Id;
        processList.add(checklist1);

        SVMXC__ServiceMax_Processes__c lookupConfig = new SVMXC__ServiceMax_Processes__c();
        lookupConfig.SVMXC__Name__c = 'lookup Config Designer 2.0';
        lookupConfig.SVMXC__ProcessID__c = 'lookup_Config_Designer_2';
        lookupConfig.SVMXC__Rule_Type__c = 'SRCH_LOOKUP_CONFIG';
        lookupConfig.SVMXC__Source_Object_Name__c = 'Account';
        lookupConfig.SVMXC__Default_Lookup_Column__c = 'AccountNumber';
        lookupConfig.RecordTypeId = recordTypeIdMap.get('Named Search');
        lookupConfig.SVMXC__Number_of_Lookup_Records__c = 10;
        processList.add(lookupConfig);

        SVMXC__ServiceMax_Processes__c globalSettingInv = new SVMXC__ServiceMax_Processes__c();
        globalSettingInv.SVMXC__Setting_Type__c = 'Global';
        globalSettingInv.SVMXC__Submodule__c = globalModuleInv.Id;
        globalSettingInv.SVMXC__SettingID__c = 'Process_D2_SET025';
        globalSettingInv.RecordTypeId = recordTypeIdMap.get('Settings');
        processList.add(globalSettingInv);
        
        SVMXC__ServiceMax_Processes__c inventoryProcess = new SVMXC__ServiceMax_Processes__c();
        inventoryProcess.SVMXC__Name__c = 'Inventory Process D2';
        inventoryProcess.SVMXC__ProcessID__c = 'Inventory_Process_D2';
        inventoryProcess.RecordTypeId = recordTypeIdMap.get('Inventory Process');
        processList.add(inventoryProcess);
        
        insert processList;

        pageLayoutElementRecord.SVMXC__Named_Search__c = lookupConfig.Id;
        update pageLayoutElementRecord;
        SVMXC__SFM_Event__c eventAPIRecord = new SVMXC__SFM_Event__c();
        eventAPIRecord.SVMXC__Event_Call_Type__c = 'SFM TRIGGER';
        eventAPIRecord.SVMXC__Event_Type__c = 'Inventory Updates';
        eventAPIRecord.SVMXC__Namespace__c = 'SVMXC';
        eventAPIRecord.SVMXC__Class__c = 'SFM_InvtUpdOnWorkOrderClosure';
        eventAPIRecord.SVMXC__ServiceMax_Process__c = processRecord.Id;
        eventAPIRecord.SVMXC__ServiceMax_Custom_Action__c = inventoryProcess.Id;
        eventAPIRecord.SVMXC__Sequence__c = 1.00;
        insert eventAPIRecord;      
        
        processList = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c lookupfilter = new SVMXC__ServiceMax_Processes__c();
        lookupfilter.SVMXC__ProcessID__c = 'lookupFilterCriteria_2';

        lookupfilter.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
        lookupfilter.SVMXC__Source_Object_Name__c = 'Account';
        lookupfilter.SVMXC__Module__c = lookupConfig.Id;
        lookupfilter.RecordTypeId = recordTypeIdMap.get('Named Search');
        processList.add(lookupfilter);


        SVMXC__ServiceMax_Processes__c advancedFilter = new SVMXC__ServiceMax_Processes__c();
        advancedFilter.SVMXC__ProcessID__c = 'advancedFilterCriteria_2';
        advancedFilter.SVMXC__Name__c = 'contactFilter';
        advancedFilter.SVMXC__Rule_Type__c = 'SRCH_CRITERIA';
        advancedFilter.SVMXC__Source_Object_Name__c = 'Contact';
        advancedFilter.SVMXC__Advance_Expression__c = '1 AND 2';
        advancedFilter.SVMXC__Field_Name__c = 'AccountId';
        advancedFilter.SVMXC__Module__c = lookupConfig.Id;
        advancedFilter.RecordTypeId = recordTypeIdMap.get('Named Search');
        processList.add(advancedFilter);

        insert processList;


        List<SVMXC__ServiceMax_Processes__c> businessRuleList = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c businessRule = new SVMXC__ServiceMax_Processes__c();
        businessRule.SVMXC__Source_Object_Name__c = 'Case';
        businessRule.SVMXC__Name__c = 'validation Rule';
        businessRule.SVMXC__ProcessID__c = 'validationRule';
        //businessRule.SVMXC__Rule_Type__c = 'Field Update Rule';
        businessRule.RecordTypeId = recordTypeIdMap.get('Business Rule');
        businessRuleList.add(businessRule);

        SVMXC__ServiceMax_Processes__c QBValidationRule = new SVMXC__ServiceMax_Processes__c();
        QBValidationRule.SVMXC__Source_Object_Name__c = 'SVMXC__Checklist__c';
        QBValidationRule.SVMXC__Name__c = 'QB validation Rule';
        QBValidationRule.SVMXC__ProcessID__c = 'QBvalidationRule';
        QBValidationRule.RecordTypeId = recordTypeIdMap.get('Business Rule');
        businessRuleList.add(QBValidationRule);        
        SVMXC__ServiceMax_Processes__c businessRule1 = new SVMXC__ServiceMax_Processes__c();
        businessRule1.SVMXC__Source_Object_Name__c = 'Case';
        businessRule1.SVMXC__Name__c = 'validationRule D2';
        businessRule1.SVMXC__ProcessID__c = 'validationRule_D2';
        businessRule1.SVMXC__Rule_Type__c = 'Field Update Rule';
        businessRule1.RecordTypeId = recordTypeIdMap.get('Business Rule');
        businessRuleList.add(businessRule1);

        SVMXC__ServiceMax_Processes__c checklistExpressionRule1 = new SVMXC__ServiceMax_Processes__c();
        checklistExpressionRule1.SVMXC__Source_Object_Name__c = 'SVMXC__Checklist__c';
        checklistExpressionRule1.SVMXC__Rule_Type__c = 'Checklist Criteria in Output Doc';
        checklistExpressionRule1.RecordTypeId = recordTypeIdMap.get('Business Rule');
        checklistExpressionRule1.SVMXC__Question_Bank__c = qb1.Id;
        businessRuleList.add(checklistExpressionRule1);

        SVMXC__ServiceMax_Processes__c sectionExitCriteria = new SVMXC__ServiceMax_Processes__c();
        sectionExitCriteria.SVMXC__Source_Object_Name__c = 'SVMXC__Checklist__c';
        sectionExitCriteria.SVMXC__Rule_Type__c = 'Checklist_Section_Exit_Criteria';
        sectionExitCriteria.RecordTypeId = recordTypeIdMap.get('Business Rule');
        sectionExitCriteria.SVMXC__Question_Bank__c = qb1.Id;
        businessRuleList.add(sectionExitCriteria);
        SVMXC__ServiceMax_Processes__c sectionEntryCriteria = new SVMXC__ServiceMax_Processes__c();
        sectionEntryCriteria.SVMXC__Name__c = 'Entry Criteria D2';
        sectionEntryCriteria.SVMXC__Source_Object_Name__c = 'Account';
        sectionEntryCriteria.SVMXC__Rule_Type__c = 'Checklist_Section_Entry_Criteria';
        sectionEntryCriteria.RecordTypeId = recordTypeIdMap.get('Business Rule');
        businessRuleList.add(sectionEntryCriteria);        
        SVMXC__ServiceMax_Processes__c expressionRecord = new SVMXC__ServiceMax_Processes__c();
        expressionRecord.SVMXC__Name__c = 'Test Expression D2';
        expressionRecord.SVMXC__Rule_Type__c = 'Named Expression';
        expressionRecord.SVMXC__ProcessID__c = 'Test_Expression_D2';
        expressionRecord.SVMXC__Source_Object_Name__c = 'Account';
        expressionRecord.RecordTypeId = recordTypeIdMap.get('SVMX Rule');
        expressionRecord.SVMXC__SettingID__c = '_Test_Expression_D2';
        expressionRecord.SVMXC__Parent_Error_Msg__c = 'Designer 2.0 Error';
        businessRuleList.add(expressionRecord);

        SVMXC__ServiceMax_Processes__c mappingRecord = new SVMXC__ServiceMax_Processes__c();
        mappingRecord.SVMXC__Name__c = 'Test Mapping D2';
        mappingRecord.SVMXC__MapID__c = 'Test_Mapping_D2';
        mappingRecord.RecordTypeId = recordTypeIdMap.get('Object Mapping');
        mappingRecord.SVMXC__Source_Object_Name__c = 'SVMXC__TaskTemplate__c';
        mappingRecord.SVMXC__Target_Object_Name__c = 'Task';
        mappingRecord.SVMXC__Active__c = true;


        businessRuleList.add(mappingRecord);


        insert businessRuleList;

        SVMXC__ServiceMax_Processes__c nodeRecord1 = new SVMXC__ServiceMax_Processes__c();
        nodeRecord1.SVMXC__Source_Object_Name__c = 'Account';
        nodeRecord1.SVMXC__Target_Object_label__c = 'Account';
        nodeRecord1.SVMXC__Type__c = 'SOURCE';
        nodeRecord1.RecordTypeId = recordTypeIdMap.get('Process Node Objects');
        nodeRecord1.SVMXC__Process__c = processRecord.Id;
        nodeRecord1.SVMXC__Sequence__c = 0;
        nodeRecordsList1.add(nodeRecord1);

        SVMXC__ServiceMax_Processes__c nodeRecord2 = new SVMXC__ServiceMax_Processes__c();
        nodeRecord2.SVMXC__Node_Source_Object_API__c = 'Account';
        nodeRecord2.SVMXC__Source_Object_Name__c = 'Contact';
        nodeRecord2.SVMXC__Target_Object_label__c = 'Contact';
        nodeRecord2.SVMXC__Type__c = 'TARGET';
        nodeRecord2.SVMXC__Enable_Attachment__c = true;
        nodeRecord2.RecordTypeId = recordTypeIdMap.get('Process Node Objects');
        nodeRecord2.SVMXC__Submodule__c = expressionRecord.Id;
        nodeRecord2.SVMXC__Module__c = mappingRecord.Id;
        nodeRecord2.SVMXC__Final_Exception_Process__c = mappingRecord.Id;
        nodeRecord2.SVMXC__Sequence__c = 0;
        nodeRecord2.SVMXC__Process__c = processRecord.Id;
        nodeRecord2.SVMXC__Values__c = '{"lstSortingRec":[{"sortingOrder":"ASC","fieldAPIName":"Name","queryField":"Name","dataType":"String"}]}';
        nodeRecordsList1.add(nodeRecord2);

        SVMXC__ServiceMax_Processes__c checklistnode = new SVMXC__ServiceMax_Processes__c();
        checklistnode.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        checklistnode.SVMXC__Target_Object_label__c = 'Work Order';
        checklistnode.SVMXC__Type__c = 'SOURCE';
        checklistnode.RecordTypeId = recordTypeIdMap.get('Process Node Objects');
        checklistnode.SVMXC__Process__c = checklist1.Id;
        nodeRecordsList1.add(checklistnode);

        SVMXC__ServiceMax_Processes__c checklistnode1 = new SVMXC__ServiceMax_Processes__c();
        checklistnode1.SVMXC__Source_Object_Name__c = 'SVMXC__Checklist__c';
        checklistnode1.SVMXC__Target_Object_label__c = 'Checklist';
        checklistnode1.SVMXC__Type__c = 'TARGET';
        checklistnode1.RecordTypeId = recordTypeIdMap.get('Process Node Objects');
        checklistnode1.SVMXC__Process__c = checklist1.Id;
        nodeRecordsList1.add(checklistnode1);

        SVMXC__ServiceMax_Processes__c opdocChecklist1 = new SVMXC__ServiceMax_Processes__c();
        opdocChecklist1.SVMXC__Process1__c = outputDoc.Id;
        opdocChecklist1.SVMXC__Process2__c = checklist1.Id;
        opdocChecklist1.SVMXC__SM_Checklist_Version__c = 'All Versions';
        opdocChecklist1.RecordTypeId = recordTypeIdMap.get('Checklist Smart Doc');
        nodeRecordsList1.add(opdocChecklist1);


        SVMXC__ServiceMax_Processes__c opdocChecklistRule1 = new SVMXC__ServiceMax_Processes__c();
        opdocChecklistRule1.SVMXC__Process1__c = outputDoc.Id;
        opdocChecklistRule1.SVMXC__Process2__c = checklist1.Id;
        opdocChecklistRule1.SVMXC__Process3__c = checklistExpressionRule1.Id;
        opdocChecklistRule1.RecordTypeId = recordTypeIdMap.get('Process Business Rule');
        opdocChecklistRule1.SVMXC__Rule_Type__c = 'Checklist Criteria in Output Doc';

        nodeRecordsList1.add(opdocChecklistRule1);

        SVMXC__ServiceMax_Processes__c sectionEntryCriteriaJunction = new SVMXC__ServiceMax_Processes__c();
        sectionEntryCriteriaJunction.SVMXC__Process1__c = checklist1.Id;
        sectionEntryCriteriaJunction.SVMXC__SM_Section__c = pageLayoutSectionRecord.Id;
        sectionEntryCriteriaJunction.SVMXC__Process3__c = sectionEntryCriteria.Id;
        sectionEntryCriteriaJunction.RecordTypeId = recordTypeIdMap.get('Process Business Rule');
        sectionEntryCriteriaJunction.SVMXC__Rule_Type__c = 'Checklist_Section_Entry_Criteria';
        nodeRecordsList1.add(sectionEntryCriteriaJunction);      
        SVMXC__ServiceMax_Processes__c sectionExitCriteriaJunction = new SVMXC__ServiceMax_Processes__c();
        sectionExitCriteriaJunction.SVMXC__Process1__c = checklist1.Id;
        sectionExitCriteriaJunction.SVMXC__SM_Section__c = pageLayoutSectionRecord.Id;
        sectionExitCriteriaJunction.SVMXC__Process3__c = sectionExitCriteria.Id;
        sectionExitCriteriaJunction.RecordTypeId = recordTypeIdMap.get('Process Business Rule');
        sectionExitCriteriaJunction.SVMXC__Rule_Type__c = 'Checklist_Section_Exit_Criteria';
        nodeRecordsList1.add(sectionExitCriteriaJunction);             
        SVMXC__ServiceMax_Processes__c qbValidationJunction = new SVMXC__ServiceMax_Processes__c();
        qbValidationJunction.SVMXC__Process1__c = QBValidationRule.Id;
        qbValidationJunction.SVMXC__Question_Bank__c = qb1.Id;
        qbValidationJunction.RecordTypeId = recordTypeIdMap.get('QB Validation');
        nodeRecordsList1.add(qbValidationJunction);     
        insert nodeRecordsList1;

        nodeRecord2.SVMXC__Parent_Object__c = nodeRecord1.Id;

        nodeRecordsList.add(nodeRecord2);

        SVMXC__ServiceMax_Processes__c woBillingProcess = new SVMXC__ServiceMax_Processes__c();
        woBillingProcess.SVMXC__Name__c = 'Work Order Proforma Invoice';
        woBillingProcess.SVMXC__ProcessID__c = 'Work_Order_Proforce_Invoice';
        woBillingProcess.RecordTypeId = recordTypeIdMap.get('Work Order Billing Process');
        woBillingProcess.SVMXC__Submodule__c = expressionRecord.Id;
        woBillingProcess.SVMXC__Module__c = expressionRecord.Id;
        woBillingProcess.SVMXC__Invoice_Scope__c = 'Case';
        nodeRecordsList.add(woBillingProcess);

        SVMXC__ServiceMax_Processes__c contractBillingProcess = new SVMXC__ServiceMax_Processes__c();
        contractBillingProcess.SVMXC__Name__c = 'Scon Proforma Invoice Process';
        contractBillingProcess.SVMXC__ProcessID__c = 'Scon_Proforma_Invoice_Process';
        contractBillingProcess.RecordTypeId = recordTypeIdMap.get('Contract Billing Process');
        contractBillingProcess.SVMXC__Module__c = expressionRecord.Id;
        contractBillingProcess.SVMXC__Primary_Consolidation_Rule__c = 'Contract';
        nodeRecordsList.add(contractBillingProcess);


        SVMXC__ServiceMax_Processes__c pmProcess = new SVMXC__ServiceMax_Processes__c();
        pmProcess.SVMXC__Name__c = 'Preventive Maintenance Process';
        pmProcess.SVMXC__ProcessID__c = 'Preventive_Maintenance_Process';
        pmProcess.RecordTypeId = recordTypeIdMap.get('PM Process');
        pmProcess.SVMXC__Module__c = expressionRecord.Id;
        pmProcess.SVMXC__Create_Work_Order__c = 'One Per Product';
        pmProcess.SVMXC__SM_Process_Type__c = 'TIME_BASED_PM';
        pmProcess.SVMXC__Process__c = mappingRecord.Id;
        pmProcess.SVMXC__Process1__c = mappingRecord.Id;
        pmProcess.SVMXC__Process2__c = mappingRecord.Id;
        pmProcess.SVMXC__Process3__c = mappingRecord.Id;
        pmProcess.SVMXC__Submodule__c = mappingRecord.Id;
        pmProcess.SVMXC__Node_Parent__c = mappingRecord.Id;
        nodeRecordsList.add(pmProcess);


        pageLayoutElementRecord.SVMXC__Field_Mapping__c = mappingRecord.Id;
        update pageLayoutElementRecord;

        SVMXC__ServiceMax_Processes__c spmRule = new SVMXC__ServiceMax_Processes__c();
        spmRule.SVMXC__Name__c = 'First Time Fix';
        spmRule.SVMXC__ProcessID__c = 'FirstTimeFix';
        spmRule.RecordTypeId = recordTypeIdMap.get('SPM Rule');
        nodeRecordsList.add(spmRule);


        SVMXC__ServiceMax_Processes__c linkedProcess = new SVMXC__ServiceMax_Processes__c();
        linkedProcess.SVMXC__Process1__c = processRecord.Id;
        linkedProcess.SVMXC__Process2__c = nodeRecord2.Id;
        linkedProcess.SVMXC__Process3__c = processRecord.Id;
        linkedProcess.SVMXC__Sequence__c = 1;
        linkedProcess.RecordTypeId = recordTypeIdMap.get('Linked Process');
        linkedProcess.SVMXC__Name__c = 'Linked SFM';
        nodeRecordsList.add(linkedProcess);

        SVMXC__ServiceMax_Processes__c validationRule = new SVMXC__ServiceMax_Processes__c();
        validationRule.SVMXC__Process1__c = processRecord.Id;
        validationRule.SVMXC__Process2__c = nodeRecord2.Id;
        validationRule.SVMXC__Process3__c = businessRule.Id;
        validationRule.SVMXC__Sequence__c = 1;
        validationRule.RecordTypeId = recordTypeIdMap.get('Process Business Rule');
        nodeRecordsList.add(validationRule);

        SVMXC__ServiceMax_Processes__c formula = new SVMXC__ServiceMax_Processes__c();
        formula.SVMXC__Process1__c = processRecord.Id;
        formula.SVMXC__Process2__c = nodeRecord2.Id;
        formula.SVMXC__Process3__c = businessRule1.Id;
        formula.SVMXC__Sequence__c = 1;

        formula.RecordTypeId = recordTypeIdMap.get('Process Business Rule');
        nodeRecordsList.add(formula);

        SVMXC__ServiceMax_Processes__c customAction = new SVMXC__ServiceMax_Processes__c();
        customAction.SVMXC__Name__c = 'Designer 2 Custom Action';
        customAction.SVMXC__ProcessID__c = 'Designer_2_Custom_Action';
        customAction.SVMXC__Source_Object_Name__c = 'Account';
        customAction.RecordTypeId = recordTypeIdMap.get('SF Action');
        nodeRecordsList.add(customAction);

        SVMXC__ServiceMax_Config_Data__c profileData = new SVMXC__ServiceMax_Config_Data__c();
        profileData.SVMXC__Configuration_Type__c = 'Global';
        profileData.RecordTypeId = recordTypeIdMap.get('Configuration Profile');
        profileData.SVMXC__Active__c = true;
        profileData.SVMXC__Profile_Name__c = 'Global Profile D2';
        insert profileData;
        
        List<SVMXC__ServiceMax_Config_Data__c> configRecList = new List<SVMXC__ServiceMax_Config_Data__c>();

        SVMXC__ServiceMax_Config_Data__c expressionDetail1 = new SVMXC__ServiceMax_Config_Data__c();
        expressionDetail1.SVMXC__Field_Name__c = 'Name';
        expressionDetail1.SVMXC__Operator__c = 'isnotnull';
        expressionDetail1.SVMXC__Sequence__c = 1;
        expressionDetail1.SVMXC__Operand__c = '';
        expressionDetail1.SVMXC__Expression_Rule__c = expressionRecord.Id;
        expressionDetail1.RecordTypeId = recordTypeIdMap.get('Expressions');
        configRecList.add(expressionDetail1);

        SVMXC__ServiceMax_Config_Data__c expressionDetail2 = new SVMXC__ServiceMax_Config_Data__c();
        expressionDetail2.SVMXC__Field_Name__c = 'Name';
        expressionDetail2.SVMXC__Operator__c = 'eq';
        expressionDetail2.SVMXC__Sequence__c = 2;
        expressionDetail2.SVMXC__Parameter_Type__c = 'Constant';
        expressionDetail2.SVMXC__Operand__c = SFM_Consts.SVMX_CURRENT_RECORD + '.Name';
        expressionDetail2.SVMXC__Expression_Rule__c = expressionRecord.Id;
        expressionDetail2.RecordTypeId = recordTypeIdMap.get('Expressions');
        configRecList.add(expressionDetail2);

        SVMXC__ServiceMax_Config_Data__c expressionDetail3 = new SVMXC__ServiceMax_Config_Data__c();
        expressionDetail3.SVMXC__Field_Name__c = 'SicDesc';
        expressionDetail3.SVMXC__Operator__c = 'eq';
        expressionDetail3.SVMXC__Sequence__c = 3;
        expressionDetail3.SVMXC__Parameter_Type__c = 'Constant';
        expressionDetail3.SVMXC__Operand__c = SFM_Consts.SVMX_USERTRUNK;
        expressionDetail3.SVMXC__Expression_Rule__c = expressionRecord.Id;
        expressionDetail3.RecordTypeId = recordTypeIdMap.get('Expressions');
        configRecList.add(expressionDetail3);


        SVMXC__ServiceMax_Config_Data__c expressionDetail4 = new SVMXC__ServiceMax_Config_Data__c();
        expressionDetail4.SVMXC__Field_Name__c = 'CreatedBy';
        expressionDetail4.SVMXC__Operator__c = 'eq';
        expressionDetail4.SVMXC__Sequence__c = 1;
        expressionDetail4.SVMXC__Parameter_Type__c = 'Constant';
        expressionDetail4.SVMXC__Operand__c = 'test';
        expressionDetail4.SVMXC__Expression_Rule__c = expressionRecord.Id;
        expressionDetail4.RecordTypeId = recordTypeIdMap.get('Expressions');
        configRecList.add(expressionDetail4);

        SVMXC__ServiceMax_Config_Data__c entryCriteriaRow = new SVMXC__ServiceMax_Config_Data__c();
        entryCriteriaRow.SVMXC__Field_Name__c = 'SVMXC__Company__c';
        entryCriteriaRow.SVMXC__Display_Type__c = 'REFERENCE';
        entryCriteriaRow.SVMXC__Operator__c = 'eq';
        entryCriteriaRow.SVMXC__Sequence__c = 1;
        entryCriteriaRow.SVMXC__Parameter_Type__c = 'Value';
        entryCriteriaRow.SVMXC__Operand__c = 'test';
        entryCriteriaRow.SVMXC__Expression_Rule__c = sectionEntryCriteria.Id;
        entryCriteriaRow.RecordTypeId = recordTypeIdMap.get('Expressions');
        entryCriteriaRow.SVMXC__Expression_Type__c = 'Business_Rule';
        configRecList.add(entryCriteriaRow);

        SVMXC__ServiceMax_Config_Data__c checklistExpressionRow1 = new SVMXC__ServiceMax_Config_Data__c();
        checklistExpressionRow1.SVMXC__Field_Name__c = 'testqb0002';
        checklistExpressionRow1.SVMXC__Display_Type__c = 'checkbox';
        checklistExpressionRow1.SVMXC__Operator__c = 'eq';
        checklistExpressionRow1.SVMXC__Sequence__c = 3;
        checklistExpressionRow1.SVMXC__Parameter_Type__c = 'Value';
        checklistExpressionRow1.SVMXC__Operand__c = 'test';
        checklistExpressionRow1.SVMXC__Expression_Rule__c = checklistExpressionRule1.Id;
        checklistExpressionRow1.RecordTypeId = recordTypeIdMap.get('Expressions');
        checklistExpressionRow1.SVMXC__Expression_Type__c = 'Business_Rule';
        configRecList.add(checklistExpressionRow1);

        SVMXC__ServiceMax_Config_Data__c sourceUpdate = new SVMXC__ServiceMax_Config_Data__c();
        sourceUpdate.SVMXC__Configuration_Type__c = 'Source Update';
        sourceUpdate.SVMXC__Action__c = 'Set';
        sourceUpdate.SVMXC__Dispatch_Process__c = processRecord.Id;
        sourceUpdate.SVMXC__Source_Field_Name__c = 'Type';
        sourceUpdate.SVMXC__MapID__c = nodeRecord1.Id;
        sourceUpdate.RecordTypeId = recordTypeIdMap.get('Field Mapping');
        sourceUpdate.SVMXC__Setting_ID__c = nodeRecord2.Id;
        sourceUpdate.SVMXC__Action_Type__c = 'Set Value';
        sourceUpdate.SVMXC__Display_Value__c = 'Prospect';
        sourceUpdate.SVMXC__MapID__c = nodeRecord1.Id;
        sourceUpdate.SVMXC__Setting_ID__c = nodeRecord2.Id;
        configRecList.add(sourceUpdate);

        SVMXC__ServiceMax_Config_Data__c sourceUpdate1 = new SVMXC__ServiceMax_Config_Data__c();
        sourceUpdate1.SVMXC__Configuration_Type__c = 'Source Update';
        sourceUpdate1.SVMXC__Action__c = 'Set';
        sourceUpdate1.SVMXC__Dispatch_Process__c = processRecord.Id;
        sourceUpdate1.SVMXC__Source_Field_Name__c = 'Industry';
        sourceUpdate1.SVMXC__MapID__c = nodeRecord1.Id;
        sourceUpdate1.RecordTypeId = recordTypeIdMap.get('Field Mapping');
        sourceUpdate1.SVMXC__Setting_ID__c = nodeRecord2.Id;
        sourceUpdate1.SVMXC__Action_Type__c = 'Set Value';
        sourceUpdate1.SVMXC__Target_Field_Name__c = 'LeadSource';
        sourceUpdate.SVMXC__MapID__c = nodeRecord1.Id;
        sourceUpdate.SVMXC__Setting_ID__c = nodeRecord2.Id;
        configRecList.add(sourceUpdate1);

        SVMXC__ServiceMax_Config_Data__c configProfile = new SVMXC__ServiceMax_Config_Data__c();
        configProfile.SVMXC__Configuration_Type__c = 'Group';
        configProfile.SVMXC__Profile_Name__c = 'Test Profile';
        configProfile.RecordTypeId = recordTypeIdMap.get('Configuration Profile');
        configRecList.add(configProfile);

        SVMXC__ServiceMax_Config_Data__c spmDetails = new SVMXC__ServiceMax_Config_Data__c();
        spmDetails.SVMXC__Dispatch_Process__c = spmRule.Id;
        spmDetails.SVMXC__Formula__c = '{"expressionDetailsList":[{"expressionRuleId":"' + expressionRecord.SVMXC__ProcessID__c + '","expressionType":"QualificationCriteria"}]}';
        spmDetails.RecordTypeId = recordTypeIdMap.get('SPM Details');
        configRecList.add(spmDetails);


        SVMXC__SM_Device_Mobile_Config__c deviceMobileConfig = new SVMXC__SM_Device_Mobile_Config__c(SVMXC__SM_Name__c = 'Test D2 Device Config', SVMXC__SM_Device_Type__c = 'iPad; iPhone; Android Tablet; Android Phone; Windows');
        insert deviceMobileConfig;

        SVMXC__ServiceMax_Config_Data__c mobileConfig = new SVMXC__ServiceMax_Config_Data__c();
        mobileConfig.SVMXC__Dispatch_Process__c = expressionRecord.Id;
        mobileConfig.RecordTypeId = recordTypeIdMap.get('Mobile Configuration');
        mobileConfig.SVMXC__Object_Name__c = 'Account';
        mobileConfig.SVMXC__Display_Type__c = 'Download Criteria';
        mobileConfig.SVMXC__SM_Device_Mobile_Config__c = deviceMobileConfig.Id;
        configRecList.add(mobileConfig);

        //Mapping Details
        SVMXC__ServiceMax_Config_Data__c mappingDetail = new SVMXC__ServiceMax_Config_Data__c();
        mappingDetail.RecordTypeId = recordTypeIdMap.get('Field Mapping');
        mappingDetail.SVMXC__Configuration_Type__c = 'Field Mapping';
        mappingDetail.SVMXC__Action_Type__c = 'Set Value';
        //mappingDetail.SVMXC__Display_Map_ID__c = 'Tast_Template_D2';
        mappingDetail.SVMXC__Source_Field_Name__c = 'SVMXC__Description__c';
        mappingDetail.SVMXC__Target_Field_Name__c = 'Description';
        mappingDetail.SVMXC__MapID__c = mappingRecord.Id;
        configRecList.add(mappingDetail);

        SVMXC__ServiceMax_Config_Data__c mappingDetail1 = new SVMXC__ServiceMax_Config_Data__c();
        mappingDetail1.RecordTypeId = recordTypeIdMap.get('Field Mapping');
        mappingDetail1.SVMXC__Configuration_Type__c = 'Field Mapping';
        mappingDetail1.SVMXC__Action_Type__c = 'Set Value';
        //mappingDetail1.SVMXC__Display_Map_ID__c = 'Tast_Template_D2';
        mappingDetail1.SVMXC__Source_Field_Name__c = 'SVMXC__Priority__c';
        mappingDetail1.SVMXC__Target_Field_Name__c = 'Priority';
        mappingDetail1.SVMXC__MapID__c = mappingRecord.Id;
        configRecList.add(mappingDetail1);

        SVMXC__ServiceMax_Config_Data__c mappingDetail2 = new SVMXC__ServiceMax_Config_Data__c();
        mappingDetail2.RecordTypeId = recordTypeIdMap.get('Field Mapping');
        mappingDetail2.SVMXC__Configuration_Type__c = 'Field Mapping';
        mappingDetail2.SVMXC__Action_Type__c = 'Set Value';
        //mappingDetail1.SVMXC__Display_Map_ID__c = 'Tast_Template_D2';
        mappingDetail2.SVMXC__Display_Value__c = 'High';
        mappingDetail2.SVMXC__Target_Field_Name__c = 'Priority';
        mappingDetail2.SVMXC__MapID__c = mappingRecord.Id;
        mappingDetail2.SVMXC__Display_Value__c = 'SVMX.CURRENTRECORD.SVMXC_company_c';
        configRecList.add(mappingDetail2);

        SVMXC__ServiceMax_Config_Data__c inventoryGlobalSetting = new SVMXC__ServiceMax_Config_Data__c();
        inventoryGlobalSetting.RecordTypeId = recordTypeIdMap.get('Setting Value');
        inventoryGlobalSetting.SVMXC__Setting_ID__c = globalSettingInv.Id;
        inventoryGlobalSetting.SVMXC__Internal_Value__c = 'SVMXC__Service_Order__c';
        inventoryGlobalSetting.SVMXC__Setting_Configuration_Profile__c = profileData.Id;
        configRecList.add(inventoryGlobalSetting);
        
        SVMXC__ServiceMax_Processes__c wizard = new SVMXC__ServiceMax_Processes__c();
        wizard.SVMXC__Name__c = 'Test Wizard';
        wizard.SVMXC__ProcessID__c = 'Test_Wizard_Process_Id';
        wizard.RecordTypeId = recordTypeIdMap.get('Wizard');
        wizard.SVMXC__Submodule__c = expressionRecord.Id;
        insert wizard;

        for(integer i=0;i<2;i++){
            SVMXC__ServiceMax_Processes__c wizardStep = new SVMXC__ServiceMax_Processes__c();
            wizardStep.SVMXC__Process__c = processRecord.Id;
            wizardStep.RecordTypeId = recordTypeIdMap.get('Wizard Step');
            wizardStep.SVMXC__Submodule__c = expressionRecord.Id;
            wizardStep.SVMXC__Module__c = wizard.Id;
            nodeRecordsList.add(wizardStep);
        }

        for(integer i=0;i<2;i++){
            SVMXC__ServiceMax_Processes__c linkedSFM = new SVMXC__ServiceMax_Processes__c();
            linkedSFM.SVMXC__Process1__c = processRecord.Id;
            linkedSFM.SVMXC__Process3__c = processRecord.Id;
            linkedSFM.RecordTypeId = recordTypeIdMap.get('Linked Process');
            nodeRecordsList.add(linkedSFM);
        }

        for(integer i=0;i<2;i++){
            SVMXC__ServiceMax_Processes__c multiSrcConfig = new SVMXC__ServiceMax_Processes__c();
            multiSrcConfig.SVMXC__Name__c = 'designer2multiSrcProcess' + i;
            multiSrcConfig.SVMXC__ProcessID__c = 'designer2multiSrcProcess' + i;
            multiSrcConfig.SVMXC__Purpose__c = 'SOURCE TO TARGET CHILD';
            multiSrcConfig.SVMXC__Dispatch_Process_Status__c = 'Complete';
            multiSrcConfig.SVMXC__Process2__c = processRecord.Id;
            multiSrcConfig.RecordTypeId = recordTypeIdMap.get('Target Manager');
            nodeRecordsList.add(multiSrcConfig);
        }



        upsert nodeRecordsList;

        //List<SVMXC__ServiceMax_Config_Data__c> scheduleList = new List<SVMXC__ServiceMax_Config_Data__c>();
        for(integer i=0;i<2;i++){
            SVMXC__ServiceMax_Config_Data__c scheduleSFM = new SVMXC__ServiceMax_Config_Data__c();
            scheduleSFM.SVMXC__Expression_Rule__c = processRecord.Id;
            scheduleSFM.RecordTypeId = recordTypeIdMap.get('Schedule Detail');
            configRecList.add(scheduleSFM);
        }


        SVMXC__ServiceMax_Config_Data__c filterExp1 = new SVMXC__ServiceMax_Config_Data__c();
        filterExp1.RecordTypeId = recordTypeIdMap.get('Expressions');
        filterExp1.SVMXC__Expression_Rule__c = lookupfilter.Id;
        filterExp1.SVMXC__Field_Name__c = 'Name';
        filterExp1.SVMXC__Parameter_Type__c = 'Value';
        filterExp1.SVMXC__Expression_Type__c = 'LKUP_Prefilter_Criteria';
        filterExp1.SVMXC__Sequence__c = 1.00;
        filterExp1.SVMXC__Operator__c = 'isnotnull';
        configRecList.add(filterExp1);

        SVMXC__ServiceMax_Config_Data__c filterExp2 = new SVMXC__ServiceMax_Config_Data__c();
        filterExp2.RecordTypeId = recordTypeIdMap.get('Expressions');
        filterExp2.SVMXC__Expression_Rule__c = lookupfilter.Id;
        filterExp2.SVMXC__Field_Name__c = 'Name';
        filterExp2.SVMXC__Expression_Type__c = 'LSRCH_Object_Fields';
        filterExp2.SVMXC__Sequence__c = 1.00;
        filterExp2.SVMXC__Search_Object_Field_Type__c = 'Result';
        configRecList.add(filterExp2);


        SVMXC__ServiceMax_Config_Data__c advFilterExp1 = new SVMXC__ServiceMax_Config_Data__c();
        advFilterExp1.RecordTypeId = recordTypeIdMap.get('Expressions');
        advFilterExp1.SVMXC__Expression_Rule__c = advancedFilter.Id;
        advFilterExp1.SVMXC__Field_Name__c = 'FirstName';
        advFilterExp1.SVMXC__Expression_Type__c = 'LKUP_Prefilter_Criteria';
        advFilterExp1.SVMXC__Parameter_Type__c = 'Value';
        advFilterExp1.SVMXC__Sequence__c = 1.00;
        advFilterExp1.SVMXC__Operand__c = 'SVMXC';
        advFilterExp1.SVMXC__Operator__c = 'eq';

        configRecList.add(advFilterExp1);

        SVMXC__ServiceMax_Config_Data__c advFilterExp2 = new SVMXC__ServiceMax_Config_Data__c();
        advFilterExp2.RecordTypeId = recordTypeIdMap.get('Expressions');
        advFilterExp2.SVMXC__Expression_Rule__c = advancedFilter.Id;
        advFilterExp2.SVMXC__Field_Name__c = 'Email';
        advFilterExp2.SVMXC__Expression_Type__c = 'LKUP_Prefilter_Criteria';
        advFilterExp2.SVMXC__Parameter_Type__c = 'Value';
        advFilterExp2.SVMXC__Sequence__c = 2.00;
        advFilterExp2.SVMXC__Operand__c = 'SVMXC@testemail.com';
        advFilterExp2.SVMXC__Operator__c = 'eq';

        configRecList.add(advFilterExp2);

        insert configRecList;

        List<SVMXC__SM_Tag_Definition__c> defList = new List<SVMXC__SM_Tag_Definition__c>();
        SVMXC__SM_Tag_Definition__c tagDef1 = new SVMXC__SM_Tag_Definition__c(Name ='Designer2');
        SVMXC__SM_Tag_Definition__c tagDef2 = new SVMXC__SM_Tag_Definition__c(Name = 'SFM');

        defList.add(tagDef1);
        defList.add(tagDef2);
        insert defList;

        List<SVMXC__SM_Tag_Element__c> tagList = new List<SVMXC__SM_Tag_Element__c>();
        SVMXC__SM_Tag_Element__c tag1 = new SVMXC__SM_Tag_Element__c(SVMXC__SM_Tag_Definition__c = tagDef1.Id,
                                                                        SVMXC__SM_Target_Object__c = processRecord.Id);
        SVMXC__SM_Tag_Element__c tag2 = new SVMXC__SM_Tag_Element__c(SVMXC__SM_Tag_Definition__c = tagDef2.Id,
                                                                        SVMXC__SM_Target_Object__c = processRecord.Id);
        tagList.add(tag1);
        tagList.add(tag2);
        insert tagList;


        SVMXC__ProductIQProfile__c productIQProfile = new SVMXC__ProductIQProfile__c();
        productIQProfile.SVMXC__ServiceMax_Profile__c = configProfile.Id;
        productIQProfile.SVMXC__Contents__c = '{"ibEditProces":[{"sfdcId":"' + processRecord.Id + '","processName":"' + processRecord.SVMXC__Name__c + '","processId":"' + processRecord.SVMXC__ProcessID__c + '"}]}';
        insert productIQProfile;

        SVMXC__Code_Snippet__c codeSnippet = new SVMXC__Code_Snippet__c();
        codeSnippet.SVMXC__SnippetId__c = 'CodeXXXXXX0001';
        codeSnippet.SVMXC__Name__c = 'Test Snippet';
        insert codeSnippet;

        SVMXC__Function_Definition__c designerFunction = new SVMXC__Function_Definition__c();
        designerFunction.SVMXC__IsActive__c = true;
        designerFunction.SVMXC__Macro_Name__c = 'Designer Macro';
        designerFunction.SVMXC__Syntax__c = '$F.YESTERDAY() - 1';
        designerFunction.SVMXC__Example__c = '$F.YESTERDAY() - 1';
        designerFunction.SVMXC__Type__c = 'Date';
        designerFunction.SVMXC__SM_Entity_Type__c = 'OPDOC';
        insert designerFunction;

        Document doc = new Document();
        doc.Name = 'Designer Logo'; 
        doc.ContentType = 'Image/png';
        doc.Keywords = 'SFM_OUTPUT_DOCUMENT';
        doc.DeveloperName = 'Designer_Logo';
        doc.FolderId = [SELECT Id FROM Folder WHERE Name = 'ServiceMax Documents'].Id;
        insert doc;

        SVMXC__ServiceMax_Tags__c serviceMaxTags = new SVMXC__ServiceMax_Tags__c();
        serviceMaxTags.SVMXC__Tag_Key__c = 'DESIGNER2TESTPROCESS';
        serviceMaxTags.SVMXC__Tag_Value__c = 'designer2TestProcess';
        serviceMaxTags.SVMXC__Tag_Context__c = 'SFM_PROCESS_NAME';
        serviceMaxTags.SVMXC__Language__c = 'Master';
        serviceMaxTags.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(UserInfo.getOrganizationId().subString(0,15)));
        insert serviceMaxTags;

    }



    Static void restUtils(String endPointUrl, String httpMethod, String serializedRequest){
        req = new RestRequest();
        res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/svmx/rest/SFMDesigner2ServiceIntf/' + endPointUrl + '/';
        System.debug(loggingLevel.Info , 'URL ' + req.requestURI);
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = httpMethod;
        req.requestBody = Blob.valueOf(serializedRequest);
        RestContext.request = req;
        RestContext.response = res;
    }

    Static testMethod void test_retrieveTags(){
        restUtils('retrieveDisplayTags', 'GET', '');
        test.startTest();
        SFMDesigner2ServiceIntf.doGet();
        test.stopTest();

        System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }

    Static testMethod void test_listOfProcesses(){

        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        request.entityType = SFM_DesignerUtils.entity_sfm;
        String serializedRequest = JSON.serialize(request);
        restUtils('listOfProcesses', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPOST();
        request.entityType = SFM_DesignerUtils.entity_opdoc;
        serializedRequest = JSON.serialize(request);
        restUtils('listOfProcesses', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPOST();
        request.entityType = SFM_DesignerUtils.entity_checklist;
        serializedRequest = JSON.serialize(request);
        restUtils('listOfProcesses', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPOST();
        test.stopTest();
    }

    Static testMethod void test_userInfo() {

        restUtils('userInfo', 'GET', '');
        test.startTest();
        SFMDesigner2ServiceIntf.doGet();
        test.stopTest();
    }

    Static testMethod void test_getSettingInfo(){
        restUtils('getSettingInfo', 'GET', '');
        test.startTest();
        SFMDesigner2ServiceIntf.doGet();
        test.stopTest();
    }

    Static testMethod void test_getWhereUserInfo(){
        SVMXC__ServiceMax_Processes__c processRecord = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Name__c = 'designer2TestProcess' AND RecordType.Name = 'Target Manager' limit 1];
        Set<String> processIds = new Set<String>{processRecord.Id};
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        request.entityids = new List<String>(processIds);
        request.entityType = SFM_DesignerUtils.entity_sfm;
        String serializedRequest = JSON.serialize(request);
        restUtils('whereUsed', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();

        processRecord = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Name__c = 'Test Expression D2' AND RecordType.Name = 'SVMX Rule' limit 1];
        processIds = new Set<String>{processRecord.Id};
        request.entityids = new List<String>(processIds);
        request.entityType = SFM_DesignerUtils.entity_expression;
        serializedRequest = JSON.serialize(request);
        restUtils('whereUsed', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        processIds.clear();
        for(SVMXC__ServiceMax_Processes__c processItrRec : [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Rule_Type__c = '' AND RecordType.Name = 'Business Rule']){
            processIds.add(processItrRec.Id);
        }
        request.entityids = new List<String>(processIds);
        request.entityType = SFM_DesignerUtils.entity_businessrule;
        serializedRequest = JSON.serialize(request);
        restUtils('whereUsed', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();


        processIds.clear();
        processRecord = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name = 'Object Mapping' LIMIT 1];
        processIds = new Set<String>{processRecord.Id};
        request.entityids = new List<String>(processIds);
        request.entityType = SFM_DesignerUtils.entity_mapping;
        serializedRequest = JSON.serialize(request);
        restUtils('whereUsed', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        processIds.clear();
        SVMXC__Page_Layout__c pageLayoutRecord = [SELECT Id FROM SVMXC__Page_Layout__c WHERE SVMXC__Name__c = 'SVMXDESIGNER2: Sample Layout' LIMIT 1];
        processIds = new Set<String>{pageLayoutRecord.Id};
        request.entityids = new List<String>(processIds);
        request.entityType = SFM_DesignerUtils.entity_layout;
        serializedRequest = JSON.serialize(request);
        restUtils('whereUsed', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        processIds.clear();
        processRecord = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Rule_Type__c = 'SRCH_LOOKUP_CONFIG' AND SVMXC__Name__c = 'lookup Config Designer 2.0' LIMIT 1];
        processIds = new Set<String>{processRecord.Id};
        request.entityids = new List<String>(processIds);
        request.entityType = SFM_DesignerUtils.entity_lkpConfig;
        serializedRequest = JSON.serialize(request);
        restUtils('whereUsed', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        processRecord = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Rule_Type__c = 'Field Update Rule' AND RecordType.Name = 'Business Rule' LIMIT 1];
        processIds = new Set<String>{processRecord.Id};
        request.entityids = new List<String>(processIds);
        request.entityType = SFM_DesignerUtils.entity_formula;
        serializedRequest = JSON.serialize(request);
        restUtils('whereUsed', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();
        test.stopTest();
    }
    Static testMethod void test_getWhereUserInfo_Checklist() {
        SVMXC__ServiceMax_Processes__c processRecord = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Name__c = 'designer2TestChecklistProcess' AND RecordType.Name = 'Target Manager' LIMIT 1];
        Set<String> processIds = new Set<String>{processRecord.Id};
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        processIds = new Set<String>{processRecord.Id};
        request.entityids = new List<String>(processIds);
        request.entityType = SFM_DesignerUtils.entity_checklist;
        String serializedRequest = JSON.serialize(request);
        restUtils('whereUsed', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();    
        processRecord = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Name__c = 'Entry Criteria D2' AND SVMXC__Rule_Type__c = 'Checklist_Section_Entry_Criteria' LIMIT 1];
        processIds = new Set<String>{processRecord.Id};
        request.entityids = new List<String>(processIds);
        request.entityType = SFM_DesignerUtils.entity_sectionEntryCriteria;
        serializedRequest = JSON.serialize(request);
        restUtils('whereUsed', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();
        SVMXC__QB_Response_Set__c responseSet = [SELECT Id FROM SVMXC__QB_Response_Set__c WHERE Name = 'yes or no' LIMIT 1];
		processIds = new Set<String>{responseSet.Id};
        request.entityids = new List<String>(processIds);
        request.entityType = SFM_DesignerUtils.entity_responseSet;
        serializedRequest = JSON.serialize(request);
        restUtils('whereUsed', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();  

        SVMXC__Question_Bank__c questionRecord = [SELECT Id FROM SVMXC__Question_Bank__c WHERE SVMXC__QuestionID__c = 'testqb0002' LIMIT 1];
		processIds = new Set<String>{questionRecord.Id};
        request.entityids = new List<String>(processIds);
        request.entityType = SFM_DesignerUtils.entity_question;
        serializedRequest = JSON.serialize(request);
        restUtils('whereUsed', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();  
        SVMXC__Doc_Template__c templateRecord = [SELECT Id FROM SVMXC__Doc_Template__c WHERE SVMXC__Template_Id__c = 'doc_Template_Designer_2' LIMIT 1];
		processIds = new Set<String>{templateRecord.Id};
        request.entityids = new List<String>(processIds);
        request.entityType = SFM_DesignerUtils.entity_template;
        serializedRequest = JSON.serialize(request);
        restUtils('whereUsed', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();
        test.stopTest();
    }

    Static COMM_AuditTrail.AuditData getPropertiesAuditData() {
        COMM_AuditTrail.AuditData auditData = new COMM_AuditTrail.AuditData();
        auditData.oldValue = '{"Audit":[{"action":"BeforeUpdate","data":[{"Name":"Audit Testing","Tags":"healthcare, Energy"}]}]}';
        auditData.newValue = '{"Audit":[{"action":"Update","data":[{"Tags":""}]}]}';
        return auditData;
    }
    Static COMM_AuditTrail.AuditData getPageLayoutAuditData() {
        COMM_AuditTrail.AuditData auditData = new COMM_AuditTrail.AuditData();
        auditData.oldValue = '{"Audit":[{"action":"BeforeUpdate","data":[{"ParentObj":"WorkOrder","SecTitle":"Description","Fields":"Billing_Type,Problemdesription"}]}]}';
        auditData.newValue = '{"Audit":[{"action":"RemoveFields","data":[{"ParentObj":"WorkOrder","SecTitle":"Description","Fields":"Billing_Type"}]}]}}';
        return auditData;
    }
    Static COMM_AuditTrail.AuditData getFormulasAuditData() {
        COMM_AuditTrail.AuditData auditData = new COMM_AuditTrail.AuditData();
        auditData.oldValue = '{"Audit":[{"action":"Formulas Added","data":[{"Object":"WorkOrder","List":"comma separated formula names"}]}]}';
        auditData.newValue = '{"Audit":[{"action":"Formulas Added","data":[{"Object":"WorkOrder","List":"comma separated formula names"}]},{"action":"Formulas removed","data":[{"Object":"WorkOrder","List":"comma separated formula names"}]}]}';
        return auditData;
    }
    Static COMM_AuditTrail.AuditData getLkpConfigAuditData() {
        COMM_AuditTrail.AuditData auditData = new COMM_AuditTrail.AuditData();
        auditData.oldValue = '{"Audit":[{"action":"Lookup Config Added","data":[{"Name":"Test Lookup"}]}]}';
        auditData.newValue = '{"Audit":[{"action":"Lookup Config Modified","data":[{"Name":"Test New Lookup"}]}]}';
        return auditData;
    }
    Static COMM_AuditTrail.AuditData getOpdocTemplateAuditData() {
        COMM_AuditTrail.AuditData auditData = new COMM_AuditTrail.AuditData();
        auditData.oldValue = '{"Audit":[{"action":"BeforeUpdate","data":[{"Name":"New Template","Desc":"Test Description","Content":"Template content"}]}]}';
        auditData.newValue = '{"Audit":[{"action":"BeforeUpdate","data":[{"Name":"New Template 1","Desc":"Testdesc","Content":"New Template content added"}]}]}';
        return auditData;
    }
    Static COMM_AuditTrail.AuditData removeEntitiesAuditData() {
        COMM_AuditTrail.AuditData auditData = new COMM_AuditTrail.AuditData();
        auditData.oldValue = '';
        auditData.newValue = '{"Audit":[{"action":"Remove","data":[{"Name":"Audit Testing"}]}]}';
        return auditData;
    }

    Static testMethod void test_exceptionRequest(){
        restUtils('', 'GET', '');
        test.startTest();
        try{
            SFMDesigner2ServiceIntf.doGet();
        }catch(exception ex){}
        test.stopTest();
    }

    Static testMethod void test_tagsList(){
        restUtils('allSFMTags', 'GET', '');
        test.startTest();
        SFMDesigner2ServiceIntf.doGet();
        test.stopTest();
    }

    Static testMethod void test_cloneProcess(){
        SVMXC__ServiceMax_Processes__c processRecord = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Name__c = 'designer2TestProcess' AND RecordType.Name = 'Target Manager' limit 1];
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        request.entityids = new List<String>{processRecord.Id};
        String serializedRequest = JSON.serialize(request);
        restUtils('cloneProcess', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        test.stopTest();
    }

    Static testMethod void test_cloneOpdocProcess(){
        SVMXC__ServiceMax_Processes__c processRecord = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Name__c = 'designer2TestOpdocProcess' AND RecordType.Name = 'Target Manager' limit 1];
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        request.entityids = new List<String>{processRecord.Id};
        String serializedRequest = JSON.serialize(request);
        restUtils('cloneProcess', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        test.stopTest();
    }

    Static testMethod void test_saveProcess(){
        SVMXC__ServiceMax_Processes__c processRecord = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Name__c = 'designer2TestProcess' AND RecordType.Name = 'Target Manager' limit 1];
        List<String> processIds = new List<String>{processRecord.Id};
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        SFM_WrapperDef2.SFM2_ProcessInfo processInfo = new SFM_CloneProcess().cloneProcess_V2(processIds);
        SFM_WrapperDef2.SFM2_EntityDetail targetManager = processInfo.targetManager;

        if(targetManager.tagsList != null && !targetManager.tagsList.isEmpty()){
            targetManager.tagsList.remove(0);
            targetManager.tagsList.add('tag3');
            targetManager.tagsList.add('tag4');
        }
        request.auditData = getPropertiesAuditData();
        request.sfm_Process = processInfo;
        request.tabinfo = 'ALL';
        String serializedRequest = JSON.serialize(request);
        restUtils('saveProcess', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        test.stopTest();
    }
    
    Static testMethod void test_saveProcessTabInfo(){
        SVMXC__ServiceMax_Processes__c processRecord = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Name__c = 'designer2TestProcess' AND RecordType.Name = 'Target Manager' limit 1];
        List<String> processIds = new List<String>{processRecord.Id};
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        SFM_WrapperDef2.SFM2_ProcessInfo processInfo = new SFM_CloneProcess().cloneProcess_V2(processIds);
        SFM_WrapperDef2.SFM2_EntityDetail targetManager = processInfo.targetManager;

        if(targetManager.tagsList != null && !targetManager.tagsList.isEmpty()){
            targetManager.tagsList.remove(0);
            targetManager.tagsList.add('tag3');
            targetManager.tagsList.add('tag4');
        }
        request.auditData = getPropertiesAuditData();
        request.sfm_Process = processInfo;
        request.tabinfo = 'PROPERTIES';
        String serializedRequest = JSON.serialize(request);
        restUtils('saveProcess', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        
        request.tabinfo = 'OBJECTMAPPING';
        serializedRequest = JSON.serialize(request);
        restUtils('saveProcess', 'POST', serializedRequest);    
        SFMDesigner2ServiceIntf.doPost();

        request.tabinfo = 'PAGELAYOUT';
        serializedRequest = JSON.serialize(request);
        restUtils('saveProcess', 'POST', serializedRequest);  
        SFMDesigner2ServiceIntf.doPost();
        
        request.tabinfo = 'SOURCEOBJECTUPDATE';
        serializedRequest = JSON.serialize(request);
        restUtils('saveProcess', 'POST', serializedRequest);     
        SFMDesigner2ServiceIntf.doPost();
        
        request.tabinfo = 'DataValidationRules';
        serializedRequest = JSON.serialize(request);
        restUtils('saveProcess', 'POST', serializedRequest);   
        SFMDesigner2ServiceIntf.doPost();
        
        request.tabinfo = 'FORMULAS';
        serializedRequest = JSON.serialize(request);
        restUtils('saveProcess', 'POST', serializedRequest);   
        SFMDesigner2ServiceIntf.doPost();
         
        test.stopTest();
    }

    Static testMethod void test_saveOpdocProcess(){
        SVMXC__ServiceMax_Processes__c processRecord = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Name__c = 'designer2TestOpdocProcess' AND RecordType.Name = 'Target Manager' limit 1];
        List<String> processIds = new List<String>{processRecord.Id};
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        SFM_WrapperDef2.SFM2_ProcessInfo processInfo = new SFM_CloneProcess().cloneProcess_V2(processIds);
        System.assert(processInfo.checklistProcessList.size() > 0, 'Checklist not associated');
        String ruleId = processInfo.checklistProcessList[0].linkedProcessId;
        processInfo.checklistProcessList[0].ruleInfo = new SFM_SaveAsExpression().cloneRule(new List<String>{ruleId}, SFM_DesignerUtils.entity_checklistCriteria);
        SFM_WrapperDef2.SFM2_EntityDetail targetManager = processInfo.targetManager;

        if(targetManager.tagsList != null && !targetManager.tagsList.isEmpty()){
            targetManager.tagsList.remove(0);
            targetManager.tagsList.add('tag3');
            targetManager.tagsList.add('tag4');
        }
        request.sfm_Process = processInfo;
        request.tabinfo = 'OPDOCCHECKLIST';
        request.entityType = SFM_DesignerUtils.entity_opdoc;
        String serializedRequest = JSON.serialize(request);
        restUtils('saveProcess', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        
        request.tabinfo = 'SORTING';
        serializedRequest = JSON.serialize(request);
        restUtils('saveProcess', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();
      
        request.tabinfo = 'ALL';
        serializedRequest = JSON.serialize(request);
        restUtils('saveProcess', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();        
        test.stopTest();
    }

    Static testMethod void test_getRulesList(){
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        SFM_WrapperDef2.SFM2_Criteria criteria = new SFM_WrapperDef2.SFM2_Criteria();
        request.entityType = SFM_DesignerUtils.entity_expression;
        String serializedRequest = JSON.serialize(request);
        restUtils('listOfRules', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();

        request.entityType = SFM_DesignerUtils.entity_businessrule;
        criteria = new SFM_WrapperDef2.SFM2_Criteria();
        criteria.sourceObjectList = new List<String>{'Case'};
        request.criteria = criteria;
        serializedRequest = JSON.serialize(request);
        restUtils('listOfRules', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        request.entityType = SFM_DesignerUtils.entity_mapping;
        criteria = new SFM_WrapperDef2.SFM2_Criteria();
        criteria.sourceObject = 'SVMXC__TaskTemplate__c';
        criteria.targetObject = 'Task';
        request.criteria = criteria;
        serializedRequest = JSON.serialize(request);
        restUtils('listOfRules', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        request.entityType = SFM_DesignerUtils.entity_lkpConfig;
        criteria = new SFM_WrapperDef2.SFM2_Criteria();
        criteria.sourceObject = 'Account';
        request.criteria = criteria;
        serializedRequest = JSON.serialize(request);
        restUtils('listOfRules', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        request.entityType = SFM_DesignerUtils.entity_formula;
        criteria = new SFM_WrapperDef2.SFM2_Criteria();
        criteria.sourceObject = 'Case';
        request.criteria = criteria;
        serializedRequest = JSON.serialize(request);
        restUtils('listOfRules', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        test.stopTest();
    }

    Static testMethod void test_getSFMFunctions(){
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        request.entityType = SFM_DesignerUtils.entity_opdoc;
        String serializedRequest = JSON.serialize(request);
        restUtils('getSFMFunctions', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        test.stopTest();
    }
    Static testMethod void test_getUserPermittedObjects(){
        restUtils('getsObjects', 'GET', '');
        test.startTest();
        SFMDesigner2ServiceIntf.doGet();
        test.stopTest();
    }

    Static testMethod void test_getAllPropertyElements(){
        restUtils('getPropertyElements', 'GET', '');
        test.startTest();
        SFMDesigner2ServiceIntf.doGet();
        test.stopTest();
    }

    Static testMethod void test_getsObjectFields(){
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        request.entityids = new List<String>{'Account','Contact'};
        String serializedRequest = JSON.serialize(request);
        restUtils('getsObjectFields', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        test.stopTest();
    }

    Static testMethod void test_deleteSFM(){
        SVMXC__ServiceMax_Processes__c processRecord = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Name__c = 'designer2TestProcess' AND RecordType.Name = 'Target Manager' limit 1];
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        request.entityids = new List<String>{processRecord.Id};
        request.entityType = SFM_DesignerUtils.entity_sfm;
        request.auditData = removeEntitiesAuditData();
        String serializedRequest = JSON.serialize(request);
        restUtils('removeEntities', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        test.stopTest();
    }

    Static testMethod void test_cloneRule(){
        SVMXC__ServiceMax_Processes__c processRecord = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Name__c = 'Test Expression D2' AND RecordType.Name = 'SVMX Rule' limit 1];
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        request.entityids = new List<String>{processRecord.Id};
        request.entityType = SFM_DesignerUtils.entity_expression;
        String serializedRequest = JSON.serialize(request);
        restUtils('cloneRule', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();

        processRecord = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Rule_Type__c = '' AND RecordType.Name = 'Business Rule' limit 1];
        request = new SFM_WrapperDef2.SFM2_Request();
        request.entityids = new List<String>{processRecord.Id};
        request.entityType = SFM_DesignerUtils.entity_businessrule;
        serializedRequest = JSON.serialize(request);
        restUtils('cloneRule', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        processRecord = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Name__c = 'Test Mapping D2' AND RecordType.Name = 'Object Mapping' limit 1];
        request = new SFM_WrapperDef2.SFM2_Request();
        request.entityids = new List<String>{processRecord.Id};
        request.entityType = SFM_DesignerUtils.entity_mapping;
        serializedRequest = JSON.serialize(request);
        restUtils('cloneRule', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();


        processRecord = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Rule_Type__c = 'Field Update Rule' AND RecordType.Name = 'Business Rule' limit 1];
        request = new SFM_WrapperDef2.SFM2_Request();
        request.entityids = new List<String>{processRecord.Id};
        request.entityType = SFM_DesignerUtils.entity_formula;
        serializedRequest = JSON.serialize(request);
        restUtils('cloneRule', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        processRecord = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Rule_Type__c = 'Checklist_Section_Entry_Criteria' AND RecordType.Name = 'Business Rule' limit 1];
        request = new SFM_WrapperDef2.SFM2_Request();
        request.entityids = new List<String>{processRecord.Id};
        request.entityType = SFM_DesignerUtils.entity_sectionEntryCriteria;
        serializedRequest = JSON.serialize(request);
        restUtils('cloneRule', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();        
        test.stopTest();
    }


    Static testMethod void test_expressionLiteralsSave(){
        SVMXC__ServiceMax_Processes__c processRecord = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Name__c = 'Test Expression D2' AND RecordType.Name = 'SVMX Rule' limit 1];
        List<String> expressionIds = new List<String>{processRecord.Id};
        SFM_WrapperDef2.SFM2_Rule ruleInfo = new SFM_SaveAsExpression().cloneRule(expressionIds, SFM_DesignerUtils.entity_expression);

        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        request.sfm_Rule = ruleInfo;
        request.entityType = SFM_DesignerUtils.entity_expression;
        String serializedRequest = JSON.serialize(request);
        restUtils('saveRule', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        test.stopTest();
    }

    Static testMethod void test_saveRule(){
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        request.entityType = SFM_DesignerUtils.entity_expression;

        SFM_WrapperDef2.SFM2_Rule ruleSample = new SFM_WrapperDef2.SFM2_Rule();
        SFM_WrapperDef2.SFM2_EntityDetail ruleEntityDetail = new SFM_WrapperDef2.SFM2_EntityDetail();
        ruleEntityDetail.entityName = 'testExpressionDesigner2';
        ruleEntityDetail.entityDescription = 'test Expression Designer 2';
        ruleSample.ruleDetail = ruleEntityDetail;
        ruleSample.sourceObject = 'Case';
        ruleSample.advanceExpression = '1 and 2';

        List<SFM_WrapperDef2.SFM2_RuleExpression> expressionDetailList = new List<SFM_WrapperDef2.SFM2_RuleExpression>();
        SFM_WrapperDef2.SFM2_RuleExpression expressionDetail = new SFM_WrapperDef2.SFM2_RuleExpression();
        expressionDetail.sequence = 1;
        expressionDetail.sourceField = 'AccountId';
        expressionDetail.operator = 'eq';
        expressionDetail.value = 'Test Account D2';
        expressionDetailList.add(expressionDetail);

        SFM_WrapperDef2.SFM2_RuleExpression expressionDetail1 = new SFM_WrapperDef2.SFM2_RuleExpression();
        expressionDetail1.sequence = 2;
        expressionDetail1.sourceField = 'Type';
        expressionDetail1.operator = 'eq';
        expressionDetail1.value = 'Other';
        expressionDetailList.add(expressionDetail1);

        ruleSample.expressionsList = expressionDetailList;
        request.auditData = getFormulasAuditData();
        request.sfm_Rule = ruleSample;
        String serializedRequest = JSON.serialize(request);
        restUtils('saveRule', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        String responseStr = res.responseBody.toString();
        System.debug('responseStr ' + responseStr);
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assert(deserializedResponse.get('data') != null, 'Expression Not Upserted');

        /*String expressionId = (String)deserializedResponse.get('data');
        ruleEntityDetail.entityId = expressionId;
        ruleSample.ruleDetail = ruleEntityDetail;
        request.sfm_Rule = ruleSample;
        serializedRequest = JSON.serialize(request);
        restUtils('saveRule', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost(); */
        test.stopTest();
    }

    static testMethod void testSaveRule_ObjectMapping() {

        String request = '{"entityType":"MAPPING","sfm_Rule":{"expressionsList":[{"actionType":"Set Value","configurationType":"Field Mapping","expressionId":null,"literalValue":null,"operator":null,"parameterType":"Field Value","sequence":1,"sourceField":"Id","sourceFieldLabel":"Account","sourceFldDtaType":"REFERENCE","targetField":"SVMXC__Account__c","value":"Id"},{"actionType":"Set Value","configurationType":"Field Mapping","expressionId":null,"operator":null,"parameterType":"Constant","sequence":2,"sourceField":null,"sourceFieldLabel":"Completed On","sourceFldDtaType":"DATETIME","targetField":"SVMXC__Completed_On__c","value":"today"},{"actionType":"Set Value","configurationType":"Field Mapping","displayValue":"Automated Process","expressionId":null,"operator":null,"parameterType":"Value","sequence":3,"sourceField":null,"sourceFieldLabel":"Owner ID","sourceFldDtaType":"REFERENCE","targetField":"OwnerId","value":"0050R000003uUO8QAM"}],"message":null,"ruleDetail":{"entityId":null,"entityName":"test checkt map","entitySubType":null},"sourceObject":"Account","targetObject":"SVMXC__Checklist__c"}}';

        restUtils('saveRule', 'POST', request);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        String responseStr = res.responseBody.toString();
        System.debug('responseStr ' + responseStr);
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        test.stopTest();
    }

    Static testMethod void test_getOperators(){
        restUtils('getOperators', 'GET', '');
        test.startTest();
        SFMDesigner2ServiceIntf.doGet();
        test.stopTest();
    }

    Static testMethod void test_getLookupValues(){
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        request.entityids = new List<String>{'SVMXC__Service_Order_Line__c', 'RecordType'};
        request.entityType = '%Par%';
        String serializedRequest = JSON.serialize(request);
        restUtils('getLookupRecords', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        test.stopTest();
    }

    Static testMethod void test_checkduplicateName(){
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        request.entityids = new List<String>{'designer2TestProcess'};
        request.entityType = SFM_DesignerUtils.entity_sfm;
        String serializedRequest = JSON.serialize(request);
        restUtils('checkDuplicateName', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        String responseStr = res.responseBody.toString();
        System.debug('Response for Check Duplicate Name Call: ' + responseStr);
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        Object responseData = deserializedResponse.get('data');

        //System.assert(String.valueOf(responseData).contains('true'), 'Check Duplicate Name - Failed');

        request = new SFM_WrapperDef2.SFM2_Request();
        request.entityids = new List<String>{'Test Expression D2'};
        request.entityType = SFM_DesignerUtils.entity_expression;
        serializedRequest = JSON.serialize(request);
        restUtils('checkDuplicateName', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        responseStr = res.responseBody.toString();
        System.debug('Response for Check Duplicate Name Call: ' + responseStr);
        deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        responseData = deserializedResponse.get('data');
        //System.assert(String.valueOf(responseData).equalsIgnoreCase('true'), 'Check Duplicate Name - Failed');

        request = new SFM_WrapperDef2.SFM2_Request();
        request.entityids = new List<String>{'Test Mapping D2'};
        request.entityType = SFM_DesignerUtils.entity_mapping;
        serializedRequest = JSON.serialize(request);
        restUtils('checkDuplicateName', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        responseStr = res.responseBody.toString();
        System.debug('Response for Check Duplicate Name Call: ' + responseStr);
        deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        responseData = deserializedResponse.get('data');
        //System.assert(String.valueOf(responseData).equalsIgnoreCase('true'), 'Check Duplicate Name - Failed');

        request = new SFM_WrapperDef2.SFM2_Request();
        request.entityids = new List<String>{'validation Rule'};
        request.entityType = SFM_DesignerUtils.entity_businessrule;
        serializedRequest = JSON.serialize(request);
        restUtils('checkDuplicateName', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        responseStr = res.responseBody.toString();
        System.debug('Response for Check Duplicate Name Call: ' + responseStr);
        deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        responseData = deserializedResponse.get('data');
        //System.assert(String.valueOf(responseData).equalsIgnoreCase('true'), 'Check Duplicate Name - Failed');

        request = new SFM_WrapperDef2.SFM2_Request();
        request.entityids = new List<String>{'designer2 Formula valid name'};
        request.entityType = SFM_DesignerUtils.entity_formula;
        serializedRequest = JSON.serialize(request);
        restUtils('checkDuplicateName', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        responseStr = res.responseBody.toString();
        System.debug('Response for Check Duplicate Name Call: ' + responseStr);
        deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        responseData = deserializedResponse.get('data');
        //System.assert(String.valueOf(responseData).equalsIgnoreCase('false'), 'Check Duplicate Name - Failed');
        test.stopTest();
    }

    Static testMethod void test_getListOfLayouts(){
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        List<SFM_WrapperDef2.SFM2_ObjectInfo> sfm_ObjectList = new List<SFM_WrapperDef2.SFM2_ObjectInfo>();
        SFM_WrapperDef2.SFM2_ObjectInfo sfm_ObjectInfo = new SFM_WrapperDef2.SFM2_ObjectInfo();
        sfm_ObjectInfo.apiName = 'Case';
        sfm_ObjectInfo.objectType = 'Header';
        sfm_ObjectList.add(sfm_ObjectInfo);

        SFM_WrapperDef2.SFM2_ObjectInfo sfm_ObjectInfo1 = new SFM_WrapperDef2.SFM2_ObjectInfo();
        sfm_ObjectInfo1.apiName = 'SVMXC__Case_Line__c';
        sfm_ObjectInfo1.objectType = 'Detail';
        sfm_ObjectInfo1.objectAlias = 'Case Lines';
        sfm_ObjectList.add(sfm_ObjectInfo1);

        request.sfm_ObjectList = sfm_ObjectList;
        String serializedRequest = JSON.serialize(request);
        restUtils('listOfLayouts', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        test.stopTest();
    }

    Static testMethod void test_getChildRelationships(){
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        request.entityids =  new List<String>{'Case'};
        String serializedRequest = JSON.serialize(request);
        restUtils('getChildRelationships', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        test.stopTest();
    }

    Static testMethod void test_CloneLayout(){
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        List<SVMXC__Page_Layout__c> pageLayoutList = [SELECT Id FROM SVMXC__Page_Layout__c WHERE SVMXC__Name__c = 'SVMXDESIGNER2: Sample Layout'];
        System.assert(pageLayoutList.size()==1, 'Failed to fetch Page Layout');
        request.entityIds = new List<String> {pageLayoutList[0].Id};
        String serializedRequest = JSON.serialize(request);
        restUtils('cloneLayout', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);


        test.stopTest();
    }

    Static testMethod void test_SaveLayout(){
        List<SVMXC__Page_Layout__c> pageLayoutList = [SELECT Id FROM SVMXC__Page_Layout__c WHERE SVMXC__Name__c = 'SVMXDESIGNER2: Sample Layout'];
        System.assert(pageLayoutList.size()==1, 'Failed to fetch Page Layout');
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        request.sfm_Layout = new SFM_GetPageLayout().clonePageLayout(new List<String>{pageLayoutList[0].Id}, false);
        List<SVMXC__ServiceMax_Processes__c> processList = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__ProcessID__c = 'designer2TestChecklistProcess' AND RecordType.Name = 'Target Manager' limit 1];
        System.assert(processList.size()==1, 'Failed to fetch Process');
        request.sfm_Layout.processId = processList[0].Id;
        request.auditData = getPageLayoutAuditData();
        String serializedRequest = JSON.serialize(request);
        restUtils('saveLayout', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
    }

    Static testMethod void test_GetFieldSets(){
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        request.entityIds = new List<String> {'Case'};
        String serializedRequest = JSON.serialize(request);
        restUtils('getFieldSets', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        test.stopTest();
    }

    Static testMethod void test_getLkpConfig(){
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        List<SVMXC__ServiceMax_Processes__c> lookupConfig = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Rule_Type__c = 'SRCH_LOOKUP_CONFIG' AND SVMXC__Name__c = 'lookup Config Designer 2.0'];
        System.assert(lookupConfig.size()==1, 'Failed to fetch lookup Config');
        request.entityIds = new List<String> {lookupConfig[0].Id};
        String serializedRequest = JSON.serialize(request);
        restUtils('cloneLkpConfig', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        test.stopTest();
    }

    Static testMethod void test_saveLkpConfig(){
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        List<SVMXC__ServiceMax_Processes__c> lookupConfig = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Rule_Type__c = 'SRCH_LOOKUP_CONFIG' AND SVMXC__Name__c = 'lookup Config Designer 2.0'];
        System.assert(lookupConfig.size()==1, 'Failed to fetch lookup Config');
        request.auditData =  getLkpConfigAuditData();
        request.sfm_LkpConfig = new SFM_GetNamedSearchInfo().getLookupConfig_v2(lookupConfig[0].Id);
        String serializedRequest = JSON.serialize(request);
        restUtils('saveLkpConfig', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        test.stopTest();
    }

    Static testMethod void test_getCodeSnippets(){
        restUtils('getCodeSnippets', 'POST', '');
        test.startTest();
        SFMDesigner2ServiceIntf.doGet();
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        test.stopTest();
    }

    Static testMethod void test_getCustomActions(){
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        request.entityIds = new List<String>{'Account'};
        String serializedRequest = JSON.serialize(request);
        restUtils('getCustomActions', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        test.stopTest();
    }

    Static testMethod void test_getMultisourceProcess(){
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        SFM_WrapperDef2.SFM2_Criteria criteria = new SFM_WrapperDef2.SFM2_Criteria();
        criteria.targetObject = 'Contact';
        request.criteria = criteria;
        String serializedRequest = JSON.serialize(request);
        restUtils('getMultiSourceProcess', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        test.stopTest();
    }

    Static testMethod void test_getLinkedProcess(){
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        SFM_WrapperDef2.SFM2_Criteria criteria = new SFM_WrapperDef2.SFM2_Criteria();
        criteria.targetObjectList = new List<String>{'Account'};
        request.criteria = criteria;
        String serializedRequest = JSON.serialize(request);
        restUtils('getLinkedProcess', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        test.stopTest();
    }

    Static testMethod void test_getListOfTemplates (){
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        List<SFM_WrapperDef2.SFM2_ObjectInfo> sfm_ObjectList = new List<SFM_WrapperDef2.SFM2_ObjectInfo>();
        SFM_WrapperDef2.SFM2_ObjectInfo sfm_ObjectInfo = new SFM_WrapperDef2.SFM2_ObjectInfo();
        sfm_ObjectInfo.apiName = 'Account';
        sfm_ObjectInfo.objectType = 'HEADER';
        sfm_ObjectInfo.objectAlias = 'My Account';
        sfm_ObjectList.add(sfm_ObjectInfo);

        SFM_WrapperDef2.SFM2_ObjectInfo sfm_ObjectInfo1 = new SFM_WrapperDef2.SFM2_ObjectInfo();
        sfm_ObjectInfo1.apiName = 'Contact';
        sfm_ObjectInfo1.objectType = 'DETAIL';
        sfm_ObjectInfo1.objectAlias = 'My Contact';
        sfm_ObjectList.add(sfm_ObjectInfo1);
        request.sfm_ObjectList = sfm_ObjectList;
        String serializedRequest = JSON.serialize(request);
        restUtils('listOfTemplates', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        test.stopTest();
    }

    Static testMethod void test_CloneTemplate(){
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        List<SVMXC__Doc_Template__c> templateList = [SELECT Id FROM SVMXC__Doc_Template__c WHERE SVMXC__Template_Id__c = 'doc_Template_Designer_2'];
        System.assert(templateList.size()==1, 'Failed to fetch Template');
        request.entityIds = new List<String> {templateList[0].Id};
        String serializedRequest = JSON.serialize(request);
        restUtils('cloneTemplate', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        test.stopTest();
    }

    Static testMethod void test_SaveTemplate(){
        List<SVMXC__Doc_Template__c> templateList = [SELECT Id FROM SVMXC__Doc_Template__c WHERE SVMXC__Template_Id__c = 'doc_Template_Designer_2'];
        System.assert(templateList.size()==1, 'Failed to fetch Template');
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        request.auditData = getOpdocTemplateAuditData();
        request.sfm_Template = new SFM_DocTemplateUtils().cloneDocTemplate_V2(new List<String>{templateList[0].Id});
        String serializedRequest = JSON.serialize(request);
        restUtils('saveTemplate', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        test.stopTest();
    }

    Static testMethod void test_SaveTemplateFileEnabled(){
        List<SVMXC__Doc_Template__c> templateList = [SELECT Id FROM SVMXC__Doc_Template__c WHERE SVMXC__Template_Id__c = 'doc_Template_Designer_2'];
        System.assert(templateList.size()==1, 'Failed to fetch Template');
        COMM_FileHandlerUtilities.fileSettingForTestClass = true;
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        request.sfm_Template = new SFM_DocTemplateUtils().cloneDocTemplate_V2(new List<String>{templateList[0].Id});
        request.sfm_Template.contentType = null;
        request.sfm_Template.templateContentId = null;
        String serializedRequest = JSON.serialize(request);
        restUtils('saveTemplate', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        test.stopTest();
    }
    Static testMethod void test_SaveTemplateAttachmentEnabled() {
        List<SVMXC__Doc_Template__c> templateList = [SELECT Id FROM SVMXC__Doc_Template__c WHERE SVMXC__Template_Id__c = 'doc_Template_Designer_2'];
        System.assert(templateList.size()==1, 'Failed to fetch Template');
        COMM_FileHandlerUtilities.fileSettingForTestClass = false;
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        request.sfm_Template = new SFM_DocTemplateUtils().cloneDocTemplate_V2(new List<String>{templateList[0].Id});
        List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'SFM_Doc_Template.html'];
        request.sfm_Template.contentType = 'File';
        request.sfm_Template.templateContentId = contentVersionList[0].Id;
        String serializedRequest = JSON.serialize(request);
        restUtils('saveTemplate', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        test.stopTest();
    }

    Static testMethod void test_getChecklistProcess(){
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        SFM_WrapperDef2.SFM2_Criteria criteria = new SFM_WrapperDef2.SFM2_Criteria();
        criteria.targetObjectList = new List<String>{'SVMXC__Service_Order__c'};
        request.criteria = criteria;
        String serializedRequest = JSON.serialize(request);
        restUtils('getChecklistProcess', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
    }

    Static testMethod void test_getListOfQuestions(){
        restUtils('getListOfQuestions', 'GET', '');
        test.startTest();
        SFMDesigner2ServiceIntf.doGet();
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);        
        test.stopTest();
    }

    Static testMethod void test_getListOfResponseSet(){
        restUtils('getListOfResponseSet', 'GET', '');
        test.startTest();
        SFMDesigner2ServiceIntf.doGet();
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);           
        test.stopTest();
    } 
    
    static testMethod void test_saveResponseSet() {
        final SFM_WrapperDef2.SFM2_ResponseOptionMeta responseSet = new SFM_WrapperDef2.SFM2_ResponseOptionMeta();
        responseSet.name = 'TestResponseSet';
        responseSet.values = new List<String>{'Yes', 'No'};
        final SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        request.responseSet = responseSet;
        final String serializedRequest = JSON.serialize(request);
        restUtils('saveResponseSet', 'POST', serializedRequest );
        Test.startTest();
        {
            SFMDesigner2ServiceIntf.doPost();
            String responseStr = res.responseBody.toString();
            Map<String, Object> deserializedResponse = (Map<String, Object>) JSON.deserializeUntyped(responseStr);
            System.assertEquals(deserializedResponse.get('success'), true);
        }
        {
            SFMDesigner2ServiceIntf.doPost();
            String responseStr = res.responseBody.toString();
            Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
            System.assertEquals(deserializedResponse.get('success'), false);
        }
        Test.stopTest();
    } 
    static testMethod void test_saveResponseSet_exception() {
        final SFM_WrapperDef2.SFM2_ResponseOptionMeta responseSet = new SFM_WrapperDef2.SFM2_ResponseOptionMeta();
        responseSet.name = 'TestResponseSet';
        responseSet.values = new List<String>{'Yes', 'No'};
        final SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        request.responseSet = responseSet;
        final String serializedRequest = JSON.serialize(request);
        restUtils('saveResponseSet', 'POST', serializedRequest );
        Test.startTest();
        Test.setReadOnlyApplicationMode(true);
        {
            SFMDesigner2ServiceIntf.doPost();
            String responseStr = res.responseBody.toString();
            Map<String, Object> deserializedResponse = (Map<String, Object>) JSON.deserializeUntyped(responseStr);
            System.assertEquals(deserializedResponse.get('success'), false);
        }
        Test.stopTest();
    } 
    static testMethod void test_saveResponseSet_invalid_name() {
        final SFM_WrapperDef2.SFM2_ResponseOptionMeta responseSet = new SFM_WrapperDef2.SFM2_ResponseOptionMeta();
        responseSet.name = '';
        responseSet.values = new List<String>{'Yes', 'No'};
        final SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        request.responseSet = responseSet;
        final String serializedRequest = JSON.serialize(request);
        restUtils('saveResponseSet', 'POST', serializedRequest );
        Test.startTest();
        {
            SFMDesigner2ServiceIntf.doPost();
            String responseStr = res.responseBody.toString();
            Map<String, Object> deserializedResponse = (Map<String, Object>) JSON.deserializeUntyped(responseStr);
            System.assertEquals(deserializedResponse.get('success'), false);
        }
        Test.stopTest();
    } 
    static testMethod void test_saveResponseSet_empty_values() {
        final SFM_WrapperDef2.SFM2_ResponseOptionMeta responseSet = new SFM_WrapperDef2.SFM2_ResponseOptionMeta();
        responseSet.name = 'TestResponseSet';
        responseSet.values = new List<String>();
        final SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        request.responseSet = responseSet;
        final String serializedRequest = JSON.serialize(request);
        restUtils('saveResponseSet', 'POST', serializedRequest );
        Test.startTest();
        {
            SFMDesigner2ServiceIntf.doPost();
            String responseStr = res.responseBody.toString();
            Map<String, Object> deserializedResponse = (Map<String, Object>) JSON.deserializeUntyped(responseStr);
            System.assertEquals(deserializedResponse.get('success'), false);
        }
        Test.stopTest();
    } 
    static testMethod void test_saveResponseSet_invalid_id() {
        final SFM_WrapperDef2.SFM2_ResponseOptionMeta responseSet = new SFM_WrapperDef2.SFM2_ResponseOptionMeta();
        responseSet.responseId = UserInfo.getUserId();
        responseSet.name = 'TestResponseSet';
        responseSet.values = new List<String>{'Yes', 'No'};
        final SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        request.responseSet = responseSet;
        final String serializedRequest = JSON.serialize(request);
        restUtils('saveResponseSet', 'POST', serializedRequest );
        Test.startTest();
        {
            SFMDesigner2ServiceIntf.doPost();
            String responseStr = res.responseBody.toString();
            Map<String, Object> deserializedResponse = (Map<String, Object>) JSON.deserializeUntyped(responseStr);
            System.assertEquals(deserializedResponse.get('success'), false);
        }
        Test.stopTest();
    } 
    static testMethod void test_saveQuestionInfo() {
       SFM_WrapperDef2.SFM2_Rule rule = new SFM_WrapperDef2.SFM2_Rule();
        SFM_WrapperDef2.SFM2_EntityDetail ruleDetail = new SFM_WrapperDef2.SFM2_EntityDetail();
        ruleDetail.entityName = 'ruleName';
        ruleDetail.entityDescription = 'Rule description';
        rule.ruleDetail = ruleDetail;
        rule.sourceObject = 'Case';
        rule.advanceExpression = '1 and 2';
        final SFM_WrapperDef2.SFM2_QuestionMeta questionInfo = new SFM_WrapperDef2.SFM2_QuestionMeta();
        questionInfo.question = 'Test question?';
        questionInfo.qType = 'Text';
        questionInfo.sfmRule = rule;
        final SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        request.questionInfo = questionInfo;
        final String serializedRequest = JSON.serialize(request);
        restUtils('saveQuestionInfo', 'POST', serializedRequest );
        Test.startTest();
        {
            SFMDesigner2ServiceIntf.doPost();
            String responseStr = res.responseBody.toString();
            Map<String, Object> deserializedResponse = (Map<String, Object>) JSON.deserializeUntyped(responseStr);
            System.assertEquals(deserializedResponse.get('success'), true);
        }
        Test.stopTest();
    }
    Static testMethod void test_getApiConfiguration(){
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        SFM_WrapperDef2.SFM2_Criteria criteria = new SFM_WrapperDef2.SFM2_Criteria();
        criteria.targetObject = 'SVMXC__Service_Order__c';
        request.criteria = criteria;
        List<SVMXC__ServiceMax_Config_Data__c> configList = [SELECT SVMXC__Setting_Unique_ID__c,SVMXC__Internal_Value__c FROM SVMXC__ServiceMax_Config_Data__c WHERE RecordType.Name = 'Setting Value'
                                         AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true
                                         AND SVMXC__Setting_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' AND
                                         SVMXC__Setting_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Global'];
        System.debug('configList : ' + configList);
        String serializedRequest = JSON.serialize(request);
        restUtils('getApiConfiguration', 'POST', serializedRequest);
        test.startTest();
        SFMDesigner2ServiceIntf.doPost();
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);           
        test.stopTest();
    }     

    Static testMethod void test_getListOfChecklistQuestions(){
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        List<SVMXC__ServiceMax_Processes__c> processRecordList = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Name__c = 'designer2TestChecklistProcess' AND RecordType.Name = 'Target Manager' limit 1];
        System.assert(processRecordList.size()==1, 'Failed to fetch checklist');
        request.entityids = new List<String>{processRecordList[0].Id};
        String serializedRequest = JSON.serialize(request);
        restUtils('getChecklistQuestions', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
    }
    
    Static testMethod void test_removeEntities(){
        SVMXC__ServiceMax_Processes__c processRecord = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Name__c = 'Test Expression D2' AND RecordType.Name = 'SVMX Rule' limit 1];
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        request.entityids = new List<String>{processRecord.Id};
        request.entityType = SFM_DesignerUtils.entity_expression;
        String serializedRequest = JSON.serialize(request);
        restUtils('removeEntities', 'POST', serializedRequest);

        test.startTest();
        SFMDesigner2ServiceIntf.doPost();

        processRecord = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Name__c = 'Test Mapping D2' AND RecordType.Name = 'Object Mapping' LIMIT 1];
        request = new SFM_WrapperDef2.SFM2_Request();
        request.entityids = new List<String>{processRecord.Id};
        request.entityType = SFM_DesignerUtils.entity_mapping;
        serializedRequest = JSON.serialize(request);
        restUtils('removeEntities', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        processRecord = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Name__c = 'validation Rule' AND RecordType.Name = 'Business Rule' LIMIT 1];
        request = new SFM_WrapperDef2.SFM2_Request();
        request.entityids = new List<String>{processRecord.Id};
        request.entityType = SFM_DesignerUtils.entity_businessrule;
        serializedRequest = JSON.serialize(request);
        restUtils('removeEntities', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        SVMXC__Page_Layout__c pageLayoutRecord = [SELECT Id FROM SVMXC__Page_Layout__c WHERE SVMXC__Name__c = 'SVMXDESIGNER2: Sample Layout' LIMIT 1];
        request = new SFM_WrapperDef2.SFM2_Request();
        request.entityids = new List<String>{pageLayoutRecord.Id};
        request.entityType = SFM_DesignerUtils.entity_layout;
        serializedRequest = JSON.serialize(request);
        restUtils('removeEntities', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        processRecord = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Rule_Type__c = 'SRCH_LOOKUP_CONFIG' AND SVMXC__Name__c = 'lookup Config Designer 2.0' LIMIT 1];
        request = new SFM_WrapperDef2.SFM2_Request();
        request.entityids = new List<String>{processRecord.Id};
        request.entityType = SFM_DesignerUtils.entity_lkpConfig;
        serializedRequest = JSON.serialize(request);
        restUtils('removeEntities', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();


        processRecord = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Name__c = 'validationRule D2' AND RecordType.Name = 'Business Rule' LIMIT 1];
        request = new SFM_WrapperDef2.SFM2_Request();
        request.entityids = new List<String>{processRecord.Id};
        request.entityType = SFM_DesignerUtils.entity_formula;
        serializedRequest = JSON.serialize(request);
        restUtils('removeEntities', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        SVMXC__Doc_Template__c templateRecord = [SELECT Id FROM SVMXC__Doc_Template__c WHERE SVMXC__Template_Id__c = 'doc_Template_Designer_2' LIMIT 1];
        request = new SFM_WrapperDef2.SFM2_Request();
        request.entityids = new List<String>{templateRecord.Id};
        request.entityType = SFM_DesignerUtils.entity_template;
        serializedRequest = JSON.serialize(request);
        restUtils('removeEntities', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        test.stopTest();
    }

    Static testMethod void test_InvalidRequest(){
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        String serializedRequest = JSON.serialize(request);

        restUtils('listOfProcesses', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('whereUsed', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('cloneProcess', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('listOfRules', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('getsObjectFields', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('removeEntities', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('cloneRule', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('saveRule', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('getLookupRecords', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('checkDuplicateName', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('saveProcess', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('listOfLayouts', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('getChildRelationships', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('cloneLayout', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('saveLayout', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('getFieldSets', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('cloneLookupConfig', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('saveLookupConfig', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('getCodeSnippets', 'GET', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('getMultiSourceProcess', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('getLinkedProcess', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('getSFMFunctions', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('listOfTemplates', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('cloneTemplate', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('getCustomActions', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('saveTemplate', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('getChecklistProcess', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('getChecklistQuestions', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('getListOfQuestions', 'GET', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();
        
        restUtils('getListOfResponseSet', 'GET', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('getApiConfiguration', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();
        
        restUtils('xxxxxxxx', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

        restUtils('', 'POST', serializedRequest);
        SFMDesigner2ServiceIntf.doPost();

    }

    Static testMethod void test_DesignerController(){
        SFM_WrapperDef2.SFM2_Request request = new SFM_WrapperDef2.SFM2_Request();
        String serializedRequest = JSON.serialize(request);
        test.startTest();
        SFM_Designer designerInstance = new SFM_Designer();
        boolean isSandbox = designerInstance.isSandbox;
        SFM_Designer.JSRGetDisplayTags(serializedRequest);
        SFM_Designer.JSRGetListOfProcesses(serializedRequest);
        SFM_Designer.JSRGetUserInfo(serializedRequest);
        SFM_Designer.JSRGetWhereUsedInfo(serializedRequest);
        SFM_Designer.JSRGetSFMTagsList(serializedRequest);
        SFM_Designer.JSRCloneProcess(serializedRequest);
        SFM_Designer.JSRGetsObjects(serializedRequest);
        SFM_Designer.JSRGetsObjectFields(serializedRequest);
        SFM_Designer.JSRGetPropertyElements(serializedRequest);
        SFM_Designer.JSRGetListOfRules(serializedRequest);
        SFM_Designer.JSRRemoveEntities(serializedRequest);
        SFM_Designer.JSRCloneRule(serializedRequest);
        SFM_Designer.JSRSaveRule(serializedRequest);
        SFM_Designer.JSRGetOperators(serializedRequest);
        SFM_Designer.JSRGetLookupRecords(serializedRequest);
        SFM_Designer.JSRCheckDuplicateName(serializedRequest);
        SFM_Designer.JSRSaveProcess(serializedRequest);
        SFM_Designer.JSRGetLayouts(serializedRequest);
        SFM_Designer.JSRGetRelatedObjects(serializedRequest);
        SFM_Designer.JSRGetFieldSets(serializedRequest);
        SFM_Designer.JSRCloneLayout(serializedRequest);
        SFM_Designer.JSRSaveLayout(serializedRequest);
        SFM_Designer.JSRCloneLookupConfig(serializedRequest);
        SFM_Designer.JSRSaveLookupConfig(serializedRequest);
        SFM_Designer.JSRGetCodeSnippets(serializedRequest);
        SFM_Designer.JSRGetCustomActions(serializedRequest);
        SFM_Designer.JSRGetMultiSourceProcess(serializedRequest);
        SFM_Designer.JSRGetLinkedProcess(serializedRequest);
        SFM_Designer.JSRGetSFMFunctions(serializedRequest);
        SFM_Designer.JSRGetListOfTemplates(serializedRequest);
        SFM_Designer.JSRCloneTemplate(serializedRequest);
        SFM_Designer.JSRSaveTemplate(serializedRequest);
        SFM_Designer.JSRGetChecklistProcess(serializedRequest);
        SFM_Designer.JSRGetChecklistQuestions(serializedRequest);
        SFM_Designer.JSRGetListOfQuestions(serializedRequest);
        SFM_Designer.JSRGetListOfResponseSet(serializedRequest);
        SFM_Designer.JSRGetApiConfiguration(serializedRequest);
        SFM_Designer.JSRSaveResponseSet(serializedRequest);
        SFM_Designer.JSRGetSettingInfo(serializedRequest);
        SFM_Designer.JSRSaveQuestionInfo(serializedRequest);

        test.stopTest();
    }
}