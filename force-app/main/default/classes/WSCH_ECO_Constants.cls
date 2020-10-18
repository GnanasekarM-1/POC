/*
 This is the constant Utility class which is having the all constants values are used in Abstraction Layer.
*/
public with sharing class WSCH_ECO_Constants {

    public static Integer intWOBatchSize;
    
    public static final String STATUS_OPT_FAIL = 'OPT_FAIL';
    public static final String STATUS_OPT_ERROR = 'OPT_ERROR';
    public static final String STATUS_OPT_QUEUED = 'OPT_QUEUED';
    public static final String STATUS_OPT_COMPLETED = 'OPT_COMPLETED';
    public static final String STATUS_OPT_TENTATIVE = 'OPT_TENTATIVE';
    public static final String STATUS_OPT_INITIATED = 'OPT_INITIATED';
    public static final String STATUS_OPT_PENDING = 'OPT_PENDING';
    public static final String STATUS_OPT_DATA_SYNC_ERROR = 'OPT_DATA_SYNC_ERROR';
    public static final String STATUS_OPT_BATCH = 'OPT_BATCH';
    public static final String STATUS_OPT_RETRY_BATCH = 'OPT_RETRY_BATCH';
    public static final String STATUS_OPT_SKIPPED = 'OPT_SKIPPED';
    public static final String STATUS_OPT_UNASSIGNED = 'OPT_UNASSIGNED';
    public static final String SCHEDULE_LOCK_IN_PLACE = 'Lock in place';
    public static final String SCHEDULE_LOCK_TO_ARRIVALWINDOW = 'Lock to arrival window';
    

    public static final String SFM_BOOK_JOB_MAP_ID = 'Linx_Book_Job';
    public static final String SFM_BOOK_APPOINTMENT_MAP_ID = 'Linx_Book_Appointment';

    public static final Integer BATCH_APEX_START_TIME = 10;

    public static final String[] WO_SP_DISPATCH_STATUS = new String[]{'Tentative','Earmarked','Contacted','Travelling','LoggedOn','LoggedOff','Cleared','Fixed'};
    public static final String[] WO_SMax_DISPATCH_STATUS = new String[]{'Tentative','Fixed','Dispatched','Received','En Route','Onsite','Finished Onsite','Completed', 'Cancelled'};
    public static final Integer SP_WOULD_BREAK_ACCESS_HOURS = 371;
    public static final Set<String> BOOKJOB_SCHDL_CHANGE_TOKENS = new Set<String>{'CHANGE_CREATE_WO'};
    public static final Set<String> ADDTECH_CHANGE_TOKENS = new Set<String>{'CHANGE_CREATE_TECH'};
    public static final Set<String> UPDATETECH_CHANGE_TOKENS = new Set<String>{'CHANGE_TECH_ZIP', 'CHANGE_TECH_WORKINGHRS', 'CHANGE_UPDATE_TECH'};
    public static final Set<String> REMOVETECH_CHANGE_TOKENS = new Set<String>{'CHANGE_REMOVE_TECH'};
    public static final Set<String> UPDATEJOB_SCHDL_CHANGE_TOKENS = new Set<String>{'CHANGE_ZIP_CODE' , 'CHANGE_LAT_LONG', 'CHANGE_SKILL_SET' , 'CHANGE_QUALIFIED_TECHNICIAN', 'CHANGE_SERVICE_DURATION' , 'CHANGE_PREFERRED_TECH' , 'CHANGE_ACCESS_HOURS' , 'CHANGE_PREFERRED_TIME' ,'CHANGE_DISPATCH_PROCESS','CHANGE_CUSTOM_FIELDS_BOOK','CHANGE_RESOURCE_PREFERENCE','CHANGE_ACCOUNT_RESOURCE','CHANGE_SITE_RESOURCE','CHANGE_COMPONENT_RESOURCE','CHANGE_CONTACT_INFO','CHANGE_PRIORITY', 'CHANGE_CUSTOM_FIELDS_UPDATE','CHANGE_ACCOUNT_INFO','CHANGE_ADDRESS_INFO','CHANGE_SCHEDULE_UNLOCK'};
    public static final Set<String> FORCEFIXJOB_SCHDL_CHANGE_TOKENS = new Set<String>{'CHANGE_TECH_FIXED','CHANGE_DATETIME_FIXED','CHANGE_JOB_FIXED','CHANGE_JOB_STATUS_FIXED'};
    public static final Set<String> SCHEDULEFIX_SCHDL_CHANGE_TOKENS = new Set<String>{'CHANGE_SCHEDULE_LOCK'};
    public static final String MOCK_DISPATCH_PROCESS='Mock Dispatch Process';
    public static final Integer MAX_CALLOUTS = Limits.getLimitCallouts();//10
    public static final Set<String> UPDATEEVENT_CHANGE_TOKENS = new Set<String>{'CHANGE_UPDATE_EVENT','CHANGE_EVENT_START_DATE', 'CHANGE_EVENT_END_DATE', 'CHANGE_EVENT_TECHNICIAN', 'CHANGE_EVENT_SERVICE_DURATION'}; //Multi-resource and Multi-appointment - while fields of events gets updated
    
    public static final Integer EVENT_BATCH_SIZE = 40;      //Limits.getLimitCallouts() - 1;

    public static String STR_SKILL_ID = 'skillId';
    public static String STR_SKILL_NAME = 'skillName';
    public static String STR_SKILL_LEVEL = 'skillLevel';
    public static String STR_SKILL_ISMANDATORY = 'isSkillMandatory';
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

   
    /* Following map contains the priority rank of scheduling change tokens for work order update API. */
    public static Map<String,Integer> CHANGE_TOKEN_PRIORITY = new Map<String,Integer>();
    //Deafult value is a higher value than others.
    public static Integer CHANGE_TOKEN_DEFAULT_PRIORITY = 100;
    //Initialise the rank of all the Schedule change job token.
    static {
        CHANGE_TOKEN_PRIORITY.put('CHANGE_CANCEL_WO',1); //Cancel Job Tokens.
        CHANGE_TOKEN_PRIORITY.put('CHANGE_CREATE_WO',1);
        CHANGE_TOKEN_PRIORITY.put('FORCE_SCHEDULE',1);
        CHANGE_TOKEN_PRIORITY.put('CHANGE_COMPLETED_STATUS',1); //for ECO, remove work order from the run but not remove event in client

        //CHANGE_TOKEN_PRIORITY.put('FORCE_SCHEDULE_BOOKED',1);
        CHANGE_TOKEN_PRIORITY.put('CHANGE_JOB_FIXED',2); //Force Fix Job Tokens.
        CHANGE_TOKEN_PRIORITY.put('CHANGE_SCHEDULE_LOCK',2); //Schedule Lock down Tokens.
       
        //Dependency Group
         CHANGE_TOKEN_PRIORITY.put('CREATE_DEPENDENCY_WO',2);
        CHANGE_TOKEN_PRIORITY.put('CHANGE_DEPENDENCY_WO',2);
        //Rebook change Tokens.
        CHANGE_TOKEN_PRIORITY.put('CHANGE_ZIP_CODE',3);
        CHANGE_TOKEN_PRIORITY.put('CHANGE_LAT_LONG',3);
        CHANGE_TOKEN_PRIORITY.put('CHANGE_SKILL_SET',3);
        CHANGE_TOKEN_PRIORITY.put('CHANGE_QUALIFIED_TECHNICIAN',3);
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
        CHANGE_TOKEN_PRIORITY.put('CHANGE_SCHEDULE_UNLOCK',4);
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
    
    public static final String WSCH_SYNCSCHEDULER_CRONJOB = 'WSCH_Provider_ECO_Scheduler';
    
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
    
    public static final Integer WO_BATCH_SIZE = intWOBatchSize;     //Limits.getLimitCallouts() - 1;
    
     public static final String OPT_SF_EVENT_TYPE = 'SF_EVENT';
     public static final String OPT_SVMX_EVENT_TYPE = 'SVMX_EVENT';
     
     
    public static final String OPT_OPTIMIZER_CHANGE_TOKEN_CREATE = 'CHANGE_CREATE_EVENT';
    public static final String OPT_OPTIMIZER_CHANGE_TOKEN_UPDATE = 'CHANGE_UPDATE_EVENT';
    public static final String OPT_OPTIMIZER_CHANGE_TOKEN_DELETE = 'CHANGE_DELETE_EVENT';
    
    public static final String OPT_OPERATION_TYPE_ADD = 'add';
    public static final String OPT_OPERATION_TYPE_UPDATE = 'update';
    public static final String OPT_OPERATION_TYPE_DELETE = 'remove';
      
    public static final String OPT_DISPATCH_PROCES_ECO = 'Real Time Optimization';
     
    public static final String ECO_OPT_PENDING = 'OPT_PENDING';
    public static final String ECO_OPT_COMPLETE = 'OPT_COMPLETED';
    public static final String ECO_OPT_ERROR = 'OPT_ERROR';
           
    public static final String OPT_NON_WORK_ORDER_EVENT_TYPE = 'NON_WO_EVENT';
    
     public static final String PUSHREQUEST_TYPE_ACTIVITY = 'ACTIVITY';
     public static final String PUSHREQUEST_TYPE_JOB = 'JOB';
     public static final String PUSHREQUEST_TYPE_RESOURCE = 'RESOURCE';  
     
     //for LTP
     public static final String SVMXJOB_LTP_TYPE = 'LTP';       
}