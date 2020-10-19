@isTest
private class WSCH_Provider_ECO_Appointment_UT{
    
      Static Map<String,Id> recordTypeIdMap = new Map<String,Id>();
      Static List<String> detailLineIds = new List<String>();
      
       Static testMethod void getUserInfoTestMethod(){
            Test.StartTest();
            WSCH_Provider_ECO_Appointment ecoAppntmnt = new WSCH_Provider_ECO_Appointment();
            ecoAppntmnt.getUserInfo();
            Test.StopTest();
      } 
      
      Static testMethod void getWOAppointmentSettingsTestMethod(){
                       
            Id woId = CreateWorkOrder(); 
            Test.StartTest();
            WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request request = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request();
            //request.headerId = woId;
            
            List<BusinessHours> lBH = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 2];
                        
            SVMXC__Territory__c objTerritory = new SVMXC__Territory__c();
            objTerritory.name = 'India';                    
            objTerritory.SVMXC__Territory_s_Business_Hours__c = lBH[0].id;
            insert objTerritory;
        
            
            SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
            //svmxprocess.SVMXC__Territory__c = objTerritory.Id;
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
            svmxprocess.SVMXC__Weight_Total_Distance__c =1.0000;
            svmxprocess.SVMXC__Calendar_Start_Days__c = 0;
            svmxprocess.SVMXC__Calendar_End_Days__c = 2;
            svmxprocess.SVMXC__Tolerance__c = 60;
            svmxprocess.SVMXC__ProcessID__c = 'PROCESS11';
            svmxprocess.SVMXC__SettingId__c = 'PROCESS11';
            svmxprocess.SVMXC__MapID__c = 'PROCESS11';
            svmxprocess.SVMXC__Name__c = 'PROCESS22';
            Insert svmxprocess;
            
            SVMXC__ServiceMax_Processes__c svmxprocess2 = new SVMXC__ServiceMax_Processes__c();
            svmxprocess2.SVMXC__Territory__c = objTerritory.Id;
            svmxprocess2.SVMXC__Process__c = svmxprocess.id;
            svmxprocess2.SVMXC__MapID__c = 'PROCESS11';
            Insert svmxprocess2;            
                                    
            List<SVMXC__SVMX_Jobs__c> lstJobs = new list<SVMXC__SVMX_Jobs__c>();
                        
            SVMXC__SVMX_Jobs__c job1 = new SVMXC__SVMX_Jobs__c();
            job1.SVMXC__SVMX_Process__c = svmxprocess.Id;
            job1.SVMXC__Territory__c = objTerritory.Id;
            job1.SVMXC__OptiMax_Message__c ='RUNNING';
            job1.SVMXC__Type__c = 'ECO';
            job1.SVMXC__Start_Time__c = system.now();
            lstJobs.add(job1);
                                    
            insert lstJobs;
            
            SVMXC__SM_Appointment_Window__c appointmentType = new SVMXC__SM_Appointment_Window__c();
            appointmentType.Name = 'GoldType';
            appointmentType.SVMXC__SM_Appointment_Type_Name__c = 'GoldType';
            appointmentType.RecordTypeId = Schema.SObjectType.SVMXC__SM_Appointment_Window__c.getRecordTypeInfosByName().get('Appointment Type').getRecordTypeId();
            insert appointmentType;
        
            SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
            workOrder1.SVMXC__Service_Duration__c = 3600;
            workOrder1.SVMXC__Zip__c = '560022';
            workOrder1.SVMXC__Primary_Territory__c = objTerritory.Id;
            workOrder1.SVMXC__SM_Appointment_Type__c = appointmentType.Id;
            
            insert workOrder1;
            
            WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Settings defaultSettingValues = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Settings();
            defaultSettingValues.numberOfOfferAppts = '40';
            defaultSettingValues.numberOfDays = '7';
            defaultSettingValues.considerCostOrDates= 'Dates'; 
            DateTime curDate = system.today();
            defaultSettingValues.startDate= String.valueOf(curDate);
            defaultSettingValues.endDate= String.valueOf(curDate);
            
            request.appointmentSettings = defaultSettingValues;            
            request.headerId = workOrder1.id;
                            
