@isTest (SeeAllData=true)
private class WORD_AutoEntitlement_UT 
{
    static Account oAccount;
    static Contact oContact;
    
    static testMethod void WORD_AutoEntitlementUnitTest1() 
    { 
        RecordType[] Rtypes = [select Id, DeveloperName, Name, SobjectType from RecordType where SobjectType IN ('SVMXC__ServiceMax_Processes__c','SVMXC__ServiceMax_Config_Data__c','SVMXC__Counter_Details__c','SVMXC__Service_Order_Line__c')];
        RecordType Rtype, ExpressionsUT, RtypeCoverage, RtypeReading, RtypeDef, RtypeProdServiced;
        for(RecordType rt : Rtypes)
        {
            if(rt.Name == 'SVMX Rule')
                Rtype = rt;
            else if(rt.Name == 'Expressions')
                ExpressionsUT = rt;
            else if(rt.Name == 'Coverage')
                RtypeCoverage = rt;
            else if(rt.Name == 'Reading')
                RtypeReading = rt;
            else if(rt.Name == 'Definition')
                RtypeDef = rt;
            else if(rt.DeveloperName == 'Products_Serviced')
                RtypeProdServiced = rt;
        }
        oAccount = new Account(Name ='Account');
        insert oAccount;
    
        oContact = new Contact(LastName='Last', AccountID = oAccount.Id,Email='svmxmailfortest@servicemax.com');
        insert oContact;
    
        SVMXC__Site__c oSite = new SVMXC__Site__c();
        insert oSite;     
        
        Product2 prod1 = new Product2(Name = 'Prod1');
        insert prod1; 
        
        SVMXC__Installed_Product__c IB0 = new SVMXC__Installed_Product__c( Name = 'IB0', SVMXC__Product__c = prod1.Id, SVMXC__Company__c = oAccount.Id  , SVMXC__Contact__c =oContact.Id, SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today() ); 
        insert IB0;
        
        SVMXC__Installed_Product__c IB1 = new SVMXC__Installed_Product__c(Name = 'IB1', SVMXC__Product__c = prod1.Id, SVMXC__Company__c = oAccount.Id  , SVMXC__Contact__c =oContact.Id, SVMXC__Top_Level__c = IB0.Id, SVMXC__Parent__c = IB0.Id , SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today()); 
        insert IB1;
        
        list<SVMXC__Warranty__c> lstWarranty =  new list<SVMXC__Warranty__c>();
        SVMXC__Warranty__c oW1 = new SVMXC__Warranty__c(SVMXC__Installed_Product__c = IB0.Id, SVMXC__Start_Date__c = date.today().addDays(-1), SVMXC__End_Date__c = date.today().addDays(1));
        lstWarranty.add(oW1); 
        
        SVMXC__Warranty__c oW2 = new SVMXC__Warranty__c(SVMXC__Installed_Product__c = IB1.Id, SVMXC__Start_Date__c = date.today().addDays(-1), SVMXC__End_Date__c = date.today().addDays(1));
        lstWarranty.add(oW2);
        insert lstWarranty;
        
        SVMXC__Service_Contract__c SVMXServiceContract = new SVMXC__Service_Contract__c(SVMXC__Active__c = true, SVMXC__Company__c = oAccount.id, SVMXC__Start_Date__c = date.today().addDays(-1), SVMXC__End_Date__c = date.today().addDays(1));
        insert SVMXServiceContract;
        
        SVMXC__Service_Contract_Contacts__c scc = new SVMXC__Service_Contract_Contacts__c(SVMXC__Contact__c = oContact.id, SVMXC__Service_Contract__c = SVMXServiceContract.id);
        insert scc;
        
        SVMXC__Service_Contract_Sites__c scs =new SVMXC__Service_Contract_Sites__c(SVMXC__site__c = oSite.id, SVMXC__Service_Contract__c = SVMXServiceContract.id);
        insert scs;
        
        list<SVMXC__Service_Contract_Products__c> lstSCP =  new list<SVMXC__Service_Contract_Products__c>();
        SVMXC__Service_Contract_Products__c oSCP1 = new SVMXC__Service_Contract_Products__c(SVMXC__Service_Contract__c = SVMXServiceContract.Id, SVMXC__Installed_Product__c = IB0.Id, SVMXC__Start_Date__c = date.today().addDays(-1), SVMXC__End_Date__c = date.today().addDays(1));
        lstSCP.add(oSCP1); 
        
        SVMXC__Service_Contract_Products__c oSCP2 = new SVMXC__Service_Contract_Products__c(SVMXC__Service_Contract__c = SVMXServiceContract.Id, SVMXC__Installed_Product__c = IB1.Id, SVMXC__Start_Date__c = date.today().addDays(-1), SVMXC__End_Date__c = date.today().addDays(1));
        lstSCP.add(oSCP2);
        insert lstSCP;      
        
        SVMXC__Service_Template__c WT1 = new SVMXC__Service_Template__c( SVMXC__Walk_in_Allowed__c =false, SVMXC__Unit_of_Time__c = '100', SVMXC__Unit_of_Time_Material__c= 'Days', SVMXC__Unit_of_Time_Expenses__c='Months', SVMXC__Transferable__c=false, SVMXC__Time_Covered__c=100, SVMXC__Template_Type__c='Warranty', SVMXC__Shipment_Allowed__c=false, SVMXC__RMA_Required__c=true, SVMXC__Onsite_Repair__c=true, SVMXC__Material_Covered__c=100, SVMXC__Loaner_Provided__c=false, SVMXC__Invoice_Required__c=false, SVMXC__Expenses_Covered__c=100, SVMXC__Duration_of_Time_Coverage__c=100, SVMXC__Duration_of_Material_Coverage__c=365, SVMXC__Duration_of_Expenses__c=52, SVMXC__Coverage_Effective_From__c='Install Date', SVMXC__All_Services_Covered__c=false, SVMXC__All_Products_Covered__c=false, Name ='Template1' );
        insert WT1;
        
        SVMXC__Counter_Details__c Counterdef = new SVMXC__Counter_Details__c( RecordTypeId = RtypeDef.Id, SVMXC__Counter_Name__c = 'Test', SVMXC__Counter_Reading__c = 51, SVMXC__Grows_Reduces_By__c=1, SVMXC__Min_Value__c = 50, SVMXC__Max_Value__c = 100, SVMXC__Installed_Product__c = IB1.Id, SVMXC__Counter_Type__c='Decreasing');
        insert Counterdef;
        
        SVMXC__Counter_Details__c CounterReading = new SVMXC__Counter_Details__c( RecordTypeId = RtypeReading.Id, SVMXC__Counter_Definition__c=Counterdef.Id, SVMXC__Counter_Name__c = 'Test', SVMXC__Counter_Reading__c = 51, SVMXC__Grows_Reduces_By__c=1, SVMXC__Min_Value__c = 50, SVMXC__Max_Value__c = 100, SVMXC__Installed_Product__c = IB1.Id, SVMXC__Product__c = prod1.Id);
        insert CounterReading;
        
        SVMXC__Counter_Details__c CoverageCounter = new SVMXC__Counter_Details__c( RecordTypeID = RtypeCoverage.Id, SVMXC__Product__c = prod1.Id, SVMXC__Counter_Definition__c=Counterdef.Id, SVMXC__Counter_Name__c = 'Test', SVMXC__Counter_Reading__c = 51, SVMXC__Grows_Reduces_By__c=1, SVMXC__Min_Value__c = 50, SVMXC__Max_Value__c = 100, SVMXC__Installed_Product__c = IB1.Id, SVMXC__Service_Maintenance_Contract__c = SVMXServiceContract.Id, SVMXC__Warranty_Terms__c = WT1.Id, SVMXC__Coverage_Limit__c = 55, SVMXC__Coverage_Starts_At__c = 40); 
        insert CoverageCounter;

        list<SVMXC__Service_Order__c> lstWO = new list<SVMXC__Service_Order__c>();
        list<SVMXC__Service_Order_Line__c> lstWOLines = new list<SVMXC__Service_Order_Line__c>();
        
        SVMXC__Service_Order__c WO1 = new SVMXC__Service_Order__c(SVMXC__Entitlement_Type__c ='AUTO', SVMXC__Country__c= 'Operator1' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Site__c=oSite.id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true,SVMXC__Service_Contract__c = SVMXServiceContract.Id,SVMXC__Product__c=prod1.Id);      //SVMXC__Service_Contract__c = SVMXServiceContract.Id,
        lstWO.add(WO1);

        SVMXC__Service_Order__c WO2 = new SVMXC__Service_Order__c(SVMXC__Entitlement_Type__c ='AUTO', SVMXC__Country__c= 'Operator2' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Site__c=oSite.id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true,SVMXC__Service_Contract__c = SVMXServiceContract.Id, SVMXC__Product__c=prod1.Id);      
        lstWO.add(WO2);

        SVMXC__Service_Order__c WO3 = new SVMXC__Service_Order__c(SVMXC__Entitlement_Type__c ='AUTO', SVMXC__Country__c= 'Operator3' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Site__c=oSite.id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true,SVMXC__Service_Contract__c = SVMXServiceContract.Id, SVMXC__Product__c=prod1.Id);      
        lstWO.add(WO3);
        insert lstWO;
        
        SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO1.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        lstWOLines.add(WOLine1); 
        
        SVMXC__Service_Order_Line__c WOLine2 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO2.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        lstWOLines.add(WOLine2); 

        SVMXC__Service_Order_Line__c WOLine3 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO3.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        lstWOLines.add(WOLine3); 
        
        insert lstWOLines;
        
        for(SVMXC__Service_Order__c serviceOrder : lstWO){
            serviceOrder.SVMXC__Perform_Auto_Entitlement__c = true;    
        }
        
        update lstWO;
        
        list<SVMXC__ServiceMax_Processes__c> tmpLstProcess = [SELECT Id, RecordTypeId, SVMXC__Rule_Type__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' AND (SVMXC__Rule_Type__c = 'Auto Entitlement WO' OR SVMXC__Rule_Type__c = 'Counters')];
        delete tmpLstProcess;

        list<SVMXC__ServiceMax_Processes__c> lstProcess = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c AEProcess1 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = true, SVMXC__Allow_Override__c = true, SVMXC__Include_Parent__c = true, SVMXC__Field_Name__c = 'Product', SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, SVMXC__Rule_Type__c='Auto Entitlement WO', SVMXC__Entitlement_Scope__c='Both', SVMXC__Entitlement_By__c='Both', SVMXC__Pick_First_Match__c = 'Warranty', SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=true, SVMXC__Counter_Vs_Dates_Rule__c = 'Whichever Is Valid', SVMXC__Advance_Expression__c = 'T',SVMXC__Enable_Child_Line_Entitlement__c = true);
        lstProcess.add(AEProcess1);

        SVMXC__ServiceMax_Processes__c AEProcess2 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = true, SVMXC__Allow_Override__c = true, SVMXC__Include_Parent__c = true, SVMXC__Field_Name__c = 'Product', SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, SVMXC__Rule_Type__c='Auto Entitlement WO', SVMXC__Entitlement_Scope__c='Warranties', SVMXC__Entitlement_By__c='Both', SVMXC__Pick_First_Match__c = 'Warranty', SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=true, SVMXC__Counter_Vs_Dates_Rule__c = 'Whichever Is Valid',SVMXC__Enable_Child_Line_Entitlement__c = true);
        lstProcess.add(AEProcess2);

