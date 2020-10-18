@isTest
public class WSCH_ResourcesTriggerHandler_UT {
    static testMethod void testWoResInsert(){
      //  WSCH_TestDataFactory.createOptimizationSettings('OptiMax,ServicePower', 'True');
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
        
        SVMXC__Service_Group_Members__c technician1 = new SVMXC__Service_Group_Members__c();
        technician1.Name = 'John';
        technician1.SVMXC__Optimizer_External_ID__c = 'TM0011';
        technician1.SVMXC__Service_Group__c  = team.Id;
        technician1.SVMXC__Service_Territory__c = territory1.Id;
        
        insert technician1;
        
        SVMXC__Site__c siteObject = new SVMXC__Site__c();
        siteObject.Name = 'Site1';
        
        insert siteObject;
        
        Account accountObject = new Account();
        accountObject.AccountNumber = '0011';
        accountObject.Name = 'Test Name';
        
        insert accountObject;
        
        Contact cont = new Contact();
        cont.LastName='Last';
        cont.AccountId =accountObject.Id;
        cont.Email='svmxmailfortest@gmail.com';
        
        insert cont;
        
        Product2 prodCloseWO = new Product2();
        prodCloseWO.Name = 'prodPR';
        prodCloseWO.ProductCode='prodPR';
        prodCloseWO.SVMXC__Inherit_Parent_Warranty__c =True;
        
        insert prodCloseWO;
        
        SVMXC__Installed_Product__c IBObject = new SVMXC__Installed_Product__c();
        IBObject.Name = 'Test IB1';
        IBObject.SVMXC__Status__c = 'Installed';
        IBObject.SVMXC__Product__c = prodCloseWO.Id;
        IBObject.SVMXC__Date_Installed__c = System.Today();
        IBObject.SVMXC__Contact__c = cont.Id;
        IBObject.SVMXC__Company__c = accountObject.Id;
        
        insert IBObject;
        
        Datetime startTime = Datetime.now();
        Datetime endTime = startTime.addHours(2);
        
        SVMXC__Service_Order__c bookJobWorkOrder = new SVMXC__Service_Order__c();
        bookJobWorkOrder.SVMXC__Zip__c = '75001';
        bookJobWorkOrder.SVMXC__Service_Duration__c = 3600.00;
        bookJobWorkOrder.SVMXC__Preferred_Start_Time__c = startTime;
        bookJobWorkOrder.SVMXC__Preferred_End_Time__c = endTime;
        bookJobWorkOrder.SVMXC__Preferred_Technician__c = technician.Id;
        bookJobWorkOrder.SVMXC__Skill_Set__c = '[{"skillName":"hardware","skillLevel":5,"skillId":"a1RG0000002fCLLMA2","isSkillMandatory":true},{"skillName":"software","skillLevel":5,"skillId":"a1RG0000002fCLQMA2","isSkillMandatory":true}]';
        bookJobWorkOrder.SVMXC__Site__c = siteObject.Id;
        bookJobWorkOrder.SVMXC__Company__c = accountObject.Id;
        
        insert bookJobWorkOrder;
        
        SVMXC__Resource_Preference__c resPref = new SVMXC__Resource_Preference__c();
        resPref.SVMXC__Company__c = accountObject.Id;
        resPref.SVMXC__Component__c = IBObject.id;
        resPref.SVMXC__Site__c = siteObject.id;
        resPref.SVMXC__Group_Member__c = technician.id;
        resPref.SVMXC__Preference_Type__c = 'Preferred';
        
        insert resPref;
        
        SVMXC__Work_Order_Resource__c woRes = new SVMXC__Work_Order_Resource__c();
        woRes.SVMXC__Preference_Type__c = 'Mandatory';
        woRes.SVMXC__Group_Member__c = technician.id;
        woRes.SVMXC__Work_Order__c = bookJobWorkOrder.id;
        
        insert woRes;
        SVMXC__Work_Order_Resource__c woRes1 = new SVMXC__Work_Order_Resource__c();
        woRes1.SVMXC__Preference_Type__c = 'Mandatory';
        woRes1.SVMXC__Group_Member__c = technician1.id;
        woRes1.SVMXC__Work_Order__c = bookJobWorkOrder.id;
        
        insert woRes1;
        Set<Id> setWoId = new Set<Id>(),setTechId = new Set<Id>();
        List<Work_Order_Resource__c> lstNewWORes = new List<Work_Order_Resource__c>(), lstAllTechRes = new List<Work_Order_Resource__c>();
        Map<Id,Work_Order_Resource__c> mapTrigNew = new  Map<Id,Work_Order_Resource__c>(), mapTrigOld = new  Map<Id,Work_Order_Resource__c>();
        setWoId.add(bookJobWorkOrder.id);
        setTechId.add(technician.id);
        mapTrigOld.put(woRes.id, woRes);
        lstNewWORes.add(woRes);
        lstAllTechRes.add(woRes);
        lstNewWORes.add(woRes1);
        woRes.SVMXC__Preference_Type__c = 'Preferred';
        mapTrigNew.put(woRes.id, woRes);
        createOptimizationSettings('OptiMax,ServicePower', 'True');
        Test.startTest();
        WSCH_ResourcesTriggerHandler.reBookJob(setWoId);
        WSCH_ResourcesTriggerHandler.getAllWORes(setTechId);
        WSCH_ResourcesTriggerHandler.checkWOResList(lstAllTechRes,lstNewWORes, 'beforeInsert');
        WSCH_ResourcesTriggerHandler.checkWOResList(lstAllTechRes,lstNewWORes, 'beforeUpdate');
        //WSCH_ResourcesTriggerHandler.checkInsertWOResList(lstAllTechRes,lstNewWORes);
        //WSCH_ResourcesTriggerHandler.checkUpdateWOResList(lstAllTechRes,lstNewWORes,mapTrigOld,mapTrigNew);
        Database.delete(woRes);
        Test.stopTest();
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
        settingProc_GLOB001_GBL022.SVMXC__Default_Value__c = 'OptiMax, ServicePower';
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