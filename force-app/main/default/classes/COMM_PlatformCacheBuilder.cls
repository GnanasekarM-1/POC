/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class has all the builder classes required for Platform Cache.
 *
 * @author Ramachandra Mohan
 * @version 19.3
 * @since 2019
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       20 Sep 2019     Created.
 *****************************************************************************************************/
public class COMM_PlatformCacheBuilder {
    
    /**
     * Private static const instance variable to hold COMM_Utils_ManageSettings class instance.
     */
    private static final COMM_Utils_ManageSettings settingManager = new COMM_Utils_ManageSettings();
    
	/**
     * This class is used to initialize the names expression details to the Platform Cache.
     */
    public class NamedExpressionCache implements Cache.CacheBuilder {
        
        /**
         * Override method to retrieve names expression details for given expression id. This method will be called by platform 
         * when the key not exists in the Platform Cache.
         * 
         * @param expressionId expression ID for which mapping details to be retrieved for Platform Cache.
         * @return Returns names expression detail map.
         */
        public Object doLoad( String expressionId ) {
            
            System.debug( LoggingLevel.DEBUG, 'NamedExpressionCache::doLoad() - enter; expressionId = ' + expressionId );
            
            Map<SObject,List<SObject>> expressionDetailMap = new Map<SObject,List<SObject>>();
            try {
                expressionDetailMap = COMM_CreateServerCache.getExpressionDetails(expressionId);
            }
            catch( Exception e ){
                System.debug( LoggingLevel.ERROR, 'NamedExpressionCache::doLoad(): Failed to retrieve expression details. ' + e.getMessage() );
            }
            finally {
                System.debug( LoggingLevel.DEBUG, 'NamedExpressionCache::doLoad() - exit;' );
            }
             
            return expressionDetailMap;
        }
    }
    
    /**
     * This class is used to initialize the field mapping informations to the Platform Cache.
     */
    public class FieldMappingCache implements Cache.CacheBuilder {
        
        /**
         * Override method to retrieve field mapping details for given mapping id. This method will be called by platform 
         * when the key not exists in the Platform Cache.
         * 
         * @param mappingId mapping ID for which mapping details to be retrieved for Platform Cache.
         * @return Returns mapping details.
         */
        public Object doLoad( String mappingId ) {
            
            System.debug( LoggingLevel.DEBUG, 'TransactionManagerCache::doLoad() - enter; mappingId = ' + mappingId );
            
            Map<SObject,List<SObject>> fieldMappingDetailMap = new Map<SObject,List<SObject>>();
            try {
                fieldMappingDetailMap = COMM_CreateServerCache.getFieldMappingDetail(mappingId);
            }
            catch( Exception e ){
                System.debug( LoggingLevel.ERROR, 'TransactionManagerCache::doLoad(): Failed to retrieve field mapping information. ' + e.getMessage() );
            }
            finally {
                System.debug( LoggingLevel.DEBUG, 'TransactionManagerCache::doLoad() - exit;' );
            }
             
            return fieldMappingDetailMap;
        }
    }
    /**
     * This class is used to initialize the transaction manager informations with process node 
     * informations to the Platform Cache.
     */
    public class TransactionManagerCache implements Cache.CacheBuilder {
        
        /**
         * Override method to retrieve configuration profile for given user profile. This method will be called by platform 
         * when the key not exists in the Platform Cache.
         * 
         * @param profileId user profile ID for which configuration profile to be retrieved for Platform Cache.
         * @return Returns global setting value map.
         */
        public Object doLoad( String processId ) {
            
            System.debug( LoggingLevel.DEBUG, 'TransactionManagerCache::doLoad() - enter; processId = ' + processId );
            
            Map<SObject,List<SObject>> transactionManagerMap = new Map<SObject,List<SObject>>();
            try {
                transactionManagerMap = COMM_CreateServerCache.getTargetManagerInfo(processId);
            }
            catch( Exception e ){
                System.debug( LoggingLevel.ERROR, 'TransactionManagerCache::doLoad(): Failed to retrieve record type id. ' + e.getMessage() );
            }
            finally {
                System.debug( LoggingLevel.DEBUG, 'TransactionManagerCache::doLoad() - exit;' );
            }
             
            return transactionManagerMap;
        }
    }

