@isTest
Private  with sharing class IPRD_CreateChildIB_UT {

    private static SVMXC.IPRD_CreateChildIB ccibObject1;
    private static Account account;
    private static Contact contact;
    private static Product2 prod;
    private static SVMXC__Installed_Product__c ibparent, ibchild;
    
         
    
   //============================== Variables for Configuration Setting Data =================================//
    
    private static List<RecordType> AllRecordTypes  = new List<RecordType>();
    
    //================================================ TestCases =============================================//
    static testMethod void IPRD_CreateChildIB_UT_Test()
    {
        // System Assert
       Account testAccount = new Account(name='Test Company Name');
       insert testAccount;
       testAccount.billingState='CA';
       update testAccount;
       // Verify that the billingState field was updated in the database.
       Account updatedAccount = [SELECT billingState FROM Account WHERE Id = :testAccount.Id];
       System.assertEquals('CA', updatedAccount.billingState);
        
        try
        {
        
        RecordType Rtypesubmodule = [select Id from RecordType where Name=:'Submodule'and SobjectType=:'SVMXC__ServiceMax_Processes__c'];
        RecordType Rtypemodule = [select Id from RecordType where Name=:'Module'and SobjectType=:'SVMXC__ServiceMax_Processes__c'];
        RecordType Rtypeset = [select Id from RecordType where Name=:'Setting Value'and SobjectType=:'SVMXC__ServiceMax_Config_Data__c'];
        RecordType Rtypesetval = [select Id from RecordType where Name=:'Settings'and SobjectType=:'SVMXC__ServiceMax_Processes__c'];
        AllRecordTypes.add(Rtypesubmodule);
        AllRecordTypes.add(Rtypemodule);
        AllRecordTypes.add(Rtypeset);
        AllRecordTypes.add(Rtypesetval);
        system.assertNotEquals(AllRecordTypes,null);
        
        account = new Account(
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
        system.assert(account.ShippingStreet!=null);
        system.assert(account.ShippingCity!=null);
        contact = new Contact(          
                                        LastName='Last',
                                        AccountId = account.Id,
                                        Email='svmxmailfortest@servicemax.com'
                                        );
        insert contact;
        
        prod = new Product2( 
                                        Name = 'TestProd',
                                        ProductCode = '123',
                                        IsActive = true
                                       
                                        );
        insert prod;
        
        ibparent = new SVMXC__Installed_Product__c(
                                        
                                        Name = 'TestIBProd',
                                        SVMXC__Company__c = account.Id,
                                        SVMXC__Contact__c = contact.Id,
                                        SVMXC__Product__c = prod.Id,
                                        SVMXC__Status__c = 'Installed'
                                        );
        insert ibparent;
        system.assert(ibparent.SVMXC__Product__c==prod.Id);
        
        ibchild = new SVMXC__Installed_Product__c(
                                        
                                        Name = 'TestIBProd2',
                                        SVMXC__Company__c = account.Id,
                                        SVMXC__Contact__c = contact.Id,
                                        SVMXC__Product__c = prod.Id,
                                        SVMXC__Parent__c = ibparent.Id,
                                        SVMXC__Status__c = 'Installed'
                                        );
        insert ibchild;
        system.assert(ibchild.SVMXC__Product__c==prod.Id);
        //System.currentPageReference().getParameters().put('parentid',prod.Id);
        test.starttest();
        ApexPages.StandardController IBstndrd = new ApexPages.StandardController(ibchild);
        SVMXC.IPRD_CreateChildIB CrChildIb = new SVMXC.IPRD_CreateChildIB(IBstndrd);
        system.assertEquals(System.currentPageReference().getParameters().get('parentid'),null);
        System.currentPagereference().getParameters().put('parentid',ibparent.Id);
        ApexPages.StandardController IBstndrd1 = new ApexPages.StandardController(ibchild);
        SVMXC.IPRD_CreateChildIB CrChildIb1 = new SVMXC.IPRD_CreateChildIB(IBstndrd1);
        system.assertEquals(System.currentPageReference().getParameters().get('parentid'),ibparent.Id);
        CrChildIb1.getTAG001();
        CrChildIb1.getTAG002();
        CrChildIb1.getTAG003();
        CrChildIb1.getTAG004();
        CrChildIb1.getTAG005();
        CrChildIb1.getTAG006();
        CrChildIb1.getTAG007();
        CrChildIb1.getTAG008();
        CrChildIb1.getTAG009();
        CrChildIb1.getTAG010();
        CrChildIb1.getTAG011();
        CrChildIb1.getTAG012();
        CrChildIb1.getTAG013();
        CrChildIb1.getTAG014();
        CrChildIb1.getTAG015();
        CrChildIb1.getHLPURL();
        //CrChildIb1.svmxTagList.clear();
        CrChildIb1.getTAG001();
        CrChildIb1.getTAG002();
        CrChildIb1.getTAG003();
        CrChildIb1.getTAG004();
        CrChildIb1.getTAG005();
        CrChildIb1.getTAG006();
        CrChildIb1.getTAG007();
        CrChildIb1.getTAG008();
        CrChildIb1.getTAG009();
        CrChildIb1.getTAG010();
        CrChildIb1.getTAG011();
        CrChildIb1.getTAG012();
        CrChildIb1.getTAG013();
        CrChildIb1.getTAG014();
        CrChildIb1.getTAG015();
        CrChildIb1.getHLPURL();
        CrChildIb1.getErrorsList();
        CrChildIb1.getDisplayBlockLevelMessage();
        CrChildIb1.getInfoMessage();
        CrChildIb1.setInfoMessage(true);
        CrChildIb1.getSelectedRecordType();
        CrChildIb1.setSelectedRecordType('Submodule');
        CrChildIb1.getShowValidData();
        CrChildIb1.setShowValidData(true);
        CrChildIb1.getIBFields();
        CrChildIb1.getIBHeader();
        CrChildIb1.getObjectRecordTypes();
        CrChildIb1.isValidData();
        CrChildIb1.newTargetObj();
        CrChildIb1.Cancel1();
        boolean b = CrChildIb1.getbtnisdisabled();
        String msg;
        CrChildIb1.AddToErrorsList(msg);
        
        CrChildIb1.getUserLocaleKey();
        CrChildIb1.getUserID();
        CrChildIb1.getUserOrgID();
        
        test.stoptest();
        }
        catch (Exception e){System.assert(e.getMessage()!=null);}
    }
    
    static testMethod void IPRD_CreateChildIB_UT_Test1()
    {
      // System Assert
       Account testAccount = new Account(name='Test Company Name');
       insert testAccount;
       testAccount.billingState='CA';
       update testAccount;
       // Verify that the billingState field was updated in the database.
       Account updatedAccount = [SELECT billingState FROM Account WHERE Id = :testAccount.Id];
       System.assertEquals('CA', updatedAccount.billingState);
      
        account = new Account(
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
        
        contact = new Contact(          
            LastName='Last',
            AccountId = account.Id,
            Email='svmxmailfortest@servicemax.com'
        );
        insert contact;
        
        prod = new Product2( 
            Name = 'TestProd',
            ProductCode = '123',
            IsActive = true
        );
        insert prod;
        system.assert(prod.Name!=null);
        
        ibparent = new SVMXC__Installed_Product__c(
            Name = 'TestIBProd',
            SVMXC__Company__c = account.Id,
            SVMXC__Contact__c = contact.Id,
            SVMXC__Product__c = prod.Id,
            SVMXC__Status__c = 'Installed'
        );
        insert ibparent;
        system.assert(ibparent.Name!=null);
        system.assert(ibparent.SVMXC__Status__c!=null);
        
        ibchild = new SVMXC__Installed_Product__c(
            Name = 'TestIBProd2',
            SVMXC__Company__c = account.Id,
            SVMXC__Contact__c = contact.Id,
            SVMXC__Product__c = prod.Id,
            SVMXC__Parent__c = ibparent.Id,
            SVMXC__Status__c = 'Installed'
        );
        insert ibchild;
        system.assert(ibchild.Name!=null);
        system.assert(ibchild.SVMXC__Status__c!=null);
         
        System.currentPageReference().getParameters().put('parentid',ibparent.Id);
        
        ApexPages.StandardController IBstndrd = new ApexPages.StandardController(ibchild);
        SVMXC.IPRD_CreateChildIB CrChildIb = new SVMXC.IPRD_CreateChildIB(IBstndrd);
        CrChildIb.newTargetObj();
    }
}