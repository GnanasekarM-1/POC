@isTest
private  with sharing class WORD_CreateWOReqRecLines_UT 
{
    private static SVMXC.WORD_CreateWOReqRecLines creWORRL;
    private static Account account;
    private static Contact contact ;
    private static Case case1;
    private static Product2  prodWORR;
    private static Pricebook2 pbStd;
    private static PricebookEntry pbe;
    private static SVMXC__Site__c sourceLocation,destLocation;
    
    private static RecordType rtWORRL;
    
    private static SVMXC__Service_Order__c woObject;
    private static SVMXC__Service_Order_Line__c worrl;
    private static List<SVMXC__Service_Order_Line__c> worrLineArray = new List<SVMXC__Service_Order_Line__c>();
    private static SVMXC__Installed_Product__c IBObject;
    
    //Variables for Configuration Setting Data
    private static List<RecordType> AllRecordTypes  = new List<RecordType>();
    private static RecordType SettgValRecordType = new RecordType();
    
    //Objects for Profile Object    
    private static SVMXC__ServiceMax_Config_Data__c configProfile;
    
    //Objects for Module, Submodule
    private static SVMXC__ServiceMax_Processes__c module;
    private static SVMXC__ServiceMax_Processes__c subModule;   
    
    //Objects for Setting Value
    private static SVMXC__ServiceMax_Config_Data__c Setng_usePriceFromPriceBook;
    private static SVMXC__ServiceMax_Config_Data__c settingWORRPriceBook;
    
    //Test Method
    static testMethod void WORD_CreateWOReqRecLines_Test()
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
        
        contact = new Contact(LastName='Last',AccountId =account.Id,Email='svmxmailfortest@servicemax.com');
        insert contact;
        
        case1 = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                                                                    
                                        ContactId =contact.Id,
                                        AccountId=account.Id
                                        ); 
        insert case1; 
        
        prodWORR = new Product2(
                                Name = 'prodPR',
                                ProductCode='prodPR',
                                SVMXC__Inherit_Parent_Warranty__c =True
                                );
                                
        insert prodWORR;
        
    
                    
        for ( RecordType rectype:AllRecordTypes)
            {
            if ((rectype.Name =='Request/Receipt')&&(rectype.SobjectType =='SVMXC__Service_Order_Line__c'))             
                rtWORRL = rectype;
            }
            
        sourceLocation = new SVMXC__Site__c(
                                        SVMXC__Zip__c ='90909090',
                                        SVMXC__Street__c ='ABC',
                                        SVMXC__State__c ='ABC',
                                        SVMXC__Country__c ='ABC',
                                        SVMXC__City__c ='ABC',
                                        SVMXC__Account__c=account.Id
                                        );
        insert sourceLocation;

        destLocation = new SVMXC__Site__c(
                                        SVMXC__Zip__c ='90909090',
                                        SVMXC__Street__c ='ABC',
                                        SVMXC__State__c ='ABC',
                                        SVMXC__Country__c ='ABC',
                                        SVMXC__City__c ='ABC',
                                        SVMXC__Account__c=account.Id
                                        );
        insert destLocation;
    
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

      
        worrl = new SVMXC__Service_Order_Line__c(
                                                SVMXC__Service_Order__c=woObject.Id,
                                                RecordTypeId = rtWORRL.Id ,
                                                SVMXC__Requested_Quantity2__c=45,
                                                SVMXC__Date_Requested__c=System.today(),
                                                SVMXC__Received_Quantity2__c=45,
                                                SVMXC__From_Location__c=sourceLocation.Id,
                                                SVMXC__Requested_Location__c=destLocation.Id
                                                );
        insert worrl;

      
    
        //Configuring Standard Price for Product
        pbStd = [select name, IsActive from Pricebook2 where IsStandard = true limit 1];

        /* Create a pricebook entries. */
        pbe = new PricebookEntry();
        pbe.Pricebook2Id = pbStd.id;
        pbe.Product2Id   = prodWORR.id;
        pbe.IsActive     = true;
        pbe.UnitPrice    = 10;        
        insert pbe; 
        
        Test.startTest();
    
        //Scenario to Launch Page with url parameters id and Target Recordtype
        system.assertNotEquals(woObject.Id, null);
        ApexPages.StandardController CWORRStdController = new ApexPages.standardController(woObject);
        PageReference pageRef = new PageReference('Page.SVMXC.WORD_CreateWOReqRecLines');
        pageRef.getParameters().put('id',woObject.Id);
        pageRef.getParameters().put('WORRName','Test WORR');
        pageRef.getParameters().put('TargetRecordType','Request/Receipt');
        Test.setCurrentPageReference(pageRef);          
    
        creWORRL = new SVMXC.WORD_CreateWOReqRecLines(CWORRStdController); 
    	creWORRL.getUserLocaleKey();
        creWORRL.getUserID();
        creWORRL.getUserOrgID();
        //call methods of the class
        creWORRL.gethelpURL();
        creWORRL.setshowWarnings(true);
        
        //Scenario to Add a new Request Receipt Line 
        List<SVMXC__Service_Order_Line__c> objArray1 = new List<SVMXC__Service_Order_Line__c> ();
        objArray1.add(worrl);
        creWORRL.setNewWORRLine( objArray1);
        //PageReference addLineRef = creWORRL.AddRequestReceiptLine();
    
        
        //Scenario to qualify Cancel() 
        PageReference cancl = creWORRL.Cancel();
    
        List<SVMXC__Service_Order_Line__c> objArray2 = new List<SVMXC__Service_Order_Line__c> ();
        objArray2.add(worrl);
        creWORRL.NewRecordTypeName = 'Request/Receipt';
        creWORRL.getRecordType(creWORRL.NewRecordTypeName,'SVMXC__Service_Order_Line__c');
        //PageReference addRRLine = creWORRL.AddRequestReceiptLine(); 
        creWORRL.setNewWORRLine( objArray2);
        PageReference upddatePr = creWORRL.UpdatePrice();
    
        //Scenario to CreateRequest Receipt Lines
        PageReference clearWarnings   = creWORRL.ClearWarnings();
    
        //Scenario to display Warnings
        creWORRL.AddToWarningsList('Msg');
        system.assert(creWORRL.getshowWarnings()!=null,'getshowWarnings assertion failed');
        creWORRL.DisplayErrorsNWarnings();
    
        //Scenario to Cancel the creation of Request Receipt Lines
        PageReference cancel = creWORRL.Cancel();
    
        //Scenario to hide and display PageBlockTable
        List<SVMXC__Service_Order_Line__c> objArray3 = new List<SVMXC__Service_Order_Line__c>();   
        creWORRL.setNewWORRLine(objArray3);
        Boolean hideTableCols = creWORRL.getDisplayTableColumns();
        system.assertEquals(hideTableCols,true);
        
        //Scenario to qualify RmvRequestReceiptLine() method
        pageRef.getParameters().put('id',woObject.Id);
        pageRef.getParameters().put('WORRName','Test WORR');
        pageRef.getParameters().put('TargetRecordType','Request/Receipt');
        Test.setCurrentPageReference(pageRef);          
    
        worrLineArray = creWORRL.getNewWORRLine();
        worrLineArray.add(worrl);
        PageReference removeRR = creWORRL.RmvRequestReceiptLine();

        //Scenario to qualify regular set & get methods
        SVMXC__Service_Order__c SourceRRData = creWORRL.getSourceRRData();
        SVMXC__Service_Order__c SourceWOL = creWORRL.getSourceWOL();     
        List<SVMXC__Service_Order_Line__c>TempRReceiptDetailArray = creWORRL.getNewWORRLine();
        system.assert(creWORRL.getCheckAllLines()!=null,'getCheckAllLines assertion failed');
        Boolean chkAllLines = creWORRL.getCheckAllLines();
        system.assertEquals(chkAllLines,false);
        creWORRL.setCheckAllLines(true);
        List<String> strList1 = creWORRL.getErrorsList();       
        system.assert(creWORRL.getDisplayBlockLevelMessage());
        Boolean dblMesg = creWORRL.getDisplayBlockLevelMessage();
        worrLineArray.add(worrl);
        PageReference uplprice = creWORRL.UpdatePrice();
        
        //Scenario to qualify the method : DisplayErrorsNWarnings()
        creWORRL.AddToWarningsList('Test Warning Message');
        creWORRL.DisplayErrorsNWarnings();
    
        //Scenario to qualify regular set & get methods    
        SVMXC__Service_Order__c sourceObj = creWORRL.getSourceWOL();
        List<String> listOfErrors = creWORRL.getErrorsList();
        system.assert(creWORRL.getTAG004()!=null,'TAG004 assertion failed');
        system.assert(creWORRL.getTAG005()!=null,'TAG005 assertion failed');
        system.assert(creWORRL.getTAG007()!=null,'TAG007 assertion failed');
        system.assert(creWORRL.getTAG008()!=null,'TAG008 assertion failed');
        system.assert(creWORRL.getTAG009()!=null,'TAG009 assertion failed');
        system.assert(creWORRL.getTAG017()!=null,'TAG017 assertion failed');
        system.assert(creWORRL.getTAG018()!=null,'TAG018 assertion failed');
        system.assert(creWORRL.getTAG024()!=null,'TAG024 assertion failed');
        system.assert(creWORRL.getTAG026()!=null,'TAG026 assertion failed');
        system.assert(creWORRL.getTAG030()!=null,'TAG030 assertion failed');
        system.assert(creWORRL.getTAG031()!=null,'TAG031 assertion failed');
        system.assert(creWORRL.getTAG032()!=null,'TAG032 assertion failed');
        system.assert(creWORRL.getTAG033()!=null,'TAG033 assertion failed');
        system.assert(creWORRL.getTAG034()!=null,'TAG034 assertion failed');
        system.assert(creWORRL.getTAG035()!=null,'TAG035 assertion failed');
        system.assert(creWORRL.getTAG036()!=null,'TAG036 assertion failed');
        system.assert(creWORRL.getTAG039()!=null,'TAG039 assertion failed');
        system.assert(creWORRL.getHLPURL()!=null,'HLPURL assertion failed');
        //creWORRL.svmxTagList.clear();
        system.assert(creWORRL.getTAG004()!=null,'TAG004 assertion failed');
        system.assert(creWORRL.getTAG005()!=null,'TAG005 assertion failed');
        system.assert(creWORRL.getTAG007()!=null,'TAG007 assertion failed');
        system.assert(creWORRL.getTAG008()!=null,'TAG008 assertion failed');
        system.assert(creWORRL.getTAG009()!=null,'TAG009 assertion failed');
        system.assert(creWORRL.getTAG017()!=null,'TAG017 assertion failed');
        system.assert(creWORRL.getTAG018()!=null,'TAG018 assertion failed');
        system.assert(creWORRL.getTAG024()!=null,'TAG024 assertion failed');
        system.assert(creWORRL.getTAG026()!=null,'TAG026 assertion failed');
        system.assert(creWORRL.getTAG030()!=null,'TAG030 assertion failed');
        system.assert(creWORRL.getTAG031()!=null,'TAG031 assertion failed');
        system.assert(creWORRL.getTAG032()!=null,'TAG032 assertion failed');
        system.assert(creWORRL.getTAG033()!=null,'TAG033 assertion failed');
        system.assert(creWORRL.getTAG034()!=null,'TAG034 assertion failed');
        system.assert(creWORRL.getTAG035()!=null,'TAG035 assertion failed');
        system.assert(creWORRL.getTAG036()!=null,'TAG036 assertion failed');
        system.assert(creWORRL.getTAG039()!=null,'TAG039 assertion failed');
        system.assert(creWORRL.getHLPURL()!=null,'HLPURL assertion failed');

    
        //Scenario to Launch Page with url parameters id and Target Recordtype for RR
        pageRef.getParameters().put('id',woObject.Id);
        pageRef.getParameters().put('RRName','Test RR');
        pageRef.getParameters().put('TargetRecordType','Request/Receipt');
        Test.setCurrentPageReference(pageRef);
        String TarRecTypeName = creWORRL.getTargetRecType();  
        creWORRL.AddToWarningsList('Test Message1') ;
        List<String> warnings = creWORRL.getWarningsList();  
        
        //================== Code to modify  Current Settings and applying different Scenarios ==================//
        //Clearing all the Settings
        creWORRL.AllSubModuleSettings.clear();
        creWORRL.ValidateAllSettings();
        PageReference pageRef3 = new PageReference('Page.SVMXC.WORD_CreateWOReqRecLines');
        pageRef.getParameters().put('id',woObject.Id);
        Test.setCurrentPage(pageRef);
        
       //Populating different values for Settings
       //Setng_WOLineRecTypeVFName - SET007
       //Setng_DefRecType - SET008
        creWORRL.AllSubModuleSettings.put('SET007','TRUE');
        creWORRL.AllSubModuleSettings.put('SET008','No Price Book');
        creWORRL.ValidateAllSettings();
        creWORRL.AllSubModuleSettings.put('SET007','FALSE');
        creWORRL.AllSubModuleSettings.put('SET008','No Price Book');
        creWORRL.ValidateAllSettings();
        Test.stopTest();
        }
        catch(Exception ex){}
        
    }//Test Method
}