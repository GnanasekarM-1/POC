@isTest
private class APL_RMAUtils_UT {
    
    static testMethod void getOrderLinesWithLocation_Test() 
    {
        RecordType recProcessRectype = [select Id from RecordType where Name='Receiving Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpressionsSrcUpdate_Rtype = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        RecordType ExpressionHeader_Rtype = [select Id from RecordType where Name=:'SVMX Rule'and SobjectType=:'SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType Loc_RType = [select Id from RecordType where Name = 'Depot'and SobjectType= 'SVMXC__Site__c' Limit 1];
        RecordType DeliveryRule_RType = [select Id from RecordType where Name = 'Delivery Rule'and SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType FieldMapping_Rtype = [select Id from RecordType where Name = 'Field Mapping' and SobjectType=:'SVMXC__ServiceMax_Config_Data__c' Limit 1];
        RecordType RMA = [select Id from RecordType where Name = 'RMA' and SobjectType=:'SVMXC__RMA_Shipment_Order__c' Limit 1];
        
        SVMXC__Site__c Loc1 = new SVMXC__Site__c();
        Loc1.Name = 'Location 1';
        Loc1.RecordTypeId = Loc_RType.Id;
        insert Loc1;
        
        SVMXC__Site__c Loc2 = new SVMXC__Site__c();
        Loc2.Name = 'Location 1';
        Loc2.RecordTypeId = Loc_RType.Id;
        Loc2.SVMXC__Parent__c = Loc1.Id;
        insert Loc2;
        
        Account objAccount = new Account(Name = 'TEST CODE1', industry = 'Hospitality');
        insert objAccount;
        
        SVMXC__RMA_Shipment_Order__c patrsOrder = new SVMXC__RMA_Shipment_Order__c();
        patrsOrder.SVMXC__Billing_Type__c = 'Contract';
        patrsOrder.SVMXC__Order_Status__c = 'Open';
        patrsOrder.SVMXC__Source_Location__c = Loc1.Id;
        patrsOrder.SVMXC__Company__c = objAccount.Id;
        patrsOrder.SVMXC__Destination_Location__c = Loc1.Id;
        insert patrsOrder;
        
        Product2 IP_Product = new Product2(Name = 'My Prod1234', Family = 'Laptop');
        insert IP_Product;
        List<SVMXC__RMA_Shipment_Line__c> LstorderLines = new List<SVMXC__RMA_Shipment_Line__c>();
        SVMXC__RMA_Shipment_Line__c partsLine1 = new SVMXC__RMA_Shipment_Line__c();
        partsLine1.SVMXC__Product__c = IP_Product.Id;
        partsLine1.SVMXC__RMA_Shipment_Order__c = patrsOrder.Id;
        insert partsLine1;
        LstorderLines.add(partsLine1);
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Processes__c SVMXProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXProcess.RecordTypeId = recProcessRectype.Id;
        SVMXProcess.SVMXC__Name__c = 'Shipping Process';
        SVMXProcess.SVMXC__Description__c = 'Shipping Process';
        SVMXProcess.SVMXC__Active__c = true;
        insert SVMXProcess;
        
        //Product Attributes
        SVMXC__ServiceMax_Config_Data__c configData1 = new SVMXC__ServiceMax_Config_Data__c();
        configData1.SVMXC__Configuration_Type__c = 'PRODUCT_ATTRIBUTE';
        configData1.SVMXC__Dispatch_Process__c = SVMXProcess.Id;
        configData1.RecordTypeId = ExpressionsSrcUpdate_Rtype.Id;
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
        configData4.SVMXC__Configuration_Type__c = 'DOCUMENT_ATTRIBUTE';
        configData4.SVMXC__Dispatch_Process__c = SVMXProcess.Id;
        configData4.RecordTypeId = ExpressionsSrcUpdate_Rtype.Id;
        configData4.SVMXC__Field_Name__c = 'SVMXC__Billing_Type__c';
        configData4.SVMXC__Display_Type__c = 'PICKLIST';
        lstConfigData.add(configData4);
        insert lstConfigData;
        
        
        SVMXC__ServiceMax_Processes__c DeliveryRuleRec = new SVMXC__ServiceMax_Processes__c();
        DeliveryRuleRec.SVMXC__Sequence__c = 1;
        DeliveryRuleRec.SVMXC__Name__c = 'Delivery Rule';
        DeliveryRuleRec.SVMXC__Description__c = 'Test Description';
        DeliveryRuleRec.SVMXC__APL_Allow_Partial_Delivery__c = true;
        DeliveryRuleRec.SVMXC__Location__c = Loc1.Id;
        DeliveryRuleRec.SVMXC__Type__c = 'Automatic';
        DeliveryRuleRec.SVMXC__Default_Location__c = Loc2.Id;
        DeliveryRuleRec.RecordTypeId = DeliveryRule_RType.Id;
        insert DeliveryRuleRec;
        
        SVMXC__ServiceMax_Processes__c DeliveryRuleLineRec = new SVMXC__ServiceMax_Processes__c();
        DeliveryRuleLineRec.SVMXC__Sequence__c = 1;
        DeliveryRuleLineRec.SVMXC__Name__c = 'Delivery Rule Line 1';
        DeliveryRuleLineRec.SVMXC__Description__c = 'Delivery Rule Line 1 description';
        DeliveryRuleLineRec.SVMXC__Module__c = DeliveryRuleRec.Id;
        DeliveryRuleLineRec.RecordTypeId = ExpressionHeader_Rtype.Id;
        DeliveryRuleLineRec.SVMXC__Rule_Type__c = 'Delivery Rule Line';
        insert DeliveryRuleLineRec;
        
        List<SVMXC__ServiceMax_Config_Data__c> LstdeliveyrRuleExprns = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c ruleExp1 = new SVMXC__ServiceMax_Config_Data__c();
        ruleExp1.RecordTypeId = FieldMapping_Rtype.Id;
        ruleExp1.SVMXC__Object_Name__c = 'Account';
        ruleExp1.SVMXC__Sequence__c = 1;
        ruleExp1.SVMXC__Field_Name__c ='industry';
        ruleExp1.SVMXC__Operator__c = 'eq';
        ruleExp1.SVMXC__Operand__c = 'Hospitality';
        ruleExp1.SVMXC__Display_Type__c = 'STRING';
        ruleExp1.SVMXC__Expression_Rule__c = DeliveryRuleLineRec.Id;
        LstdeliveyrRuleExprns.add(ruleExp1);
        
        SVMXC__ServiceMax_Config_Data__c ruleExp2 = new SVMXC__ServiceMax_Config_Data__c();
        ruleExp2.SVMXC__Object_Name__c = 'Product2';
        ruleExp2.SVMXC__Sequence__c = 1;
        ruleExp2.SVMXC__Field_Name__c ='family';
        ruleExp2.SVMXC__Operator__c = 'eq';
        ruleExp2.SVMXC__Operand__c = 'Laptop';
        ruleExp2.SVMXC__Display_Type__c = 'STRING';
        ruleExp2.SVMXC__Expression_Rule__c = DeliveryRuleLineRec.Id;
        LstdeliveyrRuleExprns.add(ruleExp2);
        
        insert LstdeliveyrRuleExprns;
        
        SVMXC.APL_RMAUtils getDeliveryDetails = new SVMXC.APL_RMAUtils();
        getDeliveryDetails.getOrderLinesWithLocation(NULL, patrsOrder.id, SVMXProcess.id, 'PROCESSRECEIPT');
        
        Case objCase = new Case();
        insert objCase;
        
        SVMXC__Case_Line__c objCaseLine = new SVMXC__Case_Line__c();
        objCaseLine.SVMXC__Case__c = objCase.Id;
        insert objCaseLine;
        
        INTF_WebServicesDef.INTF_SFMRequest docGenRequest = new INTF_WebServicesDef.INTF_SFMRequest();
        docGenRequest.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        docGenRequest.valueMap.add(new INTF_WebServicesDef.SVMXMap('CaseID',objCase.Id));
        docGenRequest.valueMap.add(new INTF_WebServicesDef.SVMXMap('HeaderMapId',''));
        docGenRequest.valueMap.add(new INTF_WebServicesDef.SVMXMap('LineMapId',''));
        INTF_WebServicesDef.SVMXMap RMADet = new INTF_WebServicesDef.SVMXMap();
        RMADet.key = 'RMADetails';
        RMADet.value = partsLine1.Id;
        RMADet.values = new List<String>();
        RMADet.values.add(objCaseLine.id);
        docGenRequest.valueMap.add(RMADet);//new INTF_WebServicesDef.SVMXMap('RMADetails',partsLine1.Id));
        getDeliveryDetails.APL_GenerateRMADoc(docGenRequest);
        docGenRequest.valueMap.add(new INTF_WebServicesDef.SVMXMap('RMAId',patrsOrder .Id));
        getDeliveryDetails.APL_GenerateRMADoc(docGenRequest);
        
        SVMXC__Route_Card__c objRoute = new SVMXC__Route_Card__c();
        objRoute.SVMXC__Case__c = objCase.Id;
        objRoute.SVMXC__First_Stop__c = Loc1.Id;
        insert objRoute;
        
        INTF_WebServicesDef.INTF_SFMRequest docGenRequest1 = new INTF_WebServicesDef.INTF_SFMRequest();
        docGenRequest1.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        docGenRequest1.valueMap.add(new INTF_WebServicesDef.SVMXMap('CaseID',objCase.Id));
        getDeliveryDetails.APL_CalculateRMAFromCase(docGenRequest1);
        getDeliveryDetails.populateLocationforDelivery(LstorderLines, SVMXProcess, objAccount.Id);
        getDeliveryDetails.populateLocationforDelivery(LstorderLines, DeliveryRuleLineRec, objAccount.Id);
        
        List<SVMXC__RMA_Shipment_Order__c> lstForReciept = new List<SVMXC__RMA_Shipment_Order__c>();
        SVMXC__RMA_Shipment_Order__c objForReciept = new SVMXC__RMA_Shipment_Order__c();
        objForReciept.SVMXC__On_Hold__c = false;
        objForReciept.RecordTypeid = RMA.id;
        objForReciept.SVMXC__Destination_Location__c = Loc1.Id;
        lstForReciept.add(objForReciept);        
        insert lstForReciept;
        List<SVMXC__RMA_Shipment_Line__c> lstForRecieptLine = new List<SVMXC__RMA_Shipment_Line__c>();
        SVMXC__RMA_Shipment_Line__c objForRecieptLine = new SVMXC__RMA_Shipment_Line__c();
        objForRecieptLine.SVMXC__RMA_Shipment_Order__c = lstForReciept[0].id;
        lstForRecieptLine.add(objForRecieptLine);        
        insert lstForRecieptLine;
        List<String> lstALLLineIds = new List<String>();
        lstALLLineIds.add(lstForRecieptLine[0].id);
        
        INTF_WebServicesDef.INTF_SFMRequest docForRecipt = new INTF_WebServicesDef.INTF_SFMRequest();
        docForRecipt.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap objReqMap = new INTF_WebServicesDef.SVMXMap();
        objReqMap.key = 'REQUESTEDLINEIDS';
        objReqMap.value = lstForReciept[0].id;
        objReqMap.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        objReqMap.valueMap.add(new INTF_WebServicesDef.SVMXMap(lstForRecieptLine[0].id,''));
        docForRecipt.valueMap.add(objReqMap);
        getDeliveryDetails.performDeliveryOnReceipt(docForRecipt);
    }
}