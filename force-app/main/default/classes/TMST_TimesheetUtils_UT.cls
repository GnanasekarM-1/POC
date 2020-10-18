@isTest
private class TMST_TimesheetUtils_UT {

    static testMethod void testgetTagValue_Null_TagName() {

        Test.startTest();
        
        String result = TMST_TimesheetUtils.getInstance().getTagValue( null );
        
        System.Assert( result != null );
        System.Assert( result == '' );
        
        Test.stopTest();
    }
    
    static testMethod void testgetTagValue() {

        Test.startTest();
        
        String result = TMST_TimesheetUtils.getInstance().getTagValue( TMST_Consts.TMST001_TAG001 );
        
        System.Assert( result != null );
        
        Test.stopTest();
    } 
    
    static testMethod void testCacheTag_Null_TagName() {

        Test.startTest();
        
        Id sampleId = '01pF0000003we8q';
        
        TMST_TimesheetUtils.getInstance().cacheTag( sampleId, null );        
        String result = TMST_TimesheetUtils.getInstance().buildStringFromCache( sampleId, null, TMST_Consts.NEWLINE );
        
        System.Assert( result != null );
        
        Test.stopTest();
    }
    
    static testMethod void testCacheTag_With_AdditionalInfoMap() {

        Test.startTest();
        
        Id sampleId = '01pF0000003we8q';
        
        TMST_TimesheetUtils.getInstance().cacheTag( sampleId, TMST_Consts.TMST001_TAG001 );
        TMST_TimesheetUtils.getInstance().cacheTag( sampleId, TMST_Consts.TMST001_TAG002 );
        
        Map<String,String> additionalInfoMap = new Map<String,String>();
        additionalInfoMap.put( TMST_Consts.TMST001_TAG001, 'TMST_Consts.TAG001' );
        additionalInfoMap.put( TMST_Consts.TMST001_TAG002, 'TMST_Consts.TAG002' );
        
        String result = TMST_TimesheetUtils.getInstance().buildStringFromCache( sampleId, additionalInfoMap, TMST_Consts.NEWLINE );
        
        System.Assert( result != null );
        
        Test.stopTest();
    }
    
    static testMethod void testCacheTag() {

        Test.startTest();
        
        Id sampleId = '01pF0000003we8q';
        
        TMST_TimesheetUtils.getInstance().cacheTag( sampleId, TMST_Consts.TMST001_TAG001 );        
        String result = TMST_TimesheetUtils.getInstance().buildStringFromCache( sampleId, null, TMST_Consts.NEWLINE );
        
        System.Assert( result != null );
        
        Test.stopTest();
    }

    static testMethod void testBuildString_Null_List() {

        Test.startTest();
        
        String result = TMST_TimesheetUtils.getInstance().buildString( null, TMST_Consts.NEWLINE );        
        
        System.Assert( result != null );
        System.Assert( result == '' );
        
        Test.stopTest();
    }
    
    static testMethod void testBuildString_Null_Seperator() {

        Test.startTest();
        
        List<String> stringList = new List<String>();
        stringList.add(TMST_Consts.TMST001_TAG001);
        stringList.add(TMST_Consts.TMST001_TAG002);
        
        String result = TMST_TimesheetUtils.getInstance().buildString( stringList , null );        
        
        System.Assert( result != null );
        System.Assert( result == '' );
        
        Test.stopTest();
    }
    
    static testMethod void testBuildString() {

        Test.startTest();
        
        List<String> stringList = new List<String>();
        stringList.add(TMST_Consts.TMST001_TAG001);
        stringList.add(TMST_Consts.TMST001_TAG002);
        
        String result = TMST_TimesheetUtils.getInstance().buildString( stringList, TMST_Consts.NEWLINE );        
        
        System.Assert( result != null );
        System.Assert( result != '' );
        
        Test.stopTest();
    }
    
    static testMethod void testGetBusinessHours() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_Response response = TMST_TimesheetUtils.getInstance().getBusinessHours();        
        
        System.Assert( response != null );
        System.Assert( response.businessHoursList != null );
        System.Assert( !response.businessHoursList.isEmpty() );
        
