/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief The abstract class SPM_AbstractBatch which implements Database.Batchable interface has 
 * definitions for start, execute and finish methods. The derived class needs to implement 
 * all abstract methods to complete the batch successfully. This class is responsible for 
 * handling any exceptions, database rollback on error, audit logs and sending batch status 
 * summary report as email to admin.
 *
 *
 * @author Ramachandra Mohan
 * @version 15.59102
 * @since 2015
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       08 Oct 2015     Created.
 * 025119       Ramachandra Mohan       23 Nov 2015     Defect fix. Ignore null check for fields in expressions.
 *              Ramachandra Mohan       06 Jan 2016     Support for multiple calculation methods.
 *              Ramachandra Mohan       11 Feb 2016     Support for Object/Field Mapping.
 * 029867       Ramachandra Mohan       13 Apr 2016     Defect fix. Support for parent object criteria.
 * 019174       Ramachandra Mohan       20 Apr 2016     Workaround for Salesforce limitaions in Database.Stateful
 *              Soumyaranjan Pati       8th Dec 2017    Error fixes(Issue-042199).
 *              
 *****************************************************************************************************/

global abstract class SPM_AbstractBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    /**
     * @brief Private boolean instance variable to enable/disable field null check in where clause.
     */     
    private Boolean includeNullCheckInWhereClause = true;
    
    /**
     * @brief Private integer instance variable to hold number of records to be processed.
     */
    private Integer numberOfRecordsToProcess = null;
    
    /**
     * @brief Private instance integer variable to hold number of days from which records are 
     * qualified based of record created date. 
     * The value for this field will be retrieved fro the settings.
     */
    private Integer numberOfDaysToQualifyRecords = null;
    /**
     * @brief Private instance Boolean variable to hold trending value
     * The value for this field will be retrieved fro the settings.
     */
    public Boolean isTrendingEnabled=false;
    /**
     * @brief Private string instance variable to hold report specific where clause.
     */
    private Map<String,String> whereClauseMap = new Map<String,String>();
    
    /**
     * @brief Private string instance variable to hold report name for which this batch instance 
     * has been created.
     */
    private String reportName = null;
    
    /**
     * @brief Private ID instance variable to hold report process Id.
     */
    private Id processId = null;
    
    /**
     * @brief Private string instance variable to hold configured or user email address which is 
     * used to send email after batch finish.
     */
    private String emailOnSuccess;
    
    /**
     * @brief Private string instance variable to hold the configuration name. The configuration
     * name will be the servicemax config data record auto number.
     */    
    private String configurationName;
    
    /**
     * @brief Private string instance variable to hold the calculation method name.
     */
    private String calculationMethodName;
    
    /**
     * @brief Private string instance variable to hold order by clause which will be used in query.
     */
    private String orderBy;
    
    /**
     * @brief Private map instance variable to hold configured name and its calculation method
     * settings and criterias.
     */
    private Map<String, SPM_ConfigurationDefinition.CalculationMethod> calculationMethodMap = new Map<String, SPM_ConfigurationDefinition.CalculationMethod>();
    
    /**
     * @brief Private Map instance variable which maps field enum name and configured field API name.
     */
    private Map<String, String> SourceObjectFieldMap = null;
    
    /**
     * @brief Private Map instance variable which maps additional field enum name and configured 
     * field API name.
     */
    private Map<String, String> ConfiguredObjectFieldMap = new Map<String, String>();
    
    /**
     * @brief Private Map instance variable which maps source fields with configuration name.
     */
    private Map<String, Map<String, String>> metricsSourceFieldMap = new Map<String, Map<String, String>>();
    
    /**
     * @brief Private Map instance variable which maps configured fields with configuration name.
     */
    private Map<String, Map<String, String>> metricsConfiguredFieldMap = new Map<String, Map<String, String>>();
    
    /**
     * @brief Private set instance variable to have list of field API names used in expression.
     */
    private Set<String> expressionFieldList = new Set<String>();
    
    /**
     * @brief Private Map instance variable which maps expression rule and list of expressions 
     * associated with it.
     */
    private Map<String, List<SVMXC__ServiceMax_Config_Data__c>> ruleExpressionListMap = new Map<String, List<SVMXC__ServiceMax_Config_Data__c>>();

    /**
     * @brief Private Map instance variable to hold list of map detail records for each mapping.
     */
    private Map<String, List<SVMXC__ServiceMax_Config_Data__c>> mapIdConfigDataMap = new Map<String, List<SVMXC__ServiceMax_Config_Data__c>>();
    
    /**
     * @brief Private Map instance variabel to hold configured mapId for each SPM configuration.
     */
    private Map<String, String> configurationMappingMap = new Map<String, String>();
    
    /**
     * @brief Private map instance variable which maps expression rule and parent object criteria.
     */
    private Map<String, String> ruleExpressionCriteriaMap = new Map<String, String>();
        
    /**
     * @brief Private map instance variable which maps expression rule and advanced expression criteria.
     */
    private Map<String, String> advancedExpressionCriteriaMap = new Map<String, String>();
    
    /**
     * @brief Private SPM_Schema.Report enum instance to hold report type for which this batch 
     * instance has been created.
     */
    private final SPM_Schema.Report report;
    
    /**
     * @brief Private set instance variable to hold unique field API names which is used in start query.
     */
    private Set<String> uniqueFieldList = new Set<String>();
    
    /**
     * @brief Private set instance variable to hold field enum names which needs to be ignored while building 
     * field level null check in where clause.
     */
    private Set<String> ignoreNullCheckSet = new Set<String>();
    
    /**
     * @brief Private AuditLog instance variable to hold job log informations.
     */
    private AuditLog auditLogInfo = new AuditLog();
    
    /**
     * @brief Protected ServiceMax config data instance variable to hold the schedule informations.
     */
    protected SVMXC__ServiceMax_Config_Data__c scheduleData;
    
    /**
     * @brief Private COMM_Utils_ManageSettings instance variable which is used to retrieve setting values.
     */
    private SVMXC.COMM_Utils_ManageSettings commUtilsManageSettings = new SVMXC.COMM_Utils_ManageSettings();
    
    /*
     * @brief Private COMM_SVMXC_Utils4 instance variable which is used to parse expressions.
     */
    //private final COMM_SVMXC_Utils4 commUtils = new COMM_SVMXC_Utils4();
    
    /**
     * 
     */
    private SPM_Schema.ExpressionType parentExpressionType = null;
    public List<SVMXC__ServiceMax_Config_Data__c> lstserviceMaxConfigDataList;
    /**
     * 
     */
    private SPM_Schema.Field parentReferenceField = null;
    
    /**
     * Inner class to hold job log informations.
     */
    class AuditLog {
        
        /**
         * Integer instance variable to hold batch count.
         */
        Integer batchInProgress = 0;
        
        /**
         * Integer instance variable to hold total number of records processed.
         */
        Integer totalRecordsProcessed = 0; 
        
        /**
         * Boolean instance variable to hold batch execution status.
         */
        Boolean isSuccess = true;
        
        /**
         * Datetime instance variable to hold batch execution start date and time.
         */
        Datetime scheduleStartDateTime;
        
        /**
         * List of strings to hold apex job logs.
         */
        List<String> messageList = new List <String>();
        
        /**
         * Class constructor to create instance of this class.
         */
        public AuditLog() {}
        
        /**
         * This method is used to add info message to audit log.
         */
        public void addInfo( String message ) {
            
            message = '[Info] ' + message;
            log( message );
        }
        
        /**
         * This method is used to add error message to audit log.
         */
        public void addError( String message ) {
            
            this.isSuccess = false;
            message = '[Error] ' + message;
            log( message );
        }
        
        /**
         * Private method used to log message to audit log with timestamp.
         */
        private void log( String message ) {
            
            message = System.now() + ': ' + message;
            messageList.add( message );
        }
    }
    
    /**
     * @brief Global class constructor to create instance of this class.
     * 
     * @param report Enum report type for which the instance has been created.
     * @param scheduleData Schedule record information for this report.
     */
    global SPM_AbstractBatch( SPM_Schema.Report report, SVMXC__ServiceMax_Config_Data__c scheduleData ) {
        
        System.debug( LoggingLevel.DEBUG, 'SPM_AbstractBatch() - enter; report : ' + report );
        
        this.report = report;
        this.scheduleData = scheduleData;
        
        // Retrieve setting values for this report.
        initSettingValues();
        
        // Get default field configurations for this report.
        SourceObjectFieldMap = SPM_ConfigurationDefinition.getSourceObjectFieldMap( report );        
    }
    
    protected void parseConfigurationsAndIdenitifyNotNullFields(SPM_Schema.Field fieldName) {
        System.debug( LoggingLevel.DEBUG, 'SPM_AbstractBatch.parseConfigurationsAndIdenitifyNotNullFields() - enter' );
        for( String calculationMethodName : calculationMethodMap.keySet() ) {
              
          System.debug( LoggingLevel.DEBUG, 'calculationMethodName: ' + calculationMethodName ); 
            
            Map<String, String> sourceObjectFieldMap = SPM_ConfigurationDefinition.getSourceObjectFieldMap( this.report);
            SPM_ConfigurationDefinition.CalculationMethod calculationMethod = calculationMethodMap.get(calculationMethodName);
                
            for( SPM_ConfigurationDefinition.ParameterInfo parameterInfo : calculationMethod.parameterInfoList ) {
                if(fieldName == parameterInfo.sourceObjectField) {
                    System.debug(LoggingLevel.DEBUG, 'Ignore field - ' + parameterInfo.sourceFieldName);
                    addIgnoreNullCheckField(parameterInfo.sourceFieldName);
                }   
            }
        }
            System.debug( LoggingLevel.DEBUG, 'SPM_AbstractBatch.parseConfigurationsAndIdenitifyNotNullFields() - exit' );
    }
    
    /**
     * @brief Abstract method to handle any additional configurations on batch start.
     */
    global abstract void initBatchConfiguration();
    
    /**
     * @brief Abstract method to process records on execute method call.
     * 
     * @param records List of records to be processed.
     */
    global abstract void handleRecords( List<SObject> records );
    
    /**
     * @brief Abstrach method to handle batch finish.
     */
    global abstract void onFinishComplete();
        
    /**
     * @brief Override method called by executeBatch method when the batch is initiated.
     * 
     * @param batchContext Database.BatchableContext instance.
     * @returns Returns Database.QueryLocator instance.
     */
    global Database.QueryLocator start( Database.BatchableContext batchContext ) {
        
        System.debug( LoggingLevel.DEBUG, report + ' start() - enter' );
        
        // Capturing batch start time for audit purpose.
        if( auditLogInfo.scheduleStartDateTime == null ) {
            auditLogInfo.scheduleStartDateTime = System.now();    
        }
        
        Database.QueryLocator locator = null;
        
        try {            
            /*
             * Initialize configured calculation method parameter and expression details.
             */
            initConfiguration();
            auditLogInfo.addInfo( 'Batch start for report ' + getReportName() );
            
            /*
             * Callback method to perform report specific additional configurations.
             * Derived class can disable null check where clause, add additional where clauses etc.
             */
            initBatchConfiguration();
            
            // Check for number of qualified records to be processed.
            if( getTotalRecordsToProcess() == 0 ) {                
                auditLogInfo.addInfo( 'No records to process the batch.');                
            } 
                
            /*
             * Build query and get the query locator. Only single query can be executed in this start method. 
             * TODO To handle with multiple objects, override other start method which returns Iterator.
             */
            String queryString = buildSelectQuery();
            System.debug( LoggingLevel.DEBUG, queryString );
            
            locator = Database.getQueryLocator( queryString );
            auditLogInfo.addInfo( 'Batch start executed successfully.');
            
            if( scheduleData != null ) {
                scheduleData.SVMXC__Previous_Execution_Started_On__c = System.now();
            }            
        }
        
        catch( QueryException ex ) {
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
            auditLogInfo.addError( 'Batch No : ' + auditLogInfo.batchInProgress + '; Exception ' + ex.getMessage() ); 
        }
        
        catch( Exception ex ) {
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
            auditLogInfo.addError( 'Batch No : ' + auditLogInfo.batchInProgress + '; Exception ' + ex.getMessage() );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, getReportName() + ' start() - exit' );
        }
        
        return locator;
    }
    
    /**
     * @brief This method is called by Database executeBatch method with batch of records.
     * 
     * @param batchContext Instance of Database.BatchableContext with job details.
     * @param records List of records to be processed for single batch.
     * 
     * @exception QueryException
     * @exception DMLException
     * @exception Exception
     */
    global void execute( Database.BatchableContext batchContext, List<SObject> records ) {
        
        System.debug( LoggingLevel.DEBUG, getReportName() + ' execute() - enter' );
        
        // Check for valid records to be processed. Just to avoide calls from unknown resources. 
        if( records == null || records.isEmpty() ) {
            
            System.debug( LoggingLevel.ERROR, 'execute call with invalid records. records: ' + records );
            auditLogInfo.addError( 'No records exists to process.');
            return;
        }
        
        // Populate batch execute summary informations.
        auditLogInfo.batchInProgress++; 
        auditLogInfo.totalRecordsProcessed += records.size();
        
        auditLogInfo.addInfo( 'Batch execute : ' + auditLogInfo.batchInProgress );
        if(getSourceObjectName() != SPM_Consts.SERVICEMAX_PROCESS) {
            //This message is invalid for summary computation.
            auditLogInfo.addInfo( 'Number of records to be processed : ' + records.size() ); 
        }
        
        
        // Create save point to handle data rollback on exceptions.
        SavePoint executeSavePoint = Database.setSavepoint();
        
        try {
            
            COMM_SVMXC_Utils4 commUtils = new COMM_SVMXC_Utils4();
            
            for( String key: calculationMethodMap.keySet() ) {
            
                configurationName = key;
                SPM_ConfigurationDefinition.CalculationMethod calculationMethod = calculationMethodMap.get( configurationName );
                SourceObjectFieldMap = metricsSourceFieldMap.get( configurationName );
                ConfiguredObjectFieldMap = metricsConfiguredFieldMap.get( configurationName );
                calculationMethodName = calculationMethod.method;
                
                System.debug( LoggingLevel.DEBUG, 'Processing records for configuration: ' + configurationName );
                
                List<SObject> filteredList = new List<SObject>();
                List<SVMXC__ServiceMax_Config_Data__c> expressionList = getRuleExpressionList( SPM_Schema.ExpressionType.QualificationCriteria );
                String advancedExpression = getAdvancedExpressionCriteria( SPM_Schema.ExpressionType.QualificationCriteria );
                
                for( SObject record : records ) {
                    
                    Boolean qualified = true;
                    for( String fieldApiName : SourceObjectFieldMap.values() ) {
                        
                        if( fieldApiName.toUpperCase().indexOf('SELECT ') != -1 
                            || fieldApiName == SPM_Consts.NONE || fieldApiName == SPM_Consts.REPEAT_VISIT_ADDITIONAL_COMPARISION_FIELD) {
                            continue;    
                        }
                        
                        if( includeNullCheckInWhereClause && !ignoreNullCheckSet.contains(fieldApiName) && getSourceObjectFieldValue( record, fieldApiName ) == null ) {
                            
                            qualified = false;
                            break;
                        }
                    }
                    
                    System.debug(LoggingLevel.DEBUG, 'Processing record: ' + record );
                    
                    if( qualified && commUtils.SVMX_ExpressionParsing( record, expressionList, advancedExpression ) ) {
                        filteredList.add( record );
                    }    
                }
                
                //Callback method to handle records to generate SPM report data.
                handleRecords( filteredList );
            }
            
            auditLogInfo.addInfo( 'Batch execute :' + auditLogInfo.batchInProgress + ' executed successfully.'); 
        }
        
        catch( QueryException ex ) {
            
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );            
            auditLogInfo.addError( 'Batch execute :' + auditLogInfo.batchInProgress + '; exception :' + ex.getMessage()); 
            
            Database.rollback( executeSavePoint );
        }
        
        catch( DMLException ex ) {
            
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
            auditLogInfo.addError( 'Batch execute :' + auditLogInfo.batchInProgress + '; exception :' + ex.getMessage()); 
            
            Database.rollback( executeSavePoint );
        }
        
        catch( Exception ex ) {
            
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );            
            auditLogInfo.addError( 'Batch execute :' + auditLogInfo.batchInProgress + '; exception :' + ex.getMessage());
            
            Database.rollback( executeSavePoint );
        }
        
        finally {
            
            auditLogInfo.addInfo( 'Batch execute completed.' );
            System.debug( LoggingLevel.DEBUG, getReportName() + ' execute() - exit' );
        }
    }
    
    /**
     * @brief This method is called by Database executeBatch on completion of all the record executions.
     * 
     * @param batchContext Instance of Database.BatchableContext with job details.
     */
    global void finish(Database.BatchableContext batchContext) {
        
        System.debug( LoggingLevel.DEBUG, getReportName() + ' finish() - enter' );
        
        auditLogInfo.addInfo( 'Batch finished' );
        
        if( scheduleData != null && scheduleData.Id != null ) {
            
            scheduleData.SVMXC__Previous_Execution_Completed_On__c = System.now();
            update scheduleData;    
        }
        
        // Callback method to handle finish in derived class.
        onFinishComplete();
        
        // Create auditlog and send status email to configured email or used email address.
        createAuditRecord();
        
        System.debug( LoggingLevel.DEBUG, getReportName() + ' finish() - exit' );
    }
    
    /**
     * @brief Protected method to get source object name used for this report.
     * 
     * @return Returns source object API name used for this report.
     */
    @TestVisible protected String getSourceObjectName() {
        return SPM_ConfigurationDefinition.REPORT_SOURCE_OBJECT_MAP.get(report.name());
    }
    
    /**
     * @brief Protected method to get report name.
     * 
     * @return Returns report name for which the report is generated.
     */
    @TestVisible protected String getReportName() {
        return reportName;
    }
    
    /**
     * @brief This method returns set of source object fields used in start query.
     * 
     * @return Returns set of field API names used in start query.
     */
    @TestVisible protected Set<String> getSourceFields() {
        return uniqueFieldList;
    }
    
    /**
     * @brief This method is used to retrieve expression criteria for given expression type.
     * 
     * @param expressionType Expression type for which criteria string to be retrieved.
     * 
     * @return Returns criteria string if exists, null otherwise.
     */
    @TestVisible protected String getExpressionCriteria( SPM_Schema.ExpressionType expressionType ) {
        return ruleExpressionCriteriaMap.get( configurationName + expressionType.name() );
    }
    
    /**
     * @brief This method is used to retrieve expression criteria for given expression type.
     * 
     * @param expressionTypeString Expression type for which criteria string to be retrieved.
     * 
     * @return Returns criteria string if exists, null otherwise.
     */
    @TestVisible protected String getExpressionCriteria( String expressionTypeString ) {
        return ruleExpressionCriteriaMap.get( expressionTypeString );
    }
    
    /**
     * @brief This method is used to retrieve advanced expression criteria for requested expression type.
     * 
     * @param expressionType Expression type for which advanced expression to be retrieved.
     * 
     * @return If exists, returns advanced expression criteria for requested expression type. Returns null otherwise.
     */
    @TestVisible protected String getAdvancedExpressionCriteria( SPM_Schema.ExpressionType expressionType ) {
        return advancedExpressionCriteriaMap.get( configurationName + expressionType.name() );
    }
    
    /**
     * @brief This method is used to check weather or not this report has expressions configured.
     * 
     * @return Returns true if expression rules are configured in this report, false otherwise.
     */
    @TestVisible protected Boolean hasRuleExpressions() {
        return !ruleExpressionListMap.isEmpty();
    }
    
    /**
     * @brief This method is used to retrieve list of expressions for requested expression type.
     * 
     * @param expressionType Expression type for which expressions to be retrieved.
     * 
     * @return Returns list of config data of type expression for given expression type if 
     * exists. Otherwise returns null.
     */
    @TestVisible protected List<SVMXC__ServiceMax_Config_Data__c> getRuleExpressionList( SPM_Schema.ExpressionType expressionType ) {
        return ruleExpressionListMap.get( configurationName + expressionType.name() );
    }
    
    /**
     * @brief This method is used to retrieve field enum vs field API name map.
     * 
     * @return Returns source object field map.
     */
    @TestVisible protected Map<String, String> getSourceObjectFieldMap() {
        return SourceObjectFieldMap;
    }
    
    /**
     * @brief This method is used to retrieve field enum vs field API name map for a given calculation method name.
     * 
     * @param methodName Calculation Method name for which source object field map to be retrieved.     * 
     * @return Returns source object field map.
     */
    @TestVisible protected Map<String, String> getSourceObjectFieldMap( String methodName ) {
        return metricsSourceFieldMap.get( methodName );
    }
    
    /**
     * @brief This method is used to retrieve configuration name for which the report is processing.
     * 
     * @return Returns configuration name.
     */
    @TestVisible protected String getConfigurationName() {
        return configurationName;
    }
    
    /**
     * @brief This method is used to retrieve calculation method name for which the report is processing.
     * 
     * @return Returns calculation method name.
     */
    @TestVisible protected String getCalculationMethodName() {
        return calculationMethodName;
    }
    
    /**
     * @brief This method is used to retrieve all configured calculation method names.
     * 
     * @return Returns set of calculation method names.
     */
    @TestVisible protected Set<String> getCalculationMethodNames() {
        return metricsSourceFieldMap.keySet();
    }
    
    /**
     * @brief This method is used to retrieve field API name for requested field enum name.
     * 
     * @param sourceObjectField Field enum name for which field API name to be retrieved.
     * 
     * @return If exists, returns field API name, Otherwise, returns null.
     */
    @TestVisible protected String getSourceObjectField( SPM_Schema.Field sourceObjectField ) {
        
        /*
         * Check field in source object field list, If not exists fetch from reference  
         * object field map.
         */
        if( SourceObjectFieldMap.containsKey( sourceObjectField.name() ) ) {
            return SourceObjectFieldMap.get( sourceObjectField.name() );    
        } else {
            return ConfiguredObjectFieldMap.get( sourceObjectField.name() );
        }
    }
    
    /**
     * @brief This method is used to retrieve report type of this instance.
     * 
     * @return Returns report type for which this class instance has been created.
     */
    @TestVisible protected SPM_Schema.Report getReport() {
        return report;
    }
     
    /**
     * @brief This method is used to retrieve field value form given sobject and field.
     * 
     * @param record SObject record from which the field to be retreived.
     * @param sourceObjectField Instance of SPM_Schema.Field to be retrieved from record.
     * 
     * @return Returns retrieved field value.
     */
    @TestVisible protected Object getSourceObjectFieldValue( SObject record, SPM_Schema.Field sourceObjectField ) {
        
        String sourceObjectFieldName = SourceObjectFieldMap.get( sourceObjectField.name() );
        
        if( sourceObjectFieldName == null && sourceObjectField == SPM_Schema.Field.Id ) {
            sourceObjectFieldName = SPM_Consts.RECORD_ID;
        }
        
        Object retValue = getSourceObjectFieldValue( record, sourceObjectFieldName );
        
        if( retValue == null ) {
            
            if( SourceObjectFieldMap.containsKey( SPM_Consts.MAPPING_PREFERENCE_2 + sourceObjectField.name() ) ) {
              retValue = getSourceObjectFieldValue( record, SourceObjectFieldMap.get( SPM_Consts.MAPPING_PREFERENCE_2 + sourceObjectField.name() ) );    
            }
            
            if( retValue == null && SourceObjectFieldMap.containsKey( SPM_Consts.MAPPING_PREFERENCE_3 + sourceObjectField.name() ) ) {
              retValue = getSourceObjectFieldValue( record, SourceObjectFieldMap.get( SPM_Consts.MAPPING_PREFERENCE_3 + sourceObjectField.name() ) );    
            }
        }
        
        return retValue;
    }
    
    /**
     * @brief This method is used to retrieve field value form given sobject and field. This method also handles 
     * fields names with multi level references.
     * 
     * @param record SObject record from which the field to be retreived.
     * @param sourceObjectFieldName Field name of which value to be retrieved from record.
     * 
     * @return Returns retrieved field value.
     */
    @TestVisible protected Object getSourceObjectFieldValue( SObject record, String sourceObjectFieldName ) {
        
        if( sourceObjectFieldName == null || record == null ) {
            return null;
        }
        
        Integer index = sourceObjectFieldName.indexOf('.');
        
        if( index == -1 ) {
            return record.get( sourceObjectFieldName );
        }
        
        String referrenceField = sourceObjectFieldName.substring( 0, index );
        sourceObjectFieldName = sourceObjectFieldName.substring( index + 1 );
        
        return getSourceObjectFieldValue( record.getSObject( referrenceField ), sourceObjectFieldName );
    }
    
    /**
     * @brief This method is used to set order by clause to query.
     * 
     * @param orderBy One or more field API names to be added in ORDER BY clause.
     */
    @TestVisible protected void setOrderBy( String orderBy ) {
        this.orderBy = orderBy;     
    }
    
    /**
     * @brief This method is used to set common where clause for all SPM configurations.
     * 
     * @param whereClause Where clause to be added to all SPM configurations.
     */
    @TestVisible protected void setWhereClause( String whereClause ) {
        
        for( String key : metricsSourceFieldMap.keySet() ) {
            setWhereClause( key, whereClause );
        }        
    }
    
    /**
     * @brief This method is used to set where clause to specific SPM configuration.
     * 
     * @param configurationName Configuration name for which where clause to be added.
     * @param whereClause Where clause to be added to specified SPM configuration.
     */
    @TestVisible protected void setWhereClause( String configurationName, String whereClause ) {
        System.debug( LoggingLevel.DEBUG, 'setWhereClause - enter()' + whereClause);
        System.debug( LoggingLevel.DEBUG, 'configurationName - ' + configurationName);
        System.debug( LoggingLevel.DEBUG, 'whereClause - ' + whereClause);

        this.whereClauseMap.put( configurationName, whereClause );
    }
    
    /**
     * @brief This method is used to build criteria with specified reference field.
     * 
     * @param expressionType Expression type for which field reference to be applied.
     * @param field Instance of SPM_Schema.Field from which reference field to be created.
     */
    @TestVisible protected String buildParentObjectCriteria( SPM_Schema.ExpressionType expressionType, SPM_Schema.Field field ) {
        
        String criteria = getExpressionCriteria( expressionType );
        return buildParentObjectCriteria( criteria, field );
    }
    
    /**
     * @brief This method is used to build criteria with specified reference field.
     *   @code 
     *     If the criteria is SVMXC__Name__c = 'Demo' & field is 'SVMXC__Work_Order__c' 
     *     then
     *     return value will be SVMXC__Work_Order__r.SVMXC__Name__c = 'Demo'
     *  @endcode
     *  
     * 
     * @param criteria Criteria for which field reference to be applied.
     * @param field Instance of SPM_Schema.Field from which reference field to be created.
     */
    @TestVisible protected String buildParentObjectCriteria( String criteria, SPM_Schema.Field field ) {
              
        String lookupField = getSourceObjectField( field );
        List<String> listStandardFieldNames = new List<String>();
        SObjectType lookUpObj = Schema.getGlobalDescribe().get(lookupField);
        try{
        Map<String,Schema.SObjectField> FieldMap = lookUpObj.getDescribe().fields.getMap();
            for (Schema.SObjectField f : FieldMap.values()) {
            Schema.DescribeFieldResult DescField = f.getDescribe();
            if(!DescField.getName().containsIgnoreCase('__c')){
            listStandardFieldNames.add(DescField.getName());
            }
        }
        }catch(Exception e){
            System.debug('Exception '+e);
        }
        if( criteria != null && lookupField != null ) {
            
            lookupField = lookupField.replace('__c', '__r.');
            
            String[] criteriaArray = criteria.split( SPM_Consts.SPACE );
            List<String> criteriaList = new List<String>();
            for( Integer index = 0; index < criteriaArray.size(); index++ ) {
                
                String token = criteriaArray[index];
                if( token.startsWithIgnoreCase( 'SVMXC__' ) || token.containsIgnoreCase('__c') || token.contains('RecordType') || standardFielddataPresentOrNot(listStandardFieldNames,token)) {
                    token = lookupField + token;
                }
                criteriaList.add(token);
            }
            criteria = SPM_Utilities.getInstance().buildString( criteriaList, SPM_Consts.SPACE );
        }
        return criteria;
    }
    public Boolean standardFielddataPresentOrNot(List<String> ListOfIDs,String IdToCompare){
        for(String IdToUse: ListOfIDs) {
           if(IdToCompare.startsWithIgnoreCase(IdToUse)) { 
           return true; 
           }
        }
    return false;
    }
    /**
     * @brief This method is used to add specified info message to audit log.
     * 
     * @param infoMessage Info message to be added to audit log.
     */
    @TestVisible protected void addInfo( String infoMessage ) {
       auditLogInfo.addInfo( infoMessage ); 
    }
    
    /**
     * @brief This method is used to app specified error message to audit log.
     * 
     * @param errorMessage Error message to be added to audit log.
     */
    @TestVisible protected void addError( String errorMessage ) {
       auditLogInfo.addError( errorMessage ); 
    }
    
    /**
     * @brief This method is used to add apecified record id & error message information to audit log.
     * 
     * @param sourceRecordId Record id on which the error occured.
     * @param errorMessage Error message to be added to audit log.
     */
    @TestVisible protected void addError( Id sourceRecordId, String errorMessage ) {
       auditLogInfo.addError( 'Record Id: ' + sourceRecordId + '; ' + errorMessage ); 
    }
    
    /**
     * @brief This method is used to update the count of total records processed
     * 
     * @param infoMessage Info message to be added to audit log.
     */
    @TestVisible protected void setTotalProcessedRecordsCount( Integer count ) {
       auditLogInfo.totalRecordsProcessed = count;
    }
    
    /**
     * @brief This method is used to enable/disable field level null check in where clause.
     * 
     * @param enabled Boolean value to enable/disable field level null check. By default, 
     *           null check on fields are enabled.
     */
    @TestVisible protected void setNullCheckInWhereClause( Boolean enabled ) {
        includeNullCheckInWhereClause = enabled;
    }
    
    /**
     * @brief This method is used to add specific fields to ignore null check list. 
     * @details This field will be ignored while building the where clause.
     * 
     * @param field Field to be ignored in where clause.
     * 
     * @see SPM_Schema
     */
    @TestVisible protected void addIgnoreNullCheckField( SPM_Schema.Field field ) {
        ignoreNullCheckSet.add( getSourceObjectField(field) );
    }
    
    /**
     * @brief This method is used to add specific field API name to ignore null check list. 
     * @details This field API name will be ignored while building the where clause.
     * 
     * @param fieldAPIName Field API name to be ignored in where clause.
     * 
     */
    @TestVisible protected void addIgnoreNullCheckField( String fieldAPIName ) {
        ignoreNullCheckSet.add( fieldAPIName );
    }
    
    /**
     * @brief This method is used to add collection of fields to ignore null check list. 
     * @details These fields will be ignored while building the where clause.
     * 
     * @param fieldList List of fields to be ignored in where clause.
     * 
     * @see SPM_Schema
     */
    @TestVisible protected void addIgnoreNullCheckField( List<SPM_Schema.Field> fieldList ) {
        
        if( fieldList != null && !fieldList.isEmpty() ) {
            for( SPM_Schema.Field field : fieldList ) {
                ignoreNullCheckSet.add( getSourceObjectField(field) );    
            }    
        }
    }
    
    /**
     * @brief This method is used to get number of days to qualify records for this report.
     * @details The number of days will be retrieved from the report specific settings.
     * 
     * @return If metric specific setting exists in org, then returns the number of days configured 
     * for this report from the setting, Otherwise, returns 0.
     */
    @TestVisible protected Integer getNumberOfDaysToQualifyRecords() {
        return numberOfDaysToQualifyRecords;
    }
    /**
     * @brief This method is used to get trending Enabled report for this report.
     * @details The boolean value will be retrieved from the report specific settings.
     * 
     * @return If metric specific setting exists in org, then returns the Boolean value configured 
     * for this report from the setting, Otherwise, returns false.
     */
    @TestVisible protected Boolean getTrendingEnabledValue() {
        return isTrendingEnabled;
    }
    
    /**
     * @brief This method is used to add additional fields to be quired in batch.
     * 
     * @param field Schema field reference for this new field.
     * @param fieldName field API name to be quired in batch.
     */
    @TestVisible protected void addQueryField( SPM_Schema.Field field, String fieldName ) {
        
        for( String key : metricsSourceFieldMap.keySet() ) {
            
            Map<String,String> sourceFieldMap = metricsSourceFieldMap.get(key);
            sourceFieldMap.put( field.name(), fieldName );
            uniqueFieldList.add(fieldName);
        }
    }
    
    /**
     * @brief This method is used to add additional fields to be quired in batch.
     * 
     * @param field Schema field reference for this new field.
     * @param fieldName field API name to be quired in batch.
     */
    @TestVisible protected void addQueryField( String field, String fieldName ) {
        
        for( String key : metricsSourceFieldMap.keySet() ) {
            
            Map<String,String> sourceFieldMap = metricsSourceFieldMap.get(key);
            sourceFieldMap.put( field, fieldName );
            uniqueFieldList.add(fieldName);
        }
    }
    
    /**
     * @brief This method is used to get the count of qualified records.
     * 
     * @return Returns qualified record count.
     */
    @TestVisible protected Integer getTotalRecordsToProcess() {
        
        System.debug( LoggingLevel.DEBUG, 'getTotalRecordsToProcess() - enter' );
        
        String sourceObjectName = getSourceObjectName();
        if( numberOfRecordsToProcess == null && sourceObjectName != null ) {
            
            String query = 'SELECT COUNT() FROM ' + sourceObjectName;
            String whereClause = buildWhereClause();
            if( whereClause != null && whereClause != '') {
                query = query + ' WHERE ' + whereClause;
            }
            
            query = query + ' LIMIT 45000';
            
            try {
                numberOfRecordsToProcess = Database.countQuery(query);
            }
            catch( QueryException ex ) {
                System.debug( LoggingLevel.ERROR, ex.getMessage() );
            }
        }
        
        System.debug( LoggingLevel.DEBUG, 'getTotalRecordsToProcess() - exit; record count: ' +  numberOfRecordsToProcess );
        
        return numberOfRecordsToProcess;
    }
    
    /**
     * 
     */
    @TestVisible protected Set<String> getMappingFields() {
        
        Set<String> mappingFieldSet = new Set<String>();
        String mapId = configurationMappingMap.get( getConfigurationName() );
        if( mapId != null ) {
            
            List<SVMXC__ServiceMax_Config_Data__c> mappingDetailsList = mapIdConfigDataMap.get( mapId );            
            
            if( mappingDetailsList != null ) {
                for( SVMXC__ServiceMax_Config_Data__c mappingData : mappingDetailsList ) {
                    mappingFieldSet.add( mappingData.SVMXC__Source_Field_Name__c );
                    if( mappingData.SVMXC__Preference_2__c != null ) {
                        mappingFieldSet.add( mappingData.SVMXC__Preference_2__c );
                        if( mappingData.SVMXC__Preference_3__c != null ) {
                            mappingFieldSet.add( mappingData.SVMXC__Preference_3__c );
                        }
                    }                    
                }    
            }
        }
        
        return mappingFieldSet;
    }
    /**
     * @brief This method is used to perform the field mapping on specified source id and target record.
     * 
     * @param sourceRecordId Source record Id from which field values are populated to target object.
     * @param targetRecord Target record to which values are populated from source object.
     */
    @TestVisible protected void performFieldMapping( Id sourceRecordId, SObject targetRecord ) {
        performFieldMapping( new List<Id> {sourceRecordId}, new List<SObject> {targetRecord} );
    }
    
    /**
     * @brief This method is used to perform the field mapping on specified source and target record.
     * 
     * @param sourceRecord Source record from which field values are populated to target object.
     * @param targetRecord Target record to which values are populated from source object.
     */
    @TestVisible protected void performFieldMapping( SObject sourceRecord, SObject targetRecord ) {
        performFieldMapping( new List<SObject> {sourceRecord}, new List<SObject> {targetRecord} );
    }
    
    /**
     * @brief This method is used to perform the field mapping on specified list of source record id's 
     * and list of target records.
     * 
     * @details The field mappings will be performed in same sequence as in the list.
     * 
     * @param sourceRecordIdList Source record Id list from which field values are populated to target object.
     * @param targetRecordList Target record list to which values are populated from source object.
     */
    @TestVisible protected void performFieldMapping( List<Id> sourceRecordIdList, List<SObject> targetRecordList ) {
        
        System.debug( LoggingLevel.DEBUG, 'performFieldMapping() - enter' );
        
        String mapId = configurationMappingMap.get( getConfigurationName() );
        if( mapId != null ) {
            
            List<SVMXC__ServiceMax_Config_Data__c> mapDetailList = mapIdConfigDataMap.get( mapId );
            if( mapDetailList != null && !mapDetailList.isEmpty() ) {
                
                Map<String,Sobject> sourceRecIdTargetObjMap = new Map<String,Sobject>();                
                for( Integer i = 0; i < sourceRecordIdList.size(); i++ ) {
                  sourceRecIdTargetObjMap.put(sourceRecordIdList[i],  targetRecordList[i]);    
                }
                
                String sourceObjectName = mapDetailList.get(0).SVMXC__MapID__r.SVMXC__Source_Object_Name__c;
                String targetObjectName = mapDetailList.get(0).SVMXC__MapID__r.SVMXC__Target_Object_Name__c;
                String mapSFID =  mapDetailList.get(0).SVMXC__MapID__c;
                
                Map<String,Schema.SObjectType> sobjectTypeMap = new Map<String,Schema.SObjectType> {
                    sourceObjectName  => SPM_Utilities.getInstance().getGlobalDescribe( sourceObjectName ),
                    targetObjectName  => SPM_Utilities.getInstance().getGlobalDescribe( targetObjectName )
                };          
                            
                SFM_ApplyMapping applyMapping = new SFM_ApplyMapping();                                
                applyMapping.applyMappingForDetail( mapSFID, sourceRecIdTargetObjMap, false, sobjectTypeMap, sourceObjectName, targetObjectName, mapDetailList, null);
            }
        }
        System.debug( LoggingLevel.DEBUG, 'performFieldMapping() - exit' );
    }
    
    /**
     * @brief This method is used to perform the field mapping on specified list of source 
     * and target records.
     * 
     * @details The field mappings will be performed in same sequence as in the list.
     * 
     * @param sourceRecordList Source record list from which field values are populated to target object.
     * @param targetRecordList Target record list to which values are populated from source object.
     */
    @TestVisible protected void performFieldMapping( List<SObject> sourceRecordList, List<SObject> targetRecordList ) {
        
        System.debug( LoggingLevel.DEBUG, 'performFieldMapping() - enter' );
        
        String mapId = configurationMappingMap.get( getConfigurationName() );
        if( mapId != null ) {
            
            List<SVMXC__ServiceMax_Config_Data__c> mapDetailList = mapIdConfigDataMap.get( mapId );
            if( mapDetailList != null && !mapDetailList.isEmpty() ) {
                
                Map<String,Sobject> sourceRecIdTargetObjMap = new Map<String,Sobject>();
                Integer index = 0;
                for( SObject sourceRecord : sourceRecordList ) {
                  sourceRecIdTargetObjMap.put(sourceRecord.Id,  targetRecordList[index++]);    
                }
                
                String sourceObjectName = mapDetailList.get(0).SVMXC__MapID__r.SVMXC__Source_Object_Name__c;
                String targetObjectName = mapDetailList.get(0).SVMXC__MapID__r.SVMXC__Target_Object_Name__c;
                String mapSFID =  mapDetailList.get(0).SVMXC__MapID__c;
                
                Map<String,Schema.SObjectType> sobjectTypeMap = new Map<String,Schema.SObjectType> {
                    sourceObjectName  => SPM_Utilities.getInstance().getGlobalDescribe( sourceObjectName ),
                    targetObjectName  => SPM_Utilities.getInstance().getGlobalDescribe( targetObjectName )
                };          
                            
                SFM_ApplyMapping applyMapping = new SFM_ApplyMapping();
                Map<String, SObject> sourceRecordMap = new Map<String, SObject>();
                sourceRecordMap.putAll( sourceRecordList );
                applyMapping.applyMappingForDetail( mapSFID, sourceRecIdTargetObjMap, false, sobjectTypeMap, sourceObjectName, targetObjectName, mapDetailList, null, sourceRecordMap );    
            }
        }
        System.debug( LoggingLevel.DEBUG, 'performFieldMapping() - exit' );
    }
    
    /**
     * 
     */
    @TestVisible protected void addParentObjectCriteria( SPM_Schema.ExpressionType parentExpressionType,  SPM_Schema.Field parentReferenceField ) {
        
        this.parentExpressionType = parentExpressionType;
        this.parentReferenceField = parentReferenceField;
    }
        
    /**
     * @brief Private method to create audit records and to send engine execution status email.
     */
    @TestVisible private void createAuditRecord() {
        
        System.debug( LoggingLevel.DEBUG, 'createAuditRecord() - enter');
        
        SVMXC__SVMX_Jobs__c objJob = new SVMXC__SVMX_Jobs__c();
        objJob.SVMXC__SVMX_Process__c = processId;
        objJob.SVMXC__Type__c = 'SPM Schedule';
        objJob.SVMXC__Start_Time__c = auditLogInfo.scheduleStartDateTime;
        objJob.SVMXC__End_Time__c = System.now();
        objJob.SVMXC__Batch_Job__c = getReportName();
        objJob.SVMXC__Status__c = ( auditLogInfo.isSuccess ) ? 'Success' : 'Failed';
        
        String message = SPM_Utilities.getInstance().buildString(auditLogInfo.messageList, '\n' );
         
        String summery = 'SPM Report Name            : ' + getReportName();
        summery += '\nBatch Execution Status     : ' + objJob.SVMXC__Status__c;
        summery += '\nNumber Of Batches          : ' + auditLogInfo.batchInProgress;
        summery += '\nNumber Of Records Processed: ' + auditLogInfo.totalRecordsProcessed;
        if( objJob.SVMXC__Start_Time__c != null ) {
            summery += '\nBatch Execution Time       : ' + (objJob.SVMXC__End_Time__c.getTime() - objJob.SVMXC__Start_Time__c.getTime())/1000 +' seconds';    
        }
        message = summery + '\n\n' + message;
        //objJob.SVMXC__Message__c = message;
        
        insert objJob;
        //Added for BAC-4043
        if(COMM_FileHandlerUtilities.checkFileSetting()){
            try{
                Id cvId = COMM_FileHandlerUtilities.insertOneContentVersion(COMM_FileHandlerUtilities.createContentVersionInstance(null,'SPM Schedule Logs.txt',message,null));
                List<Id> listContentVersionIds = new List<Id>();
                if(cvId != null){
                    listContentVersionIds.add(cvId);
                    Map<Id,Id> mapCVandCDids = new Map<Id,Id>();
                    mapCVandCDids = COMM_FileHandlerUtilities.getContentDocumentsId(listContentVersionIds);
                    ContentDocumentLink cdlInstance = COMM_FileHandlerUtilities.createContentDocumentLink(objJob.id,mapCVandCDids.get(cvId));
                    Id cdlId = COMM_FileHandlerUtilities.insertOneContentDocumentLink(cdlInstance);
                }
            }catch(Exception ex){
                System.debug('Error found creation of SPM file log '+ex.getMessage());
            }
        }else{
            Attachment objAttach = new Attachment();
            blob attachBlob = Blob.valueOf( message );
            objAttach.Body = attachBlob;
            objAttach.ParentId = objJob.id;
            objAttach.Name = 'SPM Schedule Logs.txt';
            insert objAttach;
        }
        //End BAC-4043
        

        if( emailOnSuccess != null ) {
            
            TimeZone tz = UserInfo.getTimeZone(); 
            
            Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();            
            //emailAttachment.setFileName( objAttach.Name ); //Added for BAC-4043
            //emailAttachment.setBody(attachBlob); //Added for BAC-4043
            emailAttachment.setFileName('SPM Schedule Logs.txt'); //Added for BAC-4043
            emailAttachment.setBody(Blob.valueOf( message )); //Added for BAC-4043
            
            Messaging.SingleEmailMessage singleEmailMessage =new Messaging.SingleEmailMessage();            
            singleEmailMessage.setSubject( getReportName() + ' ' + objJob.SVMXC__End_Time__c.format('MM/dd/yyyy HH:mm:ss', tz.getID() ) );
            singleEmailMessage.saveAsActivity = false;
            singleEmailMessage.setToAddresses(new List<String> {emailOnSuccess});
            singleEmailMessage.setPlainTextBody( summery );
            singleEmailMessage.setFileAttachments( new Messaging.EmailFileAttachment[]{emailAttachment} );
            
            List<Messaging.SingleEmailMessage> emailMessageList =  new List<Messaging.SingleEmailMessage> {
                singleEmailMessage    
            };
                        
            if( emailMessageList != null && emailMessageList.size() > 0 ) {
                try {
                    if( !Test.isRunningTest() ) {
                        Messaging.sendEmail( emailMessageList );    
                    }
                }
                catch( Exception ex ) {
                    
                    System.debug( LoggingLevel.ERROR, ex.getMessage() );
                    addInfo('ERROR: Failed to send notification email.');
                    addInfo(ex.getMessage());
                }
            }    
        }
        
        System.debug( LoggingLevel.DEBUG, 'createAuditRecord() - exit');
    }
    
    /**
     * @brief This method is used to build select query for the batch with all required fields and where clauses.
     * 
     * @details This method will build single query for all configured SPM configurations for this report. 
     * Below is the sample query created for FTF matric with two configuration (One with mapping).
     * 
     * @code
     * SELECT Id, Name, SVMXC__Preferred_Technician__c, SVMXC__Closed_On__c, SVMXC__Product__c, SVMXC__Company__c, SVMXC__Service_Group__c, SVMXC__Group_Member__c, SVMXC__Order_Status__c, SVMXC__Order_Type__c, SVMXC__Related_Work_Order__c, SVMXC__Related_Work_Order__r.Name, SVMXC__Country__c, SVMXC__Sub_Status__c 
     * FROM SVMXC__Service_Order__c 
   * WHERE ((CreatedDate >= 2015-03-10T03:35:57z) 
   *     AND (SVMXC__Order_Status__c='Completed' AND SVMXC__Order_Type__c='Field Service' 
   *     AND SVMXC__Related_Work_Order__r.Name = null AND SVMXC__Country__c='United States') 
   *     AND (Id != null AND Name != null AND (SVMXC__Preferred_Technician__c != null OR SVMXC__Group_Member__c != null) 
   *     AND SVMXC__Closed_On__c != null AND SVMXC__Product__c != null AND SVMXC__Company__c != null)) 
   * OR ((CreatedDate >= 2015-03-10T03:35:57z) 
   *     AND (SVMXC__Order_Status__c='Completed' AND SVMXC__Order_Type__c='Field Service' 
   *     AND SVMXC__Related_Work_Order__r.Name = null AND SVMXC__Country__c='United Kingdom') 
   *     AND (Id != null AND Name != null AND SVMXC__Preferred_Technician__c != null 
   *     AND SVMXC__Closed_On__c != null AND SVMXC__Product__c != null AND SVMXC__Company__c != null))
     * 
     * @endcode
     * 
     * @returns Returns single select query for all configured SPM configurations for this metric.
     */
    @TestVisible private String buildSelectQuery() {
        
        String sourceObjectName = getSourceObjectName();
        
        if( sourceObjectName == null ) {
            
            System.debug( LoggingLevel.ERROR, 'Invalid Source Object name.' );
            return null;
        }
        
        String fields = stringValueOf( getSourceFields() );
        String query = 'SELECT ' + fields + ' FROM ' + sourceObjectName;
        
        String whereClause = buildWhereClause();
        if( whereClause != null && whereClause != '') {
            query = query + ' WHERE ' + whereClause;
        }
        
        if( orderBy != null && orderBy != '' ) {
            query = query + ' ORDER BY ' + orderBy;
        }
        
        if( reportName == null ) {
            query = query + ' LIMIT 1';
        }
        
        return query;
    }
    
    /**
     * @brief This method is used to create comma separated fields from the Set of field.
     * 
     * @param fieldSet Field API name Set from which comma separated string to be constructed.
     * 
     * @return Returns comma separated string for specified field set.
     */
    @TestVisible private String stringValueOf( Set<String> fieldSet ) {
        
        String fields = SPM_Consts.RECORD_ID;
        if( fieldSet != null ) {
            
            for( String fieldName : fieldSet ) {
                
                if( fieldName == null || fieldName == '' || fieldName == SPM_Consts.NONE 
                    || fieldName == SPM_Consts.REPEAT_VISIT_ADDITIONAL_COMPARISION_FIELD) {
                    continue;
                }
                    
                fields = fields + ', ' + fieldName;
            }    
        }
        return fields;
    }
    
    /**
     * @brief This method is used to build where clause for all configured SPM configurations for this metric.
     * 
     * @return Returns where clause for all configured SPM configurations for this metrics.
     */
    @TestVisible private String buildWhereClause() {
        System.debug( LoggingLevel.DEBUG, 'buildWhereClause() - enter');
        String retValue = '';
        
        for( String key : metricsSourceFieldMap.keySet() ) {
            
            String whereClause = whereClauseMap.get(key);
            String metricsClause = '';
            System.debug( LoggingLevel.DEBUG, 'whereClause - ' + whereClause);
            if( whereClause != null ) {            
                metricsClause = metricsClause + '(' +  whereClause + ')';
            }
            System.debug( LoggingLevel.DEBUG, 'key1 - ' + key);
            System.debug( LoggingLevel.DEBUG, 'SPM_Schema.ExpressionType.QualificationCriteria.name() - ' + SPM_Schema.ExpressionType.QualificationCriteria.name());
            String entryCriteria = getExpressionCriteria( key + SPM_Schema.ExpressionType.QualificationCriteria.name() );
            System.debug( LoggingLevel.DEBUG, 'entryCriteria1 - ' + entryCriteria);
            if( entryCriteria != null ) {
                
                if( metricsClause != '' ) {
                    metricsClause = metricsClause + ' AND ';
                }
                metricsClause = metricsClause + '(' + entryCriteria + ')';
            }
            
            if( parentExpressionType != null && parentReferenceField != null ) {
                System.debug( LoggingLevel.DEBUG, 'key - ' + key);
                System.debug( LoggingLevel.DEBUG, 'parentExpressionType.name() - ' + parentExpressionType.name());
                entryCriteria = getExpressionCriteria( key + parentExpressionType.name() );
                System.debug( LoggingLevel.DEBUG, 'entryCriteria - ' + entryCriteria);
                
                String additionalClause = buildParentObjectCriteria( entryCriteria, parentReferenceField );
                System.debug( LoggingLevel.DEBUG, 'additionalClause - ' + additionalClause);
                if( additionalClause != null ) {
                    
                    if( metricsClause != '' ) {
                        metricsClause = metricsClause + ' AND ';
                    }
                    metricsClause = metricsClause + '(' + additionalClause + ')';
                }      
            }
            
            if( includeNullCheckInWhereClause ) {
                
                if( metricsClause != '' ) {
                    metricsClause = metricsClause + ' AND ';
                }
                
                metricsClause = metricsClause + '(' + buildNullCheckWhereClause( metricsSourceFieldMap.get(key) ) + ')';
            }
            
            if( retValue != '' ) {
                retValue = retValue + ' OR ';
            }
            retValue = retValue + '(' + metricsClause + ')';
        }
        
        System.debug( LoggingLevel.DEBUG, 'buildWhereClause() - exit - '+retValue);
        return retValue;
    }
    
    /**
     * @brief This method is used to build field null check for specified list of source field map.
     * 
     * @details This method handls ignoring null check for those fields listed in @see ignoreNullCheckSet.
     * 
     * @param fieldListMap Source field map from which null check clause to be created.
     * 
     * @return Returns null check clause to be used in where clause.
     */
    @TestVisible private String buildNullCheckWhereClause( Map<String,String> fieldListMap ) {
        
        String whereClause = 'Id != null';
        
        for( String fieldSchema : fieldListMap.keySet() ) {
            
            String fieldName = fieldListMap.get( fieldSchema );
            
            if( fieldName == null || fieldName == '' || fieldName == SPM_Consts.NONE 
                || fieldName == SPM_Consts.REPEAT_VISIT_ADDITIONAL_COMPARISION_FIELD 
                || fieldName.toUpperCase().indexOf('SELECT ') != -1 || ignoreNullCheckSet.contains(fieldName) )  {
                continue;
            }
            
            // Logic to handle additioanl mappings
            
            String preference2 = fieldListMap.get( SPM_Consts.MAPPING_PREFERENCE_2 + fieldSchema );
            String preference3 = fieldListMap.get( SPM_Consts.MAPPING_PREFERENCE_3 + fieldSchema );
            
            Set<String> additionalMappingFieldSet = new Set<String>();
            additionalMappingFieldSet.add( fieldName );
            
            if( preference2 != null ) {
                
                additionalMappingFieldSet.add( preference2 );
                if( preference3 != null ) {
                    
                    additionalMappingFieldSet.add( preference3 );
                }
            }
            
            if( additionalMappingFieldSet.size() == 1 ) {
                whereClause = whereClause + ' AND ' + fieldName + ' != null';
            } else {
                
                String mappingClause = '';
                for( String mapFields : additionalMappingFieldSet ) {
                    
                    if( mappingClause != '' ) {
                        mappingClause = mappingClause + ' OR ';
                    }
                    mappingClause = mappingClause + mapFields + ' != null';
                }
                                
                whereClause = whereClause + ' AND (' + mappingClause + ')';
            }
        }
        
        
        return whereClause;
    }
    
    /**
     * @brief Private method to initialize calculation methods and configurations for requested metrics.
     */
    private void initConfiguration() {
        
        try {
            
            //Retrieve all configured calculation methods for given report type.
            List<SVMXC__ServiceMax_Config_Data__c> serviceMaxConfigDataList = [SELECT Name, SVMXC__Formula__c, SVMXC__Dispatch_Process__c, SVMXC__Dispatch_Process__r.SVMXC__Name__c, SVMXC__Dispatch_Process__r.SVMXC__Email_On_Success__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Dispatch_Process__c IN (SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__ProcessID__c =: report.name() ) AND RecordType.Name = 'SPM Details' AND SVMXC__Active__c = true];
            
            if( serviceMaxConfigDataList.isEmpty() ) {
                
                System.debug( LoggingLevel.ERROR, 'Calculation method(s) not configured for metrics ' + report.name() );
                return;    
            }
            lstserviceMaxConfigDataList =new List<SVMXC__ServiceMax_Config_Data__c>();
            lstserviceMaxConfigDataList.addAll(serviceMaxConfigDataList);
            /*
             * For each configured calculation methods, populate configurations, expressions 
             * and mapped field names in collections.
             */
            
            String referenceObjejectName = '';
            Boolean hasReferenceObjectInMapping = false;
            Boolean applyMapping = false;
            Map<String,Boolean> includeMappingFieldsMap = new Map<String,Boolean>();
            
            for( SVMXC__ServiceMax_Config_Data__c serviceMaxConfigData : serviceMaxConfigDataList ) {
                
                if( reportName == null ) {
                    
                    reportName = serviceMaxConfigData.SVMXC__Dispatch_Process__r.SVMXC__Name__c;
                    processId = serviceMaxConfigData.SVMXC__Dispatch_Process__c;
                    configurationName = serviceMaxConfigData.Name;
                    emailOnSuccess = serviceMaxConfigData.SVMXC__Dispatch_Process__r.SVMXC__Email_On_Success__c;
                    if(emailOnSuccess == null ) emailOnSuccess = UserInfo.getUserEmail();
                }
                
                // Populate configuration name vs configuration's and object mappings if configured.
                SPM_ConfigurationDefinition.CalculationMethod calculationMethod = (SPM_ConfigurationDefinition.CalculationMethod) JSON.deserialize( serviceMaxConfigData.SVMXC__Formula__c, SPM_ConfigurationDefinition.CalculationMethod.class );
                calculationMethodMap.put( serviceMaxConfigData.Name, calculationMethod);
                if( calculationMethod.objectMappingDetailsList != null && !calculationMethod.objectMappingDetailsList.isEmpty() ) {
                    
                    SPM_ConfigurationDefinition.ObjectMappingDetails objectMappingDetails = calculationMethod.objectMappingDetailsList.get(0);
                    if( objectMappingDetails.mapId != null && !objectMappingDetails.mapId.equalsIgnoreCase( SPM_Consts.NONE ) ) {
                        
                        configurationMappingMap.put(serviceMaxConfigData.Name, objectMappingDetails.mapId);
                        includeMappingFieldsMap.put(objectMappingDetails.mapId, false);
                        
                        if( calculationMethod.sourceObjectName.equalsIgnoreCase(objectMappingDetails.sourceObjectName) ) {
                            includeMappingFieldsMap.put(objectMappingDetails.mapId, true);
                        }
                        
                        hasReferenceObjectInMapping = (objectMappingDetails.referenceObjectName == null ) ? false : objectMappingDetails.referenceObjectName;    
                    }
                }                
            }
            
            // Query all configured object mapping details.
            
            if( !configurationMappingMap.isEmpty() ) {
                
                for( SVMXC__ServiceMax_Config_Data__c mappingDetails : [ SELECT Id, SVMXC__MapID__r.SVMXC__Target_Object_Name__c, SVMXC__MapID__r.SVMXC__Source_Object_Name__c, SVMXC__MapID__r.SVMXC__MapID__c,SVMXC__Source_Field_Name__c,SVMXC__Target_Field_Name__c, SVMXC__Preference_3__c, SVMXC__Preference_2__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c, SVMXC__Active__c, RecordTypeId, Name FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c = 'Field Mapping' AND SVMXC__MapID__r.SVMXC__MapID__c IN :configurationMappingMap.values() ] ) {
                                        
                    if( !mapIdConfigDataMap.containsKey( mappingDetails.SVMXC__MapID__r.SVMXC__MapID__c ) ) {
                        mapIdConfigDataMap.put( mappingDetails.SVMXC__MapID__r.SVMXC__MapID__c, new List<SVMXC__ServiceMax_Config_Data__c>() );
                    }
                    mapIdConfigDataMap.get( mappingDetails.SVMXC__MapID__r.SVMXC__MapID__c).add( mappingDetails );
                    if( hasReferenceObjectInMapping ) {
                        
                        referenceObjejectName = mappingDetails.SVMXC__MapID__r.SVMXC__Source_Object_Name__c;
                        referenceObjejectName = referenceObjejectName.substring(0, referenceObjejectName.length() - 1 ) + 'r.';
                    }
                }    
            }
           
            /*
             * For each calculation method, update configured field mappings. 
             */
            for( String calculationMethodName : calculationMethodMap.keySet() ) {
                
                SourceObjectFieldMap = SPM_ConfigurationDefinition.getSourceObjectFieldMap( report );
                SPM_ConfigurationDefinition.CalculationMethod calculationMethod = calculationMethodMap.get(calculationMethodName);
                    
                for( SPM_ConfigurationDefinition.ParameterInfo parameterInfo : calculationMethod.parameterInfoList ) {
                    
                    if( SourceObjectFieldMap.containsKey( parameterInfo.sourceObjectField.name() ) ) {
                        
                        String fieldName = SourceObjectFieldMap.get( parameterInfo.sourceObjectField.name() );
                        if( fieldName.indexOf('.') != -1 ) {
                            
                            fieldName = fieldName.substring( 0, fieldName.lastIndexOf('.') + 1 );
                            SourceObjectFieldMap.put( parameterInfo.sourceObjectField.name(), fieldName + parameterInfo.sourceFieldName );
                        } else {
                            SourceObjectFieldMap.put( parameterInfo.sourceObjectField.name(), parameterInfo.sourceFieldName );                            
                        }
                    } else {
                        ConfiguredObjectFieldMap.put( parameterInfo.sourceObjectField.name(), parameterInfo.sourceFieldName );
                    }
                }
                
                /*
                 * Overwrite source field mappings with configured mapping.
                 */
                if( configurationMappingMap.containsKey(calculationMethodName) ) {
                    
                    Map<String,String> fieldAPINameMap = SPM_ConfigurationDefinition.getFieldAPINameMap(report);
                    
                    String mapId = configurationMappingMap.get( calculationMethodName);
                    List<SVMXC__ServiceMax_Config_Data__c> mappingDetailsList = mapIdConfigDataMap.get( mapId );
                    if( mappingDetailsList != null && !mappingDetailsList.isEmpty() && includeMappingFieldsMap.get( mapId) != null && includeMappingFieldsMap.get( mapId) ) {
                        
                        for( SVMXC__ServiceMax_Config_Data__c mappingData : mappingDetailsList ) {
                            
                            String fieldSchema = null;
                            
                            if( fieldAPINameMap.containsKey(mappingData.SVMXC__Target_Field_Name__c) && mappingData.SVMXC__Source_Field_Name__c != null ) {
                                
                                fieldSchema = fieldAPINameMap.get(mappingData.SVMXC__Target_Field_Name__c);
                                SourceObjectFieldMap.put( fieldAPINameMap.get(mappingData.SVMXC__Target_Field_Name__c), referenceObjejectName + mappingData.SVMXC__Source_Field_Name__c );
                            } else {
                                
                                if( mappingData.SVMXC__Source_Field_Name__c != null && !mappingData.SVMXC__Source_Field_Name__c.equalsIgnoreCase(SPM_Consts.RECORD_ID) ) {
                                    
                                    SourceObjectFieldMap.put( SPM_Consts.MAPPING + mappingData.SVMXC__Target_Field_Name__c, referenceObjejectName + mappingData.SVMXC__Source_Field_Name__c );
                                    addIgnoreNullCheckField( referenceObjejectName + mappingData.SVMXC__Source_Field_Name__c );
                                }
                                fieldSchema = mappingData.SVMXC__Target_Field_Name__c;
                            }
                            
                            if( fieldSchema != null ) {
                                
                                if( mappingData.SVMXC__Preference_2__c != null ) {
                                    
                                    SourceObjectFieldMap.put( SPM_Consts.MAPPING_PREFERENCE_2 + fieldSchema, referenceObjejectName + mappingData.SVMXC__Preference_2__c );
                                    addIgnoreNullCheckField( referenceObjejectName + mappingData.SVMXC__Preference_2__c );
                                    //addIgnoreNullCheckField( referenceObjejectName + mappingData.SVMXC__Source_Field_Name__c );
                                }
                                
                                if( mappingData.SVMXC__Preference_3__c != null ) {
                                    
                                    SourceObjectFieldMap.put( SPM_Consts.MAPPING_PREFERENCE_3 + fieldSchema, referenceObjejectName + mappingData.SVMXC__Preference_3__c );
                                    addIgnoreNullCheckField( referenceObjejectName + mappingData.SVMXC__Preference_3__c );
                                }    
                            }
                        }    
                    }
                }
                
                metricsSourceFieldMap.put( calculationMethodName, SourceObjectFieldMap.clone() );
                metricsConfiguredFieldMap.put( calculationMethodName, ConfiguredObjectFieldMap.clone() );
                
                uniqueFieldList.addAll( SourceObjectFieldMap.values() );
            }
                        
            // initialize expressions.
            initExpressionMap();
        }
        
        catch( QueryException ex ) {
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );            
            throw ex;
        }
        
        catch( Exception ex ) {
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            throw ex;
        }
    }
    
    /**
     * @brief Private method used to initialize expressions.
     */
    @TestVisible private void initExpressionMap() {
        
        // Retrieve all expression id's configured in calculation methods.
        Set<String> expressionRuleIdList = new Set<String>();
        for( SPM_ConfigurationDefinition.CalculationMethod calculationMethod: calculationMethodMap.values() ) {
            for( SPM_ConfigurationDefinition.ExpressionDetails expressionDetails : calculationMethod.expressionDetailsList ) {
                expressionRuleIdList.add( expressionDetails.expressionRuleId );
            }
        }
        
        // Retrieve all expression details for configured expression ID's.
        List<SVMXC__ServiceMax_Config_Data__c> ruleExpressionList = [SELECT Id, SVMXC__Expression_Rule__c, SVMXC__Expression_Rule__r.SVMXC__ProcessID__c, SVMXC__Field_Relationship_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Expression_Rule__r.SVMXC__Source_Object_Name__c, SVMXC__Expression_Rule__r.SVMXC__Advance_Expression__c, SVMXC__Expression_Rule__r.SVMXC__Parent_Object_Criteria__c , SVMXC__Display_Type__c, SVMXC__Field_Name__c, SVMXC__Operand__c, SVMXC__Operator__c, SVMXC__Sequence__c 
                                                                       FROM SVMXC__ServiceMax_Config_Data__c 
                                                                       WHERE SVMXC__Expression_Rule__c != null 
                                                                       AND SVMXC__RecordType_Name__c = 'Expressions'
                                                                       AND SVMXC__Expression_Rule__r.SVMXC__Record_Type_Name__c = 'SVMX Rule'
                                                                       AND SVMXC__Expression_Rule__r.SVMXC__Rule_Type__c = 'Named Expression'
                                                                       AND SVMXC__Expression_Rule__r.SVMXC__ProcessID__c IN :expressionRuleIdList ];
        
        // Populate list of expression vs expressions ID map.
        Map<String,List<SVMXC__ServiceMax_Config_Data__c>> ruleExpressionMap = new Map<String,List<SVMXC__ServiceMax_Config_Data__c>>();
        for( SVMXC__ServiceMax_Config_Data__c expression : ruleExpressionList ) {
            
            if( !ruleExpressionMap.containsKey(expression.SVMXC__Expression_Rule__r.SVMXC__ProcessID__c) ) {
                ruleExpressionMap.put( expression.SVMXC__Expression_Rule__r.SVMXC__ProcessID__c, new List<SVMXC__ServiceMax_Config_Data__c>() );
            }
            ruleExpressionMap.get( expression.SVMXC__Expression_Rule__r.SVMXC__ProcessID__c ).add( expression );
        }
        
        // For each calculation method name, retrieve expressions which will be used in start 
        // query or by report implementation.
        for( String key: calculationMethodMap.keySet() ) {
            
            SPM_ConfigurationDefinition.CalculationMethod calculationMethod = calculationMethodMap.get( key );
            
            for( SPM_ConfigurationDefinition.ExpressionDetails expressionDetails : calculationMethod.expressionDetailsList ) {
                
                List<SVMXC__ServiceMax_Config_Data__c> expressionList = ruleExpressionMap.get( expressionDetails.expressionRuleId );
                
                if( expressionList != null && !expressionList.isEmpty() ) {
                    
                    for( SVMXC__ServiceMax_Config_Data__c expression : expressionList ) {
                        
                        // Populate expressions for qualification criteria to use in query where clause.
                        if( expressionDetails.sourceObjectName == getSourceObjectName() || ( expressionDetails.sourceObjectName == null && expressionDetails.expressionType == SPM_Schema.ExpressionType.QualificationCriteria ) ) {
                            expressionFieldList.add( expression.SVMXC__Field_Name__c );
                            if( expression.SVMXC__Display_Type__c != null && expression.SVMXC__Display_Type__c.equalsIgnoreCase('REFERENCE') ) {
                                if( expression.SVMXC__Field_Relationship_Name__c != null && expression.SVMXC__FKey_Name_Field__c != null ) {                    
                                    expressionFieldList.add( expression.SVMXC__Field_Relationship_Name__c + '.' + expression.SVMXC__FKey_Name_Field__c );
                                }
                            }
                        }
                        
                        if( !ruleExpressionCriteriaMap.containsKey( key + expressionDetails.expressionType.name() ) ) {
                            ruleExpressionCriteriaMap.put( key + expressionDetails.expressionType.name(), expression.SVMXC__Expression_Rule__r.SVMXC__Parent_Object_Criteria__c );    
                        }
                        
                        if( !advancedExpressionCriteriaMap.containsKey( key + expressionDetails.expressionType.name() ) ) {
                            advancedExpressionCriteriaMap.put( key + expressionDetails.expressionType.name(), expression.SVMXC__Expression_Rule__r.SVMXC__Advance_Expression__c );
                        }
                    }
                    
                    ruleExpressionListMap.put( key + expressionDetails.expressionType.name(), expressionList );    
                }            
            }
        }
        
        uniqueFieldList.addAll( expressionFieldList );
        ignoreNullCheckSet.addAll(expressionFieldList);
    }
    
    /**
     * @brief Private method to initialize settings related to reports.
     */
    @TestVisible private void initSettingValues() {
        
        try {         
            Map<String, String> svmxSettingMap = commUtilsManageSettings.SVMX_getSettingList('SPM001');
            System.debug(LoggingLevel.DEBUG, '** initSettingValues() - ' + svmxSettingMap);
            if( svmxSettingMap != null ) {
                if( report == SPM_Schema.Report.FirstTimeFix ) {
                    numberOfDaysToQualifyRecords = Integer.valueOf( svmxSettingMap.get('SET001') );
                } else if( report == SPM_Schema.Report.MeanTimeToRepair ) {
                    numberOfDaysToQualifyRecords = Integer.valueOf( svmxSettingMap.get('SET002') );
                } else if( report == SPM_Schema.Report.UpDownTime ) {
                    numberOfDaysToQualifyRecords = Integer.valueOf(svmxSettingMap.get('SET003') );
          isTrendingEnabled=Boolean.valueOf(svmxSettingMap.get('SET011'));
                } else if( report == SPM_Schema.Report.ContractPenetration ) {
                    numberOfDaysToQualifyRecords = Integer.valueOf( svmxSettingMap.get('SET004') );
          isTrendingEnabled=Boolean.valueOf(svmxSettingMap.get('SET012'));
                }  else if( report == SPM_Schema.Report.MeanTimeToComplete ) {
                    numberOfDaysToQualifyRecords = Integer.valueOf( svmxSettingMap.get('SET006') );
                } else if( report == SPM_Schema.Report.AverageResponseTime ) {
                    numberOfDaysToQualifyRecords = Integer.valueOf( svmxSettingMap.get('SET005') );
                } else if( report == SPM_Schema.Report.RepeatVisit ) {
                    numberOfDaysToQualifyRecords = Integer.valueOf( svmxSettingMap.get('SET008') );
                } else if( report == SPM_Schema.Report.Utilization ) {
                    numberOfDaysToQualifyRecords = Integer.valueOf( svmxSettingMap.get('SET007') );
                } else if( report == SPM_Schema.Report.AccountSummary ) {
                    numberOfDaysToQualifyRecords = Integer.valueOf( svmxSettingMap.get('SET009') );
                }else if( report == SPM_Schema.Report.MeanTimeBetweenFailure ) {
                    numberOfDaysToQualifyRecords = Integer.valueOf( svmxSettingMap.get('SET010') );
                }
            }
        }
        catch( Exception ex ) {
            
            // Ignore the exception. Exception will be thrown only of there is no settings or setting value.
            System.debug( LoggingLevel.WARN, ex.getMessage() );
            System.debug( LoggingLevel.WARN, ex.getStackTraceString() );
        }
    }
}