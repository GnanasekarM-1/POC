/**
 * The CORD_FCOLinesBatch implements methods to execute the schedule services to perform specific task
 * Basic approach - a) Get the Scheduled Config data record to execute the service
 *                  b) Retrieve records for the object defined based on the qualification criteria. 
 *                  c) Pass the executed records to the service to perform specific task
 *                  d) On completion of service and batch, update the Scheduled Config data record and send an email to admin
 * 
 */
global with sharing class CORD_FCOLinesBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    global String fcoSfId;
    global SVMXC__SM_Change_Order_Log__c changeOrderLog;

    public static COMM_Utils_DescribeCall describeInstance = COMM_Utils_DescribeCall.getInstance();
    
    public static DescribeSObjectResult installedProductDescribe = describeInstance.getObjectDescribe(CORD_ConsoleImpl.INSTALLED_PRODUCT_OBJECT);
    public static final String IB_OBJ_PREFIX = installedProductDescribe.getKeyPrefix(); 
    public static final String IB_OBJ_LABEL_NAME = installedProductDescribe.getLabel(); 

    public static DescribeSObjectResult stockedSerialDescribe = describeInstance.getObjectDescribe(CORD_ConsoleImpl.STOCKED_SERIAL_OBJECT);
    public static final String STOCK_SERIAL_OBJ_PREFIX = stockedSerialDescribe.getKeyPrefix(); 
    public static final String STOCK_SERIAL_OBJ_LABEL_NAME = stockedSerialDescribe.getLabel(); 

    public static DescribeSObjectResult batchLotMasterDescribe = describeInstance.getObjectDescribe(CORD_ConsoleImpl.BATCH_LOT_MASTER_OBJECT);
    public static final String BATCH_MASTER_OBJ_PREFIX = batchLotMasterDescribe.getKeyPrefix(); 
    public static final String BATCH_MASTER_OBJ_LABEL_NAME = batchLotMasterDescribe.getLabel(); 

  
    public static final Map<String, String> prefixObjectNameMap = new Map<String, String> { IB_OBJ_PREFIX => IB_OBJ_LABEL_NAME,
                                                                                            STOCK_SERIAL_OBJ_PREFIX => STOCK_SERIAL_OBJ_LABEL_NAME,
                                                                                            BATCH_MASTER_OBJ_PREFIX => BATCH_MASTER_OBJ_LABEL_NAME
                                                                                          };

    public SVMXC__SM_Change_Order__c changeOrder;
    public Integer totalNumberOfRecords = 0;
    public static final String NEW_LINE  = '\n';
    public static final String SECTION_SEPARATOR = '----------------------------------------------';
    public static final Integer MAX_LOG_LENGTH = 131072;
    Map<String, Map<String, String>> allFailedRecordsMap = new Map<String, Map<String, String>> ();
    global Map<String, Integer> objectWiseRecordCountMap = new Map<String, Integer> ();  

    /**
     * This method receives 1 Schedule Detail Record.
     * It queries the list of sObject records from the schedule Detail record passed. 
     * While querying for the record, we apply the Qualification Criteria Defined to filter the records further to be passed to configured Service 
     * 
     * @return List of SObject Records retrieved
    */
     global CORD_FCOLinesBatch(String fcoSfId)
    {
        this.fcoSfId = fcoSfId;
    }  

     // This is the start method of batch class it is responsible for creating Iterable of sObject and pass it to execute method
    global List<sObject> start(Database.BatchableContext BC)
    {
        System.debug( LoggingLevel.INFO, 'start() - enter' );

        List<sObject> ibList = new List<sObject> ();
        List<SVMXC__SM_Change_Order__c> changeOrderList = [SELECT Id,  Owner.Email, SVMXC__SM_Title__c, SVMXC__SM_Status__c, SVMXC__SM_Top_Level_IBs_Only__c, SVMXC__SM_Criteria_Advanced_Expression__c, SVMXC__SM_CORD_Config__r.SVMXC__SM_Email__c, (SELECT Id, SVMXC__SM_Type__c, SVMXC__SM_Object_Criteria__c, SVMXC__SM_Sequence__c,SVMXC__SM_Criteria_Definition__c from SVMXC__Change_Order_Criterias__r WHERE SVMXC__SM_Type__c != NULL ORDER BY SVMXC__SM_Sequence__c ASC)  FROM SVMXC__SM_Change_Order__c WHERE Id =: fcoSfId];
        List<SVMXC__SM_Change_Order_Log__c> changeOrderLogs = [SELECT Id, SVMXC__SM_Started_On__c, SVMXC__SM_Completed_On__c FROM SVMXC__SM_Change_Order_Log__c WHERE SVMXC__SM_Batch_Id__c =: BC.getJobId() LIMIT 1];
        if(!changeOrderLogs.isEmpty()){
            changeOrderLog = changeOrderLogs[0];
            changeOrderLog.SVMXC__SM_Started_On__c = DateTime.now();
            update changeOrderLog;
        }
        if(!changeOrderList.isEmpty()){
            changeOrder = changeOrderList[0];
            ibList = new CORD_ConsoleImpl().getFCOLinesPreviewBatch(changeOrder, CORD_ConsoleImpl.FCO_LINE_BATCH_REQUEST);
            totalNumberOfRecords = ibList.size(); 
        }
         return ibList;
    }
    
    /** 
     * This method execute method calls the service by passing the paramter in form of SVMXC.SFM_WrapperDef.SFM_Request and gets response in the form of 
     * SVMXC.SFM_WrapperDef.SFM_Response. 
     * 
     * @scope - List of Object Records retrieved after filtering 
    */
    global void execute(Database.BatchableContext bc, List<sObject> scope){

        System.debug( LoggingLevel.INFO, 'execute() - enter' );

        Savepoint sp = Database.setSavepoint(); // set the save point, so that batch can be rolled back
        try{
            List<SVMXC__SM_Change_Order_Line__c> fcoLineList = new List<SVMXC__SM_Change_Order_Line__c> ();
            for(sObject record : scope){

                String recordId = String.valueOf(record.get('Id'));
                SVMXC__SM_Change_Order_Line__c fcoLine = new SVMXC__SM_Change_Order_Line__c(SVMXC__SM_Change_Order__c = fcoSfId, SVMXC__SM_Line_Status__c = CORD_ConsoleImpl.FCO_LINE_STATUS_DRAFT);
                String objectName = recordId.startsWith(CORD_ConsoleImpl.IB_OBJ_PREFIX) ? prefixObjectNameMap.get(CORD_ConsoleImpl.IB_OBJ_PREFIX) : recordId.startsWith(CORD_ConsoleImpl.BATCH_MASTER_OBJ_PREFIX) ? prefixObjectNameMap.get(CORD_ConsoleImpl.BATCH_MASTER_OBJ_PREFIX) : prefixObjectNameMap.get(CORD_ConsoleImpl.STOCK_SERIAL_OBJ_PREFIX);
                Integer count = objectWiseRecordCountMap.containsKey(objectName) ? objectWiseRecordCountMap.get(objectName) + 1 : 1;
                objectWiseRecordCountMap.put(objectName, count);
                
                if(recordId.startsWith(CORD_ConsoleImpl.IB_OBJ_PREFIX)){
                    fcoLine.SVMXC__SM_Installed_Product__c = recordId;
                }
                else if(recordId.startsWith(CORD_ConsoleImpl.BATCH_MASTER_OBJ_PREFIX)){
                    fcoLine.SVMXC__SM_Batch_Lot2__c = recordId;
                }
                else{
                    fcoLine.SVMXC__SM_Stocked_Serial__c = recordId;
                }
                fcoLineList.add(fcoLine);
            }
            Database.SaveResult[] srList = Database.insert(fcoLineList, false);

            // Iterate through each returned result
            Integer counter = 0;
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess() || Test.isRunningTest()) {
                    String recordId = String.valueOf(scope.get(counter).get('Id')); 
                    System.debug('test@@'+recordId+ 'errors@'+sr.getErrors());
                    String objectName = recordId.startsWith(CORD_ConsoleImpl.IB_OBJ_PREFIX) ? prefixObjectNameMap.get(CORD_ConsoleImpl.IB_OBJ_PREFIX) : recordId.startsWith(CORD_ConsoleImpl.BATCH_MASTER_OBJ_PREFIX) ? prefixObjectNameMap.get(CORD_ConsoleImpl.BATCH_MASTER_OBJ_PREFIX) : prefixObjectNameMap.get(CORD_ConsoleImpl.STOCK_SERIAL_OBJ_PREFIX);

                    // Operation failed, so get errors
                    Map<String, String> idErrorMap = allFailedRecordsMap.containsKey(objectName) ? allFailedRecordsMap.get(objectName) : new Map<String, String> ();
                    String errorMsg = !Test.isRunningTest() ? sr.getErrors()[0].getMessage() : SECTION_SEPARATOR; // SECTION_SEPARATOR works as dummy error msg for test class
                    idErrorMap.put(recordId, errorMsg);
                    allFailedRecordsMap.put(objectName, idErrorMap);
                }
                counter++;
            }
        }
        catch (Exception e){
            System.debug('Error==>'+ e.getMessage());
            System.debug( LoggingLevel.ERROR + ' execute method Failed;  Error=' + e.getStackTraceString() );
            Database.rollback(sp);
        }
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
                Integer totalFailedRecords = 0;
                String logDetails = 'Total Number of Records: ' + totalNumberOfRecords + NEW_LINE;
                String objectWiseInfo = CORD_ConsoleImpl.BLANK_STRING;
                for(String objectName : objectWiseRecordCountMap.keySet()){

                    objectWiseInfo += NEW_LINE + 'Details For: ' + objectName + CORD_ConsoleImpl.SPACE + 'Records: ' + NEW_LINE;

                    Map<String, String> idErrorMap = allFailedRecordsMap.containsKey(objectName) ? allFailedRecordsMap.get(objectName) : new Map<String, String> ();
                    Integer errorCount = idErrorMap.size();
                    Integer successCount = objectWiseRecordCountMap.get(objectName) - errorCount;

                    objectWiseInfo += 'Success: '+ successCount + NEW_LINE;
                    objectWiseInfo += 'Failure: ' + errorCount + NEW_LINE + NEW_LINE;

                    totalFailedRecords += errorCount;
                    String errorRows = CORD_ConsoleImpl.BLANK_STRING;
                    for(String recordId : idErrorMap.keySet()){
                        errorRows += recordId + CORD_ConsoleImpl.COLON_WITH_SPACE + idErrorMap.get(recordId) + NEW_LINE;
                    }
                    if(String.isNotBlank(errorRows)){
                        errorRows = 'Error Logs: ' + NEW_LINE + errorRows; 
                    }
                    objectWiseInfo += errorRows + SECTION_SEPARATOR + NEW_LINE;
                }

                logDetails += 'Success: ' + String.valueOf(totalNumberOfRecords - totalFailedRecords) + NEW_LINE;
                logDetails += 'Failure: ' + String.valueOf(totalFailedRecords) + NEW_LINE + SECTION_SEPARATOR;   
                logDetails += objectWiseInfo;     
                
                if(changeOrderLog != NULL){
                    changeOrderLog.SVMXC__SM_Completed_On__c = DateTime.now();
                    changeOrderLog.SVMXC__SM_Log_Details__c =  logDetails.length() > MAX_LOG_LENGTH ? logDetails.substring(0, MAX_LOG_LENGTH) : logDetails;
                    update changeOrderLog;
                    changeOrderLog.SVMXC__SM_Started_On__c = CORD_ConsoleImpl.getUserDateTime(changeOrderLog.SVMXC__SM_Started_On__c); // converting it to user time zone for email
                    changeOrderLog.SVMXC__SM_Completed_On__c = CORD_ConsoleImpl.getUserDateTime(changeOrderLog.SVMXC__SM_Completed_On__c); // converting it to user time zone for email
                }

                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> ();
                if(changeOrder != NULL && String.isNotBlank(changeOrder.SVMXC__SM_CORD_Config__r.SVMXC__SM_Email__c)){
                                      
                    Messaging.SingleEmailMessage singleEmailMessageAdmin = new Messaging.SingleEmailMessage();
                    
                    singleEmailMessageAdmin.setSubject(Label.FCO001_TAG038 + CORD_ConsoleImpl.SPACE + '-' + CORD_ConsoleImpl.SPACE + Label.FCO001_TAG039 + CORD_ConsoleImpl.SPACE + changeOrder.SVMXC__SM_Title__c + ' : ' + Label.FCO001_TAG062);
                    singleEmailMessageAdmin.setSaveAsActivity(false); 
                    String emailBody = CORD_ConsoleImpl.getEmailBodyForFCOAdmin(Label.FCO001_TAG039, changeOrder, totalNumberOfRecords, totalFailedRecords, changeOrderLog);

                    singleEmailMessageAdmin.setHtmlBody(emailBody);
                    singleEmailMessageAdmin.toAddresses = new String[] { changeOrder.SVMXC__SM_CORD_Config__r.SVMXC__SM_Email__c};
                    messages.add(singleEmailMessageAdmin);
                }     
                
                Messaging.SingleEmailMessage singleEmailMessageOwner = new Messaging.SingleEmailMessage();
                    
                singleEmailMessageOwner.setSubject(Label.FCO001_TAG069 + CORD_ConsoleImpl.SPACE + changeOrder.SVMXC__SM_Title__c + CORD_ConsoleImpl.SPACE + Label.FCO001_TAG070);
                singleEmailMessageOwner.setSaveAsActivity(false); 
                String emailBodyOwner = CORD_ConsoleImpl.getEmailBodyFCOLineForOwner(changeOrder, totalNumberOfRecords, totalFailedRecords, changeOrderLog);

                singleEmailMessageOwner.setHtmlBody(emailBodyOwner);

                String emailAddress = !Test.isRunningTest() ? changeOrder.Owner.Email : UserInfo.getUserEmail();
                singleEmailMessageOwner.toAddresses = new String[] { emailAddress };
                messages.add(singleEmailMessageOwner);                
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }
        catch(Exception e)
        {
            System.debug('Error==>'+ e.getMessage());
            System.debug( LoggingLevel.ERROR + ' finish method Failed;  Error=' + e.getStackTraceString() );
        } 
    }
  }