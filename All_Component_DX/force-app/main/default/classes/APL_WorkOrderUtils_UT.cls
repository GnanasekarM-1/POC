@isTest
private class APL_WorkOrderUtils_UT
{
    static testMethod void APL_CreateWorkOrdersOnReceipt_Test()
    {
        String objectMapping; 
	    String fieldMapping;
	    String expression;
	    String SVMXRule;
	    String shippingProcess;
        list<RecordType> RTypeList = [select Id,Name from RecordType where SobjectType='SVMXC__ServiceMax_Processes__c' OR SobjectType='SVMXC__ServiceMax_Config_Data__c'];
        if(RTypeList.size() > 0)
        {
        	for(RecordType r : RTypeList)
        	{
        		
        		if(r.Name == 'Object Mapping')
        			objectMapping = r.id;
        		else if(r.Name == 'Field Mapping')
        			fieldMapping = r.id;
        		else if(r.Name == 'Expressions')
        			expression = r.id;	
        		else if(r.Name == 'SVMX Rule')
        			SVMXRule = r.id;	
        		else if(r.Name == 'Shipping Process')
        			shippingProcess = r.id;		
        	}
        }
        
        SVMXC__ServiceMax_Processes__c ObjMappingHeader = new SVMXC__ServiceMax_Processes__c();
        ObjMappingHeader.SVMXC__Name__c = 'Create WorkOrder From Parts Order';
        ObjMappingHeader.SVMXC__MapID__c = 'Create WorkOrder From Parts Order';
        ObjMappingHeader.RecordTypeId = objectMapping;
        ObjMappingHeader.SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order__c';
        ObjMappingHeader.SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Order__c';
        insert ObjMappingHeader;
        
        SVMXC__ServiceMax_Processes__c ObjMappingLine = new SVMXC__ServiceMax_Processes__c();
       	ObjMappingLine.SVMXC__Name__c = 'Create Work details From Parts detils';
       	ObjMappingLine.SVMXC__MapID__c = 'Create Work details From Parts detils';
       	ObjMappingLine.RecordTypeId = objectMapping;
        ObjMappingLine.SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order_Line__c';
        ObjMappingLine.SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Line__c';
        insert ObjMappingLine;
        
        list<SVMXC__ServiceMax_Config_Data__c> lstFieldMapping = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c FieldMap = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap.RecordTypeId =fieldMapping;
        FieldMap.SVMXC__MapID__c = ObjMappingHeader.Id ;
        FieldMap.SVMXC__Source_Field_Name__c ='SVMXC__Source_City__c' ;
        FieldMap.SVMXC__Target_Field_Name__c ='SVMXC__City__c' ;
        lstFieldMapping.add(FieldMap); 
        
        SVMXC__ServiceMax_Config_Data__c FieldMap1 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap1.RecordTypeId =fieldMapping;
        FieldMap1.SVMXC__MapID__c = ObjMappingHeader.Id ;
        FieldMap1.SVMXC__Source_Field_Name__c ='SVMXC__Contact__c' ;
        FieldMap1.SVMXC__Target_Field_Name__c ='SVMXC__Contact__c' ;
        lstFieldMapping.add(FieldMap1); 
        
        SVMXC__ServiceMax_Config_Data__c FieldMap2 = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap2.RecordTypeId =fieldMapping;
        FieldMap2.SVMXC__MapID__c = ObjMappingLine.Id ;
        FieldMap2.SVMXC__Source_Field_Name__c ='SVMXC__Closed_On__c' ;
        FieldMap2.SVMXC__Target_Field_Name__c ='SVMXC__Closed_On__c' ;
        lstFieldMapping.add(FieldMap2);
        
       	insert lstFieldMapping;
        
        SVMXC__ServiceMax_Processes__c SVMXProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXProcess.RecordTypeId = shippingProcess;
        SVMXProcess.SVMXC__Name__c = 'Shipping Process';
        SVMXProcess.SVMXC__Description__c = 'Shipping Process';
        SVMXProcess.SVMXC__Active__c = true;
        SVMXProcess.SVMXC__Parent_Object__c = ObjMappingHeader.id;
        SVMXProcess.SVMXC__Process__c = ObjMappingLine.id;
        SVMXProcess.SVMXC__APL_Create_Work_Order_On__c = 'RECEIPT';
        SVMXProcess.SVMXC__APL_Group_Work_Order_By__c = 'ONE_PRODUCT';
        SVMXProcess.SVMXC__APL_Create_WO_Preference__c = 'APPLY_ORDER_FIRST';
        insert SVMXProcess;
        
        Account acc = new Account();
        acc.Name = 'ABC Inc';
        insert acc;
        Contact con = new Contact(); 
        con.LastName = 'John';
        insert con;
        //Create Route Card and Route Stop
        SVMXC__Route_Card__c routeCard = new SVMXC__Route_Card__c();
        insert routeCard;
        SVMXC__Route_Stop__c routeStop = new SVMXC__Route_Stop__c();
        routeStop.SVMXC__Record_Card__c = routeCard.id;
        insert routeStop;
        
        SVMXC__RMA_Shipment_Order__c masterPatrsOrder = new SVMXC__RMA_Shipment_Order__c();
        masterPatrsOrder.SVMXC__Billing_Type__c = 'Contract';
        masterPatrsOrder.SVMXC__Contact__c = con.id;
        masterPatrsOrder.SVMXC__Source_City__c = 'Bangalore';
        insert masterPatrsOrder;
        
        SVMXC__RMA_Shipment_Line__c masterPOline = new SVMXC__RMA_Shipment_Line__c();
        masterPOline.SVMXC__RMA_Shipment_Order__c = masterPatrsOrder.id;
        masterPOline.SVMXC__Closed_On__c = system.today();
        insert masterPOline;
        
        SVMXC__RMA_Shipment_Order__c patrsOrder = new SVMXC__RMA_Shipment_Order__c();
        patrsOrder.SVMXC__Billing_Type__c = 'Contract';
        patrsOrder.SVMXC__Service_Order__c = null;
        patrsOrder.SVMXC__Order_Status__c = 'Open';
        patrsOrder.SVMXC__Fulfillment_Type__c = 'Sales';
        patrsOrder.SVMXC__Contact__c = con.id;
        patrsOrder.SVMXC__Source_City__c = 'Bangalore';
        patrsOrder.SVMXC__Master_Order__c = masterPatrsOrder.id;
        insert patrsOrder;
        
        SVMXC__RMA_Shipment_Line__c poline = new SVMXC__RMA_Shipment_Line__c();
        poline.SVMXC__RMA_Shipment_Order__c = patrsOrder.id;
        poline.SVMXC__Actual_Quantity2__c = 2;
        poline.SVMXC__Master_Order_Line__c = masterPOline.id;
        poline.SVMXC__Closed_On__c = system.today();
        poline.SVMXC__Route_Card__c = routeCard.id;
        poline.SVMXC__Route_Stop__c = routeStop.id;
        poline.SVMXC__Service_Order__c = null;
        insert poline;
        
        //Create APL Order
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest request = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        list<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection> lstorder = new list<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection>();
        SVMXC.INTF_WebServicesDef.APL_OrderLineCollection orderl = new SVMXC.INTF_WebServicesDef.APL_OrderLineCollection();
        orderl.orderLineRecord = poline;
        lstorder.add(orderl);
        SVMXC.INTF_WebServicesDef.APL_Order aplorder = new SVMXC.INTF_WebServicesDef.APL_Order();
        aplorder.orderHdrRecord = patrsOrder;
        aplorder.orderLines = lstorder;
        aplorder.svmxProcess = SVMXProcess;
        aplOrder.processType = 'PROCESSRECEIPT';
        request.aplOrder = aplorder;
        
        SVMXC.APL_WorkOrderUtils woutils = new SVMXC.APL_WorkOrderUtils();
        woutils.APL_CreateWorkOrdersOnReceipt(request);
        
        SVMXProcess.SVMXC__APL_Create_WO_Preference__c = 'APPLY_LINE_FIRST';
        SVMXProcess.SVMXC__APL_Create_Work_Order_On__c = 'DELIVERY';
        request.aplOrder.processType = 'DELIVERYONRECEIPT';
        update SVMXProcess;
        patrsOrder.SVMXC__Fulfillment_Type__c = 'Repair';
        update patrsOrder;
         
        woutils.APL_CreateWorkOrdersOnReceipt(request);
    }
}