@isTest
public class CONF_ApplicationFilters_UT {
    
	static testMethod void testGetSupportedRecordTypes() {
        
        Test.startTest();
        
        String result = (String) CONF_ApplicationFilters.getSupportedRecordTypes( null );
        System.assert( result != null );
        
        CONF_ApplicationFilters.Output resultObject = (CONF_ApplicationFilters.Output) JSON.deserialize( result, CONF_ApplicationFilters.Output.class );            
        System.assert( resultObject.success );
        
        Test.stopTest();
    }
    
    static testMethod void testGetAllSourceObjects_Null() {
        
        Test.startTest();
        
        String result = (String) CONF_ApplicationFilters.getAllSourceObjects( null );
        System.assert( result != null );
        
        CONF_ApplicationFilters.Output resultObject = (CONF_ApplicationFilters.Output) JSON.deserialize( result, CONF_ApplicationFilters.Output.class );            
        System.assert( !resultObject.success );
        
        Test.stopTest();
    }
    
    static testMethod void testGetAllSourceObjects_Empty() {
        
        Test.startTest();
        
        String result = (String) CONF_ApplicationFilters.getAllSourceObjects( '' );
        System.assert( result != null );
        
        CONF_ApplicationFilters.Output resultObject = (CONF_ApplicationFilters.Output) JSON.deserialize( result, CONF_ApplicationFilters.Output.class );            
        System.assert( !resultObject.success );
        
        Test.stopTest();
    }
    
    static testMethod void testGetAllSourceObjects_Invalid_Request() {
        
        Test.startTest();
        
        String result = (String) CONF_ApplicationFilters.getAllSourceObjects( '{Invalid' );
        System.assert( result != null );
        
        CONF_ApplicationFilters.Output resultObject = (CONF_ApplicationFilters.Output) JSON.deserialize( result, CONF_ApplicationFilters.Output.class );            
        System.assert( !resultObject.success );
        
        Test.stopTest();
    }
    
    static testMethod void testGetAllSourceObjects_No_Processes() {
        
        Test.startTest();
        
        String result = (String) CONF_ApplicationFilters.getAllSourceObjects( '{"recordTypeName":"Wizard"}' );
        System.assert( result != null );
        
        CONF_ApplicationFilters.Output resultObject = (CONF_ApplicationFilters.Output) JSON.deserialize( result, CONF_ApplicationFilters.Output.class );            
        System.assert( resultObject.success, resultObject );
        System.assert( resultObject.objectInfoList.isEmpty(), resultObject );
        
        Test.stopTest();
    }
    
    static testMethod void testGetAllSourceObjects() {
        
        Test.startTest();
        
        initWizards();
        
        String result = (String) CONF_ApplicationFilters.getAllSourceObjects( '{"recordTypeName":"Wizard"}' );
        System.assert( result != null );
        
        CONF_ApplicationFilters.Output resultObject = (CONF_ApplicationFilters.Output) JSON.deserialize( result, CONF_ApplicationFilters.Output.class );            
        System.assert( resultObject.success, resultObject.message );
        System.assert( !resultObject.warning );
        
        Test.stopTest(); 
    }
    
    static testMethod void testGetApplicationFilter_Null_Request() {
        
        Test.startTest();
        
        String result = (String) CONF_ApplicationFilters.getApplicationFilter( null );
        System.assert( result != null );
        
        CONF_ApplicationFilters.Output resultObject = (CONF_ApplicationFilters.Output) JSON.deserialize( result, CONF_ApplicationFilters.Output.class );            
        System.assert( !resultObject.success, resultObject.message );        
        
        Test.stopTest();
    }
    
    static testMethod void testGetApplicationFilter_Empty_Request() {
        
        Test.startTest();
        
        String result = (String) CONF_ApplicationFilters.getApplicationFilter( '' );
        System.assert( result != null );
        
        CONF_ApplicationFilters.Output resultObject = (CONF_ApplicationFilters.Output) JSON.deserialize( result, CONF_ApplicationFilters.Output.class );            
        System.assert( !resultObject.success, resultObject.message );        
        
        Test.stopTest();
    }
    
