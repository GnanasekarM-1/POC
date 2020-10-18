global with sharing class PREV_Conditional_Engine_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
    global Set<String> setProcessIds = new Set<String>();
    Static final String CONDITION_BASED_TYPE = 'Condition Based';
    public Map<Id,SVMXC__ServiceMax_Processes__c> pmPlanProcessIdMap = new Map<Id,SVMXC__ServiceMax_Processes__c>();
    //public String strLogger;
    public Integer batchCount = 0;
    public List<SVMXC.PREV_Conditional_Engine_Utils.ScheduleLogger> scheduleLoggerList = new List<SVMXC.PREV_Conditional_Engine_Utils.ScheduleLogger>();
    //public Map<Id,String> processLoggerEmailMap = new  Map<Id,String>();
    public Map<Id,SVMXC__ServiceMax_Processes__c> processRecordMap = new Map<Id,SVMXC__ServiceMax_Processes__c>();
    public Map<Id,SVMXC__PM_Plan__c> pmPlanRecordMap = new Map<Id,SVMXC__PM_Plan__c>();
    
    
    global Iterable<sObject> start(Database.BatchableContext BC) {
        
        List<SVMXC__PM_Plan__c> qualifiedPMPlans = new List<SVMXC__PM_Plan__c>();
        List<SVMXC__ServiceMax_Processes__c> conditionBasedProcess = [Select Name,SVMXC__Name__c, SVMXC__Frequency__c, SVMXC__Parent_Object__c, SVMXC__Submodule__c, SVMXC__Target_Object_Name__c, 
                                                                        SVMXC__Process1__c, SVMXC__APL_Field_Name__c, SVMXC__Process2__c, SVMXC__Process3__c, SVMXC__Preferred_Tech_Enabled__c, 
                                                                        Id, SVMXC__Product_Match_Enabled__c, SVMXC__Module__c, SVMXC__Module__r.SVMXC__Parent_Object_Criteria__c, SVMXC__Number_of_Lookup_Records__c, SVMXC__Node_Parent__c, 
                                                                        SVMXC__Create_Work_Order__c, SVMXC__Assign_Work_Order_To__c, SVMXC__Assign_To_Dispatcher__c, SVMXC__Assign_To_Queue__c, 
                                                                        SVMXC__Assign_To_Service_Team__c, SVMXC__Assign_To_Technician__c, SVMXC__Include_Parent__c,SVMXC__Assign_Case_To__c,
                                                                        SVMXC__Case_Assign_To_User__c, SVMXC__Case_Assign_To_Queue__c, SVMXC__Process__c, SVMXC__Email_On_Success__c, 
                                                                        SVMXC__Email_On_Error__c, SVMXC__Capture_Log__c, SVMXC__SM_Do_Not_Create_New_WO__c, SVMXC__SM_Do_Not_Create_WO_Within__c From SVMXC__ServiceMax_Processes__c where Id =: setProcessIds AND 
                                                                        SVMXC__Active__c = true ORDER BY SVMXC__Module__c NULLS LAST];

        
        Set<Id> pmPlanIds = new Set<Id>();
        
        /*
            SVMXC__Coverage_Type__c, SVMXC__Location__c, SVMXC__Location__r.SVMXC__Country__c, SVMXC__Location__r.SVMXC__State__c, SVMXC__Location__r.SVMXC__City__c,' +
              + ' SVMXC__Location__r.SVMXC__Street__c, SVMXC__Location__r.SVMXC__Zip__c, SVMXC__Location__r.SVMXC__Latitude__c, SVMXC__Location__r.SVMXC__Longitude__c,'+ 
              + ' SVMXC__Service_Contract__r.SVMXC__Primary_Technician__c, SVMXC__Account__r.SVMXC__Preferred_Technician__c, SVMXC__End_Date__c, SVMXC__Service_Contract__c, SVMXC__Account__c,'+ 
              + ' SVMXC__SM_Adjustment_Type__c,SVMXC__SM_Adjustment_Activity_Date__c, SVMXC__SM_Adjustment_Unit__c, SVMXC__SM_Adjustment_Value__c,' +
                                  + ' SVMXC__SM_Activity_Date_To_Consider__c,SVMXC__SM_Adjustment_Max__c,SVMXC__SM_Adjustment_Min__c 
        */
        String queryString = 'Select Name, Id, OwnerId, Owner.isActive From SVMXC__PM_Plan__c where SVMXC__Status__c = \'Active\' AND' +
                                  + ' SVMXC__Start_Date__c != NULL AND SVMXC__End_Date__c != NULL AND SVMXC__Start_Date__c <= today AND SVMXC__End_Date__c >= today AND SVMXC__Schedule_Type__c = \'' + CONDITION_BASED_TYPE + '\'';


        for(SVMXC__ServiceMax_Processes__c conditionBasedRec : conditionBasedProcess){
            
            List<SVMXC__PM_Plan__c> tempPMPlans = new List<SVMXC__PM_Plan__c>();

            processRecordMap.put(conditionBasedRec.Id, conditionBasedRec);

            if(conditionBasedRec.SVMXC__Module__c != null){
        
                if(conditionBasedRec.SVMXC__Module__r.SVMXC__Parent_Object_Criteria__c != null){
                    queryString += ' AND ' + ' (' + conditionBasedRec.SVMXC__Module__r.SVMXC__Parent_Object_Criteria__c  + ' )';
                }
            }

            /*
                Not Querying the PM Plans again which are already queried. The order of the process execution is based on the query results 
                considering the process without the qualification criteria in the last. 
            */

            if(!pmPlanIds.isEmpty()){
                queryString += ' AND ' + ' Id NOT IN : pmPlanIds ';
            }   

            tempPMPlans = database.query(queryString); 

            for(SVMXC__PM_Plan__c pmPlan : tempPMPlans){
                pmPlanIds.add(pmPlan.Id);
                qualifiedPMPlans.add(pmPlan);
                pmPlanProcessIdMap.put(pmPlan.Id,conditionBasedRec);
            }           
        }                                                                       


        return qualifiedPMPlans;
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        ++batchCount;
        boolean isSuccess = true;
        Map<Id,SVMXC__ServiceMax_Processes__c> qualifiedPlanIdProcessMap  = new Map<Id,SVMXC__ServiceMax_Processes__c>();
        List<SVMXC.PREV_Conditional_Engine_Utils.ScheduleLogger> scheduleLogMap;
        String processLogger;
        
        try{        
        

            for(sObject sObjRec : scope){
                if(pmPlanProcessIdMap.containsKey(sObjRec.Id)){
                    SVMXC__ServiceMax_Processes__c pmProcess = pmPlanProcessIdMap.get(sObjRec.Id);
                    SVMXC__PM_Plan__c planRecord = (SVMXC__PM_Plan__c)sObjRec;
                    pmPlanRecordMap.put(sObjRec.Id, planRecord);
                    //strLogger = '\n ' + String.valueOfGmt(system.now()) + ' Preventive Maintenance Plan: '+ sObjRec.get('Name') ;
                    qualifiedPlanIdProcessMap.put(sObjRec.Id, pmProcess);       
                }
            }               

            System.debug(LoggingLevel.INFO, 'qualifiedPlanIdProcessMap : ' + qualifiedPlanIdProcessMap.size());

            if(!qualifiedPlanIdProcessMap.isEmpty()){
                scheduleLogMap = new PREV_Conditional_Engine_Utils().scheduleOutputProcessor(qualifiedPlanIdProcessMap);
            }
            
            if(!scheduleLogMap.isEmpty()){
                scheduleLoggerList.addAll(scheduleLogMap);
            }

        }

        catch(Exception ex){
            isSuccess = false;
            processLogger += '\n Exception: Type - '+ex.getTypeName();
            processLogger += '\n Message - ' + ex.getMessage();
            processLogger += '\n' + ex.getStackTraceString();
            system.debug(LoggingLevel.ERROR, 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString());
        }
        finally{

            if(!isSuccess){
                
                for(Id planId : qualifiedPlanIdProcessMap.keySet()){
                    SVMXC__ServiceMax_Processes__c processRec = qualifiedPlanIdProcessMap.get(planId);
                    SVMXC__PM_Plan__c pmPlan = pmPlanRecordMap.get(planId);
                    SVMXC.PREV_Conditional_Engine_Utils.ScheduleLogger scheduleLogRec = new SVMXC.PREV_Conditional_Engine_Utils.ScheduleLogger();
                    scheduleLogRec.planId = planId;
                    scheduleLogRec.processId = processRec.Id;
                    scheduleLogRec.status = 'Exception';
                    scheduleLogRec.strLogger = processLogger;
                    scheduleLogRec.planName = pmPlan.Name;
                    scheduleLogRec.ownerIdStr = pmPlan.Owner.isActive ? pmPlan.OwnerId : null ;
                    scheduleLoggerList.add(scheduleLogRec);
                }   
            }
            


        }

    }
    


    global void finish(Database.BatchableContext BC) {
        
      

        if(!scheduleLoggerList.isEmpty()){

            Map<Id, Map<Id, PMPlanWrapper>> processLogDetails = new Map<Id, Map<Id, PMPlanWrapper>>();
            
            for(SVMXC.PREV_Conditional_Engine_Utils.ScheduleLogger scheduleLogRec : scheduleLoggerList){
                integer woCount = 0;
                PMPlanWrapper planWrapRec = new PMPlanWrapper();

                Map<Id, PMPlanWrapper> planLogDetails = new Map<Id, PMPlanWrapper>();

                if(processLogDetails.containsKey(scheduleLogRec.processId)){
                    planLogDetails = processLogDetails.get(scheduleLogRec.processId);
                }

                if(planLogDetails.containsKey(scheduleLogRec.planId)){
                    planWrapRec = planLogDetails.get(scheduleLogRec.planId);
                    woCount = planWrapRec.woCount;
                }else{
                    if(pmPlanRecordMap.containsKey(scheduleLogRec.planId))
                        planWrapRec.planName = pmPlanRecordMap.get(scheduleLogRec.planId).Name;                 
                    
                    planWrapRec.strLogger = '\n' + System.label.PREV006_TAG004 +  ' ' +  planWrapRec.planName;
                    
                    
                    planWrapRec.ownerIdStr = scheduleLogRec.ownerIdStr;
                }

                if(scheduleLogRec.status != null && (!scheduleLogRec.status.equalsIgnoreCase('Exception') && !scheduleLogRec.status.equalsIgnoreCase('Failed'))){
                    planWrapRec.status = 'Success';
                    planWrapRec.strLogger += scheduleLogRec.strLogger;

                    if(scheduleLogRec.workOrderCreated != null && scheduleLogRec.workOrderCreated == true){
                        ++woCount;
                    }
                    
                }else{
                    planWrapRec.strLogger += scheduleLogRec.strLogger;
                    if(planWrapRec.status != null && planWrapRec.status == 'Success')
                        planWrapRec.status = 'Partial Success';
                    else    
                        planWrapRec.status = 'Failed';
                }
                planWrapRec.woCount = woCount;
                planLogDetails.put(scheduleLogRec.planId, planWrapRec);     
                processLogDetails.put(scheduleLogRec.processId, planLogDetails);    

            }

            List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
            List<Task> activityList = new List<Task>();
            Map<Id,String> planLoggerMap = new Map<Id,String> ();


            for(Id processId : processLogDetails.keySet()){
                
                Map<Id, PMPlanWrapper> planLogDetails = processLogDetails.get(processId);
                SVMXC__ServiceMax_Processes__c processRecord = processRecordMap.get(processId);
                boolean isAttachLog = processRecord.SVMXC__Capture_Log__c;
                String strSucessEmailId = processRecord.SVMXC__Email_On_Success__c;
                String strFailureEmailId = processRecord.SVMXC__Email_On_Error__c;

                String strSummary = System.Label.COMM001_TAG093 + '\n\n' + System.Label.PREV006_TAG001 + '\n' + System.Label.PREV006_TAG002 + ' ' + processRecord.SVMXC__Name__c  + '\n' + System.Label.PREV006_TAG003 + ' ' + planLogDetails.size();
                String strLogger = '';
                Set<String> setEmailIDs = new Set<String>();
                List<String> lstEmailIDs = new List<String>();

                
                String processStatus;

                for(Id planId : planLogDetails.keySet()){

                    PMPlanWrapper planWrapRec = planLogDetails.get(planId);
                    strSummary += '\n\n' + system.label.PREV006_TAG004 + ' ' + planWrapRec.planName;
                    strSummary +=  '\n' +system.label.PREV006_TAG005 + ' ' + planWrapRec.woCount + '\n' + system.label.COMM001_TAG091 +': '+ planWrapRec.status ;       
                    strLogger += planWrapRec.strLogger;

                    planLoggerMap.put(planId, strLogger);

                    if(isAttachLog){            
                        strSummary += '\n' + system.label.COMM001_TAG092;
                    }
                    
                    Task taskRecord;
                    if(planWrapRec.ownerIdStr != null){
                        taskRecord = new Task(OwnerId = planWrapRec.ownerIdStr, WhatId = planId, IsReminderSet = false, Description = 'Detailed log is generated and attached to this Task as file PM Completion Log', 
                                                  Status = system.Label.PREV003_TAG009, Priority = system.Label.PREV003_TAG010);
                    }

                    if(taskRecord != null){
                        if(planWrapRec.status == 'Success'){
                            if(processRecord.SVMXC__Product_Match_Enabled__c){
                                taskRecord.Subject = System.Label.PREV003_TAG007;
                                activityList.add(taskRecord);
                            }   
                        }else{ 
                            if(processRecord.SVMXC__Preferred_Tech_Enabled__c){
                                taskRecord.Subject = System.Label.PREV003_TAG008;
                                activityList.add(taskRecord);
                            }
                        }
                    }   

                    if(planWrapRec.status == 'Failed'){
                        if(String.isBlank(processStatus))
                            processStatus = 'Failed';
                        else if(processStatus == 'Success')
                            processStatus = 'Partial Success';  
                    }else if(planWrapRec.status == 'Success' && (String.isBlank(processStatus) || processStatus == 'Success')){
                        processStatus = 'Success';
                    }else if(planWrapRec.status == 'Partial Success'){  
                        processStatus = 'Partial Success';
                    }   
                }

                if(processStatus == 'Success'){
                    setEmailIDs.add(strSucessEmailId);
                }else{
                    if(processStatus == 'Failed'){
                        setEmailIDs.add(strFailureEmailId);
                    }else{
                        setEmailIDs.add(strFailureEmailId);
                        setEmailIDs.add(strSucessEmailId);
                    }   
                }

                 

                lstEmailIDs.addAll(setEmailIDs);

                Messaging.SingleEmailMessage objSingleEmailMsg = new Messaging.SingleEmailMessage();
                objSingleEmailMsg.setToAddresses(lstEmailIDs);
                objSingleEmailMsg.setSenderDisplayName(system.label.COMM001_TAG090);
                objSingleEmailMsg.setSubject(system.label.COMM001_TAG090 + ': ' + system.label.PREV006_TAG009);
                objSingleEmailMsg.setBccSender(false);
                objSingleEmailMsg.setUseSignature(false);

                if(isAttachLog && strLogger != NULL && strLogger.length() > 0){
                    strLogger = strLogger.replaceFirst('\n\n', '');
                    Messaging.EmailFileAttachment objFileAttachment = new Messaging.EmailFileAttachment();
                    objFileAttachment.setFileName('Attachment');
                    objFileAttachment.setBody(Blob.valueof(strLogger));
                    objSingleEmailMsg.setFileAttachments(new Messaging.EmailFileAttachment[] {objFileAttachment});
                }  
                
                objSingleEmailMsg.setPlainTextBody(strSummary);
                messageList.add(objSingleEmailMsg);
            }  
            try{

                Boolean isSVMXfileEnabled = COMM_FileHandlerUtilities.checkFileSetting(); //Added for BAC-2276
                
                List<Attachment> attachmentList = new List<Attachment>();
                List<ContentVersion> lstCVInstances = new List<ContentVersion>();
                Map<Id,Id> mapTaskandOwnerIds = new Map<Id,Id>();

                if(!activityList.isEmpty()){
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess( activityList, COMM_SecurityUtils.Access.Createable ) ) {
                        insert activityList;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    
                    for(Task taskRec : activityList){
                        if(planLoggerMap.containsKey(taskRec.WhatId)){
                            String logStr = planLoggerMap.get(taskRec.WhatId);
                            logStr = logStr.replaceFirst('\n\n', '');
                            if(isSVMXfileEnabled){ //Added for BAC-2276
                                ContentVersion cvTemp = new ContentVersion();
                                cvTemp.VersionData = Blob.valueof(logStr);
                                cvTemp.Title = 'PM Completion Log';
                                cvTemp.PathOnClient = 'PM Completion Log';
                                cvTemp.IsMajorVersion = false;
                                cvTemp.SVMXC__SM_Process_ID__c = taskRec.Id;
                                mapTaskandOwnerIds.put(taskRec.Id, taskRec.OwnerId);
                                lstCVInstances.add(cvTemp);
                            }else{
                                attachmentList.add(new Attachment(OwnerId = taskRec.OwnerId, ParentId = taskRec.Id, Name = 'PM Completion Log', Body = Blob.valueof(logStr), ContentType = 'text/plain'));
                            }
                        }
                    }
                    if(isSVMXfileEnabled && lstCVInstances.size()>0){ //Added for BAC-2276
                        List<Id> lstCVIds = COMM_FileHandlerUtilities.insertListOfContentVersion(lstCVInstances);
                    List<String> fieldSet = new List<String>();
                    fieldSet.add('SVMXC__SM_Process_ID__c');
                    fieldSet.add('ContentDocumentId');
                    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'ContentVersion', fieldSet, COMM_SecurityUtils.Access.Accessible ) ) {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    List<ContentVersion> lstCVDetails = Database.query('SELECT Id, SVMXC__SM_Process_ID__c, ContentDocumentId FROM ContentVersion WHERE Id IN: lstCVIds');
                    List<ContentDocumentLink> listContentDocumentLinkInstances = new List<ContentDocumentLink>();
                    for(ContentVersion cv: lstCVDetails){
                        ContentDocumentLink cdlTemp1 = new ContentDocumentLink();
                        
                        
                        listContentDocumentLinkInstances.add(COMM_FileHandlerUtilities.createContentDocumentLink(cv.SVMXC__SM_Process_ID__c,cv.ContentDocumentId));
                        if(mapTaskandOwnerIds.get(cv.SVMXC__SM_Process_ID__c) != null){
                            cdlTemp1.ContentDocumentId = cv.ContentDocumentId;
                            cdlTemp1.LinkedEntityId = mapTaskandOwnerIds.get(cv.SVMXC__SM_Process_ID__c);
                            cdlTemp1.ShareType = 'V';
                        }
                        listContentDocumentLinkInstances.add(cdlTemp1);
                        
                    }
                    List<Id> lstCDLids = COMM_FileHandlerUtilities.insertContentDocumentLink(listContentDocumentLinkInstances);
                    } // End for BAC-2276
                    if(!attachmentList.isEmpty()){
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( attachmentList, COMM_SecurityUtils.Access.Createable ) ) {
                            insert attachmentList;
                        } else {
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                        
                    }
                }
                Messaging.sendEmail(messageList);   
            }catch(Exception ex){
                system.debug(LoggingLevel.WARN, 'Email Exception: ' + ex.getMessage());
            }                 

        }

    }


    public class PMPlanWrapper{
        public integer woCount = 0;
        public string status;
        public string strLogger;
        public string planName;
        public string ownerIdStr;
        PMPlanWrapper(){
            
        }
    }
    
}