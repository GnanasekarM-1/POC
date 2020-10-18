@isTest(SeeAllData=true)
private class IPRD_CoverageByCounters_SContractUT {

    static testMethod void IPRD_CoverageByCounters_SContractUnitTest() {
        
        SVMXC.EVER_CaseEntitlement ControllerObj1,ControllerObj2,ControllerObj3,ControllerObj4;
        Account account;
        Contact contact; 
        Case case1;
        Product2 prod1,prod2,prod4;
        SVMXC__Installed_Product__c IB0,IB1,IB2,IB4 ;
        
        RecordType Rtype = new RecordType();
        RecordType Rtypedef = new RecordType();
        RecordType CountRecTypeUT = new RecordType();
        RecordType ExpressionsUT = new RecordType();
        Rtype = [select Id from RecordType where Name=:'SVMX Rule' and SobjectType=:'SVMXC__ServiceMax_Processes__c'];
        Rtypedef = [select Id from RecordType where Name=:'Definition' and SobjectType=:'SVMXC__Counter_Details__c'];
        CountRecTypeUT = [select Id from RecordType where Name=:'Coverage' and SobjectType=:'SVMXC__Counter_Details__c'];
        ExpressionsUT = [select Id from RecordType where Name=:'Expressions' and SobjectType=:'SVMXC__ServiceMax_Config_Data__c'];
        
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
        
        List<Product2> productList=new List<Product2>();         
        prod1 = new Product2(Name = 'Prod1', 
                                            ProductCode = '1234-1', 
                                            Family = 'Accessory',
                                            SVMXC__Product_Line__c = 'Laptop', 
                                            SVMXC__Inherit_Parent_Warranty__c =false 
                                            );
        productList.add(prod1);
        
        prod2 = new Product2(Name = 'Prod2', 
                                            ProductCode = '1234-2', 
                                            Family = 'Accessory',
                                            SVMXC__Product_Line__c = 'Laptop', 
                                            SVMXC__Inherit_Parent_Warranty__c =false 
                                            );
        productList.add(prod2);
        
        prod4 = new Product2(Name = 'Prod4', 
                                            ProductCode = '1234-4', 
                                            Family = 'Accessory',
                                            SVMXC__Product_Line__c = 'Network', 
                                            SVMXC__Inherit_Parent_Warranty__c =false 
                                            );
        productList.add(prod4);
        insert productList;
        
        IB0 = new SVMXC__Installed_Product__c(
                                            Name = 'IB0',
                                            SVMXC__Product__c = prod1.Id, 
                                            SVMXC__Company__c = account.Id  , 
                                            SVMXC__Contact__c =contact.Id,
                                            SVMXC__Status__c = 'Installed',//'Shipped',
                                            SVMXC__Serial_Lot_Number__c = 'Test2', 
                                            SVMXC__Date_Installed__c = System.today(), 
                                            SVMXC__Date_Shipped__c = System.today(),
                                            SVMXC__Country__c='United States'); 
        insert IB0;

        IB1 = new SVMXC__Installed_Product__c(
                                            Name = 'IB1',
                                            SVMXC__Product__c = prod1.Id, 
                                            SVMXC__Company__c = account.Id  , 
                                            SVMXC__Contact__c =contact.Id,
                                            SVMXC__Status__c = 'Installed', 
                                            SVMXC__Serial_Lot_Number__c = 'Test2', 
                                            SVMXC__Top_Level__c = IB0.Id, 
                                            SVMXC__Parent__c = IB0.Id , 
                                            SVMXC__Date_Installed__c = System.today(), 
                                            SVMXC__Date_Shipped__c = System.today(),
                                            SVMXC__Country__c='United States'); 
        insert IB1;

        SVMXC__Service_Contract__c Current_SC= new SVMXC__Service_Contract__c(
                    Name ='Current_SC',
                    SVMXC__Start_Date__c    = System.Today(),               
                    SVMXC__End_Date__c      = System.Today()+1,             
                    SVMXC__Contact__c       = contact.Id,
                    SVMXC__Company__c       = account.Id,
                    SVMXC__Active__c        = true);
        insert Current_SC;
        
        SVMXC__Service_Contract_Products__c scpCurrentIB1 =  new SVMXC__Service_Contract_Products__c(
                        SVMXC__Start_Date__c = System.Today()-2, 
                        SVMXC__End_Date__c = System.Today()+2,  
                        SVMXC__Service_Contract__c =Current_SC.Id, 
                        SVMXC__Installed_Product__c =IB1.Id); 
        insert scpCurrentIB1;
        
        SVMXC__Service_Contract_Products__c scpCurrentIB2 =  new SVMXC__Service_Contract_Products__c(
                        SVMXC__Start_Date__c = System.Today()-2, 
                        SVMXC__End_Date__c = System.Today()+2,  
                        SVMXC__Service_Contract__c =Current_SC.Id, 
                        SVMXC__Installed_Product__c =IB1.Id); 
        insert scpCurrentIB2;
        
        SVMXC__Service_Template__c Warrnty = new SVMXC__Service_Template__c();
        Warrnty  =new SVMXC__Service_Template__c(
                                            SVMXC__Walk_in_Allowed__c =false,                                                       
                                            SVMXC__Unit_of_Time__c = '100', 
                                            SVMXC__Unit_of_Time_Material__c= 'Days', 
                                            SVMXC__Unit_of_Time_Expenses__c='Months', 
                                            SVMXC__Transferable__c=false, 
                                            SVMXC__Time_Covered__c=100, 
                                            SVMXC__Template_Type__c='Warranty', 
                                            SVMXC__Shipment_Allowed__c=false, 
                                            SVMXC__RMA_Required__c=true, 
                                            SVMXC__Onsite_Repair__c=true, 
                                            SVMXC__Material_Covered__c=100, 
                                            SVMXC__Loaner_Provided__c=false, 
                                            SVMXC__Invoice_Required__c=false, 
                                            SVMXC__Expenses_Covered__c=100, 
                                            SVMXC__Duration_of_Time_Coverage__c=100, 
                                            SVMXC__Duration_of_Material_Coverage__c=365, 
                                            SVMXC__Duration_of_Expenses__c=52, 
                                            SVMXC__Coverage_Effective_From__c='Install Date', 
                                            SVMXC__All_Services_Covered__c=false, 
                                            SVMXC__All_Products_Covered__c=false, 
                                            Name ='Template1' 
                                            );
        insert Warrnty;

        SVMXC__ServiceMax_Processes__c CounterRuleListUtobj = new SVMXC__ServiceMax_Processes__c();
        CounterRuleListUtobj.SVMXC__ProcessID__c='PROCESS11';
        CounterRuleListUtobj.SVMXC__SettingId__c = 'PROCESS11';
        CounterRuleListUtobj.SVMXC__MapID__c='PROCESS11';
        CounterRuleListUtobj.SVMXC__Name__c = 'PROCESS22';
        CounterRuleListUtobj.RecordTypeId=Rtype.Id;
        CounterRuleListUtobj.SVMXC__Advance_Expression__c='1 AND 2';
        CounterRuleListUtobj.SVMXC__Description__c='Test Description';
        CounterRuleListUtobj.SVMXC__Select__c=true;
        CounterRuleListUtobj.SVMXC__Rule_Type__c='Counters';
        CounterRuleListUtobj.SVMXC__Select__c=true;
        CounterRuleListUtobj.SVMXC__Name__c='SVMX RULE';
        insert CounterRuleListUtobj;
        
        SVMXC__ServiceMax_Config_Data__c CnfiglstUTobj = new SVMXC__ServiceMax_Config_Data__c();
        CnfiglstUTobj.RecordTypeId = ExpressionsUT.Id;
        CnfiglstUTobj.SVMXC__Sequence__c = 1;
        CnfiglstUTobj.SVMXC__Operator__c = 'Test Operator';
        CnfiglstUTobj.SVMXC__Operand__c='AND';
        CnfiglstUTobj.SVMXC__Object_Name__c='SVMXC__ServiceMax_Config_Data__c';
        CnfiglstUTobj.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__Expression_Rule__c';
        CnfiglstUTobj.SVMXC__Field_Name__c='Name';
        CnfiglstUTobj.SVMXC__FKey_Name_Field__c='';
        CnfiglstUTobj.SVMXC__Expression_Type__c='IPRD_Counters';
        CnfiglstUTobj.SVMXC__Expression_Rule__c=CounterRuleListUtobj.Id;
        insert CnfiglstUTobj;
        
        SVMXC__ServiceMax_Config_Data__c CnfiglstUTobj1 = new SVMXC__ServiceMax_Config_Data__c();
        CnfiglstUTobj1.RecordTypeId = ExpressionsUT.Id;
        CnfiglstUTobj1.SVMXC__Sequence__c = 1.0;
        CnfiglstUTobj1.SVMXC__Operator__c = 'eq';
        CnfiglstUTobj1.SVMXC__Display_Type__c = 'DATETIME';
        CnfiglstUTobj1.SVMXC__Operand__c = 'SVMX.NOW';
        CnfiglstUTobj1.SVMXC__Object_Name__c = '';
        CnfiglstUTobj1.SVMXC__Lookup_Field_API_Name__c = '';
        CnfiglstUTobj1.SVMXC__Field_Name__c = 'Name';
        CnfiglstUTobj1.SVMXC__FKey_Name_Field__c = '';
        CnfiglstUTobj1.SVMXC__Expression_Type__c = 'IPRD_Counters';
        CnfiglstUTobj1.SVMXC__Expression_Rule__c = CounterRuleListUtobj.Id;
        insert CnfiglstUTobj1;
        
        SVMXC__Counter_Details__c CounterRecListUt = new SVMXC__Counter_Details__c();
        CounterRecListUt.RecordTypeID = CountRecTypeUT.Id;
        CounterRecListUt.SVMXC__Counter_Name__c = 'Test';
        //CounterRecListUt.SVMXC__Counter_Definition__c = CounterDefinationListUTobj.Id;
        CounterRecListUt.SVMXC__Counter_Reading__c = 51;
        CounterRecListUt.SVMXC__Counter_Type__c = 'Counter Test Type';
        CounterRecListUt.SVMXC__Grows_Reduces_By__c=1;
        CounterRecListUt.SVMXC__Min_Value__c = 50;
        CounterRecListUt.SVMXC__Max_Value__c = 100;
        CounterRecListUt.SVMXC__Active__c = true;
        CounterRecListUt.SVMXC__Select__c = true;
        CounterRecListUt.SVMXC__Counter_Rule__c = CounterRuleListUtobj.Id;     
        insert CounterRecListUt;
        
        SVMXC__Counter_Details__c CounterDefinationListUTobj = new SVMXC__Counter_Details__c();
        CounterDefinationListUTobj.RecordTypeID=Rtypedef.Id;
        CounterDefinationListUTobj.SVMXC__Counter_Name__c='Test Counter Name';
        CounterDefinationListUTobj.SVMXC__Counter_Definition__c = CounterRecListUt.Id;
        CounterDefinationListUTobj.SVMXC__Counter_Reading__c = 51;
        CounterDefinationListUTobj.SVMXC__Counter_Rule__c =CounterRuleListUtobj.Id;
        CounterDefinationListUTobj.SVMXC__Counter_Type__c = 'Counter Test Type';
        CounterDefinationListUTobj.SVMXC__Grows_Reduces_By__c =1;
        CounterDefinationListUTobj.SVMXC__Min_Value__c =50;
        CounterDefinationListUTobj.SVMXC__Max_Value__c =100;
        CounterDefinationListUTobj.SVMXC__Active__c = true;
        CounterDefinationListUTobj.SVMXC__Select__c = true;
        insert CounterDefinationListUTobj;
        
        SVMXC__Counter_Details__c Cdetails = new SVMXC__Counter_Details__c();
        Cdetails.RecordTypeID=CountRecTypeUT.Id;
        Cdetails.SVMXC__Installed_Product__c = IB1.Id;
        //Cdetails.SVMXC__Service_Maintenance_Contract__c,
        Cdetails.SVMXC__Covered_Products__c = scpCurrentIB1.Id;
        Cdetails.SVMXC__Product__c=prod1.Id;
        Cdetails.SVMXC__Counter_Name__c='TestCounter1234';
        Cdetails.SVMXC__Coverage_Limit__c = 77.0;
        Cdetails.SVMXC__Coverage_Starts_At__c=10.0;
        Cdetails.SVMXC__Counters_Covered__c=6.0;
        Cdetails.SVMXC__Counter_Definition__c = CounterRecListUt.Id;
        Cdetails.SVMXC__Counter_Reading__c = 20.0;
        Cdetails.SVMXC__Counter_Type__c='Increasing';
        Cdetails.SVMXC__Grows_Reduces_By__c = 5.0;
        Cdetails.SVMXC__Min_Value__c = 20.0;
        Cdetails.SVMXC__Max_Value__c = 100.0;
        Cdetails.SVMXC__Active__c=true;
        Cdetails.SVMXC__Select__c=true;
        Cdetails.SVMXC__Counter_Rule__c = CounterRuleListUtobj.Id;
        insert Cdetails;
        test.starttest();
        system.assertEquals(System.currentPageReference().getParameters().get('PId'),null);
        System.currentPageReference().getParameters().put('PId',Current_SC.Id); 
        system.assertNotEquals(System.currentPageReference().getParameters().get('PId'),null);
        SVMXC.IPRD_CoverageByCounters_SContract CbyCounter = new SVMXC.IPRD_CoverageByCounters_SContract();
        
        system.assertNotEquals(CbyCounter.TempCnfiglst,null);
        CbyCounter.getDisbleSaveBttn();
        CbyCounter.setDisbleSaveBttn(true);
        system.assertNotEquals(CbyCounter.getDisbleSaveBttn(),false);
        CbyCounter.getShowPanel();
        CbyCounter.setShowPanel(true);
        CbyCounter.getWrapCounterList();
        CbyCounter.getCounterRecList();
        CbyCounter.getCounterCvrgList();
        CbyCounter.getSrvcContract();
        CbyCounter.SVMX_SaveCounters();
        CbyCounter.SVMX_Cancel();
        SVMXC.IPRD_CoverageByCounters_SContract.WrapCovrgCounter wrapcovcount = new SVMXC.IPRD_CoverageByCounters_SContract.WrapCovrgCounter(CounterDefinationListUTobj,scpCurrentIB2,'Prod2');
        wrapcovcount.getappProd();
        wrapcovcount.getCounter();
        wrapcovcount.getProdName();
        wrapcovcount.setProdName('Prod1');
        system.assertNotEquals(wrapcovcount.getProdName(),null);

        CbyCounter.getTAG001();
        CbyCounter.getTAG002();
        CbyCounter.getTAG003();
        CbyCounter.getTAG004();
        CbyCounter.getTAG005();
        CbyCounter.getTAG006();
        CbyCounter.getTAG007();
        CbyCounter.getTAG008();
        CbyCounter.getTAG009();
        CbyCounter.getTAG010();
        CbyCounter.getTAG011();
        CbyCounter.getTAG012();
        CbyCounter.getTAG013();
        CbyCounter.getTAG014();
        CbyCounter.getTAG015();
        CbyCounter.getTAG016();
        CbyCounter.getTAG017();
        CbyCounter.getTAG018();
        CbyCounter.getTAG019();
        CbyCounter.getTAG020();
        //CbyCounter.svmxTagList.clear();
        CbyCounter.getTAG001();
        CbyCounter.getTAG002();
        CbyCounter.getTAG003();
        CbyCounter.getTAG004();
        CbyCounter.getTAG005();
        CbyCounter.getTAG006();
        CbyCounter.getTAG007();
        CbyCounter.getTAG008();
        CbyCounter.getTAG009();
        CbyCounter.getTAG010();
        CbyCounter.getTAG011();
        CbyCounter.getTAG012();
        CbyCounter.getTAG013();
        CbyCounter.getTAG014();
        CbyCounter.getTAG015();
        CbyCounter.getTAG016();
        CbyCounter.getTAG017();
        CbyCounter.getTAG018();
        CbyCounter.getTAG019();
        CbyCounter.getTAG020();
        test.stoptest();
    }
}