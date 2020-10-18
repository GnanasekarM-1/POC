/**
 * This class used to hold inventory configuration values information.
 */
public with sharing class INVT_ConfigurationRecord {

    /*
     * Instance variable for actual quantity API name ( Setting SET001 ).
     */
    private String actualQuantityAPIName;
    
    /*
     * Instance variable for allow excess quantity flag ( Setting SET002 ).
     */
    private Boolean allowExcessQuantity = false;
    
    /*
     * Instance variable for allow partial closure flag ( Setting SET003 ).
     */
    private Boolean allowPartialClosure = false;
    
    /*
     * Instance variable for allow partial quantity flag ( Setting SET004 ).
     */
    private Boolean allowPartialQuantity = false;
    
    /*
     * Instance variable for child advanced option ( Setting SET005 ).
     */
    private String childAdvancedOption;
    
    /*
     * Instance variable for child object name ( Setting SET006 ).
     */
    private String childObjectName;
    
    /*
     * Instance variable for child object record type ( Setting SET007 ).
     */
    private String childObjectRecordType;
    
    /*
     * Instance variable for email id for negative stock alert ( Setting SET008 ).
     */
    private String emailForNegativeStockAlert;
    
    /*
     * Instance variable for enable barcode entry flag ( Setting SET009 ).
     */
    private Boolean enableBarCodeEntry = false;
    
    /*
     * Instance variable for enable serial selection flag ( Setting SET010 ).
     */
    private Boolean enableSerialSelection = false;
    
    /*
     * Instance variable for enforce unique serial selection ( Setting SET011 ).
     */
    private String enforceUniquenessInSerialSelection;
    
    /*
     * Instance variable for email sent to location owner flag ( Setting SET012 ).
     */
    private Boolean isEmailSentToLocationOwner = false;
    
    /*
     * Instance variable for multiline transaction flag ( Setting SET013 ).
     */
    private Boolean isMultilineTransaction = false;
    
    /*
     * Instance variable for source location from header ( Setting SET014 ).
     */
    private Boolean isSourceLocationFromHeader = false;
    
    /*
     * Instance variable for source location stockable flag ( Setting SET015 ).
     */
    private Boolean isSourceLocationStockable = false;
    
    /*
     * Instance variable for target location from header flag ( Setting SET016 ).
     */
    private Boolean isTargetLocationFromHeader = false;
    
    /*
     * Instance variable for target location stockable flag ( Setting SET017 ).
     */
    private Boolean isTargetLocationStockable = false;
    
    /*
     * Instance variable for actual quantity editable flag ( Setting SET018 ).
     */
    private Boolean isActualQuantityEditable = false;
    
    /*
     * Instance variable for lookup field to parent ( Setting SET019 ).
     */
    private String lookupFieldToParent;
    
    /*
     * Instance variable for maintain serial history flag ( Setting SET020 ).
     */
    private Boolean doMaintainSerialHistory = false;
    
    /*
     * Instance variable for maintain stock history flag ( Setting SET021 ).
     */
    private Boolean doMaintainStockHistory = false;
    
    /*
     * Instance variable for number of location ( Setting SET022 ).
     */
    private String numberOfLocation;
    
    /*
     * Instance variable for original quantity API name ( Setting SET023 ).
     */
    private String originalQuantityAPIName;
    
    /*
     * Instance variable for parent advanced option ( Setting SET024 ).
     */
    private String parentAdvancedOption;
    
    /*
     * Instance variable for parent object name ( Setting SET025 ).
     */
    private String parentObjectName;
    
    /*
     * Instance variable for product field API name ( Setting SET026 ).
     */
    private String productFieldAPIName;
    
    /*
     * Instance variable for related product field ( Setting SET027 ).
     */
    private String relatedProductField;
    
    /*
     * Instance variable for relationship name to parent ( Setting SET028 ).
     */
    private String relationshipNameToParent;
    
    /*
     * Instance variable for relationship name to product ( Setting SET029 ).
     */
    private String relationshipNameToProduct;
    
    /*
     * Instance variable for relationship to source location ( Setting SET030 ).
     */
    private String relationshipToSourceLocation;
    
    /*
     * Instance variable for relationship to target location ( Setting SET031 ).
     */
    private String relationshipToTargetLocation;
    
    /*
     * Instance variable for source action ( Setting SET032 ).
     */
    private String sourceAction;
    
    /*
     * Instance variable for source location API name ( Setting SET033 ).
     */
    private String sourceLocationAPIName;
    
    /*
     * Instance variable for source status ( Setting SET034 ).
     */
    private String sourceStatus;
    
    /*
     * Instance variable for stock history header API name ( Setting SET035 ).
     */
    private String stockHistoryHeaderAPIName;
    
    /*
     * Instance variable for stock history line API name ( Setting SET036 ).
     */
    private String stockHistoryLineAPIName;
    
    /*
     * Instance variable for target action ( Setting SET037 ).
     */
    private String targetAction;
    
    /*
     * Instance variable for target location API name ( Setting SET038 ).
     */
    private String targetLocationAPIName;
    
    /*
     * Instance variable for target status ( Setting SET039 ).
     */
    private String targetStatus;

    /*
     * Instance variable for serial number field API name where serial numbers are captured ( Setting SET040 ).
     */
    private String serialNumberFieldAPIName;
    
    /*
     * Instance variable for stock result update field API name. ( Setting SET041 ).
     */
    private String stockResultUpdateFieldAPIName;

    /*
     * Instance variable for parent object criteria
     */
    private String parentObjectCriteria;
    
    /*
     * Instance variable for child object criteria
     */
    private String childObjectCriteria;
    
    /*
     * Instance variable for module
     */
    private String module;
    
    /*
     * Instance variable for submodule
     */
    private String submodule;
    
    /*
     * Instance variable for module id
     */
    private String moduleId;
    
    /*
     * Instance variable for submodule id
     */
    private String submoduleId;
    
    /*
     * Instance variable for process id
     */
    private String processID;
    
    /*
     * Instance variable for SVMX process name
     */
    private String name;
    
    /*
     * Instance variable for SVMX process description
     */
    private String description;
    
    /*
     * Instance variable for standard field flag.
     */  
    private Boolean isStandard;
    
    /*
     * Instance variable for parent error message.
     */
    private String parentErrorMsg;
    
    /*
     * Instance variable for child error message.
     */
    private String childErrorMsg;
    
    /*
     * Instance variable to hold servicemax processes object reference.
     */
    private SVMXC__ServiceMax_Processes__c svmxProcess; 
    
    /*
     * Instance variable to hold setting name vs config data map.
     */
    private Map<String, SVMXC__ServiceMax_Config_Data__c> mapSetting;
    
    /*
     * Class constructor to setup inventory data record.
     */
    public INVT_ConfigurationRecord( SVMXC__ServiceMax_Processes__c svmxProcess, 
        Map<String, SVMXC__ServiceMax_Config_Data__c> mapSetting ) {
        
        this.svmxProcess = svmxProcess;
        this.mapSetting = mapSetting;       
        
        init();
    }
    
    public String getActualQuantityAPIName() {
        return actualQuantityAPIName;
    }
    
    public Boolean isAllowExcessQuantity() {
        return allowExcessQuantity;
    }
    
    public Boolean isAllowPartialClosure() {
        return allowPartialClosure;
    }
    
    public Boolean isAllowPartialQuantity() {
        return allowPartialQuantity;
    }
    
    public String getChildAdvancedOption() {
        return childAdvancedOption; 
    }
    
    public String getChildObjectName() {
        return childObjectName;
    }
    
    public String getChildObjectRecordType() {
        return childObjectRecordType;
    }
    
    public String getEmailForNegativeStockAlert() {
        return emailForNegativeStockAlert;
    }
    
    public Boolean isEnableBarCodeEntry() {
        return enableBarCodeEntry;
    }
        
    public Boolean isEnableSerialSelection() {
        return enableSerialSelection;
    }
    
    public String getEnforceUniquenessInSerialSelection() {
        return enforceUniquenessInSerialSelection;
    }
    
    public Boolean isEmailSentToLocationOwner() {
        return isEmailSentToLocationOwner;
    }
    
    public Boolean isMultilineTransaction() {
        return isMultilineTransaction;
    }
    
    public Boolean isSourceLocationFromHeader() {
        return isSourceLocationFromHeader;
    }
    
    public Boolean isSourceLocationStockable() {
        return isSourceLocationStockable;
    }
    
    public Boolean isTargetLocationFromHeader() {
        return isTargetLocationFromHeader;
    }
    
    public Boolean isTargetLocationStockable() {
        return isTargetLocationStockable;
    }
    
    public Boolean isActualQuantityEditable() {
        return isActualQuantityEditable;
    }
    
    public String getLookupFieldToParent() {
        return lookupFieldToParent;
    }
    
    public Boolean isMaintainSerialHistory() {
        return doMaintainSerialHistory;
    }
    
    public Boolean isMaintainStockHistory() {
        return doMaintainStockHistory;
    }
    
    public String getNumberOfLocation() {
        return numberOfLocation;
    }
    
    public String getOriginalQuantityAPIName() {
        return originalQuantityAPIName;
    }
    
    public String getParentAdvancedOption() {
        return parentAdvancedOption;
    }
    
    public String getParentObjectName() {
        return parentObjectName;
    }
    
    public String getProductFieldAPIName() {
        return productFieldAPIName;
    }
    
    public String getRelatedProductField() {
        return relatedProductField;
    }
    
    public String getRelationshipNameToParent() {
        return relationshipNameToParent;
    }
    
    public String getRelationshipNameToProduct() {
        return relationshipNameToProduct;
    }
    
    public String getRelationshipToSourceLocation() {
        return relationshipToSourceLocation;
    }
    
    public String getRelationshipToTargetLocation() {
        return relationshipToTargetLocation;
    }
    
    public String getSourceAction() {
        return sourceAction;
    }
    
    public String getSourceLocationAPIName() {
        return sourceLocationAPIName;
    }
    
    public String getSourceStatus() {
        return sourceStatus;
    }
    
    public String getStockHistoryHeaderAPIName() {
        return stockHistoryHeaderAPIName;
    }
    
    public String getStockHistoryLineAPIName() {
        return stockHistoryLineAPIName;
    }
    
    public String getTargetAction() {
        return targetAction;
    }
    
    public String getTargetLocationAPIName() {
        return targetLocationAPIName;
    }
    
    public String getTargetStatus() {
        return targetStatus;
    }
    
    public String getSerialNumberFieldAPIName() {
        return serialNumberFieldAPIName;
    }
    
    public String getStockResultUpdateFieldAPIName() {
        return stockResultUpdateFieldAPIName;
    }
    
    public String getParentObjectCriteria() {
        return parentObjectCriteria;
    }
    
    public String getChildObjectCriteria() {
        return childObjectCriteria;
    }
    
    /*
     * Initialize instance variables from servicemax config data.
     */ 
    private void init() {
        
        if( svmxProcess == null || mapSetting == null || mapSetting.isEmpty() ) {
            return; 
        }
        
        /*
         * Initialize instance variables related to svmx process data.
         */
        initSVMXProcessData();
        
        Set<String> settingKeySet = mapSetting.keySet();
        
        for( String key : settingKeySet ) {
            
            SVMXC__ServiceMax_Config_Data__c serviceMaxConfigData = mapSetting.get( key );
            
            if( serviceMaxConfigData == null ) { continue;  }
            
            if( key == 'SET001' ) {
                actualQuantityAPIName = serviceMaxConfigData.SVMXC__Internal_Value__c;
            } else if( key == 'SET002' ) {
                allowExcessQuantity = Boolean.valueOf( serviceMaxConfigData.SVMXC__Internal_Value__c );
            } else if( key == 'SET003' ) {
                allowPartialClosure = Boolean.valueOf( serviceMaxConfigData.SVMXC__Internal_Value__c );
            } else if( key == 'SET004' ) {
                allowPartialQuantity = Boolean.valueOf( serviceMaxConfigData.SVMXC__Internal_Value__c );
            } else if( key == 'SET005' ) {
                childAdvancedOption = serviceMaxConfigData.SVMXC__Internal_Value__c;
            } else if( key == 'SET006' ) {
                childObjectName =  serviceMaxConfigData.SVMXC__Internal_Value__c;
            } else if( key == 'SET007' ) {
                childObjectRecordType = serviceMaxConfigData.SVMXC__Internal_Value__c;
            } else if( key == 'SET008' ) {
                emailForNegativeStockAlert = serviceMaxConfigData.SVMXC__Internal_Value__c;
            } else if( key == 'SET009' ) {
                enableBarCodeEntry = Boolean.valueOf( serviceMaxConfigData.SVMXC__Internal_Value__c );
            } else if( key == 'SET010' ) {
                enableSerialSelection = Boolean.valueOf( serviceMaxConfigData.SVMXC__Internal_Value__c );
            } else if( key == 'SET011' ) {
                enforceUniquenessInSerialSelection = serviceMaxConfigData.SVMXC__Internal_Value__c;
            } else if( key == 'SET012' ) {
                isEmailSentToLocationOwner = Boolean.valueOf( serviceMaxConfigData.SVMXC__Internal_Value__c );
            } else if( key == 'SET013' ) {
                isMultilineTransaction = Boolean.valueOf( serviceMaxConfigData.SVMXC__Internal_Value__c );
            } else if( key == 'SET014' ) {
                isSourceLocationFromHeader = Boolean.valueOf( serviceMaxConfigData.SVMXC__Internal_Value__c );
            } else if( key == 'SET015' ) {
                isSourceLocationStockable = Boolean.valueOf( serviceMaxConfigData.SVMXC__Internal_Value__c );
            } else if( key == 'SET016' ) {
                isTargetLocationFromHeader = Boolean.valueOf( serviceMaxConfigData.SVMXC__Internal_Value__c );
            } else if( key == 'SET017' ) {
                isTargetLocationStockable = Boolean.valueOf( serviceMaxConfigData.SVMXC__Internal_Value__c );
            } else if( key == 'SET018' ) {
                isActualQuantityEditable = Boolean.valueOf( serviceMaxConfigData.SVMXC__Internal_Value__c );
            } else if( key == 'SET019' ) {
                lookupFieldToParent = serviceMaxConfigData.SVMXC__Internal_Value__c;
            } else if( key == 'SET020' ) {
                doMaintainSerialHistory = Boolean.valueOf( serviceMaxConfigData.SVMXC__Internal_Value__c );
            } else if( key == 'SET021' ) {
                doMaintainStockHistory = Boolean.valueOf( serviceMaxConfigData.SVMXC__Internal_Value__c );
            } else if( key == 'SET022' ) {
                numberOfLocation = serviceMaxConfigData.SVMXC__Internal_Value__c;
            } else if( key == 'SET023' ) {
                originalQuantityAPIName = serviceMaxConfigData.SVMXC__Internal_Value__c;
            } else if( key == 'SET024' ) {
                parentAdvancedOption = serviceMaxConfigData.SVMXC__Internal_Value__c;
            } else if( key == 'SET025' ) {
                parentObjectName = serviceMaxConfigData.SVMXC__Internal_Value__c;
            } else if( key == 'SET026' ) {
                productFieldAPIName = serviceMaxConfigData.SVMXC__Internal_Value__c;
            } else if( key == 'SET027' ) {
                relatedProductField = serviceMaxConfigData.SVMXC__Internal_Value__c;
            } else if( key == 'SET028' ) {
                relationshipNameToParent = serviceMaxConfigData.SVMXC__Internal_Value__c;
            } else if( key == 'SET029' ) {
                relationshipNameToProduct = serviceMaxConfigData.SVMXC__Internal_Value__c;
            } else if( key == 'SET030' ) {
                relationshipToSourceLocation = serviceMaxConfigData.SVMXC__Internal_Value__c;
            } else if( key == 'SET031' ) {
                relationshipToTargetLocation = serviceMaxConfigData.SVMXC__Internal_Value__c;
            } else if( key == 'SET032' ) {
                sourceAction = serviceMaxConfigData.SVMXC__Internal_Value__c;
            } else if( key == 'SET033' ) {
                sourceLocationAPIName = serviceMaxConfigData.SVMXC__Internal_Value__c;
            } else if( key == 'SET034' ) {
                sourceStatus = serviceMaxConfigData.SVMXC__Internal_Value__c;
            } else if( key == 'SET035' ) {
                stockHistoryHeaderAPIName = serviceMaxConfigData.SVMXC__Internal_Value__c;
            } else if( key == 'SET036' ) {
                stockHistoryLineAPIName = serviceMaxConfigData.SVMXC__Internal_Value__c;
            } else if( key == 'SET037' ) {
                targetAction = serviceMaxConfigData.SVMXC__Internal_Value__c;
            } else if( key == 'SET038' ) {
                targetLocationAPIName = serviceMaxConfigData.SVMXC__Internal_Value__c;
            } else if( key == 'SET039' ) {
                targetStatus = serviceMaxConfigData.SVMXC__Internal_Value__c;
            } else if( key == 'SET040' ) {
                serialNumberFieldAPIName = serviceMaxConfigData.SVMXC__Internal_Value__c;
            } else if( key == 'SET041' ) {
                stockResultUpdateFieldAPIName = serviceMaxConfigData.SVMXC__Internal_Value__c;
            }
        }
    }       
    
    /**
     * Private method to initialize svmx process data informations.
     */
    private void initSVMXProcessData() {
        
        if( svmxProcess != null ) {
            
            parentObjectCriteria = svmxProcess.SVMXC__Parent_Object_Criteria__c;
            childObjectCriteria = svmxProcess.SVMXC__Child_Object_Criteria__c;
            module = svmxProcess.SVMXC__Module__c;
            submodule = svmxProcess.SVMXC__Submodule__c;
            moduleId = svmxProcess.SVMXC__Module__r.SVMXC__ModuleId__c;
            submoduleId = svmxProcess.SVMXC__Submodule__r.SVMXC__SubmoduleId__c;
            processID = svmxProcess.SVMXC__ProcessID__c;
            name = svmxProcess.SVMXC__Name__c;
            description = svmxProcess.SVMXC__Description__c;
            isStandard = Boolean.valueOf( svmxProcess.SVMXC__IsStandard__c );
            parentErrorMsg = svmxProcess.SVMXC__Parent_Error_Msg__c;
            childErrorMsg  = svmxProcess.SVMXC__Child_Error_Msg__c;
        }
    }
}