@isTest
(SeeAllData = false)
Private class OMAX_ManageOrgSettings_UT {
    static testMethod void OMAX_ManageOrgSettings_UT()
    {
        createOptimizationURL('http://svlousmaxdev.servicepower.com:6502/ccx/servicepower');
        createOptimizationSettings('SERVICEPOWER', 'true');
        List<SVMXC__ServiceMax_Config_Data__c> lst = [select id,SVMXC__Setting_Unique_ID__c,SVMXC__Display_Value__c,SVMXC__Internal_Value__c,SVMXC__Installation_Key__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Setting_Unique_ID__c IN ('GLOB001_GBL007','GLOB001_GBL022')];
        
        for(SVMXC__ServiceMax_Config_Data__c l: lst)
        {
            
            if(l.SVMXC__Setting_Unique_ID__c =='GLOB001_GBL022')
            {
                l.SVMXC__Display_Value__c = 'SERVICEPOWER';
                l.SVMXC__Internal_Value__c = 'SERVICEPOWER';
                l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
            }
        }
        if(lst != null && lst.size() > 0)
            update lst;
        SVMXC.OMAX_ManageOrgSettings ManageOrgSettings2 = new  SVMXC.OMAX_ManageOrgSettings();
        ManageOrgSettings2.strSelectedOptimizer = 'Linx for Service Power';
        ManageOrgSettings2.onChangeOfOptimizer();
        ManageOrgSettings2.Submit();
        ManageOrgSettings2.UpdateSPCredentials();
        
        SVMXC.OMAX_ManageOrgSettings ManageOrgSettings = new  SVMXC.OMAX_ManageOrgSettings();
        
        ManageOrgSettings.getTAG011();
        ManageOrgSettings.getTAG012();
        ManageOrgSettings.getTAG015();
        ManageOrgSettings.getTAG015();
        ManageOrgSettings.getTAG020();
        ManageOrgSettings.getTAG021();
        ManageOrgSettings.getTAG022();
        ManageOrgSettings.getTAG024();
        ManageOrgSettings.getTAG025();
        ManageOrgSettings.getTAG026();
        ManageOrgSettings.getTAG027();
        ManageOrgSettings.getTAG028();
        ManageOrgSettings.getTAG029();
        ManageOrgSettings.getTAG030();
        ManageOrgSettings.getTAG031();
        ManageOrgSettings.getTAG032();
        ManageOrgSettings.getTAG033();
        ManageOrgSettings.getTAG034();
        ManageOrgSettings.getTAG035();
        ManageOrgSettings.getTAG036();
        ManageOrgSettings.getTAG037();
        ManageOrgSettings.getTAG041();
        ManageOrgSettings.getTAG045();
        ManageOrgSettings.getProcessingText();
        ManageOrgSettings.getsanorpro();
        ManageOrgSettings.setsanorpro(true);
        ManageOrgSettings.Submit();
        ManageOrgSettings.getIscustomerguy();
        ManageOrgSettings.RefreshList();
        ManageOrgSettings.getUser();
        ManageOrgSettings.setUser('pqrs');
        ManageOrgSettings.Cancel();
        ManageOrgSettings.getpass();
        ManageOrgSettings.setpass('abcd');
        ManageOrgSettings.getlstOptimizer();
        ManageOrgSettings.getStoken();
        ManageOrgSettings.setStoken('abcdefgh');
        ManageOrgSettings.Submit();
        ManageOrgSettings.getSEmail();
        ManageOrgSettings.setSEmail('h@h.com');
        ManageOrgSettings.getEEmail();
        ManageOrgSettings.setEEmail('h@h.com');
        ManageOrgSettings.getCustomDomainURL();
        ManageOrgSettings.setCustomDomainURL('h.h.com');
        ManageOrgSettings.getlstOrgTypes();
        ManageOrgSettings.Encryption('abcd');
        ManageOrgSettings.Decryption('abcd');
        ManageOrgSettings.Decryption1('abcd');
        ManageOrgSettings.RecordTypeId('Settings');
        //ManageOrgSettings.getOptions();
        ManageOrgSettings.wrongnorecords = true;
        ManageOrgSettings.checkNewdata = true;
        ManageOrgSettings.Submit();
        ManageOrgSettings.getdisablesubmit();
        //string a = ManageOrgSettings.encryption1('abcd');
        string a = OMAX_ManageOrgSettings.encryption1('abcd');
        ManageOrgSettings.InsertOrUpdateRecords();
        ManageOrgSettings.Insertrecords();
        ManageOrgSettings.Updaterecords();
        ManageOrgSettings.onChangeOfOrgType();
        ManageOrgSettings.orgType = 'CustomDomain';
        ManageOrgSettings.onChangeOfOrgType();
        ManageOrgSettings.strSelectedOptimizer = '--None--';
        ManageOrgSettings.onChangeOfOptimizer();
        ManageOrgSettings.strSelectedOptimizer = 'OptiMax Batch';
        ManageOrgSettings.onChangeOfOptimizer();
        ManageOrgSettings.strSelectedOptimizer = 'Linx for Service Power';
        ManageOrgSettings.onChangeOfOptimizer();
        
        ManageOrgSettings.setsanorpro(false);
        ManageOrgSettings.SEmail='';
        ManageOrgSettings.EEmail='';
        //ManageOrgSettings.Authenticate();
        ManageOrgSettings.getButtonValue();
        ManageOrgSettings.setsanorpro(true);
        //ManageOrgSettings.setParameterValue();
        ManageOrgSettings.Authenticate();
        ManageOrgSettings.getButtonValue();
        //ManageOrgSettings.clearoAuthInfoFromProcess();
        
        system.assert(ManageOrgSettings.getEEmail()!=null);
        system.assert(ManageOrgSettings.getStoken()!=null);
        list <SVMXC__ServiceMax_Processes__c> lstSetting = new list <SVMXC__ServiceMax_Processes__c>(); 
        
        OMAX_ManageOrgSettings obj1 = new OMAX_ManageOrgSettings();
        for(SVMXC__ServiceMax_Config_Data__c l: lst)
        {
            
            if(l.SVMXC__Setting_Unique_ID__c =='GLOB001_GBL022')
            {
                l.SVMXC__Display_Value__c = 'OPTIMAX';
                l.SVMXC__Internal_Value__c = 'OPTIMAX';
                l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
            }
        }
        if(lst != null && lst.size() > 0)
            update lst;
        SVMXC.OMAX_ManageOrgSettings ManageOrgSettings1 = new  SVMXC.OMAX_ManageOrgSettings();
        ManageOrgSettings1.strSelectedOptimizer = '--None--';
        ManageOrgSettings.onChangeOfOptimizer();
        ManageOrgSettings1.Submit();
        ManageOrgSettings1.strSelectedOptimizer = 'OptiMax Batch';
        ManageOrgSettings.onChangeOfOptimizer();
        ManageOrgSettings1.Submit();
        
        for(SVMXC__ServiceMax_Config_Data__c l: lst)
        {
            if(l.SVMXC__Setting_Unique_ID__c =='GLOB001_GBL007')
            {
                l.SVMXC__Display_Value__c = 'False';
                l.SVMXC__Internal_Value__c = 'False';
                l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
            }
        }           
        if(lst != null && lst.size() > 0)
            update lst;
        SVMXC.OMAX_ManageOrgSettings ManageOrgSettings3 = new  SVMXC.OMAX_ManageOrgSettings();
        try{
            ManageOrgSettings3.Submit();
        }catch(exception e){}
        
        for(SVMXC__ServiceMax_Config_Data__c l: lst)
        {
            if(l.SVMXC__Setting_Unique_ID__c =='GLOB001_GBL007')
            {
                l.SVMXC__Display_Value__c = 'True';
                l.SVMXC__Internal_Value__c = 'True';
                l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
            }
            else if(l.SVMXC__Setting_Unique_ID__c =='GLOB001_GBL022')
            {
                l.SVMXC__Display_Value__c = 'OPTIMAX,SERVICEPOWER';
                l.SVMXC__Internal_Value__c = 'OPTIMAX,SERVICEPOWER';
                l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
            }
        }
        if(lst != null && lst.size() > 0)
            update lst;
        try{
            SVMXC.OMAX_ManageOrgSettings ManageOrgSettings4 = new  SVMXC.OMAX_ManageOrgSettings();
            ManageOrgSettings4.setlstSPInstanceDataWrap(ManageOrgSettings.getlstSPInstanceDataWrap());
            ManageOrgSettings4.getlstSPInstanceDataWrapSize();
            ManageOrgSettings4.StrDelIndex = '';
            ManageOrgSettings4.isOptiMaxSPEnabled = true;
            ManageOrgSettings4.strSelectedOptimizer = 'OptiMax Batch';
            ManageOrgSettings4.Submit();
            ManageOrgSettings4.strSelectedOptimizer = 'Linx for Service Power';
            ManageOrgSettings4.Submit();
            ManageOrgSettings4.strSelectedOptimizer = '';
            ManageOrgSettings4.Submit();
            ManageOrgSettings4.isOptiMaxSPEnabled = false;
            ManageOrgSettings4.isSPEnabled = true;
            ManageOrgSettings4.isSPEnabled = false;
            ManageOrgSettings4.isOptiMaxEnabled = true;
            ManageOrgSettings4.Submit();
            ManageOrgSettings4.SEmail = 'abc@xyz.xom';
            ManageOrgSettings4.EEmail = 'abc@xyz.xom';
            ManageOrgSettings4.orgType = 'CustomDomain';
            ManageOrgSettings4.CustomDomainURL = 'http://www.my.salesforce.com';
            SVMXC.COMM_Utils_ManageSettings CommSettingsUtils = new SVMXC.COMM_Utils_ManageSettings();
            ManageOrgSettings4.mapSVMXSettings = CommSettingsUtils.SVMX_getSettingList('OMAX001');
            ManageOrgSettings4.mapSVMXSettings.put('GBL010','https://optimax-dev.servicemax.com:7343/optimax/optimization');
            System.debug(logginglevel.WARN,'mapSVMXSettings '+ManageOrgSettings4.mapSVMXSettings);
            ManageOrgSettings4.Authenticate();
            ManageOrgSettings4.orgType = 'Production';
            ManageOrgSettings4.Authenticate();
            ManageOrgSettings4.orgType = 'Sandbox';
            ManageOrgSettings4.Authenticate();
            PageReference myVfPage = Page.SVMXC__OMAX_ManageOrgSettings;
            myVfPage.getParameters().put('isSuccess', 'true');
            myVfPage.getParameters().put('org', 'prod');
            Test.setCurrentPageReference(myVfPage); // use setCurrentPageReference,  
            ManageOrgSettings4.isSuccess = false;
            ManageOrgSettings4.getButtonValue();
            ManageOrgSettings4.strSelectedOptimizer = 'Linx for Service Power';
            ManageOrgSettings4.loadOMAX_ManageOrgSettings();
            myVfPage.getParameters().put('org', 'custom');
            Test.setCurrentPageReference(myVfPage);
            ManageOrgSettings4.loadOMAX_ManageOrgSettings();
            myVfPage.getParameters().put('org', 'sandbox');
            Test.setCurrentPageReference(myVfPage);
            ManageOrgSettings4.loadOMAX_ManageOrgSettings();
            myVfPage.getParameters().put('isSuccess', 'false');
            ManageOrgSettings4.loadOMAX_ManageOrgSettings();
            ManageOrgSettings4.validateSPcredentials();
            System.debug(Logginglevel.warn, 'End of the UT method');
        }
        catch(exception e){
            System.debug('Exception in the method occured'+e.getMessage());
        }
        
    }
    static testMethod void OMAX_NewSPInstSettings_UT(){
        createOptimizationURL('https://svlousmaxdev.servicepower.com:6504');
        createOptimizationSettings('SERVICEPOWER', 'true');
        List<SVMXC__ServiceMax_Properties__c> lstEmptySettings = new List<SVMXC__ServiceMax_Properties__c>();
        lstEmptySettings = [SELECT Id, Name FROM SVMXC__ServiceMax_Properties__c WHERE Name LIKE '%SP_CON%' OR Name LIKE '%SP_API%'];
        Database.delete(lstEmptySettings);
        List<String> lstSaveInst = new List<String>();
        lstSaveInst.add('01');
        System.debug('$$$SP_CON: ' + lstEmptySettings.size());
        lstEmptySettings = new List<SVMXC__ServiceMax_Properties__c>();
        SVMXC__ServiceMax_Properties__c SP001 = new SVMXC__ServiceMax_Properties__c();
        SP001.Name = 'SP001';
        SP001.SVMXC__Key__c = 'SP001';
        SP001.SVMXC__Value__c = 'SP001';
        lstEmptySettings.add(SP001);
        
        SVMXC__ServiceMax_Properties__c SP002 = new SVMXC__ServiceMax_Properties__c();
        SP002.Name = 'SP002';
        SP002.SVMXC__Key__c = 'SP002';
        SP002.SVMXC__Value__c = 'SP002';
        lstEmptySettings.add(SP002);
        
        SVMXC__ServiceMax_Properties__c SP003 = new SVMXC__ServiceMax_Properties__c();
        SP003.Name = 'SP003';
        SP003.SVMXC__Key__c = 'SP003';
        SP003.SVMXC__Value__c = 'SP003';
        lstEmptySettings.add(SP003);
        
        SVMXC__ServiceMax_Properties__c SP004 = new SVMXC__ServiceMax_Properties__c();
        SP004.Name = 'SP004';
        SP004.SVMXC__Key__c = 'SP004';
        SP004.SVMXC__Value__c = 'SP004';
        lstEmptySettings.add(SP004);
        
        SVMXC__ServiceMax_Properties__c SP005 = new SVMXC__ServiceMax_Properties__c();
        SP005.Name = 'SP005';
        SP005.SVMXC__Key__c = 'SP005';
        SP005.SVMXC__Value__c = 'SP005';
        lstEmptySettings.add(SP005);
        
        SVMXC__ServiceMax_Properties__c SP006 = new SVMXC__ServiceMax_Properties__c();
        SP006.Name = 'SP006';
        SP006.SVMXC__Key__c = 'SP006';
        SP006.SVMXC__Value__c = 'SP006';
        lstEmptySettings.add(SP006);
        
        SVMXC__ServiceMax_Properties__c SP007 = new SVMXC__ServiceMax_Properties__c();
        SP007.Name = 'SP007';
        SP007.SVMXC__Key__c = 'SP007';
        SP007.SVMXC__Value__c = 'SP007';
        lstEmptySettings.add(SP007);
        
        Database.upsert(lstEmptySettings);
        
        List<SVMXC__ServiceMax_Processes__c> lstOptimaxSetting = new List<SVMXC__ServiceMax_Processes__c>();
        Id recTypeId = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'Settings' LIMIT 1].Id;
        String setTypeId = String.valueOf(recTypeId);

        SVMXC__ServiceMax_Processes__c PS01 = new SVMXC__ServiceMax_Processes__c();
        PS01.RecordTypeId = recTypeId;
        PS01.SVMXC__IsPrivate__c = true;
        PS01.SVMXC__Setting_Type__c = 'Global';
        PS01.SVMXC__SettingID__c = 'PS01';
        PS01.SVMXC__Default_Value__c = 'PS01';
        PS01.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        lstOptimaxSetting.add(PS01);
        
        SVMXC__ServiceMax_Processes__c PS02 = new SVMXC__ServiceMax_Processes__c();
        PS02.RecordTypeId = recTypeId;
        PS02.SVMXC__IsPrivate__c = true;
        PS02.SVMXC__Setting_Type__c = 'Global';
        PS02.SVMXC__SettingID__c = 'PS02';
        PS02.SVMXC__Default_Value__c = 'PS02';
        PS02.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        lstOptimaxSetting.add(PS02);
        
        SVMXC__ServiceMax_Processes__c PS03 = new SVMXC__ServiceMax_Processes__c();
        PS03.RecordTypeId = recTypeId;
        PS03.SVMXC__IsPrivate__c = true;
        PS03.SVMXC__Setting_Type__c = 'Global';
        PS03.SVMXC__SettingID__c = 'PS03';
        PS03.SVMXC__Default_Value__c = 'PS03';
        PS03.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        lstOptimaxSetting.add(PS03);
        
        SVMXC__ServiceMax_Processes__c PS04 = new SVMXC__ServiceMax_Processes__c();
        PS04.RecordTypeId = recTypeId;
        PS04.SVMXC__IsPrivate__c = true;
        PS04.SVMXC__Setting_Type__c = 'Global';
        PS04.SVMXC__SettingID__c = 'PS04';
        PS04.SVMXC__Default_Value__c = 'PS04';
        PS04.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        lstOptimaxSetting.add(PS04);
        
        SVMXC__ServiceMax_Processes__c PS05 = new SVMXC__ServiceMax_Processes__c();
        PS05.RecordTypeId = recTypeId;
        PS05.SVMXC__IsPrivate__c = true;
        PS05.SVMXC__Setting_Type__c = 'Global';
        PS05.SVMXC__SettingID__c = 'PS05';
        PS05.SVMXC__Default_Value__c = 'PS05';
        PS05.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        lstOptimaxSetting.add(PS05);
        
        SVMXC__ServiceMax_Processes__c PS06 = new SVMXC__ServiceMax_Processes__c();
        PS06.RecordTypeId = recTypeId;
        PS06.SVMXC__IsPrivate__c = true;
        PS06.SVMXC__Setting_Type__c = 'Global';
        PS06.SVMXC__SettingID__c = 'PS06';
        PS06.SVMXC__Default_Value__c = 'PS06';
        PS06.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        lstOptimaxSetting.add(PS06);
        
        Database.upsert(lstOptimaxSetting);
        Test.startTest();
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        OMAX_ManageOrgSettings omaxSetting = new OMAX_ManageOrgSettings();
        omaxSetting.loadOMAX_ManageOrgSettings();
        omaxSetting.setDefaultValues();
        omaxSetting.newInstance();
        omaxSetting.saveInstance();
        omaxSetting.editInstance();
        omaxSetting.deleteInstance();
        omaxSetting.getFieldMapdata();
        omaxSetting.getSPCredentials();
        omaxSetting.saveOptiMaxCredentials();
        omaxSetting.getenablesubmitCancel();
        //needs settingsList (SVMXC__ServiceMax_Processes__c)
        omaxSetting.Updaterecords();
        omaxSetting.SPUsernameDatabase = 'smaxapi';
        omaxSetting.SPPassDatabase = 'smaxapi99';
        omaxSetting.SPUserName = 'smax_user';
        omaxSetting.SPEndPointURL = 'https://svlousmaxdev.servicepower.com:6504';
        //omaxSetting.validateSPcredentials();
        omaxSetting.UpdateSPCredentials();
        omaxSetting.updateSFMMapsInSettings();
        omaxSetting.migrateSpSettings();
        omaxSetting.confirmDelete();
        //WSCH_TestDataFactory.createOptimizationURL('http://svlousmaxdev.servicepower.com:6502/ccx/servicepower');
        System.debug('$$$GBL023: ' + WSCH_CommonUtils.getSettingValue('GLOB001', 'GBL023'));
        omaxSetting.createSPSettings(01, 'strConName','strIsActv','strIsDefault','strDesc','strURL','strDBUsrName','strAPIUsrNm','strPwd','strInstGetAppt','strInstBookAppt','strInstBookJob','strUpdWo');
        omaxSetting.loadSpInstSetting();
        omaxSetting.lstSpInstanceSetting = new List<OMAX_ManageOrgSettings.SPInstanceDataWrapper>(omaxSetting.getSpInsSettings());
        if(!omaxSetting.lstSpInstanceSetting.isEmpty()){
            omaxSetting.lstSpInstanceSetting[0].selected = true;
        }
        omaxSetting.editSpInstSetting();
        omaxSetting.isNewRecord = true;
        omaxSetting.boolIsDefault = true;
        omaxSetting.saveSpInstSetting();
        omaxSetting.checkDeleteInstance(lstSaveInst);
        omaxSetting.deleteSpInstSetting();
        omaxSetting.newSpInstSetting();
        omaxSetting.cancelSpInstSetting();
        omaxSetting.updateSPSettings(1, 'con1', 'true', 'true', 'TestCon', 'https://TestCon', 'testDBUSer', 'testApiUser', 'testPwd', 'api1', 'api2', 'api3', 'api4');
        Test.stopTest();
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
Database.upsert(settingProc_GLOB001_GBL007);*/
        
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
        /*SVMXC__ServiceMax_Config_Data__c conf_GLOB001_GBL007 = new SVMXC__ServiceMax_Config_Data__c();
conf_GLOB001_GBL007.RecordTypeId = setValTypeId;
conf_GLOB001_GBL007.SVMXC__Setting_Configuration_Profile__c = confProfile_GLOB001_GBL007.id;
conf_GLOB001_GBL007.SVMXC__Display_Value__c = 'True';
conf_GLOB001_GBL007.SVMXC__Internal_Value__c = 'True';
conf_GLOB001_GBL007.SVMXC__Setting_ID__c = settingProc_GLOB001_GBL007.id;
conf_GLOB001_GBL007.SVMXC__Active__c = true; //
conf_GLOB001_GBL007.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
Database.upsert(conf_GLOB001_GBL007);*/
        
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
        Database.upsert(settingProc_GLOB001_GBL023);
        
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
        Database.upsert(conf_GLOB001_GBL023);
        
        System.debug('WSCH_TestDataFactory::createOptimizationURL');
    }
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
        
        System.debug('createOptimizationSettingsMethod');
        
    }
    
}