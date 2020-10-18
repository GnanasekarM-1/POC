@isTest(SeeAllData=true)
private class APL_Utils_UT   
{
    static testMethod void APL_Utils_test()
    {
        Account a = new Account();
        a.name = 'ABC';
        insert a;
        list<Sobject> listSobjet = new list<Sobject>();
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Company__c = a.id;
        insert wo;
        listSobjet.add(wo);
        RecordType ShippingProcess_Rtype = [select Id from RecordType where Name='Shipping Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpressionsSrcUpdate_Rtype = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        SVMXC__RMA_Shipment_Order__c patrsOrder = new SVMXC__RMA_Shipment_Order__c();
        
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Processes__c SVMXProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXProcess.RecordTypeId = ShippingProcess_Rtype.Id;
        SVMXProcess.SVMXC__Name__c = 'Shipping Process';
        SVMXProcess.SVMXC__Description__c = 'Shipping Process';
        SVMXProcess.SVMXC__Active__c = true;
        insert SVMXProcess;
        
        //Create Source update Records....
        list<SVMXC__ServiceMax_Config_Data__c> SourceUpdatesRec = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c config1 = new SVMXC__ServiceMax_Config_Data__c(); 
        config1.RecordTypeId = ExpressionsSrcUpdate_Rtype.id;
        config1.SVMXC__Dispatch_Process__c = SVMXProcess.id;
        config1.SVMXC__Target_Field_Name__c = 'SVMXC__Company__c';//Reference
        config1.SVMXC__Action__c = 'Set';
        config1.SVMXC__Display_Value__c = a.id;
        config1.SVMXC__Sequence__c = 1;
        SourceUpdatesRec.add(config1);
        
        SVMXC__ServiceMax_Config_Data__c config2 = new SVMXC__ServiceMax_Config_Data__c(); 
        config2.RecordTypeId = ExpressionsSrcUpdate_Rtype.id;
        config2.SVMXC__Dispatch_Process__c = SVMXProcess.id;
        config2.SVMXC__Target_Field_Name__c = 'SVMXC__Billing_Type__c';//PICKLIST 
        config2.SVMXC__Display_Value__c = 'Contract';
        config2.SVMXC__Action__c = 'Set';
        config2.SVMXC__Sequence__c = 2;
        SourceUpdatesRec.add(config2);
        
        SVMXC__ServiceMax_Config_Data__c config5 = new SVMXC__ServiceMax_Config_Data__c(); 
        config5.RecordTypeId = ExpressionsSrcUpdate_Rtype.id;
        config5.SVMXC__Dispatch_Process__c = SVMXProcess.id;
        config5.SVMXC__Target_Field_Name__c = 'SVMXC__Apply_Business_Hours_For_OptiMax__c';//checkbox 
        config5.SVMXC__Display_Value__c = 'True';
        config5.SVMXC__Action__c = 'Set';
        config5.SVMXC__Sequence__c = 3;
        SourceUpdatesRec.add(config5);
        
        SVMXC__ServiceMax_Config_Data__c config6 = new SVMXC__ServiceMax_Config_Data__c(); 
        config6.RecordTypeId = ExpressionsSrcUpdate_Rtype.id;
        config6.SVMXC__Dispatch_Process__c = SVMXProcess.id;
        config6.SVMXC__Target_Field_Name__c = 'SVMXC__Actual_Resolution__c';//Date-Time 
        config6.SVMXC__Display_Value__c = 'TODAY';
        config6.SVMXC__Action__c = 'Set';
        config6.SVMXC__Sequence__c = 4;
        SourceUpdatesRec.add(config6);
        
        SVMXC__ServiceMax_Config_Data__c config7 = new SVMXC__ServiceMax_Config_Data__c(); 
        config7.RecordTypeId = ExpressionsSrcUpdate_Rtype.id;
        config7.SVMXC__Dispatch_Process__c = SVMXProcess.id;
        config7.SVMXC__Target_Field_Name__c = 'SVMXC__Actual_Resolution__c';//Date-Time 
        config7.SVMXC__Display_Value__c = 'TOMORROW';
        config7.SVMXC__Action__c = 'Set';
        config7.SVMXC__Sequence__c = 5;
        SourceUpdatesRec.add(config7);
        
        SVMXC__ServiceMax_Config_Data__c config8 = new SVMXC__ServiceMax_Config_Data__c(); 
        config8.RecordTypeId = ExpressionsSrcUpdate_Rtype.id;
        config8.SVMXC__Dispatch_Process__c = SVMXProcess.id;
        config8.SVMXC__Target_Field_Name__c = 'SVMXC__Actual_Resolution__c';//Date-Time 
        config8.SVMXC__Display_Value__c = 'YESTERDAY';
        config8.SVMXC__Action__c = 'Set';
        config8.SVMXC__Sequence__c = 6;
        SourceUpdatesRec.add(config8);
        
        SVMXC__ServiceMax_Config_Data__c config9 = new SVMXC__ServiceMax_Config_Data__c(); 
        config9.RecordTypeId = ExpressionsSrcUpdate_Rtype.id;
        config9.SVMXC__Dispatch_Process__c = SVMXProcess.id;
        config9.SVMXC__Target_Field_Name__c = 'SVMXC__Actual_Resolution__c';//Date-Time 
        config9.SVMXC__Display_Value__c = string.valueof(system.now());
        config9.SVMXC__Action__c = 'Set';
        config9.SVMXC__Sequence__c = 7;
        SourceUpdatesRec.add(config9);
        
        SVMXC__ServiceMax_Config_Data__c config10 = new SVMXC__ServiceMax_Config_Data__c(); 
        config10.RecordTypeId = ExpressionsSrcUpdate_Rtype.id;
        config10.SVMXC__Dispatch_Process__c = SVMXProcess.id;
        config10.SVMXC__Target_Field_Name__c = 'SVMXC__Scheduled_Date__c';//Date
        config10.SVMXC__Display_Value__c = 'YESTERDAY';
        config10.SVMXC__Action__c = 'Set';
        config10.SVMXC__Sequence__c = 8;
        SourceUpdatesRec.add(config10);
        
        SVMXC__ServiceMax_Config_Data__c config11 = new SVMXC__ServiceMax_Config_Data__c(); 
        config11.RecordTypeId = ExpressionsSrcUpdate_Rtype.id;
        config11.SVMXC__Dispatch_Process__c = SVMXProcess.id;
        config11.SVMXC__Target_Field_Name__c = 'SVMXC__Scheduled_Date__c';//Date
        config11.SVMXC__Display_Value__c = 'TODAY';
        config11.SVMXC__Action__c = 'Set';
        config11.SVMXC__Sequence__c = 9;
        SourceUpdatesRec.add(config11);
        
        SVMXC__ServiceMax_Config_Data__c config12 = new SVMXC__ServiceMax_Config_Data__c(); 
        config12.RecordTypeId = ExpressionsSrcUpdate_Rtype.id;
        config12.SVMXC__Dispatch_Process__c = SVMXProcess.id;
        config12.SVMXC__Target_Field_Name__c = 'SVMXC__Scheduled_Date__c';//Date 
        config12.SVMXC__Display_Value__c = 'TOMORROW';
        config12.SVMXC__Action__c = 'Set';
        config12.SVMXC__Sequence__c = 10;
        SourceUpdatesRec.add(config12);
        
        SVMXC__ServiceMax_Config_Data__c config13 = new SVMXC__ServiceMax_Config_Data__c(); 
        config13.RecordTypeId = ExpressionsSrcUpdate_Rtype.id;
        config13.SVMXC__Dispatch_Process__c = SVMXProcess.id;
        config13.SVMXC__Target_Field_Name__c = 'SVMXC__Scheduled_Date__c';//Date
        config13.SVMXC__Display_Value__c = String.valueof(system.today());
        config13.SVMXC__Action__c = 'Set';
        config13.SVMXC__Sequence__c = 11;
        SourceUpdatesRec.add(config13);
        
        SVMXC__ServiceMax_Config_Data__c config14 = new SVMXC__ServiceMax_Config_Data__c(); 
        config14.RecordTypeId = ExpressionsSrcUpdate_Rtype.id;
        config14.SVMXC__Dispatch_Process__c = SVMXProcess.id;
        config14.SVMXC__Target_Field_Name__c = 'SVMXC__Driving_Time__c';//Double
        config14.SVMXC__Display_Value__c = '12.334';
        config14.SVMXC__Action__c = 'Set';
        config14.SVMXC__Sequence__c = 12;
        SourceUpdatesRec.add(config14);
        
        SVMXC__ServiceMax_Config_Data__c config3 = new SVMXC__ServiceMax_Config_Data__c(); 
        config3.RecordTypeId = ExpressionsSrcUpdate_Rtype.id;
        config3.SVMXC__Dispatch_Process__c = SVMXProcess.id;
        config3.SVMXC__Target_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Days__c';
        config3.SVMXC__Display_Value__c = '1';
        config3.SVMXC__Action__c = 'INCREASE';
        config3.SVMXC__Sequence__c = 13;
        SourceUpdatesRec.add(config3);
        
        SVMXC__ServiceMax_Config_Data__c config4 = new SVMXC__ServiceMax_Config_Data__c(); 
        config4.RecordTypeId = ExpressionsSrcUpdate_Rtype.id;
        config4.SVMXC__Dispatch_Process__c = SVMXProcess.id;
        config4.SVMXC__Target_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Days__c';
        config4.SVMXC__Display_Value__c = '1';
        config4.SVMXC__Action__c = 'DECREASE';
        config4.SVMXC__Sequence__c = 14;
        SourceUpdatesRec.add(config4);
        
        SVMXC__ServiceMax_Config_Data__c config122 = new SVMXC__ServiceMax_Config_Data__c(); 
        config122.RecordTypeId = ExpressionsSrcUpdate_Rtype.id;
        config122.SVMXC__Dispatch_Process__c = SVMXProcess.id;
        config122.SVMXC__Target_Field_Name__c = 'SVMXC__Scheduled_Date__c';//Date 
        config122.SVMXC__Display_Value__c = 'TOMORROW';
        config122.SVMXC__Action__c = 'NOW';
        config122.SVMXC__Sequence__c = 15;
        SourceUpdatesRec.add(config122);
        
        SVMXC__ServiceMax_Config_Data__c config15 = new SVMXC__ServiceMax_Config_Data__c(); 
        config15.RecordTypeId = ExpressionsSrcUpdate_Rtype.id;
        config15.SVMXC__Dispatch_Process__c = SVMXProcess.id;
        config15.SVMXC__Target_Field_Name__c = 'SVMXC__Actual_Resolution__c';//Date-Time 
        config15.SVMXC__Display_Value__c = 'NOW';
        config15.SVMXC__Action__c = 'Set';
        config15.SVMXC__Sequence__c = 16;
        SourceUpdatesRec.add(config15);
        
        SVMXC__ServiceMax_Config_Data__c config16 = new SVMXC__ServiceMax_Config_Data__c(); 
        config16.RecordTypeId = ExpressionsSrcUpdate_Rtype.id;
        config16.SVMXC__Dispatch_Process__c = SVMXProcess.id;
        config16.SVMXC__Target_Field_Name__c = 'SVMXC__Schedule_Days__c';//Multi-Picklist 
        config16.SVMXC__Display_Value__c = 'MultiPicklist';
        config16.SVMXC__Action__c = 'Set';
        config16.SVMXC__Sequence__c = 17;
        SourceUpdatesRec.add(config16);
        
        SVMXC__ServiceMax_Config_Data__c config17 = new SVMXC__ServiceMax_Config_Data__c(); 
        config17.RecordTypeId = ExpressionsSrcUpdate_Rtype.id;
        config17.SVMXC__Dispatch_Process__c = SVMXProcess.id;
        config17.SVMXC__Target_Field_Name__c = 'Invalid';
        config17.SVMXC__Display_Value__c = 'Invalid';
        config17.SVMXC__Action__c = 'Set';
        config17.SVMXC__Sequence__c = 18;
        SourceUpdatesRec.add(config17);
        
        
        insert SourceUpdatesRec;
        map<String,Schema.SObjectField> mapWOFldDesc = new map<String,Schema.SObjectField>();
        map<String,Schema.SObjectField> mapTempH = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap();
        if(mapTempH.size() > 0)
        {
            for(String s : mapTempH.keyset())
            {
                mapWOFldDesc.put(mapTempH.get(s).getDescribe().getName(),mapTempH.get(s));
            }
        }
        SVMXC.APL_Utils sourceupdate = new SVMXC.APL_Utils();
        sourceupdate.DoSourceUpdate(listSobjet,SourceUpdatesRec,mapWOFldDesc);
        
        Account acc = new Account(Name = 'ABC', NumberOfEmployees=1);
        insert acc;
        sObject s1 = new Account(Name = 'Acc001', NumberOfEmployees=2);
        upsert s1;
        sObject s2 = new Product2(Name = 'PROD001');
        upsert s2;
        sObject s3 = new SVMXC__Site__c(Name = 'Bangalore', SVMXC__City__c = 'Bangalore', SVMXC__Email__c = 'a@b.com', SVMXC__Zip__c = '1111111111', SVMXC__Stocking_Location__c = true, SVMXC__Latitude__c = 123456, SVMXC__Account__c = acc.Id);
        upsert s3;
        
        map<string, sObject> lstRec = new map<string, sObject>();
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapRulesExpressions = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        mapRulesExpressions.put(SVMXProcess.Id, SourceUpdatesRec);
        
        map<Id, SVMXC__ServiceMax_Processes__c> mapRules = new map<Id, SVMXC__ServiceMax_Processes__c>();
        mapRules.put(SVMXProcess.Id, SVMXProcess);
        
        lstRec.put('Account', s1);
        lstRec.put('Product2', s2);
        lstRec.put('SVMXC__Site__c', s3);
        sourceupdate.SVMX_ExpressionParsing(lstRec,mapRulesExpressions,mapRules);
        
        RecordType RTDepot = [select id, Name from RecordType where Name='Depot' and SobjectType = 'SVMXC__Site__c' limit 1];
        RecordType RTDepotChild = [select id, Name from RecordType where Name='Depot Child' and SobjectType = 'SVMXC__Site__c' limit 1];
        RecordType RTOutboundRule = [select Id from RecordType where Name='Outbound Route Calculation'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType RTConfDataFieldMap = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        
        SVMXC__Site__c loclocloc = new SVMXC__Site__c();
        loclocloc.RecordTypeId = RTDepot.Id;
        loclocloc.Name = 'Jaipur';
        insert loclocloc;
        
        SVMXC__Site__c locloclocChild = new SVMXC__Site__c();
        locloclocChild.RecordTypeId = RTDepotChild.Id;
        locloclocChild.SVMXC__Parent__c = loclocloc.Id;
        locloclocChild.Name = 'JaipurChild';
        locloclocChild.SVMXC__Stocking_Location__c = true;
        insert locloclocChild;
        
        Product2 prod = new Product2();
        prod.Name = 'Laptop';
        insert prod;
        
        SVMXC__Product_Stock__c prodStock = new SVMXC__Product_Stock__c();
        prodStock.SVMXC__Status__c = 'Available';
        prodStock.SVMXC__Product__c =  prod.Id;
        prodStock.SVMXC__Location__c = locloclocChild.Id;
        insert prodStock;
        
        SVMXC__Product_Serial__c prodSerial = new SVMXC__Product_Serial__c();
        prodSerial.SVMXC__Product_Stock__c = prodStock.Id;
        insert prodSerial;
        
        SVMXC__RMA_Shipment_Order__c PO = new SVMXC__RMA_Shipment_Order__c();
        insert PO;
        
        SVMXC__ServiceMax_Processes__c pro = new SVMXC__ServiceMax_Processes__c();
        pro.SVMXC__ProcessID__c = 'Process000000001'; 
        pro.SVMXC__Name__c = 'Process000000001'; 
        pro.RecordTypeId = RTOutboundRule.Id;
        insert pro;
        
        List<SVMXC__ServiceMax_Config_Data__c> lstConfData = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c confData1 = new SVMXC__ServiceMax_Config_Data__c();
        confData1.RecordTypeId = RTConfDataFieldMap.Id;
        confData1.SVMXC__Dispatch_Process__c = pro.Id;
        confData1.SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_RECEIPT';
        lstConfData.add(confData1);
        SVMXC__ServiceMax_Config_Data__c confData2 = new SVMXC__ServiceMax_Config_Data__c();
        confData2.RecordTypeId = RTConfDataFieldMap.Id;
        confData2.SVMXC__Dispatch_Process__c = pro.Id;
        confData2.SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_DELIVERY';
        lstConfData.add(confData2);
        SVMXC__ServiceMax_Config_Data__c confData3 = new SVMXC__ServiceMax_Config_Data__c();
        confData3.RecordTypeId = RTConfDataFieldMap.Id;
        confData3.SVMXC__Dispatch_Process__c = pro.Id;
        confData3.SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_PICKING';
        lstConfData.add(confData3);
        SVMXC__ServiceMax_Config_Data__c confData4 = new SVMXC__ServiceMax_Config_Data__c();
        confData4.RecordTypeId = RTConfDataFieldMap.Id;
        confData4.SVMXC__Dispatch_Process__c = pro.Id;
        confData4.SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_SHIP';
        lstConfData.add(confData4);
        insert lstConfData;
        
        APL_Utils utilObj = new APL_Utils();
        List<SVMXC.INTF_WebServicesDef.SVMXMap> valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
        SVMXC.INTF_WebServicesDef.SVMXMap map1 = new SVMXC.INTF_WebServicesDef.SVMXMap('DEPOTNAME', loclocloc.Id);
        valueMap.add(map1);
        SVMXC.INTF_WebServicesDef.SVMXMap map2 = new SVMXC.INTF_WebServicesDef.SVMXMap('PRODUCTID', prod.Id);
        valueMap.add(map2);
        SVMXC.INTF_WebServicesDef.SVMXMap map3 = new SVMXC.INTF_WebServicesDef.SVMXMap('SVMX_RECORDID', PO.Id);
        valueMap.add(map3);
        SVMXC.INTF_WebServicesDef.SVMXMap map4 = new SVMXC.INTF_WebServicesDef.SVMXMap('SVMX_PROCESSID', pro.Id);
        valueMap.add(map4);
        
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest request = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        request.valueMap = valueMap;
        utilObj.getAvailableStockSerial(request);
        
        valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
        map3 = new SVMXC.INTF_WebServicesDef.SVMXMap('SVMX_RECORDID', PO.Id);
        valueMap.add(map3);
        map4 = new SVMXC.INTF_WebServicesDef.SVMXMap('SVMX_PROCESSID', pro.Id);
        valueMap.add(map4);
        SVMXC.INTF_WebServicesDef.SVMXMap map5 = new SVMXC.INTF_WebServicesDef.SVMXMap('SVMX_PROCESSTYPE', 'PROCESSRECEIPT');
        valueMap.add(map5);
        request.valueMap = valueMap;
        utilObj.PartsOrderClosure(request);
        
        valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
        map3 = new SVMXC.INTF_WebServicesDef.SVMXMap('SVMX_RECORDID', PO.Id);
        valueMap.add(map3);
        map4 = new SVMXC.INTF_WebServicesDef.SVMXMap('SVMX_PROCESSID', pro.Id);
        valueMap.add(map4);
        SVMXC.INTF_WebServicesDef.SVMXMap map6 = new SVMXC.INTF_WebServicesDef.SVMXMap('SVMX_PROCESSTYPE', 'DELIVERYONRECEIPT');
        valueMap.add(map6);
        request.valueMap = valueMap;
        utilObj.PartsOrderClosure(request);
        
        valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
        map3 = new SVMXC.INTF_WebServicesDef.SVMXMap('SVMX_RECORDID', PO.Id);
        valueMap.add(map3);
        map4 = new SVMXC.INTF_WebServicesDef.SVMXMap('SVMX_PROCESSID', pro.Id);
        valueMap.add(map4);
        SVMXC.INTF_WebServicesDef.SVMXMap map7 = new SVMXC.INTF_WebServicesDef.SVMXMap('SVMX_PROCESSTYPE', 'PICKNMOVE');
        valueMap.add(map7);
        request.valueMap = valueMap;
        utilObj.PartsOrderClosure(request);
        
        valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
        map3 = new SVMXC.INTF_WebServicesDef.SVMXMap('SVMX_RECORDID', PO.Id);
        valueMap.add(map3);
        map4 = new SVMXC.INTF_WebServicesDef.SVMXMap('SVMX_PROCESSID', pro.Id);
        valueMap.add(map4);
        SVMXC.INTF_WebServicesDef.SVMXMap map8 = new SVMXC.INTF_WebServicesDef.SVMXMap('SVMX_PROCESSTYPE', 'SHIPCONFIRM');
        valueMap.add(map8);
        request.valueMap = valueMap;
        utilObj.PartsOrderClosure(request);
    }
    static testMethod void APL_Utils_test1()
    {
        List<RecordType> LstConfigRType = new List<RecordType>(); 
        String StrConfigExpId = ''; 
        String StrConfigStopId = ''; 
        LstConfigRType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        for(RecordType r : LstConfigRType)
        {
            if(r.Name == 'Expressions')
                StrConfigExpId = r.id;
             if(r.Name == 'Route Stops')
                StrConfigStopId = r.id;
        }   
        List<RecordType> LstProcessRType = new List<RecordType>(); 
        String StrSVMXRuleId = ''; 
        LstProcessRType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='SVMX Rule' ];
        StrSVMXRuleId = LstProcessRType[0].Id;
        
        SVMXC.APL_Utils sourceupdate = new SVMXC.APL_Utils();
        map<string, sObject> lstRec = new map<string, sObject>();
        List<SVMXC__ServiceMax_Config_Data__c> lstExpressions = new List<SVMXC__ServiceMax_Config_Data__c>();
        string AdvExp = '';
        Account acc = new Account(Name = 'ABC', NumberOfEmployees=1);
        insert acc;
        //sObject s1 = new Account(Name = 'Acc001', AccountNumber = '123456');
        sObject s1 = new Account(Name = 'Acc001', NumberOfEmployees=2);
        upsert s1;
        sObject s2 = new Product2(Name = 'PROD001');
        upsert s2;
        sObject s3 = new SVMXC__Site__c(Name = 'Bangalore', SVMXC__City__c = 'Bangalore', SVMXC__Email__c = 'a@b.com', SVMXC__Zip__c = '1111111111', SVMXC__Stocking_Location__c = true, SVMXC__Latitude__c = 123456, SVMXC__Account__c = acc.Id);
        upsert s3;
        
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapRulesExpressions = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        map<Id, SVMXC__ServiceMax_Processes__c> mapRules = new map<Id, SVMXC__ServiceMax_Processes__c>();
        lstRec.put('Account', s1);
        lstRec.put('Product2', s2);
        lstRec.put('SVMXC__Site__c', s3);
        sourceupdate.SVMX_ExpressionParsing(lstRec,mapRulesExpressions,mapRules);
        sourceupdate.SVMX_ExpressionParsing(lstRec, lstExpressions, AdvExp);
        String StrExpQuery = ''; 
        lstExpressions.clear();
        
        SVMXC__ServiceMax_Processes__c objProcess = new SVMXC__ServiceMax_Processes__c();
        objProcess.SVMXC__Active__c= true;
        objProcess.SVMXC__APL_Route_Rule_Type__c = 'inbound';
        objProcess.SVMXC__Name__C = 'ProcessObj1';
        objProcess.RecordTypeId = StrSVMXRuleId;
        objProcess.SVMXC__Rule_Type__c = 'Routing Rule';
        objProcess.SVMXC__Advance_Expression__c = '1 AND 2';
        upsert objProcess;
        
        SVMXC__ServiceMax_Processes__c objProcess1 = new SVMXC__ServiceMax_Processes__c();
        objProcess1.SVMXC__Active__c= true;
        objProcess1.SVMXC__APL_Route_Rule_Type__c = 'Outbound';
        objProcess1.SVMXC__Name__C = 'ProcessObj2';
        objProcess1.RecordTypeId = StrSVMXRuleId;
        objProcess1.SVMXC__Rule_Type__c = 'Routing Rule';
        objProcess1.SVMXC__Advance_Expression__c = '1 AND 2';
        upsert objProcess1;
        
        SVMXC__Site__c loc = new SVMXC__Site__c();
        loc.SVMXC__City__c = 'Bangalore';
        upsert loc;
        
        SVMXC__Site__c loc1 = new SVMXC__Site__c();
        loc1.SVMXC__City__c = 'Manglore';
        upsert loc1;
        
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c config1 = new SVMXC__ServiceMax_Config_Data__c(); 
        config1.SVMXC__Dispatch_Process__c = objProcess1.id;
        config1.SVMXC__Location__c = loc.Id;
        config1.SVMXC__Sequence__c = 4;
        config1.RecordTypeId = StrConfigStopId;
        lstConfigData.add(config1);
        
        SVMXC__ServiceMax_Config_Data__c config2 = new SVMXC__ServiceMax_Config_Data__c(); 
        config2.SVMXC__Dispatch_Process__c = objProcess1.id;
        config2.SVMXC__Location__c = loc1.Id;
        config2.SVMXC__Sequence__c = 3;
        config2.RecordTypeId = StrConfigStopId;
        lstConfigData.add(config2);
        upsert lstConfigData;
        
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData1 = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c config3 = new SVMXC__ServiceMax_Config_Data__c(); 
        config3.RecordTypeId = StrConfigExpId;
        config3.SVMXC__Dispatch_Process__c = objProcess1.id;
        config3.SVMXC__Sequence__c = 1;
        config3.SVMXC__Field_Name__c = 'Name';
        config3.SVMXC__Operator__c = 'EQ';
        config3.SVMXC__Operand__c = 'Bangalore';
        config3.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config3.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config3.SVMXC__Display_Type__c  = 'String';
        config3.RecordTypeId = StrConfigExpId;
        config3.SVMXC__Field_Relationship_Name__c = '';
        lstConfigData1.add(config3);
        
        SVMXC__ServiceMax_Config_Data__c config4 = new SVMXC__ServiceMax_Config_Data__c(); 
        config4.RecordTypeId = StrConfigExpId;
        config4.SVMXC__Dispatch_Process__c = objProcess1.id;
        config4.SVMXC__Sequence__c = 2;
        config4.SVMXC__Field_Name__c = 'SVMXC__City__c';
        config4.SVMXC__Operator__c = 'CONTAINS';
        config4.SVMXC__Operand__c = 'Manglore';
        config4.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config4.SVMXC__Field_Relationship_Name__c = '';
        config4.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config4.SVMXC__Display_Type__c  = 'String';
        config4.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config4);
        
        SVMXC__ServiceMax_Config_Data__c config5 = new SVMXC__ServiceMax_Config_Data__c(); 
        config5.RecordTypeId = StrConfigExpId;
        config5.SVMXC__Dispatch_Process__c = objProcess1.id;
        config5.SVMXC__Sequence__c = 5;
        config5.SVMXC__Field_Name__c = 'Name';
        config5.SVMXC__Operator__c = 'STARTS';
        config5.SVMXC__Operand__c = 'a@b.com';
        config5.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config5.SVMXC__Field_Relationship_Name__c = '';
        config5.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config5.SVMXC__Display_Type__c  = 'String';
        config5.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config5);
        
