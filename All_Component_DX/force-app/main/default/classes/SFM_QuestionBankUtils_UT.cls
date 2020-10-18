@isTest
private class SFM_QuestionBankUtils_UT{
    static testMethod void SFM_GetQuestionsIDs_SFM_GetListOfQuestion_Test(){
        SVMXC__Question_Bank__c objQuestionBank = new SVMXC__Question_Bank__c();
        objQuestionBank.SVMXC__QuestionID__c = 'QB000001';
        objQuestionBank.SVMXC__Question__c = 'Test Question';
        objQuestionBank.SVMXC__Response_Type__c = 'Picklist';
        insert objQuestionBank;
        
        SVMXC__QB_Response_Options__c objQBResposeOption = new SVMXC__QB_Response_Options__c();
        objQBResposeOption.SVMXC__Question_Bank__c = objQuestionBank.id;
        objQBResposeOption.SVMXC__Sequence__c = 1;
        objQBResposeOption.SVMXC__Response__c = 'TestAns';
        insert objQBResposeOption;
        
        SVMXC__Question_Bank__c objQuestionBank1 = new SVMXC__Question_Bank__c();
        objQuestionBank1.SVMXC__QuestionID__c = 'QB000002';
        objQuestionBank1.SVMXC__Question__c = 'Test Question1';
        objQuestionBank1.SVMXC__Response_Type__c = 'Text';
        insert objQuestionBank1; 
        
        SFM_QuestionBankUtils objQBUtils = new SFM_QuestionBankUtils();
        
        
        //Code for Method SFM_GetListOfQuestion
        SVMXC.SFM_WrapperDef.SFM_StringMap objStringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        objStringMap.key = 'AllQUESTION';
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        lstStringMap.add(objStringMap);
        SVMXC.SFM_WrapperDef.SFM_Request obj_Request = new SVMXC.SFM_WrapperDef.SFM_Request();
        obj_Request.stringMap = lstStringMap;
        SVMXC.SFM_WrapperDef.SFM_Response objResponse = objQBUtils.SFM_GetListOfQuestion(obj_Request);
        System.assert(objResponse.stringMap.size() > 0);
        
        objResponse = objQBUtils.SFM_GetListOfQuestion(null);
        System.assert(objResponse.success == false);
        
        //Code for Method GetQuestionInfo
        List<String> lstQuestionId = new List<String>();
        lstQuestionId.add(objQuestionBank.id);
        lstQuestionId.add(objQuestionBank1.id);
        SVMXC.SFM_WrapperDef.SFM_StringListMap obj_StringListMap = new SVMXC.SFM_WrapperDef.SFM_StringListMap('RECORDID', lstQuestionId);
        List<SVMXC.SFM_WrapperDef.SFM_StringListMap> lst_StringListMap = new List<SVMXC.SFM_WrapperDef.SFM_StringListMap>{obj_StringListMap};
        SVMXC.SFM_WrapperDef.SFM_Request obj_Request1 = new SVMXC.SFM_WrapperDef.SFM_Request();
        obj_Request1.stringListMap = lst_StringListMap;
        SVMXC.SFM_WrapperDef.SFM_Response objResponse1 = objQBUtils.SFM_GetQuestionInfo(obj_Request1);
        System.assert(objResponse1.lstQuestionBank.size() > 0);
    }
    
    static testMethod void SFM_DeleteQuestion_Test1(){
        SVMXC__Question_Bank__c objQuestionBank = new SVMXC__Question_Bank__c();
        objQuestionBank.SVMXC__QuestionID__c = 'QB000001';
        objQuestionBank.SVMXC__Question__c = 'Test Question';
        objQuestionBank.SVMXC__Response_Type__c = 'Picklist';
        insert objQuestionBank;
        
        SVMXC__QB_Response_Options__c objQBResposeOption = new SVMXC__QB_Response_Options__c();
        objQBResposeOption.SVMXC__Question_Bank__c = objQuestionBank.id;
        objQBResposeOption.SVMXC__Sequence__c = 1;
        objQBResposeOption.SVMXC__Response__c = 'TestAns';
        insert objQBResposeOption;
        
        SFM_QuestionBankUtils objQBUtils = new SFM_QuestionBankUtils();
        
        //Code for Method SFM_DeleteQuestion
        SVMXC.SFM_WrapperDef.SFM_StringMap objStringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        objStringMap.key = 'RECORDID';
        objStringMap.value = objQuestionBank.id;
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        lstStringMap.add(objStringMap);
        SVMXC.SFM_WrapperDef.SFM_Request obj_Request = new SVMXC.SFM_WrapperDef.SFM_Request();
        obj_Request.stringMap = lstStringMap;
        SVMXC.SFM_WrapperDef.SFM_Response objResponse = objQBUtils.SFM_DeleteQuestion(obj_Request);
        System.assert(objResponse.success == true);
    }



