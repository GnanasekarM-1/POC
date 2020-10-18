@isTest
private class APL_OrderUtils_UT 
{
   
    static testMethod void APL_GetOrder_ForErrorCondition()
    {
        SVMXC.SFM_Utils utils = new SVMXC.SFM_Utils();
        Map<String, Id> objectRecType_Map = new Map<String, Id>();
        List<String> recTypeNames = new List<String>();
        recTypeNames.add('SVMXC__Site__c~Depot');
        recTypeNames.add('SVMXC__Site__c~Depot Child');
        recTypeNames.add('SVMXC__RMA_Shipment_Order__c~RAM');
        recTypeNames.add('SVMXC__RMA_Shipment_Line__c~RMA');
        recTypeNames.add('SVMXC__ServiceMax_Processes__c~SVMX Rule'); 
        objectRecType_Map = utils.getRecordTypes(recTypeNames);
        
        
        
        SVMXC__Site__c Loc1 = new SVMXC__Site__c();
        Loc1.Name = 'Loc1';
        Loc1.SVMXC__Country__c = 'India';
        Loc1.RecordTypeId = objectRecType_Map.get('SVMXC__Site__c~Depot');
        insert Loc1;
        system.assert(Loc1.Name != null);
        
        SVMXC__Site__c Loc3 = new SVMXC__Site__c();
        Loc3.Name = 'Loc3';
        Loc3.SVMXC__Country__c = 'India';
        Loc3.SVMXC__Parent__c = Loc1.Id;
        Loc3.SVMXC__IsDelivery_Location__c = true;
        Loc3.SVMXC__IsDefault_Delivery__c = true;
        Loc3.RecordTypeId = objectRecType_Map.get('SVMXC__Site__c~Depot Child');
        insert Loc3;
        system.assert(Loc3.Name != null);
        
        SVMXC__Site__c Loc4 = new SVMXC__Site__c();
        Loc4.Name = 'Loc4';
        Loc4.SVMXC__Country__c = 'India';
        Loc4.SVMXC__Parent__c = Loc1.Id;
        Loc4.SVMXC__IsStaging_Location__c = true;
        Loc4.RecordTypeId = objectRecType_Map.get('SVMXC__Site__c~Depot Child');
        insert Loc4;
        system.assert(Loc4.Name != null);
        
        RecordType ShippingProcess_Rtype = [select Id from RecordType where Name='Shipping Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpressionsSrcUpdate_Rtype = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        
        SVMXC__RMA_Shipment_Order__c patrsOrder = new SVMXC__RMA_Shipment_Order__c();
        patrsOrder.SVMXC__Billing_Type__c = 'Contract';
        patrsOrder.SVMXC__Order_Status__c = 'Open';
        //patrsOrder.RecordTypeId = objectRecType_Map.get('SVMXC__RMA_Shipment_Order__c~RAM');
        insert patrsOrder;
        system.assert(patrsOrder.SVMXC__Billing_Type__c != null);
        
        SVMXC__RMA_Shipment_Line__c poline = new SVMXC__RMA_Shipment_Line__c();
        poline.SVMXC__RMA_Shipment_Order__c = patrsOrder.id;
        poline.SVMXC__Actual_Quantity2__c = 12;
        poline.RecordTypeId = objectRecType_Map.get('SVMXC__RMA_Shipment_Line__c~RMA');
        insert poline;
        system.assert(poline.SVMXC__RMA_Shipment_Order__c != null);
        
        SVMXC__RMA_Shipment_Line__c poline1 = new SVMXC__RMA_Shipment_Line__c();
        poline1.SVMXC__RMA_Shipment_Order__c = patrsOrder.id;
        poline1.SVMXC__Actual_Quantity2__c = 12;
        poline1.RecordTypeId = objectRecType_Map.get('SVMXC__RMA_Shipment_Line__c~RMA');
        insert poline1;
        system.assert(poline1.SVMXC__RMA_Shipment_Order__c != null);
        
        SVMXC__ServiceMax_Processes__c SVMXProcess1 = new SVMXC__ServiceMax_Processes__c();
        SVMXProcess1.SVMXC__Name__c = 'Shipping Process';
        SVMXProcess1.SVMXC__SettingId__c = 'Shipping Process';
        SVMXProcess1.SVMXC__Rule_Type__c = 'Named Expression';
        SVMXProcess1.RecordTypeId =  objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~SVMX Rule'); 
        insert SVMXProcess1;
        system.assert(SVMXProcess1.SVMXC__Name__c != null);
        
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Processes__c SVMXProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXProcess.RecordTypeId = ShippingProcess_Rtype.Id;
        SVMXProcess.SVMXC__Name__c = 'Shipping Process';
        SVMXProcess.SVMXC__Description__c = 'Shipping Process';
        SVMXProcess.SVMXC__Active__c = true;
        SVMXProcess.SVMXC__Node_Parent__c = SVMXProcess1.id;
        SVMXProcess.SVMXC__Submodule__c = SVMXProcess1.id;
        SVMXProcess.SVMXC__Parent_Error_Msg__c = 'error';
        SVMXProcess.SVMXC__Child_Error_Msg__c  = 'error';
        SVMXProcess.SVMXC__Module__c = SVMXProcess1.id;
        SVMXProcess.SVMXC__Final_Exception_Process__c = SVMXProcess1.id;
        SVMXProcess.SVMXC__Parent_Error_Msg2__c = 'error';
        SVMXProcess.SVMXC__Child_Error_Msg2__c  = 'error';
        insert SVMXProcess;
        system.assert(SVMXProcess.RecordTypeId != null);
        
        SVMXC__SFM_Event__c event1 = new SVMXC__SFM_Event__c();
        event1.SVMXC__Namespace__c = 'Namespage';
        event1.SVMXC__Class__c = 'Class';
        event1.SVMXC__Method__c = 'Method';
        event1.SVMXC__Event_Type__c = 'After Receive';
        event1.SVMXC__ServiceMax_Process__c = SVMXProcess.id;
        insert event1;
        system.assert(event1.SVMXC__ServiceMax_Process__c != null);
        
        //Product Attributes
        SVMXC__ServiceMax_Config_Data__c configData1 = new SVMXC__ServiceMax_Config_Data__c();
        configData1.SVMXC__Configuration_Type__c = 'PRODUCT_ATTRIBUTE';
        configData1.SVMXC__Dispatch_Process__c = SVMXProcess.Id;
        configData1.SVMXC__Field_Name__c = 'Family';
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
       
        //Document Line  Attributes 
        SVMXC__ServiceMax_Config_Data__c configData5 = new SVMXC__ServiceMax_Config_Data__c();
        configData5.SVMXC__Configuration_Type__c = 'DOCUMENT_LINE_ATTRIBUTE';
        configData5.SVMXC__Dispatch_Process__c = SVMXProcess.Id;
        configData5.RecordTypeId = ExpressionsSrcUpdate_Rtype.Id;
        configData5.SVMXC__Field_Name__c = 'SVMXC__Service_Order__c';
        configData5.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        configData5.SVMXC__Display_Type__c = 'REFERENCE';
        configData5.SVMXC__Field_Relationship_Name__c = 'SVMXC__Service_Order__r';
        configData5.SVMXC__FKey_Name_Field__c = 'Name';
        lstConfigData.add(configData5);
        SVMXC__ServiceMax_Config_Data__c configData6 = new SVMXC__ServiceMax_Config_Data__c();
        configData6.SVMXC__Configuration_Type__c = 'DOCUMENT_LINE_ATTRIBUTE';
        configData6.SVMXC__Dispatch_Process__c = SVMXProcess.Id;
        configData6.RecordTypeId = ExpressionsSrcUpdate_Rtype.Id;
        configData6.SVMXC__Field_Name__c = 'SVMXC__Line_Type__c';
        configData6.SVMXC__Display_Type__c = 'PICKLIST';
        lstConfigData.add(configData6);
        insert lstConfigData;
        system.assert(lstConfigData.size() != null);
       
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest request = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMap = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
        SVMXC.APL_OrderUtils utils1 = new SVMXC.APL_OrderUtils();
        
        SVMXC.INTF_WebServicesDef.SVMXMap svmxmap = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap.key = 'SVMX_RECORDID';
        svmxmap.value = patrsOrder.id;
        lstSVMXMap.add(svmxmap);
        
        SVMXC.INTF_WebServicesDef.SVMXMap svmxmap1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap1.key = 'SVMX_PROCESSID';
        svmxmap1.value = SVMXProcess.id;
        lstSVMXMap.add(svmxmap1);
        
        SVMXC.INTF_WebServicesDef.SVMXMap debugMode = new SVMXC.INTF_WebServicesDef.SVMXMap();
        debugMode.key = 'SVMX_DEBUGMODE';
        debugMode.value = 'True';
        lstSVMXMap.add(debugMode);
        
        SVMXC.INTF_WebServicesDef.SVMXMap svmxmap2 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap2.key = 'SVMX_PROCESSTYPE';
        svmxmap2.value = 'PROCESSRECEIPT';
        lstSVMXMap.add(svmxmap2);
        system.assert(lstSVMXMap.size() != null);
        request.valueMap = lstSVMXMap;
        
        utils1.getAPLOrder(request);
        request.eventType = 'INITIALSYNC';
        utils1.getAPLOrder(request);
        
        //Process receipt Error Conditions
        SVMXC__Site__c LocR1 = new SVMXC__Site__c();
        LocR1.Name = 'Loc2';
        LocR1.SVMXC__Country__c = 'India';
        LocR1.SVMXC__Parent__c = Loc1.Id;
        LocR1.SVMXC__IsReceiving_Location__c = true;
        LocR1.RecordTypeId = objectRecType_Map.get('SVMXC__Site__c~Depot Child');
        insert LocR1;
        system.assert(LocR1.Name != null);
        
        SVMXC__Site__c LocR2 = new SVMXC__Site__c();
        LocR2.Name = 'Loc2';
        LocR2.SVMXC__Country__c = 'India';
        LocR2.SVMXC__Parent__c = Loc1.Id;
        LocR2.SVMXC__IsReceiving_Location__c = true;
        LocR2.RecordTypeId = objectRecType_Map.get('SVMXC__Site__c~Depot Child');
        insert LocR2;
        system.assert(LocR2.Name != null);
        
        utils1.getAPLOrder(request);
        
        delete LocR1;
        delete LocR2;
        
        utils1.getAPLOrder(request);
        
        //Delivery
        lstSVMXMap.clear();
        svmxmap = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap.key = 'SVMX_RECORDID';
        svmxmap.value = patrsOrder.id;
        lstSVMXMap.add(svmxmap);
        
        svmxmap1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap1.key = 'SVMX_PROCESSID';
        svmxmap1.value = SVMXProcess.id;
        lstSVMXMap.add(svmxmap1);
        
        debugMode = new SVMXC.INTF_WebServicesDef.SVMXMap();
        debugMode.key = 'SVMX_DEBUGMODE';
        debugMode.value = 'True';
        lstSVMXMap.add(debugMode);
        
        svmxmap2 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap2.key = 'SVMX_PROCESSTYPE';
        svmxmap2.value = 'DELIVERYONRECEIPT';
        lstSVMXMap.add(svmxmap2);
        
        request.eventType = 'INITIALSYNC';
        request.valueMap = lstSVMXMap;
        utils1.getAPLOrder(request);
        
        //Pick N Move
        lstSVMXMap.clear();
        svmxmap = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap.key = 'SVMX_RECORDID';
        svmxmap.value = patrsOrder.id;
        lstSVMXMap.add(svmxmap);
        
        svmxmap1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap1.key = 'SVMX_PROCESSID';
        svmxmap1.value = SVMXProcess.id;
        lstSVMXMap.add(svmxmap1);
        
        debugMode = new SVMXC.INTF_WebServicesDef.SVMXMap();
        debugMode.key = 'SVMX_DEBUGMODE';
        debugMode.value = 'True';
        lstSVMXMap.add(debugMode);
        
        Test.startTest();

        svmxmap2 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap2.key = 'SVMX_PROCESSTYPE';
        svmxmap2.value = 'PICKNMOVE';
        lstSVMXMap.add(svmxmap2);
        
        request.eventType = 'INITIALSYNC';
        request.valueMap = lstSVMXMap;
        utils1.getAPLOrder(request);
        
        //ShipConfirm
        lstSVMXMap.clear();
        svmxmap = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap.key = 'SVMX_RECORDID';
        svmxmap.value = patrsOrder.id;
        lstSVMXMap.add(svmxmap);
        
        svmxmap1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap1.key = 'SVMX_PROCESSID';
        svmxmap1.value = SVMXProcess.id;
        lstSVMXMap.add(svmxmap1);
        
        debugMode = new SVMXC.INTF_WebServicesDef.SVMXMap();
        debugMode.key = 'SVMX_DEBUGMODE';
        debugMode.value = 'True';
        lstSVMXMap.add(debugMode);
        
        svmxmap2 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap2.key = 'SVMX_PROCESSTYPE';
        svmxmap2.value = 'SHIPCONFIRM';
        lstSVMXMap.add(svmxmap2);
        
        request.eventType = 'INITIALSYNC';
        request.valueMap = lstSVMXMap;
        //utils1.getAPLOrder(request);
        Test.stopTest();
        
    }
    
    static testMethod void APL_GetOrder_ForProcessReceipt()
    {
        SVMXC.SFM_Utils utils = new SVMXC.SFM_Utils();
        Map<String, Id> objectRecType_Map = new Map<String, Id>();
        List<String> recTypeNames = new List<String>();
        recTypeNames.add('SVMXC__Site__c~Depot');
        recTypeNames.add('SVMXC__Site__c~Depot Child');
        recTypeNames.add('SVMXC__RMA_Shipment_Order__c~RAM');
        recTypeNames.add('SVMXC__RMA_Shipment_Line__c~RMA');
        recTypeNames.add('SVMXC__ServiceMax_Processes__c~SVMX Rule'); 
        objectRecType_Map = utils.getRecordTypes(recTypeNames);
        
        SVMXC__Site__c Loc1 = new SVMXC__Site__c();
        Loc1.Name = 'Loc1';
        Loc1.SVMXC__Country__c = 'India';
        Loc1.RecordTypeId = objectRecType_Map.get('SVMXC__Site__c~Depot');
        insert Loc1;
        system.assert(Loc1.Name != null);
        
        SVMXC__Site__c Loc3 = new SVMXC__Site__c();
        Loc3.Name = 'Loc3';
        Loc3.SVMXC__Country__c = 'India';
        Loc3.SVMXC__Parent__c = Loc1.Id;
        Loc3.SVMXC__IsDelivery_Location__c = true;
        Loc3.SVMXC__IsDefault_Delivery__c = true;
        Loc3.RecordTypeId = objectRecType_Map.get('SVMXC__Site__c~Depot Child');
        insert Loc3;
        system.assert(Loc3.Name != null);
        
        SVMXC__Site__c Loc4 = new SVMXC__Site__c();
        Loc4.Name = 'Loc4';
        Loc4.SVMXC__Country__c = 'India';
        Loc4.SVMXC__Parent__c = Loc1.Id;
        Loc4.SVMXC__IsStaging_Location__c = true;
        Loc4.RecordTypeId = objectRecType_Map.get('SVMXC__Site__c~Depot Child');
        insert Loc4;
        system.assert(Loc4.Name != null);
        
        RecordType ShippingProcess_Rtype = [select Id from RecordType where Name='Shipping Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpressionsSrcUpdate_Rtype = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        
        SVMXC__RMA_Shipment_Order__c patrsOrder = new SVMXC__RMA_Shipment_Order__c();
        patrsOrder.SVMXC__Billing_Type__c = 'Contract';
        patrsOrder.SVMXC__Order_Status__c = 'Open';
        patrsOrder.SVMXC__Source_Location__c =  Loc1.id;
        patrsOrder.SVMXC__Destination_Location__c =  Loc1.id;
        patrsOrder.RecordTypeId = objectRecType_Map.get('SVMXC__RMA_Shipment_Order__c~RMA');
        insert patrsOrder;
        system.assert(patrsOrder.SVMXC__Billing_Type__c != null);
        
        Product2 pro = new Product2(); 
        pro.Name = 'product1';
        insert pro;
        system.assert(pro.Name != null);
        Product2 pro1 = new Product2(); 
        pro1.Name = 'product2';
        insert pro1;
        system.assert(pro1.Name != null);
        
        SVMXC__RMA_Shipment_Line__c poline = new SVMXC__RMA_Shipment_Line__c();
        poline.SVMXC__RMA_Shipment_Order__c = patrsOrder.id;
        poline.SVMXC__Expected_Quantity2__c = 1;
        poline.SVMXC__Product__c = pro.id;
        poline.SVMXC__Serial_Number_List__c = 'SN01';
        poline.RecordTypeId = objectRecType_Map.get('SVMXC__RMA_Shipment_Line__c~RMA');
        insert poline;
        system.assert(poline.SVMXC__RMA_Shipment_Order__c != null);
        
        SVMXC__RMA_Shipment_Line__c poline1 = new SVMXC__RMA_Shipment_Line__c();
        poline1.SVMXC__RMA_Shipment_Order__c = patrsOrder.id;
        poline1.SVMXC__Expected_Quantity2__c = 1;
        poline1.SVMXC__Product__c = pro1.id;
        poline1.SVMXC__Serial_Number_List__c = 'SN01';
        poline1.RecordTypeId = objectRecType_Map.get('SVMXC__RMA_Shipment_Line__c~RMA');
        insert poline1;
        system.assert(poline1.SVMXC__RMA_Shipment_Order__c != null);
        
        SVMXC__ServiceMax_Processes__c SVMXProcess1 = new SVMXC__ServiceMax_Processes__c();
        SVMXProcess1.SVMXC__SettingId__c = 'Shipping Process';
        SVMXProcess1.SVMXC__Name__c = 'Shipping Process';
        SVMXProcess1.SVMXC__Rule_Type__c = 'Named Expression';
        SVMXProcess1.RecordTypeId =  objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~SVMX Rule'); 
        insert SVMXProcess1;
        system.assert(SVMXProcess1.RecordTypeId != null);
        
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Processes__c SVMXProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXProcess.RecordTypeId = ShippingProcess_Rtype.Id;
        SVMXProcess.SVMXC__Name__c = 'Shipping Process';
        SVMXProcess.SVMXC__Description__c = 'Shipping Process';
        SVMXProcess.SVMXC__Active__c = true;
        SVMXProcess.SVMXC__Node_Parent__c = SVMXProcess1.id;
        SVMXProcess.SVMXC__Submodule__c = SVMXProcess1.id;
        SVMXProcess.SVMXC__Parent_Error_Msg__c = 'error';
        SVMXProcess.SVMXC__Child_Error_Msg__c  = 'error';
        SVMXProcess.SVMXC__Module__c = SVMXProcess1.id;
        SVMXProcess.SVMXC__Final_Exception_Process__c = SVMXProcess1.id;
        SVMXProcess.SVMXC__Parent_Error_Msg2__c = 'error';
        SVMXProcess.SVMXC__Child_Error_Msg2__c  = 'error';
        insert SVMXProcess;
        system.assert(SVMXProcess.RecordTypeId != null);
        
        SVMXC__SFM_Event__c event1 = new SVMXC__SFM_Event__c();
        event1.SVMXC__Namespace__c = 'Namespage';
        event1.SVMXC__Class__c = 'Class';
        event1.SVMXC__Method__c = 'Method';
        event1.SVMXC__Event_Type__c = 'After Receive';
        event1.SVMXC__ServiceMax_Process__c = SVMXProcess.id;
        insert event1;
        system.assert(event1.SVMXC__ServiceMax_Process__c != null);
        
        //Product Attributes
        SVMXC__ServiceMax_Config_Data__c configData1 = new SVMXC__ServiceMax_Config_Data__c();
        configData1.SVMXC__Configuration_Type__c = 'PRODUCT_ATTRIBUTE';
        configData1.SVMXC__Dispatch_Process__c = SVMXProcess.Id;
        configData1.SVMXC__Field_Name__c = 'Name';
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
       
        //Document Line  Attributes 
        SVMXC__ServiceMax_Config_Data__c configData5 = new SVMXC__ServiceMax_Config_Data__c();
        configData5.SVMXC__Configuration_Type__c = 'DOCUMENT_LINE_ATTRIBUTE';
        configData5.SVMXC__Dispatch_Process__c = SVMXProcess.Id;
        configData5.RecordTypeId = ExpressionsSrcUpdate_Rtype.Id;
        configData5.SVMXC__Field_Name__c = 'SVMXC__Service_Order__c';
        configData5.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        configData5.SVMXC__Display_Type__c = 'REFERENCE';
        configData5.SVMXC__Field_Relationship_Name__c = 'SVMXC__Service_Order__r';
        configData5.SVMXC__FKey_Name_Field__c = 'Name';
        lstConfigData.add(configData5);
        SVMXC__ServiceMax_Config_Data__c configData6 = new SVMXC__ServiceMax_Config_Data__c();
        configData6.SVMXC__Configuration_Type__c = 'DOCUMENT_LINE_ATTRIBUTE';
        configData6.SVMXC__Dispatch_Process__c = SVMXProcess.Id;
        configData6.RecordTypeId = ExpressionsSrcUpdate_Rtype.Id;
        configData6.SVMXC__Field_Name__c = 'SVMXC__Line_Type__c';
        configData6.SVMXC__Display_Type__c = 'PICKLIST';
        lstConfigData.add(configData6);
        insert lstConfigData;
        system.assert(lstConfigData.size() != null);
       
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest request = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMap = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
        SVMXC.APL_OrderUtils utils1 = new SVMXC.APL_OrderUtils();
        
        //PROCESSRECEIPT    
        lstSVMXMap.clear();
        SVMXC.INTF_WebServicesDef.SVMXMap svmxmap = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap.key = 'SVMX_RECORDID';
        svmxmap.value = patrsOrder.id;
        lstSVMXMap.add(svmxmap);
        
        SVMXC.INTF_WebServicesDef.SVMXMap svmxmap1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap1.key = 'SVMX_PROCESSID';
        svmxmap1.value = SVMXProcess.id;
        lstSVMXMap.add(svmxmap1);
        
        SVMXC.INTF_WebServicesDef.SVMXMap debugMode = new SVMXC.INTF_WebServicesDef.SVMXMap();
        debugMode.key = 'SVMX_DEBUGMODE';
        debugMode.value = 'True';
        lstSVMXMap.add(debugMode);
        
        SVMXC.INTF_WebServicesDef.SVMXMap mapBatchIDs = new SVMXC.INTF_WebServicesDef.SVMXMap();
        mapBatchIDs.key = 'SVMX_BATCHIDS';
        mapBatchIDs.values.add(poline.id);
        mapBatchIDs.values.add(poline1.id);
        lstSVMXMap.add(mapBatchIDs);
        
        SVMXC.INTF_WebServicesDef.SVMXMap svmxmap2 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap2.key = 'SVMX_PROCESSTYPE';
        svmxmap2.value = 'PROCESSRECEIPT';
        lstSVMXMap.add(svmxmap2);
        request.valueMap = lstSVMXMap;
        
        utils1.getAPLOrder(request);
        request.eventType = 'INITIALSYNC';
        utils1.getAPLOrder(request);
        request.eventType = 'BATCHCALL';
        utils1.getAPLOrder(request);
        
    } 
    static testMethod void APL_GetOrder_ForDeliveryOnReceipt()
    {
        SVMXC.SFM_Utils utils = new SVMXC.SFM_Utils();
        Map<String, Id> objectRecType_Map = new Map<String, Id>();
        List<String> recTypeNames = new List<String>();
        recTypeNames.add('SVMXC__Site__c~Depot');
        recTypeNames.add('SVMXC__Site__c~Depot Child');
        recTypeNames.add('SVMXC__RMA_Shipment_Order__c~RAM');
        recTypeNames.add('SVMXC__RMA_Shipment_Line__c~RMA');
        recTypeNames.add('SVMXC__ServiceMax_Processes__c~SVMX Rule'); 
        objectRecType_Map = utils.getRecordTypes(recTypeNames);
        
        SVMXC__Site__c Loc1 = new SVMXC__Site__c();
        Loc1.Name = 'Loc1';
        Loc1.SVMXC__Country__c = 'India';
        Loc1.RecordTypeId = objectRecType_Map.get('SVMXC__Site__c~Depot');
        insert Loc1;
        system.assert(Loc1.Name != null);
        
        SVMXC__Site__c Loc3 = new SVMXC__Site__c();
        Loc3.Name = 'Loc3';
        Loc3.SVMXC__Country__c = 'India';
        Loc3.SVMXC__Parent__c = Loc1.Id;
        Loc3.SVMXC__IsDelivery_Location__c = true;
        Loc3.SVMXC__IsDefault_Delivery__c = true;
        Loc3.RecordTypeId = objectRecType_Map.get('SVMXC__Site__c~Depot Child');
        insert Loc3;
        system.assert(Loc3.Name != null);
        
        SVMXC__Site__c Loc4 = new SVMXC__Site__c();
        Loc4.Name = 'Loc4';
        Loc4.SVMXC__Country__c = 'India';
        Loc4.SVMXC__Parent__c = Loc1.Id;
        Loc4.SVMXC__IsStaging_Location__c = true;
        Loc4.RecordTypeId = objectRecType_Map.get('SVMXC__Site__c~Depot Child');
        insert Loc4;
        system.assert(Loc4.Name != null);
        
        RecordType ShippingProcess_Rtype = [select Id from RecordType where Name='Shipping Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpressionsSrcUpdate_Rtype = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        
        SVMXC__RMA_Shipment_Order__c patrsOrder = new SVMXC__RMA_Shipment_Order__c();
        patrsOrder.SVMXC__Billing_Type__c = 'Contract';
        patrsOrder.SVMXC__Order_Status__c = 'Open';
        patrsOrder.SVMXC__Source_Location__c =  Loc1.id;
        patrsOrder.SVMXC__Destination_Location__c =  Loc1.id;
        patrsOrder.RecordTypeId = objectRecType_Map.get('SVMXC__RMA_Shipment_Order__c~RMA');
        insert patrsOrder;
        system.assert(patrsOrder.SVMXC__Billing_Type__c != null);
        
        Product2 pro = new Product2(); 
        pro.Name = 'product1';
        insert pro;
        system.assert(pro.Name != null);
        Product2 pro1 = new Product2(); 
        pro1.Name = 'product2';
        insert pro1;
        system.assert(pro1.Name != null);
        
        SVMXC__RMA_Shipment_Line__c poline = new SVMXC__RMA_Shipment_Line__c();
        poline.SVMXC__RMA_Shipment_Order__c = patrsOrder.id;
        poline.SVMXC__Expected_Quantity2__c = 1;
        poline.SVMXC__Product__c = pro.id;
        poline.SVMXC__Serial_Number_List__c = 'SN01';
        poline.SVMXC__Received__c = true;
        poline.RecordTypeId = objectRecType_Map.get('SVMXC__RMA_Shipment_Line__c~RMA');
        insert poline;
        system.assert(poline.SVMXC__RMA_Shipment_Order__c != null);
        
        SVMXC__RMA_Shipment_Line__c poline1 = new SVMXC__RMA_Shipment_Line__c();
        poline1.SVMXC__RMA_Shipment_Order__c = patrsOrder.id;
        poline1.SVMXC__Expected_Quantity2__c = 1;
        poline1.SVMXC__Product__c = pro1.id;
        poline1.SVMXC__Serial_Number_List__c = 'SN02';
        poline1.SVMXC__Received__c = true;
        poline1.RecordTypeId = objectRecType_Map.get('SVMXC__RMA_Shipment_Line__c~RMA');
        insert poline1;
        system.assert(poline1.SVMXC__RMA_Shipment_Order__c != null);
        
        SVMXC__ServiceMax_Processes__c SVMXProcess1 = new SVMXC__ServiceMax_Processes__c();
        SVMXProcess1.SVMXC__Name__c = 'Shipping Process';
        SVMXProcess1.SVMXC__Rule_Type__c = 'Named Expression';
        SVMXProcess1.RecordTypeId =  objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~SVMX Rule'); 
        SVMXProcess1.SVMXC__SettingId__c = 'Shipping Process';
        insert SVMXProcess1;
        system.assert(SVMXProcess1.SVMXC__Name__c != null);
        
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Processes__c SVMXProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXProcess.RecordTypeId = ShippingProcess_Rtype.Id;
        SVMXProcess.SVMXC__Name__c = 'Shipping Process';
        SVMXProcess.SVMXC__Description__c = 'Shipping Process';
        SVMXProcess.SVMXC__Active__c = true;
        SVMXProcess.SVMXC__Node_Parent__c = SVMXProcess1.id;
        SVMXProcess.SVMXC__Submodule__c = SVMXProcess1.id;
        SVMXProcess.SVMXC__Parent_Error_Msg__c = 'error';
        SVMXProcess.SVMXC__Child_Error_Msg__c  = 'error';
        SVMXProcess.SVMXC__Module__c = SVMXProcess1.id;
        SVMXProcess.SVMXC__Final_Exception_Process__c = SVMXProcess1.id;
        SVMXProcess.SVMXC__Parent_Error_Msg2__c = 'error';
        SVMXProcess.SVMXC__Child_Error_Msg2__c  = 'error';
        insert SVMXProcess;
        system.assert(SVMXProcess.SVMXC__Name__c != null);
        
        //Product Attributes
        SVMXC__ServiceMax_Config_Data__c configData1 = new SVMXC__ServiceMax_Config_Data__c();
        configData1.SVMXC__Configuration_Type__c = 'PRODUCT_ATTRIBUTE';
        configData1.SVMXC__Dispatch_Process__c = SVMXProcess.Id;
        configData1.SVMXC__Field_Name__c = 'Name';
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
       
        //Document Line  Attributes 
        SVMXC__ServiceMax_Config_Data__c configData5 = new SVMXC__ServiceMax_Config_Data__c();
        configData5.SVMXC__Configuration_Type__c = 'DOCUMENT_LINE_ATTRIBUTE';
        configData5.SVMXC__Dispatch_Process__c = SVMXProcess.Id;
        configData5.RecordTypeId = ExpressionsSrcUpdate_Rtype.Id;
        configData5.SVMXC__Field_Name__c = 'SVMXC__Service_Order__c';
        configData5.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        configData5.SVMXC__Display_Type__c = 'REFERENCE';
        configData5.SVMXC__Field_Relationship_Name__c = 'SVMXC__Service_Order__r';
        configData5.SVMXC__FKey_Name_Field__c = 'Name';
        lstConfigData.add(configData5);
        SVMXC__ServiceMax_Config_Data__c configData6 = new SVMXC__ServiceMax_Config_Data__c();
        configData6.SVMXC__Configuration_Type__c = 'DOCUMENT_LINE_ATTRIBUTE';
        configData6.SVMXC__Dispatch_Process__c = SVMXProcess.Id;
        configData6.RecordTypeId = ExpressionsSrcUpdate_Rtype.Id;
        configData6.SVMXC__Field_Name__c = 'SVMXC__Line_Type__c';
        configData6.SVMXC__Display_Type__c = 'PICKLIST';
        lstConfigData.add(configData6);
        insert lstConfigData;
        system.assert(lstConfigData.size() != null);
        
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest request = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMap = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
        SVMXC.APL_OrderUtils utils1 = new SVMXC.APL_OrderUtils();
        
        //Porcess Type DELIVERYONRECEIPT;
        lstSVMXMap.clear();
        SVMXC.INTF_WebServicesDef.SVMXMap svmxmap = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap.key = 'SVMX_RECORDID';
        svmxmap.value = patrsOrder.id;
        lstSVMXMap.add(svmxmap);
        
        SVMXC.INTF_WebServicesDef.SVMXMap svmxmap1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap1.key = 'SVMX_PROCESSID';
        svmxmap1.value = SVMXProcess.id;
        lstSVMXMap.add(svmxmap1);
        
        SVMXC.INTF_WebServicesDef.SVMXMap debugMode = new SVMXC.INTF_WebServicesDef.SVMXMap();
        debugMode.key = 'SVMX_DEBUGMODE';
        debugMode.value = 'True';
        lstSVMXMap.add(debugMode);
        
        SVMXC.INTF_WebServicesDef.SVMXMap mapBatchIDs = new SVMXC.INTF_WebServicesDef.SVMXMap();
        mapBatchIDs.key = 'SVMX_BATCHIDS';
        mapBatchIDs.values.add(poline.id);
        mapBatchIDs.values.add(poline1.id);
        lstSVMXMap.add(mapBatchIDs);
        
        SVMXC.INTF_WebServicesDef.SVMXMap svmxmap2 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap2.key = 'SVMX_PROCESSTYPE';
        svmxmap2.value = 'DELIVERYONRECEIPT';
        lstSVMXMap.add(svmxmap2);
        request.valueMap = lstSVMXMap;
        request.eventType = null;
        utils1.getAPLOrder(request);
        request.eventType = 'INITIALSYNC';
        utils1.getAPLOrder(request);
        request.eventType = 'BATCHCALL';
        utils1.getAPLOrder(request);
    }
    static testMethod void APL_GetOrder_ForPickNMove()
    {
        SVMXC.SFM_Utils utils = new SVMXC.SFM_Utils();
        Map<String, Id> objectRecType_Map = new Map<String, Id>();
        List<String> recTypeNames = new List<String>();
        recTypeNames.add('SVMXC__Site__c~Depot');
        recTypeNames.add('SVMXC__Site__c~Depot Child');
        recTypeNames.add('SVMXC__RMA_Shipment_Order__c~Shipment');
        recTypeNames.add('SVMXC__RMA_Shipment_Line__c~Shipment');
        recTypeNames.add('SVMXC__ServiceMax_Processes__c~SVMX Rule'); 
        objectRecType_Map = utils.getRecordTypes(recTypeNames);
        
        SVMXC__Site__c Loc1 = new SVMXC__Site__c();
        Loc1.Name = 'Loc1';
        Loc1.SVMXC__Country__c = 'India';
        Loc1.RecordTypeId = objectRecType_Map.get('SVMXC__Site__c~Depot');
        insert Loc1;
        system.assert(Loc1.Name != null);
        
        SVMXC__Site__c Loc3 = new SVMXC__Site__c();
        Loc3.Name = 'Loc3';
        Loc3.SVMXC__Country__c = 'India';
        Loc3.SVMXC__Parent__c = Loc1.Id;
        Loc3.SVMXC__IsDelivery_Location__c = true;
        Loc3.SVMXC__IsDefault_Delivery__c = true;
        Loc3.RecordTypeId = objectRecType_Map.get('SVMXC__Site__c~Depot Child');
        insert Loc3;
        system.assert(Loc3.Name != null);
        
        SVMXC__Site__c Loc4 = new SVMXC__Site__c();
        Loc4.Name = 'Loc4';
        Loc4.SVMXC__Country__c = 'India';
        Loc4.SVMXC__Parent__c = Loc1.Id;
        Loc4.SVMXC__IsStaging_Location__c = true;
        Loc4.RecordTypeId = objectRecType_Map.get('SVMXC__Site__c~Depot Child');
        insert Loc4;
        system.assert(Loc4.Name != null);
        
        RecordType ShippingProcess_Rtype = [select Id from RecordType where Name='Shipping Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpressionsSrcUpdate_Rtype = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        
        SVMXC__RMA_Shipment_Order__c patrsOrder = new SVMXC__RMA_Shipment_Order__c();
        patrsOrder.SVMXC__Billing_Type__c = 'Contract';
        patrsOrder.SVMXC__Order_Status__c = 'Open';
        patrsOrder.SVMXC__Source_Location__c =  Loc1.id;
        patrsOrder.SVMXC__Destination_Location__c =  Loc1.id;
        patrsOrder.RecordTypeId = objectRecType_Map.get('SVMXC__RMA_Shipment_Order__c~Shipment');
        insert patrsOrder;
        system.assert(patrsOrder.SVMXC__Billing_Type__c != null);
        
        Product2 pro = new Product2(); 
        pro.Name = 'product1';
        insert pro;
        system.assert(pro.Name != null);
        Product2 pro1 = new Product2(); 
        pro1.Name = 'product2';
        insert pro1;
        system.assert(pro1.Name != null);
        
        SVMXC__RMA_Shipment_Line__c poline = new SVMXC__RMA_Shipment_Line__c();
        poline.SVMXC__RMA_Shipment_Order__c = patrsOrder.id;
        poline.SVMXC__Expected_Quantity2__c = 1;
        poline.SVMXC__Serial_Number_List__c = 'SN01';
        poline.SVMXC__Product__c = pro.id;
        poline.RecordTypeId = objectRecType_Map.get('SVMXC__RMA_Shipment_Line__c~Shipment');
        insert poline;
        system.assert(poline.SVMXC__RMA_Shipment_Order__c != null);
        
        SVMXC__RMA_Shipment_Line__c poline1 = new SVMXC__RMA_Shipment_Line__c();
        poline1.SVMXC__RMA_Shipment_Order__c = patrsOrder.id;
        poline1.SVMXC__Expected_Quantity2__c = 1;
        poline1.SVMXC__Serial_Number_List__c = 'SN02';
        poline1.SVMXC__Product__c = pro1.id;
        poline1.RecordTypeId = objectRecType_Map.get('SVMXC__RMA_Shipment_Line__c~Shipment');
        poline1.SVMXC__Actual_Quantity2__c = 12;
        insert poline1;
        system.assert(poline1.SVMXC__RMA_Shipment_Order__c != null);
        
        SVMXC__ServiceMax_Processes__c SVMXProcess1 = new SVMXC__ServiceMax_Processes__c();
        SVMXProcess1.SVMXC__Name__c = 'Shipping Process';
        SVMXProcess1.SVMXC__Rule_Type__c = 'Named Expression';
        SVMXProcess1.RecordTypeId =  objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~SVMX Rule'); 
        SVMXProcess1.SVMXC__SettingId__c = 'Shipping Process';
        insert SVMXProcess1;
        system.assert(SVMXProcess1.SVMXC__Name__c != null);
        
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Processes__c SVMXProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXProcess.RecordTypeId = ShippingProcess_Rtype.Id;
        SVMXProcess.SVMXC__Name__c = 'Shipping Process';
        SVMXProcess.SVMXC__Description__c = 'Shipping Process';
        SVMXProcess.SVMXC__Active__c = true;
        SVMXProcess.SVMXC__Node_Parent__c = SVMXProcess1.id;
        SVMXProcess.SVMXC__Submodule__c = SVMXProcess1.id;
        SVMXProcess.SVMXC__Parent_Error_Msg__c = 'error';
        SVMXProcess.SVMXC__Child_Error_Msg__c  = 'error';
        SVMXProcess.SVMXC__Module__c = SVMXProcess1.id;
        SVMXProcess.SVMXC__Final_Exception_Process__c = SVMXProcess1.id;
        SVMXProcess.SVMXC__Parent_Error_Msg2__c = 'error';
        SVMXProcess.SVMXC__Child_Error_Msg2__c  = 'error';
        SVMXProcess.SVMXC__Rule_Type__c = 'Named Expression';
        insert SVMXProcess;
        system.assert(SVMXProcess.SVMXC__Name__c != null);
        
        //Product Attributes
        SVMXC__ServiceMax_Config_Data__c configData1 = new SVMXC__ServiceMax_Config_Data__c();
        configData1.SVMXC__Configuration_Type__c = 'PRODUCT_ATTRIBUTE';
        configData1.SVMXC__Dispatch_Process__c = SVMXProcess.Id;
        configData1.SVMXC__Field_Name__c = 'Name';
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
       
        //Document Line  Attributes 
        SVMXC__ServiceMax_Config_Data__c configData5 = new SVMXC__ServiceMax_Config_Data__c();
        configData5.SVMXC__Configuration_Type__c = 'DOCUMENT_LINE_ATTRIBUTE';
        configData5.SVMXC__Dispatch_Process__c = SVMXProcess.Id;
        configData5.RecordTypeId = ExpressionsSrcUpdate_Rtype.Id;
        configData5.SVMXC__Field_Name__c = 'SVMXC__Service_Order__c';
        configData5.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        configData5.SVMXC__Display_Type__c = 'REFERENCE';
        configData5.SVMXC__Field_Relationship_Name__c = 'SVMXC__Service_Order__r';
        configData5.SVMXC__FKey_Name_Field__c = 'Name';
        lstConfigData.add(configData5);
        SVMXC__ServiceMax_Config_Data__c configData6 = new SVMXC__ServiceMax_Config_Data__c();
        configData6.SVMXC__Configuration_Type__c = 'DOCUMENT_LINE_ATTRIBUTE';
        configData6.SVMXC__Dispatch_Process__c = SVMXProcess.Id;
        configData6.RecordTypeId = ExpressionsSrcUpdate_Rtype.Id;
        configData6.SVMXC__Field_Name__c = 'SVMXC__Line_Type__c';
        configData6.SVMXC__Display_Type__c = 'PICKLIST';
        lstConfigData.add(configData6);
        insert lstConfigData;
        system.assert(lstConfigData.size() != null);
        
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest request = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMap = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
        SVMXC.APL_OrderUtils utils1 = new SVMXC.APL_OrderUtils();
        
        //Porcess Type PICKNMOVE;
        lstSVMXMap.clear();
        SVMXC.INTF_WebServicesDef.SVMXMap svmxmap = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap.key = 'SVMX_RECORDID';
        svmxmap.value = patrsOrder.id;
        lstSVMXMap.add(svmxmap);
        
        SVMXC.INTF_WebServicesDef.SVMXMap svmxmap1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap1.key = 'SVMX_PROCESSID';
        svmxmap1.value = SVMXProcess.id;
        lstSVMXMap.add(svmxmap1);
        
        SVMXC.INTF_WebServicesDef.SVMXMap debugMode = new SVMXC.INTF_WebServicesDef.SVMXMap();
        debugMode.key = 'SVMX_DEBUGMODE';
        debugMode.value = 'True';
        lstSVMXMap.add(debugMode);
        
        SVMXC.INTF_WebServicesDef.SVMXMap mapBatchIDs = new SVMXC.INTF_WebServicesDef.SVMXMap();
        mapBatchIDs.key = 'SVMX_BATCHIDS';
        mapBatchIDs.values.add(poline.id);
        mapBatchIDs.values.add(poline1.id);
        lstSVMXMap.add(mapBatchIDs);
        
        SVMXC.INTF_WebServicesDef.SVMXMap svmxmap2 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap2.key = 'SVMX_PROCESSTYPE';
        svmxmap2.value = 'PICKNMOVE';
        lstSVMXMap.add(svmxmap2);
        request.valueMap = lstSVMXMap;
        request.eventType = null;
        utils1.getAPLOrder(request);
        request.eventType = 'INITIALSYNC';
        utils1.getAPLOrder(request);
        request.eventType = 'BATCHCALL';
        utils1.getAPLOrder(request);
        
    }
    static testMethod void APL_GetOrder_ForShipConfirm()
    {
        SVMXC.SFM_Utils utils = new SVMXC.SFM_Utils();
        Map<String, Id> objectRecType_Map = new Map<String, Id>();
        List<String> recTypeNames = new List<String>();
        recTypeNames.add('SVMXC__Site__c~Depot');
        recTypeNames.add('SVMXC__Site__c~Depot Child');
        recTypeNames.add('SVMXC__RMA_Shipment_Order__c~Shipment');
        recTypeNames.add('SVMXC__RMA_Shipment_Line__c~Shipment');
        recTypeNames.add('SVMXC__ServiceMax_Processes__c~SVMX Rule'); 
        objectRecType_Map = utils.getRecordTypes(recTypeNames);
        
        SVMXC__Site__c Loc1 = new SVMXC__Site__c();
        Loc1.Name = 'Loc1';
        Loc1.SVMXC__Country__c = 'India';
        Loc1.RecordTypeId = objectRecType_Map.get('SVMXC__Site__c~Depot');
        insert Loc1;
        system.assert(Loc1.Name != null);
        
        SVMXC__Site__c Loc3 = new SVMXC__Site__c();
        Loc3.Name = 'Loc3';
        Loc3.SVMXC__Country__c = 'India';
        Loc3.SVMXC__Parent__c = Loc1.Id;
        Loc3.SVMXC__IsDelivery_Location__c = true;
        Loc3.SVMXC__IsDefault_Delivery__c = true;
        Loc3.RecordTypeId = objectRecType_Map.get('SVMXC__Site__c~Depot Child');
        insert Loc3;
        system.assert(Loc3.Name != null);
        
        SVMXC__Site__c Loc4 = new SVMXC__Site__c();
        Loc4.Name = 'Loc4';
        Loc4.SVMXC__Country__c = 'India';
        Loc4.SVMXC__Parent__c = Loc1.Id;
        Loc4.SVMXC__IsStaging_Location__c = true;
        Loc4.RecordTypeId = objectRecType_Map.get('SVMXC__Site__c~Depot Child');
        insert Loc4;
        system.assert(Loc4.Name != null);
        
        RecordType ShippingProcess_Rtype = [select Id from RecordType where Name='Shipping Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpressionsSrcUpdate_Rtype = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        
        SVMXC__RMA_Shipment_Order__c patrsOrder = new SVMXC__RMA_Shipment_Order__c();
        patrsOrder.SVMXC__Billing_Type__c = 'Contract';
        patrsOrder.SVMXC__Order_Status__c = 'Open';
        patrsOrder.SVMXC__Source_Location__c =  Loc1.id;
        patrsOrder.SVMXC__Destination_Location__c =  Loc1.id;
        patrsOrder.RecordTypeId = objectRecType_Map.get('SVMXC__RMA_Shipment_Order__c~Shipment');
        insert patrsOrder;
        system.assert(patrsOrder.SVMXC__Billing_Type__c != null);
        
        Product2 pro = new Product2(); 
        pro.Name = 'product1';
        insert pro;
        system.assert(pro.Name != null);
        Product2 pro1 = new Product2(); 
        pro1.Name = 'product2';
        insert pro1;
        system.assert(pro1.Name != null);
        
        SVMXC__RMA_Shipment_Line__c poline = new SVMXC__RMA_Shipment_Line__c();
        poline.SVMXC__RMA_Shipment_Order__c = patrsOrder.id;
        poline.SVMXC__Expected_Quantity2__c = 1;
        poline.SVMXC__Product__c = pro.id;
        poline.SVMXC__Picked__c = true;
        poline.RecordTypeId = objectRecType_Map.get('SVMXC__RMA_Shipment_Line__c~Shipment');
        insert poline;
        system.assert(poline.SVMXC__RMA_Shipment_Order__c != null);
        
        SVMXC__RMA_Shipment_Line__c poline1 = new SVMXC__RMA_Shipment_Line__c();
        poline1.SVMXC__RMA_Shipment_Order__c = patrsOrder.id;
        poline1.SVMXC__Expected_Quantity2__c = 1;
        poline1.SVMXC__Product__c = pro1.id;
        poline1.SVMXC__Picked__c = true;
        poline1.RecordTypeId = objectRecType_Map.get('SVMXC__RMA_Shipment_Line__c~Shipment');
        insert poline1;
        system.assert(poline1.SVMXC__RMA_Shipment_Order__c != null);
        
        SVMXC__ServiceMax_Processes__c SVMXProcess1 = new SVMXC__ServiceMax_Processes__c();
        SVMXProcess1.SVMXC__Name__c = 'Shipping Process';
        SVMXProcess1.SVMXC__Rule_Type__c = 'Named Expression';
        SVMXProcess1.RecordTypeId =  objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~SVMX Rule'); 
        SVMXProcess1.SVMXC__SettingId__c = 'Shipping Process';
        insert SVMXProcess1;
        system.assert(SVMXProcess1.SVMXC__Name__c != null);
        
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Processes__c SVMXProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXProcess.RecordTypeId = ShippingProcess_Rtype.Id;
        SVMXProcess.SVMXC__Name__c = 'Shipping Process';
        SVMXProcess.SVMXC__Description__c = 'Shipping Process';
        SVMXProcess.SVMXC__Active__c = true;
        SVMXProcess.SVMXC__Node_Parent__c = SVMXProcess1.id;
        SVMXProcess.SVMXC__Submodule__c = SVMXProcess1.id;
        SVMXProcess.SVMXC__Parent_Error_Msg__c = 'error';
        SVMXProcess.SVMXC__Child_Error_Msg__c  = 'error';
        SVMXProcess.SVMXC__Module__c = SVMXProcess1.id;
        SVMXProcess.SVMXC__Final_Exception_Process__c = SVMXProcess1.id;
        SVMXProcess.SVMXC__Parent_Error_Msg2__c = 'error';
        SVMXProcess.SVMXC__Child_Error_Msg2__c  = 'error';
        SVMXProcess.SVMXC__Rule_Type__c = 'Named Expression';
        insert SVMXProcess;
        system.assert(SVMXProcess.SVMXC__Name__c != null);
        
        //Product Attributes
        SVMXC__ServiceMax_Config_Data__c configData1 = new SVMXC__ServiceMax_Config_Data__c();
        configData1.SVMXC__Configuration_Type__c = 'PRODUCT_ATTRIBUTE';
        configData1.SVMXC__Dispatch_Process__c = SVMXProcess.Id;
        configData1.SVMXC__Field_Name__c = 'Name';
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
       
        //Document Line  Attributes 
        SVMXC__ServiceMax_Config_Data__c configData5 = new SVMXC__ServiceMax_Config_Data__c();
        configData5.SVMXC__Configuration_Type__c = 'DOCUMENT_LINE_ATTRIBUTE';
        configData5.SVMXC__Dispatch_Process__c = SVMXProcess.Id;
        configData5.RecordTypeId = ExpressionsSrcUpdate_Rtype.Id;
        configData5.SVMXC__Field_Name__c = 'SVMXC__Service_Order__c';
        configData5.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        configData5.SVMXC__Display_Type__c = 'REFERENCE';
        configData5.SVMXC__Field_Relationship_Name__c = 'SVMXC__Service_Order__r';
        configData5.SVMXC__FKey_Name_Field__c = 'Name';
        lstConfigData.add(configData5);
        SVMXC__ServiceMax_Config_Data__c configData6 = new SVMXC__ServiceMax_Config_Data__c();
        configData6.SVMXC__Configuration_Type__c = 'DOCUMENT_LINE_ATTRIBUTE';
        configData6.SVMXC__Dispatch_Process__c = SVMXProcess.Id;
        configData6.RecordTypeId = ExpressionsSrcUpdate_Rtype.Id;
        configData6.SVMXC__Field_Name__c = 'SVMXC__Line_Type__c';
        configData6.SVMXC__Display_Type__c = 'PICKLIST';
        lstConfigData.add(configData6);
        insert lstConfigData;
        system.assert(lstConfigData.size() != null);
        
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest request = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMap = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
        SVMXC.APL_OrderUtils utils1 = new SVMXC.APL_OrderUtils();
        
         //Porcess Type SHIPCONFIRM;
        lstSVMXMap.clear();
        SVMXC.INTF_WebServicesDef.SVMXMap svmxmap = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap.key = 'SVMX_RECORDID';
        svmxmap.value = patrsOrder.id;
        lstSVMXMap.add(svmxmap);
        
        SVMXC.INTF_WebServicesDef.SVMXMap svmxmap1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap1.key = 'SVMX_PROCESSID';
        svmxmap1.value = SVMXProcess.id;
        lstSVMXMap.add(svmxmap1); 
        
        SVMXC.INTF_WebServicesDef.SVMXMap debugMode = new SVMXC.INTF_WebServicesDef.SVMXMap();
        debugMode.key = 'SVMX_DEBUGMODE';
        debugMode.value = 'True';
        lstSVMXMap.add(debugMode);
        
        SVMXC.INTF_WebServicesDef.SVMXMap mapBatchIDs = new SVMXC.INTF_WebServicesDef.SVMXMap();
        mapBatchIDs.key = 'SVMX_BATCHIDS';
        mapBatchIDs.values.add(poline.id);
        mapBatchIDs.values.add(poline1.id);
        lstSVMXMap.add(mapBatchIDs);
        
        SVMXC.INTF_WebServicesDef.SVMXMap svmxmap2 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap2.key = 'SVMX_PROCESSTYPE';
        svmxmap2.value = 'SHIPCONFIRM';
        lstSVMXMap.add(svmxmap2);
        request.valueMap = lstSVMXMap;
        request.eventType = null;
        utils1.getAPLOrder(request);
        request.eventType = 'INITIALSYNC';
        utils1.getAPLOrder(request);
        request.eventType = 'BATCHCALL';
        utils1.getAPLOrder(request);
    }
    static testMethod void APL_MakeColumn_Test()
    {
        
        RecordType ShippingProcess_Rtype = [select Id from RecordType where Name='Shipping Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpressionsSrcUpdate_Rtype = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        RecordType Rule  = [select Id from RecordType where Name='SVMX Rule'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        
        SVMXC__ServiceMax_Processes__c SVMXProcess1 = new SVMXC__ServiceMax_Processes__c();
        SVMXProcess1.SVMXC__Name__c = 'Shipping Process';
        SVMXProcess1.SVMXC__Rule_Type__c = 'Named Expression';
        SVMXProcess1.RecordTypeId =  Rule.id;
        SVMXProcess1.SVMXC__SettingId__c = 'Shipping Process';
        insert SVMXProcess1;
        system.assert(SVMXProcess1.RecordtypeId != null);
        
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Processes__c SVMXProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXProcess.RecordTypeId = ShippingProcess_Rtype.Id;
        SVMXProcess.SVMXC__Name__c = 'Shipping Process';
        SVMXProcess.SVMXC__Description__c = 'Shipping Process';
        SVMXProcess.SVMXC__Active__c = true;
        SVMXProcess.SVMXC__Node_Parent__c = SVMXProcess1.id;
        SVMXProcess.SVMXC__Submodule__c = SVMXProcess1.id;
        SVMXProcess.SVMXC__Parent_Error_Msg__c = 'error';
        SVMXProcess.SVMXC__Child_Error_Msg__c  = 'error';
        SVMXProcess.SVMXC__Module__c = SVMXProcess1.id;
        SVMXProcess.SVMXC__Final_Exception_Process__c = SVMXProcess1.id;
        SVMXProcess.SVMXC__Parent_Error_Msg2__c = 'error';
        SVMXProcess.SVMXC__Child_Error_Msg2__c  = 'error';
        SVMXProcess.SVMXC__Rule_Type__c = 'Named Expression';
        insert SVMXProcess;
        system.assert(SVMXProcess.RecordtypeId != null);
        
        //Product Attributes
        SVMXC__ServiceMax_Config_Data__c configData1 = new SVMXC__ServiceMax_Config_Data__c();
        configData1.SVMXC__Configuration_Type__c = 'PRODUCT_ATTRIBUTE';
        configData1.SVMXC__Dispatch_Process__c = SVMXProcess.Id;
        configData1.SVMXC__Field_Name__c = 'Name';
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
       
        //Document Line  Attributes 
        SVMXC__ServiceMax_Config_Data__c configData5 = new SVMXC__ServiceMax_Config_Data__c();
        configData5.SVMXC__Configuration_Type__c = 'DOCUMENT_LINE_ATTRIBUTE';
        configData5.SVMXC__Dispatch_Process__c = SVMXProcess.Id;
        configData5.RecordTypeId = ExpressionsSrcUpdate_Rtype.Id;
        configData5.SVMXC__Field_Name__c = 'SVMXC__Service_Order__c';
        configData5.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        configData5.SVMXC__Display_Type__c = 'REFERENCE';
        configData5.SVMXC__Field_Relationship_Name__c = 'SVMXC__Service_Order__r';
        configData5.SVMXC__FKey_Name_Field__c = 'Name';
        lstConfigData.add(configData5);
        SVMXC__ServiceMax_Config_Data__c configData6 = new SVMXC__ServiceMax_Config_Data__c();
        configData6.SVMXC__Configuration_Type__c = 'DOCUMENT_LINE_ATTRIBUTE';
        configData6.SVMXC__Dispatch_Process__c = SVMXProcess.Id;
        configData6.RecordTypeId = ExpressionsSrcUpdate_Rtype.Id;
        configData6.SVMXC__Field_Name__c = 'SVMXC__Line_Type__c';
        configData6.SVMXC__Display_Type__c = 'PICKLIST';
        lstConfigData.add(configData6);
        insert lstConfigData;
        system.assert(lstConfigData.size() != null);
        
        SVMXC.APL_OrderUtils utils1 = new SVMXC.APL_OrderUtils();
        utils1.MakeColumn(lstConfigData ,'PROCESSRECEIPT');
        utils1.MakeColumn(lstConfigData ,'DELIVERYONRECEIPT');
        utils1.MakeColumn(lstConfigData ,'PICKNMOVE');
        utils1.MakeColumn(lstConfigData ,'SHIPCONFIRM');
        utils1.MakeColumn(lstConfigData ,'FULFILLMENTPROCESS'); 
        
        utils1.getSortingColumns(lstConfigData ,'PROCESSRECEIPT');
        utils1.getSortingColumns(lstConfigData ,'DELIVERYONRECEIPT');
        utils1.getSortingColumns(lstConfigData ,'PICKNMOVE');
        utils1.getSortingColumns(lstConfigData ,'SHIPCONFIRM');
        utils1.getSortingColumns(lstConfigData ,'FULFILLMENTPROCESS');
    }
    static testMethod void APL_SaveOrder_Test()
    {
        RecordType ShippingProcess_Rtype = [select Id from RecordType where Name='Shipping Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpressionsSrcUpdate_Rtype = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
        SVMXC__RMA_Shipment_Order__c patrsOrder = new SVMXC__RMA_Shipment_Order__c();
        patrsOrder.SVMXC__Billing_Type__c = 'Contract';
        patrsOrder.SVMXC__Order_Status__c = 'Open';
        insert patrsOrder;
        system.assert(patrsOrder.SVMXC__Billing_Type__c != null);
        
        SVMXC__RMA_Shipment_Line__c poline = new SVMXC__RMA_Shipment_Line__c();
        poline.SVMXC__RMA_Shipment_Order__c = patrsOrder.id;
        poline.SVMXC__Actual_Quantity2__c = 12;
        insert poline;
        system.assert(poline.SVMXC__RMA_Shipment_Order__c != null);
        
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Processes__c SVMXProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXProcess.RecordTypeId = ShippingProcess_Rtype.Id;
        SVMXProcess.SVMXC__Name__c = 'Shipping Process';
        SVMXProcess.SVMXC__Description__c = 'Shipping Process';
        SVMXProcess.SVMXC__Active__c = true;
        insert SVMXProcess;
        system.assert(SVMXProcess.RecordTypeId != null);
        
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
        system.assert(lstConfigData.size() != null);
       
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest request = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMap = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
        //PROCESSRECEIPT    
        SVMXC.INTF_WebServicesDef.SVMXMap svmxmap = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap.key = 'SVMX_RECORDID';
        svmxmap.value = patrsOrder.id;
        lstSVMXMap.add(svmxmap);
        
        SVMXC.INTF_WebServicesDef.SVMXMap svmxmap1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap1.key = 'SVMX_PROCESSID';
        svmxmap1.value = SVMXProcess.id;
        lstSVMXMap.add(svmxmap1);
        
        SVMXC.INTF_WebServicesDef.SVMXMap svmxmap2 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap2.key = 'SVMX_PROCESSTYPE';
        svmxmap2.value = 'PROCESSRECEIPT';
        lstSVMXMap.add(svmxmap2);
            
        request.valueMap = lstSVMXMap;
        list<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection> lstorder = new list<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection>();
        SVMXC.INTF_WebServicesDef.APL_OrderLineCollection orderl = new SVMXC.INTF_WebServicesDef.APL_OrderLineCollection();
        orderl.orderLineRecord = poline;
        lstorder.add(orderl);
        SVMXC.INTF_WebServicesDef.APL_Order aplorder = new SVMXC.INTF_WebServicesDef.APL_Order();
        aplorder.orderHdrRecord = patrsOrder;
        aplorder.orderLines = lstorder;
        aplorder.svmxProcess = SVMXProcess;
        aplorder.configData = lstConfigData;
        request.aplOrder = aplorder;
        aplorder.processType = 'PROCESSRECEIPT';
        SVMXC.APL_OrderUtils saveorder = new SVMXC.APL_OrderUtils();
        saveorder.SaveAPLOrder(request);
        //saveorder.APL_PreSaveUpdates(request);
        //DELIVERYONRECEIPT
        lstSVMXMap.clear();
        svmxmap = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap.key = 'SVMX_RECORDID';
        svmxmap.value = patrsOrder.id;
        lstSVMXMap.add(svmxmap);
        svmxmap1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap1.key = 'SVMX_PROCESSID';
        svmxmap1.value = SVMXProcess.id;
        lstSVMXMap.add(svmxmap1);
        svmxmap2 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap2.key = 'SVMX_PROCESSTYPE';
        svmxmap2.value = 'DELIVERYONRECEIPT';
        lstSVMXMap.add(svmxmap2);
        request.valueMap = lstSVMXMap;
        saveorder.SaveAPLOrder(request);
        //saveorder.APL_PreSaveUpdates(request);
        //PICKNMOVE
        lstSVMXMap.clear();
        svmxmap = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap.key = 'SVMX_RECORDID';
        svmxmap.value = patrsOrder.id;
        lstSVMXMap.add(svmxmap);
        svmxmap1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap1.key = 'SVMX_PROCESSID';
        svmxmap1.value = SVMXProcess.id;
        lstSVMXMap.add(svmxmap1);
        svmxmap2 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap2.key = 'SVMX_PROCESSTYPE';
        svmxmap2.value = 'PICKNMOVE';
        lstSVMXMap.add(svmxmap2);
        request.valueMap = lstSVMXMap;
        saveorder.SaveAPLOrder(request);
        //saveorder.APL_PreSaveUpdates(request);
        //SHIPCONFIRM
        lstSVMXMap.clear();
        svmxmap = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap.key = 'SVMX_RECORDID';
        svmxmap.value = patrsOrder.id;
        lstSVMXMap.add(svmxmap);
        svmxmap1 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap1.key = 'SVMX_PROCESSID';
        svmxmap1.value = SVMXProcess.id;
        lstSVMXMap.add(svmxmap1);
        svmxmap2 = new SVMXC.INTF_WebServicesDef.SVMXMap();
        svmxmap2.key = 'SVMX_PROCESSTYPE';
        svmxmap2.value = 'SHIPCONFIRM';
        lstSVMXMap.add(svmxmap2);
        request.valueMap = lstSVMXMap;
        saveorder.SaveAPLOrder(request);
        //saveorder.APL_PreSaveUpdates(request);
    }
    
}