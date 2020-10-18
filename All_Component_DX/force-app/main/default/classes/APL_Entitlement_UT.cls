@isTest(SeeAllData=true)
private class APL_Entitlement_UT 
{
    static testMethod void COMM_StockLookupTest() 
    {
        PageReference pageRef = Page.COMM_StockLookup;
        Test.setCurrentPageReference(pageRef);
        
        Account objAccount= new Account();
        objAccount.name= 'ServiceMax';
        insert objAccount;
        System.assert(objAccount.id!=null);

        SVMXC__Site__c requiredAtLocation =  new SVMXC__Site__c();
        requiredAtLocation.Name ='ServiceMax Depo';
        requiredAtLocation.SVMXC__Street__c ='MG Road';
        requiredAtLocation.SVMXC__Country__c ='India';
        requiredAtLocation.SVMXC__Zip__c ='560001';
        requiredAtLocation.SVMXC__Account__c =objAccount.id;
        requiredAtLocation.SVMXC__Stocking_Location__c =true;
        insert requiredAtLocation;
        System.assert(requiredAtLocation.id!=null);
        
        SVMXC__Site__c fromLocation =  new SVMXC__Site__c();
        fromLocation.Name ='ServiceMax Depo';
        fromLocation.SVMXC__Street__c ='MG Road';
        fromLocation.SVMXC__Country__c ='India';
        fromLocation.SVMXC__Zip__c ='560001';
        fromLocation.SVMXC__Account__c =objAccount.id;
        fromLocation.SVMXC__Stocking_Location__c =true;
        fromLocation.SVMXC__Latitude__c =77.594802;
        fromLocation.SVMXC__Latitude__c =12.992544;
        fromLocation.SVMXC__Service_Engineer__c =UserInfo.getUserId();
        insert fromLocation;
        System.assert(fromLocation.id!=null);
      
        Product2 objProduct =new Product2();
        objProduct.name = 'Product1';
        insert objProduct;
        System.assert(objProduct.id!=null);
        
        SVMXC__Product_Stock__c objProductStock =new SVMXC__Product_Stock__c();
        objProductStock.SVMXC__Product__c = objProduct.id;
        objProductStock.SVMXC__Status__c = 'Available';
        objProductStock.SVMXC__Quantity2__c =10;
        objProductStock.SVMXC__Location__c =fromLocation.id;
        insert objProductStock;
        System.assert(objProductStock.id!=null);
        
        SVMXC__Parts_Request__c objPartRequest =new SVMXC__Parts_Request__c();
        objPartRequest.SVMXC__Required_At_Location__c =requiredAtLocation.id;
        insert objPartRequest;
        System.assert(objPartRequest.id!=null);
        
        SVMXC__Parts_Request_Line__c objPRLine =new SVMXC__Parts_Request_Line__c();
        objPRLine.SVMXC__Parts_Request__c =objPartRequest.id;
        objPRLine.SVMXC__Product__c= objProduct.id;
        objPRLine.SVMXC__Quantity_Required2__c =2;
        objPRLine.SVMXC__Date_Required__c =Date.today();
        insert objPRLine;
        System.assert(objPRLine.id!=null);
        
        pageRef.getParameters().put('SVMX_Id', objPRLine.id);
        pageRef.getParameters().put('SVMX_Type', 'PR');
        
        COMM_StockLookup objStockLookup =new COMM_StockLookup();
        objStockLookup.FindStock();
        objStockLookup.getLstProdStock();
        objStockLookup.getlstunit();
        objStockLookup.getLocation();
        objStockLookup.getlstOption();
        objStockLookup.requestStockId = fromLocation.id;
        objStockLookup.RequestStock();
    }
  
