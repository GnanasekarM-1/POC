@isTest
(SeeAllData = false)
public class WSCH_Provider_SP_DispatchClientHelper_UT {
    
    static testMethod void TestDripList_UT_Test(){
        
    /*List<SVMXC__ServiceMax_Config_Data__c> lstDripEnable = [select id, SVMXC__Display_Value__c, SVMXC__Internal_Value__c,SVMXC__Installation_Key__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Setting_Unique_ID__c IN ('DCON002_SET001') AND SVMXC__Active__c = true];
    for(SVMXC__ServiceMax_Config_Data__c confObj : lstDripEnable)
    {
    confObj.SVMXC__Display_Value__c = 'true';
    confObj.SVMXC__Internal_Value__c = 'true';
    confObj.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
    }

    List<SVMXC__ServiceMax_Config_Data__c> lstDripField = [select id, SVMXC__Display_Value__c, SVMXC__Internal_Value__c,SVMXC__Installation_Key__c  from SVMXC__ServiceMax_Config_Data__c where SVMXC__Setting_Unique_ID__c IN ('DCON002_SET002') AND SVMXC__Active__c = true];
    for(SVMXC__ServiceMax_Config_Data__c confObj : lstDripField)
    {
    confObj.SVMXC__Display_Value__c = 'SVMXC__Service_Order__c.SVMXC__Drip__c';
    confObj.SVMXC__Internal_Value__c = 'SVMXC__Service_Order__c.SVMXC__Drip__c';
    confObj.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
    }*/
        
        createDripFeedSettings('SVMXC__Service_Order__c.SVMXC__Drip__c, Event.isAllDayEvent, SVMXC__SVMX_Event__c.SVMXC__IsAllDayEvent__c', 'True');
        System.debug('$$$DCON001: ' +WSCH_CommonUtils.getSettingValue('DCON002','SET001'));
        System.debug('###DCON002: ' +WSCH_CommonUtils.getSettingValue('DCON002','SET002'));
        
        SVMXC__Service_Order__c workorderDrip = new SVMXC__Service_Order__c(
            SVMXC__Order_Status__c = 'Open',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Order_Type__c = 'Field Service',
            SVMXC__zip__c='WC2N 6NU',
            SVMXC__City__c='Bangalore',
            SVMXC__Invoice_Created__c = true,
            SVMXC__Drip__c= false
        );
        
        
        List<SVMXC__Service_Order__c> inpWoList = new List<SVMXC__Service_Order__c>();
        List<String> lstStrFlds = new List<String>();
        
        Database.insert(workorderDrip);
        inpWoList.add(workorderDrip);
        /*if(!lstDripEnable.isEmpty())
Database.update(lstDripEnable);

if(!lstDripField.isEmpty())
Database.update(lstDripField);*/
        Test.startTest();
        
        lstStrFlds = WSCH_Provider_SP_DispatchClientHelper.fetchQueryFields('SVMXC__Service_Order__c');
        WSCH_Provider_SP_DispatchClientHelper.fetchQueryFields('OBJECT_DOES_NOT_EXIST');
        lstStrFlds.clear();
        lstStrFlds.add('SVMXC__Drip__c');
        WSCH_Provider_SP_DispatchClientHelper.updateObject(lstStrFlds, true, inpWoList);
        lstStrFlds.add('FIELD_DOES_NOT_EXIST');
        WSCH_Provider_SP_DispatchClientHelper.updateObject(lstStrFlds, false, inpWoList);
        
        WSCH_Provider_SP_DispatchClientHelper.updateDripFeedList(inpWoList, true);
        
        WSCH_Provider_SP_DispatchClientHelper.updateDripFeed(workorderDrip, true);
        
        Test.stopTest();
    }
    static testMethod void TestDripFeed_UT_Test(){
        createOptimizationSettings('OptiMax,ServicePower', 'True');
        System.debug('$$$GBL007: ' +WSCH_CommonUtils.getSettingValue('GLOB001', 'GBL007'));
        System.debug('###GBL022: ' +WSCH_CommonUtils.getSettingValue('GLOB001', 'GBL022'));
        //Job State
        String request ='{"state":"NOTIFIED","workItems":[{"id":"WO-00032883","type":"JOB","booking":{"start":"2015-01-06 08:25","end":"2015-01-06 11:30","arr":"2015-01-06 08:30","tech":"T001"},"location":{"postalCode":"WC2N 6LU"}}],"rowver":0}';
        WSCH_Provider_SP_ChangedItems.doProcessRestRequest(request);
        
        //Action 
        String request1 = '{"workItems":[{"id":"WO-00018519","type":"JOB","task":{"action":"NOTIFIED","tied":false},"booking":{"start":"2015-01-06 11:30","end":"2015-01-06 15:35","arr":"2015-01-06 11:35","tech":"T010"},"atRisk":{"type":"Dispatch Issue","offset":0}}],"rowver":0}';
        WSCH_Provider_SP_ChangedItems.doProcessRestRequest(request1);
    }
    
