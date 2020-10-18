@isTest(SeeAlldata=true)
private class PREV_ManagePMPlans_UT
{
    private static SVMXC.PREV_ManagePMPlans PMObject,PMObjecttwo; 
    
    
    static testMethod void PREV_ManagePMPlans_UT()
    {
         Account account = new Account(
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
        SVMXC__Service_Level__c sconSLA = new SVMXC__Service_Level__c(
                                        
                                        SVMXC__Active__c=true,
                                        SVMXC__Description__c = 'Test Desc',
                                        SVMXC__Effective_Date__c=System.today()
                                        
                                        );
        insert sconSLA;
        system.assertEquals('Test Desc', sconSLA.SVMXC__Description__c);
        SVMXC__Service_Contract__c SconObject = new SVMXC__Service_Contract__c(
                                             
                                             Name='ZZ1',
                                             SVMXC__Company__c=account.Id,
                                             SVMXC__End_Date__c=System.today(),
                                             SVMXC__Start_Date__c=System.today(),
                                             SVMXC__Service_Level__c= sconSLA.id
                                              );
        insert SconObject;
        List<SVMXC__PM_Plan__c> PMLst = new List<SVMXC__PM_Plan__c>();
        SVMXC__PM_Plan__c pmplan = new SVMXC__PM_Plan__c(
                                
                                        Name = 'PM Plan',
                                        SVMXC__Service_Contract__c = SconObject.id
                                        );
                                        
        insert pmplan;
        System.assertEquals('PM Plan', pmplan.name);
        PMLst.add(pmplan);
        test.startTest();
        PageReference pageRef = new PageReference('Page.SVMXC.PREV_ManagePMPlans');
        pageRef.getParameters().put('scid',SconObject.Id);
        Test.setCurrentPage(pageRef);
        
        PMObject = new SVMXC.PREV_ManagePMPlans();
        PMObject.getPMPlans();
        PMObject.SVMX_checkBoxValidation = false;
        pageReference p1 = PMObject.SVMX_NewPMPlan();
        
        SVMXC__PM_Plan__c pmplantwo = new SVMXC__PM_Plan__c(
                                
                                        Name = 'PM Plan two',
                                        SVMXC__Select__c =true,
                                        SVMXC__Service_Contract__c = SconObject.id
                                        );
                                        
        insert pmplantwo;
        System.assertEquals('PM Plan two', pmplantwo.name);
        PMObject.PMPlan.add(pmplantwo);
        pageReference p4 = PMObject.SVMX_ClonePMPlan();
        pageReference p2 = PMObject.SVMX_EditPMPlan();
        pageReference p3 = PMObject.SVMX_DeletePMPlan();
        pageReference p5 = PMObject.SVMX_BackToSC();
        boolean b1 = PMObject.SVMX_IsValidID(SconObject.Id);
        boolean b2 = PMObject.SVMX_checkBoxValidation();
        boolean b3 = PMObject.getHdrMsg();
        boolean b4 = PMObject.getDisplayRecord();
        PMObject.getSContract();
        PMObject.setSContract(SconObject);
        PMObject.setPMPlans(PMLst);
       SVMXC__PM_Plan__c pmplanthree = new SVMXC__PM_Plan__c(
                                
                                        Name = 'PM Plan three',
                                        SVMXC__Select__c =true,
                                        SVMXC__Service_Contract__c = SconObject.id
                                        );
       insert   pmplanthree;
        System.assertEquals('PM Plan three', pmplanthree.name);
        PMObject.PMPlan.add(pmplanthree);
        pageReference p8 = PMObject.SVMX_ClonePMPlan();
        pageReference p6 = PMObject.SVMX_EditPMPlan();
        pageReference p7 = PMObject.SVMX_DeletePMPlan();
        PageReference pageReftwo = new PageReference('Page.SVMXC.PREV_ManagePMPlans');
        pageRef.getParameters().put('scid','sdfsdfa');
        Test.setCurrentPage(pageRef);
        PMObjecttwo = new SVMXC.PREV_ManagePMPlans(); 
        system.assert(PMObject.getHLPURL()!=null,'TAG001 assertion failed');
        system.assert(PMObject.getTAG002()!=null,'TAG002 assertion failed');
        system.assert(PMObject.getTAG003()!=null,'TAG003 assertion failed');
        system.assert(PMObject.getTAG004()!=null,'TAG004 assertion failed');
        system.assert(PMObject.getTAG005()!=null,'TAG005 assertion failed');
        system.assert(PMObject.getTAG006()!=null,'TAG006 assertion failed');
        system.assert(PMObject.getTAG007()!=null,'TAG007 assertion failed');
        system.assert(PMObject.getTAG008()!=null,'TAG008 assertion failed');
        system.assert(PMObject.getTAG009()!=null,'TAG009 assertion failed');
        system.assert(PMObject.getTAG010()!=null,'TAG010 assertion failed');
        system.assert(PMObject.getTAG011()!=null,'TAG011 assertion failed');
        system.assert(PMObject.getTAG012()!=null,'TAG012 assertion failed');
        system.assert(PMObject.getTAG013()!=null,'TAG013 assertion failed');
        system.assert(PMObject.getTAG014()!=null,'TAG014 assertion failed');
        system.assert(PMObject.getTAG015()!=null,'TAG015 assertion failed');
        system.assert(PMObject.getTAG016()!=null,'TAG016 assertion failed');
        system.assert(PMObject.getTAG017()!=null,'TAG017 assertion failed');
        system.assert(PMObject.getTAG018()!=null,'TAG018 assertion failed');
        system.assert(PMObject.getTAG019()!=null,'TAG019 assertion failed');
        system.assert(PMObject.getTAG020()!=null,'TAG020 assertion failed');
        system.assert(PMObject.getTAG021()!=null,'TAG021 assertion failed');
        system.assert(PMObject.getTAG022()!=null,'TAG022 assertion failed');
        system.assert(PMObject.getTAG023()!=null,'TAG023 assertion failed');
        //PMObject.svmxTagList.clear();
        system.assert(PMObject.getTAG001()!=null,'TAG001 assertion failed');
        system.assert(PMObject.getTAG002()!=null,'TAG002 assertion failed');
        system.assert(PMObject.getTAG003()!=null,'TAG003 assertion failed');
        system.assert(PMObject.getTAG004()!=null,'TAG004 assertion failed');
        system.assert(PMObject.getTAG005()!=null,'TAG005 assertion failed');
        system.assert(PMObject.getTAG006()!=null,'TAG006 assertion failed');
        system.assert(PMObject.getTAG007()!=null,'TAG007 assertion failed');
        system.assert(PMObject.getTAG008()!=null,'TAG008 assertion failed');
        system.assert(PMObject.getTAG009()!=null,'TAG009 assertion failed');
        system.assert(PMObject.getTAG010()!=null,'TAG010 assertion failed');
        system.assert(PMObject.getTAG011()!=null,'TAG011 assertion failed');
        system.assert(PMObject.getTAG012()!=null,'TAG012 assertion failed');
        system.assert(PMObject.getTAG013()!=null,'TAG013 assertion failed');
        system.assert(PMObject.getTAG014()!=null,'TAG014 assertion failed');
        system.assert(PMObject.getTAG015()!=null,'TAG015 assertion failed');
        system.assert(PMObject.getTAG016()!=null,'TAG016 assertion failed');
        system.assert(PMObject.getTAG017()!=null,'TAG017 assertion failed');
        system.assert(PMObject.getTAG018()!=null,'TAG018 assertion failed');
        system.assert(PMObject.getTAG019()!=null,'TAG019 assertion failed');
        system.assert(PMObject.getTAG020()!=null,'TAG020 assertion failed');
        system.assert(PMObject.getTAG021()!=null,'TAG021 assertion failed');
        system.assert(PMObject.getTAG022()!=null,'TAG022 assertion failed');
        system.assert(PMObject.getTAG023()!=null,'TAG023 assertion failed');
        
        //Invoke the getter methods for code coverage.                 
        PMObject.getUserLocaleKey();        
        PMObject.getUserID();        
        PMObject.getUserOrgID();
                
        test.stopTest();
       
        
    }
}