    static testMethod void SFM_DeleteQuestion_Test3(){
        SVMXC__Question_Bank__c objQuestionBank = checklistTestDataCreation();
        SVMXC__Page_Layout__c objHeaderLayout = createChecklistLayout(objQuestionBank);

        String targetManager;
        String processNodeObjects;
        
        List<RecordType> RTypeList = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' OR  SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        
        if(RTypeList.size() > 0){
            for(RecordType r : RTypeList){
                if(r.Name == 'Target Manager')
                    targetManager = r.id; 
                else if(r.Name ==  'Process Node Objects')
                    processNodeObjects = r.id;
            }
        }

        //Create SFM Process Defination
        SVMXC__ServiceMax_Processes__c ChecklistProcess = new SVMXC__ServiceMax_Processes__c();
        ChecklistProcess.SVMXC__Name__c = 'TESTPROCESS001';
        ChecklistProcess.RecordTypeId = targetManager;
        ChecklistProcess.SVMXC__Purpose__c = 'CHECKLIST';
        ChecklistProcess.SVMXC__ProcessID__c = 'TESTPROCESS001';
        ChecklistProcess.SVMXC__Page_Layout__c = objHeaderLayout.id;
        insert ChecklistProcess;
        
        //Create Process Node object Records.
        list<SVMXC__ServiceMax_Processes__c> listProcessNodeObjects = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c PNObject1 = new SVMXC__ServiceMax_Processes__c();
        PNObject1.RecordTypeId = processNodeObjects;
        PNObject1.SVMXC__Type__c = 'TARGET';
        PNObject1.SVMXC__Source_Object_Name__c = 'SVMXC__Checklist__c';
        PNObject1.SVMXC__Process__c = ChecklistProcess.id;        
        PNObject1.SVMXC__Node_Source_Object_API__c = 'SVMXC__Service_Order__c';
        listProcessNodeObjects.add(PNObject1);
        
        SVMXC__ServiceMax_Processes__c PNObject2 = new SVMXC__ServiceMax_Processes__c();
        PNObject2.RecordTypeId = processNodeObjects;
        PNObject2.SVMXC__Type__c = 'SOURCE';
        PNObject2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        PNObject2.SVMXC__Process__c = ChecklistProcess.id;
        listProcessNodeObjects.add(PNObject2);
        insert listProcessNodeObjects;
        
        SFM_QuestionBankUtils objQBUtils = new SFM_QuestionBankUtils();
        
        //Code for Method SFM_DeleteQuestion
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        SVMXC.SFM_WrapperDef.SFM_StringMap objStringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        objStringMap.key = 'RECORDID';
        objStringMap.value = objQuestionBank.id;
        lstStringMap.add(objStringMap);
        SVMXC.SFM_WrapperDef.SFM_Request obj_Request = new SVMXC.SFM_WrapperDef.SFM_Request();
        obj_Request.stringMap = lstStringMap;
        SVMXC.SFM_WrapperDef.SFM_Response objResponse = objQBUtils.SFM_DeleteQuestion(obj_Request);
        System.assert(objResponse.success == false);
        
        objResponse = objQBUtils.SFM_DeleteQuestion(null);
        System.assert(objResponse.success == false);
    }

