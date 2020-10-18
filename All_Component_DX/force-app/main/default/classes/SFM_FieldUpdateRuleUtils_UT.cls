@isTest
private class SFM_FieldUpdateRuleUtils_UT {

    static testMethod void testSFM_GetFieldUpdateRuleIds() {

        Test.startTest();
        
        insertFieldUpdateRule();
        
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        
        SFM_WrapperDef.SFM_StringListMap sfmStringListMap = new SFM_WrapperDef.SFM_StringListMap();
        sfmStringListMap.key = 'OBJECTAPINAME';
        sfmStringListMap.valueList.add('SVMXC__Service_Order__c');
        
        request.stringListMap.add(sfmStringListMap);
        
        sfmStringListMap = new SFM_WrapperDef.SFM_StringListMap();
        sfmStringListMap.key = 'ALIASNAME';
        sfmStringListMap.valueList.add('SVMXC__Service_Order__c');
        
        request.stringListMap.add(sfmStringListMap);
        
        SFM_FieldUpdateRuleUtils fieldUpdateRuleUtils = new SFM_FieldUpdateRuleUtils();
        SFM_WrapperDef.SFM_Response response = fieldUpdateRuleUtils.SFM_GetFieldUpdateRuleIds(request);
        
        System.assert( response != null );
        System.assert( response.success );
        System.assert( response.resultIds != null );
        System.assert( !response.resultIds.isEmpty() );
        System.assert( response.resultIds.size() == 1, 'Actual: ' + response.resultIds.size() );
        
        Test.stopTest();
    }
    
    static testMethod void testSFM_GetFieldUpdateRuleIds_Empty_StringListMap() {

        Test.startTest();
        
        insertFieldUpdateRule();
        
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        
        SFM_FieldUpdateRuleUtils fieldUpdateRuleUtils = new SFM_FieldUpdateRuleUtils();
        SFM_WrapperDef.SFM_Response response = fieldUpdateRuleUtils.SFM_GetFieldUpdateRuleIds(request);
        
        System.assert( response != null );
        System.assert( response.success );
        System.assert( response.resultIds != null );
        System.assert( !response.resultIds.isEmpty() );
        System.assert( response.resultIds.size() == 1, 'Actual: ' + response.resultIds.size() );
        
        Test.stopTest();
    }
    
    static testMethod void testSFM_GetFieldUpdateRuleIds_Null_Key() {

        Test.startTest();
        
        insertFieldUpdateRule();
        
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        
        SFM_WrapperDef.SFM_StringListMap sfmStringListMap = new SFM_WrapperDef.SFM_StringListMap();
        sfmStringListMap.key = null;
        sfmStringListMap.valueList.add('SVMXC__Service_Order__c');
        
        request.stringListMap.add(sfmStringListMap);
        
        SFM_FieldUpdateRuleUtils fieldUpdateRuleUtils = new SFM_FieldUpdateRuleUtils();
        SFM_WrapperDef.SFM_Response response = fieldUpdateRuleUtils.SFM_GetFieldUpdateRuleIds(request);
        
        System.assert( response != null );
        System.assert( response.success );
        System.assert( response.resultIds != null );
        System.assert( !response.resultIds.isEmpty() );
        System.assert( response.resultIds.size() == 1, 'Actual: ' + response.resultIds.size() );
        
        Test.stopTest();
    }
    
    static testMethod void testSFM_GetFieldUpdateRuleIds_Null_Object_Name() {

        Test.startTest();
        
        insertFieldUpdateRule();
        
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        
        SFM_WrapperDef.SFM_StringListMap sfmStringListMap = new SFM_WrapperDef.SFM_StringListMap();
        sfmStringListMap.key = 'OBJECTAPINAME';
        sfmStringListMap.valueList.add(null);
        
        request.stringListMap.add(sfmStringListMap);
        
        SFM_FieldUpdateRuleUtils fieldUpdateRuleUtils = new SFM_FieldUpdateRuleUtils();
        SFM_WrapperDef.SFM_Response response = fieldUpdateRuleUtils.SFM_GetFieldUpdateRuleIds(request);
        
        System.assert( response != null );
        System.assert( response.success );
        System.assert( response.resultIds != null );
        System.assert( !response.resultIds.isEmpty() );
        System.assert( response.resultIds.size() == 1, 'Actual: ' + response.resultIds.size() );
        
        Test.stopTest();
    }
    
