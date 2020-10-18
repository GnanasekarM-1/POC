@isTest
private  with sharing class WORD_CloseWO_UT 
{
    private static SVMXC.WORD_CloseWO closeWO, closeWO1, CloseWO2;
    private static Account account;
    private static Contact contact ;
    private static Case case1;
    private static Product2  prodCloseWO;
    
    private static SVMXC__Service_Order__c woObject,woObject1;
    private static SVMXC__Installed_Product__c IBObject;
    //Objects for Profile Object    
    private static SVMXC__ServiceMax_Config_Data__c configProfile;
    //Objects for Module, Submodule
    private static SVMXC__ServiceMax_Processes__c module;
    private static SVMXC__ServiceMax_Processes__c subModule;
    
    private static SVMXC__ServiceMax_Config_Data__c Setng_useFieldtoConsider;
    private static SVMXC__ServiceMax_Config_Data__c SetngValue;
    private static SVMXC__ServiceMax_Config_Data__c SetngValuetoSet;
    
    static testMethod void WORD_CloseWO_Test()
    {
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
        
        contact = new Contact(LastName='Last',AccountId =account.Id,Email='svmxmailfortest@servicemax.com');
        insert contact;
        
        case1 = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                                                                    
                                        ContactId =contact.Id,
                                        AccountId=account.Id
                                        ); 
        insert case1; 
        prodCloseWO = new Product2(
                                Name = 'prodPR',
                                ProductCode='prodPR',
                                SVMXC__Inherit_Parent_Warranty__c =True
                                );
        insert prodCloseWO;
        
        woObject = new SVMXC__Service_Order__c(
                                                SVMXC__Company__c=account.Id,
                                                SVMXC__Contact__c=contact.Id,
                                                SVMXC__Case__c=case1.Id,
                                                SVMXC__Order_Status__c='Open',
                                                SVMXC__Priority__c='Low',
                                                SVMXC__Order_Type__c='Field Service',
                                                SVMXC__Purpose_of_Visit__c='Repair',
                                                
                                                SVMXC__Problem_Description__c='Its for Unit Test Case Of Request Receipt'
                                                );
        insert woObject;
        
        //IB Creation
        system.assertNotEquals(prodCloseWO.Id,null);
        IBObject = new SVMXC__Installed_Product__c(
                    Name = 'Test IB1',
                    SVMXC__Status__c = 'Installed',
                    SVMXC__Product__c = prodCloseWO.Id,
                    SVMXC__Date_Installed__c = System.Today(),
                    SVMXC__Contact__c = contact.Id,
                    SVMXC__Company__c = account.Id
                    );
        insert IBObject;
        
        case1.SVMXC__Component__c = IBObject.Id;
        update case1;
        
        Test.starttest();
        system.assertEquals(case1.SVMXC__Component__c,IBObject.Id);
        //Scenario to Launch Page without url parameters id 
        ApexPages.StandardController CWOStdController = new ApexPages.standardController(woObject);
        PageReference pageRef = new PageReference('Page.SVMXC.WORD_CloseWO');
        Test.setCurrentPageReference(pageRef); 
        closeWO  = new SVMXC.WORD_CloseWO(CWOStdController );
        closeWO = new SVMXC.WORD_CloseWO(CWOStdController );
        PageReference confirm   = closeWO.CloseWorkOrderConfirm();
        closeWO.setWOCloseHeader(woObject);
        Boolean Dpclose=closeWO.getDisplayClose();
        system.assertEquals(Dpclose,false);
        closeWO.setDisplayClose(true);
        Boolean CloseContinue=closeWO.getDisplayContinue();
        closeWO.setDisplayContinue(true);
        Boolean showDB=closeWO.getshowDetailBlock();
        system.assert(closeWO.getshowDetailBlock()!=null,'getshowDetailBlock Assertion failed');
        closeWO.setshowDetailBlock(true);
        PageReference cancl = closeWO.Cancel();
        PageReference  clwcn = closeWO.CloseWorkOrderConfirm();
        PageReference  clw = closeWO.CloseWorkOrder();
        closeWO.getWOCloseHeader();
        system.assert(closeWO.getWOCloseHeader()!=null,'getWOCloseHeader Assertion failed');
        
        system.assert(closeWO.getTAG001()!=null,'TAG001 assertion failed');
        system.assert(closeWO.getTAG002()!=null,'TAG002 assertion failed');
        system.assert(closeWO.getTAG003()!=null,'TAG003 assertion failed');
        system.assert(closeWO.getTAG004()!=null,'TAG004 assertion failed');
        system.assert(closeWO.getTAG005()!=null,'TAG005 assertion failed');
        system.assert(closeWO.getTAG006()!=null,'TAG006 assertion failed');
        system.assert(closeWO.getTAG007()!=null,'TAG007 assertion failed');
        system.assert(closeWO.getTAG008()!=null,'TAG008 assertion failed');
        system.assert(closeWO.getTAG009()!=null,'TAG009 assertion failed');
        system.assert(closeWO.getHLPURL()!=null,'HLPURL assertion failed');

        closeWO.AllSubModuleSettings.clear();
        closeWO.AllSubModuleSettings.put('SET003','True');
        closeWO.CloseWorkOrderConfirm();

        //closeWO.svmxTagList.clear();
        system.assert(closeWO.getTAG001()!=null,'TAG001 assertion failed');
        system.assert(closeWO.getTAG002()!=null,'TAG002 assertion failed');
        system.assert(closeWO.getTAG003()!=null,'TAG003 assertion failed');
        system.assert(closeWO.getTAG004()!=null,'TAG004 assertion failed');
        system.assert(closeWO.getTAG005()!=null,'TAG005 assertion failed');
        system.assert(closeWO.getTAG006()!=null,'TAG006 assertion failed');
        system.assert(closeWO.getTAG007()!=null,'TAG007 assertion failed');
        system.assert(closeWO.getTAG008()!=null,'TAG008 assertion failed');
        system.assert(closeWO.getTAG009()!=null,'TAG009 assertion failed');
        system.assert(closeWO.getHLPURL()!=null,'HLPURL assertion failed');
        Test.stoptest();
    }
}