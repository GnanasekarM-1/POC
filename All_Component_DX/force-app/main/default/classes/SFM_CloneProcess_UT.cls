@isTest(SeeAllData=true)
private with sharing class SFM_CloneProcess_UT
{
    static testMethod void SFM_cloneProcessUnitTest()
    {
        List<RecordType> lstRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' OR SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        System.assertEquals(true, lstRecType != null);
        
        String TargetManager = '';
        String ObjectMapping = '';
        String Fieldmapping = '';
        String ProcessNodeObj = '';
        String strLinkedProcess = '';
        String BizRuleRTypeId = '';
        String ProBizRuleRTypeId = '';
        String ExpressionRTypeId = '';
        
        for(RecordType r : lstRecType)
        {
            if(r.Name == 'Target Manager')
                TargetManager = r.id;
            else if(r.Name == 'Object Mapping')  
                ObjectMapping = r.id;
            else if(r.Name == 'Field Mapping')
                Fieldmapping = r.id;    
            else if(r.Name == 'Process Node Objects')    
                ProcessNodeObj = r.id;
            else if(R.Name == 'Linked Process')
                strLinkedProcess = R.id;
            else if(R.Name == 'Business Rule')
                BizRuleRTypeId = r.id;
            else if(R.Name == 'Process Business Rule')
                ProBizRuleRTypeId = r.id;
            else if(R.Name == 'Expressions')
                ExpressionRTypeId = r.id; 
        }
        
        //--------------------------------DATA CREATION----------------------------
        //------------------------Creating the process object----------------------
        SVMXC__ServiceMax_Processes__c processNodes = new SVMXC__ServiceMax_Processes__c();
        processNodes.RecordTypeId = TargetManager ;
        processNodes.SVMXC__Name__c = 'customprocess1';
        processNodes.SVMXC__Description__c = 'newprocess1';
        processNodes.SVMXC__ProcessID__c = 'process1';
        processNodes.SVMXC__IsStandard__c = true;
        processNodes.SVMXC__Purpose__c = 'SOURCE TO TARGET ALL';
        insert processNodes;
        System.assertEquals(true, processNodes != null);
        

        //Creating Request Object to pass as a parameter to the Method of the Class
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();

        //Creating List of StringMap
        List<SFM_WrapperDef.SFM_StringMap> ListOfStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_StringMap Stringmapcls1 = new SFM_WrapperDef.SFM_StringMap('RECORDID',processNodes.Id);
        ListOfStringMap.add(Stringmapcls1);
        request.StringMap = ListOfStringMap;

        //Creating List of ProcessNodeObject        
        List<SVMXC__ServiceMax_Processes__c> processNodeObject = new List<SVMXC__ServiceMax_Processes__c>();

        SVMXC__ServiceMax_Processes__c processNodeObject1 = new SVMXC__ServiceMax_Processes__c();
        processNodeObject1.SVMXC__ProcessID__c = 'process2';
        processNodeObject1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order_Line__c';
        processNodeObject1.SVMXC__Type__c = 'TARGETCHILD';
        processNodeObject1.RecordTypeId = ProcessNodeObj;
        processNodeObject1.SVMXC__Process__c = processNodes.Id;
        processNodeObject1.SVMXC__Node_Parent_API__c = 'SVMXC__Service_Order__c';
        processNodeObject1.SVMXC__Parent_Column_Name__c = 'SVMXC__Service_Order__c';
        upsert processNodeObject1;
        System.assertEquals(true, processNodeObject1 != null);

        SVMXC__ServiceMax_Processes__c processNodeObject2 = new SVMXC__ServiceMax_Processes__c();
        processNodeObject2.SVMXC__ProcessID__c = 'process3';
        processNodeObject2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        processNodeObject2.SVMXC__Type__c = 'TARGET';
        processNodeObject2.SVMXC__Process__c = processNodes.Id;
        processNodeObject2.RecordTypeId = ProcessNodeObj;
        upsert processNodeObject2;
        System.assertEquals(true, processNodeObject2 != null);

        SVMXC__ServiceMax_Processes__c processNodeObject3 = new SVMXC__ServiceMax_Processes__c();
        processNodeObject3.SVMXC__ProcessID__c = 'process4';
        processNodeObject3.SVMXC__Source_Object_Name__c = 'SVMXC__Case_Tracker__c';
        processNodeObject3.SVMXC__Type__c = 'SOURCECHILD';
        processNodeObject3.RecordTypeId = ProcessNodeObj;
        processNodeObject3.SVMXC__Process__c = processNodes.Id;
        processNodeObject3.SVMXC__Node_Parent_API__c = 'Case';
        processNodeObject3.SVMXC__Parent_Column_Name__c = 'SVMXC__Service_Order__c';
        upsert processNodeObject3;
        System.assertEquals(true, processNodeObject3 != null);

        SVMXC__ServiceMax_Processes__c processNodeObject4 = new SVMXC__ServiceMax_Processes__c();
        processNodeObject4.SVMXC__ProcessID__c = 'process5';
        processNodeObject4.SVMXC__Source_Object_Name__c = 'Case';
        processNodeObject4.SVMXC__Type__c = 'SOURCE';
        processNodeObject4.RecordTypeId = ProcessNodeObj;
        processNodeObject4.SVMXC__Process__c = processNodes.Id;
        upsert processNodeObject4;
        System.assertEquals(true, processNodeObject4 != null);

        processNodeObject.add(processNodeObject1);
        processNodeObject.add(processNodeObject2);
        processNodeObject.add(processNodeObject3);
        processNodeObject.add(processNodeObject4);
        upsert processNodeObject;
        System.assertEquals(true, processNodeObject != null);

        //Create Linkd Processe 
        SVMXC__ServiceMax_Processes__c linkedProcess = new SVMXC__ServiceMax_Processes__c();
        linkedProcess.RecordTypeId = strLinkedProcess;
        linkedProcess.SVMXC__Process1__c = processNodes.id;
        linkedProcess.SVMXC__Process2__c = processNodeObject[0].id;
        linkedProcess.SVMXC__Process3__c = processNodes.id;
        insert linkedProcess;
        
        //Biz Rules data
        SVMXC__ServiceMax_Processes__c BizRule1 = new SVMXC__ServiceMax_Processes__c();
        BizRule1.RecordTypeId = BizRuleRTypeId;
        BizRule1.SVMXC__Name__c = 'Test Biz Rule 001';
        BizRule1.SVMXC__ProcessID__c = 'My_Biz_Rule_001';
        BizRule1.SVMXC__Description__c = 'Test Biz Rule 001';
        BizRule1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        BizRule1.SVMXC__Advance_Expression__c = '';
        BizRule1.SVMXC__Parent_Error_Msg__c = 'SVMXC__Service_Order__c should be High Priority, should not be Low priority';
        BizRule1.SVMXC__Message_Type__c = 'Error';
        insert BizRule1;
        
        //Biz Rules expressions
        SVMXC__ServiceMax_Config_Data__c BizRuleExpr11 = new SVMXC__ServiceMax_Config_Data__c();
        BizRuleExpr11.RecordTypeId = ExpressionRTypeId;
        BizRuleExpr11.SVMXC__Expression_Rule__c = BizRule1.Id;
        BizRuleExpr11.SVMXC__Expression_Type__c = 'Business_Rule';
        BizRuleExpr11.SVMXC__Sequence__c = 1;
        BizRuleExpr11.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        BizRuleExpr11.SVMXC__Field_Name__c = 'SVMXC__Priority__c';
        BizRuleExpr11.SVMXC__Operator__c = 'eq';
        BizRuleExpr11.SVMXC__Operand__c = 'High';
        BizRuleExpr11.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        BizRuleExpr11.SVMXC__Display_Type__c = 'Picklist';
        BizRuleExpr11.SVMXC__Field_Relationship_Name__c = NULL;
        BizRuleExpr11.SVMXC__FKey_Name_Field__c = NULL;
        insert BizRuleExpr11;
        
        //Process Biz Rule
        List<SVMXC__ServiceMax_Processes__c> lstProBizRule = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c ProBizRule = new SVMXC__ServiceMax_Processes__c();
        ProBizRule.RecordTypeId = ProBizRuleRTypeId;
        ProBizRule.SVMXC__Process1__c = processNodes.Id;
        ProBizRule.SVMXC__Process2__c = processNodeObject2.Id;
        ProBizRule.SVMXC__Process3__c = BizRule1.Id;
        lstProBizRule.add(ProBizRule);
        insert lstProBizRule;
        
        //Creating List of the Config Data
        List<SVMXC__ServiceMax_Config_Data__c> processSourceUpdates = new List<SVMXC__ServiceMax_Config_Data__c>();
                
        SVMXC__ServiceMax_Config_Data__c svmxcd1 = new SVMXC__ServiceMax_Config_Data__c();
        svmxcd1.SVMXC__Dispatch_Process__c = processNodes.Id;
        svmxcd1.SVMXC__MapID__c = processNodeObject2.Id;
        svmxcd1.SVMXC__Source_Field_Name__c = 'AVMXCX1configdata';
        svmxcd1.SVMXC__Setting_ID__c = processNodeObject2.Id;
        svmxcd1.RecordTypeId = Fieldmapping ;
        insert svmxcd1;
        System.assertEquals(true, svmxcd1 != null);
        

        SVMXC__ServiceMax_Config_Data__c svmxcd2 = new SVMXC__ServiceMax_Config_Data__c();
        svmxcd2.SVMXC__Dispatch_Process__c = processNodes.Id;
        svmxcd2.SVMXC__MapID__c = processNodeObject4.Id;
        svmxcd2.SVMXC__Source_Field_Name__c = 'AVMXCX1configdata123';
        svmxcd2.SVMXC__Setting_ID__c = processNodeObject4.Id;
        svmxcd2.RecordTypeId = Fieldmapping ;
        insert svmxcd2;
        System.assertEquals(true, svmxcd2 != null);
        
        processSourceUpdates.add(svmxcd1);
        processSourceUpdates.add(svmxcd2);

        upsert processSourceUpdates;
        System.assertEquals(true, processSourceUpdates != null);
        
        //Creating List of ProcessNodeCetail for Source and Target Object
        List<SFM_WrapperDef.SFM_ProcessNodeDetail> processNodeTargetObject=new List<SFM_WrapperDef.SFM_ProcessNodeDetail>();
        SFM_WrapperDef.SFM_ProcessNodeDetail processNodeTargetObject1 = new SFM_WrapperDef.SFM_ProcessNodeDetail(processNodeObject2,processSourceUpdates);
        SFM_WrapperDef.SFM_ProcessNodeDetail processNodeTargetObject2 = new SFM_WrapperDef.SFM_ProcessNodeDetail(processNodeObject1,processSourceUpdates);
        processNodeTargetObject2.processBizRules = lstProBizRule;
        processNodeTargetObject.add(processNodeTargetObject1);
        processNodeTargetObject.add(processNodeTargetObject2);
        
        List<SFM_WrapperDef.SFM_ProcessNodeDetail> processNodeSourceObject=new List<SFM_WrapperDef.SFM_ProcessNodeDetail>();
        SFM_WrapperDef.SFM_ProcessNodeDetail processNodeSourceObject1 = new SFM_WrapperDef.SFM_ProcessNodeDetail(processNodeObject4,processSourceUpdates);
        SFM_WrapperDef.SFM_ProcessNodeDetail processNodeSourceObject2 = new SFM_WrapperDef.SFM_ProcessNodeDetail(processNodeObject3,processSourceUpdates);
        processNodeSourceObject.add(processNodeSourceObject1);
        processNodeSourceObject.add(processNodeSourceObject2);
        
        //Creating Object of main Class and Calling the Method
        SFM_cloneProcess testprocess = new SFM_cloneProcess();
        testprocess.cloneProcess(request);
    }
}