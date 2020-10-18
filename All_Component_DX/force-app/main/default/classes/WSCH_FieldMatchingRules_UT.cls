/**
UT class for WSCH_FieldMatchingRules
**/
@isTest(seeAllData = true)
public with sharing class WSCH_FieldMatchingRules_UT {
    
    public List<SVMXC__ServiceMax_Config_Data__c> lsteligibilityMatchConfig = new List<SVMXC__ServiceMax_Config_Data__c>();
    //public List<SVMXC__ServiceMax_Config_Data__c> lstTargetSourceAssignConfig = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<WSCH_FieldMatchingRules.TargetSourceMatchConfigWrapper> LstTargetSourceMatchWrap = new List<WSCH_FieldMatchingRules.TargetSourceMatchConfigWrapper>();
    public SVMXC__ServiceMax_Processes__c processObjFieldMatchRule = new SVMXC__ServiceMax_Processes__c();
    public  List<SVMXC__ServiceMax_Processes__c>  lstWOFieldMatchingRules = new  List<SVMXC__ServiceMax_Processes__c> ();
    public List<SVMXC__ServiceMax_Processes__c> lstTempWOFieldMatchingRules  = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> lsteligMatchConfigDel = new List<SVMXC__ServiceMax_Config_Data__c>();
    //public List<SVMXC__ServiceMax_Config_Data__c> lstTargetSourceAssignConfigDel = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<selectOption> object1Optns = new List<selectOption>();
    public List<selectOption> object2Optns = new List<selectOption>();
    string[] str;
    
    
    static TestMethod void testCustomLabels() {
        
        WSCH_FieldMatchingRules woFieldMatchingRules = new WSCH_FieldMatchingRules();
        
        woFieldMatchingRules.getHLPTITLE();
        woFieldMatchingRules.getHLPURL();
        woFieldMatchingRules.getTAG001();
        woFieldMatchingRules.getTAG002();
        woFieldMatchingRules.getTAG003();
        woFieldMatchingRules.getTAG004();
        woFieldMatchingRules.getTAG005();
        woFieldMatchingRules.getTAG006();
        woFieldMatchingRules.getTAG007();
        woFieldMatchingRules.getTAG008();
        woFieldMatchingRules.getTAG009();
        woFieldMatchingRules.getTAG010();
        woFieldMatchingRules.getTAG011();
        woFieldMatchingRules.getTAG012();
        woFieldMatchingRules.getTAG013();
        woFieldMatchingRules.getTAG014();
        woFieldMatchingRules.getTAG015();
        woFieldMatchingRules.getTAG016();
        woFieldMatchingRules.getTAG017();
        woFieldMatchingRules.getTAG018();
        woFieldMatchingRules.getTAG019();
        woFieldMatchingRules.getTAG020();
        woFieldMatchingRules.getTAG021();
        woFieldMatchingRules.getTAG022();
        woFieldMatchingRules.getTAG023();
        woFieldMatchingRules.getTAG024();
        woFieldMatchingRules.getTAG025();
        woFieldMatchingRules.getTAG026();
        woFieldMatchingRules.getTAG027();
        woFieldMatchingRules.getTAG028();
        woFieldMatchingRules.getTAG029();
        woFieldMatchingRules.getTAG030();
        woFieldMatchingRules.getTAG031();
        woFieldMatchingRules.getTAG032();
        woFieldMatchingRules.getTAG033();
        woFieldMatchingRules.getTAG034();
        woFieldMatchingRules.getTAG035();
        woFieldMatchingRules.getTAG036();
        woFieldMatchingRules.getTAG037();
        woFieldMatchingRules.getTAG038();
        woFieldMatchingRules.getTAG039();
        woFieldMatchingRules.getTAG040();
        woFieldMatchingRules.getTAG041();
        woFieldMatchingRules.getTAG042();
        woFieldMatchingRules.getTAG043();
        woFieldMatchingRules.getTAG044();
        woFieldMatchingRules.getTAG045();
        woFieldMatchingRules.getTAG046();
        woFieldMatchingRules.getTAG047();
        woFieldMatchingRules.getTAG048();
        woFieldMatchingRules.getTAG049();
        woFieldMatchingRules.getTAG050();
        woFieldMatchingRules.getTAG051();
        woFieldMatchingRules.getTAG052();
        woFieldMatchingRules.getTAG053();
        woFieldMatchingRules.getTAG054();
        woFieldMatchingRules.getTAG055();
        woFieldMatchingRules.getTAG056();
        woFieldMatchingRules.getTAG057();
        woFieldMatchingRules.getTAG058();
        woFieldMatchingRules.getTAG059();
        woFieldMatchingRules.getTAG060();
        woFieldMatchingRules.getTAG061();
        woFieldMatchingRules.getTAG062();
        woFieldMatchingRules.getTAG063();
        woFieldMatchingRules.getTAG064();
        woFieldMatchingRules.getTAG065();
        woFieldMatchingRules.getTAG066();
        woFieldMatchingRules.getTAG067();
        woFieldMatchingRules.getTAG068();
        woFieldMatchingRules.getTAG069();
        
    }
    
    static TestMethod void testGettersSetters() {
    
         String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
            
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts){
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               DispatchProRecordTypeId = rt.ID;
            else if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               ExpressionRTypeId = rt.ID;
            else if(rt.Name == 'SVMX Rule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               RuleRecordTypeId = rt.id;
            else if(rt.Name == 'Field Mapping' &&  rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               FldMapRecordTypeId = rt.id;
            else if(rt.Name == 'Coverage' &&  rt.SobjectType == 'SVMXC__Territory_Coverage__c')
               TCRT = rt.id;
        }     
        
        WSCH_FieldMatchingRules woFieldMatchingRules = new WSCH_FieldMatchingRules();
        
        WSCH_FieldMatchingRules_UT woFieldMatchRulesUT = new WSCH_FieldMatchingRules_UT();
        
        woFieldMatchingRules.StrDelIndex3 = '3';
        woFieldMatchingRules.strMapId = '1';
        
        woFieldMatchingRules.getisNewRule();
        //woFieldMatchingRules.getObject1Optns();
        //woFieldMatchingRules.getObject2Optns();
        woFieldMatchingRules.getisRenderRuleSeq();
        woFieldMatchingRules.getdisplaySeqPopup();
        woFieldMatchingRules.getMap_ObjName_Label();
        woFieldMatchingRules.getprocessObjFieldMatchRule();
        woFieldMatchingRules.getlstWOFieldMatchingRules();
        woFieldMatchingRules.getlsteligibilityMatchConfig();
        //woFieldMatchingRules.getlstTargetSourceAssignConfig();
        woFieldMatchingRules.getlstWOfield();
        woFieldMatchingRules.getlstSourceObjField();
        woFieldMatchingRules.getlstTargetObjField();
        woFieldMatchingRules.getlstOperatorSelectLst();
        woFieldMatchingRules.getlsteligMatchSize();
        //woFieldMatchingRules.getlstTargetSourceAssignSize();
        woFieldMatchingRules.getLstTargetSourceMatchWrap();
        woFieldMatchingRules.getLstTargetSourceMatchWrapSize();
        woFieldMatchingRules.getorderByFieldsLst();
        woFieldMatchingRules.getlstOfFieldMaps();
        
        List<selectOption> orderByFieldLst = new List<selectOption>();
        woFieldMatchingRules.setorderByFieldsLst(orderByFieldLst);
        
        woFieldMatchingRules.lstTempWOFieldMatchingRules = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c process1 = new SVMXC__ServiceMax_Processes__c();
        process1.SVMXC__Name__c = 'process1';
        process1.RecordTypeId=RuleRecordTypeId;
        insert process1;
        woFieldMatchingRules.lstTempWOFieldMatchingRules.add(process1);
        woFieldMatchingRules.getSeqoptions();
        
        woFieldMatchingRules.getstrFieldMatchRuleIdRearrange();
        woFieldMatchingRules.getLabelFromObjName('SVMXC__Service_order__c');
        
        woFieldMatchingRules.setisNewRule(true);
        woFieldMatchingRules.setisRenderRuleSeq(true);
        woFieldMatchingRules.setlsteligibilityMatchConfig(woFieldMatchRulesUT.lsteligibilityMatchConfig);
        //woFieldMatchingRules.setlstTargetSourceAssignConfig(woFieldMatchRulesUT.lstTargetSourceAssignConfig);
        woFieldMatchingRules.setLstTargetSourceMatchWrap(woFieldMatchRulesUT.LstTargetSourceMatchWrap);
        //woFieldMatchingRules.setObject1Optns(woFieldMatchRulesUT.object1Optns);
        //woFieldMatchingRules.setObject2Optns(woFieldMatchRulesUT.object2Optns);
        woFieldMatchingRules.setprocessObjFieldMatchRule(woFieldMatchRulesUT.processObjFieldMatchRule);
        woFieldMatchingRules.setstrFieldMatchRuleIdRearrange(woFieldMatchRulesUT.str);
        
        woFieldMatchRulesUT.lstWOFieldMatchingRules = new List<SVMXC__ServiceMax_Processes__c>();
        woFieldMatchRulesUT.lstWOFieldMatchingRules.clear();
        woFieldMatchingRules.setDefaultValues();
        woFieldMatchingRules.onSelectObject1();
        woFieldMatchingRules.onSelectOrderByField();
    }
    
    static TestMethod void testWrapperClass() {
        
        WSCH_FieldMatchingRules woFldmatchRules = new WSCH_FieldMatchingRules();
        
        WSCH_FieldMatchingRules.TargetSourceMatchConfigWrapper confWrap = new WSCH_FieldMatchingRules.TargetSourceMatchConfigWrapper();
        confWrap.IsRenderpicklist = true;
        confWrap.lstSourceObjField = new List<SelectOption>();
        confWrap.lstTargetObjField = new List<SelectOption>();
        confWrap.Sequence = 1;
        confWrap.targetSourceMatchConfig = new SVMXC__ServiceMax_Config_Data__c();
        
        confWrap.getIsRenderpicklist();
        confWrap.getlstSourceObjField();
        confWrap.getlstTargetObjField();
        confWrap.getSequence();
        confWrap.gettargetSourceMatchConfig();
        
        confWrap.setIsRenderpicklist(confWrap.IsRenderpicklist);
        confWrap.setlstSourceObjField(confWrap.lstSourceObjField);
        confWrap.setlstTargetObjField(confWrap.lstTargetObjField);
        confWrap.setSequence(1);
        confWrap.settargetSourceMatchConfig(confWrap.targetSourceMatchConfig);
        
        //intialize the parameterized constructor
        SVMXC__ServiceMax_Config_Data__c targetSourceMatchConfig = new SVMXC__ServiceMax_Config_Data__c();
        List<selectoption> lstTargetObjField = new List<SelectOption>(); 
        List<selectoption> lstSourceObjField = new List<SelectOption>();
        boolean isPicklist = true;
        Integer iSeq = 1;
        
        WSCH_FieldMatchingRules.TargetSourceMatchConfigWrapper confWrapObj = new WSCH_FieldMatchingRules.TargetSourceMatchConfigWrapper(targetSourceMatchConfig, lstTargetObjField, lstSourceObjField, isPicklist, iSeq);
    }
    
    static TestMethod void testRetrieveMethods() {
        
        WSCH_FieldMatchingRules woFldmatchRules = new WSCH_FieldMatchingRules();
        woFldmatchRules.retrieveRecordTypes();
        woFldmatchRules.retrieveWOFieldMatchRules();
        woFldmatchRules.SVMX_GoSetupHome();
    }
    
    static TestMethod void testPopulateSobjects() {
        
        WSCH_FieldMatchingRules woFldmatchRules = new WSCH_FieldMatchingRules();
        //woFldmatchRules.object1Optns = new List<SelectOption>();
        //woFldmatchRules.object1Optns = new List<SelectOption>();
        woFldmatchRules.populateSObjects();
    }
    
    static TestMethod void testPopulateWOFields() {
        
        WSCH_FieldMatchingRules woFldmatchRules = new WSCH_FieldMatchingRules();
        woFldmatchRules.lstWOfield = new List<SelectOption>();
        woFldmatchRules.populateWorkOrderFields();
    }
    
    static TestMethod void testPopulateSourceObjFields() {
        
        WSCH_FieldMatchingRules woFldmatchRules = new WSCH_FieldMatchingRules();
        woFldmatchRules.lstWOfield = new List<SelectOption>();
        woFldmatchRules.stringSelectObj1 = 'SVMXC__Service_Order__c';
        woFldmatchRules.populateSourceObjFields();
    }
    
    static TestMethod void testPopulateTargetObjFields() {
        
        WSCH_FieldMatchingRules woFldmatchRules = new WSCH_FieldMatchingRules();
        woFldmatchRules.lstWOfield = new List<SelectOption>();
        woFldmatchRules.stringSelectObj2 = 'SVMXC__Service_Order__c';
        woFldmatchRules.populateTargetObjFields();
    }
    
    static TestMethod void testPopulateOperators() {
        
        WSCH_FieldMatchingRules woFldmatchRules = new WSCH_FieldMatchingRules();
        woFldmatchRules.lstOperatorSelectLst = new List<SelectOption>();
        woFldmatchRules.populateOperators();
    }
    
    static TestMethod void testHdrAddRow1() {
        
        WSCH_FieldMatchingRules woFldmatchRules = new WSCH_FieldMatchingRules();
        //no exception case
        woFldmatchRules.lsteligibilityMatchConfig = new List<SVMXC__ServiceMax_Config_Data__c>();
        woFldmatchRules.HdrADDRow1();
        
        //exception case
        woFldmatchRules.lsteligibilityMatchConfig = null;
        woFldmatchRules.HdrADDRow1();
    }
    
    static TestMethod void testHdrAddRow2() {
        
        WSCH_FieldMatchingRules woFldmatchRules = new WSCH_FieldMatchingRules();
        woFldmatchRules.lstTargetObjField = new List<SelectOption>();
        woFldmatchRules.lstSourceObjField = new List<SelectOption>();
        woFldmatchRules.LstTargetSourceMatchWrap = new List<WSCH_FieldMatchingRules.TargetSourceMatchConfigWrapper>();
        
        woFldmatchRules.HdrADDRow2();
        
        WSCH_FieldMatchingRules.TargetSourceMatchConfigWrapper confWrap = new WSCH_FieldMatchingRules.TargetSourceMatchConfigWrapper();
        woFldmatchRules.LstTargetSourceMatchWrap.add(confWrap);
        woFldmatchRules.HdrADDRow2();
        
        woFldmatchRules.LstTargetSourceMatchWrap = null;
        woFldmatchRules.HdrADDRow2();
    }
    
    /*static TestMethod void testHdrAddRow3() {
        
        WSCH_FieldMatchingRules woFldmatchRules = new WSCH_FieldMatchingRules();
        //no exception case
        woFldmatchRules.lstTargetSourceAssignConfig = new List<SVMXC__ServiceMax_Config_Data__c>();
        woFldmatchRules.HdrADDRow3();
        
        //exception case
        woFldmatchRules.lstTargetSourceAssignConfig = null;
        woFldmatchRules.HdrADDRow3();
    }*/
    
    static TestMethod void testHdrDeleteRow1() {
        
        WSCH_FieldMatchingRules woFldmatchRules = new WSCH_FieldMatchingRules();
        woFldmatchRules.StrDelIndex1 = '1';
        woFldmatchRules.lsteligMatchConfigDel = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        woFldmatchRules.lsteligibilityMatchConfig = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c SVMXDEVonfigDataObj = new SVMXC__ServiceMax_Config_Data__c();
        insert SVMXDEVonfigDataObj;
        
        woFldmatchRules.lsteligibilityMatchConfig.add(SVMXDEVonfigDataObj);
        woFldmatchRules.HdrDeleteRow1();
        
        woFldmatchRules.StrDelIndex1 = '1';
        SVMXC__ServiceMax_Config_Data__c SVMXDEVonfigDataObj2 = new SVMXC__ServiceMax_Config_Data__c();
        insert SVMXDEVonfigDataObj2;
        woFldmatchRules.lsteligibilityMatchConfig.clear();
        woFldmatchRules.lsteligibilityMatchConfig.add(SVMXDEVonfigDataObj);
        woFldmatchRules.lsteligibilityMatchConfig.add(SVMXDEVonfigDataObj2);
        woFldmatchRules.HdrDeleteRow1();
    }
    
    static TestMethod void testHdrDeleteRow2() {
        
        WSCH_FieldMatchingRules woFldmatchRules = new WSCH_FieldMatchingRules();
        woFldmatchRules.StrDelIndex2 = '1';
        
        WSCH_FieldMatchingRules.TargetSourceMatchConfigWrapper confWrap = new WSCH_FieldMatchingRules.TargetSourceMatchConfigWrapper();
        woFldmatchRules.LstTargetSourceMatchWrap = new List<WSCH_FieldMatchingRules.TargetSourceMatchConfigWrapper>();
        woFldmatchRules.LstTargetSourceMatchWrap.add(confWrap);
        woFldmatchRules.HdrDeleteRow2();
        
        woFldmatchRules.StrDelIndex2 = '1';
        WSCH_FieldMatchingRules.TargetSourceMatchConfigWrapper confWrap2 = new WSCH_FieldMatchingRules.TargetSourceMatchConfigWrapper();
        confWrap2.targetSourceMatchConfig = new SVMXC__ServiceMax_Config_Data__c();
        confWrap2.targetSourceMatchConfig.SVMXC__Sequence__c = 2;
        confWrap2.Sequence = 1;
        confWrap2.targetSourceMatchConfig = new SVMXC__ServiceMax_Config_Data__c();
        confWrap2.targetSourceMatchConfig.SVMXC__Sequence__c = 2;
        confWrap2.Sequence = 1;
        woFldmatchRules.LstTargetSourceMatchWrap.clear();
        woFldmatchRules.LstTargetSourceMatchWrap.add(confWrap2);
        woFldmatchRules.LstTargetSourceMatchWrap.add(confWrap2);
        woFldmatchRules.HdrDeleteRow2();
    }
    
    /*static TestMethod void testHdrDeleteRow3() {
        
        WSCH_FieldMatchingRules woFldmatchRules = new WSCH_FieldMatchingRules();
        woFldmatchRules.StrDelIndex3 = '1';
        woFldmatchRules.lstTargetSourceAssignConfigDel = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        woFldmatchRules.lstTargetSourceAssignConfig = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c SVMXDEVonfigDataObj = new SVMXC__ServiceMax_Config_Data__c();
        insert SVMXDEVonfigDataObj;
        
        woFldmatchRules.lstTargetSourceAssignConfig.add(SVMXDEVonfigDataObj);
        woFldmatchRules.HdrDeleteRow3();
        
        woFldmatchRules.StrDelIndex3 = '1';
        SVMXC__ServiceMax_Config_Data__c SVMXDEVonfigDataObj2 = new SVMXC__ServiceMax_Config_Data__c();
        insert SVMXDEVonfigDataObj2;
        woFldmatchRules.lstTargetSourceAssignConfig.clear();
        woFldmatchRules.lstTargetSourceAssignConfig.add(SVMXDEVonfigDataObj);
        woFldmatchRules.lstTargetSourceAssignConfig.add(SVMXDEVonfigDataObj2);
        woFldmatchRules.HdrDeleteRow3();
    }*/
    
    static TestMethod void testOnSelectObject2() {
        
        WSCH_FieldMatchingRules woFldmatchRules = new WSCH_FieldMatchingRules();
        woFldmatchRules.stringSelectObj1 = 'SVMXC__Service_Order__c';
        woFldmatchRules.stringSelectObj2 = 'SVMXC__Service_Order__c';
        woFldmatchRules.isNewRule = true;
        
        woFldmatchRules.onSelectObject2();
        
        woFldmatchRules.isNewRule = false;
        woFldmatchRules.onSelectObject2();
        
        woFldmatchRules.stringSelectObj1 = null;
        woFldmatchRules.onSelectObject2();
    }
    
    static TestMethod void testRerenderTextOrPicklist() {
        
        WSCH_FieldMatchingRules woFldmatchRules = new WSCH_FieldMatchingRules();
        woFldmatchRules.StrSelectedIndex = '1';
        woFldmatchRules.lstSourceObjField = new List<selectoption>();
        
        woFldmatchRules.lstWOfield = new List<SelectOption>();
        woFldmatchRules.stringSelectObj1 = 'SVMXC__Service_Order__c';
        
        WSCH_FieldMatchingRules.TargetSourceMatchConfigWrapper confWrap = new WSCH_FieldMatchingRules.TargetSourceMatchConfigWrapper();
        confWrap.IsRenderpicklist = true;
        confWrap.targetSourceMatchConfig = new SVMXC__ServiceMax_Config_Data__c();
        woFldmatchRules.LstTargetSourceMatchWrap = new List<WSCH_FieldMatchingRules.TargetSourceMatchConfigWrapper>();
        woFldmatchRules.LstTargetSourceMatchWrap.add(confWrap);
        woFldmatchRules.RerenderTextOrPicklist();
        
        confWrap.IsRenderpicklist = false;
        woFldmatchRules.LstTargetSourceMatchWrap.clear();
        woFldmatchRules.LstTargetSourceMatchWrap.add(confWrap);
        woFldmatchRules.RerenderTextOrPicklist();
    }
    
    static TestMethod void testDeleteRule() {
    
        String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
            
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts){
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               DispatchProRecordTypeId = rt.ID;
            else if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               ExpressionRTypeId = rt.ID;
            else if(rt.Name == 'SVMX Rule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               RuleRecordTypeId = rt.id;
            else if(rt.Name == 'Field Mapping' &&  rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               FldMapRecordTypeId = rt.id;
            else if(rt.Name == 'Coverage' &&  rt.SobjectType == 'SVMXC__Territory_Coverage__c')
               TCRT = rt.id;
        }
            
        WSCH_FieldMatchingRules woFldmatchRules = new WSCH_FieldMatchingRules();
        woFldmatchRules.processObjFieldMatchRule = new SVMXC__ServiceMax_Processes__c();
        woFldmatchRules.processObjFieldMatchRule.SVMXC__Select__c = true;
        woFldmatchRules.processObjFieldMatchRule.RecordTypeId=RuleRecordTypeId;
        insert woFldmatchRules.processObjFieldMatchRule;
        
        woFldmatchRules.lstWOFieldMatchingRules = new  List<SVMXC__ServiceMax_Processes__c> ();
        woFldmatchRules.lstWOFieldMatchingRules.add(woFldmatchRules.processObjFieldMatchRule);
        
        woFldmatchRules.deleteRule();
    }
    
    static TestMethod void testDeleteNoRuleSelected() {
    
         String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
            
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts){
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               DispatchProRecordTypeId = rt.ID;
            else if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               ExpressionRTypeId = rt.ID;
            else if(rt.Name == 'SVMX Rule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               RuleRecordTypeId = rt.id;
            else if(rt.Name == 'Field Mapping' &&  rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               FldMapRecordTypeId = rt.id;
            else if(rt.Name == 'Coverage' &&  rt.SobjectType == 'SVMXC__Territory_Coverage__c')
               TCRT = rt.id;
        } 
           
        WSCH_FieldMatchingRules woFldmatchRules = new WSCH_FieldMatchingRules();
        woFldmatchRules.processObjFieldMatchRule = new SVMXC__ServiceMax_Processes__c();
        woFldmatchRules.processObjFieldMatchRule.SVMXC__Select__c = false;
        woFldmatchRules.processObjFieldMatchRule.RecordTypeId=RuleRecordTypeId;
        insert woFldmatchRules.processObjFieldMatchRule;
        
        woFldmatchRules.lstWOFieldMatchingRules = new  List<SVMXC__ServiceMax_Processes__c> ();
        woFldmatchRules.lstWOFieldMatchingRules.add(woFldmatchRules.processObjFieldMatchRule);
        
        woFldmatchRules.deleteRule();
    }
    
    static TestMethod void testSaveRule() {
        WSCH_FieldMatchingRules woFldmatchRules = new WSCH_FieldMatchingRules();
        woFldmatchRules.processObjFieldMatchRule = new SVMXC__ServiceMax_Processes__c();
        
        woFldmatchRules.lstWOFieldMatchingRules = new  List<SVMXC__ServiceMax_Processes__c> ();
        
        woFldmatchRules.strAdvanceExp1 = '1 AND 2';
        //woFldmatchRules.strAdvanceExp2 = '1 AND 2';
        woFldmatchRules.stringSelectObj1 = 'SVMXC__Service_order__c';
        woFldmatchRules.stringSelectObj2 = 'Account';
        woFldmatchRules.strProcessName = 'Priority rule 1';
        woFldmatchRules.strDescription = 'This is priority rule';
        woFldmatchRules.isactive = true;
        woFldmatchRules.isNewRule = true;
        woFldmatchRules.IsValidProcess = true;
        
        woFldmatchRules.ExpHdr_Rtype_Id = '';
        woFldmatchRules.ExpDtl_Rtype_Id = '';
        woFldmatchRules.retrieveRecordTypes();
        
        woFldmatchRules.lsteligibilityMatchConfig = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c confData = new SVMXC__ServiceMax_Config_Data__c();
        confData.SVMXC__Operator__c = 'eq';
        confData.SVMXC__Field_Name__c = 'SVMXC__Priority__c';
        confData.SVMXC__Operand__c = 'High';
        woFldmatchRules.lsteligibilityMatchConfig.add(confData);
        
        SVMXC__ServiceMax_Config_Data__c confData2 = new SVMXC__ServiceMax_Config_Data__c();
        confData2.SVMXC__Operator__c = 'eq';
        confData2.SVMXC__Field_Name__c = 'SVMXC__City__c';
        confData2.SVMXC__Operand__c = 'Austin';
        woFldmatchRules.lsteligibilityMatchConfig.add(confData2);
        
        woFldmatchRules.lsteligMatchConfigDel = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        woFldmatchRules.LstTargetSourceMatchWrap = new List<WSCH_FieldMatchingRules.TargetSourceMatchConfigWrapper>();
        
        WSCH_FieldMatchingRules.TargetSourceMatchConfigWrapper confWrapObj = new WSCH_FieldMatchingRules.TargetSourceMatchConfigWrapper();
        confWrapObj.targetSourceMatchConfig = new SVMXC__ServiceMax_Config_Data__c();
        confWrapObj.targetSourceMatchConfig.SVMXC__Target_Field_Name__c = 'AccountNumber';
        confWrapObj.targetSourceMatchConfig.SVMXC__Field_Name__c = 'SVMXC__City__c';
        confWrapObj.targetSourceMatchConfig.SVMXC__Operator__c = 'eq';
        woFldmatchRules.LstTargetSourceMatchWrap.add(confWrapObj);
        
        //woFldmatchRules.lstTargetSourceAssignConfig = new List<SVMXC__ServiceMax_Config_Data__c>();
        //SVMXC__ServiceMax_Config_Data__c targetSourceAssignConf = new SVMXC__ServiceMax_Config_Data__c();
        //targetSourceAssignConf.SVMXC__Target_Field_Name__c = 'AccountNumber';
        //targetSourceAssignConf.SVMXC__Field_Name__c = 'SVMXC__City__c';
        //woFldmatchRules.lstTargetSourceAssignConfig.add(targetSourceAssignConf);
        
        woFldmatchRules.saveRule();
        
        //case when if it is not new rule
        woFldmatchRules.isNewRule = true;
        woFldmatchRules.lsteligibilityMatchConfig = new List<SVMXC__ServiceMax_Config_Data__c>();
        confData = new SVMXC__ServiceMax_Config_Data__c();
        confData.SVMXC__Operator__c = '';
        confData.SVMXC__Field_Name__c = '';
        insert confData;
        confWrapObj.targetSourceMatchConfig.SVMXC__Target_Field_Name__c = '--None--';
        
        woFldmatchRules.lsteligibilityMatchConfig = new List<SVMXC__ServiceMax_Config_Data__c>();
        woFldmatchRules.lsteligibilityMatchConfig.add(confData);
        
        woFldmatchRules.saveRule();
        
        woFldmatchRules.strProcessName = '';
        woFldmatchRules.saveRule();
    }
    
    static TestMethod void testNewRule() {
        
        WSCH_FieldMatchingRules woFldmatchRules = new WSCH_FieldMatchingRules();
        woFldmatchRules.stringSelectObj1 = 'SVMXC__Service_order__c';
        woFldmatchRules.stringSelectObj2 = 'Account';
        
        woFldmatchRules.newWOFieldMatchingRules();
    }
    
    static TestMethod void testCancelRule() {
        
        WSCH_FieldMatchingRules woFldmatchRules = new WSCH_FieldMatchingRules();
        
        SVMXC__ServiceMax_Processes__c woFldMatchRule = new SVMXC__ServiceMax_Processes__c();
        woFldMatchRule.SVMXC__Select__c = true;
        woFldmatchRules.lstWOFieldMatchingRules = new List<SVMXC__ServiceMax_Processes__c>();
        woFldmatchRules.lstWOFieldMatchingRules.add(woFldMatchRule);
        woFldmatchRules.cancelRule();
    }
    
    static TestMethod void testSaveSequence() {
        
        WSCH_FieldMatchingRules woFldmatchRules = new WSCH_FieldMatchingRules();
        SVMXC__ServiceMax_Processes__c woFldMatchRule = new SVMXC__ServiceMax_Processes__c();
        woFldmatchRules.lstWOFieldMatchingRules = new List<SVMXC__ServiceMax_Processes__c>();
        woFldmatchRules.lstWOFieldMatchingRules.add(woFldMatchRule);
        woFldmatchRules.lstTempWOFieldMatchingRules = new List<SVMXC__ServiceMax_Processes__c>();
        
        woFldmatchRules.SVMX_SaveSequence();
    }
    
    static TestMethod void testOrderSequence() {
        
        WSCH_FieldMatchingRules woFldmatchRules = new WSCH_FieldMatchingRules();
        SVMXC__ServiceMax_Processes__c woFldMatchRule = new SVMXC__ServiceMax_Processes__c();
        woFldmatchRules.lstWOFieldMatchingRules = new List<SVMXC__ServiceMax_Processes__c>();
        woFldmatchRules.lstWOFieldMatchingRules.add(woFldMatchRule);
        woFldmatchRules.lstTempWOFieldMatchingRules = new List<SVMXC__ServiceMax_Processes__c>();
        
        woFldmatchRules.SVMX_OrderSequence();
    }
    
    static TestMethod void testUpSequence() {

        String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
            
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts){
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               DispatchProRecordTypeId = rt.ID;
            else if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               ExpressionRTypeId = rt.ID;
            else if(rt.Name == 'SVMX Rule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               RuleRecordTypeId = rt.id;
            else if(rt.Name == 'Field Mapping' &&  rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               FldMapRecordTypeId = rt.id;
            else if(rt.Name == 'Coverage' &&  rt.SobjectType == 'SVMXC__Territory_Coverage__c')
               TCRT = rt.id;
        }           
            
        WSCH_FieldMatchingRules woFldmatchRules = new WSCH_FieldMatchingRules();
        
        SVMXC__ServiceMax_Processes__c woFldMatchRule1 = new SVMXC__ServiceMax_Processes__c();
        woFldMatchRule1.RecordTypeId=RuleRecordTypeId;
        insert woFldMatchRule1;
        
        SVMXC__ServiceMax_Processes__c woFldMatchRule2 = new SVMXC__ServiceMax_Processes__c();
        woFldMatchRule2.RecordTypeId=RuleRecordTypeId;
        insert woFldMatchRule2;
                
         woFldmatchRules.lstWOFieldMatchingRules = new List<SVMXC__ServiceMax_Processes__c>();
        woFldmatchRules.lstWOFieldMatchingRules.add(woFldMatchRule1);
        woFldmatchRules.lstWOFieldMatchingRules.add(woFldMatchRule2);
        
        woFldmatchRules.lstTempWOFieldMatchingRules = new List<SVMXC__ServiceMax_Processes__c>();
        woFldmatchRules.lstTempWOFieldMatchingRules.addAll(woFldmatchRules.lstWOFieldMatchingRules);
        
        woFldmatchRules.strFieldMatchRuleIdRearrange = new List<String>();
        woFldmatchRules.strFieldMatchRuleIdRearrange.add(woFldMatchRule1.Id);
        woFldmatchRules.strFieldMatchRuleIdRearrange.add(woFldMatchRule2.Id);
        woFldmatchRules.selIndex = 0;
        woFldmatchRules.isUpAction = false;
        woFldmatchRules.isDownAction = false;
        woFldmatchRules.isTopAction = false;
        woFldmatchRules.isBottomAction = false;
        
        woFldmatchRules.UP();
    }
    
    static TestMethod void testDownSequence() {
        
       String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
            
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts){
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               DispatchProRecordTypeId = rt.ID;
            else if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               ExpressionRTypeId = rt.ID;
            else if(rt.Name == 'SVMX Rule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               RuleRecordTypeId = rt.id;
            else if(rt.Name == 'Field Mapping' &&  rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               FldMapRecordTypeId = rt.id;
            else if(rt.Name == 'Coverage' &&  rt.SobjectType == 'SVMXC__Territory_Coverage__c')
               TCRT = rt.id;
        }   
                
        WSCH_FieldMatchingRules woFldmatchRules = new WSCH_FieldMatchingRules();
        
        SVMXC__ServiceMax_Processes__c woFldMatchRule1 = new SVMXC__ServiceMax_Processes__c();
        woFldMatchRule1.RecordTypeId = RuleRecordTypeId;
        insert woFldMatchRule1;
        
        SVMXC__ServiceMax_Processes__c woFldMatchRule2 = new SVMXC__ServiceMax_Processes__c();
        woFldMatchRule2.RecordTypeId = RuleRecordTypeId;        
        insert woFldMatchRule2;
        
        woFldmatchRules.lstWOFieldMatchingRules = new List<SVMXC__ServiceMax_Processes__c>();
        woFldmatchRules.lstWOFieldMatchingRules.add(woFldMatchRule1);
        woFldmatchRules.lstWOFieldMatchingRules.add(woFldMatchRule2);
        
        woFldmatchRules.lstTempWOFieldMatchingRules = new List<SVMXC__ServiceMax_Processes__c>();
        woFldmatchRules.lstTempWOFieldMatchingRules.addAll(woFldmatchRules.lstWOFieldMatchingRules);
        
        woFldmatchRules.strFieldMatchRuleIdRearrange = new List<String>();
        woFldmatchRules.strFieldMatchRuleIdRearrange.add(woFldMatchRule1.Id);
        woFldmatchRules.strFieldMatchRuleIdRearrange.add(woFldMatchRule2.Id);
        woFldmatchRules.selIndex = 0;
        woFldmatchRules.isUpAction = false;
        woFldmatchRules.isDownAction = false;
        woFldmatchRules.isTopAction = false;
        woFldmatchRules.isBottomAction = false;
        
        woFldmatchRules.Down();
    }
    
    static TestMethod void testTopSequence() {
        
       String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
            
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts){
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               DispatchProRecordTypeId = rt.ID;
            else if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               ExpressionRTypeId = rt.ID;
            else if(rt.Name == 'SVMX Rule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               RuleRecordTypeId = rt.id;
            else if(rt.Name == 'Field Mapping' &&  rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               FldMapRecordTypeId = rt.id;
            else if(rt.Name == 'Coverage' &&  rt.SobjectType == 'SVMXC__Territory_Coverage__c')
               TCRT = rt.id;
        }   
                
        WSCH_FieldMatchingRules woFldmatchRules = new WSCH_FieldMatchingRules();
        
        SVMXC__ServiceMax_Processes__c woFldMatchRule1 = new SVMXC__ServiceMax_Processes__c();
        woFldMatchRule1.RecordTypeId = RuleRecordTypeId;
        insert woFldMatchRule1;
        
        SVMXC__ServiceMax_Processes__c woFldMatchRule2 = new SVMXC__ServiceMax_Processes__c();
        woFldMatchRule2.RecordTypeId = RuleRecordTypeId;        
        insert woFldMatchRule2;
        
        woFldmatchRules.lstWOFieldMatchingRules = new List<SVMXC__ServiceMax_Processes__c>();
        woFldmatchRules.lstWOFieldMatchingRules.add(woFldMatchRule1);
        woFldmatchRules.lstWOFieldMatchingRules.add(woFldMatchRule2);
        
        woFldmatchRules.lstTempWOFieldMatchingRules = new List<SVMXC__ServiceMax_Processes__c>();
        woFldmatchRules.lstTempWOFieldMatchingRules.addAll(woFldmatchRules.lstWOFieldMatchingRules);
        
        woFldmatchRules.strFieldMatchRuleIdRearrange = new List<String>();
        woFldmatchRules.strFieldMatchRuleIdRearrange.add(woFldMatchRule1.Id);
        woFldmatchRules.strFieldMatchRuleIdRearrange.add(woFldMatchRule2.Id);
        woFldmatchRules.selIndex = 0;
        woFldmatchRules.isUpAction = false;
        woFldmatchRules.isDownAction = false;
        woFldmatchRules.isTopAction = false;
        woFldmatchRules.isBottomAction = false;
        
        woFldmatchRules.Top();
    }
    
    static TestMethod void testBottomSequence() {
        
       String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
            
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts){
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               DispatchProRecordTypeId = rt.ID;
            else if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               ExpressionRTypeId = rt.ID;
            else if(rt.Name == 'SVMX Rule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               RuleRecordTypeId = rt.id;
            else if(rt.Name == 'Field Mapping' &&  rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               FldMapRecordTypeId = rt.id;
            else if(rt.Name == 'Coverage' &&  rt.SobjectType == 'SVMXC__Territory_Coverage__c')
               TCRT = rt.id;
        }   
                
        WSCH_FieldMatchingRules woFldmatchRules = new WSCH_FieldMatchingRules();
        
        SVMXC__ServiceMax_Processes__c woFldMatchRule1 = new SVMXC__ServiceMax_Processes__c();
        woFldMatchRule1.RecordTypeId = RuleRecordTypeId;
        insert woFldMatchRule1;
        
        SVMXC__ServiceMax_Processes__c woFldMatchRule2 = new SVMXC__ServiceMax_Processes__c();
        woFldMatchRule2.RecordTypeId = RuleRecordTypeId;        
        insert woFldMatchRule2;
        
        woFldmatchRules.lstWOFieldMatchingRules = new List<SVMXC__ServiceMax_Processes__c>();
        woFldmatchRules.lstWOFieldMatchingRules.add(woFldMatchRule1);
        woFldmatchRules.lstWOFieldMatchingRules.add(woFldMatchRule2);
        
        woFldmatchRules.lstTempWOFieldMatchingRules = new List<SVMXC__ServiceMax_Processes__c>();
        woFldmatchRules.lstTempWOFieldMatchingRules.addAll(woFldmatchRules.lstWOFieldMatchingRules);
        
        woFldmatchRules.strFieldMatchRuleIdRearrange = new List<String>();
        woFldmatchRules.strFieldMatchRuleIdRearrange.add(woFldMatchRule1.Id);
        woFldmatchRules.strFieldMatchRuleIdRearrange.add(woFldMatchRule2.Id);
        woFldmatchRules.selIndex = 0;
        woFldmatchRules.isUpAction = false;
        woFldmatchRules.isDownAction = false;
        woFldmatchRules.isTopAction = false;
        woFldmatchRules.isBottomAction = false;
        
        woFldmatchRules.Bottom();
    }
    
    static TestMethod void testEditRule() {
        
        WSCH_FieldMatchingRules woFldmatchRules = new WSCH_FieldMatchingRules();
        
        woFldmatchRules.stringSelectObj1 = 'SVMXC__Service_Order__c';
        woFldmatchRules.stringSelectObj2 = 'Account';
        
        woFldmatchRules.lstOperatorSelectLst = new List<SelectOption>();
        woFldmatchRules.lsteligMatchConfigDel = new List<SVMXC__ServiceMax_Config_Data__c>();
        woFldmatchRules.lstOperatorSelectLst = new List<SelectOption>();
        
        SVMXC__ServiceMax_Processes__c processObj = new SVMXC__ServiceMax_Processes__c();
        processObj.SVMXC__Select__c = true;
        
        woFldmatchRules.lstWOFieldMatchingRules = new List<SVMXC__ServiceMax_Processes__c>();
        woFldmatchRules.lstWOFieldMatchingRules.add(processObj);
        
        woFldmatchRules.lsteligibilityMatchConfig = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c confData = new SVMXC__ServiceMax_Config_Data__c();
        confData.SVMXC__Operator__c = 'eq';
        confData.SVMXC__Field_Name__c = 'SVMXC__Priority__c';
        confData.SVMXC__Operand__c = 'High';
        woFldmatchRules.lsteligibilityMatchConfig.add(confData);
        insert woFldmatchRules.lsteligibilityMatchConfig;
        
        woFldmatchRules.LstTargetSourceMatchWrap = new List<WSCH_FieldMatchingRules.TargetSourceMatchConfigWrapper>();
        
        WSCH_FieldMatchingRules.TargetSourceMatchConfigWrapper confWrapObj = new WSCH_FieldMatchingRules.TargetSourceMatchConfigWrapper();
        confWrapObj.targetSourceMatchConfig = new SVMXC__ServiceMax_Config_Data__c();
        confWrapObj.targetSourceMatchConfig.SVMXC__Target_Field_Name__c = 'AccountNumber';
        confWrapObj.targetSourceMatchConfig.SVMXC__Field_Name__c = 'SVMXC__City__c';
        confWrapObj.targetSourceMatchConfig.SVMXC__Operator__c = 'eq';
        insert confWrapObj.targetSourceMatchConfig;
        
        confWrapObj.IsRenderpicklist = false;
        woFldmatchRules.LstTargetSourceMatchWrap.add(confWrapObj);
        
        //woFldmatchRules.lstTargetSourceAssignConfig = new List<SVMXC__ServiceMax_Config_Data__c>();
        //SVMXC__ServiceMax_Config_Data__c targetSourceAssignConf = new SVMXC__ServiceMax_Config_Data__c();
        //targetSourceAssignConf.SVMXC__Target_Field_Name__c = 'AccountNumber';
        //targetSourceAssignConf.SVMXC__Field_Name__c = 'SVMXC__City__c';
        //woFldmatchRules.lstTargetSourceAssignConfig.add(targetSourceAssignConf);
        
        //insert woFldmatchRules.lstTargetSourceAssignConfig;
        
        woFldmatchRules.editRule();
    }
}