    //------Added for the story BAC-3733
    static testMethod void SFM_SaveQuestionInfo_SOU_Check(){
        String targetManager;
        String processNodeObjects;
        String fieldMapping;
        
        List<RecordType> RTypeList = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' OR  SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        
        if(RTypeList.size() > 0){
            for(RecordType r : RTypeList){
                if(r.Name == 'Target Manager')
                    targetManager = r.id; 
                else if(r.Name ==  'Process Node Objects')
                    processNodeObjects = r.id;
                else if(r.Name ==  'Field Mapping')
                    fieldMapping = r.Id;
            }
        }

        SVMXC__QB_Response_Set__c objResponseSet = new SVMXC__QB_Response_Set__c();
        objResponseSet.Name = 'Response-Set-1';
        objResponseSet.SVMXC__Response_Set_Values__c = 'value1;value2;value3;';
        insert objResponseSet;
        
        SVMXC__Question_Bank__c objQuestionBank = new SVMXC__Question_Bank__c();
        objQuestionBank.SVMXC__QuestionID__c = 'QB000001';
        objQuestionBank.SVMXC__Question__c = 'Test Question';
        objQuestionBank.SVMXC__Response_Type__c = 'Picklist';
        objQuestionBank.SVMXC__Response_Set__c = objResponseSet.id;
        insert objQuestionBank;

        //Create Header Page layout
        SVMXC__Page_Layout__c objHeaderLayout = new SVMXC__Page_Layout__c();
        objHeaderLayout.SVMXC__Object_Name__c = 'SVMXC__Checklist__c';
        objHeaderLayout.SVMXC__Type__c = 'Header';
        objHeaderLayout.SVMXC__Page_Layout_ID__c = 'TESTPAGE001';
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
        SVMXC__Page_Layout_Detail__c objfld1 = new SVMXC__Page_Layout_Detail__c();
        objfld1.SVMXC__Detail_Type__c = 'Question';
        objfld1.SVMXC__Question__c = objQuestionBank.id;
        objfld1.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objfld1.SVMXC__Section__c = objSection1.Id;
        objfld1.SVMXC__DataType__c = 'reference';
        objfld1.SVMXC__Sequence__c = 1;
        insert objfld1;

        //Create SFM Process Defination
        SVMXC__ServiceMax_Processes__c ChecklistProcess = new SVMXC__ServiceMax_Processes__c();
        ChecklistProcess.SVMXC__Name__c = 'TESTPROCESS001';
        ChecklistProcess.RecordTypeId = targetManager;
        ChecklistProcess.SVMXC__Purpose__c = 'CHECKLIST';
        ChecklistProcess.SVMXC__ProcessID__c = 'TESTPROCESS001';
        ChecklistProcess.SVMXC__Page_Layout__c = objHeaderLayout.id;
        insert ChecklistProcess;
        
        //Create Process Node object Records.
        list<SVMXC__ServiceMax_Processes__c> listProcessNodeObjects = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c PNObject1 = new SVMXC__ServiceMax_Processes__c();
        PNObject1.RecordTypeId = processNodeObjects;
        PNObject1.SVMXC__Type__c = 'TARGET';
        PNObject1.SVMXC__Source_Object_Name__c = 'SVMXC__Checklist__c';
        PNObject1.SVMXC__Process__c = ChecklistProcess.id;        
        PNObject1.SVMXC__Node_Source_Object_API__c = 'SVMXC__Service_Order__c';
        listProcessNodeObjects.add(PNObject1);
        
        SVMXC__ServiceMax_Processes__c PNObject2 = new SVMXC__ServiceMax_Processes__c();
        PNObject2.RecordTypeId = processNodeObjects;
        PNObject2.SVMXC__Type__c = 'SOURCE';
        PNObject2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        PNObject2.SVMXC__Process__c = ChecklistProcess.id;
        listProcessNodeObjects.add(PNObject2);
        insert listProcessNodeObjects;

        SVMXC__ServiceMax_Config_Data__c objSOU = new SVMXC__ServiceMax_Config_Data__c();
        objSOU.RecordTypeId = fieldMapping;
        objSOU.SVMXC__Configuration_Type__c = 'Source Update';
        objSOU.SVMXC__Action__c = 'Set';
        objSOU.SVMXC__Dispatch_Process__c = ChecklistProcess.id;
        objSOU.SVMXC__SM_Question__c = objQuestionBank.id;
        objSOU.SVMXC__MapID__c = listProcessNodeObjects[1].id;
        objSOU.SVMXC__Setting_ID__c = listProcessNodeObjects[0].id;
        objSOU.SVMXC__Source_Field_Name__c = 'SVMXC__City__c';
        insert objSOU;

        Test.startTest();

        SFM_QuestionBankUtils objQBUtils = new SFM_QuestionBankUtils();
        
        //Changing answer type
        objQuestionBank.SVMXC__Response_Type__c  = 'Text';

        //Code for Method SFM_SaveQuestionInfo with MODE = Save
        List<SVMXC.SFM_WrapperDef.SFM_QuestionBank> lstQuestionBank = new List<SVMXC.SFM_WrapperDef.SFM_QuestionBank>();
        SVMXC.SFM_WrapperDef.SFM_QuestionBank objQB = new SVMXC.SFM_WrapperDef.SFM_QuestionBank(objQuestionBank, null, objResponseSet, null);
        lstQuestionBank.add(objQB);
        
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        SVMXC.SFM_WrapperDef.SFM_StringMap objStringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        objStringMap.key = 'MODE';
        objStringMap.value = 'SAVE';
        lstStringMap.add(objStringMap);
        
        //call from QBM
        SVMXC.SFM_WrapperDef.SFM_Request obj_Request = new SVMXC.SFM_WrapperDef.SFM_Request();
        obj_Request.lstQuestionBank = lstQuestionBank;
        obj_Request.stringMap = lstStringMap;
        SVMXC.SFM_WrapperDef.SFM_Response objResponse = objQBUtils.SFM_SaveQuestionInfo(obj_Request);
        System.assert(objResponse.success == false);

        //call from designer
        obj_Request.clientType = 'Designer';
        objResponse = objQBUtils.SFM_SaveQuestionInfo(obj_Request);
        System.assert(objResponse.success == false);

        Test.stopTest();
    }
    
    static testMethod void SFM_SaveQuestionInfo_SAVE_Test(){
        SVMXC__Question_Bank__c objQuestionBank1 = new SVMXC__Question_Bank__c();
        objQuestionBank1.SVMXC__QuestionID__c = 'QB000001';
        objQuestionBank1.SVMXC__Question__c = 'Test Question';
        objQuestionBank1.SVMXC__Response_Type__c = 'Text';
        insert objQuestionBank1;

        SVMXC__Question_Bank__c objQuestionBank = new SVMXC__Question_Bank__c();
        objQuestionBank.SVMXC__Question__c = 'Test Question';
        objQuestionBank.SVMXC__Response_Type__c = 'Picklist';
        
        List<SVMXC__QB_Response_Options__c> lstQBRes = new List<SVMXC__QB_Response_Options__c>();
        SVMXC__QB_Response_Options__c objQBResposeOption = new SVMXC__QB_Response_Options__c();
        objQBResposeOption.SVMXC__Sequence__c = 1;
        objQBResposeOption.SVMXC__Response__c = 'TestAns';
        lstQBRes.add(objQBResposeOption);
        
        SFM_QuestionBankUtils objQBUtils = new SFM_QuestionBankUtils();
        
        //Code for Method SFM_SaveQuestionInfo with MODE = Save
        List<SVMXC.SFM_WrapperDef.SFM_QuestionBank> lstQuestionBank = new List<SVMXC.SFM_WrapperDef.SFM_QuestionBank>();
        SVMXC.SFM_WrapperDef.SFM_QuestionBank objQB = new SVMXC.SFM_WrapperDef.SFM_QuestionBank(objQuestionBank, lstQBRes,new SVMXC__QB_Response_Set__c(), new List<String>{'testTag1','testTag2','testTag3'});
        lstQuestionBank.add(objQB);
        
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        SVMXC.SFM_WrapperDef.SFM_StringMap objStringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        objStringMap.key = 'MODE';
        objStringMap.value = 'SAVE';
        lstStringMap.add(objStringMap);
        
        SVMXC.SFM_WrapperDef.SFM_Request obj_Request = new SVMXC.SFM_WrapperDef.SFM_Request();
        obj_Request.lstQuestionBank = lstQuestionBank;
        obj_Request.stringMap = lstStringMap;
        SVMXC.SFM_WrapperDef.SFM_Response objResponse = objQBUtils.SFM_SaveQuestionInfo(obj_Request);
        System.assert(objResponse.success == true);
        System.assert(objResponse.lstQuestionBank.size() > 0);
    }
    
