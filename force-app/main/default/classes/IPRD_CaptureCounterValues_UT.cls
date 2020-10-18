@isTest(SeeAlldata=true)
private class IPRD_CaptureCounterValues_UT{

static testMethod void IPRD_CaptureCounterValuesUnitTest(){
    Product2 P1 = new Product2(Name = 'Product1',SVMXC__Inherit_Parent_Warranty__c=true,SVMXC__Product_Line__c='accessory,desktop',SVMXC__Tracking__c='Serialized,Lot/Batch Tracked',SVMXC__Unit_Of_Measure__c='Each,Gallon',IsActive=true);
    insert P1;
    
    SVMXC__Installed_Product__c IBProdUTobj1 = new SVMXC__Installed_Product__c();
    IBProdUTobj1.Name = 'Installedproduct1';
    IBProdUTobj1.SVMXC__Serial_Lot_Number__c='11223344';
    IBProdUTobj1.SVMXC__Product__c=P1.Id;    
    insert IBProdUTobj1;
    system.assert(IBProdUTobj1.Name!=null);
    system.assert(IBProdUTobj1.SVMXC__Product__c!=null);
    
    SVMXC__Counter_Details__c CDetailsUTobj = new SVMXC__Counter_Details__c();
    
    RecordType Rtype = new RecordType();
    RecordType Rtypedef = new RecordType();
    RecordType CountRecTypeUT = new RecordType();
    RecordType ExpressionsUT = new RecordType();
    
    Rtype = [select Id from RecordType where Name=:'SVMX Rule'];
    Rtypedef = [select Id from RecordType where Name=:'Definition'and SobjectType=:'SVMXC__Counter_Details__c'];
    CountRecTypeUT = [select Id from RecordType where Name=:'Reading'and SobjectType=:'SVMXC__Counter_Details__c'];
    ExpressionsUT = [select Id from RecordType where Name=:'Expressions'];
    
    List<SVMXC__ServiceMax_Processes__c> counterRList= new List<SVMXC__ServiceMax_Processes__c>();
    SVMXC__ServiceMax_Processes__c CounterRuleListUtobj = new SVMXC__ServiceMax_Processes__c();
    CounterRuleListUtobj.SVMXC__ProcessID__c='PROCESS11';
    CounterRuleListUtobj.SVMXC__SettingId__c = 'PROCESS11';
    CounterRuleListUtobj.SVMXC__MapID__c='PROCESS11';
    CounterRuleListUtobj.SVMXC__Name__c = 'PROCESS22';
    CounterRuleListUtobj.RecordTypeId=Rtype.Id;
    CounterRuleListUtobj.SVMXC__Advance_Expression__c='1 AND 2';
    CounterRuleListUtobj.SVMXC__Description__c='Test Description';
    CounterRuleListUtobj.SVMXC__Select__c=true;
    CounterRuleListUtobj.SVMXC__Active__c = true;
    CounterRuleListUtobj.SVMXC__Rule_Type__c='Counters';
    insert CounterRuleListUtobj;
    counterRList.add(CounterRuleListUtobj);
    system.assert(CounterRuleListUtobj.SVMXC__ProcessID__c!=null);
    system.assert(CounterRuleListUtobj.SVMXC__Name__c!=null);
    system.assert(counterRList.size()>0);
    
    
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
    system.assert(CnfiglstUTobj.RecordTypeId!=null);
    system.assert(CnfiglstUTobj.SVMXC__Object_Name__c!=null);
    
    
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
    CounterRecListUt.SVMXC__Is_Latest__c = true;
    CounterRecListUt.SVMXC__Select__c = true;
    CounterRecListUt.SVMXC__Counter_Rule__c = CounterRuleListUtobj.Id;
    CounterRecListUt.SVMXC__Installed_Product__c = IBProdUTobj1.Id;
    insert CounterRecListUt;
    
    
    system.assert(CounterRecListUt.RecordTypeId!=null);
    system.assert(CounterRecListUt.SVMXC__Counter_Reading__c!=null);
    
    SVMXC__Counter_Details__c CounterRecListUt1 = new SVMXC__Counter_Details__c();
    CounterRecListUt1.RecordTypeID = CountRecTypeUT.Id;
    CounterRecListUt1.SVMXC__Counter_Name__c = 'Test';
   // CounterRecListUt1.SVMXC__Counter_Definition__c = CounterDefinationListUTobj.Id;
    CounterRecListUt1.SVMXC__Counter_Reading__c = 51;
    CounterRecListUt1.SVMXC__Counter_Type__c = 'Counter Test Type';
    CounterRecListUt1.SVMXC__Grows_Reduces_By__c=1;
    CounterRecListUt1.SVMXC__Min_Value__c = 50;
    CounterRecListUt1.SVMXC__Max_Value__c = 100;
    CounterRecListUt1.SVMXC__Active__c = true;
    CounterRecListUt1.SVMXC__Select__c = true;
    CounterRecListUt1.SVMXC__Counter_Rule__c = CounterRuleListUtobj.Id;
    CounterRecListUt1.SVMXC__Installed_Product__c = IBProdUTobj1.Id;
    insert CounterRecListUt1;
    
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
    
    
    //System.currentPageReference().getParameters().put('PId',IBProdUTobj1.Id); 
    SVMXC.IPRD_CaptureCounterValues CCValues = new SVMXC.IPRD_CaptureCounterValues();
    
    CCValues.CounterRecList.add(CounterDefinationListUTobj);
    CCValues.CounterReadingList.add(CounterRecListUt1);
    CCValues.CounterReadingList.add(CounterRecListUt);
    CCValues.CounterRuleList.add(CounterRuleListUtobj);
    CCValues.ValidMap.put(P1.Id, CounterRuleListUtobj.id); 
    

    
    //CCValues.IBId=  System.currentPageReference().getParameters().put('PId',IBProdUTobj1.Id);
    System.assertEquals(CCValues.IBId, null);
    //CCValues.IBId = IBProdUTobj1.Id; 
    //CCValues.mainMethod();    
    CCValues.getTAG001();
    CCValues.getTAG002();
    CCValues.getTAG003();
    CCValues.getTAG004();
    CCValues.getTAG005();
    CCValues.getTAG006();
    CCValues.getTAG007();
    CCValues.getTAG008();
    CCValues.getTAG009();
    CCValues.getTAG010();
    CCValues.getTAG011();
    CCValues.getTAG012();
    CCValues.getTAG013();
    CCValues.getTAG014();
    CCValues.getTAG015();
    //CCValues.svmxTagList.clear();
    CCValues.getTAG001();
    CCValues.getTAG002();
    CCValues.getTAG003();
    CCValues.getTAG004();
    CCValues.getTAG005();
    CCValues.getTAG006();
    CCValues.getTAG007();
    CCValues.getTAG008();
    CCValues.getTAG009();
    CCValues.getTAG010();
    CCValues.getTAG011();
    CCValues.getTAG012();
    CCValues.getTAG013();
    CCValues.getTAG014();
    CCValues.getTAG015();
    
    SVMXC.IPRD_CaptureCounterValues.WrapCounter  CCValuesWrapCounter = new SVMXC.IPRD_CaptureCounterValues.WrapCounter(CounterRecListUt,1 );
    CCValuesWrapCounter.getCounter();
    CCValuesWrapCounter.getReading();
    CCValuesWrapCounter.setReading(1);
     
    SVMXC.IPRD_CaptureCounterValues.WrapCounter  CCValuesWrapCounter1 = new SVMXC.IPRD_CaptureCounterValues.WrapCounter(CounterRecListUt,null);
    CCValuesWrapCounter1.getCounter();
    CCValuesWrapCounter1.getReading();
    CCValuesWrapCounter1.setReading(1);
    CCValues.mainMethod();
   
    CCValues.setDisbleSaveBttn(false);
    CCValues.getDisbleSaveBttn();
    CCValues.getShowPanel();
    CCValues.setShowPanel(true);
    CCValues.getWrapCounterList(); 
    CCValues.getCounterRecList();
    CCValues.getCounterReadingList();
    CCValues.getIBProd();
    CCValues.SVMX_SaveCounters();
    CCValues.SVMX_Cancel();
    System.currentPagereference().getParameters().put('PId',IBProdUTobj1.Id);
    SVMXC.IPRD_CaptureCounterValues CCValues1 = new SVMXC.IPRD_CaptureCounterValues();
    CCValues1.ValidMap.put(P1.Id, CounterRuleListUtobj.id); 
    CCValues1.mainMethod();
}

