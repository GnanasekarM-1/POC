@isTest(seeAllData = false)
private class WSCH_Provider_ECO_TechnicianService_UT{

    static testMethod void WSCH_Provider_ECO_TechnicianService_UnitTest() { 
            
        createOptimizationSettings();
      
        String requestJson = '{"workOrders":[{"workOrderType":"NEW","workOrderId":"WO-00015361","visitDuration":3600.0,"serviceTimes":[{"workingHoursEnd":"2016-12-03T01:00:00.000Z","workingHoursBegin":"2016-12-02T17:00:00.000Z"}],"requiredProduct":null,"requiredExpertise":null,"qualifiedTechnicians":[],"priority":5.0,"preferredResourcePriority":5.0,"preferredResourceId":"null_null","operationType":"add","mandatoryTechnicians":[],"location":{"longitude":-117.229739,"latitude":34.051113},"importance":5,"bannedTechnicians":[],"address":"CA, 90005"}],"territoryId":"a2Q2A0000005tBQUAY","svmxVersion":"16.29023","orgId":"00DF0000000ww8s","geoCodingEnabled":"true","dispatchProcessId":"a1l2A000005wTHMQA2"}';
      
        WSCH_Provider_ECO_Callout_Helper.callOut(requestJson, '/v1/schedule-services', '/manageWorkOrders/');
                        
        SVMXC__Territory__c testTer = createECOTerritory();

        SVMXC__ServiceMax_Processes__c testProcess = createECODispatchProcess(testTer.id);
        SVMXC__Service_Group_Members__c tectTechnician = createECOTechnician(testTer.id);

        SVMXC__SVMX_Jobs__c svmxJob = new SVMXC__SVMX_Jobs__c();
        svmxJob.SVMXC__Territory__c = testTer.Id;
        svmxJob.SVMXC__Type__c = 'ECO';
        svmxJob.SVMXC__OptiMax_Message__c = 'RUNNING';
        svmxJob.SVMXC__SVMX_Process__c = testProcess.Id;
        insert svmxJob;
        
        String connectionId = testProcess.Id+'_'+testTer.Id+'_'+tectTechnician.Id;
        List<String> techniciands = new List<String>();
        techniciands.add(tectTechnician.id);
        
        Event sfTestEvent1 = createSFEvent(tectTechnician.id);
        Event sfTestEvent2 = createSFEvent(tectTechnician.id);
        List<Event> sfEevents = new List<Event>();
        sfEevents.add(sfTestEvent1); 
        sfEevents.add(sfTestEvent2); 
        
        SVMXC__SVMX_Event__c svmxEvent1 = createSVMXECOEVENT(tectTechnician.id);
        List<SVMXC__SVMX_Event__c> svmxEvents = new List<SVMXC__SVMX_Event__c>();
        svmxEvents.add(svmxEvent1);
        
        //SVMXC__SVMX_Optimizer__c sftestOptimizer1 = createOptimizer(sfTestEvent1.id,'CHANGE_CREATE_EVENT',connectionId);
        SVMXC__SVMX_Optimizer__c sftestOptimizer1 = createOptimizer(tectTechnician,'CHANGE_CREATE_EVENT',connectionId);
                        
        List<SVMXC__SVMX_Optimizer__c> sftestOptimizers = new List<SVMXC__SVMX_Optimizer__c>();
        sftestOptimizers.add(sftestOptimizer1);
        
        WSCH_Provider_ECO_TechnicianService providerEcoTech =  new WSCH_Provider_ECO_TechnicianService();
        providerEcoTech.manageTechnicians(sftestOptimizers);  

        sftestOptimizer1.SVMXC__Optimizer_Change_Token__c = 'CHANGE_REMOVE_TECH';
        sftestOptimizers.clear();
        sftestOptimizers.add(sftestOptimizer1);
        providerEcoTech.manageTechnicians(sftestOptimizers);        
                        
               
        List<SVMXC__Service_Group_Members__c> listTech = new List<SVMXC__Service_Group_Members__c>(); 
        listTech.add(tectTechnician);
        providerEcoTech.isTechnicianValid(tectTechnician);
        providerEcoTech.getTerritoriesMap(listTech);    
        
    }
    
        
     private static SVMXC__SVMX_Optimizer__c createOptimizer(SVMXC__Service_Group_Members__c tectTechnician ,String changeToken,String conId){
        SVMXC__SVMX_Optimizer__c obj = new SVMXC__SVMX_Optimizer__c();
        obj.SVMXC__WhatType__c = changeToken;
        obj.SVMXC__WhatId__c = tectTechnician.id+'_'+tectTechnician.Name;
        obj.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CREATE_EVENT' ;        
        obj.SVMXC__Optimizer_Connection_ID__c=conId;
        insert obj;
        return obj;
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
    
    private  static SVMXC__SVMX_Event__c createSVMXECOEVENT(String technician){
        SVMXC__SVMX_Event__c svmxEv = new SVMXC__SVMX_Event__c();
        svmxEv.Name = 'EVMX_EV_UT';
        svmxEv.SVMXC__Technician__c =  technician;
        svmxEv.SVMXC__StartDateTime__c= system.today();
        svmxEv.SVMXC__EndDateTime__c = system.today() + 1;
        
         insert svmxEv;
         return svmxEv;
    }
    
    private static SVMXC__Service_Group_Members__c createECOTechnician(String terId){
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'ECO_Tech_UT';
        technician.SVMXC__City__c = 'Bangalore';
        technician.SVMXC__Country__c = 'India';
        technician.SVMXC__Zip__c = '560030';
        technician.SVMXC__Service_Territory__c = terId;
        technician.SVMXC__Service_Group__c = createServiceGroupId();
        insert technician;
        return technician;
        
    }
    
    private static String createServiceGroupId(){
     SVMXC__Service_Group__c segroup = new SVMXC__Service_Group__c();
     segroup.Name = 'TestGroup-UT';
     insert segroup;
     return segroup.id;
    }
    
    private static SVMXC__Territory__c createECOTerritory(){
        SVMXC__Territory__c ecoTeritory = new SVMXC__Territory__c();
        ecoTeritory.Name = 'Ter-UT';
        ecoTeritory.SVMXC__Per_Mile_Cost__c = 10;
        ecoTeritory.SVMXC__Max_Distance__c = 50;
        ecoTeritory.SVMXC__Average_Speed__c = 50;
        ecoTeritory.SVMXC__Fixed_Cost__c = 10;
        ecoTeritory.SVMXC__Per_hour_Cost__c = 10; 
        insert ecoTeritory;
        return ecoTeritory;
    }
    
    private static SVMXC__ServiceMax_Processes__c createECODispatchProcess(String terId){
        SVMXC__ServiceMax_Processes__c dprocess = new SVMXC__ServiceMax_Processes__c();
        dprocess.SVMXC__Dispatch_Method__c = 'Real Time Optimization';
        dprocess.SVMXC__Dispatch_Process_Status__c ='Complete';
        dprocess.SVMXC__Dispatch_Timezone__c= 'Asia/Colombo';
        dprocess.SVMXC__Name__c = 'Process-UT';
        dprocess.RecordTypeId = getDispatchProcessRecordId();
        dprocess.SVMXC__Territory__c = terId;
        dprocess.SVMXC__Calendar_End_Days__c = 5;
        
        insert dprocess;
        return dprocess;
    }
    
    
    private static String getDispatchProcessRecordId(){
        String dispatchProcessRecordType;
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' ];
        for(RecordType rt : rts)
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               dispatchProcessRecordType = rt.ID;
        }
        return dispatchProcessRecordType;
        
    }
    
        
    private static void createOptimizationSettings(){
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
    conf_GLOB001_GBL010.SVMXC__Display_Value__c = 'https://optimax-dev.servicemax.com:7343/optimax/optimization';
    conf_GLOB001_GBL010.SVMXC__Internal_Value__c = 'https://optimax-dev.servicemax.com:7343/optimax/optimization';
    conf_GLOB001_GBL010.SVMXC__Setting_ID__c = settingProc_GLOB001_GBL010.id;
    conf_GLOB001_GBL010.SVMXC__Active__c = true; //
    conf_GLOB001_GBL010.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
    Database.upsert(conf_GLOB001_GBL010);
  }    
   
}