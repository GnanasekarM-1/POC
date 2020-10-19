@isTest(SeeAllData=true)
public with sharing class WSCH_FieldMatchRuleEngine_UT {

	static testMethod void WSCH_FieldMatchRuleEngine_Test1(){
		test.startTest();
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               ExpressionRTypeId = rt.ID;
            else if(rt.Name == 'SVMX Rule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                RuleRecordTypeId = rt.id;
        }
        		
        SVMXC__ServiceMax_Processes__c processObj = new SVMXC__ServiceMax_Processes__c();
        processObj.SVMXC__Name__c = 'Score Rule';
        processObj.SVMXC__Description__c='Score Rule';
        processObj.SVMXC__Rule_Type__c = 'Field Match Rule';
        processObj.RecordTypeId = RuleRecordTypeId;
        processObj.SVMXC__Sequence__c = 1;
        processObj.SVMXC__ADVANCE_EXPRESSION__C='1 AND 2';	
        processObj.SVMXC__Source_Object_Name__c='SVMXC__Service_Order__c';
        processObj.SVMXC__Target_Object_Name__c='SVMXC__Service_Group_Members__c';
        processObj.SVMXC__Primary_Consolidation_Rule__c='1 AND 2';
        processObj.SVMXC__Field_Name__c = 'SVMXC__city__c';
        processObj.SVMXC__MapID__c='ScoreMap2';
        processObj.SVMXC__Active__c= true;
        insert processObj;
        
        //adding entry criteria
        SVMXC__ServiceMax_Config_Data__c cfgObj = new SVMXC__ServiceMax_Config_Data__c();
        cfgObj.SVMXC__Expression_Type__c = 'Field Match Expression';
        cfgObj.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
        cfgObj.SVMXC__Display_Type__c = 'PICKLIST';
        cfgObj.SVMXC__Operand__c='Open';
        cfgObj.SVMXC__Operator__c='eq';
        cfgObj.RecordTypeId = ExpressionRTypeId;
        cfgObj.SVMXC__Sequence__c=1;
        cfgObj.SVMXC__Expression_Rule__c = processObj.id;
        insert cfgObj;

        SVMXC__ServiceMax_Config_Data__c cfgObjec = new SVMXC__ServiceMax_Config_Data__c();
        cfgObjec.SVMXC__Expression_Type__c = 'Field Match Expression';
        cfgObjec.SVMXC__Field_Name__c='SVMXC__city__c';
        cfgObjec.SVMXC__Display_Type__c = 'STRING';
        cfgObjec.SVMXC__Operand__c='Austin';
        cfgObjec.SVMXC__Operator__c='eq';
        cfgObjec.RecordTypeId = ExpressionRTypeId;
        cfgObjec.SVMXC__Sequence__c=1;
        cfgObjec.SVMXC__Expression_Rule__c = processObj.id;
        insert cfgObjec;
        
		//adding matching for the fields
       SVMXC__ServiceMax_Config_Data__c cfgObj1 = new SVMXC__ServiceMax_Config_Data__c();
        cfgObj1.RecordTypeId = ExpressionRTypeId;
        cfgObj1.SVMXC__Expression_Rule__c = processObj.id;
        cfgObj1.SVMXC__Expression_Type__c = 'Field Match Lookup';
        cfgObj1.SVMXC__Field_Name__c='SVMXC__city__c';
        cfgObj1.SVMXC__DISPLAY_TYPE__C='STRING';
        cfgObj1.SVMXC__OPERATOR__C='eq';
        cfgObj1.SVMXC__Target_Field_Name__c='SVMXC__city__c';
        cfgObj1.SVMXC__Display_Value__c = 'Austin';
        cfgObj1.SVMXC__SEQUENCE__C=1;
        cfgObj1.SVMXC__Operand__c='123';
        insert cfgObj1;
        
       SVMXC__ServiceMax_Config_Data__c cfgObj1a = new SVMXC__ServiceMax_Config_Data__c();
        cfgObj1a.RecordTypeId = ExpressionRTypeId;
        cfgObj1a.SVMXC__Expression_Rule__c = processObj.id;
        cfgObj1a.SVMXC__Expression_Type__c = 'Field Match Lookup';
        cfgObj1a.SVMXC__Field_Name__c='SVMXC__State__c';
        cfgObj1a.SVMXC__DISPLAY_TYPE__C='STRING';
        cfgObj1a.SVMXC__OPERATOR__C='eq';
        cfgObj1a.SVMXC__Target_Field_Name__c='SVMXC__State__c';
        cfgObj1a.SVMXC__Display_Value__c = 'Austin';
        cfgObj1a.SVMXC__SEQUENCE__C=2;
        cfgObj1a.SVMXC__Operand__c='123';
        insert cfgObj1a;        

		SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
		team.name='Test Team';
		insert team;
		
		SVMXC__Service_Group_Members__c tech = new SVMXC__Service_Group_Members__c();
		tech.Name='Test Tech';
		tech.SVMXC__City__c ='Austin';
		tech.SVMXC__State__c='CA';
		tech.SVMXC__Service_Group__c = team.Id;
		//insert tech;
			
        List<SVMXC__Service_Order__c> workorders = new List<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Order_Status__c='Open';
        wo.SVMXC__City__c='Austin';
        wo.SVMXC__State__c='CA';
        workorders.add(wo);
        insert workorders;

		List<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstConfigData.add(cfgObj1a);
		WSCH_FieldMatchRuleEngine rule = new WSCH_FieldMatchRuleEngine();
		rule.initialiseFieldMatchingRules();
		rule.processFieldMatchingRules(workorders);
        rule.processFieldMatchingRules(null);
        rule.processMatchingExpressions(lstConfigData, wo,wo, '1 OR 2');
        rule.processMatchingExpressions(null, wo,wo, '1 OR 2');
		test.stopTest();
	}
    static testMethod void WSCH_FieldMatchRuleEngine_Test_MapLiteral(){
       
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Field Mapping' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               ExpressionRTypeId = rt.ID;
            else if(rt.Name == 'Object Mapping' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                RuleRecordTypeId = rt.id;
        }
		SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
		wo.SVMXC__Order_Status__c='Open';
		wo.SVMXC__City__c='Austin';
		wo.SVMXC__State__c='CA';
		Database.insert(wo);

		SVMXC__ServiceMax_Processes__c processObj = new SVMXC__ServiceMax_Processes__c();
		processObj.SVMXC__Name__c = 'Score Rule';
		processObj.SVMXC__Description__c='Score Rule';
		processObj.RecordTypeId = RuleRecordTypeId;
		processObj.SVMXC__MapID__c='ScoreMap2';
		processObj.SVMXC__Source_Object_Name__c = 'SVMXC__Catogory_Score__c';
		processObj.SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order__c';
		processObj.SVMXC__Mode_Of_Execution__c = 'Interactive';
		
		Database.insert(processObj);

		Map<String, List<String>> configVals = new Map<String, List<String>>();
		configVals.put('SVMXC__Actual_Initial_Response__c',new List<String>{'TODAY', 'NOW', 'YESTERDAY', 'TOMORROW','NEXT_MONTH'});
        configVals.put('SVMXC__Scheduled_Date__c',new List<String>{'TODAY', 'YESTERDAY', 'TOMORROW','NEXT_MONTH'});
		configVals.put('SVMXC__Closed_By__c',new List<String>{'SVMX.CURRENTRECORDHEADER.userinfo.getUserId()', 'SVMX.CURRENTUSERID', 'SVMX.USERTRUNK'} );
		configVals.put('SVMXC__Dispatch_Priority__c',new List<String>{'12.01'});
		configVals.put('SVMXC__Driving_Time__c',new List<String>{'100'});
		configVals.put('SVMXC__Drip__c',new List<String>{'true','NOT BOOLEAN'});
		configVals.put('SVMXC__Country__c',new List<String>{'India'});
		SVMXC__ServiceMax_Config_Data__c cfgObj1 = new SVMXC__ServiceMax_Config_Data__c();
		WSCH_FieldMatchRuleEngine mRule = new WSCH_FieldMatchRuleEngine();
		test.startTest();
		/*Test mapLiteral Method*/
		 for(String fldName: configVals.keyset()){
			List<String> strFldVal= configVals.get(fldName);
			for(String fldval: strFldVal){
				cfgObj1 = createConfigData(ExpressionRTypeId, processObj.id, 'Constant', fldval, fldName);
				Database.upsert(cfgObj1);
				mRule.mapLiteral(wo, cfgObj1);
			}
		}
        mRule.mapLiteral(null,null);
        mRule.getQueryFields(null);
		/*Test getAdditionalMap method*/
		SVMXC__ServiceMax_Config_Data__c cfgObj2 = createConfigDataAdnlMap(ExpressionRTypeId, processObj.id,'SVMXC__State__c','SVMXC__City__c','SVMXC__Order_Status__c');
		mRule.getAdditionalMap(wo,cfgObj2);
		wo.SVMXC__State__c = null;
		Database.update(wo);
		mRule.getAdditionalMap(wo,cfgObj2);
		wo.SVMXC__City__c = null;
		Database.update(wo);
		mRule.getAdditionalMap(wo,cfgObj2);
        mRule.getAdditionalMap(null,null);
        test.stopTest();
    }
	private static SVMXC__ServiceMax_Config_Data__c createConfigData(String expressId, ID procID, String paraType, String dispType, String tgtFldName){
		SVMXC__ServiceMax_Config_Data__c cfgObj = new SVMXC__ServiceMax_Config_Data__c();
		cfgObj.RecordTypeId = expressId;
		cfgObj.SVMXC__Expression_Rule__c = procID;
		cfgObj.SVMXC__MapID__c = procID;
		cfgObj.SVMXC__Parameter_Type__c = paraType;//constant, value,field value, servicemax setting
		cfgObj.SVMXC__Display_Value__c = dispType;//TODAY, NOW, YESTERDAY, TOMORROW
		cfgObj.SVMXC__Target_Field_Name__c = tgtFldName;
		Database.insert(cfgObj);
		return cfgObj;
	}
	private static SVMXC__ServiceMax_Config_Data__c createConfigDataAdnlMap(String expressId, ID procID, String srcFld, String prefTwo, String prefThree){
		SVMXC__ServiceMax_Config_Data__c cfgObj = new SVMXC__ServiceMax_Config_Data__c();
		cfgObj.RecordTypeId = expressId;
		cfgObj.SVMXC__Expression_Rule__c = procID;
		cfgObj.SVMXC__MapID__c = procID;
		cfgObj.SVMXC__Source_Field_Name__c = srcFld;
		cfgObj.SVMXC__Preference_2__c = prefTwo;
		cfgObj.SVMXC__Preference_3__c = prefThree;
		Database.insert(cfgObj);
		return cfgObj;
	}
}