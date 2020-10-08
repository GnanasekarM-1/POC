/*****************************************************************************
 *                       Copyright (C) 2016 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The APFT_Utilities implements utility methods which can be used accross servicemax product.
 * 
 *
 * @author Ramachandra Mohan
 * @version 16.39000
 * @since 2016
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan      13 May 2016     Created. 
 *****************************************************************************************************/
public class APFT_Utilities {
    
    /**
     * @brief Single static instance variable of this class.
     */
    private static final APFT_Utilities instance = new APFT_Utilities();
    
    /**
     * 
     */
    private Map<String,APFT_Schema.Filters> deviceTypeFiltersMap = new Map<String,APFT_Schema.Filters>();
    
    /**
     * 
     */
    private Map<String, SVMXC__ServiceMax_Processes__c> deviceTypeProcessMap = new Map<String, SVMXC__ServiceMax_Processes__c>();
    
    /**
     * 
     */
    private Datetime lastModifiedOn;
    
    /**
     * @brief Static method to get instance of this class with all supported filter devices.
     * 
     * @return Always returns single instance of this class.
     */
    public static APFT_Utilities getInstance() {
        return instance;
    }
    
    /**
     * @brief Static method to create instance of this class with specific filter devices.
     * 
     * @return Returns new instance with filters for specified device type.
     */
    public static APFT_Utilities createInstanceByDeviceType( List<String> deviceTypeIdList ) {
        return new APFT_Utilities( deviceTypeIdList );
    }
    
    /**
     * @brief This method is used to retrieve filters for specified device type
     * 
     * @param deviceType Application Profile process id for which the filter to be retrieved.
     * @return Returns APFT_Schema.Filters instance to requested device type.
     */
    public APFT_Schema.Filters getDeviceFilters( String deviceType ) {
        return deviceTypeFiltersMap.get( deviceType );
    }
    
    /**
     * @brief This method is used to clear invalid process id's from JSON structure.
     * 
     * @param recordTypeName Record type for which the invalid process id's to be cleared.
     * @param uniqueProcessIdSet Unique set of process id's of same type.
     */
    public void clearInvalidFilters( String recordTypeName, Set<String> uniqueProcessIdSet ) {
        
        System.debug( LoggingLevel.DEBUG, 'clearInvalidFilters - enter; recordTypeName: ' + recordTypeName );
        
        if( recordTypeName != null && !recordTypeName.trim().equals('') && uniqueProcessIdSet != null && !uniqueProcessIdSet.isEmpty() ) {
            
            // For each device type, retrieve the filter and validate the process Id's.
            Boolean hasInvalidFilters = false;        
            for( String deviceType : deviceTypeFiltersMap.keySet() ) {
                
                APFT_Schema.Filters filters = deviceTypeFiltersMap.get(deviceType);            
                Set<String> configuredProcessIdSet = new Set<String>();
                // retrieve process id set for specified record type name.
                if( recordTypeName.equalsIgnoreCase( APFT_Constants.RECORD_TYPE_WIZARD ) ) {                
                    configuredProcessIdSet = filters.wizards;                
                } else if( recordTypeName.equalsIgnoreCase( APFT_Constants.RECORD_TYPE_SFM_PROCESS_NODE_OBJECT ) || recordTypeName.equalsIgnoreCase( APFT_Constants.RECORD_TYPE_SFM ) || ( recordTypeName.equalsIgnoreCase( APFT_Constants.RECORD_TYPE_WIZARD_STEP ) && !recordTypeName.equalsIgnoreCase(APFT_Constants.ACTION_TYPE_OTHERS) ) ) {
                    configuredProcessIdSet = filters.sfms;
                } else if( recordTypeName.equalsIgnoreCase( APFT_Constants.RECORD_TYPE_CUSTOM_ACTION ) || ( recordTypeName.equalsIgnoreCase( APFT_Constants.RECORD_TYPE_WIZARD_STEP ) && recordTypeName.equalsIgnoreCase(APFT_Constants.ACTION_TYPE_OTHERS) ) ) {                
                    configuredProcessIdSet = filters.sfactions;
                }
                
                if( configuredProcessIdSet != null && !configuredProcessIdSet.isEmpty() ) {
                    
                    // Remove invalid process ids.
                    Set<String> invalidProcessId = new Set<String>();            
                    for( String processId : configuredProcessIdSet ) {                
                        if( !uniqueProcessIdSet.contains( processId ) ) {
                            invalidProcessId.add(processId);
                        }
                    }
                    
                    if( ! invalidProcessId.isEmpty() ) {
                        
                        hasInvalidFilters = true;
                        configuredProcessIdSet.removeAll(invalidProcessId);
                        deviceTypeProcessMap.get(deviceType).SVMXC__Values__c = JSON.serialize( filters );
                    }
                }            
            }
            
            if( hasInvalidFilters ) update deviceTypeProcessMap.values();            
        }
        
        System.debug( LoggingLevel.DEBUG, 'clearInvalidFilters - exit' );
    }
    
