@isTest
private  with sharing class PORD_OutboundRouting_UT
{
    static testMethod void PORD_OutboundRouting_UT_Test()
    {
        RecordType RT = [select id, Name from RecordType where Name = 'Depot'and SobjectType='SVMXC__Site__c' Limit 1];
        RecordType RT1 = [select id, Name from RecordType where Name = 'Outbound Route Calculation'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType RT2 = [select Id from RecordType where Name='SVMX Rule'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType RT3 = [select Id from RecordType where Name='Expressions'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        RecordType RT4 = [select Id from RecordType where Name='Route Stops'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        
        List<SVMXC__Site__c> lstLoc = new List<SVMXC__Site__c>();
        SVMXC__Site__c loc = new SVMXC__Site__c();
        loc.RecordTypeId = RT.Id;
        loc.SVMXC__City__c = 'Bangalore';
        loc.SVMXC__Country__c = 'India';
        loc.SVMXC__Location_Type__c = 'Supplier';
        loc.Name = 'Depot1';
        lstLoc.add(loc);
        SVMXC__Site__c loc1 = new SVMXC__Site__c();
        loc1.RecordTypeId = RT.Id;
        loc1.SVMXC__City__c = 'Mysore';
        loc1.SVMXC__Country__c = 'India';
        loc1.SVMXC__Location_Type__c = 'Supplier';
        loc1.Name = 'Depot1';
        lstLoc.add(loc1);
        insert lstLoc;
        System.assert(lstLoc.size() == 2);
        
        List<SVMXC__ServiceMax_Processes__c> lstOutbound = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c outboundRule = new SVMXC__ServiceMax_Processes__c();
        outboundRule.SVMXC__Name__c = 'Process00001';
        outboundRule.SVMXC__ProcessID__c = 'Process00001';
        outboundRule.RecordTypeId = RT1.Id;
        outboundRule.SVMXC__Rule_Type__c ='Outbound Route Calculation';
        outboundRule.SVMXC__Parent_Object_Criteria__c = 'Name != null';
        outboundRule.SVMXC__Location__c = loc.Id;
        outboundRule.SVMXC__Active__c = true;
        outboundRule.SVMXC__Advance_Expression__c = '1 AND 2';
        lstOutbound.add(outboundRule);
        SVMXC__ServiceMax_Processes__c outboundRule1 = new SVMXC__ServiceMax_Processes__c();
        outboundRule1.SVMXC__Name__c = 'Process00003';
        outboundRule1.SVMXC__ProcessID__c = 'Process00003';
        outboundRule1.RecordTypeId = RT1.Id;
        outboundRule1.SVMXC__Active__c = true;
        outboundRule1.SVMXC__Rule_Type__c ='Outbound Route Calculation';
        outboundRule1.SVMXC__Location__c = loc1.Id;
        outboundRule1.SVMXC__Advance_Expression__c = '1 AND 2';
        lstOutbound.add(outboundRule1);
        insert lstOutbound;
        System.assert(lstOutbound.size() == 2);
        
        List<SVMXC__ServiceMax_Config_Data__c> expressionLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c expr1 = new SVMXC__ServiceMax_Config_Data__c();
        expr1.RecordTypeId = RT3.Id;
        expr1.SVMXC__Sequence__c = 1;
        expr1.SVMXC__Object_Name2__c = 'SVMXC__RMA_Shipment_Order__c';
        expr1.SVMXC__Field_Name__c = 'SVMXC__Company__c';
        expr1.SVMXC__Operator__c = 'isnotnull';
        expr1.SVMXC__Expression_Rule__c = outboundRule.Id;
        expr1.SVMXC__Expression_Type__c = 'EXP_Named';
        expressionLst.add(expr1);
        SVMXC__ServiceMax_Config_Data__c expr2 = new SVMXC__ServiceMax_Config_Data__c();
        expr2.RecordTypeId = RT3.Id;
        expr2.SVMXC__Sequence__c = 2;
        expr2.SVMXC__Object_Name2__c = 'SVMXC__RMA_Shipment_Line__c';
        expr2.SVMXC__Field_Name__c = 'SVMXC__Line_Status__c';
        expr2.SVMXC__Operator__c = 'eq';
        expr2.SVMXC__Operand__c = 'Open';
        expr2.SVMXC__Expression_Rule__c = outboundRule.Id;
        expr2.SVMXC__Expression_Type__c = 'EXP_Named';
        expressionLst.add(expr2);
        insert expressionLst;
        System.assert(expressionLst.size() == 2);
        
        List<Account> lstAcc = new List<Account>();
        Account acc= new Account();
        acc.Name = 'Maxplore';
        acc.Type = 'Installation Partner';
        lstAcc.add(acc);
        Account acc1= new Account();
        acc1.Name = 'ServiceMax';
        acc1.Type = 'Installation Partner';
        lstAcc.add(acc1);
        insert lstAcc;
        System.assert(lstAcc.size() == 2);
        
        List<Product2> lstProduct = new List<Product2>();
        Product2 prod1 = new Product2();
        prod1.Name = 'Software';
        lstProduct.add(prod1);
        
        Product2 prod2 = new Product2();
        prod2.Name = 'Hardware';
        lstProduct.add(prod2);
        insert lstProduct;
        System.assert(lstProduct.size() == 2);
        
        List<SVMXC__RMA_Shipment_Order__c> lstPO = new List<SVMXC__RMA_Shipment_Order__c>();
        SVMXC__RMA_Shipment_Order__c PO = new SVMXC__RMA_Shipment_Order__c();
        PO.SVMXC__RMA_Type__c = 'External';
        PO.SVMXC__On_Hold__c = false;
        PO.SVMXC__Destination_Location__c = loc.Id;
        PO.SVMXC__Company__c = acc.Id;
        lstPO.add(PO);
        
        SVMXC__RMA_Shipment_Order__c PO1 = new SVMXC__RMA_Shipment_Order__c();
        PO1.SVMXC__RMA_Type__c = 'External';
        PO1.SVMXC__On_Hold__c = false;
        PO1.SVMXC__Destination_Location__c = loc1.Id;
        PO1.SVMXC__Company__c = acc.Id;
        lstPO.add(PO1);
        
        SVMXC__RMA_Shipment_Order__c PO2 = new SVMXC__RMA_Shipment_Order__c();
        PO2.SVMXC__RMA_Type__c = 'External';
        PO2.SVMXC__On_Hold__c = false;
        PO2.SVMXC__Destination_Location__c = loc.Id;
        PO2.SVMXC__Company__c = acc1.Id;
        lstPO.add(PO2);
        insert lstPO;
        System.assert(lstPO.size() == 3);
        
        SVMXC__RMA_Shipment_Line__c POLine = new SVMXC__RMA_Shipment_Line__c();
        POLine.SVMXC__RMA_Shipment_Order__c = PO.Id;
        POLine.SVMXC__Line_Status__c = 'Open';
        POLine.SVMXC__Product__c = prod1.Id;
        POLine.SVMXC__Received__c = true;
        insert POLine;
        System.assert(POLine.id != null);
        
        SVMXC__Route_Card__c RC = new SVMXC__Route_Card__c();
        RC.SVMXC__Current_Stop__c = loc.Id;
        RC.SVMXC__Next_Stop__c = loc.Id;
        RC.SVMXC__Route_Type__c = 'Inbound';
        RC.SVMXC__RMA__c = PO.Id;
        RC.SVMXC__RMA_Line__c = POLine.Id;
        insert RC;
        System.assert(RC.id != null);
        
        List<SVMXC__RMA_Shipment_Line__c> lstPOLine = new List<SVMXC__RMA_Shipment_Line__c>();
        SVMXC__RMA_Shipment_Line__c POLine1 = new SVMXC__RMA_Shipment_Line__c();
        POLine1.SVMXC__RMA_Shipment_Order__c = PO1.Id;
        POLine1.SVMXC__Master_Order_Line__c = POLine.Id;
        POLine1.SVMXC__Line_Status__c = 'Open';
        POLine1.SVMXC__Product__c = prod1.Id;
        POLine1.SVMXC__Route_Card__c = RC.Id;
        POLine1.SVMXC__Received__c = true;
        lstPOLine.add(POLine1);
        SVMXC__RMA_Shipment_Line__c POLine2 = new SVMXC__RMA_Shipment_Line__c();
        POLine2.SVMXC__RMA_Shipment_Order__c = PO2.Id;
        POLine2.SVMXC__Master_Order_Line__c = POLine.Id;
        POLine2.SVMXC__Line_Status__c = 'Open';
        POLine2.SVMXC__Product__c = prod2.Id;
        POLine2.SVMXC__Received__c = true;
        lstPOLine.add(POLine2);
        insert lstPOLine;
        System.assert(lstPOLine.size() == 2);
        
        POLine.SVMXC__Route_Card__c = RC.Id;
        POLine.SVMXC__Master_Order_Line__c = POLine1.Id;
        update POLine;
        System.assert(POLine.SVMXC__Route_Card__c == RC.Id);
        System.assert(POLine.SVMXC__Master_Order_Line__c == POLine1.Id);
        
        List<SVMXC__ServiceMax_Processes__c> lstProcess = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c routingRule = new SVMXC__ServiceMax_Processes__c();
        routingRule.SVMXC__Name__c = 'Process00002';
        routingRule.SVMXC__ProcessID__c = 'Process00002';
        routingRule.RecordTypeId = RT2.Id;
        routingRule.SVMXC__Rule_Type__c ='Outbound Route Calculation';
        routingRule.SVMXC__Select__c = true;
        routingRule.SVMXC__APL_Route_Rule_Type__c = 'Outbound';
        routingRule.SVMXC__Active__c = true;
        routingRule.SVMXC__Sequence__c = 1.0000;
        lstProcess.add(routingRule);
        
        SVMXC__ServiceMax_Processes__c routingRule1 = new SVMXC__ServiceMax_Processes__c();
        routingRule1.SVMXC__Name__c = 'Process00004';
        routingRule1.SVMXC__ProcessID__c = 'Process00004';
        routingRule1.RecordTypeId = RT2.Id;
        routingRule1.SVMXC__Rule_Type__c ='Routing Rule';
        routingRule1.SVMXC__Select__c = true;
        routingRule1.SVMXC__APL_Route_Rule_Type__c = 'Outbound';
        routingRule1.SVMXC__Active__c = true;
        routingRule1.SVMXC__Sequence__c = 2.0000;
        lstProcess.add(routingRule1);
        insert lstProcess;
        System.assert(lstProcess.size() == 2);
        
        List<SVMXC__ServiceMax_Config_Data__c> LocExpLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c ConfigDataExp = new SVMXC__ServiceMax_Config_Data__c();
        ConfigDataExp.SVMXC__Dispatch_Process__c = routingRule.id;
        ConfigDataExp.SVMXC__Sequence__c = 1.0000;
        ConfigDataExp.SVMXC__Operator__c = 'eq';
        ConfigDataExp.SVMXC__Operand__c = 'Mysore';
        ConfigDataExp.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        ConfigDataExp.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfigDataExp.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        ConfigDataExp.SVMXC__Display_Type__c = 'STRING';
        ConfigDataExp.SVMXC__Active__c = true;
        ConfigDataExp.RecordTypeId = RT3.Id;
        LocExpLst.add(ConfigDataExp);
        
        SVMXC__ServiceMax_Config_Data__c ConfigDataExp1 = new SVMXC__ServiceMax_Config_Data__c();
        ConfigDataExp1.SVMXC__Dispatch_Process__c = routingRule.id;
        ConfigDataExp1.SVMXC__Sequence__c = 2.0000;
        ConfigDataExp1.SVMXC__Operator__c = 'eq';
        ConfigDataExp1.SVMXC__Operand__c = 'ServiceMax';
        ConfigDataExp1.SVMXC__Object_Name2__c = 'Account';
        ConfigDataExp1.SVMXC__Field_Name__c = 'Name';
        ConfigDataExp1.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        ConfigDataExp1.SVMXC__Display_Type__c = 'STRING';
        ConfigDataExp1.SVMXC__Active__c = true;
        ConfigDataExp1.RecordTypeId = RT3.Id;
        LocExpLst.add(ConfigDataExp1);
        
        SVMXC__ServiceMax_Config_Data__c ConfigDataExp3 = new SVMXC__ServiceMax_Config_Data__c();
        ConfigDataExp3.SVMXC__Dispatch_Process__c = routingRule.id;
        ConfigDataExp3.SVMXC__Sequence__c = 3.0000;
        ConfigDataExp3.SVMXC__Operator__c = 'eq';
        ConfigDataExp3.SVMXC__Operand__c = 'Hardware';
        ConfigDataExp3.SVMXC__Object_Name2__c = 'Product2';
        ConfigDataExp3.SVMXC__Field_Name__c = 'Name';
        ConfigDataExp3.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        ConfigDataExp3.SVMXC__Display_Type__c = 'STRING';
        ConfigDataExp3.SVMXC__Active__c = true;
        ConfigDataExp3.RecordTypeId = RT3.Id;
        LocExpLst.add(ConfigDataExp3);
        
        SVMXC__ServiceMax_Config_Data__c ConfigDataExp4 = new SVMXC__ServiceMax_Config_Data__c();
        ConfigDataExp4.SVMXC__Dispatch_Process__c = routingRule1.id;
        ConfigDataExp4.SVMXC__Sequence__c = 1.0000;
        ConfigDataExp4.SVMXC__Operator__c = 'eq';
        ConfigDataExp4.SVMXC__Operand__c = 'Bangalore';
        ConfigDataExp4.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        ConfigDataExp4.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfigDataExp4.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        ConfigDataExp4.SVMXC__Display_Type__c = 'STRING';
        ConfigDataExp4.SVMXC__Active__c = true;
        ConfigDataExp4.RecordTypeId = RT3.Id;
        LocExpLst.add(ConfigDataExp4);
        
        SVMXC__ServiceMax_Config_Data__c ConfigDataExp5 = new SVMXC__ServiceMax_Config_Data__c();
        ConfigDataExp5.SVMXC__Dispatch_Process__c = routingRule1.id;
        ConfigDataExp5.SVMXC__Sequence__c = 2.0000;
        ConfigDataExp5.SVMXC__Operator__c = 'eq';
        ConfigDataExp5.SVMXC__Operand__c = 'Maxplore';
        ConfigDataExp5.SVMXC__Object_Name2__c = 'Account';
        ConfigDataExp5.SVMXC__Field_Name__c = 'Name';
        ConfigDataExp5.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        ConfigDataExp5.SVMXC__Display_Type__c = 'STRING';
        ConfigDataExp5.SVMXC__Active__c = true;
        ConfigDataExp5.RecordTypeId = RT3.Id;
        LocExpLst.add(ConfigDataExp5);
        
        SVMXC__ServiceMax_Config_Data__c ConfigDataExp6 = new SVMXC__ServiceMax_Config_Data__c();
        ConfigDataExp6.SVMXC__Dispatch_Process__c = routingRule1.id;
        ConfigDataExp6.SVMXC__Sequence__c = 3.0000;
        ConfigDataExp6.SVMXC__Operator__c = 'eq';
        ConfigDataExp6.SVMXC__Operand__c = 'Software';
        ConfigDataExp6.SVMXC__Object_Name2__c = 'Product2';
        ConfigDataExp6.SVMXC__Field_Name__c = 'Name';
        ConfigDataExp6.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        ConfigDataExp6.SVMXC__Display_Type__c = 'STRING';
        ConfigDataExp6.SVMXC__Active__c = true;
        ConfigDataExp6.RecordTypeId = RT3.Id;
        LocExpLst.add(ConfigDataExp6);
        
        SVMXC__ServiceMax_Config_Data__c ConfigDataExp2 = new SVMXC__ServiceMax_Config_Data__c();
        ConfigDataExp2.SVMXC__Location__c = loc.id;
        ConfigDataExp2.SVMXC__Sequence__c = 1.0000;
        ConfigDataExp2.SVMXC__Dispatch_Process__c = routingRule.id;
        ConfigDataExp2.SVMXC__Select__c = true;
        ConfigDataExp2.SVMXC__Active__c = true;
        ConfigDataExp2.RecordTypeId = RT4.Id;
        LocExpLst.add(ConfigDataExp2);
        
        SVMXC__ServiceMax_Config_Data__c ConfigDataExp7 = new SVMXC__ServiceMax_Config_Data__c();
        ConfigDataExp7.SVMXC__Location__c = loc1.id;
        ConfigDataExp7.SVMXC__Sequence__c = 1.0000;
        ConfigDataExp7.SVMXC__Dispatch_Process__c = routingRule1.id;
        ConfigDataExp7.SVMXC__Select__c = true;
        ConfigDataExp7.SVMXC__Active__c = true;
        ConfigDataExp7.RecordTypeId = RT4.Id;
        LocExpLst.add(ConfigDataExp7);
        insert LocExpLst;
        System.assert(LocExpLst.size() == 8);
        
        Test.startTest();
        PORD_OutboundRouting outboundRoute = new PORD_OutboundRouting();
        outboundRoute.outboundRouteCalculation(lstPO);
        
        Test.stopTest();
        
        ////////coverage of 'if' part line no 109
        SVMXC__RMA_Shipment_Order__c objShipOrder = [SELECT id,SVMXC__Destination_Location__c FROM SVMXC__RMA_Shipment_Order__c WHERE id =: PO2.id];
        objShipOrder.SVMXC__Destination_Location__c = null;
        update objShipOrder;
        System.assert(objShipOrder.SVMXC__Destination_Location__c == null);
        outboundRoute.outboundRouteCalculation(lstPO);
        
        String strMsg = 'Error Find in Outbound Routing';
        String emailID = 'manish.kushwah@servicemax.com';
        PORD_OutboundRouting.failureStatusEmail(strMsg, emailID);
    }
}