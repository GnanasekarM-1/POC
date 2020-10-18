/*****************************************************************************
 *                       Copyright (C) 2017 ServiceMax From GE Digital, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/** 
 * The PREV_SetupPMPlanTemplateImpl is implementation class for PREV_SetupPMPlanTemplate class, which 
 * handles the all the implementation for all the remote calls for various Services implemented.
 * 
 *
 * @author Manish
 * @version
 * @since 2017
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Manish               17 Feb 2017       Created.
 *****************************************************************************************************/
public with sharing class PREV_SetupPMPlanTemplateImpl {
    public PREV_SetupPMPlanTemplateImpl(){}

    //This method returns the Expression list available in the org for the passed object
    //Request needs an object name
    //Response will be PM_Plan_Template_Response with list of filterList(Sid, ExprName)
    public SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response PREV_GetFilterList(SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request request){
        System.debug(LoggingLevel.WARN, 'Request in PREV_GetFilterList method : ' + request);

        String objectApiName = request.objectName;
        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response objResponse = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response();
        objResponse.listKeyValue = new List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue>();
        objResponse.messageList = new List<String>();
        objResponse.success = false;

        try{
            if(objectApiName != null && objectApiName.length() > 0){
                List<SVMXC__ServiceMax_Processes__c> lstExpression = [Select Id, SVMXC__Name__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Source_Object_Name__c =: objectApiName AND SVMXC__Record_Type_Name__c = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' Order By SVMXC__Name__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

                for(SVMXC__ServiceMax_Processes__c obj: lstExpression){
                    SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue objKeyValue= new SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue();
                    objKeyValue.value = obj.Id;
                    objKeyValue.key = obj.SVMXC__Name__c;
                    objResponse.listKeyValue.add(objKeyValue);
                }
                objResponse.success = true;
            }
        }
        catch(Exception ex){
            objResponse.success = false;
            objResponse.messageList.add(ex.getMessage());
            System.debug(LoggingLevel.WARN, 'Exception in PREV_GetFilterList method: ' + ex.getMessage());
            System.debug(LoggingLevel.WARN, 'StackTrace in PREV_GetFilterList method: ' + ex.getStackTraceString());
        }
        System.debug(LoggingLevel.WARN, 'Response of PREV_GetFilterList method: ' + objResponse);
        return objResponse;
    }

    //This method returns the Task Template list available in the org of Preventive Maintenance
    //Request needs nothing
    //Response will be PM_Plan_Template_Response with list of KeyValue(Sid, TemplateName)
    public SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response PREV_GetTaskTemplate(SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request request){
        System.debug(LoggingLevel.WARN, 'Request in PREV_GetTaskTemplate method : ' + request);

        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response objResponse = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response();
        objResponse.listKeyValue = new List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue>();
        objResponse.messageList = new List<String>();
        objResponse.success = false;

        try{
            List<SVMXC__Task_Template__c> lstTaskTemplate = [Select Id, SVMXC__Template_Name__c FROM SVMXC__Task_Template__c WHERE SVMXC__Template_Type__c = 'Preventive Maintenance' AND RecordType.Name = 'Templates' Order By SVMXC__Template_Name__c];

            for(SVMXC__Task_Template__c obj: lstTaskTemplate){
                SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue objKeyValue= new SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue();
                objKeyValue.value = obj.Id;
                objKeyValue.key = obj.SVMXC__Template_Name__c;
                objResponse.listKeyValue.add(objKeyValue);
            }
            objResponse.success = true;
        }
        catch(Exception ex){
            objResponse.success = false;
            objResponse.messageList.add(ex.getMessage());
            System.debug(LoggingLevel.WARN, 'Exception in PREV_GetTaskTemplate method: ' + ex.getMessage());
            System.debug(LoggingLevel.WARN, 'StackTrace in PREV_GetTaskTemplate method: ' + ex.getStackTraceString());
        }
        System.debug(LoggingLevel.WARN, 'Response of PREV_GetTaskTemplate method: ' + objResponse);
        return objResponse;
    }

    //This method returns the list of fields of type Date and Datetime on Work Order object
    //Request needs nothing
    //Response will be PM_Plan_Template_Response with list of filterList(fieldApiName, fieldName)
    public SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response PREV_GetActivityDateList(SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request request){
        System.debug(LoggingLevel.WARN, 'Request in PREV_GetActivityDateList method : ' + request);

        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response objResponse = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response();
        objResponse.listKeyValue = new List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue>();
        objResponse.messageList = new List<String>();
        objResponse.success = false;

        try{
            List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue> resultList = new List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue>();
            PREV_PMPlanUtils objPMPlanUtils = new PREV_PMPlanUtils();
            resultList = objPMPlanUtils.getActivityDateFieldList();

            if(resultList.size() > 0){
                objResponse.success = true;
                objResponse.listKeyValue = resultList;
            }
        }
        catch(Exception ex){
            objResponse.success = false;
            objResponse.messageList.add(ex.getMessage());
            System.debug(LoggingLevel.WARN, 'Exception in PREV_GetActivityDateList method: ' + ex.getMessage());
            System.debug(LoggingLevel.WARN, 'StackTrace in PREV_GetActivityDateList method: ' + ex.getStackTraceString());
        }
        System.debug(LoggingLevel.WARN, 'Response of PREV_GetActivityDateList method: ' + objResponse);
        return objResponse;
    }

    //This method returns the list of picklist values for the passed fields on PM Plan Template object
    //Request needs fields name
    //Response will be PM_Plan_Template_Response with list of mapOfKeyAndListOfKeyValue(fieldApiName, <picklistValue, picklistLabel>)
    public SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response PREV_GetPicklistValues(SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request request){
        System.debug(LoggingLevel.WARN, 'Request in PREV_GetPicklistValues method : ' + request);

        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response objResponse = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response();
        objResponse.mapOfKeyAndListOfKeyValue = new List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyAndListOfKeyValue>();
        objResponse.messageList = new List<String>();
        objResponse.success = false;

        //Get the Keyprefix for the PM plan template Object
        String KeyPrefix = Schema.SObjectType.SVMXC__PM_Plan_Template__c.getKeyprefix();
        objResponse.listKeyValue = new List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue>();
        objResponse.listKeyValue.add(new SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue('KEYPREFIX',KeyPrefix));
        
        List<String> lstOfField = request.lstOfValues;
        try{
            if(lstOfField != null && lstOfField.size() > 0){
                List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyAndListOfKeyValue> lstOfKeyAndListOfKeyValue = new List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyAndListOfKeyValue>();
                Map<String, Schema.SObjectField> pmPlanTemplateFieldMap = Schema.SObjectType.SVMXC__PM_Plan_Template__c.fields.getMap();
                
                for(String fieldName : lstOfField){
                    SVMXC.PREV_SetupPMPlan_Wrapper.KeyAndListOfKeyValue objKeyAndListOfKeyValue = new SVMXC.PREV_SetupPMPlan_Wrapper.KeyAndListOfKeyValue();
                    objKeyAndListOfKeyValue.key = fieldName;
                    
                    Schema.DescribeFieldResult fieldDescribe = pmPlanTemplateFieldMap.get(fieldName).getDescribe();
                    if(fieldDescribe.getType() == Schema.Displaytype.Picklist){
                        List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();

                        List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue> lstOfKeyValue = new List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue>();
                        for(Schema.PicklistEntry objPicklistEntry : picklistValues){
                            if(objPicklistEntry.isActive()){
                                SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue objKeyValue = new SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue();
                                objKeyValue.key = objPicklistEntry.getValue();
                                objKeyValue.value = objPicklistEntry.getLabel();
                                lstOfKeyValue.add(objKeyValue);
                            }
                        }
                        objKeyAndListOfKeyValue.lstOfKeyValue = lstOfKeyValue;
                        lstOfKeyAndListOfKeyValue.add(objKeyAndListOfKeyValue);
                    }
                }
                objResponse.mapOfKeyAndListOfKeyValue = lstOfKeyAndListOfKeyValue;
            }
            objResponse.success = true;
        }
        catch(Exception ex){
            objResponse.success = false;
            objResponse.messageList.add(ex.getMessage());
            System.debug(LoggingLevel.WARN, 'Exception in PREV_GetPicklistValues method: ' + ex.getMessage());
            System.debug(LoggingLevel.WARN, 'StackTrace in PREV_GetPicklistValues method: ' + ex.getStackTraceString());
        }
        System.debug(LoggingLevel.WARN, 'Response of PREV_GetPicklistValues method: ' + objResponse);
        return objResponse;
    }

    //This method Saves the PM plan Template and PM Applicable Product object records
    //Request will have PM Plan Template details.
    //Response will be success or failure status, applicable message and pmPlanTemplateId
    public SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response PREV_SaveTemplateData(SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request request){
        System.debug(LoggingLevel.WARN, 'Request in PREV_SaveTemplateData method : ' + request);

        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response objResponse = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response();
        objResponse.messageList = new List<String>();
        objResponse.success = false;
        Savepoint objSavepoint;

        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Template_Detail objTemplateDetail = request.pmPlanTemplate;
        String pmPlanTemplateId = request.pmPlanTemplateId;
        objResponse.pmPlanTemplateId = pmPlanTemplateId;
        try{
            //Creating savePoint
            objSavepoint = Database.setSavepoint();

            //validate selected product
            Boolean isProductIdValid = (objTemplateDetail.product InstanceOf ID) ? true : false ;
            if(!isProductIdValid){
                objResponse.success = false;
                objResponse.messageList.add(System.Label.PREV004_TAG058);
                System.debug(LoggingLevel.WARN, 'Response of PREV_SaveTemplateData method(isProductIdValid): ' + objResponse);
                return objResponse;
            }

            //Validate Advance Expression
            Integer countOfRules = 0;
            String strAdvExpr = objTemplateDetail.advancedExpression;
            if(request.conditionRuleList != null){
                countOfRules = request.conditionRuleList.size();
            }
            if(strAdvExpr != null && strAdvExpr != '' && strAdvExpr.length() > 0){
                PREV_PMPlanUtils objPMPlanUtils = new PREV_PMPlanUtils();
                Boolean isAdvExprValid = objPMPlanUtils.validateAdvExpression(strAdvExpr, countOfRules);
                if(!isAdvExprValid){
                    objResponse.success = false;
                    objResponse.messageList.add(System.Label.PREV004_TAG052);
                    System.debug(LoggingLevel.WARN, 'Invalid Advanced Expression');
                    return objResponse;
                }
            }
            else if(strAdvExpr == null || strAdvExpr == ''){
                String strCriteria = '';
                if(countOfRules > 1){
                    for(Integer i = 0; i<countOfRules; i++){
                        if(strCriteria.length() > 0)
                            strCriteria += ' AND ';
                        strCriteria += i+1;
                    }
                }
                System.debug(LoggingLevel.WARN, 'strCriteria : ' + strCriteria);
                strAdvExpr = strCriteria;
            }

            SVMXC__PM_Plan_Template__c objPMPlanTemplate = new SVMXC__PM_Plan_Template__c();
            SVMXC__PM_Applicable_Product__c objApplicableProduct = new SVMXC__PM_Applicable_Product__c();

            if(pmPlanTemplateId != null && pmPlanTemplateId.length() > 0){
                List<SVMXC__PM_Plan_Template__c> lstTemplate = [SELECT Id,Name,SVMXC__SM_Schedule_Type__c,SVMXC__Coverage_Type__c,SVMXC__SM_Adjustment_Activity_Date__c,SVMXC__IB_Criteria__c,SVMXC__SM_Work_Order_Purpose__c FROM SVMXC__PM_Plan_Template__c WHERE Id =: pmPlanTemplateId];
                if(lstTemplate.size() > 0)
                    objPMPlanTemplate = lstTemplate[0];

                List<SVMXC__PM_Applicable_Product__c> lstApplicableProduct = [SELECT Id,SVMXC__Product__c FROM SVMXC__PM_Applicable_Product__c WHERE SVMXC__PM_Plan_Template__c =: pmPlanTemplateId];
                if(lstApplicableProduct.size() > 0)
                    objApplicableProduct = lstApplicableProduct[0];
            }

            objPMPlanTemplate.Name = objTemplateDetail.templateName;
            objPMPlanTemplate.SVMXC__SM_Schedule_Type__c = objTemplateDetail.scheduleType;
            objPMPlanTemplate.SVMXC__SM_Condition_Type__c = objTemplateDetail.conditionType;
            objPMPlanTemplate.SVMXC__Coverage_Type__c = objTemplateDetail.coverageType;
            objPMPlanTemplate.SVMXC__SM_Adjustment_Activity_Date__c = objTemplateDetail.activityDate;
            objPMPlanTemplate.SVMXC__SM_Advanced_Expression__c = strAdvExpr.toUpperCase();
            objPMPlanTemplate.SVMXC__SM_Use_Current_Field_Value__c = Boolean.valueOf(objTemplateDetail.useCurrentFieldVal);
            if(objPMPlanTemplate.SVMXC__SM_Condition_Type__c == 'Criteria_Comparison'){
                objPMPlanTemplate.SVMXC__SM_Use_Current_Field_Value__c = false;
            }
            if(objTemplateDetail.installedProductFilter != 'None' && objTemplateDetail.installedProductFilter != null){
                objPMPlanTemplate.SVMXC__IB_Criteria__c = objTemplateDetail.installedProductFilter;
            }
            else{
                objPMPlanTemplate.SVMXC__IB_Criteria__c = null;
            }
            if(objTemplateDetail.workOrderPurpose != 'None' && objTemplateDetail.workOrderPurpose != null){
                objPMPlanTemplate.SVMXC__SM_Work_Order_Purpose__c = objTemplateDetail.workOrderPurpose;
            }
            else{
                objPMPlanTemplate.SVMXC__SM_Work_Order_Purpose__c = null;
            }
            
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess( objPMPlanTemplate, COMM_SecurityUtils.Access.Upsertable)){
                upsert objPMPlanTemplate; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }else{
                  throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }

            if(objApplicableProduct.Id == null){
                objApplicableProduct.SVMXC__PM_Plan_Template__c = objPMPlanTemplate.Id;
            }
            objApplicableProduct.SVMXC__Product__c = objTemplateDetail.product;
            
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess( objApplicableProduct, COMM_SecurityUtils.Access.Upsertable) ){
                upsert objApplicableProduct; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }else{
                  throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }

            //save condition rule data
            request.pmPlanTemplateId = objPMPlanTemplate.Id;
            if(objPMPlanTemplate.SVMXC__SM_Condition_Type__c == 'Usage_Frequency'){
                PREV_SaveConditionRuleData(request);
            }
            else if(objPMPlanTemplate.SVMXC__SM_Condition_Type__c == 'Criteria_Comparison'){
                PREV_SaveCriteriaConditionRuleData(request);
            }

            objResponse.pmPlanTemplateId = objPMPlanTemplate.Id;
            objResponse.success = true;
            objResponse.messageList.add(System.Label.PREV004_TAG009);//Record Saved Successfully
        }
        catch(Exception ex){
            Database.rollback(objSavepoint);
            objResponse.success = false;
            objResponse.messageList.add(ex.getMessage());
            System.debug(LoggingLevel.WARN, 'Exception in PREV_SaveTemplateData method: ' + ex.getMessage());
            System.debug(LoggingLevel.WARN, 'StackTrace in PREV_SaveTemplateData method: ' + ex.getStackTraceString());
        }
        System.debug(LoggingLevel.WARN, 'Response of PREV_SaveTemplateData method: ' + objResponse);
        return objResponse;
    }

    //This method Saves the condition rule data
    //Request will have List of ConditionRule wrapper class and PM plan template Id.
    //Response will be success or failure status, applicable message and pmPlanTemplateId
    public SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response PREV_SaveConditionRuleData(SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request request){
        System.debug(LoggingLevel.WARN, 'Request in PREV_SaveConditionRuleData method : ' + request);

        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response objResponse = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response();
        objResponse.messageList = new List<String>();
        objResponse.success = false;
        Savepoint objSavepoint;

        String pmPlanTemplateId = request.pmPlanTemplateId;
        List<SVMXC__PM_Schedule_Template__c> listScheduleTemplateToDelete = [SELECT Id FROM SVMXC__PM_Schedule_Template__c WHERE SVMXC__PM_Plan_Template__c =: pmPlanTemplateId];

        List<SVMXC__PM_Schedule_Template__c> listScheduleTemplate = new List<SVMXC__PM_Schedule_Template__c>();
        List<SVMXC.PREV_SetupPMPlan_Wrapper.ConditionRules> listConditionRule = request.conditionRuleList;
        
        try{
            //Creating savePoint
            objSavepoint = Database.setSavepoint();

            for(SVMXC.PREV_SetupPMPlan_Wrapper.ConditionRules objConditionRule : listConditionRule){
                SVMXC__PM_Schedule_Template__c objScheduelTemplate = new SVMXC__PM_Schedule_Template__c();
                objScheduelTemplate.SVMXC__PM_Plan_Template__c = pmPlanTemplateId;
                objScheduelTemplate.SVMXC__Sequence__c = Decimal.ValueOf(objConditionRule.sequence);
                objScheduelTemplate.SVMXC__SM_IB_Attribute__c = objConditionRule.selectedField;
                objScheduelTemplate.SVMXC__SM_Attr_Data_type__c = objConditionRule.fieldDataType;
                objScheduelTemplate.SVMXC__SM_Attribute_Type__c = objConditionRule.fieldAttType;
                objScheduelTemplate.SVMXC__SM_Operator__c = objConditionRule.selectedOperator;
                objScheduelTemplate.SVMXC__Frequency_Unit__c = objConditionRule.selectedFreqUnit;
                objScheduelTemplate.SVMXC__SM_Adjustment_Type__c = objConditionRule.selectedAdjustmentType;
                objScheduelTemplate.SVMXC__SM_Adjusted_Units__c = objConditionRule.selectedAdjustedUnit;
                objScheduelTemplate.SVMXC__SM_Threshold_Type__c = 'Percentage';
                objScheduelTemplate.SVMXC__SM_Start_At__c = objConditionRule.startAt;
                objScheduelTemplate.SVMXC__SM_Stop_At__c = objConditionRule.stopAt;
                
                if(objConditionRule.frequency != null && objConditionRule.frequency != ''){
                    objScheduelTemplate.SVMXC__Frequency__c = Decimal.ValueOf(objConditionRule.frequency);
                }
                if(objConditionRule.threshold != null && objConditionRule.threshold != ''){
                 objScheduelTemplate.SVMXC__SM_Threshold__c = Decimal.ValueOf(objConditionRule.threshold);
                }
                if(objConditionRule.minAdjustment != null && objConditionRule.minAdjustment != ''){
                    objScheduelTemplate.SVMXC__SM_Min_Activity_Changed__c = Decimal.ValueOf(objConditionRule.minAdjustment);
                }
                if(objConditionRule.maxAdjustment != null && objConditionRule.maxAdjustment != ''){
                    objScheduelTemplate.SVMXC__SM_Max_Activity_Changed__c = Decimal.ValueOf(objConditionRule.maxAdjustment);
                }
                if(objConditionRule.adjustmentVal != null && objConditionRule.adjustmentVal != ''){
                    objScheduelTemplate.SVMXC__SM_Adjusted_Value__c = Decimal.ValueOf(objConditionRule.adjustmentVal);
                }

                listScheduleTemplate.add(objScheduelTemplate);
            }
            if(!listScheduleTemplate.isEmpty()){
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess( listScheduleTemplate, COMM_SecurityUtils.Access.Createable) ){
                    insert listScheduleTemplate; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }

            if(!listScheduleTemplateToDelete.isEmpty()){
                if(COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__PM_Schedule_Template__c' ) ){
                    delete listScheduleTemplateToDelete; //SDL-SVMX-DELETE-FLS-ENFORCED
                }else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
            objResponse.pmPlanTemplateId = pmPlanTemplateId;
            objResponse.success = true;
            objResponse.messageList.add(System.Label.PREV004_TAG009);//Record Saved Successfully
        }
        catch(Exception ex){
            Database.rollback(objSavepoint);
            objResponse.success = false;
            objResponse.messageList.add(ex.getMessage());
            System.debug(LoggingLevel.WARN, 'Exception in PREV_SaveConditionRuleData method: ' + ex.getMessage());
            System.debug(LoggingLevel.WARN, 'StackTrace in PREV_SaveConditionRuleData method: ' + ex.getStackTraceString());
        }
        System.debug(LoggingLevel.WARN, 'Response of PREV_SaveConditionRuleData method: ' + objResponse);
        return objResponse;
    }

    //This method Saves the condition rule data for Criteria based
    //Request will have List of ConditionRule wrapper class and PM plan template Id.
    //Response will be success or failure status, applicable message and pmPlanTemplateId
    public SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response PREV_SaveCriteriaConditionRuleData(SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request request){
        System.debug(LoggingLevel.WARN, 'Request in PREV_SaveCriteriaConditionRuleData method : ' + request);

        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response objResponse = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response();
        objResponse.messageList = new List<String>();
        objResponse.success = false;
        Savepoint objSavepoint;

        String pmPlanTemplateId = request.pmPlanTemplateId;
        List<SVMXC__PM_Schedule_Template__c> listScheduleTemplateToDelete = [SELECT Id FROM SVMXC__PM_Schedule_Template__c WHERE SVMXC__PM_Plan_Template__c =: pmPlanTemplateId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

        List<SVMXC__PM_Schedule_Template__c> listScheduleTemplate = new List<SVMXC__PM_Schedule_Template__c>();
        List<SVMXC.PREV_SetupPMPlan_Wrapper.ConditionRules> listConditionRule = request.conditionRuleList;
        
        try{
            //Creating savePoint
            objSavepoint = Database.setSavepoint();

            for(SVMXC.PREV_SetupPMPlan_Wrapper.ConditionRules objConditionRule : listConditionRule){
                SVMXC__PM_Schedule_Template__c objScheduelTemplate = new SVMXC__PM_Schedule_Template__c();
                objScheduelTemplate.SVMXC__PM_Plan_Template__c = pmPlanTemplateId;
                objScheduelTemplate.SVMXC__Sequence__c = Decimal.ValueOf(objConditionRule.sequence);
                objScheduelTemplate.SVMXC__SM_IB_Attribute__c = objConditionRule.selectedField;
                objScheduelTemplate.SVMXC__SM_Attr_Data_type__c = objConditionRule.fieldDataType;
                objScheduelTemplate.SVMXC__SM_Attribute_Type__c = objConditionRule.fieldAttType;
                objScheduelTemplate.SVMXC__SM_Operator__c = objConditionRule.selectedOperator;
                objScheduelTemplate.SVMXC__SM_Value__c = objConditionRule.value;
                listScheduleTemplate.add(objScheduelTemplate);
            }
            if(!listScheduleTemplate.isEmpty()){
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( listScheduleTemplate, COMM_SecurityUtils.Access.Createable ) ) {
                    insert listScheduleTemplate; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }

            if(!listScheduleTemplateToDelete.isEmpty()){
                delete listScheduleTemplateToDelete; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
            objResponse.pmPlanTemplateId = pmPlanTemplateId;
            objResponse.success = true;
            objResponse.messageList.add(System.Label.PREV004_TAG009);//Record Saved Successfully
        }
        catch(Exception ex){
            Database.rollback(objSavepoint);
            objResponse.success = false;
            objResponse.messageList.add(ex.getMessage());
            System.debug(LoggingLevel.WARN, 'Exception in PREV_SaveCriteriaConditionRuleData method: ' + ex.getMessage());
            System.debug(LoggingLevel.WARN, 'StackTrace in PREV_SaveCriteriaConditionRuleData method: ' + ex.getStackTraceString());
        }
        System.debug(LoggingLevel.WARN, 'Response of PREV_SaveCriteriaConditionRuleData method: ' + objResponse);
        return objResponse;
    }

    public SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response PREV_GetRecordInfo(SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request request){
        System.debug(LoggingLevel.WARN, 'Request in PREV_GetRecordInfo method : ' + request);

        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response objResponse = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response();
        objResponse.messageList = new List<String>();
        objResponse.success = false;
        objResponse.pmPlanTemplate = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Template_Detail();
        
        try{
            String templateId = request.pmPlanTemplateId;
            List<SVMXC__PM_Applicable_Product__c> lstApplicableProduct;
            List<SVMXC__PM_Plan_Template__c> lstOfPMPlanTemplate = [SELECT Id,Name,SVMXC__SM_Schedule_Type__c, SVMXC__SM_Condition_Type__c, SVMXC__Coverage_Type__c,SVMXC__SM_Adjustment_Activity_Date__c,SVMXC__IB_Criteria__c,SVMXC__SM_Work_Order_Purpose__c, SVMXC__SM_Advanced_Expression__c, SVMXC__SM_Use_Current_Field_Value__c FROM SVMXC__PM_Plan_Template__c WHERE Id =: templateId];
            
            if(lstOfPMPlanTemplate.size() > 0){
                lstApplicableProduct = [SELECT SVMXC__Product__c, SVMXC__Product__r.Name FROM SVMXC__PM_Applicable_Product__c WHERE SVMXC__PM_Plan_Template__c =: templateId];
            }

            SVMXC.PREV_SetupPMPlan_Wrapper.PM_Template_Detail objTemplateDetail = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Template_Detail();
            objTemplateDetail.templateName = lstOfPMPlanTemplate[0].Name;
            objTemplateDetail.templateId = lstOfPMPlanTemplate[0].Id;
            objTemplateDetail.scheduleType = lstOfPMPlanTemplate[0].SVMXC__SM_Schedule_Type__c;
            objTemplateDetail.conditionType = lstOfPMPlanTemplate[0].SVMXC__SM_Condition_Type__c;
            if(objTemplateDetail.conditionType == null || objTemplateDetail.conditionType == ''){
                objTemplateDetail.conditionType = 'Usage_Frequency';
            }
            objTemplateDetail.coverageType = lstOfPMPlanTemplate[0].SVMXC__Coverage_Type__c;
            
            objTemplateDetail.installedProductFilter = lstOfPMPlanTemplate[0].SVMXC__IB_Criteria__c;
            objTemplateDetail.activityDate = lstOfPMPlanTemplate[0].SVMXC__SM_Adjustment_Activity_Date__c;
            objTemplateDetail.workOrderPurpose = lstOfPMPlanTemplate[0].SVMXC__SM_Work_Order_Purpose__c;
            objTemplateDetail.advancedExpression = lstOfPMPlanTemplate[0].SVMXC__SM_Advanced_Expression__c;
            objTemplateDetail.useCurrentFieldVal = String.valueOf(lstOfPMPlanTemplate[0].SVMXC__SM_Use_Current_Field_Value__c);
            if(lstApplicableProduct.size() > 0){
                objTemplateDetail.product = lstApplicableProduct[0].SVMXC__Product__c;
                objTemplateDetail.productName = lstApplicableProduct[0].SVMXC__Product__r.Name;
            }
            objResponse.pmPlanTemplate = objTemplateDetail;

            //Fetching condition rule details
            List<SVMXC.PREV_SetupPMPlan_Wrapper.ConditionRules> listOfConditionRule = new List<SVMXC.PREV_SetupPMPlan_Wrapper.ConditionRules>();
            List<SVMXC__PM_Schedule_Template__c> listScheduleTemplate = [SELECT Id, SVMXC__PM_Plan_Template__c, SVMXC__Sequence__c, SVMXC__SM_IB_Attribute__c, SVMXC__SM_Attr_Data_type__c, SVMXC__SM_Attribute_Type__c, SVMXC__SM_Operator__c, SVMXC__Frequency_Unit__c, SVMXC__SM_Adjustment_Type__c, SVMXC__SM_Adjusted_Units__c, SVMXC__SM_Threshold_Type__c, SVMXC__SM_Start_At__c, SVMXC__SM_Stop_At__c, SVMXC__Frequency__c, SVMXC__SM_Threshold__c, SVMXC__SM_Min_Activity_Changed__c, SVMXC__SM_Max_Activity_Changed__c, SVMXC__SM_Adjusted_Value__c, SVMXC__SM_Value__c FROM SVMXC__PM_Schedule_Template__c WHERE SVMXC__PM_Plan_Template__c =: templateId Order By SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

            if(!listScheduleTemplate.isEmpty()){
                if(objTemplateDetail.conditionType == 'Usage_Frequency'){
                for(SVMXC__PM_Schedule_Template__c objSchTemp : listScheduleTemplate){
                    SVMXC.PREV_SetupPMPlan_Wrapper.ConditionRules objConditionRule = new SVMXC.PREV_SetupPMPlan_Wrapper.ConditionRules();
                    objConditionRule.conditionRuleId = objSchTemp.Id;
                    objConditionRule.sequence = String.valueOf(Integer.valueOf(objSchTemp.SVMXC__Sequence__c));
                    objConditionRule.selectedField = objSchTemp.SVMXC__SM_IB_Attribute__c;
                    objConditionRule.fieldDataType = objSchTemp.SVMXC__SM_Attr_Data_type__c;
                    objConditionRule.fieldAttType = objSchTemp.SVMXC__SM_Attribute_Type__c;
                    objConditionRule.selectedOperator = objSchTemp.SVMXC__SM_Operator__c;
                    objConditionRule.selectedAdjustedUnit = objSchTemp.SVMXC__SM_Adjusted_Units__c;
                    objConditionRule.selectedFreqUnit = objSchTemp.SVMXC__Frequency_Unit__c;
                    objConditionRule.startAt = objSchTemp.SVMXC__SM_Start_At__c;
                    objConditionRule.stopAt = objSchTemp.SVMXC__SM_Stop_At__c;
                    objConditionRule.selectedAdjustmentType = objSchTemp.SVMXC__SM_Adjustment_Type__c;
                    objConditionRule.threshold = String.valueOf(objSchTemp.SVMXC__SM_Threshold__c);
                    if(objSchTemp.SVMXC__SM_Min_Activity_Changed__c != null){
                        objConditionRule.minAdjustment = String.valueOf(objSchTemp.SVMXC__SM_Min_Activity_Changed__c.stripTrailingZeros().toPlainString());
                    }
                    else{
                        objConditionRule.minAdjustment = '';
                    }
                    
                    if(objSchTemp.SVMXC__SM_Max_Activity_Changed__c != null){
                        objConditionRule.maxAdjustment = String.valueOf(objSchTemp.SVMXC__SM_Max_Activity_Changed__c.stripTrailingZeros().toPlainString());
                    }
                    else{
                        objConditionRule.maxAdjustment = '';
                    }

                    if(objSchTemp.SVMXC__SM_Adjusted_Value__c != null){
                        objConditionRule.adjustmentVal = String.valueOf(objSchTemp.SVMXC__SM_Adjusted_Value__c.stripTrailingZeros().toPlainString());
                    }
                    else{
                        objConditionRule.adjustmentVal = '';
                    }
                    if(objSchTemp.SVMXC__Frequency__c != null){
                        objConditionRule.frequency = String.valueOf(objSchTemp.SVMXC__Frequency__c.stripTrailingZeros().toPlainString());
                    }
                    else{
                        objConditionRule.frequency = '';
                    }
                    listOfConditionRule.add(objConditionRule);
                }
                }
                else if(objTemplateDetail.conditionType == 'Criteria_Comparison'){
                    for(SVMXC__PM_Schedule_Template__c objSchTemp : listScheduleTemplate){
                        SVMXC.PREV_SetupPMPlan_Wrapper.ConditionRules objConditionRule = new SVMXC.PREV_SetupPMPlan_Wrapper.ConditionRules();
                        objConditionRule.conditionRuleId = objSchTemp.Id;
                        objConditionRule.sequence = String.valueOf(Integer.valueOf(objSchTemp.SVMXC__Sequence__c));
                        objConditionRule.selectedField = objSchTemp.SVMXC__SM_IB_Attribute__c;
                        objConditionRule.fieldDataType = objSchTemp.SVMXC__SM_Attr_Data_type__c;
                        objConditionRule.fieldAttType = objSchTemp.SVMXC__SM_Attribute_Type__c;
                        objConditionRule.selectedOperator = objSchTemp.SVMXC__SM_Operator__c;
                        objConditionRule.value = objSchTemp.SVMXC__SM_Value__c;
                        listOfConditionRule.add(objConditionRule);
                    }
                }
                objResponse.conditionRuleList = listOfConditionRule;
            }

            if(lstApplicableProduct.size() > 0){
                //Fetch technical attribute list
                PREV_PMPlanUtils objPMPlanUtils = new PREV_PMPlanUtils();
                SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request getTArequest = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request();
                getTArequest.productId = lstApplicableProduct[0].SVMXC__Product__c;
                getTArequest.pmPlanTemplate = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Template_Detail();
                getTArequest.pmPlanTemplate.conditionType = objTemplateDetail.conditionType;
                SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response objTAResponse = objPMPlanUtils.PREV_GetTechnicalAttribute(getTArequest);
                objResponse.mapOfKeyAndListOfKeyValue = objTAResponse.mapOfKeyAndListOfKeyValue;
            }
            objResponse.success = true;
        }
        catch(Exception ex){
            objResponse.success = false;
            objResponse.messageList.add(ex.getMessage());
            System.debug(LoggingLevel.WARN, 'Exception in PREV_GetRecordInfo method: ' + ex.getMessage());
            System.debug(LoggingLevel.WARN, 'StackTrace in PREV_GetTechnicalAttribute method: ' + ex.getStackTraceString());
        }
        System.debug(LoggingLevel.WARN, 'Response of PREV_GetRecordInfo method: ' + objResponse);
        return objResponse;
    }

    public SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response PREV_GetSampleSchedules(SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request request){
        System.debug(LoggingLevel.WARN, 'Request in PREV_GetSampleSchedules method : ' + request);

        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response objResponse = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response();
        objResponse.messageList = new List<String>();
        objResponse.success = false;
        objResponse.listKeyValue = new List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue>();
        
        try{
            List<PREV_SetupPMPlan_Wrapper.ConditionRules> listConditionRule = request.conditionRuleList;
            String strAdvExpr = request.pmPlanTemplate.advancedExpression;
            String strConditionType = request.pmPlanTemplate.conditionType;

            //Validate Advance Expression
            Integer countOfRules = 0;
            if(listConditionRule != null){
                countOfRules = listConditionRule.size();
            }
            if(strAdvExpr != null && strAdvExpr != '' && strAdvExpr.length() > 0){
                PREV_PMPlanUtils objPMPlanUtils = new PREV_PMPlanUtils();
                Boolean isAdvExprValid = objPMPlanUtils.validateAdvExpression(strAdvExpr, countOfRules);
                if(!isAdvExprValid){
                    objResponse.success = false;
                    objResponse.messageList.add(System.Label.PREV004_TAG052);
                    System.debug(LoggingLevel.WARN, 'Invalid Advanced Expression');
                    return objResponse;
                }
            }
            else if(strAdvExpr == null || strAdvExpr == ''){
                String strCriteria = '';
                if(countOfRules > 1){
                    for(Integer i = 0; i<countOfRules; i++){
                        if(strCriteria.length() > 0)
                            strCriteria += ' AND ';
                        strCriteria += i+1;
                    }
                }
                else if(countOfRules == 1){
                    strCriteria = '1';
                }
                System.debug(LoggingLevel.WARN, 'strCriteria : ' + strCriteria);
                strAdvExpr = strCriteria;
            }
            
            
            Map <String, String> mapUniqOrderSeq = new Map <String, String>();

            for(integer j =1 ;  j<=5; j++){
                mapUniqOrderSeq.put(String.valueOf(j), '~'+String.valueOf(j));
            }
            
            
            //Calling sample schedule creation method
            PREV_SetupPMPlanImpl objPREV_SetupPMPlanImpl = new PREV_SetupPMPlanImpl();

            List<PREV_SetupPMPlan_Wrapper.Schedule> lstSchedule;
            if(strConditionType.equalsIgnoreCase('Criteria_Comparison')){
                lstSchedule = objPREV_SetupPMPlanImpl.wrapperScheduleRecForCriteria(listConditionRule, strAdvExpr, null, mapUniqOrderSeq);
            }
            else{
                lstSchedule = objPREV_SetupPMPlanImpl.wrapperScheduleRec(listConditionRule, null, strAdvExpr, null, listConditionRule, mapUniqOrderSeq);
            }

            //Calling sample schedule creation method
            objResponse.scheduleList = lstSchedule;
            objResponse.success = true;
        }
        catch(Exception ex){
            objResponse.success = false;
            objResponse.messageList.add(ex.getMessage());
            System.debug(LoggingLevel.WARN, 'Exception in PREV_GetSampleSchedules method: ' + ex.getMessage());
            System.debug(LoggingLevel.WARN, 'StackTrace in PREV_GetSampleSchedules method: ' + ex.getStackTraceString());
        }
        System.debug(LoggingLevel.WARN, 'Response of PREV_GetSampleSchedules method: ' + objResponse);
        return objResponse;
    }
}