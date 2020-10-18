@isTest(SeeAllData=true)
Private class SFM_GetListOfProcesses_UT{

    static testMethod void SFM_getListOfProcesses_test(){
        
        //create temp data
        createData();
        //*****Variable declaration and data creation*****
        Boolean response_success;
        String response_message;
        String response_tagId;
        SFM_getListOfProcesses listprocess = new SFM_getListOfProcesses ();
        List<SVMXC__ServiceMax_Processes__c> list_processNodes = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c processNodes = new SVMXC__ServiceMax_Processes__c(SVMXC__Name__C='ProcessNode1');
        System.assertEquals(true, processNodes != null);
        list_processNodes.add(processNodes);
        SFM_WrapperDef.SFM_Response_ProcessNode oResponseNode = new SFM_WrapperDef.SFM_Response_ProcessNode(list_processNodes);
        System.assertEquals(true, oResponseNode != null);
        
        
        //*****instance of debug log class and other calsses*****
        SVMX_Debug  log = new SVMX_Debug();
        
        
        //*****Calling various methods and wrapper classes in SFM_getListOfProcesses*****
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        oResponseNode.response.success = response_success;
        oResponseNode.response.logMsg=log.getlog();
        oResponseNode.response.message = response_message;
        system.debug('*****TEST LOG101: '+oResponseNode);
        listprocess.GetAllProcesses(request);
        system.debug('*****listprocess.GetAllProcesses(request)'+listprocess.GetAllProcesses(request));
        System.assertEquals(true, listprocess.GetAllProcesses(request) != null);
        list<SVMXC.SFM_WrapperDef.SFM_StringMap> lstStringMap = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        SVMXC.SFM_WrapperDef.SFM_StringMap stringMap = new  SVMXC.SFM_WrapperDef.SFM_StringMap();
        stringMap.key = 'SHOWPRIVATE';
        stringMap.value = 'YES';
        lstStringMap.add(stringMap);
        request = new SFM_WrapperDef.SFM_Request();
        request.stringMap = lstStringMap;
        listprocess.GetAllProcesses(request);
        SVMXC.SFM_WrapperDef.SFM_StringMap stringMap1 = new  SVMXC.SFM_WrapperDef.SFM_StringMap();
        stringMap1.key = 'LINKEDPROCESS';
        stringMap1.value = 'YES';
        lstStringMap.add(stringMap1);
        SVMXC.SFM_WrapperDef.SFM_StringMap stringMap2 = new  SVMXC.SFM_WrapperDef.SFM_StringMap();
        stringMap2.key = 'OBJECTNAME';
        stringMap2.value = 'SVMXC_Service_Order_Line__c';
        lstStringMap.add(stringMap2);
        request = new SFM_WrapperDef.SFM_Request();
        request.stringMap = lstStringMap;
        listprocess.GetAllProcesses(request);
        
    }
    
    static void createData(){
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
        
        SVMXC__Service_Order__c objWO  = new SVMXC__Service_Order__c();
        insert objWO;
        
        SVMXC__Checklist__c objChecklist = new SVMXC__Checklist__c();
        objChecklist.SVMXC__ChecklistJSON__c = '{"test":"value"}';
        objChecklist.SVMXC__ChecklistMetaJSON__c = '{"test":"value"}';
        objChecklist.SVMXC__ChecklistProcessID__c = ChecklistProcess.id;
        objChecklist.SVMXC__Completed_By__c = Userinfo.getUserId();
        objChecklist.SVMXC__Completed_On__c = System.Today();
        objChecklist.SVMXC__Status__c = 'Completed';
        objChecklist.SVMXC__What_Id__c = String.ValueOf(objWO.id);
        insert objChecklist;
    }
    
    static testMethod void SFM_getCountOfProcesses_test(){
        //create temp data
        createData();
        
        list<SVMXC.SFM_WrapperDef.SFM_StringMap> lstStringMap = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        SVMXC.SFM_WrapperDef.SFM_StringMap stringMap = new  SVMXC.SFM_WrapperDef.SFM_StringMap();
        stringMap.key = 'PROCESSID';
        stringMap.value = 'TESTPROCESS001';
        lstStringMap.add(stringMap);
        stringMap = new  SVMXC.SFM_WrapperDef.SFM_StringMap();
        stringMap.key = 'PAGEID';
        stringMap.value = 'TESTPAGE001'; 
        lstStringMap.add(stringMap);
        
        SFM_getListOfProcesses countProcess = new SFM_getListOfProcesses ();
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
        request.stringMap = lstStringMap;
        response = countProcess.getCountOfProcesses(request);
                
        System.assertEquals(false, response.success);
    }
    
}