/*****************************************************************************
 *                       Copyright (C) 2016 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The CONF_ApplicationFiltersImpl implements methods to retrieve/save list of objects used 
 * in SFW, SFW and Custom Actions and associated application filter configurations.
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

public with sharing class CONF_ApplicationFiltersImpl {

    /**
     * @brief APFT_Schema.Filters instance variable to hold Servicemax Online 
     * specific application filters.
     */
    private APFT_Schema.Filters onlineFilter;
    
    /**
     * @brief APFT_Schema.Filters instance variable to hold ipad specific application filters.
     */
    private APFT_Schema.Filters iPadFilter;
    
    /**
     * @brief APFT_Schema.Filters instance variable to hold iPhone specific application filters.
     */
    private APFT_Schema.Filters iPhoneFilter;
    
    /**
     * @brief APFT_Schema.Filters instance variable to hold android phone specific 
     * application filters.
     */
    private APFT_Schema.Filters androidPhoneFilter;
    
    /**
     * @brief APFT_Schema.Filters instance variable to hold android tablet specific 
     * application filters.
     */
    private APFT_Schema.Filters androidTabletFilter;
    
    /**
     * @brief This field is used to hold last modified date time.
     */
    private Datetime lastModifiedOn;
    
    /**
     * @brief APFT_Schema.Filters instance variable to hold windows specific 
     * application filters.
     */
    private APFT_Schema.Filters windowsFilter;
    
    /**
     * @brief Class constructor to create instance of this class. This will also create standard 
     * application profile records if not exists.
     */
    public CONF_ApplicationFiltersImpl() {
        initApplicationProfiles();    
    }
    
    /**
     * @brief This method is used to retrieve list of all supported record types for 
     * application filter.
     * 
     * @return Returns list of application filter supported record types.
     * 
     * @see APFT_Constants
     */
    public APFT_WrapperDef.APFT_Response getSupportedRecordTypes() {
        
        System.debug( LoggingLevel.DEBUG, 'getSupportedRecordTypes() - enter' );
        
        APFT_WrapperDef.APFT_Response response = new APFT_WrapperDef.APFT_Response();
        
        try {
            // Supported process record types are defined in APFT_Constants.
            for( String recordTypeName : APFT_Constants.SupportedRecordTypeMap.keySet() ) {
                
                APFT_WrapperDef.ObjectInfo objectInfo = new APFT_WrapperDef.ObjectInfo();
                
                objectInfo.name = recordTypeName;
                objectInfo.label = APFT_Constants.SupportedRecordTypeMap.get( recordTypeName );
                
                response.objectInfoList.add( objectInfo );
            }    
        }
        catch( Exception ex ) {
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
            
            response.success = false;
            response.message = System.Label.APFT001_TAG006;
        }   
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getSupportedRecordTypes() - exit' );
        }
        
        return response;
    }
    
    /**
     * @brief This method is used to retrieve all source objects for given record type name.
     * 
     * @param request Instance of APFT_WrapperDef.APFT_Request with record type name for 
     * which source object names to be retrieved.
     * 
     * @return Returns APFT_WrapperDef.APFT_Response with list of object label and API names.
     */
    public APFT_WrapperDef.APFT_Response getAllSourceObjects( APFT_WrapperDef.APFT_Request request ) {
        
        System.debug( LoggingLevel.DEBUG, 'getAllSourceObjects() - enter; request=' + request );
        
        APFT_WrapperDef.APFT_Response response = new APFT_WrapperDef.APFT_Response();
        
        try {
            
            if( request != null && request.recordTypeName != null && request.recordTypeName.trim() != '' ) {
                
                // App security check to validate fields are accessable to context user 
                // before quering the records.
                List<String> queryFields = new List<String> {'SVMXC__Source_Object_Name__c', 'SVMXC__Active__c'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                // Global describe to get field label for corresponding source object API names.
                Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
                Set<String> uniqueSourceObjectNameSet = new Set<String>();
                
                // Query only those source objects for which record Type name exists and is Active.
                for( SVMXC__ServiceMax_Processes__c processes : [SELECT SVMXC__Source_Object_Name__c, SVMXC__Active__c, SVMXC__Process__r.SVMXC__Dispatch_Process_Status__c, SVMXC__Type__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = :request.recordTypeName AND SVMXC__Process__r.SVMXC__Purpose__c != 'CHECKLIST'] ) {
                    
                    if( !processes.SVMXC__Active__c && request.recordTypeName.equalsIgnoreCase( APFT_Constants.RECORD_TYPE_WIZARD ) ) {
                        continue;
                    }
                    
                    if( request.recordTypeName.equalsIgnoreCase( APFT_Constants.RECORD_TYPE_SFM_PROCESS_NODE_OBJECT ) ) {
                        if( processes.SVMXC__Process__r.SVMXC__Dispatch_Process_Status__c != 'Complete' || ( processes.SVMXC__Type__c != null && ( !processes.SVMXC__Type__c.equalsIgnoreCase('SOURCE') && !processes.SVMXC__Type__c.equalsIgnoreCase('TARGET') ) ) ) {
                            continue;
                        }   
                    }
                    
                    // If valid source object name and not yet processes then create instance of objectinfo 
                    // object with name and label informations on response object. 
                    if( globalDescribeMap.containsKey( processes.SVMXC__Source_Object_Name__c ) && !uniqueSourceObjectNameSet.contains(processes.SVMXC__Source_Object_Name__c) ) {
                        
                        APFT_WrapperDef.ObjectInfo objectInfo = new APFT_WrapperDef.ObjectInfo();
                        
                        //Descrive sObjectType again to retrieve object label.
                        Schema.DescribeSObjectResult describeSObjectResult = globalDescribeMap.get( processes.SVMXC__Source_Object_Name__c ).getDescribe();
                        objectInfo.label = describeSObjectResult.getLabel();
                        objectInfo.name = describeSObjectResult.getName();
                        
                        response.objectInfoList.add( objectInfo );
                        uniqueSourceObjectNameSet.add( processes.SVMXC__Source_Object_Name__c );
                    }
                }                
                // Sort source object list based on object label.
                response.objectInfoList.sort();                
            } else {
                
                System.debug( LoggingLevel.ERROR, System.Label.APFT001_TAG010 );
                
                response.success = false;
                response.message = System.Label.APFT001_TAG010;
            }            
        }        
        catch( QueryException ex ) {
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
            
            response.success = false;
            response.message = System.Label.APFT001_TAG004;
        }        
        catch( COMM_SecurityUtils.SecurityAccessException ex ) {
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
            
            response.success = false;
            response.message = ex.getMessage();
        }        
        catch( Exception ex ) {
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
            
            response.success = false;
            response.message = System.Label.APFT001_TAG006;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllSourceObjects() - exit' );
        }
        
        return response;
    }

    /**
     * @brief This method is used to retrieve all wizard and wizard steps configured 
     * for given source object name.
     * 
     * @param request Instance of APFT_WrapperDef.APFT_Request with source object name for which 
     * wizard and wizard steps to be retrieved.
     * 
     * @return Return APFT_WrapperDef.APFT_Response instance will all wizard and wizard steps for 
     * requested source object name, Otherwise, returns instance with success status and error message.
     */
    public APFT_WrapperDef.APFT_Response getApplicationFilter( APFT_WrapperDef.APFT_Request request ) {
        
        System.debug( LoggingLevel.DEBUG, 'getApplicationFilter() - enter; request=' + request );
        
        APFT_WrapperDef.APFT_Response response = new APFT_WrapperDef.APFT_Response();        
        
        try {
            
            if( request != null && request.sourceObjectName != null && request.recordTypeName != null && request.sourceObjectName.trim() != '' && request.recordTypeName.trim() != '' ) {
                
                System.debug( LoggingLevel.DEBUG, 'getApplicationFilter(): Source Object Name: ' + request.sourceObjectName );
                
                // App security check to validate fields are accessable to context user 
                // before quering the records.
                List<String> queryFields = new List<String> { 'Id', 'SVMXC__Active__c', 'SVMXC__Name__c', 'SVMXC__ProcessID__c', 'SVMXC__Description__c', 'SVMXC__Source_Object_Name__c' };
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                Map<String, APFT_WrapperDef.APFT_FilterInfo> idFilterMap = new Map<String, APFT_WrapperDef.APFT_FilterInfo>();
                Set<String> uniqueProcessIdSet = new Set<String>();
                
                // If record type is process node object then process id is retrieved from parent process.
                if( request.recordTypeName.equalsIgnoreCase( APFT_Constants.RECORD_TYPE_SFM_PROCESS_NODE_OBJECT ) ) {
                                        
                    for( SVMXC__ServiceMax_Processes__c processes : [SELECT SVMXC__Process__r.SVMXC__Name__c, SVMXC__Process__r.SVMXC__ProcessID__c, SVMXC__Process__r.SVMXC__Description__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = :request.recordTypeName AND SVMXC__Source_Object_Name__c = :request.sourceObjectName AND SVMXC__Process__r.SVMXC__Dispatch_Process_Status__c = 'Complete' AND ( SVMXC__Type__c = 'SOURCE' OR SVMXC__Type__c = 'TARGET') AND SVMXC__Process__r.SVMXC__Purpose__c != 'CHECKLIST'] ) {
                        
                        // create responses with unique list of processes.
                        if( !uniqueProcessIdSet.contains(processes.SVMXC__Process__r.SVMXC__ProcessID__c) ) {
                            
                            APFT_WrapperDef.APFT_FilterInfo filterInfo = new APFT_WrapperDef.APFT_FilterInfo();
                            
                            filterInfo.processId = processes.SVMXC__Process__r.SVMXC__ProcessID__c;
                            filterInfo.name = processes.SVMXC__Process__r.SVMXC__Name__c;
                            filterInfo.description = processes.SVMXC__Process__r.SVMXC__Description__c;
                            
                            response.filterInfoList.add( filterInfo );
                            uniqueProcessIdSet.add( filterInfo.processId );
                        }
                    }
                } else {
                    
                    // For all other type, retrieve process id from SVMXC__ProcessID__c field.
                    for( SVMXC__ServiceMax_Processes__c processes : [SELECT Id, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Active__c, SVMXC__Record_Type_Name__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = :request.recordTypeName AND SVMXC__Source_Object_Name__c = :request.sourceObjectName AND SVMXC__Purpose__c != 'CHECKLIST'] ) {
                        
                        // Currently active flag is only respected to wizard type processes.
                        if( request.recordTypeName.equalsIgnoreCase( APFT_Constants.RECORD_TYPE_WIZARD ) && processes.SVMXC__Active__c == false ) {
                            continue;
                        }
                        
                        APFT_WrapperDef.APFT_FilterInfo filterInfo = new APFT_WrapperDef.APFT_FilterInfo();
                        
                        filterInfo.processId = processes.SVMXC__ProcessID__c;
                        filterInfo.name = processes.SVMXC__Name__c;
                        filterInfo.description = processes.SVMXC__Description__c;
                        
                        response.filterInfoList.add( filterInfo );
                        uniqueProcessIdSet.add( filterInfo.processId );
                    }
                }
                
                //APFT_Utilities.getInstance().clearInvalidFilters( request.recordTypeName, uniqueProcessIdSet );
                
                // Update filter info for each process records.
                populateFilterInfo( request.recordTypeName, response.filterInfoList );
                response.lastModifiedOn = lastModifiedOn;
                
                // Sort process records by process id.
                response.filterInfoList.sort();
            } else {
                
                System.debug( LoggingLevel.ERROR, System.Label.APFT001_TAG010 );
                
                response.success = false;
                response.message = System.Label.APFT001_TAG010;
            }
        }
        catch( QueryException ex ) {
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
            
            response.success = false;
            response.message = System.Label.APFT001_TAG005;
        }        
        catch( COMM_SecurityUtils.SecurityAccessException ex ) {
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
            
            response.success = false;
            response.message = ex.getMessage();
        }        
        catch( Exception ex ) {
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
            
            response.success = false;
            response.message = System.Label.APFT001_TAG006;
        }
        finally {
            if( !response.success ) {
                response.filterInfoList.clear();
            }
            System.debug( LoggingLevel.DEBUG, 'getApplicationFilter() - exit' );
        }        
        return response;
    }
    
    /**
     * @brief This method is used to save application filter configuration
     * 
     * @param request Instance of APFT_WrapperDef.APFT_Request with list of filter 
     * informations to be saved.
     * 
     * @return Returns true if successfully saved, Otherwise, returns false with error message.
     */
    public APFT_WrapperDef.APFT_Response saveApplicationFilter( APFT_WrapperDef.APFT_Request request ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveApplicationFilter() - enter; request= ' + request );
        
        APFT_WrapperDef.APFT_Response response = new APFT_WrapperDef.APFT_Response();
        response.message = System.Label.APFT001_TAG001;
        response.success = true;
            
        try {
            
            if( request != null && request.recordTypeName != null && request.recordTypeName.trim() != '' && request.filterInfoList != null && !request.filterInfoList.isEmpty() ) {
                
                // App security check to validate fields are accessable to context user 
                // before quering the records.
                List<String> queryFields = new List<String> {'SVMXC__ProcessID__c', 'SVMXC__Values__c', 'LastModifiedDate', 'SVMXC__Record_Type_Name__c'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                // Retrieve all application profile records to process device specific filters.
                List<SVMXC__ServiceMax_Processes__c> processesList = [SELECT SVMXC__ProcessID__c, SVMXC__Values__c, LastModifiedDate FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = :APFT_Constants.RECORD_TYPE_APPLICATION_PROFILE AND SVMXC__ProcessID__c != null]; //SDL-SVMX-READ-FLS-ENFORCED
                
                // Retrieve filters for each device type.
                initApplicationFilters();
                
                for( APFT_WrapperDef.APFT_FilterInfo filterInfo : request.filterInfoList ) {
                    // For each filter info, update the filters in existing records.
                    if( request.recordTypeName.equalsIgnoreCase( APFT_Constants.RECORD_TYPE_WIZARD ) ) {
                        
                        if( !filterInfo.onlineEnabled ) onlineFilter.wizards.add( filterInfo.processId ); else onlineFilter.wizards.remove( filterInfo.processId );
                        if( !filterInfo.iPadEnabled ) iPadFilter.wizards.add( filterInfo.processId ); else iPadFilter.wizards.remove( filterInfo.processId );
                        if( !filterInfo.iPhoneEnabled ) iPhoneFilter.wizards.add( filterInfo.processId ); else iPhoneFilter.wizards.remove( filterInfo.processId );    
                        if( !filterInfo.androidTabletEnabled ) androidTabletFilter.wizards.add( filterInfo.processId ); else androidTabletFilter.wizards.remove( filterInfo.processId );
                        if( !filterInfo.androidPhoneEnabled ) androidPhoneFilter.wizards.add( filterInfo.processId ); else androidPhoneFilter.wizards.remove( filterInfo.processId );
                        if( !filterInfo.windowsEnabled ) windowsFilter.wizards.add( filterInfo.processId ); else windowsFilter.wizards.remove( filterInfo.processId );
                    } else if( request.recordTypeName.equalsIgnoreCase( APFT_Constants.RECORD_TYPE_SFM_PROCESS_NODE_OBJECT ) ) {
                        
                        if( !filterInfo.onlineEnabled ) onlineFilter.sfms.add( filterInfo.processId ); else onlineFilter.sfms.remove( filterInfo.processId );
                        if( !filterInfo.iPadEnabled ) iPadFilter.sfms.add( filterInfo.processId ); else iPadFilter.sfms.remove( filterInfo.processId );
                        if( !filterInfo.iPhoneEnabled ) iPhoneFilter.sfms.add( filterInfo.processId ); else iPhoneFilter.sfms.remove( filterInfo.processId );    
                        if( !filterInfo.androidTabletEnabled ) androidTabletFilter.sfms.add( filterInfo.processId ); else androidTabletFilter.sfms.remove( filterInfo.processId );
                        if( !filterInfo.androidPhoneEnabled ) androidPhoneFilter.sfms.add( filterInfo.processId ); else androidPhoneFilter.sfms.remove( filterInfo.processId );
                        if( !filterInfo.windowsEnabled ) windowsFilter.sfms.add( filterInfo.processId ); else windowsFilter.sfms.remove( filterInfo.processId );
                    } else if( request.recordTypeName.equalsIgnoreCase( APFT_Constants.RECORD_TYPE_CUSTOM_ACTION ) ) {
                        
                        if( !filterInfo.onlineEnabled ) onlineFilter.sfactions.add( filterInfo.processId ); else onlineFilter.sfactions.remove( filterInfo.processId );
                        if( !filterInfo.iPadEnabled ) iPadFilter.sfactions.add( filterInfo.processId ); else iPadFilter.sfactions.remove( filterInfo.processId );
                        if( !filterInfo.iPhoneEnabled ) iPhoneFilter.sfactions.add( filterInfo.processId ); else iPhoneFilter.sfactions.remove( filterInfo.processId );    
                        if( !filterInfo.androidTabletEnabled ) androidTabletFilter.sfactions.add( filterInfo.processId ); else androidTabletFilter.sfactions.remove( filterInfo.processId );
                        if( !filterInfo.androidPhoneEnabled ) androidPhoneFilter.sfactions.add( filterInfo.processId ); else androidPhoneFilter.sfactions.remove( filterInfo.processId );
                        if( !filterInfo.windowsEnabled ) windowsFilter.sfactions.add( filterInfo.processId ); else windowsFilter.sfactions.remove( filterInfo.processId );
                    }
                }

				// Update the filter values back to process records.                
                for( SVMXC__ServiceMax_Processes__c processes : processesList ) {
                    
                    if( request.lastModifiedOn != null && request.lastModifiedOn < processes.lastModifiedDate ) {
                        
                        response.success = false;
                        response.message = System.Label.APFT001_TAG002;
                        break;
                    }
                    
                    processes.SVMXC__Values__c = null;
                    if( processes.SVMXC__ProcessID__c.equalsIgnoreCase( APFT_Constants.APPLICATION_PROFILE_ID_ONLINE ) ) {
                        
                        if( !onlineFilter.wizards.isEmpty() || !onlineFilter.sfms.isEmpty() || !onlineFilter.sfactions.isEmpty() ) {
                            processes.SVMXC__Values__c = JSON.serialize( onlineFilter );    
                        }
                    } else if( processes.SVMXC__ProcessID__c.equalsIgnoreCase( APFT_Constants.APPLICATION_PROFILE_ID_IPAD ) ) {
                        
                        if( !iPadFilter.wizards.isEmpty() || !iPadFilter.sfms.isEmpty() || !iPadFilter.sfactions.isEmpty() ) {                        
                            processes.SVMXC__Values__c = JSON.serialize( iPadFilter );
                        }                        
                    } else if( processes.SVMXC__ProcessID__c.equalsIgnoreCase( APFT_Constants.APPLICATION_PROFILE_ID_IPHONE ) ) {
                        if( !iPhoneFilter.wizards.isEmpty() || !iPhoneFilter.sfms.isEmpty() || !iPhoneFilter.sfactions.isEmpty() ) {                        
                            processes.SVMXC__Values__c = JSON.serialize( iPhoneFilter );
                        }
                    } else if( processes.SVMXC__ProcessID__c.equalsIgnoreCase( APFT_Constants.APPLICATION_PROFILE_ID_ANDROID_PHONE ) ) {
                        if( !androidPhoneFilter.wizards.isEmpty() || !androidPhoneFilter.sfms.isEmpty() || !androidPhoneFilter.sfactions.isEmpty() ) {                        
                            processes.SVMXC__Values__c = JSON.serialize( androidPhoneFilter );
                        }
                    } else if( processes.SVMXC__ProcessID__c.equalsIgnoreCase( APFT_Constants.APPLICATION_PROFILE_ID_ANDROID_TABLET ) ) {
                        if( !androidTabletFilter.wizards.isEmpty() || !androidTabletFilter.sfms.isEmpty() || !androidTabletFilter.sfactions.isEmpty() ) {                        
                            processes.SVMXC__Values__c = JSON.serialize( androidTabletFilter );
                        }
                    } else if( processes.SVMXC__ProcessID__c.equalsIgnoreCase( APFT_Constants.APPLICATION_PROFILE_ID_WINDOWS ) ) {
                        if( !windowsFilter.wizards.isEmpty() || !windowsFilter.sfms.isEmpty() || !windowsFilter.sfactions.isEmpty() ) {                        
                            processes.SVMXC__Values__c = JSON.serialize( windowsFilter );
                        }
                    }
                }
                
                if( response.success ) {
                    
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( processesList, COMM_SecurityUtils.Access.Updateable ) ) {
                        update processesList; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    
                    response.lastModifiedOn = System.now();
                }                
            } else {
                
                System.debug( LoggingLevel.ERROR, System.Label.APFT001_TAG010 );
                
                response.success = false;
                response.message = System.Label.APFT001_TAG010;
            }
        }        
        catch( QueryException ex ) {
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
            
            response.success = false;
            response.message = System.Label.APFT001_TAG011;
        }
        catch( JSONException ex ) {
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
            
            response.success = false;
            response.message = System.Label.APFT001_TAG006;
        }        
        catch( COMM_SecurityUtils.SecurityAccessException ex ) {
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
            
            response.success = false;
            response.message = ex.getMessage();
        }
        catch( DMLException ex ) {
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
            
            response.success = false;
            response.message = System.Label.APFT001_TAG003;
        }        
        catch( Exception ex ) {
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
            
            response.success = false;
            response.message = System.Label.APFT001_TAG006;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveApplicationFilter() - exit; response= ' + response );
        }
        
        return response;
    }
    
    /**
     * @brief This private method is used to populate filters to list of APFT_WrapperDef.APFT_FilterInfo.
     * 
     * @param recordTypeName Processes record type.
     * @param filterInfoList list of APFT_WrapperDef.APFT_FilterInfo to be populated.
     */
    @TestVisible private void populateFilterInfo( String recordTypeName, List<APFT_WrapperDef.APFT_FilterInfo> filterInfoList ) {
        
        System.debug( LoggingLevel.DEBUG, 'populateFilterInfo() - enter; recordTypeName= ' + recordTypeName );
        
        if( recordTypeName != null && filterInfoList != null && !filterInfoList.isEmpty() ) {
            
            // App security check to validate fields are accessable to context user 
            // before quering the records.
            List<String> queryFields = new List<String> {'SVMXC__ProcessID__c', 'SVMXC__Values__c', 'LastModifiedDate', 'SVMXC__Record_Type_Name__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            // Retrieve last modified date.
            SVMXC__ServiceMax_Processes__c lastModifiedProcess = [SELECT LastModifiedDate FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = :APFT_Constants.RECORD_TYPE_APPLICATION_PROFILE ORDER BY LastModifiedDate DESC NULLS LAST LIMIT 1]; //SDL-SVMX-READ-FLS-ENFORCED        
            lastModifiedOn = lastModifiedProcess.LastModifiedDate;
            
            initApplicationFilters();
            
            // For each process populate filter information.
            for( APFT_WrapperDef.APFT_FilterInfo filterInfo : filterInfoList ) {
                
                if( recordTypeName.equalsIgnoreCase( APFT_Constants.RECORD_TYPE_WIZARD ) ) {
                    
                    filterInfo.onlineEnabled = !onlineFilter.wizards.contains( filterInfo.processId );
                    filterInfo.iPadEnabled = !iPadFilter.wizards.contains( filterInfo.processId );
                    filterInfo.iPhoneEnabled = !iPhoneFilter.wizards.contains( filterInfo.processId );
                    filterInfo.androidTabletEnabled = !androidTabletFilter.wizards.contains( filterInfo.processId );
                    filterInfo.androidPhoneEnabled = !androidPhoneFilter.wizards.contains( filterInfo.processId );
                    filterInfo.windowsEnabled = !windowsFilter.wizards.contains( filterInfo.processId );
                } else if( recordTypeName.equalsIgnoreCase( APFT_Constants.RECORD_TYPE_SFM_PROCESS_NODE_OBJECT ) ) {
                    
                    filterInfo.onlineEnabled = !onlineFilter.sfms.contains( filterInfo.processId );
                    filterInfo.iPadEnabled = !iPadFilter.sfms.contains( filterInfo.processId );
                    filterInfo.iPhoneEnabled = !iPhoneFilter.sfms.contains( filterInfo.processId );
                    filterInfo.androidTabletEnabled = !androidTabletFilter.sfms.contains( filterInfo.processId );
                    filterInfo.androidPhoneEnabled = !androidPhoneFilter.sfms.contains( filterInfo.processId );
                    filterInfo.windowsEnabled = !windowsFilter.sfms.contains( filterInfo.processId );
                } else if( recordTypeName.equalsIgnoreCase( APFT_Constants.RECORD_TYPE_CUSTOM_ACTION ) ) {
                    
                    filterInfo.onlineEnabled = !onlineFilter.sfactions.contains( filterInfo.processId );
                    filterInfo.iPadEnabled = !iPadFilter.sfactions.contains( filterInfo.processId );
                    filterInfo.iPhoneEnabled = !iPhoneFilter.sfactions.contains( filterInfo.processId );
                    filterInfo.androidTabletEnabled = !androidTabletFilter.sfactions.contains( filterInfo.processId );
                    filterInfo.androidPhoneEnabled = !androidPhoneFilter.sfactions.contains( filterInfo.processId );
                    filterInfo.windowsEnabled = !windowsFilter.sfactions.contains( filterInfo.processId );
                }    
            }
        }
        
        System.debug( LoggingLevel.DEBUG, 'populateFilterInfo() - exit');
    }
    
    /**
     * @brief This private method is used to retrieve application profile records and populate 
     * necessary structures. 
     * 
     * @param processesList List of Application profile records.
     */
    @TestVisible private void initApplicationFilters() {

        System.debug( LoggingLevel.DEBUG, 'initApplicationProfiles() - enter;' );
        
        onlineFilter = APFT_Utilities.getInstance().getDeviceFilters( APFT_Constants.APPLICATION_PROFILE_ID_ONLINE );
        iPadFilter = APFT_Utilities.getInstance().getDeviceFilters( APFT_Constants.APPLICATION_PROFILE_ID_IPAD );
        iPhoneFilter = APFT_Utilities.getInstance().getDeviceFilters( APFT_Constants.APPLICATION_PROFILE_ID_IPHONE );
        androidPhoneFilter = APFT_Utilities.getInstance().getDeviceFilters( APFT_Constants.APPLICATION_PROFILE_ID_ANDROID_PHONE );
        androidTabletFilter = APFT_Utilities.getInstance().getDeviceFilters( APFT_Constants.APPLICATION_PROFILE_ID_ANDROID_TABLET );
        windowsFilter = APFT_Utilities.getInstance().getDeviceFilters( APFT_Constants.APPLICATION_PROFILE_ID_WINDOWS );
        
        System.debug( LoggingLevel.DEBUG, 'initApplicationProfiles() - exit;' );
    }
    
    /**
     * @brief This method is used to create Application Profile records if not exists.
     */
    @TestVisible private void initApplicationProfiles() {
        
        System.debug( LoggingLevel.DEBUG, 'initApplicationProfiles()- enter');
        
        try {

			// App security check to validate fields are accessable to context user 
            // before quering the records.
            List<String> queryFields = new List<String> {'SVMXC__Record_Type_Name__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }            
            
            Integer count = [SELECT count() FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = :APFT_Constants.RECORD_TYPE_APPLICATION_PROFILE];
            if( count == 0 ) {
                
                System.debug( LoggingLevel.INFO, 'Application Profile standard records not exists. Creating Application profile records.' );
                
                // App security check to validate fields are accessable to context user 
                // before quering the records.
                queryFields = new List<String> {'Id', 'SobjectType', 'Name' };
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'RecordType', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }   
                    
                List<SVMXC__ServiceMax_Processes__c> applicationProfileList = new List<SVMXC__ServiceMax_Processes__c>();
                RecordType applicationProfileType = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = :APFT_Constants.RECORD_TYPE_APPLICATION_PROFILE LIMIT 1 ]; //SDL-SVMX-READ-FLS-ENFORCED
                
                SVMXC__ServiceMax_Processes__c onlineProcesses = new SVMXC__ServiceMax_Processes__c(
                    
                    RecordTypeId = applicationProfileType.id, 
                    SVMXC__Name__c = 'ServiceMax Online',
                    SVMXC__IsStandard__c = true,
                    SVMXC__ProcessID__c = APFT_Constants.APPLICATION_PROFILE_ID_ONLINE 
                );
                applicationProfileList.add(onlineProcesses);
                
                SVMXC__ServiceMax_Processes__c iPadProcesses = new SVMXC__ServiceMax_Processes__c(
                    
                    RecordTypeId = applicationProfileType.id, 
                    SVMXC__Name__c = 'iPad', 
                    SVMXC__IsStandard__c = true,
                    SVMXC__ProcessID__c = APFT_Constants.APPLICATION_PROFILE_ID_IPAD
                );
                applicationProfileList.add(iPadProcesses);
                
                SVMXC__ServiceMax_Processes__c iPhoneProcesses = new SVMXC__ServiceMax_Processes__c(
                    
                    RecordTypeId = applicationProfileType.id, 
                    SVMXC__Name__c = 'iPhone', 
                    SVMXC__IsStandard__c = true,
                    SVMXC__ProcessID__c = APFT_Constants.APPLICATION_PROFILE_ID_IPHONE
                );
                applicationProfileList.add(iPhoneProcesses);
                
                SVMXC__ServiceMax_Processes__c androidPhoneProcesses = new SVMXC__ServiceMax_Processes__c(
                    
                    RecordTypeId = applicationProfileType.id, 
                    SVMXC__Name__c = 'Android Phone', 
                    SVMXC__IsStandard__c = true,
                    SVMXC__ProcessID__c = APFT_Constants.APPLICATION_PROFILE_ID_ANDROID_PHONE 
                );
                applicationProfileList.add(androidPhoneProcesses);
                
                SVMXC__ServiceMax_Processes__c androidTabletProcesses = new SVMXC__ServiceMax_Processes__c(
                    
                    RecordTypeId = applicationProfileType.id, 
                    SVMXC__Name__c = 'Android Tablet', 
                    SVMXC__IsStandard__c = true,
                    SVMXC__ProcessID__c = APFT_Constants.APPLICATION_PROFILE_ID_ANDROID_TABLET 
                );
                applicationProfileList.add(androidTabletProcesses);
                
                SVMXC__ServiceMax_Processes__c windowsProcesses = new SVMXC__ServiceMax_Processes__c(
                    
                    RecordTypeId = applicationProfileType.id, 
                    SVMXC__Name__c = 'Windows', 
                    SVMXC__IsStandard__c = true,
                    SVMXC__ProcessID__c = APFT_Constants.APPLICATION_PROFILE_ID_WINDOWS
                );
                applicationProfileList.add(windowsProcesses);
                
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( applicationProfileList, COMM_SecurityUtils.Access.Createable ) ) {
                    insert applicationProfileList; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                System.debug( LoggingLevel.INFO, 'Application Profile standard records created successfully.' );
            }    
        }
        catch( QueryException ex ) {
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
        }        
        catch( COMM_SecurityUtils.SecurityAccessException ex ) {
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
        }        
        catch( Exception ex ) {            
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'initApplicationProfiles()- exit');
        }
    }
}