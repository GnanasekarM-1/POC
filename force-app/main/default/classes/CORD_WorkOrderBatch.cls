/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class is used to create work order and work detail records for fco change order
 *
 * @version 20.2
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Arpit Sethi      25 May 2020     Created.
 *****************************************************************************************************/
global with sharing class CORD_WorkOrderBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    global String fcoSfId;
    global List<SVMXC__SM_Change_Order_Parts__c> changeOrderPartsList;
    global SVMXC__SM_Change_Order_Log__c changeOrderLog;
    global SVMXC__SM_Change_Order__c changeOrder;
    global SFM_ApplyMapping applyMapping = new SFM_ApplyMapping();
    global Map<String,Sobject> SourceRecIdTargetObjMap = new map<String,Sobject> (); //#notInUse
    global Map<String, Schema.SObjectType> allObjmap  = new Map<String, Schema.SObjectType>();
    global String installedProdMappingProcessId;
    global String changeOrderMappingProcessId;
    global Map<String, String> failedFcoLineErrorMap = new Map<String, String> (); //#notInUse
    global Map<String, SVMXC__SM_Change_Order_Line__c> successfulFCOLineMap = new Map<String, SVMXC__SM_Change_Order_Line__c> (); // #notInUse
    global String UsageConsumptionRTId;
    global Map<String, sObject> SourceRecIdTargetObjCOMap = new Map<String, sObject> ();
    global SVMXC__Service_Order__c changeOrderMappingWO = new SVMXC__Service_Order__c();
    public static final String LINE_TYPE_PARTS = 'Parts';
    public static final String ORDER_TYPE_DEPOT_REPAIR = 'Depot Repair';
    global Map<Integer, Map<String, String>> failedRecordsWithBatchNoMap = new Map<Integer, Map<String, String>> ();
    global Map<Integer, List<String>> allRecordsInFailedBatchMap = new Map<Integer, List<String>> (); //notInUse
    global Map<Integer, Integer> recordCountInBatchMap = new Map<Integer, Integer> ();

    global Integer failedBatchCount = 0;
    global Integer totalNoOfBatches = 0;
    public Integer totalNoOfRecords = 0;
    public Integer totalFailedRecords = 0;
    public static final String NEW_LINE  = '\n';
    public static final String SECTION_SEPARATOR = '----------------------------------------------';
    public static final Integer MAX_LOG_LENGTH = 131072;
    public List<String> defaultFieldList = new List<String> {'SVMXC__Component__c','SVMXC__Product__c','SVMXC__Site__c','SVMXC__Order_Type__c'};
    public List<String> overridableFields = new List<String> ();
    public String componentId = 'PLACEHOLDER_VALUE_COMPONENT';
    public String productId = 'PLACEHOLDER_VALUE_PRODUCT';
    public String siteId = 'PLACEHOLDER_VALUE_SITE';
    public String orderType = 'PLACEHOLDER_VALUE_ORDER_TYPE';
    public static final String FIELD_MAPPING_RT = 'Field Mapping';
    public static Boolean isFailedFromTestClass = false;
    public static String testClassErrorMsg = 'dummyMsg';
    public static final String SYSTEM_ERROR_PREFIX =  'First error: SVMXDEV:'; //#toDo change it to ' First error: SVMXC:' in base org

    /**
     * Parameterized constructor
    */
     global CORD_WorkOrderBatch(final String fcoSfId, final String installedProdMappingProcessId, final String changeOrderMappingProcessId)
    {
        this.fcoSfId = fcoSfId;
        allObjmap.put('SVMXC__Installed_Product__c', Schema.SVMXC__Installed_Product__c.getSObjectType());
        allObjmap.put('SVMXC__Service_Order__c', Schema.SVMXC__Service_Order__c.getSObjectType());
        allObjmap.put('SVMXC__SM_Change_Order__c', Schema.SVMXC__SM_Change_Order__c.getSObjectType());
        this.installedProdMappingProcessId = installedProdMappingProcessId;
        this.changeOrderMappingProcessId = changeOrderMappingProcessId;
        UsageConsumptionRTId = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__Service_Order_Line__c', 'UsageConsumption');
      
        // apply mapping for CO TO WO
        if(String.isNotBlank(changeOrderMappingProcessId)){
            SourceRecIdTargetObjCOMap.put(fcoSfId, new SVMXC__Service_Order__c(SVMXC__SM_Is_Change_Order__c=true));
            Map<String, sObject> resultCOMappingMap = applyMapping.getApplyMappingCore(changeOrderMappingProcessId, SourceRecIdTargetObjCOMap, false, allObjmap); //#TODO DoPopulate owener true or false?
            if(!resultCOMappingMap.isEmpty() && resultCOMappingMap.containsKey(fcoSfId)){

                changeOrderMappingWO = (SVMXC__Service_Order__c) resultCOMappingMap.get(fcoSfId);
                List<SVMXC__ServiceMax_Config_Data__c> fieldMapping = [SELECT Id, SVMXC__Target_Field_Name__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__MapID__c =: changeOrderMappingProcessId AND recordtype.name =:FIELD_MAPPING_RT AND SVMXC__Target_Field_Name__c IN : defaultFieldList];
               
                for(SVMXC__ServiceMax_Config_Data__c configData : fieldMapping){
                    overridableFields.add(configData.SVMXC__Target_Field_Name__c);
                }
                Map<String, Object> fieldsToValueMap = changeOrderMappingWO.getPopulatedFieldsAsMap();
                if(overridableFields.contains('SVMXC__Component__c')){
                    componentId = fieldsToValueMap.containsKey('SVMXC__Component__c') ? String.valueOf(fieldsToValueMap.get('SVMXC__Component__c')) : NULL;
                }
                if(overridableFields.contains('SVMXC__Product__c')){
                    productId = fieldsToValueMap.containsKey('SVMXC__Product__c') ? String.valueOf(fieldsToValueMap.get('SVMXC__Product__c')) : NULL;
                }
                if(overridableFields.contains('SVMXC__Site__c')){
                    siteId = fieldsToValueMap.containsKey('SVMXC__Site__c') ? String.valueOf(fieldsToValueMap.get('SVMXC__Site__c')) : NULL;
                }
                if(overridableFields.contains('SVMXC__Order_Type__c')){
                    orderType = fieldsToValueMap.containsKey('SVMXC__Order_Type__c') ? String.valueOf(fieldsToValueMap.get('SVMXC__Order_Type__c')) : NULL;
                }
            }
        }
    }
    

     /** Created By: Arpit
     * This method is used to collect fco lines to be converted into work order
     * @parameter Database.BatchableContext BC
     * @return List<sObject>
     */
    global List<sObject> start(Database.BatchableContext BC)
    {
        System.debug( LoggingLevel.INFO, 'start() - enter' );

        try{
            List<SVMXC__SM_Change_Order__c> changeOrderList = [SELECT Id, SVMXC__SM_Title__c, Owner.Email, SVMXC__SM_CORD_Config__r.SVMXC__SM_Email__c, SVMXC__SM_Notify_CORD_Owner__c, (SELECT SVMXC__SM_Product__c, SVMXC__SM_Quantity__c FROM SM_Change_Order_Parts__r),
                                                                            (SELECT SVMXC__SM_Line_Status__c, SVMXC__SM_Change_Order_Log__c, SVMXC__SM_Installed_Product__c, SVMXC__SM_Installed_Product__r.SVMXC__Product__c, SVMXC__SM_Installed_Product__r.SVMXC__Site__c, SVMXC__SM_Batch_Lot2__c, SVMXC__SM_Batch_Lot2__r.SVMXC__SM_Product__c, SVMXC__SM_Stocked_Serial__c, SVMXC__SM_Stocked_Serial__r.SVMXC__Product__c, SVMXC__SM_Stocked_Serial__r.SVMXC__Product_Stock__r.SVMXC__Location__c FROM Change_Order_Lines__r 
                                                                                WHERE SVMXC__SM_Line_Status__c =: CORD_ConsoleImpl.FCO_LINE_STATUS_DRAFT 
                                                                                    AND SVMXC__SM_Generate_WORD__c = TRUE 
                                                                                        AND SVMXC__SM_Work_Order__c = NULL
                                                                                            AND (SVMXC__SM_Installed_Product__c != NULL OR SVMXC__SM_Batch_Lot2__c != NULL OR SVMXC__SM_Stocked_Serial__c != NULL)
                                                                            ) 
                                                                FROM SVMXC__SM_Change_Order__c WHERE Id =: fcoSfId];
            List<SVMXC__SM_Change_Order_Log__c> changeOrderLogs = [SELECT Id, SVMXC__SM_Batch_Id__c FROM SVMXC__SM_Change_Order_Log__c WHERE SVMXC__SM_Batch_Id__c =: BC.getJobId() LIMIT 1];
            
            if(!changeOrderLogs.isEmpty()){
                changeOrderLog = changeOrderLogs[0];
                changeOrderLog.SVMXC__SM_Started_On__c = DateTime.now();
                update changeOrderLog;
            }

            if(!changeOrderList.isEmpty()){
                changeOrder = changeOrderList[0];
                changeOrderPartsList = changeOrder.SM_Change_Order_Parts__r;
            }

        }
        catch(Exception e){ //#TODO should be part of capturing log details and send email
            System.debug('Error==>'+ e.getMessage());
            System.debug( LoggingLevel.ERROR + ' start method Failed;  Error=' + e.getStackTraceString() );
        }

        totalNoOfRecords = (changeOrder.Change_Order_Lines__r).size();
        return changeOrder.Change_Order_Lines__r;
    }
    
    
    /** 
     * This method execute method calls the service by passing the paramter in form of SVMXC.SFM_WrapperDef.SFM_Request and gets response in the form of 
     * SVMXC.SFM_WrapperDef.SFM_Response. 
     * 
     * @scope - List of Object Records retrieved after filtering 
    */
    global void execute(Database.BatchableContext bc, List<sObject> scope){

        System.debug( LoggingLevel.INFO, 'execute() - enter' );

        totalNoOfBatches += 1;
        Savepoint sp = Database.setSavepoint(); // set the save point, so that batch can be rolled back

        try{
            List<SVMXC__SM_Change_Order_Line__c>  changeOrderLines  = (List<SVMXC__SM_Change_Order_Line__c>)(scope);
            List<SVMXC__Service_Order_Line__c> workDetailsList = new List<SVMXC__Service_Order_Line__c> ();
            Map<String, sObject> SourceRecIdTargetObjIBMap = new Map<String, sObject> ();
            Map<String, sObject> resultIBMappingMap = new Map<String, sObject> ();
            Map<String, sObject> resultBatchLotMap = new Map<String, sObject> ();
            Map<String, String> failedLineErrorMap = new Map<String, String> ();
            Map<String, SVMXC__SM_Change_Order_Line__c> woTofcoLineMap = new Map<String, SVMXC__SM_Change_Order_Line__c> (); // used to map wo to corresonding change order line

            List<String> changeOrderLinesIdList = new List<String> (); // used to store change order lines id if any record in batch gets failed, we will give ids of fco line in log details so that admin can be aware of that
            for(SVMXC__SM_Change_Order_Line__c changeOrderLine : changeOrderLines){
                changeOrderLine.SVMXC__SM_Change_Order_Log__c = changeOrderLog.Id;
                changeOrderLinesIdList.add(changeOrderLine.Id);
                SVMXC__Service_Order__c workOrder = changeOrderMappingWO.clone(false, true, false, false);
                
                if(changeOrderLine.SVMXC__SM_Installed_Product__c != NULL){
                        workOrder.SVMXC__Component__c = !'PLACEHOLDER_VALUE_COMPONENT'.equalsIgnoreCase(componentId) ? componentId : changeOrderLine.SVMXC__SM_Installed_Product__c;
                        workOrder.SVMXC__Product__c = !'PLACEHOLDER_VALUE_PRODUCT'.equalsIgnoreCase(productId) ? productId : changeOrderLine.SVMXC__SM_Installed_Product__r.SVMXC__Product__c;
                        workOrder.SVMXC__Site__c =  !'PLACEHOLDER_VALUE_SITE'.equalsIgnoreCase(siteId) ? siteId : changeOrderLine.SVMXC__SM_Installed_Product__r.SVMXC__Site__c;
                        SourceRecIdTargetObjIBMap.put(changeOrderLine.SVMXC__SM_Installed_Product__c, workOrder);
                        resultIBMappingMap.put(changeOrderLine.SVMXC__SM_Installed_Product__c, workOrder);
                }
                else if(changeOrderLine.SVMXC__SM_Stocked_Serial__c != NULL){
                        workOrder.SVMXC__Product__c = !'PLACEHOLDER_VALUE_PRODUCT'.equalsIgnoreCase(productId) ? productId : changeOrderLine.SVMXC__SM_Stocked_Serial__r.SVMXC__Product__c;
                        workOrder.SVMXC__Site__c = !'PLACEHOLDER_VALUE_SITE'.equalsIgnoreCase(siteId) ? siteId : changeOrderLine.SVMXC__SM_Stocked_Serial__r.SVMXC__Product_Stock__r.SVMXC__Location__c;
                        workOrder.SVMXC__Order_Type__c = !'PLACEHOLDER_VALUE_ORDER_TYPE'.equalsIgnoreCase(orderType) ? orderType : ORDER_TYPE_DEPOT_REPAIR;
                        resultBatchLotMap.put(changeOrderLine.SVMXC__SM_Stocked_Serial__c, workOrder);
                }
                else if(changeOrderLine.SVMXC__SM_Batch_Lot2__c != NULL){
                        workOrder.SVMXC__Product__c = !'PLACEHOLDER_VALUE_PRODUCT'.equalsIgnoreCase(productId) ? productId : changeOrderLine.SVMXC__SM_Batch_Lot2__r.SVMXC__SM_Product__c;
                        workOrder.SVMXC__Order_Type__c = !'PLACEHOLDER_VALUE_ORDER_TYPE'.equalsIgnoreCase(orderType) ? orderType : ORDER_TYPE_DEPOT_REPAIR;
                        resultBatchLotMap.put(changeOrderLine.SVMXC__SM_Batch_Lot2__c, workOrder);
                    }
            }

            // apply mapping for IB TO WO
            if(String.isNotBlank(installedProdMappingProcessId)){
              resultIBMappingMap = applyMapping.getApplyMappingCore(installedProdMappingProcessId, SourceRecIdTargetObjIBMap, false, allObjmap); //#TODO DoPopulate owener true or false?
            }
            resultIBMappingMap.putAll(resultBatchLotMap);
            SourceRecIdTargetObjIBMap.clear(); //#cleanMemory
            resultBatchLotMap.clear(); //#cleanMemory
           
            // explicity setting it again to true since fco header mapping / ib mapping can set it as false and we could loose the information to know whether this WO was created from Change Order Process
            for(sObject record : resultIBMappingMap.values()){
                SVMXC__Service_Order__c workOrderRecord = (SVMXC__Service_Order__c) record;
                workOrderRecord.SVMXC__SM_Is_Change_Order__c = true;
            }
            
            //Insert Work Orders  and make list of work detail records
            List<Database.SaveResult> workOrderSaveResult = ! resultIBMappingMap.isEmpty() ? Database.insert(resultIBMappingMap.values(), false) : new List<Database.SaveResult> ();
            Integer count = 0;
           
            for (Database.SaveResult sr : workOrderSaveResult) {
                if (sr.isSuccess() || isFailedFromTestClass) {
                    workDetailsList.addAll(getWorkDetailsList(sr.getId())); // add work details in a list 
                    woTofcoLineMap.put(sr.getId(),changeOrderLines[count]); // keep the track of work order and its fcoline, would need to update WO on change order line
                }
                else{
                    String errorMsg = sr.getErrors()[0].getMessage();
                    failedLineErrorMap.put(changeOrderLines[count].Id, errorMsg);
                }
                count++;
            }
            workOrderSaveResult.clear(); // #clearMemory
            resultIBMappingMap.clear();

            // Insert work detail records
            List<Database.SaveResult> workDetailsListSaveResult = ! workDetailsList.isEmpty() ? Database.insert(workDetailsList, false) : new List<Database.SaveResult> ();
            Integer workDetailCounter = 0;
            for (Database.SaveResult sr : workDetailsListSaveResult) {
                if (!sr.isSuccess() || isFailedFromTestClass) {
                    String errorMsg = !isFailedFromTestClass ? sr.getErrors()[0].getMessage() : testClassErrorMsg;
                    String workOrderId = workDetailsList[workDetailCounter].SVMXC__Service_Order__c;
                    String fcoLineId = woTofcoLineMap.get(workOrderId).Id;
                    if(failedLineErrorMap.containsKey(fcoLineId)){
                        String existingErrorOnFcoLine = failedLineErrorMap.get(fcoLineId);
                        failedLineErrorMap.put(fcoLineId, existingErrorOnFcoLine + ', ' + sr.getErrors()[0].getMessage());
                    }
                    else{
                        failedLineErrorMap.put(fcoLineId, sr.getErrors()[0].getMessage());
                    }
                    woTofcoLineMap.remove(workOrderId); // remove work orders whose work details failed to insert
                }
                workDetailCounter++;
            }
            workDetailsListSaveResult.clear(); // #clearMemory
            
            if(!failedLineErrorMap.isEmpty() || isFailedFromTestClass){
                failedBatchCount++;
                failedRecordsWithBatchNoMap.put(failedBatchCount, failedLineErrorMap);
                recordCountInBatchMap.put(failedBatchCount, changeOrderLinesIdList.size());
                Database.rollback(sp);
                update changeOrderLines;
            }
            else{
                List<SVMXC__SM_Change_Order_Line__c> changeOrderLineList = new List<SVMXC__SM_Change_Order_Line__c> ();
                for(String workOrderId : woTofcoLineMap.keySet()){
                    SVMXC__SM_Change_Order_Line__c changeOrderLine = woTofcoLineMap.get(workOrderId);
                    changeOrderLine.SVMXC__SM_Work_Order__c = workOrderId;
                    changeOrderLine.SVMXC__SM_Line_Status__c = CORD_ConsoleImpl.FCO_LINE_STATUS_WO_GEN;
                    changeOrderLineList.add(changeOrderLine);
                }
                woTofcoLineMap.clear(); // #clearMemory
                if(!changeOrderLineList.isEmpty()){
                    Integer lineCounter = 0;
                    for (Database.SaveResult sr : Database.update(changeOrderLineList, false)) {
                        if (!sr.isSuccess() || isFailedFromTestClass) {
                            String errorMsg = !isFailedFromTestClass ? sr.getErrors()[0].getMessage() : testClassErrorMsg;
                            failedLineErrorMap.put(changeOrderLines[lineCounter].Id, errorMsg);
                            System.debug('work order could not generated for@@'+changeOrderLines[lineCounter]);
                        }
                        lineCounter++;
                    }
                    if(!failedLineErrorMap.isEmpty()){
                        Database.rollback(sp);
                        update changeOrderLines;
                    }
                }
            }        
        }
        catch (Exception e){
            System.debug('Error==>'+ e.getMessage());
            System.debug( LoggingLevel.ERROR + ' execute method Failed;  Error=' + e.getStackTraceString() );
            Database.rollback(sp);           
        }
    }
    
    @testvisible
    private List<SVMXC__Service_Order_Line__c> getWorkDetailsList(String workOrderId){
        List<SVMXC__Service_Order_Line__c> workDetailList = new List<SVMXC__Service_Order_Line__c> ();
        for(SVMXC__SM_Change_Order_Parts__c reqPart  : changeOrderPartsList){
            SVMXC__Service_Order_Line__c workDetail = new SVMXC__Service_Order_Line__c(SVMXC__Actual_Quantity2__c = reqPart.SVMXC__SM_Quantity__c,
                                                                                           SVMXC__Product__c = reqPart.SVMXC__SM_Product__c,
                                                                                           SVMXC__Service_Order__c = workOrderId,
                                                                                           SVMXC__Line_Type__c = LINE_TYPE_PARTS,
                                                                                           RecordTypeId = UsageConsumptionRTId
                                                                                          );
            workDetailList.add(workDetail);
        }
        return workDetailList;

    }

    /** Created By: Arpit
     * Used to generate log details of batch
     * @parameter Map<Integer, Map<String, String>> failedRecordsWithBatchNoMap,  Map<Integer, Integer> recordCountInBatchMap
     * @ return String
     */ 
    @testvisible 
    private String getLogDetails(Map<Integer, Map<String, String>> failedRecordsWithBatchNoMap, Map<Integer, Integer> recordCountInBatchMap){
        Boolean isTestClassExecution = Test.isRunningTest();
        AsyncApexJob apexJob;
        if(!isTestClassExecution){
            String batchId = changeOrderLog.SVMXC__SM_Batch_Id__c;
            apexJob = [SELECT Id, extendedstatus , NumberOfErrors, TotalJobItems FROM AsyncApexJob WHERE Id =: batchId];
        }
        Integer batchFailedBySystemLimitaion = !isTestClassExecution ? apexJob.NumberOfErrors : 0;
        Integer totalNoOfBatches = !isTestClassExecution ? apexJob.TotalJobItems : 1;
        failedBatchCount = batchFailedBySystemLimitaion + failedRecordsWithBatchNoMap.size();
        totalFailedRecords = CORD_ConsoleImpl.getToBeGeneratedWOCount(fcoSfId); 
        String logDetails = 'Total No. of Records: ' + totalNoOfRecords + NEW_LINE;
        String batchLogDetails = CORD_ConsoleImpl.BLANK_STRING;
        Integer capturedFailedRecordCount = 0;
        for(Integer batchNo : failedRecordsWithBatchNoMap.keySet()){
            batchLogDetails += SECTION_SEPARATOR + NEW_LINE + 'Details of records causing failure of Batch No: ' + batchNo + NEW_LINE;
            batchLogDetails += 'Total No. of FCO Lines in Batch: ' + recordCountInBatchMap.get(batchNo) + NEW_LINE;
            capturedFailedRecordCount += recordCountInBatchMap.get(batchNo);
            batchLogDetails += NEW_LINE + 'Error Logs:' + NEW_LINE;
            Map<String, String> errorMap = failedRecordsWithBatchNoMap.get(batchNo);
            for(String fcoLineId : errorMap.keySet()){
                batchLogDetails += fcoLineId + CORD_ConsoleImpl.COLON_WITH_SPACE + errorMap.get(fcoLineId) + NEW_LINE;
            }
            batchLogDetails += NEW_LINE;
        }
        String systemLimitationErrorMsg = batchFailedBySystemLimitaion > 0 ? (apexJob.extendedstatus.containsIgnoreCase(SYSTEM_ERROR_PREFIX) ? apexJob.extendedstatus.remove(SYSTEM_ERROR_PREFIX) : apexJob.extendedstatus) : CORD_ConsoleImpl.BLANK_STRING;
        systemLimitationErrorMsg = String.isNotBlank(systemLimitationErrorMsg) ? (SECTION_SEPARATOR + NEW_LINE + 'Total No. of batches failed due to error "'+ systemLimitationErrorMsg +'": ' + batchFailedBySystemLimitaion + NEW_LINE + 'Total No. of FCO Lines in Batches: '+ (totalFailedRecords - capturedFailedRecordCount) + NEW_LINE + 'Please check the debug logs for more details.' + NEW_LINE) : CORD_ConsoleImpl.BLANK_STRING;
        batchLogDetails = systemLimitationErrorMsg + batchLogDetails;
        
        logDetails += 'Success: ' + (totalNoOfRecords - totalFailedRecords) + NEW_LINE;
        logDetails += 'Failure: ' + totalFailedRecords + NEW_LINE + NEW_LINE;
        logDetails += 'Total No. of Batches: ' + totalNoOfBatches + NEW_LINE;
        logDetails += 'Successful Batches: ' + (totalNoOfBatches - failedBatchCount) + NEW_LINE;
        logDetails += 'Failed Batches: ' + failedBatchCount + NEW_LINE + NEW_LINE;
        logDetails += batchLogDetails;
        return logDetails;
    }
    
    /**
     * This method is executed on completion of batch. At the end of service, we need to : 
     * a) Send email to Admin for success or failure
     * b) Update the Config data record with the Start and End time
     * c) Create Servicemax job record to track the service ran
    */
    global void finish(Database.BatchableContext BC){

        System.debug( LoggingLevel.INFO, 'finish() - enter' );

        try{
                String logDetails = getLogDetails(failedRecordsWithBatchNoMap, recordCountInBatchMap);
                failedRecordsWithBatchNoMap.clear(); //#cleanMemory
                recordCountInBatchMap.clear(); //#cleanMemory
                if(changeOrderLog != NULL){
                    changeOrderLog.SVMXC__SM_Completed_On__c = DateTime.now();
                    changeOrderLog.SVMXC__SM_Log_Details__c =  logDetails.length() > MAX_LOG_LENGTH ? logDetails.substring(0, MAX_LOG_LENGTH) : logDetails;
                    update changeOrderLog;
                    changeOrderLog.SVMXC__SM_Started_On__c = CORD_ConsoleImpl.getUserDateTime(changeOrderLog.SVMXC__SM_Started_On__c); // converting it to user time zone for email
                    changeOrderLog.SVMXC__SM_Completed_On__c = CORD_ConsoleImpl.getUserDateTime(changeOrderLog.SVMXC__SM_Completed_On__c); // converting it to user time zone for email
                }
                logDetails = CORD_ConsoleImpl.BLANK_STRING; //#cleanMemory
               
                if(changeOrder != NULL){
                    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> ();
                    if(String.isNotBlank(changeOrder.SVMXC__SM_CORD_Config__r.SVMXC__SM_Email__c)){
                        Messaging.SingleEmailMessage singleEmailMessageAdmin = new Messaging.SingleEmailMessage();
                        singleEmailMessageAdmin.setSubject(Label.FCO001_TAG038 + CORD_ConsoleImpl.SPACE + '-' + CORD_ConsoleImpl.SPACE + Label.FCO001_TAG040 + CORD_ConsoleImpl.SPACE + changeOrder.SVMXC__SM_Title__c + ' : ' + Label.FCO001_TAG062);
                        singleEmailMessageAdmin.setSaveAsActivity(false); 
                        String emailBody = CORD_ConsoleImpl.getEmailBodyForFCOAdmin(Label.FCO001_TAG040, changeOrder, totalNoOfRecords, totalFailedRecords, changeOrderLog);
                        System.debug('emailBody@@'+emailBody);
                        singleEmailMessageAdmin.setHtmlBody(emailBody);
                        singleEmailMessageAdmin.toAddresses = new String[] { changeOrder.SVMXC__SM_CORD_Config__r.SVMXC__SM_Email__c};
                        messages.add(singleEmailMessageAdmin);
                    }

                    if(changeOrder.SVMXC__SM_Notify_CORD_Owner__c){
                        Messaging.SingleEmailMessage singleEmailMessageOwner = new Messaging.SingleEmailMessage();
                        singleEmailMessageOwner.setSubject(Label.FCO001_TAG063 + CORD_ConsoleImpl.SPACE + '"' + changeOrder.SVMXC__SM_Title__c + '"' + CORD_ConsoleImpl.SPACE + Label.FCO001_TAG064);
                        singleEmailMessageOwner.setSaveAsActivity(false); 
                        String emailBodyOwner = CORD_ConsoleImpl.getEmailBodyWOForOwner(changeOrder, totalNoOfRecords, totalFailedRecords, changeOrderLog);
                        System.debug('emailBodyOwner@@'+emailBodyOwner);
                        singleEmailMessageOwner.setHtmlBody(emailBodyOwner);
                        String emailAddress = !Test.isRunningTest() ? changeOrder.Owner.Email : UserInfo.getUserEmail();
                        singleEmailMessageOwner.toAddresses = new String[] { emailAddress };
                        messages.add(singleEmailMessageOwner);
                    }
                    if(!messages.isEmpty()){
                        Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(messages);
                    }
                   
                }             
        }
        catch(Exception e)
        {
            System.debug('Error==>'+ e.getMessage());
            System.debug( LoggingLevel.ERROR + ' finish method Failed;  Error=' + e.getStackTraceString() );
        } 
    }
  }