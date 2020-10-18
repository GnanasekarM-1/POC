@isTest(SeeAllData=true)
private class SMAX_PRM_Controller {
    private String SVMXC_getAccountForContact(String arg1){
        return null;
    }
    private String SVMXC_getPartnerUserContact(String arg1){
        return null;
    }
    
    static testMethod void testSVMXC_getPartnerUserContact (){
        test.starttest();
        User usr1 = [SELECT Id FROM User Limit 1];
        String PrtUsrContct = new SMAX_PRM_Controller().SVMXC_getPartnerUserContact(usr1.Id);
        system.assert(PrtUsrContct==null,'SVMXC_getPartnerUserContact fails');
        Account act = New Account (Name='testAcct');
        Contact ct1 = new Contact (LastName = 'lName', FirstName='fName', AccountId = act.Id);
        String AccForContact  = new SMAX_PRM_Controller().SVMXC_getAccountForContact(ct1.Id);
        system.assert(AccForContact==null,'SVMXC_getAccountForContact fails');
        Case cs = new Case (Status='New', Origin='Phone');
        
        //Trigger SVMXC_workOrderIsPartner Test
        SVMXC__Service_Order__c svo = new SVMXC__Service_Order__c(SVMXC__Priority__c ='High',SVMXC__Order_Type__c ='Return Only',SVMXC__Order_Status__c ='Open',SVMXC__Contact__c =ct1.Id,SVMXC__Company__c = act.Id,SVMXC__Case__c =cs.Id);
        insert svo;
        System.assertEquals('High', svo.SVMXC__Priority__c);
        //Trigger SVMXC_partsOrderIsPartner Test
        SVMXC__RMA_Shipment_Order__c  po = new SVMXC__RMA_Shipment_Order__c (SVMXC__Order_Status__c ='Open',SVMXC__Contact__c =ct1.Id,SVMXC__Company__c = act.Id,SVMXC__Case__c =cs.Id);
        insert po;
        System.assertEquals(ct1.Id, po.SVMXC__Contact__c);
        test.stoptest();
    }
}