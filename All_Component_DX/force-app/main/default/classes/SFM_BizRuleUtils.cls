public with sharing class SFM_BizRuleUtils
{
    /**
    * This method returns Business Rule Ids
    * @param SVMXC.SFM_WrapperDef.SFM_Request(OBJECTAPINAME: <Object API Name>)
    * @return SVMXC.SFM_WrapperDef.SFM_Response(Business Rule Ids)
    */
    public SVMXC.SFM_WrapperDef.SFM_Response SFM_GetBizRuleIds(SVMXC.SFM_WrapperDef.SFM_Request request)
    {
        List<String> lstObjectName = new List<String>();
        List<SVMXC__ServiceMax_Processes__c> lstBizRules = new List<SVMXC__ServiceMax_Processes__c>(); 
        Map<String, SVMXC__ServiceMax_Processes__c> mapBizRules = new Map<String, SVMXC__ServiceMax_Processes__c>();
        SVMXC.SFM_WrapperDef.SFM_Response objBizRuleResp = new SVMXC.SFM_WrapperDef.SFM_Response();
        objBizRuleResp.resultIds = new List<String>();
        objBizRuleResp.success = true;
        
        try
        {
            for(SVMXC.SFM_WrapperDef.SFM_StringListMap strLstMap : request.stringListMap)
            {
                if(strLstMap.key != NULL && strLstMap.key.toUpperCase() == 'OBJECTAPINAME' && strLstMap.valueList != NULL)
                {
                    for(String value : strLstMap.valueList)
                        lstObjectName.add(String.escapeSingleQuotes(value));
                }
            }
            if(lstObjectName != NULL && lstObjectName.size() > 0)
                lstBizRules = Database.query('Select Id From SVMXC__ServiceMax_Processes__c Where SVMXC__Source_Object_Name__c IN: lstObjectName AND SVMXC__Source_Object_Name__c != NULL AND Recordtype.Name = \'Business Rule\' AND SVMXC__Rule_Type__c != \'Field Update Rule\' AND SVMXC__Rule_Type__c != \'Checklist_Section_Entry_Criteria\' AND SVMXC__Rule_Type__c != \'Checklist_Section_Exit_Criteria\'');
            else
                lstBizRules = Database.query('Select Id From SVMXC__ServiceMax_Processes__c Where SVMXC__Source_Object_Name__c != NULL AND Recordtype.Name = \'Business Rule\' AND SVMXC__Rule_Type__c != \'Field Update Rule\' AND SVMXC__Rule_Type__c != \'Checklist_Section_Entry_Criteria\' AND SVMXC__Rule_Type__c != \'Checklist_Section_Exit_Criteria\'');

            if(lstBizRules != NULL && lstBizRules.size() > 0)
                mapBizRules.putAll(lstBizRules);
            if(mapBizRules != NULL && mapBizRules.size() > 0)
                objBizRuleResp.resultIds.addAll(mapBizRules.keySet());
        }
        catch(exception ex)
        {
            objBizRuleResp.success = false;
            objBizRuleResp.message = ex.getMessage();
            System.debug(LoggingLevel.Warn, 'Exception: ' + ex.getMessage());
        }
        System.debug(LoggingLevel.WARN, 'Response: ' + objBizRuleResp);
        return objBizRuleResp;
    }
    
    /**
    * This method returns Biz rule with expressions
    * @param SVMXC.SFM_WrapperDef.SFM_Request(BUSINESSRULEIDS: <Biz rule Ids>)
    * @return SVMXC.SFM_WrapperDef.SFM_Response(Biz rule with expressions)
    */
    public SVMXC.SFM_WrapperDef.SFM_Response SFM_GetBizRuleInfo(SVMXC.SFM_WrapperDef.SFM_Request request)
    {
        List<String> lstBizRuleIds = new List<String>();
        Map<String, List<SVMXC__ServiceMax_Config_Data__c>> mapBizRuleIdExplst = new Map<String, List<SVMXC__ServiceMax_Config_Data__c>>();
        SVMXC.SFM_WrapperDef.SFM_Response objBizRuleResp = new SVMXC.SFM_WrapperDef.SFM_Response();
        objBizRuleResp.lstBizRuleInfo = new List<SVMXC.SFM_WrapperDef.SFM_BizRuleInfo>();
        objBizRuleResp.success = true;
        
        try
        {
            for(SVMXC.SFM_WrapperDef.SFM_StringListMap strLstMap : request.stringListMap)
            {
                if(strLstMap.key != NULL && strLstMap.key.toUpperCase() == 'BUSINESSRULEIDS' && strLstMap.valueList != NULL)
                {
                    for(String value : strLstMap.valueList)
                        lstBizRuleIds.add(String.escapeSingleQuotes(value));
                }
            }
            if(lstBizRuleIds.size() > 0)
            {
                //Added ORDER BY clause to display sequence correctly in designer.
                for(SVMXC__ServiceMax_Config_Data__c BizRuleExpr : Database.query('Select Id, SVMXC__Description__c, SVMXC__Parameter_Type__c, SVMXC__Expression_Rule__c, SVMXC__Sequence__c, SVMXC__Object_Name__c, SVMXC__Field_Name__c, SVMXC__Display_Type__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Internal_Value__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c IN: lstBizRuleIds AND SVMXC__Expression_Type__c = \'Business_Rule\' ORDER BY SVMXC__Sequence__c'))
                {
                    if(!mapBizRuleIdExplst.containsKey(BizRuleExpr.SVMXC__Expression_Rule__c))
                        mapBizRuleIdExplst.put(BizRuleExpr.SVMXC__Expression_Rule__c, new List<SVMXC__ServiceMax_Config_Data__c>());
                    mapBizRuleIdExplst.get(BizRuleExpr.SVMXC__Expression_Rule__c).add(BizRuleExpr);
                }
                for(SVMXC__ServiceMax_Processes__c BizRule : Database.query('Select SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__IsStandard__c, SVMXC__Description__c, SVMXC__Message_Type__c, SVMXC__Source_Object_Name__c, SVMXC__Advance_Expression__c, SVMXC__Parent_Error_Msg__c, Id From SVMXC__ServiceMax_Processes__c Where Recordtype.Name = \'Business Rule\' AND SVMXC__Rule_Type__c != \'Field Update Rule\' AND Id IN: lstBizRuleIds'))
                {
                    if(mapBizRuleIdExplst.containsKey(BizRule.Id) && mapBizRuleIdExplst.get(BizRule.Id) != NULL)
                        objBizRuleResp.lstBizRuleInfo.add(new SVMXC.SFM_WrapperDef.SFM_BizRuleInfo(BizRule, mapBizRuleIdExplst.get(BizRule.Id)));
                }
            }
        }
        catch(exception ex)
        {
            objBizRuleResp.success = false;
            objBizRuleResp.message = ex.getMessage();
            System.debug(LoggingLevel.Warn, 'Exception: ' + ex.getMessage());
        }
        System.debug(LoggingLevel.WARN, 'Response: ' + objBizRuleResp);
        return objBizRuleResp;
    }
    
    /**
    * This method save the business rule
    * @param SVMXC.SFM_WrapperDef.SFM_Request(SFM_BizRuleInfo)
    * @return SVMXC.SFM_WrapperDef.SFM_Response(Success/Failure, Message, Record Ids, SFM_BizRuleInfo))
    */
    public SVMXC.SFM_WrapperDef.SFM_Response SFM_SaveBizRules(SVMXC.SFM_WrapperDef.SFM_Request BizRuleRequest)
    {
        System.debug(LoggingLevel.WARN, 'Request: ' + BizRuleRequest);
        String BizRuleId = NULL;
        String ObjName;
        String UniqueProcessId;
        String RuleRecordTypeId;
        String ExpressionRTypeId;
        String respMassage = '';
        Boolean respSuccess = true;
        Savepoint sp;
        
        SVMXC__ServiceMax_Processes__c BusinessRule;
        List<SVMXC__ServiceMax_Config_Data__c> lstBusinessRuleExpr = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC.SFM_WrapperDef.SFM_BizRuleInfo> lstBusinessRuleInfoWrap = new List<SVMXC.SFM_WrapperDef.SFM_BizRuleInfo>();
        SVMXC.SFM_WrapperDef.SFM_Response objBizRuleResp = new SVMXC.SFM_WrapperDef.SFM_Response();
        SVMXC.SFM_WrapperDef.SFM_Response objValidationResp = new SVMXC.SFM_WrapperDef.SFM_Response();
        
        try
        {
            sp = Database.setSavepoint();
            for(RecordType RType : Database.query('Select Id, Name From RecordType Where (SobjectType = \'SVMXC__ServiceMax_Processes__c\' AND Name = \'Business Rule\') OR (SobjectType = \'SVMXC__ServiceMax_Config_Data__c\' AND Name = \'Expressions\')'))
            {
                if(RType.Name == 'Business Rule')
                    RuleRecordTypeId = RType.id;
                else if(RType.Name == 'Expressions')
                    ExpressionRTypeId = RType.id;
            }
      
            objValidationResp = ValidateBizRules(BizRuleRequest);
            System.debug(LoggingLevel.WARN, 'validation responce : ' + objValidationResp);
            
            if(objValidationResp != NULL && objValidationResp.success == true)
            {
                SVMXC.SFM_WrapperDef.SFM_BizRuleInfo BizRuleInfo = BizRuleRequest.bizRuleInfo;
                if(BizRuleInfo != NULL && BizRuleInfo.bizRule != NULL)
                {
                    if(BizRuleInfo.bizRule.Id != NULL)
                        BizRuleId = String.escapeSingleQuotes(BizRuleInfo.bizRule.Id);
                    
                    if(BizRuleInfo.bizRule.SVMXC__Source_Object_Name__c != NULL)
                        ObjName = BizRuleInfo.bizRule.SVMXC__Source_Object_Name__c;
                    
                    BusinessRule = BizRuleInfo.bizRule;
                    BusinessRule.RecordTypeId = RuleRecordTypeId;
                    UniqueProcessId = BusinessRule.SVMXC__ProcessID__c;
                    
                    if(BizRuleInfo.bizRuleDetails != NULL && BizRuleInfo.bizRuleDetails.size() > 0)
                        lstBusinessRuleExpr.addAll(BizRuleInfo.bizRuleDetails);
                }
                if(BusinessRule != NULL)
                {
                    List<SVMXC__ServiceMax_Processes__c> lstDuplicateBizRule = Database.query('Select Id From SVMXC__ServiceMax_Processes__c Where Recordtype.Name = \'Business Rule\' AND SVMXC__ProcessID__c =: UniqueProcessId AND SVMXC__ProcessID__c != NULL AND Id !=: BizRuleId');
                    if(lstDuplicateBizRule != NULL && lstDuplicateBizRule.size() > 0)
                    {
                        respSuccess = false;
                        respMassage = System.Label.SFM001_TAG347;
                    }
                    else
                    {
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        upsert BusinessRule;
                        for(SVMXC__ServiceMax_Config_Data__c expressDetail : lstBusinessRuleExpr)
                        {
                            expressDetail.RecordTypeId = ExpressionRTypeId;
                            expressDetail.SVMXC__Expression_Type__c = 'Business_Rule';
                            expressDetail.SVMXC__Expression_Rule__c = BusinessRule.Id;
                            if(expressDetail.SVMXC__Display_Type__c != NULL && expressDetail.SVMXC__Display_Type__c.length() > 0)
                                expressDetail.SVMXC__Display_Type__c = String.valueOf(expressDetail.SVMXC__Display_Type__c).toUpperCase();
                        }
            
                        if(BizRuleId != NULL && BizRuleId.length() > 0)
                            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            delete Database.query('Select Id From SVMXC__ServiceMax_Config_Data__c Where Recordtype.Name = \'Expressions\' AND SVMXC__Expression_Type__c = \'Business_Rule\' And SVMXC__Expression_Rule__c =: BizRuleId AND SVMXC__Expression_Rule__c != NULL');
                        
                        if(lstBusinessRuleExpr != NULL && lstBusinessRuleExpr.size() > 0)
                            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            upsert lstBusinessRuleExpr;
                        
                        if(BusinessRule != NULL && lstBusinessRuleExpr != NULL && lstBusinessRuleExpr.size() > 0)
                            lstBusinessRuleInfoWrap.add(new SVMXC.SFM_WrapperDef.SFM_BizRuleInfo(BusinessRule, lstBusinessRuleExpr));
                        
                        respSuccess = true;
                        respMassage = System.Label.SFM001_TAG349;
                    }
                }
            }
            else
            {
                respSuccess = false;
                respMassage = System.Label.SFM001_TAG350;
            }
        }
        catch(DmlException ex)
        {
            Database.rollback(sp);
            respSuccess = false;
            respMassage = ex.getDmlMessage(0);
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            respSuccess = false;
            respMassage = ex.getmessage();
        }
        objBizRuleResp.success = respSuccess;
        objBizRuleResp.message = respMassage;
        if(BusinessRule != NULL && BusinessRule.Id != NULL)
            objBizRuleResp.resultIds.add(BusinessRule.Id);
        objBizRuleResp.lstBizRuleInfo = lstBusinessRuleInfoWrap;
        System.debug(LoggingLevel.WARN, 'Response: ' + objBizRuleResp);
        return objBizRuleResp;
    }
    
    /**
    * This method deletes Business Rule
    * @param SVMXC.SFM_WrapperDef.SFM_Request(RECORDID: <Biz Rule Id>, PROCESSID: <SFM Process Id>)
    * @return SVMXC.SFM_WrapperDef.SFM_Response(success/Failure, Message)
    */
    public SVMXC.SFM_WrapperDef.SFM_Response SFM_DeleteBizRules(SVMXC.SFM_WrapperDef.SFM_Request request)
    {
        String BizRuleId = NULL;
        String SFMProcId = NULL;
        List<SVMXC__ServiceMax_Processes__c> lstProcessBizRule = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC.SFM_WrapperDef.SFM_Response objBizRuleResp = new SVMXC.SFM_WrapperDef.SFM_Response();
        Savepoint sp;
    
        try
        {
            sp = Database.setSavepoint();
            for(SVMXC.SFM_WrapperDef.SFM_StringMap strMap : request.stringMap)
            {
                if(strMap.key != NULL && strMap.value != NULL)
                {
                    if(strMap.key.toUpperCase() == 'RECORDID')
                        BizRuleId = String.escapeSingleQuotes(strMap.value);
                    else if(strMap.key.toUpperCase() == 'PROCESSID')
                        SFMProcId = String.escapeSingleQuotes(strMap.value);
                }
            }
            //Check whether this Business rule is associated with other SFM Process.
            if(BizRuleId != NULL && BizRuleId.length() > 0)
            {
                if(SFMProcId != NULL && SFMProcId.length() > 0)
                    lstProcessBizRule = Database.query('Select SVMXC__Process1__r.SVMXC__Name__c From SVMXC__ServiceMax_Processes__c Where SVMXC__Process3__c =: BizRuleId AND SVMXC__Process1__c !=: SFMProcId AND Recordtype.Name = \'Process Business Rule\' AND SVMXC__Process3__c != NULL');
                else
                    lstProcessBizRule = Database.query('Select SVMXC__Process1__r.SVMXC__Name__c From SVMXC__ServiceMax_Processes__c Where SVMXC__Process3__c =: BizRuleId AND Recordtype.Name = \'Process Business Rule\' AND SVMXC__Process3__c != NULL');
            }
            System.debug(LoggingLevel.WARN, 'Process Business Rules list: ' + lstProcessBizRule);
            
            if(lstProcessBizRule != NULL && lstProcessBizRule.size() > 0)
            {
                String strAssocaiedSFMProcessName = '';
                Set<Id> setProBizRuleIds = new Set<Id>();
                for(SVMXC__ServiceMax_Processes__c ProcessBizRule : lstProcessBizRule)
                {
                    if(!setProBizRuleIds.contains(ProcessBizRule.SVMXC__Process1__c))
                    {
                        if(strAssocaiedSFMProcessName.length() > 0)
                            strAssocaiedSFMProcessName += ', ';
                        strAssocaiedSFMProcessName += ProcessBizRule.SVMXC__Process1__r.SVMXC__Name__c;
                        setProBizRuleIds.add(ProcessBizRule.SVMXC__Process1__c);
                    }
                }
                setProBizRuleIds.clear();
                objBizRuleResp.success = false;
                objBizRuleResp.message = System.Label.SFM001_TAG348 + ': '; 
                objBizRuleResp.message += strAssocaiedSFMProcessName;
                return objBizRuleResp;
            }
            else
            {
                List<SVMXC__ServiceMax_Processes__c> lstProBizRule = Database.query('Select Id From SVMXC__ServiceMax_Processes__c Where SVMXC__Process3__c =: BizRuleId AND SVMXC__Process1__c =: SFMProcId AND Recordtype.Name = \'Process Business Rule\'');
                List<SVMXC__ServiceMax_Processes__c> lstBizRule = Database.query('Select Id From SVMXC__ServiceMax_Processes__c Where Id =: BizRuleId AND Recordtype.Name =\'Business Rule\'');
                List<SVMXC__ServiceMax_Config_Data__c> lstBizRuleExpr = Database.query('Select Id From SVMXC__ServiceMax_Config_Data__c Where SVMXC__Expression_Rule__c =: BizRuleId AND ( SVMXC__Expression_Type__c = \'Business_Rule\' OR SVMXC__Expression_Type__c = \'Field_Update_Rule\' )');
                    
                if(lstProBizRule != NULL && lstProBizRule.size() == 1)
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    delete lstProBizRule;
                if(lstBizRuleExpr != NULL && lstBizRuleExpr.size() > 0)
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    delete lstBizRuleExpr;
                if(lstBizRule != NULL && lstBizRule.size() > 0)
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    delete lstBizRule;
                
                objBizRuleResp.success = true;
                objBizRuleResp.message = System.Label.SFM001_TAG351;
            }
        }
        catch(DmlException ex)
        {
            Database.rollback(sp);
            objBizRuleResp.success = false;
            objBizRuleResp.message = ex.getDmlMessage(0);
            return objBizRuleResp;
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            objBizRuleResp.success = false;
            objBizRuleResp.message = ex.getmessage();
            return objBizRuleResp;
        }
        System.debug(LoggingLevel.WARN, 'Response: ' + objBizRuleResp);
        return objBizRuleResp;
    }
    
    /**
    * This method returns Business Rules list
    * @param SFM Process Id (Id: SFMProcessId)
    * @return List<Sobject> lstProBizRule
    */
    public List<Sobject> SFM_GetBizRulesForProcess(String SFMProcessId)
    {
        List<Sobject> lstProBizRule = new List<Sobject>();
        if(SFMProcessId != NULL && SFMProcessId.length() > 0)
        {
            lstProBizRule.addAll(Database.query('Select Id, SVMXC__IsStandard__c, SVMXC__Parent_Error_Msg__c, SVMXC__Name__c, SVMXC__Process1__c, SVMXC__Process2__c, SVMXC__Process2__r.SVMXC__Target_Object_label__c, SVMXC__Process3__c, SVMXC__Sequence__c, SVMXC__ProcessID__c, SVMXC__Description__c From SVMXC__ServiceMax_Processes__c Where SVMXC__Process1__c =: SFMProcessId AND Recordtype.Name = \'Process Business Rule\' Order By SVMXC__Sequence__c'));
        }
        System.debug(LoggingLevel.WARN, 'Response: ' + lstProBizRule);
        return lstProBizRule;
    }
    
    /**
    * Method to get list of all SFM Processes associated with Biz Rule.
    * @param Biz Rule Id
    * @return List<SVMXC.SFM_WrapperDef.SFM_ProcessBusinessRule> 
    */
    public SVMXC.SFM_WrapperDef.SFM_Response SFM_GetBizRuleProcesses(SVMXC.SFM_WrapperDef.SFM_Request request)
    {
        List<String> lstBizRuleId = new List<String>();
        List<String> lstObjAPIName = new List<String>();
        Map<ID, SVMXC__ServiceMax_Processes__c> mapSFMBizRules = new Map<ID, SVMXC__ServiceMax_Processes__c>();
        Map<ID, Set<ID>> mapBizRuleIdSFMProIDset = new Map<ID, Set<ID>>();
        SVMXC.SFM_WrapperDef.SFM_Response objSFMResp = new SVMXC.SFM_WrapperDef.SFM_Response();
        objSFMResp.sobjectMap = new list<SVMXC.SFM_WrapperDef.SFM_StringSobjectMap>();
        
        try
        {
            for(SVMXC.SFM_WrapperDef.SFM_StringListMap strLstMap : request.stringListMap)
            {
                if(strLstMap.key != NULL && strLstMap.key.toUpperCase() == 'BUSINESSRULEIDS' && strLstMap.valueList != NULL)
                    lstBizRuleId = strLstMap.valueList;
                else if(strLstMap.key != NULL && strLstMap.key.toUpperCase() == 'OBJECTAPINAME' && strLstMap.valueList != NULL)
                    lstObjAPIName = strLstMap.valueList;
            }

            if(lstBizRuleId != NULL && lstBizRuleId.size() > 0 && lstObjAPIName != NULL && lstObjAPIName.size() > 0)
            {
                mapSFMBizRules.putAll([Select Id From SVMXC__ServiceMax_Processes__c Where SVMXC__Source_Object_Name__c IN: lstObjAPIName AND SVMXC__Source_Object_Name__c != NULL AND Recordtype.Name = 'Business Rule' AND Id IN: lstBizRuleId]);
            }
            else if(lstBizRuleId != NULL && lstBizRuleId.size() > 0 && lstObjAPIName != NULL && lstObjAPIName.size() == 0)
            {
                mapSFMBizRules.putAll([Select Id From SVMXC__ServiceMax_Processes__c Where SVMXC__Source_Object_Name__c != NULL AND Recordtype.Name = 'Business Rule' AND Id IN: lstBizRuleId]);
            }
            else if(lstBizRuleId != NULL && lstBizRuleId.size() == 0 && lstObjAPIName != NULL && lstObjAPIName.size() > 0)
            {
                mapSFMBizRules.putAll([Select Id From SVMXC__ServiceMax_Processes__c Where SVMXC__Source_Object_Name__c IN: lstObjAPIName AND SVMXC__Source_Object_Name__c != NULL AND Recordtype.Name = 'Business Rule']);
            }
            else
            {
                mapSFMBizRules.putAll([Select Id From SVMXC__ServiceMax_Processes__c Where SVMXC__Source_Object_Name__c != NULL AND Recordtype.Name = 'Business Rule']);
            }
            
            for(SVMXC__ServiceMax_Processes__c objProBizRule : [Select SVMXC__Process1__c, SVMXC__Process3__c From SVMXC__ServiceMax_Processes__c Where SVMXC__Process3__c IN: mapSFMBizRules.keySet() AND SVMXC__Process1__c != NULL  AND Recordtype.Name = 'Process Business Rule' AND SVMXC__Process3__c != NULL])
            {
                if(!mapBizRuleIdSFMProIDset.containsKey(objProBizRule.SVMXC__Process3__c))
                    mapBizRuleIdSFMProIDset.put(objProBizRule.SVMXC__Process3__c, new Set<ID>());
                mapBizRuleIdSFMProIDset.get(objProBizRule.SVMXC__Process3__c).add(objProBizRule.SVMXC__Process1__c);
            }
            
            Set<ID> setSFMProcIDs = new Set<ID>();
            for(Set<ID> lstSFMProID : mapBizRuleIdSFMProIDset.values())
                setSFMProcIDs.addAll(lstSFMProID);
            System.debug(LoggingLevel.WARN, 'SFM Process Ids: ' + setSFMProcIDs);
            
            Map<ID, SVMXC__ServiceMax_Processes__c> mapSFMProcesses = new Map<ID, SVMXC__ServiceMax_Processes__c>();
            mapSFMProcesses.putAll([Select Id, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__IsStandard__c, SVMXC__Description__c, SVMXC__Purpose__c, SVMXC__Dispatch_Process_Status__c, LastModifiedDate From SVMXC__ServiceMax_Processes__c Where Recordtype.Name = 'Target Manager' AND ID IN: setSFMProcIDs]);
            System.debug(LoggingLevel.WARN, 'SFM Process map: ' + mapSFMProcesses);
            
            for(ID BizRuleId : mapBizRuleIdSFMProIDset.keySet())
            {
                if(mapBizRuleIdSFMProIDset.get(BizRuleId) != NULL && mapBizRuleIdSFMProIDset.get(BizRuleId).size() > 0)
                {
                    list<Sobject> lstSFMProcesses = new list<Sobject>();
                    for(ID SFMProId : mapBizRuleIdSFMProIDset.get(BizRuleId))
                    {
                        if(mapSFMProcesses.containsKey(SFMProId) && mapSFMProcesses.get(SFMProId) != NULL)
                            lstSFMProcesses.add(mapSFMProcesses.get(SFMProId));
                    }
                    objSFMResp.sobjectMap.add(new SVMXC.SFM_WrapperDef.SFM_StringSobjectMap(String.valueOf(BizRuleId), lstSFMProcesses));
                }
            }
            System.debug(LoggingLevel.WARN, 'Response: ' + objSFMResp);
            objSFMResp.success = true;
            return objSFMResp;
        }
        catch(Exception ex)
        {
            objSFMResp.success = false;
            objSFMResp.message = ex.getmessage();
            return objSFMResp;
        }
    }
    
    /**
    * This method construct the request for SFM_ValidateExpressions
    * @param SVMXC.SFM_WrapperDef.SFM_Request
    * @return SVMXC.SFM_WrapperDef.SFM_Response (success/Failure, Message) 
    */
    public SVMXC.SFM_WrapperDef.SFM_Response ValidateBizRules(SVMXC.SFM_WrapperDef.SFM_Request request)
    {
        SVMXC.SFM_WrapperDef.SFM_Response objValidationResp = new SVMXC.SFM_WrapperDef.SFM_Response();
        SVMXC__ServiceMax_Processes__c bizRule = new SVMXC__ServiceMax_Processes__c();
        List<SVMXC__ServiceMax_Config_Data__c> bizRuleDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> bizRuleDetailsClone = new List<SVMXC__ServiceMax_Config_Data__c>();
        if(request != NULL && request.bizRuleInfo != NULL && request.bizRuleInfo.bizRule != NULL && request.bizRuleInfo.bizRuleDetails != NULL)
        {
            bizRule = request.bizRuleInfo.bizRule;
            bizRuleDetails = request.bizRuleInfo.bizRuleDetails;
            for(SVMXC__ServiceMax_Config_Data__c bizRuleExp : bizRuleDetails)
            {
               
                String strOperandDataType = '';
                SVMXC__ServiceMax_Config_Data__c bizRuleExpClone = bizRuleExp.clone(false, true);
                if(bizRuleExpClone.SVMXC__Display_Type__c == 'TEXTAREA'){
                    bizRuleExpClone.SVMXC__Field_Name__c = 'Id';
                }
                if(bizRuleExpClone.SVMXC__Parameter_Type__c != NULL && bizRuleExpClone.SVMXC__Parameter_Type__c.toUpperCase() == 'FIELD VALUE')
                {
                    if(bizRuleExpClone.SVMXC__Internal_Value__c != NULL)
                        strOperandDataType = bizRuleExpClone.SVMXC__Internal_Value__c.toUpperCase();
                    if(strOperandDataType == 'STRING' || strOperandDataType == 'PICKLIST' || strOperandDataType == 'REFERENCE')
                        bizRuleExpClone.SVMXC__Operand__c = 'ServiceMax';
                    else if(strOperandDataType == 'CURRENCY' || strOperandDataType == 'DOUBLE')
                        bizRuleExpClone.SVMXC__Operand__c = '20';
                    else if(strOperandDataType == 'EMAIL')
                        bizRuleExpClone.SVMXC__Operand__c = 'a@b.com';
                    else if(strOperandDataType == 'BOOLEAN')
                        bizRuleExpClone.SVMXC__Operand__c = 'true';
                    else if(strOperandDataType == 'DATE')
                        bizRuleExpClone.SVMXC__Operand__c = String.valueOf(date.today());
                    else if(strOperandDataType == 'DATETIME')
                        bizRuleExpClone.SVMXC__Operand__c = String.valueOf(datetime.now());
                    else if(strOperandDataType == 'MULTIPICKLIST')
                        bizRuleExpClone.SVMXC__Operand__c = 'ServiceMax;Maxplre';
                }
                bizRuleDetailsClone.add(bizRuleExpClone);
            }
            List<SVMXC.SFM_WrapperDef.SFM_Expression> Exprs = new List<SVMXC.SFM_WrapperDef.SFM_Expression>();
            Exprs.add(new SVMXC.SFM_WrapperDef.SFM_Expression(bizRule, bizRuleDetailsClone));
            SVMXC.SFM_WrapperDef.SFM_Request_Expression objBizRuleExprs = new SVMXC.SFM_WrapperDef.SFM_Request_Expression(Exprs);
            objValidationResp = new SVMXC.SFM_validateExpression().SFM_validateExpression(objBizRuleExprs);
        }
        else
            objValidationResp.success = false;
        
        System.debug(LoggingLevel.WARN, 'Response: ' + objValidationResp);
        return objValidationResp;
    }
    
    /**
    * This method to get Biz Rule meta info.
    * @param SFMProcessId
    * @return List<SVMXC.SFM_WrapperDef.SFM_ProcessBusinessRule> 
    */
    public List<SVMXC.SFM_WrapperDef.SFM_ProcessBusinessRule> bizRuleMetaInfo(String SFMProcessId)
    {
        //Query Process Biz Rules
        List<SVMXC__ServiceMax_Processes__c> lstProBizRules = new List<SVMXC__ServiceMax_Processes__c>();
        //lstProBizRules = Database.query('Select Id, SVMXC__Process1__c, SVMXC__Process1__r.SVMXC__Purpose__c,SVMXC__Confirmation_Message__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Process2__c, SVMXC__Child_Error_Msg__c, SVMXC__Process2__r.SVMXC__Target_Object_label__c, SVMXC__Process3__c, SVMXC__Parent_Error_Msg__c, SVMXC__Sequence__c From SVMXC__ServiceMax_Processes__c Where SVMXC__Process1__c =: SFMProcessId AND Recordtype.Name = \'Process Business Rule\' AND SVMXC__Process2__c != NULL AND SVMXC__Process3__c != NULL ORDER By SVMXC__Sequence__c');
        lstProBizRules = Database.query('Select Id, SVMXC__Process1__c, SVMXC__Process1__r.SVMXC__Purpose__c,SVMXC__Confirmation_Message__c, SVMXC__Active__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Process2__c, SVMXC__Child_Error_Msg__c, SVMXC__Process2__r.SVMXC__Target_Object_label__c, SVMXC__Process3__c, SVMXC__Parent_Error_Msg__c, SVMXC__Sequence__c,SVMXC__SM_Section__c,SVMXC__SM_Target_Section__c, SVMXC__Rule_Type__c From SVMXC__ServiceMax_Processes__c Where SVMXC__Process1__c =: SFMProcessId AND Recordtype.Name = \'Process Business Rule\' AND SVMXC__Process3__c != NULL ORDER By SVMXC__Sequence__c');
        system.debug(LoggingLevel.WARN, 'Process Biz Rules: ' + lstProBizRules);
        system.debug(LoggingLevel.WARN, 'SFMProcessId: ' + SFMProcessId);

        
        Set<ID> setBizRuleId = new Set<ID>();
        String TranslationKeys = '';
        for(SVMXC__ServiceMax_Processes__c ProBizRule : lstProBizRules){
            setBizRuleId.add(ProBizRule.SVMXC__Process3__c);
            if(ProBizRule.SVMXC__Parent_Error_Msg__c != NULL && ProBizRule.SVMXC__Parent_Error_Msg__c.length() > 0)
                TranslationKeys += ProBizRule.SVMXC__Parent_Error_Msg__c.replaceAll(' ', '_') + ';';
        }
            
        /* Start - Logic to translate SFM Data Validation Rule Error Message */
        if(TranslationKeys != NULL && TranslationKeys.length() > 0)
            lstProBizRules = new I18N_TranslationDelivery(TranslationKeys, UserInfo.getLanguage()).SVMX_GetProcessTranslation(lstProBizRules);  
        /* End */
        

        //Query Biz Rules.
        Map<ID, SVMXC__ServiceMax_Processes__c> mapBizRules = new Map<ID, SVMXC__ServiceMax_Processes__c>();
        mapBizRules.putAll((List<SVMXC__ServiceMax_Processes__c>) Database.query('Select SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__SM_Section__c, SVMXC__Message_Type__c, SVMXC__Source_Object_Name__c, SVMXC__Advance_Expression__c, SVMXC__Parent_Error_Msg__c, SVMXC__Rule_Type__c, Id,SVMXC__Sequence__c,SVMXC__SM_Target_Section__c From SVMXC__ServiceMax_Processes__c Where Recordtype.Name = \'Business Rule\' AND Id IN: setBizRuleId'));
        

        Map<ID, List<SVMXC__ServiceMax_Config_Data__c>> mapRuleIdRuleExplst = new Map<ID, List<SVMXC__ServiceMax_Config_Data__c>>();
         for(SVMXC__ServiceMax_Config_Data__c BizRuleExpr : [ Select Id, SVMXC__Description__c, SVMXC__Parameter_Type__c, SVMXC__Expression_Rule__c, SVMXC__Sequence__c,   SVMXC__Object_Name__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Formula__c, SVMXC__Action_Type__c, SVMXC__Expression_Type__c,  SVMXC__Display_Type__c, SVMXC__Expression_Rule__r.Mode_Of_Execution__c  From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c IN: setBizRuleId AND SVMXC__Expression_Rule__c != NULL AND ( SVMXC__Expression_Type__c = 'Business_Rule' OR SVMXC__Expression_Type__c = :SFM_Consts.EXPRESSION_TYPE_FIELD_UPDATE_RULE ) ] ) //added SVMXDEV__Expression_Rule__r.Mode_Of_Execution__c for BAC-5458
         {
             //Fix for defect : 034444
            if(BizRuleExpr.SVMXC__Formula__c != null && BizRuleExpr.SVMXC__Formula__c.length() > 0)
            {
                List<string> lstStrFormula = BizRuleExpr.SVMXC__Formula__c.split('\n');
                if(lstStrFormula != null && lstStrFormula.size() > 1)
                {
                    BizRuleExpr.SVMXC__Formula__c = '';
                    for(string strFormula : lstStrFormula)
                      BizRuleExpr.SVMXC__Formula__c += strFormula;
                }
            }
            
            if(!mapRuleIdRuleExplst.containsKey(BizRuleExpr.SVMXC__Expression_Rule__c))
                mapRuleIdRuleExplst.put(BizRuleExpr.SVMXC__Expression_Rule__c, new List<SVMXC__ServiceMax_Config_Data__c>());
            mapRuleIdRuleExplst.get(BizRuleExpr.SVMXC__Expression_Rule__c).add(BizRuleExpr);
        }
        
        List<SVMXC.SFM_WrapperDef.SFM_ProcessBusinessRule> lstProBizRuleWrapper = new List<SVMXC.SFM_WrapperDef.SFM_ProcessBusinessRule>();
 system.debug(LoggingLevel.WARN, 'Process Biz Rule Wrapper : ' + lstProBizRuleWrapper);
        for(SVMXC__ServiceMax_Processes__c ProBizRule : lstProBizRules)
        {
            if(ProBizRule.SVMXC__Process1__r.SVMXC__Purpose__c != NULL && ProBizRule.SVMXC__Process1__r.SVMXC__Purpose__c.equalsIgnoreCase('CHECKLIST'))
            {
                ID BizRuleId = ProBizRule.SVMXC__Process3__c;
                
                 system.debug(LoggingLevel.WARN, 'BizRuleId : ' + BizRuleId);
                 system.debug(LoggingLevel.WARN, 'mapBizRules.get(BizRuleId) : ' + mapBizRules.get(BizRuleId));
                 system.debug(LoggingLevel.WARN, 'mapRuleIdRuleExplst.get(BizRuleId) : ' + mapRuleIdRuleExplst.get(BizRuleId));
                if(mapBizRules.get(BizRuleId) != NULL && mapRuleIdRuleExplst.get(BizRuleId) != NULL)
                {
                    
                    SVMXC__ServiceMax_Processes__c obj = new SVMXC__ServiceMax_Processes__c();
                    obj = mapBizRules.get(BizRuleId);
                   
                    
                        system.debug(LoggingLevel.WARN, 'obj.SVMXC__Rule_Type__c : ' + obj.SVMXC__Rule_Type__c);
                        
                        lstProBizRuleWrapper.add(new SVMXC.SFM_WrapperDef.SFM_ProcessBusinessRule(Integer.valueOf(ProBizRule.SVMXC__Sequence__c), ProBizRule.SVMXC__Parent_Error_Msg__c, null, new SVMXC.SFM_WrapperDef.SFM_BizRuleInfo(obj, mapRuleIdRuleExplst.get(BizRuleId))));
                }
            }
            else if(ProBizRule.SVMXC__Process2__r.SVMXC__Target_Object_label__c != NULL)
            {
                ID BizRuleId = ProBizRule.SVMXC__Process3__c;
                if(mapBizRules.get(BizRuleId) != NULL && mapRuleIdRuleExplst.get(BizRuleId) != NULL)
                {
                    lstProBizRuleWrapper.add(new SVMXC.SFM_WrapperDef.SFM_ProcessBusinessRule(Integer.valueOf(ProBizRule.SVMXC__Sequence__c), ProBizRule.SVMXC__Parent_Error_Msg__c, ProBizRule.SVMXC__Process2__r.SVMXC__Target_Object_label__c, new SVMXC.SFM_WrapperDef.SFM_BizRuleInfo(mapBizRules.get(BizRuleId), mapRuleIdRuleExplst.get(BizRuleId))));
                }
            }
        }
        system.debug(LoggingLevel.WARN, 'Process Biz Rule Wrapper : ' + lstProBizRuleWrapper);
        return lstProBizRuleWrapper;
    }
}