    static testMethod void SFM_SaveQuestionInfo_SAVEUPDATE_Test(){
        SVMXC__Question_Bank__c objQuestionBank1 = new SVMXC__Question_Bank__c();
        objQuestionBank1.SVMXC__QuestionID__c = 'QB000001';
        objQuestionBank1.SVMXC__Question__c = 'Test Question';
        objQuestionBank1.SVMXC__Response_Type__c = 'Text';
        insert objQuestionBank1;

        //Added for Tags 15 Feb-16
        SVMXC__SM_Tag_Definition__c tagDefn1 = new SVMXC__SM_Tag_Definition__c(name='testTag1');
        SVMXC__SM_Tag_Definition__c tagDefn2 = new SVMXC__SM_Tag_Definition__c(name='testTag2');
        SVMXC__SM_Tag_Definition__c tagDefn3 = new SVMXC__SM_Tag_Definition__c(name='testTag4');
        insert (new List<SVMXC__SM_Tag_Definition__c>{tagDefn1,tagDefn2,tagDefn3});
        
        SVMXC__SM_Tag_Element__c tagElement1 = new SVMXC__SM_Tag_Element__c(SVMXC__SM_Tag_Definition__c = tagDefn1.Id,
                                                     SVMXC__SM_Target_Object__c = objQuestionBank1.Id);

        SVMXC__SM_Tag_Element__c tagElement2 = new SVMXC__SM_Tag_Element__c(SVMXC__SM_Tag_Definition__c = tagDefn2.Id,
                                                     SVMXC__SM_Target_Object__c = objQuestionBank1.Id);
                                                                                
        insert (new List<SVMXC__SM_Tag_Element__c>{tagElement1,tagElement2});
            

        
        List<SVMXC__QB_Response_Options__c> lstQBRes = new List<SVMXC__QB_Response_Options__c>();
        SVMXC__QB_Response_Options__c objQBResposeOption = new SVMXC__QB_Response_Options__c();
        objQBResposeOption.SVMXC__Sequence__c = 1;
        objQBResposeOption.SVMXC__Response__c = 'TestAns';
        lstQBRes.add(objQBResposeOption);
        
        SFM_QuestionBankUtils objQBUtils = new SFM_QuestionBankUtils();
        
        //Code for Method SFM_SaveQuestionInfo with MODE = Save
        List<SVMXC.SFM_WrapperDef.SFM_QuestionBank> lstQuestionBank = new List<SVMXC.SFM_WrapperDef.SFM_QuestionBank>();
        SVMXC.SFM_WrapperDef.SFM_QuestionBank objQB = new SVMXC.SFM_WrapperDef.SFM_QuestionBank(objQuestionBank1, lstQBRes,new SVMXC__QB_Response_Set__c(), new List<String>{'testTag1','testTag3','testTag4'});
        lstQuestionBank.add(objQB);
        
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        SVMXC.SFM_WrapperDef.SFM_StringMap objStringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        objStringMap.key = 'MODE';
        objStringMap.value = 'SAVE';
        lstStringMap.add(objStringMap);
        
        SVMXC.SFM_WrapperDef.SFM_Request obj_Request = new SVMXC.SFM_WrapperDef.SFM_Request();
        obj_Request.lstQuestionBank = lstQuestionBank;
        obj_Request.stringMap = lstStringMap;
        SVMXC.SFM_WrapperDef.SFM_Response objResponse = objQBUtils.SFM_SaveQuestionInfo(obj_Request);
        System.assert(objResponse.success == true);
        System.assert(objResponse.lstQuestionBank.size() > 0);       

        //Code for Method GetQuestionInfo
        List<String> lstQuestionId = new List<String>();
        lstQuestionId.add(objQuestionBank1.id);
        SVMXC.SFM_WrapperDef.SFM_StringListMap obj_StringListMap = new SVMXC.SFM_WrapperDef.SFM_StringListMap('RECORDID', lstQuestionId);
        List<SVMXC.SFM_WrapperDef.SFM_StringListMap> lst_StringListMap = new List<SVMXC.SFM_WrapperDef.SFM_StringListMap>{obj_StringListMap};
        SVMXC.SFM_WrapperDef.SFM_Request obj_Request1 = new SVMXC.SFM_WrapperDef.SFM_Request();
        obj_Request1.stringListMap = lst_StringListMap;
        SVMXC.SFM_WrapperDef.SFM_Response objResponse1 = objQBUtils.SFM_GetQuestionInfo(obj_Request1);
        System.assert(objResponse1.lstQuestionBank.size() > 0);     
        
        //Code for Method SFM_DeleteQuestion
        objStringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        objStringMap.key = 'RECORDID';
        objStringMap.value = objQuestionBank1.id;
        lstStringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        lstStringMap.add(objStringMap);
        obj_Request = new SVMXC.SFM_WrapperDef.SFM_Request();
        obj_Request.stringMap = lstStringMap;
        objResponse = objQBUtils.SFM_DeleteQuestion(obj_Request);
        System.assert(objResponse.success == true);  
        
   
    }
    
