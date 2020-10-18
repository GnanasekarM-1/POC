@isTest(SeeAllData=true)
public class PCAL_GetPrice_Case_UT {

    static testMethod void PCAL_getPrice_Test() 
    {
        
        SFM_Utils utils = new SFM_Utils();
        List<String> recTypeNames = new List<String>();
        recTypeNames.add('SVMXC__ServiceMax_Processes__c~SVMX Rule');
        recTypeNames.add('SVMXC__ServiceMax_Config_Data__c~Expressions');
        Map<String, Id> mapRecType_Map = new Map<String, Id>();
        mapRecType_Map = utils.getRecordTypes(recTypeNames);
       
       SVMXC__ServiceMax_Processes__c objExpression = new SVMXC__ServiceMax_Processes__c();
       objExpression.SVMXC__Name__c = 'process001';
       objExpression.SVMXC__Rule_Type__c = 'Named Expression';
       objExpression.SVMXC__ProcessID__c = 'process001';
       objExpression.SVMXC__SettingID__c = 'setting001';
       objExpression.RecordTypeId = mapRecType_Map.get('SVMXC__ServiceMax_Processes__c~SVMX Rule');
       insert objExpression;
       
       System.assertEquals(true, objExpression != null);
       
       List<SVMXC__ServiceMax_Config_Data__c> expressionDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
       SVMXC__ServiceMax_Config_Data__c expDtl = new SVMXC__ServiceMax_Config_Data__c();
       expDtl.RecordTypeId = mapRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions');
       expDtl.SVMXC__Expression_Type__c = 'EXP_Named';
       expDtl.SVMXC__Expression_Rule__c = objExpression.Id;
       insert expDtl;
       
        User u = [SELECT id from User where id = :UserInfo.getUserId()];
        Account account = new Account(
                                        Name ='Account',
                                        ShippingStreet='ABC',
                                        ShippingCity='PQR ',
                                        ShippingState = 'XYZ',
                                        ShippingPostalCode='111',
                                        ShippingCountry='XYZ',
                                        BillingStreet='ABC',
                                        BillingCity='PQR ',
                                        BillingState = 'XYZ',
                                        BillingPostalCode='111',
                                        BillingCountry='XYZ'
                                        ); 
        insert account;
        
        Product2 prod = new Product2( 
                                        Name = 'TestProd',
                                        ProductCode = '123',
                                        IsActive = true
                                        );
        insert prod;
        
        Contact contact = new Contact(LastName='Last',AccountId =account.Id,Email='svmxmailfortest@servicemax.com');
        insert contact;
        
        SVMXC__Installed_Product__c IBObject = new SVMXC__Installed_Product__c(
                                        Name = 'Test IB1',
                                        SVMXC__Status__c = 'Installed',
                                        SVMXC__Product__c = prod.Id,
                                        SVMXC__Date_Installed__c = System.Today(),
                                        SVMXC__Contact__c = contact.Id,
                                        SVMXC__Company__c = account.Id
                                        );
        insert IBObject;
        
        SVMXC__Warranty__c wrnty = new SVMXC__Warranty__c();
        wrnty.SVMXC__Exchange_type__c = 'Return Exchange';
        wrnty.SVMXC__Start_Date__c = system.today() - 1;
        wrnty.SVMXC__End_Date__c = system.today() + 3;
        wrnty.SVMXC__Installed_Product__c = IBObject.Id;
        insert wrnty;
        
        SVMXC__Service_Pricebook__c newSP = new SVMXC__Service_Pricebook__c();
        newSP.SVMXC__Active__c = true;
        newSP.SVMXC__Description__c = 'TestDescription';
        newSP.Name = 'TestPricebook';
        insert newSP;
        
        SVMXC__Service_Contract__c newSC = new SVMXC__Service_Contract__c();
        newSC.SVMXC__Exchange_type__c = 'Return Exchange';
        newSC.SVMXC__Start_Date__c  = system.today() - 1;
        newSC.SVMXC__End_Date__c  = system.today() + 3;
        newSC.SVMXC__Company__c = account.Id;
        newSC.SVMXC__Service_Pricebook__c = newSP.Id; //M
        insert newSC;
        System.assert(newSC.SVMXC__Service_Pricebook__c != NULL);
        
        SVMXC__Service__c objAvailableService = new SVMXC__Service__c(Name = 'TESTSERVICE', SVMXC__Active__c = true, SVMXC__Qualifying_Criteria__c = objExpression.Id);
        insert objAvailableService;
        
        SVMXC__Pricing_Rule__c objPricingRule = new SVMXC__Pricing_Rule__c(
                                            SVMXC__Service_Type__c = objAvailableService.Id,
                                            SVMXC__Rate_Type__c = 'NTE',
                                            SVMXC__Rate__c = 2000,
                                            SVMXC__Service_Contract__c = newSC.Id
                                            );
        insert objPricingRule;
        
        
        
        Case objCase = new Case (
                                            AccountId = account.Id , 
                                            ContactId =contact.Id, 
                                            Status = 'New',
                                            Priority ='Medium',
                                            SVMXC__Product__c = prod.id
                                            );
         insert objCase;
         
         SVMXC__Entitlement_History__c objEntitlementHistory = new SVMXC__Entitlement_History__c(
                                            SVMXC__Case__c = objCase.Id,
                                            SVMXC__Start_Date__c = system.today() - 1,
                                            SVMXC__End_Date__c  = system.today() + 3,
                                            SVMXC__Warranty__c = wrnty.Id
                                            );
        insert objEntitlementHistory;
        
        INTF_WebServicesDef.INTF_Request req = new INTF_WebServicesDef.INTF_Request();
        list<INTF_WebServicesDef.SVMXMap> lstValueMap = new list<INTF_WebServicesDef.SVMXMap>();
        lstValueMap.add(new INTF_WebServicesDef.SVMXMap('CASE', objCase.Id));
        if(UserInfo.isMultiCurrencyOrganization())
        {
            String idCase = objCase.Id;
            Case objCase1 = database.query('select CurrencyIsoCode from Case where id = :idCase');
            lstValueMap.add(new INTF_WebServicesDef.SVMXMap('CASECURRENCYISO', String.valueOf(objCase1.get('CurrencyIsoCode'))));
        }
        list<String> lstProduct = new list<String>();
        lstProduct.add(prod.Id);
        list<String> lstLabor = new list<String>();
        lstLabor.add('Calibration');
        lstValueMap.add(new INTF_WebServicesDef.SVMXMap('ACTIVITY', null, lstLabor));
        req.valueMap = lstValueMap;
        PCAL_GetPrice_Case clsPriceCalc = new PCAL_GetPrice_Case();
        //Warranty coverage
        clsPriceCalc.getPricingDefinitions(req);
        clsPriceCalc.getLookupDefinition(objCase.id);
    }
    
