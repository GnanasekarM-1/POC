@isTest
private class IPRD_WorkOrderFromIB_UT {

    static testMethod void IPRD_WOfromIB_test()
    {
        //Data creation
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
        System.assert(account.Name!=null);
        System.assert(account.ShippingStreet!=null);
        System.assert(account.ShippingCity!=null);

        Contact contact = new Contact(LastName='Last',AccountId =account.Id,Email='svmxmailfortest@servicemax.com');
        insert contact;
        System.assert(contact.LastName!=null);
        System.assert(contact.AccountId!=null);

        Product2 prod1 = new Product2(Name = 'Prod1', 
                                            ProductCode = '1234-1', 
                                            Family = 'Accessory',
                                            SVMXC__Product_Line__c = 'Laptop', 
                                            SVMXC__Inherit_Parent_Warranty__c =false 
                                            );
        insert prod1;
        
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
        System.assert(IB1.Name!=null);
        System.assert(IB1.SVMXC__Product__c!=null);
        System.assert(IB1.SVMXC__Company__c!=null);
        
        SVMXC__Installed_Product__c IB2 = new SVMXC__Installed_Product__c(
                                            Name = 'IB1',
                                            SVMXC__Product__c = prod1.Id, 
                                            SVMXC__Parent__c = IB1.Id,
                                            SVMXC__Top_Level__c = IB1.Id,
                                            SVMXC__Company__c = account.Id , 
                                            SVMXC__Contact__c =contact.Id,
                                            SVMXC__Status__c = 'Installed', 
                                            SVMXC__Serial_Lot_Number__c = 'Test2', 
                                            SVMXC__Date_Installed__c = System.today(), 
                                            SVMXC__Date_Shipped__c = System.today(),
                                            SVMXC__Country__c='United States'); 
        insert IB2;
        System.assert(IB2.Name!=null);
        System.assert(IB2.SVMXC__Product__c!=null);
        System.assert(IB2.SVMXC__Company__c!=null);
        
        List<Recordtype> Rtype = [Select id,Name From RecordType where SobjectType = 'SVMXC__Service_Order__c' ];

        system.currentPageReference().getParameters().put('ibid', IB2.Id);
        
        
        //Instantiation of class
        IPRD_WorkOrderFromIB WOIB = new IPRD_WorkOrderFromIB();
        WOIB.getIBname();
        WOIB.getworkOrder();
        WOIB.getTAG001();
        WOIB.getTAG002();
        WOIB.getTAG003();
        WOIB.getTAG004();
        WOIB.getTAG005();
        WOIB.getTAG008();
        WOIB.getTAG009();
        WOIB.getTAG010();
        WOIB.getTAG011();
        WOIB.getHLPURL();
        WOIB.getRecordType();
        WOIB.getSelectedRT();
        WOIB.setSelectedRT('');
        WOIB.getIsDisplay();
        WOIB.DoCancel();
        WOIB.DoCancel();
        WOIB.CreateWO();
    }
     
}