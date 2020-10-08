@isTest
public class APFT_Utilities_UT {
        
	static testMethod void testApplyApplicationFilters_Null_Records() {
        
        Test.startTest();
                
        Boolean status = APFT_Utilities.getInstance().applyApplicationFilters( null, APFT_Constants.APPLICATION_PROFILE_ID_ONLINE );
        System.assert( !status );
        
        Test.stopTest();
    }
    
    static testMethod void testApplyApplicationFilters_Empty_Records() {
        
        Test.startTest();
                
        Boolean status = APFT_Utilities.getInstance().applyApplicationFilters( new List<SVMXC__ServiceMax_Processes__c>(), APFT_Constants.APPLICATION_PROFILE_ID_ONLINE );
        System.assert( !status );
        
        Test.stopTest();
    }
    
    static testMethod void testApplyApplicationFilters_Null_Profile_Type() {
        
        Test.startTest();
                
        Boolean status = APFT_Utilities.getInstance().applyApplicationFilters( new List<SVMXC__ServiceMax_Processes__c>(), null );
        System.assert( !status );
        
        Test.stopTest();
    }
    
    static testMethod void testApplyApplicationFilters() {
        
        Test.startTest();
        
        List<SVMXC__ServiceMax_Processes__c> requestProcessList = new List<SVMXC__ServiceMax_Processes__c>();
        
        initSetup();
        
        List<SVMXC__ServiceMax_Processes__c> wizardList = [SELECT SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Record_Type_Name__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = :APFT_Constants.RECORD_TYPE_WIZARD ];
        System.assert( wizardList.size() == 3, wizardList.size() );
        requestProcessList.addAll(wizardList);
        
        initWizardSteps();
        
        List<SVMXC__ServiceMax_Processes__c> wizardStepList = [SELECT SVMXC__Name__c, SVMXC__Process__r.SVMXC__ProcessID__c, SVMXC__Record_Type_Name__c, SVMXC__Action_Type__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = :APFT_Constants.RECORD_TYPE_WIZARD_STEP ];
        System.assert( wizardStepList.size() == 1, wizardStepList.size() );
        requestProcessList.addAll(wizardStepList);
        
        Boolean status = APFT_Utilities.getInstance().applyApplicationFilters( requestProcessList, APFT_Constants.APPLICATION_PROFILE_ID_ONLINE );
        System.assert( status );
        System.assert( requestProcessList.size() == 3, 'Size: ' + requestProcessList.size() );
        
        APFT_Schema.Filters filter = APFT_Utilities.getInstance().getDeviceFilters( APFT_Constants.APPLICATION_PROFILE_ID_ONLINE );
        System.assert( filter != null );
        System.assert( !filter.wizards.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testCreateInstanceByDeviceType() {
        
        Test.startTest();
        
        initSetup();
        
        List<SVMXC__ServiceMax_Processes__c> wizardList = [SELECT SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Record_Type_Name__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = :APFT_Constants.RECORD_TYPE_WIZARD ];
        System.assert( wizardList.size() == 3, wizardList.size() );
        
        APFT_Utilities apftUtilities = APFT_Utilities.createInstanceByDeviceType( new List<String> {APFT_Constants.APPLICATION_PROFILE_ID_ONLINE} );
        
        APFT_Schema.Filters filter = apftUtilities.getDeviceFilters( APFT_Constants.APPLICATION_PROFILE_ID_ONLINE );
        System.assert( filter != null );
        System.assert( !filter.wizards.isEmpty() );
        
        filter = apftUtilities.getDeviceFilters( APFT_Constants.APPLICATION_PROFILE_ID_IPAD );
        System.assert( filter == null );
        
        Test.stopTest();
    }
    
    static testMethod void testClearInvalidFilters_Invalid_Input() {
        
        Test.startTest();
        
        APFT_Utilities.getInstance().clearInvalidFilters( null, new Set<String>() );
        APFT_Utilities.getInstance().clearInvalidFilters( '', new Set<String>() );
        APFT_Utilities.getInstance().clearInvalidFilters( APFT_Constants.RECORD_TYPE_WIZARD, null );
        
        Test.stopTest();
    }
    
    static testMethod void testClearInvalidFilters() {
        
        Test.startTest();
        
        initSetup();
        
        List<SVMXC__ServiceMax_Processes__c> wizardList = [SELECT SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Record_Type_Name__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = :APFT_Constants.RECORD_TYPE_WIZARD ];
        System.assert( wizardList.size() == 3, wizardList.size() );
        
        Set<String> processIdSet = new Set<String>();
        for( SVMXC__ServiceMax_Processes__c wizard : wizardList ) {
            processIdSet.add(wizard.SVMXC__ProcessID__c);
        }
        
        APFT_Utilities.getInstance().clearInvalidFilters( APFT_Constants.RECORD_TYPE_WIZARD, processIdSet );
        APFT_Utilities.getInstance().clearInvalidFilters( APFT_Constants.RECORD_TYPE_SFM_PROCESS_NODE_OBJECT, processIdSet );
        APFT_Utilities.getInstance().clearInvalidFilters( APFT_Constants.RECORD_TYPE_CUSTOM_ACTION, processIdSet );
        
        Test.stopTest();
    }
    
    static void initSetup() {
        
        RecordType applicationProfileType = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = :APFT_Constants.RECORD_TYPE_APPLICATION_PROFILE LIMIT 1 ]; 
        
        SVMXC__ServiceMax_Processes__c onlineProcesses = new SVMXC__ServiceMax_Processes__c(
            
            RecordTypeId = applicationProfileType.id, 
            SVMXC__Name__c = 'ServiceMax Online',
            SVMXC__IsStandard__c = true,
            SVMXC__Values__c = '{ "wizards": ["Wizard_1"], "sfms" : ["SFM_1"], "sfactions" : ["OTHERS_1"] }',
            SVMXC__ProcessID__c = APFT_Constants.APPLICATION_PROFILE_ID_ONLINE
        );
        
        insert onlineProcesses;
        
        RecordType wizardType = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = :APFT_Constants.RECORD_TYPE_WIZARD LIMIT 1 ]; 
        
        List<SVMXC__ServiceMax_Processes__c> wizardList = new List<SVMXC__ServiceMax_Processes__c>();
        
        SVMXC__ServiceMax_Processes__c wizardProcesses1 = new SVMXC__ServiceMax_Processes__c(
            
            RecordTypeId = wizardType.id, 
            SVMXC__Name__c = 'Wizard 1',            
            SVMXC__ProcessID__c = 'Wizard_1'
        );
        wizardList.add(wizardProcesses1);
        
        SVMXC__ServiceMax_Processes__c wizardProcesses2 = new SVMXC__ServiceMax_Processes__c(
            
            RecordTypeId = wizardType.id, 
            SVMXC__Name__c = 'Wizard 2',
            SVMXC__ProcessID__c = 'Wizard_2'
        );
        wizardList.add(wizardProcesses2);
        
        SVMXC__ServiceMax_Processes__c wizardProcesses3 = new SVMXC__ServiceMax_Processes__c(
            
            RecordTypeId = wizardType.id, 
            SVMXC__Name__c = 'Wizard 3',
            SVMXC__ProcessID__c = 'Wizard_3'
        );
        wizardList.add(wizardProcesses3);
        
        insert wizardList;
    }
    
    static void initWizardSteps() {
        
        RecordType sfmType = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = :APFT_Constants.RECORD_TYPE_SFM LIMIT 1 ]; 
        
        SVMXC__ServiceMax_Processes__c sfmProcesses = new SVMXC__ServiceMax_Processes__c(
            
            RecordTypeId = sfmType.id, 
            SVMXC__Name__c = 'SFM 1',
            SVMXC__ProcessID__c = 'SFM_TEST_PROCESS_1'
        );
        
        insert sfmProcesses;
        
        RecordType wizardStepType = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = :APFT_Constants.RECORD_TYPE_WIZARD_STEP LIMIT 1 ]; 
        
        SVMXC__ServiceMax_Processes__c wizardStepProcesses = new SVMXC__ServiceMax_Processes__c(
            
            RecordTypeId = wizardStepType.id, 
            SVMXC__Name__c = 'Wizard Step 1',
            SVMXC__ProcessID__c = sfmProcesses.Name,
            SVMXC__Process__c = sfmProcesses.Id,
            SVMXC__Action_Type__c = 'SFM'
        );
        
        insert wizardStepProcesses;
    }
}