    static testMethod void SFM_SaveQuestionInfo_SAVEAS_Test(){
        SVMXC__Question_Bank__c objQuestionBank1 = new SVMXC__Question_Bank__c();
        objQuestionBank1.SVMXC__QuestionID__c = 'QB000001';
        objQuestionBank1.SVMXC__Question__c = 'Test Question';
        objQuestionBank1.SVMXC__Response_Type__c = 'Text';
        insert objQuestionBank1;
        
        SVMXC__Question_Bank__c objQuestionBank = new SVMXC__Question_Bank__c();
        objQuestionBank.SVMXC__QuestionID__c = 'QB000002';
        objQuestionBank.SVMXC__Question__c = 'Test Question';
        objQuestionBank.SVMXC__Response_Type__c = 'Picklist';
        insert objQuestionBank;
        
        List<SVMXC__QB_Response_Options__c> lstQBRes = new List<SVMXC__QB_Response_Options__c>();
        SVMXC__QB_Response_Options__c objQBResposeOption = new SVMXC__QB_Response_Options__c();
        objQBResposeOption.SVMXC__Question_Bank__c = objQuestionBank.id;
        objQBResposeOption.SVMXC__Sequence__c = 1;
        objQBResposeOption.SVMXC__Response__c = 'TestAns';
        insert objQBResposeOption;
        lstQBRes.add(objQBResposeOption);
        
        SVMXC__QB_Response_Options__c objQBResposeOption1 = new SVMXC__QB_Response_Options__c();
        objQBResposeOption1.SVMXC__Sequence__c = 2;
        objQBResposeOption1.SVMXC__Response__c = 'TestAns 2';
        lstQBRes.add(objQBResposeOption1);
        
        SFM_QuestionBankUtils objQBUtils = new SFM_QuestionBankUtils();
        
        //Code for Method SFM_SaveQuestionInfo
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        SVMXC.SFM_WrapperDef.SFM_StringMap objStringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        objStringMap.key = 'MODE';
        objStringMap.value = 'EDIT';
        lstStringMap.add(objStringMap);
        
        List<SVMXC.SFM_WrapperDef.SFM_QuestionBank> lstQuestionBank = new List<SVMXC.SFM_WrapperDef.SFM_QuestionBank>();
        SVMXC.SFM_WrapperDef.SFM_QuestionBank objQB = new SVMXC.SFM_WrapperDef.SFM_QuestionBank(objQuestionBank, lstQBRes);
        lstQuestionBank.add(objQB);
        
        SVMXC.SFM_WrapperDef.SFM_Request obj_Request = new SVMXC.SFM_WrapperDef.SFM_Request();
        obj_Request.stringMap = lstStringMap;
        obj_Request.lstQuestionBank = lstQuestionBank;
        SVMXC.SFM_WrapperDef.SFM_Response objResponse = objQBUtils.SFM_SaveQuestionInfo(obj_Request);
        System.assert(objResponse.success == true);
        System.assert(objResponse.lstQuestionBank.size() > 0);
    }
    
