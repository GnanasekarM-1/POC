@isTest
private with sharing class SXFR_CreateSTLines_UT{
    private static SVMXC.SXFR_CreateSTLines sxfrlObjec; 
    private static Account account;
    private static Contact contact ;
    private static Case case1;
    private static Product2  prodSXFR, prodSXFR1, prodSXFR2, prodSXFR3;  
    private static Pricebook2 pbStd; 
    private static PricebookEntry pbe,pbe1;
    private static SVMXC__Site__c sourceLocation,destLocation;
    
    private static SVMXC__Stock_Transfer__c sxfrObject,sxfrObject1,sxfrObject2,sxfrObject3;
    private static SVMXC__Stock_Transfer_Line__c sxfrLineObject,sxfrLineObject1,sxfrLineObject2,sxfrLineObject3,sxfrLineObject4,sxfrLineObject5;
    private static List<SVMXC__Stock_Transfer_Line__c> sxfrLineArray = new List<SVMXC__Stock_Transfer_Line__c>();
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
    private static SVMXC__ServiceMax_Settings__c settingDefSXFRPriceBook;
    
    //Objects for Setting Value
    private static SVMXC__ServiceMax_Config_Data__c settingValUsePriceBk;
    private static SVMXC__ServiceMax_Config_Data__c settingValHlpUrl;
    private static SVMXC__ServiceMax_Config_Data__c settingValSXFRPriceBook;
    
    static testMethod void SXFR_CreateSTLines_Test(){
        try{
            account = new Account(Name ='Account',ShippingStreet='ABC',ShippingCity='PQR ',ShippingState = 'XYZ',ShippingPostalCode='111',ShippingCountry='XYZ',BillingStreet='ABC',BillingCity='PQR ',BillingState = 'XYZ',BillingPostalCode='111',BillingCountry='XYZ'); 
            insert account;
            
            contact = new Contact(LastName='Last',AccountId =account.Id,Email='svmxmailfortest@servicemax.com');
            insert contact;
            
            prodSXFR = new Product2(Name = 'prodPR',ProductCode='prodPR',SVMXC__Inherit_Parent_Warranty__c =True);
            insert prodSXFR;
            
            sourceLocation = new SVMXC__Site__c(SVMXC__Zip__c ='90909090',SVMXC__Street__c ='ABC',SVMXC__Stocking_Location__c=true,SVMXC__State__c ='ABC',SVMXC__Country__c ='ABC',SVMXC__City__c ='ABC',SVMXC__Account__c=account.Id);
            insert sourceLocation;
            
            destLocation = new SVMXC__Site__c(SVMXC__Zip__c ='90909090',SVMXC__Street__c ='ABC',SVMXC__Stocking_Location__c=true,SVMXC__State__c ='ABC',SVMXC__Country__c ='ABC',SVMXC__City__c ='ABC',SVMXC__Account__c=account.Id);
            insert destLocation;
            
            sxfrObject = new SVMXC__Stock_Transfer__c(SVMXC__Additional_Information__c='Unit Test Case for SXFR',SVMXC__Destination_Location__c=destLocation.Id,SVMXC__Source_Location__c=sourceLocation.Id);
            insert sxfrObject;
            
            sxfrObject1 = new SVMXC__Stock_Transfer__c(SVMXC__Additional_Information__c='Unit Test Case for SXFR',SVMXC__Destination_Location__c=destLocation.Id,SVMXC__Source_Location__c=sourceLocation.Id);
            insert sxfrObject1;
            
            sxfrLineObject = new SVMXC__Stock_Transfer_Line__c (SVMXC__Additional_Information__c='Unit Test Case for SXFR',SVMXC__Posted_To_Inventory__c=true,SVMXC__Product__c=prodSXFR.Id,SVMXC__Quantity_Transferred2__c=2,SVMXC__Select__c = true,SVMXC__Stock_Transfer__c = sxfrObject1.Id,SVMXC__Use_Price_From_Pricebook__c=true);
            insert sxfrLineObject;
            
            sxfrLineObject1 = new SVMXC__Stock_Transfer_Line__c(SVMXC__Additional_Information__c='Unit Test Case for SXFR',SVMXC__Posted_To_Inventory__c=true,SVMXC__Product__c=prodSXFR.Id,SVMXC__Quantity_Transferred2__c=2,SVMXC__Select__c = false,SVMXC__Stock_Transfer__c = sxfrObject1.Id,SVMXC__Use_Price_From_Pricebook__c=true);
            insert sxfrLineObject1;
            
            sxfrLineObject2 = new SVMXC__Stock_Transfer_Line__c(SVMXC__Additional_Information__c='Unit Test Case for SXFR',SVMXC__Posted_To_Inventory__c=true,SVMXC__Product__c=prodSXFR.Id,SVMXC__Quantity_Transferred2__c=2,SVMXC__Select__c = true,SVMXC__Stock_Transfer__c = sxfrObject1.Id,SVMXC__Use_Price_From_Pricebook__c=true);
            insert sxfrLineObject2;
            
            test.startTest();
            //Scenario to Launch Page witout url parameters id
            ApexPages.StandardController sxfrStdController = new ApexPages.standardController(sxfrObject);
            
            PageReference pageRef = new PageReference('Page.SVMXC.SXFR_CreateSTLines');
            Test.setCurrentPageReference(pageRef); 
            SVMXC.SXFR_CreateSTLines obj1 = new SVMXC.SXFR_CreateSTLines(sxfrStdController);
            sxfrlObjec = new SVMXC.SXFR_CreateSTLines(sxfrStdController);
            
            //Scenario to qualify Cancel() & AddPartsRequestLine() methods
            PageReference cancl = sxfrlObjec.Cancel();
            PageReference addSXFRLine = sxfrlObjec.AddSXFRLine();
            
            //Scenario to qualify RemovePartsOrderLine() method
            PageReference pageRef1 = new PageReference('Page.SVMXC.SXFR_CreateSTLines');
            pageRef1.getParameters().put('id',sxfrObject.Id);
            pageRef1.getParameters().put('SXFRName','Test SXFR');
            Test.setCurrentPageReference(pageRef1);
            
            sxfrLineArray = sxfrlObjec.getNewSXFRLine();
            
            sxfrLineObject3 = new SVMXC__Stock_Transfer_Line__c(SVMXC__Additional_Information__c='Unit Test Case for SXFR',SVMXC__Posted_To_Inventory__c=true,SVMXC__Product__c=prodSXFR.Id,SVMXC__Quantity_Transferred2__c=2,SVMXC__Select__c = true,SVMXC__Stock_Transfer__c = sxfrObject1.Id,SVMXC__Use_Price_From_Pricebook__c=true);
            insert sxfrLineObject3;
            
            sxfrLineArray.add(sxfrLineObject2);
            sxfrLineArray.add(sxfrLineObject1);
            
            sxfrlObjec = new SVMXC.SXFR_CreateSTLines(sxfrStdController);
            sxfrlObjec.setNewSXFRLine(sxfrLineArray);
            PageReference removeSXFRLines=sxfrlObjec.RemoveSXFRLine();
            
            //Scenario to qualify the method : getDisplayTableColumns()
            Boolean dispTabCol = sxfrlObjec.getDisplayTableColumns();
            sxfrLineArray.clear();
            //sxfrlObjec.setNewSXFRLine(sxfrLineArray);
            dispTabCol = sxfrlObjec.getDisplayTableColumns();
            
            //Scenario to qualify the method : ClearWarnings() & UpdateLines()
            PageReference clrWarnings = sxfrlObjec.ClearWarnings();
            clrWarnings = sxfrlObjec.ClearWarnings();
            
            PageReference updl = sxfrlObjec.UpdateLines();
            updl = sxfrlObjec.UpdateLines();   
            
            //Configuring Price for Product
            pbStd = [select name, IsActive from Pricebook2 where IsStandard = true limit 1];
            
            /* Create a pricebook entries. */
            pbe = new PricebookEntry();
            pbe.Pricebook2Id = pbStd.id;
            pbe.Product2Id   = prodSXFR.id;
            pbe.IsActive     = true;
            pbe.UnitPrice    = 10;        
            insert pbe; 
            
            //Scenario to qualify the method : GettPrice()
            IBObject = new SVMXC__Installed_Product__c(Name = 'Test IB1',SVMXC__Status__c = 'Installed',SVMXC__Product__c = prodSXFR.Id,SVMXC__Date_Installed__c = System.Today(),SVMXC__Contact__c = contact.Id,SVMXC__Company__c = account.Id);
            insert IBObject;
            sxfrLineObject4 = new SVMXC__Stock_Transfer_Line__c(SVMXC__Additional_Information__c='Unit Test Case for SXFR',SVMXC__Posted_To_Inventory__c=true,SVMXC__Product__c=prodSXFR.Id,SVMXC__Quantity_Transferred2__c=2,SVMXC__Select__c = true,SVMXC__Stock_Transfer__c = sxfrObject1.Id,SVMXC__Use_Price_From_Pricebook__c=true);
            insert sxfrLineObject4;
            
            sxfrLineObject5 = new SVMXC__Stock_Transfer_Line__c(SVMXC__Additional_Information__c='Unit Test Case for SXFR',SVMXC__Posted_To_Inventory__c=true,SVMXC__Product__c=prodSXFR.Id,SVMXC__Quantity_Transferred2__c=2,SVMXC__Select__c = true,SVMXC__Stock_Transfer__c = sxfrObject1.Id,SVMXC__Use_Price_From_Pricebook__c=true);
            insert sxfrLineObject5;
            
            sxfrLineArray.add(sxfrLineObject4);
            PageReference gtprice = sxfrlObjec.GettPrice();
            
            system.assert(sxfrlObjec.getSourceSXFRData()!=null,'getSourceSXFRData assertion failed');           
            system.assert(sxfrlObjec.getSourceSXFR()!=null,'getSourceSXFR assertion failed');
            system.assert(sxfrlObjec.getExistingLines()!=null,'getExistingLines assertion failed');   
            
            //Scenario to qualify the method : DisplayErrorsNWarnings()
            sxfrlObjec.AddToWarningsList('Test Warning Message2');
            sxfrlObjec.DisplayErrorsNWarnings();
            
            sxfrlObjec.SVMX_getProductIdFromIB(IBObject.Id);
            sxfrlObjec.AddToErrorsList('Test Warning Message3');
            sxfrlObjec.getErrorsList();
            sxfrlObjec.DisplayErrorsNWarnings();
            
            //Scenario to qualify regular set & get methods
            sxfrlObjec.AddToWarningsList('') ;
            List<String> warnings = sxfrlObjec.getWarningsList();
                   
            Boolean chklines = sxfrlObjec.getCheckAllLines();
            sxfrlObjec.setCheckAllLines(true);
            
            
            Boolean shw=sxfrlObjec.getshowWarnings(); 
            sxfrlObjec.setshowWarnings(true);
            
            Boolean shw1=sxfrlObjec.getshowWarnings(); 
            sxfrlObjec.setshowWarnings(false);  
            
            sxfrlObjec.setshowWarnings(true);
            Boolean dispMsg = sxfrlObjec.getDisplayBlockLevelMessage();
            
            system.assert(sxfrlObjec.getTAG001()!=null,'getTAG001 assertion failed');
            system.assert(sxfrlObjec.getTAG002()!=null,'getTAG002 assertion failed');
            system.assert(sxfrlObjec.getTAG003()!=null,'getTAG003 assertion failed');
            system.assert(sxfrlObjec.getTAG004()!=null,'getTAG004 assertion failed');
            system.assert(sxfrlObjec.getTAG005()!=null,'getTAG005 assertion failed');
            system.assert(sxfrlObjec.getTAG006()!=null,'getTAG006 assertion failed');
            system.assert(sxfrlObjec.getTAG007()!=null,'getTAG007 assertion failed');
            system.assert(sxfrlObjec.getTAG008()!=null,'getTAG008 assertion failed');
            system.assert(sxfrlObjec.getTAG009()!=null,'getTAG009 assertion failed');
            system.assert(sxfrlObjec.getTAG011()!=null,'getTAG011 assertion failed'); 
            system.assert(sxfrlObjec.getTAG012()!=null,'getTAG012 assertion failed');
            system.assert(sxfrlObjec.getTAG013()!=null,'getTAG013 assertion failed');
            system.assert(sxfrlObjec.getTAG014()!=null,'getTAG014 assertion failed');
            system.assert(sxfrlObjec.getTAG015()!=null,'getTAG015 assertion failed');      
            system.assert(sxfrlObjec.getTAG016()!=null,'getTAG016 assertion failed');
            system.assert(sxfrlObjec.getTAG018()!=null,'getTAG018 assertion failed');
            system.assert(sxfrlObjec.getTAG019()!=null,'getTAG019 assertion failed');
            system.assert(sxfrlObjec.getTAG021()!=null,'getTAG021 assertion failed');
            system.assert(sxfrlObjec.getTAG022()!=null,'getTAG022 assertion failed');
            system.assert(sxfrlObjec.getHLPURL()!=null,'getHLPURL assertion failed');
            
            //sxfrlObjec.svmxTagList.clear(); 
            
            system.assert(sxfrlObjec.getTAG001()!=null,'getTAG001 assertion failed');
            system.assert(sxfrlObjec.getTAG002()!=null,'getTAG002 assertion failed');
            system.assert(sxfrlObjec.getTAG003()!=null,'getTAG003 assertion failed');
            system.assert(sxfrlObjec.getTAG004()!=null,'getTAG004 assertion failed');
            system.assert(sxfrlObjec.getTAG005()!=null,'getTAG005 assertion failed');
            system.assert(sxfrlObjec.getTAG006()!=null,'getTAG006 assertion failed');
            system.assert(sxfrlObjec.getTAG007()!=null,'getTAG007 assertion failed');
            system.assert(sxfrlObjec.getTAG008()!=null,'getTAG008 assertion failed');
            system.assert(sxfrlObjec.getTAG009()!=null,'getTAG009 assertion failed');
            system.assert(sxfrlObjec.getTAG011()!=null,'getTAG011 assertion failed'); 
            system.assert(sxfrlObjec.getTAG012()!=null,'getTAG012 assertion failed');
            system.assert(sxfrlObjec.getTAG013()!=null,'getTAG013 assertion failed');
            system.assert(sxfrlObjec.getTAG014()!=null,'getTAG014 assertion failed');
            system.assert(sxfrlObjec.getTAG015()!=null,'getTAG015 assertion failed');      
            system.assert(sxfrlObjec.getTAG016()!=null,'getTAG016 assertion failed');
            system.assert(sxfrlObjec.getTAG018()!=null,'getTAG018 assertion failed');
            system.assert(sxfrlObjec.getTAG019()!=null,'getTAG019 assertion failed');
            system.assert(sxfrlObjec.getTAG021()!=null,'getTAG021 assertion failed');
            system.assert(sxfrlObjec.getTAG022()!=null,'getTAG022 assertion failed');
            system.assert(sxfrlObjec.getHLPURL()!=null,'getHLPURL assertion failed');
            
            //Scenario to qualify the method : ValidateAllSettings()
            String ObjName=''; 
            String SOQLStatement=''; 
                
            ObjName = 'SVMXC__ServiceMax_Processes__c';
            SOQLStatement = 'SELECT Id, Name FROM RecordType WHERE SobjectType =\''+ ObjName+ '\' ';
            rtSVMX_Processes = Database.query(SOQLStatement);    
            
            ObjName= 'SVMXC__ServiceMax_Config_Data__c'; 
            SOQLStatement = 'SELECT Id, Name FROM RecordType WHERE SobjectType =\''+ ObjName+ '\' ';
            rtSVMX_ConfData = Database.query(SOQLStatement);
                
            String Module_ID_c = 'PREQ';
            String Sub_Module_ID_c = 'PREQ002';
                
            for(RecordType rt : rtSVMX_Processes){ //Loop to take a record type at a time
                // Retrieve Module Record
                if(rt.Name == 'Module'){
                    module = [Select Id from SVMXC__ServiceMax_Processes__c where RecordTypeId =:rt.Id and SVMXC__ModuleID__c = :Module_ID_c LIMIT 1];
                } 
            }//for  
                
            for(RecordType rt : rtSVMX_Processes){ //Loop to take a record type at a time
                // Retrieve Sub Module Record
                if(rt.Name == 'Submodule'){
                    subModule = [Select Id ,SVMXC__SUBMODULEID__C from SVMXC__ServiceMax_Processes__c where RecordTypeId =:rt.Id and SVMXC__SUBMODULEID__C = :Sub_Module_ID_c and SVMXC__MODULE__C = :module.Id LIMIT 1];
                } 
            }//for  
              
            String SET001 = 'SET001'; 
            String SET002 = 'SET002';
            String SET003 = 'SET003';
            String SET004 = 'SET004';
            
            sxfrlObjec = new SVMXC.SXFR_CreateSTLines(sxfrStdController); 
            
            sxfrlObjec.AllSubModuleSettings.clear();
            sxfrlObjec.AllSubModuleSettings.put('SET002','False');
            sxfrlObjec.AllSubModuleSettings.put('SET003','No Pricebook');
            sxfrlObjec.ValidateAllSettings(); 
            sxfrlObjec.AllSubModuleSettings.clear();
            sxfrlObjec.AllSubModuleSettings.put('SET002','True');
            sxfrlObjec.AllSubModuleSettings.put('SET003','Standard Pricebook');
            sxfrlObjec.ValidateAllSettings();
            system.assert(sxfrlObjec.getSourceSXFR()!=null,'getSourceSXFR assertion failed');
            Boolean chklines1 = sxfrlObjec.getCheckAllLines();
            sxfrlObjec.setCheckAllLines(false);       
            Boolean dibm = sxfrlObjec.getDisplayBlockLevelMessage();       
            sxfrlObjec.UpdateLines();
            system.assert(sxfrlObjec.getSourceSXFR()!=null,'getSourceSXFR assertion failed');
            PageReference addSXFRLine1 = sxfrlObjec.AddSXFRLine(); 
            test.stopTest();       
        }
        catch(exception Ex){
            System.debug(Ex.getStackTraceString() );
        }
    }
}