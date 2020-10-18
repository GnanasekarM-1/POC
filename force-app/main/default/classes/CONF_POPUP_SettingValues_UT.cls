@isTest(SeeAllData=true)
Private class CONF_POPUP_SettingValues_UT {
 
    
    private static List<RecordType> rtProf  = new List<RecordType>();
    private static List<RecordType> rtConf  = new List<RecordType>();
    private static SVMXC__ServiceMax_Config_Data__c profData = new SVMXC__ServiceMax_Config_Data__c();
     
    private static SVMXC__ServiceMax_Processes__c conf_set = new SVMXC__ServiceMax_Processes__c();
    private static    SVMXC__ServiceMax_Processes__c module =  new SVMXC__ServiceMax_Processes__c();
    private static    SVMXC__ServiceMax_Processes__c subModule = new SVMXC__ServiceMax_Processes__c();
    
    static testMethod void CONF_POPUP_SettingValues_Test()
    {
        
        
     try
     {
        rtProf = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];    
        rtConf = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];    

            
        //Create Module, Submodule, ObjMap, inv process
        
        for(RecordType rt : rtProf) //Loop to take a record type at a time
        {
            // Create Module Record
            if(rt.Name == 'Module')
            {
                SVMXC__ServiceMax_Processes__c mod = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'testModule',
                                            SVMXC__ModuleID__c = 'CUSTOMTEST'                                            
                                            );
                insert mod;
                module = mod;
            } 
        }   
        System.assertEquals('testModule', module.SVMXC__Name__c);
        for(RecordType rt2 : rtProf) //Loop to take a record type at a time
        {
            // Create Sub-Module Record, Link to Module
            if(rt2.Name == 'Submodule')
            {
                SVMXC__ServiceMax_Processes__c subMod = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt2.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'testSubModule',
                                            SVMXC__SubmoduleID__c = 'CUSTOMTEST001',
                                            SVMXC__Module__c = module.Id                                            
                                            );
                insert subMod;
                subModule = subMod;
            } 
        }
        System.assertEquals('testSubModule', subModule.SVMXC__Name__c);
        //// Create Config Profile:
        for(RecordType rt4 : rtConf) //Loop to take a record type at a time
        {
            // Create objMap Record, Link to Module
            if(rt4.Name == 'Configuration Profile')
            {
                SVMXC__ServiceMax_Config_Data__c prof1 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =rt4.Id,
                                            SVMXC__Active__c = false,
                                            SVMXC__Profile_Name__c = 'Custom Config Profile',
                                            SVMXC__Description__c = 'Some Desc',
                                            SVMXC__CONFIGURATION_TYPE__C = 'Global',
                                            SVMXC__IsDefault__c = false
                                            );
                profData = prof1;
            } 
        }
        insert profData;
        System.assertEquals('Custom Config Profile', profData.SVMXC__Profile_Name__c);
         
