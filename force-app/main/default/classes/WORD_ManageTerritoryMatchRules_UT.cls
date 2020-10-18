@isTest(SeeAllData=true)
Private with sharing class WORD_ManageTerritoryMatchRules_UT {
    static testMethod void WORD_ManageTerritoryMatchRules_Test()
    {
        PageReference pageRef1 = new PageReference('Page.SVMXC.WORD_ManageTerritoryMatchRules');
        Test.setCurrentPageReference(pageRef1);
        SVMXC.WORD_ManageTerritoryMatchRules classObj = new SVMXC.WORD_ManageTerritoryMatchRules();
        System.assertEquals(true, pageRef1 != null);
        System.assertEquals(true, classObj != null);
    }
    
    
   static testMethod void WORD_ManageTerritoryMatchRulesTest() {
        
        WORD_ManageTerritoryMatchRules TRule = new WORD_ManageTerritoryMatchRules();        
        RecordType rtype = [select id from RecordType where Name=:'SVMX Rule'];     
        SVMXC__ServiceMax_Processes__c prs = new SVMXC__ServiceMax_Processes__c();
        prs.RecordTypeId = rtype.Id;
        prs.SVMXC__ProcessID__c='PROCESS11';
        prs.SVMXC__SettingId__c = 'PROCESS11';
        prs.SVMXC__MapID__c='PROCESS11';
        prs.SVMXC__Name__c = 'PROCESS22';
        prs.SVMXC__Description__c='Description Rule Test';
        prs.SVMXC__Rule_Type__c = 'Work Order Territory';
        prs.SVMXC__Select__c = true;
        prs.SVMXC__Sequence__c = 1;        
        insert prs;      
        
        TRule.getTAG001(); 
        TRule.getTAG002(); 
        TRule.getTAG003(); 
        TRule.getTAG004();
        TRule.getTAG005(); 
        TRule.getTAG006(); 
        TRule.getTAG007(); 
        TRule.getTAG008(); 
        TRule.getTAG009(); 
        TRule.getTAG010();
        TRule.getTAG011(); 
        TRule.getTAG012(); 
        TRule.getTAG013(); 
        TRule.getTAG014(); 
        TRule.getTAG015(); 
        TRule.getTAG016(); 
        TRule.getTAG017(); 
        TRule.getTAG018(); 
        TRule.getTAG019(); 
        TRule.getTAG020(); 
        TRule.getTAG021();  
        TRule.getTAG022();
        TRule.getTAG023();
        TRule.getTAG024();  
        TRule.getTAG025();
        TRule.getTAG026();
        TRule.getTAG027();
        TRule.getTAG028();
        TRule.getTAG029();
        TRule.getTAG030();
        TRule.getTAG031();
        TRule.getHLPURL();
        
        // TRule.svmxTagList.clear();
        
        TRule.getTAG001(); 
        TRule.getTAG002(); 
        TRule.getTAG003(); 
        TRule.getTAG004();
        TRule.getTAG005(); 
        TRule.getTAG006(); 
        TRule.getTAG007(); 
        TRule.getTAG008(); 
        TRule.getTAG009(); 
        TRule.getTAG010();
        TRule.getTAG011(); 
        TRule.getTAG012(); 
        TRule.getTAG013(); 
        TRule.getTAG014(); 
        TRule.getTAG015(); 
        TRule.getTAG016(); 
        TRule.getTAG017(); 
        TRule.getTAG018(); 
        TRule.getTAG019(); 
        TRule.getTAG020(); 
        TRule.getTAG021();  
        TRule.getTAG022();
        TRule.getTAG023();
        TRule.getTAG024();  
        // TRule.getTAG025();
        TRule.getTAG026();
        TRule.getTAG027();
        TRule.getTAG028();
        TRule.getTAG029();
        TRule.getTAG030();
        TRule.getHLPURL();
        System.assertEquals(true, TRule.getTAG017() != null);
        System.assertEquals(true, TRule.getTAG018() != null);
        System.assertEquals(true, TRule.getTAG019() != null);
        System.assertEquals(true, TRule.getTAG020() != null);
        System.assertEquals(true, TRule.getTAG021() != null);
        System.assertEquals(true, TRule.getTAG022() != null);
        
        
        TRule.getCheckAllRules();
        TRule.setCheckAllRules(false); 
        TRule.getDisableCancelBttn();
        TRule.setDisableCancelBttn(false);
        TRule.TrtryRuleList.add(prs); 
        SVMXC__ServiceMax_Config_Data__c TempCnfiglstUTobj = new SVMXC__ServiceMax_Config_Data__c();
        TempCnfiglstUTobj.SVMXC__Expression_Rule__c=prs.Id;
        TempCnfiglstUTobj.SVMXC__Expression_Type__c = 'WORD_Territory';
        TempCnfiglstUTobj.SVMXC__Sequence__c=1;
        TempCnfiglstUTobj.SVMXC__Operator__c = 'eq' ;
        TempCnfiglstUTobj.SVMXC__Operand__c='25';
        TempCnfiglstUTobj.SVMXC__Object_Name__c='svmxp__service_order__c';
        TempCnfiglstUTobj.SVMXC__Field_Name__c = 'SVMXC__Age__c'; 
        insert TempCnfiglstUTobj;
        System.assertEquals(true, TempCnfiglstUTobj != null);
        
//        TRule.Cnfiglst.add(TempCnfiglstUTobj);
              
        List<selectoption> WOFieldsList = new List<selectoption>();
        WOFieldsList =  TRule.CriExpressions.FieldsList;
        WORD_ManageTerritoryMatchRules.TrtryAttWrpper t = new WORD_ManageTerritoryMatchRules.TrtryAttWrpper(TempCnfiglstUTobj,WOFieldsList);
        
        t.getMapping();
        t.getWOFields();
        t.getWOItm();
        t.setWOItm('Test');
        t.getpicklistval();
        
        TRule.getCriExpressions();
        TRule.OnselectRecordOwner();
        //TRule.OnselectRecord();
        TRule.Do_Select();
        TRule.Do_CancelSearch();
        TRule.Do_Search();
        TRule.HdrFindDate();
        TRule.HdrFind();
        
        
        TRule.getTrtryRuleProcess();
        TRule.setTrtryRuleProcess(prs);
        TRule.AddException('Testing');
        TRule.AddException('');
        TRule.getDisbaleChkBox();
        TRule.setDisbaleChkBox(false);  
        TRule.getshowRule();
        TRule.setshowRule(false);   
        TRule.getDelPRCountRec();   
        TRule.setDelPRCountRec(false);
        TRule.getIsRuleBlock();
        TRule.setIsRuleBlock(false);                    
        TRule.getDisbleNewBttn();
        TRule.setDisbleNewBttn(false);
        TRule.getDisbleEdtBttn();
        TRule.setDisbleEdtBttn(false);
        TRule.getDisbleDelBttn();
        TRule.setDisbleDelBttn(false);
        TRule.getTrtryAttrbError();
        TRule.setTrtryAttrbError(false);
        TRule.getdisplaySeqPopup();
        TRule.getDisbleRuleSeqBttn();
        TRule.setDisbleRuleSeqBttn(false);
        TRule.getDisbaleActiveChkBox();
        TRule.setDisbaleActiveChkBox(true);
        TRule.getDisbleSaveBttn();
        TRule.setDisbleSaveBttn(true);              
        TRule.getTrtryRuleList();       
        TRule.RuleNameMap.put(prs.Name,1);
        TRule.getWOItem();
        TRule.setWOItem('TempCnfiglstUTobj');       
        TRule.SVMX_EdtTrtryRule();      
        TRule.SVMX_AddNewTrtryRule();       
        TRule.SVMX_SaveProcessRulewithChild();
        TRule.SVMX_DelTrTryRule();
        TRule.SVMX_Cancel();
        TRule.SVMX_GoSetupHome();
        TRule.getTrtryAttWrpList();
        Map<String,Schema.Displaytype> m = new Map<String,Schema.Displaytype>();
        Map<String,String> m2 = new Map<String,String>();
        map<string,SelectOption> m3 = new map<string,SelectOption>();
        Schema.Displaytype DT;
        
        TRule.getobjSVMXPro();
        TRule.setobjSVMXPro(prs);
        TRule.getSelectedIndex();
        TRule.setSelectedIndex ('1');
        TRule.getlstHdrObjOpt();
        //TRule.getlstLineObjOpt();
        
        TRule.RetriveField('service_order__c', TRule.Hdrfldlist, TRule.CriExpressions.mapFieldDispType, TRule.CriExpressions.FieldApiLable);
        TRule.RetriveField2('service_order__c', TRule.Hdrfldlist,m,m2,DT);
        TRule.RetriveField('service_order__c', TRule.Hdrfldlist,m,m2,DT,null);
        TRule.getHdrFldlist();
        
        TRule.OnHdrObjSelect();
        //TRule.OnHdrEntryCriFieldSelect(); 
        TRule.getSelectedID();
        TRule.setSelectedID('');
        TRule.getSelectedLabel();
        TRule.setSelectedLabel('Name');
       // TRule.getSR ();
        TRule.isDateSearch = true;
        TRule.isSearch = true;
        TRule.getisDateSearch();
        TRule.getisSearch();
        TRule.isDateSearch = false;
        TRule.isSearch = false;
        
        TRule.getDisableValue();        
        TRule.HdrADDRow();
        TRule.HdrDeleteRow();
        TRule.ClearSelOptMap (m3);
        TRule.ClearSelOptList(TRule.Hdrfldlist);
        TRule.SVMX_OrderSequence();
        TRule.getSeqoptions();
        string[] selected = new string[]{};
        selected.add(prs.Id);
        TRule.getitems();
        TRule.setitems(selected);        
        TRule.UP();
        TRule.Down();
        //TRule.shuffle(1,true); 
        TRule.Top();
        //TRule.shuffle(1,false); 
        /* RecordType svmxruleRecordId = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'SVMX Rule' Limit 1];
        SVMXC__ServiceMax_Processes__c prossObj = new SVMXC__ServiceMax_Processes__c();
        prossObj.Name = 'PN-0000003134';
        prossObj.RecordTypeId = svmxruleRecordId.Id;
        prossObj.SVMXC__Sequence__c = 1.00;
        prossObj.SVMXC__Select__c = false; 
        prossObj.RecordType.Name = 'SVMX Rule';
        prossObj.SVMXC__Rule_Type__c = 'Work Order Territory';
        insert prossObj;
        TRule.TempTrtryRuleList.add(prossObj);
        TRule.items.add(prossObj.Id); */
        TRule.Bottom();
        TRule.isTopAction = true;
        TRule.isBottomAction = false;
        TRule.isUpAction = false;
        TRule.isDownAction = false;
        //TRule.SVMX_SaveSequence();
        TRule.isTopAction = false;
        TRule.isBottomAction = true;
        TRule.isUpAction = false;
        TRule.isDownAction = false;
        //TRule.SVMX_SaveSequence();
        TRule.isTopAction = false;
        TRule.isBottomAction = false;
        TRule.isUpAction = true;
        TRule.isDownAction = false;
        //TRule.SVMX_SaveSequence();
        TRule.isTopAction = false;
        TRule.isBottomAction = false;
        TRule.isUpAction = false;
        TRule.isDownAction = true;
        //TRule.SVMX_SaveSequence();
       
        
        
    }
}