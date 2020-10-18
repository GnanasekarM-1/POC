@isTest(seeAllData = false)
private class InstalledBaseTree_UT{
    static String insertAccount(){
        
        Account acc = new Account();
        acc.Name = 'ut account';
        
        
        try{
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( acc, COMM_SecurityUtils.Access.Createable ) ) {
                upsert acc;
            } 
            return acc.id;
        }
        catch(Exception ex){
            return 'Error msg';
        }

    }
     static String insertLocationRecordForTree(String accId){
        
        SVMXC__Site__c siteInsert = new SVMXC__Site__c();
        siteInsert.Name = 'Location';
        siteInsert.SVMXC__Account__c = accId;
        
        try{
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( siteInsert, COMM_SecurityUtils.Access.Createable ) ) {
                upsert siteInsert;
            } 
            return siteInsert.id;
        }
        catch(Exception ex){
            return 'Error msg';
        }

    }

    static String insertConfigDataForTree(String accId, String locId){
        
        SVMXC__Installed_Product__c iBInsert = new SVMXC__Installed_Product__c();
        iBInsert.Name = 'IB tree ';
        iBInsert.SVMXC__Company__c = accId;
        iBInsert.SVMXC__Site__c = locId;
        
        
        try{
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( iBInsert, COMM_SecurityUtils.Access.Createable ) ) {
                upsert iBInsert;
            } 
            return iBInsert.id;
        }
        catch(Exception ex){
            return 'Error msg';
        }

    }

    static String insertConfigData(){
        
        SVMXC__Installed_Product__c iBInsert = new SVMXC__Installed_Product__c();
        iBInsert.Name = 'IB tree ';
        
       
        try{
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( iBInsert, COMM_SecurityUtils.Access.Createable ) ) {
                upsert iBInsert;
            } 
            return iBInsert.id;
        }
        catch(Exception ex){
            return 'Error msg';
        }

    }

    static String insertLocationRecord(){
        
        SVMXC__Site__c siteInsert = new SVMXC__Site__c();
        siteInsert.Name = 'Location';
        
        
        try{
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( siteInsert, COMM_SecurityUtils.Access.Createable ) ) {
                upsert siteInsert;
            } 
            return siteInsert.id;
        }
        catch(Exception ex){
            return 'Error msg';
        }

    }

    static String insertUserPreferenceRecord(){
        
        SVMXC__SM_User_Preferences__c userPref = new SVMXC__SM_User_Preferences__c();
        String userId = UserInfo.getUserId();
        userPref.SVMXC__SM_User_Reference_Id__c = userId;
        userPref.SVMXC__SM_Type__c = 'IBTreeWeb';
        userPref.SVMXC__SM_Configured_Columns__c = '{"objectN":"IB","columnToDisplay":[{"fieldname":"SVMXC__Product_Name__c","fieldlabel":"Product Name"}]}';
        
        try{
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( userPref, COMM_SecurityUtils.Access.Createable ) ) {
                upsert userPref;
            } 
            return userPref.id;
        }
        catch(Exception ex){
            return 'Error msg';
        }

    }
    static testMethod void testIBTreeData(){
        String acc = insertAccount();
        String loc = insertLocationRecordForTree(acc);
        String ib =  insertConfigDataForTree(acc,loc);
        
        String requestIb = '{\"recordId\":\"'+ib+'\",\"reload\":false}';
         String requestLoc = '{\"recordId\":\"'+loc+'\",\"reload\":false}';
        SVMXC.InstalledBaseTree.JsrGetTreeViewData(requestIb);
        SVMXC.InstalledBaseTree.JsrGetLocationTreeViewData(requestLoc);
    }

    static testMethod void getIBTreeData1(){
        String iBId = insertConfigData();
        String prefId = insertUserPreferenceRecord();
        String request = '"{"recordId":"'+iBId+'","reload":false}"';
        SVMXC.InstalledBaseTree.JsrGetTreeViewData(request);
    }

    static testMethod void getLocationTreeData(){
        String siteId = insertLocationRecord();
        SVMXC.InstalledBaseTree.JsrGetLocationTreeViewData(siteId);
    }

    static testMethod void getMetaData(){
        
        SVMXC.InstalledBaseTree.JsrGetMetadata('');
    }

    static testMethod void saveConfiguredColumn1(){

        String columnsJson = '{"objectName":"IB","columnToDisplay":[{"fieldname":"SVMXC__Product_Name__c","fieldlabel":"Product Name"}]}';
        SVMXC.InstalledBaseTree.JsrSaveConfiguredColumnsForIB(columnsJson);
    }

    static testMethod void saveConfiguredColumn2(){
        String prefId = insertUserPreferenceRecord();
        String columnsJson = '{"objectN":"IB","columnToDisplay":[{"fieldname":"SVMXC__Product_Name__c","fieldlabel":"Product Name"}]}';
        SVMXC.InstalledBaseTree.JsrSaveConfiguredColumnsForIB(columnsJson);
    }
    static testMethod void test_getChildren(){
        String acc = insertAccount();
        String loc = insertLocationRecordForTree(acc);
        String ib =  insertConfigDataForTree(acc,loc);
        
        String iBrequest = '{"objType":"SVMXC__Installed_Product__c","index":40,"recordsLimit":40,"topLevelIb":null,"treeType":"SVMXC__Installed_Product__c","isIB":false,"ibIndex":0,"sfdcId":"'+ib+'"}';
        String locationrequest = '{"objType":"SVMXC__Site__c","index":40,"recordsLimit":40,"topLevelIb":null,"treeType":"SVMXC__Installed_Product__c","isIB":false,"ibIndex":0,"sfdcId":"'+loc+'"}';
        SVMXC.InstalledBaseTree.JsrGetChildren('');
        SVMXC.InstalledBaseTree.JsrGetChildren(iBrequest);
        SVMXC.InstalledBaseTree.JsrGetChildren(locationrequest);
        

    }
    static testMethod void test_InstalledBaseTreeConfiguration(){
        SVMXC.InstalledBaseTreeConfiguration.Node objNode = new SVMXC.InstalledBaseTreeConfiguration.Node();
        

    }
    

}