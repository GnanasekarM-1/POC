@isTest(SeeAllData=true)
public class COMM_StockLookup_UT {
    static testMethod void COMM_StockLookupTest() {
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
        objStockLookup.getUserOrgID();
        objStockLookup.getUserID();
        objStockLookup.getUserLocaleKey();
        objStockLookup.FindStock();
        objStockLookup.getLstProdStock();
        objStockLookup.getlstunit();
        objStockLookup.getLocation();
        objStockLookup.getlstOption();
        objStockLookup.requestStockId = fromLocation.id;
        objStockLookup.RequestStock();
    }
    
    static testMethod void COMM_StockLookupTest1() {
        PageReference pageRef = Page.COMM_StockLookup;
        Test.setCurrentPageReference(pageRef);
        
        Account objAccount= new Account();
        objAccount.name= 'ServiceMax';
        insert objAccount;
        System.assert(objAccount.id!=null);

        SVMXC__Site__c requestedLocation =  new SVMXC__Site__c();
        requestedLocation.Name ='ServiceMax Depo';
        requestedLocation.SVMXC__Street__c ='MG Road';
        requestedLocation.SVMXC__City__c ='Bangalore';
        requestedLocation.SVMXC__State__c ='KA';
        requestedLocation.SVMXC__Country__c ='India';
        requestedLocation.SVMXC__Zip__c ='560001';
        requestedLocation.SVMXC__Account__c =objAccount.id;
        requestedLocation.SVMXC__Stocking_Location__c =true;
        insert requestedLocation;
        System.assert(requestedLocation.id!=null);
        
        SVMXC__Site__c fromLocation =  new SVMXC__Site__c();
        fromLocation.Name ='ServiceMax Depo';
        fromLocation.SVMXC__Street__c ='MG Road';
        fromLocation.SVMXC__City__c ='Bangalore';
        fromLocation.SVMXC__State__c ='KA';
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
        objStockLookup.strErrorMesssage = 'a';
    }
}