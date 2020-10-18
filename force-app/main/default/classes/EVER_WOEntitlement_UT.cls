@isTest(seeAllData = true)
public class EVER_WOEntitlement_UT {

    Static Map<String,Id> recordTypeIdMap = new Map<String,Id>();
    Static List<String> detailLineIds = new List<String>();
	
    Static testMethod void getSettingsTestMethod(){
    	EVER_WOEntitlementImpl entitlementImpl = new EVER_WOEntitlementImpl();    
        entitlementImpl.AllSubModuleSettings = new Map<String,String>{'SET001' => '', 'SET002' => '', 'SET003' => '', 'SET004' => '', 'SET005' => '',
                                                                    'SET006' => '', 'SET007' => '', 'SET008' => '', 'SET009' => '', 'SET010' => '',
                                                                    'SET011' => '', 'SET012' => '', 'SET013' => '', 'SET016' => '', 'SET017' => '','SET019' => '',
                                                                    'SET020' => '', 'SET021' => '', 'SET022' => '', 'SET023' => '', 'SET024' => '','SET026' => ''
            														};
        Test.StartTest();                                                                
		EVER_WOEntitlement.getWOEntitlementSettings();
        EVER_WrapperDef.EVER_Response response = entitlementImpl.getWOEntitlementSettings();														     
        System.assert(response.entitlementSettings != null, 'Entitlement Settings Cannot be null');
        Test.StopTest();
                                                                          
    }
    
    Static testMethod void getWODetailsTestMethod(){
       getrecordTypes(); 
       Id woId = CreateWorkOrder(); 

       Test.StartTest();
       EVER_WrapperDef.EVER_Request request;
       
       //With Request for header lines  
       request = new EVER_WrapperDef.EVER_Request();
       request.headerId = woId;
       EVER_WOEntitlement.getWorkOrderDetails(JSON.serialize(request));   
       request.entitlementSettings = getEntitlementSettings();
       request.entitlementSettings.entitlementSupportOnLines = 'false'; 
       String requestStr = JSON.serialize(request); 
       EVER_WOEntitlement.getWorkOrderDetails(requestStr); 
        
       //With Request for detail lines
       request.entitlementSettings.entitlementSupportOnLines = 'true';
       Map<Id, SVMXC__Service_Order_Line__c> servicedLineMap = CreateChildLines(woId, 2); 
       requestStr = JSON.serialize(request); 
       EVER_WOEntitlement.getWorkOrderDetails(requestStr);  
       Test.StopTest(); 
    }
    
    static testMethod void checkEntitlementAccountTestMethod(){
		getrecordTypes();        
        Id woId = CreateWorkOrder(); 
       // Map<Id, SVMXC__Service_Order_Line__c> servicedLineMap = CreateChildLines(woId, 2); 
    	EVER_WrapperDef.EVER_Request request = new EVER_WrapperDef.EVER_Request();  
        request.entitlementSettings = getEntitlementSettings();
        request.entitlementSettings.effectiveDateForEntitlement = 'SVMXC__Completed_Date_Time__c';
        request.headerId = woId;
 		request.detailLineIDs = detailLineIds;
        Test.startTest();
        EVER_WOEntitlement.checkEntitlement(JSON.serialize(request));
        
        request.entitlementSettings.effectiveDateForEntitlement = 'today';
        EVER_WOEntitlement.checkEntitlement(JSON.serialize(request));
        
        //For Header
        request.entitlementSettings.entitlementSupportOnLines = 'false';
        EVER_WOEntitlement.checkEntitlement(JSON.serialize(request));
        Test.stopTest();
    } 

    static testMethod void checkEntitlementProductTestMethod(){
        getrecordTypes();
        Id woId = CreateWorkOrder(); 
      //  Map<Id, SVMXC__Service_Order_Line__c> servicedLineMap = CreateChildLines(woId, 2); 
    	EVER_WrapperDef.EVER_Request request = new EVER_WrapperDef.EVER_Request();  
        request.entitlementSettings = getEntitlementSettings();
        request.entitlementSettings.entitleUsingAccountOrProduct = 'Product';
        request.headerId = woId;

 		request.detailLineIDs = detailLineIds;
        Test.startTest();
        EVER_WOEntitlement.checkEntitlement(JSON.serialize(request));
        
        //For Header
        request.entitlementSettings.entitlementSupportOnLines = 'false';
        request.entitlementSettings.showExpiredEntitlement = 'false';
        request.entitlementSettings.showFutureEntitlement = 'false';
        request.entitlementSettings.sLAandValidityLevels = 'Contract';
        EVER_WOEntitlement.checkEntitlement(JSON.serialize(request));        
        
        Test.stopTest();
    } 
    

