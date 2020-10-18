@isTest(SeeAllData=true)
Private class IPRD_ProductWarranty_UT {

    static testMethod void IPRD_ProductWarranty_test()
    {
        
        SVMXC__Service_Template__c seed1 = new SVMXC__Service_Template__c(
                                    Name ='TEST: 001',
                                    Coverage_Effective_From2__c='SVMXC__Date_Shipped__c'                                    
                                    );
        insert seed1;
        System.assertEquals('TEST: 001', seed1.Name);
        Product2 Product1 = new Product2(Name='test product');
        insert Product1;
        System.assertEquals('test product', Product1.Name);        
        SVMXC__Installed_Product__c inst = new SVMXC__Installed_Product__c(Name='Test',SVMXC__Product__c=Product1.Id);
        insert inst;
        System.assertEquals('Test', inst.Name);  
        Warranty__c ext = new Warranty__c(SVMXC__Installed_Product__c=inst.Id,SVMXC__Service_Template__c=seed1.Id);
        insert ext;
        System.assertEquals(inst.Id, ext.SVMXC__Installed_Product__c);
        test.startTest();
        System.currentPageReference().getParameters().put('PID',inst.Id);
        ApexPages.StandardController extcontroller = new ApexPages.standardController(ext);
        SVMXC.IPRD_ProductWarranty myPageCon = new SVMXC.IPRD_ProductWarranty(extcontroller);
        
        
        String Tag='';
        Tag = myPageCon.getTAG001();
        Tag = myPageCon.getTAG002();
        Tag = myPageCon.getTAG003();
        Tag = myPageCon.getTAG004();
        Tag = myPageCon.getTAG005();
        Tag = myPageCon.getTAG006();
        Tag = myPageCon.getTAG008();
        Tag = myPageCon.getTAG009();
        Tag = myPageCon.getTAG010();
        Tag = myPageCon.getTAG011();
        Tag = myPageCon.getTAG012();
        Tag = myPageCon.getTAG013();
        Tag = myPageCon.getTAG014();
        Tag = myPageCon.getTAG015();
        Tag = myPageCon.getTAG016();
        Tag = myPageCon.getTAG017();
        Tag = myPageCon.getTAG018();
        Tag = myPageCon.getTAG026();
        Tag = myPageCon.getTAG028();
        Tag = myPageCon.getTAG029();
        Tag = myPageCon.getTAG030();
        Tag = myPageCon.getTAG031();
        Tag = myPageCon.getTAG032();
        Tag = myPageCon.getTAG034();
        Tag = myPageCon.getTAG035();
        Tag = myPageCon.getTAG036();
        Tag = myPageCon.getTAG037();
        Tag = myPageCon.getHLPURL();
        Tag = myPageCon.getTAG043();
        //myPageCon.svmxTagList.clear();
        Tag = myPageCon.getTAG001();
        Tag = myPageCon.getTAG002();
        Tag = myPageCon.getTAG003();
        Tag = myPageCon.getTAG004();
        Tag = myPageCon.getTAG005();
        Tag = myPageCon.getTAG006();
        Tag = myPageCon.getTAG008();
        Tag = myPageCon.getTAG009();
        Tag = myPageCon.getTAG010();
        Tag = myPageCon.getTAG011();
        Tag = myPageCon.getTAG012();
        Tag = myPageCon.getTAG013();
        Tag = myPageCon.getTAG014();
        Tag = myPageCon.getTAG015();
        Tag = myPageCon.getTAG016();
        Tag = myPageCon.getTAG017();
        Tag = myPageCon.getTAG018();
        Tag = myPageCon.getTAG026();
        Tag = myPageCon.getTAG028();
        Tag = myPageCon.getTAG029();
        Tag = myPageCon.getTAG030();
        Tag = myPageCon.getTAG031();
        Tag = myPageCon.getTAG032();
        Tag = myPageCon.getTAG034();
        Tag = myPageCon.getTAG035();
        Tag = myPageCon.getTAG036();
        Tag = myPageCon.getTAG037();
        Tag = myPageCon.getTAG043();
        Tag = myPageCon.getHLPURL();
        myPageCon.getIsValid();
        myPageCon.GoCreateW();
        myPageCon.getselectedId();
        myPageCon.setselectedId('test');
        myPageCon.getOtherwarrantyTerm();
        myPageCon.getCoveredwarrantyTerm();
        myPageCon.getIProduct();
        myPageCon.getIsWCreatable();
        myPageCon.getCoveredCount();
        myPageCon.getOtherCount();
        myPageCon.GoBack();
        myPageCon.GoLoader('test');
        myPageCon.getProfDisplayBlockLevelMessage();
        
        test.stopTest();
    }
    
}