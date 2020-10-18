public with sharing class EVER_Entitlement_Utils
{
    public EVER_Entitlement_Utils(){}
    //Method to identify applicable service for given Case.
    public map<string,string> identifyServiceForCase(Map<string,sObject> mapCase, string strSCONId)
    {
        list<SVMXC__Service_Contract_Services__c> lstCoveredServices = new list<SVMXC__Service_Contract_Services__c>();
        map<string,string> mapCaseEntitledService = new map<string,string>();
        try
        {
            if(mapCase != null && strSCONId != null && strSCONId.length() > 0)
            {
                lstCoveredServices = [select SVMXC__Service__c, SVMXC__Service__r.SVMXC__Qualifying_Criteria__c, SVMXC__Service__r.SVMXC__Tracked_On__c,  SVMXC__Service_Contract__c, Id from SVMXC__Service_Contract_Services__c where SVMXC__Service_Contract__c =: strSCONId and SVMXC__Service__c != null and SVMXC__Service__r.SVMXC__Tracked_On__c = 'Case'];
                if(mapCase != null && mapCase.size() > 0 && lstCoveredServices != null && lstCoveredServices.size() > 0)
                    mapCaseEntitledService = parseService(mapCase, lstCoveredServices);
            }
        }
        catch(exception ex)
        {
            return mapCaseEntitledService;
        }
        return mapCaseEntitledService;
    }
    
    // Method to identify applicable service for given Work Order.
    public map<string,string> identifyServiceForWorkOrd(Map<string,sObject> mapWorkOrd, string strSCONId)
    {
        map<string,string> mapWorkOrdEntitledService = new map<string,string>();
        list<SVMXC__Service_Contract_Services__c> lstCoveredServices = new list<SVMXC__Service_Contract_Services__c>();
        try
        {
            if(mapWorkOrd != null && strSCONId != null && strSCONId.length() > 0)
            {
                lstCoveredServices = [select SVMXC__Service__c, SVMXC__Service_Contract__c, SVMXC__Service__r.SVMXC__Qualifying_Criteria__c,  SVMXC__Service__r.SVMXC__Tracked_On__c, Id from SVMXC__Service_Contract_Services__c where SVMXC__Service_Contract__c =: strSCONId and SVMXC__Service__c != null and SVMXC__Service__r.SVMXC__Tracked_On__c = 'Work Order'];
                if(mapWorkOrd != null && mapWorkOrd.size() > 0 && lstCoveredServices != null && lstCoveredServices.size() > 0)
                    mapWorkOrdEntitledService = parseService(mapWorkOrd,lstCoveredServices);
            }
        }
        catch(exception ex)
        {
            return mapWorkOrdEntitledService;
        }
        return mapWorkOrdEntitledService;
    }
    
    //Method to identify services for list of Cases.
    public map<string,string> identifyServiceForCase(list<Case> lstCase)
    {
        list<SVMXC__Service_Contract_Services__c> lstCoveredServices = new list<SVMXC__Service_Contract_Services__c>();
        Map<string,sObject> mapCase = new Map<string,sObject>();
        map<string,string> mapCaseEntitledService = new map<string,string>();
        Map<string,string> mapCaseContract = new Map<string,string>();
        try
        {
            for(Case objCase : lstCase)
            {
                mapCase.put(objCase.Id, (sObject)objCase);
                if(objCase.SVMXC__Service_Contract__c != null)
                    mapCaseContract.put(objCase.Id, objCase.SVMXC__Service_Contract__c);
            }
            lstCoveredServices = [select SVMXC__Service__c, SVMXC__Service__r.SVMXC__Qualifying_Criteria__c, SVMXC__Service_Contract__c, Id, SVMXC__Service__r.SVMXC__Tracked_On__c from SVMXC__Service_Contract_Services__c where SVMXC__Service_Contract__c IN: mapCaseContract.values() and SVMXC__Service__c != null and SVMXC__Service__r.SVMXC__Tracked_On__c = 'Case' ];
            if(lstCoveredServices != null && lstCoveredServices.size() > 0 && mapCase != null && mapCase.size() > 0)
                mapCaseEntitledService = parseService(mapCase, lstCoveredServices);
        }
        catch(exception ex)
        {
            return mapCaseEntitledService;
        }
        return mapCaseEntitledService;
    }
    
    //Method to identify services for list of Work Order.
    public map<string,string> identifyServiceForWorkOrder(list<SVMXC__Service_Order__c> lstWorkOrder)
    {
        list<SVMXC__Service_Contract_Services__c> lstCoveredServices = new list<SVMXC__Service_Contract_Services__c>();
        Map<string,sObject> mapWorkOrder = new Map<string,sObject>();
        map<string,string> mapWorkOrdEntitledService = new map<string,string>();
        Map<string,string> mapWorkOrdContract = new Map<string,string>();
        try
        {
            for(SVMXC__Service_Order__c objWorkOrd : lstWorkOrder)
            {
                mapWorkOrder.put(objWorkOrd.Id, (sObject)objWorkOrd);
                if(objWorkOrd.SVMXC__Service_Contract__c != null)
                    mapWorkOrdContract.put(objWorkOrd.Id, objWorkOrd.SVMXC__Service_Contract__c);
            }
            lstCoveredServices = [select SVMXC__Service__c, SVMXC__Service_Contract__c, SVMXC__Service__r.SVMXC__Qualifying_Criteria__c, Id from SVMXC__Service_Contract_Services__c where SVMXC__Service_Contract__c IN: mapWorkOrdContract.values() and SVMXC__Service__c != null and SVMXC__Service__r.SVMXC__Tracked_On__c = 'Work Order'];
            if(lstCoveredServices != null && lstCoveredServices.size() > 0 && mapWorkOrder != null && mapWorkOrder.size() > 0)
                mapWorkOrdEntitledService = parseService(mapWorkOrder, lstCoveredServices);
        }
        catch(exception ex)
        {
            return mapWorkOrdEntitledService;
        }
        return mapWorkOrdEntitledService;
    }
    
    // Method to parse the given records and returns applicable expression rule.
    public map<string,string> parseService(Map<string,sObject> mapSobjRec, list<SVMXC__Service_Contract_Services__c> lstCoveredServices)
    {
        map<string,string> mapResult = new map<string,string>();
        map<Id, SVMXC__ServiceMax_Processes__c> mapSVMXRules = new map<Id, SVMXC__ServiceMax_Processes__c>();
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapRulesExpressions = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        map<string,string> mapCoveredService_ServiceRule = new map<string,string>();
        
        if(lstCoveredServices != null && lstCoveredServices.size() > 0)
        {
            
            for(SVMXC__Service_Contract_Services__c currService : lstCoveredServices)
                mapCoveredService_ServiceRule.put(currService.Id, currService.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c);
            
            // Query all Expressions Rule which are associated with Includede Service.
            mapSVMXRules.putAll([select Id, SVMXC__Advance_Expression__c, SVMXC__Sequence__c from SVMXC__ServiceMax_Processes__c where Id IN: mapCoveredService_ServiceRule.values()]);
            
            // Query expressions Config data Records.
            string StrgExpRTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name='Expressions' limit 1].Id;
            list<SVMXC__ServiceMax_Config_Data__c> lstExpressions = new list<SVMXC__ServiceMax_Config_Data__c>();
            lstExpressions = [Select SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, SVMXC__Sequence__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__Object_Name2__c, SVMXC__IsDefault__c, SVMXC__Internal_Value__c, SVMXC__Field_Relationship_Name__c, SVMXC__Field_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, SVMXC__Display_Value__c, SVMXC__Display_Type__c, RecordTypeId, Name From SVMXC__ServiceMax_Config_Data__c  where SVMXC__Expression_Rule__c IN: mapCoveredService_ServiceRule.values() and RecordTypeId =: StrgExpRTypeId and SVMXC__Expression_Type__c = 'EXP_Named'];
            for(SVMXC__ServiceMax_Config_Data__c oExpression: lstExpressions)
            {
                if(!mapRulesExpressions.containsKey(oExpression.SVMXC__Expression_Rule__c))
                    mapRulesExpressions.put(oExpression.SVMXC__Expression_Rule__c, new List<SVMXC__ServiceMax_Config_Data__c>());
                mapRulesExpressions.get(oExpression.SVMXC__Expression_Rule__c).add(oExpression);
            }
            // Call Expression Parsing utility.
            if(mapSobjRec != null)
            {
                for(string RecId: mapSobjRec.KeySet())
                {
                    sObject sObj = mapSobjRec.get(RecId);
                    for(SVMXC__Service_Contract_Services__c Service : lstCoveredServices)
                    {
                        if(Service.SVMXC__Service__c != null && Service.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c != null)
                        {
                            if(mapRulesExpressions.containsKey(Service.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c) && mapRulesExpressions.get(Service.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c) != null)
                            {
                                boolean IsRuleApplicable = false;
                                string strAdvancedExp = '';
                                if(mapSVMXRules != null && mapSVMXRules.get(Service.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c) != null)
                                    strAdvancedExp = (mapSVMXRules.get(Service.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c)).SVMXC__Advance_Expression__c;
                                
                                IsRuleApplicable = new COMM_Utils.COMM_ExpressionParsing().SVMX_ExpressionParsing(sObj, mapRulesExpressions.get(Service.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c), strAdvancedExp);
                                
                                if(IsRuleApplicable)
                                {
                                    mapResult.put(RecId, Service.Id);
                                    break;
                                }
                            }
                        }
                        else if(Service.SVMXC__Service__c != null)
                        {
                            mapResult.put(sObj.Id, Service.Id);
                            break;
                        }
                    }
                }
            }
            system.debug('Service Record Id: '+mapResult );
        }
        return mapResult;
    }
    // Method to update threshold count for Case and Work Order in intractive mode.
    public map<string,string> manageServiceThresholdCount(string ObjectName, string RecId, string strSCONId, string EntitledServiceId)
    {
        map<string,string> mapServiceId_status = new map<string,string>();
        if(ObjectName == null && ObjectName.length() > 0 )
        {
            mapServiceId_status.put(EntitledServiceId, 'NOT_APPLICABLE');
            return mapServiceId_status; 
        }
        try
        {
            // Query the active entitlement history.
            list<SVMXC__Entitlement_History__c> lstActiveExistingHistoryRec = new  list<SVMXC__Entitlement_History__c> ();
            if(ObjectName.equalsIgnoreCase('Case'))
                lstActiveExistingHistoryRec = [select Id, SVMXC__Inactive_Date__c, SVMXC__Entitled_By_Service__c, SVMXC__Case__c  from SVMXC__Entitlement_History__c where SVMXC__Inactive_Date__c  = null and SVMXC__Case__c =: RecId LIMIT 1];
            else if(ObjectName.equalsIgnoreCase('SVMXC__Service_Order__c'))
                lstActiveExistingHistoryRec = [select Id, SVMXC__Inactive_Date__c, SVMXC__Entitled_By_Service__c, SVMXC__Case__c from SVMXC__Entitlement_History__c where SVMXC__Inactive_Date__c  = null and SVMXC__Service_Order__c =: RecId LIMIT 1];
            
            // If history exists, retrieve included service record and decrease consumed unit by 1
            if(lstActiveExistingHistoryRec != null && lstActiveExistingHistoryRec.size() == 1 )
            {
                list<SVMXC__Service_Contract_Services__c> lstEntitledServiceOld = [Select Id, SVMXC__Service__c, SVMXC__Consumed_Units__c, SVMXC__Included_Units__c, SVMXC__Service_Contract__c from SVMXC__Service_Contract_Services__c where Id =: lstActiveExistingHistoryRec[0].SVMXC__Entitled_By_Service__c limit 1];
                try
                {
                    if(lstEntitledServiceOld != null && lstEntitledServiceOld.size() == 1 && lstEntitledServiceOld[0].SVMXC__Consumed_Units__c != null && lstEntitledServiceOld[0].SVMXC__Consumed_Units__c != 0)
                    {
                        lstEntitledServiceOld[0].SVMXC__Consumed_Units__c = integer.valueOf(lstEntitledServiceOld[0].SVMXC__Consumed_Units__c) - 1;
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstEntitledServiceOld[0], COMM_SecurityUtils.Access.Updateable ) ) {
                        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        update lstEntitledServiceOld[0];
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    }
                } catch(exception ex){}
            }
            if(EntitledServiceId != null && EntitledServiceId.length() > 0 && strSCONId != null && strSCONId.length() > 0)
            {
                // Update consumed unit.
                list<SVMXC__Service_Contract_Services__c> lstEntitledService = [Select Id, SVMXC__Consumed_Units__c, SVMXC__Service__c, SVMXC__Included_Units__c, SVMXC__Service_Contract__c from SVMXC__Service_Contract_Services__c where SVMXC__Service_Contract__c =:strSCONId AND Id =: EntitledServiceId limit 1];
                if(lstEntitledService != null && lstEntitledService.size() == 1)
                {
                    try
                    {
                        lstEntitledService[0].SVMXC__Consumed_Units__c += 1;
                    }
                    catch(exception ex)
                    {
                        SVMXC__Service_Contract_Services__c tempServiceObj = new SVMXC__Service_Contract_Services__c(SVMXC__Consumed_Units__c = 0);
                        lstEntitledService[0].SVMXC__Consumed_Units__c = tempServiceObj.SVMXC__Consumed_Units__c;
                        lstEntitledService[0].SVMXC__Consumed_Units__c += 1;
                    }
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstEntitledService[0], COMM_SecurityUtils.Access.Updateable ) ) {
                        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    update lstEntitledService[0];
                    } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                }
                if(lstEntitledService[0].SVMXC__Included_Units__c == null || lstEntitledService[0].SVMXC__Included_Units__c == 0)
                    mapServiceId_status.put(lstEntitledService[0].Id, 'NOT_APPLICABLE');
                else if(lstEntitledService[0].SVMXC__Included_Units__c >= lstEntitledService[0].SVMXC__Consumed_Units__c)
                    mapServiceId_status.put(lstEntitledService[0].Id, 'WITHIN_THRESHOLD');
                else if(lstEntitledService[0].SVMXC__Included_Units__c < lstEntitledService[0].SVMXC__Consumed_Units__c)
                    mapServiceId_status.put(lstEntitledService[0].Id, 'OUTSIDE_THRESHOLD');
            }
            system.debug('Result: '+mapServiceId_status);
            return mapServiceId_status;
        }
        catch(exception ex)
        {
            system.debug('Error: '+ex.getMessage());
            mapServiceId_status.put('NOT_APPLICABLE', 'NOT_APPLICABLE');
            return mapServiceId_status;
        }
    }
    // Method to update threshold count for Auto mode in Case.
    public map<string,map<string,string>> manageServiceThresholdCount(list<Case> lstNewCase, map<string, string> mapCaseEntitledServiceId, boolean isUpdateThreshold)
    {
        list<SVMXC__Entitlement_History__c> lstActiveExistingHistoryRec = new  list<SVMXC__Entitlement_History__c>();
        list<SVMXC__Service_Contract_Services__c> lstExistingIncludedServiceOld = new list<SVMXC__Service_Contract_Services__c>();
        list<SVMXC__Service_Contract_Services__c> lstEntitledServiceTobeUpdate = new list<SVMXC__Service_Contract_Services__c>();
        map<string,map<string,string>> mapCase_mapServiceStatus = new map<string,map<string,string>>();
        map<string,string> mapServiceId_status = new map<string,string>();
        set<string> setRecIds = new set<string>();
        try
        {
            set<string> setContractIds = new set<string>();
            for(Case objCase : lstNewCase)
            {
                setRecIds.add(objCase.Id);
                if(objCase.SVMXC__Service_Contract__c != null)
                    setContractIds.add(objCase.SVMXC__Service_Contract__c);
            }
            // Query the existing active History Rec.
            lstActiveExistingHistoryRec = [select Id, SVMXC__Inactive_Date__c, SVMXC__Entitled_By_Service__c, SVMXC__Case__c  from SVMXC__Entitlement_History__c where SVMXC__Inactive_Date__c  = null and SVMXC__Case__c IN: setRecIds];
            
            if(lstActiveExistingHistoryRec != null && lstActiveExistingHistoryRec.size() > 0 )
            {
                set<string> setServiceIds = new set<string>();
                for(SVMXC__Entitlement_History__c objHistory : lstActiveExistingHistoryRec)
                {
                    if(objHistory.SVMXC__Entitled_By_Service__c != null)
                        setServiceIds.add(objHistory.SVMXC__Entitled_By_Service__c);
                }
                // Query the existing Entitled Services associated with History Rec and decrease Consumed Unit by 1.
                lstExistingIncludedServiceOld = [Select Id, SVMXC__Service__c, SVMXC__Consumed_Units__c, SVMXC__Included_Units__c, SVMXC__Service_Contract__c from SVMXC__Service_Contract_Services__c where Id IN: setServiceIds];
                if(lstExistingIncludedServiceOld != null && lstExistingIncludedServiceOld.size() > 0)
                {
                    try
                    {
                        for(SVMXC__Service_Contract_Services__c CurrService : lstExistingIncludedServiceOld)
                        {
                            if(CurrService.SVMXC__Consumed_Units__c != null && CurrService.SVMXC__Consumed_Units__c != 0)
                                CurrService.SVMXC__Consumed_Units__c = integer.valueOf(CurrService.SVMXC__Consumed_Units__c) - 1;
                        }
                        if(isUpdateThreshold){
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstExistingIncludedServiceOld, COMM_SecurityUtils.Access.Updateable ) ) {
                            //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        update lstExistingIncludedServiceOld;
                        } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                        }
                    }catch(exception ex){}
                }
            }
            if(setContractIds != null && setContractIds.size() > 0 && mapCaseEntitledServiceId != null && mapCaseEntitledServiceId.size() > 0)
            {
                map<string,SVMXC__Service_Contract_Services__c> mapEntitledServices = new map<string,SVMXC__Service_Contract_Services__c>();
                list<SVMXC__Service_Contract_Services__c> lstNewIncludedService = [Select Id, SVMXC__Consumed_Units__c, SVMXC__Service__r.SVMXC__Qualifying_Criteria__c, SVMXC__Service__c, SVMXC__Included_Units__c, SVMXC__Service_Contract__c from SVMXC__Service_Contract_Services__c where Id IN: mapCaseEntitledServiceId.values() AND SVMXC__Service_Contract__c IN: setContractIds];
                mapEntitledServices.putAll(lstNewIncludedService);
                
                if(mapEntitledServices != null && mapEntitledServices.size() > 0)
                {
                    set<Id> setEntitledServiceIds = new set<id>();
                    for(Case objCase : lstNewCase)
                    {
                        if(mapCaseEntitledServiceId.containsKey(objCase.Id) && mapCaseEntitledServiceId.get(objCase.Id) != null && mapEntitledServices.containsKey(mapCaseEntitledServiceId.get(objCase.Id)) && mapEntitledServices.get(mapCaseEntitledServiceId.get(objCase.Id)) != null)
                        {
                            SVMXC__Service_Contract_Services__c objEntitledServiceTemp = new SVMXC__Service_Contract_Services__c();
                            objEntitledServiceTemp = mapEntitledServices.get(mapCaseEntitledServiceId.get(objCase.Id));
                            try
                            {
                                objEntitledServiceTemp.SVMXC__Consumed_Units__c += 1;
                            }
                            catch(exception ex)
                            {
                                SVMXC__Service_Contract_Services__c tempServiceObj = new SVMXC__Service_Contract_Services__c(SVMXC__Consumed_Units__c = 0);
                                objEntitledServiceTemp.SVMXC__Consumed_Units__c = tempServiceObj.SVMXC__Consumed_Units__c;
                                objEntitledServiceTemp.SVMXC__Consumed_Units__c += 1;
                            } 
                            mapServiceId_status = new map<string,string>();
                            if(objEntitledServiceTemp.SVMXC__Included_Units__c == null || objEntitledServiceTemp.SVMXC__Included_Units__c == 0)
                                mapServiceId_status.put(objEntitledServiceTemp.Id, 'NOT_APPLICABLE');
                            else if(objEntitledServiceTemp.SVMXC__Included_Units__c >= objEntitledServiceTemp.SVMXC__Consumed_Units__c)
                                mapServiceId_status.put(objEntitledServiceTemp.Id, 'WITHIN_THRESHOLD');
                            else if(objEntitledServiceTemp.SVMXC__Included_Units__c < objEntitledServiceTemp.SVMXC__Consumed_Units__c)
                                mapServiceId_status.put(objEntitledServiceTemp.Id, 'OUTSIDE_THRESHOLD');
                            mapCase_mapServiceStatus.put(objCase.Id, mapServiceId_status);
                            if(setEntitledServiceIds != null && !setEntitledServiceIds.contains(objEntitledServiceTemp.Id))
                            {
                                lstEntitledServiceTobeUpdate.add(objEntitledServiceTemp);
                                setEntitledServiceIds.add(objEntitledServiceTemp.Id);
                            }
                        }
                    }
                    if(isUpdateThreshold){
                        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstEntitledServiceTobeUpdate, COMM_SecurityUtils.Access.Upsertable ) ) {
                        upsert lstEntitledServiceTobeUpdate;
                        } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                        
                    }
                }
            }
            return mapCase_mapServiceStatus;
        }
        catch(exception ex)
        {
            mapServiceId_status.put('NOT_APPLICABLE', 'NOT_APPLICABLE');
            mapCase_mapServiceStatus.put('NOT_APPLICABLE', mapServiceId_status);
            return mapCase_mapServiceStatus;
        }
    }
    
    // Method to update threshold count for Auto mode in Work Order.
    public map<string,map<string,string>> manageServiceThresholdCount(list<SVMXC__Service_Order__c> lstWorkOrder, map<string, string> mapWorkOrdEntitledServiceIds, boolean isUpdateThreshold)
    {
        list<SVMXC__Entitlement_History__c> lstActiveExistingHistoryRec = new  list<SVMXC__Entitlement_History__c>();
        list<SVMXC__Service_Contract_Services__c> lstExistingIncludedServiceOld = new list<SVMXC__Service_Contract_Services__c>();
        list<SVMXC__Service_Contract_Services__c> lstEntitledServiceTobeUpdate = new list<SVMXC__Service_Contract_Services__c>();
        map<string,map<string,string>> mapWorkOrd_mapServiceStatus = new map<string,map<string,string>>();
        map<string,string> mapServiceId_status = new map<string,string>();
        set<string> setRecIds = new set<string>();
        try
        {
            set<string> setContractIds = new set<string>();
            for(SVMXC__Service_Order__c objWorkOrd : lstWorkOrder)
            {
                setRecIds.add(objWorkOrd.Id);
                if(objWorkOrd.SVMXC__Service_Contract__c != null)
                    setContractIds.add(objWorkOrd.SVMXC__Service_Contract__c);
            }
            // Query the existing active History Rec.
            lstActiveExistingHistoryRec = [select Id, SVMXC__Inactive_Date__c, SVMXC__Entitled_By_Service__c, SVMXC__Case__c  from SVMXC__Entitlement_History__c where SVMXC__Inactive_Date__c  = null and SVMXC__Service_Order__c IN: setRecIds];
            
            if(lstActiveExistingHistoryRec != null && lstActiveExistingHistoryRec.size() > 0 )
            {
                set<string> setServiceIds = new set<string>();
                for(SVMXC__Entitlement_History__c objHistory : lstActiveExistingHistoryRec)
                {
                    if(objHistory.SVMXC__Entitled_By_Service__c != null)
                        setServiceIds.add(objHistory.SVMXC__Entitled_By_Service__c);
                }
                
                // Query the existing Entitled Services associated with History Rec and decrease Consumed Unit by 1.
                lstExistingIncludedServiceOld = [Select Id, SVMXC__Service__c, SVMXC__Consumed_Units__c, SVMXC__Included_Units__c, SVMXC__Service_Contract__c from SVMXC__Service_Contract_Services__c where Id IN: setServiceIds];
                if(lstExistingIncludedServiceOld != null && lstExistingIncludedServiceOld.size() > 0)
                {
                    try
                    {
                        for(SVMXC__Service_Contract_Services__c CurrService : lstExistingIncludedServiceOld)
                        {
                            if(CurrService.SVMXC__Consumed_Units__c != null && CurrService.SVMXC__Consumed_Units__c != 0)
                                CurrService.SVMXC__Consumed_Units__c = integer.valueOf(CurrService.SVMXC__Consumed_Units__c) - 1;
                        }
                        if(isUpdateThreshold){
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstExistingIncludedServiceOld, COMM_SecurityUtils.Access.Updateable ) ) {
                            //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        update lstExistingIncludedServiceOld;
                        } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                        }
                            
                    }catch(exception ex){}
                }
            }
            
            if(setContractIds != null && setContractIds.size() > 0 && mapWorkOrdEntitledServiceIds != null && mapWorkOrdEntitledServiceIds.size() > 0)
            {
                map<string,SVMXC__Service_Contract_Services__c> mapEntitledServices = new map<string,SVMXC__Service_Contract_Services__c>();
                list<SVMXC__Service_Contract_Services__c> lstNewIncludedService = [Select Id, SVMXC__Consumed_Units__c, SVMXC__Service__r.SVMXC__Qualifying_Criteria__c, SVMXC__Service__c, SVMXC__Included_Units__c, SVMXC__Service_Contract__c from SVMXC__Service_Contract_Services__c where Id IN: mapWorkOrdEntitledServiceIds.values() AND SVMXC__Service_Contract__c IN: setContractIds];
                mapEntitledServices.putAll(lstNewIncludedService);
                
                if(mapEntitledServices != null && mapEntitledServices.size() > 0)
                {
                    set<Id> setEntitledServiceIds = new set<id>();
                    for(SVMXC__Service_Order__c objWorkOrd : lstWorkOrder)
                    {
                        if(mapWorkOrdEntitledServiceIds.containsKey(objWorkOrd.Id) && mapWorkOrdEntitledServiceIds.get(objWorkOrd.Id) != null && mapEntitledServices.containsKey(mapWorkOrdEntitledServiceIds.get(objWorkOrd.Id)) && mapEntitledServices.get(mapWorkOrdEntitledServiceIds.get(objWorkOrd.Id)) != null)
                        {
                            SVMXC__Service_Contract_Services__c objEntitledServiceTemp = new SVMXC__Service_Contract_Services__c();
                            objEntitledServiceTemp = mapEntitledServices.get(mapWorkOrdEntitledServiceIds.get(objWorkOrd.Id));
                            try
                            {
                                objEntitledServiceTemp.SVMXC__Consumed_Units__c += 1;
                            }
                            catch(exception ex)
                            {
                                SVMXC__Service_Contract_Services__c tempServiceObj = new SVMXC__Service_Contract_Services__c(SVMXC__Consumed_Units__c = 0);
                                objEntitledServiceTemp.SVMXC__Consumed_Units__c = tempServiceObj.SVMXC__Consumed_Units__c;
                                objEntitledServiceTemp.SVMXC__Consumed_Units__c += 1;
                            } 
                            mapServiceId_status = new map<string,string>();
                            if(objEntitledServiceTemp.SVMXC__Included_Units__c == null || objEntitledServiceTemp.SVMXC__Included_Units__c == 0)
                                mapServiceId_status.put(objEntitledServiceTemp.Id, 'NOT_APPLICABLE');
                            else if(objEntitledServiceTemp.SVMXC__Included_Units__c >= objEntitledServiceTemp.SVMXC__Consumed_Units__c)
                                mapServiceId_status.put(objEntitledServiceTemp.Id, 'WITHIN_THRESHOLD');
                            else if(objEntitledServiceTemp.SVMXC__Included_Units__c < objEntitledServiceTemp.SVMXC__Consumed_Units__c)
                                mapServiceId_status.put(objEntitledServiceTemp.Id, 'OUTSIDE_THRESHOLD');
                            mapWorkOrd_mapServiceStatus.put(objWorkOrd.Id, mapServiceId_status);
                            if(setEntitledServiceIds != null && !setEntitledServiceIds.contains(objEntitledServiceTemp.Id))
                            {
                                lstEntitledServiceTobeUpdate.add(objEntitledServiceTemp);
                                setEntitledServiceIds.add(objEntitledServiceTemp.Id);
                            }
                        }
                    }
                    if(isUpdateThreshold){
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstEntitledServiceTobeUpdate, COMM_SecurityUtils.Access.Upsertable ) ) {
                        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert lstEntitledServiceTobeUpdate;
                    } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    }
                        
                }
            }
            system.debug('Case with Included Services rec: '+mapWorkOrd_mapServiceStatus);
            return mapWorkOrd_mapServiceStatus;
        }
        catch(exception ex)
        {
            system.debug('Error: '+ex.getMessage());
            mapServiceId_status.put('NOT_APPLICABLE', 'NOT_APPLICABLE');
            mapWorkOrd_mapServiceStatus.put('NOT_APPLICABLE', mapServiceId_status);
            return mapWorkOrd_mapServiceStatus;
        }
    }
    
    // Method called from before insert/update
    public map<integer,string> identifyServicesForIndexedRecs(map<integer, Case> mapIndexdCase, map<integer, SVMXC__Service_Order__c> mapIndexdWorkOrd)
    {
        list<SVMXC__Service_Contract_Services__c> lstCoveredServices = new list<SVMXC__Service_Contract_Services__c>();
        Map<integer,sObject> mapIndexSobjRec = new Map<integer,sObject>();
        map<Id, SVMXC__ServiceMax_Processes__c> mapSVMXRules = new map<Id, SVMXC__ServiceMax_Processes__c>();
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapRulesExpressions = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        map<integer,string> mapResult = new map<integer,string>();
        set<string> setContractIds = new set<string>();
        try
        {
            if(mapIndexdCase != null && mapIndexdCase.size() > 0 && mapIndexdWorkOrd == null)
            {
                setContractIds.clear();
                for(integer index : mapIndexdCase.keySet())
                {
                    mapIndexSobjRec.put(index, (sObject)mapIndexdCase.get(index));
                    if((mapIndexdCase.get(index)).SVMXC__Service_Contract__c != null)
                        setContractIds.add(mapIndexdCase.get(index).SVMXC__Service_Contract__c);
                }
            }
            else if(mapIndexdWorkOrd != null && mapIndexdWorkOrd.size() > 0 && mapIndexdCase == null)
            {
                setContractIds.clear();
                for(integer index : mapIndexdWorkOrd.keySet())
                {
                    mapIndexSobjRec.put(index, (sObject)mapIndexdWorkOrd.get(index));
                    if((mapIndexdWorkOrd.get(index)).SVMXC__Service_Contract__c != null)
                        setContractIds.add(mapIndexdWorkOrd.get(index).SVMXC__Service_Contract__c);
                }
            }
            
            // Query the list of Included Services for abaove retrieved Service Contracts.
            if(mapIndexdCase != null && mapIndexdCase.size() > 0 && mapIndexdWorkOrd == null)
                lstCoveredServices = [select SVMXC__Service__c, SVMXC__Service__r.SVMXC__Qualifying_Criteria__c, SVMXC__Service_Contract__c, Id, SVMXC__Service__r.SVMXC__Tracked_On__c from SVMXC__Service_Contract_Services__c where SVMXC__Service_Contract__c IN: setContractIds and SVMXC__Service__c != null and SVMXC__Service__r.SVMXC__Tracked_On__c = 'Case' ];
            else if(mapIndexdWorkOrd != null && mapIndexdWorkOrd.size() > 0 && mapIndexdCase == null)
                lstCoveredServices = [select SVMXC__Service__c, SVMXC__Service__r.SVMXC__Qualifying_Criteria__c, SVMXC__Service_Contract__c, Id, SVMXC__Service__r.SVMXC__Tracked_On__c from SVMXC__Service_Contract_Services__c where SVMXC__Service_Contract__c IN: setContractIds and SVMXC__Service__c != null and SVMXC__Service__r.SVMXC__Tracked_On__c = 'Work Order' ];
            
            if(lstCoveredServices != null && lstCoveredServices.size() > 0)
            {
                map<string,string> mapCoveredService_ServiceRule = new map<string,string>();
                for(SVMXC__Service_Contract_Services__c currService : lstCoveredServices)
                    mapCoveredService_ServiceRule.put(currService.Id, currService.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c);
                
                // Query all Expressions Rule which are associated with Includede Service.
                mapSVMXRules.putAll([select Id, SVMXC__Advance_Expression__c, SVMXC__Sequence__c from SVMXC__ServiceMax_Processes__c where Id IN: mapCoveredService_ServiceRule.values()]);
                
                // Query expressions Config data Records.
                string StrgExpRTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name='Expressions' limit 1].Id;
                list<SVMXC__ServiceMax_Config_Data__c> lstExpressions = new list<SVMXC__ServiceMax_Config_Data__c>();
                lstExpressions = [Select SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, SVMXC__Sequence__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__Object_Name2__c, SVMXC__IsDefault__c, SVMXC__Internal_Value__c, SVMXC__Field_Relationship_Name__c, SVMXC__Field_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, SVMXC__Display_Value__c, SVMXC__Display_Type__c, RecordTypeId, Name From SVMXC__ServiceMax_Config_Data__c  where SVMXC__Expression_Rule__c IN: mapCoveredService_ServiceRule.values() and RecordTypeId =: StrgExpRTypeId and SVMXC__Expression_Type__c = 'EXP_Named'];
                
                
                for(SVMXC__ServiceMax_Config_Data__c oExpression: lstExpressions)
                {
                    if(!mapRulesExpressions.containsKey(oExpression.SVMXC__Expression_Rule__c))
                        mapRulesExpressions.put(oExpression.SVMXC__Expression_Rule__c, new List<SVMXC__ServiceMax_Config_Data__c>());
                    mapRulesExpressions.get(oExpression.SVMXC__Expression_Rule__c).add(oExpression);
                }
                
                // Call Expression Parsing utility.
                if(mapIndexSobjRec != null)
                {
                    for(integer index : mapIndexSobjRec.KeySet())
                    {
                        sObject sObj = mapIndexSobjRec.get(index);
                        for(SVMXC__Service_Contract_Services__c Service : lstCoveredServices)
                        {
                            if(Service.SVMXC__Service__c != null && Service.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c != null)
                            {
                                if(mapRulesExpressions.containsKey(Service.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c) && mapRulesExpressions.get(Service.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c) != null)
                                {
                                    boolean IsRuleApplicable = false;
                                    string strAdvancedExp = '';
                                    if(mapSVMXRules != null && mapSVMXRules.get(Service.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c) != null)
                                        strAdvancedExp = (mapSVMXRules.get(Service.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c)).SVMXC__Advance_Expression__c;
                                    
                                    IsRuleApplicable = new COMM_Utils.COMM_ExpressionParsing().SVMX_ExpressionParsing(sObj, mapRulesExpressions.get(Service.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c), strAdvancedExp);
                                    if(IsRuleApplicable)
                                    {
                                        mapResult.put(index, Service.Id);
                                        break;
                                    }
                                }
                            }
                            else if(Service.SVMXC__Service__c != null)
                            {
                                mapResult.put(index, Service.Id);
                                break;
                            }
                        }
                    }
                }
            }
        }
        catch(exception ex)
        {
            system.debug('Error: '+ex.getMessage());
            return null;
        }
        system.debug('Respone: '+mapResult);
        return mapResult;
    }
    
    // Method called from before insert/update
    public map<integer,map<string,string>> manageServiceThresholdCount(list<Case> lstCase, list<SVMXC__Service_Order__c> lstWorkOrder, map<integer, string> mapSobjIndexWithService)
    {
        list<SVMXC__Entitlement_History__c> lstActiveExistingHistoryRec = new  list<SVMXC__Entitlement_History__c>();
        
        map<integer,map<string,string>> mapCase_mapServiceStatus = new map<integer,map<string,string>>();
        map<string,string> mapServiceId_status = new map<string,string>();
        set<string> setSCONIds = new set<string>();
        try
        {
            if(lstCase != null && lstCase.size() > 0)
            {
                for(integer i=0; i<lstCase.size(); i++)
                    if((lstCase[i].SVMXC__Service_Contract__c != null))
                        setSCONIds.add(lstCase[i].SVMXC__Service_Contract__c);
            }
            else if(lstWorkOrder != null && lstWorkOrder.size() > 0)
            {
                for(integer i=0; i<lstWorkOrder.size(); i++)
                    if((lstWorkOrder[i].SVMXC__Service_Contract__c != null))
                        setSCONIds.add(lstWorkOrder[i].SVMXC__Service_Contract__c);
            }
            
            map<string,SVMXC__Service_Contract_Services__c> mapEntitledServices = new map<string,SVMXC__Service_Contract_Services__c>();
            mapEntitledServices.putAll([Select Id, SVMXC__Consumed_Units__c, SVMXC__Service__r.SVMXC__Qualifying_Criteria__c, SVMXC__Service__c, SVMXC__Included_Units__c, SVMXC__Service_Contract__c from SVMXC__Service_Contract_Services__c where Id IN: mapSobjIndexWithService.values() AND SVMXC__Service_Contract__c IN: setSCONIds]);
            
            if(mapEntitledServices != null && mapEntitledServices.size() > 0)
            {
                if(lstCase != null && lstCase.size() > 0)
                {
                    for(integer i=0; i<lstCase.size(); i++)
                    {
                        if(mapSobjIndexWithService.containsKey(i) && mapSobjIndexWithService.get(i) != null && mapEntitledServices.containsKey(mapSobjIndexWithService.get(i)) && mapEntitledServices.get(mapSobjIndexWithService.get(i)) != null)
                        {
                            SVMXC__Service_Contract_Services__c objEntitledServiceTemp = new SVMXC__Service_Contract_Services__c();
                            objEntitledServiceTemp = mapEntitledServices.get(mapSobjIndexWithService.get(i));
                            system.debug('Service Data: '+objEntitledServiceTemp);
                            try
                            {
                                objEntitledServiceTemp.SVMXC__Consumed_Units__c += 1;
                            }
                            catch(exception ex)// If any service have null SVMXC__Consumed_Units__c, than handle it in catch block.
                            {
                                SVMXC__Service_Contract_Services__c tempServiceObj = new SVMXC__Service_Contract_Services__c();
                                tempServiceObj.SVMXC__Consumed_Units__c = 0;
                                objEntitledServiceTemp.SVMXC__Consumed_Units__c = tempServiceObj.SVMXC__Consumed_Units__c;
                                objEntitledServiceTemp.SVMXC__Consumed_Units__c += 1;
                            } 
                            mapServiceId_status = new map<string,string>();
                            if(objEntitledServiceTemp.SVMXC__Included_Units__c == null || objEntitledServiceTemp.SVMXC__Included_Units__c == 0)
                                mapServiceId_status.put(objEntitledServiceTemp.Id, 'NOT_APPLICABLE');
                            else if(objEntitledServiceTemp.SVMXC__Included_Units__c >= objEntitledServiceTemp.SVMXC__Consumed_Units__c)
                                mapServiceId_status.put(objEntitledServiceTemp.Id, 'WITHIN_THRESHOLD');
                            else if(objEntitledServiceTemp.SVMXC__Included_Units__c < objEntitledServiceTemp.SVMXC__Consumed_Units__c)
                                mapServiceId_status.put(objEntitledServiceTemp.Id, 'OUTSIDE_THRESHOLD');
                            mapCase_mapServiceStatus.put(i, mapServiceId_status);
                        }
                    }
                }
                else if(lstWorkOrder != null && lstWorkOrder.size() > 0)
                {
                    for(integer i=0; i<lstWorkOrder.size(); i++)
                    {
                        if(mapSobjIndexWithService.containsKey(i) && mapSobjIndexWithService.get(i) != null && mapEntitledServices.containsKey(mapSobjIndexWithService.get(i)) && mapEntitledServices.get(mapSobjIndexWithService.get(i)) != null)
                        {
                            SVMXC__Service_Contract_Services__c objEntitledServiceTemp = new SVMXC__Service_Contract_Services__c();
                            objEntitledServiceTemp = mapEntitledServices.get(mapSobjIndexWithService.get(i));
                            try
                            {
                                objEntitledServiceTemp.SVMXC__Consumed_Units__c += 1;
                            }
                            catch(exception ex)// If any service have null SVMXC__Consumed_Units__c, than handle it in catch block.
                            {
                                SVMXC__Service_Contract_Services__c tempServiceObj = new SVMXC__Service_Contract_Services__c();
                                tempServiceObj.SVMXC__Consumed_Units__c = 0;
                                objEntitledServiceTemp.SVMXC__Consumed_Units__c = tempServiceObj.SVMXC__Consumed_Units__c;
                                objEntitledServiceTemp.SVMXC__Consumed_Units__c += 1;
                            } 
                            mapServiceId_status = new map<string,string>();
                            if(objEntitledServiceTemp.SVMXC__Included_Units__c == null || objEntitledServiceTemp.SVMXC__Included_Units__c == 0)
                                mapServiceId_status.put(objEntitledServiceTemp.Id, 'NOT_APPLICABLE');
                            else if(objEntitledServiceTemp.SVMXC__Included_Units__c >= objEntitledServiceTemp.SVMXC__Consumed_Units__c)
                                mapServiceId_status.put(objEntitledServiceTemp.Id, 'WITHIN_THRESHOLD');
                            else if(objEntitledServiceTemp.SVMXC__Included_Units__c < objEntitledServiceTemp.SVMXC__Consumed_Units__c)
                                mapServiceId_status.put(objEntitledServiceTemp.Id, 'OUTSIDE_THRESHOLD');
                            mapCase_mapServiceStatus.put(i, mapServiceId_status);
                        }
                    }
                }
            }
            return mapCase_mapServiceStatus;
        }
        catch(exception ex)
        {
            system.debug('Error: '+ex.getMessage());
            mapServiceId_status.put('NOT_APPLICABLE', 'NOT_APPLICABLE');
            mapCase_mapServiceStatus.put(-1, mapServiceId_status);
            return mapCase_mapServiceStatus;
        }
    }
    // Changes for Included services ***
    // method for getting services of service Contract
    public void GetServicesOfSCON(List<EVER_SCResults> lstSCResults, String strobjectName, sObject sObj, boolean isShowAllServices, String strSelectSC, String strSlectSCIS)
    {
        Map<Id, SVMXC__Service_Contract_Services__c> mapCoveredServices = new Map<Id, SVMXC__Service_Contract_Services__c>();
        list<SVMXC__Service_Contract_Services__c> lstCoveredServices = new list<SVMXC__Service_Contract_Services__c>();
        map<Id, SVMXC__ServiceMax_Processes__c> mapSVMXRules = new map<Id, SVMXC__ServiceMax_Processes__c>();
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapRulesExpressions = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        set<string> setContractIds = new set<string>();
        map<ID, List<SVMXC__Service_Contract_Services__c>> mapValidServiceNSCON = new map<ID, List<SVMXC__Service_Contract_Services__c>>();
        map<ID, List<SVMXC__Service_Contract_Services__c>> mapUnValidServiceNSCON = new map<ID, List<SVMXC__Service_Contract_Services__c>>();
        map<ID, List<SVMXC__Service_Contract_Services__c>> mapValidUntracdServiceNSCON = new map<ID, List<SVMXC__Service_Contract_Services__c>>();
        map<ID, List<SVMXC__Service_Contract_Services__c>> mapUnValidUntracdServiceNSCON = new map<ID, List<SVMXC__Service_Contract_Services__c>>();
        try
        {
            System.debug('log taken all service or not : '+isShowAllServices);
            for(EVER_SCResults SCResult : lstSCResults)
            {
                if(SCResult.SCId != null)
                {
                    setContractIds.add(SCResult.SCId);
                    mapValidServiceNSCON.put(SCResult.SCId, new List<SVMXC__Service_Contract_Services__c>());
                    mapUnValidServiceNSCON.put(SCResult.SCId, new List<SVMXC__Service_Contract_Services__c>());
                    mapValidUntracdServiceNSCON.put(SCResult.SCId, new List<SVMXC__Service_Contract_Services__c>());
                    mapUnValidUntracdServiceNSCON.put(SCResult.SCId, new List<SVMXC__Service_Contract_Services__c>());
                }
            }
            
            // Query the list of Included Services for abaove retrieved Service Contracts.
            if(setContractIds != null && setContractIds.size() >0)
            {
                if(strobjectName == 'Case') 
                    mapCoveredServices.putAll([select SVMXC__Service__c, SVMXC__Service__r.Name, SVMXC__Is_Billable__c, SVMXC__Included_Units__c, SVMXC__Consumed_Units__c ,SVMXC__Service__r.SVMXC__Qualifying_Criteria__c, SVMXC__Service_Contract__c, Id, SVMXC__Service__r.SVMXC__Tracked_On__c from SVMXC__Service_Contract_Services__c where SVMXC__Service_Contract__c IN: setContractIds and SVMXC__Service__c != null  and SVMXC__Service__r.SVMXC__Tracked_On__c != 'Work Order']);
                else if(strobjectName == 'WorkOrder')
                    mapCoveredServices.putAll([select SVMXC__Service__c, SVMXC__Service__r.Name, SVMXC__Is_Billable__c, SVMXC__Included_Units__c, SVMXC__Consumed_Units__c ,SVMXC__Service__r.SVMXC__Qualifying_Criteria__c, SVMXC__Service_Contract__c, Id, SVMXC__Service__r.SVMXC__Tracked_On__c from SVMXC__Service_Contract_Services__c where SVMXC__Service_Contract__c IN: setContractIds and SVMXC__Service__c != null  and SVMXC__Service__r.SVMXC__Tracked_On__c != 'Case']);
            
                
                Map<Integer, List<Id>> mapIntId = new Map<Integer, List<Id>>();
                list<SVMXC__Service_Contract_Services__c> lstTempCoveredServices = new list<SVMXC__Service_Contract_Services__c>();
                if(mapCoveredServices != null)
                {
                    for(SVMXC__Service_Contract_Services__c SCIS : mapCoveredServices.values())
                    {
                        if(SCIS.SVMXC__Included_Units__c != null)
                        {
                            if(SCIS.SVMXC__Consumed_Units__c == null)
                            {
                                SCIS.SVMXC__Consumed_Units__c = 0;
                            }else
                            {
                                if(strSelectSC != null && strSlectSCIS != null && strSelectSC == SCIS.SVMXC__Service_Contract__c && strSlectSCIS == SCIS.Id && (Integer.valueOf(SCIS.SVMXC__Consumed_Units__c) != 0))
                                    SCIS.SVMXC__Consumed_Units__c = Integer.valueOf(SCIS.SVMXC__Consumed_Units__c) - 1;
                            }
                            Integer avilableCount = Integer.valueOf(SCIS.SVMXC__Included_Units__c) - Integer.valueOf(SCIS.SVMXC__Consumed_Units__c);
                            if(!mapIntId.containsKey(avilableCount))
                            {
                                mapIntId.put(avilableCount, New List<Id>());
                            }
                            mapIntId.get(avilableCount).add(SCIS.Id);
                        }
                        else
                        { 
                            SCIS.SVMXC__Included_Units__c = 0;
                            lstCoveredServices.add(SCIS);
                        }
                    }
                    List<Integer> lstIds = new List<Integer>();
                    lstIds.addAll(mapIntId.keySet());
                    lstIds.sort();
                    for(Integer intKey : lstIds)
                    {
                        
                        for(Id IdKey : mapIntId.get(intKey))
                        {
                            lstTempCoveredServices.add(mapCoveredServices.get(IdKey));
                        }
                    }
                    for(Integer i = lstTempCoveredServices.size() - 1 ; i >= 0 ; i--)
                    {
                        lstCoveredServices.add(lstTempCoveredServices[i]);
                    }
                }
            }
            
      system.debug('Log for lstCoveredServices 1 : '+lstCoveredServices);
            if(lstCoveredServices != null && lstCoveredServices.size() > 0)
            {
                Set<Id> setIds = new Set<Id>();
                for(SVMXC__Service_Contract_Services__c currService : lstCoveredServices)
                {
                    if(currService.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c != null && (!setIds.contains(currService.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c)))
                        setIds.add(currService.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c);
                    
                }

                // Query all Expressions Rule which are associated with Includede Service.
                list<SVMXC__ServiceMax_Config_Data__c> lstExpressions = new list<SVMXC__ServiceMax_Config_Data__c>();
                if(setIds.size() > 0)
                {
                    mapSVMXRules.putAll([select Id, SVMXC__Advance_Expression__c, SVMXC__Sequence__c from SVMXC__ServiceMax_Processes__c where Id IN: setIds and SVMXC__Record_Type_Name__c = 'SVMX Rule']);
                    
                    // Query expressions Config data Records.
                    string StrgExpRTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name='Expressions' limit 1].Id;
                    
                    lstExpressions = [Select SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, SVMXC__Sequence__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__Object_Name2__c, SVMXC__IsDefault__c, SVMXC__Internal_Value__c, SVMXC__Field_Relationship_Name__c, SVMXC__Field_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, SVMXC__Display_Value__c, SVMXC__Display_Type__c, RecordTypeId, Name From SVMXC__ServiceMax_Config_Data__c  where SVMXC__Expression_Rule__c IN: setIds and RecordTypeId =: StrgExpRTypeId and SVMXC__Expression_Type__c = 'EXP_Named'];
                
                }
                
                
                if(lstExpressions != null && lstExpressions.size() > 0)
                {
                    for(SVMXC__ServiceMax_Config_Data__c oExpression: lstExpressions)
                    {
                        if(!mapRulesExpressions.containsKey(oExpression.SVMXC__Expression_Rule__c))
                            mapRulesExpressions.put(oExpression.SVMXC__Expression_Rule__c, new List<SVMXC__ServiceMax_Config_Data__c>());
                        mapRulesExpressions.get(oExpression.SVMXC__Expression_Rule__c).add(oExpression);
                    }
                }
                
                for(SVMXC__Service_Contract_Services__c Service : lstCoveredServices)
                {
                    try
                    {
                        if(Service.SVMXC__Service__c != null && Service.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c != null)
                        {
                            
                            if(mapRulesExpressions.containsKey(Service.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c) && mapRulesExpressions.get(Service.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c) != null && mapRulesExpressions.get(Service.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c).size() > 0)
                            {
                                
                                boolean IsRuleApplicable = false;
                                string strAdvancedExp = '';
                                if(mapSVMXRules != null && mapSVMXRules.get(Service.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c) != null)
                                    strAdvancedExp = (mapSVMXRules.get(Service.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c)).SVMXC__Advance_Expression__c;
                                System.debug('log level 1 : '+mapRulesExpressions.get(Service.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c));
                                IsRuleApplicable = new COMM_Utils.COMM_ExpressionParsing().SVMX_ExpressionParsing(sObj, mapRulesExpressions.get(Service.SVMXC__Service__r.SVMXC__Qualifying_Criteria__c), strAdvancedExp);
                                System.debug('log level 2 : '+IsRuleApplicable);
                                if(IsRuleApplicable)
                                {
                                    
                                    if(Service.SVMXC__Service__r.SVMXC__Tracked_On__c == null)
                                        mapValidUntracdServiceNSCON.get(Service.SVMXC__Service_Contract__c).add(Service);
                                    else
                                        mapValidServiceNSCON.get(Service.SVMXC__Service_Contract__c).add(Service);
                                }
                                else
                                {
                                    if(isShowAllServices)
                                    {
                                        if(Service.SVMXC__Service__r.SVMXC__Tracked_On__c == null)
                                            mapUnValidUntracdServiceNSCON.get(Service.SVMXC__Service_Contract__c).add(Service);
                                        else
                                            mapUnValidServiceNSCON.get(Service.SVMXC__Service_Contract__c).add(Service);
                                    }
                                }
                            }
                        }
                        else if(Service.SVMXC__Service__c != null)
                        {
                            if(Service.SVMXC__Service__r.SVMXC__Tracked_On__c == null)
                                mapValidUntracdServiceNSCON.get(Service.SVMXC__Service_Contract__c).add(Service);
                            else
                                mapValidServiceNSCON.get(Service.SVMXC__Service_Contract__c).add(Service);
                        }
                    }
                    catch(exception ex)
                    {
                        system.debug('Error: '+ex.getMessage());
                    }
                }
      }
      system.debug('Log level for lstSCResults : '+lstSCResults);
      for(EVER_SCResults SCResult : lstSCResults)
      {
        if(SCResult.SCId != null)
        {
          EVER_SCResults.IncludedServicesWrapper SCONResultWrpr1 = new EVER_SCResults.IncludedServicesWrapper();
          SCONResultWrpr1.strServiceName = getTAG004();
          SCONResultWrpr1.IncludedServices = new SVMXC__Service_Contract_Services__c();
          SCONResultWrpr1.strTracked = '';
          SCResult.lstISWrapper.add(SCONResultWrpr1);

          if(mapValidServiceNSCON.containsKey(SCResult.SCId) && mapValidServiceNSCON.get(SCResult.SCId) != null && mapValidServiceNSCON.get(SCResult.SCId).size() > 0)
          {
            for(SVMXC__Service_Contract_Services__c SCIS : mapValidServiceNSCON.get(SCResult.SCId))
            {
              EVER_SCResults.IncludedServicesWrapper SCONResultWrpr = new EVER_SCResults.IncludedServicesWrapper();
              SCONResultWrpr.IncludedServices = SCIS;
              SCONResultWrpr.isQualified = true;
              SCONResultWrpr.strServiceName = SCONResultWrpr.IncludedServices.SVMXC__Service__r.Name;
              if(SCIS.SVMXC__Service__r.SVMXC__Tracked_On__c == null)
                SCONResultWrpr.strTracked = getTAG002();
              else
                SCONResultWrpr.strTracked = getTAG001();
              SCResult.lstISWrapper.add(SCONResultWrpr);
            }
          }
          
          if(mapValidUntracdServiceNSCON.containsKey(SCResult.SCId) && mapValidUntracdServiceNSCON.get(SCResult.SCId) != null && mapValidUntracdServiceNSCON.get(SCResult.SCId).size() > 0)
          {
            for(SVMXC__Service_Contract_Services__c SCIS : mapValidUntracdServiceNSCON.get(SCResult.SCId))
            {
              EVER_SCResults.IncludedServicesWrapper SCONResultWrpr = new EVER_SCResults.IncludedServicesWrapper();
              SCONResultWrpr.IncludedServices = SCIS;
              SCONResultWrpr.isQualified = true;
              SCONResultWrpr.strServiceName = SCONResultWrpr.IncludedServices.SVMXC__Service__r.Name;
              if(SCIS.SVMXC__Service__r.SVMXC__Tracked_On__c == null)
                SCONResultWrpr.strTracked = getTAG002();
              else
                SCONResultWrpr.strTracked = getTAG001();
              SCResult.lstISWrapper.add(SCONResultWrpr);
            }
          }

          if(mapUnValidServiceNSCON.containsKey(SCResult.SCId) && mapUnValidServiceNSCON.get(SCResult.SCId) != null && mapUnValidServiceNSCON.get(SCResult.SCId).size() > 0)
          {
            for(SVMXC__Service_Contract_Services__c SCIS : mapUnValidServiceNSCON.get(SCResult.SCId))
            {
              EVER_SCResults.IncludedServicesWrapper SCONResultWrpr = new EVER_SCResults.IncludedServicesWrapper();
              SCONResultWrpr.IncludedServices = SCIS;
              SCONResultWrpr.isQualified = false;
              SCONResultWrpr.strServiceName = SCONResultWrpr.IncludedServices.SVMXC__Service__r.Name;
              if(SCIS.SVMXC__Service__r.SVMXC__Tracked_On__c == null)
              SCONResultWrpr.strTracked = getTAG002();
            else
              SCONResultWrpr.strTracked = getTAG001();
              SCResult.lstISWrapper.add(SCONResultWrpr);
            }
          }
          
          if(mapUnValidUntracdServiceNSCON.containsKey(SCResult.SCId) && mapUnValidUntracdServiceNSCON.get(SCResult.SCId) != null && mapUnValidUntracdServiceNSCON.get(SCResult.SCId).size() > 0)
          {
            for(SVMXC__Service_Contract_Services__c SCIS : mapUnValidUntracdServiceNSCON.get(SCResult.SCId))
            {
              EVER_SCResults.IncludedServicesWrapper SCONResultWrpr = new EVER_SCResults.IncludedServicesWrapper();
              SCONResultWrpr.IncludedServices = SCIS;
              SCONResultWrpr.isQualified = false;
              SCONResultWrpr.strServiceName = SCONResultWrpr.IncludedServices.SVMXC__Service__r.Name;
              if(SCIS.SVMXC__Service__r.SVMXC__Tracked_On__c == null)
              SCONResultWrpr.strTracked = getTAG002();
            else
              SCONResultWrpr.strTracked = getTAG001();
              SCResult.lstISWrapper.add(SCONResultWrpr);
            }
          }
          if(SCResult.lstISWrapper != null && SCResult.lstISWrapper.size() > 1)
          {
            SCResult.lstISWrapper[1].isSelected = true;
            SCResult.idSelectdIS = SCResult.lstISWrapper[1].IncludedServices.Id;
            SCResult.strNameIS = SCResult.lstISWrapper[1].IncludedServices.SVMXC__Service__r.Name;
            if(SCResult.lstISWrapper[1].IncludedServices.SVMXC__Included_Units__c == null || SCResult.lstISWrapper[1].IncludedServices.SVMXC__Included_Units__c == 0)
            {
              SCResult.strUnitsAvl = getTAG003();
            }
            else
            {
              if(Integer.valueOf(SCResult.lstISWrapper[1].IncludedServices.SVMXC__Included_Units__c) - Integer.valueOf(SCResult.lstISWrapper[1].IncludedServices.SVMXC__Consumed_Units__c) > 0)
                SCResult.strUnitsAvl = String.valueOf(Integer.valueOf(SCResult.lstISWrapper[1].IncludedServices.SVMXC__Included_Units__c) - Integer.valueOf(SCResult.lstISWrapper[1].IncludedServices.SVMXC__Consumed_Units__c));
              else
                SCResult.strUnitsAvl = '0';
            }
          }
          else if(SCResult.lstISWrapper != null && SCResult.lstISWrapper.size() > 0)
          {
            SCResult.lstISWrapper[0].isSelected = true;
            SCResult.idSelectdIS = null ;
            SCResult.strNameIS = '';
            SCResult.strUnitsAvl = '';
          }
        }
      }   
        }
        catch(exception ex)
        {
            system.debug('Error: '+ex.getMessage());
        }
    }
    public String getTAG001(){ return System.Label.COMM001_TAG119;}//'Yes' 
    public String getTAG002(){ return System.Label.COMM001_TAG120;}//'No'
    public String getTAG003(){ return System.Label.COMM001_TAG125;}//'Unlimited'
    public String getTAG004(){ return System.Label.COMM001_TAG035;}//'None'
}