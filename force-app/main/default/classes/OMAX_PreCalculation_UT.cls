@isTest 
(SeeAllData = true)
Private with sharing class OMAX_PreCalculation_UT 
{ 
    private static void createOptimizationSettings(){
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
            
            //adding GLOB001 GBL010 Process Setting
            SVMXC__ServiceMax_Processes__c settingProc_GLOB001_GBL010 = new SVMXC__ServiceMax_Processes__c();
            settingProc_GLOB001_GBL010.RecordTypeId = setTypeId;
            settingProc_GLOB001_GBL010.SVMXC__SettingID__c = 'GBL010';
            settingProc_GLOB001_GBL010.SVMXC__Data_Type__c = 'Text';
            settingProc_GLOB001_GBL010.SVMXC__Default_Value__c = 'https://optimax-dev.servicemax.com:7343/optimax/optimization';
            settingProc_GLOB001_GBL010.SVMXC__Setting_Type__c = 'Global';
            settingProc_GLOB001_GBL010.SVMXC__Search_Order__c = 'Global';
            settingProc_GLOB001_GBL010.SVMXC__Active__c = true;
            settingProc_GLOB001_GBL010.SVMXC__IsStandard__c = true;
            settingProc_GLOB001_GBL010.SVMXC__Values__c = 'None,OptiMax,Service Power';
            settingProc_GLOB001_GBL010.SVMXC__Submodule__c = subModProc_GLOB001.id;
            settingProc_GLOB001_GBL010.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
            settingProc_GLOB001_GBL010.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
            Database.upsert(settingProc_GLOB001_GBL010);
            
            //adding GLOB001 GBL010 Setting Value
            SVMXC__ServiceMax_Config_Data__c conf_GLOB001_GBL010 = new SVMXC__ServiceMax_Config_Data__c();
            conf_GLOB001_GBL010.RecordTypeId = setValTypeId;
            conf_GLOB001_GBL010.SVMXC__Setting_Configuration_Profile__c = confProfile_GLOB001_GBL007.id;
            conf_GLOB001_GBL010.SVMXC__Display_Value__c = 'https://optimax-dev.servicemax.com:7343/optimax/optimization';
            //SVMXC__Internal_Value__c
            conf_GLOB001_GBL010.SVMXC__Internal_Value__c = 'https://optimax-dev.servicemax.com:7343/optimax/optimization';
            conf_GLOB001_GBL010.SVMXC__Setting_ID__c = settingProc_GLOB001_GBL010.id;
            conf_GLOB001_GBL010.SVMXC__Active__c = true;
            conf_GLOB001_GBL010.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
            Database.upsert(conf_GLOB001_GBL010);
            
            
            //adding OptiMax Process Module
            SVMXC__ServiceMax_Processes__c modProc_OMAX = new SVMXC__ServiceMax_Processes__c();
            modProc_OMAX.RecordTypeId = modTypeId;
            modProc_OMAX.SVMXC__ModuleID__c = 'DCON';
            modProc_OMAX.SVMXC__Name__c = 'OptiMax';
            modProc_OMAX.SVMXC__IsStandard__c = true;
            modProc_OMAX.SVMXC__Description__c = 'TEST MODULE DESCRIPTION';
            modProc_OMAX.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
            Database.upsert(modProc_OMAX);
    
            //adding DCON004 Process SubModule
            SVMXC__ServiceMax_Processes__c subModProc_DCON004 = new SVMXC__ServiceMax_Processes__c();
            subModProc_DCON004.RecordTypeId = subModTypeId;
            subModProc_DCON004.SVMXC__SubmoduleID__c = 'DCON004';
            subModProc_DCON004.SVMXC__Name__c = 'Manage OptiMax Settings';
            subModProc_DCON004.SVMXC__IsStandard__c = true;
            subModProc_DCON004.SVMXC__Module__c = modProc_OMAX.id;
            subModProc_DCON004.SVMXC__Description__c = 'TEST SUBMODULE DESCRIPTION';
            subModProc_DCON004.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
            Database.upsert(subModProc_DCON004);
           
            //adding DCON004 SET012 Process Setting
            SVMXC__ServiceMax_Processes__c settingProc_DCON004_SET012 = new SVMXC__ServiceMax_Processes__c();
            settingProc_DCON004_SET012.RecordTypeId = setTypeId;
            settingProc_DCON004_SET012.SVMXC__SettingID__c = 'SET012';
            settingProc_DCON004_SET012.SVMXC__Data_Type__c = 'Integer';
            settingProc_DCON004_SET012.SVMXC__Default_Value__c = '7';
            settingProc_DCON004_SET012.SVMXC__Setting_Type__c = 'Global';
            settingProc_DCON004_SET012.SVMXC__Search_Order__c = 'Global';
            settingProc_DCON004_SET012.SVMXC__Active__c = true;
            settingProc_DCON004_SET012.SVMXC__IsStandard__c = false;
            settingProc_DCON004_SET012.SVMXC__Values__c = '1,2,7';
            settingProc_DCON004_SET012.SVMXC__Submodule__c = subModProc_DCON004.id;
            settingProc_DCON004_SET012.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
            settingProc_DCON004_SET012.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
            Database.upsert(settingProc_DCON004_SET012);
           
            //associating DCON004 SET012 Setting Value to a Global profile defined above
            SVMXC__ServiceMax_Config_Data__c conf_DCON004_SET012 = new SVMXC__ServiceMax_Config_Data__c();
            conf_DCON004_SET012.RecordTypeId = setValTypeId;
            conf_DCON004_SET012.SVMXC__Setting_Configuration_Profile__c = confProfile_GLOB001_GBL007.id;
            conf_DCON004_SET012.SVMXC__Display_Value__c = '7';
            conf_DCON004_SET012.SVMXC__Internal_Value__c = '7';
            conf_DCON004_SET012.SVMXC__Setting_ID__c = settingProc_DCON004_SET012.id;
            conf_DCON004_SET012.SVMXC__Active__c = true; //
            conf_DCON004_SET012.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
            Database.upsert(conf_DCON004_SET012);       
            
            System.debug('createOptimizationSettingsMethod');
    }
    static testMethod void OMAX_PreCalculation_UT_Test()
    {
        String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               DispatchProRecordTypeId = rt.ID;
            else if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               ExpressionRTypeId = rt.ID;
            else if(rt.Name == 'SVMX Rule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                RuleRecordTypeId = rt.id;
            else if(rt.Name == 'Field Mapping' &&  rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                FldMapRecordTypeId = rt.id;
             else if(rt.Name == 'Coverage' &&  rt.SobjectType == 'SVMXC__Territory_Coverage__c')
                TCRT = rt.id;
        }
        
        list<BusinessHours> lBH = [ select WednesdayStartTime, timeZoneSidKey, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];
        
        list<Account> AccList = new list<Account>();
        Account a = new Account(Name = 'test');        
        a.SVMXC__Access_Hours__c = lBH[0].Id;
        AccList.add(a);
        insert AccList;
        
        Product2 prod = new Product2(Name = 'prodPR',ProductCode='prod',SVMXC__Inherit_Parent_Warranty__c =True);
        insert prod;
        
        list<SVMXC__Installed_Product__c> LstComponent = new list<SVMXC__Installed_Product__c>();
        SVMXC__Installed_Product__c IBObject = new SVMXC__Installed_Product__c();
        IBObject.Name = 'Test IB1';
        IBObject.SVMXC__Status__c = 'Installed';
        IBObject.SVMXC__Product__c = prod.Id;
        IBObject.SVMXC__Date_Installed__c = System.Today();
        IBObject.SVMXC__Company__c = a.Id;
        IBObject.SVMXC__Access_Hours__c = lBH[0].id;
        LstComponent.add(IBObject);
        insert LstComponent;
        
        List<Case> LstCase = new List<Case>();
        Case nCase = new Case();
        nCase.Origin='Web';
        nCase.Status = 'New';
        nCase.Priority='Medium';        
        nCase.SVMXC__Preferred_Start_Time__c = system.now();
        nCase.SVMXC__Preferred_Start_Time__c = system.now()+10;
        LstCase.add(nCase);
        insert LstCase;
        
        SVMXC__Service_Level__c SLA = new SVMXC__Service_Level__c();
        SLA.SVMXC__Active__c=true;
        SLA.Name='SLATESTDEMO';
        SLA.SVMXC__Business_Hours__c = lBH[0].id;
        insert SLA;
        
        //Create the Territory....
        list<SVMXC__Territory__c> Territorylst = new List<SVMXC__Territory__c>();
        SVMXC__Territory__c Territory1 = new SVMXC__Territory__c();
        Territory1.name = 'India';
        Territory1.SVMXC__Territory_s_Business_Hours__c = lBH[0].id;
        Territory1.SVMXC__Break_Hours__c = lBH[0].id;
        Territory1.SVMXC__Average_Driving_Time__c = 90;
        insert Territory1;
        
        SVMXC__Territory__c Territory2 = new SVMXC__Territory__c();
        Territory2.name = 'Bangalore';
        Territory2.SVMXC__Territory_s_Business_Hours__c = lBH[0].id;
        Territory2.SVMXC__Break_Hours__c = lBH[0].id;
        Territory2.SVMXC__Average_Driving_Time__c = 90;
        insert Territory2;
        
        //Create Territory Coverage 
        list<SVMXC__Territory_Coverage__c> TCList = new list<SVMXC__Territory_Coverage__c>();
        SVMXC__Territory_Coverage__c TC = new SVMXC__Territory_Coverage__c();
        TC.RecordTypeId = TCRT;
        TC.SVMXC__Territory__c = Territory1.id;
        TC.SVMXC__Value__c = 'Bangalore';
        TC.SVMXC__Type__c = 'City';
        TCList.add(TC);
        
        SVMXC__Territory_Coverage__c TC1 = new SVMXC__Territory_Coverage__c();
        TC1.RecordTypeId = TCRT;
        TC1.SVMXC__Territory__c = Territory1.id;
        TC1.SVMXC__Value__c = 'amar';
        TC1.SVMXC__Type__c = 'City';
        TCList.add(TC1);
        insert TCList;
        
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'Team1';
        team.SVMXC__Active__c = true;
        team.SVMXC__Email__c ='test@test.com';
        insert team;
       
        list<SVMXC__Service_Group_Members__c> TechList = new list<SVMXC__Service_Group_Members__c>();
        SVMXC__Service_Group_Members__c Tech = new SVMXC__Service_Group_Members__c();
        Tech.Name = 'Tech';
        Tech.SVMXC__Active__c = true;
        Tech.SVMXC__Service_Group__c = team.Id;
        Tech.SVMXC__Enable_Scheduling__c = true;
        Tech.SVMXC__Average_Drive_Time__c=60;
        Tech.SVMXC__Service_Territory__c = Territory1.id;
        TechList.add(Tech);
        
        SVMXC__Service_Group_Members__c Tech1 = new SVMXC__Service_Group_Members__c();
        Tech1.Name = 'Tech1';
        Tech1.SVMXC__Active__c = true;
        Tech1.SVMXC__Service_Group__c = team.Id;
        Tech1.SVMXC__Working_Hours__c = lBH[0].Id;
        Tech1.SVMXC__Enable_Scheduling__c = false;
        Tech1.SVMXC__Salesforce_User__c = Userinfo.getUserId();
        Tech1.SVMXC__Average_Drive_Time__c=60;
        Tech1.SVMXC__Service_Territory__c = Territory2.id;
        TechList.add(Tech1);
        insert TechList;
        
        Set<String> techIDs = new Set<String>();
        techIDs.add(Tech.Id);
        techIDs.add(Tech1.Id);
        
        //update tech in IB
        IBObject.SVMXC__Preferred_Technician__c = Tech.id;
        upsert IBObject;

        createOptimizationSettings();

        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        list<string> lstSubModules = new list<string>{'GLOB001','OMAX003','SLAT003','PREV004','IPRD009','EVER007','IPRD003','DCON002','DCON003','DCON004','WORD023', 'IPAD018'};
        map<string, Map<String, String>> AllsvmxSettingList = new map<string, Map<String, String>>();
        if(SVMX_Constants.AllsvmxSettingList == NULL || SVMX_Constants.AllsvmxSettingList.size() == 0)
        {
            SVMX_Constants.AllsvmxSettingList = commSettings.SVMX_getSettingList(lstSubModules);
        }
        AllsvmxSettingList = SVMX_Constants.AllsvmxSettingList;
        
        //list<string> lstSubModules = new list<string>{'GLOB001','OMAX003'};
        //map<string, Map<String, String>> AllsvmxSettingList = commSettings.SVMX_getSettingList(lstSubModules);
        Map<String, String> svmxSettingListOMAX003 = AllsvmxSettingList.get('OMAX003');
        svmxSettingListOMAX003.putAll(AllsvmxSettingList.get('GLOB001'));
        svmxSettingListOMAX003.put('GBL007','True');
        svmxSettingListOMAX003.put('GBL022','None,OptiMax,Service Power');
        svmxSettingListOMAX003.put('SET011', '10');
        svmxSettingListOMAX003.put('SET012', '60');
        svmxSettingListOMAX003.put('SET013', 'False');
        svmxSettingListOMAX003.put('SET014', '60');
        svmxSettingListOMAX003.put('SET049', 'true');
        svmxSettingListOMAX003.put('SET055', 'true');
        svmxSettingListOMAX003.put('SET056', 'true');
        
        SVMXC.OMAX_PreCalculation oPreCalculation1 = new SVMXC.OMAX_PreCalculation();        
        
        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        svmxprocess.SVMXC__Name__c = 'Optimized Batch DisPatch Pro';
        svmxprocess.RecordTypeId = DispatchProRecordTypeId;
        svmxprocess.SVMXC__Dispatch_Process_Status__c='Complete';
        svmxprocess.SVMXC__Dispatch_Method__c='Optimized Batch';
        svmxprocess.SVMXC__Start_Date__c = date.Today();
        svmxprocess.SVMXC__End_Date__c= date.Today()+1;
        svmxprocess.SVMXC__Schedule_Event__c = true;
        svmxprocess.SVMXC__Assign_Work_Order_To__c = 'Technician';
        insert svmxprocess;

        SVMXC__ServiceMax_Processes__c svmxprocess1 = new SVMXC__ServiceMax_Processes__c();
        svmxprocess1.SVMXC__Name__c = 'Immediate DisPatch Pro';
        svmxprocess1.RecordTypeId = DispatchProRecordTypeId;
        svmxprocess1.SVMXC__Dispatch_Method__c='Immediate';
        svmxprocess1.SVMXC__Dispatch_Process_Status__c='Complete';
        svmxprocess1.SVMXC__Start_Date__c = date.Today();
        svmxprocess1.SVMXC__End_Date__c= date.Today()+1;
        svmxprocess1.SVMXC__Schedule_Event__c = true;
        insert svmxprocess1;
        
        SVMXC__ServiceMax_Processes__c  TMatchRule = new SVMXC__ServiceMax_Processes__c();
        TMatchRule.RecordTypeId = RuleRecordTypeId;
        TMatchRule.SVMXC__Rule_Type__c = 'Work Order Territory';
        TMatchRule.SVMXC__Name__c = 'Territory Match Rule';
        insert TMatchRule;
        
        SVMXC__ServiceMax_Processes__c  TRule1 = new SVMXC__ServiceMax_Processes__c();
        TRule1.RecordTypeId = RuleRecordTypeId;
        TRule1.SVMXC__Rule_Type__c = 'Territory Access';
        TRule1.SVMXC__Name__c = 'Territory Access Rule 1';
        TRule1.SVMXC__Process__c = svmxprocess.id; 
        TRule1.SVMXC__Territory__c = Territory1.id;
        insert TRule1;
        
        SVMXC__ServiceMax_Processes__c ARule = new SVMXC__ServiceMax_Processes__c();
        ARule.SVMXC__Name__c = 'ARule 1';
        ARule.RecordTypeId = RuleRecordTypeId;
        ARule.SVMXC__Rule_Type__c = 'Simple Assignment'; 
        ARule.SVMXC__Process__c = svmxprocess1.id;
        insert ARule;
        
        SVMXC__ServiceMax_Processes__c  PRule1 = new SVMXC__ServiceMax_Processes__c();
        PRule1.RecordTypeId = RuleRecordTypeId;
        PRule1.SVMXC__Name__c = 'PriorityRule1';
        PRule1.SVMXC__Rule_Type__c = 'Priortization';
        PRule1.SVMXC__Process__c = svmxprocess.id; 
        PRule1.SVMXC__Sequence__c = 2;
        insert PRule1;
        
        SVMXC__ServiceMax_Processes__c MTTSRule = new SVMXC__ServiceMax_Processes__c();
        MTTSRule.SVMXC__Name__c = 'MTTS Rule';
        MTTSRule.SVMXC__Description__c='MTTS Rule';
        MTTSRule.SVMXC__Rule_Type__c = 'MTTS';
        MTTSRule.RecordTypeId = RuleRecordTypeId;
        MTTSRule.SVMXC__MTTS_Minutes__c = 60;
        MTTSRule.SVMXC__Sequence__c = 1;
        insert MTTSRule;
        
        List<SVMXC__ServiceMax_Config_Data__c> configLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c conf3 = new SVMXC__ServiceMax_Config_Data__c();
        conf3.RecordTypeId =FldMapRecordTypeId;
        conf3.SVMXC__Expression_Rule__c = TMatchRule.Id;
        conf3.SVMXC__Active__c = true;
        conf3.SVMXC__Target_Field_Name__c = 'SVMXC__City__c';                                         
        conf3.SVMXC__Source_Field_Name__c = 'City';   
        configLst.add(conf3);                                                                  
        
        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c='asdfgg';
        oConf.SVMXC__Operator__c='eq';
        oConf.RecordTypeId = ExpressionRTypeId;
        oConf.SVMXC__Sequence__c=1;
        oConf.SVMXC__Expression_Rule__c = svmxprocess.id;
        configLst.add(oConf);
        
        SVMXC__ServiceMax_Config_Data__c oConf1 = new SVMXC__ServiceMax_Config_Data__c();
        oConf1.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf1.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
        oConf1.SVMXC__Display_Type__c = 'STRING';
        oConf1.SVMXC__Operand__c='asdfgg';
        oConf1.SVMXC__Operator__c='eq';
        oConf1.RecordTypeId = ExpressionRTypeId;
        oConf1.SVMXC__Sequence__c=1;
        oConf1.SVMXC__Expression_Rule__c = svmxprocess1.id;
        configLst.add(oConf1);
       
        SVMXC__ServiceMax_Config_Data__c aoConf1 = new SVMXC__ServiceMax_Config_Data__c();
        aoConf1.SVMXC__Expression_Type__c = 'DISP_Simple_Assignment';
        aoConf1.SVMXC__Field_Name__c='SVMXC__Zip__c';
        aoConf1.SVMXC__Display_Type__c = 'STRING';
        aoConf1.SVMXC__Operand__c='11111';
        aoConf1.SVMXC__Operator__c='eq';
        aoConf1.RecordTypeId = ExpressionRTypeId;
        aoConf1.SVMXC__Sequence__c=1;
        aoConf1.SVMXC__Expression_Rule__c = ARule.id;
        configLst.add(aoConf1);
        
        SVMXC__ServiceMax_Config_Data__c conf8 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = MTTSRule.id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__City__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'amar',
                                            SVMXC__Expression_Type__c = 'WORD_MTTS',
                                            SVMXC__Sequence__c = 1.0,
                                            SVMXC__Display_Type__c ='STRING'   
                                            );
        configLst.add(conf8);
        
        SVMXC__ServiceMax_Config_Data__c conf4 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = PRule1.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__Billing_Type__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'Contract',
                                            SVMXC__Sequence__c = 1.0,
                                            SVMXC__Expression_Type__c = 'DISP_Priortization'                                            
                                            );
        configLst.add(conf4);
        
        SVMXC__ServiceMax_Config_Data__c conf2 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = TMatchRule.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__City__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'amar',
                                            SVMXC__Expression_Type__c = 'WORD_Territory',
                                            SVMXC__Sequence__c = 1.0000,
                                            SVMXC__Display_Type__c ='STRING'                                       
                                            );
        configLst.add(conf2);   
        insert configLst;

        //list<SVMXC__Service_Order__c> lstWO = new list<SVMXC__Service_Order__c>{new SVMXC__Service_Order__c(), new SVMXC__Service_Order__c()};
        //insert lstWO; 
        
        
        list<SVMXC__Service_Order__c> lstWO1 = new list<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c nWO1 = new SVMXC__Service_Order__c();
        nWO1.SVMXC__Zip__c = '11111';
        nWO1.SVMXC__Company__c=a.Id;              
        nWO1.SVMXC__Order_Status__c='asdfgg';
        nWO1.SVMXC__Priority__c='Low';
        nWO1.SVMXC__Order_Type__c='Field Service';
        nWO1.SVMXC__Purpose_of_Visit__c='Repair';
        nWO1.SVMXC__SLA_Terms__c=SLA.id;
        nWO1.SVMXC__Billing_Type__c = 'Contract';
        nWO1.SVMXC__City__c = 'amar';
        nWO1.SVMXC__Group_Member__c = Tech.id;
        nWO1.SVMXC__Scheduled_Date_Time__c = datetime.now();
        nWO1.SVMXC__Dispatch_Process__c =  svmxprocess1.id;
        nWO1.SVMXC__OptiMax_Error_Occurred__c = false;
        nWO1.SVMXC__OptiMax_Status__c = 'Not Completed';
        nWO1.SVMXC__Locked_By_DC__c = false;
        nWO1.SVMXC__Service_Duration__c = 60;
        nWO1.Driving_Time__c = 60;
        nWO1.SVMXC__Component__c = IBObject.Id;
        lstWO1.add(nWO1);
        
        SVMXC__Service_Order__c nWO2 = new SVMXC__Service_Order__c();
        nWO2.SVMXC__Zip__c = '11111';
        nWO2.SVMXC__Company__c=a.Id;              
        nWO2.SVMXC__Order_Status__c='asdfgg';
        nWO2.SVMXC__Billing_Type__c = 'Contract';
        nWO2.SVMXC__Priority__c='Low';
        nWO2.SVMXC__Order_Type__c='Field Service';
        nWO2.SVMXC__Purpose_of_Visit__c='Repair';
        nWO2.SVMXC__SLA_Terms__c=SLA.id;
        nWO2.SVMXC__City__c = 'amar';
        nWO2.SVMXC__State__c = 'Karnataka';
        nWO2.SVMXC__Group_Member__c = Tech1.id;
        nWO2.SVMXC__Scheduled_Date_Time__c = datetime.now();
        nWO2.SVMXC__Dispatch_Process__c =  svmxprocess1.id;
        nWO2.SVMXC__OptiMax_Error_Occurred__c = false;
        nWO2.SVMXC__OptiMax_Status__c = 'Not Completed';
        nWO2.SVMXC__Locked_By_DC__c = false;
        nWO2.SVMXC__Service_Duration__c = 60;
        nWO2.Driving_Time__c = 60;
        nWO2.SVMXC__Component__c = IBObject.Id;
        lstWO1.add(nWO2);
        insert lstWO1;
                
        
        list<SVMXC__Service_Order__c> lstWO = new list<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c oldWO = new SVMXC__Service_Order__c();
        oldWO.SVMXC__Zip__c = '12131';
        oldWO.SVMXC__City__c = 'amarOld';
        lstWO.add(oldWO);
        insert lstWO;
        
        //createOptimizationSettings('OptiMax,ServicePower', 'True');
        
        SVMXC.OMAX_PreCalculation oPreCalculation = new SVMXC.OMAX_PreCalculation(svmxSettingListOMAX003,AccList,LstCase,LstComponent); 
        
        OMAX_PreCalculation.mapWorkOrder = new map<integer, SVMXC__Service_Order__c>();
        OMAX_PreCalculation.mapWorkOrder.put(1, nWO1);
        OMAX_PreCalculation.mapWorkOrder.put(2, nWO2);
        
        oPreCalculation.doTerritoryMatchRule();
        oPreCalculation.DoProcessTechnicians(techIDs, svmxSettingListOMAX003);
        oPreCalculation.CreateEvents(lstWO1,lstWO);
        
        lstWO1.get(0).SVMXC__OptiMax_Error_Occurred__c = lstWO1.get(1).SVMXC__OptiMax_Error_Occurred__c = true;
        
        svmxprocess.SVMXC__Assign_To_Technician__c = tech.id;
        oPreCalculation.UpdateWorkOrderForSimpleDispatch(0, lstWO.get(0) , svmxprocess);    
        svmxprocess.SVMXC__Assign_To_Technician__c = tech1.id;
        oPreCalculation.UpdateWorkOrderForSimpleDispatch(1, lstWO.get(0) , svmxprocess);
        
        try{
            oPreCalculation.DoPrecalculation(lstWO1);
            oPreCalculation.DoPrecalculation(lstWO1, lstWO1);
        }
        catch(Exception ex){}
        
        svmxprocess.SVMXC__Assign_Work_Order_To__c = 'Dispatcher';
        oPreCalculation.UpdateWorkOrderForSimpleDispatch(0, lstWO.get(0) , svmxprocess);        
        svmxprocess.SVMXC__Assign_Work_Order_To__c = 'Queue';
        oPreCalculation.UpdateWorkOrderForSimpleDispatch(0, lstWO.get(0) , svmxprocess);        
        svmxprocess.SVMXC__Assign_Work_Order_To__c = 'Extra';
        oPreCalculation.UpdateWorkOrderForSimpleDispatch(0, lstWO.get(0) , svmxprocess);
        
        oPreCalculation.getINumberofDays();
        oPreCalculation.getAvgDrivTimeinMin();
        oPreCalculation.getConsiderSameDay();
        oPreCalculation.getILeadTime();
        oPreCalculation.getEvntSubject();
        
        //oPreCalculation.getWorkOrdersForSkillCompute(lstWO1);

    }
    
    static testMethod void OMAX_PreCalculation_NewUT_Test()
    {
        String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               DispatchProRecordTypeId = rt.ID;
            else if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               ExpressionRTypeId = rt.ID;
            else if(rt.Name == 'SVMX Rule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                RuleRecordTypeId = rt.id;
            else if(rt.Name == 'Field Mapping' &&  rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                FldMapRecordTypeId = rt.id;
             else if(rt.Name == 'Coverage' &&  rt.SobjectType == 'SVMXC__Territory_Coverage__c')
                TCRT = rt.id;
        }
        
        list<BusinessHours> lBH = [ select WednesdayStartTime, timeZoneSidKey, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where IsActive = true limit 9];
        
        list<Account> AccList = new list<Account>();
        Account a = new Account(Name = 'test');        
        a.SVMXC__Access_Hours__c = lBH[0].Id;
        AccList.add(a);
        insert AccList;
        
        Product2 prod = new Product2(Name = 'prodPR',ProductCode='prod',SVMXC__Inherit_Parent_Warranty__c =True);
        insert prod;
        
        list<SVMXC__Installed_Product__c> LstComponent = new list<SVMXC__Installed_Product__c>();
        SVMXC__Installed_Product__c IBObject = new SVMXC__Installed_Product__c();
        IBObject.Name = 'Test IB1';
        IBObject.SVMXC__Status__c = 'Installed';
        IBObject.SVMXC__Product__c = prod.Id;
        IBObject.SVMXC__Date_Installed__c = System.Today();
        IBObject.SVMXC__Company__c = a.Id;
        IBObject.SVMXC__Access_Hours__c = lBH[0].id;
        LstComponent.add(IBObject);
        insert LstComponent;
        
        List<Case> LstCase = new List<Case>();
        Case nCase = new Case();
        nCase.Origin='Web';
        nCase.Status = 'New';
        nCase.Priority='Medium';        
        nCase.SVMXC__Preferred_Start_Time__c = system.now();
        nCase.SVMXC__Preferred_Start_Time__c = system.now()+10;
        LstCase.add(nCase);
        insert LstCase;
        
        SVMXC__Service_Level__c SLA = new SVMXC__Service_Level__c();
        SLA.SVMXC__Active__c=true;
        SLA.Name='SLATESTDEMO';
        SLA.SVMXC__Business_Hours__c = lBH[1].id;
        insert SLA;
        
        //Create the Territory....
        list<SVMXC__Territory__c> Territorylst = new List<SVMXC__Territory__c>();
        SVMXC__Territory__c Territory1 = new SVMXC__Territory__c();
        Territory1.name = 'India';
        Territory1.SVMXC__Territory_s_Business_Hours__c = lBH[1].id;
        Territory1.SVMXC__Break_Hours__c = lBH[1].id;
        Territory1.SVMXC__Average_Driving_Time__c = 90;
        insert Territory1;
        
        SVMXC__Territory__c Territory2 = new SVMXC__Territory__c();
        Territory2.name = 'Bangalore';
        Territory2.SVMXC__Territory_s_Business_Hours__c = lBH[2].id;
        Territory2.SVMXC__Break_Hours__c = lBH[2].id;
        Territory2.SVMXC__Average_Driving_Time__c = 90;
        insert Territory2;
        
        //Create Territory Coverage 
        list<SVMXC__Territory_Coverage__c> TCList = new list<SVMXC__Territory_Coverage__c>();
        SVMXC__Territory_Coverage__c TC = new SVMXC__Territory_Coverage__c();
        TC.RecordTypeId = TCRT;
        TC.SVMXC__Territory__c = Territory1.id;
        TC.SVMXC__Value__c = 'Bangalore';
        TC.SVMXC__Type__c = 'City';
        TCList.add(TC);
        
        SVMXC__Territory_Coverage__c TC1 = new SVMXC__Territory_Coverage__c();
        TC1.RecordTypeId = TCRT;
        TC1.SVMXC__Territory__c = Territory1.id;
        TC1.SVMXC__Value__c = 'amar';
        TC1.SVMXC__Type__c = 'City';
        TCList.add(TC1);
        insert TCList;
        
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'Team1';
        team.SVMXC__Active__c = true;
        team.SVMXC__Email__c ='test@test.com';
        insert team;
       
        list<SVMXC__Service_Group_Members__c> TechList = new list<SVMXC__Service_Group_Members__c>();
        SVMXC__Service_Group_Members__c Tech = new SVMXC__Service_Group_Members__c();
        Tech.Name = 'Tech';
        Tech.SVMXC__Active__c = true;
        Tech.SVMXC__Service_Group__c = team.Id;
        Tech.SVMXC__Enable_Scheduling__c = true;
        Tech.SVMXC__Average_Drive_Time__c=60;
        Tech.SVMXC__Service_Territory__c = Territory1.id;
        TechList.add(Tech);
        
        SVMXC__Service_Group_Members__c Tech1 = new SVMXC__Service_Group_Members__c();
        Tech1.Name = 'Tech1';
        Tech1.SVMXC__Active__c = true;
        Tech1.SVMXC__Service_Group__c = team.Id;
        Tech1.SVMXC__Working_Hours__c = lBH[1].Id;
        Tech1.SVMXC__Enable_Scheduling__c = false;
        Tech1.SVMXC__Salesforce_User__c = Userinfo.getUserId();
        Tech1.SVMXC__Average_Drive_Time__c=60;
        Tech1.SVMXC__Service_Territory__c = Territory2.id;
        TechList.add(Tech1);
        insert TechList;
        
        Set<String> techIDs = new Set<String>();
        techIDs.add(Tech.Id);
        techIDs.add(Tech1.Id);
        
        //update tech in IB
        IBObject.SVMXC__Preferred_Technician__c = Tech.id;
        upsert IBObject;

        createOptimizationSettings();

        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        //list<string> lstSubModules = new list<string>{'GLOB001','OMAX003','SLAT003','PREV004','IPRD009','EVER007','IPRD003','DCON002','DCON003','DCON004','WORD023', 'IPAD018'};
        list<String> lstSubModules = new List<String>{'GLOB001','MOBN001',
                                                            'OMAX001','OMAX003','OMAX004',
                                                            'DCON002','DCON003','DCON004','DCON005',
                                                            'SORG001','SLAT003','PREV004','EVER007',
                                                            'WORD023', 'WORD022','WORD012',
                                                            'IPAD018','IPRD003','IPRD009','SFA002'};
        map<string, Map<String, String>> AllsvmxSettingList = new map<string, Map<String, String>>();
        if(SVMX_Constants.AllsvmxSettingList == NULL || SVMX_Constants.AllsvmxSettingList.size() == 0)
        {
            SVMX_Constants.AllsvmxSettingList = commSettings.SVMX_getSettingList(lstSubModules);
        }
        AllsvmxSettingList = SVMX_Constants.AllsvmxSettingList;
        
        
        //list<string> lstSubModules = new list<string>{'GLOB001','OMAX003'};
        //map<string, Map<String, String>> AllsvmxSettingList = commSettings.SVMX_getSettingList(lstSubModules);
        Map<String, String> svmxSettingListOMAX003 = AllsvmxSettingList.get('OMAX003');
        svmxSettingListOMAX003.putAll(AllsvmxSettingList.get('GLOB001'));
        svmxSettingListOMAX003.put('GBL007','True');
        svmxSettingListOMAX003.put('GBL022','None,OptiMax,Service Power');
        svmxSettingListOMAX003.put('SET011', '10');
        svmxSettingListOMAX003.put('SET012', '60');
        svmxSettingListOMAX003.put('SET013', 'False');
        svmxSettingListOMAX003.put('SET014', '60');
        svmxSettingListOMAX003.put('SET049', 'true');
        svmxSettingListOMAX003.put('SET055', 'true');
        svmxSettingListOMAX003.put('SET056', 'true');
        
        //set GBL007 true and licence
        AllsvmxSettingList.put('GLOB001',svmxSettingListOMAX003);
        
        SVMXC.OMAX_PreCalculation oPreCalculation1 = new SVMXC.OMAX_PreCalculation();        
        
        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        svmxprocess.SVMXC__Name__c = 'Optimized Batch DisPatch Pro';
        svmxprocess.RecordTypeId = DispatchProRecordTypeId;
        svmxprocess.SVMXC__Dispatch_Process_Status__c='Complete';
        svmxprocess.SVMXC__Dispatch_Method__c='Optimized Batch';
        svmxprocess.SVMXC__Start_Date__c = system.now().dateGMT();
        svmxprocess.SVMXC__End_Date__c= svmxprocess.SVMXC__Start_Date__c+2;
        svmxprocess.SVMXC__Schedule_Event__c = true;
        svmxprocess.SVMXC__Assign_Work_Order_To__c = 'Technician';
        insert svmxprocess;

        SVMXC__ServiceMax_Processes__c svmxprocess1 = new SVMXC__ServiceMax_Processes__c();
        svmxprocess1.SVMXC__Name__c = 'Immediate DisPatch Pro';
        svmxprocess1.RecordTypeId = DispatchProRecordTypeId;
        svmxprocess1.SVMXC__Dispatch_Method__c='Immediate';
        svmxprocess1.SVMXC__Dispatch_Process_Status__c='Complete';
        svmxprocess1.SVMXC__Start_Date__c = system.now().dateGMT();
        svmxprocess1.SVMXC__End_Date__c= svmxprocess1.SVMXC__Start_Date__c+2;
        svmxprocess1.SVMXC__Schedule_Event__c = true;
        insert svmxprocess1;
        
        SVMXC__ServiceMax_Processes__c  TMatchRule = new SVMXC__ServiceMax_Processes__c();
        TMatchRule.RecordTypeId = RuleRecordTypeId;
        TMatchRule.SVMXC__Rule_Type__c = 'Work Order Territory';
        TMatchRule.SVMXC__Name__c = 'Territory Match Rule';
        insert TMatchRule;
        
        SVMXC__ServiceMax_Processes__c  TRule1 = new SVMXC__ServiceMax_Processes__c();
        TRule1.RecordTypeId = RuleRecordTypeId;
        TRule1.SVMXC__Rule_Type__c = 'Territory Access';
        TRule1.SVMXC__Name__c = 'Territory Access Rule 1';
        TRule1.SVMXC__Process__c = svmxprocess.id; 
        TRule1.SVMXC__Territory__c = Territory1.id;
        insert TRule1;
        
        SVMXC__ServiceMax_Processes__c ARule = new SVMXC__ServiceMax_Processes__c();
        ARule.SVMXC__Name__c = 'ARule 1';
        ARule.RecordTypeId = RuleRecordTypeId;
        ARule.SVMXC__Rule_Type__c = 'Simple Assignment'; 
        ARule.SVMXC__Process__c = svmxprocess1.id;
        insert ARule;
        
        SVMXC__ServiceMax_Processes__c  PRule1 = new SVMXC__ServiceMax_Processes__c();
        PRule1.RecordTypeId = RuleRecordTypeId;
        PRule1.SVMXC__Name__c = 'PriorityRule1';
        PRule1.SVMXC__Rule_Type__c = 'Priortization';
        PRule1.SVMXC__Process__c = svmxprocess.id; 
        PRule1.SVMXC__Sequence__c = 2;
        insert PRule1;
        
        SVMXC__ServiceMax_Processes__c MTTSRule = new SVMXC__ServiceMax_Processes__c();
        MTTSRule.SVMXC__Name__c = 'MTTS Rule';
        MTTSRule.SVMXC__Description__c='MTTS Rule';
        MTTSRule.SVMXC__Rule_Type__c = 'MTTS';
        MTTSRule.RecordTypeId = RuleRecordTypeId;
        MTTSRule.SVMXC__MTTS_Minutes__c = 60;
        MTTSRule.SVMXC__Sequence__c = 1;
        insert MTTSRule;


        //Capacity rule process and config records
        SVMXC__ServiceMax_Processes__c CapacityRule = new SVMXC__ServiceMax_Processes__c();
        CapacityRule.SVMXC__Name__c = 'Maintenance';
        capacityRule.SVMXC__Process__c = svmxprocess.id;
        capacityRule.SVMXC__Description__c='Preventive Maintenance';
        capacityRule.SVMXC__Rule_Type__c = 'Capacity Reservation';
        capacityRule.RecordTypeId = RuleRecordTypeId;
        capacityRule.SVMXC__SM_Capacity_Threshold__c = 60;
        capacityRule.SVMXC__Sequence__c = 1;
        insert CapacityRule;        


        SVMXC__ServiceMax_Processes__c CapacityRule1 = new SVMXC__ServiceMax_Processes__c();
        CapacityRule1.SVMXC__Name__c = 'BreakFix';
        capacityRule1.SVMXC__Process__c = svmxprocess.id;
        CapacityRule1.SVMXC__Description__c='BreakFix';
        CapacityRule1.SVMXC__Rule_Type__c = 'Capacity Reservation';
        CapacityRule1.RecordTypeId = RuleRecordTypeId;
        CapacityRule1.SVMXC__SM_Capacity_Threshold__c = 30;
        CapacityRule1.SVMXC__Sequence__c = 1;
        insert CapacityRule1;
        
        SVMXC__ServiceMax_Processes__c CapacityRule2 = new SVMXC__ServiceMax_Processes__c();
        CapacityRule2.SVMXC__Name__c = 'Installation';
        capacityRule2.SVMXC__Process__c = svmxprocess.id;
        CapacityRule2.SVMXC__Description__c='installation';
        CapacityRule2.SVMXC__Rule_Type__c = 'Capacity Reservation';
        CapacityRule2.RecordTypeId = RuleRecordTypeId;
        CapacityRule2.SVMXC__SM_Capacity_Threshold__c = 20;
        CapacityRule2.SVMXC__Sequence__c = 1;
        insert CapacityRule2;               

        List<SVMXC__ServiceMax_Config_Data__c> configLst = new List<SVMXC__ServiceMax_Config_Data__c>();

        SVMXC__ServiceMax_Config_Data__c capacityRuleCfg1 = new SVMXC__ServiceMax_Config_Data__c();
        capacityRuleCfg1.RecordTypeId =ExpressionRTypeId;
        capacityRuleCfg1.SVMXC__Expression_Type__c = 'DISP_Capacity_Reservation';
        capacityRuleCfg1.SVMXC__Expression_Rule__c = CapacityRule.Id;
        capacityRuleCfg1.SVMXC__Active__c = true;
        capacityRuleCfg1.SVMXC__Field_Name__c='SVMXC__Purpose_of_Visit__c';
        capacityRuleCfg1.SVMXC__Display_Type__c = 'STRING';
        capacityRuleCfg1.SVMXC__Operand__c='Maintenance';
        capacityRuleCfg1.SVMXC__Operator__c='eq';
        capacityRuleCfg1.SVMXC__Sequence__c=1;
        configLst.add(capacityRuleCfg1);                                                                  

        SVMXC__ServiceMax_Config_Data__c capacityRuleCfg2 = new SVMXC__ServiceMax_Config_Data__c();
        capacityRuleCfg2.RecordTypeId =ExpressionRTypeId;
        capacityRuleCfg2.SVMXC__Expression_Type__c = 'DISP_Capacity_Reservation';
        capacityRuleCfg2.SVMXC__Expression_Rule__c = CapacityRule1.Id;
        capacityRuleCfg2.SVMXC__Active__c = true;
        capacityRuleCfg2.SVMXC__Field_Name__c='SVMXC__Purpose_of_Visit__c';
        capacityRuleCfg2.SVMXC__Display_Type__c = 'STRING';
        capacityRuleCfg2.SVMXC__Operand__c='BreakFix';
        capacityRuleCfg2.SVMXC__Operator__c='eq';
        capacityRuleCfg2.SVMXC__Sequence__c=2;
        configLst.add(capacityRuleCfg2);                                                                  

        SVMXC__ServiceMax_Config_Data__c capacityRuleCfg3 = new SVMXC__ServiceMax_Config_Data__c();
        capacityRuleCfg3.RecordTypeId =ExpressionRTypeId;
        capacityRuleCfg3.SVMXC__Expression_Type__c = 'DISP_Capacity_Reservation';
        capacityRuleCfg3.SVMXC__Expression_Rule__c = CapacityRule2.Id;
        capacityRuleCfg3.SVMXC__Active__c = true;
        capacityRuleCfg3.SVMXC__Field_Name__c='SVMXC__Purpose_of_Visit__c';
        capacityRuleCfg3.SVMXC__Display_Type__c = 'STRING';
        capacityRuleCfg3.SVMXC__Operand__c='Installation';
        capacityRuleCfg3.SVMXC__Operator__c='eq';
        capacityRuleCfg3.SVMXC__Sequence__c=2;
        configLst.add(capacityRuleCfg3);                                                                  
        
        SVMXC__ServiceMax_Config_Data__c conf3 = new SVMXC__ServiceMax_Config_Data__c();
        conf3.RecordTypeId =FldMapRecordTypeId;
        conf3.SVMXC__Expression_Rule__c = TMatchRule.Id;
        conf3.SVMXC__Active__c = true;
        conf3.SVMXC__Target_Field_Name__c = 'SVMXC__City__c';                                         
        conf3.SVMXC__Source_Field_Name__c = 'City';   
        configLst.add(conf3);                                                                  
        
        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c='asdfgg';
        oConf.SVMXC__Operator__c='eq';
        oConf.RecordTypeId = ExpressionRTypeId;
        oConf.SVMXC__Sequence__c=1;
        oConf.SVMXC__Expression_Rule__c = svmxprocess.id;
        configLst.add(oConf);
        
        SVMXC__ServiceMax_Config_Data__c oConf1 = new SVMXC__ServiceMax_Config_Data__c();
        oConf1.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf1.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
        oConf1.SVMXC__Display_Type__c = 'STRING';
        oConf1.SVMXC__Operand__c='asdfgg';
        oConf1.SVMXC__Operator__c='eq';
        oConf1.RecordTypeId = ExpressionRTypeId;
        oConf1.SVMXC__Sequence__c=1;
        oConf1.SVMXC__Expression_Rule__c = svmxprocess1.id;
        configLst.add(oConf1);
       
        SVMXC__ServiceMax_Config_Data__c aoConf1 = new SVMXC__ServiceMax_Config_Data__c();
        aoConf1.SVMXC__Expression_Type__c = 'DISP_Simple_Assignment';
        aoConf1.SVMXC__Field_Name__c='SVMXC__Zip__c';
        aoConf1.SVMXC__Display_Type__c = 'STRING';
        aoConf1.SVMXC__Operand__c='11111';
        aoConf1.SVMXC__Operator__c='eq';
        aoConf1.RecordTypeId = ExpressionRTypeId;
        aoConf1.SVMXC__Sequence__c=1;
        aoConf1.SVMXC__Expression_Rule__c = ARule.id;
        configLst.add(aoConf1);
        
        SVMXC__ServiceMax_Config_Data__c conf8 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = MTTSRule.id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__City__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'amar',
                                            SVMXC__Expression_Type__c = 'WORD_MTTS',
                                            SVMXC__Sequence__c = 1.0,
                                            SVMXC__Display_Type__c ='STRING'   
                                            );
        configLst.add(conf8);
        
        SVMXC__ServiceMax_Config_Data__c conf4 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = PRule1.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__Billing_Type__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'Contract',
                                            SVMXC__Sequence__c = 1.0,
                                            SVMXC__Expression_Type__c = 'DISP_Priortization'                                            
                                            );
        configLst.add(conf4);
        
        SVMXC__ServiceMax_Config_Data__c conf2 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = TMatchRule.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__City__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'amar',
                                            SVMXC__Expression_Type__c = 'WORD_Territory',
                                            SVMXC__Sequence__c = 1.0000,
                                            SVMXC__Display_Type__c ='STRING'                                       
                                            );
        configLst.add(conf2);   
        insert configLst;

        
        list<SVMXC__Service_Order__c> lstWO1 = new list<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c nWO1 = new SVMXC__Service_Order__c();
        nWO1.SVMXC__Zip__c = '11111';
        nWO1.SVMXC__Company__c=a.Id;              
        nWO1.SVMXC__Order_Status__c='asdfgg';
        nWO1.SVMXC__Priority__c='Low';
        nWO1.SVMXC__Order_Type__c='Field Service';
        nWO1.SVMXC__Purpose_of_Visit__c='Repair';
        nWO1.SVMXC__SLA_Terms__c=SLA.id;
        nWO1.SVMXC__Billing_Type__c = 'Contract';
        nWO1.SVMXC__City__c = 'amar';
        nWO1.SVMXC__Group_Member__c = Tech.id;
        nWO1.SVMXC__Scheduled_Date_Time__c = datetime.now();
        nWO1.SVMXC__Dispatch_Process__c =  svmxprocess1.id;
        nWO1.SVMXC__OptiMax_Error_Occurred__c = false;
        nWO1.SVMXC__OptiMax_Status__c = 'Not Completed';
        nWO1.SVMXC__Locked_By_DC__c = false;
        nWO1.SVMXC__Service_Duration__c = 60;
        nWO1.Driving_Time__c = 60;
        nWO1.SVMXC__Component__c = IBObject.Id;
        lstWO1.add(nWO1);
        
        SVMXC__Service_Order__c nWO2 = new SVMXC__Service_Order__c();
        nWO2.SVMXC__Zip__c = '11111';
        nWO2.SVMXC__Company__c=a.Id;              
        nWO2.SVMXC__Order_Status__c='asdfgg';
        nWO2.SVMXC__Billing_Type__c = 'Contract';
        nWO2.SVMXC__Priority__c='Low';
        nWO2.SVMXC__Order_Type__c='Field Service';
        nWO2.SVMXC__Purpose_of_Visit__c='Repair';
        nWO2.SVMXC__SLA_Terms__c=SLA.id;
        nWO2.SVMXC__City__c = 'amar';
        nWO2.SVMXC__State__c = 'Karnataka';
        nWO2.SVMXC__Group_Member__c = Tech1.id;
        nWO2.SVMXC__Scheduled_Date_Time__c = datetime.now();
        nWO2.SVMXC__Dispatch_Process__c =  svmxprocess1.id;
        nWO2.SVMXC__OptiMax_Error_Occurred__c = false;
        nWO2.SVMXC__OptiMax_Status__c = 'Not Completed';
        nWO2.SVMXC__Locked_By_DC__c = false;
        nWO2.SVMXC__Service_Duration__c = 60;
        nWO2.Driving_Time__c = 60;
        nWO2.SVMXC__Component__c = IBObject.Id;
        lstWO1.add(nWO2);
        insert lstWO1;
                
        
        list<SVMXC__Service_Order__c> lstWO = new list<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c oldWO = new SVMXC__Service_Order__c();
        oldWO.SVMXC__Zip__c = '12131';
        oldWO.SVMXC__City__c = 'amarOld';
        lstWO.add(oldWO);
        insert lstWO;

        list<SVMXC__Service_Order__c> lstWOcapacity = new list<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c capacitywo1 = new SVMXC__Service_Order__c();
        capacitywo1.SVMXC__Zip__c = '11111';
        capacitywo1.SVMXC__Company__c=a.Id;              
        capacitywo1.SVMXC__Order_Status__c='asdfgg';
        capacitywo1.SVMXC__Priority__c='Low';
        capacitywo1.SVMXC__Order_Type__c='Field Service';
        capacitywo1.SVMXC__Purpose_of_Visit__c='Maintenance';
        capacitywo1.SVMXC__SLA_Terms__c=SLA.id;
        capacitywo1.SVMXC__Billing_Type__c = 'Contract';
        capacitywo1.SVMXC__City__c = 'amar';
        capacitywo1.SVMXC__Group_Member__c = Tech.id;
        capacitywo1.SVMXC__Scheduled_Date_Time__c = datetime.now();
        capacitywo1.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        capacitywo1.SVMXC__OptiMax_Error_Occurred__c = false;
        capacitywo1.SVMXC__OptiMax_Status__c = 'Processing Completed';
        capacitywo1.SVMXC__Locked_By_DC__c = false;
        capacitywo1.SVMXC__Service_Duration__c = 60;
        capacitywo1.Driving_Time__c = 60;
        capacitywo1.SVMXC__Component__c = IBObject.Id;
        lstWOcapacity.add(capacitywo1);
        
        SVMXC__Service_Order__c capacitywo2 = new SVMXC__Service_Order__c();
        capacitywo2.SVMXC__Zip__c = '11111';
        capacitywo2.SVMXC__Company__c=a.Id;              
        capacitywo2.SVMXC__Order_Status__c='kkkkk';
        capacitywo2.SVMXC__Priority__c='high';
        capacitywo2.SVMXC__Order_Type__c='Open';
        capacitywo2.SVMXC__Purpose_of_Visit__c='Installation';
        capacitywo2.SVMXC__SLA_Terms__c=SLA.id;
        capacitywo2.SVMXC__City__c = 'Chennai';
        capacitywo2.SVMXC__Group_Member__c = Tech.id;
        capacitywo2.SVMXC__Scheduled_Date_Time__c = datetime.now();
        capacitywo2.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        capacitywo2.SVMXC__OptiMax_Error_Occurred__c = false;
        capacitywo2.SVMXC__OptiMax_Status__c = 'Processing Completed';
        capacitywo2.SVMXC__Locked_By_DC__c = true;
        capacitywo2.SVMXC__Service_Duration__c = 60;
        capacitywo2.Driving_Time__c = 60;
        lstWOcapacity.add(capacitywo2);

        SVMXC__Service_Order__c capacitywo3 = new SVMXC__Service_Order__c();
        capacitywo3.SVMXC__Zip__c = '11111';
        capacitywo3.SVMXC__Company__c=a.Id;              
        capacitywo3.SVMXC__Order_Status__c='kkkkk';
        capacitywo3.SVMXC__Priority__c='high';
        capacitywo3.SVMXC__Order_Type__c='Open';
        capacitywo3.SVMXC__Purpose_of_Visit__c='BreakFix';
        capacitywo3.SVMXC__SLA_Terms__c=SLA.id;
        capacitywo3.SVMXC__City__c = 'Chennai';
        capacitywo3.SVMXC__Group_Member__c = Tech.id;
        capacitywo3.SVMXC__Scheduled_Date_Time__c = datetime.now();
        capacitywo3.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        capacitywo3.SVMXC__OptiMax_Error_Occurred__c = false;
        capacitywo3.SVMXC__OptiMax_Status__c = 'Processing Completed';
        capacitywo3.SVMXC__Locked_By_DC__c = true;
        capacitywo3.SVMXC__Service_Duration__c = 60;
        capacitywo3.Driving_Time__c = 60;
        lstWOcapacity.add(capacitywo3);
        insert lstWOcapacity;
        //createOptimizationSettings('OptiMax,ServicePower', 'True');
        
        SVMXC.OMAX_PreCalculation oPreCalculation = new SVMXC.OMAX_PreCalculation(svmxSettingListOMAX003,AccList,LstCase,LstComponent); 
        
        OMAX_PreCalculation.mapWorkOrder = new map<integer, SVMXC__Service_Order__c>();
        OMAX_PreCalculation.mapWorkOrder.put(1, nWO1);
        OMAX_PreCalculation.mapWorkOrder.put(2, nWO2);
        
        oPreCalculation.doTerritoryMatchRule();
        oPreCalculation.DoProcessTechnicians(techIDs, svmxSettingListOMAX003);
        oPreCalculation.CreateEvents(lstWO1,lstWO);
        
        lstWO1.get(0).SVMXC__OptiMax_Error_Occurred__c = lstWO1.get(1).SVMXC__OptiMax_Error_Occurred__c = true;
        
        svmxprocess.SVMXC__Assign_To_Technician__c = tech.id;
        oPreCalculation.UpdateWorkOrderForSimpleDispatch(0, lstWO.get(0) , svmxprocess);    
        svmxprocess.SVMXC__Assign_To_Technician__c = tech1.id;
        oPreCalculation.UpdateWorkOrderForSimpleDispatch(1, lstWO.get(0) , svmxprocess);
        
        try{
            oPreCalculation.DoPrecalculation(lstWO1);
            oPreCalculation.DoPrecalculation(lstWO1, lstWO1);
        }
        catch(Exception ex){}
        
        svmxprocess.SVMXC__Assign_Work_Order_To__c = 'Dispatcher';
        oPreCalculation.UpdateWorkOrderForSimpleDispatch(0, lstWO.get(0) , svmxprocess);        
        svmxprocess.SVMXC__Assign_Work_Order_To__c = 'Queue';
        oPreCalculation.UpdateWorkOrderForSimpleDispatch(0, lstWO.get(0) , svmxprocess);        
        svmxprocess.SVMXC__Assign_Work_Order_To__c = 'Extra';
        oPreCalculation.UpdateWorkOrderForSimpleDispatch(0, lstWO.get(0) , svmxprocess);
        
        oPreCalculation.getINumberofDays();
        oPreCalculation.getAvgDrivTimeinMin();
        oPreCalculation.getConsiderSameDay();
        oPreCalculation.getILeadTime();
        oPreCalculation.getEvntSubject();

        list<SVMXC__Service_Order__c> lstNewWO = new list<SVMXC__Service_Order__c>();
        list<SVMXC__Service_Order__c> lstOldWO = new list<SVMXC__Service_Order__c>();
        
        SVMXC__Service_Order__c nWO11 = new SVMXC__Service_Order__c();
        nWO11.SVMXC__Zip__c = '11111';
        nWO11.SVMXC__Company__c=a.Id;              
        nWO11.SVMXC__Order_Status__c='asdfgg';
        nWO11.SVMXC__Priority__c='Low';
        nWO11.SVMXC__Order_Type__c='Field Service';
        nWO11.SVMXC__Purpose_of_Visit__c='Repair';
        nWO11.SVMXC__SLA_Terms__c=SLA.id;
        nWO11.SVMXC__Billing_Type__c = 'Contract';
        nWO11.SVMXC__City__c = 'amar';
        nWO11.SVMXC__Group_Member__c = Tech.id;
        nWO11.SVMXC__Scheduled_Date_Time__c = datetime.now();
        nWO11.SVMXC__Dispatch_Process__c =  svmxprocess1.id;
        nWO11.SVMXC__OptiMax_Error_Occurred__c = false;
        nWO11.SVMXC__OptiMax_Status__c = 'Not Completed';
        nWO11.SVMXC__Locked_By_DC__c = false;
        nWO11.SVMXC__Service_Duration__c = 60;
        nWO11.Driving_Time__c = 60;
        nWO11.SVMXC__Component__c = IBObject.Id;
        lstNewWO.add(nWO11);
        
        SVMXC__Service_Order__c nWO12 = new SVMXC__Service_Order__c();
        nWO12.SVMXC__Zip__c = '11111';
        nWO12.SVMXC__Company__c=a.Id;              
        nWO12.SVMXC__Order_Status__c='asdfgg';
        nWO12.SVMXC__Priority__c='Low';
        nWO12.SVMXC__Order_Type__c='Field Service';
        nWO12.SVMXC__Purpose_of_Visit__c='Repair';
        nWO12.SVMXC__SLA_Terms__c=SLA.id;
        nWO12.SVMXC__Billing_Type__c = 'Contract';
        nWO12.SVMXC__City__c = 'amar';
        nWO12.SVMXC__Group_Member__c = Tech.id;
        nWO12.SVMXC__Scheduled_Date_Time__c = datetime.now();
        nWO12.SVMXC__Dispatch_Process__c =  svmxprocess1.id;
        nWO12.SVMXC__OptiMax_Error_Occurred__c = false;
        nWO12.SVMXC__OptiMax_Status__c = 'Not Completed';
        nWO12.SVMXC__Locked_By_DC__c = false;
        nWO12.SVMXC__Service_Duration__c = 120;
        nWO12.Driving_Time__c = 60;
        nWO12.SVMXC__Component__c = IBObject.Id;
        lstOldWO.add(nWO12);
        
        //oPreCalculation.DoMTTS(nWO11,lstOldWO);
        oPreCalculation.DoSLAHours(nWO11,lstOldWO);
        
        map<Id, SVMXC__ServiceMax_Processes__c> mapSVMXProcess= new map<Id, SVMXC__ServiceMax_Processes__c>();
        mapSVMXProcess.putAll([SELECT Name, SVMXC__Sequence__c, SVMXC__Name__c, SVMXC__MTTS_Minutes__c, SVMXC__Advance_Expression__c, 
                SVMXC__Rule_Type__c, SVMXC__Process__c, SVMXC__Process__r.SVMXC__Dispatch_Process_Status__c , SVMXC__Territory__c, 
                SVMXC__Technician_User__c, SVMXC__Technician_Service_Group__c, SVMXC__Start_Time__c, SVMXC__Start_Date__c, SVMXC__Schedule_Event__c,
                SVMXC__Product_Match_Enabled__c, SVMXC__Preferred_Tech_Enabled__c, SVMXC__Final_Exception_Process__c, SVMXC__Expertise_Match_Enabled__c, 
                SVMXC__End_Date__c, SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c, SVMXC__Distance_And_Time__c, SVMXC__Dispatch_Method__c,
                SVMXC__Calendar_Start_Type__c, SVMXC__Calendar_Start_Days__c, SVMXC__Calendar_End_Type__c, SVMXC__Calendar_End_Days__c, 
                SVMXC__Assign_Work_Order_To__c, SVMXC__Assign_To_Technician__c, SVMXC__Assign_To_Technician__r.SVMXC__Email__c, 
                SVMXC__Assign_To_Queue__c, SVMXC__Assign_To_Dispatcher__c, Id, SVMXC__Weight_Tech_Eligibility__c, SVMXC__Weight_Skill_Match__c, 
                SVMXC__Weight_Product_Specialization__c, SVMXC__Weight_Preferred_Technician__c, RecordType.Name from SVMXC__ServiceMax_Processes__c 
                where (RecordType.Name = 'Dispatch Process' and SVMXC__Dispatch_Process_Status__c = 'Complete' and 
                        (SVMXC__Dispatch_Method__c = 'Immediate' OR 
                            (SVMXC__Dispatch_Method__c = 'Optimized Batch' OR 
                                (SVMXC__Dispatch_Method__c = 'Linx for ServicePower' OR 
                                    (SVMXC__Dispatch_Method__c = 'Real Time Optimization' OR
                                        (SVMXC__Dispatch_Method__c = 'Long-Term Planner' and 
                                            (SVMXC__End_Date__c >=: system.now().dateGMT() or SVMXC__End_Date__c=null)
                                        )
                                    )
                                )
                            )
                        )
                      ) or RecordType.Name = 'SVMX Rule' order by SVMXC__Sequence__c]);
        
        OMAX_ManagePrecalcData omxManagePrecalc = new OMAX_ManagePrecalcData();
        omxManagePrecalc.seggregateConfigData(mapSVMXProcess,svmxSettingListOMAX003);
        
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapAdvDispProExp = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapContDispProExp = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapECODispProExp = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        omxManagePrecalc.setMapOmaxDispatchProcess(mapSVMXProcess);
        omxManagePrecalc.setMapAdvDispProExp(mapAdvDispProExp);
        omxManagePrecalc.setMapContDispProExp(mapContDispProExp);
        omxManagePrecalc.setMapECODispProExp(mapECODispProExp);
        map<Id, SVMXC__ServiceMax_Processes__c> mapECODispatchProcess = new map<Id, SVMXC__ServiceMax_Processes__c>();
        omxManagePrecalc.setMapECODispatchProcess(mapECODispatchProcess);
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapAllDispProExp = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        omxManagePrecalc.setMapAllDispProExp(mapAllDispProExp);
        map<Id, SVMXC__ServiceMax_Processes__c> mapTerritoryRules = new map<Id, SVMXC__ServiceMax_Processes__c>();
        omxManagePrecalc.setMapTerritoryRules(mapTerritoryRules);
        map<Id, set<string>> mapDispProTerritory = new map<Id, set<string>>();
        omxManagePrecalc.setMapDispProTerritory(mapDispProTerritory);
        map<Id, Id> mapTertryDispProcess = new map<Id, Id>();
        omxManagePrecalc.setMapTertryDispProcess(mapTertryDispProcess);
        map<Id, map<Id, list<SVMXC__ServiceMax_Config_Data__c>>> mapSimpleDispRulesExp = new map<Id, map<Id, list<SVMXC__ServiceMax_Config_Data__c>>>();
        omxManagePrecalc.setMapSimpleDispRulesExp(mapSimpleDispRulesExp);
        map<Id, map<Id, list<SVMXC__ServiceMax_Config_Data__c>>> mapPriorityDispRulesExp = new map<Id, map<Id, list<SVMXC__ServiceMax_Config_Data__c>>>();
        omxManagePrecalc.setMapPriorityDispRulesExp(mapPriorityDispRulesExp);
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapTerritoryFieldMap = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        omxManagePrecalc.setMapTerritoryFieldMap(mapTerritoryFieldMap);
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapMTTSDispRulesExp = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        omxManagePrecalc.setMapMTTSDispRulesExp(mapMTTSDispRulesExp);
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapTerritoryDispRulesExp = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>(); 
        omxManagePrecalc.setMapTerritoryDispRulesExp(mapTerritoryDispRulesExp);
        map<Id, map<Id, list<SVMXC__ServiceMax_Config_Data__c>>> mapCapacityLimitRulesEx = new map<Id, map<Id, list<SVMXC__ServiceMax_Config_Data__c>>>();
        omxManagePrecalc.setMapCapacityLimitRulesExp(mapCapacityLimitRulesEx);
        
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapDispProExp = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        omxManagePrecalc.setMapDispProExp(mapDispProExp);
        
        map<Id, list<SVMXC__ServiceMax_Config_Data__c>> mapLTPDispProExp = new map<Id, list<SVMXC__ServiceMax_Config_Data__c>>();
        omxManagePrecalc.setMapLTPDispProExp(mapLTPDispProExp);
        
        map<Id, SVMXC__ServiceMax_Processes__c> mapLTPDispatchProcess = new map<Id, SVMXC__ServiceMax_Processes__c>();
        omxManagePrecalc.setMapLTPDispatchProcess(mapLTPDispatchProcess);
        //oPreCalculation.getWorkOrdersForSkillCompute(lstWO1);

    }
}