    static testMethod void SFM_GetQuestionInfo_with_RespSet_Test(){
        //Response set
        SVMXC__QB_Response_Set__c objResponseSet = new SVMXC__QB_Response_Set__c();
        objResponseSet.Name = 'Response-Set-1';
        objResponseSet.SVMXC__Response_Set_Values__c = 'value1;value2;value3;';
        insert objResponseSet;
        
        SVMXC__Question_Bank__c objQuestionBank = new SVMXC__Question_Bank__c();
        objQuestionBank.SVMXC__QuestionID__c = 'QB000001';
        objQuestionBank.SVMXC__Question__c = 'Test Question';
        objQuestionBank.SVMXC__Response_Type__c = 'Picklist';
        objQuestionBank.SVMXC__Response_Set__c = objResponseSet.id;
        insert objQuestionBank;
        
        SFM_QuestionBankUtils objQBUtils = new SFM_QuestionBankUtils();
        
        //Code for Method GetQuestionInfo
        List<String> lstQuestionId = new List<String>();
        lstQuestionId.add(objQuestionBank.id);
        SVMXC.SFM_WrapperDef.SFM_StringListMap obj_StringListMap = new SVMXC.SFM_WrapperDef.SFM_StringListMap('RECORDID', lstQuestionId);
        List<SVMXC.SFM_WrapperDef.SFM_StringListMap> lst_StringListMap = new List<SVMXC.SFM_WrapperDef.SFM_StringListMap>{obj_StringListMap};
        SVMXC.SFM_WrapperDef.SFM_Request obj_Request1 = new SVMXC.SFM_WrapperDef.SFM_Request();
        obj_Request1.stringListMap = lst_StringListMap;
        SVMXC.SFM_WrapperDef.SFM_Response objResponse1 = objQBUtils.SFM_GetQuestionInfo(obj_Request1);
        System.assert(objResponse1.lstQuestionBank.size() > 0);
        
        obj_Request1 = new SVMXC.SFM_WrapperDef.SFM_Request();
        objResponse1 = objQBUtils.SFM_GetListOfResponseSet(obj_Request1);
        System.assert(objResponse1.stringMap.size() > 0);
    }
    static testMethod void SFM_SaveQuestionInfo_DuplicateRS(){
        SVMXC__QB_Response_Set__c objResponseSet = new SVMXC__QB_Response_Set__c();
        objResponseSet.Name = 'Response-Set-1';
        objResponseSet.SVMXC__Response_Set_Values__c = 'value1;value2;value3;';
        insert objResponseSet;
        
        SVMXC__Question_Bank__c objQuestionBank = new SVMXC__Question_Bank__c();
        objQuestionBank.SVMXC__QuestionID__c = 'QB000002';
        objQuestionBank.SVMXC__Question__c = 'Test Question';
        objQuestionBank.SVMXC__Response_Type__c = 'Picklist';
        
        SVMXC__QB_Response_Set__c objResponseSet1 = new SVMXC__QB_Response_Set__c();
        objResponseSet1.Name = 'Response-Set-1';
        objResponseSet1.SVMXC__Response_Set_Values__c = 'value1;value2;';
        
        SFM_QuestionBankUtils objQBUtils = new SFM_QuestionBankUtils();
        
        //Code for Method SFM_SaveQuestionInfo        
        List<SVMXC.SFM_WrapperDef.SFM_QuestionBank> lstQuestionBank = new List<SVMXC.SFM_WrapperDef.SFM_QuestionBank>();
        SVMXC.SFM_WrapperDef.SFM_QuestionBank objQB = new SVMXC.SFM_WrapperDef.SFM_QuestionBank(objQuestionBank, null, objResponseSet1);
        lstQuestionBank.add(objQB);
        
        SVMXC.SFM_WrapperDef.SFM_Request obj_Request = new SVMXC.SFM_WrapperDef.SFM_Request();
        obj_Request.lstQuestionBank = lstQuestionBank;
        SVMXC.SFM_WrapperDef.SFM_Response objResponse = objQBUtils.SFM_SaveQuestionInfo(obj_Request);
        System.assert(objResponse.success == false);
    }
    static testMethod void  SFM_SaveChecklist_QuestionInfo_Test()
    {
        String RuleRecordTypeId, ExpressionRTypeId, ProcessBizRuleId,TargetMngRecTypeId;
        for(RecordType RType : Database.query('Select Id, Name From RecordType Where (SobjectType = \'SVMXC__ServiceMax_Processes__c\' AND Name = \'QB Validation\') OR (SobjectType = \'SVMXC__ServiceMax_Processes__c\' AND Name = \'Process Business Rule\')OR (SobjectType = \'SVMXC__ServiceMax_Config_Data__c\' AND Name = \'Expressions\')'))
        {
            if(RType.Name == 'QB Validation')
                RuleRecordTypeId = RType.id;
            else if(RType.Name == 'Expressions')
                ExpressionRTypeId = RType.id; 
            else if(RType.Name == 'Process Business Rule')
                ProcessBizRuleId = RType.id;
        }
        
        
        
        for(RecordType RType : Database.query('Select Id, Name From RecordType Where (SobjectType = \'SVMXC__ServiceMax_Processes__c\' AND Name = \'Target Manager\')  OR (SobjectType = \'SVMXC__ServiceMax_Processes__c\' AND Name = \'QB Validation\') OR (SobjectType = \'SVMXC__ServiceMax_Processes__c\' AND Name = \'Process Business Rule\')OR (SobjectType = \'SVMXC__ServiceMax_Config_Data__c\' AND Name = \'Expressions\')'))
            {
                if(RType.Name == 'QB Validation')
                    RuleRecordTypeId = RType.id;
                else if(RType.Name == 'Target Manager')
                    TargetMngRecTypeId = RType.id;
                else if(RType.Name == 'Expressions')
                    ExpressionRTypeId = RType.id; 
                else if(RType.Name == 'Process Business Rule')
                    ProcessBizRuleId = RType.id;
            }
                
        SVMXC__ServiceMax_Processes__c objPrc = new SVMXC__ServiceMax_Processes__c();
        objPrc.SVMXC__Name__c = 'TestobjPrc';
        objPrc.SVMXC__ProcessID__c = 'TestobjPrc';
        objPrc.SVMXC__Purpose__c = 'CHECKLIST';
        objPrc.RecordTypeId = TargetMngRecTypeId;

        insert objPrc;

        SVMXC__Question_Bank__c objQuestionBank = new SVMXC__Question_Bank__c();
        objQuestionBank.SVMXC__QuestionID__c = 'QB000001';
        objQuestionBank.SVMXC__Question__c = 'Test Question';
        objQuestionBank.SVMXC__Response_Type__c = 'Picklist';
        insert objQuestionBank;
        
        SVMXC__ServiceMax_Processes__c proc = new SVMXC__ServiceMax_Processes__c();

        proc.SVMXC__Name__c = 'ChecklistValidationRuleTest5';
        proc.SVMXC__ProcessID__c = 'ChecklistValidationRuleTest5';
        proc.SVMXC__Question_Bank__c = objQuestionBank.id;
        proc.RecordTypeId = RuleRecordTypeId;

        insert proc;

        SVMXC__ServiceMax_config_Data__c conf1 = new SVMXC__ServiceMax_config_Data__c();
        conf1.SVMXC__Parameter_Type__c='Constant';
        conf1.SVMXC__Sequence__c=1;
        conf1.SVMXC__Display_Type__c='DATETIME';
        conf1.SVMXC__Operator__c='lt';
        conf1.SVMXC__Operand__c='Tomorrow';
        conf1.RecordTypeId= ExpressionRTypeId;
        conf1.SVMXC__Expression_Rule__c= proc.id;
        insert conf1;
        
        
        
        
        
        
        SFM_WrapperDef.SFM_StringMap valueMap1 = new SFM_WrapperDef.SFM_StringMap();
        valueMap1.key = objQuestionBank.id;
        valueMap1.Value = proc.id;
        
        SFM_WrapperDef.SFM_MapStringMap testSFM_MapStringMap = new SFM_WrapperDef.SFM_MapStringMap();
        SFM_WrapperDef.SFM_Request req = new SFM_WrapperDef.SFM_Request();
        testSFM_MapStringMap.key = objPrc.id;
        testSFM_MapStringMap.valueMap.add(valueMap1);
        req.MapStringMap = testSFM_MapStringMap;
        SFM_QuestionBankUtils testQBU = new SFM_QuestionBankUtils();
        testQBU.SFM_SaveChecklist_QuestionInfo(req);


    
    }
    static testMethod void  SFM_Checklist_Validation_Test()
    {
        String RuleRecordTypeId, ExpressionRTypeId, ProcessBizRuleId;
        
        
        SVMXC__Question_Bank__c objQuestionBank = new SVMXC__Question_Bank__c();
        objQuestionBank.SVMXC__QuestionID__c = 'QB000001';
        objQuestionBank.SVMXC__Question__c = 'Test Question';
        objQuestionBank.SVMXC__Response_Type__c = 'Picklist';
        insert objQuestionBank;
        for(RecordType RType : Database.query('Select Id, Name From RecordType Where (SobjectType = \'SVMXC__ServiceMax_Processes__c\' AND Name = \'QB Validation\') OR (SobjectType = \'SVMXC__ServiceMax_Processes__c\' AND Name = \'Process Business Rule\')OR (SobjectType = \'SVMXC__ServiceMax_Config_Data__c\' AND Name = \'Expressions\')'))
        {
            if(RType.Name == 'QB Validation')
                RuleRecordTypeId = RType.id;
            else if(RType.Name == 'Expressions')
                ExpressionRTypeId = RType.id; 
            else if(RType.Name == 'Process Business Rule')
                ProcessBizRuleId = RType.id;
        }
        
        
        SVMXC__ServiceMax_Processes__c proc = new SVMXC__ServiceMax_Processes__c();

        proc.SVMXC__Name__c = 'ChecklistValidationRuleTest5';
        proc.SVMXC__ProcessID__c = 'ChecklistValidationRuleTest5';
        proc.SVMXC__Question_Bank__c = objQuestionBank.id;
        proc.RecordTypeId = RuleRecordTypeId;
        
        //insert proc;

        list<SVMXC__ServiceMax_Config_Data__c> lstconf = new list<SVMXC__ServiceMax_Config_Data__c>();
        

        

        SVMXC__ServiceMax_config_Data__c conf2 = new SVMXC__ServiceMax_config_Data__c();
        conf2.SVMXC__Parameter_Type__c='Constant';
        conf2.SVMXC__Sequence__c=1;
        conf2.SVMXC__Display_Type__c='DATETIME';
        conf2.SVMXC__Operator__c='lt';
        conf2.SVMXC__Operand__c='Tomorrow';
        conf2.RecordTypeId= ExpressionRTypeId;
        //conf2.SVMXC__Expression_Rule__c= proc.id;
        lstconf.add(conf2);


        


        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request ();
        request.QuestionValidationRuleInfo = new SVMXC.SFM_WrapperDef.SFM_QuestionValidationRuleInfo(proc, lstconf);
        SFM_QuestionBankUtils testCls = new SFM_QuestionBankUtils();



        SVMXC.SFM_WrapperDef.SFM_Response resp = testCls.SFM_SaveQuestionValidationRules (request);
        system.debug('++++++++++++:  '+resp);
        
        SVMXC.SFM_WrapperDef.SFM_Request request1 = new SVMXC.SFM_WrapperDef.SFM_Request ();
        SVMXC.SFM_WrapperDef.SFM_StringListMap stringMap = new SVMXC.SFM_WrapperDef.SFM_StringListMap();
        stringMap.key ='RECORDID';
        stringMap.valueList.add(objQuestionBank.id);
        request1.stringListMap.add(stringMap);
        SVMXC.SFM_WrapperDef.SFM_Response res = new SFM_QuestionBankUtils().SFM_GetQuestionInfo(request1);
        system.debug(res);

    }
    
