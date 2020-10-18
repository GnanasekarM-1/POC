/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The SPM_Consts has all the constant values used accross all the spm classes.
 *
 * @file SPM_Consts.cls
 *
 * @author Ramachandra Mohan
 * @version 15.59101
 * @since 2015
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       08 Oct 2015     Created. 
 *              Ramachandra Mohan       31 Mar 2016     Security fixes.
 *              Soumyaranjan Pati       25th Oct 2017   Added variable for MTBF 
 *              Soumyaranjan Pati       5th Dec 2017    Added SPM Custom labels
 *****************************************************************************************************/

public with sharing class SPM_Consts {
    
    /**
     * Static instant string variable to hold datetime default format.
     */
    public static final String DEFAULT_DATETIME_FORMAT              = 'yyyy-MM-dd\'T\'hh:mm:ss\'z\'';
    public static final String DEFAULT_DATETIME_FORMAT_AM_PM        = 'yyyy-MM-dd\'T\'HH:mm:ss\'z\'';
    
    /**
     * Static instant string variable to hold date default format.
     */
    public static final String DEFAULT_DATE_FORMAT                  = 'yyyy-MM-dd';    
    
    /**
     * Static instant string variable to hold single space.
     */
    public static final String SPACE                                = ' ';
    public static final String COMMA                                = ', ';
    public static final String SEMICOLON                            = ';';
    public static final String LINE_BREAK                           = '<br>';
    
    public static final String SCHEDULE                             = 'Schedule';
    public static final String MAPPING                              = 'MAPPING_';
    public static final String MAPPING_PREFERENCE_2                 = 'MAPPING_Preference_2';
    public static final String MAPPING_PREFERENCE_3                 = 'MAPPING_Preference_3';
    public static final String NONE                                 = 'NONE';
    
    public static final String ACCOUNT                              = 'Account';
    public static final String PRODUCT2                             = 'Product2';
    public static final String LOCATION                             = 'Site';
    public static final String BUSINESSHOURS                        = 'BusinessHours';
        
    public static final String RECORD_ID                            = 'Id';
    public static final String NAME                                 = 'Name';
    public static final String CREATED_DATE                         = 'CreatedDate';    
    public static final String SITE                                 = 'SVMXC__Site__c';
    public static final String SERVICE_ORDER                        = 'SVMXC__Service_Order__c';
    public static final String REPEATVISIT                               = 'SVMXC__SPM_Repeat_Visit__c';
    public static final String FIRST_TIME_FIX                       = 'SVMXC__SPM_First_Time_Fix__c';
    public static final String ACCOUNT_SUMMARY                      = 'SVMXC__SPM_Account_Summary__c';
    public static final String MEAN_TIME_BETWEEN_FAILURE            = 'SVMXC__SPM_Mean_Time_Between_Failure__c';
    public static final String WORK_ORDER                           = System.Label.SPM002_TAG062;
    public static final String DOWN_TIME                            = System.Label.SPM002_TAG063;
    public static final String MEAN_TIME_TO_REPAIR                  = 'SVMXC__SPM_Mean_Time_To_Repair__c';
    public static final String SPM_UTILIZATION                      = 'SVMXC__SPM_Utilization__c';
    public static final String CONTRACT_PENETRATION                 = 'SVMXC__SPM_Contract_Penetration__c';    
    public static final String CONTRACT_UP_TIME                     = 'SVMXC__SPM_Contract_Up_Time__c';
    public static final String MEAN_TIME_TO_COMPLETE                = 'SVMXC__SPM_Mean_Time_To_Complete__c'; 
    public static final String AVERAGE_RESPONSE_TIME                = 'SVMXC__SPM_Average_Response_Time__c';
    public static final String TIMESHEET                            = 'SVMXC__Timesheet__c';
    public static final String SM_TYPE                              = 'SVMXC__SM_Type__c';
    public static final String TIMESHEET_ENTRY                      = 'SVMXC__Timesheet_Entry__c';
    public static final String PERIOD                               = 'SVMXC__Period__c';
    public static final String USER                                 = 'SVMXC__User__c';
    public static final String SERVICE_ORDER_LINE                   = 'SVMXC__Service_Order_Line__c';
    public static final String PRODUCT                              = 'SVMXC__Product__c';
    public static final String PRODUCT_BY_REFERENCE                 = 'SVMXC__Service_Order__r.SVMXC__Product__c';
    public static final String ACCOUNT_BY_REFERENCE                 = 'SVMXC__Service_Order__r.SVMXC__Company__c';
    public static final String COMPANY                              = 'SVMXC__Company__c';
    public static final String IDLE_TIME                            = 'SVMXC__Idle_Time__c';
    public static final String DEAD_TIME                            = 'SVMXC__Dead_Time__c';
    public static final String TOP_LEVEL                            = 'SVMXC__Top_Level__c';
    public static final String CLOSED_ON                            = 'SVMXC__Closed_On__c';
    public static final String COMPONENT                            = 'SVMXC__Component__c';
    public static final String START_DATE                           = 'SVMXC__Start_Date__c';
    public static final String END_DATE                             = 'SVMXC__End_Date__c';
    public static final String SUBMITTED_LOCATION                   = 'SVMXC__Submitted_Location__c';
    public static final String DRIVING_TIME                         = 'SVMXC__Driving_Time__c';
    public static final String SERVICE_GROUP                        = 'SVMXC__Service_Group__c';
    public static final String SCHEDULED_DATE                       = 'SVMXC__Scheduled_Date__c';    
    public static final String SERVICE_DURATION                     = 'SVMXC__Service_Duration__c';
    public static final String SCHEDULED_DATE_TIME                  = 'SVMXC__Scheduled_Date_Time__c';
    public static final String PREFERRED_TECHNICIAN                 = 'SVMXC__Preferred_Technician__c';
    public static final String COMPLETED_DATE_TIME                  = 'SVMXC__Completed_Date_Time__c';    
    public static final String COMPANY_BY_IB_REFERENCE              = 'SVMXC__Installed_Product__r.SVMXC__Company__c';    
    public static final String PREFERRED_TECHNICIAN_BY_REFERENCE    = 'SVMXC__Service_Order__r.SVMXC__Preferred_Technician__c';
    public static final String TECHNICIAN_BY_REFERENCE              = 'SVMXC__Service_Order__r.SVMXC__Service_Group_Members__c';
    public static final String IDLE_TIME_BY_REFERENCE               = 'SVMXC__Service_Order__r.SVMXC__Idle_Time__c'; // Updated in Future
    public static final String SCHEDULED_DATE_BY_REFERENCE          = 'SVMXC__Service_Order__r.SVMXC__Scheduled_Date__c';
    public static final String LABOR_TIME                           = 'SVMXC__Actual_Quantity2__c';
    public static final String INSTALLED_PRODUCT                    = 'SVMXC__Installed_Product__c';
    public static final String SERVICE_GROUP_MEMBERS                = 'SVMXC__Service_Group_Members__c';
    public static final String SERVICE_CONTRACT                     = 'SVMXC__Service_Contract__c';
    public static final String SERVICE_CONTRACT_STARTDATE           = 'SVMXC__Service_Contract__r.SVMXC__Start_Date__c';
    public static final String SERVICE_CONTRACT_ENDDATE             = 'SVMXC__Service_Contract_r.SVMXC__End_Date__c';
    public static final String WARRANTY                             = 'SVMXC__Warranty__c';
    public static final String WARRANTY_STARTDATE                   = 'SVMXC__Warranty_Start_Date__c';
    public static final String WARRANTY_ENDDATE                     = 'SVMXC__Warranty_End_Date__c';
    public static final String SERVICE_CONTRACT_PRODUCTS            = 'SVMXC__Service_Contract_Products__c';
    public static final String PREFERRED_BUSINESS_HOURS             = 'SVMXC__Preferred_Business_Hours__c';
    public static final String BUSINESS_HOURS                       = 'SVMXC__Business_Hours__c';
    public static final String START_DATE_AND_TIME                  = 'SVMXC__Start_Date_and_Time__c';
    public static final String END_DATE_AND_TIME                    = 'SVMXC__End_Date_and_Time__c';
    public static final String WORKING_HOURS                        = 'SVMXC__Working_Hours__c';
    public static final String WARRANTY_QUERY                       = '(Select Id FROM SVMXC__Warranty__r WHERE SVMXC__Start_Date__c <= TODAY AND SVMXC__End_Date__c >= TODAY ORDER BY SVMXC__End_Date__c )';
    public static final String SLA_TERMS                            = 'SVMXC__SLA_Terms__c';
    public static final String TIME_TO_INITIAL_RESPONSE             = 'SVMXC__Time_to_Initial_Response__c';
    public static final String TIME_TO_ONSITE_RESPONSE              = 'SVMXC__Time_to_Onsite_Response__c';
    public static final String TIME_TO_RESOLVE                      = 'SVMXC__Time_to_Resolve__c';
    public static final String TIME_TO_RESTORE                      = 'SVMXC__Time_to_Restore__c';
    public static final String SLA_INITIAL_RESPONSE_TIME            = 'SVMXC__SM_SLA_Initial_Response__c';
    public static final String SLA_ONSITE_RESPONSE_TIME             = 'SVMXC__SM_SLA_Onsite_Response__c';
    public static final String SLA_RESTORATION_TIME                 = 'SVMXC__SM_SLA_Restoration__c';
    public static final String SLA_RESOLUTION_TIME                  = 'SVMXC__SM_SLA_Resolution__c';
    public static final String CLOCK_EXTENSION_TIME                 = 'SVMXC__SLA_Clock_Extension_Minutes__c';
    public static final String RELATED_WORK_ORDER                   = 'SVMXC__Related_Work_Order__c';
    public static final String TECHNICIAN_OBJECT                    = 'SVMXC__Service_Group_Members__c';
    public static final String TECHNICIAN                           = 'SVMXC__Group_Member__c';
    
    //#AccountSummary
    public static final String SERVICEMAX_PROCESS                   = 'SVMXC__ServiceMax_Processes__c';
    public static final String COUNT                                = 'count(id)';
    public static final String CALCULATION_METHOD                   = 'SVMXC__Calculation_Method__c';
    public static final String CONFIGURATION_NAME                   = 'SVMXC__Configuration_Name__c';
    public static final String FIXED_ON                             = 'SVMXC__Fixed_On__c';
    public static final String ACCOUNT_ON_METRIC                    = 'SVMXC__Account__c';
    public static final String IS_FIRST_TIME_FIXED                  = 'SVMXC__Is_Fixed_First_Time__c';
    public static final String PROCESS_TABLE                        = 'SVMXC__ServiceMax_Processes__c';
    public static final String PROCESS_ID                           = 'SVMXC__ProcessID__c';
   
    public static final String REPORT_NAME_UTILIZATION              = System.Label.SPM002_TAG072;
    public static final String REPORT_NAME_FIRST_TIME_FIX           = System.Label.SPM002_TAG066;
    public static final String REPORT_NAME_MEAN_TIME_TO_REPAIR      = System.Label.SPM002_TAG067;
    
    
    //Constants for SPM Scheduling Engine Flow
    public static final String DRIVE_TIME_ACTIVITY                  = System.Label.SPM002_TAG080;
    public static final String EXTERNAL_WORK_ORDER_ACTIVITY         = System.Label.SPM002_TAG081;
    public static final String OPTIMIZED_BATCH                      = System.Label.SPM002_TAG082;
    public static final String COMPLETE                             = System.Label.SPM002_TAG083;
    public static final String SPM_DETAILS                          = System.Label.SPM002_TAG084;
    public static final String SPM_OPTIMAX_RULE                     = System.Label.SPM002_TAG085;
    public static final String DEFAULT_SPM_SCHEDULING_CONFIGURATION = System.Label.SPM002_TAG086;
    
    //Constants for implementing the top-level support at case-level, SR-level and parent-workorder level.
    public static final String RELATEDWO_BY_REFERENCE               = 'SVMXC__Service_Order__r.SVMXC__Related_Work_Order__c';
    public static final String RELATEDWO_Case_BY_REFERENCE          = 'SVMXC__Service_Order__r.SVMXC__Case__c';    
    public static final String WOCASE                               = 'SVMXC__Case__c';
    public static final String CASEOBJECT                           = 'Case';
    public static final String SERVICEREQUESTOBJECT                 = 'SVMXC__Service_Request__c';    
    public static final string WO_CASE_REFERENCEFIELD               = 'SVMXC__Service_Order__r.SVMXC__Case__r.';    
    public static final String RELATEDWO_SR_BY_REFERENCE            = 'SVMXC__Service_Order__r.SVMXC__SM_Service_Request__c';
    public static final string WO_SR_REFERENCEFIELD                 = 'SVMXC__Service_Order__r.SVMXC__SM_Service_Request__r.';
    public static final String WOCASERELATIONSHIP                   = 'SVMXC__Case__r.';
    public static final String WOSRRELATIONSHIP                     = 'SVMXC__SM_Service_Request__r.';    
    public static final String WOSERVICEREQUESTFIELD                = 'SVMXC__SM_Service_Request__c';
    public static final String REPEATVISITID                        = 'RepeatVisit';
    
    public static final String REPEAT_VISIT_ADDITIONAL_COMPARISION_FIELD = 'IssueCode';
    
    // TODO create custom labels.
    public static final String SOURCE_FROM_WORK_ORDER               = System.Label.SPM002_TAG001;
    public static final String MTTR_SUM_OF_LABOR_DETAILS            = System.Label.SPM002_TAG002;
    public static final String SOURCE_FROM_INSTALLED_PRODUCT        = System.Label.SPM002_TAG003;
    public static final String SOURCE_FROM_SERVICE_CONTRACT         = System.Label.SPM002_TAG004;
    public static final String MTTC_SOURCE_FROM_WORK_ORDER          = System.Label.SPM002_TAG033;
    public static final String MTBF_SOURCE_FROM_WORK_ORDER          = System.Label.SPM002_TAG087;
    public static final String ART_SOURCE_FROM_WORK_ORDER           = System.Label.SPM002_TAG034;
    public static final String REPEATVISIT_CALCULATION_METHOD            = System.Label.SPM002_TAG035;
    public static final String UTILIZATION_CALCULATION_METHOD       = System.Label.SPM002_TAG036;
    
    public static final String LABEL_SOURCE_FOR_PRODUCT             = System.Label.SPM002_TAG005;
    public static final String LABEL_SOURCE_FOR_ACCOUNT             = System.Label.SPM002_TAG006;
    public static final String LABEL_SOURCE_FOR_SCHEDULE_DATE       = System.Label.SPM002_TAG007;    
    public static final String LABEL_SOURCE_FOR_CLOSED_ON           = System.Label.SPM002_TAG008;
    public static final String LABEL_SOURCE_FOR_BUSINESS_HOURS      = System.Label.SPM002_TAG009;
    public static final String LABEL_SOURCE_FOR_TECHNICIAN          = System.Label.SPM002_TAG010;
    public static final String LABEL_SOURCE_FOR_INSTALLED_PRODUCT   = System.Label.SPM002_TAG011;
    public static final String LABEL_SOURCE_FOR_DRIVE_TIME          = System.Label.SPM002_TAG012;
    public static final String LABEL_SOURCE_FOR_SERVICE_TIME        = System.Label.SPM002_TAG013;
    public static final String LABEL_SOURCE_FOR_DEAD_TIME           = System.Label.SPM002_TAG014;
    public static final String LABEL_SOURCE_FOR_LABOR_TIME          = System.Label.SPM002_TAG015;
    public static final String LABEL_SOURCE_FOR_LOCATION_TIME       = System.Label.SPM002_TAG037;
    public static final String LABEL_SOURCE_FOR_CREATED_ON          = System.Label.SPM002_TAG038;
    public static final String LABEL_SOURCE_FOR_COMPLETED_ON        = System.Label.SPM002_TAG039;
    public static final String LABEL_SOURCE_FOR_SERVICE_DELIVERED_ON= System.Label.SPM002_TAG040;
    public static final String LABEL_SOURCE_FOR_NON_PRODUCTIVE_TIME = System.Label.SPM002_TAG041;
    public static final String LABEL_SOURCE_FOR_BREAK_MINUTES       = System.Label.SPM002_TAG042;
    public static final String LABEL_SOURCE_FOR_REPEATVISIT_FIELDS  = System.Label.SPM002_TAG043;
    public static final String LABEL_SOURCE_FOR_REPEATVISIT_TIMEFRAME= System.Label.SPM002_TAG044;
    public static final String LABEL_SOURCE_FOR_REFERENCE_TO_PW     = System.Label.SPM002_TAG045;
    public static final String LABEL_SOURCE_FOR_CALCULATE_DIFFERENCE= System.Label.SPM002_TAG060;
    public static final String LABEL_SOURCE_FOR_LEAVES              = System.Label.SPM002_TAG061;

    public static final String LABEL_OBJECT_MAPPING                 = System.Label.SPM002_TAG046;
    public static final String LABEL_YES                            = System.Label.SPM002_TAG047;
    public static final String LABEL_NO                             = System.Label.SPM002_TAG048;
    public static final String LABEL_ACCOUNT                        = System.Label.SPM002_TAG049;
    public static final String LABEL_LOCATION                       = System.Label.SPM002_TAG050;
    public static final String LABEL_INSTALLED_PRODUCT              = System.Label.SPM002_TAG051;
    public static final String LABEL_BREAK_HOURS                    = System.Label.SPM002_TAG052;
    public static final String LABEL_BREAK_DURATION                 = System.Label.SPM002_TAG053;
    
    public static final String LABEL_CRITERIA_FOR_INSTALLED_PRODUCT = System.Label.SPM002_TAG016;
    public static final String LABEL_CRITERIA_FOR_FIRST_TIME_FIX    = System.Label.SPM002_TAG017;
    public static final String LABEL_CRITERIA_FOR_WORK_ORDER        = System.Label.SPM002_TAG018;
    public static final String LABEL_CRITERIA_FOR_EXCLUDE_WORK_ORDER= System.Label.SPM002_TAG088;
    public static final String LABEL_CRITERIA_FOR_WORK_DETAIL       = System.Label.SPM002_TAG019;
    public static final String LABEL_CRITERIA_FOR_COVERED_PRODUCT   = System.Label.SPM002_TAG032;
    public static final String LABEL_CRITERIA_FOR_TIMESHEET         = System.Label.SPM002_TAG054;
    public static final String LABEL_CRITERIA_FOR_REPEATVISIT_WORK_ORDER = System.Label.SPM002_TAG055;
        
    public static final String DEFAULT_FTF_APPLIES_TO               = System.Label.SPM002_TAG020;
    public static final String DEFAULT_MTTR_APPLIES_TO              = System.Label.SPM002_TAG021;
    public static final String DEFAULT_UPDOWN_APPLIES_TO            = System.Label.SPM002_TAG022;
    public static final String DEFAULT_CP_APPLIES_TO                = System.Label.SPM002_TAG023;
    
    public static final String TIMEFRAME_7_DAYS                     = System.Label.SPM002_TAG056;
    public static final String TIMEFRAME_14_DAYS                    = System.Label.SPM002_TAG057;
    public static final String TIMEFRAME_30_DAYS                    = System.Label.SPM002_TAG058;
    public static final String LABEL_NONE                           = System.Label.SPM002_TAG059;
    
    public static final String LABEL_WORKORDER                      = System.Label.SPM002_TAG062;
    public static final String LABEL_DOWNTIME                       = System.Label.SPM002_TAG063;
    public static final String LABEL_SOURCE_FOR_UP_DOWN_CREATED_ON  = System.Label.SPM002_TAG064;
    
    public static final String SOURCE_FROM_FTF_COMPUTATION               = System.Label.SPM002_TAG075;
    public static final String UPPERLIMIT_WORK_DETAIL_CREATION_TIMEFRAME = System.Label.SPM002_TAG076;
    public static final String LABEL_CRITERIA_FOR_REPEATVISIT_ISSUECODE  =  System.Label.SPM002_TAG077; //'Select any Text Field';//System.Label.SPM002_TAG101;
    public static final String LABEL_CRITERIA_FOR_SERVICE_CONTRACT  = System.Label.SPM002_TAG078;
  
    
    public static final Map<String,String> OPERATOR_MAP = new Map<String,String> {
        'lt'        => System.Label.SPM002_TAG024,
        'eq'        => System.Label.SPM002_TAG025,
        'ne'        => System.Label.SPM002_TAG026,
        'gt'        => System.Label.SPM002_TAG027,
        'ge'        => System.Label.SPM002_TAG028,
        'le'        => System.Label.SPM002_TAG029,
        'isnotnull' => System.Label.SPM002_TAG030,
        'isnull'    => System.Label.SPM002_TAG031
    };
}