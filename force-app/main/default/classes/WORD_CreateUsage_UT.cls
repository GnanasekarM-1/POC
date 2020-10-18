@isTest
private  with sharing class WORD_CreateUsage_UT {

    private static SVMXC.WORD_CreateUsage UsgObject1;
    private static Account account;
    private static Contact contact;
    private static Case case1;
    private static Product2 prod;
    private static SVMXC__Installed_Product__c ib;
    private static SVMXC__Service_Order__c workorder;
    private static RecordType rtEst;
    private static SVMXC__Service_Order_Line__c woestline1,woestline2,woestline3;
    
    private static Pricebook2 pbStd; 
    private static PricebookEntry pbe,pbe1;


    
    //============================== Variables for Configuration Setting Data =================================//

    private static List<RecordType> AllRecordTypes  = new List<RecordType>();
    private static RecordType SettgValRecordType = new RecordType();
    private static RecordType SettingDefRecType = new RecordType();
  
    //Objects for Module, Submodule
    private static SVMXC__ServiceMax_Processes__c module;
    private static SVMXC__ServiceMax_Processes__c subModule;   


    //Objects for Setting Value
    private static SVMXC__ServiceMax_Config_Data__c UsageFldMapSetng = new SVMXC__ServiceMax_Config_Data__c(); //SET012    
    private static SVMXC__ServiceMax_Config_Data__c Setng_usePriceFromPriceBook = new SVMXC__ServiceMax_Config_Data__c(); //SET003 
    private static SVMXC__ServiceMax_Config_Data__c Setng_UsagePriceBook = new SVMXC__ServiceMax_Config_Data__c();  //SET004


   //================================================ TestCases =============================================//
    static testMethod void WORD_CreateUsage_UT_Test()
    {
        //try{
       
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


        rtEst = [SELECT Id , Name FROM RecordType WHERE Name = 'Estimate' AND SobjectType ='SVMXC__Service_Order_Line__c' Limit 1];

		list<SVMXC__Service_Order_Line__c> wolineLst = new list<SVMXC__Service_Order_Line__c>();
        woestline1 = new SVMXC__Service_Order_Line__c(
                                        RecordTypeId = rtEst.Id,
                                        SVMXC__Service_Order__c = workorder.Id,
                                        SVMXC__Line_Type__c = 'Parts',
                                        SVMXC__Product__c = prod.Id,
                                        SVMXC__Serial_Number__c = ib.Id,
                                        SVMXC__Estimated_Quantity2__c = 2,
                                        SVMXC__Estimated_Price2__c = 50,
                                        SVMXC__Use_Price_From_Pricebook__c = false,
                                        SVMXC__Select__c = true
                                        );
        wolineLst.add(woestline1);

        woestline2 = new SVMXC__Service_Order_Line__c(
                                        RecordTypeId = rtEst.Id,
                                        SVMXC__Service_Order__c = workorder.Id,
                                        SVMXC__Line_Type__c = 'Labor',
                                        SVMXC__Product__c = prod.Id,
                                        SVMXC__Serial_Number__c = ib.Id,
                                        SVMXC__Estimated_Quantity2__c = 2,
                                        SVMXC__Estimated_Price2__c = 45,
                                        SVMXC__Use_Price_From_Pricebook__c = false,
                                        SVMXC__Select__c = true
                                        );
        wolineLst.add(woestline2);

        woestline3 = new SVMXC__Service_Order_Line__c(
                                        RecordTypeId = rtEst.Id,
                                        SVMXC__Service_Order__c = workorder.Id,
                                        SVMXC__Line_Type__c = 'Expenses',
                                        SVMXC__Product__c = prod.Id,
                                        SVMXC__Serial_Number__c = ib.Id,
                                        SVMXC__Estimated_Quantity2__c = 2,
                                        SVMXC__Estimated_Price2__c = 40,
                                        SVMXC__Use_Price_From_Pricebook__c = false,
                                        SVMXC__Select__c = true
                                        );
        wolineLst.add(woestline3);
		insert wolineLst;

        //============================ Configuring Standard Price for Product ===============================//
      
        pbStd = [select name, IsActive from Pricebook2 where IsStandard = true limit 1];
        /* Create a pricebook entries. */
        pbe = new PricebookEntry();
        pbe.Pricebook2Id = pbStd.id;
        pbe.Product2Id   = prod.id;
        pbe.IsActive     = true;
        pbe.UnitPrice    = 10;        
        insert pbe;

        
        Test.startTest();
        //=========================== Scenario to Launch Page without url parameters id  =====================//
        ApexPages.StandardController CUsageStdController = new ApexPages.standardController(workorder);
        PageReference pageRef1 = new PageReference('Page.SVMXC.WORD_CreateUsage');
        pageRef1.getParameters().put('id',workorder.Id);
        Test.setCurrentPageReference(pageRef1); 
        SVMXC.WORD_CreateUsage obj1 = new SVMXC.WORD_CreateUsage(CUsageStdController);
        obj1.getUserLocaleKey();
        obj1.getUserID();
        obj1.getUserOrgID();
        //system.assert(obj1.getErrorsList()!=null,'getErrorsList assertion failed');
        obj1.getErrorsList();
        system.assert(obj1.getDisplayBlockLevelMessage()!=null,'getDisplayBlockLevelMessage Assertion failed');
        obj1.getDisplayBlockLevelMessage();
        List<SVMXC__Service_Order_Line__c> objArray1 = obj1.getNewWORDPartLine();
        obj1.setNewWORDPartLine(objArray1);
        List<SVMXC__Service_Order_Line__c> objArray2 = obj1.getNewWORDLaborLine();
        obj1.setNewWORDLaborLine(objArray2);
        obj1.displayErrors();
        obj1.AddPartsLine();
        
        //============================= Scenario to qualify Cancel() & newTargetObj() ==========================//       
        PageReference cancl = obj1.Cancel();
        PageReference cqt = obj1.newTargetObj();
        PageReference del = obj1.DeleteLine();
        PageReference addlabor = obj1.AddLaborLine();
        PageReference addexp = obj1.AddExpLine();
        Boolean labcol = obj1.getDisplayLaborColumns();
        Boolean expcol = obj1.getDisplayExpColumns();
        Id prodfrmIB = obj1.SVMX_getProductIdFromIB(ib.Id);
        PageReference getprice = obj1.UpdateLineRecord();

        //============================ Scenario to qualify regular set & get methods ==========================//
        Boolean showvaliddata = obj1.getShowValidData();
        obj1.setShowValidData(true);
        List<String> listOfErrors = obj1.getErrorsList();
        Boolean dispMsg = obj1.getDisplayBlockLevelMessage();
        RecordType  estrtype = obj1.getEstRecordTypes();
        RecordType  usgrtype = obj1.getUsgRecordTypes();
        Boolean chklines = obj1.getCheckAllLines();
        obj1.setCheckAllLines(true);
        system.assertEquals(chklines,false);
        SVMXC__Service_Order__c svohdr = obj1.getWOrderHeader(workorder.Id);
        SVMXC__Service_Order__c svohdr2 = obj1.getWORDHeader();
        List<SVMXC__Service_Order_Line__c> partline = obj1.getNewWORDPartLine();
        obj1.setNewWORDPartLine(partline);
        List<SVMXC__Service_Order_Line__c> laborline = obj1.getNewWORDLaborLine();
        obj1.setNewWORDLaborLine(laborline);
        List<SVMXC__Service_Order_Line__c> expensesline = obj1.getNewWORDExpLine();
        obj1.setNewWORDExpLine(expensesline);
        SVMXC__Service_Order_Line__c workdetailsloc = obj1.getSVMX_WorkDetails();
        
        //Tags
        system.assert(obj1.getTAG005()!=null,'TAG005 assertion failed');
        system.assert(obj1.getTAG007()!=null,'TAG007 assertion failed');
        system.assert(obj1.getTAG008()!=null,'TAG008 assertion failed');
        system.assert(obj1.getTAG009()!=null,'TAG009 assertion failed');
        system.assert(obj1.getTAG011()!=null,'TAG011 assertion failed');
        system.assert(obj1.getTAG012()!=null,'TAG012 assertion failed');
        system.assert(obj1.getTAG013()!=null,'TAG013 assertion failed');
        system.assert(obj1.getTAG014()!=null,'TAG014 assertion failed');
        system.assert(obj1.getTAG015()!=null,'TAG015 assertion failed');
        system.assert(obj1.getTAG016()!=null,'TAG016 assertion failed');
        system.assert(obj1.getTAG017()!=null,'TAG017 assertion failed');
        system.assert(obj1.getTAG018()!=null,'TAG018 assertion failed');
        system.assert(obj1.getTAG019()!=null,'TAG019 assertion failed');
        system.assert(obj1.getTAG020()!=null,'TAG020 assertion failed');
        system.assert(obj1.getTAG021()!=null,'TAG021 assertion failed');
        system.assert(obj1.getTAG025()!=null,'TAG025 assertion failed');
        system.assert(obj1.getTAG026()!=null,'TAG026 assertion failed');
        system.assert(obj1.getTAG028()!=null,'TAG028 assertion failed');
        system.assert(obj1.getTAG029()!=null,'TAG029 assertion failed');
        system.assert(obj1.getTAG038()!=null,'TAG038 assertion failed');
        system.assert(obj1.getTAG039()!=null,'TAG039 assertion failed');
        system.assert(obj1.getTAG040()!=null,'TAG040 assertion failed');
        system.assert(obj1.getTAG041()!=null,'TAG041 assertion failed');
        system.assert(obj1.getTAG042()!=null,'TAG042 assertion failed');
        system.assert(obj1.getHLPURL()!=null,'HLPURL assertion failed');
        //obj1.svmxTagList.clear();
        system.assert(obj1.getTAG005()!=null,'TAG005 assertion failed');
        system.assert(obj1.getTAG007()!=null,'TAG007 assertion failed');
        system.assert(obj1.getTAG008()!=null,'TAG008 assertion failed');
        system.assert(obj1.getTAG009()!=null,'TAG009 assertion failed');
        system.assert(obj1.getTAG011()!=null,'TAG011 assertion failed');
        system.assert(obj1.getTAG012()!=null,'TAG012 assertion failed');
        system.assert(obj1.getTAG013()!=null,'TAG013 assertion failed');
        system.assert(obj1.getTAG014()!=null,'TAG014 assertion failed');
        system.assert(obj1.getTAG015()!=null,'TAG015 assertion failed');
        system.assert(obj1.getTAG016()!=null,'TAG016 assertion failed');
        system.assert(obj1.getTAG017()!=null,'TAG017 assertion failed');
        system.assert(obj1.getTAG018()!=null,'TAG018 assertion failed');
        system.assert(obj1.getTAG019()!=null,'TAG019 assertion failed');
        system.assert(obj1.getTAG020()!=null,'TAG020 assertion failed');
        system.assert(obj1.getTAG021()!=null,'TAG021 assertion failed');
        system.assert(obj1.getTAG025()!=null,'TAG025 assertion failed');
        system.assert(obj1.getTAG026()!=null,'TAG026 assertion failed');
        system.assert(obj1.getTAG028()!=null,'TAG028 assertion failed');
        system.assert(obj1.getTAG029()!=null,'TAG029 assertion failed');
        system.assert(obj1.getTAG038()!=null,'TAG038 assertion failed');
        system.assert(obj1.getTAG039()!=null,'TAG039 assertion failed');
        system.assert(obj1.getTAG040()!=null,'TAG040 assertion failed');
        system.assert(obj1.getTAG041()!=null,'TAG041 assertion failed');
        system.assert(obj1.getTAG042()!=null,'TAG042 assertion failed');
        system.assert(obj1.getHLPURL()!=null,'HLPURL assertion failed');
        
    //================== Code to modify  Current Settings and applying different Scenarios ==================//
       obj1.AllSubModuleSettings.put('SET003','TRUE');
       obj1.AllSubModuleSettings.put('SET004',null);
       obj1.ValidateAllSettings();
       obj1.AllSubModuleSettings.put('SET003','FALSE');      
       obj1.AllSubModuleSettings.put('SET004','No Price Book');
       obj1.ValidateAllSettings();
       Test.stopTest();
       
       // }catch(exception Ex){}
    }//Test Method
}