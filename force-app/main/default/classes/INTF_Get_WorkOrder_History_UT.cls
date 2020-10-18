@isTest
private with sharing class INTF_Get_WorkOrder_History_UT {
    static testMethod void test1()
    {
        INTF_Get_WorkOrder_History history = new INTF_Get_WorkOrder_History();
        
        Account account = new Account(
                                        Name ='Account',
                                        ShippingStreet='ABC',
                                        ShippingCity='PQR ',
                                        ShippingState = 'XYZ',
                                        ShippingPostalCode='111',
                                        ShippingCountry='XYZ',
                                        BillingStreet='ABC',
                                        BillingCity='PQR ',
                                        BillingState = 'XYZ',
                                        BillingPostalCode='111',
                                        BillingCountry='XYZ'
                                        ); 
        insert account;
        system.assert(account.Name!=null);
        system.assert(account.ShippingStreet!=null);
        system.assert(account.ShippingPostalCode!=null);

        Contact contact = new Contact(LastName='Last',AccountId =account.Id,Email='svmxmailfortest@servicemax.com');
        insert contact;
        system.assert(contact.AccountId!=null);

        Product2 prod1 = new Product2(Name = 'Prod1', 
                                            ProductCode = '1234-1', 
                                            Family = 'Accessory',
                                            SVMXC__Product_Line__c = 'Laptop', 
                                            SVMXC__Inherit_Parent_Warranty__c =false 
                                            );
        insert prod1;
        System.assert(prod1.Name!=null);
        system.assert(prod1.Family!=null);
        
        SVMXC__Installed_Product__c IB1 = new SVMXC__Installed_Product__c(
                                            Name = 'IB1',
                                            SVMXC__Product__c = prod1.Id, 
                                            SVMXC__Company__c = account.Id  , 
                                            SVMXC__Contact__c =contact.Id,
                                            SVMXC__Status__c = 'Installed', 
                                            SVMXC__Serial_Lot_Number__c = 'Test2', 
                                            SVMXC__Date_Installed__c = System.today(), 
                                            SVMXC__Date_Shipped__c = System.today(),
                                            SVMXC__Country__c='United States'); 
        insert IB1;
        
        SVMXC__Service_Order__c existingwo = new SVMXC__Service_Order__c(SVMXC__Top_Level__c = IB1.Id, SVMXC__Order_Status__c = 'Closed',SVMXC__Company__c = account.Id);
        insert existingwo;
        
        
        
        SVMXC__Service_Order__c newwo = new SVMXC__Service_Order__c(SVMXC__Top_Level__c = IB1.Id, SVMXC__Order_Status__c = 'Open',SVMXC__Company__c = account.Id);
        insert newwo;
        
        
        INTF_WebServicesDef.INTF_Request_For_History req = new INTF_WebServicesDef.INTF_Request_For_History();
        INTF_WebServicesDef.INTF_StringMap mapinfo = new INTF_WebServicesDef.INTF_StringMap('CurrentWrkOrderId', newwo.Id);
        req.historyReqInfo = new List<INTF_WebServicesDef.INTF_StringMap>();
        req.historyReqInfo.add(mapinfo);
        
        history.INTF_Get_Product_History(req);
        
        SVMXC__Service_Order__c existingwo2 = new SVMXC__Service_Order__c(SVMXC__Component__c = IB1.Id, SVMXC__Order_Status__c = 'Closed',SVMXC__Company__c = account.Id);
        insert existingwo2;
        delete existingwo;
        
        history.INTF_Get_Product_History(req);
        
        history.INTF_Get_Account_History(req);
    }
}