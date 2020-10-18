/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The SFM_FieldUpdateRuleUtils implements methods to perform Get & Save operations on 
 * Field Update Rule/Formula details. As the RecordType is same as Business Rule, Business 
 * Rule services will be used for other operations like delete, get mapped processes etc. 
 * Internally, the Field Update Rule will be saved in ServiceMax_Processes__c object and 
 * Field Update details are saved in ServiceMax_Config_Data__c object.
 * 
 * <b>Note:</b> Rule type 'Field Update Rule' has been used to save Formulas and
 * record type 'Field Updates' has been used to save Field Update Rule details.
 *
 * @author Ramachandra Mohan
 * @version 15.39100
 * @since 2015
 * @See SFM_BizRuleUtils
 */
/*****************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************
 *              Ramachandra Mohan      04 Jun 2015     Created. 
 *****************************************************************************/
/* Security Scanned */
public with sharing class SFM_FieldUpdateRuleUtils {

    /**
     * Class constructor to create instance of this class. 
     */
    public SFM_FieldUpdateRuleUtils() {}
    
    /**
     * This method is used to retrieve all Field Update Rule process ID's or process ID's for specified 
     * Source Object Name. The Source Object Name will be populated to the SFM_WrapperDef.SFM_Request
     * object stringListMap instance variable. The key will be set to 'OBJECTAPINAME' and value with 
     * Source Object Name.
     * 
     * @param request SFM_WrapperDef.SFM_Request object instance.
     * @return Returns SFM_WrapperDef.SFM_Response object instance with list of process ID's in resultIds.
     */
    public SVMXC.SFM_WrapperDef.SFM_Response SFM_GetFieldUpdateRuleIds( SVMXC.SFM_WrapperDef.SFM_Request request ) {
        
        System.debug(LoggingLevel.DEBUG, 'SFM_GetFieldUpdateRuleIds() - enter; request: ' + request );
        
        SVMXC.SFM_WrapperDef.SFM_Response response = new SVMXC.SFM_WrapperDef.SFM_Response();        
        response.success = true;
                
        try {
            
            /* Validate and process the request */
            List<String> sourceObjectNameList = new List<String>();
            List<String> aliasNameList = new List<String>();
            if( request != NULL && request.stringListMap != NULL && !request.stringListMap.isEmpty() ) {
                
                /* List all source object names if exists in request */
              for( SVMXC.SFM_WrapperDef.SFM_StringListMap requestStringListMap : request.stringListMap ) {
                
                    if( requestStringListMap == null || requestStringListMap.key == NULL ) {
                        
                        System.debug( LoggingLevel.ERROR, 'Null requestStringListMap or requestStringListMap.key found in SFM_WrapperDef.SFM_StringListMap' );
                        continue;
                    }
                    
                    /* Add source object name to list if key 'OBJECTAPINAME' and value is not empty from request*/
                    if( requestStringListMap.key.equalsIgnoreCase( SFM_Consts.KEY_OBJECT_API_NAME ) && 
                         requestStringListMap.valueList != NULL && !requestStringListMap.valueList.isEmpty() ) {
                        
                        for( String sourceObjectName : requestStringListMap.valueList ) {
                            
                            /* Add to source object name list only if its a valid string*/
                            if( ! isValidateFieldValue( sourceObjectName ) ) {
                                
                                System.debug( LoggingLevel.ERROR, 'Invalid source object name found in SFM_WrapperDef.SFM_StringListMap.valueList. SourceObjectName = ' + sourceObjectName );
                                continue;
                            }
                            
                            sourceObjectNameList.add( String.escapeSingleQuotes( sourceObjectName ) );
                        }                        
                    } else if( requestStringListMap.key.equalsIgnoreCase( SFM_Consts.KEY_ALIAS_NAME ) && 
                         requestStringListMap.valueList != NULL && !requestStringListMap.valueList.isEmpty() ) {
                        
                        for( String aliasName : requestStringListMap.valueList ) {
                            
                            /* Add to source object name list only if its a valid string*/
                            if( ! isValidateFieldValue( aliasName ) ) {
                                
                                System.debug( LoggingLevel.ERROR, 'Invalid alias name found in SFM_WrapperDef.SFM_StringListMap.valueList. alias name = ' + aliasName );
                                continue;
                            }
                            
                            aliasNameList.add( String.escapeSingleQuotes( aliasName ) );
                        }                        
                    }
                }    
            } else {
                System.debug( LoggingLevel.WARN, 'Null request/request.stringListMap or empty stringListMap found. Retrieving all Ids' );
            }
        
            /* Query all Field Update Rules if source object name is not specified, Otherwise, 
       * Retrieve processes for requested source object names */
            Map<String, SVMXC__ServiceMax_Processes__c> fieldUpdateRuleIdMap = new Map<String, SVMXC__ServiceMax_Processes__c>();
            
            if( sourceObjectNameList.isEmpty() ) {
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                fieldUpdateRuleIdMap.putAll( [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Source_Object_Name__c != NULL AND Recordtype.Name = :SFM_Consts.RECORD_TYPE_BUSINESS_RULE AND SVMXC__Rule_Type__c = :SFM_Consts.RULE_TYPE_FIELD_UPDATE_RULE ] );
            } else if( aliasNameList.isEmpty() ) {
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                fieldUpdateRuleIdMap.putAll( [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Source_Object_Name__c IN: sourceObjectNameList AND SVMXC__Source_Object_Name__c != NULL AND Recordtype.Name = :SFM_Consts.RECORD_TYPE_BUSINESS_RULE AND SVMXC__Rule_Type__c = :SFM_Consts.RULE_TYPE_FIELD_UPDATE_RULE ] );
            } else {
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                fieldUpdateRuleIdMap.putAll( [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Source_Object_Name__c IN: sourceObjectNameList AND SVMXC__Target_Object_label__c IN: aliasNameList AND SVMXC__Source_Object_Name__c != NULL AND Recordtype.Name = :SFM_Consts.RECORD_TYPE_BUSINESS_RULE AND SVMXC__Rule_Type__c = :SFM_Consts.RULE_TYPE_FIELD_UPDATE_RULE ] );
            }
            
            /* If process exist then populate process id's to response object. */
            if( !fieldUpdateRuleIdMap.isEmpty() ) response.resultIds.addAll( fieldUpdateRuleIdMap.keySet() );
        }
        
        catch( QueryException ex ) {
        
            System.debug( LoggingLevel.ERROR, 'SFM_GetFieldUpdateRuleIds() : Failed to retrieve Field Update rules.' + ex.getStackTraceString() );
                    
            response.success = false;
            response.message = System.Label.SFM001_TAG503;
        }
        
        catch( exception ex ) {
            
            response.success = false;
            response.message = System.Label.SFM001_TAG503;
            
            System.debug(LoggingLevel.ERROR, 'SFM_GetFieldUpdateRuleIds() : Failed to retrieve Field Update rules.' + ex.getStackTraceString() );
        }
        
        System.debug(LoggingLevel.DEBUG, 'SFM_GetFieldUpdateRuleIds() - exit; response: ' + response );
        
        return response;        
    }
    
    /**
     * This method is used to retrieve Field Update Details for specified Field 
     * Update Rule Id'd or all Field Update Rules.
     * 
     * @param request SFM_WrapperDef.SFM_Request object instance with Field Update Rule Id's.
     * @return Returns SFM_WrapperDef.SFM_Response object instance with list of SFM_WrapperDef.SFM_FieldUpdateRuleInfo.
     */
    public SVMXC.SFM_WrapperDef.SFM_Response SFM_GetFieldUpdateRuleInfo( SVMXC.SFM_WrapperDef.SFM_Request request ) {
        
        System.debug(LoggingLevel.DEBUG, 'SFM_GetFieldUpdateRuleInfo() - enter; request: ' + request );
        
        SVMXC.SFM_WrapperDef.SFM_Response response = new SVMXC.SFM_WrapperDef.SFM_Response();
        response.success = true;
                
        try {
            /* Validate and process request object.*/
            List<String> fieldUpdateRuleIdList = new List<String>();
            if( request != NULL && request.stringListMap != NULL && !request.stringListMap.isEmpty() ) {
                
                System.debug( LoggingLevel.DEBUG, 'SFM_GetFieldUpdateRuleInfo() : Fetching Field Update Rule IDs from request.' );
                
                for( SVMXC.SFM_WrapperDef.SFM_StringListMap requestStringListMap : request.stringListMap) {
                    
                    if( requestStringListMap == NULL || requestStringListMap.key == NULL ) {
                        continue;
                    }
                    
                    /* Populate the process ID'd to list from request where key must me 'UPDATERULEID' 
           * and value must have valid process ID.*/ 
                    if( requestStringListMap.key.equalsIgnoreCase( SFM_Consts.KEY_FIELD_UPDATE_RULE_IDS ) && requestStringListMap.valueList != NULL && !requestStringListMap.valueList.isEmpty() ) {
                        
                        for( String fieldUpdateRuleId : requestStringListMap.valueList) {
                            
                            /* Ignore the map Entry of the process Id is invalid. */
                            if( ! isValidateFieldValue( fieldUpdateRuleId ) ) {
                                
                                System.debug( LoggingLevel.ERROR, 'SFM_GetFieldUpdateRuleInfo() : Invalid Field Update Rule ID found in SFM_WrapperDef.SFM_StringListMap.valueList. fieldUpdateRuleId = ' + fieldUpdateRuleId );
                                continue;
                            }
                            
                            /* Populate valid field update rule Id's to list */
                            fieldUpdateRuleIdList.add( String.escapeSingleQuotes( fieldUpdateRuleId ) );
                        }
                    }
                }
            } else {
                System.debug( LoggingLevel.WARN, 'SFM_GetFieldUpdateRuleInfo() : Null request/request.stringListMap or empty stringListMap found. Retrieving all Field Update Rules' );
            } 
            
            /* Query requested Field Update Rule fields from ServiceMax Process object. */
            Map<Id, SVMXC__ServiceMax_Processes__c> fieldUpdateRuleProcessMap = new Map<Id, SVMXC__ServiceMax_Processes__c>();
            
            if( ! fieldUpdateRuleIdList.isEmpty() ) {
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA               
                fieldUpdateRuleProcessMap.putAll( [SELECT Id, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Source_Object_Name__c, SVMXC__Advance_Expression__c, SVMXC__Rule_Type__c, SVMXC__Target_Object_label__c FROM SVMXC__ServiceMax_Processes__c WHERE Recordtype.Name = :SFM_Consts.RECORD_TYPE_BUSINESS_RULE AND SVMXC__Rule_Type__c = :SFM_Consts.RULE_TYPE_FIELD_UPDATE_RULE AND Id IN :fieldUpdateRuleIdList]);
            } else {
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                fieldUpdateRuleProcessMap.putAll( [SELECT Id, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Source_Object_Name__c, SVMXC__Advance_Expression__c, SVMXC__Rule_Type__c, SVMXC__Target_Object_label__c FROM SVMXC__ServiceMax_Processes__c WHERE Recordtype.Name = :SFM_Consts.RECORD_TYPE_BUSINESS_RULE AND SVMXC__Rule_Type__c = :SFM_Consts.RULE_TYPE_FIELD_UPDATE_RULE ]);
            }
            
            if( !fieldUpdateRuleProcessMap.isEmpty() ) {
                
                System.debug( LoggingLevel.DEBUG, 'SFM_GetFieldUpdateRuleInfo() : Fetching details for Field Update Rules. length = ' + fieldUpdateRuleProcessMap.size() );
                
                /* Retrieve Field Update details for requested process IDs. */
                Map<String, SVMXC.SFM_WrapperDef.SFM_FieldUpdateRuleInfo> fieldUpdateRuleInfoMap = new Map<String, SVMXC.SFM_WrapperDef.SFM_FieldUpdateRuleInfo>();
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                for( SVMXC__ServiceMax_Config_Data__c fieldUpdateDetail : [ SELECT Id, SVMXC__Expression_Rule__c, SVMXC__Expression_Type__c, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Display_Type__c, SVMXC__Formula__c, SVMXC__Action_Type__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Expression_Rule__c IN :fieldUpdateRuleProcessMap.keySet() AND RecordType.Name = :SFM_Consts.RECORD_TYPE_FIELD_UPDATES AND SVMXC__Expression_Type__c = :SFM_Consts.EXPRESSION_TYPE_FIELD_UPDATE_RULE ORDER BY SVMXC__Sequence__c] ) {

                    /* Populate FieldUpdateRuleInfo map from retrieved Field Update Rule records. */
                    if( fieldUpdateRuleProcessMap.containsKey(fieldUpdateDetail.SVMXC__Expression_Rule__c) ) {
                        
                        if( !fieldUpdateRuleInfoMap.containsKey( fieldUpdateDetail.SVMXC__Expression_Rule__c ) ) {                                
                            fieldUpdateRuleInfoMap.put( fieldUpdateDetail.SVMXC__Expression_Rule__c, new SVMXC.SFM_WrapperDef.SFM_FieldUpdateRuleInfo() );    
                        }
                        
                        fieldUpdateRuleInfoMap.get( fieldUpdateDetail.SVMXC__Expression_Rule__c ).fieldUpdateRule = fieldUpdateRuleProcessMap.get( fieldUpdateDetail.SVMXC__Expression_Rule__c );
                        fieldUpdateRuleInfoMap.get( fieldUpdateDetail.SVMXC__Expression_Rule__c ).fieldUpdateRuleDetails.add( fieldUpdateDetail );
                    } else {
                        System.debug( LoggingLevel.ERROR, 'SFM_GetFieldUpdateRuleInfo() : No Field Update Rule exists for detail ' + fieldUpdateDetail.SVMXC__Expression_Rule__c );
                    }
                }
                
                System.debug( LoggingLevel.DEBUG, 'SFM_GetFieldUpdateRuleInfo() : Updating response object with Field Update Rule Info.');
                /* Populate response with retrieved Field Update Rule process & details. */
                response.fieldUpdateRuleInfoList.addAll( fieldUpdateRuleInfoMap.values() );
            } else {
                System.debug( LoggingLevel.INFO, 'SFM_GetFieldUpdateRuleInfo() : No Field Update Rules found.');
            }            
        }
        
        catch( QueryException ex ) {
        
            System.debug( LoggingLevel.ERROR, 'SFM_GetFieldUpdateRuleInfo() : Failed to retrieve Field Update rules Details.' + ex.getStackTraceString() );
                    
            response.success = false;
            response.message = System.Label.SFM001_TAG504;
        }
        
        catch( exception ex ) {
            
            System.debug( LoggingLevel.ERROR, 'SFM_GetFieldUpdateRuleInfo() : Failed to retrieve Field Update rules Details.' + ex.getStackTraceString() );
            
            response.success = false;
            response.message = System.Label.SFM001_TAG504;
        }
        
        System.debug(LoggingLevel.DEBUG, 'SFM_GetFieldUpdateRuleInfo() - exit; response: ' + response );
        return response;
    }
    
    /**
     * This method is used to save Field Update Rule and Field Update details. The fieldUpdateRuleInfoList must be 
     * populated with process and config data object which needs to be saved.
     * 
     * @param request SFM_WrapperDef.SFM_Request object instance with list of FieldUpdateRuleInfo which needs to be saved.
     * @return Returns SFM_WrapperDef.SFM_Response object instance with list of SFM_WrapperDef.SFM_FieldUpdateRuleInfo.
     */
    public SVMXC.SFM_WrapperDef.SFM_Response SFM_SaveFieldUpdateRules( SVMXC.SFM_WrapperDef.SFM_Request request ) {
        
        System.debug(LoggingLevel.DEBUG, 'SFM_SaveFieldUpdateRules() - enter; request: ' + request );
        
        SVMXC.SFM_WrapperDef.SFM_Response response = new SVMXC.SFM_WrapperDef.SFM_Response();
        response.success = true;
        
        Map<String, SVMXC__ServiceMax_Processes__c> fieldUpdateRuleProcessIdMap = new Map<String, SVMXC__ServiceMax_Processes__c>();
        Map<String, List<SVMXC__ServiceMax_Config_Data__c>> fieldUpdateRuleDetailMap = new Map<String, List<SVMXC__ServiceMax_Config_Data__c>>();
        
        /* Retrieve record type Business Rule for ServiceMax Process and Field Updates for ServiceMax Config Data. */
        Map<String,RecordType> recordTypeMap = buildRecordTypeMap();
        
        RecordType fieldUpdateRecordType = recordTypeMap.get( SFM_Consts.RECORD_TYPE_FIELD_UPDATES );
        RecordType businessRuleRecordType = recordTypeMap.get( SFM_Consts.RECORD_TYPE_BUSINESS_RULE );
        
        /* validate record type existence. */
        if( fieldUpdateRecordType == null || businessRuleRecordType == null ) {
            
            response.success = false;
            response.message = 'Failed to retrieve record type ' + SFM_Consts.RECORD_TYPE_FIELD_UPDATES + '/' + SFM_Consts.RECORD_TYPE_BUSINESS_RULE;
            
            System.debug( LoggingLevel.ERROR, 'SFM_SaveFieldUpdateRules() : Field Update/Business Rule RecordType not exists.');
            
            return response;
        }
        
        /* Validate and process request. */
        List<String> newProcessIdList = new List<String>();        
        if( request != null && request.fieldUpdateRuleInfoList != null && !request.fieldUpdateRuleInfoList.isEmpty() ) {
            
            for( SVMXC.SFM_WrapperDef.SFM_FieldUpdateRuleInfo fieldUpdateRuleInfo : request.fieldUpdateRuleInfoList ) {
                
                if( fieldUpdateRuleInfo != null && fieldUpdateRuleInfo.fieldUpdateRule != null && fieldUpdateRuleInfo.fieldUpdateRuleDetails != null && !fieldUpdateRuleInfo.fieldUpdateRuleDetails.isEmpty() ) {
                    
                    if( ! fieldUpdateRuleProcessIdMap.containsKey( fieldUpdateRuleInfo.fieldUpdateRule.SVMXC__ProcessID__c ) ) {
                        
                        /* Set Field_Update_Rule as Rule type if not exists. */
                        if( fieldUpdateRuleInfo.fieldUpdateRule.SVMXC__Rule_Type__c == null ) {
                            
                            System.debug( LoggingLevel.INFO, 'SFM_SaveFieldUpdateRules() : Updating Rule Type with ' + SFM_Consts.RULE_TYPE_FIELD_UPDATE_RULE );
                            fieldUpdateRuleInfo.fieldUpdateRule.SVMXC__Rule_Type__c = SFM_Consts.RULE_TYPE_FIELD_UPDATE_RULE;    
                        }                            
                        
                        /* Validate Field Update Rule and Field Update Rule detail records. If successfully validated,
             * populate Field Update Rule and Field Update Rule detail maps.*/
                        if( validateFieldUpdateRule( fieldUpdateRuleInfo.fieldUpdateRule, fieldUpdateRuleInfo.fieldUpdateRuleDetails, response ) ) {
                            
                            fieldUpdateRuleInfo.fieldUpdateRule.RecordTypeId = businessRuleRecordType.Id;
                            fieldUpdateRuleProcessIdMap.put( fieldUpdateRuleInfo.fieldUpdateRule.SVMXC__ProcessID__c, fieldUpdateRuleInfo.fieldUpdateRule );
                            fieldUpdateRuleDetailMap.put( fieldUpdateRuleInfo.fieldUpdateRule.SVMXC__ProcessID__c, fieldUpdateRuleInfo.fieldUpdateRuleDetails );    
                            /* Populate new record process IDs which is later used to verify duplicate 
               * process ID records.*/
                            if( fieldUpdateRuleInfo.fieldUpdateRule.Id == null ) {
                                newProcessIdList.add(fieldUpdateRuleInfo.fieldUpdateRule.SVMXC__ProcessID__c);
                            }    
                        } else {
                            response.success = false;
                            System.debug( LoggingLevel.ERROR, 'SFM_SaveFieldUpdateRules() : Process validation failed. Message: ' + response.message );
                            break;
                        }
                    }                       
                } else {
                    response.success = false;
                    response.message = System.Label.SFM001_TAG350;
                    
                    System.debug( LoggingLevel.ERROR, 'SFM_SaveFieldUpdateRules() : Null/Empty process/details in request.');
                }
            }
        } else {
            
            response.success = false;
            response.message = System.Label.SFM001_TAG350;
            
            System.debug( LoggingLevel.ERROR, 'SFM_SaveFieldUpdateRules() : Null/Empty request.');
        }
        
        /* If successfully validated the process to save the rules. */
        if( response.success ) {
            
            /* Check for duplicate process IDs before saving new Field Update Rules. */ 
            if( hasDuplicateProcessID( newProcessIdList ) ) {
                
                response.success = false;
                response.message = System.Label.SFM001_TAG347;
                
                System.debug( LoggingLevel.ERROR, 'SFM_SaveFieldUpdateRules() : One or more processes which requested to save has duplicate ProcessID.');
            } else if( !fieldUpdateRuleProcessIdMap.isEmpty() ) {
                
                /* Set save point, which will be used to rollback when DML operations are 
         * failed to save field update rule or field update rule details.
         */
                Savepoint sp = Database.setSavepoint();
                
                try {                    
                    upsert fieldUpdateRuleProcessIdMap.values();
                    
                    /* Create Id vs ServiceMax Process record map, Which is used to retrieve details for each processes. */
                    Map<Id,SVMXC__ServiceMax_Processes__c> createdFieldUpdateRuleMap = new Map<Id,SVMXC__ServiceMax_Processes__c>();
                    createdFieldUpdateRuleMap.putAll( fieldUpdateRuleProcessIdMap.values() );
                    
                    List<Id> existingDetailIdList = new List<Id>();
                    List<SVMXC__ServiceMax_Config_Data__c> fieldUpdateRuleDetailList = new List<SVMXC__ServiceMax_Config_Data__c>();
                    for( SVMXC__ServiceMax_Processes__c fieldUpdateRule : createdFieldUpdateRuleMap.values() ) {
                        
                        /* For each process, retrieve detail record and update process ID in Expression_Rule field. Also,
             * Set Expression_Type = Field_Update_Rule and RecordType = Field Updates*/
                        List<SVMXC__ServiceMax_Config_Data__c> requestFieldUpdateRuleDetailList = fieldUpdateRuleDetailMap.get(fieldUpdateRule.SVMXC__ProcessID__c);
                        for( SVMXC__ServiceMax_Config_Data__c fieldUpdateRuleDetail : requestFieldUpdateRuleDetailList ) {
                            
                            if( fieldUpdateRuleDetail.SVMXC__Action_Type__c == null ) {
                                fieldUpdateRuleDetail.SVMXC__Action_Type__c = SFM_Consts.ACTION_TYPE_SET_VALUE;
                            }
                            
                            fieldUpdateRuleDetail.RecordTypeId = fieldUpdateRecordType.Id;
                            fieldUpdateRuleDetail.SVMXC__Expression_Type__c = SFM_Consts.EXPRESSION_TYPE_FIELD_UPDATE_RULE;
                            fieldUpdateRuleDetail.SVMXC__Expression_Rule__c = fieldUpdateRule.Id;
                            
                            fieldUpdateRuleDetailList.add( fieldUpdateRuleDetail );
                            
                            if( isValidateFieldValue( fieldUpdateRuleDetail.Id ) ) {
                                existingDetailIdList.add( fieldUpdateRuleDetail.Id );
                            }
                        }
                    }
                    
                    if( existingDetailIdList.isEmpty() ) {
                        /* Delete existing detail records and create new detail records.*/
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                      delete [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE Recordtype.Name = :SFM_Consts.RECORD_TYPE_FIELD_UPDATES AND SVMXC__Expression_Type__c = :SFM_Consts.EXPRESSION_TYPE_FIELD_UPDATE_RULE AND SVMXC__Expression_Rule__c IN :createdFieldUpdateRuleMap.keySet() ];                
                    } else {
                      /* Delete existing detail records and create new detail records.*/
                      //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                      delete [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE Recordtype.Name = :SFM_Consts.RECORD_TYPE_FIELD_UPDATES AND SVMXC__Expression_Type__c = :SFM_Consts.EXPRESSION_TYPE_FIELD_UPDATE_RULE AND SVMXC__Expression_Rule__c IN :createdFieldUpdateRuleMap.keySet() AND ID NOT IN :existingDetailIdList ];                    
                    }
                    
                    
                    if( !fieldUpdateRuleDetailList.isEmpty() ) {
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        upsert fieldUpdateRuleDetailList;    
                    }
                    
                    response.success = true;
                    response.message = System.Label.SFM001_TAG349;
                    
                    /* Populate response with newly created process and detail records. */
                    for( String processId : fieldUpdateRuleProcessIdMap.keySet() ) {
                        
                        SVMXC.SFM_WrapperDef.SFM_FieldUpdateRuleInfo info = new SVMXC.SFM_WrapperDef.SFM_FieldUpdateRuleInfo();
                        info.fieldUpdateRule = fieldUpdateRuleProcessIdMap.get(processId);
                        info.fieldUpdateRuleDetails.addAll( fieldUpdateRuleDetailMap.get(processId) );
                        
                        response.fieldUpdateRuleInfoList.add( info );    
                    }                
                }
                
                catch( QueryException ex ) {
                    
                    System.debug( LoggingLevel.ERROR, 'SFM_SaveFieldUpdateRules() : Failed to Save Field Update Rule.' + ex.getStackTraceString() );
                    
                    Database.rollback( sp );
                    
                    response.success = false;
                    response.message = System.Label.SFM001_TAG016;
                }
                
                catch( DMLException ex ) {
                    
                    System.debug( LoggingLevel.ERROR, 'SFM_SaveFieldUpdateRules() : Failed to Save Field Update Rule.' + ex.getStackTraceString() );
                    
                    Database.rollback( sp );
                    
                    response.success = false;
                    response.message = System.Label.SFM001_TAG505 + fieldUpdateRuleProcessIdMap.keySet();
                }
                
                catch( Exception ex ) {
                    
                    System.debug( LoggingLevel.ERROR, 'SFM_SaveFieldUpdateRules() : Failed to Save Field Update Rule.' + ex.getStackTraceString() );
                    
                    Database.rollback( sp );
                    
                    response.success = false;
                    response.message = System.Label.SFM001_TAG505 + fieldUpdateRuleProcessIdMap.keySet();
                }
            }
        }        
        
        System.debug(LoggingLevel.DEBUG, 'SFM_SaveFieldUpdateRules() - exit; response: ' + response );
        return response;
    }
    
    /**
     * This method is used to identify duplicate process ID existance in ServiceMax Process 
     * for given list of ProcessID'd. The validation is done only for recordtype 'Business Rule'.
     * 
     * @param idList List of ProcessIDs to be validated against ServiceMax Process records.
     * @Return Returns true if duplicate ProcessID found in existing Business Rule process, 
     *     Otherwise, return false.
     */
    private Boolean hasDuplicateProcessID( List<String> idList ) {
        
        Boolean hasDuplicate = false;
        if( idList != null && !idList.isEmpty() ) {
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            List<SVMXC__ServiceMax_Processes__c> duplicateProcessList = [ SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE Recordtype.Name = :SFM_Consts.RECORD_TYPE_BUSINESS_RULE AND SVMXC__ProcessID__c IN :idList];
            if( !duplicateProcessList.isEmpty() ) {
                hasDuplicate = true;
            }
        }
        return hasDuplicate;
    }
    
    /**
     * This method is used to perform field level validations.
     */
    private Boolean validateFieldUpdateRule( SVMXC__ServiceMax_Processes__c fieldUpdateRule, List<SVMXC__ServiceMax_Config_Data__c> fieldUpdateRuleDetailList, SVMXC.SFM_WrapperDef.SFM_Response response ) {
        
        Boolean isValid = true;
        if( fieldUpdateRule != null ) {
            
            if( !isValidateFieldValue( fieldUpdateRule.SVMXC__Name__c ) ) {
                isValid = false;
        response.message = System.Label.SFM001_TAG496;                
            } else if( !isValidateFieldValue( fieldUpdateRule.SVMXC__ProcessID__c ) ) {
                isValid = false;
                response.message = System.Label.SFM001_TAG498;
            } else if( !isValidateFieldValue( fieldUpdateRule.SVMXC__Source_Object_Name__c ) ) {
                isValid = false;
                response.message = System.Label.SFM001_TAG037;
            } else if( !isValidateFieldValue( fieldUpdateRule.SVMXC__Rule_Type__c ) || !fieldUpdateRule.SVMXC__Rule_Type__c.equalsIgnoreCase( SFM_Consts.RULE_TYPE_FIELD_UPDATE_RULE ) ) {
                isValid = false;
                response.message = System.Label.SFM002_TAG077 + '[SVMXC__Rule_Type__c] = ' + fieldUpdateRule.SVMXC__Rule_Type__c;
            }
            
            /* Validate process name length. Name must be less than or equal to 255 characters.*/
            if( isValidateFieldValue( fieldUpdateRule.SVMXC__Name__c ) ) {
                
                if( fieldUpdateRule.SVMXC__Name__c.length() > SFM_Consts.MAX_TEXT_LENGTH ) {
                    
                    isValid = false;
                    response.message = System.Label.SFM001_TAG497;
                }    
            }
            
            /* Validate ProcessID length. ProcessID must be less than or equal to 50 characters.*/
            if( isValidateFieldValue( fieldUpdateRule.SVMXC__ProcessID__c ) ) {
                
                if( fieldUpdateRule.SVMXC__ProcessID__c.length() > SFM_Consts.MAX_PROCESSID_LENGTH ) {
                    
                    isValid = false;
                    response.message = System.Label.SFM001_TAG499;
                }    
            }
            
            /* Validate Field Update Rule detail fields. */
            if( fieldUpdateRuleDetailList != null && !fieldUpdateRuleDetailList.isEmpty() ) {
                
                for( SVMXC__ServiceMax_Config_Data__c fieldUpdateRuleDetail : fieldUpdateRuleDetailList ) {
                    
                    if( isValidateFieldValue( fieldUpdateRuleDetail.SVMXC__Expression_Rule__c ) && 
                        fieldUpdateRuleDetail.SVMXC__Expression_Rule__c != fieldUpdateRule.Id ) {
                        
                        isValid = false;
                    response.message = System.Label.SFM002_TAG077 + 'SVMXC__Expression_Rule__c = ' + fieldUpdateRuleDetail.SVMXC__Expression_Rule__c;
                    } else if( isValidateFieldValue( fieldUpdateRuleDetail.SVMXC__Action_Type__c ) &&
                        !fieldUpdateRuleDetail.SVMXC__Action_Type__c.equalsIgnoreCase( SFM_Consts.ACTION_TYPE_SET_VALUE ) && 
                        !fieldUpdateRuleDetail.SVMXC__Action_Type__c.equalsIgnoreCase( SFM_Consts.ACTION_TYPE_SET_ATTRIBUTE ) ) {
                        
                        isValid = false;
                    response.message = System.Label.SFM002_TAG077 + 'SVMXC__Action_Type__c = ' + fieldUpdateRuleDetail.SVMXC__Action_Type__c;
                    } else if( !isValidateFieldValue( fieldUpdateRuleDetail.SVMXC__Formula__c ) ) {
                        
                        isValid = false;
                        response.message = System.Label.SFM001_TAG500;
                    }
                }
            }
        }
        
        return isValid;
    }
    
    /**
     * This private method is used to validate field value.
     *
     * @param value String value to be validated.
     * @return Returns true if value is not null and not empty, Otherwise, returns false.
     */
    private Boolean isValidateFieldValue( String value ) {
        return ( value != null && value.trim().length() > 0 );
    }
    
    /**
     * This method is used to build record type name vs record type object.
     *
     * @return Map<String,RecordType> RecordType object instances for type 'Field Update Rule' & 'Business Rule'
     */
    private Map<String,RecordType> buildRecordTypeMap() {
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType WHERE ( SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name =: SFM_Consts.RECORD_TYPE_FIELD_UPDATES ) OR ( SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name =: SFM_Consts.RECORD_TYPE_BUSINESS_RULE ) ];
        Map<String,RecordType> recordTypeMap = new Map<String,RecordType>();
            
        for( RecordType type : recordTypeList ) {
            recordTypeMap.put( type.Name, type );
        }
        
        return recordTypeMap;        
    }
}