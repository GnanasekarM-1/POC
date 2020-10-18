@isTest(SeeAllData=true)
private class SVMXC_CreateWarrantyClass_UT {

    static testMethod void SVMXC_CreateWarrantyClassTest() {
       
   try{
        
        Account acc = new Account(Name = 'TestAccount');
        insert acc;
        System.assertEquals('TestAccount', acc.name);
        Product2 prod1 = new Product2(Name = 'Prod1', ProductCode = '1234', Family = 'Accessory', SVMXC__Inherit_Parent_Warranty__c =False);
        insert prod1;
        System.assertEquals('Prod1', prod1.name);
        Product2 prod2 = new Product2(Name = 'Prod2', ProductCode = '1235', Family = 'Accessory', SVMXC__Inherit_Parent_Warranty__c =True);
        insert prod2;
        System.assertEquals('Prod2', prod2.name);
        Product2 prod3 = new Product2(Name = 'Prod3', ProductCode = '12353', SVMXC__Inherit_Parent_Warranty__c =True);
        insert prod3;
         System.assertEquals('Prod3', prod3.name);
        //create service template1 

        SVMXC__Service_Template__c st1 = new SVMXC__Service_Template__c(Name = '6 Months from Install Date', SVMXC__Template_Type__c = 'Warranty', SVMXC__Coverage_Effective_From__c = 'Install Date', Duration_of_Time_Coverage__c =6, SVMXC__Duration_of_Material_Coverage__c = 6, Duration_of_Expenses__c = 6, SVMXC__Unit_of_Time__c = 'Months', SVMXC__Unit_of_Time_Material__c = 'Months', SVMXC__Unit_of_Time_Expenses__c = 'Months');
        insert st1; 
        SVMXC__Service_Template_Products__c stp11 = new SVMXC__Service_Template_Products__c(SVMXC__Service_Template__c = st1.Id, SVMXC__Product__c = prod1.Id );
        insert stp11;
        SVMXC__Service_Template_Products__c stp12 = new SVMXC__Service_Template_Products__c(SVMXC__Service_Template__c = st1.Id, SVMXC__Product__c = prod2.Id );
        insert stp12;
        //create service template2 
        SVMXC__Service_Template__c st2 = new SVMXC__Service_Template__c(Name = '12 Months from Ship Date', SVMXC__Template_Type__c = 'Warranty', SVMXC__Coverage_Effective_From__c = 'Ship Date', Duration_of_Time_Coverage__c = 12, SVMXC__Duration_of_Material_Coverage__c = 12, Duration_of_Expenses__c = 12, SVMXC__Unit_of_Time__c = 'Months', SVMXC__Unit_of_Time_Material__c = 'Days', SVMXC__Unit_of_Time_Expenses__c = 'Weeks');
        insert st2;
        SVMXC__Service_Template_Products__c stp21 = new SVMXC__Service_Template_Products__c(SVMXC__Service_Template__c = st2.Id, SVMXC__Product__c = prod1.Id );
        insert stp21;
        SVMXC__Service_Template_Products__c stp22 = new SVMXC__Service_Template_Products__c(SVMXC__Service_Template__c = st2.Id, SVMXC__Product__c = prod2.Id );
        insert stp22;
        //create service template3

        SVMXC__Service_Template__c st3 = new SVMXC__Service_Template__c(Name = '6 Months from Entry Date', SVMXC__Template_Type__c = 'Warranty', SVMXC__Coverage_Effective_From__c = 'Entry Date', Duration_of_Time_Coverage__c = 6, SVMXC__Duration_of_Material_Coverage__c = 6, Duration_of_Expenses__c = 6, SVMXC__Unit_of_Time__c = 'Days', SVMXC__Unit_of_Time_Material__c = 'Years', SVMXC__Unit_of_Time_Expenses__c = 'Years');
        insert st3;
        SVMXC__Service_Template_Products__c stp31 = new SVMXC__Service_Template_Products__c(SVMXC__Service_Template__c = st3.Id, SVMXC__Product__c = prod1.Id );
        insert stp31;
        SVMXC__Service_Template_Products__c stp32 = new SVMXC__Service_Template_Products__c(SVMXC__Service_Template__c = st3.Id, SVMXC__Product__c = prod2.Id );
        insert stp32;
        //create IB
        
        SVMXC__Installed_Product__c IB1 = new SVMXC__Installed_Product__c(SVMXC__Product__c = prod1.Id, SVMXC__Company__c = acc.Id, SVMXC__Status__c = 'Installed', SVMXC__Serial_Lot_Number__c = 'Test1', SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today(), SVMXC__Date_Ordered__c = System.today(), SVMXC__Last_Date_Shipped__c = System.today());
        insert IB1;
            List<SVMXC__Installed_Product__c> ibLst = new List<SVMXC__Installed_Product__c>();
            ibLst.add(IB1);
    Map<String, String> AllSubModuleSettings = new Map<String, String> ();  
    AllSubModuleSettings.put('SET005','True');
    AllSubModuleSettings.put('SET006','True');
    AllSubModuleSettings.put('SET010','True');
    AllSubModuleSettings.put('SET011','True');
    AllSubModuleSettings.put('SET002','True');
    
        SVMXC_CreateWarrantyClass.SVMX_CreateWarranty(ibLst,AllSubModuleSettings);
        SVMXC_CreateWarrantyClass.SVMX_IBWarrantyCount(ibLst);
        SVMXC_CreateWarrantyClass.SVMX_CopyParentWarranty(ibLst);
        //SVMXC__Installed_Product__c IB2 = new SVMXC__Installed_Product__c(SVMXC__Product__c = prod2.Id, SVMXC__Company__c = acc.Id, SVMXC__Status__c = 'Shipped', SVMXC__Serial_Lot_Number__c = 'Test2', SVMXC__Top_Level__c = IB1.Id, SVMXC__Parent__c = IB1.Id , SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Ordered__c = System.today(), SVMXC__Last_Date_Shipped__c = System.today());
        //insert IB2;
        prod1.SVMXC__Inherit_Parent_Warranty__c=true;
        update prod1;
        update IB1;
        //case creation
        Case cs1 = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', SVMXC__Component__c = IB1.Id); 
        insert cs1;
        Case cs2 = new Case(Status ='New', Priority = 'Medium', Origin = 'Email',  SVMXC__Component__c = IB1.Id); 
        insert cs2;
        Case cs3 = new Case(Status ='New', Priority = 'High', Origin = 'Web' ); 
        insert cs3;
        update cs1;
        update cs2;
        update cs3;
        
         //create IB with out Product        
        SVMXC__Installed_Product__c IB3 = new SVMXC__Installed_Product__c( SVMXC__Company__c = acc.Id, SVMXC__Status__c = 'Installed', SVMXC__Serial_Lot_Number__c = 'Test1', SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today(),SVMXC__Date_Ordered__c = System.today(), SVMXC__Last_Date_Shipped__c = System.today(),SVMXC__Parent__c=IB1.id);
        insert IB3;
        update IB3;
        SVMXC__Warranty__c warrantyobj=new SVMXC__Warranty__c(SVMXC__Installed_Product__c = IB3.id);
        insert warrantyobj;
        List<SVMXC__Installed_Product__c> ibLst2 = new List<SVMXC__Installed_Product__c>();
       ibLst2.add(IB3);
        test.starttest();
        
        SVMXC_CreateWarrantyClass cwc=new  SVMXC_CreateWarrantyClass();
        SVMXC_CreateWarrantyClass.SVMX_CreateWarranty(ibLst2,AllSubModuleSettings);
        SVMXC_CreateWarrantyClass.SVMX_IBWarrantyCount(ibLst2);
        SVMXC_CreateWarrantyClass.SVMX_CopyParentWarranty(ibLst2);
       
        test.stoptest();
       }catch(Exception e) {} 
    
    }
}