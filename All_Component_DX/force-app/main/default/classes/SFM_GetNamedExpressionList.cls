/* Security Scanned */
public with sharing class SFM_GetNamedExpressionList
{
    //Constructor 
    public Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
    public Map<String,String> APIMap = new Map<String,String>(); //Map of API/API
    public SFM_getNamedExpressionList()
    {
        allObjs = Schema.getGlobalDescribe(); 
        if(allObjs.size() > 0)
        {
            for(String s : allObjs.keyset())
            {
                Schema.DescribeSObjectResult objDesc = allObjs.get(s).getDescribe();
                //system.debug('Key'+objDesc.getName());
                //system.debug('value'+s);
                APIMap.put(objDesc.getName(),objDesc.getName());
            }
            
        }
    }
    public SFM_WrapperDef.SFM_Response SFM_getAllObjectNamedExpressionList(SFM_WrapperDef.SFM_Request prequest){
        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
        List<SFM_WrapperDef.SFM_StringMap> result = new List<SFM_WrapperDef.SFM_StringMap>();
        list<SVMXC__ServiceMax_Processes__c > LstExp = new list<SVMXC__ServiceMax_Processes__c >();
        List<SFM_WrapperDef.SFM_StringMap> requestedObjects = prequest.stringMap;
        String sourceObjectName;
            for(SFM_WrapperDef.SFM_StringMap req: requestedObjects)
            {
                if(req.key.toUpperCase() == 'OBJECTNAME')
                    sourceObjectName = req.value;
            }
            if(sourceObjectName != null && APIMap.containskey(sourceObjectName))
            {
                sourceObjectName = APIMap.get(sourceObjectName);
                
                LstExp = [Select Id, Name,SVMXC__Source_Object_Name__c, SVMXC__Name__c,SVMXC__SettingId__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Advance_Expression__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND SVMXC__Source_Object_Name__c = :sourceObjectName Order By SVMXC__ProcessID__c DESC]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA // AND SVMXC__Source_Object_Name__c=:sourceObjectName AND SVMXC__Target_Object_Name__c=:targetObjectName
            }
        for(SVMXC__ServiceMax_Processes__c obj: LstExp){
            result.add(new SFM_WrapperDef.SFM_StringMap(obj.Id, obj.SVMXC__Name__c));
        }
        response.stringMap = result;
        response.success = true;
        return response;
    }
    //Added for BAC-4329
    public SFM_WrapperDef.SFM_Response SFM_getCustomActionList(SFM_WrapperDef.SFM_Request prequest){
        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
        List<SFM_WrapperDef.SFM_StringMap> result = new List<SFM_WrapperDef.SFM_StringMap>();
        list<SVMXC__ServiceMax_Processes__c > LstExp = new list<SVMXC__ServiceMax_Processes__c >();
        List<SFM_WrapperDef.SFM_StringMap> requestedObjects = prequest.stringMap;
        String sourceObjectName;
        for(SFM_WrapperDef.SFM_StringMap req: requestedObjects)
        {
            if(req.key.toUpperCase() == 'OBJECTNAME')
                sourceObjectName = req.value;
        }
        if(sourceObjectName != null && APIMap.containskey(sourceObjectName))
        {
            sourceObjectName = APIMap.get(sourceObjectName);
            LstExp = [Select Id, SVMXC__Name__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SF Action' AND SVMXC__Source_Object_Name__c = :sourceObjectName Order By SVMXC__Name__c ASC];
        }
        for(SVMXC__ServiceMax_Processes__c obj: LstExp){
            result.add(new SFM_WrapperDef.SFM_StringMap(obj.Id, obj.SVMXC__Name__c));
        }
        response.stringMap = result;
        response.success = true;
        return response;
    }
    //Method to get the Named Expression..
    public SFM_WrapperDef.SFM_Response_Expression SFM_getNamedExpressionList(SFM_WrapperDef.SFM_Request ExpReq)
    {
        Boolean response_success;
        String response_message;
        String response_tagId;
        Boolean s = false; 
        String msg;
        String tid;
        SVMX_Debug  log = new SVMX_Debug();
        List<SFM_WrapperDef.SFM_StringMap> expressionDefinition = new List<SFM_WrapperDef.SFM_StringMap>();
        Map<string,list<SVMXC__ServiceMax_Config_Data__c>> MapNamedExpDetail= new Map<string,list<SVMXC__ServiceMax_Config_Data__c>>();
        Map<string,SVMXC__ServiceMax_Processes__c> MapNamedExp = new Map<string,SVMXC__ServiceMax_Processes__c>();
        list<string> namedExpressionId = new list<string>();
        list<SVMXC__ServiceMax_Processes__c > LstnamedExpression = new list<SVMXC__ServiceMax_Processes__c >(); 
        list<SVMXC__ServiceMax_Config_Data__c> LstexpressionDetails= new list<SVMXC__ServiceMax_Config_Data__c>();
        List<SFM_WrapperDef.SFM_Expression> LstSFM_Exp = new List<SFM_WrapperDef.SFM_Expression>();
        log.login('SFM_ObjectNamedExpressionList', 'SFM_getNamedExpressionList(SFM_WrapperDef.SFM_Request)');
        try
        {
            
            List<SFM_WrapperDef.SFM_StringMap> requestedObjects = ExpReq.stringMap;
            String ExpId;
            String sourceObjectName;
            for(SFM_WrapperDef.SFM_StringMap req: requestedObjects)
            {
                if(req.key.toUpperCase() == 'EXPRESSIONID')
                    ExpId = req.value;
                if(req.key.toUpperCase() == 'OBJECTNAME')
                    sourceObjectName = req.value;
            }
            log.setlog('QUERY', 'Retrieve NamedExpression and ExpressionDeatils');
            if(ExpId != null)
            {
                
                LstnamedExpression = [Select Id, Name,SVMXC__Source_Object_Name__c, SVMXC__Name__c,SVMXC__SettingId__c,SVMXC__Description__c,SVMXC__Advance_Expression__c,SVMXC__ProcessID__c,SVMXC__Parent_Object_Criteria__c,SVMXC__Parent_Error_Msg__c,SVMXC__IsStandard__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id = :ExpId Order By SVMXC__ProcessID__c ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
           
            if(sourceObjectName != null && APIMap.containskey(sourceObjectName))
            {
                sourceObjectName = APIMap.get(sourceObjectName);
                
                LstnamedExpression = [Select Id, Name,SVMXC__Source_Object_Name__c, SVMXC__Name__c,SVMXC__SettingId__c,SVMXC__Description__c,SVMXC__Advance_Expression__c,SVMXC__Parent_Object_Criteria__c,SVMXC__Parent_Error_Msg__c,SVMXC__IsStandard__c, SVMXC__ProcessID__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND SVMXC__Source_Object_Name__c = :sourceObjectName Order By SVMXC__ProcessID__c ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA // AND SVMXC__Source_Object_Name__c=:sourceObjectName AND SVMXC__Target_Object_Name__c=:targetObjectName
      
            }
            if(LstnamedExpression.size() > 0)
            {   
                log.setlog('LOOPING-Start', 'Looping through list of servicemax processes to set map header detail expression');
                for(SVMXC__ServiceMax_Processes__c p : LstnamedExpression)
                {
                    namedExpressionId.add(p.Id);
                    list<SVMXC__ServiceMax_Config_Data__c> LstTemp= new list<SVMXC__ServiceMax_Config_Data__c>();
                    MapNamedExpDetail.put(p.Id,LstTemp);
                    MapNamedExp.put(p.Id,p);
                    expressionDefinition.add(new SFM_WrapperDef.SFM_StringMap(p.Id, p.SVMXC__Name__c));
                }
                
                LstexpressionDetails = [Select SVMXC__Sequence__c, SVMXC__Object_Name2__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Field_Name__c, SVMXC__Expression_Rule__c, Name, Id From SVMXC__ServiceMax_Config_Data__c where Recordtype.Name='Expressions' AND SVMXC__Expression_Type__c = 'EXP_Named' And SVMXC__Expression_Rule__c IN:namedExpressionId Order By SVMXC__Sequence__c ASC]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
            if(LstexpressionDetails.size() > 0)
            {
                log.setlog('LOOPING-End', 'Looping through list of servicemax processes to set map header detail expression');      
                for(SVMXC__ServiceMax_Config_Data__c Oconf : LstexpressionDetails)
                {
                    if(MapNamedExpDetail.containsKey(Oconf.SVMXC__Expression_Rule__c))
                        MapNamedExpDetail.get(Oconf.SVMXC__Expression_Rule__c).add(Oconf);
                }
                log.setlog('LOOPING-Start', 'Looping through Map of Header and Detail expression to build list of SFM_Expression');
            }
            if(MapNamedExpDetail.size() > 0)
            {
                for(string Key : MapNamedExpDetail.keySet())
                {
                    SFM_WrapperDef.SFM_Expression oSFM_Exp = new SFM_WrapperDef.SFM_Expression(MapNamedExp.get(Key),MapNamedExpDetail.get(Key));
                    LstSFM_Exp.add(oSFM_Exp);
                }
                log.setlog('LOOPING-End', 'Looping through Map of Header and Detail expression to build list of SFM_Expression');
                response_success = true;
            }
        }
        catch (Exception ex)
        {
            log.setlog('ERROR', ex.getmessage());
            response_success = false;
            response_message = ex.getmessage();
        }
        log.logout();
        log.print();
        log.getlog();
        SFM_WrapperDef.SFM_Response_Expression oResponse = new SFM_WrapperDef.SFM_Response_Expression(LstSFM_Exp);//s,msg,tid,strmap Commented for New Approach
        oResponse.response.stringMap = expressionDefinition;
        oResponse.response.success=response_success;
        oResponse.response.logMsg=log.getlog();
        oResponse.response.message = response_message;
        return oResponse; 
    }

    /*
        Common Method for Designer 2.0 to retrieve the following entities for list view
        1. Expressions
        2. Data Validation Rules
        3. Mappings
    */

    public List<SFM_WrapperDef2.SFM2_ListViewDetails> getListOfRules(String ruleType, SFM_WrapperDef2.SFM2_Criteria criteria ){
        List<SVMXC__ServiceMax_Processes__c> ruleProcessList;
        if(ruleType == SFM_DesignerUtils.entity_formula){
            ruleProcessList = queryRuleRecords(criteria , null, true, ruleType); 
        } else {
            ruleProcessList = queryRuleRecords(criteria , null, false, ruleType); 
        }

        return mapRuleRecords(ruleProcessList, ruleType);
    }


    public List<SVMXC__ServiceMax_Processes__c> queryRuleRecords(SFM_WrapperDef2.SFM2_Criteria criteria, List<String> ruleIds, boolean includeChild, String ruleType){

        /*
            Security Check : To check if fields are accessible before querying
            Objects : SVMXC__ServiceMax_Processes__c, SVMXC__ServiceMax_Config_Data__c
        */

        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ServiceMax_Processes__c', new List<String>{'Id', 'SVMXC__Name__c', 'SVMXC__Question_Bank__c', 'SVMXC__Question_Bank__r.SVMXC__Question__c', 'SVMXC__Rule_Type__c', 'SVMXC__ProcessID__c', 'SVMXC__Source_Object_Name__c', 'SVMXC__Target_Object_label__c', 'SVMXC__Target_Object_Name__c', 'SVMXC__Parent_Object_Criteria__c', 'SVMXC__Parent_Error_Msg__c', 'SVMXC__Description__c', 'SVMXC__Advance_Expression__c', 'SVMXC__IsStandard__c', 'SVMXC__Message_Type__c', 'CreatedDate', 'CreatedById', 'CreatedBy.Name', 'lastModifiedDate',
                                                                'SVMXC__Mode_Of_Execution__c','lastModifiedById', 'lastModifiedBy.Name'}, COMM_SecurityUtils.Access.Accessible)){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        String queryString = 'SELECT Id, SVMXC__Name__c, SVMXC__Question_Bank__c, SVMXC__Question_Bank__r.SVMXC__Question__c, SVMXC__Rule_Type__c, SVMXC__ProcessID__c, SVMXC__Source_Object_Name__c, SVMXC__Target_Object_Name__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c, SVMXC__Description__c, SVMXC__Advance_Expression__c, SVMXC__Target_Object_label__c, SVMXC__IsStandard__c, SVMXC__Message_Type__c, CreatedDate, CreatedById, CreatedBy.Name, lastModifiedDate, lastModifiedById, lastModifiedBy.Name, SVMXC__Mode_Of_Execution__c ';
                            

        
        if(includeChild){

            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ServiceMax_Config_Data__c', new List<String>{'Id', 'Name','SVMXC__Sequence__c', 'SVMXC__Source_Field_Name__c', 'SVMXC__Action_Type__c', 'SVMXC__Target_Field_Name__c', 'SVMXC__Preference_2__c', 'SVMXC__Preference_3__c', 'SVMXC__Display_Value__c', 'SVMXC__SM_Display_Value2__c', 'SVMXC__Configuration_Type__c', 'SVMXC__Object_Name2__c', 'SVMXC__Operator__c', 'SVMXC__Formula__c', 'SVMXC__Operand__c', 'SVMXC__Parameter_Type__c', 'SVMXC__Field_Name__c', 'SVMXC__Batch_Size__c', 'SVMXC__Expression_Rule__c', 'SVMXC__Expression_Type__c','SVMXC__SM_Related_Info__c', 'SVMXC__Search_Object_Field_Type__c', 'SVMXC__Display_Type__c'}, COMM_SecurityUtils.Access.Accessible)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }

            queryString += ', (SELECT Id, Name, SVMXC__Sequence__c, SVMXC__Source_Field_Name__c, SVMXC__Description__c, SVMXC__Action_Type__c, SVMXC__Target_Field_Name__c, SVMXC__Preference_2__c, SVMXC__Preference_3__c, SVMXC__Display_Value__c, SVMXC__SM_Display_Value2__c, SVMXC__Configuration_Type__c, SVMXC__Object_Name2__c, SVMXC__Operator__c, SVMXC__Formula__c, SVMXC__Operand__c, SVMXC__Parameter_Type__c, SVMXC__Field_Name__c, SVMXC__Batch_Size__c, SVMXC__Expression_Rule__c, SVMXC__Expression_Type__c, SVMXC__SM_Related_Info__c, SVMXC__Search_Object_Field_Type__c, SVMXC__Display_Type__c ';
            
            if(ruleType == SFM_DesignerUtils.entity_businessrule || ruleType == SFM_DesignerUtils.entity_formula || ruleType == SFM_DesignerUtils.entity_checklistCriteria || ruleType == SFM_DesignerUtils.entity_sectionCriteria || ruleType == SFM_DesignerUtils.entity_sectionEntryCriteria){
                queryString += ' FROM SVMXC__ServiceMax_Config_Data2__r Order By SVMXC__Sequence__c ASC) ';
            }else if(ruleType == SFM_DesignerUtils.entity_mapping){
                queryString += ' FROM SVMXC__SVMX_Config_Data2__r Order By SVMXC__Sequence__c ASC) ';
            } else if(ruleType == SFM_DesignerUtils.entity_expression) {
                queryString += ' FROM SVMXC__ServiceMax_Config_Data2__r WHERE Recordtype.Name = \'Expressions\' Order By SVMXC__Sequence__c ASC) ';
            }
        }                    

        if(ruleType == SFM_DesignerUtils.entity_expression){
           queryString += ' FROM SVMXC__ServiceMax_Processes__c WHERE Recordtype.Name = \'SVMX Rule\' AND SVMXC__Rule_Type__c = \'Named Expression\'';
        }else if(ruleType == SFM_DesignerUtils.entity_businessrule){   
            queryString += ' FROM SVMXC__ServiceMax_Processes__c WHERE Recordtype.Name = \'Business Rule\' AND SVMXC__Rule_Type__c = NULL ';
        }else if(ruleType == SFM_DesignerUtils.entity_formula){
            queryString += ' FROM SVMXC__ServiceMax_Processes__c WHERE Recordtype.Name = \'Business Rule\' AND SVMXC__Rule_Type__c = \'Field Update Rule\'';           
        }else if(ruleType == SFM_DesignerUtils.entity_mapping){
            queryString += ' FROM SVMXC__ServiceMax_Processes__c WHERE Recordtype.Name = \'Object Mapping\' AND SVMXC__Rule_Type__c = NULL ';
        }else if(ruleType == SFM_DesignerUtils.entity_lkpConfig){
            queryString += ' FROM SVMXC__ServiceMax_Processes__c WHERE Recordtype.Name = \'Named Search\' AND SVMXC__Rule_Type__c = \'SRCH_LOOKUP_CONFIG\'';
        }else if(ruleType == SFM_DesignerUtils.entity_checklistCriteria){
            queryString += ' FROM SVMXC__ServiceMax_Processes__c WHERE Recordtype.Name = \'Business Rule\' AND SVMXC__Rule_Type__c = \'Checklist Criteria in Output Doc\'';
        }else if(ruleType == SFM_DesignerUtils.entity_sectionCriteria){
            queryString += ' FROM SVMXC__ServiceMax_Processes__c WHERE Recordtype.Name = \'Business Rule\' AND (SVMXC__Rule_Type__c = \'Checklist_Section_Entry_Criteria\' OR SVMXC__Rule_Type__c = \'Checklist_Section_Exit_Criteria\')';
        }else if(ruleType == SFM_DesignerUtils.entity_sectionEntryCriteria){
            queryString += ' FROM SVMXC__ServiceMax_Processes__c WHERE Recordtype.Name = \'Business Rule\' AND SVMXC__Rule_Type__c = \'Checklist_Section_Entry_Criteria\'';
        }  

        if(ruleIds != null && !ruleIds.isEmpty()){
            queryString += ' AND Id IN : ruleIds';
        }

        if( criteria != null ){

            if(criteria.sourceObject != null ){
                String sourceObject = criteria.sourceObject;
                queryString += ' AND SVMXC__Source_Object_Name__c =: sourceObject';
            } 

            if(criteria.sourceObjectList != null && !criteria.sourceObjectList.isEmpty()){
                List<String> sourceObjectList = criteria.sourceObjectList;
                queryString += ' AND SVMXC__Source_Object_Name__c IN : sourceObjectList';
            } 
               
            if( ruleType.equalsIgnoreCase(SFM_DesignerUtils.entity_mapping) && criteria.targetObject != null ){
                String targetObject = criteria.targetObject;
                queryString += ' AND SVMXC__Target_Object_Name__c =: targetObject';
                
                if(String.isBlank(criteria.sourceObject)){
                    queryString += ' AND (SVMXC__Source_Object_Name__c = NULL OR SVMXC__Source_Object_Name__c = \'\')';
                }
            }
        }
        


        
        /*
            queryString += ' Order By SVMXC__ProcessID__c'; 
            To Do :  Order by Name
        */
        return (List<SVMXC__ServiceMax_Processes__c>)Database.query(queryString);
    }

    public List<SFM_WrapperDef2.SFM2_ListViewDetails> mapRuleRecords(List<SVMXC__ServiceMax_Processes__c> ruleProcessList, String ruleType){
        Map<String, Schema.SObjectType> sObjectGlobalDescribe = COMM_Utils_DescribeCall.getInstance().getGlobalDescribeCall();
        Map<Id, SVMXC__ServiceMax_Processes__c> rulesRecordsMap = new Map<Id, SVMXC__ServiceMax_Processes__c>(ruleProcessList);
        List<SFM_WrapperDef2.SFM2_ListViewDetails> rulesWrapperList = new List<SFM_WrapperDef2.SFM2_ListViewDetails>();
        Set<Id> dependentProcessIds = SFM_GetEntityDependencies.entityDependencyCheck(rulesRecordsMap.keySet(), ruleType);
        

        for(SVMXC__ServiceMax_Processes__c ruleDef : ruleProcessList){
            SFM_WrapperDef2.SFM2_ListViewDetails ruleInfo = new SFM_WrapperDef2.SFM2_ListViewDetails();
            String sobjectType;
            if(ruleDef.SVMXC__Source_Object_Name__c != null){
                sobjectType = ruleDef.SVMXC__Source_Object_Name__c.trim();
                ruleInfo.sourceObjectApi = sobjectType;
                ruleInfo.sourceObject = sObjectGlobalDescribe.containsKey(sobjectType) ? sObjectGlobalDescribe.get(sobjectType).getDescribe().getLabel(): '';
            }

            if(ruleDef.SVMXC__Target_Object_Name__c != null){
                sobjectType = ruleDef.SVMXC__Target_Object_Name__c.trim();
                ruleInfo.targetObjectApi = sobjectType;
                ruleInfo.targetObject = sObjectGlobalDescribe.containsKey(sobjectType) ? sObjectGlobalDescribe.get(sobjectType).getDescribe().getLabel(): '';
            }
            ruleInfo.entityType = ruleType; 
            ruleInfo.message = ruleDef.SVMXC__Parent_Error_Msg__c;
            ruleInfo.objectAlias = ruleDef.SVMXC__Target_Object_label__c;
            
            if(dependentProcessIds.contains(ruleDef.Id)){
                ruleInfo.dependencyExist = true;
            }

            ruleInfo.entityDetail = new SFM_SaveAsExpression().buildEntityDetail(ruleDef);
            
            if(ruleType == SFM_DesignerUtils.entity_formula){
                List<SVMXC__ServiceMax_Config_Data__c> formalaFieldRecords = ruleDef.SVMXC__ServiceMax_Config_Data2__r;
                if(!formalaFieldRecords.isEmpty()){
                    ruleInfo.targetField = formalaFieldRecords[0].SVMXC__Field_Name__c;
                }
            }
            rulesWrapperList.add(ruleInfo);
        }
        
        return rulesWrapperList;  
    }
}