    static testMethod void SaveEntitlementTestMethod(){
        getrecordTypes();
        Id woId = CreateWorkOrder(); 
       // Map<Id, SVMXC__Service_Order_Line__c> servicedLineMap = CreateChildLines(woId, 2); 
    	EVER_WrapperDef.EVER_Request request = new EVER_WrapperDef.EVER_Request();  
        request.entitlementSettings = getEntitlementSettings();
        request.entitlementSettings.entitleUsingAccountOrProduct = 'Product';
        request.headerId = woId;
 		request.detailLineIDs = detailLineIds;
        EVER_WrapperDef.EVER_InfoMap infoHeader = new EVER_WrapperDef.EVER_InfoMap();
        infoHeader.recordID = detailLineIds[0];
        infoHeader.entitlementInfo = getEntitlementInfo();
        List<EVER_WrapperDef.EVER_InfoMap> tempInfoList = new List<EVER_WrapperDef.EVER_InfoMap>();
        tempInfoList.add(infoHeader);
        request.entitlementInfoMap = tempInfoList;
        Test.startTest();
        EVER_WOEntitlement.saveEntitlement(JSON.serialize(request));
        
        //For Header
		infoHeader = new EVER_WrapperDef.EVER_InfoMap();
        infoHeader.recordID = woId;
        infoHeader.entitlementInfo = getEntitlementInfo();
        tempInfoList = new List<EVER_WrapperDef.EVER_InfoMap>();
        tempInfoList.add(infoHeader); 
        request.entitlementInfoMap = tempInfoList;
        request.entitlementSettings.entitlementSupportOnLines = 'false';
        EVER_WOEntitlement.saveEntitlement(JSON.serialize(request));  
        
        EVER_WOEntitlement.getWorkOrderDetails(JSON.serialize(request));
        Test.stopTest();
    }

    Static testMethod void getEntitlementHistoryTestMethod() {
        getrecordTypes();
        ID woId = CreateWorkOrder();
        EVER_WrapperDef.EVER_Request request = new EVER_WrapperDef.EVER_Request();  
        request.entitlementSettings = getEntitlementSettings();
        request.entitlementSettings.entitleUsingAccountOrProduct = 'Product';
        request.headerId = woId;
        insertEntitlementHistory(woId,'WO');
        //EVER_WOEntitlementImpl WOEntitlementImpl = new EVER_WOEntitlementImpl();
        //WOEntitlementImpl.AllSubModuleSettings.put('SET024','False');
        EVER_WOEntitlement.getEntitlementHistory(JSON.serialize(request));
    } 
    
    Static EVER_WrapperDef.EVER_EntitlementInfo getEntitlementInfo(){
        SVMXC__Warranty__c warrantyRec = [SELECT Id,Name, SVMXC__Start_Date__c, SVMXC__End_Date__c FROM SVMXC__Warranty__c limit 1];
        EVER_WrapperDef.EVER_EntitlementInfo entitlementInfo = new EVER_WrapperDef.EVER_EntitlementInfo();
        entitlementInfo.warrantyOrScon = 'warranty';
        entitlementInfo.recordId = warrantyRec.Id;
        entitlementInfo.startDate = (warrantyRec.SVMXC__Start_Date__c != null) ? warrantyRec.SVMXC__Start_Date__c.format(): null;
        entitlementInfo.endDate = (warrantyRec.SVMXC__End_Date__c != null) ? warrantyRec.SVMXC__End_Date__c.format(): null;
        entitlementInfo.recordName = warrantyRec.Name;
    	return entitlementInfo;     
    }
    
    Static EVER_WrapperDef.EVER_Settings getEntitlementSettings(){
        EVER_WrapperDef.EVER_Settings entitlementSettings = new EVER_WrapperDef.EVER_Settings();
        entitlementSettings.showFutureEntitlement = 'true';
        entitlementSettings.entitlementSupportOnLines = 'true';
        entitlementSettings.matchContact = 'true';
        entitlementSettings.matchLocation = 'true';
        entitlementSettings.showExpiredEntitlement = 'true';
        entitlementSettings.showFutureEntitlement = 'true';
        entitlementSettings.entitleUsingAccountOrProduct = 'Account';
        entitlementSettings.coverageOnParentProduct = 'true';
        entitlementSettings.coverageOnTopLevelProduct = 'true';
        entitlementSettings.coverageOnChildProduct = 'true';
        entitlementSettings.sLAandValidityLevels = 'Product';
        entitlementSettings.matchAccount = 'true';
        entitlementSettings.coverageOnPartProduct = 'true';
        entitlementSettings.coverageOnProductFamily = 'true';
        entitlementSettings.coverageOnProductLine = 'true';
        entitlementSettings.noOfChildLevelItr = '1';
        entitlementSettings.effectiveDateForEntitlement = 'today';
        entitlementSettings.setBillingType = 'true';
        entitlementSettings.serviceBasedEntitlement = 'true';
        entitlementSettings.showAllServices = 'true';
        entitlementSettings.entUsingWarrantyOrSC = 'BOTH';
        entitlementSettings.considerCountersOrDates = 'BOTH';
        return entitlementSettings;
    }
    
