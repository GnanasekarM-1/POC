public with sharing class ProductIQConfiguration {
    
    public class Action {
        public String name;
        public String actionType;
        public String action;
        public Boolean isGlobal;
        public Boolean isHidden;
        public String parentProfileId;
        
        public Action() {
            
        }
        
        public Action(String name, String actionType, String action, Boolean isGlobal, String parentProfileId) {
            this.name = name;
            this.actionType = actionType;
            this.action = action;
            this.isGlobal = isGlobal;
            this.parentProfileId = parentProfileId;
        }
    }
    
    public class Expression {
        public String operator;
        public String field;
        public String condition;
        public String value;
        public String fieldType;
        public String sequence;
        public String expRule;
        public String parameterType;
                
        public List<Expression> children;
        //expression types are operatorroot, operator, and expression   
        public String exprType;
        
        public Expression() {
            
        }
        
        public Expression(String operator, String exprType, List<Expression> children) {
            this.operator = operator;
            this.exprType = exprType;
            this.children = children;
        }
        
        public Expression(String operator, String exprType) {
            this.operator = operator;
            this.exprType = exprType;
        }
        
        public Expression(String field, String condition, String value, String exprType) {
            this.field = field;
            this.condition = condition;
            this.value = value;
            this.exprType = exprType;
        }
        
        public Expression(String field, String operator, String value, String exprType, String fieldType, String sequence, String expRule) {
            this.field = field;
            this.operator = operator;
            this.value = value;
            this.exprType = exprType;
            this.fieldType = fieldType;
            this.sequence = sequence;
            this.expRule = expRule;
        }
    }
    
    public class Filter {
        public String name;
        public Boolean isGlobal;
        public Expression expression;
        public String parentProfileId;
        
        public Filter() {
            
        }
        
        public Filter(String name, Boolean isGlobal, Expression expression) {
            this.name = name;
            this.isGlobal = isGlobal;
            this.expression = expression;
        }
    }
    
    public class Profile {
        public String profileId;
        public String profileName;
        public List<Action> actions;
        public List<Action> stdActions;
        public List<Filter> filters;
        public List<Mapping> mappings;
        public List<CustomActionURL> customUrls;
        public List<DataValidationRule> dataValidationRules;
        public List<DataValidationRulesWithObjectInfo> rulesWithObjectInfo; 
        public List<Field> ibPriorityFields;
        public List<Field> ibHiddenFields;
        public List<Field> locPriorityFields;
        public List<Field> locHiddenFields;
        public List<Field> accPriorityFields;
        public List<Field> accHiddenFields;
        public List<Field> slocPriorityFields;
        public List<Field> slocHiddenFields;
        public List<Field> productDisplayFields;
        public List<Field> productSearchFields;
        public List<Field> ibDisplayFields;
        public List<Field> ibSearchFields;
        public List<SearchObject> search;
        public String isTechnicalAttributesEnabled;
        public List<AttachmentConfig> attachment;
        public List<IBEditProces> ibEditProces;
        public List<LocationEditProces> locationEditProces;
        public ServiceFlowWizardDisplay serviceFlowWizardDisplay;
        public String isAutoSyncEnabled;

        public Profile() {
            
        }
        
        public Profile(String profileId, String profileName) {
            this.profileId = profileId;
            this.profileName = profileName;         
        }
    }
    
    public class Configuration {
        public List<Profile> profiles;
        public List<TemplateHeader> templates;
        public List<String> delTemplateIds;
        public TechnicalAttributesTemplate technicalAttributesTemplate;
        public List<String> taDeletedTemplateIds;
        public String isValideTAtemplate;
        public List<String> deletedTACriteriaIds;
        
        
        public Configuration(){
            
        }
        public Configuration(String isValideTAtemplate){
            this.isValideTAtemplate = isValideTAtemplate;
        }
        
    }
     public class TechnicalAttributesTemplate {
        public String  templateId;
        public String  templateTitle;
        public String  templateDescription;
        public String  templateAttributesType;
        public String  templateIsActive;
        public String  templateAttributesDetails;
        public List<TAapplicationCriteria> templateApplicationCriteria;
        public String  templatePicklistId;
        
        
        public TechnicalAttributesTemplate() {
            
        }
        
        public TechnicalAttributesTemplate(String  templateId, String templateTitle, String templateIsActive,String templateDescription,String templateShortDescription,String  templateAttributesType,String  templateAttributesDetails,String templatePicklistId) {
            this.templateId = templateId;
            this.templateTitle = templateTitle;
            this.templateIsActive = templateIsActive;
            this.templateDescription = templateDescription;
            this.templateAttributesType = templateAttributesType;
            this.templateAttributesDetails = templateAttributesDetails;
            this.templatePicklistId = templatePicklistId;

            //this.templateApplicationCriteria = templateApplicationCriteria;
        }
    }
    
    public class TAapplicationCriteria{
    
         public String  criteriaId;
         public String  productId;
         public String  productFamily;
         public String  productLine;
         public String  productCode;
         
         public TAapplicationCriteria() {
            
        }
        
        public TAapplicationCriteria(String  criteriaId, String  productId,String  productFamily,String  productLine,String  productCode) {
         this.criteriaId = criteriaId;
         this.productId = productId;
         this.productId = productFamily;
         this.productId = productLine;
         this.productId = productCode;
            
        }
    
    }
    public class IBTemplates {
        
    }
    
    /* Product template objects */  
    
    public class ProductConfiguration {
        String name;
        String type;
        
        public ProductConfiguration(String name, String type) {
            this.name = name;
            this.type = type;
        }
    }
    
    public class Product {
        public String product;
        public String productId;
        public String productIcon;
        public String productDefaultValues;
        public String oldProductValueMap;
        public String newProductValueMap;
        public List<ProductConfiguration> productConfiguration;
        
        public Product() {
            
        }       
    }
    
    public class TemplateDetails {
        public String templateName;
        public String templateId;
        public String ibText;
        public String locationText;
        public String subLocationText;
        
        public TemplateDetails() {
            
        }       
    }
    
    public class Template {
        public String text;
        public String type;
        public Product product;
        public TemplateDetails templateDetails;
        public List<Template> children;
        
        public Template() {
            
        }
        
        public Template(String text, String type) {
            this.text = text;
            this.type = type;
        }
        
    }
    
    public class TemplateHeader {
        public String sfdcId;
        public String templateName;
        public String templateId;
        public Template template;        
        public List<Mapping> mappings;
        public TemplateHeader() {
            
        }
        
        public TemplateHeader(String templateName, String templateId , Template template) {
            this.templateName = templateName;
            this.templateId = templateId;
            this.template = template;
        }
    }
    
    public class Mapping {
        public String name;
        public String targetObjectName;
        public String mappingType;
        public List<FieldMapping> mappingFields; 
    }
    
    public class FieldMapping {
        public String targetField;
        public String value;
    }
    
    public class CustomActionURL {
        public String name;
        public String targetURL;
        public String sourceObjectName;
        public List<URLParameters> urlParameters;
        
        public CustomActionURL(string name, string targetURL, string sourceObjectName, List<URLParameters> urlParameters){
            this.name = name;
            this.targetURL = targetURL;
            this.sourceObjectName = sourceObjectName;
            this.urlParameters = urlParameters;
        }
    }
    
    public class URLParameters {
        public String name;
        public String parameterType;
        public String value;
        
        public URLParameters(string name, string parameterType, string value){
            this.name = name;
            this.parameterType = parameterType;
            this.value = value;
        }
    }
    
    public class Field{
        public String name;
        public Integer priority;
        public boolean required;
    } 
    
    public class DataValidationRulesWithObjectInfo{
        public String objectName;
        public String objectLabel;
        public List<DataValidationRuleInfo> rules;
        
        public DataValidationRulesWithObjectInfo(String objectName, List<DataValidationRuleInfo> rules){
            this.objectName = objectName;
            
            String[] types = new String[]{objectName};
            Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
            for(Schema.DescribeSobjectResult res : results) {
                this.objectLabel = res.getLabel();
            }
            
            this.rules = rules;
        }
    }
    
    public class DataValidationRule{
        public DataValidationRuleInfo rule;
        public List<Expression> lstExpressions = new List<Expression>();
        
        public DataValidationRule(DataValidationRuleInfo rule, List<Expression> lstExpressions){
            this.rule = rule;
            this.lstExpressions = lstExpressions;
        }
    }
    
    public class DataValidationRuleInfo{
        public String ruleId;
        public String ruleName;
        public String description;
        public String messageType;
        public String objectName;
        public String advExpr;
        public String errorMessage;
        
        public DataValidationRuleINFO(String ruleId, String ruleName, String description, String messageType, String objectName, String advExpr, String errorMessage){
            this.ruleId = ruleId;
            this.ruleName = ruleName;
            this.description = description;
            this.messageType = messageType;
            this.objectName = objectName;
            this.advExpr = advExpr;
            this.errorMessage = errorMessage;
        }
    }

    public class SearchObject{
        public List<Search> searches;
        public String objectName;
    }
    
    public class Search{
        public String searchName;
        public String searchLabel;
        public String sfdcId;
        public List<SearchField> searchfields;
        public String advancedExpression;
    }

    public class SearchField{
        public String displayType;
        public String fieldName;
        public String objectName;
        public String fieldType;
        public String lookupFieldAPIName;
        public String fieldRelationshipName;
        public String relatedObjectName;
        public String sortOrder;
        public String sequence;
        public String objectName2;
        public String operand;
        public String operatorValue;
        public String isNameField;
        public String expressionType;
        public String fKeyNameField;
    }

    public class AttachmentConfig{
        public String isAttachmentsEnabled;
        public String fileTypes;
        public String maximumFileSize;
        
        //For Files
        public String sfdcFileTypes;
        public String sfdcFileTags;
        public String maxSfdcFileSize;

    }

    
    public class IBEditProces{
        public String sfdcId;
        public String processId;
        public String processName;
        public String objectName;
    }

    public class LocationEditProces{
        public String sfdcId;
        public String processId;
        public String processName;
        public String objectName;
    }

    public class ServiceFlowWizardDisplay {
       public Boolean isOpenTreeViewActionEnabledForInstallBase;
       public Boolean isOpenTreeViewActionEnabledForLocation;
       public Boolean isOpenTreeViewActionEnabledForWO;
    }

    public class TechnicalAttributePicklistDefinition {
        public String sfdcId;
        public String name;
        public String description;
        public PickListValues picklistValues;
        public Boolean isValidPicklistDefinition; 
    }
    public class PickListValues {
        public Boolean setDefaultValue;
        public List<String> values;
    }

}