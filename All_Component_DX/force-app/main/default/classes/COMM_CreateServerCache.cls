/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This Singleton class which has methods to retrieve informations stored 
 * in Org and Session Platform Cache.
 *
 * @author Ramachandra Mohan
 * @version 19.3
 * @since 2019
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       05 Sep 2019     Created.
 *****************************************************************************************************/
public with sharing class COMM_CreateServerCache {

    /** 
     * Private static constant string variable to hold key for global setting cache.
     */
    private static final String GLOBAL_SETTINGS     = 'GBLSettings' + UserInfo.getOrganizationId();
    
    /** 
     * Private static constant string variable to hold key for global describe cache.
     */
    private static final String GLOBAL_DESCRIBE     = 'GDescribe' + UserInfo.getProfileId();
    
    /**
     * Private static boolean to hold partition cache enabled flag.
     */
    private static Boolean isPlatformCacheEnabled      = false;
    
    /**
     * Private static string to hold partition name.
     */
    private static String partitionName      = 'SVMXC.ServicemaxPartition';
    
    /**
     * List of property names for Platform Cache.
     */
    public static final List<String> CACHE_PROPERTY_LIST = new List<String> {'PC001'};
        
    /**
     * Privte instance variable to hold Org Partition instance.
     */
    private final Cache.OrgPartition OrgPartition;

    /**
     * Private static constant variable to hold instance of this class.
     */
    private static final COMM_CreateServerCache instance = new COMM_CreateServerCache();
    
    /**
     * Private static const instance variable to hold COMM_Utils_ManageSettings class instance.
     */
    private static COMM_Utils_ManageSettings settingManager = new COMM_Utils_ManageSettings();
    
    /**
     * Static method to retrieve instance of this class. This method will make sure to return single instance of 
     * this class on multiple calls.
     * 
     * @return Returns instance of this class.
     * @example COMM_CreateServerCache cacheManager =  COMM_CreateServerCache.getInstance();
     */
    public static COMM_CreateServerCache getInstance(){
        return instance;
    }
    
    /**
     * This method is used to retrieve global setting value for given setting Id. This method will make sure to retrieve 
     * value from the Platform Cache if exists.
     * 
     * @param settingId Setting Id for which global setting value to be returned.
     * @return Returns setting value for given setting Id.
     * 
     * @example COMM_CreateServerCache.getInstance().getGlobalSettingValue('GLOB001_GBL031');
     */
    public String getGlobalSettingValue( final String settingId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getGlobalSettingValue() - enter');
        
        String settingValue = '';
        
        try {
            if( settingId != null && settingId.trim().length() != 0 ) {
                
                if( OrgPartition != null && isPlatformCacheEnabled ) {
                    
                    // Retrieve all setting values from Platform Cache.
                    settingValue = getAllGlobalSettingValues().get(settingId);
                } else {
                    
                    System.debug( LoggingLevel.WARN, 'getGlobalSettingValue(): Platform Cache not enabled or failed to initialize.' );
                    settingValue = settingManager.getGlobalSettingValue(settingId);
                }
            } else {
                System.debug( LoggingLevel.ERROR, 'getGlobalSettingValue(): Invalid argument. settingId=' + settingId );
            }
        }
        
        catch( Cache.Org.OrgCacheException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getGlobalSettingValue(): Failed to retrieve global settings from Platform Cache; ' + e.getStackTraceString() );
            settingValue = settingManager.getGlobalSettingValue(settingId);
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getGlobalSettingValue() - exit');
        }
        
        return settingValue;
    }
    
    /**
     * This method is used to retrieve global setting value for given setting Id. This method will make sure to retrieve 
     * value from the Platform Cache if exists.
     * 
     * @param settingId Setting Id for which global setting value to be returned.
     * @return Returns setting value for given setting Id.
     * 
     * @example COMM_CreateServerCache.getInstance().getGlobalSettingValue(new List<String>{'GLOB001_GBL031','GLOB001_GBL032'});
     */
    public Map<String,String> getGlobalSettingValues( final List<String> settingList ) {
        
        System.debug( LoggingLevel.DEBUG, 'getGlobalSettingValues() - enter');
        
        Map<String, String> globalSettingsMap = new Map<String, String>();
        
        try {
            if( settingList != null && settingList.size() > 0 ) {
                
                if( OrgPartition != null && isPlatformCacheEnabled ) {
                    
                    // Retrieve all setting values from Platform Cache.
                    globalSettingsMap = getAllGlobalSettingValues();
                } else {
                    
                    System.debug( LoggingLevel.WARN, 'getGlobalSettingValues(): Platform Cache not enabled or failed to initialize.' );
                    globalSettingsMap = settingManager.getGlobalSettingList(settingList);
                }
            } else {
                System.debug( LoggingLevel.ERROR, 'getGlobalSettingValues(): Invalid argument. settingList=' + settingList.size() );
            }
        }
        
        catch( Cache.Org.OrgCacheException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getGlobalSettingValues(): Failed to retrieve global settings from Platform Cache; ' + e.getStackTraceString() );
            globalSettingsMap = settingManager.getGlobalSettingList(settingList);
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getGlobalSettingValues() - exit');
        }
        
        return globalSettingsMap;
    }
    
    /**
     * This method is used to retrieve all global setting values. This will make sure to retrieve values
     * from the Platform Cache if exists.
     * 
     * @return Returns map with all global setting values.
     * 
     * @example Map<String, String> globalSettingMap = COMM_CreateServerCache.getInstance().getAllGlobalSettingValues();
     */
    public Map<String, String> getAllGlobalSettingValues() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllGlobalSettingValues() - enter');
        
        Map<String, String> globalSettingsMap = new Map<String, String>();
        
        try {
            if( OrgPartition != null && isPlatformCacheEnabled ) {
                
                // Retrieve all setting values from Platform Cache.
            	globalSettingsMap = (Map<String, String>) OrgPartition.get( COMM_PlatformCacheBuilder.GlobalSettingsCache.class, GLOBAL_SETTINGS );
            } else {
                    
                System.debug( LoggingLevel.WARN, 'getAllGlobalSettingValues(): Plarform Cache not enabled or failed to initialize.' );
                globalSettingsMap = settingManager.getGlobalSettingList();
            }
            
        }
        catch( Cache.Org.OrgCacheException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllGlobalSettingValues(): Failed to retrieve global settings from Platform Cache; ' + e.getMessage() );
            globalSettingsMap = settingManager.getGlobalSettingList();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllGlobalSettingValues() - exit');
        }
        
        return globalSettingsMap;
    }
    
    /**
     * This method is used to clear global settings from Platform Cache.
     */
    public void clearGlobalSettingCache() {
        
        System.debug( LoggingLevel.DEBUG, 'clearGlobalSettingCache() - enter');
        try {
            if( OrgPartition != null && !OrgPartition.remove( COMM_PlatformCacheBuilder.GlobalSettingsCache.class, GLOBAL_SETTINGS ) ) {
                System.debug( LoggingLevel.WARN, 'clearGlobalSettingCache(): Failed to clear global setting cache.' );
            }
        }
        catch( Cache.Org.OrgCacheException e ) {
            System.debug( LoggingLevel.ERROR, 'clearGlobalSettingCache(): Failed to clear global settings cache' + e.getMessage() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'clearGlobalSettingCache() - exit');
        }
    }
    
    /**
     * This method is used to retrieve all group setting values for given submodule. This will make sure to retrieve 
     * values from the Platform Cache if exists.
     * 
     * @return Returns map with all group setting values for given submodule id.
     * 
     * @example Map<String, String> groupSettingMap = COMM_CreateServerCache.getInstance().getGroupSettingValues('GLOB001');
     */
    public Map<String, String> getGroupSettingValues( final String submoduleId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getGroupSettingValues() - enter; submoduleId= ' + submoduleId);
        
        Map<String, String> groupSettingsMap = new Map<String, String>();
        
        try {
            if( submoduleId != null && submoduleId.trim().length() != 0 ) {
                
                if( OrgPartition != null && isPlatformCacheEnabled ) {
                    
                    // Retrieve group settings from Platform Cache.
                	groupSettingsMap = (Map<String, String>) OrgPartition.get(COMM_PlatformCacheBuilder.GroupSettingsCache.class, buildGroupSettingKey(submoduleId) );
                } else {
                    
                    System.debug( LoggingLevel.WARN, 'getGroupSettingValues(): Plarform Cache not enabled or failed to initialize.' );
                    groupSettingsMap = settingManager.getSettingList( submoduleId );
                }
                
            } else {
                System.debug( LoggingLevel.ERROR, 'getGroupSettingValues(): Invalid argument. submoduleId=' + submoduleId );
            }
        }
        catch( Cache.Org.OrgCacheException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getGroupSettingValues(): Failed to retrieve group settings from Platform Cache; ' + e.getMessage() );
            groupSettingsMap = settingManager.getSettingList( submoduleId );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getGroupSettingValues() - exit');
        }
        
        return groupSettingsMap;
    }
    
    /**
     * This method is used to retrieve group setting values for given submodule and setting ids. This will make sure to retrieve 
     * values from the Platform Cache if exists.
     * 
     * @return Returns map with requested group setting values for given submodule id.
     * 
     * @example Map<String, String> groupSettingMap = COMM_CreateServerCache.getInstance().getGroupSettingValues('SFM002', new List<String>{'SET001','SET002','SET003','SET004'});
     */
    public Map<String, String> getGroupSettingValues( final String submoduleId, final List<String> settingIdList ) {
        
        System.debug( LoggingLevel.DEBUG, 'getGroupSettingValues() - enter; submoduleId= ' + submoduleId + '; settingIdList= ' + settingIdList.size() );
        
        final Map<String, String> selectedSettingsMap = new Map<String, String>();
        
        try {
            // Retrieve group settings from Platform Cache.
            final Map<String, String> groupSettingsMap = getGroupSettingValues(submoduleId);
            
            for( String settingId : settingIdList ) {
                
                if( groupSettingsMap.containsKey(settingId) ) {
                    selectedSettingsMap.put( settingId, groupSettingsMap.get(settingId) );
                } else {
                    System.debug( LoggingLevel.ERROR, 'getGroupSettingValues(): Setting id ' + settingId + ' not exists in submodule ' + submoduleId );
                }
            }
        }
        catch( Cache.Org.OrgCacheException e ) {
            System.debug( LoggingLevel.ERROR, 'getGroupSettingValues(): Failed to retrieve group settings from Platform Cache; ' + e.getMessage() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getGroupSettingValues() - exit');
        }
        
        return selectedSettingsMap;
    }
    
    /**
     * This method is used to retrieve group setting values for given submodule and setting id. This will make sure to retrieve 
     * values from the Platform Cache if exists.
     * 
     * @param submoduleId Submodule ID for which setting to be retrieved.
     * @param settingId Setting ID for which value to be retrieved.
     * 
     * @return Returns map with requested group setting values for given submodule id.
     * 
     * @example Map<String, String> groupSettingMap = COMM_CreateServerCache.getInstance().getGroupSettingValues('SFM002','SET001');
     */
    public Map<String, String> getGroupSettingValues( final String submoduleId, final String settingId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getGroupSettingValues() - enter; submoduleId= ' + submoduleId + '; settingId= ' + settingId );
        
        final Map<String, String> selectedSettingsMap = new Map<String, String>();
        
        try {
            // Retrieve group settings from Platform Cache.
            final Map<String, String> groupSettingsMap = getGroupSettingValues(submoduleId);
            
            if( groupSettingsMap.containsKey(settingId) ) {
                selectedSettingsMap.put( settingId, groupSettingsMap.get(settingId) );
            } else {
                System.debug( LoggingLevel.ERROR, 'getGroupSettingValues(): Setting id ' + settingId + ' not exists in submodule ' + submoduleId );
            }
        }
        catch( Cache.Org.OrgCacheException e ) {
            System.debug( LoggingLevel.ERROR, 'getGroupSettingValues(): Failed to retrieve group settings from Platform Cache; ' + e.getMessage() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getGroupSettingValues() - exit');
        }
        
        return selectedSettingsMap;
    }
    
    /**
     * This method is used to retrieve all group setting values for given list of submodules. This will make sure to 
     * retrieve values from the Platform Cache if exists.
     * 
     * @return Returns map with all group setting values for given list of submodule ids.
     * 
     * @example Map<String, Map<String, String>> groupSettingMap = COMM_CreateServerCache.getInstance().getGroupSettingValues( new List<String>{'GLOB001', 'GLOB002'});
     */
    public Map<String, Map<String, String>> getGroupSettingValues( final List<String> submoduleIdList ) {
        
        System.debug( LoggingLevel.DEBUG, 'getGroupSettingValues() - enter; submoduleIdList= ' + submoduleIdList.size());
        
        final Map<String, Map<String, String>> settingValuesMap = new Map<String, Map<String, String>>();
        
        try {
            // Check whether the settings for submodules are cached or not. If cached, then add the setting values 
            // to result setting values map.
            // TODO Need to avoid calling cache method in loop.
            for( String submoduleId : submoduleIdList ) {
                settingValuesMap.put( submoduleId, getGroupSettingValues(submoduleId) );
            }
        }
        catch( Cache.Org.OrgCacheException e ) {
            System.debug( LoggingLevel.ERROR, 'getGroupSettingValues(): Failed to retrieve group settings from Platform Cache; ' + e.getMessage() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getGroupSettingValues() - exit');
        }
        
        return settingValuesMap;
    }
    
    /**
     * This method is used to clear all group settings from Platform Cache.
     */
    public void clearAllGroupSettingCache() {
        
        System.debug( LoggingLevel.DEBUG, 'clearAllGroupSettingCache() - enter');
        
        try {
            
            if( OrgPartition != null ) {
                
                for( String cacheKey : OrgPartition.getKeys() ) {
                
                    if( cacheKey.containsIgnoreCase('GroupSettingsCache') ) {
                        if( !OrgPartition.remove(COMM_PlatformCacheBuilder.GroupSettingsCache.class, cacheKey.substring('GroupSettingsCache_B_'.length() ) ) ) {
                            System.debug( LoggingLevel.WARN, 'clearAllGroupSettingCache(): Failed to clear platform cache. cacheKey=' + cacheKey );
                        }
                    }
                }
            }
        }
        catch( Cache.Org.OrgCacheException e ) {
            System.debug( LoggingLevel.ERROR, 'clearAllGroupSettingCache(): Failed to clear a;; group settings cache' + e.getMessage() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'clearAllGroupSettingCache() - exit');
        }
    }
    
    /**
     * This method is used to clear Platform Cache for given submodule Id.
     * 
     * @param submoduleId Submodule id for which group setting cache to be cleared.
     */
    public void clearGroupSettingCache( final String submoduleId ) {
        
        System.debug( LoggingLevel.DEBUG, 'clearGroupSettingCache() - enter; submoduleId= ' + submoduleId);
        try {
            clearGroupSettingCache(submoduleId, false);
        }
        catch( Cache.Org.OrgCacheException e ) {
            System.debug( LoggingLevel.ERROR, 'clearGroupSettingCache(): Failed to clear group settings cache' + e.getMessage() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'clearGroupSettingCache() - exit');
        }
    }
    
    /**
     * This method is used to clear Platform Cache for given submodule Id.
     * 
     * @param submoduleId Submodule id for which group setting cache to be cleared.
     */
    public void clearGroupSettingCache( final String submoduleId, final Boolean allProfiles ) {
        
        System.debug( LoggingLevel.DEBUG, 'clearGroupSettingCache() - enter; submoduleId= ' + submoduleId + '; allProfiles=' + allProfiles );
        try {
            if( OrgPartition != null ) {
                
                if( submoduleId != null && submoduleId.trim().length() != 0 ) {
               
                    if( allProfiles ) {
                        
                        for( String cacheKey : OrgPartition.getKeys() ) {
                            
                            if( cacheKey.containsIgnoreCase('GroupSettingsCache') && cacheKey.containsIgnoreCase( convertFromHex(submoduleId) ) ) {
                                
                                if( !OrgPartition.remove(COMM_PlatformCacheBuilder.GroupSettingsCache.class, cacheKey.substring('GroupSettingsCache_B_'.length() ) ) ) {
                                    System.debug( LoggingLevel.WARN, 'clearGroupSettingCache(): Failed to clear platform cache. cacheKey=' + cacheKey );
                                }
                            } 
                        }
                    } else if( !OrgPartition.remove( COMM_PlatformCacheBuilder.GroupSettingsCache.class, buildGroupSettingKey(submoduleId) ) ) {
                        System.debug( LoggingLevel.WARN, 'clearGroupSettingCache(): Failed to clear group setting cache. submoduleId=' + submoduleId );
                    }
                } else {
                    System.debug( LoggingLevel.ERROR, 'clearGroupSettingCache(): Invalid argument. submoduleId=' + submoduleId );
                }
            }
        }
        catch( Cache.Org.OrgCacheException e ) {
            System.debug( LoggingLevel.ERROR, 'clearGroupSettingCache(): Failed to clear global settings cache' + e.getMessage() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'clearGroupSettingCache() - exit');
        }
    }
    
    /**
     * This method is used to retrieve the global describe. This will make sure to retrieve 
     * values from the Platform Cache if exists.
     * 
     * @param objectName Object API name for which describe result to be retrieved.
     * @return Returns instance of DescribeSObjectResult for given object name.
     * 
     * @example Map<String, Schema.SObjectType> globalDescribeMap = COMM_CreateServerCache.getInstance().getGlobalDescribeCache();
     */
    public Map<String, Schema.SObjectType> getGlobalDescribeCache() {
        
        System.debug( LoggingLevel.DEBUG, 'getGlobalDescribeCache() - enter');
        
        Map<String, Schema.SObjectType> globalDescribeMap = new Map<String, Schema.SObjectType>();
        
        try {
            if( OrgPartition != null && isPlatformCacheEnabled ) {
                globalDescribeMap = (Map<String, SObjectType>) OrgPartition.get(COMM_PlatformCacheBuilder.GlobalDescribeCache.class, GLOBAL_DESCRIBE );
            } else {
                
                System.debug( LoggingLevel.WARN, 'getGlobalDescribeCache(): Plarform Cache not enabled or failed to initialize.' );
                globalDescribeMap = Schema.getGlobalDescribe();
            }
        }
        catch( Cache.Org.OrgCacheException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getGlobalDescribeCache(): Failed to retrieve object describe from Platform Cache; ' + e.getMessage() );
            globalDescribeMap = Schema.getGlobalDescribe();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getGlobalDescribeCache() - exit');
        }
        
        return globalDescribeMap;
    }
    
    /**
     * This method is used to clear Platform Cache for global describe.
     */
    public void clearGlobalDescribeCache() {
        
        System.debug( LoggingLevel.DEBUG, 'clearGlobalDescribeCache() - enter');
        try { 
            if( OrgPartition != null && !OrgPartition.remove( COMM_PlatformCacheBuilder.GlobalDescribeCache.class, GLOBAL_DESCRIBE ) ) {
                System.debug( LoggingLevel.WARN, 'clearGlobalDescribeCache(): Failed to clear global describe cache' );
            }
        }
        catch( Cache.Org.OrgCacheException e ) {
            System.debug( LoggingLevel.ERROR, 'clearGlobalDescribeCache(): Failed to clear global describe cache' + e.getMessage() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'clearGlobalDescribeCache() - exit');
        }
    }
    
    /**
     * This method is used to retrieve object describe result for given object name. This will make sure to retrieve 
     * values from the Platform Cache if exists.
     * 
     * @param objectName Object API name for which describe result to be retrieved.
     * @return Returns instance of DescribeSObjectResult for given object name.
     * 
     * @example Map<String, Schema.SObjectField> objectDescribeMap = COMM_CreateServerCache.getInstance().getObjectDescribeCache('SVMXC__Service_Order__c');
     */
    public Map<String, Schema.SObjectField> getObjectDescribeCache( final String objectName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getObjectDescribeCache() - enter; objectName= ' + objectName);
        
        Map<String, Schema.SObjectField> objectDescribeMap = new Map<String, Schema.SObjectField>();
        
        try {
            
            if( objectName != null && objectName.trim().length() != 0 ) {
                    
                Map<String, Schema.SObjectType> globalDescribeMap = getGlobalDescribeCache();
               
                if( globalDescribeMap.containsKey(objectName) ) {
                    
                    if( OrgPartition != null && isPlatformCacheEnabled ) {
                        
                        // Retrieve object describe from Platform Cache.
                    	objectDescribeMap = (Map<String, Schema.SObjectField>) OrgPartition.get(COMM_PlatformCacheBuilder.ObjectDescribeCache.class, buildObjectNameKey(objectName) );
                    } else {
                        
                        System.debug( LoggingLevel.WARN, 'getObjectDescribeCache(): Plarform Cache not enabled or failed to initialize.' );
                        objectDescribeMap = Schema.getGlobalDescribe().get(objectName).getDescribe().Fields.getMap();
                    }
                } else {
                    System.debug( LoggingLevel.ERROR, 'getObjectDescribeCache(): Object not exists. objectName=' + objectName );
                }
               
            } else {
                System.debug( LoggingLevel.ERROR, 'getObjectDescribeCache(): Invalid argument. objectName=' + objectName );
            }
        }
        catch( Cache.Org.OrgCacheException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectDescribeCache(): Failed to retrieve object describe from Platform Cache; ' + e.getMessage() );
            objectDescribeMap = Schema.getGlobalDescribe().get(objectName).getDescribe().Fields.getMap();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectDescribeCache() - exit');
        }
         
        return objectDescribeMap;
    }
    
    /**
     * This method is used to clear object describe Platform Cache for given object name.
     * 
     * @param objectName Object name for which Platform Cache to be cleared.
     */
    public void clearObjectDescribeCache( final String objectName ) {
        
        System.debug( LoggingLevel.DEBUG, 'clearObjectDescribeCache() - enter; objectName= ' + objectName);
        try {
            if( objectName != null && objectName.trim().length() != 0 ) {
                
                if( OrgPartition != null && !OrgPartition.remove( COMM_PlatformCacheBuilder.ObjectDescribeCache.class, buildObjectNameKey(objectName) ) ) {
                    System.debug( LoggingLevel.WARN, 'clearObjectDescribeCache(): Failed to clear object describe cache. objectName=' + objectName );
                }
            } else {
                System.debug( LoggingLevel.ERROR, 'clearObjectDescribeCache(): Invalid argument. objectName=' + objectName );
            }
        }
        catch( Cache.Org.OrgCacheException e ) {
            System.debug( LoggingLevel.ERROR, 'clearObjectDescribeCache(): Failed to clear object describe cache' + e.getMessage() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'clearObjectDescribeCache() - exit');
        }
    }
    
    /**
     * This method is used to retrieve Target Manager record informations with list of Process Node Objects for given process ID. 
     * This will make sure to retrieve values from the Platform Cache if exists.
     * 
     * @param processId Object API name for which all record type id to be retrieved.
     * @return Returns record type name vs id map.
     * 
     * @example Map<SObject,List<SObject>> transactionManagerMap = COMM_CreateServerCache.getInstance().getTargetManagerCache(processId);
     */
    public Map<SObject,List<SObject>> getTargetManagerCache( final String processId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getTargetManagerCache() - enter; processId= ' + processId);
        
        Map<SObject,List<SObject>> transactionManagerMap = new Map<SObject,List<SObject>>();
        
        try {
            
            if( processId != null && processId.trim().length() != 0 ) {
                
                if( OrgPartition != null && isPlatformCacheEnabled ) {
                    
                    // Retrieve object describe from Platform Cache.
                    transactionManagerMap = (Map<SObject,List<SObject>>) OrgPartition.get(COMM_PlatformCacheBuilder.TransactionManagerCache.class, processId );
                } else {
                    
                    System.debug( LoggingLevel.WARN, 'getTargetManagerCache(): Plarform Cache not enabled or failed to initialize.' );
                    transactionManagerMap = COMM_CreateServerCache.getTargetManagerInfo(processId);
                }
            } else {
                System.debug( LoggingLevel.ERROR, 'getTargetManagerCache(): Invalid argument. processId=' + processId );
            }
        }
        catch( Cache.Org.OrgCacheException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getTargetManagerCache(): Failed to retrieve record type id from Platform Cache; ' + e.getMessage() );
            transactionManagerMap = COMM_CreateServerCache.getTargetManagerInfo(processId);
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getTargetManagerCache() - exit');
        }
         
        return transactionManagerMap;
    }
    
    /**
     * This method is used to clear target manager from Platform Cache for given process id.
     * 
     * @param processId process id for which Platform Cache to be cleared.
     */
    public void clearTargetManagerCache( final String processId ) {
        
        System.debug( LoggingLevel.DEBUG, 'clearTargetManagerCache() - enter; processId= ' + processId);
        try {
            if( processId != null && processId.trim().length() != 0 ) {
                
                if( OrgPartition != null && !OrgPartition.remove( COMM_PlatformCacheBuilder.TransactionManagerCache.class, processId ) ) {
                    System.debug( LoggingLevel.WARN, 'clearTargetManagerCache(): Failed to clear target manager cache. processId=' + processId );
                }
            } else {
                System.debug( LoggingLevel.ERROR, 'clearTargetManagerCache(): Invalid argument. processId=' + processId );
            }
        }
        catch( Cache.Org.OrgCacheException e ) {
            System.debug( LoggingLevel.ERROR, 'clearTargetManagerCache(): Failed to clear target manager cache' + e.getMessage() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'clearTargetManagerCache() - exit');
        }
    }
    
    /**
     * This method is used to retrieve field mapping information for given mapping ID. 
     * This will make sure to retrieve values from the Platform Cache if exists.
     * 
     * @param mapId map id for which field mapping informations to be retrieved.
     * @return Returns map of header and list of details.
     * 
     * @example Map<SObject,List<SObject>> fieldMappingDetailMap = COMM_CreateServerCache.getInstance().getFieldMappingCache(mapId);
     */
    public Map<SObject,List<SObject>> getFieldMappingCache( final String mapId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getFieldMappingCache() - enter; mapId= ' + mapId);
        
        Map<SObject,List<SObject>> fieldMappingDetailMap = new Map<SObject,List<SObject>>();
        
        try {
            
            if( mapId != null && mapId.trim().length() != 0 ) {
                
                if( OrgPartition != null && isPlatformCacheEnabled ) {
                    
                    // Retrieve object describe from Platform Cache.
                    fieldMappingDetailMap = (Map<SObject,List<SObject>>) OrgPartition.get(COMM_PlatformCacheBuilder.FieldMappingCache.class, mapId );
                } else {
                    
                    System.debug( LoggingLevel.WARN, 'getFieldMappingCache(): Plarform Cache not enabled or failed to initialize.' );
                    fieldMappingDetailMap = COMM_CreateServerCache.getFieldMappingDetail(mapId);
                }
            } else {
                System.debug( LoggingLevel.ERROR, 'getFieldMappingCache(): Invalid argument. mapId=' + mapId );
            }
        }
        catch( Cache.Org.OrgCacheException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldMappingCache(): Failed to retrieve field mapping from Platform Cache; ' + e.getMessage() );
            fieldMappingDetailMap = COMM_CreateServerCache.getFieldMappingDetail(mapId);
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFieldMappingCache() - exit');
        }
         
        return fieldMappingDetailMap;
    }
    
    /**
     * This method is used to clear field mapping from Platform Cache for given map id.
     * 
     * @param mapId map id for which Platform Cache to be cleared.
     */
    public void clearFieldMappingCache( final String mapId ) {
        
        System.debug( LoggingLevel.DEBUG, 'clearTargetManagerCache() - enter; mapId= ' + mapId);
        try {
            if( mapId != null && mapId.trim().length() != 0 ) {
                
                if( OrgPartition != null && !OrgPartition.remove( COMM_PlatformCacheBuilder.FieldMappingCache.class, mapId ) ) {
                    System.debug( LoggingLevel.WARN, 'clearTargetManagerCache(): Failed to clear field mapping cache. mapId=' + mapId );
                }
            } else {
                System.debug( LoggingLevel.ERROR, 'clearTargetManagerCache(): Invalid argument. mapId=' + mapId );
            }
        }
        catch( Cache.Org.OrgCacheException e ) {
            System.debug( LoggingLevel.ERROR, 'clearTargetManagerCache(): Failed to clear field mapping cache' + e.getMessage() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'clearTargetManagerCache() - exit');
        }
    }
    
    /**
     * This method is used to retrieve names expression details for given expression ID. 
     * This will make sure to retrieve values from the Platform Cache if exists.
     * 
     * @param expressionId expression id for which names expression details to be retrieved.
     * @return Returns map of header and list of details.
     * 
     * @example Map<SObject,List<SObject>> expressionDetailMap = COMM_CreateServerCache.getInstance().getNamedExpressionCache(expressionId);
     */
    public Map<SObject,List<SObject>> getNamedExpressionCache( final String expressionId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getNamedExpressionCache() - enter; expressionId= ' + expressionId);
        
        Map<SObject,List<SObject>> expressionDetailMap = new Map<SObject,List<SObject>>();
        
        try {
            
            if( expressionId != null && expressionId.trim().length() != 0 ) {
                
                if( OrgPartition != null && isPlatformCacheEnabled ) {
                    
                    // Retrieve object describe from Platform Cache.
                    expressionDetailMap = (Map<SObject,List<SObject>>) OrgPartition.get(COMM_PlatformCacheBuilder.NamedExpressionCache.class, expressionId );
                } else {
                    
                    System.debug( LoggingLevel.WARN, 'getFieldMappingCache(): Plarform Cache not enabled or failed to initialize.' );
                    expressionDetailMap = COMM_CreateServerCache.getExpressionDetails(expressionId);
                }
            } else {
                System.debug( LoggingLevel.ERROR, 'getFieldMappingCache(): Invalid argument. expressionId=' + expressionId );
            }
        }
        catch( Cache.Org.OrgCacheException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldMappingCache(): Failed to retrieve field mapping from Platform Cache; ' + e.getMessage() );
            expressionDetailMap = COMM_CreateServerCache.getExpressionDetails(expressionId);
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFieldMappingCache() - exit');
        }
         
        return expressionDetailMap;
    }
    
    /**
     * This method is used to clear field mapping from Platform Cache for given map id.
     * 
     * @param expressionId expression id for which Platform Cache to be cleared.
     */
    public void clearNamedExpressionCache( final String expressionId ) {
        
        System.debug( LoggingLevel.DEBUG, 'clearNamedExpressionCache() - enter; expressionId= ' + expressionId);
        try {
            if( expressionId != null && expressionId.trim().length() != 0 ) {
                
                if( OrgPartition != null && !OrgPartition.remove( COMM_PlatformCacheBuilder.NamedExpressionCache.class, expressionId ) ) {
                    System.debug( LoggingLevel.WARN, 'clearNamedExpressionCache(): Failed to clear field mapping cache. expressionId=' + expressionId );
                }
            } else {
                System.debug( LoggingLevel.ERROR, 'clearNamedExpressionCache(): Invalid argument. expressionId=' + expressionId );
            }
        }
        catch( Cache.Org.OrgCacheException e ) {
            System.debug( LoggingLevel.ERROR, 'clearNamedExpressionCache(): Failed to clear names expression cache' + e.getMessage() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'clearNamedExpressionCache() - exit');
        }
    }
    
    /**
     * This method is used to retrieve record types for given object name. This will make sure to retrieve 
     * values from the Platform Cache if exists.
     * 
     * @param objectName Object API name for which all record type id to be retrieved.
     * @return Returns record type name vs id map.
     * 
     * @example Map<String, Id> objectDescribeMap = COMM_CreateServerCache.getInstance().getObjectRecordTypeCache('SVMXC__Service_Order__c');
     */
    public Map<String, Id> getObjectRecordTypeCache( final String objectName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getObjectRecordTypeCache() - enter; objectName= ' + objectName);
        
        Map<String, Id> objectRecordTypeIdMap = new Map<String, Id>();
        
        try {
            
            if( objectName != null && objectName.trim().length() != 0 ) {
                    
                Map<String, Schema.SObjectType> globalDescribeMap = getGlobalDescribeCache();
               
                if( globalDescribeMap.containsKey(objectName) ) {
                    
                    if( OrgPartition != null && isPlatformCacheEnabled ) {
                        
                        // Retrieve object describe from Platform Cache.
                    	objectRecordTypeIdMap = (Map<String, Id>) OrgPartition.get( COMM_PlatformCacheBuilder.ObjectRecordTypeIdCache.class, buildObjectNameKey(objectName) );
                    } else {
                        
                        System.debug( LoggingLevel.WARN, 'getObjectRecordTypeCache(): Plarform Cache not enabled or failed to initialize.' );
                        objectRecordTypeIdMap = COMM_RecordTypeUtilities.getObjectRecordTypeId(EncodingUtil.convertFromHex(objectName).toString());
                    }
                } else {
                    System.debug( LoggingLevel.ERROR, 'getObjectRecordTypeCache(): Object not exists. objectName=' + objectName );
                }
               
            } else {
                System.debug( LoggingLevel.ERROR, 'getObjectRecordTypeCache(): Invalid argument. objectName=' + objectName );
            }
        }
        catch( Cache.Org.OrgCacheException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectRecordTypeCache(): Failed to retrieve record type id from Platform Cache; ' + e.getMessage() );
            objectRecordTypeIdMap = COMM_RecordTypeUtilities.getObjectRecordTypeId(EncodingUtil.convertFromHex(objectName).toString());
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectRecordTypeCache() - exit');
        }
         
        return objectRecordTypeIdMap;
    }
    
    /**
     * This method is used to retrieve record types for given object name and list of record type names. 
     * This will make sure to retrieve values from the Platform Cache if exists.
     * 
     * @param objectName Object API name for which all record type id to be retrieved.
     * @param recordTypeNameList List of record type for which id to be retrieved.
     * @return Returns record type name vs id map.
     * 
	 * @example Map<String, Id> objectDescribeMap = COMM_CreateServerCache.getInstance().getObjectRecordTypeCache('SVMXC__Service_Order__c', new List<String>({'Field_Mapping','Settings'}));
     */
    public Map<String, Id> getObjectRecordTypeCache( final String objectName, List<String> recordTypeNameList ) {
        
        System.debug( LoggingLevel.DEBUG, 'getObjectRecordTypeCache() - enter; objectName= ' + objectName);
        
        Map<String, Id> objectRecordTypeIdMap = new Map<String, Id>();
        
        try {
            
            if( objectName != null && objectName.trim().length() != 0 ) {
                    
                Map<String, Schema.SObjectType> globalDescribeMap = getGlobalDescribeCache();
               
                if( globalDescribeMap.containsKey(objectName) ) {
                    
                    Map<String, Id> objectAllRecordTypeIdMap = getObjectRecordTypeCache(objectName);
                    for( String recordTypeName: recordTypeNameList ) {
                        
                        if( objectAllRecordTypeIdMap.containsKey(recordTypeName) ) {
                            objectRecordTypeIdMap.put( recordTypeName, objectAllRecordTypeIdMap.get(recordTypeName) );
                        } else {
                            System.debug( LoggingLevel.ERROR, 'getObjectRecordTypeCache(): Recort type name does not exists. RecortTypeName=' + recordTypeName );
                        }
                    }
                } else {
                    System.debug( LoggingLevel.ERROR, 'getObjectRecordTypeCache(): Object not exists. objectName=' + objectName );
                }
               
            } else {
                System.debug( LoggingLevel.ERROR, 'getObjectRecordTypeCache(): Invalid argument. objectName=' + objectName );
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectRecordTypeCache(): Failed to retrieve record type id from Platform Cache; ' + e.getMessage() );
            objectRecordTypeIdMap = COMM_RecordTypeUtilities.getObjectRecordTypeId(EncodingUtil.convertFromHex(objectName).toString());
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectRecordTypeCache() - exit');
        }
         
        return objectRecordTypeIdMap;
    }
    
    /**
     * This method is used to retrieve record types for given object name and record type names. 
     * This will make sure to retrieve values from the Platform Cache if exists.
     * 
     * @param objectName Object API name for which all record type id to be retrieved.
     * @param recordTypeNameList List of record type for which id to be retrieved.
     * @return Returns record type name vs id map.
     * 
     * @example Map<String, Id> objectDescribeMap = COMM_CreateServerCache.getInstance().getObjectRecordTypeCache('SVMXC__Service_Order__c', 'Field_Mapping)
     */
    public Id getObjectRecordTypeCache( final String objectName, String recordTypeName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getObjectRecordTypeCache() - enter; objectName= ' + objectName);
        
        Id recordTypeId;
        
        try {
            
            if( objectName != null && objectName.trim().length() != 0 ) {
                    
                Map<String, Schema.SObjectType> globalDescribeMap = getGlobalDescribeCache();
               
                if( globalDescribeMap.containsKey(objectName) ) {
                    
                    Map<String, Id> objectAllRecordTypeIdMap = getObjectRecordTypeCache(objectName);
                        
                    if( objectAllRecordTypeIdMap.containsKey(recordTypeName) ) {
                        recordTypeId = objectAllRecordTypeIdMap.get(recordTypeName);
                    } else {
                        System.debug( LoggingLevel.ERROR, 'getObjectRecordTypeCache(): Recort type name does not exists. RecortTypeName=' + recordTypeName );
                    }
                } else {
                    System.debug( LoggingLevel.ERROR, 'getObjectRecordTypeCache(): Object not exists. objectName=' + objectName );
                }
               
            } else {
                System.debug( LoggingLevel.ERROR, 'getObjectRecordTypeCache(): Invalid argument. objectName=' + objectName );
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectRecordTypeCache(): Failed to retrieve record type id from Platform Cache; ' + e.getMessage() );
            recordTypeId = COMM_RecordTypeUtilities.getObjectRecordTypeId(EncodingUtil.convertFromHex(objectName).toString() ).get(recordTypeName);
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectRecordTypeCache() - exit');
        }
         
        return recordTypeId;
    }
    
    /**
     * This method is used to clear record type id Platform Cache for given object name.
     * 
     * @param objectName Object name for which Platform Cache to be cleared.
     */
    public void clearObjectRecordTypeIdCache( final String objectName ) {
        
        System.debug( LoggingLevel.DEBUG, 'clearObjectRecordTypeIdCache() - enter; objectName= ' + objectName);
        try {
            if( objectName != null && objectName.trim().length() != 0 ) {
                
                if( OrgPartition != null && !OrgPartition.remove( COMM_PlatformCacheBuilder.ObjectRecordTypeIdCache.class, buildObjectNameKey(objectName) ) ) {
                    System.debug( LoggingLevel.WARN, 'clearObjectRecordTypeIdCache(): Failed to clear object describe cache. objectName=' + objectName );
                }
            } else {
                System.debug( LoggingLevel.ERROR, 'clearObjectRecordTypeIdCache(): Invalid argument. objectName=' + objectName );
            }
        }
        catch( Cache.Org.OrgCacheException e ) {
            System.debug( LoggingLevel.ERROR, 'clearObjectRecordTypeIdCache(): Failed to clear object describe cache' + e.getMessage() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'clearObjectRecordTypeIdCache() - exit');
        }
    }
    
    /**
     * This method is used to clear all Platform Cache from the partition.
     */
    public void clearAllPlatformCache() {
        
        System.debug( LoggingLevel.DEBUG, 'clearAllPlatformCache() - enter;' );
        try {
            if( OrgPartition != null ) {
                
                for( String cacheKey : OrgPartition.getKeys() ) {
                
                    if( cacheKey.containsIgnoreCase('ConfigurationProfileCache') ) {
                        if( !OrgPartition.remove(COMM_PlatformCacheBuilder.ConfigurationProfileCache.class, cacheKey.substring('ConfigurationProfileCache_B_'.length() ) ) ) {
                            System.debug( LoggingLevel.WARN, 'clearAllPlatformCache(): Failed to clear platform cache. cacheKey=' + cacheKey );
                        }
                    } else if( cacheKey.containsIgnoreCase('GroupSettingsCache') ) {
                        if( !OrgPartition.remove(COMM_PlatformCacheBuilder.GroupSettingsCache.class, cacheKey.substring('GroupSettingsCache_B_'.length() ) ) ) {
                            System.debug( LoggingLevel.WARN, 'clearAllPlatformCache(): Failed to clear platform cache. cacheKey=' + cacheKey );
                        }
                    } else if( cacheKey.containsIgnoreCase('ObjectDescribeCache') ) {
                        if( !OrgPartition.remove(COMM_PlatformCacheBuilder.ObjectDescribeCache.class, cacheKey.substring('ObjectDescribeCache_B_'.length() ) ) ) {
                            System.debug( LoggingLevel.WARN, 'clearAllPlatformCache(): Failed to clear platform cache. cacheKey=' + cacheKey );
                        }
                    } else if( cacheKey.containsIgnoreCase('ObjectRecordTypeIdCache') ) {
                        if( !OrgPartition.remove(COMM_PlatformCacheBuilder.ObjectRecordTypeIdCache.class, cacheKey.substring('ObjectRecordTypeIdCache_B_'.length() ) ) ) {
                            System.debug( LoggingLevel.WARN, 'clearAllPlatformCache(): Failed to clear platform cache. cacheKey=' + cacheKey );
                        }
                    } else if( cacheKey.containsIgnoreCase('FieldMappingCache') ) {
                        if( !OrgPartition.remove(COMM_PlatformCacheBuilder.ObjectRecordTypeIdCache.class, cacheKey.substring('FieldMappingCache_B_'.length() ) ) ) {
                            System.debug( LoggingLevel.WARN, 'clearAllPlatformCache(): Failed to clear platform cache. cacheKey=' + cacheKey );
                        }
                    } else if( cacheKey.containsIgnoreCase('TransactionManagerCache') ) {
                        if( !OrgPartition.remove(COMM_PlatformCacheBuilder.ObjectRecordTypeIdCache.class, cacheKey.substring('TransactionManagerCache_B_'.length() ) ) ) {
                            System.debug( LoggingLevel.WARN, 'clearAllPlatformCache(): Failed to clear platform cache. cacheKey=' + cacheKey );
                        }
                    } else if( cacheKey.containsIgnoreCase('NamedExpressionCache') ) {
                        if( !OrgPartition.remove(COMM_PlatformCacheBuilder.ObjectRecordTypeIdCache.class, cacheKey.substring('NamedExpressionCache_B_'.length() ) ) ) {
                            System.debug( LoggingLevel.WARN, 'clearAllPlatformCache(): Failed to clear platform cache. cacheKey=' + cacheKey );
                        }
                    }
                }
                clearGlobalSettingCache();
                clearGlobalDescribeCache();
                clearServiceMaxPropertiesCache();
            }
        }
        catch( Cache.Org.OrgCacheException e ) {
            System.debug( LoggingLevel.ERROR, 'clearAllPlatformCache(): Failed to clear all platform cache' + e.getMessage() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'clearAllPlatformCache() - exit');
        }
    }
    
    /**
     * This method is used to clear all Profile Cache from the partition.
     */
    public void clearAllProfileCache() {
        
        System.debug( LoggingLevel.DEBUG, 'clearAllPlatformCache() - enter;' );
        try {
            if( OrgPartition != null ) {
                
                for( String cacheKey : OrgPartition.getKeys() ) {
                
                    if( cacheKey.containsIgnoreCase('ConfigurationProfileCache') ) {
                        if( !OrgPartition.remove(COMM_PlatformCacheBuilder.ConfigurationProfileCache.class, cacheKey.substring('ConfigurationProfileCache_B_'.length() ) ) ) {
                            System.debug( LoggingLevel.WARN, 'clearAllProfileCache(): Failed to clear profile cache. cacheKey=' + cacheKey );
                        }
                    }
                }
            }
        }
        catch( Cache.Org.OrgCacheException e ) {
            System.debug( LoggingLevel.ERROR, 'clearAllPlatformCache(): Failed to clear all platform cache' + e.getMessage() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'clearAllPlatformCache() - exit');
        }
    }
    
    /**
     * This method is used to clear all Group Setting Cache from the partition.
     */
    public void clearAllGroupSettingsCache() {
        
        System.debug( LoggingLevel.DEBUG, 'clearAllGroupSettingsCache() - enter;' );
        try {
            if( OrgPartition != null ) {
                
                for( String cacheKey : OrgPartition.getKeys() ) {
                
                   if( cacheKey.containsIgnoreCase('GroupSettingsCache') ) {
                       if( !OrgPartition.remove(COMM_PlatformCacheBuilder.GroupSettingsCache.class, cacheKey.substring('GroupSettingsCache_B_'.length() ) ) ) {
                           System.debug( LoggingLevel.WARN, 'clearAllGroupSettingsCache(): Failed to clear platform cache. cacheKey=' + cacheKey );
                       }
                   } 
                }
            }
        }
        catch( Cache.Org.OrgCacheException e ) {
            System.debug( LoggingLevel.ERROR, 'clearAllGroupSettingsCache(): Failed to clear all platform cache' + e.getMessage() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'clearAllGroupSettingsCache() - exit');
        }
    }
    
    /**
     * This method is used to clear all Object Describe Cache from the partition.
     */
    public void clearAllObjectDescribeCache() {
        
        System.debug( LoggingLevel.DEBUG, 'clearAllObjectDescribeCache() - enter;' );
        try {
            if( OrgPartition != null ) {
                
                for( String cacheKey : OrgPartition.getKeys() ) {
                
                    if( cacheKey.containsIgnoreCase('ObjectDescribeCache') ) {
                        if( !OrgPartition.remove(COMM_PlatformCacheBuilder.ObjectDescribeCache.class, cacheKey.substring('ObjectDescribeCache_B_'.length() ) ) ) {
                            System.debug( LoggingLevel.WARN, 'clearAllObjectDescribeCache(): Failed to clear platform cache. cacheKey=' + cacheKey );
                        }
                    }
                }
            }
        }
        catch( Cache.Org.OrgCacheException e ) {
            System.debug( LoggingLevel.ERROR, 'clearAllObjectDescribeCache(): Failed to clear all platform cache' + e.getMessage() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'clearAllObjectDescribeCache() - exit');
        }
    }
    
    /**
     * This method is used to clear servicemax properties cache.
     */
    public void clearServiceMaxPropertiesCache() {
        
        System.debug( LoggingLevel.DEBUG, 'clearServiceMaxPropertiesCache() - enter');
        
        try {
            Cache.Org.remove(CACHE_PROPERTY_LIST);
        }
        catch( Cache.Org.OrgCacheException e ) {
            System.debug( LoggingLevel.ERROR, 'clearServiceMaxPropertiesCache(): Failed to clear Servicemax Properties cache' + e.getMessage() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'clearServiceMaxPropertiesCache() - exit');
        }
    }
    
    /**
     * This method is used to initialize Platform cache configurations to instance variables 
     * and cache the valuse.
     */
    /*private void initServicemaxProperties() {
        
        System.debug( LoggingLevel.DEBUG, 'initServicemaxProperties() - enter');
        
        try {
            if( !Cache.Org.contains('SVMXC.ServicemaxPartition.PC001') ) {
                
                for( SVMXC__ServiceMax_Properties__c property : [Select Name, SVMXC__Key__c, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where Name in :CACHE_PROPERTY_LIST ] ) {
                    
                    if( property.SVMXC__Value__c != null ) {
                        Cache.Org.put('SVMXC.ServicemaxPartition.' + property.Name, property.SVMXC__Value__c, Cache.Org.MAX_TTL_SECS );
                    }
                }
            }
                
            isPlatformCacheEnabled = Boolean.valueOf( Cache.Org.get('SVMXC.ServicemaxPartition.PC001') );
        }
        catch( Cache.Org.OrgCacheException e ) {
            System.debug( LoggingLevel.ERROR, 'initServicemaxProperties() : Failed to initialize servicemax properties.Error: ' + e.getMessage());
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'initServicemaxProperties() - exit');
        }
    }*/
    
    public Cache.OrgPartition getOrgPartition() {
        return OrgPartition;
    }
    
    /**
     * Private constructor to create instance of this class.
     */
    private COMM_CreateServerCache() {
        
        System.debug( LoggingLevel.DEBUG, 'COMM_CreateServerCache() - enter');
        
        try {
            init();
            if( isPlatformCacheEnabled ) {
                OrgPartition = Cache.Org.getPartition(partitionName);
            }
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'COMM_CreateServerCache() : Failed to retrieve Platform Cache Partition.Error: ' + e.getMessage());
        } 
        finally {
            System.debug( LoggingLevel.DEBUG, 'COMM_CreateServerCache() - exit');
        }
    }
    
    /**
     * Private method to initialize Platform cache configurations.
     */
    private void init() {
        
        System.debug( LoggingLevel.DEBUG, 'init() - enter');
        
        try {
            
            final SVMXC__ServiceMax_Properties__c pc001Record = [Select Name, SVMXC__Key__c, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where Name ='PC001' LIMIT 1 ];
            if( pc001Record != null ) {
                
                isPlatformCacheEnabled = Boolean.valueOf( pc001Record.SVMXC__Value__c );
                /*if( isPlatformCacheEnabled ) {
                    initServicemaxProperties();
                }*/
            } else {
                System.debug( LoggingLevel.WARN, 'init() : Servicemax Properties for Platform Cache not exists.' );
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'init() : Failed to initialize Platform Cache. Error: ' + e.getMessage() );
            isPlatformCacheEnabled = false;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'init() - exit');
        }
    }
    
    /**
     * This method is used to build Platform Cache key for group settings
     */
    private String buildGroupSettingKey( final String submoduleId ) {
        
        final String svmxProfileId = (String) OrgPartition.get(COMM_PlatformCacheBuilder.ConfigurationProfileCache.class, UserInfo.getProfileId() );
        return svmxProfileId + convertToHex( submoduleId );
    }
    
    /**
     * This method is used to build Platform Cache key for object describe
     */
    private String buildObjectNameKey( final String objectName ) {
        return convertToHex( objectName );
    }
    
    /**
     * This method is used to convert string to Hex string
     */
    private String convertToHex( String value ) {
        return EncodingUtil.convertToHex( blob.valueof(value) );
    }
    
    /**
     * This method is used to convert Hex String to String
     */
    private String convertFromHex( String value ) {
        return EncodingUtil.convertFromHex(value).toString();
    }
    
    /************************************
     * Methods to be moved to utility classes.
     */
    public static Map<SObject,List<SObject>> getTargetManagerInfo( String processId ){
        
        System.debug( LoggingLevel.DEBUG, 'getTargetManagerInfo() - enter; processId=' + processId );
        
        Map<SObject,List<SObject>> transactionManagerMap = new Map<SObject,List<SObject>>();
        try {
            SVMXC__ServiceMax_Processes__c targetManager = [Select Id, Name, SVMXC__Page_Layout__c, SVMXC__Purpose__c, SVMXC__Enable_Sub_Process__c,SVMXC__Sub_Process_Source_Field__c, SVMXC__Process2__c From SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Target Manager' and (SVMXC__ProcessID__c = :processId OR Id = :processId)];
            List<SVMXC__ServiceMax_Processes__c> processNodeObjectList = [Select SVMXC__Default_Value__c, SVMXC__Values__c, SVMXC__Module__r.SVMXC__Source_Object_Name__c, SVMXC__Module__r.SVMXC__Target_Object_Name__c, SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c, SVMXC__Submodule__r.SVMXC__Source_Object_Name__c, Name,SVMXC__ProcessID__c,SVMXC__Page_Layout__c,SVMXC__Parent_Column_Name__c,SVMXC__Final_Exception_Process__c,SVMXC__Type__c,SVMXC__Node_Parent__c,SVMXC__Source_Object_Name__c,SVMXC__Target_Object_Name__c,SVMXC__Submodule__c,SVMXC__Module__c,SVMXC__Sequence__c,SVMXC__Process__c,SVMXC__Node_Source_Object_API__c,SVMXC__Target_Object_label__c,SVMXC__IsStandard__c,SVMXC__IsStandalone__c  From SVMXC__ServiceMax_Processes__c where SVMXC__Process__c = :processId and RecordType.Name  = 'Process Node Objects'];     	
            
            transactionManagerMap.put(targetManager, processNodeObjectList);
        }
        catch( Exception e ){
            System.debug( LoggingLevel.ERROR, 'getTargetManagerInfo() : Failed to retrieve record type id. ' + e.getMessage() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getTargetManagerInfo() - exit;' );
        }
        
        return transactionManagerMap;
    }
    
    public static Map<SObject,List<SObject>> getFieldMappingDetail( String mappingId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getFieldMappingDetail() - enter; mappingId=' + mappingId );
        
        Map<SObject,List<SObject>> fieldMappingDetailMap = new Map<SObject,List<SObject>>();
        try {
            SVMXC__ServiceMax_Processes__c mappingHeader = [Select SVMXC__Type__c, SVMXC__Target_Record_Type__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c,SVMXC__Settings_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c,SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c,SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c, SVMXC__MTTS_Minutes__c,SVMXC__IsStandard__c, SVMXC__IsStandalone__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__C,SVMXC__Final_Exception_Process__c,SVMXC__End_Date__c, SVMXC__Email_On_Success__c,SVMXC__Email_On_Error__c, SVMXC__Dispatch_Method__c, SVMXC__Description__c,SVMXC__Default_Value__c, SVMXC__Data_Type__c,  SVMXC__Child_Object_Criteria__c,SVMXC__Child_Error_Msg__c,SVMXC__Advance_Expression__c,SVMXC__Active__c, RecordTypeId, OwnerId, Name,LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__ServiceMax_Processes__c  where Id =: mappingId];
        	List<SVMXC__ServiceMax_Config_Data__c> mapingDetailsList = [Select SystemModstamp, SVMXC__User__c, SVMXC__Target_Field_Name__c,SVMXC__Stock_Status__c,SVMXC__Stock_History_Line_Lookup_Field__c, SVMXC__Stock_History_Header_Lookup_Field__c, SVMXC__Source_Field_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__Setting_ID__c, SVMXC__Setting_Configuration_Profile__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__Search_Object_Field_Type__c, SVMXC__Object_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__RecordType_Name__c, SVMXC__Profile__c, SVMXC__Profile_Name__c, SVMXC__Preference_3__c, SVMXC__Preference_2__c,SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__MapID__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Location_Type__c, SVMXC__Location_Field_Name__c, SVMXC__Location_Field_From__c, SVMXC__IsDefault__c, SVMXC__Inventory_Process__c,SVMXC__Internal_Value__c, SVMXC__Installation_Key__c,SVMXC__Field_Relationship_Name__c, SVMXC__Field_Name__c,SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, SVMXC__Enter_Date__c,SVMXC__Enable_Task__c, SVMXC__Enable_Calendar__c, SVMXC__Enable_Activity_Tracking_On__c,SVMXC__Display_Value__c, SVMXC__Display_Type__c, SVMXC__Display_Map_ID__c, SVMXC__Dispatch_Process__c,SVMXC__Description__c, SVMXC__Configuration_Type__c, SVMXC__Config_Profile_Name__c, SVMXC__Active__c,SVMXC__Action__c, SVMXC__Access_Configuration_Profile__c, RecordTypeId, OwnerId, Name, LastModifiedDate,LastModifiedById,  IsDeleted, Id,CreatedDate, CreatedById From SVMXC__ServiceMax_Config_Data__c  where SVMXC__MapID__c =: mappingHeader.Id];
        	
            fieldMappingDetailMap.put(mappingHeader, mapingDetailsList);
        }
        catch( Exception e ){
            System.debug( LoggingLevel.ERROR, 'getFieldMappingDetail() : Failed to query field mapping details. ' + e.getMessage() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFieldMappingDetail() - exit;' );
        }
        
        return fieldMappingDetailMap;
    }
    
    public static Map<SObject,List<SObject>> getExpressionDetails( final String expressionId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getExpressionDetails() - enter; expressionId=' + expressionId );
        
        Map<SObject,List<SObject>> expressionDetailMap = new Map<SObject,List<SObject>>();
        try {
            SVMXC__ServiceMax_Processes__c expressionProcess = [Select Id, Name,SVMXC__Source_Object_Name__c, SVMXC__Name__c,SVMXC__SettingId__c,SVMXC__Description__c, SVMXC__Advance_Expression__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id = :expressionId];
            List<SVMXC__ServiceMax_Config_Data__c> expressionDetailList = [Select SVMXC__Sequence__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Field_Name__c, SVMXC__Expression_Rule__c, Name, Id From SVMXC__ServiceMax_Config_Data__c where Recordtype.Name='Expressions' AND SVMXC__Expression_Type__c = 'EXP_Named' And SVMXC__Expression_Rule__c =:expressionId];
                                         
            expressionDetailMap.put(expressionProcess, expressionDetailList);
        }
        catch( Exception e ){
            System.debug( LoggingLevel.ERROR, 'getExpressionDetails() : Failed to query field mapping details. ' + e.getMessage() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getExpressionDetails() - exit;' );
        }
        
        return expressionDetailMap;
    }
}