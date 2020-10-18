/*****************************************************************************
 *                       Copyright (C) 2016 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The PM_Plan_Wrapper is a wrapper class for wrapping the data retrieved from the Service class which 
 * is used during the PM plan create or edit
 * 
 *
 * @author Anchal 
 * @version 
 * @since 2017
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Anchal               13 Feb 2017     Created.
 *****************************************************************************************************/
public with sharing class PREV_SetupPMPlan_Wrapper {

    public class ObjectInfo {
        public String Id;
        public String name;
        public ObjectInfo() {}
        
    }
    
    public class PM_Plan_Request {
        public String sourceId;
        public String mode;
        public String pmPlanId ;
        public String pmTemplateId; 
        public PM_Plan_Data pmPlanDataUpdates ;
        public PM_Plan_Request(){
           
        }
    }
    
    public class PM_Plan_Response {
        
        public Boolean success ;
        public Boolean warning ;
        public List<String> messageList ;  
        public PM_Plan_Data pmPlanRecord ;
        public PM_Plan_Response(){ 
            messageList = new List<String>();
        }
    }
    
    public class Covergae_Schedule_Request {
        public String coverageId;
        public String runScheduleCoverageId;
        public List<ConditionRules> conditionRuleList;
        public PM_Plan_Data pmPlanRecord ;
        public string advancedExpression;
        public string workOrderPurposeId;
        public String productId;
        public Covergae_Schedule_Request(){
           
        }
    }
    
    public class Covergae_Schedule_Response {
        public Boolean success ;
        public Boolean warning ;
        public List<String> messageList ;  
        public String coverageId;
        public String runScheduleCoverageId;
        public List<ConditionRules> conditionRuleList;
        public List<Schedule> scheduleList;
        public List<KeyAndListOfKeyValue> mapOfKeyAndListOfKeyValue;
        public Covergae_Schedule_Response(){ 
            messageList = new List<String>();
        }
    }
    
    public class Search_Request {
        public String searchText;
        public String objAPIName;
        public string whereClause;
        public search_Request(){
           
        }
    }
    
    public class Search_Response {
        public Boolean success ;
        public String searchText;
        public String objAPIName;
        public string product;
        public Map<String, SObject> mapSearchRecord; 
        public List<ObjectInfo> searchResponse ; 
        public List<String> messageList;
        public search_Response(){ 
            
        }
    }

    public class KeyValueForPicklist{
        public String label;
        public String value;
        public KeyValueForPicklist(){}
        public KeyValueForPicklist(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    public class KeyValue{
        public String key;
        public String value;
        public String dataType;
        public String attrType;
        public List<KeyValueForPicklist> lstValues;
        public KeyValue(){}
        public KeyValue(String key, String value) {
            this.key = key;
            this.value = value;
        }
        public KeyValue(String key, String value, String dataType) {
            this.key = key;
            this.value = value;
            this.dataType = dataType;
        }
        public KeyValue(String key, String value, String dataType, String attrType) {
            this.key = key;
            this.value = value;
            this.dataType = dataType;
            this.attrType = attrType;
        }
        public KeyValue(String key, String value, String dataType, String attrType, List<KeyValueForPicklist> lstValues) {
            this.key = key;
            this.value = value;
            this.dataType = dataType;
            this.attrType = attrType;
            this.lstValues = lstValues;
        }
    }

    public class KeyAndListOfKeyValue{
        public String key;
        public List<KeyValue> lstOfKeyValue;
        public KeyAndListOfKeyValue(){}
        public KeyAndListOfKeyValue(String key, List<KeyValue> lstOfKeyValue){
            this.key = key;
            this.lstOfKeyValue = lstOfKeyValue;
        }
    }
    
    public class PM_Plan_Template_Request{
        public String objectName;
        public List<String> lstOfValues;
        public String pmPlanTemplateId;
        public String productId;
        public PM_Template_Detail pmPlanTemplate;
        public List<ConditionRules> conditionRuleList;
        public PM_Plan_Template_Request(){}
    }
    
    public class PM_Plan_Template_Response{
        public Boolean success;
        public Boolean warning;
        public List<String> messageList;
        public String pmPlanTemplateId;
        public PM_Template_Detail pmPlanTemplate;
        public List<KeyValue> listKeyValue;
        public List<KeyAndListOfKeyValue> mapOfKeyAndListOfKeyValue;
        public List<ConditionRules> conditionRuleList;
        public List<Schedule> scheduleList;
        public PM_Plan_Template_Response(){}
    }
    
    //------Classes for parsing Technical Attribute JSON string----
    public class TechnicalAttributesFields{
        public String label;
        public String format;
        public String picklistSfId;
    }

    public class TechnicalAttributesSections{
        public List<TechnicalAttributesFields> technicalAttributes;
    }

    public class TechnicalAttributes{
        public List<TechnicalAttributesSections> fields;
    }
    
    public class TechnicalAttributesPicklistValues{
        public List<String> values;
    }
    //------Classes for parsing Technical Attribute JSON string----

    public class Coverage {
        public String pmCovergaeId;
        public String pmCoverageName; 
        public String installedProductName; 
        public String installedProductId;
        public String productId;
        public string advancedExpression;
        public List<ConditionRules> conditionRuleList;
        public List<schedule> scheduleList; 
        public Coverage() {}
    }
    
    public class Schedule {
        public string sequence;
        public String scheduleId;
        public String scheduleName; 
        public String status;
        public String statusLabel;
        public String selectedWOPurpose;
        public String internalExpression; 
        public String actualOpName; 
        public String advancedExpression; // Added for defect BAC - 2991 fix
        public String actualOpExpression; //Added for defect BAC- 3062 fix
        public List<ObjectInfo> woPurposeList; 
        public Schedule() {}
    }
    
    public class InternalExpression{
        public String order;
        public String attrName;
        public String attrLabel;
        public String operator;
        public String attrValue;
        public String datatype;
        public String attrType;
        public String adjType;
        public String adjValue;
        public String adjMin;
        public String adjMax;
        public String adjUnit;
        public String stopAt;
        //public String value;
        public InternalExpression() {}
    }
    
    public class ConditionRules{
        public string conditionRuleId; 
        public String sequence; 
        public String selectedField;
        public string fieldDataType;
        public String fieldAttType; 
        public String selectedOperator;
        public String frequency; 
        public String selectedFreqUnit;
        public String startAt;
        public String stopAt;
        public String threshold;
        public String selectedAdjustmentType;
        public String minAdjustment; 
        public String maxAdjustment;
        public String adjustmentVal;
        public String selectedAdjustedUnit;
        public String value;
        public String selectedFieldLabel;
        public ConditionRules(){}
    }
    
    public class PM_Template_Detail{
        public String templateName;
        public String templateId;
        public String scheduleType;
        public String coverageType;
        public String product;
        public String productName;
        public String installedProductFilter;
        public String activityDate;
        public String workOrderPurpose;
        public String advancedExpression;
        public String useCurrentFieldVal;
        public String conditionType;
        public List<ConditionRules> conditionRuleList;
        public List<KeyAndListOfKeyValue> mapOfKeyAndListOfKeyValue;
        public PM_Template_Detail(){}
    }

    public class PM_Plan_Data{
        public String pmPlanName; 
        public String pmPlanId; 
        public PM_Template_Detail pmTemplateDetail;
        public String serviceContractId;
        public List<ObjectInfo> serviceContractList; 
        public String pmPlanTemplateId;
        public List<ObjectInfo> pmTemplateList; 
        public String woPurposeId;
        public List<ObjectInfo> woPurposeList; 
        public String selectedCovergaeType;
        public List<KeyValue> coverageType; 
        public String selectedScheduleType;
        public List<KeyValue> scheduleType; 
        public String selectedActivityDate;
        public List<KeyValue> activityDateList;
        public String accountId;
        public List<ObjectInfo> accountList; 
        public String locationId;
        public List<ObjectInfo> locationList; 
        public String slaId;
        public List<ObjectInfo> slaList; 
        public String startDate;
        public String endDate;
        public String description;
        public String locationPMPlanMapping;
        public String accountPMPlanMapping;
        public String scPMPlanMapping;
        public String IBPMPlanMapping;
        public String pmTemplatePMPlanMapping;
        public String activatePMPlan;
        public SVMXC__PM_Plan__c pmPlanMappedValues;
        public List<KeyAndListOfKeyValue> mapOfKeyAndListOfKeyValue;
        public List<Coverage> coverageList;
        public String conditionType;
    }
}