    /**
     * This class is used to initialize the configuration access for user profile to the Platform Cache.
     */
    public class ObjectRecordTypeIdCache implements Cache.CacheBuilder {
        
        /**
         * Override method to retrieve configuration profile for given user profile. This method will be called by platform 
         * when the key not exists in the Platform Cache.
         * 
         * @param profileId user profile ID for which configuration profile to be retrieved for Platform Cache.
         * @return Returns global setting value map.
         */
        public Object doLoad( String objectName ) {
            
            System.debug( LoggingLevel.DEBUG, 'ObjectRecordTypeIdCache::doLoad() - enter; objectName = ' + objectName );
            
            Map<String,Id> recordTypeIdMap = new Map<String,Id>();
            try {
                
                String objectApiName = EncodingUtil.convertFromHex(objectName).toString();
                recordTypeIdMap = COMM_RecordTypeUtilities.getObjectRecordTypeId(objectApiName);
                /*for( RecordType recordType : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = :objectApiName] ) {
                    recordTypeIdMap.put(recordType.DeveloperName, recordType.Id);
                }*/
            }
            catch( Exception e ){
                System.debug( LoggingLevel.ERROR, 'ObjectRecordTypeIdCache::doLoad(): Failed to retrieve record type id. ' + e.getMessage() );
            }
            finally {
                System.debug( LoggingLevel.DEBUG, 'ObjectRecordTypeIdCache::doLoad() - exit;' );
            }
             
            return recordTypeIdMap;
        }
    }
    
    /**
     * This class is used to initialize the configuration access for user profile to the Platform Cache.
     */
    public class ConfigurationProfileCache implements Cache.CacheBuilder {
        
        /**
         * Override method to retrieve configuration profile for given user profile. This method will be called by platform 
         * when the key not exists in the Platform Cache.
         * 
         * @param profileId user profile ID for which configuration profile to be retrieved for Platform Cache.
         * @return Returns global setting value map.
         */
        public Object doLoad( String profileId ) {
            
            System.debug( LoggingLevel.DEBUG, 'ConfigurationProfileCache::doLoad() - enter; profileId = ' + profileId );
            
            String svmxProfileId = profileId;
            try {
                List<SVMXC__ServiceMax_Config_Data__c> configAccessRecord = [SELECT SVMXC__Access_Configuration_Profile__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Profile__c = :profileId AND RecordType.Name = 'Configuration Access' AND SVMXC__Access_Configuration_Profile__c != null AND SVMXC__Active__c = true];

                if(configAccessRecord != null && !configAccessRecord.isEmpty()){
                    svmxProfileId = configAccessRecord[0].SVMXC__Access_Configuration_Profile__c;
                } else {
                    System.debug( LoggingLevel.WARN, 'ConfigurationProfileCache::doLoad(): Configuration profile not exists for profile ID. profileId = ' + profileId );
                }
            }
            catch( Exception e ){
                System.debug( LoggingLevel.ERROR, 'ConfigurationProfileCache::doLoad(): Failed to retrieve group profile for profile Id. ' + e.getMessage() );
            }
            finally {
                System.debug( LoggingLevel.DEBUG, 'ConfigurationProfileCache::doLoad() - exit; svmxProfileId=' + svmxProfileId );
            }
             
            return svmxProfileId;
        }
    }
    
    /**
     * This class is used to initialize the global setting values map to the Platform Cache.
     */
    public class GlobalSettingsCache implements Cache.CacheBuilder {
        
        /**
         * Override method to retrieve all the global setting values. This method will be called by platform 
         * when the key not exists in the Platform Cache.
         * 
         * @param key unique identifier for Platform Cache.
         * @return Returns global setting value map.
         */
        public Object doLoad(String key) {
            
            System.debug( LoggingLevel.DEBUG, 'GlobalSettingsCache::doLoad() - enter; key = ' + key );
            
            Map<String, String> globalSettingsMap = new Map<String, String>();
            try {
                globalSettingsMap = settingManager.getGlobalSettingList();
            }
            catch(Exception e) {
                System.debug( LoggingLevel.ERROR, 'GlobalSettingsCache::doLoad(): Failed to retrieve global settings from utility manager. ' + e.getMessage() );
            }
            finally {
                System.debug( LoggingLevel.DEBUG, 'GlobalSettingsCache::doLoad() - exit;' );
            }
            return globalSettingsMap;
        }
    }
    