    static testMethod void testGetApplicationFilter_Invalid_Request() {
        
        Test.startTest();
        
        String result = (String) CONF_ApplicationFilters.getApplicationFilter( '{Invalid' );
        System.assert( result != null );
        
        CONF_ApplicationFilters.Output resultObject = (CONF_ApplicationFilters.Output) JSON.deserialize( result, CONF_ApplicationFilters.Output.class );            
        System.assert( !resultObject.success, resultObject.message );        
        
        Test.stopTest();
    }
    
    static testMethod void testGetApplicationFilter() {
        
        Test.startTest();
        
        initWizards();
        
        String result = (String) CONF_ApplicationFilters.getApplicationFilter( '{"recordTypeName":"Wizard","sourceObjectName":"SVMXC__Service_Order__c"}' );
        System.assert( result != null );
        
        CONF_ApplicationFilters.Output resultObject = (CONF_ApplicationFilters.Output) JSON.deserialize( result, CONF_ApplicationFilters.Output.class );            
        System.assert( resultObject.success, resultObject.message );        
        
        Test.stopTest();
    }
    
    static testMethod void testSaveApplicationFilter_Null_Request() {
        
        Test.startTest();
        
        initWizards();
        
        String result = (String) CONF_ApplicationFilters.saveApplicationFilter(null);
        System.assert( result != null );
        
        CONF_ApplicationFilters.Output resultObject = (CONF_ApplicationFilters.Output) JSON.deserialize( result, CONF_ApplicationFilters.Output.class );            
        System.assert( !resultObject.success, resultObject.message );        
        
        Test.stopTest();
    }
    
    static testMethod void testSaveApplicationFilter_Empty_Request() {
        
        Test.startTest();
        
        initWizards();
        
        String result = (String) CONF_ApplicationFilters.saveApplicationFilter('');
        System.assert( result != null );
        
        CONF_ApplicationFilters.Output resultObject = (CONF_ApplicationFilters.Output) JSON.deserialize( result, CONF_ApplicationFilters.Output.class );            
        System.assert( !resultObject.success, resultObject.message );        
        
        Test.stopTest();
    }
    
    static testMethod void testSaveApplicationFilter_Invalid_Request() {
        
        Test.startTest();
        
        initWizards();
        
        String result = (String) CONF_ApplicationFilters.saveApplicationFilter('{Invalid');
        System.assert( result != null );
        
        CONF_ApplicationFilters.Output resultObject = (CONF_ApplicationFilters.Output) JSON.deserialize( result, CONF_ApplicationFilters.Output.class );            
        System.assert( !resultObject.success, resultObject.message );        
        
        Test.stopTest();
    }
    
    static testMethod void testSaveApplicationFilter() {
        
        Test.startTest();
        
        initWizards();
        
        String result = (String) CONF_ApplicationFilters.saveApplicationFilter( '{"recordTypeName":"Wizard","filterInfoList":[{"name":"Wizard 1","processId":"Wizard_1","description":"","onlineEnabled":true,"iPadEnabled":false,"iPhoneEnabled":false,"androidPhoneEnabled":false,"androidTabletEnabled":false,"windowsEnabled":false}]}' );
        System.assert( result != null );
        
        CONF_ApplicationFilters.Output resultObject = (CONF_ApplicationFilters.Output) JSON.deserialize( result, CONF_ApplicationFilters.Output.class );            
        System.assert( resultObject.success, resultObject.message );        
        
        Test.stopTest();
    }
    
    static void initWizards() {
                
        RecordType wizardType = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = :APFT_Constants.RECORD_TYPE_WIZARD LIMIT 1 ]; 
        
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
        
        insert wizardList;
    }
}