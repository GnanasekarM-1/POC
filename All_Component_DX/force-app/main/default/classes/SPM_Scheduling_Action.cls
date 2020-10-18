/*****************************************************************************
 *                       Copyright (C) 2016 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * Delegator class for the requests sent from the Controller class.
 * 
 *
 * @author Praveen, Divya, Somabha
 * @version 1.0
 * @since 2016
 */
public class SPM_Scheduling_Action {
    
    
    /**
     * Get the list of jobs that satisfies the filter criteria specified by the input parameters.
     * 
     * @param  runStartDate        - Begin date range for the job run
     * @param  runEndDate          - End date range for the job run
     * @param  dispatchProcessName - Name of the dispatch process
     * @return                     - List of jobs.
     */
    public List<Map<String, String>> getJobs(Date runStartDate, Date runEndDate, String dispatchProcessName) {
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.getJobs() - enter' );
        System.debug('runStartDate - '+runStartDate + ', runEndDate - '+runEndDate);
        System.debug('statusComplete - '+SPM_Consts.COMPLETE + ' ,dispatchMethodName - '+SPM_Consts.OPTIMIZED_BATCH );
        System.debug('dispatchProcessName - '+dispatchProcessName);
        
        //Check for user access before quering the fields.
        List<String> queryFields = new List<String> {'SVMXC__SVMX_Process__r.SVMXC__Name__c','Name', 'SVMXC__End_Time__c', 'SVMXC__Start_Time__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SVMX_Jobs__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        //Check for user access before quering the fields.
        queryFields = new List<String> {'SVMXC__SM_JobId__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SM_Scheduling_Job_Summary__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        String dbQuery = 'SELECT SVMXC__SVMX_Process__r.SVMXC__Name__c, Name, SVMXC__End_Time__c, SVMXC__Start_Time__c'+
        ' FROM SVMXC__SVMX_Jobs__c where SVMXC__OptiMax_Message__c = \'Success\'' +
        ' and SVMXC__SVMX_Process__r.SVMXC__Dispatch_Method__c =\'' +SPM_Consts.OPTIMIZED_BATCH+'\'' +
        ' and SVMXC__SVMX_Process__r.SVMXC__Dispatch_Process_Status__c =\'' +SPM_Consts.COMPLETE+ '\'' +
        ' and DAY_ONLY(SVMXC__Start_Time__c) >=:runStartDate and DAY_ONLY(SVMXC__End_Time__c) <=:runEndDate ' + 
        ' and Id IN (SELECT SVMXC__SM_JobId__c from SVMXC__SM_Scheduling_Job_Summary__c) '; 
       
       
        if(dispatchProcessName != null && !String.isBlank(dispatchProcessName) && dispatchProcessName != 'All') {
            dbQuery = dbQuery + ' and SVMXC__SVMX_Process__r.SVMXC__Name__c =: dispatchProcessName';
        }
        //Jobs will be ordered by Name and only the top 50 results will be returned
        dbQuery = dbQuery + ' ORDER BY Name DESC limit 50';
        
        List<Map<String, String>> results = new List<Map<String, String>>();
        
        List<SVMXC__SVMX_Jobs__c> jobsList = Database.query(dbQuery);
        for(SVMXC__SVMX_Jobs__c job: jobsList) {
            Map<String, String> dataMap = new Map<String, String>();
            dataMap.put('jobId', job.Name);
            
            dataMap.put('processName', String.valueOf(job.SVMXC__SVMX_Process__r.SVMXC__Name__c));
            dataMap.put('startDate', String.valueOf(job.SVMXC__Start_Time__c));
            dataMap.put('endDate', String.valueOf(job.SVMXC__End_Time__c));
            //dataMap.put('status', 'completed');
           
            results.add(dataMap);
        }
        System.debug( LoggingLevel.DEBUG, 'Total Jobs Loaded Count - ' + results.size());
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.getJobs() - exit' );
        return results;
    }
    
    
    /**
     * Get the list of jobs that satisfies the filter criteria specified by the input parameters. And filter only those jobs which has data in source tables.
     * 
     * @param  runStartDate        - Begin date range for the job run
     * @param  runEndDate          - End date range for the job run
     * @param  dispatchProcessName - Name of the dispatch process
     * @return                     - List of jobs.
     */
    public List<Map<String, String>> getJobsForPurging(Date runStartDate, Date runEndDate, String dispatchProcessName) {
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.getJobsForPurging() - enter' );
        System.debug('runStartDate - '+runStartDate + ', runEndDate - '+runEndDate);
        System.debug('statusComplete - '+SPM_Consts.COMPLETE + ' ,dispatchMethodName - '+SPM_Consts.OPTIMIZED_BATCH );
        System.debug('dispatchProcessName - '+dispatchProcessName);
        
        //Check for user access before quering the fields.
        List<String> queryFields = new List<String> {'SVMXC__SVMX_Process__r.SVMXC__Name__c','Name', 'SVMXC__End_Time__c', 'SVMXC__Start_Time__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SVMX_Jobs__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        String dbQuery = 'SELECT SVMXC__SVMX_Process__r.SVMXC__Name__c, Name, SVMXC__End_Time__c, SVMXC__Start_Time__c'+
        ' FROM SVMXC__SVMX_Jobs__c where SVMXC__OptiMax_Message__c = \'Success\'' +
        ' and SVMXC__SVMX_Process__r.SVMXC__Dispatch_Method__c =\'' +SPM_Consts.OPTIMIZED_BATCH+'\'' +
        ' and SVMXC__SVMX_Process__r.SVMXC__Dispatch_Process_Status__c =\'' +SPM_Consts.COMPLETE+ '\'' +
        ' and DAY_ONLY(SVMXC__Start_Time__c) >=:runStartDate and DAY_ONLY(SVMXC__End_Time__c) <=:runEndDate '; 
       
       
        if(dispatchProcessName != null && !String.isBlank(dispatchProcessName) && dispatchProcessName != 'All') {
            dbQuery = dbQuery + ' and SVMXC__SVMX_Process__r.SVMXC__Name__c =: dispatchProcessName';
        }
        //Jobs will be ordered by Name and only the top 50 results will be returned
        dbQuery = dbQuery + ' ORDER BY Name DESC limit 50';
        
        List<Map<String, String>> results = new List<Map<String, String>>();
        List<SVMXC__SVMX_Jobs__c> jobsList = Database.query(dbQuery);
        System.debug(LoggingLevel.DEBUG,'Number of jobs loaded - ' + jobsList.size());
        System.debug(LoggingLevel.DEBUG,'Jobs loaded - ' + jobsList);
        
        if(jobsList.size() > 0) {
            
            Map<String, SVMXC__SVMX_Jobs__c> jobIdMap = new Map<String, SVMXC__SVMX_Jobs__c>();
            for(SVMXC__SVMX_Jobs__c job: jobsList) {
                jobIdMap.put(job.Name, job);
            }
        
            //Check for user access before quering the fields.
            queryFields = new List<String> {'SVMXC__SM_JobId__r.Name'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SM_Scheduling_Job_Summary__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            List<SVMXC__SM_Scheduling_Job_Summary__c> summaryRecords = [SELECT SVMXC__SM_JobId__r.Name FROM SVMXC__SM_Scheduling_Job_Summary__c 
                                                                        where SVMXC__SM_JobId__r.Name IN:jobIdMap.keySet() ORDER BY SVMXC__SM_JobId__r.Name DESC];
            System.debug(LoggingLevel.DEBUG,'Number of Jobs having the sourced data - ' + summaryRecords.size());
            System.debug(LoggingLevel.DEBUG,'Jobs having the sourced data - ' + summaryRecords);
            if(summaryRecords.size() > 0) {
                
                SVMXC__SVMX_Jobs__c job = null;
                Map<String, String> dataMap = null;
                for(SVMXC__SM_Scheduling_Job_Summary__c summary: summaryRecords) {
                    job = jobIdMap.get(summary.SVMXC__SM_JobId__r.Name);
                    dataMap = new Map<String, String>();
                    dataMap.put('jobId', job.Name);
                    dataMap.put('processName', String.valueOf(job.SVMXC__SVMX_Process__r.SVMXC__Name__c));
                    dataMap.put('startDate', String.valueOf(job.SVMXC__Start_Time__c));
                    dataMap.put('endDate', String.valueOf(job.SVMXC__End_Time__c));
                    results.add(dataMap);
                }
            }
        } else {
            System.debug(LoggingLevel.DEBUG,'No Jobs found for the passed in parameters');
        }
        
        System.debug( LoggingLevel.DEBUG, 'Valid Jobs Count - ' + results.size());
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.getJobsForPurging() - exit');
        return results;
    }
    
    
   /**
    * [sourceOptimaxData description]
    * @param jobId          [description]
    * @param startDateValue [description]
    * @param endDateValue   [description]
    */
    public void sourceSchedulingData(String jobId, DateTime startDateValue, DateTime endDateValue) {
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.sourceSchedulingData() - enter' );
        String strExecLogMsgAnalytics = '';
        
          try {
            
            System.debug( LoggingLevel.DEBUG, 'sourceSchedulingData() -enter' );
            strExecLogMsgAnalytics = 'jobId-' + jobId + ' : startDateValue-' + startDateValue + ' : endDateValue-' + endDateValue;
            strExecLogMsgAnalytics += 'jobId-' + jobId + ' : startDateValue.date()-' + startDateValue.date() + ' : endDateValue.date()-' + endDateValue.date();
            System.debug( LoggingLevel.DEBUG,'jobId-' + jobId + ' : startDateValue-' + startDateValue + ' : endDateValue-' + endDateValue);
            System.debug( LoggingLevel.DEBUG, 'jobId-' + jobId + ' : startDateValue.date()-' + startDateValue.date() + ' : endDateValue.date()-' + endDateValue.date());
            
            // Get the jobs detials
            SVMXC__SVMX_Jobs__c job = [SELECT SVMXC__SVMX_Process__r.id, SVMXC__SVMX_Process__r.SVMXC__Name__c, 
                                              SVMXC__End_Time__c, SVMXC__Start_Time__c, SVMXC__Territory__c 
                                              FROM SVMXC__SVMX_Jobs__c where Id =: jobId];
            System.debug( LoggingLevel.DEBUG,'Job - '+job);
            
            strExecLogMsgAnalytics += 'job===='+job+'\n';
            
            if(job == null) {
                System.debug( LoggingLevel.DEBUG,'No Jobs found for the parameters sent from Optimax engine');
                return;
            }
      Date startDate = startDateValue.date();
      Date endDate = endDateValue.date();
              
             String formatedStartDate = startDateValue.formatGmt('yyyy-MM-dd');
            String formatedEndDate = endDateValue.formatGmt('yyyy-MM-dd');
            
              //startDateValue = DateTime.newInstance(tempDate.year(), tempDate.month(), tempDate.day(), 0 , 0 , 0);
            Id jobSummaryId = createJobSummary(jobId, startDate, endDate);
            
            strExecLogMsgAnalytics += '----jobSummaryId=='+jobSummaryId+'\n';
            
            //Check for user access before quering the fields.
            List<String> queryFields = new List<String> {'Id','Name','SVMXC__Break_Hours__c','SVMXC__Overtime_Hours__c','SVMXC__Salesforce_User__c','SVMXC__Service_Group__c','SVMXC__Service_Territory__c','SVMXC__Working_Hours__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Service_Group_Members__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            
            //Get the techncian information
            List<SVMXC__Service_Group_Members__c> technicians = [SELECT Id, Name,SVMXC__Break_Hours__c,SVMXC__Overtime_Hours__c,
                                        SVMXC__Salesforce_User__c,SVMXC__Service_Group__c,SVMXC__Service_Territory__c,
                                        SVMXC__Working_Hours__c FROM SVMXC__Service_Group_Members__c 
                                        WHERE SVMXC__Service_Territory__c =: job.SVMXC__Territory__c];
                                        
            strExecLogMsgAnalytics += '----technicians=='+technicians+'\n';                         
            
            
            //Source from SFDC Events        
             List<String> userIds = new List<String>();
             for(SVMXC__Service_Group_Members__c technician: technicians) {
                 if(technician.SVMXC__Salesforce_User__c != null) {
                     //userIds.add('\'' + technician.SVMXC__Salesforce_User__c + '\'');
                     userIds.add(technician.SVMXC__Salesforce_User__c);
                 }
             }
            System.debug( LoggingLevel.DEBUG, 'UserIds Ids - ' + userIds);
            
 
              String query = '';
              SPM_Scheduling_Source_Events sourceDataBatch = null;
              
              if(userIds.size() > 0) {
                  
                 //Check for user access before quering the fields.
                queryFields = new List<String> {'DurationInMinutes','Type','Subject','EventSubtype','Description','GroupEventType','StartDateTime','EndDateTime','SVMXC__Break_Time_Total__c',
                                                'SVMXC__Driving_Time_Home__c','OwnerId','SVMXC__Driving_Time__c','SVMXC__Overhead_Time_After__c',
                                                'SVMXC__Overhead_Time_Before__c','SVMXC__Service_Duration__c','WhatId'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'Event', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                
                query = 'SELECT DurationInMinutes, Type, Subject, EventSubtype, Description, GroupEventType, StartDateTime, EndDateTime, SVMXC__Break_Time_Total__c,'
                        +'SVMXC__Driving_Time_Home__c, OwnerId, SVMXC__Driving_Time__c, SVMXC__Overhead_Time_After__c,'
                        +'SVMXC__Overhead_Time_Before__c, SVMXC__Service_Duration__c, WhatId FROM Event ' 
                        +'Where DAY_ONLY(StartDateTime) >='+ formatedStartDate +' and DAY_ONLY(StartDateTime) <=' + formatedEndDate + ' and OwnerId IN :userIds';
              
                System.debug(LoggingLevel.DEBUG, 'SFDC Events Query - ' + query);
                sourceDataBatch = new SPM_Scheduling_Source_Events(query, job.Id, jobSummaryId);
                sourceDataBatch.setUserIds(userIds);
                Database.executeBatch(sourceDataBatch);
            }
            
  
        
          List<String> technicianIds = new List<String>();
            for(SVMXC__Service_Group_Members__c technician: technicians) {
                //technicianIds.add('\'' + technician.Id + '\'');
                technicianIds.add(technician.Id);
            }
          System.debug( LoggingLevel.DEBUG, 'Technician Ids - ' + technicianIds);
        
            //Check for user access before quering the fields.
            queryFields = new List<String> {'SVMXC__Technician__c','SVMXC__Break_Time_Total__c','SVMXC__Driving_Time_Home__c','SVMXC__Driving_Time__c',
                                            'SVMXC__DurationInMinutes__c','SVMXC__Type__c','SVMXC__Overhead_Time_After__c','SVMXC__Overhead_Time_Before__c','SVMXC__StartDateTime__c',
                                            'SVMXC__EndDateTime__c','SVMXC__WhatId__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SVMX_Event__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
          query = 'SELECT SVMXC__Technician__c, SVMXC__Break_Time_Total__c, SVMXC__Driving_Time_Home__c,'
                +'SVMXC__Driving_Time__c, SVMXC__DurationInMinutes__c, SVMXC__Type__c, SVMXC__Overhead_Time_After__c,'
                +'SVMXC__Overhead_Time_Before__c, SVMXC__StartDateTime__c, SVMXC__EndDateTime__c, SVMXC__WhatId__c FROM SVMXC__SVMX_Event__c ' 
                +'Where DAY_ONLY(SVMXC__StartDateTime__c) >='+ formatedStartDate +' and DAY_ONLY(SVMXC__StartDateTime__c) <='
                + formatedEndDate + ' and SVMXC__Technician__c IN :technicianIds';
        
          
                                               
            //DAY_ONLY(StartDateTime) >='+ startDate +' and DAY_ONLY(StartDateTime) <=' + endDate
                                               
            System.debug(LoggingLevel.DEBUG, 'Servivemax Events Query - ' + query);
            
            strExecLogMsgAnalytics += '----query=='+query+'\n'; 
            
            sourceDataBatch = new SPM_Scheduling_Source_Events(query, job.Id, jobSummaryId);
          sourceDataBatch.setTechnicianIds(technicianIds);
            Database.executeBatch(sourceDataBatch);
            System.debug( LoggingLevel.DEBUG, 'sourceOptimaxData() -exit' );
            
        
        } catch(Exception ex) {
            System.debug( LoggingLevel.ERROR, 'SPM_Scheduling_Action.sourceSchedulingData() Exception ! ' + ex.getMessage() );
            
        }
        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
        Attachment anaAttachment = new Attachment(Name = 'AnaLog', ParentId = jobId, Body = Blob.valueOf(strExecLogMsgAnalytics), IsPrivate = TRUE);
         if( COMM_SecurityUtils.getInstance().verifyFieldAccess( anaAttachment, COMM_SecurityUtils.Access.Createable ) ) {
                insert anaAttachment;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        
                
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.sourceSchedulingData() - exit' );
    }
    

    /**
     * Creates an entry into the job-summary table for the passed in jobId.
     **/
    //private Id createJobSummary(String jobId, DateTime horizonStartDate, DateTime horizonEndDate) {
    private Id createJobSummary(String jobId, Date horizonStartDate, Date horizonEndDate) {
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.createJobSummary() - enter' );
        List<SVMXC__SVMX_Jobs__c> jobs = [SELECT SVMXC__SVMX_Process__r.id, SVMXC__SVMX_Process__r.SVMXC__Name__c, 
                                            SVMXC__End_Time__c, SVMXC__Start_Time__c, SVMXC__Territory__c 
                                            FROM SVMXC__SVMX_Jobs__c where Id =: jobId];
        
        String strExecLogMsgAnalytics1 = '';
        strExecLogMsgAnalytics1 += 'jobs ==' + jobs + '---horizonStartDate=='+horizonStartDate+' -- horizonEndDate=='+horizonEndDate+'\n';
        
        if(jobs == null || jobs.size() == 0) {
            System.debug( LoggingLevel.DEBUG, 'No Jobs found for the jobId - ' + jobId);
            return null;
        }
        
        // Only one Job is considered as we get one JobId                
        SVMXC__SM_Scheduling_Job_Summary__c jobSummary = new SVMXC__SM_Scheduling_Job_Summary__c();
        SVMXC__SVMX_Jobs__c job = jobs.get(0);
        
        System.debug( LoggingLevel.DEBUG, 'execute(): populate jobSummary' );
        
        jobSummary.SVMXC__SM_Dispatch_Process_Id__c = job.SVMXC__SVMX_Process__r.Id;
        jobSummary.SVMXC__SM_Dispatch_Process_Name__c = job.SVMXC__SVMX_Process__r.SVMXC__Name__c;
        jobSummary.SVMXC__SM_Horizon_End_Date__c = horizonEndDate;
        jobSummary.SVMXC__SM_Horizon_Start_Date__c = horizonStartDate;
        jobSummary.SVMXC__SM_Job_End_Time__c = job.SVMXC__End_Time__c.date();
        jobSummary.SVMXC__SM_Job_Start_Time__c = job.SVMXC__Start_Time__c.date();
        jobSummary.SVMXC__SM_JobId__c = job.Id;
        jobSummary.SVMXC__SM_Territory__c = job.SVMXC__Territory__c;
        try {
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( jobSummary, COMM_SecurityUtils.Access.Createable ) ) {
                insert jobSummary;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        } catch(Exception ex) {
            System.debug(LoggingLevel.ERROR,'Exception in SPM_Scheduling_Action.createJobSummary() - '+ex.getMessage());
        }
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.createJobSummary() - exit' );
        return jobSummary.Id;
    }
    
    /**
     * This will purge data from SPM_Scheduling_Job_Summary__c and SPM_Scheduling_Tech_Utilization_Constraints__c tables using the 
     * passed in jobIds. Deleting records on these tables will also delete records from child tables like Scheduling_Event_Summary__c etc...
     * 
     * @param jobIds - list of job-ids having data in multiple tables.
     */
    public void purgeData(List<String> jobIds) {
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.purgeData() - enter' );
        
        SPM_Scheduling_AuditLog auditLog = new SPM_Scheduling_AuditLog();
        auditLog.addMessage('Application/Module Name: SPM Scheduling');
        auditLog.addMessage(' Jobs for Purge  - '+ jobIds);



        if(jobIds == null || jobIds.size() == 0) {
            System.debug( LoggingLevel.DEBUG, 'No jobs were sent for initiating the purge operation');
            return;
        } else {
            System.debug( LoggingLevel.DEBUG, 'List of job-ids - '+jobIds);
            String query = '';
            
            // List<String> formattedJobIds = new List<String>();
            // for(String jobId: jobIds) {
            //     formattedJobIds.add('\'' + jobId + '\'');
            // }
            
            //Source from SFDC Events    
            String formattedJobIds = '(\'';
            for(String jobId: jobIds) {
                formattedJobIds += jobId + '\', \'';
            }
            formattedJobIds = formattedJobIds.substring(0, formattedJobIds.length() - 3);
            formattedJobIds += ')';
    
            
            Integer recordsCount = [SELECT count() FROM SVMXC__SM_Scheduling_Job_Summary__c where SVMXC__SM_JobId__r.Name IN:jobIds limit 1];
            if(recordsCount > 0) {
                System.debug( LoggingLevel.DEBUG, 'Initiating purge on SPM_Scheduling_Job_Summary__c table');
                
                //Check for user access before quering the fields.
                List<String> queryFields = new List<String> {'Id'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SM_Scheduling_Job_Summary__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                query = 'SELECT Id FROM SVMXC__SM_Scheduling_Job_Summary__c where SVMXC__SM_JobId__r.Name IN ' + formattedJobIds +' limit 45000';
                SPM_Scheduling_Purge_Tech_Utlization purgeBatch = new SPM_Scheduling_Purge_Tech_Utlization(query);
                purgeBatch.setAuditLog(auditLog);
                Database.executeBatch(purgeBatch);
            } else {
                System.debug( LoggingLevel.DEBUG, 'No records found inside the SVMXC__SM_Scheduling_Job_Summary__c table for the passed in jobs');
            }
            
            recordsCount = [SELECT count() FROM SVMXC__SPM_Schedul_Tech_Utilization_Constraints__c where SVMXC__JobId__r.Name IN:jobIds limit 1];
            if(recordsCount > 0) {
                //Check for user access before quering the fields.
                List<String> queryFields = new List<String> {'Id'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SPM_Schedul_Tech_Utilization_Constraints__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                System.debug( LoggingLevel.DEBUG, 'Initiating purge on SPM_Scheduling_Tech_Utilization_Constraints__c table');
                query = 'SELECT Id FROM SVMXC__SPM_Schedul_Tech_Utilization_Constraints__c where SVMXC__JobId__r.Name IN ' + formattedJobIds +' limit 45000';
                SPM_Scheduling_Purge_Tech_Utlization purgeBatch = new SPM_Scheduling_Purge_Tech_Utlization(query);
                purgeBatch.setAuditLog(auditLog);
                Database.executeBatch(purgeBatch);
            } else {
                System.debug( LoggingLevel.DEBUG, 'No records found inside the SVMXC__SPM_Schedul_Tech_Utilization_Constraints__c table for the passed in jobs');
            }
        } 
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.purgeData() - exit' );
    }
    

    /**
     * Initiates the Technician Utilization Batch class for measuring the effectiveness of Optimax Run.
     * Following steps are performed while computing the utilzation.
     *    1) Ignore the jobs for which the utilization is already computed.
     *    2) Ignore the jobs for which there is no data in source tables (Event-Summay and Job-Summary)
     *    3) Invoke the Batch Class for computing the utilization for the remaining jobs.
     * 
     * @param jobIds - List of JobIds for which utilization needs to be derived.
     */
    public void computeUtilization(List<String> jobIds) {
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.computeUtilization() - enter' );
        
        SPM_Scheduling_AuditLog auditLog = new SPM_Scheduling_AuditLog();
        auditLog.addMessage('Application/Module Name: SPM Scheduling');
        auditLog.addMessage('Jobs sent for computing the utilization - '+ jobIds);


        if(jobIds == null || jobIds.size() == 0) {
            System.debug( LoggingLevel.ERROR, 'No Jobs sent for computing the utilization');
            return;
        } else {
            System.debug( LoggingLevel.DEBUG, 'Jobs sent for utilization computation - ' + jobIds);
            //Check for user access before quering the fields.
            List<String> queryFields = new List<String> {'Id','SVMXC__JobId__r.Name'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SPM_Schedul_Tech_Utilization_Constraints__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            List<SVMXC__SPM_Schedul_Tech_Utilization_Constraints__c> records =
                [SELECT Id, SVMXC__JobId__r.Name FROM SVMXC__SPM_Schedul_Tech_Utilization_Constraints__c 
                 where SVMXC__JobId__r.Name IN:jobIds];
            System.debug( LoggingLevel.DEBUG, 'Utilization already computed for - ' + records);
            if(records.size() > 0) {
                Set<String> processedJobIds = new Set<String>();
                for(SVMXC__SPM_Schedul_Tech_Utilization_Constraints__c record: records) {
                    processedJobIds.add(record.SVMXC__JobId__r.Name);
                }
                
                List<String> filteredJobIds = new List<String>();
                for(String jobId: jobIds) {
                    if(!processedJobIds.contains(jobId)) {
                        filteredJobIds.add(jobId);
                    }
                }
                jobIds = filteredJobIds;
            }            
            
            System.debug( LoggingLevel.DEBUG, 'Jobs not having the utilization computed - ' + jobIds);
            auditLog.addMessage('Jobs not having the utilization computed - '+ jobIds);
            
            if(jobIds.size() > 0) {
                
                //Check for user access before quering the fields.
                queryFields = new List<String> {'Id','SVMXC__SM_JobId__r.Name'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SM_Scheduling_Job_Summary__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                
                //Trigger the utilization only for the jobId's having data in source objects.  
                 List<SVMXC__SM_Scheduling_Job_Summary__c> summaryRecords =
                    [SELECT Id, SVMXC__SM_JobId__r.Name FROM SVMXC__SM_Scheduling_Job_Summary__c 
                     where SVMXC__SM_JobId__r.Name IN:jobIds];
                System.debug( LoggingLevel.DEBUG, 'Jobs having the source data - '+summaryRecords.size());
                if(summaryRecords.size() > 0) {
                    Set<String> sourcedJobIds = new Set<String>();
                    for(SVMXC__SM_Scheduling_Job_Summary__c record: summaryRecords) {
                        sourcedJobIds.add(record.SVMXC__SM_JobId__r.Name);
                    }
                    //System.debug( LoggingLevel.DEBUG, 'Jobs having the source records after filtering - ' + sourcedJobIds);
                    List<String> filteredJobIds = new List<String>();
                    for(String jobId: jobIds) {
                        if(sourcedJobIds.contains(jobId)) {
                            filteredJobIds.add(jobId);
                        }
                    }
                    jobIds = filteredJobIds;
                }
                System.debug( LoggingLevel.DEBUG, 'Valid Jobs for computing the utilization - ' + jobIds);
                auditLog.addMessage('Valid Jobs for computing the utilization - '+ jobIds);
             
                if(jobIds.size() > 0) {
                     List<String> formattedJobIds = new List<String>();
                    for(String jobId: jobIds) {
                        formattedJobIds.add('\'' + jobId + '\'');
                    }
                    
                    //Check for user access before quering the fields.
                    queryFields = new List<String> {'SVMXC__SM_Break_Minutes__c','SVMXC__SM_Drive_Time__c','SVMXC__SM_Event_Date__c','SVMXC__SM_Event_Duration__c','SVMXC__SM_Event_Type__c',
                                                    'SVMXC__SM_Job_Summary__c','SVMXC__SM_JobId__c','SVMXC__SM_JobId__r.SVMXC__SVMX_Process__c',
                                                    'SVMXC__SM_JobId__r.SVMXC__SVMX_Process__r.SVMXC__Name__c','SVMXC__SM_JobId__r.SVMXC__Start_Time__c',
                                                    'SVMXC__SM_Overhead_time__c','SVMXC__SM_Technician__c'};
                                                    
                    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SM_Scheduling_Event_Summary__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    
                    //Check for the jobs for which the utilization is already computed and filter them out.
                    String query = 'SELECT SVMXC__SM_Break_Minutes__c, SVMXC__SM_Drive_Time__c,SVMXC__SM_Event_Date__c,'
                            +'SVMXC__SM_Event_Duration__c,SVMXC__SM_Event_Type__c,SVMXC__SM_Job_Summary__c,SVMXC__SM_JobId__c,'
                            +'SVMXC__SM_JobId__r.SVMXC__SVMX_Process__c, SVMXC__SM_JobId__r.SVMXC__SVMX_Process__r.SVMXC__Name__c,' 
                            +'SVMXC__SM_JobId__r.SVMXC__Start_Time__c,'
                            +'SVMXC__SM_Overhead_time__c,SVMXC__SM_Technician__c FROM SVMXC__SM_Scheduling_Event_Summary__c'
                            +' WHERE SVMXC__SM_JobId__r.Name IN ' + formattedJobIds +' Order by SVMXC__SM_JobId__c,'
                            +'SVMXC__SM_Event_Date__c, SVMXC__SM_Technician__c';
                    
                    SPM_Scheduling_Technician_Utilization utilizationBatch = new SPM_Scheduling_Technician_Utilization(query);
                    utilizationBatch.setAuditLog(auditLog);
                    Database.executeBatch(utilizationBatch);
                    System.debug( LoggingLevel.DEBUG,'Technician Utilization batch operation initiated');
                } else {
                    auditLog.addMessage('Data is not sourced to SPM Tables from Scheduling engine for the passed in JobIds');
                }
            } else {
                auditLog.addMessage('Utilization already computed for the passed in JobIds');
            }
        }
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.computeUtilization() - exit' );
    }

    /**
     * Gets the latest run amongst the runs executed for different Optimax Processes.
     * 
     * @return - Latest JobId associated with the configured dispatch process.
     */
    public List<String> getLatestRun(){
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.getLatestRun() - enter' );
        List<String> jobsIdList = new List<String>();
        
        //Check for user access before quering the fields.
        List<String> queryFields = new List<String> {'Id','Name'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SVMX_Jobs__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
                
        List<SVMXC__SVMX_Jobs__c> jobList = 
            [SELECT Id, Name FROM SVMXC__SVMX_Jobs__c WHERE SVMXC__OptiMax_Message__c = 'Success' AND 
             SVMXC__SVMX_Process__r.SVMXC__Dispatch_Method__c = :SPM_Consts.OPTIMIZED_BATCH   
            AND SVMXC__SVMX_Process__r.SVMXC__Dispatch_Process_Status__c=: SPM_Consts.COMPLETE ORDER BY Id DESC limit 1] ;
            
         if(jobList != null && jobList.size() > 0){
            SVMXC__SVMX_Jobs__c  job = jobList.get(0);
            jobsIdList.add(job.Name);
        }

        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.getLatestRun() - exit' );
        return jobsIdList; 
    }
    
    /**
     * Method to compute the utilization for the latest run optimax job. Invoked when user clicks on 'Report Latest Run'.
     */
    public String reportLatestRun() {
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.reportLatestRun() - enter' );
        String reportLatestRunMsg;
        List<String> jobsIdList = getLatestRun();
        if(jobsIdList.size() > 0) {
            System.debug(LoggingLevel.DEBUG, 'Jobs found '+jobsIdList.get(0));
            computeUtilization(jobsIdList);
            reportLatestRunMsg = System.label.SPM001_TAG022;//'Technician Utilization triggered on the latest optimax job run';
        } else {
            System.debug(LoggingLevel.DEBUG, 'No Jobs found');
            reportLatestRunMsg = System.label.SPM001_TAG024; //'No Jobs found';
        }
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.reportLatestRun() - exit' );
        return reportLatestRunMsg;
    }
    
   /**
     * Method to compute the utilization for the passed in jobs. Invoked when user select jobs and clicks on 'Report Selected Runs'.
     * 
     * @param jobsIdList - list of job-ids
     */
    public void reportSelectedRuns(List<String> jobsIdList) {
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.reportSelectedRuns() - enter' );
        System.debug(LoggingLevel.DEBUG,'Calling compute utilization on the jobs list : '+jobsIdList.size());
        computeUtilization(jobsIdList);
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.reportSelectedRuns() - exit' );
    }
    
    
    /**
     * Method to purge the data for the latest optimax job run. Invoked when user clicks on 'Purge Latest Run'. 
     */
    public String purgeLatestRun() {
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.purgeLatestRun() - enter' );
        String purgeStatusMsg ;
        List<String> jobsIdList = getLatestRun();
        if(jobsIdList.size() > 0) {
            System.debug(LoggingLevel.DEBUG, 'Jobs - '+jobsIdList);
            System.debug(LoggingLevel.DEBUG, 'Calling purge on latest run');
            purgeData(jobsIdList);
            purgeStatusMsg = System.label.SPM001_TAG023; //'Purge triggered on the latest optimax job run';
        } else {
            System.debug(LoggingLevel.DEBUG, 'No Jobs found');
             purgeStatusMsg = System.label.SPM001_TAG024;//'No Jobs found';
        }
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.purgeLatestRun() - exit' );
        return purgeStatusMsg;
    }
    
    /**
     * Method to purge the data for the list of job runs. Invoked when user selects jobs 
     * and clicks on 'Purge Selected Runs'.
     * 
     * @param jobsIdList - list of job-ids
     */
    public void purgeSelectedRuns(List<String> jobsIdList) {
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.purgeSelectedRuns() - enter' );
        System.debug(LoggingLevel.DEBUG, 'Calling purge on  jobs : '+jobsIdList.size());
        purgeData(jobsIdList);
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.purgeSelectedRuns() - exit' );
    }
    
    
     /**
     * Saves the user entered String configuration to the SPM Details
     * record type object.
     * @param  optimaxConfigurationJson - configuration string 
     * @return                          - status message
     */
    public String saveConfiguration(String optimaxConfigurationJson) {
       
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.saveConfiguration() -enter' );
        String message ;
        Savepoint savePoint = Database.setSavepoint();
        try {
            
            //Check for user access before quering the fields.
            List<String> queryFields = new List<String> {'Id'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            List<SVMXC__ServiceMax_Processes__c> techUtilProcessList = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c =:SPM_Consts.SPM_OPTIMAX_RULE] ;
            
            if(techUtilProcessList == null|| techUtilProcessList.size() == 0) {
                System.debug(LoggingLevel.INFO,'Creating new process for computing the technician utilization');
                RecordType recordTypeForSchedulingOptimization = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name =:SPM_Consts.SPM_OPTIMAX_RULE]; 
                SVMXC__ServiceMax_Processes__c techUtilProcess = new SVMXC__ServiceMax_Processes__c();
                techUtilProcess.RecordTypeId = recordTypeForSchedulingOptimization.Id;
                techUtilProcess.SVMXC__Name__c = 'Schedule Optimization Technician Utilization';
                
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( techUtilProcess, COMM_SecurityUtils.Access.Createable ) ) {
                    insert techUtilProcess;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                System.debug(LoggingLevel.INFO,'Creating new configuration for computing the technician utilization');
                //System.debug(LoggingLevel.DEBUG, 'Found process '+techUtilProcess+' , Creating new config object');
                SVMXC__ServiceMax_Config_Data__c configuration = new SVMXC__ServiceMax_Config_Data__c();
                RecordType detailsRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name =:SPM_Consts.SPM_DETAILS]; 
                configuration.RecordTypeId = detailsRecordType.Id;
                configuration.SVMXC__Formula__c = optimaxConfigurationJson;
                configuration.SVMXC__Dispatch_Process__c = (Id)techUtilProcess.get('Id');
                System.debug(LoggingLevel.DEBUG, 'Saving new configuration object '+configuration);
                
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( configuration, COMM_SecurityUtils.Access.Createable ) ) {
                    insert configuration;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                //message = 'New config object created and linked to process';
                message = System.label.SPM001_TAG021;
                
            } else { //configuration already exist. load the configuration and update it.
                System.debug(LoggingLevel.INFO,'Updating the existing configuration');
                SVMXC__ServiceMax_Processes__c techUtilProcess = techUtilProcessList.get(0);
                //Check for user access before quering the fields.
                queryFields = new List<String> {'Id'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                SVMXC__ServiceMax_Config_Data__c configuration = [SELECT ID  FROM SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c =:SPM_Consts.SPM_DETAILS and SVMXC__Dispatch_Process__c = :techUtilProcess.Id] ;
                configuration.SVMXC__Formula__c = optimaxConfigurationJson;
                //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(configuration, COMM_SecurityUtils.Access.Updateable)) {
                    update configuration;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                }
        
                message = System.label.SPM001_TAG021; //'Config object updated';
            }
        } catch(Exception ex) {
            Database.rollback(savePoint);
            message=ex.getMessage();
            System.debug(LoggingLevel.ERROR,'Exception in saveConfiguration - '+ex.getMessage());
        }
       
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.saveConfiguration() -exit' );
        return message;
    }
    
    
  /**
     * Loads the configuration from SPM Details 
     * record type object]
     * @return - configuration string
     */
    public String loadConfiguration(){
        System.debug( LoggingLevel.DEBUG, ' SPM_Scheduling_Action.loadConfiguration() -enter' );
        String result = '';
        
        try {
            //Check for user access before quering the fields.
            List<String> queryFields = new List<String> {'Id','SVMXC__Name__c','SVMXC__Record_Type_Name__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            //SDL-SVMX-READ-FLS-ENFORCED
            SVMXC__ServiceMax_Processes__c optimaxProcess = [SELECT Id, SVMXC__Name__c, SVMXC__Record_Type_Name__c FROM SVMXC__ServiceMax_Processes__c 
                    WHERE SVMXC__Record_Type_Name__c =:SPM_Consts.SPM_OPTIMAX_RULE];
            System.debug(LoggingLevel.DEBUG,'Process Object - '+ optimaxProcess);
            
            
            //Check for user access before quering the fields.
            //queryFields = new List<String> {'SVMXC__Dispatch_Process__c, Id, SVMXC__Formula__c'};
            queryFields = new List<String> {'SVMXC__Dispatch_Process__r.SVMXC__Name__c', 'SVMXC__Dispatch_Process__c', 'Id', 'SVMXC__Formula__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            //SDL-SVMX-READ-FLS-ENFORCED
            SVMXC__ServiceMax_Config_Data__c configuration = [SELECT SVMXC__Dispatch_Process__r.SVMXC__Name__c, 
                                SVMXC__Dispatch_Process__c,Id,SVMXC__Formula__c FROM SVMXC__ServiceMax_Config_Data__c 
                                where SVMXC__Dispatch_Process__c = :optimaxProcess.Id and 
                                SVMXC__RecordType_Name__c =:SPM_Consts.SPM_DETAILS 
                                and SVMXC__Dispatch_Process__c = :optimaxProcess.Id]; 
            
            System.debug(LoggingLevel.DEBUG, 'configuration -  '+configuration);
            if(configuration == null) { // || configurationList.size() == 0) {
                System.debug(LoggingLevel.DEBUG,' Configuration does not exist');
                return result;
            }
            
            result = configuration.SVMXC__Formula__c;   
            
            System.debug(LoggingLevel.DEBUG,' Config object Value - ' + result);
            System.debug( LoggingLevel.DEBUG, ' SPM_Scheduling_Action.loadConfiguration() -exit' );
        } catch(Exception ex) {
            System.debug(LoggingLevel.ERROR,'Exception in load configuration - '+ex.getMessage());
        }
        return result;
    }   
    
    /**
     * Gets the list of dispatch process names 
     * @return -    dispatch process name list
     */
    public List<String> getDispatchProcessList(){
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.getDispatchProcessList() - enter' );

        List<String> results = new List<String>();
        results.add('All');
        
        try {
            
            //Check for user access before quering the fields.
            List<String> queryFields = new List<String> {'Id','SVMXC__Name__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            //SDL-SVMX-READ-FLS-ENFORCED
            List<SVMXC__ServiceMax_Processes__c> processList = [Select Id,Name,SVMXC__Name__c from 
                             SVMXC__ServiceMax_Processes__c where SVMXC__Dispatch_Method__c = : SPM_Consts.OPTIMIZED_BATCH and 
                             SVMXC__Dispatch_Process_Status__c = :SPM_Consts.COMPLETE];
            System.debug(LoggingLevel.DEBUG,'Dispatch processList size '+processList.size());
            Map<String, String> processDetailsMap;
            for(SVMXC__ServiceMax_Processes__c process : processList) {
               results.add(process.SVMXC__Name__c);
            }
            System.debug(LoggingLevel.DEBUG,'Dispatch Process List - '+results);
        }catch(Exception e){
          System.debug(LoggingLevel.ERROR,' Exception in fetching dispatch process '+e.getMessage());
        }
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.getDispatchProcessList() - exit' );

        return results;
    }
    
    /**
     * Gets the list of event types for the objects - Event 
     * and SVMXC__SVMX_Event__c 
     * @return -   event type  list
     */
    public List<String> getEventTypes(){
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.getEventTypePickListValues() - enter' );
    Set<String> pickListValues = new Set<String>();
    
        //fetch event types for SVMX Event object
        List<String> pickListSvmxEvent = SPM_Utilities.getInstance()
            .getPickListValues('SVMXC__SVMX_Event__c', 'SVMXC__Type__c');
        
        //fetch event types for SF Event object
        List<String> pickListEvent = SPM_Utilities.getInstance()
            .getPickListValues('Event', 'SVMXC__Type__c');
        
        pickListValues.addAll(pickListSvmxEvent);
        pickListValues.addAll(pickListEvent);
        pickListValues.add(SPM_Consts.EXTERNAL_WORK_ORDER_ACTIVITY);
        
        List<String> values = new List<String>(pickListValues);
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Action.getEventTypePickListValues() - exit' );
    return values;
    }
}