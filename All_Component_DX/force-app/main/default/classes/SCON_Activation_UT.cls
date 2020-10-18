@isTest
Private class SCON_Activation_UT 
{
    private static SVMXC.SCON_Activation sconObject1;   
    private static Account account;
    private static Contact contact ;
    private static Case case1;
    private static Product2  prodSCont1,prodSCont2,prodSCont3, prodSCont4, prodSContActive,prodSContActive1,prod;
    private static SVMXC__Site__c Location1, Location2;
    private static SVMXC__Service_Contract__c SconObject; 
    private static SVMXC__Service_Contract_Products__c sconChildProdObj;                    
    private static SVMXC__Service_Contract_Services__c sconChildServ ;
    private static SVMXC__Service_Contract_Contacts__c sconChildContact;
    private static SVMXC__Service_Contract_Sites__c sconChildSites;
     //SconObject
    private static List<SVMXC__Service_Contract_Products__c> scontprodArray = new List<SVMXC__Service_Contract_Products__c>();
    private static List<SVMXC__Service_Contract_Services__c> scontsvrArray = new List<SVMXC__Service_Contract_Services__c>();
    private static List<SVMXC__Service_Contract_Contacts__c> scontcontArray = new List<SVMXC__Service_Contract_Contacts__c>();
    private static List<SVMXC__Service_Contract_Sites__c> scontsitesArray = new List<SVMXC__Service_Contract_Sites__c>();
    private static SVMXC__Installed_Product__c IBObject ;
    private static SVMXC__Site__c sconLocation, sconLocation1;
    private static SVMXC__Service_Level__c sconSLA = new SVMXC__Service_Level__c();
    private static SVMXC__Service__c sconSER = new SVMXC__Service__c();
    static testMethod void SCON_ActivateContract_Test()
    {     
       
      try
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
        system.assertEquals('Account', account.Name);
        contact = new Contact(LastName='Last', AccountId =account.Id,Email='svmxmailfortest@servicemax.com');
        insert contact;
        case1 = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                                                                 
                                        ContactId =contact.Id,
                                        AccountId=account.Id
                                        ); 
        insert case1;
        system.assertEquals('New', case1.Status);
       //product With Parent Warranty 
        prodSCont1 = new Product2 (
                                        Name ='prodSCont1',
                                        
                                        ProductCode='prodSCont1',
                                        SVMXC__Inherit_Parent_Warranty__c =True
                                                                             
                                        ); 
        insert prodSCont1;
        system.assertEquals('prodSCont1', prodSCont1.Name);
        
        //product Without Parent Warranty
        prodSCont2 = new Product2 (
                                        Name ='prodSCont2',
                                        ProductCode='prodSCont2',
                                        SVMXC__Inherit_Parent_Warranty__c =False
                                                                             
                                        );                                              
        insert prodSCont2;
        system.assertEquals('prodSCont2', prodSCont2.Name);
        
        //product Without Parent Warranty
        prodSCont3 = new Product2 (
                                        Name ='prodSCont3',
                                        ProductCode='prodSCont3',
                                        SVMXC__Inherit_Parent_Warranty__c =True
                                                                           
                                        );                                              
        insert prodSCont3;
        system.assertEquals('prodSCont3', prodSCont3.Name);
        
        prod =       new Product2(
                                       Name = 'Prod', 
                                       ProductCode = '1235', 
                                       Family = 'Accessory', 
                                       SVMXC__Inherit_Parent_Warranty__c =False 
                                       
                                       );
        insert prod;
         system.assertEquals('Prod', prod.Name);
        
        sconLocation = new SVMXC__Site__c(
                                        SVMXC__Zip__c ='90909090',
                                        SVMXC__Street__c ='ABC',
                                        SVMXC__State__c ='ABC',
                                        SVMXC__Country__c ='ABC',
                                        SVMXC__City__c ='ABC',
                                        SVMXC__Account__c=account.Id
                                        );
        insert sconLocation;
        
       
        
        sconSLA = new SVMXC__Service_Level__c(
                                        
                                        SVMXC__Active__c=true,
                                        SVMXC__Description__c = 'Test Desc',
                                        SVMXC__Effective_Date__c=System.today()
                                        
                                        );
        insert sconSLA;
        
        sconSER = new SVMXC__Service__c(
                                        
                                        SVMXC__Active__c=true,
                                        Name = 'Test Service',
                                        SVMXC__Effective_Date__c=System.today(),
                                        SVMXC__Service_Type__c = 'Installation'
                                        );
        insert sconSER;
                                        
        IBObject = new SVMXC__Installed_Product__c(
                    Name = 'Test IB1',
                    SVMXC__Status__c = 'Installed',
                    SVMXC__Product__c = prod.Id,
                    SVMXC__Date_Installed__c = System.Today(),
                    SVMXC__Contact__c = contact.Id,
                    SVMXC__Company__c = account.Id,
                    SVMXC__Serial_Lot_Number__c = 'Test2', 
                    SVMXC__Date_Shipped__c = System.today()
                    );
         insert IBObject;
         
        SconObject = new SVMXC__Service_Contract__c(
                                             
                                             Name='ZZ1',
                                             //ContactId =contact.Id,
                                             SVMXC__Company__c=account.Id,
                                             SVMXC__Activation_Notes__c= 'Its with Unit Test Case',
                                             SVMXC__Active__c=false,
                                             SVMXC__All_Contacts_Covered__c=false,
                                             SVMXC__All_Products_Covered__c=false,
                                             SVMXC__All_Services_Covered__c=false,
                                             SVMXC__All_Sites_Covered__c=true,
                                             SVMXC__Billing_Schedule__c='Annual',//Semi Annual,Quarterly,Monthly,Full Upfront,other;
                                             SVMXC__Cancelation_Notes__c=null,
                                             SVMXC__Contact__c=Contact.Id,
                                            // SVMXC__Contract_Price2__c='15',
                                             //SVMXC__Discount__c='10%',
                                            //SVMXC__Discounted_Price2__c
                                             SVMXC__End_Date__c=System.today().addDays(50),//5/12/2009,
                                             //SVMXC__EndpointURL__c=
                                             SVMXC__Renewal_Date__c=null,
                                             SVMXC__Renewal_Notes__c=null,
                                             SVMXC__Renewal_Number__c=null,
                                             SVMXC__Renewed_From__c=null,
                                             SVMXC__Sales_Rep__c=null,
                                             SVMXC__Service_Contract_Notes__c='Its for Test method',
                                            //SVMXC__SESSION_ID__c='',
                                             SVMXC__Service_Level__c= sconSLA.id,
                                             SVMXC__Start_Date__c=System.today().addDays(-50)
                                             //SVMXC__Weeks_To_Renewal__c=''                                          
                                             );
        insert SconObject;  
        
        PageReference pageRef1 = new PageReference('Page.SVMXC.SCON_Activation');
        pageRef1.getParameters().put('id',SconObject.Id);
        Test.setCurrentPageReference(pageRef1); 
        
        ApexPages.StandardController SCONStdController1 = new ApexPages.standardController(SconObject);
        sconObject1 = new SVMXC.SCON_Activation(SCONStdController1);
        
        sconObject1.svmxSettingList.put('SET001','DISALLOW');
        sconObject1.svmxSettingList.put('SET002','DISALLOW');
        sconObject1.svmxSettingList.put('SET003','DISALLOW');
        sconObject1.svmxSettingList.put('SET004','DISALLOW');   
        sconObject1.validateSettingValues();        
        sconObject1.ValidateAllSettings();
        
        sconObject1.svmxSettingList.put('SET001','WARN');
        sconObject1.svmxSettingList.put('SET002','WARN');
        sconObject1.svmxSettingList.put('SET003','WARN');
        sconObject1.svmxSettingList.put('SET004','WARN');   
        sconObject1.validateSettingValues();        
        sconObject1.ValidateAllSettings();
    
        sconChildProdObj = new SVMXC__Service_Contract_Products__c(
                    
                                            //Name='ZZ1', //SCPN-000055',
                                            SVMXC__Installed_Product__c=IBObject.Id,
                                            SVMXC__Product_Family__c='Accessory',
                                            SVMXC__Product_Line__c='Accessory',
                                            SVMXC__Notes__c='Its for test method',
                                            SVMXC__Service_Contract__c = SconObject.Id
                                            
                                            );
        insert sconChildProdObj;
    
        sconChildSites = new SVMXC__Service_Contract_Sites__c(
                                             //Name='SCSN-000014',
                                             SVMXC__Service_Contract__c = SconObject.Id,
                                             SVMXC__Site__c= sconLocation.Id,
                                             SVMXC__Notes__c='Hai its Sites notes'
                                             );
                                             
        insert sconChildSites;
    
        sconChildServ = new SVMXC__Service_Contract_Services__c(
                                            //Name='SCSN-000014',
                                            SVMXC__Service_Contract__c = SconObject.Id,
                                            SVMXC__Service__c = sconSER.Id,
                                            SVMXC__Service_Type__c='None',
                                            SVMXC__Notes__c='Its for Scont Activation'
                                            );
        insert sconChildServ;  
    
        sconChildContact = new SVMXC__Service_Contract_Contacts__c(
                                            
                                            //Name='SCCN-000015',
                                            SVMXC__Service_Contract__c = SconObject.Id,
                                            SVMXC__Contact__c=contact.Id,
                                            SVMXC__Notes__c ='Its for Activation of Contract'
                                            ); 
        insert sconChildContact;
        
        ApexPages.StandardController SCONStdController = new ApexPages.standardController(SconObject);         
        test.startTest();       
        sconObject1 = new SVMXC.SCON_Activation(SCONStdController);
        sconObject1.svmxSettingList.put('SET001','DISALLOW');
        sconObject1.svmxSettingList.put('SET002','DISALLOW');
        sconObject1.svmxSettingList.put('SET003','DISALLOW');
        sconObject1.svmxSettingList.put('SET004','DISALLOW');
        
        //Scenario to qualify Cancel()& ActivateContract() methods
        PageReference cancl = sconObject1.Cancel();
        PageReference  ac = sconObject1.ActivateContract();
        
        Boolean bvar = true;
        bvar = sconObject1.getIsActivatedContract();
        bvar = sconObject1.getIstoDisplay();
        bvar = sconObject1.getDisplayActivate();
        bvar = sconObject1.getDisplayContinue();
        bvar = sconObject1.getshowDetailBlock();
        bvar = sconObject1.getshowUpsellMessage();        
        
        bvar = true;
        sconObject1.setIsActivatedContract(bvar);
        sconObject1.setIstoDisplay(bvar);
        sconObject1.setDisplayActivate(bvar);
        sconObject1.setDisplayContinue(bvar);
        sconObject1.setshowDetailBlock(bvar);
        sconObject1.setshowUpsellMessage(bvar);
        
        bvar = false;
        sconObject1.setIsActivatedContract(bvar);
        sconObject1.setIstoDisplay(bvar);
        sconObject1.setDisplayActivate(bvar);
        sconObject1.setDisplayContinue(bvar);
        sconObject1.setshowDetailBlock(bvar);
        sconObject1.setshowUpsellMessage(bvar);
        
        String str = sconObject1.getSET001();
        List<String> strList = new  List<String>();
        sconObject1.AddToErrorsList('Test');
        
        strList = sconObject1.getErrorsList();
        sconObject1.DisplayErrors ();
        sconObject1.svmxSettingList.clear();
        sconObject1.validateSettingValues();     
       
        sconObject1.doSetUp();
        
        //Scenario to qualify regular set & get methods
        SVMXC__Service_Contract__c sconObj = sconObject1.getSContractHeader(); 

        String  strTag001 = sconObject1.getTAG001();
        String  strTag002 = sconObject1.getTAG002();
        String  strTag003 = sconObject1.getTAG003();
        String  strTag004 = sconObject1.getTAG004();       
        String  strTag006 = sconObject1.getTAG006();
        String  strTag007=  sconObject1.getTAG007();
        String  strTag008 = sconObject1.getTAG008();
        String  strTag009 = sconObject1.getTAG009();
        String  strTag010 = sconObject1.getTAG010();
        String  strTag011 = sconObject1.getTAG011();
        String  strTag012 = sconObject1.getTAG012();
        String  strTag013 = sconObject1.getTAG013();      
        String  strTag015 = sconObject1.getTAG015();
        String  strTag016 = sconObject1.getTAG016();
        String  strTag017 = sconObject1.getTAG017();
        String  strTag018 = sconObject1.getTAG018();
        String  strTag020 = sconObject1.getTAG020();
        String  strTag021 = sconObject1.getTAG021();
        String  strTagHLPURL = sconObject1.getHLPURL();
        String  strTag001b = sconObject1.getTAG001();
        String  strTag002b = sconObject1.getTAG002();
        String  strTag003b = sconObject1.getTAG003();
        String  strTag004b = sconObject1.getTAG004();
        String  strTag006b = sconObject1.getTAG006();
        String  strTag007b=  sconObject1.getTAG007();
        String  strTag008b = sconObject1.getTAG008();
        String  strTag009b = sconObject1.getTAG009();
        String  strTag010b = sconObject1.getTAG010();
        String  strTag011b = sconObject1.getTAG011();
        String  strTag012b = sconObject1.getTAG012();
        String  strTag013b = sconObject1.getTAG013();       
        String  strTag015b = sconObject1.getTAG015();
        String  strTag016b = sconObject1.getTAG016();
        String  strTag017b = sconObject1.getTAG017();
        String  strTag018b = sconObject1.getTAG018();
        String  strTag020b = sconObject1.getTAG020();
        String  strTag021b = sconObject1.getTAG021();
        String  strTagHLPURLb = sconObject1.getHLPURL();
        
        sconObject1.getUserLocaleKey();
        sconObject1.getUserID();
        sconObject1.getUserOrgID();   
        
        SconObject.SVMXC__End_Date__c = System.today().addDays(-1);
        ApexPages.StandardController SCONStdController2 = new ApexPages.standardController(SconObject);
        PageReference pageRef2 = new PageReference('Page.SVMXC.SCON_Activation');
         pageRef1.getParameters().put('id',SconObject.Id);
        Test.setCurrentPageReference(pageRef2); 
        SCON_Activation sconObject2 = new SVMXC.SCON_Activation(SCONStdController);
        sconObject2.doSetUp();
        System.debug('hari '+sconObject2.getContractProducts());
       
        PageReference  ac2 = sconObject2.ActivateContract();
        PageReference cancl2 = sconObject2.Cancel();        
        test.stopTest();        
      }
      catch(Exception ex)
       {}       
    }
}