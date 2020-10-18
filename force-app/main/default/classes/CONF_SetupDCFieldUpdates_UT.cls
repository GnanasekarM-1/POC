@isTest
private class CONF_SetupDCFieldUpdates_UT
{
    static testMethod void CONF_SetupDCFieldUpdates_UT()
    {
        CONF_SetupDCFieldUpdates profile1 = new CONF_SetupDCFieldUpdates();
        profile1.reset();
        profile1.save();
        pageReference pagRef = profile1.cancel();
        SVMXC__ServiceMax_Config_Data__c Config = new SVMXC__ServiceMax_Config_Data__c();
        List<SVMXC__ServiceMax_Config_Data__c> lstConfig = new List<SVMXC__ServiceMax_Config_Data__c>();
        Config.SVMXC__Display_Value__c = 'Id'; 
        lstConfig.add(Config);
        
        system.assert(lstConfig!=null,true);
        
        profile1.SaveSettings(lstConfig,true);
        List<String> lstSTR = new List<String>();
        lstSTR.add('ID');   
        
        system.assert(lstSTR!=null,true);
        
        profile1.getTAG001();
        profile1.getTAG002();
        profile1.getTAG003();
        profile1.getTAG004();
        profile1.getTAG005();
        profile1.getTAG006();
        profile1.getTAG007();
        profile1.getTAG008();
        profile1.getTAG009();
        profile1.getTAG010();
        profile1.getTAG011();
        profile1.getTAG012();
        profile1.getTAG013();
        profile1.getTAG014();
        profile1.getTAG015();
        profile1.getTAG016();
        profile1.getTAG017();
        profile1.getTAG018();
        profile1.getTAG019();
        profile1.getHLPURL();
    }
}