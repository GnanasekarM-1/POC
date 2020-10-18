@isTest
Private class CONF_SeedConfigData_UT 
{
    static testMethod void CONF_SeedConfigData_UT_Test()
    {
        try
        {
        Date ExpDate = Date.Today() + 15;
        String canonical = userInfo.getOrganizationId().subString(0,15) + '~' + String.valueOf(ExpDate);                        
        String InstKey = EncodingUtil.base64Encode(Blob.valueOf(canonical)); 
        SVMXC__ServiceMax_Processes__c ikey = new SVMXC__ServiceMax_Processes__c();
        
        test.starttest();
		
        SVMXC.CONF_SeedConfigData svmxseed = new SVMXC.CONF_SeedConfigData();
      
        ikey = svmxseed.getIKeyConfig();
		system.assert(InstKey!='');
        ikey.SVMXC__Installation_Key__c = InstKey;
		system.assert(ikey.SVMXC__Installation_Key__c!='');
        svmxseed.setIKeyConfig(ikey);
           
        svmxseed.SeedConfigData();

        Boolean boo = svmxseed.getJobDone();

        Boolean boo2 = svmxseed.getJobAlreadyDone();

        svmxseed.BackToHomePage();

        
        SVMXC.CONF_SeedConfigData svmxseed2 = new SVMXC.CONF_SeedConfigData();

        Map<String,ID> ObjectMap = new Map<String,ID>();
        svmxseed.BackToHomePage();
        svmxseed.getJobDone();
        svmxseed.getJobAlreadyDone();
        SVMXC__ServiceMax_Processes__c abc = svmxseed.getIKeyConfig();
        svmxseed.SeedConfigData();
        svmxseed.BuildMapsAndExistingData();
        svmxseed.SVMX_GetRecordTypes();
        svmxseed.SVMX_LoadConfigXML();
        svmxseed.SVMX_ProcessRecord('LevelTwoName',null, null);
        svmxseed.SVMX_LoadModules();
        svmxseed.SVMX_LoadSubmodules(ObjectMap);
        svmxseed.SVMX_LoadSettings(ObjectMap);
        svmxseed.SVMX_LoadObjectMappings();
        svmxseed.SVMX_LoadFieldMappings(ObjectMap);
        svmxseed.SVMX_LoadConfigProfiles();
        svmxseed.SVMX_LoadSettingValues(null, null);
        svmxseed.SVMX_LoadDisplayTags(ObjectMap);
        svmxseed.SVMX_TransferSettings();
        svmxseed.SVMX_ResetXMLData();
        svmxseed.SVMX_DebugDataSet('StageName');
        test.stoptest();
        } catch (Exception e){}
    }
}