//populating datas

        SVMXC__ServiceMax_Processes__c SettingPick = new SVMXC__ServiceMax_Processes__c();
        SettingPick=getSettingValueRecord('Setting1','TestPick', 'Picklist');

        SVMXC__ServiceMax_Processes__c SettingBol = new SVMXC__ServiceMax_Processes__c();
        SettingBol=getSettingValueRecord('Setting2','TestBoolean', 'Boolean');
   
        SVMXC__ServiceMax_Processes__c SettingNum = new SVMXC__ServiceMax_Processes__c();
        SettingNum=getSettingValueRecord('Setting2','TestNumber', 'Number');

        SVMXC__ServiceMax_Processes__c SettingDat = new SVMXC__ServiceMax_Processes__c();
        SettingDat=getSettingValueRecord('Setting2','TestDate', 'Date');

        SVMXC__ServiceMax_Processes__c SettingAcc = new SVMXC__ServiceMax_Processes__c();
        SettingAcc=getSettingValueRecord('Setting2','TestUser', 'Account');
         
        SVMXC__ServiceMax_Processes__c SettingDatTime = new SVMXC__ServiceMax_Processes__c();
        SettingDatTime=getSettingValueRecord('Setting2','TestDateTime', 'Date/Time');

        //Boolean
        System.currentPageReference().getParameters().put('src','');
        System.currentPageReference().getParameters().put('sid',SettingBol.Id);
        String Sid= System.currentPageReference().getParameters().get('sid');
        String Source= System.currentPageReference().getParameters().get('src'); 

        SVMXC.CONF_POPUP_SettingValues myPageCon = new SVMXC.CONF_POPUP_SettingValues();
        
         //Translations
         String str1 = myPageCon.getTAG020();
         String str2 = myPageCon.getTAG022();
         String str3 = myPageCon.getTAG023();
         String str4 = myPageCon.getTAG024();
         String str5 = myPageCon.getTAG026();
         String str6 = myPageCon.getTAG027();
         String str7 = myPageCon.getTAG028();
         String str8 = myPageCon.getTAG029();
         String str9 = myPageCon.getTAG031();
         String str10 = myPageCon.getTAG032();
         String str11 = myPageCon.getTAG034();
         String str12 = myPageCon.getTAG035();
         String str13 = myPageCon.getTAG036();
         String str14 = myPageCon.getTAG037();
         String str15 = myPageCon.getTAG038();
         String str16 = myPageCon.getTAG039();
         String hlp = myPageCon.getHLPURL();

         //myPageCon.svmxTagList.clear();

         myPageCon.getTAG020();
         myPageCon.getTAG022();
         myPageCon.getTAG023();
         myPageCon.getTAG024();
         myPageCon.getTAG026();
         myPageCon.getTAG027();
         myPageCon.getTAG028();
         myPageCon.getTAG029();
         myPageCon.getTAG031();
         myPageCon.getTAG032();
         myPageCon.getTAG034();
         myPageCon.getTAG035();
         myPageCon.getHLPURL();

        //void T_CLCon = 
        myPageCon.onLoad();

        SVMXC__ServiceMax_Config_Data__c T_CL1 = myPageCon.getdisplay_data();
        SVMXC__Installed_Product__c T_CL2 = myPageCon.getdisplay_lookup();
        SVMXC__ServiceMax_Processes__c T_CL3 = myPageCon.getSMXSettings();
    
        PageReference T_CL4 = myPageCon.saveSet();
        Boolean T_CL5 = myPageCon.getDisplayBlockLevelMessage();
        Boolean T_CL6 = myPageCon.getSlctradio();
        List<SelectOption> T_CL7 = myPageCon.getBooleans();
        List<SelectOption> T_CL8 = myPageCon.getItems();
        String T_CL11 = myPageCon.getSource();
        SVMXC__ServiceMax_Config_Data__c T_CL12 = myPageCon.getSMXProfSettings();
        List<SelectOption> T_CLe4 = myPageCon.getOptionList();

        //Picklist
        {
        System.currentPageReference().getParameters().put('sid',SettingPick.Id);
        SVMXC.CONF_POPUP_SettingValues myPageCon1 = new SVMXC.CONF_POPUP_SettingValues();
        
        //void T_CLCon1 = 
        myPageCon1.onLoad();
        
        SVMXC__ServiceMax_Config_Data__c T_CL111 = myPageCon1.getdisplay_data();
        SVMXC__Installed_Product__c T_CL21 = myPageCon1.getdisplay_lookup();
        SVMXC__ServiceMax_Processes__c T_CL31 = myPageCon1.getSMXSettings();
        PageReference T_CL41 = myPageCon1.saveSet();
        Boolean T_CL51 = myPageCon1.getDisplayBlockLevelMessage();
        Boolean T_CL61 = myPageCon1.getSlctradio();
        List<SelectOption> T_CL71 = myPageCon1.getBooleans();
        List<SelectOption> T_CL81 = myPageCon1.getItems();
        String T_CL201 = myPageCon1.getSource();
        SVMXC__ServiceMax_Config_Data__c T_CL121 = myPageCon1.getSMXProfSettings();
        }

        //Number
        {
        System.currentPageReference().getParameters().put('sid',SettingNum.Id);
        SVMXC.CONF_POPUP_SettingValues myPageCon1 = new SVMXC.CONF_POPUP_SettingValues();
        
       // void T_CLCon1 = 
        myPageCon1.onLoad();
        
        SVMXC__ServiceMax_Config_Data__c T_CL111 = myPageCon1.getdisplay_data();
        SVMXC__Installed_Product__c T_CL21 = myPageCon1.getdisplay_lookup();
        SVMXC__ServiceMax_Processes__c T_CL31 = myPageCon1.getSMXSettings();
        PageReference T_CL41 = myPageCon1.saveSet();
        Boolean T_CL51 = myPageCon1.getDisplayBlockLevelMessage();
        Boolean T_CL61 = myPageCon1.getSlctradio();
        List<SelectOption> T_CL71 = myPageCon1.getBooleans();
        List<SelectOption> T_CL81 = myPageCon1.getItems();
        String T_CL201 = myPageCon1.getSource();
        SVMXC__ServiceMax_Config_Data__c T_CL121 = myPageCon1.getSMXProfSettings();
        }

        //Date
        {
        System.currentPageReference().getParameters().put('sid',SettingDat.Id);
        SVMXC.CONF_POPUP_SettingValues myPageCon1 = new SVMXC.CONF_POPUP_SettingValues();
        
        // void T_CLCon1 = 
        myPageCon1.onLoad();
        
        SVMXC__ServiceMax_Config_Data__c T_CL111 = myPageCon1.getdisplay_data();
        SVMXC__Installed_Product__c T_CL21 = myPageCon1.getdisplay_lookup();
        SVMXC__ServiceMax_Processes__c T_CL31 = myPageCon1.getSMXSettings();
        PageReference T_CL41 = myPageCon1.saveSet();
        Boolean T_CL51 = myPageCon1.getDisplayBlockLevelMessage();
        Boolean T_CL61 = myPageCon1.getSlctradio();
        List<SelectOption> T_CL71 = myPageCon1.getBooleans();
        List<SelectOption> T_CL81 = myPageCon1.getItems();
        String T_CL201 = myPageCon1.getSource();
        SVMXC__ServiceMax_Config_Data__c T_CL121 = myPageCon1.getSMXProfSettings();
        }
         
        //Date/Time
        {
        System.currentPageReference().getParameters().put('sid',SettingDatTime.Id);
        SVMXC.CONF_POPUP_SettingValues myPageCon1 = new SVMXC.CONF_POPUP_SettingValues();
        
        myPageCon1.onLoad();
        
        SVMXC__ServiceMax_Config_Data__c T_CL111 = myPageCon1.getdisplay_data();
        SVMXC__Installed_Product__c T_CL21 = myPageCon1.getdisplay_lookup();
        SVMXC__ServiceMax_Processes__c T_CL31 = myPageCon1.getSMXSettings();
        PageReference T_CL41 = myPageCon1.saveSet();
        Boolean T_CL51 = myPageCon1.getDisplayBlockLevelMessage();
        Boolean T_CL61 = myPageCon1.getSlctradio();
        List<SelectOption> T_CL71 = myPageCon1.getBooleans();
        List<SelectOption> T_CL81 = myPageCon1.getItems();
        String T_CL201 = myPageCon1.getSource();
        SVMXC__ServiceMax_Config_Data__c T_CL121 = myPageCon1.getSMXProfSettings();
        }

        //Account
        {
        System.currentPageReference().getParameters().put('sid',SettingAcc.Id);
        SVMXC.CONF_POPUP_SettingValues myPageCon1 = new SVMXC.CONF_POPUP_SettingValues();
        
        //void T_CLCon1 = 
        myPageCon1.onLoad();
        
        SVMXC__ServiceMax_Config_Data__c T_CL111 = myPageCon1.getdisplay_data();
        SVMXC__Installed_Product__c T_CL21 = myPageCon1.getdisplay_lookup();
        SVMXC__ServiceMax_Processes__c T_CL31 = myPageCon1.getSMXSettings();
        PageReference T_CL41 = myPageCon1.saveSet();
        Boolean T_CL51 = myPageCon1.getDisplayBlockLevelMessage();
        Boolean T_CL61 = myPageCon1.getSlctradio();
        List<SelectOption> T_CL71 = myPageCon1.getBooleans();
        List<SelectOption> T_CL81 = myPageCon1.getItems();
        String T_CL201 = myPageCon1.getSource();
        SVMXC__ServiceMax_Config_Data__c T_CL121 = myPageCon1.getSMXProfSettings();
        }               

        //Date
        {
        System.currentPageReference().getParameters().put('src','MS');
        System.currentPageReference().getParameters().put('sid',SettingDat.Id);
        SVMXC.CONF_POPUP_SettingValues myPageCon1 = new SVMXC.CONF_POPUP_SettingValues();
        
        //void T_CLCon1 = 
        myPageCon1.onLoad();
        
        SVMXC__ServiceMax_Config_Data__c T_CL111 = myPageCon1.getdisplay_data();
        SVMXC__Installed_Product__c T_CL21 = myPageCon1.getdisplay_lookup();
        SVMXC__ServiceMax_Processes__c T_CL31 = myPageCon1.getSMXSettings();
        PageReference T_CL41 = myPageCon1.saveSet();
        Boolean T_CL51 = myPageCon1.getDisplayBlockLevelMessage();
        Boolean T_CL61 = myPageCon1.getSlctradio();
        List<SelectOption> T_CL71 = myPageCon1.getBooleans();
        List<SelectOption> T_CL81 = myPageCon1.getItems();
        String T_CL201 = myPageCon1.getSource();
        SVMXC__ServiceMax_Config_Data__c T_CL121 = myPageCon1.getSMXProfSettings();
        }
         
        //Date/Time
        {
        System.currentPageReference().getParameters().put('src','MS');
        System.currentPageReference().getParameters().put('sid',SettingDatTime.Id);
        SVMXC.CONF_POPUP_SettingValues myPageCon1 = new SVMXC.CONF_POPUP_SettingValues();
        
        myPageCon1.onLoad();
        
        SVMXC__ServiceMax_Config_Data__c T_CL111 = myPageCon1.getdisplay_data();
        SVMXC__Installed_Product__c T_CL21 = myPageCon1.getdisplay_lookup();
        SVMXC__ServiceMax_Processes__c T_CL31 = myPageCon1.getSMXSettings();
        PageReference T_CL41 = myPageCon1.saveSet();
        Boolean T_CL51 = myPageCon1.getDisplayBlockLevelMessage();
        Boolean T_CL61 = myPageCon1.getSlctradio();
        List<SelectOption> T_CL71 = myPageCon1.getBooleans();
        List<SelectOption> T_CL81 = myPageCon1.getItems();
        String T_CL201 = myPageCon1.getSource();
        SVMXC__ServiceMax_Config_Data__c T_CL121 = myPageCon1.getSMXProfSettings();
        } 

        //Number
        {
        System.currentPageReference().getParameters().put('src','MS');
        System.currentPageReference().getParameters().put('sid',SettingNum.Id);
        SVMXC.CONF_POPUP_SettingValues myPageCon1 = new SVMXC.CONF_POPUP_SettingValues();
        
        //void T_CLCon1 = 
        myPageCon1.onLoad();
        
        SVMXC__ServiceMax_Config_Data__c T_CL111 = myPageCon1.getdisplay_data();
        SVMXC__Installed_Product__c T_CL21 = myPageCon1.getdisplay_lookup();
        SVMXC__ServiceMax_Processes__c T_CL31 = myPageCon1.getSMXSettings();
        PageReference T_CL41 = myPageCon1.saveSet();
        Boolean T_CL51 = myPageCon1.getDisplayBlockLevelMessage();
        Boolean T_CL61 = myPageCon1.getSlctradio();
        List<SelectOption> T_CL71 = myPageCon1.getBooleans();
        List<SelectOption> T_CL81 = myPageCon1.getItems();
        String T_CL201 = myPageCon1.getSource();
        SVMXC__ServiceMax_Config_Data__c T_CL121 = myPageCon1.getSMXProfSettings();
        }

        //Account
        {
        System.currentPageReference().getParameters().put('src','MS');
        System.currentPageReference().getParameters().put('sid',SettingAcc.Id);
        SVMXC.CONF_POPUP_SettingValues myPageCon1 = new SVMXC.CONF_POPUP_SettingValues();
        
        //void T_CLCon1 = 
        myPageCon1.onLoad();
        
        SVMXC__ServiceMax_Config_Data__c T_CL111 = myPageCon1.getdisplay_data();
        SVMXC__Installed_Product__c T_CL21 = myPageCon1.getdisplay_lookup();
        SVMXC__ServiceMax_Processes__c T_CL31 = myPageCon1.getSMXSettings();
        PageReference T_CL41 = myPageCon1.saveSet();
        Boolean T_CL51 = myPageCon1.getDisplayBlockLevelMessage();
        Boolean T_CL61 = myPageCon1.getSlctradio();
        List<SelectOption> T_CL71 = myPageCon1.getBooleans();
        List<SelectOption> T_CL81 = myPageCon1.getItems();
        String T_CL201 = myPageCon1.getSource();
        SVMXC__ServiceMax_Config_Data__c T_CL121 = myPageCon1.getSMXProfSettings();
        }               


      }
  catch(Exception ex)
       {
         ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));
       } 
    
}
        
    static  SVMXC__ServiceMax_Processes__c getSettingValueRecord(String SettingName,String SettingId, String DType)
    {     
        SVMXC__ServiceMax_Processes__c SettingDefRecord = new SVMXC__ServiceMax_Processes__c(); 
        
        try{
        for(RecordType rt3 : rtProf) //Loop to take a record type at a time
        {
            // Create objMap Record, Link to Module
            if(rt3.Name == 'Settings')
            {
                SettingDefRecord = new SVMXC__ServiceMax_Processes__c(
                                    RecordTypeId =rt3.Id,
                                    SVMXC__Description__c = 'TEST Mapping',
                                    SVMXC__SettingID__c = SettingId,
                                    SVMXC__Data_Type__c = DType,
                                    SVMXC__SUBMODULE__C = subModule.Id,
                                    Values__c = 'Option1~|~OPtion2',
                                    Default_Value__c = 'Default',
                                    SVMXC__Settings_Name__c = SettingName                                            
                                    );
                 insert SettingDefRecord;
            } 
        }

        for(RecordType rt5 : rtConf) //Loop to take a record type at a time
        {
            // Create objMap Record, Link to Module
            if(rt5.Name == 'Setting Value')
            {
                SVMXC__ServiceMax_Config_Data__c Profacc = new SVMXC__ServiceMax_Config_Data__c(
                                    RecordTypeId =rt5.Id,
                                    SVMXC__Access_Configuration_Profile__c=profData.Id,
                                    SVMXC__Display_Value__c = 'TEST data',
                                    SVMXC__Internal_Value__c = 'Testdata',
                                    SVMXC__Setting_ID__c = SettingDefRecord.Id                                        
                                    );
                                    insert Profacc;
            } 
        }
        
        } catch (Exception e){ // System.debug (e.getMessage());
        }                          
        return SettingDefRecord;
    }
 
}