/*
 This is the constant Utility class which is having the all constants values are used in Abstraction Layer.
*/
public with sharing class WSCH_Constants {

    public static Integer intWOBatchSize;
    
    public static final String STATUS_OPT_FAIL = 'OPT_FAIL';
    public static final String STATUS_OPT_ERROR = 'OPT_ERROR';
    public static final String STATUS_OPT_QUEUED = 'OPT_QUEUED';
    public static final String STATUS_OPT_COMPLETED = 'OPT_COMPLETED';
    public static final String STATUS_OPT_TENTATIVE = 'OPT_TENTATIVE';
    public static final String STATUS_OPT_PENDING = 'OPT_PENDING';
    public static final String STATUS_OPT_DATA_SYNC_ERROR = 'OPT_DATA_SYNC_ERROR';
    public static final String STATUS_OPT_BATCH = 'OPT_BATCH';
    public static final String STATUS_OPT_RETRY_BATCH = 'OPT_RETRY_BATCH';
    public static final String STATUS_OPT_SKIPPED = 'OPT_SKIPPED';

    public static final String SFM_BOOK_JOB_MAP_ID = 'Linx_Book_Job';
    public static final String SFM_BOOK_APPOINTMENT_MAP_ID = 'Linx_Book_Appointment';

    public static final Integer BATCH_APEX_START_TIME = 10;

    public static final String CANCEL_WO_BATCH_APEX = 'WSCH_SP_CancelWorkOrderBatchApex';

    public static final String[] WO_SP_DISPATCH_STATUS = new String[]{'Tentative','Earmarked','Contacted','Travelling','LoggedOn','LoggedOff','Cleared','Fixed'};
    public static final String[] WO_SMax_DISPATCH_STATUS = new String[]{'Tentative','Fixed','Dispatched','Received','En Route','Onsite','Finished Onsite','Completed', 'Cancelled'};
    public static final Integer SP_WOULD_BREAK_ACCESS_HOURS = 371;
    public static final Set<String> BOOKJOB_SCHDL_CHANGE_TOKENS = new Set<String>{'CHANGE_CREATE_WO'};
    public static final Set<String> UPDATEJOB_SCHDL_CHANGE_TOKENS = new Set<String>{'CHANGE_CONTACT_INFO','CHANGE_PRIORITY','CHANGE_JOB_UNFIXED', 'CHANGE_CUSTOM_FIELDS_UPDATE','CHANGE_ACCOUNT_INFO','CHANGE_ADDRESS_INFO','CHANGE_ZIP_CODE' , 'CHANGE_SKILL_SET' , 'CHANGE_SERVICE_DURATION' , 'CHANGE_PREFERRED_TECH' , 'CHANGE_ACCESS_HOURS' , 'CHANGE_PREFERRED_TIME' ,'CHANGE_DISPATCH_PROCESS','CHANGE_CUSTOM_FIELDS_BOOK','CHANGE_RESOURCE_PREFERENCE','CHANGE_ACCOUNT_RESOURCE','CHANGE_SITE_RESOURCE','CHANGE_COMPONENT_RESOURCE', 'CHANGE_LAT_LONG','CHANGE_QUALIFIED_TECHNICIAN'};
    public static final Set<String> FORCEFIXJOB_SCHDL_CHANGE_TOKENS = new Set<String>{'CHANGE_TECH_FIXED','CHANGE_DATETIME_FIXED','CHANGE_JOB_FIXED','CHANGE_JOB_STATUS_FIXED'};
    public static final Set<String> CHANGESTATUS_TOKENS = new Set<String>{'CHANGE_STATUS','CHANGE_SCHEDULING_STATUS'};
    
    public static final String MOCK_DISPATCH_PROCESS='Mock Dispatch Process';
    public static final Integer MAX_CALLOUTS = Limits.getLimitCallouts();//10
    
    public static final Integer EVENT_BATCH_SIZE = 40;      //Limits.getLimitCallouts() - 1;

    public static String STR_DATABASE = null;
    public static String STR_PASSWORD = null;
    public static String STR_SP_USER = null;
    public static String STR_SKILL_NAME = 'skillName';
    public static String STR_SKILL_LEVEL = 'skillLevel';
    public static String STR_REQ_EMP_MPX = 'Preferred';     //There are either one or two preferred employees
    public static String STR_REQ_EMP_MPX_MANDATORY = 'Mandatory';       //There is one or two mandatory employees
    public static String STR_REQ_EMP_MPX_NON_MANDATORY = 'MandatoryNot';    //There is one employee who should not be used
    public static String STR_REQ_UNIT_TYPE = 'Final';
    public static String STR_NUM_REQ_TYPE='';
    public static String STR_WORKITEM_TYPE = 'Job';
    public static String STR_WORKITEM_TYPE_SA = 'StandardActivity';
    public static String STR_WORKITEM_TYPE_BR = 'Break';
    public static String STR_IMPORTANCE = String.valueOf(0);
    public static Integer INT_DEFAULT_PRIORITY = 50;
    public static Integer INT_MAX_PRIORITY = 99;
    public static String STR_LOCTYPE = 'None';
    public static String STR_ACTTYPE = String.valueOf(12);
    public static final Integer BATCH_SIZE = 9;
    public static Integer APPOINTMENT_SLOTS_MAX_SIZE = 99;
    public static String WORKORDER_OPTIMIZATION_ID_FIELD = 'Name';
    public static String STR_RULE_TYPE = 'Field Match Rule';
    public static String STR_OFFERAPPT_DAYS = 'YYYYYYY';
    public static String STR_DEFAULT_LIMIT = '1000';
    
    public static final Integer INT_MAX_SCHEDULED_JOBS = 100;
    public static final Integer INT_MAX_BATCH_JOBS = 5;

    /*
     Following parameters will be used for Retry Failed WO Batch Apex.
    */
    public static final String RETRY_WO_BATCH_QUERY_STRING = 'SELECT ID FROM SVMXC__Service_Order__c WHERE SVMXC__OptiMax_Status__c = \'OPT_RETRY_BATCH\' AND SVMXC__Scheduling_Retry_Count__c < 4';
    public static final String RETRY_WO_BATCH_CLASS_NAME = 'WSCH_SP_RetryWOBatchApex';
    public static final Integer RETRY_BATCH_APEX_START_TIME = 120;

    /*
     Following parameters will be used for Retry Failed NonWO Events Batch Apex.
    */
    public static final String RETRY_FAILED_NON_WO_EVENT_QUERY_STRING = 'SELECT ID FROM SVMXC__SVMX_Optimizer__c WHERE SVMXC__Optimizer_Status__c = \'OPT_RETRY_BATCH\' AND SVMXC__Optimizer_Retry_Count__c < 4 AND SVMXC__WhatType__c=\'NON_WO_EVENT\'' ;
    public static final String RETRY_FAILED_NON_WO_EVENT_BATCH = 'WSCH_SP_RetryNonWOEventBatchApex';

    /*
     Following parameters will be used for Retry Failed Cancel WO Batch Apex.
    */
    public static final String RETRY_CANCEL_WO_BATCH_QUERY_STRING = 'SELECT ID FROM SVMXC__SVMX_Optimizer__c WHERE SVMXC__Optimizer_Status__c = \'OPT_RETRY_BATCH\' AND SVMXC__WhatType__c = \'WORK_ORDER\' AND (SVMXC__Optimizer_Retry_Count__c = null OR SVMXC__Optimizer_Retry_Count__c < 4)';
    public static final String RETRY_CANCEL_WO_BATCH_APEX = 'WSCH_SP_RetryCancelWOBatchApex';
    public static final Integer RETRY_CANCEL_WO_BATCH_SIZE = 10;

    /*
     Following parameters will be used for Manage NonWO Events Batch Apex.
    */
    public static final String MANAGE_NON_WO_BATCH_QUERY_STRING = 'SELECT ID FROM SVMXC__SVMX_Optimizer__c WHERE SVMXC__Optimizer_Status__c = \'OPT_BATCH\' AND SVMXC__WhatType__c = \'NON_WO_EVENT\'';
    public static final String MANAGE_NON_WO_BATCH_CLASS_NAME = 'WSCH_SP_ManageNonWOEventsBatchApex';

    /*
     Following parameters will be used for Get Changes Batch Apex.
    */
    public static final String GET_CHANGES_BATCH_QUERY_STRING = 'SELECT SVMXC__Optimizer_External_ID__c, SVMXC__Optimizer_Connection_Name__c, SVMXC__Optimizer_Last_Timestamp__c FROM SVMXC__Territory__c WHERE SVMXC__Optimizer_External_ID__c != null AND SVMXC__Active__c = true';
    public static final String GET_CHANGES_BATCH_CLASS_NAME = 'WSCH_SP_GetChangesBatchApex';
    public static Integer GET_CHANGES_BATCH_SIZE = 1;

    /*
     Following parameters will be used for Manage WO Batch Apex.
    */
    public static final String WO_BATCH_QUERY_STRING = 'SELECT ID FROM SVMXC__Service_Order__c WHERE SVMXC__OptiMax_Status__c = \'OPT_BATCH\'';
    public static final String WO_BATCH_CLASS_NAME = 'WSCH_SP_WorkOrderBatchApex';

    /*
     Following parameters will be used for Update WO Batch Apex.
    */
    public static final String UPDATE_WO_BATCH_QUERY_STRING = 'SELECT ID FROM SVMXC__Service_Order__c WHERE SVMXC__OptiMax_Status__c = \'OPT_UPDATE_BATCH\'';
    public static final String UPDATE_WO_BATCH_CLASS_NAME = 'WSCH_SP_UpdateWOBatchApex';
    public static final Integer UPDATE_WO_BATCH_SIZE = 8;

    /*
     Following parameters will be used for Get Push json request.
    */
    public static final String GET_PUSH_JSON_STRING = 'SELECT ID, SVMXC__WhatType__c, SVMXC__Optimizer_Error_Text__c, LastModifiedDate, SVMXC__Optimizer_Retry_Count__c FROM SVMXC__SVMX_Optimizer__c WHERE SVMXC__WhatType__c = \'PUSH_REQUEST_JSON\' AND (SVMXC__Optimizer_Retry_Count__c = null OR SVMXC__Optimizer_Retry_Count__c < 4)';
    public static Integer GET_PUSH_BATCH_SIZE = 10;
    
    /* Following map contains the priority rank of scheduling change tokens for work order update API. */
    public static Map<String,Integer> CHANGE_TOKEN_PRIORITY = new Map<String,Integer>();
    //Deafult value is a higher value than others.
    public static Integer CHANGE_TOKEN_DEFAULT_PRIORITY = 100;
    //Initialise the rank of all the Schedule change job token.
    static {
        CHANGE_TOKEN_PRIORITY.put('CHANGE_CANCEL_WO',1); //Cancel Job Tokens.
        CHANGE_TOKEN_PRIORITY.put('CHANGE_CREATE_WO',1);
        CHANGE_TOKEN_PRIORITY.put('FORCE_SCHEDULE',1);
        //CHANGE_TOKEN_PRIORITY.put('FORCE_SCHEDULE_BOOKED',1);
        CHANGE_TOKEN_PRIORITY.put('CHANGE_JOB_FIXED',2); //Force Fix Job Tokens.
        
        //Dependency Group
         CHANGE_TOKEN_PRIORITY.put('CREATE_DEPENDENCY_WO',2);
        CHANGE_TOKEN_PRIORITY.put('CHANGE_DEPENDENCY_WO',2);
        //Rebook change Tokens.
        CHANGE_TOKEN_PRIORITY.put('CHANGE_ZIP_CODE',3);
        CHANGE_TOKEN_PRIORITY.put('CHANGE_SKILL_SET',3);
        CHANGE_TOKEN_PRIORITY.put('CHANGE_SERVICE_DURATION',3);
        CHANGE_TOKEN_PRIORITY.put('CHANGE_PREFERRED_TECH',3);
        CHANGE_TOKEN_PRIORITY.put('CHANGE_ACCESS_HOURS',3);
        CHANGE_TOKEN_PRIORITY.put('CHANGE_PREFERRED_TIME',3);
        CHANGE_TOKEN_PRIORITY.put('CHANGE_DISPATCH_PROCESS',3);
        CHANGE_TOKEN_PRIORITY.put('CHANGE_CUSTOM_FIELDS_BOOK',3);
        CHANGE_TOKEN_PRIORITY.put('CHANGE_RESOURCE_PREFERENCE',3);
        CHANGE_TOKEN_PRIORITY.put('CHANGE_ACCOUNT_RESOURCE',3);
        CHANGE_TOKEN_PRIORITY.put('CHANGE_SITE_RESOURCE',3);
        CHANGE_TOKEN_PRIORITY.put('CHANGE_COMPONENT_RESOURCE',3);
        //Update Job Change Tokens.
        CHANGE_TOKEN_PRIORITY.put('CHANGE_JOB_UNFIXED',4);
        CHANGE_TOKEN_PRIORITY.put('CHANGE_PRIORITY',5);
        CHANGE_TOKEN_PRIORITY.put('CHANGE_PREFERRED_TIME',5);
        CHANGE_TOKEN_PRIORITY.put('CHANGE_CONTACT_INFO',5);
        CHANGE_TOKEN_PRIORITY.put('CHANGE_ACCOUNT_INFO',5);
        CHANGE_TOKEN_PRIORITY.put('CHANGE_ADDRESS_INFO',5);
        CHANGE_TOKEN_PRIORITY.put('CHANGE_CUSTOM_FIELDS_UPDATE',5);
        //Change Status Tokens.
        CHANGE_TOKEN_PRIORITY.put('CHANGE_STATUS',6);
        CHANGE_TOKEN_PRIORITY.put('CHANGE_SCHEDULING_STATUS',7);
    }

    /*
        Below are the parameters which are used in CommonsUtil cls.
    */
    public static final String WSCH_SYNCSCHEDULER_CRONJOB = 'WSCH_Provider_SP_Scheduler';
    public enum CRON_JOB_STATE {COMPLETED, ERROR, DELETED}

    public static Set<string> subModules = new Set<string>{'GLOB001','OMAX001','OMAX003','OMAX004','DCON002','DCON003','DCON004','WORD023', 'WORD022','WORD012','IPAD018','SORG001','DCON005'};
    public static Map<string, Map<String, String>> allDMSettings = new Map<string, Map<String, String>>();

    public static final string API_BOOK_JOB = 'BookJob';
    public static final string API_OFFER_APPT = 'OfferAppts';
    public static final string API_BOOK_APPT = 'BookAppt';
    public static final string API_GET_CHANGED_WORK_ITEMS = 'getChangedWorkItems';
    public static final string API_CANCEL_JOB = 'cancelJob';
    public static final string API_UPDATE_JOB = 'updateJob';
    public static final string API_FORCE_FIX_JOB = 'forceFixJob';
    public static final string API_FORCE_BOOK = 'forceBook';
    public static final string API_BOOK_DEPENDANCY_GROUP = 'bookDependancyGroup';
    public static final string API_CHANGE_WORK_ITEM_STATUS = 'changeWorkItemStatus';
    public static final string API_GET_JOB_STATUS = 'getJobStatus';
    public static final string API_EMP_ADD_ACTIVITY = 'empAddActivity';
    public static final string API_EMP_DELETE_ACTIVITY = 'empDeleteActivity';
    public static final string API_EMP_UPDATE_ACTIVITY = 'empUpdateActivity';
    
    public static List<SVMXC__ServiceMax_Properties__c> allSPsettinglist;
    
    public static integer customTimeout = 19000; // timeout in milliseconds(19seconds).ONLY 25 concurrent calls with a duration of 20 seconds or more.
    
    /*
     * The below set contains the set of all workorder SLAs & ServiceContracts to be processed for SOQL queries.
     */
    public static Set<Id> setSLAIds = new Set<Id>();
    public static Set<Id> setServiceContractIds = new Set<Id>();
    
    /*
     * Maximum number of technician preferences to be sent to ServicePower.
     */
    public static final Integer TECH_MPX_SIZE = 10;
    
    static {
        initializeSettings();
    }
    
    public static void initializeSettings() {
        
        String strWOBatchSize = WSCH_CommonUtils.getSettingValue('DCON004','SET013');
        if(String.isNotBlank(strWOBatchSize)) {
            intWOBatchSize = Integer.valueOf(strWOBatchSize);
        } else {
            intWOBatchSize = 40;
        }
        //WSCH_AuditLogger.debug('WSCH_Constants::static block: WO batch size - ' + intWOBatchSize);
    }
    
    public static final Integer WO_BATCH_SIZE = intWOBatchSize;     //Limits.getLimitCallouts() - 1;
    
    //set to store the updateable fields of Work Order
    public static Set<String> setWoUpdFields;
    
    /*public static Map<String, Integer> mapOfSvmxSchedStatusAndRank = new Map<String, Integer>();
    
    public static Map<String, Integer> mapOfSPSchedStatusAndRank = new Map<String, Integer>();
    
    static {
        mapOfSvmxSchedStatusAndRank.put('Tentative', 1);
        mapOfSvmxSchedStatusAndRank.put('Dispatched', 2);
        mapOfSvmxSchedStatusAndRank.put('Received', 3);
        mapOfSvmxSchedStatusAndRank.put('En Route', 4);
        mapOfSvmxSchedStatusAndRank.put('Onsite', 5);
        mapOfSvmxSchedStatusAndRank.put('Finished Onsite', 6);
        mapOfSvmxSchedStatusAndRank.put('Completed', 7);
        
        
        mapOfSPSchedStatusAndRank.put('planned', 1);
        mapOfSPSchedStatusAndRank.put('notified', 2);
        mapOfSPSchedStatusAndRank.put('acknowledged', 3);
        mapOfSPSchedStatusAndRank.put('en_route', 4);
        mapOfSPSchedStatusAndRank.put('on_site', 5);
        mapOfSPSchedStatusAndRank.put('off_site', 6);
        mapOfSPSchedStatusAndRank.put('complete', 7);
    }*/
    
}