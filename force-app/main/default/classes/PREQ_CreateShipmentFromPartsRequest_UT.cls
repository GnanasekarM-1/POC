@isTest(SeeAllData=true)
private class PREQ_CreateShipmentFromPartsRequest_UT {

    static testMethod void myUnitTest() {
        
        SVMXC__Site__c loc1 = new SVMXC__Site__c();
        loc1.SVMXC__Stocking_Location__c = true;
        loc1.SVMXC__City__c = 'city';
        loc1.SVMXC__Street__c = 'street';
        loc1.SVMXC__State__c = 'State';
        loc1.SVMXC__Country__c = 'Country';
        loc1.SVMXC__Zip__c ='Zip';
        insert loc1;
        system.assert(loc1.SVMXC__City__c!=null);
        system.assert(loc1.SVMXC__Street__c!=null);
        system.assert(loc1.SVMXC__Country__c!=null);
       

        SVMXC__Site__c loc2 = new SVMXC__Site__c();
        loc2.SVMXC__Stocking_Location__c = true;
        loc2.SVMXC__City__c = 'city';
        loc2.SVMXC__Street__c = 'street';
        loc2.SVMXC__State__c = 'State';
        loc2.SVMXC__Country__c = 'Country';
        loc2.SVMXC__Zip__c ='Zip';
        insert loc2;
        system.assert(loc2.SVMXC__City__c!=null);
        system.assert(loc2.SVMXC__Street__c!=null);
        system.assert(loc2.SVMXC__Country__c!=null);

        Product2 product = new Product2(Name = 'prod');
        insert product;

        SVMXC__Parts_Request__c Pr = new SVMXC__Parts_Request__c();
        Pr.SVMXC__Requested_From__c = loc1.Id;
        Pr.SVMXC__Required_At_Location__c = loc2.Id;
        Pr.SVMXC__Status__c = 'Open';
        Pr.SVMXC__Requested_From__c = loc1.Id;
        Pr.SVMXC__Required_At_Location__c = loc2.Id;
        insert Pr;
        
        SVMXC__Parts_Request_Line__c PrLine = new SVMXC__Parts_Request_Line__c();
        PrLine.SVMXC__Parts_Request__c =Pr.Id;
        PrLine.SVMXC__Line_Status__c = 'Open';
        PrLine.SVMXC__Quantity_Required2__c = 10;
        PrLine.SVMXC__Quantity_Shipment_Initiated2__c = 0;
        insert PrLine;

        SVMXC__RMA_Shipment_Order__c ShpOrder = new SVMXC__RMA_Shipment_Order__c();
        ShpOrder.SVMXC__Parts_Request__c = Pr.Id;
        ShpOrder.SVMXC__Order_Status__c = 'Open';
        ShpOrder.SVMXC__Source_Location__c = loc1.Id;
        ShpOrder.SVMXC__Source_City__c = loc1.SVMXC__City__c;
        ShpOrder.SVMXC__Source_Street__c = loc1.SVMXC__Street__c;
        ShpOrder.SVMXC__Source_State__c = loc1.SVMXC__State__c;
        ShpOrder.SVMXC__Source_Zip__c = loc1.SVMXC__Zip__c;
        ShpOrder.SVMXC__Source_Country__c = loc1.SVMXC__Country__c;
        
        ShpOrder.SVMXC__Destination_Location__c = loc2.Id;
        ShpOrder.SVMXC__Destination_City__c = loc2.SVMXC__City__c;
        ShpOrder.SVMXC__Destination_Street__c = loc2.SVMXC__Street__c;
        ShpOrder.SVMXC__Destination_State__c = loc2.SVMXC__State__c;
        ShpOrder.SVMXC__Destination_Zip__c = loc2.SVMXC__Zip__c;
        ShpOrder.SVMXC__Destination_Country__c = loc2.SVMXC__Country__c;
        insert ShpOrder;
        system.assert(ShpOrder.SVMXC__Parts_Request__c!=null);
        system.assert(ShpOrder.SVMXC__Order_Status__c!=null);
        system.assert(ShpOrder.SVMXC__Source_Country__c!=null);
        
        RecordType Rtypedef = [select Id from RecordType where Name=:'Shipment'and SobjectType=:'SVMXC__RMA_Shipment_Line__c'];
        
        SVMXC__RMA_Shipment_Line__c ShpLine = new SVMXC__RMA_Shipment_Line__c();
        ShpLine.RecordTypeId =  Rtypedef.Id;
        //ShpLine.SVMXC__RMA_Shipment_Order__c = ShpOrder.Id;
        ShpLine.SVMXC__Parts_Request_Line__c = PrLine.Id;
        ShpLine.SVMXC__Product__c = Product.Id;
        //insert ShpLine;
        


        System.currentPagereference().getParameters().put('prid',Pr.Id);
        PREQ_CreateShipmentFromPartsRequest ShpFrmPr = new PREQ_CreateShipmentFromPartsRequest();
        ////ShpFrmPr.Addline();
        ShpFrmPr.Cancel();
        ShpFrmPr.Canceled();
        ShpFrmPr.clearAddress('Source');
        ShpFrmPr.del();
        ShpFrmPr.delline();
        ShpFrmPr.getAddressTypes();
        ShpFrmPr.getCheckAllLines();
        ShpFrmPr.getContinue();
        ShpFrmPr.getdesloc();
        ShpFrmPr.getdisplayTeamPopup();
        ShpFrmPr.getHeaderRecordTypes();
        ShpFrmPr.getLineErrorcheck();
        ShpFrmPr.setSelectedHeaderRecordType('Shipment');
        ShpFrmPr.setSelectedLineRecordType('Shipment');
        ShpFrmPr.getSelectedHeaderRecordType();
        ShpFrmPr.getSelectedLineRecordType();
        ShpFrmPr.getLineRecordTypes();
        ShpFrmPr.getNewRMAShpipmentHeader();
        ShpFrmPr.getNewRMAShpipmentLines();
        ShpFrmPr.GetPrice();
        ShpFrmPr.getRecordType('Shipment', 'SVMXC__RMA_Shipment_Line__c');
        ShpFrmPr.setNewRMAShpipmentHeader(ShpOrder);
        ShpFrmPr.getsavecheckS();
        ShpFrmPr.setSelectedAddressType('Source');
        ShpFrmPr.getSelectedAddressType();
        List<SVMXC__RMA_Shipment_Line__c> ShpLineList = new List<SVMXC__RMA_Shipment_Line__c>();
        ShpLineList.add(ShpLine);
        ShpFrmPr.setNewRMAShpipmentLines(ShpLineList);
        //ShpFrmPr.getSelectedRecordType();
        ShpFrmPr.getTAG001();
        ShpFrmPr.getTAG002();
        ShpFrmPr.getTAG003();
        ShpFrmPr.getTAG004();
        ShpFrmPr.getTAG005();
        ShpFrmPr.getTAG006();
        ShpFrmPr.getTAG007();
        ShpFrmPr.getTAG008();
        ShpFrmPr.getTAG009();
        ShpFrmPr.getTAG010();
        ShpFrmPr.getTAG011();
        ShpFrmPr.getTAG012();
        ShpFrmPr.getTAG013();
        ShpFrmPr.getTAG014();
        ShpFrmPr.getTAG015();
        ShpFrmPr.getTAG016();
        ShpFrmPr.getTAG017();
        ShpFrmPr.getTAG018();
        ShpFrmPr.getTAG019();
        ShpFrmPr.getTAG020();
        ShpFrmPr.getTAG021();
        ShpFrmPr.getTAG022();
        ShpFrmPr.getTAG023();
        ShpFrmPr.getTAG024();
        ShpFrmPr.getTAG025();
        ShpFrmPr.getTAG026();
        ShpFrmPr.getTAG027();
        ShpFrmPr.getTAG028();
        ShpFrmPr.getTAG029();
        ShpFrmPr.getTAG030();
        ShpFrmPr.getTAG031();
        ShpFrmPr.getTAG032();
        ShpFrmPr.getTAG033();
        ShpFrmPr.getTAG034();
        ShpFrmPr.getTAG035();
        ShpFrmPr.getTAG036();
        ShpFrmPr.getTAG037();
        ShpFrmPr.getTAG038();
        ShpFrmPr.getTAG039();
        ShpFrmPr.getTAG040();
        ShpFrmPr.getTAG041();
        ShpFrmPr.getTAG042();
        ShpFrmPr.getTAG043();
        ShpFrmPr.getTAG044();
        ShpFrmPr.getTAG045();
        ShpFrmPr.populateAddress('street', 'city', 'state', 'zip', 'country');
        ShpFrmPr.Save();
        ShpFrmPr.setAddress();
        ShpFrmPr.setAddress();
        ShpFrmPr.setAddressForSourceLoc();
        ShpFrmPr.setAddressForTargetLoc();
        ShpFrmPr.setCheckAllLines(true);
        ShpFrmPr.setSelectedAddressType('source');
        ShpFrmPr.getSelectedAddressType();
        ShpFrmPr.c = 2;
        ShpFrmPr.d = 2;
        //ShpFrmPr.Save();

    }
}