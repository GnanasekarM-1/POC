@isTest
private with sharing class SFM_GetProcessInfo_UT
{
    static testMethod void SFM_getProcessInfoUnitTest()
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
        		strLinkedProcess = r.id;
    		else if(R.Name == 'Business Rule')
        		BizRuleRTypeId = r.id;
    		else if(R.Name == 'Process Business Rule')
        		ProBizRuleRTypeId = r.id;
    		else if(R.Name == 'Expressions')
        		ExpressionRTypeId = r.id;
    		    
        }
        //----------------------------------DATA CREATION------------------------------------
        //---------Creating the process object
        SVMXC__ServiceMax_Processes__c processNodes = new SVMXC__ServiceMax_Processes__c();
        processNodes.RecordTypeId = TargetManager;
        processNodes.SVMXC__Name__c = 'process1';
        processNodes.SVMXC__Description__c = 'newprocess1';
        processNodes.SVMXC__ProcessID__c = 'process1';
        processNodes.SVMXC__IsStandard__c = true;
        processNodes.SVMXC__Purpose__c = 'STANDALONE EDIT';
        insert processNodes;
        System.assertEquals(true, lstRecType != null);
        
        //Creating Request Object to pass as a parameter to the Method of the Class
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        
        //----------Creating StringMap
        SFM_WrapperDef.SFM_StringMap Stringmapcls1 = new SFM_WrapperDef.SFM_StringMap('RECORDID',processNodes.Id);
        List<SFM_WrapperDef.SFM_StringMap> ListOfStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        ListOfStringMap.add(Stringmapcls1);
                
        request.StringMap = ListOfStringMap;
        
        //Creating List of ProcessNodeObject        
        List<SVMXC__ServiceMax_Processes__c> processNodeObject = new List<SVMXC__ServiceMax_Processes__c>();
        
        SVMXC__ServiceMax_Processes__c processNodeObject1 = new SVMXC__ServiceMax_Processes__c();
        processNodeObject1.SVMXC__ProcessID__c = 'process2';
        processNodeObject1.SVMXC__Source_Object_Name__c = 'Account';
        processNodeObject1.SVMXC__Type__c = 'TARGETCHILD';
        processNodeObject1.SVMXC__Process__c = processNodes.Id;
        processNodeObject1.RecordTypeId =  ProcessNodeObj;
        upsert processNodeObject1;
        System.assertEquals(true, processNodeObject1 != null);
        
        SVMXC__ServiceMax_Processes__c processNodeObject2 = new SVMXC__ServiceMax_Processes__c();
        processNodeObject2.SVMXC__ProcessID__c = 'process3';
        processNodeObject2.SVMXC__Source_Object_Name__c = 'Contact';
        processNodeObject2.SVMXC__Type__c = 'TARGET';
        processNodeObject2.SVMXC__Process__c = processNodes.Id;
        processNodeObject2.RecordTypeId =  ProcessNodeObj;
        upsert processNodeObject2;
        System.assertEquals(true, processNodeObject2 != null);
        
        //Create Linkd Processe 
        SVMXC__ServiceMax_Processes__c linkedProcess = new SVMXC__ServiceMax_Processes__c();
        linkedProcess.RecordTypeId = strLinkedProcess;
        linkedProcess.SVMXC__Process1__c = processNodes.id;
        linkedProcess.SVMXC__Process2__c = processNodeObject1.id;
        linkedProcess.SVMXC__Process3__c = processNodes.id;
        insert linkedProcess;
        
        //Biz Rules data
        SVMXC__ServiceMax_Processes__c BizRule1 = new SVMXC__ServiceMax_Processes__c();
		BizRule1.RecordTypeId = BizRuleRTypeId;
        BizRule1.SVMXC__Name__c = 'Test Biz Rule 001';
        BizRule1.SVMXC__ProcessID__c = 'My_Biz_Rule_001';
        BizRule1.SVMXC__Description__c = 'Test Biz Rule 001';
        BizRule1.SVMXC__Source_Object_Name__c = 'Account';
        BizRule1.SVMXC__Advance_Expression__c = '';
        BizRule1.SVMXC__Parent_Error_Msg__c = 'Account should be High rating';
        BizRule1.SVMXC__Message_Type__c = 'Error';
        insert BizRule1;
        
        //Biz Rules expressions
        SVMXC__ServiceMax_Config_Data__c BizRuleExpr11 = new SVMXC__ServiceMax_Config_Data__c();
        BizRuleExpr11.RecordTypeId = ExpressionRTypeId;
        BizRuleExpr11.SVMXC__Expression_Rule__c = BizRule1.Id;
        BizRuleExpr11.SVMXC__Expression_Type__c = 'Business_Rule';
        BizRuleExpr11.SVMXC__Sequence__c = 1;
        BizRuleExpr11.SVMXC__Object_Name__c = 'Account';
        BizRuleExpr11.SVMXC__Field_Name__c = 'Rating';
        BizRuleExpr11.SVMXC__Operator__c = 'eq';
        BizRuleExpr11.SVMXC__Operand__c = 'High';
        BizRuleExpr11.SVMXC__Object_Name2__c = 'Account';
        BizRuleExpr11.SVMXC__Display_Type__c = 'String';
        BizRuleExpr11.SVMXC__Field_Relationship_Name__c = NULL;
        BizRuleExpr11.SVMXC__FKey_Name_Field__c = NULL;
        insert BizRuleExpr11;
        
        //Process Biz Rule
        SVMXC__ServiceMax_Processes__c ProBizRule = new SVMXC__ServiceMax_Processes__c();
		ProBizRule.RecordTypeId = ProBizRuleRTypeId;
		ProBizRule.SVMXC__Process1__c = processNodes.Id;
		ProBizRule.SVMXC__Process2__c = processNodeObject1.Id;
		ProBizRule.SVMXC__Process3__c = BizRule1.Id;
		insert ProBizRule;
		
        processNodeObject.add(processNodeObject1);
        processNodeObject.add(processNodeObject2);
        System.assertNotEquals(processNodeObject1, processNodeObject2);
        
        //Creating List of the Config Data
        List<SVMXC__ServiceMax_Config_Data__c> processSourceUpdates = new List<SVMXC__ServiceMax_Config_Data__c>();
                
        SVMXC__ServiceMax_Config_Data__c svmxcd1 = new SVMXC__ServiceMax_Config_Data__c();
        svmxcd1.SVMXC__Dispatch_Process__c = processNodes.Id;
        svmxcd1.SVMXC__MapID__c = processNodes.Id;
        svmxcd1.SVMXC__Source_Field_Name__c = 'AVMXCX1configdata';
        svmxcd1.SVMXC__Setting_ID__c = processNodes.Id;
        processSourceUpdates.add(svmxcd1);
        
        SVMXC__ServiceMax_Config_Data__c svmxcd2 = new SVMXC__ServiceMax_Config_Data__c();
        svmxcd2.SVMXC__Dispatch_Process__c = processNodes.Id;
        svmxcd2.SVMXC__MapID__c = processNodes.Id;
        svmxcd2.SVMXC__Source_Field_Name__c = 'AVMXCX1configdata123';
        svmxcd2.SVMXC__Setting_ID__c = processNodes.Id;
        processSourceUpdates.add(svmxcd2);
        
        upsert processSourceUpdates;
        System.assertEquals(true, processSourceUpdates != null);

        //-----Creating Object of main Class and Calling the Method------
        SFM_getProcessInfo getprocessinfo = new SFM_getProcessInfo();
        getprocessinfo.getProcessInfo(request);
    }
}