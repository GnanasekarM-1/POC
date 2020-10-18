@isTest
private class APL_RoutingEngine_UT 
{
    static testMethod void APL_RoutingEngineTest() 
    {
        Product2 objProduct = new Product2(Name = 'TestProduct');
        insert objProduct;
        System.assert(objProduct.Name == 'TestProduct');
        
        Account objAcc = new Account();
        objAcc.Name = 'abccdef';
        insert objAcc;
        System.assert(objAcc.Name == 'abccdef');
        
        SVMXC__Site__c objLoc = new SVMXC__Site__c();
        objLoc.SVMXC__Account__c = objAcc.id;
        insert objLoc;
        System.assert(objLoc.id != null);
        
        Case objTestCase = new Case();
        objTestCase.AccountId = objAcc.id;
        insert objTestCase;
        System.assert(objTestCase.id != null);
        
        SVMXC__Case_Line__c objTestCaseLine = new SVMXC__Case_Line__c();
        objTestCaseLine.SVMXC__Case__c = objTestCase.id;
        objTestCaseLine.SVMXC__Product__c = objProduct.id;
        objTestCaseLine.SVMXC__Route_Card__c = null;
        insert objTestCaseLine;
        System.assert(objTestCaseLine.id != null);
        
        RecordType InitiateProcess_Rtype = [select Id from RecordType where Name='Initiate Return Process'and SobjectType=                                  'SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType InitiateProcess_Rtype1 = [select Id from RecordType where Name='Field Mapping'and SobjectType=                                   'SVMXC__ServiceMax_Config_Data__c' Limit 1];
        
        List<RecordType> LstProcessRType = new List<RecordType>(); 
        List<RecordType> LstConfigRType = new List<RecordType>(); 
        String StrConfigExpId = ''; 
        String StrConfigStopId = ''; 
        String StrSVMXRuleId = '';
        LstProcessRType = Database.query('Select r.Name, r.Id From RecordType r where SobjectType=\'SVMXC__ServiceMax_Processes__c\'');
        for(RecordType r : LstProcessRType)
        {
            if(r.Name == 'SVMX Rule')
                StrSVMXRuleId = r.id;
        }        
        LstConfigRType = Database.query('Select r.Name, r.IsActive, r.Id From RecordType r where SobjectType=\'SVMXC__ServiceMax_Config_Data__c\'');
        for(RecordType r : LstConfigRType)
        {
            if(r.Name == 'Expressions')
                StrConfigExpId = r.id;
            if(r.Name == 'Route Stops')
                StrConfigStopId = r.id;
        }   
        SVMXC__ServiceMax_Processes__c ObjProcess = new SVMXC__ServiceMax_Processes__c();
        ObjProcess.SVMXC__Name__c = 'Routing Rule1';
        ObjProcess.SVMXC__Description__c = 'Routing Rule1';
        ObjProcess.SVMXC__APL_Route_Rule_Type__c = 'inbound';
        ObjProcess.SVMXC__Active__c = true;
        ObjProcess.SVMXC__Rule_Type__c = 'Routing Rule';
        ObjProcess.RecordTypeId = StrSVMXRuleId;
        upsert ObjProcess;
        System.assert(ObjProcess.id != null);
        
        SVMXC__ServiceMax_Processes__c objINRTProcess = new SVMXC__ServiceMax_Processes__c();
        objINRTProcess.SVMXC__APL_Perform_Entitlement__c = true;
        objINRTProcess.SVMXC__APL_Perform_Route_Calculations__c = true;
        objINRTProcess.SVMXC__ProcessId__c = 'TestMethod';
        objINRTProcess.SVMXC__Name__c = 'TestMethod';
        objINRTProcess.SVMXC__APL_Print_RMA_Template__c = 'google.com';
        objINRTProcess.RecordtypeId = InitiateProcess_Rtype.Id;
        objINRTProcess.SVMXC__APL_Perform_Route_Calculations__c = true;
        objINRTProcess.SVMXC__Consider_Location_From_Object__c ='SVMXC__Case_Line__c';
        objINRTProcess.SVMXC__Consider_Location_From__c = 'SVMXC__Location__c';     
        insert objINRTProcess;
        System.assert(objINRTProcess.SVMXC__Name__c == 'TestMethod');
        
        List<SVMXC__ServiceMax_Config_Data__c> LstConfigDataExp = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c ConfigDataExp = new SVMXC__ServiceMax_Config_Data__c();
        ConfigDataExp.SVMXC__Sequence__c = 1;
        ConfigDataExp.SVMXC__Field_Name__c = 'Name';
        ConfigDataExp.SVMXC__Operator__c = 'eq';
        ConfigDataExp.SVMXC__Operand__c = 'ABC';
        ConfigDataExp.SVMXC__Object_Name2__c = 'Product2';
        ConfigDataExp.SVMXC__Dispatch_Process__c = ObjProcess.Id;
        ConfigDataExp.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        ConfigDataExp.SVMXC__Display_Type__c = 'REFERENCE';     
        ConfigDataExp.SVMXC__Field_Relationship_Name__c = 'CreatedBy';
        ConfigDataExp.SVMXC__FKey_Name_Field__c = 'Name';
        ConfigDataExp.RecordTypeId = StrConfigExpId;
        LstConfigDataExp.add(ConfigDataExp);
        
        SVMXC__ServiceMax_Config_Data__c ConfigDataExp1 = new SVMXC__ServiceMax_Config_Data__c();
        ConfigDataExp1.SVMXC__Sequence__c = 2;
        ConfigDataExp1.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfigDataExp1.SVMXC__Operator__c = 'eq';
        ConfigDataExp1.SVMXC__Operand__c = 'ABC';
        ConfigDataExp1.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        ConfigDataExp1.SVMXC__Dispatch_Process__c = ObjProcess.Id;
        ConfigDataExp1.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        ConfigDataExp1.SVMXC__Display_Type__c = 'REFERENCE';
        ConfigDataExp1.SVMXC__Field_Relationship_Name__c = 'SVMXC__Account__r';
        ConfigDataExp1.SVMXC__FKey_Name_Field__c = 'Name';
        ConfigDataExp1.RecordTypeId = StrConfigExpId;
        LstConfigDataExp.add(ConfigDataExp1);
        
        SVMXC__ServiceMax_Config_Data__c ConfigDataExp2 = new SVMXC__ServiceMax_Config_Data__c();
        ConfigDataExp2.SVMXC__Sequence__c = 3;
        ConfigDataExp2.SVMXC__Field_Name__c = 'Name';
        ConfigDataExp2.SVMXC__Operator__c = 'eq';
        ConfigDataExp2.SVMXC__Operand__c = 'ABC';
        ConfigDataExp2.SVMXC__Object_Name2__c = 'Account';
        ConfigDataExp2.SVMXC__Dispatch_Process__c = ObjProcess.Id;
        ConfigDataExp2.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        ConfigDataExp2.SVMXC__Display_Type__c = 'REFERENCE';
        ConfigDataExp2.SVMXC__Field_Relationship_Name__c = 'SVMXC__Access_Hours__r';
        ConfigDataExp2.SVMXC__FKey_Name_Field__c = 'Name';
        ConfigDataExp2.RecordTypeId = StrConfigExpId;
        LstConfigDataExp.add(ConfigDataExp2);
        
        SVMXC__ServiceMax_Config_Data__c ConfigDataExp3 = new SVMXC__ServiceMax_Config_Data__c();
        ConfigDataExp3.SVMXC__Sequence__c = 4;
        ConfigDataExp3.SVMXC__Field_Name__c = 'CaseNumber';
        ConfigDataExp3.SVMXC__Operator__c = 'eq';
        ConfigDataExp3.SVMXC__Operand__c = 'ABC';
        ConfigDataExp3.SVMXC__Object_Name2__c = 'Case';
        ConfigDataExp3.SVMXC__Dispatch_Process__c = ObjProcess.Id;
        ConfigDataExp3.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        ConfigDataExp3.SVMXC__Display_Type__c = 'REFERENCE';
        ConfigDataExp3.SVMXC__Field_Relationship_Name__c = 'BusinessHours';
        ConfigDataExp3.SVMXC__FKey_Name_Field__c = 'Name';
        ConfigDataExp3.RecordTypeId = StrConfigExpId;
        LstConfigDataExp.add(ConfigDataExp3);
        
        SVMXC__ServiceMax_Config_Data__c ConfigDataExp4 = new SVMXC__ServiceMax_Config_Data__c();
        ConfigDataExp4.SVMXC__Sequence__c = 5;
        ConfigDataExp4.SVMXC__Field_Name__c = 'Name';
        ConfigDataExp4.SVMXC__Operator__c = 'eq';
        ConfigDataExp4.SVMXC__Operand__c = 'ABC';
        ConfigDataExp4.SVMXC__Object_Name2__c = 'SVMXC__Case_Line__c';
        ConfigDataExp4.SVMXC__Dispatch_Process__c = ObjProcess.Id;
        ConfigDataExp4.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        ConfigDataExp4.SVMXC__Display_Type__c = 'REFERENCE';
        ConfigDataExp4.SVMXC__Field_Relationship_Name__c = 'SVMXC__Case__r';
        ConfigDataExp4.SVMXC__FKey_Name_Field__c = 'CaseNumber';
        ConfigDataExp4.RecordTypeId = StrConfigExpId;
        LstConfigDataExp.add(ConfigDataExp4);
        
        SVMXC__ServiceMax_Config_Data__c ConfigDataExp5 = new SVMXC__ServiceMax_Config_Data__c();
        ConfigDataExp5.SVMXC__Sequence__c = 6;
        ConfigDataExp5.SVMXC__Dispatch_Process__c = ObjProcess.Id;
        ConfigDataExp5.RecordTypeId  = StrConfigStopId;
        ConfigDataExp5.SVMXC__Location__c = objLoc.id; 
        LstConfigDataExp.add(ConfigDataExp5);
        insert LstConfigDataExp;
        System.assert(LstConfigDataExp.size() == 6);
        
        INTF_WebServicesDef.INTF_SFMRequest reqForEntitlement = new INTF_WebServicesDef.INTF_SFMRequest();
        reqForEntitlement.valueMap = new List<INTF_WebServicesDef.SVMXMap>();       
        reqForEntitlement.valueMap.add(new INTF_WebServicesDef.SVMXMap('AccountID',objAcc.id));
        reqForEntitlement.valueMap.add(new INTF_WebServicesDef.SVMXMap('ProductID',objProduct.id));
        reqForEntitlement.valueMap.add(new INTF_WebServicesDef.SVMXMap('LocationID',objLoc.id));
        reqForEntitlement.valueMap.add(new INTF_WebServicesDef.SVMXMap('RouteRuleId',ObjProcess.id));
        reqForEntitlement.valueMap.add(new INTF_WebServicesDef.SVMXMap('ProcessId','TestMethod'));
        reqForEntitlement.valueMap.add(new INTF_WebServicesDef.SVMXMap('CaseId',objTestCase.id));
        reqForEntitlement.valueMap.add(new INTF_WebServicesDef.SVMXMap('CaseLineId',objTestCaseLine.id));
        reqForEntitlement.valueMap.add(new INTF_WebServicesDef.SVMXMap('CaseLines',objTestCaseLine.id,new List<String>{objTestCaseLine.id}));
        reqForEntitlement.valueMap.add(new INTF_WebServicesDef.SVMXMap('IsPerformRouteCalc','true'));
        reqForEntitlement.valueMap.add(new INTF_WebServicesDef.SVMXMap('RouteType','inbound'));
        
        APL_RoutingEngine Obj = new APL_RoutingEngine();      
        Obj.APL_GetRouteInfo(reqForEntitlement);
        Obj.APL_GetAccountAndProductInfo( reqForEntitlement);
        Obj.APL_GetCaseInfo( reqForEntitlement);
        Obj.APL_UpdateRouteCardAndCaseLine(reqForEntitlement);
        
        reqForEntitlement.valueMap.add(new INTF_WebServicesDef.SVMXMap('IsPerformRouteCalc','false'));
        Obj.APL_UpdateRouteCardAndCaseLine(reqForEntitlement);

        SVMXC__ServiceMax_Processes__c objINRTProcess1 = new SVMXC__ServiceMax_Processes__c();
        objINRTProcess1.SVMXC__APL_Perform_Entitlement__c = true;
        objINRTProcess1.SVMXC__APL_Perform_Route_Calculations__c = true;
        objINRTProcess1.SVMXC__ProcessId__c = 'TestMethod';
        objINRTProcess1.SVMXC__Name__c = 'TestMethod';
        objINRTProcess1.SVMXC__APL_Print_RMA_Template__c = 'google.com';
        objINRTProcess1.RecordtypeId = InitiateProcess_Rtype.Id;
        objINRTProcess1.SVMXC__APL_Perform_Route_Calculations__c = true;
        objINRTProcess1.SVMXC__Consider_Location_From_Object__c ='Case';
        objINRTProcess1.SVMXC__Consider_Location_From__c = 'CaseNumber';
        objINRTProcess1.SVMXC__Submodule__c = ObjProcess.id;        
        insert objINRTProcess1;
        System.assert(objINRTProcess1.SVMXC__Name__c == 'TestMethod');

        Obj.APL_GetRouteInfo(reqForEntitlement);
        Obj.APL_GetAccountAndProductInfo( reqForEntitlement);
        Obj.APL_GetCaseInfo( reqForEntitlement);        
        Obj.APL_UpdateRouteCardAndCaseLine(reqForEntitlement);
    }
    static testMethod void APL_PerformRouteCalculationTest1() 
    {
        List<RecordType> LstProcessRType = new List<RecordType>(); 
        List<RecordType> LstConfigRType = new List<RecordType>(); 
        String StrConfigExpId = ''; 
        String StrConfigStopId = ''; 
        String StrSVMXRuleId = '';  
        LstProcessRType = Database.query('Select r.Name, r.Id From RecordType r where SobjectType=\'SVMXC__ServiceMax_Processes__c\'');
        for(RecordType r : LstProcessRType)
        {
            if(r.Name == 'SVMX Rule')
                StrSVMXRuleId = r.id;
        }
        LstConfigRType = Database.query('Select r.Name, r.IsActive, r.Id From RecordType r where SobjectType=\'SVMXC__ServiceMax_Config_Data__c\'');
        for(RecordType r : LstConfigRType)
        {
            if(r.Name == 'Expressions')
                StrConfigExpId = r.id;
            if(r.Name == 'Route Stops')
                StrConfigStopId = r.id;
        }     
        SVMXC__ServiceMax_Processes__c ObjProcess = new SVMXC__ServiceMax_Processes__c();
        ObjProcess.SVMXC__Name__c = 'Routing Rule1';
        ObjProcess.SVMXC__Description__c = 'Routing Rule1';
        ObjProcess.SVMXC__APL_Route_Rule_Type__c = 'outbound';
        ObjProcess.SVMXC__Active__c = true;
        ObjProcess.SVMXC__Rule_Type__c = 'Routing Rule';
        ObjProcess.RecordTypeId = StrSVMXRuleId;
        upsert ObjProcess;
        System.assert(ObjProcess.id != null);
        
        List<SVMXC__ServiceMax_Config_Data__c> LstConfigDataExp = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c ConfigDataExp = new SVMXC__ServiceMax_Config_Data__c();
        ConfigDataExp.SVMXC__Sequence__c = 1;
        ConfigDataExp.SVMXC__Field_Name__c = 'Name';
        ConfigDataExp.SVMXC__Operator__c = 'eq';
        ConfigDataExp.SVMXC__Operand__c = 'ABC';
        ConfigDataExp.SVMXC__Object_Name2__c = 'Product2';
        ConfigDataExp.SVMXC__Dispatch_Process__c = ObjProcess.Id;
        ConfigDataExp.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        ConfigDataExp.RecordTypeId = StrConfigExpId;
        LstConfigDataExp.add(ConfigDataExp);
        
        SVMXC__ServiceMax_Config_Data__c ConfigDataExp1 = new SVMXC__ServiceMax_Config_Data__c();
        ConfigDataExp1.SVMXC__Sequence__c = 2;
        ConfigDataExp1.SVMXC__Field_Name__c = ' SVMXC__City__c';
        ConfigDataExp1.SVMXC__Operator__c = 'eq';
        ConfigDataExp1.SVMXC__Operand__c = 'ABC';
        ConfigDataExp1.SVMXC__Object_Name2__c = 'SVMXC__Site__c';
        ConfigDataExp1.SVMXC__Dispatch_Process__c = ObjProcess.Id;
        ConfigDataExp1.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        ConfigDataExp1.RecordTypeId = StrConfigExpId;
        LstConfigDataExp.add(ConfigDataExp1);        
        upsert LstConfigDataExp;
        System.assert(LstConfigDataExp.size() == 2);
        
        SVMXC__Site__c Loc = new SVMXC__Site__c();
        Loc.SVMXC__City__c = 'Bangalore';
        upsert Loc;
        System.assert(Loc.id != null);
        
        Product2 Prod = new Product2();
        Prod.Name = 'Computer';
        upsert Prod;
        System.assert(Prod.id != null);
        
        Account Acc = new Account();
        Acc.Name = 'Computer';
        upsert Acc;
        System.assert(Acc.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfigDataLoc1 = new SVMXC__ServiceMax_Config_Data__c();
        ConfigDataLoc1.SVMXC__Sequence__c = 1;
        ConfigDataLoc1.SVMXC__Location__c = Loc.Id;
        upsert ConfigDataLoc1;
        System.assert(ConfigDataLoc1.id != null);
        
        INTF_WebServicesDef.INTF_SFMRequest reqForEntitlement = new INTF_WebServicesDef.INTF_SFMRequest();
        reqForEntitlement.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        reqForEntitlement.valueMap.add(new INTF_WebServicesDef.SVMXMap('RouteType','outbound'));
        reqForEntitlement.valueMap.add(new INTF_WebServicesDef.SVMXMap('AccountID',Acc.Id));
        reqForEntitlement.valueMap.add(new INTF_WebServicesDef.SVMXMap('ProductID',Prod.Id));
        reqForEntitlement.valueMap.add(new INTF_WebServicesDef.SVMXMap('LocationID',Loc.Id));
        APL_RoutingEngine Obj = new APL_RoutingEngine();
        Obj.APL_GetRouteInfo(reqForEntitlement);
    }
    static testMethod void APL_PerformRouteCalculationTest2() 
    {
        Case objTestCase = new Case();
        insert objTestCase;
        System.assert(objTestCase.id != null);
        
        SVMXC__Case_Line__c objTestCaseLine = new SVMXC__Case_Line__c();
        objTestCaseLine.SVMXC__Case__c = objTestCase.id;        
        insert objTestCaseLine;
        System.assert(objTestCaseLine.id != null);
        
        INTF_WebServicesDef.INTF_SFMRequest reqForEntitlement = new INTF_WebServicesDef.INTF_SFMRequest();
        reqForEntitlement.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        reqForEntitlement.valueMap.add(new INTF_WebServicesDef.SVMXMap('ProductId',''));
        reqForEntitlement.valueMap.add(new INTF_WebServicesDef.SVMXMap('RouteRuleId',''));
        
        APL_RoutingEngine Obj = new APL_RoutingEngine();
        Obj.APL_GetRouteInfo(reqForEntitlement);
        Obj.APL_GetAccountAndProductInfo( reqForEntitlement);
        Obj.APL_GetCaseInfo( reqForEntitlement);
        Obj.getTAG002();
        Obj.APL_UpdateRouteCardAndCaseLine(null);
    }
}