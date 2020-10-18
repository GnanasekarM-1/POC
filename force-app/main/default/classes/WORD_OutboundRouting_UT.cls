@isTest
private  with sharing class WORD_OutboundRouting_UT
{
    static testMethod void WORD_OutboundRouting_UT_Test()
    {
        RecordType RT = [select id, Name from RecordType where Name = 'Outbound Route Calculation'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType RT1 = [select Id from RecordType where Name='SVMX Rule'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType RT2 = [select id, Name from RecordType where Name = 'Depot'and SobjectType='SVMXC__Site__c' Limit 1];
        RecordType RT3 = [select Id from RecordType where Name='Expressions'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        RecordType RT4 = [select Id from RecordType where Name='Route Stops'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        
        Account acc = new Account();
        acc.Name = 'Maxplore';
        insert acc;
        
        SVMXC__Site__c loc = new SVMXC__Site__c();
        loc.SVMXC__City__c = 'Bangalore';
        loc.RecordTypeId = RT2.Id;
        insert loc;
        
        SVMXC__Route_Card__c RC = new SVMXC__Route_Card__c();
        RC.SVMXC__Current_Stop__c = loc.Id;
        RC.SVMXC__Route_Type__c = 'Inbound';
        insert RC;
        
        Product2 product1 = new Product2();
        product1.Name = 'Laptop';
        insert product1;
        
        SVMXC__RMA_Shipment_Order__c ShpOrdr = new SVMXC__RMA_Shipment_Order__c();
        ShpOrdr.SVMXC__Company__c = acc.Id;
        ShpOrdr.SVMXC__Fulfillment_Type__c = 'Sales';
        ShpOrdr.SVMXC__On_Hold__c = false;
        insert ShpOrdr;
        
        SVMXC__RMA_Shipment_Line__c POLine = new SVMXC__RMA_Shipment_Line__c();
        POLine.SVMXC__Route_Card__c = RC.Id;
        POLine.SVMXC__RMA_Shipment_Order__c = ShpOrdr.Id;
        insert POLine;
        
        RC.SVMXC__RMA__c = ShpOrdr.Id;
        RC.SVMXC__RMA_Line__c = POLine.Id;
        update RC;
        
        SVMXC__Service_Order__c WO = new SVMXC__Service_Order__c();
        WO.SVMXC__Company__c = acc.Id;
        WO.SVMXC__Master_Order_Line__c = POLine.Id;
        WO.SVMXC__Product__c = product1.Id;
        WO.SVMXC__City__c = 'Bangalore';
        insert WO;
        
        POLine.SVMXC__Route_Card__c = RC.Id;
        update POLine;
        
        Set<ID> lstWOID = new Set<ID>();
        lstWOID.add(WO.Id);
        
        SVMXC__ServiceMax_Processes__c Exp = new SVMXC__ServiceMax_Processes__c();
        Exp.RecordTypeId = RT1.Id;
        Exp.SVMXC__ProcessID__c = 'Expression00001';
        Exp.SVMXC__Name__c = 'Expression00001';
        Exp.SVMXC__Parent_Object_Criteria__c = 'SVMXC__City__c = \'Bangalore\'';
        insert Exp;
        
        List<SVMXC__ServiceMax_Config_Data__c> LocExpLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c ConfigDataExp = new SVMXC__ServiceMax_Config_Data__c();
        ConfigDataExp.SVMXC__Dispatch_Process__c = Exp.id;
        ConfigDataExp.SVMXC__Sequence__c = 1.0000;
        ConfigDataExp.SVMXC__Operator__c = 'eq';
        ConfigDataExp.SVMXC__Operand__c = 'Bangalore';
        ConfigDataExp.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfigDataExp.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfigDataExp.SVMXC__Display_Type__c = 'STRING';
        ConfigDataExp.SVMXC__Active__c = true;
        ConfigDataExp.RecordTypeId = RT3.Id;
        LocExpLst.add(ConfigDataExp);
        
        insert LocExpLst;
        
        List<SVMXC__ServiceMax_Processes__c> lstOutbound = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c outboundRule = new SVMXC__ServiceMax_Processes__c();
        outboundRule.SVMXC__Name__c = 'Process00001';
        outboundRule.SVMXC__ProcessID__c = 'Process00001';
        outboundRule.RecordTypeId = RT.Id;
        outboundRule.SVMXC__Rule_Type__c ='Outbound Route Calculation';
        outboundRule.SVMXC__Location__c = loc.Id;
        outboundRule.SVMXC__Advance_Expression__c = '1 AND 2';
        outboundRule.SVMXC__Active__c = true;
        outboundRule.SVMXC__Node_Parent__c = Exp.Id;
        lstOutbound.add(outboundRule);
        insert lstOutbound;
        
        SVMXC__ServiceMax_Processes__c routingRule = new SVMXC__ServiceMax_Processes__c();
        routingRule.SVMXC__Name__c = 'Process00002';
        routingRule.SVMXC__ProcessID__c = 'Process00002';
        routingRule.RecordTypeId = RT1.Id;
        routingRule.SVMXC__Rule_Type__c ='Routing Rule';
        routingRule.SVMXC__Select__c = true;
        routingRule.SVMXC__APL_Route_Rule_Type__c = 'Outbound';
        routingRule.SVMXC__Active__c = true;
        routingRule.SVMXC__Sequence__c = 1.0000;
        insert routingRule;
        
        SVMXC__ServiceMax_Config_Data__c ConfigDataExp1 = new SVMXC__ServiceMax_Config_Data__c();
        ConfigDataExp1.SVMXC__Dispatch_Process__c = routingRule.id;
        ConfigDataExp1.SVMXC__Sequence__c = 1.0000;
        ConfigDataExp1.SVMXC__Operator__c = 'eq';
        ConfigDataExp1.SVMXC__Operand__c = 'Bangalore';
        ConfigDataExp1.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        ConfigDataExp1.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfigDataExp1.SVMXC__Display_Type__c = 'STRING';
        ConfigDataExp1.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        ConfigDataExp1.SVMXC__Active__c = true;
        ConfigDataExp1.RecordTypeId = RT3.Id;
        insert ConfigDataExp1;
        
        SVMXC__ServiceMax_Config_Data__c ConfigDataExp2 = new SVMXC__ServiceMax_Config_Data__c();
        ConfigDataExp2.SVMXC__Location__c = loc.id;
        ConfigDataExp2.SVMXC__Sequence__c = 1.0000;
        ConfigDataExp2.SVMXC__Dispatch_Process__c = routingRule.id;
        ConfigDataExp2.SVMXC__Select__c = true;
        ConfigDataExp2.SVMXC__Active__c = true;
        ConfigDataExp2.RecordTypeId = RT4.Id;
        insert ConfigDataExp2;
        
        WORD_OutboundRouting WOClass = new WORD_OutboundRouting(lstWOID);
    }
}