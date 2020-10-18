@isTest
public class SFM_CheckListUtils_UT {
    public static Map<String,Id> recordTypeIdMap = new Map<String,Id>();
    
    
    @isTest static void SFM_GetListOfChecklist_ValidReqTest() 
    {
        getRecordTypeIds();
        Test.startTest();
        Id accountId = createTestAccount();
        Id contactId = createTestContact(accountId); 
        Id casesId = createTestCase(accountId);
        Id workOrderId = createTestWorkOrder(accountId,contactId,casesId);
        Id expressionProcessID = createExpressionProcess('SVMXC__Service_Order__c');
        Id targetManagerProcessId = createTargetManagerProcess('SVMXC__Service_Order__c', 'Checklist_Test0001');
        createNodeObjectProcess(targetManagerProcessId,expressionProcessID, 'SVMXC__Service_Order__c');
        createChecklistRec(targetManagerProcessId,workOrderId);
        try
        {
            SFM_CheckListUtils cklsUtils = new SFM_CheckListUtils();
            
            SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
            SVMXC.SFM_WrapperDef.SFM_Response response = new SVMXC.SFM_WrapperDef.SFM_Response();
            List<SVMXC.SFM_WrapperDef.SFM_StringMap> stringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
            SVMXC.SFM_WrapperDef.SFM_StringMap stringMapElement = new SVMXC.SFM_WrapperDef.SFM_StringMap();
            stringMapElement.key = 'RECORDID';
            stringMapElement.value = workOrderId;
            
            stringMap.add( stringMapElement );
            request.stringMap = stringMap;
            system.debug('StringMap :' + request);  
            response = cklsUtils.SFM_GetListOfChecklist(request); 
            System.assert(response.lstChecklistInfo.size() > 0,'SFM_GetListOfChecklist_ValidReqTest UT Failed.');
        }
        catch(exception ex){
            System.assert(false,ex.getMessage());
        }
        
        Test.stopTest();
    }

    @isTest static void SFM_GetListOfChecklist_ValidReqTestWithReferenceField() 
    {
        getRecordTypeIds();
        Test.startTest();
        Account account = new Account( Name = 'Starline Cars'); 
        insert account; 
        Id contactId = createTestContact(account.id); 
        Id casesId = createTestCase(account.id);
        Id workOrderId = createTestWorkOrder(account.id,contactId,casesId);
        Id expressionProcessID = createExpressionProcessForReferenceField('SVMXC__Service_Order__c');
        Id targetManagerProcessId = createTargetManagerProcess('SVMXC__Service_Order__c', 'Checklist_Test0001');
        createNodeObjectProcess(targetManagerProcessId,expressionProcessID, 'SVMXC__Service_Order__c');
        createChecklistRec(targetManagerProcessId,workOrderId);
        try
        {
            SFM_CheckListUtils cklsUtils = new SFM_CheckListUtils();
            
            SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
            SVMXC.SFM_WrapperDef.SFM_Response response = new SVMXC.SFM_WrapperDef.SFM_Response();
            List<SVMXC.SFM_WrapperDef.SFM_StringMap> stringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
            SVMXC.SFM_WrapperDef.SFM_StringMap stringMapElement = new SVMXC.SFM_WrapperDef.SFM_StringMap();
            stringMapElement.key = 'RECORDID';
            stringMapElement.value = workOrderId;
            
            stringMap.add( stringMapElement );
            request.stringMap = stringMap;
            system.debug('StringMap :' + request);  
            response = cklsUtils.SFM_GetListOfChecklist(request); 
            System.assert(response.lstChecklistInfo.size() > 0,'SFM_GetListOfChecklist_ValidReqTest UT Failed.');
        }
        catch(exception ex){
            System.assert(false,ex.getMessage());
        }
        
        Test.stopTest();
    }
    
    static testMethod void SFM_GetListOfChecklist_InvalidReqTest() 
    {
        Test.startTest();
        
        try
        {
            SFM_CheckListUtils cklsUtils = new SFM_CheckListUtils();
            
            SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
            SVMXC.SFM_WrapperDef.SFM_Response response = new SVMXC.SFM_WrapperDef.SFM_Response();
            request = null;
            
            response = cklsUtils.SFM_GetListOfChecklist(request); 
            
            System.assert(response.lstChecklistInfo.size()==0,'SFM_GetListOfChecklist_InvalidReqTest UT Failied.');
        }
        catch(exception ex){
            System.assert(false,ex.getMessage());
        }
    
        Test.stopTest();
    }
    
    public static Id createTestAccount(){
        // Create Account
        Account account = new Account( Name = 'Account',
                ShippingStreet = 'ABC001',
                ShippingCity = 'PQR001',
                ShippingState = 'XYZ001',
                ShippingPostalCode = '111001',
                ShippingCountry = 'XYZ001',
                BillingStreet = 'ABC001',
                BillingCity = 'PQR001',
                BillingState = 'XYZ001',
                BillingPostalCode = '111001',
                BillingCountry = 'XYZ001'); 
        insert account;  
        return account.Id;
    }
    
