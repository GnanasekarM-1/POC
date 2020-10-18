@isTest(SeeAllData=true)
public class I18N_TranslationDelivery_UT
{
    static testMethod void I18N_TranslationDelivery_Test()
    {
        String INVTRecType = [Select Id from RecordType where Name = 'Inventory Process' and SObjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1].Id;
        List<SVMXC__ServiceMax_Processes__c> lstINVTProcess = new List<SVMXC__ServiceMax_Processes__c>();
        lstINVTProcess.add(new SVMXC__ServiceMax_Processes__c (SVMXC__ProcessID__c = 'Test_INVT_Process', SVMXC__Name__c = 'Test_Process', SVMXC__Description__c = 'Test INVT Process',  SVMXC__Parent_Error_Msg__c = 'Error message for header', SVMXC__Child_Error_Msg__c = 'Error message for details', RecordTypeId = INVTRecType));
        insert lstINVTProcess;
        
        List<SVMXC__ServiceMax_Tags__c> lstSerTag = new List<SVMXC__ServiceMax_Tags__c>();
        
        SVMXC__ServiceMax_Tags__c objTag = new SVMXC__ServiceMax_Tags__c();
        objTag.SVMXC__Language__c = 'Master';
        objTag.SVMXC__Tag_Context__c = 'SFM_SECTION_TITLE';
        objTag.SVMXC__Tag_Key__c = 'Section11';
        objTag.SVMXC__Tag_Text__c = 'Section11';
        objTag.SVMXC__Tag_Value__c = 'Section11';
        objTag.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(UserInfo.getOrganizationId().subString(0,15)));
        lstSerTag.add(objTag);
        
