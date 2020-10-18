@isTest(SeeAllData=true)
Private class CONF_EditProfile_UT {

    private static SVMXC__ServiceMax_Processes__c mR = new SVMXC__ServiceMax_Processes__c();  
    private static SVMXC__ServiceMax_Config_Data__c lR = new SVMXC__ServiceMax_Config_Data__c();
    private static CONF_EditProfile.wrapper wrap = new CONF_EditProfile.wrapper(mR,lR)  ;
    private static Map<String,Id> recordTypeIdMap = new Map<String,Id>();
    

    static void getRecordTypeIdMap(){
        for(RecordType recordTypeRec : [SELECT Id, Name FROM RecordType WHERE SobjectType IN  ('SVMXC__ServiceMax_Processes__c','SVMXC__ServiceMax_Config_Data__c') AND isActive = true]){
            recordTypeIdMap.put(recordTypeRec.Name, recordTypeRec.Id);
        }
    }

    static testMethod void CONF_EditProfile_Test()
    {
    try
    {
        getRecordTypeIdMap();
        //RecordType[] rtProf = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];    
        //RecordType[] rtConf = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];   
            
        Id AdminProf =  UserInfo.getProfileId(); //[Select Id, Name From Profile where Name='System Administrator'];
        //Create Module, Submodule, ObjMap, inv process
        //SVMXC__ServiceMax_Processes__c module=new SVMXC__ServiceMax_Processes__c();
        
        /*for(RecordType rt : rtProf) //Loop to take a record type at a time
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
                //insert mod;
                module = mod;
            } 
        } */

        SVMXC__ServiceMax_Processes__c module = new SVMXC__ServiceMax_Processes__c(RecordTypeId = recordTypeIdMap.get('Module'),
                                                                                    SVMXC__Active__c = true,
                                                                                    SVMXC__Name__c = 'testModule',
                                                                                    SVMXC__ModuleID__c = 'CUSTOMTEST'                                            
                                                                                    );        
        insert module;

        /*SVMXC__ServiceMax_Processes__c subModule=new SVMXC__ServiceMax_Processes__c();
        for(RecordType rt2 : rtProf) //Loop to take a record type at a time
        {
            // Create Sub-Module Record, Link to Module
            if(rt2.Name == 'Submodule')
            {
                SVMXC__ServiceMax_Processes__c subMod = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt2.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'testSubModule',
                                            SVMXC__SubmoduleID__c = 'CUSTOMTEST001s',
                                            SVMXC__Module__c = module.Id                                            
                                            );
                //insert subMod;
                subModule = subMod;
            } 
        }*/
        
        SVMXC__ServiceMax_Processes__c subModule = new SVMXC__ServiceMax_Processes__c(RecordTypeId = recordTypeIdMap.get('Submodule'),
                                                                                        SVMXC__Active__c = true,
                                                                                        SVMXC__Name__c = 'testSubModule',
                                                                                        SVMXC__SubmoduleID__c = 'CUSTOMTEST001s',
                                                                                        SVMXC__Module__c = module.Id                                            
                                                                                        );

        insert subModule;
        
        /*SVMXC__ServiceMax_Processes__c SubModSettings =new SVMXC__ServiceMax_Processes__c();
        for(RecordType rt3 : rtProf) //Loop to take a record type at a time
        {
            // Create Sub-Module Record, Link to Module
            if(rt3.Name == 'Settings')
            {
                SVMXC__ServiceMax_Processes__c TSeting = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt3.Id,
                                            SVMXC__SettingId__c = 'CUSTOMSSet001s',
                                            Settings_Name__c='Test PB',
                                            SVMXC__Setting_Type__c='Global',
                                            SVMXC__Module__c=module.Id,
                                            SVMXC__Submodule__c=subModule.Id
                                            );
                //insert TSeting;
                SubModSettings = TSeting;

                SVMXC__ServiceMax_Processes__c TSeting1 = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt3.Id,
                                            SVMXC__SettingId__c = 'CUSTOMSSet002s',
                                            Settings_Name__c='Test PB Val',
                                            SVMXC__Setting_Type__c='Global',
                                            SVMXC__Module__c=module.Id,
                                            SVMXC__Submodule__c=subModule.Id
                                            );
                                            insert TSeting1;
            } 
        }*/

        List<SVMXC__ServiceMax_Processes__c> SubModSettingsList = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c SubModSettings = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId = recordTypeIdMap.get('Settings'),
                                            SVMXC__SettingId__c = 'CUSTOMSSet001s',
                                            Settings_Name__c='Test PB',
                                            SVMXC__Setting_Type__c='Global',
                                            SVMXC__Module__c=module.Id,
                                            SVMXC__Submodule__c=subModule.Id
                                            );
        SubModSettingsList.add(SubModSettings);

        SVMXC__ServiceMax_Processes__c SubModSettings1 = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId = recordTypeIdMap.get('Settings'),
                                            SVMXC__SettingId__c = 'CUSTOMSSet002s',
                                            Settings_Name__c='Test PB Val',
                                            SVMXC__Setting_Type__c='Global',
                                            SVMXC__Module__c=module.Id,
                                            SVMXC__Submodule__c=subModule.Id
                                            );
                                            
        
        SubModSettingsList.add(SubModSettings1);
       
        insert SubModSettingsList;

        /*SVMXC__ServiceMax_Config_Data__c profData = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Config_Data__c profData_Grp = new SVMXC__ServiceMax_Config_Data__c();
        for(RecordType rt4 : rtConf) //Loop to take a record type at a time
        {
            // Create objMap Record, Link to Module
            if(rt4.Name == 'Configuration Profile')
            {
                SVMXC__ServiceMax_Config_Data__c prof1 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =rt4.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Profile_Name__c = 'TESTSProf1',
                                            SVMXC__Description__c = 'CUSTOM P1',
                                            SVMXC__Configuration_Type__c='Group',
                                            SVMXC__IsDefault__c = false                                          
                                            );
                //insert prof1;
                
                SVMXC__ServiceMax_Config_Data__c prof2 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =rt4.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Profile_Name__c = 'TESTSProf2',
                                            SVMXC__Description__c = 'CUSTOMM P2',
                                            SVMXC__Configuration_Type__c='Group',
                                            SVMXC__IsDefault__c = false                                          
                                            );
                profData_Grp = prof2;
                profData = prof1;
            } 
        }*/

        List<SVMXC__ServiceMax_Config_Data__c> configRecordList = new  List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c profData = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId = recordTypeIdMap.get('Configuration Profile'),
                                            SVMXC__Active__c = true,
                                            SVMXC__Profile_Name__c = 'TESTSProf1',
                                            SVMXC__Description__c = 'CUSTOM P1',
                                            SVMXC__Configuration_Type__c='Group',
                                            SVMXC__IsDefault__c = false                                          
                                            );
                //insert prof1;
        
        configRecordList.add(profData);                
        SVMXC__ServiceMax_Config_Data__c profData_Grp = new SVMXC__ServiceMax_Config_Data__c(
                                    RecordTypeId = recordTypeIdMap.get('Configuration Profile'),
                                    SVMXC__Active__c = true,
                                    SVMXC__Profile_Name__c = 'TESTSProf2',
                                    SVMXC__Description__c = 'CUSTOMM P2',
                                    SVMXC__Configuration_Type__c='Group',
                                    SVMXC__IsDefault__c = false                                          
                                    );
        configRecordList.add(profData_Grp); 
        insert configRecordList;
        
       /* SVMXC__ServiceMax_Config_Data__c confAcc = new SVMXC__ServiceMax_Config_Data__c();
        for(RecordType rt5 : rtConf) //Loop to take a record type at a time
        {
            if(rt5.Name == 'Configuration Access')
            {
                SVMXC__ServiceMax_Config_Data__c acc1 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId=rt5.Id,SVMXC__Access_Configuration_Profile__c=profData_Grp.Id,SVMXC__Profile__c=AdminProf.Id,SVMXC__Active__c=true                                 
                                            );
                insert acc1;
            } 
        }*/        
        //insert confAcc;

        SVMXC__ServiceMax_Config_Data__c confAcc = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId=recordTypeIdMap.get('Configuration Access'),SVMXC__Access_Configuration_Profile__c=profData_Grp.Id,SVMXC__Profile__c=AdminProf,SVMXC__Active__c=true                                 
                                            );
        insert confAcc;

        /*for(RecordType rt6 : rtConf) //Loop to take a record type at a time
        {
            if(rt6.Name == 'Setting Value')
            {
                SVMXC__ServiceMax_Config_Data__c set1 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =rt6.Id,
                                            SVMXC__Display_Value__c='Test Def 1',
                                            SVMXC__Internal_Value__c = 'Test IV1',
                                            SVMXC__Setting_Configuration_Profile__c=profData.Id,
                                            SVMXC__Setting_ID__c=SubModSettings.id                                       
                                            );
                insert set1;
                SVMXC__ServiceMax_Config_Data__c set2 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =rt6.Id,
                                            SVMXC__Display_Value__c='Test Default val',
                                            SVMXC__Internal_Value__c = 'Test internal value',
                                            SVMXC__Setting_Configuration_Profile__c=profData_Grp.Id,
                                            SVMXC__Setting_ID__c=SubModSettings.id                                         
                                            );
                insert set2;
            } 
        } */

        configRecordList = new  List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c set1 = new SVMXC__ServiceMax_Config_Data__c(
                                    RecordTypeId =recordTypeIdMap.get('Setting Value'),
                                    SVMXC__Display_Value__c='Test Def 1',
                                    SVMXC__Internal_Value__c = 'Test IV1',
                                    SVMXC__Setting_Configuration_Profile__c=profData.Id,
                                    SVMXC__Setting_ID__c=SubModSettings.id                                       
                                    );
        configRecordList.add(set1);
        SVMXC__ServiceMax_Config_Data__c set2 = new SVMXC__ServiceMax_Config_Data__c(
                                    RecordTypeId =recordTypeIdMap.get('Setting Value'),
                                    SVMXC__Display_Value__c='Test Default val',
                                    SVMXC__Internal_Value__c = 'Test internal value',
                                    SVMXC__Setting_Configuration_Profile__c=profData_Grp.Id,
                                    SVMXC__Setting_ID__c=SubModSettings.id                                         
                                    );
        configRecordList.add(set2);

        insert configRecordList;
        

        test.starttest();
        
        System.currentPageReference().getParameters().put('svmx_sid', profData.Id);
        {
        System.currentPageReference().getParameters().put('cl',NULL);
        SVMXC.CONF_EditProfile myPageCon = new SVMXC.CONF_EditProfile();
        system.assertEquals(System.currentPageReference().getParameters().get('svmx_sid'),profData.Id);
        system.assertEquals(System.currentPageReference().getParameters().get('cl'),null);
        
        SVMXC__ServiceMax_Processes__c ms = wrap.WSetting;
        SVMXC__ServiceMax_Config_Data__c la = wrap.WSValue;
        wrap = new SVMXC.CONF_EditProfile.wrapper(mR,lR) ;
        List<CONF_EditProfile.wrapper> TS_CLf11e = myPageCon.getwrapSet();

        {
        myPageCon.Clone=NULL;
        myPageCon.SId=profData_Grp.Id;
        myPageCon.ConfProfType='Global';
       // myPageCon.onLoad();
        myPageCon.Clone='s';
       // myPageCon.onLoad();
        myPageCon.ConfProfType='Group';
        system.assertEquals(myPageCon.ConfProfType,'Group');
        myPageCon.getActiveEditable();
        }
        myPageCon.getAccessMessage();
        
        String TS_CL11e = myPageCon.getClone();
        system.assertNotEquals(TS_CL11e,null);
        String TS_CL1w3 = myPageCon.getPopUpLink();
        boolean TS_CLd33 = myPageCon.getActiveEditable();
        boolean TS_CL12e = myPageCon.getIsDefault();
        String[] s = new String[1];
        myPageCon.setProfile(s);
        myPageCon.setSProfile(s);
        List<String> T_CL1 = myPageCon.getProfile();
        List<String> T_CL2 = myPageCon.getSProfile();
        RecordType T_CL3 = myPageCon.getProfEstRecordTypes();
        SVMXC__ServiceMax_Config_Data__c T_CL4 = myPageCon.getProf_Detail();
        RecordType T_CL5 = myPageCon.getEstRecordTypes();
        {
        myPageCon.moduleView=module.Id;
        PageReference T_CL6 = myPageCon.onSelectMod();
        }
        {
        myPageCon.submoduleView=subModule.id;
        myPageCon.ConfProfType='Global';
        PageReference T_CL7 = myPageCon.onSelectSubmod();
        }
        {
        myPageCon.SId=profData.Id;
        myPageCon.submoduleView=SubModSettings.id;
        myPageCon.ConfProfType='Group';
        myPageCon.onSelectSubmod();
        }
        {
            myPageCon.SId=profData.Id;
            myPageCon.ConfProfType='Group';
            myPageCon.IsDefault=true;
            PageReference T_CL8 = myPageCon.saveProf();
        }
        myPageCon.conf_data.SVMXC__Profile_Name__c='TESTPROFOO7';
        {
        myPageCon.Clone='s';
        myPageCon.saveProf();
        myPageCon.Clone='u';
        myPageCon.saveProf();
        myPageCon.Clone=NULL;
        myPageCon.saveProf();
        }
        PageReference T_CL9 = myPageCon.saveAccessProf();
        {
        myPageCon.conf_data.SVMXC__Profile_Name__c='TESTPROFOOw';
        myPageCon.Clone='s';
        myPageCon.QsaveProf();
        myPageCon.Clone='u';
        myPageCon.QsaveProf();
        myPageCon.Clone=NULL;
        myPageCon.QsaveProf();
        }
        List<SelectOption> T_CL11 = myPageCon.getModule();
        PageReference T_CL12 = myPageCon.GoSetupHome();
        PageReference T_CL13 = myPageCon.cancelProf();
        String T_CL14 = myPageCon.getAvailProf();
        String T_CL15 = myPageCon.getSelectedProf();
        PageReference T_CL16 = myPageCon.onAddProfile();
        PageReference T_CL17 = myPageCon.onRemProfile();
            {
            //myPageCon.profile.add(AdminProf.Id);
            //myPageCon.T1profile.clear();
            //myPageCon.T1profile.add(AdminProf.Id);
            //myPageCon.onAddProfile();
            //myPageCon.Sprofile.add(AdminProf.Id);
            //myPageCon.T2profile.clear();
            //myPageCon.T2profile.add(AdminProf.Id);
            //myPageCon.onRemProfile();
            }
        List<SelectOption> T_CL18 = myPageCon.getSubModule();
        Boolean T_CL19 = myPageCon.getDisplayBlockLevelMessage();
        PageReference T_CL201 = myPageCon.onREsetDef();
        Id T_CL211 = myPageCon.getPageId();
        Boolean T_CL122 = myPageCon.getProfDisplayBlockLevelMessage();
        Boolean T_CL123 = myPageCon.getDisplayProfiles();
        
        PageReference T_CeL7s = myPageCon.CloneSettingValue();
        PageReference T_Cee7r = myPageCon.onRefresh();
        myPageCon.getProfDisplayBlockLevelMessage();
        myPageCon.getDisplayProfiles();
        myPageCon.getheaderDisplayBlockLevelMessage();
        myPageCon.getheaderRecDisplayBlockLevelMessage();
        
       /* List<SVMXC__ServiceMax_Config_Data__c> SMXB;
        List<Profile> PF;
        PF = [Select Id, Name From Profile];
        //SMXB=[Select Id,SVMXC__Profile__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c = 'Configuration Access'];
        List<String> T2 = new List<String>();
        List<SelectOption> SelectedProf = new List<SelectOption>();
        
            for(Integer i = 0; i < SMXB.size();i++){
        for(Integer j = 0; j < PF.size();j++){
            if(SMXB[i].SVMXC__Profile__c==PF[j].Id){
                SelectedProf.add(new SelectOption(PF[j].Id,PF[j].Name));
                T2.add(PF[j].Id);
            }
         }
    }
    
        
    delete SMXB;
    SMXB.clear();*/
    /*for(Integer j = 0; j < PF.size();j++){
         SVMXC__ServiceMax_Config_Data__c newProfLine = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Profile__c=PF[j]);             
          SMXB.add(newProfLine);
    }
    insert SMXB; */
 
        //Translations
         String str11 = myPageCon.getTAG011();
         String str25 = myPageCon.getTAG025();
         String str26 = myPageCon.getTAG026();
       //  String str27 = myPageCon.getTAG027();
         String str28 = myPageCon.getTAG028();
         String str29 = myPageCon.getTAG029();
         String str30 = myPageCon.getTAG030();
         String str31 = myPageCon.getTAG031();
         String str32 = myPageCon.getTAG032();
         String str33 = myPageCon.getTAG033();
         String str34 = myPageCon.getTAG034();
         String str35 = myPageCon.getTAG035();
         String str36 = myPageCon.getTAG036();
         String str37 = myPageCon.getTAG037();
         String str38 = myPageCon.getTAG038();
         String str39 = myPageCon.getTAG039();
         String str40 = myPageCon.getTAG040();
         String str41 = myPageCon.getTAG041();
         String str42 = myPageCon.getTAG042();
         ////String str43 = myPageCon.getTAG043();
         String str44 = myPageCon.getTAG044();
         String str45 = myPageCon.getTAG045();
         String str46 = myPageCon.getTAG046();
         String str47 = myPageCon.getTAG047();
         String str48 = myPageCon.getTAG048();
         String str49 = myPageCon.getTAG049();
         String str50 = myPageCon.getTAG050();
         String str51 = myPageCon.getTAG051();
         String str52 = myPageCon.getTAG052();
         String str53 = myPageCon.getTAG053();
         String str54 = myPageCon.getTAG054();
         ////String str57 = myPageCon.getTAG057();
         String str58 = myPageCon.getTAG058();
        // String str59 = myPageCon.getTAG059();
         myPageCon.getTAG060();
         myPageCon.getTAG061();
         myPageCon.getTAG062();
         myPageCon.getTAG063();
         myPageCon.getTAG064();
         myPageCon.getTAG065();
         myPageCon.getTAG066();
         myPageCon.getTAG067();
         myPageCon.getTAG068();
      
        // myPageCon.svmxTagList.clear();
         
         myPageCon.getTAG011();
         myPageCon.getTAG025();
         myPageCon.getTAG026();
       //  myPageCon.getTAG027();
         myPageCon.getTAG028();
         myPageCon.getTAG029();
         myPageCon.getTAG030();
         myPageCon.getTAG031();
         myPageCon.getTAG032();
         myPageCon.getTAG033();
         myPageCon.getTAG034();
         myPageCon.getTAG035();
         myPageCon.getTAG036();
         myPageCon.getTAG037();
         myPageCon.getTAG038();
         myPageCon.getTAG039();
         myPageCon.getTAG040();
         myPageCon.getTAG041();
         myPageCon.getTAG042();
         ////myPageCon.getTAG043();
         myPageCon.getTAG044();
         myPageCon.getTAG045();
         myPageCon.getTAG046();
         myPageCon.getTAG047();
         myPageCon.getTAG048();
         myPageCon.getTAG049();
         myPageCon.getTAG050();
         myPageCon.getTAG051();
         myPageCon.getTAG052();
         myPageCon.getTAG053();
         myPageCon.getTAG054();
         ////myPageCon.getTAG057();
         myPageCon.getTAG058();
         myPageCon.getTAG060();
         myPageCon.getHLPURL();

        }
