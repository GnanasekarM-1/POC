@isTest(SeeAllData=true)
private class PORD_CancelShipmentOrder_UT {

    static testMethod void PORD_CancelShipmentOrder_UnitTest() {
        SVMXC__RMA_Shipment_Order__c shpOrdr = new SVMXC__RMA_Shipment_Order__c();
        SVMXC__RMA_Shipment_Line__c ShpLineOrdr = new SVMXC__RMA_Shipment_Line__c();
        shpOrdr.SVMXC__Order_Status__c = 'Closed';
        insert shpOrdr;  
        ShpLineOrdr.SVMXC__Line_Status__c = 'Open';
        ShpLineOrdr.SVMXC__RMA_Shipment_Order__c = shpOrdr.Id; 
        insert ShpLineOrdr;
        system.assert(shpOrdr.SVMXC__Order_Status__c!=null);
        system.assert(ShpLineOrdr.SVMXC__Line_Status__c !=null);
        
        System.currentPagereference().getParameters().put('ShpId',shpOrdr.Id);
        PORD_CancelShipmentOrder cnclShpOrdr =  new PORD_CancelShipmentOrder();
        cnclShpOrdr.getDisplaysave();
        cnclShpOrdr.getResultMessage();
        cnclShpOrdr.setResultMsg('Process complete');
        cnclShpOrdr.BackToRecord();
        cnclShpOrdr.DisplayMessage();
        cnclShpOrdr.PerformUpdate();
        cnclShpOrdr.getTAG001();
        cnclShpOrdr.getTAG002();
        cnclShpOrdr.getTAG003();
        cnclShpOrdr.getTAG004();
        cnclShpOrdr.getTAG005();
        cnclShpOrdr.getTAG006();
        cnclShpOrdr.getTAG007();
        cnclShpOrdr.getTAG008();
    }
    static testMethod void PORD_CancelShipmentOrder_UnitTest1() {
        SVMXC__RMA_Shipment_Order__c shpOrdr = new SVMXC__RMA_Shipment_Order__c();
        SVMXC__RMA_Shipment_Line__c ShpLineOrdr = new SVMXC__RMA_Shipment_Line__c();
        shpOrdr.SVMXC__Order_Status__c = 'Canceled';
        insert shpOrdr;  
        ShpLineOrdr.SVMXC__Line_Status__c = 'Canceled';
        ShpLineOrdr.SVMXC__RMA_Shipment_Order__c = shpOrdr.Id; 
        insert ShpLineOrdr;
        system.assert(shpOrdr.SVMXC__Order_Status__c!=null);
        system.assert(ShpLineOrdr.SVMXC__Line_Status__c !=null);
        
        System.currentPagereference().getParameters().put('ShpId',shpOrdr.Id);
        PORD_CancelShipmentOrder cnclShpOrdr =  new PORD_CancelShipmentOrder();
    }
    static testMethod void PORD_CancelShipmentOrder_UnitTest2() {
        SVMXC__RMA_Shipment_Order__c shpOrdr = new SVMXC__RMA_Shipment_Order__c();
        SVMXC__RMA_Shipment_Line__c ShpLineOrdr = new SVMXC__RMA_Shipment_Line__c();
        shpOrdr.SVMXC__Order_Status__c = 'Open';
        insert shpOrdr;  
        ShpLineOrdr.SVMXC__Line_Status__c = 'Open';
        ShpLineOrdr.SVMXC__RMA_Shipment_Order__c = shpOrdr.Id; 
        insert ShpLineOrdr;
        system.assert(shpOrdr.SVMXC__Order_Status__c!=null);
        system.assert(ShpLineOrdr.SVMXC__Line_Status__c !=null);
        
        System.currentPagereference().getParameters().put('ShpId',shpOrdr.Id);
        PORD_CancelShipmentOrder cnclShpOrdr =  new PORD_CancelShipmentOrder();
        cnclShpOrdr.PerformUpdate();
    }
    static testMethod void PORD_CancelShipmentOrder_UnitTest3() {
        SVMXC__RMA_Shipment_Order__c shpOrdr = new SVMXC__RMA_Shipment_Order__c();
        SVMXC__RMA_Shipment_Line__c ShpLineOrdr = new SVMXC__RMA_Shipment_Line__c();
        shpOrdr.SVMXC__Order_Status__c = 'Open';
        insert shpOrdr;
        ShpLineOrdr.SVMXC__Line_Status__c = 'Canceled';
        ShpLineOrdr.SVMXC__RMA_Shipment_Order__c = shpOrdr.Id;
        insert ShpLineOrdr;
        system.assert(shpOrdr.SVMXC__Order_Status__c!=null);
        system.assert(ShpLineOrdr.SVMXC__Line_Status__c !=null);
        
        System.currentPagereference().getParameters().put('ShpId',shpOrdr.Id);
        PORD_CancelShipmentOrder cnclShpOrdr =  new PORD_CancelShipmentOrder();
    }
}