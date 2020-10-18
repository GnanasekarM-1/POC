@isTest
Private with sharing class CONF_SetupRoutingRules_UT
 {
    static testMethod void CONF_SetupRoutingRules_UT_Test()
    {
        string ConfigExpId = '';
        string ConfigStopId = '';
        List<RecordType> ConfigRType = new List<RecordType>(); 
        RecordType records = [Select SobjectType, NamespacePrefix, Name, IsActive, Id, DeveloperName, Description From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' and name = 'SVMX Rule' limit 1];
        ConfigRType = Database.query('Select r.Name, r.IsActive, r.Id From RecordType r where SobjectType=\'SVMXC__ServiceMax_Config_Data__c\'');
        for(RecordType r : ConfigRType)
        {
            if(r.Name == 'Expressions')
                ConfigExpId = r.id;
             if(r.Name == 'Route Stops')
                ConfigStopId = r.id;
        }   
        SVMXC__ServiceMax_Processes__c processObj = new SVMXC__ServiceMax_Processes__c();
        processObj.RecordTypeId=records.Id;
        processObj.SVMXC__Select__c = true;
        processObj.SVMXC__Sequence__c = 1.0;
        processObj.SVMXC__APL_Route_Rule_Type__c = 'Inbound';
        processObj.SVMXC__Active__c = true;
        processObj.SVMXC__Name__C = 'Routing Rule';
        processObj.SVMXC__Advance_Expression__c = '1 AND 2';
        processObj.SVMXC__Description__c = 'Routing Rule';
        processObj.SVMXC__Rule_Type__c = 'Routing Rule';
        insert processObj;
        
        SVMXC__ServiceMax_Processes__c processObj1 = new SVMXC__ServiceMax_Processes__c();
        processObj1.RecordTypeId=records.Id;
        processObj1.SVMXC__Select__c = true;
        processObj1.SVMXC__Sequence__c = 2.0;
        processObj1.SVMXC__APL_Route_Rule_Type__c = 'Outbound';
        processObj1.SVMXC__Active__c = true;
        processObj1.SVMXC__Name__C = 'Routing Rule1';
        processObj1.SVMXC__Advance_Expression__c = '1 AND 2 AND 3';
        processObj1.SVMXC__Description__c = 'Routing Rule1';
        processObj1.SVMXC__Rule_Type__c = 'Routing Rule';
        insert processObj1;
        
        List<SVMXC__ServiceMax_Processes__c> processObjLst = new List<SVMXC__ServiceMax_Processes__c>();
        processObjLst.add(processObj);
        processObjLst.add(processObj1);
        
        SVMXC__Site__c Loc = new SVMXC__Site__c();
        Loc.Name = 'Bangalore';
        Loc.SVMXC__Country__c = 'India';
        insert Loc;
        
        SVMXC__Site__c Loc1 = new SVMXC__Site__c();
        Loc1.Name = 'Pune';
        Loc1.SVMXC__Country__c = 'India';
        insert Loc1;
    
        List<SVMXC__ServiceMax_Config_Data__c> LocExpLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        SVMXC__ServiceMax_Config_Data__c ConfigDataExp = new SVMXC__ServiceMax_Config_Data__c();
        ConfigDataExp.SVMXC__Location__c = Loc.id;
        ConfigDataExp.SVMXC__Dispatch_Process__c = processObj.id;
        ConfigDataExp.SVMXC__Sequence__c = 1.0000;
        ConfigDataExp.SVMXC__Select__c = true;
        ConfigDataExp.SVMXC__Operator__c = 'eq';
        ConfigDataExp.SVMXC__Operand__c = 'Bangalore';
        ConfigDataExp.SVMXC__Object_Name__c = 'SVMXC__Site__c';
        ConfigDataExp.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfigDataExp.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        ConfigDataExp.SVMXC__Active__c = true;
        ConfigDataExp.RecordTypeId = ConfigExpId;
        insert ConfigDataExp;
        LocExpLst.add(ConfigDataExp);
        
        SVMXC__ServiceMax_Config_Data__c ConfigDataExp1 = new SVMXC__ServiceMax_Config_Data__c();
        ConfigDataExp1.SVMXC__Location__c = Loc1.id;
        ConfigDataExp1.SVMXC__Dispatch_Process__c = processObj.id;
        ConfigDataExp1.SVMXC__Sequence__c = 2.0000;
        ConfigDataExp1.SVMXC__Select__c = true;
        ConfigDataExp1.SVMXC__Operator__c = 'eq';
        ConfigDataExp1.SVMXC__Operand__c = 'India';
        ConfigDataExp1.SVMXC__Object_Name__c = 'SVMXC__Site__c';
        ConfigDataExp1.SVMXC__Field_Name__c = 'SVMXC__Country__c';
        ConfigDataExp1.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        ConfigDataExp1.SVMXC__Active__c = true;
        ConfigDataExp1.RecordTypeId = ConfigExpId;
        insert ConfigDataExp1;
        LocExpLst.add(ConfigDataExp1);
        
        SVMXC__ServiceMax_Config_Data__c ConfigLoc = new SVMXC__ServiceMax_Config_Data__c();
        ConfigLoc.SVMXC__Location__c = Loc1.id;
        ConfigLoc.SVMXC__Dispatch_Process__c = processObj.id;
        ConfigLoc.SVMXC__Select__c = true;
        ConfigLoc.SVMXC__Active__c = true;
        ConfigLoc.RecordTypeId = ConfigStopId;
        insert ConfigLoc;
        
        SVMXC__ServiceMax_Config_Data__c ConfigLoc1 = new SVMXC__ServiceMax_Config_Data__c();
        ConfigLoc1.SVMXC__Location__c = Loc.id;
        ConfigLoc1.SVMXC__Dispatch_Process__c = processObj.id;
        ConfigLoc1.SVMXC__Select__c = true;
        ConfigLoc1.SVMXC__Active__c = true;
        ConfigLoc1.RecordTypeId = ConfigStopId;
        insert ConfigLoc1;
     
        string RoutID = '';
        RoutID = processObj.id;
        System.currentPageReference().getParameters().put('SVMX_RecordID', RoutID);
        System.currentPageReference().getParameters().put('SVMX_Mode', 'Clone');
        
        //.......class instantiation and calling various methods.......
        CONF_SetupRoutingRules RuleObj =  new CONF_SetupRoutingRules();
        boolean IsError = true;
        integer index = 1;
        RuleObj.setIntIndex(index);
        RuleObj.getIntIndex();
        RuleObj.AddLocRow();
        //RuleObj.DelLocRow();
        RuleObj.ADDCriRow();
        //RuleObj.DelCriRow();
        RuleObj.BackToSetupHome();
        RuleObj.RoutTypeAction();
        RuleObj.ObjectFields();
        RuleObj.getRuleLstSize();
        RuleObj.getObjectLst();
        RuleObj.getOperatorsSelectLst();
        RuleObj.getIsRender();
        RuleObj.setIsRender(IsError);
        RuleObj.getIsHdrMsg();
        RuleObj.setIsHdrMsg(IsError);
        RuleObj.getIsdisableValue();
        RuleObj.getIsExpMsg();
        RuleObj.setIsExpMsg(IsError);
        RuleObj.getLocLstSize();
        RuleObj.setLstSVMXRoutRules(processObjLst);
        RuleObj.setRoutRule(processObj1);
        RuleObj.getLstCriWrapSize();
        RuleObj.getLstSVMXRoutRules();
        RuleObj.getRoutRule();
        RuleObj.getLstCriWrap();
        RuleObj.setLocConfigLst(LocExpLst);
        RuleObj.getLocConfigLst();
        RuleObj.getTAG001();
        RuleObj.getTAG002();
        RuleObj.getTAG003();
        RuleObj.getTAG004();
        RuleObj.getTAG005();
        RuleObj.getTAG006();
        RuleObj.getTAG007();
        RuleObj.getTAG008();
        RuleObj.getTAG009();
        RuleObj.getTAG010();
        RuleObj.getTAG011();
        RuleObj.getTAG012();
        RuleObj.getTAG013();
        RuleObj.getTAG014();
        RuleObj.getTAG015();
        RuleObj.getTAG016();
        RuleObj.getTAG017();
        RuleObj.getTAG018();
        RuleObj.getTAG019();
        RuleObj.getTAG020();
        RuleObj.getTAG021();
        RuleObj.getTAG022();
        RuleObj.getTAG023();
        RuleObj.getTAG024();
        RuleObj.IsValidExp();
        
        List<SelectOption> TempObjFields = new  List<SelectOption>();
        string ObjName1 = 'Account';
        TempObjFields = RuleObj.getAllFields(ObjName1);
        
        IsError = RuleObj.IsValidProcess();
        PageReference pr = new PageReference('/apex/CONF_ManageRoutingRules');   
        pr = RuleObj.QuickSaveRules() ;
        pr = RuleObj.CancelRules();
        
        List<SVMXC__ServiceMax_Config_Data__c> lstExpressions = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Processes__c TempLocObj = new SVMXC__ServiceMax_Processes__c(SVMXC__Source_Object_Name__c = 'SVMXC__Site__c');
        SVMXC__ServiceMax_Config_Data__c TempExp;
        for(integer i=0; i < 5;i++)
        {
            TempExp = new SVMXC__ServiceMax_Config_Data__c();
            TempExp.SVMXC__Field_Name__c = 'SVMXC__City__c';
            TempExp.SVMXC__Operator__c = 'eq';
            TempExp.SVMXC__Operand__c = 'Bangalore';
            lstExpressions.add(TempExp);
        }
        upsert lstExpressions;
        
        CONF_SetupRoutingRules.ConfigExpWrapper WrapObj = new CONF_SetupRoutingRules.ConfigExpWrapper();
        WrapObj.getSequence();
        WrapObj.getSelObj();
        WrapObj.getSelFld();
        WrapObj.getObjFlds();
        WrapObj.getOperator();
        WrapObj.getOprand();
        string AdvancedExp = '';
        string ObjName = 'SVMXC__Site__c';
        IsError = RuleObj.submitExp( TempLocObj, LocExpLst);
        IsError = RuleObj.ValidateAdvancedExp( ObjName, AdvancedExp, lstExpressions);
    }
    
    static testMethod void CONF_SetupRoutingRules_UT_Test01()
    {
        string ConfigExpId = '';
        string ConfigStopId = '';
        List<RecordType> ConfigRType = new List<RecordType>(); 
        RecordType records = [Select SobjectType, NamespacePrefix, Name, IsActive, Id, DeveloperName, Description From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' and name = 'SVMX Rule' limit 1];
        ConfigRType = Database.query('Select r.Name, r.IsActive, r.Id From RecordType r where SobjectType=\'SVMXC__ServiceMax_Config_Data__c\'');
        for(RecordType r : ConfigRType)
        {
            if(r.Name == 'Expressions')
                ConfigExpId = r.id;
             if(r.Name == 'Route Stops')
                ConfigStopId = r.id;
        }   
        SVMXC__ServiceMax_Processes__c processObj = new SVMXC__ServiceMax_Processes__c();
        processObj.RecordTypeId=records.Id;
        processObj.SVMXC__Select__c = true;
        processObj.SVMXC__Sequence__c = 1.0;
        processObj.SVMXC__APL_Route_Rule_Type__c = 'Inbound';
        processObj.SVMXC__Active__c = true;
        processObj.SVMXC__Name__C = 'Routing Rule';
        processObj.SVMXC__Advance_Expression__c = '1 AND 2';
        processObj.SVMXC__Description__c = 'Routing Rule';
        processObj.SVMXC__Rule_Type__c = 'Routing Rule';
        insert processObj;
        
        SVMXC__ServiceMax_Processes__c processObj1 = new SVMXC__ServiceMax_Processes__c();
        processObj1.RecordTypeId=records.Id;
        processObj1.SVMXC__Select__c = true;
        processObj1.SVMXC__Sequence__c = 2.0;
        processObj1.SVMXC__APL_Route_Rule_Type__c = 'Outbound';
        processObj1.SVMXC__Active__c = true;
        processObj1.SVMXC__Name__C = 'Routing Rule1';
        processObj1.SVMXC__Advance_Expression__c = '1 AND 2 AND 3';
        processObj1.SVMXC__Description__c = 'Routing Rule1';
        processObj1.SVMXC__Rule_Type__c = 'Routing Rule';
        insert processObj1;
        
        List<SVMXC__ServiceMax_Processes__c> processObjLst = new List<SVMXC__ServiceMax_Processes__c>();
        processObjLst.add(processObj);
        processObjLst.add(processObj1);
        
        SVMXC__Site__c Loc = new SVMXC__Site__c();
        Loc.Name = 'Bangalore';
        Loc.SVMXC__Country__c = 'India';
        insert Loc;
        
        SVMXC__Site__c Loc1 = new SVMXC__Site__c();
        Loc1.Name = 'Pune';
        Loc1.SVMXC__Country__c = 'India';
        insert Loc1;
    
        List<SVMXC__ServiceMax_Config_Data__c> LocExpLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        SVMXC__ServiceMax_Config_Data__c ConfigDataExp = new SVMXC__ServiceMax_Config_Data__c();
        ConfigDataExp.SVMXC__Location__c = Loc.id;
        ConfigDataExp.SVMXC__Dispatch_Process__c = processObj.id;
        ConfigDataExp.SVMXC__Sequence__c = 1.0000;
        ConfigDataExp.SVMXC__Select__c = true;
        ConfigDataExp.SVMXC__Operator__c = 'eq';
        ConfigDataExp.SVMXC__Operand__c = 'Bangalore';
        ConfigDataExp.SVMXC__Object_Name__c = 'SVMXC__Site__c';
        ConfigDataExp.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfigDataExp.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        ConfigDataExp.SVMXC__Active__c = true;
        ConfigDataExp.RecordTypeId = ConfigExpId;
        insert ConfigDataExp;
        LocExpLst.add(ConfigDataExp);
        
        SVMXC__ServiceMax_Config_Data__c ConfigDataExp1 = new SVMXC__ServiceMax_Config_Data__c();
        ConfigDataExp1.SVMXC__Location__c = Loc1.id;
        ConfigDataExp1.SVMXC__Dispatch_Process__c = processObj.id;
        ConfigDataExp1.SVMXC__Sequence__c = 2.0000;
        ConfigDataExp1.SVMXC__Select__c = true;
        ConfigDataExp1.SVMXC__Operator__c = 'eq';
        ConfigDataExp1.SVMXC__Operand__c = 'true';
        ConfigDataExp1.SVMXC__Object_Name__c = 'Product2';
        ConfigDataExp1.SVMXC__Field_Name__c = 'Active';
        ConfigDataExp1.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        ConfigDataExp1.SVMXC__Active__c = true;
        ConfigDataExp1.RecordTypeId = ConfigExpId;
        insert ConfigDataExp1;
        
        SVMXC__ServiceMax_Config_Data__c ConfigDataExp2 = new SVMXC__ServiceMax_Config_Data__c();
        ConfigDataExp2.SVMXC__Location__c = Loc1.id;
        ConfigDataExp2.SVMXC__Dispatch_Process__c = processObj.id;
        ConfigDataExp2.SVMXC__Sequence__c = 2.0000;
        ConfigDataExp2.SVMXC__Select__c = true;
        ConfigDataExp2.SVMXC__Operator__c = 'eq';
        ConfigDataExp2.SVMXC__Operand__c = '12345';
        ConfigDataExp2.SVMXC__Object_Name__c = 'Account';
        ConfigDataExp2.SVMXC__Field_Name__c = 'Phone';
        ConfigDataExp2.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
        ConfigDataExp2.SVMXC__Active__c = true;
        ConfigDataExp2.RecordTypeId = ConfigExpId;
        insert ConfigDataExp2;
        LocExpLst.add(ConfigDataExp2);
        
        SVMXC__ServiceMax_Config_Data__c ConfigLoc = new SVMXC__ServiceMax_Config_Data__c();
        ConfigLoc.SVMXC__Location__c = Loc1.id;
        ConfigLoc.SVMXC__Dispatch_Process__c = processObj.id;
        ConfigLoc.SVMXC__Select__c = true;
        ConfigLoc.SVMXC__Active__c = true;
        ConfigLoc.RecordTypeId = ConfigStopId;
        insert ConfigLoc;
        
        SVMXC__ServiceMax_Config_Data__c ConfigLoc1 = new SVMXC__ServiceMax_Config_Data__c();
        ConfigLoc1.SVMXC__Location__c = Loc.id;
        ConfigLoc1.SVMXC__Dispatch_Process__c = processObj.id;
        ConfigLoc1.SVMXC__Select__c = true;
        ConfigLoc1.SVMXC__Active__c = true;
        ConfigLoc1.RecordTypeId = ConfigStopId;
        insert ConfigLoc1;
     
        string RoutID = '';
        RoutID = processObj.id;
        System.currentPageReference().getParameters().put('SVMX_RecordID', RoutID);
        System.currentPageReference().getParameters().put('SVMX_Mode', 'Edit');
        
        //.......class instantiation and calling various methods.......
        CONF_SetupRoutingRules RuleObj =  new CONF_SetupRoutingRules();
        boolean IsError = true;
        integer index = 1;
        RuleObj.setIntIndex(0);
        RuleObj.getIntIndex();
        RuleObj.AddLocRow();
        RuleObj.setIsdisableValue(false);
        RuleObj.ADDCriRow();
        RuleObj.getslctLstLocs();
        RuleObj.BackToSetupHome();
        RuleObj.RoutTypeAction();
        RuleObj.ObjectFields();
        RuleObj.getRuleLstSize();
        RuleObj.getObjectLst();
        RuleObj.getOperatorsSelectLst();
        RuleObj.getIsRender();
        RuleObj.setIsRender(IsError);
        RuleObj.getIsHdrMsg();
        RuleObj.setIsHdrMsg(IsError);
        RuleObj.getIsdisableValue();
        RuleObj.getIsExpMsg();
        RuleObj.setIsExpMsg(IsError);
        RuleObj.getLocLstSize();
        RuleObj.setLstSVMXRoutRules(processObjLst);
        RuleObj.setRoutRule(processObj1);
        RuleObj.getLstCriWrapSize();
        RuleObj.getLstSVMXRoutRules();
        RuleObj.getRoutRule();
        RuleObj.getLstCriWrap();
        RuleObj.setLocConfigLst(LocExpLst);
        RuleObj.getLocConfigLst();
        RuleObj.getTAG001();
        RuleObj.getTAG002();
        RuleObj.getTAG003();
        RuleObj.getTAG004();
        RuleObj.getTAG005();
        RuleObj.getTAG006();
        RuleObj.getTAG007();
        RuleObj.getTAG008();
        RuleObj.getTAG009();
        RuleObj.getTAG010();
        RuleObj.getTAG011();
        RuleObj.getTAG012();
        RuleObj.getTAG013();
        RuleObj.getTAG014();
        RuleObj.getTAG015();
        RuleObj.getTAG016();
        RuleObj.getTAG017();
        RuleObj.getTAG018();
        RuleObj.getTAG019();
        RuleObj.getTAG020();
        RuleObj.getTAG021();
        RuleObj.getTAG022();
        RuleObj.getTAG023();
        RuleObj.getTAG024();
        RuleObj.IsValidExp();
        List<SelectOption> TempObjFields = new  List<SelectOption>();
        string ObjName1 = 'Account';
        TempObjFields = RuleObj.getAllFields(ObjName1);
        IsError = RuleObj.IsValidProcess();
        PageReference pr = new PageReference('/apex/CONF_ManageRoutingRules');   
        pr = RuleObj.QuickSaveRules() ;
        pr = RuleObj.CancelRules();
        
        List<SVMXC__ServiceMax_Config_Data__c> lstExpressions = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Processes__c TempLocObj = new SVMXC__ServiceMax_Processes__c(SVMXC__Source_Object_Name__c = 'SVMXC__Site__c');
        SVMXC__ServiceMax_Config_Data__c TempExp;
        for(integer i=0; i < 5;i++)
        {
            TempExp = new SVMXC__ServiceMax_Config_Data__c();
            TempExp.SVMXC__Field_Name__c = 'SVMXC__City__c';
            TempExp.SVMXC__Operator__c = 'eq';
            TempExp.SVMXC__Operand__c = 'Bangalore';
            lstExpressions.add(TempExp);
        }
        upsert lstExpressions;
        list<CONF_SetupRoutingRules.ConfigExpWrapper> WrapObjLst = new list<CONF_SetupRoutingRules.ConfigExpWrapper>();
        CONF_SetupRoutingRules.ConfigExpWrapper WrapObj = new CONF_SetupRoutingRules.ConfigExpWrapper();
        WrapObj.getSequence();
        WrapObj.setSequence(0);
        WrapObj.getSelObj();
        WrapObj.setSelObj('Account');
        WrapObj.getSelFld();
        WrapObj.getObjFlds();
        WrapObj.getOperator();
        WrapObj.setOperator('equal');
        WrapObj.getOprand();
        WrapObj.setOprand('');
        string AdvancedExp = '';
        string ObjName = 'SVMXC__Site__c';
        WrapObjLst.add(WrapObj);
        RuleObj.setLstCriWrap(WrapObjLst);
        IsError = RuleObj.submitExp( TempLocObj, LocExpLst);
        IsError = RuleObj.ValidateAdvancedExp( ObjName, AdvancedExp, lstExpressions);
        RuleObj.getTAG025();
        RuleObj.getTAG040();
        //RuleObj.getTAG041();
        //RuleObj.getTAG042();
        //RuleObj.getTAG043();
        RuleObj.getTAG044();
        RuleObj.getTAG045();
        RuleObj.getHLPURL();
        RuleObj.getHLPTITLE();
    }
}