            //createOptimizationSettings();
            createOptimizationSettings_1();                                     
            WSCH_Provider_ECO_Appointment.getWOAppointmentSettings(JSON.serialize(request));   
            Test.StopTest();
        
      }
    
      Static testMethod void getWorkOrderDetailsTestMethod(){
           Id woId = CreateWorkOrder(); 
           Test.StartTest();
           WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request request = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request();
           request.headerId = woId;
           WSCH_Provider_ECO_Appointment.getWorkOrderDetails(JSON.serialize(request));   
           Test.StopTest();
     } 
     
     Static testMethod void bookAppointmentTestMethod(){
           Id woId = CreateWorkOrder(); 
           Test.StartTest();
           WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request request = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request();
           request.headerId = woId;
           WSCH_Provider_ECO_Appointment.bookAppointment(JSON.serialize(request));   
           Test.StopTest();
     }
     
     Static testMethod void getOfferAppointmentsTestMethod(){
        
           WSCH_Provider_ECO_Appointment_Impl ecoAppImpl = new WSCH_Provider_ECO_Appointment_Impl(); 
           /*Map<String,Map<String,String>> settingsMap = new Map<String,Map<String,String>>();
           Map<String,String> glbMap = new Map<String,String>();
           glbMap.put('GBL007','True');
           glbMap.put('GBL022','Optimax,OptimaxEco');
           Map<String,String> omaxMap = new Map<String,String>();
           omaxMap.put('SET051','TRUE');
           WSCH_Constants.allDMSettings.put('GLOB001',glbMap);
           WSCH_Constants.allDMSettings.put('OMAX003',omaxMap);*/
           createOptimizationSettings_1();
           Id woId = CreateWorkOrder(); 
           
           
           Test.StartTest();
           
           WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Settings defaultSettingValues = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Settings();
           defaultSettingValues.numberOfOfferAppts = '40';
           defaultSettingValues.numberOfDays = '7';
           defaultSettingValues.considerCostOrDates= 'Dates'; 
           DateTime curDate = system.today();
           defaultSettingValues.startDate= String.valueOf(curDate);
           defaultSettingValues.endDate= String.valueOf(curDate);
           defaultSettingValues.startDateTime= String.valueOf(curDate);
           defaultSettingValues.endDateTime= String.valueOf(curDate);
           defaultSettingValues.territoryTimezone = 'IST';
            
           WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request request = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request();
           request.appointmentSettings = defaultSettingValues;
           request.headerId = woId;
           WSCH_Provider_ECO_Appointment.getOfferAppointments(JSON.serialize(request));   
           Test.StopTest();
     }
     
      static Id CreateWorkOrder(){
            
            List<BusinessHours> lBH = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];
            SVMXC__Territory__c Territory1 = new SVMXC__Territory__c();
            Territory1.name = 'India';
            Territory1.SVMXC__Territory_s_Business_Hours__c = lBH[0].id;
            insert Territory1;
            
            SVMXC__Service_Order__c woRecord = new SVMXC__Service_Order__c(SVMXC__Order_Status__c = 'Open');  
            woRecord.SVMXC__Company__c = InsertAccount();
            woRecord.SVMXC__Contact__c = InsertContact();
            woRecord.SVMXC__Primary_Territory__c = Territory1.Id;
                   
            woRecord.SVMXC__Component__c = InsertComponent();
            Id sconId = InsertScontract(woRecord.SVMXC__Company__c);
            Id covLocId = InsertCoveredLocation( woRecord.SVMXC__Site__c,sconId);
            Id covContact = InsertCoveredContact (woRecord.SVMXC__Contact__c, sconId);
            Id covProduct = InsertCoveredProduct(woRecord.SVMXC__Component__c,sconId);
            //Id warrantyId = InsertWarranties(woRecord.SVMXC__Component__c);
            insert woRecord;
            /*Map<Id, SVMXC__Service_Order_Line__c> servicedLineMap = CreateChildLines(woRecord.Id,2);
            for(Id lineID : servicedLineMap.keySet()){
                detailLineIds.add(lineID);
                covProduct = InsertCoveredProduct(servicedLineMap.get(lineID).SVMXC__Serial_Number__c,sconId);
            }*/
            return woRecord.Id;
     }
    
     Static Id InsertAccount(){
            Account acc = new Account(Name='Test Account');
            insert acc;
            return acc.id;
     }
    
     Static Id InsertContact(){
            Contact con = new Contact(LastName = 'Test Contact');
            insert con;
            return con.Id;
     }
     
     Static Id InsertComponent(){
            SVMXC__Installed_Product__c installedProduct = new SVMXC__Installed_Product__c();
            installedProduct.SVMXC__Product__c = InsertProduct('BaseProduct');
            List<SVMXC__Installed_Product__c> topComponentsList = InsertTopComponents();
            installedProduct.SVMXC__Parent__c = topComponentsList[0].Id;
            installedProduct.SVMXC__Top_Level__c = topComponentsList[1].Id;
            insert installedProduct;
            InsertChildIBs(installedProduct.Id);
            return installedProduct.Id;
    }
    
    Static Id InsertProduct(String productName){
            Product2 productRec = new Product2(SVMXC__Product_Line__c = 'Testing',Name = productName, Family = 'TestFamily');
            insert productRec;
            return productRec.Id;
    }
    
    Static Id InsertWarranties(Id componentId){
            SVMXC__Warranty__c warrantyRec = new SVMXC__Warranty__c();
            warrantyRec.SVMXC__Start_Date__c = System.today() - 10;
            warrantyRec.SVMXC__End_Date__c = System.today() + 10;
            warrantyRec.SVMXC__Installed_Product__c = componentId;
            //insert warrantyRec;
            return warrantyRec.Id;
    }
    
    Static List<SVMXC__Installed_Product__c> InsertTopComponents(){
            List<SVMXC__Installed_Product__c> lstInstalledProduct = new List<SVMXC__Installed_Product__c>(); 
            SVMXC__Installed_Product__c installedProduct1 = new SVMXC__Installed_Product__c();
            installedProduct1.SVMXC__Product__c = InsertProduct('Top');
            lstInstalledProduct.add(installedProduct1);
            
            SVMXC__Installed_Product__c installedProduct2 = new SVMXC__Installed_Product__c();
            installedProduct2.SVMXC__Product__c = InsertProduct('Parent');
            lstInstalledProduct.add(installedProduct2);
    
            insert lstInstalledProduct;
            return lstInstalledProduct;
    }
    
    Static void InsertChildIBs(Id parentIbId){
            SVMXC__Installed_Product__c installedProduct = new SVMXC__Installed_Product__c();
            installedProduct.SVMXC__Product__c = InsertProduct('ChildProduct');
            installedProduct.SVMXC__Parent__c = parentIbId;
            insert installedProduct;
    }
    
    Static Id InsertScontract(Id accountID){
            SVMXC__Service_Contract__c scons = new SVMXC__Service_Contract__c();
            scons.SVMXC__Company__c = accountID;
            scons.SVMXC__Active__c = true;
            scons.SVMXC__Start_Date__c = System.today() -10;
            scons.SVMXC__End_Date__c = System.today() + 10;
            insert scons;
            InsertCoveredServices(scons.Id);
            return scons.Id;
    }
    
    Static void InsertCoveredServices(Id sconID){
            SVMXC__Service__c serviceType = new SVMXC__Service__c();
            serviceType.SVMXC__Active__c = true;
            serviceType.SVMXC__Effective_Date__c = System.today()-20;
            serviceType.SVMXC__Service_Type__c = 'Repair';
            serviceType.SVMXC__Tracked_On__c = 'Work Order';
            insert serviceType; 
            List<SVMXC__Service_Contract_Services__c> covServicesList = new List<SVMXC__Service_Contract_Services__c>();
            for(integer i=0; i<2; i++){
                SVMXC__Service_Contract_Services__c covServices = new SVMXC__Service_Contract_Services__c();
                covServices.SVMXC__Service_Contract__c = sconID;
                covServices.SVMXC__Included_Units__c = 2;
                covServices.SVMXC__Consumed_Units__c = 1;
                covServices.SVMXC__Service__c = serviceType.Id;
                covServicesList.add(covServices);
            }  
            insert covServicesList;
    }
    
    Static Id InsertCoveredContact(Id contactId, Id conID){
            SVMXC__Service_Contract_Contacts__c covContact = new SVMXC__Service_Contract_Contacts__c();
            covContact.SVMXC__Service_Contract__c = conID;
            covContact.SVMXC__Contact__c = contactId;
            insert covContact;
            return covContact.Id;
    }
    
    Static Id InsertCoveredLocation(Id loc, Id conID){
            SVMXC__Service_Contract_Sites__c covLoc = new SVMXC__Service_Contract_Sites__c();
            covLoc.SVMXC__Service_Contract__c = conID;
            covLoc.SVMXC__Site__c = loc;
            covLoc.SVMXC__Start_Date__c = System.today() + 9;
            covLoc.SVMXC__End_Date__c = System.today() + 20;
            insert covLoc;
            return covLoc.Id;
    }
    
    Static Id InsertCoveredProduct(Id componentId, Id sConId){
            SVMXC__Service_Contract_Products__c covProd = new SVMXC__Service_Contract_Products__c();
            covProd.SVMXC__Installed_Product__c = componentId;
            covProd.SVMXC__Service_Contract__c = sConId;
            covProd.SVMXC__Start_Date__c = system.today() + 9;
            covProd.SVMXC__End_Date__c = system.today() + 20;
            insert covProd;
            return covProd.Id;
    }
    
     static Map<Id, SVMXC__Service_Order_Line__c> CreateChildLines(Id woId, Integer recordsCount){
            List<SVMXC__Service_Order_Line__c> productServicedLinesList = new List<SVMXC__Service_Order_Line__c>();
            for(integer i=0; i < recordsCount ; i++){
                SVMXC__Service_Order_Line__c woLine = new SVMXC__Service_Order_Line__c();
                woLine.SVMXC__Service_Order__c = woId;
                woLine.SVMXC__Serial_Number__c = InsertComponent();
                woLine.RecordTypeId = recordTypeIdMap.get('Products_Serviced');
                woLine.SVMXC__Product_Warranty__c = InsertWarranties(woLine.SVMXC__Serial_Number__c);
                productServicedLinesList.add(woLine);
            }
            //Id warrantyId = InsertWarranties(productServicedLinesList[0].SVMXC__Serial_Number__c);
            //insert productServicedLinesList;
            return (new Map<Id, SVMXC__Service_Order_Line__c>(productServicedLinesList));
    }
    
    private static void createOptimizationSettings(){
            /*String confProfileTypeId = '';
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
            Database.upsert(conf_GLOB001_GBL007);*/
            
            //adding GLOB001 GBL022 Process Setting
            /*SVMXC__ServiceMax_Processes__c settingProc_GLOB001_GBL022 = new SVMXC__ServiceMax_Processes__c();
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
            Database.upsert(conf_GLOB001_GBL022);*/
            
            
            //adding OptiMax Process Module
            /*SVMXC__ServiceMax_Processes__c modProc_OMAX = new SVMXC__ServiceMax_Processes__c();
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
            
            System.debug('createOptimizationSettingsMethod');*/
    }
    
    private static void createOptimizationSettings_1(){
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
    
      Static testMethod void getWOAppointmentSettings_Idle(){
                       
            Id woId = CreateWorkOrder(); 
            Test.StartTest();
            WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request request = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request();
            //request.headerId = woId;
            
            List<BusinessHours> lBH = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 2];
                        
            SVMXC__Territory__c objTerritory = new SVMXC__Territory__c();
            objTerritory.name = 'India';                    
            objTerritory.SVMXC__Territory_s_Business_Hours__c = lBH[0].id;
            insert objTerritory;
        
            
            SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
            //svmxprocess.SVMXC__Territory__c = objTerritory.Id;
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
            svmxprocess.SVMXC__Weight_Total_Distance__c =1.0000;
            svmxprocess.SVMXC__Calendar_Start_Days__c = 0;
            svmxprocess.SVMXC__Calendar_End_Days__c = 2;
            svmxprocess.SVMXC__Tolerance__c = 60;
            svmxprocess.SVMXC__ProcessID__c = 'PROCESS11';
            svmxprocess.SVMXC__SettingId__c = 'PROCESS11';
            svmxprocess.SVMXC__MapID__c = 'PROCESS11';
            svmxprocess.SVMXC__Name__c = 'PROCESS22';
            Insert svmxprocess;
            
            SVMXC__ServiceMax_Processes__c svmxprocess2 = new SVMXC__ServiceMax_Processes__c();
            svmxprocess2.SVMXC__Territory__c = objTerritory.Id;
            svmxprocess2.SVMXC__Process__c = svmxprocess.id;
            svmxprocess2.SVMXC__MapID__c = 'PROCESS11';
            Insert svmxprocess2;            
                                    
            List<SVMXC__SVMX_Jobs__c> lstJobs = new list<SVMXC__SVMX_Jobs__c>();
                        
            SVMXC__SVMX_Jobs__c job1 = new SVMXC__SVMX_Jobs__c();
            job1.SVMXC__SVMX_Process__c = svmxprocess.Id;
            job1.SVMXC__Territory__c = objTerritory.Id;
            job1.SVMXC__OptiMax_Message__c ='IDLE';
            job1.SVMXC__Type__c = 'ECO';
            job1.SVMXC__Start_Time__c = system.now();
            lstJobs.add(job1);
                                    
            insert lstJobs;
            
            SVMXC__SM_Appointment_Window__c appointmentType = new SVMXC__SM_Appointment_Window__c();
            appointmentType.Name = 'GoldType';
            appointmentType.SVMXC__SM_Appointment_Type_Name__c = 'GoldType';
            appointmentType.RecordTypeId = Schema.SObjectType.SVMXC__SM_Appointment_Window__c.getRecordTypeInfosByName().get('Appointment Type').getRecordTypeId();
            insert appointmentType;
        
            SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
            workOrder1.SVMXC__Service_Duration__c = 3600;
            workOrder1.SVMXC__Zip__c = '560022';
            workOrder1.SVMXC__Primary_Territory__c = objTerritory.Id;
            workOrder1.SVMXC__SM_Appointment_Type__c = appointmentType.Id;
            workOrder1.SVMXC__Preferred_Start_Time__c = datetime.now();
            workOrder1.SVMXC__Preferred_End_Time__c=datetime.now()+1;
            insert workOrder1;
            
            WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Settings defaultSettingValues = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Settings();
            defaultSettingValues.numberOfOfferAppts = '40';
            defaultSettingValues.numberOfDays = '7';
            defaultSettingValues.considerCostOrDates= 'Dates'; 
            DateTime curDate = system.today();
            defaultSettingValues.startDate= String.valueOf(curDate);
            defaultSettingValues.endDate= String.valueOf(curDate);
            
            request.appointmentSettings = defaultSettingValues;            
            request.headerId = workOrder1.id;
                            
            //createOptimizationSettings();
            createOptimizationSettings_1();                                     
            WSCH_Provider_ECO_Appointment.getWOAppointmentSettings(JSON.serialize(request));   
            Test.StopTest();
        
      }    

      Static testMethod void getWOAppointmentSettings_Resume(){
                       
            Id woId = CreateWorkOrder(); 
            Test.StartTest();
            WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request request = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request();
            //request.headerId = woId;
            
            List<BusinessHours> lBH = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 2];
                        
            SVMXC__Territory__c objTerritory = new SVMXC__Territory__c();
            objTerritory.name = 'India';                    
            objTerritory.SVMXC__Territory_s_Business_Hours__c = lBH[0].id;
            insert objTerritory;
        
            
            SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
            //svmxprocess.SVMXC__Territory__c = objTerritory.Id;
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
            svmxprocess.SVMXC__Weight_Total_Distance__c =1.0000;
            svmxprocess.SVMXC__Calendar_Start_Days__c = 0;
            svmxprocess.SVMXC__Calendar_End_Days__c = 2;
            svmxprocess.SVMXC__Tolerance__c = 60;
            svmxprocess.SVMXC__ProcessID__c = 'PROCESS11';
            svmxprocess.SVMXC__SettingId__c = 'PROCESS11';
            svmxprocess.SVMXC__MapID__c = 'PROCESS11';
            svmxprocess.SVMXC__Name__c = 'PROCESS22';
            Insert svmxprocess;
            
            SVMXC__ServiceMax_Processes__c svmxprocess2 = new SVMXC__ServiceMax_Processes__c();
            svmxprocess2.SVMXC__Territory__c = objTerritory.Id;
            svmxprocess2.SVMXC__Process__c = svmxprocess.id;
            svmxprocess2.SVMXC__MapID__c = 'PROCESS11';
            Insert svmxprocess2;            
                                    
            List<SVMXC__SVMX_Jobs__c> lstJobs = new list<SVMXC__SVMX_Jobs__c>();
                        
            SVMXC__SVMX_Jobs__c job1 = new SVMXC__SVMX_Jobs__c();
            job1.SVMXC__SVMX_Process__c = svmxprocess.Id;
            job1.SVMXC__Territory__c = objTerritory.Id;
            job1.SVMXC__OptiMax_Message__c ='RESUMING';
            job1.SVMXC__Type__c = 'ECO';
            job1.SVMXC__Start_Time__c = system.now();
            lstJobs.add(job1);
                                    
            insert lstJobs;
            
            SVMXC__SM_Appointment_Window__c appointmentType = new SVMXC__SM_Appointment_Window__c();
            appointmentType.Name = 'GoldType';
            appointmentType.SVMXC__SM_Appointment_Type_Name__c = 'GoldType';
            appointmentType.RecordTypeId = Schema.SObjectType.SVMXC__SM_Appointment_Window__c.getRecordTypeInfosByName().get('Appointment Type').getRecordTypeId();
            insert appointmentType;
        
            SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
            workOrder1.SVMXC__Service_Duration__c = 3600;
            workOrder1.SVMXC__Zip__c = '560022';
            workOrder1.SVMXC__Primary_Territory__c = objTerritory.Id;
            workOrder1.SVMXC__SM_Appointment_Type__c = appointmentType.Id;
            workOrder1.SVMXC__Preferred_Start_Time__c = datetime.now();
            workOrder1.SVMXC__Preferred_End_Time__c=datetime.now()+1;
            insert workOrder1;
            
            WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Settings defaultSettingValues = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Settings();
            defaultSettingValues.numberOfOfferAppts = '40';
            defaultSettingValues.numberOfDays = '7';
            defaultSettingValues.considerCostOrDates= 'Dates'; 
            DateTime curDate = system.today();
            defaultSettingValues.startDate= String.valueOf(curDate);
            defaultSettingValues.endDate= String.valueOf(curDate);
            
            request.appointmentSettings = defaultSettingValues;            
            request.headerId = workOrder1.id;
                            
            //createOptimizationSettings();
            createOptimizationSettings_1();                                     
            WSCH_Provider_ECO_Appointment.getWOAppointmentSettings(JSON.serialize(request));   
            
            
            //PST and PET is outside horizon
            SVMXC__Service_Order__c workOrder2 = new SVMXC__Service_Order__c();
            workOrder2.SVMXC__Service_Duration__c = 3600;
            workOrder2.SVMXC__Zip__c = '560022';
            workOrder2.SVMXC__Primary_Territory__c = objTerritory.Id;
            workOrder2.SVMXC__SM_Appointment_Type__c = appointmentType.Id;
            workOrder2.SVMXC__Preferred_Start_Time__c = datetime.now();
            workOrder2.SVMXC__Preferred_End_Time__c=datetime.now()+25;
            insert workOrder2;            
            request.headerId = workOrder2.id;
                            
            //createOptimizationSettings();
            createOptimizationSettings_1();                                     
            WSCH_Provider_ECO_Appointment.getWOAppointmentSettings(JSON.serialize(request));   
            
            //PST and PET both outside horizon
            SVMXC__Service_Order__c workOrder3 = new SVMXC__Service_Order__c();
            workOrder3.SVMXC__Service_Duration__c = 3600;
            workOrder3.SVMXC__Zip__c = '560022';
            workOrder3.SVMXC__Primary_Territory__c = objTerritory.Id;
            workOrder3.SVMXC__SM_Appointment_Type__c = appointmentType.Id;
            workOrder3.SVMXC__Preferred_Start_Time__c = datetime.now()-10;
            workOrder3.SVMXC__Preferred_End_Time__c=datetime.now()+25;
            insert workOrder3;            
            request.headerId = workOrder3.id;
                            
            //createOptimizationSettings();
            createOptimizationSettings_1();                                     
            WSCH_Provider_ECO_Appointment.getWOAppointmentSettings(JSON.serialize(request));   
            
            Test.StopTest();
        
      }
      
      Static testMethod void getWOAppointmentSettings_Suspended(){
                       
            Id woId = CreateWorkOrder(); 
            Test.StartTest();
            WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request request = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request();
            //request.headerId = woId;
            
            List<BusinessHours> lBH = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 2];
                        
            SVMXC__Territory__c objTerritory = new SVMXC__Territory__c();
            objTerritory.name = 'India';                    
            objTerritory.SVMXC__Territory_s_Business_Hours__c = lBH[0].id;
            insert objTerritory;
        
            
            SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
            //svmxprocess.SVMXC__Territory__c = objTerritory.Id;
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
            svmxprocess.SVMXC__Weight_Total_Distance__c =1.0000;
            svmxprocess.SVMXC__Calendar_Start_Days__c = 0;
            svmxprocess.SVMXC__Calendar_End_Days__c = 2;
            svmxprocess.SVMXC__Tolerance__c = 60;
            svmxprocess.SVMXC__ProcessID__c = 'PROCESS11';
            svmxprocess.SVMXC__SettingId__c = 'PROCESS11';
            svmxprocess.SVMXC__MapID__c = 'PROCESS11';
            svmxprocess.SVMXC__Name__c = 'PROCESS22';
            Insert svmxprocess;
            
            SVMXC__ServiceMax_Processes__c svmxprocess2 = new SVMXC__ServiceMax_Processes__c();
            svmxprocess2.SVMXC__Territory__c = objTerritory.Id;
            svmxprocess2.SVMXC__Process__c = svmxprocess.id;
            svmxprocess2.SVMXC__MapID__c = 'PROCESS11';
            Insert svmxprocess2;            
                                    
            List<SVMXC__SVMX_Jobs__c> lstJobs = new list<SVMXC__SVMX_Jobs__c>();
                        
            SVMXC__SVMX_Jobs__c job1 = new SVMXC__SVMX_Jobs__c();
            job1.SVMXC__SVMX_Process__c = svmxprocess.Id;
            job1.SVMXC__Territory__c = objTerritory.Id;
            job1.SVMXC__OptiMax_Message__c ='SUSPENDED';
            job1.SVMXC__Type__c = 'ECO';
            job1.SVMXC__Start_Time__c = system.now();
            lstJobs.add(job1);
                                    
            insert lstJobs;
            
            SVMXC__SM_Appointment_Window__c appointmentType = new SVMXC__SM_Appointment_Window__c();
            appointmentType.Name = 'GoldType';
            appointmentType.SVMXC__SM_Appointment_Type_Name__c = 'GoldType';
            appointmentType.RecordTypeId = Schema.SObjectType.SVMXC__SM_Appointment_Window__c.getRecordTypeInfosByName().get('Appointment Type').getRecordTypeId();
            insert appointmentType;
        
            SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
            workOrder1.SVMXC__Service_Duration__c = 3600;
            workOrder1.SVMXC__Zip__c = '560022';
            workOrder1.SVMXC__Primary_Territory__c = objTerritory.Id;
            workOrder1.SVMXC__SM_Appointment_Type__c = appointmentType.Id;
            workOrder1.SVMXC__Preferred_Start_Time__c = datetime.now();
            workOrder1.SVMXC__Preferred_End_Time__c=datetime.now()+1;
            insert workOrder1;
            
            WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Settings defaultSettingValues = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Settings();
            defaultSettingValues.numberOfOfferAppts = '40';
            defaultSettingValues.numberOfDays = '7';
            defaultSettingValues.considerCostOrDates= 'Dates'; 
            DateTime curDate = system.today();
            defaultSettingValues.startDate= String.valueOf(curDate);
            defaultSettingValues.endDate= String.valueOf(curDate);
            
            request.appointmentSettings = defaultSettingValues;            
            request.headerId = workOrder1.id;
                            
            //createOptimizationSettings();
            createOptimizationSettings_1();                                     
            WSCH_Provider_ECO_Appointment.getWOAppointmentSettings(JSON.serialize(request));   
            Test.StopTest();
      }
       Static testMethod void getWOAppointmentSettings_JobNull(){
                       
            Id woId = CreateWorkOrder(); 
            Test.StartTest();
            WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request request = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request();
            //request.headerId = woId;
            
            List<BusinessHours> lBH = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 2];
                        
            SVMXC__Territory__c objTerritory;
        
            
            SVMXC__ServiceMax_Processes__c svmxprocess;
            
                                   
            List<SVMXC__SVMX_Jobs__c> lstJobs = new list<SVMXC__SVMX_Jobs__c>();
                        
            SVMXC__SVMX_Jobs__c job1 = new SVMXC__SVMX_Jobs__c();
            job1.SVMXC__SVMX_Process__c = null;
            job1.SVMXC__Territory__c = null;
            job1.SVMXC__OptiMax_Message__c ='FAILED';
            job1.SVMXC__Type__c = 'ECO';
            job1.SVMXC__Start_Time__c = system.now();
            lstJobs.add(job1);
                                    
            insert lstJobs;
            
            SVMXC__SM_Appointment_Window__c appointmentType = new SVMXC__SM_Appointment_Window__c();
            appointmentType.Name = 'GoldType';
            appointmentType.SVMXC__SM_Appointment_Type_Name__c = 'GoldType';
            appointmentType.RecordTypeId = Schema.SObjectType.SVMXC__SM_Appointment_Window__c.getRecordTypeInfosByName().get('Appointment Type').getRecordTypeId();
            insert appointmentType;
        
            SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
            workOrder1.SVMXC__Service_Duration__c = 3600;
            workOrder1.SVMXC__Zip__c = '560022';
            workOrder1.SVMXC__Primary_Territory__c = null;
            workOrder1.SVMXC__SM_Appointment_Type__c = appointmentType.Id;
            workOrder1.SVMXC__Preferred_Start_Time__c = datetime.now();
            workOrder1.SVMXC__Preferred_End_Time__c=datetime.now()+1;
            insert workOrder1;
            
            WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Settings defaultSettingValues = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Settings();
            defaultSettingValues.numberOfOfferAppts = '40';
            defaultSettingValues.numberOfDays = '7';
            defaultSettingValues.considerCostOrDates= 'Dates'; 
            DateTime curDate = system.today();
            defaultSettingValues.startDate= String.valueOf(curDate);
            defaultSettingValues.endDate= String.valueOf(curDate);
            
            request.appointmentSettings = defaultSettingValues;            
            request.headerId = workOrder1.id;
                            
            //createOptimizationSettings();
            createOptimizationSettings_1();                                     
            WSCH_Provider_ECO_Appointment.getWOAppointmentSettings(JSON.serialize(request));   
            Test.StopTest();
        
      }
      
      Static testMethod void getWOAppointmentSettings_dependency(){
                       
            Id woId = CreateWorkOrder(); 
            Test.StartTest();
            WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request request = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request();
            //request.headerId = woId;
            
            List<BusinessHours> lBH = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 2];
                        
            SVMXC__Territory__c objTerritory;
        
            
            SVMXC__ServiceMax_Processes__c svmxprocess;
            
                                   
            List<SVMXC__SVMX_Jobs__c> lstJobs = new list<SVMXC__SVMX_Jobs__c>();
                        
            SVMXC__SVMX_Jobs__c job1 = new SVMXC__SVMX_Jobs__c();
            job1.SVMXC__SVMX_Process__c = null;
            job1.SVMXC__Territory__c = null;
            job1.SVMXC__OptiMax_Message__c ='FAILED';
            job1.SVMXC__Type__c = 'ECO';
            job1.SVMXC__Start_Time__c = system.now();
            lstJobs.add(job1);
                                    
            insert lstJobs;
            
            SVMXC__SM_Appointment_Window__c appointmentType = new SVMXC__SM_Appointment_Window__c();
            appointmentType.Name = 'GoldType';
            appointmentType.SVMXC__SM_Appointment_Type_Name__c = 'GoldType';
            appointmentType.RecordTypeId = Schema.SObjectType.SVMXC__SM_Appointment_Window__c.getRecordTypeInfosByName().get('Appointment Type').getRecordTypeId();
            insert appointmentType;
        
            SVMXC__Dependency_Management__c dependencyManagement = new SVMXC__Dependency_Management__c();
            dependencyManagement.SVMXC__Dependency_Group_Name__c = 'BDG-01';
            insert dependencyManagement;
                        
            SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
            workOrder1.SVMXC__Service_Duration__c = 3600;
            workOrder1.SVMXC__Zip__c = '560022';
            workOrder1.SVMXC__Primary_Territory__c = null;
            workOrder1.SVMXC__SM_Appointment_Type__c = appointmentType.Id;
            workOrder1.SVMXC__Preferred_Start_Time__c = datetime.now();
            workOrder1.SVMXC__Preferred_End_Time__c=datetime.now()+1;
            workOrder1.SVMXC__Dependency_Group__c = dependencyManagement.Id;
            insert workOrder1;
            
            WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Settings defaultSettingValues = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Settings();
            defaultSettingValues.numberOfOfferAppts = '40';
            defaultSettingValues.numberOfDays = '7';
            defaultSettingValues.considerCostOrDates= 'Dates'; 
            DateTime curDate = system.today();
            defaultSettingValues.startDate= String.valueOf(curDate);
            defaultSettingValues.endDate= String.valueOf(curDate);
            
            request.appointmentSettings = defaultSettingValues;            
            request.headerId = workOrder1.id;
                            
            //createOptimizationSettings();
            createOptimizationSettings_1();                                     
            WSCH_Provider_ECO_Appointment.getWOAppointmentSettings(JSON.serialize(request));
            
            WSCH_Provider_ECO_Appointment_Impl appointment_impl = new WSCH_Provider_ECO_Appointment_Impl();
            appointment_impl.numberOfDays = '10';
            appointment_impl.numberOfOfferAppts = '10';
            
            WSCH_Provider_ECO_Appointment_Impl.bookedApptSlot = 'bookedSlot';
               
            Test.StopTest();
      }          

      Static testMethod void getWOAppointmentSettingsTestMethod_coverMore1(){
                       
            Id woId = CreateWorkOrder(); 
            Test.StartTest();
            WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request request = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request();
            //request.headerId = woId;
            
            List<BusinessHours> lBH = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 2];
                        
            SVMXC__Territory__c objTerritory = new SVMXC__Territory__c();
            objTerritory.name = 'India';                    
            objTerritory.SVMXC__Territory_s_Business_Hours__c = lBH[0].id;
            insert objTerritory;
        
            
            SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
            //svmxprocess.SVMXC__Territory__c = objTerritory.Id;
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
            svmxprocess.SVMXC__Weight_Total_Distance__c =1.0000;
            svmxprocess.SVMXC__Calendar_Start_Days__c = 0;
            svmxprocess.SVMXC__Calendar_End_Days__c = 2;
            svmxprocess.SVMXC__Tolerance__c = 60;
            svmxprocess.SVMXC__ProcessID__c = 'PROCESS11';
            svmxprocess.SVMXC__SettingId__c = 'PROCESS11';
            svmxprocess.SVMXC__MapID__c = 'PROCESS11';
            svmxprocess.SVMXC__Name__c = 'PROCESS22';
            Insert svmxprocess;
            
            SVMXC__ServiceMax_Processes__c svmxprocess2 = new SVMXC__ServiceMax_Processes__c();
            svmxprocess2.SVMXC__Territory__c = objTerritory.Id;
            svmxprocess2.SVMXC__Process__c = svmxprocess.id;
            svmxprocess2.SVMXC__MapID__c = 'PROCESS11';
            Insert svmxprocess2;            
                                    
            /*List<SVMXC__SVMX_Jobs__c> lstJobs = new list<SVMXC__SVMX_Jobs__c>();
                        
            SVMXC__SVMX_Jobs__c job1 = new SVMXC__SVMX_Jobs__c();
            job1.SVMXC__SVMX_Process__c = svmxprocess.Id;
            job1.SVMXC__Territory__c = objTerritory.Id;
            job1.SVMXC__OptiMax_Message__c ='RUNNING';
            job1.SVMXC__Type__c = 'ECO';
            job1.SVMXC__Start_Time__c = system.now();
            lstJobs.add(job1);
                                    
            insert lstJobs;*/
            
            SVMXC__SM_Appointment_Window__c appointmentType = new SVMXC__SM_Appointment_Window__c();
            appointmentType.Name = 'GoldType';
            appointmentType.SVMXC__SM_Appointment_Type_Name__c = 'GoldType';
            appointmentType.RecordTypeId = Schema.SObjectType.SVMXC__SM_Appointment_Window__c.getRecordTypeInfosByName().get('Appointment Type').getRecordTypeId();
            insert appointmentType;
        
            SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
            workOrder1.SVMXC__Service_Duration__c = null;
            workOrder1.SVMXC__Zip__c = '';
            //workOrder1.SVMXC__Primary_Territory__c = objTerritory.Id;
            workOrder1.SVMXC__SM_Appointment_Type__c = null;
            workOrder1.SVMXC__Latitude__c = 20.11;
            workOrder1.SVMXC__Longitude__c = 30.22;
            
            insert workOrder1;
            
            WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Settings defaultSettingValues = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Settings();
            defaultSettingValues.numberOfOfferAppts = '40';
            defaultSettingValues.numberOfDays = '7';
            defaultSettingValues.considerCostOrDates= 'Dates'; 
            DateTime curDate = system.today();
            defaultSettingValues.startDate= String.valueOf(curDate);
            defaultSettingValues.endDate= String.valueOf(curDate);
            
            request.appointmentSettings = defaultSettingValues;            
            request.headerId = workOrder1.id;
                            
            //createOptimizationSettings();
            createOptimizationSettings_1();                                     
            WSCH_Provider_ECO_Appointment.getWOAppointmentSettings(JSON.serialize(request));

            SVMXC__Service_Order__c workOrder2 = new SVMXC__Service_Order__c();
            workOrder2.SVMXC__Service_Duration__c = 3600;
            workOrder2.SVMXC__Zip__c = '';
            workOrder2.SVMXC__Country__c = '';
            workOrder2.SVMXC__Latitude__c = NULL;
            workOrder2.SVMXC__Longitude__c = NULL;
            workOrder2.SVMXC__Primary_Territory__c = objTerritory.Id;
            workOrder2.SVMXC__SM_Appointment_Type__c = appointmentType.Id;
            
            insert workOrder2;
            request.headerId = workOrder2.id;
            createOptimizationSettings_1();                                     
            WSCH_Provider_ECO_Appointment.getWOAppointmentSettings(JSON.serialize(request));

            SVMXC__Service_Order__c workOrder3 = new SVMXC__Service_Order__c();
            workOrder3.SVMXC__Service_Duration__c = 3600;
            workOrder3.SVMXC__Zip__c = '560022';
            workOrder3.SVMXC__Country__c = 'India';
            workOrder3.SVMXC__Primary_Territory__c = objTerritory.Id;
            workOrder3.SVMXC__SM_Appointment_Type__c = appointmentType.Id;
            workOrder3.SVMXC__Latitude__c = 20.33;
            workOrder3.SVMXC__Longitude__c = 30.33;
            workOrder3.SVMXC__Work_Order_Scheduling_Status__c = 'Dispatched';
            
            insert workOrder3;
            request.headerId = workOrder3.id;
            createOptimizationSettings_1();                                     
            WSCH_Provider_ECO_Appointment.getWOAppointmentSettings(JSON.serialize(request));

            SVMXC__Service_Order__c workOrder4 = new SVMXC__Service_Order__c();
            workOrder4.SVMXC__Service_Duration__c = NULL;
            workOrder4.SVMXC__Zip__c = '560022';
            workOrder4.SVMXC__Country__c = 'India';
            workOrder4.SVMXC__Primary_Territory__c = objTerritory.Id;
            workOrder4.SVMXC__SM_Appointment_Type__c = NULL;
            workOrder4.SVMXC__Latitude__c = 20.33;
            workOrder4.SVMXC__Longitude__c = 40.33;
            workOrder4.SVMXC__Optimax_Status__c = 'OPT_PENDING';
            workOrder4.SVMXC__Locked_By_DC__c = true;
            
            insert workOrder4;
            request.headerId = workOrder4.id;
            createOptimizationSettings_1();                                     
            WSCH_Provider_ECO_Appointment.getWOAppointmentSettings(JSON.serialize(request));

            SVMXC__Service_Order__c workOrder5 = new SVMXC__Service_Order__c();
            workOrder5.SVMXC__Service_Duration__c = NULL;
            workOrder5.SVMXC__Zip__c = '560022';
            workOrder5.SVMXC__Country__c = 'India';
            workOrder5.SVMXC__Primary_Territory__c = NULL;
            workOrder5.SVMXC__SM_Appointment_Type__c = NULL;
            workOrder5.SVMXC__Latitude__c = 20.33;
            workOrder5.SVMXC__Longitude__c = 40.33;
            workOrder5.SVMXC__Optimax_Status__c = 'OPT_PENDING';
            workOrder5.SVMXC__Locked_By_DC__c = true;
            
            insert workOrder5;
            request.headerId = workOrder5.id;
            createOptimizationSettings_1();                                     
            WSCH_Provider_ECO_Appointment.getWOAppointmentSettings(JSON.serialize(request));

            Test.StopTest();
      }

      Static testMethod void getWOAppointmentSettingsTestMethod_coverMore2() {
            Test.StartTest();
            WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request request = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Request();
            
            WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Settings defaultSettingValues = new WSCH_Provider_ECO_AppointmentWrapperDef.WSCH_Provider_ECO_Appointment_Settings();
            defaultSettingValues.numberOfOfferAppts = '40';
            defaultSettingValues.numberOfDays = '7';
            defaultSettingValues.considerCostOrDates= 'Dates'; 
            DateTime curDate = system.today();
            defaultSettingValues.startDate= String.valueOf(curDate);
            defaultSettingValues.endDate= String.valueOf(curDate);
            
            request.appointmentSettings = defaultSettingValues;            
                            
            //createOptimizationSettings();
            //createOptimizationSettings_1();                                     
            WSCH_Provider_ECO_Appointment.getWOAppointmentSettings(JSON.serialize(request));
      }
}