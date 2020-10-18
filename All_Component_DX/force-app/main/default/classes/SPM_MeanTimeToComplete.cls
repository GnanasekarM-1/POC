/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/
 //FLS and CRUD check is not required as this class is running batch mode
/**
 * The class SPM_MeanTimeToComplete which extends SPM_AbstractBatch abstract class. 
 * This class implementats all the SPM_AbstractBatch class abstract methods. 
 *
 * @author Ramachandra Mohan
 * @version 15.59101
 * @since 2016
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan      04 Jan 2016     Created. 
 * 027597    Ramachandra Mohan     01 Mar 2016     Support for mapping.
 *              Ramachandra Mohan      31 Mar 2016     Security fixes.
 *              Soumyaranjan Pati      8th Dec 2017    Error fixes(Issue-041377).
 * BAC-4050     Soumyaranjan Pati      28th June 2018  Security fixes.
 *****************************************************************************************************/

global with sharing class SPM_MeanTimeToComplete extends SPM_AbstractBatch {
    
    /**
     * 
     */
    private Id bussinessHoursId; 
    
    /**
     * 
     */
    global SPM_MeanTimeToComplete( SVMXC__ServiceMax_Config_Data__c scheduleData ) {         
       super( SPM_Schema.Report.MeanTimeToComplete, scheduleData );
    }
    
    /**
     * Holds the referece to the saved business configuration.
     **/
    private SPM_ConfigurationDefinition.businessProcessConfig savedConfiguration;
    
    /**
     * Add the top-level object's expression along with the created-date and modified date to the base where clause.
     **/
    private void populateCreatedAndLastModifiedDateFields() {
        System.debug( LoggingLevel.DEBUG, 'SPM_MeanTimeToComplete.populateCreatedAndLastModifiedDateFields() - enter' );
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
        
        String technicianField = getSourceObjectField( SPM_Schema.Field.Technician ).replace('__c', '__r') + '.' + SPM_Consts.WORKING_HOURS;
        addQueryField( SPM_Schema.Field.BusinessHours, technicianField );
        addIgnoreNullCheckField( technicianField );

        System.debug( LoggingLevel.DEBUG, 'SPM_MeanTimeToComplete.populateCreatedAndLastModifiedDateFields() - exit' );
    }
    
    /**
     * Loads the saved business process configuration and store the details to the class level attribute.
     **/
    private void loadBusinessProcessConfiguration() {
        System.debug( LoggingLevel.DEBUG, 'SPM_MeanTimeToComplete.loadBusinessProcessConfiguration() - enter' );
        List<SVMXC__ServiceMax_Config_Data__c> listOfData = SPM_ConfigurationDefinition.getBusinessProcessConfig();        
        System.debug(LoggingLevel.DEBUG, 'BusinessProcess - ' + listOfData); 
        if(listOfData != NULL && !listOfData.isEmpty()) {
            savedConfiguration =(SPM_ConfigurationDefinition.BusinessProcessConfig) JSON.deserialize(
                listOfData[0].SVMXC__Formula__c, SPM_ConfigurationDefinition.businessProcessConfig.class);                                                
        }
        System.debug( LoggingLevel.DEBUG, 'SPM_MeanTimeToComplete.loadBusinessProcessConfiguration() - exit' );
    }
    
  /**
     * 
     */
    global override void initBatchConfiguration() {
        
        System.debug( LoggingLevel.DEBUG, 'initBatchConfiguration() - enter' );
        loadBusinessProcessConfiguration();
        populateCreatedAndLastModifiedDateFields();
        List<String> queryFields = new List<String> {'Id'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'BusinessHours', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        
        BusinessHours defaultBusinessHours = [SELECT Id FROM BusinessHours WHERE IsDefault=true LIMIT 1];
        bussinessHoursId = defaultBusinessHours.Id;
        
        System.debug( LoggingLevel.DEBUG, 'initBatchConfiguration() - exit' );
  }
    
    /**
     * Use this method to log in case of any errors addError( Id sourceRecordId, String errorMessage )
     */
    global override void handleRecords( List<SObject> records ) {
        
        System.debug( LoggingLevel.DEBUG, 'handleRecords() - enter; records: ' + records.size() );
        
        Map<Id, SObject> workorderMap = new Map<Id, SObject>();
        List<SObject> listSobjects=new List<SObject>();
        for( SObject record : records ) {            
             workorderMap.put( (Id) record.get( SPM_Consts.RECORD_ID ), record );            
        }
        
        List<String> queryFields = new List<String> {'Id', 'SVMXC__Work_Order__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SPM_Mean_Time_To_Complete__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        
        List<SVMXC__SPM_Mean_Time_To_Complete__c> existingRecords = [ SELECT Id, SVMXC__Work_Order__c FROM SVMXC__SPM_Mean_Time_To_Complete__c WHERE SVMXC__Work_Order__c IN :workorderMap.keySet() ];
        
        for( SVMXC__SPM_Mean_Time_To_Complete__c record : existingRecords ) {
            workorderMap.remove( record.SVMXC__Work_Order__c );
        }
        
        List<SVMXC__SPM_Mean_Time_To_Complete__c> meanTimeToCompleteList = new List<SVMXC__SPM_Mean_Time_To_Complete__c>();
        for( SObject record: workorderMap.values() ) {
            
            Object businessHoursValue = getSourceObjectFieldValue( record, SPM_Schema.Field.BusinessHours );
            
            if( businessHoursValue != null ) {
                bussinessHoursId = String.valueOf( businessHoursValue );
            }
            
            SVMXC__SPM_Mean_Time_To_Complete__c meanTimeToComplete = new SVMXC__SPM_Mean_Time_To_Complete__c();
            
            Datetime startDateAndTime = (Datetime) getSourceObjectFieldValue( record, SPM_Schema.Field.CreatedDate );
            Datetime endDateAndTime = (Datetime) getSourceObjectFieldValue( record, SPM_Schema.Field.CompletedDate );
            
            if(startDateAndTime != null && endDateAndTime != null && bussinessHoursId != null) {
                
                Long milliSec = BusinessHours.diff(bussinessHoursId, startDateAndTime, endDateAndTime);
                Long duration = (milliSec/1000/60);                
                meanTimeToComplete.SVMXC__Completion_Time__c = (Integer) duration;
                
                System.debug( LoggingLevel.DEBUG, 'startDateAndTime: ' + startDateAndTime + '; endDateAndTime: ' + endDateAndTime + '; duration: ' + duration );
                
                if( meanTimeToComplete.SVMXC__Completion_Time__c < 0 ) {
                    // TODO
                    continue;
                }
            }
            meanTimeToComplete.SVMXC__Account__c = (Id) getSourceObjectFieldValue( record, SPM_Schema.Field.Account );
            meanTimeToComplete.SVMXC__Technician__c = (Id) getSourceObjectFieldValue( record, SPM_Schema.Field.Technician );    
            meanTimeToComplete.SVMXC__Product__c = (Id) getSourceObjectFieldValue( record, SPM_Schema.Field.Product );
            meanTimeToComplete.SVMXC__Work_Order__c = (Id) record.get( SPM_Consts.RECORD_ID );
            meanTimeToComplete.SVMXC__Service_Delivered_On__c = endDateAndTime.date();
            
            meanTimeToComplete.SVMXC__Configuration_Name__c = getConfigurationName();
            meanTimeToComplete.SVMXC__Calculation_Method__c = getCalculationMethodName();
            
            populateIssueLevelFields(record, meanTimeToComplete);
            listSobjects.add(record);
            meanTimeToCompleteList.add(meanTimeToComplete);
        }
        
        if( !meanTimeToCompleteList.isEmpty() ) {
            
            performFieldMapping( listSobjects, meanTimeToCompleteList );
            
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( meanTimeToCompleteList, COMM_SecurityUtils.Access.Createable ) ) {
                insert meanTimeToCompleteList;
                
                if(savedConfiguration != NULL && savedConfiguration.source != NULL) {
                    if(savedConfiguration.source=='Case') {
                        updateSummaryForCase(meanTimeToCompleteList);
                    } else if(savedConfiguration.source == 'SVMXC__Service_Request__c') {
                        updateSummaryForServiceRequest(meanTimeToCompleteList);
                    } else {
                        updateSummaryForPrimaryWorkorder(meanTimeToCompleteList);
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
    private void populateIssueLevelFields(SObject record, SVMXC__SPM_Mean_Time_To_Complete__c meanTimeToComplete) {
        if(savedConfiguration != NULL && savedConfiguration.source != NULL) {
            if(savedConfiguration.source=='Case') {
                if(record.get(SPM_Consts.WOCASE) !=NULL) {                
                    meanTimeToComplete.SVMXC__Case__c = (Id) record.get(SPM_Consts.WOCASE);                    
                }
            } else if(savedConfiguration.source == 'SVMXC__Service_Request__c') {
                if(record.get(SPM_Consts.WOSERVICEREQUESTFIELD) !=NULL) {                
                    meanTimeToComplete.SVMXC__Service_Request__c = (Id) record.get(SPM_Consts.WOSERVICEREQUESTFIELD);                    
                }
            } else {
                if(record.get(SPM_Consts.RELATED_WORK_ORDER) != NULL) {                                               
                    meanTimeToComplete.SVMXC__Primary_Work_Order__c = (Id) record.get(SPM_Consts.RELATED_WORK_ORDER);                                            
                } else {                                               
                    meanTimeToComplete.SVMXC__Primary_Work_Order__c = (Id) record.get( SPM_Consts.RECORD_ID );                                            
                }                    
            }
        }
    }
    
    /**
     * Summarises the MTTC computation at case level.
     **/
    private void updateSummaryForCase(List<SVMXC__SPM_Mean_Time_To_Complete__c> meanTimeToCompleteList) {
        System.debug( LoggingLevel.DEBUG, 'SPM_MeanTimeToComplete.updateSummaryForCase() - enter' );
        
        System.debug( LoggingLevel.DEBUG, 'meanTimeToCompleteList - '+meanTimeToCompleteList);
        
        Map<Id, List<SVMXC__SPM_Mean_Time_To_Complete__c>> meanTimeToCompleteMap = new Map<Id, List<SVMXC__SPM_Mean_Time_To_Complete__c>>();
        List<SVMXC__SPM_Mean_Time_To_Complete__c> tempList = null; 
        for(SVMXC__SPM_Mean_Time_To_Complete__c obj: meanTimeToCompleteList) {
            if(meanTimeToCompleteMap.containsKey(obj.SVMXC__Case__c)) {
                tempList = meanTimeToCompleteMap.get(obj.SVMXC__Case__c);
            } else {
                tempList = new List<SVMXC__SPM_Mean_Time_To_Complete__c>();
            }
            tempList.add(obj);
            meanTimeToCompleteMap.put(obj.SVMXC__Case__c, tempList);  
        }
        
        Set<Id> sourceIds = meanTimeToCompleteMap.keySet();
        System.debug( LoggingLevel.DEBUG, 'sourceIds - '+sourceIds);
        List<SVMXC__SPM_Top_Level_Summary__c> existingSummaries =  [SELECT SVMXC__Case__c, SVMXC__Completion_Time__c FROM SVMXC__SPM_Top_Level_Summary__c WHERE SVMXC__Case__c IN :sourceIds]; 
        Map<Id, SVMXC__SPM_Top_Level_Summary__c> updatedSummaries = new Map<Id, SVMXC__SPM_Top_Level_Summary__c>();
        
        if(existingSummaries.size() > 0) {
            for(SVMXC__SPM_Top_Level_Summary__c summary: existingSummaries) {
                updatedSummaries.put(summary.SVMXC__Case__c, summary);
            }
        }
        
        System.debug( LoggingLevel.DEBUG, 'updatedSummaries - '+updatedSummaries);
        Decimal completionTime = 0;
        SVMXC__SPM_Top_Level_Summary__c summary = null;
        
        for(Id topLevelIssueId:meanTimeToCompleteMap.keySet()) {
            completionTime = 0;
            if(updatedSummaries.containsKey(topLevelIssueId)) {
                System.debug( LoggingLevel.DEBUG, 'Updating the summary as the data for this source is already present');
                summary = updatedSummaries.get(topLevelIssueId);
            } else {
                System.debug( LoggingLevel.DEBUG, 'Creatign a new summary object');
                summary = new SVMXC__SPM_Top_Level_Summary__c();
                summary.SVMXC__Case__c = topLevelIssueId;
            }
            tempList = meanTimeToCompleteMap.get(topLevelIssueId);
            for(SVMXC__SPM_Mean_Time_To_Complete__c obj: tempList) {
                completionTime += obj.SVMXC__Completion_Time__c;
            }
            
            System.debug( LoggingLevel.DEBUG, 'completionTime - '+completionTime);
            summary.SVMXC__Completion_Time__c = completionTime;
            updatedSummaries.put(topLevelIssueId, summary);
        }
        System.debug( LoggingLevel.DEBUG, 'updatedSummaries - '+updatedSummaries);
        upsert updatedSummaries.values();
        System.debug( LoggingLevel.DEBUG, 'SPM_MeanTimeToComplete.updateSummaryForCase() - exit' );
    }
    
    /**
     * Summarises the MTTC computation at Service-Request level.
     **/    
    private void updateSummaryForServiceRequest(List<SVMXC__SPM_Mean_Time_To_Complete__c> meanTimeToCompleteList) {
        System.debug( LoggingLevel.DEBUG, 'SPM_MeanTimeToComplete.updateSummaryForServiceRequest() - enter' );
        
        System.debug( LoggingLevel.DEBUG, 'meanTimeToCompleteList - '+meanTimeToCompleteList);
        
        Map<Id, List<SVMXC__SPM_Mean_Time_To_Complete__c>> meanTimeToCompleteMap = new Map<Id, List<SVMXC__SPM_Mean_Time_To_Complete__c>>();
        List<SVMXC__SPM_Mean_Time_To_Complete__c> tempList = null; 
        for(SVMXC__SPM_Mean_Time_To_Complete__c obj: meanTimeToCompleteList) {
            if(meanTimeToCompleteMap.containsKey(obj.SVMXC__Service_Request__c)) {
                tempList = meanTimeToCompleteMap.get(obj.SVMXC__Service_Request__c);
            } else {
                tempList = new List<SVMXC__SPM_Mean_Time_To_Complete__c>();
            }
            tempList.add(obj);
            meanTimeToCompleteMap.put(obj.SVMXC__Service_Request__c, tempList);  
        }
        
        Set<Id> sourceIds = meanTimeToCompleteMap.keySet();
        System.debug( LoggingLevel.DEBUG, 'sourceIds - '+sourceIds);
        List<SVMXC__SPM_Top_Level_Summary__c> existingSummaries =  [SELECT SVMXC__Service_Request__c, SVMXC__Completion_Time__c FROM SVMXC__SPM_Top_Level_Summary__c WHERE SVMXC__Service_Request__c IN :sourceIds]; 
        Map<Id, SVMXC__SPM_Top_Level_Summary__c> updatedSummaries = new Map<Id, SVMXC__SPM_Top_Level_Summary__c>();
        
        if(existingSummaries.size() > 0) {
            for(SVMXC__SPM_Top_Level_Summary__c summary: existingSummaries) {
                updatedSummaries.put(summary.SVMXC__Service_Request__c, summary);
            }
        }
        
        System.debug( LoggingLevel.DEBUG, 'updatedSummaries - '+updatedSummaries);
        Decimal completionTime = 0;
        SVMXC__SPM_Top_Level_Summary__c summary = null;
        
        for(Id topLevelIssueId:meanTimeToCompleteMap.keySet()) {
            completionTime = 0;
            if(updatedSummaries.containsKey(topLevelIssueId)) {
                System.debug( LoggingLevel.DEBUG, 'Updating the summary as the data for this source is already present');
                summary = updatedSummaries.get(topLevelIssueId);
            } else {
                System.debug( LoggingLevel.DEBUG, 'Creatign a new summary object');
                summary = new SVMXC__SPM_Top_Level_Summary__c();
                summary.SVMXC__Service_Request__c = topLevelIssueId;
            }
            tempList = meanTimeToCompleteMap.get(topLevelIssueId);
            for(SVMXC__SPM_Mean_Time_To_Complete__c obj: tempList) {
                completionTime += obj.SVMXC__Completion_Time__c;
            }
            
            System.debug( LoggingLevel.DEBUG, 'completionTime - '+completionTime);
            summary.SVMXC__Completion_Time__c = completionTime;
            updatedSummaries.put(topLevelIssueId, summary);
        }
        System.debug( LoggingLevel.DEBUG, 'updatedSummaries - '+updatedSummaries);
        upsert updatedSummaries.values();
        System.debug( LoggingLevel.DEBUG, 'SPM_MeanTimeToComplete.updateSummaryForServiceRequest() - exit' );
    }

    /**
     * Summarizes the MTTC computation at primary work-order level.
     **/      
    private void updateSummaryForPrimaryWorkorder(List<SVMXC__SPM_Mean_Time_To_Complete__c> meanTimeToCompleteList) {
        System.debug( LoggingLevel.DEBUG, 'SPM_MeanTimeToComplete.updateSummaryForPrimaryWorkorder() - enter' );
        
        System.debug( LoggingLevel.DEBUG, 'meanTimeToCompleteList - '+meanTimeToCompleteList);
        
        Map<Id, List<SVMXC__SPM_Mean_Time_To_Complete__c>> meanTimeToCompleteMap = new Map<Id, List<SVMXC__SPM_Mean_Time_To_Complete__c>>();
        List<SVMXC__SPM_Mean_Time_To_Complete__c> tempList = null; 
        for(SVMXC__SPM_Mean_Time_To_Complete__c obj: meanTimeToCompleteList) {
            if(meanTimeToCompleteMap.containsKey(obj.SVMXC__Primary_Work_Order__c)) {
                tempList = meanTimeToCompleteMap.get(obj.SVMXC__Primary_Work_Order__c);
            } else {
                tempList = new List<SVMXC__SPM_Mean_Time_To_Complete__c>();
            }
            tempList.add(obj);
            meanTimeToCompleteMap.put(obj.SVMXC__Primary_Work_Order__c, tempList);  
        }
        
        Set<Id> sourceIds = meanTimeToCompleteMap.keySet();
        System.debug( LoggingLevel.DEBUG, 'sourceIds - '+sourceIds);
        List<SVMXC__SPM_Top_Level_Summary__c> existingSummaries =  [SELECT SVMXC__Primary_Work_Order__c, SVMXC__Completion_Time__c FROM SVMXC__SPM_Top_Level_Summary__c WHERE SVMXC__Primary_Work_Order__c IN :sourceIds]; 
        Map<Id, SVMXC__SPM_Top_Level_Summary__c> updatedSummaries = new Map<Id, SVMXC__SPM_Top_Level_Summary__c>();
        
        if(existingSummaries.size() > 0) {
            for(SVMXC__SPM_Top_Level_Summary__c summary: existingSummaries) {
                updatedSummaries.put(summary.SVMXC__Primary_Work_Order__c, summary);
            }
        }
        
        System.debug( LoggingLevel.DEBUG, 'updatedSummaries - '+updatedSummaries);
        Decimal completionTime = 0;
        SVMXC__SPM_Top_Level_Summary__c summary = null;
        
        for(Id topLevelIssueId:meanTimeToCompleteMap.keySet()) {
            completionTime = 0;
            if(updatedSummaries.containsKey(topLevelIssueId)) {
                System.debug( LoggingLevel.DEBUG, 'Updating the summary as the data for this source is already present');
                summary = updatedSummaries.get(topLevelIssueId);
            } else {
                System.debug( LoggingLevel.DEBUG, 'Creatign a new summary object');
                summary = new SVMXC__SPM_Top_Level_Summary__c();
                summary.SVMXC__Primary_Work_Order__c = topLevelIssueId;
            }
            tempList = meanTimeToCompleteMap.get(topLevelIssueId);
            for(SVMXC__SPM_Mean_Time_To_Complete__c obj: tempList) {
                completionTime += obj.SVMXC__Completion_Time__c;
            }
            
            System.debug( LoggingLevel.DEBUG, 'completionTime - '+completionTime);
            summary.SVMXC__Completion_Time__c = completionTime;
            updatedSummaries.put(topLevelIssueId, summary);
        }
        System.debug( LoggingLevel.DEBUG, 'updatedSummaries - '+updatedSummaries);
        upsert updatedSummaries.values();
        System.debug( LoggingLevel.DEBUG, 'SPM_MeanTimeToComplete.updateSummaryForPrimaryWorkorder() - exit' );
    }
    
    /**
     * 
     */
    global override void onFinishComplete() {
        System.debug( LoggingLevel.DEBUG, ' onFinishComplete()' );
    }
}