    static testMethod void COMM_StockLookupTest1() 
    {
        PageReference pageRef = Page.COMM_StockLookup;
        Test.setCurrentPageReference(pageRef);
        
        Account objAccount= new Account();
        objAccount.name= 'ServiceMax';
        insert objAccount;
        System.assert(objAccount.id!=null);

        SVMXC__Site__c requestedLocation =  new SVMXC__Site__c();
        requestedLocation.Name ='ServiceMax Depo';
        requestedLocation.SVMXC__Street__c ='MG Road';
        requestedLocation.SVMXC__Country__c ='India';
        requestedLocation.SVMXC__Zip__c ='560001';
        requestedLocation.SVMXC__Account__c =objAccount.id;
        requestedLocation.SVMXC__Stocking_Location__c =true;
        insert requestedLocation;
        System.assert(requestedLocation.id!=null);
        
        SVMXC__Site__c fromLocation =  new SVMXC__Site__c();
        fromLocation.Name ='ServiceMax Depo';
        fromLocation.SVMXC__Street__c ='MG Road';
        fromLocation.SVMXC__Country__c ='India';
        fromLocation.SVMXC__Zip__c ='560001';
        fromLocation.SVMXC__Account__c =objAccount.id;
        fromLocation.SVMXC__Stocking_Location__c =true;
        fromLocation.SVMXC__Latitude__c =77.594802;
        fromLocation.SVMXC__Latitude__c =12.992544;
        fromLocation.SVMXC__Service_Engineer__c =UserInfo.getUserId();
        insert fromLocation;
        System.assert(fromLocation.id!=null);

        Product2 objProduct =new Product2();
        objProduct.name = 'Product1';
        insert objProduct;
        System.assert(objProduct.id!=null);
        
        SVMXC__Product_Stock__c objProductStock =new SVMXC__Product_Stock__c();
        objProductStock.SVMXC__Product__c = objProduct.id;
        objProductStock.SVMXC__Status__c = 'Available';
        objProductStock.SVMXC__Quantity2__c =10;
        objProductStock.SVMXC__Location__c =fromLocation.id;
        insert objProductStock;
        System.assert(objProductStock.id!=null);
        
        SVMXC__Service_Order__c objServiceOrder =new SVMXC__Service_Order__c();
        insert objServiceOrder;
        System.assert(objServiceOrder.id!=null);
        
        SVMXC__Service_Order_Line__c objSVOLine =new SVMXC__Service_Order_Line__c();
        objSVOLine.SVMXC__Service_Order__c =objServiceOrder.id;
        objSVOLine.SVMXC__Product__c= objProduct.id;
        objSVOLine.SVMXC__Requested_Quantity2__c =2;
        objSVOLine.SVMXC__Requested_Location__c =requestedLocation.id;
        insert objSVOLine;
        System.assert(objSVOLine.id!=null);
        
        pageRef.getParameters().put('SVMX_Id', objSVOLine.id);
        pageRef.getParameters().put('SVMX_Type', 'SVO');
        
        COMM_StockLookup objStockLookup =new COMM_StockLookup();
        objStockLookup.FindStock();
        objStockLookup.getLstProdStock();
        objStockLookup.getlstunit();
        objStockLookup.getLocation();
        objStockLookup.getlstOption();
        objStockLookup.requestStockId = fromLocation.id;
        objStockLookup.RequestStock();
    }
    static testMethod void APL_EntitlementTest1()
    {
        COMM_StockLookup comm = new COMM_StockLookup();
        PageReference pageRef = Page.COMM_StockLookup;
        COMM_StockLookup_UT objUT = new COMM_StockLookup_UT();
        SFM_BusinessRules_UT objBizRuleUT = new SFM_BusinessRules_UT();
    }
    
    
    static testMethod void APL_EntitlementTest()
    {
        // UT for class SVMXRestMethodInfo
        SVMXRestMethodInfo a = new SVMXRestMethodInfo(null, null);   
        SVMXRestMethodInfo a1 = new SVMXRestMethodInfo();     
        OMAX_BatchRunQTL b = new OMAX_BatchRunQTL(null, null, null);  
        b.start(null);
        
        
        Case objTestCase = new Case(); 
        insert objTestCase;//
        SVMXC__Case_Line__c objTestCaseLine = new SVMXC__Case_Line__c();
        objTestCaseLine.SVMXC__Case__c = objTestCase.id;
        insert objTestCaseLine;
        INTF_WebServicesDef.INTF_SFMRequest reqForEntitlement = new INTF_WebServicesDef.INTF_SFMRequest();
        reqForEntitlement.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        reqForEntitlement.valueMap.add(new INTF_WebServicesDef.SVMXMap('',objTestCase.Id));
        reqForEntitlement.valueMap.add(new INTF_WebServicesDef.SVMXMap('','SVMXC__Priority__c'));
        APL_Entitlement objEntitle = new APL_Entitlement();
        objEntitle.APL_PerformEntitlement(reqForEntitlement);
        
        SVMXC__RMA_Shipment_Order__c PO = new SVMXC__RMA_Shipment_Order__c();
        insert PO;
        
        List<SVMXC__RMA_Shipment_Line__c> poLinesForEntitlement = new List<SVMXC__RMA_Shipment_Line__c>();
        SVMXC__RMA_Shipment_Line__c newLine = new SVMXC__RMA_Shipment_Line__c();
        newLine.SVMXC__RMA_Shipment_Order__c = PO.Id;
        poLinesForEntitlement.add(newLine);
        insert poLinesForEntitlement;
        
        objEntitle.APL_ResolveIB_On_PD(poLinesForEntitlement);
        
        INTF_WebServicesDef.INTF_SFMRequest reqForEntitlementRMALine = new INTF_WebServicesDef.INTF_SFMRequest();
        reqForEntitlementRMALine.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        reqForEntitlementRMALine.valueMap.add(new INTF_WebServicesDef.SVMXMap('UNEXPECTEDLINES',newLine.Id));
        objEntitle.APL_PerformEntitlement_PD(reqForEntitlementRMALine);
        objEntitle.getTAG001();
        objEntitle.getTAG002();
        objEntitle.getTAG003();
        APL_Entitlement.failureStatusEmail('','abc@abc.com');
        
        List<SVMXC__Service_Contract__c> SC = new List<SVMXC__Service_Contract__c>();
        List<ID> lstSCID = new List<ID>();
        
        Account ABC = new Account();
        ABC.Name = 'ABCDEFGHI';
        insert ABC;
        system.assert(ABC.Name!=null);
        
        SVMXC__Service_Contract__c newSC = new SVMXC__Service_Contract__c();
        newSC.SVMXC__Exchange_type__c = 'Return Exchange';
        newSC.SVMXC__Start_Date__c  = system.today();
        newSC.SVMXC__End_Date__c  = system.today() + 1;
        newSC.SVMXC__Company__c = ABC.Id;
        SC.add(newSC);
        SVMXC__Service_Contract__c newSC1 = new SVMXC__Service_Contract__c();
        newSC1.SVMXC__Exchange_type__c = 'Return Exchange';
        newSC1.SVMXC__Start_Date__c  = system.today();
        newSC1.SVMXC__End_Date__c  = system.today() + 1;
        newSC1.SVMXC__Company__c = ABC.Id;
        SC.add(newSC1);
        insert SC;
        system.assert(SC.size() !=null);        
        Product2 newProduct = new Product2();
        newProduct.Name = 'Computer';
        insert newProduct;
        system.assert(newProduct.Name !=null); 
        newSC.SVMXC__Exchange_type__c = 'Advance Exchange';
        update newSC;
        
        for(SVMXC__Service_Contract__c sc1 : SC)
            lstSCID.add(sc1.Id);
            
        List<SVMXC__Installed_Product__c> lstIB = new List<SVMXC__Installed_Product__c>();
        SVMXC__Installed_Product__c IB1 = new SVMXC__Installed_Product__c();
        IB1.SVMXC__Product__c = newProduct.Id;
        IB1.SVMXC__Company__c = ABC.Id;
        lstIB.add(IB1);
        insert lstIB;     
        
        SVMXC__Service_Contract_Products__c CP = new SVMXC__Service_Contract_Products__c();
        CP.SVMXC__Exchange_type__c = 'Return Exchange';
        CP.SVMXC__Start_Date__c  = system.today();
        CP.SVMXC__End_Date__c  = system.today() + 1;
        CP.SVMXC__Service_Contract__c = newSC.Id;
        CP.SVMXC__Product__c = newProduct.Id;
        CP.SVMXC__Installed_Product__c = IB1.Id;
        insert CP;
        system.assert(CP.SVMXC__Exchange_type__c !=null); 
        List<ID> lstIBId = new List<ID>();
        lstIBId.add(IB1.Id);
        
        SVMXC__Warranty__c wrnty = new SVMXC__Warranty__c();
        wrnty.SVMXC__Exchange_type__c = 'Return Exchange';
        wrnty.SVMXC__Installed_Product__c = IB1.Id;
        wrnty.SVMXC__Start_Date__c = system.today();
        wrnty.SVMXC__End_Date__c = system.today() + 1;
        insert wrnty;
        //Map<ID, ID> mapWarntyIBId = new Map<ID, ID>();
        //Map<ID, SVMXC__Warranty__c> mapIBIdWarnty = new Map<ID, SVMXC__Warranty__c>();
        objEntitle.updateIBForContract(lstSCID);
        objEntitle.updateIBForInvalidWarranty(lstIBId);
        //objEntitle.updateIBForWarranty(mapWarntyIBId,mapIBIdWarnty);
        
        
        List<SVMXC__ServiceMax_Config_Data__c> lst = [select id from SVMXC__ServiceMax_Config_Data__c where SVMXC__Setting_Unique_ID__c IN ('APL001_SET001')];
        
        for(SVMXC__ServiceMax_Config_Data__c l: lst)
        {
            l.SVMXC__Display_Value__c = 'Pick The First Service Contract';
            l.SVMXC__Internal_Value__c = 'Pick The First Service Contract';
        }
        if(lst != null && lst.size() > 0)
        update lst;
        
        SVMXC__Case_Line__c objTestCaseLine1 = new SVMXC__Case_Line__c();
        objTestCaseLine1.SVMXC__Case__c = objTestCase.id;
        insert objTestCaseLine1;
        objEntitle.APL_PerformEntitlement(reqForEntitlement);
        
        List<SVMXC__Entitlement_History__c> etlHistory = new List<SVMXC__Entitlement_History__c>();
        Date startDate;
        Date endDate;
        objEntitle.CreateEntitHistoryForCaseLine(etlHistory, newLine, startDate, endDate);
        
        //Added this code for code coverage.
        objEntitle.CreateEntitHistoryForCaseLine(etlHistory, objTestCaseLine, startDate, endDate);
        
        objEntitle.APL_Entitlement_On_PD(poLinesForEntitlement);
        
        newLine.SVMXC__Serial_Number_List__c = 'ABC';
        update newLine;
        IB1.SVMXC__Serial_Lot_Number__c = 'ABC';
        update IB1;
        objEntitle.APL_ResolveIB_On_PD(poLinesForEntitlement);
    }
}