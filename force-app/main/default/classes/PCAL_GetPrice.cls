public with sharing class PCAL_GetPrice {
    
    public String strCurrencyIsoCode;    
    public List<String> lstProducts = new List<String>();
    public List<String> lstLabor = new List<String>();   
    public boolean entitlementCheckRequired = true; //If true entitlement check required
    public class SVMXException extends Exception{}

    public INTF_WebServicesDef.INTF_Response getPricingDefinitions(INTF_WebServicesDef.INTF_Request request)
    {
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        SFM_Utils utils = new SFM_Utils();
        Map<String, String> mapSettings;
        
        INTF_WebServicesDef.INTF_Response response = new INTF_WebServicesDef.INTF_Response();
        list<INTF_WebServicesDef.SVMXMap> lstPricingDetails = new list<INTF_WebServicesDef.SVMXMap>();
        
        // Get Usage and Estimate recordtype Id
        List<String> recTypeNames = new List<String>();
        recTypeNames.add('SVMXC__Service_Order_Line__c~Estimate');
        recTypeNames.add('SVMXC__Service_Order_Line__c~Usage/Consumption');
        Map<String, Id> mapRecType_Map = new Map<String, Id>();
        mapRecType_Map = utils.getRecordTypes(recTypeNames);
            
        mapSettings = commSettings.SVMX_getSettingList('WORD005');
        list<String> lstPartsPricebookId = new list<String>();
        list<String> lstLaborPricebookId = new list<String>();
        list<String> lstPartsPricebookName = new list<String>();
        list<String> lstLaborPricebookName = new list<String>();
        String workOrderId;
        Id idCoveredWarranty;
        Id idCoveredServiceContract;
        Id idServiceOffering;

        list<String> lstLaborParts = new list<String>();
        map<String, String> mapRecordTypePricebookName = new map<String, String>();
        String strCoveredBy = 'NOCOVERAGE';
        String strServiceOfferingCoverage = 'NOTCOVERED';
        String strLaborPriceBookToBeConsidered = 'Service price book';
        system.debug('Request: ' + request);
        
        INTF_WebServicesDef.SVMXMap recordTypeInfoParts = new INTF_WebServicesDef.SVMXMap('RECORDTYPEINFO_PARTS', NULL);
        INTF_WebServicesDef.SVMXMap recordTypeInfoLabor = new INTF_WebServicesDef.SVMXMap('RECORDTYPEINFO_LABOR', NULL);
        list<INTF_WebServicesDef.SVMXMap> lstRecordTypeInfoParts = new list<INTF_WebServicesDef.SVMXMap>();
        list<INTF_WebServicesDef.SVMXMap> lstRecordTypeInfoLabor = new list<INTF_WebServicesDef.SVMXMap>();
        
        //Get the setting to consider pricebook for labor. Default behaviour is to consider labor pricebook.
        if(mapSettings != null && mapSettings.containsKey('SET019') && mapSettings.get('SET019') != NULL){
            strLaborPriceBookToBeConsidered = mapSettings.get('SET019');
        }
        
        // Get the setting parts pricebook information for Estimates
        if(mapSettings.containsKey('SET006') && mapSettings.get('SET006') != NULL)
        {
            lstPartsPricebookName.add(mapSettings.get('SET006'));
            mapRecordTypePricebookName.put('PARTS_ESTIMATES_' + mapSettings.get('SET006'), mapRecType_Map.get('SVMXC__Service_Order_Line__c~Estimate'));
        }
        // Get the setting labor pricebook information for Estimates
        if(mapSettings.containsKey('SET018') && mapSettings.get('SET018') != NULL)
        {
            lstLaborPricebookName.add(mapSettings.get('SET018'));
            mapRecordTypePricebookName.put('LABOR_ESTIMATES_' + mapSettings.get('SET018'), mapRecType_Map.get('SVMXC__Service_Order_Line__c~Estimate'));
        }
        // Get the setting parts pricebook information for Usage
        if(mapSettings.containsKey('SET004') && mapSettings.get('SET004') != NULL)
        {
            lstPartsPricebookName.add(mapSettings.get('SET004'));
            mapRecordTypePricebookName.put('PARTS_USAGE_' + mapSettings.get('SET004'), mapRecType_Map.get('SVMXC__Service_Order_Line__c~Usage/Consumption'));
        }
        // Get the setting labor pricebook information for Usage
        if(mapSettings.containsKey('SET017') && mapSettings.get('SET017') != NULL)
        {
            lstLaborPricebookName.add(mapSettings.get('SET017'));
            mapRecordTypePricebookName.put('LABOR_USAGE_' + mapSettings.get('SET017'), mapRecType_Map.get('SVMXC__Service_Order_Line__c~Usage/Consumption'));
        }

        //Entitlement Check to be performed for get price
        if(mapSettings.containsKey('SET020') && mapSettings.get('SET020') != NULL){
            entitlementCheckRequired = boolean.valueof(mapSettings.get('SET020'));
        }

        system.debug('TEST LOG: ' + mapRecordTypePricebookName);
        
        // Parse the request to get work order id, currency code, parts, labor, labor parts
        for(SVMXC.INTF_WebServicesDef.SVMXMap currentValMap : request.valueMap)
        {
            if(currentValMap.key == 'WORKORDER')
                workOrderId = currentValMap.value;
            else if(currentValMap.key == 'WORKORDERCURRENCYISO')
                strCurrencyIsoCode = currentValMap.value;
            else if(currentValMap.key == 'PARTS')
                lstProducts = currentValMap.values;
            else if(currentValMap.key == 'LABOR')
                lstLabor = currentValMap.values;
            else if(currentValMap.key == 'LABORPARTS' && currentValMap.values != NULL){
                lstLaborParts = currentValMap.values;
                system.debug(LoggingLevel.WARN, 'Setting WORD005_SET019 value: ' + strLaborPriceBookToBeConsidered);
                if(strLaborPriceBookToBeConsidered.toUpperCase() == 'PRODUCT PRICE BOOK'){
                    if(lstProducts != null && lstProducts.size() > 0)
                       lstProducts.addAll(currentValMap.values);
                   else
                       lstProducts  = currentValMap.values;
                }
            }
        }
        
        //------------Start----------Added for the defect BAC-3352
        Boolean isMultiCurrency = UserInfo.isMultiCurrencyOrganization();
        SVMXC__Service_Order__c lstWorkOrder;
        if(isMultiCurrency){
            String strQuery = 'Select CurrencyIsoCode, SVMXC__Product__c,SVMXC__Warranty__c, SVMXC__Service_Contract__c from SVMXC__Service_Order__c where Id = : workOrderId';
            lstWorkOrder = Database.query(strQuery);
            //Condition strCurrencyIsoCode == 'null' is added as part of defect BAC-3375 fix 
            if((strCurrencyIsoCode == null || strCurrencyIsoCode == 'null' || strCurrencyIsoCode == '' || strCurrencyIsoCode == 'undefined') && lstWorkOrder != null && lstWorkOrder.get('CurrencyIsoCode') != null){
                strCurrencyIsoCode = (String)lstWorkOrder.get('CurrencyIsoCode');
            }
        }
        else{
            lstWorkOrder = [Select SVMXC__Product__c,SVMXC__Warranty__c, SVMXC__Service_Contract__c from SVMXC__Service_Order__c where Id = : workOrderId];
        }
        //------------End----------Added for the defect BAC-3352

        //Commented for the defect BAC-3352
        //SVMXC__Service_Order__c lstWorkOrder = [Select SVMXC__Product__c,SVMXC__Warranty__c, SVMXC__Service_Contract__c from SVMXC__Service_Order__c where Id = : workOrderId];

        //For labor we need to consider work order product if work detail does not have product
        if(lstLabor != NULL && lstLabor.size() > 0)
        {
            if(lstWorkOrder.SVMXC__Product__c != NULL){
                lstLaborParts.add(lstWorkOrder.SVMXC__Product__c);
            }
        }
        
        if(UserInfo.isMultiCurrencyOrganization() && (strCurrencyIsoCode == NULL || strCurrencyIsoCode == ''))
            throw new SVMXException('Your org is multicurrency enabled, please provide currency ISO code in request');
            
        //Pass recordtype information
        list<INTF_WebServicesDef.SVMXMap> lstRecordTypeInfo = new list<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap wrpRecordTypes = new INTF_WebServicesDef.SVMXMap('RECORDTYPEDEFINITION', NULL);
        lstRecordTypeInfo.add(new INTF_WebServicesDef.SVMXMap('Estimate', mapRecType_Map.get('SVMXC__Service_Order_Line__c~Estimate')));
        lstRecordTypeInfo.add(new INTF_WebServicesDef.SVMXMap('Usage/Consumption', mapRecType_Map.get('SVMXC__Service_Order_Line__c~Usage/Consumption')));
        wrpRecordTypes.valueMap = lstRecordTypeInfo;
        lstPricingDetails.add(wrpRecordTypes);
        
        Map<Id,SVMXC__Service_Order_Line__c> productServicedLinesMap = new Map<Id,SVMXC__Service_Order_Line__c>([SELECT Id,SVMXC__Service_Maintenance_Contract__c,SVMXC__Product_Warranty__c,
                                                         SVMXC__Service_Maintenance_Contract__r.SVMXC__Default_Parts_Price_Book__c,SVMXC__Service_Maintenance_Contract__r.SVMXC__Service_Pricebook__c,
                                                         (SELECT Id,SVMXC__Product__c,SVMXC__Work_Detail__c from SVMXC__Work_Details__r) 
                                                         FROM SVMXC__Service_Order_Line__c WHERE RecordType.Name = 'Products Serviced' 
                                                         AND SVMXC__Service_Order__c =: workOrderId]);

       

    // Get the Entitlement history and identify the coverage and service offerings
        list<SVMXC__Entitlement_History__c> lstEntitlementHistory = new list<SVMXC__Entitlement_History__c>();
        String queryString = 'SELECT Id, SVMXC__Entitled_By_Service__c, SVMXC__Entitled_Within_Threshold__c, SVMXC__Service_Order__c,SVMXC__Work_Detail__c, SVMXC__Start_Date__c,' + 
                             + 'SVMXC__End_Date__c, SVMXC__Warranty__c, SVMXC__Service_Contract__c,SVMXC__Service_Contract__r.SVMXC__Service_Pricebook__c, SVMXC__Service_Contract__r.SVMXC__Default_Parts_Price_Book__c ' +
                             + 'from SVMXC__Entitlement_History__c where SVMXC__Inactive_Date__c = NULL AND ( SVMXC__Service_Order__c =: workOrderId ' ;
        if(!productServicedLinesMap.isEmpty()){
            Set<Id> lineIds = productServicedLinesMap.keySet();
            queryString += 'OR SVMXC__Work_Detail__c IN : lineIds';
        }                     

        queryString += ' ) ORDER BY CreatedDate' ;
        lstEntitlementHistory = Database.query(queryString); 
        Map<Id,SVMXC__Entitlement_History__c> historyRecordMap = new Map<Id,SVMXC__Entitlement_History__c>();
        for(SVMXC__Entitlement_History__c history: lstEntitlementHistory){
            if(history.SVMXC__Service_Order__c != null && !historyRecordMap.containsKey(history.SVMXC__Service_Order__c)){
               historyRecordMap.put(history.SVMXC__Service_Order__c,history);              
            }else if(history.SVMXC__Work_Detail__c != null && !historyRecordMap.containsKey(history.SVMXC__Work_Detail__c)){
               historyRecordMap.put(history.SVMXC__Work_Detail__c,history);    
            }
        }
        

        if(workOrderId != null && historyRecordMap.containsKey(workOrderId)){
            SVMXC__Entitlement_History__c qualifiedHistoryRec = historyRecordMap.get(workOrderId);
            //More info #006751
            //if(System.Today() >= history.SVMXC__Start_Date__c && System.Today() <= history.SVMXC__End_Date__c)
            if(qualifiedHistoryRec.SVMXC__Entitled_By_Service__c != NULL)
            {
                idServiceOffering = qualifiedHistoryRec.SVMXC__Entitled_By_Service__c;
                if(qualifiedHistoryRec.SVMXC__Entitled_Within_Threshold__c == true)
                    strServiceOfferingCoverage = 'COVERED';
            }
            
            // If work order is covered by Warranty
            if(qualifiedHistoryRec.SVMXC__Warranty__c != NULL)
            {
                // Get the Warranty Id
                strCoveredBy = 'WARRANTY';
                idCoveredWarranty = qualifiedHistoryRec.SVMXC__Warranty__c;
            }
            // If work order is covered by Service Contract
            else if(qualifiedHistoryRec.SVMXC__Service_Contract__c != NULL)
            {
                // Get the Service Contract Id
                strCoveredBy = 'SERVICECONTRACT';
                idCoveredServiceContract = qualifiedHistoryRec.SVMXC__Service_Contract__c;
            }
        }else if(lstWorkOrder != null && !entitlementCheckRequired){
            if(lstWorkOrder.SVMXC__Warranty__c != null){
                strCoveredBy = 'WARRANTY';
                idCoveredWarranty = lstWorkOrder.SVMXC__Warranty__c;
            }else if(lstWorkOrder.SVMXC__Service_Contract__c != null){
                strCoveredBy = 'SERVICECONTRACT';
                idCoveredServiceContract = lstWorkOrder.SVMXC__Service_Contract__c;
            }
        }    


        /*
        //When there is no entitlement history get the service contract/warranty from work order
        if(lstEntitlementHistory.size() == 0){
            SVMXC__Service_Order__c objWO = [Select SVMXC__Service_Contract__c, SVMXC__Warranty__c from SVMXC__Service_Order__c where Id = :workOrderId];
            if(objWO.SVMXC__Warranty__c != NULL){
                strCoveredBy = 'WARRANTY';
                idCoveredWarranty = objWO.SVMXC__Warranty__c;
            }
            else if(objWO.SVMXC__Service_Contract__c != NULL){
                strCoveredBy = 'SERVICECONTRACT';
                idCoveredServiceContract = objWO.SVMXC__Service_Contract__c;
            }
        }*/

        // Build key value for record type -> pricebook defined in setting
        list<PricebookEntry> lstPartsPricebookEntry = new list<PricebookEntry>();
        list<SVMXC__Service_Pricebook_Entry__c> lstLaborPricebookEntry = new list<SVMXC__Service_Pricebook_Entry__c>();
        system.debug('List of Parts Price Book Name: ' + lstPartsPricebookName);
        if(lstProducts != NULL && lstProducts.size() > 0 && lstPartsPricebookName != NULL && lstPartsPricebookName.size() > 0)
        {
            list<Pricebook2> lstPriceBook = SVMXC_GetPartsPricebook(lstPartsPricebookId, lstPartsPricebookName);
            for(Pricebook2 priceBook: lstPriceBook)
            {
                for(String key: mapRecordTypePricebookName.keySet())
                {
                    if(mapRecordTypePricebookName.get(key) != NULL && key == 'PARTS_ESTIMATES_' + priceBook.Name)
                        lstRecordTypeInfoParts.add(new INTF_WebServicesDef.SVMXMap(mapRecordTypePricebookName.get('PARTS_ESTIMATES_' + priceBook.Name), priceBook.Id));
                    if(mapRecordTypePricebookName.get(key) != NULL && key == 'PARTS_USAGE_' + priceBook.Name)
                        lstRecordTypeInfoParts.add(new INTF_WebServicesDef.SVMXMap(mapRecordTypePricebookName.get('PARTS_USAGE_' + priceBook.Name), priceBook.Id));
                }
            }
        }
        
        map<Id, SVMXC__Activity_Master__c> mapLabor = new map<Id, SVMXC__Activity_Master__c> ();
        system.debug('List of Labor Price Book Name: ' + lstLaborPricebookName);
        if(lstLabor != NULL && lstLabor.size() > 0 && lstLaborPricebookName != NULL && lstLaborPricebookName.size() > 0)
        {
            list<SVMXC__Service_Pricebook__c> lstPriceBook = SVMXC_GetLaborPricebook(lstLaborPricebookId, lstLaborPricebookName);
            for(SVMXC__Service_Pricebook__c priceBook: lstPriceBook)
            {
                for(String key: mapRecordTypePricebookName.keySet())
                {
                    if(mapRecordTypePricebookName.get(key) != NULL && key == 'LABOR_ESTIMATES_' + priceBook.Name)
                        lstRecordTypeInfoLabor.add(new INTF_WebServicesDef.SVMXMap(mapRecordTypePricebookName.get('LABOR_ESTIMATES_' + priceBook.Name), priceBook.Id));
                    if(mapRecordTypePricebookName.get(key) != NULL && key == 'LABOR_USAGE_' + priceBook.Name)
                        lstRecordTypeInfoLabor.add(new INTF_WebServicesDef.SVMXMap(mapRecordTypePricebookName.get('LABOR_USAGE_' + priceBook.Name), priceBook.Id));
                }
            }
        }
        
        recordTypeInfoParts.valueMap = lstRecordTypeInfoParts;
        recordTypeInfoLabor.valueMap = lstRecordTypeInfoLabor;
        lstPricingDetails.add(recordTypeInfoParts);
        lstPricingDetails.add(recordTypeInfoLabor);
        system.debug('Is Work Order Covered by Warranty:' + idCoveredWarranty);
        system.debug('Is Work Order Covered by Contract:' + idCoveredServiceContract);
        // If work order covered by Warranty
        if(idCoveredWarranty != NULL)
        {
            list<SVMXC__Warranty__c> objWarrantyTemplate = [Select Id, SVMXC__Travel_Covered__c, SVMXC__Time_Covered__c, SVMXC__Material_Covered__c, SVMXC__Expenses_Covered__c from SVMXC__Warranty__c where Id = :idCoveredWarranty];
            INTF_WebServicesDef.SVMXMap wrpWarranty = new INTF_WebServicesDef.SVMXMap('WARRANTYDEFINITION', NULL);
            wrpWarranty.data = objWarrantyTemplate;
            lstPricingDetails.add(wrpWarranty);
        }
        // If work order is covered by Service Contract get the following pricing information
        else if(idCoveredServiceContract != NULL)
        {
            list<SVMXC__Service_Contract__c> lstServiceContract = [Select SVMXC__Default_Travel_Price__c, SVMXC__Default_Travel_Unit__c, SVMXC__Zone__c, SVMXC__Service_Pricebook__c, SVMXC__Default_Parts_Price_Book__c, SVMXC__Minimum_Labor__c, SVMXC__Minimum_Travel__c, SVMXC__Labor_Rounding_Type__c, SVMXC__Travel_Rounding_Type__c, SVMXC__Round_Labor_To_Nearest__c, SVMXC__Round_Travel_To_Nearest__c From SVMXC__Service_Contract__c where Id = :idCoveredServiceContract];
            
            if(lstServiceContract != NULL && lstServiceContract.size() == 1)
            {
                // Get Service Contract pricebook definition for parts
                SVMXC__Service_Contract__c objServiceContract = lstServiceContract[0];
                list<String> lstSCONPartsPricebookId = new list<String>();
                list<String> lstSCONLaborPricebookId = new list<String>();
                if(objServiceContract.SVMXC__Default_Parts_Price_Book__c != NULL && objServiceContract.SVMXC__Default_Parts_Price_Book__c != '')
                {
                    lstSCONPartsPricebookId.add(objServiceContract.SVMXC__Default_Parts_Price_Book__c);
                    lstPartsPricebookId.add(objServiceContract.SVMXC__Default_Parts_Price_Book__c);
                    list<Pricebook2> lstPriceBook = SVMXC_GetPartsPricebook(lstSCONPartsPricebookId, lstPartsPricebookId);
                    INTF_WebServicesDef.SVMXMap recordTypeInfoContractParts = new INTF_WebServicesDef.SVMXMap('RECORDTYPEINFO_PARTS_CONTRACT', NULL);
                    list<INTF_WebServicesDef.SVMXMap> lstRecordTypeInfoContractParts = new list<INTF_WebServicesDef.SVMXMap>();
                    for(Pricebook2 priceBook: lstPriceBook)
                    {
                        lstRecordTypeInfoContractParts.add(new INTF_WebServicesDef.SVMXMap(mapRecType_Map.get('SVMXC__Service_Order_Line__c~Estimate'), priceBook.Id));
                        lstRecordTypeInfoContractParts.add(new INTF_WebServicesDef.SVMXMap(mapRecType_Map.get('SVMXC__Service_Order_Line__c~Usage/Consumption'), priceBook.Id));
                    }
                    recordTypeInfoContractParts.valueMap = lstRecordTypeInfoContractParts;
                    lstPricingDetails.add(recordTypeInfoContractParts);
                }
                // Get Service Contract pricebook definition for labor
                if(objServiceContract.SVMXC__Service_Pricebook__c != NULL)
                {
                    lstSCONLaborPricebookId.add(objServiceContract.SVMXC__Service_Pricebook__c);
                    lstLaborPricebookId.add(objServiceContract.SVMXC__Service_Pricebook__c);
                    list<SVMXC__Service_Pricebook__c> lstPriceBook = SVMXC_GetLaborPricebook(lstSCONLaborPricebookId, lstLaborPricebookId);
                    INTF_WebServicesDef.SVMXMap recordTypeInfoContractLabor = new INTF_WebServicesDef.SVMXMap('RECORDTYPEINFO_LABOR_CONTRACT', NULL);
                    list<INTF_WebServicesDef.SVMXMap> lstRecordTypeInfoContractLabor = new list<INTF_WebServicesDef.SVMXMap>();
                    for(SVMXC__Service_Pricebook__c priceBook: lstPriceBook)
                    {
                        lstRecordTypeInfoContractLabor.add(new INTF_WebServicesDef.SVMXMap(mapRecType_Map.get('SVMXC__Service_Order_Line__c~Estimate'), priceBook.Id));
                        lstRecordTypeInfoContractLabor.add(new INTF_WebServicesDef.SVMXMap(mapRecType_Map.get('SVMXC__Service_Order_Line__c~Usage/Consumption'), priceBook.Id));
                    }
                    system.debug('List of Price Book:' + lstPriceBook);
                    recordTypeInfoContractLabor.valueMap = lstRecordTypeInfoContractLabor;
                    lstPricingDetails.add(recordTypeInfoContractLabor);
                }
                
                list<SVMXC__Pricing_Rule__c> lstPricingRules = new list<SVMXC__Pricing_Rule__c>();
                list<SVMXC__Parts_Pricing__c> lstPartsPricing = new list<SVMXC__Parts_Pricing__c>();
                list<SVMXC__Parts_Discount__c> lstPartsDiscountPricing = new list<SVMXC__Parts_Discount__c>();
                list<SVMXC__Labor_Pricing__c> lstLaborPricing = new list<SVMXC__Labor_Pricing__c>();
                list<SVMXC__Expense_Pricing__c> lstExpensePricing = new list<SVMXC__Expense_Pricing__c>();
                list<SVMXC__Travel_Policy__c> lstTravelPricing = new list<SVMXC__Travel_Policy__c>();
                list<SVMXC__Mileage_Tiers__c> lstMileageTiers = new list<SVMXC__Mileage_Tiers__c>();
                list<SVMXC__Zone_Pricing__c> lstZonePricing = new list<SVMXC__Zone_Pricing__c>();
                list<SVMXC__Service_Contract_Services__c> lstIncludedServices = new list<SVMXC__Service_Contract_Services__c>();
                list<SVMXC__Custom_Coverage__c> lstCustomCoverages = new list<SVMXC__Custom_Coverage__c>();

                // If org is multicurrency enabled, get following pricing information only for the work order currency code, else get all pricing information for the contract
                if(UserInfo.isMultiCurrencyOrganization())
                {
                    // Get pricing rules for Contract
                    lstPricingRules = database.query('Select SVMXC__Named_Expression__c,SVMXC__Rate_Type__c, SVMXC__Rate__c From SVMXC__Pricing_Rule__c where SVMXC__Service_Contract__c = :idCoveredServiceContract AND CurrencyIsoCode = :strCurrencyIsoCode');
                    // Get special parts pricing for Contract
                    lstPartsPricing = database.query('Select SVMXC__Product__c, SVMXC__Price_Per_Unit__c From SVMXC__Parts_Pricing__c where SVMXC__Service_Contract__c = :idCoveredServiceContract and SVMXC__Active__c = true AND CurrencyIsoCode = :strCurrencyIsoCode');
                    // Get special parts discount for Contract
                    lstPartsDiscountPricing = database.query('Select SVMXC__Discount_Percentage__c, SVMXC__Product__c, SVMXC__Product_Family__c, SVMXC__Product_Line__c From SVMXC__Parts_Discount__c where SVMXC__Active__c = true and SVMXC__Service_Contract__c = :idCoveredServiceContract AND CurrencyIsoCode = :strCurrencyIsoCode');
                    // Get special labor pricing for Contract
                    lstLaborPricing = database.query('Select SVMXC__Activity_Type__c, SVMXC__Product__c,SVMXC__Product_Family__c,SVMXC__Product_Line__c,SVMXC__Unit__c, SVMXC__Regular_Rate__c, SVMXC__Activity__c,SVMXC__Activity_Product__c, SVMXC__Minimum_Labor__c From SVMXC__Labor_Pricing__c where SVMXC__Service_Contract__c = :idCoveredServiceContract AND CurrencyIsoCode = :strCurrencyIsoCode');
                    // Get expense pricing for Contract
                    lstExpensePricing = database.query('Select SVMXC__Rate__c, SVMXC__Rate_Type__c, SVMXC__Expense_Type__c From SVMXC__Expense_Pricing__c where SVMXC__Service_Contract__c = :idCoveredServiceContract AND CurrencyIsoCode = :strCurrencyIsoCode');
                    // Get travel policy for Contract
                    lstTravelPricing = database.query('Select SVMXC__Named_Expression__c,SVMXC__Unit__c, SVMXC__Service__c, SVMXC__Rate__c From SVMXC__Travel_Policy__c where SVMXC__Service_Contract__c = :idCoveredServiceContract AND CurrencyIsoCode = :strCurrencyIsoCode');
                    // Get mileage tiers for Contract
                    lstMileageTiers = database.query('Select SVMXC__Unit__c, SVMXC__Rate__c, SVMXC__Minimum__c, SVMXC__Maximum__c From SVMXC__Mileage_Tiers__c where SVMXC__Service_Contract__c = :idCoveredServiceContract AND CurrencyIsoCode = :strCurrencyIsoCode');
                    // Get zone pricing for Contract
                    lstZonePricing = database.query('Select SVMXC__Zone__c, SVMXC__Rate__c, OwnerId From SVMXC__Zone_Pricing__c where SVMXC__Service_Contract__c = :idCoveredServiceContract AND CurrencyIsoCode = :strCurrencyIsoCode');
                    // Get included services for Contract
                    lstIncludedServices = database.query('Select SVMXC__Travel_Discount_Not_Covered__c, SVMXC__Travel_Discount_Covered__c, SVMXC__Parts_Discount_Not_Covered__c, SVMXC__Parts_Discount_Covered__c, SVMXC__Labor_Discount_Not_Covered__c, SVMXC__Labor_Discount_Covered__c, SVMXC__Expense_Discount_Not_Covered__c, SVMXC__Expense_Discount_Covered__c From SVMXC__Service_Contract_Services__c where Id = :idServiceOffering AND CurrencyIsoCode = :strCurrencyIsoCode');
                    // Get Custom Coverages for Contract
                    lstCustomCoverages = database.query('Select SVMXC__Product_Type__c,SVMXC__Included_Service__c,SVMXC__Parts_Discount_Covered__c,SVMXC__Parts_Discount_Not_Covered__c from SVMXC__Custom_Coverage__c where SVMXC__Included_Service__c = : idServiceOffering AND CurrencyIsoCode = :strCurrencyIsoCode');
                }
                else
                {
                    lstPricingRules = [Select SVMXC__Named_Expression__c,SVMXC__Rate_Type__c, SVMXC__Rate__c From SVMXC__Pricing_Rule__c where SVMXC__Service_Contract__c = :idCoveredServiceContract];
                    lstPartsPricing = [Select SVMXC__Product__c, SVMXC__Price_Per_Unit__c From SVMXC__Parts_Pricing__c where SVMXC__Service_Contract__c = :idCoveredServiceContract and SVMXC__Active__c = true];
                    lstPartsDiscountPricing = [Select SVMXC__Discount_Percentage__c, SVMXC__Product__c, SVMXC__Product_Family__c, SVMXC__Product_Line__c From SVMXC__Parts_Discount__c where SVMXC__Active__c = true and SVMXC__Service_Contract__c = :idCoveredServiceContract];
                    lstLaborPricing = [Select SVMXC__Activity_Type__c, SVMXC__Product__c,SVMXC__Product_Family__c,SVMXC__Product_Line__c,SVMXC__Unit__c, SVMXC__Regular_Rate__c, SVMXC__Activity__c,SVMXC__Activity_Product__c, SVMXC__Minimum_Labor__c From SVMXC__Labor_Pricing__c where SVMXC__Service_Contract__c = :idCoveredServiceContract];
                    lstExpensePricing = [Select SVMXC__Rate__c, SVMXC__Rate_Type__c, SVMXC__Expense_Type__c From SVMXC__Expense_Pricing__c where SVMXC__Service_Contract__c = :idCoveredServiceContract];
                    lstTravelPricing = [Select SVMXC__Named_Expression__c,SVMXC__Unit__c, SVMXC__Service__c, SVMXC__Rate__c From SVMXC__Travel_Policy__c where SVMXC__Service_Contract__c = :idCoveredServiceContract];
                    lstMileageTiers = [Select SVMXC__Unit__c, SVMXC__Rate__c, SVMXC__Minimum__c, SVMXC__Maximum__c From SVMXC__Mileage_Tiers__c where SVMXC__Service_Contract__c = :idCoveredServiceContract];
                    lstZonePricing = [Select SVMXC__Zone__c, SVMXC__Rate__c From SVMXC__Zone_Pricing__c where SVMXC__Service_Contract__c = :idCoveredServiceContract];
                    lstIncludedServices = [Select SVMXC__Travel_Discount_Not_Covered__c, SVMXC__Travel_Discount_Covered__c, SVMXC__Parts_Discount_Not_Covered__c, SVMXC__Parts_Discount_Covered__c, SVMXC__Labor_Discount_Not_Covered__c, SVMXC__Labor_Discount_Covered__c, SVMXC__Expense_Discount_Not_Covered__c, SVMXC__Expense_Discount_Covered__c From SVMXC__Service_Contract_Services__c where Id = :idServiceOffering];
                    lstCustomCoverages = [Select SVMXC__Product_Type__c,SVMXC__Included_Service__c,SVMXC__Parts_Discount_Covered__c,SVMXC__Parts_Discount_Not_Covered__c from SVMXC__Custom_Coverage__c where SVMXC__Included_Service__c = : idServiceOffering];
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
                
                if(lstPartsPricing != NULL && lstPartsPricing.size() >0)
                {
                    INTF_WebServicesDef.SVMXMap wrpPartsPricing = new INTF_WebServicesDef.SVMXMap('CONTRACT_SPECIALPARTSPRICING', NULL);
                    wrpPartsPricing.data = lstPartsPricing;
                    lstPricingDetails.add(wrpPartsPricing);
                }
                
                if(lstPartsDiscountPricing != NULL && lstPartsDiscountPricing.size() >0)
                {
                    INTF_WebServicesDef.SVMXMap wrpPartsDiscountPricing = new INTF_WebServicesDef.SVMXMap('CONTRACT_PARTSDISCOUNT', NULL);
                    wrpPartsDiscountPricing.data = lstPartsDiscountPricing;
                    lstPricingDetails.add(wrpPartsDiscountPricing);
                }
                
                if(lstLaborPricing != NULL && lstLaborPricing.size() >0)
                {
                    INTF_WebServicesDef.SVMXMap wrpLaborPricing = new INTF_WebServicesDef.SVMXMap('CONTRACT_SPECIALLABORPRICING', NULL);
                    wrpLaborPricing.data = lstLaborPricing;
                    lstPricingDetails.add(wrpLaborPricing);
                }
                
                if(lstExpensePricing != NULL && lstExpensePricing.size() >0)
                {
                    INTF_WebServicesDef.SVMXMap wrpExpensePricing = new INTF_WebServicesDef.SVMXMap('CONTRACT_EXPENSE', NULL);
                    wrpExpensePricing.data = lstExpensePricing;
                    lstPricingDetails.add(wrpExpensePricing);
                }
                
                if(lstTravelPricing != NULL && lstTravelPricing.size() >0)
                {
                    INTF_WebServicesDef.SVMXMap wrpTravelPolicy = new INTF_WebServicesDef.SVMXMap('CONTRACT_TRAVELPOLICY', NULL);
                    wrpTravelPolicy.data = lstTravelPricing;
                    lstPricingDetails.add(wrpTravelPolicy);
                }
                    
                if(lstMileageTiers != NULL && lstMileageTiers.size() >0)
                {
                    INTF_WebServicesDef.SVMXMap wrpMileageTiers = new INTF_WebServicesDef.SVMXMap('CONTRACT_MILEAGETIERS', NULL);
                    wrpMileageTiers.data = lstMileageTiers;
                    lstPricingDetails.add(wrpMileageTiers);
                }
                
                if(lstZonePricing != NULL && lstZonePricing.size() >0)
                {
                    INTF_WebServicesDef.SVMXMap wrpZonePricing = new INTF_WebServicesDef.SVMXMap('CONTRACT_ZONEPRICING', NULL);
                    wrpZonePricing.data = lstZonePricing;
                    lstPricingDetails.add(wrpZonePricing);
                }
                            
                if(lstIncludedServices != NULL && lstIncludedServices.size() >0)
                {
                    INTF_WebServicesDef.SVMXMap wrpIncludedServises = new INTF_WebServicesDef.SVMXMap('CONTRACT_SERVICEOFFERING', strServiceOfferingCoverage);
                    wrpIncludedServises.data = lstIncludedServices;
                    lstPricingDetails.add(wrpIncludedServises);
                }

                if(lstCustomCoverages != NULL && lstCustomCoverages.size() > 0){
                    INTF_WebServicesDef.SVMXMap wrpIncludedServises = new INTF_WebServicesDef.SVMXMap('CONTRACT_CUSTOMCOVERAGE', strServiceOfferingCoverage);
                    wrpIncludedServises.data = lstCustomCoverages;
                    lstPricingDetails.add(wrpIncludedServises);
                }  
                
                List<INTF_WebServicesDef.SVMXMap> lstServiceExpressions = null;
                lstServiceExpressions = SVMXC_GetServiceExpressions(lstTravelPricing,lstPricingRules);
                if(lstServiceExpressions != null && lstServiceExpressions.size() > 0)
                {
                    INTF_WebServicesDef.SVMXMap wrpTravelPolicyExpressions = new INTF_WebServicesDef.SVMXMap('RULES', NULL);
                    wrpTravelPolicyExpressions.valueMap = lstServiceExpressions;
                    lstPricingDetails.add(wrpTravelPolicyExpressions);
                }
            }
        }
        
                
        // Getting product definition
        list<String> lstRequestedProduct = new list<String>();
        if(lstProducts != NULL)
            lstRequestedProduct.addAll(lstProducts);
        if(lstLaborParts != NULL)
            lstRequestedProduct.addAll(lstLaborParts);
        
        // Get all product family and product line information for requested products
        list<Product2> lstObjProducts = [Select Id, SVMXC__Product_Line__c, Family,SVMXC__Product_Type__c From Product2 where Id IN: lstRequestedProduct];
        if(lstObjProducts != NULL && lstObjProducts.size() >0)
        {
            INTF_WebServicesDef.SVMXMap wrpProductDefinition = new INTF_WebServicesDef.SVMXMap('PRODUCT_DEFINITION', NULL);
            wrpProductDefinition.data = lstObjProducts;
            lstPricingDetails.add(wrpProductDefinition);
        }
                
        //Get complete work order details
        List<INTF_WebServicesDef.SVMXMap> lstWorkOrderDetails = getLookupDefinition(workOrderId);
        if(lstWorkOrderDetails != null && lstWorkOrderDetails.size() > 0)
            lstPricingDetails.addAll(lstWorkOrderDetails);
        
        if(!productServicedLinesMap.isEmpty()){    
            List<INTF_WebServicesDef.SVMXMap> lstIBWarrantyDetails = getIBWarranty(productServicedLinesMap,historyRecordMap);
            if(lstIBWarrantyDetails != null && lstIBWarrantyDetails.size() > 0)
                lstPricingDetails.addAll(lstIBWarrantyDetails);
        }    
        
        if(!productServicedLinesMap.isEmpty()){   
            List<INTF_WebServicesDef.SVMXMap> lstIBSconDetails = getIBScons(productServicedLinesMap,historyRecordMap);
            if(lstIBSconDetails != null && lstIBSconDetails.size() > 0)
                lstPricingDetails.addAll(lstIBSconDetails);
        }    

            
        // Get the parts pricebook entry for the requested parts, pricebook(Contract special pricebook, Setting pricebook)
        if(lstProducts != NULL && lstProducts.size() > 0 && ((lstPartsPricebookId != NULL && lstPartsPricebookId.size() > 0) || (lstPartsPricebookName != NULL && lstPartsPricebookName.size() > 0)))
        {
            if(UserInfo.isMultiCurrencyOrganization())
                lstPartsPricebookEntry = database.query('SELECT Name,UnitPrice,UseStandardPrice,Product2Id,Pricebook2Id FROM PricebookEntry WHERE Pricebook2.IsActive = true AND (Pricebook2.Name IN:lstPartsPricebookName OR Pricebook2Id IN :lstPartsPricebookId) AND CurrencyIsoCode = :strCurrencyIsoCode AND Product2Id IN:lstProducts AND IsActive = true');
            else
                lstPartsPricebookEntry = [SELECT Name,UnitPrice,UseStandardPrice,Product2Id,Pricebook2Id FROM PricebookEntry WHERE Pricebook2.IsActive = true AND (Pricebook2.Name IN:lstPartsPricebookName OR Pricebook2Id IN :lstPartsPricebookId) AND Product2Id IN:lstProducts AND IsActive = true];
        }
        
        // Get the labor pricebook entry for the requested labor, pricebook(Contract special pricebook, Setting pricebook)
        if(lstLabor != NULL && lstLabor.size() > 0 && ((lstLaborPricebookId != NULL && lstLaborPricebookId.size() > 0) || (lstLaborPricebookName != NULL && lstLaborPricebookName.size() > 0)))
        {
            /* Commented to fix 043114
            if(UserInfo.isMultiCurrencyOrganization())//Currency handling needs to be implemented
                lstLaborPricebookEntry = database.query('SELECT Name, SVMXC__Unit__c, SVMXC__Regular_Rate__c, SVMXC__Price_Book__c, SVMXC__Activity_Type__c, SVMXC__Activity__c, SVMXC__Activity_Product__c, SVMXC__Product__c, SVMXC__Product_Family__c, SVMXC__Product_Line__c FROM SVMXC__Service_Pricebook_Entry__c WHERE SVMXC__Activity_Type__c IN : lstLabor AND (SVMXC__Activity_Product__c = null OR SVMXC__Activity_Product__r.SVMXC__Product__c IN : lstLaborParts ) AND SVMXC__Price_Book__r.SVMXC__Active__c = true AND (SVMXC__Price_Book__r.Name IN :lstLaborPricebookName OR SVMXC__Price_Book__c IN :lstLaborPricebookId) AND CurrencyIsoCode = :strCurrencyIsoCode');
            else
                lstLaborPricebookEntry = [SELECT Name, SVMXC__Unit__c, SVMXC__Regular_Rate__c, SVMXC__Price_Book__c, SVMXC__Activity_Type__c, SVMXC__Activity__c, SVMXC__Activity_Product__c, SVMXC__Product__c, SVMXC__Product_Family__c, SVMXC__Product_Line__c FROM SVMXC__Service_Pricebook_Entry__c WHERE SVMXC__Activity_Type__c IN :lstLabor AND (SVMXC__Activity_Product__c = null OR SVMXC__Activity_Product__r.SVMXC__Product__c IN : lstLaborParts ) AND SVMXC__Price_Book__r.SVMXC__Active__c = true AND (SVMXC__Price_Book__r.Name IN :lstLaborPricebookName OR SVMXC__Price_Book__c IN 
                :lstLaborPricebookId)];*/
                //Above queries are commented and below code is addded for fixing defect 043114 by splitting one query into three for acheiving indexing on the SOQL execution.
            //-------Start-----------//
            List<String> lstPBIds = new List<String>();
            List<String> lstAPIds = new List<String>();
            list<SVMXC__Service_Pricebook_Entry__c> lstLaborPricebookEntrytempforNull = new list<SVMXC__Service_Pricebook_Entry__c>();
            list<SVMXC__Service_Pricebook_Entry__c> lstLaborPricebookEntrytemp = new list<SVMXC__Service_Pricebook_Entry__c>();
            for(SVMXC__Service_Pricebook__c objSP : [SELECT Id From SVMXC__Service_Pricebook__c WHERE SVMXC__Active__c = true AND (Name IN: lstLaborPricebookName OR Id IN: lstLaborPricebookId)]){
                lstPBIds.add(objSP.Id);
            }

            for(SVMXC__Activity_Product__c objAP : [SELECT Id From SVMXC__Activity_Product__c WHERE SVMXC__Product__c IN: lstLaborParts]){
                lstAPIds.add(objAP.Id);
            }
            if(UserInfo.isMultiCurrencyOrganization()){
                lstLaborPricebookEntrytempforNull = database.query('SELECT Name, SVMXC__Unit__c, SVMXC__Regular_Rate__c, SVMXC__Price_Book__c, SVMXC__Activity_Type__c, SVMXC__Activity__c, SVMXC__Activity_Product__c, SVMXC__Product__c, SVMXC__Product_Family__c, SVMXC__Product_Line__c FROM SVMXC__Service_Pricebook_Entry__c WHERE SVMXC__Activity_Type__c IN: lstLabor AND SVMXC__Activity_Product__c = null AND SVMXC__Price_Book__c IN: lstPBIds AND CurrencyIsoCode = :strCurrencyIsoCode');
                lstLaborPricebookEntrytemp = database.query('SELECT Name, SVMXC__Unit__c, SVMXC__Regular_Rate__c, SVMXC__Price_Book__c, SVMXC__Activity_Type__c, SVMXC__Activity__c, SVMXC__Activity_Product__c, SVMXC__Product__c, SVMXC__Product_Family__c, SVMXC__Product_Line__c FROM SVMXC__Service_Pricebook_Entry__c WHERE SVMXC__Activity_Type__c IN: lstLabor AND SVMXC__Activity_Product__c IN: lstAPIds AND SVMXC__Price_Book__c IN: lstPBIds AND CurrencyIsoCode = :strCurrencyIsoCode');
                lstLaborPricebookEntry.addAll(lstLaborPricebookEntrytemp);
                lstLaborPricebookEntry.addAll(lstLaborPricebookEntrytempforNull);
            }
            else{
                lstLaborPricebookEntrytempforNull = [SELECT Name, SVMXC__Unit__c, SVMXC__Regular_Rate__c, SVMXC__Price_Book__c, SVMXC__Activity_Type__c, SVMXC__Activity__c, SVMXC__Activity_Product__c, SVMXC__Product__c, SVMXC__Product_Family__c, SVMXC__Product_Line__c FROM SVMXC__Service_Pricebook_Entry__c WHERE SVMXC__Activity_Type__c IN: lstLabor AND SVMXC__Activity_Product__c = null AND SVMXC__Price_Book__c IN: lstPBIds];
                lstLaborPricebookEntrytemp = [SELECT Name, SVMXC__Unit__c, SVMXC__Regular_Rate__c, SVMXC__Price_Book__c, SVMXC__Activity_Type__c, SVMXC__Activity__c, SVMXC__Activity_Product__c, SVMXC__Product__c, SVMXC__Product_Family__c, SVMXC__Product_Line__c FROM SVMXC__Service_Pricebook_Entry__c WHERE SVMXC__Activity_Type__c IN: lstLabor AND SVMXC__Activity_Product__c IN: lstAPIds AND SVMXC__Price_Book__c IN: lstPBIds];
                lstLaborPricebookEntry.addAll(lstLaborPricebookEntrytemp);
                lstLaborPricebookEntry.addAll(lstLaborPricebookEntrytempforNull);
            }
            //End code to fix the defect-043114
        }
        system.debug('List of Parts Price Book Entry :' + lstPartsPricebookEntry);
        system.debug('List of Labor Price Book Entry :' + lstLaborPricebookEntry);
        
        INTF_WebServicesDef.SVMXMap wrpParts = new INTF_WebServicesDef.SVMXMap('PARTSPRICING', NULL);
        wrpParts.data = lstPartsPricebookEntry;
        lstPricingDetails.add(wrpParts);
        INTF_WebServicesDef.SVMXMap wrpLabor = new INTF_WebServicesDef.SVMXMap('LABORPRICING', NULL);
        wrpLabor.data = lstLaborPricebookEntry;
        lstPricingDetails.add(wrpLabor);
        
        //Get required tags
        INTF_WebServicesDef.SVMXMap wrpTags = new INTF_WebServicesDef.SVMXMap('TAGS', NULL);
        list<INTF_WebServicesDef.SVMXMap> lstTags = new list<INTF_WebServicesDef.SVMXMap>();
        lstTags.add(new INTF_WebServicesDef.SVMXMap('EVER005_TAG087', system.label.EVER005_TAG087));
        wrpTags.valueMap = lstTags;
        lstPricingDetails.add(wrpTags);
        
        //Get PriceBook Setting for Labor
        INTF_WebServicesDef.SVMXMap wrpLaborPB = new INTF_WebServicesDef.SVMXMap('SETTINGS', NULL);
        wrpLaborPB.valueMap = new list<INTF_WebServicesDef.SVMXMap>();
        wrpLaborPB.valueMap.add(new INTF_WebServicesDef.SVMXMap('WORD005_SET019', strLaborPriceBookToBeConsidered));
        wrpLaborPB.valueMap.add(new INTF_WebServicesDef.SVMXMap('WORD005_SET020', String.valueof(entitlementCheckRequired)));

        lstPricingDetails.add(wrpLaborPB);
        
        response.message = JSON.serialize(lstPricingDetails);
        return response;
    }

    public list<Pricebook2> SVMXC_GetPartsPricebook(list<String> priceBookId, list<String> priceBookName)
    {
        if (priceBookName == null)
        {
            return null;
        } 
        try
        {
            list<Pricebook2> lstPricebook = [SELECT Id, Name FROM Pricebook2 WHERE (Id IN: priceBookId OR Name IN:PriceBookName) AND IsActive = true];
            return lstPricebook;
        } 
        catch(System.Exception ex )
        {
        }
        return null;
    }
    public list<SVMXC__Service_Pricebook__c> SVMXC_GetLaborPricebook(list<String> priceBookId, list<String> priceBookName)
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

    public list<INTF_WebServicesDef.SVMXMap> SVMXC_GetServiceExpressions(list<SVMXC__Travel_Policy__c> travelPolicy,list<SVMXC__Pricing_Rule__c> pricingRules)
    {
        //get all the Expression IDs
        List<String> lstExpressionIDs = new List<String>();
        Map<Id,SVMXC__ServiceMax_Processes__c> mapExpressionObjs = new Map<Id,SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__SERVICEMAX_CONFIG_DATA__C> lstExpressionDetailsObjs = new List<SVMXC__SERVICEMAX_CONFIG_DATA__C>();
        if(travelPolicy != null && travelPolicy.size() > 0)
        {
            for(SVMXC__Travel_Policy__c objCurrPloicy : travelPolicy)
            {
                if(objCurrPloicy.SVMXC__Named_Expression__c != null && objCurrPloicy.SVMXC__Named_Expression__c.length() > 0)
                {
                    lstExpressionIDs.add(objCurrPloicy.SVMXC__Named_Expression__c);
                }
            }
            
        }
        
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

    public List<INTF_WebServicesDef.SVMXMap> getLookupDefinition(String IdWorkOrder)
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
        Map<String, SObjectField> souObjfieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap(); // Get field definition map for work order
        DCON_Utils.referenceFields_WP reference_M = dcUtils.SVMX_getReferenceFields(souObjfieldMap,true);
        List<String> allFields_L = reference_M.allFields_L; //Get the all field list
        refFields_L = reference_M.referenceFields_L; //Get the reference field list
        dateTimeFields_L = reference_M.dateTimeFields_L; //Get the dateTime field list
        dateFields_L = reference_M.dateFields_L; //Get the date field list
        replacementRef = reference_M.replacementReference_M;  //Get the replacement reference field map
        replacementNameField = reference_M.replacementField_M;  //Get the name field for reference map
        
        //--------Start------------Added for fixing defect 043715
        COMM_Utils_V2 objCOMM_Utils_V2 = new COMM_Utils_V2();
        allFields_L = objCOMM_Utils_V2.checkDuplicateFields(allFields_L, 'SVMXC__Service_Order__c');
        //--------End--------------Added for fixing defect 043715
        
        querySelect = utils.SVMX_getFieldNamesFromList(allFields_L); //Convert the list of strings to coma seperated string
        String strWhereClause= 'Id = :IdWorkOrder';
        list<SVMXC__Service_Order__c> workorder_LO = Database.query('SELECT ' + querySelect +' FROM SVMXC__Service_Order__c WHERE '+string.escapeSingleQuotes(strWhereClause));
        
        List<INTF_WebServicesDef.SVMXMap> specialFields_LWP = new List<INTF_WebServicesDef.SVMXMap>();
        for(SVMXC__Service_Order__c objWorkOrder: workorder_LO)
        {
            for(String fieldApi : refFields_L)
            {
                if(objWorkOrder.get(fieldApi) != NULL)
                {
                    INTF_WebServicesDef.SVMXMap wrpLookupValue;
                    Sobject ref_TO = objWorkOrder.getSobject(replacementRef.get(fieldApi));
                    if(ref_TO != NULL)
                    {
                        wrpLookupValue = new INTF_WebServicesDef.SVMXMap(fieldApi, String.valueof(ref_TO.get(replacementNameField.get(fieldApi))) );
                        specialFields_LWP.add(wrpLookupValue);
                    }
                }
            }
        }
        System.debug('Special Fields: ' + specialFields_LWP);
        INTF_WebServicesDef.SVMXMap wrpLookupDefinition = new INTF_WebServicesDef.SVMXMap('LOOKUP_DEFINITION', NULL);
        wrpLookupDefinition.valueMap = specialFields_LWP;
        response.add(wrpLookupDefinition);
        
        INTF_WebServicesDef.SVMXMap wrpWorkOrderData = new INTF_WebServicesDef.SVMXMap('WORKORDER_DATA', NULL);
        wrpWorkOrderData.data = workorder_LO;
        response.add(wrpWorkOrderData);
                    
        return response;
    }

    public List<INTF_WebServicesDef.SVMXMap> getIBWarranty(Map<Id,SVMXC__Service_Order_Line__c> productServicedLinesMap,Map<Id,SVMXC__Entitlement_History__c> historyRecordMap)
    {
        List<INTF_WebServicesDef.SVMXMap> response = new List<INTF_WebServicesDef.SVMXMap>();

        if(productServicedLinesMap.values().isEmpty())
            return response;

        map<Id, Set<String>> mapWorkDetailsWarranty = new map<Id, Set<String>>();
        List<INTF_WebServicesDef.SVMXMap> warrantyDetails = new List<INTF_WebServicesDef.SVMXMap>();        
        List<INTF_WebServicesDef.SVMXMap> lineWarrantyEntitledCheck = new List<INTF_WebServicesDef.SVMXMap>(); 
        INTF_WebServicesDef.SVMXMap detailIdWarrantyMap; 

        for(SVMXC__Service_Order_Line__c objWO : productServicedLinesMap.values()){
            Id warrantyId;
            detailIdWarrantyMap = new INTF_WebServicesDef.SVMXMap ();
            if(historyRecordMap.containsKey(objWO.Id)){
               SVMXC__Entitlement_History__c historyRec = historyRecordMap.get(objWO.Id);
               warrantyId = historyRec.SVMXC__Warranty__c;
            }else if(!entitlementCheckRequired){
               warrantyId = objWO.SVMXC__Product_Warranty__c;   
            }
            if(warrantyId != NULL && !objWO.SVMXC__Work_Details__r.isEmpty()){
                Set<String> tempSet = new Set<String>();
                for(SVMXC__Service_Order_Line__c psDetailLineRec : objWO.SVMXC__Work_Details__r){
                    tempSet.add(psDetailLineRec.Id);
                }
                if(mapWorkDetailsWarranty.containsKey(warrantyId)){
                   tempSet.addAll(mapWorkDetailsWarranty.get(warrantyId)); 
                }   
                mapWorkDetailsWarranty.put(warrantyId, tempSet);
            }
            detailIdWarrantyMap.key = objWO.Id;
            detailIdWarrantyMap.value = 'false';
            if(warrantyId != null)
                detailIdWarrantyMap.value = 'true';
            lineWarrantyEntitledCheck.add(detailIdWarrantyMap);    
        }
        
        list<SVMXC__Warranty__c> lstWarranty = [Select Id, SVMXC__Travel_Covered__c, SVMXC__Time_Covered__c, SVMXC__Material_Covered__c, SVMXC__Expenses_Covered__c from SVMXC__Warranty__c where Id IN :mapWorkDetailsWarranty.keySet()];
        
        for(SVMXC__Warranty__c objWarranty: lstWarranty){
            if(mapWorkDetailsWarranty.containsKey(objWarranty.Id)){
                INTF_WebServicesDef.SVMXMap wrpWarrantyData = new INTF_WebServicesDef.SVMXMap();
                wrpWarrantyData.values = new List<String>(mapWorkDetailsWarranty.get(objWarranty.Id));
                wrpWarrantyData.record = objWarranty;
                warrantyDetails.add(wrpWarrantyData);
            }
            
        }

        INTF_WebServicesDef.SVMXMap wrpWarrantyData = new INTF_WebServicesDef.SVMXMap('IBWARRANTY', NULL);
        wrpWarrantyData.valueMap = warrantyDetails;
        response.add(wrpWarrantyData);


        wrpWarrantyData = new INTF_WebServicesDef.SVMXMap('LINEWARRANTYENTITLED', NULL);
        wrpWarrantyData.valueMap = lineWarrantyEntitledCheck;
        response.add(wrpWarrantyData);        
                    
        return response;
    }

    public List<INTF_WebServicesDef.SVMXMap> getIBScons(Map<Id,SVMXC__Service_Order_Line__c> productServicedLinesMap,Map<Id,SVMXC__Entitlement_History__c> historyRecordMap){
        List<INTF_WebServicesDef.SVMXMap> response = new List<INTF_WebServicesDef.SVMXMap>();
        if(productServicedLinesMap.values().isEmpty())
            return response;

        Map<Id,Set<String>> sConWorkDetailIdsMap = new Map<Id,Set<String>>();
       
        Set<String> partsPricebook = new Set<String>();
        Set<String> laborPricebook = new Set<String>();
        Map<String,Set<String>> partsPricebookMap = new Map<String,Set<String>>();
        Map<String,Set<String>> laborPricebookMap = new Map<String,Set<String>>();
        
        List<INTF_WebServicesDef.SVMXMap> lineSconEntitledCheck = new List<INTF_WebServicesDef.SVMXMap>(); 
        INTF_WebServicesDef.SVMXMap detailIdSconMap; 

        for(SVMXC__Service_Order_Line__c psLineRec : productServicedLinesMap.values()){
            Id sConId;
            detailIdSconMap = new INTF_WebServicesDef.SVMXMap ();
            String priceBookId;
            String laborPriceBookId;
            if(historyRecordMap.containsKey(psLineRec.Id)){
               SVMXC__Entitlement_History__c historyRec = historyRecordMap.get(psLineRec.Id);
               sConId = historyRec.SVMXC__Service_Contract__c;
               priceBookId = historyRec.SVMXC__Service_Contract__r.SVMXC__Default_Parts_Price_Book__c;
               laborPriceBookId = historyRec.SVMXC__Service_Contract__r.SVMXC__Service_Pricebook__c;
            }else if(!entitlementCheckRequired){
               sConId = psLineRec.SVMXC__Service_Maintenance_Contract__c;   
               priceBookId = psLineRec.SVMXC__Service_Maintenance_Contract__r.SVMXC__Default_Parts_Price_Book__c;
               laborPriceBookId = psLineRec.SVMXC__Service_Maintenance_Contract__r.SVMXC__Service_Pricebook__c;
            }
            System.debug('laborPriceBookId :' + laborPriceBookId);
            if(sConId != NULL && !psLineRec.SVMXC__Work_Details__r.isEmpty()){
                Set<String> tempSet = new Set<String>();
                for(SVMXC__Service_Order_Line__c detailLine : psLineRec.SVMXC__Work_Details__r){
                    tempSet.add(detailLine.Id);
                }         
                Set<String> detailSet = new Set<String>();
                if(sConWorkDetailIdsMap.containsKey(sConId)){
                   detailSet = sConWorkDetailIdsMap.get(sConId); 
                }   
                detailSet.addAll(tempSet);
                sConWorkDetailIdsMap.put(sConId, detailSet);  

                if(priceBookId != null){
                    detailSet = new Set<String>();
                    if(partsPricebookMap.containsKey(priceBookId)){
                        detailSet = partsPricebookMap.get(priceBookId);
                    }    
                    detailSet.addAll(tempSet);
                    partsPricebookMap.put(priceBookId,detailSet);          
                }
                
                if(laborPriceBookId != null){
                    detailSet = new Set<String>();
                    if(laborPricebookMap.containsKey(laborPriceBookId)){
                        detailSet = laborPricebookMap.get(laborPriceBookId);
                    }    
                    detailSet.addAll(tempSet);
                    laborPricebookMap.put(laborPriceBookId,detailSet); 
                }
            }

            detailIdSconMap.key = psLineRec.Id;
            detailIdSconMap.value = 'false';
            if(sConId != null)
                detailIdSconMap.value = 'true';
            lineSconEntitledCheck.add(detailIdSconMap);              
        }  

        Set<Id> sconIds = sConWorkDetailIdsMap.keySet();
        partsPricebook.addAll(partsPricebookMap.keySet());
        laborPricebook.addAll(laborPricebookMap.keySet());
        System.debug('laborPricebook :' + laborPricebook);
        
        List<SVMXC__Parts_Pricing__c> lstPartsPricing = new list<SVMXC__Parts_Pricing__c>();
        List<SVMXC__Parts_Discount__c> lstPartsDiscountPricing = new list<SVMXC__Parts_Discount__c>();
        List<SVMXC__Labor_Pricing__c> lstLaborPricing = new list<SVMXC__Labor_Pricing__c>();    
        List<SVMXC__Expense_Pricing__c> lstExpensePricing = new List<SVMXC__Expense_Pricing__c>();
        List<PricebookEntry> lstPartsPricebookEntry = new List<PricebookEntry>();
        List<SVMXC__Service_Contract__c> lstLineServiceContract = new List<SVMXC__Service_Contract__c>();
        List<SVMXC__Service_Pricebook_Entry__c> lstLaborPricebookEntry = new List<SVMXC__Service_Pricebook_Entry__c>();
        if(!sconIds.isEmpty()){
            // If org is multicurrency enabled, get following pricing information only for the work order currency code, else get all pricing information for the contract
            lstLineServiceContract = [Select SVMXC__Default_Travel_Price__c, SVMXC__Default_Travel_Unit__c, SVMXC__Zone__c, SVMXC__Service_Pricebook__c, SVMXC__Default_Parts_Price_Book__c, 
                                                                         SVMXC__Minimum_Labor__c, SVMXC__Minimum_Travel__c, SVMXC__Labor_Rounding_Type__c, 
                                                                         SVMXC__Travel_Rounding_Type__c, SVMXC__Round_Labor_To_Nearest__c, SVMXC__Round_Travel_To_Nearest__c 
                                                                         From SVMXC__Service_Contract__c where Id IN :sconIds];
            if(UserInfo.isMultiCurrencyOrganization())
            {
                lstPartsPricing = database.query('Select SVMXC__Product__c,SVMXC__Service_Contract__c, SVMXC__Price_Per_Unit__c From SVMXC__Parts_Pricing__c where SVMXC__Service_Contract__c IN :sconIds and SVMXC__Active__c = true AND CurrencyIsoCode = :strCurrencyIsoCode');
                // Get special parts discount for Contract
                lstPartsDiscountPricing = database.query('Select SVMXC__Discount_Percentage__c, SVMXC__Product__c,SVMXC__Service_Contract__c, SVMXC__Product_Family__c, SVMXC__Product_Line__c From SVMXC__Parts_Discount__c where SVMXC__Active__c = true and SVMXC__Service_Contract__c IN :sconIds AND CurrencyIsoCode = :strCurrencyIsoCode');
                // Get special labor pricing for Contract
                lstLaborPricing = database.query('Select SVMXC__Activity_Type__c, SVMXC__Product__c,SVMXC__Product_Family__c,SVMXC__Product_Line__c,SVMXC__Service_Contract__c,SVMXC__Unit__c, SVMXC__Regular_Rate__c, SVMXC__Activity__c,SVMXC__Activity_Product__c, SVMXC__Minimum_Labor__c From SVMXC__Labor_Pricing__c where SVMXC__Service_Contract__c IN :sconIds AND CurrencyIsoCode = :strCurrencyIsoCode');
                // Get expense pricing for Contract
                lstExpensePricing = database.query('Select SVMXC__Rate__c,SVMXC__Service_Contract__c, SVMXC__Rate_Type__c, SVMXC__Expense_Type__c From SVMXC__Expense_Pricing__c where SVMXC__Service_Contract__c IN :sconIds AND CurrencyIsoCode = :strCurrencyIsoCode');
                // Get expense pricing for Contract
                if(lstProducts != null && !lstProducts.isEmpty())
                    lstPartsPricebookEntry = database.query('SELECT Name,UnitPrice,UseStandardPrice,Product2Id,Pricebook2Id,Pricebook2.name FROM PricebookEntry WHERE Pricebook2.IsActive = true AND (Pricebook2.Name IN:partsPricebook OR Pricebook2Id IN :partsPricebook) AND CurrencyIsoCode = :strCurrencyIsoCode AND Product2Id IN:lstProducts AND IsActive = true');
                if(lstLabor != null && !lstLabor.isEmpty())    
                    lstLaborPricebookEntry = database.query('SELECT Name, SVMXC__Unit__c, SVMXC__Regular_Rate__c, SVMXC__Price_Book__c, SVMXC__Activity_Type__c, SVMXC__Activity__c, SVMXC__Activity_Product__c, SVMXC__Product__c, SVMXC__Product_Family__c, SVMXC__Product_Line__c FROM SVMXC__Service_Pricebook_Entry__c WHERE SVMXC__Activity_Type__c IN : lstLabor AND SVMXC__Price_Book__r.SVMXC__Active__c = true AND SVMXC__Price_Book__c IN :laborPricebook AND CurrencyIsoCode = :strCurrencyIsoCode');
            }
            else
            {
                lstPartsPricing = [Select SVMXC__Product__c,SVMXC__Service_Contract__c, SVMXC__Price_Per_Unit__c From SVMXC__Parts_Pricing__c where SVMXC__Service_Contract__c IN :sconIds and SVMXC__Active__c = true];
                lstPartsDiscountPricing = [Select SVMXC__Discount_Percentage__c, SVMXC__Product__c,SVMXC__Service_Contract__c, SVMXC__Product_Family__c, SVMXC__Product_Line__c From SVMXC__Parts_Discount__c where SVMXC__Active__c = true and SVMXC__Service_Contract__c IN :sconIds ];
                lstLaborPricing = [Select SVMXC__Activity_Type__c, SVMXC__Product__c,SVMXC__Product_Family__c,SVMXC__Product_Line__c,SVMXC__Service_Contract__c,SVMXC__Unit__c, SVMXC__Regular_Rate__c, SVMXC__Activity__c,SVMXC__Activity_Product__c, SVMXC__Minimum_Labor__c From SVMXC__Labor_Pricing__c where SVMXC__Service_Contract__c IN :sconIds ];
                lstExpensePricing = [Select SVMXC__Rate__c, SVMXC__Rate_Type__c,SVMXC__Service_Contract__c, SVMXC__Expense_Type__c From SVMXC__Expense_Pricing__c where SVMXC__Service_Contract__c IN :sconIds];                
                if(lstProducts != null && !lstProducts.isEmpty())
                    lstPartsPricebookEntry = [SELECT Name,UnitPrice,UseStandardPrice,Product2Id,Pricebook2Id,Pricebook2.name FROM PricebookEntry WHERE Pricebook2.IsActive = true AND (Pricebook2.Name IN:partsPricebook OR Pricebook2Id IN :partsPricebook) AND Product2Id IN:lstProducts AND IsActive = true];
                if(lstLabor != null && !lstLabor.isEmpty())     
                    lstLaborPricebookEntry = [SELECT Name, SVMXC__Unit__c, SVMXC__Regular_Rate__c, SVMXC__Price_Book__c, SVMXC__Activity_Type__c, SVMXC__Activity__c, SVMXC__Activity_Product__c, SVMXC__Product__c, SVMXC__Product_Family__c, SVMXC__Product_Line__c FROM SVMXC__Service_Pricebook_Entry__c WHERE SVMXC__Activity_Type__c IN :lstLabor AND SVMXC__Price_Book__r.SVMXC__Active__c = true AND SVMXC__Price_Book__c IN :laborPricebook];

            }    
        } 

        List<INTF_WebServicesDef.SVMXMap> wrapperMapList = new List<INTF_WebServicesDef.SVMXMap>();
        for(SVMXC__Service_Contract__c sconRec : lstLineServiceContract){
            if(sConWorkDetailIdsMap.containsKey(sconRec.Id)){
                INTF_WebServicesDef.SVMXMap partPricingData = new INTF_WebServicesDef.SVMXMap();
                partPricingData.values = new List<String>(sConWorkDetailIdsMap.get(sconRec.Id));
                partPricingData.record = sconRec;
                wrapperMapList.add(partPricingData);
            }
        }
        INTF_WebServicesDef.SVMXMap pricingData = new INTF_WebServicesDef.SVMXMap('LINECONTRACTDEFINITION', NULL);
        pricingData.valueMap = wrapperMapList;
        response.add(pricingData);

        wrapperMapList = new List<INTF_WebServicesDef.SVMXMap>();
        for(SVMXC__Parts_Pricing__c partPriceRec : lstPartsPricing){
            if(sConWorkDetailIdsMap.containsKey(partPriceRec.SVMXC__Service_Contract__c)){
                INTF_WebServicesDef.SVMXMap partPricingData = new INTF_WebServicesDef.SVMXMap();
                partPricingData.values = new List<String>(sConWorkDetailIdsMap.get(partPriceRec.SVMXC__Service_Contract__c));
                partPricingData.record = partPriceRec;
                wrapperMapList.add(partPricingData);
            }
        }
        pricingData = new INTF_WebServicesDef.SVMXMap('LINEPARTSPRICING', NULL);
        pricingData.valueMap = wrapperMapList;
        response.add(pricingData);

        wrapperMapList = new List<INTF_WebServicesDef.SVMXMap>();
        for(SVMXC__Parts_Discount__c partPriceRec : lstPartsDiscountPricing){
            if(sConWorkDetailIdsMap.containsKey(partPriceRec.SVMXC__Service_Contract__c)){
                INTF_WebServicesDef.SVMXMap partPricingData = new INTF_WebServicesDef.SVMXMap();
                partPricingData.values = new List<String>(sConWorkDetailIdsMap.get(partPriceRec.SVMXC__Service_Contract__c));
                partPricingData.record = partPriceRec;
                wrapperMapList.add(partPricingData);
            }
        }
        pricingData = new INTF_WebServicesDef.SVMXMap('LINEPARTSDISCOUNTPRICING', NULL);
        pricingData.valueMap = wrapperMapList;
        response.add(pricingData);    

        wrapperMapList = new List<INTF_WebServicesDef.SVMXMap>();
        for(SVMXC__Labor_Pricing__c partPriceRec : lstLaborPricing){
            if(sConWorkDetailIdsMap.containsKey(partPriceRec.SVMXC__Service_Contract__c)){
                INTF_WebServicesDef.SVMXMap partPricingData = new INTF_WebServicesDef.SVMXMap();
                partPricingData.values = new List<String>(sConWorkDetailIdsMap.get(partPriceRec.SVMXC__Service_Contract__c));
                partPricingData.record = partPriceRec;
                wrapperMapList.add(partPricingData);
            }
        }
        pricingData = new INTF_WebServicesDef.SVMXMap('LINELABORPRICING', NULL);
        pricingData.valueMap = wrapperMapList;
        response.add(pricingData);   

        wrapperMapList = new List<INTF_WebServicesDef.SVMXMap>();
        for(SVMXC__Expense_Pricing__c expensePriceRec : lstExpensePricing){
            if(sConWorkDetailIdsMap.containsKey(expensePriceRec.SVMXC__Service_Contract__c)){
                INTF_WebServicesDef.SVMXMap partPricingData = new INTF_WebServicesDef.SVMXMap();
                partPricingData.values = new List<String>(sConWorkDetailIdsMap.get(expensePriceRec.SVMXC__Service_Contract__c));
                partPricingData.record = expensePriceRec;
                wrapperMapList.add(partPricingData);
            }
        }
        pricingData = new INTF_WebServicesDef.SVMXMap('LINEEXPENSEPRICING', NULL);
        pricingData.valueMap = wrapperMapList;
        response.add(pricingData);             

        wrapperMapList = new List<INTF_WebServicesDef.SVMXMap>();
        for(PricebookEntry priceBookRec : lstPartsPricebookEntry){
            if(partsPricebookMap.containsKey(priceBookRec.Pricebook2Id) || partsPricebookMap.containsKey(priceBookRec.Pricebook2.Name)){
                Set<String> idSet = (partsPricebookMap.containsKey(priceBookRec.Pricebook2Id)) ? partsPricebookMap.get(priceBookRec.Pricebook2Id) : partsPricebookMap.get(priceBookRec.Pricebook2.Name);
                INTF_WebServicesDef.SVMXMap partPricingData = new INTF_WebServicesDef.SVMXMap();
                partPricingData.values = new List<String>(idSet);
                partPricingData.record = priceBookRec;
                wrapperMapList.add(partPricingData);
            }
        }
        pricingData = new INTF_WebServicesDef.SVMXMap('LINEPARTPRICEBOOK', NULL);
        pricingData.valueMap = wrapperMapList;
        response.add(pricingData);       

        wrapperMapList = new List<INTF_WebServicesDef.SVMXMap>();
        for(SVMXC__Service_Pricebook_Entry__c priceBookRec : lstLaborPricebookEntry){
            if(laborPricebookMap.containsKey(priceBookRec.SVMXC__Price_Book__c)){
                Set<String> idSet = laborPricebookMap.get(priceBookRec.SVMXC__Price_Book__c);
                INTF_WebServicesDef.SVMXMap partPricingData = new INTF_WebServicesDef.SVMXMap();
                partPricingData.values = new List<String>(idSet);
                partPricingData.record = priceBookRec;
                wrapperMapList.add(partPricingData);
            }
        }
        pricingData = new INTF_WebServicesDef.SVMXMap('LINELABORPRICEBOOK', NULL);
        pricingData.valueMap = wrapperMapList;
        response.add(pricingData);      



        pricingData = new INTF_WebServicesDef.SVMXMap('LINESCONTRACTENTITLED', NULL);
        pricingData.valueMap = lineSconEntitledCheck;
        response.add(pricingData);   

        return response;    
    }
    /* Request
    INTF_WebServicesDef.INTF_Request req = new INTF_WebServicesDef.INTF_Request();
    list<INTF_WebServicesDef.SVMXMap> lstValueMap = new list<INTF_WebServicesDef.SVMXMap>();
    lstValueMap.add(new INTF_WebServicesDef.SVMXMap('WORKORDER', 'a0q70000000balB'));
    SVMXC__Service_Order__c objWO = [select CurrencyIsoCode from SVMXC__Service_Order__c where id = 'a0q70000000b011'];
    lstValueMap.add(new INTF_WebServicesDef.SVMXMap('WORKORDERCURRENCYISO', objWO.CurrencyIsoCode));
    list<String> lstProduct = new list<String>();
    lstProduct.add('01t70000002KGb9');
    lstValueMap.add(new INTF_WebServicesDef.SVMXMap('PARTS', null, lstProduct));
    lstValueMap.add(new INTF_WebServicesDef.SVMXMap('LABORPARTS', null, lstProduct));
    list<String> lstLabor = new list<String>();
    lstLabor.add('Calibration');
    lstValueMap.add(new INTF_WebServicesDef.SVMXMap('LABOR', null, lstLabor));
    req.valueMap = lstValueMap;
    system.debug('TESTLOG:' + INTF_WebServicesDef.PCAL_getPricingDefinition_WS(req));
    //WO-00071694
    */
}