/*
        System.currentPageReference().getParameters().put('sid', profData.Id);
        {
        System.currentPageReference().getParameters().put('cl', 's');
        SVMXC.CONF_EditProfile myPageCon = new SVMXC.CONF_EditProfile();
 
        {
        myPageCon.ConfProfType='Global';
        void TS_CL11fd = myPageCon.onLoad();
        }
        
        String TS_CL1w = myPageCon.getClone();
        boolean TS_CL1s = myPageCon.getIsDefault();
 
        List<String> T_CL11 = myPageCon.getProfile();
        List<String> T_CL21 = myPageCon.getSProfile();
        RecordType T_CL31 = myPageCon.getProfEstRecordTypes();
        SVMXC__ServiceMax_Config_Data__c T_CL41 = myPageCon.getProf_Detail();
        RecordType T_CL51 = myPageCon.getEstRecordTypes();
        PageReference T_CL26 = myPageCon.onSelectMod();
        {
        myPageCon.submoduleView=SubModSettings.id;
        myPageCon.ConfProfType='Global';
        PageReference T_CL7 = myPageCon.onSelectSubmod();
        }
        PageReference T_CL81 = myPageCon.saveProf();
        PageReference T_CL91 = myPageCon.saveAccessProf();
        PageReference T_CL101 = myPageCon.QsaveProf();
        List<SelectOption> T_CL111 = myPageCon.getModule();
        PageReference T_CL121 = myPageCon.GoSetupHome();
        PageReference T_CL131 = myPageCon.cancelProf();
        List<SelectOption> T_CL141 = myPageCon.getAvailProf();
        List<SelectOption> T_CL151 = myPageCon.getSelectedProf();
        PageReference T_CL161 = myPageCon.onAddProfile();
        PageReference T_CL171 = myPageCon.onRemProfile();
        List<SelectOption> T_CL181 = myPageCon.getSubModule();
        Boolean T_CL191 = myPageCon.getDisplayBlockLevelMessage();
        PageReference T_CL201 = myPageCon.onREsetDef();
        Id T_CL211 = myPageCon.getPageId();
        Boolean T_CL122 = myPageCon.getProfDisplayBlockLevelMessage();
        Boolean T_CL123 = myPageCon.getDisplayProfiles();
        Boolean T_CL124 = myPageCon.getheaderDisplayBlockLevelMessage();
        Boolean T_CL125 = myPageCon.getheaderRecDisplayBlockLevelMessage();
        }
        */
        test.stoptest();
    }catch(Exception e) {}
    }
 }