    static testMethod void testSFM_GetFieldUpdateRuleIds_Unknown_Object_Name() {

        Test.startTest();
        
        insertFieldUpdateRule();
        
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        
        SFM_WrapperDef.SFM_StringListMap sfmStringListMap = new SFM_WrapperDef.SFM_StringListMap();
        sfmStringListMap.key = 'OBJECTAPINAME';
        sfmStringListMap.valueList.add('Unknown');
        
        request.stringListMap.add(sfmStringListMap);
        
        SFM_FieldUpdateRuleUtils fieldUpdateRuleUtils = new SFM_FieldUpdateRuleUtils();
        SFM_WrapperDef.SFM_Response response = fieldUpdateRuleUtils.SFM_GetFieldUpdateRuleIds(request);
        
        System.assert( response != null );
        System.assert( response.success );
        System.assert( response.resultIds != null );
        System.assert( response.resultIds.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testSFM_GetFieldUpdateRuleIds_Null_Request() {

        Test.startTest();
        
        SFM_FieldUpdateRuleUtils fieldUpdateRuleUtils = new SFM_FieldUpdateRuleUtils();
        SFM_WrapperDef.SFM_Response response = fieldUpdateRuleUtils.SFM_GetFieldUpdateRuleIds(null);
        
        System.assert( response != null );
        System.assert( response.success );
        System.assert( response.resultIds.isEmpty() );
        
        insertFieldUpdateRule();
        
        response = fieldUpdateRuleUtils.SFM_GetFieldUpdateRuleIds(null);
        
        System.assert( response != null );
        System.assert( response.success );
        System.assert( response.resultIds != null );
        System.assert( !response.resultIds.isEmpty() );
        System.assert( response.resultIds.size() == 1, 'Actual: ' + response.resultIds.size() );
        
        Test.stopTest();
    }
    
    static testMethod void testSFM_GetFieldUpdateRuleInfo() {

        Test.startTest();
        
        Id processId = insertFieldUpdateRule();
        insertFieldUpdateRuleDetails( processId );
        
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        
        SFM_WrapperDef.SFM_StringListMap sfmStringListMap = new SFM_WrapperDef.SFM_StringListMap();
        sfmStringListMap.key = 'FIELDUPDATERULEIDS';
        sfmStringListMap.valueList.add(processId);
        
        request.stringListMap.add(sfmStringListMap);
        
        SFM_FieldUpdateRuleUtils fieldUpdateRuleUtils = new SFM_FieldUpdateRuleUtils();
        SFM_WrapperDef.SFM_Response response = fieldUpdateRuleUtils.SFM_GetFieldUpdateRuleInfo(request);
        
        System.assert( response != null );
        System.assert( response.success );
        System.assert( response.fieldUpdateRuleInfoList != null );
        System.assert( !response.fieldUpdateRuleInfoList.isEmpty() );
        System.assert( response.fieldUpdateRuleInfoList.size() == 1, 'Actual: ' + response.resultIds.size() );
        
        Test.stopTest();
    }
    
    static testMethod void testSFM_GetFieldUpdateRuleInfo_Null_Key() {

        Test.startTest();
        
        Id processId = insertFieldUpdateRule();
        insertFieldUpdateRuleDetails( processId );
        
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        
        SFM_WrapperDef.SFM_StringListMap sfmStringListMap = new SFM_WrapperDef.SFM_StringListMap();
        sfmStringListMap.key = null;
        sfmStringListMap.valueList.add(processId);
        
        request.stringListMap.add(sfmStringListMap);
        
        SFM_FieldUpdateRuleUtils fieldUpdateRuleUtils = new SFM_FieldUpdateRuleUtils();
        SFM_WrapperDef.SFM_Response response = fieldUpdateRuleUtils.SFM_GetFieldUpdateRuleInfo(request);
        
        System.assert( response != null );
        System.assert( response.success );
        System.assert( response.fieldUpdateRuleInfoList != null );
        System.assert( !response.fieldUpdateRuleInfoList.isEmpty() );
        System.assert( response.fieldUpdateRuleInfoList.size() == 1, 'Actual: ' + response.resultIds.size() );
        
        Test.stopTest();
    }
    
    static testMethod void testSFM_GetFieldUpdateRuleInfo_Null_ProcessId() {

        Test.startTest();
        
        Id processId = insertFieldUpdateRule();
        insertFieldUpdateRuleDetails( processId );
        
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        
        SFM_WrapperDef.SFM_StringListMap sfmStringListMap = new SFM_WrapperDef.SFM_StringListMap();
        sfmStringListMap.key = 'FIELDUPDATERULEIDS';
        sfmStringListMap.valueList.add(null);
        
        request.stringListMap.add(sfmStringListMap);
        
        SFM_FieldUpdateRuleUtils fieldUpdateRuleUtils = new SFM_FieldUpdateRuleUtils();
        SFM_WrapperDef.SFM_Response response = fieldUpdateRuleUtils.SFM_GetFieldUpdateRuleInfo(request);
        
        System.assert( response != null );
        System.assert( response.success );
        System.assert( response.fieldUpdateRuleInfoList != null );
        System.assert( !response.fieldUpdateRuleInfoList.isEmpty() );
        System.assert( response.fieldUpdateRuleInfoList.size() == 1, 'Actual: ' + response.resultIds.size() );
        
        Test.stopTest();
    }
    
    static testMethod void testSFM_GetFieldUpdateRuleInfo_Empty_StringListMap() {

        Test.startTest();
        
        Id processId = insertFieldUpdateRule();
        insertFieldUpdateRuleDetails( processId );
        
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        
        SFM_FieldUpdateRuleUtils fieldUpdateRuleUtils = new SFM_FieldUpdateRuleUtils();
        SFM_WrapperDef.SFM_Response response = fieldUpdateRuleUtils.SFM_GetFieldUpdateRuleInfo(request);
        
        System.assert( response != null );
        System.assert( response.success );
        System.assert( response.fieldUpdateRuleInfoList != null );
        System.assert( !response.fieldUpdateRuleInfoList.isEmpty() );
        System.assert( response.fieldUpdateRuleInfoList.size() == 1, 'Actual: ' + response.resultIds.size() );
        
        Test.stopTest();
    }
    
    static testMethod void testSFM_SFM_SaveFieldUpdateRules() {

        Test.startTest();
                
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        
        SFM_WrapperDef.SFM_FieldUpdateRuleInfo info = new SFM_WrapperDef.SFM_FieldUpdateRuleInfo();
        info.fieldUpdateRule = buildFieldUpdateRule();
        info.fieldUpdateRuleDetails.add( buildFieldUpdateRuleDetail() );
        
        request.fieldUpdateRuleInfoList.add(info);
        
        SFM_FieldUpdateRuleUtils fieldUpdateRuleUtils = new SFM_FieldUpdateRuleUtils();
        SFM_WrapperDef.SFM_Response response = fieldUpdateRuleUtils.SFM_SaveFieldUpdateRules(request);
        
        System.assert( response != null );
        System.assert( response.success );
        System.assert( response.fieldUpdateRuleInfoList != null );
		System.assert( !response.fieldUpdateRuleInfoList.isEmpty() );        

        response = fieldUpdateRuleUtils.SFM_GetFieldUpdateRuleIds( new SFM_WrapperDef.SFM_Request() );
        
        System.assert( response != null );
        System.assert( response.success );
        System.assert( response.resultIds != null );
        System.assert( !response.resultIds.isEmpty() );
        System.assert( response.resultIds.size() == 1, 'Actual: ' + response.resultIds.size() );
        
        Test.stopTest();
    }
    
    static testMethod void testSFM_SFM_SaveFieldUpdateRules_ReadOnlyMode() {

        Test.startTest();
                
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        
        SFM_WrapperDef.SFM_FieldUpdateRuleInfo info = new SFM_WrapperDef.SFM_FieldUpdateRuleInfo();
        info.fieldUpdateRule = buildFieldUpdateRule();
        info.fieldUpdateRuleDetails.add( buildFieldUpdateRuleDetail() );
        
        request.fieldUpdateRuleInfoList.add(info);
        
        Test.setReadOnlyApplicationMode(true);
        
        SFM_FieldUpdateRuleUtils fieldUpdateRuleUtils = new SFM_FieldUpdateRuleUtils();
        SFM_WrapperDef.SFM_Response response = fieldUpdateRuleUtils.SFM_SaveFieldUpdateRules(request);
        
        System.assert( response != null );
        System.assert( !response.success );

        response = fieldUpdateRuleUtils.SFM_GetFieldUpdateRuleIds( new SFM_WrapperDef.SFM_Request() );
        
        System.assert( response != null );
        System.assert( response.success );
        System.assert( response.resultIds != null );
        System.assert( response.resultIds.isEmpty() );
                
        Test.stopTest();
    }
    
    static testMethod void testSFM_SFM_SaveFieldUpdateRules_Null_Request() {

        Test.startTest();
        
        SFM_FieldUpdateRuleUtils fieldUpdateRuleUtils = new SFM_FieldUpdateRuleUtils();
        SFM_WrapperDef.SFM_Response response = fieldUpdateRuleUtils.SFM_SaveFieldUpdateRules(null);
        
        System.assert( response != null );
        System.assert( !response.success );
        System.assert( response.message != null );
        System.assert( response.message.equalsIgnoreCase( System.Label.SFM001_TAG350 ) );
 
        Test.stopTest();
    } 
    
    static testMethod void testSFM_SFM_SaveFieldUpdateRules_Null_FieldUpdateInfoList() {

        Test.startTest();
                
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();        
        request.fieldUpdateRuleInfoList = null;
        
        SFM_FieldUpdateRuleUtils fieldUpdateRuleUtils = new SFM_FieldUpdateRuleUtils();
        SFM_WrapperDef.SFM_Response response = fieldUpdateRuleUtils.SFM_SaveFieldUpdateRules(request);
        
        System.assert( response != null );
        System.assert( !response.success );
        System.assert( response.message != null );
        System.assert( response.message.equalsIgnoreCase( System.Label.SFM001_TAG350 ) );
        
        Test.stopTest();
    }
    
    static testMethod void testSFM_SFM_SaveFieldUpdateRules_Empty_FieldUpdateRule() {

        Test.startTest();
                
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();        

		SFM_WrapperDef.SFM_FieldUpdateRuleInfo info = new SFM_WrapperDef.SFM_FieldUpdateRuleInfo();
        info.fieldUpdateRule = null;
        
        request.fieldUpdateRuleInfoList.add(info);        
        
        SFM_FieldUpdateRuleUtils fieldUpdateRuleUtils = new SFM_FieldUpdateRuleUtils();
        SFM_WrapperDef.SFM_Response response = fieldUpdateRuleUtils.SFM_SaveFieldUpdateRules(request);
        
        System.assert( response != null );
        System.assert( !response.success );
        System.assert( response.message != null );
        System.assert( response.message.equalsIgnoreCase( System.Label.SFM001_TAG350 ) );
        
        Test.stopTest();
    }
    
    static testMethod void testSFM_SFM_SaveFieldUpdateRules_Duplicate_ProcessID() {

        Test.startTest();
                
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        
        SFM_WrapperDef.SFM_FieldUpdateRuleInfo info = new SFM_WrapperDef.SFM_FieldUpdateRuleInfo();
        info.fieldUpdateRule = buildFieldUpdateRule();
        info.fieldUpdateRuleDetails.add( buildFieldUpdateRuleDetail() );
        
        request.fieldUpdateRuleInfoList.add(info);
                
        SFM_FieldUpdateRuleUtils fieldUpdateRuleUtils = new SFM_FieldUpdateRuleUtils();
        SFM_WrapperDef.SFM_Response response = fieldUpdateRuleUtils.SFM_SaveFieldUpdateRules(request);
        
        System.assert( response != null );
        System.assert( response.success, response.message );
        
        request.fieldUpdateRuleInfoList.clear();
        info = new SFM_WrapperDef.SFM_FieldUpdateRuleInfo();
        info.fieldUpdateRule = buildFieldUpdateRule();
        info.fieldUpdateRuleDetails.add( buildFieldUpdateRuleDetail() );
        
        request.fieldUpdateRuleInfoList.add(info);
        
        response = fieldUpdateRuleUtils.SFM_SaveFieldUpdateRules(request);
        
        System.assert( response != null );
        System.assert( !response.success );
        System.assert( response.message != null );
        System.assert( response.message.equalsIgnoreCase( System.Label.SFM001_TAG347 ) );

        response = fieldUpdateRuleUtils.SFM_GetFieldUpdateRuleIds( new SFM_WrapperDef.SFM_Request() );
        
        System.assert( response != null );
        System.assert( response.success );
        System.assert( response.resultIds != null );
        System.assert( !response.resultIds.isEmpty() );
        System.assert( response.resultIds.size() == 1, 'Actual: ' + response.resultIds.size() );
        
        Test.stopTest();
    }
    
    static testMethod void testSFM_SFM_SaveFieldUpdateRules_Deleted_Record() {

        Test.startTest();
                
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        
        SFM_WrapperDef.SFM_FieldUpdateRuleInfo info = new SFM_WrapperDef.SFM_FieldUpdateRuleInfo();
        info.fieldUpdateRule = buildFieldUpdateRule();
        info.fieldUpdateRuleDetails.add( buildFieldUpdateRuleDetail() );
        
        request.fieldUpdateRuleInfoList.add(info);
                
        SFM_FieldUpdateRuleUtils fieldUpdateRuleUtils = new SFM_FieldUpdateRuleUtils();
        SFM_WrapperDef.SFM_Response response = fieldUpdateRuleUtils.SFM_SaveFieldUpdateRules(request);
        
        System.assert( response != null );
        System.assert( response.success, response.message );
                        
        response = fieldUpdateRuleUtils.SFM_SaveFieldUpdateRules(request);
        
        System.assert( response != null );
        System.assert( response.success );
        System.assert( response.message != null );
        
        response = fieldUpdateRuleUtils.SFM_GetFieldUpdateRuleIds( new SFM_WrapperDef.SFM_Request() );
        
        System.assert( response != null );
        System.assert( response.success );
        System.assert( response.resultIds != null );
        System.assert( !response.resultIds.isEmpty() );
        System.assert( response.resultIds.size() == 1, 'Actual: ' + response.resultIds.size() );
        
        Test.stopTest();
    }
    
    static testMethod void testSFM_SFM_SaveFieldUpdateRules_Empty_FieldUpdateRuleList() {

        Test.startTest();
                
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        
        SFM_FieldUpdateRuleUtils fieldUpdateRuleUtils = new SFM_FieldUpdateRuleUtils();
        SFM_WrapperDef.SFM_Response response = fieldUpdateRuleUtils.SFM_SaveFieldUpdateRules(request);
        
        System.assert( response != null );
        System.assert( !response.success );
                
        Test.stopTest();
    }
    
    static testMethod void testSFM_SFM_SaveFieldUpdateRules_Process_Name_Validation() {

        Test.startTest();
                
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        
        SFM_WrapperDef.SFM_FieldUpdateRuleInfo info = new SFM_WrapperDef.SFM_FieldUpdateRuleInfo();
        info.fieldUpdateRule = buildFieldUpdateRule();
        info.fieldUpdateRuleDetails.add( buildFieldUpdateRuleDetail() );
        
        info.fieldUpdateRule.SVMXC__Name__c = null;
        request.fieldUpdateRuleInfoList.add(info);
        
        SFM_FieldUpdateRuleUtils fieldUpdateRuleUtils = new SFM_FieldUpdateRuleUtils();
        SFM_WrapperDef.SFM_Response response = fieldUpdateRuleUtils.SFM_SaveFieldUpdateRules(request);
        
        System.assert( response != null );
        System.assert( !response.success );
        
        String longName = '';
        for( Integer i = 0; i < 26; i++ ) { longName += 'Abcdefghij';}
        info.fieldUpdateRule.SVMXC__Name__c = longName;
        response = fieldUpdateRuleUtils.SFM_SaveFieldUpdateRules(request);
        
        System.assert( response != null );
        System.assert( !response.success );
                
        Test.stopTest();
    }
    
    static testMethod void testSFM_SFM_SaveFieldUpdateRules_ProcessId_Validation() {

        Test.startTest();
                
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        
        SFM_WrapperDef.SFM_FieldUpdateRuleInfo info = new SFM_WrapperDef.SFM_FieldUpdateRuleInfo();
        info.fieldUpdateRule = buildFieldUpdateRule();
        info.fieldUpdateRuleDetails.add( buildFieldUpdateRuleDetail() );
        
        info.fieldUpdateRule.SVMXC__ProcessID__c = null;
        request.fieldUpdateRuleInfoList.add(info);
        
        SFM_FieldUpdateRuleUtils fieldUpdateRuleUtils = new SFM_FieldUpdateRuleUtils();
        SFM_WrapperDef.SFM_Response response = fieldUpdateRuleUtils.SFM_SaveFieldUpdateRules(request);
        
        System.assert( response != null );
        System.assert( !response.success );
        
        String longText = '';
        for( Integer i = 0; i < 51; i++ ) {
            longText += 'A';
        }
        
        info.fieldUpdateRule.SVMXC__ProcessID__c = longText;
        response = fieldUpdateRuleUtils.SFM_SaveFieldUpdateRules(request);
        
        System.assert( response != null );
        System.assert( !response.success );
                
        Test.stopTest();
    }
    
    static testMethod void testSFM_SFM_SaveFieldUpdateRules_Null_Source_Object_Name() {

        Test.startTest();
                
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        
        SFM_WrapperDef.SFM_FieldUpdateRuleInfo info = new SFM_WrapperDef.SFM_FieldUpdateRuleInfo();
        info.fieldUpdateRule = buildFieldUpdateRule();
        info.fieldUpdateRuleDetails.add( buildFieldUpdateRuleDetail() );
        
        info.fieldUpdateRule.SVMXC__Source_Object_Name__c = null;
        request.fieldUpdateRuleInfoList.add(info);
        
        SFM_FieldUpdateRuleUtils fieldUpdateRuleUtils = new SFM_FieldUpdateRuleUtils();
        SFM_WrapperDef.SFM_Response response = fieldUpdateRuleUtils.SFM_SaveFieldUpdateRules(request);
        
        System.assert( response != null );
        System.assert( !response.success );
                
        Test.stopTest();
    }
    
    static testMethod void testSFM_SFM_SaveFieldUpdateRules_Null_Rule_Type() {

        Test.startTest();
                
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        
        SFM_WrapperDef.SFM_FieldUpdateRuleInfo info = new SFM_WrapperDef.SFM_FieldUpdateRuleInfo();
        info.fieldUpdateRule = buildFieldUpdateRule();
        info.fieldUpdateRuleDetails.add( buildFieldUpdateRuleDetail() );
        
        info.fieldUpdateRule.SVMXC__Rule_Type__c = null;
        request.fieldUpdateRuleInfoList.add(info);
        
        SFM_FieldUpdateRuleUtils fieldUpdateRuleUtils = new SFM_FieldUpdateRuleUtils();
        SFM_WrapperDef.SFM_Response response = fieldUpdateRuleUtils.SFM_SaveFieldUpdateRules(request);
        
        System.assert( response != null );
        System.assert( response.success );
                
        Test.stopTest();
    }
    
    static testMethod void testSFM_SFM_SaveFieldUpdateRules_Invalid_Rule_Type() {

        Test.startTest();
                
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        
        SFM_WrapperDef.SFM_FieldUpdateRuleInfo info = new SFM_WrapperDef.SFM_FieldUpdateRuleInfo();
        info.fieldUpdateRule = buildFieldUpdateRule();
        info.fieldUpdateRuleDetails.add( buildFieldUpdateRuleDetail() );
        
        info.fieldUpdateRule.SVMXC__Rule_Type__c = 'Invalid';
        request.fieldUpdateRuleInfoList.add(info);
        
        SFM_FieldUpdateRuleUtils fieldUpdateRuleUtils = new SFM_FieldUpdateRuleUtils();
        SFM_WrapperDef.SFM_Response response = fieldUpdateRuleUtils.SFM_SaveFieldUpdateRules(request);
        
        System.assert( response != null );
        System.assert( !response.success );
                
        Test.stopTest();
    }
    
    static testMethod void testSFM_SFM_SaveFieldUpdateRules_Invalid_Action_Type() {

        Test.startTest();
                
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        
        SFM_WrapperDef.SFM_FieldUpdateRuleInfo info = new SFM_WrapperDef.SFM_FieldUpdateRuleInfo();
        info.fieldUpdateRule = buildFieldUpdateRule();
        info.fieldUpdateRuleDetails.add( buildFieldUpdateRuleDetail() );
        
        info.fieldUpdateRuleDetails.get(0).SVMXC__Action_Type__c = 'Invalid';
        request.fieldUpdateRuleInfoList.add(info);
        
        SFM_FieldUpdateRuleUtils fieldUpdateRuleUtils = new SFM_FieldUpdateRuleUtils();
        SFM_WrapperDef.SFM_Response response = fieldUpdateRuleUtils.SFM_SaveFieldUpdateRules(request);
        
        System.assert( response != null );
        System.assert( !response.success );
                
        Test.stopTest();
    } 
    
    static testMethod void testSFM_SFM_SaveFieldUpdateRules_Invalid_Expression_Rule() {

        Test.startTest();
                
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        
        SFM_WrapperDef.SFM_FieldUpdateRuleInfo info = new SFM_WrapperDef.SFM_FieldUpdateRuleInfo();
        info.fieldUpdateRule = buildFieldUpdateRule();
        info.fieldUpdateRuleDetails.add( buildFieldUpdateRuleDetail() );
        
        info.fieldUpdateRuleDetails.get(0).SVMXC__Expression_Rule__c = insertFieldUpdateRule();
        request.fieldUpdateRuleInfoList.add(info);
        
        SFM_FieldUpdateRuleUtils fieldUpdateRuleUtils = new SFM_FieldUpdateRuleUtils();
        SFM_WrapperDef.SFM_Response response = fieldUpdateRuleUtils.SFM_SaveFieldUpdateRules(request);
        
        System.assert( response != null );
        System.assert( !response.success );
                
        Test.stopTest();
    }
    
    static testMethod void testSFM_SFM_SaveFieldUpdateRules_Null_Formula() {

        Test.startTest();
                
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        
        SFM_WrapperDef.SFM_FieldUpdateRuleInfo info = new SFM_WrapperDef.SFM_FieldUpdateRuleInfo();
        info.fieldUpdateRule = buildFieldUpdateRule();
        info.fieldUpdateRuleDetails.add( buildFieldUpdateRuleDetail() );
        
        info.fieldUpdateRuleDetails.get(0).SVMXC__Formula__c = null;
        request.fieldUpdateRuleInfoList.add(info);
        
        SFM_FieldUpdateRuleUtils fieldUpdateRuleUtils = new SFM_FieldUpdateRuleUtils();
        SFM_WrapperDef.SFM_Response response = fieldUpdateRuleUtils.SFM_SaveFieldUpdateRules(request);
        
        System.assert( response != null );
        System.assert( !response.success );
                
        Test.stopTest();
    }
        
    private static SVMXC__ServiceMax_Processes__c buildFieldUpdateRule() {
        
    	RecordType businessRuleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name =: 'Business Rule' LIMIT 1];
                
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.RecordTypeId = businessRuleRecordType.Id;
        process.SVMXC__Name__c = 'Sample Field Update Rule';
        process.SVMXC__Rule_Type__c = 'Field Update Rule';
        process.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        process.SVMXC__ProcessID__c = 'Sample_Field_Update_Rule';
        
        return process;
    }
    
    private static SVMXC__ServiceMax_Config_Data__c buildFieldUpdateRuleDetail() {
        
        RecordType fieldUpdateEecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name = 'Field Updates' LIMIT 1 ];
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        
        configData.RecordTypeId = fieldUpdateEecordType.Id;        
        configData.SVMXC__Expression_Type__c = 'Field_Update_Rule';
        configData.SVMXC__Formula__c = 'Formula';
        
        return configData;
    }
    
    private static Id insertFieldUpdateRule() {
        
        RecordType businessRuleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name =: 'Business Rule' LIMIT 1];
                
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        
        process.RecordTypeId = businessRuleRecordType.Id;
        process.SVMXC__Name__c = 'Sample Field Update Rule';
        process.SVMXC__Rule_Type__c = 'Field Update Rule';
        process.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        process.SVMXC__ProcessID__c = 'Sample_Field_Update_Rule';
        process.SVMXC__Target_Object_label__c = 'SVMXC__Service_Order__c';
        
        insert process;

		return process.Id;
    }
    
    private static void insertFieldUpdateRuleDetails( Id processId ) {
                
        RecordType fieldUpdateEecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name = 'Field Updates' LIMIT 1 ];
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        
        configData.RecordTypeId = fieldUpdateEecordType.Id;
        configData.SVMXC__Expression_Rule__c = processId;
        configData.SVMXC__Expression_Type__c = 'Field_Update_Rule';
                
        insert configData;
    }
}