    public static Id createTestContact(Id accountId){
        // Create Contact
        Contact contact = new Contact( LastName='Last001',
                AccountId = accountId,
                Email = 'svmxmailfortest@servicemax.com');
        insert contact;
        return contact.Id;        
    }
    
    public static Id createTestCase(Id accountid){
        //Create Case
        Case caseobj = new Case( Origin='Web', Status='Low', 
                AccountId = accountId);
        insert caseobj;
        return caseobj.Id;
    }
    
    public static Id createTestWorkOrder(Id accountId,Id contactId, Id casesId){
        // Create workorder
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c( 
                SVMXC__Company__c = accountId,
                SVMXC__Contact__c = contactId,
                SVMXC__Case__c = casesId,
                SVMXC__Order_Status__c = 'Open' );
                
        insert workOrder;       
        return workOrder.id;
    }
    
    public static Id createExpressionProcess(String sourceObj){
        SVMXC__ServiceMax_Processes__c expressionProcess = businessProcessRule(sourceObj);
        
        SVMXC__ServiceMax_Config_Data__c expressionConfig = businessProcessConfigRecord(expressionProcess.Id);
        return expressionProcess.Id;
    }

    public static SVMXC__ServiceMax_Processes__c businessProcessRuleForReferenceField(String sourceObj){
        SVMXC__ServiceMax_Processes__c expressionProcess = new SVMXC__ServiceMax_Processes__c();
        expressionProcess.RecordTypeId = recordTypeIdMap.get('SVMX_Rule');
        expressionProcess.SVMXC__Name__c = 'Test Rule Expression';
        expressionProcess.SVMXC__ProcessID__c = 'Test_Rule_Expression_for_CheckList';
        expressionProcess.SVMXC__Rule_Type__c = 'Named Expression';
        expressionProcess.SVMXC__Source_Object_Name__c = sourceObj;//'SVMXC__Service_Order__c';
        expressionProcess.SVMXC__Parent_Error_Msg__c = 'This record does not meet the qualification criteria for this SFM Transaction';
        expressionProcess.SVMXC__Parent_Object_Criteria__c = 'SVMXC__Account__r.Name=\'Starline Cars\'';
        expressionProcess.SVMXC__SettingID__c = 'Test_Rule_Expression_for_CheckList';  
        
        insert expressionProcess;
        return expressionProcess;
    }
    
    public static SVMXC__ServiceMax_Config_Data__c businessProcessConfigRecordForReferenceField(Id businessRuleId){
        SVMXC__ServiceMax_Config_Data__c expressionConfig = new SVMXC__ServiceMax_Config_Data__c();
        expressionConfig.RecordTypeId = recordTypeIdMap.get('Expressions');
        expressionConfig.SVMXC__Field_Name__c = 'SVMXC__Company__c';
        expressionConfig.SVMXC__Field_Relationship_Name__c = 'SVMXC__Company__r';
        expressionConfig.SVMXC__Display_Type__c = 'REFERENCE';
        expressionConfig.SVMXC__Expression_Type__c = 'EXP_Named';
        expressionConfig.SVMXC__Operand__c = 'Starline Cars';
        expressionConfig.SVMXC__Operator__c = 'eq';
        expressionConfig.SVMXC__Sort_Order__c = 'Ascending';
        expressionConfig.SVMXC__FKey_Name_Field__c = 'Name';
        expressionConfig.SVMXC__Sequence__c = 1.0;
        expressionConfig.SVMXC__Expression_Rule__c = businessRuleId;
        insert expressionConfig;
        return expressionConfig;
    } 

    public static Id createExpressionProcessForReferenceField(String sourceObj){
        SVMXC__ServiceMax_Processes__c expressionProcess = businessProcessRuleForReferenceField(sourceObj);
        
        SVMXC__ServiceMax_Config_Data__c expressionConfig = businessProcessConfigRecordForReferenceField(expressionProcess.Id);
        return expressionProcess.Id;
    }
    
    public static SVMXC__ServiceMax_Processes__c businessProcessRule(String sourceObj){
        SVMXC__ServiceMax_Processes__c expressionProcess = new SVMXC__ServiceMax_Processes__c();
        expressionProcess.RecordTypeId = recordTypeIdMap.get('SVMX_Rule');
        expressionProcess.SVMXC__Name__c = 'Test Rule Expression';
        expressionProcess.SVMXC__ProcessID__c = 'Test_Rule_Expression_for_CheckList';
        expressionProcess.SVMXC__Rule_Type__c = 'Named Expression';
        expressionProcess.SVMXC__Source_Object_Name__c = sourceObj;//'SVMXC__Service_Order__c';
        expressionProcess.SVMXC__Parent_Error_Msg__c = 'This record does not meet the qualification criteria for this SFM Transaction';
        expressionProcess.SVMXC__Parent_Object_Criteria__c = 'SVMXC__Order_Status__c = \'Open\'';
        expressionProcess.SVMXC__SettingID__c = 'Test_Rule_Expression_for_CheckList';  
        
        insert expressionProcess;
        return expressionProcess;
    }
    
