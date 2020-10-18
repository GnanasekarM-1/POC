/*****************************************************************************
 *                       Copyright (C) 2016 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/
//FLS and CRUD check is not required as this class is running batch mode
/**
 * This class is used to generate the RepeatVisit metrics for the finshed work-orders.
 * 
 *
 * @author Praveen.R
 * @version 1.0
 * @since 2016
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Praveen.R           09 Feb 2016     Created.
 *              Praveen.R           22 Feb 2016     Add code comments.
 *              Praveen.R           24 Feb 2016     Changed the algorithm for computing the RepeatVisit
 *              Praveen.R           10 Mar 2016     Updated logic to compare the Top-Level when IB is 
 *                                                  selected in the configuration screen.
 *              Manish Kushwah      01 Apr 2016     Security Fixes
 * 019174       Ramachandra Mohan   20 Apr 2016     Workaround for Salesforce limitaions in Database.Stateful
 * BAC-4050     Soumyaranjan Pati      28th June 2018  Security fixes.
 *****************************************************************************************************/
global with sharing class SPM_Repeat_Visit extends SPM_AbstractBatch {
    
    /**
     * Reference to util class for invoking the expression.
     */
    //private final COMM_SVMXC_Utils4 commUtils = new COMM_SVMXC_Utils4();

     /**
      * Holds the reference to the configuration object related to this Metrics.
      */
    private SVMXC__ServiceMax_Config_Data__c scheduleConfigData;
    
    /**
     * By default we set this value to 7 days. This will be over-ridden with user selected value.
     */
    private Integer configuredRepeatVisitDays = 7; 

    /**
     * Holds the reference to user selected fields for RepeatVisit check.
     */
    private List<String> listOfFieldsToBeMatchedForRepeatVisit;
    
    /**
     * Holds the name of the calculation method for which this metrics is getting generated.
     */
    private String calculationMethodName;

    /**
     * Holds the API name of the Account field.
     */
    private String accountFieldApi = '';
    
    /**
     * Holds the API name of the Location field.
     */
    private String locationFieldApi = '';
    
    /**
     * Holds the API name of the Top-level field. 
     */
    private String topLevelFieldApi = '';

    /**
     * Holds the API name of the Component's Top-level field. 
     */
    private String componentsTopLevelFieldApi = '';

    private String issueCodeFieldApi = '';

    private Set<Object> issueCodes = new Set<Object>();
    
    /**
     * Holds the unique list of account-ids that are present in the work-orders for the current batch.
     * This will be used to check for matching records in work-order table to calculate the RepeatVisit metrics.
     */
    private Set<String> accounts = new Set<String>();

    /**
     * Holds the unique list of location-ids that are present in the work-orders for the current batch.
     * This will be used to check for matching records in work-order table to calculate the RepeatVisit metrics.
     */
    private Set<String> locations = new Set<String>();

    /**
     * Holds the unique list of IB-ids that are present in the work-orders for the current batch.
     * This will be used to check for matching records in work-order table to calculate the RepeatVisit metrics.
     */
    private Set<String> topLevelProducts = new Set<String>();


    private Set<String> relatedWorkOrderIds = new Set<String>();

    /**
     * Global constructor invoke while this class is initalized.
     */
    global SPM_Repeat_Visit( SVMXC__ServiceMax_Config_Data__c scheduleData ) {        
        super(SPM_Schema.Report.RepeatVisit, scheduleData);  
        this.scheduleConfigData = scheduleData;
    }
    
    /**
     * Holds the referece to the saved business configuration.
     **/
    private SPM_ConfigurationDefinition.businessProcessConfig savedConfiguration;
    
    /**
     * Add the top-level object's expression along with the created-date and modified date to the base where clause.
     **/
    private void populateCreatedAndLastModifiedDateFields() {
        System.debug( LoggingLevel.DEBUG, 'SPM_FirstTimeFix.populateCreatedAndLastModifiedDateFields() - enter' );
        numberOfDays = getNumberOfDaysToQualifyRecords();
        if( numberOfDays == null ) numberOfDays = 120;
        Datetime previousExecution = System.now().addDays( (numberOfDays * -1) );
        String entryCriteria = '';
        
        //Saravana: SPM - Top Level Coding - Start  
        String topCriteria;
        
        System.debug(LoggingLevel.DEBUG,'Config Process - '+ savedConfiguration);         
        if(savedConfiguration != NULL && savedConfiguration.source != NULL) {
            if(savedConfiguration.source !='SVMXC__Service_Order__c') {
                //Changes for security scan.
                List<String> queryFields = new List<String> {'SVMXC__Field_Name__c','SVMXC__Expression_Rule__r.SVMXC__Parent_Object_Criteria__c'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                List<SVMXC__ServiceMax_Config_Data__c> expressions = [Select SVMXC__Field_Name__c ,SVMXC__Expression_Rule__r.SVMXC__Parent_Object_Criteria__c 
                                                                                From SVMXC__ServiceMax_Config_Data__c Where SVMXC__Expression_Rule__r.RecordType.Name ='SVMX Rule' 
                                                                                and SVMXC__Expression_Rule__r.SVMXC__ProcessID__c=:savedConfiguration.selectedCriteria 
                                                                                and RecordType.Name='Expressions']; 
                String source = SPM_Consts.WOCASERELATIONSHIP;
                if(savedConfiguration.source == 'Case') {
                    addQueryField( SPM_Consts.WOCASE, SPM_Consts.WOCASE );
                } else {
                    source = SPM_Consts.WOSRRELATIONSHIP;
                    addQueryField(SPM_Consts.WOSERVICEREQUESTFIELD, SPM_Consts.WOSERVICEREQUESTFIELD);            
                }
                
                if(!expressions.isEmpty()) {
                    topCriteria = expressions[0].SVMXC__Expression_Rule__r.SVMXC__Parent_Object_Criteria__c;
                    System.debug(LoggingLevel.DEBUG,'Base topCriteria - ' + topCriteria);
                    for(SVMXC__ServiceMax_Config_Data__c expression:expressions) {
                        String fieldName = expression.SVMXC__Field_Name__c;
                        System.debug(LoggingLevel.DEBUG,'fieldName - ' + fieldName);
                        if(topCriteria.contains(fieldName)) {
                            topCriteria = topCriteria.replace(fieldName, source + fieldName);
                        }
                    }
                }
                System.debug(LoggingLevel.DEBUG,'Updated topCriteria - ' + topCriteria);
                //Changes for filtering the records
                entryCriteria = source + 'CreatedDate >= ' + previousExecution.formatGmt( SPM_Consts.DEFAULT_DATETIME_FORMAT );
                if( scheduleData != null && scheduleData.SVMXC__Previous_Execution_Started_On__c != null ) {
                    previousExecution = scheduleData.SVMXC__Previous_Execution_Started_On__c;
                    entryCriteria = entryCriteria + ' AND '+ source + 'LastModifiedDate >= ' + previousExecution.formatGmt( SPM_Consts.DEFAULT_DATETIME_FORMAT );
                }
                entryCriteria = '('+entryCriteria+') AND ('+topCriteria+')'; 
                
            } else { // Primary Work-order case.
                addQueryField( SPM_Consts.RELATED_WORK_ORDER, SPM_Consts.RELATED_WORK_ORDER ); 
                addIgnoreNullCheckField( SPM_Consts.RELATED_WORK_ORDER );                       
            }
        } 
        
        //Back-ward compatibility flow changes.
        if(savedConfiguration == NULL || savedConfiguration.source == NULL || savedConfiguration.source == 'SVMXC__Service_Order__c') { 
            entryCriteria = 'CreatedDate >= ' + previousExecution.formatGmt( SPM_Consts.DEFAULT_DATETIME_FORMAT );
            if( scheduleData != null && scheduleData.SVMXC__Previous_Execution_Started_On__c != null ) {
                previousExecution = scheduleData.SVMXC__Previous_Execution_Started_On__c;
                entryCriteria = entryCriteria + ' AND LastModifiedDate >= ' + previousExecution.formatGmt( SPM_Consts.DEFAULT_DATETIME_FORMAT );
            }
        }
        System.debug( LoggingLevel.DEBUG, 'Entry Criteria - '+ entryCriteria );
        //Saravana Added for Top Level - End
        setWhereClause(entryCriteria);
        System.debug( LoggingLevel.DEBUG, 'SPM_FirstTimeFix.populateCreatedAndLastModifiedDateFields() - exit' );
    }
    
    /**
     * Loads the saved business process configuration and store the details to the class level attribute.
     **/
    private void loadBusinessProcessConfiguration() {
        System.debug( LoggingLevel.DEBUG, 'SPM_FirstTimeFix.loadBusinessProcessConfiguration() - enter' );
        List<SVMXC__ServiceMax_Config_Data__c> listOfData = SPM_ConfigurationDefinition.getBusinessProcessConfig();        
        System.debug(LoggingLevel.DEBUG, 'BusinessProcess - ' + listOfData); 
        if(listOfData != NULL && !listOfData.isEmpty()) {
            savedConfiguration =(SPM_ConfigurationDefinition.BusinessProcessConfig) JSON.deserialize(
                listOfData[0].SVMXC__Formula__c, SPM_ConfigurationDefinition.businessProcessConfig.class);                                                
        }
        System.debug( LoggingLevel.DEBUG, 'SPM_FirstTimeFix.loadBusinessProcessConfiguration() - exit' );
    }
    

    /**
     * This method is called when the class is invoked by the engine for the first time.
     */ 
    global override void initBatchConfiguration() {
        System.debug( LoggingLevel.DEBUG, 'SPM_Repeat_Visit.initBatchConfiguration() - enter' ); 
    
        parseConfigurationsAndIdenitifyNotNullFields(SPM_Schema.Field.IssueCode);
        //Saravana added    
        loadBusinessProcessConfiguration();
        populateCreatedAndLastModifiedDateFields();
        // setWhereClause(tempWhereClause);    
        setOrderBy('CreatedDate');       
        setAdditionalClause();  
        System.debug( LoggingLevel.DEBUG, 'SPM_Repeat_Visit.initBatchConfiguration() - exit' );
    }
    
    

    /**
     * Method to populate the value of certain fields based on configuration. Also remove certain fields from null check.
     */
    private void setAdditionalClause() {
        System.debug( LoggingLevel.DEBUG, 'SPM_Repeat_Visit.setAdditionalClause() - enter' );
        List<SPM_Schema.Field> listIgnoreFields = new List<SPM_Schema.Field>{
            SPM_Schema.Field.ServiceContract, 
            SPM_Schema.Field.Warranty, SPM_Schema.Field.RelatedWorkOrder};

        String team = getSourceObjectField( SPM_Schema.Field.Technician ).replace('__c', '__r') + '.' + 'SVMXC__Service_Group__c';
        String manager = getSourceObjectField( SPM_Schema.Field.Technician ).replace('__c', '__r') + '.' + 'SVMXC__Salesforce_User__r.ManagerId';
       
        addQueryField( SPM_Schema.Field.Team, team );
        addQueryField( SPM_Schema.Field.Manager, manager );

        addIgnoreNullCheckField(team);
        addIgnoreNullCheckField(manager);
        addIgnoreNullCheckField(listIgnoreFields);

        System.debug( LoggingLevel.DEBUG, 'SPM_Repeat_Visit.setAdditionalClause() - exit' );
    }


    /**
     * Holds the the number of days for which the work-order needs to be processed.
     */
    private Integer numberOfDays = 0;

    /**
     * Method to generate the where clause for record filtering during the batch execution.
     * @return where clause for filtering the records.
     */
    // private String getRepeatVisitWhereClause() {
    //     System.debug( LoggingLevel.DEBUG, 'SPM_Repeat_Visit.getRepeatVisitWhereClause() - enter' );

    //     //Get the configured start date range from the configuration.
    //     numberOfDays = getNumberOfDaysToQualifyRecords();        
    //     if( numberOfDays == null ) {
    //         numberOfDays = 120;        
    //     }
    //     Datetime previousExecution = System.now().addDays((numberOfDays * -1));        
    //     String entryCriteria = 'CreatedDate >= ' + previousExecution.formatGmt(SPM_Consts.DEFAULT_DATETIME_FORMAT);
        
    //     if( scheduleData != null && scheduleData.SVMXC__Previous_Execution_Started_On__c != null ) {            
    //         previousExecution = scheduleData.SVMXC__Previous_Execution_Started_On__c;
    //         entryCriteria = entryCriteria + ' AND LastModifiedDate >= ' + previousExecution.formatGmt(SPM_Consts.DEFAULT_DATETIME_FORMAT);
    //     }         
    //     System.debug( LoggingLevel.DEBUG, 'SPM_Repeat_Visit.getRepeatVisitWhereClause() - exit  <=> where clause - '+entryCriteria );
    //     return entryCriteria;
    // }

    /**
     * Method to populate the user selected fields for identifying the RepeatVisit-metric records.
     */
    private void populateUserSelectedFieldsForRepeatVisit() {
        System.debug( LoggingLevel.DEBUG, 'SPM_Repeat_Visit.populateUserSelectedFieldsForRepeatVisit() - entry ');  
        String fieldsForRepeatVisitCheck = (String) getSourceObjectField(SPM_Schema.Field.RepeatVisitQualifier);
        System.debug( LoggingLevel.DEBUG, 'fieldsForRepeatVisitCheck - '+fieldsForRepeatVisitCheck);
        //Saravana added
        String additionalCriteriaFields = (String) getSourceObjectField(SPM_Schema.Field.IssueCode);
        System.debug( LoggingLevel.DEBUG, 'additionalCriteriaFields - '+ additionalCriteriaFields);
        //Saravana added
        if(fieldsForRepeatVisitCheck.length() > 0) {            
            listOfFieldsToBeMatchedForRepeatVisit = fieldsForRepeatVisitCheck.split(';');
        } else {
            listOfFieldsToBeMatchedForRepeatVisit = new List<String>();
        }
        if(additionalCriteriaFields != NULL && additionalCriteriaFields != SPM_Consts.NONE && additionalCriteriaFields != SPM_Consts.REPEAT_VISIT_ADDITIONAL_COMPARISION_FIELD) {
            listOfFieldsToBeMatchedForRepeatVisit.add('IssueCode');
        }
        if(getSourceObjectField(SPM_Schema.Field.RepeatVisitWindow) != null) {
            configuredRepeatVisitDays = Integer.valueof(getSourceObjectField(SPM_Schema.Field.RepeatVisitWindow));            
            System.debug( LoggingLevel.DEBUG, 'Configured Days - '+configuredRepeatVisitDays);
        }

        setMatchingFieldApi();
        System.debug( LoggingLevel.DEBUG, 'SPM_Repeat_Visit.populateUserSelectedFieldsForRepeatVisit() - exit '+ fieldsForRepeatVisitCheck);  
    }

    /**
     * Method to get the RepeatVisit-key from the passed-in record based on user selected configuration.
     * 
     * @param  record - current record in context
     * @return computed RepeatVisit key
     */
    private String getRepeatVisitKeyForMatchingFields(SObject record) {
        System.debug( LoggingLevel.DEBUG, 'SPM_Repeat_Visit.getRepeatVisitKeyForMatchingFields() - entry'+record );
        String repeatVisitKey = '';
        System.debug( LoggingLevel.DEBUG, 'listOfFieldsToBeMatchedForRepeatVisit - '+listOfFieldsToBeMatchedForRepeatVisit);
        for(String entry: listOfFieldsToBeMatchedForRepeatVisit) {
            //System.debug( LoggingLevel.DEBUG, 'Entry - '+entry);  
            if(entry.equalsIgnoreCase('Account')) {
                repeatVisitKey += (String)getSourceObjectFieldValue(record, SVMXC.SPM_Schema.Field.Account);  
                System.debug('Account ='+(String)getSourceObjectFieldValue(record, SVMXC.SPM_Schema.Field.Account));              
            } else if(entry.equalsIgnoreCase('Location')) {
              repeatVisitKey += (String)getSourceObjectFieldValue(record, SVMXC.SPM_Schema.Field.Location);
                System.debug('Account ='+(String)getSourceObjectFieldValue(record, SVMXC.SPM_Schema.Field.Location));
            } else if(entry.equalsIgnoreCase('Installed Product')) {
                repeatVisitKey += (String)getSourceObjectFieldValue(record, SVMXC.SPM_Schema.Field.InstallProduct);
                System.debug('Installed Product ='+(String)getSourceObjectFieldValue(record, SVMXC.SPM_Schema.Field.InstallProduct));                
            } else if(entry.equalsIgnoreCase('IssueCode')) {
                System.debug(LoggingLevel.INFO,'IssueCode - ' + getSourceObjectField(SPM_Schema.Field.IssueCode));   
                System.debug(LoggingLevel.INFO,'Field value - ' + record.get(getSourceObjectField(SPM_Schema.Field.IssueCode)));
                if(record.get(getSourceObjectField(SPM_Schema.Field.IssueCode)) != null) {
                    String issueCode = String.valueOf(record.get(getSourceObjectField(SPM_Schema.Field.IssueCode))); //(String)record.get(getSourceObjectField(SPM_Schema.Field.IssueCode));
                    repeatVisitKey += issueCode.toLowerCase();
                }
            }
        }
        System.debug(LoggingLevel.DEBUG, 'SPM_Repeat_Visit.getRepeatVisitKeyForMatchingFields() - exit with RepeatVisit-key ' + repeatVisitKey);
        return repeatVisitKey;
    }
  
    /**
     * Populated the api values for the user selected comparison fields.
     */
    private void setMatchingFieldApi() {
        System.debug(LoggingLevel.DEBUG, 'SPM_Repeat_Visit.setMatchingFieldApi() - entry');
        for(String entry: listOfFieldsToBeMatchedForRepeatVisit) {
            System.debug( LoggingLevel.DEBUG, 'Entry - '+entry);  
            if(entry.equalsIgnoreCase('Account')) {
                accountFieldApi = (String)getSourceObjectField(SVMXC.SPM_Schema.Field.Account);
                System.debug( LoggingLevel.DEBUG, 'Account Field API - ' + accountFieldApi);
            } else if(entry.equalsIgnoreCase('Location')) {
                locationFieldApi = (String)getSourceObjectField(SVMXC.SPM_Schema.Field.Location);  
                System.debug( LoggingLevel.DEBUG, 'Location Field API - ' + locationFieldApi);               
            } else if(entry.equalsIgnoreCase('Installed Product')) {
                topLevelFieldApi = (String) getSourceObjectField(SVMXC.SPM_Schema.Field.InstallProduct);    
                System.debug( LoggingLevel.DEBUG, 'IB Field API - ' + topLevelFieldApi);   
            } else if(entry.equalsIgnoreCase('IssueCode')) {
                issueCodeFieldApi = (String) getSourceObjectField(SVMXC.SPM_Schema.Field.IssueCode);             
                System.debug( LoggingLevel.DEBUG, 'Issue Code Field API - ' + issueCodeFieldApi);
            }            
        }
        System.debug(LoggingLevel.DEBUG, 'SPM_Repeat_Visit.setMatchingFieldApi() - exit');
    }
 
    /**
     * Reset the attributes used for computing the RepeatVisit calculation.     
     */
    private void resetFieldsForBatchExecution() {
        System.debug(LoggingLevel.DEBUG, 'SPM_Repeat_Visit.resetFieldsForBatchExecution() - entry');      
        accounts.clear(); 
        locations.clear();
        topLevelProducts.clear();
        relatedWorkOrderIds.clear();
        //Saravana added
        issueCodes.clear();
        //Saravana added
        System.debug(LoggingLevel.DEBUG, 'SPM_Repeat_Visit.resetFieldsForBatchExecution() - exit');
    }
    
    /**
     * Apex Batch engine invokes this method for processing the records.
     * 
     * @param records - List of retireved records chunk processed in batches.
     */
    global override void handleRecords(List<SObject> records) {        
        
        System.debug(LoggingLevel.DEBUG, 'SPM_Repeat_Visit.handleRecords() - enter; records count: ' + records.size());
        //Saravana added
        // List<SVMXC__ServiceMax_Config_Data__c> listOfData = SPM_ConfigurationDefinition.getBusinessProcessConfig();        
        // SPM_ConfigurationDefinition.businessProcessConfig newConfig; 
        // String parentCriteria,topCriteria;    
        // if(!listOfData.isEmpty() && listOfData[0].SVMXC__Formula__c !=NULL )
        // {
        //     newConfig = (SPM_ConfigurationDefinition.businessProcessConfig)(JSON.deserialize(listOfData[0].SVMXC__Formula__c,SPM_ConfigurationDefinition.businessProcessConfig.class));
        // }
        //Saravana added         
        SVMXC__Service_Order__c workOrderRecord;
        SVMXC__Service_Order__c parentWorkOrder;
        String repeatVisitKey = '';
        String repeatVisitKeyForComponentsTopLevel = '';
        List<String> listOfworkOrderIds = new List<String>();
        SVMXC__SPM_Repeat_Visit__c repeatVisitObject;

        resetFieldsForBatchExecution();
        populateUserSelectedFieldsForRepeatVisit(); 
        calculationMethodName = getCalculationMethodName();
        System.debug( LoggingLevel.DEBUG, 'Calculation method name used for generating the Utilization Metrics - ' + calculationMethodName);
       
        Map<String, SVMXC__SPM_Repeat_Visit__c> mapOfRepeatVisitsWithWorkorderIdKey = new Map<String, SVMXC__SPM_Repeat_Visit__c>();
        Map<String, SVMXC__Service_Order__c> mapOfWorkOrdersWithRepeatVisitKey = new Map<String, SVMXC__Service_Order__c>();
        
        for(SObject record : records) {
            String workOrderId = (Id)getSourceObjectFieldValue(record, SPM_Schema.Field.Id);
            listOfworkOrderIds.add(workOrderId);          
            
            Map<String, Object> workorderMap = ( Map<String, Object> ) (( Map<String, Object> ) JSON.deserializeUntyped( JSON.serialize( record ) ) );
            SObject workorderobject = (SObject) JSON.deserialize( JSON.serialize( workorderMap ), SObject.class );
        }

        Map<String, SVMXC__SPM_Repeat_Visit__c> mapOfExistingRepeatVisitObjectsWithWorkOrderIdKey = populateExistingRepeatVisitedRecords(listOfworkOrderIds);

        for(SObject record : records) {    
            workOrderRecord = (SVMXC__Service_Order__c)record;
            if(mapOfExistingRepeatVisitObjectsWithWorkOrderIdKey.containsKey((Id)getSourceObjectFieldValue(workOrderRecord, SPM_Schema.Field.Id))) {
                repeatVisitObject = mapOfExistingRepeatVisitObjectsWithWorkOrderIdKey.get((Id)getSourceObjectFieldValue(workOrderRecord, SPM_Schema.Field.Id));                
            } else {
                repeatVisitObject = createRepeatVisitObject(workOrderRecord);
                populateIssueLevelFields(record, repeatVisitObject);
            }            
            
            mapOfRepeatVisitsWithWorkorderIdKey.put(repeatVisitObject.SVMXC__Work_Order__c, repeatVisitObject);

            System.debug( LoggingLevel.DEBUG, 'Workorder record - ' + workOrderRecord);
            //Get the RepeatVisit-key based on the user selected the comparison fields
            repeatVisitKey = getRepeatVisitKeyForMatchingFields(workOrderRecord);
            System.debug( LoggingLevel.DEBUG, 'Generated RepeatVisit-key - '+ repeatVisitKey +' for work-order - ' + workOrderRecord.Name);
            if(repeatVisitKey != '') { //Ignore the record for further checks.                
                if(mapOfWorkOrdersWithRepeatVisitKey.containsKey(repeatVisitKey)) {                    
                    parentWorkOrder = (SVMXC__Service_Order__c) mapOfWorkOrdersWithRepeatVisitKey.get(repeatVisitKey);                     
                    System.debug( LoggingLevel.DEBUG, 'Found a previously matched record - '+parentWorkOrder.Name);
                    if(meetsSubsequentCriteria(workOrderRecord)) {
                        System.debug( LoggingLevel.DEBUG, 'Meets the sub-sequent work-order matching criteria');
                        if(isWithinConfiguredDays(parentWorkOrder, workOrderRecord)
                            && hasMatchingParentWorkOrderId(parentWorkOrder, workOrderRecord)
                            && !isFromSameSource(parentWorkOrder, workOrderRecord)) {
                            System.debug( LoggingLevel.DEBUG, 'Meets the days and parent work-order match');
                            repeatVisitObject = mapOfRepeatVisitsWithWorkorderIdKey.get((Id)getSourceObjectFieldValue(parentWorkOrder, SPM_Schema.Field.Id));
                            updateRepeatVisitObject(repeatVisitObject, workOrderRecord);
                        } else {
                          System.debug( LoggingLevel.DEBUG, 'Does not meet the days and parent work-order match');
                          populateValuesForLoadingParentWorkOrders(workOrderRecord);
                        }                    
                    } 
                } else if(meetsSubsequentCriteria(workOrderRecord)) {
                    System.debug( LoggingLevel.DEBUG, 'Meets the sub-sequent work-order matching criteria without any matching record within the batch');                    
                    populateValuesForLoadingParentWorkOrders(workOrderRecord);
                }
                mapOfWorkOrdersWithRepeatVisitKey.put(repeatVisitKey, workOrderRecord); 
            } else {
                //This block is executed when user doesn't select any field for comparision and chooses the option 'yes' for 
                //related-work-order field comparison.  
                repeatVisitKey = workOrderRecord.Id;                
                if(meetsSubsequentCriteria(workOrderRecord) && isPrimaryWorkOrderMatchNeeded()) {
                   Id primaryWorkOrderId = getPrimaryWorkOrderId(workOrderRecord);
                   if(primaryWorkOrderId != null && mapOfWorkOrdersWithRepeatVisitKey.containsKey(primaryWorkOrderId)) { 
                        parentWorkOrder = (SVMXC__Service_Order__c) mapOfWorkOrdersWithRepeatVisitKey.get(primaryWorkOrderId);
                        if(isWithinConfiguredDays(parentWorkOrder, workOrderRecord)) {                                                        
                            System.debug( LoggingLevel.DEBUG, 'Parent work-order match found');
                            repeatVisitObject = mapOfRepeatVisitsWithWorkorderIdKey.get(primaryWorkOrderId);
                            updateRepeatVisitObject(repeatVisitObject, workOrderRecord);
                        }
                    } else {
                        System.debug( LoggingLevel.DEBUG, 'Meets the sub-sequent work-order matching criteria without any matching record within the batch');    
                        System.debug( LoggingLevel.DEBUG, 'primaryWorkOrderId - '+primaryWorkOrderId);
                        addRelatedWorkOrderId(primaryWorkOrderId);
                    }        
                }                        
                mapOfWorkOrdersWithRepeatVisitKey.put(repeatVisitKey, workOrderRecord);                
            }
        }

        //Save the RepeatVisit records.
        if(mapOfRepeatVisitsWithWorkorderIdKey.size() > 0) {
            List<SVMXC__SPM_Repeat_Visit__c> lstRepeatVisitRecords = mapOfRepeatVisitsWithWorkorderIdKey.values();
            performFieldMapping(records, lstRepeatVisitRecords);
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstRepeatVisitRecords, COMM_SecurityUtils.Access.Upsertable)){
                upsert lstRepeatVisitRecords;
                //createOrUpdateSummary(lstRepeatVisitRecords);
                if(savedConfiguration != NULL && savedConfiguration.source != NULL) {
                    if(savedConfiguration.source=='Case') {
                        updateSummaryForCase(lstRepeatVisitRecords);
                    } else if(savedConfiguration.source == 'SVMXC__Service_Request__c') {
                        updateSummaryForServiceRequest(lstRepeatVisitRecords);
                    } else {
                        updateSummaryForPrimaryWorkorder(lstRepeatVisitRecords);
                    }
                }
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        }

        Map<String, SVMXC__Service_Order__c> mapOfExistingWorkOrdersWithRepeatVisitKey = new Map<String, SVMXC__Service_Order__c>();     
        //Update the RepeatVisit status of previously processed records.    
        populateExistingWorkOrdersWithRepeatVisitKey(listOfworkOrderIds,  mapOfExistingWorkOrdersWithRepeatVisitKey); 
        updateProcessedRecords(mapOfExistingWorkOrdersWithRepeatVisitKey, mapOfWorkOrdersWithRepeatVisitKey);        
    } 
    
    /**
     * Populate the top-level issue information to target table.
     **/
    private void populateIssueLevelFields(SObject record, SVMXC__SPM_Repeat_Visit__c repeatVisitObject) {
        if(savedConfiguration != NULL && savedConfiguration.source != NULL) {
            if(savedConfiguration.source=='Case') {
                if(record.get(SPM_Consts.WOCASE) !=NULL) {                
                    repeatVisitObject.SVMXC__Case__c = (Id) record.get(SPM_Consts.WOCASE);                    
                }
            } else if(savedConfiguration.source == 'SVMXC__Service_Request__c') {
                if(record.get(SPM_Consts.WOSERVICEREQUESTFIELD) !=NULL) {                
                    repeatVisitObject.SVMXC__Service_Request__c = (Id) record.get(SPM_Consts.WOSERVICEREQUESTFIELD);                    
                }
            } else {
                if(record.get(SPM_Consts.RELATED_WORK_ORDER) != NULL) {                                               
                    repeatVisitObject.SVMXC__Primary_Work_Order__c = (Id) record.get(SPM_Consts.RELATED_WORK_ORDER);                                            
                } else {                                               
                    repeatVisitObject.SVMXC__Primary_Work_Order__c = (Id) record.get( SPM_Consts.RECORD_ID );                                            
                }                    
            }
        }
    }
    

    /**
     * [updateProcessedRecords description]
     * @param mapOfExistingWorkOrdersWithRepeatVisitKey [description]
     * @param mapOfWorkOrdersWithRepeatVisitKey         [description]
     */
    private void updateProcessedRecords(Map<String, SVMXC__Service_Order__c> mapOfExistingWorkOrdersWithRepeatVisitKey, 
                                        Map<String, SVMXC__Service_Order__c> mapOfWorkOrdersWithRepeatVisitKey) {
      
      System.debug(LoggingLevel.DEBUG, 'SPM_Repeat_Visit.updateProcessedRecords() - enter'+mapOfExistingWorkOrdersWithRepeatVisitKey+'='+mapOfWorkOrdersWithRepeatVisitKey);
      if(mapOfExistingWorkOrdersWithRepeatVisitKey.size() > 0)  {
          SVMXC__Service_Order__c workOrderRecord;
          SVMXC__Service_Order__c parentWorkOrder;
          SVMXC__SPM_Repeat_Visit__c repeatVisitObject;

          List<String> listOfExistingWorkOrderIds = new List<String>();
          for(SVMXC__Service_Order__c value: mapOfExistingWorkOrdersWithRepeatVisitKey.values()) {
              listOfExistingWorkOrderIds.add(value.Id);
          }

          Map<String, SVMXC__SPM_Repeat_Visit__c> mapOfExistingRepeatVisitObjectsWithWorkOrderIdKey =  
                                                      populateExistingRepeatVisitedRecords(listOfExistingWorkOrderIds);

          List<SVMXC__SPM_Repeat_Visit__c> updatedRepeatVisitObjects = new List<SVMXC__SPM_Repeat_Visit__c>();

           for(String key: mapOfWorkOrdersWithRepeatVisitKey.keySet()) {

              //Check if the user has not selected any matching field and have selected the option to compare the 
              //primary work-order.
              workOrderRecord = mapOfWorkOrdersWithRepeatVisitKey.get(key);              
              if(listOfFieldsToBeMatchedForRepeatVisit.size() == 0) {
                  key = getPrimaryWorkOrderId(workOrderRecord);
              } 
              System.debug(LoggingLevel.DEBUG,'Key compared on the work order object - '+key);
              if(mapOfExistingWorkOrdersWithRepeatVisitKey.containsKey(key)) {
                  parentWorkOrder = mapOfExistingWorkOrdersWithRepeatVisitKey.get(key);

                  if(isWithinConfiguredDays(parentWorkOrder, workOrderRecord)
                        && meetsSubsequentCriteria(workOrderRecord)
                        && hasMatchingParentWorkOrderId(parentWorkOrder, workOrderRecord)
                        && !isFromSameSource(parentWorkOrder, workOrderRecord)) {
                        System.debug(LoggingLevel.DEBUG, 'Id used for RepeatVisit - '+(Id)getSourceObjectFieldValue(parentWorkOrder, SPM_Schema.Field.Id));
                        repeatVisitObject = mapOfExistingRepeatVisitObjectsWithWorkOrderIdKey.get(
                            (Id)getSourceObjectFieldValue(parentWorkOrder, SPM_Schema.Field.Id));
                      if(repeatVisitObject != null) {
                          updateRepeatVisitObject(repeatVisitObject, workOrderRecord);
                          updatedRepeatVisitObjects.add(repeatVisitObject);
                      }
                  }
              }
           }

            if(updatedRepeatVisitObjects.size() > 0) {
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(updatedRepeatVisitObjects, COMM_SecurityUtils.Access.Upsertable)){
                    upsert updatedRepeatVisitObjects;
                    
                    if(savedConfiguration != NULL && savedConfiguration.source != NULL) {
                        if(savedConfiguration.source=='Case') {
                            updateSummaryForCase(updatedRepeatVisitObjects);
                        } else if(savedConfiguration.source == 'SVMXC__Service_Request__c') {
                            updateSummaryForServiceRequest(updatedRepeatVisitObjects);
                        } else {
                            updateSummaryForPrimaryWorkorder(updatedRepeatVisitObjects);
                        }
                    }
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
        } 
        System.debug(LoggingLevel.DEBUG, 'SPM_Repeat_Visit.updateProcessedRecords() - exit');       
    }

    private Id getPrimaryWorkOrderId(SVMXC__Service_Order__c workOrder) {
        System.debug('What is the primaryworkOrder Id '+(Id) getSourceObjectFieldValue(workOrder, SPM_Schema.Field.RelatedWorkOrder));
        return (Id) getSourceObjectFieldValue(workOrder, SPM_Schema.Field.RelatedWorkOrder);
    }


    /**
     * Method to load the list of work-orders having the matching fields selected by the user in 
     * the configuration screen. The values are computed from the current batch of work-orders.
     * 
     * @param  workOrdersIdsInBatch 
     * @return Map of matching work-orders with the RepeatVisit-key
     */
    private void populateExistingWorkOrdersWithRepeatVisitKey (List<String> workOrdersIdsInBatch, 
                                                          Map<String, SVMXC__Service_Order__c> mapOfWorkOrdersWithRepeatVisitKey) {         
      System.debug(LoggingLevel.DEBUG, 'SPM_Repeat_Visit.populateExistingWorkOrdersWithRepeatVisitKey() - enter');

      if((workOrdersIdsInBatch.size() > 0) 
            && (accounts.size() > 0 || locations.size() > 0 || topLevelProducts.size() > 0 || relatedWorkOrderIds.size() > 0 || issueCodes.size()>0)) {//Saravana added
            List<SVMXC__Service_Order__c> workOrders = new List<SVMXC__Service_Order__c>();      
            String repeatVisitKey = '';
            String repeatVisitKeyForComponentsTopLevel = '';

            //List of fields API name for App Security check
            List<String> queryFields = new List<String> {'Id', 'Name'};
            
            String selectClause = 'select Id, Name, ';  
            if(savedConfiguration != NULL && savedConfiguration.source != NULL && savedConfiguration.source !='SVMXC__Service_Order__c') {
                if(savedConfiguration.source == 'Case') {
                    selectClause += SPM_Consts.WOCASE + ', '; 
                } else {
                    selectClause += SPM_Consts.WOSERVICEREQUESTFIELD + ', '; //savedConfiguration.source + ', '; 
                }
            }
            String incidentFieldApi = (String)getSourceObjectField(SVMXC.SPM_Schema.Field.ServiceDeliveredOn);  
            selectClause += incidentFieldApi+ ', ';  
            queryFields.add(incidentFieldApi);
            
            String whereClause = 'where ';
            if(accounts.size() > 0) {
                queryFields.add(accountFieldApi);
                selectClause += accountFieldApi + ',';
                whereClause += accountFieldApi +' IN: accounts and ';              
            }
            if(locations.size() > 0) {
                queryFields.add(locationFieldApi);
                selectClause += locationFieldApi + ',';
                whereClause += locationFieldApi +' IN: locations and ';
            }
            if(topLevelProducts.size() > 0) {
                queryFields.add(topLevelFieldApi);
                selectClause += topLevelFieldApi + ',';
                whereClause += topLevelFieldApi +' IN: topLevelProducts and ';          
            }  
            
            //Saravana added
            if(issueCodes.size() > 0) {
                System.debug(LoggingLevel.DEBUG, 'What is in issuecodes '+issueCodes+' and fields = '+issueCodeFieldApi);
                queryFields.add(issueCodeFieldApi);
                selectClause += issueCodeFieldApi + ',';
                //type cast the value before executing the query else we get soql exception.
                if(!(issueCodes.size() == 1 && issueCodes.contains(null))) {
                    List<Object> issueCodesList = new List<Object>(issueCodes);
                    Object tempValue = issueCodesList.get(0);
                    if(tempValue instanceof Double) {
                        System.debug(LoggingLevel.DEBUG, 'Data is of double data-type - ' + issueCodesList);
                        //add logic for double where clause
                        Set<Double> doubleDatatypeValues = new Set<Double>();
                        for(Object code: issueCodesList) {
                            doubleDatatypeValues.add(Double.valueOf(code));
                        }
                        whereClause += issueCodeFieldApi +' IN: doubleDatatypeValues and ';
                    } else if(tempValue instanceof Integer) {
                        System.debug(LoggingLevel.DEBUG, 'Data is of Integer data-type - ' + issueCodesList);
                        //add logic for Integer where clause
                        Set<Integer> integerDatatypeValues = new Set<Integer>();
                        for(Object code: issueCodesList) {
                            integerDatatypeValues.add(Integer.valueOf(code));
                        }
                        whereClause += issueCodeFieldApi +' IN: integerDatatypeValues and ';
                    } else if(tempValue instanceof String) {
                        System.debug(LoggingLevel.DEBUG, 'Data is of String data-type - ' + issueCodesList);
                        //add logic for String where clause
                        Set<String> stringDatatypeValues = new Set<String>();
                        for(Object code: issueCodesList) {
                            stringDatatypeValues.add(String.valueOf(code));
                        }
                        whereClause += issueCodeFieldApi +' IN: stringDatatypeValues and ';
                    }
                }
            }  
            //Saravana added                      
            whereClause += ' Id Not IN: workOrdersIdsInBatch and ';

            if(relatedWorkOrderIds.size() > 0) {
                String sourceFieldApi = getSourceObjectField(SVMXC.SPM_Schema.Field.RelatedWorkOrder);
                queryFields.add(sourceFieldApi);
                selectClause += sourceFieldApi+',';
                whereClause += 'Id IN: relatedWorkOrderIds and '; 
            }
            
            //add the create-date check from the configuration.
            Datetime previousExecution = System.now().addDays((numberOfDays * -1));
            previousExecution.addDays(configuredRepeatVisitDays * -1);
            whereClause += ' CreatedDate >= ' + previousExecution.formatGmt( SPM_Consts.DEFAULT_DATETIME_FORMAT );

            String entryCriteria = getExpressionCriteria(SPM_Schema.ExpressionType.QualificationCriteria);
            System.debug(LoggingLevel.DEBUG, 'entryCriteria - '+entryCriteria);
            if(!String.isEmpty(entryCriteria)) {
              whereClause += ' and (' + entryCriteria;
            }
            
            //Calling security util class for checking access
            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Service_Order__c', queryFields, COMM_SecurityUtils.Access.Accessible)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            selectClause = selectClause.substring(0, selectClause.length() - 1);
            String orderByClause = ') order by CreatedDate';
            String queryString = selectClause + ' from SVMXC__Service_Order__c ' + whereClause + orderByClause;
            System.debug(LoggingLevel.DEBUG, 'Query for fetching the list of primary Work-orders  - ' + queryString);
            
            workOrders = Database.query(queryString);
           
            System.debug(LoggingLevel.DEBUG,'List of loaded Workorders - '+workOrders.size());
            if(workOrders.size() > 0) {
                //Create a map of RepeatVisit-key with values
                for(SVMXC__Service_Order__c record: workOrders) {
                System.debug('What is in this record '+record);
                    repeatVisitKey = getRepeatVisitKeyForMatchingFields(record);
                    if(String.isEmpty(repeatVisitKey)) {
                        repeatVisitKey = record.Id;
                    }                    
                    System.debug(LoggingLevel.DEBUG,'repeatVisitKey - '+repeatVisitKey);
                    mapOfWorkOrdersWithRepeatVisitKey.put(repeatVisitKey, record);
                }
            }
        }
        System.debug(LoggingLevel.DEBUG, 'SPM_Repeat_Visit.populateExistingWorkOrdersWithRepeatVisitKey() - exit'+mapOfWorkOrdersWithRepeatVisitKey);
    }

    private void addRelatedWorkOrderId(Id parentWorkOrderId) {
        relatedWorkOrderIds.add(parentWorkOrderId);  
    }

    /**
     * Method to populate the values from the user selected fields for the passed in work-order.
     * @param record - work-order in context
     */
    private void populateValuesForLoadingParentWorkOrders(SVMXC__Service_Order__c record) {
        System.debug( LoggingLevel.DEBUG, 'SPM_Repeat_Visit.populateValuesForLoadingParentWorkOrders() - entry'+record );
        
        for(String entry: listOfFieldsToBeMatchedForRepeatVisit) {
            //System.debug( LoggingLevel.DEBUG, 'Entry - '+entry);  
            if(entry.equalsIgnoreCase('Account')) {
                accounts.add((String)getSourceObjectFieldValue(record, SVMXC.SPM_Schema.Field.Account));
            } else if(entry.equalsIgnoreCase('Location')) {
                locations.add((String)getSourceObjectFieldValue(record, SVMXC.SPM_Schema.Field.Location));
            } else if(entry.equalsIgnoreCase('Installed Product')) {                
                topLevelProducts.add((String)getSourceObjectFieldValue(record, SVMXC.SPM_Schema.Field.InstallProduct)); //getToplLevelValue(record));                
            } else if(entry.equalsIgnoreCase('IssueCode')) { 
                System.debug('What is in this code '+ getSourceObjectFieldValue(record, SVMXC.SPM_Schema.Field.IssueCode));
                //if(record.get(issueCodeFieldApi) != NULL) {               
                issueCodes.add(record.get(issueCodeFieldApi)); //String.valueOf(record.get(issueCodeFieldApi))); //getToplLevelValue(record));                
                //}
            }
        }
        System.debug(LoggingLevel.DEBUG, 'SPM_Repeat_Visit.populateValuesForLoadingParentWorkOrders() - exit');
    }
   

    /**
     * Method to check if the work-orders were created within the days specified in configuration.
     * 
     * @param parentWorkOrder - Parent Work order
     * @param subSequentWorkOrder - Sub sequent Work order
     * @return true/false based on the days difference against the configured range
     */
    private Boolean isWithinConfiguredDays(SVMXC__Service_Order__c parentWorkOrder, SVMXC__Service_Order__c subSequentWorkOrder) {
        System.debug(LoggingLevel.DEBUG, 'SPM_Repeat_Visit.isWithinConfiguredDays() - enter');
        Boolean isValid = false;
        
        Datetime dateTimeOnParentWorkOrder = (Datetime) getSourceObjectFieldValue(parentWorkOrder, SPM_Schema.Field.ServiceDeliveredOn );
        Datetime dateTimeOnSubsequentWorkOrder = (Datetime) getSourceObjectFieldValue(subSequentWorkOrder, SPM_Schema.Field.ServiceDeliveredOn );

        if(dateTimeOnParentWorkOrder != null && dateTimeOnSubsequentWorkOrder != null) {
            Integer numberOfDays = dateTimeOnParentWorkOrder.Date().daysBetween(
                dateTimeOnSubsequentWorkOrder.Date());
            System.debug( LoggingLevel.DEBUG, 'numberOfDays - configuredRepeatVisitDays : '+numberOfDays+' - '+configuredRepeatVisitDays);
            if(numberOfDays <= configuredRepeatVisitDays) {
                isValid = true;
            } 
        } else {
            System.debug( LoggingLevel.DEBUG, 'Date field used for checking the RepeatVisit-days is null in one of the Work Orders -  WO1 - ' 
              + parentWorkOrder.Name + 'WO2 - ' + subSequentWorkOrder.Name);
        }
        System.debug( LoggingLevel.DEBUG, 'isWithinConfiguredDays - ' + isValid);
        System.debug(LoggingLevel.DEBUG, 'SPM_Repeat_Visit.isWithinConfiguredDays() - exit');
        return isValid;
    }

    /**
     * Method to check if the work-order has parent work-order Id based on configuration setting.
     * 
     * @param parentWorkOrder - Parent Work order
     * @param subSequentWorkOrder - Sub sequent Work order
     * @return true/false based on the parent work-order Id presence
     */
    private Boolean hasMatchingParentWorkOrderId(SVMXC__Service_Order__c parentWorkOrder, 
                                              SVMXC__Service_Order__c subSequentWorkOrder) {
        System.debug(LoggingLevel.DEBUG, 'SPM_Repeat_Visit.hasMatchingParentWorkOrderId() - enter');
        Boolean isValid = true;
        if(isPrimaryWorkOrderMatchNeeded()) {                            
            Id relatedWorkOrderId = (Id) getSourceObjectFieldValue(subSequentWorkOrder, SPM_Schema.Field.RelatedWorkOrder);
            Id parentWorkOrderId = (Id) getSourceObjectFieldValue(parentWorkOrder, SPM_Schema.Field.Id);
            System.debug( LoggingLevel.DEBUG, 'relatedWorkOrderId - '+relatedWorkOrderId);
            System.debug( LoggingLevel.DEBUG, 'parentWorkOrderId - '+parentWorkOrderId);
            if(relatedWorkOrderId == null || parentWorkOrderId != relatedWorkOrderId) {
                isValid = false;
            }
        } 
        System.debug(LoggingLevel.DEBUG, 'hasMatchingParentWorkOrderId - ' + isValid);
        System.debug(LoggingLevel.DEBUG, 'SPM_Repeat_Visit.hasMatchingParentWorkOrderId() - exit');
        return isValid;
    }
    
    /**
     * Method to check if the work-order belong to same source. Work-orders from same source are not elibile for repeat-visit.
     **/
    private Boolean isFromSameSource(SVMXC__Service_Order__c parentWorkOrder, SVMXC__Service_Order__c subSequentWorkOrder) {
        System.debug(LoggingLevel.DEBUG, 'SPM_Repeat_Visit.isFromSameSource() - enter');
        String sourceApi = '';
        Boolean isSameParent = false;
        if(savedConfiguration != NULL && savedConfiguration.source != NULL && savedConfiguration.source != 'SVMXC__Service_Order__c') {
             if(savedConfiguration.source == 'Case') {
                sourceApi = SPM_Consts.WOCASE; 
             } else {
                sourceApi = SPM_Consts.WOSERVICEREQUESTFIELD; //savedConfiguration.source;
             }
             System.debug( LoggingLevel.DEBUG, 'sourceApi - ' + sourceApi);
             Id parentWorkOrderSource = (Id) getSourceObjectFieldValue(parentWorkOrder, sourceApi);
             Id subSequentWorkOrderSource = (Id) getSourceObjectFieldValue(subSequentWorkOrder, sourceApi);
             System.debug( LoggingLevel.DEBUG, 'parentWorkOrderSource - '+parentWorkOrderSource);
             System.debug( LoggingLevel.DEBUG, 'subSequentWorkOrderSource - '+subSequentWorkOrderSource);
            
             if(parentWorkOrderSource == subSequentWorkOrderSource) {
                 isSameParent = true;
             }
        }
        System.debug(LoggingLevel.DEBUG, 'isSameParent - ' + isSameParent);
        System.debug(LoggingLevel.DEBUG, 'SPM_Repeat_Visit.isFromSameSource() - exit');
        return isSameParent;
    }

    /**
     * Return true/false based on the user selected option for matching the related work-order-id with
     * Parent WO.
     * 
     * @return True/False based on the setting.
     */
    private Boolean isPrimaryWorkOrderMatchNeeded() {
        if(getSourceObjectField(SPM_Schema.Field.hasPrimaryWorkOrder) == 'Yes') {
            return true;
        }
        return false;
    }

    /**
     * Method to check if the passed in record is eligible for RepeatVisit-check for the configured expression.
     * 
     * @param  record - record to be validated
     * @return true or false based on the evaluating the expression.
     */
    private Boolean meetsSubsequentCriteria(SVMXC__Service_Order__c record) {
        
        System.debug(LoggingLevel.DEBUG, 'meetsSubsequentCriteria() - enter');
        COMM_SVMXC_Utils4 commUtils = new COMM_SVMXC_Utils4();
        String advancedExpression = getAdvancedExpressionCriteria( SPM_Schema.ExpressionType.WorkOrderCriteria);
        System.debug(LoggingLevel.DEBUG, 'Advanced Expression - '+ advancedExpression);   
        List<SVMXC__ServiceMax_Config_Data__c> expressionList = getRuleExpressionList( SPM_Schema.ExpressionType.WorkOrderCriteria );
        Boolean isEligible = commUtils.SVMX_ExpressionParsing( record, expressionList, advancedExpression );
        System.debug(LoggingLevel.DEBUG, 'meetsSubsequentCriteria() - exit - '+ isEligible);        
        return isEligible;
    }

    /**
     * Method to update the subsequent workorder information in the RepeatVisit record 
     */
    public void updateRepeatVisitObject(SVMXC__SPM_Repeat_Visit__c repeatVisitRecord, SVMXC__Service_Order__c subSequentworkOrder) {
      try {
            repeatVisitRecord.SVMXC__Subsequent_Work_Order__c = (Id) getSourceObjectFieldValue(subSequentworkOrder, SPM_Schema.Field.Id);
            repeatVisitRecord.SVMXC__Subsequent_Incident_On__c = ((Datetime) getSourceObjectFieldValue(subSequentworkOrder, SPM_Schema.Field.ServiceDeliveredOn)).date();         
        } catch(Exception ex) {
            System.debug(LoggingLevel.DEBUG, 'exception - '+ex);
        }
    }


    /**
     * Method to create the RepeatVisit record for passed in work-order record.
     * 
     * @param  workOrder - current work-order record in context
     * @param  parentWorkOrder - parent to the current work-order
     * @return repeatVisit object
     */
    private SVMXC__SPM_Repeat_Visit__c createRepeatVisitObject(SVMXC__Service_Order__c workOrder) {
        System.debug(LoggingLevel.DEBUG, 'createRepeatVisitObject() - enter');
        SVMXC__SPM_Repeat_Visit__c repeatVisit = new SVMXC__SPM_Repeat_Visit__c();
        repeatVisit.SVMXC__Work_Order__c = (Id) getSourceObjectFieldValue(workOrder, SPM_Schema.Field.Id);
        repeatVisit.SVMXC__First_Incident_On__c = ((Datetime) getSourceObjectFieldValue(workOrder, SPM_Schema.Field.ServiceDeliveredOn)).date();
        repeatVisit.SVMXC__Technician__c = (Id) getSourceObjectFieldValue(workOrder, SPM_Schema.Field.Technician);
        repeatVisit.SVMXC__Service_Contract__c = (Id) getSourceObjectFieldValue(workOrder, SPM_Schema.Field.ServiceContract);
        repeatVisit.SVMXC__Product_Warranty__c = (Id) getSourceObjectFieldValue(workOrder, SPM_Schema.Field.Warranty); 
        repeatVisit.SVMXC__Installed_Product__c = (Id) getSourceObjectFieldValue(workOrder, SPM_Schema.Field.InstallProduct);//getToplLevelValue(workOrder); 
        repeatVisit.SVMXC__Calculation_Method__c = calculationMethodName; 
        repeatVisit.SVMXC__Configuration_Name__c = getConfigurationName();        
        repeatVisit.SVMXC__Service_Team__c = (Id) getSourceObjectFieldValue(workOrder, SPM_Schema.Field.Team);
        repeatVisit.SVMXC__Service_Manager__c = (Id) getSourceObjectFieldValue(workOrder, SPM_Schema.Field.Manager); 
        repeatVisit.SVMXC__Account__c = (Id) getSourceObjectFieldValue( workOrder, SPM_Schema.Field.Account );
        System.debug(LoggingLevel.DEBUG, 'createRepeatVisitObject() - exit');        
        return repeatVisit;
    }

    /**
     * Method to load the RepeatVisit records for the passed in work-order Ids.
     * 
     * @param  Ids - work-order Ids inside the current batch
     * @return - map of RepeatVisit objects with workorderId as the key
     */
    private Map<String, SVMXC__SPM_Repeat_Visit__c> populateExistingRepeatVisitedRecords(List<String> Ids) {
      System.debug(LoggingLevel.DEBUG, 'populateExistingRepeatVisitedRecords() - enter '+Ids);
      Map<String, SVMXC__SPM_Repeat_Visit__c> mapOfExistingRepeatVisitRecords = new Map <String, SVMXC__SPM_Repeat_Visit__c>();
    
        List<String> queryFields = new List<String> {'SVMXC__Work_Order__c', 'SVMXC__Subsequent_Work_Order__c', 'SVMXC__Subsequent_Incident_On__c'};
        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SPM_Repeat_Visit__c', queryFields, COMM_SecurityUtils.Access.Accessible)){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        List<SVMXC__SPM_Repeat_Visit__c> listOfExistingRepeatVisits = [select SVMXC__Work_Order__c, 
            SVMXC__Subsequent_Work_Order__c, SVMXC__Subsequent_Incident_On__c from SVMXC__SPM_Repeat_Visit__c 
            where SVMXC__Work_Order__c IN: Ids and SVMXC__Configuration_Name__c =: getConfigurationName()];

        System.debug(LoggingLevel.DEBUG, 'listOfExistingRepeatVisits.size() - ' + listOfExistingRepeatVisits.size());
        if(listOfExistingRepeatVisits.size() > 0) {
          for(SVMXC__SPM_Repeat_Visit__c repeatVisit: listOfExistingRepeatVisits) {
              mapOfExistingRepeatVisitRecords.put(repeatVisit.SVMXC__Work_Order__c, repeatVisit);            
          }
        }
        System.debug(LoggingLevel.DEBUG, 'populateExistingRepeatVisitedRecords() - exit with existing RepeatVisit records count:' + listOfExistingRepeatVisits.size());
        return mapOfExistingRepeatVisitRecords;
    }

    private void updateSummaryForCase(List<SVMXC__SPM_Repeat_Visit__c> repeatVisitList) {
        System.debug( LoggingLevel.DEBUG, 'updateSummaryForCase() - enter' );
        
        System.debug( LoggingLevel.DEBUG, 'repeatVisitList - '+repeatVisitList);
        
        //Iterate through the list of WO and get the Case Information and store in a map.
        List<Id> workOrderIds = new List<Id>();
        for(SVMXC__SPM_Repeat_Visit__c repeatVisit: repeatVisitList) {
            workOrderIds.add(repeatVisit.SVMXC__Work_Order__c);
        }
        
        List<SVMXC__SPM_Repeat_Visit__c> repeatVisitListWithSource = [SELECT SVMXC__Case__c, SVMXC__Subsequent_Incident_On__c, 
                        SVMXC__Work_Order__c FROM SVMXC__SPM_Repeat_Visit__c WHERE SVMXC__Work_Order__c IN :workOrderIds];
        Map<Id, Boolean> tempSourceStatusMap = new Map<Id, Boolean>();
        
        Boolean isRepeatVisit = false;
        for(SVMXC__SPM_Repeat_Visit__c repeatVisit: repeatVisitListWithSource) {
            isRepeatVisit = false;
            
            //Check if it is repeat visit based on the presence of sub-sequent field value.
            if(repeatVisit.SVMXC__Subsequent_Incident_On__c != null) {
                isRepeatVisit = true;
            }
            if(tempSourceStatusMap.containsKey(repeatVisit.SVMXC__Case__c) &&
                tempSourceStatusMap.get(repeatVisit.SVMXC__Case__c) == true) {
                continue;
            }
            tempSourceStatusMap.put(repeatVisit.SVMXC__Case__c, isRepeatVisit);
        }
        
        //Fire a query to load the saved RV records present in the summary table. 
        //Update them if they are RV or else leave it as is.
        
        List<SVMXC__SPM_Top_Level_Summary__c> existingSummaries =  [SELECT SVMXC__Case__c, SVMXC__is_repeat_visit__c FROM 
                                                                    SVMXC__SPM_Top_Level_Summary__c WHERE SVMXC__Case__c IN :tempSourceStatusMap.keySet()]; 
        Map<Id, SVMXC__SPM_Top_Level_Summary__c> updatedSummaries = new Map<Id, SVMXC__SPM_Top_Level_Summary__c>();
        
        if(existingSummaries.size() > 0) {
            for(SVMXC__SPM_Top_Level_Summary__c summary: existingSummaries) {
                updatedSummaries.put(summary.SVMXC__Case__c, summary);
            }
        }
        
        SVMXC__SPM_Top_Level_Summary__c summary = null;
        for(Id topLevelIssueId:tempSourceStatusMap.keySet()) {
            if(updatedSummaries.containsKey(topLevelIssueId)) {
                summary = updatedSummaries.get(topLevelIssueId);
                if(summary.SVMXC__is_repeat_visit__c == 0) {
                    if(tempSourceStatusMap.get(topLevelIssueId)) {
                        summary.SVMXC__is_repeat_visit__c = 1;
                    }
                }
            } else {
                summary = new SVMXC__SPM_Top_Level_Summary__c();
                summary.SVMXC__Case__c = topLevelIssueId;
                if(tempSourceStatusMap.get(topLevelIssueId)) {
                    summary.SVMXC__is_repeat_visit__c = 1;
                } else {
                    summary.SVMXC__is_repeat_visit__c = 0;
                }
            }
            updatedSummaries.put(topLevelIssueId, summary);
        }
        
        System.debug( LoggingLevel.DEBUG, 'updatedSummaries - '+updatedSummaries);
        upsert updatedSummaries.values();
        System.debug( LoggingLevel.DEBUG, 'updateSummaryForCase() - exit' );
    }

    private void updateSummaryForServiceRequest(List<SVMXC__SPM_Repeat_Visit__c> repeatVisitList) {
        System.debug( LoggingLevel.DEBUG, 'updateSummaryForServiceRequest() - enter' );
        
        System.debug( LoggingLevel.DEBUG, 'repeatVisitList - '+repeatVisitList);
        
        //Iterate through the list of WO and get the Case Information and store in a map.
        List<Id> workOrderIds = new List<Id>();
        for(SVMXC__SPM_Repeat_Visit__c repeatVisit: repeatVisitList) {
            workOrderIds.add(repeatVisit.SVMXC__Work_Order__c);
        }
        
        List<SVMXC__SPM_Repeat_Visit__c> repeatVisitListWithSource = [SELECT SVMXC__Service_Request__c, SVMXC__Subsequent_Incident_On__c, 
                        SVMXC__Work_Order__c FROM SVMXC__SPM_Repeat_Visit__c WHERE SVMXC__Work_Order__c IN :workOrderIds];
        Map<Id, Boolean> tempSourceStatusMap = new Map<Id, Boolean>();
        
        Boolean isRepeatVisit = false;
        for(SVMXC__SPM_Repeat_Visit__c repeatVisit: repeatVisitListWithSource) {
            isRepeatVisit = false;
            
            //Check if it is repeat visit based on the presence of sub-sequent field value.
            if(repeatVisit.SVMXC__Subsequent_Incident_On__c != null) {
                isRepeatVisit = true;
            }
            if(tempSourceStatusMap.containsKey(repeatVisit.SVMXC__Service_Request__c) &&
                tempSourceStatusMap.get(repeatVisit.SVMXC__Service_Request__c) == true) {
                continue;
            }
            tempSourceStatusMap.put(repeatVisit.SVMXC__Service_Request__c, isRepeatVisit);
        }
        
        //Fire a query to load the saved RV records present in the summary table. 
        //Update them if they are RV or else leave it as is.
        
        List<SVMXC__SPM_Top_Level_Summary__c> existingSummaries =  [SELECT SVMXC__Service_Request__c, SVMXC__is_repeat_visit__c FROM 
                                                                    SVMXC__SPM_Top_Level_Summary__c WHERE SVMXC__Service_Request__c IN :tempSourceStatusMap.keySet()]; 
        Map<Id, SVMXC__SPM_Top_Level_Summary__c> updatedSummaries = new Map<Id, SVMXC__SPM_Top_Level_Summary__c>();
        
        if(existingSummaries.size() > 0) {
            for(SVMXC__SPM_Top_Level_Summary__c summary: existingSummaries) {
                updatedSummaries.put(summary.SVMXC__Service_Request__c, summary);
            }
        }
        
        SVMXC__SPM_Top_Level_Summary__c summary = null;
        for(Id topLevelIssueId:tempSourceStatusMap.keySet()) {
            if(updatedSummaries.containsKey(topLevelIssueId)) {
                summary = updatedSummaries.get(topLevelIssueId);
                if(summary.SVMXC__is_repeat_visit__c == 0) {
                    if(tempSourceStatusMap.get(topLevelIssueId)) {
                        summary.SVMXC__is_repeat_visit__c = 1;
                    }
                }
            } else {
                summary = new SVMXC__SPM_Top_Level_Summary__c();
                summary.SVMXC__Service_Request__c = topLevelIssueId;
                if(tempSourceStatusMap.get(topLevelIssueId)) {
                    summary.SVMXC__is_repeat_visit__c = 1;
                } else {
                    summary.SVMXC__is_repeat_visit__c = 0;
                }
            }
            updatedSummaries.put(topLevelIssueId, summary);
        }
        
        System.debug( LoggingLevel.DEBUG, 'updatedSummaries - '+updatedSummaries);
        upsert updatedSummaries.values();
        System.debug( LoggingLevel.DEBUG, 'updateSummaryForServiceRequest() - exit' );
    }
    
    private void updateSummaryForPrimaryWorkorder(List<SVMXC__SPM_Repeat_Visit__c> repeatVisitList) {
        System.debug( LoggingLevel.DEBUG, 'updateSummaryForPrimaryWorkorder() - enter' );
        
        System.debug( LoggingLevel.DEBUG, 'repeatVisitList - '+repeatVisitList);
        
        //Iterate through the list of WO and get the Case Information and store in a map.
        List<Id> workOrderIds = new List<Id>();
        for(SVMXC__SPM_Repeat_Visit__c repeatVisit: repeatVisitList) {
            workOrderIds.add(repeatVisit.SVMXC__Work_Order__c);
        }
        
        List<SVMXC__SPM_Repeat_Visit__c> repeatVisitListWithSource = [SELECT SVMXC__Primary_Work_Order__c, SVMXC__Subsequent_Incident_On__c, 
                        SVMXC__Work_Order__c FROM SVMXC__SPM_Repeat_Visit__c WHERE SVMXC__Work_Order__c IN :workOrderIds];
        Map<Id, Boolean> tempSourceStatusMap = new Map<Id, Boolean>();
        
        Boolean isRepeatVisit = false;
        for(SVMXC__SPM_Repeat_Visit__c repeatVisit: repeatVisitListWithSource) {
            isRepeatVisit = false;
            
            //Check if it is repeat visit based on the presence of sub-sequent field value.
            if(repeatVisit.SVMXC__Subsequent_Incident_On__c != null) {
                isRepeatVisit = true;
            }
            if(tempSourceStatusMap.containsKey(repeatVisit.SVMXC__Primary_Work_Order__c) &&
                tempSourceStatusMap.get(repeatVisit.SVMXC__Primary_Work_Order__c) == true) {
                continue;
            }
            tempSourceStatusMap.put(repeatVisit.SVMXC__Primary_Work_Order__c, isRepeatVisit);
        }
        
        //Fire a query to load the saved RV records present in the summary table. 
        //Update them if they are RV or else leave it as is.
        
        List<SVMXC__SPM_Top_Level_Summary__c> existingSummaries =  [SELECT SVMXC__Primary_Work_Order__c, SVMXC__is_repeat_visit__c FROM 
                                                                    SVMXC__SPM_Top_Level_Summary__c WHERE SVMXC__Primary_Work_Order__c IN :tempSourceStatusMap.keySet()]; 
        Map<Id, SVMXC__SPM_Top_Level_Summary__c> updatedSummaries = new Map<Id, SVMXC__SPM_Top_Level_Summary__c>();
        
        if(existingSummaries.size() > 0) {
            for(SVMXC__SPM_Top_Level_Summary__c summary: existingSummaries) {
                updatedSummaries.put(summary.SVMXC__Primary_Work_Order__c, summary);
            }
        }
        
        SVMXC__SPM_Top_Level_Summary__c summary = null;
        for(Id topLevelIssueId:tempSourceStatusMap.keySet()) {
            if(updatedSummaries.containsKey(topLevelIssueId)) {
                summary = updatedSummaries.get(topLevelIssueId);
                if(summary.SVMXC__is_repeat_visit__c == 0) {
                    if(tempSourceStatusMap.get(topLevelIssueId)) {
                        summary.SVMXC__is_repeat_visit__c = 1;
                    }
                }
            } else {
                summary = new SVMXC__SPM_Top_Level_Summary__c();
                summary.SVMXC__Primary_Work_Order__c = topLevelIssueId;
                if(tempSourceStatusMap.get(topLevelIssueId)) {
                    summary.SVMXC__is_repeat_visit__c = 1;
                } else {
                    summary.SVMXC__is_repeat_visit__c = 0;
                }
            }
            updatedSummaries.put(topLevelIssueId, summary);
        }
        
        System.debug( LoggingLevel.DEBUG, 'updatedSummaries - '+updatedSummaries);
        upsert updatedSummaries.values();
        System.debug( LoggingLevel.DEBUG, 'updateSummaryForPrimaryWorkorder() - exit' );
    }
    
    /**
     * Invoked after the batch operation is completed.
     */
    global override void onFinishComplete() {
        System.debug( LoggingLevel.DEBUG, 'SPM_Repeat_Visit.onFinishComplete()' );
    }
}