        SVMXC__ServiceMax_Processes__c AEProcess3 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = true, SVMXC__Allow_Override__c = true, SVMXC__Include_Parent__c = true, SVMXC__Field_Name__c = 'Product', SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, SVMXC__Rule_Type__c='Auto Entitlement WO', SVMXC__Entitlement_Scope__c='Service Contracts', SVMXC__Entitlement_By__c='Both', SVMXC__Pick_First_Match__c = 'Warranty', SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=true, SVMXC__Counter_Vs_Dates_Rule__c = 'Whichever Is Valid',SVMXC__Enable_Child_Line_Entitlement__c = true);
        lstProcess.add(AEProcess3);
        
        SVMXC__ServiceMax_Processes__c AEProcess4 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = true, SVMXC__Allow_Override__c = false, SVMXC__Include_Parent__c = true, SVMXC__Field_Name__c = 'Product', SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, SVMXC__Rule_Type__c='Counters', SVMXC__Entitlement_Scope__c='Service Contracts', SVMXC__Entitlement_By__c='Both', SVMXC__Pick_First_Match__c = 'Warranty', SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=true, SVMXC__Counter_Vs_Dates_Rule__c = 'Whichever Is Valid',SVMXC__Enable_Child_Line_Entitlement__c = true);
        lstProcess.add(AEProcess4);
        
        SVMXC__ServiceMax_Processes__c AEProcess5 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = true, SVMXC__Allow_Override__c = false, SVMXC__Include_Parent__c = true, SVMXC__Field_Name__c = 'Product', SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, SVMXC__Rule_Type__c='Counters', SVMXC__Entitlement_Scope__c='Service Contracts', SVMXC__Entitlement_By__c='Validity dates', SVMXC__Pick_First_Match__c = 'Warranty', SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=true, SVMXC__Counter_Vs_Dates_Rule__c = 'Whichever Is Valid',SVMXC__Enable_Child_Line_Entitlement__c = true);
        lstProcess.add(AEProcess5);
        insert lstProcess;

        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c Cnfig1 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'EQ', SVMXC__Operand__c='Operator1', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='WO_Auto_Entitlement', SVMXC__Expression_Rule__c=AEProcess1.Id, SVMXC__Display_Type__c='STRING');
        lstConfigData.add(Cnfig1);

        SVMXC__ServiceMax_Config_Data__c Cnfig2 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'EQ', SVMXC__Operand__c='Operator2', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='WO_Auto_Entitlement', SVMXC__Expression_Rule__c=AEProcess2.Id, SVMXC__Display_Type__c='STRING');
        lstConfigData.add(Cnfig2);

        SVMXC__ServiceMax_Config_Data__c Cnfig3 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'EQ', SVMXC__Operand__c='Operator3', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='WO_Auto_Entitlement', SVMXC__Expression_Rule__c=AEProcess3.Id, SVMXC__Display_Type__c='STRING');
        lstConfigData.add(Cnfig3);
        
        SVMXC__ServiceMax_Config_Data__c Cnfig4 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'EQ', SVMXC__Operand__c='Operator1', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='EXP_Named', SVMXC__Expression_Rule__c = AEProcess1.Id, SVMXC__Display_Type__c='STRING');
        lstConfigData.add(Cnfig4);
        
        insert lstConfigData;
        
        SVMXC__Service__c oService = new SVMXC__Service__c( SVMXC__Qualifying_Criteria__c = AEProcess1.id, SVMXC__Tracked_On__c = 'Work Order');
        insert oService;

        SVMXC__Service_Contract_Services__c scServices = new SVMXC__Service_Contract_Services__c(SVMXC__Service_Contract__c = SVMXServiceContract.Id, SVMXC__Service__c = oService.id);
        insert scServices;
        
        SVMXC__Entitlement_History__c eh = new SVMXC__Entitlement_History__c(SVMXC__Service_Order__c = WO1.Id); 
        insert eh;
        
        List<String> lstIdsWO = new List<String>();
        lstIdsWO.add(WO1.id);
        lstIdsWO.add(WO2.id);
        lstIdsWO.add(WO3.id);
        
        WORD_AutoEntitlement WOAEntl = new WORD_AutoEntitlement();
        
        INTF_WebServicesDef.INTF_Request req = new INTF_WebServicesDef.INTF_Request();
        req.recordIds = lstIdsWO;
        
        List<SVMXC__ServiceMax_Config_Data__c> lst = [select id from SVMXC__ServiceMax_Config_Data__c where SVMXC__Setting_Unique_ID__c IN ('EVER007_SET004')];
        for(SVMXC__ServiceMax_Config_Data__c conf: lst)
            conf.SVMXC__Internal_Value__c = 'TRUE';
        upsert  lst; 
        test.startTest();
        WOAEntl.SVMX_DoEntitlement(req);
        
        //WOAEntl.mapCounterReadings.get(IB1.id).SVMXC__Counter_Definition__r.SVMXC__Counter_Type__c = 'Increasing';
        WOAEntl.updateCounterMaps(IB1.id);
        
        List<Id> componentOrderList = WOAEntl.getcomponentOrderList(AEProcess1, WO1.SVMXC__Component__c);
        WORD_AutoEntitlement.EntitlementInfoWrapper infoWrapper = new WORD_AutoEntitlement.EntitlementInfoWrapper();
        infoWrapper = WOAEntl.getServiceContractOnBoth(componentOrderList,AEProcess1,WO1,0);
        
        //WO1.SVMXC__Component__c = null;
        //WOAEntl.getServiceContractOnBoth(WO1, AEProcess1, 0);
        infoWrapper = WOAEntl.getServiceContractOnBoth(componentOrderList,AEProcess1,WO1,0);
        //WOAEntl.getServiceContractOnValidityDate(WO1, AEProcess1, 0);
        
        //WOAEntl.mapIBServiceContractCoverage.get(IB1.Id).get(0).SVMXC__Service_Contract__r.SVMXC__Company__c = null;
        infoWrapper = WOAEntl.getServiceContractOnValidityDate(componentOrderList,AEProcess1,WO1, 0);
        infoWrapper = WOAEntl.getServiceContractOnBoth(componentOrderList,AEProcess1,WO1,0);
        
        //WOAEntl.mapIBServiceContractCoverage.get(IB1.Id).get(0).SVMXC__Start_Date__c = null;    
        infoWrapper = WOAEntl.getServiceContractOnValidityDate(componentOrderList,AEProcess1,WO1, 0);
        
        infoWrapper = WOAEntl.getServiceContractOnBoth(componentOrderList,AEProcess1,WO1,0);
        
        Map<String, String> mapSettings = new Map<String, String>();
        mapSettings.put('EVER007_SET001', 'TRUE'); 
        mapSettings.put('EVER007_SET004', 'TRUE');
        
        list<SVMXC__Service_Order__c> lstWO1 = new list<SVMXC__Service_Order__c>{new SVMXC__Service_Order__c(), new SVMXC__Service_Order__c(), new SVMXC__Service_Order__c()};
        for(SVMXC__Service_Order__c objWO : lstWO)
        {
            objWO.SVMXC__Warranty__c = oW1.Id;
            objWO.SVMXC__Perform_Auto_Entitlement__c = false;
            objWO.SVMXC__Service_Contract__c = SVMXServiceContract.Id;
        }
        
        List<SVMXC__Service_Contract__c> listServiceContract = new List<SVMXC__Service_Contract__c>();
        listServiceContract.add(SVMXServiceContract);
        WORD_AutoEntitlement.mapWOIndexContractIBCvrg.clear();
        WORD_AutoEntitlement.mapWOIndexContractIBCvrg.put(0,oSCP2);
        infoWrapper = WOAEntl.getWarrantyOnBoth(componentOrderList,WO1,false);
        infoWrapper = WOAEntl.getServiceContractOnLocation (AEProcess1,WO1, 0);
        WOAEntl.SVMX_UpdateEntitlementHistory(lstWO, lstWO1, mapSettings);
        lstWO1 = null;
        WOAEntl.SVMX_UpdateEntitlementHistory(lstWO, lstWO1, mapSettings);
        test.stopTest();
    } 
    
    static testMethod void WORD_AutoEntitlementUnitTest2() 
    { 
        RecordType[] Rtypes = [select Id, DeveloperName, Name, SobjectType from RecordType where SobjectType IN ('SVMXC__ServiceMax_Processes__c','SVMXC__ServiceMax_Config_Data__c','SVMXC__Counter_Details__c','SVMXC__Service_Order_Line__c')];
        RecordType Rtype, ExpressionsUT, RtypeCoverage, RtypeReading, RtypeDef, RtypeProdServiced;
        for(RecordType rt : Rtypes)
        {
            if(rt.Name == 'SVMX Rule')
                Rtype = rt;
            else if(rt.Name == 'Expressions')
                ExpressionsUT = rt;
            else if(rt.Name == 'Coverage')
                RtypeCoverage = rt;
            else if(rt.Name == 'Reading')
                RtypeReading = rt;
            else if(rt.Name == 'Definition')
                RtypeDef = rt;
            else if(rt.DeveloperName == 'Products_Serviced')
                RtypeProdServiced = rt;
        }
        oAccount = new Account(Name ='Account');
        insert oAccount;
    
        oContact = new Contact(LastName='Last', AccountID = oAccount.Id,Email='svmxmailfortest@servicemax.com');
        insert oContact;
    
        SVMXC__Site__c oSite = new SVMXC__Site__c();
        insert oSite;     
        
        Product2 prod1 = new Product2(Name = 'Prod1');
        insert prod1; 
        
        SVMXC__Installed_Product__c IB0 = new SVMXC__Installed_Product__c( Name = 'IB0', SVMXC__Product__c = prod1.Id, SVMXC__Company__c = oAccount.Id  , SVMXC__Contact__c =oContact.Id, SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today() ); 
        insert IB0;
        
        SVMXC__Installed_Product__c IB1 = new SVMXC__Installed_Product__c(Name = 'IB1', SVMXC__Product__c = prod1.Id, SVMXC__Company__c = oAccount.Id  , SVMXC__Contact__c =oContact.Id, SVMXC__Top_Level__c = IB0.Id, SVMXC__Parent__c = IB0.Id , SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today()); 
        insert IB1;
        
        list<SVMXC__Warranty__c> lstWarranty =  new list<SVMXC__Warranty__c>();
        SVMXC__Warranty__c oW1 = new SVMXC__Warranty__c(SVMXC__Installed_Product__c = IB0.Id, SVMXC__Start_Date__c = date.today().addDays(-1), SVMXC__End_Date__c = date.today().addDays(1));
        lstWarranty.add(oW1); 
        
        SVMXC__Warranty__c oW2 = new SVMXC__Warranty__c(SVMXC__Installed_Product__c = IB1.Id, SVMXC__Start_Date__c = date.today().addDays(-1), SVMXC__End_Date__c = date.today().addDays(1));
        lstWarranty.add(oW2);
        insert lstWarranty;
        
         SVMXC__Service_Contract__c SVMXServiceContract = new SVMXC__Service_Contract__c(SVMXC__Active__c = true, SVMXC__Company__c = oAccount.id, SVMXC__Start_Date__c = date.today().addDays(-1), SVMXC__End_Date__c = date.today().addDays(1));
        insert SVMXServiceContract;
        
        SVMXC__Service_Contract_Contacts__c scc = new SVMXC__Service_Contract_Contacts__c(SVMXC__Contact__c = oContact.id, SVMXC__Service_Contract__c = SVMXServiceContract.id);
        insert scc;
        
        SVMXC__Service_Contract_Sites__c scs =new SVMXC__Service_Contract_Sites__c(SVMXC__site__c = oSite.id, SVMXC__Service_Contract__c = SVMXServiceContract.id);
        insert scs;
        
        list<SVMXC__Service_Contract_Products__c> lstSCP =  new list<SVMXC__Service_Contract_Products__c>();
        SVMXC__Service_Contract_Products__c oSCP1 = new SVMXC__Service_Contract_Products__c(SVMXC__Service_Contract__c = SVMXServiceContract.Id, SVMXC__Installed_Product__c = IB0.Id, SVMXC__Start_Date__c = date.today().addDays(-1), SVMXC__End_Date__c = date.today().addDays(1));
        lstSCP.add(oSCP1); 
        
        SVMXC__Service_Contract_Products__c oSCP2 = new SVMXC__Service_Contract_Products__c(SVMXC__Service_Contract__c = SVMXServiceContract.Id, SVMXC__Installed_Product__c = IB1.Id, SVMXC__Start_Date__c = date.today().addDays(-1), SVMXC__End_Date__c = date.today().addDays(1));
        lstSCP.add(oSCP2);
        insert lstSCP;      
        
        SVMXC__Service_Template__c WT1 = new SVMXC__Service_Template__c( SVMXC__Walk_in_Allowed__c =false, SVMXC__Unit_of_Time__c = '100', SVMXC__Unit_of_Time_Material__c= 'Days', SVMXC__Unit_of_Time_Expenses__c='Months', SVMXC__Transferable__c=false, SVMXC__Time_Covered__c=100, SVMXC__Template_Type__c='Warranty', SVMXC__Shipment_Allowed__c=false, SVMXC__RMA_Required__c=true, SVMXC__Onsite_Repair__c=true, SVMXC__Material_Covered__c=100, SVMXC__Loaner_Provided__c=false, SVMXC__Invoice_Required__c=false, SVMXC__Expenses_Covered__c=100, SVMXC__Duration_of_Time_Coverage__c=100, SVMXC__Duration_of_Material_Coverage__c=365, SVMXC__Duration_of_Expenses__c=52, SVMXC__Coverage_Effective_From__c='Install Date', SVMXC__All_Services_Covered__c=false, SVMXC__All_Products_Covered__c=false, Name ='Template1' );
        insert WT1;
        
        SVMXC__Counter_Details__c Counterdef = new SVMXC__Counter_Details__c( RecordTypeId = RtypeDef.Id, SVMXC__Counter_Name__c = 'Test', SVMXC__Counter_Reading__c = 51, SVMXC__Grows_Reduces_By__c=1, SVMXC__Min_Value__c = 50, SVMXC__Max_Value__c = 100, SVMXC__Installed_Product__c = IB1.Id, SVMXC__Counter_Type__c='Decreasing');
        insert Counterdef;
        
        SVMXC__Counter_Details__c CounterReading = new SVMXC__Counter_Details__c( RecordTypeId = RtypeReading.Id, SVMXC__Counter_Definition__c=Counterdef.Id, SVMXC__Counter_Name__c = 'Test', SVMXC__Counter_Reading__c = 51, SVMXC__Grows_Reduces_By__c=1, SVMXC__Min_Value__c = 50, SVMXC__Max_Value__c = 100, SVMXC__Installed_Product__c = IB1.Id, SVMXC__Product__c = prod1.Id);
        insert CounterReading;
        
        SVMXC__Counter_Details__c CoverageCounter = new SVMXC__Counter_Details__c( RecordTypeID = RtypeCoverage.Id, SVMXC__Product__c = prod1.Id, SVMXC__Counter_Definition__c=Counterdef.Id, SVMXC__Counter_Name__c = 'Test', SVMXC__Counter_Reading__c = 51, SVMXC__Grows_Reduces_By__c=1, SVMXC__Min_Value__c = 50, SVMXC__Max_Value__c = 100, SVMXC__Installed_Product__c = IB1.Id, SVMXC__Service_Maintenance_Contract__c = SVMXServiceContract.Id, SVMXC__Warranty_Terms__c = WT1.Id, SVMXC__Coverage_Limit__c = 55, SVMXC__Coverage_Starts_At__c = 40); 
        insert CoverageCounter;

        list<SVMXC__Service_Order__c> lstWO = new list<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c WO1 = new SVMXC__Service_Order__c(SVMXC__Entitlement_Type__c ='AUTO', SVMXC__Country__c= 'Operator1' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Site__c=oSite.id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true, SVMXC__Service_Contract__c = SVMXServiceContract.Id, SVMXC__Product__c=prod1.Id);      //SVMXC__Service_Contract__c = SVMXServiceContract.Id, 
        lstWO.add(WO1);

        SVMXC__Service_Order__c WO2 = new SVMXC__Service_Order__c(SVMXC__Entitlement_Type__c ='AUTO', SVMXC__Country__c= 'Operator2' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Site__c=oSite.id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true, SVMXC__Service_Contract__c = SVMXServiceContract.Id,  SVMXC__Product__c=prod1.Id);      
        lstWO.add(WO2);

        SVMXC__Service_Order__c WO3 = new SVMXC__Service_Order__c(SVMXC__Entitlement_Type__c ='AUTO', SVMXC__Country__c= 'Operator3' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Site__c=oSite.id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true, SVMXC__Service_Contract__c = SVMXServiceContract.Id,  SVMXC__Product__c=prod1.Id);      
        lstWO.add(WO3);
        insert lstWO;
        
        list<SVMXC__Service_Order_Line__c> lstWOLines = new list<SVMXC__Service_Order_Line__c>();
        SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO1.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        lstWOLines.add(WOLine1); 
        
        SVMXC__Service_Order_Line__c WOLine2 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO2.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        lstWOLines.add(WOLine2); 

        SVMXC__Service_Order_Line__c WOLine3 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO3.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        lstWOLines.add(WOLine3); 
        
        insert lstWOLines;

        for(SVMXC__Service_Order__c serviceOrder : lstWO){
            serviceOrder.SVMXC__Perform_Auto_Entitlement__c = true;    
        }
        
        update lstWO;
        

        list<SVMXC__ServiceMax_Processes__c> tmpLstProcess = [SELECT Id, RecordTypeId, SVMXC__Rule_Type__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' AND (SVMXC__Rule_Type__c = 'Auto Entitlement WO' OR SVMXC__Rule_Type__c = 'Counters')];
        delete tmpLstProcess;
        
        list<SVMXC__ServiceMax_Processes__c> lstProcess = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c AEProcess1 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = true, SVMXC__Include_Parent__c = true,SVMXC__Field_Name__c ='Product', SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, SVMXC__Rule_Type__c='Auto Entitlement WO', SVMXC__Entitlement_Scope__c='Both', SVMXC__Entitlement_By__c='Counters', SVMXC__Pick_First_Match__c = 'Warranty', SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=true, SVMXC__Counter_Vs_Dates_Rule__c = 'Whichever Is Valid',
                                                                                          SVMXC__Enable_Child_Line_Entitlement__c = true);
        lstProcess.add(AEProcess1);

        SVMXC__ServiceMax_Processes__c AEProcess2 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = true, SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true,SVMXC__Field_Name__c ='Product', RecordTypeId=Rtype.Id, SVMXC__Rule_Type__c='Auto Entitlement WO', SVMXC__Entitlement_Scope__c='Warranties', SVMXC__Entitlement_By__c='Counters', SVMXC__Pick_First_Match__c = 'Warranty', SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=true, SVMXC__Counter_Vs_Dates_Rule__c = 'Whichever Is Valid',
                                                                                          SVMXC__Enable_Child_Line_Entitlement__c = true);
        lstProcess.add(AEProcess2);

        SVMXC__ServiceMax_Processes__c AEProcess3 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = false, SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true,SVMXC__Field_Name__c ='Product', RecordTypeId=Rtype.Id, SVMXC__Rule_Type__c='Auto Entitlement WO', SVMXC__Entitlement_Scope__c='Service Contracts', SVMXC__Entitlement_By__c='Counters', SVMXC__Pick_First_Match__c = 'Warranty', SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=true, SVMXC__Counter_Vs_Dates_Rule__c = 'Whichever Is Valid',
                                                                                          SVMXC__Enable_Child_Line_Entitlement__c = true);
        lstProcess.add(AEProcess3);
        
        SVMXC__ServiceMax_Processes__c AEProcess4 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = false, SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true,SVMXC__Field_Name__c ='Product', RecordTypeId=Rtype.Id, SVMXC__Rule_Type__c='Auto Entitlement WO', SVMXC__Entitlement_Scope__c='Service Contracts', SVMXC__Entitlement_By__c='Validity dates', SVMXC__Pick_First_Match__c = 'Warranty', SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=true, SVMXC__Counter_Vs_Dates_Rule__c = 'Whichever Is Valid',
                                                                                          SVMXC__Enable_Child_Line_Entitlement__c = true);
        lstProcess.add(AEProcess4);
        
        SVMXC__ServiceMax_Processes__c AEProcess5 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = true, SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, SVMXC__Field_Name__c ='Account',RecordTypeId=Rtype.Id, SVMXC__Rule_Type__c='Auto Entitlement WO', SVMXC__Entitlement_Scope__c='Service Contracts', SVMXC__Entitlement_By__c='Validity dates', SVMXC__Pick_First_Match__c = 'Warranty', SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=true, SVMXC__Counter_Vs_Dates_Rule__c = 'Whichever Is Valid',
                                                                                          SVMXC__Enable_Child_Line_Entitlement__c = true);
        lstProcess.add(AEProcess5);
        insert lstProcess;
        
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c Cnfig1 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'EQ', SVMXC__Operand__c='Operator1', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='WO_Auto_Entitlement', SVMXC__Expression_Rule__c=AEProcess1.Id, SVMXC__Display_Type__c='STRING');
        lstConfigData.add(Cnfig1);

        SVMXC__ServiceMax_Config_Data__c Cnfig2 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'EQ', SVMXC__Operand__c='Operator2', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='WO_Auto_Entitlement', SVMXC__Expression_Rule__c=AEProcess2.Id, SVMXC__Display_Type__c='STRING');
        lstConfigData.add(Cnfig2);

        SVMXC__ServiceMax_Config_Data__c Cnfig3 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'EQ', SVMXC__Operand__c='Operator3', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='WO_Auto_Entitlement', SVMXC__Expression_Rule__c=AEProcess3.Id, SVMXC__Display_Type__c='STRING');
        lstConfigData.add(Cnfig3);
        
        SVMXC__ServiceMax_Config_Data__c Cnfig4 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'EQ', SVMXC__Operand__c='Operator3', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='IPRD_Counters', SVMXC__Expression_Rule__c=AEProcess3.Id, SVMXC__Display_Type__c='STRING');
        lstConfigData.add(Cnfig4);
        insert lstConfigData;
        
        List<String> lstIdsWO = new List<String>();
        lstIdsWO.add(WO1.id);
        lstIdsWO.add(WO2.id);
        lstIdsWO.add(WO3.id);
        
        WORD_AutoEntitlement WOAEntl = new WORD_AutoEntitlement();
        
        INTF_WebServicesDef.INTF_Request req = new INTF_WebServicesDef.INTF_Request();
        req.recordIds = lstIdsWO;
        
        WOAEntl.SVMX_DoEntitlement(req);
    }
    
     static testMethod void WORD_AutoEntitlementUnitTest3() 
    { 
        RecordType[] Rtypes = [select Id, DeveloperName, Name, SobjectType from RecordType where SobjectType IN ('SVMXC__ServiceMax_Processes__c','SVMXC__ServiceMax_Config_Data__c','SVMXC__Counter_Details__c','SVMXC__Service_Order_Line__c')];
        RecordType Rtype, ExpressionsUT, RtypeCoverage, RtypeReading, RtypeDef, RtypeProdServiced;
        for(RecordType rt : Rtypes)
        {
            if(rt.Name == 'SVMX Rule')
                Rtype = rt;
            else if(rt.Name == 'Expressions')
                ExpressionsUT = rt;
            else if(rt.Name == 'Coverage')
                RtypeCoverage = rt;
            else if(rt.Name == 'Reading')
                RtypeReading = rt;
            else if(rt.Name == 'Definition')
                RtypeDef = rt;
            else if(rt.DeveloperName == 'Products_Serviced')
                RtypeProdServiced = rt;
        }
        
        oAccount = new Account(Name ='Account');
        insert oAccount;
    
        oContact = new Contact(LastName='Last', AccountID = oAccount.Id,Email='svmxmailfortest@servicemax.com');
        insert oContact;
    
        SVMXC__Site__c oSite = new SVMXC__Site__c();
        insert oSite;     
        
        Product2 prod1 = new Product2(Name = 'Prod1');
        insert prod1; 
        
        SVMXC__Installed_Product__c IB0 = new SVMXC__Installed_Product__c( Name = 'IB0', SVMXC__Product__c = prod1.Id, SVMXC__Company__c = oAccount.Id  , SVMXC__Contact__c =oContact.Id, SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today() ); 
        insert IB0;
        
        SVMXC__Installed_Product__c IB1 = new SVMXC__Installed_Product__c(Name = 'IB1', SVMXC__Product__c = prod1.Id, SVMXC__Company__c = oAccount.Id  , SVMXC__Contact__c =oContact.Id, SVMXC__Top_Level__c = IB0.Id, SVMXC__Parent__c = IB0.Id , SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today()); 
        insert IB1;
        
        list<SVMXC__Warranty__c> lstWarranty =  new list<SVMXC__Warranty__c>();
        SVMXC__Warranty__c oW1 = new SVMXC__Warranty__c(SVMXC__Installed_Product__c = IB0.Id, SVMXC__Start_Date__c = date.today().addDays(-1), SVMXC__End_Date__c = date.today().addDays(1));
        lstWarranty.add(oW1); 
        
        SVMXC__Warranty__c oW2 = new SVMXC__Warranty__c(SVMXC__Installed_Product__c = IB1.Id, SVMXC__Start_Date__c = date.today().addDays(-1), SVMXC__End_Date__c = date.today().addDays(1));
        lstWarranty.add(oW2);
        insert lstWarranty;
        
         SVMXC__Service_Contract__c SVMXServiceContract = new SVMXC__Service_Contract__c(SVMXC__Active__c = true, SVMXC__Company__c = oAccount.id, SVMXC__Start_Date__c = date.today().addDays(-1), SVMXC__End_Date__c = date.today().addDays(1));
        insert SVMXServiceContract;
        
        SVMXC__Service_Contract_Contacts__c scc = new SVMXC__Service_Contract_Contacts__c(SVMXC__Contact__c = oContact.id, SVMXC__Service_Contract__c = SVMXServiceContract.id);
        insert scc;
        
        SVMXC__Service_Contract_Sites__c scs =new SVMXC__Service_Contract_Sites__c(SVMXC__site__c = oSite.id, SVMXC__Service_Contract__c = SVMXServiceContract.id);
        insert scs;
        
        list<SVMXC__Service_Contract_Products__c> lstSCP =  new list<SVMXC__Service_Contract_Products__c>();
        SVMXC__Service_Contract_Products__c oSCP1 = new SVMXC__Service_Contract_Products__c(SVMXC__Service_Contract__c = SVMXServiceContract.Id, SVMXC__Installed_Product__c = IB0.Id, SVMXC__Start_Date__c = date.today().addDays(-1), SVMXC__End_Date__c = date.today().addDays(1));
        lstSCP.add(oSCP1); 
        
        SVMXC__Service_Contract_Products__c oSCP2 = new SVMXC__Service_Contract_Products__c(SVMXC__Service_Contract__c = SVMXServiceContract.Id, SVMXC__Installed_Product__c = IB1.Id, SVMXC__Start_Date__c = date.today().addDays(-1), SVMXC__End_Date__c = date.today().addDays(1));
        lstSCP.add(oSCP2);
        insert lstSCP;      
        
        SVMXC__Service_Template__c WT1 = new SVMXC__Service_Template__c( SVMXC__Walk_in_Allowed__c =false, SVMXC__Unit_of_Time__c = '100', SVMXC__Unit_of_Time_Material__c= 'Days', SVMXC__Unit_of_Time_Expenses__c='Months', SVMXC__Transferable__c=false, SVMXC__Time_Covered__c=100, SVMXC__Template_Type__c='Warranty', SVMXC__Shipment_Allowed__c=false, SVMXC__RMA_Required__c=true, SVMXC__Onsite_Repair__c=true, SVMXC__Material_Covered__c=100, SVMXC__Loaner_Provided__c=false, SVMXC__Invoice_Required__c=false, SVMXC__Expenses_Covered__c=100, SVMXC__Duration_of_Time_Coverage__c=100, SVMXC__Duration_of_Material_Coverage__c=365, SVMXC__Duration_of_Expenses__c=52, SVMXC__Coverage_Effective_From__c='Install Date', SVMXC__All_Services_Covered__c=false, SVMXC__All_Products_Covered__c=false, Name ='Template1' );
        insert WT1;
        
        SVMXC__Counter_Details__c Counterdef = new SVMXC__Counter_Details__c( RecordTypeId = RtypeDef.Id, SVMXC__Counter_Name__c = 'Test', SVMXC__Counter_Reading__c = 51, SVMXC__Grows_Reduces_By__c=1, SVMXC__Min_Value__c = 50, SVMXC__Max_Value__c = 100, SVMXC__Installed_Product__c = IB1.Id, SVMXC__Counter_Type__c='Decreasing');
        insert Counterdef;
        
        SVMXC__Counter_Details__c CounterReading = new SVMXC__Counter_Details__c( RecordTypeId = RtypeReading.Id, SVMXC__Counter_Definition__c=Counterdef.Id, SVMXC__Counter_Name__c = 'Test', SVMXC__Counter_Reading__c = 51, SVMXC__Grows_Reduces_By__c=1, SVMXC__Min_Value__c = 50, SVMXC__Max_Value__c = 100, SVMXC__Installed_Product__c = IB1.Id, SVMXC__Product__c = prod1.Id);
        insert CounterReading;
        
        SVMXC__Counter_Details__c CoverageCounter = new SVMXC__Counter_Details__c( RecordTypeID = RtypeCoverage.Id, SVMXC__Product__c = prod1.Id, SVMXC__Counter_Definition__c=Counterdef.Id, SVMXC__Counter_Name__c = 'Test', SVMXC__Counter_Reading__c = 51, SVMXC__Grows_Reduces_By__c=1, SVMXC__Min_Value__c = 50, SVMXC__Max_Value__c = 100, SVMXC__Installed_Product__c = IB1.Id, SVMXC__Service_Maintenance_Contract__c = SVMXServiceContract.Id, SVMXC__Warranty_Terms__c = WT1.Id, SVMXC__Coverage_Limit__c = 55, SVMXC__Coverage_Starts_At__c = 40); 
        insert CoverageCounter;

        list<SVMXC__Service_Order__c> lstWO = new list<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c WO1 = new SVMXC__Service_Order__c(SVMXC__Entitlement_Type__c ='AUTO', SVMXC__Country__c= 'Operator1' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Site__c=oSite.id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true, SVMXC__Service_Contract__c = SVMXServiceContract.Id, SVMXC__Product__c=prod1.Id);      
        lstWO.add(WO1);

        SVMXC__Service_Order__c WO2 = new SVMXC__Service_Order__c(SVMXC__Entitlement_Type__c ='AUTO', SVMXC__Country__c= 'Operator2' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Site__c=oSite.id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true, SVMXC__Service_Contract__c = SVMXServiceContract.Id, SVMXC__Product__c=prod1.Id);      
        lstWO.add(WO2);

        SVMXC__Service_Order__c WO3 = new SVMXC__Service_Order__c(SVMXC__Entitlement_Type__c ='AUTO', SVMXC__Country__c= 'Operator3' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Site__c=oSite.id, SVMXC__Perform_Auto_Entitlement__c=true, SVMXC__Service_Contract__c = SVMXServiceContract.Id, SVMXC__Product__c=prod1.Id);      
        lstWO.add(WO3);
        insert lstWO;

        
        list<SVMXC__Service_Order_Line__c> lstWOLines = new list<SVMXC__Service_Order_Line__c>();
        SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO1.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        lstWOLines.add(WOLine1); 
        
        SVMXC__Service_Order_Line__c WOLine2 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO2.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        lstWOLines.add(WOLine2); 

        SVMXC__Service_Order_Line__c WOLine3 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO3.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        lstWOLines.add(WOLine3); 
        
        insert lstWOLines;

        for(SVMXC__Service_Order__c serviceOrder : lstWO){
            serviceOrder.SVMXC__Perform_Auto_Entitlement__c = true;    
        }
        
        update lstWO;
        
        list<SVMXC__ServiceMax_Processes__c> tmpLstProcess = [SELECT Id, RecordTypeId, SVMXC__Rule_Type__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' AND (SVMXC__Rule_Type__c = 'Auto Entitlement WO' OR SVMXC__Rule_Type__c = 'Counters')];
        delete tmpLstProcess;
        
        list<SVMXC__ServiceMax_Processes__c> lstProcess = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c AEProcess1 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = false,SVMXC__Field_Name__c ='Product', SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, SVMXC__Rule_Type__c='Auto Entitlement WO', SVMXC__Entitlement_Scope__c='Both', SVMXC__Entitlement_By__c='Validity dates', SVMXC__Pick_First_Match__c = 'Warranty', SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=true, SVMXC__Counter_Vs_Dates_Rule__c = 'Whichever Is Valid',
                                                                                          SVMXC__Enable_Child_Line_Entitlement__c = true);
        lstProcess.add(AEProcess1);

        SVMXC__ServiceMax_Processes__c AEProcess2 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = true,SVMXC__Field_Name__c ='Product', SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, SVMXC__Rule_Type__c='Auto Entitlement WO', SVMXC__Entitlement_Scope__c='Warranties', SVMXC__Entitlement_By__c='Validity dates', SVMXC__Pick_First_Match__c = 'Warranty', SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=true, SVMXC__Counter_Vs_Dates_Rule__c = 'Whichever Is Valid',
                                                                                          SVMXC__Enable_Child_Line_Entitlement__c = true);
        lstProcess.add(AEProcess2);

        SVMXC__ServiceMax_Processes__c AEProcess3 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = true,SVMXC__Field_Name__c ='Product', SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, SVMXC__Rule_Type__c='Auto Entitlement WO', SVMXC__Entitlement_Scope__c='Service Contracts', SVMXC__Entitlement_By__c='Validity dates', SVMXC__Pick_First_Match__c = 'Warranty', SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=true, SVMXC__Counter_Vs_Dates_Rule__c = 'Whichever Is Valid',
                                                                                          SVMXC__Enable_Child_Line_Entitlement__c = true);
        lstProcess.add(AEProcess3);
        
        SVMXC__ServiceMax_Processes__c AEProcess5 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = true,SVMXC__Field_Name__c ='Product', SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, SVMXC__Rule_Type__c='Auto Entitlement WO', SVMXC__Entitlement_Scope__c='Service Contracts', SVMXC__Entitlement_By__c='Validity dates', SVMXC__Pick_First_Match__c = 'Warranty', SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=true, SVMXC__Counter_Vs_Dates_Rule__c = 'Whichever Is Valid',
                                                                                          SVMXC__Enable_Child_Line_Entitlement__c = true);
        lstProcess.add(AEProcess5);
        
        insert lstProcess;

        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c Cnfig1 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'EQ', SVMXC__Operand__c='Operator1', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='WO_Auto_Entitlement', SVMXC__Expression_Rule__c=AEProcess1.Id, SVMXC__Display_Type__c='STRING');
        lstConfigData.add(Cnfig1);

        SVMXC__ServiceMax_Config_Data__c Cnfig2 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'EQ', SVMXC__Operand__c='Operator2', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='WO_Auto_Entitlement', SVMXC__Expression_Rule__c=AEProcess2.Id, SVMXC__Display_Type__c='STRING');
        lstConfigData.add(Cnfig2);

        SVMXC__ServiceMax_Config_Data__c Cnfig3 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'EQ', SVMXC__Operand__c='Operator3', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='WO_Auto_Entitlement', SVMXC__Expression_Rule__c=AEProcess3.Id, SVMXC__Display_Type__c='STRING');
        lstConfigData.add(Cnfig3);
        
        SVMXC__ServiceMax_Config_Data__c Cnfig4 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'EQ', SVMXC__Operand__c='Operator3', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='IPRD_Counters', SVMXC__Expression_Rule__c=AEProcess3.Id, SVMXC__Display_Type__c='STRING');
        lstConfigData.add(Cnfig4);
        insert lstConfigData;
        
        List<String> lstIdsWO = new List<String>();
        lstIdsWO.add(WO1.id);
        lstIdsWO.add(WO2.id);
        lstIdsWO.add(WO3.id);
        
        WORD_AutoEntitlement WOAEntl = new WORD_AutoEntitlement();
        
        INTF_WebServicesDef.INTF_Request req = new INTF_WebServicesDef.INTF_Request();
        req.recordIds = lstIdsWO;
        
        WOAEntl.SVMX_DoEntitlement(req);
    }
    
    static testMethod void WORD_AutoEntitlementUnitTest4() 
    { 
        RecordType[] Rtypes = [select Id, DeveloperName, Name, SobjectType from RecordType where SobjectType IN ('SVMXC__ServiceMax_Processes__c','SVMXC__ServiceMax_Config_Data__c','SVMXC__Counter_Details__c','SVMXC__Service_Order_Line__c')];
        RecordType Rtype, ExpressionsUT, RtypeCoverage, RtypeReading, RtypeDef, RtypeProdServiced;
        for(RecordType rt : Rtypes)
        {
            if(rt.Name == 'SVMX Rule')
                Rtype = rt;
            else if(rt.Name == 'Expressions')
                ExpressionsUT = rt;
            else if(rt.Name == 'Coverage')
                RtypeCoverage = rt;
            else if(rt.Name == 'Reading')
                RtypeReading = rt;
            else if(rt.Name == 'Definition')
                RtypeDef = rt;
            else if(rt.DeveloperName == 'Products_Serviced')
                RtypeProdServiced = rt;
        }
        oAccount = new Account(Name ='Account');
        insert oAccount;
    
        oContact = new Contact(LastName='Last', AccountID = oAccount.Id,Email='svmxmailfortest@servicemax.com');
        insert oContact;
    
        SVMXC__Site__c oSite = new SVMXC__Site__c();
        insert oSite;     
        
        Product2 prod1 = new Product2(Name = 'Prod1');
        insert prod1; 
        
        SVMXC__Installed_Product__c IB0 = new SVMXC__Installed_Product__c( Name = 'IB0', SVMXC__Product__c = prod1.Id, SVMXC__Company__c = oAccount.Id  , SVMXC__Contact__c =oContact.Id, SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today() ); 
        insert IB0;
        
        SVMXC__Installed_Product__c IB1 = new SVMXC__Installed_Product__c(Name = 'IB1', SVMXC__Product__c = prod1.Id, SVMXC__Company__c = oAccount.Id  , SVMXC__Contact__c =oContact.Id, SVMXC__Top_Level__c = IB0.Id, SVMXC__Parent__c = IB0.Id , SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today()); 
        insert IB1;
        
        list<SVMXC__Warranty__c> lstWarranty =  new list<SVMXC__Warranty__c>();
        SVMXC__Warranty__c oW1 = new SVMXC__Warranty__c(SVMXC__Installed_Product__c = IB0.Id, SVMXC__Start_Date__c = date.today().addDays(-1), SVMXC__End_Date__c = date.today().addDays(1));
        lstWarranty.add(oW1); 
        
        SVMXC__Warranty__c oW2 = new SVMXC__Warranty__c(SVMXC__Installed_Product__c = IB1.Id, SVMXC__Start_Date__c = date.today().addDays(-1), SVMXC__End_Date__c = date.today().addDays(1));
        lstWarranty.add(oW2);
        insert lstWarranty;
        
        SVMXC__Service_Contract__c SVMXServiceContract = new SVMXC__Service_Contract__c(SVMXC__Active__c = true, SVMXC__Company__c = oAccount.id, SVMXC__Start_Date__c = date.today().addDays(-1), SVMXC__End_Date__c = date.today().addDays(1));
        insert SVMXServiceContract;
        
        SVMXC__Service_Contract_Contacts__c scc = new SVMXC__Service_Contract_Contacts__c(SVMXC__Contact__c = oContact.id, SVMXC__Service_Contract__c = SVMXServiceContract.id);
        insert scc;
        
        SVMXC__Service_Contract_Sites__c scs =new SVMXC__Service_Contract_Sites__c(SVMXC__site__c = oSite.id, SVMXC__Service_Contract__c = SVMXServiceContract.id);
        insert scs;
        
        list<SVMXC__Service_Contract_Products__c> lstSCP =  new list<SVMXC__Service_Contract_Products__c>();
        SVMXC__Service_Contract_Products__c oSCP1 = new SVMXC__Service_Contract_Products__c(SVMXC__Service_Contract__c = SVMXServiceContract.Id, SVMXC__Installed_Product__c = IB0.Id, SVMXC__Start_Date__c = date.today().addDays(-1), SVMXC__End_Date__c = date.today().addDays(1));
        lstSCP.add(oSCP1); 
        
        SVMXC__Service_Contract_Products__c oSCP2 = new SVMXC__Service_Contract_Products__c(SVMXC__Service_Contract__c = SVMXServiceContract.Id, SVMXC__Installed_Product__c = IB1.Id, SVMXC__Start_Date__c = date.today().addDays(-1), SVMXC__End_Date__c = date.today().addDays(1));
        lstSCP.add(oSCP2);
        insert lstSCP;      
        
        SVMXC__Service_Template__c WT1 = new SVMXC__Service_Template__c( SVMXC__Walk_in_Allowed__c =false, SVMXC__Unit_of_Time__c = '100', SVMXC__Unit_of_Time_Material__c= 'Days', SVMXC__Unit_of_Time_Expenses__c='Months', SVMXC__Transferable__c=false, SVMXC__Time_Covered__c=100, SVMXC__Template_Type__c='Warranty', SVMXC__Shipment_Allowed__c=false, SVMXC__RMA_Required__c=true, SVMXC__Onsite_Repair__c=true, SVMXC__Material_Covered__c=100, SVMXC__Loaner_Provided__c=false, SVMXC__Invoice_Required__c=false, SVMXC__Expenses_Covered__c=100, SVMXC__Duration_of_Time_Coverage__c=100, SVMXC__Duration_of_Material_Coverage__c=365, SVMXC__Duration_of_Expenses__c=52, SVMXC__Coverage_Effective_From__c='Install Date', SVMXC__All_Services_Covered__c=false, SVMXC__All_Products_Covered__c=false, Name ='Template1' );
        insert WT1;
        
        SVMXC__Counter_Details__c Counterdef = new SVMXC__Counter_Details__c( RecordTypeId = RtypeDef.Id, SVMXC__Counter_Name__c = 'Test', SVMXC__Counter_Reading__c = 51, SVMXC__Grows_Reduces_By__c=1, SVMXC__Min_Value__c = 50, SVMXC__Max_Value__c = 100, SVMXC__Installed_Product__c = IB1.Id, SVMXC__Counter_Type__c='Increasing');
        insert Counterdef;
        
        SVMXC__Counter_Details__c CounterReading = new SVMXC__Counter_Details__c( RecordTypeId = RtypeReading.Id, SVMXC__Counter_Definition__c=Counterdef.Id, SVMXC__Counter_Name__c = 'Test', SVMXC__Counter_Reading__c = 51, SVMXC__Grows_Reduces_By__c=1, SVMXC__Min_Value__c = 50, SVMXC__Max_Value__c = 100, SVMXC__Installed_Product__c = IB1.Id, SVMXC__Product__c = prod1.Id);
        insert CounterReading;
        
        SVMXC__Counter_Details__c CoverageCounter = new SVMXC__Counter_Details__c( RecordTypeID = RtypeCoverage.Id, SVMXC__Product__c = prod1.Id, SVMXC__Counter_Definition__c=Counterdef.Id, SVMXC__Counter_Name__c = 'Test', SVMXC__Counter_Reading__c = 51, SVMXC__Grows_Reduces_By__c=1, SVMXC__Min_Value__c = 50, SVMXC__Max_Value__c = 100, SVMXC__Installed_Product__c = IB1.Id, SVMXC__Service_Maintenance_Contract__c = SVMXServiceContract.Id, SVMXC__Warranty_Terms__c = WT1.Id, SVMXC__Coverage_Limit__c = 55, SVMXC__Coverage_Starts_At__c = 40); 
        insert CoverageCounter;

        list<SVMXC__Service_Order__c> lstWO = new list<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c WO1 = new SVMXC__Service_Order__c(SVMXC__Entitlement_Type__c ='AUTO', SVMXC__Country__c= 'Operator1' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Site__c=oSite.id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true, SVMXC__Service_Contract__c = SVMXServiceContract.Id, SVMXC__Product__c=prod1.Id);      
        lstWO.add(WO1);

        SVMXC__Service_Order__c WO2 = new SVMXC__Service_Order__c(SVMXC__Entitlement_Type__c ='AUTO', SVMXC__Country__c= 'Operator2' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Site__c=oSite.id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true, SVMXC__Service_Contract__c = SVMXServiceContract.Id, SVMXC__Product__c=prod1.Id);      
        lstWO.add(WO2);

        SVMXC__Service_Order__c WO3 = new SVMXC__Service_Order__c(SVMXC__Entitlement_Type__c ='AUTO', SVMXC__Country__c= 'Operator3' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Site__c=oSite.id, SVMXC__Perform_Auto_Entitlement__c=true, SVMXC__Service_Contract__c = SVMXServiceContract.Id, SVMXC__Product__c=prod1.Id);      
        lstWO.add(WO3);
        insert lstWO;
        
        
        list<SVMXC__Service_Order_Line__c> lstWOLines = new list<SVMXC__Service_Order_Line__c>();
        SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO1.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        lstWOLines.add(WOLine1); 
        
        SVMXC__Service_Order_Line__c WOLine2 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO2.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        lstWOLines.add(WOLine2); 

        SVMXC__Service_Order_Line__c WOLine3 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO3.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        lstWOLines.add(WOLine3); 
        
        insert lstWOLines;

        for(SVMXC__Service_Order__c serviceOrder : lstWO){
            serviceOrder.SVMXC__Perform_Auto_Entitlement__c = true;    
        }
        
        update lstWO;        

        list<SVMXC__ServiceMax_Processes__c> tmpLstProcess = [SELECT Id, RecordTypeId, SVMXC__Rule_Type__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' AND (SVMXC__Rule_Type__c = 'Auto Entitlement WO' OR SVMXC__Rule_Type__c = 'Counters')];
        delete tmpLstProcess;
        
        list<SVMXC__ServiceMax_Processes__c> lstProcess = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c AEProcess1 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = false,SVMXC__Field_Name__c ='Product', SVMXC__Allow_Override__c = true, SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, SVMXC__Rule_Type__c='Counters', SVMXC__Entitlement_Scope__c='Both', SVMXC__Entitlement_By__c='Both', SVMXC__Pick_First_Match__c = 'Warranty', SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=true, SVMXC__Counter_Vs_Dates_Rule__c = 'Whichever Is Valid',
                                                                                          SVMXC__Enable_Child_Line_Entitlement__c = true);
        lstProcess.add(AEProcess1);

        SVMXC__ServiceMax_Processes__c AEProcess2 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = true,SVMXC__Field_Name__c ='Product', SVMXC__Allow_Override__c = true , SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, SVMXC__Rule_Type__c='Counters', SVMXC__Entitlement_Scope__c='Warranties', SVMXC__Entitlement_By__c='Both', SVMXC__Pick_First_Match__c = 'Warranty', SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=true, SVMXC__Counter_Vs_Dates_Rule__c = 'Whichever Is Valid',
                                                                                          SVMXC__Enable_Child_Line_Entitlement__c = true);
        lstProcess.add(AEProcess2);

        SVMXC__ServiceMax_Processes__c AEProcess3 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = true,SVMXC__Field_Name__c ='Product', SVMXC__Allow_Override__c = false, SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, SVMXC__Rule_Type__c='Counters', SVMXC__Entitlement_Scope__c='Service Contracts', SVMXC__Entitlement_By__c='Both', SVMXC__Pick_First_Match__c = 'Warranty', SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=true, SVMXC__Counter_Vs_Dates_Rule__c = 'Whichever Is Valid',
                                                                                          SVMXC__Enable_Child_Line_Entitlement__c = true);
        lstProcess.add(AEProcess3);
        
        SVMXC__ServiceMax_Processes__c AEProcess5 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = true,SVMXC__Field_Name__c ='Product', SVMXC__Allow_Override__c = false, SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, SVMXC__Rule_Type__c='Counters', SVMXC__Entitlement_Scope__c='Service Contracts', SVMXC__Entitlement_By__c='Both', SVMXC__Pick_First_Match__c = 'Warranty', SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=true, SVMXC__Counter_Vs_Dates_Rule__c = 'Whichever Is Valid',
                                                                                          SVMXC__Enable_Child_Line_Entitlement__c = true);
        lstProcess.add(AEProcess5);
        
        insert lstProcess;

        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c Cnfig1 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'EQ', SVMXC__Operand__c='Operator1', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='IPRD_Counters', SVMXC__Expression_Rule__c=AEProcess1.Id, SVMXC__Display_Type__c='STRING');
        lstConfigData.add(Cnfig1);

        SVMXC__ServiceMax_Config_Data__c Cnfig2 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'EQ', SVMXC__Operand__c='Operator2', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='IPRD_Counters', SVMXC__Expression_Rule__c=AEProcess2.Id, SVMXC__Display_Type__c='STRING');
        lstConfigData.add(Cnfig2);

        SVMXC__ServiceMax_Config_Data__c Cnfig3 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'EQ', SVMXC__Operand__c='Operator3', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='IPRD_Counters', SVMXC__Expression_Rule__c=AEProcess3.Id, SVMXC__Display_Type__c='STRING');
        lstConfigData.add(Cnfig3);
    
        insert lstConfigData;
        
        List<String> lstIdsWO = new List<String>();
        lstIdsWO.add(WO1.id);
        lstIdsWO.add(WO2.id);
        lstIdsWO.add(WO3.id);
        
        WORD_AutoEntitlement WOAEntl = new WORD_AutoEntitlement();
        
        INTF_WebServicesDef.INTF_Request req = new INTF_WebServicesDef.INTF_Request();
        req.recordIds = lstIdsWO;
        
        Map<String, String> mapSettings = new Map<String, String>();
        mapSettings.put('EVER007_SET001', 'TRUE'); 
        mapSettings.put('EVER007_SET004', 'TRUE');
        mapSettings.put('IPRD003_SET007', 'TRUE');
        mapSettings.put('IPRD003_SET003', 'TRUE');
    
        WOAEntl.SVMX_DeriveProdfrmIB(lstWO, mapSettings);

        List<Id> componentOrderList2 = WOAEntl.getcomponentOrderList(AEProcess2, WO1.SVMXC__Component__c);
        WORD_AutoEntitlement.EntitlementInfoWrapper infoWrapper2 = new WORD_AutoEntitlement.EntitlementInfoWrapper();
        
        infoWrapper2 = WOAEntl.getServiceContractOnCounters(componentOrderList2,AEProcess2,WO1,0);
        
        List<Id> componentOrderList3 = WOAEntl.getcomponentOrderList(AEProcess5, WO1.SVMXC__Component__c);
        infoWrapper2 = WOAEntl.getServiceContractOnCounters(componentOrderList2,AEProcess5,WO1,0);
    } 
    
    static SVMXC__Installed_Product__c IB1;
    static SVMXC__Site__c objSite;
    
    static void createTestData(){
        RecordType[] Rtypes = [select Id, DeveloperName, Name, SobjectType from RecordType where SobjectType IN ('SVMXC__ServiceMax_Processes__c','SVMXC__ServiceMax_Config_Data__c','SVMXC__Counter_Details__c','SVMXC__Service_Order_Line__c')];
        RecordType Rtype, ExpressionsUT, RtypeCoverage, RtypeReading, RtypeDef, RtypeProdServiced;
        for(RecordType rt : Rtypes)
        {
            if(rt.Name == 'SVMX Rule')
                Rtype = rt;
            else if(rt.Name == 'Expressions')
                ExpressionsUT = rt;
            else if(rt.Name == 'Coverage')
                RtypeCoverage = rt;
            else if(rt.Name == 'Reading')
                RtypeReading = rt;
            else if(rt.Name == 'Definition')
                RtypeDef = rt;
            else if(rt.DeveloperName == 'Products_Serviced')
                RtypeProdServiced = rt;
        }
        oAccount = new Account(Name ='Account');
        insert oAccount;

        oContact = new Contact(LastName='Last', AccountID = oAccount.Id,Email='svmxmailfortest@servicemax.com');
        insert oContact;  
        
        Product2 prod1 = new Product2(Name = 'Prod1');
        insert prod1; 
        
        //Installed product
        SVMXC__Installed_Product__c IB0 = new SVMXC__Installed_Product__c( Name = 'IB0', SVMXC__Product__c = prod1.Id, SVMXC__Company__c = oAccount.Id  , SVMXC__Contact__c =oContact.Id, SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today() ); 
        insert IB0;
        
        //Installed product
        IB1 = new SVMXC__Installed_Product__c(Name = 'IB1', SVMXC__Product__c = prod1.Id, SVMXC__Company__c = oAccount.Id  , SVMXC__Contact__c =oContact.Id, SVMXC__Top_Level__c = IB0.Id, SVMXC__Parent__c = IB0.Id , SVMXC__Date_Installed__c = System.today(), SVMXC__Date_Shipped__c = System.today()); 
        insert IB1;
        
        //Service Contract
        SVMXC__Service_Contract__c SVMXServiceContract = new SVMXC__Service_Contract__c(SVMXC__Active__c = true, SVMXC__Company__c = oAccount.id, SVMXC__Start_Date__c = date.today().addDays(-1), SVMXC__End_Date__c = date.today().addDays(1), SVMXC__Contact__c = oContact.id);
        insert SVMXServiceContract;
        
        //Service Contract contacts - Entitled contacts
        SVMXC__Service_Contract_Contacts__c objEntitleContact = new SVMXC__Service_Contract_Contacts__c(SVMXC__Service_Contract__c = SVMXServiceContract.id, SVMXC__Contact__c = oContact.id, SVMXC__Number_of_Service_Orders__c = 20.0);
        insert objEntitleContact;
        
        //Covered Product
        list<SVMXC__Service_Contract_Products__c> lstSCP =  new list<SVMXC__Service_Contract_Products__c>();
        SVMXC__Service_Contract_Products__c oSCP1 = new SVMXC__Service_Contract_Products__c(SVMXC__Service_Contract__c = SVMXServiceContract.Id, SVMXC__Installed_Product__c = IB0.Id, SVMXC__Start_Date__c = date.today().addDays(-1), SVMXC__End_Date__c = date.today().addDays(1));
        lstSCP.add(oSCP1); 
        
        //Covered Product
        SVMXC__Service_Contract_Products__c oSCP2 = new SVMXC__Service_Contract_Products__c(SVMXC__Service_Contract__c = SVMXServiceContract.Id, SVMXC__Installed_Product__c = IB1.Id, SVMXC__Start_Date__c = date.today().addDays(-1), SVMXC__End_Date__c = date.today().addDays(1));
        lstSCP.add(oSCP2);
        insert lstSCP;
        
        //Service Template - Warranty Term
        SVMXC__Service_Template__c WT1 = new SVMXC__Service_Template__c( SVMXC__Walk_in_Allowed__c =false, SVMXC__Unit_of_Time__c = '100', SVMXC__Unit_of_Time_Material__c= 'Days', SVMXC__Unit_of_Time_Expenses__c='Months', SVMXC__Transferable__c=false, SVMXC__Time_Covered__c=100, SVMXC__Template_Type__c='Warranty', SVMXC__Shipment_Allowed__c=false, SVMXC__RMA_Required__c=true, SVMXC__Onsite_Repair__c=true, SVMXC__Material_Covered__c=100, SVMXC__Loaner_Provided__c=false, SVMXC__Invoice_Required__c=false, SVMXC__Expenses_Covered__c=100, SVMXC__Duration_of_Time_Coverage__c=100, SVMXC__Duration_of_Material_Coverage__c=365, SVMXC__Duration_of_Expenses__c=52, SVMXC__Coverage_Effective_From__c='SVMXC__Date_Installed__c', SVMXC__All_Services_Covered__c=false, SVMXC__All_Products_Covered__c=false, Name ='Template1', SVMXC__Exchange_Type__c = 'Return Exchange');
        insert WT1;
        
        //Applicable product
        SVMXC__Service_Template_Products__c objAppPro = new SVMXC__Service_Template_Products__c(SVMXC__Service_Template__c = WT1.id, SVMXC__Product__c = prod1.id);
        insert objAppPro;
        
        //Product Warranty
        SVMXC__Warranty__c oW1 = new SVMXC__Warranty__c(SVMXC__Installed_Product__c = IB1.Id, SVMXC__Start_Date__c = date.today().addDays(-1), SVMXC__End_Date__c = date.today().addDays(1), SVMXC__Service_Template__c = WT1.id, SVMXC__All_Products_Covered__c = true);
        insert oW1;
        
        //Counter Rule
        SVMXC__ServiceMax_Processes__c CounterRule = new SVMXC__ServiceMax_Processes__c(RecordTypeId = Rtype.Id, SVMXC__Description__c = 'Test', SVMXC__Name__c= 'TestCounterRule', SVMXC__Rule_Type__c = 'Counters', SVMXC__Parent_Object_Criteria__c = 'Name=\'Toyota Innova\'');
        insert CounterRule;
        
        //Counter Definition
        List<SVMXC__Counter_Details__c> lstCountDef = new List<SVMXC__Counter_Details__c>();
        SVMXC__Counter_Details__c Counterdef = new SVMXC__Counter_Details__c( RecordTypeId = RtypeDef.Id, SVMXC__Counter_Rule__c = CounterRule.id,SVMXC__Counter_Name__c = 'TestInc',  SVMXC__Grows_Reduces_By__c=1, SVMXC__Min_Value__c = 0, SVMXC__Max_Value__c = 100, SVMXC__Counter_Type__c='Increasing', SVMXC__Active__c= true);
        lstCountDef.add(Counterdef);
        
        //Counter Definition
        SVMXC__Counter_Details__c Counterdef1 = new SVMXC__Counter_Details__c( RecordTypeId = RtypeDef.Id, SVMXC__Counter_Rule__c = CounterRule.id, SVMXC__Counter_Name__c = 'TestDec',  SVMXC__Grows_Reduces_By__c=1, SVMXC__Min_Value__c = 0, SVMXC__Max_Value__c = 100, SVMXC__Counter_Type__c='Decreasing', SVMXC__Active__c= true);
        lstCountDef.add(Counterdef1);
        insert lstCountDef;
        
        List<SVMXC__Counter_Details__c> lstCounterReading = new List<SVMXC__Counter_Details__c>();
        //Counter Reading
        SVMXC__Counter_Details__c CounterReading = new SVMXC__Counter_Details__c( RecordTypeId = RtypeReading.Id, SVMXC__Counter_Definition__c=Counterdef.Id, SVMXC__Counter_Name__c = 'TestInc', SVMXC__Counter_Reading__c = 51, SVMXC__Grows_Reduces_By__c=1, SVMXC__Min_Value__c = 0, SVMXC__Max_Value__c = 100, SVMXC__Installed_Product__c = IB1.Id, SVMXC__Product__c = prod1.Id, SVMXC__Is_Latest__c = true);
        lstCounterReading.add(CounterReading);
        
        //Counter Reading
        SVMXC__Counter_Details__c CounterReading1 = new SVMXC__Counter_Details__c( RecordTypeId = RtypeReading.Id, SVMXC__Counter_Definition__c=Counterdef1.Id, SVMXC__Counter_Name__c = 'TestDec', SVMXC__Counter_Reading__c = 51, SVMXC__Grows_Reduces_By__c=1, SVMXC__Min_Value__c = 0, SVMXC__Max_Value__c = 100, SVMXC__Installed_Product__c = IB1.Id, SVMXC__Product__c = prod1.Id, SVMXC__Is_Latest__c = true);
        lstCounterReading.add(CounterReading1);
        insert lstCounterReading;
        
        List<SVMXC__Counter_Details__c> lstCounterCoverageForServiceContractAndWarranty = new List<SVMXC__Counter_Details__c>();
        //Counter Coverage for Service Contract
        SVMXC__Counter_Details__c CoverageCounter = new SVMXC__Counter_Details__c( RecordTypeID = RtypeCoverage.Id, SVMXC__Product__c = prod1.Id, SVMXC__Counter_Definition__c=Counterdef.Id, SVMXC__Counter_Name__c = 'TestInc', SVMXC__Grows_Reduces_By__c=1, SVMXC__Min_Value__c = 0, SVMXC__Max_Value__c = 100, SVMXC__Installed_Product__c = IB1.Id, SVMXC__Service_Maintenance_Contract__c = SVMXServiceContract.Id, SVMXC__Coverage_Limit__c = 80, SVMXC__Coverage_Starts_At__c = 0, SVMXC__Counters_Covered__c = 80, SVMXC__Counter_Type__c = 'Increasing', SVMXC__Covered_Products__c = oSCP2.id, SVMXC__Counter_Rule__c = CounterRule.id); 
        lstCounterCoverageForServiceContractAndWarranty.add(CoverageCounter);
        
        //Counter Coverage for Service Contract
        SVMXC__Counter_Details__c CoverageCounter1 = new SVMXC__Counter_Details__c( RecordTypeID = RtypeCoverage.Id, SVMXC__Product__c = prod1.Id, SVMXC__Counter_Definition__c=Counterdef1.Id, SVMXC__Counter_Name__c = 'TestDec', SVMXC__Grows_Reduces_By__c=1, SVMXC__Min_Value__c = 0, SVMXC__Max_Value__c = 100, SVMXC__Installed_Product__c = IB1.Id, SVMXC__Service_Maintenance_Contract__c = SVMXServiceContract.Id, SVMXC__Coverage_Limit__c = 40, SVMXC__Coverage_Starts_At__c = 100, SVMXC__Counters_Covered__c = 60, SVMXC__Counter_Type__c = 'Decreasing', SVMXC__Covered_Products__c = oSCP2.id, SVMXC__Counter_Rule__c = CounterRule.id); 
        lstCounterCoverageForServiceContractAndWarranty.add(CoverageCounter1);
        
        //Counter Coverage for Warranty
        SVMXC__Counter_Details__c CoverageCounter2 = new SVMXC__Counter_Details__c( RecordTypeID = RtypeCoverage.Id, SVMXC__Product__c = prod1.Id, SVMXC__Counter_Definition__c=Counterdef.Id, SVMXC__Counter_Name__c = 'TestInc', SVMXC__Grows_Reduces_By__c=1, SVMXC__Min_Value__c = 0, SVMXC__Max_Value__c = 100, SVMXC__Coverage_Limit__c = 80, SVMXC__Coverage_Starts_At__c = 0, SVMXC__Counters_Covered__c = 80, SVMXC__Counter_Type__c = 'Increasing', SVMXC__Counter_Rule__c = CounterRule.id, SVMXC__Warranty_Terms__c = WT1.id, SVMXC__Applicable_Products__c = objAppPro.id);
        lstCounterCoverageForServiceContractAndWarranty.add(CoverageCounter2);
        
        //Counter Coverage for Warranty
        SVMXC__Counter_Details__c CoverageCounter3 = new SVMXC__Counter_Details__c( RecordTypeID = RtypeCoverage.Id, SVMXC__Product__c = prod1.Id, SVMXC__Counter_Definition__c=Counterdef1.Id, SVMXC__Counter_Name__c = 'TestDec', SVMXC__Grows_Reduces_By__c=1, SVMXC__Min_Value__c = 0, SVMXC__Max_Value__c = 100, SVMXC__Coverage_Limit__c = 40, SVMXC__Coverage_Starts_At__c = 100, SVMXC__Counters_Covered__c = 60, SVMXC__Counter_Type__c = 'Decreasing', SVMXC__Counter_Rule__c = CounterRule.id, SVMXC__Warranty_Terms__c = WT1.id, SVMXC__Applicable_Products__c = objAppPro.id);
        lstCounterCoverageForServiceContractAndWarranty.add(CoverageCounter3);
        insert lstCounterCoverageForServiceContractAndWarranty;
        
        //Create location
        objSite = new SVMXC__site__c(Name = 'TestLoc');
        insert objSite;
        
        SVMXC__Service_Contract_Sites__c scs =new SVMXC__Service_Contract_Sites__c(SVMXC__site__c = objSite.id, SVMXC__Service_Contract__c = SVMXServiceContract.id);
        insert scs;
        
        list<SVMXC__ServiceMax_Processes__c> tmpLstProcess = [SELECT Id, RecordTypeId, SVMXC__Rule_Type__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'SVMX Rule' AND (SVMXC__Rule_Type__c = 'Auto Entitlement WO' OR SVMXC__Rule_Type__c = 'Counters')];
        delete tmpLstProcess;
        
        WORD_AutoEntitlement obj = new WORD_AutoEntitlement();
        obj.getStartDate(oSCP2);
        obj.getEndDate(oSCP2);
    }
    
    static testMethod void WORD_AutoEntitlementUnit_Entitle(){
        createTestData();
        
        RecordType[] Rtypes = [select Id, Name,DeveloperName, SobjectType from RecordType where SobjectType=:'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Service_Order_Line__c'];
        RecordType Rtype, ExpressionsUT,RtypeProdServiced;
        for(RecordType rt : Rtypes){
            if(rt.Name == 'SVMX Rule')
                Rtype = rt;
            else if(rt.Name == 'Expressions')
                ExpressionsUT = rt;
            else if(rt.DeveloperName == 'Products_Serviced')
                RtypeProdServiced = rt;            
        }
        
        list<SVMXC__ServiceMax_Processes__c> lstProcess = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c AEProcess1 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = false,SVMXC__Field_Name__c ='Product', SVMXC__Allow_Override__c = true, SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, SVMXC__Rule_Type__c='Auto Entitlement WO', SVMXC__Entitlement_Scope__c='Both', SVMXC__Entitlement_By__c='Both', SVMXC__Pick_First_Match__c = 'Warranty', SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=false, SVMXC__Counter_Vs_Dates_Rule__c = 'Whichever Is Valid',
                                                                                          SVMXC__Enable_Child_Line_Entitlement__c = true);
        insert AEProcess1;
        
        SVMXC__ServiceMax_Config_Data__c Cnfig1 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'eq', SVMXC__Operand__c='Operator1', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='IPRD_Counters', SVMXC__Expression_Rule__c=AEProcess1.Id, SVMXC__Display_Type__c='STRING');
        insert Cnfig1;
        
        SVMXC__Service_Order__c WO1 = new SVMXC__Service_Order__c(SVMXC__Country__c= 'Operator1' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true);
        insert WO1;
        SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO1.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        insert WOLine1;
        
        WO1.SVMXC__Perform_Auto_Entitlement__c = true;
        update WO1;
        
        
    }
    static testMethod void WORD_AutoEntitlementUnit_Entitle1(){
        createTestData();
        RecordType[] Rtypes = [select Id, Name,DeveloperName, SobjectType from RecordType where SobjectType=:'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Service_Order_Line__c'];
        RecordType Rtype, ExpressionsUT,RtypeProdServiced;
        for(RecordType rt : Rtypes){
            if(rt.Name == 'SVMX Rule')
                Rtype = rt;
            else if(rt.Name == 'Expressions')
                ExpressionsUT = rt;
            else if(rt.DeveloperName == 'Products_Serviced')
                RtypeProdServiced = rt;            
        }
        
        list<SVMXC__ServiceMax_Processes__c> lstProcess = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c AEProcess1 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = false, SVMXC__Allow_Override__c = true, SVMXC__Field_Name__c ='Product', SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, 
        SVMXC__Rule_Type__c='Auto Entitlement WO', 
        SVMXC__Entitlement_Scope__c='Service Contracts', 
        SVMXC__Entitlement_By__c='Validity dates', 
        SVMXC__Pick_First_Match__c = 'Service Contract',
        SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=false,
        SVMXC__Enable_Child_Line_Entitlement__c = true);
        insert AEProcess1;
        
        SVMXC__ServiceMax_Config_Data__c Cnfig1 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'eq', SVMXC__Operand__c='Operator1', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='IPRD_Counters', SVMXC__Expression_Rule__c=AEProcess1.Id, SVMXC__Display_Type__c='STRING');
        insert Cnfig1;

        SVMXC__Service_Order__c WO1 = new SVMXC__Service_Order__c(SVMXC__Country__c= 'Operator1' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true);
        insert WO1;
        
        SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO1.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        insert WOLine1;
        
        WO1.SVMXC__Perform_Auto_Entitlement__c = true;
        update WO1;  

        AEProcess1.SVMXC__SM_Disable_AutoEntitlement__c = true;
        WO1.SVMXC__Perform_Auto_Entitlement__c = true;
        update WO1;     
    }
    static testMethod void WORD_AutoEntitlementUnit_Entitle2(){
        createTestData();
        RecordType[] Rtypes = [select Id, Name,DeveloperName, SobjectType from RecordType where SobjectType=:'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Service_Order_Line__c'];
        RecordType Rtype, ExpressionsUT,RtypeProdServiced;
        for(RecordType rt : Rtypes){
            if(rt.Name == 'SVMX Rule')
                Rtype = rt;
            else if(rt.Name == 'Expressions')
                ExpressionsUT = rt;
            else if(rt.DeveloperName == 'Products_Serviced')
                RtypeProdServiced = rt;            
        }
        
        list<SVMXC__ServiceMax_Processes__c> lstProcess = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c AEProcess1 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = false,SVMXC__Field_Name__c ='Product', SVMXC__Allow_Override__c = true, SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, 
        SVMXC__Rule_Type__c='Auto Entitlement WO', 
        SVMXC__Entitlement_Scope__c='Service Contracts', 
        SVMXC__Entitlement_By__c='Counters', 
        SVMXC__Pick_First_Match__c = 'Service Contract',
        SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=false,
        SVMXC__Enable_Child_Line_Entitlement__c = true);
        insert AEProcess1;
        
        SVMXC__ServiceMax_Config_Data__c Cnfig1 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'eq', SVMXC__Operand__c='Operator1', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='IPRD_Counters', SVMXC__Expression_Rule__c=AEProcess1.Id, SVMXC__Display_Type__c='STRING');
        insert Cnfig1;
        
        SVMXC__Service_Order__c WO1 = new SVMXC__Service_Order__c(SVMXC__Country__c= 'Operator1' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true);
        insert WO1;

        SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO1.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        insert WOLine1;
        
        WO1.SVMXC__Perform_Auto_Entitlement__c = true;
        update WO1;          
    }
    
    static testMethod void WORD_AutoEntitlementUnit_Entitle3(){
        createTestData();
        RecordType[] Rtypes = [select Id, Name,DeveloperName, SobjectType from RecordType where SobjectType=:'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Service_Order_Line__c'];
        RecordType Rtype, ExpressionsUT,RtypeProdServiced;
        for(RecordType rt : Rtypes){
            if(rt.Name == 'SVMX Rule')
                Rtype = rt;
            else if(rt.Name == 'Expressions')
                ExpressionsUT = rt;
            else if(rt.DeveloperName == 'Products_Serviced')
                RtypeProdServiced = rt;            
        }
        
        list<SVMXC__ServiceMax_Processes__c> lstProcess = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c AEProcess1 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = false,SVMXC__Field_Name__c ='Product', SVMXC__Allow_Override__c = true, SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, 
        SVMXC__Rule_Type__c='Auto Entitlement WO', 
        SVMXC__Entitlement_Scope__c='Service Contracts', 
        SVMXC__Entitlement_By__c='Both', 
        SVMXC__Pick_First_Match__c = 'Service Contract', 
        SVMXC__Counter_Vs_Dates_Rule__c = 'Whichever Is Valid',
        SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=false,
        SVMXC__Enable_Child_Line_Entitlement__c = true);                                                                                           
        insert AEProcess1;
        
        SVMXC__ServiceMax_Config_Data__c Cnfig1 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'eq', SVMXC__Operand__c='Operator1', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='IPRD_Counters', SVMXC__Expression_Rule__c=AEProcess1.Id, SVMXC__Display_Type__c='STRING');
        insert Cnfig1;
        
        SVMXC__Service_Order__c WO1 = new SVMXC__Service_Order__c(SVMXC__Country__c= 'Operator1' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true);
        insert WO1;
        

        SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO1.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        insert WOLine1;
        
        WO1.SVMXC__Perform_Auto_Entitlement__c = true;
        update WO1;          
    }
    
    static testMethod void WORD_AutoEntitlementUnit_Entitle4(){
        createTestData();
        
        RecordType[] Rtypes = [select Id, Name,DeveloperName, SobjectType from RecordType where SobjectType=:'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Service_Order_Line__c'];
        RecordType Rtype, ExpressionsUT,RtypeProdServiced;
        for(RecordType rt : Rtypes){
            if(rt.Name == 'SVMX Rule')
                Rtype = rt;
            else if(rt.Name == 'Expressions')
                ExpressionsUT = rt;
            else if(rt.DeveloperName == 'Products_Serviced')
                RtypeProdServiced = rt;            
        }
        
        list<SVMXC__ServiceMax_Processes__c> lstProcess = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c AEProcess1 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = false, SVMXC__Field_Name__c ='Product', SVMXC__Allow_Override__c = true, SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, 
        SVMXC__Rule_Type__c='Auto Entitlement WO', 
        SVMXC__Entitlement_Scope__c='Service Contracts', 
        SVMXC__Entitlement_By__c='Both', 
        SVMXC__Pick_First_Match__c = 'Service Contract', 
        SVMXC__Counter_Vs_Dates_Rule__c = 'Both Are Valid',
        SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=false,
        SVMXC__Enable_Child_Line_Entitlement__c = true);                                                                                           
        insert AEProcess1;
        
        SVMXC__ServiceMax_Config_Data__c Cnfig1 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'eq', SVMXC__Operand__c='Operator1', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='IPRD_Counters', SVMXC__Expression_Rule__c=AEProcess1.Id, SVMXC__Display_Type__c='STRING');
        insert Cnfig1;
        
        SVMXC__Service_Order__c WO1 = new SVMXC__Service_Order__c(SVMXC__Country__c= 'Operator1' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true);
        insert WO1;
        
        SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO1.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        insert WOLine1;
        
        WO1.SVMXC__Perform_Auto_Entitlement__c = true;
        update WO1;            
    }
   
    static testMethod void WORD_AutoEntitlementUnit_Entitle5(){
        createTestData();
        RecordType[] Rtypes = [select Id, Name,DeveloperName, SobjectType from RecordType where SobjectType=:'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Service_Order_Line__c'];
        RecordType Rtype, ExpressionsUT,RtypeProdServiced;
        for(RecordType rt : Rtypes){
            if(rt.Name == 'SVMX Rule')
                Rtype = rt;
            else if(rt.Name == 'Expressions')
                ExpressionsUT = rt;
            else if(rt.DeveloperName == 'Products_Serviced')
                RtypeProdServiced = rt;            
        }
        
        list<SVMXC__ServiceMax_Processes__c> lstProcess = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c AEProcess1 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = false, SVMXC__Field_Name__c ='Product', SVMXC__Allow_Override__c = true, SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, 
        SVMXC__Rule_Type__c='Auto Entitlement WO', 
        SVMXC__Entitlement_Scope__c='Both', 
        SVMXC__Entitlement_By__c='Validity dates', 
        SVMXC__Pick_First_Match__c = 'Warranty',
        SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=false,
        SVMXC__Enable_Child_Line_Entitlement__c = true);
        insert AEProcess1;
        
        SVMXC__ServiceMax_Config_Data__c Cnfig1 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'eq', SVMXC__Operand__c='Operator1', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='IPRD_Counters', SVMXC__Expression_Rule__c=AEProcess1.Id, SVMXC__Display_Type__c='STRING');
        insert Cnfig1;
        
        SVMXC__Service_Order__c WO1 = new SVMXC__Service_Order__c(SVMXC__Country__c= 'Operator1' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true);
        insert WO1;

        SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO1.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        insert WOLine1;
        
        WO1.SVMXC__Perform_Auto_Entitlement__c = true;
        update WO1;           
    }
    static testMethod void WORD_AutoEntitlementUnit_Entitle6(){
        createTestData();
        RecordType[] Rtypes = [select Id, Name,DeveloperName, SobjectType from RecordType where SobjectType=:'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Service_Order_Line__c'];
        RecordType Rtype, ExpressionsUT,RtypeProdServiced;
        for(RecordType rt : Rtypes){
            if(rt.Name == 'SVMX Rule')
                Rtype = rt;
            else if(rt.Name == 'Expressions')
                ExpressionsUT = rt;
            else if(rt.DeveloperName == 'Products_Serviced')
                RtypeProdServiced = rt;            
        }
        
        list<SVMXC__ServiceMax_Processes__c> lstProcess = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c AEProcess1 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = false,SVMXC__Field_Name__c ='Product', SVMXC__Allow_Override__c = true, SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, 
        SVMXC__Rule_Type__c='Auto Entitlement WO', 
        SVMXC__Entitlement_Scope__c='Both', 
        SVMXC__Entitlement_By__c='Counters', 
        SVMXC__Pick_First_Match__c = 'Warranty',
        SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=false,
        SVMXC__Enable_Child_Line_Entitlement__c = true);                                                                                           
        insert AEProcess1;
        
        SVMXC__ServiceMax_Config_Data__c Cnfig1 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'eq', SVMXC__Operand__c='Operator1', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='IPRD_Counters', SVMXC__Expression_Rule__c=AEProcess1.Id, SVMXC__Display_Type__c='STRING');
        insert Cnfig1;
        
        SVMXC__Service_Order__c WO1 = new SVMXC__Service_Order__c(SVMXC__Country__c= 'Operator1' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true);
        insert WO1;

        SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO1.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        insert WOLine1;
        
        WO1.SVMXC__Perform_Auto_Entitlement__c = true;
        update WO1;            
        
    }
    static testMethod void WORD_AutoEntitlementUnit_Entitle7(){
        createTestData();
        RecordType[] Rtypes = [select Id, Name,DeveloperName, SobjectType from RecordType where SobjectType=:'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Service_Order_Line__c'];
        RecordType Rtype, ExpressionsUT,RtypeProdServiced;
        for(RecordType rt : Rtypes){
            if(rt.Name == 'SVMX Rule')
                Rtype = rt;
            else if(rt.Name == 'Expressions')
                ExpressionsUT = rt;
            else if(rt.DeveloperName == 'Products_Serviced')
                RtypeProdServiced = rt;            
        }
        
        list<SVMXC__ServiceMax_Processes__c> lstProcess = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c AEProcess1 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = false,SVMXC__Field_Name__c ='Product', SVMXC__Allow_Override__c = true, SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, 
        SVMXC__Rule_Type__c='Auto Entitlement WO', 
        SVMXC__Entitlement_Scope__c='Both', 
        SVMXC__Entitlement_By__c='Both', 
        SVMXC__Pick_First_Match__c = 'Warranty',
        SVMXC__Counter_Vs_Dates_Rule__c = 'Whichever Is Valid',
        SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=false,
        SVMXC__Enable_Child_Line_Entitlement__c = true);
        insert AEProcess1;
        
        SVMXC__ServiceMax_Config_Data__c Cnfig1 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'eq', SVMXC__Operand__c='Operator1', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='IPRD_Counters', SVMXC__Expression_Rule__c=AEProcess1.Id, SVMXC__Display_Type__c='STRING');
        insert Cnfig1;
        
        SVMXC__Service_Order__c WO1 = new SVMXC__Service_Order__c(SVMXC__Country__c= 'Operator1' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true);
        insert WO1;
        
        SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO1.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        insert WOLine1;
        
        WO1.SVMXC__Perform_Auto_Entitlement__c = true;
        update WO1;           
    }
    static testMethod void WORD_AutoEntitlementUnit_Entitle8(){
        createTestData();
        
        RecordType[] Rtypes = [select Id, Name,DeveloperName, SobjectType from RecordType where SobjectType=:'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Service_Order_Line__c'];
        RecordType Rtype, ExpressionsUT,RtypeProdServiced;
        for(RecordType rt : Rtypes){
            if(rt.Name == 'SVMX Rule')
                Rtype = rt;
            else if(rt.Name == 'Expressions')
                ExpressionsUT = rt;
            else if(rt.DeveloperName == 'Products_Serviced')
                RtypeProdServiced = rt;            
        }
        
        list<SVMXC__ServiceMax_Processes__c> lstProcess = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c AEProcess1 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = false, SVMXC__Field_Name__c ='Product', SVMXC__Allow_Override__c = true, SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, 
        SVMXC__Rule_Type__c='Auto Entitlement WO', 
        SVMXC__Entitlement_Scope__c='Both', 
        SVMXC__Entitlement_By__c='Both', 
        SVMXC__Pick_First_Match__c = 'Warranty',
        SVMXC__Counter_Vs_Dates_Rule__c = 'Both Are Valid',
        SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=false,
        SVMXC__Enable_Child_Line_Entitlement__c = true);
        insert AEProcess1;
        
        SVMXC__ServiceMax_Config_Data__c Cnfig1 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'eq', SVMXC__Operand__c='Operator1', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='IPRD_Counters', SVMXC__Expression_Rule__c=AEProcess1.Id, SVMXC__Display_Type__c='STRING');
        insert Cnfig1;
        
        SVMXC__Service_Order__c WO1 = new SVMXC__Service_Order__c(SVMXC__Country__c= 'Operator1' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true);
        insert WO1;
        
        SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO1.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        insert WOLine1;
        
        WO1.SVMXC__Perform_Auto_Entitlement__c = true;
        update WO1;         
    }
    static testMethod void WORD_AutoEntitlementUnit_Entitle9(){
        createTestData();
        
        RecordType[] Rtypes = [select Id, Name,DeveloperName, SobjectType from RecordType where SobjectType=:'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Service_Order_Line__c'];
        RecordType Rtype, ExpressionsUT,RtypeProdServiced;
        for(RecordType rt : Rtypes){
            if(rt.Name == 'SVMX Rule')
                Rtype = rt;
            else if(rt.Name == 'Expressions')
                ExpressionsUT = rt;
            else if(rt.DeveloperName == 'Products_Serviced')
                RtypeProdServiced = rt;            
        }
        
        list<SVMXC__ServiceMax_Processes__c> lstProcess = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c AEProcess1 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = false,SVMXC__Field_Name__c ='Product', SVMXC__Allow_Override__c = true, SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, 
        SVMXC__Rule_Type__c='Auto Entitlement WO', 
        SVMXC__Entitlement_Scope__c='Both', 
        SVMXC__Entitlement_By__c='Validity dates', 
        SVMXC__Pick_First_Match__c = 'Service Contract',
        SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=false,
        SVMXC__Enable_Child_Line_Entitlement__c = true);
        insert AEProcess1;
        
        SVMXC__ServiceMax_Config_Data__c Cnfig1 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'eq', SVMXC__Operand__c='Operator1', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='IPRD_Counters', SVMXC__Expression_Rule__c=AEProcess1.Id, SVMXC__Display_Type__c='STRING');
        insert Cnfig1;
        
        SVMXC__Service_Order__c WO1 = new SVMXC__Service_Order__c(SVMXC__Country__c= 'Operator1' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true);
        insert WO1;
        
        SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO1.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        insert WOLine1;
        
        WO1.SVMXC__Perform_Auto_Entitlement__c = true;
        update WO1;          
    }
    static testMethod void WORD_AutoEntitlementUnit_Entitle10(){
        createTestData();
        
        RecordType[] Rtypes = [select Id, Name,DeveloperName, SobjectType from RecordType where SobjectType=:'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Service_Order_Line__c'];
        RecordType Rtype, ExpressionsUT,RtypeProdServiced;
        for(RecordType rt : Rtypes){
            if(rt.Name == 'SVMX Rule')
                Rtype = rt;
            else if(rt.Name == 'Expressions')
                ExpressionsUT = rt;
            else if(rt.DeveloperName == 'Products_Serviced')
                RtypeProdServiced = rt;            
        }
        
        list<SVMXC__ServiceMax_Processes__c> lstProcess = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c AEProcess1 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = false,SVMXC__Field_Name__c ='Product', SVMXC__Allow_Override__c = true, SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, 
        SVMXC__Rule_Type__c='Auto Entitlement WO', 
        SVMXC__Entitlement_Scope__c='Both', 
        SVMXC__Entitlement_By__c='Counters', 
        SVMXC__Pick_First_Match__c = 'Service Contract',
        SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=false,
        SVMXC__Enable_Child_Line_Entitlement__c = true);
        insert AEProcess1;
        
        SVMXC__ServiceMax_Config_Data__c Cnfig1 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'eq', SVMXC__Operand__c='Operator1', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='IPRD_Counters', SVMXC__Expression_Rule__c=AEProcess1.Id, SVMXC__Display_Type__c='STRING');
        insert Cnfig1;
        
        SVMXC__Service_Order__c WO1 = new SVMXC__Service_Order__c(SVMXC__Country__c= 'Operator1' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true);
        insert WO1;
        
        SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO1.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        insert WOLine1;
        
        WO1.SVMXC__Perform_Auto_Entitlement__c = true;
        update WO1;          
    }
    static testMethod void WORD_AutoEntitlementUnit_Entitle11(){
        createTestData();
        RecordType[] Rtypes = [select Id, Name,DeveloperName, SobjectType from RecordType where SobjectType=:'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Service_Order_Line__c'];
        RecordType Rtype, ExpressionsUT,RtypeProdServiced;
        for(RecordType rt : Rtypes){
            if(rt.Name == 'SVMX Rule')
                Rtype = rt;
            else if(rt.Name == 'Expressions')
                ExpressionsUT = rt;
            else if(rt.DeveloperName == 'Products_Serviced')
                RtypeProdServiced = rt;            
        }
        
        list<SVMXC__ServiceMax_Processes__c> lstProcess = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c AEProcess1 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = false, SVMXC__Field_Name__c ='Product', SVMXC__Allow_Override__c = true, SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, 
        SVMXC__Rule_Type__c='Auto Entitlement WO', 
        SVMXC__Entitlement_Scope__c='Both', 
        SVMXC__Entitlement_By__c='Both', 
        SVMXC__Pick_First_Match__c = 'Service Contract',
        SVMXC__Counter_Vs_Dates_Rule__c = 'Whichever Is Valid',
        SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=false,
        SVMXC__Enable_Child_Line_Entitlement__c = true);
        insert AEProcess1;
        
        SVMXC__ServiceMax_Config_Data__c Cnfig1 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'eq', SVMXC__Operand__c='Operator1', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='IPRD_Counters', SVMXC__Expression_Rule__c=AEProcess1.Id, SVMXC__Display_Type__c='STRING');
        insert Cnfig1;
        
        SVMXC__Service_Order__c WO1 = new SVMXC__Service_Order__c(SVMXC__Country__c= 'Operator1' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true);
        insert WO1;
       
        SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO1.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        insert WOLine1;
        
        WO1.SVMXC__Perform_Auto_Entitlement__c = true;
        update WO1;          
        
    } 
    static testMethod void WORD_AutoEntitlementUnit_Entitle12(){
        createTestData();
        RecordType[] Rtypes = [select Id, Name,DeveloperName, SobjectType from RecordType where SobjectType=:'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Service_Order_Line__c'];
        RecordType Rtype, ExpressionsUT,RtypeProdServiced;
        for(RecordType rt : Rtypes){
            if(rt.Name == 'SVMX Rule')
                Rtype = rt;
            else if(rt.Name == 'Expressions')
                ExpressionsUT = rt;
            else if(rt.DeveloperName == 'Products_Serviced')
                RtypeProdServiced = rt;            
        }
        
        list<SVMXC__ServiceMax_Processes__c> lstProcess = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c AEProcess1 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = false,SVMXC__Field_Name__c ='Product', SVMXC__Allow_Override__c = true, SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, 
        SVMXC__Rule_Type__c='Auto Entitlement WO', 
        SVMXC__Entitlement_Scope__c='Both', 
        SVMXC__Entitlement_By__c='Both', 
        SVMXC__Pick_First_Match__c = 'Service Contract',
        SVMXC__Counter_Vs_Dates_Rule__c = 'Both Are Valid',
        SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=false,
        SVMXC__Enable_Child_Line_Entitlement__c = true);
        insert AEProcess1;
        
        SVMXC__ServiceMax_Config_Data__c Cnfig1 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'eq', SVMXC__Operand__c='Operator1', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='IPRD_Counters', SVMXC__Expression_Rule__c=AEProcess1.Id, SVMXC__Display_Type__c='STRING');
        insert Cnfig1;
        
        SVMXC__Service_Order__c WO1 = new SVMXC__Service_Order__c(SVMXC__Country__c= 'Operator1' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true);
        insert WO1;
       
        SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO1.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        insert WOLine1;
        
        WO1.SVMXC__Perform_Auto_Entitlement__c = true;
        update WO1;           
        
    }
    static testMethod void WORD_AutoEntitlementUnit_Entitle13(){
        createTestData();
        
        RecordType[] Rtypes = [select Id, Name,DeveloperName, SobjectType from RecordType where SobjectType=:'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Service_Order_Line__c'];
        RecordType Rtype, ExpressionsUT,RtypeProdServiced;
        for(RecordType rt : Rtypes){
            if(rt.Name == 'SVMX Rule')
                Rtype = rt;
            else if(rt.Name == 'Expressions')
                ExpressionsUT = rt;
            else if(rt.DeveloperName == 'Products_Serviced')
                RtypeProdServiced = rt;            
        }
        
        list<SVMXC__ServiceMax_Processes__c> lstProcess = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c AEProcess1 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = false,SVMXC__Field_Name__c ='Product', SVMXC__Allow_Override__c = true, SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, 
        SVMXC__Rule_Type__c='Auto Entitlement WO', 
        SVMXC__Entitlement_Scope__c='Warranties', 
        SVMXC__Entitlement_By__c='Validity dates', 
        SVMXC__Pick_First_Match__c = 'Warranty',
        SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=false,
        SVMXC__Enable_Child_Line_Entitlement__c = true);
        insert AEProcess1;
        
        SVMXC__ServiceMax_Config_Data__c Cnfig1 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'eq', SVMXC__Operand__c='Operator1', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='IPRD_Counters', SVMXC__Expression_Rule__c=AEProcess1.Id, SVMXC__Display_Type__c='STRING');
        insert Cnfig1;
        
        SVMXC__Service_Order__c WO1 = new SVMXC__Service_Order__c(SVMXC__Country__c= 'Operator1' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true);
        insert WO1;
       
        SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO1.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        insert WOLine1;
        
        WO1.SVMXC__Perform_Auto_Entitlement__c = true;
        update WO1;           
    }
    static testMethod void WORD_AutoEntitlementUnit_Entitle14(){
        createTestData();
        
        RecordType[] Rtypes = [select Id, Name,DeveloperName, SobjectType from RecordType where SobjectType=:'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Service_Order_Line__c'];
        RecordType Rtype, ExpressionsUT,RtypeProdServiced;
        for(RecordType rt : Rtypes){
            if(rt.Name == 'SVMX Rule')
                Rtype = rt;
            else if(rt.Name == 'Expressions')
                ExpressionsUT = rt;
            else if(rt.DeveloperName == 'Products_Serviced')
                RtypeProdServiced = rt;            
        }
        
        list<SVMXC__ServiceMax_Processes__c> lstProcess = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c AEProcess1 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = false,SVMXC__Field_Name__c ='Product', SVMXC__Allow_Override__c = true, SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, 
        SVMXC__Rule_Type__c='Auto Entitlement WO', 
        SVMXC__Entitlement_Scope__c='Warranties', 
        SVMXC__Entitlement_By__c='Counters', 
        SVMXC__Pick_First_Match__c = 'Warranty',
        SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=false,
        SVMXC__Enable_Child_Line_Entitlement__c = true);
        insert AEProcess1;
        
        SVMXC__ServiceMax_Config_Data__c Cnfig1 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'eq', SVMXC__Operand__c='Operator1', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='IPRD_Counters', SVMXC__Expression_Rule__c=AEProcess1.Id, SVMXC__Display_Type__c='STRING');
        insert Cnfig1;
        
        SVMXC__Service_Order__c WO1 = new SVMXC__Service_Order__c(SVMXC__Country__c= 'Operator1' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true);
        insert WO1;
        SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO1.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        insert WOLine1;
        
        WO1.SVMXC__Perform_Auto_Entitlement__c = true;
        update WO1;         
    }
    static testMethod void WORD_AutoEntitlementUnit_Entitle15(){
        createTestData();
        RecordType[] Rtypes = [select Id, Name,DeveloperName, SobjectType from RecordType where SobjectType=:'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Service_Order_Line__c'];
        RecordType Rtype, ExpressionsUT,RtypeProdServiced;
        for(RecordType rt : Rtypes){
            if(rt.Name == 'SVMX Rule')
                Rtype = rt;
            else if(rt.Name == 'Expressions')
                ExpressionsUT = rt;
            else if(rt.DeveloperName == 'Products_Serviced')
                RtypeProdServiced = rt;            
        }
        
        list<SVMXC__ServiceMax_Processes__c> lstProcess = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c AEProcess1 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = false,SVMXC__Field_Name__c ='Product', SVMXC__Allow_Override__c = true, SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, 
        SVMXC__Rule_Type__c='Auto Entitlement WO', 
        SVMXC__Entitlement_Scope__c='Warranties', 
        SVMXC__Entitlement_By__c='Both', 
        SVMXC__Pick_First_Match__c = 'Warranty',
        SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=false,
        SVMXC__Enable_Child_Line_Entitlement__c = true);
        insert AEProcess1;
        
        SVMXC__ServiceMax_Config_Data__c Cnfig1 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'eq', SVMXC__Operand__c='Operator1', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='IPRD_Counters', SVMXC__Expression_Rule__c=AEProcess1.Id, SVMXC__Display_Type__c='STRING');
        insert Cnfig1;
        
        SVMXC__Service_Order__c WO1 = new SVMXC__Service_Order__c(SVMXC__Country__c= 'Operator1' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true);
        insert WO1;
        
        SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO1.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        insert WOLine1;
        
        WO1.SVMXC__Perform_Auto_Entitlement__c = true;
        update WO1;            
    }
    static testMethod void WORD_AutoEntitlementUnit_Entitle16(){
        createTestData();
        RecordType[] Rtypes = [select Id, Name,DeveloperName, SobjectType from RecordType where SobjectType=:'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Service_Order_Line__c'];
        RecordType Rtype, ExpressionsUT,RtypeProdServiced;
        for(RecordType rt : Rtypes){
            if(rt.Name == 'SVMX Rule')
                Rtype = rt;
            else if(rt.Name == 'Expressions')
                ExpressionsUT = rt;
            else if(rt.DeveloperName == 'Products_Serviced')
                RtypeProdServiced = rt;            
        }
        
        list<SVMXC__ServiceMax_Processes__c> lstProcess = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c AEProcess1 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = true,SVMXC__Field_Name__c ='Product', SVMXC__Allow_Override__c = true, SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, 
        SVMXC__Rule_Type__c='Auto Entitlement WO', 
        SVMXC__Entitlement_Scope__c='Service Contracts', 
        SVMXC__Entitlement_By__c='Validity dates', 
        SVMXC__Pick_First_Match__c = 'Service Contract',
        SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=false,
        SVMXC__Enable_Child_Line_Entitlement__c = true);
        insert AEProcess1;
        
        SVMXC__ServiceMax_Config_Data__c Cnfig1 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'eq', SVMXC__Operand__c='Operator1', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='IPRD_Counters', SVMXC__Expression_Rule__c=AEProcess1.Id, SVMXC__Display_Type__c='STRING');
        insert Cnfig1;
        
        SVMXC__Service_Order__c WO1 = new SVMXC__Service_Order__c(SVMXC__Country__c= 'Operator1' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true);
        insert WO1;
        SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO1.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        insert WOLine1;
        
        WO1.SVMXC__Perform_Auto_Entitlement__c = true;
        update WO1;         
        
    }
    static testMethod void WORD_AutoEntitlementUnit_Entitle17(){
        createTestData();
        RecordType[] Rtypes = [select Id, Name,DeveloperName, SobjectType from RecordType where SobjectType=:'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Service_Order_Line__c'];
        RecordType Rtype, ExpressionsUT,RtypeProdServiced;
        for(RecordType rt : Rtypes){
            if(rt.Name == 'SVMX Rule')
                Rtype = rt;
            else if(rt.Name == 'Expressions')
                ExpressionsUT = rt;
            else if(rt.DeveloperName == 'Products_Serviced')
                RtypeProdServiced = rt;            
        }
        
        list<SVMXC__ServiceMax_Processes__c> lstProcess = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c AEProcess1 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = true,SVMXC__Field_Name__c ='Product', SVMXC__Allow_Override__c = true, SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, 
        SVMXC__Rule_Type__c='Auto Entitlement WO', 
        SVMXC__Entitlement_Scope__c='Service Contracts', 
        SVMXC__Entitlement_By__c='Counters', 
        SVMXC__Pick_First_Match__c = 'Service Contract',
        SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=false,
        SVMXC__Enable_Child_Line_Entitlement__c = true);
        insert AEProcess1;
        
        SVMXC__ServiceMax_Config_Data__c Cnfig1 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'eq', SVMXC__Operand__c='Operator1', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='IPRD_Counters', SVMXC__Expression_Rule__c=AEProcess1.Id, SVMXC__Display_Type__c='STRING');
        insert Cnfig1;
        
        SVMXC__Service_Order__c WO1 = new SVMXC__Service_Order__c(SVMXC__Country__c= 'Operator1' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=oAccount.Id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true);
        insert WO1;
        SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO1.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        insert WOLine1;
        
        WO1.SVMXC__Perform_Auto_Entitlement__c = true;
        update WO1;          
    }
    static testMethod void WORD_AutoEntitlementUnit_Entitle18(){
        createTestData();
        RecordType[] Rtypes = [select Id, Name,DeveloperName, SobjectType from RecordType where SobjectType=:'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Service_Order_Line__c'];
        RecordType Rtype, ExpressionsUT,RtypeProdServiced;
        for(RecordType rt : Rtypes){
            if(rt.Name == 'SVMX Rule')
                Rtype = rt;
            else if(rt.Name == 'Expressions')
                ExpressionsUT = rt;
            else if(rt.DeveloperName == 'Products_Serviced')
                RtypeProdServiced = rt;            
        }
        
        list<SVMXC__ServiceMax_Processes__c> lstProcess = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c AEProcess1 = new SVMXC__ServiceMax_Processes__c(SVMXC__Include_Product__c = true,SVMXC__Field_Name__c ='Product', SVMXC__Allow_Override__c = true, SVMXC__Include_Parent__c = true, SVMXC__Include_Top_Level__c = true, RecordTypeId=Rtype.Id, 
        SVMXC__Rule_Type__c='Auto Entitlement WO', 
        SVMXC__Entitlement_Scope__c='Service Contracts', 
        SVMXC__Entitlement_By__c='Both', 
        SVMXC__Pick_First_Match__c = 'Service Contract', 
        SVMXC__Counter_Vs_Dates_Rule__c = 'Both Are Valid',
        SVMXC__Match_Account__c=true, SVMXC__Match_Contact__c=true, SVMXC__Match_Location__c=true);
        insert AEProcess1;
        
        SVMXC__ServiceMax_Config_Data__c Cnfig1 = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsUT.Id, SVMXC__Sequence__c = 1, SVMXC__Operator__c = 'eq', SVMXC__Operand__c='Operator1', SVMXC__Field_Name__c='SVMXC__Country__c', SVMXC__Expression_Type__c='IPRD_Counters', SVMXC__Expression_Rule__c=AEProcess1.Id, SVMXC__Display_Type__c='STRING');
        insert Cnfig1;
        
        Account newAcc = new Account(Name = 'NewAccount');
        SVMXC__Service_Order__c WO1 = new SVMXC__Service_Order__c(SVMXC__Country__c= 'Operator1' ,SVMXC__Contact__c =oContact.Id, SVMXC__Company__c=newAcc.Id, SVMXC__Component__c=IB1.Id, SVMXC__Perform_Auto_Entitlement__c=true, SVMXC__Site__c = objSite.id);
        insert WO1;
        
        SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c(SVMXC__Service_Order__c = WO1.Id,RecordTypeId = RtypeProdServiced.Id,SVMXC__Serial_Number__c = IB1.Id);
        insert WOLine1;
        
        WO1.SVMXC__Perform_Auto_Entitlement__c = true;
        update WO1;         
        
    }  
}