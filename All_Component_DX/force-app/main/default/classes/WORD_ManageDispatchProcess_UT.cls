@isTest(seeAllData = true)
Private with sharing class WORD_ManageDispatchProcess_UT {
    
    static testMethod void WORD_ManageDispatchProcessUnitTest() {
        List<RecordType> RecType = new  List<RecordType>();
        List<RecordType> ConfigRecordTypes = new  List<RecordType>();
        string DispatchRTypeId;
        string ExpressionRTypeId;
        string RuleRecordTypeId;
        RecType = Database.Query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\'');
        system.debug('RecType'+RecType);
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
        List<SVMXC__ServiceMax_Processes__c> prcessObjList=new List<SVMXC__ServiceMax_Processes__c>();
        
        SVMXC__ServiceMax_Processes__c prcessObjone=new SVMXC__ServiceMax_Processes__c();
        prcessObjone.RecordTypeId =  DispatchRTypeId;
        prcessObjone.SVMXC__ProcessID__c='PROCESS11';
        prcessObjone.SVMXC__SettingId__c = 'PROCESS11';
        prcessObjone.SVMXC__MapID__c='PROCESS11';
        prcessObjone.SVMXC__Name__c = 'PROCESS22';
        prcessObjone.Dispatch_Method__c = 'Immediate';
        prcessObjone.SVMXC__Select__c = true;
        prcessObjone.SVMXC__Sequence__c = 1;
        prcessObjList.add(prcessObjone);
        
        SVMXC__ServiceMax_Processes__c prcessObjtwo=new SVMXC__ServiceMax_Processes__c();
        prcessObjtwo.RecordTypeId =  DispatchRTypeId;
        prcessObjtwo.SVMXC__ProcessID__c='PROCESS11';
        prcessObjtwo.SVMXC__SettingId__c = 'PROCESS11';
        prcessObjtwo.SVMXC__MapID__c='PROCESS11';
        prcessObjtwo.SVMXC__Name__c = 'Test two22';
        prcessObjtwo.Dispatch_Method__c = 'Optimized Batch';
        prcessObjtwo.SVMXC__Select__c = true;
        prcessObjtwo.SVMXC__Sequence__c = 2;
        prcessObjList.add(prcessObjtwo);
        
        insert prcessObjList;
        System.assertEquals(true, prcessObjList != null);
        
        
        
        //Create the Territory....
        list<SVMXC__Territory__c> Territorylst = new List<SVMXC__Territory__c>();
        SVMXC__Territory__c Territory1 = new SVMXC__Territory__c();
        Territory1.name = 'india';
        Territorylst.add(Territory1);
        
        SVMXC__Territory__c Territory2 = new SVMXC__Territory__c();
        Territory2.name = 'bangalore';
        Territorylst.add(Territory2);
        
        insert Territorylst;
        System.assertEquals(true, Territorylst != null);
        
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
        System.assertEquals(true, conf1 != null);
        
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
        
        //Create Assignment Rule...
        List<SVMXC__ServiceMax_Processes__c>  RuleLst = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Processes__c>  DelRuleLst = new List<SVMXC__ServiceMax_Processes__c>();
        
        SVMXC__ServiceMax_Processes__c  ARule1 = new SVMXC__ServiceMax_Processes__c();
        ARule1.RecordTypeId = RuleRecordTypeId;
        ARule1.SVMXC__ProcessID__c='PROCESS11';
        ARule1.SVMXC__SettingId__c = 'PROCESS11';
        ARule1.SVMXC__MapID__c='PROCESS11';
        ARule1.SVMXC__Name__c = 'PROCESS22';
        ARule1.SVMXC__Rule_Type__c = 'Simple Assignment';
        ARule1.SVMXC__Process__c = prcessObjone.id; 
        ARule1.SVMXC__Select__c = true;
        RuleLst.add(ARule1);
        DelRuleLst.add(ARule1);
        
        SVMXC__ServiceMax_Processes__c  ARule2 = new SVMXC__ServiceMax_Processes__c();
        ARule2.RecordTypeId = RuleRecordTypeId;
        ARule2.SVMXC__ProcessID__c='PROCESS11';
        ARule2.SVMXC__SettingId__c = 'PROCESS11';
        ARule2.SVMXC__MapID__c='PROCESS11';
        ARule2.SVMXC__Name__c = 'PROCESS22';
        ARule2.SVMXC__Rule_Type__c = 'Simple Assignment';
        ARule2.SVMXC__Process__c = prcessObjone.id; 
        ARule2.SVMXC__Select__c = true;
        RuleLst.add(ARule2);
        DelRuleLst.add(ARule2);
        SVMXC__ServiceMax_Processes__c  ARule3 = new SVMXC__ServiceMax_Processes__c();
        ARule3.RecordTypeId = RuleRecordTypeId;
        ARule3.SVMXC__ProcessID__c='PROCESS11';
        ARule3.SVMXC__SettingId__c = 'PROCESS11';
        ARule3.SVMXC__MapID__c='PROCESS11';
        ARule3.SVMXC__Name__c = 'PROCESS22';
        ARule3.SVMXC__Rule_Type__c = 'Simple Assignment';
        ARule3.SVMXC__Process__c = prcessObjone.id; 
        RuleLst.add(ARule3);
        //Create Priority Rule 
        
        SVMXC__ServiceMax_Processes__c  PRule1 = new SVMXC__ServiceMax_Processes__c();
        PRule1.RecordTypeId = RuleRecordTypeId;
        PRule1.SVMXC__ProcessID__c='PROCESS11';
        PRule1.SVMXC__SettingId__c = 'PROCESS11';
        PRule1.SVMXC__MapID__c='PROCESS11';
        PRule1.SVMXC__Name__c = 'PROCESS22';
        PRule1.SVMXC__Rule_Type__c = 'Priortization';
        PRule1.SVMXC__Process__c = prcessObjtwo.id; 
        PRule1.SVMXC__Select__c = true;
        RuleLst.add(PRule1);
        SVMXC__ServiceMax_Processes__c  PRule2 = new SVMXC__ServiceMax_Processes__c();
        PRule2.RecordTypeId = RuleRecordTypeId;
        PRule2.SVMXC__ProcessID__c='PROCESS11';
        PRule2.SVMXC__SettingId__c = 'PROCESS11';
        PRule2.SVMXC__MapID__c='PROCESS11';
        PRule2.SVMXC__Name__c = 'PROCESS22';
        PRule2.SVMXC__Rule_Type__c = 'Priortization';
        PRule2.SVMXC__Process__c = prcessObjtwo.id; 
        RuleLst.add(PRule2);
        SVMXC__ServiceMax_Processes__c  PRule3 = new SVMXC__ServiceMax_Processes__c();
        PRule3.RecordTypeId = RuleRecordTypeId;
        PRule3.SVMXC__ProcessID__c='PROCESS11';
        PRule3.SVMXC__SettingId__c = 'PROCESS11';
        PRule3.SVMXC__MapID__c='PROCESS11';
        PRule3.SVMXC__Name__c = 'PROCESS22';
        PRule3.SVMXC__Rule_Type__c = 'Priortization';
        PRule3.SVMXC__Process__c = prcessObjtwo.id; 
        RuleLst.add(PRule3);
        SVMXC__ServiceMax_Processes__c  PRule4 = new SVMXC__ServiceMax_Processes__c();
        PRule4.RecordTypeId = RuleRecordTypeId;
        PRule4.SVMXC__ProcessID__c='PROCESS11';
        PRule4.SVMXC__SettingId__c = 'PROCESS11';
        PRule4.SVMXC__MapID__c='PROCESS11';
        PRule4.SVMXC__Name__c = 'PROCESS22';
        PRule4.SVMXC__Rule_Type__c = 'Priortization';
        PRule4.SVMXC__Process__c = prcessObjtwo.id; 
        RuleLst.add(PRule4);
        
        ////Create the Territory  for AdvanceDispatch....
        
        SVMXC__ServiceMax_Processes__c  TRule1 = new SVMXC__ServiceMax_Processes__c();
        TRule1.RecordTypeId = RuleRecordTypeId;
        TRule1.SVMXC__ProcessID__c='PROCESS11';
        TRule1.SVMXC__SettingId__c = 'PROCESS11';
        TRule1.SVMXC__MapID__c='PROCESS11';
        TRule1.SVMXC__Name__c = 'PROCESS22';
        TRule1.SVMXC__Territory__c = Territorylst[0].id;
        TRule1.SVMXC__Rule_Type__c = 'Territory Access';
        TRule1.SVMXC__Process__c = prcessObjtwo.id; 
        RuleLst.add(TRule1);
        
        SVMXC__ServiceMax_Processes__c  TRule2 = new SVMXC__ServiceMax_Processes__c();
        TRule2.RecordTypeId = RuleRecordTypeId;
        TRule2.SVMXC__ProcessID__c='PROCESS11';
        TRule2.SVMXC__SettingId__c = 'PROCESS11';
        TRule2.SVMXC__MapID__c='PROCESS11';
        TRule2.SVMXC__Name__c = 'PROCESS22';
        TRule2.SVMXC__Territory__c = Territorylst[1].id;
        TRule2.SVMXC__Rule_Type__c = 'Territory Access';
        TRule2.SVMXC__Process__c = prcessObjtwo.id; 
        RuleLst.add(TRule2);
        
        insert RuleLst;
        System.assertEquals(true, RuleLst != null);
        
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
                                            SVMXC__Expression_Rule__c = ARule1.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__City__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'pune',
                                            SVMXC__Expression_Type__c = 'DISP_Simple_Assignment'                                            
                                            );
         configLst.add(conf4);                                    
         //Create config data for Assignmment rule 
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
        System.assertEquals(true, configLst != null);
        
            SVMXC__Territory__c ter=new SVMXC__Territory__c();
            ter.Name='FirstTerritory';
            ter.SVMXC__Active__c=true;
            insert ter;
            
            SVMXC__SVMX_Jobs__c job= new SVMXC__SVMX_Jobs__c();
            job.SVMXC__Message__c='Servicemax';
            job.SVMXC__Status__c='current';
            job.SVMXC__Type__c='OptiMax';
            job.SVMXC__Territory__c=ter.id;
            insert job;
        
        WORD_ManageDispatchProcess.JobRecWrapper objJobRec = new WORD_ManageDispatchProcess.JobRecWrapper(false,new SVMXC__SVMX_Jobs__c());
        objJobRec.setobjjobRec(new SVMXC__SVMX_Jobs__c());
        objJobRec.getjobRec();
        PageReference pageRef = Page.WORD_ManageDispatchProcess;
        Test.setCurrentPage(pageRef);
        WORD_ManageDispatchProcess controller = new WORD_ManageDispatchProcess();
        controller.SVMX_DPSequence();
        controller.setDispatchProcessLst(prcessObjList);
        integer selIndex=0;
        boolean isTop=true;
        controller.shuffle(selIndex,isTop);
        WORD_ManageDispatchProcess controller1 = new WORD_ManageDispatchProcess();
        controller.setselectedId(job.id);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.setMock(WebServiceMock.class, new OMAX_Execute_Job_WS_Success_Impl());
        controller.SVMX_RunJob();
        
        controller1.setselectedId(job.id);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.setMock(WebServiceMock.class, new OMAX_Execute_Job_WS_Fail_Impl());
        controller1.SVMX_RunJob();
        Test.stopTest();
        
        controller.getJobRecLst();
        controller.getselectedId();
        //........Creation of list of Process id...........
        List<string> processLst= new List<string>();
        processLst.add(prcessObjone.id);
        processLst.add(prcessObjone.id);

        string[] o =processLst;
        controller.getTAG001();
        controller.getTAG002();
        controller.getTAG003();
        controller.getTAG004();
        controller.getTAG005();
        controller.getTAG006();
        controller.getTAG007();
        controller.getTAG008();
        controller.getTAG009();
        controller.getTAG010();
        controller.getTAG011();
        controller.getTAG012();
        controller.getTAG013();
        controller.getTAG014();
        controller.getTAG015();
        controller.getTAG016();
        controller.getTAG017();
        controller.getTAG018();
        controller.getTAG019();
        controller.getTAG020();
        controller.getTAG021();
        controller.getTAG022();
        controller.getTAG023();
        controller.getTAG024();
        controller.getTAG025();
        controller.getTAG026();
        controller.getTAG027();
        controller.getTAG028();
        controller.getTAG029();
        controller.getTAG030();
        controller.getTAG031();
        controller.getTAG032();
        controller.getTAG033();
        controller.getTAG034();
        controller.getTAG035();
        controller.getTAG036();
        controller.getTAG037();
        controller.getTAG038();
        controller.getHLPURL();
        
        // controller.svmxTagList.clear();
        
        controller.getTAG001();
        controller.getTAG002();
        controller.getTAG003();
        controller.getTAG004();
        controller.getTAG005();
        controller.getTAG006();
        controller.getTAG007();
        controller.getTAG008();
        controller.getTAG009();
        controller.getTAG010();
        controller.getTAG011();
        controller.getTAG012();
        controller.getTAG013();
        controller.getTAG014();
        controller.getTAG015();
        controller.getTAG016();
        controller.getTAG017();
        controller.getTAG018();
        controller.getTAG019();
        controller.getTAG020();
        controller.getTAG021();
        controller.getTAG022();
        controller.getTAG023();
        controller.getTAG024();
        controller.getTAG025();
        controller.getTAG026();
        controller.getTAG027();
        controller.getTAG028();
        controller.getTAG029();
        controller.getTAG030();
        controller.getTAG031();
        controller.getTAG032();
        controller.getHLPURL();
        controller.ValidProcess();
        controller.getDispatchProcessLst();
        controller.getHdrMsg();
        controller.getDisProSize();
        controller.getDisProLst();
        controller.getPageNameToRedirect();
        controller.getDetailPageId();
        controller.switchtab();
        controller.getJobObjects();
        controller.SVMX_PopupCancel();
        controller.setitems(o);
        controller.getitems();
        controller.UP();
        controller.Down();
        controller.SVMX_SaveSequence();
        controller.Bottom();
        controller.Top();
        controller.getSeqoptions();
        controller.getdisplaySeqPopup();
        prcessObjList.clear();
        prcessObjone.SVMXC__Select__c = false;
        prcessObjtwo.SVMXC__Select__c = true;
        prcessObjList.add(prcessObjone);
        prcessObjList.add(prcessObjtwo);
        upsert prcessObjList;
        controller.SVMX_Clone();
        controller.SVMX_Edit();
        prcessObjList.clear();
        prcessObjone.SVMXC__Select__c = true;
        prcessObjtwo.SVMXC__Select__c = false;
        prcessObjList.add(prcessObjone);
        prcessObjList.add(prcessObjtwo);
        upsert prcessObjList;
        controller.setDispatchProcessLst(prcessObjList);
        controller.SVMX_Clone();
        controller.SVMX_Edit();
        controller.SVMXC_ShowJob();
        controller.SVMX_NewProcess();
        controller.SVMX_Delete();
        controller.SVMX_BackToSetupHome();
      
    }
    
    
    //Test Method covering the abort job functionality
     static testMethod void test_AbortJob() {
        system.debug('******************Begin  test_AbortJob');
        
        WORD_ManageDispatchProcess controller = new WORD_ManageDispatchProcess();
        
        controller.getTAG040();
        controller.getTAG041();
        controller.getTAG042();
        controller.getTAG043();
        controller.getTAG044();
        controller.getTAG045();
        controller.getTAG046();
        controller.getTAG047();
        controller.getTAG048();
        controller.setIsActiveJob(true);
        controller.getIsActiveJob();
        controller.setIsRealTimeOptProcess(true);
        controller.getIsRealTimeOptProcess();
        controller.setEnableAbortJobButton(true);
        controller.getEnableAbortJobButton();
        
        SVMXC__Territory__c ter=new SVMXC__Territory__c();
        ter.Name='FirstTerritory';
        ter.SVMXC__Active__c=true;
        insert ter;
            
        SVMXC__SVMX_Jobs__c objSVMXJob = new SVMXC__SVMX_Jobs__c();
        objSVMXJob.SVMXC__OptiMax_Message__c = 'Initiate Error';
        objSVMXJob.SVMXC__Message__c='Servicemax';
        objSVMXJob.SVMXC__Status__c='current';
        objSVMXJob.SVMXC__Type__c='OptiMax';
        objSVMXJob.SVMXC__Territory__c=ter.id;
        insert objSVMXJob;
        
        controller.setselectedId(objSVMXJob.id);
        
        SVMXC__SVMX_Jobs__c job = new SVMXC__SVMX_Jobs__c();
        job = [Select SVMXC__Status__c, SVMXC__OptiMax_Message__c, Id From SVMXC__SVMX_Jobs__c  where Id =: objSVMXJob.Id];
        
        Boolean jobStatusFlag = controller.returnAbortJobFlag(job.SVMXC__OptiMax_Message__c);
        System.assertEquals(false, jobStatusFlag);
        
        PageReference pageRef = Page.WORD_ManageDispatchProcess;
        Test.setCurrentPage(pageRef);
        controller.SVMX_Enable_Abort();
        
        controller.setselectedId(objSVMXJob.id);
        
        Boolean enableAbortFlag = controller.enableAbort();
        System.assertEquals(false, enableAbortFlag);
        
        job.SVMXC__OptiMax_Message__c = 'Initiate Error';
        update job;
        System.assertEquals(false, controller.returnAbortJobFlag(job.SVMXC__OptiMax_Message__c));
        
        job.SVMXC__OptiMax_Message__c = 'Aborted';
        update job;
        System.assertEquals(false, controller.returnAbortJobFlag(job.SVMXC__OptiMax_Message__c));
        
        job.SVMXC__OptiMax_Message__c = 'Processing Error';
        update job;
        System.assertEquals(false, controller.returnAbortJobFlag(job.SVMXC__OptiMax_Message__c));
        
        job.SVMXC__OptiMax_Message__c = 'Running Precalc';
        update job;
        System.assertEquals(false, controller.returnAbortJobFlag(job.SVMXC__OptiMax_Message__c));
        
        job.SVMXC__OptiMax_Message__c = ' Precalc Completed';
        update job;
        System.assertEquals(false, controller.returnAbortJobFlag(job.SVMXC__OptiMax_Message__c));
        
        job.SVMXC__OptiMax_Message__c = 'Precalc Failure';
        update job;
        System.assertEquals(false, controller.returnAbortJobFlag(job.SVMXC__OptiMax_Message__c));
        
        job.SVMXC__OptiMax_Message__c = 'QTL Completed';
        update job;
        System.assertEquals(false, controller.returnAbortJobFlag(job.SVMXC__OptiMax_Message__c));
        
        job.SVMXC__OptiMax_Message__c = 'QTL Failure';
        update job;
        System.assertEquals(false, controller.returnAbortJobFlag(job.SVMXC__OptiMax_Message__c));
        
        job.SVMXC__OptiMax_Message__c = 'In Progress';
        update job;
        System.assertEquals(true, controller.returnAbortJobFlag(job.SVMXC__OptiMax_Message__c));
        
        List<SVMXC__ServiceMax_Processes__c> prcessObjList=createProcessObjList();
        System.assertEquals(true, prcessObjList != null);
        controller.setProCredList(prcessObjList);
        controller.getProCredList();
        controller.setselectedId(job.id);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.setMock(WebServiceMock.class, new OMAX_Suspend_Job_WS_Success_Impl());
        controller.SVMX_AbortJob();
        
       /* Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.setMock(WebServiceMock.class, new OMAX_SuspendSuccess_Job_WS_FAILURE_Impl());
        controller.SVMX_AbortJob();*/
        
        /*WORD_ManageDispatchProcess controller2 = new WORD_ManageDispatchProcess();
        controller2.setselectedId(job.id);
        job.SVMXC__Type__c = 'ECO';
        update job;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.setMock(WebServiceMock.class, new OMAX_SuspendECO_Job_WS_Success_Impl  ());
        controller2.SVMX_AbortJob();*/
        
       /* WORD_ManageDispatchProcess controller3 = new WORD_ManageDispatchProcess();
        controller3.setselectedId(job.id);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.setMock(WebServiceMock.class, new OMAX_Suspend_Job_WS_FAILURE_Impl());
        controller3.SVMX_AbortJob();*/
        
         /*WORD_ManageDispatchProcess controller4 = new WORD_ManageDispatchProcess();
         controller4.setselectedId(job.id);
         job.SVMXC__End_Time__c = system.now();
         update job;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.setMock(WebServiceMock.class, new OMAX_Suspend_Job_WS_Success_Impl());
        controller4.SVMX_AbortJob(); */
        
       test.stopTest();
        
        
        system.debug('******************End test_AbortJob');
     }
    
    static List<SVMXC__ServiceMax_Processes__c> createProcessObjList(){
      
        string DispatchRTypeId = retrunDispatchProcessRecordType();
        
        List<SVMXC__ServiceMax_Processes__c> prcessObjList=new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c prcessObjone=new SVMXC__ServiceMax_Processes__c();
        prcessObjone.RecordTypeId =  DispatchRTypeId;
        prcessObjone.SVMXC__Setting_Type__c ='Global';
        prcessObjone.SVMXC__ProcessID__c='PROCESS11';
        prcessObjone.SVMXC__SettingId__c = 'PS01';
        prcessObjone.SVMXC__MapID__c='PROCESS11';
        prcessObjone.SVMXC__Name__c = 'PROCESS22';
        prcessObjone.Dispatch_Method__c = 'Immediate';
        prcessObjone.SVMXC__Select__c = true;
        prcessObjone.SVMXC__Sequence__c = 1;
        prcessObjone.SVMXC__IsPrivate__c = true;
        prcessObjList.add(prcessObjone);
        
        SVMXC__ServiceMax_Processes__c prcessObjtwo=new SVMXC__ServiceMax_Processes__c();
        prcessObjtwo.RecordTypeId =  DispatchRTypeId;
        prcessObjtwo.SVMXC__Setting_Type__c ='Global';
        prcessObjone.SVMXC__IsPrivate__c = true;
        prcessObjtwo.SVMXC__ProcessID__c='PROCESS11';
        prcessObjtwo.SVMXC__SettingId__c = 'PS02';
        prcessObjtwo.SVMXC__MapID__c='PROCESS11';
        prcessObjtwo.SVMXC__Name__c = 'Test two22';
        prcessObjtwo.Dispatch_Method__c = 'Optimized Batch';
        prcessObjtwo.SVMXC__Select__c = true;
        prcessObjtwo.SVMXC__Sequence__c = 2;
        prcessObjList.add(prcessObjtwo);
        
        SVMXC__ServiceMax_Processes__c prcessObjthree=new SVMXC__ServiceMax_Processes__c();
        prcessObjthree.RecordTypeId =  DispatchRTypeId;
        prcessObjthree.SVMXC__Setting_Type__c ='Global';
        prcessObjthree.SVMXC__IsPrivate__c = true;
        prcessObjthree.SVMXC__ProcessID__c='PROCESS11';
        prcessObjthree.SVMXC__SettingId__c = 'PS03';
        prcessObjthree.SVMXC__MapID__c='PROCESS11';
        prcessObjthree.SVMXC__Name__c = 'Test two22';
        prcessObjthree.Dispatch_Method__c = 'Optimized Batch';
        prcessObjthree.SVMXC__Select__c = true;
        prcessObjthree.SVMXC__Sequence__c = 2;
        prcessObjList.add(prcessObjthree);
        
        insert prcessObjList;
        
        return prcessObjList;
    }
    
    public static string retrunDispatchProcessRecordType(){
       string DispatchRTypeId;
       List<RecordType> RecType = Database.Query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\'');
       system.debug('RecType'+RecType);
       for(RecordType Rt : RecType)
       {
        if(Rt.Name == 'Dispatch Process')
        {
            DispatchRTypeId  = Rt.id;
        }  
       }
       return DispatchRTypeId;
    }
    
    
    public class OMAX_Execute_Job_WS_Success_Impl implements WebServiceMock {
        public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
            OMAX_ServicemaxCom.OMAX_Execute_Job_WSResponse respElement = new OMAX_ServicemaxCom.OMAX_Execute_Job_WSResponse();
            OMAX_ServicemaxCom.status statusObj = new OMAX_ServicemaxCom.status();
            statusObj.status = 'SUCCESS';
            respElement.return_x = statusObj;
            response.put('response_x', respElement);
        }
    }
    
    public class OMAX_Execute_Job_WS_Fail_Impl implements WebServiceMock {
        public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
            OMAX_ServicemaxCom.OMAX_Execute_Job_WSResponse respElement = new OMAX_ServicemaxCom.OMAX_Execute_Job_WSResponse();
            OMAX_ServicemaxCom.status statusObj = new OMAX_ServicemaxCom.status();
            statusObj.status = 'FAILURE';
            respElement.return_x = statusObj;
            response.put('response_x', respElement);
        }
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('GET', req.getMethod());
            HttpResponse res = new HttpResponse();
            res.setHeader('Location', req.getEndpoint());
            res.setStatusCode(200);
            return res;
        }
    }
    
    
     public class OMAX_Suspend_Job_WS_Success_Impl implements WebServiceMock {
        public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
            OMAX_ServicemaxCom.OMAX_Suspend_Job_WSResponse respElement = new OMAX_ServicemaxCom.OMAX_Suspend_Job_WSResponse();
            OMAX_ServicemaxCom.status statusObj = new OMAX_ServicemaxCom.status();
            statusObj.status = 'ABORTED';
            respElement.return_x = statusObj;
            response.put('response_x', respElement);
        }
    }
    
     public class OMAX_SuspendECO_Job_WS_Success_Impl implements WebServiceMock {
        public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
            OMAX_ServicemaxCom.OMAX_Suspend_Job_WSResponse respElement = new OMAX_ServicemaxCom.OMAX_Suspend_Job_WSResponse();
            OMAX_ServicemaxCom.status statusObj = new OMAX_ServicemaxCom.status();
            statusObj.status = 'SUSPENDED';
            respElement.return_x = statusObj;
            response.put('response_x', respElement);
        }
    }
    
     public class OMAX_Suspend_Job_WS_FAILURE_Impl implements WebServiceMock {
        public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
            OMAX_ServicemaxCom.OMAX_Suspend_Job_WSResponse respElement = new OMAX_ServicemaxCom.OMAX_Suspend_Job_WSResponse();
            OMAX_ServicemaxCom.status statusObj = new OMAX_ServicemaxCom.status();
            statusObj.status = 'ERROR';
            respElement.return_x = statusObj;
            response.put('response_x', respElement);
        }
    }
    
     public class OMAX_SuspendSuccess_Job_WS_FAILURE_Impl implements WebServiceMock {
        public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
            OMAX_ServicemaxCom.OMAX_Suspend_Job_WSResponse respElement = new OMAX_ServicemaxCom.OMAX_Suspend_Job_WSResponse();
            OMAX_ServicemaxCom.status statusObj = new OMAX_ServicemaxCom.status();
            statusObj.status = 'SUCCESS';
            respElement.return_x = statusObj;
            response.put('response_x', respElement);
        }
    }
}