/*****************************************************************************
*                       Copyright (C) 2020 ServiceMax, Inc
*                               All rights reserved
*
*****************************************************************************/

/**
* @brief This class has implementation of all defined FCO APIs. These methods are 
 * invoked by both REST services and JSR calls.
*
* @author Ramachandra Mohan
* @version 20.2
* @since 2020
*/
/*****************************************************************************************************
*    ID        Name                    Date            Comment
*****************************************************************************************************
*              Ramachandra Mohan       07 Feb 2020     Created.
*****************************************************************************************************/
public with sharing class CORD_ConsoleImpl {
    
    public static final String BLANK_STRING = '';
    public static final String SPACE = ' ';
    public static final String CHANGE_ORDER_OBJECT = 'SVMXC__SM_Change_Order__c';
    public static final String FCO_LINE_OBJECT = 'SVMXC__SM_Change_Order_Line__c';
    public static final String FCO_REQ_PART_OBJECT = 'SVMXC__SM_Change_Order_Parts__c'; //#defectFix-6261
    public static final String WORK_DETAIL_OBJECT = 'SVMXC__Service_Order_Line__c'; //#defectFix-6261
    public static final String WORK_ORDER_OBJECT = 'SVMXC__Service_Order__c'; 
    public static final String INSTALLED_PRODUCT_SEARCH_TYPE = 'Installed Product';
    public static final String TECH_ATTRIB_SEARCH_TYPE = 'Technical Attribute';
    public static final String BATCH_LOT_SEARCH_TYPE = 'Batch Lot';
    public static final String INSTALLED_PRODUCT_OBJECT = 'SVMXC__Installed_Product__c';
    public static final String BATCH_LOT_MASTER_OBJECT = 'SVMXC__SM_Batch_Lot__c';
    public static final String STOCKED_SERIAL_OBJECT = 'SVMXC__Product_Serial__c';
    public static final String SITE_OBJECT = 'SVMXC__Site__c';
    public static String errorMessage = BLANK_STRING;
    public static final String CHANGE_ORDER_ACCESS_RT = 'Change_Order_Access';
    public static final String BATCH_STATUS_OPEN = 'Open';
    public static final String LOG_TYPE_FCO_GENERATION = 'FCO Line Generation';
    public static final String LOG_TYPE_WO_GENERATION = 'WO Generation';
    public static final String FCO_STATUS_DRAFT = 'Draft';
    public static final String FCO_STATUS_IN_PROGRESS = 'In Progress';
    public static final String FCO_STATUS_COMPLETED = 'Completed';
    public static final String LOG_TYPE_CANCELED = 'Canceled';
    public static final String BATCH_NOT_STARTED = 'Not_Started';
    public static final String BATCH_IN_PROGRESS = 'In_Progress';
    public static final String BATCH_QUEUED = 'Queued';
    public static final String BATCH_STATUS_IN_PROGRESS= 'In-Progress';
    public static final String USER_PREF_TYPE_FCO = 'FCO';
    public static final String DETAILS_TAB = 'Details_Tab';
    public static final String SEARCH_RESULTS_TAB = 'SearchResults_Tab';
    public static final String WORK_ORDER_TAB = 'WorkOrder_Tab';
    public static final String FCO_LINE_STATUS_WO_GEN = 'WO Generated';
    public static final String FCO_LINE_STATUS_CONFIRMED = 'Confirmed';
    public static final String FCO_LINE_STATUS_DRAFT = 'Draft';
    public static final Integer MAX_PREVIEW_LINES = 5;
    private static Integer totalExpectedFCOLineCount = 0;
    public static final String PREVIEW_REQUEST = 'previewRequest';
    public static final String FCO_LINE_BATCH_REQUEST = 'fcoLineBatchRequest';
    public static final String BATCH_LOT_REQUEST = 'batchLot';
    public static final String IB_REQUEST = 'installedProduct';
    public static String batchStatusByTestClass = BATCH_NOT_STARTED;

    public static final COMM_Utils_DescribeCall describeInstance;
    public static final Map<String, Schema.SObjectType> globalDescribeInstance;
    public static final timeZone userTimeZone = UserInfo.getTimeZone();
    public static final String userTimeZoneDisplayName = userTimeZone.getDisplayName();
    public String FCO001_TAG051_LABEL = Label.FCO001_TAG051;
    public String FCO001_TAG052_LABEL = Label.FCO001_TAG052;
    public String FCO001_TAG075_LABEL = Label.FCO001_TAG075;
    public String FCO001_TAG076_LABEL = Label.FCO001_TAG076;
    public String FCO001_TAG057_LABEL = Label.FCO001_TAG057;
    public String FCO001_TAG058_LABEL = Label.FCO001_TAG058;
    public String FCO001_TAG059_LABEL = Label.FCO001_TAG059;
    public String FCO001_TAG060_LABEL = Label.FCO001_TAG060;
    public String FCO001_TAG031_LABEL = Label.FCO001_TAG031;
    public String FCO001_TAG061_LABEL = Label.FCO001_TAG061;


    public static COMM_Utils_DescribeCall getDescribeInstance() {
        return describeInstance != NULL ? describeInstance : COMM_Utils_DescribeCall.getInstance();
    }

    public static Map<String, Schema.SObjectType> getGlobalDescribe(){
        return globalDescribeInstance != NULL ? globalDescribeInstance : getDescribeInstance().getGlobalDescribeCall();
    }

    public static final Schema.DescribeSObjectResult changeOrderDescribeResult = getGlobalDescribe().get(CHANGE_ORDER_OBJECT).getDescribe();
    public static final Boolean isCOCreateable = changeOrderDescribeResult.isCreateable();
    public static final Boolean isCOUpdateable = changeOrderDescribeResult.isUpdateable();
    public static final Boolean isCODeletable = changeOrderDescribeResult.isDeletable();

    private static final String WORK_ORDER_DEFAULT_QUERY_FIELDS = ' Id, Name, SVMXC__Component__r.SVMXC__Serial_Lot_Number__c, SVMXC__Site__r.Name, SVMXC__Order_Status__c ';
    private static final String FCO_LINE_DEFAULT_QUERY_FIELDS = ' Id, SVMXC__SM_Installed_Product__r.Name, SVMXC__SM_Serial_Number__c, SVMXC__SM_Location__c,SVMXC__SM_Batch_Lot_Number__c, SVMXC__SM_Generate_WORD__c, toLabel(SVMXC__SM_Line_Status__c) ';   
    private static final String FCO_DEFAULT_QUERY_FIELDS = ' Id, SVMXC__SM_Title__c, toLabel(SVMXC__SM_Order_Type__c), toLabel(SVMXC__SM_Order_Type__c), toLabel(SVMXC__SM_Priority__c), toLabel(SVMXC__SM_Status__c), SVMXC__SM_Start_Date__c, SVMXC__SM_Due_Date__c ';
    private static final String STOCKED_SERIAL_PREVIEW_FIELDS = 'Id, Name, SVMXC__SM_Batch_Lot2__c, SVMXC__SM_Batch_Lot2__r.Name, SVMXC__Product_Stock__c, SVMXC__Product_Stock__r.SVMXC__Location__c,SVMXC__Product_Stock__r.SVMXC__Location__r.Name ';
    private static final String BATCH_LOT_FIELD_ON_STOCKED_SERIAL = 'SVMXC__SM_Batch_Lot2__c';
    private static final String BATCH_MASTER_PREVIEW_FIELDS = 'Id, Name ';
    public static final String BATCH_LOT_NUMBER_PLACEHOLDER_FIELD = 'Batch_Lot_Number';
    public Savepoint sp;

    /*
        Status  Description  
        Holding Job has been submitted and is held in the Apex flex queue until system resources become available to queue the job for processing.
        Queued  Job is awaiting execution.
        Preparing   The start method of the job has been invoked. This status can last a few minutes depending on the size of the batch of records.
        Processing  Job is being processed.
        Aborted Job aborted by a user.
        Completed   Job completed with or without failures.
        Failed  Job experienced a system failure.
    */
    public static final List<String> BATCH_QUEUED_STATUS_LIST = new List<String> {'Holding', 'Queued'};
    public static final List<String> BATCH_IN_PROGRESS_LIST = new List<String> {'Preparing', 'Processing'};
    public static final String BATCH_COMPLETED = 'Completed';
    public static final String BATCH_ABORTED = 'Aborted';
    public static final String BATCH_FAILED = 'Failed';

    public static List<CORD_WrapperDef.FCOFieldInfo> fcoSelectedColumns = new List<CORD_WrapperDef.FCOFieldInfo> () ;
    public static List<CORD_WrapperDef.FCOFieldInfo> fcoLineSelectedColumns = new List<CORD_WrapperDef.FCOFieldInfo> ();
    public static List<CORD_WrapperDef.FCOFieldInfo> workOrderSelectedColumns = new List<CORD_WrapperDef.FCOFieldInfo> ();
    public static List<CORD_WrapperDef.FCOFieldInfo> objConfigColumns = new List<CORD_WrapperDef.FCOFieldInfo> ();

    // This map is used to keep those objects which does not have standard name field
    public static final Map<String, String> stdObjectFieldMap = new Map<String, String>{'Case' => 'CaseNumber',
                                                                        'Solution' => 'SolutionName',
                                                                        'Task' => 'Subject',
                                                                        'Event' => 'Subject',
                                                                        'Contract' => 'ContractNumber',
                                                                        'OrderItem' => 'OrderItemNumber',
                                                                        'Order' => 'OrderNumber'
                                                                    };  

    // This map is used keep columns for fco preview line
    public static final Map<String, String> fcoLinePreviewMap = new Map<String, String> {'item' => 'SVMXC__SM_Installed_Product__c',
                                                                                        'serialNumber' => 'SVMXC__SM_Serial_Number__c',
                                                                                        'batchLotNumber' => 'SVMXC__SM_Batch_Lot_Number__c', //possibleError
                                                                                        'location' => 'SVMXC__SM_Location__c'
                                                                                        };          
                                                      
    // This map is used to get field api name on batch lot, stocked serial and installed product object
    private static Map<String, String> objectProductFieldMap = new Map<String, String>  {BATCH_LOT_MASTER_OBJECT => 'SVMXC__SM_Product__c',
                                                                                        STOCKED_SERIAL_OBJECT => 'SVMXC__Product__c',
                                                                                        INSTALLED_PRODUCT_OBJECT => 'SVMXC__Product__c'
                                                                                        };

    /* operator display values starts*/                                                                
    private static final String CONTAINS = Label.FCO001_TAG008; // value: contains 
    private static final String IS_EQUAL_TO = Label.FCO001_TAG009; // value: is equal to
    private static final String IS_NOT_EQUAL_TO = Label.FCO001_TAG010; // value: is not equal to
    private static final String DOES_NOT_CONTAIN = Label.FCO001_TAG011; // value: does not contain
    private static final String IS_NULL = Label.FCO001_TAG012; // value: is NULL
    private static final String IS_NOT_NULL = Label.FCO001_TAG013; // value: is not NULL
    private static final String IS = Label.FCO001_TAG014; // value: is
    private static final String IS_BEFORE = Label.FCO001_TAG015; // value: is before
    private static final String IS_AFTER = Label.FCO001_TAG016; // value: is after
    private static final String IS_GREATER_THAN = Label.FCO001_TAG017; // value: is greater than
    private static final String IS_GREATER_THAN_EQUAL = Label.FCO001_TAG018; // value: is greater than or equal to
    private static final String IS_LESS_THAN = Label.FCO001_TAG019; // value: is less than
    private static final String IS_LESS_THAN_EQUAL = Label.FCO001_TAG020; // value: is lesser than or equal to
    private static final String INCLUDES = Label.FCO001_TAG021; // value: includes
    private static final String EXCLUDES = Label.FCO001_TAG022; // value: excludes
    private static final String STARTS_WITH = Label.FCO001_TAG034; // value: Starts With

    public static final String IB_OBJ_PREFIX = SVMXC__Installed_Product__c.SObjectType.getDescribe().getKeyPrefix(); 
    public static final String STOCK_SERIAL_OBJ_PREFIX = SVMXC__Product_Serial__c.SObjectType.getDescribe().getKeyPrefix(); 
    public static final String BATCH_MASTER_OBJ_PREFIX = SVMXC__SM_Batch_Lot__c.SObjectType.getDescribe().getKeyPrefix();
    public static final String COLON = ':';
    public static final String COLON_WITH_SPACE =': ';
    /* operator display values ends*/   

    /* This map is used to keep data type with their applicable operators */
    @testvisible
    private static final Map<String,  List<String>> fieldTypeOperatorMap = new Map<String,  List<String>>{
        'STRING' => new List<String> {CONTAINS, IS_GREATER_THAN, IS_GREATER_THAN_EQUAL, IS_LESS_THAN, IS_LESS_THAN_EQUAL, IS_EQUAL_TO, IS_NOT_EQUAL_TO, DOES_NOT_CONTAIN, IS_NULL, IS_NOT_NULL, STARTS_WITH}, 
        'DATE' => new List<String> {IS, IS_BEFORE, IS_AFTER, IS_GREATER_THAN_EQUAL, IS_LESS_THAN_EQUAL, IS_NOT_EQUAL_TO, IS_NULL, IS_NOT_NULL}, 
        'REFERENCE' => new List<String> {CONTAINS, IS_EQUAL_TO, IS_NOT_EQUAL_TO, DOES_NOT_CONTAIN, IS_NULL, IS_NOT_NULL, STARTS_WITH}, 
        'BOOLEAN' =>  new List<String> {IS}, 
        'DATETIME' => new List<String> {IS, IS_BEFORE, IS_AFTER, IS_GREATER_THAN_EQUAL, IS_LESS_THAN_EQUAL, IS_NOT_EQUAL_TO, IS_NULL, IS_NOT_NULL}, 
        'PICKLIST' => new List<String> {IS_EQUAL_TO, IS_NOT_EQUAL_TO, IS_NULL, IS_NOT_NULL}, 
        'MULTIPICKLIST' => new List<String> {IS_EQUAL_TO, IS_NOT_EQUAL_TO, INCLUDES, EXCLUDES, IS_NULL, IS_NOT_NULL}, 
        'DOUBLE' => new List<String> {IS_EQUAL_TO, IS_NOT_EQUAL_TO, IS_GREATER_THAN, IS_GREATER_THAN_EQUAL, IS_LESS_THAN, IS_LESS_THAN_EQUAL, IS_NULL, IS_NOT_NULL}, 
        'EMAIL' => new List<String> {CONTAINS, STARTS_WITH, IS_EQUAL_TO, IS_NOT_EQUAL_TO, DOES_NOT_CONTAIN, IS_NULL, IS_NOT_NULL}, 
        'CURRENCY' => new List<String> {IS_EQUAL_TO, IS_NOT_EQUAL_TO, IS_GREATER_THAN, IS_GREATER_THAN_EQUAL, IS_LESS_THAN, IS_LESS_THAN_EQUAL, IS_NULL, IS_NOT_NULL}, 
        'PHONE' => new List<String> {CONTAINS, IS_EQUAL_TO, IS_NOT_EQUAL_TO, IS_NULL, IS_NOT_NULL},
        'PERCENT'=>new List<String> {IS_EQUAL_TO, IS_NOT_EQUAL_TO, IS_GREATER_THAN, IS_GREATER_THAN_EQUAL, IS_LESS_THAN, IS_LESS_THAN_EQUAL, IS_NULL, IS_NOT_NULL}
     }; 

    /* This map is used to keep data type with their applicable operators */
    private static final Map<String,  List<String>> fieldTypeOperatorForTechAtrribMap = new Map<String,  List<String>>{
        'STRING' => new List<String> {CONTAINS, IS_GREATER_THAN, IS_GREATER_THAN_EQUAL, IS_LESS_THAN, IS_LESS_THAN_EQUAL, IS_EQUAL_TO, IS_NOT_EQUAL_TO, DOES_NOT_CONTAIN, IS_NULL, IS_NOT_NULL, STARTS_WITH}, 
        'BOOLEAN' =>  new List<String> {IS}, 
        'PICKLIST' => new List<String> {IS_EQUAL_TO, IS_NOT_EQUAL_TO, IS_NULL, IS_NOT_NULL}, 
        'DOUBLE' => new List<String> {IS_EQUAL_TO, IS_NOT_EQUAL_TO, IS_GREATER_THAN, IS_GREATER_THAN_EQUAL, IS_LESS_THAN, IS_LESS_THAN_EQUAL, IS_NULL, IS_NOT_NULL}
        }; 

    /* This map is used to keep data type with their applicable operators */
    private static final Map<String,  List<String>> fieldTypeOperatorForBatchLotMap = new Map<String,  List<String>>{
        'STRING' => new List<String> {CONTAINS, IS_GREATER_THAN, IS_GREATER_THAN_EQUAL, IS_LESS_THAN, IS_LESS_THAN_EQUAL, IS_EQUAL_TO, IS_NOT_EQUAL_TO, DOES_NOT_CONTAIN, IS_NULL, IS_NOT_NULL, STARTS_WITH}
       }; 
     
     
     /* This set is used to contains text data type which needs to have single quotes while making query */
     private static final Set<String> STRING_EQVLNT_TYPES = new Set<String> {'STRING', 'REFERENCE', 'PICKLIST', 'MULTIPICKLIST', 'EMAIL', 'PHONE'};

     /* This map contains operators with its corrensponding salesforce operators */
    private static final Map<String, String> operatorSymbolMap = new Map<String, String> {
                                                                                            'cntn' => 'LIKE',
                                                                                            'eq' => '=',
                                                                                            'neq' => '!=',
                                                                                            'nocntn' => 'LIKE',
                                                                                            'isBfr' => '<',
                                                                                            'isAftr' => '>',
                                                                                            'gt' => '>',
                                                                                            'gte' => '>=',
                                                                                            'lt' => '<',
                                                                                            'lte' => '<=',
                                                                                            'isNull' => '= NULL',
                                                                                            'isNotNull' => '!= NULL',
                                                                                            'is' => '=',
                                                                                            'inc' => 'INCLUDES',
                                                                                            'exc' => 'EXCLUDES',
                                                                                            'strtWith' => 'STARTS_WITH'
                                                                                        };
    private Boolean isCloneRequest = false;
    private Boolean isFcoHeaderHasCustomField = false;

     /* This map is used to contain operator equivalents which will be stored in Database as part of JSON */
     private static Map<String, String> operatorPicklistMap = new Map<String, String>{
                                                                                CONTAINS => 'cntn',
                                                                                IS_EQUAL_TO => 'eq',
                                                                                IS_NOT_EQUAL_TO => 'neq',
                                                                                DOES_NOT_CONTAIN => 'nocntn',
                                                                                IS_NULL => 'isNull',
                                                                                IS_NOT_NULL => 'isNotNull',
                                                                                IS => 'is',
                                                                                IS_BEFORE => 'isBfr',
                                                                                IS_AFTER => 'isAftr',
                                                                                IS_GREATER_THAN => 'gt',
                                                                                IS_GREATER_THAN_EQUAL => 'gte',
                                                                                IS_LESS_THAN => 'lt',
                                                                                IS_LESS_THAN_EQUAL => 'lte',
                                                                                INCLUDES => 'inc',
                                                                                EXCLUDES => 'exc',
                                                                                STARTS_WITH => 'strtWith'
                                                                             };

    private static Map<String, String> techAttribDataTypeMap = new Map<String, String> {
                                                                                    'Text' => 'STRING',
                                                                                    'Number' => 'DOUBLE',
                                                                                    'Picklist' => 'PICKLIST',
                                                                                    'Boolean' => 'BOOLEAN'
                                                                                 };        
                                                                                 
    private static Map<String, String> techAttribDataTypeToField = new Map<String, String> {
                                                                                    'STRING' => 'SVMXC__SM_Attr_Value__c',
                                                                                    'DOUBLE' => 'SVMXC__SM_Number_Value__c',
                                                                                    'PICKLIST' => 'SVMXC__SM_Attr_Value__c',
                                                                                    'BOOLEAN' => 'SVMXC__SM_Boolean_Value__c'
                                                                                 };                                                                               
    
    /** Created By: Arpit
     * Used to generate a map of datatype with its supported operators (key, value pair)
     * @parameter NA
     * @return Map<String, List<CORD_WrapperDef.KeyValuePair>>
     */
    @testvisible
     private static Map<String, List<CORD_WrapperDef.KeyValuePair>> createFieldTypeOperatorMap(Map<String,  List<String>> fieldTypeOperMap){
        Map<String, List<CORD_WrapperDef.KeyValuePair>> fieldTypeWithOperators = new Map<String, List<CORD_WrapperDef.KeyValuePair>> ();
        for(String dataType : fieldTypeOperMap.keySet()){
            fieldTypeWithOperators.put(dataType, getOperatorsList(dataType));
         }
         return fieldTypeWithOperators;
     }

     /** Created By: Arpit
     * Used to create list of applicable operators of provided data type
     * @parameter String dataType
     * @return List<CORD_WrapperDef.KeyValuePair>
     */
    @testvisible
     private static List<CORD_WrapperDef.KeyValuePair> getOperatorsList(String dataType){
         List<CORD_WrapperDef.KeyValuePair> keyValuePairList = new List<CORD_WrapperDef.KeyValuePair> ();
        for(String operator : fieldTypeOperatorMap.get(dataType)){
            CORD_WrapperDef.KeyValuePair keyValuePair = new CORD_WrapperDef.KeyValuePair ();
            keyValuePair.key = operator;
            keyValuePair.value = operatorPicklistMap.get(operator);
            keyValuePairList.add(keyValuePair);
        }
        return keyValuePairList;
     }

     /** Created By: Arpit
     * Used to get apex job details
     * @parameter String batchId
     * @return AsyncApexJob
     */ 
     @testvisible
     private static AsyncApexJob getBatchDetails(String batchId){
        List<AsyncApexJob> apexJobList = [SELECT Id, Status FROM AsyncApexJob WHERE Id =: batchId];
        return !apexJobList.isEmpty() ? apexJobList[0] : Test.isRunningTest() ? new AsyncApexJob() : NULL;
     }

     /** Created By: Arpit
     * Used to get FCO screen tab to be rendered
     * @parameter fcoSfId
     * @return Returns String
     */ 
     public CORD_WrapperDef.FCO_Response getFCOScreen(final String fcoSfId){

         System.debug( LoggingLevel.INFO, 'getFCOScreen() - enter' ); 
         System.debug( LoggingLevel.INFO, fcoSfId ); 
 
         CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
         String tabToRender = DETAILS_TAB;

        try{
                List<SVMXC__SM_Change_Order_Log__c> fcoLineLogs = [SELECT Id, SVMXC__SM_Batch_Id__c FROM SVMXC__SM_Change_Order_Log__c WHERE SVMXC__SM_Change_Order__c =: fcoSfId AND SVMXC__SM_Log_Type__c =: LOG_TYPE_FCO_GENERATION ORDER BY createdDate];
                List<SVMXC__SM_Change_Order_Log__c> fcoWOLogs = [SELECT Id, SVMXC__SM_Batch_Id__c FROM SVMXC__SM_Change_Order_Log__c WHERE SVMXC__SM_Change_Order__c =: fcoSfId AND SVMXC__SM_Log_Type__c =: LOG_TYPE_WO_GENERATION ORDER BY createdDate];

                if(fcoLineLogs.isEmpty() && fcoWOLogs.isEmpty()){
                    tabToRender = DETAILS_TAB;
               }
                else{
                    if(!fcoLineLogs.isEmpty() && fcoWOLogs.isEmpty()){ // if fcoWOLogs is empty it means we never exectuted wo generation batch so we must be on details or search tab
                        tabToRender = SEARCH_RESULTS_TAB;
                    }
                    else if(!fcoWOLogs.isEmpty()){
                        tabToRender = WORK_ORDER_TAB;
                    }
                }
                response.data = tabToRender;
            }   

         catch(Exception e){
                 response.success = false;
                 response.message = Label.FCO001_TAG026; //'There is some error occurred while retrieving change order details. Please contact admin';
                 errorMessage = response.message;
                 createExceptionLogs(e, response, 'getFCOScreen', BLANK_STRING);
            }

        finally{
                System.debug( LoggingLevel.INFO, 'getFCOScreen() - exit' );
            }
         
         return response;
     }

     /** Created By: Arpit
     * Used to identify if any custom field is available on the object
     * @parameter String objectName
     * @return Returns Boolean
     */ 
     private Boolean isFCOCustomFieldAvailable(String objectName){
         getFieldsInfo(objectName);
         return isFcoHeaderHasCustomField;
     }
     
    /** Created By: Arpit
     * Used to get FCO Header and Required Parts information
     * @parameter String fcoSfId
     * @return Returns CORD_WrapperDef.FCO_Response
     */ 
    public CORD_WrapperDef.FCO_Response getFieldChangeOrder(final String fcoSfId) {
        System.debug( LoggingLevel.INFO, 'getFieldChangeOrder() - enter' ); // #reviewComment final keyword
        System.debug( LoggingLevel.INFO, fcoSfId ); // #reviewComment

        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
            List<SVMXC__SM_Change_Order__c> fcoList = [SELECT Id, LastModifiedDate, SVMXC__SM_Title__c, SVMXC__SM_CORD_Config__c, SVMXC__SM_Notify_CORD_Owner__c, SVMXC__SM_Top_Level_IBs_Only__c, SVMXC__SM_Decision_Date__c, SVMXC__SM_Delivery_Method__c, SVMXC__SM_Order_Type__c, SVMXC__SM_Description__c, SVMXC__SM_Status__c, SVMXC__SM_Priority__c, SVMXC__SM_Start_Date__c, SVMXC__SM_Due_Date__c,SVMXC__SM_Criteria_Advanced_Expression__c,
                                                         (SELECT SVMXC__SM_Product__c, SVMXC__SM_Product__r.Name, SVMXC__SM_Quantity__c FROM SVMXC__SM_Change_Order_Parts__r)
                                                        FROM SVMXC__SM_Change_Order__c WHERE Id =: fcoSfId /*WITH SECURITY_ENFORCED*/ LIMIT 1];
          CORD_WrapperDef.FieldChangeOrderInfo fieldChangeOrderInfoWrapper = new CORD_WrapperDef.FieldChangeOrderInfo();
           if(!fcoList.isEmpty()){
                 SVMXC__SM_Change_Order__c changeOrder = fcoList[0];
                 fieldChangeOrderInfoWrapper = createChangeOrderHeaderInfo(changeOrder);
                 List<CORD_WrapperDef.RequiredParts> requiredPartsList = createRequiredPartsInfo(changeOrder.SVMXC__SM_Change_Order_Parts__r);
                 fieldChangeOrderInfoWrapper.requiredPartsList = requiredPartsList;
                 try{
                    fieldChangeOrderInfoWrapper.searchExpressions = getSearchExpression(fcoSfId);
                    String tabToRender = (String) getFCOScreen(fcoSfId).data;
                    if(String.isNotBlank(tabToRender)){
                        fieldChangeOrderInfoWrapper.tabToRender = tabToRender;
                        fieldChangeOrderInfoWrapper.isFcoHeaderHasCustomField = isFCOCustomFieldAvailable(CHANGE_ORDER_OBJECT);
                        response.data = fieldChangeOrderInfoWrapper;
                    }
                    else{
                        createExceptionLogs(null, response, 'getFieldChangeOrder', errorMessage);   
                    }
                 }
                 catch(Exception e){
                    createExceptionLogs(e, response, 'getFieldChangeOrder', Label.FCO001_TAG007); // value: 'Search Expression is not valid'    
                 }
            }
            else{
                createExceptionLogs(null, response, 'getFieldChangeOrder',  Label.FCO001_TAG003);   // value : Insufficient permission to access this record or record does not exist.
            }
                
        }   
        
        catch(Exception e ){
                 createExceptionLogs(e, response, 'getFieldChangeOrder', BLANK_STRING);
        }

        finally {
            System.debug( LoggingLevel.INFO, 'getFieldChangeOrder() - exit' );
        }
        return response;
    }

     /** Created By: Arpit
     * Used to get FCO Records List
     * @parameter N/A
     * @return Returns CORD_WrapperDef.FCO_Response
     */ 
    public CORD_WrapperDef.FCO_Response getFieldChangeOrdersList(List<CORD_WrapperDef.FCOFieldInfo> configuredColumns) {
        
        System.debug( LoggingLevel.INFO, 'getFieldChangeOrdersList() - enter' );
        String queryFields = !configuredColumns.isEmpty() ? getQueryFields(configuredColumns) : FCO_DEFAULT_QUERY_FIELDS;
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        // To Do, FCO will be loaded based on the config (SVMXC__SM_CORD_Config__c), If user group profile
        // falls under fco configuration same as FCO or FCO is orgainisation wide available then grab it.
        try {
            List<SVMXC__SM_Change_Order__c> changeOrderList =  Database.query('SELECT ' + queryFields + ' FROM SVMXC__SM_Change_Order__c ORDER BY createdDate DESC ');            
            response.data = changeOrderList;
        }
        
        catch(Exception e ){
            createExceptionLogs(e, response, 'getFieldChangeOrdersList', BLANK_STRING);
         }
        
        finally {
            System.debug( LoggingLevel.INFO, 'getFieldChangeOrdersList() - exit' );
        }
        return response;
    }
    
    
     /** Created By: Arpit
     * Used to save fco record
     * @parameter CORD_WrapperDef.FieldChangeOrderInfo
     * @return Returns CORD_WrapperDef.FCO_Response
     */ 
    public CORD_WrapperDef.FCO_Response saveFieldChangeOrder( CORD_WrapperDef.FieldChangeOrderInfo fieldChangeOrderInfo ) {
        System.debug( LoggingLevel.INFO, 'saveFieldChangeOrder() - enter' );
        System.debug( LoggingLevel.INFO, fieldChangeOrderInfo ); // #reviewComment

        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        SVMXC__SM_Change_Order__c changeOrder;
        sp = Database.setSavepoint(); // set the save point, so that roll back can be done in case of partial success

        try{   
            if(isCOCreateable){            
                if(isValidFcoRequest(fieldChangeOrderInfo)){ // #reviewComment create method to verify if all the required fields are there 
                    changeOrder = createChangeOrderRecord(fieldChangeOrderInfo);        
                    upsert changeOrder;

                    List<SVMXC__SM_Change_Order_Parts__c> toBeDeletedRequiredParts;
                    List<Id> existingRecords = new List<Id> ();
                    fieldChangeOrderInfo.fcoSfId = changeOrder.Id;

                    List<CORD_WrapperDef.RequiredParts> requiredPartsList = new List<CORD_WrapperDef.RequiredParts> ();
                    requiredPartsList = fieldChangeOrderInfo.requiredPartsList;
                    Map<Id, String> productIdNameMap = new Map<Id, String> ();
                    List<SVMXC__SM_Change_Order_Parts__c> changeOrderReqPartsList = new List<SVMXC__SM_Change_Order_Parts__c> ();
                    if(requiredPartsList != NULL && !requiredPartsList.isEmpty()){
                        for(CORD_WrapperDef.RequiredParts reqPart : requiredPartsList){
                            SVMXC__SM_Change_Order_Parts__c requiredPart = String.isBlank(reqPart.sfId) ? new SVMXC__SM_Change_Order_Parts__c(SVMXC__SM_Change_Order__c = changeOrder.Id) :  new SVMXC__SM_Change_Order_Parts__c(Id = reqPart.sfId, SVMXC__SM_Change_Order__c = changeOrder.Id);
                            if(String.isNotBlank(reqPart.sfId)){
                                existingRecords.add(reqPart.sfId);
                            }
                            requiredPart.SVMXC__SM_Product__c = reqPart.productId;
                            requiredPart.SVMXC__SM_Quantity__c = reqPart.quantity;
                            productIdNameMap.put(reqPart.productId, reqPart.name);
                            changeOrderReqPartsList.add(requiredPart);
                        }
                    }

                    // delete required parts which we did not recieve in request 
                    toBeDeletedRequiredParts = [SELECT Id FROM SVMXC__SM_Change_Order_Parts__c WHERE Id NOT IN : existingRecords AND SVMXC__SM_Change_Order__c =: changeOrder.Id];
                    Schema.DescribeSObjectResult changeOrderReqPartDescribeResult = getGlobalDescribe().get(FCO_REQ_PART_OBJECT).getDescribe(); //#defectFix-6261
                    if(!toBeDeletedRequiredParts.isEmpty()){
                        Boolean isReqPartDeletable = changeOrderReqPartDescribeResult.isDeletable(); //#defectFix-6261
                        if(isReqPartDeletable){  //#defectFix-6261
                            delete toBeDeletedRequiredParts;
                        }
                        else{
                            createExceptionLogs(null, response, 'saveFieldChangeOrder', Label.COMM001_TAG142); //Value: Insufficient permission to perform the operation. Please verify the object and field level permissions.
                            return response;
                        }
                    }

                    if(!changeOrderReqPartsList.isEmpty()){
                        Boolean isReqPartCreatable = changeOrderReqPartDescribeResult.isCreateable(); //#defectFix-6261
                        if(isReqPartCreatable){  //#defectFix-6261
                            upsert changeOrderReqPartsList;
                            fieldChangeOrderInfo.requiredPartsList = createRequiredPartsInfo(changeOrderReqPartsList, productIdNameMap);
                        }
                        else{
                            createExceptionLogs(null, response, 'saveFieldChangeOrder', Label.COMM001_TAG142); //Value: Insufficient permission to perform the operation. Please verify the object and field level permissions.
                            return response;
                        }
                    }
                    List<SVMXC__SM_Change_Order__c> changeOrderList = [SELECT Id, LastModifiedDate FROM SVMXC__SM_Change_Order__c WHERE Id =: changeOrder.Id LIMIT 1];
                    fieldChangeOrderInfo.LastModifiedDate = String.valueOf((changeOrderList[0].LastModifiedDate).getTime());
                    response.data = fieldChangeOrderInfo;
                    response.message = Label.FCO001_TAG002; // Value: Changes saved successfully.
                }
                else{
                    createExceptionLogs(null, response, 'saveFieldChangeOrder', errorMessage); //Value: Invalid Request
                    return response;
                }
            }
            else{
                createExceptionLogs(null, response, 'saveFieldChangeOrder', Label.COMM001_TAG142); //Value: Insufficient permission to perform the operation. Please verify the object and field level permissions.
                }
        }
        catch(Exception e ){
            createExceptionLogs(e, response, 'saveFieldChangeOrder', BLANK_STRING);
        }
        
        finally {
            System.debug( LoggingLevel.INFO, 'saveFieldChangeOrder() - exit' );
        }
        return response;
    }

    /** Created By: Arpit
     * Used to get products based on the provided search keyword
     * @parameter String searchKeyword
     * @return Returns CORD_WrapperDef.FCO_Response
     */ 
    public CORD_WrapperDef.FCO_Response getSearchProductList(String searchKeyword, String requestType) {
       
        System.debug( LoggingLevel.INFO, 'getSearchProductList() - enter' );
        System.debug( LoggingLevel.INFO, searchKeyword);       
        System.debug( LoggingLevel.INFO, requestType);     
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        List<CORD_WrapperDef.SearchedProduct> productWrapper = new List<CORD_WrapperDef.SearchedProduct>();
        
        try {
            List<Product2> listProducts = new List<Product2>();
            searchKeyword = '%'+String.escapeSingleQuotes(searchKeyword)+'%'; 
            searchKeyword = searchKeyword.replace('_', '\\_'); //#newFix move entire method
            Boolean isBatchLotRequest = String.isNotBlank(requestType) && requestType.equalsIgnoreCase(BATCH_LOT_REQUEST) ? true : false;
            String whereClause =  ' Name LIKE :searchKeyword';
            whereClause = isBatchLotRequest ? ' SVMXC__Stockable__c = TRUE AND (SVMXC__SM_Enable_Batch_Lot_Tracking__c = TRUE OR SVMXC__Enable_Serialized_Tracking__c = TRUE) AND ' + whereClause : whereClause;
            String fieldsToBeQueried = 'Name, toLabel(Family), toLabel(SVMXC__Product_Line__c), IsActive ';
            String queryString = 'SELECT ' + fieldsToBeQueried +' FROM Product2 WHERE '+ whereClause + ' LIMIT 500';
            for(Product2 productRecord : Database.query(queryString)){
                productWrapper.add(createProductInfo(productRecord));
            }
            response.data = productWrapper;
        }
        
        catch(Exception e ){
            createExceptionLogs(e, response, 'getSearchProductList', BLANK_STRING);
        }

        finally {
            System.debug( LoggingLevel.INFO, 'getSearchProductList() - exit' );
        }
        return response;
    }

    /** Created By: Arpit
     * Used to get products based on the provided search keyword
     * @parameter String searchKeyword
     * @return Returns CORD_WrapperDef.FCO_Response
     */ 
    public CORD_WrapperDef.FCO_Response getRequiredParts(String searchKeyword) { 

        System.debug( LoggingLevel.INFO, 'getRequiredParts() - enter' );
        System.debug( LoggingLevel.INFO, searchKeyword);       

        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        List<CORD_WrapperDef.RequiredParts> productWrapper = new List<CORD_WrapperDef.RequiredParts>();
        
        try {
            List<Product2> listProducts = new List<Product2>();
                searchKeyword = '%' + String.escapeSingleQuotes(searchKeyword) + '%';
                searchKeyword = searchKeyword.replace('_', '\\_'); // to escape '_' character
                String queryString = 'SELECT Id,Name,Family,SVMXC__Product_Line__c,IsActive FROM Product2 WHERE Name LIKE :searchKeyWord';
                queryString = queryString + ' OR Family LIKE :searchKeyWord OR SVMXC__Product_Line__c LIKE :searchKeyWord';
            
            for(Product2 productRec : Database.query(queryString)){
                CORD_WrapperDef.RequiredParts wrapperInstance = new CORD_WrapperDef.RequiredParts();
                wrapperInstance.productId= productRec.Id;
                wrapperInstance.Name = productRec.Name;
                wrapperInstance.Family = productRec.Family;
                wrapperInstance.Line = productRec.SVMXC__Product_Line__c;
                wrapperInstance.isActive= productRec.IsActive;
               productWrapper.add(wrapperInstance);
            }
            response.data = productWrapper;
        }
        
        catch(Exception e ){
            createExceptionLogs(e, response, 'getRequiredParts', BLANK_STRING);
        }
        finally {
            System.debug( LoggingLevel.INFO, 'getRequiredParts() - exit' );
        }
        
        return response;
    }

    
    /** Created By: Arpit
     * Used to get picklist values of the given picklist fields.
     * @parameter N/A
    * @return Returns CORD_WrapperDef.FCO_Response
     */ 
    public CORD_WrapperDef.FCO_Response getPicklistValues(final String fcoSfId) {

        System.debug( LoggingLevel.INFO, 'getRequiredParts() - enter' );

        List<String> fieldAPIList = new List<String> {'SVMXC__SM_Order_Type__c','SVMXC__SM_Priority__c','SVMXC__SM_Status__c','SVMXC__SM_Delivery_Method__c'};
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        CORD_WrapperDef.PickListValues picklistValueWrapper = new CORD_WrapperDef.PickListValues ();
        try {
            //#forReview should we have isAccessible check on picklist fields
            COMM_Utils_DescribeCall describeInstance = COMM_Utils_DescribeCall.getInstance();
            Map<String,Schema.SObjectField> fieldMap = new Map<String,Schema.SObjectField> ();
            fieldMap = COMM_Utils_DescribeCall.getObjectFieldDetails(CHANGE_ORDER_OBJECT);
            for(String fieldAPIName : fieldAPIList){
                Schema.DescribeFieldResult fieldResult = fieldMap.get(fieldAPIName).getDescribe(); //describeInstance.describeField(fieldMap.get(fieldAPIName)); //#reviewComment
                    Map<String, String> picklistMap = new Map<String, String> ();
                    List<CORD_WrapperDef.KeyValuePair> keyValuePairList = new List<CORD_WrapperDef.KeyValuePair> ();
                    for( Schema.PicklistEntry pickListVal : fieldResult.getPicklistValues()){
                        picklistMap.put(pickListVal.getLabel(), pickListVal.getValue());
                    }  

                    keyValuePairList = sortMapByKey(picklistMap);

                    if(fieldAPIName.equalsIgnoreCase('SVMXC__SM_Order_Type__c')){
                        picklistValueWrapper.orderTypePicklist = keyValuePairList;
                    }
                    else if(fieldAPIName.equalsIgnoreCase('SVMXC__SM_Priority__c')){
                        picklistValueWrapper.priorityPicklist = keyValuePairList;
                    }
                    else if(fieldAPIName.equalsIgnoreCase('SVMXC__SM_Status__c')){
                        picklistValueWrapper.statusPicklist = keyValuePairList;
                    }
                    else if(fieldAPIName.equalsIgnoreCase('SVMXC__SM_Delivery_Method__c')){
                        picklistValueWrapper.deliveryMethodPicklist = keyValuePairList;
                    }

            }
            picklistValueWrapper.fcoConfigurationList = getFCOConfigurationTemplates(fcoSfId);
            response.data = picklistValueWrapper;
        }   
        
        catch(Exception e ){
            createExceptionLogs(e, response, 'getPicklistValues', BLANK_STRING);
           }
        finally {
            System.debug( LoggingLevel.INFO, 'getPicklistValues() - exit' );
        }
        return response;
    }

    /** Created By: Arpit
     * Used to delete FCO record
     * @parameter String fcoSfId
     * @return Returns CORD_WrapperDef.FCO_Response
     */ 
    public CORD_WrapperDef.FCO_Response deleteFieldChangeOrderRecords(final String fcoSfId) {

        System.debug( LoggingLevel.INFO, 'deleteFieldChangeOrderRecords() - enter' );
        System.debug( LoggingLevel.INFO, fcoSfId);   

        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
            if(isCODeletable){ //#forReview, we can perform it on M in M-D Relationship
                //if(COMM_SecurityUtils.getInstance().isDeletableObject(CHANGE_ORDER_OBJECT)){ //#forReview, we can perform it on M in M-D Relationship
                // to do, need to ask : do we need to delete all other related stuff as well,
                // lets say a batch process is running for search results or work order generation
                // do we need to terminate those or let it run
                // #toDo need to delted search records
                
                List<SVMXC__SM_Change_Order__c> changeOrderList = [SELECT Id FROM SVMXC__SM_Change_Order__c WHERE Id =: fcoSfId];
                if(!changeOrderList.isEmpty()){
                    if(!isFCOBatchRunning(fcoSfId)){
                        delete [SELECT Id FROM SVMXC__SM_Change_Order__c WHERE Id IN : changeOrderList];
                        response.message = Label.FCO001_TAG001; // Value: FCO Deleted Successfully
                    }
                    else{
                        createExceptionLogs(null, response, 'deleteFieldChangeOrderRecords', Label.FCO001_TAG023); // Value: 'A batch process for this change order already is in progress.Please try after some time.'
                    }
                }
                else{
                    createExceptionLogs(null, response, 'deleteFieldChangeOrderRecords', Label.FCO001_TAG003); // Value : Insufficient permission to access this record or record does not exist.
                }
            }
            else{
                createExceptionLogs(null, response, 'saveFieldChangeOrder', Label.COMM001_TAG142); //Value: Insufficient permission to perform the operation. Please verify the object and field level permissions.
            }
        }
        catch(Exception e ){
            createExceptionLogs(e, response, 'deleteFieldChangeOrderRecords', BLANK_STRING);
        }

        finally {
            System.debug( LoggingLevel.INFO, 'deleteFieldChangeOrderRecords() - exit' );
        }
        
        return response;
    }

    /** Created By: Arpit
     * Used to clone FCO Record
     * @parameter String fcoSfId
     * @return Returns CORD_WrapperDef.FCO_Response
     */ 
    public CORD_WrapperDef.FCO_Response cloneFieldChangeOrderRecord(final String fcoSfId) {

        System.debug( LoggingLevel.INFO, 'cloneFieldChangeOrderRecord() - enter' );
        System.debug( LoggingLevel.INFO, fcoSfId);   

        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
            isCloneRequest = true;
            response = getFieldChangeOrder(fcoSfId);
            if(response.success){ //#reviewComment
                CORD_WrapperDef.FieldChangeOrderInfo fieldChangeOrderInfoWrapper = (CORD_WrapperDef.FieldChangeOrderInfo) response.data;
                // check if configuration template is still applicable to user group profile
                if(String.isNotBlank(fieldChangeOrderInfoWrapper.fcoConfiguration) && !isValidConfigTempalte(fieldChangeOrderInfoWrapper.fcoConfiguration)){
                    fieldChangeOrderInfoWrapper.fcoConfiguration = NULL;
                }
                response.data = fieldChangeOrderInfoWrapper;
            }
        }   
        
        catch(Exception e ){
            createExceptionLogs(e, response, 'cloneFieldChangeOrderRecord', BLANK_STRING);
        }

        finally {
            System.debug( LoggingLevel.INFO, 'cloneFieldChangeOrderRecord() - exit' );
        }
        return response;
    }

    /** Created By: Arpit
     * Used to map fields for change order record
     * @parameter CORD_WrapperDef.fieldChangeOrderInfo fieldChangeOrderInfo
     * @return SVMXC__SM_Change_Order__c
     */ 
    @testvisible 
    private SVMXC__SM_Change_Order__c createChangeOrderRecord(final CORD_WrapperDef.fieldChangeOrderInfo fieldChangeOrderInfo){
        Boolean isNewChangeOrder = isNewChangeOrder(fieldChangeOrderInfo);
        SVMXC__SM_Change_Order__c changeOrder = isNewChangeOrder ? new SVMXC__SM_Change_Order__c(SVMXC__SM_Change_Order_Id__c =  createUniqueChangeOrderId(fieldChangeOrderInfo.fcoName)) : new SVMXC__SM_Change_Order__c(Id = fieldChangeOrderInfo.fcoSfId);
       
        changeOrder.SVMXC__SM_Title__c = fieldChangeOrderInfo.fcoName;
        changeOrder.SVMXC__SM_Description__c = fieldChangeOrderInfo.description;
        changeOrder.SVMXC__SM_Priority__c = fieldChangeOrderInfo.priority;
        changeOrder.SVMXC__SM_Status__c = fieldChangeOrderInfo.status;
        changeOrder.SVMXC__SM_Start_Date__c = fieldChangeOrderInfo.startDate;
        changeOrder.SVMXC__SM_Due_Date__c = fieldChangeOrderInfo.dueDate;
        changeOrder.SVMXC__SM_Order_Type__c = fieldChangeOrderInfo.fcoType;
        changeOrder.SVMXC__SM_Delivery_Method__c = fieldChangeOrderInfo.deliveryMethod;
        changeOrder.SVMXC__SM_Top_Level_IBs_Only__c = fieldChangeOrderInfo.searchTopLevelIBOnly != NULL ? fieldChangeOrderInfo.searchTopLevelIBOnly : false;
        changeOrder.SVMXC__SM_Decision_Date__c = fieldChangeOrderInfo.decisionDate;
        changeOrder.SVMXC__SM_CORD_Config__c = fieldChangeOrderInfo.fcoConfiguration;
        changeOrder.SVMXC__SM_Notify_CORD_Owner__c = fieldChangeOrderInfo.notifyFCOOwner != NULL ? fieldChangeOrderInfo.notifyFCOOwner : false;
        return changeOrder;
    }

    /** Created By: Arpit
     * Used to get all fields information of requested object
     * @parameter String objectName
     * @return CORD_WrapperDef.FCO_Response
     */
    public CORD_WrapperDef.FCO_Response hasFcoHeaderUpdated(final String fcoSfId, final String lmdTimeStamp) {
        System.debug( LoggingLevel.INFO, 'hasFcoHeaderUpdated() - enter' );
        System.debug( LoggingLevel.INFO, fcoSfId);   
        System.debug( LoggingLevel.INFO, lmdTimeStamp);   

        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();

        try {
            List<SVMXC__SM_Change_Order__c> changeOrderList = new List<SVMXC__SM_Change_Order__c> ([SELECT Id, LastModifiedDate FROM SVMXC__SM_Change_Order__c WHERE Id =: fcoSfId LIMIT 1]);
            if(!changeOrderList.isEmpty()){
                String latestLMD = String.valueOf(changeOrderList[0].LastModifiedDate.getTime());
                Boolean isHeaderModified = lmdTimeStamp.equalsIgnoreCase(latestLMD) ? false : true;
                Map<String, Boolean> responseData = new Map<String, Boolean> {'isHeaderModified' => isHeaderModified};
                response.data = responseData;
             }
             else{
                createExceptionLogs(null, response, 'hasFcoHeaderUpdated',  Label.FCO001_TAG027); // Value: Invalid Request
            }
        }   
        
        catch(Exception e ){
                createExceptionLogs(e, response, 'hasFcoHeaderUpdated', BLANK_STRING);
        }

        finally {
            System.debug( LoggingLevel.INFO, 'hasFcoHeaderUpdated() - exit' );
        }
        return response;

    }
    
    /** Created By: Arpit
     * Used to get all fields information of requested object
     * @parameter String objectName
     * @return CORD_WrapperDef.FCO_Response
     */ 
    public CORD_WrapperDef.FCO_Response getFieldsInfo(String objectName) {

        System.debug( LoggingLevel.INFO, 'getFieldsInfo() - enter' );
        System.debug( LoggingLevel.INFO, objectName);   
                    
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        CORD_WrapperDef.UserPreference userPreference = new CORD_WrapperDef.UserPreference();
        Set<String> ignoredFieldSet = new Set<String> {'Id','SystemModstamp', 'LastActivityDate', 'LastViewedDate', 'LastReferencedDate', 'IsDeleted'};
        Set<String> ignoredFieldType = new Set<String> {'TIME', 'ENCRYPTEDSTRING', 'LOCATION', 'TEXTAREA'};
        Map<String,String> standardFieldsMap = new Map<String, String> {'OwnerId'=> 'Owner Name', 'CreatedById'=>'Created By Name', 'LastModifiedById'=>'Last Modified By Name'};
        Boolean isChangeOrderObject = objectName.equalsIgnoreCase(CHANGE_ORDER_OBJECT) ? true : false;
        Boolean isFCOLineObject = objectName.equalsIgnoreCase(FCO_LINE_OBJECT) ? true : false;
        Boolean isWorkOrderObject = objectName.equalsIgnoreCase(WORK_ORDER_OBJECT) ? true : false;
        Boolean isInstalledProductObj = objectName.equalsIgnoreCase(INSTALLED_PRODUCT_OBJECT) ? true : false;
       try {
                COMM_Utils_DescribeCall describeInstance = COMM_Utils_DescribeCall.getInstance();
                Map<String, Schema.SObjectField> fieldMap = COMM_Utils_DescribeCall.getObjectFieldDetails(objectName);
                Map<String, CORD_WrapperDef.FCOFieldInfo> fieldNameInfoMap = new Map<String, CORD_WrapperDef.FCOFieldInfo> ();
                Map<String, String> fieldNameInfoMapUpperCase = new Map<String, String> (); // this map is used to do sorting on field labels.
                Map<String, CORD_WrapperDef.FCOFieldInfo> apiNameFieldInfoMap = new Map<String, CORD_WrapperDef.FCOFieldInfo> ();
                
                // Iterate through the fields of object to collect available fields and already selected fields
                for(Schema.SObjectField sfield : fieldMap.Values())
                {
                    CORD_WrapperDef.FCOFieldInfo fieldInfoWrapper = new CORD_WrapperDef.FCOFieldInfo();
                    fieldInfoWrapper.picklistMap = new Map<String, List<CORD_WrapperDef.KeyValuePair>> ();
                    Schema.DescribeFieldResult fieldResult = sfield.getDescribe(); 
                    fieldInfoWrapper.fieldType = String.valueOf(fieldResult.getType());
                    fieldInfoWrapper.fieldName = fieldResult.getname();
                    // this logic is to identify if change order header is having any custom field apart from managed one, so that we can show
                    // link to update custom fields on header on fco detail screen
                    if(!isFcoHeaderHasCustomField && isChangeOrderObject){
                        if(!fieldInfoWrapper.fieldName.startsWithIgnoreCase('SVMXC__') && fieldInfoWrapper.fieldName.endsWithIgnoreCase('__c')){
                            isFcoHeaderHasCustomField = true;
                        }
                    }
                    if(fieldResult.isAccessible() && !ignoredFieldType.contains(fieldInfoWrapper.fieldType) && !ignoredFieldSet.contains(fieldInfoWrapper.fieldName)){
                        fieldInfoWrapper.fieldLabel = fieldResult.getLabel();
                        if(fieldInfoWrapper.fieldType == 'REFERENCE'){
                            fieldInfoWrapper.fieldLabel = !standardFieldsMap.containsKey(fieldInfoWrapper.fieldName) ? fieldResult.getLabel() :standardFieldsMap.get(fieldInfoWrapper.fieldName);
                            String relationshipName = fieldResult.relationshipName;
                            String referenceObjName = fieldResult.getReferenceTo()[0].getDescribe().getName();
                            fieldInfoWrapper.displayName = stdObjectFieldMap.containsKey(referenceObjName) ? relationshipName + '.' + stdObjectFieldMap.get(referenceObjName) : relationshipName + '.Name';
                        }
                        // for search expression tab we need picklist drop down for installed product object
                        else if(isInstalledProductObj && (fieldInfoWrapper.fieldType == 'PICKLIST' || fieldInfoWrapper.fieldType == 'MULTIPICKLIST')){
                            List<CORD_WrapperDef.KeyValuePair> keyValuePairList = new List<CORD_WrapperDef.KeyValuePair> ();
                            Map<String, String> picklistMap = new Map<String, String> ();
                            Map<String, List<CORD_WrapperDef.KeyValuePair>> picklistFieldMap = new  Map<String, List<CORD_WrapperDef.KeyValuePair>> ();
                            for( Schema.PicklistEntry pickListVal : fieldResult.getPicklistValues()){
                                picklistMap.put(pickListVal.getLabel(), pickListVal.getValue());
                            }  
                            fieldInfoWrapper.picklistMap.put(fieldInfoWrapper.fieldName, sortMapByKey(picklistMap));
                        }

                        // we need to explicity set excluded field label for fco line search result page for columns
                        if(isFCOLineObject && fieldInfoWrapper.fieldName.equalsIgnoreCase('SVMXC__SM_Generate_WORD__c')){
                            fieldInfoWrapper.fieldLabel =  Label.FCO001_TAG032; // FCO001_TAG032: Excluded
                        }

                        fieldNameInfoMap.put(fieldInfoWrapper.fieldLabel, fieldInfoWrapper);
                        fieldNameInfoMapUpperCase.put(fieldInfoWrapper.fieldLabel.toUpperCase(),fieldInfoWrapper.fieldLabel);
                        apiNameFieldInfoMap.put(fieldInfoWrapper.fieldName, fieldInfoWrapper);
                    }
                }      
                
                if(isWorkOrderObject){
                    for(CORD_WrapperDef.FCOFieldInfo fieldWrapper : getAdditionalFieldsForWokrOrder()){
                        fieldNameInfoMap.put(fieldWrapper.fieldLabel, fieldWrapper);
                        fieldNameInfoMapUpperCase.put(fieldWrapper.fieldLabel.toUpperCase(), fieldWrapper.fieldLabel);
                        apiNameFieldInfoMap.put(fieldWrapper.fieldName, fieldWrapper);
                    }
                }

                // get User configured columns
                if(!isInstalledProductObj){ // we need user configuration for fco line, change order and work order object but not in installed product because we don't store user config for IB
                    SVMXC__SM_User_Preferences__c userPrefRecord = getUserPreference();
                   userPreference.userPrefId = userPrefRecord != NULL ? userPrefRecord.Id : NULL;
                    userPreference.selectedColumns = getConfiguredColumns(userPrefRecord , apiNameFieldInfoMap, objectName);
                    objConfigColumns = userPreference.selectedColumns;
                }  
                
                userPreference.availableColumns = getSortedFields(fieldNameInfoMap, fieldNameInfoMapUpperCase);
                userPreference.fieldTypeWithOperators = isInstalledProductObj ? createFieldTypeOperatorMap(fieldTypeOperatorMap) : NULL; // we need fieldTypeWithOperators for installed base product screen for search search expression building
                response.data = userPreference;
            }
        
        catch(Exception e ){
            createExceptionLogs(e, response, 'getFieldsInfo', BLANK_STRING);
        }

        finally {
            System.debug( LoggingLevel.INFO, 'getFieldsInfo() - exit' );
        }

        return response;    
    }

    /** Created By: Arpit
     * Used to identify whether config template is valid, used when we clone existing fco record because may be auto populated config template is no longer valid for user's group profile now
     * @parameter String objectName
     * @return CORD_WrapperDef.FCO_Response
     */ 
    private boolean isValidConfigTempalte(String templateId){
        Boolean isValid = true;
        Set<Id> configurationTempIds = new Set<Id> ();
        SVMXC__ServiceMax_Config_Data__c userProfileConfigData = getSmaxProfileOfUser();
        if(userProfileConfigData != NULL){
            for(SVMXC__ServiceMax_Config_Data__c configData : [SELECT  SVMXC__SM_CORD_Config__c, SVMXC__SM_CORD_Config__r.Name, SVMXC__SM_CORD_Config__r.SVMXC__SM_Name__c FROM SVMXC__ServiceMax_Config_Data__c WHERE RecordType.DeveloperName =: CHANGE_ORDER_ACCESS_RT AND SVMXC__Access_Configuration_Profile__c =: userProfileConfigData.SVMXC__Access_Configuration_Profile__c AND SVMXC__SM_CORD_Config__r.SVMXC__SM_Active__c = TRUE ]){
                configurationTempIds.add(configData.SVMXC__SM_CORD_Config__c);
            }
        }
        if(!configurationTempIds.contains(templateId)){
            isValid = false;
        }
       return isValid;
    }

    /** Created By: Arpit
     * Used to get list of available configuration templates
     * @parameter String fcoSfId
     * @return List<CORD_WrapperDef.KeyValuePair>
     */ 
    private List<CORD_WrapperDef.KeyValuePair> getFCOConfigurationTemplates(String fcoSfId){
        List<CORD_WrapperDef.KeyValuePair> keyValuePairList = new List<CORD_WrapperDef.KeyValuePair> ();
        Map<String, String> picklistMap = new Map<String, String> ();
        Set<Id> configurationTempIds = new Set<Id> ();

        // step 1: get user's servicemax profile
        SVMXC__ServiceMax_Config_Data__c userProfileConfigData = getSmaxProfileOfUser();

        // step 2: get all the configuration where it is included
        if(userProfileConfigData != NULL){
            for(SVMXC__ServiceMax_Config_Data__c configData : [SELECT  SVMXC__SM_CORD_Config__c, SVMXC__SM_CORD_Config__r.Name, SVMXC__SM_CORD_Config__r.SVMXC__SM_Name__c FROM SVMXC__ServiceMax_Config_Data__c WHERE RecordType.DeveloperName =: CHANGE_ORDER_ACCESS_RT AND SVMXC__Access_Configuration_Profile__c =: userProfileConfigData.SVMXC__Access_Configuration_Profile__c AND SVMXC__SM_CORD_Config__r.SVMXC__SM_Active__c = true ]){
                picklistMap.put(configData.SVMXC__SM_CORD_Config__r.SVMXC__SM_Name__c, configData.SVMXC__SM_CORD_Config__c);
                configurationTempIds.add(configData.SVMXC__SM_CORD_Config__c);
            }
            if(String.isNotBlank(fcoSfId) && !isCloneRequest){
                SVMXC__SM_Change_Order__c changeOrder = getFCOConfigTemplateDetails(fcoSfId);
                if(changeOrder != NULL && !configurationTempIds.contains(changeOrder.SVMXC__SM_CORD_Config__c)){
                    picklistMap.put(changeOrder.SVMXC__SM_CORD_Config__r.SVMXC__SM_Name__c, changeOrder.SVMXC__SM_CORD_Config__c);
                }
            }
            keyValuePairList = sortMapByKey(picklistMap);
        }
        return keyValuePairList;  
    }

     /** Created By: Arpit
     * Used to validate fco request
     * @parameter CORD_WrapperDef.FieldChangeOrderInfo fieldChangeOrderInfo
     * @return Boolean
     */ 
    @testvisible
    private Boolean isValidFcoRequest(final CORD_WrapperDef.FieldChangeOrderInfo fieldChangeOrderInfo){
        Boolean isValidRequest = true;
        if(String.isBlank(fieldChangeOrderInfo.fcoName) || String.isBlank(fieldChangeOrderInfo.fcoConfiguration)){
            isValidRequest = false;
            errorMessage = Label.FCO001_TAG028 + '<br/>'; // value: Please fill the mandatory fields.
        }
        if((String.isNotBlank(String.valueOf(fieldChangeOrderInfo.startDate)) && (String.isNotBlank(String.valueOf(fieldChangeOrderInfo.decisionDate)) && fieldChangeOrderInfo.decisionDate < fieldChangeOrderInfo.startDate))){
            isValidRequest = false;
            errorMessage += Label.FCO001_TAG029 + '<br/>'; // value: Decision Date can not be prior to start date.
        }
        if((String.isNotBlank(String.valueOf(fieldChangeOrderInfo.startDate)) && (String.isNotBlank(String.valueOf(fieldChangeOrderInfo.dueDate)) && fieldChangeOrderInfo.dueDate < fieldChangeOrderInfo.startDate))){
            isValidRequest = false;
            errorMessage += Label.FCO001_TAG030 + '<br/>'; // value: Due Date can not be prior to start date.
        }
        List<CORD_WrapperDef.RequiredParts> requiredPartsList = fieldChangeOrderInfo.requiredPartsList;
        if(requiredPartsList != NULL && !requiredPartsList.isEmpty()){
            isValidRequest = isValidRequest && isValidReqPartsRequest(requiredPartsList);
        }
        if(isValidRequest && String.isNotBlank(fieldChangeOrderInfo.fcoSfId)){ // don't allow fco to be saved if any batch is running for the provided fco
            Boolean isBatchRunning = isFCOBatchRunning(fieldChangeOrderInfo.fcoSfId);
            errorMessage = isBatchRunning ?  Label.FCO001_TAG023 : BLANK_STRING;  //Label.FCO001_TAG023:  Value: 'A batch process for this change order already is in progress.Please try after some time.'
            isValidRequest = !isBatchRunning;
        }
       return isValidRequest;
    }

     /** Created By: Arpit
     * Used to identify if request is for new change order or old record
     * @parameter CORD_WrapperDef.FieldChangeOrderInfo fieldChangeOrderInfo
     * @return Boolean
     */ 
    private Boolean isNewChangeOrder(final CORD_WrapperDef.FieldChangeOrderInfo fieldChangeOrderInfo ) {
        return String.isBlank(fieldChangeOrderInfo.fcoSfId) ? true : false;
    }

     /** Created By: Arpit
     * Used to validate required parts request
     * @parameter List<CORD_WrapperDef.RequiredParts>  requiredPartsList
     * @return Boolean
     */ 
    @testvisible
    private Boolean isValidReqPartsRequest(final List<CORD_WrapperDef.RequiredParts>  requiredPartsList){
        Boolean isValidRequest = true;
        for(CORD_WrapperDef.RequiredParts reqPart : requiredPartsList){
            if(reqPart.quantity == NULL || reqPart.quantity <= 0 || reqPart.productId == NULL){
                isValidRequest = false;
                errorMessage = Label.FCO001_TAG074 + '<br/>'; // Value: Required Parts request is not valid.
                break;
            }
        }
        return isValidRequest;
    }

    /** Created By: Arpit
     * Used to create exception logs
     * @parameter Exception e, CORD_WrapperDef.FCO_Response response, String methodName, String customErrorMsg
     * @return void
     */ 
    @testvisible 
    private void createExceptionLogs(Exception e, CORD_WrapperDef.FCO_Response response, String methodName, String customErrorMsg){
        response.success = false;
        response.message = String.isBlank(customErrorMsg) ? e.getMessage() : customErrorMsg;
        if(e != null){
            System.debug('Error==>'+ e.getMessage());
            System.debug( LoggingLevel.ERROR, methodName + ' Failed;  Error=' + e.getStackTraceString() );
        } 
        if(sp != null){
            Database.rollback(sp);
        }   
    }

    /** Created By: Arpit
     * Used to create wrapper for change order record
     * @parameter SVMXC__SM_Change_Order__c changeOrder
     * @return CORD_WrapperDef.FieldChangeOrderInfo
     */ 
    @testvisible 
    private CORD_WrapperDef.FieldChangeOrderInfo createChangeOrderHeaderInfo(final SVMXC__SM_Change_Order__c changeOrder){ 
        CORD_WrapperDef.FieldChangeOrderInfo fieldChangeOrderInfoWrapper = new CORD_WrapperDef.FieldChangeOrderInfo();
        fieldChangeOrderInfoWrapper.fcoName = isCloneRequest ? Label.FCO001_TAG006 + SPACE + changeOrder.SVMXC__SM_Title__c : changeOrder.SVMXC__SM_Title__c;
        fieldChangeOrderInfoWrapper.description = changeOrder.SVMXC__SM_Description__c;
        fieldChangeOrderInfoWrapper.priority = changeOrder.SVMXC__SM_Priority__c;
        fieldChangeOrderInfoWrapper.status = isCloneRequest ? FCO_STATUS_DRAFT : changeOrder.SVMXC__SM_Status__c;
        fieldChangeOrderInfoWrapper.startDate =  changeOrder.SVMXC__SM_Start_Date__c;
        fieldChangeOrderInfoWrapper.dueDate = changeOrder.SVMXC__SM_Due_Date__c;
        fieldChangeOrderInfoWrapper.fcoType = changeOrder.SVMXC__SM_Order_Type__c;
        fieldChangeOrderInfoWrapper.decisionDate = changeOrder.SVMXC__SM_Decision_Date__c;
        fieldChangeOrderInfoWrapper.deliveryMethod = changeOrder.SVMXC__SM_Delivery_Method__c;
        fieldChangeOrderInfoWrapper.searchTopLevelIBOnly = changeOrder.SVMXC__SM_Top_Level_IBs_Only__c;
        fieldChangeOrderInfoWrapper.fcoSfId = isCloneRequest ? BLANK_STRING : changeOrder.Id;
        fieldChangeOrderInfoWrapper.fcoConfiguration = changeOrder.SVMXC__SM_CORD_Config__c;
        fieldChangeOrderInfoWrapper.notifyFCOOwner = changeOrder.SVMXC__SM_Notify_CORD_Owner__c;
        fieldChangeOrderInfoWrapper.criteriaAdvancedExpression = changeOrder.SVMXC__SM_Criteria_Advanced_Expression__c;
        fieldChangeOrderInfoWrapper.LastModifiedDate = isCloneRequest ? NULL : String.valueOf((changeOrder.LastModifiedDate).getTime());
        return fieldChangeOrderInfoWrapper;
    }

    /** Created By: Arpit
     * Used to create wrapper for required parts record
     * @parameter List<SVMXC__SM_Change_Order_Parts__c> requiredParts
     * @return List<CORD_WrapperDef.RequiredParts>
     */ 
    @testvisible 
    private List<CORD_WrapperDef.RequiredParts> createRequiredPartsInfo(final List<SVMXC__SM_Change_Order_Parts__c> requiredParts){
        List<CORD_WrapperDef.RequiredParts> requiredPartsList = new List<CORD_WrapperDef.requiredParts> ();
        for(SVMXC__SM_Change_Order_Parts__c requiredPart : requiredParts){ 
           CORD_WrapperDef.RequiredParts requiredPartWrapper = new CORD_WrapperDef.RequiredParts();
           requiredPartWrapper.productId = requiredPart.SVMXC__SM_Product__c;
           requiredPartWrapper.Name = requiredPart.SVMXC__SM_Product__r.Name;
           requiredPartWrapper.quantity = requiredPart.SVMXC__SM_Quantity__c;
           requiredPartWrapper.sfId = isCloneRequest ? BLANK_STRING : requiredPart.Id;
           requiredPartsList.add(requiredPartWrapper);
        }
        return requiredPartsList;
    }

    /** Created By: Arpit
     * Used to create wrapper for required parts record
     * @parameter List<SVMXC__SM_Change_Order_Parts__c> requiredParts, Map<Id, String> productIdNameMap
     * @return List<CORD_WrapperDef.RequiredParts>
     */ 
    @testvisible 
    private List<CORD_WrapperDef.RequiredParts> createRequiredPartsInfo(final List<SVMXC__SM_Change_Order_Parts__c> requiredParts, Map<Id, String> productIdNameMap){
        List<CORD_WrapperDef.RequiredParts> requiredPartsList = new List<CORD_WrapperDef.requiredParts> ();
        for(SVMXC__SM_Change_Order_Parts__c requiredPart : requiredParts){
           CORD_WrapperDef.RequiredParts requiredPartWrapper = new CORD_WrapperDef.RequiredParts();
           requiredPartWrapper.productId = requiredPart.SVMXC__SM_Product__c;
           requiredPartWrapper.Name = productIdNameMap.get(requiredPart.SVMXC__SM_Product__c);
           requiredPartWrapper.quantity = requiredPart.SVMXC__SM_Quantity__c;
           requiredPartWrapper.sfId = requiredPart.Id;
           requiredPartsList.add(requiredPartWrapper);
        }
        return requiredPartsList;
    }

    /** Created By: Arpit
     * Used to get associated group profile of user
     * @parameter N/A
     * @return SVMXC__ServiceMax_Config_Data__c
     */ 
    @testvisible 
    private static SVMXC__ServiceMax_Config_Data__c  getSmaxProfileOfUser(){ //#reviewComment to be asked from Ram, if we can cache this info in cache
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = [SELECT Id, SVMXC__Profile__c, SVMXC__Access_Configuration_Profile__c FROM SVMXC__ServiceMax_Config_Data__c 
                                                                    WHERE SVMXC__RecordType_Name__c = 'Configuration Access' AND SVMXC__Profile__c =: UserInfo.getProfileId()  AND SVMXC__Access_Configuration_Profile__c != NULL AND SVMXC__Access_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Group'];
        return  !configDataList.isEmpty() ? configDataList[0] : NULL;                                  
    }

    /** Created By: Arpit
     * Used to create unique change order id
     * @parameter N/A
     * @return SVMXC__ServiceMax_Config_Data__c
     */ 
    @testvisible
    private String createUniqueChangeOrderId(String fcoName){
        return (fcoName.normalizeSpace().left(40)+DateTime.now().getTime()).replace(' ','_');
    }

    /** Created By: Arpit
     * Used to sort map based on the key
     * @parameter Map<String, String> picklistMap
     * @return List<CORD_WrapperDef.KeyValuePair>
     */ 
    @testvisible
    private List<CORD_WrapperDef.KeyValuePair> sortMapByKey(Map<String, String> picklistMap){
        List<CORD_WrapperDef.KeyValuePair> keyValuePairList = new List<CORD_WrapperDef.KeyValuePair> ();
        List<String> keyList = new List<String> (picklistMap.keySet());
        keyList.sort();
        
        for(String key : keyList){
            CORD_WrapperDef.KeyValuePair pickListEntryWrappper = new CORD_WrapperDef.KeyValuePair();
            pickListEntryWrappper.key = key;
           pickListEntryWrappper.value = picklistMap.get(key);
            keyValuePairList.add(pickListEntryWrappper); 
        }
        return keyValuePairList;
    }

    /** Created By: Arpit
     * Used to get user preference record
     * @parameter N/A
     * @return SVMXC__SM_User_Preferences__c
     */ 
    @testvisible 
    private SVMXC__SM_User_Preferences__c getUserPreference(){
        System.debug( LoggingLevel.INFO, 'getUserPreference() - enter' );
        List<SVMXC__SM_User_Preferences__c> userPrefRecord = [SELECT SVMXC__SM_Configured_Columns__c FROM SVMXC__SM_User_Preferences__c WHERE SVMXC__SM_User_Reference_Id__c =: UserInfo.getUserId() AND SVMXC__SM_Type__c =: USER_PREF_TYPE_FCO limit 1];
        return !userPrefRecord.isEmpty() ? userPrefRecord[0] : NULL;
    }

    /** Created By: Arpit
     * Used to save user preference
     * @parameter CORD_WrapperDef.UserPreference userPreference
     * @return  CORD_WrapperDef.FCO_Response
     */ 
    public CORD_WrapperDef.FCO_Response saveUserPreference(final CORD_WrapperDef.UserPreference userPreference){

        System.debug( LoggingLevel.INFO, 'saveUserPreference() - enter' );
        System.debug( LoggingLevel.INFO, userPreference);
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        CORD_WrapperDef.FCOFieldInfoWrapper configuredColumns = new CORD_WrapperDef.FCOFieldInfoWrapper();
        Map<String, List<CORD_WrapperDef.FCOFieldInfo>> userPrefMap = new Map<String, List<CORD_WrapperDef.FCOFieldInfo>> ();
        Map<String, Object> objectNameConfigColsMap = new Map<String, Object> ();
        try{
            Boolean isNewUserPref = String.isBlank(userPreference.userPrefId) ? true : false;
            SVMXC__SM_User_Preferences__c userPrefRecord = isNewUserPref ? new SVMXC__SM_User_Preferences__c(SVMXC__SM_Type__c = USER_PREF_TYPE_FCO, SVMXC__SM_User_Reference_Id__c = UserInfo.getUserId()) : new SVMXC__SM_User_Preferences__c(Id = userPreference.userPrefId);
            
            if(!isNewUserPref){ // query existing User Preference Record and update the configured columns
                SVMXC__SM_User_Preferences__c existingUserPref = [SELECT SVMXC__SM_Configured_Columns__c FROM SVMXC__SM_User_Preferences__c WHERE Id =: userPreference.userPrefId LIMIT 1];
                objectNameConfigColsMap =  (Map<String, Object>) JSON.deserializeUntyped(existingUserPref.SVMXC__SM_Configured_Columns__c);
                objectNameConfigColsMap.put(userPreference.objectName, JSON.serialize(userPreference.selectedColumns));
            }
            else{ // create new map entry for new user preference record for the requested object name
                objectNameConfigColsMap.put(userPreference.objectName, JSON.serialize(userPreference.selectedColumns));
            }

            userPrefRecord.SVMXC__SM_Configured_Columns__c = JSON.serialize(objectNameConfigColsMap); // serialize the columns setting and assign it to SVMXC__SM_Configured_Columns__c
            upsert userPrefRecord;
            response.message = Label.FCO001_TAG002; // Value: changes saved successfully.
        }
        catch(Exception e ){
            createExceptionLogs(e, response, 'saveUserPreference', Label.FCO001_TAG004); // Value: Error occurred while saving the record.
        }
        
        finally {
            System.debug( LoggingLevel.INFO, 'saveUserPreference() - exit' );
        }
        return response;
    }

    /** Created By: Arpit
     * Used to create new work orders
     * @parameter fcoSfId
     * @return  CORD_WrapperDef.FCO_Response
     */ 
    public CORD_WrapperDef.FCO_Response createWorkOrders(final String fcoSfId){
        System.debug( LoggingLevel.INFO, 'createWorkOrders() - enter' );
        System.debug( LoggingLevel.INFO, fcoSfId);

        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        Boolean isWorkOrderCreatable = getGlobalDescribe().get(WORK_ORDER_OBJECT).getDescribe().isCreateable();
        Boolean isBatchRunning = isFCOBatchRunning(fcoSfId);
        try{
            if(!isBatchRunning && isWorkOrderCreatable){
                SVMXC__SM_Change_Order__c changeOrder = getFCOConfigTemplateDetails(fcoSfId); // #TODO Change the name to say getChangeOrderDetails
                if(!Test.isRunningTest() && (changeOrder.SVMXC__SM_CORD_Config__c == NULL || (String.isBlank(changeOrder.SVMXC__SM_CORD_Config__r.SVMXC__SM_Process1__c) ))){
                    response.success = false;
                    response.message = changeOrder.SVMXC__SM_CORD_Config__c == NULL ? Label.FCO001_TAG072 : Label.FCO001_TAG073; 
                }
                else{
                         //#defectFix-6261 starts
                        Integer reqPartsCount = Database.countQuery('SELECT count() FROM ' + FCO_REQ_PART_OBJECT + ' WHERE SVMXC__SM_Change_Order__c =: fcoSfId');
                        if(reqPartsCount > 0){
                            Boolean isWorkDetailCreatable = getGlobalDescribe().get(WORK_DETAIL_OBJECT).getDescribe().isCreateable(); 
                            if(!isWorkDetailCreatable){
                                createExceptionLogs(null, response, 'createWorkOrders', LABEL.COMM001_TAG142); // COMM001_TAG142 Value: Insufficient permission to perform the operation. Please verify the object and field level permissions.
                                return response;
                            }
                        }
                         //#defectFix-6261 ends
                         
                        // initiate batch
                        CORD_WorkOrderBatch workOrderBatchInstance = new CORD_WorkOrderBatch(fcoSfId, changeOrder.SVMXC__SM_CORD_Config__r.SVMXC__SM_Process1__c, changeOrder.SVMXC__SM_CORD_Config__r.SVMXC__SM_Process2__c);
                        if(Test.isRunningTest() || changeOrder.SVMXC__SM_CORD_Config__c != NULL){ //#TODO Change
                            ID batchprocessid = Database.executeBatch(workOrderBatchInstance, getBatchSize('FCO001_SET002')); //#TODO batch size needs to be
                            SVMXC__SM_Change_Order_Log__c fcoLogRecord = new SVMXC__SM_Change_Order_Log__c( SVMXC__SM_Batch_Id__c = batchprocessid,
                                                                                                                SVMXC__SM_Change_Order__c = fcoSfId,
                                                                                                                SVMXC__SM_Log_Type__c = LOG_TYPE_WO_GENERATION
                                                                                                            );
                        insert fcoLogRecord;
                    }
                }                
            }
            else{
                createExceptionLogs(null, response, 'createWorkOrders', isWorkOrderCreatable ? Label.FCO001_TAG023 : Label.COMM001_TAG142); // FCO001_TAG023 Value: 'A batch process for this change order already is in progress.Please try after some time.'
            }
        }
        catch(Exception e){
            createExceptionLogs(e, response, 'createWorkOrders', BLANK_STRING);
        }
        finally {
            System.debug( LoggingLevel.INFO, 'createWorkOrders() - exit' );
        }
        return response;

    }

    /** Created By: Arpit
     * Used to get module setting
     * @parameter String moduleNumber
     * @return String
     */ 
    private static String getFCOModuleSettings(String moduleNumber){
        return new COMM_Utils_ManageSettings().SVMX_getGlobalSettingList(moduleNumber);
    }

    /** Created By: Arpit
     * Used to get Batch Size value for work order / fco lines from settings
     * @parameter String moduleNumber
     * @return Integer
     */ 
    private static Integer getBatchSize(String moduleNumber){
        Integer batchSize = moduleNumber.equalsIgnoreCase('FCO001_SET001') ? 250 : 10; // keeping 200 for fco line and 10 for work order in case setting values not found in module
        String settingValue = getFCOModuleSettings(moduleNumber);
        return String.isNotBlank(settingValue) ?  Integer.valueOf(settingValue) : batchSize;
    }

    /** Created By: Arpit
     * Used to get maximum supported fco lines value from settings
     * @parameter String moduleNumber
     * @return Integer
     */ 
    private static Integer getMaxSupportedFCOLines(String moduleNumber){
        String settingValue = getFCOModuleSettings(moduleNumber);
        return String.isNotBlank(settingValue) ? Integer.valueOf(settingValue) : 2500; // keeping 2500 as default if setting value not found
    }

    /** Created By: Arpit
     * Used to create new fco lines
     * @parameter fcoSfId
     * @return  CORD_WrapperDef.FCO_Response
     */ 
    public CORD_WrapperDef.FCO_Response createFCOLines(final String fcoSfId){
        System.debug( LoggingLevel.INFO, 'createFCOLines() - enter' );
        System.debug( LoggingLevel.INFO, fcoSfId);

        Schema.DescribeSObjectResult changeOrderLineDescribeResult = getGlobalDescribe().get(FCO_LINE_OBJECT).getDescribe(); //#defectFix-6261
        Boolean isFCOLineCreateable = changeOrderLineDescribeResult.isCreateable(); //#defectFix-6261
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try{
            if(!isFCOBatchRunning(fcoSfId) && isFCOLineCreateable){
                // initiate batch
               CORD_FCOLinesBatch fcoLineBatch = new CORD_FCOLinesBatch(fcoSfId);
                
               ID batchprocessid = Database.executeBatch(fcoLineBatch, getBatchSize('FCO001_SET001')); 

                SVMXC__SM_Change_Order_Log__c fcoLogRecord = new SVMXC__SM_Change_Order_Log__c ( SVMXC__SM_Batch_Id__c = batchprocessid,
                                                                                                    SVMXC__SM_Change_Order__c = fcoSfId,
                                                                                                    SVMXC__SM_Log_Type__c = LOG_TYPE_FCO_GENERATION
                                                                                                   );
                insert fcoLogRecord;

                // Update change order status to 'In Progress'
                List<SVMXC__SM_Change_Order__c> changeOrderList = [SELECT Id, SVMXC__SM_Status__c FROM SVMXC__SM_Change_Order__c WHERE Id =: fcoSfId AND SVMXC__SM_Status__c !=: FCO_STATUS_IN_PROGRESS ];
                if(!changeOrderList.isEmpty()){
                    update new SVMXC__SM_Change_Order__c(Id=fcoSfId, SVMXC__SM_Status__c = FCO_STATUS_IN_PROGRESS);
                }
            }
            else{
                createExceptionLogs(null, response, 'createFCOLines', isFCOLineCreateable ? Label.FCO001_TAG023 : Label.COMM001_TAG142); //# defectFix-6261 // FCO001_TAG023 Value: 'A batch process for this change order already is in progress.Please try after some time.'
            }
        }
        catch(Exception e){
            createExceptionLogs(e, response, 'createFCOLines', BLANK_STRING);
        }
        finally {
            System.debug( LoggingLevel.INFO, 'createFCOLines() - exit' );
        }
        return response;

    }

    /** Created By: Arpit
     * Used to update fco lines
     * Parameter String fcoSfId
     * @return String
     */ 
    @testvisible
    private static String getSearchResultStatus(final String fcoSfId){
        String searchResultStatus = BLANK_STRING;
        // 1. check if any change order log exist for fco line generation
        List<SVMXC__SM_Change_Order_Log__c> changeOrderLogs = [SELECT Id, SVMXC__SM_Batch_Id__c, SVMXC__SM_Completed_On__c FROM SVMXC__SM_Change_Order_Log__c WHERE SVMXC__SM_Change_Order__c =: fcoSfId AND SVMXC__SM_Log_Type__c='FCO Line Generation' order by LastModifiedDate DESC];
        if(changeOrderLogs.isEmpty()){
            searchResultStatus = BATCH_NOT_STARTED;
        }
        else{
             List<SVMXC__SM_Change_Order_Line__c> fcoLinesWithWO = new List<SVMXC__SM_Change_Order_Line__c> ();
             AsyncApexJob apexJob = getBatchDetails(changeOrderLogs[0].SVMXC__SM_Batch_Id__c);
             if(apexJob != NULL){
                String batchStatus = !Test.isRunningTest() ? apexJob.Status : batchStatusByTestClass;
                if(BATCH_QUEUED_STATUS_LIST.contains(batchStatus)){
                    searchResultStatus = BATCH_QUEUED;
                }
                else if(BATCH_IN_PROGRESS_LIST.contains(batchStatus)){
                    searchResultStatus = BATCH_IN_PROGRESS; 
                }
                else if(batchStatus.equalsIgnoreCase(BATCH_COMPLETED)){
                    // #defectFix BAC-6138
                    searchResultStatus = Database.countQuery('SELECT count() FROM ' + FCO_LINE_OBJECT + ' WHERE SVMXC__SM_Change_Order__c =: fcoSfId') > 0 ? BATCH_COMPLETED : BATCH_NOT_STARTED;
                }
                else if(batchStatus.equalsIgnoreCase(BATCH_ABORTED)){
                    searchResultStatus = BATCH_ABORTED;                       
                }
                else if(batchStatus.equalsIgnoreCase(BATCH_FAILED)){
                    searchResultStatus = BATCH_FAILED;                       
                }
            }
            else{
                    // #defectFix BAC-6138
                    searchResultStatus = Database.countQuery('SELECT count() FROM ' + FCO_LINE_OBJECT + ' WHERE SVMXC__SM_Change_Order__c =: fcoSfId') > 0 ? BATCH_COMPLETED : BATCH_NOT_STARTED;
                }
        }
        return searchResultStatus;
    }

    /** Created By: Arpit
     * Used to update fco lines
     * Parameter List<SVMXC__SM_Change_Order_Line__c> oldFCOLines, List<SVMXC__SM_Change_Order_Line__c> newFCOLines, String fcoSfId
    * @return CORD_WrapperDef.FCOFieldInfo 
     */ 
    public CORD_WrapperDef.FCO_Response updateFCOLines(final List<SVMXC__SM_Change_Order_Line__c> oldFCOLines, final List<SVMXC__SM_Change_Order_Line__c> newFCOLines, final String fcoSfId){
         System.debug( LoggingLevel.INFO, 'updateFCOLines() - enter' );
        // System.debug( LoggingLevel.INFO, fcoLines);
        sp = Database.setSavepoint();  //#defectFix-6261
        Schema.DescribeSObjectResult changeOrderLineDescribeResult = getGlobalDescribe().get(FCO_LINE_OBJECT).getDescribe(); //#defectFix-6261
        Boolean isFCOLineCreateable = changeOrderLineDescribeResult.isCreateable(); //#defectFix-6261
        Boolean isFCOLineUpdateable = changeOrderLineDescribeResult.isUpdateable(); //#defectFix-6261
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try{
             if(!isFCOBatchRunning(fcoSfId)){
                if(oldFCOLines != NULL && !oldFCOLines.isEmpty()){
                    if(isFCOLineUpdateable){ //#defectFix-6261
                        update oldFCOLines;
                    }
                    else{
                        createExceptionLogs(null, response, 'updateFCOLines', Label.COMM001_TAG142); // Value: Insufficient permission to perform the operation. Please verify the object and field level permissions.
                        return response;
                    }
                }
                if(newFCOLines != NULL && !newFCOLines.isEmpty()){
                    if(isFCOLineCreateable){ //#defectFix-6261
                        insert newFCOLines;
                    }
                    else{
                        createExceptionLogs(null, response, 'updateFCOLines', Label.COMM001_TAG142); // Value: Insufficient permission to perform the operation. Please verify the object and field level permissions.
                        return response; //#defectFix-6261
                    }
                }
                response.message = Label.FCO001_TAG002; // Value: Changes saved successfully.
             }
             else{
                 createExceptionLogs(null, response, 'updateFCOLines', Label.FCO001_TAG023); // Value: 'A batch process for this change order already is in progress.Please try after some time.'
             }
            }
        catch( Exception e ){
             createExceptionLogs(e, response, 'updateFCOLines', Label.FCO001_TAG035); // value: Error occured while updating change order lines. Please contact admin.        
        }
        finally {
            System.debug( LoggingLevel.INFO, 'updateFCOLines() - exit' );
         }      
        return response;
    }

    /** Created By: Arpit
     * Used to return field info wrapper
     * Parameter String fieldName, String fieldForLabel, String fieldType, Map<String,Schema.SObjectField> fieldMap, COMM_Utils_DescribeCall descInstance
     * @return CORD_WrapperDef.FCOFieldInfo 
     */ 
    private CORD_WrapperDef.FCOFieldInfo getFieldInfoWrapper(String fieldName, String fieldForLabel, String fieldType, String displayName, Map<String,Schema.SObjectField> fieldMap, COMM_Utils_DescribeCall descInstance){
        CORD_WrapperDef.FCOFieldInfo fieldInfoWrapper = new CORD_WrapperDef.FCOFieldInfo();
        fieldInfoWrapper.fieldName = fieldName;
        fieldInfoWrapper.fieldLabel = fieldMap.get(fieldForLabel).getDescribe().getLabel();//descInstance.describeField(fieldMap.get(fieldForLabel)).getLabel();
        fieldInfoWrapper.fieldType = fieldType;
        fieldInfoWrapper.displayName = displayName;
        return fieldInfoWrapper;
    }

     /** Created By: Arpit
     * Used to get user preferred fields for work order object
     * Parameter N/A
     * @return CORD_WrapperDef.UserPreference
     */ 
    public CORD_WrapperDef.UserPreference getUserConfigForWorkOrder(){
        CORD_WrapperDef.UserPreference userPreference = new CORD_WrapperDef.UserPreference();
        userPreference = (CORD_WrapperDef.UserPreference) getFieldsInfo(WORK_ORDER_OBJECT).data;
        if(objConfigColumns.isEmpty()){ 
            List<CORD_WrapperDef.FCOFieldInfo> validSelectedColumns = new List<CORD_WrapperDef.FCOFieldInfo> ();
            COMM_Utils_DescribeCall describeInstance = getDescribeInstance();
            Map<String,Schema.SObjectField> fieldMapWO = COMM_Utils_DescribeCall.getObjectFieldDetails(WORK_ORDER_OBJECT); 
            Map<String,Schema.SObjectField> fieldMapIB = COMM_Utils_DescribeCall.getObjectFieldDetails(INSTALLED_PRODUCT_OBJECT); 
            userPreference.userPrefId = userPreference != NULL && String.isNotBlank(userPreference.userPrefId) ? userPreference.userPrefId : NULL ;
            validSelectedColumns.add(getFieldInfoWrapper('Name', 'Name', 'STRING', null, fieldMapWO, describeInstance)); //fieldInfoWorkOrderNumber
            validSelectedColumns.add(getFieldInfoWrapper('SVMXC__Component__r.SVMXC__Serial_Lot_Number__c', 'SVMXC__Serial_Lot_Number__c', 'STRING', null, fieldMapIB, describeInstance)); //fieldInfoSerialNo
            CORD_WrapperDef.FCOFieldInfo siteInfo = getFieldInfoWrapper('SVMXC__Site__c', 'SVMXC__Site__c', 'REFERENCE', null, fieldMapWO, describeInstance);
            siteInfo.displayName = 'SVMXC__Site__r.Name';
            validSelectedColumns.add(siteInfo);
            validSelectedColumns.add(getFieldInfoWrapper('SVMXC__Order_Status__c', 'SVMXC__Order_Status__c', 'STRING', null, fieldMapWO, describeInstance)); //fieldInfoOrderStatus
            userPreference.selectedColumns = validSelectedColumns;
        }
        return userPreference;
    } 

    /** Created By: Arpit
     * Used to get user preferred fields for fco line object
     * Parameter N/A
     * @return CORD_WrapperDef.UserPreference
     */ 
    @testvisible
    private CORD_WrapperDef.UserPreference getUserConfigForSearch(){
        CORD_WrapperDef.UserPreference userPreference = new CORD_WrapperDef.UserPreference();
       
        userPreference = (CORD_WrapperDef.UserPreference) getFieldsInfo(FCO_LINE_OBJECT).data;

        if(objConfigColumns.isEmpty()){ 
            List<CORD_WrapperDef.FCOFieldInfo> validSelectedColumns = new List<CORD_WrapperDef.FCOFieldInfo> ();
            COMM_Utils_DescribeCall describeInstance = COMM_Utils_DescribeCall.getInstance();
            Map<String,Schema.SObjectField> fieldMap = COMM_Utils_DescribeCall.getObjectFieldDetails(FCO_LINE_OBJECT); 
            userPreference.userPrefId = userPreference != NULL && String.isNotBlank(userPreference.userPrefId) ? userPreference.userPrefId : NULL ;
            CORD_WrapperDef.FCOFieldInfo fieldInfoName = new CORD_WrapperDef.FCOFieldInfo();

            validSelectedColumns.add(getFieldInfoWrapper('SVMXC__SM_Installed_Product__c', 'SVMXC__SM_Installed_Product__c', 'REFERENCE', 'SVMXC__SM_Installed_Product__r.Name', fieldMap, describeInstance)); //fieldInfoIBSerialNo
            validSelectedColumns.add(getFieldInfoWrapper('SVMXC__SM_Serial_Number__c', 'SVMXC__SM_Serial_Number__c', 'STRING', null, fieldMap, describeInstance)); //fieldInfoIBSerialNo
            validSelectedColumns.add(getFieldInfoWrapper('SVMXC__SM_Batch_Lot_Number__c', 'SVMXC__SM_Batch_Lot_Number__c', 'STRING', null, fieldMap, describeInstance)); //fieldInfoIBSerialNo
            validSelectedColumns.add(getFieldInfoWrapper('SVMXC__SM_Location__c', 'SVMXC__SM_Location__c', 'STRING', null, fieldMap, describeInstance)); //fieldInfoIBSite
            
            CORD_WrapperDef.FCOFieldInfo fieldInfoGenWorkOrd = new CORD_WrapperDef.FCOFieldInfo();
            fieldInfoGenWorkOrd.fieldName = 'SVMXC__SM_Generate_WORD__c';
            fieldInfoGenWorkOrd.fieldLabel =  Label.FCO001_TAG032; // value: 'Excluded'; 
            fieldInfoGenWorkOrd.fieldType = 'BOOLEAN';
            validSelectedColumns.add(fieldInfoGenWorkOrd);

            userPreference.selectedColumns = validSelectedColumns;
        }
        return userPreference;
    } 

    /** Created By: Arpit
     * Used to get predefined fields info of Installed Product
     * Parameter N/A
     * @return CORD_WrapperDef.UserPreference
     */ 
    @testvisible
    private static CORD_WrapperDef.UserPreference getColumnsForPreviewResult(){
        CORD_WrapperDef.UserPreference userPreference = new CORD_WrapperDef.UserPreference();
        List<CORD_WrapperDef.FCOFieldInfo> validSelectedColumns = new List<CORD_WrapperDef.FCOFieldInfo> ();
        COMM_Utils_DescribeCall describeInstance = COMM_Utils_DescribeCall.getInstance();
        Map<String,Schema.SObjectField> fieldMap = COMM_Utils_DescribeCall.getObjectFieldDetails(FCO_LINE_OBJECT); 
        
        for(String fieldName : fcoLinePreviewMap.keySet()){
            CORD_WrapperDef.FCOFieldInfo fieldInfo = new CORD_WrapperDef.FCOFieldInfo();
            String fieldAPIName = fcoLinePreviewMap.get(fieldName);
            fieldInfo.fieldName = fieldName;
            fieldInfo.fieldLabel =  fieldMap.get(fieldAPIName).getDescribe().getLabel();//describeInstance.describeField(fieldMap.get(fieldAPIName)).getLabel();
            validSelectedColumns.add(fieldInfo);
        }

        userPreference.selectedColumns = validSelectedColumns;
        return userPreference;
    }


    /** Created By: Arpit
     * Used to get search result information of the fco
     * @parameter fcoSfId
     * @return  CORD_WrapperDef.FCO_Response
     */ 
    public CORD_WrapperDef.FCO_Response getSearchResultInfo(String fcoSfId){
        System.debug( LoggingLevel.INFO, 'getSearchResultInfo() - enter' );
        System.debug( LoggingLevel.INFO, fcoSfId);
      
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try{
            CORD_WrapperDef.SearchResultInfo searchResultInfo = new CORD_WrapperDef.SearchResultInfo();
            List<SVMXC__SM_Change_Order__c> changeOrderList = [SELECT SVMXC__SM_Status__c, SVMXC__SM_Top_Level_IBs_Only__c, SVMXC__SM_Criteria_Advanced_Expression__c, (select Id, SVMXC__SM_Type__c, SVMXC__SM_Object_Criteria__c, SVMXC__SM_Sequence__c, SVMXC__SM_Criteria_Definition__c from SVMXC__Change_Order_Criterias__r WHERE SVMXC__SM_Type__c != NULL ORDER BY SVMXC__SM_Sequence__c ASC) FROM SVMXC__SM_Change_Order__c WHERE Id =: fcoSfId]; //#bhupi
            if(!changeOrderList.isEmpty()){
                SVMXC__SM_Change_Order__c changeOrder = changeOrderList[0];
                String searchResultStatus = getSearchResultStatus(fcoSfId);
                searchResultInfo.status = searchResultStatus;

                if(!searchResultStatus.equalsIgnoreCase(BATCH_ABORTED) && !searchResultStatus.equalsIgnoreCase(BATCH_FAILED)){
                    if(searchResultStatus.equalsIgnoreCase('Not_Started')){
                        searchResultInfo.maxAllowedFcoLines = getMaxSupportedFCOLines('FCO001_SET003');
                        searchResultInfo.fcoPreviewLines = getFCOLinesPreview(changeOrder, PREVIEW_REQUEST);
                        searchResultInfo.fcoLineCount = totalExpectedFCOLineCount;
                        searchResultInfo.userPreferredColumns = getColumnsForPreviewResult();
                    }
                    else if(searchResultStatus.equalsIgnoreCase('Completed')){
                        searchResultInfo.userPreferredColumns = getUserConfigForSearch();
                        searchResultInfo.fcoLines = getFCOLines(fcoSfId); 
                        searchResultInfo.fcoLineCount = searchResultInfo.fcoLines.size(); // getting fco lines with draft status
                    }
                    else if(searchResultStatus.equalsIgnoreCase('In_Progress')){
                        searchResultInfo.fcoLineCount = getFCOLineCount(fcoSfId); // getting fco lines with draft status
                    }
                } 
                else{
                        response.success = false;
                        response.message = searchResultStatus.equalsIgnoreCase(BATCH_ABORTED) ? Label.FCO001_TAG024 : Label.FCO001_TAG025;
                }
                  response.data  = searchResultInfo;
            }
            else{
                createExceptionLogs(null, response, 'getSearchResultInfo', Label.FCO001_TAG027); // Value: Invalid Request
            }
        }
        catch(Exception e ){
            createExceptionLogs(e, response, 'getSearchResultInfo', BLANK_STRING);
        }
        
        finally {
            System.debug( LoggingLevel.INFO, 'getSearchResultInfo() - exit' );
        }
        return response;
    }

    /** Created By: Arpit
     * Used to get preview result wrapper
     * @parameter sObject record
     * @return CORD_WrapperDef.PreviewSearchResultWrapper
    */
    @testvisible
    private static CORD_WrapperDef.PreviewSearchResultWrapper getPreviewWrapperForIb(sObject record){
        CORD_WrapperDef.PreviewSearchResultWrapper previewWrapper = new CORD_WrapperDef.PreviewSearchResultWrapper();
        previewWrapper.item = String.valueOf(record.get('Name'));
        previewWrapper.serialNumber = String.valueOf(record.get('SVMXC__Serial_Lot_Number__c'));
        previewWrapper.batchLotNumber = String.valueOf(record.getSobject('SVMXC__SM_Batch_Lot2__r') != NULL ? String.valueOf(record.getSobject('SVMXC__SM_Batch_Lot2__r').get('Name')) : BLANK_STRING);
        previewWrapper.location = String.valueOf(record.getSobject('SVMXC__Site__r') != NULL ? String.valueOf(record.getSobject('SVMXC__Site__r').get('Name')) : BLANK_STRING);
        return previewWrapper;
    }

    /** Created By: Arpit
     * Used to get wrapper for stock serial search
     * @parameter sObject record
     * @return CORD_WrapperDef.PreviewSearchResultWrapper
    */
    @testvisible
    private static CORD_WrapperDef.PreviewSearchResultWrapper getPreviewWrapperForStockSerial(sObject record){
        CORD_WrapperDef.PreviewSearchResultWrapper previewWrapper = new CORD_WrapperDef.PreviewSearchResultWrapper();
        previewWrapper.serialNumber = String.valueOf(record.get('Name'));
        previewWrapper.batchLotNumber = String.valueOf(record.getSobject('SVMXC__SM_Batch_Lot2__r') != NULL ? String.valueOf(record.getSobject('SVMXC__SM_Batch_Lot2__r').get('Name')) : BLANK_STRING);
        sObject productStock = record.getSobject('SVMXC__Product_Stock__r') != NULL ? record.getSobject('SVMXC__Product_Stock__r') : NULL;
        previewWrapper.location = productStock != NULL && productStock.getSobject('SVMXC__Location__r') != NULL ? String.valueOf(productStock.getSobject('SVMXC__Location__r').get('Name')) : BLANK_STRING;
        return previewWrapper;
    }

    /** Created By: Arpit
     * Used to get wrapper for batch lot search
     * @parameter sObject record
     * @return CORD_WrapperDef.PreviewSearchResultWrapper
    */
    @testvisible
    private static CORD_WrapperDef.PreviewSearchResultWrapper getPreviewWrapperForBatchLot(sObject record){
        CORD_WrapperDef.PreviewSearchResultWrapper previewWrapper = new CORD_WrapperDef.PreviewSearchResultWrapper();
        previewWrapper.batchLotNumber = String.valueOf(record.get('Name'));
        return previewWrapper;
    }

    /** Created By: Arpit
     * Used to get fco preview lines
     * @parameter SVMXC__SM_Change_Order__c changeOrder, String requestType
     * @return List<CORD_WrapperDef.PreviewSearchResultWrapper>
    */
    @testvisible
    private List<CORD_WrapperDef.PreviewSearchResultWrapper> getFCOLinesPreview(SVMXC__SM_Change_Order__c changeOrder, String requestType){
        List<sObject> previewResultRecordList = getFCOLinesPreviewBatch(changeOrder, requestType);
        List<CORD_WrapperDef.PreviewSearchResultWrapper> wrapperList = new List<CORD_WrapperDef.PreviewSearchResultWrapper> ();
        List<CORD_WrapperDef.PreviewSearchResultWrapper> previewResultWrapper = new List<CORD_WrapperDef.PreviewSearchResultWrapper> ();
        for(sObject previewResultRecord : previewResultRecordList){
            String recordId = String.valueOf(previewResultRecord.get('Id'));
            CORD_WrapperDef.PreviewSearchResultWrapper wrapper = recordId.startsWith(IB_OBJ_PREFIX) ? getPreviewWrapperForIb(previewResultRecord) : recordId.startsWith(BATCH_MASTER_OBJ_PREFIX) ? getPreviewWrapperForBatchLot(previewResultRecord) : getPreviewWrapperForStockSerial(previewResultRecord);
            wrapperList.add(wrapper);
        }
        return wrapperList;
    }
    
    /** Created By: Arpit
     * Used to generate fcoLines
     * @parameter fcoSfId
     * @return  List<CORD_WrapperDef.FCOLineWrapper> 
     */ 
    public List<sObject> getFCOLinesPreviewBatch(SVMXC__SM_Change_Order__c changeOrder, String requestType){
        Map<Id, sObject> installedProductSet = new Map<Id, sObject> ();
        List<sObject> installedProductList = new List<sObject> ();
        Map<Id, sObject> allIBMap = new Map<Id, sObject> ();
        Map<Id, sObject> allBatchLotRecordsMap = new Map<Id, sObject> (); 
        Map<Id, sObject> previewBatchMap = new Map<Id, sObject> ();
        Map<Id, SVMXC__Installed_Product__c> tempIBMap = new Map<Id, SVMXC__Installed_Product__c> ();
        List<sObject> batchLotSerializedStockList = new List<sObject> ();
        List<SVMXC__SM_Batch_Lot__c> batchLotList = new List<SVMXC__SM_Batch_Lot__c> ();
        List<SVMXC__Product_Serial__c> productSerialList = new List<SVMXC__Product_Serial__c> ();
        Map<String, SVMXC__SM_Change_Order_Criteria__c> criteriaMap = new Map<String, SVMXC__SM_Change_Order_Criteria__c> ();

        String topLevelSubQueryIB = changeOrder.SVMXC__SM_Top_Level_IBs_Only__c ? ' AND SVMXC__Top_Level__c = NULL AND SVMXC__Parent__c = NULL ' : BLANK_STRING;
        String topLevelSubQueryTechAttrib = changeOrder.SVMXC__SM_Top_Level_IBs_Only__c ? ' SVMXC__SM_Installed_Product_id__r.SVMXC__Top_Level__c = NULL AND SVMXC__SM_Installed_Product_id__r.SVMXC__Parent__c = NULL AND ' : BLANK_STRING;
        String advancedExpression = changeOrder.SVMXC__SM_Criteria_Advanced_Expression__c;
        Integer countOfFCOLines = 0;
        Integer noOfRecordQuery = 5;
        Boolean isPreviewRequest = requestType.equalsIgnoreCase(PREVIEW_REQUEST) ? true : false;
        Map<String, List<sObject>> mapForPreviewResults = new Map<String, List<sObject>> (); // to maintain preview result sequence

        for(SVMXC__SM_Change_Order_Criteria__c criteria : changeOrder.SVMXC__Change_Order_Criterias__r){
            criteriaMap.put(Criteria.SVMXC__SM_Type__c, criteria);
        }

        if(criteriaMap.containsKey(INSTALLED_PRODUCT_SEARCH_TYPE)){
            tempIBMap =  new Map<Id, SVMXC__Installed_Product__c> ((List<SVMXC__Installed_Product__c>) Database.query('SELECT Id FROM SVMXC__Installed_Product__c WHERE (' + criteriaMap.get(INSTALLED_PRODUCT_SEARCH_TYPE).SVMXC__SM_Object_Criteria__c +') '+ topLevelSubQueryIB));
            allIBMap.putAll(tempIBMap);
            if(isPreviewRequest){
                Set<Id> tempIds = tempIBMap.keySet();
                //defaulted query limit to MAX_PREVIEW_LINES =5 in query since it is first query
                Map<Id, SVMXC__Installed_Product__c> ibSearchResult = new Map<Id, SVMXC__Installed_Product__c> ((List<SVMXC__Installed_Product__c>) Database.query('SELECT Id, Name, SVMXC__Serial_Lot_Number__c, SVMXC__Site__c, SVMXC__Site__r.Name, SVMXC__SM_Batch_Lot2__c, SVMXC__SM_Batch_Lot2__r.Name FROM SVMXC__Installed_Product__c WHERE (Id IN :tempIds AND (' + criteriaMap.get(INSTALLED_PRODUCT_SEARCH_TYPE).SVMXC__SM_Object_Criteria__c +'))' + topLevelSubQueryIB +' ORDER BY SVMXC__Serial_Lot_Number__c ASC, SVMXC__SM_Batch_Lot2__r.Name ASC LIMIT : MAX_PREVIEW_LINES'));
                installedProductSet.putAll(ibSearchResult);
                noOfRecordQuery = MAX_PREVIEW_LINES - ibSearchResult.size();
                ibSearchResult.clear(); //#cleanMemory
                tempIds.clear(); //#cleanMemory
                tempIBMap.clear(); //#cleanMemory
            }
        }
        if(criteriaMap.containsKey(TECH_ATTRIB_SEARCH_TYPE)){
            if(String.isBlank(advancedExpression) || advancedExpression.containsIgnoreCase('OR') || (advancedExpression.containsIgnoreCase('AND') && !allIBMap.isEmpty())){
                List<String> ibIdList = new List<String> ();
                Set<String> tempTechAttributeIbSet = new Set<String> ();
                Boolean isAndOperator = false;
                Set<String> ibIdSet = new Set<String> ();
                Set<String> clonedIbSet = new Set<String> ();
                String techAttributeSubQuery = (String.isBlank(advancedExpression) || advancedExpression.containsIgnoreCase('OR')) ? BLANK_STRING : ' SVMXC__SM_Installed_Product_id__c IN : allIBMap.keySet() AND ';
                CORD_WrapperDef.FCOSearchExpression searchExpression = (CORD_WrapperDef.FCOSearchExpression) JSON.deserialize(criteriaMap.get(TECH_ATTRIB_SEARCH_TYPE).SVMXC__SM_Criteria_Definition__c, CORD_WrapperDef.FCOSearchExpression.class);
                List<CORD_WrapperDef.ExpressionRows> expressionRows = searchExpression.expressionRows;
                List<String> operatorForRows = searchExpression.operatorForRows;
            
                // if advanced expression is having AND condition we need to pass ib ids in tech attribute search
                if(String.isNotBlank(techAttributeSubQuery)){
                    Set<String> tempSet = new Set<String>( (List<String>) new List<Id> (allIBMap.keySet()) );
                    clonedIbSet.addAll(tempSet);
                }
                
                //This is to identify whether technical attribute section is having AND operators among rows i.e first row AND second row AND third row
                if(operatorForRows!= NULL && !operatorForRows.isEmpty() && operatorForRows[0].containsIgnoreCase('AND')){
                    isAndOperator = true;
                }

                for(Integer i=0; i < expressionRows.size(); i++){
                    if(isAndOperator){ 
                        if(i > 0 && clonedIbSet.isEmpty() ) { // if it is "AND" condition among rows and previous row expression does not return any result in clonedIbSet then do not call the method since no result is available to feed in next row for "AND" condition
                            ibIdSet = new Set<String> ();
                            break; // exit from loop since we will be not getting any result because previous row did not return any and we have AND condition among rows
                        }
                        else{
                            ibIdSet = getIBRecordsFromTechAttribute(expressionRows[i], clonedIbSet, topLevelSubQueryTechAttrib);
                        }
                        clonedIbSet = new Set<String> (ibIdSet); // store result of current row expression
                    }
                    else{
                        ibIdSet.addAll(getIBRecordsFromTechAttribute(expressionRows[i], clonedIbSet, topLevelSubQueryTechAttrib));
                    }
                }
                
                noOfRecordQuery = String.isNotBlank(techAttributeSubQuery) ? MAX_PREVIEW_LINES : noOfRecordQuery; // It means if there is 'AND' condition then we need to reset countOfRecords to 5 since it is intersection                     
                Map<Id, SVMXC__Installed_Product__c> tempTechAttribIBMap = new Map<Id, SVMXC__Installed_Product__c> ((List<SVMXC__Installed_Product__c>) Database.query('SELECT Id FROM SVMXC__Installed_Product__c WHERE Id IN :ibIdSet'));

                if(String.isBlank(techAttributeSubQuery)){
                    allIBMap.putAll(tempTechAttribIBMap);
                }
                else{
                    allIBMap = new Map<Id, sObject> ();
                    allIBMap.putAll(tempTechAttribIBMap);
                }

                Map<Id, SVMXC__Installed_Product__c> techAttribIBResult = new Map<Id, SVMXC__Installed_Product__c> ();
                if(isPreviewRequest && !allIBMap.isEmpty()){
                    Set<String> tempSet = new Set<String>( (List<String>) new List<Id> (allIBMap.keySet()) );
                    ibIdList = new List<String> (tempSet);
                    techAttribIBResult = new Map<Id, SVMXC__Installed_Product__c> ((List<SVMXC__Installed_Product__c>) Database.query('SELECT Id, Name, SVMXC__Serial_Lot_Number__c, SVMXC__Site__c, SVMXC__Site__r.Name, SVMXC__SM_Batch_Lot2__c, SVMXC__SM_Batch_Lot2__r.Name FROM SVMXC__Installed_Product__c WHERE Id IN :ibIdList ORDER BY SVMXC__Serial_Lot_Number__c ASC, SVMXC__SM_Batch_Lot2__r.Name ASC LIMIT :MAX_PREVIEW_LINES '));
                    tempSet.clear();
                }

                installedProductSet.clear(); // rebuild preview lines
                Integer counter = 0;
                for(SVMXC__Installed_Product__c ibRecord : techAttribIBResult.values()){
                    if(counter < MAX_PREVIEW_LINES){
                        installedProductSet.put(ibRecord.Id, ibRecord);
                    }
                    else{
                        break;
                    }
                    counter++;
                }

                ibIdSet.clear(); //#cleanMemory
                tempTechAttribIBMap.clear(); //#cleanMemory
                techAttribIBResult.clear(); //#cleanMemory
                ibIdList.clear(); //#cleanMemory
                ibIdSet.clear(); //#cleanMemory
            }
        }

        if(criteriaMap.containsKey(BATCH_LOT_SEARCH_TYPE)){
            List<BatchLotResultWrapper> batchLotWrapperList = new List<BatchLotResultWrapper> ();
            Set<String> batchLotSet = new Set<String> ();
            Set<String> batchIdOnSerialStockSet = new Set<String> ();
            Map<Id, SVMXC__Product_Serial__c> stockedSerialSet = new  Map<Id, SVMXC__Product_Serial__c> ();
            Map<Id, SVMXC__SM_Batch_Lot__c> batchLotMasterSet = new  Map<Id, SVMXC__SM_Batch_Lot__c> ();

            CORD_WrapperDef.FCOSearchExpression searchExpression = (CORD_WrapperDef.FCOSearchExpression) JSON.deserialize(criteriaMap.get(BATCH_LOT_SEARCH_TYPE).SVMXC__SM_Criteria_Definition__c, CORD_WrapperDef.FCOSearchExpression.class);
            List<String> operatorForRows = searchExpression.operatorForRows;
            List<CORD_WrapperDef.ExpressionRows> expressionRows = searchExpression.expressionRows;

            Map<String, List<CORD_WrapperDef.ExpressionRows>> batchSerialExpressionMap = new Map<String, List<CORD_WrapperDef.ExpressionRows>> (); 
            for(CORD_WrapperDef.ExpressionRows expressionRow : expressionRows){
                List<CORD_WrapperDef.Expression> expressions = expressionRow.expressions;
                String firstFieldName = expressions[0].fieldName;
                String objectName = firstFieldName.equalsIgnoreCase(BATCH_LOT_NUMBER_PLACEHOLDER_FIELD) ? BATCH_LOT_MASTER_OBJECT : STOCKED_SERIAL_OBJECT;
                if(batchSerialExpressionMap.containsKey(objectName)){
                    batchSerialExpressionMap.get(objectName).add(expressionRow);
                }
                else{
                    batchSerialExpressionMap.put(objectName, new List<CORD_WrapperDef.ExpressionRows> {expressionRow});
                }
            }
            // Boolean isSingleObjectSearch = batchSerialExpressionMap.size() == 1 ? true : false; //defectFix 6089
            Boolean isOnlyStockSerialSearch = batchSerialExpressionMap.size() == 1 && batchSerialExpressionMap.containsKey(STOCKED_SERIAL_OBJECT) ? true : false; //defectFix 6089
            Boolean isFirstRun = true;
            Boolean isAndOperator = false; // defect 6071
            Set<String> batchLotIds = new Set<String> ();
            // iterate over batch lot and stock serial expressions
            for(String objectName : batchSerialExpressionMap.keySet()){
                List<CORD_WrapperDef.ExpressionRows> expressions = batchSerialExpressionMap.get(objectName);
                String whereClause = BLANK_STRING;
                isAndOperator = operatorForRows!= NULL && operatorForRows[0].equalsIgnoreCase('AND') ? true : false;
                BatchLotResultWrapper batchLotResultWrapper;
                for(Integer i=0; i<expressions.size(); i++){
                    String rowOperator = i > 0 ? operatorForRows[0] + ' (': BLANK_STRING;
                    whereClause += rowOperator + createQueryForRow(objectProductFieldMap.get(objectName), expressions[i], BATCH_LOT_SEARCH_TYPE);
                    whereClause +=  i > 0 ? ')' : BLANK_STRING;
                }
                whereClause += objectName.equalsIgnoreCase(BATCH_LOT_MASTER_OBJECT) ? ' ORDER BY Name ASC ' : ' ORDER BY Name ASC, SVMXC__SM_Batch_Lot2__r.Name ASC '; 
                System.debug('whereClause@@'+whereClause);
                if(!isFirstRun && isAndOperator && batchLotIds.isEmpty()){ // if there is no batchId results from previous row in AND condtion stop processing further
                    batchLotWrapperList.clear();
                    break;
                }
                else if(isFirstRun || !isAndOperator){
                    batchLotResultWrapper =  getBatchLotResult(whereClause, isPreviewRequest, new Set<String> (), objectName.equalsIgnoreCase(BATCH_LOT_MASTER_OBJECT));
                    batchLotIds = isAndOperator ? batchLotResultWrapper.batchLotIdSet : new Set<String> ();
                }
                else if(!isFirstRun && isAndOperator && !batchLotIds.isEmpty()){
                    batchLotResultWrapper =  getBatchLotResult(whereClause, isPreviewRequest, batchLotIds, objectName.equalsIgnoreCase(BATCH_LOT_MASTER_OBJECT));
                    if((batchLotResultWrapper.batchLotIdSet).isEmpty()){ // in second run onwards if no common result is obtained in batchLotResultWrapper.batchLotIdSet, then stop processing further and clear the wrapper 
                        batchLotWrapperList.clear();
                        break;
                    }
                    else{
                        batchLotIds = batchLotResultWrapper.batchLotIdSet; // defect 6071
                    }
                }
                batchLotWrapperList.add(batchLotResultWrapper);
                isFirstRun = false;
            }
            
            
            batchSerialExpressionMap.clear(); // #clearMemory
            if(batchLotIds.isEmpty() && isAndOperator && !isOnlyStockSerialSearch){ //defectFix 6089
                batchLotWrapperList.clear();
            }
            if(!isAndOperator){
                // collect all the batch lot ids from stock serial record
                for(BatchLotResultWrapper wrapper : batchLotWrapperList){
                    for(SVMXC__Product_Serial__c stockedSerialRecord : wrapper.serializedRecords){
                        stockedSerialSet.put(stockedSerialRecord.Id, stockedSerialRecord);
                        if(String.isNotBlank(stockedSerialRecord.SVMXC__SM_Batch_Lot2__c)){ //#todo we can remove it using query itself
                            batchIdOnSerialStockSet.add(stockedSerialRecord.SVMXC__SM_Batch_Lot2__c);
                        }
                    }
                }
                
                // collect all the batch lot ids from batch lot record
                for(BatchLotResultWrapper wrapper : batchLotWrapperList){
                    for(SVMXC__SM_Batch_Lot__c batchLotRecord : wrapper.batchLotRecords){
                        if(!batchIdOnSerialStockSet.contains(batchLotRecord.Id)){
                            batchLotMasterSet.put(batchLotRecord.Id, batchLotRecord);
                        }
                    }
                }
            }
            else{ // AND Condition
                    // collect all the batch lot ids from stock serial record
                    for(BatchLotResultWrapper wrapper : batchLotWrapperList){
                        for(SVMXC__Product_Serial__c stockedSerialRecord : wrapper.serializedRecords){
                            String batchId = stockedSerialRecord.SVMXC__SM_Batch_Lot2__c;
                            if(isOnlyStockSerialSearch){ //defectFix 6089
                                stockedSerialSet.put(stockedSerialRecord.Id, stockedSerialRecord);
                            }
                            else if(String.isNotBlank(batchId) && batchLotIds.contains(batchId)){
                                stockedSerialSet.put(stockedSerialRecord.Id, stockedSerialRecord);
                                batchIdOnSerialStockSet.add(batchId);
                            }
                        }
                    }
                    // collect all the batch lot ids from batch lot record
                    for(BatchLotResultWrapper wrapper : batchLotWrapperList){
                        for(SVMXC__SM_Batch_Lot__c batchLotRecord : wrapper.batchLotRecords){
                            if(batchLotIds.contains(batchLotRecord.Id) && !batchIdOnSerialStockSet.contains(batchLotRecord.Id)){
                                batchLotMasterSet.put(batchLotRecord.Id, batchLotRecord);
                            }
                        }
                    }
            }

            Map<Id, sObject> batchLotRecords = new Map<Id, sObject> ();
            for(SVMXC__Product_Serial__c stockedSerial : stockedSerialSet.values()){
                previewBatchMap.put(stockedSerial.Id, stockedSerial);
            }

            for(SVMXC__SM_Batch_Lot__c batchLotmaster : batchLotMasterSet.values()){
                previewBatchMap.put(batchLotmaster.Id,  batchLotmaster);
            }

            Integer batchRecordCounter = 0;
            List<sObject> firstFiveRecords = new List<sObject> ();
            for(sObject record : previewBatchMap.values()){
                if(batchRecordCounter < MAX_PREVIEW_LINES){
                    firstFiveRecords.add(record);
                }
                batchRecordCounter++;
            }
            mapForPreviewResults.put(BATCH_LOT_SEARCH_TYPE, firstFiveRecords);
            
            allBatchLotRecordsMap.putAll(stockedSerialSet);
            allBatchLotRecordsMap.putAll(batchLotMasterSet);

            batchLotWrapperList.clear(); //#cleanMemory
            batchIdOnSerialStockSet.clear(); //#cleanMemory       
        }
        if(requestType.equalsIgnoreCase(FCO_LINE_BATCH_REQUEST)){
            installedProductSet.putAll(allIBMap);
            installedProductSet.putAll(allBatchLotRecordsMap);
            installedProductList.addAll(installedProductSet.values());
        }
        else{
            Integer counter = 0;
            Boolean isIBPreviewComplete = false;
            for(String criteriaType : criteriaMap.keySet()){
                if(criteriaType.equalsIgnoreCase(BATCH_LOT_SEARCH_TYPE) && counter < MAX_PREVIEW_LINES){
                    for(sObject record : mapForPreviewResults.get(BATCH_LOT_SEARCH_TYPE)){
                        if(counter < MAX_PREVIEW_LINES){
                            installedProductList.add(record);
                            counter++;
                        }
                        else{
                            break;
                        }
                    }
                }
                else{
                        Map<String, sObject> serialNumberRecordMap = new Map<String, sObject> ();
                        List<String> serialNumberList = new List<String> ();
                        if(!isIBPreviewComplete){
                            isIBPreviewComplete = true;
                            for(sObject record : installedProductSet.values()){
                                if(counter < MAX_PREVIEW_LINES){
                                    String serialNumber = (String) record.get('SVMXC__Serial_Lot_Number__c');
                                    if(String.isBlank(serialNumber)){
                                        installedProductList.add(record);
                                    }
                                    else{
                                        serialNumberRecordMap.put(serialNumber, record);
                                        serialNumberList.add(serialNumber);
                                    }
                                    counter++;
                                } 
                                else{
                                    break;
                                }
                            }
                            if(!serialNumberList.isEmpty()){
                                serialNumberList.sort();
                                for(String serialNumber : serialNumberList){
                                    installedProductList.add(serialNumberRecordMap.get(serialNumber));
                                }
                            }
                        }
                    }
            }
            allIBMap.putAll(allBatchLotRecordsMap);
        }
        // TO DO take additional count for batch lot search type and add into below count
        totalExpectedFCOLineCount = allIBMap.size();
        allIBMap.clear(); //#cleanMemory
        return installedProductList;
    }

    /** Created By: Arpit
     * Used to get ib records from technical attribute search
     * @parameter CORD_WrapperDef.ExpressionRows expressionRow, Set<String> ibSet, String topLevelSubQuery
     * @return Set<String>
    */ 
    private Set<String> getIBRecordsFromTechAttribute(CORD_WrapperDef.ExpressionRows expressionRow, Set<String> ibSet, String topLevelSubQuery){
        List<CORD_WrapperDef.Expression> expressions = expressionRow.expressions;
        String productField = 'SVMXC__SM_Installed_Product_id__r.SVMXC__Product__c';
        String firstFieldName = expressions[0].fieldName;
        String subQuery =  ibSet.isEmpty() ? BLANK_STRING : ' AND SVMXC__SM_Installed_Product_id__c IN :ibSet ORDER BY SVMXC__SM_Installed_Product_id__r.SVMXC__Serial_Lot_Number__c ASC, SVMXC__SM_Installed_Product_id__r.SVMXC__SM_Batch_Lot2__r.Name ASC ';
        Set<String> finalIBSet = new Set<String> ();
        String baseQuery = 'SELECT Id, SVMXC__SM_Installed_Product_id__c FROM SVMXC__SM_IB_Technical_Attributes__c WHERE '+ topLevelSubQuery;
        if(expressions.size() > 1){
            String secondFieldName = expressions[1].fieldName;
            List<String> operatorForColumns = expressionRow.operatorForColumns;

            if(firstFieldName.equalsIgnoreCase(secondFieldName) || operatorForColumns[0].equalsIgnoreCase('OR')){
                String query = baseQuery + createQueryForRow(productField, expressionRow, TECH_ATTRIB_SEARCH_TYPE);
                query += subQuery;
                List<SVMXC__SM_IB_Technical_Attributes__c> techAttribRecords = Database.query(query);
                for(SVMXC__SM_IB_Technical_Attributes__c attrib : techAttribRecords){
                    if(String.isNotBlank(attrib.SVMXC__SM_Installed_Product_id__c)){
                        finalIBSet.add(attrib.SVMXC__SM_Installed_Product_id__c);
                    }
                }                
            }
            else{
                String queryString1 = baseQuery + productField + ' = \''+expressionRow.selectedProductId.trim() + '\'';
                queryString1 += ' AND ( ';
                queryString1 += createQueryFromExpression( expressions[0], TECH_ATTRIB_SEARCH_TYPE) +' ) ';
                queryString1 += subQuery;
                List<SVMXC__SM_IB_Technical_Attributes__c> techAttribRecords = Database.query(queryString1);
                for(SVMXC__SM_IB_Technical_Attributes__c attrib : techAttribRecords){
                    if(String.isNotBlank(attrib.SVMXC__SM_Installed_Product_id__c)){
                        finalIBSet.add(attrib.SVMXC__SM_Installed_Product_id__c);
                    }
                }
                if(!finalIBSet.isEmpty()){
                    String queryString2 = baseQuery + productField + ' = \''+expressionRow.selectedProductId.trim() + '\'';
                    queryString2 += ' AND ( ';
                    queryString2 += createQueryFromExpression( expressions[1], TECH_ATTRIB_SEARCH_TYPE) +' ) ';
                    queryString2 +=  ' AND SVMXC__SM_Installed_Product_id__c IN :finalIBSet ';
                    List<SVMXC__SM_IB_Technical_Attributes__c> techAttribRecords2 = Database.query(queryString2);
                    finalIBSet = new Set<String> ();
                    for(SVMXC__SM_IB_Technical_Attributes__c attrib : techAttribRecords2){
                        if(String.isNotBlank(attrib.SVMXC__SM_Installed_Product_id__c)){
                            finalIBSet.add(attrib.SVMXC__SM_Installed_Product_id__c);
                        }
                    }
                }
                else{
                    finalIBSet = new Set<String> ();
                }
            }
        }
        else{
            String query = baseQuery + createQueryForRow(productField, expressionRow, TECH_ATTRIB_SEARCH_TYPE);
            query += ibSet.isEmpty() ? BLANK_STRING : ' AND SVMXC__SM_Installed_Product_id__c IN : ibSet ';
            List<SVMXC__SM_IB_Technical_Attributes__c> techAttribRecords2 = Database.query(query);
            for(SVMXC__SM_IB_Technical_Attributes__c attrib : techAttribRecords2){
                if(String.isNotBlank(attrib.SVMXC__SM_Installed_Product_id__c)){
                    finalIBSet.add(attrib.SVMXC__SM_Installed_Product_id__c);
                }
            }
        }
        return finalIBSet;
    }

    /** Created By: Arpit
     * Used to generate fcoLines
     * @parameter fcoSfId
     * @return  List<CORD_WrapperDef.FCOLineWrapper>
    */ 
    @testvisible
    private List<SVMXC__SM_Change_Order_Line__c> getFCOLines(String fcoSfId){
        String queryFields = !objConfigColumns.isEmpty() ? getQueryFields(objConfigColumns) : FCO_LINE_DEFAULT_QUERY_FIELDS;
        queryFields += queryFields.containsIgnoreCase('SVMXC__SM_Line_Status__c') ? BLANK_STRING : ',SVMXC__SM_Line_Status__c ';
        queryFields += queryFields.containsIgnoreCase('SVMXC__SM_Installed_Product__c') ? BLANK_STRING : ',SVMXC__SM_Installed_Product__c';
        queryFields += queryFields.containsIgnoreCase('SVMXC__SM_Installed_Product__r.Name') ? BLANK_STRING : ',SVMXC__SM_Installed_Product__r.Name';
        String query = 'SELECT '+ queryFields + ' FROM SVMXC__SM_Change_Order_Line__c WHERE SVMXC__SM_Change_Order__c =:fcoSfId ORDER BY LastmodifiedDate DESC LIMIT 50000';// AND SVMXC__SM_Line_Status__c =: FCO_STATUS_DRAFT LIMIT 50000 ';
        return Database.query(query);
    }
                                                                    
    /** Created By: Arpit
     * Used to get generated fcolines with status draft
     * @parameter fcoSfId
     * @return Integer
     */ 
    @testvisible
    private Integer getFCOLineCount(String fcoSfId){
        List<SVMXC__SM_Change_Order_Line__c> fcoLinesList = [SELECT Id FROM SVMXC__SM_Change_Order_Line__c WHERE SVMXC__SM_Change_Order__c =: fcoSfId];
        return fcoLinesList.size();
    }

    // This method is used to get fco lines which has been converted into work order. If logId is provided then it
    // fetches fco lines specific to that change order log (running batch count) else, if logId is blank then it gives all the fco lines (which has been converted to work order)
    // created from all the batches run so far 
    @testvisible
    private List<SVMXC__SM_Change_Order_Line__c> getFCOLinesWithWO(String fcoSfId, String logId){
        String query = 'SELECT Id, SVMXC__SM_Work_Order__c FROM SVMXC__SM_Change_Order_Line__c WHERE SVMXC__SM_Change_Order__c =: fcoSfId AND SVMXC__SM_Work_Order__c != NULL';
        query += String.isBlank(logId) ? BLANK_STRING : ' AND SVMXC__SM_Change_Order_Log__c =: logId'; 
        return Database.query(query);
    }

    /** Created By: Arpit
     * Used to get generated work order list
     * @parameter List<SVMXC__SM_Change_Order_Line__c> changeOrderLines
     * @return  CORD_WrapperDef.FCO_Response
     */ 
    @testvisible
    private List<SVMXC__Service_Order__c> getWorkOrderList(List<SVMXC__SM_Change_Order_Line__c> changeOrderLines){
        List<String> workOrdeIdList = new List<String> ();
        String queryFields = !objConfigColumns.isEmpty() ? getQueryFields(objConfigColumns) : WORK_ORDER_DEFAULT_QUERY_FIELDS;
        
        for(SVMXC__SM_Change_Order_Line__c changeOrderLine : changeOrderLines){ //iterate over all fco lines to collect work order ids onand query respective work order fields based on user preference
            workOrdeIdList.add(changeOrderLine.SVMXC__SM_Work_Order__c); 
        }
        String query = 'SELECT '+ queryFields + ' FROM '+ WORK_ORDER_OBJECT +' WHERE Id IN : workOrdeIdList ORDER BY LastmodifiedDate DESC LIMIT 50000';
        return Database.query(query);
    }
    
    /** Created By: Arpit
     * Used to get search result information of the fco
     * @parameter fcoSfId
     * @return  CORD_WrapperDef.FCO_Response
     */ 
    public CORD_WrapperDef.FCO_Response getWorkOrderInfo(String fcoSfId){
        System.debug( LoggingLevel.INFO, 'getWorkOrderInfo() - enter' );
        System.debug( LoggingLevel.INFO, fcoSfId);
       
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();

        try{
            CORD_WrapperDef.WorkOrderInfo workOrderInfo = new CORD_WrapperDef.WorkOrderInfo();
            // get the batch id fco
            List<SVMXC__SM_Change_Order_Log__c> woChangeOrderLogs = [SELECT Id, SVMXC__SM_Batch_Id__c FROM SVMXC__SM_Change_Order_Log__c WHERE SVMXC__SM_Change_Order__c =: fcoSfId AND SVMXC__SM_Log_Type__c =: LOG_TYPE_WO_GENERATION AND SVMXC__SM_Batch_Id__c != NULL  ORDER BY createdDate DESC LIMIT 1];  
            if(!woChangeOrderLogs.isEmpty()){
                List<SVMXC__SM_Change_Order_Line__c> fcoLinesWithWO = new List<SVMXC__SM_Change_Order_Line__c> ();
                AsyncApexJob apexJob = getBatchDetails(woChangeOrderLogs[0].SVMXC__SM_Batch_Id__c); //#TODO REMVOE THIS METHOD
                if(apexJob != NULL){
                    String batchStatus = !Test.isRunningTest() ? apexJob.Status : batchStatusByTestClass;
                    if(BATCH_QUEUED_STATUS_LIST.contains(batchStatus)){
                        workOrderInfo.status = BATCH_QUEUED;
                    }
                    else if(BATCH_IN_PROGRESS_LIST.contains(batchStatus)){
                        workOrderInfo.status =  BATCH_IN_PROGRESS;
                        fcoLinesWithWO = getFCOLinesWithWO(fcoSfId, woChangeOrderLogs[0].Id);
                       workOrderInfo.workOrderCount = fcoLinesWithWO.size();
                    }
                    else if(batchStatus.equalsIgnoreCase(BATCH_COMPLETED)){
                        Integer eligibleFCOLines = getToBeGeneratedWOCount(fcoSfId);
                        if(eligibleFCOLines > 0){
                            workOrderInfo.status =  'Not_Started';
                            workOrderInfo.workOrderCount = eligibleFCOLines;
                            response.data = workOrderInfo;
                        }
                        else{
                            workOrderInfo.status =  BATCH_COMPLETED;
                            fcoLinesWithWO = getFCOLinesWithWO(fcoSfId, BLANK_STRING);
                            workOrderInfo.userPreferredColumns = getUserConfigForWorkOrder();
                            workOrderInfo.workOrderList = getWorkOrderList(fcoLinesWithWO); //#TODO
                            workOrderInfo.workOrderCount = fcoLinesWithWO.size();
                        }
                    }
                    else if(batchStatus.equalsIgnoreCase(BATCH_ABORTED) || batchStatus.equalsIgnoreCase(BATCH_FAILED)){
                        Integer eligibleFCOLines = getToBeGeneratedWOCount(fcoSfId);
                        if(eligibleFCOLines > 0){
                           workOrderInfo.status =  'Not_Started';
                            workOrderInfo.workOrderCount = eligibleFCOLines;
                            response.data = workOrderInfo;
                        }
                        else{
                            response.success = false;
                            response.message = batchStatus.equalsIgnoreCase(BATCH_ABORTED) ? Label.FCO001_TAG024 : Label.FCO001_TAG025; // Process has been terminated. Please contact admin.
                        }
                        
                    }
                }
                else{ //#TODO make a separate method
                        Integer eligibleFCOLines = getToBeGeneratedWOCount(fcoSfId);
                        if(eligibleFCOLines > 0){
                            workOrderInfo.status =  'Not_Started';
                            workOrderInfo.workOrderCount = eligibleFCOLines;
                            response.data = workOrderInfo;
                        }
                        else{
                            workOrderInfo.status =  BATCH_COMPLETED;
                            fcoLinesWithWO = getFCOLinesWithWO(fcoSfId, BLANK_STRING);
                            workOrderInfo.userPreferredColumns = getUserConfigForWorkOrder();
                            workOrderInfo.workOrderList = getWorkOrderList(fcoLinesWithWO); //#TODO
                            workOrderInfo.workOrderCount = fcoLinesWithWO.size();
                        }
                }
                response.data = workOrderInfo;
            }
            else{
                workOrderInfo.status =  'Not_Started';
                workOrderInfo.workOrderCount = getToBeGeneratedWOCount(fcoSfId);
                response.data = workOrderInfo;

            }
        }
        catch(Exception e ){
            createExceptionLogs(e, response, 'getWorkOrderInfo', BLANK_STRING);
        }
        
        finally {
            System.debug( LoggingLevel.INFO, 'getWorkOrderInfo() - exit' );
        }
        return response;
    } 

    /** Created By: Arpit
     * Used to get eligible fco lines for work order generation
     * @parameter String fcoSfId
     * @return Integer
     */ 
    public static Integer getToBeGeneratedWOCount(String fcoSfId){
        List<SVMXC__SM_Change_Order_Line__c> changeOrderLines = [SELECT Id FROM SVMXC__SM_Change_Order_Line__c WHERE SVMXC__SM_Change_Order__c =:fcoSfId AND SVMXC__SM_Generate_WORD__c = true AND SVMXC__SM_Line_Status__c =: FCO_LINE_STATUS_DRAFT LIMIT 50000];
        return changeOrderLines.size();
    }

    /** Created By: Arpit
     * Used to get user preference configuration for the provide object
     * @parameter SVMXC__SM_User_Preferences__c userPreference, Map<String,Schema.SObjectField> fieldMap, String objectName
     * @return  List<CORD_WrapperDef.FCOFieldInfo>
     */ 
    private List<CORD_WrapperDef.FCOFieldInfo> getConfiguredColumns(SVMXC__SM_User_Preferences__c userPreference, Map<String, CORD_WrapperDef.FCOFieldInfo> fieldMap, String objectName){
        List<CORD_WrapperDef.FCOFieldInfo> validSelectedColumns = new List<CORD_WrapperDef.FCOFieldInfo> ();
        List<CORD_WrapperDef.FCOFieldInfo> userPreferenceList = new List<CORD_WrapperDef.FCOFieldInfo> ();
        if(userPreference != NULl && String.isNotBlank(userPreference.SVMXC__SM_Configured_Columns__c)){
            Map<String, Object> preferenceMap = new Map<String, Object> ();
            preferenceMap = (Map<String, Object>) JSON.deserializeUntyped(userPreference.SVMXC__SM_Configured_Columns__c);
            if(preferenceMap.containsKey(objectName)){
                String serializedString = (String) preferenceMap.get(objectName);
                if(String.isNotBlank(serializedString)){
                    userPreferenceList = (List<CORD_WrapperDef.FCOFieldInfo> ) JSON.deserialize(serializedString, List<CORD_WrapperDef.FCOFieldInfo>.class);
                }
            }
   
            for(CORD_WrapperDef.FCOFieldInfo fieldInfo : userPreferenceList){
                if(String.isNotBlank(fieldInfo.fieldName) && fieldMap.containsKey(fieldInfo.fieldName)){ // #TODO we should validate data type as well
                    validSelectedColumns.add(fieldMap.get(fieldInfo.fieldName));
                }
            }
        }
            return validSelectedColumns;
        }
    

    /** Created By: Arpit
    * Used to collect fields in a set
    * @parameter List<CORD_WrapperDef.FCOFieldInfo> definedColumns
    * @return Set<String>
    */
    @testvisible
    private Set<String> getConfiguredFields(List<CORD_WrapperDef.FCOFieldInfo> definedColumns){
        Set<String> columnSet = new Set<String> ();
        for(CORD_WrapperDef.FCOFieldInfo column : definedColumns){
            columnSet.add(column.fieldName);
        }
        return columnSet;
    }
   
   
    /** Created By: Arpit
     * Used to get configured fields from user preference
     * @parameter List<CORD_WrapperDef.FCOFieldInfo>  configuredColumns
     * @return String
     */ 
    private String getQueryFields(List<CORD_WrapperDef.FCOFieldInfo>  configuredColumns){
        Set<String> columnSet = new Set<String> ();
        for(CORD_WrapperDef.FCOFieldInfo column : configuredColumns){
            String fieldName = (column.fieldType).equalsIgnoreCase('PICKLIST') ? 'toLabel('+column.fieldName+')' : column.fieldName;
            columnSet.add(fieldName);
          if(String.isNotBlank(column.displayName)){ // display name field is populated for lookup fields, Id of lookup is capture from fieldName and dislayName contains corresponding Name field like ib.name, account.name
                columnSet.add(column.displayName);
            }
        }
        return String.join(new List<String> (columnSet),','); 
    }
    
    /** Created By: Arpit
    * Used to check if any batch is running for the fco
    * @parameter String fcoSfId
    * @return Boolean
    */
    private static Boolean isFCOBatchRunning(String fcoSfId){
        List<String> batchStatusInProgressList = new List<String> ();
        batchStatusInProgressList.addAll(BATCH_QUEUED_STATUS_LIST);
        batchStatusInProgressList.addAll(BATCH_IN_PROGRESS_LIST);

        List<String> batchIdList = new List<String> ();
        // collect all the batches related to fco
        for( SVMXC__SM_Change_Order_Log__c log : [SELECT SVMXC__SM_Batch_Id__c FROM SVMXC__SM_Change_Order_Log__c WHERE SVMXC__SM_Change_Order__c =: fcoSfId AND SVMXC__SM_Batch_Id__c != NULL]){
            batchIdList.add(log.SVMXC__SM_Batch_Id__c);
        }
        return Test.isRunningTest() ? false : !batchIdList.isEmpty() && Database.countQuery('SELECT count() FROM AsyncApexJob WHERE Id IN : batchIdList AND Status IN : batchStatusInProgressList') > 0 ? true : false;
    }  

    /** Created By: Arpit
     * Used to save search expression
     * @parameter N/A
     * @return Returns CORD_WrapperDef.FCO_Response
     */ 
    public CORD_WrapperDef.FCO_Response saveSearchExpression(final CORD_WrapperDef.FCO_Request request ) {
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        List<SVMXC__SM_Change_Order_Criteria__c> newCriteriaList = new List<SVMXC__SM_Change_Order_Criteria__c> ();
        sp = Database.setSavepoint();   
        try { 
                String fcoSfId = request.fcoSfId;
                if(!isFCOBatchRunning(fcoSfId)){ // we should not allow to change search expression if any batch exist for fco
                    CORD_WrapperDef.FCOSearchExpressions searchExpressions = request.searchExpressions;
                    if(request.fieldChangeOrderInfo != NULL){
                        // update the change order if value of SVMXC__SM_Top_Level_IBs_Only__c is changed otherwise ignore
                        Boolean searchTopLevelIBOnly = request.fieldChangeOrderInfo.searchTopLevelIBOnly;
                        String criteriaAdvancedExpression = String.isNotBlank(request.fieldChangeOrderInfo.criteriaAdvancedExpression) ? (request.fieldChangeOrderInfo.criteriaAdvancedExpression).trim() : BLANK_STRING;
                        SVMXC__SM_Change_Order__c changeOrder = [SELECT Id, SVMXC__SM_Top_Level_IBs_Only__c, SVMXC__SM_Criteria_Advanced_Expression__c FROM SVMXC__SM_Change_Order__c WHERE Id =:fcoSfId LIMIT 1];
                        if(changeOrder.SVMXC__SM_Top_Level_IBs_Only__c != searchTopLevelIBOnly || changeOrder.SVMXC__SM_Criteria_Advanced_Expression__c != criteriaAdvancedExpression){
                            changeOrder.SVMXC__SM_Top_Level_IBs_Only__c = searchTopLevelIBOnly;
                            changeOrder.SVMXC__SM_Criteria_Advanced_Expression__c = criteriaAdvancedExpression;
                            if(isCOUpdateable){
                                update changeOrder;
                            }
                            else{
                                createExceptionLogs(null, response, 'saveSearchExpression', Label.COMM001_TAG142); // Value: Insufficient permission to perform the operation. Please verify the object and field level permissions.
                                return response;
                            }
                        }
                    }         
                    
                    // delete old criterias
                    List<SVMXC__SM_Change_Order_Criteria__c> existingCriterias = [SELECT Id FROM SVMXC__SM_Change_Order_Criteria__c WHERE SVMXC__SM_Change_Order__c =: fcoSfId];
                    if(!existingCriterias.isEmpty()){
                        delete existingCriterias;  //#defectFix-6261                    
                    }
                   
                    if(searchExpressions.instProdExpression != NULL){
                        newCriteriaList.add(getValidatedCriteria(searchExpressions.instProdExpression, fcoSfId));
                    }

                    if(searchExpressions.techAttribExpression != NULL){ // for technical attributes
                        newCriteriaList.add(createChangeOrderCriteria(TECH_ATTRIB_SEARCH_TYPE, JSON.serialize(searchExpressions.techAttribExpression), fcoSfId, BLANK_STRING, searchExpressions.techAttribExpression.sequence)); //#bhupiDefect
                    }

                    if(searchExpressions.batchLotExpression != NULL){ // for technical attributes
                        newCriteriaList.add(createChangeOrderCriteria(BATCH_LOT_SEARCH_TYPE, JSON.serialize(searchExpressions.batchLotExpression), fcoSfId, BLANK_STRING, searchExpressions.batchLotExpression.sequence));
                    }
               
                    if(!newCriteriaList.isEmpty()){
                        insert newCriteriaList; //#defectFix-6261
                    }

                    Boolean isDeleteSuccessfull = deleteFCOLinesAndLogs(fcoSfId, response);
                    if(isDeleteSuccessfull){
                        response.data = newCriteriaList;
                        response.message = Label.FCO001_TAG002;
                    }
                }
                else{
                    createExceptionLogs(null, response, 'saveSearchExpression', Label.FCO001_TAG023); //Value: 'A batch process for this change order already is in progress.Please try after some time.'
                 }
        }   
        catch(Exception e ){
            createExceptionLogs(e, response, 'saveSearchExpression', BLANK_STRING);
            response.message = Label.FCO001_TAG033; // value: 'Search Criteria is not valid.'; 
        }

        finally {
            System.debug( LoggingLevel.INFO, 'saveSearchExpression() - exit' );
        }
        return response;
    }

    /** Created By: Arpit
    * Used to generate query expression for a row
    * @parameter String productField, CORD_WrapperDef.ExpressionRows expressionRow, String searchType
    * @return String
    */
    private String createQueryForRow(String productField, CORD_WrapperDef.ExpressionRows expressionRow, String searchType){
        String queryString = String.isNotBlank(expressionRow.selectedProductId) ? productField + ' = \''+expressionRow.selectedProductId.trim() + '\'  AND ( ' : ' ( ';
        List<CORD_WrapperDef.Expression> expressions = expressionRow.expressions;
        List<String> operatorForColumns = expressionRow.operatorForColumns;        
        for(integer j=0; j < expressions.size(); j++){
            if(j > 0){
                queryString += SPACE + operatorForColumns[j-1] + SPACE;
            }
            queryString += createQueryFromExpression(expressions[j], searchType);
        }
        queryString = ' ( '+ queryString + ' ) ) ';
        System.debug('queryRow@@'+queryString);
        return queryString;
    }

    /** Created By: Arpit
    * Used to validate ib search definition
    * @parameter CORD_WrapperDef.FCOSearchExpression expression, String fcoSfId
    * @return SVMXC__SM_Change_Order_Criteria__c
    */
    private SVMXC__SM_Change_Order_Criteria__c getValidatedCriteria(CORD_WrapperDef.FCOSearchExpression expression, String fcoSfId){
        CORD_WrapperDef.FCOSearchExpression searchExpression = expression;
        Integer sequence = searchExpression.sequence;
        List<CORD_WrapperDef.ExpressionRows> expressionRows = searchExpression.expressionRows;
        List<String> operatorForRows = searchExpression.operatorForRows;
        String queryString = BLANK_STRING;
        for(integer i=0; i < expressionRows.size(); i++){
            CORD_WrapperDef.ExpressionRows expressionRow = expressionRows[i];
            if(i > 0){
                queryString += SPACE + operatorForRows[i-1] + SPACE + ' ( ';
            }
            queryString += createQueryForRow(objectProductFieldMap.get(INSTALLED_PRODUCT_OBJECT), expressionRow, INSTALLED_PRODUCT_SEARCH_TYPE);
            if(i > 0){
                queryString +=  ' ) ';
            }  
        }

        // to validate expression we can perform a dummy query to ensure that it is not a malformed query otherwise it will go into catch block
        List<sObject> recordsList = Database.query('SELECT Id FROM '+ INSTALLED_PRODUCT_OBJECT + ' WHERE '+ queryString + ' LIMIT 0');
        // Query Validation Logic ends here
         return createChangeOrderCriteria(INSTALLED_PRODUCT_SEARCH_TYPE, JSON.serialize(searchExpression), fcoSfId, queryString, sequence);
    }

    /** Created By: Arpit
    * Used to get batch lot results
    * @parameter String whereClause, Boolean isPreviewResult, Set<String> batchLotIds, Boolean isBatchLotObject
    * @return BatchLotResultWrapper
    */
    private BatchLotResultWrapper getBatchLotResult(String whereClause, Boolean isPreviewResult, Set<String> batchLotIds, Boolean isBatchLotObject){
        List<SVMXC__SM_Batch_Lot__c> batchLotRecords = new List<SVMXC__SM_Batch_Lot__c> ();
        List<SVMXC__Product_Serial__c> serializedRecords = new List<SVMXC__Product_Serial__c> ();
        BatchLotResultWrapper batchLotResultWrapper;
        Set<String> batchIds = new Set<String> ();
        String objectName = isBatchLotObject ? BATCH_LOT_MASTER_OBJECT : STOCKED_SERIAL_OBJECT;
        String batchIdQuery = BLANK_STRING;
        if(!batchLotIds.isEmpty()){
            batchIdQuery = isBatchLotObject ? ' Id IN :batchLotIds ' : ' SVMXC__SM_Batch_Lot2__c IN :batchLotIds ';
        }
        whereClause =  String.isBlank(batchIdQuery) ? whereClause : ' ( ' + batchIdQuery + ' ) AND ' + whereClause;
        String queryFields = isBatchLotObject ? isPreviewResult ? BATCH_MASTER_PREVIEW_FIELDS : ' Id, Name ' : isPreviewResult ? STOCKED_SERIAL_PREVIEW_FIELDS : 'Id, Name, '+BATCH_LOT_FIELD_ON_STOCKED_SERIAL + SPACE;
        String soqlQuery = 'SELECT '+ queryFields + ' FROM '+ objectName + ' WHERE ' + whereClause;
        if(isBatchLotObject){
            batchLotRecords = Database.query(soqlQuery);
            for(SVMXC__SM_Batch_Lot__c batchLotRecord : batchLotRecords){
                batchIds.add(batchLotRecord.Id);
            }
        }
        else{
            serializedRecords = Database.query(soqlQuery);
            for(SVMXC__Product_Serial__c stockSerialRecord : serializedRecords){
                if(String.isNotBlank(stockSerialRecord.SVMXC__SM_Batch_Lot2__c)){
                    batchIds.add(stockSerialRecord.SVMXC__SM_Batch_Lot2__c);
                }
            }
        }
        batchLotResultWrapper = new BatchLotResultWrapper(batchLotRecords, serializedRecords, batchIds, isBatchLotObject);
        return batchLotResultWrapper;
    }

    /* This is a wrapper class for batch lot search */
    public class BatchLotResultWrapper{
        public List<SVMXC__SM_Batch_Lot__c> batchLotRecords;
        public List<SVMXC__Product_Serial__c> serializedRecords;
        public Set<String> batchLotIdSet;
        public Boolean isBatchLotObject;
        public BatchLotResultWrapper(List<SVMXC__SM_Batch_Lot__c> batchLotRecords, List<SVMXC__Product_Serial__c> serializedRecords, Set<String> batchLotIdSet,  Boolean isBatchLotObject){
            this.batchLotRecords = batchLotRecords; 
            this.serializedRecords = serializedRecords;
            this.batchLotIdSet = batchLotIdSet;
            this.isBatchLotObject = isBatchLotObject;
        }
    }
   
    /** Created By: Arpit
    * Used to search installed product
    * @parameter String productId, String searchKeyword
    * @return CORD_WrapperDef.FCO_Response
    */
    public CORD_WrapperDef.FCO_Response searchInstalledProduct(String productId, String searchKeyword){

        System.debug( LoggingLevel.INFO, 'searchInstalledProduct() - enter' );
        System.debug( LoggingLevel.INFO, productId); 
        System.debug( LoggingLevel.INFO, searchKeyword);       
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        List<CORD_WrapperDef.SearchedProduct> productWrapper = new List<CORD_WrapperDef.SearchedProduct>();
        
        try {
            List<SVMXC__Installed_Product__c> installedProductList = new List<SVMXC__Installed_Product__c>();
            List<List<SObject>> searchResults = new List<List<SObject>>();
            searchKeyword = '*'+String.escapeSingleQuotes(searchKeyword)+'*';
            String searchQuery = 'FIND \'' + searchKeyword + '\' IN ALL FIELDS RETURNING  SVMXC__Installed_Product__c (Id, Name, SVMXC__Company__c, SVMXC__Company__r.Name, SVMXC__Serial_Lot_Number__c, SVMXC__Status__c, SVMXC__Site__c, SVMXC__Site__r.Name,SVMXC__SM_Batch_Lot2__c, SVMXC__SM_Batch_Lot2__r.Name WHERE SVMXC__Product__c =: productId ORDER BY Name ASC)';  // Not Putting LIMIT 2000, since it will be auto applied by salesforce   
            searchResults = Search.query(searchQuery);
            installedProductList = ((List<SVMXC__Installed_Product__c>) searchResults[0]);
            response.data = installedProductList;
        }
        
        catch(Exception e ){
            createExceptionLogs(e, response, 'searchInstalledProduct', BLANK_STRING);
        }

        finally {
            System.debug( LoggingLevel.INFO, 'searchInstalledProduct() - exit' );
        }
        return response;
    }

    /** Created By: Arpit
    * Used to get technical attributes
    * @parameter List<String> productRecordIdList
    * @return CORD_WrapperDef.FCO_Response
    */
    public CORD_WrapperDef.FCO_Response getTechAttributes(List<String> productRecordIdList){

        System.debug( LoggingLevel.INFO, 'getTechAttributes() - enter' );
        System.debug( LoggingLevel.INFO, productRecordIdList); 
        
        List<Product2> productList = [SELECT Id, Family, SVMXC__Product_Line__c FROM Product2 WHERE Id IN : productRecordIdList];
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        Map<String, List<CORD_WrapperDef.FCOFieldInfo>> productFieldInfoMap = new Map<String,  List<CORD_WrapperDef.FCOFieldInfo>> ();
        CORD_WrapperDef.TechBatchProductInfo techAttributeInfo = new CORD_WrapperDef.TechBatchProductInfo();
        try {
            for(Product2 product : productList){
                if(!productFieldInfoMap.containsKey(product.Id)){
                    List<CORD_WrapperDef.FCOFieldInfo> fieldInfoList = new List<CORD_WrapperDef.FCOFieldInfo> ();
                    productFieldInfoMap.put(product.Id, fieldInfoList); // initialize with empty list, if no template and fields found for this product
                    Map<String, CORD_WrapperDef.FCOFieldInfo> pickListFCOFieldMap = new Map<String, CORD_WrapperDef.FCOFieldInfo> ();
                    Map<String, CORD_WrapperDef.FCOFieldInfo> normalFCOFieldMap = new Map<String, CORD_WrapperDef.FCOFieldInfo> ();
                    // search the template for the provided product and get the fields
                    SVMXC__SM_Product_Attributes__c productAttribute = getProductAttribute(product);
            
                    String templateJSON = productAttribute != NULL && String.isNotBlank(productAttribute.SVMXC__SM_Attribute_Template_Id__r.SVMXC__SM_Template_Json__c) ? productAttribute.SVMXC__SM_Attribute_Template_Id__r.SVMXC__SM_Template_Json__c : BLANK_STRING;
                    
                    if(String.isNotBlank(templateJSON)){
                        //  deserialize template json into wrapper class
                        TechnicalAttributeConfiguration.IbInstancePayload templateJsonPayload =
                        (TechnicalAttributeConfiguration.IbInstancePayload) JSON.deserialize(templateJSON, TechnicalAttributeConfiguration.IbInstancePayload.class);
                        
                        // continue to collect fields information if fields are available on template
                        if(templateJsonPayload != NULL && templateJsonPayload.fields != NULL && !templateJsonPayload.fields.isEmpty()){
                           // List<TechnicalAttributeConfiguration.AttributesCategory> allSectionsOnTemplate = new List<TechnicalAttributeConfiguration.AttributesCategory> ();
                            //allSectionsOnTemplate = templateJsonPayload.fields; #reviewComment // In a template there can be multiple sections, newCategoryList contains all the sections
                            productFieldInfoMap.put(product.Id, getTechFieldsList(templateJsonPayload));
                        }
                    }
                }
            }
            techAttributeInfo.productFieldInfoMap = productFieldInfoMap;
            techAttributeInfo.fieldTypeWithOperators = createFieldTypeOperatorMap(fieldTypeOperatorForTechAtrribMap);
            response.data = techAttributeInfo;
        }
        
        catch(Exception e ){
            createExceptionLogs(e, response, 'getTechAttributes', BLANK_STRING);
        }

        finally {
            System.debug( LoggingLevel.INFO, 'getTechAttributes() - exit' );
        }
        return response;
    }

    /** Created By: Arpit
    * Used to get batch lot fields
    * @parameter List<String> productRecordIdList
    * @return CORD_WrapperDef.FCO_Response
    */
    public CORD_WrapperDef.FCO_Response getBatchLotFields(List<String> productRecordIdList){

        System.debug( LoggingLevel.INFO, 'getBatchLotFields() - enter' );
        System.debug( LoggingLevel.INFO, productRecordIdList); 
        
        List<Product2> productList = [SELECT Id, SVMXC__Stockable__c, SVMXC__SM_Enable_Batch_Lot_Tracking__c, SVMXC__Enable_Serialized_Tracking__c FROM Product2 WHERE Id IN : productRecordIdList AND SVMXC__Stockable__c = TRUE];
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        Map<String, List<CORD_WrapperDef.FCOFieldInfo>> productFieldInfoMap = new Map<String,  List<CORD_WrapperDef.FCOFieldInfo>> ();
        CORD_WrapperDef.TechBatchProductInfo batchLotProductInfo = new CORD_WrapperDef.TechBatchProductInfo();
        try {
                        
            CORD_WrapperDef.FCOFieldInfo serialNumberFieldInfo = new CORD_WrapperDef.FCOFieldInfo();
            serialNumberFieldInfo.fieldName = 'Name';
            serialNumberFieldInfo.fieldLabel = Label.FCO003_TAG030; 
            serialNumberFieldInfo.fieldType = 'STRING';

            CORD_WrapperDef.FCOFieldInfo batchLotFieldInfo = new CORD_WrapperDef.FCOFieldInfo();
            batchLotFieldInfo.fieldName = BATCH_LOT_NUMBER_PLACEHOLDER_FIELD; //blocker, its not blocker, let it be like this only so that we can send it to UI and identify in return that its batch lot object related search
            batchLotFieldInfo.fieldLabel = Label.FCO001_TAG071;
            batchLotFieldInfo.fieldType = 'STRING';

            for(Product2 product : productList){
                if(!productFieldInfoMap.containsKey(product.Id)){
                    List<CORD_WrapperDef.FCOFieldInfo> fieldInfoList = new List<CORD_WrapperDef.FCOFieldInfo> ();
                    if(product.SVMXC__SM_Enable_Batch_Lot_Tracking__c){
                        fieldInfoList.add(batchLotFieldInfo);
                    }
                    if(product.SVMXC__Enable_Serialized_Tracking__c){
                        fieldInfoList.add(serialNumberFieldInfo);
                    }
                    productFieldInfoMap.put(product.Id, fieldInfoList); // initialize with empty list, if no template and fields found for this product
                }
            }
            batchLotProductInfo.productFieldInfoMap = productFieldInfoMap;
            batchLotProductInfo.fieldTypeWithOperators = createFieldTypeOperatorMap(fieldTypeOperatorForBatchLotMap);
            response.data = batchLotProductInfo;
        }
        
        catch(Exception e ){
            createExceptionLogs(e, response, 'getBatchLotFields', BLANK_STRING);
        }

        finally {
            System.debug( LoggingLevel.INFO, 'getBatchLotFields() - exit' );
        }
        return response;
    }
 
    /** Created By: Arpit
    * Used to get attributes of the product
    * @parameter Product2 product
    * @return SVMXC__SM_Product_Attributes__c
    */
    private SVMXC__SM_Product_Attributes__c getProductAttribute(Product2 product){
        /* Precendency is first search based on product then product line and then product family */
          String prodId = product.Id;
          String productFamily = product.Family;
          String productLine = product.SVMXC__Product_Line__c;

          //#TODO ask for active/inactive templates // Update: as per discussion no check will be applied for active/inactive templates
          List<SVMXC__SM_Product_Attributes__c> productAttributes;
          String baseQuery = 'SELECT Id, SVMXC__SM_Product__c, SVMXC__SM_Attribute_Template_Id__r.SVMXC__SM_Template_Json__c FROM SVMXC__SM_Product_Attributes__c WHERE SVMXC__SM_Attribute_Template_Id__c != NULL ';
          String queryForProductId = baseQuery +' AND SVMXC__SM_Product__c =: prodId';
          String queryForProductFamily = String.isNotBlank(productFamily) ? baseQuery + ' AND SVMXC__SM_Product_Family__c =: productFamily ': BLANK_STRING;
          String queryForProductLine = String.isNotBlank(productLine) ?  baseQuery + ' AND SVMXC__SM_Product_Line__c =: productLine ' : BLANK_STRING;
          List<TechnicalAttributeConfiguration.Attribute> attributeList = new List<TechnicalAttributeConfiguration.Attribute> ();
           
          //execute the logic to get attributes
          productAttributes = Database.query(queryForProductId);
          if(productAttributes.isEmpty()){
              if(String.isNotBlank(queryForProductLine)){
                  productAttributes = Database.query(queryForProductLine);
              }
              if(productAttributes.isEmpty() && String.isNotBlank(queryForProductFamily)){
                  productAttributes = Database.query(queryForProductFamily);
              }
          }
          return productAttributes != NULL && !productAttributes.isEmpty() ? productAttributes[0] : NULL;
    }

    /** Created By: Arpit
    * Used to get Existing Picklist On Template
    * @parameter TechnicalAttributeConfiguration.IbInstancePayload templateJsonPayload
    * @return Map<String, List<CORD_WrapperDef.KeyValuePair>>
    */
    private Map<String, List<CORD_WrapperDef.KeyValuePair>> getExistingPicklistOnTemplate(TechnicalAttributeConfiguration.IbInstancePayload templateJsonPayload){
        Map<String, TechnicalAttributeConfiguration.AttributesPicklist> pickListStoredOnTemplate = templateJsonPayload.picklist;
        Map<String, List<CORD_WrapperDef.KeyValuePair>> existingPickListOnTemplateMap = new Map<String, List<CORD_WrapperDef.KeyValuePair>> ();
        for(String pickListName : pickListStoredOnTemplate.keySet()){
            List<CORD_WrapperDef.KeyValuePair> keyValuePairList = new List<CORD_WrapperDef.KeyValuePair> ();
            for(String picklistValue : pickListStoredOnTemplate.get(pickListName).values){
                keyValuePairList.add(new CORD_WrapperDef.KeyValuePair(picklistValue, picklistValue));
            }
           existingPickListOnTemplateMap.put(pickListName, keyValuePairList);
        }
        return existingPickListOnTemplateMap;
    }

    /** Created By: Arpit
    * Used to get technical attributes
    * @parameter TechnicalAttributeConfiguration.IbInstancePayload templateJsonPayload
    * @return List<CORD_WrapperDef.FCOFieldInfo>
    */
    private List<CORD_WrapperDef.FCOFieldInfo> getTechFieldsList(TechnicalAttributeConfiguration.IbInstancePayload templateJsonPayload){
        Map<String, List<CORD_WrapperDef.KeyValuePair>> existingPickListOnTemplateMap = templateJsonPayload.picklist != NULL && !(templateJsonPayload.picklist).isEmpty() ? getExistingPicklistOnTemplate(templateJsonPayload) : new Map<String, List<CORD_WrapperDef.KeyValuePair>> ();
        List<TechnicalAttributeConfiguration.AttributesCategory> allSectionsOnTemplate = templateJsonPayload.fields; // In a template there can be multiple sections, newCategoryList contains all the sections
       List<CORD_WrapperDef.FCOFieldInfo> fieldInfoList = new List<CORD_WrapperDef.FCOFieldInfo> ();
        List<CORD_WrapperDef.FCOFieldInfo> picklistFieldInfoList = new List<CORD_WrapperDef.FCOFieldInfo> ();
        Map<String, List<CORD_WrapperDef.KeyValuePair>> latestPickListMap = new Map<String, List<CORD_WrapperDef.KeyValuePair>> ();
        Map<String, String> picklistSfIdNameMap = new Map <String, String> ();

        // Iterate through each section/category to get fields(attribute)
        for (TechnicalAttributeConfiguration.AttributesCategory newCategory: allSectionsOnTemplate) {
            List <TechnicalAttributeConfiguration.Attribute> techAttributeList = newCategory.technicalAttributes;
           if(techAttributeList != NULL){
                for(TechnicalAttributeConfiguration.Attribute attribute : techAttributeList) {
                    CORD_WrapperDef.FCOFieldInfo fieldInfo = new CORD_WrapperDef.FCOFieldInfo();
                    fieldInfo.fieldLabel = attribute.label;
                    fieldInfo.fieldName = attribute.label;
                    fieldInfo.fieldType = techAttribDataTypeMap.get(attribute.format);
                    if(String.isNotBlank(attribute.picklistSfId)) {
                        fieldInfo.displayName = attribute.picklistId; // temporary mapping for picklist, will blank out once values are filled for picklist
                        picklistSfIdNameMap.put(attribute.picklistSfId, attribute.picklistId);
                        picklistFieldInfoList.add(fieldInfo);    
                    }
                    else{
                        fieldInfoList.add(fieldInfo);
                    }
                }
            }
        }

        if(!picklistSfIdNameMap.isEmpty()){
            latestPickListMap =  getPickListFromSF(new List<String> (picklistSfIdNameMap.keySet()));
            for(CORD_WrapperDef.FCOFieldInfo fieldInfo : picklistFieldInfoList){
                if(latestPickListMap.containsKey(fieldInfo.displayName)){
                    Map<String, List<CORD_WrapperDef.KeyValuePair>> picklistMap = new Map<String, List<CORD_WrapperDef.KeyValuePair>> {
                                                                                        fieldInfo.fieldName => latestPickListMap.get(fieldInfo.displayName)
                                                                                  };
                    fieldInfo.picklistMap = picklistMap;
                    fieldInfo.displayName = NULL;
                }
                else{
                    if(existingPickListOnTemplateMap.containsKey(fieldInfo.displayName)){
                        Map<String, List<CORD_WrapperDef.KeyValuePair>> picklistMap = new Map<String, List<CORD_WrapperDef.KeyValuePair>> {
                                    fieldInfo.fieldName => existingPickListOnTemplateMap.get(fieldInfo.displayName)
                                };
                        fieldInfo.picklistMap = picklistMap;
                        fieldInfo.displayName = NULL;
                    }
                }
            fieldInfoList.add(fieldInfo);
            }
        }
        return fieldInfoList;
        }

    /** Created By: Arpit
    * Used to get PickList values From SF
    * @parameter List<String> picklistRecordIdList
    * @return Map<String, List<CORD_WrapperDef.KeyValuePair>>
    */
    private Map<String, List<CORD_WrapperDef.KeyValuePair>> getPickListFromSF(List<String> picklistRecordIdList){
        Map<String, List<CORD_WrapperDef.KeyValuePair>> latestPickListMap = new Map<String, List<CORD_WrapperDef.KeyValuePair>> (); 
        List <SM_TA_Picklist_Definition__c> pklistDefRecords = [SELECT Id, SM_Name__c, SM_Values__c FROM SM_TA_Picklist_Definition__c
        WHERE Id IN: picklistRecordIdList];
        for (SM_TA_Picklist_Definition__c pikcklistDefRecord: pklistDefRecords) {
            TechnicalAttributeConfiguration.AttributesPicklist attributePicklist =
                (TechnicalAttributeConfiguration.AttributesPicklist) JSON.deserialize(pikcklistDefRecord.SM_Values__c, TechnicalAttributeConfiguration.AttributesPicklist.class);
        
                List<CORD_WrapperDef.KeyValuePair> keyValuePairs = new List<CORD_WrapperDef.KeyValuePair> ();
                List<CORD_WrapperDef.KeyValuePair> pickListKeyValuePair = new List<CORD_WrapperDef.KeyValuePair> ();
                for(String picklistVal : attributePicklist.values){
                    pickListKeyValuePair.add(new CORD_WrapperDef.KeyValuePair(picklistVal, picklistVal));
                }
                latestPickListMap.put(pikcklistDefRecord.SM_Name__c, pickListKeyValuePair);
        }
        return latestPickListMap;
    }

     /** Created By: Arpit
     * Used to delete fco lines
     * @parameter CORD_WrapperDef.Expression expression
     * @return String
     */
      private Boolean deleteFCOLinesAndLogs(String fcoSfId, CORD_WrapperDef.FCO_Response response){
        Boolean isDeleteSuccessfull = true;
        try{
            List<SVMXC__SM_Change_Order_Log__c> changeOrderLogList = [SELECT Id FROM SVMXC__SM_Change_Order_Log__c WHERE SVMXC__SM_Change_Order__c =: fcoSfId];
            Map<Id, SVMXC__SM_Change_Order_Line__c> changeOrderLinesMap = new Map<Id, SVMXC__SM_Change_Order_Line__c> ([SELECT Id FROM SVMXC__SM_Change_Order_Line__c WHERE SVMXC__SM_Change_Order__c =: fcoSfId]);
            if(!changeOrderLogList.isEmpty() || !changeOrderLinesMap.isEmpty()){
                Schema.DescribeSObjectResult changeOrderLineDescribeResult = getGlobalDescribe().get(FCO_LINE_OBJECT).getDescribe(); //#defectFix-6261
                Boolean isFCOLineDeletable = changeOrderLineDescribeResult.isDeletable(); //#defectFix-6261
               if(isFCOLineDeletable){
                    if(!changeOrderLogList.isEmpty()){
                        delete changeOrderLogList;
                    }
                    if(!changeOrderLinesMap.isEmpty()){
                        delete changeOrderLinesMap.values();
                        hardDeleteFCOLines(changeOrderLinesMap.keySet());
                    }
               }
               else{
                    isDeleteSuccessfull = false;
                    createExceptionLogs(null, response, 'deleteFCOLinesAndLogs',Label.COMM001_TAG142); 
               }
            }
        }
        catch(Exception e ){
            isDeleteSuccessfull = false;
            createExceptionLogs(e, response, 'deleteFCOLinesAndLogs', BLANK_STRING);
        }
        return isDeleteSuccessfull;
    }

    
    /** Created By: Arpit
     * Used to delete fco lines from recycle bin
     * @parameter CORD_WrapperDef.Expression expression
     * @return String
     */
    @future
    public static void hardDeleteFCOLines(Set<Id> changeOrderLineSet) {
        Database.emptyRecycleBin(new List<Id> (changeOrderLineSet));
    }

    /** Created By: Arpit
     * Used to get search expression
     * @parameter N/A
     * @return Returns CORD_WrapperDef.FCO_Response
     */ 
    public CORD_WrapperDef.FCOSearchExpressions getSearchExpression(final String fcoSfId ) {
        CORD_WrapperDef.FCOSearchExpressions searchExpressions = new CORD_WrapperDef.FCOSearchExpressions();
        try { 
            List<SVMXC__SM_Change_Order_Criteria__c> searchCriteriaList = [SELECT SVMXC__SM_Type__c,SVMXC__SM_Criteria_Definition__c FROM SVMXC__SM_Change_Order_Criteria__c WHERE SVMXC__SM_Change_Order__c =: fcoSfId AND SVMXC__SM_Type__c != NULL ORDER BY SVMXC__SM_Sequence__c ASC];
            Map<String, CORD_WrapperDef.SearchedProduct> productInfoMap = new Map<String, CORD_WrapperDef.SearchedProduct> ();            
            for(SVMXC__SM_Change_Order_Criteria__c criteria : searchCriteriaList){ 
                CORD_WrapperDef.FCOSearchExpression searchExpression = (CORD_WrapperDef.FCOSearchExpression) JSON.deserialize(criteria.SVMXC__SM_Criteria_Definition__c, CORD_WrapperDef.FCOSearchExpression.class);
                String criteriaType = criteria.SVMXC__SM_Type__c;
               for(CORD_WrapperDef.ExpressionRows expressionRow : searchExpression.ExpressionRows){
                    String productId = expressionRow.selectedProductId;
                    if(String.isNotBlank(productId) && !productInfoMap.containsKey(productId)){
                        productInfoMap.put(productId, getProductInfo(productId));
                    }
                    expressionRow.selectedProductInfo = productInfoMap.containsKey(productId) ? productInfoMap.get(productId) : NULL;
                }
                if(criteriaType.equalsIgnoreCase(INSTALLED_PRODUCT_SEARCH_TYPE)){
                    searchExpressions.instProdExpression = searchExpression;
                }
                else if(criteriaType.equalsIgnoreCase(TECH_ATTRIB_SEARCH_TYPE)){
                    searchExpressions.techAttribExpression = searchExpression;
                }
                else{
                    searchExpressions.batchLotExpression = searchExpression;
                }
            }
        }   
        
        catch(Exception e ){
            System.debug('Error==>'+ e.getMessage());
            System.debug( LoggingLevel.ERROR, 'getSearchExpression Failed;  Error=' + e.getStackTraceString() );
        }

        finally {
            System.debug( LoggingLevel.INFO, 'getSearchExpression() - exit' );
        }
        return searchExpressions;
}


    /** Created By: Arpit
     * Used to create search expression at column level
     * @parameter CORD_WrapperDef.Expression expression
     * @return String
     */ 
    private String createQueryFromExpression(CORD_WrapperDef.Expression expression, String searchType){
        String value = String.isNotBlank(expression.value) ? String.escapeSingleQuotes(expression.value.trim()) : BLANK_STRING;
        String operator = operatorSymbolMap.get(expression.operator);
        String fieldType = expression.fieldType;
        String fieldName = fieldType.equalsIgnoreCase('REFERENCE') ? expression.displayName : expression.fieldName;
        fieldName = searchType.equalsIgnoreCase(BATCH_LOT_SEARCH_TYPE) && fieldName.equalsIgnoreCase(BATCH_LOT_NUMBER_PLACEHOLDER_FIELD) ? 'Name' : fieldName;
        String queryExpression = BLANK_STRING;

        if(operator.equalsIgnoreCase('LIKE')){ // we are giving contains (like) options for STRING, REFERENCE, PHONE, EMAIL, PICKLIST, MULTIPICKLIST only, not to numbers. So not putting check for dataType since all of them would need % symbol for query
             value = '\'%' + value + '%\'';
        }
        else if(operator.equalsIgnoreCase('STARTS_WITH')){ // #TODO #constant declaration // we are giving contains (like) options for STRING, REFERENCE, PHONE, EMAIL, PICKLIST, MULTIPICKLIST only, not to numbers. So not putting check for dataType since all of them would need % symbol for query
            value = '\'' +value + '%\'';
            operator = 'LIKE'; // since 'starts with' operator will also be treated as like keyword
       }
        else if(operator.equalsIgnoreCase('INCLUDES') || operator.equalsIgnoreCase('EXCLUDES')){ // to support includes and excludes for multipicklist
            value = '(\''+ value + '\')';
        }
        else if(String.isNotBlank(value) && fieldType.equalsIgnoreCase('DATETIME')){
            fieldName = 'DAY_ONLY(convertTimezone('+fieldName+'))';
        }
        else if(STRING_EQVLNT_TYPES.CONTAINS(fieldType) && !expression.operator.containsIgnoreCase('NULL')){
            value = '\'' + value + '\'';
            if(expression.operator.equalsIgnoreCase('lt') || expression.operator.equalsIgnoreCase('lte')){ //#defectFix BAC-5928
                queryExpression = '(' + fieldName + ' != NULL AND ';
            }
        }        
        if(searchType.equalsIgnoreCase(TECH_ATTRIB_SEARCH_TYPE)){
            fieldName = '\'' + fieldName + '\'';
            String baseQuery = '(SVMXC__SM_Attr_Name__c ='+ fieldName +' AND ';
            queryExpression =  baseQuery + techAttribDataTypeToField.get(fieldType) + SPACE + operator + SPACE + value + ')';
        }
        else{
            queryExpression +=  fieldName + SPACE + operator + SPACE + value;
           // queryExpression += (STRING_EQVLNT_TYPES.CONTAINS(fieldType) && !expression.operator.containsIgnoreCase('NULL') && expression.operator.equalsIgnoreCase('lt') || expression.operator.equalsIgnoreCase('lte')) ? ')' : BLANK_STRING;
              queryExpression += (STRING_EQVLNT_TYPES.CONTAINS(fieldType) && !expression.operator.containsIgnoreCase('NULL') && (expression.operator.equalsIgnoreCase('lt') || expression.operator.equalsIgnoreCase('lte'))) ? ')' : BLANK_STRING;
           queryExpression = expression.operator.equalsIgnoreCase('nocntn') ? '( NOT '+ queryExpression +')' : queryExpression;
        }
        System.debug('queryExpression@@'+queryExpression);
        return queryExpression;
    }

    /** Created By: Arpit
     * Used to get sorted list of fields
     * @parameter Map<String, CORD_WrapperDef.FCOFieldInfo> fieldsMap
     * @return List<CORD_WrapperDef.FCOFieldInfo>
     */ 
    private List<CORD_WrapperDef.FCOFieldInfo> getSortedFields(Map<String, CORD_WrapperDef.FCOFieldInfo> fieldsMap, Map<String, String> fieldNameInfoMapUpperCase){
        List<String> fieldList = new List<String>(fieldNameInfoMapUpperCase.keySet());
        fieldList.sort();
        List<CORD_WrapperDef.FCOFieldInfo> sortedFieldList = new List<CORD_WrapperDef.FCOFieldInfo> ();
        for(String field : fieldList){
            sortedFieldList.add(fieldsMap.get(fieldNameInfoMapUpperCase.get(field)));
        }
        return sortedFieldList;

    }

    /** Created By: Arpit
     * Used to get additional fields for fco line tab
     * @parameter NA
     * @return List<CORD_WrapperDef.FCOFieldInfo>
     */ 
    @testvisible
    private static List<CORD_WrapperDef.FCOFieldInfo> getAdditionalFieldsForWokrOrder(){
        COMM_Utils_DescribeCall describeInstance = COMM_Utils_DescribeCall.getInstance();
        Map<String,Schema.SObjectField> fieldMapIB = COMM_Utils_DescribeCall.getObjectFieldDetails(INSTALLED_PRODUCT_OBJECT); // needed to set field label
        CORD_WrapperDef.FCOFieldInfo fieldInfoSerialNo = new CORD_WrapperDef.FCOFieldInfo();
        fieldInfoSerialNo.fieldName = 'SVMXC__Component__r.SVMXC__Serial_Lot_Number__c';
        fieldInfoSerialNo.fieldLabel = fieldMapIB.get('SVMXC__Serial_Lot_Number__c').getDescribe().getLabel(); //describeInstance.describeField(fieldMapIB.get('SVMXC__Serial_Lot_Number__c')).getLabel();
        fieldInfoSerialNo.fieldType = 'STRING';

        return new List<CORD_WrapperDef.FCOFieldInfo> {fieldInfoSerialNo};
    }

    /** Created By: Arpit
     * Used to create wrapper of product information
     * @parameter String productId
     * @return CORD_WrapperDef.SearchedProduct
     */ 
    private CORD_WrapperDef.SearchedProduct getProductInfo(String productId){
        List<Product2> productList = [SELECT Name, toLabel(Family), toLabel(SVMXC__Product_Line__c), IsActive FROM Product2 WHERE Id =: productId]; 
        return !productList.isEmpty() ? createProductInfo(productList[0]) : new CORD_WrapperDef.SearchedProduct();
    }

    /** Created By: Arpit
     * Used to create wrapper of product information
     * @parameter Product2 productRecord
     * @return CORD_WrapperDef.SearchedProduct
     */ 
    private CORD_WrapperDef.SearchedProduct createProductInfo(Product2 productRecord) {
            CORD_WrapperDef.SearchedProduct wrapperInstance = new CORD_WrapperDef.SearchedProduct();
            wrapperInstance.value = productRecord.Id;
            wrapperInstance.label = productRecord.Name;
            String productLine = String.isNotBlank(productRecord.SVMXC__Product_Line__c) ? productRecord.SVMXC__Product_Line__c : '--';
            String productFamily = String.isNotBlank(productRecord.Family) ? productRecord.Family : '--';
            String isActive = productRecord.IsActive ? 'Active' : 'InActive';
            wrapperInstance.meta = productLine + ' / '+ productFamily + ' / '+ isActive; 
            return wrapperInstance;
    }

    /** Created By: Arpit
     * Used to create instance of change order criteria
     * @parameter String searchType, String searchExpression, String fcoSfId, String queryString, Integer sequence
     * @return SVMXC__SM_Change_Order_Criteria__c
     */
    @testvisible
    private SVMXC__SM_Change_Order_Criteria__c createChangeOrderCriteria(String searchType, String searchExpression, String fcoSfId, String queryString, Integer sequence){
        SVMXC__SM_Change_Order_Criteria__c changeOrderCriteria = new SVMXC__SM_Change_Order_Criteria__c(
                                                                            SVMXC__SM_Type__c = searchType, 
                                                                            SVMXC__SM_Criteria_Definition__c = searchExpression,
                                                                            SVMXC__SM_Change_Order__c = fcoSfId, 
                                                                            SVMXC__SM_Object_Criteria__c = queryString, 
                                                                            SVMXC__SM_Sequence__c = sequence
                                                                        );
        return changeOrderCriteria;
    }

    /** Created By: Arpit
     * Used to get change order details with configuration
     * @parameter String fcoSfId
     * @return SVMXC__SM_Change_Order__c
     */
    @testvisible
    private SVMXC__SM_Change_Order__c getFCOConfigTemplateDetails(String fcoSfId){
        List<SVMXC__SM_Change_Order__c> changeOrderList = [SELECT SVMXC__SM_CORD_Config__c, SVMXC__SM_CORD_Config__r.SVMXC__SM_Process1__c, SVMXC__SM_CORD_Config__r.SVMXC__SM_Process2__c, SVMXC__SM_CORD_Config__r.SVMXC__SM_Name__c FROM SVMXC__SM_Change_Order__c WHERE Id =: fcoSfId AND SVMXC__SM_CORD_Config__c != NULL];
        SVMXC__SM_Change_Order__c changeOrder = !changeOrderList.isEmpty() ? changeOrderList[0] : NULL;
        return changeOrder;
    }

    /** Created By: Arpit
     * Used to convert gmt time to logged in user time
     * @parameter DateTime gmtDateTime
     * @return DateTime
     */ 
    public static DateTime getUserDateTime(DateTime gmtDateTime){
        return gmtDateTime.addSeconds((userTimeZone.getOffset(gmtDateTime)/1000));
    }

    /** Created By: Arpit
     * Used to create email body for fco owner once work order batch gets completed
     * @parameter String batchType, SVMXC__SM_Change_Order__c changeOrder, Integer totalNoOfRecord, Integer failureCount, SVMXC__SM_Change_Order_Log__c changeOrderLog
     * @return String
     */ 
    public static String getEmailBodyForFCOAdmin(String batchType, SVMXC__SM_Change_Order__c changeOrder, Integer totalNoOfRecord, Integer failureCount, SVMXC__SM_Change_Order_Log__c changeOrderLog){
        String orgBaseUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/';
        //String changeOrderLink = '<a href="' + orgBaseUrl + changeOrder.Id + '" target ="__blank">' + changeOrder.SVMXC__SM_Title__c + '</a>';
        String changeOrderTitle = changeOrder.SVMXC__SM_Title__c;
        String changeOrderLogLink = '<a href="' + orgBaseUrl + changeOrderLog.Id + '" target ="__blank">' + orgBaseUrl + changeOrder.Id + '</a>';
        String processingTime = String.valueOf(((changeOrderLog.SVMXC__SM_Completed_On__c).getTime() - (changeOrderLog.SVMXC__SM_Started_On__c).getTime()) / (1000 * 60));       
        String emailBody = Label.FCO001_TAG036 + '<br/><br/>'; // FCO001_TAG036: NOTE: THIS IS A SYSTEM GENERATED EMAIL. PLEASE DO NOT REPLY TO THIS MESSAGE.   
        emailBody += Label.FCO001_TAG037 + '<br/><br/>'; // FCO001_TAG037: A Change Order Process has completed with the following results: 
        emailBody += '<b>' + Label.FCO001_TAG038 + COLON_WITH_SPACE + '</b>' + batchType + ' ' + changeOrderTitle + ' ' + '<br/><br/>'; // FCO001_TAG038: Type/Name of Batch Process:    // batchType: FCO Results for  / WO Generation for 
        emailBody += '<b>' + Label.FCO001_TAG041 + COLON_WITH_SPACE + '</b>' + totalNoOfRecord + '<br/>'; // FCO001_TAG041 : Records to Process     
        emailBody += '<b>' + Label.FCO001_TAG043 + COLON_WITH_SPACE + '</b>' + (totalNoOfRecord - failureCount) + '<br/>'; // FCO001_TAG043 : Success       
        emailBody += '<b>' + Label.FCO001_TAG045 + COLON_WITH_SPACE + '</b>' + failureCount + '<br/><br/>'; // FCO001_TAG045 : Failed   
        emailBody += '<b>' + Label.FCO001_TAG047 + COLON_WITH_SPACE + '</b>' + changeOrderLog.SVMXC__SM_Started_On__c + ' - ' + userTimeZoneDisplayName + '<br/>'; // FCO001_TAG047: Change Order Process Start Time
        emailBody += '<b>' + Label.FCO001_TAG048 + COLON_WITH_SPACE + '</b>' + changeOrderLog.SVMXC__SM_Completed_On__c + ' - ' + userTimeZoneDisplayName + '<br/>'; // FCO001_TAG048: Change Order Process Finish Time
        emailBody += '<b>' + Label.FCO001_TAG049 + COLON_WITH_SPACE + '</b>' + processingTime + '<br/><br/>'; // FCO001_TAG049: Elapsed Time in minutes
        emailBody += Label.FCO001_TAG050 + '<br/>' + changeOrderLogLink + '<br/>'; // FCO001_TAG050: For more information, review the below log record: 
        return emailBody;
    }

    /** Created By: Arpit
     * Used to create email body for fco owner once work order batch gets completed
     * @parameter SVMXC__SM_Change_Order__c changeOrder, Integer totalNoOfRecord, Integer failureCount, SVMXC__SM_Change_Order_Log__c changeOrderLog
     * @return String
     */ 
    public static String getEmailBodyWOForOwner(SVMXC__SM_Change_Order__c changeOrder, Integer totalNoOfRecord, Integer failureCount, SVMXC__SM_Change_Order_Log__c changeOrderLog){
        String changeOrderName = changeOrder.SVMXC__SM_Title__c;
        String processingTime = String.valueOf(((changeOrderLog.SVMXC__SM_Completed_On__c).getTime() - (changeOrderLog.SVMXC__SM_Started_On__c).getTime()) / (1000 * 60));       
        String emailBody = Label.FCO001_TAG036 + '<br/><br/>'; // Value: NOTE: THIS IS A SYSTEM GENERATED EMAIL. PLEASE DO NOT REPLY TO THIS MESSAGE.   
        emailBody += Label.FCO001_TAG053 + SPACE + changeOrderName + SPACE + Label.FCO001_TAG054 + COLON_WITH_SPACE + '<br/><br/>'; // FCO001_TAG053 Value: The Work Order Generation Process for    // FCO001_TAG054: has completed with the following results:        
        emailBody += '<b>' + Label.FCO001_TAG055 + COLON_WITH_SPACE + '</b>' + totalNoOfRecord  + '<br/>'; // FCO001_TAG055: Total Work Orders to Create     
        emailBody += '<b>' + Label.FCO001_TAG056 + COLON_WITH_SPACE + '</b>' + (totalNoOfRecord - failureCount)  + '<br/><br/>'; // FCO001_TAG056: FCO001_TAG056: Number of Work Orders Successfully Created    
        emailBody += '<b>' + Label.FCO001_TAG042 + COLON_WITH_SPACE + '</b>'  + changeOrderLog.SVMXC__SM_Started_On__c + ' - ' + userTimeZoneDisplayName + '<br/>'; // FCO001_TAG042 : Work Order Generation Process Start Time 
        emailBody += '<b>' + Label.FCO001_TAG044 + COLON_WITH_SPACE + '</b>' + changeOrderLog.SVMXC__SM_Completed_On__c + ' - ' + userTimeZoneDisplayName + '<br/>'; // FCO001_TAG044 : Work Order Generation Process Finish Time   
        emailBody += '<b>' + Label.FCO001_TAG046 + COLON_WITH_SPACE + '</b>' + processingTime + '<br/>'; // value 45 : Failed:  // FCO001_TAG046 : Elapsed Time in minutes: 
        return emailBody;
    }

    /** Created By: Arpit
     * Used to create email body for fco owner once fco line batch gets completed
     * @parameter SVMXC__SM_Change_Order__c changeOrder, Integer totalNoOfRecord, Integer failureCount, SVMXC__SM_Change_Order_Log__c changeOrderLog
     * @return String
     */ 
    public static String getEmailBodyFCOLineForOwner(SVMXC__SM_Change_Order__c changeOrder, Integer totalNoOfRecord, Integer failureCount, SVMXC__SM_Change_Order_Log__c changeOrderLog){
        String changeOrderName = changeOrder.SVMXC__SM_Title__c;
        String processingTime = String.valueOf(((changeOrderLog.SVMXC__SM_Completed_On__c).getTime() - (changeOrderLog.SVMXC__SM_Started_On__c).getTime()) / (1000 * 60));       
        String emailBody = Label.FCO001_TAG036 + '<br/><br/>'; // Value: NOTE: THIS IS A SYSTEM GENERATED EMAIL. PLEASE DO NOT REPLY TO THIS MESSAGE.   
        emailBody += Label.FCO001_TAG065 + SPACE + changeOrderName + SPACE + Label.FCO001_TAG054 + COLON_WITH_SPACE + '<br/><br/>'; // FCO001_TAG065 Value: The FCO Search Process for   // FCO001_TAG054: has completed with the following results:        
        emailBody += '<b>' + Label.FCO001_TAG066 + COLON_WITH_SPACE + '</b>' + (totalNoOfRecord - failureCount)  + '<br/><br/>'; // FCO001_TAG066: Total Results Found   
        emailBody += '<b>' + Label.FCO001_TAG067 + COLON_WITH_SPACE + '</b>'  + changeOrderLog.SVMXC__SM_Started_On__c + ' - ' + userTimeZoneDisplayName + '<br/>'; // FCO001_TAG067 : Work Order Generation Process Start Time 
        emailBody += '<b>' + Label.FCO001_TAG068 + COLON_WITH_SPACE + '</b>' + changeOrderLog.SVMXC__SM_Completed_On__c + ' - ' + userTimeZoneDisplayName + '<br/>'; // FCO001_TAG068 : FCO Search Finish Time  
        emailBody += '<b>' + Label.FCO001_TAG046 + COLON_WITH_SPACE + '</b>' + processingTime + '<br/>'; // FCO001_TAG046 : Elapsed Time in minutes:    
        return emailBody;
    }


    /** Created By: Arpit
     * Used to clone FCO Record
     * @parameter String fcoSfId
     * @return Returns CORD_WrapperDef.FCO_Response
     */ 
    public CORD_WrapperDef.FCO_Response getCustomLabels() {
        System.debug( LoggingLevel.INFO, 'getCustomLabels() - enter' );

        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        List<CORD_WrapperDef.KeyValuePair> listCustomLabels = new List<CORD_WrapperDef.KeyValuePair>();
        Map<String, String> mapCustomLabels = new Map<String, String>();
        try{
            //custom labels
            mapCustomLabels.put('FCO003_HLPURL',Label.FCO003_HLPURL);
            mapCustomLabels.put('FCO003_TAG001',Label.FCO003_TAG001);
            mapCustomLabels.put('FCO003_TAG002',Label.FCO003_TAG002);
            mapCustomLabels.put('FCO003_TAG003',Label.FCO003_TAG003);
            mapCustomLabels.put('FCO003_TAG004',Label.FCO003_TAG004);
            mapCustomLabels.put('FCO003_TAG005',Label.FCO003_TAG005);
            mapCustomLabels.put('FCO003_TAG006',Label.FCO003_TAG006);
            mapCustomLabels.put('FCO003_TAG007',Label.FCO003_TAG007);
            mapCustomLabels.put('FCO003_TAG008',Label.FCO003_TAG008);
            mapCustomLabels.put('FCO003_TAG009',Label.FCO003_TAG009);
            mapCustomLabels.put('FCO003_TAG010',Label.FCO003_TAG010);
            mapCustomLabels.put('FCO003_TAG011',Label.FCO003_TAG011);
            mapCustomLabels.put('FCO003_TAG012',Label.FCO003_TAG012);
            mapCustomLabels.put('FCO003_TAG013',Label.FCO003_TAG013);
            mapCustomLabels.put('FCO003_TAG014',Label.FCO003_TAG014);
            mapCustomLabels.put('FCO003_TAG015',Label.FCO003_TAG015);
            mapCustomLabels.put('FCO003_TAG016',Label.FCO003_TAG016);
            mapCustomLabels.put('FCO003_TAG017',Label.FCO003_TAG017);
            mapCustomLabels.put('FCO003_TAG018',Label.FCO003_TAG018);
            mapCustomLabels.put('FCO003_TAG019',Label.FCO003_TAG019);
            mapCustomLabels.put('FCO003_TAG020',Label.FCO003_TAG020);
            mapCustomLabels.put('FCO003_TAG021',Label.FCO003_TAG021);
            mapCustomLabels.put('FCO003_TAG022',Label.FCO003_TAG022);
            mapCustomLabels.put('FCO003_TAG023',Label.FCO003_TAG023);
            mapCustomLabels.put('FCO003_TAG024',Label.FCO003_TAG024);
            mapCustomLabels.put('FCO003_TAG025',Label.FCO003_TAG025);
            mapCustomLabels.put('FCO003_TAG026',Label.FCO003_TAG026);
            mapCustomLabels.put('FCO003_TAG027',Label.FCO003_TAG027);
            mapCustomLabels.put('FCO003_TAG028',Label.FCO003_TAG028);
            mapCustomLabels.put('FCO003_TAG029',Label.FCO003_TAG029);
            mapCustomLabels.put('FCO003_TAG030',Label.FCO003_TAG030);
            mapCustomLabels.put('FCO003_TAG031',Label.FCO003_TAG031);
            mapCustomLabels.put('FCO003_TAG032',Label.FCO003_TAG032);
            mapCustomLabels.put('FCO003_TAG033',Label.FCO003_TAG033);
            mapCustomLabels.put('FCO003_TAG034',Label.FCO003_TAG034);
            mapCustomLabels.put('FCO003_TAG035',Label.FCO003_TAG035);
            mapCustomLabels.put('FCO003_TAG036',Label.FCO003_TAG036);
            mapCustomLabels.put('FCO003_TAG037',Label.FCO003_TAG037);
            mapCustomLabels.put('FCO003_TAG038',Label.FCO003_TAG038);
            mapCustomLabels.put('FCO003_TAG039',Label.FCO003_TAG039);   
            mapCustomLabels.put('FCO003_TAG040',Label.FCO003_TAG040);   
            mapCustomLabels.put('FCO003_TAG041',Label.FCO003_TAG041);   
            mapCustomLabels.put('FCO003_TAG042',Label.FCO003_TAG042);   
            mapCustomLabels.put('FCO003_TAG043',Label.FCO003_TAG043); 
            mapCustomLabels.put('FCO003_TAG044',Label.FCO003_TAG044); 
            mapCustomLabels.put('FCO003_TAG045',Label.FCO003_TAG045); 
            mapCustomLabels.put('FCO003_TAG046',Label.FCO003_TAG046); 
            mapCustomLabels.put('FCO003_TAG047',Label.FCO003_TAG047); 
            mapCustomLabels.put('FCO003_TAG048',Label.FCO003_TAG048); 
            mapCustomLabels.put('FCO003_TAG049',Label.FCO003_TAG049); 
            mapCustomLabels.put('FCO003_TAG050',Label.FCO003_TAG050); 
            mapCustomLabels.put('FCO003_TAG051',Label.FCO003_TAG051); 
            mapCustomLabels.put('FCO003_TAG052',Label.FCO003_TAG052); 
            mapCustomLabels.put('FCO003_TAG053',Label.FCO003_TAG053); 
            mapCustomLabels.put('FCO003_TAG054',Label.FCO003_TAG054); 
            mapCustomLabels.put('FCO003_TAG055',Label.FCO003_TAG055); 
            mapCustomLabels.put('FCO003_TAG056',Label.FCO003_TAG056); 
            mapCustomLabels.put('FCO003_TAG057',Label.FCO003_TAG057); 
            mapCustomLabels.put('FCO003_TAG058',Label.FCO003_TAG058); 
            mapCustomLabels.put('FCO003_TAG059',Label.FCO003_TAG059); 
            mapCustomLabels.put('FCO003_TAG060',Label.FCO003_TAG060);
            mapCustomLabels.put('FCO003_TAG061',Label.FCO003_TAG061);
            mapCustomLabels.put('FCO003_TAG062',Label.FCO003_TAG062);
            mapCustomLabels.put('FCO003_TAG063',Label.FCO003_TAG063);
            mapCustomLabels.put('FCO003_TAG064',Label.FCO003_TAG064);
            mapCustomLabels.put('FCO003_TAG065',Label.FCO003_TAG065);
            mapCustomLabels.put('FCO003_TAG066',Label.FCO003_TAG066);
            mapCustomLabels.put('FCO003_TAG067',Label.FCO003_TAG067);
            mapCustomLabels.put('FCO003_TAG068',Label.FCO003_TAG068);
            mapCustomLabels.put('FCO003_TAG069',Label.FCO003_TAG069);
            mapCustomLabels.put('FCO003_TAG070',Label.FCO003_TAG070);
            mapCustomLabels.put('FCO003_TAG071',Label.FCO003_TAG071);
            mapCustomLabels.put('FCO003_TAG072',Label.FCO003_TAG072);
            mapCustomLabels.put('FCO003_TAG073',Label.FCO003_TAG073);
            mapCustomLabels.put('FCO003_TAG074',Label.FCO003_TAG074);
            mapCustomLabels.put('FCO003_TAG075',Label.FCO003_TAG075);
            mapCustomLabels.put('FCO003_TAG076',Label.FCO003_TAG076);
            mapCustomLabels.put('FCO003_TAG077',Label.FCO003_TAG077);
            mapCustomLabels.put('FCO003_TAG078',Label.FCO003_TAG078);
            mapCustomLabels.put('FCO003_TAG079',Label.FCO003_TAG079);
            mapCustomLabels.put('FCO003_TAG080',Label.FCO003_TAG080);
            mapCustomLabels.put('FCO003_TAG081',Label.FCO003_TAG081);
            mapCustomLabels.put('FCO003_TAG082',Label.FCO003_TAG082);
            mapCustomLabels.put('FCO003_TAG083',Label.FCO003_TAG083);
            mapCustomLabels.put('FCO003_TAG084',Label.FCO003_TAG084);
            mapCustomLabels.put('FCO003_TAG085',Label.FCO003_TAG085);
            mapCustomLabels.put('FCO003_TAG086',Label.FCO003_TAG086);
            mapCustomLabels.put('FCO003_TAG087',Label.FCO003_TAG087);
            mapCustomLabels.put('FCO003_TAG088',Label.FCO003_TAG088);
            mapCustomLabels.put('FCO003_TAG089',Label.FCO003_TAG089);
            mapCustomLabels.put('FCO003_TAG090',Label.FCO003_TAG090);
            mapCustomLabels.put('FCO003_TAG091',Label.FCO003_TAG091);
            mapCustomLabels.put('FCO003_TAG092',Label.FCO003_TAG092);
            mapCustomLabels.put('FCO003_TAG093',Label.FCO003_TAG093);
            mapCustomLabels.put('FCO003_TAG094',Label.FCO003_TAG094);
            mapCustomLabels.put('FCO003_TAG095',Label.FCO003_TAG095);
            mapCustomLabels.put('FCO003_TAG096',Label.FCO003_TAG096);
            mapCustomLabels.put('FCO003_TAG097',Label.FCO003_TAG097);
            mapCustomLabels.put('FCO003_TAG098',Label.FCO003_TAG098);
            mapCustomLabels.put('FCO003_TAG099',Label.FCO003_TAG099);
            mapCustomLabels.put('FCO003_TAG100',Label.FCO003_TAG100);
            mapCustomLabels.put('FCO003_TAG101',Label.FCO003_TAG101);
            mapCustomLabels.put('FCO003_TAG102',Label.FCO003_TAG102);
            mapCustomLabels.put('FCO003_TAG103',Label.FCO003_TAG103);
            mapCustomLabels.put('FCO003_TAG104',Label.FCO003_TAG104);
            mapCustomLabels.put('FCO003_TAG105',Label.FCO003_TAG105);
            mapCustomLabels.put('FCO003_TAG106',Label.FCO003_TAG106);
            mapCustomLabels.put('FCO003_TAG107',Label.FCO003_TAG107);
            mapCustomLabels.put('FCO003_TAG108',Label.FCO003_TAG108);
            mapCustomLabels.put('FCO003_TAG109',Label.FCO003_TAG109);
            mapCustomLabels.put('FCO003_TAG110',Label.FCO003_TAG110);
            mapCustomLabels.put('FCO003_TAG111',Label.FCO003_TAG111);
            mapCustomLabels.put('FCO003_TAG112',Label.FCO003_TAG112);
            mapCustomLabels.put('FCO003_TAG113',Label.FCO003_TAG113);
            mapCustomLabels.put('FCO003_TAG114',Label.FCO003_TAG114);
            mapCustomLabels.put('FCO003_TAG115',Label.FCO003_TAG115);
            mapCustomLabels.put('FCO003_TAG116',Label.FCO003_TAG116);
            mapCustomLabels.put('FCO003_TAG117',Label.FCO003_TAG117);
            mapCustomLabels.put('FCO003_TAG118',Label.FCO003_TAG118);
            mapCustomLabels.put('FCO003_TAG119',Label.FCO003_TAG119);
            mapCustomLabels.put('FCO003_TAG120',Label.FCO003_TAG120);
            mapCustomLabels.put('FCO003_TAG121',Label.FCO003_TAG121);
            mapCustomLabels.put('FCO003_TAG122',Label.FCO003_TAG122);
            mapCustomLabels.put('FCO003_TAG123',Label.FCO003_TAG123);
            mapCustomLabels.put('FCO003_TAG124',Label.FCO003_TAG124);
            mapCustomLabels.put('FCO003_TAG125',Label.FCO003_TAG125);
            mapCustomLabels.put('FCO003_TAG126',Label.FCO003_TAG126);
            mapCustomLabels.put('FCO003_TAG127',Label.FCO003_TAG127);
            mapCustomLabels.put('FCO003_TAG128',Label.FCO003_TAG128);
            mapCustomLabels.put('FCO003_TAG129',Label.FCO003_TAG129);
            mapCustomLabels.put('FCO003_TAG130',Label.FCO003_TAG130);
            mapCustomLabels.put('FCO003_TAG131',Label.FCO003_TAG131);
            mapCustomLabels.put('FCO003_TAG132',Label.FCO003_TAG132);
            mapCustomLabels.put('FCO003_TAG133',Label.FCO003_TAG133);
            mapCustomLabels.put('FCO003_TAG134',Label.FCO003_TAG134);
            mapCustomLabels.put('FCO003_TAG135',Label.FCO003_TAG135);
            mapCustomLabels.put('FCO003_TAG136',Label.FCO003_TAG136); 
            mapCustomLabels.put('FCO003_TAG137',Label.FCO003_TAG137);
            mapCustomLabels.put('FCO003_TAG138',Label.FCO003_TAG138);
            mapCustomLabels.put('FCO003_TAG139',Label.FCO003_TAG139);
            mapCustomLabels.put('FCO003_TAG140',Label.FCO003_TAG140);
            mapCustomLabels.put('FCO003_TAG141',Label.FCO003_TAG141);
            mapCustomLabels.put('FCO003_TAG142',Label.FCO003_TAG142);
            mapCustomLabels.put('FCO003_TAG143',Label.FCO003_TAG143);
            mapCustomLabels.put('FCO003_TAG144',Label.FCO003_TAG144);
            mapCustomLabels.put('FCO003_TAG145',Label.FCO003_TAG145);
            mapCustomLabels.put('FCO003_TAG146',Label.FCO003_TAG146);
            mapCustomLabels.put('FCO003_TAG147',Label.FCO003_TAG147);
            mapCustomLabels.put('FCO003_TAG148',Label.FCO003_TAG148);
            mapCustomLabels.put('FCO003_TAG149',Label.FCO003_TAG149);
            mapCustomLabels.put('FCO003_TAG150',Label.FCO003_TAG150);   
            mapCustomLabels.put('FCO003_TAG152',Label.FCO003_TAG152);
            mapCustomLabels.put('FCO003_TAG153',Label.FCO003_TAG153); 
            mapCustomLabels.put('FCO003_TAG154',Label.FCO003_TAG154);   
            mapCustomLabels.put('FCO003_TAG155',Label.FCO003_TAG155);        
            response.data = mapCustomLabels;
        }
        catch( Exception e ) {
            createExceptionLogs(e, response, 'getCustomLabels', BLANK_STRING);
        }
        return response;
    }

    
}