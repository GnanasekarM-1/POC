@isTest(seeAllData = false)
public with sharing class WSCH_Provider_ECO_Callout_Helper_UT {
    
    //This method Optimization Settings GLOB001_GBL007 & GLOB001_GBL022
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
    
    static testMethod void testEcoCalloutHelper() {
    	
    	createOptimizationSettings();
    	
    	WSCH_Provider_ECO_Callout_Helper callOutHelper = new WSCH_Provider_ECO_Callout_Helper();
    	
    	String requestJson = '{"workOrders":[{"workOrderType":"NEW","workOrderId":"WO-00015361","visitDuration":3600.0,"serviceTimes":[{"workingHoursEnd":"2016-12-03T01:00:00.000Z","workingHoursBegin":"2016-12-02T17:00:00.000Z"}],"requiredProduct":null,"requiredExpertise":null,"qualifiedTechnicians":[],"priority":5.0,"preferredResourcePriority":5.0,"preferredResourceId":"null_null","operationType":"add","mandatoryTechnicians":[],"location":{"longitude":-117.229739,"latitude":34.051113},"importance":5,"bannedTechnicians":[],"address":"CA, 90005"}],"territoryId":"a2Q2A0000005tBQUAY","svmxVersion":"16.29023","orgId":"00DF0000000ww8s","geoCodingEnabled":"true","dispatchProcessId":"a1l2A000005wTHMQA2"}';
    	
    	WSCH_Provider_ECO_Callout_Helper.callOut(requestJson, '/v1/schedule-services', '/manageWorkOrders/');
    }

    static testMethod void testEcoCalloutHelperNew() {
    	
    	createOptimizationSettings();
    	
    	WSCH_Provider_ECO_Callout_Helper callOutHelper = new WSCH_Provider_ECO_Callout_Helper();
    	
    	String requestJson = '{"workOrders":[{"workOrderType":"NEW","workOrderId":"WO-00015361","visitDuration":3600.0,"serviceTimes":[{"workingHoursEnd":"2016-12-03T01:00:00.000Z","workingHoursBegin":"2016-12-02T17:00:00.000Z"}],"requiredProduct":null,"requiredExpertise":null,"qualifiedTechnicians":[],"priority":5.0,"preferredResourcePriority":5.0,"preferredResourceId":"null_null","operationType":"add","mandatoryTechnicians":[],"location":{"longitude":-117.229739,"latitude":34.051113},"importance":5,"bannedTechnicians":[],"address":"CA, 90005"}],"territoryId":"a2Q2A0000005tBQUAY","svmxVersion":"16.29023","orgId":"00DF0000000ww8s","geoCodingEnabled":"true","dispatchProcessId":"a1l2A000005wTHMQA2"}';
    	
    	WSCH_Provider_ECO_Callout_Helper.apptOfferCallOut(requestJson, '/v1/schedule-services', '/bookAppointment/');

    	WSCH_Provider_ECO_Callout_Helper.bookApptCallOut(requestJson, '/v1/schedule-services', '/getAppointmentOffers/');
    	
    }    
    
}