    static testMethod void TestDispatchClientHelper(){
        createOptimizationSettings('OptiMax,ServicePower', 'True');
        System.debug('$$$GBL007: ' +WSCH_CommonUtils.getSettingValue('GLOB001', 'GBL007'));
        System.debug('###GBL022: ' +WSCH_CommonUtils.getSettingValue('GLOB001', 'GBL022'));
        test.startTest();
        List<WSCH_Provider_SP_DispatchClient.BreakTimes> breaks = new List<WSCH_Provider_SP_DispatchClient.BreakTimes>();
        WSCH_Provider_SP_DispatchClient.BreakTimes break1 = new WSCH_Provider_SP_DispatchClient.BreakTimes();
        break1.BreakName = 'testName';
        break1.BreakType = 'testType';
        break1.BreakStart = '2019-05-15T08:30';
        break1.BreakDuration = 20;
        breaks.add(break1);
        
        
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workorder.SVMXC__Zip__c='75001';
        workOrder.SVMXC__Service_Duration__c=3600.00;
        workOrder.SVMXC__Order_Status__c = 'Open';
        workOrder.SVMXC__Priority__c = 'Medium';
        workOrder.SVMXC__Order_Type__c = 'Field Service';
        workOrder.SVMXC__zip__c='WC2N 6NU';
        workOrder.SVMXC__City__c='Bangalore';
        workOrder.SVMXC__Invoice_Created__c = true;
        workOrder.SVMXC__Drip__c= false;
        insert workOrder;
        
        List<SVMXC__Service_Order__c> inpWoList = new List<SVMXC__Service_Order__c>();
        inpWoList.add(workOrder);
        
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
        
        SVMXC__Service_Group__c objTeam = new SVMXC__Service_Group__c(Name = 'TEAM 1');
        insert objTeam;
        SVMXC__Territory__c objTerritory = new SVMXC__Territory__c (Name = 'TERRITORY 1');
        insert objTerritory;
        SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c (
            Name = 'TECH 1' ,
            SVMXC__Latitude__c = 40.739582 ,
            SVMXC__Longitude__c = -73.980772,
            SVMXC__Service_Group__c = objTeam.Id ,
            SVMXC__Service_Territory__c = objTerritory.Id,
            SVMXC__Enable_Scheduling__c = true,
            SVMXC__Optimizer_External_ID__c = technician.SVMXC__Optimizer_External_ID__c,
            SVMXC__Salesforce_User__c = userinfo.getUserId()
        );
        insert tech1;
        
        /*Set<string> subModule = new Set<string>();
WSCH_Constants.subModules = subModule;

Map<string, Map<String, String>> mapSet = new Map<string, Map<String, String>>();
WSCH_Constants.allDMSettings =  mapset;
List<SVMXC__ServiceMax_Processes__c> testConfig1 = [select Name, Id, SVMXC__SubmoduleID__c, SVMXC__SettingID__c from SVMXC__ServiceMax_Processes__c where SVMXC__SubmoduleID__c = 'DCON002'];
List<SVMXC__ServiceMax_Processes__c> testConfig2 = new List<SVMXC__ServiceMax_Processes__c>();
for(SVMXC__ServiceMax_Processes__c smaxProcess : testConfig1){
smaxProcess.SVMXC__SubmoduleID__c = 'DCON00XX';
smaxProcess.SVMXC__SettingID__c = 'testsetting';
testConfig2.add(smaxProcess);
}
update testConfig2;
System.debug('1-->'+testConfig2);*/
        
        WSCH_Provider_SP_DispatchClientHelper.updateDripFeedList(inpWoList,true);
        WSCH_Provider_SP_DispatchClientHelper.createEventsForBreakTimes(breaks, technician.SVMXC__Optimizer_External_ID__c);
        
        /*List<SVMXC__ServiceMax_Processes__c> testConfig3 = [select Name, Id, SVMXC__SubmoduleID__c from SVMXC__ServiceMax_Processes__c where SVMXC__SubmoduleID__c = 'DCON002'];
System.debug('2-->'+testConfig3);*/
        test.StopTest();
    }
    static testMethod void processDispatchedWorkOrder() {
        
        Test.startTest();
        SVMXC__Service_Order__c bookJobWorkOrder = new SVMXC__Service_Order__c();
        bookJobWorkOrder.SVMXC__OptiMax_Status__c = 'OPT_COMPLETED';
        insert bookJobWorkOrder;
        bookJobWorkOrder = WSCH_CommonUtils.fetchWorkOrderById(bookJobWorkOrder.Id);
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'testTeam';
        insert team;
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'John';
        technician.SVMXC__Optimizer_External_ID__c = 'TM001';
        technician.SVMXC__Service_Group__c  = team.Id;
        insert technician;
        Event sfEvent = new Event();
        sfEvent.WhatId =  bookJobWorkOrder.Id;
        sfEvent.StartDateTime = DateTime.now();
        sfEvent.DurationInMinutes = 60;
        insert sfEvent;
        SVMXC__SVMX_Event__c svmxEvent= new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-12 00:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-12 01:00:00').addHours(1),
                                                    SVMXC__Technician__c =  technician.Id,
                                                    SVMXC__WhatId__c = bookJobWorkOrder.Id
                                                    );

