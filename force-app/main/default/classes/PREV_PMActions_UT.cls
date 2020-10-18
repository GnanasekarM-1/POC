@isTest(SeeAllData=true)
private with sharing class PREV_PMActions_UT 
{
    static testMethod void PREV_PMActions_Test() 
    {
        
         Account account = new Account(
                                        Name ='Account',
                                        ShippingStreet='ABC',
                                        ShippingCity='PQR ',
                                        ShippingState = 'XYZ',
                                        ShippingPostalCode='111',
                                        ShippingCountry='XYZ',
                                        BillingStreet='ABC',
                                        BillingCity='PQR ',
                                        BillingState = 'XYZ',
                                        BillingPostalCode='111',
                                        BillingCountry='XYZ'
                                        ); 
         insert account;
         system.assert(account.Name!=null);
         system.assert(account.ShippingStreet!=null);
         system.assert(account.ShippingState!=null);

         
         Product2 prod1 = new Product2(
                                       Name = 'Prod1', 
                                       ProductCode = '1235', 
                                       Family = 'Accessory', 
                                       SVMXC__Inherit_Parent_Warranty__c =True 
                                       );
        insert prod1;
        system.assert(prod1.Name!=null);
        system.assert(prod1.ProductCode!=null);
        
        SVMXC__Installed_Product__c IBObject1 = new SVMXC__Installed_Product__c(
                                       Name = 'Test IB1',
                                       SVMXC__Status__c = 'Installed',
                                       SVMXC__Product__c = prod1.Id,
                                       SVMXC__Date_Installed__c = System.Today(),
                                       SVMXC__Company__c = account.Id
                                       );
        insert IBObject1;
        system.assert(IBObject1.Name!=null);
        system.assert(IBObject1.SVMXC__Status__c!=null);
        
        SVMXC__Service_Contract__c SconObject = new SVMXC__Service_Contract__c(
                                             Name='ZZ1',
                                             SVMXC__Company__c=account.Id,
                                             SVMXC__End_Date__c = system.Today().addDays(60),
                                             SVMXC__Start_Date__c = system.Today().addDays(-30),
                                             OwnerId =UserInfo.getUserId() 
                                             //SVMXC__Service_Level__c= sconSLA.id
                                             );
        insert SconObject;
        system.assert(SconObject.Name!=null);
        system.assert(SconObject.SVMXC__Company__c!=null);
        SVMXC__Task_Template__c tasktempone = new SVMXC__Task_Template__c();
        tasktempone.SVMXC__Template_Name__c = 'Tempone';
        tasktempone.SVMXC__Task_Title__c = 'Tempone';
        tasktempone.SVMXC__Template_Type__c = 'Preventive Maintenance';
        tasktempone.SVMXC__Priority__c = 'Normal';
        insert tasktempone;
         SVMXC__PM_Plan__c pmplanone  = new SVMXC__PM_Plan__c(
                                
                                        Name = 'PM Plan One',
                                        SVMXC__Service_Contract__c = SconObject.id,
                                        SVMXC__Task_Template__c = tasktempone.id,
                                        SVMXC__Start_Date__c = system.Today().addDays(-30),
                                        SVMXC__End_Date__c = system.Today().addDays(60),
                                        SVMXC__Schedule_Type__c ='Time Based',
                                        //SVMXC__Field_map_for_wo__c = smaxprocess[0].SVMXC__MapID__c,
                                        //SVMXC__Field_map_for_Case__c = smaxprocess[1].SVMXC__MapID__c,
                                        SVMXC__Work_Order_Assign_To__c='USER',
                                        SVMXC__Work_Order_Assign_To_User__c=UserInfo.getUserId(),
                                        SVMXC__Number_of_Work_orders__c='ONE PER PRODUCT',
                                        SVMXC__Number_of_Cases__c ='ONE PER WORK ORDER',
                                        SVMXC__Create_Case__c = true,
                                        SVMXC__Success_Email_ID__c ='success@test.com',
                                        SVMXC__Error_Email_ID__c ='error@test.com',
                                        SVMXC__Next_PM_Date__c = system.Today(),
                                        SVMXC__Work_Order_Date__c = system.Today(),
                                        SVMXC__Frequency__c =2,
                                        SVMXC__Frequency_Unit__c ='Months',
                                        SVMXC__Status__c ='Active'
                                        );
                                        
        insert pmplanone; 
        system.assert(pmplanone.id != null);
        
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
        newSC.SVMXC__Company__c = account.Id;
        insert newSC;
        SC.add(newSC);
        
        
        Product2 newProduct = new Product2();
        newProduct.Name = 'Computer';
        insert newProduct;
        system.assert(newProduct.Name !=null); 
        List<SVMXC__Installed_Product__c> lstIB = new List<SVMXC__Installed_Product__c>();
        SVMXC__Installed_Product__c IB1 = new SVMXC__Installed_Product__c();
        IB1.SVMXC__Product__c = prod1.Id;
        IB1.SVMXC__Company__c = account.Id;
        lstIB.add(IB1);
        insert lstIB; 
        SVMXC__Service_Contract_Products__c CP = new SVMXC__Service_Contract_Products__c();
        CP.SVMXC__Exchange_type__c = 'Return Exchange';
        CP.SVMXC__Start_Date__c  = system.today();
        CP.SVMXC__End_Date__c  = system.today() + 1;
        CP.SVMXC__Service_Contract__c = SconObject.Id;
        CP.SVMXC__Product__c = prod1.Id;
        CP.SVMXC__Installed_Product__c = IBObject1.Id;
        insert CP;
        system.assert(CP.SVMXC__Exchange_type__c !=null); 
        RecordType RType = new RecordType();
        RType = [select Id from RecordType where Name=:'Technician'];
        
        SVMXC__Service_Group__c Team = new SVMXC__Service_Group__c();
        Team.RecordTypeId = RType.id;
        Team.Name = 'OS Installation';
        insert Team;
        SVMXC__Service_Group_Members__c Tech = new SVMXC__Service_Group_Members__c();        
        Tech.Name = 'OS Installation';
        Tech.SVMXC__Service_Group__c = Team.id;
        insert Tech; 
        
        list<SVMXC__Service_Order__c>  lstWO = new list<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c oldWO = new SVMXC__Service_Order__c();
        oldWO.SVMXC__Order_Status__c = 'new';
        //insert oldWO;
        lstWO.add(oldWO);
        
        SVMXC__Service_Order__c NewWO = new SVMXC__Service_Order__c();
        NewWO.SVMXC__Order_Status__c = 'Closed';
        NewWO.SVMXC__Is_PM_Work_Order__c = true;
        NewWO.SVMXC__Component__c = IBObject1.id;
        NewWO.SVMXC__PM_Plan__c = pmplanone.id;
        NewWO.SVMXC__Group_Member__c = Tech.id;
        NewWO.SVMXC__PM_Tasks_Created__c= false;        
        //insert NewWO;
        lstWO.add(NewWO);
        
        SVMXC__Service_Order__c NewWO1 = new SVMXC__Service_Order__c();
        NewWO1.SVMXC__Order_Status__c = 'Closed';
        NewWO1.SVMXC__Is_PM_Work_Order__c = true;
        NewWO1.SVMXC__Component__c = IBObject1.id;
        NewWO1.SVMXC__PM_Plan__c = pmplanone.id;
        NewWO1.SVMXC__Group_Member__c = Tech.id;
        NewWO1.SVMXC__PM_Tasks_Created__c= false;
        //insert NewWO1;
        lstWO.add(NewWO1);
        
        insert lstWO;
        
        SVMXC__Service_Order__c[] objOldLst = new SVMXC__Service_Order__c[]{};
        SVMXC__Service_Order__c[] NewOldLst = new SVMXC__Service_Order__c[]{};
        
        objOldLst.add(oldWO);
        NewOldLst.add(NewWO);
        objOldLst.add(NewWO1);
        NewOldLst.add(NewWO1);
        SVMXC.PREV_PMActions PMObject = new SVMXC.PREV_PMActions(); 
        PMObject.WorkOrderActions(objOldLst,NewOldLst,true,false);
        PMObject.WorkOrderActions(objOldLst,NewOldLst,false,true);
        SVMXC.PREV_PMActions PMObject1 = new SVMXC.PREV_PMActions(new Map<String, String>()); 
        PMObject.updateInstalledProdCount(new Map<Id, Integer>(), IBObject1.id);
    }
}