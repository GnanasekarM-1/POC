@isTest(SeeAllData=true)
private class PCAL_GetPrice_UT {

    static testMethod void PCAL_getPrice_Test() {
        
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
        Pricebook2 objStdPricebook = [Select Id from Pricebook2 where Name = 'Standard Price Book'];
        Pricebook2 pbk = new Pricebook2(Name= 'SCONPRICEBOOK', IsActive = true);
        insert pbk;
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = objStdPricebook.Id, Product2Id = prod.Id, UnitPrice = 300, IsActive = true); 
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pbk.Id, Product2Id = prod.Id, UnitPrice = 200, IsActive = true); 
        List<PricebookEntry> lstPricebook = new List<PricebookEntry>();
        lstPricebook.add(pbe1);
        lstPricebook.add(pbe2);
        insert lstPricebook;
        

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
        
        SVMXC__Service_Contract__c newSC = new SVMXC__Service_Contract__c();
        newSC.SVMXC__Exchange_type__c = 'Return Exchange';
        newSC.SVMXC__Start_Date__c  = system.today() - 1;
        newSC.SVMXC__End_Date__c  = system.today() + 3;
        newSC.SVMXC__Company__c = account.Id;
        newSC.SVMXC__Default_Parts_Price_Book__c = pbk.Id;
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
        
        SVMXC__Travel_Policy__c objTravelPolicy = new SVMXC__Travel_Policy__c(
                                            SVMXC__Service_Contract__c = newSC.Id,
                                            SVMXC__Service__c = objAvailableService.Id,
                                            SVMXC__Unit__c = 'Flat Rate',
                                            SVMXC__Rate__c = 100
                                            );
        insert objTravelPolicy;
        
        SVMXC__Mileage_Tiers__c objMileageTiers = new SVMXC__Mileage_Tiers__c(
                                            SVMXC__Service_Contract__c = newSC.Id,
                                            SVMXC__Minimum__c = 0,
                                            SVMXC__Maximum__c = 100,
                                            SVMXC__Unit__c = 'Flat Rate',
                                            SVMXC__Rate__c = 100
                                            );
        insert objMileageTiers;
        
        SVMXC__Zone_Pricing__c objZone = new SVMXC__Zone_Pricing__c(
                                            SVMXC__Service_Contract__c = newSC.Id,
                                            SVMXC__Zone__c = 'ZONE1',
                                            SVMXC__Rate__c = 100
                                            );
        insert objZone;
        
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c (
                                            SVMXC__Company__c = account.Id , 
                                            SVMXC__Contact__c =contact.Id, 
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c ='Medium',
                                            SVMXC__Order_Type__c='Field Service'
                                            );
         insert objWorkOrder;
         
         SVMXC__Entitlement_History__c objEntitlementHistory = new SVMXC__Entitlement_History__c(
                                            SVMXC__Service_Order__c = objWorkOrder.Id,
                                            SVMXC__Start_Date__c = system.today() - 1,
                                            SVMXC__End_Date__c  = system.today() + 3,
                                            SVMXC__Warranty__c = wrnty.Id
                                            );
        insert objEntitlementHistory;
        
        INTF_WebServicesDef.INTF_Request req = new INTF_WebServicesDef.INTF_Request();
        list<INTF_WebServicesDef.SVMXMap> lstValueMap = new list<INTF_WebServicesDef.SVMXMap>();
        lstValueMap.add(new INTF_WebServicesDef.SVMXMap('WORKORDER', objWorkOrder.Id));
        if(UserInfo.isMultiCurrencyOrganization())
        {
            String idWorkOrder = objWorkOrder.Id;
            SVMXC__Service_Order__c objWO = database.query('select CurrencyIsoCode from SVMXC__Service_Order__c where id = :idWorkOrder');
            lstValueMap.add(new INTF_WebServicesDef.SVMXMap('WORKORDERCURRENCYISO', String.valueOf(objWO.get('CurrencyIsoCode'))));
        }
        list<String> lstProduct = new list<String>();
        lstProduct.add(prod.Id);
        lstValueMap.add(new INTF_WebServicesDef.SVMXMap('PARTS', null, lstProduct));
        lstValueMap.add(new INTF_WebServicesDef.SVMXMap('LABORPARTS', null, lstProduct));
        list<String> lstLabor = new list<String>();
        lstLabor.add('Calibration');
        lstValueMap.add(new INTF_WebServicesDef.SVMXMap('LABOR', null, lstLabor));
        req.valueMap = lstValueMap;
        PCAL_getPrice clsPriceCalc = new PCAL_getPrice();
        //Warranty coverage
        clsPriceCalc.getPricingDefinitions(req);
    }
    
    static testMethod void PCAL_getPrice_Test2() 
    {
        
        SFM_Utils utils = new SFM_Utils();
        List<String> recTypeNames = new List<String>();
        recTypeNames.add('SVMXC__ServiceMax_Processes__c~SVMX Rule');
        recTypeNames.add('SVMXC__ServiceMax_Config_Data__c~Expressions');
        recTypeNames.add('SVMXC__Service_Order_Line__c~Products Serviced');
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
        Pricebook2 objStdPricebook = [Select Id from Pricebook2 where Name = 'Standard Price Book'];
        Pricebook2 pbk = new Pricebook2(Name= 'SCONPRICEBOOK', IsActive = true);
        insert pbk;
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = objStdPricebook.Id, Product2Id = prod.Id, UnitPrice = 300, IsActive = true); 
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pbk.Id, Product2Id = prod.Id, UnitPrice = 200, IsActive = true); 
        List<PricebookEntry> lstPricebook = new List<PricebookEntry>();
        lstPricebook.add(pbe1);
        lstPricebook.add(pbe2);
        insert lstPricebook;
        

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
        
        SVMXC__Service_Contract__c newSC = new SVMXC__Service_Contract__c();
        newSC.SVMXC__Exchange_type__c = 'Return Exchange';
        newSC.SVMXC__Start_Date__c  = system.today() - 1;
        newSC.SVMXC__End_Date__c  = system.today() + 3;
        newSC.SVMXC__Company__c = account.Id;
        newSC.SVMXC__Default_Parts_Price_Book__c = pbk.Id;
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
        
        SVMXC__Travel_Policy__c objTravelPolicy = new SVMXC__Travel_Policy__c(
                                            SVMXC__Service_Contract__c = newSC.Id,
                                            SVMXC__Service__c = objAvailableService.Id,
                                            SVMXC__Unit__c = 'Flat Rate',
                                            SVMXC__Rate__c = 100
                                            );
        insert objTravelPolicy;
        
        SVMXC__Mileage_Tiers__c objMileageTiers = new SVMXC__Mileage_Tiers__c(
                                            SVMXC__Service_Contract__c = newSC.Id,
                                            SVMXC__Minimum__c = 0,
                                            SVMXC__Maximum__c = 100,
                                            SVMXC__Unit__c = 'Flat Rate',
                                            SVMXC__Rate__c = 100
                                            );
        insert objMileageTiers;
        
        SVMXC__Zone_Pricing__c objZone = new SVMXC__Zone_Pricing__c(
                                            SVMXC__Service_Contract__c = newSC.Id,
                                            SVMXC__Zone__c = 'ZONE1',
                                            SVMXC__Rate__c = 100
                                            );
        insert objZone;
        
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c (
                                            SVMXC__Company__c = account.Id , 
                                            SVMXC__Contact__c =contact.Id, 
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c ='Medium',
                                            SVMXC__Order_Type__c='Field Service'
                                            );
         insert objWorkOrder;
         
         SVMXC__Service_Order_Line__c psLine = new SVMXC__Service_Order_Line__c(
        									SVMXC__Serial_Number__c = IBObject.Id,
             								SVMXC__Service_Maintenance_Contract__c = newSC.Id,
             								RecordTypeId = mapRecType_Map.get('SVMXC__Service_Order_Line__c~Products Serviced'),
             								SVMXC__Service_Order__c = objWorkOrder.Id
             								);
        
         insert psLine;	
         SVMXC__Entitlement_History__c objEntitlementHistory = new SVMXC__Entitlement_History__c(
                                            SVMXC__Service_Order__c = objWorkOrder.Id,
                                            SVMXC__Start_Date__c = system.today() - 1,
                                            SVMXC__End_Date__c  = system.today() + 3,
                                            SVMXC__Warranty__c = wrnty.Id
                                            );
        insert objEntitlementHistory;
        
        SVMXC__Entitlement_History__c objEntitlementHistory2 = new SVMXC__Entitlement_History__c(
                                            SVMXC__Work_Detail__c = psLine.Id,
                                            SVMXC__Start_Date__c = system.today() - 1,
                                            SVMXC__End_Date__c  = system.today() + 3,
                                            SVMXC__Warranty__c = wrnty.Id
                                            );
        insert objEntitlementHistory2;        
        
        INTF_WebServicesDef.INTF_Request req = new INTF_WebServicesDef.INTF_Request();
        list<INTF_WebServicesDef.SVMXMap> lstValueMap = new list<INTF_WebServicesDef.SVMXMap>();
        lstValueMap.add(new INTF_WebServicesDef.SVMXMap('WORKORDER', objWorkOrder.Id));
        if(UserInfo.isMultiCurrencyOrganization())
        {
            String idWorkOrder = objWorkOrder.Id;
            SVMXC__Service_Order__c objWO = database.query('select CurrencyIsoCode from SVMXC__Service_Order__c where id = :idWorkOrder');
            lstValueMap.add(new INTF_WebServicesDef.SVMXMap('WORKORDERCURRENCYISO', String.valueOf(objWO.get('CurrencyIsoCode'))));
        }
        list<String> lstProduct = new list<String>();
        lstProduct.add(prod.Id);
        lstValueMap.add(new INTF_WebServicesDef.SVMXMap('PARTS', null, lstProduct));
        lstValueMap.add(new INTF_WebServicesDef.SVMXMap('LABORPARTS', null, lstProduct));
        list<String> lstLabor = new list<String>();
        lstLabor.add('Calibration');
        lstValueMap.add(new INTF_WebServicesDef.SVMXMap('LABOR', null, lstLabor));
        req.valueMap = lstValueMap;
        PCAL_getPrice clsPriceCalc = new PCAL_getPrice();
        
        objEntitlementHistory.SVMXC__Warranty__c = null;
        objEntitlementHistory.SVMXC__Service_Contract__c = newSC.Id;
        update objEntitlementHistory;
        //Service Contract coverage
        clsPriceCalc.getPricingDefinitions(req);
    }
}