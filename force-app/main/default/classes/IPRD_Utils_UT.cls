@isTest(SeeAllData=true)
Private class IPRD_Utils_UT {
    public static testMethod void IPRD_Utils()
    {
        SVMXC__Service_Template__c seed1 = new SVMXC__Service_Template__c(
                                    Name ='TEST: 001',
                                    Coverage_Effective_From2__c='SVMXC__Date_Installed__c',
                                    SVMXC__Duration_of_Time_Coverage__c=2.0,
                                    SVMXC__Unit_of_Time__c='Years',
                                    SVMXC__Duration_of_Material_Coverage__c=2.0,
                                    SVMXC__Unit_of_Time_Material__c='Years',
                                    SVMXC__Duration_of_Expenses__c=2.0,
                                    SVMXC__Unit_of_Time_Expenses__c='Years'
                                    );
        insert seed1;
        // Verify that the Create Service Template was created  in the database.
        System.assertEquals('SVMXC__Date_Installed__c', seed1.Coverage_Effective_From2__c);                 
        Product2 Product1 = new Product2(Name='test product');
        insert Product1;                
        // Verify that the Create Product was created  in the database.
        System.assertEquals('test product', Product1.Name);
        
        SVMXC__Installed_Product__c inst = new SVMXC__Installed_Product__c(Name='Test',SVMXC__Product__c=Product1.Id,SVMXC__Date_Installed__c=date.today());
        insert inst;
        // Verify that the Create Product was created  in the database.
        System.assertEquals('test product', Product1.Name);
        
        Warranty__c ext = new Warranty__c(SVMXC__Installed_Product__c=inst.Id,SVMXC__Service_Template__c=seed1.Id);
        insert ext;
        // Verify that the Warranty was created  in the database.
        System.assertEquals(inst.id, ext.SVMXC__Installed_Product__c);
        
        SVMXC__Service_Template_Products__c stprod = new SVMXC__Service_Template_Products__c(SVMXC__Product__c=Product1.Id, SVMXC__Service_Template__c=seed1.Id);
        insert stprod;
        // Verify that the Service Template Products was created  in the database.
        System.assertEquals(Product1.Id, stprod.SVMXC__Product__c);
        
        List<SVMXC__Installed_Product__c> IBList = new List<SVMXC__Installed_Product__c>();
        List<SVMXC__Service_Template__c> WarrantyList= new List<SVMXC__Service_Template__c>();
        Map<Id,list<SVMXC__Service_Template__c>> IBtoWarranty = new Map<Id,list<SVMXC__Service_Template__c>>();
        
        IBList.add(inst);
        WarrantyList.add(seed1);
        IBtoWarranty.put(inst.Id,WarrantyList);
        
        set<Id> CoveredIds = new set<Id>();
        set<String> SCoveredIds = new set<String>();
                
        SVMXC.IPRD_Utils ConfClass = new SVMXC.IPRD_Utils();
        CoveredIds=ConfClass.SVMXC_Get_CoveredProducts(inst);
        for(string s: CoveredIds){
            SCoveredIds.add(s);
        }
        ConfClass.SVMXC_Set_CreateWarranty_IPW(IBList,IBtoWarranty);
        set<String> aStr = new set<String> ();
        aStr.add('A String');
        SVMXC.IPRD_Utils.CreateWarrantyResult wrapClass = new SVMXC.IPRD_Utils.CreateWarrantyResult('Status','retURL',aStr);
        wrapClass = ConfClass.SVMXC_Set_CreateWarranty_IPW(IBList,IBtoWarranty);
      
        SVMXC.IPRD_Utils.SVMX_CalcWarrEndDate(system.today(), 0, null);
        SVMXC.IPRD_Utils.SVMX_CalcWarrEndDate(system.today(), -2, null);
        SVMXC.IPRD_Utils.SVMX_CalcWarrEndDate(system.today(), 100, 'Days');
        SVMXC.IPRD_Utils.SVMX_CalcWarrEndDate(system.today(), 100, 'Weeks');
        SVMXC.IPRD_Utils.SVMX_CalcWarrEndDate(system.today(), 100, 'Months');
        SVMXC.IPRD_Utils.SVMX_CalcWarrEndDate(system.today(), 100, 'Years');
        SVMXC.IPRD_Utils.SVMX_CalcWarrEndDate(system.today(), 100, 'dmy');
    
    }
}