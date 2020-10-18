@isTest(SeeAllData=true)
public with sharing class WSCH_Provider_SP_RealTimeOptimizer_UT {

    static testMethod void AllTestCase(){
       //Test.startTest();

        String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
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

        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        svmxprocess.SVMXC__Name__c = 'Linx for ServicePower 1';
        svmxprocess.RecordTypeId = DispatchProRecordTypeId;
        svmxprocess.SVMXC__Dispatch_Process_Status__c='Complete';
        svmxprocess.SVMXC__Dispatch_Method__c='Linx for ServicePower';
        insert svmxprocess;

        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c='Open';
        oConf.SVMXC__Operator__c='eq';
        oConf.RecordTypeId = ExpressionRTypeId;
        oConf.SVMXC__Sequence__c=1;
        oConf.SVMXC__Expression_Rule__c = svmxprocess.id;
        insert oConf;

        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.name = 'South Central Region';
        territory.SVMXC__Optimizer_External_ID__c = 'SOU';
        territory.SVMXC__Optimizer_Last_Timestamp__c='';
        insert territory;

        SVMXC__Territory__c territory1 = new SVMXC__Territory__c();
        territory1.name = 'UK Region';
        territory1.SVMXC__Optimizer_External_ID__c = 'UK01';
        territory1.SVMXC__Optimizer_Last_Timestamp__c='';
        insert territory1;

        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrder.SVMXC__Zip__c = '75001';
        workOrder.SVMXC__Order_Status__c='Open';
        workOrder.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder.SVMXC__Locked_By_DC__c = false;
        workOrder.SVMXC__Service_Duration__c = 60;
        workOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CREATE_WO';
        workOrder.SVMXC__OptiMax_Status__c='Tentative';
        workOrder.SVMXC__Primary_Territory__c=territory.Id;
        workOrder.SVMXC__Acknowledged_By_Technician_Date_Time__c=Datetime.now();
        workOrder.SVMXC__Started_Driving_To_Location_Date_Time__c=Datetime.now();
        workOrder.SVMXC__Actual_Onsite_Response__c=Datetime.now();
        workOrder.SVMXC__Finished_Onsite_Date_Time__c=Datetime.now();

        WSCH_Provider_SP_RealTimeOptimizer rto= new WSCH_Provider_SP_RealTimeOptimizer();

        //canCallOut_Test
        Map<String, String> terrFRUMap = new Map<String,String>();
        terrFRUMap.put(territory.Id,'SOU');
        terrFRUMap.put(territory1.Id,'UK01');
        Set<String> fruChangesToGet = new Set<String>();
        fruChangesToGet.add('SOU');
        fruChangesToGet.add('UK01');
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        rto.canCallOut(workOrder, fruChangesToGet, terrFRUMap);

        workOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_STATUS';
        workOrder.SVMXC__Work_Order_Scheduling_Status__c='Tentative';
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        rto.canCallOut(workOrder, fruChangesToGet, terrFRUMap);
    }

    static testMethod void canCallOut_Test() {

        String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
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

        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        svmxprocess.SVMXC__Name__c = 'Linx for ServicePower 1';
        svmxprocess.RecordTypeId = DispatchProRecordTypeId;
        svmxprocess.SVMXC__Dispatch_Process_Status__c='Complete';
        svmxprocess.SVMXC__Dispatch_Method__c='Linx for ServicePower';
        insert svmxprocess;

        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c='Open';
        oConf.SVMXC__Operator__c='eq';
        oConf.RecordTypeId = ExpressionRTypeId;
        oConf.SVMXC__Sequence__c=1;
        oConf.SVMXC__Expression_Rule__c = svmxprocess.id;
        insert oConf;

        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.name = 'South Central Region';
        territory.SVMXC__Optimizer_External_ID__c = 'SOU';
        territory.SVMXC__Optimizer_Last_Timestamp__c='';
        insert territory;

        SVMXC__Territory__c territory1 = new SVMXC__Territory__c();
        territory1.name = 'UK Region';
        territory1.SVMXC__Optimizer_External_ID__c = 'UK01';
        territory1.SVMXC__Optimizer_Last_Timestamp__c='';
        insert territory1;

        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrder.SVMXC__Zip__c = '75002';
        workOrder.SVMXC__Order_Status__c='Open';
        workOrder.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder.SVMXC__Locked_By_DC__c = false;
        workOrder.SVMXC__Service_Duration__c = 60;
        workOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CREATE_WO';
        workOrder.SVMXC__OptiMax_Status__c='Tentative';
        workOrder.SVMXC__Primary_Territory__c=territory.Id;
        workOrder.SVMXC__Acknowledged_By_Technician_Date_Time__c=Datetime.now();
        workOrder.SVMXC__Started_Driving_To_Location_Date_Time__c=Datetime.now();
        workOrder.SVMXC__Actual_Onsite_Response__c=Datetime.now();
        workOrder.SVMXC__Finished_Onsite_Date_Time__c=Datetime.now();

        WSCH_Provider_SP_RealTimeOptimizer rto= new WSCH_Provider_SP_RealTimeOptimizer();

        //canCallOut_Test
        Map<String, String> terrFRUMap = new Map<String,String>();
        terrFRUMap.put(territory.Id,'SOU1');
        terrFRUMap.put(territory1.Id,'UK02');
        Set<String> fruChangesToGet = new Set<String>();
        fruChangesToGet.add('SOU1');
        fruChangesToGet.add('UK02');
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        rto.canCallOut(workOrder, fruChangesToGet, terrFRUMap);

        workOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_STATUS';
        workOrder.SVMXC__Work_Order_Scheduling_Status__c='Contacted';
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        rto.canCallOut(workOrder, fruChangesToGet, terrFRUMap);

        workOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_STATUS';
        workOrder.SVMXC__Work_Order_Scheduling_Status__c='Travelling';
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        rto.canCallOut(workOrder, fruChangesToGet, terrFRUMap);

    }

    static testMethod void updateStatus_Test(){
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrder.SVMXC__Zip__c = '75001';
        workOrder.SVMXC__Order_Status__c='Open';
        //workOrder.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder.SVMXC__Locked_By_DC__c = false;
        workOrder.SVMXC__Service_Duration__c = 60;
        workOrder.SVMXC__Work_Order_Scheduling_Status__c='Tentative';
        workOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CREATE_WO';
        //workOrder.SVMXC__Primary_Territory__c=territory.Id;
        workOrder.SVMXC__Acknowledged_By_Technician_Date_Time__c=Datetime.now();
        workOrder.SVMXC__Started_Driving_To_Location_Date_Time__c=Datetime.now();
        workOrder.SVMXC__Actual_Onsite_Response__c=Datetime.now();
        workOrder.SVMXC__Finished_Onsite_Date_Time__c=Datetime.now();

        WSCH_Provider_SP_RealTimeOptimizer rto= new WSCH_Provider_SP_RealTimeOptimizer();

    /*    SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        list<string> lstSubModules = new list<string>{'GLOB001','OMAX003'};
        map<string, Map<String, String>> AllsvmxSettingList = commSettings.SVMX_getSettingList(lstSubModules);
        Map<String, String> svmxSettingListOMAX003 = AllsvmxSettingList.get('OMAX003');
        svmxSettingListOMAX003.putAll(AllsvmxSettingList.get('GLOB001'));
        svmxSettingListOMAX003.put('GBL007','True');
        svmxSettingListOMAX003.put('GBL022','None,OptiMax,Service Power');
        svmxSettingListOMAX003.put('GBL023','http://smaxdem.servicepower.com:6502/ccx/servicepower');*/


        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        rto.updateStatus(workOrder);
    }

    static testMethod void isValidApptBookRequest_Test(){
        WSCH_Provider_SP_StubsV91.ApptBookRequest apptBookReq = new WSCH_Provider_SP_StubsV91.ApptBookRequest();
        apptBookReq.jobID='';
        apptBookReq.jobType='Repair';
        apptBookReq.postcode='75001';
        apptBookReq.date_x='3/7/2014';
        apptBookReq.priority='1';
        apptBookReq.importance='10';
        WSCH_Provider_SP_StubsV91.SkillWithLevel skill = new WSCH_Provider_SP_StubsV91.SkillWithLevel();
        skill.skillId='skill1';
        skill.skillLevel='10';
        apptBookReq.extraSkills= new WSCH_Provider_SP_StubsV91.ReqSkills();
        apptBookReq.extraSkills.reqSkills = new List<WSCH_Provider_SP_StubsV91.SkillWithLevel>();
        apptBookReq.extraSkills.reqSkills.add(skill);

        WSCH_Provider_SP_StubsV91.ReqEmps reqEmps = new WSCH_Provider_SP_StubsV91.ReqEmps();
        String[] empIDs = new String[]{'TM001','TS001'};
        reqEmps.empIDs=empIDs;
        reqEmps.MPX='Preferred';
        apptBookReq.reqEmps=reqEmps;

        apptBookReq.listReqEmps = new WSCH_Provider_SP_StubsV91.ListReqEmps();
        apptBookReq.listReqEmps.reqEmp = new List<WSCH_Provider_SP_StubsV91.ReqEmp>();
        WSCH_Provider_SP_StubsV91.ReqEmp reqEmp = new WSCH_Provider_SP_StubsV91.ReqEmp();
        reqEmp.empID='TM001';
        reqEmp.MPX='Preferred';
        apptBookReq.listReqEmps.reqEmp.add(reqEmp);

        WSCH_Provider_SP_RealTimeOptimizer rto= new WSCH_Provider_SP_RealTimeOptimizer();
        rto.isValidApptBookRequest(apptBookReq);

    }

    static testMethod void isWorkOrderValid_Test(){
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrder.SVMXC__Zip__c = '75001';
        workOrder.SVMXC__Order_Status__c='Open';
        workOrder.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder.SVMXC__Locked_By_DC__c = false;
        workOrder.SVMXC__Service_Duration__c = 60;
        workOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CREATE_WO';
        //workOrder.Id='testId';
        //insert workOrder;

        WSCH_Provider_SP_RealTimeOptimizer rto= new WSCH_Provider_SP_RealTimeOptimizer();
        
        WSCH_Provider_SP_StubsV91.JobBookRequest request_x = new WSCH_Provider_SP_StubsV91.JobBookRequest();
        request_x.jobID = 'id';
        request_x.postcode = '1234';
        request_x.extraDuration = '60';
        rto.isJobBookRequestValid(request_x, workOrder);

    }

    static testMethod void changeWorkItemStatus_Test(){
        //test.startTest();

        String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
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

        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        svmxprocess.SVMXC__Name__c = 'Linx for ServicePower 1';
        svmxprocess.RecordTypeId = DispatchProRecordTypeId;
        svmxprocess.SVMXC__Dispatch_Process_Status__c='Complete';
        svmxprocess.SVMXC__Dispatch_Method__c='Linx for ServicePower';
        insert svmxprocess;

        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c='Open';
        oConf.SVMXC__Operator__c='eq';
        oConf.RecordTypeId = ExpressionRTypeId;
        oConf.SVMXC__Sequence__c=1;
        oConf.SVMXC__Expression_Rule__c = svmxprocess.id;
        insert oConf;

        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.name = 'South Central Region';
        territory.SVMXC__Optimizer_External_ID__c = 'SOU';
        territory.SVMXC__Optimizer_Last_Timestamp__c='';
        insert territory;

        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrder.SVMXC__Zip__c = '75001';
        workOrder.SVMXC__Order_Status__c='Open';
        workOrder.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder.SVMXC__Locked_By_DC__c = false;
        workOrder.SVMXC__Service_Duration__c = 60;
        workOrder.SVMXC__OptiMax_Status__c ='';
        workOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CREATE_WO';
        workOrder.SVMXC__OptiMax_Status__c='Tentative';
        workOrder.SVMXC__Primary_Territory__c=territory.Id;

        String[] WO_SP_DISPATCH_STATUS = new String[]{'Tentative','Earmarked','Contacted','Travelling','LoggedOn','Cleared'};

        WSCH_Provider_SP_RealTimeOptimizer rto= new WSCH_Provider_SP_RealTimeOptimizer();
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        rto.changeWorkItemStatus(workOrder,WO_SP_DISPATCH_STATUS[0],Datetime.now());
    }

    static testMethod void testManageNonWOEventsCreate() {
        Test.startTest();

        SVMXC__Territory__c territory1 = new SVMXC__Territory__c();
        territory1.name = 'UK Region';
        territory1.SVMXC__Optimizer_External_ID__c = 'UK01';
        territory1.SVMXC__Optimizer_Last_Timestamp__c='';
        insert territory1;

        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'testTeam';

        insert team;

        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'John';
        technician.SVMXC__Optimizer_External_ID__c = 'TM001';
        technician.SVMXC__Service_Group__c  = team.Id;
        technician.SVMXC__Service_Territory__c = territory1.Id;

        insert technician;

        
        SVMXC__SVMX_Event__c svmxEvent= new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-12 00:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-12 01:00:00').addHours(1),
                                                    SVMXC__Technician__c =  technician.Id,
                                                    SVMXC__WhatId__c = Schema.Sobjecttype.SVMXC__SVMX_Event__c.getKeyPrefix()
                                                    );

        insert svmxEvent;

        SVMXC__SVMX_Optimizer__c svmxOptimizer = new SVMXC__SVMX_Optimizer__c();
        svmxOptimizer.SVMXC__WhatId__c = svmxEvent.Id;
        svmxOptimizer.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CREATE';
        svmxOptimizer.SVMXC__Optimizer_External_Id__c = String.valueOf(1234);

        insert svmxOptimizer;

        List<SVMXC__SVMX_Optimizer__c> lstOfOptimizerEvent = new List<SVMXC__SVMX_Optimizer__c>();
        lstOfOptimizerEvent.add(svmxOptimizer);

        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_Provider_SP_RealTimeOptimizer rto = new WSCH_Provider_SP_RealTimeOptimizer();
        rto.manageNonWorkOrderEvents(lstOfOptimizerEvent);

        Test.stopTest();
    }

     static testMethod void testManageNonWOEventsUpdate() {
        Test.startTest();

        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'testTeam';

        insert team;

        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'John';
        technician.SVMXC__Optimizer_External_ID__c = 'TM001';
        technician.SVMXC__Service_Group__c  = team.Id;

        insert technician;

        SVMXC__SVMX_Event__c svmxEvent= new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-12 00:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-12 01:00:00').addHours(1),
                                                    SVMXC__Technician__c =  technician.Id,
                                                    SVMXC__WhatId__c = Schema.Sobjecttype.SVMXC__SVMX_Event__c.getKeyPrefix()
                                                    );

        insert svmxEvent;


        SVMXC__SVMX_Optimizer__c svmxOptimizer = new SVMXC__SVMX_Optimizer__c();
        svmxOptimizer.SVMXC__WhatId__c = svmxEvent.Id;
        svmxOptimizer.SVMXC__Optimizer_Change_Token__c = 'CHANGE_UPDATE';
        svmxOptimizer.SVMXC__Optimizer_External_Id__c = String.valueOf(1234);

        insert svmxOptimizer;

        List<SVMXC__SVMX_Optimizer__c> lstOfOptimizerEvent = new List<SVMXC__SVMX_Optimizer__c>();
        lstOfOptimizerEvent.add(svmxOptimizer);

        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_Provider_SP_RealTimeOptimizer rto = new WSCH_Provider_SP_RealTimeOptimizer();
        rto.manageNonWorkOrderEvents(lstOfOptimizerEvent);

        Test.stopTest();
    }
    
    static testMethod void testManageNonWOEventsDelete() {
        Test.startTest();

        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'testTeam';

        insert team;

        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'John';
        technician.SVMXC__Optimizer_External_ID__c = 'TM001';
        technician.SVMXC__Service_Group__c  = team.Id;

        insert technician;

        SVMXC__SVMX_Event__c svmxEvent= new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-12 00:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-12 01:00:00').addHours(1),
                                                    SVMXC__Technician__c =  technician.Id,
                                                    SVMXC__WhatId__c = Schema.Sobjecttype.SVMXC__SVMX_Event__c.getKeyPrefix()
                                                    );

        insert svmxEvent;


        SVMXC__SVMX_Optimizer__c svmxOptimizer = new SVMXC__SVMX_Optimizer__c();
        svmxOptimizer.SVMXC__WhatId__c = svmxEvent.Id;
        svmxOptimizer.SVMXC__Optimizer_Change_Token__c = 'CHANGE_DELETE';
        svmxOptimizer.SVMXC__Optimizer_External_Id__c = String.valueOf(1234);

        insert svmxOptimizer;

        List<SVMXC__SVMX_Optimizer__c> lstOfOptimizerEvent = new List<SVMXC__SVMX_Optimizer__c>();
        lstOfOptimizerEvent.add(svmxOptimizer);

        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_Provider_SP_RealTimeOptimizer rto = new WSCH_Provider_SP_RealTimeOptimizer();
        rto.manageNonWorkOrderEvents(lstOfOptimizerEvent);

        Test.stopTest();
    }

    static testMethod void testCancelJob() {
        Test.startTest();
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CANCEL_WO';
        List<SVMXC__Service_Order__c> workOrders = new List<SVMXC__Service_Order__c>();
        workOrders.add(workOrder);
        insert workOrders;

        SVMXC__SVMX_Optimizer__c svmxOptimizer = new SVMXC__SVMX_Optimizer__c();
        svmxOptimizer.SVMXC__WhatId__c = workOrder.Id;
        svmxOptimizer.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CANCEL_WO';

        List<SVMXC__SVMX_Optimizer__c> lstOfOptimizerEvent = new List<SVMXC__SVMX_Optimizer__c>();
        lstOfOptimizerEvent.add(svmxOptimizer);

        WSCH_Provider_SP_RealTimeOptimizer rto = new WSCH_Provider_SP_RealTimeOptimizer();
        rto.cancelWorkOrders(lstOfOptimizerEvent);
        rto.manageWorkOrders(workOrders);

        Test.stopTest();
    }

    static testMethod void testUpdateJob() {
        Test.startTest();
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        List<SVMXC__Service_Order__c> workOrders = new List<SVMXC__Service_Order__c>();

        SVMXC__Service_Order__c priorityWO = new SVMXC__Service_Order__c();
        priorityWO.SVMXC__Dispatch_Priority__c = 1.0;
        priorityWO.SVMXC__Scheduling_Change_Token__c = 'CHANGE_PRIORITY';
        workOrders.add(priorityWO);

        SVMXC__Service_Order__c contactWO = new SVMXC__Service_Order__c();
        contactWO.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CONTACT_INFO';
        workOrders.add(contactWO);

        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'testTeam';

        insert team;

        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'John';
        technician.SVMXC__Optimizer_External_ID__c = 'TM001';
        technician.SVMXC__Service_Group__c  = team.Id;

        insert technician;

        SVMXC__Service_Order__c updateWO_UnFix = new SVMXC__Service_Order__c();

        updateWO_UnFix.SVMXC__Scheduling_Change_Token__c = 'CHANGE_JOB_UNFIXED';
        updateWO_UnFix.SVMXC__Group_Member__c = technician.Id;
        workOrders.add(updateWO_UnFix);

        SVMXC__Service_Order__c updateWO_Fix = new SVMXC__Service_Order__c();

        updateWO_Fix.SVMXC__Scheduling_Change_Token__c = 'CHANGE_JOB_FIXED';
        updateWO_Fix.SVMXC__Group_Member__c = technician.Id;
        updateWO_Fix.SVMXC__Scheduled_Date_Time__c=Datetime.now();
        workOrders.add(updateWO_Fix);

        insert workOrders;

        WSCH_Provider_SP_RealTimeOptimizer rto = new WSCH_Provider_SP_RealTimeOptimizer();
        rto.manageWorkOrders(workOrders);


        Test.stopTest();
    }

    static testMethod void testSetFRU(){

         String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
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

        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        svmxprocess.SVMXC__Name__c = 'Linx for ServicePower 1';
        svmxprocess.RecordTypeId = DispatchProRecordTypeId;
        svmxprocess.SVMXC__Dispatch_Process_Status__c='Complete';
        svmxprocess.SVMXC__Dispatch_Method__c='Linx for ServicePower';
        insert svmxprocess;

        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c='Open';
        oConf.SVMXC__Operator__c='eq';
        oConf.RecordTypeId = ExpressionRTypeId;
        oConf.SVMXC__Sequence__c=1;
        oConf.SVMXC__Expression_Rule__c = svmxprocess.id;
        insert oConf;

        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.name = 'South Central Region';
        territory.SVMXC__Optimizer_External_ID__c = 'SOU';
        territory.SVMXC__Optimizer_Last_Timestamp__c='';
        insert territory;

        SVMXC__Territory__c territory1 = new SVMXC__Territory__c();
        territory1.name = 'UK Region';
        territory1.SVMXC__Optimizer_External_ID__c = 'UK01';
        territory1.SVMXC__Optimizer_Last_Timestamp__c='';
        insert territory1;

        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrder.SVMXC__Zip__c = '75001';
        workOrder.SVMXC__Order_Status__c='Open';
        workOrder.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder.SVMXC__Locked_By_DC__c = false;
        workOrder.SVMXC__Service_Duration__c = 60;
        workOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CREATE_WO';
        workOrder.SVMXC__OptiMax_Status__c='Tentative';
        workOrder.SVMXC__Primary_Territory__c=territory.Id;
        workOrder.SVMXC__Acknowledged_By_Technician_Date_Time__c=Datetime.now();
        workOrder.SVMXC__Started_Driving_To_Location_Date_Time__c=Datetime.now();
        workOrder.SVMXC__Actual_Onsite_Response__c=Datetime.now();
        workOrder.SVMXC__Finished_Onsite_Date_Time__c=Datetime.now();

        WSCH_Provider_SP_RealTimeOptimizer rto= new WSCH_Provider_SP_RealTimeOptimizer();

        //canCallOut_Test
        Map<String, String> terrFRUMap = new Map<String,String>();
        terrFRUMap.put(territory.Id,'SOU');
        terrFRUMap.put(territory1.Id,'UK01');
        Set<String> fruChangesToGet = new Set<String>();
        fruChangesToGet.add('SOU');
        fruChangesToGet.add('UK01');
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        rto.setFRU(workOrder, terrFRUMap,fruChangesToGet);

    }

    static testMethod void testLogintoSP() {
        String dbUser='testuser';
        String dbPassword ='testpw';
        String spUser='spUser';
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_Provider_SP_RealTimeOptimizer.loginToSP(dbUser, dbPassword, spUser);
    }

    static testMethod void testForceBook() {

        test.startTest();

        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrder.SVMXC__Zip__c = '75001';
        workOrder.SVMXC__Order_Status__c='Open';
        workOrder.SVMXC__Scheduling_Change_Token__c = 'FORCE_SCHEDULE';
        workOrder.SVMXC__OptiMax_Status__c='OPT_PENDING';
        workOrder.SVMXC__Service_Duration__c = 60;

        insert workOrder;

        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_Provider_SP_RealTimeOptimizer spRealTimeOptimizer = new WSCH_Provider_SP_RealTimeOptimizer();
        spRealTimeOptimizer.forceBook(workOrder);

        test.stopTest();
    }
    
    static testMethod void testCustomLabels() {
        WSCH_Provider_SP_RealTimeOptimizer.getTAG035();
        WSCH_Provider_SP_RealTimeOptimizer.getTAG036();
    }
    
    static testMethod void SP_RealTimeOptimizer() {
        
        test.StartTest();
        WSCH_Provider_SP_RealTimeOptimizer.mapWoConName = new Map<Id, String>();
        List<SVMXC__ServiceMax_Config_Data__c> lstSetting = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstSetting = [SELECT id,SVMXC__Setting_Unique_ID__c, SVMXC__Internal_Value__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Setting_Unique_ID__c In ('GLOB001_GBL024', 'DCON004_SET010')];
        for(SVMXC__ServiceMax_Config_Data__c lst: lstSetting ){
            lst.SVMXC__Internal_Value__c = 'EXTERNAL';
            update lst;
        }
        
        WSCH_Provider_SP_RealTimeOptimizer testRealTimeOptimizer = new WSCH_Provider_SP_RealTimeOptimizer();
        
        
        /* RecordType FulfillmentProcess_Rtype = [select Id from RecordType where Name='Fulfillment Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];

SVMXC__ServiceMax_Processes__c SVMXProcess = new SVMXC__ServiceMax_Processes__c();
SVMXProcess.RecordTypeId = FulfillmentProcess_Rtype.Id;
SVMXProcess.SVMXC__Name__c = 'Fulfillment Process';
SVMXProcess.SVMXC__Description__c = 'Fulfillment Process';
SVMXProcess.SVMXC__ProcessID__c = 'TEST_FULFILLMENT_PROCESS';
SVMXProcess.SVMXC__Active__c = true;
SVMXProcess.SVMXC__Parent_Error_Msg__c = 'error found';
SVMXProcess.SVMXC__Child_Error_Msg__c = 'error found in child';             
insert SVMXProcess;*/
        
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'testTeam';
        
        insert team;
        
        SVMXC__Territory__c territory1 = new SVMXC__Territory__c();
        territory1.name = 'UK Region';
        territory1.SVMXC__Optimizer_External_ID__c = 'UK01';
        territory1.SVMXC__Optimizer_Last_Timestamp__c='';
        insert territory1;
        
        //testRealTimeOptimizer.getWorkOrderUpdates(territory1);
        
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'John';
        technician.SVMXC__Optimizer_External_ID__c = 'TM001';
        technician.SVMXC__Service_Group__c  = team.Id;
        technician.SVMXC__Service_Territory__c = territory1.Id;
        
        insert technician;
        
        BusinessHours lstOfBusinessHours1;
        lstOfBusinessHours1 = [SELECT Id,IsActive,IsDefault,MondayStartTime,MondayEndTime,
                               TuesdayStartTime,TuesdayEndTime,WednesdayStartTime,WednesdayEndTime,
                               ThursdayStartTime,ThursdayEndTime,FridayStartTime,FridayEndTime,SaturdayStartTime,
                               SaturdayEndTime,SundayStartTime,SundayEndTime FROM BusinessHours
                               WHERE IsDefault = TRUE AND IsActive = TRUE Limit 1];
        
        // BusinessHours businessHoursObj = lstOfBusinessHours1.get(0);
        
        
        SVMXC__Service_Level__c slaone=new SVMXC__Service_Level__c(
            Name='Test one',
            SVMXC__Description__c='Test one Description',
            SVMXC__Active__c =true,
            SVMXC__Initial_Response_Tracked_On__c = 'Case'  , 
            SVMXC__Select__c=true,        
            SVMXC__Business_Hours__c = lstOfBusinessHours1.id         
        );
        insert slaone;
        
        Account ABC = new Account();
        ABC.Name = 'ABCDEFGHI';
        insert ABC;
        system.assert(ABC.Name!=null);
        
        SVMXC__Service_Contract__c newSC = new SVMXC__Service_Contract__c();
        newSC.SVMXC__Exchange_type__c = 'Return Exchange';
        newSC.SVMXC__Start_Date__c  = system.today();
        newSC.SVMXC__End_Date__c  = system.today() + 1;
        newSC.SVMXC__Company__c = ABC.Id;
        
        
        
        SVMXC__Service_Order__c bookJobWorkOrder = new SVMXC__Service_Order__c();
        bookJobWorkOrder.SVMXC__Zip__c = '75001';
        bookJobWorkOrder.SVMXC__Service_Duration__c = 3600.00;
        Datetime startTime = Datetime.now();
        Datetime endTime = startTime.addHours(2);
        bookJobWorkOrder.SVMXC__Service_Contract__c = newSC.id;
        bookJobWorkOrder.SVMXC__SLA_Terms__c = slaone.id;
        bookJobWorkOrder.SVMXC__Preferred_Start_Time__c = startTime;
        bookJobWorkOrder.SVMXC__Preferred_End_Time__c = endTime;
        bookJobWorkOrder.SVMXC__Preferred_Technician__c = technician.Id;
        bookJobWorkOrder.SVMXC__Primary_Territory__c=territory1.Id;
        bookJobWorkOrder.SVMXC__Preferred_Business_Hours__c = lstOfBusinessHours1.Id;
        bookJobWorkOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_ZIP_CODE';
        bookJobWorkOrder.SVMXC__Completed_Date_Time__c = Datetime.now();
        bookJobWorkOrder.SVMXC__OptiMax_Status__c='Tentative';
        //bookJobWorkOrder.SVMXC__Dispatch_Process__c = SVMXProcess.id;
        bookJobWorkOrder.SVMXC__Skill_Set__c = '[{"skillName":"hardware","skillLevel":5,"skillId":"a1RG0000002fCLLMA2","isSkillMandatory":true},{"skillName":"software","skillLevel":5,"skillId":"a1RG0000002fCLQMA2","isSkillMandatory":true}]';
        
        insert bookJobWorkOrder;
        
        WSCH_ApptParam apptParam = new WSCH_ApptParam();
        apptParam.startDateTime = System.now();
        apptParam.endDateTime = System.now()+1;
        
        try{
            testRealTimeOptimizer.getAvailableAppointments(bookJobWorkOrder, apptParam,1, 0);
        } catch(Exception ex) {
            system.debug('Exception occured');
        }        
        
        WSCH_Appointment appointment = new WSCH_Appointment();
        appointment.setStartDateTime(DateTime.now());
        appointment.setStrStartDateTime('2014-05-13T08:30');
        appointment.setOfferToken('');
        
        testRealTimeOptimizer.bookAppointment(bookJobWorkOrder, appointment);
        List<SVMXC__Service_Order__c> lstWO = new List<SVMXC__Service_Order__c>();
        lstWO.add(bookJobWorkOrder);
        testRealTimeOptimizer.getBatchList(lstWO,'Open');
        testRealTimeOptimizer.populateWorkOrderResPrefMap(lstWO);
        testRealTimeOptimizer.manageWorkOrders(lstWO);
        testRealTimeOptimizer.forceBook(bookJobWorkOrder);
        testRealTimeOptimizer.updateStatus(bookJobWorkOrder); 
        //testRealTimeOptimizer.getChangedWorkOrders('UK01', 'strTimeStamp');
        
        test.StopTest();
    }
    
    static testMethod void testDependency(){
        System.Test.StartTest();
    SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
    workOrder1.SVMXC__Zip__c = '75001';
    workOrder1.SVMXC__Order_Status__c = 'Open';
    workOrder1.SVMXC__Service_Duration__c = 3600;
    workOrder1.SVMXC__Schedule_As_A_Dependent_Work_Order__c = True;
    insert workOrder1;
    SVMXC__Service_Order__c workOrder2 = new SVMXC__Service_Order__c();
    workOrder2.SVMXC__Zip__c = '75001';
    workOrder2.SVMXC__Order_Status__c='Open';
    workOrder2.SVMXC__Service_Duration__c = 3600;
    workOrder2.SVMXC__Schedule_As_A_Dependent_Work_Order__c = True;
    insert workOrder2;
    SVMXC__Dependency_Management__c dependencyManagement = new SVMXC__Dependency_Management__c();
    dependencyManagement.SVMXC__Dependency_Group_Name__c = 'BDG-01';
    insert dependencyManagement;
    SVMXC__Service_Order_Dependency__c dependencyRecord = new SVMXC__Service_Order_Dependency__c();
    dependencyRecord.SVMXC__Primary_Work_Order__c = workOrder1.Id;
    dependencyRecord.SVMXC__Secondary_Work_Order__c = workOrder2.Id;
    dependencyRecord.SVMXC__Time_Dependency__c = 'Start Times Of Both Depend On Each Other';
    dependencyRecord.SVMXC__Dependency_Group__c = dependencyManagement.id;
    dependencyRecord.SVMXC__Maximum_Time_Deviation__c = 30;
    dependencyRecord.SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes';
    dependencyRecord.SVMXC__Minimum_Time_Deviation__c = 60;
    dependencyRecord.SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes';
    dependencyRecord.SVMXC__Targeted_Time_Difference__c = 45;
    dependencyRecord.SVMXC__Targeted_Time_Variance_Cost_ID__c = 'testCost';
    dependencyRecord.SVMXC__Targeted_Time_Difference_Units__c = 'Minutes';
    insert dependencyRecord;
    
    List<Service_Order_Dependency__c> serviceOrderList = new List<Service_Order_Dependency__c>();
    serviceOrderList.add(dependencyRecord);
    List<String> multiJobIds = new List<String>();
    multiJobIds.add('BDG-01');
    WSCH_Provider_SP_StubsV91.BookDependencyGroupResponse response;
    WSCH_Provider_SP_RealTimeOptimizer realtimeoptimizer = new WSCH_Provider_SP_RealTimeOptimizer();
    response = realtimeoptimizer.manageDependencyGroup(dependencyManagement.Id, serviceOrderList);
    System.Test.StopTest();
    }
}