        insert svmxEvent;
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_Provider_SP_DispatchClient.DispOutputRequest dispReq = new WSCH_Provider_SP_DispatchClient.DispOutputRequest();
        WSCH_Provider_SP_DispatchClient.LoginRequest loginReq = new WSCH_Provider_SP_DispatchClient.LoginRequest();
        WSCH_Provider_SP_DispatchClient.BreakTimes breakTimes = new WSCH_Provider_SP_DispatchClient.BreakTimes();
        WSCH_Provider_SP_DispatchClient.DispJobEarmarked jobInfo = new WSCH_Provider_SP_DispatchClient.DispJobEarmarked();
        jobInfo.ETS = '2014-02-21T8:00';
        jobInfo.ETA = '2014-02-21T8:30';
        jobInfo.ETF = '2014-02-21T9:00';
        jobInfo.jobID = WSCH_CommonUtils.getWorkItemId('Name',bookJobWorkOrder);
        jobInfo.empID = technician.SVMXC__Optimizer_External_ID__c;
        jobInfo.earmarkType = 'SA-Earmark';
        WSCH_Provider_SP_DispatchClient.DispOutput(jobInfo);
        jobInfo.earmarkType = 'Earmark';
        WSCH_Provider_SP_DispatchClient.DispOutput(jobInfo);
        jobInfo.earmarkType = 'UnEarmark';
        WSCH_Provider_SP_DispatchClient.DispOutput(jobInfo);
        WSCH_Provider_SP_DispatchClient.DispOutput(null);
        jobInfo.ETS = '2014/02/21T8:00';
        WSCH_Provider_SP_DispatchClient.DispOutput(jobInfo);
        Test.stopTest();
    }
    public static void createDripFeedSettings(String strDripFields, String strSetDrip){
        String confProfileTypeId = '';
        String setValTypeId = '';
        String setTypeId = '';
        String subModTypeId = '';
        String modTypeId = '';
        List<SVMXC__ServiceMax_Processes__c> lstInsProcDrip = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Config_Data__c> lstInsConfDrip = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        RecordType[] recTypeId = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : recTypeId) //Loop to take a record type at a time
        {
            if(rt.Name == 'Configuration Profile' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                confProfileTypeId = rt.ID;
            else if(rt.Name == 'Setting Value' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                setValTypeId = rt.ID;
            else if(rt.Name == 'Settings' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                setTypeId = rt.id;
            else if(rt.Name == 'Submodule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                subModTypeId = rt.id;
            else if(rt.Name == 'Module' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                modTypeId = rt.id;
        }
        
        //adding DCON Process Module
        SVMXC__ServiceMax_Processes__c modProc_DCON = new SVMXC__ServiceMax_Processes__c();
        modProc_DCON.RecordTypeId = modTypeId;
        modProc_DCON.SVMXC__ModuleID__c = 'DCON';
        modProc_DCON.SVMXC__Name__c = 'Dispatch Management';
        modProc_DCON.SVMXC__IsStandard__c = true;
        modProc_DCON.SVMXC__Description__c = 'TEST MODULE DESCRIPTION';
        modProc_DCON.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.insert(modProc_DCON);
        
        //adding DCON002 Process SubModule
        SVMXC__ServiceMax_Processes__c subModProc_DCON002 = new SVMXC__ServiceMax_Processes__c();
        subModProc_DCON002.RecordTypeId = subModTypeId;
        subModProc_DCON002.SVMXC__SubmoduleID__c = 'DCON002';
        subModProc_DCON002.SVMXC__Name__c = 'Drip Feed';
        subModProc_DCON002.SVMXC__IsStandard__c = true;
        subModProc_DCON002.SVMXC__Module__c = modProc_DCON.id;
        subModProc_DCON002.SVMXC__Description__c = 'TEST SUBMODULE DESCRIPTION';
        subModProc_DCON002.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.insert(subModProc_DCON002);
        
        //adding DCON002 SET001 Process Setting
        SVMXC__ServiceMax_Processes__c settingProc_DCON002_SET001 = new SVMXC__ServiceMax_Processes__c();
        settingProc_DCON002_SET001.RecordTypeId = setTypeId;
        settingProc_DCON002_SET001.SVMXC__SettingID__c = 'SET001';
        settingProc_DCON002_SET001.SVMXC__Data_Type__c = 'Boolean';
        settingProc_DCON002_SET001.SVMXC__Default_Value__c = 'False';
        settingProc_DCON002_SET001.SVMXC__Setting_Type__c = 'Group';
        settingProc_DCON002_SET001.SVMXC__Search_Order__c = 'Group,Global';
        settingProc_DCON002_SET001.SVMXC__Active__c = true;
        settingProc_DCON002_SET001.SVMXC__IsStandard__c = true;
        settingProc_DCON002_SET001.SVMXC__Values__c = 'TRUE~|~FALSE';
        settingProc_DCON002_SET001.SVMXC__Submodule__c = subModProc_DCON002.id;
        settingProc_DCON002_SET001.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
        settingProc_DCON002_SET001.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.insert(settingProc_DCON002_SET001);        
        
        //adding DCON002 SET001 Configuration Profile
        SVMXC__ServiceMax_Config_Data__c confProfile_DCON002_SET001 = new SVMXC__ServiceMax_Config_Data__c();
        confProfile_DCON002_SET001.SVMXC__Profile_Name__c = 'TestSvmxPro';
        confProfile_DCON002_SET001.RecordTypeId = confProfileTypeId;
        confProfile_DCON002_SET001.SVMXC__Configuration_Type__c = 'Global';
        confProfile_DCON002_SET001.SVMXC__Active__c = true;
        confProfile_DCON002_SET001.SVMXC__IsDefault__c = true;
        confProfile_DCON002_SET001.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.insert(confProfile_DCON002_SET001);
        
        //adding DCON002 SET001 Setting Value
        SVMXC__ServiceMax_Config_Data__c confDrip_DCON002_SET001 = new SVMXC__ServiceMax_Config_Data__c();
        confDrip_DCON002_SET001.RecordTypeId = setValTypeId;
        confDrip_DCON002_SET001.SVMXC__Setting_Configuration_Profile__c = confProfile_DCON002_SET001.id;
        confDrip_DCON002_SET001.SVMXC__Display_Value__c = 'True';
        confDrip_DCON002_SET001.SVMXC__Internal_Value__c = 'True';
        confDrip_DCON002_SET001.SVMXC__Setting_ID__c = settingProc_DCON002_SET001.id;
        confDrip_DCON002_SET001.SVMXC__Active__c = true; //
        confDrip_DCON002_SET001.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.insert(confDrip_DCON002_SET001);
        
        //adding DCON002 SET002 Process Setting
        SVMXC__ServiceMax_Processes__c settingProc_DCON002_SET002 = new SVMXC__ServiceMax_Processes__c();
        settingProc_DCON002_SET002.RecordTypeId = setTypeId;
        settingProc_DCON002_SET002.SVMXC__SettingID__c = 'SET002';
        settingProc_DCON002_SET002.SVMXC__Data_Type__c = 'Text';
        settingProc_DCON002_SET002.SVMXC__Default_Value__c = 'SVMXC__Service_Order__c.SVMXC__Drip__c';
        settingProc_DCON002_SET002.SVMXC__Setting_Type__c = 'Group';
        settingProc_DCON002_SET002.SVMXC__Search_Order__c = 'Group,Global';
        settingProc_DCON002_SET002.SVMXC__Active__c = true;
        settingProc_DCON002_SET002.SVMXC__IsStandard__c = true;
        settingProc_DCON002_SET002.SVMXC__Values__c = 'SVMXC__Service_Order__c.SVMXC__Drip__c';
        settingProc_DCON002_SET002.SVMXC__Submodule__c = subModProc_DCON002.id;
        settingProc_DCON002_SET002.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
        settingProc_DCON002_SET002.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.insert(settingProc_DCON002_SET002);
        
        //adding DCON002 SET002 Setting Value
        SVMXC__ServiceMax_Config_Data__c confDrip_DCON002_SET002 = new SVMXC__ServiceMax_Config_Data__c();
        confDrip_DCON002_SET002.RecordTypeId = setValTypeId;
        confDrip_DCON002_SET002.SVMXC__Setting_Configuration_Profile__c = confProfile_DCON002_SET001.id;
        confDrip_DCON002_SET002.SVMXC__Display_Value__c = 'SVMXC__Service_Order__c.SVMXC__Drip__c, Event.isAllDayEvent, SVMXC__SVMX_Event__c.SVMXC__IsAllDayEvent__c';
        //SVMXC__Internal_Value__c
        confDrip_DCON002_SET002.SVMXC__Internal_Value__c = 'SVMXC__Service_Order__c.SVMXC__Drip__c, Event.isAllDayEvent, SVMXC__SVMX_Event__c.SVMXC__IsAllDayEvent__c';
        confDrip_DCON002_SET002.SVMXC__Setting_ID__c = settingProc_DCON002_SET002.id;
        confDrip_DCON002_SET002.SVMXC__Active__c = true; //
        confDrip_DCON002_SET002.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.insert(confDrip_DCON002_SET002);

        System.debug('createDripFeedSettingsMethod');
    }
    //This method Optimization Settings GLOB001_GBL007 & GLOB001_GBL022
    public static void createOptimizationSettings(String strOptimizers, String strEnableOptimizer){
        String confProfileTypeId = '';
        String setValTypeId = '';
        String setTypeId = '';
        String subModTypeId = '';
        String modTypeId = '';
        
        RecordType[] recTypeId = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : recTypeId) //Loop to take a record type at a time
        {
            if(rt.Name == 'Configuration Profile' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                confProfileTypeId = rt.ID;
            else if(rt.Name == 'Setting Value' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                setValTypeId = rt.ID;
            else if(rt.Name == 'Settings' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                setTypeId = rt.id;
            else if(rt.Name == 'Submodule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                subModTypeId = rt.id;
            else if(rt.Name == 'Module' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                modTypeId = rt.id;
        }

        //adding COMM Process Module
        SVMXC__ServiceMax_Processes__c modProc_COMM = new SVMXC__ServiceMax_Processes__c();
        modProc_COMM.RecordTypeId = modTypeId;
        modProc_COMM.SVMXC__ModuleID__c = 'COMM';
        modProc_COMM.SVMXC__Name__c = 'Common';
        modProc_COMM.SVMXC__IsStandard__c = true;
        modProc_COMM.SVMXC__Description__c = 'TEST MODULE DESCRIPTION';
        modProc_COMM.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.insert(modProc_COMM);
        
        //adding GLOB001 Process SubModule
        SVMXC__ServiceMax_Processes__c subModProc_GLOB001 = new SVMXC__ServiceMax_Processes__c();
        subModProc_GLOB001.RecordTypeId = subModTypeId;
        subModProc_GLOB001.SVMXC__SubmoduleID__c = 'GLOB001';
        subModProc_GLOB001.SVMXC__Name__c = 'Global Settings';
        subModProc_GLOB001.SVMXC__IsStandard__c = true;
        subModProc_GLOB001.SVMXC__Module__c = modProc_COMM.id;
        subModProc_GLOB001.SVMXC__Description__c = 'TEST SUBMODULE DESCRIPTION';
        subModProc_GLOB001.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.insert(subModProc_GLOB001);
        
        //adding GLOB001 GBL007 Process Setting
        SVMXC__ServiceMax_Processes__c settingProc_GLOB001_GBL007 = new SVMXC__ServiceMax_Processes__c();
        settingProc_GLOB001_GBL007.RecordTypeId = setTypeId;
        settingProc_GLOB001_GBL007.SVMXC__SettingID__c = 'GBL007';
        settingProc_GLOB001_GBL007.SVMXC__Data_Type__c = 'Boolean';
        settingProc_GLOB001_GBL007.SVMXC__Default_Value__c = 'True';
        settingProc_GLOB001_GBL007.SVMXC__Setting_Type__c = 'Global';
        settingProc_GLOB001_GBL007.SVMXC__Search_Order__c = 'Global';
        settingProc_GLOB001_GBL007.SVMXC__Active__c = true;
        settingProc_GLOB001_GBL007.SVMXC__IsStandard__c = true;
        settingProc_GLOB001_GBL007.SVMXC__Values__c = 'TRUE~|~FALSE';
        settingProc_GLOB001_GBL007.SVMXC__Submodule__c = subModProc_GLOB001.id;
        settingProc_GLOB001_GBL007.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
        settingProc_GLOB001_GBL007.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.insert(settingProc_GLOB001_GBL007);        
        
        //adding GLOB001 GBL007 Configuration Profile
        SVMXC__ServiceMax_Config_Data__c confProfile_GLOB001_GBL007 = new SVMXC__ServiceMax_Config_Data__c();
        confProfile_GLOB001_GBL007.SVMXC__Profile_Name__c = 'TestSvmxGLB';
        confProfile_GLOB001_GBL007.RecordTypeId = confProfileTypeId;
        confProfile_GLOB001_GBL007.SVMXC__Configuration_Type__c = 'Global';
        confProfile_GLOB001_GBL007.SVMXC__Active__c = true;
        confProfile_GLOB001_GBL007.SVMXC__IsDefault__c = true;
        confProfile_GLOB001_GBL007.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.insert(confProfile_GLOB001_GBL007);
        
        //adding GLOB001 GBL007 Setting Value
        SVMXC__ServiceMax_Config_Data__c conf_GLOB001_GBL007 = new SVMXC__ServiceMax_Config_Data__c();
        conf_GLOB001_GBL007.RecordTypeId = setValTypeId;
        conf_GLOB001_GBL007.SVMXC__Setting_Configuration_Profile__c = confProfile_GLOB001_GBL007.id;
        conf_GLOB001_GBL007.SVMXC__Display_Value__c = 'True';
        conf_GLOB001_GBL007.SVMXC__Internal_Value__c = 'True';
        conf_GLOB001_GBL007.SVMXC__Setting_ID__c = settingProc_GLOB001_GBL007.id;
        conf_GLOB001_GBL007.SVMXC__Active__c = true; //
        conf_GLOB001_GBL007.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.insert(conf_GLOB001_GBL007);
        
        //adding GLOB001 GBL022 Process Setting
        SVMXC__ServiceMax_Processes__c settingProc_GLOB001_GBL022 = new SVMXC__ServiceMax_Processes__c();
        settingProc_GLOB001_GBL022.RecordTypeId = setTypeId;
        settingProc_GLOB001_GBL022.SVMXC__SettingID__c = 'GBL022';
        settingProc_GLOB001_GBL022.SVMXC__Data_Type__c = 'Text';
        settingProc_GLOB001_GBL022.SVMXC__Default_Value__c = 'OptiMax,ServicePower';
        settingProc_GLOB001_GBL022.SVMXC__Setting_Type__c = 'Global';
        settingProc_GLOB001_GBL022.SVMXC__Search_Order__c = 'Global';
        settingProc_GLOB001_GBL022.SVMXC__Active__c = true;
        settingProc_GLOB001_GBL022.SVMXC__IsStandard__c = true;
        settingProc_GLOB001_GBL022.SVMXC__Values__c = 'None,OptiMax,Service Power';
        settingProc_GLOB001_GBL022.SVMXC__Submodule__c = subModProc_GLOB001.id;
        settingProc_GLOB001_GBL022.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
        settingProc_GLOB001_GBL022.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.insert(settingProc_GLOB001_GBL022);
        
        //adding GLOB001 GBL022 Setting Value
        SVMXC__ServiceMax_Config_Data__c conf_GLOB001_GBL022 = new SVMXC__ServiceMax_Config_Data__c();
        conf_GLOB001_GBL022.RecordTypeId = setValTypeId;
        conf_GLOB001_GBL022.SVMXC__Setting_Configuration_Profile__c = confProfile_GLOB001_GBL007.id;
        conf_GLOB001_GBL022.SVMXC__Display_Value__c = 'OptiMax, ServicePower';
        //SVMXC__Internal_Value__c
        conf_GLOB001_GBL022.SVMXC__Internal_Value__c = 'OptiMax, ServicePower';
        conf_GLOB001_GBL022.SVMXC__Setting_ID__c = settingProc_GLOB001_GBL022.id;
        conf_GLOB001_GBL022.SVMXC__Active__c = true;
        conf_GLOB001_GBL022.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.insert(conf_GLOB001_GBL022);
        
        System.debug('createOptimizationSettingsMethod');

    }
}