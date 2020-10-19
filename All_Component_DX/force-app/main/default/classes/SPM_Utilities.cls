/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The class SPM_Utilities implementats utility methods which is used across all SPM apex class.
 *
 * @author Ramachandra Mohan
 * @version 15.59101
 * @since 2015
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       15 Oct 2015     Created. 
 * 027677       Ramachandra Mohan       03 Mar 2016     Alphabetically sorting the mapping's.
 *              Ramachandra Mohan       31 Mar 2016     Security fixes.
 * 019174       Ramachandra Mohan       18 Apr 2016     Workaround for Salesforce Database.Stateful limitation.
 *****************************************************************************************************/

public with sharing class SPM_Utilities {
    
    /**
     * Static instance variable to hold instance of the class.
     */
    private static final SPM_Utilities instance = new SPM_Utilities();
    
    /**
     * Static instance variable to cache global describe.
     */
    //private static Map<String, Schema.SObjectType> globalDescribeMap = null;
    
    /**
     * Static instance variable to store field describe information of each objects.
     */
    private static Map<String, List<Schema.DescribeFieldResult>> objectDescribeFieldResultMap = new Map<String, List<Schema.DescribeFieldResult>>();
    
    /**
     * Static method to retrieve single instance of this class.
     * 
     * @returns Returns instance of SPM_Utilities class.
     */
    public static SPM_Utilities getInstance() {
        return instance;
    }
   
    /**
     * 
     */
    String strSPMMetricName = '';
    public void populateConfigurationDetails( List<SPM_ConfigurationDefinition.CalculationMethod> calculationMethodList , String strMetricName) {

        strSPMMetricName = strMetricName;
        System.debug('MK_strSPMMetricName: '+strSPMMetricName);
        for( SPM_ConfigurationDefinition.CalculationMethod calculationMethod : calculationMethodList ) {
            
            for( SPM_ConfigurationDefinition.ParameterInfo parmeterInfo : calculationMethod.parameterInfoList ) {
                if( parmeterInfo.sourceFieldInfoList.isEmpty() ) {
                    populateParameterInfo( parmeterInfo, calculationMethod.sourceObjectName );    
                }
            }
            
            for( SPM_ConfigurationDefinition.ObjectMappingDetails mappingDetails : calculationMethod.objectMappingDetailsList ) {
                populateMappingDetails( mappingDetails );
            }

            for( SPM_ConfigurationDefinition.ExpressionDetails expressionDetails: calculationMethod.expressionDetailsList) {                
                String sourceObjectName = (expressionDetails.sourceObjectName == null ) ? calculationMethod.sourceObjectName : expressionDetails.sourceObjectName;
                populateExpressionDetails( sourceObjectName, expressionDetails , strSPMMetricName);
            }
            
            populateSourceTargetLabelInfo( calculationMethod );
        }        
    }
    
    public void populateSourceTargetLabelInfo( SPM_ConfigurationDefinition.CalculationMethod calculationMethod ) {
        
        Schema.SObjectType sourceObjectType = getGlobalDescribe( calculationMethod.sourceObjectName );
        if( sourceObjectType != null ) { //Account Summary Flow changes
            if(calculationMethod.sourceObjectName == SPM_Consts.SERVICEMAX_PROCESS) {
                calculationMethod.sourceObjectLabel = getGlobalDescribe( SPM_Consts.FIRST_TIME_FIX ).getDescribe().getLabel() + SPM_Consts.COMMA;
                calculationMethod.sourceObjectLabel += getGlobalDescribe( SPM_Consts.MEAN_TIME_TO_REPAIR ).getDescribe().getLabel() + SPM_Consts.COMMA;
                calculationMethod.sourceObjectLabel += getGlobalDescribe( SPM_Consts.CONTRACT_PENETRATION ).getDescribe().getLabel() + SPM_Consts.COMMA;
                calculationMethod.sourceObjectLabel += getGlobalDescribe( SPM_Consts.CONTRACT_UP_TIME ).getDescribe().getLabel() + SPM_Consts.COMMA;
                calculationMethod.sourceObjectLabel += getGlobalDescribe( SPM_Consts.MEAN_TIME_TO_COMPLETE ).getDescribe().getLabel() + SPM_Consts.COMMA;
                calculationMethod.sourceObjectLabel += getGlobalDescribe( SPM_Consts.AVERAGE_RESPONSE_TIME ).getDescribe().getLabel() + SPM_Consts.COMMA;
                calculationMethod.sourceObjectLabel += getGlobalDescribe( SPM_Consts.REPEATVISIT ).getDescribe().getLabel();
            } else {
                calculationMethod.sourceObjectLabel = sourceObjectType.getDescribe().getLabel();
            }
            System.debug(LoggingLevel.DEBUG, 'Soruce Object Label: ' + calculationMethod.sourceObjectLabel );
        }
        
        Schema.SObjectType targetObjectType = getGlobalDescribe( calculationMethod.targetObjectName );
        if( targetObjectType != null ) {
            
            calculationMethod.targetObjectLabel = targetObjectType.getDescribe().getLabel();
            System.debug(LoggingLevel.DEBUG, 'Target Object Label: ' + calculationMethod.targetObjectLabel );
        }
    }
    
    /**
     * TODO check performance.
     */
    private void populateParameterInfo( SPM_ConfigurationDefinition.ParameterInfo parmeterInfo, String sourceObjectName) {
        
        if( parmeterInfo.sourceObjectName != null ) {
            sourceObjectName = parmeterInfo.sourceObjectName;
        }
        
        if( parmeterInfo.displayType == Schema.DisplayType.MultiPicklist && parmeterInfo.isPicklistValue ) {
            
            populatePicklistValues( parmeterInfo );
            // TODO check for other scenarios.
            parmeterInfo.sourceFieldName ='';
            parmeterInfo.sourceFieldLabel = '';
            return;
        }
        
        List<Schema.DescribeFieldResult> describeFieldResultList = getDescribeFieldResultList( sourceObjectName );
        
        for( Schema.DescribeFieldResult describeFieldResult : describeFieldResultList ) {
            
            if( describeFieldResult.getType() == parmeterInfo.displayType ) {
                
                SPM_ConfigurationDefinition.FieldInfo fieldInfo = new SPM_ConfigurationDefinition.FieldInfo();
                
                fieldInfo.name = describeFieldResult.getName();
                fieldInfo.label = describeFieldResult.getLabel();
                fieldInfo.displayType = describeFieldResult.getType();
                System.debug( fieldInfo.name + ':' + fieldInfo.label + ':' + fieldInfo.displayType );
                System.debug(parmeterInfo.sourceFieldName);
                if( describeFieldResult.getType() == Schema.DisplayType.REFERENCE && parmeterInfo.referenceTo != null ) {
                    
                    Boolean isReferenceObject = false;
                    List<Schema.sObjectType> referenceList = describeFieldResult.getReferenceTo();
                    for( Schema.sObjectType objectType : referenceList ) {
                        Schema.DescribeSObjectResult result = objectType.getDescribe();
                        System.debug( LoggingLevel.DEBUG, 'Reference: ' + result.getName() );
                        if( result.getName().equalsIgnoreCase( parmeterInfo.referenceTo ) ) {
                            isReferenceObject = true;
                            break;
                        }
                    }
                    if( !isReferenceObject ) {
                        continue;
                    }
                }
                
                parmeterInfo.sourceFieldInfoList.add( fieldInfo );
            }
        }
        parmeterInfo.sourceFieldInfoList.sort();
    }
    
    private void populatePicklistValues( SPM_ConfigurationDefinition.ParameterInfo parmeterInfo ) {
        
        System.debug( LoggingLevel.DEBUG, 'populatePicklistValues() - enter ');
        
        List<Schema.DescribeFieldResult> describeFieldResultList = getDescribeFieldResultList( parmeterInfo.sourceObjectName );
        
        for( Schema.DescribeFieldResult describeFieldResult : describeFieldResultList ) {
            
            if( parmeterInfo.sourceFieldName.equalsIgnoreCase( describeFieldResult.getName() ) ) {
                
                List<Schema.PicklistEntry> PicklistEntryList = describeFieldResult.getPicklistValues();
                
                for( Schema.PicklistEntry picklistEntry : PicklistEntryList ) {
                    
                    SPM_ConfigurationDefinition.FieldInfo fieldInfo = new SPM_ConfigurationDefinition.FieldInfo();
                    
                    fieldInfo.name = picklistEntry.getValue();
                    fieldInfo.label = picklistEntry.getLabel();
                    parmeterInfo.sourceFieldInfoList.add( fieldInfo );
                } 
                break;
            }
        }
    }
    
    @TestVisible private void populateMappingDetails( SPM_ConfigurationDefinition.ObjectMappingDetails mappingDetails ) {
        
        System.debug( LoggingLevel.DEBUG, 'populateMappingDetails() - enter; mappingDetails: ' + mappingDetails );
        
        if( mappingDetails != null && mappingDetails.sourceObjectName != null && mappingDetails.targetObjectName != null ) {
            
            List<String> queryFields = new List<String> {'SVMXC__MapID__c', 'SVMXC__Name__c'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            
            List<SVMXC__ServiceMax_Processes__c> mappingList = [SELECT SVMXC__MapID__c,SVMXC__Name__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = 'Object Mapping' AND SVMXC__Source_Object_Name__c = :mappingDetails.sourceObjectName AND SVMXC__Target_Object_Name__c = :mappingDetails.targetObjectName ORDER BY SVMXC__Name__c];
            
            System.debug( 'No. of mappings: ' + mappingList.size() );
            
            for( SVMXC__ServiceMax_Processes__c objectMappingProcess : mappingList ) {
                
                SPM_ConfigurationDefinition.ObjectMapping objectMapping = new SPM_ConfigurationDefinition.ObjectMapping();
                objectMapping.mapId = objectMappingProcess.SVMXC__MapID__c;
                objectMapping.name = objectMappingProcess.SVMXC__Name__c;
                
                mappingDetails.objectMappingList.add(objectMapping);
            }    
        }
        System.debug( LoggingLevel.DEBUG, 'populateMappingDetails() - exit' );
    }
    
    /**
     * 
     */
    private void populateExpressionDetails( String sourceObjectName, SPM_ConfigurationDefinition.ExpressionDetails expressionDetails , String strSPMMetricName) {
        
        List<Schema.DescribeFieldResult> describeFieldResultList = getDescribeFieldResultList( sourceObjectName );
        
        Map<String,String> fieldNameLabelMap = new Map<String,String>();
        for( Schema.DescribeFieldResult describeFieldResult : describeFieldResultList ) {
            fieldNameLabelMap.put( describeFieldResult.getName(), describeFieldResult.getLabel() );
        }
        
        List<String> queryFields = new List<String> {'SVMXC__ProcessID__c', 'SVMXC__Name__c', 'SVMXC__Advance_Expression__c' };
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        
        queryFields = new List<String> {'SVMXC__Field_Name__c', 'SVMXC__Sequence__c', 'SVMXC__Operand__c', 'SVMXC__Operator__c', 'SVMXC__Expression_Rule__c' };
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        
        List<SVMXC__ServiceMax_Config_Data__c > expressionConfigDataList = [SELECT Id, SVMXC__Field_Name__c, SVMXC__Sequence__c, SVMXC__Operand__c, SVMXC__Operator__c, SVMXC__Expression_Rule__c, SVMXC__Expression_Rule__r.SVMXC__ProcessID__c, SVMXC__Expression_Rule__r.SVMXC__Name__c, SVMXC__Expression_Rule__r.SVMXC__Advance_Expression__c 
                                                                              FROM SVMXC__ServiceMax_Config_Data__c 
                                                                              WHERE SVMXC__Field_Name__c != null 
                                                                              AND SVMXC__Expression_Rule__c != null
                                                                              AND SVMXC__Expression_Rule__r.SVMXC__ProcessID__c != null 
                                                                              AND SVMXC__Expression_Rule__r.SVMXC__Source_Object_Name__c =: sourceObjectName 
                                                                              AND SVMXC__RecordType_Name__c = 'Expressions' 
                                                                              AND SVMXC__Expression_Rule__r.SVMXC__Record_Type_Name__c = 'SVMX Rule'
                                                                              AND SVMXC__Expression_Rule__r.SVMXC__Rule_Type__c = 'Named Expression'
                                                                              AND SVMXC__Expression_Rule__r.SVMXC__Name__c != null 
                                                                              ORDER BY SVMXC__Expression_Rule__r.SVMXC__Name__c, SVMXC__Sequence__c ];
        
        Map<String, SPM_ConfigurationDefinition.ExpressionRule> expressionRuleMap = new Map<String, SPM_ConfigurationDefinition.ExpressionRule>();
        System.debug('MK_strSPMMetricName: '+strSPMMetricName);
        System.debug('MK_expressionDetails: '+expressionDetails.expressionType);
        if(strSPMMetricName.equalsIgnoreCase('MeanTimeBetweenFailure') &&  expressionDetails.expressionType.name().equals('WorkOrderExcludeCriteria')){
            SPM_ConfigurationDefinition.ExpressionRule expressionRuleNone = new SPM_ConfigurationDefinition.ExpressionRule();
            expressionRuleNone.expressionRuleName = SPM_Consts.LABEL_NONE;
            expressionRuleNone.expressionRuleId = SPM_Consts.NONE;
            expressionRuleMap.put('MeanTimeBetweenFailure', expressionRuleNone);
        }
        
        for( SVMXC__ServiceMax_Config_Data__c expressionData : expressionConfigDataList) {
            
            if( !expressionRuleMap.containsKey( expressionData.SVMXC__Expression_Rule__r.SVMXC__ProcessID__c ) ) {
                
                expressionRuleMap.put( expressionData.SVMXC__Expression_Rule__r.SVMXC__ProcessID__c, new SPM_ConfigurationDefinition.ExpressionRule( expressionData.SVMXC__Expression_Rule__r.SVMXC__ProcessID__c, expressionData.SVMXC__Expression_Rule__r.SVMXC__Name__c ) );
                expressionRuleMap.get( expressionData.SVMXC__Expression_Rule__r.SVMXC__ProcessID__c ).advancedExpression = expressionData.SVMXC__Expression_Rule__r.SVMXC__Advance_Expression__c;
            }
            
            if( expressionData.SVMXC__Operator__c == null || expressionData.SVMXC__Operator__c == '' ) {
                continue;
            }
            
            SPM_ConfigurationDefinition.Expression expression = new SPM_ConfigurationDefinition.Expression();
            expression.expressionId = expressionData.Id;
            if( expressionData.SVMXC__Sequence__c != null ) 
                expression.sequence = String.valueOf( Math.Round( expressionData.SVMXC__Sequence__c ) );
            expression.operator = (SPM_Consts.OPERATOR_MAP.containsKey( expressionData.SVMXC__Operator__c ) ) ? SPM_Consts.OPERATOR_MAP.get(expressionData.SVMXC__Operator__c ) : expressionData.SVMXC__Operator__c;
            expression.value = expressionData.SVMXC__Operand__c;
            expression.field = ( fieldNameLabelMap.containsKey( expressionData.SVMXC__Field_Name__c ) ) ? fieldNameLabelMap.get( expressionData.SVMXC__Field_Name__c ) : expressionData.SVMXC__Field_Name__c;
            
            expressionRuleMap.get( expressionData.SVMXC__Expression_Rule__r.SVMXC__ProcessID__c ).expressionList.add( expression );
        }
        
        expressionDetails.expressionRuleList.addAll( expressionRuleMap.values() );
    }
    
    /*
    public Boolean hasExpressionRule( String expressionRuleId ) {
        
        Boolean hasExpression = false;
        
        if( expressionRuleId != null ) {
            
            hasExpression = expressionRuleMap.containsKey(expressionRuleId);
            if( !hasExpression ) {
                if( [SELECT count() FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Rule_Type__c = 'Named Expression' AND SVMXC__Record_Type_Name__c = 'SVMX Rule' AND SVMXC__ProcessID__c = :expressionRuleId ] > 0 ) {
                    hasExpression = true;
                }
            }   
        }
        
        return hasExpression;
    }
    */
    
    /**
     * 
     */
    public List<Schema.DescribeFieldResult> getDescribeFieldResultList( String sourceObjectName ) {
        
        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
        
        if( !objectDescribeFieldResultMap.containsKey( sourceObjectName ) ) {
            
            List<Schema.DescribeFieldResult> describeFieldResultList = new List<Schema.DescribeFieldResult>();              
            for( Schema.SObjectField field : globalDescribeMap.get( sourceObjectName ).getDescribe().fields.getMap().values() ) {
                describeFieldResultList.add( field.getDescribe() );
            }                
            objectDescribeFieldResultMap.put( sourceObjectName, describeFieldResultList );
        }
        return objectDescribeFieldResultMap.get( sourceObjectName );
    }
    
    public Schema.SObjectType getGlobalDescribe( String sourceObjectName ) {
        
        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
        return globalDescribeMap.get( sourceObjectName );
    }
    
    public String buildString( Set<String> stringSet, String separator ) {
        return buildString( new List<String>(stringSet), separator );
    }
    
    public String buildString( List<String> stringList, String separator ) {
    
        String resultString = '';
        
        if( stringList != null && separator != null ) {
        
            for( String str : stringList ) {
            
                if( str != null ) {
                
                    if( !resultString.equals('') ) resultString += separator;
                    resultString += str;
                }
            }
        }
        
        return resultString;
    }
    
    /**
     * 
     */
    public SPM_WrapperDef.SPM_Response getAllTimezones() {
    
        System.debug( LoggingLevel.DEBUG, 'getAllTimezones() - enter' );        
        
        SPM_WrapperDef.SPM_Response response = new SPM_WrapperDef.SPM_Response();
        
        Schema.DescribeFieldResult timezoneDescribe = User.TimeZoneSidKey.getDescribe();
        List<Schema.PicklistEntry> picklistEntryList = timezoneDescribe.getPicklistValues();
    
        for(Schema.PicklistEntry picklistEntry : picklistEntryList ) {
            
            SPM_WrapperDef.ObjectInfo timezoneInfo = new SPM_WrapperDef.ObjectInfo();
            timezoneInfo.Id = picklistEntry.getValue();            
            timezoneInfo.name = picklistEntry.getLabel();
            
            response.timezoneList.add(timezoneInfo);
        }
        
        return response;
    }
    
    /**
     * Creates the key to track the summary records.
     */
    public String createNewSummaryKey(String accountId, String dateKey, String configurationName) {
        System.debug(LoggingLevel.DEBUG, 'SPM_Utilities.createNewSummaryKey() - enter');
        String key = accountId + '$' + dateKey + '$' + configurationName;   
        System.debug(LoggingLevel.DEBUG, 'Key for Summary - ' + key);
        System.debug(LoggingLevel.DEBUG, 'SPM_Utilities.createNewSummaryKey() - exit');
        return key;
    }
    
    /**
     * Computes the begin date of the month using the passed in date.
     **/
    public Date getBeginDateOfMonth(Date anyDate) {
        System.debug(LoggingLevel.DEBUG, 'SPM_Utilities.getBeginDateOfMonth() - enter - '+ anyDate);
        return Date.newInstance(anyDate.year(), anyDate.month(), 1);
    }
    
    public Date getEndDateOfMonth(Date anyDate) {
        System.debug(LoggingLevel.DEBUG, 'SPM_Utilities.getEndOfMonth() - enter - '+ anyDate);
        return anyDate.addMonths(1).toStartofMonth().addDays(-1);
    }
    
    /**
     * Creates a instance of the summary record using the passed in information.
     **/
     public SVMXC__SPM_Account_Summary__c createSummaryRecord (String accountId, String configurationName, String calculationMethod, 
                                                                String description, Date beginDate, Date endDate, String unit, Integer totalCount) {
        
        System.debug( LoggingLevel.DEBUG, 'SPM_Utilities.createSummaryRecord() - enter' );
        
        //Create a summary object using the above information.
        SVMXC__SPM_Account_Summary__c summaryRecord = new SVMXC__SPM_Account_Summary__c();
        summaryRecord.SVMXC__Account__c = accountId;
        summaryRecord.SVMXC__Configuration_Name__c = configurationName;
        summaryRecord.SVMXC__Calculation_Method__c = calculationMethod;
        summaryRecord.SVMXC__Metrics_Description__c = description;
        summaryRecord.SVMXC__Start_Date__c = beginDate;
        summaryRecord.SVMXC__End_Date__c = endDate;
        summaryRecord.SVMXC__Total_Record_Count__c = 1;
        summaryRecord.SVMXC__Unit__c = unit;
        summaryRecord.SVMXC__Total_Record_Count__c = totalCount;
        //default values
        summaryRecord.SVMXC__Value__c = 0;
        summaryRecord.SVMXC__Metric_Value__c = 0;
        System.debug( LoggingLevel.DEBUG, 'SPM_Utilities.createSummaryRecord() - exit' );
        return summaryRecord;
    }
    
    /**
     * Load the existing summary record and merge/override it with the current batch based on the creation date. Use the parameter for loading the information.
     **/
    public void overrideExistingSummary(Set<String> accountIds, Set<Date> dates, Set<String> configurationNames, 
                                          Map<String, SVMXC__SPM_Account_Summary__c> batchSummaryMap) {
        System.debug(LoggingLevel.DEBUG, 'SPM_Utilities.overrideExistingSummary() - enter');
        List<SObject> records = [select SVMXC__Account__c, SVMXC__Start_Date__c, SVMXC__Configuration_Name__c, SVMXC__Total_Record_Count__c, 
                                SVMXC__Value__c, SVMXC__Metric_Value__c from SVMXC__SPM_Account_Summary__c Where SVMXC__Account__c IN :accountIds 
                                and SVMXC__Start_Date__c IN :dates and SVMXC__Configuration_Name__c IN :configurationNames];
        
        if(records.size() > 0) {
            SVMXC__SPM_Account_Summary__c summaryRecord;
            
            String key = '';
            SVMXC__SPM_Account_Summary__c batchSummaryRecord;
            
            for (SObject record : records) {  
                summaryRecord = (SVMXC__SPM_Account_Summary__c) record;
                String accountId = summaryRecord.SVMXC__Account__c;
                String configurationName = summaryRecord.SVMXC__Configuration_Name__c;
                Date beginDate = summaryRecord.SVMXC__Start_Date__c;
              
                //generate a map with the key as accountId-startDate-configurationName
                key = createNewSummaryKey(accountId, beginDate.format(), configurationName);
                
                if(batchSummaryMap.containsKey(key)) {
                    batchSummaryRecord = batchSummaryMap.get(key);
                    summaryRecord.SVMXC__Metric_Value__c = batchSummaryRecord.SVMXC__Metric_Value__c;
                    summaryRecord.SVMXC__Value__c = batchSummaryRecord.SVMXC__Value__c;
                    summaryRecord.SVMXC__Total_Record_Count__c = batchSummaryRecord.SVMXC__Total_Record_Count__c;
                    
                    batchSummaryMap.put(key, summaryRecord);
                }
            }
        }
        System.debug(LoggingLevel.DEBUG, 'SPM_Utilities.overrideExistingSummary() - exit');
    }
    
    /**
     * Load the existing summary record and merge it with the current batch. Use the parameter for loading the information.
     **/
    public void mergeBatchWithExistingSummary(Set<String> accountIds, Set<Date> dates, Set<String> configurationNames, 
                                          Map<String, SVMXC__SPM_Account_Summary__c> batchSummaryMap, Boolean isMean) {
        System.debug(LoggingLevel.DEBUG, 'SPM_Utilities.mergeBatchWithExistingSummary() - enter');
        List<SObject> records = [select SVMXC__Account__c, SVMXC__Start_Date__c, SVMXC__Configuration_Name__c, SVMXC__Total_Record_Count__c, 
                                SVMXC__Value__c, SVMXC__Metric_Value__c from SVMXC__SPM_Account_Summary__c Where SVMXC__Account__c IN :accountIds 
                                and SVMXC__Start_Date__c IN :dates and SVMXC__Configuration_Name__c IN :configurationNames];
        
        if(records.size() > 0) {
            SVMXC__SPM_Account_Summary__c summaryRecord;
            
            String key = '';
            Decimal totalRecordsCount = 0;
            Decimal value = 0;
            SVMXC__SPM_Account_Summary__c batchSummaryRecord;
            
            for (SObject record : records) {  
                summaryRecord = (SVMXC__SPM_Account_Summary__c) record;
                String accountId = summaryRecord.SVMXC__Account__c;
                String configurationName = summaryRecord.SVMXC__Configuration_Name__c;
                Date beginDate = summaryRecord.SVMXC__Start_Date__c;
              
                //generate a map with the key as accountId-startDate-configurationName
                key = createNewSummaryKey(accountId, beginDate.format(), configurationName);
                
                if(batchSummaryMap.containsKey(key)) {
                    totalRecordsCount = 0;
                    value = 0;
                    batchSummaryRecord = batchSummaryMap.get(key);
                    System.debug(LoggingLevel.DEBUG, 'batchSummaryRecord '+batchSummaryRecord);
                    System.debug(LoggingLevel.DEBUG, 'batchSummaryRecord.SVMXC__Value__c '+batchSummaryRecord.SVMXC__Value__c);
                    System.debug(LoggingLevel.DEBUG, 'summaryRecord.SVMXC__Value__c '+summaryRecord.SVMXC__Value__c);
                    
                    value = batchSummaryRecord.SVMXC__Value__c + summaryRecord.SVMXC__Value__c;
                    totalRecordsCount = batchSummaryRecord.SVMXC__Total_Record_Count__c + summaryRecord.SVMXC__Total_Record_Count__c;
                    
                    if(isMean) {
                        summaryRecord.SVMXC__Value__c = value;
                        summaryRecord.SVMXC__Metric_Value__c = value / totalRecordsCount;
                    } else {
                        if(value > 0 && totalRecordsCount > 0) {
                            summaryRecord.SVMXC__Value__c = value;
                            summaryRecord.SVMXC__Metric_Value__c = ((value / totalRecordsCount) * 100);
                        } 
                    }
                    summaryRecord.SVMXC__Total_Record_Count__c = totalRecordsCount;
                    batchSummaryMap.put(key, summaryRecord);
                }
            }
        }
        System.debug(LoggingLevel.DEBUG, 'SPM_Utilities.mergeBatchWithExistingSummary() - exit');
    }
    
    /**
     * Method to identify the SPM processes having the passed in expressions in their criteria. 
     * If found then the processes names are returned.
     **/
    public Set<String> getAssociatedProcessNames(List<String> expressionIds) {
        Set<String> processNames = new Set<String>();
        
        System.debug(LoggingLevel.DEBUG, 'SPM_Utilities.getAssocaitedProcessNames() - enter');
        System.debug(LoggingLevel.DEBUG,'Expression Ids - '+expressionIds);
        if(expressionIds != null && expressionIds.isEmpty()) {
            System.debug(LoggingLevel.INFO,'No Expressions sent for existance check');
            return processNames;
        }
        //Get the Expression Names using the passed in Ids;
        List<String> expressionNames = new List<String>();
        List<SVMXC__ServiceMax_Processes__c> expressionProcessNames = [Select SVMXC__ProcessID__c from SVMXC__ServiceMax_Processes__c where Id IN:expressionIds]; 
                                                                            //and Recordtype.Name='SVMX Rule'];
        for(SVMXC__ServiceMax_Processes__c expressionProcessName: expressionProcessNames) {
            //expressionNames.add('expressionRuleId": "' + expressionProcessName.SVMXC__ProcessID__c);
            expressionNames.add(expressionProcessName.SVMXC__ProcessID__c);
        }
        System.debug(LoggingLevel.DEBUG,'Expression Names - '+ expressionNames);
        
        //Load the existing SPM Configurations
        List<SVMXC__ServiceMax_Processes__c> processes = [SELECT SVMXC__Name__c, (SELECT SVMXC__Formula__c from SVMXC__ServiceMax_Config_Data__r 
                            where SVMXC__RecordType_Name__c = 'SPM Details') FROM SVMXC__ServiceMax_Processes__c 
                            WHERE SVMXC__Record_Type_Name__c = 'SPM Rule'];
        //Check if the SPM Configuration is definied.
        if(processes != null && !processes.isEmpty()) {
            for(SVMXC__ServiceMax_Processes__c process: processes) {
                if(process.SVMXC__ServiceMax_Config_Data__r != null) {
                    for(SVMXC__ServiceMax_Config_Data__c config: process.SVMXC__ServiceMax_Config_Data__r) {
                        if(isListEntryPresent(expressionNames, config.SVMXC__Formula__c)) {
                            processNames.add(process.SVMXC__Name__c);
                        }
                    }
                }
            }
        }
        System.debug('Process Names - ' + processNames);
        System.debug(LoggingLevel.DEBUG, 'SPM_Utilities.getAssocaitedProcessNames() - exit');
        return processNames;
    }
    
    /**
     * Check if the list of strings passed is present in the target string. Returns true if found.
     **/
    private boolean isListEntryPresent(List<String> searchStrings, String target) {
        System.debug(LoggingLevel.DEBUG, 'SPM_Utilities.isListEntryPresent() - enter');
        System.debug(LoggingLevel.DEBUG, 'Formula - '+ target);
        System.debug(LoggingLevel.DEBUG, 'Expressions to be searched - '+ searchStrings);
        for(String searchString: searchStrings) {
            if(target.indexOf(searchString) != -1) {
                System.debug(LoggingLevel.DEBUG, 'Expression found - '+searchString);
                return true;
            }
        }
        System.debug(LoggingLevel.DEBUG, 'SPM_Utilities.isListEntryPresent() - exit');
        return false;
    }
    
    /**
     * Get the value configured by the user in the SPM Scheduling Configuration screen.
     **/
    public String loadConfigurationValue(String key) {
        System.debug( LoggingLevel.DEBUG, 'SPM_Utilities.loadConfigurationValue() - enter');

        SVMXC__ServiceMax_Processes__c optimaxProcess = [SELECT Id, SVMXC__Name__c, SVMXC__Record_Type_Name__c FROM SVMXC__ServiceMax_Processes__c 
                        WHERE SVMXC__Record_Type_Name__c =:SPM_Consts.SPM_OPTIMAX_RULE];
        System.debug( LoggingLevel.DEBUG,'Servicemax Scheduling Process - ' + optimaxProcess);
        
                      //WHERE SVMXC__Record_Type_Name__c = 'SPM Optimax Rule' and  SVMXC__Name__c='Optimax Technician Utilization' limit 1] ;
                      
        SVMXC__ServiceMax_Config_Data__c config = [select Name, SVMXC__Formula__c from SVMXC__ServiceMax_Config_Data__c 
                                                                    where SVMXC__Dispatch_Process__c = :optimaxProcess.Id];
                                                                    
        System.debug( LoggingLevel.DEBUG,'loaded configurations - ' + config);
        
        String value = '';
        String formula = config.SVMXC__Formula__c;
        if(!String.isEmpty(formula)) {
           JSONParser parser = JSON.createParser(formula);
           while (parser.nextToken() != null) {
               if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == key)) {//(parser.getText() == 'emailId')) {
                   
                   parser.nextToken(); //Get the value.
                   value = parser.getText();
                   break;
               }
           }
        }
        System.debug( LoggingLevel.DEBUG,'Key - ' + key + ': Value - ' + value);
        System.debug( LoggingLevel.DEBUG, 'SPM_Utilities.loadConfigurationValue() - exit' );
        return value;
    }
    
    /**
     * Method to get the field name values for the given object
     */
    public List <String> getPickListValues (String objectName, String fieldName) {
        System.debug(LoggingLevel.DEBUG, 'SPM_Utilities.getPickListValues() - enter');
        System.debug(LoggingLevel.DEBUG, 'Populating the values for the picklist for object-name - '+objectName + ' and field-name - '+ fieldName); 
        List <String> pickListValues = new List<String>();
        List<Schema.DescribeFieldResult> describeFieldResultList = getDescribeFieldResultList( objectName );
               
        for( Schema.DescribeFieldResult describeFieldResult : describeFieldResultList ) {
           if( fieldName.equalsIgnoreCase( describeFieldResult.getName() ) ) {
               List<Schema.PicklistEntry> PicklistEntryList = describeFieldResult.getPicklistValues();
               for( Schema.PicklistEntry picklistEntry : PicklistEntryList ) {
                   pickListValues.add(picklistEntry.getValue());
               } 
               break;
           }
        }
        System.debug(LoggingLevel.DEBUG, 'Pick List Values - ' + pickListValues);
        System.debug(LoggingLevel.DEBUG, 'SPM_Utilities.getPickListValues() - exit');
        return pickListValues;
    }
    
    /**
     * Populate the list of supported display-types for Repeat-Visit flow.
     **/
    public Set<Schema.DisplayType> populateDisplayTypesForRepeatVisitComparison() {
        System.debug( LoggingLevel.DEBUG, 'SPM_Utilities.populateDisplayTypesForRepeatVisitComparison() - enter');    
        Set<Schema.DisplayType> displayTypes = new Set<Schema.DisplayType>();
        displayTypes.add(Schema.DisplayType.String);
        displayTypes.add(Schema.DisplayType.Picklist);
        displayTypes.add(Schema.DisplayType.Integer);
        displayTypes.add(Schema.DisplayType.Double);
        displayTypes.add(Schema.DisplayType.Percent);
        System.debug( LoggingLevel.DEBUG, 'Display Types - ' + displayTypes);
        System.debug( LoggingLevel.DEBUG, 'SPM_Utilities.populateDisplayTypesForRepeatVisitComparison() - exit');    
        return displayTypes;
    }
    
    /**
     * Populate the list of fields from the passed in object matching the display-type. 
     **/
    public List<SPM_ConfigurationDefinition.FieldInfo> getFieldsForDisplayType(String objectName, Set<Schema.DisplayType> displayTypes) {
        System.debug( LoggingLevel.DEBUG, 'SPM_Utilities.getFieldsForDisplayType() - enter');     
        System.debug(LoggingLevel.DEBUG, 'Loading the text fields for the object - ' + objectName);
        System.debug(LoggingLevel.DEBUG, 'Display types list - ' + displayTypes);
        List<SPM_ConfigurationDefinition.FieldInfo> textFields = new List<SPM_ConfigurationDefinition.FieldInfo>();
        Map<String,schema.sObjectField> mapOfWorkorderFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        //Non value is set to default on load.
        SPM_ConfigurationDefinition.FieldInfo fieldDefinition = new SPM_ConfigurationDefinition.FieldInfo();
        fieldDefinition.label = SPM_Consts.LABEL_NONE;
        fieldDefinition.name = SPM_Consts.NONE;
        fieldDefinition.displayType = Schema.DisplayType.String;
        textFields.add(fieldDefinition); 
        
        Map<String, String> fieldsMap = new Map<String, String>();
        for(Schema.sObjectField field:mapOfWorkOrderFields.values()) {
           
            if(displayTypes.contains(field.getDescribe().getType())) {
                if(field.getDescribe().getName() == 'Name') { //Ignore the Name column as it is auto-generated.
                    continue;
                }
                fieldsMap.put(field.getDescribe().getLabel(), field.getDescribe().getName());
            }
        }
        System.debug(LoggingLevel.DEBUG, 'fieldsMap - '+ fieldsMap);
        
        List<String> sortedFieldNames = getSortedKeyset(fieldsMap);
        for(String name: sortedFieldNames) {
            String mapValue = fieldsMap.get(name);
            fieldDefinition = new SPM_ConfigurationDefinition.FieldInfo();
            fieldDefinition.label = name;
            fieldDefinition.name = mapValue;
            textFields.add(fieldDefinition);
        }
        System.debug(LoggingLevel.DEBUG, 'Fields List to be rendered in the UI - ' + textFields);
        
        System.debug( LoggingLevel.DEBUG, 'SPM_Utilities.getFieldsForDisplayType() - exit');                              
        return textFields;
    }    
    
    /**
     * Sort the keys inside datamap and return back result as list.
     **/
    private List<String> getSortedKeyset(Map<String, String> dataMap) {
        System.debug( LoggingLevel.DEBUG, 'SPM_Utilities.getSortedKeyset() - enter'); 
        List<String> keySetList = new List<String>();
        keySetList.addAll(dataMap.keySet());
        keySetList.sort();
        System.debug( LoggingLevel.DEBUG, 'SPM_Utilities.getSortedKeyset() - exit'); 
        return keySetList;
    }
    
    /**
     * 
     */
    private SPM_Utilities() {        
    }
}