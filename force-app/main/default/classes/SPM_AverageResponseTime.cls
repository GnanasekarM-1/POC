/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 *
 * @author Manish Kushwah
 * @version 16.3 (Spr 16)
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Manish Kushwah         06 Jan 2016     Created. 
 *              Manish Kushwah         01 Apr 2016     Security Fixes
 *****************************************************************************************************/

global with sharing class SPM_AverageResponseTime extends SPM_AbstractBatch {

    /**
     *Constructor
     */
    global SPM_AverageResponseTime( SVMXC__ServiceMax_Config_Data__c scheduleData ) {         
        super( SPM_Schema.Report.AverageResponseTime, scheduleData );
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
     *Initialization method for initializing calculation method, calculating number of days needs
	 *to consider for fetching source records and adding where clause for the source object query
	 *and also removing null check for some fields in the source object query
     */
    global override void initBatchConfiguration() {        
        System.debug( LoggingLevel.DEBUG, 'SPM_AverageResponseTime.initBatchConfiguration() - enter' );

        loadBusinessProcessConfiguration();
        String tempWhereClause = populateCreatedAndLastModifiedDateFields();
		
		//Checking atleast one of the time should not be null and greater than zero
		String InitialApiName = getSourceObjectField(SPM_Schema.Field.TimeToInitialResponse);
		String OnsiteApiName = getSourceObjectField(SPM_Schema.Field.TimeToOnsiteResponse);
		String RestoreApiName = getSourceObjectField(SPM_Schema.Field.TimeToRestore);
		String ResolveApiName = getSourceObjectField(SPM_Schema.Field.TimeToResolve);
		
		tempWhereClause += ' AND (('+InitialApiName+' !=null AND '+InitialApiName+' >0) OR ('+OnsiteApiName+' !=null AND '+OnsiteApiName+' >0) OR ('+ResolveApiName+' !=null AND '+ResolveApiName+' >0) OR ('+RestoreApiName+' !=null AND '+RestoreApiName+' >0))';
		
        setWhereClause(tempWhereClause);
		
		//Adding fields name which are not required for null check in the Source object query
		List<SPM_Schema.Field> lstIgnoreFields = new List<SPM_Schema.Field>{SPM_Schema.Field.TimeToInitialResponse, SPM_Schema.Field.TimeToOnsiteResponse, SPM_Schema.Field.TimeToResolve, SPM_Schema.Field.TimeToRestore, SPM_Schema.Field.ServiceContract, SPM_Schema.Field.SLAInitialResponseTime, SPM_Schema.Field.SLAOnsiteResponseTime, SPM_Schema.Field.SLARestorationTime, SPM_Schema.Field.SLAResolutionTime, SPM_Schema.Field.ClockExtensionMinutes, SPM_Schema.Field.SLATerms};
		addIgnoreNullCheckField(lstIgnoreFields);
		
        System.debug( LoggingLevel.DEBUG, 'SPM_AverageResponseTime.initBatchConfiguration() - exit' );
    }
    
    /**
     * This method handles source record(Work Order records) for processing Average Response Time records.
     */
    global override void handleRecords( List<SObject> records ) {
		System.debug( LoggingLevel.DEBUG, 'SPM_AverageResponseTime.handleRecords() - enter; records: ' + records.size() );
		if(records.isEmpty()) {
			System.debug( LoggingLevel.INFO, 'No Work orders available in this execution');
            return;
        }
		
		//Fetching Calculation method name and Configuration name
		String strCalculationMethodName = getCalculationMethodName();
		String strConfigurationName = getConfigurationName();
		
		System.debug(LoggingLevel.DEBUG, 'ConfigurationName: '+strConfigurationName+'CalculationMethodName: '+strCalculationMethodName);
		
		//Collecting Work Order record ids from source record list
		Set<Id> setWorkOrderIds = new Set<Id>();
		for(SObject record : records)
			setWorkOrderIds.add((Id)getSourceObjectFieldValue(record, SPM_Schema.Field.Id));
		System.debug(LoggingLevel.DEBUG, 'setWorkOrderIds: '+setWorkOrderIds);
		
		List<String> queryFields = new List<String> {'SVMXC__Work_Order__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SPM_Average_Response_Time__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
		
		//Querying existing ART records based on calculation method name and set of Work order ids.
		List<SVMXC__SPM_Average_Response_Time__c> lstART = [SELECT SVMXC__Work_Order__c FROM SVMXC__SPM_Average_Response_Time__c WHERE SVMXC__Work_Order__c IN: setWorkOrderIds];
		
		//Creating map of Work order ids and ART record
		Map<Id, SVMXC__SPM_Average_Response_Time__c> mapWorkOrderIdVsArtRecord = new Map<Id, SVMXC__SPM_Average_Response_Time__c>();
		for(SVMXC__SPM_Average_Response_Time__c obj: lstART)
			mapWorkOrderIdVsArtRecord.put(obj.SVMXC__Work_Order__c, obj);
		System.debug(LoggingLevel.DEBUG, 'mapWorkOrderIdVsArtRecord: '+mapWorkOrderIdVsArtRecord);
		
		lstART = new List<SVMXC__SPM_Average_Response_Time__c>();
		for(SObject record : records){
			Id WorkOrderId = (Id)getSourceObjectFieldValue(record, SPM_Schema.Field.Id);
			SVMXC__SPM_Average_Response_Time__c objART = null;
			
			//Checking ART record is already present OR not for particular Work order id
			if((!mapWorkOrderIdVsArtRecord.isEmpty()) && mapWorkOrderIdVsArtRecord.containsKey(WorkOrderId)){
				//objART = mapWorkOrderIdVsArtRecord.get(WorkOrderId);
				continue;
			}
			else{
				objART = new SVMXC__SPM_Average_Response_Time__c();
			}
			objART = createOrUpdateRecord(objART, record, WorkOrderId, strConfigurationName, strCalculationMethodName);
			populateIssueLevelFields(record, objART);
			lstART.add(objART);
		}
		if(!lstART.isEmpty()){
			//Added for Mapping feature
            performFieldMapping(records, lstART);
			if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstART, COMM_SecurityUtils.Access.Createable ) ) {
                insert lstART;
                
                 if(savedConfiguration != NULL && savedConfiguration.source != NULL) {
                    if(savedConfiguration.source=='Case') {
                        updateSummaryForCase(lstART);
                    } else if(savedConfiguration.source == 'SVMXC__Service_Request__c') {
                        updateSummaryForServiceRequest(lstART);
                    } else {
                        updateSummaryForPrimaryWorkorder(lstART);
                    }
                }
                
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            } 
		}
		System.debug(LoggingLevel.DEBUG, 'lstART size: '+lstART.size());
		addInfo('Number of ART Records processed: '+lstART.size());
        System.debug( LoggingLevel.DEBUG, 'SPM_AverageResponseTime.handleRecords() - exit' );
    }
    
    /**
     * Populate the top-level issue information to target table.
     **/
    private void populateIssueLevelFields(SObject record, SVMXC__SPM_Average_Response_Time__c objART) {
        if(savedConfiguration != NULL && savedConfiguration.source != NULL) {
            if(savedConfiguration.source=='Case') {
                if(record.get(SPM_Consts.WOCASE) !=NULL) {                
                    objART.SVMXC__Case__c = (Id) record.get(SPM_Consts.WOCASE);                    
                }
            } else if(savedConfiguration.source == 'SVMXC__Service_Request__c') {
                if(record.get(SPM_Consts.WOSERVICEREQUESTFIELD) !=NULL) {                
                    objART.SVMXC__Service_Request__c = (Id) record.get(SPM_Consts.WOSERVICEREQUESTFIELD);                    
                }
            } else {
                if(record.get(SPM_Consts.RELATED_WORK_ORDER) != NULL) {                                               
                    objART.SVMXC__Primary_Work_Order__c = (Id) record.get(SPM_Consts.RELATED_WORK_ORDER);                                            
                } else {                                               
                    objART.SVMXC__Primary_Work_Order__c = (Id) record.get( SPM_Consts.RECORD_ID );                                            
                }                    
            }
        }
    }
	
	/**
     * This private method handles cretion and updation of Average Response Time record.
     */
	private SVMXC__SPM_Average_Response_Time__c createOrUpdateRecord(SVMXC__SPM_Average_Response_Time__c objART, SObject record, Id WorkOrderId, String strConfigurationName, String strCalculationMethodName){
		objART.SVMXC__Work_Order__c = WorkOrderId;
		objART.SVMXC__Configuration_Name__c = strConfigurationName;
		objART.SVMXC__Calculation_Method__c = strCalculationMethodName;
		objART.SVMXC__Service_Delivered_On__c = ((Datetime) getSourceObjectFieldValue(record, SPM_Schema.Field.ServiceDeliveredOn)).date();
		objART.SVMXC__Technician__c = (Id) getSourceObjectFieldValue(record, SPM_Schema.Field.Technician);
		objART.SVMXC__Account__c = (Id) getSourceObjectFieldValue(record, SPM_Schema.Field.Account);
		objART.SVMXC__Service_Contract__c = (Id) getSourceObjectFieldValue(record, SPM_Schema.Field.ServiceContract);
		objART.SVMXC__Product__c = (Id) getSourceObjectFieldValue(record, SPM_Schema.Field.Product);
		objART.SVMXC__SLA_Terms__c = (Id) getSourceObjectFieldValue(record, SPM_Schema.Field.SLATerms);
		objART.SVMXC__Actual_Initial_Response_Time__c = (Double) getSourceObjectFieldValue(record, SPM_Schema.Field.TimeToInitialResponse);
		objART.SVMXC__Actual_Onsite_Response_Time__c = (Double) getSourceObjectFieldValue(record, SPM_Schema.Field.TimeToOnsiteResponse);
		objART.SVMXC__Actual_Restoration_Time__c = (Double) getSourceObjectFieldValue(record, SPM_Schema.Field.TimeToRestore);
		objART.SVMXC__Actual_Resolution_Time__c = (Double) getSourceObjectFieldValue(record, SPM_Schema.Field.TimeToResolve);
		objART.SVMXC__SLA_Initial_Response_Time__c = (Double) getSourceObjectFieldValue(record, SPM_Schema.Field.SLAInitialResponseTime);
		objART.SVMXC__SLA_Onsite_Response_Time__c = (Double) getSourceObjectFieldValue(record, SPM_Schema.Field.SLAOnsiteResponseTime);
		objART.SVMXC__SLA_Restoration_Time__c = (Double) getSourceObjectFieldValue(record, SPM_Schema.Field.SLARestorationTime);
		objART.SVMXC__SLA_Resolution_Time__c = (Double) getSourceObjectFieldValue(record, SPM_Schema.Field.SLAResolutionTime);
		objART.SVMXC__Extension_Time__c = (Double) getSourceObjectFieldValue(record, SPM_Schema.Field.ClockExtensionMinutes);
		return objART;
	}
	
    /**
     * 
     **/
    private void updateSummaryForCase(List<SVMXC__SPM_Average_Response_Time__c> artList) {
        System.debug( LoggingLevel.DEBUG, 'updateSummaryForCase() - enter' );
        System.debug( LoggingLevel.DEBUG, 'artList - '+artList);
        
        Map<Id, List<SVMXC__SPM_Average_Response_Time__c>> artMap = new Map<Id, List<SVMXC__SPM_Average_Response_Time__c>>();
        List<SVMXC__SPM_Average_Response_Time__c> tempList = null; 
        for(SVMXC__SPM_Average_Response_Time__c obj: artList) {
            if(artMap.containsKey(obj.SVMXC__Case__c)) {
                tempList = artMap.get(obj.SVMXC__Case__c);
            } else {
                tempList = new List<SVMXC__SPM_Average_Response_Time__c>();
            }
            tempList.add(obj);
            artMap.put(obj.SVMXC__Case__c, tempList);  
        }
        
        Set<Id> sourceIds = artMap.keySet();
        System.debug( LoggingLevel.DEBUG, 'sourceIds - '+sourceIds);
        
        List<String> queryFields = new List<String> {'SVMXC__Case__c', 'SVMXC__Actual_Onsite_Response_Time__c', 'SVMXC__SLA_Onsite_Response_Time__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SPM_Top_Level_Summary__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        List<SVMXC__SPM_Top_Level_Summary__c> existingSummaries =  [SELECT SVMXC__Case__c, SVMXC__Actual_Onsite_Response_Time__c,
            SVMXC__SLA_Onsite_Response_Time__c FROM SVMXC__SPM_Top_Level_Summary__c WHERE SVMXC__Case__c IN :sourceIds]; 
        Map<Id, SVMXC__SPM_Top_Level_Summary__c> updatedSummaries = new Map<Id, SVMXC__SPM_Top_Level_Summary__c>();
        if(existingSummaries.size() > 0) {
            for(SVMXC__SPM_Top_Level_Summary__c summary: existingSummaries) {
                updatedSummaries.put(summary.SVMXC__Case__c, summary);
            }
        }
        
        System.debug( LoggingLevel.DEBUG, 'updatedSummaries - '+updatedSummaries);
        Decimal actualTime = 0;
        Decimal slaTime = 0;
        SVMXC__SPM_Top_Level_Summary__c summary = null;
        
        for(Id topLevelIssueId:artMap.keySet()) {
            actualTime = 0;
            slaTime = 0;
            if(updatedSummaries.containsKey(topLevelIssueId)) {
                System.debug( LoggingLevel.DEBUG, 'Updating the summary as the data for this source is already present');
                summary = updatedSummaries.get(topLevelIssueId);
                System.debug( LoggingLevel.DEBUG, 'actualTime - ' + actualTime);
                System.debug( LoggingLevel.DEBUG, 'slaTime - ' + slaTime);
            } else {
                System.debug( LoggingLevel.DEBUG, 'Creatign a new summary object');
                summary = new SVMXC__SPM_Top_Level_Summary__c();
                summary.SVMXC__Case__c = topLevelIssueId;
            }
            
            tempList = artMap.get(topLevelIssueId);
            for(SVMXC__SPM_Average_Response_Time__c obj: tempList) {
                if(obj.SVMXC__Actual_Onsite_Response_Time__c != null) {
                    actualTime += obj.SVMXC__Actual_Onsite_Response_Time__c;
                }
                if(obj.SVMXC__SLA_Onsite_Response_Time__c != null) {
                    slaTime += obj.SVMXC__SLA_Onsite_Response_Time__c;
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'actualTime - ' + actualTime);
            System.debug( LoggingLevel.DEBUG, 'slaTime - ' + slaTime);
                
            summary.SVMXC__Actual_Onsite_Response_Time__c = actualTime;
            summary.SVMXC__SLA_Onsite_Response_Time__c = slaTime;
            updatedSummaries.put(topLevelIssueId, summary);
                
        }
        System.debug( LoggingLevel.DEBUG, 'updatedSummaries - '+updatedSummaries);
        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(updatedSummaries.values(), COMM_SecurityUtils.Access.Upsertable)){
            upsert updatedSummaries.values();
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        System.debug( LoggingLevel.DEBUG, 'updateSummaryForCase() - exit' );
    }
    
    
    private void updateSummaryForServiceRequest(List<SVMXC__SPM_Average_Response_Time__c> artList) {
        System.debug( LoggingLevel.DEBUG, 'updateSummaryForServiceRequest() - enter' );
        System.debug( LoggingLevel.DEBUG, 'artList - '+artList);
        
        Map<Id, List<SVMXC__SPM_Average_Response_Time__c>> artMap = new Map<Id, List<SVMXC__SPM_Average_Response_Time__c>>();
        List<SVMXC__SPM_Average_Response_Time__c> tempList = null; 
        for(SVMXC__SPM_Average_Response_Time__c obj: artList) {
            if(artMap.containsKey(obj.SVMXC__Service_Request__c)) {
                tempList = artMap.get(obj.SVMXC__Service_Request__c);
            } else {
                tempList = new List<SVMXC__SPM_Average_Response_Time__c>();
            }
            tempList.add(obj);
            artMap.put(obj.SVMXC__Service_Request__c, tempList);  
        }
        
        Set<Id> sourceIds = artMap.keySet();
        System.debug( LoggingLevel.DEBUG, 'sourceIds - '+sourceIds);
        
        List<String> queryFields = new List<String> {'SVMXC__Service_Request__c', 'SVMXC__Actual_Onsite_Response_Time__c', 'SVMXC__SLA_Onsite_Response_Time__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SPM_Top_Level_Summary__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        List<SVMXC__SPM_Top_Level_Summary__c> existingSummaries =  [SELECT SVMXC__Service_Request__c, SVMXC__Actual_Onsite_Response_Time__c,
            SVMXC__SLA_Onsite_Response_Time__c FROM SVMXC__SPM_Top_Level_Summary__c WHERE SVMXC__Service_Request__c IN :sourceIds]; 
        Map<Id, SVMXC__SPM_Top_Level_Summary__c> updatedSummaries = new Map<Id, SVMXC__SPM_Top_Level_Summary__c>();
        if(existingSummaries.size() > 0) {
            for(SVMXC__SPM_Top_Level_Summary__c summary: existingSummaries) {
                updatedSummaries.put(summary.SVMXC__Service_Request__c, summary);
            }
        }
        
        System.debug( LoggingLevel.DEBUG, 'updatedSummaries - '+updatedSummaries);
        Decimal actualTime = 0;
        Decimal slaTime = 0;
        SVMXC__SPM_Top_Level_Summary__c summary = null;
        
        for(Id topLevelIssueId:artMap.keySet()) {
            actualTime = 0;
            slaTime = 0;
            if(updatedSummaries.containsKey(topLevelIssueId)) {
                System.debug( LoggingLevel.DEBUG, 'Updating the summary as the data for this source is already present');
                summary = updatedSummaries.get(topLevelIssueId);
                System.debug( LoggingLevel.DEBUG, 'actualTime - ' + actualTime);
                System.debug( LoggingLevel.DEBUG, 'slaTime - ' + slaTime);
            } else {
                System.debug( LoggingLevel.DEBUG, 'Creatign a new summary object');
                summary = new SVMXC__SPM_Top_Level_Summary__c();
                summary.SVMXC__Service_Request__c = topLevelIssueId;
            }
            
            tempList = artMap.get(topLevelIssueId);
            for(SVMXC__SPM_Average_Response_Time__c obj: tempList) {
                if(obj.SVMXC__Actual_Onsite_Response_Time__c != null) {
                    actualTime += obj.SVMXC__Actual_Onsite_Response_Time__c;
                }
                if(obj.SVMXC__SLA_Onsite_Response_Time__c != null) {
                    slaTime += obj.SVMXC__SLA_Onsite_Response_Time__c;
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'actualTime - ' + actualTime);
            System.debug( LoggingLevel.DEBUG, 'slaTime - ' + slaTime);
                
            summary.SVMXC__Actual_Onsite_Response_Time__c = actualTime;
            summary.SVMXC__SLA_Onsite_Response_Time__c = slaTime;
            updatedSummaries.put(topLevelIssueId, summary);
                
        }
        System.debug( LoggingLevel.DEBUG, 'updatedSummaries - '+updatedSummaries);
        //upsert updatedSummaries.values();
        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(updatedSummaries.values(), COMM_SecurityUtils.Access.Upsertable)){
            upsert updatedSummaries.values();
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        System.debug( LoggingLevel.DEBUG, 'updateSummaryForServiceRequest() - exit' );
    }

    private void updateSummaryForPrimaryWorkorder(List<SVMXC__SPM_Average_Response_Time__c> artList) {
        System.debug( LoggingLevel.DEBUG, 'updateSummaryForPrimaryWorkorder() - enter' );
        System.debug( LoggingLevel.DEBUG, 'artList - '+artList);
        
        Map<Id, List<SVMXC__SPM_Average_Response_Time__c>> artMap = new Map<Id, List<SVMXC__SPM_Average_Response_Time__c>>();
        List<SVMXC__SPM_Average_Response_Time__c> tempList = null; 
        for(SVMXC__SPM_Average_Response_Time__c obj: artList) {
            if(artMap.containsKey(obj.SVMXC__Primary_Work_Order__c)) {
                tempList = artMap.get(obj.SVMXC__Primary_Work_Order__c);
            } else {
                tempList = new List<SVMXC__SPM_Average_Response_Time__c>();
            }
            tempList.add(obj);
            artMap.put(obj.SVMXC__Primary_Work_Order__c, tempList);  
        }
        
        Set<Id> sourceIds = artMap.keySet();
        System.debug( LoggingLevel.DEBUG, 'sourceIds - '+sourceIds);
        
        List<String> queryFields = new List<String> {'SVMXC__Primary_Work_Order__c', 'SVMXC__Actual_Onsite_Response_Time__c', 'SVMXC__SLA_Onsite_Response_Time__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SPM_Top_Level_Summary__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        List<SVMXC__SPM_Top_Level_Summary__c> existingSummaries =  [SELECT SVMXC__Primary_Work_Order__c, SVMXC__Actual_Onsite_Response_Time__c,
            SVMXC__SLA_Onsite_Response_Time__c FROM SVMXC__SPM_Top_Level_Summary__c WHERE SVMXC__Primary_Work_Order__c IN :sourceIds]; 
        Map<Id, SVMXC__SPM_Top_Level_Summary__c> updatedSummaries = new Map<Id, SVMXC__SPM_Top_Level_Summary__c>();
        if(existingSummaries.size() > 0) {
            for(SVMXC__SPM_Top_Level_Summary__c summary: existingSummaries) {
                updatedSummaries.put(summary.SVMXC__Primary_Work_Order__c, summary);
            }
        }
        
        System.debug( LoggingLevel.DEBUG, 'updatedSummaries - '+updatedSummaries);
        Decimal actualTime = 0;
        Decimal slaTime = 0;
        SVMXC__SPM_Top_Level_Summary__c summary = null;
        
        for(Id topLevelIssueId:artMap.keySet()) {
            actualTime = 0;
            slaTime = 0;
            if(updatedSummaries.containsKey(topLevelIssueId)) {
                System.debug( LoggingLevel.DEBUG, 'Updating the summary as the data for this source is already present');
                summary = updatedSummaries.get(topLevelIssueId);
                System.debug( LoggingLevel.DEBUG, 'actualTime - ' + actualTime);
                System.debug( LoggingLevel.DEBUG, 'slaTime - ' + slaTime);
            } else {
                System.debug( LoggingLevel.DEBUG, 'Creatign a new summary object');
                summary = new SVMXC__SPM_Top_Level_Summary__c();
                summary.SVMXC__Primary_Work_Order__c = topLevelIssueId;
            }
            
            tempList = artMap.get(topLevelIssueId);
            for(SVMXC__SPM_Average_Response_Time__c obj: tempList) {
                if(obj.SVMXC__Actual_Onsite_Response_Time__c != null) {
                    actualTime += obj.SVMXC__Actual_Onsite_Response_Time__c;
                }
                if(obj.SVMXC__SLA_Onsite_Response_Time__c != null) {
                    slaTime += obj.SVMXC__SLA_Onsite_Response_Time__c;
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'actualTime - ' + actualTime);
            System.debug( LoggingLevel.DEBUG, 'slaTime - ' + slaTime);
                
            summary.SVMXC__Actual_Onsite_Response_Time__c = actualTime;
            summary.SVMXC__SLA_Onsite_Response_Time__c = slaTime;
            updatedSummaries.put(topLevelIssueId, summary);
                
        }
        System.debug( LoggingLevel.DEBUG, 'updatedSummaries - '+updatedSummaries);
        //upsert updatedSummaries.values();
        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(updatedSummaries.values(), COMM_SecurityUtils.Access.Upsertable)){
            upsert updatedSummaries.values();
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        System.debug( LoggingLevel.DEBUG, 'updateSummaryForPrimaryWorkorder() - exit' );
    }
    
    /**
     * This is finish method
     */
    global override void onFinishComplete() {
        System.debug( LoggingLevel.DEBUG, 'SPM_AverageResponseTime.onFinishComplete()' );
    }
}