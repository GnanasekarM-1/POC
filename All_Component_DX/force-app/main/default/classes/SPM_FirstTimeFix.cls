/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/
//FLS and CRUD check is not required as this class is running in batch mode
/**
 * The class SPM_FirstTimeFix which extends SPM_AbstractBatch abstract class. 
 * This class implementats all the SPM_AbstractBatch class abstract methods.
 *
 * @author Ramachandra Mohan
 * @version 15.59101
 * @since 2015
 */
  
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan      14 Oct 2015     Created. 
 *              Ramachandra Mohan      31 Mar 2016     Security fixes.
 * 019174       Ramachandra Mohan      20 Apr 2016     Workaround for Salesforce limitaions in Database.Stateful
 *              Soumyaranjan Pati      22nd May 2018   Fixed ANA-2064 defect
 * BAC-4050     Soumyaranjan Pati      27th June 2018  Security fixes.
 *****************************************************************************************************/

global with sharing class SPM_FirstTimeFix extends SPM_AbstractBatch {
    

    /**
     * Holds the referece to the saved business configuration.
     **/
    private SPM_ConfigurationDefinition.BusinessProcessConfig savedConfiguration;
 
    /**
     * 
     */
    global SPM_FirstTimeFix( SVMXC__ServiceMax_Config_Data__c scheduleData ) {         
        super( SPM_Schema.Report.FirstTimeFix, scheduleData );
    }
    
    /**
     * Add the top-level object's expression along with the created-date and modified date to the base where clause.
     **/
    private void populateCreatedAndLastModifiedDateFields() {
        System.debug( LoggingLevel.DEBUG, 'SPM_FirstTimeFix.populateCreatedAndLastModifiedDateFields() - enter' );
        Integer numberOfDays = getNumberOfDaysToQualifyRecords();
        if( numberOfDays == null ) numberOfDays = 31;
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
     * Invoked before executing the base query for considering additional criteria and select fields.SPM_Utilities.getInstance()
     */
    global override void initBatchConfiguration() {
        System.debug( LoggingLevel.DEBUG, 'initBatchConfiguration() - enter' );
        addIgnoreNullCheckField( SPM_Schema.Field.ServiceGroup );   
        loadBusinessProcessConfiguration();
        populateCreatedAndLastModifiedDateFields();
        System.debug( LoggingLevel.DEBUG, 'initBatchConfiguration() - exit' );
    }
    
    /**
     * Use this method to log in case of any errors addError( Id sourceRecordId, String errorMessage )
     */
    global override void handleRecords( List<SObject> records ) {
        
        System.debug( LoggingLevel.DEBUG, 'handleRecords() - enter; records: ' + records.size() );
        
        Map<Id, SObject> workorderMap = new Map<Id, SObject>();
        Map<Id, Id> workorderTechnicianMap = new Map<Id, Id>();
        
        for( SObject record : records ) {
            
            workorderMap.put( (Id) record.get( SPM_Consts.RECORD_ID ), record );
            workorderTechnicianMap.put( (Id) record.get( SPM_Consts.RECORD_ID ), (Id) getSourceObjectFieldValue(record, SPM_Schema.Field.Technician ) );
        }
        
        // Retrieve all manager's associated to technicians.
        Map<Id, SVMXC__Service_Group_Members__c> technicianMap = new Map<Id, SVMXC__Service_Group_Members__c>();
        
        List<String> queryFields = new List<String> {'Id'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Service_Group_Members__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        technicianMap.putAll( [SELECT Id,SVMXC__Salesforce_User__r.ManagerId FROM SVMXC__Service_Group_Members__c WHERE Id IN :workorderTechnicianMap.values()] );
        
        addInfo('Eliminating already processed work orders.');
        
        Map<Id,Id> workorderFtfMap = new Map<Id,Id>();
        
        queryFields = new List<String> {'Id', 'SVMXC__Work_Order__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SPM_First_Time_Fix__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        for( SVMXC__SPM_First_Time_Fix__c processedFirstTimeFix : [ SELECT Id, SVMXC__Work_Order__c FROM SVMXC__SPM_First_Time_Fix__c WHERE SVMXC__Work_Order__c IN :workorderMap.keySet() ] ) {
            if( workorderMap.containsKey( processedFirstTimeFix.SVMXC__Work_Order__c ) ) {
                workorderMap.remove( processedFirstTimeFix.SVMXC__Work_Order__c );    
            }
        }
        
        addInfo('Work Order to be processes for FTF report: ' + workorderMap.size() );
        
        List<SVMXC__ServiceMax_Config_Data__c> expressionList = getRuleExpressionList( SPM_Schema.ExpressionType.CriteriaForFirstTimeFixed );
        addInfo( 'Criteria for First Time Fixed: ' + expressionList );
        
        if( expressionList == null ) {            
            addError('Invalid qualification criteria expression list: ' + expressionList );
        }
        
        String advancedExpression = getAdvancedExpressionCriteria( SPM_Schema.ExpressionType.CriteriaForFirstTimeFixed );
        addInfo( 'Advanced Expression for First Time Fixed: ' + advancedExpression );
            
        COMM_SVMXC_Utils4 commUtils = new COMM_SVMXC_Utils4();
        String defaultSource = 'WorkOrder';
        String configuredSource = '';
        //Get the source for FTF based on the configuration.
        if(getSourceObjectField(SPM_Schema.Field.ftfSource) != null) {
            configuredSource = getSourceObjectField(SPM_Schema.Field.ftfSource);
        }
        
        List<SVMXC__SPM_First_Time_Fix__c> firstTimeFixList = new List<SVMXC__SPM_First_Time_Fix__c>();        
        for( SObject record : workorderMap.values() ) {
            
            SVMXC__SPM_First_Time_Fix__c firstTimeFix = new SVMXC__SPM_First_Time_Fix__c();
            
            firstTimeFix.SVMXC__Work_Order__c = (Id) record.get( SPM_Consts.RECORD_ID );
            Datetime closedOn = (Datetime) getSourceObjectFieldValue(record, SPM_Schema.Field.ClosedOn );
            firstTimeFix.SVMXC__Fixed_On__c = closedOn.date();
            firstTimeFix.SVMXC__Account__c = (Id) getSourceObjectFieldValue(record, SPM_Schema.Field.Account );
            firstTimeFix.SVMXC__Product__c = (Id) getSourceObjectFieldValue(record, SPM_Schema.Field.Product );
            firstTimeFix.SVMXC__Technician__c = (Id) getSourceObjectFieldValue(record, SPM_Schema.Field.Technician );
            firstTimeFix.SVMXC__Service_Team__c = (Id) getSourceObjectFieldValue(record, SPM_Schema.Field.ServiceGroup );
            firstTimeFix.SVMXC__Configuration_Name__c = getConfigurationName();
            firstTimeFix.SVMXC__Calculation_Method__c = getCalculationMethodName();
            
            if( technicianMap.containsKey( firstTimeFix.SVMXC__Technician__c ) ) {
                firstTimeFix.SVMXC__Service_Manager__c = technicianMap.get( firstTimeFix.SVMXC__Technician__c ).SVMXC__Salesforce_User__r.ManagerId;
            }
            
            if(configuredSource.equals(defaultSource)) {
                firstTimeFix.SVMXC__Is_Fixed_First_Time__c = commUtils.SVMX_ExpressionParsing( record, expressionList, advancedExpression );
            } else { //Mark it as true by default.
                firstTimeFix.SVMXC__Is_Fixed_First_Time__c = true;
            }
            
            populateIssueLevelFields(record, firstTimeFix);
            
            // firstTimeFix.SVMXC__Is_Fixed_First_Time__c = commUtils.SVMX_ExpressionParsing( record, expressionList, advancedExpression );
            
            firstTimeFixList.add(firstTimeFix );
        }
        
        addInfo( 'Number of new FTF records: ' + firstTimeFixList.size() );
        
        if( !firstTimeFixList.isEmpty() ) {
            
            //Invoke the methods by checking the FTF source - work-order or work-detail. 
            System.debug( LoggingLevel.DEBUG, 'FTF Source - ' + getSourceObjectField(SPM_Schema.Field.ftfSource));
            if(configuredSource.equals(defaultSource)) {
                checkForFollowUpAndUpdateFTFStatus(workorderMap.keySet(), firstTimeFixList);
            } else {
                identifyFTFBasedOnWorkDetails(workorderMap.keySet(), firstTimeFixList);
            }
            
            performFieldMapping( workorderMap.values(), firstTimeFixList );
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( firstTimeFixList, COMM_SecurityUtils.Access.Createable ) ) {
                insert firstTimeFixList;
                
                if(savedConfiguration != NULL && savedConfiguration.source != NULL) {
                    if(savedConfiguration.source=='Case') {
                        updateSummaryForCase(firstTimeFixList);
                    } else if(savedConfiguration.source == 'SVMXC__Service_Request__c') {
                        updateSummaryForServiceRequest(firstTimeFixList);
                    } else {
                        updateSummaryForPrimaryWorkorder(firstTimeFixList);
                    }
                }
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }   
        }
        
        System.debug( LoggingLevel.DEBUG, 'handleRecords() - exit' );
    }
    
    /**
     * Populate the top-level issue information to target table.
     **/
    public void populateIssueLevelFields(SObject record, SVMXC__SPM_First_Time_Fix__c firstTimeFix) {
        if(savedConfiguration != NULL && savedConfiguration.source != NULL) {
            if(savedConfiguration.source=='Case') {
                if(record.get(SPM_Consts.WOCASE) !=NULL) {                
                    firstTimeFix.SVMXC__Case__c = (Id) record.get(SPM_Consts.WOCASE);                    
                }
            } else if(savedConfiguration.source == 'SVMXC__Service_Request__c') {
                if(record.get(SPM_Consts.WOSERVICEREQUESTFIELD) !=NULL) {                
                    firstTimeFix.SVMXC__Service_Request__c = (Id) record.get(SPM_Consts.WOSERVICEREQUESTFIELD);                    
                }
            } else {
                if(record.get(SPM_Consts.RELATED_WORK_ORDER) != NULL) {                                               
                    firstTimeFix.SVMXC__Primary_Work_Order__c = (Id) record.get(SPM_Consts.RELATED_WORK_ORDER);                                            
                } else {                                               
                    firstTimeFix.SVMXC__Primary_Work_Order__c = (Id) record.get( SPM_Consts.RECORD_ID );                                            
                }                    
            }
        } 
    }
    
    private void checkForFollowUpAndUpdateFTFStatus(Set<Id> workOrderIds, List<SVMXC__SPM_First_Time_Fix__c> firstTimeFixList) {
        System.debug( LoggingLevel.DEBUG, 'SPM_FirstTimeFix.checkForFollowUp() - enter' );
        //For the list of WO check if there is any child-WO. if true then add it to the set for recognising the FTF value.
        System.debug(LoggingLevel.DEBUG, 'Is Secondary check needed - ' + getSourceObjectField(SPM_Schema.Field.hasPrimaryWorkOrder));
        if(getSourceObjectField(SPM_Schema.Field.hasPrimaryWorkOrder) == 'Yes') {
            Set<Id> workorderIdsWithFollowup = new Set<Id>();
            
            List<String> queryFields = new List<String> {'SVMXC__Related_Work_Order__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Service_Order__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }


            for( SVMXC__Service_Order__c workOrder: [SELECT SVMXC__Related_Work_Order__c FROM SVMXC__Service_Order__c WHERE SVMXC__Related_Work_Order__c IN :workOrderIds]) {
                workorderIdsWithFollowup.add(workOrder.SVMXC__Related_Work_Order__c);
            }
            System.debug(LoggingLevel.DEBUG, 'List of work orders having followup WO - ' + workorderIdsWithFollowup);
            
            if(workorderIdsWithFollowup.size() > 0) {
                for(SVMXC__SPM_First_Time_Fix__c firstTimeFix: firstTimeFixList) {
                    if(workorderIdsWithFollowup.contains(firstTimeFix.SVMXC__Work_Order__c)) {
                        firstTimeFix.SVMXC__Is_Fixed_First_Time__c = false;
                    }
                }
            }
        }
        System.debug( LoggingLevel.DEBUG, 'SPM_FirstTimeFix.checkForFollowUp() - exit' );
    }
    
    private void identifyFTFBasedOnWorkDetails(Set<Id> workOrderIds, List<SVMXC__SPM_First_Time_Fix__c> firstTimeFixList) {
        System.debug( LoggingLevel.DEBUG, 'SPM_FirstTimeFix.identifyFTFBasedOnWorkDetails() - enter' );
        
        //Load the work-detail records - matching the criteria and grouped by workorder id.
        String criteria = getExpressionCriteria(SPM_Schema.ExpressionType.CriteriaForFirstTimeFixedUsingWorkDetail);
        if(criteria == null) {
            return;
        }
        //Security check
        List<String> queryFields = new List<String> {'SVMXC__Service_Order__c', 'CreatedDate'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Service_Order_Line__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        String query = 'SELECT SVMXC__Service_Order__c, CreatedDate FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Service_Order__c IN :workOrderIds AND (' + criteria + ') ORDER BY SVMXC__Service_Order__c, CreatedDate';
        System.debug( LoggingLevel.DEBUG, 'Query - '+ query);
        List<SVMXC__Service_Order_Line__c> workDetails = Database.query(query);
            
        //Iterate through the work-details and check if they were created outside the time range.
        Id parentWorkOrder;
        Long configuredDaysRange = Long.valueOf(getSourceObjectField(SPM_Schema.Field.Period));//1;
        System.debug( LoggingLevel.DEBUG,'Configured Days - ' + configuredDaysRange);
        DateTime previousDateTime;
        
        Set<Id> ftfWorkOrderIds = new Set<Id>();
        BusinessHours defaultBH = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
        String bussinessHoursId = defaultBH.Id;
        
        Long perDayBusinessSeconds = 0; //Holds the BusinessHours info in milli-seconds on a working day.
        for(SVMXC__Service_Order_Line__c detail: workDetails) {
            if(parentWorkOrder == null || parentWorkOrder != detail.SVMXC__Service_Order__c) {
                parentWorkOrder = detail.SVMXC__Service_Order__c;
                previousDateTime = detail.CreatedDate; 
                if(perDayBusinessSeconds == 0) {
                    DateTime startDateTime = Datetime.newInstance(previousDateTime.year(), previousDateTime.month(), previousDateTime.day(), 0,0,0);
                    DateTime endDateTime = DateTime.newInstance(previousDateTime.year(), previousDateTime.month(), previousDateTime.day(), 23,59,59);
                    perDayBusinessSeconds = BusinessHours.diff(bussinessHoursId, startDateTime, endDateTime);
                    System.debug(LoggingLevel.DEBUG, 'perDayBusinessSeconds - ' + perDayBusinessSeconds);
                }
                continue;
            } else {
                //TODO - Check if we need to make it as a configuration. 
                Long milliSec = BusinessHours.diff(bussinessHoursId, previousDateTime, detail.CreatedDate); 
                System.debug(LoggingLevel.DEBUG, 'Time difference - ' + milliSec);
                Long daysDiff = (milliSec/perDayBusinessSeconds);
                
                System.debug( LoggingLevel.DEBUG,'Days difference between the work-details - ' + daysDiff);
                if(daysDiff > configuredDaysRange) {
                    ftfWorkOrderIds.add(parentWorkOrder);
                }
                previousDateTime = detail.CreatedDate;
            }
        }
        
        System.debug(LoggingLevel.DEBUG,'List of FTF Work-orders - ' + ftfWorkOrderIds);
        //For the selected WO, mark the corresponding record in the target object as FTF.
        if(ftfWorkOrderIds.size() > 0) {
            for(SVMXC__SPM_First_Time_Fix__c firstTimeFix: firstTimeFixList) {
                if(ftfWorkOrderIds.contains(firstTimeFix.SVMXC__Work_Order__c)) {
                    firstTimeFix.SVMXC__Is_Fixed_First_Time__c = false;
                } 
            }
        }
        System.debug( LoggingLevel.DEBUG, 'SPM_FirstTimeFix.identifyFTFBasedOnWorkDetails() - exit' );
    }

    /**
     * Summarizes the FTF computation at case level.
     **/
    private void updateSummaryForCase(List<SVMXC__SPM_First_Time_Fix__c> firstTimeFixList) {
        System.debug( LoggingLevel.DEBUG, 'updateSummaryForCase() - enter' );
        
        System.debug( LoggingLevel.DEBUG, 'firstTimeFixList - '+firstTimeFixList);
        
        Map<Id, List<SVMXC__SPM_First_Time_Fix__c>> firstTimeFixMap = new Map<Id, List<SVMXC__SPM_First_Time_Fix__c>>();
        List<SVMXC__SPM_First_Time_Fix__c> tempList = null; 
        for(SVMXC__SPM_First_Time_Fix__c obj: firstTimeFixList) {
            if(firstTimeFixMap.containsKey(obj.SVMXC__Case__c)) {
                tempList = firstTimeFixMap.get(obj.SVMXC__Case__c);
            } else {
                tempList = new List<SVMXC__SPM_First_Time_Fix__c>();
            }
            tempList.add(obj);
            firstTimeFixMap.put(obj.SVMXC__Case__c, tempList);  
        }
        
        Set<Id> sourceIds = firstTimeFixMap.keySet();
        System.debug( LoggingLevel.DEBUG, 'sourceIds - '+sourceIds);
        
        List<String> queryFields = new List<String> {'SVMXC__Case__c', 'SVMXC__Is_Fixed_First_Time__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SPM_Top_Level_Summary__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        List<SVMXC__SPM_Top_Level_Summary__c> existingSummaries =  [SELECT SVMXC__Case__c, SVMXC__Is_Fixed_First_Time__c FROM 
                                                                    SVMXC__SPM_Top_Level_Summary__c WHERE SVMXC__Case__c IN :sourceIds]; 
        
        Map<Id, SVMXC__SPM_Top_Level_Summary__c> updatedSummaries = new Map<Id, SVMXC__SPM_Top_Level_Summary__c>();
        
        if(existingSummaries.size() > 0) {
            for(SVMXC__SPM_Top_Level_Summary__c summary: existingSummaries) {
                updatedSummaries.put(summary.SVMXC__Case__c, summary);
            }
        }
        
        System.debug( LoggingLevel.DEBUG, 'updatedSummaries - '+updatedSummaries);
        Integer isFirstTimeFix = 1;
        SVMXC__SPM_Top_Level_Summary__c summary = null;
        
        for(Id topLevelIssueId:firstTimeFixMap.keySet()) {
            isFirstTimeFix = 1;
            if(updatedSummaries.containsKey(topLevelIssueId)) {
                System.debug( LoggingLevel.DEBUG, 'Updating the summary as the data for this source is already present');
                summary = updatedSummaries.get(topLevelIssueId);
                tempList = firstTimeFixMap.get(topLevelIssueId);
                for(SVMXC__SPM_First_Time_Fix__c obj: tempList) {
                    if(!obj.SVMXC__Is_Fixed_First_Time__c) {
                        isFirstTimeFix = 0;
                        break;
                    }
                }
                if(isFirstTimeFix == 1 && updatedSummaries.get(topLevelIssueId).SVMXC__Is_Fixed_First_Time__c == 0) {
                    isFirstTimeFix = 0;
                }
                System.debug( LoggingLevel.DEBUG, 'isFirstTimeFix - '+isFirstTimeFix);
            } else {
                System.debug( LoggingLevel.DEBUG, 'Creatign a new summary object');
                summary = new SVMXC__SPM_Top_Level_Summary__c();
                summary.SVMXC__Case__c = topLevelIssueId;
                for(SVMXC__SPM_First_Time_Fix__c obj: tempList) {
                    if(!obj.SVMXC__Is_Fixed_First_Time__c) {
                        isFirstTimeFix = 0;
                        break;
                    }
                }
                System.debug( LoggingLevel.DEBUG, 'isFirstTimeFix - '+isFirstTimeFix);
            }
            summary.SVMXC__Is_Fixed_First_Time__c = isFirstTimeFix;
            updatedSummaries.put(topLevelIssueId, summary);
        }
        System.debug( LoggingLevel.DEBUG, 'updatedSummaries - '+updatedSummaries);
        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(updatedSummaries.values(), COMM_SecurityUtils.Access.Upsertable)){
            upsert updatedSummaries.values();
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        //upsert updatedSummaries.values();
        System.debug( LoggingLevel.DEBUG, 'updateSummaryForCase() - exit' );
    }
    
    /**
     * Summarizes the FTF computation at service-request level.
     **/
    private void updateSummaryForServiceRequest(List<SVMXC__SPM_First_Time_Fix__c> firstTimeFixList) {
        System.debug( LoggingLevel.DEBUG, 'updateSummaryForServiceRequest() - enter' );
        
        System.debug( LoggingLevel.DEBUG, 'firstTimeFixList - '+firstTimeFixList);
        
        Map<Id, List<SVMXC__SPM_First_Time_Fix__c>> firstTimeFixMap = new Map<Id, List<SVMXC__SPM_First_Time_Fix__c>>();
        List<SVMXC__SPM_First_Time_Fix__c> tempList = null; 
        for(SVMXC__SPM_First_Time_Fix__c obj: firstTimeFixList) {
            if(firstTimeFixMap.containsKey(obj.SVMXC__Service_Request__c)) {
                tempList = firstTimeFixMap.get(obj.SVMXC__Service_Request__c);
            } else {
                tempList = new List<SVMXC__SPM_First_Time_Fix__c>();
            }
            tempList.add(obj);
            firstTimeFixMap.put(obj.SVMXC__Service_Request__c, tempList);  
        }
        
        Set<Id> sourceIds = firstTimeFixMap.keySet();
        System.debug( LoggingLevel.DEBUG, 'sourceIds - '+sourceIds);
        
        List<String> queryFields = new List<String> {'SVMXC__Service_Request__c', 'SVMXC__Is_Fixed_First_Time__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SPM_Top_Level_Summary__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        List<SVMXC__SPM_Top_Level_Summary__c> existingSummaries =  [SELECT SVMXC__Service_Request__c, SVMXC__Is_Fixed_First_Time__c FROM 
                                                                    SVMXC__SPM_Top_Level_Summary__c WHERE SVMXC__Service_Request__c IN :sourceIds]; 
        
        Map<Id, SVMXC__SPM_Top_Level_Summary__c> updatedSummaries = new Map<Id, SVMXC__SPM_Top_Level_Summary__c>();
        
        if(existingSummaries.size() > 0) {
            for(SVMXC__SPM_Top_Level_Summary__c summary: existingSummaries) {
                updatedSummaries.put(summary.SVMXC__Service_Request__c, summary);
            }
        }
        
        System.debug( LoggingLevel.DEBUG, 'updatedSummaries - '+updatedSummaries);
        Integer isFirstTimeFix = 1;
        SVMXC__SPM_Top_Level_Summary__c summary = null;
        
        for(Id topLevelIssueId:firstTimeFixMap.keySet()) {
            isFirstTimeFix = 1;
            if(updatedSummaries.containsKey(topLevelIssueId)) {
                System.debug( LoggingLevel.DEBUG, 'Updating the summary as the data for this source is already present');
                summary = updatedSummaries.get(topLevelIssueId);
                tempList = firstTimeFixMap.get(topLevelIssueId);
                for(SVMXC__SPM_First_Time_Fix__c obj: tempList) {
                    if(!obj.SVMXC__Is_Fixed_First_Time__c) {
                        isFirstTimeFix = 0;
                        break;
                    }
                }
                if(isFirstTimeFix == 1 && updatedSummaries.get(topLevelIssueId).SVMXC__Is_Fixed_First_Time__c == 0) {
                    isFirstTimeFix = 0;
                }
                System.debug( LoggingLevel.DEBUG, 'isFirstTimeFix - '+isFirstTimeFix);
            } else {
                System.debug( LoggingLevel.DEBUG, 'Creatign a new summary object');
                summary = new SVMXC__SPM_Top_Level_Summary__c();
                summary.SVMXC__Service_Request__c = topLevelIssueId;
                for(SVMXC__SPM_First_Time_Fix__c obj: tempList) {
                    if(!obj.SVMXC__Is_Fixed_First_Time__c) {
                        isFirstTimeFix = 0;
                        break;
                    }
                }
                System.debug( LoggingLevel.DEBUG, 'isFirstTimeFix - '+isFirstTimeFix);
            }
            summary.SVMXC__Is_Fixed_First_Time__c = isFirstTimeFix;
            updatedSummaries.put(topLevelIssueId, summary);
        }
        System.debug( LoggingLevel.DEBUG, 'updatedSummaries - '+updatedSummaries);
         if(COMM_SecurityUtils.getInstance().verifyFieldAccess(updatedSummaries.values(), COMM_SecurityUtils.Access.Upsertable)){
            upsert updatedSummaries.values();
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        //upsert updatedSummaries.values();
        System.debug( LoggingLevel.DEBUG, 'updateSummaryForServiceRequest() - exit' );
    }
    
    /**
     * Summarizes the FTF computation at primary work-order level.
     **/    
    private void updateSummaryForPrimaryWorkorder(List<SVMXC__SPM_First_Time_Fix__c> firstTimeFixList) {
        System.debug( LoggingLevel.DEBUG, 'updateSummaryForPrimaryWorkorder() - enter' );
        
        System.debug( LoggingLevel.DEBUG, 'firstTimeFixList - '+firstTimeFixList);
        
        Map<Id, List<SVMXC__SPM_First_Time_Fix__c>> firstTimeFixMap = new Map<Id, List<SVMXC__SPM_First_Time_Fix__c>>();
        List<SVMXC__SPM_First_Time_Fix__c> tempList = null; 
        for(SVMXC__SPM_First_Time_Fix__c obj: firstTimeFixList) {
            if(firstTimeFixMap.containsKey(obj.SVMXC__Primary_Work_Order__c)) {
                tempList = firstTimeFixMap.get(obj.SVMXC__Primary_Work_Order__c);
            } else {
                tempList = new List<SVMXC__SPM_First_Time_Fix__c>();
            }
            tempList.add(obj);
            firstTimeFixMap.put(obj.SVMXC__Primary_Work_Order__c, tempList);  
        }
        
        Set<Id> sourceIds = firstTimeFixMap.keySet();
        System.debug( LoggingLevel.DEBUG, 'sourceIds - '+sourceIds);
        
        List<String> queryFields = new List<String> {'SVMXC__Primary_Work_Order__c', 'SVMXC__Is_Fixed_First_Time__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SPM_Top_Level_Summary__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        List<SVMXC__SPM_Top_Level_Summary__c> existingSummaries =  [SELECT SVMXC__Primary_Work_Order__c, SVMXC__Is_Fixed_First_Time__c FROM 
                                                                    SVMXC__SPM_Top_Level_Summary__c WHERE SVMXC__Primary_Work_Order__c IN :sourceIds]; 
        
        Map<Id, SVMXC__SPM_Top_Level_Summary__c> updatedSummaries = new Map<Id, SVMXC__SPM_Top_Level_Summary__c>();
        
        if(existingSummaries.size() > 0) {
            for(SVMXC__SPM_Top_Level_Summary__c summary: existingSummaries) {
                updatedSummaries.put(summary.SVMXC__Primary_Work_Order__c, summary);
            }
        }
        
        System.debug( LoggingLevel.DEBUG, 'updatedSummaries - '+updatedSummaries);
        Integer isFirstTimeFix = 1;
        SVMXC__SPM_Top_Level_Summary__c summary = null;
        
        for(Id topLevelIssueId:firstTimeFixMap.keySet()) {
            isFirstTimeFix = 1;
            if(updatedSummaries.containsKey(topLevelIssueId)) {
                System.debug( LoggingLevel.DEBUG, 'Updating the summary as the data for this source is already present');
                summary = updatedSummaries.get(topLevelIssueId);
                tempList = firstTimeFixMap.get(topLevelIssueId);
                for(SVMXC__SPM_First_Time_Fix__c obj: tempList) {
                    if(!obj.SVMXC__Is_Fixed_First_Time__c) {
                        isFirstTimeFix = 0;
                        break;
                    }
                }
                if(isFirstTimeFix == 1 && updatedSummaries.get(topLevelIssueId).SVMXC__Is_Fixed_First_Time__c == 0) {
                    isFirstTimeFix = 0;
                }
                System.debug( LoggingLevel.DEBUG, 'isFirstTimeFix - '+isFirstTimeFix);
            } else {
                System.debug( LoggingLevel.DEBUG, 'Creatign a new summary object');
                summary = new SVMXC__SPM_Top_Level_Summary__c();
                summary.SVMXC__Primary_Work_Order__c = topLevelIssueId;
                for(SVMXC__SPM_First_Time_Fix__c obj: tempList) {
                    if(!obj.SVMXC__Is_Fixed_First_Time__c) {
                        isFirstTimeFix = 0;
                        break;
                    }
                }
                System.debug( LoggingLevel.DEBUG, 'isFirstTimeFix - '+isFirstTimeFix);
            }
            summary.SVMXC__Is_Fixed_First_Time__c = isFirstTimeFix;
            updatedSummaries.put(topLevelIssueId, summary);
        }
        System.debug( LoggingLevel.DEBUG, 'updatedSummaries - '+updatedSummaries);
        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(updatedSummaries.values(), COMM_SecurityUtils.Access.Upsertable)){
            upsert updatedSummaries.values();
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        System.debug( LoggingLevel.DEBUG, 'updateSummaryForPrimaryWorkorder() - exit' );
    }
    
    /**
     * 
     */
    global override void onFinishComplete() {
        System.debug( LoggingLevel.DEBUG, 'onFinishComplete()' );
    }
}