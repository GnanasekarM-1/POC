@isTest
private class CONF_SetupiPadClient_UT{
    static testMethod void IPAD_SetupiPadClient_UT(){
        
        //SVMXC__ServiceMax_Processes__c IPADProcess = new SVMXC__ServiceMax_Processes__c();
        //insert IPADProcess;
        CONF_SetupiPadClient profile1 = new CONF_SetupiPadClient();
        //profile1.save_WOView();
        //profile1.save_TimeMaterial();
        //profile1.save_WOUpdate();
        //profile1.save_ServiceReport();
        profile1.reset_WOView();
        ////profile1.reset_TimeMaterial();
        //profile1.reset_WOUpdate();
        //profile1.reset_ServiceReport();
        profile1.getAddressType();
        profile1.save_All();
        pageReference pagRef = profile1.cancel();
        SVMXC__ServiceMax_Config_Data__c IPADConfig = new SVMXC__ServiceMax_Config_Data__c();
        List<SVMXC__ServiceMax_Config_Data__c> lstIPADConfig = new List<SVMXC__ServiceMax_Config_Data__c>();
        IPADConfig.SVMXC__Display_Value__c = 'Id'; 
        lstIPADConfig.add(IPADConfig);
        
        system.assert(lstIPADConfig!=null,true);
        
        profile1.SaveSettings(lstIPADConfig,true);
        List<String> lstSTR = new List<String>();
        lstSTR.add('ID');   

        system.assert(lstSTR!=null,true);
        
        //profile1.validateMethod(lstIPADConfig,lstSTR,1);
        //profile1.cancel();
        /*profile1.getTAG001();
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
        profile1.getTAG012();*/
        profile1.getTAG013();
        profile1.getTAG014();
        profile1.getTAG015();
        /*profile1.getTAG016();
        profile1.getTAG017();
        profile1.getTAG018();
        profile1.getTAG019();
        profile1.getTAG020();
        profile1.getTAG021();
        profile1.getTAG022();
        profile1.getTAG023();
        profile1.getTAG024();
        profile1.getTAG025();
        profile1.getTAG026();
        profile1.getTAG027();
        profile1.getTAG028();
        profile1.getTAG029();
        profile1.getTAG030();
        profile1.getTAG031();*/
        profile1.getTAG032();
        profile1.getTAG033();
        profile1.getTAG034();
        profile1.getTAG035();
        profile1.getTAG036();
        profile1.getTAG037();
        profile1.getTAG038();
        profile1.getTAG039();
        profile1.getTAG040();
        profile1.getTAG041();
       // profile1.getTAG042();
        profile1.getTAG043();
        profile1.getTAG044();
        profile1.getTAG045();
        profile1.getTAG046();
        profile1.getTAG047();
        profile1.getTAG048();
        profile1.getTAG049();
        profile1.getTAG050();
        profile1.getTAG051();
        profile1.getTAG052();
        profile1.getTAG053();
        profile1.getTAG054();
        profile1.getTAG055();
        profile1.getTAG056();
        profile1.getTAG057();
        profile1.getTAG058();
        profile1.getTAG059();
        profile1.getTAG060();
        profile1.getTAG061();
        profile1.getTAG062();
        profile1.getTAG063();
        profile1.getTAG064();
        profile1.getTAG065();
        profile1.getTAG042();
        profile1.getTAG066();
        profile1.getTAG067();
        profile1.getTAGHLPURL();
    }
}