    static Id CreateWorkOrder(){
        SVMXC__Service_Order__c woRecord = new SVMXC__Service_Order__c(SVMXC__Order_Status__c = 'Open');	
        woRecord.SVMXC__Company__c = InsertAccount();
        woRecord.SVMXC__Contact__c = InsertContact();
        woRecord.SVMXC__Site__c = InsertLocation();
       
        woRecord.SVMXC__Component__c = InsertComponent();
        Id sconId = InsertScontract(woRecord.SVMXC__Company__c);
        Id covLocId =InsertCoveredLocation( woRecord.SVMXC__Site__c,sconId);
        Id covContact = InsertCoveredContact (woRecord.SVMXC__Contact__c, sconId);
        Id covProduct = InsertCoveredProduct(woRecord.SVMXC__Component__c,sconId);
        Id warrantyId = InsertWarranties(woRecord.SVMXC__Component__c);
        insert woRecord;
        Map<Id, SVMXC__Service_Order_Line__c> servicedLineMap = CreateChildLines(woRecord.Id,2);
        for(Id lineID : servicedLineMap.keySet()){
            detailLineIds.add(lineID);
            covProduct = InsertCoveredProduct(servicedLineMap.get(lineID).SVMXC__Serial_Number__c,sconId);
        }
        return woRecord.Id;
    }
    
    Static Id InsertCoveredProduct(Id componentId, Id sConId){
        SVMXC__Service_Contract_Products__c covProd = new SVMXC__Service_Contract_Products__c();
        covProd.SVMXC__Installed_Product__c = componentId;
        covProd.SVMXC__Service_Contract__c = sConId;
        covProd.SVMXC__Start_Date__c = system.today() + 9;
        covProd.SVMXC__End_Date__c = system.today() + 20;
        insert covProd;
        return covProd.Id;
    }
    
    Static List<SVMXC__Installed_Product__c> InsertTopComponents(){
        List<SVMXC__Installed_Product__c> lstInstalledProduct = new List<SVMXC__Installed_Product__c>(); 
        SVMXC__Installed_Product__c installedProduct1 = new SVMXC__Installed_Product__c();
        installedProduct1.SVMXC__Product__c = InsertProduct('Top');
        lstInstalledProduct.add(installedProduct1);
        
        SVMXC__Installed_Product__c installedProduct2 = new SVMXC__Installed_Product__c();
        installedProduct2.SVMXC__Product__c = InsertProduct('Parent');
        lstInstalledProduct.add(installedProduct2);

        insert lstInstalledProduct;
        return lstInstalledProduct;
    }
    
    Static Id InsertComponent(){
        SVMXC__Installed_Product__c installedProduct = new SVMXC__Installed_Product__c();
        installedProduct.SVMXC__Product__c = InsertProduct('BaseProduct');
        List<SVMXC__Installed_Product__c> topComponentsList = InsertTopComponents();
        installedProduct.SVMXC__Parent__c = topComponentsList[0].Id;
        installedProduct.SVMXC__Top_Level__c = topComponentsList[1].Id;
        insert installedProduct;
        InsertChildIBs(installedProduct.Id);
        return installedProduct.Id;
    }
    
 
    Static void InsertChildIBs(Id parentIbId){
        SVMXC__Installed_Product__c installedProduct = new SVMXC__Installed_Product__c();
        installedProduct.SVMXC__Product__c = InsertProduct('ChildProduct');
		installedProduct.SVMXC__Parent__c = parentIbId;
        insert installedProduct;
    }
    
    Static Id InsertWarranties(Id componentId){
        SVMXC__Warranty__c warrantyRec = new SVMXC__Warranty__c();
        warrantyRec.SVMXC__Start_Date__c = System.today() - 10;
        warrantyRec.SVMXC__End_Date__c = System.today() + 10;
        warrantyRec.SVMXC__Installed_Product__c = componentId;
        insert warrantyRec;
        return warrantyRec.Id;
    }
    
    Static Id InsertProduct(String productName){
    	Product2 productRec = new Product2(SVMXC__Product_Line__c = 'Testing',Name = productName, Family = 'TestFamily');
        insert productRec;
        return productRec.Id;
    }
    
