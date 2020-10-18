@isTest
public class CONF_ApplicationFiltersImpl_UT {
    
	static testMethod void testConstructor() {
        
        Test.startTest();
        
        Integer count = [SELECT count() FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = :APFT_Constants.RECORD_TYPE_APPLICATION_PROFILE];        
        System.assert( count == 0 );
        
        CONF_ApplicationFiltersImpl applicationFilters = new CONF_ApplicationFiltersImpl();
        
        count = [SELECT count() FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = :APFT_Constants.RECORD_TYPE_APPLICATION_PROFILE];        
        System.assert( count == 6 );
        
        Test.stopTest();
    }
    
    static testMethod void testGetSupportedRecordTypes() {
        
        Test.startTest();
        
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().getSupportedRecordTypes();
        System.assert( response != null );
        System.assert( response.success );
        System.assert( response.objectInfoList != null );
        System.assert( !response.objectInfoList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testGetAllSourceObjects_Null_Request() {
        
        Test.startTest();
        
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().getAllSourceObjects(null);
		System.assert( response != null );
        System.assert( !response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testGetAllSourceObjects_Null_RecordTypeName() {
        
        Test.startTest();
        
        APFT_WrapperDef.APFT_Request request = new APFT_WrapperDef.APFT_Request();
        request.recordTypeName = null;
        
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().getAllSourceObjects(request);
		System.assert( response != null );
        System.assert( !response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testGetAllSourceObjects_Empty_RecordTypeName() {
        
        Test.startTest();
        
        APFT_WrapperDef.APFT_Request request = new APFT_WrapperDef.APFT_Request();
        request.recordTypeName = '';
        
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().getAllSourceObjects(request);
		System.assert( response != null );
        System.assert( !response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testGetAllSourceObjects_Invalid_RecordTypeName() {
        
        Test.startTest();
        
        APFT_WrapperDef.APFT_Request request = new APFT_WrapperDef.APFT_Request();
        request.recordTypeName = 'Invalid';
        
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().getAllSourceObjects(request);
		System.assert( response != null );
        System.assert( response.success );
        System.assert( response.objectInfoList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testGetAllSourceObjects_No_Processes() {
        
        Test.startTest();
        
        APFT_WrapperDef.APFT_Request request = new APFT_WrapperDef.APFT_Request();
        request.recordTypeName = 'SVMXC__Service_Order__c';
        
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().getAllSourceObjects(request);
		System.assert( response != null );
        System.assert( response.success );
        System.assert( response.objectInfoList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testGetAllSourceObjects() {
        
        Test.startTest();
        
        initWizards();
        
        APFT_WrapperDef.APFT_Request request = new APFT_WrapperDef.APFT_Request();
        request.recordTypeName = APFT_Constants.RECORD_TYPE_WIZARD;
        
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().getAllSourceObjects(request);
		System.assert( response != null );
        System.assert( response.success );
        System.assert( !response.objectInfoList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testGetApplicationFilter_Null_Request() {
        
        Test.startTest();
                
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().getApplicationFilter(null);
		System.assert( response != null );
        System.assert( !response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testGetApplicationFilter_Null_RecordTypeName() {
        
        Test.startTest();
        
        APFT_WrapperDef.APFT_Request request = new APFT_WrapperDef.APFT_Request();
        request.sourceObjectName = 'SVMXC__Service_Order__c';
        request.recordTypeName = null;
                
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().getApplicationFilter(request);
		System.assert( response != null );
        System.assert( !response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testGetApplicationFilter_Null_SourceObjectName() {
        
        Test.startTest();
        
        APFT_WrapperDef.APFT_Request request = new APFT_WrapperDef.APFT_Request();
        request.sourceObjectName = null;
        request.recordTypeName = APFT_Constants.RECORD_TYPE_WIZARD;
        
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().getApplicationFilter(request);
		System.assert( response != null );
        System.assert( !response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testGetApplicationFilter_Empty_RecordTypeName() {
        
        Test.startTest();
        
        APFT_WrapperDef.APFT_Request request = new APFT_WrapperDef.APFT_Request();
        request.sourceObjectName = 'SVMXC__Service_Order__c';
        request.recordTypeName = '';
                
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().getApplicationFilter(request);
		System.assert( response != null );
        System.assert( !response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testGetApplicationFilter_Empty_SourceObjectName() {
        
        Test.startTest();
        
        APFT_WrapperDef.APFT_Request request = new APFT_WrapperDef.APFT_Request();
        request.sourceObjectName = '';
        request.recordTypeName = APFT_Constants.RECORD_TYPE_WIZARD;
        
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().getApplicationFilter(request);
		System.assert( response != null );
        System.assert( !response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testGetApplicationFilter_Invalid_RecordTypeName() {
        
        Test.startTest();
        
        APFT_WrapperDef.APFT_Request request = new APFT_WrapperDef.APFT_Request();
        request.sourceObjectName = 'SVMXC__Service_Order__c';
        request.recordTypeName = 'Invalid';
                
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().getApplicationFilter(request);
		System.assert( response != null );
        System.assert( response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testGetApplicationFilter_Invalid_SourceObjectName() {
        
        Test.startTest();
        
        APFT_WrapperDef.APFT_Request request = new APFT_WrapperDef.APFT_Request();
        request.sourceObjectName = 'Invalid';
        request.recordTypeName = APFT_Constants.RECORD_TYPE_WIZARD;
        
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().getApplicationFilter(request);
		System.assert( response != null );
        System.assert( response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testGetApplicationFilter_No_Processes_Records() {
        
        Test.startTest();
        
        APFT_WrapperDef.APFT_Request request = new APFT_WrapperDef.APFT_Request();
        request.sourceObjectName = 'SVMXC__Service_Order__c';
        request.recordTypeName = APFT_Constants.RECORD_TYPE_WIZARD;
        
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().getApplicationFilter(request);
		System.assert( response != null );
        System.assert( response.success );
        System.assert( response.filterInfoList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testGetApplicationFilter_Wizard() {
        
        Test.startTest();
        
        initWizards();
        
        APFT_WrapperDef.APFT_Request request = new APFT_WrapperDef.APFT_Request();
        request.sourceObjectName = 'SVMXC__Service_Order__c';
        request.recordTypeName = APFT_Constants.RECORD_TYPE_WIZARD;
        
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().getApplicationFilter(request);
		System.assert( response != null );
        System.assert( response.success );
        System.assert( !response.filterInfoList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testGetApplicationFilter_Process_Node_Object() {
        
        Test.startTest();
        
        initWizards();
        
        APFT_WrapperDef.APFT_Request request = new APFT_WrapperDef.APFT_Request();
        request.sourceObjectName = 'SVMXC__Service_Order__c';
        request.recordTypeName = APFT_Constants.RECORD_TYPE_SFM_PROCESS_NODE_OBJECT;
        
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().getApplicationFilter(request);
		System.assert( response != null );
        System.assert( response.success );
        System.assert( !response.filterInfoList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testGetApplicationFilter_Custom_Actions() {
        
        Test.startTest();
        
        initWizards();
        
        APFT_WrapperDef.APFT_Request request = new APFT_WrapperDef.APFT_Request();
        request.sourceObjectName = 'SVMXC__Service_Order__c';
        request.recordTypeName = APFT_Constants.RECORD_TYPE_CUSTOM_ACTION;
        
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().getApplicationFilter(request);
		System.assert( response != null );
        System.assert( response.success );
        System.assert( !response.filterInfoList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveApplicationFilter_Null_Request() {
        
        Test.startTest();
                
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().saveApplicationFilter(null);
		System.assert( response != null );
        System.assert( !response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveApplicationFilter_Null_RecordTypeName() {
        
        Test.startTest();
        
        APFT_WrapperDef.APFT_Request request = new APFT_WrapperDef.APFT_Request();        
        request.recordTypeName = null;
                
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().saveApplicationFilter(request);
		System.assert( response != null );
        System.assert( !response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveApplicationFilter_Null_FilterInfoList() {
        
        Test.startTest();
        
        APFT_WrapperDef.APFT_Request request = new APFT_WrapperDef.APFT_Request();        
        request.recordTypeName = APFT_Constants.RECORD_TYPE_WIZARD;
        request.filterInfoList = null;
                
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().saveApplicationFilter(request);
		System.assert( response != null );
        System.assert( !response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveApplicationFilter_Empty_RecordTypeName() {
        
        Test.startTest();
        
        APFT_WrapperDef.APFT_Request request = new APFT_WrapperDef.APFT_Request();        
        request.recordTypeName = '';
                
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().saveApplicationFilter(request);
		System.assert( response != null );
        System.assert( !response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveApplicationFilter_Empty_FilterInfoList() {
        
        Test.startTest();
        
        APFT_WrapperDef.APFT_Request request = new APFT_WrapperDef.APFT_Request();        
        request.recordTypeName = APFT_Constants.RECORD_TYPE_WIZARD;
                
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().saveApplicationFilter(request);
		System.assert( response != null );
        System.assert( !response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveApplicationFilter_Invalid_RecordTypeName() {
        
        Test.startTest();
        
        APFT_WrapperDef.APFT_Request request = new APFT_WrapperDef.APFT_Request();        
        request.recordTypeName = 'Invalid';
                
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().saveApplicationFilter(request);
		System.assert( response != null );
        System.assert( !response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveApplicationFilter_Read_Only() {
        
        Test.startTest();
        
        Test.setReadOnlyApplicationMode(true);
        
        APFT_WrapperDef.APFT_Request request = new APFT_WrapperDef.APFT_Request();        
        request.recordTypeName = APFT_Constants.RECORD_TYPE_WIZARD;
        
        APFT_WrapperDef.APFT_FilterInfo filterInfo = new APFT_WrapperDef.APFT_FilterInfo();
        filterInfo.processId = 'Wizard_1';
        filterInfo.onlineEnabled = true;
        
        request.filterInfoList.add( filterInfo );
                
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().saveApplicationFilter(request);
		System.assert( response != null );
        System.assert( !response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveApplicationFilter_Wizard() {
        
        Test.startTest();
        
        APFT_WrapperDef.APFT_Request request = new APFT_WrapperDef.APFT_Request();        
        request.recordTypeName = APFT_Constants.RECORD_TYPE_WIZARD;
        
        APFT_WrapperDef.APFT_FilterInfo filterInfo = new APFT_WrapperDef.APFT_FilterInfo();
        filterInfo.processId = 'Wizard_1';
        filterInfo.onlineEnabled = true;
        filterInfo.iPadEnabled = true;
        filterInfo.iPhoneEnabled = true;
        filterInfo.androidTabletEnabled = true;
        filterInfo.androidPhoneEnabled = true;
        filterInfo.windowsEnabled = true;
        
        request.filterInfoList.add( filterInfo );
                
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().saveApplicationFilter(request);
		System.assert( response != null );
        System.assert( response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveApplicationFilter_SFM() {
        
        Test.startTest();
        
        APFT_WrapperDef.APFT_Request request = new APFT_WrapperDef.APFT_Request();        
        request.recordTypeName = APFT_Constants.RECORD_TYPE_SFM_PROCESS_NODE_OBJECT;
        
        APFT_WrapperDef.APFT_FilterInfo filterInfo = new APFT_WrapperDef.APFT_FilterInfo();
        filterInfo.processId = 'Process_Node_Target';
        filterInfo.onlineEnabled = true;
        
        request.filterInfoList.add( filterInfo );
                
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().saveApplicationFilter(request);
		System.assert( response != null );
        System.assert( response.success );
        
        Test.stopTest();
    }
    
    static testMethod void testSaveApplicationFilter_CustomAction() {
        
        Test.startTest();
        
        APFT_WrapperDef.APFT_Request request = new APFT_WrapperDef.APFT_Request();        
        request.recordTypeName = APFT_Constants.RECORD_TYPE_CUSTOM_ACTION;
        
        APFT_WrapperDef.APFT_FilterInfo filterInfo = new APFT_WrapperDef.APFT_FilterInfo();
        filterInfo.processId = 'Process_Node_Target';
        filterInfo.onlineEnabled = true;
        
        request.filterInfoList.add( filterInfo );
                
        APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().saveApplicationFilter(request);
		System.assert( response != null );
        System.assert( response.success );
        
        Test.stopTest();
    }
    
    static void initWizards() {
                
        RecordType wizardType = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = :APFT_Constants.RECORD_TYPE_WIZARD LIMIT 1 ]; 
        RecordType processNodeObjectType = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = :APFT_Constants.RECORD_TYPE_SFM_PROCESS_NODE_OBJECT LIMIT 1 ]; 
        RecordType sfmType = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = :APFT_Constants.RECORD_TYPE_SFM LIMIT 1 ]; 
        RecordType customActionType = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = :APFT_Constants.RECORD_TYPE_CUSTOM_ACTION LIMIT 1 ]; 
        
        List<SVMXC__ServiceMax_Processes__c> wizardList = new List<SVMXC__ServiceMax_Processes__c>();
        
        SVMXC__ServiceMax_Processes__c wizardProcesses1 = new SVMXC__ServiceMax_Processes__c(
            
            RecordTypeId = wizardType.id, 
            SVMXC__Name__c = 'Wizard 1',            
            SVMXC__ProcessID__c = 'Wizard_1',
            SVMXC__Active__c = true,
            SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c'
        );
        wizardList.add(wizardProcesses1);
        
        SVMXC__ServiceMax_Processes__c wizardProcesses2 = new SVMXC__ServiceMax_Processes__c(
            
            RecordTypeId = wizardType.id, 
            SVMXC__Name__c = 'Wizard 2',
            SVMXC__ProcessID__c = 'Wizard_2',
            SVMXC__Active__c = true,
            SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c'
        );
        wizardList.add(wizardProcesses2);
        
        SVMXC__ServiceMax_Processes__c wizardProcesses3 = new SVMXC__ServiceMax_Processes__c(
            
            RecordTypeId = wizardType.id, 
            SVMXC__Name__c = 'Wizard 3',
            SVMXC__ProcessID__c = 'Wizard_3',
            SVMXC__Active__c = true,
            SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c'
        );
        wizardList.add(wizardProcesses3);
        
        SVMXC__ServiceMax_Processes__c wizardProcesses4 = new SVMXC__ServiceMax_Processes__c(
            
            RecordTypeId = wizardType.id, 
            SVMXC__Name__c = 'Wizard 4',
            SVMXC__ProcessID__c = 'Wizard_4',
            SVMXC__Active__c = false,
            SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c'
        );
        wizardList.add(wizardProcesses4);
        
        SVMXC__ServiceMax_Processes__c sfmProcess = new SVMXC__ServiceMax_Processes__c(
            
            RecordTypeId = sfmType.id, 
            SVMXC__Name__c = 'SFM Process Type',
            SVMXC__ProcessID__c = 'SFM_Process_Type',
            SVMXC__Active__c = true,
            SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c',
            SVMXC__Dispatch_Process_Status__c = 'Complete'
        );
        insert sfmProcess;
        
        SVMXC__ServiceMax_Processes__c processNodeObject = new SVMXC__ServiceMax_Processes__c(
            
            RecordTypeId = processNodeObjectType.id, 
            SVMXC__Name__c = 'Process Node Object',
            SVMXC__ProcessID__c = 'Process_Node_Object',
            SVMXC__Active__c = true,
            SVMXC__Process__c = sfmProcess.Id,
            SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c',
            SVMXC__Type__c = 'SOURCE'
        );
        wizardList.add(processNodeObject);
        
        SVMXC__ServiceMax_Processes__c customAction = new SVMXC__ServiceMax_Processes__c(
            
            RecordTypeId = customActionType.id, 
            SVMXC__Name__c = 'Custom Action',
            SVMXC__ProcessID__c = 'Custom_Action',
            SVMXC__Active__c = true,
            SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c'
        );
        wizardList.add(customAction);
        
        insert wizardList;
    }
}