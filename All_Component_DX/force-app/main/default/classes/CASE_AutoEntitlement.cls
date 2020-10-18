public with sharing class CASE_AutoEntitlement
{
    public static map<ID, Boolean> mapCaseIdCheckEntitlement = new map<ID, Boolean>();
    public static map<Integer, Boolean> mapCaseIndexCheckEntitlement = new map<Integer, Boolean>();
    public map<Integer, Case> mapCase = new map<Integer, Case>();
    public map<Id, Id> mapCounterDefIB = new map<Id, Id>();
    public map<Id, Integer> mapIBCaseIndex = new map<Id, Integer>();
    public map<Id, SVMXC__Installed_Product__c> mapComponent = new map<Id, SVMXC__Installed_Product__c>();
    public map<Id, SVMXC__Installed_Product__c> mapComponentParentANDTopLevel = new map<Id, SVMXC__Installed_Product__c>();
    public map<Id, SVMXC__ServiceMax_Processes__c> mapSVMXProcess = new map<Id, SVMXC__ServiceMax_Processes__c>();
    public map<Id, SVMXC__ServiceMax_Processes__c> mapEntRules = new map<Id, SVMXC__ServiceMax_Processes__c>();
    public map<Id, SVMXC__ServiceMax_Processes__c> mapCountersRules = new map<Id, SVMXC__ServiceMax_Processes__c>();
    public map<Id, list<SVMXC__Counter_Details__c>> mapCountersRulesDefinitions = new map<Id, list<SVMXC__Counter_Details__c>>();
    public map<Id, SVMXC__ServiceMax_Config_Data__c> mapExpression = new map<Id, SVMXC__ServiceMax_Config_Data__c>();
    public map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapEntRuleExpression = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    public map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapCountersRuleExpression = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
    public map<Id, list<Id>> mapIBCaseList = new map<Id, list<Id>>();  
    public map<Integer, string> mapCaseEntRule = new map<Integer, string>();
    public map<Id, string> mapProductCounterRule = new map<Id, string>();
    public set<Id> setComponent = new set<Id>();
    public map<Integer, Id> mapCaseContact = new map<Integer, Id>();
    public map<Integer, Id> mapCaseAccount = new map<Integer, Id>();
    public map<Id, Id> mapParentIB = new map<Id, Id>();
    public map<Id, Id> mapTopLevelIB = new map<Id, Id>();
    public set<Id> setParentProductId = new set<Id>();
    public set<Id> setTopLevelProductId = new set<Id>();
    public map<Id, Id> mapProductId = new map<Id, Id>();
    public set<Id> setCounterDefinitionId = new set<Id>();
    public map<Id, SVMXC__Warranty__c> mapProductWarranty = new map<Id, SVMXC__Warranty__c>();
    public map<Id, SVMXC__Service_Contract_Products__c> mapServiceContractCoverageIB = new map<Id, SVMXC__Service_Contract_Products__c>();
    public map<Id, List<SVMXC__Service_Contract_Products__c>> mapServiceContractCoverageProduct = new map<Id, List<SVMXC__Service_Contract_Products__c>>();
    public map<Id, map<Id, SVMXC__Counter_Details__c>> mapCounterCoverageIB = new map<Id, map<Id, SVMXC__Counter_Details__c>>();
    public map<Id, map<Id, SVMXC__Counter_Details__c>> mapCounterCoverageProduct = new map<Id, map<Id, SVMXC__Counter_Details__c>>();
    public map<Id, SVMXC__Counter_Details__c> mapCounterReadings = new map<Id, SVMXC__Counter_Details__c>();
    public map<Id, List<SVMXC__Counter_Details__c>> mapIBIDAndListCounterReadings = new map<Id, List<SVMXC__Counter_Details__c>>();
    public map<Id, SVMXC__Counter_Details__c> mapCounterDetails = new map<Id, SVMXC__Counter_Details__c>();
    public map<Id, SVMXC__Service_Contract_Contacts__c> mapEntitledContacts = new map<Id, SVMXC__Service_Contract_Contacts__c>();
    public map<Id, set<Id>> mapContactSC = new map<Id, set<Id>>();
    public map<Id, Product2> mapProduct = new map<Id, Product2>();
    public map<Id, SVMXC__Warranty__c> mapCaseProductWarranty = new map<Id, SVMXC__Warranty__c>();
    public map<Id, SVMXC__Service_Contract_Products__c> mapCaseServiceContractCoverage = new map<Id, SVMXC__Service_Contract_Products__c>();
    public map<Id, SVMXC__Counter_Details__c> mapCounterReading = new map<Id, SVMXC__Counter_Details__c>();
    public map<Id, list<SVMXC__Warranty__c>> mapIBProductWarranty = new map<Id, list<SVMXC__Warranty__c>>();
    public map<Id, list<SVMXC__Service_Contract_Products__c>> mapIBServiceContractCoverage = new map<Id, list<SVMXC__Service_Contract_Products__c>>();
    public map<Id, map<Id, SVMXC__Service_Contract__c>> mapIBServiceContractCoverageCounters = new map<Id, map<Id, SVMXC__Service_Contract__c>>();
    public map<Id, map<Id, SVMXC__Service_Template__c>> mapIBWarrantyTermsCounters = new map<Id, map<Id, SVMXC__Service_Template__c>>();    
    public SVMXC.COMM_SVMXC_Utils2.COMM_ExpressionParsing oExpressionParsing = new SVMXC.COMM_SVMXC_Utils2.COMM_ExpressionParsing();
    public Boolean IsCaseEntitled = false;
    public Boolean SetBillingType = true;
    public Boolean IsException = false;
    public String strExecptin;
    
    //Enhancement: Added new variables to support Match Location in Auto Entitlement
    public static map<Integer, SVMXC__Service_Contract_Products__c> mapCaseIndexContractIBCvrg = new map<Integer, SVMXC__Service_Contract_Products__c>();
    public map<Id, SVMXC__Service_Contract_Sites__c> mapEntitledLocation = new map<Id, SVMXC__Service_Contract_Sites__c>();
    public map<Id, list<SVMXC__Service_Contract__c>> mapLocationContractLst = new map<Id, list<SVMXC__Service_Contract__c>>();
    public map<Id, set<Id>> mapLocationSCON = new map<Id, set<Id>>();
    public map<Integer, Id> mapCaseLocation = new map<Integer, Id>();
    public set<string> setContractIds = new set<string>();
    public string Setng_EntitleUsingFld = null;
    
    //Variable for using Web Service
    public Map<String, String> mapCaseIdnSuccess = new Map<String, String>();
    public boolean isWebServiceCall = false;
    public Map <ID,List<SVMXC__Service_Contract_Sites__c> > mapServiceContractandCoveredLocations = new Map <ID, List<SVMXC__Service_Contract_Sites__c > > ();
    
    public CASE_AutoEntitlement()
    {
        //mapSettings.put('EVER004_SET001', 'TRUE');
    }

    //Case Entitlement using Web Service 
    public Set<String>  getFieldtoCaseQury()
    {
        List<SVMXC__ServiceMax_Processes__c> lstAutoEntitlementRules = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Config_Data__c> lstRuleExpressions = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        try
        {
            lstAutoEntitlementRules = [select Id from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' AND (SVMXC__Rule_Type__c = 'Auto Entitlement' )];
            lstRuleExpressions = [select SVMXC__Field_Name__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name='Expressions' AND SVMXC__Expression_Rule__c IN :lstAutoEntitlementRules AND (SVMXC__Expression_Type__c = 'CASE_Auto_Entitlement' )];
        }
        catch(Exception ex)
        {
            IsException = true;
            strExecptin = ex.getMessage();
        }
        Set<String> setField = new Set<String>();
        for(SVMXC__ServiceMax_Config_Data__c currExprFld :lstRuleExpressions)
        {
            if(currExprFld.SVMXC__Field_Name__c != null && currExprFld.SVMXC__Field_Name__c.length() > 0)
            {
                if(currExprFld.SVMXC__Field_Name__c != null && currExprFld.SVMXC__Field_Name__c.length() > 0 )
                    setField.add(currExprFld.SVMXC__Field_Name__c);
            }
        }
        return setField;
    }
    
    public INTF_WebServicesDef.INTF_Response SVMX_DoEntitlement(INTF_WebServicesDef.INTF_Request reqEntitlement)
    {
        mapCaseIdnSuccess.clear();
        isWebServiceCall = true;
        boolean isUpdateHistory = false;
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        INTF_WebServicesDef.INTF_Response objResponse = new INTF_WebServicesDef.INTF_Response();
        List<String> lstCaseIds = new List<String>();
        
        for(String currRecId: reqEntitlement.recordIds)
        {
            lstCaseIds.add(currRecId);
        }
        try
        {
            if(lstCaseIds != null && lstCaseIds.size() > 0)
            {
                list<string> lstSubModules = new list<string>{'EVER004','IPRD003'};
                map<string, Map<String, String>> AllsvmxSettingList = new map<string, Map<String, String>>();
                AllsvmxSettingList = commSettings.SVMX_getSettingList(lstSubModules);
                Map<String, String> mapSettings = new Map<String, String>();
                if(AllsvmxSettingList != null && AllsvmxSettingList.containsKey('EVER004') && AllsvmxSettingList.get('EVER004') != null )
                {
                    Map<String, String> mapSetting1 = AllsvmxSettingList.get('EVER004');
                    if(mapSetting1 != null && mapSetting1.size() > 0)
                    {
                        for(string strSettingId : mapSetting1.keySet())
                        {
                            string setValue = mapSetting1.containsKey(strSettingId) ? mapSetting1.get(strSettingId) : '';
                            strSettingId = 'EVER004'+'_'+strSettingId;
                            mapSettings.put(strSettingId,setValue);
                        }
                    }
                }
                if(AllsvmxSettingList != null && AllsvmxSettingList.containsKey('IPRD003') && AllsvmxSettingList.get('IPRD003') != null )
                {
                    Map<String, String> mapSetting2 = AllsvmxSettingList.get('IPRD003');
                    if(mapSetting2 != null && mapSetting2.size() > 0)
                    {
                        for(string strSettingId : mapSetting2.keySet())
                        {
                            string setValue = mapSetting2.containsKey(strSettingId) ? mapSetting2.get(strSettingId) : '';
                            strSettingId = 'IPRD003'+'_'+strSettingId;
                            mapSettings.put(strSettingId,setValue);
                        }
                    }
                }
                // Entitlement by Web Service should always be performed without respecting global setting EVER004_SET001(Is Perform Auto Entitlement.)
                if(mapSettings.containsKey('EVER004_SET001') && mapSettings.get('EVER004_SET001') != null && mapSettings.get('EVER004_SET001').toUpperCase() == 'FALSE')
                {
                    isUpdateHistory = true;
                    mapSettings.put('EVER004_SET001', 'TRUE');
                }
                List<Case> lstCases = new List<Case>();
                String strLoctnField = '';
                Set<String> setFields = new Set<String>();
                setFields = getFieldtoCaseQury();
                if(strLoctnField != null && strLoctnField.length() > 0)
                setFields.add(strLoctnField);
                
                if(mapSettings.containsKey('EVER004_SET003') && mapSettings.get('EVER004_SET003') != null && !mapSettings.get('EVER004_SET003').equalsIgnoreCase('Today') && !mapSettings.get('EVER004_SET003').equalsIgnoreCase('CreatedDate'))
                    setFields.add(mapSettings.get('EVER004_SET003'));
                
                setFields.add('Id');
                setFields.add('SVMXC__Entitlement_Notes__c');
                setFields.add('SVMXC__Auto_Entitlement_Status__c');
                setFields.add('SVMXC__Perform_Auto_Entitlement__c');
                setFields.add('SVMXC__SLA_Terms__c');
                setFields.add('SVMXC__Component__c');
                setFields.add('SVMXC__Warranty__c');
                setFields.add('SVMXC__Service_Contract__c');
                setFields.add('AccountId');
                setFields.add('ContactId');
                setFields.add('SVMXC__Billing_Type__c');
                setFields.add('SVMXC__Product__c');
                setFields.add('SVMXC__Is_Service_Covered__c');
                setFields.add('SVMXC__Site__c');
                setFields.add('SVMXC__Top_Level__c');
                setFields.add('CreatedDate');
                setFields.add('SVMXC__Is_Entitlement_Performed__c');
                
                list<SVMXC__Service__c> lstAvailServices = new list<SVMXC__Service__c>();
                list<SVMXC__ServiceMax_Config_Data__c> lstConfigExpr = new list<SVMXC__ServiceMax_Config_Data__c>();
                set<string> setProcessIds = new set<string>(); 
                List<String> queryFields = new List<String> {'SVMXC__Qualifying_Criteria__c' , 'Id', 'SVMXC__Tracked_On__c'};
                if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Service__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                lstAvailServices = [Select SVMXC__Qualifying_Criteria__c, Id from SVMXC__Service__c where SVMXC__Qualifying_Criteria__c != null AND SVMXC__Tracked_On__c = 'Case']; //SDL-SVMX-READ-FLS-ENFORCED
                for(SVMXC__Service__c currService : lstAvailServices)
                {
                    if(currService.SVMXC__Qualifying_Criteria__c != null)
                        setProcessIds.add(currService.SVMXC__Qualifying_Criteria__c);   
                }
                    
                if(setProcessIds != null && setProcessIds.size() > 0)
                    lstConfigExpr = [select SVMXC__Field_Name__c, Id from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Type__c = 'EXP_Named' AND RecordType.Name='Expressions' AND SVMXC__Expression_Rule__c IN: setProcessIds]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                for(SVMXC__ServiceMax_Config_Data__c currConfigData : lstConfigExpr)
                {
                    if(currConfigData.SVMXC__Field_Name__c != null && currConfigData.SVMXC__Field_Name__c != '')
                        setFields.add(currConfigData.SVMXC__Field_Name__c);
                }
                lstAvailServices.clear();
                lstConfigExpr.clear();
                setProcessIds.clear();
                
                String strCaseFields = '';
                for(String field : setFields)
                {
                    if(strCaseFields != null  && strCaseFields.length() == 0 )
                        strCaseFields = field;
                    else
                        strCaseFields = strCaseFields+', '+field;
                }
                try
                {
                    String strCaseQuery = 'select '+strCaseFields+' from Case where Id IN: lstCaseIds';
                    system.debug('Query : '+strCaseQuery);
                    lstCases = Database.query(strCaseQuery);
                }
                catch(Exception ex)
                {
                    IsException = true;
                    if(mapSettings.containsKey('EVER004_SET003') && mapSettings.get('EVER004_SET003') != null)
                        strExecptin = System.Label.COMM001_TAG081 + ' ' +mapSettings.get('EVER004_SET003');
                    else
                        strExecptin = ex.getMessage();
                }
                
                // Update Perform Auto Entitlement field set to true.
                for(Case objCase : lstCases)
                {
                    objCase.SVMXC__Perform_Auto_Entitlement__c = true;
                    objCase.SVMXC__Is_Entitlement_Performed__c = true; // Turn on this flag for Get Price. 
                }
                
                // Perform Entitlement by calling method SVMX_DoEntitlement.
                SVMX_DoEntitlement(lstCases, mapSettings);
                
                // Update Entitlement history by calling method SVMX_UpdateEntitlementHistory.
                if(isUpdateHistory)
                {
                    SVMX_UpdateEntitlementHistory(lstCases, lstCases, mapSettings);
                }
                
                if(IsException != true)
                {
                    if(mapCaseIdnSuccess != null && mapCaseIdnSuccess.size() > 0 )
                    {
                        for(String ids : mapCaseIdnSuccess.keySet())
                        {
                            if(ids != null && ids.length() > 0)
                            {
                                if(mapCaseIdnSuccess.get(ids) != null)
                                {
                                    SVMXC.INTF_WebServicesDef.SVMXMap objSVMXMap = new SVMXC.INTF_WebServicesDef.SVMXMap();
                                    objSVMXMap.key = ids;
                                    objSVMXMap.value = mapCaseIdnSuccess.get(ids);
                                    objResponse.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
                                    objResponse.valueMap.add(objSVMXMap);
                                }
                            }
                        }
                    }
                    for(Case objCase : lstCases)
                        objCase.SVMXC__Perform_Auto_Entitlement__c = false;
                    if(lstCases != null){
                        //upsert lstCases;
                        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstCases, COMM_SecurityUtils.Access.Upsertable)){
                            upsert lstCases; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        }
                        else{
                            objResponse.success = false;
                            objResponse.message = System.label.COMM001_TAG142;
                            return objResponse;
                        }
                    }
                    objResponse.success = true;
                }
                else
                {
                    objResponse.success = false;
                    objResponse.message = strExecptin;
                }
            }
        }
        catch(Exception ex)
        {
            objResponse.success = false;
            objResponse.message = ex.getMessage();
        }
        return objResponse;
    }
    
    public void SVMX_DoEntitlement(list<case> lstCase, Map<String, String> mapSettings)
    {
        String billingTypeValue; //Billing type value to be set when entitlement fails and auto calculate billing type is enabled
        //Entitlement enhancement: Setting to get the Date field of Case by which Entitlement validity can be checked.
        if(mapSettings.containsKey('EVER004_SET003') && mapSettings.get('EVER004_SET003') == null)
        {
            for(Case obCase : lstCase)
                obCase.addError(' '+ System.Label.COMM001_TAG081);
            return;
        }   
        else if(mapSettings.containsKey('EVER004_SET003') && mapSettings.get('EVER004_SET003') != null )
            Setng_EntitleUsingFld = mapSettings.get('EVER004_SET003');
        
        //Added on 2/3/2011 Due to Defect 001402(By Amar)
        if(mapSettings.containsKey('EVER004_SET002') && mapSettings.get('EVER004_SET002').toUpperCase() == 'FALSE')
        {
            SetBillingType = false;
        }
        
        if(mapSettings.containsKey('EVER004_SET005') && mapSettings.get('EVER004_SET005') != null)
            billingTypeValue = mapSettings.get('EVER004_SET005');        

        if(mapSettings.containsKey('EVER004_SET001') && mapSettings.get('EVER004_SET001').toUpperCase() == 'TRUE')
        {
            for(integer iIndex = 0; iIndex < lstCase.size(); iIndex++)
            {
                /* Defect(8660): Save this static map to prevent Entitlement History records multiple times on edit of Work Order record. */
                if(lstCase[iIndex].Id != NULL && String.valueOf(lstCase[iIndex].Id).length() > 0)
                    mapCaseIdCheckEntitlement.put(lstCase[iIndex].Id, lstCase[iIndex].SVMXC__Perform_Auto_Entitlement__c);
                else
                    mapCaseIndexCheckEntitlement.put(iIndex, lstCase[iIndex].SVMXC__Perform_Auto_Entitlement__c);
                
                Case oCase = lstCase[iIndex];
                if(oCase != null && oCase.SVMXC__Perform_Auto_Entitlement__c)
                {
                    mapCase.put(iIndex, oCase);
                    oCase.SVMXC__Is_Entitlement_Performed__c = true; // Turn on this flag for Get Price. 
                    if(oCase.SVMXC__Component__c != NULL )
                    {
                        mapIBCaseIndex.put(oCase.SVMXC__Component__c, iIndex);
                        setComponent.add(oCase.SVMXC__Component__c);
                        if(!mapIBCaseList.containsKey(oCase.SVMXC__Component__c))
                            mapIBCaseList.put(oCase.SVMXC__Component__c, new list<Id>());
                        mapIBCaseList.get(oCase.SVMXC__Component__c).add(oCase.Id);
                    }
                }
            }
            mapSVMXProcess.putAll([SELECT Name, SVMXC__Allow_Override__c, SVMXC__Match_Contact__c, SVMXC__Match_Location__c, SVMXC__Include_Product__c, SVMXC__Match_Account__c, SVMXC__Pick_First_Match__c, SVMXC__Counter_Vs_Dates_Rule__c, SVMXC__Include_Parent__c, SVMXC__Include_Top_Level__c, SVMXC__Entitlement_Scope__c, SVMXC__Entitlement_By__c, SVMXC__Sequence__c, SVMXC__Name__c, SVMXC__Advance_Expression__c, SVMXC__Rule_Type__c, SVMXC__Process__c, Id from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' AND (SVMXC__Rule_Type__c = 'Auto Entitlement' OR SVMXC__Rule_Type__c = 'Counters')]);
            for(SVMXC__ServiceMax_Processes__c oSVMXProcess :mapSVMXProcess.Values())
            {
                if(oSVMXProcess.SVMXC__Rule_Type__c == 'Auto Entitlement')
                {
                    mapEntRules.put(oSVMXProcess.Id, oSVMXProcess);
                    mapEntRuleExpression.put(oSVMXProcess.Id, new List<SVMXC__ServiceMax_Config_Data__c>());
                }
                else if(oSVMXProcess.SVMXC__Rule_Type__c == 'Counters')
                    mapCountersRules.put(oSVMXProcess.Id, oSVMXProcess);
            }
            
            mapExpression.putAll([SELECT Id, SVMXC__Source_Field_Name__c, SVMXC__Target_Field_Name__c, SVMXC__Display_Type__c, SVMXC__Sequence__c, SVMXC__RecordType_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Inventory_Process__c, SVMXC__Field_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name='Expressions' AND SVMXC__Expression_Rule__c IN :mapSVMXProcess.KeySet() AND (SVMXC__Expression_Type__c = 'CASE_Auto_Entitlement' OR SVMXC__Expression_Type__c = 'IPRD_Counters')]);
            for(SVMXC__ServiceMax_Config_Data__c oExp: mapExpression.values())
            {
                if(oExp.SVMXC__Expression_Type__c == 'CASE_Auto_Entitlement')
                {
                    if(!mapEntRuleExpression.containsKey(oExp.SVMXC__Expression_Rule__c))
                        mapEntRuleExpression.put(oExp.SVMXC__Expression_Rule__c, new List<SVMXC__ServiceMax_Config_Data__c>());
                    mapEntRuleExpression.get(oExp.SVMXC__Expression_Rule__c).add(oExp);
                }
                else if(oExp.SVMXC__Expression_Type__c == 'IPRD_Counters')
                {
                    if(!mapCountersRuleExpression.containsKey(oExp.SVMXC__Expression_Rule__c))
                        mapCountersRuleExpression.put(oExp.SVMXC__Expression_Rule__c, new List<SVMXC__ServiceMax_Config_Data__c>());
                    mapCountersRuleExpression.get(oExp.SVMXC__Expression_Rule__c).add(oExp);
                }
            }
            mapComponent.putAll([select Id, SVMXC__Parent__c, SVMXC__Top_Level__c, SVMXC__Product__c from SVMXC__Installed_Product__c where Id in :setComponent]);
            for(SVMXC__Installed_Product__c oIB :mapComponent.values())
            {
                mapProductId.put(oIB.Id, oIB.SVMXC__Product__c);
            }
            
            mapCaseEntRule = oExpressionParsing.SVMX_ExpressionParsing(mapCase, mapEntRuleExpression, mapEntRules);
            string strWhereClouseProductWarranty;
            string strWhereClouseServiceContract;
            string strCounterWhereClouseProductWarranty;
            string strCounterWhereClouseServiceContract;
            for(Integer iCaseIndex :mapCaseEntRule.KeySet())
            {
                case oCase = mapCase.get(iCaseIndex);
                oCase.SVMXC__Warranty__c = null;
                oCase.SVMXC__Service_Contract__c = null;
                oCase.SVMXC__SLA_Terms__c = null;
                oCase.SVMXC__Entitlement_Notes__c = '';
                
                //In case of new Case Rec, consider Today.(Because Created date or other date fields will be null)
                string strdate = null;
                try
                {
                    if(Setng_EntitleUsingFld.equalsIgnoreCase('Today') || Setng_EntitleUsingFld.equalsIgnoreCase('CreatedDate'))
                        strdate = string.valueOf(date.today());
                    else 
                        strdate = String.valueOf(date.valueOf(oCase.get(Setng_EntitleUsingFld)));
                    
                    if(strdate == null)
                    {
                        oCase.addError(' ' + System.Label.COMM001_TAG080 + ' ' +Setng_EntitleUsingFld);
                        return;
                    }
                }
                catch(exception ex)
                {
                    system.debug('Error: '+ex.getMessage());
                    oCase.addError(' '+ System.Label.COMM001_TAG081 + ' ' +Setng_EntitleUsingFld);
                    return;
                }
                
                if(oCase != null && oCase.SVMXC__Component__c != null)
                {
                    SVMXC__ServiceMax_Processes__c oEntRule = mapEntRules.get(mapCaseEntRule.get(iCaseIndex));
                    if(oEntRule != null )
                    {
                        if(oEntRule.SVMXC__Include_Parent__c && mapComponent.get(oCase.SVMXC__Component__c) != null)
                            mapParentIB.put(oCase.SVMXC__Component__c, mapComponent.get(oCase.SVMXC__Component__c).SVMXC__Parent__c);
                        if(oEntRule.SVMXC__Include_Top_Level__c && mapComponent.get(oCase.SVMXC__Component__c) != null)
                            mapTopLevelIB.put(oCase.SVMXC__Component__c, mapComponent.get(oCase.SVMXC__Component__c).SVMXC__Top_Level__c);
                        if(oEntRule.SVMXC__Entitlement_Scope__c == 'Warranties' || oEntRule.SVMXC__Entitlement_Scope__c == 'Both' )
                        {
                            /*Commented for the defect 020280 - Auto Entitlement through Warranty on Counters
                            if(oEntRule.SVMXC__Entitlement_By__c == 'Validity dates' || oEntRule.SVMXC__Entitlement_By__c == 'Both' || oEntRule.SVMXC__Entitlement_By__c == 'Counters')
                            {
                                if(strWhereClouseProductWarranty == null)
                                    strWhereClouseProductWarranty = '( ' + getIBStringFull(oCase, oEntRule) + ' AND SVMXC__Start_Date__c <= ' + strdate + ' AND SVMXC__End_Date__c >= ' + strdate + ' )';
                                else
                                    strWhereClouseProductWarranty += ' OR ( ' + getIBStringFull(oCase, oEntRule) + ' AND SVMXC__Start_Date__c <= ' + strdate + ' AND SVMXC__End_Date__c >= ' + strdate +' )';
                            }*/
                            
                            //This change is for fixing defect 021648
                            //if(oEntRule.SVMXC__Entitlement_By__c == 'Validity dates' || oEntRule.SVMXC__Entitlement_By__c == 'Both')
                            if(oEntRule.SVMXC__Entitlement_By__c == 'Validity dates')
                            {
                                if(strWhereClouseProductWarranty == null)
                                    strWhereClouseProductWarranty = '( ' + getIBStringFull(oCase, oEntRule) + ' AND SVMXC__Start_Date__c <= ' + strdate + ' AND SVMXC__End_Date__c >= ' + strdate + ' )';
                                else
                                    strWhereClouseProductWarranty += ' OR ( ' + getIBStringFull(oCase, oEntRule) + ' AND SVMXC__Start_Date__c <= ' + strdate + ' AND SVMXC__End_Date__c >= ' + strdate +' )';
                            }
                            //This change is for fixing defect 021648
                            //else if(oEntRule.SVMXC__Entitlement_By__c == 'Counters'){
                            else if(oEntRule.SVMXC__Entitlement_By__c == 'Counters' || oEntRule.SVMXC__Entitlement_By__c == 'Both'){
                                if(strWhereClouseProductWarranty == null)
                                    strWhereClouseProductWarranty = '( ' + getIBStringFull(oCase, oEntRule) + ' )';
                                else
                                    strWhereClouseProductWarranty += ' OR ( ' + getIBStringFull(oCase, oEntRule) + ' )';
                            }
                        }
                        if(oEntRule.SVMXC__Entitlement_Scope__c == 'Service Contracts' || oEntRule.SVMXC__Entitlement_Scope__c == 'Both' )
                        {
                            if(oEntRule.SVMXC__Include_Product__c)
                            {
                                if(oEntRule.SVMXC__Entitlement_By__c == 'Validity dates' || oEntRule.SVMXC__Entitlement_By__c == 'Both')
                                {
                                    /*if(strWhereClouseServiceContract == null)
                                        strWhereClouseServiceContract = ' (( SVMXC__Installed_Product__c = \'' +oCase.SVMXC__Component__c +'\' OR SVMXC__Product__c = \'' + mapProductId.get(oCase.SVMXC__Component__c) + '\' ) AND ((SVMXC__Start_Date__c != null AND SVMXC__End_Date__c != null AND SVMXC__Start_Date__c <= ' +strdate + ' AND SVMXC__End_Date__c >= ' + strdate + ') OR ((SVMXC__Start_Date__c = null OR SVMXC__End_Date__c = null ) AND SVMXC__Service_Contract__r.SVMXC__Start_Date__c <= ' +strdate + ' AND SVMXC__Service_Contract__r.SVMXC__End_Date__c >= ' + strdate + ')) ';
                                    else
                                        strWhereClouseServiceContract += ' OR  (( SVMXC__Installed_Product__c = \'' +oCase.SVMXC__Component__c +'\' OR SVMXC__Product__c = \'' + mapProductId.get(oCase.SVMXC__Component__c) + '\' ) AND ((SVMXC__Start_Date__c != null AND SVMXC__End_Date__c != null AND SVMXC__Start_Date__c <= ' +strdate + ' AND SVMXC__End_Date__c >= ' + strdate + ') OR ((SVMXC__Start_Date__c = null OR SVMXC__End_Date__c = null ) AND SVMXC__Service_Contract__r.SVMXC__Start_Date__c <= ' +strdate + ' AND SVMXC__Service_Contract__r.SVMXC__End_Date__c >= ' + strdate + ')) ';
                                    */
                                        
                                    string trmpstrWhereClouseServiceContract = '';
                                    trmpstrWhereClouseServiceContract = ' (( ' + getIBStringFull(oCase, oEntRule) +' OR SVMXC__Product__c = \'' + mapProductId.get(oCase.SVMXC__Component__c) + '\' ) AND ((SVMXC__Start_Date__c != null AND SVMXC__End_Date__c != null AND SVMXC__Start_Date__c <= ' + strdate + ' AND SVMXC__End_Date__c >= ' + strdate + ') OR ((SVMXC__Start_Date__c = null OR SVMXC__End_Date__c = null ) AND SVMXC__Service_Contract__r.SVMXC__Start_Date__c <= ' + strdate + ' AND SVMXC__Service_Contract__r.SVMXC__End_Date__c >= ' + strdate + ')) ';
                                    
                                    boolean isvalidQuery = true;
                                    if(oEntRule.SVMXC__Match_Account__c)
                                    {
                                        if(oCase.AccountId != null)
                                        {
                                            mapCaseAccount.put(iCaseIndex, oCase.AccountId);
                                            trmpstrWhereClouseServiceContract += ' AND SVMXC__Service_Contract__r.SVMXC__Company__c = \'' + oCase.AccountId + '\'';
                                        }
                                        else 
                                            isvalidQuery = false;
                                    }
                                    trmpstrWhereClouseServiceContract += ' ) ';
                                    if(oEntRule.SVMXC__Match_Contact__c && oCase.ContactId != null)
                                        mapCaseContact.put(iCaseIndex, oCase.ContactId);
                                    if(oEntRule.SVMXC__Match_Location__c && oCase.SVMXC__site__c != null)
                                        mapCaseLocation.put(iCaseIndex, oCase.SVMXC__site__c);
                                    
                                    if(isvalidQuery)
                                    {
                                        if(strWhereClouseServiceContract == null || strWhereClouseServiceContract.length() == 0)
                                            strWhereClouseServiceContract = trmpstrWhereClouseServiceContract;
                                        else
                                            strWhereClouseServiceContract += ' OR ' + trmpstrWhereClouseServiceContract;
                                    }
                                }
                                else if( oEntRule.SVMXC__Entitlement_By__c == 'Counters')
                                {
                                    if(oEntRule.SVMXC__Match_Account__c && oCase.AccountId != null)
                                        mapCaseAccount.put(iCaseIndex, oCase.AccountId);
                                    if(oEntRule.SVMXC__Match_Contact__c && oCase.ContactId != null)
                                        mapCaseContact.put(iCaseIndex, oCase.ContactId);
                                    if(oEntRule.SVMXC__Match_Location__c && oCase.SVMXC__site__c != null)
                                        mapCaseLocation.put(iCaseIndex, oCase.SVMXC__site__c);
                                }
                            }
                            else
                            {
                                if(oEntRule.SVMXC__Entitlement_By__c == 'Validity dates' || oEntRule.SVMXC__Entitlement_By__c == 'Both')
                                {
                                    string trmpstrWhereClouseServiceContract = '';
                                    trmpstrWhereClouseServiceContract = ' ( ' + getIBStringFull(oCase, oEntRule) + ' AND ((SVMXC__Start_Date__c != null AND SVMXC__End_Date__c != null AND SVMXC__Start_Date__c <= ' + strdate + ' AND SVMXC__End_Date__c >= ' + strdate + ') OR ((SVMXC__Start_Date__c = null OR SVMXC__End_Date__c = null ) AND SVMXC__Service_Contract__r.SVMXC__Start_Date__c <= ' + strdate + ' AND SVMXC__Service_Contract__r.SVMXC__End_Date__c >= ' + strdate + ')) ';
                                    
                                    boolean isvalidQuery = true;
                                    if(oEntRule.SVMXC__Match_Account__c)
                                    {
                                        if(oCase.AccountId != null)
                                        {
                                            mapCaseAccount.put(iCaseIndex, oCase.AccountId);
                                            trmpstrWhereClouseServiceContract += ' AND SVMXC__Service_Contract__r.SVMXC__Company__c = \'' + oCase.AccountId + '\'';
                                        }
                                        else 
                                            isvalidQuery = false;
                                    }
                                    trmpstrWhereClouseServiceContract += ' ) ';
                                    if(oEntRule.SVMXC__Match_Contact__c && oCase.ContactId != null)
                                        mapCaseContact.put(iCaseIndex, oCase.ContactId);
                                    
                                    if(oEntRule.SVMXC__Match_Location__c && oCase.SVMXC__site__c != null)
                                        mapCaseLocation.put(iCaseIndex, oCase.SVMXC__site__c);
                                    
                                    if(isvalidQuery)
                                    {
                                        if(strWhereClouseServiceContract == null || strWhereClouseServiceContract.length() == 0)
                                            strWhereClouseServiceContract = trmpstrWhereClouseServiceContract;
                                        else
                                            strWhereClouseServiceContract += ' OR ' + trmpstrWhereClouseServiceContract;
                                    }
                                }
                                else if( oEntRule.SVMXC__Entitlement_By__c == 'Counters')
                                {
                                    if(oEntRule.SVMXC__Match_Account__c && oCase.AccountId != null)
                                        mapCaseAccount.put(iCaseIndex, oCase.AccountId);
                                    if(oEntRule.SVMXC__Match_Contact__c && oCase.ContactId != null)
                                        mapCaseContact.put(iCaseIndex, oCase.ContactId);
                                    if(oEntRule.SVMXC__Match_Location__c && oCase.SVMXC__site__c != null)
                                        mapCaseLocation.put(iCaseIndex, oCase.SVMXC__site__c);
                                }
                            }
                        }
                    }
                }
                else if(oCase != null)
                {
                    SVMXC__ServiceMax_Processes__c oEntRule = mapEntRules.get(mapCaseEntRule.get(iCaseIndex));
                    if(oEntRule != null )
                    {
                        if(oEntRule.SVMXC__Match_Account__c && oCase.AccountId != null)
                            mapCaseAccount.put(iCaseIndex, oCase.AccountId);
                        if(oEntRule.SVMXC__Match_Contact__c && oCase.ContactId != null)
                            mapCaseContact.put(iCaseIndex, oCase.ContactId);
                        if(oEntRule.SVMXC__Match_Location__c && oCase.SVMXC__site__c != null)
                            mapCaseLocation.put(iCaseIndex, oCase.SVMXC__site__c);
                    }
                }
            }
            
            mapComponentParentANDTopLevel.putAll([select Id, SVMXC__Parent__c, SVMXC__Top_Level__c, SVMXC__Product__c from SVMXC__Installed_Product__c where Id in :mapParentIB.values() OR Id in :mapTopLevelIB.values()]);
            for(SVMXC__Installed_Product__c oIB :mapComponentParentANDTopLevel.values())
            {
                mapProductId.put(oIB.Id, oIB.SVMXC__Product__c);
            }
            
            //Updated by Vasu -Mar-01-2012: To handle Null in whr clause
            Set<Id> ibSet = new Set<Id>();
            ibSet.addAll(mapComponent.Keyset());
            ibSet.addAll(mapParentIB.values());
            ibSet.addAll(mapTopLevelIB.values());
            if(ibSet.contains(null))
                ibset.remove(null);
                
            set<ID> ProdIDs = new  set<ID>();
            ProdIDs.addAll(mapProductId.values());
            
            if(ProdIDs.contains(null))
                ProdIDs.remove(null);    
                
                system.debug('ProdIDs ' + ProdIDs);         
                system.debug('ibset ' + ibset);    

            //Added for PB-Xray 107---Using old reading with single entry and latest reading if there are multiple reading entries for each counter definition
            List<SVMXC__Counter_Details__c> lstCounterReading =  new List<SVMXC__Counter_Details__c>();
            List<String> queryFields = new List<String> {'Id', 'SVMXC__Service_Maintenance_Contract__r.Name', 'SVMXC__Service_Maintenance_Contract__r.SVMXC__Service_Level__c',  'SVMXC__Coverage_Limit__c', 'SVMXC__Coverage_Starts_At__c', 'SVMXC__Product__c', 'SVMXC__Warranty_Terms__r.Id', 'SVMXC__Warranty_Terms__c', 'RecordType.Name', 'SVMXC__Installed_Product__c', 'SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c', 'SVMXC__Service_Maintenance_Contract__r.Id', 'SVMXC__Counter_Definition__r.SVMXC__Max_Value__c', 'SVMXC__Counter_Definition__r.SVMXC__Min_Value__c', 'SVMXC__Counter_Reading__c', 'SVMXC__Counter_Definition__c', 'SVMXC__Service_Maintenance_Contract__r.SVMXC__Company__c', 'SVMXC__Service_Maintenance_Contract__r.SVMXC__Active__c', 'SVMXC__Is_Latest__c'};
            if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Counter_Details__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            if (ibSet != null && ibSet.size() > 0 && ProdIDs != null && ProdIDs.size() > 0){
                lstCounterReading = [select Id, SVMXC__Service_Maintenance_Contract__r.Name, SVMXC__Service_Maintenance_Contract__r.SVMXC__Service_Level__c,  SVMXC__Coverage_Limit__c, SVMXC__Coverage_Starts_At__c, SVMXC__Product__c, SVMXC__Warranty_Terms__r.Id, SVMXC__Warranty_Terms__c, RecordType.Name, SVMXC__Installed_Product__c, SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c, SVMXC__Service_Maintenance_Contract__r.Id, SVMXC__Counter_Definition__r.SVMXC__Max_Value__c, SVMXC__Counter_Definition__r.SVMXC__Min_Value__c, SVMXC__Counter_Reading__c, SVMXC__Counter_Definition__c, SVMXC__Service_Maintenance_Contract__r.SVMXC__Company__c, SVMXC__Service_Maintenance_Contract__r.SVMXC__Active__c, SVMXC__Is_Latest__c from SVMXC__Counter_Details__c where RecordType.Name = 'Reading' AND (SVMXC__Installed_Product__c IN :ibSet OR SVMXC__Product__c IN :ProdIDs)]; //SDL-SVMX-READ-FLS-ENFORCED
            }
            else if (ProdIDs != null && ProdIDs.size() > 0){
                lstCounterReading = [select Id, SVMXC__Service_Maintenance_Contract__r.Name, SVMXC__Service_Maintenance_Contract__r.SVMXC__Service_Level__c,  SVMXC__Coverage_Limit__c, SVMXC__Coverage_Starts_At__c, SVMXC__Product__c, SVMXC__Warranty_Terms__r.Id, SVMXC__Warranty_Terms__c, RecordType.Name, SVMXC__Installed_Product__c, SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c, SVMXC__Service_Maintenance_Contract__r.Id, SVMXC__Counter_Definition__r.SVMXC__Max_Value__c, SVMXC__Counter_Definition__r.SVMXC__Min_Value__c, SVMXC__Counter_Reading__c, SVMXC__Counter_Definition__c, SVMXC__Service_Maintenance_Contract__r.SVMXC__Company__c, SVMXC__Service_Maintenance_Contract__r.SVMXC__Active__c, SVMXC__Is_Latest__c from SVMXC__Counter_Details__c where RecordType.Name = 'Reading' AND SVMXC__Product__c IN :ProdIDs]; //SDL-SVMX-READ-FLS-ENFORCED
            }
            else if (ibSet != null && ibSet.size() > 0){
                lstCounterReading = [select Id, SVMXC__Service_Maintenance_Contract__r.Name, SVMXC__Service_Maintenance_Contract__r.SVMXC__Service_Level__c,  SVMXC__Coverage_Limit__c, SVMXC__Coverage_Starts_At__c, SVMXC__Product__c, SVMXC__Warranty_Terms__r.Id, SVMXC__Warranty_Terms__c, RecordType.Name, SVMXC__Installed_Product__c, SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c, SVMXC__Service_Maintenance_Contract__r.Id, SVMXC__Counter_Definition__r.SVMXC__Max_Value__c, SVMXC__Counter_Definition__r.SVMXC__Min_Value__c, SVMXC__Counter_Reading__c, SVMXC__Counter_Definition__c, SVMXC__Service_Maintenance_Contract__r.SVMXC__Company__c, SVMXC__Service_Maintenance_Contract__r.SVMXC__Active__c, SVMXC__Is_Latest__c from SVMXC__Counter_Details__c where RecordType.Name = 'Reading' AND SVMXC__Installed_Product__c IN :ibSet]; //SDL-SVMX-READ-FLS-ENFORCED
            }
            
            System.debug('NoOFReading : '+lstCounterReading.size());
            System.debug('ReadingRecord : '+lstCounterReading);
            
            Map<String, List<SVMXC__Counter_Details__c>> mapIBIdListReading = new Map<String, List<SVMXC__Counter_Details__c>>();
            for(SVMXC__Counter_Details__c objReading : lstCounterReading){
                if(!mapIBIdListReading.containsKey(objReading.SVMXC__Installed_Product__c))
                    mapIBIdListReading.put(objReading.SVMXC__Installed_Product__c, new List<SVMXC__Counter_Details__c>());
                mapIBIdListReading.get(objReading.SVMXC__Installed_Product__c).add(objReading);
            }
            System.debug('mapIBIdListReading size : '+mapIBIdListReading.size());
            System.debug('mapIBIdListReading : '+mapIBIdListReading);
            
            Map<String, List<SVMXC__Counter_Details__c>> mapDefinitionIdToReadingList;
            for(String objIBid : mapIBIdListReading.keySet()){
                mapDefinitionIdToReadingList = new Map<String, List<SVMXC__Counter_Details__c>>();
                for(SVMXC__Counter_Details__c objRead : mapIBIdListReading.get(objIBid)){
                    if(!mapDefinitionIdToReadingList.containsKey(objRead.SVMXC__Counter_Definition__c))
                        mapDefinitionIdToReadingList.put(objRead.SVMXC__Counter_Definition__c, new List<SVMXC__Counter_Details__c>());
                    mapDefinitionIdToReadingList.get(objRead.SVMXC__Counter_Definition__c).add(objRead);
                }
                System.debug('mapDefinitionIdToReadingList size : '+mapDefinitionIdToReadingList.size());
                System.debug('mapDefinitionIdToReadingList : '+mapDefinitionIdToReadingList);
                
                for(String DefId : mapDefinitionIdToReadingList.keySet()){
                    List<SVMXC__Counter_Details__c> lstReading = mapDefinitionIdToReadingList.get(DefId);
                    if(lstReading.size() == 1)
                        mapCounterDetails.put(lstReading[0].id, lstReading[0]);
                    else{
                        for(SVMXC__Counter_Details__c objRead : lstReading){
                            if(objRead.SVMXC__Is_Latest__c == true)
                                mapCounterDetails.put(objRead.id, objRead);
                        }
                    }
                }
            }
            System.debug('mapCounterDetails : '+mapCounterDetails);
            System.debug('mapCounterDetails Size: '+mapCounterDetails.size());
            
            if (ibSet != null && ibSet.size() > 0 && ProdIDs != null && ProdIDs.size() > 0)
            {
                mapCounterDetails.putAll([select Id, SVMXC__Service_Maintenance_Contract__r.Name, SVMXC__Service_Maintenance_Contract__r.SVMXC__Service_Level__c,  SVMXC__Coverage_Limit__c, SVMXC__Coverage_Starts_At__c, SVMXC__Product__c, SVMXC__Warranty_Terms__r.Id, SVMXC__Warranty_Terms__c, RecordType.Name, SVMXC__Installed_Product__c, SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c, SVMXC__Service_Maintenance_Contract__r.Id, SVMXC__Counter_Definition__r.SVMXC__Max_Value__c, SVMXC__Counter_Definition__r.SVMXC__Min_Value__c, SVMXC__Counter_Reading__c, SVMXC__Counter_Definition__c, SVMXC__Service_Maintenance_Contract__r.SVMXC__Company__c, SVMXC__Service_Maintenance_Contract__r.SVMXC__Active__c from SVMXC__Counter_Details__c where (RecordType.Name = 'Coverage' AND (SVMXC__Warranty_Terms__c != NULL OR (SVMXC__Service_Maintenance_Contract__c != NULL AND SVMXC__Service_Maintenance_Contract__r.SVMXC__Active__c = TRUE))) AND (SVMXC__Installed_Product__c IN :ibSet OR SVMXC__Product__c IN :ProdIDs)]);
            
            }
            else if (ProdIDs != null && ProdIDs.size() > 0)
            {
                mapCounterDetails.putAll([select Id, SVMXC__Service_Maintenance_Contract__r.Name, SVMXC__Service_Maintenance_Contract__r.SVMXC__Service_Level__c,  SVMXC__Coverage_Limit__c, SVMXC__Coverage_Starts_At__c, SVMXC__Product__c, SVMXC__Warranty_Terms__r.Id, SVMXC__Warranty_Terms__c, RecordType.Name, SVMXC__Installed_Product__c, SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c, SVMXC__Service_Maintenance_Contract__r.Id, SVMXC__Counter_Definition__r.SVMXC__Max_Value__c, SVMXC__Counter_Definition__r.SVMXC__Min_Value__c, SVMXC__Counter_Reading__c, SVMXC__Counter_Definition__c, SVMXC__Service_Maintenance_Contract__r.SVMXC__Company__c, SVMXC__Service_Maintenance_Contract__r.SVMXC__Active__c from SVMXC__Counter_Details__c where (RecordType.Name = 'Coverage' AND (SVMXC__Warranty_Terms__c != NULL OR (SVMXC__Service_Maintenance_Contract__c != NULL AND SVMXC__Service_Maintenance_Contract__r.SVMXC__Active__c = TRUE))) AND (SVMXC__Product__c IN :ProdIDs)]);
            
            }
            else if (ibSet != null && ibSet.size() > 0)
            {
                mapCounterDetails.putAll([select Id, SVMXC__Service_Maintenance_Contract__r.Name, SVMXC__Service_Maintenance_Contract__r.SVMXC__Service_Level__c,  SVMXC__Coverage_Limit__c, SVMXC__Coverage_Starts_At__c, SVMXC__Product__c, SVMXC__Warranty_Terms__r.Id, SVMXC__Warranty_Terms__c, RecordType.Name, SVMXC__Installed_Product__c, SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c, SVMXC__Service_Maintenance_Contract__r.Id, SVMXC__Counter_Definition__r.SVMXC__Max_Value__c, SVMXC__Counter_Definition__r.SVMXC__Min_Value__c, SVMXC__Counter_Reading__c, SVMXC__Counter_Definition__c, SVMXC__Service_Maintenance_Contract__r.SVMXC__Company__c, SVMXC__Service_Maintenance_Contract__r.SVMXC__Active__c from SVMXC__Counter_Details__c where (RecordType.Name = 'Coverage' AND (SVMXC__Warranty_Terms__c != NULL OR (SVMXC__Service_Maintenance_Contract__c != NULL AND SVMXC__Service_Maintenance_Contract__r.SVMXC__Active__c = TRUE))) AND (SVMXC__Installed_Product__c IN :ibSet)]);
            }
            
            System.debug('mapCounterDetails Size: '+mapCounterDetails.size());
            System.debug('mapCounterDetails : '+mapCounterDetails);
            
            for(SVMXC__Counter_Details__c oCD :mapCounterDetails.values())
            {
                if(oCD.RecordType.Name == 'Reading')
                {
                    if(oCD.SVMXC__Installed_Product__c != null)
                    {
                        //mapCounterReadings.put(oCD.SVMXC__Installed_Product__c, oCD); Commented for the Multiple counter reading defect 020165
                        if(!mapIBIDAndListCounterReadings.containsKey(oCD.SVMXC__Installed_Product__c))
                            mapIBIDAndListCounterReadings.put(oCD.SVMXC__Installed_Product__c, new List<SVMXC__Counter_Details__c>());
                        mapIBIDAndListCounterReadings.get(oCD.SVMXC__Installed_Product__c).add(oCD);
                        
                        setCounterDefinitionId.add(oCD.SVMXC__Counter_Definition__c);
                        mapCounterDefIB.put(oCD.SVMXC__Counter_Definition__c, oCD.SVMXC__Installed_Product__c);
                    }
                }
                if(oCD.RecordType.Name == 'Coverage')
                {
                    if(oCD.SVMXC__Installed_Product__c != null && oCD.SVMXC__Service_Maintenance_Contract__c != null && oCD.SVMXC__Service_Maintenance_Contract__r.SVMXC__Active__c == true)
                    {
                        if(!mapCounterCoverageIB.containsKey(oCD.SVMXC__Installed_Product__c))
                            mapCounterCoverageIB.put(oCD.SVMXC__Installed_Product__c, new map<Id, SVMXC__Counter_Details__c>());
                        mapCounterCoverageIB.get(oCD.SVMXC__Installed_Product__c).put(oCD.Id, oCD);
                    }
                    if(oCD.SVMXC__Product__c != null && oCD.SVMXC__Warranty_Terms__c != null)
                    {
                        if(!mapCounterCoverageProduct.containsKey(oCD.SVMXC__Product__c))
                            mapCounterCoverageProduct.put(oCD.SVMXC__Product__c, new map<Id, SVMXC__Counter_Details__c>());
                        mapCounterCoverageProduct.get(oCD.SVMXC__Product__c).put(oCD.Id, oCD);
                    }
                }
            }
            
            System.debug('mapIBIDAndListCounterReadings Size: '+mapIBIDAndListCounterReadings.size());
            System.debug('mapIBIDAndListCounterReadings: '+mapIBIDAndListCounterReadings);
            
            mapEntitledContacts.putAll([select Id, SVMXC__Contact__c, SVMXC__Service_Contract__c from SVMXC__Service_Contract_Contacts__c where SVMXC__Contact__c IN :mapCaseContact.values()]);
            
            for(SVMXC__Service_Contract_Contacts__c oSCC :mapEntitledContacts.values())
            {
                if(!mapContactSC.containsKey(oSCC.SVMXC__Contact__c))
                    mapContactSC.put(oSCC.SVMXC__Contact__c, new set<Id>());
                mapContactSC.get(oSCC.SVMXC__Contact__c).add(oSCC.SVMXC__Service_Contract__c);
            }
            
            if(mapCaseLocation != null && mapCaseLocation.size() > 0)
                mapEntitledLocation.putAll([select Id, SVMXC__SLA_Terms__c,SVMXC__End_Date__c, SVMXC__Start_Date__c, SVMXC__site__c, SVMXC__Service_Contract__c 
                                            from SVMXC__Service_Contract_Sites__c 
                                            WHERE SVMXC__Service_Contract__r.SVMXC__Active__c = true 
                                            AND SVMXC__site__c IN: mapCaseLocation.values()]);
                                            
            set<string> setSCONIds = new set<string>(); 
            
            for(SVMXC__Service_Contract_Sites__c currLocation :mapEntitledLocation.values())
            {
                if(!mapLocationSCON.containsKey(currLocation.SVMXC__site__c))
                    mapLocationSCON.put(currLocation.SVMXC__site__c, new set<Id>());
                mapLocationSCON.get(currLocation.SVMXC__site__c).add(currLocation.SVMXC__Service_Contract__c);
                setSCONIds.add(currLocation.SVMXC__Service_Contract__c);
                
                
                if(currLocation.SVMXC__Service_Contract__c != null){
                    if(!mapServiceContractandCoveredLocations.containsKey(currLocation.SVMXC__Service_Contract__c ))
                        mapServiceContractandCoveredLocations.put(currLocation.SVMXC__Service_Contract__c,  new List<SVMXC__Service_Contract_Sites__c>());  
                    mapServiceContractandCoveredLocations.get(currLocation.SVMXC__Service_Contract__c).add(currLocation);
                }
            }   
            
            map<Id,SVMXC__Service_Contract__c> mapContract =  new map<Id,SVMXC__Service_Contract__c>();
            mapContract.putAll([select Id, Name, SVMXC__Start_Date__c, SVMXC__Company__c, SVMXC__End_Date__c, SVMXC__Service_Level__c from SVMXC__Service_Contract__c where Id IN: setSCONIds]);
            for(SVMXC__Service_Contract_Sites__c currLocation :mapEntitledLocation.values())
            {
                if(!mapLocationContractLst.containsKey(currLocation.SVMXC__site__c))
                    mapLocationContractLst.put(currLocation.SVMXC__site__c, new list<SVMXC__Service_Contract__c>());
                if(mapContract.containsKey(currLocation.SVMXC__Service_Contract__c) && mapContract.get(currLocation.SVMXC__Service_Contract__c) != null)
                    mapLocationContractLst.get(currLocation.SVMXC__site__c).add(mapContract.get(currLocation.SVMXC__Service_Contract__c));
            }
            mapContract.clear();
            mapEntitledLocation.clear();

            for(Id IdIB :mapComponent.KeySet())
            {
                SVMXC__ServiceMax_Processes__c oEntRule = mapEntRules.get(mapCaseEntRule.get(mapIBCaseIndex.get(IdIB))); 
                if(oEntRule != null && (oEntRule.SVMXC__Entitlement_By__c == 'Counters' || oEntRule.SVMXC__Entitlement_By__c == 'Both' ))
                {
                    updateCounterMaps(IdIB);
                    if(oEntRule.SVMXC__Include_Parent__c)
                        updateCounterMaps(mapParentIB.get(IdIB));
                    if(oEntRule.SVMXC__Include_Top_Level__c)
                        updateCounterMaps(mapTopLevelIB.get(IdIB));
                }
            }
            system.debug('where clause: '+strWhereClouseProductWarranty+ ', '+strWhereClouseServiceContract);
            if(strWhereClouseProductWarranty != null)
            {
                mapProductWarranty.putALL((list<SVMXC__Warranty__c>)database.Query('select Id, Name, SVMXC__Start_Date__c, SVMXC__End_Date__c, SVMXC__Installed_Product__c from SVMXC__Warranty__c where ' + strWhereClouseProductWarranty));
                for(SVMXC__Warranty__c oPW :mapProductWarranty.Values())
                {
                    if(!mapIBProductWarranty.ContainsKey(oPW.SVMXC__Installed_Product__c))
                        mapIBProductWarranty.put(oPW.SVMXC__Installed_Product__c, new list<SVMXC__Warranty__c>());
                    mapIBProductWarranty.get(oPW.SVMXC__Installed_Product__c).add(oPW);
                }
            }
            if(strWhereClouseServiceContract != null)
            {
                mapServiceContractCoverageIB.putAll((list<SVMXC__Service_Contract_Products__c>)database.Query('select Id, SVMXC__Service_Contract__r.SVMXC__Start_Date__c , SVMXC__Service_Contract__r.SVMXC__End_Date__c, SVMXC__Service_Contract__r.Name, SVMXC__Service_Contract__r.SVMXC__Service_Level__c, SVMXC__Service_Contract__r.SVMXC__Company__c, SVMXC__Installed_Product__c, SVMXC__Service_Contract__c, SVMXC__Start_Date__c, SVMXC__End_Date__c, SVMXC__SLA_Terms__c from SVMXC__Service_Contract_Products__c where SVMXC__Service_Contract__r.SVMXC__Active__c = true AND (' + strWhereClouseServiceContract + ')'));
                for(SVMXC__Service_Contract_Products__c oSC :mapServiceContractCoverageIB.Values())
                {
                    if(!mapIBServiceContractCoverage.ContainsKey(oSC.SVMXC__Installed_Product__c))
                        mapIBServiceContractCoverage.put(oSC.SVMXC__Installed_Product__c, new list<SVMXC__Service_Contract_Products__c>());
                    mapIBServiceContractCoverage.get(oSC.SVMXC__Installed_Product__c).add(oSC);
                }
            }
            
            for(Integer iCaseIndex = 0; iCaseIndex < lstCase.size(); iCaseIndex++)
            {
                Case oCase = lstCase.get(iCaseIndex);
                IsCaseEntitled = false;
                if(mapCaseEntRule.containsKey(iCaseIndex))
                {
                    SVMXC__ServiceMax_Processes__c oEntRule = mapEntRules.get(mapCaseEntRule.get(iCaseIndex));
                    if(oEntRule.SVMXC__Entitlement_Scope__c == 'Warranties')
                    {
                        if(oEntRule.SVMXC__Entitlement_By__c == 'Both')
                        {
                            if(oEntRule.SVMXC__Counter_Vs_Dates_Rule__c == 'Whichever Is Valid')
                            {
                                oCase = getWarrantyOnValidityDate(oCase, oEntRule);
                                if(oCase.SVMXC__Warranty__c == null)
                                    oCase = getWarrantyOnCounters(oCase, oEntRule);
                            }
                            else
                                oCase = getWarrantyOnBoth(oCase, oEntRule);
                        }
                        else if(oEntRule.SVMXC__Entitlement_By__c == 'Counters')
                            oCase = getWarrantyOnCounters(oCase, oEntRule);
                        else if(oEntRule.SVMXC__Entitlement_By__c == 'Validity dates')
                            oCase = getWarrantyOnValidityDate(oCase, oEntRule);
                    }
                    else if(oEntRule.SVMXC__Entitlement_Scope__c == 'Service Contracts')
                    {
                        if(oEntRule.SVMXC__Entitlement_By__c == 'Both')
                        {
                            if(oEntRule.SVMXC__Counter_Vs_Dates_Rule__c == 'Whichever Is Valid')
                            {
                                boolean IsServiceContractFound = false;
                                oCase = getServiceContractOnValidityDate(oCase, oEntRule, iCaseIndex);
                                
                                if(oCase.SVMXC__Service_Contract__c == null && oEntRule.SVMXC__Include_Parent__c)
                                    oCase = getServiceContractOnValidityDate(oCase, oEntRule, iCaseIndex);
                                if(oCase.SVMXC__Service_Contract__c == null)
                                    oCase = getServiceContractOnCounters(oCase, oEntRule, iCaseIndex);
                            }
                            else if(oEntRule.SVMXC__Counter_Vs_Dates_Rule__c == 'Both Are Valid')
                                oCase = getServiceContractOnBoth(oCase, oEntRule, iCaseIndex);
                        }
                        else if(oEntRule.SVMXC__Entitlement_By__c == 'Counters')
                            oCase = getServiceContractOnCounters(oCase, oEntRule, iCaseIndex);
                        else if(oEntRule.SVMXC__Entitlement_By__c == 'Validity dates')
                            oCase = getServiceContractOnValidityDate(oCase, oEntRule, iCaseIndex);
                    } 
                    else if(oEntRule.SVMXC__Entitlement_Scope__c == 'Both')
                    {
                        if(oEntRule.SVMXC__Entitlement_By__c == 'Both')
                        {
                            if(oEntRule.SVMXC__Counter_Vs_Dates_Rule__c == 'Whichever Is Valid')
                            {
                                if(oEntRule.SVMXC__Pick_First_Match__c == 'Service Contract')
                                {
                                    oCase = getServiceContractOnValidityDate(oCase, oEntRule, iCaseIndex);
                                    if(oCase.SVMXC__Service_Contract__c == null)
                                        oCase = getServiceContractOnCounters(oCase, oEntRule, iCaseIndex);
                                    if(oCase.SVMXC__Service_Contract__c == null)
                                        oCase = getWarrantyOnBoth(oCase, oEntRule);
                                }
                                else if(oEntRule.SVMXC__Pick_First_Match__c == 'Warranty')
                                {
                                    oCase = getWarrantyOnValidityDate(oCase, oEntRule);
                                    if(oCase.SVMXC__Warranty__c == null)
                                        oCase = getServiceContractOnValidityDate(oCase, oEntRule, iCaseIndex);
                                    if(oCase.SVMXC__Service_Contract__c == null)
                                        oCase = getServiceContractOnCounters(oCase, oEntRule, iCaseIndex);
                                }
                            }
                            else if(oEntRule.SVMXC__Counter_Vs_Dates_Rule__c == 'Both Are Valid')
                            {
                                if(oEntRule.SVMXC__Pick_First_Match__c == 'Service Contract')
                                {
                                    oCase = getServiceContractOnBoth(oCase, oEntRule, iCaseIndex);
                                    if(oCase.SVMXC__Service_Contract__c == null)
                                        oCase = getWarrantyOnValidityDate(oCase, oEntRule);
                                }
                                else if(oEntRule.SVMXC__Pick_First_Match__c == 'Warranty')
                                {
                                    oCase = getWarrantyOnValidityDate(oCase, oEntRule);
                                    if(oCase.SVMXC__Warranty__c == null)
                                        oCase = getServiceContractOnBoth(oCase, oEntRule, iCaseIndex);
                                }
                            }
                        }
                        else if(oEntRule.SVMXC__Entitlement_By__c == 'Counters')
                        {
                            if(oEntRule.SVMXC__Pick_First_Match__c == 'Service Contract')
                            {
                                oCase = getServiceContractOnCounters(oCase, oEntRule, iCaseIndex);
                                if(oCase.SVMXC__Service_Contract__c == null)
                                    oCase = getWarrantyOnCounters(oCase, oEntRule);
                            }
                            else if(oEntRule.SVMXC__Pick_First_Match__c == 'Warranty')
                            {
                                oCase = getWarrantyOnCounters(oCase, oEntRule);
                                if(oCase.SVMXC__Warranty__c == null)
                                    oCase = getServiceContractOnCounters(oCase, oEntRule, iCaseIndex);
                            }
                        }
                        else if(oEntRule.SVMXC__Entitlement_By__c == 'Validity dates')
                        {
                            if(oEntRule.SVMXC__Pick_First_Match__c == 'Service Contract')
                            {
                                if(oCase.SVMXC__Warranty__c == null)
                                    oCase = getServiceContractOnValidityDate(oCase, oEntRule, iCaseIndex);
                                if(oCase.SVMXC__Service_Contract__c == null)
                                {
                                    oCase = getWarrantyOnValidityDate(oCase, oEntRule);
                                }
                            }
                            else if(oEntRule.SVMXC__Pick_First_Match__c == 'Warranty')
                            {
                                oCase = getWarrantyOnValidityDate(oCase, oEntRule);
                                if(oCase.SVMXC__Warranty__c == null)
                                    oCase = getServiceContractOnValidityDate(oCase, oEntRule, iCaseIndex);
                            }
                        }
                    }
                    if(IsCaseEntitled)
                    {
                        if(isWebServiceCall)
                            mapCaseIdnSuccess.put(oCase.Id,'Success');
                        oCase.SVMXC__Entitlement_Type__c = 'AUTO';
                        oCase.SVMXC__Auto_Entitlement_Status__c = 'Success';
                        oCase.SVMXC__Perform_Auto_Entitlement__c = false;
                        if(oCase.SVMXC__Service_Contract__c != null)
                        {
                            setContractIds.add(oCase.SVMXC__Service_Contract__c);
                        }
                    }
                }
                if(!IsCaseEntitled && oCase.SVMXC__Perform_Auto_Entitlement__c)
                {
                    if(isWebServiceCall)
                            mapCaseIdnSuccess.put(oCase.Id,'Failed');
                    oCase.SVMXC__Warranty__c = null;
                    oCase.SVMXC__Service_Contract__c = null;
                    oCase.SVMXC__SLA_Terms__c = null;
                    oCase.SVMXC__Entitlement_Notes__c = '';
                    oCase.SVMXC__Auto_Entitlement_Status__c = 'Failed';
                    if(SetBillingType && billingTypeValue != null)
                        oCase.SVMXC__Billing_Type__c = billingTypeValue;                      
                    oCase.SVMXC__Perform_Auto_Entitlement__c = false;
                    oCase.SVMXC__Is_Service_Covered__c = false;
                }
            }
            
            //Enhancement: Update Threshold Count.
            if(mapSettings.containsKey('EVER004_SET004') && mapSettings.get('EVER004_SET004').toUpperCase() == 'TRUE')
            {
                map<integer, map<string,string>> mapCase_Status  = new map<integer, map<string,string>>(); 
                map<integer,string> mapIndexdCaseService  = new map<integer,string>();
                map<string,SVMXC__Service_Contract_Services__c> mapEntitledService = new map<string,SVMXC__Service_Contract_Services__c>();  
                
                // Identify the Covered service available in Service Contract for Case rec(s) by calling IdentifyServiceForCase method.
                mapIndexdCaseService  = new EVER_Entitlement_Utils().identifyServicesForIndexedRecs(mapCase, null);
                
                // If Service is available for list of Case, pass map of case and applicable exp rule to manage threshold.
                if(mapIndexdCaseService != null && mapIndexdCaseService.size() > 0)
                {
                    mapCase_Status = new EVER_Entitlement_Utils().manageServiceThresholdCount(lstCase, null, mapIndexdCaseService);
                    mapEntitledService.putAll([Select Id, Name, SVMXC__Service_Contract__c from SVMXC__Service_Contract_Services__c where Id IN: mapIndexdCaseService.values() AND SVMXC__Service_Contract__c IN: setContractIds]);
                }
                for(integer index : mapCase.keySet())
                {
                    if((mapCase.get(index)).SVMXC__Service_Contract__c != null)
                    {
                        if(mapCase_Status.containsKey(index) && mapCase_Status.get(index) != null)
                        {
                            set<string> setIncludedServiceId = mapCase_Status.get(index).keySet();
                            list<string> lstStatus =  mapCase_Status.get(index).values();
                            if(setIncludedServiceId != null && setIncludedServiceId.size() == 1 && lstStatus != null && lstStatus.size() == 1)
                            {
                                if(mapEntitledService != null && mapEntitledService.get((mapIndexdCaseService.get(index))) != null)
                                    mapCase.get(index).SVMXC__Entitlement_Notes__c += '\nService Consumed: ' +  mapEntitledService.get(string.valueOf((mapIndexdCaseService.get(index)))).Name;
                                if(lstStatus[0] == 'NOT_APPLICABLE')
                                    mapCase.get(index).SVMXC__Is_Service_Covered__c = false;
                                else
                                    mapCase.get(index).SVMXC__Is_Service_Covered__c = true;      
                            }
                            else
                                mapCase.get(index).SVMXC__Is_Service_Covered__c = false;
                        }
                        else
                            mapCase.get(index).SVMXC__Is_Service_Covered__c = false;
                    }
                    else
                        mapCase.get(index).SVMXC__Is_Service_Covered__c = false;
                }
            }
        }
    }
    
    public void SVMX_UpdateEntitlementHistory(list<case> lstNewCase, list<case> lstOldCase, Map<String, String> mapSettings)
    {
        system.debug('CaseId - Perform Entitlememt Map: ' + mapCaseIdCheckEntitlement + '; ' + mapCaseIndexCheckEntitlement);
        list<SVMXC__Entitlement_History__c> lstNewEntitlementHistory = new list<SVMXC__Entitlement_History__c>();
        set<Id> setCaseId = new set<Id>();
        map<Id, Id> mapCaseIdWarrantyId = new map<Id, Id>();
        map<Id, Id> mapCaseIdServiceContractID = new map<Id, Id>();
        set<Id> setWarrantyId = new set<Id>();
        set<Id> setServiceContractId = new set<Id>();
        map<Id, SVMXC__Warranty__c> mapProductWarrantyHist = new map<Id, SVMXC__Warranty__c>();
        map<Id, SVMXC__Service_Contract__c> mapServiceContractHist = new map<Id, SVMXC__Service_Contract__c>();
        if(mapSettings.containsKey('EVER004_SET001') && mapSettings.get('EVER004_SET001').toUpperCase() == 'TRUE')
        {
            for(integer iIndex = 0; iIndex < lstNewCase.size(); iIndex++)
            {
                Case oOldCase;
                if(lstOldCase != null)
                    oOldCase = lstOldCase[iIndex];
                Case oNewCase = lstNewCase[iIndex];
                
                /** Only enter below code section when Perform Entitlement is set to true for Case Record **/
                if((mapCaseIdCheckEntitlement != NULL && mapCaseIdCheckEntitlement.containsKey(oNewCase.Id) && mapCaseIdCheckEntitlement.get(oNewCase.Id) == false) || (mapCaseIndexCheckEntitlement != NULL && mapCaseIndexCheckEntitlement.containsKey(iIndex) && mapCaseIndexCheckEntitlement.get(iIndex) == false))
                    continue;
                
                if(oOldCase == null && oNewCase.SVMXC__Entitlement_Type__c == 'AUTO' && !oNewCase.SVMXC__Perform_Auto_Entitlement__c)
                {
                    if(oNewCase.SVMXC__Warranty__c != null  || oNewCase.SVMXC__Service_Contract__c != null)
                    {
                        setCaseId.add(oNewCase.Id);
                        if(oNewCase.SVMXC__Service_Contract__c != null)
                        {
                            setServiceContractId.add(oNewCase.SVMXC__Service_Contract__c);
                            mapCaseIdServiceContractID.put(oNewCase.Id, oNewCase.SVMXC__Service_Contract__c);
                        }
                        if(oNewCase.SVMXC__Warranty__c != null)
                        {
                            setWarrantyId.add(oNewCase.SVMXC__Warranty__c);
                            mapCaseIdWarrantyId.put(oNewCase.Id, oNewCase.SVMXC__Warranty__c);
                        }
                    }
                }
                else if(oNewCase.SVMXC__Entitlement_Type__c == 'AUTO' && oNewCase != null && oNewCase.Id != null && !oNewCase.SVMXC__Perform_Auto_Entitlement__c && ((oNewCase.SVMXC__Warranty__c != null && oNewCase.SVMXC__Warranty__c != oOldCase.SVMXC__Warranty__c)  || (oNewCase.SVMXC__Service_Contract__c != null)))
                {
                    setCaseId.add(oNewCase.Id);
                    if(oNewCase.SVMXC__Service_Contract__c != null)
                    {
                        setServiceContractId.add(oNewCase.SVMXC__Service_Contract__c);
                        mapCaseIdServiceContractID.put(oNewCase.Id, oNewCase.SVMXC__Service_Contract__c);
                    }
                    if(oNewCase.SVMXC__Warranty__c != null && oNewCase.SVMXC__Warranty__c != oOldCase.SVMXC__Warranty__c)
                    {
                        setWarrantyId.add(oNewCase.SVMXC__Warranty__c);
                        mapCaseIdWarrantyId.put(oNewCase.Id, oNewCase.SVMXC__Warranty__c);
                    }
                }
            }
            
            if(setCaseId.size() > 0)
            {
                if(setCaseId.contains(null))
                    setCaseId.remove(null);
                
                map<Id, list<SVMXC__Entitlement_History__c>> mapEntitlementHistory = new map<Id, list<SVMXC__Entitlement_History__c>>();
                mapProductWarrantyHist.putALL([select Id, Name, SVMXC__Start_Date__c, SVMXC__End_Date__c from SVMXC__Warranty__c where ID IN :setWarrantyId]);
                mapServiceContractHist.putAll([select Id, Name, SVMXC__Start_Date__c, SVMXC__End_Date__c, SVMXC__Service_Level__c from SVMXC__Service_Contract__c where Id IN :setServiceContractId]);
                
                /* Defect(8660): Removed SVMXC__Inactive_Date__c = NULL from query to avoid SOQL Exception on high volume data, Since  Entitlement History records (Entitlement History records queried below + new History reecord) will voilate the Governor Limit (more than 10000 DML Operations) */
                list<SVMXC__Entitlement_History__c> lstEntitlementHistory = new list<SVMXC__Entitlement_History__c>(); 
                List<String> queryFields = new List<String> {'Id', 'SVMXC__Inactive_Date__c', 'SVMXC__Case__c', 'SVMXC__Entitled_By_Service__c'};
                if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Entitlement_History__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                lstEntitlementHistory = [select Id, SVMXC__Inactive_Date__c, SVMXC__Case__c, SVMXC__Entitled_By_Service__c from SVMXC__Entitlement_History__c where SVMXC__Case__c in :setCaseId ORDER BY SVMXC__Inactive_Date__c ASC NULLS FIRST Limit 5000]; //SDL-SVMX-READ-FLS-ENFORCED
                
                map<string,string> mapCaseService  = new map<string,string>();
                map<string, map<string,string>> mapCase_Status  = new map<string, map<string,string>>(); 
                if(mapSettings.containsKey('EVER004_SET004') && mapSettings.get('EVER004_SET004').toUpperCase() == 'TRUE')
                {
                    //Identify the applicable service and update threshold count.
                    mapCaseService  = new EVER_Entitlement_Utils().identifyServiceForCase(lstNewCase);
                    mapCase_Status = new EVER_Entitlement_Utils().manageServiceThresholdCount(lstNewCase, mapCaseService, true);
                }
                
                for(SVMXC__Entitlement_History__c oEntHistory : lstEntitlementHistory)
                {
                    if(oEntHistory.SVMXC__Inactive_Date__c == NULL)
                        oEntHistory.SVMXC__Inactive_Date__c = date.Today();
                    else
                        break;
                }
                
                list<case> lstCaseTobeUpdate = new list<case>(); 
                for(integer iIndex = 0; iIndex < lstNewCase.size(); iIndex++)
                {
                    Case oOldCase;
                    if(lstOldCase != null)
                        oOldCase = lstOldCase[iIndex];
                    Case oNewCase = lstNewCase[iIndex];
                    
                    /** Only enter below code section when Perform Entitlement is set to true for Case Record **/
                    if((mapCaseIdCheckEntitlement != NULL && mapCaseIdCheckEntitlement.containsKey(oNewCase.Id) && mapCaseIdCheckEntitlement.get(oNewCase.Id) == false) || (mapCaseIndexCheckEntitlement != NULL && mapCaseIndexCheckEntitlement.containsKey(iIndex) && mapCaseIndexCheckEntitlement.get(iIndex) == false))
                        continue;
                    
                    if(oOldCase == null)
                    {
                        if(oNewCase.SVMXC__Warranty__c != null  || oNewCase.SVMXC__Service_Contract__c != null)
                        {
                            if(oNewCase.SVMXC__Warranty__c != null )
                            {
                                SVMXC__Entitlement_History__c oEntitlementHistory = new SVMXC__Entitlement_History__c();
                                oEntitlementHistory.SVMXC__Case__c = oNewCase.Id;
                                oEntitlementHistory.SVMXC__Date_of_Entitlement__c = date.Today();
                                Id WarrantyId = mapCaseIdWarrantyId.get(oNewCase.Id);
                                oEntitlementHistory.SVMXC__Warranty__c = WarrantyId;
                                SVMXC__Warranty__c oPW = mapProductWarrantyHist.get(WarrantyId);
                                oEntitlementHistory.SVMXC__Start_Date__c = oPW.SVMXC__Start_Date__c; 
                                oEntitlementHistory.SVMXC__End_Date__c = oPW.SVMXC__End_Date__c;
                                oEntitlementHistory.SVMXC__Entitlement_Notes__c = oNewCase.SVMXC__Entitlement_Notes__c;/*'Entitled by ServiceMax auto-entitlement process.'+
                                                                                    '\nWarranty:' + oPW.Name + 
                                                                                    '\nStart Date:' + oPW.SVMXC__Start_Date__c +
                                                                                    '\nEnd Date:' + oPW.SVMXC__End_Date__c ;*/
                                lstNewEntitlementHistory.add(oEntitlementHistory);
                            }
                            if(oNewCase.SVMXC__Service_Contract__c != null)
                            {
                                SVMXC__Entitlement_History__c oEntitlementHistory = new SVMXC__Entitlement_History__c();
                                oEntitlementHistory.SVMXC__Case__c = oNewCase.Id;
                                if(mapSettings.containsKey('EVER004_SET004') && mapSettings.get('EVER004_SET004').toUpperCase() == 'TRUE')
                                {
                                    if(mapCase_Status.containsKey(oNewCase.Id) && mapCase_Status.get(oNewCase.Id) != null)
                                    {
                                        set<string> setIncludedServiceId = mapCase_Status.get(oNewCase.Id).keySet();
                                        list<string> lstStatus =  mapCase_Status.get(oNewCase.Id).values();
                                        if(setIncludedServiceId != null && setIncludedServiceId.size() == 1 && lstStatus != null && lstStatus.size() == 1)
                                        {
                                            if(lstStatus[0] == 'NOT_APPLICABLE')
                                                oEntitlementHistory.SVMXC__Entitled_Within_Threshold__c = false;
                                            else
                                            {
                                                for(string currId : setIncludedServiceId)
                                                    oEntitlementHistory.SVMXC__Entitled_By_Service__c = currId;
                                                if(lstStatus[0] == 'WITHIN_THRESHOLD')
                                                    oEntitlementHistory.SVMXC__Entitled_Within_Threshold__c = true;
                                                else if(lstStatus[0] == 'OUTSIDE_THRESHOLD' || lstStatus[0] == 'NOT_APPLICABLE')
                                                    oEntitlementHistory.SVMXC__Entitled_Within_Threshold__c = false;
                                            }
                                        }
                                    }
                                }
                                
                                oEntitlementHistory.SVMXC__Date_of_Entitlement__c = date.Today();
                                Id ServiceContractId = mapCaseIdServiceContractID.get(oNewCase.Id);
                                oEntitlementHistory.SVMXC__Service_Contract__c = ServiceContractId;
                                SVMXC__Service_Contract__c oSC = mapServiceContractHist.get(ServiceContractId);
                                
                                //If Case is entitled by Coverd Product, then populate the start and end date from Service Contract's Covered Product
                                if(mapCaseIndexContractIBCvrg != NULL && mapCaseIndexContractIBCvrg.containsKey(iIndex) && mapCaseIndexContractIBCvrg.get(iIndex) != NULL)
                                {
                                    SVMXC__Service_Contract_Products__c objCoveredProduct = new SVMXC__Service_Contract_Products__c();
                                    objCoveredProduct = mapCaseIndexContractIBCvrg.get(iIndex);
                                    oEntitlementHistory.SVMXC__Start_Date__c = getStartDate(objCoveredProduct);
                                    oEntitlementHistory.SVMXC__End_Date__c = getEndDate(objCoveredProduct);
                                    /*if(objCoveredProduct.SVMXC__SLA_Terms__c != NULL)
                                        oEntitlementHistory.SVMXC__SLA_Terms__c = objCoveredProduct.SVMXC__SLA_Terms__c;
                                    else
                                        oEntitlementHistory.SVMXC__SLA_Terms__c = oSC.SVMXC__Service_Level__c;
                                    */
                                    oEntitlementHistory.SVMXC__SLA_Terms__c = oNewCase.SVMXC__SLA_Terms__c;
                                }
                                else
                                {
                                    oEntitlementHistory.SVMXC__Start_Date__c = oSC.SVMXC__Start_Date__c; 
                                    oEntitlementHistory.SVMXC__End_Date__c = oSC.SVMXC__End_Date__c;
                                    oEntitlementHistory.SVMXC__SLA_Terms__c = oSC.SVMXC__Service_Level__c;
                                }
                                
                                oEntitlementHistory.SVMXC__Entitlement_Notes__c = oNewCase.SVMXC__Entitlement_Notes__c;/*'Entitled by ServiceMax auto-entitlement process.'+
                                                                                    '\nService Contract:' + oSC.Name + 
                                                                                    '\nStart Date:' + oSC.SVMXC__Start_Date__c +
                                                                                    '\nEnd Date:' + oSC.SVMXC__End_Date__c ;*/
                                lstNewEntitlementHistory.add(oEntitlementHistory);
                            }
                        }
                    }
                    else if(oNewCase.SVMXC__Entitlement_Type__c == 'AUTO' && oNewCase != null && oNewCase.Id != null && !oNewCase.SVMXC__Perform_Auto_Entitlement__c && ((oNewCase.SVMXC__Warranty__c != null && oNewCase.SVMXC__Warranty__c != oOldCase.SVMXC__Warranty__c)  || (oNewCase.SVMXC__Service_Contract__c != null)))
                    {
                        if(oNewCase.SVMXC__Warranty__c != null  || oNewCase.SVMXC__Service_Contract__c != null)
                        {
                            if(oNewCase.SVMXC__Warranty__c != null && oNewCase.SVMXC__Warranty__c != oOldCase.SVMXC__Warranty__c)
                            {
                                SVMXC__Entitlement_History__c oEntitlementHistory = new SVMXC__Entitlement_History__c();
                                oEntitlementHistory.SVMXC__Case__c = oNewCase.Id;
                                oEntitlementHistory.SVMXC__Date_of_Entitlement__c = date.Today();
                                Id WarrantyId = mapCaseIdWarrantyId.get(oNewCase.Id);
                                oEntitlementHistory.SVMXC__Warranty__c = WarrantyId;
                                SVMXC__Warranty__c oPW = mapProductWarrantyHist.get(WarrantyId);
                                oEntitlementHistory.SVMXC__Start_Date__c = oPW.SVMXC__Start_Date__c; 
                                oEntitlementHistory.SVMXC__End_Date__c = oPW.SVMXC__End_Date__c;
                                oEntitlementHistory.SVMXC__Entitlement_Notes__c = oNewCase.SVMXC__Entitlement_Notes__c;/*'Entitled by ServiceMax auto-entitlement process.'+
                                                                                    '\nWarranty:' + oPW.Name + 
                                                                                    '\nStart Date:' + oPW.SVMXC__Start_Date__c +
                                                                                    '\nEnd Date:' + oPW.SVMXC__End_Date__c ;*/
                                lstNewEntitlementHistory.add(oEntitlementHistory);
                            }
                            if(oNewCase.SVMXC__Service_Contract__c != null)
                            {
                                SVMXC__Entitlement_History__c oEntitlementHistory = new SVMXC__Entitlement_History__c();
                                if(mapSettings.containsKey('EVER004_SET004') && mapSettings.get('EVER004_SET004').toUpperCase() == 'TRUE')
                                {
                                    if(mapCase_Status.containsKey(oNewCase.Id) && mapCase_Status.get(oNewCase.Id) != null)
                                    {
                                        set<string> setIncludedServiceId = mapCase_Status.get(oNewCase.Id).keySet();
                                        list<string> lstStatus =  mapCase_Status.get(oNewCase.Id).values();
                                        if(setIncludedServiceId != null && setIncludedServiceId.size() == 1 && lstStatus != null && lstStatus.size() == 1)
                                        {
                                            if(lstStatus[0] == 'NOT_APPLICABLE')
                                                oEntitlementHistory.SVMXC__Entitled_Within_Threshold__c = false;
                                            else
                                            {
                                                for(string currId : setIncludedServiceId)
                                                    oEntitlementHistory.SVMXC__Entitled_By_Service__c = currId;
                                                if(lstStatus[0] == 'WITHIN_THRESHOLD')
                                                    oEntitlementHistory.SVMXC__Entitled_Within_Threshold__c = true;
                                                else if(lstStatus[0] == 'OUTSIDE_THRESHOLD' || lstStatus[0] == 'NOT_APPLICABLE')
                                                    oEntitlementHistory.SVMXC__Entitled_Within_Threshold__c = false;
                                            }
                                        }
                                    }
                                }
                                
                                oEntitlementHistory.SVMXC__Case__c = oNewCase.Id;
                                oEntitlementHistory.SVMXC__Date_of_Entitlement__c = date.Today();
                                Id ServiceContractId = mapCaseIdServiceContractID.get(oNewCase.Id);
                                oEntitlementHistory.SVMXC__Service_Contract__c = ServiceContractId;
                                SVMXC__Service_Contract__c oSC = mapServiceContractHist.get(ServiceContractId);
                                
                                //If Case is entitled by Coverd Product, then populate the start and end date from Service Contract's Covered Product
                                if(mapCaseIndexContractIBCvrg != NULL && mapCaseIndexContractIBCvrg.containsKey(iIndex) && mapCaseIndexContractIBCvrg.get(iIndex) != NULL)
                                {
                                    SVMXC__Service_Contract_Products__c objCoveredProduct = new SVMXC__Service_Contract_Products__c();
                                    objCoveredProduct = mapCaseIndexContractIBCvrg.get(iIndex);
                                    oEntitlementHistory.SVMXC__Start_Date__c = getStartDate(objCoveredProduct);
                                    oEntitlementHistory.SVMXC__End_Date__c = getEndDate(objCoveredProduct);
                                    /*if(objCoveredProduct.SVMXC__SLA_Terms__c != NULL)
                                        oEntitlementHistory.SVMXC__SLA_Terms__c = objCoveredProduct.SVMXC__SLA_Terms__c;
                                    else
                                        oEntitlementHistory.SVMXC__SLA_Terms__c = oSC.SVMXC__Service_Level__c;
                                    */
                                     oEntitlementHistory.SVMXC__SLA_Terms__c = oNewCase.SVMXC__SLA_Terms__c;
                                }
                                else
                                {
                                    oEntitlementHistory.SVMXC__Start_Date__c = oSC.SVMXC__Start_Date__c; 
                                    oEntitlementHistory.SVMXC__End_Date__c = oSC.SVMXC__End_Date__c;
                                    oEntitlementHistory.SVMXC__SLA_Terms__c = oSC.SVMXC__Service_Level__c;
                                }
                                oEntitlementHistory.SVMXC__Entitlement_Notes__c = oNewCase.SVMXC__Entitlement_Notes__c;/*'Entitled by ServiceMax auto-entitlement process.'+
                                                                                    '\nService Contract:' + oSC.Name + 
                                                                                    '\nStart Date:' + oSC.SVMXC__Start_Date__c +
                                                                                    '\nEnd Date:' + oSC.SVMXC__End_Date__c ;*/
                            
                                lstNewEntitlementHistory.add(oEntitlementHistory);
                            }
                        }
                    }
                }
                if(lstNewEntitlementHistory != null)
                {
                    if(lstEntitlementHistory != null)
                        lstNewEntitlementHistory.addAll(lstEntitlementHistory);
                    //upsert lstNewEntitlementHistory;
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstNewEntitlementHistory, COMM_SecurityUtils.Access.Upsertable)){
                        upsert lstNewEntitlementHistory; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    }
                    else{
                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                }
                else
                {
                    if(lstEntitlementHistory != null){
                        //upsert lstEntitlementHistory;
                        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstEntitlementHistory, COMM_SecurityUtils.Access.Upsertable)){
                            upsert lstEntitlementHistory; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        }
                        else{
                            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                        }
                    }
                }
            }
        }
    }
    public date getStartDate(SVMXC__Service_Contract_Products__c oSCP)
    {
        if(oSCP.SVMXC__Start_Date__c != null || oSCP.SVMXC__End_Date__c != null)
            return oSCP.SVMXC__Start_Date__c;
        else
            return oSCP.SVMXC__Service_Contract__r.SVMXC__Start_Date__c;
    }
    
    public date getEndDate(SVMXC__Service_Contract_Products__c oSCP)
    {
        if(oSCP.SVMXC__Start_Date__c != null || oSCP.SVMXC__End_Date__c != null)
            return oSCP.SVMXC__End_Date__c;
        else
            return oSCP.SVMXC__Service_Contract__r.SVMXC__End_Date__c;
    }
    
    public String dateToString(date objDate)
    {
        String strDate = '';
        try
        {
            if(objDate != NULL)
            {
                String strMM = objDate.month().format() ;
                String strDD = objDate.day().format();
                if(integer.valueOf(strMM) < 10) strMM = '0' + strMM;
                if(integer.valueOf(strDD) < 10) strDD = '0' + strDD;
                strDate = String.valueOf(objDate.year()) + '-' + strMM + '-' + strDD;
            }
        }
        catch(exception ex)
        {
            system.debug(LoggingLevel.WARN, 'Message - ' + ex.getMessage());
        }
        return strDate;
    }
    
    public string getIBStringFull(Case oCase, SVMXC__ServiceMax_Processes__c oEntRule)
    {
        string strIBWhereClouse = '';
        strIBWhereClouse = ' ( SVMXC__Installed_Product__c = \'' +oCase.SVMXC__Component__c + '\' ';
        if(oEntRule.SVMXC__Include_Parent__c && mapParentIB.get(oCase.SVMXC__Component__c) != null)
            strIBWhereClouse += ' OR SVMXC__Installed_Product__c = \'' + mapParentIB.get(oCase.SVMXC__Component__c) + '\' ';
        if(oEntRule.SVMXC__Include_Top_Level__c && mapTopLevelIB.get(oCase.SVMXC__Component__c) != null)
            strIBWhereClouse += ' OR SVMXC__Installed_Product__c = \'' + mapTopLevelIB.get(oCase.SVMXC__Component__c) + '\' ';
        strIBWhereClouse += ' )';
        return strIBWhereClouse;
    
    }
    public Case getWarrantyOnValidityDate(Case oCase, SVMXC__ServiceMax_Processes__c oEntRule)
    {
        oCase = getWarrantyOnValidityDate(oCase, oEntRule, oCase.SVMXC__Component__c);
        if(oCase.SVMXC__Warranty__c == null && oEntRule.SVMXC__Include_Parent__c)
            oCase = getWarrantyOnValidityDate(oCase, oEntRule, mapParentIB.get(oCase.SVMXC__Component__c));
        if(oCase.SVMXC__Warranty__c == null && oEntRule.SVMXC__Include_Top_Level__c)
            oCase = getWarrantyOnValidityDate(oCase, oEntRule, mapTopLevelIB.get(oCase.SVMXC__Component__c));
        return oCase;
    }
    public Case getWarrantyOnValidityDate(Case oCase, SVMXC__ServiceMax_Processes__c oEntRule, Id ComponantID)
    {
        try
        {
            if(ComponantID != null && mapIBProductWarranty.get(ComponantID) != null && mapIBProductWarranty.get(ComponantID).size() > 0)
            {
                date dtEntitleusing = date.today();
                try
                {
                    if(Setng_EntitleUsingFld != null && (!Setng_EntitleUsingFld.equalsIgnoreCase('Today') && !Setng_EntitleUsingFld.equalsIgnoreCase('CreatedDate')) && oCase.get(Setng_EntitleUsingFld) != null )
                        dtEntitleusing = date.valueOf(String.valueOf(oCase.get(Setng_EntitleUsingFld)));
                }
                catch(exception ex)
                {
                    dtEntitleusing = date.today();
                }
                    
                for(SVMXC__Warranty__c oPW :mapIBProductWarranty.get(ComponantID))
                {
                    if(oPW.SVMXC__Start_Date__c <= dtEntitleusing && oPW.SVMXC__End_Date__c >= dtEntitleusing )
                    {
                        oCase.SVMXC__Warranty__c = oPW.Id;
                        oCase.SVMXC__Entitlement_Notes__c = 'Entitled by ServiceMax auto-entitlement process.'+
                                                            '\nAuto-Entitlement Rule: ' + oEntRule.SVMXC__Name__c +
                                                            '\nWarranty: ' + oPW.Name + 
                                                            '\nStart Date: ' + dateToString(oPW.SVMXC__Start_Date__c) +
                                                            '\nEnd Date: ' + dateToString(oPW.SVMXC__End_Date__c);
                        //Added on 2/3/2011 Due to Defect 001402 (By Amar)
                        if(SetBillingType == true)
                            oCase.SVMXC__Billing_Type__c = 'Warranty';
                        IsCaseEntitled = true;
                        //IsWarrantyFound = true;
                        break;
                    }
                }
            }
        }
        catch(exception ex)
        {
            IsException = true;
            strExecptin = ex.getMessage();
        }
        return oCase;
    }
    
    //Added for the defect 020280 - Auto Entitlement through Warranty on Counters
    public Case getWarrantyOnCounters(Case oCase, SVMXC__ServiceMax_Processes__c oEntRule)
    {
        oCase = getWarrantyOnCounters(oCase, oEntRule, oCase.SVMXC__Component__c);
        if(oCase.SVMXC__Warranty__c == null && oEntRule.SVMXC__Include_Parent__c)
            oCase = getWarrantyOnCounters(oCase, oEntRule, mapParentIB.get(oCase.SVMXC__Component__c));
        if(oCase.SVMXC__Warranty__c == null && oEntRule.SVMXC__Include_Top_Level__c)
            oCase = getWarrantyOnCounters(oCase, oEntRule, mapTopLevelIB.get(oCase.SVMXC__Component__c));
        return oCase;
    }
    public Case getWarrantyOnCounters(Case oCase, SVMXC__ServiceMax_Processes__c oEntRule, Id ComponantID)
    {
        try
        {
            if(mapIBProductWarranty.get(ComponantID) != null && mapIBProductWarranty.get(ComponantID).size() > 0)
            {
                ID ProdId = mapProductId.get(ComponantID);
                for(SVMXC__Warranty__c oPW :mapIBProductWarranty.get(ComponantID))
                {
                    if(mapIBWarrantyTermsCounters.get(ProdId) != null && mapIBWarrantyTermsCounters.get(ProdId).size() > 0)
                    {
                        oCase.SVMXC__Warranty__c = oPW.Id;
                        oCase.SVMXC__Entitlement_Notes__c = 'Entitled by ServiceMax auto-entitlement process.'+
                                                            '\nAuto-Entitlement Rule: ' + oEntRule.SVMXC__Name__c +
                                                            '\nWarranty: ' + oPW.Name;
                        IsCaseEntitled = true;
                        if(SetBillingType == true)
                            oCase.SVMXC__Billing_Type__c = 'Warranty';
                        break;
                    }
                }
            }
        }
        catch(exception ex)
        { 
            IsException = true;
            strExecptin = ex.getMessage();
        }
        return oCase;
    }
    public Case getWarrantyOnBoth(Case oCase, SVMXC__ServiceMax_Processes__c oEntRule)
    {
        oCase = getWarrantyOnBoth(oCase, oEntRule, oCase.SVMXC__Component__c);
        if(oCase.SVMXC__Warranty__c == null && oEntRule.SVMXC__Include_Parent__c)
            oCase = getWarrantyOnBoth(oCase, oEntRule, mapParentIB.get(oCase.SVMXC__Component__c));
        if(oCase.SVMXC__Warranty__c == null && oEntRule.SVMXC__Include_Top_Level__c)
            oCase = getWarrantyOnBoth(oCase, oEntRule, mapTopLevelIB.get(oCase.SVMXC__Component__c));
        return oCase;
    }
    public Case getWarrantyOnBoth(Case oCase, SVMXC__ServiceMax_Processes__c oEntRule, Id ComponantID)
    {
        try
        {
            if(mapIBProductWarranty.get(ComponantID) != null && mapIBProductWarranty.get(ComponantID).size() > 0)
            {
                ID ProdId = mapProductId.get(ComponantID);
                date dtEntitleusing = date.today();
                try
                {
                    if(Setng_EntitleUsingFld != null && (!Setng_EntitleUsingFld.equalsIgnoreCase('Today') && !Setng_EntitleUsingFld.equalsIgnoreCase('CreatedDate')) && oCase.get(Setng_EntitleUsingFld) != null )
                        dtEntitleusing = date.valueOf(String.valueOf(oCase.get(Setng_EntitleUsingFld)));    
                }
                catch(exception ex)
                {
                    dtEntitleusing = date.today();
                }
                        
                for(SVMXC__Warranty__c oPW :mapIBProductWarranty.get(ComponantID))
                {
                    if(oPW.SVMXC__Start_Date__c <= dtEntitleusing && oPW.SVMXC__End_Date__c >= dtEntitleusing)
                    {
                        if(mapIBWarrantyTermsCounters.get(ProdId) != null && mapIBWarrantyTermsCounters.get(ProdId).size() > 0)
                        {
                            oCase.SVMXC__Warranty__c = oPW.Id;
                            oCase.SVMXC__Entitlement_Notes__c = 'Entitled by ServiceMax auto-entitlement process.'+
                                                                '\nAuto-Entitlement Rule: ' + oEntRule.SVMXC__Name__c +
                                                                '\nWarranty: ' + oPW.Name + 
                                                                '\nStart Date: ' + dateToString(oPW.SVMXC__Start_Date__c) +
                                                                '\nEnd Date: ' + dateToString(oPW.SVMXC__End_Date__c);
                            //IsServiceContractFound = true;
                            IsCaseEntitled = true;
                            //Added on 2/3/2011 Due to Defect 001402 (By Amar)
                            if(SetBillingType == true)
                                oCase.SVMXC__Billing_Type__c = 'Warranty';
                            break;
                        }
                    }
                 }
            }
        }
        catch(exception ex)
        { 
            IsException = true;
            strExecptin = ex.getMessage();
        }
        return oCase;
    }
    public Case getServiceContractOnValidityDate(Case oCase, SVMXC__ServiceMax_Processes__c oEntRule, Integer iCaseIndex)
    {
        oCase = getServiceContractOnValidityDate(oCase, oEntRule, oCase.SVMXC__Component__c, iCaseIndex);
        if(oCase.SVMXC__Service_Contract__c == null && oEntRule.SVMXC__Include_Parent__c)
            oCase = getServiceContractOnValidityDate(oCase, oEntRule, mapParentIB.get(oCase.SVMXC__Component__c), iCaseIndex);
        if(oCase.SVMXC__Service_Contract__c == null && oEntRule.SVMXC__Include_Top_Level__c)
            oCase = getServiceContractOnValidityDate(oCase, oEntRule, mapTopLevelIB.get(oCase.SVMXC__Component__c), iCaseIndex);
        return oCase;
    }
    
    public Case getServiceContractOnValidityDate(Case oCase, SVMXC__ServiceMax_Processes__c oEntRule, Id ComponantID, Integer iCaseIndex)
    {
        if(ComponantID != null && mapIBServiceContractCoverage.get(ComponantID) != null && mapIBServiceContractCoverage.get(ComponantID).size() > 0)
        {
            for(SVMXC__Service_Contract_Products__c oSCP :mapIBServiceContractCoverage.get(ComponantID))
            {
                date dtEntitleusing = date.today();
                date DateStart;
                date DateEnd;
                
                try
                {
                    if(Setng_EntitleUsingFld != null && (!Setng_EntitleUsingFld.equalsIgnoreCase('Today') && !Setng_EntitleUsingFld.equalsIgnoreCase('CreatedDate')) && oCase.get(Setng_EntitleUsingFld) != null )
                        dtEntitleusing = date.valueOf(String.valueOf(oCase.get(Setng_EntitleUsingFld)));
                }
                catch(exception ex)
                {
                    dtEntitleusing = date.today();
                }
                
                if(oSCP.SVMXC__Start_Date__c == null || oSCP.SVMXC__End_Date__c == null){
                    DateStart = oSCP.SVMXC__Service_Contract__r.SVMXC__Start_Date__c;
                    DateEnd = oSCP.SVMXC__Service_Contract__r.SVMXC__End_Date__c;
                }
                else{
                    if(oSCP.SVMXC__Service_Contract__r.SVMXC__Start_Date__c <= dtEntitleusing && oSCP.SVMXC__Service_Contract__r.SVMXC__End_Date__c >= dtEntitleusing){
                        DateStart = oSCP.SVMXC__Start_Date__c;
                        DateEnd = oSCP.SVMXC__End_Date__c;   
                    }
                }
                boolean isValidSC = true;
                
                if(DateStart <= dtEntitleusing  && DateEnd >= dtEntitleusing)
                {
                    if(oEntRule.SVMXC__Match_Contact__c)
                    {
                        if(!(oCase.ContactId != null && mapContactSC.ContainsKey(oCase.ContactId) && mapContactSC.get(oCase.ContactId).contains(oSCP.SVMXC__Service_Contract__c)))
                            isValidSC = false;
                    }
                    if(oEntRule.SVMXC__Match_Account__c)
                    {
                        if(mapCaseAccount.get(iCaseIndex) != oSCP.SVMXC__Service_Contract__r.SVMXC__Company__c)
                            isValidSC = false;
                    }
                    
                    if(isValidSC)
                    {
                        oCase.SVMXC__Service_Contract__c = oSCP.SVMXC__Service_Contract__c;
                        
                        if(oEntRule.SVMXC__Allow_Override__c){
                            oCase.SVMXC__SLA_Terms__c = oSCP.SVMXC__Service_Contract__r.SVMXC__Service_Level__c;
                            DateStart = oSCP.SVMXC__Service_Contract__r.SVMXC__Start_Date__c;
                            DateEnd = oSCP.SVMXC__Service_Contract__r.SVMXC__End_Date__c;
                        }
                        else{
                            if(oSCP.SVMXC__SLA_Terms__c != null){
                                oCase.SVMXC__SLA_Terms__c = oSCP.SVMXC__SLA_Terms__c;
                            }
                            else
                                oCase.SVMXC__SLA_Terms__c = oSCP.SVMXC__Service_Contract__r.SVMXC__Service_Level__c;
                        }
                        oCase.SVMXC__Entitlement_Notes__c = 'Entitled by ServiceMax auto-entitlement process.'+
                                                            '\nAuto-Entitlement Rule: ' + oEntRule.SVMXC__Name__c +
                                                            '\nService Contract: ' + oSCP.SVMXC__Service_Contract__r.Name + 
                                                            '\nStart Date: ' + dateToString(DateStart) +
                                                            '\nEnd Date: ' + dateToString(DateEnd);
                        IsCaseEntitled = true;
                        //Added on 2/3/2011 Due to Defect 001402 (By Amar)
                            if(SetBillingType == true)
                                oCase.SVMXC__Billing_Type__c = 'Contract';
                        //IsWarrantyFound = true;
                        
                        //Create map of Case index and Service Contract Covered Product for Entitlement History update.
                        mapCaseIndexContractIBCvrg.put(iCaseIndex, oSCP);
                        
                        break;
                    }
                    else if(oEntRule.SVMXC__Match_Location__c && oCase.SVMXC__site__c != null )
                    {
                        if(mapLocationContractLst.containsKey(oCase.SVMXC__site__c) && mapLocationContractLst.get(oCase.SVMXC__site__c) != null)
                            oCase = getServiceContractOnLocation(oCase, oEntRule, mapLocationContractLst.get(oCase.SVMXC__site__c), iCaseIndex);
                    }
                }
                else if(oEntRule.SVMXC__Match_Location__c && oCase.SVMXC__site__c != null )
                {
                    if(mapLocationContractLst.containsKey(oCase.SVMXC__site__c) && mapLocationContractLst.get(oCase.SVMXC__site__c) != null)
                        oCase = getServiceContractOnLocation(oCase, oEntRule, mapLocationContractLst.get(oCase.SVMXC__site__c), iCaseIndex);
                }
            }
        }
        else if(oEntRule.SVMXC__Match_Location__c && oCase.SVMXC__site__c != null )
        {
            if(mapLocationContractLst.containsKey(oCase.SVMXC__site__c) && mapLocationContractLst.get(oCase.SVMXC__site__c) != null)
                oCase = getServiceContractOnLocation(oCase, oEntRule, mapLocationContractLst.get(oCase.SVMXC__site__c), iCaseIndex);
        }
        return oCase;
    }
    
    //Method to calculate location based Service COntract. 
    public Case getServiceContractOnLocation(Case oCase, SVMXC__ServiceMax_Processes__c oEntRule, list<SVMXC__Service_Contract__c> lstContract, Integer iCaseIndex)
    {
        if(lstContract != null && lstContract.size() > 0)
        {
            for(SVMXC__Service_Contract__c objContract : lstContract)
            {
                date dtEntitleusing = date.today();
                try
                {
                    if(Setng_EntitleUsingFld != null && (!Setng_EntitleUsingFld.equalsIgnoreCase('Today') && !Setng_EntitleUsingFld.equalsIgnoreCase('CreatedDate')) && oCase.get(Setng_EntitleUsingFld) != null )
                        dtEntitleusing = date.valueOf(String.valueOf(oCase.get(Setng_EntitleUsingFld)));
                }
                catch(exception ex)
                {
                    dtEntitleusing = date.today();
                }
                
                if(objContract.SVMXC__Start_Date__c <= dtEntitleusing  && objContract.SVMXC__End_Date__c >= dtEntitleusing)
                {
                    boolean isValidLocBasedContract = true;
                    if(oEntRule.SVMXC__Match_Contact__c)
                    {
                        if(!(oCase.ContactId != null && mapContactSC.ContainsKey(oCase.ContactId) && mapContactSC.get(oCase.ContactId).contains(objContract.Id)))
                            isValidLocBasedContract = false;
                    }
                    if(oEntRule.SVMXC__Match_Account__c)
                    {
                        if(mapCaseAccount.get(iCaseIndex) != objContract.SVMXC__Company__c)
                            isValidLocBasedContract = false;
                    }
                    
                    if(oEntRule.SVMXC__Allow_Override__c){
                        oCase.SVMXC__Service_Contract__c = objContract.Id;
                        oCase.SVMXC__SLA_Terms__c = objContract.SVMXC__Service_Level__c;
                        Date StartDate = objContract.SVMXC__Start_Date__c;
                        Date EndDate = objContract.SVMXC__End_Date__c;
                        
                        IsCaseEntitled = true;
                        oCase.SVMXC__Entitlement_Notes__c = 'Entitled by ServiceMax auto-entitlement process.'+
                                                                '\nAuto-Entitlement Rule: ' + oEntRule.SVMXC__Name__c +
                                                                '\nService Contract: ' + objContract.Name + 
                                                                '\nStart Date: ' + dateToString(StartDate) +
                                                                '\nEnd Date: ' + dateToString(EndDate);
                        if(SetBillingType == true)
                            oCase.SVMXC__Billing_Type__c = 'Contract';
                    }
                    else {
                        if(mapServiceContractandCoveredLocations != null && mapServiceContractandCoveredLocations.size() > 0){
                            List<SVMXC__Service_Contract_Sites__c> coveredLocationRec = mapServiceContractandCoveredLocations.get(objContract.Id);
                            for(SVMXC__Service_Contract_Sites__c covLocForServiceContract : coveredLocationRec ){ 
                                if(covLocForServiceContract.SVMXC__Site__c == oCase.SVMXC__Site__c){
                                    Date StartDate ; 
                                    Date EndDate ;
                                    if(covLocForServiceContract.SVMXC__Start_Date__c == null || covLocForServiceContract.SVMXC__End_Date__c == null) {
                                        StartDate = objContract.SVMXC__Start_Date__c; 
                                        EndDate = objContract.SVMXC__End_Date__c;
                                    }
                                    else{
                                        if(objContract.SVMXC__Start_Date__c <= dtEntitleusing && objContract.SVMXC__End_Date__c >= dtEntitleusing){
                                            StartDate = covLocForServiceContract.SVMXC__Start_Date__c; 
                                            EndDate = covLocForServiceContract.SVMXC__End_Date__c; 
                                        }
                                    }
                                    
                                    if(StartDate <= dtEntitleusing  && EndDate >= dtEntitleusing){
                                        if(IsValidLocBasedContract){    
                                            oCase.SVMXC__Service_Contract__c = objContract.Id;
                                            if(covLocForServiceContract.SVMXC__SLA_Terms__c != null)
                                                oCase.SVMXC__SLA_Terms__c = covLocForServiceContract.SVMXC__SLA_Terms__c;
                                            else
                                                oCase.SVMXC__SLA_Terms__c = objContract.SVMXC__Service_Level__c;
                                            
                                            
                                            IsCaseEntitled = true;
                                            oCase.SVMXC__Entitlement_Notes__c = 'Entitled by ServiceMax auto-entitlement process.'+
                                                                                    '\nAuto-Entitlement Rule: ' + oEntRule.SVMXC__Name__c +
                                                                                    '\nService Contract: ' + objContract.Name + 
                                                                                    '\nStart Date: ' + dateToString(StartDate) +
                                                                                    '\nEnd Date: ' + dateToString(EndDate);
                                            if(SetBillingType == true)
                                                oCase.SVMXC__Billing_Type__c = 'Contract';
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return oCase;
    }
    
    public Case getServiceContractOnCounters(Case oCase, SVMXC__ServiceMax_Processes__c oEntRule, Integer iCaseIndex)
    {
        oCase = getServiceContractOnCounters(oCase, oEntRule, oCase.SVMXC__Component__c, iCaseIndex);
        if(oCase.SVMXC__Service_Contract__c == null && oEntRule.SVMXC__Include_Parent__c)
            oCase = getServiceContractOnCounters(oCase, oEntRule, mapParentIB.get(oCase.SVMXC__Component__c), iCaseIndex);
        if(oCase.SVMXC__Service_Contract__c == null && oEntRule.SVMXC__Include_Top_Level__c)
            oCase = getServiceContractOnCounters(oCase, oEntRule, mapTopLevelIB.get(oCase.SVMXC__Component__c), iCaseIndex);
        return oCase;
    }
    public Case getServiceContractOnCounters(Case oCase, SVMXC__ServiceMax_Processes__c oEntRule, Id ComponantID, Integer iCaseIndex)
    {
        if(mapIBServiceContractCoverageCounters.get(ComponantID) != null && mapIBServiceContractCoverageCounters.get(ComponantID).size() > 0)
        {
            for(SVMXC__Service_Contract__c oSC :mapIBServiceContractCoverageCounters.get(ComponantID).values())
            {
                boolean isValidSC = true;
                if(oEntRule.SVMXC__Match_Contact__c)
                {
                    if(!(oCase.ContactId != null && mapContactSC.ContainsKey(oCase.ContactId) && mapContactSC.get(oCase.ContactId).contains(oSC.Id)))
                        isValidSC = false;
                }
                if(oEntRule.SVMXC__Match_Account__c)
                {
                    if(mapCaseAccount.get(iCaseIndex) != oSC.SVMXC__Company__c)
                        isValidSC = false;
                }
                if(isValidSC)
                {
                    if(mapServiceContractCoverageProduct != null && mapServiceContractCoverageProduct.size() > 0 && mapServiceContractCoverageProduct.containsKey(oSC.Id) && mapServiceContractCoverageProduct.get(oSC.Id) != null)
                    {
                        for(SVMXC__Service_Contract_Products__c oSCP : mapServiceContractCoverageProduct.get(oSC.Id))
                        {
                            if(oSCP.SVMXC__Installed_Product__c == oCase.SVMXC__Component__c)
                            {
                                if(oSCP.SVMXC__SLA_Terms__c != null)
                                    oCase.SVMXC__SLA_Terms__c = oSCP.SVMXC__SLA_Terms__c;
                                else
                                    oCase.SVMXC__SLA_Terms__c = oSC.SVMXC__Service_Level__c;
                                    
                                //Create map of Case index and Service Contract Covered Product for Entitlement History update.
                                    mapCaseIndexContractIBCvrg.put(iCaseIndex, oSCP);
                                break;
                            }
                        }
                    }
                    oCase.SVMXC__Service_Contract__c = oSC.Id;
                    oCase.SVMXC__SLA_Terms__c = oSC.SVMXC__Service_Level__c;
                    oCase.SVMXC__Entitlement_Notes__c = 'Entitled by ServiceMax auto-entitlement process.'+
                                                        '\nAuto-Entitlement Rule: ' + oEntRule.SVMXC__Name__c +
                                                        '\nService Contract: ' + oSC.Name;
                    IsCaseEntitled = true;
                    //Added on 2/3/2011 Due to Defect 001402 (By Amar)
                    if(SetBillingType == true)
                        oCase.SVMXC__Billing_Type__c = 'Contract';
                    
                    break;
                }
            }
        }
        return oCase;
    }
    public Case getServiceContractOnBoth(Case oCase, SVMXC__ServiceMax_Processes__c oEntRule, Integer iCaseIndex)
    {
        oCase = getServiceContractOnBoth(oCase, oEntRule, oCase.SVMXC__Component__c, iCaseIndex);
        if(oCase.SVMXC__Service_Contract__c == null && oEntRule.SVMXC__Include_Parent__c)
            oCase = getServiceContractOnBoth(oCase, oEntRule, mapParentIB.get(oCase.SVMXC__Component__c), iCaseIndex);
        if(oCase.SVMXC__Service_Contract__c == null && oEntRule.SVMXC__Include_Top_Level__c)
            oCase = getServiceContractOnBoth(oCase, oEntRule, mapTopLevelIB.get(oCase.SVMXC__Component__c), iCaseIndex);
        return oCase;
    }
    public Case getServiceContractOnBoth(Case oCase, SVMXC__ServiceMax_Processes__c oEntRule, Id ComponantID, Integer iCaseIndex)
    {
       
        if(oCase.SVMXC__Component__c != null && mapIBServiceContractCoverage.get(oCase.SVMXC__Component__c) != null && mapIBServiceContractCoverage.get(oCase.SVMXC__Component__c).size() > 0)
        {
            
            date dtEntitleusing = date.today();
            try
            {
                if(Setng_EntitleUsingFld != null && (!Setng_EntitleUsingFld.equalsIgnoreCase('Today') && !Setng_EntitleUsingFld.equalsIgnoreCase('CreatedDate')) && oCase.get(Setng_EntitleUsingFld) != null )
                    dtEntitleusing = date.valueOf(String.valueOf(oCase.get(Setng_EntitleUsingFld)));
            }
            catch(exception ex)
            {
                dtEntitleusing = date.today();
            }
            for(SVMXC__Service_Contract_Products__c oSCP :mapIBServiceContractCoverage.get(oCase.SVMXC__Component__c))
            {
                
                date DateStart;
                date DateEnd;
                if(oSCP.SVMXC__Start_Date__c == null || oSCP.SVMXC__End_Date__c == null){
                    DateStart = oSCP.SVMXC__Service_Contract__r.SVMXC__Start_Date__c;
                    DateEnd = oSCP.SVMXC__Service_Contract__r.SVMXC__End_Date__c;
                }
                else{
                    if(oSCP.SVMXC__Service_Contract__r.SVMXC__Start_Date__c <= dtEntitleusing && oSCP.SVMXC__Service_Contract__r.SVMXC__End_Date__c >= dtEntitleusing){
                        DateStart = oSCP.SVMXC__Start_Date__c;
                        DateEnd = oSCP.SVMXC__End_Date__c;   
                    }
                }
                Boolean isValidSC = true;
                
                if(DateStart <= dtEntitleusing && DateEnd >= dtEntitleusing)
                {   
                    if(mapIBServiceContractCoverageCounters.get(oCase.SVMXC__Component__c) != null && mapIBServiceContractCoverageCounters.get(oCase.SVMXC__Component__c).get(oSCP.SVMXC__Service_Contract__c) != null)
                    {   
                        if(oEntRule.SVMXC__Match_Contact__c)
                        {
                            if(!(oCase.ContactId != null && mapContactSC.ContainsKey(oCase.ContactId) && mapContactSC.get(oCase.ContactId).contains(oSCP.SVMXC__Service_Contract__c)))
                                isValidSC = false;
                        }
                        if(oEntRule.SVMXC__Match_Account__c)
                        {
                            if(mapCaseAccount.get(iCaseIndex) != oSCP.SVMXC__Service_Contract__r.SVMXC__Company__c)
                                isValidSC = false;
                        }
                        
                        if(isValidSC)
                        {
                            oCase.SVMXC__Service_Contract__c = oSCP.SVMXC__Service_Contract__c;
                            
                            if(oEntRule.SVMXC__Allow_Override__c){
                                oCase.SVMXC__SLA_Terms__c = oSCP.SVMXC__Service_Contract__r.SVMXC__Service_Level__c;
                                DateStart = oSCP.SVMXC__Service_Contract__r.SVMXC__Start_Date__c;
                                DateEnd = oSCP.SVMXC__Service_Contract__r.SVMXC__End_Date__c;
                            }
                            else{
                                if(oSCP.SVMXC__SLA_Terms__c != null){
                                    oCase.SVMXC__SLA_Terms__c = oSCP.SVMXC__SLA_Terms__c;
                                }
                                else
                                    oCase.SVMXC__SLA_Terms__c = oSCP.SVMXC__Service_Contract__r.SVMXC__Service_Level__c;
                                    
                            }
                            
                            oCase.SVMXC__Entitlement_Notes__c = 'Entitled by ServiceMax auto-entitlement process.'+
                                                                '\nAuto-Entitlement Rule: ' + oEntRule.SVMXC__Name__c +
                                                                '\nService Contract: ' + oSCP.SVMXC__Service_Contract__r.Name + 
                                                                '\nStart Date: ' + dateToString(DateStart) +
                                                                '\nEnd Date: ' + dateToString(DateEnd);
                            IsCaseEntitled = true;
                            //Added on 2/3/2011 Due to Defect 001402 (By Amar)
                            if(SetBillingType == true) 
                                oCase.SVMXC__Billing_Type__c = 'Contract';
                            
                            //Create map of Case index and Service Contract Covered Product for Entitlement History update.
                                mapCaseIndexContractIBCvrg.put(iCaseIndex, oSCP);
                    
                            break;
                        }
                        else if(oEntRule.SVMXC__Match_Location__c && oCase.SVMXC__site__c != null )
                        {
                            if(mapLocationContractLst.containsKey(oCase.SVMXC__site__c) && mapLocationContractLst.get(oCase.SVMXC__site__c) != null)
                                oCase = getServiceContractOnLocation(oCase, oEntRule, mapLocationContractLst.get(oCase.SVMXC__site__c), iCaseIndex);
                        }
                    }
                }
                else if(oEntRule.SVMXC__Match_Location__c && oCase.SVMXC__site__c != null )
                {
                    if(mapLocationContractLst.containsKey(oCase.SVMXC__site__c) && mapLocationContractLst.get(oCase.SVMXC__site__c) != null)
                        oCase = getServiceContractOnLocation(oCase, oEntRule, mapLocationContractLst.get(oCase.SVMXC__site__c), iCaseIndex);
                }
            }
        }
        else if(oEntRule.SVMXC__Match_Location__c && oCase.SVMXC__site__c != null )
        {
            if(mapLocationContractLst.containsKey(oCase.SVMXC__site__c) && mapLocationContractLst.get(oCase.SVMXC__site__c) != null)
                oCase = getServiceContractOnLocation(oCase, oEntRule, mapLocationContractLst.get(oCase.SVMXC__site__c), iCaseIndex);
        }
        return oCase;
    }
    public void updateCounterMaps(Id IdIB)
    {
        //if(mapCounterReadings.ContainsKey(IdIB)) Commented for the Multiple counter reading defect 020165
        if(mapIBIDAndListCounterReadings.ContainsKey(IdIB))
        {
            //SVMXC__Counter_Details__c oCR = mapCounterReadings.get(IdIB); Commented for the Multiple counter reading defect 020165
            for(SVMXC__Counter_Details__c oCR : mapIBIDAndListCounterReadings.get(IdIB)){
                map<Id, SVMXC__Counter_Details__c> m1 = mapCounterCoverageIB.get(IdIB);
                if(m1 != null)
                {
                    for(SVMXC__Counter_Details__c oCD :m1.values())
                    {
                        if(oCR.SVMXC__Counter_Definition__c == oCD.SVMXC__Counter_Definition__c)
                        {
                            if(oCR.SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c == 'Increasing')
                            {
                                if(oCD.SVMXC__Coverage_Limit__c > oCR.SVMXC__Counter_Reading__c && oCD.SVMXC__Coverage_Starts_At__c <= oCR.SVMXC__Counter_Reading__c)
                                {
                                    SVMXC__Service_Contract__c oSC = (SVMXC__Service_Contract__c)oCD.getSObject('SVMXC__Service_Maintenance_Contract__r');
                                    if(oSC != null)
                                    {
                                        if(!mapIBServiceContractCoverageCounters.ContainsKey(IdIB))
                                            mapIBServiceContractCoverageCounters.put(IdIB, new map<Id, SVMXC__Service_Contract__c>());
                                        mapIBServiceContractCoverageCounters.get(IdIB).put(oSC.Id, oSC);
                                    }
                                }
                            }
                            else if(oCR.SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c == 'Decreasing')
                            {
                                //if(oCD.SVMXC__Coverage_Limit__c >= oCR.SVMXC__Counter_Reading__c && oCD.SVMXC__Coverage_Starts_At__c < oCR.SVMXC__Counter_Reading__c) Commented for the Decreasing counter defect 019056
                                if(oCD.SVMXC__Coverage_Limit__c < oCR.SVMXC__Counter_Reading__c && oCD.SVMXC__Coverage_Starts_At__c >= oCR.SVMXC__Counter_Reading__c)
                                {
                                    SVMXC__Service_Contract__c oSC = (SVMXC__Service_Contract__c)oCD.getSObject('SVMXC__Service_Maintenance_Contract__r');
                                    if(oSC != null)
                                    {
                                        if(!mapIBServiceContractCoverageCounters.ContainsKey(IdIB))
                                            mapIBServiceContractCoverageCounters.put(IdIB, new map<Id, SVMXC__Service_Contract__c>());
                                        mapIBServiceContractCoverageCounters.get(IdIB).put(oSC.Id, oSC);
                                    }
                                }
                            }
                            fillMapContractNCoverProduct();
                        }
                    }
                }
                
                map<Id, SVMXC__Counter_Details__c> m2 = mapCounterCoverageProduct.get(mapProductId.get(IdIB));
                if(m2 != null)
                {
                    for(SVMXC__Counter_Details__c oCD :m2.values())
                    {
                        if(oCR.SVMXC__Counter_Definition__c == oCD.SVMXC__Counter_Definition__c)
                        {
                            ID ProdId = mapProductId.get(IdIB);
                            if(oCR.SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c == 'Increasing')
                            {
                                if(oCD.SVMXC__Coverage_Limit__c > oCR.SVMXC__Counter_Reading__c && oCD.SVMXC__Coverage_Starts_At__c <= oCR.SVMXC__Counter_Reading__c)
                                {
                                    SVMXC__Service_Template__c oWT = (SVMXC__Service_Template__c)oCD.getSObject('SVMXC__Warranty_Terms__r');
                                    if(oWT != null)
                                    {
                                        if(!mapIBWarrantyTermsCounters.ContainsKey(ProdId))
                                            mapIBWarrantyTermsCounters.put(ProdId, new map<Id, SVMXC__Service_Template__c>());
                                        mapIBWarrantyTermsCounters.get(ProdId).put(oWT.Id, oWT);
                                    }
                                }
                            }
                            else if(oCR.SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c == 'Decreasing')
                            {
                                //if(oCD.SVMXC__Coverage_Limit__c >= oCR.SVMXC__Counter_Reading__c && oCD.SVMXC__Coverage_Starts_At__c < oCR.SVMXC__Counter_Reading__c) Commented for the Decreasing counter defect 019056
                                if(oCD.SVMXC__Coverage_Limit__c < oCR.SVMXC__Counter_Reading__c && oCD.SVMXC__Coverage_Starts_At__c >= oCR.SVMXC__Counter_Reading__c)
                                {
                                    SVMXC__Service_Template__c oWT = (SVMXC__Service_Template__c)oCD.getSObject('SVMXC__Warranty_Terms__r');
                                    if(oWT != null)
                                    {
                                        if(!mapIBWarrantyTermsCounters.ContainsKey(ProdId))
                                            mapIBWarrantyTermsCounters.put(ProdId, new map<Id, SVMXC__Service_Template__c>());
                                        mapIBWarrantyTermsCounters.get(ProdId).put(oCD.Id, oWT);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public void fillMapContractNCoverProduct()
    {
        //mapServiceContractCoverageProduct
        //mapIBServiceContractCoverageCounters
        List<String> SCONIds = new List<String>();
        if(mapIBServiceContractCoverageCounters != null && mapIBServiceContractCoverageCounters.size() > 0 )
        {
            for(String strKey : mapIBServiceContractCoverageCounters.keySet())
            {
                if(mapIBServiceContractCoverageCounters.get(strKey) != null)
                {
                    for(String strK : mapIBServiceContractCoverageCounters.get(strKey).keySet() )
                        SCONIds.add(strK);
                }
            }
            if(SCONIds != null && SCONIds.size() > 0)
            {
                // 5th Dec 2014
                // Defect Fix - 012922, to add SVMXC__Service_Contract__r.SVMXC__Start_Date__c,  SVMXC__Service_Contract__r.SVMXC__End_Date__c to query
                String strQueryCP = 'select SVMXC__Service_Contract__c, SVMXC__Service_Contract__r.SVMXC__Start_Date__c,  SVMXC__Service_Contract__r.SVMXC__End_Date__c, SVMXC__Start_Date__c, SVMXC__End_Date__c, SVMXC__Installed_Product__c, SVMXC__SLA_Terms__c from SVMXC__Service_Contract_Products__c where SVMXC__Service_Contract__c IN: SCONIds' ;
                List<SVMXC__Service_Contract_Products__c> lstObjSCP = Database.query(strQueryCP);
                if(lstObjSCP != null && lstObjSCP.size() > 0 )
                {
                    for(String strKey : mapIBServiceContractCoverageCounters.keySet())
                    {
                        if(mapIBServiceContractCoverageCounters.get(strKey) != null)
                        {
                            for(String strK : mapIBServiceContractCoverageCounters.get(strKey).keySet())
                            {
                                if(!(mapServiceContractCoverageProduct.containsKey(strK)))
                                {
                                    List<SVMXC__Service_Contract_Products__c> lstObjTempSCP = new List<SVMXC__Service_Contract_Products__c>();
                                    for(SVMXC__Service_Contract_Products__c SCP : lstObjSCP)
                                    {
                                        if(SCP.SVMXC__Service_Contract__c == strK)
                                            lstObjTempSCP.add(SCP);
                                    }
                                    mapServiceContractCoverageProduct.put(strK, lstObjTempSCP);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public void SVMX_DeriveProdfrmIB(list<case> lstCase, Map<String, String> mapSettings)
    {
        
        set<Id> setComponant = new set<Id>();
        for (Integer i = 0; i < lstCase.size(); i++) 
        {
            if(lstCase[i].SVMXC__Component__c != null)
                setComponant.add(lstCase[i].SVMXC__Component__c);
        }
        map<Id, SVMXC__Installed_Product__c> mapIB = new map<Id, SVMXC__Installed_Product__c>(); 
        if(setComponant.size() > 0)
            mapIB.putAll([Select id,SVMXC__Product__c,SVMXC__Top_Level__c from SVMXC__Installed_Product__c where id IN :setComponant]);
        
        if(mapIB.size() > 0 && mapSettings.containsKey('IPRD003_SET007') && mapSettings.get('IPRD003_SET007').ToUpperCase() == 'TRUE') //Check added by GM 16Nov-09
        {
            for (Integer i = 0; i < lstCase.size(); i++) 
            {
                if(lstCase[i].SVMXC__Component__c != null && mapIB.get(lstCase[i].SVMXC__Component__c) != null && mapIB.get(lstCase[i].SVMXC__Component__c).SVMXC__Product__c != null)  
                    lstCase[i].SVMXC__Product__c = mapIB.get(lstCase[i].SVMXC__Component__c).SVMXC__Product__c;
            }
        }
        if(mapIB.size() > 0 && mapSettings.containsKey('IPRD003_SET003') && mapSettings.get('IPRD003_SET003').ToUpperCase() == 'TRUE')//Added by amar due to enhancement bug no 001491 on 26th oct 2010
        {
            for (Integer i = 0; i < lstCase.size(); i++) 
            {
                if(lstCase[i].SVMXC__Component__c != null && mapIB.Containskey(lstCase[i].SVMXC__Component__c) && mapIB.get(lstCase[i].SVMXC__Component__c).SVMXC__Top_Level__c != null)  
                    lstCase[i].SVMXC__Top_Level__c = mapIB.get(lstCase[i].SVMXC__Component__c).SVMXC__Top_Level__c;
            }
        }
    }
}