@isTest
global class SPM_Utilities_UT {
    
    static testMethod void testPopulateConfigurationDetails() {
        
        Test.startTest();
        
        List<SPM_ConfigurationDefinition.CalculationMethod> calculationMethodList = SPM_ConfigurationDefinition.getCalculationMethodList( SPM_Schema.Report.FirstTimeFix.name() );
        SPM_Utilities.getInstance().populateConfigurationDetails( calculationMethodList, 'FirstTimeFix' );
        
        Test.stopTest();
    }
    
    static testMethod void testPopulateConfigurationDetailsUtilization() {
        
        Test.startTest();
        
        List<SPM_ConfigurationDefinition.CalculationMethod> calculationMethodList = SPM_ConfigurationDefinition.getCalculationMethodList( SPM_Schema.Report.Utilization.name() );
        SPM_Utilities.getInstance().populateConfigurationDetails( calculationMethodList, 'Utilization' );
        
        Test.stopTest();
    }
    
    static testMethod void testGetAllTimezones() {
        
        Test.startTest();
        
        SPM_WrapperDef.SPM_Response response = SPM_Utilities.getInstance().getAllTimezones();
        
        Test.stopTest();
    }
    
    static testMethod void testBuildString() {
        
        Test.startTest();
        
        List<String> stringList = new List<String> {'Testing', 'SPM', 'Utilities', 'Class'};
        String resultString = SPM_Utilities.getInstance().buildString( stringList, SPM_Consts.SEMICOLON );
        
        System.assert( resultString.endsWith('Testing;SPM;Utilities;Class'), resultString );
        
        Test.stopTest();
    }
}