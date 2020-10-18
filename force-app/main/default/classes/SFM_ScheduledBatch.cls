/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The SFM_ScheduledBatch implements methods to execute the schedule services to perform specific task
 * Basic approach - a) Get the Scheduled Config data record to execute the service
 *                  b) Retrieve records for the object defined based on the qualification criteria. 
 *                  c) Pass the executed records to the service to perform specific task
 *                  d) On completion of service and batch, update the Scheduled Config data record and send an email to admin
 * 
 * * @author Anchal Sharma
 */
/*****************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************
 *              Anchal Sharma        17 June 2015        Created. 
 *              Soumyaranjan Pati   20th Dec 2018       BAC-2276-Salesforce file
 *****************************************************************************/

global with sharing class SFM_ScheduledBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    public DateTime dateTimeStart = null;
    
    /* Global variable defines the record which is passed from SCON_Scheduler. 
    The Config Data record hold all the Schedule services detail*/
    global SVMXC__ServiceMax_Config_Data__c scheduleDetailConfig = new SVMXC__ServiceMax_Config_Data__c();
    Map<String, Integer> mapCounterReadingCountPass =  new Map<String, Integer>();
    Map<String, Integer> mapCounterReadingCountFail =  new Map<String, Integer>();
    Map<String, String> mapSObjectIDName = new Map<String, String>();
    Integer mapKey = 0;
    Integer intListSize = 0;
    Boolean isServiceForChecklistReporting = false;
    Integer intCountOfAlreadyProcssedRecord = 0;
    Map<Integer, Map<String, List<String>>> mapIBCounterReading = new Map<Integer, Map<String,List<String>>>();
    
    
    /**
     * This method receives 1 Schedule Detail Record.
     * It queries the list of sObject records from the schedule Detail record passed. 
     * While querying for the record, we apply the Qualification Criteria Defined to filter the records further to be passed to configured Service 
     * 
     * @return List of SObject Records retrieved
    */
    global Iterable<sObject> start(Database.BatchableContext CounterEngine){
        scheduleDetailConfig.SVMXC__Previous_Execution_Started_On__c = Datetime.now();
        if(dateTimeStart == null)
            dateTimeStart = System.now(); 
        system.debug(scheduleDetailConfig);
        String queryObject='';
        string classname='';
        if(scheduleDetailConfig.Class_Name__c != null && scheduleDetailConfig.Class_Name__c!='')
        
            classname =scheduleDetailConfig.Class_Name__c.toUppercase();
        if(classname != null && classname!='' && classname.contains('SFM_TRANSPOSECHECKLISTDATA') &&(scheduleDetailConfig.Object_Name__c.equalsIgnoreCase('SVMXC__Checklist__c')||scheduleDetailConfig.Object_Name__c.equalsIgnoreCase('Checklist__c')))
            
            queryObject = 'SELECT Id, Name FROM ' + scheduleDetailConfig.Object_Name__c + ' WHERE ' + scheduleDetailConfig.Expression_Rule__r.Parent_Object_Criteria__c+ ' AND (SVMXC__SM_Sequence__c = null OR SVMXC__SM_Sequence__c= 1)' ; 
            //queryObject = 'SELECT Id, Name FROM ' + scheduleDetailConfig.Object_Name__c + ' WHERE ' + scheduleDetailConfig.Expression_Rule__r.Parent_Object_Criteria__c+ ' AND (SVMXC__SM_Sequence__c = null OR SVMXC__SM_Sequence__c= 1) and id = :strid'  ; 
        else
            queryObject = 'SELECT Id, Name FROM ' + scheduleDetailConfig.Object_Name__c + ' WHERE ' + scheduleDetailConfig.Expression_Rule__r.Parent_Object_Criteria__c; 
        //List <SObject> listSobjectRec = Database.query(queryObject); 
        Database.querylocator listSobjectRec= Database.getQueryLocator(queryObject);
        
        
        // In the start method, initailize the Record pass and fail count.
        String scheduleServiceID = scheduleDetailConfig.Id;
        mapCounterReadingCountPass.put(scheduleServiceID, 0);
        mapCounterReadingCountFail.put(scheduleServiceID, 0);
        
        
        System.debug(LoggingLevel.WARN, 'Start- Approximate amount of memory used in heap: ' + Limits.getHeapSize());
        System.debug(LoggingLevel.WARN, 'Start- Approximate amount of memory that can be used in heap: ' + Limits.getLimitHeapSize());
        
        return listSobjectRec;
    }
    
    
    /** 
     * This method execute method calls the service by passing the paramter in form of SVMXC.SFM_WrapperDef.SFM_Request and gets response in the form of 
     * SVMXC.SFM_WrapperDef.SFM_Response. 
     * 
     * @scope - List of Object Records retrieved after filtering 
    */
    global void execute(Database.BatchableContext CounterEngine, List<sObject> scope){
        mapKey = mapKey + 1;
        try{
            if(scope != null && scope.size() > 0){
                List<String> listRecordIds = new List<String>();
                intListSize += scope.size();
                for(SObject sobjRec : scope){ 
                    listRecordIds.add(sobjRec.Id); 
                    mapSObjectIDName.put((String)sobjRec.get('Id'), (String)sobjRec.get('Name'));
                }
                
                System.debug(LoggingLevel.WARN, 'Total Records for which service will run  :' + scope.size());  
                
                // The request contains the record IDs for which the service need to run
                List<SVMXC.SFM_WrapperDef.SFM_StringListMap> listSfmString = new List<SVMXC.SFM_WrapperDef.SFM_StringListMap>();
                SVMXC.SFM_WrapperDef.SFM_Request sfmReq = new SVMXC.SFM_WrapperDef.SFM_Request();
                SVMXC.SFM_WrapperDef.SFM_StringListMap sfmString = new SVMXC.SFM_WrapperDef.SFM_StringListMap('RECORDIDS', listRecordIds);
                listSfmString.add(sfmString);
                sfmReq.stringListMap = listSfmString;
                system.debug(LoggingLevel.WARN,'request'+sfmReq); 
                
                SFM_ScheduledBatchInterface sfmCounterReadingIns = SFM_ScheduledBatchUtils.getInstance('',scheduleDetailConfig.Class_Name__c);
                SVMXC.SFM_WrapperDef.SFM_Response sfmResponse = sfmCounterReadingIns.executeService(sfmReq);
                system.debug(LoggingLevel.WARN,'response'+sfmResponse); 
                
                System.debug(LoggingLevel.WARN, 'Execute- Total number of SOQL queries called: ' + Limits.getQueries());
                System.debug(LoggingLevel.WARN, 'Execute- Total number of SOQL queries that can be called: ' + Limits.getLimitQueries());
                
                System.debug(LoggingLevel.WARN, 'Execute- Total number of records that have been returned by issuing SOQL queries: ' + Limits.getQueryRows());
                System.debug(LoggingLevel.WARN, 'Execute- number of records that can be returned by issuing SOQL queries: ' + Limits.getLimitQueryRows());
                
                System.debug(LoggingLevel.WARN, 'Execute- Total number of DML statements called: ' + Limits.getDMLStatements());
                System.debug(LoggingLevel.WARN, 'Execute- Total number of DML statements that can be called: ' + Limits.getLimitDMLStatements());
                
                
                // Based on the response received from service, we calculate the pass and fail count for records.
                if(sfmResponse != null){
                    //Added for Checklist Reporting to change the email content
                    if(sfmResponse.stringMap != null && sfmResponse.stringMap.size() > 0){
                        if(sfmResponse.stringMap[0].key.equalsIgnoreCase('ServiceType') && sfmResponse.stringMap[0].value.equalsIgnoreCase('ChecklistReporting')){
                            isServiceForChecklistReporting = true;
                        }
                        if(sfmResponse.stringMap[1].key.equalsIgnoreCase('AlreadyProcessedChecklistRecord') && sfmResponse.stringMap[1].value != null){
                            intCountOfAlreadyProcssedRecord += Integer.valueOf(sfmResponse.stringMap[1].value);
                        }
                    }
                    
                    if(sfmResponse.success){
                        Integer intCountPass = mapCounterReadingCountPass.get((String)scheduleDetailConfig.ID)+1;
                        mapCounterReadingCountPass.put((String)scheduleDetailConfig.ID, intCountPass); 
                        Map<String, List<String>> mapIBCounterReadingRec = new Map<String, List<String>>();
                        for(SVMXC.SFM_WrapperDef.SFM_StringListMap IBCounterReading : sfmResponse.StringLstMap){
                            mapIBCounterReadingRec.put(IBCounterReading.key, IBCounterReading.valueList);
                        }
                        mapIBCounterReading.put(mapKey, mapIBCounterReadingRec);
                        
                    }
                    else{
                        Integer intCountFail = mapCounterReadingCountFail.get((String)scheduleDetailConfig.ID)+1;
                        mapCounterReadingCountFail.put((String)scheduleDetailConfig.ID, intCountFail);
                    }
                }
                
                System.debug(LoggingLevel.WARN, 'Execute- Approximate amount of memory used in heap: ' + Limits.getHeapSize());
                System.debug(LoggingLevel.WARN, 'Execute- Approximate amount of memory that can be used in heap: ' + Limits.getLimitHeapSize());
            }
        }
        catch (Exception ex){
            // Track the exceptions as well
            Integer intCountFail = mapCounterReadingCountFail.get((String)scheduleDetailConfig.ID)+1;
            mapCounterReadingCountFail.put((String)scheduleDetailConfig.ID, intCountFail);
            System.debug(logginglevel.WARN, 'on catch of execute method for sfm scheduled detail batch process : '+ex.getMessage());
        }
    }
    
    
    /**
     * This method is executed on completion of batch. At the end of service, we need to : 
     * a) Send email to Admin for success or failure
     * b) Update the Config data record with the Start and End time
     * c) Create Servicemax job record to track the service ran
    */
    global void finish(Database.BatchableContext BC){
        scheduleDetailConfig.SVMXC__Previous_Execution_Completed_On__c = Datetime.now();
        try{
            DateTime datetimeEnd = System.now();
            system.debug(LoggingLevel.WARN,'No. of records created for the Object Rec passed'+ mapIBCounterReading);
            //code for logging
            List<Messaging.SingleEmailMessage> lstEmail =new List<Messaging.SingleEmailMessage>();
            List<SVMXC__SVMX_Jobs__c> lstJobs = new List<SVMXC__SVMX_Jobs__c>();
            Map<String, SVMXC__SVMX_Jobs__c> mapHeaderProcessIdJob = new Map<String, SVMXC__SVMX_Jobs__c>();
            Map<String, String> mapHeaderProcessIdAttachment = new Map<String, String>();
            
            String strlogger = '\n'+getTAG002()+' '+scheduleDetailConfig.SVMXC__Dispatch_Process__r.SVMXC__Name__c;
            strlogger = strlogger+'\n'+getTAG003()+' '+scheduleDetailConfig.SVMXC__Dispatch_Process__r.SVMXC__ProcessID__c;
            String strLogPass = '';
            String strAttachmentlog = '';
            String serviceConfigDataID = scheduleDetailConfig.ID;
            
            if(mapCounterReadingCountPass.containsKey(serviceConfigDataID)){
                strLogPass = strLogPass+'\n\n'+scheduleDetailConfig.Class_Name__c+':';
                Integer intCountPass = mapCounterReadingCountPass.get(serviceConfigDataID);
                Integer intCountFail = mapCounterReadingCountFail.get(serviceConfigDataID);
                strLogPass = strLogPass+'\n\t'+getTAG004()+' '+intListSize;
                strLogPass = strLogPass+'\n\t'+getTAG005()+' '+intCountPass;
                strLogPass = strLogPass+'\n\t'+getTAG006()+' '+intCountFail;
            }
            
            Integer countProcessesRec= 0;
            for(Integer i : mapIBCounterReading.keyset()){
                Map<String, List<String>> mapCreateIBCounterREadingLogs = mapIBCounterReading.get(i);
                countProcessesRec = countProcessesRec + mapCreateIBCounterREadingLogs.size();
                for(String installedProductId :mapCreateIBCounterREadingLogs.keyset()){
                    strAttachmentlog = strAttachmentlog + mapSObjectIDName.get(installedProductId)+ +' : '+ mapCreateIBCounterREadingLogs.get(installedProductId).size() + ' '+getTAG022()+'\n';
                }
            }
                    
            strlogger = strlogger+strLogPass;
            
            String strEndlog = '';
            strEndlog = strEndlog+'\n\n'+getTAG019()+': '+dateTimeStart.format('MM/dd/yyyy HH:mm:ss', scheduleDetailConfig.SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Timezone__c)+' '+TimeZone.getTimeZone(scheduleDetailConfig.SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Timezone__c).getDisplayName()+' ('+scheduleDetailConfig.SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Timezone__c+')';
            strEndlog = strEndlog+'\n'+getTAG020()+': '+datetimeEnd.format('MM/dd/yyyy HH:mm:ss', scheduleDetailConfig.SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Timezone__c)+' '+TimeZone.getTimeZone(scheduleDetailConfig.SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Timezone__c).getDisplayName()+' ('+scheduleDetailConfig.SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Timezone__c+')';
            Decimal decCoutTime  = (Decimal.valueOf(((datetimeEnd.day()-dateTimeStart.day())*24*60*60)+((datetimeEnd.hour()-dateTimeStart.hour())*60*60)+((datetimeEnd.minute()-dateTimeStart.minute())*60)+(datetimeEnd.second()-dateTimeStart.second())))/60;
            Decimal decRounded = Math.round(decCoutTime * 100) / 100.0;
            strEndlog = strEndlog+'\n'+getTAG009()+': '+ decRounded.toPlainString();
            
            //Added for Checklist Reporting to change the email content
            if(isServiceForChecklistReporting){
                strAttachmentlog = strlogger+'\n=========================================================\n'+ getTAG023() +' '+intCountOfAlreadyProcssedRecord+'\n'+getTAG024()+' '+countProcessesRec+ '\n\n' + strAttachmentlog;
            }
            else{
                strAttachmentlog = strlogger+'\n=========================================================\n'+ getTAG021() +' ' +countProcessesRec +'\n\n' + strAttachmentlog;
            }
            
            strlogger = strlogger+strEndlog;
            strAttachmentlog = strAttachmentlog+'\n=========================================================\n'+strEndlog;
            
            String strFinaLlogger = getTAG001()+'\n';
            strFinaLlogger = strFinaLlogger+'\n'+getTAG014();
            strFinaLlogger = strFinaLlogger+strlogger;
            strFinaLlogger = strFinaLlogger+'\n\n'+getTAG010();
            String strNowDateMail =  datetimeEnd.format('MM/dd/yyyy', scheduleDetailConfig.SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Timezone__c);
            if(scheduleDetailConfig.SVMXC__Dispatch_Process__r.SVMXC__Assign_To_Dispatcher__c != null)
            {
                Messaging.EmailFileAttachment Attc = new Messaging.EmailFileAttachment();
                blob attachBlob = Blob.valueOf(strAttachmentlog);
                string flename= getTAG012()+'_'+strNowDateMail+'.txt';
                Attc.setFileName(flename);
                Attc.setBody(attachBlob);
                Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
                String subject = getTAG011()+' '+strNowDateMail;
                email.setSubject(subject);
                email.saveAsActivity = false;
                email.setTargetObjectId( scheduleDetailConfig.SVMXC__Dispatch_Process__r.SVMXC__Assign_To_Dispatcher__c );
                email.setPlainTextBody(strFinaLlogger);
                email.setFileAttachments(new Messaging.EmailFileAttachment[]{Attc});
                lstEmail.add(email);
            }
            
            if(scheduleDetailConfig.SVMXC__Dispatch_Process__r.SVMXC__Capture_Log__c){
                SVMXC__SVMX_Jobs__c objJob = new SVMXC__SVMX_Jobs__c();
                objJob.SVMXC__SVMX_Process__c = scheduleDetailConfig.SVMXC__Dispatch_Process__c;
                objJob.SVMXC__Type__c = 'Scheduled Services';
                objJob.SVMXC__Start_Time__c = dateTimeStart;
                objJob.SVMXC__End_Time__c = datetimeEnd;
                objJob.SVMXC__Message__c = strlogger;
                lstJobs.add(objJob);
            }
            
            if(lstJobs != null && lstJobs.size() > 0)
            {
                //insert lstJobs;
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstJobs, COMM_SecurityUtils.Access.Createable ) ) {
                    insert lstJobs;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
                Boolean isSVMXfileEnabled = COMM_FileHandlerUtilities.checkFileSetting(); //Added for BAC-2276
                List<ContentVersion> lstCVInstances = new List<ContentVersion>();
                if(isSVMXfileEnabled){
                    ContentVersion cvTemp = new ContentVersion();
                    cvTemp.VersionData = Blob.valueOf(strAttachmentlog);
                    cvTemp.Title = 'Scheduled Services.txt';
                    cvTemp.PathOnClient = 'Scheduled Services.txt';
                    cvTemp.IsMajorVersion = false;
                    cvTemp.SVMXC__SM_Process_ID__c = lstJobs[0].id;
                    lstCVInstances.add(cvTemp);
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
                        listContentDocumentLinkInstances.add(COMM_FileHandlerUtilities.createContentDocumentLink(cv.SVMXC__SM_Process_ID__c,cv.ContentDocumentId));
                        
                    }
                    List<Id> lstCDLids = COMM_FileHandlerUtilities.insertContentDocumentLink(listContentDocumentLinkInstances);
                }else{
                    Attachment objAttach = new Attachment();
                    blob attachBlob = Blob.valueOf(strAttachmentlog);
                    objAttach.Body = attachBlob;
                    objAttach.ParentId = lstJobs[0].id;
                    objAttach.Name = 'Scheduled Services.txt';
                    //insert objAttach;
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( objAttach, COMM_SecurityUtils.Access.Createable ) ) {
                        insert objAttach;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                }
                
            }
            
            if(lstEmail != null && lstEmail.size() > 0)
            {
                Messaging.SendEmailResult [] mainsend = Messaging.sendEmail(lstEmail);
                system.debug('check mail: '+mainsend);
            }
            
            
            scheduleDetailConfig.SVMXC__Previous_Execution_Status__c = 'Completed';
            
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( scheduleDetailConfig, COMM_SecurityUtils.Access.Updateable ) ) {
                update scheduleDetailConfig;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        }
        catch(Exception ex)
        {
            System.debug(logginglevel.WARN, 'on catch of finish method for sfm scheduled batch process : '+ex.getMessage());
        } 
    }
    
    public string getTAG001(){return System.label.COMM001_TAG093;}//'NOTE: THIS IS A SYSTEM GENERATED EMAIL. PLEASE DO NOT REPLY TO THIS MESSAGE.'
    public string getTAG002(){return System.label.CONF039_TAG017;}//'Schedule SFM Process Name:'
    public string getTAG003(){return System.label.CONF039_TAG018;}//'Scheduled SFM Process Id:'
    public string getTAG004(){return System.label.CONF039_TAG048;}//'Number of records to process:'
    public string getTAG005(){return System.label.CONF039_TAG049;}//'Successfully processed batches:'
    public string getTAG006(){return System.label.CONF039_TAG050;}//'Failed processed batches:'
    public string getTAG009(){return System.label.CONF039_TAG022;}//'Elapsed Time in minutes'
    public string getTAG010(){return System.label.COMM001_TAG092;}//'For more information, review the attached log.'
    public string getTAG011(){return System.label.CONF039_TAG023;}//'ServiceMax: SFM Scheduled Status on:'
    public string getTAG012(){return System.label.COMM001_TAG095;}//'Attachment'
    public string getTAG014(){return System.label.CONF039_TAG016;}//'Scheduled SFM Process has been completed with the following results:'
    public string getTAG019(){return System.label.CONF039_TAG038;}//'Scheduler Start Time'
    public string getTAG020(){return System.label.CONF039_TAG039;}//'Scheduler Finish Time'
    public string getTAG021(){return System.label.CONF039_TAG046;}//'Total number of records qualified for processing: '
    public string getTAG022(){return System.label.CONF039_TAG056;}//'Records Created'
    public string getTAG023(){return System.label.CONF039_TAG058;}//'Record(s) already transformed & available in target object:'
    public string getTAG024(){return System.label.CONF039_TAG059;}//'Net new record(s) eligible for processing:'
}