@istest
private class IPRD_CoverageByCounters_WarrantyUT{

    static testMethod void IPRD_CoverageByCounters_WarrantyUnitTest(){
        RecordType Rtype = new RecordType();
        RecordType Rtypedef = new RecordType();
        RecordType CountRecTypeUT = new RecordType();
        RecordType ExpressionsUT = new RecordType();
        Rtype = [select Id from RecordType where Name=:'SVMX Rule' and SobjectType=:'SVMXC__ServiceMax_Processes__c'];
        Rtypedef = [select Id from RecordType where Name=:'Definition' and SobjectType=:'SVMXC__Counter_Details__c'];
        CountRecTypeUT = [select Id from RecordType where Name=:'Coverage' and SobjectType=:'SVMXC__Counter_Details__c'];
        ExpressionsUT = [select Id from RecordType where Name=:'Expressions' and SobjectType=:'SVMXC__ServiceMax_Config_Data__c'];

        SVMXC__Service_Template__c WT1 = new SVMXC__Service_Template__c();
        WT1  =new SVMXC__Service_Template__c(
                                            SVMXC__Walk_in_Allowed__c =false,                                                       
                                            SVMXC__Unit_of_Time__c = '100', 
                                            SVMXC__Unit_of_Time_Material__c= 'Days', 
                                            SVMXC__Unit_of_Time_Expenses__c='Months', 
                                            SVMXC__Transferable__c=false, 
                                            SVMXC__Time_Covered__c=100, 
                                            SVMXC__Template_Type__c='Warranty', 
                                            SVMXC__Shipment_Allowed__c=false, 
                                            SVMXC__RMA_Required__c=true, 
                                            SVMXC__Onsite_Repair__c=true, 
                                            SVMXC__Material_Covered__c=100, 
                                            SVMXC__Loaner_Provided__c=false, 
                                            SVMXC__Invoice_Required__c=false, 
                                            SVMXC__Expenses_Covered__c=100, 
                                            SVMXC__Duration_of_Time_Coverage__c=100, 
                                            SVMXC__Duration_of_Material_Coverage__c=365, 
                                            SVMXC__Duration_of_Expenses__c=52, 
                                            SVMXC__Coverage_Effective_From__c='Install Date', 
                                            SVMXC__All_Services_Covered__c=false, 
                                            SVMXC__All_Products_Covered__c=false, 
                                            Name ='Template1' 
                                                );
        insert WT1;

        Product2 P1 = new Product2(Name = 'Product1',SVMXC__Inherit_Parent_Warranty__c=true,SVMXC__Product_Line__c='accessory,desktop',SVMXC__Tracking__c='Serialized,Lot/Batch Tracked',SVMXC__Unit_Of_Measure__c='Each,Gallon',IsActive=true);
        insert P1;
        
        SVMXC__ServiceMax_Processes__c CounterRuleListUtobj = new SVMXC__ServiceMax_Processes__c();
        CounterRuleListUtobj.SVMXC__ProcessID__c='PROCESS11';
        CounterRuleListUtobj.SVMXC__SettingId__c = 'PROCESS11';
        CounterRuleListUtobj.SVMXC__MapID__c='PROCESS11';
        CounterRuleListUtobj.SVMXC__Name__c = 'PROCESS22';
        CounterRuleListUtobj.RecordTypeId=Rtype.Id;
        CounterRuleListUtobj.SVMXC__Advance_Expression__c='1 AND 2';
        CounterRuleListUtobj.SVMXC__Description__c='Test Description';
        //CounterRuleListUtobj.SVMXC__Name__c = 'Test';
        CounterRuleListUtobj.SVMXC__Select__c=true;
        CounterRuleListUtobj.SVMXC__Rule_Type__c='Counters';
        insert CounterRuleListUtobj; 
  
        SVMXC__ServiceMax_Config_Data__c CnfiglstUTobj = new SVMXC__ServiceMax_Config_Data__c();
        CnfiglstUTobj.RecordTypeId = ExpressionsUT.Id;
        CnfiglstUTobj.SVMXC__Sequence__c = 1;
        CnfiglstUTobj.SVMXC__Operator__c = 'Test Operator';
        CnfiglstUTobj.SVMXC__Operand__c='AND';
        CnfiglstUTobj.SVMXC__Object_Name__c='SVMXC__ServiceMax_Config_Data__c';
        CnfiglstUTobj.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__Expression_Rule__c';
        CnfiglstUTobj.SVMXC__Field_Name__c='Name';
        CnfiglstUTobj.SVMXC__FKey_Name_Field__c='';
        CnfiglstUTobj.SVMXC__Expression_Type__c='IPRD_Counters';
        CnfiglstUTobj.SVMXC__Expression_Rule__c=CounterRuleListUtobj.Id;
        insert CnfiglstUTobj;

        SVMXC__Counter_Details__c CounterRecListUt = new SVMXC__Counter_Details__c();
        CounterRecListUt.RecordTypeID = CountRecTypeUT.Id;
        CounterRecListUt.SVMXC__Counter_Name__c = 'Test';
        //CounterRecListUt.SVMXC__Counter_Definition__c = CounterDefinationListUTobj.Id;
        CounterRecListUt.SVMXC__Counter_Reading__c = 51;
        CounterRecListUt.SVMXC__Counter_Type__c = 'Counter Test Type';
        CounterRecListUt.SVMXC__Grows_Reduces_By__c=1;
        CounterRecListUt.SVMXC__Min_Value__c = 50;
        CounterRecListUt.SVMXC__Max_Value__c = 100;
        CounterRecListUt.SVMXC__Active__c = true;
        CounterRecListUt.SVMXC__Select__c = true;
        CounterRecListUt.SVMXC__Counter_Rule__c = CounterRuleListUtobj.Id;     
        insert CounterRecListUt;
        
        SVMXC__Counter_Details__c CounterDefinationListUTobj = new SVMXC__Counter_Details__c();
        CounterDefinationListUTobj.RecordTypeID=Rtypedef.Id;
        CounterDefinationListUTobj.SVMXC__Counter_Name__c='Test Counter Name';
        CounterDefinationListUTobj.SVMXC__Counter_Definition__c = CounterRecListUt.Id;
        CounterDefinationListUTobj.SVMXC__Counter_Reading__c = 51;
        CounterDefinationListUTobj.SVMXC__Counter_Rule__c =CounterRuleListUtobj.Id;
        CounterDefinationListUTobj.SVMXC__Counter_Type__c = 'Counter Test Type';
        CounterDefinationListUTobj.SVMXC__Grows_Reduces_By__c =1;
        CounterDefinationListUTobj.SVMXC__Min_Value__c =50;
        CounterDefinationListUTobj.SVMXC__Max_Value__c =100;
        CounterDefinationListUTobj.SVMXC__Active__c = true;
        CounterDefinationListUTobj.SVMXC__Select__c = true;
        insert CounterDefinationListUTobj;

        SVMXC__Service_Template_Products__c stempprod = new SVMXC__Service_Template_Products__c();
        stempprod.SVMXC__Product__c = P1.Id;
        stempprod.SVMXC__Service_Template__c = WT1.Id;
        insert stempprod;
        test.starttest();
        system.assertNotEquals(stempprod.Id,null);
        
        system.assertEquals(System.currentPageReference().getParameters().get('PId'),null);

        System.currentPageReference().getParameters().put('PId',WT1.Id);

        system.assertNotEquals(System.currentPageReference().getParameters().get('PId'),null);

        SVMXC.IPRD_CoverageByCounters_Warranty CbyCounter = new SVMXC.IPRD_CoverageByCounters_Warranty();

        system.assertEquals(System.currentPageReference().getParameters().get('PId'),WT1.Id);

        CbyCounter.getTAG001();
        CbyCounter.getTAG002();
        CbyCounter.getTAG003();
        CbyCounter.getTAG004();
        CbyCounter.getTAG005();
        CbyCounter.getTAG006();
        CbyCounter.getTAG007();
        CbyCounter.getTAG008();
        CbyCounter.getTAG009();
        CbyCounter.getTAG010();
        CbyCounter.getTAG011();
        CbyCounter.getTAG012();
        CbyCounter.getTAG013();
        CbyCounter.getTAG014();
        CbyCounter.getTAG015();
        CbyCounter.getTAG016();
        CbyCounter.getTAG017();
        CbyCounter.getTAG018();
        CbyCounter.getTAG019();
        CbyCounter.getTAG020();
        CbyCounter.getTAG021();
        CbyCounter.getHLPURL();
        //CbyCounter.svmxTagList.clear();
        CbyCounter.getTAG001();
        CbyCounter.getTAG002();
        CbyCounter.getTAG003();
        CbyCounter.getTAG004();
        CbyCounter.getTAG005();
        CbyCounter.getTAG006();
        CbyCounter.getTAG007();
        CbyCounter.getTAG008();
        CbyCounter.getTAG009();
        CbyCounter.getTAG010();
        CbyCounter.getTAG011();
        CbyCounter.getTAG012();
        CbyCounter.getTAG013();
        CbyCounter.getTAG014();
        CbyCounter.getTAG015();
        CbyCounter.getTAG016();
        CbyCounter.getTAG017();
        CbyCounter.getTAG018();
        CbyCounter.getTAG019();
        CbyCounter.getTAG020();
        CbyCounter.getTAG021();
        CbyCounter.getHLPURL();

        CbyCounter.getDisbleSaveBttn();
        CbyCounter.setDisbleSaveBttn(true);
        CbyCounter.getShowPanel();
        CbyCounter.setShowPanel(true);
        CbyCounter.getWrapCounterList();
        CbyCounter.getCounterRecList();
        CbyCounter.getCounterCvrgList();
        CbyCounter.getWarrnty();
        CbyCounter.SVMX_SaveCounters();
        CbyCounter.SVMX_Cancel();
        
        List<SVMXC__Service_Template_Products__c> stempprodlst = new List<SVMXC__Service_Template_Products__c>();
        stempprodlst.add(stempprod);
        CbyCounter.mainMethod();
        
        SVMXC.IPRD_CoverageByCounters_Warranty.WrapCovrgCounter WrapCbyCounter = new SVMXC.IPRD_CoverageByCounters_Warranty.WrapCovrgCounter(CounterDefinationListUTobj,stempprod,'Product1','SVMXRULE1');
        WrapCbyCounter.getappProd();
        WrapCbyCounter.getCounter();
        WrapCbyCounter.getProdName();
        WrapCbyCounter.setProdName('Product1');
        WrapCbyCounter.getRuleName();
        WrapCbyCounter.setRuleName('SVMXRULE');
        CbyCounter.getTId();
        CbyCounter.setTId(null);
        CbyCounter.SVMX_Cancel();
        test.stoptest();
    }
}