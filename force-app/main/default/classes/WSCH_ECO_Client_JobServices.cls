@RestResource(urlMapping='/scheduling/eco/job/*')
global with sharing class WSCH_ECO_Client_JobServices {
    public static final String SVMX_OBJECT_TYPE_JOB = 'SVMXC__SVMX_Jobs__c';
    public static final String SVMX_OBJECT_TYPE_WO = 'SVMXC__Service_Order__c';
    public static final String SVMX_OBJECT_TYPE_PROCESS = 'SVMXC__ServiceMax_Processes__c';
    public static final String RETURN_MESSAGE = 'Notification Success';
    public static final String NO_OP_ERROR_MESSAGE = 'Empty or Invalid operation type';
    public static final String REQUEST_SPLIT_CHAR = '_';
    
    public static final String SVMX_JOB_COLUMNS = 'SELECT SVMXC__Age__c,SVMXC__Batch_Job__c,SVMXC__End_Time__c,SVMXC__Initiated_By__c,SVMXC__Message__c,SVMXC__OptiMax_Message__c,SVMXC__Scheduled_Resources__c,SVMXC__Scheduled_Work_Orders__c,SVMXC__Sent_Events_Count__c,SVMXC__Sent_Resources__c,SVMXC__Sent_Work_Orders__c,SVMXC__Start_Time__c,SVMXC__Status__c,SVMXC__SVMX_Process__c,SVMXC__Territory__c,SVMXC__Total_Distance__c,SVMXC__Total_Driving_Time__c,SVMXC__Total_Route_Time__c,SVMXC__Type__c FROM SVMXC__SVMX_Jobs__c WHERE ';
    public static Map<String,String> sobjetFieldMapping = new Map<String,String>();
    
    static {
      sobjetFieldMapping.put('statusCode', 'SVMXC__Status__c');
      sobjetFieldMapping.put('jobStatus', 'SVMXC__OptiMax_Message__c');
      sobjetFieldMapping.put('message', 'SVMXC__Message__c');
    }
   
    @HttpPost
    global static String doPOST() {
       //WSCH_AuditLogger.rca('A notify request has been recieved from the server');
       Long startTime = Datetime.now().getTime();
       String returnMsg = NO_OP_ERROR_MESSAGE;
       RestRequest req = RestContext.request;
       // Extract Request
       WSCH_ECO_Client_Stubs.JobNotificationRequest_WP notifyRequest = extractNotifyRequest(req);
       WSCH_AuditLogger.debug('WSCH_ECO_Client_JobServices::doPOST():: Notify Request: ' + notifyRequest);
       if('NOTIFY_JOB'.equals(notifyRequest.operation)) {
        returnMsg = notifyJob(notifyRequest);
       }
       WSCH_AuditLogger.debug('WSCH_ECO_Client_JobServices :: doPost() :: Response Time (In Milli Seconds) :: '+ (Datetime.now().getTime() - startTime));
       WSCH_AuditLogger.setApexCPUTime((Integer) (Datetime.now().getTime() - startTime));
       WSCH_AuditLogger.finish();
       return returnMsg;
    }
    
    private static String notifyJob(WSCH_ECO_Client_Stubs.JobNotificationRequest_WP notifyRequest) {
       // Process each object 
       processSMAXSObjectData(notifyRequest);
       return RETURN_MESSAGE;
    }
    
    // Construct the request from the rest request
    private static  WSCH_ECO_Client_Stubs.JobNotificationRequest_WP extractNotifyRequest(RestRequest request){
        Blob data = request.requestBody;
        String requestStr = data.toString();
        WSCH_AuditLogger.debug('WSCH_ECO_Client_JobServices::extractNotifyRequest():: JSON Request: ' + requestStr);
        WSCH_ECO_Client_Stubs.JobNotificationRequest_WP notifyRequest = (WSCH_ECO_Client_Stubs.JobNotificationRequest_WP)JSON.deserialize(requestStr, WSCH_ECO_Client_Stubs.JobNotificationRequest_WP.class); 
        WSCH_AuditLogger.debug('WSCH_ECO_Client_JobServices::extractNotifyRequest():: After Deserailize: ' + notifyRequest);
        return notifyRequest;
    }
    
    // Identify the Object type in request and process the data   
    public static boolean processSMAXSObjectData(WSCH_ECO_Client_Stubs.JobNotificationRequest_WP jobRequest){
      WSCH_AuditLogger.debug('Begin WSCH_ECO_Client_JobServices::processSMAXSObjectData(): ' + jobRequest);
      if(null != jobRequest.jobInstanceGuid && jobRequest.jobInstanceGuid != '') {
            processBatchJob(jobRequest);
      } else {
            processECOJob(jobRequest);
      }
      
      WSCH_AuditLogger.debug('End WSCH_ECO_Client_JobServices::processSVMXJob()');
      return true;
    }
    
    private static void processBatchJob(WSCH_ECO_Client_Stubs.JobNotificationRequest_WP jobRequest){
        WSCH_AuditLogger.debug('Begin WSCH_ECO_Client_JobServices::processBatchJob(): ' + jobRequest);
        String query = SVMX_JOB_COLUMNS;
        String jobInstanceGuid = jobRequest.jobInstanceGuid;
        query += ' Id = \''+jobInstanceGuid+'\'';
        
        WSCH_AuditLogger.debug('Begin WSCH_ECO_Client_JobServices::query(): ' + query);
            
       List<SVMXC__SVMX_Jobs__c> jobs = Database.query(query);
       SVMXC__SVMX_Jobs__c job = jobs[0];
       WSCH_AuditLogger.debug('WSCH_ECO_Client_JobServices::processSMAXSObjectData(): Fetched job record Id ' + job.id);
       job.SVMXC__End_Time__c = Datetime.now();
       updateJob(jobRequest,job);
    }
    
    
    private static void processECOJob(WSCH_ECO_Client_Stubs.JobNotificationRequest_WP jobRequest){
        WSCH_AuditLogger.debug('Begin WSCH_ECO_Client_JobServices::processEcoJob(): ' + jobRequest);
        try{
             String query = SVMX_JOB_COLUMNS;
             query += ' SVMXC__SVMX_Process__c = \''+jobRequest.dispatchProcessGuid+'\'';
             query += ' AND ';
             query += ' SVMXC__Territory__c = \''+jobRequest.territoryGuid+'\'';
             query += ' AND ';
             query += ' SVMXC__Type__c = \'ECO\'';
             query += ' FOR UPDATE';        //added the FOR UPDATE clause to avoid race conditions while job record updates.
              
             WSCH_AuditLogger.debug('Begin WSCH_ECO_Client_JobServices::query(): ' + query);
                    
             List<SVMXC__SVMX_Jobs__c> jobs = Database.query(query);
              
            SVMXC__SVMX_Jobs__c job;
            String DPID = jobRequest.dispatchProcessGuid;
            String jobStatus;
            String jobmessage;
            for(WSCH_ECO_Client_Stubs.Params_WP jobDetail : jobRequest.jobDetails){
             if('jobStatus'.equals(jobDetail.name)) {
                jobStatus = jobDetail.value;
             }
             if('message'.equals(jobDetail.name)) {
                jobmessage = jobDetail.value;
             }
            }
            
            String dispatchProcessName= WSCH_AuditLogger.fetchDispatchProcessName(DPID);
            WSCH_AuditLogger.setLogContext(dispatchProcessName);
            //WSCH_AuditLogger.rca('The Notify request is for Dispatch Process ' + dispatchProcessName);
            //WSCH_AuditLogger.rca('The Notify Message from the Server  ' + jobmessage);
            
            if(jobs.size() == 0) {
                WSCH_AuditLogger.debug('WSCH_ECO_Client_JobServices::processSMAXSObjectData(): No job records exist for Dispatch Process ' + DPID);
                job = createSVMXJob(Id.valueOf(jobRequest.territoryGuid), Id.valueOf(DPID), jobStatus);
                WSCH_AuditLogger.debug('WSCH_ECO_Client_JobServices::processSMAXSObjectData(): Created job record with Id ' + job.id + ' for Dispatch Process ' + DPID);
                //WSCH_AuditLogger.rca('WSCH_ECO_Client_JobServices::processSMAXSObjectData(): Created job record with Id ' + job.id + ' for Dispatch Process ' + DPID);
            } else {
                job = jobs[0];
                //job.SVMXC__End_Time__c = Datetime.now();
                WSCH_AuditLogger.debug('WSCH_ECO_Client_JobServices::processSMAXSObjectData(): Fetched job record Id ' + job.id + ' for Dispatch Process ' + DPID);
                 //WSCH_AuditLogger.rca('WSCH_ECO_Client_JobServices::processSMAXSObjectData(): Fetched job record Id ' + job.id + ' for Dispatch Process ' + DPID);
            }
            
            if((jobs.size() == 0 && 'RUNNING'.equals(jobStatus)) || ('IDLE'.equals(job.SVMXC__OptiMax_Message__c) && 'RUNNING'.equals(jobStatus))) {
                if(!WSCH_ECO_CommonUtils.getIsRTOBatched())
                    createTechOptimizer(Id.valueOf(jobRequest.territoryGuid), Id.valueOf(DPID));
            }
            if('SUSPENDED'.equals(job.SVMXC__OptiMax_Message__c) && 'RUNNING'.equals(jobStatus)){
                //Need to clean up the non work order event (CHANGE_DELETE_EVENT) which was removed from the run. 
                deleteEventOptimizer(Id.valueOf(jobRequest.territoryGuid), Id.valueOf(DPID));
            }
            if('IDLE'.equals(jobStatus)) {
                deleteTechOptimizer(Id.valueOf(jobRequest.territoryGuid), Id.valueOf(DPID));
            }
            WSCH_AuditLogger.debug('WSCH_ECO_Client_JobServices::processSMAXSObjectData(): Before  Update: ' + job);
            updateJob(jobRequest,job);
            WSCH_AuditLogger.debug('The Job has been updated ');
        }catch(Exception e){
            WSCH_AuditLogger.error('WSCH_ECO_Client_JobServices:: Exception occured...'+e.getStackTraceString());
            WSCH_AuditLogger.rca('Exception occured while updating the job'+e.getStackTraceString());
            WSCH_AuditLogger.finish();  
        }
    }
    
    private static void updateJob(WSCH_ECO_Client_Stubs.JobNotificationRequest_WP jobRequest,SVMXC__SVMX_Jobs__c job){
        try {
            // Fetch all the field Names and Values from the request object to be updated
            String sObjectFieldName;
            for(WSCH_ECO_Client_Stubs.Params_WP jobDetail : jobRequest.jobDetails){
               sObjectFieldName = sobjetFieldMapping.get(jobDetail.name);
               if(sObjectFieldName != null) {
                  job.put(sObjectFieldName, jobDetail.value);
               }
            }
            WSCH_AuditLogger.debug('WSCH_ECO_Client_JobServices::processSVMXJob(): After Update: ' + job);
            //update job;
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(job, COMM_SecurityUtils.Access.Updateable)){      //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                update job;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
        } catch(Exception ex) {
            WSCH_AuditLogger.error('Exception caught:WSCH_ECO_Client_JobServices:updateJob() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
    
    
    private static SVMXC__SVMX_Jobs__c createSVMXJob(Id territoryId, Id dpId, String jobStatus) {
        List<SVMXC__SVMX_Jobs__c> listJobs = new List<SVMXC__SVMX_Jobs__c>();
        SVMXC__SVMX_Jobs__c job = null;
        WSCH_AuditLogger.debug('WSCH_ECO_Client_JobServices::createSVMXJob(): Creating job record for territory Id - ' + territoryId + ' | dispatch process Id ' + dpId + ' with status ' + jobStatus);
        try {        
            SVMXC__SVMX_Jobs__c objSVMXJob = new SVMXC__SVMX_Jobs__c();
            objSVMXJob.SVMXC__SVMX_Process__c = dpId;
            objSVMXJob.SVMXC__Territory__c = territoryId;
            objSVMXJob.SVMXC__OptiMax_Message__c = jobStatus;
            objSVMXJob.SVMXC__Start_Time__c = system.now();
            objSVMXJob.SVMXC__Initiated_By__c = Userinfo.getUserId();
            objSVMXJob.SVMXC__Type__c = 'ECO';
            listJobs.add(objSVMXJob);           
            WSCH_AuditLogger.debug('WSCH_ECO_Client_JobServices::createSVMXJob(): listJobs - ' + listJobs);
            //Database.upsert(listJobs);
            if(listJobs.size() > 0) {
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( listJobs, COMM_SecurityUtils.Access.Upsertable) ) {     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert listJobs; 
                }else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
            job = listJobs[0];
        } catch(Exception ex) {
            WSCH_AuditLogger.error('Exception caught:WSCH_ECO_Client_JobServices:createSVMXJob() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return job;
    }
    
    private static void createTechOptimizer(Id territoryId, Id dpId) {
        List<SVMXC__SVMX_Optimizer__c> lstOptimizer = new List<SVMXC__SVMX_Optimizer__c>();
        try {
            List<SVMXC__Service_Group_Members__c> lstTech = [select Id, Name from SVMXC__Service_Group_Members__c where SVMXC__Active__c = TRUE AND SVMXC__Service_Territory__c  =: territoryId AND ((SVMXC__Enable_Scheduling__c = TRUE AND SVMXC__Salesforce_User__c = NULL) OR (SVMXC__Salesforce_User__c != NULL AND SVMXC__Salesforce_User__r.IsActive = true) )];
            WSCH_AuditLogger.debug('WSCH_ECO_Client_JobServices::createTechOptimizer(): no of tech records - ' + lstTech.size());
            for(SVMXC__Service_Group_Members__c techObj : lstTech){
                SVMXC__SVMX_Optimizer__c optimizer = new SVMXC__SVMX_Optimizer__c();
                optimizer.SVMXC__WhatType__c = 'TECHNICIAN';
                optimizer.SVMXC__WhatId__c = techObj.Id + '_' + techObj.Name;
                optimizer.SVMXC__Optimizer_Connection_ID__c = dpId + '_' + territoryId;
                optimizer.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CREATE_TECH';
                optimizer.SVMXC__Optimizer_Status__c = 'OPT_COMPLETED';
                optimizer.SVMXC__Optimizer_Error_Text__c = 'Technician added through initJob call';
                lstOptimizer.add(optimizer);
            }               
            //Database.upsert(lstOptimizer);
            
            if(lstOptimizer.size() > 0) {
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstOptimizer, COMM_SecurityUtils.Access.Upsertable) ) {     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert lstOptimizer; 
                }else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
        } catch(Exception ex) {
            WSCH_AuditLogger.error('Exception caught:WSCH_ECO_Client_JobServices:createTechOptimizer() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }
    
    private static void deleteTechOptimizer(Id territoryId, Id dpId) {
        List<SVMXC__SVMX_Optimizer__c> lstOptimizer = new List<SVMXC__SVMX_Optimizer__c>();
        String query = 'Select Id from SVMXC__SVMX_Optimizer__c where SVMXC__Optimizer_Connection_ID__c LIKE \'%' + dpId + '_' + territoryId + '%\'';
        try {
            WSCH_AuditLogger.debug('WSCH_ECO_Client_JobServices::deleteTechOptimizer(): Fetch Optimizer Transaction records query: ' + query);
            List<SVMXC__SVMX_Optimizer__c> optTranObjs = Database.query(query);
            if(optTranObjs.size() == 0) {
                WSCH_AuditLogger.debug('WSCH_ECO_Client_JobServices::deleteTechOptimizer(): No Optimizer Transaction records');
            } else {
                WSCH_AuditLogger.debug('WSCH_ECO_Client_JobServices::deleteTechOptimizer(): Deleting ' + optTranObjs.size() + ' Optimizer Transaction records');
                //delete optTranObjs;
                if(optTranObjs != null && optTranObjs.size() > 0){
                    if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SVMX_Optimizer__c')){     //SDL-SVMX-DELETE-FLS-ENFORCED
                        delete optTranObjs;
                    }
                    else{
                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                }
            }
        } catch(Exception ex) {
            WSCH_AuditLogger.error('Exception caught:WSCH_ECO_Client_JobServices:deleteTechOptimizer() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }

    private static void deleteEventOptimizer(Id territoryId, Id dpId) {
        List<SVMXC__SVMX_Optimizer__c> lstOptimizer = new List<SVMXC__SVMX_Optimizer__c>();
        String query = 'Select Id from SVMXC__SVMX_Optimizer__c where SVMXC__Optimizer_Change_Token__c = \'CHANGE_DELETE_EVENT\' AND SVMXC__Optimizer_Status__c = \'OPT_COMPLETED\' AND SVMXC__Optimizer_Connection_ID__c LIKE \'%' + dpId + '_' + territoryId + '%\'';
        try {
            WSCH_AuditLogger.debug('WSCH_ECO_Client_JobServices::deleteEventOptimizer(): Fetch Optimizer Transaction records query: ' + query);
            List<SVMXC__SVMX_Optimizer__c> optTranObjs = Database.query(query);
            if(optTranObjs.size() == 0) {
                WSCH_AuditLogger.debug('WSCH_ECO_Client_JobServices::deleteEventOptimizer(): No Optimizer Transaction records');
            } else {
                WSCH_AuditLogger.debug('WSCH_ECO_Client_JobServices::deleteEventOptimizer(): Deleting ' + optTranObjs.size() + ' Optimizer Transaction records');
                //delete optTranObjs;
                if(optTranObjs != null && optTranObjs.size() > 0){
                    if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SVMX_Optimizer__c')){     //SDL-SVMX-DELETE-FLS-ENFORCED
                        delete optTranObjs;
                    }
                    else{
                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                }
            }
        } catch(Exception ex) {
            WSCH_AuditLogger.error('Exception caught:WSCH_ECO_Client_JobServices:deleteEventOptimizer() ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
    }    
}