        SVMXC__ServiceMax_Tags__c objTag1 = new SVMXC__ServiceMax_Tags__c();
        objTag1.SVMXC__Language__c = 'Master';
        objTag1.SVMXC__Tag_Context__c = 'SFM_SECTION_TITLE';
        objTag1.SVMXC__Tag_Key__c = 'Section22';
        objTag1.SVMXC__Tag_Text__c = 'Section22';
        objTag1.SVMXC__Tag_Value__c = 'Section22';
        objTag1.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(UserInfo.getOrganizationId().subString(0,15)));
        lstSerTag.add(objTag1);
        
        SVMXC__ServiceMax_Tags__c objTag2 = new SVMXC__ServiceMax_Tags__c();
        objTag2.SVMXC__Language__c = 'Master';
        objTag2.SVMXC__Tag_Context__c = 'SFM_SECTION_TITLE';
        objTag2.SVMXC__Tag_Key__c = 'Section33';
        objTag2.SVMXC__Tag_Text__c = 'Section33';
        objTag2.SVMXC__Tag_Value__c = 'Section33';
        objTag2.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(UserInfo.getOrganizationId().subString(0,15)));
        lstSerTag.add(objTag2);
        
        SVMXC__ServiceMax_Tags__c objTag3 = new SVMXC__ServiceMax_Tags__c();
        objTag3.SVMXC__Language__c = 'Master';
        objTag3.SVMXC__Tag_Context__c = 'SFM_BUTTON_TITLE';
        objTag3.SVMXC__Tag_Key__c = 'SAVE';
        objTag3.SVMXC__Tag_Text__c = 'SAVE';
        objTag3.SVMXC__Tag_Value__c = 'SAVE';
        objTag3.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(UserInfo.getOrganizationId().subString(0,15)));
        lstSerTag.add(objTag3);
        
        SVMXC__ServiceMax_Tags__c objTag4 = new SVMXC__ServiceMax_Tags__c();
        objTag4.SVMXC__Language__c = 'Master';
        objTag4.SVMXC__Tag_Context__c = 'SFM_BUTTON_TITLE';
        objTag4.SVMXC__Tag_Key__c = 'CANCEL';
        objTag4.SVMXC__Tag_Text__c = 'CANCEL';
        objTag4.SVMXC__Tag_Value__c = 'CANCEL';
        objTag4.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(UserInfo.getOrganizationId().subString(0,15)));
        lstSerTag.add(objTag4);
        
        insert lstSerTag;
        
        I18N_TranslationDelivery objTemp = new I18N_TranslationDelivery();
        I18N_TranslationDelivery TranslationObj = new I18N_TranslationDelivery('Test_Process;Section11;Section22;Section33;SAVE;CANCEL;', 'Master');
        TranslationObj.SVMX_GetProcessTranslation(lstINVTProcess);
        
        List<SVMXC__Page_Layout__c> lstLayout = new List<SVMXC__Page_Layout__c>();
        SVMXC__Page_Layout__c headerLayout = new SVMXC__Page_Layout__c();
        headerLayout.SVMXC__Page_Layout_ID__c = '1';
        headerLayout.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        headerLayout.SVMXC__Type__c = 'Header';
        insert headerLayout;
        lstLayout.add(headerLayout);
        
        SVMXC__Page_Layout__c detailLayout = new SVMXC__Page_Layout__c();
        detailLayout.SVMXC__Page_Layout_ID__c = '2';
        detailLayout.SVMXC__Object_Name__c = 'SVMXC__Service_Order_Line__c';
        detailLayout.SVMXC__Type__c = 'Detail';
        detailLayout.SVMXC__Header_Page_Layout__c = headerLayout.Id;
        insert detailLayout;  
        lstLayout.add(detailLayout);
        
        List<SVMXC__Page_Layout_Detail__c> sectionList = new List<SVMXC__Page_Layout_Detail__c>();
        SVMXC__Page_Layout_Detail__c section1 = new SVMXC__Page_Layout_Detail__c();
        section1.SVMXC__Detail_Type__c = 'Section';
        section1.SVMXC__Page_Layout_Detail_Id__c = 'sectionLayout1';
        section1.SVMXC__Page_Layout__c = headerLayout.Id;
        section1.SVMXC__Sequence__c = 1;
        section1.SVMXC__Title__c = 'Section11';
        sectionList.add(section1);
        
        SVMXC__Page_Layout_Detail__c section2 = new SVMXC__Page_Layout_Detail__c();
        section2.SVMXC__Detail_Type__c = 'Section';
        section2.SVMXC__Page_Layout_Detail_Id__c = 'sectionLayout2';
        section2.SVMXC__Page_Layout__c = headerLayout.Id;
        section2.SVMXC__Sequence__c = 2;
        section2.SVMXC__Title__c = 'Section22';
        sectionList.add(section2);
        
        SVMXC__Page_Layout_Detail__c section3 = new SVMXC__Page_Layout_Detail__c();
        section3.SVMXC__Detail_Type__c = 'Section';
        section3.SVMXC__Page_Layout_Detail_Id__c = 'sectionLayout3';
        section3.SVMXC__Page_Layout__c = headerLayout.Id;
        section3.SVMXC__Sequence__c = 2;
        section3.SVMXC__Title__c = 'Section33';
        insert section3;
        sectionList.add(section3);
        
        //Creating Buttons for Header and Detail Page Layouts
        List<SVMXC__Page_Layout_Detail__c> buttonList = new List<SVMXC__Page_Layout_Detail__c>();
        SVMXC__Page_Layout_Detail__c button1 = new SVMXC__Page_Layout_Detail__c();
        button1.SVMXC__Detail_Type__c = 'Button';
        button1.SVMXC__Title__c = 'Save';
        button1.SVMXC__Sequence__c = 1;
        buttonList.add(button1);

        SVMXC__Page_Layout_Detail__c button2 = new SVMXC__Page_Layout_Detail__c();
        button2.SVMXC__Detail_Type__c = 'Button';
        button2.SVMXC__Title__c = 'Cancel';
        button2.SVMXC__Sequence__c = 2;
        buttonList.add(button2);
        
        SVMXC__Page_Layout_Detail__c button3 = new SVMXC__Page_Layout_Detail__c();
        button3.SVMXC__Detail_Type__c = 'Button';
        button3.SVMXC__Page_Layout__c = detailLayout.Id;
        button3.SVMXC__Title__c = 'Cancel';
        button3.SVMXC__Sequence__c = 3;
        insert button3;
        buttonList.add(button3);
        
        TranslationObj.SVMX_GetPageLayoutTranslation(lstLayout);
        TranslationObj.SVMX_GetPageLayoutDetailTranslation(sectionList);
        TranslationObj.SVMX_GetPageLayoutDetailTranslation(buttonList);
        TranslationObj.I18N_WizardStepsSearchObjsProcessIdUpdateRule();
    }
    
    static testMethod void I18N_TranslationDelivery_TestForChecklist(){
        List<SVMXC__Question_Bank__c> lstQues = new List<SVMXC__Question_Bank__c>();
        List<SVMXC__QB_Response_Options__c> lstQuesRes = new List<SVMXC__QB_Response_Options__c>();
        List<SVMXC__QB_Response_Set__c> lstQuesResSet = new List<SVMXC__QB_Response_Set__c>();
        
        SVMXC__Question_Bank__c objQuestionBank = new SVMXC__Question_Bank__c();
        objQuestionBank.SVMXC__QuestionID__c = 'QUE001';
        objQuestionBank.SVMXC__Question__c = 'Test Question';
        objQuestionBank.SVMXC__Response_Type__c = 'Picklist';
        insert objQuestionBank;
        lstQues.add(objQuestionBank);
        
        SVMXC__QB_Response_Options__c objQBResposeOption = new SVMXC__QB_Response_Options__c();
        objQBResposeOption.SVMXC__Question_Bank__c = objQuestionBank.id;
        objQBResposeOption.SVMXC__Sequence__c = 1;
        objQBResposeOption.SVMXC__Response__c = 'TestAns';
        insert objQBResposeOption;
        lstQuesRes.add(objQBResposeOption);
        
        SVMXC__QB_Response_Set__c objQBResposeSet = new SVMXC__QB_Response_Set__c();
        objQBResposeSet.Name = 'Test response set';
        objQBResposeSet.SVMXC__Response_Set_Values__c = 'value1;value2;';
        lstQuesResSet.add(objQBResposeSet);
        
        SVMXC__Question_Bank__c objQuestionBank1 = new SVMXC__Question_Bank__c();
        objQuestionBank1.SVMXC__QuestionID__c = 'QUE002';
        objQuestionBank1.SVMXC__Question__c = 'Test Question2';
        objQuestionBank1.SVMXC__Response_Type__c = 'Text';
        insert objQuestionBank1;
        lstQues.add(objQuestionBank1);
        
        List<SVMXC__SM_Default_Checklist_Response__c> lstDCResponse = new List<SVMXC__SM_Default_Checklist_Response__c>();
        SVMXC__SM_Default_Checklist_Response__c DCResponse = new SVMXC__SM_Default_Checklist_Response__c();
        DCResponse.SVMXC__SM_Default_Response__c = '{"literalValue":null,"listOfDefaultValues":["TestDefAns"]}';
        DCResponse.SVMXC__SM_Question__c = objQuestionBank1.id;
        insert DCResponse;
        lstDCResponse.add(DCResponse);
        
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
        
        List<SVMXC__ServiceMax_Tags__c> lstSerTag = new List<SVMXC__ServiceMax_Tags__c>();
        
        SVMXC__ServiceMax_Tags__c objTag = new SVMXC__ServiceMax_Tags__c();
        objTag.SVMXC__Language__c = 'Master';
        objTag.SVMXC__Tag_Context__c = 'SFM_QUESTION_TEXT';
        objTag.SVMXC__Tag_Key__c = 'TEST_QUESTION';
        objTag.SVMXC__Tag_Text__c = 'TEST_QUESTION';
        objTag.SVMXC__Tag_Value__c = 'TEST_QUESTION';
        objTag.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(UserInfo.getOrganizationId().subString(0,15)));
        lstSerTag.add(objTag);
        
        SVMXC__ServiceMax_Tags__c objTag1 = new SVMXC__ServiceMax_Tags__c();
        objTag1.SVMXC__Language__c = 'Master';
        objTag1.SVMXC__Tag_Context__c = 'SFM_QUESTION_TEXT';
        objTag1.SVMXC__Tag_Key__c = 'TEST_QUESTION2';
        objTag1.SVMXC__Tag_Text__c = 'TEST_QUESTION2';
        objTag1.SVMXC__Tag_Value__c = 'TEST_QUESTION2';
        objTag1.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(UserInfo.getOrganizationId().subString(0,15)));
        lstSerTag.add(objTag1);
        
        SVMXC__ServiceMax_Tags__c objTag2 = new SVMXC__ServiceMax_Tags__c();
        objTag2.SVMXC__Language__c = 'Master';
        objTag2.SVMXC__Tag_Context__c = 'SFM_RESPONSE_TEXT';
        objTag2.SVMXC__Tag_Key__c = 'TESTANS';
        objTag2.SVMXC__Tag_Text__c = 'TESTANS';
        objTag2.SVMXC__Tag_Value__c = 'TESTANS';
        objTag2.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(UserInfo.getOrganizationId().subString(0,15)));
        lstSerTag.add(objTag2);
        
        SVMXC__ServiceMax_Tags__c objTag3 = new SVMXC__ServiceMax_Tags__c();
        objTag3.SVMXC__Language__c = 'Master';
        objTag3.SVMXC__Tag_Context__c = 'SFM_RESPONSE_DEFAULT_ANSWER';
        objTag3.SVMXC__Tag_Key__c = 'TESTDEFResponse';
        objTag3.SVMXC__Tag_Text__c = 'TESTDEFResponse';
        objTag3.SVMXC__Tag_Value__c = 'TESTDEFResponse';
        objTag3.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(UserInfo.getOrganizationId().subString(0,15)));
        lstSerTag.add(objTag3);
        
        insert lstSerTag;
        
        List<String> lstTagKey = new List<String>();
        lstTagKey.add('TEST_QUESTION');
        lstTagKey.add('TEST_QUESTION2');
        lstTagKey.add('TESTANS');
        lstTagKey.add('TESTDEFResponse');
        
        I18N_TranslationDelivery TranslationObj = new I18N_TranslationDelivery(lstTagKey, 'Master');
        TranslationObj.SVMX_GetQuestionTranslation(lstQues);
        TranslationObj.SVMX_GetQuestionResponseTranslation(lstQuesRes);
        TranslationObj.SVMX_GetQuestionResponseSetTranslation(lstQuesResSet); 
        TranslationObj.SVMX_GetQuestionDefaultAnswerTranslation(lstDCResponse);
    }
}