    /**
     * This class is used to initialize the group setting values to the Platform Cache.
     */
    public class GroupSettingsCache implements Cache.CacheBuilder {

        /**
         * Override method to retrieve all group setting values for given submodules. This method will be called by platform 
         * when the key not exists in the Platform Cache.
         * 
         * @param key unique identifier for Platform Cache.
         * @return Returns group setting value map.
         */
        public Object doLoad( String profileSubmoduleKey ) {
            
            System.debug( LoggingLevel.DEBUG, 'GroupSettingsCache::doLoad() - enter; profileSubmoduleKey = ' + profileSubmoduleKey );
            
            Map<String, String> groupSettingMap = new Map<String, String>();
            
            try {
                profileSubmoduleKey = profileSubmoduleKey.substring( UserInfo.getProfileId().length() );
                final String submoduleId = EncodingUtil.convertFromHex(profileSubmoduleKey).toString();
                
                //groupSettingMap = settingManager.SVMX_getSettingList( submoduleId );
                groupSettingMap = settingManager.getSettingList( submoduleId );
                
                System.debug(LoggingLevel.INFO, 'Setting values retrieved for cahcing. submoduleId =' + submoduleId );
            }
            catch( Exception e ) {
                System.debug( LoggingLevel.ERROR, 'GroupSettingsCache::doLoad(): Failed to retrieve settings from utility manager. ' + e.getMessage() );
            }
            finally {
                System.debug( LoggingLevel.DEBUG, 'GroupSettingsCache::doLoad() - exit;' );
            }
            
            return groupSettingMap;
        }
    }
    
    /**
     * This class is used to initialize the global describe result to the Platform Cache.
     */
    public class GlobalDescribeCache implements Cache.CacheBuilder {
    
        /**
         * Override method to retrieve global describe. This method will be called by platform 
         * when the key not exists in the Platform Cache.
         * 
         * @param key unique identifier for Platform Cache.
         * @return Returns group setting value map.
         */
        public Object doLoad( String describeKey ) {
            
            System.debug( LoggingLevel.DEBUG, 'GlobalDescribeCache::doLoad() - enter; describeKey = ' + describeKey );
            
            Map<String, Schema.SObjectType> globalDescribeMap = new Map<String, Schema.SObjectType>();
            
            try {
            	globalDescribeMap = Schema.getGlobalDescribe();
            }
            catch( Exception e ) {
                System.debug( LoggingLevel.ERROR, 'GlobalDescribeCache::doLoad(): Failed to retrieve object describe. ' + e.getMessage() );
            }
            finally {
                System.debug( LoggingLevel.DEBUG, 'GlobalDescribeCache::doLoad() - exit;' );
            }
            
            return globalDescribeMap;
        }
    }
    
    /**
     * This class is used to initialize the object describe reult to the Platform Cache.
     */
    public class ObjectDescribeCache implements Cache.CacheBuilder {
    
        /**
         * Override method to retrieve object describe for given object name. This method will be called by platform 
         * when the key not exists in the Platform Cache.
         * 
         * @param key unique identifier for Platform Cache.
         * @return Returns group setting value map.
         */
        public Object doLoad( String objectName ) {
            
            System.debug( LoggingLevel.DEBUG, 'ObjectDescribeCache::doLoad() - enter; objectName = ' + objectName );
            
            Map<String, Schema.SObjectField> objectDescribeMap = new Map<String, Schema.SObjectField>();
            
            try {
                final String objectAPIName = EncodingUtil.convertFromHex(objectName).toString();
                objectDescribeMap = Schema.getGlobalDescribe().get(objectAPIName).getDescribe().Fields.getMap();
                
                System.debug(LoggingLevel.INFO, 'Field describe map retrieved for cahcing. objectAPIName =' + objectAPIName );
            }
            catch( Exception e ) {
                System.debug( LoggingLevel.ERROR, 'ObjectDescribeCache::doLoad(): Failed to retrieve object describe. ' + e.getMessage() );
            }
            finally {
                System.debug( LoggingLevel.DEBUG, 'ObjectDescribeCache::doLoad() - exit;' );
            }
            
            return objectDescribeMap;
        }
    }
}