@isTest
private  with sharing class WORD_CreateWOEstUsgLines_UT {    
    //private static SVMXC.WORD_CreateWOEstUsgLines EstUsgObject1;
    private static Account account;
    private static Contact contact;
    private static Case case1;
    private static Product2 prod;
    private static SVMXC__Installed_Product__c ib;
    private static SVMXC__Service_Order__c workorder;
    private static SVMXC__Service_Order_Line__c woestline1,woestline2,woestline3,woestline4,woestline5,woestline6;
    private static RecordType rtUsg,rtEst;
    private static Pricebook2 pbStd; 
    private static PricebookEntry pbe,pbe1;

    private static List<SVMXC__Service_Order_Line__c> svoUsgPrtLineArray = new List<SVMXC__Service_Order_Line__c>();
    private static List<SVMXC__Service_Order_Line__c> svoUsgLabLineArray = new List<SVMXC__Service_Order_Line__c>();
    private static List<SVMXC__Service_Order_Line__c> svoUsgExpLineArray = new List<SVMXC__Service_Order_Line__c>();
    private static List<SVMXC__Service_Order_Line__c> svoUsgEstLineArray = new List<SVMXC__Service_Order_Line__c>();
    private static List<SVMXC__Service_Order_Line__c> svoEstLabLineArray = new List<SVMXC__Service_Order_Line__c>();
    private static List<SVMXC__Service_Order_Line__c> svoEstExpLineArray = new List<SVMXC__Service_Order_Line__c>();


    //============================== Variables for Configuration Setting Data =================================//

    private static List<RecordType> AllRecordTypes  = new List<RecordType>();
    private static RecordType SettgValRecordType = new RecordType();
    private static RecordType SettingDefRecType = new RecordType();
  
    //Objects for Module, Submodule
    private static SVMXC__ServiceMax_Processes__c module;
    private static SVMXC__ServiceMax_Processes__c subModule;   


    //Objects for Setting Value    
    private static SVMXC__ServiceMax_Config_Data__c UsgSetng_usePriceFromPriceBook = new SVMXC__ServiceMax_Config_Data__c(); //SET003
    private static SVMXC__ServiceMax_Config_Data__c Setng_UsagePriceBook = new SVMXC__ServiceMax_Config_Data__c();  //SET004
    private static SVMXC__ServiceMax_Config_Data__c EstSetng_usePriceFromPriceBook = new SVMXC__ServiceMax_Config_Data__c(); //SET005
    private static SVMXC__ServiceMax_Config_Data__c Setng_EstPriceBook = new SVMXC__ServiceMax_Config_Data__c();  //SET006


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
                                        //CurrencyISOCode = 'USD'
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
                                        //CurrencyIsoCode = 'USD'
                                        );
        insert workorder;
        
        rtUsg = [SELECT Id , Name FROM RecordType WHERE Name = 'Usage/Consumption' AND SobjectType ='SVMXC__Service_Order_Line__c' Limit 1];

        rtEst = [SELECT Id , Name FROM RecordType WHERE Name = 'Estimate' AND SobjectType ='SVMXC__Service_Order_Line__c' Limit 1];
        list<SVMXC__Service_Order_Line__c> woLineList = new list<SVMXC__Service_Order_Line__c>();
        woestline1 = new SVMXC__Service_Order_Line__c(
                                        RecordTypeId = rtUsg.Id,
                                        SVMXC__Service_Order__c = workorder.Id,
                                        SVMXC__Line_Type__c = 'Parts',
                                        SVMXC__Product__c = prod.Id,
                                        SVMXC__Serial_Number__c = ib.Id,
                                        SVMXC__Estimated_Quantity2__c = 2,
                                        SVMXC__Estimated_Price2__c = 50,
                                        SVMXC__Use_Price_From_Pricebook__c = true,
                                        SVMXC__Select__c = true
                                        );
        woLineList.add(woestline1);

        woestline2 = new SVMXC__Service_Order_Line__c(
                                        RecordTypeId = rtUsg.Id,
                                        SVMXC__Service_Order__c = workorder.Id,
                                        SVMXC__Line_Type__c = 'Labor',
                                        SVMXC__Product__c = prod.Id,
                                        SVMXC__Serial_Number__c = ib.Id,
                                        SVMXC__Estimated_Quantity2__c = 2,
                                        SVMXC__Estimated_Price2__c = 50,
                                        SVMXC__Use_Price_From_Pricebook__c = true,
                                        SVMXC__Select__c = true
                                        );
        woLineList.add(woestline2);

                
        woestline3 = new SVMXC__Service_Order_Line__c(
                                        RecordTypeId = rtUsg.Id,
                                        SVMXC__Service_Order__c = workorder.Id,
                                        SVMXC__Line_Type__c = 'Expenses',
                                        SVMXC__Product__c = prod.Id,
                                        SVMXC__Serial_Number__c = ib.Id,
                                        SVMXC__Estimated_Quantity2__c = 2,
                                        SVMXC__Estimated_Price2__c = 50,
                                        SVMXC__Use_Price_From_Pricebook__c = true,
                                        SVMXC__Select__c = true
                                        );
        woLineList.add(woestline3);
                
        woestline4 = new SVMXC__Service_Order_Line__c(
                                        RecordTypeId = rtEst.Id,
                                        SVMXC__Service_Order__c = workorder.Id,
                                        SVMXC__Line_Type__c = 'Parts',
                                        SVMXC__Product__c = prod.Id,
                                        SVMXC__Serial_Number__c = ib.Id,
                                        SVMXC__Estimated_Quantity2__c = 2,
                                        SVMXC__Estimated_Price2__c = 50,
                                        SVMXC__Use_Price_From_Pricebook__c = true,
                                        SVMXC__Select__c = true
                                        );
        woLineList.add(woestline4);
        
        woestline5 = new SVMXC__Service_Order_Line__c(
                                        RecordTypeId = rtEst.Id,
                                        SVMXC__Service_Order__c = workorder.Id,
                                        SVMXC__Line_Type__c = 'Labor',
                                        SVMXC__Product__c = prod.Id,
                                        SVMXC__Serial_Number__c = ib.Id,
                                        SVMXC__Estimated_Quantity2__c = 2,
                                        SVMXC__Estimated_Price2__c = 50,
                                        SVMXC__Use_Price_From_Pricebook__c = true,
                                        SVMXC__Select__c = true
                                        );
        woLineList.add(woestline5);
       
        woestline6 = new SVMXC__Service_Order_Line__c(
                                        RecordTypeId = rtEst.Id,
                                        SVMXC__Service_Order__c = workorder.Id,
                                        SVMXC__Line_Type__c = 'Expenses',
                                        SVMXC__Product__c = prod.Id,
                                        SVMXC__Serial_Number__c = ib.Id,
                                        SVMXC__Estimated_Quantity2__c = 2,
                                        SVMXC__Estimated_Price2__c = 50,
                                        SVMXC__Use_Price_From_Pricebook__c = true,
                                        SVMXC__Select__c = true
                                        );
        woLineList.add(woestline6);
        insert woLineList;
        SVMXC__Service_Group__c  sgroup = new SVMXC__Service_Group__c();
        sgroup.Name = 'group1';
        insert sgroup;
		SVMXC__Service_Group_Members__c groupmember = new SVMXC__Service_Group_Members__c();
		groupmember.SVMXC__Service_Group__c = sgroup.id;
		groupmember.Name = 'member1';
		groupmember.SVMXC__Salesforce_User__c = Userinfo.getUserId();
		insert groupmember;
        //============================ Configuring Standard Price for Product ===============================//
        pbStd = [select name, IsActive from Pricebook2 where IsStandard = true limit 1];
        /* Create a pricebook entries. */
        pbe = new PricebookEntry();
        pbe.Pricebook2Id = pbStd.id;
        pbe.Product2Id   = prod.id;
        pbe.IsActive     = true;
        //pbe.CurrencyIsoCode = 'USD';
        pbe.UnitPrice    = 10;        
        insert pbe;
        
        test.startTest();
        //=========================== Scenario to Launch Page without url parameters id  =====================//
        ApexPages.StandardController CWOEstUsgStdController1 = new ApexPages.standardController(workorder);
        PageReference pageRef1 = new PageReference('Page.SVMXC.WORD_CreateWOEstUsgLines');
        pageRef1.getParameters().put('id',workorder.Id); ////
        Test.setCurrentPageReference(pageRef1); 
        SVMXC.WORD_CreateWOEstUsgLines obj1 = new SVMXC.WORD_CreateWOEstUsgLines(CWOEstUsgStdController1);
        obj1.getUserLocaleKey();
        obj1.getUserID();
        obj1.getUserOrgID();
        system.assert(obj1.getErrorsList()!=null,'getErrorsList assertion failed');
        obj1.getDisplayBlockLevelMessage();
        List<SVMXC__Service_Order_Line__c> objArray7 = obj1.getNewWORDEstExpLine();
        obj1.setNewWORDEstExpLine(objArray7);
        List<SVMXC__Service_Order_Line__c> objArray8 = obj1.getNewWORDEstLabLine();
        obj1.setNewWORDEstLabLine(objArray8);
        system.assert(obj1.getCheckAllLines()!=null,'getCheckAllLines assertion failed');
        obj1.setCheckAllLines(true);
        system.assert(obj1.getShowValidData()!=null,'getShowValidData assertion failed');
        obj1.setShowValidData(true);
        obj1.getTargetRecType();
        system.assert(obj1.getTAG005()!=null,'TAG005 assertion failed');
        system.assert(obj1.getTAG007()!=null,'TAG007 assertion failed');
        system.assert(obj1.getTAG008()!=null,'TAG008 assertion failed');
        system.assert(obj1.getTAG009()!=null,'TAG009 assertion failed');
        system.assert(obj1.getTAG010()!=null,'TAG010 assertion failed');
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
        system.assert(obj1.getTAG022()!=null,'TAG022 assertion failed');
        system.assert(obj1.getTAG023()!=null,'TAG023 assertion failed');
        system.assert(obj1.getTAG024()!=null,'TAG024 assertion failed');
        system.assert(obj1.getTAG025()!=null,'TAG025 assertion failed');
        system.assert(obj1.getTAG026()!=null,'TAG026 assertion failed');
        system.assert(obj1.getTAG027()!=null,'TAG027 assertion failed');
        system.assert(obj1.getTAG028()!=null,'TAG028 assertion failed');
        system.assert(obj1.getTAG029()!=null,'TAG029 assertion failed');
        system.assert(obj1.getTAG037()!=null,'TAG037 assertion failed');
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
        system.assert(obj1.getTAG010()!=null,'TAG010 assertion failed');
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
        system.assert(obj1.getTAG022()!=null,'TAG022 assertion failed');
        system.assert(obj1.getTAG023()!=null,'TAG023 assertion failed');
        system.assert(obj1.getTAG024()!=null,'TAG024 assertion failed');
        system.assert(obj1.getTAG025()!=null,'TAG025 assertion failed');
        system.assert(obj1.getTAG026()!=null,'TAG026 assertion failed');
        system.assert(obj1.getTAG027()!=null,'TAG027 assertion failed');
        system.assert(obj1.getTAG028()!=null,'TAG028 assertion failed');
        system.assert(obj1.getTAG029()!=null,'TAG029 assertion failed');
        system.assert(obj1.getTAG037()!=null,'TAG037 assertion failed');
        system.assert(obj1.getTAG039()!=null,'TAG039 assertion failed');
        system.assert(obj1.getTAG040()!=null,'TAG040 assertion failed');
        system.assert(obj1.getTAG041()!=null,'TAG041 assertion failed');
        system.assert(obj1.getTAG042()!=null,'TAG042 assertion failed');
        system.assert(obj1.getHLPURL()!=null,'HLPURL assertion failed');
        
        //============================= Scenario to qualify Cancel() & newTargetObj() ==========================//
        PageReference cancl = obj1.Cancel();
        PageReference delest = obj1.DeleteEstLine();
        PageReference saveusg = obj1.SaveUsageLines();
        PageReference saveest = obj1.SaveEstLines();
        Id prodfrmIB = obj1.SVMX_getProductIdFromIB(ib.Id);
        PageReference getprice = obj1.UpdateLineRecord();
        PageReference getestprice = obj1.UpdateEstLineRecord();
        Boolean labcol = obj1.getDisplayLaborColumns();
        Boolean expcol = obj1.getDisplayExpColumns();
        Boolean estlabcol = obj1.getDisplayEstLaborColumns();
        Boolean estexpcol = obj1.getDisplayEstExpColumns();
        
        //======================== Scenario to qualify getNewWORDPartLine() method =======================//
        List<SVMXC__Service_Order_Line__c> PrtArray = obj1.getNewWORDPartLine();
        svoUsgPrtLineArray = obj1.getNewWORDPartLine();
        svoUsgPrtLineArray.add(woestline1);    
        obj1.setNewWORDPartLine(svoUsgPrtLineArray);
        
        //======================== Scenario to qualify getNewWORDLaborLine() method =======================//
        List<SVMXC__Service_Order_Line__c> LabArray = obj1.getNewWORDLaborLine();
        svoUsgLabLineArray = obj1.getNewWORDLaborLine();
        svoUsgLabLineArray.add(woestline2);    
        obj1.setNewWORDLaborLine(svoUsgLabLineArray);
        
        //======================== Scenario to qualify getNewWORDExpLine() method =======================//
        List<SVMXC__Service_Order_Line__c> ExpArray = obj1.getNewWORDExpLine();
        svoUsgExpLineArray = obj1.getNewWORDExpLine();
        svoUsgExpLineArray.add(woestline3);    
        obj1.setNewWORDExpLine(svoUsgExpLineArray);
        
        //======================== Scenario to qualify getNewWORDEstLine() method =======================//
        List<SVMXC__Service_Order_Line__c> EstArray = obj1.getNewWORDEstLine();
        svoUsgEstLineArray = obj1.getNewWORDEstLine();
        svoUsgEstLineArray.add(woestline4);    
        obj1.setNewWORDEstLine(svoUsgEstLineArray);
        
        //======================== Scenario to qualify getNewWORDEstLabLine() method =======================//
        List<SVMXC__Service_Order_Line__c> EstLabArray = obj1.getNewWORDEstLabLine();
        svoEstLabLineArray = obj1.getNewWORDEstLabLine();
        svoEstLabLineArray.add(woestline5);    
        obj1.setNewWORDEstLabLine(svoEstLabLineArray);
        
        //======================== Scenario to qualify getNewWORDEstExpLine() method =======================//
        List<SVMXC__Service_Order_Line__c> EstExpArray = obj1.getNewWORDEstExpLine();
        svoEstExpLineArray = obj1.getNewWORDEstExpLine();
        svoEstExpLineArray.add(woestline6);    
        obj1.setNewWORDEstExpLine(svoEstExpLineArray);
        
        //==================================== Scenario to Add a new part Line ================================//
        List<SVMXC__Service_Order_Line__c> objArray1 = new List<SVMXC__Service_Order_Line__c> ();
        objArray1.add(woestline1);
        obj1.setNewWORDPartLine(objArray1);
        PageReference addPLineRef = obj1.AddPartsLine();
        
        //============================ Scenario to Remove a new Line to Work Details ========================//
        PageReference removePLineRef = obj1.DeleteLine();
        
        //==================================== Scenario to Add a new Labor Line ===============================//
        List<SVMXC__Service_Order_Line__c> objArray2 = new List<SVMXC__Service_Order_Line__c> ();
        objArray2.add(woestline2);
        obj1.setNewWORDLaborLine(objArray2);
        
        
        PageReference addLLineRef = obj1.AddLaborLine();

        //============================ Scenario to Remove a new Line to Work Details ========================//
        PageReference removeLLineRef = obj1.DeleteLine();
        
        //================================== Scenario to Add a new Expenses Line ==============================//
        List<SVMXC__Service_Order_Line__c> objArray3 = new List<SVMXC__Service_Order_Line__c> ();
        objArray3.add(woestline3);
        obj1.setNewWORDExpLine(objArray3);
        PageReference addExLineRef = obj1.AddExpLine();
        
        //============================ Scenario to Remove a new Line to Work Details ========================//
        PageReference removeExLineRef = obj1.DeleteLine();
        
        //=========================== Scenario to Add a new Estimate Part Line ==============================//
        List<SVMXC__Service_Order_Line__c> objArray4 = new List<SVMXC__Service_Order_Line__c> ();
        objArray4.add(woestline4);
        obj1.setNewWORDEstLine(objArray4);
        PageReference addEsLineRef = obj1.AddEstimateLine();

        //============================ Scenario to Remove a new Line to Work Details ========================//
        PageReference removeEsLineRef = obj1.DeleteEstLine();
        
        //============================ Scenario to Add a new Estimate Labor Line =============================//
        List<SVMXC__Service_Order_Line__c> objArray5 = new List<SVMXC__Service_Order_Line__c> ();
        objArray5.add(woestline5);
        obj1.setNewWORDEstLabLine(objArray5);
        PageReference addEstLabLineRef = obj1.AddEstimateLabLine();
        
        //============================ Scenario to Remove a new Line to Work Details ========================//
        PageReference removeEsLabLineRef = obj1.DeleteEstLine();
        
        //========================== Scenario to Add a new Estimate Expenses Line ===========================//
        List<SVMXC__Service_Order_Line__c> objArray6 = new List<SVMXC__Service_Order_Line__c> ();
        objArray6.add(woestline6);
        obj1.setNewWORDEstExpLine(objArray6);
        PageReference addEstExpLineRef = obj1.AddEstimateExpLine();

        //============================ Scenario to Remove a new Line to Work Details ========================//
        PageReference removeEstExpLineRef = obj1.DeleteEstLine();
        
        //============================ Scenario to qualify regular set & get methods ==========================//
        Boolean showvaliddata = obj1.getShowValidData();
        obj1.setShowValidData(true);
        obj1.AddToErrorsList('Msg');
        List<String> listOfErrors = obj1.getErrorsList();
        obj1.DisplayErrorsNWarnings();
        Boolean dispMsg = obj1.getDisplayBlockLevelMessage();
        RecordType  estrtype = obj1.getEstRecordTypes();
        RecordType  usgrtype = obj1.getUsgRecordTypes();
        obj1.getNewEstUsageLine();
        Boolean chklines = obj1.getCheckAllLines();
        obj1.setCheckAllLines(true);
        SVMXC__Service_Order__c svohdr = obj1.getWOrderHeader();
        String TarRecTypeUsg = 'Usage/Consumption';
        String TarRecTypeEst = 'Estimate';
        String rectype = obj1.getTargetRecType();
        obj1.displayErrors();
        obj1.displayErrorsEst();
        SVMXC__Service_Order_Line__c workdetailsloc = obj1.getSVMX_WorkDetails();
    
    //================== Code to modify  Current Settings and applying different Scenarios ==================//
    //Clearing all the Settings
       
       obj1.AllSubModuleSettings.clear();
       obj1.ValidateAllSettings();
       obj1.AllSubModuleSettings.put('SET003','TRUE');
       obj1.AllSubModuleSettings.put('SET004',null);
       obj1.AllSubModuleSettings.put('SET005','TRUE');
       obj1.AllSubModuleSettings.put('SET006',null);
       obj1.ValidateAllSettings();
       obj1.AllSubModuleSettings.put('SET003','FALSE');      
       obj1.AllSubModuleSettings.put('SET004','No Price Book');
       obj1.AllSubModuleSettings.put('SET005','FALSE');      
       obj1.AllSubModuleSettings.put('SET006','No Price Book');
       obj1.ValidateAllSettings();
       test.stopTest();
        
       // }catch(exception Ex){}
  
    }//Test Method

}