    static testMethod void SFM_GetQuestionDetailsOfProcess_testMethod(){
        SVMXC__Question_Bank__c objQuestionBank = checklistTestDataCreation();
        SVMXC__Page_Layout__c objHeaderLayout = createChecklistLayout(objQuestionBank);

        test.startTest();
        SFM_WrapperDef.SFM_Request requestStr = new SFM_WrapperDef.SFM_Request();
        
        SFM_WrapperDef.SFM_StringListMap stringListMap = new SFM_WrapperDef.SFM_StringListMap('', new List<String>{objHeaderLayout.Id});
        requestStr.stringListMap = new List<SFM_WrapperDef.SFM_StringListMap>();
        requestStr.stringListMap.add(stringListMap);
        SFM_WrapperDef.SFM_Response  response = SFM_WebServicesDef.SFM_GetQuestionDetailsOfProcess(requestStr);
        System.assert(response.success == true);
        test.stopTest();
    }

    static SVMXC__Question_Bank__c checklistTestDataCreation(){
        SVMXC__Question_Bank__c objQuestionBank = new SVMXC__Question_Bank__c();
        objQuestionBank.SVMXC__QuestionID__c = 'QB000001';
        objQuestionBank.SVMXC__Question__c = 'Test Question';
        objQuestionBank.SVMXC__Response_Type__c = 'Picklist';
        insert objQuestionBank;
        
        SVMXC__QB_Response_Options__c objQBResposeOption = new SVMXC__QB_Response_Options__c();
        objQBResposeOption.SVMXC__Question_Bank__c = objQuestionBank.id;
        objQBResposeOption.SVMXC__Sequence__c = 1;
        objQBResposeOption.SVMXC__Response__c = 'TestAns';
        insert objQBResposeOption;
        
        
        
      
        return objQuestionBank;
    }