    /**
     * @brief This method is used to apply application filters and updated the process list accordingly.
     * 
     * @param processesList List of servicemax processes records to be filtered.
     * @param deviceType Device type for which the filter to be applied. 
     * 
     * @return Returns true if filters applied successfully, Otherwise, returns false.
     */
    public Boolean applyApplicationFilters( List<SVMXC__ServiceMax_Processes__c> processesList, String deviceType ) {
        
        System.debug( LoggingLevel.DEBUG, 'applyApplicationFilters() - enter; deviceType= ' + deviceType );
        
        Boolean applySuccess = true;
        try {
            if( processesList != null && !processesList.isEmpty() && deviceType != null && deviceTypeFiltersMap.containsKey(deviceType) ) {
                
                APFT_Schema.Filters filters = deviceTypeFiltersMap.get(deviceType);
                
                List<SVMXC__ServiceMax_Processes__c> qualifiedProcessesList = new List<SVMXC__ServiceMax_Processes__c>();
                for( SVMXC__ServiceMax_Processes__c processes : processesList ) {
                    
                    if( APFT_Constants.RecordTypeCompareFieldMap.containsKey( processes.SVMXC__Record_Type_Name__c ) ) {
                        
                        String fieldApiName = APFT_Constants.RecordTypeCompareFieldMap.get( processes.SVMXC__Record_Type_Name__c );
                        String fieldValue = (String) getFieldValue( processes, fieldApiName );
                        
                        if( processes.SVMXC__Record_Type_Name__c.equalsIgnoreCase( APFT_Constants.RECORD_TYPE_WIZARD )) {
                            
                            if( filters.wizards == null || !filters.wizards.contains( fieldValue ) ) {
                                qualifiedProcessesList.add( processes );
                            } 
                        } else if( processes.SVMXC__Record_Type_Name__c.equalsIgnoreCase( APFT_Constants.RECORD_TYPE_SFM_PROCESS_NODE_OBJECT ) || processes.SVMXC__Record_Type_Name__c.equalsIgnoreCase( APFT_Constants.RECORD_TYPE_SFM ) || ( processes.SVMXC__Record_Type_Name__c.equalsIgnoreCase( APFT_Constants.RECORD_TYPE_WIZARD_STEP ) && !processes.SVMXC__Action_Type__c.equalsIgnoreCase(APFT_Constants.ACTION_TYPE_OTHERS) ) ) {
                            
                            if( filters.sfms == null || !filters.sfms.contains( fieldValue ) ) {
                                qualifiedProcessesList.add( processes );
                            }
                        } else if( processes.SVMXC__Record_Type_Name__c.equalsIgnoreCase( APFT_Constants.RECORD_TYPE_CUSTOM_ACTION ) || ( processes.SVMXC__Record_Type_Name__c.equalsIgnoreCase( APFT_Constants.RECORD_TYPE_WIZARD_STEP ) && processes.SVMXC__Action_Type__c.equalsIgnoreCase(APFT_Constants.ACTION_TYPE_OTHERS) ) ) {
                            
                            if( filters.sfactions == null || !filters.sfactions.contains( fieldValue ) ) {
                                qualifiedProcessesList.add( processes );
                            }
                        } else {
                            applySuccess = false;
                            System.debug( LoggingLevel.ERROR, 'Unsupported record type ' + processes.SVMXC__Record_Type_Name__c );
                            
                            break;
                        }
                    } else {
                        System.debug( LoggingLevel.ERROR, 'applyApplicationFilters(): Unsupported record type. recordType=' + processes.SVMXC__Record_Type_Name__c );
                        
                        applySuccess = false;
                        break;
                    }
                }
                
                if( applySuccess ) {
                    
                    processesList.clear(); 
                    processesList.addAll(qualifiedProcessesList);    
                }
                
            } else {
                applySuccess = false;
                System.debug( LoggingLevel.ERROR, 'Invalid or Unsupported arguments.');
            }    
        }
        catch( Exception ex) {
            
            applySuccess = false;
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
        }
        
        return applySuccess;
    }
    
