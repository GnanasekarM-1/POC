@isTest(SeeAllData=true)
Private class COMM_Utils_ManageSettings_UT {
    static testMethod void COMM_Utils_ManageSettings_UT_Test()
    {
        try
        {
        //1// Create Module & SubModule
        //2// Create Settings for a SubModule
        //3// Create Object Mapping Def
        //4// Create Inventory Processes Def
        //5// Create Field Mapping Entry for a Object Mapping#3
        //6// Create Inv Process Step for a Inv Process #4
        //7// Create Default conf Profile
        //8// Create Grooup conf Profile 
        //9// Create User conf Profile
        //10// Create Setting Values
            //10.1 use #2 & map to #7 confProfile
            //10.2 use #2 & map to #8 confProfile
            //10.3 use #2 & map to #9 confProfile
        //11// Create config Access Records
            //11.1 use current User & map to #9
            //11.1 use current UserProfile & map to #8
            

        RecordType[] rts = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];    
        RecordType[] rtsConf = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];    
            
            
        //Create Module, Submodule, ObjMap, inv process
        SVMXC__ServiceMax_Processes__c module;
        
        for(RecordType rt : rts) //Loop to take a record type at a time
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
        system.assert(module.RecordTypeId!=null);
        
        SVMXC__ServiceMax_Processes__c subModule;
        for(RecordType rt2 : rts) //Loop to take a record type at a time
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
        system.assert(subModule.RecordTypeId!=null);
        
        SVMXC__ServiceMax_Processes__c subModule2;
        for(RecordType rt2 : rts) //Loop to take a record type at a time
        {
            // Create Sub-Module Record, Link to Module
            if(rt2.Name == 'Submodule')
            {
                SVMXC__ServiceMax_Processes__c subMod2 = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt2.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'testSubModule',
                                            SVMXC__SubmoduleID__c = 'CUSTOMTEST001',
                                            SVMXC__Module__c = module.Id                                            
                                            );
                insert subMod2;
                subModule2 = subMod2;
            } 
        }
        system.assert(subModule2.RecordTypeId!=null);
        
        SVMXC__ServiceMax_Processes__c objMapping;
        for(RecordType rt3 : rts) //Loop to take a record type at a time
        {
            // Create objMap Record, Link to Module
            if(rt3.Name == 'Object Mapping')
            {
                SVMXC__ServiceMax_Processes__c objMap = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt3.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'TEST Mapping',
                                            SVMXC__MapID__c = 'CUSTOMMAP001',
                                            SVMXC__Source_Object_Name__c = 'SVMXC__Installed_Product__c',
                                            SVMXC__Target_Object_Name__c = 'SVMXC__Installed_Product__c',
                                            SVMXC__Target_Record_Type__c = 'Master'                                            
                                            );
                insert objMap;
                objMapping = objMap;
            } 
        }
        system.assert(objMapping.RecordTypeId!=null);
        
        //Create Field Mapping
       SVMXC__ServiceMax_Config_Data__c fldMap;
        for(RecordType rt7 : rtsConf) //Loop to take a record type at a time
        {
            // Create objMap Record, Link to Module
            if(rt7.Name == 'Field Mapping')
            {
                SVMXC__ServiceMax_Config_Data__c fldM = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =rt7.Id,
                                            SVMXC__ACTIVE__C = true,
                                            SVMXC__MAPID__C = objMapping.Id,
                                            SVMXC__SOURCE_FIELD_NAME__C = 'SVMXC__Company__c',
                                            SVMXC__TARGET_FIELD_NAME__C = 'SVMXC__Company__c'
                                            );
                 insert fldM;
                fldMap = fldM;
            } 
        }
        
       //Create INV Process
        SVMXC__ServiceMax_Processes__c invProcess;
        for(RecordType rt4 : rts) //Loop to take a record type at a time
        {
            // Create objMap Record, Link to Module
            if(rt4.Name == 'Inventory Process')
            {
                SVMXC__ServiceMax_Processes__c invP = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt4.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'TEST Inv Process',
                                            SVMXC__ProcessID__c = 'CUSTOMIPRO001'
                                            );
                insert invP;
                invProcess = invP;
            } 
        }
        
        
        //Create Inv Process Steps
        SVMXC__ServiceMax_Config_Data__c invProStep;
        for(RecordType rt8 : rtsConf) //Loop to take a record type at a time
        {
            // Create objMap Record, Link to Module
            if(rt8.Name == 'Inventory Process Step')
            {
                SVMXC__ServiceMax_Config_Data__c invPSt = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =rt8.Id,
                                            SVMXC__ACTIVE__C = true,
                                            SVMXC__INVENTORY_PROCESS__C = invProcess.Id,
                                            SVMXC__OBJECT_NAME__C = 'sObject',
                                            SVMXC__LOCATION_FIELD_NAME__C = 'SVMXC__Location__c',
                                            SVMXC__LOCATION_FIELD_FROM__C= 'Header',
                                            SVMXC__STOCK_HISTORY_HEADER_LOOKUP_FIELD__C = 'SVMXC__HdrLocation__c',
                                            SVMXC__STOCK_HISTORY_LINE_LOOKUP_FIELD__C = 'SVMXC__LineLocation__c',
                                            SVMXC__ACTION__C = 'Increase',
                                            SVMXC__SEQUENCE__C = 1,
                                            SVMXC__LOCATION_TYPE__C = 'Type'
                                            );
                 insert invPSt;
                invProStep = invPSt;
            } 
        }
        
        SVMXC__ServiceMax_Processes__c set1 = new SVMXC__ServiceMax_Processes__c();
        //Create Settings Defination - Standard
         for(RecordType rt : rts) //Loop to take a record type at a time
        {
            // Create Module Record
            if(rt.Name == 'Settings')
            {
                SVMXC__ServiceMax_Processes__c s1 = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'testModule',
                                            SVMXC__SUBMODULE__C = subModule.Id,
                                            SVMXC__SETTINGID__C = 'CUSTOMSET001',
                                            SVMXC__SETTING_TYPE__C = 'Global'
                                            );
                insert s1;
                set1 = s1;
            } 
        }   
       
       SVMXC__ServiceMax_Processes__c set2 = new SVMXC__ServiceMax_Processes__c();
        //Create Settings Defination - Standard
         for(RecordType rt : rts) //Loop to take a record type at a time
        {
            // Create Module Record
            if(rt.Name == 'Settings')
            {
                SVMXC__ServiceMax_Processes__c s2 = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'testModule',
                                            SVMXC__SUBMODULE__C = subModule.Id,
                                            SVMXC__SETTINGID__C = 'CUSTOMSET002',
                                            SVMXC__SETTING_TYPE__C = 'Global'
                                            );
                insert s2;
                set2 = s2;
            } 
        }   
       
       SVMXC__ServiceMax_Processes__c set3 = new SVMXC__ServiceMax_Processes__c();
        //Create Settings Defination - Standard
         for(RecordType rt : rts) //Loop to take a record type at a time
        {
            // Create Module Record
            if(rt.Name == 'Settings')
            {
                SVMXC__ServiceMax_Processes__c s3 = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'testModule',
                                            SVMXC__SUBMODULE__C = subModule.Id,
                                            SVMXC__SETTINGID__C = 'CUSTOMSET003',
                                            SVMXC__SETTING_TYPE__C = 'Global'
                                            );
                insert s3;
                set3 = s3;
            } 
        }   
       
       //Create Default Profile 
       SVMXC__ServiceMax_Config_Data__c confProfile; // -Global
       SVMXC__ServiceMax_Config_Data__c confProfileGrp; // - Group
       SVMXC__ServiceMax_Config_Data__c confProfileUsr; // - User
       
        for(RecordType rt5 : rtsConf) //Loop to take a record type at a time
        {
            // Create objMap Record, Link to Module
            if(rt5.Name == 'Configuration Profile')
            {
                SVMXC__ServiceMax_Config_Data__c cnfP = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =rt5.Id,
                                            SVMXC__ACTIVE__C = false,
                                            SVMXC__ISDEFAULT__C = true,
                                            SVMXC__PROFILE_NAME__C = 'Test Default',
                                            SVMXC__CONFIGURATION_TYPE__C = 'Global'
                                            );
                 //insert cnfP;
                 SVMXC__ServiceMax_Config_Data__c cnfPG = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =rt5.Id,
                                            SVMXC__ACTIVE__C = true,
                                            SVMXC__ISDEFAULT__C = true,
                                            SVMXC__PROFILE_NAME__C = 'Test Group',
                                            SVMXC__CONFIGURATION_TYPE__C = 'Group'
                                            );
                // insert cnfPG;
                 SVMXC__ServiceMax_Config_Data__c cnfPU = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =rt5.Id,
                                            SVMXC__ACTIVE__C = true,
                                            SVMXC__ISDEFAULT__C = true,
                                            SVMXC__PROFILE_NAME__C = 'Test User',
                                            SVMXC__CONFIGURATION_TYPE__C = 'User'
                                            );
                 //insert cnfPU;
                confProfile = cnfP;
                confProfileGrp = cnfPG;
                confProfileUsr = cnfPU;
            } 
        }
       
       
        
        
        
       //Create Setting(s) Value
       SVMXC__ServiceMax_Config_Data__c set1Value;
       SVMXC__ServiceMax_Config_Data__c set2Value;
       SVMXC__ServiceMax_Config_Data__c set3Value;
        for(RecordType rt6 : rtsConf) //Loop to take a record type at a time
        {
            // Create objMap Record, Link to Module
            if(rt6.Name == 'Setting Value')
            {
                SVMXC__ServiceMax_Config_Data__c set1V = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =rt6.Id,
                                            SVMXC__ACTIVE__C = true,
                                            SVMXC__SETTING_CONFIGURATION_PROFILE__C = confProfile.Id,
                                            SVMXC__SETTING_ID__C = set1.Id ,
                                            SVMXC__INTERNAL_VALUE__C = 'True',
                                            SVMXC__DISPLAY_VALUE__C = 'True'
                                            );
                 insert set1V;
        /*        SVMXC__ServiceMax_Config_Data__c set2V = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =rt6.Id,
                                            SVMXC__ACTIVE__C = true,
                                            SVMXC__SETTING_CONFIGURATION_PROFILE__C = confProfile.Id,
                                            SVMXC__SETTING_ID__C = set2.Id ,
                                            SVMXC__INTERNAL_VALUE__C = 'CUSTOMMAP001',
                                            SVMXC__DISPLAY_VALUE__C = 'CUSTOMMAP001'
                                            );
                // insert set2V;
                SVMXC__ServiceMax_Config_Data__c set3V = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =rt6.Id,
                                            SVMXC__ACTIVE__C = true,
                                            SVMXC__SETTING_CONFIGURATION_PROFILE__C = confProfile.Id,
                                            SVMXC__SETTING_ID__C = set3.Id ,
                                            SVMXC__INTERNAL_VALUE__C = 'CUSTOMIPRO001',
                                            SVMXC__DISPLAY_VALUE__C = 'CUSTOMIPRO001'
                                            );*/
                 //insert set3V;
                system.assertNotEquals(set1V.Id,null);
                set1Value = set1V;
                system.assertEquals(set1V.Id,set1Value.Id);
                //set2Value = set2V;
                //set3Value = set3V;
            } 
        }
       //Create Config Access
       // -- Process Test Method --
       
       // test.starttest();                                            

            SVMXC.COMM_Utils_ManageSettings commUtil = new SVMXC.COMM_Utils_ManageSettings();
            
            List<SVMXC__ServiceMax_Config_Data__c> fldMap2 = commUtil.SVMX_getFieldMapping('CUSTOMMAP001'); //use the Test-obj Map created above
            List<SVMXC__ServiceMax_Config_Data__c> invProcessSteps = commUtil.SVMX_getInventoryProcessSteps('CUSTOMIPRO001'); ////use the Test-Inv Process created above
            Map<String, SVMXC__ServiceMax_Processes__c> x =  commUtil.SVMX_getSettingDef('CUSTOMTEST001','CUSTOMSET001');
            Map<String, String> svmxSetList = commUtil.SVMX_getSettingList('CUSTOMTEST001'); //use the Test-subModule created above
            Map<String, String> svmxSetList2 = commUtil.SVMX_getSettingList('CUSTOMTEST001','CUSTOMSET001');
            List<String> settingLst = new List<String>();
            settingLst.add('CUSTOMSET001');
            settingLst.add('CUSTOMSET002');
            Map<String, String> svmxSetList3 = commUtil.SVMX_getSettingList('CUSTOMTEST001',settingLst); 
            Map<String, SVMXC__ServiceMax_Processes__c> xy = commUtil.SVMX_cloneSettingDef(subModule.Id, subModule2.Id, null);
            SVMXC__ServiceMax_Processes__c xyz = commUtil.SVMX_cloneSubModuleSettings(subModule.SVMXC__SubmoduleID__c, subModule2.SVMXC__SubmoduleID__c, null, module.SVMXC__ModuleID__c, module.Id);
            map<string, SVMXC__ServiceMax_Config_Data__c> mapStrCongobj= new map<string, SVMXC__ServiceMax_Config_Data__c>();
            mapStrCongobj.put('True',set1Value);
            commUtil.SVMX_cloneSettingValues(subModule.Id,subModule2.Id,subModule.SVMXC__SubmoduleID__c,subModule2.SVMXC__SubmoduleID__c,mapStrCongobj,null);
            commUtil.SVMX_getSettingObjectList('CUSTOMMAP001');
             commUtil.SVMX_cloneSettingDef(subModule.Id,subModule2.Id,null);
            commUtil.SVMX_cloneSubModuleSettings(subModule.Id,subModule2.SVMXC__SubmoduleID__c,null,'',subModule2.Id); 
            system.assert(commUtil.SVMX_getSettingObjectList('CUSTOMMAP001')!=null);
        
        //test.stoptest();
        }
        catch(exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));
        }
              
    }
    static testMethod void COMM_Utils_ManageSettings_UT_Test2()
    {
        SVMXC.COMM_Utils_ManageSettings commUtil = new SVMXC.COMM_Utils_ManageSettings();
        ////commUtil.SVMX_getGlobalSettingList();
        system.assert(commUtil.SVMX_getSettingObjectList('CUSTOMMAP001')!=null);
        commUtil.SVMX_getGlobalSettingList('GLOB001_GBL001');
        commUtil.SVMX_getGlobalSettingList('GLOB001_GBL001test');
        list<string> lststr = new list<string>();
        lststr.add('GLOB001_GBL001');
        commUtil.SVMX_getGlobalSettingList(lststr);               
        system.assert(lststr.size()>0);
    }
    
    static testMethod void COMM_Utils_ManageSettings_UT_Test3()
    {
        SVMXC.COMM_Utils_ManageSettings commUtil = new SVMXC.COMM_Utils_ManageSettings();
        List<SVMXC__ServiceMax_Processes__c> allSetRecs = new List<SVMXC__ServiceMax_Processes__c>();
        allSetRecs = [SELECT SVMXC__Setting_Unique_ID__c, SVMXC__Values__c, SVMXC__Submodule__r.SVMXC__SubmoduleID__c, SVMXC__Submodule__c, SVMXC__Setting_Type__c, SVMXC__SettingID__c, SVMXC__Search_Order__c, SVMXC__Module__c, SVMXC__IsPrivate__c, SVMXC__Default_Value__c, SVMXC__Data_Type__c, SVMXC__Active__c, Name, Id FROM SVMXC__ServiceMax_Processes__c WHERE (SVMXC__Submodule__c != Null AND SVMXC__Active__c = true AND recordType.Name = 'Settings' AND (SVMXC__Submodule__r.SVMXC__Module__r.SVMXC__ModuleID__c = 'IPAD'))];
        //commUtil.SVMX_GetSettingValueMap(allSetRecs ,true);
    }
    
    // Ramachandra
    static testMethod void COMM_Utils_ManageSettings_UT_Coverage()
    {
        SVMXC.COMM_Utils_ManageSettings commUtil = new SVMXC.COMM_Utils_ManageSettings();
        commUtil.SVMX_getSettingList2('DCON001','SET001');
        List<String> settingIdList = new List<String>();
        settingIdList.add('SET001');
        commUtil.SVMX_getSettingList2('DCON001',settingIdList);
    }
}