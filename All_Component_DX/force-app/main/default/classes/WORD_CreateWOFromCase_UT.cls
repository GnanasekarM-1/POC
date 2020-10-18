@isTest
private  with sharing class WORD_CreateWOFromCase_UT {

    private static SVMXC.WORD_CreateWOFromCase woObject1,woObject2;
    private static Account account;
    private static Contact contact;
    private static Product2 prod;
    private static SVMXC__Installed_Product__c ib;
    private static Case case1;

//============================== Variables for Configuration Setting Data =================================//
    private static List<RecordType> rtSVMX_Processes = new List<RecordType>();
    private static List<RecordType> rtSVMX_ConfData = new List<RecordType>();
    
    //Objects for Profile Object    
    private static SVMXC__ServiceMax_Config_Data__c configProfile;
    
    //Objects for Module, Submodule
    private static SVMXC__ServiceMax_Processes__c module;
    private static SVMXC__ServiceMax_Processes__c subModule; 
    
    // Objects for Setting Def
    private static SVMXC__ServiceMax_Processes__c settingDefForDefRecType;
    private static SVMXC__ServiceMax_Processes__c settingDefForSelWolRecTypeVFName;
    
    //Objects for Setting Value
    private static SVMXC__ServiceMax_Config_Data__c settingValForDefRecType;
    private static SVMXC__ServiceMax_Config_Data__c settingValForSelWolRecTypeVFName;

//================================================ TestCases =============================================//
    static testMethod void WORD_CreateWOFromCase_UT_Test()
    {
        //try        {
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

        case1 = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                                                                    
                                        ContactId =contact.Id,
                                        AccountId=account.Id
                                        ); 
        insert case1;
        
        test.starttest();
        
        //=============== Scenario to Launch Page with url parameters id and Target Recordtype =================//
        PageReference pageRef = new PageReference('Page.SVMXC.WORD_CreateWOFromCase');
        pageRef.getParameters().put('cid',case1.Id);
        Test.setCurrentPage(pageRef);
        SVMXC.WORD_CreateWOFromCase objWO = new SVMXC.WORD_CreateWOFromCase(); ////CWOStdController
        objWO.getUserLocaleKey();
        objWO.getUserID();
        objWO.getUserOrgID();
        objWO.getRecTypSize();
        system.assert(objWO.getRecTypSize()!=null);
         //============================= Scenario to qualify Cancel() & newTargetObj() ==========================//
        PageReference cancl = objWO.Cancel();
        PageReference cwo = objWO.newTargetObj();

        //============================ Scenario to qualify regular set & get methods ==========================//
        String recType = objWO.getSelectedRecordType();
        objWO.setSelectedRecordType(recType);
        Boolean showvaliddata = objWO.getShowValidData();
        system.assert(objWO.getShowValidData(),'getShowValidData Assertion failed');
        objWO.setShowValidData(true);
        List<SelectOption> rectypes = objWO.getObjectRecordTypes();
        List<String> listOfErrors = objWO.getErrorsList();
        Boolean dispMsg = objWO.getDisplayBlockLevelMessage();
        system.assertEquals(dispMsg,false);
        Case casehdr = objWO.getCaseHeader();
        SVMXC__Service_Order__c wohdr = objWO.getWOHeader();

        system.assert(objWO.getTAG001()!=null,'TAG001 assertion failed');
        system.assert(objWO.getTAG002()!=null,'TAG002 assertion failed');
        system.assert(objWO.getTAG003()!=null,'TAG003 assertion failed');
        system.assert(objWO.getTAG004()!=null,'TAG004 assertion failed');
        system.assert(objWO.getTAG005()!=null,'TAG005 assertion failed');
        system.assert(objWO.getTAG006()!=null,'TAG006 assertion failed');
        system.assert(objWO.getTAG007()!=null,'TAG007 assertion failed');
        system.assert(objWO.getTAG008()!=null,'TAG008 assertion failed');
        system.assert(objWO.getTAG009()!=null,'TAG009 assertion failed');
        system.assert(objWO.getTAG010()!=null,'TAG010 assertion failed');
        system.assert(objWO.getHLPURL()!=null,'HLPURL assertion failed');
        //objWO.svmxTagList.clear();          
        system.assert(objWO.getTAG001()!=null,'TAG001 assertion failed');
        system.assert(objWO.getTAG002()!=null,'TAG002 assertion failed');
        system.assert(objWO.getTAG003()!=null,'TAG003 assertion failed');
        system.assert(objWO.getTAG004()!=null,'TAG004 assertion failed');
        system.assert(objWO.getTAG005()!=null,'TAG005 assertion failed');
        system.assert(objWO.getTAG006()!=null,'TAG006 assertion failed');
        system.assert(objWO.getTAG007()!=null,'TAG007 assertion failed');
        system.assert(objWO.getTAG008()!=null,'TAG008 assertion failed');
        system.assert(objWO.getTAG009()!=null,'TAG009 assertion failed');
        system.assert(objWO.getTAG010()!=null,'TAG010 assertion failed');
        system.assert(objWO.getHLPURL()!=null,'HLPURL assertion failed');

        //================== Code to modify  Current Settings and applying different Scenarios ==================//
        //Clearing all the Settings       
        objWO.AllSubModuleSettings.clear();
        objWO.ValidateAllSettings();
        system.assertNotEquals(case1.Id,null);
        PageReference pageRef3 = new PageReference('Page.SVMXC.WORD_CreateWOFromCase');
        pageRef.getParameters().put('id',case1.Id);
        Test.setCurrentPage(pageRef);
        
        //Populating different values for Settings
        //Setng_WOLineRecTypeVFName - SET003
        //Setng_DefRecType - SET004
        objWO.AllSubModuleSettings.put('SET003','');
        objWO.AllSubModuleSettings.put('SET004','TRUE');
        objWO.ValidateAllSettings();
        objWO.AllSubModuleSettings.put('SET003','');
        objWO.AllSubModuleSettings.put('SET004','FALSE');
        objWO.ValidateAllSettings();
        test.stoptest();
    }
}//Test Method