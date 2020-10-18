@isTest
private class COMM_CreateServerCache_UT {

    @testSetup static void setup() {
        
        SFMTransactionSync_UT.insertConfigData();
        SFMTransactionSync_UT.createIPADSetting();
        
        SVMXC__ServiceMax_Properties__c pc001 = new SVMXC__ServiceMax_Properties__c( Name='PC001', SVMXC__Key__c='Platform_Cache_Enabled', SVMXC__Value__c='True');
        
        insert pc001;
    }
    
    static testMethod void testGetAllGlobalSettingValues() {

        Test.startTest();
        
        final Map<String, String> globalSettingMap = COMM_CreateServerCache.getInstance().getAllGlobalSettingValues();
        
        System.Assert( globalSettingMap != null );
        
        Test.stopTest();
    }
    
    static testMethod void testClearGlobalSettingCache() {

        Test.startTest();
        
        COMM_CreateServerCache.getInstance().clearGlobalSettingCache();
        
        Test.stopTest();
    }
    
    static testMethod void testGetGlobalSettingValues() {

        Test.startTest();
        
        final String settingValue = COMM_CreateServerCache.getInstance().getGlobalSettingValue('IPAD018_SET004');
        
        //System.Assert( settingValue != null );
        
        Test.stopTest();
    }
    
    static testMethod void testGetGroupSettingValues() {

        Test.startTest();
        
        final Map<String, String> settingValueMap = COMM_CreateServerCache.getInstance().getGroupSettingValues('IPAD018');
        
        System.Assert( settingValueMap != null );
        System.Assert( settingValueMap.size() != 0 );
        
        Test.stopTest();
    }
    
    static testMethod void testGetGroupSettingValues_specific_settings() {

        Test.startTest();
        
        final Map<String, String> groupSettingMap = COMM_CreateServerCache.getInstance().getGroupSettingValues('IPAD018', new List<String>{'SET016'});
        
        System.Assert( groupSettingMap != null );
        System.Assert( groupSettingMap.size() != 0 );
        
        Test.stopTest();
    }
    
    static testMethod void testGetGroupSettingValues_specific_setting() {

        Test.startTest();
        
        final Map<String, String> groupSettingMap = COMM_CreateServerCache.getInstance().getGroupSettingValues('IPAD018', 'SET016');
        
        System.Assert( groupSettingMap != null );
        System.Assert( groupSettingMap.size() != 0 );
        
        Test.stopTest();
    }
    
    static testMethod void testGetGroupSettingValues_listof_submodules() {

        Test.startTest();
        
        Map<String, Map<String, String>> groupSettingMap = COMM_CreateServerCache.getInstance().getGroupSettingValues( new List<String>{'IPAD018'});
        
        System.Assert( groupSettingMap != null );
        System.Assert( groupSettingMap.size() != 0 );
        
        Test.stopTest();
    }
    
    static testMethod void testClearGroupSettingCache() {

        Test.startTest();
        
        COMM_CreateServerCache.getInstance().clearGroupSettingCache('IPAD018');
        
        Test.stopTest();
    }
    
    static testMethod void testGetGlobalDescribeCache() {

        Test.startTest();
        
        final Map<String, Schema.SObjectType> globalDescribeMap = COMM_CreateServerCache.getInstance().getGlobalDescribeCache();
        
        System.Assert( globalDescribeMap != null );
        System.Assert( globalDescribeMap.size() != 0 );
        
        Test.stopTest();
    }
    
    static testMethod void testClearGlobalDescribeCache() {

        Test.startTest();
        
        COMM_CreateServerCache.getInstance().clearGlobalDescribeCache();
        
        Test.stopTest();
    }
    
    static testMethod void testGetObjectDescribeCache() {

        Test.startTest();
        
        final Map<String, Schema.SObjectField> objectDescribeMap = COMM_CreateServerCache.getInstance().getObjectDescribeCache('SVMXC__Service_Order__c');
        
        System.Assert( objectDescribeMap != null );
        System.Assert( objectDescribeMap.size() != 0 );
        
        Test.stopTest();
    }
    
    static testMethod void testClearObjectDescribeCache() {

        Test.startTest();
        
        COMM_CreateServerCache.getInstance().clearObjectDescribeCache('SVMXC__Service_Order__c');
        
        Test.stopTest();
    }
    
    static testMethod void testGetObjectDescribeCache_null() {

        Test.startTest();
        
        final Map<String, Schema.SObjectField> objectDescribeMap = COMM_CreateServerCache.getInstance().getObjectDescribeCache(null);
        
        System.Assert( objectDescribeMap != null );
        System.Assert( objectDescribeMap.size() == 0 );
        
        Test.stopTest();
    }
    
    static testMethod void testGetObjectDescribeCache_invalid() {

        Test.startTest();
        
        final Map<String, Schema.SObjectField> objectDescribeMap = COMM_CreateServerCache.getInstance().getObjectDescribeCache('invalid');
        
        System.Assert( objectDescribeMap != null );
        System.Assert( objectDescribeMap.size() == 0 );
        
        Test.stopTest();
    }
    
    static testMethod void testProcessTime() {
        
        Long startTime = System.currentTimeMillis();

        Map<String, String> globalSettingValueMap = COMM_CreateServerCache.getInstance().getAllGlobalSettingValues();
        Map<String, Map<String, String>> settingValueMap = COMM_CreateServerCache.getInstance().getGroupSettingValues( new List<String>{'IPAD018'});
        
        System.debug( LoggingLevel.DEBUG, 'Setting Count: ' + settingValueMap.size());
        System.debug( LoggingLevel.DEBUG, 'Processing Time: ' + (System.currentTimeMillis() - startTime) );
        
        startTime = System.currentTimeMillis();
        globalSettingValueMap = COMM_CreateServerCache.getInstance().getAllGlobalSettingValues();
        settingValueMap = COMM_CreateServerCache.getInstance().getGroupSettingValues( new List<String>{'IPAD018'});
        
        System.debug( LoggingLevel.DEBUG, 'Setting Count: ' + settingValueMap.size());
        System.debug( LoggingLevel.DEBUG, 'Processing Time: ' + (System.currentTimeMillis() - startTime ) );
        
        //Clearing Cache
        COMM_CreateServerCache.getInstance().clearGlobalSettingCache();
        COMM_CreateServerCache.getInstance().clearGroupSettingCache('IPAD018');
    }
}