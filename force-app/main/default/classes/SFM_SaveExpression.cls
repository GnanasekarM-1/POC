/* Security Scanned */
public with sharing class SFM_SaveExpression {
    public Map<String,Schema.Displaytype>  mapFieldDispType = new Map<String,Schema.Displaytype>();
    public Map<String, Schema.SObjectType> Allobjs = new Map<String, Schema.SObjectType>();
    public Map<String, Schema.SObjectField> FieldMap = new Map<String, Schema.SObjectField>();

    public SFM_saveExpression(){}   
    public SFM_WrapperDef.SFM_Response SFM_saveExpression(SFM_WrapperDef.SFM_Request_Expression ExpReq){
        Boolean response_success;
        String response_message;
        String response_tagId;
        Boolean s = false;
        String msg;
        String tid;
        SVMX_Debug  log = new SVMX_Debug();
        List<String> resultIds=new List<String>();
        List<SFM_WrapperDef.SFM_Expression> LstSFM_Expressions=ExpReq.expressions;
        List<SFM_WrapperDef.SFM_StringMap> stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        Map<string,list<SVMXC__ServiceMax_Config_Data__c>> MapNamedExpDetail= new Map<string,list<SVMXC__ServiceMax_Config_Data__c>>();
        Map<string,SVMXC__ServiceMax_Processes__c> MapNamedExp = new Map<string,SVMXC__ServiceMax_Processes__c>();
        list<string> namedExpressionId = new list<string>();
        list<SVMXC__ServiceMax_Processes__c >   LstnamedExpression = new list<SVMXC__ServiceMax_Processes__c >();   
        list<SVMXC__ServiceMax_Config_Data__c> LstexpressionDetails= new list<SVMXC__ServiceMax_Config_Data__c>();
        list<SVMXC__ServiceMax_Config_Data__c> LstexpressionDetailsexp= new list<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> expressionDetails = new list<SVMXC__ServiceMax_Config_Data__c>();
        List<SFM_WrapperDef.SFM_Expression> LstSFM_Exp = new List<SFM_WrapperDef.SFM_Expression>();
        log.login('SFM_saveExpression', 'SFM_saveExpression(SFM_WrapperDef.SFM_Request_Expression)');
        Savepoint sp;
        set<String> Ids=new set<String>();
        Map<String, Id> expRecType_Map = new Map<String, Id>();
        List<String> recTypeNames = new List<String>();
        SFM_Utils utils = new SFM_Utils();
        String UniqueProcessId;
        String exprId;
        String ObjectName;
        List<SVMXC__ServiceMax_Processes__c> uniquecheck = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC.SFM_validateExpression ValidateExpression = new SVMXC.SFM_validateExpression();
        SFM_WrapperDef.SFM_Response PResponse=new SFM_WrapperDef.SFM_Response();
        try
        {           
            recTypeNames.add('SVMXC__ServiceMax_Processes__c~SVMX Rule');
            recTypeNames.add('SVMXC__ServiceMax_Config_Data__c~Expressions');
            expRecType_Map = utils.getRecordTypes(recTypeNames);  
            
            PResponse=ValidateExpression.SFM_validateExpression(ExpReq);
            if(PResponse.success==true)
            {
                log.setlog('SAVEPOINT', 'Setting up savepoint before upserting');
                sp = Database.setSavepoint();//Setting up save point
               
                System.debug('LstSFM_Expressions ; '+LstSFM_Expressions);
                for(SFM_WrapperDef.SFM_Expression Expression: LstSFM_Expressions)
                {
                    System.debug('Expression.namedExpression.Id  : '+Expression.namedExpression.Id );
                    if(Expression.namedExpression.Id != null)
                    {
                        Ids.add(Expression.namedExpression.Id);
                         exprId=Expression.namedExpression.Id;
                         
                    }   
                    if(Expression != null && Expression.namedExpression != null && Expression.namedExpression.SVMXC__Source_Object_Name__c != null && Expression.namedExpression.SVMXC__Source_Object_Name__c.length() > 0 )
                        ObjectName = Expression.namedExpression.SVMXC__Source_Object_Name__c;
                }
                System.debug('ObjectName : '+ObjectName);
                 /* Building of Field Name,Field Type map - starts here */
                if( ObjectName != null && ObjectName != '')
                {
                    Allobjs = Schema.getGlobalDescribe();
                    String ObjectNameAPI = utils.getOriginalAPIName(ObjectName,Allobjs);// Required to do field describe
                    if(Allobjs.containskey(ObjectNameAPI))
                    {
                        FieldMap = Allobjs.get(ObjectNameAPI).getDescribe().fields.getMap();
                    }
                    if(FieldMap.size() > 0)
                    {
                        for(String FldMapKey :FieldMap.keyset())
                        {
                            Schema.DescribeFieldResult F = FieldMap.get(FldMapKey).getDescribe();
                            mapFieldDispType.put(F.getName(),F.getType());
                        }    
                    }
                }
                /* Building of Field Name,Field Type map - ends here */

                system.debug('exprId:'+exprId);
                String exprRecId = expRecType_Map.get('SVMXC__ServiceMax_Processes__c~SVMX Rule');  
                String exprDetailRecId = expRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions');    
                for(SFM_WrapperDef.SFM_Expression expinfo: ExpReq.expressions)
                   {
                       SVMXC__ServiceMax_Processes__c expressionHeader= expinfo.namedExpression;
                        
                        expressionHeader.RecordTypeId = exprRecId;
                        expressionHeader.SVMXC__Rule_Type__c = 'Named Expression';
                        if(PResponse!=null)
                        {
                            expressionHeader.SVMXC__Parent_Object_Criteria__c = PResponse.message;
                        }
                        
                        if(expressionHeader.SVMXC__ProcessID__c!=null ||expressionHeader.SVMXC__ProcessID__c!='')
                          {
                            expressionHeader.SVMXC__ProcessID__c=expressionHeader.SVMXC__ProcessID__c;
                          }
                          
                        
                        UniqueProcessId=expressionHeader.SVMXC__ProcessID__c;
                        system.debug('UniqueProcessId:'+UniqueProcessId); 
                        LstnamedExpression.add(expressionHeader);
                        system.debug('ExpressionDetailRecords'+ expinfo.expressionDetails);
                        expressionDetails.addAll(expinfo.expressionDetails);
                   }
                    
                    
                    if(LstnamedExpression!=null && LstnamedExpression.size()>0)
                    {
                        
                        uniquecheck=[Select Id, Name,SVMXC__Source_Object_Name__c, SVMXC__Name__c,SVMXC__SettingId__c,SVMXC__Description__c, SVMXC__Advance_Expression__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND SVMXC__ProcessID__c = :UniqueProcessId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        if(uniquecheck.size()>0)
                          {
                             if(uniquecheck[0].Id!=exprId)
                             {
                             
                             
                               system.debug('Entered false block');
                               response_success = false;
                               //response_message='Named expression cannot be saved as the process is not unique';
                               response_message= system.Label.SFM001_TAG179;
                             }
                             else
                             {
                                    System.debug('expression header save : '+LstnamedExpression);
                                    
                                   upsert LstnamedExpression; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                   for(SVMXC__ServiceMax_Processes__c p : LstnamedExpression)
                                   {
                                     resultIds.add(p.Id);
                                   }
                            
                                  for(SVMXC__ServiceMax_Config_Data__c expressDetail : expressionDetails)
                                   {
                                      SVMXC__ServiceMax_Config_Data__c fields = new SVMXC__ServiceMax_Config_Data__c();
                                      fields.RecordTypeId = exprDetailRecId;
                                      fields.SVMXC__Expression_Type__c = 'EXP_Named';
                                      fields.SVMXC__Field_Name__c=expressDetail.SVMXC__Field_Name__c;
                                      fields.SVMXC__Operator__c=expressDetail.SVMXC__Operator__c;
                                      fields.SVMXC__Operand__c=expressDetail.SVMXC__Operand__c;
                                      fields.SVMXC__Sequence__c=expressDetail.SVMXC__Sequence__c;
                                      fields.SVMXC__Expression_Rule__c=LstnamedExpression[0].Id;
                                      if(expressDetail.SVMXC__Field_Name__c != null && mapFieldDispType.get(expressDetail.SVMXC__Field_Name__c) != null)
                                          fields.SVMXC__Display_Type__c = String.valueOf(mapFieldDispType.get(expressDetail.SVMXC__Field_Name__c));
                                      
                                        //Added try catch block to avoid exception. Since Field Relationship Name & Object Name field may/may not be NULL in the request.
                                        try
                                        {
                                            system.debug(LoggingLevel.WARN, 'Field Datatype: ' + fields.SVMXC__Display_Type__c);
                                            if(fields.SVMXC__Display_Type__c != NULL && fields.SVMXC__Display_Type__c.length() > 0 && fields.SVMXC__Display_Type__c.toUpperCase() == 'REFERENCE' )
                                            {
                                                fields.SVMXC__Field_Relationship_Name__c = expressDetail.SVMXC__Field_Relationship_Name__c;
                                                fields.SVMXC__FKey_Name_Field__c = expressDetail.SVMXC__FKey_Name_Field__c;
                                            }
                                        }
                                        catch(Exception ex)
                                        {
                                            system.debug(LoggingLevel.WARN, 'Exception: ' + ex.getMessage());
                                        }
                                        
                                        LstexpressionDetails.add(fields);
                                    }                       
                                    
                                  if(exprId!=null)
                                  {
                                    
                                    LstexpressionDetailsexp=[Select SVMXC__Sequence__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Field_Name__c, SVMXC__Expression_Rule__c, Name, Id From SVMXC__ServiceMax_Config_Data__c where Recordtype.Name='Expressions' AND SVMXC__Expression_Type__c = 'EXP_Named' And SVMXC__Expression_Rule__c =:exprId];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                    if(LstexpressionDetailsexp.size()>0)
                                    
                                    delete LstexpressionDetailsexp; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                  }
                                  
                                  if(LstexpressionDetails!=null && LstexpressionDetails.size()>0)
                                      
                                        upsert LstexpressionDetails; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                
                                  for(SVMXC__ServiceMax_Processes__c p : LstnamedExpression)
                                  {
                                    namedExpressionId.add(p.Id);
                                    list<SVMXC__ServiceMax_Config_Data__c> LstTemp= new list<SVMXC__ServiceMax_Config_Data__c>();
                                    MapNamedExpDetail.put(p.Id,LstTemp);
                                    MapNamedExp.put(p.Id,p);
                    
                                  }             
                                  for(SVMXC__ServiceMax_Config_Data__c Oconf : LstexpressionDetails){
                                   if(MapNamedExpDetail.containsKey(Oconf.SVMXC__Expression_Rule__c))
                                   MapNamedExpDetail.get(Oconf.SVMXC__Expression_Rule__c).add(Oconf);
                                   }
        
                                  for(string Key : MapNamedExpDetail.keySet()){
                                  SFM_WrapperDef.SFM_Expression oSFM_Exp = new SFM_WrapperDef.SFM_Expression(MapNamedExp.get(Key),MapNamedExpDetail.get(Key));
                                  LstSFM_Exp.add(oSFM_Exp);
                                  }
                                  response_success = true;
                                
                             }
                             //else block
                          }
                        else
                         {
                             
                            upsert LstnamedExpression; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            for(SVMXC__ServiceMax_Processes__c p : LstnamedExpression){
                                resultIds.add(p.Id);
                                
                            }
                            system.debug('ResultIds'+ resultIds);
                      system.debug('ExpressionDetail'+ expressionDetails + 'Size' + expressionDetails.size());
                      system.debug('ExpressionDetailInfo'+ expressionDetails[0]);
                        for(SVMXC__ServiceMax_Config_Data__c expressDetail : expressionDetails)
                        {
                            SVMXC__ServiceMax_Config_Data__c fields = new SVMXC__ServiceMax_Config_Data__c();
                            fields.RecordTypeId = exprDetailRecId;
                            fields.SVMXC__Expression_Type__c = 'EXP_Named';
                            //system.debug('ExpressionDetailInfoField'+ expressDetail.SVMXC__Field_Name__c);
                            //system.debug('ExpressionDetailInfoOperator'+ expressDetail.SVMXC__Operator__c);
                            fields.SVMXC__Field_Name__c=expressDetail.SVMXC__Field_Name__c;
                            fields.SVMXC__Operator__c=expressDetail.SVMXC__Operator__c;
                            fields.SVMXC__Operand__c=expressDetail.SVMXC__Operand__c;
                            fields.SVMXC__Sequence__c=expressDetail.SVMXC__Sequence__c;
                            fields.SVMXC__Expression_Rule__c=LstnamedExpression[0].Id;
                            if(expressDetail.SVMXC__Field_Name__c != null && mapFieldDispType.get(expressDetail.SVMXC__Field_Name__c) != null)
                            {
                                fields.SVMXC__Display_Type__c = String.valueOf(mapFieldDispType.get(expressDetail.SVMXC__Field_Name__c));
                            }
                            
                            try
                            {
                                system.debug(LoggingLevel.WARN, 'Field Datatype: ' + fields.SVMXC__Display_Type__c);
                                if(fields.SVMXC__Display_Type__c != NULL && fields.SVMXC__Display_Type__c.length() > 0 && fields.SVMXC__Display_Type__c.toUpperCase() == 'REFERENCE' )
                                {
                                    fields.SVMXC__Field_Relationship_Name__c = expressDetail.SVMXC__Field_Relationship_Name__c;
                                    fields.SVMXC__FKey_Name_Field__c = expressDetail.SVMXC__FKey_Name_Field__c; 
                                }
                            }
                            catch(Exception ex)
                            {
                                system.debug(LoggingLevel.WARN, 'Exception: ' + ex.getMessage());
                            }
                            
                            LstexpressionDetails.add(fields);
                        }                       
                    
                 if(exprId!=null)
                   {
                       
                       LstexpressionDetailsexp=[Select SVMXC__Sequence__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Field_Name__c, SVMXC__Expression_Rule__c, Name, Id From SVMXC__ServiceMax_Config_Data__c where Recordtype.Name='Expressions' AND SVMXC__Expression_Type__c = 'EXP_Named' And SVMXC__Expression_Rule__c =:exprId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                       if(LstexpressionDetailsexp.size()>0)
                           
                       delete LstexpressionDetailsexp; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                   }
                   
                if(LstexpressionDetails!=null && LstexpressionDetails.size()>0)
                    
                    upsert LstexpressionDetails; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                for(SVMXC__ServiceMax_Processes__c p : LstnamedExpression){
                    namedExpressionId.add(p.Id);
                    
                   //if(!Ids.contains(p.Id)){
                     //resultIds.add(p.Id);
                   //}
                    list<SVMXC__ServiceMax_Config_Data__c> LstTemp= new list<SVMXC__ServiceMax_Config_Data__c>();
                    MapNamedExpDetail.put(p.Id,LstTemp);
                    MapNamedExp.put(p.Id,p);
                    
                }               
                for(SVMXC__ServiceMax_Config_Data__c Oconf : LstexpressionDetails){
                    if(MapNamedExpDetail.containsKey(Oconf.SVMXC__Expression_Rule__c))
                        MapNamedExpDetail.get(Oconf.SVMXC__Expression_Rule__c).add(Oconf);
                }
        
                for(string Key : MapNamedExpDetail.keySet()){
                    SFM_WrapperDef.SFM_Expression oSFM_Exp = new SFM_WrapperDef.SFM_Expression(MapNamedExp.get(Key),MapNamedExpDetail.get(Key));
                    LstSFM_Exp.add(oSFM_Exp);
                }
                response_success = true;
                            
                           }
                           //
                    }
                //comment   
                }
        
                else
                {
                    //response_message='Invalid expression';
                    response_message = system.Label.SFM001_TAG180;
                    response_success = false;
                }
        
}
   catch (DmlException ex)
        {
            log.setlog('ERROR', ex.getDmlMessage(0));
            log.setlog('ROLLBACK', 'When fails rollback data donot commit');
            Database.rollback(sp);//When fails rollback data donot commit
            response_success = false;
            response_message = ex.getDmlMessage(0);
            
        }
        catch (Exception ex)
        {
            log.setlog('ERROR', ex.getmessage());
            log.setlog('ROLLBACK', 'When fails rollback data donot commit');
            Database.rollback(sp);//When fails rollback data donot commit
            response_success = false;
            response_message = ex.getmessage();
        }
        log.logout();
        log.print();
        log.getlog();
        SFM_WrapperDef.SFM_Response oResponse=new SFM_WrapperDef.SFM_Response();
        oResponse.logMsg = log.getlog();
        oResponse.success = response_success;
        oResponse.message = response_message;
        oResponse.stringMap = stringMap;
        system.debug('FinalResultIds'+ resultIds);
        oResponse.resultIds = resultIds;//(s,msg,tid,stringMap,log.getlog(),resultIds);
        return oResponse;   
    }

    public SFM_WrapperDef2.SFM2_Rule saveRule(SFM_WrapperDef2.SFM2_Rule sfm_Rule, String entityType, Boolean isQuestionRule, COMM_AuditTrail.AuditData auditData){
        
        mapHeaderFieldValues(sfm_Rule, entityType, isQuestionRule, auditData);

        return sfm_Rule;
    }


    private void mapHeaderFieldValues(SFM_WrapperDef2.SFM2_Rule sfm_Rule, String entityType, Boolean isQuestionRule, COMM_AuditTrail.AuditData auditData){
        SVMXC__ServiceMax_Processes__c processRecord = new SVMXC__ServiceMax_Processes__c();
        Map<Integer, SVMXC__ServiceMax_Config_Data__c> expressionDetailSequenceMap; 
        Map<String, Schema.SObjectField> fieldResultMap;
        SFM_ValidateExpression expressionValidator;
        List<SVMXC__ServiceMax_Config_Data__c> configList;
        Boolean isNewRule = true;
        
        if(sfm_Rule.ruleDetail != null){
            SFM_WrapperDef2.SFM2_EntityDetail ruleDetail = sfm_Rule.ruleDetail;

            if(!isQuestionRule && SFM_DesignerUtils.isEntityNameAlreadyUsed(ruleDetail.entityName, entityType, ruleDetail.entityId)) {
                System.debug( System.LoggingLevel.ERROR, 'Name already exists');
                throw new SFM_DesignerUtils.ServicemaxNestedException( System.Label.SFM001_TAG685 );
            }

            if(ruleDetail.entityId != null ) {
                isNewRule = false;
                processRecord.Id = ruleDetail.entityId;
            }
            
            processRecord.SVMXC__Name__c = ruleDetail.entityName;
            /*
                SFMDZ-2243 : SFMDZ_‘Setting ID’ and ‘Setting Unique ID’ are not populated in the new designer
            */
            if(entityType.equals(SFM_DesignerUtils.entity_sectionEntryCriteria)){
                processRecord.SVMXC__SettingID__c = ruleDetail.entityName;
            }
            processRecord.SVMXC__Description__c = ruleDetail.entityDescription;
            processRecord.SVMXC__Message_Type__c = ruleDetail.entitySubType;

        }else {
           
           System.debug( System.LoggingLevel.ERROR, 'Rule detail not exists in request.');
           throw new SFM_DesignerUtils.ServicemaxNestedException( 'mapHeaderFieldValues() : Invalid request parameter.');
        }            
       
        processRecord.SVMXC__Mode_Of_Execution__c = sfm_Rule.modeOfExecution != null ? sfm_Rule.modeOfExecution: 'Interactive';
        processRecord.SVMXC__Source_Object_Name__c = sfm_Rule.sourceObject;
        processRecord.SVMXC__Target_Object_Name__c = sfm_Rule.targetObject;
        processRecord.SVMXC__Parent_Error_Msg__c = sfm_Rule.message;
        processRecord.SVMXC__Advance_Expression__c = sfm_Rule.advanceExpression;
        processRecord.SVMXC__Target_Object_label__c = sfm_Rule.objectAlias;
        Map<String, Map<String, Schema.SObjectField>> sObjectsFieldResultMap ;

        List<Schema.DescribeSobjectResult> sobjectDescribeResults;
        try{
            List<String> sObjectNames = new List<String>();
            if(sfm_Rule.sourceObject != null && sfm_Rule.sourceObject != ''){
               sObjectNames.add(sfm_Rule.sourceObject);
            }

            if(sfm_Rule.targetObject != null && sfm_Rule.targetObject != ''){
               sObjectNames.add(sfm_Rule.targetObject);
            }

            sobjectDescribeResults = SFM_DesignerUtils.sobjectsFieldsDescribe(sObjectNames);
            if(sobjectDescribeResults != null){
                sObjectsFieldResultMap = new Map<String, Map<String, Schema.SObjectField>>();
                for(Schema.DescribeSobjectResult sobjResult : sobjectDescribeResults){
                    sObjectsFieldResultMap.put(sobjResult.getName(), sobjResult.fields.getMap());
                }
            }
        }catch(exception ex){
            throw new SFM_DesignerUtils.ServicemaxNestedException('An error occurred while saving. Object does not exist.');
        }

        if(entityType.equals(SFM_DesignerUtils.entity_expression) || entityType.equals(SFM_DesignerUtils.entity_businessrule) || entityType.equals(SFM_DesignerUtils.entity_formula)
            || entityType.equals(SFM_DesignerUtils.entity_sectionEntryCriteria)){
            
            if(entityType.equals(SFM_DesignerUtils.entity_expression)){
                expressionValidator = new SFM_ValidateExpression();
                processRecord.RecordTypeId = SFM_DesignerUtils.recordTypeIdMap.get('SVMX Rule');
                processRecord.SVMXC__Rule_Type__c = 'Named Expression';
                processRecord.SVMXC__SettingID__c = '_' + processRecord.SVMXC__Name__c;
                
                if(processRecord.Id == null){
                    processRecord.SVMXC__ProcessID__c = SFM_DesignerUtils.generateUniqueId('EXP');
                }
            }else{
                String processIdKey = 'DVR';
                processRecord.RecordTypeId = SFM_DesignerUtils.recordTypeIdMap.get('Business Rule');
                if(entityType.equals(SFM_DesignerUtils.entity_formula)){
                   processIdKey = 'FLR';
                   processRecord.SVMXC__Rule_Type__c = 'Field Update Rule';
                }else if(entityType.equals(SFM_DesignerUtils.entity_sectionEntryCriteria)){
                    processIdKey = 'SEC';
                    processRecord.SVMXC__Rule_Type__c = 'Checklist_Section_Entry_Criteria';
                }
                
                if(processRecord.Id == null){
                  processRecord.SVMXC__ProcessID__c = SFM_DesignerUtils.generateUniqueId(processIdKey);     
                }
            }
        } else if(entityType.equals(SFM_DesignerUtils.entity_mapping)) {
            processRecord.SVMXC__Active__c = true;
            processRecord.RecordTypeId = SFM_DesignerUtils.recordTypeIdMap.get('Object Mapping');
            if(processRecord.Id == null){
                processRecord.SVMXC__MapID__c = SFM_DesignerUtils.generateUniqueId('MAP');
            }
        }

        Integer sequence = 0;
        if(sfm_Rule.expressionsList != null && !sfm_Rule.expressionsList.isEmpty()) {
            
            configList = new List<SVMXC__ServiceMax_Config_Data__c>();         

            
            for(SFM_WrapperDef2.SFM2_RuleExpression expressionDetail : sfm_Rule.expressionsList){
                
                SVMXC__ServiceMax_Config_Data__c configData = mapDetailFieldValues(expressionDetail, expressionDetail.expressionId, entityType);
                //expressionDetailSequenceMap.put(Integer.valueOf(configRec.SVMXC__Sequence__c), expressionDetail);

                if(entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_expression) || entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_businessrule) || entityType.equals(SFM_DesignerUtils.entity_formula)
                  || entityType.equals(SFM_DesignerUtils.entity_sectionEntryCriteria)) {
                    if(sObjectsFieldResultMap != null && sfm_Rule.sourceObject != null && sObjectsFieldResultMap.containskey(sfm_Rule.sourceObject)){
                        fieldResultMap = sObjectsFieldResultMap.get(sfm_Rule.sourceObject);
                        if(expressionDetail.sourceField != null && !Pattern.matches('^QB\\d{6}+(00D[a-zA-Z0-9]{15})?$', expressionDetail.sourceField)){
                    if(!fieldResultMap.containsKey(expressionDetail.sourceField)){
                         throw new SFM_DesignerUtils.ServicemaxNestedException( 'An error occurred while saving. Field does not exist : ' + expressionDetail.sourceField);
                    }

                    Schema.DescribeFieldResult fldDescribe = fieldResultMap.get(expressionDetail.sourceField).getDescribe();
                    configData.SVMXC__Display_Type__c = String.valueOf(fldDescribe.getType());

                    if(entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_expression) && expressionValidator != null){
                        expressionValidator.FieldApiLable.put(fldDescribe.getName(), fldDescribe.getLabel());
                        expressionValidator.mapFieldDispType.put(fldDescribe.getName(), fldDescribe.getType()); 
                        
                        if(fldDescribe.getType() == Schema.Displaytype.REFERENCE ) {
                            configData.SVMXC__Field_Relationship_Name__c = String.valueOf( fldDescribe.getRelationshipName() );
                            expressionValidator.mapFieldApiObjName.put(fldDescribe.getName(),fldDescribe.getReferenceTo()[0]);
                            expressionValidator.mapFieldRelName.put(fldDescribe.getName(),fldDescribe.getRelationshipName());
                                }
                            }
                        }
                    }

                }else if(entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_mapping)){
                    if(sObjectsFieldResultMap != null && sfm_Rule.targetObject != null && sObjectsFieldResultMap.containskey(sfm_Rule.targetObject)){
                        fieldResultMap = sObjectsFieldResultMap.get(sfm_Rule.targetObject);
                    Schema.DescribeFieldResult fldDescribe = fieldResultMap.get(expressionDetail.targetField).getDescribe();
                    if(fldDescribe.getType() == Schema.Displaytype.REFERENCE ) {
                       configData.SVMXC__Object_Name2__c = String.valueOf(fldDescribe.getReferenceTo()[0]);
                            if(configData.SVMXC__Object_Name2__c == 'RecordType'){
                                configData.SVMXC__Object_Name2__c = null;
                            }
                        }
                    }
                    expressionDetail.sequence = sequence++;
                    configData.SVMXC__Sequence__c = expressionDetail.sequence;
                }

                configList.add(configData);
            }

        }
        
        if(entityType.equals(SFM_DesignerUtils.entity_expression) && expressionValidator != null){ 
            processRecord.SVMXC__Parent_Object_Criteria__c = expressionValidator.getCriteria(processRecord.SVMXC__Source_Object_Name__c, processRecord.SVMXC__Advance_Expression__c, configList);
            if(processRecord.SVMXC__Parent_Object_Criteria__c != null && processRecord.SVMXC__Parent_Object_Criteria__c == 'ERROR'){
                throw new SFM_DesignerUtils.ServicemaxNestedException('An error occurred while saving: ' + System.Label.SFM001_TAG180);
            }
        }

        Savepoint sPoint = Database.setSavepoint();

        try{
            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(processRecord, COMM_SecurityUtils.Access.Upsertable)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            } 

            upsert processRecord;

            // Create audit tails on expression/DVR/Formula/Mapping creation or update.
            COMM_AuditTrail.AuditTrailInfo auditTrailInfo = new COMM_AuditTrail.AuditTrailInfo();
            auditTrailInfo.internalId = processRecord.Id;
            auditTrailInfo.actionType = isNewRule ? System.Label.AUDIT001_TAG009 : System.Label.AUDIT001_TAG010;
            // Populate entity type and application depending on entity type.
            if( entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_expression) ) {
                auditTrailInfo.application = System.Label.AUDIT001_TAG003;
                auditTrailInfo.entityName = System.Label.AUDIT001_TAG003;
            } else if( entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_businessrule) ) {
                auditTrailInfo.application = System.Label.AUDIT001_TAG005;
                auditTrailInfo.entityName = System.Label.AUDIT001_TAG005;
            } else if( entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_formula) ) {
                auditTrailInfo.application = System.Label.AUDIT001_TAG006;
                auditTrailInfo.entityName = System.Label.AUDIT001_TAG006;
            } else if( entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_mapping) ) {
                auditTrailInfo.application = System.Label.AUDIT001_TAG004;
                auditTrailInfo.entityName = System.Label.AUDIT001_TAG004;
            }
            // Populate action text depending on the entity type.
            if( entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_expression) ) {
                auditTrailInfo.action = isNewRule ? System.Label.AUDIT001_TAG037 + sfm_Rule.ruleDetail.entityName : System.Label.AUDIT001_TAG038 + sfm_Rule.ruleDetail.entityName;
            } else if( entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_businessrule) ) {
                auditTrailInfo.action = isNewRule ? System.Label.AUDIT001_TAG043 + sfm_Rule.ruleDetail.entityName : System.Label.AUDIT001_TAG044 + sfm_Rule.ruleDetail.entityName;
            } else if( entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_formula) ) {
                auditTrailInfo.action = isNewRule ? System.Label.AUDIT001_TAG046 + sfm_Rule.ruleDetail.entityName : System.Label.AUDIT001_TAG047 + sfm_Rule.ruleDetail.entityName;
            } else if( entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_mapping) ) {
                auditTrailInfo.action = isNewRule ? System.Label.AUDIT001_TAG040 + sfm_Rule.ruleDetail.entityName : System.Label.AUDIT001_TAG041 + sfm_Rule.ruleDetail.entityName;
            }
            COMM_AuditTrail.getInstance().logAudit(auditTrailInfo, auditData);
            sfm_Rule.ruleDetail.entityId = processRecord.Id;
            expressionDetailSequenceMap = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();

            if(configList != null && !configList.isEmpty()){
                
                for(SVMXC__ServiceMax_Config_Data__c configRec : configList){
                    
                    expressionDetailSequenceMap.put(Integer.valueOf(configRec.SVMXC__Sequence__c), configRec);
                    
                    if(entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_expression) || entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_businessrule) || entityType.equals(SFM_DesignerUtils.entity_formula)
                        || entityType.equals(SFM_DesignerUtils.entity_sectionEntryCriteria)){
                        configRec.SVMXC__Expression_Rule__c = processRecord.Id;
                    }else if(entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_mapping)){
                        configRec.SVMXC__MapID__c = processRecord.Id;
                        configRec.SVMXC__Sequence__c = null;
                    }
                }

                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(expressionDetailSequenceMap.values(), COMM_SecurityUtils.Access.Upsertable)){
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                } 
                
                upsert expressionDetailSequenceMap.values();
            }

            Set<Id> detailIds = new Set<Id>();
            if(sfm_Rule.expressionsList != null && !sfm_Rule.expressionsList.isEmpty()){
               
               for(SFM_WrapperDef2.SFM2_RuleExpression expressionDetail : sfm_Rule.expressionsList){
                    
                    if(expressionDetailSequenceMap != null && expressionDetailSequenceMap.containsKey(expressionDetail.sequence)){
                        expressionDetail.expressionId = expressionDetailSequenceMap.get(expressionDetail.sequence).Id;
                        
                        if(entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_mapping)){
                            expressionDetail.sequence = null;
                        }

                        detailIds.add(expressionDetail.expressionId);
                    }
                }
            }

            if(processRecord.Id != null ) {

                if(!COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }

                SVMXC__ServiceMax_Processes__c ruleRecord = [SELECT Id, (SELECT Id FROM SVMXC__ServiceMax_Config_Data2__r WHERE Id NOT IN : detailIds AND Recordtype.Name != 'Schedule Detail'),
                                                                (SELECT Id FROM SVMXC__SVMX_Config_Data2__r WHERE Id NOT IN : detailIds) FROM SVMXC__ServiceMax_Processes__c WHERE Id =: processRecord.Id];
                
                if(!ruleRecord.SVMXC__ServiceMax_Config_Data2__r.isEmpty()){
                    delete ruleRecord.SVMXC__ServiceMax_Config_Data2__r;
                }

                if(!ruleRecord.SVMXC__SVMX_Config_Data2__r.isEmpty()){
                    delete ruleRecord.SVMXC__SVMX_Config_Data2__r;
                }
            }
        
        }        
        
        catch( DmlException e ) {
        

            Database.rollback( sPoint );
            
            System.debug( System.LoggingLevel.ERROR, 'Failed to upsert rule');
            throw e;
        }
        
        catch( Exception e ) {
            
            Database.rollback( sPoint );
            
            System.debug( System.LoggingLevel.ERROR, 'Failed to save rule');
            throw e;
        }
        
        finally {
            System.debug( System.LoggingLevel.DEBUG, 'saveRule() - exit');
        }    
        
        
    }

    public SVMXC__ServiceMax_Config_Data__c mapDetailFieldValues(SFM_WrapperDef2.SFM2_RuleExpression expressionDetail, String expId, String entityType){
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        if(expId != null){
          configData.Id = expId;
        }
        configData.SVMXC__Action_Type__c = 'Set Value';
        configData.SVMXC__Configuration_Type__c = expressionDetail.configurationType;
        configData.SVMXC__Parameter_Type__c = expressionDetail.parameterType;
        configData.SVMXC__Target_Field_Name__c = expressionDetail.targetField;
        configData.SVMXC__Preference_2__c = expressionDetail.preference1;
        configData.SVMXC__Preference_3__c = expressionDetail.preference2;
        configData.SVMXC__Sequence__c = expressionDetail.sequence;
        configData.SVMXC__Operator__c = expressionDetail.operator;
        configData.SVMXC__Search_Object_Field_Type__c = expressionDetail.contextType;
        configData.SVMXC__Description__c = expressionDetail.processConfig;
        configData.SVMXC__Display_Type__c = expressionDetail.sourceFldDtaType;
        if(entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_mapping) ) {
            if(!expressionDetail.parameterType.equalsIgnoreCase('Field Value')){
                configData.SVMXC__Display_Value__c = calculateFieldValue(configData, expressionDetail, entityType);
                if(expressionDetail.sourceFldDtaType.equalsIgnoreCase('REFERENCE') && expressionDetail.parameterType.equalsIgnoreCase('Value')){
                    configData.SVMXC__SM_Display_Value2__c = expressionDetail.displayValue;
                    configData.SVMXC__Internal_Value__c = configData.SVMXC__Display_Value__c;
                    if(expressionDetail.targetField == 'RecordTypeId'){
                        configData.SVMXC__Display_Value__c = expressionDetail.displayValue;
                        configData.SVMXC__Internal_Value__c = null;
                    }
                }
            }
            if(expressionDetail.parameterType.equalsIgnoreCase('Field Value')){
                configData.SVMXC__Display_Value__c = null;
            }
            configData.RecordTypeId = SFM_DesignerUtils.recordTypeIdMap.get('Field Mapping');
            configData.SVMXC__Source_Field_Name__c = expressionDetail.sourceField;
            configData.SVMXC__Active__c = true;
        }else{
            configData.SVMXC__Field_Name__c = expressionDetail.sourceField;
            if(entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_formula)){
              configData.SVMXC__Formula__c = expressionDetail.value;
              configData.SVMXC__SM_Related_Info__c = expressionDetail.metaData;
              configData.RecordTypeId = SFM_DesignerUtils.recordTypeIdMap.get('Field Updates');
              configData.SVMXC__Expression_Type__c = 'Field_Update_Rule'; 
            } else {
              configData.SVMXC__Operand__c = calculateFieldValue(configData, expressionDetail, entityType);
              configData.RecordTypeId = SFM_DesignerUtils.recordTypeIdMap.get('Expressions');
            
              if(entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_expression)){
                configData.SVMXC__Expression_Type__c = 'EXP_Named';
              }else if(entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_businessrule) || entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_checklistCriteria)
                    || entityType.equals(SFM_DesignerUtils.entity_sectionEntryCriteria)){
                configData.SVMXC__Expression_Type__c = 'Business_Rule'; 
              }else{
                  if(configData.SVMXC__Search_Object_Field_Type__c != null)
                      configData.SVMXC__Expression_Type__c = 'SRCH_Object_Fields'; 
                  else{

                      if(entityType == 'SRCH_OBJECT'){
                          configData.SVMXC__Expression_Type__c = 'LKUP_Prefilter_Criteria'; 
                      }else{
                          configData.SVMXC__Expression_Type__c = 'LKUP_Criteria'; 
                      }
                  }
              }  
            }
         
        }

        return configData;

    }

    /**
     * SFMDZ-684
     * This method is used to populate expression display value from the request to the config data object. 
     * If the request is to save functions Current Record & Current Record Header the value will be reconstructed as 
     * SVMX.CURRENTRECORD & SVMX.CURRENTRECORDHEADER accordingly.
     * 
     * @param configData Instance of ServiceMax_Config_Data object to which value to be populated.
     * @param expressionDetail Request expression details from which function and values are consumed to reconstruct the display value.
     * 
     * @ServicemaxNestedException
     */
    private String calculateFieldValue(SVMXC__ServiceMax_Config_Data__c configData, SFM_WrapperDef2.SFM2_RuleExpression expressionDetail, String entitytype) {
        
        System.debug(System.LoggingLevel.DEBUG, 'calculateFieldValue() - enter');
        
        // By default set the value to display value field.
        String retValue = expressionDetail.value;
        try {
            
            if( expressionDetail.value != null && expressionDetail.value.trim().length() > 0 ) {
                
                //Check whether or not the expression is of type Current Record or Current Record Header.
                if( expressionDetail.value.containsIgnoreCase( SFM_Consts.CURRENT_RECORD_FUNCTION ) ) {
                
                    // Check for valid functions name. throw ServicemaxNestedException if the function names are invalid.
                    if( !expressionDetail.value.equalsIgnoreCase( SFM_Consts.CURRENT_RECORD_FUNCTION ) 
                       && !expressionDetail.value.equalsIgnoreCase( SFM_Consts.CURRENT_RECORD_HEADER_FUNCTION ) ) {
                        
                        System.debug( System.LoggingLevel.ERROR, 'Unsupported function ' + expressionDetail.value );
                        throw new SFM_DesignerUtils.ServicemaxNestedException( 'Unsupported function ' + expressionDetail.value);
                    }
                    
                    // Check for valid value for the function 'Current Record' or 'Current Record Header'.
                    if( expressionDetail.literalValue == null || expressionDetail.literalValue.trim().length() == 0 ) {
                        
                        System.debug( System.LoggingLevel.ERROR, 'Invalid value "' + expressionDetail.literalValue + '" for function ' + expressionDetail.value );
                        throw new SFM_DesignerUtils.ServicemaxNestedException( 'Invalid value for function ' + expressionDetail.value);
                    }
                    
                    // Create macro name for requested function and populate the concatenated value to Display Value field.
                    String functionName =  (expressionDetail.value.equalsIgnoreCase( SFM_Consts.CURRENT_RECORD_FUNCTION ) ) 
                        ? SFM_Consts.SVMX_CURRENT_RECORD 
                        : SFM_Consts.SVMX_CURRENT_RECORD_HEADER;
                    
                    retValue = functionName + '.' + expressionDetail.literalValue;
                } else if( expressionDetail.value.equalsIgnoreCase('LAST_N_DAYS') || expressionDetail.value.equalsIgnoreCase('NEXT_N_DAYS') ) {
                    
                    if( expressionDetail.literalValue != null && expressionDetail.literalValue.trim().length() != 0 ) {
                        
                        retValue = expressionDetail.value + ':' + expressionDetail.literalValue;
                    } else {
                        System.debug( System.LoggingLevel.ERROR, 'Missing number of days for literal ' + expressionDetail.value );
                        throw new SFM_DesignerUtils.ServicemaxNestedException( 'Bad request. Number of days missing for literal.');
                    }
                } else if(expressionDetail.value.equalsIgnoreCase(SFM_Consts.USERTRUNK)){

                    retValue = SFM_Consts.SVMX_USERTRUNK;
                } else if(expressionDetail.value.equalsIgnoreCase(SFM_Consts.CURRENTUSER)){

                    retValue = SFM_Consts.SVMX_CURRENTUSER;
                } else if(expressionDetail.value.equalsIgnoreCase(SFM_Consts.TODAY)){
                    retValue = SFM_Consts.TODAY;
                    if(entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_lkpConfig) || entityType.equalsIgnoreCase('SRCH_CRITERIA') || entityType.equalsIgnoreCase('SRCH_OBJECT')){
                        retValue = retValue.toUpperCase();
                    }
                } else if(expressionDetail.value.equalsIgnoreCase(SFM_Consts.TOMORROW)){
                    retValue = SFM_Consts.TOMORROW;
                    if(entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_lkpConfig) || entityType.equalsIgnoreCase('SRCH_CRITERIA') || entityType.equalsIgnoreCase('SRCH_OBJECT')){
                        retValue = retValue.toUpperCase();
                    }
                } else if(expressionDetail.value.equalsIgnoreCase(SFM_Consts.YESTERDAY)){
                    retValue = SFM_Consts.YESTERDAY;
                    if(entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_lkpConfig) || entityType.equalsIgnoreCase('SRCH_CRITERIA') || entityType.equalsIgnoreCase('SRCH_OBJECT')){
                        retValue = retValue.toUpperCase();
                }      
                } else if(expressionDetail.value.equalsIgnoreCase(SFM_Consts.Now)){
                    retValue = SFM_Consts.Now;
                    if(entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_lkpConfig) || entityType.equalsIgnoreCase('SRCH_CRITERIA') || entityType.equalsIgnoreCase('SRCH_OBJECT')){
                        retValue = SFM_Consts.SVMX_NOW;
                    }
                } else if(expressionDetail.value.equalsIgnoreCase(SFM_Consts.OWNER)){
                    retValue = SFM_Consts.SVMX_OWNER;
                } else if(expressionDetail.value.equalsIgnoreCase(SFM_Consts.SETNULL)){
                    retValue = SFM_Consts.SVMX_SETNULL;
                }
            }
        }
        finally {
            System.debug(System.LoggingLevel.DEBUG, 'calculateFieldValue() - exit');
        }
       
        return retValue;
    }
}