@isTest
Private with sharing class CONF_ManageRoutingRules_UT
{
    static testMethod void CONF_ManageRoutingRules_UT_Test()
    {
        List<RecordType> RtypeLst = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='SVMX Rule' ];
    
        SVMXC__ServiceMax_Processes__c processObj = new SVMXC__ServiceMax_Processes__c();
        processObj.RecordTypeId = RtypeLst[0].Id;
        processObj.SVMXC__APL_Route_Rule_Type__c = 'Inbound';
        processObj.SVMXC__Active__c = true;
        processObj.SVMXC__Name__C = 'Routing Rule';
        processObj.SVMXC__Rule_Type__c = 'Routing Rule';
        processObj.SVMXC__ProcessID__c = 'ProcessID001';
        insert processObj;
        
        SVMXC__ServiceMax_Processes__c processObj1 = new SVMXC__ServiceMax_Processes__c();
        processObj1.RecordTypeId = RtypeLst[0].Id;
        processObj1.SVMXC__Select__c = true;
        processObj1.SVMXC__Sequence__c = 2;
        processObj1.SVMXC__APL_Route_Rule_Type__c = 'Outbound';
        processObj1.SVMXC__Active__c = true;
        processObj1.SVMXC__Name__C = 'Routing Rule1';
        processObj1.SVMXC__Advance_Expression__c = '1 AND 2 AND 3';
        processObj1.SVMXC__Description__c = 'Routing Rule1';
        processObj1.SVMXC__Rule_Type__c = 'Routing Rule';
        insert processObj1;
        
        //.......class instantiation and calling various methods.......
        List<SVMXC__ServiceMax_Processes__c> processLst = new List<SVMXC__ServiceMax_Processes__c>();
        processLst.add(processObj);
        processLst.add(processObj1);
        CONF_ManageRoutingRules RuleObj =  new CONF_ManageRoutingRules();
        RuleObj.setIsHdrMsg(true);
        RuleObj.getIsHdrMsg();
        RuleObj.getRulesProcessLst();
        RuleObj.getdisplaySeqPopup();
        RuleObj.getRuleLstSize();
        RuleObj.setRulesProcessLst(processLst);
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
        RuleObj.IsValid();
        RuleObj.SVMXEditRules();
        RuleObj.SVMXCloneRules();
        RuleObj.BackToSetupHome();
        RuleObj.SVMXEditRules();
        RuleObj.SVMXNewRules();
        RuleObj.SVMXdeleteRules();
        RuleObj.SVMX_RuleSequence();
        RuleObj.getSeqoptions();
        string[] items = new String[]{processObj1.Id};
        RuleObj.getitems();
        RuleObj.setitems(items);
        //RuleObj.shuffle(1, false );
        /* RuleObj.shuffle(1, true );
        RuleObj.shuffle(2, false );
        RuleObj.shuffle(2, true ); */
        RuleObj.UP();
        RuleObj.Down();
        RuleObj.Top();
        RuleObj.Bottom();
        RuleObj.SVMX_SaveSequence();
        RuleObj.SVMX_PopupCancel();
    }
    static testMethod void CONF_ManageRoutingRules_UT_Test1()
    {
        List<RecordType> RtypeLst = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='SVMX Rule' ];
        SVMXC__ServiceMax_Processes__c processObj = new SVMXC__ServiceMax_Processes__c();
        processObj.RecordTypeId = RtypeLst[0].Id;
        processObj.SVMXC__APL_Route_Rule_Type__c = 'Inbound';
        processObj.SVMXC__Active__c = true;
    processObj.SVMXC__Select__c = true;
        processObj.SVMXC__Name__C = 'Routing Rule';
        processObj.SVMXC__Rule_Type__c = 'Routing Rule';
        processObj.SVMXC__ProcessID__c = 'ProcessID001';
        insert processObj;
        
        SVMXC__ServiceMax_Processes__c processObj1 = new SVMXC__ServiceMax_Processes__c();
        processObj1.RecordTypeId = RtypeLst[0].Id;
        processObj1.SVMXC__APL_Route_Rule_Type__c = '';
    processObj1.SVMXC__Select__c = true;
        processObj1.SVMXC__Active__c = true;
        processObj1.SVMXC__Name__C = '';
        processObj1.SVMXC__Rule_Type__c = 'Routing Rule';
        insert processObj1;
       
       //.......class instantiation and calling various methods.......
        List<SVMXC__ServiceMax_Processes__c> processLst = new List<SVMXC__ServiceMax_Processes__c>();
        processLst.add(processObj);
        processLst.add(processObj1);
        CONF_ManageRoutingRules RuleObj =  new CONF_ManageRoutingRules();
        RuleObj.IsValid();       
        RuleObj.getRulesProcessLst();
        RuleObj.setRulesProcessLst(processLst);
        RuleObj.SVMXEditRules();
        RuleObj.SVMXCloneRules();
        RuleObj.BackToSetupHome();
        RuleObj.SVMXEditRules();
        RuleObj.SVMXNewRules();
        RuleObj.SVMXdeleteRules();
        RuleObj.SVMX_RuleSequence();
        RuleObj.getSeqoptions();
        string[] items = new String[]{processObj1.Id};
        RuleObj.getitems();
        RuleObj.setitems(items);
        RuleObj.shuffle(1, false );
        RuleObj.shuffle(1, true );
        //RuleObj.shuffle(2, false );
        //RuleObj.shuffle(2, true );
        RuleObj.UP();
        RuleObj.Down();
        RuleObj.Top();
        RuleObj.Bottom();
    RuleObj.SVMX_SaveSequence();
    items = new String[]{processObj.Id};
    RuleObj.getitems();
        RuleObj.setitems(items);
        /* RuleObj.shuffle(2, false );
        RuleObj.shuffle(3, true );
        RuleObj.shuffle(3, false );
        RuleObj.shuffle(2, true ); */
        RuleObj.SVMX_SaveSequence();
        RuleObj.SVMX_PopupCancel();
    }
 }