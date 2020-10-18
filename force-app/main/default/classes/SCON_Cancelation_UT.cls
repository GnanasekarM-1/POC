@isTest
Private class SCON_Cancelation_UT 
{
    private static SVMXC.SCON_Cancelation SConCancel;
    private static Account account;
    private static Contact contact ;
    private static Case case1, case2;
    private static Product2  prodSCont1,prodSCont2,prodSCont3, prodSCont4, prodSContActive,prodSContActive1,prod;
    
    private static SVMXC__Service_Contract__c SconObject; 
    private static SVMXC__Service_Contract_Products__c sconChildProdObj;                    
    private static SVMXC__Service_Contract_Services__c sconChildServ ;
    private static SVMXC__Service_Contract_Contacts__c sconChildContact;
    private static SVMXC__Service_Contract_Sites__c sconChildSites;
    
     // Objects for Setting Def
    private static SVMXC__ServiceMax_Settings__c setngAContwoProdCov;
    private static SVMXC__ServiceMax_Settings__c setngAContwoSiteCov;
    private static SVMXC__ServiceMax_Settings__c setngAContwoSvrCov;
    private static SVMXC__ServiceMax_Settings__c setngAContwoContactCov;   
    
     //Objects for Setting Value
    private static SVMXC__ServiceMax_Config_Data__c setngValAContwoProdCov; 
    private static SVMXC__ServiceMax_Config_Data__c setngValAContwoSiteCov; 
    private static SVMXC__ServiceMax_Config_Data__c setngValAContwoSvrCov;
    private static SVMXC__ServiceMax_Config_Data__c setngValAContwoContCov;
    
    //SconObject
    private static List<SVMXC__Service_Contract_Products__c> scontprodArray = new List<SVMXC__Service_Contract_Products__c>();
    private static List<SVMXC__Service_Contract_Services__c> scontsvrArray = new List<SVMXC__Service_Contract_Services__c>();
    private static List<SVMXC__Service_Contract_Contacts__c> scontcontArray = new List<SVMXC__Service_Contract_Contacts__c>();
    private static List<SVMXC__Service_Contract_Sites__c> scontsitesArray = new List<SVMXC__Service_Contract_Sites__c>();    
    
    private static SVMXC__Installed_Product__c IBObject ;
    private static SVMXC__Site__c sconLocation, sconLocation1;
    private static SVMXC__Service__c sconSLA;    
    
    //Variables for Configuration Setting Data   
    private static List<RecordType> rtSVMX_Processes = new List<RecordType>();
    private static List<RecordType> rtSVMX_ConfData = new List<RecordType>();
    
    //Objects for Profile Object    
    private static SVMXC__ServiceMax_Config_Data__c configProfile;
    //Objects for Module, Submodule
    private static SVMXC__ServiceMax_Processes__c module;
    private static SVMXC__ServiceMax_Processes__c subModule;
    
    static testmethod void SCON_CancelContract_Test()
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
        
            contact = new Contact(LastName='Last', AccountId =account.Id,Email='svmxmailfortest@servicemax.com');
            insert contact;     
        
            case2 = new Case(Status ='Closed', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                        ContactId =contact.Id,
                                        AccountId=account.Id                                        
                                        ); 
            insert case2; 
        
            //product With Parent Warranty  
            prodSCont1 = new Product2 (
                                            Name ='prodSCont1',
                                            
                                            ProductCode='prodSCont1',
                                            SVMXC__Inherit_Parent_Warranty__c =False
                                            );                                  
                                             
            insert prodSCont1;
            
             //product Without Parent Warranty
            prodSCont2 = new Product2 (
                                            Name ='prodSCont2',
                                            ProductCode='prodSCont2',
                                            SVMXC__Inherit_Parent_Warranty__c =False
                                            );                                
                                                                                          
            insert prodSCont2;
            
            //product Without Parent Warranty
            prodSCont3 = new Product2 (
                                            Name ='prodSCont3',
                                            ProductCode='prodSCont3',
                                            SVMXC__Inherit_Parent_Warranty__c =False
                                             );                                  
                                                                                         
            insert prodSCont3;
            
            prod =       new Product2(
                                           Name = 'Prod', 
                                           ProductCode = '1235', 
                                           Family = 'Accessory', 
                                           SVMXC__Inherit_Parent_Warranty__c =False 
                                          );
                                           
            insert prod;
            
            sconLocation = new SVMXC__Site__c(
                                            SVMXC__Zip__c ='90909090',
                                            SVMXC__Street__c ='ABC',
                                            SVMXC__State__c ='ABC',
                                            SVMXC__Country__c ='ABC',
                                            SVMXC__City__c ='ABC',
                                            SVMXC__Account__c=account.Id
                                            );
            insert sconLocation;
            
            sconSLA = new SVMXC__Service__c(
                                            
                                            SVMXC__Active__c=true,
                                            //SVMXC__Service_Type__c
                                            SVMXC__Effective_Date__c=System.today()
                                            
                                            );
            insert sconSLA;
            
            IBObject = new SVMXC__Installed_Product__c(
                        Name = 'Test IB1',
                        SVMXC__Status__c = 'Installed',
                        SVMXC__Product__c = prod.Id,
                        SVMXC__Date_Installed__c = System.Today(),
                        SVMXC__Contact__c = contact.Id,
                        SVMXC__Company__c = account.Id
                        
                        );
             insert IBObject;
             
             SconObject = new SVMXC__Service_Contract__c(
                                                 
                                                 Name='ZZ1',
                                                 //ContactId =contact.Id,
                                                 SVMXC__Company__c=account.Id,
                                                 SVMXC__Activation_Notes__c= 'Its with Unit Test Case',
                                                 SVMXC__Active__c=false,
                                                 SVMXC__All_Contacts_Covered__c=true,
                                                 SVMXC__All_Products_Covered__c=true,
                                                 SVMXC__All_Services_Covered__c=false,
                                                 SVMXC__All_Sites_Covered__c=true,
                                                 SVMXC__Billing_Schedule__c='Annual',//Semi Annual,Quarterly,Monthly,Full Upfront,other;
                                                 SVMXC__Cancelation_Notes__c=null,
                                                 SVMXC__Contact__c=Contact.Id,
                                                 SVMXC__End_Date__c = System.today().addDays(50),//5/12/2009,
                                                 SVMXC__Renewal_Date__c=null,
                                                 SVMXC__Renewal_Notes__c=null,
                                                 SVMXC__Renewal_Number__c=null,
                                                 SVMXC__Renewed_From__c=null,
                                                 SVMXC__Sales_Rep__c=null,
                                                 SVMXC__Service_Contract_Notes__c='Its for Test method',
                                                 SVMXC__Start_Date__c=System.today().addDays(-50)
                                                 );
            insert SconObject;
             
            sconChildProdObj = new SVMXC__Service_Contract_Products__c(
                                                SVMXC__Installed_Product__c=IBObject.Id,
                                                SVMXC__Product_Family__c='Accessory',
                                                SVMXC__Product_Line__c='Accessory',
                                                SVMXC__Notes__c='Its for test method',
                                                SVMXC__Service_Contract__c = SconObject.Id
                                                );
            insert sconChildProdObj;
            
            sconChildSites = new SVMXC__Service_Contract_Sites__c(
                                                 SVMXC__Service_Contract__c = SconObject.Id,
                                                 SVMXC__Site__c= sconLocation.Id,
                                                 SVMXC__Notes__c='Hai its Sites notes'
                                                 );
            insert sconChildSites;
        
            sconChildServ = new SVMXC__Service_Contract_Services__c(
                                                SVMXC__Service_Contract__c = SconObject.Id,
                                                SVMXC__Service__c = sconSLA.Id,
                                                SVMXC__Service_Type__c='None',
                                                SVMXC__Notes__c='Its for Scont Activation'
                                                );
            insert sconChildServ;
        
        
            sconChildContact = new SVMXC__Service_Contract_Contacts__c(
                                                SVMXC__Service_Contract__c = SconObject.Id,
                                                SVMXC__Contact__c=contact.Id,
                                                SVMXC__Notes__c ='Its for Activation of Contract'
                                                ); 
            insert sconChildContact;
            
                
            SVMXC__Entitlement_History__c objEntitleHistory1 =  new SVMXC__Entitlement_History__c();
            objEntitleHistory1.SVMXC__Service_Contract__c = SconObject.Id;  
            objEntitleHistory1.SVMXC__Case__c = case2.Id;
            insert objEntitleHistory1;
            System.assert(objEntitleHistory1.id != null);
            
            test.starttest();
            
            ApexPages.StandardController SCONStdController = new ApexPages.standardController(SconObject);        
            system.assertEquals(System.currentPageReference().getParameters().get('id'),null);
            PageReference pageRef1 = new PageReference('Page.SVMXC.SCON_Cancelation');
            pageRef1.getParameters().put('id',SconObject.Id);
            Test.setCurrentPageReference(pageRef1); 
            SConCancel = new SVMXC.SCON_Cancelation(SCONStdController);             
            system.assertNotEquals(System.currentPageReference().getParameters().get('id'),null);
            
            SVMXC__Service_Contract__c sconObj = SConCancel.getSContractHeader() ; 
            system.assertNotEquals(sconObj,null);
            String  strTag001 = SConCancel.getTAG001();
            String  strTag002 = SConCancel.getTAG002();
            String  strTag003 = SConCancel.getTAG003();
            String  strTag004 = SConCancel.getTAG004();
            String  strTag005=  SConCancel.getTAG005();
            String  strTag006 = SConCancel.getTAG006();
            String  strTag007=  SConCancel.getTAG007();
            String  strTag008 = SConCancel.getTAG008();
            String  strTag009 = SConCancel.getTAG009();
            String  strTag010 = SConCancel.getTAG010();
            String  strTag011 = SConCancel.getTAG011();
            String  strTag012 = SConCancel.getTAG012();
            String  strTag013 = SConCancel.getTAG013();
            String  strTag014 = SConCancel.getTAG014();
            String  strTag015 = SConCancel.getTAG015();
            String  strHLPURL = SConCancel.getHLPURL();
            String  strTag101 = SConCancel.getTAG001();
            String  strTag102 = SConCancel.getTAG002();
            String  strTag103 = SConCancel.getTAG003();
            String  strTag104 = SConCancel.getTAG004();
            String  strTag105=  SConCancel.getTAG005();
            String  strTag106 = SConCancel.getTAG006();
            String  strTag107=  SConCancel.getTAG007();
            String  strTag108 = SConCancel.getTAG008();
            String  strTag109 = SConCancel.getTAG009();
            String  strTag110 = SConCancel.getTAG010();
            String  strTag111 = SConCancel.getTAG011();
            String  strTag112 = SConCancel.getTAG012();
            String  strTag113 = SConCancel.getTAG013();
            String  strTag114 = SConCancel.getTAG014();
            String  strTag115 = SConCancel.getTAG015();
            String  strHLPURLa = SConCancel.getHLPURL();
       
            Boolean IsActCon = SConCancel.getIsActivatedContract();
            SConCancel.setIsActivatedContract(false);
            system.assertNotEquals(SConCancel.getIsActivatedContract(),true);
            SConCancel.setshowDetailBlock(true);//added
            Boolean showDb=SConCancel.getshowDetailBlock();
            SConCancel.setshowDetailBlock(true);
            system.assert(SConCancel.getshowDetailBlock());     
            Boolean showUm=SConCancel.getshowUpsellMessage();
            SConCancel.setshowUpsellMessage(true);
        
            List<String> fieldList = new List<String>();
            fieldList.add('TEST1');
            fieldList.add('TEST2');     
            Boolean isfav=SVMXC.SCON_Cancelation.isFieldAvailable(fieldList,'TEST2');
            
            SConCancel.getSContEntlHisy();
            SConCancel.getSContractHeader();      
            SConCancel.Cancel();
            SConCancel.RevokeSContract();
            
            SConCancel.getUserLocaleKey();
            SConCancel.getUserID();
            SConCancel.getUserOrgID();              
            
            SconObject.SVMXC__Active__c = true;
            update SconObject;
            system.assert(SconObject.SVMXC__Active__c == true);
            SVMXC.SCON_Cancelation SConCancel2 = new SVMXC.SCON_Cancelation(SCONStdController);
                        
            test.stoptest();
        }
        catch(Exception ex)
        {}
    }
    static testmethod void SCON_CancelContract_Test1()
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
            
            contact = new Contact(LastName='Last', AccountId =account.Id,Email='svmxmailfortest@servicemax.com');
            insert contact;
            
            case1 = new Case(Status ='New', Priority = 'Medium', 
                                            Origin = 'Email',                                        
                                            ContactId =contact.Id,
                                            AccountId=account.Id                                        
                                            ); 
            insert case1; 
            
        
            //product With Parent Warranty 
            prodSCont1 = new Product2 (
                                            Name ='prodSCont1',
                                            
                                            ProductCode='prodSCont1',
                                            SVMXC__Inherit_Parent_Warranty__c =False
                                            );                                  
                                             
            insert prodSCont1;
            
             //product Without Parent Warranty
            prodSCont2 = new Product2 (
                                            Name ='prodSCont2',
                                            ProductCode='prodSCont2',
                                            SVMXC__Inherit_Parent_Warranty__c =False
                                            );                                
                                                                                          
            insert prodSCont2;
            
            //product Without Parent Warranty
            prodSCont3 = new Product2 (
                                            Name ='prodSCont3',
                                            ProductCode='prodSCont3',
                                            SVMXC__Inherit_Parent_Warranty__c =False
                                             );                                  
                                                                                         
            insert prodSCont3;
            
            prod =       new Product2(
                                           Name = 'Prod', 
                                           ProductCode = '1235', 
                                           Family = 'Accessory', 
                                           SVMXC__Inherit_Parent_Warranty__c =False 
                                          );
                                           
            insert prod;
            
            sconLocation = new SVMXC__Site__c(
                                            SVMXC__Zip__c ='90909090',
                                            SVMXC__Street__c ='ABC',
                                            SVMXC__State__c ='ABC',
                                            SVMXC__Country__c ='ABC',
                                            SVMXC__City__c ='ABC',
                                            SVMXC__Account__c=account.Id
                                            );
            insert sconLocation;
            
            sconSLA = new SVMXC__Service__c(
                                            
                                            SVMXC__Active__c=true,
                                            //SVMXC__Service_Type__c
                                            SVMXC__Effective_Date__c=System.today()
                                            
                                            );
            insert sconSLA;
            
            IBObject = new SVMXC__Installed_Product__c(
                        Name = 'Test IB1',
                        SVMXC__Status__c = 'Installed',
                        SVMXC__Product__c = prod.Id,
                        SVMXC__Date_Installed__c = System.Today(),
                        SVMXC__Contact__c = contact.Id,
                        SVMXC__Company__c = account.Id
                        
                        );
             insert IBObject;
             
             SconObject = new SVMXC__Service_Contract__c(
                                                 
                                                 Name='ZZ1',
                                                 //ContactId =contact.Id,
                                                 SVMXC__Company__c=account.Id,
                                                 SVMXC__Activation_Notes__c= 'Its with Unit Test Case',
                                                 SVMXC__Active__c=false,
                                                 SVMXC__All_Contacts_Covered__c=true,
                                                 SVMXC__All_Products_Covered__c=true,
                                                 SVMXC__All_Services_Covered__c=false,
                                                 SVMXC__All_Sites_Covered__c=true,
                                                 SVMXC__Billing_Schedule__c='Annual',//Semi Annual,Quarterly,Monthly,Full Upfront,other;
                                                 SVMXC__Cancelation_Notes__c=null,
                                                 SVMXC__Contact__c=Contact.Id,
                                                 SVMXC__End_Date__c = System.today().addDays(50),//5/12/2009,
                                                 SVMXC__Renewal_Date__c=null,
                                                 SVMXC__Renewal_Notes__c=null,
                                                 SVMXC__Renewal_Number__c=null,
                                                 SVMXC__Renewed_From__c=null,
                                                 SVMXC__Sales_Rep__c=null,
                                                 SVMXC__Service_Contract_Notes__c='Its for Test method',
                                                 SVMXC__Start_Date__c=System.today().addDays(-50)
                                                 );
            insert SconObject;
             
            sconChildProdObj = new SVMXC__Service_Contract_Products__c(
                                                SVMXC__Installed_Product__c=IBObject.Id,
                                                SVMXC__Product_Family__c='Accessory',
                                                SVMXC__Product_Line__c='Accessory',
                                                SVMXC__Notes__c='Its for test method',
                                                SVMXC__Service_Contract__c = SconObject.Id
                                                );
            insert sconChildProdObj;
            
            sconChildSites = new SVMXC__Service_Contract_Sites__c(
                                                 SVMXC__Service_Contract__c = SconObject.Id,
                                                 SVMXC__Site__c= sconLocation.Id,
                                                 SVMXC__Notes__c='Hai its Sites notes'
                                                 );
            insert sconChildSites;
        
            sconChildServ = new SVMXC__Service_Contract_Services__c(
                                                SVMXC__Service_Contract__c = SconObject.Id,
                                                SVMXC__Service__c = sconSLA.Id,
                                                SVMXC__Service_Type__c='None',
                                                SVMXC__Notes__c='Its for Scont Activation'
                                                );
            insert sconChildServ;
        
        
            sconChildContact = new SVMXC__Service_Contract_Contacts__c(
                                                SVMXC__Service_Contract__c = SconObject.Id,
                                                SVMXC__Contact__c=contact.Id,
                                                SVMXC__Notes__c ='Its for Activation of Contract'
                                                ); 
            insert sconChildContact;    
            
            test.starttest();
            ApexPages.StandardController SCONStdController = new ApexPages.standardController(SconObject);
            
            SVMXC__Entitlement_History__c objEntitleHistory =  new SVMXC__Entitlement_History__c();
            objEntitleHistory.SVMXC__Service_Contract__c = SconObject.Id;
            objEntitleHistory.SVMXC__Case__c = case1.Id;
            insert objEntitleHistory;
            System.assert(objEntitleHistory.id != null);    
            SVMXC.SCON_Cancelation SConCancel1 = new SVMXC.SCON_Cancelation(SCONStdController);
            
            system.assertEquals(System.currentPageReference().getParameters().get('id'),null);
            PageReference pageRef1 = new PageReference('Page.SVMXC.SCON_Cancelation');
             pageRef1.getParameters().put('id',SconObject.Id);
            Test.setCurrentPageReference(pageRef1); 
            SConCancel = new SVMXC.SCON_Cancelation(SCONStdController);     
            
            system.assertNotEquals(System.currentPageReference().getParameters().get('id'),null);
          
            SVMXC__Service_Contract__c sconObj = SConCancel.getSContractHeader() ; 
            system.assertNotEquals(sconObj,null);
            String  strTag001 = SConCancel.getTAG001();
            String  strTag002 = SConCancel.getTAG002();
            String  strTag003 = SConCancel.getTAG003();
            String  strTag004 = SConCancel.getTAG004();
            String  strTag005=  SConCancel.getTAG005();
            String  strTag006 = SConCancel.getTAG006();
            String  strTag007=  SConCancel.getTAG007();
            String  strTag008 = SConCancel.getTAG008();
            String  strTag009 = SConCancel.getTAG009();
            String  strTag010 = SConCancel.getTAG010();
            String  strTag011 = SConCancel.getTAG011();
            String  strTag012 = SConCancel.getTAG012();
            String  strTag013 = SConCancel.getTAG013();
            String  strTag014 = SConCancel.getTAG014();
            String  strTag015 = SConCancel.getTAG015();
            String  strHLPURL = SConCancel.getHLPURL();         
            String  strTag101 = SConCancel.getTAG001();
            String  strTag102 = SConCancel.getTAG002();
            String  strTag103 = SConCancel.getTAG003();
            String  strTag104 = SConCancel.getTAG004();
            String  strTag105=  SConCancel.getTAG005();
            String  strTag106 = SConCancel.getTAG006();
            String  strTag107=  SConCancel.getTAG007();
            String  strTag108 = SConCancel.getTAG008();
            String  strTag109 = SConCancel.getTAG009();
            String  strTag110 = SConCancel.getTAG010();
            String  strTag111 = SConCancel.getTAG011();
            String  strTag112 = SConCancel.getTAG012();
            String  strTag113 = SConCancel.getTAG013();
            String  strTag114 = SConCancel.getTAG014();
            String  strTag115 = SConCancel.getTAG015();
            String  strHLPURLa = SConCancel.getHLPURL();                   
       
            Boolean IsActCon = SConCancel.getIsActivatedContract();
            SConCancel.setIsActivatedContract(false);
            system.assertNotEquals(SConCancel.getIsActivatedContract(),true);
            SConCancel.setshowDetailBlock(true);//added
            Boolean showDb=SConCancel.getshowDetailBlock();
            SConCancel.setshowDetailBlock(true);
            system.assert(SConCancel.getshowDetailBlock());
            
            Boolean showUm=SConCancel.getshowUpsellMessage();
            SConCancel.setshowUpsellMessage(true);
            
            List<String> fieldList = new List<String>();
            fieldList.add('TEST1');
            fieldList.add('TEST2');
            
            Boolean isfav=SVMXC.SCON_Cancelation.isFieldAvailable(fieldList,'TEST2');
            
            SConCancel.getSContEntlHisy();
            SConCancel.getSContractHeader();      
            SConCancel.Cancel();
            SConCancel.RevokeSContract();
            
            SConCancel.getUserLocaleKey();
            SConCancel.getUserID();
            SConCancel.getUserOrgID();              
        
            SconObject.SVMXC__Active__c = true;
            update SconObject;
            system.assert(SconObject.SVMXC__Active__c == true);
            SVMXC.SCON_Cancelation SConCancel2 = new SVMXC.SCON_Cancelation(SCONStdController);
    
            test.stoptest();
        }
        catch(Exception ex)
        {   }
    }
}