@isTest(SeeAllData=true)
Private class IPRD_WarrantyDefinition_UT {

    static testMethod void IPRD_WarrantyDefinition_test()
    {
                SVMXC__Service_Template__c seed1 = new SVMXC__Service_Template__c(
                                            Name ='TEST: 001',
                                            Coverage_Effective_From2__c='SVMXC__Date_Shipped__c'                                    
                                            );
                insert seed1;
        test.starttest();
        SVMXC.IPRD_WarrantyDefinition myPageConW = new SVMXC.IPRD_WarrantyDefinition();        
        System.currentPageReference().getParameters().put('wid', seed1.Id);
        SVMXC.IPRD_WarrantyDefinition myPageCon = new SVMXC.IPRD_WarrantyDefinition();
        System.assertNotEquals(System.currentPageReference().getParameters().get('wid'),null);
        {
        myPageCon.getTAG030();
        myPageCon.getTAG021();
        myPageCon.getTAG022();
        myPageCon.getTAG023();
        myPageCon.getTAG024();
        myPageCon.getTAG025();
        myPageCon.getTAG026();
        myPageCon.getTAG027();
        myPageCon.getHLPURL();
        //myPageCon.svmxTagList.clear();
        myPageCon.getTAG030();
        myPageCon.getTAG021();
        myPageCon.getTAG022();
        myPageCon.getTAG023();
        myPageCon.getTAG024();
        myPageCon.getTAG025();
        myPageCon.getTAG026();
        myPageCon.getTAG027();
        myPageCon.getHLPURL();
        }
        {
        myPageCon.getIsValid();
        system.assert(myPageCon.getIsValid()==true);
        myPageCon.getWId();
        System.assertNotEquals(myPageCon.getWId(),null);
        myPageCon.getDatec();
        myPageCon.setDatec('TEST');
        myPageCon.getwarrantyTerm();
        myPageCon.getAvailDate();
        }
        myPageCon.GoSave();
        myPageCon.GoBack();
        test.stoptest();
    }
}