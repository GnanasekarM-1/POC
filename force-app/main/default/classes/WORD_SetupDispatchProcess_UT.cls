@isTest(seeAllData = true)
Private class WORD_SetupDispatchProcess_UT 
{
    static testMethod void WORD_SetupDispatchProcessUnitTest() 
    {
        SVMXC.WORD_SetupDispatchProcess obj;
        List<RecordType> RecType = new  List<RecordType>();
        List<RecordType> ConfigRecordTypes = new  List<RecordType>();
        string DispatchRTypeId;
        string RuleRecordTypeId;
        string ExpressionRTypeId;
        RecType = Database.Query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\'');
        system.debug('RecType'+RecType);
        System.assert(RecType != null, 'RecType assertion failed');
        
        for(RecordType Rt : RecType)
        {
            if(Rt.Name == 'Dispatch Process')
            {
                DispatchRTypeId  = Rt.id;
            }
            if(Rt.Name == 'SVMX Rule')
            {
                RuleRecordTypeId = Rt.id;
            }
        }
        ConfigRecordTypes = Database.query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Config_Data__c\'');
        for(RecordType r : ConfigRecordTypes)
        {
            if(r.Name == 'Expressions')
            {
                ExpressionRTypeId = r.id;
            }
        }
        //Create the Territory....
        list<SVMXC__Territory__c> Territorylst = new List<SVMXC__Territory__c>();
        SVMXC__Territory__c Territory1 = new SVMXC__Territory__c();
        Territory1.name = 'india';
        Territorylst.add(Territory1);
        
        SVMXC__Territory__c Territory2 = new SVMXC__Territory__c();
        Territory2.name = 'bangalore';
        Territorylst.add(Territory2);
                
        insert Territorylst;
        //Create the Dispatch Process....
        List<SVMXC__ServiceMax_Processes__c> prcessObjList=new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c prcessObjone=new SVMXC__ServiceMax_Processes__c();
        prcessObjone.RecordTypeId =  DispatchRTypeId;
        prcessObjone.SVMXC__Name__c = 'Test one';
        prcessObjone.SVMXC__Dispatch_Method__c = 'Immediate';
        prcessObjone.SVMXC__Runs_Every_Monday__c = true;
        prcessObjone.SVMXC__Runs_Every_Friday__c = true;
        prcessObjone.SVMXC__Start_Time__c= '11:00 PM';
        prcessObjone.SVMXC__Start_Date__c = system.today();
        prcessObjone.SVMXC__End_Date__c = system.today() + 12;
        prcessObjone.SVMXC__Email_On_Error__c = 'test@servicemax.com';
        prcessObjone.SVMXC__Email_On_Success__c = 'test@servicemax.com';
        prcessObjone.SVMXC__Weight_Time_Window__c = 1;
        prcessObjone.SVMXC__Weight_Total_Distance__c = 1;
        prcessObjone.SVMXC__Weight_Route_Distance__c = 1;
        prcessObjone.SVMXC__Weight_Route_Time__c = 1;
        prcessObjone.SVMXC__Weight_Node_Type__c = 1;
        prcessObjone.SVMXC__Weight_Tech_Eligibility__c = 1;
        prcessObjone.SVMXC__Weight_Skill_Match__c = 1;
        prcessObjone.SVMXC__Weight_Product_Specialization__c = 1;
        prcessObjone.SVMXC__Weight_Preferred_Technician__c = 1;
        prcessObjone.SVMXC__Values__c = Territorylst[0].id + ':U,';
        prcessObjone.Assign_Work_Order_To__c = 'Dispatcher';
        //prcessObjone.Assign_To_Dispatcher__c = userinfo.getUserId();
        prcessObjone.SVMXC__Advance_Expression__c = '1 AND 2';
        //prcessObjList.add(prcessObjone);
        
        SVMXC__ServiceMax_Processes__c prcessObjtwo=new SVMXC__ServiceMax_Processes__c();
        prcessObjtwo.RecordTypeId =  DispatchRTypeId;
        prcessObjtwo.SVMXC__Name__c = 'Test two';
        prcessObjtwo.SVMXC__Dispatch_Method__c = 'Optimized Batch';
        prcessObjtwo.SVMXC__Runs_Every_Monday__c = true;
        prcessObjtwo.SVMXC__Runs_Every_Friday__c = true;
        prcessObjtwo.SVMXC__Start_Time__c= '11:00 PM';
        prcessObjtwo.SVMXC__Start_Date__c = system.today();
        prcessObjtwo.SVMXC__End_Date__c = system.today() + 12;
        prcessObjtwo.SVMXC__Email_On_Error__c = 'test@servicemax.com';
        prcessObjtwo.SVMXC__Email_On_Success__c = 'test@servicemax.com';
        prcessObjtwo.SVMXC__Weight_Time_Window__c = 1;
        prcessObjtwo.SVMXC__Weight_Total_Distance__c = 1;
        prcessObjtwo.SVMXC__Weight_Route_Distance__c = 1;
        prcessObjtwo.SVMXC__Weight_Route_Time__c = 1;
        prcessObjtwo.SVMXC__Weight_Node_Type__c = 1;
        prcessObjtwo.SVMXC__Weight_Tech_Eligibility__c = 1;
        prcessObjtwo.SVMXC__Weight_Skill_Match__c = 1;
        prcessObjtwo.SVMXC__Weight_Product_Specialization__c = 1;
        prcessObjtwo.SVMXC__Weight_Preferred_Technician__c = 1;
        prcessObjtwo.SVMXC__Values__c = Territorylst[0].id + ':U,';
        prcessObjtwo.SVMXC__Advance_Expression__c = '1 AND 2';
        prcessObjtwo.SVMXC__Product_Match_Enabled__c = true;
        prcessObjtwo.SVMXC__Expertise_Match_Enabled__c = true; 
        
        SVMXC__ServiceMax_Processes__c prcessObj3=new SVMXC__ServiceMax_Processes__c();
        prcessObj3.RecordTypeId =  DispatchRTypeId;
        prcessObj3.SVMXC__Name__c = 'Test three';
        prcessObj3.SVMXC__Dispatch_Method__c = 'Linx for ServicePower';
        //prcessObjone.Assign_To_Dispatcher__c = userinfo.getUserId();
        prcessObj3.SVMXC__Advance_Expression__c = '1 AND 2';
        
        SVMXC__ServiceMax_Processes__c prcessObj4 = new SVMXC__ServiceMax_Processes__c();
        prcessObj4.RecordTypeId =  DispatchRTypeId;
        prcessObj4.SVMXC__Name__c = 'Test one';
        prcessObj4.SVMXC__Dispatch_Method__c = 'Long-Term Planner';
        prcessObj4.SVMXC__Start_Time__c= '11:00 AM';
        prcessObj4.SVMXC__Start_Date__c = system.today();
        prcessObj4.SVMXC__End_Date__c = system.today().addDays(12);
        prcessObj4.SVMXC__Email_On_Error__c = 'test@servicemax.com';
        prcessObj4.SVMXC__Email_On_Success__c = 'test@servicemax.com';
        prcessObj4.SVMXC__Weight_Time_Window__c = 1;
        prcessObj4.SVMXC__Weight_Total_Distance__c = 1;
        prcessObj4.SVMXC__Weight_Route_Distance__c = 1;
        prcessObj4.SVMXC__Weight_Route_Time__c = 1;
        prcessObj4.SVMXC__Weight_Node_Type__c = 1;
        prcessObj4.SVMXC__Values__c = Territorylst[0].id + ':U,';
        prcessObj4.SVMXC__Window_Height__c = 10;
        prcessObj4.Frequency__c = Integer.valueOf('10');
        prcessObj4.Calendar_End_Days__c = Integer.valueOf('10');
        prcessObj4.Calendar_Start_Days__c = Integer.valueOf('10');
        prcessObj4.SVMXC__Window_Width__c = Double.valueOf('20');
        prcessObj4.SVMXC__Window_Height__c = Double.valueOf('10');
        prcessObj4.SVMXC__Confirmation_Message__c = 'message';
                
        prcessObjList.add(prcessObjone);        
        prcessObjList.add(prcessObjtwo);
        prcessObjList.add(prcessObj3);
        prcessObjList.add(prcessObj4);

        insert prcessObjList;
        System.assertEquals(false, prcessObjList == null);
        
        List<SVMXC__ServiceMax_Config_Data__c> configLst= new List<SVMXC__ServiceMax_Config_Data__c>(); 
        SVMXC__ServiceMax_Config_Data__c conf1 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId = ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = prcessObjtwo.id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__City__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'Bangalore',
                                            SVMXC__Expression_Type__c = 'DISP_Process_Entry'                                            
                                            );
        configLst.add(conf1);
        SVMXC__ServiceMax_Config_Data__c conf2 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = prcessObjtwo.id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__Source_City__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'werw',
                                            SVMXC__Expression_Type__c = 'DISP_Process_Entry'                                            
                                            );
        configLst.add(conf2);
        SVMXC__ServiceMax_Config_Data__c confCont1 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId = ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = prcessObj3.id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__City__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'Bangalore',
                                            SVMXC__Expression_Type__c = 'DISP_Process_Entry'                                            
                                            );
        configLst.add(confCont1);
        SVMXC__ServiceMax_Config_Data__c confCont2 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = prcessObj3.id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__Source_City__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'werw',
                                            SVMXC__Expression_Type__c = 'DISP_Process_Entry'                                            
                                            );
        configLst.add(confCont2);                       
           
        //Create Assignment Rule...
        List<SVMXC__ServiceMax_Processes__c>  RuleLst = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Processes__c>  DelRuleLst = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c  ARule1 = new SVMXC__ServiceMax_Processes__c();
        ARule1.RecordTypeId = RuleRecordTypeId;
        ARule1.SVMXC__Rule_Type__c = 'Simple Assignment';
        ARule1.SVMXC__Process__c = prcessObjone.id; 
        ARule1.SVMXC__Sequence__c = 1;
        ARule1.SVMXC__Select__c = true;
        ARule1.SVMXC__ProcessID__c='PROCESS11';
        ARule1.SVMXC__SettingId__c = 'PROCESS11';
        ARule1.SVMXC__MapID__c='PROCESS11';
        ARule1.SVMXC__Name__c = 'PROCESS22';
        RuleLst.add(ARule1);
        DelRuleLst.add(ARule1);
        SVMXC__ServiceMax_Processes__c  ARule2 = new SVMXC__ServiceMax_Processes__c();
        ARule2.RecordTypeId = RuleRecordTypeId;
        ARule2.SVMXC__Rule_Type__c = 'Simple Assignment';
        ARule2.SVMXC__Process__c = prcessObjone.id; 
        ARule2.SVMXC__Select__c = false;
        ARule2.SVMXC__Sequence__c = 2;
        ARule2.Assign_Work_Order_To__c = 'Dispatcher';
        ARule2.SVMXC__ProcessID__c='PROCESS11';
        ARule2.SVMXC__SettingId__c = 'PROCESS11';
        ARule2.SVMXC__MapID__c='PROCESS11';
        ARule2.SVMXC__Name__c = 'PROCESS22';
        RuleLst.add(ARule2);
        DelRuleLst.add(ARule2);
        SVMXC__ServiceMax_Processes__c  ARule3 = new SVMXC__ServiceMax_Processes__c();
        ARule3.RecordTypeId = RuleRecordTypeId;
        ARule3.SVMXC__Rule_Type__c = 'Simple Assignment';
        ARule3.SVMXC__Process__c = prcessObjone.id; 
        ARule3.SVMXC__Select__c = true;
        ARule3.SVMXC__Sequence__c = 3;
        ARule3.Assign_Work_Order_To__c = 'Dispatcher';
        ARule3.SVMXC__ProcessID__c='PROCESS11';
        ARule3.SVMXC__SettingId__c = 'PROCESS11';
        ARule3.SVMXC__MapID__c='PROCESS11';
        ARule3.SVMXC__Name__c = 'PROCESS22';
        RuleLst.add(ARule3);
        //Create Priority Rule 
        
        SVMXC__ServiceMax_Processes__c  PRule1 = new SVMXC__ServiceMax_Processes__c();
        PRule1.RecordTypeId = RuleRecordTypeId;
        PRule1.SVMXC__Rule_Type__c = 'Priortization';
        PRule1.SVMXC__Process__c = prcessObjtwo.id; 
        PRule1.SVMXC__Sequence__c = 4;
        PRule1.SVMXC__ProcessID__c='PROCESS11';
        PRule1.SVMXC__SettingId__c = 'PROCESS11';
        PRule1.SVMXC__MapID__c='PROCESS11';
        PRule1.SVMXC__Name__c = 'PROCESS22';
        PRule1.SVMXC__Select__c = true;
        RuleLst.add(PRule1);
        SVMXC__ServiceMax_Processes__c  PRule2 = new SVMXC__ServiceMax_Processes__c();
        PRule2.RecordTypeId = RuleRecordTypeId;
        PRule2.SVMXC__Rule_Type__c = 'Priortization';
        PRule2.SVMXC__Process__c = prcessObjtwo.id; 
        PRule2.SVMXC__Sequence__c = 3;
        PRule2.SVMXC__ProcessID__c='PROCESS11';
        PRule2.SVMXC__SettingId__c = 'PROCESS11';
        PRule2.SVMXC__MapID__c='PROCESS11';
        PRule2.SVMXC__Name__c = 'PROCESS22';
        RuleLst.add(PRule2);
        SVMXC__ServiceMax_Processes__c  PRule3 = new SVMXC__ServiceMax_Processes__c();
        PRule3.RecordTypeId = RuleRecordTypeId;
        PRule3.SVMXC__Rule_Type__c = 'Priortization';
        PRule3.SVMXC__Process__c = prcessObjtwo.id; 
        PRule3.SVMXC__Sequence__c = 2;
        PRule3.SVMXC__ProcessID__c='PROCESS11';
        PRule3.SVMXC__SettingId__c = 'PROCESS11';
        PRule3.SVMXC__MapID__c='PROCESS11';
        PRule3.SVMXC__Name__c = 'PROCESS22';
        RuleLst.add(PRule3);
        SVMXC__ServiceMax_Processes__c  PRule4 = new SVMXC__ServiceMax_Processes__c();
        PRule4.RecordTypeId = RuleRecordTypeId;
        PRule4.SVMXC__Rule_Type__c = 'Priortization';
        PRule4.SVMXC__Process__c = prcessObjtwo.id; 
        PRule4.SVMXC__Sequence__c = 1;
        PRule4.SVMXC__ProcessID__c='PROCESS11';
        PRule4.SVMXC__SettingId__c = 'PROCESS11';
        PRule4.SVMXC__MapID__c='PROCESS11';
        PRule4.SVMXC__Name__c = 'PROCESS22';
        RuleLst.add(PRule4);
        
        ////Create the Territory  for AdvanceDispatch....  
        
        SVMXC__ServiceMax_Processes__c  TRule1 = new SVMXC__ServiceMax_Processes__c();
        TRule1.RecordTypeId = RuleRecordTypeId;
        TRule1.SVMXC__Territory__c = Territorylst[0].id;
        TRule1.SVMXC__Rule_Type__c = 'Territory Access';
        TRule1.SVMXC__Process__c = prcessObjtwo.id; 
        TRule1.SVMXC__ProcessID__c='PROCESS11';
        TRule1.SVMXC__SettingId__c = 'PROCESS11';
        TRule1.SVMXC__MapID__c='PROCESS11';
        TRule1.SVMXC__Name__c = 'PROCESS22';
        RuleLst.add(TRule1);
        
        SVMXC__ServiceMax_Processes__c  TRule2 = new SVMXC__ServiceMax_Processes__c();
        TRule2.RecordTypeId = RuleRecordTypeId;
        TRule2.SVMXC__Territory__c = Territorylst[1].id;
        TRule2.SVMXC__Rule_Type__c = 'Territory Access';
        TRule2.SVMXC__Process__c = prcessObjtwo.id; 
        TRule2.SVMXC__ProcessID__c='PROCESS11';
        TRule2.SVMXC__SettingId__c = 'PROCESS11';
        TRule2.SVMXC__MapID__c='PROCESS11';
        TRule2.SVMXC__Name__c = 'PROCESS22';
        TRule2.SVMXC__Select__c = true;
        RuleLst.add(TRule2);
        
        insert RuleLst;
        System.assertNotEquals(true, RuleLst == null);
        
        //Create config data for Assignmment rule 
        SVMXC__ServiceMax_Config_Data__c conf3 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = ARule1.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__City__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'Bangalore',
                                            SVMXC__Expression_Type__c = 'DISP_Simple_Assignment'                                            
                                            );
        configLst.add(conf3);
        SVMXC__ServiceMax_Config_Data__c conf4 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = ARule2.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__City__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'pune',
                                            SVMXC__Expression_Type__c = 'DISP_Simple_Assignment'                                            
                                            );
         configLst.add(conf4);                                    
         //Create config data for Priortization rule 
        SVMXC__ServiceMax_Config_Data__c conf5 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = PRule1.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__City__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'Bangalore',
                                            SVMXC__Expression_Type__c = 'DISP_Priortization'                                            
                                            );
        configLst.add(conf5);
        SVMXC__ServiceMax_Config_Data__c conf6 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = PRule1.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__City__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'pune',
                                            SVMXC__Expression_Type__c = 'DISP_Priortization'                                            
                                            );
        configLst.add(conf6);  
        
        insert configLst;
        
        test.startTest();
        PageReference pageRef = Page.WORD_SetupDispatchProcess;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('dpeid', prcessObjone.id);
        
        obj = new SVMXC.WORD_SetupDispatchProcess();
        
        
        //obj.ValidateScheduleRuns();
        //WORD_SetupDispatch_Methods DM = new WORD_SetupDispatch_Methods();
        List<String> s1 = new List<String>();
        String str = '';
        obj.getitems();
        obj.setitems(s1);
        obj.getIsNew();
        Boolean b;
        obj.setIsNew(b);
        obj.getDontProcess();
        obj.setDontProcess(b);
        obj.ValidateDispatchMethod();
        obj.getCloneMode();
        obj.ValidDPAssignTo();
        obj.getdelIndex();
        obj.setdelIndex(str);
        obj.SVMX_IsValidID(prcessObjList[0].id);
        obj.getprocessobj();
        obj.setprocessobj(prcessObjone);
        obj.getDPCriExpressions();
        obj.DPCriDeleteRow();
        obj.DPCriADDRow();
        ////obj.SVMX_DispatchProcess();
        obj.SVMX_AssignmentRules();
        obj.getRuleLst();
        obj.getRuleCriExpressions();
        obj.RuleCriADDRow();
        obj.RuleCriDeleteRow();
        //obj.getruleobj();
        //obj.getSeqoptions();
        //obj.getAssignmentRulesTab();
       // obj.getCalOptions();
        obj.getCostParametersTab();
        obj.getdelIndex();
        obj.getdisableValue();
        obj.getDisbaleChkBox();
        obj.getDisbalePriChkBox();
        obj.getDisbleCancleBttn();
        obj.getDisbalePriChkBox();
        obj.getDisbleCancleBttn();
        obj.getDisbleDelBttn();
        obj.getDisbleEditBttn();
        obj.getDisbleNewBttn();
        obj.getDisbleRSeqBttn();
        obj.getDisbleSaveBttn();
        //obj.getDispatchProcess();
        obj.getdisplaySeqPopup();
        obj.getDispMethods();
        //obj.getDistanceTypeToConsider();
        obj.getDPCriExpressions();
        //obj.getFinalException();
        obj.getHdrMsg();
        //obj.getlst();
        obj.getOptions();
        obj.getPreferencesTab();
        obj.getPrioritizationTab();
        obj.getPriorityBlkSec();
        obj.getPriorityCancelBtn();
        obj.getPriorityCriExpressions();
        obj.getPriorityEditBtn();
        obj.getPrioritySaveBtn();
        obj.getPriortization();
        obj.getPriorityBlkSec();
        obj.getPriorityCancelBtn();
        obj.getPriorityCriExpressions();
        obj.getPriorityEditBtn();
        obj.getPrioritySaveBtn();
        obj.getPriortization();
        obj.getRouteNatureToConsider();
        obj.getRuleBlockSection();
        obj.getSchedulingTab();
        obj.getselectedTab();
        obj.getSeqoptions();
        obj.getTab2Msg();
        obj.getTab3Msg();
        obj.getTab4Msg();
        obj.getOrignalTerritory();
        obj.getTab3Msg2();
        obj.getTerritoryRecLst();
        obj.getPanelMsg();
        obj.SVMX_AddTerritory();
        obj.SVMX_GO();
        obj.SVMX_AddSelected();
        obj.getSaveCloseRulesBtn();
        obj.getNewMode();
        obj.getEditMode();  
        obj.getTerritoriesTab();
        //obj.getSelTerritory();
        //obj.getToptions();
        //obj.getTTId();
        obj.getWOQueue();
        obj.SVMX_RuleSequence();
        obj.shuffle(1,true);
        obj.shuffle(1,false);
        obj.Top();
        obj.UP();
        obj.Bottom();
        obj.Down();
        //delete  DelRuleLst;
        obj.shuffle(1,false);
        obj.Top();
        obj.UP();
        obj.Bottom();
        obj.Down();
        //obj.setDispMethods(DM);
       
       // obj.setFinalException(prcessObjtwo);
       // obj.setlst(str);
        obj.setPriortization(prcessObjList);
        obj.setprocessobj(prcessObjtwo);
        obj.setRuleLst(RuleLst);
        ARule1.SVMXC__Select__c = true;
        ARule2.SVMXC__Select__c = true;
        ARule3.SVMXC__Select__c = true;     
        obj.setruleobj(ARule1);
        obj.setselectedTab(str);
        obj.SVMX_CanclePriortization();
        obj.SVMX_CostParameters();
        obj.SVMX_DispatchPreferences();
        ////obj.SVMX_DispatchProcess();
        obj.SVMX_EditPriortization();
        //obj.SVMX_getPickListValues('SVMXC__Route_Type__c');
        obj.SVMX_Prioritization();
        //obj.SVMX_SavePrioritization();
        //obj.SVMX_EditPrioritization();
        obj.strCapacityThreshold = '20';
        obj.strProcessName = 'testProcess';
        obj.SVMX_CapacityLimitations();
        obj.SVMX_AddRuleCapacityLimitations();
        obj.SVMX_EditCapacityLimitations();
        obj.SVMX_SaveCapacityLimitations();
        obj.SVMX_CancleCapacityLimitations();
        obj.SVMX_DeleteCapacityLimitations();
        obj.SVMX_RuleSequence();
        obj.SVMX_SaveSequence();
        obj.SVMX_Scheduling();
        obj.SVMX_Scheduling();
        obj.SVMX_Territories();
        obj.SVMX_ValidAdvanceProcess();
        obj.SVMX_ProcessDefination();
        //obj.SVMX_NewRule();
        //obj.SVMX_ValidateARule();
        //obj.SVMX_EditRule();
        obj.SVMX_BackToDP();
        obj.SVMX_PopupCancel();
        obj.SVMX_ValidDP();
        //obj.SVMX_ValidAR();
        //obj.SVMX_ValidPR(); 
        obj.SVMX_ValidAdvanceProcess();
        obj.SVMX_SaveDP();
        obj.getWeightEligibility();
        obj.setWeightEligibility(1);
        obj.getWeightExpertise();
        obj.setWeightExpertise(1);
        obj.getWeightProductSpecilaization();
        obj.setWeightProductSpecilaization(1);
        obj.getWeightPreferredTech();
        obj.setWeightPreferredTech(1);
        SVMXC__ServiceMax_Processes__c  ARule4 = new SVMXC__ServiceMax_Processes__c(SVMXC__Select__c = true);
        ARule4.Assign_Work_Order_To__c = 'Dispatcher';
        ARule4.Assign_To_Dispatcher__c = userinfo.getUserId();
        obj.RuleLst.clear();
        obj.RuleLst.add(ARule4);
        obj.SVMX_ValidAR();
        obj.SVMX_SaveRules();
        obj.isUpAction = true;
        obj.SVMX_SaveSequence();
        obj.isUpAction = false;
        obj.isDownAction = true;
        obj.SVMX_SaveSequence();
        obj.isUpAction = false;
        obj.isDownAction = false;
        obj.isTopAction = true;
        obj.SVMX_SaveSequence();
        obj.isUpAction = false;
        obj.isDownAction = false;
        obj.isTopAction = false;
        obj.isBottomAction = true;
        obj.SVMX_SaveSequence();
        obj.Down();
        obj.UP();
        obj.SVMX_SaveCloseRules();
        //obj.SVMX_SavePriortization(); 
        PRule1.SVMXC__Select__c = false;
        obj.SVMX_FinalSave();
        obj.SVMX_SaveLTP();
        prcessObjone.SVMXC__Name__c = '';
        prcessObjone.SVMXC__Dispatch_Method__c = '';
        obj.SVMX_ValidDP();
        prcessObjone.SVMXC__Dispatch_Method__c = 'Optimized Batch';
        obj.SVMX_AssignmentRules();
        map<String,SelectOption> mp  = new map<String,SelectOption>(); 
        obj.ClearSelOptMap(mp);
        obj.getHdrFldlist();
        list<SelectOption> lst = new list<SelectOption>(); 
        obj.ClearSelOptList(lst);
        ARule1.SVMXC__Select__c = true;
        ARule2.SVMXC__Select__c = true;
        ARule3.SVMXC__Select__c = true;
        obj.SVMX_DeleteRule();
        obj.SVMX_DeleteTerritory();
        obj.getProductExpertise();
        obj.setProductExpertise('Skill');
        obj.ChangeSliders();
        WORD_SetupDispatchProcess.RunInformation runInfo = new WORD_SetupDispatchProcess.RunInformation(true,'Full','3:00 AM', true);
        runInfo.getIsSelected();
        runInfo.getRunType();
        runInfo.getRunAt();
        WORD_SetupDispatchProcess.RunInformation runInfo1 = new WORD_SetupDispatchProcess.RunInformation();
        runInfo1.setIsSelected(false);
        runInfo1.setRunType('Incremental');
        runInfo1.setRunAt('1:00 AM');
        //obj.calculateScheduleIntervals('1:00 PM', '5:00 PM',1);
        obj.SelectedStartTime = '1:00 PM';
        obj.SelectedEndTime = '5:00 PM';
        obj.SelectedFrequency = '2';
        obj.Disp_Schedule.add(runInfo);
        obj.Disp_Schedule.add(runInfo1); 
        obj.ValidateScheduleRuns();
       
        
        obj.SVMX_addScheduleRun();        
        obj.SVMX_addScheduleRuns();
        obj.DeleteRunInformation();
        obj.getIncrementRunExpressions();
        obj.IncreExpresCriADDRow();
        obj.IncreExpresCriDeleteRow();
        obj.getmsgFreqGr1();
        
        ApexPages.currentPage().getParameters().put('dpeid', prcessObjtwo.id);
        ApexPages.currentPage().getParameters().put('sMode', 'clone');
               
        obj = new SVMXC.WORD_SetupDispatchProcess();
        obj.setWeightTimeWindow(1);
        obj.getWeightTimeWindow();
        obj.setWeightTotalDistance(1);
        obj.getWeightTotalDistance();
        obj.setWeightRouteDistance(1);
        obj.getWeightRouteDistance();
        obj.setWeightRouteTime(1);
        obj.getWeightRouteTime();
        obj.setWeightNodeType(1);
        obj.getWeightNodeType();
        obj.getDisableTabs();
        obj.setRuleLst(RuleLst);
        prcessObjtwo.SVMXC__Frequency__c = 2;
        prcessObjtwo.SVMXC__Full_Run_Unit__c = 'Days';
        obj.Disp_Schedule.add(runInfo);
        obj.Disp_Schedule.add(runInfo1);
        obj.SVMX_FinalSave();
        obj.SVMX_EditRule();
        obj.SVMX_enableQuickAddPopup();
        obj.setDispMethods(new WORD_SetupDispatch_Methods());
        obj.AssignWOto();
        obj.getmsgDeleteRunInfo();
        obj.getSearchKeyword();
        obj.setSearchKeyword(null);
        obj.PriorityCriADDRow();
        obj.PriorityCriDeleteRow();
        obj.getProductExpertiseOpt();
        WORD_SetupDispatchProcess.RunInformation runInfo3 = new WORD_SetupDispatchProcess.RunInformation();
        runInfo3.setIsSelected(false);
        runInfo3.setRunType('Incremental');
        runInfo3.setRunAt('5:00 AM');
        obj.Disp_Schedule.add(runInfo3); 
        obj.ValidateScheduleRuns();
        WORD_SetupDispatchProcess.RunInformation runInfo2 = new WORD_SetupDispatchProcess.RunInformation();
        runInfo2.setIsSelected(false);
        runInfo2.setRunType('Incremental');
        runInfo2.setRunAt('1:00 AM');
        obj.Disp_Schedule.add(runInfo2); 
        obj.ValidateScheduleRuns();
        //obj.SVMX_SaveDP();
        SVMXC__ServiceMax_Processes__c prior1=new SVMXC__ServiceMax_Processes__c();
        prior1.RecordTypeId =  DispatchRTypeId;
        prior1.SVMXC__ProcessID__c='PROCESS11';
        prior1.SVMXC__SettingId__c = 'PROCESS11';
        prior1.SVMXC__MapID__c='PROCESS11';
        prior1.SVMXC__Name__c = 'PROCESS22';
        SVMXC__ServiceMax_Processes__c prior2=new SVMXC__ServiceMax_Processes__c();
        prior2.RecordTypeId =  DispatchRTypeId; 
        prior2.SVMXC__ProcessID__c='PROCESS11';
        prior2.SVMXC__SettingId__c = 'PROCESS11';
        prior2.SVMXC__MapID__c='PROCESS11';
        prior2.SVMXC__Name__c = 'PROCESS22';        
        List<SVMXC__ServiceMax_Processes__c> prior = new List<SVMXC__ServiceMax_Processes__c>();
        prior.add(prior1);
        prior.add(prior2);
        obj.SVMX_IsValidID(prior1.id);
        insert prior;
        obj.setPriortization(prior);
        obj.SVMX_BackToDP();
        obj.ValidDPAssignTo();
        obj.SVMX_DeleteRule();
        obj.SVMX_cancleASRule();
        obj.SVMX_SaveDP();
        ApexPages.currentPage().getParameters().put('dpeid', prior1.id);
        obj = new SVMXC.WORD_SetupDispatchProcess();   
        ApexPages.currentPage().getParameters().put('dpeid', '');
        obj = new SVMXC.WORD_SetupDispatchProcess();   
        obj.getlstSOAssignWOTo();   
        obj.getAssignmentRulesTab();   
        obj.getruleobj();   
        obj.SVMX_NewRule(); 
        //Linx for ServicePower
        //ApexPages.currentPage().getParameters().put('dpeid', prcessObj3.id);
        //obj = new SVMXC.WORD_SetupDispatchProcess();
        List<String> s2 = new List<String>();
        String str1 = '';
        obj.getitems();
        obj.setitems(s2);
        obj.getIsNew();
        Boolean b1;
        obj.setIsNew(b1);
        obj.getDontProcess();
        obj.setDontProcess(b1);
        obj.ValidateDispatchMethod();
        obj.ValidDPAssignTo();
        obj.getdelIndex();
        obj.setdelIndex(str1);
        obj.SVMX_IsValidID(prcessObjList[2].id);
        obj.getprocessobj();
        obj.setprocessobj(prcessObj3);
        obj.getDPCriExpressions();
        obj.DPCriDeleteRow();
        obj.DPCriADDRow();
        obj.getSaveCloseDPBtn();
        obj.getNextDPBtn();
        obj.SVMX_SaveContinuousDP();
        obj.SVMX_AssignmentRules();
        obj.getDispatchMethod();

        Boolean SaveCloseDPBtn=false;
        Boolean NextDPBtn=false;
        obj.getDispatchMethod();
        
       // obj.SVMX_ValidAdvanceProcess();

        test.stopTest();
    }
    
    static testMethod void WORD_SetupDispatchProcessUnitTest2()
    {
        SVMXC.WORD_SetupDispatchProcess obj;
        List<RecordType> RecType = new  List<RecordType>();
        List<RecordType> ConfigRecordTypes = new  List<RecordType>();
        string DispatchRTypeId;
        string RuleRecordTypeId;
        string ExpressionRTypeId;
        RecType = Database.Query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\'');
        system.debug('RecType'+RecType);
        System.assert(RecType != null, 'RecType assertion failed');
        
        for(RecordType Rt : RecType)
        {
            if(Rt.Name == 'Dispatch Process')
            {
                DispatchRTypeId  = Rt.id;
            }
            if(Rt.Name == 'SVMX Rule')
            {
                RuleRecordTypeId = Rt.id;
            }
        }
        
        ConfigRecordTypes = Database.query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Config_Data__c\'');
        for(RecordType r : ConfigRecordTypes)
        {
            if(r.Name == 'Expressions')
            {
                ExpressionRTypeId = r.id;
            }
        }
        
        //Create the Territory....
        list<SVMXC__Territory__c> Territorylst = new List<SVMXC__Territory__c>();
        SVMXC__Territory__c Territory1 = new SVMXC__Territory__c();
        Territory1.name = 'india';
        Territorylst.add(Territory1);
        insert Territorylst;
        
        List<SVMXC__ServiceMax_Processes__c> prcessObjList=new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c prcessObj4=new SVMXC__ServiceMax_Processes__c();
        prcessObj4.RecordTypeId =  DispatchRTypeId;
        prcessObj4.SVMXC__Name__c = 'Test Four';
        prcessObj4.SVMXC__Dispatch_Method__c = 'Real Time Optimization';
        prcessObj4.SVMXC__Email_On_Error__c = 'test@servicemax.com';
        prcessObj4.SVMXC__Email_On_Success__c = 'test@servicemax.com';
        prcessObj4.SVMXC__Weight_Time_Window__c = 1;
        prcessObj4.SVMXC__Weight_Total_Distance__c = 1;
        prcessObj4.SVMXC__Weight_Route_Distance__c = 1;
        prcessObj4.SVMXC__Weight_Route_Time__c = 1;
        prcessObj4.SVMXC__Weight_Node_Type__c = 1;
        prcessObj4.SVMXC__Weight_Tech_Eligibility__c = 1;
        prcessObj4.SVMXC__Weight_Skill_Match__c = 1;
        prcessObj4.SVMXC__Weight_Product_Specialization__c = 1;
        prcessObj4.SVMXC__Weight_Preferred_Technician__c = 1;
        prcessObj4.SVMXC__Values__c = Territorylst[0].id + ':U,';
        prcessObj4.SVMXC__Advance_Expression__c = '1 AND 2';
        prcessObj4.SVMXC__Product_Match_Enabled__c = true;
        prcessObj4.SVMXC__Expertise_Match_Enabled__c = true;
        
        prcessObjList.add(prcessObj4);
        insert prcessObjList;
        
        List<SVMXC__ServiceMax_Config_Data__c> configLst= new List<SVMXC__ServiceMax_Config_Data__c>(); 
        SVMXC__ServiceMax_Config_Data__c confForObj4 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = prcessObj4.id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__Source_City__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'werw',
                                            SVMXC__Expression_Type__c = 'DISP_Process_Entry'                                            
                                            );
        configLst.add(confForObj4);
        insert configLst;        
        
        List<SVMXC__ServiceMax_Processes__c>  RuleLst = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c  PRule5 = new SVMXC__ServiceMax_Processes__c();
        PRule5.RecordTypeId = RuleRecordTypeId;
        PRule5.SVMXC__Rule_Type__c = 'Priortization';
        PRule5.SVMXC__Process__c = prcessObj4.id; 
        PRule5.SVMXC__Sequence__c = 5;
        PRule5.SVMXC__ProcessID__c ='PROCESS11';
        PRule5.SVMXC__SettingId__c = 'PROCESS11';
        PRule5.SVMXC__MapID__c = 'PROCESS11';
        PRule5.SVMXC__Name__c = 'PROCESS22';
        RuleLst.add(PRule5);
        
        SVMXC__ServiceMax_Processes__c  TRule3 = new SVMXC__ServiceMax_Processes__c();
        TRule3.RecordTypeId = RuleRecordTypeId;
        TRule3.SVMXC__Territory__c = Territorylst[0].id;
        TRule3.SVMXC__Rule_Type__c = 'Territory Access';
        TRule3.SVMXC__Process__c = prcessObj4.id; 
        TRule3.SVMXC__ProcessID__c = 'PROCESS11';
        TRule3.SVMXC__SettingId__c = 'PROCESS11';
        TRule3.SVMXC__MapID__c = 'PROCESS11';
        TRule3.SVMXC__Name__c = 'PROCESS22';
        TRule3.SVMXC__Select__c = true;
        RuleLst.add(TRule3);
        insert RuleLst;
        
        test.startTest();
        PageReference pageRef = Page.WORD_SetupDispatchProcess;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('dpeid', prcessObj4.id);
        
        obj = new SVMXC.WORD_SetupDispatchProcess();
        obj.setIsNew(true);
        obj.SVMX_AssignmentRules();
        obj.getECOSchedulingTab();
        obj.setRuleLst(RuleLst);
        obj.SVMX_ValidAdvanceProcess();
        obj.SVMX_SaveDP();
        obj.SVMX_Scheduling();
        obj.SVMX_ECOFinalSave();  
        
        test.stopTest();
    }
    
    static testMethod void WORD_SetupDispatchProcessUnitTest3()
    {
        List<RecordType> RecType = new  List<RecordType>();
        List<RecordType> ConfigRecordTypes = new  List<RecordType>();
        string DispatchRTypeId;
        RecType = Database.Query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\'');
        for(RecordType Rt : RecType)
        {
            if(Rt.Name == 'Dispatch Process')
            {
                DispatchRTypeId  = Rt.id;
            }
        }
        
        List<SVMXC__ServiceMax_Processes__c> prcessObjList = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c prcessObj2 = new SVMXC__ServiceMax_Processes__c();
        prcessObj2.SVMXC__Name__c = 'OptimaxECO_DP_Test';
        prcessObj2.RecordTypeId = DispatchRTypeId;
        prcessObj2.SVMXC__Dispatch_Method__c = 'Real Time Optimization';
        prcessObj2.SVMXC__Email_On_Error__c = 'test@servicemax.com';
        prcessObj2.SVMXC__Email_On_Success__c = 'test@servicemax.com';
        prcessObj2.SVMXC__Weight_Time_Window__c = 1;
        prcessObj2.SVMXC__Weight_Total_Distance__c = 1;
        prcessObj2.SVMXC__Weight_Route_Distance__c = 1;
        prcessObj2.SVMXC__Weight_Route_Time__c = 1;
        prcessObj2.SVMXC__Weight_Node_Type__c = 1;
        prcessObj2.SVMXC__Weight_Tech_Eligibility__c = 1;
        prcessObj2.SVMXC__Weight_Skill_Match__c = 1;
        prcessObj2.SVMXC__Weight_Product_Specialization__c = 1;
        prcessObj2.SVMXC__Weight_Preferred_Technician__c = 1;
        prcessObj2.SVMXC__Advance_Expression__c = '1 AND 2';
        prcessObj2.SVMXC__Product_Match_Enabled__c = true;
        prcessObj2.SVMXC__Expertise_Match_Enabled__c = true;
        prcessObjList.add(prcessObj2);
        insert prcessObjList;
        
        list<SVMXC__Territory__c> Territorylst = new List<SVMXC__Territory__c>();
        SVMXC__Territory__c Territory1 = new SVMXC__Territory__c();
        Territory1.name = 'RockHill';
        Territorylst.add(Territory1);
        insert Territorylst;
        
        SVMXC__ServiceMax_Processes__c prcessObj = new SVMXC__ServiceMax_Processes__c();
        prcessObj.RecordTypeId = DispatchRTypeId;
        prcessObj.SVMXC__Dispatch_Method__c = 'Real Time Optimization';
        prcessObj.SVMXC__Email_On_Error__c = 'test@servicemax.com';
        prcessObj.SVMXC__Email_On_Success__c = 'test@servicemax.com';
        prcessObj.SVMXC__Weight_Time_Window__c = 1;
        prcessObj.SVMXC__Weight_Total_Distance__c = 1;
        prcessObj.SVMXC__Weight_Route_Distance__c = 1;
        prcessObj.SVMXC__Weight_Route_Time__c = 1;
        prcessObj.SVMXC__Weight_Node_Type__c = 1;
        prcessObj.SVMXC__Weight_Tech_Eligibility__c = 1;
        prcessObj.SVMXC__Weight_Skill_Match__c = 1;
        prcessObj.SVMXC__Weight_Product_Specialization__c = 1;
        prcessObj.SVMXC__Weight_Preferred_Technician__c = 1;
        prcessObj.SVMXC__Advance_Expression__c = '1 AND 2';
        prcessObj.SVMXC__Product_Match_Enabled__c = true;
        prcessObj.SVMXC__Expertise_Match_Enabled__c = true;
        
        SVMXC.WORD_SetupDispatchProcess obj = new SVMXC.WORD_SetupDispatchProcess();
        
        obj.setprocessobj(prcessObj);
        obj.SVMX_ValidDP();
        
        prcessObj.SVMXC__Name__c = 'DP1';
        obj.setprocessobj(prcessObj);
        obj.SVMX_ValidDP();
        
        prcessObj.SVMXC__Name__c = 'OptimaxECO_DP_Test';
        obj.setprocessobj(prcessObj);
        obj.SVMX_ValidDP();
        
        obj.setSearchKeyword('Rock');
        obj.SVMX_AddTerritory();
        obj.SVMX_GO();
        List<SVMXC__Territory__c> orgTerr = obj.getOrignalTerritory();
        orgTerr[0].SVMXC__Select__c = true;
        obj.SVMX_AddSelected();
        List<SVMXC__ServiceMax_Processes__c> addedTerr = obj.getTerritoryRecLst();
        addedTerr[0].SVMXC__Select__c = true;
        obj.SVMX_DeleteTErritory();
        
        obj.setSearchKeyword('Te123rr');
        obj.SVMX_GO();
    }
    
    static testMethod void WORD_SetupDispatchProcessUnitTest4()
    {
        list<SVMXC__Territory__c> Territorylst = new List<SVMXC__Territory__c>();
        SVMXC__Territory__c Territory1 = new SVMXC__Territory__c();
        Territory1.name = 'RockHill';
        Territory1.SVMXC__Territory_s_Business_Hours__c = null;
        Territorylst.add(Territory1);
        
        BusinessHours[] bh = [Select Id from BusinessHours where IsActive=false];
        SVMXC__Territory__c Territory2 = new SVMXC__Territory__c();
        Territory2.name = 'TestTerr2';
        if (bh.size() > 0)
            Territory2.SVMXC__Territory_s_Business_Hours__c = bh[0].Id;
        else
            Territory2.SVMXC__Territory_s_Business_Hours__c = null;
        Territorylst.add(Territory2);
        insert Territorylst;
        
        List<RecordType> RecType = new  List<RecordType>();
        List<RecordType> ConfigRecordTypes = new  List<RecordType>();
        string DispatchRTypeId;
        RecType = Database.Query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\'');
        for(RecordType Rt : RecType)
        {
            if(Rt.Name == 'Dispatch Process')
            {
                DispatchRTypeId  = Rt.id;
            }
        }
        
        SVMXC__ServiceMax_Processes__c prcessObj = new SVMXC__ServiceMax_Processes__c();
        prcessObj.RecordTypeId = DispatchRTypeId;
        prcessObj.SVMXC__Dispatch_Method__c = 'Real Time Optimization';
        prcessObj.SVMXC__Email_On_Error__c = null;
        prcessObj.SVMXC__Email_On_Success__c = null;
        prcessObj.SVMXC__Weight_Tech_Eligibility__c = 1;
        prcessObj.SVMXC__Weight_Skill_Match__c = 1;
        prcessObj.SVMXC__Weight_Product_Specialization__c = 1;
        prcessObj.SVMXC__Weight_Preferred_Technician__c = 1;
        prcessObj.SVMXC__Advance_Expression__c = '1 AND 2';
        prcessObj.SVMXC__Product_Match_Enabled__c = true;
        prcessObj.SVMXC__Expertise_Match_Enabled__c = true;
        
        SVMXC.WORD_SetupDispatchProcess obj = new SVMXC.WORD_SetupDispatchProcess();
        
        obj.setprocessobj(prcessObj);
        
        obj.setSearchKeyword('Rock');
        obj.SVMX_GO();
        List<SVMXC__Territory__c> orgTerr = obj.getOrignalTerritory();
        orgTerr[0].SVMXC__Select__c = true;
        obj.SVMX_AddSelected();
        
        obj.setSearchKeyword('TestTerr2');
        obj.SVMX_GO();
        orgTerr = obj.getOrignalTerritory();
        orgTerr[0].SVMXC__Select__c = true;
        obj.SVMX_AddSelected();
        
        obj.WeightTimeWindow = 10;
        obj.WeightTotalDistance = 10; 
        obj.WeightRouteDistance = 10;
        obj.WeightRouteTime = 10;
        obj.WeightNodeType = 10;
        obj.SVMX_ValidAdvanceProcess();
        
        SVMXC__ServiceMax_Processes__c prcessObjtwo = new SVMXC__ServiceMax_Processes__c();
        prcessObjtwo.RecordTypeId = DispatchRTypeId;
        prcessObjtwo.SVMXC__Name__c = 'Test two';
        prcessObjtwo.SVMXC__Dispatch_Method__c = 'Optimized Batch';
        prcessObjtwo.SVMXC__Start_Time__c = null;
        prcessObjtwo.SVMXC__Start_Date__c = null;
        prcessObjtwo.SVMXC__Email_On_Error__c = 'test@servicemax.com';
        prcessObjtwo.SVMXC__Email_On_Success__c = 'test@servicemax.com';
        prcessObjtwo.SVMXC__Weight_Time_Window__c = 1;
        prcessObjtwo.SVMXC__Weight_Total_Distance__c = 1;
        prcessObjtwo.SVMXC__Weight_Route_Distance__c = 1;
        prcessObjtwo.SVMXC__Weight_Route_Time__c = 1;
        prcessObjtwo.SVMXC__Weight_Node_Type__c = 1;
        prcessObjtwo.SVMXC__Weight_Tech_Eligibility__c = 1;
        prcessObjtwo.SVMXC__Weight_Skill_Match__c = 1;
        prcessObjtwo.SVMXC__Weight_Product_Specialization__c = 1;
        prcessObjtwo.SVMXC__Weight_Preferred_Technician__c = 1;
        prcessObjtwo.SVMXC__Values__c = Territorylst[0].id + ':U,';
        prcessObjtwo.SVMXC__Advance_Expression__c = '1 AND 2';
        prcessObjtwo.SVMXC__Product_Match_Enabled__c = true;
        prcessObjtwo.SVMXC__Expertise_Match_Enabled__c = true;
        prcessObjtwo.SVMXC__Optimization_Goal__c = 'Minimize Overall Cost';
        
        obj.setprocessobj(prcessObjtwo);
        obj.SVMX_ValidAdvanceProcess();
        
        prcessObjtwo.SVMXC__Start_Date__c = system.today() - 1;
        obj.SVMX_ValidAdvanceProcess();
        
        prcessObjtwo.SVMXC__End_Date__c = system.today() - 2;
        obj.SVMX_ValidAdvanceProcess();
        
        WORD_SetupDispatchProcess.RunInformation runInfo = new WORD_SetupDispatchProcess.RunInformation(false,'Full','3:00 AM', false);
        obj.Disp_Schedule.add(runInfo);
        WORD_SetupDispatchProcess.RunInformation runInfo1 = new WORD_SetupDispatchProcess.RunInformation(false,'Full','3:00 AM', false);
        obj.Disp_Schedule.add(runInfo1);
        obj.SVMX_ValidAdvanceProcess();
        
        prcessObjtwo.SVMXC__Dispatch_Threshold__c = 7400;
        obj.strScheduleDays = String.valueOf(3);
        obj.SVMX_ValidAdvanceProcess();
        
        obj.ChangeSliders();
    }
    
    static testMethod void WORD_SetupDispatchProcessUnitTest5()
    {
        list<SVMXC__Territory__c> Territorylst = new List<SVMXC__Territory__c>();
        SVMXC__Territory__c Territory1 = new SVMXC__Territory__c();
        Territory1.name = 'SetupDispatchProcessUnitTest5_T1';
        Territory1.SVMXC__Territory_s_Business_Hours__c = null;
        Territorylst.add(Territory1);
        
        insert Territorylst;
        
        List<RecordType> RecType = new  List<RecordType>();
        List<RecordType> ConfigRecordTypes = new  List<RecordType>();
        String DispatchRTypeId;
        RecType = Database.Query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\'');
        for(RecordType Rt : RecType)
        {
            if(Rt.Name == 'Dispatch Process')
            {
                DispatchRTypeId  = Rt.id;
            }
        }
        
        SVMXC__ServiceMax_Processes__c prcessObjtwo = new SVMXC__ServiceMax_Processes__c();
        prcessObjtwo.RecordTypeId = DispatchRTypeId;
        prcessObjtwo.SVMXC__Name__c = 'Test two';
        prcessObjtwo.SVMXC__Dispatch_Method__c = 'Optimized Batch';
        prcessObjtwo.SVMXC__Start_Time__c = '10:00 AM';
        prcessObjtwo.SVMXC__Start_Date__c = system.today();
        prcessObjtwo.SVMXC__Email_On_Error__c = 'test@servicemax.com';
        prcessObjtwo.SVMXC__Email_On_Success__c = 'test@servicemax.com';
        prcessObjtwo.SVMXC__Weight_Time_Window__c = 1;
        prcessObjtwo.SVMXC__Weight_Total_Distance__c = 1;
        prcessObjtwo.SVMXC__Weight_Route_Distance__c = 1;
        prcessObjtwo.SVMXC__Weight_Route_Time__c = 1;
        prcessObjtwo.SVMXC__Weight_Node_Type__c = 1;
        prcessObjtwo.SVMXC__Weight_Tech_Eligibility__c = 1;
        prcessObjtwo.SVMXC__Weight_Skill_Match__c = 1;
        prcessObjtwo.SVMXC__Weight_Product_Specialization__c = 1;
        prcessObjtwo.SVMXC__Weight_Preferred_Technician__c = 1;
        prcessObjtwo.SVMXC__Values__c = Territorylst[0].id + ':U,';
        prcessObjtwo.SVMXC__Advance_Expression__c = '1 AND 2';
        prcessObjtwo.SVMXC__Product_Match_Enabled__c = true;
        prcessObjtwo.SVMXC__Expertise_Match_Enabled__c = true;
        prcessObjtwo.SVMXC__Optimization_Goal__c = 'Minimize Overall Cost';
        prcessObjtwo.SVMXC__Full_Run_Unit__c = 'Days';
        prcessObjtwo.SVMXC__Runs_Every_Monday__c = true;
        
        SVMXC.WORD_SetupDispatchProcess obj = new SVMXC.WORD_SetupDispatchProcess();
        
        obj.setprocessobj(prcessObjtwo);
        obj.getIsNew();
        obj.getNewMode();
        obj.getDispatchMethod();
        
        obj.setSearchKeyword('SetupDispatchProcessUnitTest5_T1');
        obj.SVMX_GO();
        List<SVMXC__Territory__c> orgTerr = obj.getOrignalTerritory();
        orgTerr[0].SVMXC__Select__c = true;
        obj.SVMX_AddSelected();
        
        WORD_SetupDispatchProcess.RunInformation runInfo = new WORD_SetupDispatchProcess.RunInformation(false,'Full','11:00 AM', true);
        runInfo.setIsActive(true);
        obj.Disp_Schedule.add(runInfo);
        
        obj.SVMX_FinalSave();
    }
    
    static testMethod void WORD_SetupDispatchProcessUnitTest6()
    {
        list<SVMXC__Territory__c> Territorylst = new List<SVMXC__Territory__c>();
        BusinessHours bh = [Select Id from BusinessHours where IsDefault=true];
        SVMXC__Territory__c Territory1 = new SVMXC__Territory__c();
        Territory1.name = 'SetupDispatchProcessUnitTest6_T1';
        Territory1.SVMXC__Territory_s_Business_Hours__c = bh.id;
        Territorylst.add(Territory1);
        
        insert Territorylst;
        
        List<RecordType> RecType = new  List<RecordType>();
        List<RecordType> ConfigRecordTypes = new  List<RecordType>();
        String DispatchRTypeId;
        RecType = Database.Query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\'');
        for(RecordType Rt : RecType)
        {
            if(Rt.Name == 'Dispatch Process')
            {
                DispatchRTypeId  = Rt.id;
            }
        }
        
        SVMXC__ServiceMax_Processes__c prcessObjtwo = new SVMXC__ServiceMax_Processes__c();
        prcessObjtwo.RecordTypeId = DispatchRTypeId;
        prcessObjtwo.SVMXC__Name__c = 'Test DP for ECO';
        prcessObjtwo.SVMXC__Dispatch_Method__c = 'Real Time Optimization';
        prcessObjtwo.SVMXC__Start_Time__c = '10:00 AM';
        prcessObjtwo.SVMXC__Email_On_Error__c = 'test@servicemax.com';
        prcessObjtwo.SVMXC__Email_On_Success__c = 'test@servicemax.com';
        prcessObjtwo.SVMXC__Weight_Time_Window__c = 1;
        prcessObjtwo.SVMXC__Weight_Total_Distance__c = 1;
        prcessObjtwo.SVMXC__Weight_Route_Distance__c = 1;
        prcessObjtwo.SVMXC__Weight_Route_Time__c = 1;
        prcessObjtwo.SVMXC__Weight_Node_Type__c = 1;
        prcessObjtwo.SVMXC__Weight_Tech_Eligibility__c = 1;
        prcessObjtwo.SVMXC__Weight_Skill_Match__c = 1;
        prcessObjtwo.SVMXC__Weight_Product_Specialization__c = 1;
        prcessObjtwo.SVMXC__Weight_Preferred_Technician__c = 1;
        prcessObjtwo.SVMXC__Values__c = Territorylst[0].id + ':U,';
        prcessObjtwo.SVMXC__Advance_Expression__c = '1 AND 2';
        prcessObjtwo.SVMXC__Product_Match_Enabled__c = true;
        prcessObjtwo.SVMXC__Expertise_Match_Enabled__c = true;
        prcessObjtwo.SVMXC__Optimization_Goal__c = 'Minimize Overall Cost';
        prcessObjtwo.SVMXC__Full_Run_Unit__c = 'Days';
        prcessObjtwo.SVMXC__Dispatch_Threshold__c = 30;
        prcessObjtwo.SVMXC__Optimizer_Sync_Interval__c = 30;
        
        SVMXC.WORD_SetupDispatchProcess obj = new SVMXC.WORD_SetupDispatchProcess();
        
        obj.setprocessobj(prcessObjtwo);
        
        obj.setSearchKeyword('SetupDispatchProcessUnitTest6_T1');
        obj.SVMX_GO();
        List<SVMXC__Territory__c> orgTerr = obj.getOrignalTerritory();
        orgTerr[0].SVMXC__Select__c = true;
        obj.SVMX_AddSelected();
        
        obj.SVMX_ECOFinalSave();
    }
    
    static testMethod void coverGetSetMethods() {
        SVMXC.WORD_SetupDispatchProcess obj = new SVMXC.WORD_SetupDispatchProcess();
        obj.StartAfter = '5';
        obj.strSelectedTimeZone = 'Asia/Kolkata';
        obj.strLTPStartAftrFull = '10';
        obj.strLTPScheduleDays = '25';
        obj.ltpRunAt = '12:00 AM';
        obj.ltpStartAfter = '20';
        obj.getlstDispatchMethod();
        obj.strScheduleDays = '10';
        obj.delIndex = '1';
        
        obj.getdisableCapacityTab();
        obj.getCapacityLimitationsTab();
        obj.getlongTermPlannerTab();
        obj.getisDispatchMethodLTP();
        obj.getZoneTab();
        obj.RulesNotMatchedThenAssignWOto();
        obj.CapacityLimitaionsCriADDRow();
        obj.CapacityLimitaionsCriDeleteRow();
        obj.getCapacityLimitationsCriExpressions();
        
        obj.getCapacityNewRuleBtn();
        obj.getCapacitySaveBtn();
        obj.getCapacityCancelBtn();
        obj.getCapacityEditBtn();
        obj.getCapacityDelBtn();
        obj.getCapacityDisbalePriChkBox();
        obj.getCapacityBlkSec();
        obj.getCapacityEditName();
        obj.getCapacityEditThreshold();
    
        obj.getenableAdvanceExprSec();
        Boolean b = true;
        obj.setenableAdvanceExprSec(b);
        obj.getCapacityLimitations();
        List<SVMXC__ServiceMax_Processes__c> sp = new List<SVMXC__ServiceMax_Processes__c>();
        obj.setCapacityLimitations(sp);
        
    }
    
    static testMethod void testLTPMethods() {
        SVMXC.WORD_SetupDispatchProcess obj = new SVMXC.WORD_SetupDispatchProcess();
        
        List<SVMXC__ServiceMax_Config_Data__c> lst = new List<SVMXC__ServiceMax_Config_Data__c>();
        obj.getlstLongTermPlanningConfigData();
        obj.setlstLongTermPlanningConfigData(lst);
        
        List<SVMXC__ServiceMax_Config_Data__c> lstSchedules = new List<SVMXC__ServiceMax_Config_Data__c>();
        obj.getlstSchedules();
        obj.setlstSchedules(lstSchedules);
        
        integer intSeqVal;
        obj.getintSeqVal();
        obj.setintSeqVal(intSeqVal);
        
        boolean enableLTPCheckbox = false;
        obj.getenableLTPCheckbox();
        obj.setenableLTPCheckbox(enableLTPCheckbox);
        
        obj.enableLTPCheckbox = true;
        obj.isDispatchMethodLTP = true;
        obj.enableLTPSectionOnCheckBox();
        obj.toEnableDisableLTPSections();
        
        
        obj.enableLTPCheckbox = false;
        obj.isDispatchMethodLTP = false;
        obj.enableLTPSectionOnCheckBox();
        obj.toEnableDisableLTPSections();
        
        List<RecordType> RecType = new  List<RecordType>();
        List<RecordType> ConfigRecordTypes = new  List<RecordType>();
        string DispatchRTypeId;
        string ExpressionRTypeId;
        string RuleRecordTypeId;
        string Schedule_Rtype_Id;
        RecType = Database.Query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\' OR SobjectType = \'SVMXC__ServiceMax_Config_Data__c\'');
        system.debug('RecType'+RecType);
        System.assert(RecType != null, 'RecType assertion failed' );
        for(RecordType Rt : RecType)
        {
            if(Rt.Name == 'Dispatch Process')
            {
                DispatchRTypeId  = Rt.id;
            }
            if(Rt.Name == 'SVMX Rule')
            {
                RuleRecordTypeId = Rt.id;
            }
            if(Rt.Name == 'Schedule' && Rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
            {
                Schedule_Rtype_Id = Rt.Id;
            }
            if(Rt.Name == 'Expressions')
                ExpressionRTypeId = Rt.id;
        }
        
        list<SVMXC__Territory__c> Territorylst = new List<SVMXC__Territory__c>();
        SVMXC__Territory__c Territory1 = new SVMXC__Territory__c();
        Territory1.name = 'india';
        Territorylst.add(Territory1);
        
        SVMXC__Territory__c Territory2 = new SVMXC__Territory__c();
        Territory2.name = 'bangalore';
        Territorylst.add(Territory2);
        
        insert Territorylst;
        SVMXC__ServiceMax_Processes__c prcessObjone = new SVMXC__ServiceMax_Processes__c();
        prcessObjone.RecordTypeId =  DispatchRTypeId;
        prcessObjone.SVMXC__Name__c = 'Test one';
        prcessObjone.SVMXC__Dispatch_Method__c = 'Long-Term Planner';
        prcessObjone.SVMXC__Start_Time__c= '11:00 AM';
        prcessObjone.SVMXC__Start_Date__c = system.today();
        prcessObjone.SVMXC__End_Date__c = system.today().addDays(12);
        prcessObjone.SVMXC__Email_On_Error__c = 'test@servicemax.com';
        prcessObjone.SVMXC__Email_On_Success__c = 'test@servicemax.com';
        prcessObjone.SVMXC__Weight_Time_Window__c = 1;
        prcessObjone.SVMXC__Weight_Total_Distance__c = 1;
        prcessObjone.SVMXC__Weight_Route_Distance__c = 1;
        prcessObjone.SVMXC__Weight_Route_Time__c = 1;
        prcessObjone.SVMXC__Weight_Node_Type__c = 1;
        prcessObjone.SVMXC__Values__c = Territorylst[0].id + ':U,';
        prcessObjone.SVMXC__Window_Height__c = 10;
        prcessObjone.Frequency__c = Integer.valueOf('10');
        prcessObjone.Calendar_End_Days__c = Integer.valueOf('10');
        prcessObjone.Calendar_Start_Days__c = Integer.valueOf('10');
        prcessObjone.SVMXC__Window_Width__c = Double.valueOf('20');
        prcessObjone.SVMXC__Window_Height__c = Double.valueOf('10');
        prcessObjone.SVMXC__Confirmation_Message__c = 'message';
        
        insert prcessObjone;
        
        List<SVMXC__ServiceMax_Config_Data__c> lstRun = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = prcessObjone.Id;
        currentRun.SVMXC__Run_At__c = '5:00 AM';
        currentRun.SVMXC__Run_Type__c = 'Day of Week';
        currentRun.SVMXC__Schedule_Days__c = 'Monday;Tuesday';
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = prcessObjone.Id;
        currentRun.SVMXC__Run_At__c = '5:25 AM';
        currentRun.SVMXC__Run_Type__c = 'Date of Month';
        currentRun.SVMXC__Day_to_Run__c = '8';
        currentRun.SVMXC__Schedule_Days__c = 'Monday;Tuesday';
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = prcessObjone.Id;
        currentRun.SVMXC__Run_At__c = null;
        currentRun.SVMXC__Run_Type__c = null;
        currentRun.SVMXC__Day_to_Run__c = '8';
        currentRun.SVMXC__Schedule_Days__c = 'Monday;Tuesday';
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = prcessObjone.Id;
        currentRun.SVMXC__Run_At__c = '5:00 AM';
        currentRun.SVMXC__Run_Type__c = 'Day of Week';
        currentRun.SVMXC__Schedule_Days__c = null;
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = prcessObjone.Id;
        currentRun.SVMXC__Run_At__c = '5:25 AM';
        currentRun.SVMXC__Run_Type__c = 'Date of Month';
        currentRun.SVMXC__Day_to_Run__c = null;
        currentRun.SVMXC__Schedule_Days__c = 'Monday;Tuesday';
        lstRun.add(currentRun);
        
        insert lstRun;
        
        obj.lstSchedules = new List<SVMXC__ServiceMax_Config_Data__c>();
        obj.lstSchedules.addAll(lstRun);
        
        obj.saveLTPSchedule();
        obj.isvalidLTPSchedule();
        
        obj.initializeLTPScheduleTable();
        obj.changeRunType();
        
        
        obj.lstSchedules_AddRow();
        
        obj.delIndex = '1';
        obj.getlongTermPlanningRunExpressions();
        obj.ltpExpresCriADDRow();
        obj.ltpExpresCriDeleteRow();
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.SVMXC__Sequence__c=1;
        configData.SVMXC__Field_Name__c='SVMXC__City__c';
        configData.SVMXC__Operator__c='equals'; 
        configData.SVMXC__Operand__c='Goa'; 
        configData.SVMXC__Object_Name__c='SVMXC__Service_Order__c'; 
        configData.SVMXC__Expression_Type__c='DISP_Process_Entry'; 
        configData.SVMXC__Expression_Rule__c=null; 
        configData.RecordTypeId=ExpressionRTypeId;
        
        List<SVMXC__ServiceMax_Config_Data__c> lstLongTermPlanningConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstLongTermPlanningConfigData.add(configData);
        insert lstLongTermPlanningConfigData;
        
        List<selectoption> Hdrfldlist=new List<selectoption>();
        WORD_SetupDispatch_Methods DispMethods = new WORD_SetupDispatch_Methods();
        List<SelectOption> so = DispMethods.sortingSelectOption(Hdrfldlist, true);
        COMM_SVMXC_Search_Expressions longTermPlanningRunExpressions=new COMM_SVMXC_Search_Expressions(1,true,true,true,false,true,'','');
        DispMethods.RetriveField('SVMXC__Service_Order__c', Hdrfldlist, longTermPlanningRunExpressions.mapFieldDispType, longTermPlanningRunExpressions.FieldApiLable);
        longTermPlanningRunExpressions.FieldsList=Hdrfldlist;
        longTermPlanningRunExpressions.objfieldMap=DispMethods.mMapFieldList.get('SVMXC__Service_Order__c');
        longTermPlanningRunExpressions.DefaultField=DispMethods.getTAG033();
        longTermPlanningRunExpressions.DefaultOperator=DispMethods.getTAG033();
        longTermPlanningRunExpressions.DefaultListValue=DispMethods.getTAG033();
        longTermPlanningRunExpressions.ExpressionType='CRITERIA';
        for(SVMXC__ServiceMax_Config_Data__c exp : lstLongTermPlanningConfigData)
        {
            longTermPlanningRunExpressions.setExpressions(exp);
        }
        obj.validateAdvanceExpression(longTermPlanningRunExpressions);
    }
    
    static testMethod void coverSubmitExprMethod()
    {
        SVMXC.WORD_SetupDispatchProcess obj;
        List<RecordType> RecType = new  List<RecordType>();
        List<RecordType> ConfigRecordTypes = new  List<RecordType>();
        string DispatchRTypeId;
        string RuleRecordTypeId;
        string ExpressionRTypeId;
        RecType = Database.Query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\'');
        system.debug('RecType'+RecType);
        System.assert(RecType != null, 'RecType assertion failed');
        
        for(RecordType Rt : RecType)
        {
            if(Rt.Name == 'Dispatch Process')
            {
                DispatchRTypeId  = Rt.id;
            }
            if(Rt.Name == 'SVMX Rule')
            {
                RuleRecordTypeId = Rt.id;
            }
        }
        
        ConfigRecordTypes = Database.query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Config_Data__c\'');
        for(RecordType r : ConfigRecordTypes)
        {
            if(r.Name == 'Expressions')
            {
                ExpressionRTypeId = r.id;
            }
        }
        
        //Create the Territory....
        list<SVMXC__Territory__c> Territorylst = new List<SVMXC__Territory__c>();
        SVMXC__Territory__c Territory1 = new SVMXC__Territory__c();
        Territory1.name = 'india';
        Territorylst.add(Territory1);
        insert Territorylst;
        
        List<SVMXC__ServiceMax_Processes__c> prcessObjList=new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c prcessObj4=new SVMXC__ServiceMax_Processes__c();
        prcessObj4.RecordTypeId =  DispatchRTypeId;
        prcessObj4.SVMXC__Name__c = 'Test Four';
        prcessObj4.SVMXC__Dispatch_Method__c = 'Real Time Optimization';
        prcessObj4.SVMXC__Email_On_Error__c = 'test@servicemax.com';
        prcessObj4.SVMXC__Email_On_Success__c = 'test@servicemax.com';
        prcessObj4.SVMXC__Weight_Time_Window__c = 1;
        prcessObj4.SVMXC__Weight_Total_Distance__c = 1;
        prcessObj4.SVMXC__Weight_Route_Distance__c = 1;
        prcessObj4.SVMXC__Weight_Route_Time__c = 1;
        prcessObj4.SVMXC__Weight_Node_Type__c = 1;
        prcessObj4.SVMXC__Weight_Tech_Eligibility__c = 1;
        prcessObj4.SVMXC__Weight_Skill_Match__c = 1;
        prcessObj4.SVMXC__Weight_Product_Specialization__c = 1;
        prcessObj4.SVMXC__Weight_Preferred_Technician__c = 1;
        prcessObj4.SVMXC__Values__c = Territorylst[0].id + ':U,';
        prcessObj4.SVMXC__Advance_Expression__c = '1 AND 2';
        prcessObj4.SVMXC__Product_Match_Enabled__c = true;
        prcessObj4.SVMXC__Expertise_Match_Enabled__c = true;
        
        prcessObjList.add(prcessObj4);
        insert prcessObjList;
        
        List<SVMXC__ServiceMax_Config_Data__c> configLst= new List<SVMXC__ServiceMax_Config_Data__c>(); 
        SVMXC__ServiceMax_Config_Data__c confForObj4 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = prcessObj4.id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__Source_City__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'werw',
                                            SVMXC__Expression_Type__c = 'DISP_Process_Entry'                                            
                                            );
        configLst.add(confForObj4);
        insert configLst;        
        
        List<SVMXC__ServiceMax_Processes__c>  RuleLst = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c  PRule5 = new SVMXC__ServiceMax_Processes__c();
        PRule5.RecordTypeId = RuleRecordTypeId;
        PRule5.SVMXC__Rule_Type__c = 'Priortization';
        PRule5.SVMXC__Process__c = prcessObj4.id; 
        PRule5.SVMXC__Sequence__c = 5;
        PRule5.SVMXC__ProcessID__c ='PROCESS11';
        PRule5.SVMXC__SettingId__c = 'PROCESS11';
        PRule5.SVMXC__MapID__c = 'PROCESS11';
        PRule5.SVMXC__Name__c = 'PROCESS22';
        RuleLst.add(PRule5);
        
        SVMXC__ServiceMax_Processes__c  TRule3 = new SVMXC__ServiceMax_Processes__c();
        TRule3.RecordTypeId = RuleRecordTypeId;
        TRule3.SVMXC__Territory__c = Territorylst[0].id;
        TRule3.SVMXC__Rule_Type__c = 'Territory Access';
        TRule3.SVMXC__Process__c = prcessObj4.id; 
        TRule3.SVMXC__ProcessID__c = 'PROCESS11';
        TRule3.SVMXC__SettingId__c = 'PROCESS11';
        TRule3.SVMXC__MapID__c = 'PROCESS11';
        TRule3.SVMXC__Name__c = 'PROCESS22';
        TRule3.SVMXC__Select__c = true;
        RuleLst.add(TRule3);
        insert RuleLst;
        
        test.startTest();
        PageReference pageRef = Page.WORD_SetupDispatchProcess;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('dpeid', prcessObj4.id);
        
        obj = new SVMXC.WORD_SetupDispatchProcess();
        obj.setIsNew(true);
        obj.SVMX_AssignmentRules();
        obj.getECOSchedulingTab();
        obj.setRuleLst(RuleLst);
        obj.SVMX_ValidAdvanceProcess();
        obj.SVMX_SaveDP();
        obj.SVMX_Scheduling();
        obj.SVMX_ECOFinalSave();  
        obj.submitExp(prcessObj4, configLst, prcessObj4.SVMXC__Advance_Expression__c);
        test.stopTest();
    }
}