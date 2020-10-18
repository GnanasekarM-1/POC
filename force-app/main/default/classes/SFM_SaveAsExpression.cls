public with sharing class SFM_SaveAsExpression {
    public SFM_saveAsExpression(){}
    public SFM_WrapperDef.SFM_Response SFM_saveAsExpression(SFM_WrapperDef.SFM_Request_Expression ExpReq){
        SVMX_Debug log = new SVMX_Debug();
        
        Boolean response_success;
        String response_message;
        String response_tagId;
        List<SFM_WrapperDef.SFM_StringMap> stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        List<String> resultIds=new List<String>();
        Map<String, Id> expRecType_Map = new Map<String, Id>();
        List<String> recTypeNames = new List<String>();
        SFM_Utils utils = new SFM_Utils();
        recTypeNames.add('SVMXC__ServiceMax_Processes__c~SVMX Rule');
        recTypeNames.add('SVMXC__ServiceMax_Config_Data__c~Expressions');
        expRecType_Map = utils.getRecordTypes(recTypeNames);
        List<SFM_WrapperDef.SFM_Expression> LstSFM_Expressions=ExpReq.expressions;
        SVMXC__ServiceMax_Processes__c namedExpression = new SVMXC__ServiceMax_Processes__c();//member of SFM_Response_ProcessNodeInfo
        List<SVMXC__ServiceMax_Config_Data__c> ExpDetails = new List<SVMXC__ServiceMax_Config_Data__c>();//member of SFM_Response_ProcessNodeInfo
        SVMXC__ServiceMax_Processes__c ClonednamedExpression = new SVMXC__ServiceMax_Processes__c();//member of SFM_Response_ProcessNodeInfo
        List<SVMXC__ServiceMax_Config_Data__c> ClonedExpDetails = new List<SVMXC__ServiceMax_Config_Data__c>();//member of SFM_Response_ProcessNodeInfo
        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
        List<SFM_WrapperDef.SFM_Expression> LstSFM_Exp = new List<SFM_WrapperDef.SFM_Expression>();
        //try
        //{
            
            for(SFM_WrapperDef.SFM_Expression Expression: LstSFM_Expressions)
            {
               namedExpression=Expression.namedExpression;  
               ExpDetails.addAll(Expression.expressionDetails);
               ClonednamedExpression = namedExpression.clone(false,true);
               ClonednamedExpression.RecordTypeId=expRecType_Map.get('SVMXC__ServiceMax_Processes__c~SVMX Rule');
               ClonednamedExpression.SVMXC__Rule_Type__c = 'Named Expression';
               ClonednamedExpression.SVMXC__IsStandard__c = false;
               //ClonednamedExpression.SVMXC__Name__c =  ClonednamedExpression.SVMXC__Name__c + ' ' + system.now();
               //ClonednamedExpression.SVMXC__ProcessID__c=ClonednamedExpression.SVMXC__ProcessID__c + ' ' + system.now();
            }
            if(ExpDetails.size() > 0)
            {
               
               for(SVMXC__ServiceMax_Config_Data__c expressDetail : ExpDetails)
               {
                    SVMXC__ServiceMax_Config_Data__c tempconfigdata = new SVMXC__ServiceMax_Config_Data__c();
                    tempconfigdata = expressDetail.clone(false,true);
                    tempconfigdata.RecordTypeId = expRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions');
                    tempconfigdata.SVMXC__Expression_Type__c = 'EXP_Named';
                    ClonedExpDetails.add(tempconfigdata);   
               }
            }
            SFM_WrapperDef.SFM_Expression oSFM_Exp = new SFM_WrapperDef.SFM_Expression(ClonednamedExpression,ClonedExpDetails);
            LstSFM_Exp.add(oSFM_Exp);
            SFM_WrapperDef.SFM_Request_Expression oResponse = new SFM_WrapperDef.SFM_Request_Expression(LstSFM_Exp);//s,msg,tid,strmap Commented for New Approach
            SVMXC.SFM_saveExpression saveExp = new SVMXC.SFM_saveExpression();
            return saveExp.SFM_saveExpression(oResponse);
            //response_success = true;
            //response_message='Cloned successfully';
        /*}
        catch(exception ex)
        {
            log.setlog('ERROR', ex.getmessage());
        
        }*/
        /*log.logout();
        log.print();
        response.logMsg = log.getlog();
        response.success = response_success;
        response.message = response_message;
        response.stringMap = stringMap;
        response.resultIds = resultIds;     
        return response;*/
        
    }   
    
    public SFM_WrapperDef2.SFM2_Rule cloneRule(List<String> entityIds, String entityType){
        SFM_WrapperDef2.SFM2_Rule ruleInfo;
        if(entityIds.size() == 1){


            List<SVMXC__ServiceMax_Processes__c> rulesList = new SFM_GetNamedExpressionList().queryRuleRecords(null, entityIds, true, entityType); 
            
            if(!rulesList.isEmpty()){
                ruleInfo = buildSFM2Rule(rulesList[0], entityType, false);
            
            }else{
                System.debug( System.LoggingLevel.ERROR, 'Requested entity does not exist. Rule Id=' + entityIds[0]);
                throw new SFM_DesignerUtils.ServicemaxNestedException( 'Record not exists for requested id.');
            }


        }

        return ruleInfo;
    }

    /**
     * This method is used to build SFM2_Rule wrapper structire for given servicemax process record.
     */
    public SFM_WrapperDef2.SFM2_Rule buildSFM2Rule( SVMXC__ServiceMax_Processes__c processRecord, String entityType, boolean isClone) {
        List<SVMXC__ServiceMax_Config_Data__c> configRecordsList;
        SFM_WrapperDef2.SFM2_Rule sfm2Rule = new SFM_WrapperDef2.SFM2_Rule();
        
        // Build entity details for servicemax process record.
        sfm2Rule.ruleDetail = buildEntityDetail( processRecord );
        if(isClone){
            sfm2Rule.ruleDetail.entityId = null;
        }
        sfm2Rule.sourceObject = processRecord.SVMXC__Source_Object_Name__c;
        sfm2Rule.objectAlias = processRecord.SVMXC__Target_Object_label__c;
        sfm2Rule.advanceExpression = processRecord.SVMXC__Advance_Expression__c;
        sfm2Rule.targetObject = processRecord.SVMXC__Target_Object_Name__c;
        sfm2Rule.message = processRecord.SVMXC__Parent_Error_Msg__c;
        sfm2Rule.questionId = processRecord.SVMXC__Question_Bank__c;
        sfm2Rule.questionName = processRecord.SVMXC__Question_Bank__r.SVMXC__Question__c;
        sfm2Rule.modeOfExecution = processRecord.SVMXC__Mode_Of_Execution__c;
       
        if(entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_expression) || entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_businessrule) || entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_formula)
            || entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_checklistCriteria) || entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_sectionCriteria) || entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_sectionEntryCriteria)){
            configRecordsList = processRecord.SVMXC__ServiceMax_Config_Data2__r;
        }else if(entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_mapping)){
            configRecordsList = processRecord.SVMXC__SVMX_Config_Data2__r;
        }

        // Build rule expression for servicemax process record and add it to sfm rule wrapper.
        sfm2Rule.expressionsList = expressionListWrapper(configRecordsList, entityType, isClone);

        return sfm2Rule;
    }

    public List<SFM_WrapperDef2.SFM2_RuleExpression> expressionListWrapper(List<SVMXC__ServiceMax_Config_Data__c> expressionConfigList, String entityType, boolean isClone){
        List<SFM_WrapperDef2.SFM2_RuleExpression> expressionWrapList = new List<SFM_WrapperDef2.SFM2_RuleExpression>();
        
        if(expressionConfigList != null && !expressionConfigList.isEmpty() ) {
            
            for( SVMXC__ServiceMax_Config_Data__c configDataRecord : expressionConfigList ) {
                expressionWrapList.add( buildSFM2RuleExpression(configDataRecord, entityType, isClone));
            }
        }

        return expressionWrapList;
    }
    
    /**
     * This method is used to nuild rule expression for given servicemax configuration record.
     */
    public SFM_WrapperDef2.SFM2_RuleExpression buildSFM2RuleExpression( SVMXC__ServiceMax_Config_Data__c configDataRecord, String entityType, boolean isClone) {

        SFM_WrapperDef2.SFM2_RuleExpression ruleExpression = null;
        
        if( configDataRecord != null ) {
            
            ruleExpression = new SFM_WrapperDef2.SFM2_RuleExpression();
            if(!isClone){
            ruleExpression.expressionId = configDataRecord.Id;
            }
            ruleExpression.configurationType = configDataRecord.SVMXC__Configuration_Type__c;
            ruleExpression.parameterType = configDataRecord.SVMXC__Parameter_Type__c;
            ruleExpression.sourceField = (entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_mapping)) ? configDataRecord.SVMXC__Source_Field_Name__c: configDataRecord.SVMXC__Field_Name__c;
            ruleExpression.targetField = configDataRecord.SVMXC__Target_Field_Name__c;
            ruleExpression.preference1 = configDataRecord.SVMXC__Preference_2__c;
            ruleExpression.preference2 = configDataRecord.SVMXC__Preference_3__c;
            ruleExpression.actionType = configDataRecord.SVMXC__Action_Type__c;
            ruleExpression.sequence = Integer.valueOf(configDataRecord.SVMXC__Sequence__c);
            ruleExpression.operator = configDataRecord.SVMXC__Operator__c;
            ruleExpression.processConfig = configDataRecord.SVMXC__Description__c;
            ruleExpression.metaData = configDataRecord.SVMXC__SM_Related_Info__c;
            ruleExpression.contextType = configDataRecord.SVMXC__Search_Object_Field_Type__c;
            ruleExpression.sourceFldDtaType = configDataRecord.SVMXC__Display_Type__c;

            /*
                For Standard Mappings parameter type is always null, hence setting it up based on the source field value
            */
            if(entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_mapping)){

                if(configDataRecord.SVMXC__Source_Field_Name__c != null){
                    ruleExpression.parameterType = 'Field Value';
                }else if(configDataRecord.SVMXC__Display_Value__c != null){
                    ruleExpression.parameterType = 'Value';
                    if(configDataRecord.SVMXC__Display_Value__c.startsWith('SVMX.') || SFM_DesignerUtils.supportedLiterals.contains(configDataRecord.SVMXC__Display_Value__c.toUpperCase())){
                       ruleExpression.parameterType = 'Constant';     
                    }
                }
            }
            ruleExpression.value = (entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_formula)) ? configDataRecord.SVMXC__Formula__c : configDataRecord.SVMXC__Operand__c;
            
            if( entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_mapping) ) {
                populateExpressionValue(ruleExpression, configDataRecord.SVMXC__Display_Value__c);
                if(configDataRecord.SVMXC__SM_Display_Value2__c != null){
                   ruleExpression.displayValue = configDataRecord.SVMXC__SM_Display_Value2__c;
                }else{
                    ruleExpression.displayValue = configDataRecord.SVMXC__Display_Value__c;
                }
            } else if( entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_expression)  || entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_businessrule) || entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_lkpConfig)
                        || entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_checklistCriteria) || entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_sectionCriteria) || entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_sectionEntryCriteria)) {
                String expressionValue = configDataRecord.SVMXC__Operand__c;
                populateExpressionValue(ruleExpression, expressionValue);

                if( entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_lkpConfig) && expressionValue != null ) {
                    if( expressionValue.equalsIgnoreCase('true') || expressionValue.equalsIgnoreCase('false') ) {
                        ruleExpression.parameterType = 'Value';
                    } else if( expressionValue.startsWith('SVMX.') ) {
                         ruleExpression.parameterType = 'Constant';
                    }
                }
            }
        }
        
        return ruleExpression;
    }
    
    /**
     * SFMDZ-684
     * This private method evaluate the value for literals/functions and populates value and function accordingly.
     * 
     * @param ruleExpression Instance of SFM2_RuleExpression to be populated with value and function name.
     * @param value String value to be evaluated and populated to rule expression.
     * 
     * @ServicemaxNestedException
     */
    private void populateExpressionValue( SFM_WrapperDef2.SFM2_RuleExpression ruleExpression, String value ) {
        
        System.debug( System.LoggingLevel.DEBUG, 'populateExpressionValue() - enter; value=' + value );
        
        // By default populate the value to rule expression.
        ruleExpression.value = value;
        
        try {
            if( value != null && value.trim().length() > 0 ) {
                
                // Check whether or not the value has the current record function/macro name.
                if( value.indexOf('.') != -1 && value.containsIgnoreCase( SFM_Consts.CURRENT_RECORD ) ) {
                   
                   String[] valueArray = value.split('\\.');
                   // Value array must have atleast 3 parts, Eg. SVMX, CURRENTRECORD/CURRENTRECORDHEADER and the value part.
                   if( valueArray.size() > 2 ) {
                       
                       ruleExpression.literalValue = valueArray[2];
                       
                       // Check for valid function name. Its posiblity to change these values from salesforce client or any other similar source.
                       if( !valueArray[1].equalsIgnoreCase( SFM_Consts.CURRENT_RECORD ) && !valueArray[1].equalsIgnoreCase( SFM_Consts.CURRENT_RECORD_HEADER ) ) {
                           
                           System.debug( System.LoggingLevel.ERROR, 'Unsupported function ' + valueArray[1] );
                           throw new SFM_DesignerUtils.ServicemaxNestedException( 'Unsupported function ' + valueArray[1] );
                       }
                       
                       // Populate the proper function name as per the macro name exists in the value field.
                       ruleExpression.value = (valueArray[1].equalsIgnoreCase( SFM_Consts.CURRENT_RECORD ) ) ? SFM_Consts.CURRENT_RECORD_FUNCTION : SFM_Consts.CURRENT_RECORD_HEADER_FUNCTION;
                   }
                } else if( value.containsIgnoreCase( 'LAST_N_DAYS') || value.containsIgnoreCase( 'NEXT_N_DAYS') ) {
                             
                    ruleExpression.value = value.containsIgnoreCase('LAST_N_DAYS') ? 'LAST_N_DAYS' : 'NEXT_N_DAYS';
                    if( value.indexOf(':') != -1 ) {
                        ruleExpression.literalValue = value.split(':')[1];            
                    }
                } else if( value.equalsIgnoreCase(SFM_Consts.SVMX_USERTRUNK) ) {

                    ruleExpression.value = SFM_Consts.USERTRUNK;
                } else if( value.equalsIgnoreCase(SFM_Consts.SVMX_NOW)) {
                    ruleExpression.value = SFM_Consts.NOW;
                } else if( value.equalsIgnoreCase(SFM_Consts.SVMX_CURRENTUSER)) {
                    ruleExpression.value = SFM_Consts.CURRENTUSER;
                } else if( value.equalsIgnoreCase(SFM_Consts.TODAY)) {
                    ruleExpression.value = SFM_Consts.TODAY.toLowerCase();
                } else if( value.equalsIgnoreCase(SFM_Consts.TOMORROW)) {
                    ruleExpression.value = SFM_Consts.TOMORROW.toLowerCase();
                } else if( value.equalsIgnoreCase(SFM_Consts.YESTERDAY)) {
                    ruleExpression.value = SFM_Consts.YESTERDAY.toLowerCase();
                } else if( value.equalsIgnoreCase(SFM_Consts.SVMX_OWNER)) {
                    ruleExpression.value = SFM_Consts.OWNER;
                } else if( value.equalsIgnoreCase(SFM_Consts.SVMX_SETNULL)){
                    ruleExpression.value = SFM_Consts.SETNULL;
                }
            }
            
        }
        finally {
            System.debug( System.LoggingLevel.DEBUG, 'populateExpressionValue() - exit; function=' + ruleExpression.value + ';value=' + ruleExpression.literalValue );
        }
    }
    
    /**
     * This method is used to create entity detail form the requested servicemax process record.
     */
    public SFM_WrapperDef2.SFM2_EntityDetail buildEntityDetail(SVMXC__ServiceMax_Processes__c processRecord ) {
        
        SFM_WrapperDef2.SFM2_EntityDetail entityDetail = null;
        
        if( processRecord != null ) {
            
            entityDetail = new SFM_WrapperDef2.SFM2_EntityDetail();
            
            entityDetail.entityId = processRecord.id;
            entityDetail.isStandard = processRecord.SVMXC__IsStandard__c;
            entityDetail.entityDescription = processRecord.SVMXC__Description__c;
            entityDetail.entityName = processRecord.SVMXC__Name__c;
            entityDetail.lastModifiedDate = String.valueOfGmt(processRecord.lastModifiedDate);
            entityDetail.createdDate = String.valueOfGmt(processRecord.CreatedDate);
            entityDetail.createdBy = processRecord.CreatedBy.Name;
            entityDetail.lastModifiedBy = processRecord.lastModifiedBy.Name;
            entityDetail.entitySubType = processRecord.SVMXC__Message_Type__c;
        }
        
        return entityDetail;
    }
}