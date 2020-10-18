@isTest(SeeAllData=true)
private class CONF_MobileConfig_UT 
{
    static testMethod void CONF_MobileConfig_UT_Test()
    {
        List<string> lstRTNames = new List<string>{'Mobile Configuration','Configuration Profile'};
        String RTConfigProfile;
        String RTMobConf;
        for(RecordType RT : [SELECT Id, Name FROM RecordType WHERE Name IN: lstRTNames AND SobjectType = 'SVMXC__ServiceMax_Config_Data__c'])
        {
            if(RT.Name == 'Configuration Profile')
                RTConfigProfile = RT.Id;
            else if(RT.Name == 'Mobile Configuration')
                RTMobConf = RT.Id;
        }
        
        SVMXC__ServiceMax_Config_Data__c SVMXGrpProfile = new SVMXC__ServiceMax_Config_Data__c();
        SVMXGrpProfile.RecordTypeId = RTConfigProfile;
        SVMXGrpProfile.SVMXC__Select__c =  true;
        SVMXGrpProfile.SVMXC__Profile_Name__c = 'testGrpProfile';
        SVMXGrpProfile.SVMXC__Configuration_Type__c = 'Group';
        insert SVMXGrpProfile;
        System.assert(SVMXGrpProfile.SVMXC__Profile_Name__c == 'testGrpProfile');
        
        List<SVMXC__ServiceMax_Config_Data__c> lstMobileConfigSettings = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        SVMXC__ServiceMax_Config_Data__c mobConfig1 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig1.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig1.RecordTypeId = RTMobConf;
        mobConfig1.SVMXC__Display_Type__c = 'Dataset Synchronization';
        mobConfig1.SVMXC__Internal_Value__c = '30';
        lstMobileConfigSettings.add(mobConfig1);
        
        SVMXC__ServiceMax_Config_Data__c mobConfig2 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig2.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig2.RecordTypeId = RTMobConf;
        mobConfig2.SVMXC__Display_Type__c = 'Frequency of Master Data';
        mobConfig2.SVMXC__Internal_Value__c = '30';
        lstMobileConfigSettings.add(mobConfig2);
        
        SVMXC__ServiceMax_Config_Data__c mobConfig3 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig3.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig3.RecordTypeId = RTMobConf;
        mobConfig3.SVMXC__Display_Type__c = 'Frequency of Application Changes';
        mobConfig3.SVMXC__Internal_Value__c = '30';
        lstMobileConfigSettings.add(mobConfig3);
        
        SVMXC__ServiceMax_Config_Data__c mobConfig4 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig4.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig4.RecordTypeId = RTMobConf;
        mobConfig4.SVMXC__Display_Type__c = 'Synchronization To Get Events';
        mobConfig4.SVMXC__Internal_Value__c = '10';
        lstMobileConfigSettings.add(mobConfig4);
        
        SVMXC__ServiceMax_Config_Data__c mobConfig5 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig5.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig5.RecordTypeId = RTMobConf;
        mobConfig5.SVMXC__Display_Type__c = 'Synchronization To Remove Events';
        mobConfig5.SVMXC__Internal_Value__c = '10';
        lstMobileConfigSettings.add(mobConfig5);
        
        SVMXC__ServiceMax_Config_Data__c mobConfig6 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig6.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig6.RecordTypeId = RTMobConf;
        mobConfig6.SVMXC__Display_Type__c = 'Conflict Resolution';
        mobConfig6.SVMXC__Internal_Value__c = 'ServiceMax online data';
        lstMobileConfigSettings.add(mobConfig6);
        
        SVMXC__ServiceMax_Config_Data__c mobConfig7 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig7.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig7.RecordTypeId = RTMobConf;
        mobConfig7.SVMXC__Display_Type__c = 'Chatter Threads';
        mobConfig7.SVMXC__Internal_Value__c = '10';
        lstMobileConfigSettings.add(mobConfig7);
        
        SVMXC__ServiceMax_Config_Data__c mobConfig8 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig8.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig8.RecordTypeId = RTMobConf;
        mobConfig8.SVMXC__Display_Type__c = 'Download Limit For KB';
        mobConfig8.SVMXC__Internal_Value__c = '50';
        lstMobileConfigSettings.add(mobConfig8);
        
        SVMXC__ServiceMax_Config_Data__c mobConfig9 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig9.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig9.RecordTypeId = RTMobConf;
        mobConfig9.SVMXC__Display_Type__c = 'Location Tracking Frequency';
        mobConfig9.SVMXC__Internal_Value__c = '30';
        lstMobileConfigSettings.add(mobConfig9);
        
        SVMXC__ServiceMax_Config_Data__c mobConfig10 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig10.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig10.RecordTypeId = RTMobConf;
        mobConfig10.SVMXC__Display_Type__c = 'Enable Location Tracking';
        mobConfig10.SVMXC__Internal_Value__c = 'false';
        lstMobileConfigSettings.add(mobConfig10);
        
        SVMXC__ServiceMax_Config_Data__c mobConfig11 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig11.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig11.RecordTypeId = RTMobConf;
        mobConfig11.SVMXC__Display_Type__c = 'Location History Records to cache';
        mobConfig11.SVMXC__Internal_Value__c = '30';
        lstMobileConfigSettings.add(mobConfig11);
        
        SVMXC__ServiceMax_Config_Data__c mobConfig12 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig12.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig12.RecordTypeId = RTMobConf;
        mobConfig12.SVMXC__Display_Type__c = 'Set Technician Location';
        mobConfig12.SVMXC__Internal_Value__c = 'false';
        lstMobileConfigSettings.add(mobConfig12);
        
        SVMXC__ServiceMax_Config_Data__c mobConfig13 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig13.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig13.RecordTypeId = RTMobConf;
        mobConfig13.SVMXC__Display_Type__c = 'Allow API Access';
        mobConfig13.SVMXC__Internal_Value__c = 'true';
        lstMobileConfigSettings.add(mobConfig13);
        
        SVMXC__ServiceMax_Config_Data__c mobConfig14 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig14.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig14.RecordTypeId = RTMobConf;
        mobConfig14.SVMXC__Display_Type__c = 'PURGE_FREQ';
        mobConfig14.SVMXC__Internal_Value__c = '250';
        lstMobileConfigSettings.add(mobConfig14);
        
        SVMXC__ServiceMax_Config_Data__c mobConfig15 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig15.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig15.RecordTypeId = RTMobConf;
        mobConfig15.SVMXC__Display_Type__c = 'PURGE_REC_OLDER_THAN';
        mobConfig15.SVMXC__Internal_Value__c = '10';
        lstMobileConfigSettings.add(mobConfig15);
        
        SVMXC__ServiceMax_Config_Data__c mobConfig16 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig16.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig16.RecordTypeId = RTMobConf;
        mobConfig16.SVMXC__Display_Type__c = 'Download Criteria';
        mobConfig16.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        mobConfig16.SVMXC__Ownership_Type__c = 'All Records';
        mobConfig16.SVMXC__Sequence__c = 1;
        lstMobileConfigSettings.add(mobConfig16);
        
        SVMXC__ServiceMax_Config_Data__c mobConfig17 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig17.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig17.RecordTypeId = RTMobConf;
        mobConfig17.SVMXC__Display_Type__c = 'Advanced Download Criteria';
        mobConfig17.SVMXC__Object_Name__c = 'Account';
        mobConfig17.SVMXC__Ownership_Type__c = 'All Records';
        mobConfig17.SVMXC__Sequence__c = 1;
        lstMobileConfigSettings.add(mobConfig17);
        
        SVMXC__ServiceMax_Config_Data__c mobConfigFiles = new SVMXC__ServiceMax_Config_Data__c();
        mobConfigFiles.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfigFiles.RecordTypeId = RTMobConf;
        mobConfigFiles.SVMXC__Display_Type__c = 'Advanced Download Criteria';
        mobConfigFiles.SVMXC__Object_Name__c = 'Files';
        mobConfigFiles.SVMXC__SM_Files_Config__c = '{\"maxFileSize\":\"25\",\"isFilesEnabled\":true,\"fileTypes\":\"jpg,html\",\"fileTags\":\"\"}' ;
        mobConfigFiles.SVMXC__Sequence__c = 1;
        lstMobileConfigSettings.add(mobConfigFiles);
        
        SVMXC__ServiceMax_Config_Data__c mobConfig18 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig18.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig18.RecordTypeId = RTMobConf;
        mobConfig18.SVMXC__Display_Type__c = 'Enable Logging';
        mobConfig18.SVMXC__Internal_Value__c = '30';
        lstMobileConfigSettings.add(mobConfig18);
        
        SVMXC__ServiceMax_Config_Data__c mobConfig19 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig19.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig19.RecordTypeId = RTMobConf;
        mobConfig19.SVMXC__Display_Type__c = 'Enable Performance Profiling';
        mobConfig19.SVMXC__Internal_Value__c = 'true';
        lstMobileConfigSettings.add(mobConfig19);
        
        SVMXC__ServiceMax_Config_Data__c mobConfig20 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig20.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig20.RecordTypeId = RTMobConf;
        mobConfig20.SVMXC__Display_Type__c = 'Enable SOQL Profiling';
        mobConfig20.SVMXC__Internal_Value__c = 'true';
        lstMobileConfigSettings.add(mobConfig20);
        
        SVMXC__ServiceMax_Config_Data__c mobConfig21 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig21.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig21.RecordTypeId = RTMobConf;
        mobConfig21.SVMXC__Display_Type__c = 'Performance Profiling Org Type';
        mobConfig21.SVMXC__Internal_Value__c = 'Custom';
        lstMobileConfigSettings.add(mobConfig21);
        
        SVMXC__ServiceMax_Config_Data__c mobConfig22 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig22.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig22.RecordTypeId = RTMobConf;
        mobConfig22.SVMXC__Display_Type__c = 'Performance Profiling Endpoint Url';
        mobConfig22.SVMXC__Internal_Value__c = 'empp.servicemax-api.com';
        lstMobileConfigSettings.add(mobConfig22);
        
        SVMXC__ServiceMax_Config_Data__c mobConfig23 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig23.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig23.RecordTypeId = RTMobConf;
        mobConfig23.SVMXC__Display_Type__c = 'Enable Checklist';
        mobConfig23.SVMXC__Internal_Value__c = 'true';
        lstMobileConfigSettings.add(mobConfig23);
        
        SVMXC__ServiceMax_Config_Data__c mobConfig24 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig24.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig24.RecordTypeId = RTMobConf;
        mobConfig24.SVMXC__Display_Type__c = 'Completed Checklists';
        mobConfig24.SVMXC__Internal_Value__c = 'true';
        lstMobileConfigSettings.add(mobConfig24);
        
        SVMXC__ServiceMax_Config_Data__c mobConfig25 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig25.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig25.RecordTypeId = RTMobConf;
        mobConfig25.SVMXC__Display_Type__c = 'InProgress Checklists';
        mobConfig25.SVMXC__Internal_Value__c = 'true';
        lstMobileConfigSettings.add(mobConfig25);
        
        //Usage Logging
        SVMXC__ServiceMax_Config_Data__c mobConfig26 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig26.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig26.RecordTypeId = RTMobConf;
        mobConfig26.SVMXC__Display_Type__c = 'Enable Logging';
        mobConfig26.SVMXC__Internal_Value__c = 'true';
        lstMobileConfigSettings.add(mobConfig26);
        
        SVMXC__ServiceMax_Config_Data__c mobConfig27 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig27.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig27.RecordTypeId = RTMobConf;
        mobConfig27.SVMXC__Display_Type__c = 'Enable Usage Logging';
        
        //validate Key
        String orgId = UserInfo.getOrganizationId();
        String strType = 'error';
        Blob key = EncodingUtil.base64Decode('DHrjCunJBoQvVjRjvWJLnBKIvPNHO0cuWciRhy8mARQ=');
        Blob data = Blob.valueOf(orgId + '||' + string.valueOf(System.today()+10) + '||' + '' + '||' + strType); 
        Blob encrypted = Crypto.encryptWithManagedIV('AES256', key, data);        
        mobConfig27.SVMXC__Internal_Value__c = EncodingUtil.base64Encode(encrypted);
        lstMobileConfigSettings.add(mobConfig27);
        
        SVMXC__ServiceMax_Config_Data__c mobConfig28 = new SVMXC__ServiceMax_Config_Data__c();
        mobConfig28.SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id;
        mobConfig28.RecordTypeId = RTMobConf;
        mobConfig28.SVMXC__Display_Type__c = 'Usage Logging User Option';
        mobConfig28.SVMXC__Internal_Value__c = 'error';
        lstMobileConfigSettings.add(mobConfig28);
        
        insert lstMobileConfigSettings;
        
        System.assert(lstMobileConfigSettings != null);
        System.assert(lstMobileConfigSettings.size() > 0);
        
        CONF_MobileConfig confMobileConfigObj = new CONF_MobileConfig();
        
        //Calling of all the getter Methods
        confMobileConfigObj.getprofileOptns();
        confMobileConfigObj.getconfiguredProfileOptns();
        confMobileConfigObj.getconflictResolutionOptns();
        confMobileConfigObj.getUserAccessLstSelOptn();
        //confMobileConfigObj.getdatasetSynchronizationOptns();
        confMobileConfigObj.getprocessType();
        confMobileConfigObj.getOperatorSelectLst();
        confMobileConfigObj.gettxObj();
        confMobileConfigObj.gettxObjAdvDwnld();
        confMobileConfigObj.getHdrfldlist();
        confMobileConfigObj.SetselectedProcessObjs(confMobileConfigObj.getselectedProcessObjs());
        confMobileConfigObj.getSelectedLstPrss();
        confMobileConfigObj.getmapAPILabel_Name();
        confMobileConfigObj.getIsFreqBased();
        confMobileConfigObj.getAdvExp_DetailSize();
        confMobileConfigObj.setlstWrapperConfData(confMobileConfigObj.getlstWrapperConfData());
        confMobileConfigObj.getWrapperSize();
        confMobileConfigObj.getExpDetailSize();
        confMobileConfigObj.setlstAdvDwnldCriWrp(confMobileConfigObj.getlstAdvDwnldCriWrp());
        confMobileConfigObj.getAdvDwnldCriWrpSize();
        confMobileConfigObj.setExpToShow(confMobileConfigObj.getExpToShow());
        
        //Calling Methods without data preparation
        confMobileConfigObj.cancel();
        confMobileConfigObj.GoSetupHome();
        confMobileConfigObj.cancelExp();
        confMobileConfigObj.cancelExp_AdvDwnldCrit();
        confMobileConfigObj.retURL = '/apex/abcdefg';
        confMobileConfigObj.cancel();
        
        //Profile Selected
        confMobileConfigObj.selectedProfile = SVMXGrpProfile.id;
        System.assert(confMobileConfigObj.selectedProfile != null);
        confMobileConfigObj.getDeviceTargetedConfiguration();
        confMobileConfigObj.getDeviceTargetedConfiguration();
                        
        confMobileConfigObj.editDeviceMobileConfig();
        confMobileConfigObj.deleteDeviceMobileConfig();        
        confMobileConfigObj.listOfDeviceTargetWrap[0].isSelect=true;        
        confMobileConfigObj.editDeviceMobileConfig();        
        confMobileConfigObj.deleteDeviceMobileConfig();
        confMobileConfigObj.cancelDeviceTargetConfig(); 
        
        //Configured Profile Selected
        confMobileConfigObj.selectedConfiguredProfile = SVMXGrpProfile.id;
        confMobileConfigObj.cloneDeviceTargetConfig();
        
        //Adding new row in the Download Criteria and Advanced Download Criteria
        confMobileConfigObj.addRowDispatch();
        confMobileConfigObj.addRow_AdvDwnldCrit();
        confMobileConfigObj.enablesoqlPerformance();
        confMobileConfigObj.disableChecklistFeature();
        confMobileConfigObj.enableCustomUrl();
        
        //Deleting Rows in the Download Criteria and Advanced Download Criteria
        if(confMobileConfigObj.lstWrapperConfData != null && confMobileConfigObj.lstWrapperConfData.size() > 0)
        {
            confMobileConfigObj.delrow();
            confMobileConfigObj.lstWrapperConfData[0].IsSelectRow = true;
            confMobileConfigObj.delrow();
        }
        if(confMobileConfigObj.lstAdvDwnldCriWrp != null && confMobileConfigObj.lstAdvDwnldCriWrp.size() > 0)
        {
            confMobileConfigObj.delrow_AdvDwnldCrit();
            confMobileConfigObj.lstAdvDwnldCriWrp[0].IsSelectRow = true;
            confMobileConfigObj.delrow_AdvDwnldCrit();
        }
        
        //Process Object Map UI Method Calls
        //confMobileConfigObj.funDataSyn();
        //confMobileConfigObj.DatasetSynchron = 'Every';
        //confMobileConfigObj.funDataSyn();
        confMobileConfigObj.searchByObjKey = 'SVMXC__Service_Order__c';
        confMobileConfigObj.searchByObj();
        confMobileConfigObj.searchByObjKey = 'SVMX.None';
        confMobileConfigObj.searchByObj();
        confMobileConfigObj.searchByTyp = 'SOURCE TO TARGET ALL';
        confMobileConfigObj.searchProcessByType();
        confMobileConfigObj.searchByTyp = 'SVMX.None';
        confMobileConfigObj.searchProcessByType();
        /*confMobileConfigObj.selectedProcess = [select id from SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='Process Node Objects' or SVMXC__Record_Type_Name__c ='Target Manager' limit 1][0].Id;
        System.assert(confMobileConfigObj.selectedProcess != null);
        confMobileConfigObj.onSelectProcess();*/
        
        //Selecting Object in the Download Criteria and Advanced Download Criteria
        confMobileConfigObj.onSelectObj();
        confMobileConfigObj.onSelect_AdvDwnldCritObj();
        confMobileConfigObj.selectedObjSerial = 1;
        if(confMobileConfigObj.lstWrapperConfData != null && confMobileConfigObj.lstWrapperConfData.size() > 0)
        {
            confMobileConfigObj.lstWrapperConfData[0].selectedObjName = 'SVMXC__Service_Order__c';
            confMobileConfigObj.onSelectObj();
            confMobileConfigObj.lstWrapperConfData[0].selectedObjName = 'SVMX.None';
            confMobileConfigObj.onSelectObj();
        }
        confMobileConfigObj.onSelectSetting();
        if(confMobileConfigObj.lstAdvDwnldCriWrp != null && confMobileConfigObj.lstAdvDwnldCriWrp.size() > 0)
        {
            confMobileConfigObj.lstAdvDwnldCriWrp[0].selectedObjName = 'SVMXC__Service_Order__c';
            confMobileConfigObj.onSelect_AdvDwnldCritObj();
            confMobileConfigObj.lstAdvDwnldCriWrp[0].selectedObjName = 'SVMX.None';
            confMobileConfigObj.onSelect_AdvDwnldCritObj();
        }
        confMobileConfigObj.onSelectPro_AdvDwnldCrit();
        
        //Adding Filters for Download Criteria and Advanced Download Criteria
        confMobileConfigObj.AddFilter();
        confMobileConfigObj.AdvDwnldCrit_selectedObjSerial = '1';
        confMobileConfigObj.AdvDwnldCrit_AddFilter();
        
        //Getter Methods of the Wrapper Classes
        CONF_MobileConfig.advDwnldCrit_DtlWrap advWrprObj = new CONF_MobileConfig.advDwnldCrit_DtlWrap();
        advWrprObj.getdtlObjLstSO();
        advWrprObj.getdtlFldLstSO();
        CONF_MobileConfig.advDwnldCritWrap wrp = new CONF_MobileConfig.advDwnldCritWrap();
        wrp.getExpPro();
        wrp.setdtlWrap(wrp.getdtlWrap());
        
        //Save Operation
        confMobileConfigObj.saveDeviceTargetConfig();
Test.startTest();        
        //Filters related Methods
        confMobileConfigObj.EditFilter();
        //confMobileConfigObj.AdvDwnldCrit_EditFilter();
        confMobileConfigObj.HdrDeleteRow();
        confMobileConfigObj.AdvExp_DeleteRow();
        confMobileConfigObj.onSelectfld_AdvExp();
        confMobileConfigObj.onSelectRefObj_AdvExp();
        
        //Expressions Save Methods
        confMobileConfigObj.submitExp();
        confMobileConfigObj.submitExp_AdvDwnldCrit();
        
        //Tags getter methods
        confMobileConfigObj.getHLPURL();
        confMobileConfigObj.getTAG001();
        confMobileConfigObj.getTAG002();
        confMobileConfigObj.getTAG003();
        confMobileConfigObj.getTAG004();
        confMobileConfigObj.getTAG005();
        confMobileConfigObj.getTAG006();
        confMobileConfigObj.getTAG007();
        confMobileConfigObj.getTAG008();
        confMobileConfigObj.getTAG009();
        confMobileConfigObj.getTAG010();
        confMobileConfigObj.getTAG012();
        confMobileConfigObj.getTAG013();
        confMobileConfigObj.getTAG014();
        confMobileConfigObj.getTAG015();
        confMobileConfigObj.getTAG016();
        confMobileConfigObj.getTAG017();
        confMobileConfigObj.getTAG018();
        confMobileConfigObj.getTAG020();
        confMobileConfigObj.getTAG021();
        confMobileConfigObj.getTAG022();
        confMobileConfigObj.getTAG023();
        confMobileConfigObj.getTAG024();
        confMobileConfigObj.getTAG025();
        confMobileConfigObj.getTAG026();
        confMobileConfigObj.getTAG027();
        confMobileConfigObj.getTAG028();
        confMobileConfigObj.getTAG029();
        confMobileConfigObj.getTAG030();
        confMobileConfigObj.getTAG045();
        confMobileConfigObj.getTAG046();
        confMobileConfigObj.getTAG049();
        confMobileConfigObj.getTAG050();                
        confMobileConfigObj.getTAG058();         
        confMobileConfigObj.getTAG060();
        confMobileConfigObj.getTAG061();
        confMobileConfigObj.getTAG062();
        confMobileConfigObj.getTAG063();
        confMobileConfigObj.getTAG064();
        confMobileConfigObj.getTAG065();
        confMobileConfigObj.getTAG066();
        confMobileConfigObj.getTAG067();
        confMobileConfigObj.getTAG068();
        confMobileConfigObj.getTAG069();
        confMobileConfigObj.getTAG070();
        confMobileConfigObj.getTAG071();
        confMobileConfigObj.getTAG072();
        confMobileConfigObj.getTAG073();
        confMobileConfigObj.getTAG074();
        confMobileConfigObj.getTAG075();
        confMobileConfigObj.getTAG077();
        confMobileConfigObj.getTAG078();
        confMobileConfigObj.getTAG079();
        confMobileConfigObj.getTAG080();
        confMobileConfigObj.getTAG081();
        confMobileConfigObj.getTAG082();
        confMobileConfigObj.getTAG083();
        confMobileConfigObj.getTAG084();
        confMobileConfigObj.getTAG085();
        confMobileConfigObj.getTAG086();
        confMobileConfigObj.getTAG087();
        confMobileConfigObj.getTAG088();
        confMobileConfigObj.getTAG089();
        confMobileConfigObj.getTAG091();                
        confMobileConfigObj.getTAG092();
        confMobileConfigObj.getTAG093();
        confMobileConfigObj.getTAG094();
        confMobileConfigObj.getTAG097();
        confMobileConfigObj.getTAG098();
        confMobileConfigObj.getTAG099();
        confMobileConfigObj.getTAG100();
        confMobileConfigObj.getTAG101();
        confMobileConfigObj.getTAG102();
        confMobileConfigObj.getTAG103();
        confMobileConfigObj.getTAG104();
        confMobileConfigObj.getTAG105();    
        confMobileConfigObj.getTAG107();    
        confMobileConfigObj.getTAG108();    
        confMobileConfigObj.getTAG109();    
        confMobileConfigObj.getTAG110();    
        confMobileConfigObj.getTAG111();    
        confMobileConfigObj.getTAG112();    
        confMobileConfigObj.getTAG113();                                                                
        confMobileConfigObj.getTAG114();    
        confMobileConfigObj.getTAG115();    
        confMobileConfigObj.getTAG116();    
        confMobileConfigObj.getTAG117();                                                                        
        confMobileConfigObj.getTAG118();                                                                        
        confMobileConfigObj.getTAG119();                                                                                        
        confMobileConfigObj.getTAG127();  
        confMobileConfigObj.getTAG130();  
        confMobileConfigObj.getTAG131();  
        confMobileConfigObj.getTAG132();  
        confMobileConfigObj.getTAG133();                                                                                        
        confMobileConfigObj.getTAG134();  
        confMobileConfigObj.getTAG135();  
        confMobileConfigObj.getTAG136();  
        confMobileConfigObj.getTAG137();                                  
        confMobileConfigObj.getTAG138(); 
        confMobileConfigObj.getTAG139();
        confMobileConfigObj.getTAG140();
        confMobileConfigObj.getTAG144();
        confMobileConfigObj.getTAG145();
        confMobileConfigObj.getTAG146();
        confMobileConfigObj.getTAG147();
        confMobileConfigObj.getTAG148();
        confMobileConfigObj.getTAG149();
        confMobileConfigObj.getTAG146();
        
Test.stopTest();                                                         
    }
    
