@isTest
Private  class IPRD_CreateCaseFromIB_UT
{
    private static SVMXC.IPRD_CreateCaseFromIB caseobject,caseobject1;
    private static Account account;
    private static Contact contact;
    private static Product2 prod;
    private static SVMXC__Installed_Product__c ibparent;
    private static Case ibcase;
    private static String s; 
    
   //============================== Variables for Configuration Setting Data =================================//

    private static List<RecordType> CaseRT = new List<RecordType>();
    private static RecordType SettgValRecordType = new RecordType();
    private static RecordType SettingDefRecType = new RecordType();
    
    //Objects for Module, Submodule
    private static SVMXC__ServiceMax_Processes__c module;
    private static SVMXC__ServiceMax_Processes__c subModule;   


    //Objects for Setting Value    
    private static SVMXC__ServiceMax_Config_Data__c settingcaseFieldMapId = new SVMXC__ServiceMax_Config_Data__c(); //SET001
    private static SVMXC__ServiceMax_Config_Data__c setfordefRT = new SVMXC__ServiceMax_Config_Data__c();  //SET002


    private static List<RecordType> AllRecordTypes  = new List<RecordType>();


/////================================================ TestCases =============================================//
    static testMethod void IPRD_CreateCaseFromIB_UT_Test()
    {
        
        CaseRT =[SELECT Id , Name,SobjectType  FROM RecordType where SobjectType = 'Case' ];
        
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
                                        Email='svmxmailfortest@gmail.com'
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
                                        SVMXC__Product__c = prod.Id
                                        );
        insert ibparent;

         ibcase = new Case();      
         insert ibcase;
        test.starttest();
        ////ApexPages.StandardController stdcontroller = new ApexPages.standardController(ibcase);
         System.assertNotEquals(CaseRT,null);
        //================ Scenario to Launch Page without url parameters id and Target Recordtype =============//
        
        PageReference pageRef1 = new PageReference('Page.SVMXC.IPRD_CreateCaseFromIB');
        Test.setCurrentPageReference(pageRef1); 
        caseobject1 = new SVMXC.IPRD_CreateCaseFromIB();////stdcontroller
        System.assertEquals(System.currentPageReference().getParameters().get('ibid'),null);
       //=============== Scenario to Launch Page with url parameters id and Target Recordtype =================//
        PageReference pageRef = new PageReference('Page.SVMXC.IPRD_CreateCaseFromIB');
        pageRef.getParameters().put('ibid',ibparent.Id);
        Test.setCurrentPage(pageRef);
        caseobject = new SVMXC.IPRD_CreateCaseFromIB();
        System.assertNotEquals(System.currentPageReference().getParameters().get('ibid'),null);
       //=============== All  Methods =================//
        
       caseobject.getRecordType(); 
       System.assertNotEquals(caseobject.Rtype,null);
       caseobject.getcaseHeader();
       caseobject.getIBname();
       caseobject.getTAG001();
       caseobject.getTAG002();
       caseobject.getTAG003();
       caseobject.getTAG004();
       caseobject.getTAG005();
       caseobject.getTAG008();
       caseobject.getTAG009();
       caseobject.getTAG010();
       caseobject.getTAG011();
       caseobject.getHLPURL();
       caseobject.getSelectedRT();
       caseobject.setSelectedRT(System.Label.IPRD003_TAG005); // Set selected RT to default RecordType. - RR
       
       //caseobject.svmxTagList.clear();
       caseobject.getTAG001();
       caseobject.getTAG002();
       caseobject.getTAG003();
       caseobject.getTAG004();
       caseobject.getTAG005();
       caseobject.getTAG008();
       caseobject.getTAG009();
       caseobject.getTAG010();
       caseobject.getTAG011();
       caseobject.getHLPURL();
       
       caseobject.getIsDisplay();
       caseobject.CreateCase();
       caseobject.DoCancel();
       caseobject.IBId = null;
       caseobject.isdisplay = false;
       caseobject.DoCancel();
       caseobject.getIsDisplay();
    
       CaseRT.clear();
       System.currentPagereference().getParameters().put('ibid',null);
       caseobject  = new SVMXC.IPRD_CreateCaseFromIB(); ////stdcontroller
       caseobject.getIBname();
       test.stoptest();
   }
}