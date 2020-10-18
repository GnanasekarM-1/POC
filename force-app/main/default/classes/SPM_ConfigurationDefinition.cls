/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief The class SPM_ConfigurationDefinition defines default configurations required for SPM
 * engine and UI.
 *
 *
 * @author Ramachandra Mohan
 * @version 15.59101
 * @since 2015
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       08 Oct 2015     Created.
 * 028216       Ramachandra Mohan       10 Mar 2015     Defect fix. Default expression for Utilization.
 *              Ramachandra Mohan       31 Mar 2016     Security fixes.
 *              Soumyaranjan Pati       25th Oct 2017   MTBF Code added V.02
 *****************************************************************************************************/
public with sharing class SPM_ConfigurationDefinition {

    /**
     * 
     */
    public class FieldInfo implements Comparable {
        
        public String label;
        public String name;
        public Schema.DisplayType displayType;
        public List<Schema.SObjectType> referenceToList = new List<Schema.SObjectType>();
        
        public FieldInfo(){}
        
        public Integer compareTo( Object compareTo ) {
            
            if( compareTo != null ) {
                
                FieldInfo info = (FieldInfo) compareTo;
                if( info.label == label ) return 0;
                if( info.label < label ) return 1;                
            }
            return -1;                        
        }        
    }
    
    /**
     * 
     */
    public class ParameterInfo {
        
        public String label;
        public String sourceFieldLabel;
        public String sourceFieldName;
        public String sourceObjectName;
        public String referenceTo;
        public Boolean isCriteria = false;
        public Boolean isMultiSelect = false;
        public Boolean isPicklistValue = false;
        public SPM_Schema.Field sourceObjectField;
        public Schema.DisplayType displayType = Schema.DisplayType.anytype;
        
        public List<FieldInfo> sourceFieldInfoList = new List<FieldInfo>();
        
        public ParameterInfo(){}
    }
 
    public class Expression {
        
        public String expressionId;
        
        public String sequence;
        public String operator;
        public String value;        
        public String field;
        
        public Expression() {}
    }
    
    public class ExpressionRule {
        
        public String expressionRuleId;
        public String expressionRuleName;
        public String advancedExpression;
        
        public List<Expression> expressionList = new List<Expression>();
        public ExpressionRule() {}
       
        public ExpressionRule( String expressionRuleId, String expressionRuleName ) {
            this.expressionRuleId = expressionRuleId; this.expressionRuleName = expressionRuleName;
        }
    }
    
    public class ExpressionDetails {
        
        public String label;        
        public String expressionRuleId;
        public String sourceObjectName;
        public SPM_Schema.ExpressionType expressionType = SPM_Schema.ExpressionType.QualificationCriteria;
        public List<ExpressionRule> expressionRuleList = new List<ExpressionRule>();
        
        public ExpressionDetails(){}
        
        public ExpressionDetails( ExpressionDetails details ) {
            
            if( details != this ) {
                
                this.label = details.label;
                this.expressionRuleId = details.expressionRuleId;
                this.sourceObjectName = details.sourceObjectName;
                this.expressionType = details.expressionType;                
            }
        }
    }
    
    public class ObjectMapping {
        
        public String mapId;
        public String name;
        
        public ObjectMapping() {}
    }
    
    public class ObjectMappingDetails {
        
        public String label;        
        public String mapId = SPM_Consts.NONE;        
        public String sourceObjectName;
        public String targetObjectName;
        public Boolean referenceObjectName = false;
        
        public List<ObjectMapping> objectMappingList = new List<ObjectMapping>();
            
        public ObjectMappingDetails() {
            
            ObjectMapping noneMapping = new ObjectMapping();
            noneMapping.mapId = SPM_Consts.NONE;
            noneMapping.name = SPM_Consts.LABEL_NONE;
            
            objectMappingList.add(noneMapping);
        }
        
        public ObjectMappingDetails( ObjectMappingDetails details ) {
            
            if( details != this ) {
                
                this.label = details.label;
                this.mapId = details.mapId;
                this.sourceObjectName = details.sourceObjectName;
                this.targetObjectName = details.targetObjectName;
            }
        }
    }
    
    public class CalculationMethod {
        
        public String recordId;
        public String name;
        public String method;
        public String methodDisplayName;
        public String appliesTo;
        public String sourceObjectName;
        public String sourceObjectLabel;
        public String targetObjectName;
        public String targetObjectLabel;
        public String lastModifiedOn;
        public Boolean isActive = false;
        public String entryTypeForMTBF = '';
        
        public List<ParameterInfo> parameterInfoList = new List<ParameterInfo>();
        public List<ExpressionDetails> expressionDetailsList = new List<ExpressionDetails>();
        public List<ObjectMappingDetails> objectMappingDetailsList = new List<ObjectMappingDetails>();
        
        public CalculationMethod() {}
    }
    
    public static final Map<String, String> REPORT_SOURCE_OBJECT_MAP = new Map<String, String> {
        
        SPM_Schema.Report.RepeatVisit.name()                 => SPM_Consts.SERVICE_ORDER,
        SPM_Schema.Report.Utilization.name()            => SPM_Consts.TIMESHEET,
        SPM_Schema.Report.FirstTimeFix.name()           => SPM_Consts.SERVICE_ORDER, 
        SPM_Schema.Report.MeanTimeToRepair.name()       => SPM_Consts.SERVICE_ORDER_LINE,
        SPM_Schema.Report.MeanTimeToComplete.name()     => SPM_Consts.SERVICE_ORDER,
        SPM_Schema.Report.UpDownTime.name()             => SPM_Consts.SERVICE_CONTRACT,
        SPM_Schema.Report.AverageResponseTime.name()    => SPM_Consts.SERVICE_ORDER,
        SPM_Schema.Report.ContractPenetration.name()    => SPM_Consts.INSTALLED_PRODUCT,
        SPM_Schema.Report.AccountSummary.name()         => SPM_Consts.SERVICEMAX_PROCESS,
        SPM_Schema.Report.MeanTimeBetweenFailure.name()    => SPM_Consts.INSTALLED_PRODUCT
    };
    
    /**
     * Default source object fields to be retrieved for RepeatVisit report.
     */
    public static final Map<String, String> DEFAULT_REPEATVISIT_SOBJ_FIELDS = new Map<String, String> 
    {
        SPM_Schema.Field.Name.name()                => SPM_Consts.NAME,
        SPM_Schema.Field.Location.name()            => SPM_Consts.SITE,        
        SPM_Schema.Field.Account.name()             => SPM_Consts.COMPANY,
        SPM_Schema.Field.InstallProduct.name()      => SPM_Consts.TOP_LEVEL,        
        SPM_Schema.Field.ServiceDeliveredOn.name()  => SPM_Consts.CLOSED_ON,
        SPM_Schema.Field.CreatedDate.name()         => SPM_Consts.CREATED_DATE,
        SPM_Schema.Field.Technician.name()          => SPM_Consts.TECHNICIAN,
        SPM_Schema.Field.Warranty.name()            => SPM_Consts.WARRANTY,
        SPM_Schema.Field.ServiceContract.name()     => SPM_Consts.SERVICE_CONTRACT,
        SPM_Schema.Field.RelatedWorkOrder.name()    => SPM_Consts.RELATED_WORK_ORDER,
        SPM_Schema.Field.IssueCode.name()           => SPM_Consts.REPEAT_VISIT_ADDITIONAL_COMPARISION_FIELD
    };
        
    /**
     * Default target object fields to be retrieved for RepeatVisit report.
     */
    public static final Map<String, String> DEFAULT_REPEATVISIT_TOBJ_FIELDS = new Map<String, String> 
    {
        'SVMXC__Installed_Product__c'     => SPM_Schema.Field.InstallProduct.name(),
        'SVMXC__Product_Warranty__c'      => SPM_Schema.Field.Warranty.name(),
        'SVMXC__Service_Contract__c'      => SPM_Schema.Field.ServiceContract.name(),
        'SVMXC__Technician__c'            => SPM_Schema.Field.Technician.name()
    };
        
    /**
     * Default source object fields to be retrieved for First Time Fix report.
     */
    public static final Map<String, String> DEFAULT_FTF_SOBJ_FIELDS = new Map<String, String> 
    {
        SPM_Schema.Field.Name.name()                => SPM_Consts.NAME,
        SPM_Schema.Field.Technician.name()          => SPM_Consts.TECHNICIAN,
        SPM_Schema.Field.ClosedOn.name()            => SPM_Consts.CLOSED_ON,
        SPM_Schema.Field.Product.name()             => SPM_Consts.PRODUCT,
        SPM_Schema.Field.Account.name()             => SPM_Consts.COMPANY,
        SPM_Schema.Field.ServiceGroup.name()        => SPM_Consts.SERVICE_GROUP
    };
    
    /**
     * Default target object fields to be retrieved for First Time Fix report.
     */
    public static final Map<String, String> DEFAULT_FTF_TOBJ_FIELDS = new Map<String, String> 
    {
        'SVMXC__Technician__c'                => SPM_Schema.Field.Technician.name(),
        'SVMXC__Fixed_On__c'                  => SPM_Schema.Field.ClosedOn.name(),
        'SVMXC__Product__c'                   => SPM_Schema.Field.Product.name(),
        'SVMXC__Account__c'                   => SPM_Schema.Field.Account.name(),
        'SVMXC__Service_Team__c'              => SPM_Schema.Field.ServiceGroup.name()
    };
        
    /**
     * Default source object fields to be retrieved for Technician Utilization report.
     */
    public static final Map<String, String> DEFAULT_TECH_UTIL_SOBJ_FIELDS = new Map<String, String> {
        SPM_Schema.Field.TimesheetID.name()         => SPM_Consts.NAME,        
        SPM_Schema.Field.User.name()                => SPM_Consts.USER        
    };
    
    /**
     * Default source object fields to be retrieved for 'Mean Time To Repair' report.
     */
    public static final Map<String, String> DEFAULT_MTTR_SOBJ_FIELDS = new Map<String, String> {
        SPM_Schema.Field.Name.name()                => SPM_Consts.NAME,
        SPM_Schema.Field.Technician.name()          => SPM_Consts.TECHNICIAN_BY_REFERENCE,
        SPM_Schema.Field.Product.name()             => SPM_Consts.PRODUCT_BY_REFERENCE,
        SPM_Schema.Field.DeadTime.name()            => SPM_Consts.DEAD_TIME,
        SPM_Schema.Field.ScheduledDate.name()       => SPM_Consts.SCHEDULED_DATE_BY_REFERENCE,
        SPM_Schema.Field.LaborTime.name()           => SPM_Consts.LABOR_TIME,
        SPM_Schema.Field.WorkOrder.name()           => SPM_Consts.SERVICE_ORDER,
        SPM_Schema.Field.StartDateAndTime.name()    => SPM_Consts.START_DATE_AND_TIME,
        SPM_Schema.Field.EndDateAndTime.name()      => SPM_Consts.END_DATE_AND_TIME,
        SPM_Schema.Field.Account.name()             => SPM_Consts.ACCOUNT_BY_REFERENCE
    };
        
    /**
     * Default target object fields to be retrieved for 'Mean Time To Repair' report.
     */
    public static final Map<String, String> DEFAULT_MTTR_TOBJ_FIELDS = new Map<String, String> {
        'SVMXC__Technician__c'                => SPM_Schema.Field.Technician.name(),
        'SVMXC__Product__c'                   => SPM_Schema.Field.Product.name(),
        'SVMXC__Dead_Time__c'                 => SPM_Schema.Field.DeadTime.name(),
        'SVMXC__Service_Delivered_On_Date__c' => SPM_Schema.Field.ScheduledDate.name(),
        'SVMXC__Labor_Time__c'                => SPM_Schema.Field.LaborTime.name(),
        'SVMXC__Work_Order__c'                => SPM_Schema.Field.WorkOrder.name(),
        'SVMXC__Account__c'                   => SPM_Schema.Field.Account.name()
    };
        
    /**
     * Default source object fields to be retrieved for 'Mean Time To Complete' report.
     */
    public static final Map<String, String> DEFAULT_MTTC_SOBJ_FIELDS = new Map<String, String> {
        SPM_Schema.Field.Name.name()                => SPM_Consts.NAME,
        SPM_Schema.Field.Technician.name()          => SPM_Consts.TECHNICIAN,
        SPM_Schema.Field.Product.name()             => SPM_Consts.PRODUCT,
        SPM_Schema.Field.CompletedDate.name()       => SPM_Consts.COMPLETED_DATE_TIME,
        SPM_Schema.Field.CreatedDate.name()         => SPM_Consts.CREATED_DATE,
        SPM_Schema.Field.Account.name()             => SPM_Consts.COMPANY 
    };
        
    /**
     * Default target object fields to be retrieved for 'Mean Time To Complete' report.
     */
    public static final Map<String, String> DEFAULT_MTTC_TOBJ_FIELDS = new Map<String, String> {
        
        'SVMXC__Technician__c'                => SPM_Schema.Field.Technician.name(),
        'SVMXC__Product__c'                   => SPM_Schema.Field.Product.name(),
        'SVMXC__Service_Delivered_On__c'      => SPM_Schema.Field.CompletedDate.name(),
        'SVMXC__Account__c'                   => SPM_Schema.Field.Account.name()
    };
     /**
     * Default target object fields to be retrieved for 'Mean Time Between Failure' report.
     */
    public static final Map<String, String> DEFAULT_MTBF_TOBJ_FIELDS = new Map<String, String> {
        
        'SVMXC__Account__c'                       => SPM_Schema.Field.Account.name(),
        'SVMXC__Actual_Uptime__c'                 => 'SVMXC__Actual_Uptime__c',
        'SVMXC__Downtime__c'                      =>'SVMXC__Downtime__c',
        'SVMXC__Expected_Uptime__c'               => 'SVMXC__Expected_Uptime__c',
        'SVMXC__Installed_Product__c'             => 'SVMXC__Installed_Product__c',
        'SVMXC__Product__c'                       => 'SVMXC__Product__c',
        'SVMXC__Run_Date__c'                      => 'SVMXC__Run_Date__c',
        'SVMXC__Workorder_Count__c'               => 'SVMXC__Workorder_Count__c'
    };   
    /**
     * Default source object fields to be retrieved for 'Average Response Time' report.
     */
    public static final Map<String, String> DEFAULT_ART_SOBJ_FIELDS = new Map<String, String> {
        SPM_Schema.Field.Name.name()                    => SPM_Consts.NAME,
        SPM_Schema.Field.Technician.name()              => SPM_Consts.TECHNICIAN,
        SPM_Schema.Field.Product.name()                 => SPM_Consts.PRODUCT,
        SPM_Schema.Field.Account.name()                 => SPM_Consts.COMPANY,
        SPM_Schema.Field.SLATerms.name()                => SPM_Consts.SLA_TERMS,
        SPM_Schema.Field.TimeToInitialResponse.name()   => SPM_Consts.TIME_TO_INITIAL_RESPONSE,
        SPM_Schema.Field.TimeToOnsiteResponse.name()    => SPM_Consts.TIME_TO_ONSITE_RESPONSE,
        SPM_Schema.Field.TimeToResolve.name()           => SPM_Consts.TIME_TO_RESOLVE,
        SPM_Schema.Field.TimeToRestore.name()           => SPM_Consts.TIME_TO_RESTORE,
        SPM_Schema.Field.ServiceContract.name()         => SPM_Consts.SERVICE_CONTRACT,
        SPM_Schema.Field.ServiceDeliveredOn.name()      => SPM_Consts.CLOSED_ON,
        SPM_Schema.Field.SLAInitialResponseTime.name()  => SPM_Consts.SLA_INITIAL_RESPONSE_TIME,
        SPM_Schema.Field.SLAOnsiteResponseTime.name()   => SPM_Consts.SLA_ONSITE_RESPONSE_TIME,
        SPM_Schema.Field.SLARestorationTime.name()      => SPM_Consts.SLA_RESTORATION_TIME,
        SPM_Schema.Field.SLAResolutionTime.name()       => SPM_Consts.SLA_RESOLUTION_TIME,
        SPM_Schema.Field.ClockExtensionMinutes.name()   => SPM_Consts.CLOCK_EXTENSION_TIME
    };
    
    /**
     * Default target object fields to be retrieved for 'Average Response Time' report.
     */
    public static final Map<String, String> DEFAULT_ART_TOBJ_FIELDS = new Map<String, String> {
        
        'SVMXC__Account__c'                       => SPM_Schema.Field.Account.name(),
        'SVMXC__Actual_Initial_Response_Time__c'  => SPM_Schema.Field.TimeToInitialResponse.name(),
        'SVMXC__Actual_Onsite_Response_Time__c'   => SPM_Schema.Field.TimeToOnsiteResponse.name(),
        'SVMXC__Actual_Resolution_Time__c'        => SPM_Schema.Field.TimeToResolve.name(),
        'SVMXC__Actual_Restoration_Time__c'       => SPM_Schema.Field.TimeToRestore.name(),
        'SVMXC__Extension_Time__c'                => SPM_Schema.Field.ClockExtensionMinutes.name(),
        'SVMXC__Product__c'                       => SPM_Schema.Field.Product.name(),
        'SVMXC__Service_Contract__c'              => SPM_Schema.Field.ServiceContract.name(),
        'SVMXC__Service_Delivered_On__c'          => SPM_Schema.Field.ServiceDeliveredOn.name(),
        'SVMXC__SLA_Initial_Response_Time__c'     => SPM_Schema.Field.SLAInitialResponseTime.name(),
        'SVMXC__SLA_Onsite_Response_Time__c'      => SPM_Schema.Field.SLAOnsiteResponseTime.name(),
        'SVMXC__SLA_Restoration_Time__c'          => SPM_Schema.Field.SLARestorationTime.name(),
        'SVMXC__SLA_Resolution_Time__c'           => SPM_Schema.Field.SLAResolutionTime.name(),
        'SVMXC__SLA_Terms__c'                     => SPM_Schema.Field.SLATerms.name(),
        'SVMXC__Technician__c'                    => SPM_Schema.Field.Technician.name()
    };
        
    /**
     * Default source object fields to be retrieved for 'Contract Penetration' report.
     */
    public static final Map<String, String> DEFAULT_CP_SOBJ_FIELDS = new Map<String, String> {
        SPM_Schema.Field.Name.name()                    => SPM_Consts.NAME,                
        SPM_Schema.Field.Account.name()                 => SPM_Consts.COMPANY,
        SPM_Schema.Field.Warranty.name()                => SPM_Consts.WARRANTY_QUERY
    };
        
    /**
     * Default target object fields to be retrieved for 'Contract Penetration' report.
     */
    public static final Map<String, String> DEFAULT_CP_TOBJ_FIELDS = new Map<String, String> {
        
        'SVMXC__Account__c'               => SPM_Schema.Field.Account.name(),
        'SVMXC__Product_Warranty__c'      => SPM_Schema.Field.Warranty.name()
    };
    
    /**
    * Default source object fields to be retrieved for 'Contract UpTime' report.
    */   
    public static final Map<String, String> DEFAULT_UPDOWN_SOBJ_FIELDS = new Map<String, String> {
        SPM_Schema.Field.Name.name()                    => SPM_Consts.NAME,
        SPM_Schema.Field.StartDate.name()               => SPM_Consts.START_DATE,
        SPM_Schema.Field.EndDate.name()                 => SPM_Consts.END_DATE,
        SPM_Schema.Field.Account.name()                 => SPM_Consts.COMPANY,
        SPM_Schema.Field.BusinessHours.name()           => SPM_Consts.BUSINESS_HOURS
    };
        
    /**
    * Default target object fields to be retrieved for 'Contract UpTime' report.
    */
    public static final Map<String, String> DEFAULT_UPDOWN_TOBJ_FIELDS = new Map<String, String> {
        
        'SVMXC__Account__c'               => SPM_Schema.Field.Account.name()
    };
    
     /**
     * Default source object fields to be retrieved for 'Account Summary' report.
     */
    public static final Map<String, String> DEFAULT_ACCOUNT_SUMMARY_SOBJ_FIELDS = new Map<String, String> {
        SPM_Schema.Field.ProcessId.name()          => SPM_Consts.PROCESS_ID
    };
     /**
     * Default source object fields to be retrieved for 'Mean Time Between Failure' report.
     * #Summary - Added Mean Time Between Failure information
     */
    public static final Map<String, String> DEFAULT_MTBF_SOBJ_FIELDS = new Map<String, String> {
        SPM_Schema.Field.Name.name()                    => SPM_Consts.NAME,
        SPM_Schema.Field.Account.name()                 => SPM_Consts.COMPANY,
        //SPM_Schema.Field.BusinessHours.name()           => SPM_Consts.BUSINESS_HOURS,
        'SVMXC__Product__c'                             => SPM_Consts.PRODUCT
        //'CreatedDate'                                 =>'CreatedDate' 
        
    };   
    private static final ParameterInfo SOURCE_FOR_CREATED_DATE_INFO;
    static {
        SOURCE_FOR_CREATED_DATE_INFO = new ParameterInfo();
        SOURCE_FOR_CREATED_DATE_INFO.label = SPM_Consts.LABEL_SOURCE_FOR_CREATED_ON;
        SOURCE_FOR_CREATED_DATE_INFO.sourceFieldName = SPM_Consts.CREATED_DATE;
        SOURCE_FOR_CREATED_DATE_INFO.sourceObjectField = SPM_Schema.Field.CreatedDate;
        SOURCE_FOR_CREATED_DATE_INFO.displayType = Schema.DisplayType.Datetime;
    }
    
    private static final ParameterInfo SOURCE_FOR_UP_DOWN_CREATED_DATE_INFO;
    static {
        SOURCE_FOR_UP_DOWN_CREATED_DATE_INFO = new ParameterInfo();
        SOURCE_FOR_UP_DOWN_CREATED_DATE_INFO.label = SPM_Consts.LABEL_SOURCE_FOR_UP_DOWN_CREATED_ON;
        SOURCE_FOR_UP_DOWN_CREATED_DATE_INFO.isCriteria = true;
        SOURCE_FOR_UP_DOWN_CREATED_DATE_INFO.sourceFieldName = SPM_Consts.CREATED_DATE;
        SOURCE_FOR_UP_DOWN_CREATED_DATE_INFO.sourceObjectField = SPM_Schema.Field.CreatedDate;
        SOURCE_FOR_UP_DOWN_CREATED_DATE_INFO.displayType = Schema.DisplayType.Datetime;
        SOURCE_FOR_UP_DOWN_CREATED_DATE_INFO.sourceObjectName = SPM_Consts.SERVICE_ORDER;
    }
    
    /**
     * Configuration definition for User interface.
     */
    private static final ParameterInfo SOURCE_FOR_ACCOUNT_INFO;
    static {
        SOURCE_FOR_ACCOUNT_INFO = new ParameterInfo();
        SOURCE_FOR_ACCOUNT_INFO.label = SPM_Consts.LABEL_SOURCE_FOR_ACCOUNT;
        SOURCE_FOR_ACCOUNT_INFO.sourceFieldName = SPM_Consts.COMPANY;
        SOURCE_FOR_ACCOUNT_INFO.sourceObjectField = SPM_Schema.Field.Account;
        SOURCE_FOR_ACCOUNT_INFO.displayType = Schema.DisplayType.Reference;
        SOURCE_FOR_ACCOUNT_INFO.referenceTo = SPM_Consts.ACCOUNT;
        //SOURCE_FOR_ACCOUNT_INFO.sourceObjectName = SPM_Consts.SERVICE_ORDER;
    }
    
    /**
     * If source-object name is not defined then the query takes the value from the base object.
     * 
     * This definition is specific only for MTTR as the base object is Work-detail and we need the Account information from
     * its parent which is Work-Order.
     * 
     */
    private static final ParameterInfo SOURCE_FOR_WORK_ORDER_ACCOUNT_INFO;
    static {
        
        SOURCE_FOR_WORK_ORDER_ACCOUNT_INFO = new ParameterInfo();
        SOURCE_FOR_WORK_ORDER_ACCOUNT_INFO.label = SPM_Consts.LABEL_SOURCE_FOR_ACCOUNT;
        SOURCE_FOR_WORK_ORDER_ACCOUNT_INFO.sourceFieldName = SPM_Consts.COMPANY;
        SOURCE_FOR_WORK_ORDER_ACCOUNT_INFO.sourceObjectField = SPM_Schema.Field.Account;
        SOURCE_FOR_WORK_ORDER_ACCOUNT_INFO.displayType = Schema.DisplayType.Reference;
        SOURCE_FOR_WORK_ORDER_ACCOUNT_INFO.referenceTo = SPM_Consts.ACCOUNT;
        SOURCE_FOR_WORK_ORDER_ACCOUNT_INFO.sourceObjectName = SPM_Consts.SERVICE_ORDER;
        
    }
    
    private static final ParameterInfo SOURCE_FOR_PRODUCT_INFO;
    static {
        SOURCE_FOR_PRODUCT_INFO = new ParameterInfo();
        SOURCE_FOR_PRODUCT_INFO.label = SPM_Consts.LABEL_SOURCE_FOR_PRODUCT;
        SOURCE_FOR_PRODUCT_INFO.sourceFieldName = SPM_Consts.PRODUCT;
        SOURCE_FOR_PRODUCT_INFO.sourceObjectField = SPM_Schema.Field.Product;
        SOURCE_FOR_PRODUCT_INFO.displayType = Schema.DisplayType.Reference;
        SOURCE_FOR_PRODUCT_INFO.referenceTo = SPM_Consts.PRODUCT2;
        SOURCE_FOR_PRODUCT_INFO.sourceObjectName = SPM_Consts.SERVICE_ORDER;
    }
    
    private static final ParameterInfo SOURCE_FOR_LOCATION_INFO;
    static {
        SOURCE_FOR_LOCATION_INFO = new ParameterInfo();
        SOURCE_FOR_LOCATION_INFO.label = SPM_Consts.LABEL_SOURCE_FOR_LOCATION_TIME;
        SOURCE_FOR_LOCATION_INFO.sourceFieldName = SPM_Consts.SITE;
        SOURCE_FOR_LOCATION_INFO.sourceObjectField = SPM_Schema.Field.Location;
        SOURCE_FOR_LOCATION_INFO.displayType = Schema.DisplayType.Reference;
        SOURCE_FOR_LOCATION_INFO.referenceTo = SPM_Consts.SITE;
        SOURCE_FOR_LOCATION_INFO.sourceObjectName = SPM_Consts.SERVICE_ORDER;
    }
    
    private static final ParameterInfo SOURCE_FOR_CLOSED_ON_INFO;
    static {
        SOURCE_FOR_CLOSED_ON_INFO = new ParameterInfo();
        SOURCE_FOR_CLOSED_ON_INFO.label = SPM_Consts.LABEL_SOURCE_FOR_CLOSED_ON;
        SOURCE_FOR_CLOSED_ON_INFO.sourceFieldName = SPM_Consts.CLOSED_ON;
        SOURCE_FOR_CLOSED_ON_INFO.sourceObjectField = SPM_Schema.Field.ClosedOn;
        SOURCE_FOR_CLOSED_ON_INFO.displayType = Schema.DisplayType.Datetime;
        SOURCE_FOR_CLOSED_ON_INFO.sourceObjectName = SPM_Consts.SERVICE_ORDER;
    }
    
    private static final ParameterInfo SOURCE_FOR_UP_DOWN_CLOSED_ON_INFO;
    static {
        SOURCE_FOR_UP_DOWN_CLOSED_ON_INFO = new ParameterInfo();
        SOURCE_FOR_UP_DOWN_CLOSED_ON_INFO.label = SPM_Consts.LABEL_SOURCE_FOR_CLOSED_ON;
        SOURCE_FOR_UP_DOWN_CLOSED_ON_INFO.isCriteria = true;
        SOURCE_FOR_UP_DOWN_CLOSED_ON_INFO.sourceFieldName = SPM_Consts.CLOSED_ON;
        SOURCE_FOR_UP_DOWN_CLOSED_ON_INFO.sourceObjectField = SPM_Schema.Field.ClosedOn;
        SOURCE_FOR_UP_DOWN_CLOSED_ON_INFO.displayType = Schema.DisplayType.Datetime;
        SOURCE_FOR_UP_DOWN_CLOSED_ON_INFO.sourceObjectName = SPM_Consts.SERVICE_ORDER;
    }
    
    private static final ParameterInfo SOURCE_FOR_SERVICE_DELIVERED_ON_INFO;
    static {
        SOURCE_FOR_SERVICE_DELIVERED_ON_INFO = new ParameterInfo();
        SOURCE_FOR_SERVICE_DELIVERED_ON_INFO.label = SPM_Consts.LABEL_SOURCE_FOR_SERVICE_DELIVERED_ON;
        SOURCE_FOR_SERVICE_DELIVERED_ON_INFO.sourceFieldName = SPM_Consts.CLOSED_ON;
        SOURCE_FOR_SERVICE_DELIVERED_ON_INFO.sourceObjectField = SPM_Schema.Field.ServiceDeliveredOn;
        SOURCE_FOR_SERVICE_DELIVERED_ON_INFO.displayType = Schema.DisplayType.Datetime;
    }
    
    private static final ParameterInfo SOURCE_FOR_COMPLETED_DATE_INFO;
    static {
        SOURCE_FOR_COMPLETED_DATE_INFO = new ParameterInfo();
        SOURCE_FOR_COMPLETED_DATE_INFO.label = SPM_Consts.LABEL_SOURCE_FOR_COMPLETED_ON;
        SOURCE_FOR_COMPLETED_DATE_INFO.sourceFieldName = SPM_Consts.COMPLETED_DATE_TIME;
        SOURCE_FOR_COMPLETED_DATE_INFO.sourceObjectField = SPM_Schema.Field.CompletedDate;
        SOURCE_FOR_COMPLETED_DATE_INFO.displayType = Schema.DisplayType.Datetime;
    }
    
    private static final ParameterInfo SOURCE_FOR_TECHNICIAN_INFO;
    static {
        SOURCE_FOR_TECHNICIAN_INFO = new ParameterInfo();
        SOURCE_FOR_TECHNICIAN_INFO.label = SPM_Consts.LABEL_SOURCE_FOR_TECHNICIAN;
        SOURCE_FOR_TECHNICIAN_INFO.sourceFieldName = SPM_Consts.TECHNICIAN;
        SOURCE_FOR_TECHNICIAN_INFO.sourceObjectField = SPM_Schema.Field.Technician;
        SOURCE_FOR_TECHNICIAN_INFO.displayType = Schema.DisplayType.Reference;
        SOURCE_FOR_TECHNICIAN_INFO.referenceTo = SPM_Consts.SERVICE_GROUP_MEMBERS;
        SOURCE_FOR_TECHNICIAN_INFO.sourceObjectName = SPM_Consts.SERVICE_ORDER;
    }
    
    private static final ParameterInfo SOURCE_FOR_SCHEDULE_DATE_INFO;
    static {
        SOURCE_FOR_SCHEDULE_DATE_INFO = new ParameterInfo();
        SOURCE_FOR_SCHEDULE_DATE_INFO.label = SPM_Consts.LABEL_SOURCE_FOR_SCHEDULE_DATE;
        SOURCE_FOR_SCHEDULE_DATE_INFO.sourceFieldName = SPM_Consts.SCHEDULED_DATE;
        SOURCE_FOR_SCHEDULE_DATE_INFO.sourceObjectField = SPM_Schema.Field.ScheduledDate;
        SOURCE_FOR_SCHEDULE_DATE_INFO.displayType = Schema.DisplayType.Date;
        SOURCE_FOR_SCHEDULE_DATE_INFO.sourceObjectName = SPM_Consts.SERVICE_ORDER;
    }
    
    private static final ParameterInfo SOURCE_FOR_INSTALLED_PRODUCT_INFO;
    static {
        SOURCE_FOR_INSTALLED_PRODUCT_INFO = new ParameterInfo();
        SOURCE_FOR_INSTALLED_PRODUCT_INFO.label = SPM_Consts.LABEL_SOURCE_FOR_INSTALLED_PRODUCT;
        SOURCE_FOR_INSTALLED_PRODUCT_INFO.sourceFieldName = SPM_Consts.COMPONENT;
        SOURCE_FOR_INSTALLED_PRODUCT_INFO.sourceObjectField = SPM_Schema.Field.InstallProduct;
        SOURCE_FOR_INSTALLED_PRODUCT_INFO.displayType = Schema.DisplayType.Reference;
        SOURCE_FOR_INSTALLED_PRODUCT_INFO.referenceTo = SPM_Consts.INSTALLED_PRODUCT;
        SOURCE_FOR_INSTALLED_PRODUCT_INFO.sourceObjectName = SPM_Consts.SERVICE_ORDER;
    }
    
    private static final ParameterInfo SOURCE_FOR_DRIVE_TIME_INFO;
    static {
        SOURCE_FOR_DRIVE_TIME_INFO = new ParameterInfo();
        SOURCE_FOR_DRIVE_TIME_INFO.label = SPM_Consts.LABEL_SOURCE_FOR_DRIVE_TIME;
        SOURCE_FOR_DRIVE_TIME_INFO.sourceFieldName = SPM_Consts.DRIVING_TIME;
        SOURCE_FOR_DRIVE_TIME_INFO.sourceObjectField = SPM_Schema.Field.DrivingTime;
        SOURCE_FOR_DRIVE_TIME_INFO.displayType = Schema.DisplayType.Integer;
    }   
    
    private static final ParameterInfo SOURCE_FOR_SERVICE_TIME_INFO;
    static {
        SOURCE_FOR_SERVICE_TIME_INFO = new ParameterInfo();
        SOURCE_FOR_SERVICE_TIME_INFO.label = SPM_Consts.LABEL_SOURCE_FOR_SERVICE_TIME;
        SOURCE_FOR_SERVICE_TIME_INFO.sourceFieldName = SPM_Consts.SERVICE_DURATION;
        SOURCE_FOR_SERVICE_TIME_INFO.sourceObjectField = SPM_Schema.Field.ServiceDuration;
        SOURCE_FOR_SERVICE_TIME_INFO.displayType = Schema.DisplayType.Integer;
    }   
    
    private static final ParameterInfo SOURCE_FOR_IDLE_TIME_INFO;
    static {
        SOURCE_FOR_IDLE_TIME_INFO = new ParameterInfo();
        SOURCE_FOR_IDLE_TIME_INFO.label = SPM_Consts.LABEL_SOURCE_FOR_DEAD_TIME;
        SOURCE_FOR_IDLE_TIME_INFO.isCriteria = true;
        SOURCE_FOR_IDLE_TIME_INFO.sourceFieldName = SPM_Consts.DEAD_TIME;
        SOURCE_FOR_IDLE_TIME_INFO.sourceObjectField = SPM_Schema.Field.DeadTime;
        SOURCE_FOR_IDLE_TIME_INFO.displayType = Schema.DisplayType.Double;
        SOURCE_FOR_IDLE_TIME_INFO.sourceObjectName = SPM_Consts.SERVICE_ORDER_LINE;
    }
    
    private static final ParameterInfo SOURCE_FOR_LABOR_INFO;
    static {
        SOURCE_FOR_LABOR_INFO = new ParameterInfo();
        SOURCE_FOR_LABOR_INFO.label = SPM_Consts.LABEL_SOURCE_FOR_LABOR_TIME;
        SOURCE_FOR_LABOR_INFO.sourceFieldName = SPM_Consts.LABOR_TIME;
        SOURCE_FOR_LABOR_INFO.sourceObjectField = SPM_Schema.Field.LaborTime;
        SOURCE_FOR_LABOR_INFO.displayType = Schema.DisplayType.Double;
        SOURCE_FOR_LABOR_INFO.sourceObjectName = SPM_Consts.SERVICE_ORDER_LINE;
    }
    
    private static final ParameterInfo SOURCE_FOR_BUSINESS_HOURS_INFO;
    static {
        SOURCE_FOR_BUSINESS_HOURS_INFO = new ParameterInfo();
        SOURCE_FOR_BUSINESS_HOURS_INFO.label = SPM_Consts.LABEL_SOURCE_FOR_BUSINESS_HOURS;
        SOURCE_FOR_BUSINESS_HOURS_INFO.sourceFieldName = SPM_Consts.BUSINESS_HOURS;
        SOURCE_FOR_BUSINESS_HOURS_INFO.sourceObjectField = SPM_Schema.Field.BusinessHours;
        SOURCE_FOR_BUSINESS_HOURS_INFO.displayType = Schema.DisplayType.Reference;
        SOURCE_FOR_BUSINESS_HOURS_INFO.referenceTo = SPM_Consts.BUSINESSHOURS;
        SOURCE_FOR_BUSINESS_HOURS_INFO.sourceObjectName = SPM_Consts.SERVICE_CONTRACT;
    }
    
    private static final ParameterInfo SOURCE_FOR_NON_PRODUCTIVE_TIME_INFO;
    static {
        SOURCE_FOR_NON_PRODUCTIVE_TIME_INFO = new ParameterInfo();
        SOURCE_FOR_NON_PRODUCTIVE_TIME_INFO.isMultiSelect = true;
        SOURCE_FOR_NON_PRODUCTIVE_TIME_INFO.isPicklistValue = true;
        SOURCE_FOR_NON_PRODUCTIVE_TIME_INFO.isCriteria = true;
        SOURCE_FOR_NON_PRODUCTIVE_TIME_INFO.label = SPM_Consts.LABEL_SOURCE_FOR_NON_PRODUCTIVE_TIME;
        SOURCE_FOR_NON_PRODUCTIVE_TIME_INFO.sourceFieldName = SPM_Consts.SM_TYPE;
        SOURCE_FOR_NON_PRODUCTIVE_TIME_INFO.sourceObjectField = SPM_Schema.Field.NonProductiveTime;
        SOURCE_FOR_NON_PRODUCTIVE_TIME_INFO.displayType = Schema.DisplayType.MultiPicklist;
        SOURCE_FOR_NON_PRODUCTIVE_TIME_INFO.sourceObjectName = SPM_Consts.TIMESHEET_ENTRY;
    }
    
    private static final ParameterInfo SOURCE_FOR_LEAVES_INFO;
    static {
        SOURCE_FOR_LEAVES_INFO = new ParameterInfo();
        SOURCE_FOR_LEAVES_INFO.isMultiSelect = true;
        SOURCE_FOR_LEAVES_INFO.isPicklistValue = true;
        SOURCE_FOR_LEAVES_INFO.isCriteria = true;
        SOURCE_FOR_LEAVES_INFO.label = SPM_Consts.LABEL_SOURCE_FOR_LEAVES;
        SOURCE_FOR_LEAVES_INFO.sourceFieldName = SPM_Consts.SM_TYPE;
        SOURCE_FOR_LEAVES_INFO.sourceObjectField = SPM_Schema.Field.Leaves;
        SOURCE_FOR_LEAVES_INFO.displayType = Schema.DisplayType.MultiPicklist;
        SOURCE_FOR_LEAVES_INFO.sourceObjectName = SPM_Consts.TIMESHEET_ENTRY;
    }
    
    private static final ParameterInfo SOURCE_FOR_BREAK_MINUTES_INFO;
    static {
        SOURCE_FOR_BREAK_MINUTES_INFO = new ParameterInfo();        
        SOURCE_FOR_BREAK_MINUTES_INFO.label = SPM_Consts.LABEL_SOURCE_FOR_BREAK_MINUTES;
        SOURCE_FOR_BREAK_MINUTES_INFO.isCriteria = true;
        SOURCE_FOR_BREAK_MINUTES_INFO.sourceFieldName = 'Break Hours';
        SOURCE_FOR_BREAK_MINUTES_INFO.sourceObjectField = SPM_Schema.Field.BreakTime;
        SOURCE_FOR_BREAK_MINUTES_INFO.displayType = Schema.DisplayType.Picklist;
        
        FieldInfo breakHourFieldInfo = new FieldInfo();
        breakHourFieldInfo.name = 'Break Hours';
        breakHourFieldInfo.label = SPM_Consts.LABEL_BREAK_HOURS;
        
        FieldInfo breakDurationFieldInfo = new FieldInfo();
        breakDurationFieldInfo.name = 'Break Duration';
        breakDurationFieldInfo.label = SPM_Consts.LABEL_BREAK_DURATION;
        
        SOURCE_FOR_BREAK_MINUTES_INFO.sourceFieldInfoList = new List<FieldInfo> { breakHourFieldInfo, breakDurationFieldInfo };
    }
    
    private static final ParameterInfo SOURCE_FOR_REPEATVISIT_COMPARE_INFO;
    static {
        SOURCE_FOR_REPEATVISIT_COMPARE_INFO = new ParameterInfo();
        SOURCE_FOR_REPEATVISIT_COMPARE_INFO.isMultiSelect = true;
        SOURCE_FOR_REPEATVISIT_COMPARE_INFO.isCriteria = true;
        SOURCE_FOR_REPEATVISIT_COMPARE_INFO.label = SPM_Consts.LABEL_SOURCE_FOR_REPEATVISIT_FIELDS;
        SOURCE_FOR_REPEATVISIT_COMPARE_INFO.sourceFieldName = 'Account';
        SOURCE_FOR_REPEATVISIT_COMPARE_INFO.sourceObjectField = SPM_Schema.Field.RepeatVisitQualifier;
        SOURCE_FOR_REPEATVISIT_COMPARE_INFO.displayType = Schema.DisplayType.Picklist;
        
        FieldInfo accountFieldInfo = new FieldInfo();
        accountFieldInfo.name = 'Account';
        accountFieldInfo.label = SPM_Consts.LABEL_ACCOUNT;
        
        FieldInfo locationFieldInfo = new FieldInfo();
        locationFieldInfo.name = 'Location';
        locationFieldInfo.label = SPM_Consts.LABEL_LOCATION;
        
        FieldInfo installedProductFieldInfo = new FieldInfo();
        installedProductFieldInfo.name = 'Installed Product';
        installedProductFieldInfo.label = SPM_Consts.LABEL_INSTALLED_PRODUCT;
        
        SOURCE_FOR_REPEATVISIT_COMPARE_INFO.sourceFieldInfoList = new List<FieldInfo> { accountFieldInfo, locationFieldInfo, installedProductFieldInfo };
    }
    
    private static final ParameterInfo SOURCE_FOR_PRIMRY_WORKORDER_INFO;
    static {
        SOURCE_FOR_PRIMRY_WORKORDER_INFO = new ParameterInfo();        
        SOURCE_FOR_PRIMRY_WORKORDER_INFO.label = SPM_Consts.LABEL_SOURCE_FOR_REFERENCE_TO_PW;
        SOURCE_FOR_PRIMRY_WORKORDER_INFO.isCriteria = true;
        SOURCE_FOR_PRIMRY_WORKORDER_INFO.sourceFieldName = 'Yes';
        SOURCE_FOR_PRIMRY_WORKORDER_INFO.sourceObjectField = SPM_Schema.Field.hasPrimaryWorkOrder;
        SOURCE_FOR_PRIMRY_WORKORDER_INFO.displayType = Schema.DisplayType.Picklist;
        
        FieldInfo yesFieldInfo = new FieldInfo();
        yesFieldInfo.name = 'Yes';
        yesFieldInfo.label = SPM_Consts.LABEL_YES;
        
        FieldInfo noFieldInfo = new FieldInfo();
        noFieldInfo.name = 'No';
        noFieldInfo.label = SPM_Consts.LABEL_NO;
        
        SOURCE_FOR_PRIMRY_WORKORDER_INFO.sourceFieldInfoList = new List<FieldInfo> { yesFieldInfo, noFieldInfo };
    }
    
    private static final ParameterInfo SOURCE_FOR_CALCULATE_DIFFERENCE;
    static {
        SOURCE_FOR_CALCULATE_DIFFERENCE = new ParameterInfo();        
        SOURCE_FOR_CALCULATE_DIFFERENCE.label = SPM_Consts.LABEL_SOURCE_FOR_CALCULATE_DIFFERENCE;
        SOURCE_FOR_CALCULATE_DIFFERENCE.isCriteria = true;
        SOURCE_FOR_CALCULATE_DIFFERENCE.sourceFieldName = 'Work Order';
        SOURCE_FOR_CALCULATE_DIFFERENCE.sourceObjectField = SPM_Schema.Field.considerDownTimeFrom;
        SOURCE_FOR_CALCULATE_DIFFERENCE.displayType = Schema.DisplayType.Picklist;
        
        FieldInfo yesFieldInfo = new FieldInfo();
        yesFieldInfo.name = 'Work Order';
        yesFieldInfo.label = SPM_Consts.LABEL_WORKORDER;
        
        FieldInfo noFieldInfo = new FieldInfo();
        noFieldInfo.name = 'Down Time';
        noFieldInfo.label = SPM_Consts.LABEL_DOWNTIME;
        
        SOURCE_FOR_CALCULATE_DIFFERENCE.sourceFieldInfoList = new List<FieldInfo> { yesFieldInfo, noFieldInfo };
    }
    
    private static final ParameterInfo SOURCE_FOR_REPEATVIST_ADDITIONALCRITERIA;
    static {
        SOURCE_FOR_REPEATVIST_ADDITIONALCRITERIA = new ParameterInfo();        
        SOURCE_FOR_REPEATVIST_ADDITIONALCRITERIA.label = SPM_Consts.LABEL_CRITERIA_FOR_REPEATVISIT_ISSUECODE;
        SOURCE_FOR_REPEATVIST_ADDITIONALCRITERIA.isCriteria = true;
        SOURCE_FOR_REPEATVIST_ADDITIONALCRITERIA.sourceFieldName = 'None';
        SOURCE_FOR_REPEATVIST_ADDITIONALCRITERIA.sourceObjectField = SPM_Schema.Field.IssueCode;
        SOURCE_FOR_REPEATVIST_ADDITIONALCRITERIA.displayType = Schema.DisplayType.String;
        SOURCE_FOR_REPEATVIST_ADDITIONALCRITERIA.sourceFieldInfoList = new List<FieldInfo>(SPM_Utilities.getInstance().getFieldsForDisplayType(
            SPM_Consts.SERVICE_ORDER, SPM_Utilities.getInstance().populateDisplayTypesForRepeatVisitComparison()));
    }
    
    private static final ParameterInfo SOURCE_FOR_REPEATVISIT_WINDOW_INFO;
    static {
        SOURCE_FOR_REPEATVISIT_WINDOW_INFO = new ParameterInfo();
        SOURCE_FOR_REPEATVISIT_WINDOW_INFO.label = SPM_Consts.LABEL_SOURCE_FOR_REPEATVISIT_TIMEFRAME;
        SOURCE_FOR_REPEATVISIT_WINDOW_INFO.isCriteria = true;
        SOURCE_FOR_REPEATVISIT_WINDOW_INFO.sourceFieldName = '7';
        SOURCE_FOR_REPEATVISIT_WINDOW_INFO.sourceObjectField = SPM_Schema.Field.RepeatVisitWindow;
        SOURCE_FOR_REPEATVISIT_WINDOW_INFO.displayType = Schema.DisplayType.Picklist;
        
        FieldInfo sevenDaysFieldInfo = new FieldInfo();
        sevenDaysFieldInfo.name = '7';
        sevenDaysFieldInfo.label = SPM_Consts.TIMEFRAME_7_DAYS;
        
        FieldInfo fourteenDaysFieldInfo = new FieldInfo();
        fourteenDaysFieldInfo.name = '14';
        fourteenDaysFieldInfo.label = SPM_Consts.TIMEFRAME_14_DAYS;
        
        FieldInfo thirtyDaysFieldInfo = new FieldInfo();
        thirtyDaysFieldInfo.name = '30';
        thirtyDaysFieldInfo.label = SPM_Consts.TIMEFRAME_30_DAYS;
        
        SOURCE_FOR_REPEATVISIT_WINDOW_INFO.sourceFieldInfoList = new List<FieldInfo> { sevenDaysFieldInfo, fourteenDaysFieldInfo, thirtyDaysFieldInfo };
    }
    
        private static final ParameterInfo SOURCE_FOR_FTF_COMPUTATION;
    static {
        SOURCE_FOR_FTF_COMPUTATION = new ParameterInfo();        
        SOURCE_FOR_FTF_COMPUTATION.label = SPM_Consts.SOURCE_FROM_FTF_COMPUTATION;
        SOURCE_FOR_FTF_COMPUTATION.isCriteria = true;
        SOURCE_FOR_FTF_COMPUTATION.sourceFieldName = 'WorkOrder';
        SOURCE_FOR_FTF_COMPUTATION.sourceObjectField = SPM_Schema.Field.ftfSource;
        SOURCE_FOR_FTF_COMPUTATION.displayType = Schema.DisplayType.Picklist;
        
        FieldInfo workOrderFieldInfo = new FieldInfo();
        workOrderFieldInfo.name = 'WorkOrder';
        workOrderFieldInfo.label = Schema.getGlobalDescribe().get(SPM_Consts.SERVICE_ORDER).getDescribe().label; //'Work Order';
        
        FieldInfo workDetailFieldInfo = new FieldInfo();
        workDetailFieldInfo.name = 'WorkDetail';
        workDetailFieldInfo.label = Schema.getGlobalDescribe().get(SPM_Consts.SERVICE_ORDER_LINE).getDescribe().label; //'Work Detail';
        
        SOURCE_FOR_FTF_COMPUTATION.sourceFieldInfoList = new List<FieldInfo> { workOrderFieldInfo, workDetailFieldInfo };
    }
    
    private static final ParameterInfo WORK_DETAIL_CREATION_TIMEFRAME_FOR_FTF;
    static {
        WORK_DETAIL_CREATION_TIMEFRAME_FOR_FTF = new ParameterInfo();        
        WORK_DETAIL_CREATION_TIMEFRAME_FOR_FTF.label = SPM_Consts.UPPERLIMIT_WORK_DETAIL_CREATION_TIMEFRAME; 
        WORK_DETAIL_CREATION_TIMEFRAME_FOR_FTF.isCriteria = true;
        WORK_DETAIL_CREATION_TIMEFRAME_FOR_FTF.sourceFieldName = '0';
        WORK_DETAIL_CREATION_TIMEFRAME_FOR_FTF.sourceObjectField = SPM_Schema.Field.Period;
        WORK_DETAIL_CREATION_TIMEFRAME_FOR_FTF.displayType = Schema.DisplayType.String;
        
        FieldInfo zero = new FieldInfo();
        zero.name = '0';
        zero.label = '0 Day';
        
        FieldInfo one = new FieldInfo();
        one.name = '1';
        one.label = '1 Day';
        
        FieldInfo two = new FieldInfo();
        two.name = '2';
        two.label = '2 Days';
        
        
        FieldInfo three = new FieldInfo();
        three.name = '3';
        three.label = '3 Days';
        
        
        FieldInfo four = new FieldInfo();
        four.name = '4';
        four.label = '4 Days';
        
        FieldInfo five = new FieldInfo();
        five.name = '5';
        five.label = '5 Days';
        
        WORK_DETAIL_CREATION_TIMEFRAME_FOR_FTF.sourceFieldInfoList = new List<FieldInfo> {zero, one, two, three, four, five};
        
    }
    
    private static final ParameterInfo SOURCE_FOR_PRIMARY_WORKORDER_FTF;
    static {
        SOURCE_FOR_PRIMARY_WORKORDER_FTF = new ParameterInfo();        
        SOURCE_FOR_PRIMARY_WORKORDER_FTF.label = SPM_Consts.LABEL_SOURCE_FOR_REFERENCE_TO_PW;
        SOURCE_FOR_PRIMARY_WORKORDER_FTF.isCriteria = true;
        SOURCE_FOR_PRIMARY_WORKORDER_FTF.sourceFieldName = 'No';
        SOURCE_FOR_PRIMARY_WORKORDER_FTF.sourceObjectField = SPM_Schema.Field.hasPrimaryWorkOrder;
        SOURCE_FOR_PRIMARY_WORKORDER_FTF.displayType = Schema.DisplayType.Picklist;
        
        FieldInfo yesFieldInfo = new FieldInfo();
        yesFieldInfo.name = 'Yes';
        yesFieldInfo.label = SPM_Consts.LABEL_YES;
        
        FieldInfo noFieldInfo = new FieldInfo();
        noFieldInfo.name = 'No';
        noFieldInfo.label = SPM_Consts.LABEL_NO;
        
        SOURCE_FOR_PRIMARY_WORKORDER_FTF.sourceFieldInfoList = new List<FieldInfo> { yesFieldInfo, noFieldInfo };
    }
    
    /**
     * 
     */
    public static final List<ParameterInfo> UTILIZATION_SOURCE_PARAMETER_LIST = new List<ParameterInfo> 
    { 
        SOURCE_FOR_NON_PRODUCTIVE_TIME_INFO,        
        SOURCE_FOR_LEAVES_INFO,
        SOURCE_FOR_BREAK_MINUTES_INFO
    };
    
    /**
     * 
     */
    public static final List<ParameterInfo> REPEATVISIT_SOURCE_PARAMETER_LIST = new List<ParameterInfo> 
    {  
        SOURCE_FOR_REPEATVISIT_COMPARE_INFO,
        SOURCE_FOR_PRIMRY_WORKORDER_INFO,
        SOURCE_FOR_REPEATVISIT_WINDOW_INFO,        
        SOURCE_FOR_ACCOUNT_INFO,
        SOURCE_FOR_LOCATION_INFO,
        SOURCE_FOR_INSTALLED_PRODUCT_INFO,
        SOURCE_FOR_SERVICE_DELIVERED_ON_INFO,
        SOURCE_FOR_TECHNICIAN_INFO,
        SOURCE_FOR_REPEATVIST_ADDITIONALCRITERIA
    };
        
    /**
     * 
     */
    public static final List<ParameterInfo> FTF_SOURCE_PARAMETER_LIST = new List<ParameterInfo> 
    { 
        SOURCE_FOR_ACCOUNT_INFO, 
        SOURCE_FOR_TECHNICIAN_INFO, 
        SOURCE_FOR_PRODUCT_INFO, 
        SOURCE_FOR_CLOSED_ON_INFO,
        SOURCE_FOR_FTF_COMPUTATION, 
        SOURCE_FOR_PRIMARY_WORKORDER_FTF,
        WORK_DETAIL_CREATION_TIMEFRAME_FOR_FTF 
    };
        
    /**
     * 
     */
    public static final List<ParameterInfo> MTTR_SOURCE_PARAMETER_LIST = new List<ParameterInfo> 
    { 
        SOURCE_FOR_IDLE_TIME_INFO,
        SOURCE_FOR_TECHNICIAN_INFO,
        SOURCE_FOR_PRODUCT_INFO,        
        SOURCE_FOR_SCHEDULE_DATE_INFO,
        SOURCE_FOR_WORK_ORDER_ACCOUNT_INFO
    };
        
    /**
     * 
     */
    public static final List<ParameterInfo> MTTC_SOURCE_PARAMETER_LIST = new List<ParameterInfo> 
    { 
        SOURCE_FOR_TECHNICIAN_INFO,
        SOURCE_FOR_PRODUCT_INFO,
        SOURCE_FOR_CREATED_DATE_INFO,
        SOURCE_FOR_COMPLETED_DATE_INFO,
        SOURCE_FOR_ACCOUNT_INFO
    };
        
    /**
     * 
     */
    public static final List<ParameterInfo> ART_SOURCE_PARAMETER_LIST = new List<ParameterInfo> 
    { 
        SOURCE_FOR_TECHNICIAN_INFO,
        SOURCE_FOR_ACCOUNT_INFO,
        SOURCE_FOR_PRODUCT_INFO,
        SOURCE_FOR_SERVICE_DELIVERED_ON_INFO
    };
            
    /**
     * 
     */
    public static final List<ParameterInfo> UP_DOWN_SOURCE_PARAMETER_LIST = new List<ParameterInfo> 
    {
        SOURCE_FOR_CALCULATE_DIFFERENCE,
        SOURCE_FOR_UP_DOWN_CREATED_DATE_INFO,
        SOURCE_FOR_UP_DOWN_CLOSED_ON_INFO,
        SOURCE_FOR_INSTALLED_PRODUCT_INFO,
        SOURCE_FOR_BUSINESS_HOURS_INFO
    };
    public static final List<ParameterInfo> MTBF_PARAMETER_LIST = new List<ParameterInfo> 
    {   SOURCE_FOR_ACCOUNT_INFO,
        SOURCE_FOR_INSTALLED_PRODUCT_INFO,
        SOURCE_FOR_CALCULATE_DIFFERENCE,
        SOURCE_FOR_UP_DOWN_CREATED_DATE_INFO,
        SOURCE_FOR_UP_DOWN_CLOSED_ON_INFO,
        SOURCE_FOR_BUSINESS_HOURS_INFO
    };
    /**
     * 
     */
    public static final List<ParameterInfo> CONTRACT_PENETRATION_SOURCE_PARAMETER_LIST = new List<ParameterInfo> 
    { 
        SOURCE_FOR_ACCOUNT_INFO
    };
    
    /**
     * 
     */
    public static final ExpressionDetails QUALIFICATION_EXPRESSION;
    static {
        QUALIFICATION_EXPRESSION = new ExpressionDetails();
        //QUALIFICATION_EXPRESSION.label = SPM_Consts.LABEL_QUALIFICATION_CRITERIA;
        QUALIFICATION_EXPRESSION.expressionType = SPM_Schema.ExpressionType.QualificationCriteria;
    }
    
    /**
     * 
     */
    public static final ExpressionDetails FTF_EXPRESSION;
    static {
        FTF_EXPRESSION = new ExpressionDetails();
        FTF_EXPRESSION.label = SPM_Consts.LABEL_CRITERIA_FOR_FIRST_TIME_FIX;
        FTF_EXPRESSION.expressionType = SPM_Schema.ExpressionType.CriteriaForFirstTimeFixed;
        FTF_EXPRESSION.sourceObjectName = SPM_Consts.SERVICE_ORDER;
    }
    
    public static final ExpressionDetails FTF_WD_EXPRESSION;
    static {
        FTF_WD_EXPRESSION = new ExpressionDetails();
        FTF_WD_EXPRESSION.label = SPM_Consts.LABEL_CRITERIA_FOR_FIRST_TIME_FIX;
        FTF_WD_EXPRESSION.expressionType = SPM_Schema.ExpressionType.CriteriaForFirstTimeFixedUsingWorkDetail;
        FTF_WD_EXPRESSION.sourceObjectName = SPM_Consts.SERVICE_ORDER_LINE;
    }   
    
    public static final ExpressionDetails COVERED_PRODUCT_EXPRESSION;
    static {
        COVERED_PRODUCT_EXPRESSION = new ExpressionDetails();
        COVERED_PRODUCT_EXPRESSION.label = SPM_Consts.LABEL_CRITERIA_FOR_COVERED_PRODUCT;
        COVERED_PRODUCT_EXPRESSION.expressionType = SPM_Schema.ExpressionType.FilterCriteria;
        COVERED_PRODUCT_EXPRESSION.sourceObjectName = SPM_Consts.SERVICE_CONTRACT_PRODUCTS;
        COVERED_PRODUCT_EXPRESSION.expressionRuleId = 'EXPR093'; //'Valid_Covered_Products'; //TODO - Change this id after the expression is seeded.
    }
    
    
    /**
     * 
     */
    public static final ExpressionDetails WORK_ORDER_EXCLUDE_EXPRESSION;
    static {
        WORK_ORDER_EXCLUDE_EXPRESSION = new ExpressionDetails();
        WORK_ORDER_EXCLUDE_EXPRESSION.label = SPM_Consts.LABEL_CRITERIA_FOR_EXCLUDE_WORK_ORDER;
        WORK_ORDER_EXCLUDE_EXPRESSION.expressionType = SPM_Schema.ExpressionType.WorkOrderExcludeCriteria;
        WORK_ORDER_EXCLUDE_EXPRESSION.sourceObjectName = SPM_Consts.SERVICE_ORDER;
    }

    public static final ExpressionDetails WORK_ORDER_EXPRESSION;
    static {
        WORK_ORDER_EXPRESSION = new ExpressionDetails();
        WORK_ORDER_EXPRESSION.label = SPM_Consts.LABEL_CRITERIA_FOR_WORK_ORDER;
        WORK_ORDER_EXPRESSION.expressionType = SPM_Schema.ExpressionType.WorkOrderCriteria;
        WORK_ORDER_EXPRESSION.sourceObjectName = SPM_Consts.SERVICE_ORDER;
    }
    
    public static final ObjectMappingDetails WORK_ORDER_FTF_MAPPING;
    static {
        WORK_ORDER_FTF_MAPPING = new ObjectMappingDetails();
        WORK_ORDER_FTF_MAPPING.label = SPM_Consts.LABEL_OBJECT_MAPPING;
        WORK_ORDER_FTF_MAPPING.sourceObjectName = SPM_Consts.SERVICE_ORDER;
        WORK_ORDER_FTF_MAPPING.targetObjectName = SPM_Consts.FIRST_TIME_FIX;
    }
    
    public static final ObjectMappingDetails WORK_ORDER_MTTR_MAPPING;
    static {
        WORK_ORDER_MTTR_MAPPING = new ObjectMappingDetails();
        WORK_ORDER_MTTR_MAPPING.referenceObjectName = true;
        WORK_ORDER_MTTR_MAPPING.label = SPM_Consts.LABEL_OBJECT_MAPPING;
        WORK_ORDER_MTTR_MAPPING.sourceObjectName = SPM_Consts.SERVICE_ORDER;
        WORK_ORDER_MTTR_MAPPING.targetObjectName = SPM_Consts.MEAN_TIME_TO_REPAIR;
    }
    
    public static final ObjectMappingDetails WORK_ORDER_MTTC_MAPPING;
    static {
        WORK_ORDER_MTTC_MAPPING = new ObjectMappingDetails();
        WORK_ORDER_MTTC_MAPPING.label = SPM_Consts.LABEL_OBJECT_MAPPING;
        WORK_ORDER_MTTC_MAPPING.sourceObjectName = SPM_Consts.SERVICE_ORDER;
        WORK_ORDER_MTTC_MAPPING.targetObjectName = SPM_Consts.MEAN_TIME_TO_COMPLETE;
    }
    
    public static final ObjectMappingDetails WORK_ORDER_ART_MAPPING;
    static {
        WORK_ORDER_ART_MAPPING = new ObjectMappingDetails();
        WORK_ORDER_ART_MAPPING.label = SPM_Consts.LABEL_OBJECT_MAPPING;
        WORK_ORDER_ART_MAPPING.sourceObjectName = SPM_Consts.SERVICE_ORDER;
        WORK_ORDER_ART_MAPPING.targetObjectName = SPM_Consts.AVERAGE_RESPONSE_TIME;
    }
    
    public static final ObjectMappingDetails WORK_ORDER_REPEATVISIT_MAPPING;
    static {
        WORK_ORDER_REPEATVISIT_MAPPING = new ObjectMappingDetails();
        WORK_ORDER_REPEATVISIT_MAPPING.label = SPM_Consts.LABEL_OBJECT_MAPPING;
        WORK_ORDER_REPEATVISIT_MAPPING.sourceObjectName = SPM_Consts.SERVICE_ORDER;
        WORK_ORDER_REPEATVISIT_MAPPING.targetObjectName = SPM_Consts.REPEATVISIT;
    }
    
    public static final ObjectMappingDetails IB_CP_MAPPING;
    static {
        IB_CP_MAPPING = new ObjectMappingDetails();
        IB_CP_MAPPING.label = SPM_Consts.LABEL_OBJECT_MAPPING;
        IB_CP_MAPPING.sourceObjectName = SPM_Consts.INSTALLED_PRODUCT;
        IB_CP_MAPPING.targetObjectName = SPM_Consts.CONTRACT_PENETRATION;
    } 
   
    public static final ObjectMappingDetails TIMESHEET_URILIZATION_MAPPING;
    static {
        TIMESHEET_URILIZATION_MAPPING = new ObjectMappingDetails();
        TIMESHEET_URILIZATION_MAPPING.label = SPM_Consts.LABEL_OBJECT_MAPPING;
        TIMESHEET_URILIZATION_MAPPING.sourceObjectName = SPM_Consts.TECHNICIAN_OBJECT;
        TIMESHEET_URILIZATION_MAPPING.targetObjectName = SPM_Consts.SPM_UTILIZATION;
    }
    
    public static final ObjectMappingDetails SERVICE_CONTRACT_CONTRACT_UP_TIME_MAPPING;
    static {
        SERVICE_CONTRACT_CONTRACT_UP_TIME_MAPPING = new ObjectMappingDetails();
        SERVICE_CONTRACT_CONTRACT_UP_TIME_MAPPING.label = SPM_Consts.LABEL_OBJECT_MAPPING;
        SERVICE_CONTRACT_CONTRACT_UP_TIME_MAPPING.sourceObjectName = SPM_Consts.SERVICE_CONTRACT;
        SERVICE_CONTRACT_CONTRACT_UP_TIME_MAPPING.targetObjectName = SPM_Consts.CONTRACT_UP_TIME;
    }
    public static final ObjectMappingDetails MEAN_TIME_BETWEEN_FAILURE_MAPPING;
    static {
        MEAN_TIME_BETWEEN_FAILURE_MAPPING = new ObjectMappingDetails();
        MEAN_TIME_BETWEEN_FAILURE_MAPPING.label = SPM_Consts.LABEL_OBJECT_MAPPING;
        MEAN_TIME_BETWEEN_FAILURE_MAPPING.sourceObjectName = SPM_Consts.INSTALLED_PRODUCT;
        MEAN_TIME_BETWEEN_FAILURE_MAPPING.targetObjectName = SPM_Consts.MEAN_TIME_BETWEEN_FAILURE;
    }
    /**
     * 
     */
    public static final CalculationMethod CAL_METHOD_REPEATVISIT_WO_AS_SOURCE;
    static {
        CAL_METHOD_REPEATVISIT_WO_AS_SOURCE = new CalculationMethod();
        CAL_METHOD_REPEATVISIT_WO_AS_SOURCE.method = SPM_Consts.REPEATVISIT_CALCULATION_METHOD;        
        CAL_METHOD_REPEATVISIT_WO_AS_SOURCE.sourceObjectName = SPM_Consts.SERVICE_ORDER;
        CAL_METHOD_REPEATVISIT_WO_AS_SOURCE.targetObjectName = SPM_Consts.REPEATVISIT;
        CAL_METHOD_REPEATVISIT_WO_AS_SOURCE.parameterInfoList = REPEATVISIT_SOURCE_PARAMETER_LIST;
        CAL_METHOD_REPEATVISIT_WO_AS_SOURCE.objectMappingDetailsList.add( WORK_ORDER_REPEATVISIT_MAPPING );
        
        QUALIFICATION_EXPRESSION.label = SPM_Consts.LABEL_CRITERIA_FOR_WORK_ORDER;
        QUALIFICATION_EXPRESSION.expressionRuleId = 'EXPR091';
        CAL_METHOD_REPEATVISIT_WO_AS_SOURCE.expressionDetailsList.add( new ExpressionDetails( QUALIFICATION_EXPRESSION) );
        
        WORK_ORDER_EXPRESSION.label = SPM_Consts.LABEL_CRITERIA_FOR_REPEATVISIT_WORK_ORDER;
        WORK_ORDER_EXPRESSION.expressionRuleId = 'EXPR084';
        CAL_METHOD_REPEATVISIT_WO_AS_SOURCE.expressionDetailsList.add( new ExpressionDetails( WORK_ORDER_EXPRESSION) );
    }
    
    /**
     * 
     */
    public static final CalculationMethod CAL_METHOD_FTF_WO_AS_SOURCE;
    static {
        CAL_METHOD_FTF_WO_AS_SOURCE = new CalculationMethod();
        CAL_METHOD_FTF_WO_AS_SOURCE.method = SPM_Consts.SOURCE_FROM_WORK_ORDER;
        //CAL_METHOD_FTF_WO_AS_SOURCE.appliesTo = SPM_Consts.DEFAULT_FTF_APPLIES_TO;
        CAL_METHOD_FTF_WO_AS_SOURCE.sourceObjectName = SPM_Consts.SERVICE_ORDER;
        CAL_METHOD_FTF_WO_AS_SOURCE.targetObjectName = SPM_Consts.FIRST_TIME_FIX;
        CAL_METHOD_FTF_WO_AS_SOURCE.parameterInfoList = FTF_SOURCE_PARAMETER_LIST;
        CAL_METHOD_FTF_WO_AS_SOURCE.objectMappingDetailsList.add( WORK_ORDER_FTF_MAPPING );
        
        QUALIFICATION_EXPRESSION.label = SPM_Consts.LABEL_CRITERIA_FOR_WORK_ORDER;
        QUALIFICATION_EXPRESSION.expressionRuleId = 'EXPR083';
        CAL_METHOD_FTF_WO_AS_SOURCE.expressionDetailsList.add( new ExpressionDetails( QUALIFICATION_EXPRESSION) );
        
        FTF_EXPRESSION.expressionRuleId = 'EXPR084';
        CAL_METHOD_FTF_WO_AS_SOURCE.expressionDetailsList.add( new ExpressionDetails( FTF_EXPRESSION ) );
        
        FTF_WD_EXPRESSION.expressionRuleId = 'EXPR085'; //Work-detail support
        CAL_METHOD_FTF_WO_AS_SOURCE.expressionDetailsList.add( new ExpressionDetails( FTF_WD_EXPRESSION ) );
    }
    
    /**
     * 
     */
    public static final CalculationMethod CAL_METHOD_UP_DOWN_IB_AS_SOURCE;
    static {
        CAL_METHOD_UP_DOWN_IB_AS_SOURCE = new CalculationMethod();
        CAL_METHOD_UP_DOWN_IB_AS_SOURCE.method = SPM_Consts.SOURCE_FROM_SERVICE_CONTRACT;
        //CAL_METHOD_UP_DOWN_IB_AS_SOURCE.appliesTo = SPM_Consts.DEFAULT_UPDOWN_APPLIES_TO;
        CAL_METHOD_UP_DOWN_IB_AS_SOURCE.sourceObjectName = SPM_Consts.SERVICE_CONTRACT;
        CAL_METHOD_UP_DOWN_IB_AS_SOURCE.targetObjectName = SPM_Consts.CONTRACT_UP_TIME;
        CAL_METHOD_UP_DOWN_IB_AS_SOURCE.parameterInfoList = UP_DOWN_SOURCE_PARAMETER_LIST;
        CAL_METHOD_UP_DOWN_IB_AS_SOURCE.objectMappingDetailsList.add( SERVICE_CONTRACT_CONTRACT_UP_TIME_MAPPING );
        
        QUALIFICATION_EXPRESSION.label = SPM_Consts.LABEL_CRITERIA_FOR_SERVICE_CONTRACT;
        QUALIFICATION_EXPRESSION.expressionRuleId = 'EXPR031';
        CAL_METHOD_UP_DOWN_IB_AS_SOURCE.expressionDetailsList.add( new ExpressionDetails( QUALIFICATION_EXPRESSION ) );
        
        
        CAL_METHOD_UP_DOWN_IB_AS_SOURCE.expressionDetailsList.add( new ExpressionDetails( COVERED_PRODUCT_EXPRESSION ) );
        
        WORK_ORDER_EXPRESSION.expressionRuleId = 'EXPR086';
        WORK_ORDER_EXPRESSION.label = SPM_Consts.LABEL_CRITERIA_FOR_WORK_ORDER;
        CAL_METHOD_UP_DOWN_IB_AS_SOURCE.expressionDetailsList.add( new ExpressionDetails( WORK_ORDER_EXPRESSION ) );
    }
    
    /**
     * 
     */
    public static final CalculationMethod CAL_METHOD_MTTR_WO_WD_AS_SOURCE;
    static {
        CAL_METHOD_MTTR_WO_WD_AS_SOURCE = new CalculationMethod();
        CAL_METHOD_MTTR_WO_WD_AS_SOURCE.method = SPM_Consts.MTTR_SUM_OF_LABOR_DETAILS;
        //CAL_METHOD_MTTR_WO_WD_AS_SOURCE.appliesTo = SPM_Consts.DEFAULT_MTTR_APPLIES_TO;
        CAL_METHOD_MTTR_WO_WD_AS_SOURCE.sourceObjectName = SPM_Consts.SERVICE_ORDER_LINE;
        CAL_METHOD_MTTR_WO_WD_AS_SOURCE.targetObjectName = SPM_Consts.MEAN_TIME_TO_REPAIR;
        CAL_METHOD_MTTR_WO_WD_AS_SOURCE.parameterInfoList = MTTR_SOURCE_PARAMETER_LIST;
        CAL_METHOD_MTTR_WO_WD_AS_SOURCE.objectMappingDetailsList.add( WORK_ORDER_MTTR_MAPPING );
        
        WORK_ORDER_EXPRESSION.expressionRuleId = 'EXPR060';
        WORK_ORDER_EXPRESSION.label = SPM_Consts.LABEL_CRITERIA_FOR_WORK_ORDER;
        CAL_METHOD_MTTR_WO_WD_AS_SOURCE.expressionDetailsList.add( new ExpressionDetails( WORK_ORDER_EXPRESSION ) );
        
        QUALIFICATION_EXPRESSION.label = SPM_Consts.LABEL_CRITERIA_FOR_WORK_DETAIL;
        QUALIFICATION_EXPRESSION.expressionRuleId = 'EXPR085';
        CAL_METHOD_MTTR_WO_WD_AS_SOURCE.expressionDetailsList.add( new ExpressionDetails( QUALIFICATION_EXPRESSION ) );
    }
    
    /**
     * 
     */
    public static final CalculationMethod CAL_METHOD_MTTC_WO_AS_SOURCE;
    static {
        CAL_METHOD_MTTC_WO_AS_SOURCE = new CalculationMethod();
        CAL_METHOD_MTTC_WO_AS_SOURCE.method = SPM_Consts.MTTC_SOURCE_FROM_WORK_ORDER;
        CAL_METHOD_MTTC_WO_AS_SOURCE.sourceObjectName = SPM_Consts.SERVICE_ORDER;
        CAL_METHOD_MTTC_WO_AS_SOURCE.targetObjectName = SPM_Consts.MEAN_TIME_TO_COMPLETE;
        CAL_METHOD_MTTC_WO_AS_SOURCE.parameterInfoList = MTTC_SOURCE_PARAMETER_LIST;
        CAL_METHOD_MTTC_WO_AS_SOURCE.objectMappingDetailsList.add( WORK_ORDER_MTTC_MAPPING );
        
        QUALIFICATION_EXPRESSION.label = SPM_Consts.LABEL_CRITERIA_FOR_WORK_ORDER;
        
        QUALIFICATION_EXPRESSION.expressionRuleId = 'EXPR060';
        CAL_METHOD_MTTC_WO_AS_SOURCE.expressionDetailsList.add( new ExpressionDetails( QUALIFICATION_EXPRESSION ) );
    }
    
    /**
     * 
     */
    public static final CalculationMethod CAL_METHOD_ART_WO_AS_SOURCE;
    static {
        CAL_METHOD_ART_WO_AS_SOURCE = new CalculationMethod();
        CAL_METHOD_ART_WO_AS_SOURCE.method = SPM_Consts.ART_SOURCE_FROM_WORK_ORDER;
        CAL_METHOD_ART_WO_AS_SOURCE.sourceObjectName = SPM_Consts.SERVICE_ORDER;
        CAL_METHOD_ART_WO_AS_SOURCE.targetObjectName = SPM_Consts.AVERAGE_RESPONSE_TIME;
        CAL_METHOD_ART_WO_AS_SOURCE.parameterInfoList = ART_SOURCE_PARAMETER_LIST;
        CAL_METHOD_ART_WO_AS_SOURCE.objectMappingDetailsList.add( WORK_ORDER_ART_MAPPING );
        
        QUALIFICATION_EXPRESSION.label = SPM_Consts.LABEL_CRITERIA_FOR_WORK_ORDER;
        
        QUALIFICATION_EXPRESSION.expressionRuleId = 'EXPR060';
        CAL_METHOD_ART_WO_AS_SOURCE.expressionDetailsList.add( new ExpressionDetails( QUALIFICATION_EXPRESSION ) );
    }
    
    /**
     * 
     */
    public static final CalculationMethod CAL_METHOD_CP_IB_AS_SOURCE;
    static {
        CAL_METHOD_CP_IB_AS_SOURCE = new CalculationMethod();
        CAL_METHOD_CP_IB_AS_SOURCE.method = SPM_Consts.SOURCE_FROM_INSTALLED_PRODUCT;
        //CAL_METHOD_CP_IB_AS_SOURCE.appliesTo = SPM_Consts.DEFAULT_CP_APPLIES_TO;
        CAL_METHOD_CP_IB_AS_SOURCE.sourceObjectName = SPM_Consts.INSTALLED_PRODUCT;
        CAL_METHOD_CP_IB_AS_SOURCE.targetObjectName = SPM_Consts.CONTRACT_PENETRATION;
        CAL_METHOD_CP_IB_AS_SOURCE.parameterInfoList = CONTRACT_PENETRATION_SOURCE_PARAMETER_LIST;
        CAL_METHOD_CP_IB_AS_SOURCE.objectMappingDetailsList.add( IB_CP_MAPPING );
        
        
        QUALIFICATION_EXPRESSION.label = SPM_Consts.LABEL_CRITERIA_FOR_INSTALLED_PRODUCT;
        QUALIFICATION_EXPRESSION.expressionRuleId = 'EXPR087';
        CAL_METHOD_CP_IB_AS_SOURCE.expressionDetailsList.add( new ExpressionDetails( QUALIFICATION_EXPRESSION ) );
        
        CAL_METHOD_CP_IB_AS_SOURCE.expressionDetailsList.add( new ExpressionDetails( COVERED_PRODUCT_EXPRESSION ) );
    }
    
    /**
     * 
     */
    public static final CalculationMethod CAL_METHOD_TECH_UTILIZATION_TIMESHEET;
    static {
        CAL_METHOD_TECH_UTILIZATION_TIMESHEET = new CalculationMethod();
        CAL_METHOD_TECH_UTILIZATION_TIMESHEET.method = SPM_Consts.UTILIZATION_CALCULATION_METHOD;
        CAL_METHOD_TECH_UTILIZATION_TIMESHEET.sourceObjectName = SPM_Consts.TIMESHEET;
        CAL_METHOD_TECH_UTILIZATION_TIMESHEET.targetObjectName = SPM_Consts.SPM_UTILIZATION;
        CAL_METHOD_TECH_UTILIZATION_TIMESHEET.parameterInfoList = UTILIZATION_SOURCE_PARAMETER_LIST;
        CAL_METHOD_TECH_UTILIZATION_TIMESHEET.objectMappingDetailsList.add( TIMESHEET_URILIZATION_MAPPING );
        
        QUALIFICATION_EXPRESSION.label = SPM_Consts.LABEL_CRITERIA_FOR_TIMESHEET;
        QUALIFICATION_EXPRESSION.expressionRuleId = 'EXPR089';
        CAL_METHOD_TECH_UTILIZATION_TIMESHEET.expressionDetailsList.add( new ExpressionDetails( QUALIFICATION_EXPRESSION ) );
    }
    
    public static final CalculationMethod CAL_METHOD_ACCOUNT_SUMMARY;
    static {
        CAL_METHOD_ACCOUNT_SUMMARY = new CalculationMethod();
        CAL_METHOD_ACCOUNT_SUMMARY.sourceObjectName = SPM_Consts.SERVICEMAX_PROCESS;
        CAL_METHOD_ACCOUNT_SUMMARY.targetObjectName = SPM_Consts.ACCOUNT_SUMMARY;
    }
    public static final CalculationMethod CAL_METHOD_MTBF;
    static {
        CAL_METHOD_MTBF = new CalculationMethod();
        CAL_METHOD_MTBF.sourceObjectName = SPM_Consts.INSTALLED_PRODUCT;
        CAL_METHOD_MTBF.targetObjectName = SPM_Consts.MEAN_TIME_BETWEEN_FAILURE;
        CAL_METHOD_MTBF.objectMappingDetailsList.add( MEAN_TIME_BETWEEN_FAILURE_MAPPING );
        CAL_METHOD_MTBF.parameterInfoList = MTBF_PARAMETER_LIST;
        CAL_METHOD_MTBF.method = SPM_Consts.MTBF_SOURCE_FROM_WORK_ORDER;
        QUALIFICATION_EXPRESSION.label = SPM_Consts.LABEL_CRITERIA_FOR_INSTALLED_PRODUCT;
        QUALIFICATION_EXPRESSION.expressionRuleId = 'EXPR087';
        CAL_METHOD_MTBF.expressionDetailsList.add( new ExpressionDetails( QUALIFICATION_EXPRESSION ) );
        
        WORK_ORDER_EXPRESSION.expressionRuleId = 'EXPR060';
        WORK_ORDER_EXPRESSION.label = SPM_Consts.LABEL_CRITERIA_FOR_WORK_ORDER;
        CAL_METHOD_MTBF.expressionDetailsList.add( new ExpressionDetails( WORK_ORDER_EXPRESSION ) );

        WORK_ORDER_EXCLUDE_EXPRESSION.expressionRuleId = '--None--';
        WORK_ORDER_EXCLUDE_EXPRESSION.label = SPM_Consts.LABEL_CRITERIA_FOR_EXCLUDE_WORK_ORDER;
        CAL_METHOD_MTBF.expressionDetailsList.add( new ExpressionDetails( WORK_ORDER_EXCLUDE_EXPRESSION ) );
        
        /*              
        QUALIFICATION_EXPRESSION.label = SPM_Consts.LABEL_CRITERIA_FOR_WORK_ORDER;
        QUALIFICATION_EXPRESSION.expressionRuleId = 'EXPR060';
        CAL_METHOD_MTBF.expressionDetailsList.add( new ExpressionDetails( QUALIFICATION_EXPRESSION ) );
        */
    }
    /**
     * 
     */
    public static final List<CalculationMethod> REPEATVISIT_CAL_METHOD_LIST = new List<CalculationMethod> {
        CAL_METHOD_REPEATVISIT_WO_AS_SOURCE
    };
        
    /**
     * 
     */
    public static final List<CalculationMethod> FTF_CAL_METHOD_LIST = new List<CalculationMethod> {
        CAL_METHOD_FTF_WO_AS_SOURCE
    };
        
    /**
     * 
     */
    public static final List<CalculationMethod> MTTR_CAL_METHOD_LIST = new List<CalculationMethod> {
        CAL_METHOD_MTTR_WO_WD_AS_SOURCE
    };
        
    /**
     * 
     */
    public static final List<CalculationMethod> MTTC_CAL_METHOD_LIST = new List<CalculationMethod> {
        CAL_METHOD_MTTC_WO_AS_SOURCE
    };
        
    /**
     * 
     */
    public static final List<CalculationMethod> ART_CAL_METHOD_LIST = new List<CalculationMethod> {
        CAL_METHOD_ART_WO_AS_SOURCE
    };
        
    /**
     * 
     */
    public static final List<CalculationMethod> UP_DOWN_CAL_METHOD_LIST = new List<CalculationMethod> {
        CAL_METHOD_UP_DOWN_IB_AS_SOURCE
    };
        
    /**
     * 
     */
    public static final List<CalculationMethod> TECT_UTILIZATION_CAL_METHOD_LIST = new List<CalculationMethod> {
        CAL_METHOD_TECH_UTILIZATION_TIMESHEET
    };
        
    /**
     * 
     */
    public static final List<CalculationMethod> CONTRACT_PENETRATION_CAL_METHOD_LIST = new List<CalculationMethod> { CAL_METHOD_CP_IB_AS_SOURCE };
    
   /**
    * List of calculation methods associated with Account Summary flow.
    **/
    public static final List<CalculationMethod> ACCOUNT_SUMMARY_CAL_METHOD_LIST = new List<CalculationMethod> {
        CAL_METHOD_ACCOUNT_SUMMARY
    };
    /**
    * List of calculation methods associated with MTBF flow.
    **/
     public static final List<CalculationMethod> MTBF_CAL_METHOD_LIST = new List<CalculationMethod> {
        CAL_METHOD_MTBF
    };   
    /**
     * 
     */
        public static Map<String, String> getSourceObjectFieldMap( SPM_Schema.Report report ) {
            
            Map<String, String> SourceObjectFieldMap = new Map<String, String>();
            
            if( report == SPM_Schema.Report.RepeatVisit ) {
                SourceObjectFieldMap = DEFAULT_REPEATVISIT_SOBJ_FIELDS.clone();
            } else if( report == SPM_Schema.Report.FirstTimeFix ) {
                SourceObjectFieldMap = DEFAULT_FTF_SOBJ_FIELDS.clone();
            } else if( report == SPM_Schema.Report.Utilization ) {
                SourceObjectFieldMap = DEFAULT_TECH_UTIL_SOBJ_FIELDS.clone();
            } else if( report == SPM_Schema.Report.MeanTimeToRepair ) {
                SourceObjectFieldMap = DEFAULT_MTTR_SOBJ_FIELDS.clone();
            } else if(report == SPM_Schema.Report.ContractPenetration ){
                SourceObjectFieldMap = DEFAULT_CP_SOBJ_FIELDS.clone();
            } else if(report == SPM_Schema.Report.UpDownTime ){
                SourceObjectFieldMap = DEFAULT_UPDOWN_SOBJ_FIELDS.clone();
            } else if( report == SPM_Schema.Report.MeanTimeToComplete ) {
                SourceObjectFieldMap = DEFAULT_MTTC_SOBJ_FIELDS.clone();
            } else if( report == SPM_Schema.Report.AverageResponseTime ) {
                SourceObjectFieldMap = DEFAULT_ART_SOBJ_FIELDS.clone();
            } else if( report == SPM_Schema.Report.AccountSummary ) {
                SourceObjectFieldMap = DEFAULT_ACCOUNT_SUMMARY_SOBJ_FIELDS.clone();
            } else if( report == SPM_Schema.Report.MeanTimeBetweenFailure ) {
                SourceObjectFieldMap = DEFAULT_MTBF_SOBJ_FIELDS.clone();
            }
            
            return SourceObjectFieldMap;
        }
    
    public static Map<String, String> getFieldAPINameMap( SPM_Schema.Report report ) {
        
        Map<String, String> targetObjectFieldMap = new Map<String, String>();
        
        if( report == SPM_Schema.Report.FirstTimeFix ) {
            targetObjectFieldMap = DEFAULT_FTF_TOBJ_FIELDS.clone();
        } else if( report == SPM_Schema.Report.MeanTimeToRepair ) {
            targetObjectFieldMap = DEFAULT_MTTR_TOBJ_FIELDS.clone();
        } else if( report == SPM_Schema.Report.MeanTimeToComplete ) {
            targetObjectFieldMap = DEFAULT_MTTC_TOBJ_FIELDS.clone();
        } else if( report == SPM_Schema.Report.ContractPenetration ) {
            targetObjectFieldMap = DEFAULT_CP_TOBJ_FIELDS.clone();
        }else if( report == SPM_Schema.Report.MeanTimeBetweenFailure ) {
            targetObjectFieldMap = DEFAULT_MTBF_TOBJ_FIELDS.clone();
        }
        
        return targetObjectFieldMap;
    }
    
    /**
     * 
     */
    public static List<SPM_ConfigurationDefinition.CalculationMethod> getCalculationMethodList( String reportType ) {
        
        List<SPM_ConfigurationDefinition.CalculationMethod> calculationMethodList = new List<SPM_ConfigurationDefinition.CalculationMethod>();
        
        if( reportType == SPM_Schema.Report.RepeatVisit.name() ) {
            calculationMethodList = REPEATVISIT_CAL_METHOD_LIST.clone();
        } else if( reportType == SPM_Schema.Report.FirstTimeFix.name() ) {
            calculationMethodList = FTF_CAL_METHOD_LIST.clone();
        } else if( reportType == SPM_Schema.Report.MeanTimeToRepair.name() ) {
            calculationMethodList = MTTR_CAL_METHOD_LIST.clone();
        } else if( reportType == SPM_Schema.Report.UpDownTime.name() ) {
            calculationMethodList = UP_DOWN_CAL_METHOD_LIST.clone();
        } else if( reportType == SPM_Schema.Report.ContractPenetration.name() ) {
            calculationMethodList = CONTRACT_PENETRATION_CAL_METHOD_LIST.clone();
        } else if( reportType == SPM_Schema.Report.MeanTimeToComplete.name() ) {
            calculationMethodList = MTTC_CAL_METHOD_LIST.clone();
        } else if( reportType == SPM_Schema.Report.AverageResponseTime.name() ) {
            calculationMethodList = ART_CAL_METHOD_LIST.clone();
        } else if( reportType == SPM_Schema.Report.Utilization.name() ) {
            calculationMethodList = TECT_UTILIZATION_CAL_METHOD_LIST.clone();        
        } else if( reportType == SPM_Schema.Report.AccountSummary.name() ) {
            calculationMethodList = ACCOUNT_SUMMARY_CAL_METHOD_LIST.clone();        
        }else if( reportType == SPM_Schema.Report.MeanTimeBetweenFailure.name() ) {
            calculationMethodList = MTBF_CAL_METHOD_LIST.clone();
        }
        
        return calculationMethodList;
    }
    
    public static List<SVMXC__ServiceMax_Config_Data__c> getBusinessProcessConfig() {
        System.debug(LoggingLevel.DEBUG, 'SPM_ConfigurationDefinition.getBusinessProcessConfig() - enter');
        List<SVMXC__ServiceMax_Config_Data__c> listOfData = [Select SVMXC__Formula__c From SVMXC__ServiceMax_Config_Data__c Where RecordType.Name='SPM Details' 
                                                                and SVMXC__Dispatch_Process__r.RecordType.Name='SPM Rule' and SVMXC__Dispatch_Process__r.SVMXC__Name__c ='Business Process Config' 
                                                                Limit 1];                    
        System.debug('Existing Business Process Configuration - ' + listOfData);
        System.debug(LoggingLevel.DEBUG, 'SPM_ConfigurationDefinition.getBusinessProcessConfig() - exit');
        return listOfData;
    }
    
    public class BusinessProcessConfig
    {
        public String source;
        public String selectedCriteria;
    }
    
    public class LoadBusinessConfig
    {
        public BusinessProcessConfig businessProcessConfig;
        public Map<String,String> sources;
        public List<SPM_ConfigurationDefinition.ExpressionDetails> expressionDetail = new List<SPM_ConfigurationDefinition.ExpressionDetails>();
    }
    
    /**
     * 
     */
    private SPM_ConfigurationDefinition() {}
}