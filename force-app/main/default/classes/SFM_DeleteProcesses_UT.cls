@isTest
Private class SFM_DeleteProcesses_UT{

    static testMethod void SFM_deleteProcesses_Test(){
    
        //*****Variable declaration and data creation*****
        
        
        String strLinkedProcess = '';
        String strTargetManager = '';
        String strProcessNodeObject = '';
        list<RecordType> RTypeList = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c'];
        for(RecordType R : RTypeList){
            if(R.Name == 'Target Manager')
                strTargetManager = R.id;
            else if(R.Name == 'Linked Process')
                strLinkedProcess = R.id;
            else if(R.Name == 'Process Node Objects')
                strProcessNodeObject = R.id;        
        }
        
        //Create PageHeader
        SVMXC__Page_Layout__c PageHeader = new SVMXC__Page_Layout__c();
        PageHeader.SVMXC__Name__c = 'PAGE00001';
        PageHeader.SVMXC__Object_Name__c = 'SVMXC__Quote__c';
        PageHeader.SVMXC__Type__c = 'Header';
        insert PageHeader;
        //Create PageDetail
        SVMXC__Page_Layout__c PageDetail = new SVMXC__Page_Layout__c();
        PageDetail.SVMXC__Header_Page_Layout__c = PageHeader.id;
        PageDetail.SVMXC__Object_Name__c = 'SVMXC__Quote_Line__c';
        PageDetail.SVMXC__Type__c = 'Detail';
        insert PageDetail;
        
        //Create SFM Process Defination
        SVMXC__ServiceMax_Processes__c standaloneCreate = new SVMXC__ServiceMax_Processes__c();
        standaloneCreate.SVMXC__Name__c = 'CUSTOMPRO0001';
        standaloneCreate.RecordTypeId = strTargetManager;
        standaloneCreate.SVMXC__Purpose__c = 'STANDALONE CREATE';
        standaloneCreate.SVMXC__ProcessID__c = 'CUSTOMPRO0001';
        standaloneCreate.SVMXC__Page_Layout__c = PageHeader.id;
        insert standaloneCreate;
        
        
        //Create Process Node object Records.
        SVMXC__ServiceMax_Processes__c PNObject1 = new SVMXC__ServiceMax_Processes__c();
        PNObject1.RecordTypeId = strProcessNodeObject;
        PNObject1.SVMXC__Type__c = 'TARGET';
        PNObject1.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
        PNObject1.SVMXC__Process__c = standaloneCreate.id;
        insert PNObject1;
        
        SVMXC__ServiceMax_Processes__c PNObject2 = new SVMXC__ServiceMax_Processes__c();
        PNObject2.RecordTypeId = strProcessNodeObject;
        PNObject2.SVMXC__Type__c = 'TARGETCHILD';
        PNObject2.SVMXC__Page_Layout__c = PageDetail.id;
        PNObject2.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
        PNObject2.SVMXC__Parent_Column_Name__c = 'SVMXC__Quote__c';
        PNObject2.SVMXC__Process__c = standaloneCreate.id;
        insert PNObject2;
        
        //Create Linkd Processe 
        SVMXC__ServiceMax_Processes__c linkedProcess = new SVMXC__ServiceMax_Processes__c();
        linkedProcess.RecordTypeId = strLinkedProcess;
        linkedProcess.SVMXC__Process1__c = standaloneCreate.id;
        linkedProcess.SVMXC__Process2__c = PNObject1.id;
        linkedProcess.SVMXC__Process3__c = PNObject2.id;
        insert linkedProcess;
              
        Test.startTest();
        SVMXC.SFM_deleteProcesses delt_Process = new SVMXC.SFM_deleteProcesses();
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
        SVMXC.SFM_WrapperDef.SFM_StringMap objSFM_StringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap('RECORDID', standaloneCreate.id);
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        lstStringMap.add(ObjSFM_StringMap);
        request.stringMap = lstStringMap;
        delt_Process.DeleteProcesses(request);
        
        //Create process 
        SVMXC__ServiceMax_Processes__c standaloneCreate1 = new SVMXC__ServiceMax_Processes__c();
        standaloneCreate1.SVMXC__Name__c = 'CUSTOMPRO000111';
        standaloneCreate1.RecordTypeId = strTargetManager;
        standaloneCreate1.SVMXC__Purpose__c = 'STANDALONE CREATE';
        standaloneCreate1.SVMXC__ProcessID__c = 'CUSTOMPRO000111';
        standaloneCreate1.SVMXC__Page_Layout__c = PageHeader.id;
        insert standaloneCreate1;
        
        SVMXC__ServiceMax_Processes__c PNObject3 = new SVMXC__ServiceMax_Processes__c();
        PNObject3.RecordTypeId = strProcessNodeObject;
        PNObject3.SVMXC__Type__c = 'TARGET';
        PNObject3.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
        PNObject3.SVMXC__Process__c = standaloneCreate1.id;
        insert PNObject3;
        
        SVMXC__ServiceMax_Processes__c linkedProcess1 = new SVMXC__ServiceMax_Processes__c();
        linkedProcess1.RecordTypeId = strLinkedProcess;
        linkedProcess1.SVMXC__Process1__c = standaloneCreate1.id;
        linkedProcess1.SVMXC__Process2__c = PNObject3.id;
        linkedProcess1.SVMXC__Process3__c = standaloneCreate1.id;
        insert linkedProcess1;
        
        request = new SVMXC.SFM_WrapperDef.SFM_Request();
        objSFM_StringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap('RECORDID', standaloneCreate1.id);
        lstStringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        lstStringMap.add(ObjSFM_StringMap);
        request.stringMap = lstStringMap;
        delt_Process.DeleteProcesses(request);
        Test.stopTest();
        
    }
    
    static testMethod void SFM_deleteProcesses_Test1(){
    
        //*****Variable declaration and data creation*****
        
        
        String strLinkedProcess = '';
        String strTargetManager = '';
        String strProcessNodeObject = '';
        list<RecordType> RTypeList = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c'];
        for(RecordType R : RTypeList){
            if(R.Name == 'Target Manager')
                strTargetManager = R.id;
            else if(R.Name == 'Linked Process')
                strLinkedProcess = R.id;
            else if(R.Name == 'Process Node Objects')
                strProcessNodeObject = R.id;        
        }
        
        User userTimeZone = [Select Id,TimeZoneSidKey from User where Id =: UserInfo.getUserId()];
        RecordType schedule_Rtype;
        RecordType SFMScheduledProcess_Rtype;
        RecordType scheduleDetail_Rtype;
    
        List<RecordType> lstRecordType = [select Name,id from RecordType where (Name='Schedule' OR Name='Schedule Detail' OR Name='Schedule Header')AND (SobjectType='SVMXC__ServiceMax_Config_Data__c' OR SobjectType='SVMXC__ServiceMax_Processes__c')];
        for(RecordType rt : lstRecordType){
            if(rt.Name.equals('Schedule'))
                schedule_Rtype = rt;
            else if(rt.Name.equals('Schedule Detail'))
                scheduleDetail_Rtype = rt;
            else if(rt.Name.equals('Schedule Header'))
                SFMScheduledProcess_Rtype = rt;
        }
        
        //Create PageHeader
        SVMXC__Page_Layout__c PageHeader = new SVMXC__Page_Layout__c();
        PageHeader.SVMXC__Name__c = 'PAGE00001';
        PageHeader.SVMXC__Object_Name__c = 'SVMXC__Quote__c';
        PageHeader.SVMXC__Type__c = 'Header';
        insert PageHeader;
        //Create PageDetail
        SVMXC__Page_Layout__c PageDetail = new SVMXC__Page_Layout__c();
        PageDetail.SVMXC__Header_Page_Layout__c = PageHeader.id;
        PageDetail.SVMXC__Object_Name__c = 'SVMXC__Quote_Line__c';
        PageDetail.SVMXC__Type__c = 'Detail';
        insert PageDetail;
        
        //Create SFM Process Defination
        SVMXC__ServiceMax_Processes__c standaloneCreate = new SVMXC__ServiceMax_Processes__c();
        standaloneCreate.SVMXC__Name__c = 'CUSTOMPRO0001';
        standaloneCreate.RecordTypeId = strTargetManager;
        standaloneCreate.SVMXC__Purpose__c = 'STANDALONE CREATE';
        standaloneCreate.SVMXC__ProcessID__c = 'CUSTOMPRO0001';
        standaloneCreate.SVMXC__Page_Layout__c = PageHeader.id;
        insert standaloneCreate;
        
        
        //Create Process Node object Records.
        SVMXC__ServiceMax_Processes__c PNObject1 = new SVMXC__ServiceMax_Processes__c();
        PNObject1.RecordTypeId = strProcessNodeObject;
        PNObject1.SVMXC__Type__c = 'TARGET';
        PNObject1.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
        PNObject1.SVMXC__Process__c = standaloneCreate.id;
        insert PNObject1;
        
        SVMXC__ServiceMax_Processes__c PNObject2 = new SVMXC__ServiceMax_Processes__c();
        PNObject2.RecordTypeId = strProcessNodeObject;
        PNObject2.SVMXC__Type__c = 'TARGETCHILD';
        PNObject2.SVMXC__Page_Layout__c = PageDetail.id;
        PNObject2.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
        PNObject2.SVMXC__Parent_Column_Name__c = 'SVMXC__Quote__c';
        PNObject2.SVMXC__Process__c = standaloneCreate.id;
        insert PNObject2;
        
        //Create Linkd Processe 
        SVMXC__ServiceMax_Processes__c linkedProcess = new SVMXC__ServiceMax_Processes__c();
        linkedProcess.RecordTypeId = strLinkedProcess;
        linkedProcess.SVMXC__Process1__c = standaloneCreate.id;
        linkedProcess.SVMXC__Process2__c = PNObject1.id;
        linkedProcess.SVMXC__Process3__c = PNObject2.id;
        insert linkedProcess;
        
        
        SVMXC__ServiceMax_Processes__c objProcess1 = new SVMXC__ServiceMax_Processes__c();
        objProcess1.SVMXC__ProcessId__c = 'testProcess1';
        objProcess1.SVMXC__Name__c = 'testProcess1';        
        objProcess1.SVMXC__Description__c = 'TestDescription1';
        objProcess1.SVMXC__IsStandard__c = false;
        objProcess1.SVMXC__Active__c = true;            
        objProcess1.SVMXC__Capture_Log__c = true;
        objProcess1.SVMXC__Dispatch_Timezone__c = userTimeZone.TimeZoneSidKey;
        objProcess1.SVMXC__Assign_To_Dispatcher__c = UserInfo.getUserId();
        objProcess1.RecordTypeId = SFMScheduledProcess_Rtype.id;
        insert objProcess1;
        System.assert(objProcess1.id != null);
        
        SVMXC__ServiceMax_Config_Data__c objScheduleDetail = new SVMXC__ServiceMax_Config_Data__c();
        objScheduleDetail.RecordTypeId = scheduleDetail_Rtype.id;
        objScheduleDetail.SVMXC__Dispatch_Process__c = objProcess1.id;
        objScheduleDetail.SVMXC__Expression_Rule__c = standaloneCreate.id;
        insert objScheduleDetail;
        System.assert(objScheduleDetail.id != null);
        
        List<SVMXC__ServiceMax_Config_Data__c> lstSchedule = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c objSchedule = new SVMXC__ServiceMax_Config_Data__c();
        objSchedule.SVMXC__Sequence__c = 1;
        objSchedule.SVMXC__Run_At__c = '00:00 AM';
        objSchedule.SVMXC__Schedule_Days__c = 'Sunday';
        objSchedule.SVMXC__Run_Type__c='Day of Week';
        objSchedule.SVMXC__Dispatch_Process__c = objProcess1.Id;
        objSchedule.RecordTypeId = Schedule_Rtype.Id;
        lstSchedule.add(objSchedule);
        
        SVMXC__ServiceMax_Config_Data__c objSchedule1 = new SVMXC__ServiceMax_Config_Data__c();
        objSchedule1.SVMXC__Sequence__c = 2;
        objSchedule1.SVMXC__Run_At__c = '00:00 AM';
        objSchedule1.SVMXC__Day_to_Run__c = '2';
        objSchedule1.SVMXC__Run_Type__c='Date of Month';
        objSchedule1.SVMXC__Dispatch_Process__c = objProcess1.Id;
        objSchedule1.RecordTypeId = Schedule_Rtype.Id;
        lstSchedule.add(objSchedule1);
        
        insert lstSchedule;
        System.assert(lstSchedule.size() > 0);        
        
        Test.startTest();
        SVMXC.SFM_deleteProcesses delt_Process = new SVMXC.SFM_deleteProcesses();
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
        SVMXC.SFM_WrapperDef.SFM_StringMap objSFM_StringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap('RECORDID', standaloneCreate.id);
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        lstStringMap.add(ObjSFM_StringMap);
        request.stringMap = lstStringMap;
        delt_Process.DeleteProcesses(request);
        
        //Create process 
        SVMXC__ServiceMax_Processes__c standaloneCreate1 = new SVMXC__ServiceMax_Processes__c();
        standaloneCreate1.SVMXC__Name__c = 'CUSTOMPRO000111';
        standaloneCreate1.RecordTypeId = strTargetManager;
        standaloneCreate1.SVMXC__Purpose__c = 'STANDALONE CREATE';
        standaloneCreate1.SVMXC__ProcessID__c = 'CUSTOMPRO000111';
        standaloneCreate1.SVMXC__Page_Layout__c = PageHeader.id;
        insert standaloneCreate1;
        
        SVMXC__ServiceMax_Processes__c PNObject3 = new SVMXC__ServiceMax_Processes__c();
        PNObject3.RecordTypeId = strProcessNodeObject;
        PNObject3.SVMXC__Type__c = 'TARGET';
        PNObject3.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
        PNObject3.SVMXC__Process__c = standaloneCreate1.id;
        insert PNObject3;
        
        SVMXC__ServiceMax_Processes__c linkedProcess1 = new SVMXC__ServiceMax_Processes__c();
        linkedProcess1.RecordTypeId = strLinkedProcess;
        linkedProcess1.SVMXC__Process1__c = standaloneCreate1.id;
        linkedProcess1.SVMXC__Process2__c = PNObject3.id;
        linkedProcess1.SVMXC__Process3__c = standaloneCreate1.id;
        insert linkedProcess1;
        
        request = new SVMXC.SFM_WrapperDef.SFM_Request();
        objSFM_StringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap('RECORDID', standaloneCreate1.id);
        lstStringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        lstStringMap.add(ObjSFM_StringMap);
        request.stringMap = lstStringMap;
        delt_Process.DeleteProcesses(request);
        Test.stopTest();        
    }
    static testMethod void SFM_deleteProcesses_Test2(){
    
        //*****Variable declaration and data creation*****
        
        String strTargetManager = '';
        String strProcessNodeObject = '';
        list<RecordType> RTypeList = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c'];
        for(RecordType R : RTypeList){
            if(R.Name == 'Target Manager')
                strTargetManager = R.id;
            else if(R.Name == 'Process Node Objects')
                strProcessNodeObject = R.id;        
        }
        
        //Create PageHeader
        SVMXC__Page_Layout__c PageHeader = new SVMXC__Page_Layout__c();
        PageHeader.SVMXC__Name__c = 'PAGE00001';
        PageHeader.SVMXC__Object_Name__c = 'SVMXC__Quote__c';
        PageHeader.SVMXC__Type__c = 'Header';
        insert PageHeader;
        //Create PageDetail
        SVMXC__Page_Layout__c PageDetail = new SVMXC__Page_Layout__c();
        PageDetail.SVMXC__Header_Page_Layout__c = PageHeader.id;
        PageDetail.SVMXC__Object_Name__c = 'SVMXC__Quote_Line__c';
        PageDetail.SVMXC__Type__c = 'Detail';
        insert PageDetail;
        
        //Create SFM Process Defination
        SVMXC__ServiceMax_Processes__c standaloneCreate = new SVMXC__ServiceMax_Processes__c();
        standaloneCreate.SVMXC__Name__c = 'CUSTOMPRO0001';
        standaloneCreate.RecordTypeId = strTargetManager;
        standaloneCreate.SVMXC__Purpose__c = 'STANDALONE CREATE';
        standaloneCreate.SVMXC__ProcessID__c = 'CUSTOMPRO0001';
        standaloneCreate.SVMXC__Page_Layout__c = PageHeader.id;
        insert standaloneCreate;
        
        
        //Create Process Node object Records.
        SVMXC__ServiceMax_Processes__c PNObject1 = new SVMXC__ServiceMax_Processes__c();
        PNObject1.RecordTypeId = strProcessNodeObject;
        PNObject1.SVMXC__Type__c = 'TARGET';
        PNObject1.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
        PNObject1.SVMXC__Process__c = standaloneCreate.id;
        insert PNObject1;
        
        SVMXC__ServiceMax_Processes__c PNObject2 = new SVMXC__ServiceMax_Processes__c();
        PNObject2.RecordTypeId = strProcessNodeObject;
        PNObject2.SVMXC__Type__c = 'TARGETCHILD';
        PNObject2.SVMXC__Page_Layout__c = PageDetail.id;
        PNObject2.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
        PNObject2.SVMXC__Parent_Column_Name__c = 'SVMXC__Quote__c';
        PNObject2.SVMXC__Process__c = standaloneCreate.id;
        insert PNObject2; 
        
        Test.startTest();
        SVMXC.SFM_deleteProcesses delt_Process = new SVMXC.SFM_deleteProcesses();
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
        SVMXC.SFM_WrapperDef.SFM_StringMap objSFM_StringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap('RECORDID', standaloneCreate.id);
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        lstStringMap.add(ObjSFM_StringMap);
        request.stringMap = lstStringMap;
        delt_Process.DeleteProcesses(request);
        
        //Create process 
        SVMXC__ServiceMax_Processes__c standaloneCreate1 = new SVMXC__ServiceMax_Processes__c();
        standaloneCreate1.SVMXC__Name__c = 'CUSTOMPRO000111';
        standaloneCreate1.RecordTypeId = strTargetManager;
        standaloneCreate1.SVMXC__Purpose__c = 'STANDALONE CREATE';
        standaloneCreate1.SVMXC__ProcessID__c = 'CUSTOMPRO000111';
        standaloneCreate1.SVMXC__Page_Layout__c = PageHeader.id;
        insert standaloneCreate1;
        
        SVMXC__ServiceMax_Processes__c PNObject3 = new SVMXC__ServiceMax_Processes__c();
        PNObject3.RecordTypeId = strProcessNodeObject;
        PNObject3.SVMXC__Type__c = 'TARGET';
        PNObject3.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
        PNObject3.SVMXC__Process__c = standaloneCreate1.id;
        insert PNObject3;
        
        request = new SVMXC.SFM_WrapperDef.SFM_Request();
        lstStringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        objSFM_StringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap('RECORDID', standaloneCreate1.id);
        lstStringMap.add(ObjSFM_StringMap);
        objSFM_StringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap('FORCEDELETE', 'TRUE');       
        lstStringMap.add(ObjSFM_StringMap);
        request.stringMap = lstStringMap;
        delt_Process.DeleteProcesses(request);
        Test.stopTest();        
    }
    static testMethod void SFM_deleteProcesses_ChecklistPro(){
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
        
        SVMXC.SFM_deleteProcesses delt_Process = new SVMXC.SFM_deleteProcesses();
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
        SVMXC.SFM_WrapperDef.SFM_StringMap objSFM_StringMap = new SVMXC.SFM_WrapperDef.SFM_StringMap('RECORDID', ChecklistProcess.id);
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        lstStringMap.add(ObjSFM_StringMap);
        request.stringMap = lstStringMap;
        SFM_WrapperDef.SFM_Response objResponse = delt_Process.DeleteProcesses(request);
        System.assert(objResponse.success == true);
    }
}