@isTest
Private class SCON_Renewal_UT{
    private static SVMXC.SCON_Renewal SConRenew, SconRenew2;
    private static Account account;
    private static Contact contact ;
    private static Case case1, case2;
    private static Product2  prodSCont1,prodSCont2,prodSCont3, prodSCont4, prodSContActive,prodSContActive1,prod;
    private static SVMXC__Site__c Location1, Location2;
    private static SVMXC__Service_Contract__c SconObject, SconObject4, SCont3,SCont4; 
    private static SVMXC__Service_Contract_Products__c sconChildProdObj;                    
    private static SVMXC__Service_Contract_Services__c sconChildServ ;
    private static SVMXC__Service_Contract_Contacts__c sconChildContact;
    private static SVMXC__Service_Contract_Sites__c sconChildSites;
    //Objects for Setting Value
    private static SVMXC__ServiceMax_Config_Data__c setngValAContHeader = new SVMXC__ServiceMax_Config_Data__c();
    private static SVMXC__ServiceMax_Config_Data__c setngValAContwoProdCov =new SVMXC__ServiceMax_Config_Data__c();
    private static SVMXC__ServiceMax_Config_Data__c setngValAContwoSiteCov =new SVMXC__ServiceMax_Config_Data__c();
    private static SVMXC__ServiceMax_Config_Data__c setngValAContwoSvrCov =new SVMXC__ServiceMax_Config_Data__c();
    private static SVMXC__ServiceMax_Config_Data__c setngValAContwoContCov =new SVMXC__ServiceMax_Config_Data__c();
    private static SVMXC__ServiceMax_Processes__c setngSContHeader = new SVMXC__ServiceMax_Processes__c();
    private static SVMXC__ServiceMax_Processes__c setngAContwoProdCov = new SVMXC__ServiceMax_Processes__c();
    private static SVMXC__ServiceMax_Processes__c setngAContwoSiteCov =new SVMXC__ServiceMax_Processes__c();
    private static SVMXC__ServiceMax_Processes__c setngAContwoSvrCov =new SVMXC__ServiceMax_Processes__c();
    private static SVMXC__ServiceMax_Processes__c setngAContwoContactCovnew =new SVMXC__ServiceMax_Processes__c();
    //SconObject
    private static List<SVMXC__Service_Contract_Products__c> scontprodArray = new List<SVMXC__Service_Contract_Products__c>();
    private static List<SVMXC__Service_Contract_Services__c> scontsvrArray = new List<SVMXC__Service_Contract_Services__c>();
    private static List<SVMXC__Service_Contract_Contacts__c> scontcontArray = new List<SVMXC__Service_Contract_Contacts__c>();
    private static List<SVMXC__Service_Contract_Sites__c> scontsitesArray = new List<SVMXC__Service_Contract_Sites__c>();
    private static SVMXC__Installed_Product__c IBObject ;
    private static SVMXC__Site__c sconLocation, sconLocation1;
    private static SVMXC__Service_Level__c sconSLA = new SVMXC__Service_Level__c();
    private static SVMXC__Service__c sconSER = new SVMXC__Service__c();    
    private static SVMXC__ServiceMax_List__c svmxList, svmxList1; 
    //Variables for Configuration Setting Data
    private static List<RecordType> rtSVMX_Processes = new List<RecordType>();
    private static List<RecordType> rtSVMX_ConfData = new List<RecordType>();
    private static RecordType settingDefRecType = new RecordType();
    //Objects for Profile Object    
    private static SVMXC__ServiceMax_Config_Data__c configProfile;
    //Objects for Module, Submodule
    private static SVMXC__ServiceMax_Processes__c module;
    private static SVMXC__ServiceMax_Processes__c subModule;   
    
    static testMethod void SCON_RenewalContract_Test(){
    try{
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
        
        prod = new Product2(
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
                
        sconLocation1 = new SVMXC__Site__c(
            SVMXC__Zip__c ='909090901',
            SVMXC__Street__c ='ABCD',
            SVMXC__State__c ='ABCD',
            SVMXC__Country__c ='ABCD',
            SVMXC__City__c ='ABCD',
            SVMXC__Account__c=account.Id
        );
        insert sconLocation1;
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
            SVMXC__Company__c = account.Id
        );
        insert IBObject;
         
        SconObject = new SVMXC__Service_Contract__c( 
            SVMXC__Company__c=account.Id,
            SVMXC__Activation_Notes__c= null,
            SVMXC__Active__c=false,
            SVMXC__All_Contacts_Covered__c=true,
            SVMXC__All_Products_Covered__c=true,
            SVMXC__All_Services_Covered__c=false,
            SVMXC__All_Sites_Covered__c=true,
            SVMXC__Billing_Schedule__c='Annual',//Semi Annual,Quarterly,Monthly,Full Upfront,other;
            SVMXC__Cancelation_Notes__c=null,
            SVMXC__Contact__c=Contact.Id,
            SVMXC__Renewal_Date__c=null,
            SVMXC__Renewal_Notes__c=null,
            SVMXC__Renewal_Number__c=null,
            SVMXC__Renewed_From__c=null,
            SVMXC__Sales_Rep__c=null,
            SVMXC__Service_Contract_Notes__c='',
            SVMXC__Service_Level__c=sconSLA.id,
            SVMXC__Start_Date__c=null,
            SVMXC__End_Date__c=null
        );
        insert SconObject;
        
        SconObject4 = new SVMXC__Service_Contract__c( 
            Name='ZZ1',
            SVMXC__Company__c=account.Id,
            SVMXC__Activation_Notes__c= 'Its with Unit Test Case',
            SVMXC__Active__c=true,
            SVMXC__All_Contacts_Covered__c=true,
            SVMXC__All_Products_Covered__c=true,
            SVMXC__All_Services_Covered__c=false,
            SVMXC__All_Sites_Covered__c=true,
            SVMXC__Billing_Schedule__c='Annual',//Semi Annual,Quarterly,Monthly,Full Upfront,other;
            SVMXC__Cancelation_Notes__c=null,
            SVMXC__Contact__c=Contact.Id,
            SVMXC__End_Date__c=System.today(),//5/12/2009,
            SVMXC__Renewal_Date__c=null,
            SVMXC__Renewal_Notes__c=null,
            SVMXC__Renewal_Number__c=null,
            SVMXC__Renewed_From__c=null,
            SVMXC__Sales_Rep__c=null,
            SVMXC__Service_Contract_Notes__c='Its for Test method',
            SVMXC__Service_Level__c=sconSLA.id,
            SVMXC__Start_Date__c=System.today()
        );
        insert SconObject4;
        
        SCont3 = new SVMXC__Service_Contract__c(
            SVMXC__Active__c=true,
            SVMXC__Activation_Notes__c='Test',
            SVMXC__Cancelation_Notes__c='Test'      
        );
        insert SCont3;      
            
        svmxList = new SVMXC__ServiceMax_List__c (
            SVMXC__Action__c = 'Increase',
            SVMXC__Activate_Contract_Upon_Renewal__c=true,
            SVMXC__Activity_Type__c='Calibration',
            SVMXC__Additional_Information__c='Its for Test Case',
            SVMXC__Billable__c=true,
            SVMXC__Close_Line__c=true,
            SVMXC__Close_Request__c=true,
            SVMXC__Consumed_From_Location__c=sconLocation.id,
            SVMXC__Copy_Covered_Locations__c=true,
            SVMXC__Copy_Covered_Products__c=true,
            SVMXC__Copy_Entitled_Contacts__c=true,
            SVMXC__Copy_Included_Services__c=true,
            SVMXC__Date_Required__c=System.today(),
            SVMXC__Product__c=prod.Id,
            SVMXC__Select__c=true,
            SVMXC__Destination_Location__c=sconLocation1.id
        );
        insert svmxList;
                                            
        svmxList1 = new SVMXC__ServiceMax_List__c (
            SVMXC__Action__c = 'Increase',
            SVMXC__Activate_Contract_Upon_Renewal__c=true,
            SVMXC__Activity_Type__c='Calibration',
            SVMXC__Additional_Information__c='Its for Test Case',
            SVMXC__Billable__c=true,
            SVMXC__Close_Line__c=true,
            SVMXC__Close_Request__c=true,
            SVMXC__Consumed_From_Location__c=sconLocation.id,
            SVMXC__Copy_Covered_Locations__c=true,
            SVMXC__Copy_Covered_Products__c=true,
            SVMXC__Copy_Entitled_Contacts__c=true,
            SVMXC__Copy_Included_Services__c=true,
            SVMXC__Date_Required__c=System.today(),
            SVMXC__Product__c=prod.Id,
            SVMXC__Select__c=true,
            SVMXC__Destination_Location__c=sconLocation1.id
        );
        insert svmxList1;
        
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
            SVMXC__Service__c = sconSER.Id,
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
        PageReference pageRef1 = new PageReference('Page.SVMXC.SCON_Renewal');
        pageRef1.getParameters().put('id',SconObject.Id);
        Test.setCurrentPageReference(pageRef1); 
        
        SConRenew = new SVMXC.SCON_Renewal(SCONStdController);
        
        //Scenario to qualify Cancel()& RenewalContract() methods
        PageReference cancl = SConRenew.Cancel();
        PageReference  rc = SConRenew.RenewSContract();
        
        //Scenario to qualify regular set & get methods
        SVMXC__Service_Contract__c sconObj = SConRenew.getSContractHeader() ; 

        SConRenew.getHLPURL();
        String  strTag001 = SConRenew.getTAG001();
        String  strTag002 = SConRenew.getTAG002();
        String  strTag004 = SConRenew.getTAG004();
        String  strTag005=  SConRenew.getTAG005();
        String  strTag006 = SConRenew.getTAG006();
        String  strTag007=  SConRenew.getTAG007();
        String  strTag008 = SConRenew.getTAG008();
        String  strTag009 = SConRenew.getTAG009();
        String  strTag010 = SConRenew.getTAG010();
        String  strTag011 = SConRenew.getTAG011();
        String  strTag012 = SConRenew.getTAG012();
        String  strTag013 = SConRenew.getTAG013();
        String  strTag014 = SConRenew.getTAG014();
        String  strTag015 = SConRenew.getTAG015();
        String  strTag017 = SConRenew.getTAG017();
        String  strTag018 = SConRenew.getTAG018();
        //SConRenew.svmxTagList.clear();
        
        system.assert(SConRenew.getHLPURL()!=null,'HLPURL Fails');
        system.assert(SConRenew.getTAG001()!=null,'TAG001 Fails');
        system.assert(SConRenew.getTAG002()!=null,'TAG002 Fails');
        system.assert(SConRenew.getTAG004()!=null,'TAG004 Fails');
        system.assert(SConRenew.getTAG005()!=null,'TAG005 Fails');
        system.assert(SConRenew.getTAG006()!=null,'TAG006 Fails');
        system.assert(SConRenew.getTAG007()!=null,'TAG007 Fails');
        system.assert(SConRenew.getTAG008()!=null,'TAG008 Fails');
        system.assert(SConRenew.getTAG009()!=null,'TAG009 Fails');
        system.assert(SConRenew.getTAG010()!=null,'TAG010 Fails');
        system.assert(SConRenew.getTAG011()!=null,'TAG011 Fails');
        system.assert(SConRenew.getTAG012()!=null,'TAG012 Fails');
        system.assert(SConRenew.getTAG013()!=null,'TAG013 Fails');
        system.assert(SConRenew.getTAG014()!=null,'TAG014 Fails');
        system.assert(SConRenew.getTAG015()!=null,'TAG015 Fails');
        system.assert(SConRenew.getTAG017()!=null,'TAG017 Fails');
        system.assert(SConRenew.getTAG018()!=null,'TAG018 Fails');
 
        //Scenario to qualify the method : ValidateAllSettings()
        String ObjName=''; 
        String SOQLStatement=''; 
        
        ObjName = 'SVMXC__ServiceMax_Processes__c';
        SOQLStatement = 'SELECT Id, Name FROM RecordType WHERE SobjectType =\''+ ObjName+ '\' ';
        rtSVMX_Processes = Database.query(SOQLStatement);
        
            
        ObjName= 'SVMXC__ServiceMax_Config_Data__c'; 
        SOQLStatement = 'SELECT Id, Name FROM RecordType WHERE SobjectType =\''+ ObjName+ '\' ';
        rtSVMX_ConfData = Database.query(SOQLStatement);
        
        String Module_ID_c = 'SCON';
        String Sub_Module_ID_c = 'SCON002';
        
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
        
        for(RecordType rt : rtSVMX_Processes){ //Loop to take a record type at a time
            // Retrieve Sub Module Record
            if(rt.Name == 'Settings'){
                settingDefRecType = rt;
            } 
        }//for  
        String SET001 = 'SET001'; 
        String SET002 = 'SET002';
        String SET003 = 'SET003';
        String SET004 = 'SET004';
        String SET005 = 'SET005';
        String SET006 = 'SET006';
               
        setngSContHeader = [Select Id ,Name from SVMXC__ServiceMax_Processes__c where 
            RecordTypeId =:SettingDefRecType.Id 
            and SVMXC__Submodule__c = :subModule.Id
            and SVMXC__SettingID__c = :SET001 LIMIT 1];      
              
        setngAContwoSvrCov = [Select Id ,Name from SVMXC__ServiceMax_Processes__c where 
            RecordTypeId =:SettingDefRecType.Id 
            and SVMXC__Submodule__c = :subModule.Id
            and SVMXC__SettingID__c = :SET003 LIMIT 1];
           
        setngAContwoSiteCov = [Select Id ,Name from SVMXC__ServiceMax_Processes__c where 
            RecordTypeId =:SettingDefRecType.Id 
            and SVMXC__Submodule__c = :subModule.Id
            and SVMXC__SettingID__c = :SET004 LIMIT 1];
        
        setngAContwoContactCovnew = [Select Id ,Name from SVMXC__ServiceMax_Processes__c where 
            RecordTypeId =:SettingDefRecType.Id 
            and SVMXC__Submodule__c = :subModule.Id
            and SVMXC__SettingID__c = :SET005 LIMIT 1];
            
        for(RecordType rt : rtSVMX_ConfData){ //Loop to take a record type at a time
            if(rt.Name == 'Setting Value'){
                setngValAContHeader= [select Id,SVMXC__Internal_Value__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId= :rt.Id and SVMXC__Setting_ID__c= :setngSContHeader.Id limit 1];  

                setngValAContwoSvrCov= [select Id,SVMXC__Internal_Value__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId =: rt.Id and SVMXC__Setting_ID__c =:setngAContwoSvrCov.Id limit 1];  
                                                
                setngValAContwoSiteCov= [select Id,SVMXC__Internal_Value__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId =: rt.Id and SVMXC__Setting_ID__c =:setngAContwoSiteCov.Id limit 1];

                setngValAContwoContCov= [select Id,SVMXC__Internal_Value__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId=: rt.Id and SVMXC__Setting_ID__c=:setngAContwoContactCovnew.Id limit 1];
     
            }//if                                               
        }//for
        
        SConRenew.AddToErrorsList('Error');
        system.assert(SConRenew.getErrorsList()!=null,'getErrorsList fails');
        SConRenew.ValidateAllSettings();
        SConRenew.ValidateAllChildCvrage();
        
        SConRenew.SCONTHeaderFieldMapp();
        SConRenew.SCONTChildFieldMapp();
            
        Boolean IsDisp = SConRenew.getIstoDisplay();
        SConRenew.setIstoDisplay(false);
        
        Boolean IsDisp1 = SConRenew.getIstoDisplay();
        SConRenew.setIstoDisplay(true);
                
        Boolean dc= SConRenew.getDisplayContinue();
        SConRenew.setDisplayContinue(true);
            
        Boolean dc1= SConRenew.getDisplayContinue();
        SConRenew.setDisplayContinue(false);
        SConRenew.getSMaxList();
        SConRenew.setSMaxList(svmxList);
            
        Boolean IsAC=SConRenew.getIsActivatedContract();
        SConRenew.setIsActivatedContract(false);
            
        Boolean shupm = SConRenew.getshowUpsellMessage();
        SConRenew.setshowUpsellMessage(false);
    
        Boolean showDB=SConRenew.getshowDetailBlock();
        SConRenew.setshowDetailBlock(false);
        SConRenew.getSMaxListHeader();
        SConRenew.getContractProducts();
        SConRenew.getNewSContHeader();
        SConRenew.setNewSContHeader(SconObject4);
        SConRenew.SCONTHeaderFieldMapp();
        SConRenew.SCONTChildFieldMapp();
        
        SCont3.SVMXC__Activation_Notes__c='Its for Test method';
        SCont3.SVMXC__Cancelation_Notes__c='Its for Test method';
        update SCont3; 

        SConRenew.SCONTChildFieldMapp();
        SConRenew.getNewSContHeader();
        SConRenew.setNewSContHeader(SconObject);
        
        //SconObject
        PageReference  renew= SConRenew.RenewSContract();   
        SConRenew.SCONTHeaderFieldMapp();
        SConRenew.SCONTChildFieldMapp();
        test.stoptest();
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }
}