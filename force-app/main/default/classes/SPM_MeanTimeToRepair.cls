/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/
 //FLS and CRUD check is not required as this class is running in batch mode
/**
 * The class SPM_MeanTimeToRepair which extends SPM_AbstractBatch abstract class. 
 * This class implementats all the SPM_AbstractBatch class abstract methods.
 *
 * @author Anchal Sharma
 * @version 15.59101
 * @since 2015
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *             Anchal                  13 Oct 2015     Created.
 *             Ramachandra Mohan       22 Feb 2015     Updated code to support field mapping.
 *             Ramachandra Mohan       31 Mar 2016     Security fixes.
 * 029867      Ramachandra Mohan       13 Apr 2016     Call addParentObjectCriteria instead of creating criteria.
 * BAC-4050    Soumyaranjan Pati      28th June 2018  Security fixes.
 *             Soumyaranjan Pati        21st Jan 2019   Defect fixes 043289/BAC-4633
 *****************************************************************************************************/

global with sharing class SPM_MeanTimeToRepair extends SPM_AbstractBatch {
    
     /**
      * 
      */
    Private String bussinessHoursId;   
    
    global SPM_MeanTimeToRepair( SVMXC__ServiceMax_Config_Data__c scheduleData ) {
        super(SPM_Schema.Report.MeanTimeToRepair, scheduleData);        
    }
    
    /**
     * Holds the referece to the saved business configuration.
     **/
    private SPM_ConfigurationDefinition.businessProcessConfig savedConfiguration;
    
    /**
     * Add the top-level object's expression along with the created-date and modified date to the base where clause.
     **/
    private String populateCreatedAndLastModifiedDateFields() {
        System.debug( LoggingLevel.DEBUG, 'SPM_FirstTimeFix.populateCreatedAndLastModifiedDateFields() - enter' );
        Integer numberOfDays = getNumberOfDaysToQualifyRecords();
        if( numberOfDays == null ) numberOfDays = 60;
        Datetime previousExecution = System.now().addDays((numberOfDays * -1));
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
                String source = SPM_Consts.WO_CASE_REFERENCEFIELD;
                if(savedConfiguration.source == 'Case') {
                    //addQueryField( SPM_Consts.WOCASE, SPM_Consts.WOCASE );
                    addQueryField( SPM_Consts.RELATEDWO_Case_BY_REFERENCE, SPM_Consts.RELATEDWO_Case_BY_REFERENCE );
                } else {
                    source = SPM_Consts.WO_SR_REFERENCEFIELD;
                    //addQueryField(SPM_Consts.WOSERVICEREQUESTFIELD, SPM_Consts.WOSERVICEREQUESTFIELD); 
                    addQueryField( SPM_Consts.RELATEDWO_SR_BY_REFERENCE, SPM_Consts.RELATEDWO_SR_BY_REFERENCE );  
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
                // addQueryField( SPM_Consts.RELATED_WORK_ORDER, SPM_Consts.RELATED_WORK_ORDER ); 
                // addIgnoreNullCheckField( SPM_Consts.RELATED_WORK_ORDER );            
                System.debug(LoggingLevel.DEBUG,'** Executing the primary workorder flow **');
                addQueryField( SPM_Consts.RELATEDWO_SR_BY_REFERENCE, SPM_Consts.RELATEDWO_SR_BY_REFERENCE );
                addIgnoreNullCheckField(SPM_Consts.RELATEDWO_SR_BY_REFERENCE);
            }
        } 
        
        //Back-ward compatibility flow changes.
        if(savedConfiguration == NULL || savedConfiguration.source == NULL || savedConfiguration.source == 'SVMXC__Service_Order__c') { 
            entryCriteria = ' SVMXC__Service_Order__r.CreatedDate >= ' + previousExecution.formatGmt( SPM_Consts.DEFAULT_DATETIME_FORMAT );
            if( scheduleData != null && scheduleData.SVMXC__Previous_Execution_Started_On__c != null ) {
                previousExecution = scheduleData.SVMXC__Previous_Execution_Started_On__c;
                entryCriteria = entryCriteria + ' AND SVMXC__Service_Order__r.LastModifiedDate >= ' + previousExecution.formatGmt( SPM_Consts.DEFAULT_DATETIME_FORMAT );
            }
        }
        System.debug( LoggingLevel.DEBUG, 'Entry Criteria - '+ entryCriteria );
        System.debug( LoggingLevel.DEBUG, 'SPM_FirstTimeFix.populateCreatedAndLastModifiedDateFields() - exit' );
        
        return entryCriteria;
        //Saravana Added for Top Level - End
        //setWhereClause(entryCriteria);
        
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
     * 
     */ 
    global override void initBatchConfiguration() {
        
        System.debug( LoggingLevel.DEBUG, 'initBatchConfiguration() - enter' );
        
        loadBusinessProcessConfiguration();
        String entryCriteria = populateCreatedAndLastModifiedDateFields();
        
        addIgnoreNullCheckField( SPM_Schema.Field.DeadTime );
        addIgnoreNullCheckField( SPM_Schema.Field.StartDateAndTime );
        addIgnoreNullCheckField( SPM_Schema.Field.EndDateAndTime );
        addIgnoreNullCheckField( SPM_Schema.Field.LaborTime );
        
        String technicianField = getSourceObjectField( SPM_Schema.Field.Technician ).replace('__c', '__r') + '.' + SPM_Consts.WORKING_HOURS;
        
        addQueryField( SPM_Schema.Field.BusinessHours, technicianField );
        addIgnoreNullCheckField(technicianField);
        
        String startEndclause = '( (' + getSourceObjectField( SPM_Schema.Field.StartDateAndTime ) + ' != null AND ' + getSourceObjectField( SPM_Schema.Field.EndDateAndTime ) + ' != null )';
        String laborClause = getSourceObjectField( SPM_Schema.Field.LaborTime ) + ' != null )';
        System.debug( LoggingLevel.DEBUG, 'Before entryCriteria - ' + entryCriteria);
        entryCriteria = '(' + entryCriteria + ') AND (' + startEndclause + ') OR (' + laborClause + ')';
        System.debug( LoggingLevel.DEBUG, 'After entryCriteria - ' + entryCriteria);
        addParentObjectCriteria( SPM_Schema.ExpressionType.WorkOrderCriteria, SPM_Schema.Field.WorkOrder );

        setWhereClause( entryCriteria );
        
        List<String> queryFields = new List<String> {'Id' };
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'BusinessHours', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        BusinessHours defaultBH = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
        bussinessHoursId = defaultBH.Id;
        
        //Changes for fixing story - ANA-278 - Begin. 
        List<SVMXC__ServiceMax_Config_Data__c> expressionList = getRuleExpressionList( SPM_Schema.ExpressionType.WorkOrderCriteria );       
        if(expressionList != null) {        
            for( SVMXC__ServiceMax_Config_Data__c expression : expressionList ) {       
                addQueryField('SVMXC__Service_Order__r.'+expression.SVMXC__Field_Name__c, 'SVMXC__Service_Order__r.'+expression.SVMXC__Field_Name__c);      
            }       
        }
        //Changes for fixing story - ANA-278 - End. 
        System.debug( LoggingLevel.DEBUG, 'initBatchConfiguration() - exit' );
    }
    
    /**
     * 
     */
    global override void handleRecords( List<SObject> records ) {
        System.debug( LoggingLevel.DEBUG, 'handleRecords() - enter; records: ' + records.size() ); 
        Map<Id,List<SObject>> mapWOToWDLine = new Map<Id,List<SObject>>();
        Map<id,sObject> mapOfIdAndItsWO = new Map<id,sObject>();
        
        List<SVMXC__SPM_Mean_Time_To_Repair__c> listMTTRRecords = new List<SVMXC__SPM_Mean_Time_To_Repair__c>();
        
        //Changes for fixing story - ANA-278 - Begin. 
        //We consider the filter criteria at the Work-Order level.
        List<SVMXC__ServiceMax_Config_Data__c> expressionList = getRuleExpressionList( SPM_Schema.ExpressionType.WorkOrderCriteria );       
        String advancedExpression = getAdvancedExpressionCriteria( SPM_Schema.ExpressionType.WorkOrderCriteria );       
        
        COMM_SVMXC_Utils4 commUtils = new COMM_SVMXC_Utils4();
        //Changes for fixing story - ANA-278 - End
        
        for( SObject serviceLineSObject : records ) {
                    
            Map<String, Object> workorderMap = ( Map<String, Object> ) (( Map<String, Object> ) JSON.deserializeUntyped( JSON.serialize( serviceLineSObject ) ) ).get('SVMXC__Service_Order__r');       
            SObject workorderobject = (SObject) JSON.deserialize( JSON.serialize( workorderMap ), SObject.class );      
            
            //Changes for fixing story - ANA-278 - Begin    
            if(!commUtils.SVMX_ExpressionParsing( workorderobject, expressionList, advancedExpression )) {      
                System.debug( LoggingLevel.DEBUG, 'workorderobject - '+workorderobject);        
                continue;       
            }       
            //Changes for fixing story - ANA-278 - End
            
            Id WOId = (Id) getSourceObjectFieldValue( serviceLineSObject, SPM_Schema.Field.WorkOrder );    
            List<SObject> WDrec = new List<SObject>();
            if(mapWOToWDLine != null && mapWOToWDLine.size()>0  && mapWOToWDLine.get(WOId)!= null){
                WDrec = mapWOToWDLine.get(WOId);
                WDrec.add(serviceLineSObject);
            }
            else{
                WDrec.add(serviceLineSObject);
            }
            
            mapWOToWDLine.put(WOId, WDrec);
            mapOfIdAndItsWO.put(WOId,workorderobject);
        }
        Map <ID, SVMXC__SPM_Mean_Time_To_Repair__c> mapWOIdToMTTR = new Map <ID, SVMXC__SPM_Mean_Time_To_Repair__c>();
        
        List<String> queryFields = new List<String> {'Id', 'SVMXC__Work_Order__c', 'SVMXC__Dead_Time__c', 'SVMXC__Labor_Time__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SPM_Mean_Time_To_Repair__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
         //Added SVMXC__Labor_Time__c and SVMXC__Dead_Time__c to SOQL for BAC-4633/043289
        for(SVMXC__SPM_Mean_Time_To_Repair__c existingMTTRRec  : [Select Id, SVMXC__Work_Order__c, SVMXC__Dead_Time__c, SVMXC__Labor_Time__c FROM SVMXC__SPM_Mean_Time_To_Repair__c WHERE SVMXC__Work_Order__c IN : mapWOToWDLine.keyset()]){
            mapWOIdToMTTR.put(existingMTTRRec.SVMXC__Work_Order__c, existingMTTRRec);
        }
       
        List<Id> woIdList = new List<Id>();                                
        for(Id WOIDkey: mapWOToWDLine.keyset()){
            Integer deadTime = 0;
            Integer laborTime = 0;
            woIdList.add(WOIDkey);
            List <SObject> lstWDRec = mapWOToWDLine.get(WOIDkey);
            SVMXC__SPM_Mean_Time_To_Repair__c mttrRec = new SVMXC__SPM_Mean_Time_To_Repair__c ();
            if( mapWOIdToMTTR.containsKey(WOIDkey) ) {
                //mttrRec = mapWOIdToMTTR.get(WOIDkey);
                //continue; // Commented for BAC-4633/043289
                //Added for BAC-4633/043289
                mttrRec.id = mapWOIdToMTTR.get(WOIDkey).id;
                if(mapWOIdToMTTR.get(WOIDkey).SVMXC__Labor_Time__c != null)
                    laborTime = mapWOIdToMTTR.get(WOIDkey).SVMXC__Labor_Time__c.intValue();
                if(mapWOIdToMTTR.get(WOIDkey).SVMXC__Dead_Time__c != null)
                    deadTime = mapWOIdToMTTR.get(WOIDkey).SVMXC__Dead_Time__c.intValue();
                //End changes for BAC-4633/043289
            }
            
            
            
            
            mttrRec.SVMXC__Work_Order__c = WOIDkey;
            
            
            for (SObject WDRec : lstWDRec) {
                
                deadTime += getSourceObjectFieldValue( WDRec, SPM_Schema.Field.DeadTime) != null? Integer.valueOf(getSourceObjectFieldValue( WDRec, SPM_Schema.Field.DeadTime)): 0;
                
                if( getSourceObjectFieldValue( WDRec, SPM_Schema.Field.LaborTime) != null ) {
                    
                    laborTime += (Integer) ( Double.valueOf( getSourceObjectFieldValue( WDRec, SPM_Schema.Field.LaborTime) ) * 60.0 );
                } else {
                    if(getSourceObjectFieldValue( WDRec, SPM_Schema.Field.BusinessHours) != null){
                        bussinessHoursId = String.valueOf(getSourceObjectFieldValue( WDRec, SPM_Schema.Field.BusinessHours));
                    }
                    Datetime startDateAndTime = (Datetime) getSourceObjectFieldValue( WDRec, SPM_Schema.Field.StartDateAndTime );
                    Datetime endDateAndTime = (Datetime) getSourceObjectFieldValue( WDRec, SPM_Schema.Field.EndDateAndTime );
                    if(startDateAndTime != null && endDateAndTime != null && bussinessHoursId != null){
                        Long milliSec = BusinessHours.diff(bussinessHoursId, startDateAndTime,endDateAndTime);
                        Long duration = (milliSec/1000/60);
                        laborTime += (Integer) duration;
                        System.debug('startDateAndTime: ' + startDateAndTime + '; endDateAndTime: ' + endDateAndTime + '; duration: ' + duration );
                    }
                }
                
                mttrRec.SVMXC__Service_Delivered_On_Date__c = Date.valueOf(getSourceObjectFieldValue( WDRec, SPM_Schema.Field.ScheduledDate));
                mttrRec.SVMXC__Technician__c = (Id) getSourceObjectFieldValue( WDRec, SPM_Schema.Field.Technician );    
                mttrRec.SVMXC__Product__c = (Id) getSourceObjectFieldValue( WDRec, SPM_Schema.Field.Product );
                mttrRec.SVMXC__Account__c = (Id) getSourceObjectFieldValue( WDRec, SPM_Schema.Field.Account );
                
            }
            mttrRec.SVMXC__Dead_Time__c = deadTime;
            mttrRec.SVMXC__Labor_Time__c = laborTime;
            mttrRec.SVMXC__Configuration_Name__c = getConfigurationName();
            mttrRec.SVMXC__Calculation_Method__c = getCalculationMethodName();
            
            if(savedConfiguration != NULL && savedConfiguration.source != NULL && savedConfiguration.source == 'Case' ) {
                if(mapOfIdAndItsWO.containsKey(WOIDkey) && mapOfIdAndItsWO.get(WOIDkey)!=NULL && mapOfIdAndItsWO.get(WOIDkey).get(SPM_Consts.WOCASE)!=NULL) {
                    mttrRec.SVMXC__Case__c = (Id)mapOfIdAndItsWO.get(WOIDkey).get(SPM_Consts.WOCASE);
                }
            } else if(savedConfiguration != NULL && savedConfiguration.source != NULL && savedConfiguration.source == 'SVMXC__Service_Request__c' ) {
                if(mapOfIdAndItsWO.containsKey(WOIDkey) && mapOfIdAndItsWO.get(WOIDkey)!=NULL && mapOfIdAndItsWO.get(WOIDkey).get(SPM_Consts.WOSERVICEREQUESTFIELD) != NULL) {
                    mttrRec.SVMXC__Service_Request__c = (Id)mapOfIdAndItsWO.get(WOIDkey).get(SPM_Consts.WOSERVICEREQUESTFIELD);                
                }
            } else if(savedConfiguration != NULL && savedConfiguration.source != NULL && savedConfiguration.source== 'SVMXC__Service_Order__c') {
                if(mapOfIdAndItsWO.containsKey(WOIDkey) && mapOfIdAndItsWO.get(WOIDkey) != NULL && mapOfIdAndItsWO.get(WOIDkey).get(SPM_Consts.RELATED_WORK_ORDER) != NULL) {
                    mttrRec.SVMXC__Primary_Work_Order__c = (Id)mapOfIdAndItsWO.get(WOIDkey).get(SPM_Consts.RELATED_WORK_ORDER);                                    
                } else if(mapOfIdAndItsWO.containsKey(WOIDkey) && mapOfIdAndItsWO.get(WOIDkey)!=NULL && mapOfIdAndItsWO.get(WOIDkey).get(SPM_Consts.RELATED_WORK_ORDER) == NULL) {
                    mttrRec.SVMXC__Primary_Work_Order__c = WOIDkey;                                    
                }
            }
            listMTTRRecords.add(mttrRec);
        }
        
        
        if(listMTTRRecords != null && listMTTRRecords.size() >0) {
            
            performFieldMapping( woIdList, listMTTRRecords );
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( listMTTRRecords, COMM_SecurityUtils.Access.Createable ) ) {
                 //insert listMTTRRecords; //Added for BAC-4633/043289
                upsert listMTTRRecords; // Added for BAC-4633/043289
                
                if(savedConfiguration != NULL && savedConfiguration.source != NULL) {
                    if(savedConfiguration.source=='Case') {
                        updateSummaryForCase(listMTTRRecords);
                    } else if(savedConfiguration.source == 'SVMXC__Service_Request__c') {
                        updateSummaryForServiceRequest(listMTTRRecords);
                    } else {
                        updateSummaryForPrimaryWorkorder(listMTTRRecords);
                    }
                }
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        }
            
            
        System.debug( LoggingLevel.DEBUG, 'handleRecords() - exit' );
    }

    private void updateSummaryForCase(List<SVMXC__SPM_Mean_Time_To_Repair__c> meanTimeToRepairList) {
        System.debug( LoggingLevel.DEBUG, 'updateSummaryForCase() - enter' );
        
        System.debug( LoggingLevel.DEBUG, 'meanTimeToRepairList - '+meanTimeToRepairList);
        
        Map<Id, List<SVMXC__SPM_Mean_Time_To_Repair__c>> meanTimeToRepairMap = new Map<Id, List<SVMXC__SPM_Mean_Time_To_Repair__c>>();
        List<SVMXC__SPM_Mean_Time_To_Repair__c> tempList = null; 
        for(SVMXC__SPM_Mean_Time_To_Repair__c obj: meanTimeToRepairList) {
            if(meanTimeToRepairMap.containsKey(obj.SVMXC__Case__c)) {
                tempList = meanTimeToRepairMap.get(obj.SVMXC__Case__c);
            } else {
                tempList = new List<SVMXC__SPM_Mean_Time_To_Repair__c>();
            }
            tempList.add(obj);
            meanTimeToRepairMap.put(obj.SVMXC__Case__c, tempList);  
        }
        
        Set<Id> sourceIds = meanTimeToRepairMap.keySet();
        System.debug( LoggingLevel.DEBUG, 'sourceIds - '+sourceIds);
        List<SVMXC__SPM_Top_Level_Summary__c> existingSummaries =  [SELECT SVMXC__Case__c, SVMXC__Labor_Time__c, SVMXC__Dead_Time__c FROM SVMXC__SPM_Top_Level_Summary__c WHERE SVMXC__Case__c IN :sourceIds];
        Map<Id, SVMXC__SPM_Top_Level_Summary__c> updatedSummaries = new Map<Id, SVMXC__SPM_Top_Level_Summary__c>();
        if(existingSummaries.size() > 0) {
            for(SVMXC__SPM_Top_Level_Summary__c summary: existingSummaries) {
                updatedSummaries.put(summary.SVMXC__Case__c, summary);
            }
        }
        
        System.debug( LoggingLevel.DEBUG, 'updatedSummaries - '+updatedSummaries);
        Decimal labourTime = 0;
        Decimal deadTime = 0;
        SVMXC__SPM_Top_Level_Summary__c summary = null;
        
        for(Id topLevelIssueId:meanTimeToRepairMap.keySet()) {
            labourTime = 0;
            deadTime = 0;
            if(updatedSummaries.containsKey(topLevelIssueId)) {
                System.debug( LoggingLevel.DEBUG, 'Updating the summary as the data for this source is already present');
                summary = updatedSummaries.get(topLevelIssueId);
            } else {
                System.debug( LoggingLevel.DEBUG, 'Creatign a new summary object');
                summary = new SVMXC__SPM_Top_Level_Summary__c();
                summary.SVMXC__Case__c = topLevelIssueId;
            }
            
            tempList = meanTimeToRepairMap.get(topLevelIssueId);
            for(SVMXC__SPM_Mean_Time_To_Repair__c obj: tempList) {
                labourTime += obj.SVMXC__Labor_Time__c;
                deadTime += obj.SVMXC__Dead_Time__c;
            }
            System.debug( LoggingLevel.DEBUG, 'labourTime - ' + labourTime);
            System.debug( LoggingLevel.DEBUG, 'deadTime - ' + deadTime);
                
            summary.SVMXC__Labor_Time__c = labourTime;
            summary.SVMXC__Dead_Time__c = deadTime;
            updatedSummaries.put(topLevelIssueId, summary);
        }
        System.debug( LoggingLevel.DEBUG, 'updatedSummaries - '+updatedSummaries);
        upsert updatedSummaries.values();
        System.debug( LoggingLevel.DEBUG, 'updateSummaryForCase() - exit' );
    }
    
    private void updateSummaryForServiceRequest(List<SVMXC__SPM_Mean_Time_To_Repair__c> meanTimeToRepairList) {
        System.debug( LoggingLevel.DEBUG, 'updateSummaryForServiceRequest() - enter' );
        
        System.debug( LoggingLevel.DEBUG, 'meanTimeToRepairList - '+meanTimeToRepairList);
        
        Map<Id, List<SVMXC__SPM_Mean_Time_To_Repair__c>> meanTimeToRepairMap = new Map<Id, List<SVMXC__SPM_Mean_Time_To_Repair__c>>();
        List<SVMXC__SPM_Mean_Time_To_Repair__c> tempList = null; 
        for(SVMXC__SPM_Mean_Time_To_Repair__c obj: meanTimeToRepairList) {
            if(meanTimeToRepairMap.containsKey(obj.SVMXC__Service_Request__c)) {
                tempList = meanTimeToRepairMap.get(obj.SVMXC__Service_Request__c);
            } else {
                tempList = new List<SVMXC__SPM_Mean_Time_To_Repair__c>();
            }
            tempList.add(obj);
            meanTimeToRepairMap.put(obj.SVMXC__Service_Request__c, tempList);  
        }
        
        Set<Id> sourceIds = meanTimeToRepairMap.keySet();
        System.debug( LoggingLevel.DEBUG, 'sourceIds - '+sourceIds);
        List<SVMXC__SPM_Top_Level_Summary__c> existingSummaries =  [SELECT SVMXC__Service_Request__c, SVMXC__Labor_Time__c, SVMXC__Dead_Time__c FROM SVMXC__SPM_Top_Level_Summary__c WHERE SVMXC__Service_Request__c IN :sourceIds]; 
        
        Map<Id, SVMXC__SPM_Top_Level_Summary__c> updatedSummaries = new Map<Id, SVMXC__SPM_Top_Level_Summary__c>();
        
        if(existingSummaries.size() > 0) {
            for(SVMXC__SPM_Top_Level_Summary__c summary: existingSummaries) {
                updatedSummaries.put(summary.SVMXC__Service_Request__c, summary);
            }
        }
        
        System.debug( LoggingLevel.DEBUG, 'updatedSummaries - '+updatedSummaries);
        Decimal labourTime = 0;
        Decimal deadTime = 0;
        SVMXC__SPM_Top_Level_Summary__c summary = null;
        
        for(Id topLevelIssueId:meanTimeToRepairMap.keySet()) {
            labourTime = 0;
            deadTime = 0;
            if(updatedSummaries.containsKey(topLevelIssueId)) {
                System.debug( LoggingLevel.DEBUG, 'Updating the summary as the data for this source is already present');
                summary = updatedSummaries.get(topLevelIssueId);
            } else {
                System.debug( LoggingLevel.DEBUG, 'Creatign a new summary object');
                summary = new SVMXC__SPM_Top_Level_Summary__c();
                summary.SVMXC__Service_Request__c = topLevelIssueId;
            }
            
            tempList = meanTimeToRepairMap.get(topLevelIssueId);
            for(SVMXC__SPM_Mean_Time_To_Repair__c obj: tempList) {
                labourTime += obj.SVMXC__Labor_Time__c;
                deadTime += obj.SVMXC__Dead_Time__c;
            }
            System.debug( LoggingLevel.DEBUG, 'labourTime - ' + labourTime);
            System.debug( LoggingLevel.DEBUG, 'deadTime - ' + deadTime);
                
            summary.SVMXC__Labor_Time__c = labourTime;
            summary.SVMXC__Dead_Time__c = deadTime;
            updatedSummaries.put(topLevelIssueId, summary);
        }
        System.debug( LoggingLevel.DEBUG, 'updatedSummaries - '+updatedSummaries);
        upsert updatedSummaries.values();
        System.debug( LoggingLevel.DEBUG, 'updateSummaryForServiceRequest() - exit' );
    }

    private void updateSummaryForPrimaryWorkorder(List<SVMXC__SPM_Mean_Time_To_Repair__c> meanTimeToRepairList) {
        System.debug( LoggingLevel.DEBUG, 'updateSummaryForPrimaryWorkorder() - enter' );
        
        System.debug( LoggingLevel.DEBUG, 'meanTimeToRepairList - '+meanTimeToRepairList);
        
        Map<Id, List<SVMXC__SPM_Mean_Time_To_Repair__c>> meanTimeToRepairMap = new Map<Id, List<SVMXC__SPM_Mean_Time_To_Repair__c>>();
        List<SVMXC__SPM_Mean_Time_To_Repair__c> tempList = null; 
        for(SVMXC__SPM_Mean_Time_To_Repair__c obj: meanTimeToRepairList) {
            if(meanTimeToRepairMap.containsKey(obj.SVMXC__Primary_Work_Order__c)) {
                tempList = meanTimeToRepairMap.get(obj.SVMXC__Primary_Work_Order__c);
            } else {
                tempList = new List<SVMXC__SPM_Mean_Time_To_Repair__c>();
            }
            tempList.add(obj);
            meanTimeToRepairMap.put(obj.SVMXC__Primary_Work_Order__c, tempList);  
        }
        
        Set<Id> sourceIds = meanTimeToRepairMap.keySet();
        System.debug( LoggingLevel.DEBUG, 'sourceIds - '+sourceIds);
        List<SVMXC__SPM_Top_Level_Summary__c> existingSummaries =  [SELECT SVMXC__Primary_Work_Order__c, SVMXC__Labor_Time__c, SVMXC__Dead_Time__c FROM SVMXC__SPM_Top_Level_Summary__c WHERE SVMXC__Primary_Work_Order__c IN :sourceIds]; 
        
        Map<Id, SVMXC__SPM_Top_Level_Summary__c> updatedSummaries = new Map<Id, SVMXC__SPM_Top_Level_Summary__c>();
        
        if(existingSummaries.size() > 0) {
            for(SVMXC__SPM_Top_Level_Summary__c summary: existingSummaries) {
                updatedSummaries.put(summary.SVMXC__Primary_Work_Order__c, summary);
            }
        }
        
        System.debug( LoggingLevel.DEBUG, 'updatedSummaries - '+updatedSummaries);
        Decimal labourTime = 0;
        Decimal deadTime = 0;
        SVMXC__SPM_Top_Level_Summary__c summary = null;
        
        for(Id topLevelIssueId:meanTimeToRepairMap.keySet()) {
            labourTime = 0;
            deadTime = 0;
            if(updatedSummaries.containsKey(topLevelIssueId)) {
                System.debug( LoggingLevel.DEBUG, 'Updating the summary as the data for this source is already present');
                summary = updatedSummaries.get(topLevelIssueId);
            } else {
                System.debug( LoggingLevel.DEBUG, 'Creatign a new summary object');
                summary = new SVMXC__SPM_Top_Level_Summary__c();
                summary.SVMXC__Primary_Work_Order__c = topLevelIssueId;
            }
            
            tempList = meanTimeToRepairMap.get(topLevelIssueId);
            for(SVMXC__SPM_Mean_Time_To_Repair__c obj: tempList) {
                labourTime += obj.SVMXC__Labor_Time__c;
                deadTime += obj.SVMXC__Dead_Time__c;
            }
            System.debug( LoggingLevel.DEBUG, 'labourTime - ' + labourTime);
            System.debug( LoggingLevel.DEBUG, 'deadTime - ' + deadTime);
                
            summary.SVMXC__Labor_Time__c = labourTime;
            summary.SVMXC__Dead_Time__c = deadTime;
            updatedSummaries.put(topLevelIssueId, summary);
        }
        System.debug( LoggingLevel.DEBUG, 'updatedSummaries - '+updatedSummaries);
        upsert updatedSummaries.values();
        System.debug( LoggingLevel.DEBUG, 'updateSummaryForPrimaryWorkorder() - exit' );
    }    
    
    /**
     * 
     */
    global override void onFinishComplete() {
        System.debug( LoggingLevel.DEBUG, 'onFinishComplete()' );
    }
}