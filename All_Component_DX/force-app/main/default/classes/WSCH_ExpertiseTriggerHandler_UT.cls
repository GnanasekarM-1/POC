@isTest(seeAllData = false)
public with sharing class WSCH_ExpertiseTriggerHandler_UT {
    
    static testMethod void expertiseInsert() {
        createOptimizationSettings();
        List<Service_Group_Skills__c> lstOfExpertise = getExpertiseList();
        WSCH_ExpertiseTriggerHandler.handleExpertiseInsert(lstOfExpertise);
    }
    
    static testMethod void expertiseUpdate() {
        List<Service_Group_Skills__c> lstOfExpertise = getExpertiseList();
        WSCH_ExpertiseTriggerHandler.handleExpertiseUpdate(lstOfExpertise, lstOfExpertise);

        List<Service_Group_Skills__c> lstOfExpertiseOld = getExpertiseList();
        WSCH_ExpertiseTriggerHandler.handleExpertiseUpdate(lstOfExpertise, lstOfExpertiseOld);
    }
    
    static testMethod void expertiseDelete() {
        List<Service_Group_Skills__c> lstOfExpertise = getExpertiseList();
        WSCH_ExpertiseTriggerHandler.handleExpertiseDelete(lstOfExpertise);  
    }

    static testMethod void expertiseErrorScenario() {
        List<Service_Group_Skills__c> lstOfExpertiseError = getExpertiseListError();
        WSCH_ExpertiseTriggerHandler.handleExpertiseInsert(lstOfExpertiseError); 

        WSCH_ExpertiseTriggerHandler.handleExpertiseUpdate(lstOfExpertiseError, lstOfExpertiseError);

        WSCH_ExpertiseTriggerHandler.handleExpertiseDelete(lstOfExpertiseError);
    }
    
    private static List<Service_Group_Skills__c> getExpertiseList() {

        createOptimizationSettings();
        
        List<Service_Group_Skills__c> lstOfExpertise = new List<Service_Group_Skills__c>();

        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'team1';
        team.SVMXC__Active__c = true;
        insert team;
        
        SVMXC__Service_Group_Members__c tech1 = getTechnicianObj();
        SVMXC__SVMX_Optimizer__c optTransObj1 = new SVMXC__SVMX_Optimizer__c();
        optTransObj1.SVMXC__WhatId__c = tech1.Id +'_'+ tech1.Name;
        insert optTransObj1;

        Service_Group_Skills__c expertise1 = new Service_Group_Skills__c();
        expertise1.SVMXC__Availability_Start_Date__c = system.now().Date();
        expertise1.SVMXC__Availability_End_Date__c = (system.now() + 1).date();
        expertise1.SVMXC__Group_Member__c = tech1.Id;
        expertise1.SVMXC__Service_Group__c = team.Id;
        lstOfExpertise.add(expertise1);
    
        SVMXC__Service_Group_Members__c tech2 = getTechnicianObj();
        SVMXC__SVMX_Optimizer__c optTransObj2 = new SVMXC__SVMX_Optimizer__c();
        optTransObj2.SVMXC__WhatId__c = tech2.Id +'_'+ tech2.Name;
        insert optTransObj2;

        Service_Group_Skills__c expertise2 = new Service_Group_Skills__c();
        expertise2.SVMXC__Availability_Start_Date__c = system.now().Date();
        expertise2.SVMXC__Availability_End_Date__c = (system.now() + 1).Date();
        expertise2.SVMXC__Group_Member__c = tech2.Id;
        expertise2.SVMXC__Service_Group__c = team.Id;
        lstOfExpertise.add(expertise2);
        insert lstOfExpertise;

        List<String> lstIds = new List<String>();
        lstIds.add(expertise1.Id);
        lstIds.add(expertise2.Id);

        List<Service_Group_Skills__c> lstOfRetrievedExpertise = [Select Id, SVMXC__Is_Applicable__c, SVMXC__Group_Member__c, SVMXC__Service_Group__c from Service_Group_Skills__c WHERE Id IN:lstIds];
         
        return lstOfRetrievedExpertise;   
    }

    private static List<Service_Group_Skills__c> getExpertiseListError() {
        
        List<Service_Group_Skills__c> lstOfExpertise = new List<Service_Group_Skills__c>();

        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'team1';
        team.SVMXC__Active__c = true;
        insert team;
        
        SVMXC__Service_Group_Members__c tech1 = getTechnicianObj();
        SVMXC__SVMX_Optimizer__c optTransObj1 = new SVMXC__SVMX_Optimizer__c();
        optTransObj1.SVMXC__WhatId__c = tech1.Id +'_'+ tech1.Name;
        insert optTransObj1;

        Service_Group_Skills__c expertise1 = new Service_Group_Skills__c();
        expertise1.SVMXC__Availability_Start_Date__c = system.now().Date();
        expertise1.SVMXC__Availability_End_Date__c = (system.now() + 1).date();
        expertise1.SVMXC__Group_Member__c = tech1.Id;
        expertise1.SVMXC__Service_Group__c = team.Id;
        lstOfExpertise.add(expertise1);
    
        SVMXC__Service_Group_Members__c tech2 = getTechnicianObj();
        SVMXC__SVMX_Optimizer__c optTransObj2 = new SVMXC__SVMX_Optimizer__c();
        optTransObj2.SVMXC__WhatId__c = tech2.Id +'_'+ tech2.Name;
        insert optTransObj2;

        Service_Group_Skills__c expertise2 = new Service_Group_Skills__c();
        expertise2.SVMXC__Availability_Start_Date__c = system.now().Date();
        expertise2.SVMXC__Availability_End_Date__c = (system.now() + 1).Date();
        expertise2.SVMXC__Group_Member__c = tech2.Id;
        expertise2.SVMXC__Service_Group__c = team.Id;
        lstOfExpertise.add(expertise2);
        insert lstOfExpertise;

        List<String> lstIds = new List<String>();
        lstIds.add(expertise1.Id);
        lstIds.add(expertise2.Id);

        List<Service_Group_Skills__c> lstOfRetrievedExpertise = [Select Id, SVMXC__Is_Applicable__c from Service_Group_Skills__c WHERE Id IN:lstIds];
         
        return lstOfRetrievedExpertise;   
    }
    
    private static SVMXC__Service_Group_Members__c getTechnicianObj() {
    
        list<BusinessHours> lBH = [ select WednesdayStartTime, timeZoneSidKey, WednesdayEndTime, TuesdayStartTime, 
        TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, 
        SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime
         from BusinessHours where IsActive = true limit 1];
         
        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.SVMXC__Active__c = true;
        territory.SVMXC__Territory_s_Business_Hours__c = lBH[0].Id;
        insert territory;
        
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'team1';
        team.SVMXC__Active__c = true;
        insert team;
    
        SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c();
        tech1.Name = 'tech1';
        tech1.SVMXC__Service_Territory__c = territory.Id;
        tech1.SVMXC__Service_Group__c = team.Id;
        tech1.SVMXC__Enable_Scheduling__c = true;
        insert tech1;
        return tech1;
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
        settingProc_GLOB001_GBL022.SVMXC__Default_Value__c = 'OptiMaxEco,ServicePower';
        settingProc_GLOB001_GBL022.SVMXC__Setting_Type__c = 'Global';
        settingProc_GLOB001_GBL022.SVMXC__Search_Order__c = 'Global';
        settingProc_GLOB001_GBL022.SVMXC__Active__c = true;
        settingProc_GLOB001_GBL022.SVMXC__IsStandard__c = true;
        settingProc_GLOB001_GBL022.SVMXC__Values__c = 'None,OptiMaxEco,Service Power';
        settingProc_GLOB001_GBL022.SVMXC__Submodule__c = subModProc_GLOB001.id;
        settingProc_GLOB001_GBL022.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
        settingProc_GLOB001_GBL022.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(settingProc_GLOB001_GBL022);
        
        //adding GLOB001 GBL022 Setting Value
        SVMXC__ServiceMax_Config_Data__c conf_GLOB001_GBL022 = new SVMXC__ServiceMax_Config_Data__c();
        conf_GLOB001_GBL022.RecordTypeId = setValTypeId;
        conf_GLOB001_GBL022.SVMXC__Setting_Configuration_Profile__c = confProfile_GLOB001_GBL007.id;
        conf_GLOB001_GBL022.SVMXC__Display_Value__c = 'OptiMaxEco, ServicePower';
        //SVMXC__Internal_Value__c
        conf_GLOB001_GBL022.SVMXC__Internal_Value__c = 'OptiMaxEco, ServicePower';
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
        
        //adding OMAX001 Process SubModule
        SVMXC__ServiceMax_Processes__c subModProc_OMAX001 = new SVMXC__ServiceMax_Processes__c();
        subModProc_OMAX001.RecordTypeId = subModTypeId;
        subModProc_OMAX001.SVMXC__SubmoduleID__c = 'OMAX001';
        subModProc_OMAX001.SVMXC__Name__c = 'Manage OptiMax Settings';
        subModProc_OMAX001.SVMXC__IsStandard__c = true;
        subModProc_OMAX001.SVMXC__Module__c = modProc_OMAX.id;
        subModProc_OMAX001.SVMXC__Description__c = 'TEST SUBMODULE DESCRIPTION';
        subModProc_OMAX001.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(subModProc_OMAX001);
        
        //adding OMAX001 SET00999 Process Setting
        SVMXC__ServiceMax_Processes__c settingProc_OMAX001_SET00999 = new SVMXC__ServiceMax_Processes__c();
        settingProc_OMAX001_SET00999.RecordTypeId = setTypeId;
        settingProc_OMAX001_SET00999.SVMXC__SettingID__c = 'SET00999';
        settingProc_OMAX001_SET00999.SVMXC__Data_Type__c = 'Boolean';
        settingProc_OMAX001_SET00999.SVMXC__Default_Value__c = 'True';
        settingProc_OMAX001_SET00999.SVMXC__Setting_Type__c = 'Global';
        settingProc_OMAX001_SET00999.SVMXC__Search_Order__c = 'Global';
        settingProc_OMAX001_SET00999.SVMXC__Active__c = true;
        settingProc_OMAX001_SET00999.SVMXC__IsStandard__c = false;
        settingProc_OMAX001_SET00999.SVMXC__Values__c = 'TRUE~|~FALSE';
        settingProc_OMAX001_SET00999.SVMXC__Submodule__c = subModProc_OMAX001.id;
        settingProc_OMAX001_SET00999.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
        settingProc_OMAX001_SET00999.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(settingProc_OMAX001_SET00999);
        
        //associating OMAX001 SET00999 Setting Value to a Global profile defined above
        SVMXC__ServiceMax_Config_Data__c conf_OMAX001_SET00999 = new SVMXC__ServiceMax_Config_Data__c();
        conf_OMAX001_SET00999.RecordTypeId = setValTypeId;
        conf_OMAX001_SET00999.SVMXC__Setting_Configuration_Profile__c = confProfile_GLOB001_GBL007.id;
        conf_OMAX001_SET00999.SVMXC__Display_Value__c = 'True';
        conf_OMAX001_SET00999.SVMXC__Internal_Value__c = 'True';
        conf_OMAX001_SET00999.SVMXC__Setting_ID__c = settingProc_OMAX001_SET00999.id;
        conf_OMAX001_SET00999.SVMXC__Active__c = true; //
        conf_OMAX001_SET00999.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(conf_OMAX001_SET00999);
        
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