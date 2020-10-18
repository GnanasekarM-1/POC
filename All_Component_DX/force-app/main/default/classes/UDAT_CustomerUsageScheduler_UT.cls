@isTest (seeAllData = true)
private class UDAT_CustomerUsageScheduler_UT
{
    static testMethod void customerUsageScheduler_UT_Test()
    {
		/*
        // creating Account
        Account objAcc = new Account();
        objAcc.Name = 'testAcc : '+System.now();
        insert objAcc;

        // creating work Order
        SVMXC__Service_Order__c objWO = new SVMXC__Service_Order__c();
        objWO.SVMXC__Order_Type__c = 'Field Service';
        objWO.SVMXC__Order_Status__c = 'Open';
        Insert objWO;

        SVMXC__Service_Order__c objWO1 = new SVMXC__Service_Order__c();
        objWO1.SVMXC__Order_Type__c = 'Depot Repair';
        objWO1.SVMXC__Order_Status__c = 'Open';
        Insert objWO1;

        // creating work Order Details
        SVMXC__Service_Order_Line__c objWOLins = new SVMXC__Service_Order_Line__c();
        objWOLins.SVMXC__Service_Order__c = objWO.Id;
        objWOLins.SVMXC__Line_Type__c = 'Parts';
        insert objWOLins;

        // creating product and install product
        Product2 objPrdt = new Product2();
        objPrdt.Name = 'TestProduct : '+System.now();
        Insert objPrdt;

        SVMXC__Installed_Product__c objIB = new SVMXC__Installed_Product__c();
        objIB.SVMXC__Product__c = objPrdt.Id;
        objIB.SVMXC__Status__c = 'Installed';
        Insert objIB;
	*/
        Test.starttest();
        UDAT_CustomerUsageScheduler nwObj = new UDAT_CustomerUsageScheduler ();
       /* 
        String OrgId = UserInfo.getOrganizationId();
        Datetime dd = System.now();
        
        Map<String, String> svmxSettingList = new Map<String,String>();
        List<SVMXC__ServiceMax_List__c> lstSvmxlst = new List<SVMXC__ServiceMax_List__c>();
        Map<String, Integer> RcrdCunts = new Map<String, Integer>();
        
        
        svmxSettingList = nwObj.getSetting();
        nwObj.calculateHRD(svmxSettingList);
        lstSvmxlst = nwObj.getRcrdCounts();
        RcrdCunts = nwObj.countObjects(svmxSettingList);
        nwObj.addNSaveCounts(RcrdCunts, lstSvmxlst, svmxSettingList);
        
        Map<String, String> saveRcrdCunts = new Map<String, String>();
        saveRcrdCunts.put('Account','23');
        nwObj.creatXMLNSendMail(svmxSettingList, saveRcrdCunts);
        //nwObj.sendException('testing');
        nwObj.updateLRD(System.now());
        SchedulableContext sc;
        //system.assert(nwObj.execute(sc) == null);
       */
        Test.stoptest();
    }
}