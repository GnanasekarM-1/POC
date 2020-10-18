@isTest
Private with sharing class CONF_ManageProductReplacement_UT
{
    static testMethod void CONF_ManageProductReplacement_UT_Test1()
    {
        list<Product2> lstProd = new list<Product2>();
        Product2 prod1 = new Product2();
        prod1.SVMXC__Select__c = true;
        prod1.SVMXC__Replacement_Available__c = false;
        prod1.ProductCode = 'prod001';
        prod1.Name = 'prod1';
        prod1.IsActive = true;
        prod1.Description = 'prod1';
        insert prod1;
        lstProd.add(prod1);
        
        Product2 prod2 = new Product2();
        prod2.SVMXC__Select__c = true;
        prod2.SVMXC__Replacement_Available__c = false;
        prod2.ProductCode = 'prod002';
        prod2.Name = 'prod2';
        prod2.IsActive = true;
        prod2.Description = 'prod2';
        insert prod2;
        lstProd.add(prod2);
        
        Product2 prod3 = new Product2();
        prod3.SVMXC__Select__c = true;
        prod3.SVMXC__Replacement_Available__c = false;
        prod3.ProductCode = 'prod003';
        prod3.Name = 'prod3';
        prod3.IsActive = true;
        prod3.Description = 'prod3';
        insert prod3;
        lstProd.add(prod3);
        
        Product2 prod4 = new Product2();
        prod4.SVMXC__Select__c = true;
        prod4.SVMXC__Replacement_Available__c = false;
        prod4.ProductCode = 'prod004';
        prod4.Name = 'prod4';
        prod4.IsActive = true;
        prod4.Description = 'prod4';
        insert prod4;
        lstProd.add(prod4);
        
        list<SVMXC__Product_Replacement__c> ReplacedProdLst = new list<SVMXC__Product_Replacement__c>();
        SVMXC__Product_Replacement__c Rprod1 = new SVMXC__Product_Replacement__c();
        Rprod1.SVMXC__Base_Product__c = prod1.Id;
        Rprod1.SVMXC__Order_Of_Preference__c = 1;
        Rprod1.SVMXC__Replacement_Product__c = prod3.Id;
        insert Rprod1;
        ReplacedProdLst.add(Rprod1);
        
        SVMXC__Product_Replacement__c Rprod2 = new SVMXC__Product_Replacement__c();
        Rprod2.SVMXC__Base_Product__c = prod2.Id;
        Rprod2.SVMXC__Order_Of_Preference__c = 1;
        Rprod2.SVMXC__Replacement_Product__c = prod4.Id;
        insert Rprod2;
        ReplacedProdLst.add(Rprod2);
        
        //.......class instantiation and calling various methods.......
        CONF_ManageProductReplacement SubsituteObj =  new CONF_ManageProductReplacement();
        SubsituteObj.getTAG001();
        SubsituteObj.getTAG002();
        SubsituteObj.getTAG003();
        SubsituteObj.getTAG004();
        SubsituteObj.getTAG005();
        SubsituteObj.getTAG006();
        SubsituteObj.getTAG007();
        SubsituteObj.getTAG008();
        SubsituteObj.getTAG009();
        SubsituteObj.getTAG010();
        SubsituteObj.getTAG011();
        SubsituteObj.getTAG012();
        SubsituteObj.getTAG013();
        SubsituteObj.getTAG014();
        SubsituteObj.getTAG015();
        SubsituteObj.getTAG016();
        SubsituteObj.getTAG017();
        SubsituteObj.getProdLst();
        SubsituteObj.setProdLst(lstProd);
        SubsituteObj.setAvailProdLst(lstProd);
        SubsituteObj.UpProduct();
        SubsituteObj.setTobeReplacProdLst(lstProd);
        SubsituteObj.setReplacedProdLst(ReplacedProdLst);
        SubsituteObj.setProdSelect(prod1.Id);
        SubsituteObj.gettitleName();
        SubsituteObj.getProdSelect();
        SubsituteObj.getIsRender();
        SubsituteObj.getIsError();
        SubsituteObj.getIsDetailError();
        SubsituteObj.getAvailProdLst();
        SubsituteObj.getTobeReplacProdLst();
        SubsituteObj.getReplacedProdLst();
        SubsituteObj.getIsListEmpty();
        SubsituteObj.ProductReplacementAction();
        SubsituteObj.OnAddproduct();
        SubsituteObj.OnRemProduct();
        SubsituteObj.DownProduct();
        SubsituteObj.CancelAction();
        SubsituteObj.ConformReplacement();
        SubsituteObj.getPicklistOption();
        SubsituteObj.getpickValue();
        SubsituteObj.setpickValue('10');
        SubsituteObj.getpickValueForAvail();
        SubsituteObj.setpickValueForAvail('10');
        SubsituteObj.getProdLstSize();
        SubsituteObj.getAvailProdLstSize();
        SubsituteObj.getstrSearchKeyword();
        SubsituteObj.setstrSearchKeyword('SLA');
        SubsituteObj.getstrSearchKeywordForAvail();
        SubsituteObj.setstrSearchKeywordForAvail('SLA');
        SubsituteObj.getProductLst();
        SubsituteObj.ProdctSearch();
        SubsituteObj.AvailProdctSearch();
    }
    static testMethod void CONF_ManageProductReplacement_UT_Test2()
    {
        list<Product2> lstProd = new list<Product2>();
        Product2 prod1 = new Product2();
        prod1.SVMXC__Select__c = false;
        prod1.SVMXC__Replacement_Available__c = false;
        prod1.ProductCode = 'prod001';
        prod1.Name = 'prod1';
        prod1.IsActive = true;
        prod1.Description = 'prod1';
        insert prod1;
        lstProd.add(prod1);
        
        Product2 prod2 = new Product2();
        prod2.SVMXC__Select__c = false;
        prod2.SVMXC__Replacement_Available__c = false;
        prod2.ProductCode = 'prod002';
        prod2.Name = 'prod2';
        prod2.IsActive = true;
        prod2.Description = 'prod2';
        insert prod2;
        lstProd.add(prod2);
        
        Product2 prod3 = new Product2();
        prod3.SVMXC__Select__c = false;
        prod3.SVMXC__Replacement_Available__c = false;
        prod3.ProductCode = 'prod003';
        prod3.Name = 'prod3';
        prod3.IsActive = true;
        prod3.Description = 'prod3';
        insert prod3;
        lstProd.add(prod3);
        
        Product2 prod4 = new Product2();
        prod4.SVMXC__Select__c = true;
        prod4.SVMXC__Replacement_Available__c = false;
        prod4.ProductCode = 'prod004';
        prod4.Name = 'prod4';
        prod4.IsActive = true;
        prod4.Description = 'prod4';
        insert prod4;
        lstProd.add(prod4);
        
        list<SVMXC__Product_Replacement__c> ReplacedProdLst = new list<SVMXC__Product_Replacement__c>();
        
        
        //.......class instantiation and calling various methods.......
        CONF_ManageProductReplacement SubsituteObj =  new CONF_ManageProductReplacement();
        SubsituteObj.getProdLst();
        SubsituteObj.setProdLst(lstProd);
        SubsituteObj.setAvailProdLst(lstProd);
        SubsituteObj.setTobeReplacProdLst(lstProd);
        SubsituteObj.setReplacedProdLst(ReplacedProdLst);
        SubsituteObj.setProdSelect(prod1.Id);
        SubsituteObj.gettitleName();
        SubsituteObj.getProdSelect();
        SubsituteObj.getIsRender();
        SubsituteObj.getIsError();
        SubsituteObj.getIsDetailError();
        SubsituteObj.getAvailProdLst();
        SubsituteObj.getTobeReplacProdLst();
        SubsituteObj.getReplacedProdLst();
        SubsituteObj.getIsListEmpty();
        SubsituteObj.ProductReplacementAction();
        SubsituteObj.OnAddproduct();
        SubsituteObj.OnRemProduct();
        SubsituteObj.UpProduct();
        SubsituteObj.DownProduct();
        SubsituteObj.BackToSetupHome();
        SubsituteObj.ConformReplacement();
        SubsituteObj.getTag018();
        SubsituteObj.getTag019();
        SubsituteObj.setTobeReplacProdLst(lstProd);
        SubsituteObj.UpProduct();
        SubsituteObj.DownProduct();
        
    }
    static testMethod void CONF_ManageProductReplacement_UT_Test3()
    {
        list<Product2> lstProd = new list<Product2>();
        list<SVMXC__Product_Replacement__c> ReplacedProdLst = new list<SVMXC__Product_Replacement__c>();
        

        Product2 prod1 = new Product2();
        prod1.SVMXC__Select__c = true;
        prod1.SVMXC__Replacement_Available__c = false;
        prod1.ProductCode = 'prod001';
        prod1.Name = 'prod1';
        prod1.IsActive = true;
        prod1.Description = 'prod1';
        insert prod1;
        lstProd.add(prod1);
        
        Product2 prod2 = new Product2();
        prod2.SVMXC__Select__c = true;
        prod2.SVMXC__Replacement_Available__c = false;
        prod2.ProductCode = 'prod002';
        prod2.Name = 'prod2';
        prod2.IsActive = true;
        prod2.Description = 'prod2';
        insert prod2;
        lstProd.add(prod2);
        
        Product2 prod3 = new Product2();
        prod3.SVMXC__Select__c = true;
        prod3.SVMXC__Replacement_Available__c = false;
        prod3.ProductCode = 'prod003';
        prod3.Name = 'prod3';
        prod3.IsActive = true;
        prod3.Description = 'prod3';
        insert prod3;
        lstProd.add(prod3);
        
        
        //.......class instantiation and calling various methods.......
        CONF_ManageProductReplacement SubsituteObj =  new CONF_ManageProductReplacement();
        
        SubsituteObj.setTobeReplacProdLst(lstProd);
        SubsituteObj.UpProduct();
        SubsituteObj.DownProduct();
        
        SubsituteObj.getProdLst();
        SubsituteObj.setProdLst(lstProd);
        SubsituteObj.setAvailProdLst(lstProd);
        SubsituteObj.setTobeReplacProdLst(lstProd);
        SubsituteObj.setReplacedProdLst(ReplacedProdLst);
        SubsituteObj.setProdSelect('');
        SubsituteObj.gettitleName();
        SubsituteObj.getProdSelect();
        SubsituteObj.getIsRender();
        SubsituteObj.getIsError();
        SubsituteObj.getIsDetailError();
        SubsituteObj.getAvailProdLst();
        SubsituteObj.getTobeReplacProdLst();
        SubsituteObj.getReplacedProdLst();
        SubsituteObj.getIsListEmpty();
        SubsituteObj.OnAddproduct();
        SubsituteObj.OnRemProduct();
        SubsituteObj.UpProduct();
        SubsituteObj.DownProduct();
        //SubsituteObj.CancelAction();
        SubsituteObj.ConformReplacement();
    }
}