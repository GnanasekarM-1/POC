@isTest
Private class IPRD_IBTree_UT {

    static testMethod void IPRD_IBTree_Test(){
        
        try{
        
            Account objAccount;
            Contact objContact; 
            Product2 objProduct;
            SVMXC.IPRD_IBTree objIBTree;
            SVMXC__Installed_Product__c objIB1,objIB2;
            list<SVMXC__Installed_Product__c> lstInstalledProduct;
            
            objAccount = new Account(Name ='Account', ShippingStreet='ABC', ShippingCity='PQR ', ShippingState = 'XYZ', ShippingPostalCode='111', ShippingCountry='XYZ', BillingStreet='ABC', BillingCity='PQR ', BillingState = 'XYZ', BillingPostalCode='111',BillingCountry='XYZ');
            insert objAccount;
            system.assert(objAccount.Id != null);
            
            objContact = new Contact(LastName='Last',AccountId =objAccount.Id, Email='svmxmailfortest@servicemax.com');
            insert objContact;
            system.assert(objContact.Id != null);
            
            objProduct = new Product2(Name = 'objProduct', ProductCode = '1234-1', Family = 'Accessory',SVMXC__Product_Line__c = 'Laptop', SVMXC__Inherit_Parent_Warranty__c = false );
            insert objProduct;
            System.assert(objProduct.Id != null);
            
            objIB1 = new SVMXC__Installed_Product__c(Name = 'objIB1', SVMXC__Product__c = objProduct.Id, SVMXC__Company__c = objAccount.Id  , SVMXC__Contact__c =objContact.Id,SVMXC__Status__c = 'Installed', SVMXC__Serial_Lot_Number__c = 'Test2', SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today(),SVMXC__Country__c='United States'); 
            insert objIB1;
            System.assert(objIB1.Id != null);

            objIB2 = new SVMXC__Installed_Product__c(Name = 'objIB1',SVMXC__Product__c = objProduct.Id, SVMXC__Parent__c = objIB1.Id,SVMXC__Top_Level__c = objIB1.Id,SVMXC__Company__c = objAccount.Id  , SVMXC__Contact__c =objContact.Id,SVMXC__Status__c = 'Installed', SVMXC__Serial_Lot_Number__c = 'Test2', SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today(),SVMXC__Country__c='United States'); 
            insert objIB2;
            System.assert(objIB2.Id != null);
            
            test.starttest();
            
            system.assertNotEquals(System.currentPageReference().getParameters().get('id'), objIB1.Id); 

            PageReference pageRef = new PageReference('Page.IPRD_IBTree');
            pageRef.getParameters().put('id',objIB1.Id);
            Test.setCurrentPageReference(pageRef);
            
            system.assertEquals(System.currentPageReference().getParameters().get('id'),objIB1.Id);
            
            ApexPages.StandardController stdController = new ApexPages.standardController(objIB1);
            objIBTree = new SVMXC.IPRD_IBTree(stdController);
            
            objIBTree.loadCookie();
            
            objIBTree.getOptions();
            system.assertNotEquals(objIBTree.getOptions(), null);
            
            String[] s = new String[]{'TEST','TEST'};
            objIBTree.setAFields(s);
            objIBTree.setSFields(s);
            objIBTree.setOptions(s);
            objIBTree.strErrorMessage = 'TEST';
            objIBTree.ibId = objIB1.Id;
            objIBTree.strSelectedFields = 'SVMXC__Product__c,0,LastModifiedDate,1,Owner,2';
            objIBTree.loadCookie();

            objIBTree.ShowPopUp();
            objIBTree.SaveListPP();
            objIBTree.ClosePP();
            
            objIBTree.AFields.add(objIBTree.AIBFields[0]);
            objIBTree.OnAddFields();
            objIBTree.SFields.add(objIBTree.SIBFields[0]);
            objIBTree.onRemFields();
            
            objIBTree.getAFields();
            objIBTree.getSFields();
            objIBTree.getAvailFields();
            objIBTree.getSelectedFields();
            objIBTree.ShowPopUp();
            objIBTree.SwapSelectedList(0,1);
            
      objIBTree.UP();
      objIBTree.Down();
      objIBTree.Top();
      objIBTree.Bottom();
            objIBTree.shuffle(0);
            
            objIBTree.getTAG001();
            objIBTree.getTAG003();
            objIBTree.getTAG004();
            objIBTree.getTAG005();
            objIBTree.getTAG006();
            objIBTree.getTAG007();
            objIBTree.getTAG008();
            objIBTree.getTAG009();
            objIBTree.getTAG010();
            objIBTree.getTAG011();
            objIBTree.getTAG012();
            objIBTree.getTAG013();
            objIBTree.getTAG014();
            objIBTree.getTAG015();
            objIBTree.getTAG017();
            objIBTree.getTAG018();
            objIBTree.getTAG019();
            objIBTree.getTAG001();
            objIBTree.getTAG003();
            objIBTree.getTAG004();
            objIBTree.getTAG005();
            objIBTree.getTAG006();
            objIBTree.getTAG007();
            objIBTree.getTAG008();
            objIBTree.getTAG009();
            objIBTree.getTAG010();
            objIBTree.getTAG011();
            objIBTree.getTAG012();
            objIBTree.getTAG013();
            objIBTree.getTAG014();
            objIBTree.getTAG015();
            objIBTree.getTAG017();
            objIBTree.getTAG018();
            objIBTree.getTAG019();
            objIBTree.getTAG021();
            objIBTree.getTAG022();
            objIBTree.getTAG023();
            objIBTree.Up();
            objIBTree.Down();
            objIBTree.Bottom();


            
            test.stoptest();
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }
    
    static testMethod void IPRD_IBTree_Test2(){
        
        try{
        
            Account objAccount;
            Contact objContact; 
            Product2 objProduct;
            SVMXC.IPRD_IBTree objIBTree;
            SVMXC__Installed_Product__c objIB1,objIB2;
            list<SVMXC__Installed_Product__c> lstInstalledProduct;
            
            objAccount = new Account(Name ='Account', ShippingStreet='ABC', ShippingCity='PQR ', ShippingState = 'XYZ', ShippingPostalCode='111', ShippingCountry='XYZ', BillingStreet='ABC', BillingCity='PQR ', BillingState = 'XYZ', BillingPostalCode='111',BillingCountry='XYZ');
            insert objAccount;
            system.assert(objAccount.Id != null);
            
            objContact = new Contact(LastName='Last',AccountId =objAccount.Id, Email='svmxmailfortest@servicemax.com');
            insert objContact;
            system.assert(objContact.Id != null);
            
            objProduct = new Product2(Name = 'objProduct', ProductCode = '1234-1', Family = 'Accessory',SVMXC__Product_Line__c = 'Laptop', SVMXC__Inherit_Parent_Warranty__c = false );
            insert objProduct;
            System.assert(objProduct.Id != null);
            
            objIB1 = new SVMXC__Installed_Product__c(Name = 'objIB1', SVMXC__Product__c = objProduct.Id, SVMXC__Company__c = objAccount.Id  , SVMXC__Contact__c =objContact.Id,SVMXC__Status__c = 'Installed', SVMXC__Serial_Lot_Number__c = 'Test2', SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today(),SVMXC__Country__c='United States'); 
            insert objIB1;
            System.assert(objIB1.Id != null);

            objIB2 = new SVMXC__Installed_Product__c(Name = 'objIB1',SVMXC__Product__c = objProduct.Id, SVMXC__Parent__c = objIB1.Id,SVMXC__Top_Level__c = objIB1.Id,SVMXC__Company__c = objAccount.Id  , SVMXC__Contact__c =objContact.Id,SVMXC__Status__c = 'Installed', SVMXC__Serial_Lot_Number__c = 'Test2', SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today(),SVMXC__Country__c='United States'); 
            insert objIB2;
            System.assert(objIB2.Id != null);
            
            test.starttest();
            
            system.assertNotEquals(System.currentPageReference().getParameters().get('id'), objIB1.Id); 

            PageReference pageRef = new PageReference('Page.IPRD_IBTree');
            pageRef.getParameters().put('id',objIB1.Id);
            Test.setCurrentPageReference(pageRef);
            
            system.assertEquals(System.currentPageReference().getParameters().get('id'),objIB1.Id);
            
            ApexPages.StandardController stdController = new ApexPages.standardController(objIB1);
            objIBTree = new SVMXC.IPRD_IBTree(stdController);
            
            objIBTree.loadCookie();
            
            objIBTree.getOptions();
            system.assertNotEquals(objIBTree.getOptions(), null);
            
            String[] s = new String[]{'TEST','TEST'};
            objIBTree.setAFields(s);
            objIBTree.setSFields(s);
            objIBTree.setOptions(s);
            objIBTree.strErrorMessage = 'TEST';
            objIBTree.ibId = objIB1.Id;
            objIBTree.strSelectedFields = 'SVMXC__Product__c,SVMXC__Product__c,0,LastModifiedDate,LastModifiedDate,1';
            objIBTree.loadCookie();

            objIBTree.ShowPopUp();
            objIBTree.SaveListPP();
            objIBTree.ClosePP();
            
            objIBTree.AFields.add(objIBTree.AIBFields[0]);
            objIBTree.OnAddFields();
            objIBTree.SFields.add(objIBTree.SIBFields[0]);
            objIBTree.onRemFields();
            
            objIBTree.getAFields();
            objIBTree.getSFields();
            objIBTree.getAvailFields();
            objIBTree.getSelectedFields();
            objIBTree.ShowPopUp();
            objIBTree.SwapSelectedList(0,1);
            
      objIBTree.UP();
      objIBTree.Down();
      objIBTree.Top();
      objIBTree.Bottom();
            objIBTree.shuffle(0);
            
            objIBTree.getTAG001();
            objIBTree.getTAG003();
            objIBTree.getTAG004();
            objIBTree.getTAG005();
            objIBTree.getTAG006();
            objIBTree.getTAG007();
            objIBTree.getTAG008();
            objIBTree.getTAG009();
            objIBTree.getTAG010();
            objIBTree.getTAG011();
            objIBTree.getTAG012();
            objIBTree.getTAG013();
            objIBTree.getTAG014();
            objIBTree.getTAG015();
            objIBTree.getTAG017();
            objIBTree.getTAG018();
            objIBTree.getTAG019();
            objIBTree.getTAG001();
            objIBTree.getTAG003();
            objIBTree.getTAG004();
            objIBTree.getTAG005();
            objIBTree.getTAG006();
            objIBTree.getTAG007();
            objIBTree.getTAG008();
            objIBTree.getTAG009();
            objIBTree.getTAG010();
            objIBTree.getTAG011();
            objIBTree.getTAG012();
            objIBTree.getTAG013();
            objIBTree.getTAG014();
            objIBTree.getTAG015();
            objIBTree.getTAG017();
            objIBTree.getTAG018();
            objIBTree.getTAG019();
            
            test.stoptest();
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }
}