        SVMXC__ServiceMax_Config_Data__c config6 = new SVMXC__ServiceMax_Config_Data__c(); 
        config6.RecordTypeId = StrConfigExpId;
        config6.SVMXC__Dispatch_Process__c = objProcess1.id;
        config6.SVMXC__Sequence__c = 6;
        config6.SVMXC__Field_Name__c = 'Name';
        config6.SVMXC__Operator__c = 'ISNOTNULL';
        config6.SVMXC__Operand__c = 'Manglore';
        config6.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config6.SVMXC__Field_Relationship_Name__c = '';
        config6.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config6.SVMXC__Display_Type__c  = 'String';
        config6.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config6);
        
        SVMXC__ServiceMax_Config_Data__c config7 = new SVMXC__ServiceMax_Config_Data__c(); 
        config7.RecordTypeId = StrConfigExpId;
        config7.SVMXC__Dispatch_Process__c = objProcess1.id;
        config7.SVMXC__Sequence__c = 7;
        config7.SVMXC__Field_Name__c = 'Name';
        config7.SVMXC__Operator__c = 'NOTCONTAINS';
        config7.SVMXC__Operand__c = 'aaaaaaaaaaaaaaaaaaaaaaaaaaa';
        config7.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config7.SVMXC__Field_Relationship_Name__c = '';
        config7.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config7.SVMXC__Display_Type__c  = 'String';
        config7.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config7);
        
        SVMXC__ServiceMax_Config_Data__c config8 = new SVMXC__ServiceMax_Config_Data__c(); 
        config8.RecordTypeId = StrConfigExpId;
        config8.SVMXC__Dispatch_Process__c = objProcess1.id;
        config8.SVMXC__Sequence__c = 8;
        config8.SVMXC__Field_Name__c = 'Name';
        config8.SVMXC__Operator__c = 'IN';
        config8.SVMXC__Operand__c = 'aaaaaaaaaaaaaaaa';
        config8.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config8.SVMXC__Field_Relationship_Name__c = '';
        config8.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config8.SVMXC__Display_Type__c  = 'String';
        config8.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config8);
        
        SVMXC__ServiceMax_Config_Data__c config81 = new SVMXC__ServiceMax_Config_Data__c(); 
        config81.RecordTypeId = StrConfigExpId;
        config81.SVMXC__Dispatch_Process__c = objProcess1.id;
        config81.SVMXC__Sequence__c = 9;
        config81.SVMXC__Field_Name__c = 'Name';
        config81.SVMXC__Operator__c = 'ISNULL';
        config81.SVMXC__Operand__c = 'aaaaaaaaaaaaaaaa';
        config81.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config81.SVMXC__Field_Relationship_Name__c = '';
        config81.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config81.SVMXC__Display_Type__c  = 'String';
        config81.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config81);
        
        SVMXC__ServiceMax_Config_Data__c config82 = new SVMXC__ServiceMax_Config_Data__c(); 
        config82.RecordTypeId = StrConfigExpId;
        config82.SVMXC__Dispatch_Process__c = objProcess1.id;
        config82.SVMXC__Sequence__c = 10;
        config82.SVMXC__Field_Name__c = 'Name';
        config82.SVMXC__Operator__c = 'NE';
        config82.SVMXC__Operand__c = 'aaaaaaaaaaaaaaaa';
        config82.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config82.SVMXC__Field_Relationship_Name__c = '';
        config82.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config82.SVMXC__Display_Type__c  = 'String';
        config82.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config82);
        
        SVMXC__ServiceMax_Config_Data__c config9 = new SVMXC__ServiceMax_Config_Data__c(); 
        config9.RecordTypeId = StrConfigExpId;
        config9.SVMXC__Dispatch_Process__c = objProcess1.id;
        config9.SVMXC__Sequence__c = 11;
        config9.SVMXC__Field_Name__c = 'SVMXC__Stocking_Location__c';
        config9.SVMXC__Operator__c = 'EQ';
        config9.SVMXC__Operand__c = 'true';
        config9.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config9.SVMXC__Field_Relationship_Name__c = '';
        config9.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config9.SVMXC__Display_Type__c  = 'Boolean';
        config9.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config9);
        
        SVMXC__ServiceMax_Config_Data__c config91 = new SVMXC__ServiceMax_Config_Data__c(); 
        config91.RecordTypeId = StrConfigExpId;
        config91.SVMXC__Dispatch_Process__c = objProcess1.id;
        config91.SVMXC__Sequence__c = 12;
        config91.SVMXC__Field_Name__c = 'SVMXC__Stocking_Location__c';
        config91.SVMXC__Operator__c = 'ISNULL';
        config91.SVMXC__Operand__c = 'true';
        config91.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config91.SVMXC__Field_Relationship_Name__c = '';
        config91.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config91.SVMXC__Display_Type__c  = 'Boolean';
        config91.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config91);
        
        SVMXC__ServiceMax_Config_Data__c config92 = new SVMXC__ServiceMax_Config_Data__c(); 
        config92.RecordTypeId = StrConfigExpId;
        config92.SVMXC__Dispatch_Process__c = objProcess1.id;
        config92.SVMXC__Sequence__c = 13;
        config92.SVMXC__Field_Name__c = 'SVMXC__Stocking_Location__c';
        config92.SVMXC__Operator__c = 'ISNOTNULL';
        config92.SVMXC__Operand__c = 'true';
        config92.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config92.SVMXC__Field_Relationship_Name__c = '';
        config92.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config92.SVMXC__Display_Type__c  = 'Boolean';
        config92.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config92);
        
        SVMXC__ServiceMax_Config_Data__c config10 = new SVMXC__ServiceMax_Config_Data__c(); 
        config10.RecordTypeId = StrConfigExpId;
        config10.SVMXC__Dispatch_Process__c = objProcess1.id;
        config10.SVMXC__Sequence__c = 14;
        config10.SVMXC__Field_Name__c = 'SVMXC__Stocking_Location__c';
        config10.SVMXC__Operator__c = 'NE';
        config10.SVMXC__Operand__c = 'true';
        config10.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config10.SVMXC__Field_Relationship_Name__c = '';
        config10.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config10.SVMXC__Display_Type__c  = 'Boolean';
        config10.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config10);
        
        SVMXC__ServiceMax_Config_Data__c config11 = new SVMXC__ServiceMax_Config_Data__c(); 
        config11.RecordTypeId = StrConfigExpId;
        config11.SVMXC__Dispatch_Process__c = objProcess1.id;
        config11.SVMXC__Sequence__c = 15;
        config11.SVMXC__Field_Name__c = 'SVMXC__Latitude__c';
        config11.SVMXC__Operator__c = 'EQ';
        config11.SVMXC__Operand__c = '123456';
        config11.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config11.SVMXC__Field_Relationship_Name__c = '';
        config11.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config11.SVMXC__Display_Type__c  = 'INTEGER';
        config11.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config11);
        
        SVMXC__ServiceMax_Config_Data__c config12 = new SVMXC__ServiceMax_Config_Data__c(); 
        config12.RecordTypeId = StrConfigExpId;
        config12.SVMXC__Dispatch_Process__c = objProcess1.id;
        config12.SVMXC__Sequence__c = 16;
        config12.SVMXC__Field_Name__c = 'SVMXC__Latitude__c';
        config12.SVMXC__Operator__c = 'GT';
        config12.SVMXC__Operand__c = '123456';
        config12.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config12.SVMXC__Field_Relationship_Name__c = '';
        config12.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config12.SVMXC__Display_Type__c  = 'INTEGER';
        config12.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config12);
        
        SVMXC__ServiceMax_Config_Data__c config121 = new SVMXC__ServiceMax_Config_Data__c(); 
        config121.RecordTypeId = StrConfigExpId;
        config121.SVMXC__Dispatch_Process__c = objProcess1.id;
        config121.SVMXC__Sequence__c = 17;
        config121.SVMXC__Field_Name__c = 'SVMXC__Latitude__c';
        config121.SVMXC__Operator__c = 'ISNULL';
        config121.SVMXC__Operand__c = '123456';
        config121.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config121.SVMXC__Field_Relationship_Name__c = '';
        config121.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config121.SVMXC__Display_Type__c  = 'INTEGER';
        config121.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config121);
        
        SVMXC__ServiceMax_Config_Data__c config122 = new SVMXC__ServiceMax_Config_Data__c(); 
        config122.RecordTypeId = StrConfigExpId;
        config122.SVMXC__Dispatch_Process__c = objProcess1.id;
        config122.SVMXC__Sequence__c = 18;
        config122.SVMXC__Field_Name__c = 'SVMXC__Latitude__c';
        config122.SVMXC__Operator__c = 'ISNOTNULL';
        config122.SVMXC__Operand__c = '123456';
        config122.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config122.SVMXC__Field_Relationship_Name__c = '';
        config122.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config122.SVMXC__Display_Type__c  = 'INTEGER';
        config122.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config122);
        
        SVMXC__ServiceMax_Config_Data__c config123 = new SVMXC__ServiceMax_Config_Data__c(); 
        config123.RecordTypeId = StrConfigExpId;
        config123.SVMXC__Dispatch_Process__c = objProcess1.id;
        config123.SVMXC__Sequence__c = 19;
        config123.SVMXC__Field_Name__c = 'SVMXC__Latitude__c';
        config123.SVMXC__Operator__c = 'LE';
        config123.SVMXC__Operand__c = '123456';
        config123.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config123.SVMXC__Field_Relationship_Name__c = '';
        config123.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config123.SVMXC__Display_Type__c  = 'INTEGER';
        config123.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config123);
        
        SVMXC__ServiceMax_Config_Data__c config124 = new SVMXC__ServiceMax_Config_Data__c(); 
        config124.RecordTypeId = StrConfigExpId;
        config124.SVMXC__Dispatch_Process__c = objProcess1.id;
        config124.SVMXC__Sequence__c = 20;
        config124.SVMXC__Field_Name__c = 'SVMXC__Latitude__c';
        config124.SVMXC__Operator__c = 'GE';
        config124.SVMXC__Operand__c = '123456';
        config124.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config124.SVMXC__Field_Relationship_Name__c = '';
        config124.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config124.SVMXC__Display_Type__c  = 'INTEGER';
        config124.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config124);
        
        SVMXC__ServiceMax_Config_Data__c config13 = new SVMXC__ServiceMax_Config_Data__c(); 
        /* config13.RecordTypeId = StrConfigExpId;
        config13.SVMXC__Dispatch_Process__c = objProcess1.id;
        config13.SVMXC__Sequence__c = 11;
        config13.SVMXC__Field_Name__c = 'SVMXC__Account__c';
        config13.SVMXC__Operator__c = 'ISNOTNULL';
        config13.SVMXC__Operand__c = '';
        config13.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config13.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config13.SVMXC__Display_Type__c  = 'Reference';
        config13.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config13); */
        
        SVMXC__ServiceMax_Config_Data__c config14 = new SVMXC__ServiceMax_Config_Data__c(); 
        config14.RecordTypeId = StrConfigExpId;
        config14.SVMXC__Dispatch_Process__c = objProcess1.id;
        config14.SVMXC__Sequence__c = 21;
        config14.SVMXC__Field_Name__c = 'NumberOfEmployees';
        config14.SVMXC__Operator__c = 'EQ';
        config14.SVMXC__Operand__c = '123456';
        config14.SVMXC__Object_Name2__c = 'Account';
        config14.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config14.SVMXC__Display_Type__c  = 'INTEGER';
        config14.SVMXC__Field_Relationship_Name__c = '';
        config14.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config14);
        
        SVMXC__ServiceMax_Config_Data__c config15 = new SVMXC__ServiceMax_Config_Data__c(); 
        config15.RecordTypeId = StrConfigExpId;
        config15.SVMXC__Dispatch_Process__c = objProcess1.id;
        config15.SVMXC__Sequence__c = 22;
        config15.SVMXC__Field_Name__c = 'NumberOfEmployees';
        config15.SVMXC__Operator__c = 'LT';
        config15.SVMXC__Operand__c = '123654';
        config15.SVMXC__Object_Name2__c = 'Account';
        config15.SVMXC__Field_Relationship_Name__c = '';
        config15.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config15.SVMXC__Display_Type__c  = 'INTEGER';
        config15.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config15);
        
        
        SVMXC__ServiceMax_Config_Data__c config16 = new SVMXC__ServiceMax_Config_Data__c(); 
        config16.RecordTypeId = StrConfigExpId;
        config16.SVMXC__Dispatch_Process__c = objProcess1.id;
        config16.SVMXC__Sequence__c = 23;
        config16.SVMXC__Field_Name__c = 'NumberOfEmployees';
        config16.SVMXC__Operator__c = 'IN';
        config16.SVMXC__Operand__c = '123654';
        config16.SVMXC__Object_Name2__c = 'Account';
        config16.SVMXC__Field_Relationship_Name__c = '';
        config16.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config16.SVMXC__Display_Type__c  = 'INTEGER';
        config16.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config16);
        
        SVMXC__ServiceMax_Config_Data__c config17 = new SVMXC__ServiceMax_Config_Data__c(); 
        config17.RecordTypeId = StrConfigExpId;
        config17.SVMXC__Dispatch_Process__c = objProcess1.id;
        config17.SVMXC__Sequence__c = 24;
        config17.SVMXC__Field_Name__c = 'NumberOfEmployees';
        config17.SVMXC__Operator__c = 'NOTIN';
        config17.SVMXC__Operand__c = '123654';
        config17.SVMXC__Object_Name2__c = 'Account';
        config17.SVMXC__Field_Relationship_Name__c = '';
        config17.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config17.SVMXC__Display_Type__c  = 'INTEGER';
        config17.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config17);
        
        
                SVMXC__ServiceMax_Config_Data__c config211 = new SVMXC__ServiceMax_Config_Data__c(); 
        config211.RecordTypeId = StrConfigExpId;
        config211.SVMXC__Dispatch_Process__c = objProcess1.id;
        config211.SVMXC__Sequence__c = 25;
        config211.SVMXC__Field_Name__c = 'SVMXC__Latitude__c';
        config211.SVMXC__Operator__c = 'EQ';
        config211.SVMXC__Operand__c = '123456';
        config211.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config211.SVMXC__Field_Relationship_Name__c = '';
        config211.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config211.SVMXC__Display_Type__c  = 'CURRENCY';
        config211.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config211);
        
        SVMXC__ServiceMax_Config_Data__c config212 = new SVMXC__ServiceMax_Config_Data__c(); 
        config212.RecordTypeId = StrConfigExpId;
        config212.SVMXC__Dispatch_Process__c = objProcess1.id;
        config212.SVMXC__Sequence__c = 26;
        config212.SVMXC__Field_Name__c = 'SVMXC__Latitude__c';
        config212.SVMXC__Operator__c = 'GT';
        config212.SVMXC__Operand__c = '123456';
        config212.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config212.SVMXC__Field_Relationship_Name__c = '';
        config212.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config212.SVMXC__Display_Type__c  = 'CURRENCY';
        config212.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config212);
        
        SVMXC__ServiceMax_Config_Data__c config221 = new SVMXC__ServiceMax_Config_Data__c(); 
        config221.RecordTypeId = StrConfigExpId;
        config221.SVMXC__Dispatch_Process__c = objProcess1.id;
        config221.SVMXC__Sequence__c = 27;
        config221.SVMXC__Field_Name__c = 'SVMXC__Latitude__c';
        config221.SVMXC__Operator__c = 'ISNULL';
        config221.SVMXC__Operand__c = '123456';
        config221.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config221.SVMXC__Field_Relationship_Name__c = '';
        config221.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config221.SVMXC__Display_Type__c  = 'CURRENCY';
        config221.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config221);
        
        SVMXC__ServiceMax_Config_Data__c config213 = new SVMXC__ServiceMax_Config_Data__c(); 
        config213.RecordTypeId = StrConfigExpId;
        config213.SVMXC__Dispatch_Process__c = objProcess1.id;
        config213.SVMXC__Sequence__c = 28;
        config213.SVMXC__Field_Name__c = 'SVMXC__Latitude__c';
        config213.SVMXC__Operator__c = 'ISNOTNULL';
        config213.SVMXC__Operand__c = '123456';
        config213.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config213.SVMXC__Field_Relationship_Name__c = '';
        config213.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config213.SVMXC__Display_Type__c  = 'CURRENCY';
        config213.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config213);
        
        SVMXC__ServiceMax_Config_Data__c config214 = new SVMXC__ServiceMax_Config_Data__c(); 
        config214.RecordTypeId = StrConfigExpId;
        config214.SVMXC__Dispatch_Process__c = objProcess1.id;
        config214.SVMXC__Sequence__c = 29;
        config214.SVMXC__Field_Name__c = 'SVMXC__Latitude__c';
        config214.SVMXC__Operator__c = 'LE';
        config214.SVMXC__Operand__c = '123456';
        config214.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config214.SVMXC__Field_Relationship_Name__c = '';
        config214.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config214.SVMXC__Display_Type__c  = 'CURRENCY';
        config214.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config214);
        
        SVMXC__ServiceMax_Config_Data__c config215 = new SVMXC__ServiceMax_Config_Data__c(); 
        config215.RecordTypeId = StrConfigExpId;
        config215.SVMXC__Dispatch_Process__c = objProcess1.id;
        config215.SVMXC__Sequence__c = 30;
        config215.SVMXC__Field_Name__c = 'SVMXC__Latitude__c';
        config215.SVMXC__Operator__c = 'GE';
        config215.SVMXC__Operand__c = '123456';
        config215.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config215.SVMXC__Field_Relationship_Name__c = '';
        config215.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config215.SVMXC__Display_Type__c  = 'CURRENCY';
        config215.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config215);        
        
        SVMXC__ServiceMax_Config_Data__c config216 = new SVMXC__ServiceMax_Config_Data__c(); 
        config216.RecordTypeId = StrConfigExpId;
        config216.SVMXC__Dispatch_Process__c = objProcess1.id;
        config216.SVMXC__Sequence__c = 31;
        config216.SVMXC__Field_Name__c = 'NumberOfEmployees';
        config216.SVMXC__Operator__c = 'EQ';
        config216.SVMXC__Operand__c = '123456';
        config216.SVMXC__Object_Name2__c = 'Account';
        config216.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config216.SVMXC__Display_Type__c  = 'CURRENCY';
        config216.SVMXC__Field_Relationship_Name__c = '';
        config216.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config216);
        
        SVMXC__ServiceMax_Config_Data__c config217 = new SVMXC__ServiceMax_Config_Data__c(); 
        config217.RecordTypeId = StrConfigExpId;
        config217.SVMXC__Dispatch_Process__c = objProcess1.id;
        config217.SVMXC__Sequence__c = 32;
        config217.SVMXC__Field_Name__c = 'NumberOfEmployees';
        config217.SVMXC__Operator__c = 'LT';
        config217.SVMXC__Operand__c = '123654';
        config217.SVMXC__Object_Name2__c = 'Account';
        config217.SVMXC__Field_Relationship_Name__c = '';
        config217.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config217.SVMXC__Display_Type__c  = 'CURRENCY';
        config217.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config217);
        
        SVMXC__ServiceMax_Config_Data__c config218 = new SVMXC__ServiceMax_Config_Data__c(); 
        config218.RecordTypeId = StrConfigExpId;
        config218.SVMXC__Dispatch_Process__c = objProcess1.id;
        config218.SVMXC__Sequence__c = 33;
        config218.SVMXC__Field_Name__c = 'NumberOfEmployees';
        config218.SVMXC__Operator__c = 'NOTIN';
        config218.SVMXC__Operand__c = '123654';
        config218.SVMXC__Object_Name2__c = 'Account';
        config218.SVMXC__Field_Relationship_Name__c = '';
        config218.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config218.SVMXC__Display_Type__c  = 'CURRENCY';
        config218.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config218);
                
        
        SVMXC__ServiceMax_Config_Data__c config219 = new SVMXC__ServiceMax_Config_Data__c(); 
        config219.RecordTypeId = StrConfigExpId;
        config219.SVMXC__Dispatch_Process__c = objProcess1.id;
        config219.SVMXC__Sequence__c = 34;
        config219.SVMXC__Field_Name__c = 'NumberOfEmployees';
        config219.SVMXC__Operator__c = 'ISNULL';
        config219.SVMXC__Operand__c = '123654';
        config219.SVMXC__Object_Name2__c = 'Account';
        config219.SVMXC__Field_Relationship_Name__c = '';
        config219.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config219.SVMXC__Display_Type__c  = 'CURRENCY';
        config219.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config219);
        
        SVMXC__ServiceMax_Config_Data__c config220 = new SVMXC__ServiceMax_Config_Data__c(); 
        config220.RecordTypeId = StrConfigExpId;
        config220.SVMXC__Dispatch_Process__c = objProcess1.id;
        config220.SVMXC__Sequence__c = 35;
        config220.SVMXC__Field_Name__c = 'NumberOfEmployees';
        config220.SVMXC__Operator__c = 'ISNOTNULL';
        config220.SVMXC__Operand__c = '123654';
        config220.SVMXC__Object_Name2__c = 'Account';
        config220.SVMXC__Field_Relationship_Name__c = '';
        config220.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config220.SVMXC__Display_Type__c  = 'CURRENCY';
        config220.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config220);
        
        SVMXC__ServiceMax_Config_Data__c config311 = new SVMXC__ServiceMax_Config_Data__c(); 
        config311.RecordTypeId = StrConfigExpId;
        config311.SVMXC__Dispatch_Process__c = objProcess1.id;
        config311.SVMXC__Sequence__c = 36;
        config311.SVMXC__Field_Name__c = 'SVMXC__Latitude__c';
        config311.SVMXC__Operator__c = 'EQ';
        config311.SVMXC__Operand__c = '123456';
        config311.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config311.SVMXC__Field_Relationship_Name__c = '';
        config311.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config311.SVMXC__Display_Type__c  = 'DOUBLE';
        config311.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config311);
        
        SVMXC__ServiceMax_Config_Data__c config312 = new SVMXC__ServiceMax_Config_Data__c(); 
        config312.RecordTypeId = StrConfigExpId;
        config312.SVMXC__Dispatch_Process__c = objProcess1.id;
        config312.SVMXC__Sequence__c = 37;
        config312.SVMXC__Field_Name__c = 'SVMXC__Latitude__c';
        config312.SVMXC__Operator__c = 'GT';
        config312.SVMXC__Operand__c = '123456';
        config312.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config312.SVMXC__Field_Relationship_Name__c = '';
        config312.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config312.SVMXC__Display_Type__c  = 'DOUBLE';
        config312.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config312);
        
        SVMXC__ServiceMax_Config_Data__c config231 = new SVMXC__ServiceMax_Config_Data__c(); 
        config231.RecordTypeId = StrConfigExpId;
        config231.SVMXC__Dispatch_Process__c = objProcess1.id;
        config231.SVMXC__Sequence__c = 38;
        config231.SVMXC__Field_Name__c = 'SVMXC__Latitude__c';
        config231.SVMXC__Operator__c = 'ISNULL';
        config231.SVMXC__Operand__c = '123456';
        config231.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config231.SVMXC__Field_Relationship_Name__c = '';
        config231.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config231.SVMXC__Display_Type__c  = 'DOUBLE';
        config231.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config231);
        
        SVMXC__ServiceMax_Config_Data__c config313 = new SVMXC__ServiceMax_Config_Data__c(); 
        config313.RecordTypeId = StrConfigExpId;
        config313.SVMXC__Dispatch_Process__c = objProcess1.id;
        config313.SVMXC__Sequence__c = 39;
        config313.SVMXC__Field_Name__c = 'SVMXC__Latitude__c';
        config313.SVMXC__Operator__c = 'ISNOTNULL';
        config313.SVMXC__Operand__c = '123456';
        config313.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config313.SVMXC__Field_Relationship_Name__c = '';
        config313.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config313.SVMXC__Display_Type__c  = 'DOUBLE';
        config313.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config313);
        
        SVMXC__ServiceMax_Config_Data__c config314 = new SVMXC__ServiceMax_Config_Data__c(); 
        config314.RecordTypeId = StrConfigExpId;
        config314.SVMXC__Dispatch_Process__c = objProcess1.id;
        config314.SVMXC__Sequence__c = 40;
        config314.SVMXC__Field_Name__c = 'SVMXC__Latitude__c';
        config314.SVMXC__Operator__c = 'LE';
        config314.SVMXC__Operand__c = '123456';
        config314.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config314.SVMXC__Field_Relationship_Name__c = '';
        config314.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config314.SVMXC__Display_Type__c  = 'DOUBLE';
        config314.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config314);
        
        SVMXC__ServiceMax_Config_Data__c config315 = new SVMXC__ServiceMax_Config_Data__c(); 
        config315.RecordTypeId = StrConfigExpId;
        config315.SVMXC__Dispatch_Process__c = objProcess1.id;
        config315.SVMXC__Sequence__c = 41;
        config315.SVMXC__Field_Name__c = 'SVMXC__Latitude__c';
        config315.SVMXC__Operator__c = 'GE';
        config315.SVMXC__Operand__c = '123456';
        config315.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config315.SVMXC__Field_Relationship_Name__c = '';
        config315.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config315.SVMXC__Display_Type__c  = 'DOUBLE';
        config315.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config315);        
        
        SVMXC__ServiceMax_Config_Data__c config316 = new SVMXC__ServiceMax_Config_Data__c(); 
        config316.RecordTypeId = StrConfigExpId;
        config316.SVMXC__Dispatch_Process__c = objProcess1.id;
        config316.SVMXC__Sequence__c = 42;
        config316.SVMXC__Field_Name__c = 'NumberOfEmployees';
        config316.SVMXC__Operator__c = 'EQ';
        config316.SVMXC__Operand__c = '123456';
        config316.SVMXC__Object_Name2__c = 'Account';
        config316.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config316.SVMXC__Display_Type__c  = 'DOUBLE';
        config316.SVMXC__Field_Relationship_Name__c = '';
        config316.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config316);
        
        SVMXC__ServiceMax_Config_Data__c config317 = new SVMXC__ServiceMax_Config_Data__c(); 
        config317.RecordTypeId = StrConfigExpId;
        config317.SVMXC__Dispatch_Process__c = objProcess1.id;
        config317.SVMXC__Sequence__c = 43;
        config317.SVMXC__Field_Name__c = 'NumberOfEmployees';
        config317.SVMXC__Operator__c = 'LT';
        config317.SVMXC__Operand__c = '123654';
        config317.SVMXC__Object_Name2__c = 'Account';
        config317.SVMXC__Field_Relationship_Name__c = '';
        config317.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config317.SVMXC__Display_Type__c  = 'DOUBLE';
        config317.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config317);
        
	SVMXC__ServiceMax_Config_Data__c config318 = new SVMXC__ServiceMax_Config_Data__c(); 
	config318.RecordTypeId = StrConfigExpId;
	config318.SVMXC__Dispatch_Process__c = objProcess1.id;
	config318.SVMXC__Sequence__c = 44;
	config318.SVMXC__Field_Name__c = 'NumberOfEmployees';
	config318.SVMXC__Operator__c = 'NOTIN';
	config318.SVMXC__Operand__c = '123654';
	config318.SVMXC__Object_Name2__c = 'Account';
	config318.SVMXC__Field_Relationship_Name__c = '';
	config318.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
	config318.SVMXC__Display_Type__c  = 'DOUBLE';
	config318.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config318);
        
        
        
        SVMXC__ServiceMax_Config_Data__c config319 = new SVMXC__ServiceMax_Config_Data__c(); 
        config319.RecordTypeId = StrConfigExpId;
        config319.SVMXC__Dispatch_Process__c = objProcess1.id;
        config319.SVMXC__Sequence__c = 45;
        config319.SVMXC__Field_Name__c = 'NumberOfEmployees';
        config319.SVMXC__Operator__c = 'NOTIN';
        config319.SVMXC__Operand__c = '123654';
        config319.SVMXC__Object_Name2__c = 'Account';
        config319.SVMXC__Field_Relationship_Name__c = '';
        config319.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config319.SVMXC__Display_Type__c  = 'DOUBLE';
        config319.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config319);
        
        
        SVMXC__ServiceMax_Config_Data__c config320 = new SVMXC__ServiceMax_Config_Data__c(); 
		config320.RecordTypeId = StrConfigExpId;
		config320.SVMXC__Dispatch_Process__c = objProcess1.id;
		config320.SVMXC__Sequence__c = 46;
		config320.SVMXC__Field_Name__c = 'NumberOfEmployees';
		config320.SVMXC__Operator__c = 'ISNOTNULL';
		config320.SVMXC__Operand__c = '123654';
		config320.SVMXC__Object_Name2__c = 'Account';
		config320.SVMXC__Field_Relationship_Name__c = '';
		config320.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
		config320.SVMXC__Display_Type__c  = 'DOUBLE';
		config320.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config320);
        
        config311 = new SVMXC__ServiceMax_Config_Data__c(); 
        config311.RecordTypeId = StrConfigExpId;
        config311.SVMXC__Dispatch_Process__c = objProcess1.id;
        config311.SVMXC__Sequence__c = 141;
        config311.SVMXC__Field_Name__c = 'SVMXC__Latitude__c';
        config311.SVMXC__Operator__c = 'EQ';
        config311.SVMXC__Operand__c = '123456';
        config311.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config311.SVMXC__Field_Relationship_Name__c = '';
        config311.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config311.SVMXC__Display_Type__c  = 'DECIMAL';
        config311.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config311);
        
        config312 = new SVMXC__ServiceMax_Config_Data__c(); 
        config312.RecordTypeId = StrConfigExpId;
        config312.SVMXC__Dispatch_Process__c = objProcess1.id;
        config312.SVMXC__Sequence__c = 102;
        config312.SVMXC__Field_Name__c = 'SVMXC__Latitude__c';
        config312.SVMXC__Operator__c = 'GT';
        config312.SVMXC__Operand__c = '123456';
        config312.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config312.SVMXC__Field_Relationship_Name__c = '';
        config312.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config312.SVMXC__Display_Type__c  = 'DECIMAL';
        config312.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config312);
        
        config231 = new SVMXC__ServiceMax_Config_Data__c(); 
        config231.RecordTypeId = StrConfigExpId;
        config231.SVMXC__Dispatch_Process__c = objProcess1.id;
        config231.SVMXC__Sequence__c = 103;
        config231.SVMXC__Field_Name__c = 'SVMXC__Latitude__c';
        config231.SVMXC__Operator__c = 'ISNULL';
        config231.SVMXC__Operand__c = '123456';
        config231.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config231.SVMXC__Field_Relationship_Name__c = '';
        config231.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config231.SVMXC__Display_Type__c  = 'DECIMAL';
        config231.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config231);
        
        config313 = new SVMXC__ServiceMax_Config_Data__c(); 
        config313.RecordTypeId = StrConfigExpId;
        config313.SVMXC__Dispatch_Process__c = objProcess1.id;
        config313.SVMXC__Sequence__c = 104;
        config313.SVMXC__Field_Name__c = 'SVMXC__Latitude__c';
        config313.SVMXC__Operator__c = 'ISNOTNULL';
        config313.SVMXC__Operand__c = '123456';
        config313.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config313.SVMXC__Field_Relationship_Name__c = '';
        config313.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config313.SVMXC__Display_Type__c  = 'DECIMAL';
        config313.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config313);
        
        config314 = new SVMXC__ServiceMax_Config_Data__c(); 
        config314.RecordTypeId = StrConfigExpId;
        config314.SVMXC__Dispatch_Process__c = objProcess1.id;
        config314.SVMXC__Sequence__c = 105;
        config314.SVMXC__Field_Name__c = 'SVMXC__Latitude__c';
        config314.SVMXC__Operator__c = 'LE';
        config314.SVMXC__Operand__c = '123456';
        config314.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config314.SVMXC__Field_Relationship_Name__c = '';
        config314.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config314.SVMXC__Display_Type__c  = 'DECIMAL';
        config314.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config314);
        
        config315 = new SVMXC__ServiceMax_Config_Data__c(); 
        config315.RecordTypeId = StrConfigExpId;
        config315.SVMXC__Dispatch_Process__c = objProcess1.id;
        config315.SVMXC__Sequence__c = 106;
        config315.SVMXC__Field_Name__c = 'SVMXC__Latitude__c';
        config315.SVMXC__Operator__c = 'GE';
        config315.SVMXC__Operand__c = '123456';
        config315.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        config315.SVMXC__Field_Relationship_Name__c = '';
        config315.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config315.SVMXC__Display_Type__c  = 'DECIMAL';
        config315.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config315);        
        
        config316 = new SVMXC__ServiceMax_Config_Data__c(); 
        config316.RecordTypeId = StrConfigExpId;
        config316.SVMXC__Dispatch_Process__c = objProcess1.id;
        config316.SVMXC__Sequence__c = 127;
        config316.SVMXC__Field_Name__c = 'NumberOfEmployees';
        config316.SVMXC__Operator__c = 'EQ';
        config316.SVMXC__Operand__c = '123456';
        config316.SVMXC__Object_Name2__c = 'Account';
        config316.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config316.SVMXC__Display_Type__c  = 'DECIMAL';
        config316.SVMXC__Field_Relationship_Name__c = '';
        config316.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config316);
        
        config317 = new SVMXC__ServiceMax_Config_Data__c(); 
        config317.RecordTypeId = StrConfigExpId;
        config317.SVMXC__Dispatch_Process__c = objProcess1.id;
        config317.SVMXC__Sequence__c = 138;
        config317.SVMXC__Field_Name__c = 'NumberOfEmployees';
        config317.SVMXC__Operator__c = 'LT';
        config317.SVMXC__Operand__c = '123654';
        config317.SVMXC__Object_Name2__c = 'Account';
        config317.SVMXC__Field_Relationship_Name__c = '';
        config317.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config317.SVMXC__Display_Type__c  = 'DECIMAL';
        config317.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config317);
        
	config318 = new SVMXC__ServiceMax_Config_Data__c(); 
	config318.RecordTypeId = StrConfigExpId;
	config318.SVMXC__Dispatch_Process__c = objProcess1.id;
	config318.SVMXC__Sequence__c = 139;
	config318.SVMXC__Field_Name__c = 'NumberOfEmployees';
	config318.SVMXC__Operator__c = 'NOTIN';
	config318.SVMXC__Operand__c = '123654';
	config318.SVMXC__Object_Name2__c = 'Account';
	config318.SVMXC__Field_Relationship_Name__c = '';
	config318.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
	config318.SVMXC__Display_Type__c  = 'DECIMAL';
	config318.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config318);
        
        
        
        config319 = new SVMXC__ServiceMax_Config_Data__c(); 
        config319.RecordTypeId = StrConfigExpId;
        config319.SVMXC__Dispatch_Process__c = objProcess1.id;
        config319.SVMXC__Sequence__c = 145;
        config319.SVMXC__Field_Name__c = 'NumberOfEmployees';
        config319.SVMXC__Operator__c = 'NOTIN';
        config319.SVMXC__Operand__c = '123654';
        config319.SVMXC__Object_Name2__c = 'Account';
        config319.SVMXC__Field_Relationship_Name__c = '';
        config319.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        config319.SVMXC__Display_Type__c  = 'DECIMAL';
        config319.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config319);
        
        
        config320 = new SVMXC__ServiceMax_Config_Data__c(); 
		config320.RecordTypeId = StrConfigExpId;
		config320.SVMXC__Dispatch_Process__c = objProcess1.id;
		config320.SVMXC__Sequence__c = 146;
		config320.SVMXC__Field_Name__c = 'NumberOfEmployees';
		config320.SVMXC__Operator__c = 'ISNOTNULL';
		config320.SVMXC__Operand__c = '123654';
		config320.SVMXC__Object_Name2__c = 'Account';
		config320.SVMXC__Field_Relationship_Name__c = '';
		config320.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
		config320.SVMXC__Display_Type__c  = 'DECIMAL';
		config320.RecordTypeId = StrConfigExpId;
        lstConfigData1.add(config320);
                
        upsert lstConfigData1;
        
        //sourceupdate.SVMX_ExpressionParsing(lstRec, lstConfigData1, AdvExp);
        sourceupdate.SVMX_ExpressionParsing(lstRec, lstConfigData1, '( 1 AND 2 ) AND ( 3 OR 4 )');
        
        LIST<SVMXC__ServiceMax_Processes__c> LstSVMXRoutRules = new LIST<SVMXC__ServiceMax_Processes__c>();
        LstSVMXRoutRules = [select SVMXC__Select__c, SVMXC__Sequence__c, SVMXC__Active__c, SVMXC__APL_Route_Rule_Type__c , SVMXC__Name__C, SVMXC__Description__c, SVMXC__Advance_Expression__c, SVMXC__IsStandard__c from  SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='SVMX Rule' And SVMXC__Rule_Type__c = 'Routing Rule' And SVMXC__Active__c =true ORDER BY SVMXC__Sequence__c ];
        
        List<String> LstRulesId = new List<String>();    
        for(SVMXC__ServiceMax_Processes__c oSVMXProcess: LstSVMXRoutRules)
        {
            Id IdRule = oSVMXProcess.Id;
            mapRules.put(IdRule,oSVMXProcess);
            LstRulesId.add(String.escapeSingleQuotes(String.valueOf(IdRule))); 
        }
       
        
        
        StrExpQuery = 'Select SVMXC__Display_Type__c, SVMXC__Location__c, SVMXC__Dispatch_Process__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__RecordType_Name__c, SVMXC__Profile__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name2__c,  SVMXC__Field_Name__c,  SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, SVMXC__Description__c, SVMXC__Active__c, RecordTypeId From SVMXC__ServiceMax_Config_Data__c  where SVMXC__Dispatch_Process__r.Id IN: LstRulesId and SVMXC__Dispatch_Process__r.SVMXC__Rule_Type__c = \'Routing Rule\' and  RecordTypeId=\''+StrConfigExpId+'\'and SVMXC__Expression_Type__c =\'ROUTE_RULE_EXP\'';
        lstExpressions = Database.Query(StrExpQuery);
        for(SVMXC__ServiceMax_Config_Data__c oExpression: lstExpressions)
        {
            if(mapRulesExpressions.containsKey(oExpression.SVMXC__Dispatch_Process__c))
            {
                mapRulesExpressions.get(oExpression.SVMXC__Dispatch_Process__c).add(oExpression);
            }
            else
            {
                lstExpressions = new List<SVMXC__ServiceMax_Config_Data__c>();
                lstExpressions.add(oExpression);
                mapRulesExpressions.put(oExpression.SVMXC__Dispatch_Process__c,lstExpressions);
            }
        }
        sourceupdate.PopulateInfoForReferenceFields(lstExpressions);
        //sourceupdate.SVMX_ExpressionParsing(lstRec,mapRulesExpressions,mapRules);
        
        RecordType ExpressionsDetail_Rtype = [select Id from RecordType where Name='Expressions'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        List<SVMXC__ServiceMax_Config_Data__c> multiObjExp = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c multiObjExp1 = new SVMXC__ServiceMax_Config_Data__c();
        multiObjExp1.recordTypeId = ExpressionsDetail_Rtype.Id;
        multiObjExp1.SVMXC__Expression_Rule__c = objProcess1.Id;
        multiObjExp1.SVMXC__Expression_Type__c = 'EXP_Named';
        multiObjExp1.SVMXC__Sequence__c = 1;
        multiObjExp1.SVMXC__Object_Name2__c = 'SVMXC__RMA_Shipment_Order__c';
        multiObjExp1.SVMXC__Field_Name__c = 'SVMXC__Address_Type__c';
        multiObjExp1.SVMXC__Operator__c = 'EQ';
        multiObjExp1.SVMXC__Operand__c = 'Account Billing Address';
        multiObjExp.add(multiObjExp1);
        SVMXC__ServiceMax_Config_Data__c multiObjExp2 = new SVMXC__ServiceMax_Config_Data__c();
        multiObjExp2.recordTypeId = ExpressionsDetail_Rtype.Id;
        multiObjExp2.SVMXC__Expression_Rule__c = objProcess1.Id;
        multiObjExp2.SVMXC__Expression_Type__c = 'EXP_Named';
        multiObjExp2.SVMXC__Sequence__c = 2;
        multiObjExp2.SVMXC__Object_Name2__c = 'SVMXC__RMA_Shipment_Line__c';
        multiObjExp2.SVMXC__Field_Name__c = 'SVMXC__Disposition__c';
        multiObjExp2.SVMXC__Operator__c = 'EQ';
        multiObjExp2.SVMXC__Operand__c = 'Repair';
        multiObjExp.add(multiObjExp2);
        insert multiObjExp; 
        
        Map<String,String> mapObjName_RelationShipName = new Map<String,String>();
        mapObjName_RelationShipName.put('SVMXC__RMA_Shipment_Order__c', 'SVMXC__RMA_Shipment_Order__r');
        Map<String,Schema.Displaytype> fieldNameToDisplayType = new Map<String,Schema.Displaytype>();
        Map<String,Schema.SObjectType> mapFieldApiObjName = new Map<String,Schema.SObjectType>();
        Map<String,String> mapFieldRelName = new Map<String,String>();
        
        for(SVMXC__ServiceMax_Config_Data__c confDataTemp : multiObjExp)
        {
            string ObjName = confDataTemp.SVMXC__Object_Name2__c;
            Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
            if(ObjName == 'SVMXC__RMA_Shipment_Order__c')
                objfieldMap = SVMXC__RMA_Shipment_Order__c.SObjectType.getDescribe().fields.getMap();
            else if(ObjName == 'SVMXC__RMA_Shipment_Line__c')
                objfieldMap = SVMXC__RMA_Shipment_Line__c.SObjectType.getDescribe().fields.getMap();
              
            for (String fieldKey : objfieldMap.keySet()) 
            {
                Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
                Schema.DescribeFieldResult f = fsObj.getDescribe();
                if(f.getName() == confDataTemp.SVMXC__Field_Name__c)
                {
                    confDataTemp.SVMXC__Display_Type__c = f.getType().name();
                    fieldNameToDisplayType.put(confDataTemp.SVMXC__Field_Name__c, f.getType());
                    if(f.getType().name().ToUpperCase() == 'REFERENCE') 
                    {
                        mapFieldApiObjName.put(f.getName(),f.getReferenceTo()[0]);
                        mapFieldRelName.put(f.getName(),f.getRelationshipName());
                        confDataTemp.SVMXC__Field_Relationship_Name__c = f.getRelationshipName();
                        List<Schema.sObjectType> schema1 = new List<Schema.sObjectType>();
                        schema1 = f.getReferenceTo();
                        confDataTemp.SVMXC__Object_Name2__c = string.valueOf(schema1[0]);
                        if(schema1[0] == Account.SObjectType)
                        confDataTemp.SVMXC__FKey_Name_Field__c = 'Name';
                        else
                        {
                            Map<String,Schema.SObjectField> R = schema1[0].getDescribe().fields.getMap();
                            for(String fieldKey1 : R.keySet())
                            {
                                Schema.SObjectField fsObj1 = R.get(fieldKey1);
                                Schema.DescribeFieldResult f1 = fsObj1.getDescribe();
                                if(f1.isNameField())
                                    confDataTemp.SVMXC__FKey_Name_Field__c = f1.getName();
                            }
                        }
                    }
                }
            }
        }
        
        sourceupdate.validateExpression_DiffObjects('1 AND 2', multiObjExp);
        sourceupdate.BuildWhereClause_MasterDetailObjects('SVMXC__RMA_Shipment_Line__c', mapObjName_RelationShipName, '1 AND 2', multiObjExp, fieldNameToDisplayType, mapFieldApiObjName, mapFieldRelName);
        String StrProcessType = '';
        set<Id> uniqueOrderLines = new set<Id>();
        List<INTF_WebServicesDef.APL_OrderLineCollection> requestOrderLines = new List<INTF_WebServicesDef.APL_OrderLineCollection>();
        INTF_WebServicesDef.APL_OrderLineCollection orderLine1 = new INTF_WebServicesDef.APL_OrderLineCollection();
        requestOrderLines.add(orderLine1);
        
    }
    
    static testMethod void APL_Utils_test2()
    {
        List<RecordType> LstProcessRType = new List<RecordType>(); 
        String StrSVMXRuleId = ''; 
        LstProcessRType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='SVMX Rule' ];
        StrSVMXRuleId = LstProcessRType[0].Id;
        
        SVMXC.APL_Utils sourceupdate = new SVMXC.APL_Utils();
        
        SVMXC__ServiceMax_Processes__c objProcess = new SVMXC__ServiceMax_Processes__c();
        objProcess.SVMXC__Active__c= true;
        objProcess.SVMXC__Name__C = 'ProcessObj1';
        objProcess.RecordTypeId = StrSVMXRuleId;
        objProcess.SVMXC__SettingId__c = 'Setting001';
        objProcess.SVMXC__Rule_Type__c = 'Named Expression';
        upsert objProcess;
        list<SVMXC__RMA_Shipment_Line__c> lstOrdersLines = new list<SVMXC__RMA_Shipment_Line__c>();
    
        list<SVMXC__RMA_Shipment_Order__c> lstOrders = new list<SVMXC__RMA_Shipment_Order__c>();
        sourceupdate.checkHeaderQualification(lstOrders, objProcess.Id, objProcess);
        string strId = objProcess.Id;
        sourceupdate.checkChildQualification(lstOrdersLines, strId, objProcess);
    }
    
    static testMethod void APL_RouteCardUpdates_Test()
    {
        set<Id> uniqueOrderLines = new set<Id>();
        
        List<INTF_WebServicesDef.APL_OrderLineCollection> lstOrderLineWrp = new List<INTF_WebServicesDef.APL_OrderLineCollection>();
        INTF_WebServicesDef.APL_OrderLineCollection orderLine = new INTF_WebServicesDef.APL_OrderLineCollection();
        
        SVMXC__Route_Card__c routeCard = new SVMXC__Route_Card__c();
        insert routeCard;
        
        SVMXC__RMA_Shipment_Order__c patrsOrder = new SVMXC__RMA_Shipment_Order__c();
        patrsOrder.SVMXC__Billing_Type__c = 'Contract';
        patrsOrder.SVMXC__Order_Status__c = 'Open';
        insert patrsOrder;
        
        SVMXC__RMA_Shipment_Line__c poline1 = new SVMXC__RMA_Shipment_Line__c();
        poline1.SVMXC__RMA_Shipment_Order__c = patrsOrder.id;
        poline1.SVMXC__Actual_Quantity2__c = 12;
        poline1.SVMXC__Route_Card__c = routeCard.Id;
        insert poline1;
        routeCard.SVMXC__RMA_Line__c = poline1.Id;
        update routeCard;
        uniqueOrderLines.add(poline1.Id);
        
        orderLine.orderLineRecord = poline1;
        lstOrderLineWrp.add(orderLine);
        
        INTF_WebServicesDef.APL_OrderLineCollection orderLine2 = new INTF_WebServicesDef.APL_OrderLineCollection();
        
        SVMXC__RMA_Shipment_Line__c poline2 = new SVMXC__RMA_Shipment_Line__c();
        poline2.SVMXC__RMA_Shipment_Order__c = patrsOrder.id;
        poline2.SVMXC__Actual_Quantity2__c = 12;
        poline2.SVMXC__Route_Card__c = routeCard.Id;
        insert poline2;
        
        orderLine2.orderLineRecord = poline2;
        orderLine2.clonedFromId = poline1.Id;
        lstOrderLineWrp.add(orderLine2);
        
        APL_Utils utils = new APL_Utils();
        
       // utils.updateRouteCalculations(lstOrderLineWrp, uniqueOrderLines);
    }
    static testMethod void CreateInternalExternalRMA_UT()
    {
      list<RecordType> Rtypes = [select Id,Name,SobjectType from RecordType where sobjectType = 'SVMXC__Site__c' OR sobjectType = 'SVMXC__ServiceMax_Processes__c' OR sobjectType = 'SVMXC__RMA_Shipment_Order__c'];
      String depot = '';
      String objMapping = '';
      String receivingPro = '';
      String ShipmentHeader = '';
      String ShipmentLine = '';
      if(Rtypes.size() > 0)
      {
        for(RecordType rt : Rtypes)
        {
          if(rt.Name == 'Depot')
            depot = rt.id;
          else if(rt.Name == 'Object Mapping')
            objMapping = rt.id;
          else if(rt.Name == 'Receiving Process')
            receivingPro = rt.id;
          else if(rt.Name == 'Shipment')
            ShipmentHeader = rt.id;    
              
        }
      }
      SVMXC__Site__c CustomerLocation = new SVMXC__Site__c();
    CustomerLocation.SVMXC__Zip__c ='90909090';
    CustomerLocation.SVMXC__Street__c ='ABC';
    CustomerLocation.SVMXC__State__c ='ABC';
    CustomerLocation.SVMXC__Country__c ='ABC';
    CustomerLocation.SVMXC__City__c ='ABC';
    CustomerLocation.RecordTypeId = depot;
    insert CustomerLocation;
    
    SVMXC__Site__c SupplierLocation = new SVMXC__Site__c();
    SupplierLocation.SVMXC__Zip__c ='90909090';
    SupplierLocation.SVMXC__Street__c ='ABC';
    SupplierLocation.SVMXC__State__c ='ABC';
    SupplierLocation.SVMXC__Country__c ='ABC';
    SupplierLocation.SVMXC__City__c ='ABC';
    SupplierLocation.RecordTypeId = depot;
    SupplierLocation.SVMXC__Location_Type__c = 'Supplier';
    insert SupplierLocation;
    
    SVMXC__ServiceMax_Processes__c objmapping1 = new SVMXC__ServiceMax_Processes__c();
    objmapping1.RecordTypeId = objMapping;
    objmapping1.SVMXC__MapID__c = 'objmapping1';
    objmapping1.SVMXC__Name__c = 'objmapping1';
    insert objmapping1;
    SVMXC__ServiceMax_Processes__c objmapping2 = new SVMXC__ServiceMax_Processes__c();
    objmapping2.RecordTypeId = objMapping;
    objmapping2.SVMXC__MapID__c = 'objmapping1';
    objmapping2.SVMXC__Name__c = 'objmapping2';
    insert objmapping2;
    
    //Receiving Process..
    SVMXC__ServiceMax_Processes__c svmxProcess = new SVMXC__ServiceMax_Processes__c();
    svmxProcess.RecordTypeId = receivingPro;
    svmxProcess.SVMXC__Name__c = 'Receiving Process1';
    svmxProcess.SVMXC__APL_Create_Supplier_RMA__c= true;
    svmxProcess.SVMXC__Parent_Object__c = objmapping1.id;
    svmxProcess.SVMXC__Process__c = objmapping2.id;
    svmxProcess.SVMXC__APL_Create_Internal_RMA__c = true;
    insert svmxProcess;
    
    //Route Card & Stops
    SVMXC__Route_Card__c routeCard = new SVMXC__Route_Card__c();
    routeCard.SVMXC__Status__c = 'Open';
    insert routeCard;
    
    SVMXC__Route_Stop__c rs1 = new SVMXC__Route_Stop__c();
    rs1.SVMXC__Stop_Number__c = 1;
    rs1.SVMXC__Record_Card__c = routeCard.id;
    insert rs1;
    
    SVMXC__Route_Stop__c rs2 = new SVMXC__Route_Stop__c();
    rs2.SVMXC__Stop_Number__c = 2;
    rs2.SVMXC__Record_Card__c = routeCard.id;
    insert rs2;
    
    SVMXC__RMA_Shipment_Order__c masterPatrsOrder = new SVMXC__RMA_Shipment_Order__c();
        masterPatrsOrder.SVMXC__Billing_Type__c = 'Contract';
        insert masterPatrsOrder;
        
        SVMXC__RMA_Shipment_Line__c masterPOline = new SVMXC__RMA_Shipment_Line__c();
        masterPOline.SVMXC__RMA_Shipment_Order__c = masterPatrsOrder.id;
        insert masterPOline;
        
        SVMXC__RMA_Shipment_Order__c patrsOrder = new SVMXC__RMA_Shipment_Order__c();
        patrsOrder.SVMXC__Billing_Type__c = 'Contract';
        patrsOrder.SVMXC__Order_Status__c = 'Open';
        patrsOrder.SVMXC__Fulfillment_Type__c = 'Sales';
        patrsOrder.SVMXC__Master_Order__c = masterPatrsOrder.id;
        patrsOrder.SVMXC__Source_Location__c = CustomerLocation.id;
        patrsOrder.SVMXC__Destination_Location__c = SupplierLocation.id;
        insert patrsOrder;
        
        SVMXC__RMA_Shipment_Line__c poline = new SVMXC__RMA_Shipment_Line__c();
        poline.SVMXC__RMA_Shipment_Order__c = patrsOrder.id;
        poline.SVMXC__Actual_Quantity2__c = 2;
        poline.SVMXC__Master_Order_Line__c = masterPOline.id;
        poline.SVMXC__Route_Card__c = routeCard.id;
        poline.SVMXC__Route_Stop__c = rs1.id;
        insert poline;
    
    // 
    SVMXC.APL_Utils utils = new SVMXC.APL_Utils(); 
    list<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection> lstorder = new list<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection>();
        SVMXC.INTF_WebServicesDef.APL_OrderLineCollection orderl = new SVMXC.INTF_WebServicesDef.APL_OrderLineCollection();
        orderl.orderLineRecord = poline;
        lstorder.add(orderl);
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest request = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        SVMXC.INTF_WebServicesDef.APL_Order aplorder = new SVMXC.INTF_WebServicesDef.APL_Order();
        aplorder.orderHdrRecord = patrsOrder;
        aplorder.orderLines = lstorder;
        aplorder.svmxProcess = svmxProcess;
        aplOrder.processType = 'SHIPCONFIRM';
        request.aplOrder = aplorder;
        utils.CreateInternalExternalRMA(request);
    
    patrsOrder.SVMXC__Source_Location__c = SupplierLocation.id;
    patrsOrder.SVMXC__Destination_Location__c = CustomerLocation.id;
        update patrsOrder;
        aplorder.orderHdrRecord = patrsOrder;
        request.aplOrder = aplorder;
    utils.CreateInternalExternalRMA(request);
    }
    static testMethod void APL_Util_TestMethod()
    {
        SVMXC.APL_Utils utils = new SVMXC.APL_Utils();
        utils.getDate('TODAY');
        utils.getDate('SVMX.NOW');
        utils.getDate('TOMORROW');
        utils.getDate('YESTERDAY');
        utils.getDate('NEXT_N_DAYS');
        utils.getDate('LAST_N_DAYS');
        utils.getDate('abc');
        
        utils.isDateInRange('THIS_WEEK',date.newinstance(2012, 7, 22));
        utils.isDateInRange('LAST_WEEK',date.newinstance(2012, 7, 23));
        utils.isDateInRange('NEXT_WEEK',date.newinstance(2012, 7, 22));
        utils.isDateInRange('THIS_MONTH',date.newinstance(2012, 7, 01));
        utils.isDateInRange('LAST_MONTH',date.newinstance(2012, 7, 31));
        utils.isDateInRange('NEXT_MONTH',date.newinstance(2012, 8, 01));
        utils.isDateInRange('NEXT_90_DAYS',date.newinstance(2012, 7, 01));
        utils.isDateInRange('LAST_90_DAYS',date.newinstance(2012, 6, 01));
        
        utils.isDateTimeInRange('THIS_WEEK',datetime.newinstance(2012, 7, 22, 12, 30, 2));
        utils.isDateTimeInRange('LAST_WEEK',datetime.newinstance(2012, 7, 23, 12, 30, 2));
        utils.isDateTimeInRange('NEXT_WEEK',datetime.newinstance(2012, 7, 22, 12, 30, 2));
        utils.isDateTimeInRange('THIS_MONTH',datetime.newinstance(2012, 7, 01, 12, 30, 2));
        utils.isDateTimeInRange('LAST_MONTH',datetime.newinstance(2012, 7, 31, 12, 30, 2));
        utils.isDateTimeInRange('NEXT_MONTH',datetime.newinstance(2012, 8, 01, 12, 30, 2));
        utils.isDateTimeInRange('NEXT_90_DAYS',datetime.newinstance(2012, 7, 01, 12, 30, 2));
        utils.isDateTimeInRange('LAST_90_DAYS',datetime.newinstance(2012, 6, 01, 12, 30, 2));
        
        utils.getDateTime('TODAY');
        utils.getDateTime('SVMX.NOW');
        utils.getDateTime('TOMORROW');
        utils.getDateTime('YESTERDAY');
        utils.getDateTime('NEXT_N_DAYS');
        utils.getDateTime('LAST_N_DAYS'); 
        utils.getDateTime('abc');
    }  
    static testMethod void updateRouteCalculationsTest()
    {
        RecordType RT = [select id, Name from RecordType where Name = 'Depot'and SobjectType='SVMXC__Site__c' Limit 1];
        RecordType RT1 = [select id, Name from RecordType where Name = 'Outbound Route Calculation'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType RT2 = [select Id from RecordType where Name='SVMX Rule'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType RT3 = [select Id from RecordType where Name='Expressions'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        RecordType RT4 = [select Id from RecordType where Name='Route Stops'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        
        
        SVMXC__Site__c loc = new SVMXC__Site__c();
        loc.RecordTypeId = RT.Id;
        loc.SVMXC__City__c = 'Bangalore';
        loc.SVMXC__Country__c = 'India';
        loc.SVMXC__Location_Type__c = 'Supplier';
        loc.Name = 'Depot1';
        insert loc;
        SVMXC__Site__c loc1 = new SVMXC__Site__c();
        loc1.RecordTypeId = RT.Id;
        loc1.SVMXC__City__c = 'Mysore';
        loc1.SVMXC__Country__c = 'India';
        loc1.SVMXC__Location_Type__c = 'Supplier';
        loc1.Name = 'Depot1';
        insert loc1;
        
        Account acc= new Account();
        acc.Name = 'Maxplore';
        acc.Type = 'Installation Partner';
        insert acc;
        Account acc1= new Account();
        acc1.Name = 'ServiceMax';
        acc1.Type = 'Installation Partner';
        
        insert acc1;
        
        Product2 prod1 = new Product2();
        prod1.Name = 'Software';
        insert prod1;
        
        Product2 prod2 = new Product2();
        prod2.Name = 'Hardware';
        insert prod2;
        
        List<SVMXC__RMA_Shipment_Order__c> lstPO = new List<SVMXC__RMA_Shipment_Order__c>();
        SVMXC__RMA_Shipment_Order__c PO = new SVMXC__RMA_Shipment_Order__c();
        PO.SVMXC__Fulfillment_Type__c = 'Repair';
        PO.SVMXC__RMA_Type__c = 'External';
        PO.SVMXC__On_Hold__c = false;
        PO.SVMXC__Destination_Location__c = loc.Id;
        PO.SVMXC__Company__c = acc.Id;
        lstPO.add(PO);
        
        SVMXC__RMA_Shipment_Order__c PO1 = new SVMXC__RMA_Shipment_Order__c();
        PO1.SVMXC__Fulfillment_Type__c = 'Repair';
        PO1.SVMXC__RMA_Type__c = 'External';
        PO1.SVMXC__On_Hold__c = false;
        PO1.SVMXC__Destination_Location__c = loc1.Id;
        PO1.SVMXC__Company__c = acc.Id;
        lstPO.add(PO1);
        
        SVMXC__RMA_Shipment_Order__c PO2 = new SVMXC__RMA_Shipment_Order__c();
        PO2.SVMXC__Fulfillment_Type__c = 'Repair';
        PO2.SVMXC__RMA_Type__c = 'External';
        PO2.SVMXC__On_Hold__c = false;
        PO2.SVMXC__Destination_Location__c = loc.Id;
        PO2.SVMXC__Company__c = acc1.Id;
        lstPO.add(PO2);
        insert lstPO;
        
        List<SVMXC__RMA_Shipment_Line__c> lstPOLine = new List<SVMXC__RMA_Shipment_Line__c>();
        SVMXC__RMA_Shipment_Line__c POLine = new SVMXC__RMA_Shipment_Line__c();
        POLine.SVMXC__RMA_Shipment_Order__c = PO.Id;
        POLine.SVMXC__Line_Status__c = 'Open';
        POLine.SVMXC__Product__c = prod1.Id;
        POLine.SVMXC__Received__c = true;
        insert POLine;
        
        SVMXC__Route_Card__c RC = new SVMXC__Route_Card__c();
        RC.SVMXC__Current_Stop__c = loc.Id;
        RC.SVMXC__Next_Stop__c = loc.Id;
        RC.SVMXC__First_Stop__c = loc.id;
        RC.SVMXC__Last_Stop__c = loc.id;
        RC.SVMXC__Route_Type__c = 'Inbound';
        RC.SVMXC__RMA__c = PO.Id;
        RC.SVMXC__RMA_Line__c = POLine.Id;
        insert RC;
        
        SVMXC__Route_Stop__c RS = new SVMXC__Route_Stop__c();
        RS.SVMXC__Record_Card__c = RC.id;
        RS.SVMXC__Next_Stop__c = loc.id;
        RS.SVMXC__Stop_Location__c = loc.id;
        insert RS;
        
        SVMXC__Route_Card__c RC1 = new SVMXC__Route_Card__c();
        RC1.SVMXC__Current_Stop__c = loc.Id;
        RC1.SVMXC__Next_Stop__c = loc.Id;
        RC1.SVMXC__First_Stop__c = loc.id;
        RC1.SVMXC__Last_Stop__c = loc.id;
        RC1.SVMXC__Route_Type__c = 'Inbound';
        RC1.SVMXC__RMA__c = PO.Id;
        RC1.SVMXC__RMA_Line__c = POLine.Id;
        insert RC1;
        
        SVMXC__Route_Stop__c RS1 = new SVMXC__Route_Stop__c();
        RS1.SVMXC__Record_Card__c = RC1.id;
        RS1.SVMXC__Next_Stop__c = loc.id;
        RS1.SVMXC__Stop_Location__c = loc.id;
        insert RS1;
        
        SVMXC__RMA_Shipment_Line__c POLine1 = new SVMXC__RMA_Shipment_Line__c();
        POLine1.SVMXC__RMA_Shipment_Order__c = PO1.Id;
        POLine1.SVMXC__Master_Order_Line__c = POLine.Id;
        POLine1.SVMXC__Line_Status__c = 'Open';
        POLine1.SVMXC__Product__c = prod1.Id;
        POLine1.SVMXC__Route_Card__c = RC.Id;
        POLine1.SVMXC__Route_Stop__c = Rs.Id;
        POLine1.SVMXC__Received__c = true;
        lstPOLine.add(POLine1);
        SVMXC__RMA_Shipment_Line__c POLine2 = new SVMXC__RMA_Shipment_Line__c();
        POLine2.SVMXC__RMA_Shipment_Order__c = PO2.Id;
        POLine2.SVMXC__Master_Order_Line__c = POLine.Id;
        POLine2.SVMXC__Line_Status__c = 'Open';
        POLine2.SVMXC__Product__c = prod2.Id;
        POLine2.SVMXC__Route_Card__c = RC1.Id;
        POLine2.SVMXC__Route_Stop__c = Rs1.Id;
        POLine2.SVMXC__Received__c = true;
        lstPOLine.add(POLine2);
        insert lstPOLine;
        POLine.SVMXC__Route_Card__c = RC.Id;
        POLine.SVMXC__Master_Order_Line__c = POLine1.Id;
        update POLine;
        
        RC.SVMXC__RMA_Line__c = lstPOLine[0].id;
        RC1.SVMXC__RMA_Line__c = lstPOLine[1].id;
        update RC;
        update RC1;
        
        
        List<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection> orderLineCollection = new List<INTF_WebServicesDef.APL_OrderLineCollection>();
        INTF_WebServicesDef.APL_OrderLineCollection orderLine = new INTF_WebServicesDef.APL_OrderLineCollection();
        INTF_WebServicesDef.APL_OrderLineCollection orderLine1 = new INTF_WebServicesDef.APL_OrderLineCollection();
        orderLine.orderLineRecord = lstPOLine[0];
        orderLine1.orderLineRecord = lstPOLine[1];
        orderLineCollection.add(orderLine);
        orderLineCollection.add(orderLine1);
        set<Id> uniqueOrderLines = new set<Id>();
        uniqueOrderLines.add(lstPOLine[0].id);
        uniqueOrderLines.add(lstPOLine[1].id);
        SVMXC.APL_Utils utils = new SVMXC.APL_Utils();
        utils.updateRouteCalculations(orderLineCollection, uniqueOrderLines, 'PROCESSRECEIPT');
        utils.updateRouteCalculations(orderLineCollection, uniqueOrderLines, 'PICKNMOVE');
        utils.updateRouteCalculations(orderLineCollection, uniqueOrderLines, 'DELIVERYONRECEIPT');
        utils.updateRouteCalculations(orderLineCollection, uniqueOrderLines, 'SHIPCONFIRM');
    }  
    
    // Ramachandra
    static testMethod void coverage() {
        
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest request = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
		request.valueMap = new list<SVMXC.INTF_WebServicesDef.SVMXMap>(); 
        SVMXC.INTF_WebServicesDef.SVMXMap svmxRecordId = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxRecordId.key = 'SVMX_RECORDID';
        svmxRecordId.value = null;
        request.valueMap.add(svmxRecordId);
        
        SVMXC.INTF_WebServicesDef.SVMXMap svmxProcessType = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxProcessType.key = 'SVMX_PROCESSTYPE';
        svmxProcessType.value = 'PROCESSRECEIPT';
        request.valueMap.add(svmxProcessType);
        
        SVMXC.APL_Utils utils = new SVMXC.APL_Utils();
    	utils.getFieldsToQuery(request);
        
        svmxProcessType.key = 'SVMX_PROCESSTYPE';
        svmxProcessType.value = 'DELIVERYONRECEIPT';
        request.valueMap.add(svmxProcessType);
        utils.getFieldsToQuery(request);
        
        svmxProcessType.key = 'SVMX_PROCESSTYPE';
        svmxProcessType.value = 'PICKNMOVE';
        request.valueMap.add(svmxProcessType);
        utils.getFieldsToQuery(request);
        
        svmxProcessType.key = 'SVMX_PROCESSTYPE';
        svmxProcessType.value = 'SHIPCONFIRM';
        request.valueMap.add(svmxProcessType);
        utils.getFieldsToQuery(request);
    }
}