/*TEST*/
@isTest
public class WSCH_TestDataFactory {
    //This method creates Drip related settings DCON002_SET001 & DCON002_SET002
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
    public static void saveResultLog(Database.SaveResult[] srList){
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted record. ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Fields that affected this error: ' + err.getFields());
                }
            }
        }
    }
    public static User createTestUser(String usrAlias){
        Profile usrProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User tstUser = new User(
            Alias = usrAlias,
            Email= usrAlias + '@testorg.com', 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = usrProfile.Id, 
            TimeZoneSidKey='America/Los_Angeles',
            UserName= usrAlias + '@testorg.com');
        return tstUser;
    }
    
    //This method creates Technician Field related settings DCON003_SET004
    public static void createTechFieldSettings(String strTechFields){
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
        
        //adding DCON003 Process SubModule
        SVMXC__ServiceMax_Processes__c subModProc_DCON003 = new SVMXC__ServiceMax_Processes__c();
        subModProc_DCON003.RecordTypeId = subModTypeId;
        subModProc_DCON003.SVMXC__SubmoduleID__c = 'DCON003';
        subModProc_DCON003.SVMXC__Name__c = 'Appointment Booking';
        subModProc_DCON003.SVMXC__IsStandard__c = true;
        subModProc_DCON003.SVMXC__Module__c = modProc_DCON.id;
        subModProc_DCON003.SVMXC__Description__c = 'TEST SUBMODULE DESCRIPTION';
        subModProc_DCON003.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.insert(subModProc_DCON003);
        
        //adding DCON003 SET004 Process Setting
        SVMXC__ServiceMax_Processes__c settingProc_DCON003_SET004 = new SVMXC__ServiceMax_Processes__c();
        settingProc_DCON003_SET004.RecordTypeId = setTypeId;
        settingProc_DCON003_SET004.SVMXC__SettingID__c = 'SET004';
        settingProc_DCON003_SET004.SVMXC__Data_Type__c = 'Text';
        settingProc_DCON003_SET004.SVMXC__Default_Value__c = 'Name';
        settingProc_DCON003_SET004.SVMXC__Setting_Type__c = 'Group';
        settingProc_DCON003_SET004.SVMXC__Search_Order__c = 'Group,Global';
        settingProc_DCON003_SET004.SVMXC__Active__c = true;
        settingProc_DCON003_SET004.SVMXC__IsStandard__c = true;
        settingProc_DCON003_SET004.SVMXC__Values__c = 'Name';
        settingProc_DCON003_SET004.SVMXC__Submodule__c = subModProc_DCON003.id;
        settingProc_DCON003_SET004.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
        settingProc_DCON003_SET004.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.insert(settingProc_DCON003_SET004);        
        
        //adding DCON003 SET004 Configuration Profile
        SVMXC__ServiceMax_Config_Data__c confProfile_DCON003_SET004 = new SVMXC__ServiceMax_Config_Data__c();
        confProfile_DCON003_SET004.SVMXC__Profile_Name__c = 'TestSvmxPro';
        confProfile_DCON003_SET004.RecordTypeId = confProfileTypeId;
        confProfile_DCON003_SET004.SVMXC__Configuration_Type__c = 'Global';
        confProfile_DCON003_SET004.SVMXC__Active__c = true;
        confProfile_DCON003_SET004.SVMXC__IsDefault__c = true;
        confProfile_DCON003_SET004.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.insert(confProfile_DCON003_SET004);
        
        //adding DCON003 SET004 Setting Value
        SVMXC__ServiceMax_Config_Data__c confDrip_DCON003_SET004 = new SVMXC__ServiceMax_Config_Data__c();
        confDrip_DCON003_SET004.RecordTypeId = setValTypeId;
        confDrip_DCON003_SET004.SVMXC__Setting_Configuration_Profile__c = confProfile_DCON003_SET004.id;
        confDrip_DCON003_SET004.SVMXC__Display_Value__c = strTechFields;
        confDrip_DCON003_SET004.SVMXC__Internal_Value__c = strTechFields;
        confDrip_DCON003_SET004.SVMXC__Setting_ID__c = settingProc_DCON003_SET004.id;
        confDrip_DCON003_SET004.SVMXC__Active__c = true; //
        confDrip_DCON003_SET004.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.insert(confDrip_DCON003_SET004);
        System.debug('Setting value in DCON003_SET004:'+String.valueof(WSCH_CommonUtils.getSettingValue('DCON003','SET004')));
    }
    //This method Optimization Settings GLOB001_GBL023
    public static void createOptimizationURL(String strURL){
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
        /*SVMXC__ServiceMax_Processes__c settingProc_GLOB001_GBL007 = new SVMXC__ServiceMax_Processes__c();
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
Database.insert(settingProc_GLOB001_GBL007);*/
        
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
        /*SVMXC__ServiceMax_Config_Data__c conf_GLOB001_GBL007 = new SVMXC__ServiceMax_Config_Data__c();
conf_GLOB001_GBL007.RecordTypeId = setValTypeId;
conf_GLOB001_GBL007.SVMXC__Setting_Configuration_Profile__c = confProfile_GLOB001_GBL007.id;
conf_GLOB001_GBL007.SVMXC__Display_Value__c = 'True';
conf_GLOB001_GBL007.SVMXC__Internal_Value__c = 'True';
conf_GLOB001_GBL007.SVMXC__Setting_ID__c = settingProc_GLOB001_GBL007.id;
conf_GLOB001_GBL007.SVMXC__Active__c = true; //
conf_GLOB001_GBL007.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
Database.insert(conf_GLOB001_GBL007);*/
        
        //adding GLOB001 GBL022 Process Setting
        SVMXC__ServiceMax_Processes__c settingProc_GLOB001_GBL023 = new SVMXC__ServiceMax_Processes__c();
        settingProc_GLOB001_GBL023.RecordTypeId = setTypeId;
        settingProc_GLOB001_GBL023.SVMXC__SettingID__c = 'GBL023';
        settingProc_GLOB001_GBL023.SVMXC__Data_Type__c = 'Text';
        settingProc_GLOB001_GBL023.SVMXC__Default_Value__c = '';
        settingProc_GLOB001_GBL023.SVMXC__Setting_Type__c = 'Global';
        settingProc_GLOB001_GBL023.SVMXC__Search_Order__c = 'Global';
        settingProc_GLOB001_GBL023.SVMXC__Active__c = true;
        settingProc_GLOB001_GBL023.SVMXC__IsStandard__c = true;
        settingProc_GLOB001_GBL023.SVMXC__Values__c = '';
        settingProc_GLOB001_GBL023.SVMXC__Submodule__c = subModProc_GLOB001.id;
        settingProc_GLOB001_GBL023.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
        settingProc_GLOB001_GBL023.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.insert(settingProc_GLOB001_GBL023);
        
        //adding GLOB001 GBL023 Setting Value
        SVMXC__ServiceMax_Config_Data__c conf_GLOB001_GBL023 = new SVMXC__ServiceMax_Config_Data__c();
        conf_GLOB001_GBL023.RecordTypeId = setValTypeId;
        conf_GLOB001_GBL023.SVMXC__Setting_Configuration_Profile__c = confProfile_GLOB001_GBL007.id;
        conf_GLOB001_GBL023.SVMXC__Display_Value__c = strURL;
        //SVMXC__Internal_Value__c
        conf_GLOB001_GBL023.SVMXC__Internal_Value__c = strURL;
        conf_GLOB001_GBL023.SVMXC__Setting_ID__c = settingProc_GLOB001_GBL023.id;
        conf_GLOB001_GBL023.SVMXC__Active__c = true;
        conf_GLOB001_GBL023.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.insert(conf_GLOB001_GBL023);
        
        System.debug('WSCH_TestDataFactory::createOptimizationURL');
    }
}