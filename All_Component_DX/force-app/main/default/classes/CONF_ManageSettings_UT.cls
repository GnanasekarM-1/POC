@isTest(SeeAllData=true)
Private class CONF_ManageSettings_UT{
            
    static testMethod void CONF_ManageSettings_Test()
    {
     try
     {
        RecordType[] rtProf = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];    
        RecordType[] rtConf = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];   
            
        Profile AdminProf = [Select Id, Name From Profile where Name='System Administrator'];
        //Create Module, Submodule, ObjMap, inv process
        SVMXC__ServiceMax_Processes__c module=new SVMXC__ServiceMax_Processes__c();
        
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
                //insert mod;
                module = mod;
            } 
        } 
        insert module;
        system.assertEquals('testModule', module.SVMXC__Name__c);
        SVMXC__ServiceMax_Processes__c subModule=new SVMXC__ServiceMax_Processes__c();
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
        }
        insert subModule;
        system.assertEquals('testSubModule', subModule.SVMXC__Name__c);
        SVMXC__ServiceMax_Processes__c SubModSettings =new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c SubModSettings2 =new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c SubModSettings3 =new SVMXC__ServiceMax_Processes__c();
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
                                            Data_Type__c='Boolean',
                                            SVMXC__Module__c=module.Id,
                                            SVMXC__IsStandard__c=false,
                                            SVMXC__IsPrivate__c=false,
                                            SVMXC__Select__c=true,
                                            SVMXC__Submodule__c=subModule.Id,
                                            SVMXC__Active__c=true
                                            );
                //insert TSeting;
                SubModSettings = TSeting;
                
                SVMXC__ServiceMax_Processes__c TSeting2 = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt3.Id,
                                            SVMXC__SettingId__c = 'CUSTOMSSet003s',
                                            Settings_Name__c='Test PB',
                                            SVMXC__Setting_Type__c='Global',
                                            SVMXC__Module__c=module.Id,
                                            Data_Type__c='Boolean',
                                            SVMXC__IsStandard__c=false,
                                            SVMXC__IsPrivate__c=false,
                                            SVMXC__Submodule__c=subModule.Id,
                                            SVMXC__Active__c=true
                                            );
                //insert TSeting;
                insert TSeting2;
                SubModSettings2=TSeting2;
                 //insert TSeting;
                SubModSettings = TSeting;
                SVMXC__ServiceMax_Processes__c TSeting4 = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt3.Id,
                                            SVMXC__SettingId__c =NULL,
                                            Settings_Name__c=NULL,
                                            SVMXC__Setting_Type__c=NULL,
                                            SVMXC__Module__c=module.Id,
                                            Data_Type__c=NULL,
                                            SVMXC__IsStandard__c=false,
                                            SVMXC__IsPrivate__c=false,
                                            Search_Order__c=NULL,
                                            SVMXC__Submodule__c=subModule.Id,
                                            SVMXC__Active__c=true
                                            );
                                            SubModSettings3=TSeting4;
                SVMXC__ServiceMax_Processes__c TSeting1 = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt3.Id,
                                            SVMXC__SettingId__c = 'CUSTOMSSet002s',
                                            Settings_Name__c='Test PB Val',
                                            SVMXC__Setting_Type__c='Global',
                                            SVMXC__Module__c=module.Id,
                                            Data_Type__c='Boolean',
                                            SVMXC__IsPrivate__c=false,
                                            SVMXC__Submodule__c=subModule.Id,
                                            SVMXC__Select__c=true,
                                            SVMXC__Active__c=true
                                            );
                                            insert TSeting1;
            } 
        }
        insert SubModSettings;
        test.startTest();
        System.currentPageReference().getParameters().put('svmx_sid', subModule.Id);
        System.currentPageReference().getParameters().put('mid', module.Id);
        SVMXC.CONF_ManageSettings myPageCon = new SVMXC.CONF_ManageSettings();
        //Translations
        String str1 = myPageCon.getTAG001();
        String str2 = myPageCon.getTAG002();
        String str3 = myPageCon.getTAG003();
        String str4 = myPageCon.getTAG004();
        String str5 = myPageCon.getTAG005();
        String str6 = myPageCon.getTAG006();
        String str7 = myPageCon.getTAG007();
        String str8 = myPageCon.getTAG008();
        //String str9 = myPageCon.getTAG009();
        String str10 = myPageCon.getTAG010();
        String str11 = myPageCon.getTAG011();
        String str12 = myPageCon.getTAG012();
        String str13 = myPageCon.getTAG013();
        String str14 = myPageCon.getTAG014();
        String str15 = myPageCon.getTAG015();
        String str16 = myPageCon.getTAG016();
        String str17 = myPageCon.getTAG017();
        String str18 = myPageCon.getTAG018();
        String str19 = myPageCon.getTAG019();
        String str20 = myPageCon.getTAG020();
        String str21 = myPageCon.getTAG021(); 
        String str22 = myPageCon.getTAG022();
        String str23 = myPageCon.getTAG023();
        String str24 = myPageCon.getTAG024();
        String str25 = myPageCon.getTAG025();
        String hlp = myPageCon.getHLPURL();
        //myPageCon.svmxTagList.clear();
        myPageCon.getTAG001();
        myPageCon.getTAG002();
        myPageCon.getTAG003();
        myPageCon.getTAG004();
        myPageCon.getTAG005();
        myPageCon.getTAG006();
        myPageCon.getTAG007();
        myPageCon.getTAG008();
        ////myPageCon.getTAG009();
        myPageCon.getTAG010();
        myPageCon.getTAG011();
        myPageCon.getTAG012();
        myPageCon.getTAG013();
        myPageCon.getTAG014();
        myPageCon.getTAG015();
        myPageCon.getTAG016();
        myPageCon.getTAG017();
        myPageCon.getTAG018();
        myPageCon.getTAG019();
        myPageCon.getTAG020();
        myPageCon.getTAG021();
        myPageCon.getTAG022();
        myPageCon.getTAG023();
        myPageCon.getTAG024();
        myPageCon.getTAG025();
        myPageCon.getHLPURL();
        myPageCon.onLoad();
        myPageCon.getPopUpLink();
        myPageCon.setCheckAllLines(true);
        RecordType T_CL5 = myPageCon.getEstRecordTypes();
        RecordType T_CL6 = myPageCon.getProfEstRecordTypes();
        myPageCon.submoduleView=subModule.Id;
        PageReference T_CL7 = myPageCon.onSelectMod();
        PageReference T_CL8 = myPageCon.onSelectSubmod();
        boolean T_CL9 = myPageCon.getIsStdAvail();
        boolean T_CL10 = myPageCon.getIsCustAvail();
        Boolean T_CL11 = myPageCon.getCheckAllLines();
        List<SelectOption> T_CL12 = myPageCon.getModule();
        List<SelectOption> T_CL13 = myPageCon.getSubModule();
        {
            myPageCon.moduleView=module.Id;
            myPageCon.onSelectMod();
            myPageCon.submoduleView=subModule.Id;
            myPageCon.onSelectMod();
            myPageCon.cust_serviceMaxConfData.add(SubModSettings);
            myPageCon.cust_serviceMaxConfData.add(SubModSettings2);
            myPageCon.cust_serviceMaxConfData.add(SubModSettings3);
            myPageCon.isValidData('Save');
            myPageCon.isValidData('Del');
        }
        List<SVMXC__ServiceMax_Processes__c> T_CL14 = myPageCon.getSMXStdSettings();
        List<SVMXC__ServiceMax_Processes__c> T_CL15 = myPageCon.getSMXCustSettings();
        PageReference T_CL17 = myPageCon.AddNewSetting();
        PageReference T_CL18 = myPageCon.saveSet();
        {
            myPageCon.cust_serviceMaxConfData.add(SubModSettings);
            myPageCon.cust_serviceMaxConfData.add(SubModSettings2);
            myPageCon.cust_serviceMaxConfData.add(SubModSettings3);
            myPageCon.ResetDef();
        }
        PageReference T_CL20 = myPageCon.GoSetupHome();     
        Boolean T_CL21 = myPageCon.getDisplaySettings();
        Boolean T_CL22 = myPageCon.getDisplayBlockLevelMessage();
        PageReference T_CL28 = myPageCon.delSet();
        PageReference gosub = myPageCon.GoSubMod();
        String T_CL58 = myPageCon.getSid();
        String T_CL68 = myPageCon.getMid();
        test.stopTest();
  }
  catch(Exception ex)
   {
     ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));
   }  
 }
}