    static testMethod void PCAL_getPrice_Test2() 
    {
        
        SFM_Utils utils = new SFM_Utils();
        List<String> recTypeNames = new List<String>();
        recTypeNames.add('SVMXC__ServiceMax_Processes__c~SVMX Rule');
        recTypeNames.add('SVMXC__ServiceMax_Config_Data__c~Expressions');
        Map<String, Id> mapRecType_Map = new Map<String, Id>();
        mapRecType_Map = utils.getRecordTypes(recTypeNames);
       
       SVMXC__ServiceMax_Processes__c objExpression = new SVMXC__ServiceMax_Processes__c();
       objExpression.SVMXC__Name__c = 'process001';
       objExpression.SVMXC__Rule_Type__c = 'Named Expression';
       objExpression.SVMXC__ProcessID__c = 'process001';
       objExpression.SVMXC__SettingID__c = 'setting001';
       objExpression.RecordTypeId = mapRecType_Map.get('SVMXC__ServiceMax_Processes__c~SVMX Rule');
       insert objExpression;
       
       System.assertEquals(true, objExpression != null);
       
       List<SVMXC__ServiceMax_Config_Data__c> expressionDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
       SVMXC__ServiceMax_Config_Data__c expDtl = new SVMXC__ServiceMax_Config_Data__c();
       expDtl.RecordTypeId = mapRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Expressions');
       expDtl.SVMXC__Expression_Type__c = 'EXP_Named';
       expDtl.SVMXC__Expression_Rule__c = objExpression.Id;
       insert expDtl;
       
        User u = [SELECT id from User where id = :UserInfo.getUserId()];
        Account account = new Account(
                                        Name ='Account',
                                        ShippingStreet='ABC',
                                        ShippingCity='PQR ',
                                        ShippingState = 'XYZ',
                                        ShippingPostalCode='111',
                                        ShippingCountry='XYZ',
                                        BillingStreet='ABC',
                                        BillingCity='PQR ',
                                        BillingState = 'XYZ',
                                        BillingPostalCode='111',
                                        BillingCountry='XYZ'
                                        ); 
        insert account;
        
        Product2 prod = new Product2( 
                                        Name = 'TestProd',
                                        ProductCode = '123',
                                        IsActive = true
                                        );
        insert prod;
        
        Contact contact = new Contact(LastName='Last',AccountId =account.Id,Email='svmxmailfortest@servicemax.com');
        insert contact;
        
        SVMXC__Installed_Product__c IBObject = new SVMXC__Installed_Product__c(
                                        Name = 'Test IB1',
                                        SVMXC__Status__c = 'Installed',
                                        SVMXC__Product__c = prod.Id,
                                        SVMXC__Date_Installed__c = System.Today(),
                                        SVMXC__Contact__c = contact.Id,
                                        SVMXC__Company__c = account.Id
                                        );
        insert IBObject;
        
        SVMXC__Warranty__c wrnty = new SVMXC__Warranty__c();
        wrnty.SVMXC__Exchange_type__c = 'Return Exchange';
        wrnty.SVMXC__Start_Date__c = system.today() - 1;
        wrnty.SVMXC__End_Date__c = system.today() + 3;
        wrnty.SVMXC__Installed_Product__c = IBObject.Id;
        insert wrnty;
        
        SVMXC__Service_Pricebook__c newSP = new SVMXC__Service_Pricebook__c();
        newSP.SVMXC__Active__c = true;
        newSP.SVMXC__Description__c = 'TestDescription';
        newSP.Name = 'TestPricebook';
        insert newSP;
        
        SVMXC__Service_Contract__c newSC = new SVMXC__Service_Contract__c();
        newSC.SVMXC__Exchange_type__c = 'Return Exchange';
        newSC.SVMXC__Start_Date__c  = system.today() - 1;
        newSC.SVMXC__End_Date__c  = system.today() + 3;
        newSC.SVMXC__Company__c = account.Id;
        newSC.SVMXC__Service_Pricebook__c = newSP.Id;
        insert newSC;
        
        SVMXC__Service__c objAvailableService = new SVMXC__Service__c(Name = 'TESTSERVICE', SVMXC__Active__c = true, SVMXC__Qualifying_Criteria__c = objExpression.Id);
        insert objAvailableService;
        
        SVMXC__Pricing_Rule__c objPricingRule = new SVMXC__Pricing_Rule__c(
                                            SVMXC__Service_Type__c = objAvailableService.Id,
                                            SVMXC__Rate_Type__c = 'NTE',
                                            SVMXC__Rate__c = 2000,
                                            SVMXC__Service_Contract__c = newSC.Id
                                            );
        insert objPricingRule;       
        
        Case objCase = new Case (
                                            AccountId = account.Id , 
                                            ContactId =contact.Id, 
                                            Status = 'New',
                                            Priority ='Medium'
                                            );
         insert objCase;
         
         SVMXC__Entitlement_History__c objEntitlementHistory = new SVMXC__Entitlement_History__c(
                                            SVMXC__Case__c = objCase.Id,
                                            SVMXC__Start_Date__c = system.today() - 1,
                                            SVMXC__End_Date__c  = system.today() + 3,
                                            SVMXC__Warranty__c = wrnty.Id
                                            );
        insert objEntitlementHistory;
        
        INTF_WebServicesDef.INTF_Request req = new INTF_WebServicesDef.INTF_Request();
        list<INTF_WebServicesDef.SVMXMap> lstValueMap = new list<INTF_WebServicesDef.SVMXMap>();
        lstValueMap.add(new INTF_WebServicesDef.SVMXMap('WORKORDER', objCase.Id));
        if(UserInfo.isMultiCurrencyOrganization())
        {
            String idCase = objCase.Id;
            Case objCase1 = database.query('select CurrencyIsoCode from Case where id = :idCase');
            lstValueMap.add(new INTF_WebServicesDef.SVMXMap('CASECURRENCYISO', String.valueOf(objCase1.get('CurrencyIsoCode'))));
        }
        list<String> lstProduct = new list<String>();
        lstProduct.add(prod.Id);
        list<String> lstLabor = new list<String>();
        lstLabor.add('Calibration');
        lstValueMap.add(new INTF_WebServicesDef.SVMXMap('ACTIVITY', null, lstLabor));
        req.valueMap = lstValueMap;
        PCAL_GetPrice_Case clsPriceCalc = new PCAL_GetPrice_Case();
        
        objEntitlementHistory.SVMXC__Warranty__c = null;
        objEntitlementHistory.SVMXC__Service_Contract__c = newSC.Id;
        update objEntitlementHistory;
        //Service Contract coverage
        clsPriceCalc.getPricingDefinitions(req);
    } 
}