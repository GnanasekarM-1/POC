public with sharing class SFM_WrapperDef2 {

    public SFM_WrapperDef2() {

    }

    /*
        Request class for all the rest services
    */
    public class SFM2_Request {

        public List<String> entityids;
        public List<SFM2_ObjectInfo> sfm_ObjectList;
        public String entityType;
        public String tabInfo;
        public SFM2_Criteria criteria;
        public SFM2_Rule sfm_Rule;
        public SFM2_ProcessInfo sfm_Process;
        public SFM2_Layout sfm_Layout;
        public SFM2_LookupConfig sfm_LkpConfig;
        public SFM2_DocTemplate sfm_Template;
        public SFM2_ResponseOptionMeta responseSet;
        public SFM2_QuestionMeta questionInfo;
        public boolean isClone = false;
        public boolean isChildCardAddedDeleted = false;
		public COMM_AuditTrail.AuditData auditData;
        public SFM2_Request(){
        }
    }

    /*
        Response class for all the rest services
    */
    public class SFM2_Response{
        public Object data;
        public Boolean success;
        //public Object errors;
        public String message;
        public SFM2_Response(){

        }
    }

    public class SFM2_ObjectInfo {
        public String apiName;
        public String objectAlias;
        public String objectType;
    }

    public class SFM2_Criteria {

        public String sourceObject;
        public String targetObject;
        public List<String> sourceObjectList;
        public List<String> targetObjectList;
        public SFM2_Criteria(){}
    }

    public class FieldProperties{
        public Integer length;
        public boolean calculated;
        public boolean custom;
        public boolean filterable;
        public boolean createable;
        public boolean updateable;
        public boolean idLookup;
        public String label;
        public String dataType;
        public boolean unique;
        public boolean nillable;
        public boolean nameField;
        public String name;
        public boolean autoNumber;
        public Object picklistValues;
        public String referenceTo;
        public Integer precision;
        public Integer scale;
        public String referenceNameField;
        public String relationshipName;
        public boolean htmlFormatted;
        public FieldProperties(){

        }
    }

    /*
        User info wrapper class
    */
    public class UserInfoWrapper{
        public String userId;               //SFDC User Id
        public String firstName;            //User First Name
        public String lastName;             //User Last Name
        public String dateFormat;           //User date format ex: DD/MM/YYYY
        public String timeZoneOffSet;       //offset ex: +05:30
        public String timeFormat;           //time format ex: h:mma
        public String thousandSepartor;
        public String decimalSeparator;
        public String userCurrency;         //Currency Id ex:
        public String svmxNameSpace;
        public String organizationId;
        public String organizationName;
        public String organizationType;
        public String userLocale;
        public String applicationType;
        public UserInfoWrapper(){

        }
    }
 /*
        Global/Group setting info wrapper class
    */
    public class SettingInfoWrapper{

        public Integer maxSortFields;
        public Boolean isChecklistEnabled;
        public Boolean isSalesforceFilesEnabled;
        public Boolean isUsageTrackingAllowed;
        public Boolean isApiConfigurationEnabled;

        public SettingInfoWrapper(){
            this.isApiConfigurationEnabled = false;
        }
    }
    /*
        List view details (Limited info to be displayed on the list view)
    */
    public class SFM2_ListViewDetails{
        public String sourceObject;         //Source object Name
        public String sourceObjectApi;
        public String targetObjectApi;
        public String targetObject;         //Target Object Name
        public String objectAlias;
        public String targetField;
        public String entityType;           //Entity Type : (SFM, Expressions, PageLayout, Validation rules etc  )
        public boolean dependencyExist;     //Set to true if the entity is referenced or used by any other entity
        public SFM2_EntityDetail entityDetail; //Detailed info of the entity
        public String message;
        public SFM2_ListViewDetails(){
            dependencyExist = false;
        }
    }

    public class SFM2_ProcessInfo{
        public SFM2_EntityDetail targetManager;
        public List<SFM2_ProcessNode> processNodeList;
        public List<SFM2_LinkedProcess> checklistProcessList;
        public List<SFM2_Event> events;
        public String adv_SubProcessId;  //for multisource configuration
        public String adv_SubProcessSrcField; //for multisource configuration
        public boolean adv_AttachmentEnabled;
        public boolean enableTargetedSync;
        public boolean enableVersionControl;
        public boolean includeSkippedSections;
        public boolean excludeSkippedQuestions;
        public boolean enableRealTimeValidation;
        public String displayFileName;
        public String pageLayoutId;
        public String templateId;
        public String tagKeys;
        public boolean isClone;
        public String displayFileMetaData ; // store opdoc editor file name fields
        public SFM2_ProcessInfo(){
            adv_AttachmentEnabled = false;
            isClone = false;
        }
    }


    public class SFM2_Layout{   //Layout
        public SFM2_EntityDetail layoutDetail; //name, id, type, standard
        public boolean isChecklist;
        public String processId;
        public String objectAPIName;
        public boolean hideSave;
        public boolean hideQuickSave;
        public String pageHelp;
        public String helpUrl;
        public boolean showAllSections;
        public boolean showAccountHistory;
        public boolean showProductHistory;
        public boolean enableTroubleShooting;
        public boolean enableServiceReportView;
        public boolean enableServiceReportGeneration;
        public String titleBar;
        public boolean includeSummary;
        public String summaryTitle;
        public boolean includeEventTimePlace;
        public boolean includeContact;
        public String includeField1;
        public String includeField2;
        public String includeField3;
        public boolean dependencyExist;
        public List<SFM2_LayoutSection> sectionDetails;
        public List<SFM2_Event> events;
        public SFM2_Layout(){

        }

    }

    public class SFM2_LayoutSection{
        public String sectionId;
        public Integer sequence;
        public Integer columns;
        public String sectionType;
        public String title;
        public String description;
        public String helpUrl;
        public String objectAlias;
        public String childAPIName;
        public String allowZeroLines;
        public boolean allowNew;
        public boolean allowDelete;
        public String multiAddField;
        public String multiAddObject;
        public String headerReferenceField;
        public boolean showinWeb;
        public boolean showinIpad;
        public boolean useForSLA;
        public String entryCriteriaId;
        public List<SFM2_Rule> exitCriteria; 
        public List<SFM2_Event> events;
        public List<SFM2_LayoutElement> layoutElements;
        public SFM2_LayoutSection(){

        }
    }

    public class SFM2_LayoutElement{
        public String eltId;
        public String eltType;
        public String apiName;
        public String dataType;
        public Integer sequence;
        public Integer row;
        public Integer column;
        public Integer noOfColumn;
        public String title;
        public boolean required;
        public boolean readOnly;
        public String referenceTo;
        public String referenceNameField;
        public String lkpupConfig;
        public boolean overrideContext;
        public String lkpContext;
        public String lkpMatchField;
        public String lkpFormFill;
        public String lkpContextSrc;
        public String questionId;
        public String questionRuleId;
        public String questionRuleMessage;
        public String checklistSourceField;
        public List<SFM2_Event> events;
        public SFM2_LayoutElement(){

        }
    }

    public class SFM2_DocTemplate {
        public SFM2_EntityDetail entityDetail;
        public String resources;
        public List<SFM2_DocTemplateDetail> templateDetails;
        public String templateContent;
        public String templateContentId;
        public String contentType;
        public boolean dependencyExist;
        public SFM2_DocTemplate(){

        }
    }

    public class SFM2_DocTemplateDetail {
        public String recordId;
        public String objectType;
        public String objectAPIName;
        public String templateDetailId;
        public String templateAlias;
        public String soqlData;
        public String metaData;
        public String referenceField;
        public SFM2_DocTemplateDetail(){

        }
    }

    public class SFM2_Event{
        public String eventId;
        public String eventType;
        public String eventCallType;
        public String eventActionId;
        public String urlWindowType;
        public Integer sequence;
        public String targetClass;
        public String targetNameSpace;
        public SFM2_Event(){

        }
    }

    /*
        Junction Record Info for DVR, Linked SFMs, Formulas & Checklist
    */
    public class SFM2_LinkedProcess{
        public String processId;                     //Junction Record Id
        public String linkedProcessName;             //Junction Record Name applicable only for Linked SFMs
        public String targetNodeId;                  //target node Id for which Junction record is created
        public String checklistId;
        public String checklistName;
        public String linkedProcessId;               //Reusable entity Id which is associated to the process
        public SFM2_Rule ruleInfo;                   //Rule defined on the reusable entity
        public Integer sequence;
        public String message ;
        public String checklistVersion;
        public SFM2_LinkedProcess(){

        }
    }

    public class SFM2_Rule{
        public SFM2_EntityDetail ruleDetail;
        public String sourceObject;
        public String objectAlias;
        public String targetObject;
        public String targetNodeId;
        public Integer sequence;
        public Integer targetSequence;
        public String advanceExpression;
        public String message;
        public boolean allowOverride;
        public boolean defaultOn;
        public String questionId;
        public String questionName;
        public String modeOfExecution;
        public List<SFM2_RuleExpression> expressionsList;
        public SFM2_Rule(){
            allowOverride = false;
            defaultOn = false;
        }
    }

    public class SFM2_LookupConfig{
        public SFM2_EntityDetail configDetail;
        public String lookupObject;
        public String defaultColumn;
        public boolean isDefault;
        public Integer lkpRecords;
        public SFM2_Rule lookupFilter;
        public List<SFM2_Rule> advancedFilters ;
        public SFM2_LookupConfig(){
            advancedFilters = new List<SFM2_Rule>();
        }
    }

    public class SFM2_QuestionsResponses{
        public String checklistId;
        public List<SFM2_QuestionMeta> questions;
        public List<SFM2_ResponseOptionMeta> responses;
        public SFM2_QuestionsResponses(){

        }
    }

    public class SFM2_QuestionMeta{
        public String question;
        public String questionId;
        public List<String> defaultValues;
        public String defaultLiteralValue;
        public String defaultResponseId;
        public String questionExtId;
        public String responseId;
        public String qType;
        public String createdBy;
        public String lastModifiedDate;
        public SFM2_Rule sfmRule;
        public String helpUrl;
        public List<String> tagsList;       //Tags associated to the entity
        public Boolean descriptionRequired;
        public Boolean showInSmartDoc;
        public SFM2_QuestionMeta(){
        }
    }

    public class SFM2_ResponseOptionMeta{
        public String name;
        public String responseId;
        public List<String> values;
        public SFM2_ResponseOptionMeta(){
        }
    }

    public class SFM2_RuleExpression{
        public String expressionId;
        public String sourceField;
        public String sourceFieldLabel;
        public String sourceFldDtaType;
        public String targetField;
        public String preference1; //For alternate Mapping values
        public string preference2; //For alternate MApping Values
        public String value;
        public String displayValue;
        public String literalValue;
        public String operator;
        public Integer sequence;
        public String sourceObject;  //required for source update rules
        public String targetNodeId;  //required for source update rules
        public String sourceNodeId;
        public String actionType;
        public String action; //required for source update rules
        public String configurationType;
        public String parameterType;
        public String contextType;
        public String processConfig;
        public String metaData; // for storing formula fields after parsing

        public SFM2_RuleExpression(){

        }
    }

    public class SFM2_ProcessNode{
        public String nodeId;
        public String nodeType;
        public String sourceNodeId;
        public String objectLabel;
        public String objectAPIName;
        public String nodeAPIName;
        public String nodeSourceAPIName;
        public String parentColumnAPIName; //Applicable only for child process nodes
        public String pageDetailId;
        public String templateDetailId;
        public String valueMappingId;
        public String valueMappingName;
        public String fieldMappingId;
        public String fieldMappingName;
        public String qcRuleId;
        public String qcRuleName;
        public List<SFM_WrapperDef.SortingRec> adv_SortingInfo;
        public List<String> fieldSets;
        public Integer sequence;
        public SFM2_Rule sourceUpdateRule;
        public List<SFM2_LinkedProcess> linkedProcessList;
        public List<SFM2_LinkedProcess> validationRulesList;
        public List<SFM2_LinkedProcess> formulasList;
		public boolean allowAttachments;
		public boolean allowImages;
        public SFM2_ProcessNode(){

        }
    }


    public class SFM2_Dependency{
        public String entityType;
        public String fieldAPIName;
        public String objectAPIName;
        public List<SFM2_EntityDetail> entityDetailList;
        public SFM2_dependency(){

        }

        public SFM2_Dependency(String fieldAPIName, String objectAPIName, List<SFM2_EntityDetail> entityDetailList){
            this.fieldAPIName = fieldAPIName;
            this.objectAPIName = objectAPIName;
            this.entityDetailList = entityDetailList;
        }
    }


    public class SFM2_EntityDetail{
        public String entityId;
        public String uniqueId;
        public boolean isStandard;
        public String entityDescription;
        public List<String> tagsList;       //Tags associated to the entity
        public String entityName;
        public String entityPath;
        public String entitySubType;
        public String entityStatus;
        public String lastModifiedDate;
        public String createdDate;
        public String createdBy;
        public String lastModifiedBy;
        public SFM2_EntityDetail(){

        }
    }

    public class SobjectInfo {
        public String label;
        public String apiName;
        public String lkpAPIName;
        public boolean custom;
        public Set<SobjectInfo> childReferences = new Set<SobjectInfo>();
        public Integer fieldsCount;
        public SobjectInfo(String objApiName, String objlabel){
            this.label = objlabel;
            this.apiName = objApiName;
        }

        public SobjectInfo(String objApiName, String objlabel, String lkpAPIName, boolean custom){
            this.label = objlabel;
            this.apiName = objApiName;
            this.lkpAPIName = lkpAPIName;
            this.custom = custom;
        }
    }

    public class SmaxPropertyElement{
        public String propertyKey;
        public List<String> propertyValues;
        public SmaxPropertyElement(){

        }
    }

    public class SFM2_Function{
        public SFM2_EntityDetail functionDetail;
        public String functionId;
        public String syntax;
        public String example;
        public String macroType;
        public String macroName;

        public SFM2_Function(){

        }
    }
}