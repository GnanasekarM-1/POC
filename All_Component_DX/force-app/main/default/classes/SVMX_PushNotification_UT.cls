@isTest

public with sharing class SVMX_PushNotification_UT 
{
	static void insertTestData()
	{
		Id sfdcProfileId = userinfo.getProfileId();
		String strInstlltnKey = EncodingUtil.base64Encode(Blob.valueOf(UserInfo.getOrganizationId().subString(0,15)));
		Id configProfileRecordTypeId,confAccessRecTypeId,mobConfigRecordTypeId,moduleRecTypeId,subModuleRecTypeId,settingRecTypeId,settingValueRecTypeId;
        //Getting record Type Ids
        for(RecordType rType : [select Id, DeveloperName, SobjectType from Recordtype where (SobjectType =: 'SVMXC__ServiceMax_Config_Data__c' and DeveloperName =: 'Configuration_Profile') 
        OR (SobjectType =: 'SVMXC__ServiceMax_Config_Data__c' and DeveloperName =:'Configuration_Access') 
        OR (SobjectType =: 'SVMXC__ServiceMax_Config_Data__c' and DeveloperName =:'Mobile_Configuration') 
        OR (SobjectType =:'SVMXC__ServiceMax_Processes__c' and DeveloperName =:'Module') 
        OR (SobjectType =:'SVMXC__ServiceMax_Processes__c' and DeveloperName =:'Submodule') 
        OR (SobjectType =: 'SVMXC__ServiceMax_Config_Data__c' AND DeveloperName =: 'Setting_Value')
        OR (SobjectType =:'SVMXC__ServiceMax_Processes__c' and DeveloperName =:'Settings')])
        {
            if(rType.SobjectType == 'SVMXC__ServiceMax_Config_Data__c' && rType.DeveloperName =='Configuration_Profile')
            {
                configProfileRecordTypeId = rType.Id;
            }
            if(rType.SobjectType == 'SVMXC__ServiceMax_Config_Data__c' && rType.DeveloperName =='Configuration_Access')
            {
                confAccessRecTypeId = rType.Id;
            }
            if(rType.SobjectType == 'SVMXC__ServiceMax_Config_Data__c' && rType.DeveloperName =='Mobile_Configuration')
            {
                mobConfigRecordTypeId = rType.Id;
            }
            if(rType.SobjectType == 'SVMXC__ServiceMax_Processes__c' && rType.DeveloperName =='Module')
            {
                moduleRecTypeId = rType.Id;
            }
            if(rType.SobjectType == 'SVMXC__ServiceMax_Processes__c' && rType.DeveloperName =='Submodule')
            {
                subModuleRecTypeId = rType.Id;
            }
            if(rType.SobjectType == 'SVMXC__ServiceMax_Processes__c' && rType.DeveloperName =='Settings')
            {
                settingRecTypeId = rType.Id;
            }
            if(rType.SobjectType == 'SVMXC__ServiceMax_Config_Data__c' && rType.DeveloperName =='Setting_Value')
            {
                settingValueRecTypeId = rType.Id;
            }
        }
		SVMXC__ServiceMax_Processes__c module = new SVMXC__ServiceMax_Processes__c(SVMXC__Name__c='ServiceMax iPad Client',RecordTypeId = moduleRecTypeId,SVMXC__ModuleID__c='IPAD',SVMXC__IsStandard__c=true,SVMXC__Installation_Key__c = strInstlltnKey);
		insert module;
		SVMXC__ServiceMax_Processes__c submodule = new SVMXC__ServiceMax_Processes__c(SVMXC__Name__c='Synchronization',RecordTypeId = subModuleRecTypeId,SVMXC__Module__c=module.Id,SVMXC__SubmoduleID__c='IPAD018',SVMXC__IsStandard__c=true,SVMXC__Installation_Key__c = strInstlltnKey);
		insert submodule;
		SVMXC__ServiceMax_Processes__c settingValue = new SVMXC__ServiceMax_Processes__c(SVMXC__Name__c='Enable Push Notification',RecordTypeId = settingRecTypeId,SVMXC__SubModule__c=submodule.Id,SVMXC__SettingID__c='SET017',SVMXC__IsStandard__c=true,SVMXC__Installation_Key__c = strInstlltnKey);
		insert settingValue;
		
		//Setting - IPAD018_SET009
        SVMXC__ServiceMax_Processes__c settingProcess = new SVMXC__ServiceMax_Processes__c(RecordTypeId = settingRecTypeId , SVMXC__Name__c='Enable Push Notification', 
        SVMXC__Search_Order__c = 'Group,Global',SVMXC__Setting_Type__c = 'Group',SVMXC__Values__c = 'True~|~False',SVMXC__SubmoduleID__c = 'IPAD018',
        SVMXC__Data_Type__c = 'Boolean',SVMXC__Default_Value__c = 'false',SVMXC__Description__c = 'Enable Push Notification.',
        SVMXC__Submodule__c = submodule.Id,SVMXC__SettingID__c = 'SET017',SVMXC__Active__c= true ,SVMXC__Installation_Key__c = strInstlltnKey); 
        insert settingProcess;
		
        //insert profile related processes and config data
        SVMXC__ServiceMax_Config_Data__c configProfile = new SVMXC__ServiceMax_Config_Data__c();
        configProfile.SVMXC__Profile_Name__c = 'Test User Profile';
        configProfile.RecordTypeId = configProfileRecordTypeId;
        configProfile.SVMXC__Configuration_Type__c = 'Group';
        configProfile.SVMXC__Active__c = true;
        insert configProfile;
        
        SVMXC__ServiceMax_Config_Data__c accessProfile = new SVMXC__ServiceMax_Config_Data__c();
        accessProfile.SVMXC__Action_Type__c = 'Set Value';
        accessProfile.SVMXC__Profile__c = sfdcProfileId;
        accessProfile.RecordTypeId = confAccessRecTypeId;
        accessProfile.SVMXC__Active__c = true;
        accessProfile.SVMXC__Access_Configuration_Profile__c = configProfile.Id;
        insert accessProfile;

		//Setting Value
        SVMXC__ServiceMax_Config_Data__c settingValueConfig = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = settingValueRecTypeId , 
        SVMXC__Setting_Configuration_Profile__c = configProfile.Id, SVMXC__Setting_ID__c =  settingProcess.Id, SVMXC__Internal_Value__c = 'True');
        insert settingValueConfig;	        
	}
	static void insertMobTestData()
	{
		Id sfdcProfileId = userinfo.getProfileId();
		String strInstlltnKey = EncodingUtil.base64Encode(Blob.valueOf(UserInfo.getOrganizationId().subString(0,15)));
		Id configProfileRecordTypeId,confAccessRecTypeId,mobConfigRecordTypeId,moduleRecTypeId,subModuleRecTypeId,settingRecTypeId,settingValueRecTypeId;
        //Getting record Type Ids
        for(RecordType rType : [select Id, DeveloperName, SobjectType from Recordtype where (SobjectType =: 'SVMXC__ServiceMax_Config_Data__c' and DeveloperName =: 'Configuration_Profile') 
        OR (SobjectType =: 'SVMXC__ServiceMax_Config_Data__c' and DeveloperName =:'Configuration_Access') 
        OR (SobjectType =: 'SVMXC__ServiceMax_Config_Data__c' and DeveloperName =:'Mobile_Configuration') 
        OR (SobjectType =:'SVMXC__ServiceMax_Processes__c' and DeveloperName =:'Module') 
        OR (SobjectType =:'SVMXC__ServiceMax_Processes__c' and DeveloperName =:'Submodule') 
        OR (SobjectType =: 'SVMXC__ServiceMax_Config_Data__c' AND DeveloperName =: 'Setting_Value')
        OR (SobjectType =:'SVMXC__ServiceMax_Processes__c' and DeveloperName =:'Settings')])
        {
            if(rType.SobjectType == 'SVMXC__ServiceMax_Config_Data__c' && rType.DeveloperName =='Configuration_Profile')
            {
                configProfileRecordTypeId = rType.Id;
            }
            if(rType.SobjectType == 'SVMXC__ServiceMax_Config_Data__c' && rType.DeveloperName =='Configuration_Access')
            {
                confAccessRecTypeId = rType.Id;
            }
            if(rType.SobjectType == 'SVMXC__ServiceMax_Config_Data__c' && rType.DeveloperName =='Mobile_Configuration')
            {
                mobConfigRecordTypeId = rType.Id;
            }
            if(rType.SobjectType == 'SVMXC__ServiceMax_Processes__c' && rType.DeveloperName =='Module')
            {
                moduleRecTypeId = rType.Id;
            }
            if(rType.SobjectType == 'SVMXC__ServiceMax_Processes__c' && rType.DeveloperName =='Submodule')
            {
                subModuleRecTypeId = rType.Id;
            }
            if(rType.SobjectType == 'SVMXC__ServiceMax_Processes__c' && rType.DeveloperName =='Settings')
            {
                settingRecTypeId = rType.Id;
            }
            if(rType.SobjectType == 'SVMXC__ServiceMax_Config_Data__c' && rType.DeveloperName =='Setting_Value')
            {
                settingValueRecTypeId = rType.Id;
            }
        }
		SVMXC__ServiceMax_Processes__c module = new SVMXC__ServiceMax_Processes__c(SVMXC__Name__c='Mobile Notification',RecordTypeId = moduleRecTypeId,SVMXC__ModuleID__c='MOBN',SVMXC__IsStandard__c=true,SVMXC__Installation_Key__c = strInstlltnKey);
		insert module;
		SVMXC__ServiceMax_Processes__c submodule = new SVMXC__ServiceMax_Processes__c(SVMXC__Name__c='Pulse',RecordTypeId = subModuleRecTypeId,SVMXC__Module__c=module.Id,SVMXC__SubmoduleID__c='MOBN001',SVMXC__IsStandard__c=true,SVMXC__Installation_Key__c = strInstlltnKey);
		insert submodule;
		SVMXC__ServiceMax_Processes__c settingValue = new SVMXC__ServiceMax_Processes__c(SVMXC__Name__c='Enable Push Notification',RecordTypeId = settingRecTypeId,SVMXC__SubModule__c=submodule.Id,SVMXC__SettingID__c='SET001',SVMXC__IsStandard__c=true,SVMXC__Installation_Key__c = strInstlltnKey);
		insert settingValue;
		
		//Setting - IPAD018_SET009
        SVMXC__ServiceMax_Processes__c settingProcess = new SVMXC__ServiceMax_Processes__c(RecordTypeId = settingRecTypeId , SVMXC__Name__c='Enable Push Notification', 
        SVMXC__Search_Order__c = 'Group,Global',SVMXC__Setting_Type__c = 'Group',SVMXC__Values__c = 'True~|~False',SVMXC__SubmoduleID__c = 'MOBN001',
        SVMXC__Data_Type__c = 'Boolean',SVMXC__Default_Value__c = 'false',SVMXC__Description__c = 'Enable Push Notification.',
        SVMXC__Submodule__c = submodule.Id,SVMXC__SettingID__c = 'SET001',SVMXC__Active__c= true ,SVMXC__Installation_Key__c = strInstlltnKey); 
        insert settingProcess;
		
        //insert profile related processes and config data
        SVMXC__ServiceMax_Config_Data__c configProfile = new SVMXC__ServiceMax_Config_Data__c();
        configProfile.SVMXC__Profile_Name__c = 'Test User Profile';
        configProfile.RecordTypeId = configProfileRecordTypeId;
        configProfile.SVMXC__Configuration_Type__c = 'Group';
        configProfile.SVMXC__Active__c = true;
        insert configProfile;
        
        SVMXC__ServiceMax_Config_Data__c accessProfile = new SVMXC__ServiceMax_Config_Data__c();
        accessProfile.SVMXC__Action_Type__c = 'Set Value';
        accessProfile.SVMXC__Profile__c = sfdcProfileId;
        accessProfile.RecordTypeId = confAccessRecTypeId;
        accessProfile.SVMXC__Active__c = true;
        accessProfile.SVMXC__Access_Configuration_Profile__c = configProfile.Id;
        insert accessProfile;

		//Setting Value
        SVMXC__ServiceMax_Config_Data__c settingValueConfig = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = settingValueRecTypeId , 
        SVMXC__Setting_Configuration_Profile__c = configProfile.Id, SVMXC__Setting_ID__c =  settingProcess.Id, SVMXC__Internal_Value__c = 'True');
        insert settingValueConfig;
	}  
    static testMethod void testImmediately()
    {
    	insertTestData();
        String RTProRule, RTConfigExp;
        map<Id, sObject> newMapOfIdToSObj = new map<Id, sObject>();
        List<string> lstRTNames = new List<string>{'SVMX Rule', 'Expressions'};
        SVMXC__ServiceMax_Config_Data__c selectedNotification = new SVMXC__ServiceMax_Config_Data__c();
        SVMX_PushNotification obj = new SVMX_PushNotification();
        
        for(RecordType RT : [SELECT Id, Name FROM RecordType WHERE Name IN: lstRTNames])
        {
            if(RT.Name == 'SVMX Rule')
                RTProRule = RT.Id;
            else if(RT.Name == 'Expressions')
                RTConfigExp = RT.Id;
        }
        
        SVMXC__ServiceMax_Processes__c expPro = new SVMXC__ServiceMax_Processes__c(RecordTypeId = RTProRule, SVMXC__Name__c = 'ExpProcess001', SVMXC__ProcessID__c = 'ExpProcess001', SVMXC__Source_Object_Name__c ='SVMXC__Service_Order__c', SVMXC__Rule_Type__c='Named Expression',SVMXC__SettingId__c = 'ExpProcess001');
        insert expPro;
        
        SVMXC__ServiceMax_Config_Data__c expDtl1 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 1, SVMXC__Field_Name__c = 'SVMXC__Order_Status__c', SVMXC__Operator__c = 'eq', SVMXC__Operand__c = 'Open', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'PICKLIST');
        insert expDtl1;
        
        SVMXC__ServiceMax_Config_Data__c expDtl2 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 2, SVMXC__Field_Name__c = 'SVMXC__Priority__c', SVMXC__Operator__c = 'eq', SVMXC__Operand__c = 'High', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'PICKLIST');
        insert expDtl2;
        
        selectedNotification.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        selectedNotification.SVMXC__Dispatch_Process__c = expPro.Id;
        selectedNotification.SVMXC__Display_Value__c = '1';
        selectedNotification.SVMXC__Internal_Value__c = 'WO Updated';
        selectedNotification.SVMXC__Description__c = 'to [$SVMXC__Company__c]';
        selectedNotification.SVMXC__Parameter_Name__c = 'Immediately';
        selectedNotification.SVMXC__Profile_Name__c = 'Test Notification1';
        selectedNotification.SVMXC__Active__c = True;
        selectedNotification.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__Closed_By__c';
        selectedNotification.SVMXC__Profile__c = 'abc@servicemax.com,xyz@servicemax.com';
        selectedNotification.SVMXC__Display_Type__c = 'Push Notification';
        selectedNotification.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Mobile Configuration' Limit 1][0].Id;
        system.debug(LoggingLevel.WARN, 'First Notification = ' + selectedNotification);
        insert selectedNotification;
        
        Account acc = new Account();
        acc.Name = 'Test Account1';
        insert acc;
		Test.startTest();
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Order_Status__c = 'Open';
        wo.SVMXC__Priority__c='High';
        wo.SVMXC__Company__c = acc.Id;
        wo.SVMXC__Closed_By__c = [SELECT Id FROM User Limit 1][0].Id;
        SVMXC__SM_SNS_Detail__c newDetails = new SVMXC__SM_SNS_Detail__c(SVMXC__SM_IsActive__c =true,SVMXC__SM_Status__c ='Registered',SVMXC__SM_User__c =[SELECT Id FROM User Limit 1][0].Id,SVMXC__SM_TargetArn__c ='1');
        insert newDetails;
        newDetails = new SVMXC__SM_SNS_Detail__c(SVMXC__SM_IsActive__c =true,SVMXC__SM_Status__c ='Registered',SVMXC__SM_User__c =[SELECT Id FROM User Limit 1][0].Id,SVMXC__SM_TargetArn__c ='1');
        insert newDetails;         
        insert wo;       
        newMapOfIdToSObj.put(wo.Id, wo);
        obj.routingPN(newMapOfIdToSObj, 'SVMXC__Service_Order__c', '1', new map<String, String>());
        obj.sendNotification(newMapOfIdToSObj, 'SVMXC__Service_Order__c', '1', new map<String, String>(),true);        
        obj.sendNotification(newMapOfIdToSObj, 'SVMXC__Service_Order__c', '1', new map<String, String>(),false);                
		Test.stopTest();
    }
    static testmethod void eventTestingoldSetting()
    {
    	insertTestData();
    	Account acc = new Account();
        acc.Name = 'Test Account1';
        insert acc;
    	SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Order_Status__c = 'Open';
        wo.SVMXC__Priority__c='High';
        wo.SVMXC__Company__c = acc.Id;
        wo.SVMXC__Closed_By__c = [SELECT Id FROM User Limit 1][0].Id;
        insert wo; 
    	Test.startTest();
		Event evntObj = new Event();
        evntObj.OwnerId = UserInfo.getUserId();
        evntObj.StartDateTime = DateTime.now();
        evntObj.DurationInMinutes = 60;
        evntObj.EndDateTime = DateTime.now().addHours(1);
        evntObj.WhatId = wo.Id;
        insert evntObj;
        evntObj.subject = '50';
        update evntObj;
        Test.stopTest();
    }	
    static testmethod void eventTestingNewSetting()
    {
    	insertMobTestData();
    	Account acc = new Account();
        acc.Name = 'Test Account1';
        insert acc;
    	SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Order_Status__c = 'Open';
        wo.SVMXC__Priority__c='High';
        wo.SVMXC__Company__c = acc.Id;
        wo.SVMXC__Closed_By__c = [SELECT Id FROM User Limit 1][0].Id;
        insert wo; 
    	Test.startTest();
		Event evntObj = new Event();
        evntObj.OwnerId = UserInfo.getUserId();
        evntObj.StartDateTime = DateTime.now();
        evntObj.DurationInMinutes = 60;
        evntObj.EndDateTime = DateTime.now().addHours(1);
        evntObj.WhatId = wo.Id;
        insert evntObj;
        evntObj.subject = '50';
        update evntObj;
        Test.stopTest();
    }    
    static testmethod void svmxEventTestoldSetting()
    {
    	insertTestData();
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.SVMXC__Active__c = true;
        team.Name = 'Test Team';
        insert team;
        
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'Test Technician';
        technician.SVMXC__Salesforce_User__c = UserInfo.getUserId();
        technician.SVMXC__Service_Group__c = team.Id;
        technician.SVMXC__Active__c = true;
        insert technician;
        Account acc = new Account();
        acc.Name = 'Test Account1';
        insert acc;
    	SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Order_Status__c = 'Open';
        wo.SVMXC__Priority__c='High';
        wo.SVMXC__Company__c = acc.Id;
        wo.SVMXC__Closed_By__c = [SELECT Id FROM User Limit 1][0].Id;
        insert wo;
        Test.startTest();
        SVMXC__SVMX_Event__c svmxEvent = new SVMXC__SVMX_Event__c();
        svmxEvent.Name = 'Test Subject';
        svmxEvent.SVMXC__StartDateTime__c = DateTime.now();
        svmxEvent.SVMXC__EndDateTime__c = DateTime.now().addHours(1);
        svmxEvent.SVMXC__Technician__c = technician.Id;
        svmxEvent.SVMXC__WhatId__c = wo.Id;
        insert svmxEvent;
        
        svmxEvent.Name='Testing';
        svmxEvent.SVMXC__EndDateTime__c=DateTime.now().addHours(2);
        update svmxEvent;
        Test.stopTest();
    }	
    static testmethod void svmxEventTestNewSetting()
    {
    	insertMobTestData();
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.SVMXC__Active__c = true;
        team.Name = 'Test Team';
        insert team;
        
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'Test Technician';
        technician.SVMXC__Salesforce_User__c = UserInfo.getUserId();
        technician.SVMXC__Service_Group__c = team.Id;
        technician.SVMXC__Active__c = true;
        insert technician;
        Account acc = new Account();
        acc.Name = 'Test Account1';
        insert acc;
    	SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Order_Status__c = 'Open';
        wo.SVMXC__Priority__c='High';
        wo.SVMXC__Company__c = acc.Id;
        wo.SVMXC__Closed_By__c = [SELECT Id FROM User Limit 1][0].Id;
        insert wo;
        Test.startTest();
        SVMXC__SVMX_Event__c svmxEvent = new SVMXC__SVMX_Event__c();
        svmxEvent.Name = 'Test Subject';
        svmxEvent.SVMXC__StartDateTime__c = DateTime.now();
        svmxEvent.SVMXC__EndDateTime__c = DateTime.now().addHours(1);
        svmxEvent.SVMXC__Technician__c = technician.Id;
        svmxEvent.SVMXC__WhatId__c = wo.Id;
        insert svmxEvent;
        
        svmxEvent.Name='Testing';
        svmxEvent.SVMXC__EndDateTime__c=DateTime.now().addHours(2);
        update svmxEvent;
        Test.stopTest();
    }    
    static testMethod void testBusinessHours()
    {
    	insertTestData();
        String RTProRule, RTConfigExp;
        map<Id, sObject> newMapOfIdToSObj = new map<Id, sObject>();
        List<string> lstRTNames = new List<string>{'SVMX Rule', 'Expressions'};
        SVMXC__ServiceMax_Config_Data__c selectedNotification1 = new SVMXC__ServiceMax_Config_Data__c();
        SVMX_PushNotification obj = new SVMX_PushNotification();
        
        for(RecordType RT : [SELECT Id, Name FROM RecordType WHERE Name IN: lstRTNames])
        {
            if(RT.Name == 'SVMX Rule')
                RTProRule = RT.Id;
            else if(RT.Name == 'Expressions')
                RTConfigExp = RT.Id;
        }
        
        SVMXC__ServiceMax_Processes__c expPro = new SVMXC__ServiceMax_Processes__c(RecordTypeId = RTProRule, SVMXC__Name__c = 'ExpProcess001', SVMXC__ProcessID__c = 'ExpProcess001', SVMXC__Source_Object_Name__c ='SVMXC__Service_Order__c', SVMXC__Rule_Type__c='Named Expression',SVMXC__SettingId__c = 'ExpProcess001');
        insert expPro;
        
        SVMXC__ServiceMax_Config_Data__c expDtl = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 1, SVMXC__Field_Name__c = 'SVMXC__Order_Status__c', SVMXC__Operator__c = 'eq', SVMXC__Operand__c = 'Open', SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'PICKLIST');
        insert expDtl;
        
        //2nd Notification
        selectedNotification1.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        selectedNotification1.SVMXC__Dispatch_Process__c = expPro.Id;
        selectedNotification1.SVMXC__Display_Value__c = '1';
        selectedNotification1.SVMXC__Internal_Value__c = 'WO Updated';
        selectedNotification1.SVMXC__Description__c = 'This record [$SVMXC__Order_Status__c] is updated';
        selectedNotification1.SVMXC__Parameter_Name__c = 'Business Hours';
        selectedNotification1.SVMXC__Profile_Name__c = 'Test Notification2';
        selectedNotification1.SVMXC__Active__c = True;
        selectedNotification1.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__Closed_By__c';
        selectedNotification1.SVMXC__Profile__c = 'abc@servicemax.com,xyz@servicemax.com';
        selectedNotification1.SVMXC__Display_Type__c = 'Push Notification';
        selectedNotification1.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Mobile Configuration' Limit 1][0].Id;
        system.debug(LoggingLevel.WARN, 'Second Notification = ' + selectedNotification1);
        insert selectedNotification1;
        
        
        Account acc = new Account();
        acc.Name = 'Test Account2';
        insert acc;
        
        /*BusinessHours bussHrs = new BusinessHours();
        bussHrs.Name = 'Test Bussiness Hours'; 
        bussHrs.IsActive = true;
        insert bussHrs;
        List<BusinessHours> lstBusinessHrs = new List<BusinessHours>();
        lstBusinessHrs = [SELECT Id, Name, IsActive, IsDefault FROM BusinessHours limit 1];*/
        Test.startTest();
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Order_Status__c = 'Open';
        wo.SVMXC__Company__c = acc.Id;
        wo.SVMXC__Closed_By__c = [SELECT Id FROM User Limit 1][0].Id;
        insert wo;
        
        newMapOfIdToSObj.put(wo.Id, wo);
        obj.routingPN(newMapOfIdToSObj, 'SVMXC__Service_Order__c', '1', new map<String, String>());
        obj.sendNotification(newMapOfIdToSObj, 'SVMXC__Service_Order__c', '1', new map<String, String>(),true);        
        obj.sendNotification(newMapOfIdToSObj, 'SVMXC__Service_Order__c', '1', new map<String, String>(),false);                
        Test.stopTest();
    }
    static testMethod void testImmediatelyWithRefDTDataType()
    {
    	insertTestData();
        String RTProRule, RTConfigExp;
        map<Id, sObject> newMapOfIdToSObj = new map<Id, sObject>();
        List<string> lstRTNames = new List<string>{'SVMX Rule', 'Expressions'};
        SVMXC__ServiceMax_Config_Data__c selectedNotification = new SVMXC__ServiceMax_Config_Data__c();
        SVMX_PushNotification obj = new SVMX_PushNotification();
        
        for(RecordType RT : [SELECT Id, Name FROM RecordType WHERE Name IN: lstRTNames])
        {
            if(RT.Name == 'SVMX Rule')
                RTProRule = RT.Id;
            else if(RT.Name == 'Expressions')
                RTConfigExp = RT.Id;
        }
        
        SVMXC__ServiceMax_Processes__c expPro = new SVMXC__ServiceMax_Processes__c(RecordTypeId = RTProRule, SVMXC__Name__c = 'ExpProcess001', SVMXC__ProcessID__c = 'ExpProcess001', SVMXC__Source_Object_Name__c ='SVMXC__Service_Order__c', SVMXC__Rule_Type__c='Named Expression',SVMXC__SettingId__c = 'ExpProcess001', SVMXC__Advance_Expression__c ='((((1 AND 2 AND 3) OR 4) AND 5 AND 6) AND 7 AND 8 AND 9 AND 10 AND 11 AND 12 AND 13 AND 14 AND 15 AND 16 AND 17 AND 18 AND 19 AND 20 AND 21 AND 22)');
        insert expPro;
        
        SVMXC__ServiceMax_Config_Data__c expDtl1 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 1, SVMXC__Field_Name__c = 'createdDate', SVMXC__Operator__c = 'isnotnull',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DATETIME');
        insert expDtl1;
        
        SVMXC__ServiceMax_Config_Data__c expDtl2 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 2, SVMXC__Field_Name__c = 'SVMXC__Company__c',SVMXC__Field_Relationship_Name__c ='SVMXC__Company__r',SVMXC__FKey_Name_Field__c ='Name', SVMXC__Operator__c = 'isnotnull',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'REFERENCE');
        insert expDtl2;

        SVMXC__ServiceMax_Config_Data__c expDtl3 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 3, SVMXC__Field_Name__c = 'isDeleted', SVMXC__Operator__c = 'eq',SVMXC__Operand__c = 'false',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'BOOLEAN');
        insert expDtl3;
        
        SVMXC__ServiceMax_Config_Data__c expDtl4 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 4, SVMXC__Field_Name__c = 'Name', SVMXC__Operator__c = 'isnotnull',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'STRING');
        insert expDtl4; 
        
        SVMXC__ServiceMax_Config_Data__c expDtl5 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 5, SVMXC__Field_Name__c = 'createdDate', SVMXC__Operator__c = 'ge',SVMXC__Operand__c = 'YESTERDAY',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DATETIME');
        insert expDtl5;
        
        SVMXC__ServiceMax_Config_Data__c expDtl6 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 6, SVMXC__Field_Name__c = 'LastActivityDate', SVMXC__Operator__c = 'lt',SVMXC__Operand__c = 'NEXT_N_DAYS:15',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DATE');
        insert expDtl6;
        
        SVMXC__ServiceMax_Config_Data__c expDtl7 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 7, SVMXC__Field_Name__c = 'SVMXC__Optimizer_Connection_Name__c', SVMXC__Operator__c = 'isnull',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'STRING');
        insert expDtl7;
        
        SVMXC__ServiceMax_Config_Data__c expDtl8 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 8, SVMXC__Field_Name__c = 'SVMXC__Optimizer_Connection_Name__c', SVMXC__Operator__c = 'ne',SVMXC__Operand__c = '15',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'STRING');
        insert expDtl8;

        SVMXC__ServiceMax_Config_Data__c expDtl9 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 9, SVMXC__Field_Name__c = 'Name', SVMXC__Operator__c = 'CONTAINS',SVMXC__Operand__c = 'W',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'STRING');
        insert expDtl9;
        
        SVMXC__ServiceMax_Config_Data__c expDt20 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 10, SVMXC__Field_Name__c = 'isDeleted', SVMXC__Operator__c = 'isnotnull',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'BOOLEAN');
        insert expDt20;
        
        SVMXC__ServiceMax_Config_Data__c expDt21 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 11, SVMXC__Field_Name__c = 'isDeleted', SVMXC__Operator__c = 'eq',SVMXC__Operand__c = 'false',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'BOOLEAN');
        insert expDt21; 
        
        SVMXC__ServiceMax_Config_Data__c expDt22 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 12, SVMXC__Field_Name__c = 'isDeleted', SVMXC__Operator__c = 'ne',SVMXC__Operand__c = 'true',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'BOOLEAN');
        insert expDt22;
        
        SVMXC__ServiceMax_Config_Data__c expDt23 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 13, SVMXC__Field_Name__c = 'SVMXC__Dispatch_Priority__c', SVMXC__Operator__c = 'isnull',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DECIMAL');
        insert expDt23;
        
        SVMXC__ServiceMax_Config_Data__c expDt24 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 14, SVMXC__Field_Name__c = 'LastModifiedById', SVMXC__Field_Relationship_Name__c ='LastModifiedBy',SVMXC__FKey_Name_Field__c ='Name', SVMXC__Operator__c = 'ne',SVMXC__Operand__c = 'NULL',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'REFERENCE');
        insert expDt24; 
        
        SVMXC__ServiceMax_Config_Data__c expDt25 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 15, SVMXC__Field_Name__c = 'Name', SVMXC__Operator__c = 'STARTS',SVMXC__Operand__c = 'W',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'STRING');
        insert expDt25;

        SVMXC__ServiceMax_Config_Data__c expDt26 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 16, SVMXC__Field_Name__c = 'Name', SVMXC__Operator__c = 'NOTCONTAINS',SVMXC__Operand__c = '^',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'STRING');
        insert expDt26;
        
        SVMXC__ServiceMax_Config_Data__c expDt27 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 17, SVMXC__Field_Name__c = 'Name', SVMXC__Operator__c = 'IN',SVMXC__Operand__c = 'W,o',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'STRING');
        insert expDt27;

        SVMXC__ServiceMax_Config_Data__c expDt28 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 18, SVMXC__Field_Name__c = 'Name', SVMXC__Operator__c = 'NOTIN',SVMXC__Operand__c = '^,&',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'STRING');
        insert expDt28;

        SVMXC__ServiceMax_Config_Data__c expDt29 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 19, SVMXC__Field_Name__c = 'SVMXC__Dispatch_Priority__c', SVMXC__Operator__c = 'NOTIN',SVMXC__Operand__c = '5,6',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DECIMAL');
        insert expDt29;
        
        SVMXC__ServiceMax_Config_Data__c expDt30 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 20, SVMXC__Field_Name__c = 'SVMXC__Dispatch_Priority__c', SVMXC__Operator__c = 'ne',SVMXC__Operand__c = '8',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DECIMAL');
        insert expDt30;

        SVMXC__ServiceMax_Config_Data__c expDt31 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 21, SVMXC__Field_Name__c = 'SVMXC__Company__c',SVMXC__Field_Relationship_Name__c ='SVMXC__Company__r',SVMXC__FKey_Name_Field__c ='Name', SVMXC__Operator__c = 'NOTIN',SVMXC__Operand__c = '!,&,^',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'REFERENCE');
        insert expDt31;

        SVMXC__ServiceMax_Config_Data__c expDt32 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 22, SVMXC__Field_Name__c = 'SVMXC__Company__c',SVMXC__Field_Relationship_Name__c ='SVMXC__Company__r',SVMXC__FKey_Name_Field__c ='Name', SVMXC__Operator__c = 'NOTCONTAINS',SVMXC__Operand__c = '!^',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'REFERENCE');
        insert expDt32;        
        
        selectedNotification.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        selectedNotification.SVMXC__Dispatch_Process__c = expPro.Id;
        selectedNotification.SVMXC__Display_Value__c = '1';
        selectedNotification.SVMXC__Internal_Value__c = 'WO Updated';
        selectedNotification.SVMXC__Description__c = 'This work order records Account field is chnaged to [$SVMXC__Company__c]';
        selectedNotification.SVMXC__Parameter_Name__c = 'Immediately';
        selectedNotification.SVMXC__Profile_Name__c = 'Test Notification1';
        selectedNotification.SVMXC__Active__c = True;
        selectedNotification.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__Closed_By__c';
        selectedNotification.SVMXC__Profile__c = 'abc@servicemax.com,xyz@servicemax.com';
        selectedNotification.SVMXC__Display_Type__c = 'Push Notification';
        selectedNotification.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Mobile Configuration' Limit 1][0].Id;
        system.debug(LoggingLevel.WARN, 'First Notification = ' + selectedNotification);
        insert selectedNotification;
        Test.startTest();
        Account acc = new Account();
        acc.Name = 'Test Account1';
        insert acc;

        SVMXC__SVMX_Job_Logs__c newLogs = new SVMXC__SVMX_Job_Logs__c(SVMXC__Operation__c = 'PUSH NOTIFICATION',SVMXC__Event_Name__c ='Test Notification1');
        insert newLogs;
        
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Order_Status__c = 'Open';
        wo.SVMXC__Priority__c='High';
        wo.SVMXC__Company__c = acc.Id;
        wo.SVMXC__Closed_By__c = [SELECT Id FROM User Limit 1][0].Id;
        SVMXC__SM_SNS_Detail__c newDetails = new SVMXC__SM_SNS_Detail__c(SVMXC__SM_IsActive__c =true,SVMXC__SM_Status__c ='Registered',SVMXC__SM_User__c =[SELECT Id FROM User Limit 1][0].Id,SVMXC__SM_TargetArn__c ='1');
        insert newDetails;
        newDetails = new SVMXC__SM_SNS_Detail__c(SVMXC__SM_IsActive__c =true,SVMXC__SM_Status__c ='Registered',SVMXC__SM_User__c =[SELECT Id FROM User Limit 1][0].Id,SVMXC__SM_TargetArn__c ='1');
        insert newDetails;         
        insert wo;       
        newMapOfIdToSObj.put(wo.Id, wo);
        Map<String,String> mapOfSettingValues = new Map<String,String>();
        mapOfSettingValues.put('SET004','Solution,GroupMember');
        mapOfSettingValues.put('SET021','300');
        mapOfSettingValues.put('SET020','Spr16');        
        obj.routingPN(newMapOfIdToSObj, 'SVMXC__Service_Order__c', '1', mapOfSettingValues);
        obj.sendNotification(newMapOfIdToSObj, 'SVMXC__Service_Order__c', '1', mapOfSettingValues,true);        
        obj.sendNotification(newMapOfIdToSObj, 'SVMXC__Service_Order__c', '1', mapOfSettingValues,false);
        Test.stopTest();                        
    }  
    static testMethod void testImmediatelyWithNumberDataType()
    {
    	insertTestData();
        String RTProRule, RTConfigExp;
        map<Id, sObject> newMapOfIdToSObj = new map<Id, sObject>();
        List<string> lstRTNames = new List<string>{'SVMX Rule', 'Expressions'};
        SVMXC__ServiceMax_Config_Data__c selectedNotification = new SVMXC__ServiceMax_Config_Data__c();
        SVMX_PushNotification obj = new SVMX_PushNotification();
        
        for(RecordType RT : [SELECT Id, Name FROM RecordType WHERE Name IN: lstRTNames])
        {
            if(RT.Name == 'SVMX Rule')
                RTProRule = RT.Id;
            else if(RT.Name == 'Expressions')
                RTConfigExp = RT.Id;
        }
        
        SVMXC__ServiceMax_Processes__c expPro = new SVMXC__ServiceMax_Processes__c(RecordTypeId = RTProRule, SVMXC__Name__c = 'ExpProcess001', SVMXC__ProcessID__c = 'ExpProcess001', SVMXC__Source_Object_Name__c ='SVMXC__Service_Order__c', SVMXC__Rule_Type__c='Named Expression',SVMXC__SettingId__c = 'ExpProcess001', SVMXC__Advance_Expression__c ='(1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8 AND 9 AND 10 AND 11 AND 12 AND 13 AND 14 AND 15 AND 16)');
        insert expPro;
        
        SVMXC__ServiceMax_Config_Data__c expDtl1 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 1, SVMXC__Field_Name__c = 'SVMXC__Driving_Time__c', SVMXC__Operator__c = 'isnull',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'INTEGER');
        insert expDtl1;
        
        SVMXC__ServiceMax_Config_Data__c expDtl2 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 2, SVMXC__Field_Name__c = 'SVMXC__Dispatch_Priority__c',SVMXC__Operator__c = 'eq',SVMXC__Operand__c = '10.00',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DOUBLE');
        insert expDtl2;

        SVMXC__ServiceMax_Config_Data__c expDtl3 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 3, SVMXC__Field_Name__c = 'SVMXC__Dispatch_Priority__c', SVMXC__Operator__c = 'ne',SVMXC__Operand__c = '5.00',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DOUBLE');
        insert expDtl3;
        
        SVMXC__ServiceMax_Config_Data__c expDtl4 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 4, SVMXC__Field_Name__c = 'SVMXC__Dispatch_Priority__c', SVMXC__Operator__c = 'lt',SVMXC__Operand__c = '15.00',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DOUBLE');
        insert expDtl4; 
        
        SVMXC__ServiceMax_Config_Data__c expDtl5 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 5, SVMXC__Field_Name__c = 'SVMXC__Dispatch_Priority__c', SVMXC__Operator__c = 'gt',SVMXC__Operand__c = '7.00',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DOUBLE');
        insert expDtl5;
        
        SVMXC__ServiceMax_Config_Data__c expDtl6 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 6, SVMXC__Field_Name__c = 'SVMXC__Dispatch_Priority__c', SVMXC__Operator__c = 'le',SVMXC__Operand__c = '15.00',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DOUBLE');
        insert expDtl6;
        
        SVMXC__ServiceMax_Config_Data__c expDtl7 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 7, SVMXC__Field_Name__c = 'SVMXC__Scheduling_Retry_Count__c', SVMXC__Operator__c = 'isnotnull',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'INTEGER');
        insert expDtl7;
        
        SVMXC__ServiceMax_Config_Data__c expDtl8 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 8, SVMXC__Field_Name__c = 'SVMXC__Scheduling_Retry_Count__c', SVMXC__Operator__c = 'ne',SVMXC__Operand__c = '15',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'INTEGER');
        insert expDtl8;

        SVMXC__ServiceMax_Config_Data__c expDtl9 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 9, SVMXC__Field_Name__c = 'SVMXC__Scheduling_Retry_Count__c', SVMXC__Operator__c = 'eq',SVMXC__Operand__c = '10',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'INTEGER');
        insert expDtl9;
        
        SVMXC__ServiceMax_Config_Data__c expDt20 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 10, SVMXC__Field_Name__c = 'SVMXC__Scheduling_Retry_Count__c', SVMXC__Operator__c = 'lt',SVMXC__Operand__c = '20',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'INTEGER');
        insert expDt20;
        
        SVMXC__ServiceMax_Config_Data__c expDt21 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 11, SVMXC__Field_Name__c = 'SVMXC__Scheduling_Retry_Count__c', SVMXC__Operator__c = 'gt',SVMXC__Operand__c = '5',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'INTEGER');
        insert expDt21; 
        
        SVMXC__ServiceMax_Config_Data__c expDt22 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 12, SVMXC__Field_Name__c = 'SVMXC__Scheduling_Retry_Count__c', SVMXC__Operator__c = 'le',SVMXC__Operand__c = '25',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'INTEGER');
        insert expDt22;
        
        SVMXC__ServiceMax_Config_Data__c expDt23 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 13, SVMXC__Field_Name__c = 'SVMXC__Scheduling_Retry_Count__c', SVMXC__Operator__c = 'ge',SVMXC__Operand__c = '5',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'INTEGER');
        insert expDt23;
        
        SVMXC__ServiceMax_Config_Data__c expDt24 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 14, SVMXC__Field_Name__c = 'SVMXC__Dispatch_Priority__c', SVMXC__Operator__c = 'ge',SVMXC__Operand__c = '1.00',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DOUBLE');
        insert expDt24;  
        
        SVMXC__ServiceMax_Config_Data__c expDt25 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 15, SVMXC__Field_Name__c = 'SVMXC__Dispatch_Priority__c', SVMXC__Operator__c = 'NOTIN',SVMXC__Operand__c = '134.00,34.00',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DOUBLE');
        insert expDt25;   
        
        SVMXC__ServiceMax_Config_Data__c expDt26 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 16, SVMXC__Field_Name__c = 'SVMXC__Scheduling_Retry_Count__c', SVMXC__Operator__c = 'NOTIN',SVMXC__Operand__c = '5,15',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'INTEGER');
        insert expDt26;        
        
        selectedNotification.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        selectedNotification.SVMXC__Dispatch_Process__c = expPro.Id;
        selectedNotification.SVMXC__Display_Value__c = '1';
        selectedNotification.SVMXC__Internal_Value__c = 'WO Updated';
        selectedNotification.SVMXC__Description__c = 'This work order records Account field is chnaged to [$SVMXC__Company__c]';
        selectedNotification.SVMXC__Parameter_Name__c = 'Immediately';
        selectedNotification.SVMXC__Profile_Name__c = 'Test Notification1';
        selectedNotification.SVMXC__Active__c = True;
        selectedNotification.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__Closed_By__c';
        selectedNotification.SVMXC__Profile__c = 'abc@servicemax.com,xyz@servicemax.com';
        selectedNotification.SVMXC__Display_Type__c = 'Push Notification';
        selectedNotification.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Mobile Configuration' Limit 1][0].Id;
        system.debug(LoggingLevel.WARN, 'First Notification = ' + selectedNotification);
        insert selectedNotification;
        
        Account acc = new Account();
        acc.Name = 'Test Account1';
        insert acc;

        SVMXC__SVMX_Job_Logs__c newLogs = new SVMXC__SVMX_Job_Logs__c(SVMXC__Operation__c = 'PUSH NOTIFICATION',SVMXC__Event_Name__c ='Test Notification1');
        insert newLogs;
        Test.startTest();
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Order_Status__c = 'Open';
        wo.SVMXC__Priority__c='High';
        wo.SVMXC__Dispatch_Priority__c=10.00;
        wo.SVMXC__Scheduling_Retry_Count__c=10;
        wo.SVMXC__Company__c = acc.Id;
        wo.SVMXC__Closed_By__c = [SELECT Id FROM User Limit 1][0].Id;
        SVMXC__SM_SNS_Detail__c newDetails = new SVMXC__SM_SNS_Detail__c(SVMXC__SM_IsActive__c =true,SVMXC__SM_Status__c ='Registered',SVMXC__SM_User__c =[SELECT Id FROM User Limit 1][0].Id,SVMXC__SM_TargetArn__c ='1');
        insert newDetails;
        newDetails = new SVMXC__SM_SNS_Detail__c(SVMXC__SM_IsActive__c =true,SVMXC__SM_Status__c ='Registered',SVMXC__SM_User__c =[SELECT Id FROM User Limit 1][0].Id,SVMXC__SM_TargetArn__c ='1');
        insert newDetails;         
        insert wo;       
        newMapOfIdToSObj.put(wo.Id, wo);
        Map<String,String> mapOfSettingValues = new Map<String,String>();
        mapOfSettingValues.put('SET004','Solution,GroupMember');
        mapOfSettingValues.put('SET021','300');
        mapOfSettingValues.put('SET020','Spr16');        
        obj.routingPN(newMapOfIdToSObj, 'SVMXC__Service_Order__c', '1', mapOfSettingValues);
        obj.sendNotification(newMapOfIdToSObj, 'SVMXC__Service_Order__c', '1', mapOfSettingValues,true);        
        obj.sendNotification(newMapOfIdToSObj, 'SVMXC__Service_Order__c', '1', mapOfSettingValues,false);
        Test.stopTest();                
    } 
    static testMethod void testImmediatelyWithDatetimeDataType()
    {
    	insertMobTestData();
        String RTProRule, RTConfigExp;
        map<Id, sObject> newMapOfIdToSObj = new map<Id, sObject>();
        List<string> lstRTNames = new List<string>{'SVMX Rule', 'Expressions'};
        SVMXC__ServiceMax_Config_Data__c selectedNotification = new SVMXC__ServiceMax_Config_Data__c();
        SVMX_PushNotification obj = new SVMX_PushNotification();
        
        for(RecordType RT : [SELECT Id, Name FROM RecordType WHERE Name IN: lstRTNames])
        {
            if(RT.Name == 'SVMX Rule')
                RTProRule = RT.Id;
            else if(RT.Name == 'Expressions')
                RTConfigExp = RT.Id;
        }
        
        SVMXC__ServiceMax_Processes__c expPro = new SVMXC__ServiceMax_Processes__c(RecordTypeId = RTProRule, SVMXC__Name__c = 'ExpProcess001', SVMXC__ProcessID__c = 'ExpProcess001', SVMXC__Source_Object_Name__c ='SVMXC__Service_Order__c', SVMXC__Rule_Type__c='Named Expression',SVMXC__SettingId__c = 'ExpProcess001', SVMXC__Advance_Expression__c ='(1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8 AND 9 AND 10 AND 11 AND 12 AND 13 AND 14 AND 15)');
        insert expPro;
        
        SVMXC__ServiceMax_Config_Data__c expDtl1 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 1, SVMXC__Field_Name__c = 'SVMXC__SLA_Clock_Pause_Time__c', SVMXC__Operator__c = 'isnull',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DATETIME');
        insert expDtl1;
        
        SVMXC__ServiceMax_Config_Data__c expDtl2 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 2, SVMXC__Field_Name__c = 'SVMXC__SLA_Clock_Pause_Restart_Time__c',SVMXC__Operator__c = 'eq',SVMXC__Operand__c = 'SVMX.NOW',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DATETIME');
        insert expDtl2;

        SVMXC__ServiceMax_Config_Data__c expDtl3 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 3, SVMXC__Field_Name__c = 'SVMXC__SLA_Clock_Pause_Restart_Time__c', SVMXC__Operator__c = 'ne',SVMXC__Operand__c = 'YESTERDAY',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DATETIME');
        insert expDtl3;
        
        SVMXC__ServiceMax_Config_Data__c expDtl4 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 4, SVMXC__Field_Name__c = 'SVMXC__SLA_Clock_Pause_Restart_Time__c', SVMXC__Operator__c = 'lt',SVMXC__Operand__c = 'TOMORROW',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DATETIME');
        insert expDtl4; 
        
        SVMXC__ServiceMax_Config_Data__c expDtl5 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 5, SVMXC__Field_Name__c = 'SVMXC__SLA_Clock_Pause_Restart_Time__c', SVMXC__Operator__c = 'gt',SVMXC__Operand__c = 'YESTERDAY',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DATETIME');
        insert expDtl5;
        
        SVMXC__ServiceMax_Config_Data__c expDtl6 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 6, SVMXC__Field_Name__c = 'SVMXC__SLA_Clock_Pause_Restart_Time__c', SVMXC__Operator__c = 'le',SVMXC__Operand__c = 'TODAY',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DATETIME');
        insert expDtl6;
        
        SVMXC__ServiceMax_Config_Data__c expDtl7 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 7, SVMXC__Field_Name__c = 'SVMXC__SLA_Clock_Pause_Restart_Time__c', SVMXC__Operator__c = 'isnotnull',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DATETIME');
        insert expDtl7;
        
        SVMXC__ServiceMax_Config_Data__c expDtl8 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 8, SVMXC__Field_Name__c = 'SVMXC__Scheduled_Date__c', SVMXC__Operator__c = 'ne',SVMXC__Operand__c = 'YESTERDAY',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DATE');
        insert expDtl8;

        SVMXC__ServiceMax_Config_Data__c expDtl9 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 9, SVMXC__Field_Name__c = 'SVMXC__Scheduled_Date__c', SVMXC__Operator__c = 'eq',SVMXC__Operand__c = 'TODAY',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DATE');
        insert expDtl9;
        
        SVMXC__ServiceMax_Config_Data__c expDt20 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 10, SVMXC__Field_Name__c = 'SVMXC__Scheduled_Date__c', SVMXC__Operator__c = 'lt',SVMXC__Operand__c = 'YESTERDAY',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DATE');
        insert expDt20;
        
        SVMXC__ServiceMax_Config_Data__c expDt21 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 11, SVMXC__Field_Name__c = 'SVMXC__Scheduled_Date__c', SVMXC__Operator__c = 'gt',SVMXC__Operand__c = 'TOMORROW',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DATE');
        insert expDt21; 
        
        SVMXC__ServiceMax_Config_Data__c expDt22 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 12, SVMXC__Field_Name__c = 'SVMXC__Scheduled_Date__c', SVMXC__Operator__c = 'le',SVMXC__Operand__c = 'TODAY',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DATE');
        insert expDt22;
        
        SVMXC__ServiceMax_Config_Data__c expDt23 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 13, SVMXC__Field_Name__c = 'SVMXC__Scheduled_Date__c', SVMXC__Operator__c = 'ge',SVMXC__Operand__c = 'TODAY',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DATE');
        insert expDt23;
        
        SVMXC__ServiceMax_Config_Data__c expDt24 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 14, SVMXC__Field_Name__c = 'SVMXC__Scheduled_Date__c', SVMXC__Operator__c = 'NOTIN',SVMXC__Operand__c = 'YESTERDAY,TOMORROW',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DATE');
        insert expDt24; 
        
        SVMXC__ServiceMax_Config_Data__c expDt25 = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp, SVMXC__Sequence__c = 15, SVMXC__Field_Name__c = 'SVMXC__SLA_Clock_Pause_Restart_Time__c', SVMXC__Operator__c = 'NOTIN',SVMXC__Operand__c = 'YESTERDAY,TOMORROW',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c', SVMXC__Expression_Rule__c = expPro.Id, SVMXC__Expression_Type__c='EXP_Named', SVMXC__Display_Type__c = 'DATETIME');
        insert expDt25;        
        
        selectedNotification.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        selectedNotification.SVMXC__Dispatch_Process__c = expPro.Id;
        selectedNotification.SVMXC__Display_Value__c = '1';
        selectedNotification.SVMXC__Internal_Value__c = 'WO Updated';
        selectedNotification.SVMXC__Description__c = 'This work order records Account field is chnaged to [$SVMXC__Company__c]';
        selectedNotification.SVMXC__Parameter_Name__c = 'Immediately';
        selectedNotification.SVMXC__Profile_Name__c = 'Test Notification1';
        selectedNotification.SVMXC__Active__c = True;
        selectedNotification.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__Closed_By__c';
        selectedNotification.SVMXC__Profile__c = 'abc@servicemax.com,xyz@servicemax.com';
        selectedNotification.SVMXC__Display_Type__c = 'Push Notification';
        selectedNotification.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Mobile Configuration' Limit 1][0].Id;
        system.debug(LoggingLevel.WARN, 'First Notification = ' + selectedNotification);
        insert selectedNotification;
        
        Account acc = new Account();
        acc.Name = 'Test Account1';
        insert acc;

        SVMXC__SVMX_Job_Logs__c newLogs = new SVMXC__SVMX_Job_Logs__c(SVMXC__Operation__c = 'PUSH NOTIFICATION',SVMXC__Event_Name__c ='Test Notification1');
        insert newLogs;
        Test.startTest();
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Order_Status__c = 'Open';
        wo.SVMXC__Priority__c='High';
        wo.SVMXC__Dispatch_Priority__c=10.00;
        wo.SVMXC__Scheduling_Retry_Count__c=10;
        wo.SVMXC__SLA_Clock_Pause_Restart_Time__c=System.now();
        wo.SVMXC__Scheduled_Date__c=System.today();
        wo.SVMXC__Company__c = acc.Id;
        wo.SVMXC__Closed_By__c = [SELECT Id FROM User Limit 1][0].Id;
        SVMXC__SM_SNS_Detail__c newDetails = new SVMXC__SM_SNS_Detail__c(SVMXC__SM_IsActive__c =true,SVMXC__SM_Status__c ='Registered',SVMXC__SM_User__c =[SELECT Id FROM User Limit 1][0].Id,SVMXC__SM_TargetArn__c ='1');
        insert newDetails;
        newDetails = new SVMXC__SM_SNS_Detail__c(SVMXC__SM_IsActive__c =true,SVMXC__SM_Status__c ='Registered',SVMXC__SM_User__c =[SELECT Id FROM User Limit 1][0].Id,SVMXC__SM_TargetArn__c ='1');
        insert newDetails;         
        insert wo;       
        newMapOfIdToSObj.put(wo.Id, wo);
        Map<String,String> mapOfSettingValues = new Map<String,String>();
        mapOfSettingValues.put('SET004','Solution,GroupMember');
        mapOfSettingValues.put('SET021','300');
        mapOfSettingValues.put('SET020','Spr16');  
        mapOfSettingValues.put('SET013','5');                  
        obj.routingPN(newMapOfIdToSObj, 'SVMXC__Service_Order__c', '1', mapOfSettingValues);
        obj.sendNotification(newMapOfIdToSObj, 'SVMXC__Service_Order__c', '1', mapOfSettingValues,true);
        obj.sendNotification(newMapOfIdToSObj, 'SVMXC__Service_Order__c', '1', mapOfSettingValues,false);
        Test.stopTest();        
    }     
}