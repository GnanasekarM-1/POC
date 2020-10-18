@isTest
Private class PREV_SetupPMPlanTemplateImpl_UT{
    static testMethod void PREV_GetFilterList_Test(){
        SVMXC.PREV_SetupPMPlanTemplateImpl objPREV_SetupPMPlanTemplateImpl = new SVMXC.PREV_SetupPMPlanTemplateImpl();
        createTestData();
        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request objPM_Plan_Template_Request = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request();
        objPM_Plan_Template_Request.objectName = 'SVMXC__Installed_Product__c';
        objPREV_SetupPMPlanTemplateImpl.PREV_GetFilterList(objPM_Plan_Template_Request);
    }

    static testMethod void PREV_GetTaskTemplate_Test(){
        SVMXC.PREV_SetupPMPlanTemplateImpl objPREV_SetupPMPlanTemplateImpl = new SVMXC.PREV_SetupPMPlanTemplateImpl();
        createTestData();
        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request objPM_Plan_Template_Request = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request();
        objPREV_SetupPMPlanTemplateImpl.PREV_GetTaskTemplate(objPM_Plan_Template_Request);
    }

    static testMethod void PREV_GetActivityDateList_Test(){
        SVMXC.PREV_SetupPMPlanTemplateImpl objPREV_SetupPMPlanTemplateImpl = new SVMXC.PREV_SetupPMPlanTemplateImpl();

        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request objPM_Plan_Template_Request = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request();
        objPREV_SetupPMPlanTemplateImpl.PREV_GetActivityDateList(objPM_Plan_Template_Request);
    }

    static testMethod void PREV_GetPicklistValues_Test(){
        SVMXC.PREV_SetupPMPlanTemplateImpl objPREV_SetupPMPlanTemplateImpl = new SVMXC.PREV_SetupPMPlanTemplateImpl();

        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request objPM_Plan_Template_Request = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request();
        objPM_Plan_Template_Request.lstOfValues = new List<String>{'SVMXC__Coverage_Type__c','SVMXC__SM_Schedule_Type__c'};
        objPREV_SetupPMPlanTemplateImpl.PREV_GetPicklistValues(objPM_Plan_Template_Request);
    }

    static testMethod void PREV_SaveTemplateData_Test(){
        SVMXC.PREV_SetupPMPlanTemplateImpl objPREV_SetupPMPlanTemplateImpl = new SVMXC.PREV_SetupPMPlanTemplateImpl();

        Product2 sobjProduct2 = new Product2(
          Name = 'Transmitter',                           // Product Name
          SVMXC__Unit_Of_Measure__c = 'Each',           // Unit of Measure
          ProductCode = 'Transmitter',                    // Product Code
          IsActive = true,                                // Active
          SVMXC__Stockable__c = true,                   // Stockable
          SVMXC__Product_Line__c = 'Software',          // Product Line
          Family = 'iPad',                                // Product Family
          SVMXC__Inherit_Parent_Warranty__c = true,     // Inherit Parent Warranty
          SVMXC__Enable_Serialized_Tracking__c = true  // Enable Serialized Tracking of Stock
        );
        insert sobjProduct2;

        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Template_Detail objTemplateDetail = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Template_Detail();
        objTemplateDetail.templateName = 'Test Template';
        objTemplateDetail.scheduleType = 'Condition Based';
        objTemplateDetail.coverageType = 'Product (Must Have IB)';
        objTemplateDetail.product = sobjProduct2.id;
        objTemplateDetail.activityDate = 'Acknowledged By Technician Date Time';
        objTemplateDetail.advancedExpression = '1 AND 2';
        objTemplateDetail.useCurrentFieldVal = 'true';
        objTemplateDetail.conditionType = 'Usage_Frequency';

        List<SVMXC.PREV_SetupPMPlan_Wrapper.ConditionRules> listConditionRule = new List<SVMXC.PREV_SetupPMPlan_Wrapper.ConditionRules>();
        SVMXC.PREV_SetupPMPlan_Wrapper.ConditionRules objConditionRules = new SVMXC.PREV_SetupPMPlan_Wrapper.ConditionRules();
        objConditionRules.sequence = '1';
        objConditionRules.selectedOperator = 'EYI';
        objConditionRules.frequency = '2';
        objConditionRules.selectedFreqUnit = 'Weeks';
        objConditionRules.startAt = '2017-03-22';
        objConditionRules.stopAt = '2017-03-24';
        objConditionRules.threshold = '1';
        objConditionRules.minAdjustment = '2';
        objConditionRules.maxAdjustment = '22';
        objConditionRules.adjustmentVal = '12';
        objConditionRules.fieldDataType = 'Date';
        listConditionRule.add(objConditionRules);

        objConditionRules = new SVMXC.PREV_SetupPMPlan_Wrapper.ConditionRules();
        objConditionRules.sequence = '2';
        objConditionRules.selectedOperator = 'EYI';
        objConditionRules.frequency = '2';
        objConditionRules.selectedFreqUnit = 'Weeks';
        objConditionRules.startAt = '2017-03-22';
        objConditionRules.stopAt = '2017-03-24';
        objConditionRules.threshold = '1';
        objConditionRules.minAdjustment = '2';
        objConditionRules.maxAdjustment = '22';
        objConditionRules.adjustmentVal = '12';
        objConditionRules.fieldDataType = 'Date';
        listConditionRule.add(objConditionRules);

        //save
        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request objPM_Plan_Template_Request = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request();
        objPM_Plan_Template_Request.pmPlanTemplate = objTemplateDetail;
        objPM_Plan_Template_Request.conditionRuleList = listConditionRule;
        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response objResponse = objPREV_SetupPMPlanTemplateImpl.PREV_SaveTemplateData(objPM_Plan_Template_Request);

        String templateId = objResponse.pmPlanTemplateId;

        //GetRecordInfo
        objPM_Plan_Template_Request = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request();
        objPM_Plan_Template_Request.pmPlanTemplateId = templateId;
        objPREV_SetupPMPlanTemplateImpl.PREV_GetRecordInfo(objPM_Plan_Template_Request);

        //Resave
        objPM_Plan_Template_Request = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request();
        objPM_Plan_Template_Request.pmPlanTemplateId = templateId;
        objPM_Plan_Template_Request.pmPlanTemplate = objTemplateDetail;
        objPM_Plan_Template_Request.conditionRuleList = listConditionRule;
        objResponse = objPREV_SetupPMPlanTemplateImpl.PREV_SaveTemplateData(objPM_Plan_Template_Request);

        //Get Sample schedules
        objPM_Plan_Template_Request = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request();
        objPM_Plan_Template_Request.pmPlanTemplate = objTemplateDetail;
        objPM_Plan_Template_Request.conditionRuleList = listConditionRule;
        objResponse = objPREV_SetupPMPlanTemplateImpl.PREV_GetSampleSchedules(objPM_Plan_Template_Request);

        //Invalid adv expr
        objTemplateDetail.advancedExpression = '1 AND 2 AND 3';
        objPM_Plan_Template_Request = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request();
        objPM_Plan_Template_Request.pmPlanTemplateId = templateId;
        objPM_Plan_Template_Request.pmPlanTemplate = objTemplateDetail;
        objPM_Plan_Template_Request.conditionRuleList = listConditionRule;
        objResponse = objPREV_SetupPMPlanTemplateImpl.PREV_SaveTemplateData(objPM_Plan_Template_Request);
        objResponse = objPREV_SetupPMPlanTemplateImpl.PREV_GetSampleSchedules(objPM_Plan_Template_Request);

        //Two rule but no adv expr
        objTemplateDetail.advancedExpression = '';
        objPM_Plan_Template_Request = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request();
        objPM_Plan_Template_Request.pmPlanTemplateId = templateId;
        objPM_Plan_Template_Request.pmPlanTemplate = objTemplateDetail;
        objPM_Plan_Template_Request.conditionRuleList = listConditionRule;
        objResponse = objPREV_SetupPMPlanTemplateImpl.PREV_SaveTemplateData(objPM_Plan_Template_Request);
        objResponse = objPREV_SetupPMPlanTemplateImpl.PREV_GetSampleSchedules(objPM_Plan_Template_Request);

        //Invalid product in pm plan template
        objTemplateDetail.product = 'dffdf';
        objPM_Plan_Template_Request = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request();
        objPM_Plan_Template_Request.pmPlanTemplateId = templateId;
        objPM_Plan_Template_Request.pmPlanTemplate = objTemplateDetail;
        objPM_Plan_Template_Request.conditionRuleList = listConditionRule;
        objResponse = objPREV_SetupPMPlanTemplateImpl.PREV_SaveTemplateData(objPM_Plan_Template_Request);

        //Create exeception by passing invalid value for useCurrentFieldVal
        objTemplateDetail.product = sobjProduct2.id;
        objTemplateDetail.advancedExpression = '1 AND 2';
        objTemplateDetail.useCurrentFieldVal = '';
        objPM_Plan_Template_Request = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request();
        objPM_Plan_Template_Request.pmPlanTemplateId = templateId;
        objPM_Plan_Template_Request.pmPlanTemplate = objTemplateDetail;
        objPM_Plan_Template_Request.conditionRuleList = listConditionRule;
        objResponse = objPREV_SetupPMPlanTemplateImpl.PREV_SaveTemplateData(objPM_Plan_Template_Request);
    }

    static testMethod void PREV_SaveTemplateDataForCriteria_Test(){
        SVMXC.PREV_SetupPMPlanTemplateImpl objPREV_SetupPMPlanTemplateImpl = new SVMXC.PREV_SetupPMPlanTemplateImpl();

        Product2 sobjProduct2 = new Product2(
          Name = 'Transmitter',                           // Product Name
          SVMXC__Unit_Of_Measure__c = 'Each',           // Unit of Measure
          ProductCode = 'Transmitter',                    // Product Code
          IsActive = true,                                // Active
          SVMXC__Stockable__c = true,                   // Stockable
          SVMXC__Product_Line__c = 'Software',          // Product Line
          Family = 'iPad',                                // Product Family
          SVMXC__Inherit_Parent_Warranty__c = true,     // Inherit Parent Warranty
          SVMXC__Enable_Serialized_Tracking__c = true  // Enable Serialized Tracking of Stock
        );
        insert sobjProduct2;

        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Template_Detail objTemplateDetail = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Template_Detail();
        objTemplateDetail.templateName = 'Test Template';
        objTemplateDetail.scheduleType = 'Condition Based';
        objTemplateDetail.coverageType = 'Product (Must Have IB)';
        objTemplateDetail.product = sobjProduct2.id;
        objTemplateDetail.activityDate = 'Acknowledged By Technician Date Time';
        objTemplateDetail.advancedExpression = '1 AND 2';
        objTemplateDetail.useCurrentFieldVal = 'true';
        objTemplateDetail.conditionType = 'Criteria_Comparison';

        List<SVMXC.PREV_SetupPMPlan_Wrapper.ConditionRules> listConditionRule = new List<SVMXC.PREV_SetupPMPlan_Wrapper.ConditionRules>();
        SVMXC.PREV_SetupPMPlan_Wrapper.ConditionRules objConditionRules = new SVMXC.PREV_SetupPMPlan_Wrapper.ConditionRules();
        objConditionRules.sequence = '1';
        objConditionRules.selectedOperator = 'eq';
        objConditionRules.selectedField = 'SVMXC__City__c';
        objConditionRules.fieldDataType = 'TEXT';
        objConditionRules.fieldAttType = 'Schema';
        objConditionRules.value = 'Bangalore';
        listConditionRule.add(objConditionRules);

        objConditionRules = new SVMXC.PREV_SetupPMPlan_Wrapper.ConditionRules();
        objConditionRules.sequence = '2';
        objConditionRules.selectedOperator = 'gt';
        objConditionRules.selectedField = 'SVMXC__Longitude__c';
        objConditionRules.fieldAttType = 'Schema';
        objConditionRules.fieldDataType = 'Number';
        objConditionRules.value = '15';
        listConditionRule.add(objConditionRules);

        //save
        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request objPM_Plan_Template_Request = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request();
        objPM_Plan_Template_Request.pmPlanTemplate = objTemplateDetail;
        objPM_Plan_Template_Request.conditionRuleList = listConditionRule;
        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response objResponse = objPREV_SetupPMPlanTemplateImpl.PREV_SaveTemplateData(objPM_Plan_Template_Request);

        String templateId = objResponse.pmPlanTemplateId;

        //GetRecordInfo
        objPM_Plan_Template_Request = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request();
        objPM_Plan_Template_Request.pmPlanTemplateId = templateId;
        objPM_Plan_Template_Request.pmPlanTemplate = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Template_Detail();
        objPM_Plan_Template_Request.pmPlanTemplate.conditionType = 'Criteria_Comparison';
        objPREV_SetupPMPlanTemplateImpl.PREV_GetRecordInfo(objPM_Plan_Template_Request);
    }

    static void createTestData(){
        //Fetching recordTypes
        List<RecordType> lstRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__Task_Template__c' OR SobjectType = 'SVMXC__ServiceMax_Processes__c' OR SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        String TemplateRecordTypeId;
        String TaskRecordId;
        String RuleRecordId;
        String ExpressionRecordId;
        for(RecordType obj : lstRecType){
            if(obj.Name == 'Templates')
                TemplateRecordTypeId = obj.Id;
            if(obj.Name == 'Tasks')
                TaskRecordId = obj.Id;
            if(obj.Name == 'SVMX Rule')
                RuleRecordId = obj.Id;
            if(obj.Name == 'Expressions')
                ExpressionRecordId = obj.Id;
        }

        //Creating Template
        SVMXC__Task_Template__c sobjTemplate = new SVMXC__Task_Template__c(
            SVMXC__Template_Name__c = 'Checking HVAC Systems',
            SVMXC__Template_Type__c = 'Preventive Maintenance',
            RecordTypeId = TemplateRecordTypeId
        );
        insert sobjTemplate;

        //Creating Task
        SVMXC__Task_Template__c sobjTask = new SVMXC__Task_Template__c(
            SVMXC__Task_Template__c = sobjTemplate.Id,
            SVMXC__Description__c = 'Check the Air Conditioner and its parts',
            RecordTypeId = TaskRecordId
        );
        insert sobjTask;

        //Creating Expression
        SVMXC__ServiceMax_Processes__c sobjRule = new SVMXC__ServiceMax_Processes__c(
            SVMXC__Name__c = 'CityBangaloretest',                               // Name
            SVMXC__Rule_Type__c = 'Named Expression',                           // Rule Type
            SVMXC__ProcessID__c = 'CityBangaloretest',                          // Process ID
            RecordTypeId = RuleRecordId,                                            // Record Type
            SVMXC__Source_Object_Name__c = 'SVMXC__Installed_Product__c',     // Source Object Name
            SVMXC__IsDefault__c = false,                                        // Is Default?
            SVMXC__IsStandard__c = false,                                       // Is Standard
            SVMXC__Parent_Error_Msg__c = 'City should be bangalore',            // Parent Error Msg
            SVMXC__Parent_Object_Criteria__c = 'SVMXC__City__c=\'Bangalore\'', // Parent Object Criteria
            SVMXC__SettingID__c = 'CityBangaloretest',                          // Setting ID
            SVMXC__Active__c = false                                            // Active
        );
        insert sobjRule; 

        SVMXC__ServiceMax_Config_Data__c sobjExpression = new SVMXC__ServiceMax_Config_Data__c(
          RecordTypeId = ExpressionRecordId,                       // Record Type
          SVMXC__Expression_Rule__c = sobjRule.Id,             // Expression Rule
          SVMXC__Action_Type__c = 'Set Value',                 // Action Type
          SVMXC__Field_Name__c = 'SVMXC__City__c',           // Field Name
          SVMXC__Display_Type__c = 'STRING',                   // Field Type
          SVMXC__Expression_Type__c = 'EXP_Named',             // Expression Type
          SVMXC__Operand__c = 'Bangalore',                     // Operand
          SVMXC__Sequence__c = 1.0000,                         // Sequence
          SVMXC__Operator__c = 'eq'                            // Operator
        );
        insert sobjExpression;
    }
}