    Static Id InsertCoveredLocation(Id loc, Id conID){
    	SVMXC__Service_Contract_Sites__c covLoc = new SVMXC__Service_Contract_Sites__c();
        covLoc.SVMXC__Service_Contract__c = conID;
        covLoc.SVMXC__Site__c = loc;
        covLoc.SVMXC__Start_Date__c = System.today() + 9;
        covLoc.SVMXC__End_Date__c = System.today() + 20;
        insert covLoc;
        return covLoc.Id;
    }
    
    Static Id InsertCoveredContact(Id contactId, Id conID){
        SVMXC__Service_Contract_Contacts__c covContact = new SVMXC__Service_Contract_Contacts__c();
        covContact.SVMXC__Service_Contract__c = conID;
        covContact.SVMXC__Contact__c = contactId;
        insert covContact;
        return covContact.Id;
    }
    
    Static Id InsertScontract(Id accountID){
    	SVMXC__Service_Contract__c scons = new SVMXC__Service_Contract__c();
        scons.SVMXC__Company__c = accountID;
        scons.SVMXC__Active__c = true;
        scons.SVMXC__Start_Date__c = System.today() -10;
		scons.SVMXC__End_Date__c = System.today() + 10;
        insert scons;
        InsertCoveredServices(scons.Id);
        return scons.Id;
    }
    
    Static void InsertCoveredServices(Id sconID){
        SVMXC__Service__c serviceType = new SVMXC__Service__c();
        serviceType.SVMXC__Active__c = true;
        serviceType.SVMXC__Effective_Date__c = System.today()-20;
        serviceType.SVMXC__Service_Type__c = 'Repair';
        serviceType.SVMXC__Tracked_On__c = 'Work Order';
        insert serviceType; 
        List<SVMXC__Service_Contract_Services__c> covServicesList = new List<SVMXC__Service_Contract_Services__c>();
        for(integer i=0; i<2; i++){
        	SVMXC__Service_Contract_Services__c covServices = new SVMXC__Service_Contract_Services__c();
            covServices.SVMXC__Service_Contract__c = sconID;
            covServices.SVMXC__Included_Units__c = 2;
            covServices.SVMXC__Consumed_Units__c = 1;
            covServices.SVMXC__Service__c = serviceType.Id;
            covServicesList.add(covServices);
        }  
        insert covServicesList;
    }
    
    Static Id InsertAccount(){
        Account acc = new Account(Name='Test Account');
        insert acc;
        return acc.id;
    }
    
    Static Id InsertContact(){
        Contact con = new Contact(LastName = 'Test Contact');
        insert con;
        return con.Id;
    }
    
    Static Id InsertLocation(){
        SVMXC__Site__c loc = new SVMXC__Site__c(Name = 'Test Location');
        insert loc;
        return loc.Id;
    }
    
    static Map<Id, SVMXC__Service_Order_Line__c> CreateChildLines(Id woId, Integer recordsCount){
        List<SVMXC__Service_Order_Line__c> productServicedLinesList = new List<SVMXC__Service_Order_Line__c>();
        for(integer i=0; i < recordsCount ; i++){
            SVMXC__Service_Order_Line__c woLine = new SVMXC__Service_Order_Line__c();
            woLine.SVMXC__Service_Order__c = woId;
            woLine.SVMXC__Serial_Number__c = InsertComponent();
            woLine.RecordTypeId = recordTypeIdMap.get('Products_Serviced');
            woLine.SVMXC__Product_Warranty__c = InsertWarranties(woLine.SVMXC__Serial_Number__c);
            productServicedLinesList.add(woLine);
        }
        Id warrantyId = InsertWarranties(productServicedLinesList[0].SVMXC__Serial_Number__c);
        insert productServicedLinesList;
        return (new Map<Id, SVMXC__Service_Order_Line__c>(productServicedLinesList));
    }
    static void  getrecordTypes(){
        for(RecordType rec : [SELECT Id,DeveloperName FROM RecordType WHERE sObjectType =: 'SVMXC__Service_Order_Line__c' AND isActive = true]){
            recordTypeIdMap.put(rec.DeveloperName,rec.Id);
        }
    }

    static string insertEntitlementHistory(String recId, string WOorScon) {
        SVMXC__Entitlement_History__c historyRec = new SVMXC__Entitlement_History__c();
        if(WOorScon == 'WO'){
            historyRec.SVMXC__Service_Order__c = recId;
        }else{
            historyRec.SVMXC__Work_Detail__c = recid;
        }
        insert historyRec;
        return historyRec.id;
    }
}