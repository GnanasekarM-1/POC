@isTest(Seealldata=true)
private with sharing class PREQ_CreatePRLines_UT{
    private static SVMXC.PREQ_CreatePRLines prlObject1;
    private static Account account;
    private static Contact contact ;
    private static Case case1;
    private static Product2  prodPR, prodPR1, prodPR2, prod;  
    private static Pricebook2 pbStd; 
    private static PricebookEntry pbe,pbe1;
    private static SVMXC__Site__c sourceLocation,destLocation;
    
    //Instance creation
    private static SVMXC__Parts_Request__c prObject,prObject1,prObject2; 
    private static SVMXC__Parts_Request_Line__c  prLineObject1, prLineObject2, prLineObject3, prLineObject4, prLineObject5;
    private static List<SVMXC__Parts_Request_Line__c> prLineArray = new List<SVMXC__Parts_Request_Line__c>();
    private static SVMXC__Installed_Product__c IBObject;
    
    //Variables for Configuration Setting Data
    private static List<RecordType> rtSVMX_Processes = new List<RecordType>();
    private static List<RecordType> rtSVMX_ConfData = new List<RecordType>();
    
    //Objects for Profile Object
    private static SVMXC__ServiceMax_Config_Data__c configProfile;
    //Objects for Module, Submodule
    private static SVMXC__ServiceMax_Processes__c module;
    private static SVMXC__ServiceMax_Processes__c subModule;   
    //Objects for Setting Def
    private static SVMXC__ServiceMax_Settings__c settingDefHlpUrl;
    private static SVMXC__ServiceMax_Settings__c settingDefUsePriceBk;
    private static SVMXC__ServiceMax_Settings__c settingDefPRPriceBook;
    
    //Objects for Setting Value
    private static SVMXC__ServiceMax_Config_Data__c settingValUsePriceBk;
    private static SVMXC__ServiceMax_Config_Data__c settingValHlpUrl;
    private static SVMXC__ServiceMax_Config_Data__c settingValPRPriceBook;

    //Test Method
    static testMethod void PREQ_CreatePRLines_Test(){
        try{
            account = new Account(Name ='Account',ShippingStreet='ABC',ShippingCity='PQR ',ShippingState = 'XYZ',ShippingPostalCode='111',ShippingCountry='XYZ',BillingStreet='ABC',BillingCity='PQR ',BillingState = 'XYZ',BillingPostalCode='111',BillingCountry='XYZ'); 
            insert account;
            
            contact = new Contact(LastName='Last',AccountId =account.Id,Email='svmxmailfortest@servicemax.com');
            insert contact;
            
            prodPR = new Product2(Name = 'prodPR',ProductCode='prodPR',SVMXC__Inherit_Parent_Warranty__c =True);
            insert prodPR;
            
            sourceLocation = new SVMXC__Site__c(SVMXC__Zip__c ='90909090',SVMXC__Street__c ='ABC',SVMXC__State__c ='ABC',SVMXC__Country__c ='ABC',SVMXC__City__c ='ABC',SVMXC__Account__c=account.Id);
            insert sourceLocation;
            
            destLocation = new SVMXC__Site__c(SVMXC__Zip__c ='90909090',SVMXC__Street__c ='ABC',SVMXC__Stocking_Location__c=true,SVMXC__State__c ='ABC',SVMXC__Country__c ='ABC',SVMXC__City__c ='ABC',SVMXC__Account__c=account.Id);
            insert destLocation;
            
            prObject = new SVMXC__Parts_Request__c (SVMXC__Requested_From__c=sourceLocation.Id,SVMXC__Required_At_Location__c=destLocation.Id,SVMXC__Company__c=account.Id,SVMXC__Status__c='open',SVMXC__Additional_Information__c='Unit Test for Parts Request');
            insert prObject;
            
            prObject1 = new SVMXC__Parts_Request__c (SVMXC__Requested_From__c=sourceLocation.Id,SVMXC__Required_At_Location__c=destLocation.Id,SVMXC__Company__c=account.Id,SVMXC__Status__c='Open',SVMXC__Additional_Information__c='Unit Test for Parts Request');
            insert prObject1;
            
            prLineObject1 = new SVMXC__Parts_Request_Line__c(SVMXC__Line_Status__c = 'Open',SVMXC__Parts_Request__c = prObject1.id,SVMXC__Product__c=prodPR.Id,SVMXC__Quantity_Required2__c=5,SVMXC__Date_Required__c=System.Today(),SVMXC__Additional_Information__c='Unit Test for Parts Request Line',SVMXC__Quantity_Shipped2__c=5,SVMXC__Quantity_Received2__c=5,SVMXC__Posted_To_Inventory__c = true);
            insert prLineObject1;   
            
            prLineObject2 = new SVMXC__Parts_Request_Line__c(SVMXC__Line_Status__c = 'Open',SVMXC__Parts_Request__c = prObject1.id,SVMXC__Product__c=prodPR.Id,SVMXC__Quantity_Required2__c=5,SVMXC__Date_Required__c=System.Today(),SVMXC__Additional_Information__c='Unit Test for Parts Request Line',SVMXC__Quantity_Shipped2__c=5,SVMXC__Quantity_Received2__c=5,SVMXC__Posted_To_Inventory__c = true);
            insert prLineObject2;
            
            prLineObject3 = new SVMXC__Parts_Request_Line__c(SVMXC__Line_Status__c = 'Open',SVMXC__Product__c=prodPR.Id,SVMXC__Parts_Request__c = prObject1.id,SVMXC__Quantity_Required2__c=5,SVMXC__Date_Required__c=System.Today(),SVMXC__Additional_Information__c='Unit Test for Parts Request Line',SVMXC__Quantity_Shipped2__c=5,SVMXC__Quantity_Received2__c=5,SVMXC__Posted_To_Inventory__c = true);
            insert prLineObject3;  
           }
            catch(exception Ex){}
            test.startTest();
            //Scenario to Launch Page without url parameters id and Target Recordtype
            ApexPages.StandardController prStdController = new ApexPages.standardController(prLineObject1);

            ApexPages.CurrentPage().getparameters().put('id', prLineObject1.id);
            SVMXC.PREQ_CreatePRLines obj1 = new SVMXC.PREQ_CreatePRLines(prStdController);
            String currUserInfo = obj1.getUserLocaleKey();
            currUserInfo = obj1.getUserID();
            currUserInfo = obj1.getUserOrgID();
            prlObject1 = new SVMXC.PREQ_CreatePRLines(prStdController);

            //Scenario to qualify Cancel() & AddPartsRequestLine() methods
            PageReference cancl = prlObject1.Cancel();
            PageReference addPartReqLine = prlObject1.AddPartsRequestLine();
            
            //Scenario to qualify RemovePartsOrderLine() method
            PageReference pageRef2 = new PageReference('Page.SVMXC.PREQ_CreatePRLines');
              
            pageRef2.getParameters().put('id',prLineObject1.Id);
            pageRef2.getParameters().put('PRName','Test PR');
            Test.setCurrentPageReference(pageRef2); 
            prlObject1 = new SVMXC.PREQ_CreatePRLines(prStdController);
            prLineArray = prlObject1.getNewPRLine();
            
            prLineObject4 = new SVMXC__Parts_Request_Line__c(SVMXC__Line_Status__c = 'Open',SVMXC__Product__c=prodPR.Id,SVMXC__Parts_Request__c = prObject1.id,SVMXC__Quantity_Required2__c=5,SVMXC__Date_Required__c=System.Today(),SVMXC__Additional_Information__c='Unit Test for Parts Request Line',SVMXC__Quantity_Shipped2__c=5,SVMXC__Quantity_Received2__c=5,SVMXC__Posted_To_Inventory__c = true);
            insert prLineObject4;
            
            prLineArray.add(prLineObject4);
            
            //// prlObject1.setNewPRLine(prLineArray);
            PageReference removePartReq=prlObject1.RemovePartsRequestLine();
            
            //Scenario to qualify the method : getDisplayTableColumns()
            Boolean dispTabCol = prlObject1.getDisplayTableColumns();
            prLineArray.clear();
            
            ////prlObject1.setNewPRLine(prLineArray);
            dispTabCol = prlObject1.getDisplayTableColumns();
            
            //Scenario to qualify the method : ClearWarnings() & UpdateLines()
            PageReference clrWarnings = prlObject1.ClearWarnings();
            clrWarnings = prlObject1.ClearWarnings();
            
            //Configuring Price for Product
            pbStd = [select name, IsActive from Pricebook2 where IsStandard = true limit 1];
               
            /* Create a pricebook entries. */
            pbe = new PricebookEntry();
            pbe.Pricebook2Id = pbStd.id;
            pbe.Product2Id   = prodPR.id;
            pbe.IsActive = true;
            pbe.UnitPrice= 10;
            insert pbe; 
            
            //Scenario to qualify the method : UpdateLineRecord()
            IBObject = new SVMXC__Installed_Product__c(Name = 'Test IB1',SVMXC__Status__c = 'Installed',SVMXC__Product__c = prodPR.Id,SVMXC__Date_Installed__c = System.Today(),SVMXC__Contact__c = contact.Id,SVMXC__Company__c = account.Id);
            insert IBObject;
            
            prLineObject5 = new SVMXC__Parts_Request_Line__c(SVMXC__Line_Status__c = 'Open',SVMXC__Parts_Request__c = prObject1.id,SVMXC__Product__c=prodPR.Id,SVMXC__Quantity_Required2__c=5,SVMXC__Date_Required__c=System.Today(),SVMXC__Additional_Information__c='Unit Test for Parts Request Line',SVMXC__Quantity_Shipped2__c=5,SVMXC__Quantity_Received2__c=5,SVMXC__Posted_To_Inventory__c = true);
            insert prLineObject5;
            
            prLineArray.add(prLineObject5);
            PageReference updLineRec = prlObject1.GettPrice();      
            system.assert(prlObject1.getSourcePRData()!=null,'getSourcePRData assertion failed');
            //Scenario to qualify the method : DisplayErrorsNWarnings()
            prlObject1.AddToWarningsList('Test Warning Message2');
            prlObject1.DisplayErrorsNWarnings();
            prlObject1.SVMX_getProductIdFromIB(IBObject.Id);
            //Scenario to qualify regular set & get methods
            prlObject1.AddToWarningsList('Test Message1') ;
            List<String> warnings = prlObject1.getWarningsList();
            prlObject1.AddToErrorsList('Test Message');
               
            Boolean chklines = prlObject1.getCheckAllLines();
            prlObject1.setCheckAllLines(true);
              
            Boolean showmsg = prlObject1.getshowWarnings();
            prlObject1.setshowWarnings(true);
            Boolean dispMsg = prlObject1.getDisplayBlockLevelMessage();

            system.assert(prlObject1.getTAG001()!=null,'getTAG001 assertion failed');
            system.assert(prlObject1.getTAG002()!=null,'getTAG002 assertion failed');
            system.assert(prlObject1.getTAG003()!=null,'getTAG003 assertion failed');
            system.assert(prlObject1.getTAG004()!=null,'getTAG004 assertion failed');
            system.assert(prlObject1.getTAG005()!=null,'getTAG005 assertion failed');
            system.assert(prlObject1.getTAG006()!=null,'getTAG006 assertion failed');
            system.assert(prlObject1.getTAG007()!=null,'getTAG007 assertion failed');
            system.assert(prlObject1.getTAG008()!=null,'getTAG008 assertion failed');
            system.assert(prlObject1.getTAG009()!=null,'getTAG009 assertion failed');
            system.assert(prlObject1.getTAG011()!=null,'getTAG011 assertion failed'); 
            system.assert(prlObject1.getTAG012()!=null,'getTAG012 assertion failed');
            system.assert(prlObject1.getTAG013()!=null,'getTAG013 assertion failed');
            system.assert(prlObject1.getTAG014()!=null,'getTAG014 assertion failed');
            system.assert(prlObject1.getTAG015()!=null,'getTAG015 assertion failed');  
            system.assert(prlObject1.getTAG016()!=null,'getTAG016 assertion failed');
            system.assert(prlObject1.getTAG018()!=null,'getTAG018 assertion failed');
            system.assert(prlObject1.getTAG019()!=null,'getTAG019 assertion failed');
            system.assert(prlObject1.getTAG020()!=null,'getTAG020 assertion failed');
            system.assert(prlObject1.getTAG021()!=null,'getTAG021 assertion failed');
            system.assert(prlObject1.getTAG022()!=null,'getTAG022 assertion failed');
            system.assert(prlObject1.getHLPURL()!=null,'getHLPURL assertion failed');
            
            //prlObject1.svmxTagList.clear(); 
            
            system.assert(prlObject1.getTAG001()!=null,'getTAG001 assertion failed');
            system.assert(prlObject1.getTAG002()!=null,'getTAG002 assertion failed');
            system.assert(prlObject1.getTAG003()!=null,'getTAG003 assertion failed');
            system.assert(prlObject1.getTAG004()!=null,'getTAG004 assertion failed');
            system.assert(prlObject1.getTAG005()!=null,'getTAG005 assertion failed');
            system.assert(prlObject1.getTAG006()!=null,'getTAG006 assertion failed');
            system.assert(prlObject1.getTAG007()!=null,'getTAG007 assertion failed');
            system.assert(prlObject1.getTAG008()!=null,'getTAG008 assertion failed');
            system.assert(prlObject1.getTAG009()!=null,'getTAG009 assertion failed');
            system.assert(prlObject1.getTAG011()!=null,'getTAG011 assertion failed'); 
            system.assert(prlObject1.getTAG012()!=null,'getTAG012 assertion failed');
            system.assert(prlObject1.getTAG013()!=null,'getTAG013 assertion failed');
            system.assert(prlObject1.getTAG014()!=null,'getTAG014 assertion failed');
            system.assert(prlObject1.getTAG015()!=null,'getTAG015 assertion failed');  
            system.assert(prlObject1.getTAG016()!=null,'getTAG016 assertion failed');
            system.assert(prlObject1.getTAG018()!=null,'getTAG018 assertion failed');
            system.assert(prlObject1.getTAG019()!=null,'getTAG019 assertion failed');
            system.assert(prlObject1.getTAG020()!=null,'getTAG020 assertion failed');
            system.assert(prlObject1.getTAG021()!=null,'getTAG021 assertion failed');
            system.assert(prlObject1.getTAG022()!=null,'getTAG022 assertion failed');
            system.assert(prlObject1.getHLPURL()!=null,'getHLPURL assertion failed');

            List<String> errlist = prlObject1.getErrorsList();
            List<SVMXC__Parts_Request_Line__c> TstobjArray = new     List<SVMXC__Parts_Request_Line__c>();
            SVMXC__Parts_Request_Line__c Tstobj = new SVMXC__Parts_Request_Line__c();
            TstobjArray.add(Tstobj);
            prlObject1.setNewPRLine(TstobjArray);
            TstobjArray = prlObject1.getExistingLines();
            prlObject1.AllSubModuleSettings.clear();
            prlObject1.ValidateAllSettings();
            prlObject1.AllSubModuleSettings.put('SET002','False');
            prlObject1.AllSubModuleSettings.put('SET003','Pricebook');
            prlObject1.ValidateAllSettings();
            prlObject1.AllSubModuleSettings.clear();
            prlObject1.AllSubModuleSettings.put('SET002','xxxx');
            prlObject1.AllSubModuleSettings.put('SET003','No Pricebook');
            prlObject1.ValidateAllSettings();
            SVMXC__Parts_Request__c PRQ = new SVMXC__Parts_Request__c();
            PRQ.SVMXC__Requested_From__c = null;
            PRQ.SVMXC__Required_At_Location__c = null;
            PRQ=prlObject1.getSourcePRData();
            
            SVMXC__Parts_Request_Line__c PRQL = new SVMXC__Parts_Request_Line__c();
            prlObject1.getExistingLines();
            PRQL.SVMXC__Select__c = true;
            system.assert(prlObject1.getExistingLines()!=null,'getExistingLines assertion failed');
            PRQL.SVMXC__Use_Price_From_Pricebook__c=false;
            prlObject1.AddPartsRequestLine();
            PRQL.SVMXC__Use_Price_From_Pricebook__c=true;
            prlObject1.AddPartsRequestLine();
            system.assert(prlObject1.getExistingLines()!=null,'getExistingLines assertion failed');
            system.assert(prlObject1.getSourcePR()!=null,'getSourcePR assertion failed');           
            test.stopTest();

    }


}