        Test.stopTest();
    } 
    
    static testMethod void testGetAllTimezones() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_Response response = TMST_TimesheetUtils.getInstance().getAllTimezones();        
        
        System.Assert( response != null );
        System.Assert( response.timezoneList != null );
        System.Assert( !response.timezoneList.isEmpty() );
        
        Test.stopTest();
    } 
    
    static testMethod void testGetWorkDetailOwnership() {

        Test.startTest();
        
        TMST_WrapperDef.TMST_Response response = TMST_TimesheetUtils.getInstance().getWorkDetailOwnership();        
        
        System.Assert( response != null );
        System.Assert( response.workDetailOwnershipList != null );
        System.Assert( !response.workDetailOwnershipList.isEmpty() );
        
        Test.stopTest();
    } 
    
    static testMethod void testGetObjectMappingAndSVMXRules() {

        Test.startTest();
        
        RecordType objectMappingType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'Object Mapping' LIMIT 1];
        RecordType svmxRuleType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'SVMX Rule' LIMIT 1];
        
        List<SVMXC__ServiceMax_Processes__c> processList = new List<SVMXC__ServiceMax_Processes__c>();
        processList.add( new  SVMXC__ServiceMax_Processes__c( RecordTypeId = objectMappingType.Id, SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order_Line__c', SVMXC__Target_Object_Name__c = 'SVMXC__Timesheet_Entry__c', SVMXC__Name__c = 'WOD-TSMapping', SVMXC__MapID__c = 'WOD-TSMapping' ) );
        processList.add( new  SVMXC__ServiceMax_Processes__c( RecordTypeId = objectMappingType.Id, SVMXC__Source_Object_Name__c = 'Event', SVMXC__Target_Object_Name__c = 'SVMXC__Timesheet_Entry__c', SVMXC__Name__c = 'Event-TSMapping', SVMXC__MapID__c = 'Event-TSMapping' ) );
        processList.add( new  SVMXC__ServiceMax_Processes__c( RecordTypeId = objectMappingType.Id, SVMXC__Source_Object_Name__c = 'Task', SVMXC__Target_Object_Name__c = 'SVMXC__Timesheet_Entry__c', SVMXC__Name__c = 'Task-TSMapping', SVMXC__MapID__c = 'Task-TSMapping' ) );
        processList.add( new  SVMXC__ServiceMax_Processes__c( RecordTypeId = objectMappingType.Id, SVMXC__Source_Object_Name__c = 'SVMXC__SVMX_Event__c', SVMXC__Target_Object_Name__c = 'SVMXC__Timesheet_Entry__c', SVMXC__Name__c = 'SVMXEvent-TSMapping', SVMXC__MapID__c  = 'SVMXEvent-TSMapping' ) );
        
        processList.add( new  SVMXC__ServiceMax_Processes__c( RecordTypeId = svmxRuleType.Id, SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order_Line__c', SVMXC__Name__c = 'WOD-Rule' ) );
        processList.add( new  SVMXC__ServiceMax_Processes__c( RecordTypeId = svmxRuleType.Id, SVMXC__Source_Object_Name__c = 'Event', SVMXC__Name__c = 'Event-Rule' ) );
        processList.add( new  SVMXC__ServiceMax_Processes__c( RecordTypeId = svmxRuleType.Id, SVMXC__Source_Object_Name__c = 'Task', SVMXC__Name__c = 'Task-Rule' ) );
        processList.add( new  SVMXC__ServiceMax_Processes__c( RecordTypeId = svmxRuleType.Id, SVMXC__Source_Object_Name__c = 'SVMXC__SVMX_Event__c', SVMXC__Name__c = 'SVMXEvent-Rule' ) );
        
        insert processList;
        
        TMST_WrapperDef.TMST_Response response = TMST_TimesheetUtils.getInstance().getObjectMappingAndSVMXRules();        
        
        System.Assert( response != null );
        System.Assert( response.workDetailsMappingList != null );
        System.Assert( response.workDetailsRuleList != null );
        System.Assert( response.taskMappingList != null );
        System.Assert( response.taskRuleList != null );
        System.Assert( response.eventMappingList != null );
        System.Assert( response.eventRuleList != null );
        System.Assert( response.servicemaxEventMappingList != null );
        System.Assert( response.servicemaxEventRuleList != null );
        
        System.Assert( !response.workDetailsMappingList.isEmpty() );
        System.Assert( !response.workDetailsRuleList.isEmpty() );
        System.Assert( !response.taskMappingList.isEmpty() );
        System.Assert( !response.taskRuleList.isEmpty() );
        System.Assert( !response.eventMappingList.isEmpty() );
        System.Assert( !response.eventRuleList.isEmpty() );
        System.Assert( !response.servicemaxEventMappingList.isEmpty() );
        System.Assert( !response.servicemaxEventRuleList.isEmpty() );
        
        Test.stopTest();
    }
}