    static testMethod void CONF_MobileConfig_UT_Test1()
    {
        List<string> lstRTNames = new List<string>{'Mobile Configuration','Configuration Profile','SVMX Rule','Expressions'};
        String RTConfigProfile;
        String RTMobConf;
        String RTProRule;
        String RTConfigExp;
        for(RecordType RT : [SELECT Id, Name FROM RecordType WHERE Name IN: lstRTNames AND (SobjectType = 'SVMXC__ServiceMax_Config_Data__c' OR SobjectType = 'SVMXC__ServiceMax_Processes__c')])
        {
            if(RT.Name == 'Configuration Profile')
                RTConfigProfile = RT.Id;
            else if(RT.Name == 'Mobile Configuration')
                RTMobConf = RT.Id;
            else if(RT.Name == 'SVMX Rule')
                RTProRule = RT.Id;
            else if(RT.Name == 'Expressions')
                RTConfigExp = RT.Id;
        }
        
        SVMXC__ServiceMax_Config_Data__c SVMXGrpProfile = new SVMXC__ServiceMax_Config_Data__c();
        SVMXGrpProfile.RecordTypeId = RTConfigProfile;
        SVMXGrpProfile.SVMXC__Select__c =  true;
        SVMXGrpProfile.SVMXC__Profile_Name__c = 'testGrpProfile';
        SVMXGrpProfile.SVMXC__Configuration_Type__c = 'Group';
        insert SVMXGrpProfile;
        System.assert(SVMXGrpProfile.SVMXC__Profile_Name__c == 'testGrpProfile');
        
        SVMXC__ServiceMax_Processes__c expPro = new SVMXC__ServiceMax_Processes__c(RecordTypeId = RTProRule,SVMXC__Name__c = 'ExpProcess001',SVMXC__ProcessID__c = 'ExpProcess001', SVMXC__Source_Object_Name__c ='SVMXC__Service_Order__c',SVMXC__Rule_Type__c='Named Expression',SVMXC__SettingId__c = 'ExpProcess001');
        insert expPro;
        
        SVMXC__ServiceMax_Processes__c advExpPro = new SVMXC__ServiceMax_Processes__c(RecordTypeId = RTProRule,SVMXC__Name__c = 'ExpProcess002',SVMXC__ProcessID__c = 'ExpProcess002', SVMXC__Source_Object_Name__c ='Account',SVMXC__Rule_Type__c = 'Adv Criteria Exp',SVMXC__SettingId__c = 'ExpProcess002');
        insert advExpPro;
        
        List<SVMXC__ServiceMax_Config_Data__c> lstExpressionDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        SVMXC__ServiceMax_Config_Data__c expDtl = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp,SVMXC__Sequence__c=1,SVMXC__Field_Name__c='SVMXC__Order_Status__c',SVMXC__Operator__c='eq',SVMXC__Operand__c='Open',SVMXC__Object_Name__c='SVMXC__Service_Order__c',SVMXC__Expression_Rule__c=expPro.Id,SVMXC__Expression_Type__c='EXP_Named');
        lstExpressionDetails.add(expDtl);
        SVMXC__ServiceMax_Config_Data__c advExpDtl = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTConfigExp,SVMXC__Sequence__c=1,SVMXC__Field_Name__c='Id',SVMXC__Operator__c='in',SVMXC__Operand__c='',SVMXC__Object_Name2__c='SVMXC__Service_Order__c',SVMXC__Source_Field_Name__c='SVMXC__Company__c',SVMXC__Object_Name__c='Account',SVMXC__Expression_Rule__c=advExpPro.Id,SVMXC__Expression_Type__c='EXP_Named',SVMXC__Display_Type__c='ID');
        lstExpressionDetails.add(advExpDtl);
        
        SVMXC__ServiceMax_Config_Data__c mobConfigDC = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id,RecordTypeId = RTMobConf,SVMXC__Display_Type__c = 'Download Criteria',SVMXC__Object_Name__c = 'SVMXC__Service_Order__c',SVMXC__Ownership_Type__c = 'All Records',SVMXC__Sequence__c = 1,SVMXC__Dispatch_Process__c=expPro.Id);
        lstExpressionDetails.add(mobConfigDC);
        
        SVMXC__ServiceMax_Config_Data__c mobConfigADC = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTMobConf,SVMXC__Access_Configuration_Profile__c = SVMXGrpProfile.id,SVMXC__Display_Type__c = 'Advanced Download Criteria',SVMXC__Object_Name__c = 'Account',SVMXC__Ownership_Type__c = 'All Records',SVMXC__Sequence__c = 1,SVMXC__Dispatch_Process__c=advExpPro.Id);
        lstExpressionDetails.add(mobConfigADC);
        
        insert lstExpressionDetails;
        
        CONF_MobileConfig confMobileConfigObj = new CONF_MobileConfig();
        
        //Profile Selected
        confMobileConfigObj.selectedProfile = SVMXGrpProfile.id;
        System.assert(confMobileConfigObj.selectedProfile != null);
        confMobileConfigObj.getDeviceTargetedConfiguration();
        
        //Edit Filter and Save Expressions for Download Criteria and Advanced Download Criteria
        confMobileConfigObj.editFilterId = expPro.Id;
        confMobileConfigObj.ObjNameToFilter = 'SVMXC__Service_Order__c';
        confMobileConfigObj.EditFilter();
        confMobileConfigObj.ObjNameFrSaveExp = 'SVMXC__Service_Order__c';
        confMobileConfigObj.selectedObjSerial = 1;
        confMobileConfigObj.submitExp();
        
        confMobileConfigObj.AdvDwnldCrit_editFilterId = advExpPro.Id;
        confMobileConfigObj.AdvDwnldCrit_ObjNameToFilter = 'Account';
        confMobileConfigObj.AdvDwnldCrit_selectedObjSerial = '1';
        confMobileConfigObj.AdvDwnldCrit_EditFilter();
        confMobileConfigObj.advExpId = RTProRule;
        confMobileConfigObj.AdvDwnldCrit_ObjNameToFilter = 'Account';
        confMobileConfigObj.ObjName_SaveAdvDwnldCritExp = 'Account';
        confMobileConfigObj.AdvDwnldCrit_selectedObjSerial = '1';
        //confMobileConfigObj.submitExp_AdvDwnldCrit();
    }
    
    static testmethod void CONF_MobileconfigDevice()
    {
    
        List<string> lstRTNames = new List<string>{'Mobile Configuration','Configuration Profile','SVMX Rule','Expressions'};
        String RTConfigProfile;
        String RTMobConf;
        String RTProRule;
        String RTConfigExp;
        for(RecordType RT : [SELECT Id, Name FROM RecordType WHERE Name IN: lstRTNames AND (SobjectType = 'SVMXC__ServiceMax_Config_Data__c' OR SobjectType = 'SVMXC__ServiceMax_Processes__c')])
        {
            if(RT.Name == 'Configuration Profile')
                RTConfigProfile = RT.Id;
            else if(RT.Name == 'Mobile Configuration')
                RTMobConf = RT.Id;
            else if(RT.Name == 'SVMX Rule')
                RTProRule = RT.Id;
            else if(RT.Name == 'Expressions')
                RTConfigExp = RT.Id;
        }
        
        SVMXC__ServiceMax_Config_Data__c SVMXGrpProfile = new SVMXC__ServiceMax_Config_Data__c();
        SVMXGrpProfile.RecordTypeId = RTConfigProfile;
        SVMXGrpProfile.SVMXC__Select__c =  true;
        SVMXGrpProfile.SVMXC__Profile_Name__c = 'testGrpProfile';
        SVMXGrpProfile.SVMXC__Configuration_Type__c = 'Group';
        insert SVMXGrpProfile;
                        
        CONF_MobileConfig confMobileConfigObj = new CONF_MobileConfig();
        try 
        {               
            confMobileConfigObj.selectedProfile = 'SVMX.None';
            confMobileconfigObj.getDeviceTargetedConfiguration();
            
            confMobileConfigObj.selectedProfile = SVMXGrpProfile.id;
            System.assert(confMobileConfigObj.selectedProfile != null);
            confMobileConfigObj.getDeviceTargetedConfiguration();
            
            System.assert(!confMobileConfigObj.listOfDeviceTargetWrap.isEmpty());
            confMobileConfigObj.listOfDeviceTargetWrap[0].isSelect=true;
            confMobileConfigObj.editDeviceMobileConfig();
            confMobileConfigObj.newMobileConfig.SM_IsDefault__c=false;
            confMobileconfigObj.saveDeviceTargetConfig();
            
            confMobileConfigObj.addDeviceMobileConfig();
            System.assert(confMobileconfigObj.disableSaveCancelBtn==false);
            
            confMobileConfigObj.saveDeviceTargetConfig();
            System.assert(confMobileConfigObj.topPagMsgDevice);        
            
            confMobileConfigObj.newMobileConfig.SM_Name__c='iPad Configuration';                
            confMobileConfigObj.saveDeviceTargetConfig();
            
            confMobileConfigObj.newMobileConfig.SM_Description__c='Configuration for iPad Devices';    
            confMobileConfigObj.saveDeviceTargetConfig();
            
            confMobileConfigObj.newMobileConfig.SM_Device_Type__c='iPad'; 
            confMobileConfigObj.newMobileConfig.SM_IsDefault__c=true;   
            confMobileConfigObj.saveDeviceTargetConfig();
            
            confMobileConfigObj.newMobileConfig.SM_Device_Type__c='iPad'; 
            confMobileConfigObj.newMobileConfig.SM_IsDefault__c=true;   
            confMobileConfigObj.saveDeviceTargetConfig();        
            
            confMobileConfigObj.newMobileConfig.SM_Device_Type__c='iPad';
            confMobileConfigObj.newMobileConfig.SM_IsDefault__c=true;
            confMobileConfigObj.freqMasterData='5';
            confMobileConfigObj.freqAppChng='5';  
            confMobileConfigObj.syncGetEvent='5';
            confMobileConfigObj.syncRemoveEvent='5';  
            confMobileConfigObj.chatterThreads='5';
            confMobileConfigObj.downloadLimitKB='5';  
            confMobileConfigObj.strFreqLocTracking='5';
            confMobileConfigObj.strMaxRecToCache='5';  
            confMobileConfigObj.freqDataPurging='5';
            confMobileConfigObj.purgeOlderRec='5'; 
            confMobileConfigObj.isLocationTrack=true;
            confMobileConfigObj.isSetLatestTechLoc=true;
            confMobileConfigObj.allowAPIAccess=true;
            confMobileConfigObj.enableLogging=true;                                       
            confMobileconfigObj.saveDeviceTargetConfig();
            confMobileconfigObj.saveDevice();
            
            confMobileConfigObj.listOfDeviceTargetWrap[0].isSelect=true;
            confMobileConfigObj.listOfDeviceTargetWrap[1].isSelect=true;
            
            confMobileConfigObj.deleteDeviceMobileConfig();        
            confMobileConfigObj.editDeviceMobileConfig();
            
            for(CONF_MobileConfig.DeviceTargetWrap newWrap:confMobileConfigObj.listOfDeviceTargetWrap)
            {
                if(newWrap.deviceMobileConfig.SM_IsDefault__c)
                {
                    newWrap.isSelect=true;
                }
            }               
        }
        catch(Exception ex){}               
        confMobileconfigObj.deleteDeviceMobileConfig();             
        confMobileconfigObj.cancel();
        confMobileconfigObj.cancelDeviceTargetConfig();
        confMobileconfigObj.confirmMessage();
             
        for(CONF_MobileConfig.DeviceTargetWrap newWrap:confMobileConfigObj.listOfDeviceTargetWrap)
        {
            if(!newWrap.deviceMobileConfig.SM_IsDefault__c)
            {
                newWrap.isSelect=true;
            }
        }  
        confMobileconfigObj.deleteDeviceMobileConfig();                 
    } 
}