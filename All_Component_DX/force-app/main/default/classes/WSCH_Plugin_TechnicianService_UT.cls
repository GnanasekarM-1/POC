@isTest(seeAllData = false)
public with sharing class WSCH_Plugin_TechnicianService_UT {
    
    static testMethod void testPluginTechnicianService() {
    	
    	//need to refer the TriggerHandler_UT to set the setting data
    	/*
    	//adding GLOB001 GBL007 Configuration Profile
        SVMXC__ServiceMax_Config_Data__c confProfile_OMAX001_SET00999 = new SVMXC__ServiceMax_Config_Data__c();
        confProfile_OMAX001_SET00999.SVMXC__Profile_Name__c = 'TestSvmxOmax';
        confProfile_OMAX001_SET00999.RecordTypeId = confProfileTypeId;
        confProfile_OMAX001_SET00999.SVMXC__Configuration_Type__c = 'Global';
        confProfile_OMAX001_SET00999.SVMXC__Active__c = true;
        confProfile_OMAX001_SET00999.SVMXC__IsDefault__c = true;
        confProfile_OMAX001_SET00999.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(confProfile_OMAX001_SET00999);
        
        //adding GLOB001 GBL007 Setting Value
        SVMXC__ServiceMax_Config_Data__c conf_OMAX001_SET00999 = new SVMXC__ServiceMax_Config_Data__c();
        conf_OMAX001_SET00999.RecordTypeId = setValTypeId;
        conf_OMAX001_SET00999.SVMXC__Setting_Configuration_Profile__c = confProfile_GLOB001_GBL007.id;
        conf_OMAX001_SET00999.SVMXC__Display_Value__c = 'True';
        conf_OMAX001_SET00999.SVMXC__Internal_Value__c = 'True';
        conf_OMAX001_SET00999.SVMXC__Setting_ID__c = settingProc_GLOB001_GBL007.id;
        conf_OMAX001_SET00999.SVMXC__Active__c = true; //
        conf_OMAX001_SET00999.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(conf_GLOB001_GBL007);*/
    	
    	List<SVMXC__SVMX_Optimizer__c> listOptTrans = new List<SVMXC__SVMX_Optimizer__c>();
    	
    	SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
	    team.Name = 'team1';
	    insert team;
    	
    	SVMXC__Service_Group_Members__c technician1 = new SVMXC__Service_Group_Members__c();
	    technician1.Name = 'Tech1';
	    technician1.SVMXC__Service_Group__c = team.Id;
	    insert technician1;
	    
	    SVMXC__Service_Group_Members__c technician2 = new SVMXC__Service_Group_Members__c();
	    technician2.Name = 'Tech2';
	    technician2.SVMXC__Service_Group__c = team.Id;
	    insert technician2;
	    
	    SVMXC__SVMX_Optimizer__c svmxOptTrans1 = new SVMXC__SVMX_Optimizer__c();
	    //svmxOptTrans1.Name = 'optTrans1';
	    svmxOptTrans1.SVMXC__Optimizer_Change_Token__c = 'CHANGE_REMOVE_TECH';
	    svmxOptTrans1.SVMXC__WhatId__c = technician1.id;
	    insert svmxOptTrans1;
	    listOptTrans.add(svmxOptTrans1);
	    
	    WSCH_Plugin_TechnicianService.manageTechnicians(listOptTrans);
	    
	    SVMXC__SVMX_Optimizer__c svmxOptTrans2 = new SVMXC__SVMX_Optimizer__c();
	    //svmxOptTrans2.Name = 'optTrans2';
	    svmxOptTrans2.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CREATE_TECH';
	    svmxOptTrans2.SVMXC__WhatId__c = technician2.id;
	    insert svmxOptTrans2;
	    
	    listOptTrans = new List<SVMXC__SVMX_Optimizer__c>();
	    listOptTrans.add(svmxOptTrans2);
	    
    	WSCH_Plugin_TechnicianService.manageTechnicians(listOptTrans);
    }
}