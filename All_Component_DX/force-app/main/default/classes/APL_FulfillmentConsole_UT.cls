@isTest(SeeAllData=true)
public with sharing class APL_FulfillmentConsole_UT {

    static testMethod void APL_GetFulfillmentOrder_Test() 
    {
        SVMXC.SFM_Utils utils = new SVMXC.SFM_Utils();
        Map<String, Id> objectRecType_Map = new Map<String, Id>();
        List<String> recTypeNames = new List<String>();
        recTypeNames.add('SVMXC__Site__c~Depot');
        recTypeNames.add('SVMXC__Site__c~Depot Child');
        recTypeNames.add('SVMXC__RMA_Shipment_Order__c~Shipment');
        recTypeNames.add('SVMXC__RMA_Shipment_Line__c~Shipment');
        objectRecType_Map = utils.getRecordTypes(recTypeNames);
        
        RecordType FulfillmentProcess_Rtype = [select Id from RecordType where Name='Fulfillment Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType rule_Rtype = [select Id from RecordType where Name='SVMX Rule'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpressionsSrcUpdate_Rtype = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        RecordType FulfilPath_Rtype = [select Id from RecordType where Name='Fulfillment Path'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        
        Account a = new Account();
        a.Name = 'abc';
        insert a;
        system.assert(a.Name!=null);
        
        Product2 IP_Product = new Product2(Name = 'My Prod1234', Family = 'Laptop');
        insert IP_Product;
        
        SVMXC__Site__c Loc1 = new SVMXC__Site__c();
        Loc1.Name = 'Loc1';
        Loc1.SVMXC__Country__c = 'India';
        Loc1.RecordTypeId = objectRecType_Map.get('SVMXC__Site__c~Depot');
        insert Loc1;        
        system.assert(Loc1.Name!=null);
        
        SVMXC__Site__c Loc2 = new SVMXC__Site__c();
        Loc2.Name = 'Loc2';
        Loc2.SVMXC__Country__c = 'India';
        Loc2.SVMXC__Parent__c = Loc1.Id;
        Loc2.SVMXC__IsReceiving_Location__c = true;
        Loc2.RecordTypeId = objectRecType_Map.get('SVMXC__Site__c~Depot Child');
        
        SVMXC__Site__c Loc3 = new SVMXC__Site__c();
        Loc3.Name = 'Loc3';
        Loc3.SVMXC__Country__c = 'India';
        Loc3.SVMXC__Parent__c = Loc1.Id;
        Loc3.SVMXC__IsDelivery_Location__c = true;
        Loc3.SVMXC__IsDefault_Delivery__c = true;
        Loc3.SVMXC__IsGood_Stock__c = true;
        Loc3.RecordTypeId = objectRecType_Map.get('SVMXC__Site__c~Depot Child');        
        
        List<SVMXC__Site__c> lstSite = new List<SVMXC__Site__c>();
        lstSite.add(Loc2);
        lstSite.add(Loc3);
        insert lstSite;
        System.assert(lstSite.size()==2);
        
        SVMXC__RMA_Shipment_Order__c partsOrder = new SVMXC__RMA_Shipment_Order__c();
        partsOrder.SVMXC__Billing_Type__c = 'Contract';
        partsOrder.SVMXC__Order_Status__c = 'Open';
        partsOrder.SVMXC__Company__c = a.id;
        partsOrder.SVMXC__Destination_Location__c = Loc1.id;
        partsOrder.SVMXC__Fulfillment_Type__c = 'Repair';
        partsOrder.SVMXC__On_Hold__c = false;
        
        SVMXC__RMA_Shipment_Order__c partsOrder2 = new SVMXC__RMA_Shipment_Order__c();
        partsOrder2.SVMXC__Billing_Type__c = 'Contract';
        partsOrder2.SVMXC__Order_Status__c = 'Open';
        partsOrder2.SVMXC__Company__c = a.id;
        partsOrder2.SVMXC__Destination_Location__c = Loc1.id;
        partsOrder2.RecordTypeId = objectRecType_Map.get('SVMXC__RMA_Shipment_Order__c~Shipment');
        partsOrder2.SVMXC__On_Hold__c = false;
        
        SVMXC__RMA_Shipment_Order__c partsOrder3 = new SVMXC__RMA_Shipment_Order__c();
        partsOrder3.SVMXC__Billing_Type__c = 'Contract';
        partsOrder3.SVMXC__Order_Status__c = 'Open';
        partsOrder3.SVMXC__Company__c = a.id;
        partsOrder3.SVMXC__Destination_Location__c = null;
        partsOrder3.SVMXC__Fulfillment_Type__c = 'Repair';
        partsOrder3.RecordTypeId = objectRecType_Map.get('SVMXC__RMA_Shipment_Order__c~Shipment');
        partsOrder3.SVMXC__On_Hold__c = false;
                
        List<SVMXC__RMA_Shipment_Order__c> lstRMAShip = new List<SVMXC__RMA_Shipment_Order__c>();
        lstRMAShip.add(partsOrder);
        lstRMAShip.add(partsOrder2);
        lstRMAShip.add(partsOrder3);
        insert lstRMAShip;
        System.assert(lstRMAShip.size()==3);
        
        SVMXC__RMA_Shipment_Line__c orderLines1 = new SVMXC__RMA_Shipment_Line__c();
        orderLines1.SVMXC__RMA_Shipment_Order__c = partsOrder.Id;
        orderLines1.SVMXC__Product__c = IP_Product.Id;
        orderLines1.SVMXC__Expected_Quantity2__c = 2;
        orderLines1.SVMXC__Serial_Number_List__c = 'SN-0001;SN-0002';
        orderLines1.RecordTypeId = objectRecType_Map.get('SVMXC__RMA_Shipment_Line__c~Shipment');
        insert orderLines1;
        system.assert(orderLines1.SVMXC__Serial_Number_List__c != null);
        
        SVMXC__Product_Replacement__c prodRepl = new SVMXC__Product_Replacement__c();
        prodRepl.SVMXC__Base_Product__c = IP_Product.Id;
        prodRepl.SVMXC__Replacement_Product__c = IP_Product.Id;
        insert prodRepl;
        
        SVMXC__ServiceMax_Processes__c SVMXProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXProcess.RecordTypeId = FulfillmentProcess_Rtype.Id;
        SVMXProcess.SVMXC__Name__c = 'Fulfillment Process';
        SVMXProcess.SVMXC__Description__c = 'Fulfillment Process';
        SVMXProcess.SVMXC__ProcessID__c = 'TEST_FULFILLMENT_PROCESS';
        SVMXProcess.SVMXC__Active__c = true;
        SVMXProcess.SVMXC__Parent_Error_Msg__c = 'error found';
        SVMXProcess.SVMXC__Child_Error_Msg__c = 'error found in child';             
        insert SVMXProcess;
        
        SVMXC__ServiceMax_Processes__c fulPathProc = new SVMXC__ServiceMax_Processes__c();
        fulPathProc.SVMXC__Process__c = SVMXProcess.Id;
        fulPathProc.SVMXC__ProcessID__c = 'TEST_FULFILLMENT_PROCESS_Path';
        fulPathProc.SVMXC__Rule_Type__c = 'FulFillment Path';       
        fulPathProc.SVMXC__Default_Location__c = Loc3.Id;
        fulPathProc.RecordTypeId = rule_Rtype.Id;
        fulPathProc.SVMXC__IsDefault__c = true;
        insert fulPathProc;
        
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c pathConfData = new SVMXC__ServiceMax_Config_Data__c();
        pathConfData.SVMXC__Dispatch_Process__c = fulPathProc.Id;
        pathConfData.RecordTypeId = FulfilPath_Rtype.Id;
        pathConfData.SVMXC__Sequence__c = 1;
        pathConfData.SVMXC__Location__c = Loc3.Id;
        lstConfigData.add(pathConfData);
        
        //Product Attributes
        SVMXC__ServiceMax_Config_Data__c configData1 = new SVMXC__ServiceMax_Config_Data__c();
        configData1.SVMXC__Configuration_Type__c = 'PRODUCT_ATTRIBUTE';
        configData1.SVMXC__Dispatch_Process__c = SVMXProcess.Id;
        configData1.RecordTypeId = ExpressionsSrcUpdate_Rtype.Id;
        configData1.SVMXC__Field_Name__c = 'Description';
        lstConfigData.add(configData1);
        SVMXC__ServiceMax_Config_Data__c configData2 = new SVMXC__ServiceMax_Config_Data__c();
        configData2.SVMXC__Configuration_Type__c = 'PRODUCT_ATTRIBUTE';
        configData2.SVMXC__Dispatch_Process__c = SVMXProcess.Id;
        configData2.RecordTypeId = ExpressionsSrcUpdate_Rtype.Id;
        lstConfigData.add(configData2);
        //Document Attributes 
        SVMXC__ServiceMax_Config_Data__c configData3 = new SVMXC__ServiceMax_Config_Data__c();
        configData3.SVMXC__Configuration_Type__c = 'DOCUMENT_ATTRIBUTE';
        configData3.SVMXC__Dispatch_Process__c = SVMXProcess.Id;
        configData3.RecordTypeId = ExpressionsSrcUpdate_Rtype.Id;
        configData3.SVMXC__Field_Name__c = 'SVMXC__Company__c';
        configData3.SVMXC__Object_Name__c = 'Account';
        configData3.SVMXC__Display_Type__c = 'REFERENCE';
        configData3.SVMXC__Field_Relationship_Name__c = 'SVMXC__Company__r';
        configData3.SVMXC__FKey_Name_Field__c = 'Name';
        lstConfigData.add(configData3);
        SVMXC__ServiceMax_Config_Data__c configData4 = new SVMXC__ServiceMax_Config_Data__c();
        configData4.SVMXC__Configuration_Type__c = 'DOCUMENT_LINE_ATTRIBUTE';
        configData4.SVMXC__Dispatch_Process__c = SVMXProcess.Id;
        configData4.RecordTypeId = ExpressionsSrcUpdate_Rtype.Id;
        configData4.SVMXC__Field_Name__c = 'SVMXC__Billing_Type__c';
        configData4.SVMXC__Display_Type__c = 'PICKLIST';
        lstConfigData.add(configData4);
        insert lstConfigData;
        System.assert(lstConfigData.size()==5);
        
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest request = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMap = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
        list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMapDELIVERYONRECEIPT = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
        
        SVMXC.INTF_WebServicesDef.SVMXMap svmxmap = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap.key = 'SVMX_RECORDID';
        svmxmap.value = partsOrder.id;
        lstSVMXMap.add(svmxmap);
        lstSVMXMapDELIVERYONRECEIPT.add(svmxmap);
        
        SVMXC.INTF_WebServicesDef.SVMXMap svmxmap1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap1.key = 'SVMX_PROCESSID';
        svmxmap1.value = SVMXProcess.id;
        lstSVMXMap.add(svmxmap1);
        lstSVMXMapDELIVERYONRECEIPT.add(svmxmap1);
        
        SVMXC.INTF_WebServicesDef.SVMXMap svmxmap2 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap2.key = 'SVMX_PROCESSTYPE';
        svmxmap2.value = 'FULFILLMENTPROCESS';
        lstSVMXMap.add(svmxmap2);
        
        SVMXC.INTF_WebServicesDef.SVMXMap svmxmap3 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap3.key = 'SVMX_BATCHIDS';
        svmxmap3.valueMap = lstSVMXMapDELIVERYONRECEIPT;
        lstSVMXMap.add(svmxmap3);

        SVMXC.INTF_WebServicesDef.SVMXMap svmxmap4 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap4.key = 'EXISTINGSHIPMENTLOCATIONS';
        svmxmap4.value = Loc1.id;
        lstSVMXMap.add(svmxmap4);
        
        request.valueMap = lstSVMXMap;
        request.eventType = 'INITIALSYNC';
        //SVMXC.APL_OrderUtils getorder = new SVMXC.APL_OrderUtils();
        SVMXC.APL_FulfillmentConsole getFulfillmentOrder = new SVMXC.APL_FulfillmentConsole();
        
        getFulfillmentOrder.getAPLFulfillmentOrder(request);        
        request.eventType = 'XYZ';
        getFulfillmentOrder.getAPLFulfillmentOrder(request);
        SVMXC__Site__c[] SITE = [SELECT id FROM SVMXC__Site__c WHERE Name = 'Loc2'];
        SITE[0].SVMXC__IsReceiving_Location__c = false;
        update SITE;
        getFulfillmentOrder.getAPLFulfillmentOrder(request);
        
        SITE = [SELECT id FROM SVMXC__Site__c WHERE Name = 'Loc2' OR Name = 'Loc3'];
        SITE[0].SVMXC__IsReceiving_Location__c = true;
        SITE[1].SVMXC__IsReceiving_Location__c = true;
        update SITE;
        Test.startTest();
        getFulfillmentOrder.getAPLFulfillmentOrder(request); 
        Test.stopTest();       
    }
    static testMethod void APL_FulfillmentConsole_Test() 
    {
        SFM_Utils utils = new SFM_Utils();
        List<String> recTypeNames = new List<String>();
        recTypeNames.add('SVMXC__RMA_Shipment_Order__c~RMA');
        recTypeNames.add('SVMXC__RMA_Shipment_Line__c~RMA');
        recTypeNames.add('SVMXC__RMA_Shipment_Order__c~Shipment');
        recTypeNames.add('SVMXC__RMA_Shipment_Line__c~Shipment');
        recTypeNames.add('SVMXC__Site__c~Depot');
        recTypeNames.add('SVMXC__Site__c~Depot Child');
        recTypeNames.add('SVMXC__ServiceMax_Processes__c~Fulfillment Process');
        recTypeNames.add('SVMXC__ServiceMax_Processes__c~SVMX Rule');
        recTypeNames.add('SVMXC__ServiceMax_Config_Data__c~Fulfillment Path');
        Map<String, Id> mapRecType_Map = new Map<String, Id>();
        mapRecType_Map = utils.getRecordTypes(recTypeNames);
        
        // Creating inventory structure
        List<SVMXC__Site__c> lstAllLocations = new List<SVMXC__Site__c>();
        SVMXC__Site__c depo = new SVMXC__Site__c(Name = 'TestDepo', RecordTypeId = mapRecType_Map.get('SVMXC__Site__c~Depot'));
        insert depo;
        System.assert(depo.id != null);
        
        SVMXC__Site__c depo2 = new SVMXC__Site__c(Name = 'TestDepo2', RecordTypeId = mapRecType_Map.get('SVMXC__Site__c~Depot'));
        insert depo2;
        System.assert(depo2.id != null);
        
        SVMXC__Site__c depoChild1 = new SVMXC__Site__c(Name = 'TestDepoChild1', SVMXC__IsReceiving_Location__c = true, SVMXC__Parent__c = depo.Id, RecordTypeId = mapRecType_Map.get('SVMXC__Site__c~Depot Child'));
        lstAllLocations.add(depoChild1);
        SVMXC__Site__c depoChild2 = new SVMXC__Site__c(Name = 'TestDepoChild2', SVMXC__IsStaging_Location__c = true, SVMXC__Parent__c = depo.Id, RecordTypeId = mapRecType_Map.get('SVMXC__Site__c~Depot Child'));
        lstAllLocations.add(depoChild2);
        SVMXC__Site__c depoChild3 = new SVMXC__Site__c(Name = 'TestDepoChild3', SVMXC__Parent__c = depo.Id, RecordTypeId = mapRecType_Map.get('SVMXC__Site__c~Depot Child'));
        lstAllLocations.add(depoChild3);
        SVMXC__Site__c depoChild4 = new SVMXC__Site__c(Name = 'TestDepoChild4', SVMXC__Parent__c = depo.Id, RecordTypeId = mapRecType_Map.get('SVMXC__Site__c~Depot Child'));
        lstAllLocations.add(depoChild4);
        SVMXC__Site__c depoChild5 = new SVMXC__Site__c(Name = 'TestDepoChild21', SVMXC__IsReceiving_Location__c = true, SVMXC__Parent__c = depo2.Id, RecordTypeId = mapRecType_Map.get('SVMXC__Site__c~Depot Child'));
        lstAllLocations.add(depoChild5);
        SVMXC__Site__c depoChild6 = new SVMXC__Site__c(Name = 'TestDepoChild22', SVMXC__IsStaging_Location__c = true, SVMXC__Parent__c = depo2.Id, RecordTypeId = mapRecType_Map.get('SVMXC__Site__c~Depot Child'));
        lstAllLocations.add(depoChild6);
        insert lstAllLocations;
        System.assert(lstAllLocations.size()==6);
        
        // Creating process definitions
        SVMXC__ServiceMax_Processes__c fulfilmentProcess = new SVMXC__ServiceMax_Processes__c(SVMXC__ProcessID__c = 'TESTPROCESS');
        fulfilmentProcess.recordTypeId = mapRecType_Map.get('SVMXC__ServiceMax_Processes__c~Fulfillment Process');
        insert fulfilmentProcess;
        System.assert(fulfilmentProcess.id != null);
        
        Id processId = fulfilmentProcess.Id;
        
        SVMXC__ServiceMax_Processes__c expressionLaptop = new SVMXC__ServiceMax_Processes__c();
        expressionLaptop.SVMXC__SettingId__c = 'MY8DIGITKEY2';
        expressionLaptop.recordTypeId = mapRecType_Map.get('SVMXC__ServiceMax_Processes__c~SVMX Rule');
        expressionLaptop.SVMXC__Rule_Type__c = 'Named Expression';
        expressionLaptop.SVMXC__Sequence__c = 1;
        expressionLaptop.SVMXC__Source_Object_Name__c = 'Product2';
        expressionLaptop.SVMXC__Parent_Object_Criteria__c = 'Family = \'Laptop\'';
        insert expressionLaptop;        
        system.assert(expressionLaptop.SVMXC__SettingId__c != null);
        
        SVMXC__ServiceMax_Processes__c expressionAccesory = new SVMXC__ServiceMax_Processes__c();
        expressionAccesory.SVMXC__SettingId__c = 'MY8DIGITKEY';
        expressionAccesory.recordTypeId = mapRecType_Map.get('SVMXC__ServiceMax_Processes__c~SVMX Rule');
        expressionAccesory.SVMXC__Rule_Type__c = 'Named Expression';
        expressionAccesory.SVMXC__Sequence__c = 1;
        expressionAccesory.SVMXC__Source_Object_Name__c = 'Product2';
        expressionAccesory.SVMXC__Parent_Object_Criteria__c = 'Family = \'Accessary\'';
        insert expressionAccesory;
        system.assert(expressionAccesory.SVMXC__SettingId__c != null);
        
        SVMXC__ServiceMax_Processes__c fulfillmentRule = new SVMXC__ServiceMax_Processes__c();
        fulfillmentRule.recordTypeId = mapRecType_Map.get('SVMXC__ServiceMax_Processes__c~SVMX Rule');
        fulfillmentRule.SVMXC__Rule_Type__c = 'FulFillment Path';
        fulfillmentRule.SVMXC__Sequence__c = 1;
        fulfillmentRule.SVMXC__Default_Location__c = lstAllLocations[0].Id;
        fulfillmentRule.SVMXC__Process__c = processId;
        fulfillmentRule.SVMXC__Submodule__c = expressionLaptop.Id;
        fulfillmentRule.SVMXC__IsDefault__c = true;
        insert fulfillmentRule;
        system.assert(fulfillmentRule.SVMXC__Rule_Type__c != null);
        
        SVMXC__ServiceMax_Processes__c fulfillmentRule2 = new SVMXC__ServiceMax_Processes__c();
        fulfillmentRule2.recordTypeId = mapRecType_Map.get('SVMXC__ServiceMax_Processes__c~SVMX Rule');
        fulfillmentRule2.SVMXC__Rule_Type__c = 'FulFillment Path';
        fulfillmentRule2.SVMXC__Sequence__c = 1;
        fulfillmentRule2.SVMXC__Default_Location__c = lstAllLocations[0].Id;
        fulfillmentRule2.SVMXC__Process__c = processId;
        fulfillmentRule2.SVMXC__Submodule__c = expressionAccesory.Id;
        insert fulfillmentRule2;
        system.assert(fulfillmentRule2.SVMXC__Rule_Type__c != null);
        
        list<SVMXC__ServiceMax_Config_Data__c> lstLoc = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c path1 = new SVMXC__ServiceMax_Config_Data__c();
        path1.recordTypeId = mapRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Fulfillment Path');
        path1.SVMXC__Sequence__c = 1;
        path1.SVMXC__Location__c = lstAllLocations[1].Id;
        path1.SVMXC__Dispatch_Process__c = fulfillmentRule.Id;
        lstLoc.add(path1);
        
        SVMXC__ServiceMax_Config_Data__c path2 = new SVMXC__ServiceMax_Config_Data__c();
        path2.recordTypeId = mapRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Fulfillment Path');
        path2.SVMXC__Sequence__c = 2;
        path2.SVMXC__Location__c = lstAllLocations[2].Id;
        path2.SVMXC__Dispatch_Process__c = fulfillmentRule.Id;
        path2.SVMXC__Object_Name__c = 'Product2';
        lstLoc.add(path2);
        
        SVMXC__ServiceMax_Config_Data__c path3 = new SVMXC__ServiceMax_Config_Data__c();
        path3.recordTypeId = mapRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Fulfillment Path');
        path3.SVMXC__Sequence__c = 2;
        path3.SVMXC__Location__c = lstAllLocations[0].Id;
        path3.SVMXC__Dispatch_Process__c = fulfillmentRule.Id;
        path3.SVMXC__Object_Name__c = 'Product2';
        lstLoc.add(path3);
        
        SVMXC__ServiceMax_Config_Data__c path4 = new SVMXC__ServiceMax_Config_Data__c();
        path4.recordTypeId = mapRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Fulfillment Path');
        path4.SVMXC__Sequence__c = 1;
        path4.SVMXC__Location__c = lstAllLocations[5].Id;
        path4.SVMXC__Dispatch_Process__c = fulfillmentRule2.Id;
        lstLoc.add(path4);
        insert lstLoc;
        system.assert(lstLoc.size() != null);
        
        Account account1 = new Account();
        account1.Name = 'abc';
        insert account1;
        System.assert(account1.id != null);
        
        // Creating product and product stock
        list<Product2> lstProd = new list<Product2>();
        Product2 IP_Product1 = new Product2(Name = 'My Prod1', Family = 'Accessary');
        lstProd.add(IP_Product1);
        Product2 IP_Product2 = new Product2(Name = 'My Prod2', Family = 'Laptop');
        lstProd.add(IP_Product2);
        Product2 IP_Product3 = new Product2(Name = 'My Prod3', Family = 'Accessary');
        lstProd.add(IP_Product3);
        Product2 IP_Product4 = new Product2(Name = 'My Prod4', Family = 'Laptop');
        lstProd.add(IP_Product4);
        Product2 IP_Product5 = new Product2(Name = 'My Prod4', Family = 'UNKNOWN');
        lstProd.add(IP_Product5);
        insert lstProd;
        System.assert(lstProd.size() == 5);
        
        list<SVMXC__Product_Replacement__c> lstProdRelacement = new list<SVMXC__Product_Replacement__c>();
        SVMXC__Product_Replacement__c replaceProduct1 = new SVMXC__Product_Replacement__c(SVMXC__Base_Product__c = IP_Product1.Id, SVMXC__Replacement_Product__c = IP_Product2.Id, SVMXC__Order_Of_Preference__c = 1);
        SVMXC__Product_Replacement__c replaceProduct2 = new SVMXC__Product_Replacement__c(SVMXC__Base_Product__c = IP_Product2.Id, SVMXC__Replacement_Product__c = IP_Product3.Id, SVMXC__Order_Of_Preference__c = 1);
        SVMXC__Product_Replacement__c replaceProduct3 = new SVMXC__Product_Replacement__c(SVMXC__Base_Product__c = IP_Product3.Id, SVMXC__Replacement_Product__c = IP_Product4.Id, SVMXC__Order_Of_Preference__c = 1);
        SVMXC__Product_Replacement__c replaceProduct4 = new SVMXC__Product_Replacement__c(SVMXC__Base_Product__c = IP_Product4.Id, SVMXC__Replacement_Product__c = IP_Product5.Id, SVMXC__Order_Of_Preference__c = 1);
        SVMXC__Product_Replacement__c replaceProduct5 = new SVMXC__Product_Replacement__c(SVMXC__Base_Product__c = IP_Product5.Id, SVMXC__Replacement_Product__c = IP_Product1.Id, SVMXC__Order_Of_Preference__c = 1);
        lstProdRelacement.add(replaceProduct1);
        lstProdRelacement.add(replaceProduct2);
        lstProdRelacement.add(replaceProduct3);
        lstProdRelacement.add(replaceProduct4);
        lstProdRelacement.add(replaceProduct5);
        insert lstProdRelacement;
        System.assert(lstProdRelacement.size() == 5);
        
        list<SVMXC__Product_Stock__c> lstProductStock = new list<SVMXC__Product_Stock__c>();
        SVMXC__Product_Stock__c prdStk1 = new SVMXC__Product_Stock__c();
        prdStk1.SVMXC__Quantity2__c = 2;
        prdStk1.SVMXC__Location__c = lstAllLocations[0].Id;
        prdStk1.SVMXC__Product__c = lstProd[2].Id;
        prdStk1.SVMXC__Status__c = 'Available';
        lstProductStock.add(prdStk1);
        
        SVMXC__Product_Stock__c prdStk2 = new SVMXC__Product_Stock__c();
        prdStk2.SVMXC__Quantity2__c = 1;
        prdStk2.SVMXC__Location__c = lstAllLocations[2].Id;
        prdStk2.SVMXC__Product__c = lstProd[1].Id;
        prdStk2.SVMXC__Status__c = 'Available';
        lstProductStock.add(prdStk2);
        
        SVMXC__Product_Stock__c prdStk3 = new SVMXC__Product_Stock__c();
        prdStk3.SVMXC__Quantity2__c = 2;
        prdStk3.SVMXC__Location__c = lstAllLocations[2].Id;
        prdStk3.SVMXC__Product__c = lstProd[4].Id;
        prdStk3.SVMXC__Status__c = 'Available';
        lstProductStock.add(prdStk3);
        
        SVMXC__Product_Stock__c prdStk4 = new SVMXC__Product_Stock__c();
        prdStk4.SVMXC__Quantity2__c = 2;
        prdStk4.SVMXC__Location__c = lstAllLocations[1].Id;
        prdStk4.SVMXC__Product__c = lstProd[3].Id;
        prdStk4.SVMXC__Status__c = 'Available';
        lstProductStock.add(prdStk4);
        
        SVMXC__Product_Stock__c prdStk5 = new SVMXC__Product_Stock__c();
        prdStk5.SVMXC__Quantity2__c = 13;
        prdStk5.SVMXC__Location__c = lstAllLocations[4].Id;
        prdStk5.SVMXC__Product__c = lstProd[4].Id;
        prdStk5.SVMXC__Status__c = 'Available';
        lstProductStock.add(prdStk5);
        
        SVMXC__Product_Stock__c prdStk6 = new SVMXC__Product_Stock__c();
        prdStk6.SVMXC__Quantity2__c = 1;
        prdStk6.SVMXC__Location__c = lstAllLocations[5].Id;
        prdStk6.SVMXC__Product__c = lstProd[0].Id;
        prdStk6.SVMXC__Status__c = 'Available';
        lstProductStock.add(prdStk6);
        
        SVMXC__Product_Stock__c prdStk7 = new SVMXC__Product_Stock__c();
        prdStk7.SVMXC__Quantity2__c = 1;
        prdStk7.SVMXC__Location__c = lstAllLocations[5].Id;
        prdStk7.SVMXC__Product__c = lstProd[2].Id;
        prdStk7.SVMXC__Status__c = 'Available';
        lstProductStock.add(prdStk7);
        
        SVMXC__Product_Stock__c prdStk8 = new SVMXC__Product_Stock__c();
        prdStk8.SVMXC__Quantity2__c = 12;
        prdStk8.SVMXC__Location__c = lstAllLocations[1].Id;
        prdStk8.SVMXC__Product__c = lstProd[4].Id;
        prdStk8.SVMXC__Status__c = 'Available';
        lstProductStock.add(prdStk8);
        
        SVMXC__Product_Stock__c prdStk9 = new SVMXC__Product_Stock__c();
        prdStk9.SVMXC__Quantity2__c = 1;
        prdStk9.SVMXC__Location__c = lstAllLocations[3].Id;
        prdStk9.SVMXC__Product__c = lstProd[2].Id;
        prdStk9.SVMXC__Status__c = 'Available';
        lstProductStock.add(prdStk9);
        insert lstProductStock;
        System.assert(lstProductStock.size() == 9);
        
        SVMXC.APL_FulfillmentConsole getFulfillmentOrder = new SVMXC.APL_FulfillmentConsole();
        getFulfillmentOrder.createProductIfdoesnotExist(new Set<Id>{lstAllLocations[0].id},new Set<Id>{lstProd[0].id},lstProductStock);
        
        set<Id> locationId = new set<Id>();
        locationId.add(lstAllLocations[0].id);
        locationId.add(lstAllLocations[1].id);
        locationId.add(lstAllLocations[2].id);
        locationId.add(lstAllLocations[3].id);
        locationId.add(lstAllLocations[4].id);
        locationId.add(lstAllLocations[5].id);
        set<Id> productId = new set<Id>();
        productId.add(lstProd[0].Id);
        productId.add(lstProd[1].Id);
        productId.add(lstProd[2].Id);
        productId.add(lstProd[3].Id);
        productId.add(lstProd[4].Id);
        boolean createStockIfDoesnotExist = false;
        getFulfillmentOrder.getAvailableStock(locationId, productId, createStockIfDoesnotExist);
        
        // Creating RMA and RMA lines
        SVMXC__RMA_Shipment_Order__c partsOrder = new SVMXC__RMA_Shipment_Order__c();
        partsOrder.recordTypeId = mapRecType_Map.get('SVMXC__RMA_Shipment_Order__c~RMA');
        partsOrder.SVMXC__Billing_Type__c = 'Contract';
        partsOrder.SVMXC__Order_Status__c = 'Open';
        partsOrder.SVMXC__Fulfillment_Type__c = 'Repair';
        partsOrder.SVMXC__Company__c = account1.id;
        partsOrder.SVMXC__Source_Location__c = lstAllLocations[0].Id;
        partsOrder.SVMXC__Destination_Location__c = depo2.Id;
        insert partsOrder;
        System.assert(partsOrder.id != null);
        
        list<SVMXC__RMA_Shipment_Line__c> lstShipLines = new list<SVMXC__RMA_Shipment_Line__c>(); 
        SVMXC__RMA_Shipment_Line__c orderLines1 = new SVMXC__RMA_Shipment_Line__c();
        orderLines1.recordTypeId = mapRecType_Map.get('SVMXC__RMA_Shipment_Line__c~RMA');
        orderLines1.SVMXC__RMA_Shipment_Order__c = partsOrder.Id;
        orderLines1.SVMXC__Product__c = lstProd[0].Id;
        orderLines1.SVMXC__Expected_Quantity2__c = 5;
        lstShipLines.add(orderLines1);
        
        SVMXC__RMA_Shipment_Line__c orderLines2 = new SVMXC__RMA_Shipment_Line__c();
        orderLines2.recordTypeId = mapRecType_Map.get('SVMXC__RMA_Shipment_Line__c~RMA');
        orderLines2.SVMXC__RMA_Shipment_Order__c = partsOrder.Id;
        orderLines2.SVMXC__Product__c = lstProd[1].Id;
        orderLines2.SVMXC__Expected_Quantity2__c = 6;
        lstShipLines.add(orderLines2);
        
        SVMXC__RMA_Shipment_Line__c orderLines3 = new SVMXC__RMA_Shipment_Line__c();
        orderLines3.recordTypeId = mapRecType_Map.get('SVMXC__RMA_Shipment_Line__c~RMA');
        orderLines3.SVMXC__RMA_Shipment_Order__c = partsOrder.Id;
        orderLines3.SVMXC__Product__c = lstProd[2].Id;
        orderLines3.SVMXC__Expected_Quantity2__c = 8;
        orderLines3.SVMXC__Master_Order_Line__c = orderLines1.id;
        orderLines3.SVMXC__Fulfillment_Qty__c = 4;
        lstShipLines.add(orderLines3);
        
        SVMXC__RMA_Shipment_Line__c orderLines4 = new SVMXC__RMA_Shipment_Line__c();
        orderLines4.recordTypeId = mapRecType_Map.get('SVMXC__RMA_Shipment_Line__c~RMA');
        orderLines4.SVMXC__RMA_Shipment_Order__c = partsOrder.Id;
        orderLines4.SVMXC__Product__c = lstProd[3].Id;
        orderLines4.SVMXC__Expected_Quantity2__c = 2;
        orderLines4.SVMXC__Master_Order_Line__c = orderLines2.id;
        orderLines4.SVMXC__Fulfillment_Qty__c = 5;
        lstShipLines.add(orderLines4);
        
        SVMXC__RMA_Shipment_Line__c orderLines5 = new SVMXC__RMA_Shipment_Line__c();
        orderLines5.recordTypeId = mapRecType_Map.get('SVMXC__RMA_Shipment_Line__c~RMA');
        orderLines5.SVMXC__RMA_Shipment_Order__c = partsOrder.Id;
        orderLines5.SVMXC__Product__c = lstProd[4].Id;
        orderLines5.SVMXC__Expected_Quantity2__c = 2;
        lstShipLines.add(orderLines5);
        insert lstShipLines;
        System.assert(lstShipLines.size() == 5);
        
        getFulfillmentOrder.updateFulfillmentQuantityonRMALine(lstShipLines); 
        
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest request = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMap = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
        
        SVMXC.INTF_WebServicesDef.SVMXMap svmxmap = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap.key = 'SVMX_RECORDID';
        svmxmap.value = partsOrder.id;
        lstSVMXMap.add(svmxmap);
        
        SVMXC.INTF_WebServicesDef.SVMXMap svmxmap1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap1.key = 'SVMX_PROCESSID';
        svmxmap1.value = processId;
        lstSVMXMap.add(svmxmap1);
        
        SVMXC.INTF_WebServicesDef.SVMXMap svmxmap2 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap2.key = 'SVMX_PROCESSTYPE';
        svmxmap2.value = 'FULFILLMENTPROCESS';
        lstSVMXMap.add(svmxmap2);
        
        SVMXC.INTF_WebServicesDef.SVMXMap svmxmap3 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap3.key = 'EXISTINGSHIPMENTLOCATIONS';
        svmxmap3.valueMap = lstSVMXMap;
        lstSVMXMap.add(svmxmap3);
        
        request.valueMap = lstSVMXMap;
        SVMXC.APL_OrderUtils getorder = new SVMXC.APL_OrderUtils();
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse response = getorder.getAPLOrder(request);
        
        SVMXC.INTF_WebServicesDef.SVMXMap reqAdditionalParam = new SVMXC.INTF_WebServicesDef.SVMXMap();
        reqAdditionalParam.key = 'REQUESTATTRIBUTE';
        reqAdditionalParam.valueMap = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
        
        for(SVMXC.INTF_WebServicesDef.APL_OrderLineCollection orderLine: response.aplOrder.orderLines)
        {
            Integer reqQty = (orderLine.orderLineRecord.SVMXC__Expected_Quantity2__c).intValue();
            Integer allocated = 0;
            reqAdditionalParam.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap(orderLine.orderLineRecord.Id, orderLine.orderLineRecord.SVMXC__Product__c));
            for(SVMXC.INTF_WebServicesDef.APL_SerialCollection prodStk: orderLine.serialNumbers)
            {
                if(reqQty <= prodStk.availableCount)
                {
                    prodStk.allocatedCount = reqQty - allocated;
                    break;
                }
                if(allocated > reqQty)
                    break;
                allocated++;
                if(orderLine.serialNumbers.size() == allocated)
                    prodStk.allocatedCount = reqQty - allocated;
                else
                    prodStk.allocatedCount = allocated;
            }
        }
        request.valueMap.add(reqAdditionalParam);
        request.aplOrder = response.aplOrder;
        response = getorder.SaveAPLOrder(request);
        
        SVMXC.INTF_WebServicesDef.APL_SerialCollection objSerial = new SVMXC.INTF_WebServicesDef.APL_SerialCollection();
        objSerial.uniqueId = lstAllLocations[0].Id;
        objSerial.serialNumber = 'SN-0001';     
        SVMXC.INTF_WebServicesDef.APL_OrderLineCollection objOrderLine = new SVMXC.INTF_WebServicesDef.APL_OrderLineCollection(lstShipLines[0],
        new list<SVMXC.INTF_WebServicesDef.APL_SerialCollection>{objSerial});       
        SVMXC.INTF_WebServicesDef.APL_Order objOrder = new SVMXC.INTF_WebServicesDef.APL_Order();
        objOrder.orderLines = new List<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection>{objOrderLine};        
        request.aplOrder = objOrder;        
        
        String strRecordId = partsOrder.id;
        getFulfillmentOrder.saveFulfillmentOrder(strRecordId, request);
    }
}