@isTest (SeeAllData=true)
Private class EVER_CaseEntitlement_UT
 {
    static testMethod void EVER_CaseEntitlement_Test1()
    {
        
        Account account = new Account( Name ='Account',ShippingStreet='ABC',ShippingCity='PQR ',ShippingState = 'XYZ',ShippingPostalCode='111',ShippingCountry='XYZ',BillingStreet='ABC',BillingCity='PQR ',BillingState = 'XYZ',BillingPostalCode='111',BillingCountry='XYZ'); 
        insert account;
        
        Contact contact = new Contact(LastName='Last',AccountId =account.Id,Email='svmxmailfortest@servicemax.com');
        insert contact;
        
        SVMXC__Service_Level__c SLA_TERM = new SVMXC__Service_Level__c (Name = 'SLA_TERM1',SVMXC__Active__c = true);
        insert SLA_TERM ;           
        
        SVMXC__Service_Contract__c Current_SC= new SVMXC__Service_Contract__c(Name ='Current_SC',SVMXC__Service_Level__c = SLA_TERM.Id,SVMXC__Start_Date__c  = System.Today(),SVMXC__End_Date__c = System.Today()+1, SVMXC__Contact__c = contact.Id,SVMXC__Company__c = account.Id,SVMXC__Active__c = true);
        insert Current_SC;  
        
        SVMXC__Service_Contract__c Current_SC1 = new SVMXC__Service_Contract__c(Name ='Current_SC1',SVMXC__Service_Level__c = SLA_TERM.Id,SVMXC__Start_Date__c    = System.Today(),SVMXC__End_Date__c = System.Today()+1, SVMXC__Contact__c = contact.Id,SVMXC__Company__c = account.Id,SVMXC__Active__c = true);
        insert Current_SC1;
        
        SVMXC__Service__c objService = new SVMXC__Service__c();
        objService.Name = 'service';
        objService.SVMXC__Active__c = true;
        objService.SVMXC__Tracked_On__c = 'Work Order';
        insert objService;
        
        
        SVMXC__Service_Contract_Services__c isObj = new SVMXC__Service_Contract_Services__c();
        isObj.SVMXC__Service_Contract__c = Current_SC.Id;
        isObj.SVMXC__Service__c = objService.Id;
        insert isObj;
        
        Case case1 = new Case(Status ='New', SVMXC__Service_Contract__c = Current_SC.Id, Priority = 'Medium', Origin = 'Email', ContactId =contact.Id,AccountId=account.Id ); 
        insert case1;
        
        SVMXC__Site__c objLoc = new SVMXC__Site__c();
        objLoc.SVMXC__City__c = 'Bangalore';
        insert objLoc;
        
        Product2 prod1 = new Product2(Name = 'Prod1',ProductCode = '1234-1', Family = 'Accessory',SVMXC__Product_Line__c = 'Laptop', SVMXC__Inherit_Parent_Warranty__c =false );
        insert prod1;
        
        SVMXC__Installed_Product__c IB0 = new SVMXC__Installed_Product__c(Name = 'IB0',SVMXC__Product__c = prod1.Id, SVMXC__Company__c = account.Id  , SVMXC__Contact__c =contact.Id,SVMXC__Status__c = 'Installed',SVMXC__Serial_Lot_Number__c = 'Test2', SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today(),SVMXC__Country__c='United States'); 
        insert IB0;
        
        SVMXC__Installed_Product__c IB1 = new SVMXC__Installed_Product__c(Name = 'IB1',SVMXC__Company__c = account.Id , SVMXC__Contact__c =contact.Id, SVMXC__Status__c = 'Installed',SVMXC__Serial_Lot_Number__c = 'Test2', SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today(),SVMXC__Country__c='United States'); 
        insert IB1;
        
        SVMXC__Service_Template__c WT1  =new SVMXC__Service_Template__c(SVMXC__Walk_in_Allowed__c =false,SVMXC__Unit_of_Time__c = '100', SVMXC__Unit_of_Time_Material__c= 'Days', SVMXC__Unit_of_Time_Expenses__c='Months', SVMXC__Transferable__c=false, SVMXC__Time_Covered__c=100, SVMXC__Template_Type__c='Warranty', SVMXC__Shipment_Allowed__c=false, SVMXC__RMA_Required__c=true, SVMXC__Onsite_Repair__c=true,SVMXC__Material_Covered__c=100,  SVMXC__Loaner_Provided__c=false, SVMXC__Invoice_Required__c=false, SVMXC__Expenses_Covered__c=100, SVMXC__Duration_of_Time_Coverage__c=100, SVMXC__Duration_of_Material_Coverage__c=365, SVMXC__Duration_of_Expenses__c=52, SVMXC__Coverage_Effective_From__c='Install Date', SVMXC__All_Services_Covered__c=false, SVMXC__All_Products_Covered__c=false, Name ='Template1');
        insert WT1;
        
        list<SVMXC__Warranty__c> wl = new list<SVMXC__Warranty__c>();
        SVMXC__Warranty__c WarrantyforIB1 = new SVMXC__Warranty__c (SVMXC__Select__c = true, SVMXC__Start_Date__c= System.Today()-1,SVMXC__Service_Template__c   = WT1.Id,SVMXC__Installed_Product__c  =IB1.Id,SVMXC__End_Date__c =System.Today()+1 );
        insert WarrantyforIB1; 
        wl.add(WarrantyforIB1);
        
        SVMXC__Warranty__c WarrantyforIB2 = new SVMXC__Warranty__c (SVMXC__Select__c = true, SVMXC__Start_Date__c= System.Today()-1,SVMXC__Service_Template__c   = WT1.Id,SVMXC__Installed_Product__c  =IB1.Id,SVMXC__End_Date__c =System.Today()+1 );
        insert WarrantyforIB2; 
        wl.add(WarrantyforIB2);
        
        SVMXC__Service_Order__c Workorder  = new SVMXC__Service_Order__c();
        Workorder.SVMXC__Company__c  = account.Id;
        Workorder.SVMXC__Contact__c = contact.Id;
        Workorder.SVMXC__Component__c = IB1.Id;  
        Workorder.SVMXC__Product__c = prod1.id;
        Workorder.SVMXC__Warranty__c  = WarrantyforIB1.id;
        Workorder.SVMXC__Service_Contract__c = Current_SC.id;
        Workorder.SVMXC__Site__c = objLoc.Id;
        insert Workorder;
        
        SVMXC__Service_Contract_Contacts__c entitledContact = new SVMXC__Service_Contract_Contacts__c();
        entitledContact.SVMXC__Contact__c = contact.Id;
        entitledContact.SVMXC__Service_Contract__c = Current_SC.id;
        insert entitledContact;
        
        SVMXC__Service_Contract_Sites__c  covLoc = new SVMXC__Service_Contract_Sites__c();
        covLoc.SVMXC__Service_Contract__c = Current_SC.Id;
        covLoc.SVMXC__Site__c = objLoc.Id;
        covLoc.SVMXC__SLA_Terms__c = SLA_TERM.Id;
        insert covLoc;
        
        SVMXC__Entitlement_History__c objHstry = new SVMXC__Entitlement_History__c();
        objHstry.SVMXC__Service_Order__c = Workorder.Id;
        objHstry.SVMXC__Service_Contract__c = Current_SC.id;
        objHstry.SVMXC__Entitled_By_Service__c = isObj.Id;
        objHstry.SVMXC__Inactive_Date__c = null;
        insert objHstry;
        
        List<Case> lstcsHdr = new List<Case>();
        lstcsHdr.add(case1);
        List<SVMXC__Service_Order__c> lstWOHdr = new List<SVMXC__Service_Order__c>();
        lstWOHdr.add(Workorder);
        System.currentPageReference().getParameters().put('cid', Workorder.Id);
        EVER_CaseEntitlement EverCaesEntlmt = new EVER_CaseEntitlement();
        EVER_CaseEntitlement.WrapperClass EntOpt = new EVER_CaseEntitlement.WrapperClass();
        EntOpt.Match_Contact = false;
        EverCaesEntlmt.getServiceContractData(null ,case1, EntOpt, '' ,2, date.today());
        
        EverCaesEntlmt.setApplicableEntitlementType('Account');
        EverCaesEntlmt.setSVMX_WarrResults(wl);
        EverCaesEntlmt.isValidData();
        EverCaesEntlmt.getSVMX_WarrResults();
        EverCaesEntlmt.PopulateSavedWarrSC();
        EverCaesEntlmt.getIsRendered();
        EverCaesEntlmt.setWOHdr(Workorder);
        EverCaesEntlmt.setCaseHdr(case1);
        EverCaesEntlmt.getEntitlementTypes();
        EverCaesEntlmt.isValidSearchCriteria();
        
        EverCaesEntlmt.SVMX_doCheckEntitlement();
        EverCaesEntlmt.strSelectedSCID = Current_SC.Id;
        EverCaesEntlmt.showMoreServices();
        EverCaesEntlmt.serviceSubmitcheck();
        
        isObj.SVMXC__Included_Units__c = 20;
        isObj.SVMXC__Consumed_Units__c = 14;
        update isObj;
        
        EverCaesEntlmt.SVMX_doCheckEntitlement();
        EverCaesEntlmt.strSelectedSCID = Current_SC.Id;
        EverCaesEntlmt.serviceSubmitcheck();
        
        
        isObj.SVMXC__Included_Units__c = 20;
        isObj.SVMXC__Consumed_Units__c = 24;
        update isObj;
        
        EverCaesEntlmt.SVMX_doCheckEntitlement();
        EverCaesEntlmt.strSelectedSCID = Current_SC.Id;
        
        EntOpt.Match_Contact = false;
        EntOpt.Match_Location = true;
        EverCaesEntlmt.SVMX_doCheckEntitlement();
        
        //EverCaesEntlmt.strSlectedService = 'None';
        //EverCaesEntlmt.serviceSubmitcheck();
        
        //EverCaesEntlmt.strSelectedSCID = Current_SC1.Id;
        //EverCaesEntlmt.serviceSubmit();
        
        
        EverCaesEntlmt.setApplicableEntitlementType('Product');
        EverCaesEntlmt.setWOHdr(Workorder);
        EverCaesEntlmt.setCaseHdr(case1);
        EverCaesEntlmt.getEntitlementTypes();
        EverCaesEntlmt.isValidSearchCriteria();
        EverCaesEntlmt.SVMX_doCheckEntitlement();
        EverCaesEntlmt.getUserLocaleKey();
        EverCaesEntlmt.getUserID();
        EverCaesEntlmt.getUserOrgID();
        EverCaesEntlmt.getIsServiceAvailable();
        EverCaesEntlmt.getIsServiceAvailableOnSave();
        EverCaesEntlmt.getisNotEntitled();
        EverCaesEntlmt.setisNotEntitled(true);
        EverCaesEntlmt.getlstIncludedServicesWrpr();
        //EverCaesEntlmt.getContactCoveredProducts(null, null);
        EverCaesEntlmt.CancelPopup();
        //
        
        //EverCaesEntlmt.serviceSubmitcheck();
        //EverCaesEntlmt.serviceSubmit();
        
        List<EVER_SCResults.IncludedServicesWrapper> lstobjWrpr = new List<EVER_SCResults.IncludedServicesWrapper>();
        EVER_SCResults.IncludedServicesWrapper objWrpr = new EVER_SCResults.IncludedServicesWrapper();
        lstobjWrpr.add(objWrpr);
        EverCaesEntlmt.setlstIncludedServicesWrpr(lstobjWrpr);
        EverCaesEntlmt.serviceSubmitNo();
        EverCaesEntlmt.SaveEntitlementNo();
        
        case1.SVMXC__Component__c = IB0.Id;
        EverCaesEntlmt.getServiceContractData(null ,case1, EntOpt, '' ,2, date.today());
        
        // Workorder.SVMXC__Warranty__c  = null;
        // Workorder.SVMXC__Service_Contract__c = null;
        // update Workorder;
        // System.currentPageReference().getParameters().put('cid', Workorder.Id);
        //EVER_CaseEntitlement EverCaesEntlmt1 = new EVER_CaseEntitlement();
        
    }
    static testMethod void EVER_CaseEntitlement_Test2()
    {
        Account account = new Account( Name ='Account',ShippingStreet='ABC',ShippingCity='PQR ',ShippingState = 'XYZ',ShippingPostalCode='111',ShippingCountry='XYZ',BillingStreet='ABC',BillingCity='PQR ',BillingState = 'XYZ',BillingPostalCode='111',BillingCountry='XYZ'); 
        insert account;
        
        Contact contact = new Contact(LastName='Last',AccountId =account.Id,Email='svmxmailfortest@servicemax.com');
        insert contact;
        
        SVMXC__Service_Level__c SLA_TERM = new SVMXC__Service_Level__c (Name = 'SLA_TERM1',SVMXC__Active__c = true);
        insert SLA_TERM ;           
        
        SVMXC__Service_Contract__c Current_SC= new SVMXC__Service_Contract__c(Name ='Current_SC',SVMXC__Service_Level__c = SLA_TERM.Id,SVMXC__Start_Date__c    = System.Today(),SVMXC__End_Date__c = System.Today()+1, SVMXC__Contact__c = contact.Id,SVMXC__Company__c = account.Id,SVMXC__Active__c = true);
        insert Current_SC;  
        
        SVMXC__Site__c objLoc = new SVMXC__Site__c();
        objLoc.SVMXC__City__c = 'Bangalore';
        insert objLoc;
        
        Case case1 = new Case(Status ='New', SVMXC__Site__c = objLoc.Id, SVMXC__Service_Contract__c = Current_SC.Id, Priority = 'Medium', Origin = 'Email', ContactId =contact.Id,AccountId=account.Id ); 
        insert case1;
        
        SVMXC__Service__c objService = new SVMXC__Service__c();
        objService.Name = 'service';
        objService.SVMXC__Active__c = true;
        objService.SVMXC__Tracked_On__c = 'Case';
        
        insert objService;
        
        
        SVMXC__Service_Contract_Services__c isObj = new SVMXC__Service_Contract_Services__c();
        isObj.SVMXC__Service_Contract__c = Current_SC.Id;
        isObj.SVMXC__Service__c = objService.Id;
        insert isObj;
        
        
        SVMXC__Entitlement_History__c objHstry1 = new SVMXC__Entitlement_History__c();
        objHstry1.SVMXC__Case__c = case1.Id;
        objHstry1.SVMXC__Service_Contract__c = Current_SC.id;
        objHstry1.SVMXC__Entitled_By_Service__c = isObj.Id;
        objHstry1.SVMXC__Inactive_Date__c = null;
        insert objHstry1;
        
        Product2 prod1 = new Product2(Name = 'Prod1',ProductCode = '1234-1', Family = 'Accessory',SVMXC__Product_Line__c = 'Laptop', SVMXC__Inherit_Parent_Warranty__c =false );
        insert prod1;
        
        SVMXC__Installed_Product__c IB0 = new SVMXC__Installed_Product__c(Name = 'IB0',SVMXC__Product__c = prod1.Id, SVMXC__Company__c = account.Id  , SVMXC__Contact__c =contact.Id,SVMXC__Status__c = 'Installed',SVMXC__Serial_Lot_Number__c = 'Test2', SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today(),SVMXC__Country__c='United States'); 
        insert IB0;
        
        SVMXC__Installed_Product__c IB1 = new SVMXC__Installed_Product__c(Name = 'IB1', SVMXC__Site__c = objLoc.Id, SVMXC__Company__c = account.Id , SVMXC__Contact__c =contact.Id, SVMXC__Status__c = 'Installed',SVMXC__Serial_Lot_Number__c = 'Test2', SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today(),SVMXC__Country__c='United States'); 
        insert IB1;
        
        SVMXC__Service_Template__c WT1  =new SVMXC__Service_Template__c(SVMXC__Walk_in_Allowed__c =false,SVMXC__Unit_of_Time__c = '100', SVMXC__Unit_of_Time_Material__c= 'Days', SVMXC__Unit_of_Time_Expenses__c='Months', SVMXC__Transferable__c=false, SVMXC__Time_Covered__c=100, SVMXC__Template_Type__c='Warranty', SVMXC__Shipment_Allowed__c=false, SVMXC__RMA_Required__c=true, SVMXC__Onsite_Repair__c=true,SVMXC__Material_Covered__c=100,  SVMXC__Loaner_Provided__c=false, SVMXC__Invoice_Required__c=false, SVMXC__Expenses_Covered__c=100, SVMXC__Duration_of_Time_Coverage__c=100, SVMXC__Duration_of_Material_Coverage__c=365, SVMXC__Duration_of_Expenses__c=52, SVMXC__Coverage_Effective_From__c='Install Date', SVMXC__All_Services_Covered__c=false, SVMXC__All_Products_Covered__c=false, Name ='Template1');
        insert WT1;
        
        list<SVMXC__Warranty__c> wl = new list<SVMXC__Warranty__c>();
        SVMXC__Warranty__c WarrantyforIB1 = new SVMXC__Warranty__c ( SVMXC__Select__c = true, SVMXC__Start_Date__c= System.Today()-1,SVMXC__Service_Template__c   = WT1.Id,SVMXC__Installed_Product__c  =IB1.Id,SVMXC__End_Date__c =System.Today()+1 );
        insert WarrantyforIB1; 
        wl.add(WarrantyforIB1);
        
        SVMXC__Warranty__c WarrantyforIB2 = new SVMXC__Warranty__c (SVMXC__Select__c = true, SVMXC__Start_Date__c= System.Today()-1,SVMXC__Service_Template__c   = WT1.Id,SVMXC__Installed_Product__c  =IB1.Id,SVMXC__End_Date__c =System.Today()+1 );
        insert WarrantyforIB2; 
        wl.add(WarrantyforIB2);
        
        SVMXC__Service_Order__c Workorder  = new SVMXC__Service_Order__c();
        Workorder.SVMXC__Company__c  = account.Id;
        Workorder.SVMXC__Contact__c = contact.Id;
        Workorder.SVMXC__Component__c = IB1.Id;
        Workorder.SVMXC__Site__c = objLoc.Id;
        Workorder.SVMXC__Product__c = prod1.id;
        Workorder.SVMXC__Warranty__c  = WarrantyforIB1.id;
        Workorder.SVMXC__Service_Contract__c = Current_SC.id;
        insert Workorder;
        
        SVMXC__Service_Contract_Contacts__c entitledContact = new SVMXC__Service_Contract_Contacts__c();
        entitledContact.SVMXC__Contact__c = contact.Id;
        entitledContact.SVMXC__Service_Contract__c = Current_SC.id;
        insert entitledContact;
        
        SVMXC__Service_Contract_Sites__c  covLoc = new SVMXC__Service_Contract_Sites__c();
        covLoc.SVMXC__Service_Contract__c = Current_SC.Id;
        covLoc.SVMXC__Site__c = objLoc.Id;
        covLoc.SVMXC__SLA_Terms__c = SLA_TERM.Id;
        insert covLoc;
        
        List<Case> lstcsHdr = new List<Case>();
        lstcsHdr.add(case1);
        List<SVMXC__Service_Order__c> lstWOHdr = new List<SVMXC__Service_Order__c>();
        lstWOHdr.add(Workorder);
        
        System.currentPageReference().getParameters().put('cid', case1.Id);
        
        EVER_CaseEntitlement EverCaesEntlmt = new EVER_CaseEntitlement();
        
        EverCaesEntlmt.SVMX_doCheckEntitlement();
        EverCaesEntlmt.strSelectedSCID = isObj.Id;
        EverCaesEntlmt.serviceSubmit();
        EverCaesEntlmt.AllSubModuleSettings.put('SET022', 'TRUE');
        
        List<SVMXC__Service_Contract_Products__c> lstCP = new List<SVMXC__Service_Contract_Products__c>();
        SVMXC__Service_Contract_Products__c newObjCP = new SVMXC__Service_Contract_Products__c();
        newObjCP.SVMXC__Service_Contract__c = contact.Id;
        newObjCP.SVMXC__Product__c = prod1.id;
        lstCP.add(newObjCP);
        
        
        EverCaesEntlmt.getContactCoveredProducts(lstCP, contact.Id);
        EverCaesEntlmt.getContactCoveredProducts(lstCP, null);
        
        
        EverCaesEntlmt.getTAG001();
        EverCaesEntlmt.getTAG004();
        EverCaesEntlmt.getTAG005();
        EverCaesEntlmt.getTAG006();
        EverCaesEntlmt.getTAG007();
        EverCaesEntlmt.getTAG008();
        EverCaesEntlmt.getTAG020();
        EverCaesEntlmt.getTAG021();
        EverCaesEntlmt.getTAG022();
        EverCaesEntlmt.getTAG038();
        EverCaesEntlmt.getTAG039();
        EverCaesEntlmt.getTAG040();
        EverCaesEntlmt.getTAG045();
        EverCaesEntlmt.getTAG046();
        EverCaesEntlmt.getTAG047();
        EverCaesEntlmt.getTAG048();
        EverCaesEntlmt.getTAG050();
        EverCaesEntlmt.getTAG051();
        EverCaesEntlmt.getTAG052();
        EverCaesEntlmt.getTAG053();
        EverCaesEntlmt.getTAG054();
        EverCaesEntlmt.getTAG055();
        EverCaesEntlmt.getTAG056();
        EverCaesEntlmt.getTAG057();
        EverCaesEntlmt.getTAG058();
        EverCaesEntlmt.getTAG059();
        EverCaesEntlmt.getTAG060();
        EverCaesEntlmt.getTAG061();
        EverCaesEntlmt.getTAG062();
        EverCaesEntlmt.getTAG063();
        EverCaesEntlmt.getTAG064();
        EverCaesEntlmt.getTAG065();
        EverCaesEntlmt.getTAG066();
        EverCaesEntlmt.getTAG067();
        EverCaesEntlmt.getTAG068();
        EverCaesEntlmt.getTAG069();
        EverCaesEntlmt.getTAG070();
        EverCaesEntlmt.getTAG071();
        EverCaesEntlmt.getTAG072();
        EverCaesEntlmt.getTAG073();
        EverCaesEntlmt.getTAG074();
        EverCaesEntlmt.getTAG075();
        EverCaesEntlmt.getTAG076();
        EverCaesEntlmt.getTAG077();
        EverCaesEntlmt.getTAG079();
        EverCaesEntlmt.getTAG080();
        EverCaesEntlmt.getTAG081();
        EverCaesEntlmt.getTAG082();
        EverCaesEntlmt.getTAG083();
        EverCaesEntlmt.getTAG084();
        EverCaesEntlmt.getTAG085();
        EverCaesEntlmt.getTAG086();
        EverCaesEntlmt.getTag089();
        EverCaesEntlmt.getTag090();
        EverCaesEntlmt.getTag091();
        EverCaesEntlmt.getTag092();
        EverCaesEntlmt.getTAG093();
        EverCaesEntlmt.getTAG094();
        EverCaesEntlmt.getTAG095();
        EverCaesEntlmt.getTAG096();
        EverCaesEntlmt.getTAG097();
        EverCaesEntlmt.getTAG098();
        EverCaesEntlmt.getTAG099();
        EverCaesEntlmt.getTAG100();
        EverCaesEntlmt.getTAG101();
        EverCaesEntlmt.getTAG102();
        EverCaesEntlmt.getTAG103();
        EverCaesEntlmt.getTAG104();
        EverCaesEntlmt.getTAG105();
        EverCaesEntlmt.getTAG106();
        EverCaesEntlmt.getTAG107();
        EverCaesEntlmt.getTAG108();
        
        EverCaesEntlmt.getHLPURL();
        EverCaesEntlmt.setApplicableEntitlementType('Account');
        EverCaesEntlmt.setSVMX_WarrResults(wl);
        EverCaesEntlmt.getSVMX_WarrResults();
        EverCaesEntlmt.PopulateSavedWarrSC();
        EverCaesEntlmt.setWOHdr(Workorder);
        EverCaesEntlmt.setCaseHdr(case1);
        EverCaesEntlmt.getEntitlementTypes();
        EverCaesEntlmt.isValidSearchCriteria();
        EverCaesEntlmt.SVMX_doCheckEntitlement();
        EverCaesEntlmt.setApplicableEntitlementType('Product');
        EverCaesEntlmt.setWOHdr(Workorder);
        EverCaesEntlmt.setCaseHdr(case1);
        EverCaesEntlmt.getEntitlementTypes();
        EverCaesEntlmt.isValidSearchCriteria();
        EverCaesEntlmt.SVMX_doCheckEntitlement();
        EVER_CaseEntitlement.WrapperClass EntOpt = new EVER_CaseEntitlement.WrapperClass();
        EverCaesEntlmt.getServiceContractData(null ,case1, EntOpt, '' ,2, date.today());
        EverCaesEntlmt.getIsWOUpdatable();
        EverCaesEntlmt.getIsRendered();
        EverCaesEntlmt.getIsCaseUpdatable();
        EverCaesEntlmt.getMyObject();
        EverCaesEntlmt.setTabname('selectTab');
        EverCaesEntlmt.getDetailId();
        EverCaesEntlmt.setDetailId('');
        EverCaesEntlmt.switchtab();
        EverCaesEntlmt.getAllowEntFilters();
        EverCaesEntlmt.setAllowEntFilters(true);
        EverCaesEntlmt.getSVMX_WarrResults();
        EverCaesEntlmt.getSVMX_SCResults();
        EverCaesEntlmt.getCaseHdr();
        EverCaesEntlmt.getWOHdr();
        EverCaesEntlmt.getObjectIs();
        EverCaesEntlmt.getEntOptions();
        EverCaesEntlmt.setEntOptions(EntOpt);
        EverCaesEntlmt.ValidateNPopulateSettings();
        EverCaesEntlmt.AddToErrorsList('');
        EverCaesEntlmt.getErrorsList();
        EverCaesEntlmt.getDisplayForm();
        EverCaesEntlmt.setDisplayForm(false);
        EverCaesEntlmt.DisplayErrors();
        EverCaesEntlmt.getEntitlementTypes();
        EverCaesEntlmt.getSelectedEntType();
        EverCaesEntlmt.setSelectedEntType('');
        EverCaesEntlmt.UpdateEntitlementType();
        EverCaesEntlmt.setApplicableEntitlementType('Product');
        EverCaesEntlmt.getCaseData();
        EverCaesEntlmt.getWOData();
        EverCaesEntlmt.isValidSearchCriteria();
        EverCaesEntlmt.SVMX_doCheckEntitlement();
        EverCaesEntlmt.Cancel();
        EverCaesEntlmt.SaveEntitlement();
        EverCaesEntlmt.isValidData();
        EverCaesEntlmt.getDisplaySCBlockTab();
        EverCaesEntlmt.getTAG002();
        EverCaesEntlmt.getTAG003();
        EverCaesEntlmt.getTAG009();
        EverCaesEntlmt.getTAG010();
        EverCaesEntlmt.getTAG011();
        EverCaesEntlmt.getTAG012();
        EverCaesEntlmt.getTAG013();
        EverCaesEntlmt.getTAG014();
        EverCaesEntlmt.getPageNameToRedirect();
        EverCaesEntlmt.getTAG047();
        EverCaesEntlmt.getTAG048();
        EverCaesEntlmt.getTAG050();
        EverCaesEntlmt.getTAG051();
        EverCaesEntlmt.getTAG052();
        EverCaesEntlmt.getTAG053();
        EverCaesEntlmt.getTAG054();
        EverCaesEntlmt.getTAG055();
        EverCaesEntlmt.getTAG056();
        EverCaesEntlmt.gettabNameValue();
        EverCaesEntlmt.getDetailPageId();
        EverCaesEntlmt.getDisplayWarrBlockTab();
        system.debug(EverCaesEntlmt.AllSubModuleSettings+ '--');
        list<SVMXC.EVER_SCResults> lstSCRslt = new list<SVMXC.EVER_SCResults>();
        EverCaesEntlmt.setSVMX_SCResults(lstSCRslt);
        EverCaesEntlmt.getTag087();
        EverCaesEntlmt.getTag088();
        EverCaesEntlmt.Setng_pageRedirect = true;
        EverCaesEntlmt.ObjectIs = 'WorkOrder';
        EverCaesEntlmt.PageRedirect();
        EverCaesEntlmt.SelectedEntType = 'Product';
        EverCaesEntlmt.SVMX_doCheckEntitlement();

    }
    
    static testMethod void EVER_CaseEntitlement_Test3()
    {
        Account objAcc = new Account();
        objAcc.Name = 'Test Account';
        insert objAcc;
        system.assert(objAcc.Name != NULL);
        
        Case objCase = new Case();
        objCase.Priority = 'HIGH';
        objCase.AccountId = objAcc.Id;
        insert objCase;
        system.assert(objCase.Priority != NULL);
        
        SVMXC__Service_Order__c objWorkOrd = new SVMXC__Service_Order__c();
        objWorkOrd.SVMXC__Company__c = objAcc.Id;
        objWorkOrd.SVMXC__Order_Status__c = 'OPEN';
        objWorkOrd.SVMXC__Priority__c = 'HIGH';
        insert objWorkOrd;
        system.assert(objWorkOrd.SVMXC__Order_Status__c != NULL);
        
        SVMXC__Service_Contract__c objServiceContract = new SVMXC__Service_Contract__c();
        objServiceContract.Name = 'Test_SCON001';
        objServiceContract.SVMXC__Active__c = true;
        objServiceContract.SVMXC__Company__c = objAcc.Id;
        objServiceContract.SVMXC__Start_Date__c = date.today();
        objServiceContract.SVMXC__End_Date__c = date.today().addDays(365);
        insert objServiceContract;
        system.assert(objServiceContract.Name != NULL);
        
        SVMXC__Service_Contract_Services__c objCvrdService = new SVMXC__Service_Contract_Services__c();
        objCvrdService.SVMXC__Service_Contract__c = objServiceContract.Id;
        objCvrdService.SVMXC__Consumed_Units__c = 5;
        insert objCvrdService;
        system.assert(objCvrdService.SVMXC__Service_Contract__c != NULL);
        
        SVMXC__Entitlement_History__c objHistory = new SVMXC__Entitlement_History__c();
        objHistory.SVMXC__Entitled_By_Service__c = objCvrdService.Id;
        objHistory.SVMXC__Inactive_Date__c = NULL;
        objHistory.SVMXC__Case__c = objCase.Id;
        insert objHistory;
        
        System.currentPageReference().getParameters().put('cid', objCase.Id);
        new EVER_CaseEntitlement().resetEntitlementInfo(objCase, objWorkOrd, 'Case');
        
        objHistory.SVMXC__Service_Order__c = objWorkOrd.Id;
        update objHistory;
        
        System.currentPageReference().getParameters().put('cid', objWorkOrd.Id);
        new EVER_CaseEntitlement().resetEntitlementInfo(objCase, objWorkOrd, 'Work Order');
    }
    
    static testMethod void EVER_CaseEntitlement_Test4()
    {
        
        Account account = new Account( Name ='Account',ShippingStreet='ABC',ShippingCity='PQR ',ShippingState = 'XYZ',ShippingPostalCode='111',ShippingCountry='XYZ',BillingStreet='ABC',BillingCity='PQR ',BillingState = 'XYZ',BillingPostalCode='111',BillingCountry='XYZ'); 
        insert account;
        
        Contact contact = new Contact(LastName='Last',AccountId =account.Id,Email='svmxmailfortest@servicemax.com');
        insert contact;
        
        SVMXC__Service_Level__c SLA_TERM = new SVMXC__Service_Level__c (Name = 'SLA_TERM1',SVMXC__Active__c = true);
        insert SLA_TERM ;           
        
        SVMXC__Service_Contract__c Current_SC= new SVMXC__Service_Contract__c(Name ='Current_SC',SVMXC__Service_Level__c = SLA_TERM.Id,SVMXC__Start_Date__c  = System.Today(),SVMXC__End_Date__c = System.Today()+1, SVMXC__Contact__c = contact.Id,SVMXC__Company__c = account.Id,SVMXC__Active__c = true);
        insert Current_SC;  
        
        SVMXC__Service_Contract__c Current_SC1 = new SVMXC__Service_Contract__c(Name ='Current_SC1',SVMXC__Service_Level__c = SLA_TERM.Id,SVMXC__Start_Date__c    = System.Today(),SVMXC__End_Date__c = System.Today()+1, SVMXC__Contact__c = contact.Id,SVMXC__Company__c = account.Id,SVMXC__Active__c = true);
        insert Current_SC1;
        
        SVMXC__ServiceMax_Processes__c svmxProcess1 = [Select Name from SVMXC__ServiceMax_Processes__c limit 1];
        
        SVMXC__Service__c objService1 = new SVMXC__Service__c();
        objService1.Name = 'service';
        objService1.SVMXC__Active__c = true;
        objService1.SVMXC__Tracked_On__c = 'Case';
        objService1.SVMXC__Qualifying_Criteria__c = svmxProcess1.ID;
        insert objService1;
        
        SVMXC__Service__c objService = new SVMXC__Service__c();
        objService.Name = 'service';
        objService.SVMXC__Active__c = true;
        objService.SVMXC__Tracked_On__c = 'Work Order';
        insert objService;
        
        
        SVMXC__Service_Contract_Services__c isObj = new SVMXC__Service_Contract_Services__c();
        isObj.SVMXC__Service_Contract__c = Current_SC.Id;
        isObj.SVMXC__Service__c = objService.Id;
        insert isObj;
        
        Case case1 = new Case(Status ='New', SVMXC__Service_Contract__c = Current_SC.Id, Priority = 'Medium', Origin = 'Email', ContactId =contact.Id,AccountId=account.Id ); 
        insert case1;
        
        SVMXC__Site__c objLoc = new SVMXC__Site__c();
        objLoc.SVMXC__City__c = 'Bangalore';
        insert objLoc;
        
        Product2 prod1 = new Product2(Name = 'Prod1',ProductCode = '1234-1', Family = 'Accessory',SVMXC__Product_Line__c = 'Laptop', SVMXC__Inherit_Parent_Warranty__c =false );
        insert prod1;
        
        SVMXC__Installed_Product__c IB0 = new SVMXC__Installed_Product__c(Name = 'IB0',SVMXC__Product__c = prod1.Id, SVMXC__Company__c = account.Id  , SVMXC__Contact__c =contact.Id,SVMXC__Status__c = 'Installed',SVMXC__Serial_Lot_Number__c = 'Test2', SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today(),SVMXC__Country__c='United States'); 
        insert IB0;
        
        SVMXC__Installed_Product__c IB1 = new SVMXC__Installed_Product__c(Name = 'IB1',SVMXC__Company__c = account.Id , SVMXC__Contact__c =contact.Id, SVMXC__Status__c = 'Installed',SVMXC__Serial_Lot_Number__c = 'Test2', SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today(),SVMXC__Country__c='United States'); 
        insert IB1;
        
        SVMXC__Service_Template__c WT1  =new SVMXC__Service_Template__c(SVMXC__Walk_in_Allowed__c =false,SVMXC__Unit_of_Time__c = '100', SVMXC__Unit_of_Time_Material__c= 'Days', SVMXC__Unit_of_Time_Expenses__c='Months', SVMXC__Transferable__c=false, SVMXC__Time_Covered__c=100, SVMXC__Template_Type__c='Warranty', SVMXC__Shipment_Allowed__c=false, SVMXC__RMA_Required__c=true, SVMXC__Onsite_Repair__c=true,SVMXC__Material_Covered__c=100,  SVMXC__Loaner_Provided__c=false, SVMXC__Invoice_Required__c=false, SVMXC__Expenses_Covered__c=100, SVMXC__Duration_of_Time_Coverage__c=100, SVMXC__Duration_of_Material_Coverage__c=365, SVMXC__Duration_of_Expenses__c=52, SVMXC__Coverage_Effective_From__c='Install Date', SVMXC__All_Services_Covered__c=false, SVMXC__All_Products_Covered__c=false, Name ='Template1');
        insert WT1;
        
        list<SVMXC__Warranty__c> wl = new list<SVMXC__Warranty__c>();
        SVMXC__Warranty__c WarrantyforIB1 = new SVMXC__Warranty__c (SVMXC__Select__c = true, SVMXC__Start_Date__c= System.Today()-1,SVMXC__Service_Template__c   = WT1.Id,SVMXC__Installed_Product__c  =IB1.Id,SVMXC__End_Date__c =System.Today()+1 );
        insert WarrantyforIB1; 
        wl.add(WarrantyforIB1);
        
        SVMXC__Warranty__c WarrantyforIB2 = new SVMXC__Warranty__c (SVMXC__Select__c = true, SVMXC__Start_Date__c= System.Today()-1,SVMXC__Service_Template__c   = WT1.Id,SVMXC__Installed_Product__c  =IB1.Id,SVMXC__End_Date__c =System.Today()+1 );
        insert WarrantyforIB2; 
        wl.add(WarrantyforIB2);
        
        SVMXC__Service_Order__c Workorder  = new SVMXC__Service_Order__c();
        Workorder.SVMXC__Company__c  = account.Id;
        Workorder.SVMXC__Contact__c = contact.Id;
        Workorder.SVMXC__Component__c = IB1.Id;  
        Workorder.SVMXC__Product__c = prod1.id;
        Workorder.SVMXC__Warranty__c  = WarrantyforIB1.id;
        Workorder.SVMXC__Service_Contract__c = Current_SC.id;
        Workorder.SVMXC__Site__c = objLoc.Id;
        insert Workorder;
        
        SVMXC__Service_Contract_Contacts__c entitledContact = new SVMXC__Service_Contract_Contacts__c();
        entitledContact.SVMXC__Contact__c = contact.Id;
        entitledContact.SVMXC__Service_Contract__c = Current_SC.id;
        insert entitledContact;
        
        SVMXC__Entitlement_History__c objHstry = new SVMXC__Entitlement_History__c();
        objHstry.SVMXC__Service_Order__c = Workorder.Id;
        objHstry.SVMXC__Service_Contract__c = Current_SC.id;
        objHstry.SVMXC__Entitled_By_Service__c = isObj.Id;
        objHstry.SVMXC__Inactive_Date__c = null;
        insert objHstry;
        
        List<Case> lstcsHdr = new List<Case>();
        lstcsHdr.add(case1);
        List<SVMXC__Service_Order__c> lstWOHdr = new List<SVMXC__Service_Order__c>();
        lstWOHdr.add(Workorder);
        System.currentPageReference().getParameters().put('cid', Workorder.Id);
        EVER_CaseEntitlement EverCaesEntlmt = new EVER_CaseEntitlement();
        EVER_CaseEntitlement.WrapperClass EntOpt = new EVER_CaseEntitlement.WrapperClass();
        EntOpt.Match_Location = true;
        EntOpt.Match_Contact = false;
        EverCaesEntlmt.AllSubModuleSettings.put('SET022', 'TRUE');
      
        EverCaesEntlmt.setApplicableEntitlementType('Account');
        EverCaesEntlmt.setSVMX_WarrResults(wl);
        EverCaesEntlmt.isValidData();
        EverCaesEntlmt.getSVMX_WarrResults();
        EverCaesEntlmt.PopulateSavedWarrSC();
        EverCaesEntlmt.getIsRendered();
        EverCaesEntlmt.setWOHdr(Workorder);
        EverCaesEntlmt.setCaseHdr(case1);
        EverCaesEntlmt.getEntitlementTypes();
        EverCaesEntlmt.isValidSearchCriteria();
        EverCaesEntlmt.getCaseData();
        EverCaesEntlmt.getWOData();
        
        EverCaesEntlmt.strSelectedSCID = Current_SC.Id;
        EverCaesEntlmt.showMoreServices();
        EverCaesEntlmt.serviceSubmitcheck();
        EverCaesEntlmt.SaveEntitlement();
        
        isObj.SVMXC__Included_Units__c = 20;
        isObj.SVMXC__Consumed_Units__c = 14;
        update isObj;
        
       
        EverCaesEntlmt.strSelectedSCID = Current_SC.Id;
        EverCaesEntlmt.serviceSubmitcheck();
        EverCaesEntlmt.SaveEntitlement();
        
        
        isObj.SVMXC__Included_Units__c = 20;
        isObj.SVMXC__Consumed_Units__c = 24;
        update isObj;
        
        EntOpt.Match_Location = true;
        EverCaesEntlmt.SVMX_doCheckEntitlement();
        EverCaesEntlmt.strSelectedSCID = Current_SC.Id;
        //EverCaesEntlmt.SaveEntitlement();
        
        //EverCaesEntlmt.strSlectedService = 'None';
        //EverCaesEntlmt.serviceSubmitcheck();
        
        //EverCaesEntlmt.strSelectedSCID = Current_SC1.Id;
        //EverCaesEntlmt.serviceSubmit();
        
  
        //EverCaesEntlmt.serviceSubmitcheck();
        //EverCaesEntlmt.serviceSubmit();
        
    }
    
    static testMethod void EVER_CaseEntitlement_Test5()
    {
        
        Account account = new Account( Name ='Account',ShippingStreet='ABC',ShippingCity='PQR ',ShippingState = 'XYZ',ShippingPostalCode='111',ShippingCountry='XYZ',BillingStreet='ABC',BillingCity='PQR ',BillingState = 'XYZ',BillingPostalCode='111',BillingCountry='XYZ'); 
        insert account;
        
        Contact contact = new Contact(LastName='Last',AccountId =account.Id,Email='svmxmailfortest@servicemax.com');
        insert contact;
        
        SVMXC__Service_Level__c SLA_TERM = new SVMXC__Service_Level__c (Name = 'SLA_TERM1',SVMXC__Active__c = true);
        insert SLA_TERM ;           
        
        SVMXC__Service_Contract__c Current_SC= new SVMXC__Service_Contract__c(Name ='Current_SC',SVMXC__Service_Level__c = SLA_TERM.Id,SVMXC__Start_Date__c  = System.Today(),SVMXC__End_Date__c = System.Today()+1, SVMXC__Contact__c = contact.Id,SVMXC__Company__c = account.Id,SVMXC__Active__c = true);
        insert Current_SC;  
        
        SVMXC__Service_Contract__c Current_SC1 = new SVMXC__Service_Contract__c(Name ='Current_SC1',SVMXC__Service_Level__c = SLA_TERM.Id,SVMXC__Start_Date__c    = System.Today(),SVMXC__End_Date__c = System.Today()+1, SVMXC__Contact__c = contact.Id,SVMXC__Company__c = account.Id,SVMXC__Active__c = true);
        insert Current_SC1;
        
        SVMXC__Service__c objService = new SVMXC__Service__c();
        objService.Name = 'service';
        objService.SVMXC__Active__c = true;
        objService.SVMXC__Tracked_On__c = 'Work Order';
        insert objService;
        
        
        SVMXC__Service_Contract_Services__c isObj = new SVMXC__Service_Contract_Services__c();
        isObj.SVMXC__Service_Contract__c = Current_SC.Id;
        isObj.SVMXC__Service__c = objService.Id;
        insert isObj;
        
        Case case1 = new Case(Status ='New', SVMXC__Service_Contract__c = Current_SC.Id, Priority = 'Medium', Origin = 'Email', ContactId =contact.Id,AccountId=account.Id ); 
        insert case1;
        
        SVMXC__Site__c objLoc = new SVMXC__Site__c();
        objLoc.SVMXC__City__c = 'Bangalore';
        insert objLoc;
        
        Product2 prod1 = new Product2(Name = 'Prod1',ProductCode = '1234-1', Family = 'Accessory',SVMXC__Product_Line__c = 'Laptop', SVMXC__Inherit_Parent_Warranty__c =false );
        insert prod1;
        
        SVMXC__Installed_Product__c IB0 = new SVMXC__Installed_Product__c(Name = 'IB0',SVMXC__Product__c = prod1.Id, SVMXC__Company__c = account.Id  , SVMXC__Contact__c =contact.Id,SVMXC__Status__c = 'Installed',SVMXC__Serial_Lot_Number__c = 'Test2', SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today(),SVMXC__Country__c='United States'); 
        insert IB0;
        
        SVMXC__Installed_Product__c IB1 = new SVMXC__Installed_Product__c(Name = 'IB1',SVMXC__Company__c = account.Id , SVMXC__Contact__c =contact.Id, SVMXC__Status__c = 'Installed',SVMXC__Serial_Lot_Number__c = 'Test2', SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today(),SVMXC__Country__c='United States'); 
        insert IB1;
        
        SVMXC__Service_Template__c WT1  =new SVMXC__Service_Template__c(SVMXC__Walk_in_Allowed__c =false,SVMXC__Unit_of_Time__c = '100', SVMXC__Unit_of_Time_Material__c= 'Days', SVMXC__Unit_of_Time_Expenses__c='Months', SVMXC__Transferable__c=false, SVMXC__Time_Covered__c=100, SVMXC__Template_Type__c='Warranty', SVMXC__Shipment_Allowed__c=false, SVMXC__RMA_Required__c=true, SVMXC__Onsite_Repair__c=true,SVMXC__Material_Covered__c=100,  SVMXC__Loaner_Provided__c=false, SVMXC__Invoice_Required__c=false, SVMXC__Expenses_Covered__c=100, SVMXC__Duration_of_Time_Coverage__c=100, SVMXC__Duration_of_Material_Coverage__c=365, SVMXC__Duration_of_Expenses__c=52, SVMXC__Coverage_Effective_From__c='Install Date', SVMXC__All_Services_Covered__c=false, SVMXC__All_Products_Covered__c=false, Name ='Template1');
        insert WT1;
        
        list<SVMXC__Warranty__c> wl = new list<SVMXC__Warranty__c>();
        SVMXC__Warranty__c WarrantyforIB1 = new SVMXC__Warranty__c (SVMXC__Select__c = true, SVMXC__Start_Date__c= System.Today()-1,SVMXC__Service_Template__c   = WT1.Id,SVMXC__Installed_Product__c  =IB1.Id,SVMXC__End_Date__c =System.Today()+1 );
        insert WarrantyforIB1; 
        wl.add(WarrantyforIB1);
        
        SVMXC__Warranty__c WarrantyforIB2 = new SVMXC__Warranty__c (SVMXC__Select__c = true, SVMXC__Start_Date__c= System.Today()-1,SVMXC__Service_Template__c   = WT1.Id,SVMXC__Installed_Product__c  =IB1.Id,SVMXC__End_Date__c =System.Today()+1 );
        insert WarrantyforIB2; 
        wl.add(WarrantyforIB2);
        
        SVMXC__Service_Order__c Workorder  = new SVMXC__Service_Order__c();
        Workorder.SVMXC__Company__c  = account.Id;
        Workorder.SVMXC__Contact__c = contact.Id;
        Workorder.SVMXC__Component__c = IB1.Id;  
        Workorder.SVMXC__Product__c = prod1.id;
        Workorder.SVMXC__Warranty__c  = WarrantyforIB1.id;
        Workorder.SVMXC__Service_Contract__c = Current_SC.id;
        Workorder.SVMXC__Site__c = objLoc.Id;
        insert Workorder;
        
        SVMXC__Service_Contract_Contacts__c entitledContact = new SVMXC__Service_Contract_Contacts__c();
        entitledContact.SVMXC__Contact__c = contact.Id;
        entitledContact.SVMXC__Service_Contract__c = Current_SC.id;
        insert entitledContact;
        
        SVMXC__Entitlement_History__c objHstry = new SVMXC__Entitlement_History__c();
        objHstry.SVMXC__Service_Order__c = Workorder.Id;
        objHstry.SVMXC__Service_Contract__c = Current_SC.id;
        objHstry.SVMXC__Entitled_By_Service__c = isObj.Id;
        objHstry.SVMXC__Inactive_Date__c = null;
        insert objHstry;
        
        List<Case> lstcsHdr = new List<Case>();
        lstcsHdr.add(case1);
        List<SVMXC__Service_Order__c> lstWOHdr = new List<SVMXC__Service_Order__c>();
        lstWOHdr.add(Workorder);
        System.currentPageReference().getParameters().put('cid', Workorder.Id);
        EVER_CaseEntitlement EverCaesEntlmt = new EVER_CaseEntitlement();
        
        isObj.SVMXC__Included_Units__c = 20;
        isObj.SVMXC__Consumed_Units__c = 14;
        update isObj;
        
        System.currentPageReference().getParameters().put('cid', Workorder.Id);
        EVER_CaseEntitlement EverCaesEntlmt1 = new EVER_CaseEntitlement();

        
        isObj.SVMXC__Included_Units__c = 20;
        isObj.SVMXC__Consumed_Units__c = 24;
        update isObj;
        
        System.currentPageReference().getParameters().put('cid', Workorder.Id);
        EVER_CaseEntitlement EverCaesEntlmt2 = new EVER_CaseEntitlement();
        
        objHstry.SVMXC__Entitled_By_Service__c = null;
        update objHstry;
        
        System.currentPageReference().getParameters().put('cid', Workorder.Id);
        EVER_CaseEntitlement EverCaesEntlmt3 = new EVER_CaseEntitlement();
        
        Workorder.SVMXC__Service_Contract__c = null;
        delete objHstry;
        System.currentPageReference().getParameters().put('cid', Workorder.Id);
        EVER_CaseEntitlement EverCaesEntlmt4 = new EVER_CaseEntitlement();
        EverCaesEntlmt4.WOHdr.SVMXC__Service_Contract__c = null;
        EverCaesEntlmt4.PopulateSavedWarrSC();
        
        EverCaesEntlmt4.WOHdr.SVMXC__Company__c = null;
        EverCaesEntlmt4.EntOptions.Match_Account= true;
        EverCaesEntlmt4.WOHdr.SVMXC__Contact__c = null;
        EverCaesEntlmt4.EntOptions.Match_Contact= false;
        EverCaesEntlmt4.EntOptions.Match_Location= true;
        
        EverCaesEntlmt4.WOHdr.SVMXC__Product__c = null;
        EverCaesEntlmt4.EntOptions.Chk_Part_Number = true;
        EverCaesEntlmt4.isValidSearchCriteria();
        
        EverCaesEntlmt4.strLocId = '123';
        EverCaesEntlmt4.EntOptions.Show_Expired_Entitlement = false;
        EverCaesEntlmt4.Setng_EntitleUsingDateFld = null;
        EverCaesEntlmt4.SVMX_doCheckEntitlement();
        
        EverCaesEntlmt4.Setng_EntitleUsingDateFld = 'testing';
        EverCaesEntlmt4.SVMX_doCheckEntitlement();
        EverCaesEntlmt4.SelectedEntType = 'Product';
        EverCaesEntlmt4.SVMX_doCheckEntitlement();
        
        
        
    }
    static testMethod void EVER_CaseEntitlement_Test6()
    {
        Account account = new Account( Name ='Account',ShippingStreet='ABC',ShippingCity='PQR ',ShippingState = 'XYZ',ShippingPostalCode='111',ShippingCountry='XYZ',BillingStreet='ABC',BillingCity='PQR ',BillingState = 'XYZ',BillingPostalCode='111',BillingCountry='XYZ'); 
        insert account;
        
        Contact contact = new Contact(LastName='Last',AccountId =account.Id,Email='svmxmailfortest@gmail.com');
        insert contact;
        
        SVMXC__Service_Level__c SLA_TERM = new SVMXC__Service_Level__c (Name = 'SLA_TERM1',SVMXC__Active__c = true);
        insert SLA_TERM ;           
        
        SVMXC__Service_Contract__c Current_SC= new SVMXC__Service_Contract__c(Name ='Current_SC',SVMXC__Service_Level__c = SLA_TERM.Id,SVMXC__Start_Date__c    = System.Today(),SVMXC__End_Date__c = System.Today()+1, SVMXC__Contact__c = contact.Id,SVMXC__Company__c = account.Id,SVMXC__Active__c = true);
        insert Current_SC;  
        
        SVMXC__Site__c objLoc = new SVMXC__Site__c();
        objLoc.SVMXC__City__c = 'Bangalore';
        insert objLoc;
        
        SVMXC__ServiceMax_Processes__c svmxProcess1 = [Select Name from SVMXC__ServiceMax_Processes__c limit 1];
        
        SVMXC__Service__c objService = new SVMXC__Service__c();
        objService.Name = 'service';
        objService.SVMXC__Active__c = true;
        objService.SVMXC__Tracked_On__c = 'Case';
        objService.SVMXC__Qualifying_Criteria__c = svmxProcess1.ID;
        insert objService;
        
        SVMXC__Service__c objServiceWO = new SVMXC__Service__c();
        objServiceWO.Name = 'service';
        objServiceWO.SVMXC__Active__c = true;
        objServiceWO.SVMXC__Tracked_On__c = 'Work Order';
        objServiceWO.SVMXC__Qualifying_Criteria__c = svmxProcess1.ID;
        insert objServiceWO;
        
        
        SVMXC__Service_Contract_Services__c isObj = new SVMXC__Service_Contract_Services__c();
        isObj.SVMXC__Service_Contract__c = Current_SC.Id;
        isObj.SVMXC__Service__c = objService.Id;
        insert isObj;
        
        Product2 prod1 = new Product2(Name = 'Prod1',ProductCode = '1234-1', Family = 'Accessory',SVMXC__Product_Line__c = 'Laptop', SVMXC__Inherit_Parent_Warranty__c =false );
        insert prod1;
        
        SVMXC__Installed_Product__c IB0 = new SVMXC__Installed_Product__c(Name = 'IB0',SVMXC__Product__c = prod1.Id, SVMXC__Company__c = account.Id  , SVMXC__Contact__c =contact.Id,SVMXC__Status__c = 'Installed',SVMXC__Serial_Lot_Number__c = 'Test2', SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today(),SVMXC__Country__c='United States'); 
        insert IB0;
        
        SVMXC__Installed_Product__c IB1 = new SVMXC__Installed_Product__c(Name = 'IB1', SVMXC__Site__c = objLoc.Id, SVMXC__Company__c = account.Id , SVMXC__Contact__c =contact.Id, SVMXC__Status__c = 'Installed',SVMXC__Serial_Lot_Number__c = 'Test2', SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today(),SVMXC__Country__c='United States'); 
        insert IB1;
        
        SVMXC__Service_Template__c WT1  =new SVMXC__Service_Template__c(SVMXC__Walk_in_Allowed__c =false,SVMXC__Unit_of_Time__c = '100', SVMXC__Unit_of_Time_Material__c= 'Days', SVMXC__Unit_of_Time_Expenses__c='Months', SVMXC__Transferable__c=false, SVMXC__Time_Covered__c=100, SVMXC__Template_Type__c='Warranty', SVMXC__Shipment_Allowed__c=false, SVMXC__RMA_Required__c=true, SVMXC__Onsite_Repair__c=true,SVMXC__Material_Covered__c=100,  SVMXC__Loaner_Provided__c=false, SVMXC__Invoice_Required__c=false, SVMXC__Expenses_Covered__c=100, SVMXC__Duration_of_Time_Coverage__c=100, SVMXC__Duration_of_Material_Coverage__c=365, SVMXC__Duration_of_Expenses__c=52, SVMXC__Coverage_Effective_From__c='Install Date', SVMXC__All_Services_Covered__c=false, SVMXC__All_Products_Covered__c=false, Name ='Template1');
        insert WT1;
        
        list<SVMXC__Warranty__c> wl = new list<SVMXC__Warranty__c>();
        SVMXC__Warranty__c WarrantyforIB1 = new SVMXC__Warranty__c ( SVMXC__Select__c = true, SVMXC__Start_Date__c= System.Today()-1,SVMXC__Service_Template__c   = WT1.Id,SVMXC__Installed_Product__c  =IB1.Id,SVMXC__End_Date__c =System.Today()+1 );
        insert WarrantyforIB1; 
        wl.add(WarrantyforIB1);
        
        SVMXC__Warranty__c WarrantyforIB2 = new SVMXC__Warranty__c (SVMXC__Select__c = true, SVMXC__Start_Date__c= System.Today()-1,SVMXC__Service_Template__c   = WT1.Id,SVMXC__Installed_Product__c  =IB1.Id,SVMXC__End_Date__c =System.Today()+1 );
        insert WarrantyforIB2; 
        wl.add(WarrantyforIB2);
        
        Case case1 = new Case(Status ='New', SVMXC__Site__c = objLoc.Id, SVMXC__Service_Contract__c = Current_SC.Id, Priority = 'Medium', Origin = 'Email', ContactId =contact.Id,AccountId=account.Id, SVMXC__Warranty__c = WarrantyforIB2.Id ); 
        insert case1;
        
        SVMXC__Entitlement_History__c objHstry1 = new SVMXC__Entitlement_History__c();
        objHstry1.SVMXC__Case__c = case1.Id;
        objHstry1.SVMXC__Service_Contract__c = Current_SC.id;
        objHstry1.SVMXC__Entitled_By_Service__c = isObj.Id;
        objHstry1.SVMXC__Inactive_Date__c = null;
        insert objHstry1;
        
        SVMXC__Service_Order__c Workorder  = new SVMXC__Service_Order__c();
        Workorder.SVMXC__Company__c  = account.Id;
        Workorder.SVMXC__Contact__c = contact.Id;
        Workorder.SVMXC__Component__c = IB1.Id;  
        Workorder.SVMXC__Product__c = prod1.id;
        Workorder.SVMXC__Warranty__c  = WarrantyforIB1.id;
        Workorder.SVMXC__Service_Contract__c = Current_SC.id;
        Workorder.SVMXC__Site__c = objLoc.Id;
        insert Workorder;
        List<Case> lstcsHdr = new List<Case>();
        lstcsHdr.add(case1);
        List<SVMXC__Service_Order__c> lstWOHdr = new List<SVMXC__Service_Order__c>();
        lstWOHdr.add(Workorder);
        
        System.currentPageReference().getParameters().put('cid', case1.Id);
        EVER_CaseEntitlement EverCaesEntlmt1 = new EVER_CaseEntitlement();
        
        isObj.SVMXC__Included_Units__c = 20;
        isObj.SVMXC__Consumed_Units__c = 14;
        update isObj;
        
        System.currentPageReference().getParameters().put('cid', case1.Id);
        EVER_CaseEntitlement EverCaesEntlmt2 = new EVER_CaseEntitlement();

        
        isObj.SVMXC__Included_Units__c = 20;
        isObj.SVMXC__Consumed_Units__c = 24;
        update isObj;
        
        System.currentPageReference().getParameters().put('cid', case1.Id);
        EVER_CaseEntitlement EverCaesEntlmt3 = new EVER_CaseEntitlement();
        
        objHstry1.SVMXC__Entitled_By_Service__c = null;
        update objHstry1;
        
        System.currentPageReference().getParameters().put('cid', case1.Id);
        EVER_CaseEntitlement EverCaesEntlmt4 = new EVER_CaseEntitlement();
        
        case1.SVMXC__Service_Contract__c = null;
         delete objHstry1;
        System.currentPageReference().getParameters().put('cid', case1.Id);
        EVER_CaseEntitlement EverCaesEntlmt5 = new EVER_CaseEntitlement();
        EverCaesEntlmt5.csHdr.SVMXC__Service_Contract__c = null;
        EverCaesEntlmt5.PopulateSavedWarrSC();
        
        EverCaesEntlmt5.csHdr.AccountId = null;
        EverCaesEntlmt5.EntOptions.Match_Account= true;
        EverCaesEntlmt5.csHdr.ContactId = null;
        EverCaesEntlmt5.EntOptions.Match_Contact= false;
        EverCaesEntlmt5.csHdr.SVMXC__Product__c = null;
        EverCaesEntlmt5.EntOptions.Chk_Part_Number = true;
        EverCaesEntlmt5.isValidSearchCriteria();
        
        EverCaesEntlmt5.EntOptions.Match_Contact = false;
        EverCaesEntlmt5.EntOptions.Match_Location = true;
        EverCaesEntlmt5.Setng_EntitleUsingDateFld = null;
        EverCaesEntlmt5.SVMX_doCheckEntitlement();
        
        EverCaesEntlmt5.Setng_EntitleUsingDateFld = 'testing';
        EverCaesEntlmt5.SVMX_doCheckEntitlement();
        EverCaesEntlmt5.SelectedEntType = 'Product';
        EverCaesEntlmt5.SVMX_doCheckEntitlement();
        
    }

     static testMethod void EVER_CaseEntitlement_Test7()
    {
        Account account = new Account( Name ='Account',ShippingStreet='ABC',ShippingCity='PQR ',ShippingState = 'XYZ',ShippingPostalCode='111',ShippingCountry='XYZ',BillingStreet='ABC',BillingCity='PQR ',BillingState = 'XYZ',BillingPostalCode='111',BillingCountry='XYZ'); 
        insert account;
        
        Contact contact = new Contact(LastName='Last',AccountId =account.Id,Email='svmxmailfortest@servicemax.com');
        insert contact;
        
        SVMXC__Service_Level__c SLA_TERMP = new SVMXC__Service_Level__c (Name = 'SLA_TERMP',SVMXC__Active__c = true);
        insert SLA_TERMP ; 

        SVMXC__Service_Level__c SLA_TERML = new SVMXC__Service_Level__c (Name = 'SLA_TERML',SVMXC__Active__c = true);
        insert SLA_TERML ;
        
        SVMXC__Service_Level__c SLA_TERMC = new SVMXC__Service_Level__c (Name = 'SLA_TERMC',SVMXC__Active__c = true);
        insert SLA_TERMC ;
        
        SVMXC__Service_Contract__c Current_SC= new SVMXC__Service_Contract__c(Name ='Current_SC',SVMXC__Service_Level__c = SLA_TERMC.Id,SVMXC__Start_Date__c    = System.Today(),SVMXC__End_Date__c = System.Today()+1, SVMXC__Contact__c = contact.Id,SVMXC__Company__c = account.Id,SVMXC__Active__c = true);
        insert Current_SC; 
        
        SVMXC__Service_Contract__c NoSLACurrent_SC= new SVMXC__Service_Contract__c(Name ='Current_SC',SVMXC__Service_Level__c = SLA_TERMC.Id,SVMXC__Start_Date__c    = System.Today(),SVMXC__End_Date__c = System.Today()+1, SVMXC__Contact__c = contact.Id,SVMXC__Company__c = account.Id,SVMXC__Active__c = true);
        insert NoSLACurrent_SC; 
        
        Product2 prod1 = new Product2(Name = 'Prod1',ProductCode = '1234-1', Family = 'Accessory',SVMXC__Product_Line__c = 'Laptop', SVMXC__Inherit_Parent_Warranty__c =false );
        insert prod1;
        
        SVMXC__Installed_Product__c IB0 = new SVMXC__Installed_Product__c(Name = 'IB0',SVMXC__Product__c = prod1.Id, SVMXC__Company__c = account.Id  , SVMXC__Contact__c =contact.Id,SVMXC__Status__c = 'Installed',SVMXC__Serial_Lot_Number__c = 'Test2', SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today(),SVMXC__Country__c='United States'); 
        insert IB0;
        
        SVMXC__Site__c objLoc = new SVMXC__Site__c();
        objLoc.SVMXC__City__c = 'Bangalore';
        insert objLoc;
        
        SVMXC__Installed_Product__c IB1 = new SVMXC__Installed_Product__c(Name = 'IB1', SVMXC__Site__c = objLoc.Id, SVMXC__Company__c = account.Id , SVMXC__Contact__c =contact.Id, SVMXC__Status__c = 'Installed',SVMXC__Serial_Lot_Number__c = 'Test2', SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today(),SVMXC__Country__c='United States'); 
        insert IB1;
        
        SVMXC__Service_Contract_Products__c newObjCP = new SVMXC__Service_Contract_Products__c();
        newObjCP.SVMXC__Service_Contract__c = Current_SC.Id;
        newObjCP.SVMXC__Installed_Product__c = IB1.id;
        newObjCP.SVMXC__SLA_Terms__c = SLA_TERMP.id;
        
        SVMXC__Service_Contract_Products__c newObjCP1 = new SVMXC__Service_Contract_Products__c();
        newObjCP1.SVMXC__Service_Contract__c = Current_SC.Id;
        newObjCP1.SVMXC__Installed_Product__c = IB1.id;
        insert newObjCP1;
        
        SVMXC__Service__c objService = new SVMXC__Service__c();
        objService.Name = 'service';
        objService.SVMXC__Active__c = true;
        objService.SVMXC__Tracked_On__c = 'Case';
        insert objService;
        
        
        SVMXC__Service_Contract_Services__c isObj = new SVMXC__Service_Contract_Services__c();
        isObj.SVMXC__Service_Contract__c = Current_SC.Id;
        isObj.SVMXC__Service__c = objService.Id;
        insert isObj;
        
        SVMXC__Service_Contract_Sites__c  covLoc = new SVMXC__Service_Contract_Sites__c();
        covLoc.SVMXC__Service_Contract__c = Current_SC.Id;
        covLoc.SVMXC__Site__c = objLoc.Id;
        covLoc.SVMXC__SLA_Terms__c = SLA_TERML.id;
        covLoc.SVMXC__Start_Date__c = Date.today();
        covLoc.SVMXC__End_Date__c = Date.today();
        insert covLoc;
        
        SVMXC__Service_Contract_Sites__c  noSLAcovLoc = new SVMXC__Service_Contract_Sites__c();
        noSLAcovLoc.SVMXC__Service_Contract__c = Current_SC.Id;
        noSLAcovLoc.SVMXC__Site__c = objLoc.Id;
        insert noSLAcovLoc;
        
        SVMXC__Service_Template__c WT1  =new SVMXC__Service_Template__c(SVMXC__Walk_in_Allowed__c =false,SVMXC__Unit_of_Time__c = '100', SVMXC__Unit_of_Time_Material__c= 'Days', SVMXC__Unit_of_Time_Expenses__c='Months', SVMXC__Transferable__c=false, SVMXC__Time_Covered__c=100, SVMXC__Template_Type__c='Warranty', SVMXC__Shipment_Allowed__c=false, SVMXC__RMA_Required__c=true, SVMXC__Onsite_Repair__c=true,SVMXC__Material_Covered__c=100,  SVMXC__Loaner_Provided__c=false, SVMXC__Invoice_Required__c=false, SVMXC__Expenses_Covered__c=100, SVMXC__Duration_of_Time_Coverage__c=100, SVMXC__Duration_of_Material_Coverage__c=365, SVMXC__Duration_of_Expenses__c=52, SVMXC__Coverage_Effective_From__c='Install Date', SVMXC__All_Services_Covered__c=false, SVMXC__All_Products_Covered__c=false, Name ='Template1');
        insert WT1;
        
        
        Map<String, SVMXC__Service_Contract_Sites__c> mapServiceContractIDANDCoveredProd = new  Map<String, SVMXC__Service_Contract_Sites__c> ();
        mapServiceContractIDANDCoveredProd.put(Current_SC.Id, covLoc);
        mapServiceContractIDANDCoveredProd.put(NoSLACurrent_SC.ID,noSLAcovLoc );
                
        SVMXC__Service_Order__c Workorder  = new SVMXC__Service_Order__c();
        Workorder.SVMXC__Company__c  = account.Id;
        Workorder.SVMXC__Contact__c = contact.Id;
        Workorder.SVMXC__Component__c = IB1.Id;  
        Workorder.SVMXC__Product__c = prod1.id;
        Workorder.SVMXC__Service_Contract__c = Current_SC.id;
        Workorder.SVMXC__Site__c = objLoc.Id;
        insert Workorder;
        List<SVMXC__Service_Order__c> lstWOHdr = new List<SVMXC__Service_Order__c>();
        lstWOHdr.add(Workorder);
        
        SVMXC.EVER_SCResults TempRecord = new SVMXC.EVER_SCResults();
        System.currentPageReference().getParameters().put('cid', Workorder.Id);
        EVER_CaseEntitlement EverCaesEntlmt5 = new EVER_CaseEntitlement();
        
        Map<String, SVMXC__Service_Contract_Sites__c> mapServiceContractIDANDCoveredLoc = new  Map<String, SVMXC__Service_Contract_Sites__c> ();
        EverCaesEntlmt5.EntOptions.Match_Account= true;
        EverCaesEntlmt5.EntOptions.Match_Contact= false;
        EverCaesEntlmt5.EntOptions.Match_Location= false;
        EverCaesEntlmt5.EntOptions.Chk_Part_Number = true;
        EverCaesEntlmt5.Setng_EntitleUsingDateFld = null;
        EverCaesEntlmt5.selectValidSLA(Date.today(), newObjCP,TempRecord, mapServiceContractIDANDCoveredProd );
        EverCaesEntlmt5.selectValidLocation(Date.today(), newObjCP,TempRecord, mapServiceContractIDANDCoveredLoc );
        
        EVER_CaseEntitlement EverCaesEntlmt6 = new EVER_CaseEntitlement();
        EverCaesEntlmt6.EntOptions.Match_Account= true;
        EverCaesEntlmt6.EntOptions.Match_Contact= false;
        EverCaesEntlmt6.selectValidSLA(Date.today(), newObjCP1,TempRecord, mapServiceContractIDANDCoveredProd );
        //EverCaesEntlmt7.selectValidLocation( Date.today(), newObjCP1,TempRecord, mapServiceContractIDANDCoveredProd );
        
        EverCaesEntlmt5.Setng_ApplicableSLACovLevel = 'Product';
        EVER_CaseEntitlement EverCaesEntlmt7 = new EVER_CaseEntitlement();
        EverCaesEntlmt7.EntOptions.Match_Account= true;
        EverCaesEntlmt7.EntOptions.Match_Contact= true;
        EverCaesEntlmt7.EntOptions.Match_Location= true;
        EverCaesEntlmt7.selectValidSLA( Date.today(), newObjCP1,TempRecord, mapServiceContractIDANDCoveredProd );
        EverCaesEntlmt7.selectValidLocation( Date.today(), newObjCP1,TempRecord, mapServiceContractIDANDCoveredProd );
        
        
        EverCaesEntlmt5.EntOptions.Match_Account= true;
        EverCaesEntlmt5.EntOptions.Match_Contact= false;
        EverCaesEntlmt5.EntOptions.Match_Location= true;
        newObjCP.SVMXC__Start_Date__c = Date.today();
        newObjCP.SVMXC__End_Date__c =  Date.today();
        EverCaesEntlmt5.selectValidSLA(Date.today(), newObjCP,TempRecord, mapServiceContractIDANDCoveredProd );
        EverCaesEntlmt5.selectValidLocation(Date.today(), newObjCP,TempRecord, mapServiceContractIDANDCoveredProd );
        
        EverCaesEntlmt5.EntOptions.Match_Account= true;
        EverCaesEntlmt5.EntOptions.Match_Contact= false;
        EverCaesEntlmt5.EntOptions.Match_Location= false;
        EverCaesEntlmt5.EntOptions.Chk_Part_Number = true;
        EverCaesEntlmt5.Setng_EntitleUsingDateFld = null;
        date newDate = date.newInstance(2015, 11, 21);
        newObjCP.SVMXC__Start_Date__c = Date.today();
        newObjCP.SVMXC__End_Date__c = newDate;
        EverCaesEntlmt5.selectValidLocation(Date.today(), newObjCP,TempRecord, mapServiceContractIDANDCoveredLoc );
        
        
        EverCaesEntlmt5.Setng_ApplicableSLACovLevel = 'Contract';
        EverCaesEntlmt5.strLocId = '123';
        EverCaesEntlmt5.EntOptions.Show_Expired_Entitlement = false;
        EverCaesEntlmt5.SVMX_doCheckEntitlement();
        EverCaesEntlmt5.SelectedEntType = 'Product';
        EverCaesEntlmt5.SVMX_doCheckEntitlement();
        
    }
    
     static testMethod void EVER_CaseEntitlement_Test8()
    {
        Account account = new Account( Name ='Account',ShippingStreet='ABC',ShippingCity='PQR ',ShippingState = 'XYZ',ShippingPostalCode='111',ShippingCountry='XYZ',BillingStreet='ABC',BillingCity='PQR ',BillingState = 'XYZ',BillingPostalCode='111',BillingCountry='XYZ'); 
        insert account;
        
        Contact contact = new Contact(LastName='Last',AccountId =account.Id,Email='svmxmailfortest@servicemax.com');
        insert contact;
        
        SVMXC__Service_Level__c SLA_TERMP = new SVMXC__Service_Level__c (Name = 'SLA_TERMP',SVMXC__Active__c = true);
        insert SLA_TERMP ; 

        SVMXC__Service_Level__c SLA_TERML = new SVMXC__Service_Level__c (Name = 'SLA_TERML',SVMXC__Active__c = true);
        insert SLA_TERML ;
        
        SVMXC__Service_Level__c SLA_TERMC = new SVMXC__Service_Level__c (Name = 'SLA_TERMC',SVMXC__Active__c = true);
        insert SLA_TERMC ;
        
        SVMXC__Service_Contract__c Current_SC= new SVMXC__Service_Contract__c(Name ='Current_SC',SVMXC__Service_Level__c = SLA_TERMC.Id,SVMXC__Start_Date__c    = System.Today(),SVMXC__End_Date__c = System.Today()+1, SVMXC__Contact__c = contact.Id,SVMXC__Company__c = account.Id,SVMXC__Active__c = true);
        insert Current_SC; 
        
        SVMXC__Service_Contract__c NoSLACurrent_SC= new SVMXC__Service_Contract__c(Name ='Current_SC',SVMXC__Service_Level__c = SLA_TERMC.Id,SVMXC__Start_Date__c    = System.Today(),SVMXC__End_Date__c = System.Today()+1, SVMXC__Contact__c = contact.Id,SVMXC__Company__c = account.Id,SVMXC__Active__c = true);
        insert NoSLACurrent_SC; 
        
        Product2 prod1 = new Product2(Name = 'Prod1',ProductCode = '1234-1', Family = 'Accessory',SVMXC__Product_Line__c = 'Laptop', SVMXC__Inherit_Parent_Warranty__c =false );
        insert prod1;
        
        SVMXC__Installed_Product__c IB0 = new SVMXC__Installed_Product__c(Name = 'IB0',SVMXC__Product__c = prod1.Id, SVMXC__Company__c = account.Id  , SVMXC__Contact__c =contact.Id,SVMXC__Status__c = 'Installed',SVMXC__Serial_Lot_Number__c = 'Test2', SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today(),SVMXC__Country__c='United States'); 
        insert IB0;
        
        SVMXC__Site__c objLoc = new SVMXC__Site__c();
        objLoc.SVMXC__City__c = 'Bangalore';
        insert objLoc;
        
        SVMXC__Installed_Product__c IB1 = new SVMXC__Installed_Product__c(Name = 'IB1', SVMXC__Site__c = objLoc.Id, SVMXC__Company__c = account.Id , SVMXC__Contact__c =contact.Id, SVMXC__Status__c = 'Installed',SVMXC__Serial_Lot_Number__c = 'Test2', SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today(),SVMXC__Country__c='United States'); 
        insert IB1;
        
        SVMXC__Service_Contract_Products__c newObjCP = new SVMXC__Service_Contract_Products__c();
        newObjCP.SVMXC__Service_Contract__c = Current_SC.Id;
        newObjCP.SVMXC__Installed_Product__c = IB1.id;
        newObjCP.SVMXC__SLA_Terms__c = SLA_TERMP.id;
        
        SVMXC__Service_Contract_Products__c newObjCP1 = new SVMXC__Service_Contract_Products__c();
        newObjCP1.SVMXC__Service_Contract__c = Current_SC.Id;
        newObjCP1.SVMXC__Installed_Product__c = IB1.id;
        insert newObjCP1;
        
        SVMXC__Service__c objService = new SVMXC__Service__c();
        objService.Name = 'service';
        objService.SVMXC__Active__c = true;
        objService.SVMXC__Tracked_On__c = 'Case';
        insert objService;
        
        
        SVMXC__Service_Contract_Services__c isObj = new SVMXC__Service_Contract_Services__c();
        isObj.SVMXC__Service_Contract__c = Current_SC.Id;
        isObj.SVMXC__Service__c = objService.Id;
        insert isObj;
        
        SVMXC__Service_Contract_Sites__c  covLoc = new SVMXC__Service_Contract_Sites__c();
        covLoc.SVMXC__Service_Contract__c = Current_SC.Id;
        covLoc.SVMXC__Site__c = objLoc.Id;
        covLoc.SVMXC__SLA_Terms__c = SLA_TERML.id;
        covLoc.SVMXC__Start_Date__c = Date.today();
        covLoc.SVMXC__End_Date__c = Date.today();
        insert covLoc;
        
        SVMXC__Service_Contract_Sites__c  noSLAdatecovLoc = new SVMXC__Service_Contract_Sites__c();
        noSLAdatecovLoc.SVMXC__Service_Contract__c = Current_SC.Id;
        noSLAdatecovLoc.SVMXC__Site__c = objLoc.Id;
        insert noSLAdatecovLoc;
        
        SVMXC__Service_Contract_Sites__c  noSLAcovLoc = new SVMXC__Service_Contract_Sites__c();
        noSLAcovLoc.SVMXC__Service_Contract__c = Current_SC.Id;
        noSLAcovLoc.SVMXC__Site__c = objLoc.Id;
        
        insert noSLAcovLoc;
        
        SVMXC__Service_Template__c WT1  =new SVMXC__Service_Template__c(SVMXC__Walk_in_Allowed__c =false,SVMXC__Unit_of_Time__c = '100', SVMXC__Unit_of_Time_Material__c= 'Days', SVMXC__Unit_of_Time_Expenses__c='Months', SVMXC__Transferable__c=false, SVMXC__Time_Covered__c=100, SVMXC__Template_Type__c='Warranty', SVMXC__Shipment_Allowed__c=false, SVMXC__RMA_Required__c=true, SVMXC__Onsite_Repair__c=true,SVMXC__Material_Covered__c=100,  SVMXC__Loaner_Provided__c=false, SVMXC__Invoice_Required__c=false, SVMXC__Expenses_Covered__c=100, SVMXC__Duration_of_Time_Coverage__c=100, SVMXC__Duration_of_Material_Coverage__c=365, SVMXC__Duration_of_Expenses__c=52, SVMXC__Coverage_Effective_From__c='Install Date', SVMXC__All_Services_Covered__c=false, SVMXC__All_Products_Covered__c=false, Name ='Template1');
        insert WT1;
        
        
        Map<String, SVMXC__Service_Contract_Sites__c> mapServiceContractIDANDCoveredProd = new  Map<String, SVMXC__Service_Contract_Sites__c> ();
        mapServiceContractIDANDCoveredProd.put(Current_SC.Id, covLoc);
        mapServiceContractIDANDCoveredProd.put(NoSLACurrent_SC.ID,noSLAcovLoc );
        mapServiceContractIDANDCoveredProd.put(noSLAdatecovLoc.ID,noSLAdatecovLoc );
                
        SVMXC__Service_Order__c Workorder  = new SVMXC__Service_Order__c();
        Workorder.SVMXC__Company__c  = account.Id;
        Workorder.SVMXC__Contact__c = contact.Id;
        Workorder.SVMXC__Component__c = IB1.Id;  
        Workorder.SVMXC__Product__c = prod1.id;
        Workorder.SVMXC__Service_Contract__c = Current_SC.id;
        Workorder.SVMXC__Site__c = objLoc.Id;
        insert Workorder;
        List<SVMXC__Service_Order__c> lstWOHdr = new List<SVMXC__Service_Order__c>();
        lstWOHdr.add(Workorder);
        
        SVMXC.EVER_SCResults TempRecord = new SVMXC.EVER_SCResults();
        System.currentPageReference().getParameters().put('cid', Workorder.Id);
        EVER_CaseEntitlement EverCaesEntlmt5 = new EVER_CaseEntitlement();
        
        EverCaesEntlmt5.EntOptions.Match_Account= true;
        EverCaesEntlmt5.EntOptions.Match_Contact= true;
        EverCaesEntlmt5.EntOptions.Match_Location= true;
        EverCaesEntlmt5.EntOptions.Chk_Part_Number = true;
        EverCaesEntlmt5.Setng_EntitleUsingDateFld = null;
        EverCaesEntlmt5.selectValidLocation(Date.today(), newObjCP,TempRecord, mapServiceContractIDANDCoveredProd );
        
        EVER_CaseEntitlement EverCaesEntlmt7 = new EVER_CaseEntitlement();
        EverCaesEntlmt7.EntOptions.Match_Account= true;
        EverCaesEntlmt7.EntOptions.Match_Contact= false;
        EverCaesEntlmt7.EntOptions.Match_Location= false;
        EverCaesEntlmt7.selectValidLocation( Date.today(), newObjCP1,TempRecord, mapServiceContractIDANDCoveredProd );
        
        EverCaesEntlmt5.EntOptions.Match_Account= true;
        EverCaesEntlmt5.EntOptions.Match_Contact= false;
        EverCaesEntlmt5.EntOptions.Match_Location= false;
        EverCaesEntlmt5.EntOptions.Chk_Part_Number = true;
        EverCaesEntlmt5.Setng_EntitleUsingDateFld = null;
        date newDate = date.newInstance(2015, 11, 21);
        newObjCP.SVMXC__Start_Date__c = Date.today();
        newObjCP.SVMXC__End_Date__c = newDate;
        EverCaesEntlmt5.selectValidLocation(Date.today(), newObjCP,TempRecord, null);
        
        
    }
}