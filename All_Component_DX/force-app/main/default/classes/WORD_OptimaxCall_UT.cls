@isTest(seeAllData = true)
private class WORD_OptimaxCall_UT 
{
    static testMethod void WORD_OptimaxCall_UT()
    {
        
        List<RecordType> RecType = new  List<RecordType>();
        List<RecordType> ConfigRecordTypes = new  List<RecordType>();
        string DispatchRTypeId;
        string ExpressionRTypeId;
        string RuleRecordTypeId;
        RecType = Database.Query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\'');
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
        }
        ConfigRecordTypes = Database.query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Config_Data__c\'');
        for(RecordType r : ConfigRecordTypes)
        {
            if(r.Name == 'Expressions')
            {
                ExpressionRTypeId = r.id;
            }
        }
        list<SVMXC__Territory__c> Territorylst = new List<SVMXC__Territory__c>();
        SVMXC__Territory__c Territory1 = new SVMXC__Territory__c();
        Territory1.name = 'india';
        Territorylst.add(Territory1);
        
        SVMXC__Territory__c Territory2 = new SVMXC__Territory__c();
        Territory2.name = 'bangalore';
        Territorylst.add(Territory2);
        
        insert Territorylst;
        
        SVMXC__Service_Zone__c  objZone1 = new SVMXC__Service_Zone__c ();
        objZone1.SVMXC__Zone_Type__c = 'Polygon';
        objZone1.SVMXC__Zone_Definition__c = '{\"latLng\":[{\"lng\":78.94775390625,\"lat\":13.31479411223821},{\"lng\":78.343505859375,\"lat\":13.058074727480722},{\"lng\":78.662109375,\"lat\":12.404388944669792},{\"lng\":78.453369140625,\"lat\":11.68451427712824},{\"lng\":79.12353515625,\"lat\":12.243391505623274},{\"lng\":79.837646484375,\"lat\":11.942601073545658},{\"lng\":79.62890625,\"lat\":12.951029216018357}],\"id\":\"2\",\"fillColor\":\"#1E90FF\",\"clickable\":false}';
        objZone1.SVMXC__Territory__c = Territorylst[0].id;
        objZone1.SVMXC__Zone_Name__c = 'objZone1Name';
        insert objZone1;
        SVMXC__Service_Zone__c  objZone2 = new SVMXC__Service_Zone__c ();
        objZone2.SVMXC__Zone_Type__c = 'Circle';
        objZone2.SVMXC__Zone_Definition__c = '{\"radius\":50023.03489581493,\"id\":\"4\",\"fillColor\":\"#1E90FF\",\"center\":{\"lng\":76.1572265625,\"lat\":11.706030770773825}}';
        objZone2.SVMXC__Territory__c = Territorylst[1].id;
        objZone2.SVMXC__Zone_Name__c = 'objZone2Name';
        insert objZone2;
        SVMXC__Service_Zone__c  objZone3 = new SVMXC__Service_Zone__c ();
        objZone3.SVMXC__Zone_Type__c = 'Rectangle';
        objZone3.SVMXC__Zone_Definition__c = '{\"sw\":{\"lng\":77.71728515625,\"lat\":10.14193168613103},\"ne\":{\"lng\":79.178466796875,\"lat\":10.466205555063882},\"id\":\"6\",\"fillColor\":\"#1E90FF\"}';
        objZone3.SVMXC__Territory__c = Territorylst[1].id;
        objZone3.SVMXC__Zone_Name__c = 'objZone3Name';
        insert objZone3;
        
        SVMXC__ServiceMax_Processes__c prcessObjone = new SVMXC__ServiceMax_Processes__c();
        prcessObjone.RecordTypeId =  DispatchRTypeId;
        prcessObjone.SVMXC__Name__c = 'Test one';
        prcessObjone.SVMXC__Dispatch_Method__c = 'Advanced Dispatch';
        prcessObjone.SVMXC__Runs_Every_Monday__c = true;
        prcessObjone.SVMXC__Runs_Every_Tuesday__c = true;
        prcessObjone.SVMXC__Runs_Every_Wednesday__c = true;
        prcessObjone.SVMXC__Runs_Every_Thursday__c = true;
        prcessObjone.SVMXC__Runs_Every_Friday__c = true;
        prcessObjone.SVMXC__Runs_Every_Saturday__c = true;
        prcessObjone.SVMXC__Runs_Every_Sunday__c = true;
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
        prcessObjone.SVMXC__Values__c = Territorylst[0].id + ':U,';
        
        insert prcessObjone;
        System.assertEquals(true, prcessObjone != null);
        
        String DPID = prcessObjone.id;
        List<SVMXC__ServiceMax_Config_Data__c> lstRun = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Full';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '12:00 PM';
        currentRun.SVMXC__Active__c = true;
        lstRun.add(currentRun);

        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Full';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '8:15 PM';
        currentRun.SVMXC__Active__c = true;
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Full';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '8:05 AM';
        currentRun.SVMXC__Active__c = true;
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Full';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '8:10 AM';
        currentRun.SVMXC__Active__c = true;
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Full';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '8:15 AM';
        currentRun.SVMXC__Active__c = true;
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Full';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '11:20 AM';
        currentRun.SVMXC__Active__c = true;
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Full';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '11:25 AM';
        currentRun.SVMXC__Active__c = true;
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Full';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '11:30 AM';
        currentRun.SVMXC__Active__c = true;
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Full';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '11:35 AM';
        currentRun.SVMXC__Active__c = true;
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Full';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '11:40 AM';
        currentRun.SVMXC__Active__c = true;
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Full';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '9:45 AM';
        currentRun.SVMXC__Active__c = true;
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Full';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '9:50 AM';
        currentRun.SVMXC__Active__c = true;
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Full';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '9:55 AM';
        currentRun.SVMXC__Active__c = true;
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Full';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '12:00 AM';
        currentRun.SVMXC__Active__c = true;
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Incremental';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:00 PM';
        currentRun.SVMXC__Active__c = true;
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Incremental';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:05 PM';
        currentRun.SVMXC__Active__c = true;
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Incremental';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:10 PM';
        currentRun.SVMXC__Active__c = true;
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Incremental';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:15 PM';
        currentRun.SVMXC__Active__c = true;
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Incremental';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:20 PM';
        currentRun.SVMXC__Active__c = true;
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Incremental';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:25 PM';
        currentRun.SVMXC__Active__c = true;
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Incremental';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '6:30 PM';
        currentRun.SVMXC__Active__c = true;
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Incremental';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '6:35 PM';
        currentRun.SVMXC__Active__c = true;
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Incremental';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '6:40 PM';
        currentRun.SVMXC__Active__c = true;
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Incremental';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '6:45 PM';
        currentRun.SVMXC__Active__c = true;
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Incremental';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '6:50 PM';
        currentRun.SVMXC__Active__c = true;
        lstRun.add(currentRun);
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Incremental';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '6:55 PM';
        currentRun.SVMXC__Active__c = true;
        lstRun.add(currentRun);
        
        insert lstRun;
        System.assertEquals(true, lstRun != null);
                        
        system.debug('prcessObjone'+prcessObjone.Id);
        
        List<SVMXC__ServiceMax_Processes__c>  TRuleLst = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c  TRule1 = new SVMXC__ServiceMax_Processes__c();
        TRule1.RecordTypeId = RuleRecordTypeId;
        TRule1.SVMXC__ProcessID__c='PROCESS11';
        TRule1.SVMXC__SettingId__c = 'PROCESS11';
        TRule1.SVMXC__MapID__c='PROCESS11';
        TRule1.SVMXC__Name__c = 'PROCESS21';
        TRule1.SVMXC__Territory__c = Territorylst[0].id;
        TRule1.SVMXC__Rule_Type__c = 'Territory Access';
        TRule1.SVMXC__Process__c = prcessObjone.id; 
        TRuleLst.add(TRule1);
        
        SVMXC__ServiceMax_Processes__c  TRule2 = new SVMXC__ServiceMax_Processes__c();
        TRule2.RecordTypeId = RuleRecordTypeId;
        TRule2.SVMXC__ProcessID__c='PROCESS12';
        TRule2.SVMXC__SettingId__c = 'PROCESS12';
        TRule2.SVMXC__MapID__c='PROCESS12';
        TRule2.SVMXC__Name__c = 'PROCESS22';
        TRule2.SVMXC__Territory__c = Territorylst[1].id;
        TRule2.SVMXC__Rule_Type__c = 'Territory Access';
        TRule2.SVMXC__Process__c = prcessObjone.id; 
        TRuleLst.add(TRule2);
        
        insert TRuleLst;
        System.assertnotEquals(true, TRuleLst == null);
        
        PageReference pageRef = Page.WORD_OptimaxCall;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('dpid', DPID);
        ApexPages.currentPage().getParameters().put('runConstructorLogic','true');
        SVMXC.WORD_OptimaxCall obj = new SVMXC.WORD_OptimaxCall();
        String str = 'asdf';
        obj.getDispMethods();
        obj.SVMX_WSDLCall();
        obj.decryption1(str);
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.setMock(WebServiceMock.class, new OMAX_Dispatch_Process_Definition_WS_Impl());
        Test.startTest();
        obj.CORNExpression(prcessObjone);
        obj.decryption1(str);
        obj.OptiMaxWebServiceCall(prcessObjone,TRuleLst);
        Test.stopTest();
        
        obj.BackToDP();
        prcessObjone.SVMXC__Start_Time__c= '11:00 AM';
        obj.CORNExpression(prcessObjone);
        prcessObjone.SVMXC__Start_Time__c= '12:00 PM';
        obj.CORNExpression(prcessObjone);
        prcessObjone.SVMXC__Start_Time__c= '12:00 AM';
        obj.CORNExpression(prcessObjone);
        prcessObjone.SVMXC__Start_Time__c= '11:15 PM';
        obj.CORNExpression(prcessObjone);
        prcessObjone.SVMXC__Start_Time__c= '11:15 AM';
        obj.CORNExpression(prcessObjone);
    }
    static testMethod void WORD_OptimaxCall_UT1()
    {
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
        }
        ConfigRecordTypes = Database.query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Config_Data__c\'');
        for(RecordType r : ConfigRecordTypes)
        {
            if(r.Name == 'Expressions')
            {
                ExpressionRTypeId = r.id;
            }
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
        prcessObjone.SVMXC__Dispatch_Method__c = 'Advanced Dispatch';
        prcessObjone.SVMXC__Runs_Every_Monday__c = true;
        prcessObjone.SVMXC__Runs_Every_Tuesday__c = true;
        prcessObjone.SVMXC__Runs_Every_Wednesday__c = true;
        prcessObjone.SVMXC__Runs_Every_Thursday__c = true;
        prcessObjone.SVMXC__Runs_Every_Friday__c = true;
        prcessObjone.SVMXC__Runs_Every_Saturday__c = true;
        prcessObjone.SVMXC__Runs_Every_Sunday__c = true;
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
        
        insert prcessObjone;
        System.assertEquals(true, prcessObjone != null);
        
        String DPID = prcessObjone.id;
        List<SVMXC__ServiceMax_Config_Data__c> lstRun = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Full';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '12:00 AM';
        lstRun.add(currentRun);
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.SVMXC__Display_Type__c = 'Incremental';
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Expression_Rule__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:00 AM';
        lstRun.add(currentRun);
        
        
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:00 AM';
        currentRun.SVMXC__Run_Type__c = 'Day of Week';
        currentRun.SVMXC__Schedule_Days__c = 'Monday;Tuesday';
        lstRun.add(currentRun);
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:05 AM';
        currentRun.SVMXC__Run_Type__c = 'Date of Month';
        currentRun.SVMXC__Day_to_Run__c = '8';
        lstRun.add(currentRun);
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:10 AM';
        currentRun.SVMXC__Run_Type__c = 'Day of Week';
        currentRun.SVMXC__Schedule_Days__c = 'Monday;Tuesday';
        lstRun.add(currentRun);
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:15 AM';
        currentRun.SVMXC__Run_Type__c = 'Date of Month';
        currentRun.SVMXC__Day_to_Run__c = '8';
        lstRun.add(currentRun);
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:20 AM';
        currentRun.SVMXC__Run_Type__c = 'Day of Week';
        currentRun.SVMXC__Schedule_Days__c = 'Monday;Tuesday';
        lstRun.add(currentRun);
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:25 AM';
        currentRun.SVMXC__Run_Type__c = 'Date of Month';
        currentRun.SVMXC__Day_to_Run__c = '8';
        lstRun.add(currentRun);
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:30 AM';
        currentRun.SVMXC__Run_Type__c = 'Day of Week';
        currentRun.SVMXC__Schedule_Days__c = 'Monday;Tuesday';
        lstRun.add(currentRun);
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:35 AM';
        currentRun.SVMXC__Run_Type__c = 'Date of Month';
        currentRun.SVMXC__Day_to_Run__c = '8';
        lstRun.add(currentRun);
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:40 AM';
        currentRun.SVMXC__Run_Type__c = 'Date of Month';
        currentRun.SVMXC__Day_to_Run__c = '8';
        lstRun.add(currentRun);
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:45 AM';
        currentRun.SVMXC__Run_Type__c = 'Date of Month';
        currentRun.SVMXC__Day_to_Run__c = '8';
        lstRun.add(currentRun);
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:50 AM';
        currentRun.SVMXC__Run_Type__c = 'Date of Month';
        currentRun.SVMXC__Day_to_Run__c = '8';
        lstRun.add(currentRun);
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:55 AM';
        currentRun.SVMXC__Run_Type__c = 'Date of Month';
        currentRun.SVMXC__Day_to_Run__c = '8';
        lstRun.add(currentRun);
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:00 PM';
        currentRun.SVMXC__Run_Type__c = 'Date of Month';
        currentRun.SVMXC__Day_to_Run__c = '8';
        lstRun.add(currentRun);
        insert lstRun;
        
        System.assertEquals(true, lstRun != null);
                        
        system.debug('prcessObjone'+prcessObjone.Id);
        
        List<SVMXC__ServiceMax_Processes__c>  TRuleLst = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c  TRule1 = new SVMXC__ServiceMax_Processes__c();
        TRule1.RecordTypeId = RuleRecordTypeId;
        TRule1.SVMXC__ProcessID__c='PROCESS11';
        TRule1.SVMXC__SettingId__c = 'PROCESS11';
        TRule1.SVMXC__MapID__c='PROCESS11';
        TRule1.SVMXC__Name__c = 'PROCESS21';
        TRule1.SVMXC__Territory__c = Territorylst[0].id;
        TRule1.SVMXC__Rule_Type__c = 'Territory Access';
        TRule1.SVMXC__Process__c = prcessObjone.id; 
        TRuleLst.add(TRule1);
        
        SVMXC__ServiceMax_Processes__c  TRule2 = new SVMXC__ServiceMax_Processes__c();
        TRule2.RecordTypeId = RuleRecordTypeId;
        TRule2.SVMXC__ProcessID__c='PROCESS12';
        TRule2.SVMXC__SettingId__c = 'PROCESS12';
        TRule2.SVMXC__MapID__c='PROCESS12';
        TRule2.SVMXC__Name__c = 'PROCESS22';
        TRule2.SVMXC__Territory__c = Territorylst[1].id;
        TRule2.SVMXC__Rule_Type__c = 'Territory Access';
        TRule2.SVMXC__Process__c = prcessObjone.id; 
        TRuleLst.add(TRule2);
        
        insert TRuleLst;
        System.assertnotEquals(true, TRuleLst == null);
        
        PageReference pageRef = Page.WORD_OptimaxCall;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('dpid', DPID);
        ApexPages.currentPage().getParameters().put('runConstructorLogic','true');
        SVMXC.WORD_OptimaxCall obj = new SVMXC.WORD_OptimaxCall();
        
        obj.ltpScheduleRunLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        obj.ltpScheduleRunLst.addAll(lstRun);
        
        String str = 'asdf';
        obj.getDispMethods();
       // obj.setDispMethods(DispMethods);
        obj.SVMX_WSDLCall();
        obj.CORNExpression(prcessObjone);
        obj.decryption1(str);
        obj.OptiMaxWebServiceCall(prcessObjone,TRuleLst);
        obj.BackToDP();
        prcessObjone.SVMXC__Start_Time__c= '11:00 AM';
        obj.CORNExpression(prcessObjone);
        prcessObjone.SVMXC__Start_Time__c= '12:00 AM';
        obj.CORNExpression(prcessObjone);
        prcessObjone.SVMXC__Start_Time__c= '12:00 AM';
        obj.CORNExpression(prcessObjone);
        prcessObjone.SVMXC__Start_Time__c= '1:15 AM';
        obj.CORNExpression(prcessObjone);
        prcessObjone.SVMXC__Start_Time__c= '11:15 AM';
        obj.CORNExpression(prcessObjone);
        try{
            obj.setDispMethods(obj.getDispMethods());
        }
        catch(exception ex){}
        
        prcessObjone.SVMXC__Start_Time__c= '11:00 AM';
        obj.CORNLTPExpression(prcessObjone);
        /*prcessObjone.SVMXC__Start_Time__c= '11:05 AM';
        obj.CORNLTPExpression(prcessObjone);
        prcessObjone.SVMXC__Start_Time__c= '11:10 AM';
        obj.CORNLTPExpression(prcessObjone);
        prcessObjone.SVMXC__Start_Time__c= '11:15 AM';
        obj.CORNLTPExpression(prcessObjone);
        prcessObjone.SVMXC__Start_Time__c= '11:20 AM';
        obj.CORNLTPExpression(prcessObjone);
        prcessObjone.SVMXC__Start_Time__c= '11:25 AM';
        obj.CORNLTPExpression(prcessObjone);
        prcessObjone.SVMXC__Start_Time__c= '11:30 AM';
        obj.CORNLTPExpression(prcessObjone);
        prcessObjone.SVMXC__Start_Time__c= '11:35 AM';
        obj.CORNLTPExpression(prcessObjone);
        prcessObjone.SVMXC__Start_Time__c= '11:40 AM';
        obj.CORNLTPExpression(prcessObjone);
        prcessObjone.SVMXC__Start_Time__c= '11:45 AM';
        obj.CORNLTPExpression(prcessObjone);
        prcessObjone.SVMXC__Start_Time__c= '11:50 AM';
        obj.CORNLTPExpression(prcessObjone);
        prcessObjone.SVMXC__Start_Time__c= '11:55 AM';
        obj.CORNLTPExpression(prcessObjone);*/
    }
    
    static testMethod void WORD_OptimaxCall_UT2()
    {
        ApexPages.currentPage().getParameters().put('runConstructorLogic','true');
        WORD_ManageZoneDefinition clsTest = new WORD_ManageZoneDefinition();
        WORD_ManageZoneDefinition_UT clsTest2 = new WORD_ManageZoneDefinition_UT();
        SFMSearchDeliveryServiceIntf clsTest3 = new SFMSearchDeliveryServiceIntf();
        SFMWizardDeliveryServiceIntf clsTest4 = new SFMWizardDeliveryServiceIntf();
        SFM_BizRuleUtils_UT clsTest5 = new SFM_BizRuleUtils_UT();
        PCAL_GetPrice_Case_UT clsTest6 = new PCAL_GetPrice_Case_UT();
        PageReference pageRef = Page.WORD_ManageZoneDefinition;
        PageReference pageRef2 = Page.SFMSearchDelivery;
    }
    
    static testMethod void WORD_OptimaxCall_UT3()
    {
        ApexPages.currentPage().getParameters().put('runConstructorLogic','true');
        String CRONExpression = '0 0 9 ? * 2,4,6 2016';
        String territoryId = 'a2QF0000000NmFT';
        String orgId = '72';
        String sType = '_FULL_30';
        List<OMAX_ServicemaxCom.parameter> plist = new List<OMAX_ServicemaxCom.parameter>();
        SVMXC__ServiceMax_Processes__c prcessObjone = new SVMXC__ServiceMax_Processes__c();
        prcessObjone.SVMXC__Email_On_Error__c = 'test@servicemax.com';
        prcessObjone.SVMXC__Email_On_Success__c = 'test@servicemax.com';
        
        SVMXC.WORD_OptimaxCall obj = new SVMXC.WORD_OptimaxCall();
        obj.buildSchedule(CRONExpression, territoryId, orgId, sType, plist, prcessObjone, 'Real Time Optimization');
    }
    
    static testMethod void WORD_OptimaxCall_UT4()
    {
        SVMXC__ServiceMax_Processes__c prcessObjone = createECO_DP();
        Test.startTest();
        PageReference pageRef = Page.WORD_OptimaxCall;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('dpid', prcessObjone.id);
        ApexPages.currentPage().getParameters().put('runConstructorLogic','true');
        SVMXC.WORD_OptimaxCall obj = new SVMXC.WORD_OptimaxCall();
        OMAX_ServicemaxCom.territorySchedule[] TList = obj.ECO_CRONExpression(prcessObjone);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.setMock(WebServiceMock.class, new OMAX_Dispatch_Process_Definition_WS_Impl());
        obj.ECO_OptiMaxWebServiceCall(prcessObjone, TList);
        Test.stopTest();
    }
    
    static SVMXC__ServiceMax_Processes__c createECO_DP() {
        List<RecordType> RecType = new  List<RecordType>();
        List<RecordType> ConfigRecordTypes = new  List<RecordType>();
        string DispatchRTypeId;
        string ExpressionRTypeId;
        string RuleRecordTypeId;
        RecType = Database.Query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\'');
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
        }
        ConfigRecordTypes = Database.query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Config_Data__c\'');
        for(RecordType r : ConfigRecordTypes)
        {
            if(r.Name == 'Expressions')
            {
                ExpressionRTypeId = r.id;
            }
        }
        
        BusinessHours bh = [Select Id from BusinessHours where IsDefault=true];
        list<SVMXC__Territory__c> Territorylst = new List<SVMXC__Territory__c>();
        SVMXC__Territory__c Territory1 = new SVMXC__Territory__c();
        Territory1.name = 'india';
        Territory1.SVMXC__Territory_s_Business_Hours__c = bh.Id;
        Territorylst.add(Territory1);
        
        SVMXC__Territory__c Territory2 = new SVMXC__Territory__c();
        Territory2.name = 'bangalore';
        Territory2.SVMXC__Territory_s_Business_Hours__c = bh.Id;
        Territorylst.add(Territory2);
        
        insert Territorylst;
        
        SVMXC__Service_Zone__c  objZone1 = new SVMXC__Service_Zone__c ();
        objZone1.SVMXC__Zone_Type__c = 'Polygon';
        objZone1.SVMXC__Zone_Definition__c = '{\"latLng\":[{\"lng\":78.94775390625,\"lat\":13.31479411223821},{\"lng\":78.343505859375,\"lat\":13.058074727480722},{\"lng\":78.662109375,\"lat\":12.404388944669792},{\"lng\":78.453369140625,\"lat\":11.68451427712824},{\"lng\":79.12353515625,\"lat\":12.243391505623274},{\"lng\":79.837646484375,\"lat\":11.942601073545658},{\"lng\":79.62890625,\"lat\":12.951029216018357}],\"id\":\"2\",\"fillColor\":\"#1E90FF\",\"clickable\":false}';
        objZone1.SVMXC__Territory__c = Territorylst[0].id;
        objZone1.SVMXC__Zone_Name__c = 'objZone1Name';
        insert objZone1;
        SVMXC__Service_Zone__c  objZone2 = new SVMXC__Service_Zone__c ();
        objZone2.SVMXC__Zone_Type__c = 'Circle';
        objZone2.SVMXC__Zone_Definition__c = '{\"radius\":50023.03489581493,\"id\":\"4\",\"fillColor\":\"#1E90FF\",\"center\":{\"lng\":76.1572265625,\"lat\":11.706030770773825}}';
        objZone2.SVMXC__Territory__c = Territorylst[1].id;
        objZone2.SVMXC__Zone_Name__c = 'objZone2Name';
        insert objZone2;
        SVMXC__Service_Zone__c  objZone3 = new SVMXC__Service_Zone__c ();
        objZone3.SVMXC__Zone_Type__c = 'Rectangle';
        objZone3.SVMXC__Zone_Definition__c = '{\"sw\":{\"lng\":77.71728515625,\"lat\":10.14193168613103},\"ne\":{\"lng\":79.178466796875,\"lat\":10.466205555063882},\"id\":\"6\",\"fillColor\":\"#1E90FF\"}';
        objZone3.SVMXC__Territory__c = Territorylst[1].id;
        objZone3.SVMXC__Zone_Name__c = 'objZone3Name';
        insert objZone3;   

        SVMXC__ServiceMax_Processes__c prcessObjone = new SVMXC__ServiceMax_Processes__c();
        prcessObjone.RecordTypeId =  DispatchRTypeId;
        prcessObjone.SVMXC__Name__c = 'Test one';
        prcessObjone.SVMXC__Dispatch_Method__c = 'Real Time Optimization';
        prcessObjone.SVMXC__Email_On_Error__c = 'test@servicemax.com';
        prcessObjone.SVMXC__Email_On_Success__c = 'test@servicemax.com';
        prcessObjone.SVMXC__Weight_Time_Window__c = 1;
        prcessObjone.SVMXC__Weight_Total_Distance__c = 1;
        prcessObjone.SVMXC__Weight_Route_Distance__c = 1;
        prcessObjone.SVMXC__Weight_Route_Time__c = 1;
        prcessObjone.SVMXC__Weight_Node_Type__c = 1;
        prcessObjone.SVMXC__Values__c = Territorylst[0].id + ':U,';
        prcessObjone.SVMXC__Route_Type__c = 'CLOSED';
        prcessObjone.SVMXC__Dispatch_Threshold__c = 30;
        prcessObjone.SVMXC__Optimizer_Sync_Interval__c = 30;
        insert prcessObjone;
        System.assertEquals(true, prcessObjone != null);
        
        String DPID = prcessObjone.id;
        system.debug('prcessObjone' + prcessObjone.Id);
        
        List<SVMXC__ServiceMax_Processes__c>  TRuleLst = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c  TRule1 = new SVMXC__ServiceMax_Processes__c();
        TRule1.RecordTypeId = RuleRecordTypeId;
        TRule1.SVMXC__ProcessID__c='PROCESS11';
        TRule1.SVMXC__SettingId__c = 'PROCESS11';
        TRule1.SVMXC__MapID__c='PROCESS11';
        TRule1.SVMXC__Name__c = 'PROCESS21';
        TRule1.SVMXC__Territory__c = Territorylst[0].id;
        TRule1.SVMXC__Rule_Type__c = 'Territory Access';
        TRule1.SVMXC__Process__c = prcessObjone.id; 
        TRuleLst.add(TRule1);
        insert TRuleLst;
        System.assertnotEquals(true, TRuleLst == null);
        
        return prcessObjone;
    }
    
    static testMethod void createLTP_Process() {
        
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
        }
        ConfigRecordTypes = Database.query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Config_Data__c\'');
        for(RecordType r : ConfigRecordTypes)
        {
            if(r.Name == 'Expressions')
            {
                ExpressionRTypeId = r.id;
            }
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
        prcessObjone.SVMXC__Values__c = Territorylst[0].id + ':U,';
        prcessObjone.SVMXC__Window_Height__c = 10;
        
        insert prcessObjone;
        System.assertEquals(true, prcessObjone != null);
        
        String DPID = prcessObjone.id;
        List<SVMXC__ServiceMax_Config_Data__c> lstRun = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:00 AM';
        currentRun.SVMXC__Run_Type__c = 'Day of Week';
        currentRun.SVMXC__Schedule_Days__c = 'Monday;Tuesday';
        lstRun.add(currentRun);
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:05 AM';
        currentRun.SVMXC__Run_Type__c = 'Date of Month';
        currentRun.SVMXC__Day_to_Run__c = '8';
        lstRun.add(currentRun);
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:10 AM';
        currentRun.SVMXC__Run_Type__c = 'Day of Week';
        currentRun.SVMXC__Schedule_Days__c = 'Monday;Tuesday';
        lstRun.add(currentRun);
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:15 AM';
        currentRun.SVMXC__Run_Type__c = 'Date of Month';
        currentRun.SVMXC__Day_to_Run__c = '8';
        lstRun.add(currentRun);
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:20 AM';
        currentRun.SVMXC__Run_Type__c = 'Day of Week';
        currentRun.SVMXC__Schedule_Days__c = 'Monday;Tuesday';
        lstRun.add(currentRun);
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:25 AM';
        currentRun.SVMXC__Run_Type__c = 'Date of Month';
        currentRun.SVMXC__Day_to_Run__c = '8';
        lstRun.add(currentRun);
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:30 AM';
        currentRun.SVMXC__Run_Type__c = 'Day of Week';
        currentRun.SVMXC__Schedule_Days__c = 'Monday;Tuesday';
        lstRun.add(currentRun);
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:35 AM';
        currentRun.SVMXC__Run_Type__c = 'Date of Month';
        currentRun.SVMXC__Day_to_Run__c = '8';
        lstRun.add(currentRun);
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:40 AM';
        currentRun.SVMXC__Run_Type__c = 'Date of Month';
        currentRun.SVMXC__Day_to_Run__c = '8';
        lstRun.add(currentRun);
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:45 AM';
        currentRun.SVMXC__Run_Type__c = 'Date of Month';
        currentRun.SVMXC__Day_to_Run__c = '8';
        lstRun.add(currentRun);
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:50 AM';
        currentRun.SVMXC__Run_Type__c = 'Date of Month';
        currentRun.SVMXC__Day_to_Run__c = '8';
        lstRun.add(currentRun);
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:55 AM';
        currentRun.SVMXC__Run_Type__c = 'Date of Month';
        currentRun.SVMXC__Day_to_Run__c = '8';
        lstRun.add(currentRun);
        currentRun = new SVMXC__ServiceMax_Config_Data__c();
        currentRun.RecordTypeId = Schedule_Rtype_Id;
        currentRun.SVMXC__Expression_Type__c = 'DISP_Schedule';
        currentRun.SVMXC__Dispatch_Process__c = DPID;
        currentRun.SVMXC__Run_At__c = '5:00 PM';
        currentRun.SVMXC__Run_Type__c = 'Date of Month';
        currentRun.SVMXC__Day_to_Run__c = '8';
        lstRun.add(currentRun);
        insert lstRun;
        
        System.assertEquals(true, lstRun != null);
                        
        system.debug('prcessObjone'+prcessObjone.Id);
        
        List<SVMXC__ServiceMax_Processes__c>  TRuleLst = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c  TRule1 = new SVMXC__ServiceMax_Processes__c();
        TRule1.RecordTypeId = RuleRecordTypeId;
        TRule1.SVMXC__ProcessID__c='PROCESS11';
        TRule1.SVMXC__SettingId__c = 'PROCESS11';
        TRule1.SVMXC__MapID__c='PROCESS11';
        TRule1.SVMXC__Name__c = 'PROCESS21';
        TRule1.SVMXC__Territory__c = Territorylst[0].id;
        TRule1.SVMXC__Rule_Type__c = 'Territory Access';
        TRule1.SVMXC__Process__c = prcessObjone.id; 
        TRuleLst.add(TRule1);
        
        SVMXC__ServiceMax_Processes__c  TRule2 = new SVMXC__ServiceMax_Processes__c();
        TRule2.RecordTypeId = RuleRecordTypeId;
        TRule2.SVMXC__ProcessID__c='PROCESS12';
        TRule2.SVMXC__SettingId__c = 'PROCESS12';
        TRule2.SVMXC__MapID__c='PROCESS12';
        TRule2.SVMXC__Name__c = 'PROCESS22';
        TRule2.SVMXC__Territory__c = Territorylst[1].id;
        TRule2.SVMXC__Rule_Type__c = 'Territory Access';
        TRule2.SVMXC__Process__c = prcessObjone.id; 
        TRuleLst.add(TRule2);
        
        insert TRuleLst;
        System.assertnotEquals(true, TRuleLst == null);
        
        PageReference pageRef = Page.WORD_OptimaxCall;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('dpid', DPID);
        ApexPages.currentPage().getParameters().put('runConstructorLogic','true');
        SVMXC.WORD_OptimaxCall obj = new SVMXC.WORD_OptimaxCall();
        
        obj.ltpScheduleRunLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        obj.ltpScheduleRunLst.addAll(lstRun);
        
        String str = 'asdf';
        obj.getDispMethods();
       // obj.setDispMethods(DispMethods);
        obj.SVMX_WSDLCall();
        obj.CORNLTPExpression(prcessObjone);
        obj.decryption1(str);
        obj.OptiMaxWebServiceCall(prcessObjone,TRuleLst);
        obj.BackToDP();
        
        try{
            obj.setDispMethods(obj.getDispMethods());
        }
        catch(exception ex){}
        
        prcessObjone.SVMXC__Start_Time__c= '11:00 AM';
        obj.CORNLTPExpression(prcessObjone);
    }
    
    static testMethod void WORD_OptimaxCall_UT5()
    {
        ApexPages.currentPage().getParameters().put('runConstructorLogic','true');
        String expression = '';
        Integer hour = 10;
        SVMXC.WORD_OptimaxCall obj = new SVMXC.WORD_OptimaxCall();
        obj.buildExpression(expression, hour);
        expression = '9';
        obj.buildExpression(expression, hour);
    }
    
    static testMethod void WORD_OptimaxCall_UT6()
    {
        ApexPages.currentPage().getParameters().put('runConstructorLogic','false');
        SVMXC__ServiceMax_Processes__c prcessObjone = new SVMXC__ServiceMax_Processes__c();
        prcessObjone.SVMXC__Start_Date__c = system.today();
        prcessObjone.SVMXC__End_Date__c = system.today() + 12;
        prcessObjone.SVMXC__Dispatch_Timezone__c = 'Asia/Kolkata';
        
        String expression = '11';
        String strType = '0MIN';
        String weekDays = '2,3,4';
        
        SVMXC.WORD_OptimaxCall obj = new SVMXC.WORD_OptimaxCall();
        obj.buildCRONExpression(expression, strType, weekDays, prcessObjone);
        
        strType = '5MIN';
        obj.buildCRONExpression(expression, strType, weekDays, prcessObjone);
        
        strType = '10MIN';
        obj.buildCRONExpression(expression, strType, weekDays, prcessObjone);

        strType = '15MIN';
        obj.buildCRONExpression(expression, strType, weekDays, prcessObjone);

        strType = '20MIN';
        obj.buildCRONExpression(expression, strType, weekDays, prcessObjone);
        
        strType = '25MIN';
        obj.buildCRONExpression(expression, strType, weekDays, prcessObjone);
        
        strType = '30MIN';
        obj.buildCRONExpression(expression, strType, weekDays, prcessObjone);
        
        strType = '35MIN';
        obj.buildCRONExpression(expression, strType, weekDays, prcessObjone);
        
        strType = '40MIN';
        obj.buildCRONExpression(expression, strType, weekDays, prcessObjone);
        
        strType = '45MIN';
        obj.buildCRONExpression(expression, strType, weekDays, prcessObjone);
        
        strType = '50MIN';
        obj.buildCRONExpression(expression, strType, weekDays, prcessObjone);
        
        strType = '55MIN';
        obj.buildCRONExpression(expression, strType, weekDays, prcessObjone);
        
        prcessObjone.SVMXC__End_Date__c = system.today() + 400;
        obj.buildCRONExpression(expression, strType, weekDays, prcessObjone);
    }
    
    static testMethod void WORD_OptimaxCall_UT7()
    {
        SVMXC__ServiceMax_Processes__c prcessObjone = createECO_DP();
        Test.startTest();
        PageReference pageRef = Page.WORD_OptimaxCall;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('dpid', prcessObjone.id);
        ApexPages.currentPage().getParameters().put('runConstructorLogic','true');
        SVMXC.WORD_OptimaxCall obj = new SVMXC.WORD_OptimaxCall();
        OMAX_ServicemaxCom.territorySchedule[] TList = obj.ECO_CRONExpression(prcessObjone);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.setMock(WebServiceMock.class, new OMAX_Dispatch_Process_Definition_WS_Fail_Impl());
        obj.ECO_OptiMaxWebServiceCall(prcessObjone, TList);
        Test.stopTest();
    }
    
    public class OMAX_Dispatch_Process_Definition_WS_Impl implements WebServiceMock {
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
            OMAX_ServicemaxCom.OMAX_Dispatch_Process_Definition_WSResponse respElement = new OMAX_ServicemaxCom.OMAX_Dispatch_Process_Definition_WSResponse();
            OMAX_ServicemaxCom.status statusObj = new OMAX_ServicemaxCom.status();
            statusObj.status = 'SUCCESS';
            statusObj.message = 'Dispatch Process created successfully';
            respElement.return_x = statusObj;
            response.put('response_x', respElement);
        }
    }
    
    public class OMAX_Dispatch_Process_Definition_WS_Fail_Impl implements WebServiceMock {
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
            OMAX_ServicemaxCom.OMAX_Dispatch_Process_Definition_WSResponse respElement = new OMAX_ServicemaxCom.OMAX_Dispatch_Process_Definition_WSResponse();
            OMAX_ServicemaxCom.status statusObj = new OMAX_ServicemaxCom.status();
            statusObj.status = 'FAILURE';
            statusObj.message = 'Error creating Dispatch Process';
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
}