    /**
     * @brief This method is used to retrieve field value for specified record and field API name.
     * 
     * @param record SObject instance from which value to be retrieved.
     * @param fieldName Field API name of which value to be retrieved.
     * 
     * @return Returns object value for specified field API name from sobject. 
     */
    @TestVisible private Object getFieldValue( SObject record, String fieldName ) {
        
        if( fieldName == null || record == null ) {
            return null;
        }
        
        Integer index = fieldName.indexOf('.');
        
        if( index == -1 ) {
            return record.get( fieldName );
        }
        
        String referrenceField = fieldName.substring( 0, index );
        fieldName = fieldName.substring( index + 1 );
        
        return getFieldValue( record.getSObject( referrenceField ), fieldName );
    }
    
    private APFT_Utilities() {
        
        for( SVMXC__ServiceMax_Processes__c applicationFilter : [SELECT SVMXC__ProcessID__c, SVMXC__Values__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = :APFT_Constants.RECORD_TYPE_APPLICATION_PROFILE AND SVMXC__IsStandard__c = true] ) {
            
            APFT_Schema.Filters filters = new APFT_Schema.Filters();
            if( applicationFilter.SVMXC__Values__c != null && applicationFilter.SVMXC__Values__c.trim() != '') {
                filters = (APFT_Schema.Filters) JSON.deserialize( applicationFilter.SVMXC__Values__c, APFT_Schema.Filters.class );
            }
            
            deviceTypeFiltersMap.put(applicationFilter.SVMXC__ProcessID__c, filters );
            deviceTypeProcessMap.put(applicationFilter.SVMXC__ProcessID__c, applicationFilter );
        }
        
        System.debug( LoggingLevel.DEBUG, 'APFT_Utilities() - exit; deviceTypeFiltersMap: ' + deviceTypeFiltersMap );
    }
    
    private APFT_Utilities( List<String> deviceTypeIdList ) {
        
        for( SVMXC__ServiceMax_Processes__c applicationFilter : [SELECT Id,SVMXC__ProcessID__c, SVMXC__Values__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = :APFT_Constants.RECORD_TYPE_APPLICATION_PROFILE AND SVMXC__IsStandard__c = true AND SVMXC__ProcessID__c = :deviceTypeIdList] ) {
            
            APFT_Schema.Filters filters = new APFT_Schema.Filters();
            if( applicationFilter.SVMXC__Values__c != null && applicationFilter.SVMXC__Values__c.trim() != '') {
                filters = (APFT_Schema.Filters) JSON.deserialize( applicationFilter.SVMXC__Values__c, APFT_Schema.Filters.class );
            }
            
            deviceTypeFiltersMap.put(applicationFilter.SVMXC__ProcessID__c, filters );
            deviceTypeProcessMap.put(applicationFilter.SVMXC__ProcessID__c, applicationFilter );
        }
    }
}