    static SVMXC__Page_Layout__c createChecklistLayout(SVMXC__Question_Bank__c objQuestionBank){
        //Create Header Page layout
        SVMXC__Page_Layout__c objHeaderLayout = new SVMXC__Page_Layout__c();
        objHeaderLayout.SVMXC__Object_Name__c = 'SVMXC__Checklist__c';
        objHeaderLayout.SVMXC__Type__c = 'Header';
        objHeaderLayout.SVMXC__Page_Layout_ID__c = 'TESTPAGE001';
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
        return objHeaderLayout;
    }
    static testMethod void test_saveQuestionInfo() {
        Test.startTest();
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
        SVMXC.SFM_WrapperDef2.SFM2_Response response = new SFM_QuestionBankUtils().saveQuestionInfo( questionInfo );
        System.assert(response.success);
        questionInfo.sfmRule = null;
        questionInfo.questionId = ((SFM_WrapperDef2.SFM2_QuestionMeta) response.data).questionId;
        questionInfo.questionExtId = ((SFM_WrapperDef2.SFM2_QuestionMeta) response.data).questionExtId;
        response = new SFM_QuestionBankUtils().saveQuestionInfo( questionInfo );
        System.assert(response.success);
        Test.stopTest();
    }
    static testMethod void test_saveQuestionInfo_exception() {
        Test.startTest();
        Test.setReadOnlyApplicationMode(true);
        final SFM_WrapperDef2.SFM2_QuestionMeta questionInfo = new SFM_WrapperDef2.SFM2_QuestionMeta();
        questionInfo.question = 'Test question?';
        questionInfo.qType = 'Text';
        try {
            SVMXC.SFM_WrapperDef2.SFM2_Response response = new SFM_QuestionBankUtils().saveQuestionInfo( questionInfo );
        }
        catch( Exception e ) {
            System.assert(true);
        }
        Test.stopTest();
    }
    static testMethod void test_saveQuestionInfo_invalid_request() {
        Test.startTest();
        SVMXC.SFM_WrapperDef2.SFM2_Response response = new SFM_QuestionBankUtils().saveQuestionInfo( null );
        System.assert(!response.success);
        final SFM_WrapperDef2.SFM2_QuestionMeta questionInfo = new SFM_WrapperDef2.SFM2_QuestionMeta();
        questionInfo.question = 'Test question?';
        questionInfo.qType = null;
        response = new SFM_QuestionBankUtils().saveQuestionInfo( questionInfo );
        System.assert(!response.success);
        questionInfo.qType = '';
        response = new SFM_QuestionBankUtils().saveQuestionInfo( questionInfo );
        System.assert(!response.success);
        Test.stopTest();
    }
    static testMethod void test_saveQuestionInfo_with_invalid_responseSet() {
        Test.startTest();
        final SFM_WrapperDef2.SFM2_QuestionMeta questionInfo = new SFM_WrapperDef2.SFM2_QuestionMeta();
        questionInfo.question = 'Test question?';
        questionInfo.qType = 'Checkbox';
        SVMXC.SFM_WrapperDef2.SFM2_Response response = new SFM_QuestionBankUtils().saveQuestionInfo( questionInfo );
        System.assert(!response.success);
        Test.stopTest();
    }
    static testMethod void test_saveQuestionInfo_with_invalid_externalId() {
        Test.startTest();
        final SFM_WrapperDef2.SFM2_QuestionMeta questionInfo = new SFM_WrapperDef2.SFM2_QuestionMeta();
        questionInfo.questionId = 'questionId';
        questionInfo.question = 'Test question?';
        questionInfo.qType = 'Text';
        SVMXC.SFM_WrapperDef2.SFM2_Response response = new SFM_QuestionBankUtils().saveQuestionInfo( questionInfo );
        System.assert(!response.success);
        Test.stopTest();
    }
    static testMethod void test_generateQuestionId() {
        Test.startTest();
        final SFM_WrapperDef2.SFM2_QuestionMeta questionInfo = new SFM_WrapperDef2.SFM2_QuestionMeta();
        questionInfo.question = 'Test question?';
        questionInfo.qType = 'Text';
        SVMXC.SFM_WrapperDef2.SFM2_Response response = new SFM_QuestionBankUtils().saveQuestionInfo( questionInfo );
        System.assert(response.success);
        final String questionId = new SFM_QuestionBankUtils().generateQuestionId();
        System.assertEquals('QB000002', questionId);
        Test.stopTest();
    }
}