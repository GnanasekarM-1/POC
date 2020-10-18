/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest()
private class WSCH_LTP_Initiate_Service_UT {

    static {
        createOptimizationSettings('OptiMax,ServicePower', 'True');
    }

    static testMethod void invokeInitJobNoDataUT() {
        // TO DO: implement unit test 
        WSCH_LTP_Scheduling_Stubs.InitJobRequest_WP req = new WSCH_LTP_Scheduling_Stubs.InitJobRequest_WP();
        req.dispatchProcessGuid ='a122I00000E4CcTQAV';
        req.territoryGuid ='a1dF0000002mLNO_LTP00';
        req.orgGuid ='00DF00000007BzN';
        req.jobInstanceId ='4302';
        req.dispatchMethod = 'Long-Term Planner';
        Test.startTest();
        SVMXC.COMM_Utils_ManageSettings manageSet = new SVMXC.COMM_Utils_ManageSettings();
        WSCH_LTP_Scheduling_Stubs.InitJobResponse_WP resp= WSCH_LTP_Initiate_Service.invokeInitJob(req);
        Test.stopTest();
    }
    
    static testMethod void invokeRestCall_invalidData_UT() {
        String jsonStr = '{"orgGuid" : "org1","dispatchProcessGuid" : "a122I00000E4CcT","territoryGuid" : "a1dF0000002mLNO_LTP00","jobInstanceId" : "999", "dispatchMethod" : "Long-Term Planner"   }';
        RestRequest req = new RestRequest(); 
        req.requestURI = '/services/apexrest/scheduling/batch/initiate';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonStr);
        RestContext.request = req;
        Test.startTest();
        WSCH_LTP_Initiate_Service.doPost();
        Test.stopTest();
    }

    static testMethod void invokeRestCall_validData_UT() {
        Test.startTest();
        SVMXC__Territory__c territory = createTerritory('RealTime Territory');
        SVMXC__ServiceMax_Processes__c prcessObjone = createDP(territory,'Real Time Optimization');
        SVMXC__Service_Group_Members__c sfTech = createSFTech(territory);
        SVMXC__Service_Group_Members__c svmxTech = createSVMXTech(territory);
        List<SVMXC__Service_Order__c> lstWO = new list<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c wo = createWorkOrder(prcessObjone.Id,territory.Id,null,null,false);
        SVMXC__Service_Order__c wo1 = createWorkOrder(prcessObjone.Id,territory.Id,null,null,false);
        SVMXC__Service_Order__c wo2 = createWorkOrder(prcessObjone.Id,territory.Id,null,null,false);
        
        String ltpTerritoryId = territory.id+'_LTP00';
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/scheduling/batch/initiate';
        String reqBody = '{"orgGuid":null, "dispatchProcessGuid":"' + prcessObjone.id + '","territoryGuid":"' + ltpTerritoryId + '","jobInstanceId":"999","dispatchMethod" : "Long-Term Planner"}';
        req.requestBody = Blob.valueOf(reqBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        WSCH_LTP_Initiate_Service.doPost();
        Test.stopTest();
    }

    static testMethod void invokeInit_withSVMXJob_UT() {
        Test.startTest();
        SVMXC__Territory__c territory = createTerritory('RealTime Territory1');
        SVMXC__ServiceMax_Processes__c prcessObjone = createDP(territory,'Real Time Optimization');
        SVMXC__SVMX_Jobs__c svmxJob = createSVMXJob(prcessObjone.Id,territory.Id,'Staging','LTP');        
        SVMXC__Service_Group_Members__c sfTech = createSFTech(territory);
        SVMXC__Service_Group_Members__c svmxTech = createSVMXTech(territory);
        List<SVMXC__Service_Order__c> lstWO = new list<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c wo = createWorkOrder(prcessObjone.Id,territory.Id,Datetime.now()+10,Datetime.now()+20,false);
        SVMXC__Service_Order__c wo1 = createWorkOrder(prcessObjone.Id,territory.Id,null,null,false);
        SVMXC__Service_Order__c wo2 = createWorkOrder(prcessObjone.Id,territory.Id,null,null,false);
        
        String ltpTerritoryId = territory.id+'_LTP00';
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/scheduling/batch/initiate';
        String reqBody = '{"orgGuid":null, "dispatchProcessGuid":"' + prcessObjone.id + '","territoryGuid":"' + ltpTerritoryId + '","jobInstanceId":"999", "dispatchMethod" : "Long-Term Planner"   }';
        req.requestBody = Blob.valueOf(reqBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        WSCH_LTP_Initiate_Service.doPost();
        Test.stopTest();
    }


    static testMethod void invokeInit_withSVMXJobFULL_UT() {
        Test.startTest();
        SVMXC__Territory__c territory = createTerritory('Batch Territory1');
        SVMXC__ServiceMax_Processes__c prcessObjone = createDP(territory,'Optimized Batch');
        SVMXC__SVMX_Jobs__c svmxJob = createSVMXJob(prcessObjone.Id,territory.Id,'Staging','Full');        
        SVMXC__Service_Group_Members__c sfTech = createSFTech(territory);
        SVMXC__Service_Group_Members__c svmxTech = createSVMXTech(territory);
        List<SVMXC__Service_Order__c> lstWO = new list<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c wo = createWorkOrder(prcessObjone.Id,territory.Id,Datetime.now()+10,Datetime.now()+20,false);
        SVMXC__Service_Order__c wo1 = createWorkOrder(prcessObjone.Id,territory.Id,null,null,false);
        SVMXC__Service_Order__c wo2 = createWorkOrder(prcessObjone.Id,territory.Id,null,null,false);
        
        String ltpTerritoryId = territory.id+'_LTP00';
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/scheduling/batch/initiate';
        String reqBody = '{"orgGuid":null, "dispatchProcessGuid":"' + prcessObjone.id + '","territoryGuid":"' + ltpTerritoryId + '","jobInstanceId":"999", "dispatchMethod" : "Optimized Batch" }';
        req.requestBody = Blob.valueOf(reqBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        WSCH_LTP_Initiate_Service.doPost();
        Test.stopTest();
    }    
    static testMethod void doSendIds_UT() {
        Test.startTest();
        SVMXC__Territory__c territory = createTerritory('LTP Territory1');
        SVMXC__ServiceMax_Processes__c prcessObjone = createDP(territory,'Optimized Batch');
        SVMXC__SVMX_Jobs__c svmxJob = createSVMXJob(prcessObjone.Id,territory.Id,'Initiated','LTP');
        SVMXC__Service_Group_Members__c sfTech = createSFTech(territory);
        SVMXC__Service_Group_Members__c svmxTech = createSVMXTech(territory);
        Event sfEvent = createSFEvent(sfTech.Id);
        SVMXC__SVMX_Event__c svmxEvent =createSVMXEvent(svmxTech.Id);
        List<SVMXC__Service_Order__c> lstWO = new list<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c wo = createWorkOrder(prcessObjone.Id,territory.Id,Datetime.now()+10,Datetime.now()+20,false);
        SVMXC__Service_Order__c wo1 = createWorkOrder(prcessObjone.Id,territory.Id,Datetime.now()-10,Datetime.now()+1,false);
        SVMXC__Service_Order__c wo2 = createWorkOrder(prcessObjone.Id,territory.Id,Datetime.now()+400,Datetime.now()+10,true);
        SVMXC__Service_Order__c wo3 = createWorkOrder(prcessObjone.Id,territory.Id,null,Datetime.now()+30,false);
        SVMXC__Service_Order__c wo4 = createWorkOrder(prcessObjone.Id,territory.Id,Datetime.now()+5,null,false);
        SVMXC__Service_Order__c wo5 = createWorkOrder(prcessObjone.Id,territory.Id,null,null,false); 
        SVMXC__Service_Order__c wo6 = createWorkOrder(prcessObjone.Id,territory.Id,Datetime.now()+400,Datetime.now()+10,true);              
        WSCH_LTP_Initiate_Service.doSendIds(svmxJob.Id);
        Test.stopTest();
    }

    static testMethod void doSendIdsFULL_UT() {
        Test.startTest();
        SVMXC__Territory__c territory = createTerritory('Batch Territory3');
        SVMXC__ServiceMax_Processes__c prcessObjone = createDP(territory,'Optimized Batch');
        SVMXC__SVMX_Jobs__c svmxJob = createSVMXJob(prcessObjone.Id,territory.Id,'Initiated','Full');
        SVMXC__Service_Group_Members__c sfTech = createSFTech(territory);
        SVMXC__Service_Group_Members__c svmxTech = createSVMXTech(territory);
        Event sfEvent = createSFEvent(sfTech.Id);
        SVMXC__SVMX_Event__c svmxEvent =createSVMXEvent(svmxTech.Id);
        List<SVMXC__Service_Order__c> lstWO = new list<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c wo = createWorkOrder(prcessObjone.Id,territory.Id,Datetime.now()+10,Datetime.now()+20,false);
        SVMXC__Service_Order__c wo1 = createWorkOrder(prcessObjone.Id,territory.Id,Datetime.now()-10,Datetime.now()+1,false);
        SVMXC__Service_Order__c wo2 = createWorkOrder(prcessObjone.Id,territory.Id,Datetime.now()+400,Datetime.now()+10,true);
        SVMXC__Service_Order__c wo3 = createWorkOrder(prcessObjone.Id,territory.Id,null,Datetime.now()+30,false);
        SVMXC__Service_Order__c wo4 = createWorkOrder(prcessObjone.Id,territory.Id,Datetime.now()+5,null,false);
        SVMXC__Service_Order__c wo5 = createWorkOrder(prcessObjone.Id,territory.Id,null,null,false); 
        SVMXC__Service_Order__c wo6 = createWorkOrder(prcessObjone.Id,territory.Id,Datetime.now()+400,Datetime.now()+10,true);              
        WSCH_LTP_Initiate_Service.doSendIds(svmxJob.Id);
        Test.stopTest();
    }
    private static SVMXC__SVMX_Jobs__c createSVMXJob(String dpId, String territoryId, String jobStatus, String jobType){
            SVMXC__SVMX_Jobs__c objSVMXJob = new SVMXC__SVMX_Jobs__c();
            objSVMXJob.SVMXC__SVMX_Process__c = dpId;
            objSVMXJob.SVMXC__Territory__c = territoryId;
            objSVMXJob.SVMXC__OptiMax_Message__c = jobStatus;
            objSVMXJob.SVMXC__Start_Time__c = system.now();
            objSVMXJob.SVMXC__Initiated_By__c = Userinfo.getUserId();
            objSVMXJob.SVMXC__Status__c = '100';
            objSVMXJob.SVMXC__Type__c = jobType;
            insert objSVMXJob;
            return objSVMXJob;            
    }
    
    private static SVMXC__Service_Order__c createWorkOrder(String dpId, String territoryId, Datetime pstDT, Datetime petDT, boolean isfixed){
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        BusinessHours bh = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];
        workOrder.SVMXC__Zip__c = '75001';
        workOrder.SVMXC__Order_Status__c='Open';
        workOrder.SVMXC__Dispatch_Process__c =  dpId;
        workOrder.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder.SVMXC__Locked_By_DC__c = isfixed;
        workOrder.SVMXC__Service_Duration__c = 3600;
        workOrder.SVMXC__OptiMax_Status__c ='';
        workOrder.SVMXC__Preferred_Business_Hours__c = bh.Id;
        if(pstDT != null)
            workOrder.SVMXC__Preferred_Start_Time__c = pstDT;
        if(petDT != null)
            workOrder.SVMXC__Preferred_End_Time__c = petDT;
        workOrder.SVMXC__Primary_Territory__c=territoryId;
        workOrder.SVMXC__Latitude__c=22.3433;
        workOrder.SVMXC__Longitude__c=23.3434;
        insert workOrder;
        return workOrder;
    }
        
    //create optimization data
    private static SVMXC__Territory__c createTerritory(String territoryName) {
        list<SVMXC__Territory__c> Territorylst = new List<SVMXC__Territory__c>();
        BusinessHours bh = [Select Id from BusinessHours where IsDefault=true];
        SVMXC__Territory__c Territory1 = new SVMXC__Territory__c();
        Territory1.name = territoryName;
        Territory1.SVMXC__Territory_s_Business_Hours__c = bh.id;
        Territorylst.add(Territory1);
        insert Territorylst;
        
        return Territorylst[0];
    }
    
    private static SVMXC__ServiceMax_Processes__c createDP(SVMXC__Territory__c territory, String strDPMethod) {
        List<RecordType> RecType = new  List<RecordType>();
        string DispatchRTypeId;
        RecType = Database.Query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\'');
        for(RecordType Rt : RecType)
        {
            if(Rt.Name == 'Dispatch Process')
            {
                DispatchRTypeId  = Rt.id;
            }
        }
        SVMXC__ServiceMax_Processes__c prcessObjone = new SVMXC__ServiceMax_Processes__c();
        prcessObjone.RecordTypeId = DispatchRTypeId;
        prcessObjone.SVMXC__Name__c = 'Test LTP';
        prcessObjone.SVMXC__Dispatch_Method__c = strDPMethod;
        prcessObjone.SVMXC__Email_On_Error__c = 'test@servicemax.com';
        prcessObjone.SVMXC__Email_On_Success__c = 'test@servicemax.com';
        prcessObjone.SVMXC__Weight_Time_Window__c = 1;
        prcessObjone.SVMXC__Weight_Total_Distance__c = 1;
        prcessObjone.SVMXC__Weight_Route_Distance__c = 1;
        prcessObjone.SVMXC__Weight_Route_Time__c = 1;
        prcessObjone.SVMXC__Weight_Node_Type__c = 1;
        prcessObjone.SVMXC__Values__c = territory.id + ':U,';
        prcessObjone.SVMXC__Route_Type__c = 'CLOSED';
        prcessObjone.SVMXC__Dispatch_Threshold__c = 30;
        prcessObjone.SVMXC__Optimizer_Sync_Interval__c = 30;
        prcessObjone.SVMXC__Calendar_End_Days__c=9;
        prcessObjone.SVMXC__Calendar_Start_Days__c=1;
        prcessObjone.SVMXC__Full_Run_Unit__c = 'DAYS';
        prcessObjone.SVMXC__Window_Height__c = 9.0;
        prcessObjone.SVMXC__Window_Width__c = 90.0;
        insert prcessObjone;
        
        return prcessObjone;
    }
    
    private static SVMXC__Service_Group_Members__c createSFTech(SVMXC__Territory__c territory) {
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'testTeam';
        insert team;
        
        SVMXC__Service_Group_Members__c Tech1 = new SVMXC__Service_Group_Members__c();
        Tech1.name = 'T1';
        Tech1.SVMXC__Active__c = true;
        Tech1.SVMXC__Enable_Scheduling__c = true;
        Tech1.SVMXC__Service_Territory__c = territory.id;
        Tech1.SVMXC__Service_Group__c = team.Id;
        Tech1.SVMXC__Salesforce_User__c = Userinfo.getUserId();
        insert Tech1;
        return Tech1;               
    }
    
    Private static SVMXC__Service_Group_Members__c createSVMXTech(SVMXC__Territory__c territory) {
        SVMXC__Service_Group__c team1 = new SVMXC__Service_Group__c();
        team1.Name = 'testTeam1';
        insert team1;
        SVMXC__Service_Group_Members__c Tech2 = new SVMXC__Service_Group_Members__c();
        Tech2.name = 'T2';
        Tech2.SVMXC__Active__c = true;
        Tech2.SVMXC__Enable_Scheduling__c = true;
        Tech2.SVMXC__Service_Territory__c = territory.id;
        Tech2.SVMXC__Service_Group__c = team1.Id;
        insert Tech2;
        return Tech2;
    }
    private static Event createSFEvent(String techId){
        Event ev = new Event();
        ev.EventSubtype  = 'Event';
        ev.StartDateTime = system.today();
        ev.EndDateTime = system.today() + 1;
        ev.WhatId = techId;
        insert ev;
        return ev;
    }
    
    private  static SVMXC__SVMX_Event__c createSVMXEvent(String technician){
        SVMXC__SVMX_Event__c svmxEv = new SVMXC__SVMX_Event__c();
        svmxEv.Name = 'EVMX_EV_UT';
        svmxEv.SVMXC__Technician__c =  technician;
        svmxEv.SVMXC__StartDateTime__c= system.today();
        svmxEv.SVMXC__EndDateTime__c = system.today() + 1;
         insert svmxEv;
         return svmxEv;
    }    
    private static void createJob(Id dpId, Id territoryId) {
        List<SVMXC__SVMX_Jobs__c> listJobs = new List<SVMXC__SVMX_Jobs__c>();
        SVMXC__SVMX_Jobs__c objSVMXJob = new SVMXC__SVMX_Jobs__c();
        objSVMXJob.SVMXC__SVMX_Process__c = dpId;
        objSVMXJob.SVMXC__Territory__c = territoryId;
        objSVMXJob.SVMXC__OptiMax_Message__c = 'Initiated';
        objSVMXJob.SVMXC__Start_Time__c = system.now();
        objSVMXJob.SVMXC__Initiated_By__c = Userinfo.getUserId();
        objSVMXJob.SVMXC__Type__c = 'LTP';
        listJobs.add(objSVMXJob);           
        Database.upsert(listJobs);
    }

    //This method Optimization Settings GLOB001_GBL007 & GLOB001_GBL022
    private static void createOptimizationSettings(String strOptimizers, String strEnableOptimizer){
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
        Database.upsert(modProc_COMM);
        
        //adding GLOB001 Process SubModule
        SVMXC__ServiceMax_Processes__c subModProc_GLOB001 = new SVMXC__ServiceMax_Processes__c();
        subModProc_GLOB001.RecordTypeId = subModTypeId;
        subModProc_GLOB001.SVMXC__SubmoduleID__c = 'GLOB001';
        subModProc_GLOB001.SVMXC__Name__c = 'Global Settings';
        subModProc_GLOB001.SVMXC__IsStandard__c = true;
        subModProc_GLOB001.SVMXC__Module__c = modProc_COMM.id;
        subModProc_GLOB001.SVMXC__Description__c = 'TEST SUBMODULE DESCRIPTION';
        subModProc_GLOB001.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(subModProc_GLOB001);
        
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
        Database.upsert(settingProc_GLOB001_GBL007);        
        
        //adding GLOB001 GBL007 Configuration Profile
        SVMXC__ServiceMax_Config_Data__c confProfile_GLOB001_GBL007 = new SVMXC__ServiceMax_Config_Data__c();
        confProfile_GLOB001_GBL007.SVMXC__Profile_Name__c = 'TestSvmxGLB';
        confProfile_GLOB001_GBL007.RecordTypeId = confProfileTypeId;
        confProfile_GLOB001_GBL007.SVMXC__Configuration_Type__c = 'Global';
        confProfile_GLOB001_GBL007.SVMXC__Active__c = true;
        confProfile_GLOB001_GBL007.SVMXC__IsDefault__c = true;
        confProfile_GLOB001_GBL007.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(confProfile_GLOB001_GBL007);
        
        //adding GLOB001 GBL007 Setting Value
        SVMXC__ServiceMax_Config_Data__c conf_GLOB001_GBL007 = new SVMXC__ServiceMax_Config_Data__c();
        conf_GLOB001_GBL007.RecordTypeId = setValTypeId;
        conf_GLOB001_GBL007.SVMXC__Setting_Configuration_Profile__c = confProfile_GLOB001_GBL007.id;
        conf_GLOB001_GBL007.SVMXC__Display_Value__c = 'True';
        conf_GLOB001_GBL007.SVMXC__Internal_Value__c = 'True';
        conf_GLOB001_GBL007.SVMXC__Setting_ID__c = settingProc_GLOB001_GBL007.id;
        conf_GLOB001_GBL007.SVMXC__Active__c = true; //
        conf_GLOB001_GBL007.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(conf_GLOB001_GBL007);
        
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
        Database.upsert(settingProc_GLOB001_GBL022);
        
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
        Database.upsert(conf_GLOB001_GBL022);
        
        //adding OptiMax Process Module
        SVMXC__ServiceMax_Processes__c modProc_OMAX = new SVMXC__ServiceMax_Processes__c();
        modProc_OMAX.RecordTypeId = modTypeId;
        modProc_OMAX.SVMXC__ModuleID__c = 'OMAX';
        modProc_OMAX.SVMXC__Name__c = 'OptiMax';
        modProc_OMAX.SVMXC__IsStandard__c = true;
        modProc_OMAX.SVMXC__Description__c = 'TEST MODULE DESCRIPTION';
        modProc_OMAX.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(modProc_OMAX);
       
        //adding DCON004 Process SubModule///////////////////////////
        SVMXC__ServiceMax_Processes__c subModProc_DCON004 = new SVMXC__ServiceMax_Processes__c();
        subModProc_DCON004.RecordTypeId = subModTypeId;
        subModProc_DCON004.SVMXC__SubmoduleID__c = 'DCON004';
        subModProc_DCON004.SVMXC__Name__c = 'Manage OptiMax Settings';
        subModProc_DCON004.SVMXC__IsStandard__c = true;
        subModProc_DCON004.SVMXC__Module__c = modProc_OMAX.id;
        subModProc_DCON004.SVMXC__Description__c = 'TEST SUBMODULE DESCRIPTION';
        subModProc_DCON004.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(subModProc_DCON004);
       
        //adding DCON004 SET009 Process Setting
         SVMXC__ServiceMax_Processes__c settingProc_DCON004_SET009 = new SVMXC__ServiceMax_Processes__c();
        settingProc_DCON004_SET009.RecordTypeId = setTypeId;
        settingProc_DCON004_SET009.SVMXC__SettingID__c = 'SET009';
        settingProc_DCON004_SET009.SVMXC__Data_Type__c = 'Text';
        settingProc_DCON004_SET009.SVMXC__Default_Value__c = '1';
        settingProc_DCON004_SET009.SVMXC__Setting_Type__c = 'Global';
        settingProc_DCON004_SET009.SVMXC__Search_Order__c = 'Global';
        settingProc_DCON004_SET009.SVMXC__Active__c = true;
        settingProc_DCON004_SET009.SVMXC__IsStandard__c =true;
        settingProc_DCON004_SET009.SVMXC__Values__c = '1....N';
        settingProc_DCON004_SET009.SVMXC__Submodule__c = subModProc_DCON004.id;
        settingProc_DCON004_SET009.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
        settingProc_DCON004_SET009.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(settingProc_DCON004_SET009);
       
        //associating DCON004 SET009 Setting Value to a Global profile defined above
             SVMXC__ServiceMax_Config_Data__c conf_DCON004_SET009 = new SVMXC__ServiceMax_Config_Data__c();
        conf_DCON004_SET009.RecordTypeId = setValTypeId;
        conf_DCON004_SET009.SVMXC__Setting_Configuration_Profile__c = confProfile_GLOB001_GBL007.id;
        conf_DCON004_SET009.SVMXC__Display_Value__c = '1';
        conf_DCON004_SET009.SVMXC__Internal_Value__c = '1';
        conf_DCON004_SET009.SVMXC__Setting_ID__c = settingProc_DCON004_SET009.id;
        conf_DCON004_SET009.SVMXC__Active__c = true; //
        conf_DCON004_SET009.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(conf_DCON004_SET009); 
        
         //adding DCON004 SET008 Process Setting
              //adding DCON004 SET009 Process Setting
      SVMXC__ServiceMax_Processes__c settingProc_DCON004_SET008 = new SVMXC__ServiceMax_Processes__c();
        settingProc_DCON004_SET008.RecordTypeId = setTypeId;
        settingProc_DCON004_SET008.SVMXC__SettingID__c = 'SET008';
        settingProc_DCON004_SET008.SVMXC__Data_Type__c = 'Text';
        settingProc_DCON004_SET008.SVMXC__Default_Value__c = '1';
        settingProc_DCON004_SET008.SVMXC__Setting_Type__c = 'Global';
        settingProc_DCON004_SET008.SVMXC__Search_Order__c = 'Global';
        settingProc_DCON004_SET008.SVMXC__Active__c = true;
        settingProc_DCON004_SET008.SVMXC__IsStandard__c = true;
        settingProc_DCON004_SET008.SVMXC__Values__c = '1...N';
        settingProc_DCON004_SET008.SVMXC__Submodule__c = subModProc_DCON004.id;
        settingProc_DCON004_SET008.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
        settingProc_DCON004_SET008.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(settingProc_DCON004_SET008);
       
        //associating DCON004 SET008 Setting Value to a Global profile defined above
        SVMXC__ServiceMax_Config_Data__c conf_DCON004_SET008 = new SVMXC__ServiceMax_Config_Data__c();
        conf_DCON004_SET008.RecordTypeId = setValTypeId;
        conf_DCON004_SET008.SVMXC__Setting_Configuration_Profile__c = confProfile_GLOB001_GBL007.id;
        conf_DCON004_SET008.SVMXC__Display_Value__c = '1';
        conf_DCON004_SET008.SVMXC__Internal_Value__c = '1';
        conf_DCON004_SET008.SVMXC__Setting_ID__c = settingProc_DCON004_SET008.id;
        conf_DCON004_SET008.SVMXC__Active__c = true; //
        conf_DCON004_SET008.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(conf_DCON004_SET008); 
        
          //adding DCON004 SET008 Process Setting
        SVMXC__ServiceMax_Processes__c settingProc_DCON004_SET0015 = new SVMXC__ServiceMax_Processes__c();
        settingProc_DCON004_SET0015.RecordTypeId = setTypeId;
        settingProc_DCON004_SET0015.SVMXC__SettingID__c = 'SET015';
        settingProc_DCON004_SET0015.SVMXC__Data_Type__c = 'Boolean';
        settingProc_DCON004_SET0015.SVMXC__Default_Value__c = 'True';
        settingProc_DCON004_SET0015.SVMXC__Setting_Type__c = 'Global';
        settingProc_DCON004_SET0015.SVMXC__Search_Order__c = 'Global';
        settingProc_DCON004_SET0015.SVMXC__Active__c = true;
        settingProc_DCON004_SET0015.SVMXC__IsStandard__c = false;
        settingProc_DCON004_SET0015.SVMXC__Values__c = 'TRUE~|~FALSE';
        settingProc_DCON004_SET0015.SVMXC__Submodule__c = subModProc_DCON004.id;
        settingProc_DCON004_SET0015.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
        settingProc_DCON004_SET0015.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(settingProc_DCON004_SET0015);
       
        //associating DCON004 SET008 Setting Value to a Global profile defined above
        SVMXC__ServiceMax_Config_Data__c conf_DCON004_SET015 = new SVMXC__ServiceMax_Config_Data__c();
        conf_DCON004_SET015.RecordTypeId = setValTypeId;
        conf_DCON004_SET015.SVMXC__Setting_Configuration_Profile__c = confProfile_GLOB001_GBL007.id;
        conf_DCON004_SET015.SVMXC__Display_Value__c = 'True';
        conf_DCON004_SET015.SVMXC__Internal_Value__c = 'True';
        conf_DCON004_SET015.SVMXC__Setting_ID__c = settingProc_DCON004_SET0015.id;
        conf_DCON004_SET015.SVMXC__Active__c = true; //
        conf_DCON004_SET015.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(conf_DCON004_SET015); 

        //adding GLOB001 GBL010 Process Setting
        SVMXC__ServiceMax_Processes__c settingProc_GLOB001_GBL010 = new SVMXC__ServiceMax_Processes__c();
        settingProc_GLOB001_GBL010.RecordTypeId = setTypeId;
        settingProc_GLOB001_GBL010.SVMXC__SettingID__c = 'GBL010';
        settingProc_GLOB001_GBL010.SVMXC__Data_Type__c = 'Boolean';
        settingProc_GLOB001_GBL010.SVMXC__Default_Value__c = 'True';
        settingProc_GLOB001_GBL010.SVMXC__Setting_Type__c = 'Global';
        settingProc_GLOB001_GBL010.SVMXC__Search_Order__c = 'Global';
        settingProc_GLOB001_GBL010.SVMXC__Active__c = true;
        settingProc_GLOB001_GBL010.SVMXC__IsStandard__c = true;
        settingProc_GLOB001_GBL010.SVMXC__Values__c = 'TRUE~|~FALSE';
        settingProc_GLOB001_GBL010.SVMXC__Submodule__c = subModProc_GLOB001.id;
        settingProc_GLOB001_GBL010.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
        settingProc_GLOB001_GBL010.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(settingProc_GLOB001_GBL010);        
        
        //adding GLOB001 GBL010 Configuration Profile
        SVMXC__ServiceMax_Config_Data__c confProfile_GLOB001_GBL010 = new SVMXC__ServiceMax_Config_Data__c();
        confProfile_GLOB001_GBL010.SVMXC__Profile_Name__c = 'TestSvmxGLB';
        confProfile_GLOB001_GBL010.RecordTypeId = confProfileTypeId;
        confProfile_GLOB001_GBL010.SVMXC__Configuration_Type__c = 'Global';
        confProfile_GLOB001_GBL010.SVMXC__Active__c = true;
        confProfile_GLOB001_GBL010.SVMXC__IsDefault__c = true;
        confProfile_GLOB001_GBL010.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(confProfile_GLOB001_GBL010);
        
        //adding GLOB001 GBL010 Setting Value
        SVMXC__ServiceMax_Config_Data__c conf_GLOB001_GBL010 = new SVMXC__ServiceMax_Config_Data__c();
        conf_GLOB001_GBL010.RecordTypeId = setValTypeId;
        conf_GLOB001_GBL010.SVMXC__Setting_Configuration_Profile__c = confProfile_GLOB001_GBL010.id;
        conf_GLOB001_GBL010.SVMXC__Display_Value__c = 'https://dev-optimax.servicemax-api.com:8343/optimax/optimization';
        conf_GLOB001_GBL010.SVMXC__Internal_Value__c = 'https://dev-optimax.servicemax-api.com:8343/optimax/optimization';
        conf_GLOB001_GBL010.SVMXC__Setting_ID__c = settingProc_GLOB001_GBL010.id;
        conf_GLOB001_GBL010.SVMXC__Active__c = true; //
        conf_GLOB001_GBL010.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(conf_GLOB001_GBL010);
       
        System.debug('createOptimizationSettingsMethod');
    }
        
}