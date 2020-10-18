/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief Field Change Order request & response wrapper structures.
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
public with sharing class CORD_WrapperDef {
    
    public class FCO_Request {
        
        public FieldChangeOrderInfo fieldChangeOrderInfo;
        public FCOConfigurationInfo configurationInfo;
        public String searchKeyword;
        public String objectAPIName; //#addedByArpit
        public List<String> pickListFieldList; //#addedByArpit
        public String fcoSfId; //#addedByArpit
        public String fcoConfigId; //Added by Nidhi - FCO Configuration Page BAC-5670
        public UserPreference userPreference; //#addedByArpit
        public List<FCOFieldInfo> selectedColumns; //#addedByArpit
        public FCOSearchExpressions searchExpressions; //#addedByArpit
        public String productId; //#addedByArpit for searchInstalledProduct
        public List<sObject> newRecordList; //#addedByArpit for updation of fco lines exclusion/inclusion property and new fco lines
        public List<sObject> oldRecordList; //#addedByArpit for updation of fco lines exclusion/inclusion property and new fco lines
        public List<String> recordIdList; //#addedByArpit as an input to find technical attributes for the product
        public String requestType; //#addedByArpit to identify product search is for batch/lot or installed product. Expecting 'batchLot' for batch/lot and 'installedProduct' for Installed Product
        public FCO_Request(){}
    }
    

    public class FCO_Response {
        
        public Boolean success;
        public String message;
        public Object data;

        public FCO_Response() {
            this.success = true; //#addedByArpit, By adding this we don't need to set its value as true explicitly
                                 // in success scenerio, only in catch block/ error scenerio set it as false 
        }
    }

    public class RequiredParts{
        public String productId;
        public String name;
        public String family;
        public String line; 
        public Boolean isActive;   
        public Decimal quantity; // #addedByArpit
        public String sfId; // #addedByArpit
    }

    public class SearchedProduct{
        public String icon;
        public String label;
        public String meta;
        public String value; 
        public SearchedProduct(){
            this.icon = 'standard:product';
        }
    }

    
      public class PickListValues{ //#addedByArpit
        public List<KeyValuePair> statusPicklist;
        public List<KeyValuePair> priorityPicklist;
        public List<KeyValuePair> orderTypePicklist;
        public List<KeyValuePair> deliveryMethodPicklist;
        public List<KeyValuePair> fcoConfigurationList;
    }

    public class dataTypeOperatorValues{
        public List<String> StringList;
        public List<String> dateList;
        public List<String> referenceList;
        public List<String> booleanList;
        public List<String> pickList;
        public List<String> dateTimeList;
        public List<String> mulitPicklist;
        public List<String> numberList;
        public List<String> emailList;
        public List<String> currencyList;
        public List<String> phoneList;

    }

    
    public class keyValuePair { //#addedByArpit
        public String key;
        public String value;
        
        public keyValuePair(String Key, String Value){
            this.key = Key;
            this.value = Value;
        }
        public keyValuePair(){
           
        }
    }

    public class FieldChangeOrderInfo {
        public String fcoSfId;
        public String fcoName;
        public String description;
        public String priority;
        public String fcoType; 
        public String status;
        public Date startDate;
        public Date dueDate;
        public Date decisionDate; //#addedByArpit
        public String deliveryMethod; //#addedByArpit
        public String fcoConfiguration; //#addedByArpit
        public Boolean searchTopLevelIBOnly; //#addedByArpit
        public String criteriaAdvancedExpression; //added to store operator value between between IB and Technical Attribute section
        public List<RequiredParts> requiredPartsList; //#addedByArpit
        public Boolean notifyFCOOwner; //#addedByArpit
        public List<String> selectedFieldList; //#addedByArpit
        public FCOSearchExpressions searchExpressions; //#addedByArpit
        public String tabToRender; // 'Details_Tab', 'SearchResults_Tab', 'WorkOrder_Tab'
        public String lastModifiedDate; //#addedForLMDLogic
        public Boolean isFcoHeaderHasCustomField; //#addedForCustomField Link visibility
    }
    
    //Added by Nidhi - FCO Configuration Page BAC-5670
    public class FCOConfigurationInfo{
        public String fcoConfigId;
        public String fcoConfigName;
        public String fcoConfigDescription;
        public Boolean fcoConfigStatus;
        public String process1_Id;
        public String process2_Id;
        public String email;        
        public Date lastModifiedDate;
        public List<String> profileIdList = new List<String>();
        public List<String> assignmentToBeDeleted = new List<String>();
        public List<AssignmentData> assignmentData = new List<assignmentData>();
    }
    
    public class ProcessData{
        public List<keyValuePair> process1Data = new List<keyValuePair>();
        public List<keyValuePair> process2Data = new List<keyValuePair>();
    }

    //Added by Arpit 
    public class UserPreference{
        public String userPrefId;
        public String objectName; //FcoLandingPage, FcoSearchResultPage
        public List<FCOFieldInfo> availableColumns;
        public List<FCOFieldInfo> selectedColumns;
        public Map<String, List<KeyValuePair>> fieldTypeWithOperators;
    }

    //Added by Arpit 
    public class TechBatchProductInfo{
        public Map<String, List<CORD_WrapperDef.FCOFieldInfo>> productFieldInfoMap;
        public Map<String, List<KeyValuePair>> fieldTypeWithOperators;
    }

    //Added by Arpit 
    public class FCOFieldInfoWrapper{
        public Map<String, List<FCOFieldInfo>> fcoFieldInfoListMap;
    }

    //Added by Arpit 
    public class FCOFieldInfo{
        public String fieldName;
        public String fieldLabel;
        public String fieldType;
        public String displayName; 
        public Map<String, List<KeyValuePair>> picklistMap;
    }

    //Added by Arpit 
    public class FCOSearchExpressions{
        public FCOSearchExpression instProdExpression;
        public FCOSearchExpression batchLotExpression;
        public FCOSearchExpression techAttribExpression;
    }

    //Added by Arpit 
    public class FCOSearchExpression{
        public List<ExpressionRows> expressionRows;
        public List<String> operatorForRows;
        public Integer sequence;
        public String sfId;
    }

    //Added by Arpit 
    public class ExpressionRows{
        public List<Expression> expressions;
        public List<String> operatorForColumns; 
        public String selectedProductId;
        public SearchedProduct selectedProductInfo;
    }

    //Added by Arpit 
    public class Expression{
        public String fieldName;
        public String fieldType;
        public String operator;
        public String value;
        public String displayName;
    }
    
    public class AssignmentData{
        public String assignmentId;
        public String profileId;
        public String fcoConfigId;
        public String profileName;
        public String description;
    }

    //Added by Arpit 
    public class SearchResultInfo{
        public String status;
        public Integer fcoLineCount;
        public Integer maxAllowedFcoLines;
        public UserPreference userPreferredColumns;
        //public List<sObject> fcoPreviewLines;
        public List<PreviewSearchResultWrapper> fcoPreviewLines;
        public List<SVMXC__SM_Change_Order_Line__c> fcoLines;
    }

    //Added by Arpit 
    public class WorkOrderInfo{
        public String status;
        public Integer workOrderCount;
        public UserPreference userPreferredColumns;
        public List<SVMXC__Service_Order__c> workOrderList;
    }

   //Added by Arpit for preview Lines
   public class PreviewSearchResultWrapper{
        public String item; // ib name #lacy
        public String serialNumber;
        public String batchLotNumber;
        public String location;
    }
}