@isTest
(SeeAllData= true)
Private class SMAX_OptiMax_Engine_WS_UT{
    static String dispatchprocessId;
    static String territoryId;
    static String jobId;
    
    static list<string> lstSettings;
    static List<SVMXC__ServiceMax_Config_Data__c> lstSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();
    
    static list<string> lstSettings1;
    static List<SVMXC__ServiceMax_Config_Data__c> lstSettingValues1;
    
    static {
        SMAX_OptiMax_Engine_WS_UT smaxEngineWS = new SMAX_OptiMax_Engine_WS_UT(); 
        createSettings();
    } 
    
   /* void SMAX_OptiMax_Engine_WS_UT() {
        createSettings();
    }*/
    
    public static void createSettings() {
        lstSettings = new list<string>();        
        lstSettings.add('GLOB001_GBL007');
        lstSettings.add('OMAX003_SET030');
        lstSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        try {
            lstSettingValues = [SELECT SVMXC__Internal_Value__c, SVMXC__Setting_Unique_ID__c FROM SVMXC__ServiceMax_Config_Data__c WHERE recordType.Name = 'Setting Value'
                            AND SVMXC__Setting_Unique_ID__c IN :lstSettings
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' 
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Global' for UPDATE
                            ];                          
            lstSettingValues[0].SVMXC__Internal_Value__c='True';
            lstSettingValues[1].SVMXC__Internal_Value__c='True';
            upsert lstSettingValues;
            
            
            lstSettings1 = new list<string>();          
            lstSettings1.add('OMAX003_SET032'); //batch size
            lstSettings1.add('OMAX002_SET002'); //dbl age       
            lstSettingValues1 = new List<SVMXC__ServiceMax_Config_Data__c>();
            lstSettingValues1 = [SELECT SVMXC__Internal_Value__c, SVMXC__Setting_Unique_ID__c FROM SVMXC__ServiceMax_Config_Data__c WHERE recordType.Name = 'Setting Value'
                                AND SVMXC__Setting_Unique_ID__c IN :lstSettings1
                                AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true
                                AND SVMXC__Setting_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' 
                                AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Global'
                                ];
            lstSettingValues1[0].SVMXC__Internal_Value__c='20';
            lstSettingValues1[1].SVMXC__Internal_Value__c='60';
            upsert lstSettingValues1;
            
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
        
        //set GBL007 true and licence
        AllsvmxSettingList.put('GLOB001',svmxSettingListOMAX003);
                    
        } catch(Exception ex) {
            system.debug('Exception occurred - ' + ex.getMessage());
        }
    }
    
    static testMethod void SMAX_OptiMax_Engine_WS_UnitTest()
    {
        try
        {
        //Creating data 
        System.debug('Entering the SMAX_OptiMax_Engine_WS_UnitTest');
        /*list<string> lstSettings = new list<string>();        
        lstSettings.add('GLOB001_GBL007');
        lstSettings.add('OMAX003_SET030');
        List<SVMXC__ServiceMax_Config_Data__c> lstSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstSettingValues = [SELECT SVMXC__Internal_Value__c, SVMXC__Setting_Unique_ID__c FROM SVMXC__ServiceMax_Config_Data__c WHERE recordType.Name = 'Setting Value'
                            AND SVMXC__Setting_Unique_ID__c IN :lstSettings
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' 
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Global'
                            ];                          
        lstSettingValues[0].SVMXC__Internal_Value__c='True';
        lstSettingValues[1].SVMXC__Internal_Value__c='True';
        upsert lstSettingValues;
        list<string> lstSettings1 = new list<string>();          
        lstSettings1.add('OMAX003_SET032'); //batch size
        lstSettings1.add('OMAX002_SET002'); //dbl age       
        List<SVMXC__ServiceMax_Config_Data__c> lstSettingValues1 = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstSettingValues1 = [SELECT SVMXC__Internal_Value__c, SVMXC__Setting_Unique_ID__c FROM SVMXC__ServiceMax_Config_Data__c WHERE recordType.Name = 'Setting Value'
                            AND SVMXC__Setting_Unique_ID__c IN :lstSettings1
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' 
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Global'
                            ];
        lstSettingValues1[0].SVMXC__Internal_Value__c='20';
        lstSettingValues1[1].SVMXC__Internal_Value__c='60';
        upsert lstSettingValues1;*/
        
                    
            case c = new case();
            Account account = new Account(
                                                Name = 'Account',
                                                ShippingStreet= 'ABC',
                                                ShippingCity= 'PQR ',
                                                ShippingState = 'California',
                                                ShippingPostalCode= '111',
                                                ShippingCountry= 'United States',
                                                BillingStreet= 'ABC',
                                                BillingCity= 'PQR ',
                                                BillingState = 'California',
                                                BillingPostalCode= '111',
                                                BillingCountry= 'United States'
                                                );  
            insert account;
            System.assertEquals('Account', account.Name);
            
            List<BusinessHours> lBH = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where IsActive = true OR isDefault = true limit 5];
            
            
            Contact contact = new Contact(LastName= 'Last',AccountId =account.Id,Email= 'test@max.com');
            insert contact;
            System.assertEquals('Last', contact.LastName);      
            
            SVMXC__Territory__c T1 = new SVMXC__Territory__c(Name= 'T1',SVMXC__Active__c =true,SVMXC__Territory_Code__c = 'T1',SVMXC__Parent_Territory__c =NULL,SVMXC__Per_Mile_Cost__c=2.0,SVMXC__Max_Distance__c=100,SVMXC__Average_Speed__c=50.0);
            insert T1;
            territoryId = T1.Id;
            RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];
            SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
            
            SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
            oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
            oConf.SVMXC__Field_Name__c = 'SVMXC__Zip__c';
            oConf.SVMXC__Display_Type__c = 'STRING';
            oConf.SVMXC__Operand__c = '11111111';
            oConf.SVMXC__Operator__c = 'eq';
            oConf.SVMXC__Expression_Rule__c =svmxprocess.Id;
            
            
            for(RecordType rt : rts) //Loop to take a record type at a time
            {
                if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                {
                   svmxprocess.RecordTypeId = rt.ID;
                } 
                 
                if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                {
                   oConf.RecordTypeId = rt.ID;
                } 
            }
            
            svmxprocess.SVMXC__Territory__c = T1.Id;
            svmxprocess.SVMXC__Description__c = 'abcd';
            svmxprocess.SVMXC__Dispatch_Method__c = 'Optimized Batch';
            svmxprocess.SVMXC__Assign_Work_Order_To__c = 'Technician';
            svmxprocess.SVMXC__Calendar_Start_Type__c = 'SAME DAY';
            svmxprocess.SVMXC__Calendar_End_Type__c = 'SAME DAY';
            svmxprocess.SVMXC__Expertise_Match_Enabled__c =true;
            svmxprocess.SVMXC__Product_Match_Enabled__c =true;
            svmxprocess.SVMXC__Preferred_Tech_Enabled__c =true;
            svmxprocess.SVMXC__Route_Type__c = 'CLOSED';
            svmxprocess.SVMXC__Distance_And_Time__c = 'Actual Distance And Time';
            svmxprocess.SVMXC__Weight_Time_Window__c =1.0000;
            svmxprocess.SVMXC__Weight_Route_Distance__c =1.0000;
            svmxprocess.SVMXC__Weight_Route_Time__c =1.0000;
            svmxprocess.SVMXC__Weight_Node_Type__c =1;
            svmxprocess.SVMXC__Dispatch_Process_Status__c = 'Complete';
            svmxprocess.SVMXC__Runs_Every_Monday__c =true;
            svmxprocess.SVMXC__Runs_Every_Tuesday__c =true;
            svmxprocess.SVMXC__Start_Time__c = '11:00 PM';
            svmxprocess.SVMXC__Frequency__c =1;
            svmxprocess.SVMXC__Full_Run_Unit__c = 'Days';
            svmxprocess.SVMXC__Start_Date__c = date.Today();
            svmxprocess.SVMXC__End_Date__c = date.Today().addDays(1);
            svmxprocess.SVMXC__Weight_Total_Distance__c =1.0000;
            svmxprocess.SVMXC__Calendar_Start_Days__c = 0;
            svmxprocess.SVMXC__Calendar_End_Days__c = 2;
            svmxprocess.SVMXC__Tolerance__c = 30;
            svmxprocess.SVMXC__ProcessID__c = 'PROCESS11';
            svmxprocess.SVMXC__SettingId__c = 'PROCESS11';
            svmxprocess.SVMXC__MapID__c = 'PROCESS11';
            svmxprocess.SVMXC__Name__c = 'PROCESS22';
            Insert svmxprocess;
            dispatchprocessId = svmxprocess.Id;
            
            insert oConf;
            System.assertEquals(true, oConf != null);   
            
            List<SVMXC__Service_Order__c> Wo_List = new List<SVMXC__Service_Order__c>();
            SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
            workOrder1.SVMXC__Case__c = c.Id;
            workOrder1.SVMXC__Company__c = account.Id;
            workOrder1.SVMXC__Contact__c =contact.Id;
            workOrder1.SVMXC__Latitude__c = 40.739582;
            workOrder1.SVMXC__Longitude__c = -73.980772;
            workOrder1.SVMXC__Street__c = 'Street1';
            workOrder1.SVMXC__City__c = 'BANGALORE';
            workOrder1.SVMXC__State__c = 'Karnataka';
            workOrder1.SVMXC__Country__c = 'India';
            workOrder1.SVMXC__Zip__c = '11111111';
            workOrder1.SVMXC__Order_Status__c = 'Open';
            workOrder1.SVMXC__Priority__c = 'Medium';
            workOrder1.SVMXC__Dispatch_Priority__c = 2;
            workOrder1.SVMXC__Order_Type__c = 'Field Service';
            workOrder1.SVMXC__Apply_Business_Hours_For_OptiMax__c = false;
            workOrder1.SVMXC__Preferred_Business_Hours__c = lBH[0].Id;
            workOrder1.SVMXC__Primary_Territory__c = T1.Id;
            workOrder1.SVMXC__OptiMax_status__c = '';
            workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
            workOrder1.SVMXC__Dispatch_Process__c = svmxprocess.Id;
            workOrder1.SVMXC__Service_Duration__c = 6000;
            workOrder1.SVMXC__Locked_By_DC__c = false;
            workOrder1.SVMXC__SM_Lock_Appointment_Schedule__c = null;
            workOrder1.SVMXC__Qualified_Technicians__c = '[{"valid":false,"tName":"MizaLatLong","tech":"a1DF0000008fpCZMAY","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"Miza1","tech":"a1DF0000008fusxMAA","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"Miza2","tech":"a1DF0000008fut2MAA","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"Miza3","tech":"a1DF0000008fut7MAA","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"Miza4","tech":"a1DF0000008fvCeMAI","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"TestTech","tech":"a1DF0000008fz6yMAA","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10}]';
            Wo_List.add(workOrder1);
            //Insert Wo;
            
            SVMXC__Service_Order__c workOrder2 = new SVMXC__Service_Order__c();
            workOrder2.SVMXC__Case__c = c.Id;
            workOrder2.SVMXC__Company__c = account.Id;
            workOrder2.SVMXC__Contact__c =contact.Id;
            workOrder2.SVMXC__Latitude__c = 40.739582;
            workOrder2.SVMXC__Longitude__c = -73.980772;
            workOrder2.SVMXC__Street__c = 'Street1';
            workOrder2.SVMXC__City__c = 'BANGALORE';
            workOrder2.SVMXC__State__c = 'Karnataka';
            workOrder2.SVMXC__Country__c = 'India';
            workOrder2.SVMXC__Zip__c = '11111111';
            workOrder2.SVMXC__Order_Status__c = 'Open';
            workOrder2.SVMXC__Priority__c = 'Medium';
            workOrder2.SVMXC__Dispatch_Priority__c = 2;
            workOrder2.SVMXC__Order_Type__c = 'Field Service';
            workOrder2.SVMXC__Apply_Business_Hours_For_OptiMax__c = true;
            workOrder2.SVMXC__Preferred_Start_Time__c = system.now().addDays(-2);
            workOrder2.SVMXC__Preferred_End_Time__c = system.now().addDays(5);
            workOrder2.SVMXC__Primary_Territory__c = T1.Id;
            workOrder2.SVMXC__OptiMax_status__c = '';
            workOrder2.SVMXC__OptiMax_Error_Occurred__c = false;
            workOrder2.SVMXC__Dispatch_Process__c = svmxprocess.Id;
            workOrder2.SVMXC__Service_Duration__c = 50000;
            workOrder2.SVMXC__Locked_By_DC__c = true;
            workOrder2.SVMXC__SM_Lock_Appointment_Schedule__c = WSCH_ECO_Constants.SCHEDULE_LOCK_IN_PLACE;
            workOrder2.SVMXC__Qualified_Technicians__c = '[{"valid":false,"tName":"MizaLatLong","tech":"a1DF0000008fpCZMAY","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"Miza1","tech":"a1DF0000008fusxMAA","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"Miza2","tech":"a1DF0000008fut2MAA","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"Miza3","tech":"a1DF0000008fut7MAA","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"Miza4","tech":"a1DF0000008fvCeMAI","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"TestTech","tech":"a1DF0000008fz6yMAA","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10}]';
            Wo_List.add(workOrder2);
            
            SVMXC__Service_Order__c workOrder3 = new SVMXC__Service_Order__c();
            workOrder3.SVMXC__Case__c = c.Id;
            workOrder3.SVMXC__Company__c = account.Id;
            workOrder3.SVMXC__Contact__c =contact.Id;
            workOrder3.SVMXC__Latitude__c = 40.739582;
            workOrder3.SVMXC__Longitude__c = -73.980772;
            workOrder3.SVMXC__Street__c = 'Street1';
            workOrder3.SVMXC__City__c = 'BANGALORE';
            workOrder3.SVMXC__State__c = 'Karnataka';
            workOrder3.SVMXC__Country__c = 'India';
            workOrder3.SVMXC__Zip__c = '11111111';
            workOrder3.SVMXC__Order_Status__c = 'Open';
            workOrder3.SVMXC__Priority__c = 'Medium';
            workOrder3.SVMXC__Dispatch_Priority__c = 2;
            workOrder3.SVMXC__Order_Type__c = 'Field Service';
            workOrder3.SVMXC__Apply_Business_Hours_For_OptiMax__c = true;
            workOrder3.SVMXC__Preferred_Start_Time__c = system.now().addDays(-2);
            workOrder3.SVMXC__Preferred_End_Time__c = system.now().addDays(5);
            workOrder3.SVMXC__Primary_Territory__c = T1.Id;
            workOrder3.SVMXC__OptiMax_status__c = '';
            workOrder3.SVMXC__OptiMax_Error_Occurred__c = false;
            workOrder3.SVMXC__Service_Duration__c = 50000;
            workOrder3.SVMXC__Locked_By_DC__c = false;
            workOrder3.SVMXC__SM_Lock_Appointment_Schedule__c = null;
            workOrder3.SVMXC__Qualified_Technicians__c = '[{"valid":false,"tName":"MizaLatLong","tech":"a1DF0000008fpCZMAY","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"Miza1","tech":"a1DF0000008fusxMAA","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"Miza2","tech":"a1DF0000008fut2MAA","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"Miza3","tech":"a1DF0000008fut7MAA","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"Miza4","tech":"a1DF0000008fvCeMAI","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"TestTech","tech":"a1DF0000008fz6yMAA","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10}]';
            Wo_List.add(workOrder3);
            
            SVMXC__Service_Order__c workOrder4 = new SVMXC__Service_Order__c();
            workOrder4.SVMXC__Case__c = c.Id;
            workOrder4.SVMXC__Company__c = account.Id;
            workOrder4.SVMXC__Contact__c =contact.Id;
            workOrder4.SVMXC__Latitude__c = 40.739582;
            workOrder4.SVMXC__Longitude__c = -73.980772;
            workOrder4.SVMXC__Street__c = 'Street1';
            workOrder4.SVMXC__City__c = 'BANGALORE';
            workOrder4.SVMXC__State__c = 'Karnataka';
            workOrder4.SVMXC__Country__c = 'India';
            workOrder4.SVMXC__Zip__c = '11111111';
            workOrder4.SVMXC__Order_Status__c = 'Open';
            workOrder4.SVMXC__Priority__c = 'Medium';
            workOrder4.SVMXC__Dispatch_Priority__c = 2;
            workOrder4.SVMXC__Order_Type__c = 'Field Service';
            workOrder4.SVMXC__Apply_Business_Hours_For_OptiMax__c = true;
            workOrder4.SVMXC__Preferred_Start_Time__c = system.now().addDays(1);
            workOrder4.SVMXC__Preferred_End_Time__c = system.now().addDays(1).addHours(2);
            workOrder4.SVMXC__Primary_Territory__c = T1.Id;
            workOrder4.SVMXC__OptiMax_status__c = '';
            workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
            workOrder4.SVMXC__Dispatch_Process__c = svmxprocess.Id;
            workOrder4.SVMXC__Service_Duration__c = 50000;
            workOrder4.SVMXC__Locked_By_DC__c = false;
            workOrder4.SVMXC__SM_Lock_Appointment_Schedule__c = null;

            SVMXC__Service_Order__c workOrder5 = new SVMXC__Service_Order__c();
            workOrder5.SVMXC__Case__c = c.Id;
            workOrder5.SVMXC__Company__c = account.Id;
            workOrder5.SVMXC__Contact__c =contact.Id;
            workOrder5.SVMXC__Street__c = '';
            workOrder5.SVMXC__City__c = '';
            workOrder5.SVMXC__State__c = '';
            workOrder5.SVMXC__Country__c = '';
            workOrder5.SVMXC__Zip__c = '';
            workOrder5.SVMXC__Order_Status__c = 'Open';
            workOrder5.SVMXC__Priority__c = 'Medium';
            workOrder5.SVMXC__Dispatch_Priority__c = 2;
            workOrder5.SVMXC__Order_Type__c = 'Field Service';
            workOrder5.SVMXC__Preferred_Start_Time__c = system.now().addDays(1);
            workOrder5.SVMXC__Preferred_End_Time__c = system.now().addDays(1).addHours(2);
            workOrder5.SVMXC__Primary_Territory__c = T1.Id;
            workOrder5.SVMXC__OptiMax_status__c = '';
            workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
            workOrder5.SVMXC__Dispatch_Process__c = svmxprocess.Id;
            workOrder5.SVMXC__Locked_By_DC__c = false;
            workOrder5.SVMXC__SM_Lock_Appointment_Schedule__c = null;

            Wo_List.add(workOrder5);
            
            insert Wo_List;
            System.assertEquals(true, Wo_List != null);
            
            SMAX_OptiMax_Engine_WS.WorkOrder_WP woTEST = new SMAX_OptiMax_Engine_WS.WorkOrder_WP(workOrder1);
            
            
            SVMXC__Service_Group__c sgroup = new SVMXC__Service_Group__c();
            sgroup.SVMXC__Country__c = 'India';
            sgroup.SVMXC__City__c = 'Bangalore';
            Insert sgroup;
            
            
            List<SVMXC__Service_Group_Members__c> technicians= new List<SVMXC__Service_Group_Members__c>();
            SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c();
            tech1.SVMXC__Service_Territory__c =T1.Id;
            ////tech.SVMXC__Salesforce_User__c = UserId.Id;
            tech1.SVMXC__Fixed_Cost__c = 2.0;
            tech1.SVMXC__Latitude_Home__c = 37.407843;
            tech1.SVMXC__Longitude_Home__c = -122.008637;
            tech1.SVMXC__Street__c = 'Street 1';
            tech1.SVMXC__City__c = 'Bangalore';
            tech1.SVMXC__State__c = 'Karnataka';
            tech1.SVMXC__Zip__c = '11111111';
            tech1.SVMXC__Country__c = 'India';
            tech1.SVMXC__Per_hour_Cost__c = 2.0; 
            tech1.SVMXC__Per_Mile_Cost__c = 1.0;
            tech1.SVMXC__Average_Speed__c = 2.0;
            tech1.SVMXC__Max_Daily_Hours__c = 2.0;
            tech1.SVMXC__Max_Distance__c = 5.0;
             //tech1.SVMXC__Max_Weekly_Hours__c = 7.0;
             //tech1.SVMXC__Capacity__c = 1.0;
            tech1.SVMXC__Enable_Scheduling__c = true;
            tech1.SVMXC__Service_Group__c =sgroup.Id; 
            if(lBH != NULL && lBH.size()>0)
            tech1.SVMXC__Working_Hours__c = lBH[0].id;
            technicians.add(tech1);
            SVMXC__Service_Group_Members__c tech = new SVMXC__Service_Group_Members__c();
            tech.SVMXC__Service_Territory__c =T1.Id;
            ////tech.SVMXC__Salesforce_User__c = UserId.Id;
            tech.SVMXC__Fixed_Cost__c = 2.0;
            tech.SVMXC__Latitude_Home__c = 37.407843;
            tech.SVMXC__Longitude_Home__c = -122.008637;
            tech.SVMXC__Street__c = 'Street 1';
            tech.SVMXC__City__c = 'Bangalore';
            tech.SVMXC__State__c = 'Karnataka';
            tech.SVMXC__Zip__c = '11111111';
            tech.SVMXC__Country__c = 'India';
            tech.SVMXC__Per_hour_Cost__c = 2.0; 
            tech.SVMXC__Per_Mile_Cost__c = 1.0;
            tech.SVMXC__Average_Speed__c = 2.0;
            tech.SVMXC__Max_Daily_Hours__c = 2.0;
            tech.SVMXC__Max_Distance__c = 5.0;
            tech.SVMXC__Salesforce_User__c = UserInfo.getUserId();
            //tech.SVMXC__Max_Weekly_Hours__c = 7.0;
            //tech.SVMXC__Capacity__c = 1.0;
            tech.SVMXC__Enable_Scheduling__c = true;
            tech.SVMXC__Service_Group__c =sgroup.Id; 
            if(lBH != NULL && lBH.size()>0)
            tech.SVMXC__Working_Hours__c = lBH[0].id;
            technicians.add(tech);
            Insert technicians;
            
            List<SVMXC__SVMX_Event__c> Svmx_Event_L = new List<SVMXC__SVMX_Event__c>();
            SVMXC__SVMX_Event__c Svmx_Event = new SVMXC__SVMX_Event__c();
            Svmx_Event.SVMXC__StartDateTime__c = System.now();
            Svmx_Event.SVMXC__DurationInMinutes__c = 60;
            Svmx_Event.SVMXC__EndDateTime__c = System.now().addHours(1);
            Svmx_Event.SVMXC__WhatId__c = workOrder3.Id;
            Svmx_Event.SVMXC__Technician__c = tech.Id;
            Svmx_Event_L.add(Svmx_Event);
            
            SVMXC__SVMX_Event__c Svmx_Event2 = new SVMXC__SVMX_Event__c();
            Svmx_Event2.SVMXC__StartDateTime__c = System.now().addDays(1);
            Svmx_Event2.SVMXC__DurationInMinutes__c = 60;
            Svmx_Event2.SVMXC__EndDateTime__c = System.now().addHours(1).addDays(1);
            Svmx_Event2.SVMXC__WhatId__c = workOrder3.Id;
            Svmx_Event2.SVMXC__Technician__c = tech.Id;
            Svmx_Event_L.add(Svmx_Event2);
            
            SVMXC__SVMX_Event__c Svmx_Event3 = new SVMXC__SVMX_Event__c();
            Svmx_Event3.SVMXC__StartDateTime__c = System.now().addDays(1);
            Svmx_Event3.SVMXC__DurationInMinutes__c = 60;
            Svmx_Event3.SVMXC__EndDateTime__c = System.now().addHours(1).addDays(1);
            Svmx_Event3.SVMXC__Technician__c = tech.Id;
            Svmx_Event_L.add(Svmx_Event3);
            
            insert Svmx_Event_L;
            
            List<Event> SF_Event_L = new List<Event>();
            Event SF_Event = new Event();
            SF_Event.ActivityDate = System.today();
            SF_Event.ActivityDateTime = System.now();
            SF_Event.StartDateTime = SF_Event.ActivityDateTime;
            SF_Event.DurationInMinutes = 60;
            SF_Event.EndDateTime = System.now().addHours(1);
            SF_Event.OwnerId = UserInfo.getUserId();
            SF_Event_L.add(SF_Event);
            
            Event SF_Event2 = new Event();
            SF_Event2.ActivityDate = System.today().addDays(1);
            SF_Event2.ActivityDateTime = System.now().addDays(1);
            SF_Event2.StartDateTime = SF_Event2.ActivityDateTime;
            SF_Event2.DurationInMinutes = 60;
            SF_Event2.EndDateTime = System.now().addHours(1).addDays(1);
            SF_Event2.OwnerId = UserInfo.getUserId();
            SF_Event_L.add(SF_Event2);
            
            Event SF_Event3 = new Event();
            SF_Event3.ActivityDate = System.today().addDays(1);
            SF_Event3.ActivityDateTime = System.now().addDays(1);
            SF_Event3.StartDateTime = SF_Event3.ActivityDateTime;
            SF_Event3.DurationInMinutes = 60;
            SF_Event3.EndDateTime = System.now().addHours(1).addDays(1);
            SF_Event3.OwnerId = UserInfo.getUserId();
            SF_Event3.WhatId = workOrder3.Id;
            SF_Event_L.add(SF_Event3);
            
            insert SF_Event_L;
            
            System.assertEquals(true, SF_Event_L != null);
            
            System.debug('Just before Initiate Job:1');
            SVMXC__Skill__c sk = new SVMXC__Skill__c(Name = 'TEST');
            insert sk;
            SVMXC__Service_Group_Skills__c gmS = new SVMXC__Service_Group_Skills__c(SVMXC__Group_Member__c = tech.Id, SVMXC__Skill__c = sk.Id, SVMXC__Service_Group__c = sgroup.Id);
            insert gmS;
            Product2 prod = new Product2(Name = 'TP');
            insert prod;
            SVMXC__Service_Group_Product__c gmP = new SVMXC__Service_Group_Product__c(SVMXC__Group_Member__c = tech.Id, SVMXC__Product__c = prod.Id, SVMXC__Service_Group__c = sgroup.Id);
            insert gmP;
            System.assertEquals(true, gmP != null);
            
            SMAX_OptiMax_Engine_WS OmaxEngineWs = new SMAX_OptiMax_Engine_WS();
            System.debug('Just before Initiate Job:2');
            //Initiate Jobs
            
            List<SVMXC__SVMX_Jobs__c> lstJobs = new list<SVMXC__SVMX_Jobs__c>();

            SVMXC__SVMX_Jobs__c jobPrecalc1 = new SVMXC__SVMX_Jobs__c();
            jobPrecalc1.SVMXC__SVMX_Process__c = svmxprocess.Id;
            jobPrecalc1.SVMXC__Territory__c = T1.Id;
            jobPrecalc1.SVMXC__OptiMax_Message__c = 'Running Precalc';
            jobPrecalc1.SVMXC__Start_Time__c = system.now();
            lstJobs.add(jobPrecalc1);
            
            SVMXC__SVMX_Jobs__c jobPrecalc2 = new SVMXC__SVMX_Jobs__c();
            jobPrecalc2.SVMXC__SVMX_Process__c = svmxprocess.Id;
            jobPrecalc2.SVMXC__Territory__c = T1.Id;
            jobPrecalc2.SVMXC__OptiMax_Message__c = 'Precalc Failure';
            jobPrecalc2.SVMXC__Start_Time__c = system.now();
            lstJobs.add(jobPrecalc2);

            SVMXC__SVMX_Jobs__c job = new SVMXC__SVMX_Jobs__c();
            job.SVMXC__SVMX_Process__c = svmxprocess.Id;
            job.SVMXC__Territory__c = T1.Id;
            job.SVMXC__OptiMax_Message__c = 'QTL Completed';
            job.SVMXC__Start_Time__c = system.now();
            lstJobs.add(job);

            SVMXC__SVMX_Jobs__c job1 = new SVMXC__SVMX_Jobs__c();
            job1.SVMXC__SVMX_Process__c = svmxprocess.Id;
            job1.SVMXC__Territory__c = T1.Id;
            job1.SVMXC__OptiMax_Message__c = 'In Progress';
            job1.SVMXC__Start_Time__c = system.now().addDays(-1);
            lstJobs.add(job1);
            
            SVMXC__SVMX_Jobs__c job2 = new SVMXC__SVMX_Jobs__c();
            job2.SVMXC__SVMX_Process__c = svmxprocess.Id;
            job2.SVMXC__Territory__c = T1.Id;
            job2.SVMXC__OptiMax_Message__c = 'In Progress';
            job2.SVMXC__Start_Time__c = system.now().addDays(-2);
            lstJobs.add(job2);
            
            insert lstJobs;

            SMAX_OptiMax_Engine_WS.opInitateJobs_WP OmaxEngineWsInitjobs = new SMAX_OptiMax_Engine_WS.opInitateJobs_WP();
            OmaxEngineWsInitjobs.jobId = job.Id;
            OmaxEngineWsInitjobs.jobNo = job.Name;
            OmaxEngineWsInitjobs.status = 2;
            OmaxEngineWsInitjobs.message = job.SVMXC__OptiMax_Message__c;
            OmaxEngineWsInitjobs.sentWOCount = 0;
            OmaxEngineWsInitjobs.sentEventCount=0;
            OmaxEngineWsInitjobs.getworkOrder_LWP();
            OmaxEngineWsInitjobs.gettechnician_LWP();
            OmaxEngineWsInitjobs.getExec_SettingsMap();            
            
            SMAX_OptiMax_Engine_WS.opInitateJobs_WP initiateCall1 = SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(UserInfo.getUserId(),T1.Id,svmxprocess.Id);
            System.debug(logginglevel.WARN,'TESTLOG1: ' + initiateCall1.status + ' '+initiateCall1.jobId);
            
            if(initiateCall1.status > 0)
            {
            SMAX_OptiMax_Engine_WS.opInitateJobs_WP initiateCall2 = SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(UserInfo.getUserId(),T1.Id,initiateCall1.jobId);
            }
            SMAX_OptiMax_Engine_WS.opInitateJobs_WP initiateCall22 = SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(UserInfo.getUserId(),T1.Id,'abc'+svmxprocess.Id);
            SMAX_OptiMax_Engine_WS.opInitateJobs_WP initiateCall3 = SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(UserInfo.getUserId(),T1.Id+'_INCR',svmxprocess.Id);
            System.debug(logginglevel.WARN,'TESTLOG2: ' + initiateCall3.status);
            if(initiateCall3.status > 0)
            {
            SMAX_OptiMax_Engine_WS.opInitateJobs_WP initiateCall4 = SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(UserInfo.getUserId(),T1.Id+'_INCR',initiateCall3.jobId);
            }
            
            SMAX_OptiMax_Engine_Ext oMaxExt = new SMAX_OptiMax_Engine_Ext();
            oMaxExt.logInitiateJob(initiateCall1);
            jobId = initiateCall1.jobId;
            
            SMAX_OptiMax_Engine_WS.WorkOrder_WP OmaxEngineWsWoWp = new SMAX_OptiMax_Engine_WS.WorkOrder_WP(workOrder1);
            SMAX_OptiMax_Engine_WS.ExecutionTime_WP objExecutionTime_WP = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(System.now().addminutes(-60),System.now());
            list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstExecutionTime_WP = new list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
            lstExecutionTime_WP.add(objExecutionTime_WP);
            SMAX_OptiMax_Engine_WS.WorkOrder_WP EngineWsWoWp = new SMAX_OptiMax_Engine_WS.WorkOrder_WP(workOrder4,lstExecutionTime_WP,'',null);
            EngineWsWoWp.skill = '';
            EngineWsWoWp.product = '';
            
        }
        catch(Exception ex){
            System.debug(ex.getMessage());
        }
    }
    
    static testMethod void SMAX_OptiMax_Engine_WS_ExecutionTime_WP()
    {
        try
        {
                List<BusinessHours> lBH = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];
                System.assertEquals(true, lBH != null);
                
                for(BusinessHours bh: lBH){
                    SMAX_OptiMax_Engine_Ext.getStartEndTime(bh, 'Monday', 'StartTime');
                    SMAX_OptiMax_Engine_Ext.getStartEndTime(bh, 'Tuesday', 'StartTime');
                    SMAX_OptiMax_Engine_Ext.getStartEndTime(bh, 'Wednesday', 'StartTime');
                    SMAX_OptiMax_Engine_Ext.getStartEndTime(bh, 'Thursday', 'StartTime');
                    SMAX_OptiMax_Engine_Ext.getStartEndTime(bh, 'Friday', 'StartTime');
                    SMAX_OptiMax_Engine_Ext.getStartEndTime(bh, 'Saturday', 'StartTime');
                    SMAX_OptiMax_Engine_Ext.getStartEndTime(bh, 'Sunday', 'StartTime');
                    SMAX_OptiMax_Engine_Ext.getStartEndTime(bh, 'Monday', 'EndTime');
                    SMAX_OptiMax_Engine_Ext.getStartEndTime(bh, 'Tuesday', 'EndTime');
                    SMAX_OptiMax_Engine_Ext.getStartEndTime(bh, 'Wednesday', 'EndTime');
                    SMAX_OptiMax_Engine_Ext.getStartEndTime(bh, 'Thursday', 'EndTime');
                    SMAX_OptiMax_Engine_Ext.getStartEndTime(bh, 'Friday', 'EndTime');
                    SMAX_OptiMax_Engine_Ext.getStartEndTime(bh, 'Saturday', 'EndTime');
                    SMAX_OptiMax_Engine_Ext.getStartEndTime(bh, 'Sunday', 'EndTime');
                }
                list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> eventTime = new list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
                list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> breakTime = new list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
                SMAX_OptiMax_Engine_WS.ExecutionTime_WP ExecutionTime_T1 = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP();
                ExecutionTime_T1.startDate = datetime.newInstance(2008, 12, 1, 12, 30, 2);
                ExecutionTime_T1.endDate = datetime.newInstance(2008, 12, 1, 22, 30, 2);
                eventTime.add(ExecutionTime_T1);
                System.assertEquals(true, eventTime != null);
                
                SMAX_OptiMax_Engine_WS.ExecutionTime_WP ExecutionTime_T2 = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP();
                ExecutionTime_T2.startDate = datetime.newInstance(2008, 12, 1, 13, 30, 2);
                ExecutionTime_T2.endDate = datetime.newInstance(2008, 12, 1, 14, 30, 2);
                breakTime.add(ExecutionTime_T2);
                System.assertEquals(true, breakTime != null);
                
                SMAX_OptiMax_Engine_WS.ExecutionTime_WP ExecutionTime_T3 = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP();
                ExecutionTime_T3.startDate = datetime.newInstance(2008, 12, 1, 17, 30, 2);
                ExecutionTime_T3.endDate = datetime.newInstance(2008, 12, 1, 23, 30, 2);
                breakTime.add(ExecutionTime_T3);
        
                SMAX_OptiMax_Engine_WS.ExecutionTime_WP ExecutionTime_T4 = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP();
                ExecutionTime_T4.startDate = datetime.newInstance(2008, 12, 1, 13, 30, 2);
                ExecutionTime_T4.endDate = datetime.newInstance(2008, 12, 1, 17, 30, 2);
                eventTime.add(ExecutionTime_T4);
                System.assertEquals(true, eventTime != null);
                
                SMAX_OptiMax_Engine_WS.ExecutionTime_WP ExecutionTime_T5 = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP();
                ExecutionTime_T5.startDate = datetime.newInstance(2008, 12, 1, 10, 30, 2);
                ExecutionTime_T5.endDate = datetime.newInstance(2008, 12, 1, 13, 30, 2);
                breakTime.add(ExecutionTime_T5);
                System.assertEquals(true, breakTime != null);
                
                SMAX_OptiMax_Engine_WS.TechniciansEvents_WP techEvent = new SMAX_OptiMax_Engine_WS.TechniciansEvents_WP('T1','PR','EI', datetime.newInstance(2008, 11, 1), datetime.newInstance(2008, 12, 1), 1, 1, 1);
                ////SMAX_OptiMax_Engine_Ext.updateExecutionTime(eventTime, breakTime);
                SMAX_OptiMax_Engine_WS.Expertise_WP expt_WP = new SMAX_OptiMax_Engine_WS.Expertise_WP();
                expt_WP.id = '';
                expt_WP.name = '';              
                
                SMAX_OptiMax_Engine_WS.Product_WP prdt_WP = new SMAX_OptiMax_Engine_WS.Product_WP();
                prdt_WP.id = '';
                prdt_WP.name = '';              
                
                SMAX_OptiMax_Engine_WS.opCompleteJobs_WP compltjobs_WP = new SMAX_OptiMax_Engine_WS.opCompleteJobs_WP();
                compltjobs_WP.status = 1234;
                compltjobs_WP.statusMessage = 'message';
                compltjobs_WP.getviolations_WP();
                compltjobs_WP.setViolations_WPL(compltjobs_WP.getviolations_WP());
                
                SMAX_OptiMax_Engine_WS.TechnicianDetail_WP techdetail_WP = new SMAX_OptiMax_Engine_WS.TechnicianDetail_WP();
                techdetail_WP.technicianId = '';
                SMAX_OptiMax_Engine_WS.Location_WP loca_wp = new SMAX_OptiMax_Engine_WS.Location_WP('0','0');
                techdetail_WP.location = loca_wp;
                
                SMAX_OptiMax_Engine_WS.TotalRouteTime_WP totRoutTime_WP = new SMAX_OptiMax_Engine_WS.TotalRouteTime_WP();
                totRoutTime_WP.startTime = datetime.newInstance(2008, 12, 1, 12, 30, 2);
                totRoutTime_WP.endTime = datetime.newInstance(2008, 12, 1, 22, 30, 2);
                SMAX_OptiMax_Engine_WS.TechniciansEvents_WP techevnt_wp = new SMAX_OptiMax_Engine_WS.TechniciansEvents_WP();
                SMAX_OptiMax_Engine_WS.WorkOrderSchedule_WP woschd_wp = new SMAX_OptiMax_Engine_WS.WorkOrderSchedule_WP();
                
                SMAX_OptiMax_Engine_WS.ipCompleteJobs_WP ipcomJob_ws= new SMAX_OptiMax_Engine_WS.ipCompleteJobs_WP();
                ipcomJob_ws.jobNo = '';
                ipcomJob_ws.timeOfComp = system.now();
                ipcomJob_ws.scheduleResourceCount = Double.valueOf('12.33');
                ipcomJob_ws.errorTest = 'errorTest';
                SMAX_OptiMax_Engine_WS.Route_WP rout_wp= new SMAX_OptiMax_Engine_WS.Route_WP();
                rout_wp.routeTime = totRoutTime_WP;
                list<SMAX_OptiMax_Engine_WS.Route_WP> routeList = new list<SMAX_OptiMax_Engine_WS.Route_WP>();
                SMAX_OptiMax_Engine_WS.DestinationNodes_WP dest1 = new SMAX_OptiMax_Engine_WS.DestinationNodes_WP();
                list<SMAX_OptiMax_Engine_WS.DestinationNodes_WP> distNodeList = new list<SMAX_OptiMax_Engine_WS.DestinationNodes_WP>();
                rout_wp.setdestinationNodes_WPL(distNodeList);
                routeList.add(rout_wp);
                ipcomJob_ws.setroute_WPL(routeList);
        }
        catch(Exception ex){
            System.debug(ex.getMessage());
        }      
    }
    
    static testMethod void SMAX_OptiMax_Engine_WS_CompleteJob()
    {
        try
        {
        //Creating data 
        list<string> lstSettings = new list<string>();        
        lstSettings.add('GLOB001_GBL007');
        lstSettings.add('OMAX003_SET030');
        List<SVMXC__ServiceMax_Config_Data__c> lstSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstSettingValues = [SELECT SVMXC__Internal_Value__c, SVMXC__Setting_Unique_ID__c FROM SVMXC__ServiceMax_Config_Data__c WHERE recordType.Name = 'Setting Value'
                            AND SVMXC__Setting_Unique_ID__c IN :lstSettings
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' 
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Global'
                            ];                          
        if(('false'.equalsIgnoreCase(lstSettingValues[0].SVMXC__Internal_Value__c)) && ('false'.equalsIgnoreCase(lstSettingValues[1].SVMXC__Internal_Value__c))){
            lstSettingValues[0].SVMXC__Internal_Value__c='True';
            lstSettingValues[1].SVMXC__Internal_Value__c='True';
            upsert lstSettingValues;    
        } 
        list<string> lstSettings1 = new list<string>();          
        lstSettings1.add('OMAX003_SET032'); //batch size
        lstSettings1.add('OMAX002_SET002'); //dbl age       
        List<SVMXC__ServiceMax_Config_Data__c> lstSettingValues1 = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstSettingValues1 = [SELECT SVMXC__Internal_Value__c, SVMXC__Setting_Unique_ID__c FROM SVMXC__ServiceMax_Config_Data__c WHERE recordType.Name = 'Setting Value'
                            AND SVMXC__Setting_Unique_ID__c IN :lstSettings1
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' 
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Global'
                            ];
        lstSettingValues1[0].SVMXC__Internal_Value__c='20';
        lstSettingValues1[1].SVMXC__Internal_Value__c='60';
        upsert lstSettingValues1;
            case c = new case();
            Account account = new Account(
                                                Name = 'Account',
                                                ShippingStreet= 'ABC',
                                                ShippingCity= 'PQR ',
                                                ShippingState = 'California',
                                                ShippingPostalCode= '111',
                                                ShippingCountry= 'United States',
                                                BillingStreet= 'ABC',
                                                BillingCity= 'PQR ',
                                                BillingState = 'California',
                                                BillingPostalCode= '111',
                                                BillingCountry= 'United States'
                                                ); 
            insert account;
            System.assertEquals('Account', account.Name);
            
            List<BusinessHours> lBH = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];
            
            
            Contact contact = new Contact(LastName= 'Last',AccountId =account.Id,Email= 'test@max.com');
            insert contact;
            System.assertEquals('Last', contact.LastName);  
            
            SVMXC__Territory__c T1 = new SVMXC__Territory__c(Name= 'T1',SVMXC__Active__c =true,SVMXC__Territory_Code__c = 'T1',SVMXC__Parent_Territory__c =NULL,SVMXC__Per_Mile_Cost__c=2.0,SVMXC__Max_Distance__c=100,SVMXC__Average_Speed__c=50.0);
            insert T1;
            territoryId = T1.Id;
            RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];
            SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
            
            SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
            oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
            oConf.SVMXC__Field_Name__c = 'SVMXC__Zip__c';
            oConf.SVMXC__Display_Type__c = 'STRING';
            oConf.SVMXC__Operand__c = '11111111';
            oConf.SVMXC__Operator__c = 'eq';
            oConf.SVMXC__Expression_Rule__c =svmxprocess.Id;
            
            
            for(RecordType rt : rts) //Loop to take a record type at a time
            {
                if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                {
                   svmxprocess.RecordTypeId = rt.ID;
                }
                 
                if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                {
                   oConf.RecordTypeId = rt.ID;
                } 
            }
            
            svmxprocess.SVMXC__Territory__c = T1.Id;
            svmxprocess.SVMXC__Description__c = 'abcd';
            svmxprocess.SVMXC__Dispatch_Method__c = 'Optimized Batch';
            svmxprocess.SVMXC__Assign_Work_Order_To__c = 'Technician';
            svmxprocess.SVMXC__Calendar_Start_Type__c = 'SAME DAY';
            svmxprocess.SVMXC__Calendar_End_Type__c = 'SAME DAY';
            svmxprocess.SVMXC__Expertise_Match_Enabled__c =true;
            svmxprocess.SVMXC__Product_Match_Enabled__c =true;
            svmxprocess.SVMXC__Preferred_Tech_Enabled__c =true;
            svmxprocess.SVMXC__Route_Type__c = 'CLOSED';
            svmxprocess.SVMXC__Distance_And_Time__c = 'Actual Distance And Time';
            svmxprocess.SVMXC__Weight_Time_Window__c =1.0000;
            svmxprocess.SVMXC__Weight_Route_Distance__c =1.0000;
            svmxprocess.SVMXC__Weight_Route_Time__c =1.0000;
            svmxprocess.SVMXC__Weight_Node_Type__c =1;
            svmxprocess.SVMXC__Dispatch_Process_Status__c = 'Complete';
            svmxprocess.SVMXC__Runs_Every_Monday__c =true;
            svmxprocess.SVMXC__Runs_Every_Tuesday__c =true;
            svmxprocess.SVMXC__Start_Time__c = '11:00 PM';
            svmxprocess.SVMXC__Frequency__c =1;
            svmxprocess.SVMXC__Full_Run_Unit__c = 'Days';
            svmxprocess.SVMXC__Start_Date__c = date.Today();
            svmxprocess.SVMXC__End_Date__c = date.Today().addDays(1);
            svmxprocess.SVMXC__Weight_Total_Distance__c =1.0000;
            svmxprocess.SVMXC__Calendar_Start_Days__c = 0;
            svmxprocess.SVMXC__Calendar_End_Days__c = 2;
            svmxprocess.SVMXC__Tolerance__c = 30;
            svmxprocess.SVMXC__ProcessID__c = 'PROCESS11';
            svmxprocess.SVMXC__SettingId__c = 'PROCESS11';
            svmxprocess.SVMXC__MapID__c = 'PROCESS11';
            svmxprocess.SVMXC__Name__c = 'PROCESS22';
            Insert svmxprocess;
            dispatchprocessId = svmxprocess.Id;
            System.assertEquals(true, svmxprocess != null);
            
            insert oConf;
            System.assertEquals(true, oConf != null);
            
            List<SVMXC__Service_Order__c> Wo_List = new List<SVMXC__Service_Order__c>();
            SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
            workOrder1.SVMXC__Case__c = c.Id;
            workOrder1.SVMXC__Company__c = account.Id;
            workOrder1.SVMXC__Contact__c =contact.Id;
            workOrder1.SVMXC__Latitude__c = 40.739582;
            workOrder1.SVMXC__Longitude__c = -73.980772;
            workOrder1.SVMXC__Street__c = 'Street1';
            workOrder1.SVMXC__City__c = 'BANGALORE';
            workOrder1.SVMXC__State__c = 'Karnataka';
            workOrder1.SVMXC__Country__c = 'India';
            workOrder1.SVMXC__Zip__c = '11111111';
            workOrder1.SVMXC__Order_Status__c = 'Open';
            workOrder1.SVMXC__Priority__c = 'Medium';
            workOrder1.SVMXC__Dispatch_Priority__c = 2;
            workOrder1.SVMXC__Order_Type__c = 'Field Service';
            workOrder1.SVMXC__Apply_Business_Hours_For_OptiMax__c = false;
            workOrder1.SVMXC__Preferred_Business_Hours__c = lBH[0].Id;
            workOrder1.SVMXC__Primary_Territory__c = T1.Id;
            workOrder1.SVMXC__OptiMax_status__c = '';
            workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
            workOrder1.SVMXC__Dispatch_Process__c = svmxprocess.Id;
            workOrder1.SVMXC__Service_Duration__c = 6000;
            workOrder1.SVMXC__Locked_By_DC__c = false;
            workOrder1.SVMXC__SM_Lock_Appointment_Schedule__c = null;            
            Wo_List.add(workOrder1);
            
            SVMXC__Service_Order__c workOrder2 = new SVMXC__Service_Order__c();
            workOrder2.SVMXC__Case__c = c.Id;
            workOrder2.SVMXC__Company__c = account.Id;
            workOrder2.SVMXC__Contact__c =contact.Id;
            workOrder2.SVMXC__Latitude__c = 40.739582;
            workOrder2.SVMXC__Longitude__c = -73.980772;
            workOrder2.SVMXC__Street__c = 'Street1';
            workOrder2.SVMXC__City__c = 'BANGALORE';
            workOrder2.SVMXC__State__c = 'Karnataka';
            workOrder2.SVMXC__Country__c = 'India';
            workOrder2.SVMXC__Zip__c = '11111111';
            workOrder2.SVMXC__Order_Status__c = 'Open';
            workOrder2.SVMXC__Priority__c = 'Medium';
            workOrder2.SVMXC__Dispatch_Priority__c = 2;
            workOrder2.SVMXC__Order_Type__c = 'Field Service';
            workOrder2.SVMXC__Apply_Business_Hours_For_OptiMax__c = true;
            workOrder2.SVMXC__Preferred_Start_Time__c = system.now().addDays(-2);
            workOrder2.SVMXC__Preferred_End_Time__c = system.now().addDays(5);
            workOrder2.SVMXC__Primary_Territory__c = T1.Id;
            workOrder2.SVMXC__OptiMax_status__c = '';
            workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
            workOrder2.SVMXC__Dispatch_Process__c = svmxprocess.Id;
            workOrder2.SVMXC__Service_Duration__c = 50000;
            workOrder2.SVMXC__Locked_By_DC__c = true;
            workOrder2.SVMXC__SM_Lock_Appointment_Schedule__c = WSCH_ECO_Constants.SCHEDULE_LOCK_IN_PLACE;
            Wo_List.add(workOrder2);
            //Insert workOrder2;
            insert Wo_List;
            System.assertEquals(true, Wo_List != null);
            
            SMAX_OptiMax_Engine_WS.WorkOrder_WP woTEST = new SMAX_OptiMax_Engine_WS.WorkOrder_WP(workOrder1);
            
            
            SVMXC__Service_Group__c sgroup = new SVMXC__Service_Group__c();
            sgroup.SVMXC__Country__c = 'India';
            sgroup.SVMXC__City__c = 'Bangalore';
            Insert sgroup;
            System.assertEquals('India', sgroup.SVMXC__Country__c);
            
            
            List<SVMXC__Service_Group_Members__c> technicians= new List<SVMXC__Service_Group_Members__c>();
            SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c();
            tech1.SVMXC__Service_Territory__c =T1.Id;
            ////tech.SVMXC__Salesforce_User__c = UserId.Id;
            tech1.SVMXC__Fixed_Cost__c = 2.0;
            tech1.SVMXC__Latitude_Home__c = 37.407843;
            tech1.SVMXC__Longitude_Home__c = -122.008637;
            tech1.SVMXC__Street__c = 'Street 1';
            tech1.SVMXC__City__c = 'Bangalore';
            tech1.SVMXC__State__c = 'Karnataka';
            tech1.SVMXC__Zip__c = '11111111';
            tech1.SVMXC__Country__c = 'India';
            tech1.SVMXC__Per_hour_Cost__c = 2.0; 
            tech1.SVMXC__Per_Mile_Cost__c = 1.0;
            tech1.SVMXC__Average_Speed__c = 2.0;
            tech1.SVMXC__Max_Daily_Hours__c = 2.0;
            tech1.SVMXC__Max_Distance__c = 5.0;
            // tech1.SVMXC__Max_Weekly_Hours__c = 7.0;
            // tech1.SVMXC__Capacity__c = 1.0;
            tech1.SVMXC__Enable_Scheduling__c = true;
            tech1.SVMXC__Service_Group__c =sgroup.Id; 
            if(lBH != NULL && lBH.size()>0)
            tech1.SVMXC__Working_Hours__c = lBH[0].id;
            technicians.add(tech1);
            SVMXC__Service_Group_Members__c tech = new SVMXC__Service_Group_Members__c();
            tech.SVMXC__Service_Territory__c =T1.Id;
            ////tech.SVMXC__Salesforce_User__c = UserId.Id;
            tech.SVMXC__Fixed_Cost__c = 2.0;
            tech.SVMXC__Latitude_Home__c = 37.407843;
            tech.SVMXC__Longitude_Home__c = -122.008637;
            tech.SVMXC__Street__c = 'Street 1';
            tech.SVMXC__City__c = 'Bangalore';
            tech.SVMXC__State__c = 'Karnataka';
            tech.SVMXC__Zip__c = '11111111';
            tech.SVMXC__Country__c = 'India';
            tech.SVMXC__Per_hour_Cost__c = 2.0; 
            tech.SVMXC__Per_Mile_Cost__c = 1.0;
            tech.SVMXC__Average_Speed__c = 2.0;
            tech.SVMXC__Max_Daily_Hours__c = 2.0;
            tech.SVMXC__Max_Distance__c = 5.0;
            tech.SVMXC__Salesforce_User__c = UserInfo.getUserId();
            // tech.SVMXC__Max_Weekly_Hours__c = 7.0;
            // tech.SVMXC__Capacity__c = 1.0;
            tech.SVMXC__Enable_Scheduling__c = true;
            tech.SVMXC__Service_Group__c =sgroup.Id; 
            if(lBH != NULL && lBH.size()>0)
            tech.SVMXC__Working_Hours__c = lBH[0].id;
            technicians.add(tech);
            Insert technicians;
            
            List<Event> SF_Event_L = new List<Event>();
            Event SF_Event = new Event();
            SF_Event.ActivityDate = System.today();
            SF_Event.ActivityDateTime = System.now();
            SF_Event.StartDateTime = SF_Event.ActivityDateTime;
            SF_Event.DurationInMinutes = 60;
            SF_Event.EndDateTime = System.now().addHours(1);
            SF_Event.OwnerId = UserInfo.getUserId();
            SF_Event_L.add(SF_Event);
            Event SF_Event2 = new Event();
            SF_Event2.ActivityDate = System.today().addDays(1);
            SF_Event2.ActivityDateTime = System.now().addDays(1);
            SF_Event2.StartDateTime = SF_Event2.ActivityDateTime;
            SF_Event2.DurationInMinutes = 60;
            SF_Event2.EndDateTime = System.now().addHours(1).addDays(1);
            SF_Event2.OwnerId = UserInfo.getUserId();
            SF_Event_L.add(SF_Event2);
            insert SF_Event_L;
            System.assertEquals(true, SF_Event_L != null);
            
            System.debug('Just before Initiate Job:1');
            SVMXC__Skill__c sk = new SVMXC__Skill__c(Name = 'TEST');
            insert sk;
            SVMXC__Service_Group_Skills__c gmS = new SVMXC__Service_Group_Skills__c(SVMXC__Group_Member__c = tech.Id, SVMXC__Skill__c = sk.Id, SVMXC__Service_Group__c = sgroup.Id);
            insert gmS;
            Product2 prod = new Product2(Name = 'TP');
            insert prod;
            SVMXC__Service_Group_Product__c gmP = new SVMXC__Service_Group_Product__c(SVMXC__Group_Member__c = tech.Id, SVMXC__Product__c = prod.Id, SVMXC__Service_Group__c = sgroup.Id);
            insert gmP;
            
            SMAX_OptiMax_Engine_WS OmaxEngineWs = new SMAX_OptiMax_Engine_WS();
            System.debug('Just before Initiate Job:2');
            //Initiate Jobs

            SMAX_OptiMax_Engine_WS.opInitateJobs_WP initiateCall1 = SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(UserInfo.getUserId(),T1.Id,svmxprocess.Id);
            
            jobId = initiateCall1.jobId;
            initiateCall1.gettechnicianEvent_LWP();
            ////SMAX_OptiMax_Engine_WS.WorkOrder_WP OmaxEngineWsWoWp = new SMAX_OptiMax_Engine_WS.WorkOrder_WP(Wo);
            SVMXC__Service_Group_Members__c t = new SVMXC__Service_Group_Members__c();
            List<Time> ListeventTime = new List<Time>();
            List<Product2> products = new List<Product2>();
            List<SVMXC__Service_Group_Skills__c> skills = new List<SVMXC__Service_Group_Skills__c>();
            
            SMAX_OptiMax_Engine_WS.ExecutionTime_WP OmaxEngineWsET = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP();
            List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstWsET = new List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
            SMAX_OptiMax_Engine_WS.Product_WP OmaxEngineWsProd = new SMAX_OptiMax_Engine_WS.Product_WP();
            List<SMAX_OptiMax_Engine_WS.Product_WP> lstprodwp = new List<SMAX_OptiMax_Engine_WS.Product_WP>();
            SMAX_OptiMax_Engine_WS.Expertise_WP OmaxEngineWsExp = new SMAX_OptiMax_Engine_WS.Expertise_WP();
            List<SMAX_OptiMax_Engine_WS.Expertise_WP> lstExpwp = new List<SMAX_OptiMax_Engine_WS.Expertise_WP>();
            
            SMAX_OptiMax_Engine_WS.Technician_WP OmaxEngineWsTechws = new SMAX_OptiMax_Engine_WS.Technician_WP(t,lstWsET,lstprodwp,lstExpwp); 
            OmaxEngineWsTechws.gettechProduct_WPL();
            OmaxEngineWsTechws.gettechExpertise_WPL();
            SMAX_OptiMax_Engine_WS.ExcSetting_WP OmaxEngineWsEset = new SMAX_OptiMax_Engine_WS.ExcSetting_WP();
            
            //Oncomplete Jobs WS
            List<SVMXC__SVMX_Jobs__c> lstJobs = new list<SVMXC__SVMX_Jobs__c>();
            SVMXC__SVMX_Jobs__c jobs = new SVMXC__SVMX_Jobs__c();
            jobs.SVMXC__SVMX_Process__c = svmxprocess.Id;
            jobs.SVMXC__Territory__c = T1.Id;
            jobs.SVMXC__Age__c = 2000;
            jobs.SVMXC__Start_Time__c =system.now();
            jobs.SVMXC__OptiMax_Message__c = 'In Progress';
            jobs.SVMXC__End_Time__c =  system.now().addDays(1);
            jobs.SVMXC__Message__c = workOrder1.Id+'~|~'+SF_Event_L[0].Id;
            lstJobs.add(jobs);
            
            SVMXC__SVMX_Jobs__c job1 = new SVMXC__SVMX_Jobs__c();
            job1.SVMXC__SVMX_Process__c = svmxprocess.Id;
            job1.SVMXC__Territory__c = T1.Id;
            job1.SVMXC__OptiMax_Message__c = 'In Progress';
            job1.SVMXC__Start_Time__c = system.now();
            lstJobs.add(job1);
            
            SVMXC__SVMX_Jobs__c job2 = new SVMXC__SVMX_Jobs__c();
            job2.SVMXC__SVMX_Process__c = svmxprocess.Id;
            job2.SVMXC__Territory__c = T1.Id;
            job2.SVMXC__OptiMax_Message__c = 'In Progress';
            job2.SVMXC__Start_Time__c = system.now().addDays(-2);
            lstJobs.add(job2);
            
            insert lstJobs;
            System.assertEquals(true, jobs != null);
            
            String strBadWorkOrderDetails='{"workItemName":"'+workOrder1.Name+'","workItemId":"'+workOrder1.Id+'","errorDetails":[{"errorType":"Dispatch Parameter Error","errorMessage":"Invalid Service Duration"},{"errorType":"Dispatch Parameter Error","errorMessage":"Invalid Zipcode"},{"errorType":"QTL Error","errorMessage":"Workorder disallowed due to No Qualified Technicians computed."}]};';
            
            SVMXC__SVMX_Jobs__c inProgressJob = new SVMXC__SVMX_Jobs__c(SVMXC__SVMX_Process__c = dispatchprocessId, SVMXC__Territory__c = territoryId, SVMXC__OptiMax_Message__c = 'In Progress');        
            insert inProgressJob;  

            // Attachment objBadWorkOrderAttach = new Attachment(Name = 'Invalid WorkOrders', ParentId = jobId, Body = Blob.valueOf(strBadWorkOrderDetails), IsPrivate = TRUE);
            
            Attachment objBadWorkOrderAttach = new Attachment(Name = 'Invalid WorkOrders', ParentId = inProgressJob.Id, Body = Blob.valueOf(strBadWorkOrderDetails), IsPrivate = TRUE);
            insert objBadWorkOrderAttach;
            
            
            SMAX_OptiMax_Engine_WS.opInitateJobs_WP OmaxEngineWsInitjobs = new SMAX_OptiMax_Engine_WS.opInitateJobs_WP();
            OmaxEngineWsInitjobs.jobId = jobs.Id;
            OmaxEngineWsInitjobs.jobNo = jobs.Name;
            OmaxEngineWsInitjobs.status = 2;
            OmaxEngineWsInitjobs.message = jobs.SVMXC__OptiMax_Message__c;
            OmaxEngineWsInitjobs.sentWOCount = 0;
            OmaxEngineWsInitjobs.sentEventCount=0;
            OmaxEngineWsInitjobs.getworkOrder_LWP();
            OmaxEngineWsInitjobs.gettechnician_LWP();
            OmaxEngineWsInitjobs.getExec_SettingsMap();            
            //Violation info
            List<SMAX_OptiMax_Engine_WS.Violations_WP> woViolations = new List<SMAX_OptiMax_Engine_WS.Violations_WP>();
            SMAX_OptiMax_Engine_WS.Violations_WP woViolation = new SMAX_OptiMax_Engine_WS.Violations_WP();
            woViolation.attribute='Node';
            woViolation.category='Time Constraints';
            woViolation.value='Time Exceded';
            woViolations.add(woViolation);
            
            //Desination info
            SMAX_OptiMax_Engine_WS.DestinationNodes_WP dest1 = new SMAX_OptiMax_Engine_WS.DestinationNodes_WP();
            dest1.sequenceNo = 1;
            dest1.workorderId = workOrder1.Id;
            dest1.arraivalTime = system.now()-10;
            dest1.departureTime = system.now()-5;
            dest1.drivingTime = 5;
            dest1.violations_WPL=woViolations;
            dest1.idleTime = Double.valueOf('23.44');
            List<SMAX_OptiMax_Engine_WS.DestinationNodes_WP> dest_O1 = new List<SMAX_OptiMax_Engine_WS.DestinationNodes_WP>();
            dest_O1.add(dest1);
            //Desination info
            SMAX_OptiMax_Engine_WS.DestinationNodes_WP dest2 = new SMAX_OptiMax_Engine_WS.DestinationNodes_WP();
            dest2.sequenceNo = 1;
            dest2.workorderId = workOrder2.Id + '_' + SF_Event2.Id;
            dest2.arraivalTime = system.now()-10;
            dest2.departureTime = system.now()-5;
            dest2.drivingTime = 5;
            dest2.violations_WPL=woViolations;
            List<SMAX_OptiMax_Engine_WS.DestinationNodes_WP> dest_O2 = new List<SMAX_OptiMax_Engine_WS.DestinationNodes_WP>();
            dest_O2.add(dest2);
            
            //Route Info
            SMAX_OptiMax_Engine_WS.Route_WP route1 = new SMAX_OptiMax_Engine_WS.Route_WP();
            route1.routeId = 'ROUTE1';
            route1.resourceId = tech.Id+'_DAY1';
            route1.destinationNodes_WPL = dest_O1;
            
            //Route Info
            SMAX_OptiMax_Engine_WS.Route_WP route2 = new SMAX_OptiMax_Engine_WS.Route_WP();
            route2.routeId = 'ROUTE1';
            route2.resourceId = tech1.Id+'_DAY1';
            route2.destinationNodes_WPL = dest_O2;
            
            List<SMAX_OptiMax_Engine_WS.Route_WP> routes = new List<SMAX_OptiMax_Engine_WS.Route_WP>();
            routes.add(route1);
            routes.add(route2);
            
            SMAX_OptiMax_Engine_WS.ipCompleteJobs_WP OmaxEngineWsipcompjobs = new SMAX_OptiMax_Engine_WS.ipCompleteJobs_WP();
            OmaxEngineWsipcompjobs.dispatchProcessId = svmxprocess.Id; 
            OmaxEngineWsipcompjobs.territoryId = T1.Id;
            OmaxEngineWsipcompjobs.jobId = jobs.id;
            OmaxEngineWsipcompjobs.gettotalRouteTime_WP();
            OmaxEngineWsipcompjobs.settotalRouteTime_WP(OmaxEngineWsipcompjobs.totalRouteTime_WP);
            OmaxEngineWsipcompjobs.route_WPL=routes;
            System.debug('TEST LOG101:'+OmaxEngineWsipcompjobs.getroute_WPL());
            OmaxEngineWsipcompjobs.getstatics_WPL();
            OmaxEngineWsipcompjobs.setstatics_WPL(OmaxEngineWsipcompjobs.statics_WPL);
            OmaxEngineWsipcompjobs.getexeLog_WPL();
            OmaxEngineWsipcompjobs.setexeLog_WPL(OmaxEngineWsipcompjobs.exeLog_WPL);
            
            List<SMAX_OptiMax_Engine_WS.WorkOrderDetail_WP> WO_LatLng_L = new List<SMAX_OptiMax_Engine_WS.WorkOrderDetail_WP>();
            SMAX_OptiMax_Engine_WS.WorkOrderDetail_WP WO_LatLng = new SMAX_OptiMax_Engine_WS.WorkOrderDetail_WP();
            WO_LatLng.workOrderId = workOrder2.Id;
            WO_LatLng.location = new SMAX_OptiMax_Engine_WS.Location_WP('0','0');
            WO_LatLng_L.add(WO_LatLng);
            OmaxEngineWsipcompjobs.workOrder_WPL = WO_LatLng_L;
            
            SMAX_OptiMax_Engine_WS.TotalRouteTime_WP OmaxEngineWsTrTime = new SMAX_OptiMax_Engine_WS.TotalRouteTime_WP();
            SMAX_OptiMax_Engine_WS.Route_WP OmaxEngineWsRWP = new SMAX_OptiMax_Engine_WS.Route_WP();
            OmaxEngineWsRWP.routeId= 'abcd';
            OmaxEngineWsRWP.resourceId= 'abcd';
                   
            OmaxEngineWsRWP.getviolations_WPL();
            OmaxEngineWsRWP.setviolations_WPL(OmaxEngineWsRWP.getviolations_WPL());
            OmaxEngineWsRWP.getdestinationNodes_WPL();

            SMAX_OptiMax_Engine_WS.DestinationNodes_WP  OmaxEngineWsDnwp= new SMAX_OptiMax_Engine_WS.DestinationNodes_WP();
            OmaxEngineWsDnwp.violations_WPL=woViolations;
            OmaxEngineWsDnwp.workorderId=workOrder1.Id;
            OmaxEngineWsDnwp.getviolations_WP();
            OmaxEngineWsDnwp.setviolations_WPL(OmaxEngineWsDnwp.getviolations_WP());
            
            ////SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(UserId.Id,T1.Id,svmxprocess.Id);
            SMAX_OptiMax_Engine_WS.SMAX_Complete_OptiMax_Job_WS(OmaxEngineWsipcompjobs);
            
            OmaxEngineWsipcompjobs.scheduleWOCount = -1;
            List<SMAX_OptiMax_Engine_WS.ExeLog_WP> lstOmaxEngineWsELp = new List<SMAX_OptiMax_Engine_WS.ExeLog_WP>();
            List<SMAX_OptiMax_Engine_WS.Statics_WP> lstOmaxEngineWsStsp = new List<SMAX_OptiMax_Engine_WS.Statics_WP>();
            
            SMAX_OptiMax_Engine_WS.Statics_WP OmaxEngineWsSwp = new SMAX_OptiMax_Engine_WS.Statics_WP();
            OmaxEngineWsSwp.statName = 'Input Work Order Count';
            OmaxEngineWsSwp.value = '4.0';
            OmaxEngineWsSwp.units = 10;
            OmaxEngineWsSwp.unit = 'count';
            SMAX_OptiMax_Engine_WS.ExeLog_WP OmaxEngineWsELp = new SMAX_OptiMax_Engine_WS.ExeLog_WP();
            OmaxEngineWsELp.logLevel = -1;
            OmaxEngineWsELp.message = 'No work orders available';
            SMAX_OptiMax_Engine_WS.ExeLog_WP OmaxEngineWsELp2 = new SMAX_OptiMax_Engine_WS.ExeLog_WP();
            OmaxEngineWsELp.logLevel = -2;
            OmaxEngineWsELp.message = 'No technicians available';
            SMAX_OptiMax_Engine_WS.ExeLog_WP OmaxEngineWsELp3 = new SMAX_OptiMax_Engine_WS.ExeLog_WP();
            OmaxEngineWsELp.logLevel = -3;
            OmaxEngineWsELp.message = 'No events available';
            lstOmaxEngineWsELp.add(OmaxEngineWsELp);
            lstOmaxEngineWsELp.add(OmaxEngineWsELp2);
            lstOmaxEngineWsELp.add(OmaxEngineWsELp3);
            lstOmaxEngineWsStsp.add(OmaxEngineWsSwp);
            SMAX_OptiMax_Engine_WS.WorkOrderDetail_WP OmaxEngineWsODl = new SMAX_OptiMax_Engine_WS.WorkOrderDetail_WP();
            SMAX_OptiMax_Engine_WS.TechnicianDetail_WP OmaxEngineWsOD2 = new SMAX_OptiMax_Engine_WS.TechnicianDetail_WP();
            SMAX_OptiMax_Engine_WS.TechnicianAdditonalDetails_WP techAdditionalDetailsWP = new SMAX_OptiMax_Engine_WS.TechnicianAdditonalDetails_WP();
            OmaxEngineWsipcompjobs.exeLog_WPL = lstOmaxEngineWsELp;
            OmaxEngineWsipcompjobs.statics_WPL = lstOmaxEngineWsStsp;
            SMAX_OptiMax_Engine_WS.SMAX_Complete_OptiMax_Job_WS(OmaxEngineWsipcompjobs);
            
            
            List<SMAX_OptiMax_Engine_WS.Status_WP> lstOmaxEngineWsStatusp = new List<SMAX_OptiMax_Engine_WS.Status_WP>();
            SMAX_OptiMax_Engine_WS.Status_WP OmaxEngineWstp = new SMAX_OptiMax_Engine_WS.Status_WP();
            OmaxEngineWstp.event = '';
            OmaxEngineWstp.message = '';
            OmaxEngineWstp.tag = '';
            lstOmaxEngineWsStatusp.add(OmaxEngineWstp);
            OmaxEngineWsipcompjobs.workOrderError_WPL = lstOmaxEngineWsStatusp;
            
            //Coverage for method SMAX_Run_Precalc_WS
            //Create the Key-Value pair for input parameter
            list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
            SVMXC.SMAX_OptiMax_Engine_WS.KeyValue DPKeyVal = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
            SVMXC.SMAX_OptiMax_Engine_WS.KeyValue TEKeyVal = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
            DPKeyVal.name = 'DISPATCHPROCESSID';
            DPKeyVal.value = dispatchprocessId;
            TEKeyVal.name = 'TERRITORYID';
            TEKeyVal.value = T1.Id + '_FULL';
            keyValuePairs.add(DPKeyVal);
            keyValuePairs.add(TEKeyVal);
            SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs);
            //Coverage for method SMAX_Get_OptiMax_ErrorWO_WS
            list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs1 = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
            keyValuePairs1.add(TEKeyVal);
            SMAX_OptiMax_Engine_WS.SMAX_Get_OptiMax_ErrorWO_WS(keyValuePairs1);
            //Coverage for method SMAX_Get_Job_Status_WS
            SVMXC__SVMX_Jobs__c smaxJob = new SVMXC__SVMX_Jobs__c();
            smaxJob.SVMXC__Status__c = '100';
            insert smaxJob;
            list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs2 = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
            SVMXC.SMAX_OptiMax_Engine_WS.KeyValue jobKeyVal = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
            jobKeyVal.name = 'ServiceMaxJobId';
            jobKeyVal.value = smaxJob.id;
            keyValuePairs2.add(jobKeyVal);
            SMAX_OptiMax_Engine_WS.SMAX_Get_Job_Status_WS(keyValuePairs2);
        }
        catch(Exception ex){
              System.debug(logginglevel.WARN, ex.getMessage());
        }
    }
    
    static testMethod void SMAX_OptiMax_Engine_WS_UnitTest2()
    {
        //Creating data 
        list<string> lstSettings = new list<string>();        
        lstSettings.add('GLOB001_GBL007');
        lstSettings.add('OMAX003_SET030');
        List<SVMXC__ServiceMax_Config_Data__c> lstSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstSettingValues = [SELECT SVMXC__Internal_Value__c, SVMXC__Setting_Unique_ID__c FROM SVMXC__ServiceMax_Config_Data__c WHERE recordType.Name = 'Setting Value'
                            AND SVMXC__Setting_Unique_ID__c IN :lstSettings
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' 
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Global'
                            ];                          
        if(('false'.equalsIgnoreCase(lstSettingValues[0].SVMXC__Internal_Value__c)) && ('false'.equalsIgnoreCase(lstSettingValues[1].SVMXC__Internal_Value__c))){
            lstSettingValues[0].SVMXC__Internal_Value__c='True';
            lstSettingValues[1].SVMXC__Internal_Value__c='True';
            upsert lstSettingValues;    
        } 
        case c = new case();
        Account account = new Account(
                                                Name = 'Account',
                                                ShippingStreet= 'ABC',
                                                ShippingCity= 'PQR ',
                                                ShippingState = 'California',
                                                ShippingPostalCode= '111',
                                                ShippingCountry= 'United States',
                                                BillingStreet= 'ABC',
                                                BillingCity= 'PQR ',
                                                BillingState = 'California',
                                                BillingPostalCode= '111',
                                                BillingCountry= 'United States'
                                                ); 
        insert account;
        System.assertEquals('Account', account.Name);
        
        List<BusinessHours> lBH = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];
        
        
        Contact contact = new Contact(LastName= 'Last',AccountId =account.Id,Email= 'test@max.com');
        insert contact;
        System.assertEquals('Last', contact.LastName);
        SVMXC__Territory__c Territory2 = new SVMXC__Territory__c(Name= 'Territory2',SVMXC__Active__c =true,SVMXC__Territory_Code__c = 'Territory2',SVMXC__Parent_Territory__c =NULL,SVMXC__Per_Mile_Cost__c=1.0,SVMXC__Max_Distance__c=5,SVMXC__Average_Speed__c=70.0);
        insert Territory2;
        
        territoryId = Territory2.Id;
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType];
        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        
        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c = 'SVMXC__Zip__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c = '11111111';
        oConf.SVMXC__Operator__c = 'eq';
        oConf.SVMXC__Expression_Rule__c = svmxprocess.Id;
        
        
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
            {
               svmxprocess.RecordTypeId = rt.ID;
            } 
             
            if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
            {
               oConf.RecordTypeId = rt.ID;
            } 
        }
        
        svmxprocess.SVMXC__Territory__c = Territory2.Id;
        svmxprocess.SVMXC__Description__c = 'abcd';
        svmxprocess.SVMXC__Dispatch_Method__c = 'Optimized Batch';
        svmxprocess.SVMXC__Assign_Work_Order_To__c = 'Technician';
        svmxprocess.SVMXC__Calendar_Start_Type__c = 'SAME DAY';
        svmxprocess.SVMXC__Calendar_End_Type__c = 'SAME DAY';
        svmxprocess.SVMXC__Expertise_Match_Enabled__c =true;
        svmxprocess.SVMXC__Product_Match_Enabled__c =true;
        svmxprocess.SVMXC__Preferred_Tech_Enabled__c =true;
        svmxprocess.SVMXC__Route_Type__c = 'CLOSED';
        svmxprocess.SVMXC__Distance_And_Time__c = 'Actual Distance And Time';
        svmxprocess.SVMXC__Weight_Time_Window__c =1.0000;
        svmxprocess.SVMXC__Weight_Route_Distance__c =1.0000;
        svmxprocess.SVMXC__Weight_Route_Time__c =1.0000;
        svmxprocess.SVMXC__Weight_Node_Type__c =1;
        svmxprocess.SVMXC__Dispatch_Process_Status__c = 'Complete';
        svmxprocess.SVMXC__Runs_Every_Monday__c =true;
        svmxprocess.SVMXC__Runs_Every_Tuesday__c =true;
        svmxprocess.SVMXC__Start_Time__c = '11:00 PM';
        svmxprocess.SVMXC__Frequency__c =1;
        svmxprocess.SVMXC__Full_Run_Unit__c = 'Days';
        svmxprocess.SVMXC__Start_Date__c = date.Today();
        svmxprocess.SVMXC__End_Date__c = date.Today().addDays(1);
        svmxprocess.SVMXC__Weight_Total_Distance__c =1.0000;
        svmxprocess.SVMXC__Calendar_Start_Days__c = 0;
        svmxprocess.SVMXC__Calendar_End_Days__c = 2;
        svmxprocess.SVMXC__Tolerance__c = 30;
        svmxprocess.SVMXC__ProcessID__c = 'PROCESS11';
        svmxprocess.SVMXC__SettingId__c = 'PROCESS11';
        svmxprocess.SVMXC__MapID__c = 'PROCESS11';
        svmxprocess.SVMXC__Name__c = 'PROCESS22';
        Insert svmxprocess;
        dispatchprocessId = svmxprocess.Id;
        
        list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue DPKeyVal = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue TEKeyVal = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue TEKeyVal1 = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        DPKeyVal.name = 'DISPATCHPROCESSID';
        DPKeyVal.value = dispatchprocessId;
        keyValuePairs.add(DPKeyVal);
        TEKeyVal.name = 'TERRITORYID';
        TEKeyVal.value = Territory2.Id + '_FULL';
        TEKeyVal1.name = 'TERRITORYID';
        TEKeyVal1.value = Territory2.Id + '_INCR';

        SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs);
        
        keyValuePairs.add(TEKeyVal);
        SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs);

        keyValuePairs.add(TEKeyVal1);
        SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs);
        
        SVMXC__SVMX_Jobs__c precalcCompletedJob = new SVMXC__SVMX_Jobs__c(SVMXC__SVMX_Process__c = dispatchprocessId, SVMXC__Territory__c = Territory2.Id, SVMXC__OptiMax_Message__c = 'Precalc Completed');
        SVMXC__SVMX_Jobs__c precalcCompletedJob4 = new SVMXC__SVMX_Jobs__c(SVMXC__SVMX_Process__c = dispatchprocessId, SVMXC__Territory__c = Territory2.Id, SVMXC__OptiMax_Message__c = 'Precalc Failure');
        SVMXC__SVMX_Jobs__c precalcCompletedJob5 = new SVMXC__SVMX_Jobs__c(SVMXC__SVMX_Process__c = dispatchprocessId, SVMXC__Territory__c = Territory2.Id, SVMXC__OptiMax_Message__c = 'Running Precalc');
        List<SVMXC__SVMX_Jobs__c> lstPrecalcJobs = new List<SVMXC__SVMX_Jobs__c>();
        lstPrecalcJobs.add(precalcCompletedJob);
        lstPrecalcJobs.add(precalcCompletedJob4);
        lstPrecalcJobs.add(precalcCompletedJob5);
        insert lstPrecalcJobs;
        
        list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs1 = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue DPKeyVal1 = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        DPKeyVal1.name = 'DISPATCHPROCESSID';
        DPKeyVal1.value = dispatchprocessId;
         keyValuePairs1.add(DPKeyVal1);
        SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs1);
        
        list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs2 = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue TEKeyVal2 = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        TEKeyVal2.name = 'TERRITORYID';
        TEKeyVal2.value = Territory2.Id + '_FULL';
        keyValuePairs1.add(TEKeyVal2);
        SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs2);
        
        list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs3 = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue TEKeyVal3 = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        TEKeyVal3.name = 'TERRITORYID';
        TEKeyVal3.value = Territory2.Id + '_INCR';
        keyValuePairs3.add(TEKeyVal3);
       SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs3);
        
        SVMXC__Service_Order__c workOrderQTL = new SVMXC__Service_Order__c();
        workOrderQTL.SVMXC__Case__c = c.Id;
        workOrderQTL.SVMXC__Company__c = account.Id;
        workOrderQTL.SVMXC__Contact__c =contact.Id;
        workOrderQTL.SVMXC__Latitude__c = 40.739582;
        workOrderQTL.SVMXC__Longitude__c = -73.980772;
        workOrderQTL.SVMXC__Street__c = 'Street1';
        workOrderQTL.SVMXC__City__c = 'BANGALORE';
        workOrderQTL.SVMXC__State__c = 'Karnataka';
        workOrderQTL.SVMXC__Country__c = 'India';
        workOrderQTL.SVMXC__Zip__c = '11111111';
        workOrderQTL.SVMXC__Order_Status__c = 'Open';
        workOrderQTL.SVMXC__Priority__c = 'Medium';
        workOrderQTL.SVMXC__Dispatch_Priority__c = 2;
        workOrderQTL.SVMXC__Order_Type__c = 'Field Service';
        workOrderQTL.SVMXC__Apply_Business_Hours_For_OptiMax__c = false;
        workOrderQTL.SVMXC__Preferred_Business_Hours__c = lBH[0].Id;
        workOrderQTL.SVMXC__Primary_Territory__c = Territory2.Id;
        workOrderQTL.SVMXC__OptiMax_status__c = 'OPT_COMPLETED';
        workOrderQTL.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrderQTL.SVMXC__Dispatch_Process__c = dispatchprocessId;
        workOrderQTL.SVMXC__Service_Duration__c = 6000;
        workOrderQTL.SVMXC__Locked_By_DC__c = false;
        workOrderQTL.SVMXC__SM_Lock_Appointment_Schedule__c = null;
        workOrderQTL.SVMXC__Scheduled_Date_Time__c  = system.now().addDays(3);
        insert workOrderQTL;
        
        //Create technicans
        SVMXC__Service_Group__c sgroup = new SVMXC__Service_Group__c();
        sgroup.SVMXC__Country__c = 'India';
        sgroup.SVMXC__City__c = 'Bangalore';
        Insert sgroup;
        System.assertEquals('India', sgroup.SVMXC__Country__c);
        
        SVMXC__Skill__c objSkillnstallation = new SVMXC__Skill__c();
        objSkillnstallation.Name = 'SkillInstall2';
        objSkillnstallation.SVMXC__Skill_Category__c = 'Installation';
        insert objSkillnstallation;
        
        List<SVMXC__Service_Group_Members__c> technicians= new List<SVMXC__Service_Group_Members__c>();
        SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c();
        tech1.SVMXC__Service_Territory__c =Territory2.Id;
        tech1.SVMXC__Fixed_Cost__c = 2.0;
        tech1.SVMXC__Latitude_Home__c = 37.407843;
        tech1.SVMXC__Longitude_Home__c = -122.008637;
        tech1.SVMXC__Street__c = 'Street 1';
        tech1.SVMXC__City__c = 'Bangalore';
        tech1.SVMXC__State__c = 'Karnataka';
        tech1.SVMXC__Zip__c = '11111111';
        tech1.SVMXC__Country__c = 'India';
        tech1.SVMXC__Per_hour_Cost__c = 2.0; 
        tech1.SVMXC__Per_Mile_Cost__c = 1.0;
        tech1.SVMXC__Average_Speed__c = 2.0;
        tech1.SVMXC__Max_Daily_Hours__c = 2.0;
        tech1.SVMXC__Max_Distance__c = 5.0;
        tech1.SVMXC__Enable_Scheduling__c = true;
        tech1.SVMXC__Service_Group__c =sgroup.Id; 
        if(lBH != NULL && lBH.size()>0)
            tech1.SVMXC__Working_Hours__c = lBH[0].id;
        tech1.SVMXC__Active__c  = true;
        technicians.add(tech1);

        SVMXC__Service_Group_Members__c tech = new SVMXC__Service_Group_Members__c();
        tech.SVMXC__Service_Territory__c = Territory2.Id;
        tech.SVMXC__Fixed_Cost__c = 2.0;
        tech.SVMXC__Latitude_Home__c = 37.407843;
        tech.SVMXC__Longitude_Home__c = -122.008637;
        tech.SVMXC__Street__c = 'Street 1';
        tech.SVMXC__City__c = 'Bangalore';
        tech.SVMXC__State__c = 'Karnataka';
        tech.SVMXC__Zip__c = '11111111';
        tech.SVMXC__Country__c = 'India';
        tech.SVMXC__Per_hour_Cost__c = 2.0; 
        tech.SVMXC__Per_Mile_Cost__c = 1.0;
        tech.SVMXC__Average_Speed__c = 2.0;
        tech.SVMXC__Max_Daily_Hours__c = 2.0;
        tech.SVMXC__Max_Distance__c = 5.0;
        tech.SVMXC__Salesforce_User__c = UserInfo.getUserId();
        tech.SVMXC__Enable_Scheduling__c = true;
        tech.SVMXC__Service_Group__c = sgroup.Id; 
        tech.SVMXC__Active__c  = true;
        if(lBH != NULL && lBH.size()>0)
            tech.SVMXC__Working_Hours__c = lBH[0].id;
        technicians.add(tech);
        Insert technicians;
        
        SVMXC__Service_Group_Skills__c skillForTech = new SVMXC__Service_Group_Skills__c(SVMXC__Service_Group__c = sgroup.Id, SVMXC__Skill__c = objSkillnstallation.Id);
        insert skillForTech;

        //Create Eligibility Matching Rules
        Id eligibilityProcessId;
        Id eligibilityExpressionId;
        Id skillProcessId;
        Id skillExpressionId;
        Id applicableSkillRectypeId;
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'SVMX Rule' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
            {
                eligibilityProcessId = rt.Id;
                skillProcessId = rt.Id;
            }
             
            if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
            {
                eligibilityExpressionId = rt.Id;
                skillExpressionId = rt.Id;
            }
            if(rt.Name == 'Applicable Skills' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
            {
                applicableSkillRectypeId = rt.Id;
            }
        }
        
        list<SVMXC__ServiceMax_Processes__c> lstRuleProcess = new list<SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Config_Data__c> lstRuleExpressionConf = new list<SVMXC__ServiceMax_Config_Data__c>();
        
        SVMXC__ServiceMax_Processes__c objEligibilityRule_1 = new SVMXC__ServiceMax_Processes__c();
        objEligibilityRule_1.RecordTypeId = eligibilityProcessId;
        objEligibilityRule_1.SVMXC__Rule_Type__c = 'Tech Eligibility';
        objEligibilityRule_1.SVMXC__Name__c = 'Eligibility Rule Test1';
        objEligibilityRule_1.SVMXC__Description__c = 'Eligibility Rule Test1';
        objEligibilityRule_1.SVMXC__Select__c = true;
        objEligibilityRule_1.SVMXC__Rule_Type__c = 'Tech Eligibility';
        objEligibilityRule_1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objEligibilityRule_1.SVMXC__Sequence__c = 1.0000;
        lstRuleProcess.add(objEligibilityRule_1);
        
        SVMXC__ServiceMax_Processes__c objSkillMatchingRule_1 = new SVMXC__ServiceMax_Processes__c();
        objSkillMatchingRule_1.SVMXC__Name__c = 'Skill Rule Test1';
        objSkillMatchingRule_1.SVMXC__Description__c = 'Skill Rule Test1';
        objSkillMatchingRule_1.SVMXC__Select__c = true;               
        objSkillMatchingRule_1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objSkillMatchingRule_1.SVMXC__Sequence__c = 0.0000;
        objSkillMatchingRule_1.SVMXC__Rule_Type__c = 'Skill Matching';
        objSkillMatchingRule_1.RecordTypeId = skillProcessId;
        lstRuleProcess.add(objSkillMatchingRule_1);
        
        SVMXC__ServiceMax_Processes__c objEligibilityRule_2 = new SVMXC__ServiceMax_Processes__c();
        objEligibilityRule_2.RecordTypeId = eligibilityProcessId;
        objEligibilityRule_2.SVMXC__Rule_Type__c = 'Tech Eligibility';
        objEligibilityRule_2.SVMXC__Name__c = 'Eligibility Rule Test2';
        objEligibilityRule_2.SVMXC__Description__c = 'Eligibility Rule Test2';
        objEligibilityRule_2.SVMXC__Select__c = false;
        objEligibilityRule_2.SVMXC__Sequence__c = 2.0000;
        objEligibilityRule_2.SVMXC__Rule_Type__c = 'Tech Eligibility';
        objEligibilityRule_2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        lstRuleProcess.add(objEligibilityRule_2);
        
        insert lstRuleProcess;
        
        SVMXC__ServiceMax_Processes__c objSkillMatchingRule_2 = new SVMXC__ServiceMax_Processes__c();
        objSkillMatchingRule_2.SVMXC__Name__c = 'Skill Rule Test2';
        objSkillMatchingRule_2.SVMXC__Description__c = 'Skill Rule Test2';
        objSkillMatchingRule_2.SVMXC__Select__c = false;
        objSkillMatchingRule_2.SVMXC__Sequence__c = 1.0000;
        objSkillMatchingRule_2.SVMXC__Rule_Type__c = 'Skill Matching';
        objSkillMatchingRule_2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objSkillMatchingRule_2.RecordTypeId = skillProcessId;
        objSkillMatchingRule_2.SVMXC__Node_Parent__c = objSkillMatchingRule_1.Id;
        insert objSkillMatchingRule_2;
        
        SVMXC__ServiceMax_Config_Data__c objEligibilityCriteria = new  SVMXC__ServiceMax_Config_Data__c();
        objEligibilityCriteria.RecordTypeId = eligibilityExpressionId;
        objEligibilityCriteria.SVMXC__Expression_Type__c = 'Tech_Eligibility';
        objEligibilityCriteria.SVMXC__Expression_Rule__c = objEligibilityRule_1.id;
        objEligibilityCriteria.SVMXC__Field_Name__c = 'SVMXC__City__c';
        objEligibilityCriteria.SVMXC__Operator__c = 'eq';
        objEligibilityCriteria.SVMXC__Operand__c = 'Bangalore';
        lstRuleExpressionConf.add(objEligibilityCriteria);
        
        SVMXC__ServiceMax_Config_Data__c objSkillEligibility_1 = new  SVMXC__ServiceMax_Config_Data__c();
        objSkillEligibility_1.SVMXC__Expression_Type__c = 'Skill_Eligibility';
        objSkillEligibility_1.RecordTypeId = skillExpressionId;
        objSkillEligibility_1.SVMXC__Expression_Rule__c = objSkillMatchingRule_1.id;
        objSkillEligibility_1.SVMXC__Expression_Type__c = 'Skill_Eligibility';
        objSkillEligibility_1.SVMXC__Field_Name__c = 'SVMXC__City__c';
        objSkillEligibility_1.SVMXC__Operator__c = 'eq';
        objSkillEligibility_1.SVMXC__Operand__c = 'Bangalore';
        lstRuleExpressionConf.add(objSkillEligibility_1); 
        
        SVMXC__ServiceMax_Config_Data__c skilApplicable_1 = new  SVMXC__ServiceMax_Config_Data__c();
        skilApplicable_1.SVMXC__Skill__c = objSkillnstallation.id;
        skilApplicable_1.RecordTypeId = applicableSkillRectypeId;
        skilApplicable_1.SVMXC__Expression_Rule__c = objSkillMatchingRule_1.id;        
        lstRuleExpressionConf.add(skilApplicable_1);
        
        insert lstRuleExpressionConf;       
        
        SMAX_OptiMax_Engine_WS.QualifiedTechnician_WP objQTL = new SMAX_OptiMax_Engine_WS.QualifiedTechnician_WP(Territory2.Id,5);
        SMAX_OptiMax_Engine_WS.Expertise_WP objExpertise_WP = new SMAX_OptiMax_Engine_WS.Expertise_WP();
        //SMAX_OptiMax_Engine_WS.Expertise_WP objExpertise_WP1 = new SMAX_OptiMax_Engine_WS.Expertise_WP('aaaa','bbb');
        list<SMAX_OptiMax_Engine_WS.Expertise_WP> lstExpertise_WP = new list<SMAX_OptiMax_Engine_WS.Expertise_WP>();
        lstExpertise_WP.add(objExpertise_WP);
        //lstExpertise_WP.add(objExpertise_WP1);
        SMAX_OptiMax_Engine_WS.Product_WP objProduct_WP = new SMAX_OptiMax_Engine_WS.Product_WP();
        //SMAX_OptiMax_Engine_WS.Product_WP objProduct_WP1 = new SMAX_OptiMax_Engine_WS.Product_WP('aaaa','bbb');
        list<SMAX_OptiMax_Engine_WS.Product_WP> lstProduct_WP = new list<SMAX_OptiMax_Engine_WS.Product_WP>();
        lstProduct_WP.add(objProduct_WP);
        //lstProduct_WP.add(objProduct_WP1);
        SMAX_OptiMax_Engine_WS.ExecutionTime_WP objExecutionTime_WP1 = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP();
        SMAX_OptiMax_Engine_WS.ExecutionTime_WP objExecutionTime_WP = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(System.now().addminutes(-60),System.now());
        list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstExecutionTime_WP = new list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
        lstExecutionTime_WP.add(objExecutionTime_WP);
        lstExecutionTime_WP.add(objExecutionTime_WP1);
        SMAX_OptiMax_Engine_WS.Technician_WP objTechnician_WP = new SMAX_OptiMax_Engine_WS.Technician_WP(tech1,lstExecutionTime_WP,lstProduct_WP,lstExpertise_WP,null); 
        SMAX_OptiMax_Engine_WS.Technician_WP objTechnician_WP1 = new SMAX_OptiMax_Engine_WS.Technician_WP(tech1, lstExecutionTime_WP, lstProduct_WP,lstExpertise_WP);
        objTechnician_WP1.gettechProduct_WPL();
        objTechnician_WP1.gettechExpertise_WPL();
        SMAX_OptiMax_Engine_WS.ExecutionTime_WP objexeWP = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(System.now(),System.now());
        objexeWP.setstartDateTime(System.now());
        objexeWP.setendDateTime(System.now());
        set<date> setdate= new set<date>();
        setdate.add(System.today());
        setdate.add(System.today().adddays(1));
        objexeWP.doSplitDays(String.valueof(Userinfo.getTimeZone()),setdate);
        SMAX_OptiMax_Engine_WS.ExecutionTime_WP objexeWP1 = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(System.now(),System.now().adddays(2));
        objexeWP1.doSplitDays(String.valueof(Userinfo.getTimeZone()),setdate);
        SMAX_OptiMax_Engine_WS.WorkOrder_WP objWorkOrder_WP = new SMAX_OptiMax_Engine_WS.WorkOrder_WP(workOrderQTL);
        
         workOrderQTL.SVMXC__Qualified_Technicians__c = '[{"valid":false,"tName":"MizaLatLong","tech":"a1DF0000008fpCZMAY","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"Miza1","tech":"a1DF0000008fusxMAA","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"Miza2","tech":"a1DF0000008fut2MAA","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"Miza3","tech":"a1DF0000008fut7MAA","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"Miza4","tech":"a1DF0000008fvCeMAI","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"TestTech","tech":"a1DF0000008fz6yMAA","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10}]';
         // workOrderQTL.SVMXC__OptiMax_Status__c = 'Completed';
         // //workOrderQTL.SVMXC__Product__c = new SVMXC__Product__c().id;
        SVMXC__Skill__c objSkillnstallation2 = new SVMXC__Skill__c();
        objSkillnstallation2.Name = 'SkillInstall2';
        objSkillnstallation2.SVMXC__Skill_Category__c = 'Installation';
        insert objSkillnstallation2;
        workOrderQTL.SVMXC__Skill__c = objSkillnstallation2.id;
        upsert workOrderQTL;
        SMAX_OptiMax_Engine_WS.WorkOrder_WP objWorkOrder_WP1 = new SMAX_OptiMax_Engine_WS.WorkOrder_WP(workOrderQTL, lstExecutionTime_WP, 'abc',null);   
        SMAX_OptiMax_Engine_WS.KeyValue objKeyValue = new SMAX_OptiMax_Engine_WS.KeyValue('TERRITORYID',Territory2.Id); 
        Event SF_Event2 = new Event();
            SF_Event2.ActivityDate = System.today().addDays(1);
            SF_Event2.ActivityDateTime = System.now().addDays(1);
            SF_Event2.StartDateTime = SF_Event2.ActivityDateTime;
            SF_Event2.DurationInMinutes = 60;
            SF_Event2.EndDateTime = System.now().addHours(1).addDays(1);
            SF_Event2.OwnerId = UserInfo.getUserId();
            //insert SF_Event2;
        SMAX_OptiMax_Engine_WS.WorkOrderSchedule_WP objWorkOrderSchedule_WP = new SMAX_OptiMax_Engine_WS.WorkOrderSchedule_WP(String.valueof(SF_Event2.id), tech1.id, System.now(), System.now().addminutes(60), 60);   
        SMAX_OptiMax_Engine_WS.DblLocation_WP objDblLocation_WP2 = new SMAX_OptiMax_Engine_WS.DblLocation_WP();
        SMAX_OptiMax_Engine_WS.DblLocation_WP objDblLocation_WP = new SMAX_OptiMax_Engine_WS.DblLocation_WP(12.975174,77.607995);   
        SMAX_OptiMax_Engine_WS.DblLocation_WP objDblLocation_WP1 = new SMAX_OptiMax_Engine_WS.DblLocation_WP(String.valueof(12.975174),String.valueof(77.607995));
        SMAX_OptiMax_Engine_WS.ExcSetting_WP objExcSetting_WP = new SMAX_OptiMax_Engine_WS.ExcSetting_WP('aaaa','bbb');     
        System.Test.startTest();
        
        SMAX_OptiMax_Engine_WS.SMAX_Run_QTL_WS(keyValuePairs);
        precalcCompletedJob.SVMXC__OptiMax_Message__c = 'QTL Completed';
        update precalcCompletedJob;
        //SMAX_OptiMax_Engine_WS.SMAX_Run_QTL_WS(keyValuePairs);
        SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(Userinfo.getUserId(),Territory2.Id,dispatchprocessId);

        precalcCompletedJob.SVMXC__OptiMax_Message__c = 'QTL Failure';
        update precalcCompletedJob;
        //SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(Userinfo.getUserId(),Territory2.Id,dispatchprocessId);
        
        precalcCompletedJob.SVMXC__OptiMax_Message__c = 'Running Precalc';
        update precalcCompletedJob;
        //SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(Userinfo.getUserId(),Territory2.Id,dispatchprocessId);
        
        precalcCompletedJob.SVMXC__OptiMax_Message__c = 'Precalc Failure';
        update precalcCompletedJob;
        
        SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(Userinfo.getUserId(),Territory2.Id,dispatchprocessId);
        
        /*precalcCompletedJob.SVMXC__OptiMax_Message__c = 'Initiated';
        precalcCompletedJob.SVMXC__Start_Time__c = System.now();
        update precalcCompletedJob; 
        
        SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(Userinfo.getUserId(),Territory2.Id,dispatchprocessId);
        */
        precalcCompletedJob.SVMXC__OptiMax_Message__c = 'aaac Failure';
        update precalcCompletedJob;
        
        SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(Userinfo.getUserId(),Territory2.Id,dispatchprocessId);
        
        precalcCompletedJob.SVMXC__OptiMax_Message__c = 'QTL Failure';
        update precalcCompletedJob;
        
        SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(Userinfo.getUserId(),Territory2.Id,dispatchprocessId);
        
        precalcCompletedJob.SVMXC__OptiMax_Message__c = 'Running QTL';
        update precalcCompletedJob;
        
        SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(Userinfo.getUserId(),Territory2.Id,dispatchprocessId);
        
        System.debug(logginglevel.WARN, 'SMAX_OptiMax_Engine_WS_UnitTest2 -- Running QTL condition completed');
        
        SVMXC__SVMX_Jobs__c precalcCompletedJob1 = new SVMXC__SVMX_Jobs__c(SVMXC__SVMX_Process__c = dispatchprocessId, SVMXC__Territory__c = Territory2.Id, SVMXC__OptiMax_Message__c = 'Precalc Completed');
        insert precalcCompletedJob1;
        
        SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(Userinfo.getUserId(),Territory2.Id,dispatchprocessId);
    
    }
     
    static testMethod void triggerTest()
    {
        // code for SVMXC__Stock_Adjustment__c object trigger
        List<SVMXC__Stock_Adjustment__c> lstStockAdj = new List<SVMXC__Stock_Adjustment__c>();
        List<SVMXC__Site__c> lstLoc = new List<SVMXC__Site__c>();
        lstLoc.add(new SVMXC__Site__c(Name='Loc1', SVMXC__Stocking_Location__c = true, SVMXC__IsPartnerRecord__c = true));
        lstLoc.add(new SVMXC__Site__c(Name='Loc2', SVMXC__Stocking_Location__c = true, SVMXC__IsPartnerRecord__c = true));
        insert lstLoc;
        
        for(Integer i=0; i< 5; i++)
        {
            SVMXC__Stock_Adjustment__c  StockAdj = new SVMXC__Stock_Adjustment__c();
            if(i == 2 || i== 4)
                StockAdj.SVMXC__Location__c = lstLoc[0].id;
            else
                StockAdj.SVMXC__Location__c = lstLoc[1].id;
            lstStockAdj.add(StockAdj);
        }
        insert lstStockAdj;
    } 
    
    static testMethod void SMAX_OptiMax_Engine_WS_RUNQTL()
    {
        //Creating data 
        list<string> lstSettings = new list<string>();        
        lstSettings.add('GLOB001_GBL007');
        lstSettings.add('OMAX003_SET030');
        List<SVMXC__ServiceMax_Config_Data__c> lstSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstSettingValues = [SELECT SVMXC__Internal_Value__c, SVMXC__Setting_Unique_ID__c FROM SVMXC__ServiceMax_Config_Data__c WHERE recordType.Name = 'Setting Value'
                            AND SVMXC__Setting_Unique_ID__c IN :lstSettings
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' 
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Global'
                            ];                          
        if(('false'.equalsIgnoreCase(lstSettingValues[0].SVMXC__Internal_Value__c)) && ('false'.equalsIgnoreCase(lstSettingValues[1].SVMXC__Internal_Value__c))){
            lstSettingValues[0].SVMXC__Internal_Value__c='True';
            lstSettingValues[1].SVMXC__Internal_Value__c='True';
            upsert lstSettingValues;    
        } 

        case c = new case();
        Account account = new Account(
                                                Name = 'Account',
                                                ShippingStreet= 'ABC',
                                                ShippingCity= 'PQR ',
                                                ShippingState = 'California',
                                                ShippingPostalCode= '111',
                                                ShippingCountry= 'United States',
                                                BillingStreet= 'ABC',
                                                BillingCity= 'PQR ',
                                                BillingState = 'California',
                                                BillingPostalCode= '111',
                                                BillingCountry= 'United States'
                                                ); 
        insert account;
        System.assertEquals('Account', account.Name);
        
        List<BusinessHours> lBH = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];
        
        
        Contact contact = new Contact(LastName= 'Last',AccountId =account.Id,Email= 'test@max.com');
        insert contact;
        System.assertEquals('Last', contact.LastName);
        SVMXC__Territory__c Territory2 = new SVMXC__Territory__c(Name= 'Territory2',SVMXC__Active__c =true,SVMXC__Territory_Code__c = 'Territory2',SVMXC__Parent_Territory__c =NULL,SVMXC__Per_Mile_Cost__c=2.0,SVMXC__Max_Distance__c=100,SVMXC__Average_Speed__c=50.0);
        insert Territory2;
        
        territoryId = Territory2.Id;
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType];
        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        
        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c = 'SVMXC__Zip__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c = '11111111';
        oConf.SVMXC__Operator__c = 'eq';
        oConf.SVMXC__Expression_Rule__c = svmxprocess.Id;
        
        
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
            {
               svmxprocess.RecordTypeId = rt.ID;
            } 
             
            if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
            {
               oConf.RecordTypeId = rt.ID;
            } 
        }
        
        svmxprocess.SVMXC__Territory__c = Territory2.Id;
        svmxprocess.SVMXC__Description__c = 'abcd';
        svmxprocess.SVMXC__Dispatch_Method__c = 'Optimized Batch';
        svmxprocess.SVMXC__Assign_Work_Order_To__c = 'Technician';
        svmxprocess.SVMXC__Calendar_Start_Type__c = 'SAME DAY';
        svmxprocess.SVMXC__Calendar_End_Type__c = 'SAME DAY';
        svmxprocess.SVMXC__Expertise_Match_Enabled__c =true;
        svmxprocess.SVMXC__Product_Match_Enabled__c =true;
        svmxprocess.SVMXC__Preferred_Tech_Enabled__c =true;
        svmxprocess.SVMXC__Route_Type__c = 'CLOSED';
        svmxprocess.SVMXC__Distance_And_Time__c = 'Actual Distance And Time';
        svmxprocess.SVMXC__Weight_Time_Window__c =1.0000;
        svmxprocess.SVMXC__Weight_Route_Distance__c =1.0000;
        svmxprocess.SVMXC__Weight_Route_Time__c =1.0000;
        svmxprocess.SVMXC__Weight_Node_Type__c =1;
        svmxprocess.SVMXC__Dispatch_Process_Status__c = 'Complete';
        svmxprocess.SVMXC__Runs_Every_Monday__c =true;
        svmxprocess.SVMXC__Runs_Every_Tuesday__c =true;
        svmxprocess.SVMXC__Start_Time__c = '11:00 PM';
        svmxprocess.SVMXC__Frequency__c =1;
        svmxprocess.SVMXC__Full_Run_Unit__c = 'Days';
        svmxprocess.SVMXC__Start_Date__c = date.Today();
        svmxprocess.SVMXC__End_Date__c = date.Today().addDays(1);
        svmxprocess.SVMXC__Weight_Total_Distance__c =1.0000;
        svmxprocess.SVMXC__Calendar_Start_Days__c = 0;
        svmxprocess.SVMXC__Calendar_End_Days__c = 2;
        svmxprocess.SVMXC__Tolerance__c = 30;
        svmxprocess.SVMXC__ProcessID__c = 'PROCESS11';
        svmxprocess.SVMXC__SettingId__c = 'PROCESS11';
        svmxprocess.SVMXC__MapID__c = 'PROCESS11';
        svmxprocess.SVMXC__Name__c = 'PROCESS22';
        Insert svmxprocess;
        dispatchprocessId = svmxprocess.Id;
                
        //Create the Key-Value pair for input parameter
        list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue DPKeyVal = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue TEKeyVal = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue TEKeyVal1 = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        DPKeyVal.name = 'DISPATCHPROCESSID';
        DPKeyVal.value = dispatchprocessId;
        TEKeyVal.name = 'TERRITORYID';
        TEKeyVal.value = Territory2.Id + '_FULL';
        TEKeyVal1.name = 'TERRITORYID';
        TEKeyVal1.value = Territory2.Id + '_INCR';
        
        keyValuePairs.add(DPKeyVal);
        keyValuePairs.add(TEKeyVal);
        keyValuePairs.add(TEKeyVal1);
        //Coverage for method SMAX_Get_OptiMax_ErrorWO_WS
        SMAX_OptiMax_Engine_WS.SMAX_Get_OptiMax_ErrorWO_WS(keyValuePairs);
        
        //Coverage for method SMAX_Get_Job_Status_WS
        SVMXC__SVMX_Jobs__c smaxJob = new SVMXC__SVMX_Jobs__c();
        smaxJob.SVMXC__Status__c = '100';
        insert smaxJob;
        SVMXC__SVMX_Jobs__c precalcCompletedJob = new SVMXC__SVMX_Jobs__c(SVMXC__SVMX_Process__c = dispatchprocessId, SVMXC__Territory__c = Territory2.Id, SVMXC__OptiMax_Message__c = '');        
        insert precalcCompletedJob;
        list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs2 = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue jobKeyVal = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        jobKeyVal.name = 'ServiceMaxJobId';
        jobKeyVal.value = smaxJob.id;
        keyValuePairs2.add(jobKeyVal);
        
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue jobKeyVal1 = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        jobKeyVal1.name = 'ServiceMaxJobId';
        jobKeyVal1.value = precalcCompletedJob.id;
        keyValuePairs2.add(jobKeyVal1);
        
        //SMAX_OptiMax_Engine_WS.SMAX_Get_Job_Status_WS(keyValuePairs2);
                               
        SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(UserInfo.getUserId(),Territory2.Id,dispatchprocessId);
        
        SMAX_OptiMax_Engine_WS.SMAX_Run_QTL_WS(keyValuePairs);
    }

     static testMethod void SMAX_OptiMax_Engine_WS_RUNQTL2()
    {
        //Creating data 
        list<string> lstSettings = new list<string>();        
        lstSettings.add('GLOB001_GBL007');
        lstSettings.add('OMAX003_SET030');
        List<SVMXC__ServiceMax_Config_Data__c> lstSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstSettingValues = [SELECT SVMXC__Internal_Value__c, SVMXC__Setting_Unique_ID__c FROM SVMXC__ServiceMax_Config_Data__c WHERE recordType.Name = 'Setting Value'
                            AND SVMXC__Setting_Unique_ID__c IN :lstSettings
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' 
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Global'
                            ];                          
        if(('false'.equalsIgnoreCase(lstSettingValues[0].SVMXC__Internal_Value__c)) && ('false'.equalsIgnoreCase(lstSettingValues[1].SVMXC__Internal_Value__c))){
            lstSettingValues[0].SVMXC__Internal_Value__c='True';
            lstSettingValues[1].SVMXC__Internal_Value__c='True';
            upsert lstSettingValues;    
        } 
        case c = new case();
        Account account = new Account(
                                                Name = 'Account',
                                                ShippingStreet= 'ABC',
                                                ShippingCity= 'PQR ',
                                                ShippingState = 'California',
                                                ShippingPostalCode= '111',
                                                ShippingCountry= 'United States',
                                                BillingStreet= 'ABC',
                                                BillingCity= 'PQR ',
                                                BillingState = 'California',
                                                BillingPostalCode= '111',
                                                BillingCountry= 'United States'
                                                ); 
        insert account;
        System.assertEquals('Account', account.Name);
        
        List<BusinessHours> lBH = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];
        
        
        Contact contact = new Contact(LastName= 'Last',AccountId =account.Id,Email= 'test@max.com');
        insert contact;
        System.assertEquals('Last', contact.LastName);
        SVMXC__Territory__c Territory2 = new SVMXC__Territory__c(Name= 'Territory2',SVMXC__Active__c =true,SVMXC__Territory_Code__c = 'Territory2',SVMXC__Parent_Territory__c =NULL,SVMXC__Per_Mile_Cost__c=2.0,SVMXC__Max_Distance__c=100,SVMXC__Average_Speed__c=50.0);
        insert Territory2;
        
        territoryId = Territory2.Id;
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType];
        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        
        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c = 'SVMXC__Zip__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c = '11111111';
        oConf.SVMXC__Operator__c = 'eq';
        oConf.SVMXC__Expression_Rule__c = svmxprocess.Id;
        
        
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
            {
               svmxprocess.RecordTypeId = rt.ID;
            } 
             
            if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
            {
               oConf.RecordTypeId = rt.ID;
            } 
        }
        
        svmxprocess.SVMXC__Territory__c = Territory2.Id;
        svmxprocess.SVMXC__Description__c = 'abcd';
        svmxprocess.SVMXC__Dispatch_Method__c = 'Optimized Batch';
        svmxprocess.SVMXC__Assign_Work_Order_To__c = 'Technician';
        svmxprocess.SVMXC__Calendar_Start_Type__c = 'SAME DAY';
        svmxprocess.SVMXC__Calendar_End_Type__c = 'SAME DAY';
        svmxprocess.SVMXC__Expertise_Match_Enabled__c =true;
        svmxprocess.SVMXC__Product_Match_Enabled__c =true;
        svmxprocess.SVMXC__Preferred_Tech_Enabled__c =true;
        svmxprocess.SVMXC__Route_Type__c = 'CLOSED';
        svmxprocess.SVMXC__Distance_And_Time__c = 'Actual Distance And Time';
        svmxprocess.SVMXC__Weight_Time_Window__c =1.0000;
        svmxprocess.SVMXC__Weight_Route_Distance__c =1.0000;
        svmxprocess.SVMXC__Weight_Route_Time__c =1.0000;
        svmxprocess.SVMXC__Weight_Node_Type__c =1;
        svmxprocess.SVMXC__Dispatch_Process_Status__c = 'Complete';
        svmxprocess.SVMXC__Runs_Every_Monday__c =true;
        svmxprocess.SVMXC__Runs_Every_Tuesday__c =true;
        svmxprocess.SVMXC__Start_Time__c = '11:00 PM';
        svmxprocess.SVMXC__Frequency__c =1;
        svmxprocess.SVMXC__Full_Run_Unit__c = 'Days';
        svmxprocess.SVMXC__Start_Date__c = date.Today();
        svmxprocess.SVMXC__End_Date__c = date.Today().addDays(1);
        svmxprocess.SVMXC__Weight_Total_Distance__c =1.0000;
        svmxprocess.SVMXC__Calendar_Start_Days__c = 0;
        svmxprocess.SVMXC__Calendar_End_Days__c = 2;
        svmxprocess.SVMXC__Tolerance__c = 30;
        svmxprocess.SVMXC__ProcessID__c = 'PROCESS11';
        svmxprocess.SVMXC__SettingId__c = 'PROCESS11';
        svmxprocess.SVMXC__MapID__c = 'PROCESS11';
        svmxprocess.SVMXC__Name__c = 'PROCESS22';
        Insert svmxprocess;
        dispatchprocessId = svmxprocess.Id;
                
        //Create the Key-Value pair for input parameter
        list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue DPKeyVal = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue TEKeyVal = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue TEKeyVal1 = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        DPKeyVal.name = 'DISPATCHPROCESSID';
        DPKeyVal.value = dispatchprocessId;
        TEKeyVal.name = 'TERRITORYID';
        TEKeyVal.value = Territory2.Id + '_FULL';
        TEKeyVal1.name = 'TERRITORYID';
        TEKeyVal1.value = Territory2.Id + '_INCR';
        
        keyValuePairs.add(DPKeyVal);
        keyValuePairs.add(TEKeyVal);
        keyValuePairs.add(TEKeyVal1);
        //Coverage for method SMAX_Get_OptiMax_ErrorWO_WS
        SMAX_OptiMax_Engine_WS.SMAX_Get_OptiMax_ErrorWO_WS(keyValuePairs);
        
        //Coverage for method SMAX_Get_Job_Status_WS
        SVMXC__SVMX_Jobs__c smaxJob = new SVMXC__SVMX_Jobs__c();
        smaxJob.SVMXC__Status__c = '100';
        insert smaxJob;
        SVMXC__SVMX_Jobs__c precalcCompletedJob = new SVMXC__SVMX_Jobs__c(SVMXC__SVMX_Process__c = dispatchprocessId, SVMXC__Territory__c = Territory2.Id, SVMXC__OptiMax_Message__c = 'Precalc Failure');        
        insert precalcCompletedJob;
        list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs2 = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue jobKeyVal = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        jobKeyVal.name = 'ServiceMaxJobId';
        jobKeyVal.value = smaxJob.id;
        keyValuePairs2.add(jobKeyVal);
        
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue jobKeyVal1 = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        jobKeyVal1.name = 'ServiceMaxJobId';
        jobKeyVal1.value = precalcCompletedJob.id;
        keyValuePairs2.add(jobKeyVal1);
        
        //SMAX_OptiMax_Engine_WS.SMAX_Get_Job_Status_WS(keyValuePairs2);
                               
        SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(UserInfo.getUserId(),Territory2.Id,dispatchprocessId);
        
        SMAX_OptiMax_Engine_WS.SMAX_Run_QTL_WS(keyValuePairs);
    }
    
    static testMethod void InitiateJobTestCoverage()
    {
        //Creating data 
        list<string> lstSettings = new list<string>();        
        lstSettings.add('GLOB001_GBL007');
        lstSettings.add('OMAX003_SET030');
        List<SVMXC__ServiceMax_Config_Data__c> lstSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstSettingValues = [SELECT SVMXC__Internal_Value__c, SVMXC__Setting_Unique_ID__c FROM SVMXC__ServiceMax_Config_Data__c WHERE recordType.Name = 'Setting Value'
                            AND SVMXC__Setting_Unique_ID__c IN :lstSettings
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' 
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Global'
                            ];                          
        if(('false'.equalsIgnoreCase(lstSettingValues[0].SVMXC__Internal_Value__c)) && ('false'.equalsIgnoreCase(lstSettingValues[1].SVMXC__Internal_Value__c))){
            lstSettingValues[0].SVMXC__Internal_Value__c='True';
            lstSettingValues[1].SVMXC__Internal_Value__c='True';
            upsert lstSettingValues;    
        } 

        case c = new case();
        Account account = new Account(
                                                Name = 'Account',
                                                ShippingStreet= 'ABC',
                                                ShippingCity= 'PQR ',
                                                ShippingState = 'California',
                                                ShippingPostalCode= '111',
                                                ShippingCountry= 'United States',
                                                BillingStreet= 'ABC',
                                                BillingCity= 'PQR ',
                                                BillingState = 'California',
                                                BillingPostalCode= '111',
                                                BillingCountry= 'United States'
                                                ); 
        insert account;
        System.assertEquals('Account', account.Name);
        
        List<BusinessHours> lBH = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];
        
        
        Contact contact = new Contact(LastName= 'Last',AccountId =account.Id,Email= 'test@max.com');
        insert contact;
        System.assertEquals('Last', contact.LastName);

        SVMXC__Territory__c Territory3 = new SVMXC__Territory__c(Name= 'Territory3',SVMXC__Active__c =true,SVMXC__Territory_Code__c = 'Territory3',SVMXC__Parent_Territory__c =NULL,SVMXC__Per_Mile_Cost__c=1.0,SVMXC__Max_Distance__c=5,SVMXC__Average_Speed__c=70.0);
        insert Territory3;

        SVMXC__Territory__c Territory4 = new SVMXC__Territory__c(Name= 'Territory4',SVMXC__Active__c =true,SVMXC__Territory_Code__c = 'Territory4',SVMXC__Parent_Territory__c =NULL,SVMXC__Per_Mile_Cost__c=null,SVMXC__Max_Distance__c=null,SVMXC__Average_Speed__c=null);
        insert Territory4;
                
        territoryId = Territory3.Id;
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType];
        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        
        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c = 'SVMXC__Zip__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c = '11111111';
        oConf.SVMXC__Operator__c = 'eq';
        oConf.SVMXC__Expression_Rule__c = svmxprocess.Id;
        
        
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
            {
               svmxprocess.RecordTypeId = rt.ID;
            } 
             
            if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
            {
               oConf.RecordTypeId = rt.ID;
            } 
        }
        
        svmxprocess.SVMXC__Territory__c = Territory3.Id;
        svmxprocess.SVMXC__Description__c = 'abcd';
        svmxprocess.SVMXC__Dispatch_Method__c = 'Optimized Batch';
        svmxprocess.SVMXC__Assign_Work_Order_To__c = 'Technician';
        svmxprocess.SVMXC__Calendar_Start_Type__c = 'SAME DAY';
        svmxprocess.SVMXC__Calendar_End_Type__c = 'SAME DAY';
        svmxprocess.SVMXC__Expertise_Match_Enabled__c =true;
        svmxprocess.SVMXC__Product_Match_Enabled__c =true;
        svmxprocess.SVMXC__Preferred_Tech_Enabled__c =true;
        svmxprocess.SVMXC__Route_Type__c = 'CLOSED';
        svmxprocess.SVMXC__Distance_And_Time__c = 'Actual Distance And Time';
        svmxprocess.SVMXC__Weight_Time_Window__c =1.0000;
        svmxprocess.SVMXC__Weight_Route_Distance__c =1.0000;
        svmxprocess.SVMXC__Weight_Route_Time__c =1.0000;
        svmxprocess.SVMXC__Weight_Node_Type__c =1;
        svmxprocess.SVMXC__Dispatch_Process_Status__c = 'Complete';
        svmxprocess.SVMXC__Runs_Every_Monday__c =true;
        svmxprocess.SVMXC__Runs_Every_Tuesday__c =true;
        svmxprocess.SVMXC__Start_Time__c = '11:00 PM';
        svmxprocess.SVMXC__Frequency__c =1;
        svmxprocess.SVMXC__Full_Run_Unit__c = 'Days';
        svmxprocess.SVMXC__Start_Date__c = date.Today();
        svmxprocess.SVMXC__End_Date__c = date.Today().addDays(1);
        svmxprocess.SVMXC__Weight_Total_Distance__c =1.0000;
        svmxprocess.SVMXC__Calendar_Start_Days__c = 0;
        svmxprocess.SVMXC__Calendar_End_Days__c = 2;
        svmxprocess.SVMXC__Tolerance__c = 30;
        svmxprocess.SVMXC__ProcessID__c = 'PROCESS11';
        svmxprocess.SVMXC__SettingId__c = 'PROCESS11';
        svmxprocess.SVMXC__MapID__c = 'PROCESS11';
        svmxprocess.SVMXC__Name__c = 'PROCESS22';
        Insert svmxprocess;
        dispatchprocessId = svmxprocess.Id;
        
        list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue DPKeyVal = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue TEKeyVal = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue TEKeyVal1 = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        DPKeyVal.name = 'DISPATCHPROCESSID';
        DPKeyVal.value = dispatchprocessId;
        keyValuePairs.add(DPKeyVal);
        TEKeyVal.name = 'TERRITORYID';
        TEKeyVal.value = Territory3.Id + '_FULL';
        TEKeyVal1.name = 'TERRITORYID';
        TEKeyVal1.value = Territory3.Id + '_INCR';

        SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs);
        
        keyValuePairs.add(TEKeyVal);
        SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs);

        keyValuePairs.add(TEKeyVal1);
        SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs);
        
        SVMXC__SVMX_Jobs__c precalcCompletedJob = new SVMXC__SVMX_Jobs__c(SVMXC__SVMX_Process__c = dispatchprocessId, SVMXC__Territory__c = Territory3.Id, SVMXC__OptiMax_Message__c = 'Precalc Completed');
        SVMXC__SVMX_Jobs__c precalcCompletedJob4 = new SVMXC__SVMX_Jobs__c(SVMXC__SVMX_Process__c = dispatchprocessId, SVMXC__Territory__c = Territory3.Id, SVMXC__OptiMax_Message__c = 'Precalc Failure');
        SVMXC__SVMX_Jobs__c precalcCompletedJob5 = new SVMXC__SVMX_Jobs__c(SVMXC__SVMX_Process__c = dispatchprocessId, SVMXC__Territory__c = Territory3.Id, SVMXC__OptiMax_Message__c = 'Running Precalc');
        List<SVMXC__SVMX_Jobs__c> lstPrecalcJobs = new List<SVMXC__SVMX_Jobs__c>();
        lstPrecalcJobs.add(precalcCompletedJob);
        lstPrecalcJobs.add(precalcCompletedJob4);
        lstPrecalcJobs.add(precalcCompletedJob5);
        insert lstPrecalcJobs;
        
        list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs1 = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue DPKeyVal1 = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        DPKeyVal1.name = 'DISPATCHPROCESSID';
        DPKeyVal1.value = dispatchprocessId;
         keyValuePairs1.add(DPKeyVal1);
        SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs1);
        
        list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs2 = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue TEKeyVal2 = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        TEKeyVal2.name = 'TERRITORYID';
        TEKeyVal2.value = Territory3.Id + '_FULL';
        keyValuePairs1.add(TEKeyVal2);
        SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs2);
        
        list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs3 = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue TEKeyVal3 = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        TEKeyVal3.name = 'TERRITORYID';
        TEKeyVal3.value = Territory3.Id + '_INCR';
        keyValuePairs3.add(TEKeyVal3);
       SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs3);
        
        SVMXC__Service_Order__c workOrderQTL = new SVMXC__Service_Order__c();
        workOrderQTL.SVMXC__Case__c = c.Id;
        workOrderQTL.SVMXC__Company__c = account.Id;
        workOrderQTL.SVMXC__Contact__c =contact.Id;
        workOrderQTL.SVMXC__Latitude__c = 40.739582;
        workOrderQTL.SVMXC__Longitude__c = -73.980772;
        workOrderQTL.SVMXC__Street__c = 'Street1';
        workOrderQTL.SVMXC__City__c = 'BANGALORE';
        workOrderQTL.SVMXC__State__c = 'Karnataka';
        workOrderQTL.SVMXC__Country__c = 'India';
        workOrderQTL.SVMXC__Zip__c = '11111111';
        workOrderQTL.SVMXC__Order_Status__c = 'Open';
        workOrderQTL.SVMXC__Priority__c = 'Medium';
        workOrderQTL.SVMXC__Dispatch_Priority__c = 2;
        workOrderQTL.SVMXC__Order_Type__c = 'Field Service';
        workOrderQTL.SVMXC__Apply_Business_Hours_For_OptiMax__c = false;
        workOrderQTL.SVMXC__Preferred_Business_Hours__c = lBH[0].Id;
        workOrderQTL.SVMXC__Primary_Territory__c = Territory3.Id;
        workOrderQTL.SVMXC__OptiMax_status__c = 'OPT_COMPLETED';
        workOrderQTL.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrderQTL.SVMXC__Dispatch_Process__c = dispatchprocessId;
        workOrderQTL.SVMXC__Service_Duration__c = 6000;
        workOrderQTL.SVMXC__Locked_By_DC__c = true;
        workOrderQTL.SVMXC__SM_Lock_Appointment_Schedule__c = WSCH_ECO_Constants.SCHEDULE_LOCK_IN_PLACE;
        workOrderQTL.SVMXC__Scheduled_Date_Time__c  = system.now().addDays(3);
        insert workOrderQTL;
        
        //Create technicans
        SVMXC__Service_Group__c sgroup = new SVMXC__Service_Group__c();
        sgroup.SVMXC__Country__c = 'India';
        sgroup.SVMXC__City__c = 'Bangalore';
        Insert sgroup;
        System.assertEquals('India', sgroup.SVMXC__Country__c);
        
        SVMXC__Skill__c objSkillnstallation = new SVMXC__Skill__c();
        objSkillnstallation.Name = 'SkillInstall2';
        objSkillnstallation.SVMXC__Skill_Category__c = 'Installation';
        insert objSkillnstallation;
        
        List<SVMXC__Service_Group_Members__c> technicians= new List<SVMXC__Service_Group_Members__c>();
        SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c();
        tech1.SVMXC__Service_Territory__c =Territory3.Id;
        tech1.SVMXC__Fixed_Cost__c = 2.0;
        tech1.SVMXC__Latitude_Home__c = 37.407843;
        tech1.SVMXC__Longitude_Home__c = -122.008637;
        tech1.SVMXC__Street__c = 'Street 1';
        tech1.SVMXC__City__c = 'Bangalore';
        tech1.SVMXC__State__c = 'Karnataka';
        tech1.SVMXC__Zip__c = '11111111';
        tech1.SVMXC__Country__c = 'India';
        tech1.SVMXC__Per_hour_Cost__c = 2.0; 
        tech1.SVMXC__Per_Mile_Cost__c = 1.0;
        tech1.SVMXC__Average_Speed__c = 2.0;
        tech1.SVMXC__Max_Daily_Hours__c = 2.0;
        tech1.SVMXC__Max_Distance__c = 5.0;
        tech1.SVMXC__Enable_Scheduling__c = true;
        tech1.SVMXC__Service_Group__c =sgroup.Id; 
        if(lBH != NULL && lBH.size()>0)
            tech1.SVMXC__Working_Hours__c = lBH[0].id;
        tech1.SVMXC__Active__c  = true;
        technicians.add(tech1);

        SVMXC__Service_Group_Members__c tech = new SVMXC__Service_Group_Members__c();
        tech.SVMXC__Service_Territory__c = Territory3.Id;
        tech.SVMXC__Fixed_Cost__c = 2.0;
        tech.SVMXC__Latitude_Home__c = 37.407843;
        tech.SVMXC__Longitude_Home__c = -122.008637;
        tech.SVMXC__Street__c = 'Street 1';
        tech.SVMXC__City__c = 'Bangalore';
        tech.SVMXC__State__c = 'Karnataka';
        tech.SVMXC__Zip__c = '11111111';
        tech.SVMXC__Country__c = 'India';
        tech.SVMXC__Per_hour_Cost__c = 2.0; 
        tech.SVMXC__Per_Mile_Cost__c = 1.0;
        tech.SVMXC__Average_Speed__c = 2.0;
        tech.SVMXC__Max_Daily_Hours__c = 2.0;
        tech.SVMXC__Max_Distance__c = 5.0;
        tech.SVMXC__Salesforce_User__c = UserInfo.getUserId();
        tech.SVMXC__Enable_Scheduling__c = true;
        tech.SVMXC__Service_Group__c = sgroup.Id; 
        tech.SVMXC__Active__c  = true;
        if(lBH != NULL && lBH.size()>0)
            tech.SVMXC__Working_Hours__c = lBH[0].id;
        technicians.add(tech);
        Insert technicians;
        
        SVMXC__Service_Group_Skills__c skillForTech = new SVMXC__Service_Group_Skills__c(SVMXC__Service_Group__c = sgroup.Id, SVMXC__Skill__c = objSkillnstallation.Id);
        insert skillForTech;

        //Create Eligibility Matching Rules
        Id eligibilityProcessId;
        Id eligibilityExpressionId;
        Id skillProcessId;
        Id skillExpressionId;
        Id applicableSkillRectypeId;
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'SVMX Rule' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
            {
                eligibilityProcessId = rt.Id;
                skillProcessId = rt.Id;
            }
             
            if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
            {
                eligibilityExpressionId = rt.Id;
                skillExpressionId = rt.Id;
            }
            if(rt.Name == 'Applicable Skills' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
            {
                applicableSkillRectypeId = rt.Id;
            }
        }
        
        list<SVMXC__ServiceMax_Processes__c> lstRuleProcess = new list<SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Config_Data__c> lstRuleExpressionConf = new list<SVMXC__ServiceMax_Config_Data__c>();
        
        SVMXC__ServiceMax_Processes__c objEligibilityRule_1 = new SVMXC__ServiceMax_Processes__c();
        objEligibilityRule_1.RecordTypeId = eligibilityProcessId;
        objEligibilityRule_1.SVMXC__Rule_Type__c = 'Tech Eligibility';
        objEligibilityRule_1.SVMXC__Name__c = 'Eligibility Rule Test1';
        objEligibilityRule_1.SVMXC__Description__c = 'Eligibility Rule Test1';
        objEligibilityRule_1.SVMXC__Select__c = true;
        objEligibilityRule_1.SVMXC__Rule_Type__c = 'Tech Eligibility';
        objEligibilityRule_1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objEligibilityRule_1.SVMXC__Sequence__c = 1.0000;
        lstRuleProcess.add(objEligibilityRule_1);
        
        SVMXC__ServiceMax_Processes__c objSkillMatchingRule_1 = new SVMXC__ServiceMax_Processes__c();
        objSkillMatchingRule_1.SVMXC__Name__c = 'Skill Rule Test1';
        objSkillMatchingRule_1.SVMXC__Description__c = 'Skill Rule Test1';
        objSkillMatchingRule_1.SVMXC__Select__c = true;               
        objSkillMatchingRule_1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objSkillMatchingRule_1.SVMXC__Sequence__c = 0.0000;
        objSkillMatchingRule_1.SVMXC__Rule_Type__c = 'Skill Matching';
        objSkillMatchingRule_1.RecordTypeId = skillProcessId;
        lstRuleProcess.add(objSkillMatchingRule_1);
        
        SVMXC__ServiceMax_Processes__c objEligibilityRule_2 = new SVMXC__ServiceMax_Processes__c();
        objEligibilityRule_2.RecordTypeId = eligibilityProcessId;
        objEligibilityRule_2.SVMXC__Rule_Type__c = 'Tech Eligibility';
        objEligibilityRule_2.SVMXC__Name__c = 'Eligibility Rule Test2';
        objEligibilityRule_2.SVMXC__Description__c = 'Eligibility Rule Test2';
        objEligibilityRule_2.SVMXC__Select__c = false;
        objEligibilityRule_2.SVMXC__Sequence__c = 2.0000;
        objEligibilityRule_2.SVMXC__Rule_Type__c = 'Tech Eligibility';
        objEligibilityRule_2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        lstRuleProcess.add(objEligibilityRule_2);
        
        insert lstRuleProcess;
        
        SVMXC__ServiceMax_Processes__c objSkillMatchingRule_2 = new SVMXC__ServiceMax_Processes__c();
        objSkillMatchingRule_2.SVMXC__Name__c = 'Skill Rule Test2';
        objSkillMatchingRule_2.SVMXC__Description__c = 'Skill Rule Test2';
        objSkillMatchingRule_2.SVMXC__Select__c = false;
        objSkillMatchingRule_2.SVMXC__Sequence__c = 1.0000;
        objSkillMatchingRule_2.SVMXC__Rule_Type__c = 'Skill Matching';
        objSkillMatchingRule_2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objSkillMatchingRule_2.RecordTypeId = skillProcessId;
        objSkillMatchingRule_2.SVMXC__Node_Parent__c = objSkillMatchingRule_1.Id;
        insert objSkillMatchingRule_2;
        
        SVMXC__ServiceMax_Config_Data__c objEligibilityCriteria = new  SVMXC__ServiceMax_Config_Data__c();
        objEligibilityCriteria.RecordTypeId = eligibilityExpressionId;
        objEligibilityCriteria.SVMXC__Expression_Type__c = 'Tech_Eligibility';
        objEligibilityCriteria.SVMXC__Expression_Rule__c = objEligibilityRule_1.id;
        objEligibilityCriteria.SVMXC__Field_Name__c = 'SVMXC__City__c';
        objEligibilityCriteria.SVMXC__Operator__c = 'eq';
        objEligibilityCriteria.SVMXC__Operand__c = 'Bangalore';
        lstRuleExpressionConf.add(objEligibilityCriteria);
        
        SVMXC__ServiceMax_Config_Data__c objSkillEligibility_1 = new  SVMXC__ServiceMax_Config_Data__c();
        objSkillEligibility_1.SVMXC__Expression_Type__c = 'Skill_Eligibility';
        objSkillEligibility_1.RecordTypeId = skillExpressionId;
        objSkillEligibility_1.SVMXC__Expression_Rule__c = objSkillMatchingRule_1.id;
        objSkillEligibility_1.SVMXC__Expression_Type__c = 'Skill_Eligibility';
        objSkillEligibility_1.SVMXC__Field_Name__c = 'SVMXC__City__c';
        objSkillEligibility_1.SVMXC__Operator__c = 'eq';
        objSkillEligibility_1.SVMXC__Operand__c = 'Bangalore';
        lstRuleExpressionConf.add(objSkillEligibility_1); 
        
        SVMXC__ServiceMax_Config_Data__c skilApplicable_1 = new  SVMXC__ServiceMax_Config_Data__c();
        skilApplicable_1.SVMXC__Skill__c = objSkillnstallation.id;
        skilApplicable_1.RecordTypeId = applicableSkillRectypeId;
        skilApplicable_1.SVMXC__Expression_Rule__c = objSkillMatchingRule_1.id;        
        lstRuleExpressionConf.add(skilApplicable_1);
        
        insert lstRuleExpressionConf;       
        
        SMAX_OptiMax_Engine_WS.QualifiedTechnician_WP objQTL = new SMAX_OptiMax_Engine_WS.QualifiedTechnician_WP(Territory3.Id,5);
        SMAX_OptiMax_Engine_WS.Expertise_WP objExpertise_WP = new SMAX_OptiMax_Engine_WS.Expertise_WP();
        //SMAX_OptiMax_Engine_WS.Expertise_WP objExpertise_WP1 = new SMAX_OptiMax_Engine_WS.Expertise_WP('aaaa','bbb');
        list<SMAX_OptiMax_Engine_WS.Expertise_WP> lstExpertise_WP = new list<SMAX_OptiMax_Engine_WS.Expertise_WP>();
        lstExpertise_WP.add(objExpertise_WP);
        //lstExpertise_WP.add(objExpertise_WP1);
        SMAX_OptiMax_Engine_WS.Product_WP objProduct_WP = new SMAX_OptiMax_Engine_WS.Product_WP();
        //SMAX_OptiMax_Engine_WS.Product_WP objProduct_WP1 = new SMAX_OptiMax_Engine_WS.Product_WP('aaaa','bbb');
        list<SMAX_OptiMax_Engine_WS.Product_WP> lstProduct_WP = new list<SMAX_OptiMax_Engine_WS.Product_WP>();
        lstProduct_WP.add(objProduct_WP);
        //lstProduct_WP.add(objProduct_WP1);
        SMAX_OptiMax_Engine_WS.ExecutionTime_WP objExecutionTime_WP1 = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP();
        SMAX_OptiMax_Engine_WS.ExecutionTime_WP objExecutionTime_WP = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(System.now().addminutes(-60),System.now());
        list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstExecutionTime_WP = new list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
        lstExecutionTime_WP.add(objExecutionTime_WP);
        lstExecutionTime_WP.add(objExecutionTime_WP1);
        SMAX_OptiMax_Engine_WS.Technician_WP objTechnician_WP = new SMAX_OptiMax_Engine_WS.Technician_WP(tech1,lstExecutionTime_WP,lstProduct_WP,lstExpertise_WP,null); 
        SMAX_OptiMax_Engine_WS.Technician_WP objTechnician_WP1 = new SMAX_OptiMax_Engine_WS.Technician_WP(tech1, lstExecutionTime_WP, lstProduct_WP,lstExpertise_WP);
        objTechnician_WP1.gettechProduct_WPL();
        objTechnician_WP1.gettechExpertise_WPL();
        SMAX_OptiMax_Engine_WS.ExecutionTime_WP objexeWP = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(System.now(),System.now());
        objexeWP.setstartDateTime(System.now());
        objexeWP.setendDateTime(System.now());
        set<date> setdate= new set<date>();
        setdate.add(System.today());
        setdate.add(System.today().adddays(1));
        objexeWP.doSplitDays(String.valueof(Userinfo.getTimeZone()),setdate);
        SMAX_OptiMax_Engine_WS.ExecutionTime_WP objexeWP1 = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(System.now(),System.now().adddays(2));
        objexeWP1.doSplitDays(String.valueof(Userinfo.getTimeZone()),setdate);
        SMAX_OptiMax_Engine_WS.WorkOrder_WP objWorkOrder_WP = new SMAX_OptiMax_Engine_WS.WorkOrder_WP(workOrderQTL);
        SMAX_OptiMax_Engine_WS.WorkOrder_WP objWorkOrder_WP1 = new SMAX_OptiMax_Engine_WS.WorkOrder_WP(workOrderQTL, lstExecutionTime_WP, 'abc',null);   
        SMAX_OptiMax_Engine_WS.KeyValue objKeyValue = new SMAX_OptiMax_Engine_WS.KeyValue('TERRITORYID',Territory3.Id); 
        Event SF_Event2 = new Event();
            SF_Event2.ActivityDate = System.today().addDays(1);
            SF_Event2.ActivityDateTime = System.now().addDays(1);
            SF_Event2.StartDateTime = SF_Event2.ActivityDateTime;
            SF_Event2.DurationInMinutes = 60;
            SF_Event2.EndDateTime = System.now().addHours(1).addDays(1);
            SF_Event2.OwnerId = UserInfo.getUserId();
            //insert SF_Event2;
        SMAX_OptiMax_Engine_WS.WorkOrderSchedule_WP objWorkOrderSchedule_WP = new SMAX_OptiMax_Engine_WS.WorkOrderSchedule_WP(String.valueof(SF_Event2.id), tech1.id, System.now(), System.now().addminutes(60), 60);   
        SMAX_OptiMax_Engine_WS.DblLocation_WP objDblLocation_WP2 = new SMAX_OptiMax_Engine_WS.DblLocation_WP();
        SMAX_OptiMax_Engine_WS.DblLocation_WP objDblLocation_WP = new SMAX_OptiMax_Engine_WS.DblLocation_WP(12.975174,77.607995);   
        SMAX_OptiMax_Engine_WS.DblLocation_WP objDblLocation_WP1 = new SMAX_OptiMax_Engine_WS.DblLocation_WP(String.valueof(12.975174),String.valueof(77.607995));
        SMAX_OptiMax_Engine_WS.ExcSetting_WP objExcSetting_WP = new SMAX_OptiMax_Engine_WS.ExcSetting_WP('aaaa','bbb');     
        System.Test.startTest();
        
        SMAX_OptiMax_Engine_WS.SMAX_Run_QTL_WS(keyValuePairs);
        precalcCompletedJob.SVMXC__OptiMax_Message__c = 'QTL Completed';
        update precalcCompletedJob;
        //SMAX_OptiMax_Engine_WS.SMAX_Run_QTL_WS(keyValuePairs);
        SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(Userinfo.getUserId(),Territory3.Id,dispatchprocessId);
    } 
    
    static testMethod void InitiateJobTestCoverageMultiTerritory()
    {
        //Creating data 
        list<string> lstSettings = new list<string>();        
        lstSettings.add('GLOB001_GBL007');
        lstSettings.add('OMAX003_SET030');
        List<SVMXC__ServiceMax_Config_Data__c> lstSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstSettingValues = [SELECT SVMXC__Internal_Value__c, SVMXC__Setting_Unique_ID__c FROM SVMXC__ServiceMax_Config_Data__c WHERE recordType.Name = 'Setting Value'
                            AND SVMXC__Setting_Unique_ID__c IN :lstSettings
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' 
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Global'
                            ];                          
        if(('false'.equalsIgnoreCase(lstSettingValues[0].SVMXC__Internal_Value__c)) && ('false'.equalsIgnoreCase(lstSettingValues[1].SVMXC__Internal_Value__c))){
            lstSettingValues[0].SVMXC__Internal_Value__c='True';
            lstSettingValues[1].SVMXC__Internal_Value__c='True';
            upsert lstSettingValues;    
        } 
        case c = new case();
        Account account = new Account(
                                                Name = 'Account',
                                                ShippingStreet= 'ABC',
                                                ShippingCity= 'PQR ',
                                                ShippingState = 'California',
                                                ShippingPostalCode= '111',
                                                ShippingCountry= 'United States',
                                                BillingStreet= 'ABC',
                                                BillingCity= 'PQR ',
                                                BillingState = 'California',
                                                BillingPostalCode= '111',
                                                BillingCountry= 'United States'
                                                );  
        insert account;
        System.assertEquals('Account', account.Name);
        
        List<BusinessHours> lBH = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];
        
        
        Contact contact = new Contact(LastName= 'Last',AccountId =account.Id,Email= 'test@max.com');
        insert contact;
        System.assertEquals('Last', contact.LastName);

        SVMXC__Territory__c Territory1 = new SVMXC__Territory__c(Name= 'Territory1',SVMXC__Active__c =true,SVMXC__Territory_Code__c = 'Territory1',SVMXC__Parent_Territory__c =NULL,SVMXC__Per_Mile_Cost__c=1.0,SVMXC__Max_Distance__c=5,SVMXC__Average_Speed__c=70.0);
        insert Territory1;
        
        SVMXC__Territory__c Territory2 = new SVMXC__Territory__c(Name= 'Territory2',SVMXC__Active__c =true,SVMXC__Territory_Code__c = 'Territory2',SVMXC__Parent_Territory__c =NULL,SVMXC__Per_Mile_Cost__c=1.0,SVMXC__Max_Distance__c=5,SVMXC__Average_Speed__c=70.0);
        insert Territory2;

        SVMXC__Territory__c Territory3 = new SVMXC__Territory__c(Name= 'Territory3',SVMXC__Active__c =true,SVMXC__Territory_Code__c = 'Territory3',SVMXC__Parent_Territory__c =NULL,SVMXC__Per_Mile_Cost__c=1.0,SVMXC__Max_Distance__c=5,SVMXC__Average_Speed__c=70.0);
        insert Territory3;

        //territoryId = Territory3.Id;
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType];
        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        svmxprocess.SVMXC__Territory__c = Territory1.Id;
        svmxprocess.SVMXC__Description__c = 'abcd';
        svmxprocess.SVMXC__Dispatch_Method__c = 'Optimized Batch';
        svmxprocess.SVMXC__Assign_Work_Order_To__c = 'Technician';
        svmxprocess.SVMXC__Calendar_Start_Type__c = 'SAME DAY';
        svmxprocess.SVMXC__Calendar_End_Type__c = 'SAME DAY';
        svmxprocess.SVMXC__Expertise_Match_Enabled__c =true;
        svmxprocess.SVMXC__Product_Match_Enabled__c =true;
        svmxprocess.SVMXC__Preferred_Tech_Enabled__c =true;
        svmxprocess.SVMXC__Route_Type__c = 'CLOSED';
        svmxprocess.SVMXC__Distance_And_Time__c = 'Actual Distance And Time';
        svmxprocess.SVMXC__Weight_Time_Window__c =1.0000;
        svmxprocess.SVMXC__Weight_Route_Distance__c =1.0000;
        svmxprocess.SVMXC__Weight_Route_Time__c =1.0000;
        svmxprocess.SVMXC__Weight_Node_Type__c =1;
        svmxprocess.SVMXC__Dispatch_Process_Status__c = 'Complete';
        svmxprocess.SVMXC__Runs_Every_Monday__c =true;
        svmxprocess.SVMXC__Runs_Every_Tuesday__c =true;
        svmxprocess.SVMXC__Start_Time__c = '11:00 PM';
        svmxprocess.SVMXC__Frequency__c =1;
        svmxprocess.SVMXC__Full_Run_Unit__c = 'Days';
        svmxprocess.SVMXC__Start_Date__c = date.Today();
        svmxprocess.SVMXC__End_Date__c = date.Today().addDays(1);
        svmxprocess.SVMXC__Weight_Total_Distance__c =1.0000;
        svmxprocess.SVMXC__Calendar_Start_Days__c = 0;
        svmxprocess.SVMXC__Calendar_End_Days__c = 2;
        svmxprocess.SVMXC__Tolerance__c = 30;
        svmxprocess.SVMXC__ProcessID__c = 'PROCESS11';
        svmxprocess.SVMXC__SettingId__c = 'PROCESS11';
        svmxprocess.SVMXC__MapID__c = 'PROCESS11';
        svmxprocess.SVMXC__Name__c = 'PROCESS22';
        Insert svmxprocess;
        
        
        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c = 'SVMXC__Zip__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c = '11111111';
        oConf.SVMXC__Operator__c = 'eq';
        oConf.SVMXC__Expression_Rule__c = svmxprocess.Id;
        

        SVMXC__ServiceMax_Processes__c svmxprocess1 = new SVMXC__ServiceMax_Processes__c();
        svmxprocess1.SVMXC__Territory__c = Territory2.Id;
        svmxprocess1.SVMXC__Description__c = 'abcd';
        svmxprocess1.SVMXC__Dispatch_Method__c = 'Optimized Batch';
        svmxprocess1.SVMXC__Assign_Work_Order_To__c = 'Technician';
        svmxprocess1.SVMXC__Calendar_Start_Type__c = 'SAME DAY';
        svmxprocess1.SVMXC__Calendar_End_Type__c = 'SAME DAY';
        svmxprocess1.SVMXC__Expertise_Match_Enabled__c =true;
        svmxprocess1.SVMXC__Product_Match_Enabled__c =true;
        svmxprocess1.SVMXC__Preferred_Tech_Enabled__c =true;
        svmxprocess1.SVMXC__Route_Type__c = 'CLOSED';
        svmxprocess1.SVMXC__Distance_And_Time__c = 'Actual Distance And Time';
        svmxprocess1.SVMXC__Weight_Time_Window__c =1.0000;
        svmxprocess1.SVMXC__Weight_Route_Distance__c =1.0000;
        svmxprocess1.SVMXC__Weight_Route_Time__c =1.0000;
        svmxprocess1.SVMXC__Weight_Node_Type__c =1;
        svmxprocess1.SVMXC__Dispatch_Process_Status__c = 'Complete';
        svmxprocess1.SVMXC__Runs_Every_Monday__c =true;
        svmxprocess1.SVMXC__Runs_Every_Tuesday__c =true;
        svmxprocess1.SVMXC__Start_Time__c = '11:00 PM';
        svmxprocess1.SVMXC__Frequency__c =1;
        svmxprocess1.SVMXC__Full_Run_Unit__c = 'Hours';
        svmxprocess1.SVMXC__Start_Date__c = date.Today();
        svmxprocess1.SVMXC__End_Date__c = date.Today().addDays(1);
        svmxprocess1.SVMXC__Weight_Total_Distance__c =1.0000;
        svmxprocess1.SVMXC__Calendar_Start_Days__c = 0;
        svmxprocess1.SVMXC__Calendar_End_Days__c = 2;
        svmxprocess1.SVMXC__Tolerance__c = 30;
        svmxprocess1.SVMXC__ProcessID__c = 'PROCESS11';
        svmxprocess1.SVMXC__SettingId__c = 'PROCESS11';
        svmxprocess1.SVMXC__MapID__c = 'PROCESS11';
        svmxprocess1.SVMXC__Name__c = 'PROCESS22';
        Insert svmxprocess1;        
        
        SVMXC__ServiceMax_Config_Data__c oConf1 = new SVMXC__ServiceMax_Config_Data__c();
        oConf1.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf1.SVMXC__Field_Name__c = 'SVMXC__Zip__c';
        oConf1.SVMXC__Display_Type__c = 'STRING';
        oConf1.SVMXC__Operand__c = '11111111';
        oConf1.SVMXC__Operator__c = 'eq';
        oConf1.SVMXC__Expression_Rule__c = svmxprocess1.Id;
        
        SVMXC__ServiceMax_Processes__c svmxprocess2 = new SVMXC__ServiceMax_Processes__c();
        svmxprocess2.SVMXC__Territory__c = Territory3.Id;
        svmxprocess2.SVMXC__Description__c = 'abcd';
        svmxprocess2.SVMXC__Dispatch_Method__c = 'Optimized Batch';
        svmxprocess2.SVMXC__Assign_Work_Order_To__c = 'Technician';
        svmxprocess2.SVMXC__Calendar_Start_Type__c = 'SAME DAY';
        svmxprocess2.SVMXC__Calendar_End_Type__c = 'SAME DAY';
        svmxprocess2.SVMXC__Expertise_Match_Enabled__c =true;
        svmxprocess2.SVMXC__Product_Match_Enabled__c =true;
        svmxprocess2.SVMXC__Preferred_Tech_Enabled__c =true;
        svmxprocess2.SVMXC__Route_Type__c = 'CLOSED';
        svmxprocess2.SVMXC__Distance_And_Time__c = 'Actual Distance And Time';
        svmxprocess2.SVMXC__Weight_Time_Window__c =1.0000;
        svmxprocess2.SVMXC__Weight_Route_Distance__c =1.0000;
        svmxprocess2.SVMXC__Weight_Route_Time__c =1.0000;
        svmxprocess2.SVMXC__Weight_Node_Type__c =1;
        svmxprocess2.SVMXC__Dispatch_Process_Status__c = 'Complete';
        svmxprocess2.SVMXC__Runs_Every_Monday__c =true;
        svmxprocess2.SVMXC__Runs_Every_Tuesday__c =true;
        svmxprocess2.SVMXC__Start_Time__c = '11:00 PM';
        svmxprocess2.SVMXC__Frequency__c =1;
        svmxprocess2.SVMXC__Full_Run_Unit__c = 'Days';
        svmxprocess2.SVMXC__Start_Date__c = date.Today();
        svmxprocess2.SVMXC__End_Date__c = date.Today().addDays(1);
        svmxprocess2.SVMXC__Weight_Total_Distance__c =1.0000;
        svmxprocess2.SVMXC__Calendar_Start_Days__c = 0;
        svmxprocess2.SVMXC__Calendar_End_Days__c = 2;
        svmxprocess2.SVMXC__Tolerance__c = 30;
        svmxprocess2.SVMXC__ProcessID__c = 'PROCESS11';
        svmxprocess2.SVMXC__SettingId__c = 'PROCESS11';
        svmxprocess2.SVMXC__MapID__c = 'PROCESS11';
        svmxprocess2.SVMXC__Name__c = 'PROCESS22';
        Insert svmxprocess2;
        
        SVMXC__ServiceMax_Config_Data__c oConf2 = new SVMXC__ServiceMax_Config_Data__c();
        oConf2.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf2.SVMXC__Field_Name__c = 'SVMXC__Zip__c';
        oConf2.SVMXC__Display_Type__c = 'STRING';
        oConf2.SVMXC__Operand__c = '11111111';
        oConf2.SVMXC__Operator__c = 'eq';
        oConf2.SVMXC__Expression_Rule__c = svmxprocess2.Id;
                        
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
            {
               svmxprocess.RecordTypeId = rt.ID;
               svmxprocess1.RecordTypeId = rt.ID;
               svmxprocess2.RecordTypeId = rt.ID;
            } 
             
            if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
            {
               oConf.RecordTypeId = rt.ID;
               oConf1.RecordTypeId = rt.ID;
               oConf2.RecordTypeId = rt.ID;
            } 
        }
        //dispatchprocessId = svmxprocess.Id;
        
        list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue DPKeyVal = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue TEKeyVal = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue TEKeyVal1 = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        DPKeyVal.name = 'DISPATCHPROCESSID';
        DPKeyVal.value = svmxprocess.Id;
        keyValuePairs.add(DPKeyVal);
        TEKeyVal.name = 'TERRITORYID';
        TEKeyVal.value = Territory1.Id + '_FULL';
        TEKeyVal1.name = 'TERRITORYID';
        TEKeyVal1.value = Territory1.Id + '_INCR';

        TEKeyVal.name = 'TERRITORYID';
        TEKeyVal.value = Territory2.Id + '_FULL';
        TEKeyVal1.name = 'TERRITORYID';
        TEKeyVal1.value = Territory2.Id + '_INCR';

        TEKeyVal.name = 'TERRITORYID';
        TEKeyVal.value = Territory3.Id + '_FULL';
        TEKeyVal1.name = 'TERRITORYID';
        TEKeyVal1.value = Territory3.Id + '_INCR';

        SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs);
        
        keyValuePairs.add(TEKeyVal);
        SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs);

        keyValuePairs.add(TEKeyVal1);
        SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs);
        
        SVMXC__SVMX_Jobs__c precalcCompletedJob = new SVMXC__SVMX_Jobs__c(SVMXC__SVMX_Process__c = svmxprocess.Id, SVMXC__Territory__c = Territory1.Id, SVMXC__OptiMax_Message__c = 'Precalc Completed');
        SVMXC__SVMX_Jobs__c precalcCompletedJob1 = new SVMXC__SVMX_Jobs__c(SVMXC__SVMX_Process__c = svmxprocess.Id, SVMXC__Territory__c = Territory2.Id, SVMXC__OptiMax_Message__c = 'Precalc Failure');
        SVMXC__SVMX_Jobs__c precalcCompletedJob2 = new SVMXC__SVMX_Jobs__c(SVMXC__SVMX_Process__c = svmxprocess.Id, SVMXC__Territory__c = Territory2.Id, SVMXC__OptiMax_Message__c = 'Running Precalc');
        List<SVMXC__SVMX_Jobs__c> lstPrecalcJobs = new List<SVMXC__SVMX_Jobs__c>();
        lstPrecalcJobs.add(precalcCompletedJob);
        lstPrecalcJobs.add(precalcCompletedJob1);
        lstPrecalcJobs.add(precalcCompletedJob2);
        insert lstPrecalcJobs;
        
        list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs1 = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue DPKeyVal1 = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        DPKeyVal1.name = 'DISPATCHPROCESSID';
        DPKeyVal1.value = svmxprocess.Id;
         keyValuePairs1.add(DPKeyVal1);
        SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs1);
        
        list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs2 = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue TEKeyVal2 = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        TEKeyVal2.name = 'TERRITORYID';
        TEKeyVal2.value = Territory1.Id + '_FULL';
        keyValuePairs1.add(TEKeyVal2);
        SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs2);
        
        list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs3 = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue TEKeyVal3 = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        TEKeyVal3.name = 'TERRITORYID';
        TEKeyVal3.value = Territory2.Id + '_INCR';
        keyValuePairs3.add(TEKeyVal3);
       SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs3);
        
        list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs4 = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue TEKeyVal4 = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        TEKeyVal4.name = 'TERRITORYID';
        TEKeyVal4.value = Territory3.Id + '_INCR';
        keyValuePairs4.add(TEKeyVal4);
       SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs4);
        
        List<SVMXC__Service_Order__c> Wo_List = new List<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c workOrderQTL = new SVMXC__Service_Order__c();
        workOrderQTL.SVMXC__Case__c = c.Id;
        workOrderQTL.SVMXC__Company__c = account.Id;
        workOrderQTL.SVMXC__Contact__c =contact.Id;
        workOrderQTL.SVMXC__Latitude__c = 40.739582;
        workOrderQTL.SVMXC__Longitude__c = -73.980772;
        workOrderQTL.SVMXC__Street__c = 'Street1';
        workOrderQTL.SVMXC__City__c = 'BANGALORE';
        workOrderQTL.SVMXC__State__c = 'Karnataka';
        workOrderQTL.SVMXC__Country__c = 'India';
        workOrderQTL.SVMXC__Zip__c = '11111111';
        workOrderQTL.SVMXC__Order_Status__c = 'Open';
        workOrderQTL.SVMXC__Priority__c = 'Medium';
        workOrderQTL.SVMXC__Dispatch_Priority__c = 2;
        workOrderQTL.SVMXC__Order_Type__c = 'Field Service';
        workOrderQTL.SVMXC__Apply_Business_Hours_For_OptiMax__c = false;
        workOrderQTL.SVMXC__Preferred_Business_Hours__c = lBH[0].Id;
        workOrderQTL.SVMXC__Primary_Territory__c = Territory1.Id;
        workOrderQTL.SVMXC__OptiMax_status__c = 'OPT_COMPLETED';
        workOrderQTL.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrderQTL.SVMXC__Dispatch_Process__c = svmxprocess.Id;
        workOrderQTL.SVMXC__Service_Duration__c = 6000;
        workOrderQTL.SVMXC__Locked_By_DC__c = false;
        workOrderQTL.SVMXC__SM_Lock_Appointment_Schedule__c = null;
        workOrderQTL.SVMXC__Scheduled_Date_Time__c  = system.now().addDays(3);
        //insert workOrderQTL;
        Wo_List.add(workOrderQTL);

        SVMXC__Service_Order__c workOrderQTL1 = new SVMXC__Service_Order__c();
        workOrderQTL1.SVMXC__Case__c = c.Id;
        workOrderQTL1.SVMXC__Company__c = account.Id;
        workOrderQTL1.SVMXC__Contact__c =contact.Id;
        workOrderQTL1.SVMXC__Latitude__c = 40.739582;
        workOrderQTL1.SVMXC__Longitude__c = -73.980772;
        workOrderQTL1.SVMXC__Street__c = 'Street1';
        workOrderQTL1.SVMXC__City__c = 'BANGALORE';
        workOrderQTL1.SVMXC__State__c = 'Karnataka';
        workOrderQTL1.SVMXC__Country__c = 'India';
        workOrderQTL1.SVMXC__Zip__c = '11111111';
        workOrderQTL1.SVMXC__Order_Status__c = 'Open';
        workOrderQTL1.SVMXC__Priority__c = 'Medium';
        workOrderQTL1.SVMXC__Dispatch_Priority__c = 2;
        workOrderQTL1.SVMXC__Order_Type__c = 'Field Service';
        workOrderQTL1.SVMXC__Apply_Business_Hours_For_OptiMax__c = false;
        workOrderQTL1.SVMXC__Preferred_Business_Hours__c = lBH[0].Id;
        workOrderQTL1.SVMXC__Primary_Territory__c = Territory2.Id;
        workOrderQTL1.SVMXC__OptiMax_status__c = '';
        workOrderQTL1.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrderQTL1.SVMXC__Dispatch_Process__c = svmxprocess1.Id;
        workOrderQTL1.SVMXC__Service_Duration__c = 6000;
        workOrderQTL1.SVMXC__Locked_By_DC__c = true;
        workOrderQTL1.SVMXC__SM_Lock_Appointment_Schedule__c = WSCH_ECO_Constants.SCHEDULE_LOCK_IN_PLACE;
        workOrderQTL1.SVMXC__Scheduled_Date_Time__c  = system.now().addDays(3);
        //insert workOrderQTL1;
        Wo_List.add(workOrderQTL1);

        SVMXC__Service_Order__c workOrderQTL2 = new SVMXC__Service_Order__c();
        workOrderQTL2.SVMXC__Case__c = c.Id;
        workOrderQTL2.SVMXC__Company__c = account.Id;
        workOrderQTL2.SVMXC__Contact__c =contact.Id;
        workOrderQTL2.SVMXC__Latitude__c = 40.739582;
        workOrderQTL2.SVMXC__Longitude__c = -73.980772;
        workOrderQTL2.SVMXC__Street__c = 'Street1';
        workOrderQTL2.SVMXC__City__c = 'BANGALORE';
        workOrderQTL2.SVMXC__State__c = 'Karnataka';
        workOrderQTL2.SVMXC__Country__c = 'India';
        workOrderQTL2.SVMXC__Zip__c = '11111111';
        workOrderQTL2.SVMXC__Order_Status__c = 'Open';
        workOrderQTL2.SVMXC__Priority__c = 'Medium';
        workOrderQTL2.SVMXC__Dispatch_Priority__c = 2;
        workOrderQTL2.SVMXC__Order_Type__c = 'Field Service';
        workOrderQTL2.SVMXC__Apply_Business_Hours_For_OptiMax__c = false;
        workOrderQTL2.SVMXC__Preferred_Business_Hours__c = lBH[0].Id;
        workOrderQTL2.SVMXC__Primary_Territory__c = Territory3.Id;
        workOrderQTL2.SVMXC__OptiMax_status__c = 'OPT_COMPLETED';
        workOrderQTL2.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrderQTL2.SVMXC__Dispatch_Process__c = svmxprocess2.Id;
        workOrderQTL2.SVMXC__Service_Duration__c = 6000;
        workOrderQTL2.SVMXC__Locked_By_DC__c = false;
        workOrderQTL2.SVMXC__SM_Lock_Appointment_Schedule__c = null;
        workOrderQTL2.SVMXC__Scheduled_Date_Time__c  = system.now().addDays(3);
        //insert workOrderQTL2;
        Wo_List.add(workOrderQTL2);
        insert Wo_List;
        
        //Create technicans
        SVMXC__Service_Group__c sgroup = new SVMXC__Service_Group__c();
        sgroup.SVMXC__Country__c = 'India';
        sgroup.SVMXC__City__c = 'Bangalore';
        Insert sgroup;
        System.assertEquals('India', sgroup.SVMXC__Country__c);
        
        SVMXC__Skill__c objSkillnstallation = new SVMXC__Skill__c();
        objSkillnstallation.Name = 'SkillInstall2';
        objSkillnstallation.SVMXC__Skill_Category__c = 'Installation';
        insert objSkillnstallation;
        
        List<SVMXC__Service_Group_Members__c> technicians= new List<SVMXC__Service_Group_Members__c>();
        SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c();
        tech1.SVMXC__Service_Territory__c =Territory1.Id;
        tech1.SVMXC__Fixed_Cost__c = 2.0;
        tech1.SVMXC__Latitude_Home__c = 37.407843;
        tech1.SVMXC__Longitude_Home__c = -122.008637;
        tech1.SVMXC__Street__c = 'Street 1';
        tech1.SVMXC__City__c = 'Bangalore';
        tech1.SVMXC__State__c = 'Karnataka';
        tech1.SVMXC__Zip__c = '11111111';
        tech1.SVMXC__Country__c = 'India';
        tech1.SVMXC__Per_hour_Cost__c = 2.0; 
        tech1.SVMXC__Per_Mile_Cost__c = 1.0;
        tech1.SVMXC__Average_Speed__c = 2.0;
        tech1.SVMXC__Max_Daily_Hours__c = 2.0;
        tech1.SVMXC__Max_Distance__c = 5.0;
        tech1.SVMXC__Enable_Scheduling__c = true;
        tech1.SVMXC__Service_Group__c =sgroup.Id; 
        if(lBH != NULL && lBH.size()>0)
            tech1.SVMXC__Working_Hours__c = lBH[0].id;
        if(lBH != NULL && lBH.size()>0)
            tech1.SVMXC__Break_Hours__c = lBH[0].id;
        tech1.SVMXC__Active__c  = true;
        technicians.add(tech1);

        SVMXC__Service_Group_Members__c tech2 = new SVMXC__Service_Group_Members__c();
        tech2.SVMXC__Service_Territory__c =Territory2.Id;
        tech2.SVMXC__Fixed_Cost__c = 2.0;
        tech2.SVMXC__Latitude_Home__c = 37.407843;
        tech2.SVMXC__Longitude_Home__c = -122.008637;
        tech2.SVMXC__Street__c = 'Street 1';
        tech2.SVMXC__City__c = 'Bangalore';
        tech2.SVMXC__State__c = 'Karnataka';
        tech2.SVMXC__Zip__c = '11111111';
        tech2.SVMXC__Country__c = 'India';
        tech2.SVMXC__Per_hour_Cost__c = 2.0; 
        tech2.SVMXC__Per_Mile_Cost__c = 1.0;
        tech2.SVMXC__Average_Speed__c = 2.0;
        tech2.SVMXC__Max_Daily_Hours__c = 2.0;
        tech2.SVMXC__Max_Distance__c = 5.0;
        tech2.SVMXC__Enable_Scheduling__c = true;
        tech2.SVMXC__Service_Group__c =sgroup.Id; 
        if(lBH != NULL && lBH.size()>0)
            tech2.SVMXC__Working_Hours__c = lBH[0].id;
        if(lBH != NULL && lBH.size()>0)
            tech2.SVMXC__Break_Hours__c = lBH[0].id;
        tech2.SVMXC__Active__c  = true;
        technicians.add(tech2);

        SVMXC__Service_Group_Members__c tech3 = new SVMXC__Service_Group_Members__c();
        tech3.SVMXC__Service_Territory__c = Territory3.Id;
        tech3.SVMXC__Fixed_Cost__c = 2.0;
        tech3.SVMXC__Latitude_Home__c = 37.407843;
        tech3.SVMXC__Longitude_Home__c = -122.008637;
        tech3.SVMXC__Street__c = 'Street 1';
        tech3.SVMXC__City__c = 'Bangalore';
        tech3.SVMXC__State__c = 'Karnataka';
        tech3.SVMXC__Zip__c = '11111111';
        tech3.SVMXC__Country__c = 'India';
        tech3.SVMXC__Per_hour_Cost__c = 2.0; 
        tech3.SVMXC__Per_Mile_Cost__c = 1.0;
        tech3.SVMXC__Average_Speed__c = 2.0;
        tech3.SVMXC__Max_Daily_Hours__c = 2.0;
        tech3.SVMXC__Max_Distance__c = 5.0;
        tech3.SVMXC__Salesforce_User__c = UserInfo.getUserId();
        tech3.SVMXC__Enable_Scheduling__c = true;
        tech3.SVMXC__Service_Group__c = sgroup.Id; 
        tech3.SVMXC__Active__c  = true;
        if(lBH != NULL && lBH.size()>0)
            tech3.SVMXC__Working_Hours__c = lBH[0].id;
        if(lBH != NULL && lBH.size()>0)
            tech3.SVMXC__Break_Hours__c = lBH[0].id;
        technicians.add(tech3);
        Insert technicians;
        
        SVMXC__Service_Group_Skills__c skillForTech = new SVMXC__Service_Group_Skills__c(SVMXC__Service_Group__c = sgroup.Id, SVMXC__Skill__c = objSkillnstallation.Id);
        insert skillForTech;

        //Create Eligibility Matching Rules
        Id eligibilityProcessId;
        Id eligibilityExpressionId;
        Id skillProcessId;
        Id skillExpressionId;
        Id applicableSkillRectypeId;
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'SVMX Rule' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
            {
                eligibilityProcessId = rt.Id;
                skillProcessId = rt.Id;
            }
             
            if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
            {
                eligibilityExpressionId = rt.Id;
                skillExpressionId = rt.Id;
            }
            if(rt.Name == 'Applicable Skills' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
            {
                applicableSkillRectypeId = rt.Id;
            }
        }
        
        list<SVMXC__ServiceMax_Processes__c> lstRuleProcess = new list<SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Config_Data__c> lstRuleExpressionConf = new list<SVMXC__ServiceMax_Config_Data__c>();
        
        SVMXC__ServiceMax_Processes__c objEligibilityRule_1 = new SVMXC__ServiceMax_Processes__c();
        objEligibilityRule_1.RecordTypeId = eligibilityProcessId;
        objEligibilityRule_1.SVMXC__Rule_Type__c = 'Tech Eligibility';
        objEligibilityRule_1.SVMXC__Name__c = 'Eligibility Rule Test1';
        objEligibilityRule_1.SVMXC__Description__c = 'Eligibility Rule Test1';
        objEligibilityRule_1.SVMXC__Select__c = true;
        objEligibilityRule_1.SVMXC__Rule_Type__c = 'Tech Eligibility';
        objEligibilityRule_1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objEligibilityRule_1.SVMXC__Sequence__c = 1.0000;
        lstRuleProcess.add(objEligibilityRule_1);
        
        SVMXC__ServiceMax_Processes__c objSkillMatchingRule_1 = new SVMXC__ServiceMax_Processes__c();
        objSkillMatchingRule_1.SVMXC__Name__c = 'Skill Rule Test1';
        objSkillMatchingRule_1.SVMXC__Description__c = 'Skill Rule Test1';
        objSkillMatchingRule_1.SVMXC__Select__c = true;               
        objSkillMatchingRule_1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objSkillMatchingRule_1.SVMXC__Sequence__c = 0.0000;
        objSkillMatchingRule_1.SVMXC__Rule_Type__c = 'Skill Matching';
        objSkillMatchingRule_1.RecordTypeId = skillProcessId;
        lstRuleProcess.add(objSkillMatchingRule_1);
        
        SVMXC__ServiceMax_Processes__c objEligibilityRule_2 = new SVMXC__ServiceMax_Processes__c();
        objEligibilityRule_2.RecordTypeId = eligibilityProcessId;
        objEligibilityRule_2.SVMXC__Rule_Type__c = 'Tech Eligibility';
        objEligibilityRule_2.SVMXC__Name__c = 'Eligibility Rule Test2';
        objEligibilityRule_2.SVMXC__Description__c = 'Eligibility Rule Test2';
        objEligibilityRule_2.SVMXC__Select__c = false;
        objEligibilityRule_2.SVMXC__Sequence__c = 2.0000;
        objEligibilityRule_2.SVMXC__Rule_Type__c = 'Tech Eligibility';
        objEligibilityRule_2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        lstRuleProcess.add(objEligibilityRule_2);
        
        insert lstRuleProcess;
        
        SVMXC__ServiceMax_Processes__c objSkillMatchingRule_2 = new SVMXC__ServiceMax_Processes__c();
        objSkillMatchingRule_2.SVMXC__Name__c = 'Skill Rule Test2';
        objSkillMatchingRule_2.SVMXC__Description__c = 'Skill Rule Test2';
        objSkillMatchingRule_2.SVMXC__Select__c = false;
        objSkillMatchingRule_2.SVMXC__Sequence__c = 1.0000;
        objSkillMatchingRule_2.SVMXC__Rule_Type__c = 'Skill Matching';
        objSkillMatchingRule_2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objSkillMatchingRule_2.RecordTypeId = skillProcessId;
        objSkillMatchingRule_2.SVMXC__Node_Parent__c = objSkillMatchingRule_1.Id;
        insert objSkillMatchingRule_2;
        
        SVMXC__ServiceMax_Config_Data__c objEligibilityCriteria = new  SVMXC__ServiceMax_Config_Data__c();
        objEligibilityCriteria.RecordTypeId = eligibilityExpressionId;
        objEligibilityCriteria.SVMXC__Expression_Type__c = 'Tech_Eligibility';
        objEligibilityCriteria.SVMXC__Expression_Rule__c = objEligibilityRule_1.id;
        objEligibilityCriteria.SVMXC__Field_Name__c = 'SVMXC__City__c';
        objEligibilityCriteria.SVMXC__Operator__c = 'eq';
        objEligibilityCriteria.SVMXC__Operand__c = 'Bangalore';
        lstRuleExpressionConf.add(objEligibilityCriteria);
        
        SVMXC__ServiceMax_Config_Data__c objSkillEligibility_1 = new  SVMXC__ServiceMax_Config_Data__c();
        objSkillEligibility_1.SVMXC__Expression_Type__c = 'Skill_Eligibility';
        objSkillEligibility_1.RecordTypeId = skillExpressionId;
        objSkillEligibility_1.SVMXC__Expression_Rule__c = objSkillMatchingRule_1.id;
        objSkillEligibility_1.SVMXC__Expression_Type__c = 'Skill_Eligibility';
        objSkillEligibility_1.SVMXC__Field_Name__c = 'SVMXC__City__c';
        objSkillEligibility_1.SVMXC__Operator__c = 'eq';
        objSkillEligibility_1.SVMXC__Operand__c = 'Bangalore';
        lstRuleExpressionConf.add(objSkillEligibility_1); 
        
        SVMXC__ServiceMax_Config_Data__c skilApplicable_1 = new  SVMXC__ServiceMax_Config_Data__c();
        skilApplicable_1.SVMXC__Skill__c = objSkillnstallation.id;
        skilApplicable_1.RecordTypeId = applicableSkillRectypeId;
        skilApplicable_1.SVMXC__Expression_Rule__c = objSkillMatchingRule_1.id;        
        lstRuleExpressionConf.add(skilApplicable_1);
        
        insert lstRuleExpressionConf;       
        
        SMAX_OptiMax_Engine_WS.QualifiedTechnician_WP objQTL = new SMAX_OptiMax_Engine_WS.QualifiedTechnician_WP(Territory3.Id,5);
        SMAX_OptiMax_Engine_WS.Expertise_WP objExpertise_WP = new SMAX_OptiMax_Engine_WS.Expertise_WP();
        //SMAX_OptiMax_Engine_WS.Expertise_WP objExpertise_WP1 = new SMAX_OptiMax_Engine_WS.Expertise_WP('aaaa','bbb');
        list<SMAX_OptiMax_Engine_WS.Expertise_WP> lstExpertise_WP = new list<SMAX_OptiMax_Engine_WS.Expertise_WP>();
        lstExpertise_WP.add(objExpertise_WP);
        //lstExpertise_WP.add(objExpertise_WP1);
        SMAX_OptiMax_Engine_WS.Product_WP objProduct_WP = new SMAX_OptiMax_Engine_WS.Product_WP();
        //SMAX_OptiMax_Engine_WS.Product_WP objProduct_WP1 = new SMAX_OptiMax_Engine_WS.Product_WP('aaaa','bbb');
        list<SMAX_OptiMax_Engine_WS.Product_WP> lstProduct_WP = new list<SMAX_OptiMax_Engine_WS.Product_WP>();
        lstProduct_WP.add(objProduct_WP);
        //lstProduct_WP.add(objProduct_WP1);
        SMAX_OptiMax_Engine_WS.ExecutionTime_WP objExecutionTime_WP1 = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP();
        SMAX_OptiMax_Engine_WS.ExecutionTime_WP objExecutionTime_WP = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(System.now().addminutes(-60),System.now());
        list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstExecutionTime_WP = new list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
        lstExecutionTime_WP.add(objExecutionTime_WP);
        lstExecutionTime_WP.add(objExecutionTime_WP1);
        SMAX_OptiMax_Engine_WS.Technician_WP objTechnician_WP = new SMAX_OptiMax_Engine_WS.Technician_WP(tech1,lstExecutionTime_WP,lstProduct_WP,lstExpertise_WP,null); 
        SMAX_OptiMax_Engine_WS.Technician_WP objTechnician_WP1 = new SMAX_OptiMax_Engine_WS.Technician_WP(tech1, lstExecutionTime_WP, lstProduct_WP,lstExpertise_WP);
        objTechnician_WP1.gettechProduct_WPL();
        objTechnician_WP1.gettechExpertise_WPL();
        SMAX_OptiMax_Engine_WS.ExecutionTime_WP objexeWP = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(System.now(),System.now());
        objexeWP.setstartDateTime(System.now());
        objexeWP.setendDateTime(System.now());
        set<date> setdate= new set<date>();
        setdate.add(System.today());
        setdate.add(System.today().adddays(1));
        objexeWP.doSplitDays(String.valueof(Userinfo.getTimeZone()),setdate);
        SMAX_OptiMax_Engine_WS.ExecutionTime_WP objexeWP1 = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(System.now(),System.now().adddays(2));
        objexeWP1.doSplitDays(String.valueof(Userinfo.getTimeZone()),setdate);
        SMAX_OptiMax_Engine_WS.WorkOrder_WP objWorkOrder_WP = new SMAX_OptiMax_Engine_WS.WorkOrder_WP(workOrderQTL);
        SMAX_OptiMax_Engine_WS.WorkOrder_WP objWorkOrder_WP1 = new SMAX_OptiMax_Engine_WS.WorkOrder_WP(workOrderQTL, lstExecutionTime_WP, 'abc',null);   
        SMAX_OptiMax_Engine_WS.KeyValue objKeyValue = new SMAX_OptiMax_Engine_WS.KeyValue('TERRITORYID',Territory3.Id); 
        Event SF_Event2 = new Event();
            SF_Event2.ActivityDate = System.today().addDays(1);
            SF_Event2.ActivityDateTime = System.now().addDays(1);
            SF_Event2.StartDateTime = SF_Event2.ActivityDateTime;
            SF_Event2.DurationInMinutes = 60;
            SF_Event2.EndDateTime = System.now().addHours(1).addDays(1);
            SF_Event2.OwnerId = UserInfo.getUserId();
            //insert SF_Event2;
        SMAX_OptiMax_Engine_WS.WorkOrderSchedule_WP objWorkOrderSchedule_WP = new SMAX_OptiMax_Engine_WS.WorkOrderSchedule_WP(String.valueof(SF_Event2.id), tech1.id, System.now(), System.now().addminutes(60), 60);   
        SMAX_OptiMax_Engine_WS.DblLocation_WP objDblLocation_WP2 = new SMAX_OptiMax_Engine_WS.DblLocation_WP();
        SMAX_OptiMax_Engine_WS.DblLocation_WP objDblLocation_WP = new SMAX_OptiMax_Engine_WS.DblLocation_WP(12.975174,77.607995);   
        SMAX_OptiMax_Engine_WS.DblLocation_WP objDblLocation_WP1 = new SMAX_OptiMax_Engine_WS.DblLocation_WP(String.valueof(12.975174),String.valueof(77.607995));
        SMAX_OptiMax_Engine_WS.ExcSetting_WP objExcSetting_WP = new SMAX_OptiMax_Engine_WS.ExcSetting_WP('aaaa','bbb');     
        System.Test.startTest();
        
        SMAX_OptiMax_Engine_WS.SMAX_Run_QTL_WS(keyValuePairs);
        precalcCompletedJob.SVMXC__OptiMax_Message__c = 'QTL Completed';
        update precalcCompletedJob;
        //SMAX_OptiMax_Engine_WS.SMAX_Run_QTL_WS(keyValuePairs);
        SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(Userinfo.getUserId(),Territory1.Id,svmxprocess.Id);

        precalcCompletedJob.SVMXC__OptiMax_Message__c = 'QTL Failure';
        update precalcCompletedJob;
        SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(Userinfo.getUserId(),Territory2.Id,svmxprocess1.Id);
        
            precalcCompletedJob.SVMXC__OptiMax_Message__c = 'Running Precalc';
            update precalcCompletedJob;
            SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(Userinfo.getUserId(),Territory3.Id,svmxprocess2.Id);
            
            precalcCompletedJob.SVMXC__OptiMax_Message__c = 'Precalc Failure';
            update precalcCompletedJob;
            SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(Userinfo.getUserId(),Territory3.Id,svmxprocess2.Id);
            precalcCompletedJob.SVMXC__OptiMax_Message__c = 'Initiated';
            precalcCompletedJob.SVMXC__Start_Time__c = System.now();
            update precalcCompletedJob; 
            SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(Userinfo.getUserId(),Territory3.Id,svmxprocess2.Id);
                        
    }            

    static testMethod void SMAX_OptiMax_Engine_WS_CompleteJob2()
    {
        try
        {
        //Creating data 
        list<string> lstSettings = new list<string>();        
        lstSettings.add('GLOB001_GBL007');
        lstSettings.add('OMAX003_SET030');
        List<SVMXC__ServiceMax_Config_Data__c> lstSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstSettingValues = [SELECT SVMXC__Internal_Value__c, SVMXC__Setting_Unique_ID__c FROM SVMXC__ServiceMax_Config_Data__c WHERE recordType.Name = 'Setting Value'
                            AND SVMXC__Setting_Unique_ID__c IN :lstSettings
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' 
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Global'
                            ];                          
        lstSettingValues[0].SVMXC__Internal_Value__c='True';
        lstSettingValues[1].SVMXC__Internal_Value__c='True';
        upsert lstSettingValues;
        list<string> lstSettings1 = new list<string>();          
        lstSettings1.add('OMAX003_SET032'); //batch size
        lstSettings1.add('OMAX002_SET002'); //dbl age       
        List<SVMXC__ServiceMax_Config_Data__c> lstSettingValues1 = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstSettingValues1 = [SELECT SVMXC__Internal_Value__c, SVMXC__Setting_Unique_ID__c FROM SVMXC__ServiceMax_Config_Data__c WHERE recordType.Name = 'Setting Value'
                            AND SVMXC__Setting_Unique_ID__c IN :lstSettings1
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' 
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Global'
                            ];
        lstSettingValues1[0].SVMXC__Internal_Value__c='20';
        lstSettingValues1[1].SVMXC__Internal_Value__c='60';
        upsert lstSettingValues1;
            case c = new case();
            Account account = new Account(
                                                Name = 'Account',
                                                ShippingStreet= 'ABC',
                                                ShippingCity= 'PQR ',
                                                ShippingState = 'California',
                                                ShippingPostalCode= '111',
                                                ShippingCountry= 'United States',
                                                BillingStreet= 'ABC',
                                                BillingCity= 'PQR ',
                                                BillingState = 'California',
                                                BillingPostalCode= '111',
                                                BillingCountry= 'United States'
                                                );  
            insert account;
            System.assertEquals('Account', account.Name);
            
            List<BusinessHours> lBH = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];
            
            
            Contact contact = new Contact(LastName= 'Last',AccountId =account.Id,Email= 'test@max.com');
            insert contact;
            System.assertEquals('Last', contact.LastName);  
            
            SVMXC__Territory__c T1 = new SVMXC__Territory__c(Name= 'T1',SVMXC__Active__c =true,SVMXC__Territory_Code__c = 'T1',SVMXC__Parent_Territory__c =NULL,SVMXC__Per_Mile_Cost__c=2.0,SVMXC__Max_Distance__c=100,SVMXC__Average_Speed__c=50.0);
            insert T1;
            territoryId = T1.Id;
            RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];
            SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
            
            SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
            oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
            oConf.SVMXC__Field_Name__c = 'SVMXC__Zip__c';
            oConf.SVMXC__Display_Type__c = 'STRING';
            oConf.SVMXC__Operand__c = '11111111';
            oConf.SVMXC__Operator__c = 'eq';
            oConf.SVMXC__Expression_Rule__c =svmxprocess.Id;
            
            
            for(RecordType rt : rts) //Loop to take a record type at a time
            {
                if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                {
                   svmxprocess.RecordTypeId = rt.ID;
                }
                 
                if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                {
                   oConf.RecordTypeId = rt.ID;
                } 
            }
            
            svmxprocess.SVMXC__Territory__c = T1.Id;
            svmxprocess.SVMXC__Description__c = 'abcd';
            svmxprocess.SVMXC__Dispatch_Method__c = 'Optimized Batch';
            svmxprocess.SVMXC__Assign_Work_Order_To__c = 'Technician';
            svmxprocess.SVMXC__Calendar_Start_Type__c = 'SAME DAY';
            svmxprocess.SVMXC__Calendar_End_Type__c = 'SAME DAY';
            svmxprocess.SVMXC__Expertise_Match_Enabled__c =true;
            svmxprocess.SVMXC__Product_Match_Enabled__c =true;
            svmxprocess.SVMXC__Preferred_Tech_Enabled__c =true;
            svmxprocess.SVMXC__Route_Type__c = 'CLOSED';
            svmxprocess.SVMXC__Distance_And_Time__c = 'Actual Distance And Time';
            svmxprocess.SVMXC__Weight_Time_Window__c =1.0000;
            svmxprocess.SVMXC__Weight_Route_Distance__c =1.0000;
            svmxprocess.SVMXC__Weight_Route_Time__c =1.0000;
            svmxprocess.SVMXC__Weight_Node_Type__c =1;
            svmxprocess.SVMXC__Dispatch_Process_Status__c = 'Complete';
            svmxprocess.SVMXC__Runs_Every_Monday__c =true;
            svmxprocess.SVMXC__Runs_Every_Tuesday__c =true;
            svmxprocess.SVMXC__Start_Time__c = '11:00 PM';
            svmxprocess.SVMXC__Frequency__c =1;
            svmxprocess.SVMXC__Full_Run_Unit__c = 'Days';
            svmxprocess.SVMXC__Start_Date__c = date.Today();
            svmxprocess.SVMXC__End_Date__c = date.Today().addDays(1);
            svmxprocess.SVMXC__Weight_Total_Distance__c =1.0000;
            svmxprocess.SVMXC__Calendar_Start_Days__c = 0;
            svmxprocess.SVMXC__Calendar_End_Days__c = 2;
            svmxprocess.SVMXC__Tolerance__c = 30;
            svmxprocess.SVMXC__ProcessID__c = 'PROCESS11';
            svmxprocess.SVMXC__SettingId__c = 'PROCESS11';
            svmxprocess.SVMXC__MapID__c = 'PROCESS11';
            svmxprocess.SVMXC__Name__c = 'PROCESS22';
            Insert svmxprocess;
            dispatchprocessId = svmxprocess.Id;
            System.assertEquals(true, svmxprocess != null);
            
            insert oConf;
            System.assertEquals(true, oConf != null);
            
            List<SVMXC__Service_Order__c> Wo_List = new List<SVMXC__Service_Order__c>();
            SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
            workOrder1.SVMXC__Case__c = c.Id;
            workOrder1.SVMXC__Company__c = account.Id;
            workOrder1.SVMXC__Contact__c =contact.Id;
            workOrder1.SVMXC__Latitude__c = 40.739582;
            workOrder1.SVMXC__Longitude__c = -73.980772;
            workOrder1.SVMXC__Street__c = 'Street1';
            workOrder1.SVMXC__City__c = 'BANGALORE';
            workOrder1.SVMXC__State__c = 'Karnataka';
            workOrder1.SVMXC__Country__c = 'India';
            workOrder1.SVMXC__Zip__c = '11111111';
            workOrder1.SVMXC__Order_Status__c = 'Open';
            workOrder1.SVMXC__Priority__c = 'Medium';
            workOrder1.SVMXC__Dispatch_Priority__c = 2;
            workOrder1.SVMXC__Order_Type__c = 'Field Service';
            workOrder1.SVMXC__Apply_Business_Hours_For_OptiMax__c = false;
            workOrder1.SVMXC__Preferred_Business_Hours__c = lBH[0].Id;
            workOrder1.SVMXC__Primary_Territory__c = T1.Id;
            workOrder1.SVMXC__OptiMax_status__c = '';
            workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
            workOrder1.SVMXC__Dispatch_Process__c = svmxprocess.Id;
            workOrder1.SVMXC__Service_Duration__c = 6000;
            workOrder1.SVMXC__Locked_By_DC__c = true;
            workOrder1.SVMXC__SM_Lock_Appointment_Schedule__c = WSCH_ECO_Constants.SCHEDULE_LOCK_IN_PLACE;
            Wo_List.add(workOrder1);
            
            SVMXC__Service_Order__c workOrder2 = new SVMXC__Service_Order__c();
            workOrder2.SVMXC__Case__c = c.Id;
            workOrder2.SVMXC__Company__c = account.Id;
            workOrder2.SVMXC__Contact__c =contact.Id;
            workOrder2.SVMXC__Latitude__c = 40.739582;
            workOrder2.SVMXC__Longitude__c = -73.980772;
            workOrder2.SVMXC__Street__c = 'Street1';
            workOrder2.SVMXC__City__c = 'BANGALORE';
            workOrder2.SVMXC__State__c = 'Karnataka';
            workOrder2.SVMXC__Country__c = 'India';
            workOrder2.SVMXC__Zip__c = '11111111';
            workOrder2.SVMXC__Order_Status__c = 'Open';
            workOrder2.SVMXC__Priority__c = 'Medium';
            workOrder2.SVMXC__Dispatch_Priority__c = 2;
            workOrder2.SVMXC__Order_Type__c = 'Field Service';
            workOrder2.SVMXC__Apply_Business_Hours_For_OptiMax__c = true;
            workOrder2.SVMXC__Preferred_Start_Time__c = system.now().addDays(-2);
            workOrder2.SVMXC__Preferred_End_Time__c = system.now().addDays(5);
            workOrder2.SVMXC__Primary_Territory__c = T1.Id;
            workOrder2.SVMXC__OptiMax_status__c = '';
            workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
            workOrder2.SVMXC__Dispatch_Process__c = svmxprocess.Id;
            workOrder2.SVMXC__Service_Duration__c = 50000;
            workOrder2.SVMXC__Locked_By_DC__c = false;
            workOrder2.SVMXC__SM_Lock_Appointment_Schedule__c = null;
            Wo_List.add(workOrder2);
            //Insert workOrder2;
            insert Wo_List;
            System.assertEquals(true, Wo_List != null);
            
            SMAX_OptiMax_Engine_WS.WorkOrder_WP woTEST = new SMAX_OptiMax_Engine_WS.WorkOrder_WP(workOrder1);
            
            
            SVMXC__Service_Group__c sgroup = new SVMXC__Service_Group__c();
            sgroup.SVMXC__Country__c = 'India';
            sgroup.SVMXC__City__c = 'Bangalore';
            Insert sgroup;
            System.assertEquals('India', sgroup.SVMXC__Country__c);
            
            
            List<SVMXC__Service_Group_Members__c> technicians= new List<SVMXC__Service_Group_Members__c>();
            SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c();
            tech1.SVMXC__Service_Territory__c =T1.Id;
            ////tech.SVMXC__Salesforce_User__c = UserId.Id;
            tech1.SVMXC__Fixed_Cost__c = 2.0;
            tech1.SVMXC__Latitude_Home__c = 37.407843;
            tech1.SVMXC__Longitude_Home__c = -122.008637;
            tech1.SVMXC__Street__c = 'Street 1';
            tech1.SVMXC__City__c = 'Bangalore';
            tech1.SVMXC__State__c = 'Karnataka';
            tech1.SVMXC__Zip__c = '11111111';
            tech1.SVMXC__Country__c = 'India';
            tech1.SVMXC__Per_hour_Cost__c = 2.0; 
            tech1.SVMXC__Per_Mile_Cost__c = 1.0;
            tech1.SVMXC__Average_Speed__c = 2.0;
            tech1.SVMXC__Max_Daily_Hours__c = 2.0;
            tech1.SVMXC__Max_Distance__c = 5.0;
            // tech1.SVMXC__Max_Weekly_Hours__c = 7.0;
            // tech1.SVMXC__Capacity__c = 1.0;
            tech1.SVMXC__Enable_Scheduling__c = true;
            tech1.SVMXC__Service_Group__c =sgroup.Id; 
            if(lBH != NULL && lBH.size()>0)
            tech1.SVMXC__Working_Hours__c = lBH[0].id;
            technicians.add(tech1);
            SVMXC__Service_Group_Members__c tech = new SVMXC__Service_Group_Members__c();
            tech.SVMXC__Service_Territory__c =T1.Id;
            ////tech.SVMXC__Salesforce_User__c = UserId.Id;
            tech.SVMXC__Fixed_Cost__c = 2.0;
            tech.SVMXC__Latitude_Home__c = 37.407843;
            tech.SVMXC__Longitude_Home__c = -122.008637;
            tech.SVMXC__Street__c = 'Street 1';
            tech.SVMXC__City__c = 'Bangalore';
            tech.SVMXC__State__c = 'Karnataka';
            tech.SVMXC__Zip__c = '11111111';
            tech.SVMXC__Country__c = 'India';
            tech.SVMXC__Per_hour_Cost__c = 2.0; 
            tech.SVMXC__Per_Mile_Cost__c = 1.0;
            tech.SVMXC__Average_Speed__c = 2.0;
            tech.SVMXC__Max_Daily_Hours__c = 2.0;
            tech.SVMXC__Max_Distance__c = 5.0;
            tech.SVMXC__Salesforce_User__c = UserInfo.getUserId();
            // tech.SVMXC__Max_Weekly_Hours__c = 7.0;
            // tech.SVMXC__Capacity__c = 1.0;
            tech.SVMXC__Enable_Scheduling__c = true;
            tech.SVMXC__Service_Group__c =sgroup.Id; 
            if(lBH != NULL && lBH.size()>0)
            tech.SVMXC__Working_Hours__c = lBH[0].id;
            technicians.add(tech);
            Insert technicians;
            
            List<Event> SF_Event_L = new List<Event>();
            Event SF_Event = new Event();
            SF_Event.ActivityDate = System.today();
            SF_Event.ActivityDateTime = System.now();
            SF_Event.StartDateTime = SF_Event.ActivityDateTime;
            SF_Event.DurationInMinutes = 60;
            SF_Event.EndDateTime = System.now().addHours(1);
            SF_Event.OwnerId = UserInfo.getUserId();
            SF_Event_L.add(SF_Event);
            Event SF_Event2 = new Event();
            SF_Event2.ActivityDate = System.today().addDays(1);
            SF_Event2.ActivityDateTime = System.now().addDays(1);
            SF_Event2.StartDateTime = SF_Event2.ActivityDateTime;
            SF_Event2.DurationInMinutes = 60;
            SF_Event2.EndDateTime = System.now().addHours(1).addDays(1);
            SF_Event2.OwnerId = UserInfo.getUserId();
            SF_Event_L.add(SF_Event2);
            insert SF_Event_L;
            System.assertEquals(true, SF_Event_L != null);
            
            System.debug('Just before Initiate Job:1');
            SVMXC__Skill__c sk = new SVMXC__Skill__c(Name = 'TEST');
            insert sk;
            SVMXC__Service_Group_Skills__c gmS = new SVMXC__Service_Group_Skills__c(SVMXC__Group_Member__c = tech.Id, SVMXC__Skill__c = sk.Id, SVMXC__Service_Group__c = sgroup.Id);
            insert gmS;
            Product2 prod = new Product2(Name = 'TP');
            insert prod;
            SVMXC__Service_Group_Product__c gmP = new SVMXC__Service_Group_Product__c(SVMXC__Group_Member__c = tech.Id, SVMXC__Product__c = prod.Id, SVMXC__Service_Group__c = sgroup.Id);
            insert gmP;
            
            SMAX_OptiMax_Engine_WS OmaxEngineWs = new SMAX_OptiMax_Engine_WS();
            System.debug('Just before Initiate Job:2');
            //Initiate Jobs

            // SMAX_OptiMax_Engine_WS.opInitateJobs_WP initiateCall1 = SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(UserInfo.getUserId(),T1.Id,svmxprocess.Id);
            
            // jobId = initiateCall1.jobId;
            ////SMAX_OptiMax_Engine_WS.WorkOrder_WP OmaxEngineWsWoWp = new SMAX_OptiMax_Engine_WS.WorkOrder_WP(Wo);
            SVMXC__Service_Group_Members__c t = new SVMXC__Service_Group_Members__c();
            List<Time> ListeventTime = new List<Time>();
            List<Product2> products = new List<Product2>();
            List<SVMXC__Service_Group_Skills__c> skills = new List<SVMXC__Service_Group_Skills__c>();
            
            SMAX_OptiMax_Engine_WS.ExecutionTime_WP OmaxEngineWsET = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP();
            List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstWsET = new List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
            SMAX_OptiMax_Engine_WS.Product_WP OmaxEngineWsProd = new SMAX_OptiMax_Engine_WS.Product_WP();
            List<SMAX_OptiMax_Engine_WS.Product_WP> lstprodwp = new List<SMAX_OptiMax_Engine_WS.Product_WP>();
            SMAX_OptiMax_Engine_WS.Expertise_WP OmaxEngineWsExp = new SMAX_OptiMax_Engine_WS.Expertise_WP();
            List<SMAX_OptiMax_Engine_WS.Expertise_WP> lstExpwp = new List<SMAX_OptiMax_Engine_WS.Expertise_WP>();
            
            SMAX_OptiMax_Engine_WS.Technician_WP OmaxEngineWsTechws = new SMAX_OptiMax_Engine_WS.Technician_WP(t,lstWsET,lstprodwp,lstExpwp,'t'); 
            OmaxEngineWsTechws.gettechProduct_WPL();
            OmaxEngineWsTechws.gettechExpertise_WPL();
            OmaxEngineWsTechws.currentAddress = ''; 
            OmaxEngineWsTechws.currentLatitude = 0.0;
            OmaxEngineWsTechws.currentLongitude = 0.0;
            OmaxEngineWsTechws.capacity = 0.0;
            SMAX_OptiMax_Engine_WS.ExcSetting_WP OmaxEngineWsEset = new SMAX_OptiMax_Engine_WS.ExcSetting_WP();
            
            //Oncomplete Jobs WS
            List<SVMXC__SVMX_Jobs__c> lstJobs = new list<SVMXC__SVMX_Jobs__c>();
            SVMXC__SVMX_Jobs__c jobs = new SVMXC__SVMX_Jobs__c();
            jobs.SVMXC__SVMX_Process__c = svmxprocess.Id;
            jobs.SVMXC__Territory__c = T1.Id;
            jobs.SVMXC__Age__c = 2000;
            jobs.SVMXC__Start_Time__c =system.now();
            jobs.SVMXC__OptiMax_Message__c = 'In Progress';
            jobs.SVMXC__End_Time__c =  system.now().addDays(1);
            jobs.SVMXC__Message__c = workOrder1.Id+'~|~'+SF_Event_L[0].Id;
            lstJobs.add(jobs);
            
            SVMXC__SVMX_Jobs__c job1 = new SVMXC__SVMX_Jobs__c();
            job1.SVMXC__SVMX_Process__c = svmxprocess.Id;
            job1.SVMXC__Territory__c = T1.Id;
            job1.SVMXC__OptiMax_Message__c = 'In Progress';
            job1.SVMXC__Start_Time__c = system.now();
            lstJobs.add(job1);
            
            SVMXC__SVMX_Jobs__c job2 = new SVMXC__SVMX_Jobs__c();
            job2.SVMXC__SVMX_Process__c = svmxprocess.Id;
            job2.SVMXC__Territory__c = T1.Id;
            job2.SVMXC__OptiMax_Message__c = 'In Progress';
            job2.SVMXC__Start_Time__c = system.now().addDays(-2);
            lstJobs.add(job2);
            
            insert lstJobs;
            System.assertEquals(true, jobs != null);
            
            SMAX_OptiMax_Engine_WS.opInitateJobs_WP OmaxEngineWsInitjobs = new SMAX_OptiMax_Engine_WS.opInitateJobs_WP();
            OmaxEngineWsInitjobs.jobId = jobs.Id;
            OmaxEngineWsInitjobs.jobNo = jobs.Name;
            OmaxEngineWsInitjobs.status = 2;
            OmaxEngineWsInitjobs.message = jobs.SVMXC__OptiMax_Message__c;
            OmaxEngineWsInitjobs.sentWOCount = 0;
            OmaxEngineWsInitjobs.sentEventCount=0;
            OmaxEngineWsInitjobs.sentTechCount=0;
            OmaxEngineWsInitjobs.getworkOrder_LWP();
            OmaxEngineWsInitjobs.gettechnician_LWP();
            OmaxEngineWsInitjobs.getExec_SettingsMap();            
            //Violation info
            List<SMAX_OptiMax_Engine_WS.Violations_WP> woViolations = new List<SMAX_OptiMax_Engine_WS.Violations_WP>();
            SMAX_OptiMax_Engine_WS.Violations_WP woViolation = new SMAX_OptiMax_Engine_WS.Violations_WP();
            woViolation.attribute='Node';
            woViolation.category='Time Constraints';
            woViolation.value='Time Exceded';
            woViolations.add(woViolation);
            
            //Desination info
            SMAX_OptiMax_Engine_WS.DestinationNodes_WP dest1 = new SMAX_OptiMax_Engine_WS.DestinationNodes_WP();
            dest1.sequenceNo = 1;
            dest1.workorderId = workOrder1.Id;
            dest1.arraivalTime = system.now()-10;
            dest1.departureTime = system.now()-5;
            dest1.drivingTime = 5;
            dest1.violations_WPL=woViolations;
            List<SMAX_OptiMax_Engine_WS.DestinationNodes_WP> dest_O1 = new List<SMAX_OptiMax_Engine_WS.DestinationNodes_WP>();
            dest_O1.add(dest1);
            //Desination info
            SMAX_OptiMax_Engine_WS.DestinationNodes_WP dest2 = new SMAX_OptiMax_Engine_WS.DestinationNodes_WP();
            dest2.sequenceNo = 1;
            dest2.workorderId = workOrder2.Id + '_' + SF_Event2.Id;
            dest2.arraivalTime = system.now()-10;
            dest2.departureTime = system.now()-5;
            dest2.drivingTime = 5;
            dest2.violations_WPL=woViolations;
            List<SMAX_OptiMax_Engine_WS.DestinationNodes_WP> dest_O2 = new List<SMAX_OptiMax_Engine_WS.DestinationNodes_WP>();
            dest_O2.add(dest2);

            //Desination info for ONS
            SMAX_OptiMax_Engine_WS.DestinationNodes_WP destOns = new SMAX_OptiMax_Engine_WS.DestinationNodes_WP();
            destOns.sequenceNo = 0;
            destOns.workorderId = 'ONS_13_'+tech.Id;
            destOns.arraivalTime = system.now()-10;
            destOns.departureTime = system.now()-5;
            destOns.drivingTime = 5;
            destOns.violations_WPL=woViolations;
            List<SMAX_OptiMax_Engine_WS.DestinationNodes_WP> dest_Ons = new List<SMAX_OptiMax_Engine_WS.DestinationNodes_WP>();
            dest_Ons.add(destOns);
 
             //Desination info for ONS_returndrive
            SMAX_OptiMax_Engine_WS.DestinationNodes_WP destOns1 = new SMAX_OptiMax_Engine_WS.DestinationNodes_WP();
            destOns1.sequenceNo = 1;
            destOns1.workorderId = 'ONS_13_'+tech.Id+'_ReturnDriveHome';
            destOns1.arraivalTime = system.now()-10;
            destOns1.departureTime = system.now()-5;
            destOns1.drivingTime = 5;
            destOns1.violations_WPL=woViolations;
            dest_Ons.add(destOns1);  

            //Route Info
            SMAX_OptiMax_Engine_WS.Route_WP routeons = new SMAX_OptiMax_Engine_WS.Route_WP();
            routeons.routeId = 'ROUTE5';
            routeons.resourceId = tech.Id;
            routeons.destinationNodes_WPL = dest_Ons;
            routeons.startLocationElementId=tech.Id;
            routeons.endLocationElementId = workOrder2.id;
                                             
            //Route Info
            SMAX_OptiMax_Engine_WS.Route_WP route1 = new SMAX_OptiMax_Engine_WS.Route_WP();
            route1.routeId = 'ROUTE1';
            route1.resourceId = tech.Id+'_DAY1';
            route1.destinationNodes_WPL = dest_O1;
            route1.startLocationElementId=tech.Id;
            route1.endLocationElementId = workOrder2.id;
            
            
            //Route Info
            SMAX_OptiMax_Engine_WS.Route_WP route2 = new SMAX_OptiMax_Engine_WS.Route_WP();
            route2.routeId = 'ROUTE1';
            route2.resourceId = tech1.Id+'_DAY1';
            route2.destinationNodes_WPL = dest_O2;
            
            List<SMAX_OptiMax_Engine_WS.Route_WP> routes = new List<SMAX_OptiMax_Engine_WS.Route_WP>();
            routes.add(route1);
            routes.add(route2);
            routes.add(routeons);
            
            SMAX_OptiMax_Engine_WS.ipCompleteJobs_WP OmaxEngineWsipcompjobs = new SMAX_OptiMax_Engine_WS.ipCompleteJobs_WP();
            OmaxEngineWsipcompjobs.dispatchProcessId = svmxprocess.Id; 
            OmaxEngineWsipcompjobs.territoryId = T1.Id;
            OmaxEngineWsipcompjobs.jobId = jobs.id;
            OmaxEngineWsipcompjobs.gettotalRouteTime_WP();
            OmaxEngineWsipcompjobs.settotalRouteTime_WP(OmaxEngineWsipcompjobs.totalRouteTime_WP);
            OmaxEngineWsipcompjobs.route_WPL=routes;
            System.debug('TEST LOG101:'+OmaxEngineWsipcompjobs.getroute_WPL());
            OmaxEngineWsipcompjobs.getstatics_WPL();
            OmaxEngineWsipcompjobs.setstatics_WPL(OmaxEngineWsipcompjobs.statics_WPL);
            OmaxEngineWsipcompjobs.getexeLog_WPL();
            OmaxEngineWsipcompjobs.setexeLog_WPL(OmaxEngineWsipcompjobs.exeLog_WPL);
            
            List<SMAX_OptiMax_Engine_WS.WorkOrderDetail_WP> WO_LatLng_L = new List<SMAX_OptiMax_Engine_WS.WorkOrderDetail_WP>();
            SMAX_OptiMax_Engine_WS.WorkOrderDetail_WP WO_LatLng = new SMAX_OptiMax_Engine_WS.WorkOrderDetail_WP();
            WO_LatLng.workOrderId = workOrder2.Id;
            WO_LatLng.location = new SMAX_OptiMax_Engine_WS.Location_WP('0','0');
            WO_LatLng_L.add(WO_LatLng);
            OmaxEngineWsipcompjobs.workOrder_WPL = WO_LatLng_L;
            
            SMAX_OptiMax_Engine_WS.TotalRouteTime_WP OmaxEngineWsTrTime = new SMAX_OptiMax_Engine_WS.TotalRouteTime_WP();
            SMAX_OptiMax_Engine_WS.Route_WP OmaxEngineWsRWP = new SMAX_OptiMax_Engine_WS.Route_WP();
            OmaxEngineWsRWP.routeId= 'abcd';
            OmaxEngineWsRWP.resourceId= 'abcd';
                   
            OmaxEngineWsRWP.getviolations_WPL();
            OmaxEngineWsRWP.setviolations_WPL(OmaxEngineWsRWP.getviolations_WPL());
            OmaxEngineWsRWP.getdestinationNodes_WPL();

            SMAX_OptiMax_Engine_WS.DestinationNodes_WP  OmaxEngineWsDnwp= new SMAX_OptiMax_Engine_WS.DestinationNodes_WP();
            OmaxEngineWsDnwp.violations_WPL=woViolations;
            OmaxEngineWsDnwp.workorderId=workOrder1.Id;
            OmaxEngineWsDnwp.getviolations_WP();
            //OmaxEngineWsDnwp.setviolations_WPL(OmaxEngineWsDnwp.getviolations_WP());

            SMAX_OptiMax_Engine_WS.SMAX_Complete_OptiMax_Job_WS(OmaxEngineWsipcompjobs);
                        
            List<SMAX_OptiMax_Engine_WS.ExeLog_WP> lstOmaxEngineWsELp = new List<SMAX_OptiMax_Engine_WS.ExeLog_WP>();
            List<SMAX_OptiMax_Engine_WS.Statics_WP> lstOmaxEngineWsStsp = new List<SMAX_OptiMax_Engine_WS.Statics_WP>();
            
            SMAX_OptiMax_Engine_WS.Statics_WP OmaxEngineWsSwp = new SMAX_OptiMax_Engine_WS.Statics_WP();
            OmaxEngineWsSwp.statName = 'Input Work Order Count';
            OmaxEngineWsSwp.value = '4.0';
            OmaxEngineWsSwp.units = 10;
            OmaxEngineWsSwp.unit = 'count';
            SMAX_OptiMax_Engine_WS.ExeLog_WP OmaxEngineWsELp = new SMAX_OptiMax_Engine_WS.ExeLog_WP();
            OmaxEngineWsELp.logLevel = -1;
            OmaxEngineWsELp.message = 'No work orders available';
            SMAX_OptiMax_Engine_WS.ExeLog_WP OmaxEngineWsELp2 = new SMAX_OptiMax_Engine_WS.ExeLog_WP();
            OmaxEngineWsELp.logLevel = -2;
            OmaxEngineWsELp.message = 'No technicians available';
            SMAX_OptiMax_Engine_WS.ExeLog_WP OmaxEngineWsELp3 = new SMAX_OptiMax_Engine_WS.ExeLog_WP();
            OmaxEngineWsELp.logLevel = -3;
            OmaxEngineWsELp.message = 'No events available';
            lstOmaxEngineWsELp.add(OmaxEngineWsELp);
            lstOmaxEngineWsELp.add(OmaxEngineWsELp2);
            lstOmaxEngineWsELp.add(OmaxEngineWsELp3);
            lstOmaxEngineWsStsp.add(OmaxEngineWsSwp);
            SMAX_OptiMax_Engine_WS.WorkOrderDetail_WP OmaxEngineWsODl = new SMAX_OptiMax_Engine_WS.WorkOrderDetail_WP();
            SMAX_OptiMax_Engine_WS.TechnicianDetail_WP OmaxEngineWsOD2 = new SMAX_OptiMax_Engine_WS.TechnicianDetail_WP();
            SMAX_OptiMax_Engine_WS.TechnicianAdditonalDetails_WP techAdditionalDetailsWP = new SMAX_OptiMax_Engine_WS.TechnicianAdditonalDetails_WP();
            OmaxEngineWsipcompjobs.exeLog_WPL = lstOmaxEngineWsELp;
            OmaxEngineWsipcompjobs.statics_WPL = lstOmaxEngineWsStsp;
            System.debug(logginglevel.WARN, 'Just before second complete job call');
            OmaxEngineWsipcompjobs.setstatics_WPL(OmaxEngineWsipcompjobs.statics_WPL);
            OmaxEngineWsipcompjobs.setexeLog_WPL(OmaxEngineWsipcompjobs.exeLog_WPL);
            System.debug(logginglevel.WARN, 'Just before second complete job call'+OmaxEngineWsipcompjobs.getexeLog_WPL());
            SMAX_OptiMax_Engine_WS.SMAX_Complete_OptiMax_Job_WS(OmaxEngineWsipcompjobs);
            
            OmaxEngineWsipcompjobs.scheduleWOCount = -1;
            SMAX_OptiMax_Engine_WS.SMAX_Complete_OptiMax_Job_WS(OmaxEngineWsipcompjobs);
            

            
            //Zombie job coverage
            List<SVMXC__SVMX_Jobs__c> lstJobsZombie = new list<SVMXC__SVMX_Jobs__c>();
            SVMXC__SVMX_Jobs__c jobZombie = new SVMXC__SVMX_Jobs__c();
            jobZombie.SVMXC__SVMX_Process__c = svmxprocess.Id;
            jobZombie.SVMXC__Territory__c = T1.Id;
            jobZombie.SVMXC__OptiMax_Message__c = 'Canceled - Zombie';
            jobZombie.SVMXC__Start_Time__c = system.now().addDays(1);
            lstJobsZombie.add(jobZombie);
            
            insert lstJobsZombie;
            SMAX_OptiMax_Engine_WS.SMAX_Complete_OptiMax_Job_WS(OmaxEngineWsipcompjobs);

        }
        catch(Exception ex){
              System.debug(logginglevel.WARN, ex.getMessage());
        }
    }
    
     static testMethod void InitiateJobSum16()
    {
        //Creating data 
       /* SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
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
        
        //set GBL007 true and licence
        AllsvmxSettingList.put('GLOB001',svmxSettingListOMAX003);   */        

        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        list<string> lstSettings = new list<string>();
        lstSettings.add('OMAX003_SET030');
        lstSettings.add('OMAX003_SET032');
        lstSettings.add('GLOB001_GBL007');
        //Apurva
        lstSettings.add('OMAX002_SET002');
        map<String, String> mapSetting = commSettings.SVMX_getGlobalSettingList(lstSettings);
        mapSetting.put('GLOB001_GBL007','True');

        case c = new case();
        Account account = new Account(
                                                Name = 'Account',
                                                ShippingStreet= 'ABC',
                                                ShippingCity= 'PQR ',
                                                ShippingState = 'California',
                                                ShippingPostalCode= '111',
                                                ShippingCountry= 'United States',
                                                BillingStreet= 'ABC',
                                                BillingCity= 'PQR ',
                                                BillingState = 'California',
                                                BillingPostalCode= '111',
                                                BillingCountry= 'United States'
                                                ); 
        insert account;
        System.assertEquals('Account', account.Name);
        
        List<BusinessHours> lBH = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];
        
        
        Contact contact = new Contact(LastName= 'Last',AccountId =account.Id,Email= 'test@max.com');
        insert contact;
        System.assertEquals('Last', contact.LastName);

        SVMXC__Territory__c Territory3 = new SVMXC__Territory__c(Name= 'Territory3',SVMXC__Active__c =true,SVMXC__Territory_Code__c = 'Territory3',SVMXC__Parent_Territory__c =NULL,SVMXC__Per_Mile_Cost__c=1.0,SVMXC__Max_Distance__c=5,SVMXC__Average_Speed__c=70.0);
        insert Territory3;
        
        territoryId = Territory3.Id;
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType];
        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        
        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c = 'SVMXC__Zip__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c = '11111111';
        oConf.SVMXC__Operator__c = 'eq';
        oConf.SVMXC__Expression_Rule__c = svmxprocess.Id;
        
        
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
            {
               svmxprocess.RecordTypeId = rt.ID;
            } 
             
            if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
            {
               oConf.RecordTypeId = rt.ID;
            } 
        }
        
        svmxprocess.SVMXC__Territory__c = Territory3.Id;
        svmxprocess.SVMXC__Description__c = 'abcd';
        svmxprocess.SVMXC__Dispatch_Method__c = 'Optimized Batch';
        svmxprocess.SVMXC__Assign_Work_Order_To__c = 'Technician';
        svmxprocess.SVMXC__Calendar_Start_Type__c = 'SAME DAY';
        svmxprocess.SVMXC__Calendar_End_Type__c = 'SAME DAY';
        svmxprocess.SVMXC__Expertise_Match_Enabled__c =true;
        svmxprocess.SVMXC__Product_Match_Enabled__c =true;
        svmxprocess.SVMXC__Preferred_Tech_Enabled__c =true;
        svmxprocess.SVMXC__Route_Type__c = 'CLOSED';
        svmxprocess.SVMXC__Distance_And_Time__c = 'Actual Distance And Time';
        svmxprocess.SVMXC__Weight_Time_Window__c =1.0000;
        svmxprocess.SVMXC__Weight_Route_Distance__c =1.0000;
        svmxprocess.SVMXC__Weight_Route_Time__c =1.0000;
        svmxprocess.SVMXC__Weight_Node_Type__c =1;
        svmxprocess.SVMXC__Dispatch_Process_Status__c = 'Complete';
        svmxprocess.SVMXC__Runs_Every_Monday__c =true;
        svmxprocess.SVMXC__Runs_Every_Tuesday__c =true;
        svmxprocess.SVMXC__Start_Time__c = '11:00 PM';
        svmxprocess.SVMXC__Frequency__c =1;
        svmxprocess.SVMXC__Full_Run_Unit__c = 'Days';
        svmxprocess.SVMXC__Start_Date__c = date.Today();
        svmxprocess.SVMXC__End_Date__c = date.Today().addDays(1);
        svmxprocess.SVMXC__Weight_Total_Distance__c =1.0000;
        svmxprocess.SVMXC__Calendar_Start_Days__c = 0;
        svmxprocess.SVMXC__Calendar_End_Days__c = 2;
        svmxprocess.SVMXC__Tolerance__c = 30;
        svmxprocess.SVMXC__ProcessID__c = 'PROCESS11';
        svmxprocess.SVMXC__SettingId__c = 'PROCESS11';
        svmxprocess.SVMXC__MapID__c = 'PROCESS11';
        svmxprocess.SVMXC__Name__c = 'PROCESS22';
        Insert svmxprocess;
        dispatchprocessId = svmxprocess.Id;
        
        list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue DPKeyVal = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue TEKeyVal = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue TEKeyVal1 = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        DPKeyVal.name = 'DISPATCHPROCESSID';
        DPKeyVal.value = dispatchprocessId;
        keyValuePairs.add(DPKeyVal);
        TEKeyVal.name = 'TERRITORYID';
        TEKeyVal.value = Territory3.Id + '_FULL';
        TEKeyVal1.name = 'TERRITORYID';
        TEKeyVal1.value = Territory3.Id + '_INCR';

        SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs);
        
        keyValuePairs.add(TEKeyVal);
        SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs);

        keyValuePairs.add(TEKeyVal1);
        SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs);
        
        SVMXC__SVMX_Jobs__c precalcCompletedJob = new SVMXC__SVMX_Jobs__c(SVMXC__SVMX_Process__c = dispatchprocessId, SVMXC__Territory__c = Territory3.Id, SVMXC__OptiMax_Message__c = 'Precalc Completed');
        SVMXC__SVMX_Jobs__c precalcCompletedJob4 = new SVMXC__SVMX_Jobs__c(SVMXC__SVMX_Process__c = dispatchprocessId, SVMXC__Territory__c = Territory3.Id, SVMXC__OptiMax_Message__c = 'Precalc Failure');
        SVMXC__SVMX_Jobs__c precalcCompletedJob5 = new SVMXC__SVMX_Jobs__c(SVMXC__SVMX_Process__c = dispatchprocessId, SVMXC__Territory__c = Territory3.Id, SVMXC__OptiMax_Message__c = 'Running Precalc');
        List<SVMXC__SVMX_Jobs__c> lstPrecalcJobs = new List<SVMXC__SVMX_Jobs__c>();
        lstPrecalcJobs.add(precalcCompletedJob);
        lstPrecalcJobs.add(precalcCompletedJob4);
        lstPrecalcJobs.add(precalcCompletedJob5);
        insert lstPrecalcJobs;
        
        list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs1 = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue DPKeyVal1 = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        DPKeyVal1.name = 'DISPATCHPROCESSID';
        DPKeyVal1.value = dispatchprocessId;
         keyValuePairs1.add(DPKeyVal1);
        SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs1);
        
        list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs2 = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue TEKeyVal2 = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        TEKeyVal2.name = 'TERRITORYID';
        TEKeyVal2.value = Territory3.Id + '_FULL';
        keyValuePairs1.add(TEKeyVal2);
        SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs2);
        
        list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs3 = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue TEKeyVal3 = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        TEKeyVal3.name = 'TERRITORYID';
        TEKeyVal3.value = Territory3.Id + '_INCR';
        keyValuePairs3.add(TEKeyVal3);
       SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs3);
        
        SVMXC__Service_Order__c workOrderQTL = new SVMXC__Service_Order__c();
        workOrderQTL.SVMXC__Case__c = c.Id;
        workOrderQTL.SVMXC__Company__c = account.Id;
        workOrderQTL.SVMXC__Contact__c =contact.Id;
        workOrderQTL.SVMXC__Latitude__c = 40.739582;
        workOrderQTL.SVMXC__Longitude__c = -73.980772;
        workOrderQTL.SVMXC__Street__c = 'Street1';
        workOrderQTL.SVMXC__City__c = 'BANGALORE';
        workOrderQTL.SVMXC__State__c = 'Karnataka';
        workOrderQTL.SVMXC__Country__c = 'India';
        workOrderQTL.SVMXC__Zip__c = '11111111';
        workOrderQTL.SVMXC__Order_Status__c = 'Open';
        workOrderQTL.SVMXC__Priority__c = 'Medium';
        workOrderQTL.SVMXC__Dispatch_Priority__c = 2;
        workOrderQTL.SVMXC__Order_Type__c = 'Field Service';
        workOrderQTL.SVMXC__Apply_Business_Hours_For_OptiMax__c = false;
        workOrderQTL.SVMXC__Preferred_Business_Hours__c = lBH[0].Id;
        workOrderQTL.SVMXC__Primary_Territory__c = Territory3.Id;
        workOrderQTL.SVMXC__OptiMax_status__c = 'OPT_COMPLETED';
        workOrderQTL.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrderQTL.SVMXC__Dispatch_Process__c = dispatchprocessId;
        workOrderQTL.SVMXC__Service_Duration__c = 6000;
        workOrderQTL.SVMXC__Locked_By_DC__c = false;
        workOrderQTL.SVMXC__SM_Lock_Appointment_Schedule__c = null;
        workOrderQTL.SVMXC__Scheduled_Date_Time__c  = system.now().addDays(3);
        insert workOrderQTL;
        
        //Create technicans
        SVMXC__Service_Group__c sgroup = new SVMXC__Service_Group__c();
        sgroup.SVMXC__Country__c = 'India';
        sgroup.SVMXC__City__c = 'Bangalore';
        Insert sgroup;
        System.assertEquals('India', sgroup.SVMXC__Country__c);
        
        SVMXC__Skill__c objSkillnstallation = new SVMXC__Skill__c();
        objSkillnstallation.Name = 'SkillInstall2';
        objSkillnstallation.SVMXC__Skill_Category__c = 'Installation';
        insert objSkillnstallation;
        
        List<SVMXC__Service_Group_Members__c> technicians= new List<SVMXC__Service_Group_Members__c>();
        SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c();
        tech1.SVMXC__Service_Territory__c =Territory3.Id;
        tech1.SVMXC__Fixed_Cost__c = 2.0;
        tech1.SVMXC__Latitude_Home__c = 37.407843;
        tech1.SVMXC__Longitude_Home__c = -122.008637;
        tech1.SVMXC__Street__c = 'Street 1';
        tech1.SVMXC__City__c = 'Bangalore';
        tech1.SVMXC__State__c = 'Karnataka';
        tech1.SVMXC__Zip__c = '11111111';
        tech1.SVMXC__Country__c = 'India';
        tech1.SVMXC__Per_hour_Cost__c = 2.0; 
        tech1.SVMXC__Per_Mile_Cost__c = 1.0;
        tech1.SVMXC__Average_Speed__c = 2.0;
        tech1.SVMXC__Max_Daily_Hours__c = 2.0;
        tech1.SVMXC__Max_Distance__c = 5.0;
        tech1.SVMXC__Enable_Scheduling__c = true;
        tech1.SVMXC__Service_Group__c =sgroup.Id; 
        if(lBH != NULL && lBH.size()>0)
            tech1.SVMXC__Working_Hours__c = lBH[0].id;
        tech1.SVMXC__Active__c  = true;
        technicians.add(tech1);

        SVMXC__Service_Group_Members__c tech = new SVMXC__Service_Group_Members__c();
        tech.SVMXC__Service_Territory__c = Territory3.Id;
        tech.SVMXC__Fixed_Cost__c = 2.0;
        tech.SVMXC__Latitude_Home__c = 37.407843;
        tech.SVMXC__Longitude_Home__c = -122.008637;
        tech.SVMXC__Street__c = 'Street 1';
        tech.SVMXC__City__c = 'Bangalore';
        tech.SVMXC__State__c = 'Karnataka';
        tech.SVMXC__Zip__c = '11111111';
        tech.SVMXC__Country__c = 'India';
        tech.SVMXC__Per_hour_Cost__c = 2.0; 
        tech.SVMXC__Per_Mile_Cost__c = 1.0;
        tech.SVMXC__Average_Speed__c = 2.0;
        tech.SVMXC__Max_Daily_Hours__c = 2.0;
        tech.SVMXC__Max_Distance__c = 5.0;
        tech.SVMXC__Salesforce_User__c = UserInfo.getUserId();
        tech.SVMXC__Enable_Scheduling__c = true;
        tech.SVMXC__Service_Group__c = sgroup.Id; 
        tech.SVMXC__Active__c  = true;
        if(lBH != NULL && lBH.size()>0)
            tech.SVMXC__Working_Hours__c = lBH[0].id;
        technicians.add(tech);
        Insert technicians;
        
        SVMXC__Service_Group_Skills__c skillForTech = new SVMXC__Service_Group_Skills__c(SVMXC__Service_Group__c = sgroup.Id, SVMXC__Skill__c = objSkillnstallation.Id);
        insert skillForTech;

        //Create Eligibility Matching Rules
        Id eligibilityProcessId;
        Id eligibilityExpressionId;
        Id skillProcessId;
        Id skillExpressionId;
        Id applicableSkillRectypeId;
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'SVMX Rule' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
            {
                eligibilityProcessId = rt.Id;
                skillProcessId = rt.Id;
            }
             
            if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
            {
                eligibilityExpressionId = rt.Id;
                skillExpressionId = rt.Id;
            }
            if(rt.Name == 'Applicable Skills' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
            {
                applicableSkillRectypeId = rt.Id;
            }
        }
        
        list<SVMXC__ServiceMax_Processes__c> lstRuleProcess = new list<SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Config_Data__c> lstRuleExpressionConf = new list<SVMXC__ServiceMax_Config_Data__c>();
        
        SVMXC__ServiceMax_Processes__c objEligibilityRule_1 = new SVMXC__ServiceMax_Processes__c();
        objEligibilityRule_1.RecordTypeId = eligibilityProcessId;
        objEligibilityRule_1.SVMXC__Rule_Type__c = 'Tech Eligibility';
        objEligibilityRule_1.SVMXC__Name__c = 'Eligibility Rule Test1';
        objEligibilityRule_1.SVMXC__Description__c = 'Eligibility Rule Test1';
        objEligibilityRule_1.SVMXC__Select__c = true;
        objEligibilityRule_1.SVMXC__Rule_Type__c = 'Tech Eligibility';
        objEligibilityRule_1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objEligibilityRule_1.SVMXC__Sequence__c = 1.0000;
        lstRuleProcess.add(objEligibilityRule_1);
        
        SVMXC__ServiceMax_Processes__c objSkillMatchingRule_1 = new SVMXC__ServiceMax_Processes__c();
        objSkillMatchingRule_1.SVMXC__Name__c = 'Skill Rule Test1';
        objSkillMatchingRule_1.SVMXC__Description__c = 'Skill Rule Test1';
        objSkillMatchingRule_1.SVMXC__Select__c = true;               
        objSkillMatchingRule_1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objSkillMatchingRule_1.SVMXC__Sequence__c = 0.0000;
        objSkillMatchingRule_1.SVMXC__Rule_Type__c = 'Skill Matching';
        objSkillMatchingRule_1.RecordTypeId = skillProcessId;
        lstRuleProcess.add(objSkillMatchingRule_1);
        
        SVMXC__ServiceMax_Processes__c objEligibilityRule_2 = new SVMXC__ServiceMax_Processes__c();
        objEligibilityRule_2.RecordTypeId = eligibilityProcessId;
        objEligibilityRule_2.SVMXC__Rule_Type__c = 'Tech Eligibility';
        objEligibilityRule_2.SVMXC__Name__c = 'Eligibility Rule Test2';
        objEligibilityRule_2.SVMXC__Description__c = 'Eligibility Rule Test2';
        objEligibilityRule_2.SVMXC__Select__c = false;
        objEligibilityRule_2.SVMXC__Sequence__c = 2.0000;
        objEligibilityRule_2.SVMXC__Rule_Type__c = 'Tech Eligibility';
        objEligibilityRule_2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        lstRuleProcess.add(objEligibilityRule_2);
        
        insert lstRuleProcess;
        
        SVMXC__ServiceMax_Processes__c objSkillMatchingRule_2 = new SVMXC__ServiceMax_Processes__c();
        objSkillMatchingRule_2.SVMXC__Name__c = 'Skill Rule Test2';
        objSkillMatchingRule_2.SVMXC__Description__c = 'Skill Rule Test2';
        objSkillMatchingRule_2.SVMXC__Select__c = false;
        objSkillMatchingRule_2.SVMXC__Sequence__c = 1.0000;
        objSkillMatchingRule_2.SVMXC__Rule_Type__c = 'Skill Matching';
        objSkillMatchingRule_2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objSkillMatchingRule_2.RecordTypeId = skillProcessId;
        objSkillMatchingRule_2.SVMXC__Node_Parent__c = objSkillMatchingRule_1.Id;
        insert objSkillMatchingRule_2;
        
        SVMXC__ServiceMax_Config_Data__c objEligibilityCriteria = new  SVMXC__ServiceMax_Config_Data__c();
        objEligibilityCriteria.RecordTypeId = eligibilityExpressionId;
        objEligibilityCriteria.SVMXC__Expression_Type__c = 'Tech_Eligibility';
        objEligibilityCriteria.SVMXC__Expression_Rule__c = objEligibilityRule_1.id;
        objEligibilityCriteria.SVMXC__Field_Name__c = 'SVMXC__City__c';
        objEligibilityCriteria.SVMXC__Operator__c = 'eq';
        objEligibilityCriteria.SVMXC__Operand__c = 'Bangalore';
        lstRuleExpressionConf.add(objEligibilityCriteria);
        
        SVMXC__ServiceMax_Config_Data__c objSkillEligibility_1 = new  SVMXC__ServiceMax_Config_Data__c();
        objSkillEligibility_1.SVMXC__Expression_Type__c = 'Skill_Eligibility';
        objSkillEligibility_1.RecordTypeId = skillExpressionId;
        objSkillEligibility_1.SVMXC__Expression_Rule__c = objSkillMatchingRule_1.id;
        objSkillEligibility_1.SVMXC__Expression_Type__c = 'Skill_Eligibility';
        objSkillEligibility_1.SVMXC__Field_Name__c = 'SVMXC__City__c';
        objSkillEligibility_1.SVMXC__Operator__c = 'eq';
        objSkillEligibility_1.SVMXC__Operand__c = 'Bangalore';
        lstRuleExpressionConf.add(objSkillEligibility_1); 
        
        SVMXC__ServiceMax_Config_Data__c skilApplicable_1 = new  SVMXC__ServiceMax_Config_Data__c();
        skilApplicable_1.SVMXC__Skill__c = objSkillnstallation.id;
        skilApplicable_1.RecordTypeId = applicableSkillRectypeId;
        skilApplicable_1.SVMXC__Expression_Rule__c = objSkillMatchingRule_1.id;        
        lstRuleExpressionConf.add(skilApplicable_1);
        
        insert lstRuleExpressionConf;       
        
        SMAX_OptiMax_Engine_WS.QualifiedTechnician_WP objQTL = new SMAX_OptiMax_Engine_WS.QualifiedTechnician_WP(Territory3.Id,5);
        SMAX_OptiMax_Engine_WS.Expertise_WP objExpertise_WP = new SMAX_OptiMax_Engine_WS.Expertise_WP();
        //SMAX_OptiMax_Engine_WS.Expertise_WP objExpertise_WP1 = new SMAX_OptiMax_Engine_WS.Expertise_WP('aaaa','bbb');
        list<SMAX_OptiMax_Engine_WS.Expertise_WP> lstExpertise_WP = new list<SMAX_OptiMax_Engine_WS.Expertise_WP>();
        lstExpertise_WP.add(objExpertise_WP);
        //lstExpertise_WP.add(objExpertise_WP1);
        SMAX_OptiMax_Engine_WS.Product_WP objProduct_WP = new SMAX_OptiMax_Engine_WS.Product_WP();
        //SMAX_OptiMax_Engine_WS.Product_WP objProduct_WP1 = new SMAX_OptiMax_Engine_WS.Product_WP('aaaa','bbb');
        list<SMAX_OptiMax_Engine_WS.Product_WP> lstProduct_WP = new list<SMAX_OptiMax_Engine_WS.Product_WP>();
        lstProduct_WP.add(objProduct_WP);
        //lstProduct_WP.add(objProduct_WP1);
        SMAX_OptiMax_Engine_WS.ExecutionTime_WP objExecutionTime_WP1 = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP();
        SMAX_OptiMax_Engine_WS.ExecutionTime_WP objExecutionTime_WP = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(System.now().addminutes(-60),System.now());
        list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstExecutionTime_WP = new list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
        lstExecutionTime_WP.add(objExecutionTime_WP);
        lstExecutionTime_WP.add(objExecutionTime_WP1);
        SMAX_OptiMax_Engine_WS.Technician_WP objTechnician_WP = new SMAX_OptiMax_Engine_WS.Technician_WP(tech1,lstExecutionTime_WP,lstProduct_WP,lstExpertise_WP,null); 
        SMAX_OptiMax_Engine_WS.Technician_WP objTechnician_WP1 = new SMAX_OptiMax_Engine_WS.Technician_WP(tech1, lstExecutionTime_WP, lstProduct_WP,lstExpertise_WP);
        objTechnician_WP1.gettechProduct_WPL();
        objTechnician_WP1.gettechExpertise_WPL();
        SMAX_OptiMax_Engine_WS.ExecutionTime_WP objexeWP = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(System.now(),System.now());
        objexeWP.setstartDateTime(System.now());
        objexeWP.setendDateTime(System.now());
        set<date> setdate= new set<date>();
        setdate.add(System.today());
        setdate.add(System.today().adddays(1));
        objexeWP.doSplitDays(String.valueof(Userinfo.getTimeZone()),setdate);
        SMAX_OptiMax_Engine_WS.ExecutionTime_WP objexeWP1 = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(System.now(),System.now().adddays(2));
        objexeWP1.doSplitDays(String.valueof(Userinfo.getTimeZone()),setdate);
        SMAX_OptiMax_Engine_WS.WorkOrder_WP objWorkOrder_WP = new SMAX_OptiMax_Engine_WS.WorkOrder_WP(workOrderQTL);
        SMAX_OptiMax_Engine_WS.WorkOrder_WP objWorkOrder_WP1 = new SMAX_OptiMax_Engine_WS.WorkOrder_WP(workOrderQTL, lstExecutionTime_WP, 'abc',null);   
        SMAX_OptiMax_Engine_WS.KeyValue objKeyValue = new SMAX_OptiMax_Engine_WS.KeyValue('TERRITORYID',Territory3.Id); 
        Event SF_Event2 = new Event();
            SF_Event2.ActivityDate = System.today().addDays(1);
            SF_Event2.ActivityDateTime = System.now().addDays(1);
            SF_Event2.StartDateTime = SF_Event2.ActivityDateTime;
            SF_Event2.DurationInMinutes = 60;
            SF_Event2.EndDateTime = System.now().addHours(1).addDays(1);
            SF_Event2.OwnerId = UserInfo.getUserId();
            //insert SF_Event2;
        SMAX_OptiMax_Engine_WS.WorkOrderSchedule_WP objWorkOrderSchedule_WP = new SMAX_OptiMax_Engine_WS.WorkOrderSchedule_WP(String.valueof(SF_Event2.id), tech1.id, System.now(), System.now().addminutes(60), 60);   
        SMAX_OptiMax_Engine_WS.DblLocation_WP objDblLocation_WP2 = new SMAX_OptiMax_Engine_WS.DblLocation_WP();
        SMAX_OptiMax_Engine_WS.DblLocation_WP objDblLocation_WP = new SMAX_OptiMax_Engine_WS.DblLocation_WP(12.975174,77.607995);   
        SMAX_OptiMax_Engine_WS.DblLocation_WP objDblLocation_WP1 = new SMAX_OptiMax_Engine_WS.DblLocation_WP(String.valueof(12.975174),String.valueof(77.607995));
        SMAX_OptiMax_Engine_WS.ExcSetting_WP objExcSetting_WP = new SMAX_OptiMax_Engine_WS.ExcSetting_WP('aaaa','bbb');     
        System.Test.startTest();
        
        SMAX_OptiMax_Engine_WS.SMAX_Run_QTL_WS(keyValuePairs);
        precalcCompletedJob.SVMXC__OptiMax_Message__c = 'QTL Completed';
        update precalcCompletedJob;
        //SMAX_OptiMax_Engine_WS.SMAX_Run_QTL_WS(keyValuePairs);
        SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(Userinfo.getUserId(),Territory3.Id+'_INCR',dispatchprocessId);
    } 
    
    static testMethod void SMAX_OptiMax_Engine_WS_UnitTestSum16()
    {
        //Creating data 
        list<string> lstSettings = new list<string>();        
        lstSettings.add('GLOB001_GBL007');
        lstSettings.add('OMAX003_SET030');
        List<SVMXC__ServiceMax_Config_Data__c> lstSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstSettingValues = [SELECT SVMXC__Internal_Value__c, SVMXC__Setting_Unique_ID__c FROM SVMXC__ServiceMax_Config_Data__c WHERE recordType.Name = 'Setting Value'
                            AND SVMXC__Setting_Unique_ID__c IN :lstSettings
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' 
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Global'
                            ]; 
        if(('false'.equalsIgnoreCase(lstSettingValues[0].SVMXC__Internal_Value__c)) && ('false'.equalsIgnoreCase(lstSettingValues[1].SVMXC__Internal_Value__c))){
            lstSettingValues[0].SVMXC__Internal_Value__c='True';
            lstSettingValues[1].SVMXC__Internal_Value__c='True';
            upsert lstSettingValues;    
        }                         
        case c = new case();
        Account account = new Account(
                                                Name = 'Account',
                                                ShippingStreet= 'ABC',
                                                ShippingCity= 'PQR ',
                                                ShippingState = 'California',
                                                ShippingPostalCode= '111',
                                                ShippingCountry= 'United States',
                                                BillingStreet= 'ABC',
                                                BillingCity= 'PQR ',
                                                BillingState = 'California',
                                                BillingPostalCode= '111',
                                                BillingCountry= 'United States'
                                                );  
        insert account;
        System.assertEquals('Account', account.Name);
        
        List<BusinessHours> lBH = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];
        
        
        Contact contact = new Contact(LastName= 'Last',AccountId =account.Id,Email= 'test@max.com');
        insert contact;
        System.assertEquals('Last', contact.LastName);
        SVMXC__Territory__c Territory2 = new SVMXC__Territory__c(Name= 'Territory2',SVMXC__Active__c =true,SVMXC__Territory_Code__c = 'Territory2',SVMXC__Parent_Territory__c =NULL,SVMXC__Per_Mile_Cost__c=1.0,SVMXC__Max_Distance__c=5,SVMXC__Average_Speed__c=70.0);
        insert Territory2;
        
        territoryId = Territory2.Id;
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType];
        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        
        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c = 'SVMXC__Zip__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c = '11111111';
        oConf.SVMXC__Operator__c = 'eq';
        oConf.SVMXC__Expression_Rule__c = svmxprocess.Id;
        
        
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
            {
               svmxprocess.RecordTypeId = rt.ID;
            } 
             
            if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
            {
               oConf.RecordTypeId = rt.ID;
            } 
        }
        
        svmxprocess.SVMXC__Territory__c = Territory2.Id;
        svmxprocess.SVMXC__Description__c = 'abcd';
        svmxprocess.SVMXC__Dispatch_Method__c = 'Optimized Batch';
        svmxprocess.SVMXC__Assign_Work_Order_To__c = 'Technician';
        svmxprocess.SVMXC__Calendar_Start_Type__c = 'SAME DAY';
        svmxprocess.SVMXC__Calendar_End_Type__c = 'SAME DAY';
        svmxprocess.SVMXC__Expertise_Match_Enabled__c =true;
        svmxprocess.SVMXC__Product_Match_Enabled__c =true;
        svmxprocess.SVMXC__Preferred_Tech_Enabled__c =true;
        svmxprocess.SVMXC__Route_Type__c = 'CLOSED';
        svmxprocess.SVMXC__Distance_And_Time__c = 'Actual Distance And Time';
        svmxprocess.SVMXC__Weight_Time_Window__c =1.0000;
        svmxprocess.SVMXC__Weight_Route_Distance__c =1.0000;
        svmxprocess.SVMXC__Weight_Route_Time__c =1.0000;
        svmxprocess.SVMXC__Weight_Node_Type__c =1;
        svmxprocess.SVMXC__Dispatch_Process_Status__c = 'Complete';
        svmxprocess.SVMXC__Runs_Every_Monday__c =true;
        svmxprocess.SVMXC__Runs_Every_Tuesday__c =true;
        svmxprocess.SVMXC__Start_Time__c = '11:00 PM';
        svmxprocess.SVMXC__Frequency__c =1;
        svmxprocess.SVMXC__Full_Run_Unit__c = 'Days';
        svmxprocess.SVMXC__Start_Date__c = date.Today();
        svmxprocess.SVMXC__End_Date__c = date.Today().addDays(1);
        svmxprocess.SVMXC__Weight_Total_Distance__c =1.0000;
        svmxprocess.SVMXC__Calendar_Start_Days__c = 0;
        svmxprocess.SVMXC__Calendar_End_Days__c = 2;
        svmxprocess.SVMXC__Tolerance__c = 30;
        svmxprocess.SVMXC__ProcessID__c = 'PROCESS11';
        svmxprocess.SVMXC__SettingId__c = 'PROCESS11';
        svmxprocess.SVMXC__MapID__c = 'PROCESS11';
        svmxprocess.SVMXC__Name__c = 'PROCESS22';
        Insert svmxprocess;
        dispatchprocessId = svmxprocess.Id;
        
        list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue DPKeyVal = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue TEKeyVal = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue TEKeyVal1 = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        DPKeyVal.name = 'DISPATCHPROCESSID';
        DPKeyVal.value = dispatchprocessId;
        keyValuePairs.add(DPKeyVal);
        TEKeyVal.name = 'TERRITORYID';
        TEKeyVal.value = Territory2.Id + '_FULL';
        TEKeyVal1.name = 'TERRITORYID';
        TEKeyVal1.value = Territory2.Id + '_INCR';

        SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs);
        
        keyValuePairs.add(TEKeyVal);
        SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs);

        keyValuePairs.add(TEKeyVal1);
        SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs);
        
        SVMXC__SVMX_Jobs__c precalcCompletedJob = new SVMXC__SVMX_Jobs__c(SVMXC__SVMX_Process__c = dispatchprocessId, SVMXC__Territory__c = Territory2.Id, SVMXC__OptiMax_Message__c = 'Precalc Completed');
       // SVMXC__SVMX_Jobs__c precalcCompletedJob4 = new SVMXC__SVMX_Jobs__c(SVMXC__SVMX_Process__c = dispatchprocessId, SVMXC__Territory__c = Territory2.Id, SVMXC__OptiMax_Message__c = 'Precalc Failure');
        SVMXC__SVMX_Jobs__c precalcCompletedJob5 = new SVMXC__SVMX_Jobs__c(SVMXC__SVMX_Process__c = dispatchprocessId, SVMXC__Territory__c = Territory2.Id, SVMXC__OptiMax_Message__c = 'Running Precalc');
        List<SVMXC__SVMX_Jobs__c> lstPrecalcJobs = new List<SVMXC__SVMX_Jobs__c>();
        lstPrecalcJobs.add(precalcCompletedJob);
        //lstPrecalcJobs.add(precalcCompletedJob4);
        lstPrecalcJobs.add(precalcCompletedJob5);
        insert lstPrecalcJobs;
        
        list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs1 = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue DPKeyVal1 = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        DPKeyVal1.name = 'DISPATCHPROCESSID';
        DPKeyVal1.value = dispatchprocessId;
         keyValuePairs1.add(DPKeyVal1);
        SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs1);
        
        list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs2 = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue TEKeyVal2 = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        TEKeyVal2.name = 'TERRITORYID';
        TEKeyVal2.value = Territory2.Id + '_FULL';
        keyValuePairs1.add(TEKeyVal2);
        SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs2);
        
        list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue> keyValuePairs3 = new list<SVMXC.SMAX_OptiMax_Engine_WS.KeyValue>(); 
        SVMXC.SMAX_OptiMax_Engine_WS.KeyValue TEKeyVal3 = new SVMXC.SMAX_OptiMax_Engine_WS.KeyValue();
        TEKeyVal3.name = 'TERRITORYID';
        TEKeyVal3.value = Territory2.Id + '_INCR';
        keyValuePairs3.add(TEKeyVal3);
       SMAX_OptiMax_Engine_WS.SMAX_Run_Precalc_WS(keyValuePairs3);
        
        SVMXC__Service_Order__c workOrderQTL = new SVMXC__Service_Order__c();
        workOrderQTL.SVMXC__Case__c = c.Id;
        workOrderQTL.SVMXC__Company__c = account.Id;
        workOrderQTL.SVMXC__Contact__c =contact.Id;
        workOrderQTL.SVMXC__Latitude__c = 40.739582;
        workOrderQTL.SVMXC__Longitude__c = -73.980772;
        workOrderQTL.SVMXC__Street__c = 'Street1';
        workOrderQTL.SVMXC__City__c = 'BANGALORE';
        workOrderQTL.SVMXC__State__c = 'Karnataka';
        workOrderQTL.SVMXC__Country__c = 'India';
        workOrderQTL.SVMXC__Zip__c = '11111111';
        workOrderQTL.SVMXC__Order_Status__c = 'Open';
        workOrderQTL.SVMXC__Priority__c = 'Medium';
        workOrderQTL.SVMXC__Dispatch_Priority__c = 2;
        workOrderQTL.SVMXC__Order_Type__c = 'Field Service';
        workOrderQTL.SVMXC__Apply_Business_Hours_For_OptiMax__c = false;
        workOrderQTL.SVMXC__Preferred_Business_Hours__c = lBH[0].Id;
        workOrderQTL.SVMXC__Primary_Territory__c = Territory2.Id;
        workOrderQTL.SVMXC__OptiMax_status__c = 'OPT_COMPLETED';
        workOrderQTL.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrderQTL.SVMXC__Dispatch_Process__c = dispatchprocessId;
        workOrderQTL.SVMXC__Service_Duration__c = 6000;
        workOrderQTL.SVMXC__Locked_By_DC__c = true;
        workOrderQTL.SVMXC__SM_Lock_Appointment_Schedule__c = WSCH_ECO_Constants.SCHEDULE_LOCK_IN_PLACE;
        workOrderQTL.SVMXC__Scheduled_Date_Time__c  = system.now().addDays(3);
        insert workOrderQTL;
        
        //Create technicans
        SVMXC__Service_Group__c sgroup = new SVMXC__Service_Group__c();
        sgroup.SVMXC__Country__c = 'India';
        sgroup.SVMXC__City__c = 'Bangalore';
        Insert sgroup;
        System.assertEquals('India', sgroup.SVMXC__Country__c);
        
        SVMXC__Skill__c objSkillnstallation = new SVMXC__Skill__c();
        objSkillnstallation.Name = 'SkillInstall2';
        objSkillnstallation.SVMXC__Skill_Category__c = 'Installation';
        insert objSkillnstallation;
        
        List<SVMXC__Service_Group_Members__c> technicians= new List<SVMXC__Service_Group_Members__c>();
        SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c();
        tech1.SVMXC__Service_Territory__c =Territory2.Id;
        tech1.SVMXC__Fixed_Cost__c = 2.0;
        tech1.SVMXC__Latitude_Home__c = 37.407843;
        tech1.SVMXC__Longitude_Home__c = -122.008637;
        tech1.SVMXC__Street__c = 'Street 1';
        tech1.SVMXC__City__c = 'Bangalore';
        tech1.SVMXC__State__c = 'Karnataka';
        tech1.SVMXC__Zip__c = '11111111';
        tech1.SVMXC__Country__c = 'India';
        tech1.SVMXC__Per_hour_Cost__c = 2.0; 
        tech1.SVMXC__Per_Mile_Cost__c = 1.0;
        tech1.SVMXC__Average_Speed__c = 2.0;
        tech1.SVMXC__Max_Daily_Hours__c = 2.0;
        tech1.SVMXC__Max_Distance__c = 5.0;
        tech1.SVMXC__Enable_Scheduling__c = true;
        tech1.SVMXC__Service_Group__c =sgroup.Id; 
        if(lBH != NULL && lBH.size()>0)
            tech1.SVMXC__Working_Hours__c = lBH[0].id;
        tech1.SVMXC__Active__c  = true;
        technicians.add(tech1);

        SVMXC__Service_Group_Members__c tech = new SVMXC__Service_Group_Members__c();
        tech.SVMXC__Service_Territory__c = Territory2.Id;
        tech.SVMXC__Fixed_Cost__c = 2.0;
        tech.SVMXC__Latitude_Home__c = 37.407843;
        tech.SVMXC__Longitude_Home__c = -122.008637;
        tech.SVMXC__Street__c = 'Street 1';
        tech.SVMXC__City__c = 'Bangalore';
        tech.SVMXC__State__c = 'Karnataka';
        tech.SVMXC__Zip__c = '11111111';
        tech.SVMXC__Country__c = 'India';
        tech.SVMXC__Per_hour_Cost__c = 2.0; 
        tech.SVMXC__Per_Mile_Cost__c = 1.0;
        tech.SVMXC__Average_Speed__c = 2.0;
        tech.SVMXC__Max_Daily_Hours__c = 2.0;
        tech.SVMXC__Max_Distance__c = 5.0;
        tech.SVMXC__Salesforce_User__c = UserInfo.getUserId();
        tech.SVMXC__Enable_Scheduling__c = true;
        tech.SVMXC__Service_Group__c = sgroup.Id; 
        tech.SVMXC__Active__c  = true;
        if(lBH != NULL && lBH.size()>0)
            tech.SVMXC__Working_Hours__c = lBH[0].id;
        technicians.add(tech);
        Insert technicians;
        
        SVMXC__Service_Group_Skills__c skillForTech = new SVMXC__Service_Group_Skills__c(SVMXC__Service_Group__c = sgroup.Id, SVMXC__Skill__c = objSkillnstallation.Id);
        insert skillForTech;

        //Create Eligibility Matching Rules
        Id eligibilityProcessId;
        Id eligibilityExpressionId;
        Id skillProcessId;
        Id skillExpressionId;
        Id applicableSkillRectypeId;
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'SVMX Rule' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
            {
                eligibilityProcessId = rt.Id;
                skillProcessId = rt.Id;
            }
             
            if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
            {
                eligibilityExpressionId = rt.Id;
                skillExpressionId = rt.Id;
            }
            if(rt.Name == 'Applicable Skills' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
            {
                applicableSkillRectypeId = rt.Id;
            }
        }
        
        list<SVMXC__ServiceMax_Processes__c> lstRuleProcess = new list<SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Config_Data__c> lstRuleExpressionConf = new list<SVMXC__ServiceMax_Config_Data__c>();
        
        SVMXC__ServiceMax_Processes__c objEligibilityRule_1 = new SVMXC__ServiceMax_Processes__c();
        objEligibilityRule_1.RecordTypeId = eligibilityProcessId;
        objEligibilityRule_1.SVMXC__Rule_Type__c = 'Tech Eligibility';
        objEligibilityRule_1.SVMXC__Name__c = 'Eligibility Rule Test1';
        objEligibilityRule_1.SVMXC__Description__c = 'Eligibility Rule Test1';
        objEligibilityRule_1.SVMXC__Select__c = true;
        objEligibilityRule_1.SVMXC__Rule_Type__c = 'Tech Eligibility';
        objEligibilityRule_1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objEligibilityRule_1.SVMXC__Sequence__c = 1.0000;
        lstRuleProcess.add(objEligibilityRule_1);
        
        SVMXC__ServiceMax_Processes__c objSkillMatchingRule_1 = new SVMXC__ServiceMax_Processes__c();
        objSkillMatchingRule_1.SVMXC__Name__c = 'Skill Rule Test1';
        objSkillMatchingRule_1.SVMXC__Description__c = 'Skill Rule Test1';
        objSkillMatchingRule_1.SVMXC__Select__c = true;               
        objSkillMatchingRule_1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objSkillMatchingRule_1.SVMXC__Sequence__c = 0.0000;
        objSkillMatchingRule_1.SVMXC__Rule_Type__c = 'Skill Matching';
        objSkillMatchingRule_1.RecordTypeId = skillProcessId;
        lstRuleProcess.add(objSkillMatchingRule_1);
        
        SVMXC__ServiceMax_Processes__c objEligibilityRule_2 = new SVMXC__ServiceMax_Processes__c();
        objEligibilityRule_2.RecordTypeId = eligibilityProcessId;
        objEligibilityRule_2.SVMXC__Rule_Type__c = 'Tech Eligibility';
        objEligibilityRule_2.SVMXC__Name__c = 'Eligibility Rule Test2';
        objEligibilityRule_2.SVMXC__Description__c = 'Eligibility Rule Test2';
        objEligibilityRule_2.SVMXC__Select__c = false;
        objEligibilityRule_2.SVMXC__Sequence__c = 2.0000;
        objEligibilityRule_2.SVMXC__Rule_Type__c = 'Tech Eligibility';
        objEligibilityRule_2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        lstRuleProcess.add(objEligibilityRule_2);
        
        insert lstRuleProcess;
        
        SVMXC__ServiceMax_Processes__c objSkillMatchingRule_2 = new SVMXC__ServiceMax_Processes__c();
        objSkillMatchingRule_2.SVMXC__Name__c = 'Skill Rule Test2';
        objSkillMatchingRule_2.SVMXC__Description__c = 'Skill Rule Test2';
        objSkillMatchingRule_2.SVMXC__Select__c = false;
        objSkillMatchingRule_2.SVMXC__Sequence__c = 1.0000;
        objSkillMatchingRule_2.SVMXC__Rule_Type__c = 'Skill Matching';
        objSkillMatchingRule_2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objSkillMatchingRule_2.RecordTypeId = skillProcessId;
        objSkillMatchingRule_2.SVMXC__Node_Parent__c = objSkillMatchingRule_1.Id;
        insert objSkillMatchingRule_2;
        
        SVMXC__ServiceMax_Config_Data__c objEligibilityCriteria = new  SVMXC__ServiceMax_Config_Data__c();
        objEligibilityCriteria.RecordTypeId = eligibilityExpressionId;
        objEligibilityCriteria.SVMXC__Expression_Type__c = 'Tech_Eligibility';
        objEligibilityCriteria.SVMXC__Expression_Rule__c = objEligibilityRule_1.id;
        objEligibilityCriteria.SVMXC__Field_Name__c = 'SVMXC__City__c';
        objEligibilityCriteria.SVMXC__Operator__c = 'eq';
        objEligibilityCriteria.SVMXC__Operand__c = 'Bangalore';
        lstRuleExpressionConf.add(objEligibilityCriteria);
        
        SVMXC__ServiceMax_Config_Data__c objSkillEligibility_1 = new  SVMXC__ServiceMax_Config_Data__c();
        objSkillEligibility_1.SVMXC__Expression_Type__c = 'Skill_Eligibility';
        objSkillEligibility_1.RecordTypeId = skillExpressionId;
        objSkillEligibility_1.SVMXC__Expression_Rule__c = objSkillMatchingRule_1.id;
        objSkillEligibility_1.SVMXC__Expression_Type__c = 'Skill_Eligibility';
        objSkillEligibility_1.SVMXC__Field_Name__c = 'SVMXC__City__c';
        objSkillEligibility_1.SVMXC__Operator__c = 'eq';
        objSkillEligibility_1.SVMXC__Operand__c = 'Bangalore';
        lstRuleExpressionConf.add(objSkillEligibility_1); 
        
        SVMXC__ServiceMax_Config_Data__c skilApplicable_1 = new  SVMXC__ServiceMax_Config_Data__c();
        skilApplicable_1.SVMXC__Skill__c = objSkillnstallation.id;
        skilApplicable_1.RecordTypeId = applicableSkillRectypeId;
        skilApplicable_1.SVMXC__Expression_Rule__c = objSkillMatchingRule_1.id;        
        lstRuleExpressionConf.add(skilApplicable_1);
        
        insert lstRuleExpressionConf;       
        
        SMAX_OptiMax_Engine_WS.QualifiedTechnician_WP objQTL = new SMAX_OptiMax_Engine_WS.QualifiedTechnician_WP(Territory2.Id,5);
        SMAX_OptiMax_Engine_WS.Expertise_WP objExpertise_WP = new SMAX_OptiMax_Engine_WS.Expertise_WP();
        //SMAX_OptiMax_Engine_WS.Expertise_WP objExpertise_WP1 = new SMAX_OptiMax_Engine_WS.Expertise_WP('aaaa','bbb');
        list<SMAX_OptiMax_Engine_WS.Expertise_WP> lstExpertise_WP = new list<SMAX_OptiMax_Engine_WS.Expertise_WP>();
        lstExpertise_WP.add(objExpertise_WP);
        //lstExpertise_WP.add(objExpertise_WP1);
        SMAX_OptiMax_Engine_WS.Product_WP objProduct_WP = new SMAX_OptiMax_Engine_WS.Product_WP();
        //SMAX_OptiMax_Engine_WS.Product_WP objProduct_WP1 = new SMAX_OptiMax_Engine_WS.Product_WP('aaaa','bbb');
        list<SMAX_OptiMax_Engine_WS.Product_WP> lstProduct_WP = new list<SMAX_OptiMax_Engine_WS.Product_WP>();
        lstProduct_WP.add(objProduct_WP);
        //lstProduct_WP.add(objProduct_WP1);
        SMAX_OptiMax_Engine_WS.ExecutionTime_WP objExecutionTime_WP1 = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP();
        SMAX_OptiMax_Engine_WS.ExecutionTime_WP objExecutionTime_WP = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(System.now().addminutes(-60),System.now());
        list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstExecutionTime_WP = new list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
        lstExecutionTime_WP.add(objExecutionTime_WP);
        lstExecutionTime_WP.add(objExecutionTime_WP1);
        SMAX_OptiMax_Engine_WS.Technician_WP objTechnician_WP = new SMAX_OptiMax_Engine_WS.Technician_WP(tech1,lstExecutionTime_WP,lstProduct_WP,lstExpertise_WP,null); 
        SMAX_OptiMax_Engine_WS.Technician_WP objTechnician_WP1 = new SMAX_OptiMax_Engine_WS.Technician_WP(tech1, lstExecutionTime_WP, lstProduct_WP,lstExpertise_WP);
        objTechnician_WP1.gettechProduct_WPL();
        objTechnician_WP1.gettechExpertise_WPL();
        
        SMAX_OptiMax_Engine_WS.TechnicianAdditonalDetails_WP techAddDetail_wp = new SMAX_OptiMax_Engine_WS.TechnicianAdditonalDetails_WP();
        techAddDetail_wp.techOverTimeSecs = 1234;
        techAddDetail_wp.thresholdDistance = 1234;
        techAddDetail_wp.thresholdDuration = 1234;
        techAddDetail_wp.totalStaysOut = 1234;
        techAddDetail_wp.staysOutInRow = 1234;
        techAddDetail_wp.isPolicyOverRidesEfficiency = true; 
        techAddDetail_wp.minRecoverHours = 1234;
        SMAX_OptiMax_Engine_WS.Technician_WP objTechnician_WP2 = new SMAX_OptiMax_Engine_WS.Technician_WP(tech1,lstExecutionTime_WP,lstProduct_WP,lstExpertise_WP,'addOnId',techAddDetail_wp);
        
        
        SMAX_OptiMax_Engine_WS.TechniciansEventsAdditonalDetails_WP techEventAddDetails = new SMAX_OptiMax_Engine_WS.TechniciansEventsAdditonalDetails_WP();
        SMAX_OptiMax_Engine_WS.TechniciansEvents_WP techEvents_WP = new SMAX_OptiMax_Engine_WS.TechniciansEvents_WP('terrId', 'prefRes', 'eventId', System.now(),System.now().adddays(2), Double.valueOf('2333'), Double.valueOf(3.0), 3, techEventAddDetails);
        
        SMAX_OptiMax_Engine_WS.ExecutionTime_WP objexeWP = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(System.now(),System.now());
        objexeWP.setstartDateTime(System.now());
        objexeWP.setendDateTime(System.now());
        set<date> setdate= new set<date>();
        setdate.add(System.today());
        setdate.add(System.today().adddays(1));
        objexeWP.doSplitDays(String.valueof(Userinfo.getTimeZone()),setdate);
        SMAX_OptiMax_Engine_WS.ExecutionTime_WP objexeWP1 = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(System.now(),System.now().adddays(2));
        objexeWP1.doSplitDays(String.valueof(Userinfo.getTimeZone()),setdate);
        SMAX_OptiMax_Engine_WS.WorkOrder_WP objWorkOrder_WP = new SMAX_OptiMax_Engine_WS.WorkOrder_WP(workOrderQTL);
        
         workOrderQTL.SVMXC__Qualified_Technicians__c = '[{"valid":false,"tName":"MizaLatLong","tech":"a1DF0000008fpCZMAY","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"Miza1","tech":"a1DF0000008fusxMAA","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"Miza2","tech":"a1DF0000008fut2MAA","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"Miza3","tech":"a1DF0000008fut7MAA","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"Miza4","tech":"a1DF0000008fvCeMAI","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10},{"valid":false,"tName":"TestTech","tech":"a1DF0000008fz6yMAA","stackRank":2,"skillR":0,"skillO":0.0,"prod":0,"prefTech":0,"eligible":10}]';
         // workOrderQTL.SVMXC__OptiMax_Status__c = 'Completed';
         // //workOrderQTL.SVMXC__Product__c = new SVMXC__Product__c().id;
        SVMXC__Skill__c objSkillnstallation2 = new SVMXC__Skill__c();
        objSkillnstallation2.Name = 'SkillInstall2';
        objSkillnstallation2.SVMXC__Skill_Category__c = 'Installation';
        insert objSkillnstallation2;
        workOrderQTL.SVMXC__Skill__c = objSkillnstallation2.id;
        upsert workOrderQTL;
        SMAX_OptiMax_Engine_WS.WorkOrder_WP objWorkOrder_WP1 = new SMAX_OptiMax_Engine_WS.WorkOrder_WP(workOrderQTL, lstExecutionTime_WP, 'abc',null);   
        SMAX_OptiMax_Engine_WS.KeyValue objKeyValue = new SMAX_OptiMax_Engine_WS.KeyValue('TERRITORYID',Territory2.Id); 
        Event SF_Event2 = new Event();
            SF_Event2.ActivityDate = System.today().addDays(1);
            SF_Event2.ActivityDateTime = System.now().addDays(1);
            SF_Event2.StartDateTime = SF_Event2.ActivityDateTime;
            SF_Event2.DurationInMinutes = 60;
            SF_Event2.EndDateTime = System.now().addHours(1).addDays(1);
            SF_Event2.OwnerId = UserInfo.getUserId();
            //insert SF_Event2;
        SMAX_OptiMax_Engine_WS.WorkOrderSchedule_WP objWorkOrderSchedule_WP = new SMAX_OptiMax_Engine_WS.WorkOrderSchedule_WP(String.valueof(SF_Event2.id), tech1.id, System.now(), System.now().addminutes(60), 60);   
        SMAX_OptiMax_Engine_WS.DblLocation_WP objDblLocation_WP2 = new SMAX_OptiMax_Engine_WS.DblLocation_WP();
        SMAX_OptiMax_Engine_WS.DblLocation_WP objDblLocation_WP = new SMAX_OptiMax_Engine_WS.DblLocation_WP(12.975174,77.607995);   
        SMAX_OptiMax_Engine_WS.DblLocation_WP objDblLocation_WP1 = new SMAX_OptiMax_Engine_WS.DblLocation_WP(String.valueof(12.975174),String.valueof(77.607995));
        SMAX_OptiMax_Engine_WS.ExcSetting_WP objExcSetting_WP = new SMAX_OptiMax_Engine_WS.ExcSetting_WP('aaaa','bbb');     
        System.Test.startTest();
        
        SMAX_OptiMax_Engine_WS.SMAX_Run_QTL_WS(keyValuePairs);
        precalcCompletedJob.SVMXC__OptiMax_Message__c = 'QTL Completed';
        update precalcCompletedJob;
        //SMAX_OptiMax_Engine_WS.SMAX_Run_QTL_WS(keyValuePairs);
        SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(Userinfo.getUserId(),Territory2.Id,dispatchprocessId);
    
    }
    
    static testMethod void coverInnerClassWrapper() {
        
        SMAX_OptiMax_Engine_WS.BannedTechnician_WP bannedTech_wp = new SMAX_OptiMax_Engine_WS.BannedTechnician_WP('techId');
        
        SMAX_OptiMax_Engine_WS.MandatoryTechnician_WP mandatoryTech_wp = new SMAX_OptiMax_Engine_WS.MandatoryTechnician_WP('techId',1);
        
        SMAX_OptiMax_Engine_WS.TechnicianAdditonalDetails_WP techAddDetail_wp = new SMAX_OptiMax_Engine_WS.TechnicianAdditonalDetails_WP();
        techAddDetail_wp.techOverTimeSecs = 1234;
        techAddDetail_wp.thresholdDistance = 1234;
        techAddDetail_wp.thresholdDuration = 1234;
        techAddDetail_wp.totalStaysOut = 1234;
        techAddDetail_wp.staysOutInRow = 1234;
        techAddDetail_wp.isPolicyOverRidesEfficiency = true; 
        techAddDetail_wp.minRecoverHours = 1234;
        
        SMAX_OptiMax_Engine_WS.TechniciansEventsAdditonalDetails_WP techEventAddDetails = new SMAX_OptiMax_Engine_WS.TechniciansEventsAdditonalDetails_WP();
        techEventAddDetails.address = 'address';
        techEventAddDetails.latitude = Double.valueOf('123.44');
        techEventAddDetails.longitude = Double.valueOf('123.44');
        techEventAddDetails.eventtype = 'type';
        techEventAddDetails.isForcedStayNode = true;
        
        SMAX_OptiMax_Engine_WS.WorkOrderAdditionalDetails_WP workOrderAddDetails_wp = new SMAX_OptiMax_Engine_WS.WorkOrderAdditionalDetails_WP();
        workOrderAddDetails_wp.isAvailableForOvernightStay = true;
        workOrderAddDetails_wp.scheduleViolationPenalty = Double.valueOf('123.44');
        
        SMAX_OptiMax_Engine_WS.Relation_WP relation_wp = new SMAX_OptiMax_Engine_WS.Relation_WP();
        relation_wp.relationshipType = 'startToFinish';
        relation_wp.relatedNodeId = 'wo-1234';
        relation_wp.resourceDependencyType = 'time';
        relation_wp.minimalDeviationSec = Double.valueOf('20');
        relation_wp.maximalDeviationSec = Double.valueOf('20');
        relation_wp.sameResource = true;
        
        SMAX_OptiMax_Engine_WS.TotalRouteTime_WP totalRouteTime_wp = new SMAX_OptiMax_Engine_WS.TotalRouteTime_WP();
        totalRouteTime_wp.totalRouteTime = Double.valueOf('123.44');
        totalRouteTime_wp.totalDrivingTime = Double.valueOf('123.44');
        totalRouteTime_wp.totalDistance = Double.valueOf('123.44');
        totalRouteTime_wp.startTime = system.now();
        totalRouteTime_wp.endTime = system.now() + 1;
        totalRouteTime_wp.returnDrivingTime = Double.valueOf('123.44');
        totalRouteTime_wp.returnDistance = Double.valueOf('123.44');
        
        SMAX_OptiMax_Engine_WS.Statics_WP statics_wp = new SMAX_OptiMax_Engine_WS.Statics_WP();
        statics_wp.statName = 'statName';
        statics_wp.value = 'value';
        statics_wp.units = Double.valueOf('123');
        statics_wp.unit = 'unit';
        
        SMAX_OptiMax_Engine_WS.ExeLog_WP exeLog_wp = new SMAX_OptiMax_Engine_WS.ExeLog_WP();
        exeLog_wp.timeStamp = system.now();
        exeLog_wp.logLevel = Double.valueOf('12');
        exeLog_wp.operation = 'operation';
        exeLog_wp.message = 'message';
        
        SMAX_OptiMax_Engine_WS.TechnicianEventDetail_WP techEventDetail_wp = new SMAX_OptiMax_Engine_WS.TechnicianEventDetail_WP();
        techEventDetail_wp.technicianEventId = 'id';
        techEventDetail_wp.location = new SMAX_OptiMax_Engine_WS.Location_WP('lat','long');
        
        SMAX_OptiMax_Engine_WS.Status_WP status_wp = new SMAX_OptiMax_Engine_WS.Status_WP();
        status_wp.event = 'event';
        status_wp.message = 'message';
        status_wp.tag = 'tag';
    }
    
    public static void coverTechEventCreation(List<SVMXC__Service_Group_Members__c> technicians) {
        
        SMAX_OptiMax_Engine_Ext.capacityResult capacityResult = new SMAX_OptiMax_Engine_Ext.capacityResult();
        
        //Map of Technician with eventId and start and end datetime
        Map<Id, Map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> mapTechIdExecTimeEventId = new Map<Id, Map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>();
        
        //Map of Technician with ONS eventId and start and end datetime
        Map<Id, Map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> mapTechIdONSExecTimeEventId = new Map<Id, Map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>();
        
        //Map of Technician with BreakHour start and end datetime
        //Map<Id, Map<Date, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> mapTechIdBreakEventExecTime = new Map<Id, Map<Date, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>();
        
        Map<id, Map<date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>> mapTechAvailability = new Map<id, Map<date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>>();
        
        List<BusinessHours> lBH = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];
        
        List<SVMXC__SVMX_Event__c> Svmx_Event_L = new List<SVMXC__SVMX_Event__c>();
        SVMXC__SVMX_Event__c Svmx_Event = new SVMXC__SVMX_Event__c();
        Svmx_Event.SVMXC__StartDateTime__c = System.now();
        Svmx_Event.SVMXC__DurationInMinutes__c = 60;
        Svmx_Event.SVMXC__EndDateTime__c = System.now().addHours(1);
        Svmx_Event.SVMXC__Technician__c = technicians[0].Id;
        Svmx_Event.SVMXC__SM_Latitude__c = Double.valueOf('20.22');
        Svmx_Event.SVMXC__SM_Longitude__c = Double.valueOf('22.22');
        Svmx_Event_L.add(Svmx_Event);
        
        SVMXC__SVMX_Event__c Svmx_Event1 = new SVMXC__SVMX_Event__c();
        Svmx_Event1.SVMXC__StartDateTime__c = System.now().addDays(1);
        Svmx_Event1.SVMXC__DurationInMinutes__c = 60;
        Svmx_Event1.SVMXC__EndDateTime__c = System.now().addHours(1).addDays(1);
        Svmx_Event1.SVMXC__Technician__c = technicians[1].Id;
        Svmx_Event1.SVMXC__SM_Latitude__c = Double.valueOf('20.22');
        Svmx_Event1.SVMXC__SM_Longitude__c = Double.valueOf('22.22');
        Svmx_Event_L.add(Svmx_Event1);
        
        insert Svmx_Event_L;
        
        SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpEventTimeWindow = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(Svmx_Event.SVMXC__StartDateTime__c, Svmx_Event.SVMXC__EndDateTime__c);
        Map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP> mapOfEventIdExecTime = new Map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
        mapOfEventIdExecTime.put(Svmx_Event.Id, wrpEventTimeWindow);
        mapTechIdExecTimeEventId.put(technicians[2].Id, mapOfEventIdExecTime);
        
        mapTechIdONSExecTimeEventId.put(technicians[2].Id, mapOfEventIdExecTime);
        
        /*Map<Date, SMAX_OptiMax_Engine_WS.ExecutionTime_WP> mapOfDateExecTime = new Map<Date, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
        mapOfDateExecTime.put(system.now().date(), wrpEventTimeWindow);
        mapTechIdBreakEventExecTime.put(technicians[2].Id, mapOfDateExecTime);*/
        
        Map<String, SMAX_OptiMax_Engine_WS.TechniciansEventsAdditonalDetails_WP> mapTechAdditionalDetails = new Map<String, SMAX_OptiMax_Engine_WS.TechniciansEventsAdditonalDetails_WP>();
        SMAX_OptiMax_Engine_WS.TechniciansEventsAdditonalDetails_WP techAddtnlDetail1 = new SMAX_OptiMax_Engine_WS.TechniciansEventsAdditonalDetails_WP();
        techAddtnlDetail1.latitude = Svmx_Event.SVMXC__SM_Latitude__c;
        techAddtnlDetail1.longitude = Svmx_Event.SVMXC__SM_Longitude__c;
        techAddtnlDetail1.eventtype = 'CalendarGeoItem';
        techAddtnlDetail1.address = null;
        
        SMAX_OptiMax_Engine_WS.TechniciansEventsAdditonalDetails_WP techAddtnlDetail2 = new SMAX_OptiMax_Engine_WS.TechniciansEventsAdditonalDetails_WP();
        techAddtnlDetail2.latitude = Svmx_Event1.SVMXC__SM_Latitude__c;
        techAddtnlDetail2.longitude = Svmx_Event1.SVMXC__SM_Longitude__c;
        techAddtnlDetail2.eventtype = 'CalendarGeoItem';
        techAddtnlDetail2.address = null;
        techAddtnlDetail2.isForcedStayNode = true;
        
        String strTechStartDtTime1 = technicians[0].Id + '_' + system.now();
        mapTechAdditionalDetails.put(strTechStartDtTime1, techAddtnlDetail1);
        
        String strTechStartDtTime2 = technicians[1].Id + '_' + system.now();
        mapTechAdditionalDetails.put(strTechStartDtTime2, techAddtnlDetail2);
        
        String strTechStartDtTime3 = technicians[2].Id + '_' + system.now();
        mapTechAdditionalDetails.put(strTechStartDtTime3, techAddtnlDetail2);
        
        List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstOfExeTime_wp = new List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
        lstOfExeTime_wp.add(wrpEventTimeWindow);
        
        Map<Date, List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> mapOfDateExecTime2 = new Map<Date, List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>();
        mapOfDateExecTime2.put(system.now().date(), lstOfExeTime_wp);
        mapTechAvailability.put(technicians[0].Id, mapOfDateExecTime2);
        
        Map<Date, List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> mapOfDateExecTime3 = new Map<Date, List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>();
        mapOfDateExecTime3.put(system.now().date(), lstOfExeTime_wp);
        mapTechAvailability.put(technicians[1].Id, mapOfDateExecTime3);
        
        Map<Date, List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> mapOfDateExecTime4 = new Map<Date, List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>();
        mapOfDateExecTime4.put(system.now().date(), lstOfExeTime_wp);
        mapTechAvailability.put(technicians[2].Id, mapOfDateExecTime4);
        
        capacityResult.mapTechIdExecTimeEventId = mapTechIdExecTimeEventId;
        capacityResult.mapTechIdONSExecTimeEventId = mapTechIdONSExecTimeEventId;
        //capacityResult.mapTechIdBreakEventExecTime = mapTechIdBreakEventExecTime;
        capacityResult.mapTechAdditionalDetails = mapTechAdditionalDetails;
        capacityResult.mapTechAvailability = mapTechAvailability;
        
    }
    
    static testMethod void SMAX_OptiMax_Engine_WS_MoreInitJobCall(){

        case c = new case();
        Account account = new Account(
                                                Name = 'Account',
                                                ShippingStreet= 'ABC',
                                                ShippingCity= 'PQR ',
                                                ShippingState = 'California',
                                                ShippingPostalCode= '111',
                                                ShippingCountry= 'United States',
                                                BillingStreet= 'ABC',
                                                BillingCity= 'PQR ',
                                                BillingState = 'California',
                                                BillingPostalCode= '111',
                                                BillingCountry= 'United States'
                                                ); 
        insert account;
        System.assertEquals('Account', account.Name);
        
        List<BusinessHours> lBH = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];
        
        
        Contact contact = new Contact(LastName= 'Last',AccountId =account.Id,Email= 'test@max.com');
        insert contact;
        System.assertEquals('Last', contact.LastName);

        SVMXC__Territory__c Territory3 = new SVMXC__Territory__c(Name= 'Territory3',SVMXC__Active__c =true,SVMXC__Territory_Code__c = 'Territory3',SVMXC__Parent_Territory__c =NULL,SVMXC__Per_Mile_Cost__c=1.0,SVMXC__Max_Distance__c=5,SVMXC__Average_Speed__c=70.0);
        insert Territory3;

        SVMXC__Territory__c Territory4 = new SVMXC__Territory__c(Name= 'Territory4',SVMXC__Active__c =true,SVMXC__Territory_Code__c = 'Territory4',SVMXC__Parent_Territory__c =NULL,SVMXC__Per_Mile_Cost__c=null,SVMXC__Max_Distance__c=null,SVMXC__Average_Speed__c=null);
        insert Territory4;
                
        territoryId = Territory3.Id;
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType];
        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        
        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c = 'SVMXC__Zip__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c = '11111111';
        oConf.SVMXC__Operator__c = 'eq';
        oConf.SVMXC__Expression_Rule__c = svmxprocess.Id;
        
        
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
            {
               svmxprocess.RecordTypeId = rt.ID;
            } 
             
            if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
            {
               oConf.RecordTypeId = rt.ID;
            } 
        }
        
        svmxprocess.SVMXC__Territory__c = Territory3.Id;
        svmxprocess.SVMXC__Description__c = 'abcd';
        svmxprocess.SVMXC__Dispatch_Method__c = 'Optimized Batch';
        svmxprocess.SVMXC__Assign_Work_Order_To__c = 'Technician';
        svmxprocess.SVMXC__Calendar_Start_Type__c = 'SAME DAY';
        svmxprocess.SVMXC__Calendar_End_Type__c = 'SAME DAY';
        svmxprocess.SVMXC__Expertise_Match_Enabled__c =true;
        svmxprocess.SVMXC__Product_Match_Enabled__c =true;
        svmxprocess.SVMXC__Preferred_Tech_Enabled__c =true;
        svmxprocess.SVMXC__Route_Type__c = 'CLOSED';
        svmxprocess.SVMXC__Distance_And_Time__c = 'Actual Distance And Time';
        svmxprocess.SVMXC__Weight_Time_Window__c =1.0000;
        svmxprocess.SVMXC__Weight_Route_Distance__c =1.0000;
        svmxprocess.SVMXC__Weight_Route_Time__c =1.0000;
        svmxprocess.SVMXC__Weight_Node_Type__c =1;
        svmxprocess.SVMXC__Dispatch_Process_Status__c = 'Complete';
        svmxprocess.SVMXC__Runs_Every_Monday__c =true;
        svmxprocess.SVMXC__Runs_Every_Tuesday__c =true;
        svmxprocess.SVMXC__Start_Time__c = '11:00 PM';
        svmxprocess.SVMXC__Frequency__c =1;
        svmxprocess.SVMXC__Full_Run_Unit__c = 'Days';
        svmxprocess.SVMXC__Start_Date__c = date.Today();
        svmxprocess.SVMXC__End_Date__c = date.Today().addDays(1);
        svmxprocess.SVMXC__Weight_Total_Distance__c =1.0000;
        svmxprocess.SVMXC__Calendar_Start_Days__c = 0;
        svmxprocess.SVMXC__Calendar_End_Days__c = 2;
        svmxprocess.SVMXC__Tolerance__c = 30;
        svmxprocess.SVMXC__ProcessID__c = 'PROCESS11';
        svmxprocess.SVMXC__SettingId__c = 'PROCESS11';
        svmxprocess.SVMXC__MapID__c = 'PROCESS11';
        svmxprocess.SVMXC__Name__c = 'PROCESS22';
        Insert svmxprocess;
        //dispatchprocessId = svmxprocess.Id;

        SVMXC__SVMX_Jobs__c precalcCompletedJob = new SVMXC__SVMX_Jobs__c(SVMXC__SVMX_Process__c = svmxprocess.Id, SVMXC__Territory__c = Territory3.Id, SVMXC__OptiMax_Message__c = 'Precalc Completed');
        List<SVMXC__SVMX_Jobs__c> lstPrecalcJobs = new List<SVMXC__SVMX_Jobs__c>();
        lstPrecalcJobs.add(precalcCompletedJob);
        insert lstPrecalcJobs;

        precalcCompletedJob.SVMXC__OptiMax_Message__c = 'QTL Failure';
        update precalcCompletedJob;
        SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(Userinfo.getUserId(),Territory3.Id,svmxprocess.Id);

        precalcCompletedJob.SVMXC__OptiMax_Message__c = 'Running QTL';
        update precalcCompletedJob;
        SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(Userinfo.getUserId(),Territory3.Id,svmxprocess.Id);
            
        precalcCompletedJob.SVMXC__OptiMax_Message__c = 'Work Orders Being Sent';
        update precalcCompletedJob;
        SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(Userinfo.getUserId(),Territory3.Id,svmxprocess.Id);

        precalcCompletedJob.SVMXC__OptiMax_Message__c = 'Resources Sent';
        update precalcCompletedJob;
        SMAX_OptiMax_Engine_WS.SMAX_Initiate_OptiMax_Job_WS(Userinfo.getUserId(),Territory3.Id,svmxprocess.Id);
        
    }


    //UT execution for Complete Job Failure 
    static testMethod void SMAX_OptiMax_Engine_WS_Handle_CompleteJobFAILURES(){

      SVMXC__Territory__c T1 = new SVMXC__Territory__c(Name= 'T1',SVMXC__Active__c =true,SVMXC__Territory_Code__c = 'T1',SVMXC__Parent_Territory__c =NULL,SVMXC__Per_Mile_Cost__c=2.0,SVMXC__Max_Distance__c=100,SVMXC__Average_Speed__c=50.0);
            insert T1;
            territoryId = T1.Id;
            RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];
            SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
            
            SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
            oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
            oConf.SVMXC__Field_Name__c = 'SVMXC__Zip__c';
            oConf.SVMXC__Display_Type__c = 'STRING';
            oConf.SVMXC__Operand__c = '11111111';
            oConf.SVMXC__Operator__c = 'eq';
            oConf.SVMXC__Expression_Rule__c =svmxprocess.Id;
            
            
            for(RecordType rt : rts) //Loop to take a record type at a time
            {
                if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                {
                   svmxprocess.RecordTypeId = rt.ID;
                } 
                 
                if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                {
                   oConf.RecordTypeId = rt.ID;
                } 
            }
            
            svmxprocess.SVMXC__Territory__c = T1.Id;
            svmxprocess.SVMXC__Description__c = 'abcd';
            svmxprocess.SVMXC__Dispatch_Method__c = 'Optimized Batch';
            svmxprocess.SVMXC__Assign_Work_Order_To__c = 'Technician';
            svmxprocess.SVMXC__Calendar_Start_Type__c = 'SAME DAY';
            svmxprocess.SVMXC__Calendar_End_Type__c = 'SAME DAY';
            svmxprocess.SVMXC__Expertise_Match_Enabled__c =true;
            svmxprocess.SVMXC__Product_Match_Enabled__c =true;
            svmxprocess.SVMXC__Preferred_Tech_Enabled__c =true;
            svmxprocess.SVMXC__Route_Type__c = 'CLOSED';
            svmxprocess.SVMXC__Distance_And_Time__c = 'Actual Distance And Time';
            svmxprocess.SVMXC__Weight_Time_Window__c =1.0000;
            svmxprocess.SVMXC__Weight_Route_Distance__c =1.0000;
            svmxprocess.SVMXC__Weight_Route_Time__c =1.0000;
            svmxprocess.SVMXC__Weight_Node_Type__c =1;
            svmxprocess.SVMXC__Dispatch_Process_Status__c = 'Complete';
            svmxprocess.SVMXC__Runs_Every_Monday__c =true;
            svmxprocess.SVMXC__Runs_Every_Tuesday__c =true;
            svmxprocess.SVMXC__Start_Time__c = '11:00 PM';
            svmxprocess.SVMXC__Frequency__c =1;
            svmxprocess.SVMXC__Full_Run_Unit__c = 'Days';
            svmxprocess.SVMXC__Start_Date__c = date.Today();
            svmxprocess.SVMXC__End_Date__c = date.Today().addDays(1);
            svmxprocess.SVMXC__Weight_Total_Distance__c =1.0000;
            svmxprocess.SVMXC__Calendar_Start_Days__c = 0;
            svmxprocess.SVMXC__Calendar_End_Days__c = 2;
            svmxprocess.SVMXC__Tolerance__c = 30;
            svmxprocess.SVMXC__ProcessID__c = 'PROCESS11';
            svmxprocess.SVMXC__SettingId__c = 'PROCESS11';
            svmxprocess.SVMXC__MapID__c = 'PROCESS11';
            svmxprocess.SVMXC__Name__c = 'PROCESS22';
            Insert svmxprocess;

 SVMXC__SVMX_Jobs__c job1 = new SVMXC__SVMX_Jobs__c();
            job1.SVMXC__SVMX_Process__c = svmxprocess.Id;
            job1.SVMXC__Territory__c = T1.Id;
            job1.SVMXC__OptiMax_Message__c = 'In Progress';
            job1.SVMXC__Start_Time__c = system.now().addDays(-1);
 insert job1;


       //Scenario 1 - All WO Invalid - All Tech Invalid
       SMAX_OptiMax_Engine_WS.ipCompleteJobs_WP compltjobs_WP = new SMAX_OptiMax_Engine_WS.ipCompleteJobs_WP();
       compltjobs_WP.dispatchProcessId='a122I00000EHZlaQAH';
       compltjobs_WP.jobId=job1.id;
       compltjobs_WP.scheduleWOCount=-1.0;
       
       list<SMAX_OptiMax_Engine_WS.Status_WP> wrapperList= new list<SMAX_OptiMax_Engine_WS.Status_WP>();
       SMAX_OptiMax_Engine_WS.Status_WP woStatusWrapper1=createErrorWrapper('WO-01550556','Failed to resolve address using SLR-GeoCoding Service');
       wrapperList.add(woStatusWrapper1);
       //SMAX_OptiMax_Engine_WS.Status_WP woStatusWrapper2=createErrorWrapper('WO-01550556','Unassigned');
       //wrapperList.add(woStatusWrapper2);
       compltjobs_WP.workOrderError_WPL = wrapperList;
       compltjobs_WP.technicianError_WPL = wrapperList;
       compltjobs_WP.technicianEventError_WPL = wrapperList;
       
       List<SMAX_OptiMax_Engine_WS.ExeLog_WP> exeLoglist = new List<SMAX_OptiMax_Engine_WS.ExeLog_WP>();
       SMAX_OptiMax_Engine_WS.ExeLog_WP exclog=createExecutionlogWrapper(-2.0,'No work orders with valid address/data are available for optimized dispatch','Processing Error');
       exeLoglist.add(exclog);
       compltjobs_WP.exeLog_WPL=exeLoglist;

       SMAX_OptiMax_Engine_WS.SMAX_Complete_OptiMax_Job_WS(compltjobs_WP);


       List<SMAX_OptiMax_Engine_WS.ExeLog_WP> exeLoglist1 = new List<SMAX_OptiMax_Engine_WS.ExeLog_WP>();
       SMAX_OptiMax_Engine_WS.ExeLog_WP exclog1=createExecutionlogWrapper(-1.0,'No work orders with valid address/data are available for optimized dispatch','Processing Error');
       exeLoglist1.add(exclog1);
       compltjobs_WP.exeLog_WPL=exeLoglist1;
       SMAX_OptiMax_Engine_WS.SMAX_Complete_OptiMax_Job_WS(compltjobs_WP);

       List<SMAX_OptiMax_Engine_WS.ExeLog_WP> exeLoglist2 = new List<SMAX_OptiMax_Engine_WS.ExeLog_WP>();
       SMAX_OptiMax_Engine_WS.ExeLog_WP exclog2=createExecutionlogWrapper(-3.0,'No work orders with valid address/data are available for optimized dispatch','Processing Error');
       exeLoglist2.add(exclog2);
       compltjobs_WP.exeLog_WPL=exeLoglist2;
       SMAX_OptiMax_Engine_WS.SMAX_Complete_OptiMax_Job_WS(compltjobs_WP);

       //Cover PArtial Error Flow

       SMAX_OptiMax_Engine_WS.ipCompleteJobs_WP compltjobs_WP1 = new SMAX_OptiMax_Engine_WS.ipCompleteJobs_WP();
       SMAX_OptiMax_Engine_Ext engineExt = new SMAX_OptiMax_Engine_Ext();
       compltjobs_WP1.dispatchProcessId='a122I00000EHZlaQAH';
       compltjobs_WP1.jobId=job1.id;
       compltjobs_WP1.workOrderError_WPL = wrapperList;
       compltjobs_WP1.technicianError_WPL = wrapperList;
       compltjobs_WP1.technicianEventError_WPL = wrapperList;
       //SMAX_OptiMax_Engine_WS.SMAX_Complete_OptiMax_Job_WS(compltjobs_WP1);
       engineExt.handleCJFailurePartial(compltjobs_WP1);
    }



    private static SMAX_OptiMax_Engine_WS.Status_WP createErrorWrapper(String event,String message){
        SMAX_OptiMax_Engine_WS.Status_WP errWrapper = new SMAX_OptiMax_Engine_WS.Status_WP();
        errWrapper.event=event;
        errWrapper.message=message;
        return errWrapper;
    }

  

    private static SMAX_OptiMax_Engine_WS.ExeLog_WP createExecutionlogWrapper(Decimal loglevel,String message,String operation){
        SMAX_OptiMax_Engine_WS.ExeLog_WP exeLog_wp = new SMAX_OptiMax_Engine_WS.ExeLog_WP();
        exeLog_wp.logLevel=loglevel;
        exeLog_wp.message=message;
        exeLog_wp.operation=operation;
        return exeLog_wp;
    }
}