    static testMethod void IPRD_CaptureCounterValuesUnitTest2(){ 
        Product2 P1 = new Product2(Name = 'Product1',SVMXC__Inherit_Parent_Warranty__c=true,SVMXC__Product_Line__c='accessory,desktop',SVMXC__Tracking__c='Serialized,Lot/Batch Tracked',SVMXC__Unit_Of_Measure__c='Each,Gallon',IsActive=true);
        insert P1;
        
        SVMXC__Installed_Product__c IBProdUTobj1 = new SVMXC__Installed_Product__c();
        IBProdUTobj1.Name = 'Installedproduct1';
        IBProdUTobj1.SVMXC__Serial_Lot_Number__c='11223344';
        IBProdUTobj1.SVMXC__Product__c=P1.Id;    
        insert IBProdUTobj1;
        system.assert(IBProdUTobj1.Name!=null);
        system.assert(IBProdUTobj1.SVMXC__Product__c!=null);
        
        SVMXC__Counter_Details__c CDetailsUTobj = new SVMXC__Counter_Details__c();
        
        RecordType Rtype = new RecordType();
        RecordType Rtypedef = new RecordType();
        RecordType CountRecTypeUT = new RecordType();
        RecordType ExpressionsUT = new RecordType();
        
        Rtype = [select Id from RecordType where Name=:'SVMX Rule'];
        Rtypedef = [select Id from RecordType where Name=:'Definition'and SobjectType=:'SVMXC__Counter_Details__c'];
        CountRecTypeUT = [select Id from RecordType where Name=:'Reading'and SobjectType=:'SVMXC__Counter_Details__c'];
        ExpressionsUT = [select Id from RecordType where Name=:'Expressions'];
        
        List<SVMXC__ServiceMax_Processes__c> counterRList= new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c CounterRuleListUtobj = new SVMXC__ServiceMax_Processes__c();
        CounterRuleListUtobj.SVMXC__ProcessID__c='PROCESS11';
        CounterRuleListUtobj.SVMXC__SettingId__c = 'PROCESS11';
        CounterRuleListUtobj.SVMXC__MapID__c='PROCESS11';
        CounterRuleListUtobj.SVMXC__Name__c = 'PROCESS22';
        CounterRuleListUtobj.RecordTypeId=Rtype.Id;
        CounterRuleListUtobj.SVMXC__Advance_Expression__c='1 AND 2';
        CounterRuleListUtobj.SVMXC__Description__c='Test Description';
        CounterRuleListUtobj.SVMXC__Select__c=true;
        CounterRuleListUtobj.SVMXC__Rule_Type__c='Counters';
        insert CounterRuleListUtobj;
        counterRList.add(CounterRuleListUtobj);
        system.assert(CounterRuleListUtobj.SVMXC__ProcessID__c!=null);
        system.assert(CounterRuleListUtobj.SVMXC__Name__c!=null);
        system.assert(counterRList.size()>0);
        
        
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
        system.assert(CnfiglstUTobj.RecordTypeId!=null);
        system.assert(CnfiglstUTobj.SVMXC__Object_Name__c!=null);
        
        
        
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
        CounterRecListUt.SVMXC__Is_Latest__c = true;
        CounterRecListUt.SVMXC__Select__c = true;
        CounterRecListUt.SVMXC__Counter_Rule__c = CounterRuleListUtobj.Id;
        CounterRecListUt.SVMXC__Installed_Product__c = IBProdUTobj1.Id;
        insert CounterRecListUt;
        
        
        system.assert(CounterRecListUt.RecordTypeId!=null);
        system.assert(CounterRecListUt.SVMXC__Counter_Reading__c!=null);
        
        SVMXC__Counter_Details__c CounterRecListUt1 = new SVMXC__Counter_Details__c();
        CounterRecListUt1.RecordTypeID = CountRecTypeUT.Id;
        CounterRecListUt1.SVMXC__Counter_Name__c = 'Test';
       // CounterRecListUt1.SVMXC__Counter_Definition__c = CounterDefinationListUTobj.Id;
        CounterRecListUt1.SVMXC__Counter_Reading__c = 51;
        CounterRecListUt1.SVMXC__Counter_Type__c = 'Counter Test Type';
        CounterRecListUt1.SVMXC__Grows_Reduces_By__c=1;
        CounterRecListUt1.SVMXC__Min_Value__c = 50;
        CounterRecListUt1.SVMXC__Max_Value__c = 100;
        CounterRecListUt1.SVMXC__Active__c = true;
        CounterRecListUt1.SVMXC__Select__c = true;
        CounterRecListUt1.SVMXC__Counter_Rule__c = CounterRuleListUtobj.Id;
        CounterRecListUt1.SVMXC__Installed_Product__c = IBProdUTobj1.Id;
        insert CounterRecListUt1;
        
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
        System.currentPagereference().getParameters().put('PId',IBProdUTobj1.Id);
        
        SVMXC.IPRD_CaptureCounterValues CCValues = new SVMXC.IPRD_CaptureCounterValues();
    
        CCValues.CounterRecList.add(CounterDefinationListUTobj);
        CCValues.CounterReadingList.add(CounterRecListUt1);
        CCValues.CounterReadingList.add(CounterRecListUt);
        CCValues.CounterRuleList.add(CounterRuleListUtobj);
        CCValues.ValidMap.put(P1.Id, CounterRuleListUtobj.id); 
        SVMXC.IPRD_CaptureCounterValues.WrapCounter  CCValuesWrapCounter = new SVMXC.IPRD_CaptureCounterValues.WrapCounter(CounterRecListUt,1 );
        CCValuesWrapCounter.getCounter();
        CCValuesWrapCounter.getReading();
        CCValuesWrapCounter.setReading(1);
        CCValues.WrapCounterList.add(CCValuesWrapCounter);
         
        SVMXC.IPRD_CaptureCounterValues.WrapCounter  CCValuesWrapCounter1 = new SVMXC.IPRD_CaptureCounterValues.WrapCounter(CounterRecListUt,null);
        CCValuesWrapCounter1.getCounter();
        CCValuesWrapCounter1.getReading();
        CCValuesWrapCounter1.setReading(1);
        CCValues.WrapCounterList.add(CCValuesWrapCounter1);
        CCValues.setDisbleSaveBttn(false);
        CCValues.getDisbleSaveBttn();
        CCValues.getShowPanel();
        CCValues.setShowPanel(true);
        CCValues.getWrapCounterList(); 
        CCValues.getCounterRecList();
        CCValues.getCounterReadingList();
        CCValues.getIBProd();
        CCValues.SVMX_SaveCounters();
    }

}