    public static SVMXC__ServiceMax_Config_Data__c businessProcessConfigRecord(Id businessRuleId){
        SVMXC__ServiceMax_Config_Data__c expressionConfig = new SVMXC__ServiceMax_Config_Data__c();
        expressionConfig.RecordTypeId = recordTypeIdMap.get('Expressions');
        expressionConfig.SVMXC__Field_Name__c = 'SVMXC__Order_Status__c';
        expressionConfig.SVMXC__Display_Type__c = 'PICKLIST';
        expressionConfig.SVMXC__Expression_Type__c = 'EXP_Named';
        expressionConfig.SVMXC__Ownership_Type__c = 'All Records';
        expressionConfig.SVMXC__Operand__c = 'Open';
        expressionConfig.SVMXC__Operator__c = 'eq';
        expressionConfig.SVMXC__Sort_Order__c = 'Ascending';
        expressionConfig.SVMXC__Sequence__c = 1.0;
        expressionConfig.SVMXC__Expression_Rule__c = businessRuleId;
        insert expressionConfig;
        return expressionConfig;
    }    

    public static Id createTargetManagerProcess(String sourceObj, String processName){
        SVMXC__ServiceMax_Processes__c checklistTargetRecord = new SVMXC__ServiceMax_Processes__c();
        checklistTargetRecord.RecordTypeId = recordTypeIdMap.get('Target_Manager');
        checklistTargetRecord.SVMXC__Name__c = processName;
        checklistTargetRecord.SVMXC__ProcessID__c = processName;
        checklistTargetRecord.SVMXC__Purpose__c = 'CHECKLIST';
        checklistTargetRecord.SVMXC__Source_Object_Name__c = sourceObj;//'SVMXC__Service_Order__c';
        checklistTargetRecord.SVMXC__Dispatch_Process_Status__c = 'Complete';
        checklistTargetRecord.SVMXC__Tag_Keys__c = 'Checklist_Test0001';
        checklistTargetRecord.SVMXC__Page_Layout__c = createPageLayoutWithQuestion(processName);
        insert checklistTargetRecord;  
        return checklistTargetRecord.Id;
    }

    public static Id createPageLayoutWithQuestion(String processId){
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
        objHeaderLayout.SVMXC__Page_Layout_ID__c = processId+'_CHK';
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
        objfld1.SVMXC__SM_Checklist_Source_Field_API_Name__c = 'SVMXC__Billing_Type__c';
        insert objfld1;

        return objHeaderLayout.id;
    }
    
    public static void createNodeObjectProcess(Id targetProcessId, Id expressionId, String sourceObj){
        List<SVMXC__ServiceMax_Processes__c> processNodeList = new List<SVMXC__ServiceMax_Processes__c> ();
        SVMXC__ServiceMax_Processes__c checklistProcesses = new SVMXC__ServiceMax_Processes__c();
        checklistProcesses.RecordTypeId = recordTypeIdMap.get('Process_Node_Objects');
        checklistProcesses.SVMXC__Name__c = 'Checklist Test0001';
        checklistProcesses.SVMXC__ProcessID__c = 'Checklist_Test0001';
        checklistProcesses.SVMXC__Process__c = targetProcessId;
        checklistProcesses.SVMXC__Type__c = 'SOURCE';
        checklistProcesses.SVMXC__Source_Object_Name__c = sourceObj; //'SVMXC__Service_Order__c';
        processNodeList.add(checklistProcesses);
       
        SVMXC__ServiceMax_Processes__c checklistProcessesTarget = new SVMXC__ServiceMax_Processes__c();
        checklistProcessesTarget.RecordTypeId = recordTypeIdMap.get('Process_Node_Objects');
        checklistProcessesTarget.SVMXC__Name__c = 'Checklist Test0001';
        checklistProcessesTarget.SVMXC__ProcessID__c = 'Checklist_Test0001';
        checklistProcessesTarget.SVMXC__Process__c = targetProcessId;
        checklistProcessesTarget.SVMXC__Source_Object_Name__c = 'SVMXC__Checklist__c';
        checklistProcessesTarget.SVMXC__Type__c = 'TARGET';
        checklistProcessesTarget.SVMXC__Node_Source_Object_API__c = sourceObj; //'SVMXC__Service_Order__c';
        checklistProcessesTarget.SVMXC__Submodule__c = expressionId;
        processNodeList.add(checklistProcessesTarget);
        insert processNodeList;    
    }
    
    public static void createChecklistRec(Id ProcessId,Id workOrderId){
        SVMXC__Checklist__c checkListRec = new SVMXC__Checklist__c();
        checkListRec.SVMXC__ChecklistProcessID__c = ProcessId;
        checkListRec.SVMXC__What_Id__c = workOrderId;
        checkListRec.SVMXC__Status__c = 'Completed';
        insert checkListRec;
    }
        
    public static void getRecordTypeIds(){
        for(RecordType rec : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType IN ('SVMXC__ServiceMax_Processes__c','SVMXC__ServiceMax_Config_Data__c') AND isActive = true]){
           recordTypeIdMap.put(rec.DeveloperName, rec.Id); 
        }
    }

}