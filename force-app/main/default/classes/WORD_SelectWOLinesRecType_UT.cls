@isTest(SeeAllData=true)
private  with sharing class WORD_SelectWOLinesRecType_UT {
    
    private static SVMXC.WORD_SelectWOLinesRecType RTObject1;
    private static Account account;
    private static Contact contact;
    private static Case case1;
    private static Product2 prod;
    private static SVMXC__Installed_Product__c ib;
    private static SVMXC__Service_Order__c workorder;

    //============================== Variables for Configuration Setting Data =================================//
    private static List<RecordType> AllRecordTypes  = new List<RecordType>();
    private static RecordType SettgValRecordType = new RecordType();
  
    //Objects for Module, Submodule
    private static SVMXC__ServiceMax_Processes__c module;
    private static SVMXC__ServiceMax_Processes__c subModule;   

    //Objects for Setting Value    
    private static SVMXC__ServiceMax_Config_Data__c EstUsgVFPage = new SVMXC__ServiceMax_Config_Data__c(); //SET001
    private static SVMXC__ServiceMax_Config_Data__c ReqRsptVFPage = new SVMXC__ServiceMax_Config_Data__c();  //SET002

    //================================================ TestCases =============================================//
    static testMethod void WORD_SelectWOLinesRecType_UT_Test()
    {
        try{
        AllRecordTypes =[SELECT Id , Name,SobjectType  FROM RecordType];

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

        contact = new Contact(          
                                        LastName='Last',
                                        AccountId = account.Id,
                                        Email='svmxmailfortest@servicemax.com'
                                        );
        insert contact;

        case1 = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                                                                    
                                        ContactId =contact.Id,
                                        AccountId=account.Id
                                        ); 
        insert case1;

        prod = new Product2( 
                                        Name = 'TestProd',
                                        ProductCode = '123',
                                        IsActive = true
                                        );
        insert prod;

        ib = new SVMXC__Installed_Product__c(
                                        
                                        Name = 'TestIBProd',
                                        SVMXC__Company__c = account.Id,
                                        SVMXC__Contact__c = contact.Id,
                                        SVMXC__Product__c = prod.Id,
                                        SVMXC__Status__c = 'Installed'
                                        );
        insert ib;

        workorder = new SVMXC__Service_Order__c(
                                        SVMXC__Company__c = account.Id,
                                        SVMXC__Contact__c = contact.Id,
                                        SVMXC__Case__c = case1.Id,
                                        SVMXC__Order_Status__c = 'Open',
                                        SVMXC__Priority__c = 'Medium',
                                        SVMXC__Order_Type__c = 'Field Service'
                                        );
        insert workorder;

        Test.starttest();
        ApexPages.StandardController cntrlr = new ApexPages.standardController(workorder);
        System.currentPageReference().getParameters().put('id',workorder.Id);
        SVMXC.WORD_SelectWOLinesRecType objSelRT = new SVMXC.WORD_SelectWOLinesRecType(cntrlr);
        
        //call the methods in the class
        PageReference cancl = objSelRT.Cancel();
        
        //set & get methods
        String recType = objSelRT.getSelectedRecordType();
        objSelRT.setSelectedRecordType(recType);
        system.assert(objSelRT.getShowValidData()!=null,'getShowValidData assertion failed');
        Boolean showvaliddata = objSelRT.getShowValidData();
        objSelRT.setShowValidData(true);
        objSelRT.AddToErrorsList('Msg');
        List<String> listOfErrors = objSelRT.getErrorsList();
        objSelRT.DisplayErrorsNWarnings();
        system.assertEquals(objSelRT.getDisplayBlockLevelMessage(),false,'getDisplayBlockLevelMessage value is incorrect');
        Boolean dispMsg = objSelRT.getDisplayBlockLevelMessage();
        List<SelectOption> objrectype = objSelRT.getObjectRecordTypes();
        RecordType  estrtype = objSelRT.getEstRecordTypes();
        RecordType  usgrtype = objSelRT.getUsgRecordTypes();
        PageReference LaunchPages = objSelRT.LaunchAddLines();
        
        //TAGS
        system.assert(objSelRT.getTAG001()!=null,'TAG001 assertion failed');
        system.assert(objSelRT.getTAG002()!=null,'TAG002 assertion failed');
        system.assert(objSelRT.getTAG003()!=null,'TAG003 assertion failed');
        system.assert(objSelRT.getTAG004()!=null,'TAG004 assertion failed');
        system.assert(objSelRT.getTAG005()!=null,'TAG005 assertion failed');
        system.assert(objSelRT.getTAG006()!=null,'TAG006 assertion failed');
        system.assert(objSelRT.getTAG007()!=null,'TAG007 assertion failed');
        system.assert(objSelRT.getTAG008()!=null,'TAG008 assertion failed');
        system.assert(objSelRT.getTAG009()!=null,'TAG009 assertion failed');
        system.assert(objSelRT.getHLPURL()!=null,'HLPURL assertion failed');
        //objSelRT.svmxTagList.clear();
        system.assert(objSelRT.getTAG001()!=null,'TAG001 assertion failed');
        system.assert(objSelRT.getTAG002()!=null,'TAG002 assertion failed');
        system.assert(objSelRT.getTAG003()!=null,'TAG003 assertion failed');
        system.assert(objSelRT.getTAG004()!=null,'TAG004 assertion failed');
        system.assert(objSelRT.getTAG005()!=null,'TAG005 assertion failed');
        system.assert(objSelRT.getTAG006()!=null,'TAG006 assertion failed');
        system.assert(objSelRT.getTAG007()!=null,'TAG007 assertion failed');
        system.assert(objSelRT.getTAG008()!=null,'TAG008 assertion failed');
        system.assert(objSelRT.getTAG009()!=null,'TAG009 assertion failed');
        system.assert(objSelRT.getHLPURL()!=null,'HLPURL assertion failed');
        Test.stoptest();
    
        }catch(Exception ex){}
    }
}