public with sharing class PCAL_GetPrice_Case {

    public class SVMXException extends Exception{}

    public INTF_WebServicesDef.INTF_Response getPricingDefinitions(INTF_WebServicesDef.INTF_Request request)
    {
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        SFM_Utils utils = new SFM_Utils();
        Map<String, String> mapSettings;
        
        INTF_WebServicesDef.INTF_Response response = new INTF_WebServicesDef.INTF_Response();
        list<INTF_WebServicesDef.SVMXMap> lstPricingDetails = new list<INTF_WebServicesDef.SVMXMap>();
        
        mapSettings = commSettings.SVMX_getSettingList('CASE002');
        list<String> lstActivityPricebookId = new list<String>();
        list<String> lstActivityPricebookName = new list<String>();
        
        String strCurrencyIsoCode;
        String caseId;
        Id idCoveredWarranty;
        Id idCoveredServiceContract;
        Id idServiceOffering;
        list<String> lstProducts = new list<String>();
        list<String> lstActivitys = new list<String>();
        list<String> lstActivityParts = new list<String>();
        map<String, String> mapRecordTypePricebookName = new map<String, String>();
        String strCoveredBy = 'NOCOVERAGE';
        String strServiceOfferingCoverage = 'NOTCOVERED';
        system.debug('Request: ' + request);
        
        INTF_WebServicesDef.SVMXMap recordTypeInfoActivity = new INTF_WebServicesDef.SVMXMap('RECORDTYPEINFO_ACTIVITY', NULL);
        list<INTF_WebServicesDef.SVMXMap> lstRecordTypeInfoActivity = new list<INTF_WebServicesDef.SVMXMap>();
        // Get the setting parts pricebook information for Case Activity
        if(mapSettings.containsKey('SET001') && mapSettings.get('SET001') != NULL)
        {
            lstActivityPricebookName.add(mapSettings.get('SET001'));
            mapRecordTypePricebookName.put(mapSettings.get('SET001'), 'MASTER');
        }
        // Parse the request to get case id, currency code, case activities
        for(SVMXC.INTF_WebServicesDef.SVMXMap currentValMap : request.valueMap)
        {
            if(currentValMap.key == 'CASE')
                caseId = currentValMap.value;
            else if(currentValMap.key == 'CASECURRENCYISO')
                strCurrencyIsoCode = currentValMap.value;
            else if(currentValMap.key == 'ACTIVITY')
                lstActivitys = currentValMap.values;
        }
        
        //For labor we need to consider work order product if work detail does not have product
        if(lstActivitys != NULL && lstActivitys.size() > 0)
        {
            list<Case> lstCase = [Select SVMXC__Product__c from Case where Id = : caseId];
            for(Case objCase : lstCase)
            {
                if(objCase.SVMXC__Product__c != NULL)
                    lstActivityParts.add(objCase.SVMXC__Product__c);
            }
        }
        
        if(UserInfo.isMultiCurrencyOrganization() && (strCurrencyIsoCode == NULL || strCurrencyIsoCode == ''))
            throw new SVMXException('Your org is multicurrency enabled, please provide currency ISO code in request');
         
        // Get the Entitlement history and identify the coverage and service offerings
        list<SVMXC__Entitlement_History__c> lstEntitlementHistory = new list<SVMXC__Entitlement_History__c>();
        lstEntitlementHistory = [select Id, SVMXC__Entitled_By_Service__c, SVMXC__Entitled_Within_Threshold__c, SVMXC__Service_Order__c, SVMXC__Start_Date__c, SVMXC__End_Date__c, SVMXC__Warranty__c, SVMXC__Service_Contract__c from SVMXC__Entitlement_History__c where SVMXC__Case__c = :caseId and SVMXC__Inactive_Date__c = NULL];
        for(SVMXC__Entitlement_History__c history: lstEntitlementHistory)
        {
            if(history.SVMXC__Entitled_By_Service__c != NULL)
            {
                idServiceOffering = history.SVMXC__Entitled_By_Service__c;
                if(history.SVMXC__Entitled_Within_Threshold__c == true)
                    strServiceOfferingCoverage = 'COVERED';
            }
            
            // If case is covered by Warranty
            if(history.SVMXC__Warranty__c != NULL)
            {
                // Get the Warranty Id
                strCoveredBy = 'WARRANTY';
                idCoveredWarranty = history.SVMXC__Warranty__c;
                break;
            }
            // If case is covered by Service Contract
            else if(history.SVMXC__Service_Contract__c != NULL)
            {
                // Get the Service Contract Id
                strCoveredBy = 'SERVICECONTRACT';
                idCoveredServiceContract = history.SVMXC__Service_Contract__c;
                break;
            }
        }
        list<SVMXC__Service_Pricebook_Entry__c> lstActivityPricebookEntry = new list<SVMXC__Service_Pricebook_Entry__c>();    
        map<Id, SVMXC__Activity_Master__c> mapActivitys = new map<Id, SVMXC__Activity_Master__c> ();
        system.debug('List of Activity Price Book Name: ' + lstActivityPricebookName);
        if(lstActivitys != NULL && lstActivitys.size() > 0 && lstActivityPricebookName != NULL && lstActivityPricebookName.size() > 0)
        {
            list<SVMXC__Service_Pricebook__c> lstPriceBook = SVMXC_GetActivityPricebook(lstActivityPricebookId, lstActivityPricebookName);
            system.debug('List of Activity Price Book Records: ' + lstActivityPricebookName + ' lstPriceBook: ' + lstPriceBook);        
            for(SVMXC__Service_Pricebook__c priceBook: lstPriceBook)
            {
                for(String key: mapRecordTypePricebookName.keySet())
                {
                    if(mapRecordTypePricebookName.get(key) != NULL && key == priceBook.Name)
                        lstRecordTypeInfoActivity.add(new INTF_WebServicesDef.SVMXMap(mapRecordTypePricebookName.get(priceBook.Name), priceBook.Id));
                }
            }
        }
        
        recordTypeInfoActivity.valueMap = lstRecordTypeInfoActivity;
        lstPricingDetails.add(recordTypeInfoActivity);
        
        system.debug('Is case Covered by Warranty:' + idCoveredWarranty);
        system.debug('Is case Covered by Contract:' + idCoveredServiceContract);
        // If case covered by Warranty
        if(idCoveredWarranty != NULL)
        {
            list<SVMXC__Warranty__c> objWarrantyTemplate = [Select Id, SVMXC__Travel_Covered__c, SVMXC__Time_Covered__c, SVMXC__Material_Covered__c, SVMXC__Expenses_Covered__c from SVMXC__Warranty__c where Id = :idCoveredWarranty];
            INTF_WebServicesDef.SVMXMap wrpWarranty = new INTF_WebServicesDef.SVMXMap('WARRANTYDEFINITION', NULL);
            wrpWarranty.data = objWarrantyTemplate;
            lstPricingDetails.add(wrpWarranty);
        }// If work order is covered by Service Contract get the following pricing information
        else if(idCoveredServiceContract != NULL)
        {
            list<SVMXC__Service_Contract__c> lstServiceContract = [Select SVMXC__Default_Travel_Price__c, SVMXC__Default_Travel_Unit__c, SVMXC__Zone__c, SVMXC__Service_Pricebook__c, SVMXC__Default_Parts_Price_Book__c, SVMXC__Minimum_Labor__c, SVMXC__Minimum_Travel__c, SVMXC__Labor_Rounding_Type__c, SVMXC__Travel_Rounding_Type__c, SVMXC__Round_Labor_To_Nearest__c, SVMXC__Round_Travel_To_Nearest__c From SVMXC__Service_Contract__c where Id = :idCoveredServiceContract];
            
            if(lstServiceContract != NULL && lstServiceContract.size() == 1)
            {
                // Get Service Contract pricebook definition for parts
                SVMXC__Service_Contract__c objServiceContract = lstServiceContract[0];
                list<String> lstSCONActivityPricebookId = new list<String>();
                
                // Get Service Contract pricebook definition for labor
                if(objServiceContract.SVMXC__Service_Pricebook__c != NULL)
                {
                    lstSCONActivityPricebookId.add(objServiceContract.SVMXC__Service_Pricebook__c);
                    lstActivityPricebookId.add(objServiceContract.SVMXC__Service_Pricebook__c);
                    list<SVMXC__Service_Pricebook__c> lstPriceBook = SVMXC_GetActivityPricebook(lstSCONActivityPricebookId, lstActivityPricebookId);
                    INTF_WebServicesDef.SVMXMap recordTypeInfoContractLabor = new INTF_WebServicesDef.SVMXMap('RECORDTYPEINFO_ACTIVITY_CONTRACT', NULL);
                    list<INTF_WebServicesDef.SVMXMap> lstRecordTypeInfoContractLabor = new list<INTF_WebServicesDef.SVMXMap>();
                    for(SVMXC__Service_Pricebook__c priceBook: lstPriceBook)
                    {
                        lstRecordTypeInfoContractLabor.add(new INTF_WebServicesDef.SVMXMap('MASTER', priceBook.Id));
                    }
                    system.debug('List of Price Book:' + lstPriceBook);
                    recordTypeInfoContractLabor.valueMap = lstRecordTypeInfoContractLabor;
                    lstPricingDetails.add(recordTypeInfoContractLabor);
                }
                
                list<SVMXC__Pricing_Rule__c> lstPricingRules = new list<SVMXC__Pricing_Rule__c>();
                list<SVMXC__Labor_Pricing__c> lstLaborPricing = new list<SVMXC__Labor_Pricing__c>();
                list<SVMXC__Service_Contract_Services__c> lstIncludedServices = new list<SVMXC__Service_Contract_Services__c>();
                
                // If org is multicurrency enabled, get following pricing information only for the work order currency code, else get all pricing information for the contract
                if(UserInfo.isMultiCurrencyOrganization())
                {
                    // Get pricing rules for Contract
                    lstPricingRules = database.query('Select SVMXC__Named_Expression__c,SVMXC__Rate_Type__c, SVMXC__Rate__c From SVMXC__Pricing_Rule__c where SVMXC__Service_Contract__c = :idCoveredServiceContract AND CurrencyIsoCode = :strCurrencyIsoCode');
                    // Get special labor pricing for Contract
                    lstLaborPricing = database.query('Select SVMXC__Activity_Type__c, SVMXC__Product__c,SVMXC__Product_Family__c,SVMXC__Product_Line__c,SVMXC__Unit__c, SVMXC__Regular_Rate__c, SVMXC__Activity__c,SVMXC__Activity_Product__c, SVMXC__Minimum_Labor__c From SVMXC__Labor_Pricing__c where SVMXC__Service_Contract__c = :idCoveredServiceContract AND CurrencyIsoCode = :strCurrencyIsoCode');
                    // Get included services for Contract
                    lstIncludedServices = database.query('Select SVMXC__Travel_Discount_Not_Covered__c, SVMXC__Travel_Discount_Covered__c, SVMXC__Parts_Discount_Not_Covered__c, SVMXC__Parts_Discount_Covered__c, SVMXC__Labor_Discount_Not_Covered__c, SVMXC__Labor_Discount_Covered__c, SVMXC__Expense_Discount_Not_Covered__c, SVMXC__Expense_Discount_Covered__c From SVMXC__Service_Contract_Services__c where Id = :idServiceOffering AND CurrencyIsoCode = :strCurrencyIsoCode');
                }
                else
                {
                    lstPricingRules = [Select SVMXC__Named_Expression__c,SVMXC__Rate_Type__c, SVMXC__Rate__c From SVMXC__Pricing_Rule__c where SVMXC__Service_Contract__c = :idCoveredServiceContract];
                    lstLaborPricing = [Select SVMXC__Activity_Type__c, SVMXC__Product__c,SVMXC__Product_Family__c,SVMXC__Product_Line__c,SVMXC__Unit__c, SVMXC__Regular_Rate__c, SVMXC__Activity__c,SVMXC__Activity_Product__c, SVMXC__Minimum_Labor__c From SVMXC__Labor_Pricing__c where SVMXC__Service_Contract__c = :idCoveredServiceContract];
                    lstIncludedServices = [Select SVMXC__Travel_Discount_Not_Covered__c, SVMXC__Travel_Discount_Covered__c, SVMXC__Parts_Discount_Not_Covered__c, SVMXC__Parts_Discount_Covered__c, SVMXC__Labor_Discount_Not_Covered__c, SVMXC__Labor_Discount_Covered__c, SVMXC__Expense_Discount_Not_Covered__c, SVMXC__Expense_Discount_Covered__c From SVMXC__Service_Contract_Services__c where Id = :idServiceOffering];
                }
                INTF_WebServicesDef.SVMXMap wrpContract = new INTF_WebServicesDef.SVMXMap('CONTRACT_DEFINITION', NULL);
                wrpContract.data = lstServiceContract;
                lstPricingDetails.add(wrpContract);
                
                if(lstPricingRules != NULL && lstPricingRules.size() >0)
                {
                    INTF_WebServicesDef.SVMXMap wrpPricingRules = new INTF_WebServicesDef.SVMXMap('CONTRACT_PRICINGRULES', NULL);
                    wrpPricingRules.data = lstPricingRules;
                    lstPricingDetails.add(wrpPricingRules);
                }           
                
                if(lstLaborPricing != NULL && lstLaborPricing.size() >0)
                {
                    INTF_WebServicesDef.SVMXMap wrpLaborPricing = new INTF_WebServicesDef.SVMXMap('CONTRACT_SPECIALACTIVITYPRICING', NULL);
                    wrpLaborPricing.data = lstLaborPricing;
                    lstPricingDetails.add(wrpLaborPricing);
                }           
                            
                if(lstIncludedServices != NULL && lstIncludedServices.size() >0)
                {
                    INTF_WebServicesDef.SVMXMap wrpIncludedServises = new INTF_WebServicesDef.SVMXMap('CONTRACT_SERVICEOFFERING', strServiceOfferingCoverage);
                    wrpIncludedServises.data = lstIncludedServices;
                    lstPricingDetails.add(wrpIncludedServises);
                }
                
                List<INTF_WebServicesDef.SVMXMap> lstServiceExpressions = null;
                lstServiceExpressions = SVMXC_GetServiceExpressions(lstPricingRules);
                if(lstServiceExpressions != null && lstServiceExpressions.size() > 0)
                {
                    INTF_WebServicesDef.SVMXMap wrpRuleExpressions = new INTF_WebServicesDef.SVMXMap('RULES', NULL);
                    wrpRuleExpressions.valueMap = lstServiceExpressions;
                    lstPricingDetails.add(wrpRuleExpressions);
                }
                              
            }
        }
        //Get complete case details
        List<INTF_WebServicesDef.SVMXMap> lstCaseDetails = getLookupDefinition(caseId);
        if(lstCaseDetails != null && lstCaseDetails.size() > 0)
        lstPricingDetails.addAll(lstCaseDetails);
        // Get the labor pricebook entry for the requested labor, pricebook(Contract special pricebook, Setting pricebook)
        if(lstActivitys != NULL && lstActivitys.size() > 0 && ((lstActivityPricebookId != NULL && lstActivityPricebookId.size() > 0) || (lstActivityPricebookName != NULL && lstActivityPricebookName.size() > 0)))
        {
            if(UserInfo.isMultiCurrencyOrganization())//Currency handling needs to be implemented
                lstActivityPricebookEntry = database.query('SELECT Name, SVMXC__Unit__c, SVMXC__Regular_Rate__c, SVMXC__Price_Book__c, SVMXC__Activity_Type__c, SVMXC__Activity__c, SVMXC__Activity_Product__c, SVMXC__Product__c, SVMXC__Product_Family__c, SVMXC__Product_Line__c FROM SVMXC__Service_Pricebook_Entry__c WHERE SVMXC__Activity_Type__c IN : lstActivitys AND SVMXC__Price_Book__r.SVMXC__Active__c = true AND (SVMXC__Price_Book__r.Name IN :lstActivityPricebookName OR SVMXC__Price_Book__c IN :lstActivityPricebookId) AND CurrencyIsoCode = :strCurrencyIsoCode');
            else
                lstActivityPricebookEntry = [SELECT Name, SVMXC__Unit__c, SVMXC__Regular_Rate__c, SVMXC__Price_Book__c, SVMXC__Activity_Type__c, SVMXC__Activity__c, SVMXC__Activity_Product__c, SVMXC__Product__c, SVMXC__Product_Family__c, SVMXC__Product_Line__c FROM SVMXC__Service_Pricebook_Entry__c WHERE SVMXC__Activity_Type__c IN :lstActivitys AND SVMXC__Price_Book__r.SVMXC__Active__c = true AND (SVMXC__Price_Book__r.Name IN :lstActivityPricebookName OR SVMXC__Price_Book__c IN :lstActivityPricebookId)];
        }
        system.debug('List of Labor Price Book Entry :' + lstActivityPricebookEntry);
        INTF_WebServicesDef.SVMXMap wrpActivitys = new INTF_WebServicesDef.SVMXMap('ACTIVITYPRICING', NULL);
        wrpActivitys.data = lstActivityPricebookEntry;
        lstPricingDetails.add(wrpActivitys);
        
        //Get required tags
        INTF_WebServicesDef.SVMXMap wrpTags = new INTF_WebServicesDef.SVMXMap('TAGS', NULL);
        list<INTF_WebServicesDef.SVMXMap> lstTags = new list<INTF_WebServicesDef.SVMXMap>();
        lstTags.add(new INTF_WebServicesDef.SVMXMap('EVER005_TAG087', system.label.EVER005_TAG087));
        wrpTags.valueMap = lstTags;
        lstPricingDetails.add(wrpTags);
        
        response.message = JSON.serialize(lstPricingDetails);        
        return response;        
    }
    
    private list<INTF_WebServicesDef.SVMXMap> SVMXC_GetServiceExpressions(list<SVMXC__Pricing_Rule__c> pricingRules)
    {
        //get all the Expression IDs
        List<String> lstExpressionIDs = new List<String>();
        Map<Id,SVMXC__ServiceMax_Processes__c> mapExpressionObjs = new Map<Id,SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__SERVICEMAX_CONFIG_DATA__C> lstExpressionDetailsObjs = new List<SVMXC__SERVICEMAX_CONFIG_DATA__C>();
                
        if(pricingRules != null && pricingRules.size() > 0)
        {
            for(SVMXC__Pricing_Rule__c objCurrService : pricingRules)
            {
                if(objCurrService.SVMXC__Named_Expression__c != null && objCurrService.SVMXC__Named_Expression__c.length() > 0)
                {
                    lstExpressionIDs.add(objCurrService.SVMXC__Named_Expression__c);
                }
            }       
        }
        if(lstExpressionIDs.size() > 0)
        {
            mapExpressionObjs.putAll([Select SVMXC__Advance_Expression__c,Id from SVMXC__ServiceMax_Processes__c where id in: lstExpressionIDs and RecordType.Name = 'SVMX RULE']);
            lstExpressionDetailsObjs = [Select SVMXC__Field_Name__c,SVMXC__Operator__c,SVMXC__Operand__c,SVMXC__Sequence__c,SVMXC__Expression_Type__c,SVMXC__Expression_Rule__c,Id from SVMXC__SERVICEMAX_CONFIG_DATA__C where SVMXC__Expression_Rule__c in: lstExpressionIDs and RecordType.Name = 'EXPRESSIONS']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        Map<String,INTF_WebServicesDef.SVMXMap> objExpressionRes = new Map<String,INTF_WebServicesDef.SVMXMap>();
        if(mapExpressionObjs.keySet().size() > 0 && lstExpressionDetailsObjs.size() > 0)
        {
            for(SVMXC__SERVICEMAX_CONFIG_DATA__C objCurrDetail : lstExpressionDetailsObjs)
            {
                if(!objExpressionRes.containsKey(objCurrDetail.SVMXC__Expression_Rule__c) && mapExpressionObjs.containsKey(objCurrDetail.SVMXC__Expression_Rule__c))
                {
                    INTF_WebServicesDef.SVMXMap objTempDetail = new INTF_WebServicesDef.SVMXMap();
                    objTempDetail.data = new List<sObject>();
                    objTempDetail.value = mapExpressionObjs.get(objCurrDetail.SVMXC__Expression_Rule__c).SVMXC__Advance_Expression__c;
                    objTempDetail.key = mapExpressionObjs.get(objCurrDetail.SVMXC__Expression_Rule__c).Id;
                    objExpressionRes.put(objCurrDetail.SVMXC__Expression_Rule__c,objTempDetail);
                }
                objExpressionRes.get(objCurrDetail.SVMXC__Expression_Rule__c).data.add(objCurrDetail);
            }
        }
        
        return objExpressionRes.values();
    } 
    
    private list<SVMXC__Service_Pricebook__c> SVMXC_GetActivityPricebook(list<String> priceBookId, list<String> priceBookName)
    {
        if (priceBookName == null)
        {
            return null;
        } 
        try
        {
            list<SVMXC__Service_Pricebook__c> lstPricebook = [SELECT Id, Name FROM SVMXC__Service_Pricebook__c WHERE (Id IN : priceBookId OR Name IN:priceBookName) AND SVMXC__Active__c = true];
            return lstPricebook;
        } 
        catch(System.Exception ex )
        {
        }
        return null;
    }
    
    public List<INTF_WebServicesDef.SVMXMap> getLookupDefinition(String IdCase)
    {
        SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils(); 
        DCON_Utils dcUtils = new DCON_Utils();
        
        List<INTF_WebServicesDef.SVMXMap> response = new List<INTF_WebServicesDef.SVMXMap>();
        
        String querySelect;
        List<String> refFields_L = new List<String>();
        List<String> dateTimeFields_L = new List<String>();
        List<String> dateFields_L = new List<String>();
        Map<String,String> replacementRef = new Map<String,String>();
        Map<String,String> replacementNameField = new Map<String,String>();
        Map<String, SObjectField> souObjfieldMap = Schema.SObjectType.Case.fields.getMap(); // Get field definition map for work order
        /*********Duplicate Check**************************************/
                 COMM_Utils_V2 objCommUtilV2 = new COMM_Utils_V2();
                    souObjfieldMap = objCommUtilV2.removeDuplicateFields(souObjfieldMap);
        /****************************************************************/
        DCON_Utils.referenceFields_WP reference_M = dcUtils.SVMX_getReferenceFields(souObjfieldMap,true);
        List<String> allFields_L = reference_M.allFields_L; //Get the all field list
        refFields_L = reference_M.referenceFields_L; //Get the reference field list
        dateTimeFields_L = reference_M.dateTimeFields_L; //Get the dateTime field list
        dateFields_L = reference_M.dateFields_L; //Get the date field list
        replacementRef = reference_M.replacementReference_M;  //Get the replacement reference field map
        replacementNameField = reference_M.replacementField_M;  //Get the name field for reference map
        querySelect = utils.SVMX_getFieldNamesFromList(allFields_L); //Convert the list of strings to coma seperated string
        String strWhereClause= 'Id = :IdCase';
        list<Case> case_LO = Database.query('SELECT ' + querySelect +' FROM Case WHERE '+string.escapeSingleQuotes(strWhereClause));
        
        List<INTF_WebServicesDef.SVMXMap> specialFields_LWP = new List<INTF_WebServicesDef.SVMXMap>();
        for(Case objCase: case_LO)
        {
            for(String fieldApi : refFields_L)
            {
                if(objCase.get(fieldApi) != NULL)
                {
                    INTF_WebServicesDef.SVMXMap wrpLookupValue;
                    Sobject ref_TO = objCase.getSobject(replacementRef.get(fieldApi));
                    if(ref_TO != NULL)
                    {
                        wrpLookupValue = new INTF_WebServicesDef.SVMXMap(fieldApi, String.valueof(ref_TO.get(replacementNameField.get(fieldApi))) );
                        specialFields_LWP.add(wrpLookupValue);
                    }
                }
            }
        }
        
        INTF_WebServicesDef.SVMXMap wrpLookupDefinition = new INTF_WebServicesDef.SVMXMap('LOOKUP_DEFINITION', NULL);
        wrpLookupDefinition.valueMap = specialFields_LWP;
        response.add(wrpLookupDefinition);
        
        INTF_WebServicesDef.SVMXMap wrpCaseData = new INTF_WebServicesDef.SVMXMap('CASE_DATA', NULL);
        wrpCaseData.data = case_LO;
        response.add(wrpCaseData);
                    
        return response;
    }

}