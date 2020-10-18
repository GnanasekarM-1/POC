@isTest
private class APL_Inventory_UT 
{
    //For Process Receipt..
    static testMethod void InventoryUpdateForProcessReceipt()
    {
        String standardLocationRId = '';
        String strRMARTypeId = '';
        String strSHIPRTypeId = '';
        String strRMARLineTypeId = '';
        String strSHIPLineRTypeId = '';
        list<Product2> lstProduct = new list<Product2>();
        SVMXC__Site__c toLoc = new SVMXC__Site__c();
        SVMXC__Site__c fromLoc = new SVMXC__Site__c();
        //Get RecrodType for Location & Parts Order
        list<RecordType> Rtypes = [Select Id, SobjectType, Name, LastModifiedDate, LastModifiedById, IsActive, DeveloperName, Description From RecordType where SobjectType = 'SVMXC__Site__c' or SobjectType = 'SVMXC__RMA_Shipment_Order__c'];
        if(Rtypes.size() > 0)
        {
            for(RecordType r : Rtypes)
            {
                if(r.Name == 'Standard Location')
                    standardLocationRId = r.id;
                else if(r.Name == 'RMA')
                    strRMARTypeId = r.id;
                else if(r.Name == 'Shipment')
                    strSHIPRTypeId = r.id;
            }
        }
        //Record Type of PO Lines 
        list<RecordType> RtypesL = [Select Id, SobjectType, Name, LastModifiedDate, LastModifiedById, IsActive, DeveloperName, Description From RecordType where SobjectType = 'SVMXC__RMA_Shipment_Line__c'];
        if(RtypesL.size() > 0)
        {
            for(RecordType r : RtypesL)
            {
                if(r.Name == 'RMA')
                    strRMARLineTypeId = r.id;
                else if(r.Name == 'Shipment')
                    strSHIPLineRTypeId = r.id;
            }
        }
        //Create Products..
        Product2 p1 = new Product2();
        p1.Name = 'Product1';
        p1.SVMXC__Enable_Serialized_Tracking__c = true;
        p1.SVMXC__Stockable__c = true;
        p1.Family = 'Laptop';
        lstProduct.add(p1);
        system.assert(p1.Name != null);
        Product2 p2 = new Product2();
        p2.Name = 'Product2';
        p2.SVMXC__Enable_Serialized_Tracking__c = true;
        p2.SVMXC__Stockable__c = true;
        p2.Family = 'Laptop';
        lstProduct.add(p2);
        system.assert(p2.Name != null);
        insert lstProduct;
        system.assert(lstProduct.size() != null);
        //Create Location..
        toLoc.RecordTypeId = standardLocationRId;
        toLoc.SVMXC__Street__c = '1st cross, 1st main';
        toLoc.SVMXC__City__c = 'Bangalore';
        toLoc.SVMXC__State__c = 'Karnataka';
        toLoc.SVMXC__Stocking_Location__c = true;
        insert toLoc;
        system.assert(toLoc.RecordTypeId != null);
        fromLoc.RecordTypeId = standardLocationRId;
        fromLoc.SVMXC__Street__c = '2nd cross, 1st main';
        fromLoc.SVMXC__City__c = 'Bangalore';
        fromLoc.SVMXC__State__c = 'Karnataka';
        fromLoc.SVMXC__Stocking_Location__c = true;
        insert fromLoc;
        system.assert(fromLoc.RecordTypeId != null);
        //Create RMA Order..
        SVMXC__RMA_Shipment_Order__c RMAHeader = new SVMXC__RMA_Shipment_Order__c();
        RMAHeader.RecordTypeId = strRMARTypeId;
        RMAHeader.SVMXC__Order_Status__c = 'Open';
        RMAHeader.SVMXC__Source_Location__c = fromLoc.id;
        RMAHeader.SVMXC__Destination_Location__c = toLoc.id;
        insert RMAHeader;
        system.assert(RMAHeader.RecordTypeId != null);
        //Create RMA Line
        SVMXC__RMA_Shipment_Line__c RMALine = new SVMXC__RMA_Shipment_Line__c();
        RMALine.RecordTypeId = strRMARLineTypeId;
        RMALine.SVMXC__RMA_Shipment_Order__c = RMAHeader.id;
        RMALine.SVMXC__Expected_Quantity2__c = 1;
        RMALine.SVMXC__Serial_Number_List__c = 'SN-01';
        RMALine.SVMXC__Product__c = lstProduct[0].id;
        RMALine.SVMXC__Line_Status__c = 'Open';
        insert RMALine;
        system.assert(RMALine.RecordTypeId != null);
        SVMXC.INTF_WebServicesDef.APL_Order aplOrder = new SVMXC.INTF_WebServicesDef.APL_Order();
        list<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection> orderLines = new list<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection>();
        list<SVMXC.INTF_WebServicesDef.APL_SerialCollection> serialNumbers = new list<SVMXC.INTF_WebServicesDef.APL_SerialCollection>();
        //Create Serial Numbers..
        SVMXC.INTF_WebServicesDef.APL_SerialCollection serialNumber = new SVMXC.INTF_WebServicesDef.APL_SerialCollection();
        serialNumber.serialNumber = 'SN-01';
        serialNumber.isExpected = true;
        serialNumber.isReceived = true;
        serialNumbers.add(serialNumber);
        //Create Lines
        SVMXC.INTF_WebServicesDef.APL_OrderLineCollection orderLine = new SVMXC.INTF_WebServicesDef.APL_OrderLineCollection();
        orderLine.serialNumbers = serialNumbers;
        orderLine.orderLineRecord = RMALine;
        orderLine.isProductStockable = true;
        orderLine.isEnableSerializedTracking = true;
        orderLines.add(orderLine);
        //Create APL Order
        aplOrder.orderHdrRecord = RMAHeader;
        aplOrder.orderLines = orderLines;
        aplOrder.processType = 'PROCESSRECEIPT';
        SVMXC.APL_Inventory inv = new SVMXC.APL_Inventory();
        inv.allowSerialHistrory = true;
        inv.PopulateProductStockAndStockSerial(aplOrder);
    }
    //For Delivery..
    static testMethod void InventoryUpdateForDeliveryOnReceipt()
    {
        String standardLocationRId = '';
        String strRMARTypeId = '';
        String strSHIPRTypeId = '';
        String strRMARLineTypeId = '';
        String strSHIPLineRTypeId = '';
        list<Product2> lstProduct = new list<Product2>();
        SVMXC__Site__c toLoc = new SVMXC__Site__c();
        SVMXC__Site__c fromLoc = new SVMXC__Site__c();
        //Get RecrodType for Location & Parts Order
        list<RecordType> Rtypes = [Select Id, SobjectType, Name, LastModifiedDate, LastModifiedById, IsActive, DeveloperName, Description From RecordType where SobjectType = 'SVMXC__Site__c' or SobjectType = 'SVMXC__RMA_Shipment_Order__c'];
        if(Rtypes.size() > 0)
        {
            for(RecordType r : Rtypes)
            {
                if(r.Name == 'Standard Location')
                    standardLocationRId = r.id;
                else if(r.Name == 'RMA')
                    strRMARTypeId = r.id;
                else if(r.Name == 'Shipment')
                    strSHIPRTypeId = r.id;
            }
        }
        //Record Type of PO Lines 
        list<RecordType> RtypesL = [Select Id, SobjectType, Name, LastModifiedDate, LastModifiedById, IsActive, DeveloperName, Description From RecordType where SobjectType = 'SVMXC__RMA_Shipment_Line__c'];
        if(RtypesL.size() > 0)
        {
            for(RecordType r : RtypesL)
            {
                if(r.Name == 'RMA')
                    strRMARLineTypeId = r.id;
                else if(r.Name == 'Shipment')
                    strSHIPLineRTypeId = r.id;
            }
        }
        //Create Products..
        Product2 p1 = new Product2();
        p1.Name = 'Product1';
        p1.SVMXC__Enable_Serialized_Tracking__c = true;
        p1.SVMXC__Stockable__c = true;
        p1.Family = 'Laptop';
        lstProduct.add(p1);
        Product2 p2 = new Product2();
        p2.Name = 'Product2';
        p2.SVMXC__Enable_Serialized_Tracking__c = true;
        p2.SVMXC__Stockable__c = true;
        p2.Family = 'Laptop';
        lstProduct.add(p2);
        insert lstProduct;
        system.assert(lstProduct.size() != null);
        //Create Location..
        toLoc.RecordTypeId = standardLocationRId;
        toLoc.SVMXC__Street__c = '1st cross, 1st main';
        toLoc.SVMXC__City__c = 'Bangalore';
        toLoc.SVMXC__State__c = 'Karnataka';
        toLoc.SVMXC__Stocking_Location__c = true;
        insert toLoc;
        system.assert(toLoc.RecordTypeId != null);
        fromLoc.RecordTypeId = standardLocationRId;
        fromLoc.SVMXC__Street__c = '2nd cross, 1st main';
        fromLoc.SVMXC__City__c = 'Bangalore';
        fromLoc.SVMXC__State__c = 'Karnataka';
        fromLoc.SVMXC__Stocking_Location__c = true;
        insert fromLoc;
        system.assert(fromLoc.RecordTypeId != null);
        //Create RMA Order..
        SVMXC__RMA_Shipment_Order__c RMAHeader = new SVMXC__RMA_Shipment_Order__c();
        RMAHeader.RecordTypeId = strRMARTypeId;
        RMAHeader.SVMXC__Order_Status__c = 'Open';
        RMAHeader.SVMXC__Source_Location__c = fromLoc.id;
        RMAHeader.SVMXC__Destination_Location__c = toLoc.id;
        insert RMAHeader;
        system.assert(RMAHeader.RecordTypeId != null);
        //Create RMA Line
        SVMXC__RMA_Shipment_Line__c RMALine = new SVMXC__RMA_Shipment_Line__c();
        RMALine.RecordTypeId = strRMARLineTypeId;
        RMALine.SVMXC__RMA_Shipment_Order__c = RMAHeader.id;
        RMALine.SVMXC__Expected_Quantity2__c = 1;
        RMALine.SVMXC__Serial_Number_List__c = 'SN-01';
        RMALine.SVMXC__Product__c = lstProduct[0].id;
        RMALine.SVMXC__Line_Status__c = 'Open';
        RMALine.SVMXC__Delivery_Location__c = fromLoc.id;
        insert RMALine;
        system.assert(RMALine.RecordTypeId != null);
        SVMXC.INTF_WebServicesDef.APL_Order aplOrder = new SVMXC.INTF_WebServicesDef.APL_Order();
        list<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection> orderLines = new list<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection>();
        list<SVMXC.INTF_WebServicesDef.APL_SerialCollection> serialNumbers = new list<SVMXC.INTF_WebServicesDef.APL_SerialCollection>();
        //Create Serial Numbers..
        SVMXC.INTF_WebServicesDef.APL_SerialCollection serialNumber = new SVMXC.INTF_WebServicesDef.APL_SerialCollection();
        serialNumber.serialNumber = 'SN-01';
        serialNumber.isExpected = true;
        serialNumber.isReceived = true;
        serialNumbers.add(serialNumber);
        //Create Lines
        SVMXC.INTF_WebServicesDef.APL_OrderLineCollection orderLine = new SVMXC.INTF_WebServicesDef.APL_OrderLineCollection();
        orderLine.serialNumbers = serialNumbers;
        orderLine.orderLineRecord = RMALine;
        orderLine.isProductStockable = true;
        orderLine.isEnableSerializedTracking = true;
        orderLines.add(orderLine);
        //Create APL Order
        aplOrder.orderHdrRecord = RMAHeader;
        aplOrder.orderLines = orderLines;
        aplOrder.processType = 'DELIVERYONRECEIPT';
        SVMXC.APL_Inventory inv = new SVMXC.APL_Inventory();
        inv.allowSerialHistrory = true;
        inv.PopulateProductStockAndStockSerial(aplOrder);
    }
    //For Pick & Move
    static testMethod void InventoryUpdateForPickAndMove()
    {
        String standardLocationRId = '';
        String strRMARTypeId = '';
        String strSHIPRTypeId = '';
        String strRMARLineTypeId = '';
        String strSHIPLineRTypeId = '';
        list<Product2> lstProduct = new list<Product2>();
        SVMXC__Site__c toLoc = new SVMXC__Site__c();
        SVMXC__Site__c fromLoc = new SVMXC__Site__c();
        //Get RecrodType for Location & Parts Order
        list<RecordType> Rtypes = [Select Id, SobjectType, Name, LastModifiedDate, LastModifiedById, IsActive, DeveloperName, Description From RecordType where SobjectType = 'SVMXC__Site__c' or SobjectType = 'SVMXC__RMA_Shipment_Order__c'];
        if(Rtypes.size() > 0)
        {
            for(RecordType r : Rtypes)
            {
                if(r.Name == 'Standard Location')
                    standardLocationRId = r.id;
                else if(r.Name == 'RMA')
                    strRMARTypeId = r.id;
                else if(r.Name == 'Shipment')
                    strSHIPRTypeId = r.id;
            }
        }
        //Record Type of PO Lines 
        list<RecordType> RtypesL = [Select Id, SobjectType, Name, LastModifiedDate, LastModifiedById, IsActive, DeveloperName, Description From RecordType where SobjectType = 'SVMXC__RMA_Shipment_Line__c'];
        if(RtypesL.size() > 0)
        {
            for(RecordType r : RtypesL)
            {
                if(r.Name == 'RMA')
                    strRMARLineTypeId = r.id;
                else if(r.Name == 'Shipment')
                    strSHIPLineRTypeId = r.id;
            }
        }
        //Create Products..
        Product2 p1 = new Product2();
        p1.Name = 'Product1';
        p1.SVMXC__Enable_Serialized_Tracking__c = true;
        p1.SVMXC__Stockable__c = true;
        p1.Family = 'Laptop';
        lstProduct.add(p1);
        Product2 p2 = new Product2();
        p2.Name = 'Product2';
        p2.SVMXC__Enable_Serialized_Tracking__c = true;
        p2.SVMXC__Stockable__c = true;
        p2.Family = 'Laptop';
        lstProduct.add(p2);
        insert lstProduct;
        system.assert(lstProduct.size() != null);
        //Create Location..
        toLoc.RecordTypeId = standardLocationRId;
        toLoc.SVMXC__Street__c = '1st cross, 1st main';
        toLoc.SVMXC__City__c = 'Bangalore';
        toLoc.SVMXC__State__c = 'Karnataka';
        toLoc.SVMXC__Stocking_Location__c = true;
        insert toLoc;
        system.assert(toLoc.RecordTypeId != null);
        fromLoc.RecordTypeId = standardLocationRId;
        fromLoc.SVMXC__Street__c = '2nd cross, 1st main';
        fromLoc.SVMXC__City__c = 'Bangalore';
        fromLoc.SVMXC__State__c = 'Karnataka';
        fromLoc.SVMXC__Stocking_Location__c = true;
        insert fromLoc;
        system.assert(fromLoc.RecordTypeId != null);
        //Create Shipment Order..
        SVMXC__RMA_Shipment_Order__c ShipmentHeader = new SVMXC__RMA_Shipment_Order__c();
        ShipmentHeader.RecordTypeId = strSHIPRTypeId;
        ShipmentHeader.SVMXC__Order_Status__c = 'Open';
        ShipmentHeader.SVMXC__Source_Location__c = fromLoc.id;
        ShipmentHeader.SVMXC__Destination_Location__c = toLoc.id;
        insert ShipmentHeader;
        system.assert(ShipmentHeader.RecordTypeId != null);
        //Create Shipment Line
        SVMXC__RMA_Shipment_Line__c ShipmentLine = new SVMXC__RMA_Shipment_Line__c();
        ShipmentLine.RecordTypeId = strSHIPLineRTypeId;
        ShipmentLine.SVMXC__RMA_Shipment_Order__c = ShipmentHeader.id;
        ShipmentLine.SVMXC__Expected_Quantity2__c = 1;
        ShipmentLine.SVMXC__Serial_Number_List__c = 'SN-01';
        ShipmentLine.SVMXC__Product__c = lstProduct[0].id;
        ShipmentLine.SVMXC__Line_Status__c = 'Open';
        ShipmentLine.SVMXC__Delivery_Location__c = fromLoc.id;
        insert ShipmentLine;
        system.assert(ShipmentLine.RecordTypeId != null);
        SVMXC.INTF_WebServicesDef.APL_Order aplOrder = new SVMXC.INTF_WebServicesDef.APL_Order();
        list<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection> orderLines = new list<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection>();
        list<SVMXC.INTF_WebServicesDef.APL_SerialCollection> serialNumbers = new list<SVMXC.INTF_WebServicesDef.APL_SerialCollection>();
        //Create Serial Numbers..
        SVMXC.INTF_WebServicesDef.APL_SerialCollection serialNumber = new SVMXC.INTF_WebServicesDef.APL_SerialCollection();
        serialNumber.serialNumber = 'SN-01';
        serialNumber.isExpected = true;
        serialNumber.isReceived = true;
        serialNumber.isPicked = true;
        serialNumbers.add(serialNumber);
        //Create Lines
        SVMXC.INTF_WebServicesDef.APL_OrderLineCollection orderLine = new SVMXC.INTF_WebServicesDef.APL_OrderLineCollection();
        orderLine.serialNumbers = serialNumbers;
        orderLine.orderLineRecord = ShipmentLine;
        orderLine.isProductStockable = true;
        orderLine.isEnableSerializedTracking = true;
        orderLines.add(orderLine);
        //Create APL Order
        aplOrder.orderHdrRecord = ShipmentHeader;
        aplOrder.orderLines = orderLines;
        aplOrder.processType = 'PICKNMOVE';
        SVMXC.APL_Inventory inv = new SVMXC.APL_Inventory();
        inv.allowSerialHistrory = true;
        inv.PopulateProductStockAndStockSerial(aplOrder);
    }
    //For Ship Confirm.
    static testMethod void InventoryUpdateForShipConfirm()
    {
        String standardLocationRId = '';
        String strRMARTypeId = '';
        String strSHIPRTypeId = '';
        String strRMARLineTypeId = '';
        String strSHIPLineRTypeId = '';
        list<Product2> lstProduct = new list<Product2>();
        SVMXC__Site__c toLoc = new SVMXC__Site__c();
        SVMXC__Site__c fromLoc = new SVMXC__Site__c();
        //Get RecrodType for Location & Parts Order
        list<RecordType> Rtypes = [Select Id, SobjectType, Name, LastModifiedDate, LastModifiedById, IsActive, DeveloperName, Description From RecordType where SobjectType = 'SVMXC__Site__c' or SobjectType = 'SVMXC__RMA_Shipment_Order__c'];
        if(Rtypes.size() > 0)
        {
            for(RecordType r : Rtypes)
            {
                if(r.Name == 'Standard Location')
                    standardLocationRId = r.id;
                else if(r.Name == 'RMA')
                    strRMARTypeId = r.id;
                else if(r.Name == 'Shipment')
                    strSHIPRTypeId = r.id;
            }
        }
        //Record Type of PO Lines 
        list<RecordType> RtypesL = [Select Id, SobjectType, Name, LastModifiedDate, LastModifiedById, IsActive, DeveloperName, Description From RecordType where SobjectType = 'SVMXC__RMA_Shipment_Line__c'];
        if(RtypesL.size() > 0)
        {
            for(RecordType r : RtypesL)
            {
                if(r.Name == 'RMA')
                    strRMARLineTypeId = r.id;
                else if(r.Name == 'Shipment')
                    strSHIPLineRTypeId = r.id;
            }
        }
        //Create Products..
        Product2 p1 = new Product2();
        p1.Name = 'Product1';
        p1.SVMXC__Enable_Serialized_Tracking__c = true;
        p1.SVMXC__Stockable__c = true;
        p1.Family = 'Laptop';
        lstProduct.add(p1);
        Product2 p2 = new Product2();
        p2.Name = 'Product2';
        p2.SVMXC__Enable_Serialized_Tracking__c = true;
        p2.SVMXC__Stockable__c = true;
        p2.Family = 'Laptop';
        lstProduct.add(p2);
        insert lstProduct;
        system.assert(lstProduct.size() != null);
        //Create Location..
        toLoc.RecordTypeId = standardLocationRId;
        toLoc.SVMXC__Street__c = '1st cross, 1st main';
        toLoc.SVMXC__City__c = 'Bangalore';
        toLoc.SVMXC__State__c = 'Karnataka';
        toLoc.SVMXC__Stocking_Location__c = true;
        insert toLoc;
        system.assert(toLoc.RecordTypeId != null);
        fromLoc.RecordTypeId = standardLocationRId;
        fromLoc.SVMXC__Street__c = '2nd cross, 1st main';
        fromLoc.SVMXC__City__c = 'Bangalore';
        fromLoc.SVMXC__State__c = 'Karnataka';
        fromLoc.SVMXC__Stocking_Location__c = true;
        insert fromLoc;
        system.assert(fromLoc.RecordTypeId != null);
        //Create Shipment Order..
        SVMXC__RMA_Shipment_Order__c ShipmentHeader = new SVMXC__RMA_Shipment_Order__c();
        ShipmentHeader.RecordTypeId = strSHIPRTypeId;
        ShipmentHeader.SVMXC__Order_Status__c = 'Open';
        ShipmentHeader.SVMXC__Source_Location__c = fromLoc.id;
        ShipmentHeader.SVMXC__Destination_Location__c = toLoc.id;
        insert ShipmentHeader;
        system.assert(ShipmentHeader.RecordTypeId != null);
        //Create Shipment Line
        SVMXC__RMA_Shipment_Line__c ShipmentLine = new SVMXC__RMA_Shipment_Line__c();
        ShipmentLine.RecordTypeId = strSHIPLineRTypeId;
        ShipmentLine.SVMXC__RMA_Shipment_Order__c = ShipmentHeader.id;
        ShipmentLine.SVMXC__Expected_Quantity2__c = 1;
        ShipmentLine.SVMXC__Serial_Number_List__c = 'SN-01';
        ShipmentLine.SVMXC__Product__c = lstProduct[0].id;
        ShipmentLine.SVMXC__Line_Status__c = 'Open';
        insert ShipmentLine;
        system.assert(ShipmentLine.RecordTypeId != null);
        SVMXC.INTF_WebServicesDef.APL_Order aplOrder = new SVMXC.INTF_WebServicesDef.APL_Order();
        list<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection> orderLines = new list<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection>();
        list<SVMXC.INTF_WebServicesDef.APL_SerialCollection> serialNumbers = new list<SVMXC.INTF_WebServicesDef.APL_SerialCollection>();
        //Create Serial Numbers..
        SVMXC.INTF_WebServicesDef.APL_SerialCollection serialNumber = new SVMXC.INTF_WebServicesDef.APL_SerialCollection();
        serialNumber.serialNumber = 'SN-01';
        serialNumber.isExpected = true;
        serialNumber.isReceived = true;
        serialNumber.isShipped = true;
        serialNumbers.add(serialNumber);
        //Create Lines
        SVMXC.INTF_WebServicesDef.APL_OrderLineCollection orderLine = new SVMXC.INTF_WebServicesDef.APL_OrderLineCollection();
        orderLine.serialNumbers = serialNumbers;
        orderLine.orderLineRecord = ShipmentLine;
        orderLine.isProductStockable = true;
        orderLine.isEnableSerializedTracking = true;
        orderLines.add(orderLine);
        //Create APL Order
        aplOrder.orderHdrRecord = ShipmentHeader;
        aplOrder.orderLines = orderLines;
        aplOrder.processType = 'SHIPCONFIRM';
        SVMXC.APL_Inventory inv = new SVMXC.APL_Inventory();
        inv.allowSerialHistrory = true;
        inv.PopulateProductStockAndStockSerial(aplOrder);
    }

}