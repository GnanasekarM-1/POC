/*****************************************************************************
 *                       Copyright (C) 2016 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * Batch implementation for deleting the records. 
 * This is used to delete the data from below tables
 *  1) Data sourced from SFDC Events/Servimax Events  
 *  2) Tech Utilization data computed from previous runs
 * 
 *
 * @author Praveen 
 * @version 1.0
 * @since 2016
 */
global class SPM_Scheduling_Purge_Tech_Utlization implements Database.Batchable<SObject>, Database.Stateful {

    /**
     * Holds the reference to the query being executed for deleting the records in batches.
     **/
    global String query = '';
    
    /**
     * Holds the reference to audit log file.
     **/
    private SPM_Scheduling_AuditLog auditLog;

    /**
     * Constructor method for initializing the query.
     * 
     * @param value - query to be run.
     **/
    global SPM_Scheduling_Purge_Tech_Utlization(String value) {
        System.debug( LoggingLevel.DEBUG, 'Invoked the SPM_Scheduling_Purge_Tech_Utlization constructor with the query - '+ value);
        this.query = value;
    }
    
    public void setAuditLog(SPM_Scheduling_AuditLog auditLogInstance) {
        this.auditLog = auditLogInstance;
    }
    
    /**
     * Method to run the query and execute the batch.
     */
    global Database.QueryLocator start(Database.BatchableContext context)
    {
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Purge_Tech_Utlization.start() - Invoking the query for batch processing' );
        auditLog.startTime = System.now();
        return Database.getQueryLocator(query);
    }

    /**
     * Invoked on every batch run.
     */
    global void execute(Database.BatchableContext context, List<sObject> records)
    {        
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Purge_Tech_Utlization.execute() - start');
        if(records.size() == 0) {
            System.debug( LoggingLevel.DEBUG, 'No records to be processed');
            auditLog.addFailureMessage( 'No records were loaded for processing');
        }
        auditLog.totalRecordsCount += records.size();
        System.debug( LoggingLevel.DEBUG, 'Invoke delete on the records size - '+records.size());
        //Delete the records in batches.
        //delete records;
        // if(COMM_SecurityUtils.getInstance().isDeletableObject(records.get(0).getName())) {
        //     delete records;
        // } else {
        //     throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
        // }
        
        sObject tempObject = records.get(0);
        System.debug( LoggingLevel.DEBUG, 'Object being purged - '+tempObject);
        String sourceObject = 'SVMXC__SPM_Schedul_Tech_Utilization_Constraints__c';
        if(tempObject instanceOf SVMXC__SM_Scheduling_Job_Summary__c) {
            sourceObject = 'SVMXC__SM_Scheduling_Job_Summary__c';
        }
        
        System.debug( LoggingLevel.DEBUG, 'Checking the security check for the object - ' + sourceObject);
        //Delete the records in batches.
        if(COMM_SecurityUtils.getInstance().isDeletableObject(sourceObject)) {
            delete records;
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
        }
        
    }
    
    /**
     * Invoked after the batch operation is completed.
     */
    global void finish(Database.BatchableContext context) {
        
    	System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Purge_Tech_Utlization.finish()' );
    	
        auditLog.addMessage('Total Number of Constraints Record Purged - ' + auditLog.totalRecordsCount);
    	auditLog.addMessage('Report Generation Start Time - ' + auditLog.startTime);
        auditLog.addMessage('Report Generation End Time - ' + System.now());
        auditLog.addMessage('Report generation success status - '+ auditLog.isSuccess);
        auditLog.addMessage('Time taken to generate the report (in ms) - '+ (System.now().getTime() - auditLog.startTime.getTime()));
        auditLog.addMessage('User initiating the report - ' + UserInfo.getName());
        String emailId = '';
        if( !Test.isRunningTest() ) { //Temp Fix
            //parse the configuration and extract the emailId.
            emailId = SPM_Utilities.getInstance().loadConfigurationValue('emailId'); 
            //SPM_Utilities.getInstance().getEmailIdFromScheduledConfiguration(); //getEmailId();
        }
        auditLog.saveAuditAndSendMessage(emailId, 'SPM Scheduled Data Purge');
    }    	
    
}