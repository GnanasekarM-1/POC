/* Security Scanned */
public with sharing class SFM_CheckListUtils {
    
    static final String DISPATCH_STATUS_COMPLETE = 'Complete';
    public Map<String, Schema.SObjectField> fieldDescribeMap;
    public I18N_TranslationDelivery objTranslnUtil;
    public List<sObject> HeaderSobjList;
    public String objectAPIName;


    public SVMXC.SFM_WrapperDef.SFM_Response SFM_GetListOfChecklist(SFM_WrapperDef.SFM_Request request){
        System.debug(LoggingLevel.WARN, 'Processing SFM_GetListOfChecklist() request');
        SVMXC.SFM_WrapperDef.SFM_Response response = new SVMXC.SFM_WrapperDef.SFM_Response();
        Map<Id, SVMXC.SFM_WrapperDef.SFM_ChecklistInfo> checkListProcessMap = new Map<Id, SVMXC.SFM_WrapperDef.SFM_ChecklistInfo>();
        response.stringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();       
        response.success = true;
        String recordId = '';
        String objectAPIName = '';
        system.debug('Request  : ' + Request);
        try{
            if(request != null && request.stringMap != null){
                for(SVMXC.SFM_WrapperDef.SFM_StringMap objStringMap : request.stringMap){
                    if(objStringMap.key != null && objStringMap.key.toUpperCase() == 'RECORDID' && objStringMap.value != null){
                        recordId = objStringMap.value;
                        objectAPIName = findObjectAPIName(recordId);
                        
                        if (objectAPIName != null && objectAPIName !='') {
                            //Added one more field "SVMXC__Process__r.SVMXC__Page_Layout__c" queried for the story BAC-3744
                            
                            List<SVMXC__ServiceMax_Processes__c> checkListProcessList = [SELECT SVMXC__Type__c,SVMXC__Submodule__c,SVMXC__Source_Object_Name__c,SVMXC__Node_Source_Object_API__c,SVMXC__Process__c,SVMXC__Process__r.SVMXC__ProcessID__c,SVMXC__Process__r.SVMXC__Name__c,SVMXC__Process__r.SVMXC__Description__c, SVMXC__Process__r.SVMXC__Page_Layout__c
                                                                                            FROM SVMXC__ServiceMax_Processes__c WHERE (SVMXC__Source_Object_Name__c =: objectAPIName OR SVMXC__Node_Source_Object_API__c =:objectAPIName) AND SVMXC__Record_Type_Name__c = 'Process Node Objects' AND SVMXC__Process__r.SVMXC__Purpose__c='CHECKLIST' AND SVMXC__Process__r.SVMXC__Dispatch_Process_Status__c =: DISPATCH_STATUS_COMPLETE];//SDL-SVMX-FLS-NOT-ENFORCED-META-DATA                
                            //DateTime firstTime ; //Commented this code as this is not needed and causing issue BAC-4038
                            if(checkListProcessList != null && checkListProcessList.size() > 0)
                            {   //firstTime = System.now(); //Commented this code as this is not needed and causing issue BAC-4038
                               checkListProcessList = Qualify(checkListProcessList,recordId);
                            }
                            //Added below else block for fixing issue BAC-4038
                            else{
                                response.success = false;
                                response.message = System.Label.SFM002_TAG260; //No checklist process is configured
                                return response;
                            }
                            //long  timeDiff = System.now().getTime() - firstTime.getTime(); //Commented this code as this is not needed and causing issue BAC-4038
                            //system.debug('timeDiff  : ' + timeDiff); //Commented this code as this is not needed and causing issue BAC-4038
                           
                            //-------------Added by Manish for translating list of checklist process--------------//
                            Set<String> setProcessId = new Set<String>();
                            for(SVMXC__ServiceMax_Processes__c objProNode : checkListProcessList){
                                if(objProNode.SVMXC__Process__c != null)
                                    setProcessId.add(objProNode.SVMXC__Process__c);
                            }
                            List<SVMXC__ServiceMax_Processes__c> lstProcess = new List<SVMXC__ServiceMax_Processes__c>();
                            if(setProcessId.size() > 0){
                                
                                lstProcess = [SELECT Id, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Tag_Keys__c,  SVMXC__Parent_Error_Msg__c, SVMXC__Child_Error_Msg__c, SVMXC__Confirmation_Message__c, SVMXC__Module__c, SVMXC__Module__r.SVMXC__ProcessID__c, SVMXC__Record_Type_Name__c, SVMXC__Rule_Type__c FROM SVMXC__ServiceMax_Processes__c WHERE Id IN: setProcessId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                
                                List<String> lstTagKeys = new List<String>();
                                for(SVMXC__ServiceMax_Processes__c objProc : lstProcess){
                                    if(objProc.SVMXC__Tag_Keys__c != null && objProc.SVMXC__Tag_Keys__c.length() > 0)
                                        lstTagKeys.add(objProc.SVMXC__Tag_Keys__c);
                                }
                                if(lstTagKeys.size() > 0){
                                    objTranslnUtil = new I18N_TranslationDelivery(lstTagKeys, UserInfo.getLanguage());
                                    lstProcess = objTranslnUtil.SVMX_GetProcessTranslation(lstProcess);
                                }
                            }
                            //-----------------------------------------------------------------------------------//
                            
                            for(SVMXC__ServiceMax_Processes__c objCheckPro : lstProcess){
                                SVMXC.SFM_WrapperDef.SFM_ChecklistInfo objChecklistInfo = new SVMXC.SFM_WrapperDef.SFM_ChecklistInfo();
                                objChecklistInfo.recordId = recordId;
                                objChecklistInfo.processId = objCheckPro.SVMXC__ProcessID__c;
                                objChecklistInfo.processName = objCheckPro.SVMXC__Name__c;
                                objChecklistInfo.status = 'Qualified';
                                objChecklistInfo.targetId = '';
                                objChecklistInfo.description = objCheckPro.SVMXC__Description__c;
                                objChecklistInfo.completionDate = null;
                                objChecklistInfo.sfProcessId = objCheckPro.id;
                                checkListProcessMap.put(objCheckPro.id, objChecklistInfo);
                            }
                            /*
                            for(SVMXC__ServiceMax_Processes__c checkListProcess : checkListProcessList){
                                SVMXC.SFM_WrapperDef.SFM_ChecklistInfo checklistInfo = new SVMXC.SFM_WrapperDef.SFM_ChecklistInfo(
                                    recordId,
                                    checkListProcess.SVMXC__Process__r.SVMXC__ProcessID__c,
                                    checkListProcess.SVMXC__Process__r.SVMXC__Name__c,
                                    'Qualified',
                                    '',
                                    checkListProcess.SVMXC__Process__r.SVMXC__Description__c,
                                    null,
                                    checkListProcess.SVMXC__Process__c);
                                checkListProcessMap.put(checkListProcess.SVMXC__Process__c, checklistInfo);
                            }  */     
                        }
                        //TODO: Remove any template that transaction does not qualify for
                        
                        for(SVMXC__Checklist__c cklsRecord : [SELECT Id,SVMXC__ChecklistProcessID__c,SVMXC__ChecklistProcessID__r.SVMXC__ProcessID__c,SVMXC__ChecklistProcessID__r.SVMXC__Name__c,SVMXC__Status__c,SVMXC__ChecklistProcessID__r.SVMXC__Description__c,SVMXC__What_Id__c,SVMXC__Completed_On__c,SVMXC__Completed_By__r.name,SVMXC__SM_Sequence__c  FROM SVMXC__Checklist__c WHERE SVMXC__What_Id__c =: recordId AND (SVMXC__SM_Sequence__c =1 OR SVMXC__SM_Sequence__c  = null)]) 
                        {
                            //System.debug('cklsRecord : ' +cklsRecord);
                            //Ignore records where we do not have a qualified template
                            if (checkListProcessMap.containsKey(cklsRecord.SVMXC__ChecklistProcessID__c) && checkListProcessMap.get(cklsRecord.SVMXC__ChecklistProcessID__c) != null) {
                                SVMXC.SFM_WrapperDef.SFM_ChecklistInfo checklistInfo = new SVMXC.SFM_WrapperDef.SFM_ChecklistInfo();
                                checklistInfo.recordId = cklsRecord.SVMXC__What_Id__c;
                                checklistInfo.processId = cklsRecord.SVMXC__ChecklistProcessID__r.SVMXC__ProcessID__c;
                                checklistInfo.status = cklsRecord.SVMXC__Status__c;
                                checklistInfo.targetId = cklsRecord.Id;
                                checklistInfo.completionDate = cklsRecord.SVMXC__Completed_On__c;
                                checklistInfo.sfProcessId = cklsRecord.SVMXC__ChecklistProcessID__c;
                                //checklistInfo.completedBy = cklsRecord.SVMXC__Completed_By__r.name;
                                checklistInfo.processName = checkListProcessMap.get(cklsRecord.SVMXC__ChecklistProcessID__c).processName;
                                checklistInfo.description = checkListProcessMap.get(cklsRecord.SVMXC__ChecklistProcessID__c).description;
                                checkListProcessMap.put(cklsRecord.Id,checklistInfo);
                            }
                        }
                    }
                }
            }
            else{
                System.debug(LoggingLevel.WARN, 'Invalid Request for SFM_GetListOfChecklist method');
                response.success = false;
                return response;
            }
            
            //------Start-----below code is moved inside the try block for error handling for the story BAC-4426
            System.debug('Size of the checkListProcessMap : ' +checkListProcessMap.size());
            if(checkListProcessMap.size() > 0) {
                response.lstChecklistInfo = checkListProcessMap.values();
                if(HeaderSobjList != null && !HeaderSobjList.isEmpty()){
                    
                    Map<String,SFM_WrapperDef.SFM_StringFieldMap> fieldMapRecordMap = new Map<String,SFM_WrapperDef.SFM_StringFieldMap>();
                    sObject sObjectRecord = HeaderSobjList[0];
                    Map<String,String> relatedFieldsMap = new Map<String,String>();
                    SFM_ValidateExpression validateExpression = new SFM_ValidateExpression();
                    Set<String> relatedFieldsSet = new Set<String>();
                    
                    for(String sObjFieldTypeRec : fieldDescribeMap.keySet()){
                        Schema.DescribeFieldResult fieldDescribeResult = fieldDescribeMap.get(sObjFieldTypeRec).getDescribe();   
                        // Here we are checking fields are accessible or not
                        //-----Start----- Added for Defect BAC-3390 : Rajat
                        //Added one more condition here !setFieldAPINames.contains(fieldDescribeResult.getName()) for the story BAC-3744
                        if(!fieldDescribeResult.isAccessible() || !setFieldAPINames.contains(fieldDescribeResult.getName())) {      
                            continue;
                        }//-----End------
                        SFM_WrapperDef.SFM_StringFieldMap fieldMapRecord = new SFM_WrapperDef.SFM_StringFieldMap();
                        fieldMapRecord.key =  fieldDescribeResult.getName();//sObjFieldTypeRec;
                        fieldMapRecord.value = (sObjectRecord.get(sObjFieldTypeRec) != null)? String.valueOf(sObjectRecord.get(sObjFieldTypeRec)): null;
                        fieldMapRecord.ftype = String.valueOf(fieldDescribeResult.getType());
                        //Jaysukh added for dynamic checklist response
                         if(fieldDescribeResult.getType() == Schema.Displaytype.Picklist)
                         {
                            fieldMapRecord.picklistLabelValue = new List<SFM_WrapperDef.SFM_StringMap>();
                            List<Schema.PicklistEntry> lstPicklistEntry = fieldDescribeResult.getPicklistValues();
                            for(Schema.PicklistEntry objPicklistEntry : lstPicklistEntry){
                               if(objPicklistEntry.isActive())
                               {
                                   SFM_WrapperDef.SFM_StringMap pickListkeyValue = new SFM_WrapperDef.SFM_StringMap();
                                   pickListkeyValue.key = objPicklistEntry.getLabel();
                                   pickListkeyValue.value = objPicklistEntry.getValue();
                                   fieldMapRecord.picklistLabelValue.add(pickListkeyValue);  
                               }
                            }
                          }
                        
                        
                        if(fieldMapRecord.ftype.equalsIgnoreCase('REFERENCE') &&  fieldMapRecord.value != null){
                            String relatedField = validateExpression.getNameFieldFromReferenceType(null, fieldDescribeResult.getReferenceTo()[0], fieldDescribeResult.getRelationshipName());
                            String relatedObjName = fieldDescribeResult.getRelationshipName();
                            if(relatedField != null){
                                System.debug(LoggingLevel.INFO, 'relatedField ' + relatedField + ' sObjFieldTypeRec : ' + sObjFieldTypeRec);
                                //String relatedObjName = String.valueOf(fieldDescribeResult.getReferenceTo()[0]);
                                List<String> fieldSplitString = relatedField.split('\\.');
                                relatedFieldsSet.add(relatedField);
                                
                                relatedObjName = relatedObjName + '-'  + fieldSplitString[1];
    
                                System.debug(LoggingLevel.INFO, 'relatedObjName ' + relatedObjName);
                                relatedFieldsMap.put(sObjFieldTypeRec, relatedObjName);
                            }
                        } 
    
                        if(fieldDescribeResult.isAccessible()){
                            fieldMapRecordMap.put(sObjFieldTypeRec, fieldMapRecord); 
                        }
                    }
    
                    String queryFields='';
                    for (String field : relatedFieldsSet) {
                        if (queryFields.length()>0) {
                            queryFields += ',';
                        }
                        queryFields += field;
                    }   
    
                    if(queryFields != '' && objectAPIName != null){
                        Id targetId =  sObjectRecord.Id;
                        List<sObject> sObjectList = Database.query('SELECT ' + queryFields + ' FROM ' + objectAPIName + ' WHERE Id = : targetId');
                        if(!sObjectList.isEmpty())
                            sObjectRecord = sObjectList[0];
    
                        for(String sObjFieldTypeRec : relatedFieldsMap.keySet()){
                            SFM_WrapperDef.SFM_StringFieldMap fieldMapRecord = fieldMapRecordMap.get(sObjFieldTypeRec);
                            String relatedFieldDetail = relatedFieldsMap.get(sObjFieldTypeRec);
                            List<String> fieldSplitString = relatedFieldDetail.split('-');
                            System.debug(LoggingLevel.INFO, 'fieldSplitString ' + fieldSplitString);
                            sObject relatedObj = sObjectRecord.getSobject(fieldSplitString[0]);
                            fieldMapRecord.fieldsToNull = (relatedObj != null && relatedObj.get(fieldSplitString[1]) != null)? String.valueOf(relatedObj.get(fieldSplitString[1])): null;
                        }                        
                    }
                    response.stringFieldMap = fieldMapRecordMap.values();
                }
            }
            //------End-----above code is moved inside the try block for error handling for the story BAC-4426
        }
        catch (QueryException qex){
            response.success = false;
            response.message = qex.getMessage();
            System.debug(LoggingLevel.ERROR, 'QueryException in SFM_GetListOfChecklist method: ' + qex.getMessage());
            return response;
        }
        catch(Exception ex){
            response.success = false;
            response.message = ex.getMessage();
            System.debug(LoggingLevel.ERROR, 'Exception in SFM_GetListOfChecklist method: ' + ex.getMessage());
            System.debug(LoggingLevel.ERROR, 'Exception in SFM_GetListOfChecklist method: ' + ex.getStackTraceString());
            return response;
        }
        return response;
    }
    
    //Added Id field in the set to query atleast Id field on the object for fixing defect BAC-3696
    Set<String> setFieldAPINames = new Set<String>{'Id'}; //Added for the story BAC-3744
    Public List<SVMXC__ServiceMax_Processes__c> Qualify(List<SVMXC__ServiceMax_Processes__c> checkListProcessList, String RecordId){
        SVMXC.SFM_parseExpression ExpParssig ; 
        Set<Id> HdrExpressionIds = new Set<Id> ();
        Set<Id> qualifiedExpIds = new Set<Id> ();     
        SVMXC.SFM_buildSobject buildSobject = new SVMXC.SFM_buildSobject();  
        List<SVMXC__ServiceMax_Processes__c>  qualifiedProcessList = new List<SVMXC__ServiceMax_Processes__c> ();
        String HdrExpression;
        String HeaderObject;
        Set<Id> setPageLayoutId = new Set<Id>(); //Added for the story BAC-3744
        Set <Id> setCheckListTargetManagerId = new Set <Id>(); // Collecting section criteria process ID for story BAC-3984
        for(SVMXC__ServiceMax_Processes__c Pro : checkListProcessList){
            system.debug(Pro.id);
            if(Pro.SVMXC__Type__c.touppercase() == 'TARGET'){
                HeaderObject = Pro.SVMXC__Node_Source_Object_API__c; 
                if(Pro.SVMXC__Submodule__c != null)   
                    HdrExpression = Pro.SVMXC__Submodule__c;
                setPageLayoutId.add(Pro.SVMXC__Process__r.SVMXC__Page_Layout__c); //Added for the story BAC-3744 for collecting page layout ids
                
                setCheckListTargetManagerId.add(Pro.SVMXC__Process__c);
      }
            if(HeaderObject != null && HdrExpression != null){
                HdrExpressionIds.add(HdrExpression);
            }
        }
        
        Map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapRulesExpressions = new Map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
            
        //Added for the defect BAC-3261 fix
        if(fieldDescribeMap != null && fieldDescribeMap.size() > 0 && RecordId != null && HeaderObject != null){
            //-------Start-----Added for the story BAC-3744
            //Here we will collect all the field API name which are used in Dynamic default response for the question
            if(setPageLayoutId.size() > 0){
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                for(SVMXC__Page_Layout_Detail__c objPLD : [SELECT SVMXC__SM_Checklist_Source_Field_API_Name__c FROM SVMXC__Page_Layout_Detail__c WHERE SVMXC__Page_Layout__c IN: setPageLayoutId AND SVMXC__Detail_Type__c = 'Question']){
                    String strFieldApiName = objPLD.SVMXC__SM_Checklist_Source_Field_API_Name__c;
                    if(String.isNotBlank(strFieldApiName) && fieldDescribeMap.containsKey(strFieldApiName)) {
                        setFieldAPINames.add(objPLD.SVMXC__SM_Checklist_Source_Field_API_Name__c);
                    }
                }
            }
            //-------End-----Added for the story BAC-3744
           
            // Query the field name which are getting used in section criteria for story BAC-3984
            if(setCheckListTargetManagerId != null && setCheckListTargetManagerId.size() > 0){
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                for(SVMXC__ServiceMax_Config_Data__c sectionCriteriaExpression : [Select SVMXC__Field_Name__c FROM SVMXC__ServiceMax_Config_Data__c 
                                                                                        WHERE SVMXC__Expression_Rule__c IN (Select SVMXC__Process3__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Process1__c IN :setCheckListTargetManagerId AND SVMXC__Rule_Type__c = 'Checklist_Section_Entry_Criteria') 
                                                                                            AND SVMXC__Expression_Type__c = 'Business_Rule']){
                    
                    String objectFieldName = sectionCriteriaExpression.SVMXC__Field_Name__c; 
                    if(String.isNotBlank(objectFieldName) && fieldDescribeMap.containsKey(objectFieldName)) {
                        setFieldAPINames.add(objectFieldName); 
                    }
                }
            } 
             
            system.debug('------' + setFieldAPINames);
            
            if(!HdrExpressionIds.isEmpty()){
                /*
                    BAC-3559 : Evaluating expressions on the queried record details instead of making a query for every expression by constructing where clause filter.
                */
                
                list<SVMXC__ServiceMax_Config_Data__c> lstExpressions = [SELECT SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, SVMXC__Sequence__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__Lookup_Field_API_Name__c,
                                  SVMXC__Object_Name2__c, SVMXC__IsDefault__c, SVMXC__Internal_Value__c, SVMXC__Field_Relationship_Name__c, SVMXC__Field_Name__c, SVMXC__FKey_Name_Field__c, 
                                  SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c,SVMXC__Expression_Rule__r.SVMXC__Advance_Expression__c, SVMXC__Display_Value__c, SVMXC__Display_Type__c, RecordTypeId, Name FROM SVMXC__ServiceMax_Config_Data__c  
                                  WHERE SVMXC__Expression_Rule__c IN: HdrExpressionIds AND RecordType.Name = 'Expressions' AND SVMXC__Expression_Type__c = 'EXP_Named']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                for(SVMXC__ServiceMax_Config_Data__c oExpression: lstExpressions)
                {
                    if(!mapRulesExpressions.containsKey(oExpression.SVMXC__Expression_Rule__c))
                        mapRulesExpressions.put(oExpression.SVMXC__Expression_Rule__c, new List<SVMXC__ServiceMax_Config_Data__c>());
                    mapRulesExpressions.get(oExpression.SVMXC__Expression_Rule__c).add(oExpression);
                    /*
                        BAC-3761 : Removed toUpperCase() as the code for checking security replaces __r with __c
                    */
                    // We need to get the fields used in Expression as well
                    if(oExpression.SVMXC__Field_Name__c != null )
                        setFieldAPINames.add((oExpression.SVMXC__Field_Name__c));
                
                    if(oExpression.SVMXC__Display_Type__c == 'REFERENCE' )
                        setFieldAPINames.add((oExpression.SVMXC__Field_Relationship_Name__c + '.' + oExpression.SVMXC__FKey_Name_Field__c));
                }
            }
            List<String> listFieldAPINames=new List<String>();
          listFieldAPINames.addAll(setFieldAPINames);
            
            if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( HeaderObject, listFieldAPINames, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            String fieldNames = '';
            
            for (String field : setFieldAPINames)
            {
                if(!String.isBlank(fieldNames))
                    fieldNames += ', ' + field;
                else
                    fieldNames += field;
            }
            
            String strQuery = 'SELECT ' +fieldNames+ ' FROM ' + HeaderObject + ' WHERE Id = \''+RecordId+'\'';
            System.debug('strQuery: '+strQuery);
            HeaderSobjList = Database.query(strQuery);
        }
        
        List<Sobject> SobjList;
        if(!HeaderSobjList.isEmpty() && !HdrExpressionIds.isEmpty()){
            for(Id expressionId : HdrExpressionIds){
                if(mapRulesExpressions.containsKey(expressionId) && !mapRulesExpressions.get(expressionId).isEmpty()){
                    List<SVMXC__ServiceMax_Config_Data__c> configRecList = mapRulesExpressions.get(expressionId);
                    system.debug(expressionId+ '------ ' + configRecList.size());
                    boolean isRuleApplicable = new COMM_Utils_V2.COMM_ExpressionParsing().SVMX_ExpressionParsing(HeaderSobjList[0], configRecList,configRecList[0].SVMXC__Expression_Rule__r.SVMXC__Advance_Expression__c);
                    System.debug(LoggingLevel.INFO, 'Rule Status ' + isRuleApplicable);
                    if(isRuleApplicable){
                        qualifiedExpIds.add(expressionId);
                    }
                }    
            }

            //commented for the defect BAC-3261 fix
            //HeaderSobjList = buildSobject.getSFM_BuildSobject(RecordId,HeaderObject,null,null);
            /*for(SVMXC__ServiceMax_Processes__c Expression : [Select Id, Name,SVMXC__Source_Object_Name__c, SVMXC__Name__c,SVMXC__SettingId__c,SVMXC__Description__c,SVMXC__Advance_Expression__c,SVMXC__ProcessID__c,SVMXC__Parent_Object_Criteria__c,SVMXC__Parent_Error_Msg__c,SVMXC__IsStandard__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id IN: HdrExpressionIds]){
                ExpParssig = new SVMXC.SFM_parseExpression(); 
                SobjList = new list<Sobject>();
                SVMXC.SFM_WrapperDef.SFM_Expression SFMExpression = new SVMXC.SFM_WrapperDef.SFM_Expression();
                SFMExpression.namedExpression = Expression;
                SobjList = ExpParssig.SFM_ParseExpression(HeaderSobjList,SFMExpression);    
                if(!SobjList.isEmpty()){
                    System.debug(LoggingLevel.INFO, 'Rule Status true');
                    qualifiedExpIds.add(Expression.Id);
                }else{
                    System.debug(LoggingLevel.INFO, 'Rule Status false');
                }                                 
            }*/
        }

        for(SVMXC__ServiceMax_Processes__c Pro : checkListProcessList){
            if(Pro.SVMXC__Type__c.touppercase() == 'TARGET' && (Pro.SVMXC__Submodule__c == null || qualifiedExpIds.contains(Pro.SVMXC__Submodule__c)))
               qualifiedProcessList.add(Pro);
        }
        system.debug('qualifiedProcessList: ' + qualifiedProcessList);
        return qualifiedProcessList;         
    }

    public string findObjectAPIName(String recordId){
        String keyPrefix = recordId.substring(0,3);
        for(Schema.SObjectType obj : Schema.getGlobalDescribe().Values()){
            String prefix = obj.getDescribe().getKeyPrefix();
            if(prefix != null && keyPrefix != null && prefix.equals(keyPrefix)){
                objectAPIName = obj.getDescribe().getName();
                fieldDescribeMap = obj.getDescribe().fields.getMap();
                break;
            }
        }
        return objectAPIName;
    }

}