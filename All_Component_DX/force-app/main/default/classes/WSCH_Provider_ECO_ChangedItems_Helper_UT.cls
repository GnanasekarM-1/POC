@isTest
    public with sharing class WSCH_Provider_ECO_ChangedItems_Helper_UT {
        
         static testMethod void WORD_handlePushREquest() {
         
         SVMXC__Territory__c testTer = createECOTerritory();
         SVMXC__Service_Group_Members__c tectTechnician = createECOTechnician(testTer.id);
         Event event = createSFEvent(tectTechnician.id);
        
         List<WSCH_Provider_ECO_Push_Stubs.WorkItem> workItems = new List<WSCH_Provider_ECO_Push_Stubs.WorkItem>();
         WSCH_Provider_ECO_Push_Stubs.WorkItem workItem = new WSCH_Provider_ECO_Push_Stubs.WorkItem();
         
         WSCH_Provider_ECO_Push_Stubs.Booking booking = createBooking();
         booking.tech = tectTechnician.id+tectTechnician.name;
            
           workItem.id = 'Event_'+event.id+tectTechnician.name;
           workItem.type = 'ACTIVITY';
           workItem.booking = booking;
           workItems.add(workItem);
          
           WSCH_Provider_ECO_Push_Stubs.PushRequest pushRequest = new WSCH_Provider_ECO_Push_Stubs.PushRequest();
           pushRequest.changeTime = '2016-11-18 05:26';
           pushRequest.workItems = workItems;
           pushRequest.state = 'ON_TENTATIVE';
           pushRequest.errorcode = '[No Error!]';
           
           WSCH_AuditLogger.isLinxMetricLogEnabled  = true;
           WSCH_Provider_ECO_ChangedItems_Helper.doProcessRequest(pushRequest);
          
         }
         
         static testMethod void testDispatchPushRequest() {
            SVMXC__Territory__c testTer = createECOTerritory();
            SVMXC__Service_Group_Members__c tectTechnician = createECOTechnician(testTer.id);
            Event event = createSFEvent(tectTechnician.id);
            
            SVMXC__Service_Order__c wo1 = new SVMXC__Service_Order__c();
            wo1.SVMXC__Primary_Territory__c = testTer.Id;
            wo1.SVMXC__Group_Member__c=tectTechnician.Id;
            wo1.SVMXC__zip__c='560005';
            insert wo1;
            
            SVMXC__Service_Order__c createdWO1= [Select Name from SVMXC__Service_Order__c where id =: wo1.id];
            
            WSCH_Provider_ECO_Push_Stubs.Booking booking = createBooking();
            booking.tech = tectTechnician.id+tectTechnician.name;
            

            List<WSCH_Provider_ECO_Push_Stubs.WorkItem> workItems = new List<WSCH_Provider_ECO_Push_Stubs.WorkItem>();
            WSCH_Provider_ECO_Push_Stubs.WorkItem workItem = new WSCH_Provider_ECO_Push_Stubs.WorkItem();
            workItem.id = createdWO1.Name;
            workItem.type = 'JOB';
            workItem.booking = booking;
            workItem.ignored=true;
            workItems.add(workItem);
            
            WSCH_Provider_ECO_Push_Stubs.WorkItem workItem1 = new WSCH_Provider_ECO_Push_Stubs.WorkItem();
            workItem1.id = '12';
            workItem1.type = 'JOB';
            workItem1.booking = booking;
            workItem1.ignored=true;
            workItems.add(workItem1);
            
           WSCH_Provider_ECO_Push_Stubs.PushRequest pushRequest = new WSCH_Provider_ECO_Push_Stubs.PushRequest();
           pushRequest.changeTime = '2017-05-01 00:41';
           pushRequest.workItems = workItems;
           pushRequest.state = 'ON_DISPATCH';
           pushRequest.errorcode = '[No Error!]';
           
           //WSCH_Provider_ECO_ChangedItems_Helper.createOptimizerObjects(pushRequest);
           WSCH_AuditLogger.isLinxMetricLogEnabled  = true;
           WSCH_Provider_ECO_ChangedItems_Helper.doProcessRequest(pushRequest);
         }
         
         
          static testMethod void testFailurePushRequest() {
            SVMXC__Territory__c testTer = createECOTerritory();
            SVMXC__Service_Group_Members__c tectTechnician = createECOTechnician(testTer.id);
            Event event = createSFEvent(tectTechnician.id);
            
            SVMXC__Service_Order__c wo1 = new SVMXC__Service_Order__c();
            wo1.SVMXC__Primary_Territory__c = testTer.Id;
            wo1.SVMXC__Group_Member__c=tectTechnician.Id;
            wo1.SVMXC__zip__c='560005';
            insert wo1;
            
            SVMXC__Service_Order__c createdWO1= [Select Name from SVMXC__Service_Order__c where id =: wo1.id];
            
            List<WSCH_Provider_ECO_Push_Stubs.WorkItem> workItems = new List<WSCH_Provider_ECO_Push_Stubs.WorkItem>();
            WSCH_Provider_ECO_Push_Stubs.WorkItem workItem = new WSCH_Provider_ECO_Push_Stubs.WorkItem();
            workItem.id = createdWO1.Name;
            workItem.type = 'JOB';
            workItem.booking = null;
            workItem.ignored=true;
            workItem.errorMsg= 'Connection Issue';
            workItems.add(workItem);
            
            WSCH_Provider_ECO_Push_Stubs.Booking booking = createBooking();
            booking.tech = tectTechnician.id+tectTechnician.name;
            
           WSCH_Provider_ECO_Push_Stubs.PushRequest pushRequest = new WSCH_Provider_ECO_Push_Stubs.PushRequest();
           pushRequest.changeTime = '2017-05-01 00:41';
           pushRequest.workItems = workItems;
           pushRequest.state = 'ON_FAILURE';
           pushRequest.errorcode = '[No Error!]';
           WSCH_AuditLogger.isLinxMetricLogEnabled  = true;
           WSCH_Provider_ECO_ChangedItems_Helper.doProcessRequest(pushRequest);
           
            workItems = new List<WSCH_Provider_ECO_Push_Stubs.WorkItem>();
            workItem = new WSCH_Provider_ECO_Push_Stubs.WorkItem();
            workItem.id = createdWO1.Name;
            workItem.type = 'JOB';
            workItem.booking = null;
            workItems.add(workItem);
            pushRequest.workItems = workItems;
            WSCH_Provider_ECO_ChangedItems_Helper.doProcessRequest(pushRequest);
            
            
          workItems = new List<WSCH_Provider_ECO_Push_Stubs.WorkItem>();
          workItem = new WSCH_Provider_ECO_Push_Stubs.WorkItem();
          workItem.id = createdWO1.Name;
          workItem.type = 'ACTIVITY';
          workItem.booking = null;
          workItem.errorMsg= 'Connection Issue';
          workItems.add(workItem);
          pushRequest = new WSCH_Provider_ECO_Push_Stubs.PushRequest();
          pushRequest.changeTime = '2017-05-01 00:41';
          pushRequest.workItems = workItems;
          pushRequest.state = 'ON_FAILURE';
          pushRequest.errorcode = '[No Error!]';
          WSCH_Provider_ECO_ChangedItems_Helper.doProcessRequest(pushRequest);
           
        workItems = new List<WSCH_Provider_ECO_Push_Stubs.WorkItem>();
        workItem = new WSCH_Provider_ECO_Push_Stubs.WorkItem();
        workItem.id = createdWO1.Name;
        workItem.type = 'ACTIVITY';
        workItem.booking = null;
        workItems.add(workItem);
        pushRequest.workItems = workItems;
        WSCH_Provider_ECO_ChangedItems_Helper.doProcessRequest(pushRequest);
        
          workItems = new List<WSCH_Provider_ECO_Push_Stubs.WorkItem>();
          workItem = new WSCH_Provider_ECO_Push_Stubs.WorkItem();
          workItem.id = tectTechnician.id+'_techname';
          workItem.type = 'RESOURCE';
          workItem.booking = null;
          workItem.errorMsg= 'Connection Issue';
          workItems.add(workItem);
          pushRequest = new WSCH_Provider_ECO_Push_Stubs.PushRequest();
          pushRequest.changeTime = '2017-05-01 00:41';
          pushRequest.workItems = workItems;
          pushRequest.state = 'ON_FAILURE';
          pushRequest.errorcode = '[No Error!]';
          WSCH_Provider_ECO_ChangedItems_Helper.doProcessRequest(pushRequest);
          
          workItems = new List<WSCH_Provider_ECO_Push_Stubs.WorkItem>();
          workItem = new WSCH_Provider_ECO_Push_Stubs.WorkItem();
          workItem.id = tectTechnician.id+'_techname';
          workItem.type = 'RESOURCE';
          workItem.booking = null;
          workItems.add(workItem);
          pushRequest = new WSCH_Provider_ECO_Push_Stubs.PushRequest();
          pushRequest.changeTime = '2017-05-01 00:41';
          pushRequest.workItems = workItems;
          pushRequest.state = 'ON_FAILURE';
          pushRequest.errorcode = '[No Error!]';
          WSCH_Provider_ECO_ChangedItems_Helper.doProcessRequest(pushRequest);
          

          createOptimizer(tectTechnician.id);
          workItems = new List<WSCH_Provider_ECO_Push_Stubs.WorkItem>();
          workItem = new WSCH_Provider_ECO_Push_Stubs.WorkItem();
          workItem.id = tectTechnician.id;
          workItem.type = 'RESOURCE';
          workItem.booking = null;
          workItem.resolvedLatitude=1.1;
          workItem.resolvedLongitude=2.2;
          workItem.errorMsg = 'Resource Error';
          
          workItems.add(workItem);
          pushRequest = new WSCH_Provider_ECO_Push_Stubs.PushRequest();
          pushRequest.changeTime = '2017-05-01 00:41';
          pushRequest.workItems = workItems;
          pushRequest.state = 'ON_TENTATIVE';
          pushRequest.errorcode = '[No Error!]';
          WSCH_Provider_ECO_ChangedItems_Helper.doProcessRequest(pushRequest);
           
         }
         
         
        static testMethod void testUnAssignedPushRequest() {
            SVMXC__Territory__c testTer = createECOTerritory();
            SVMXC__Service_Group_Members__c tectTechnician = createECOTechnician(testTer.id);
            Event event = createSFEvent(tectTechnician.id);
            
            List<SVMXC__Service_Order__c> lstWO = new List<SVMXC__Service_Order__c>();
            SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
            wo.SVMXC__Primary_Territory__c = testTer.Id;
            wo.SVMXC__Group_Member__c=tectTechnician.Id;
            wo.SVMXC__zip__c='560001';
            lstWO.add(wo);
            
            SVMXC__Service_Order__c wo1 = new SVMXC__Service_Order__c();
            wo1.SVMXC__Primary_Territory__c = testTer.Id;
            wo1.SVMXC__Group_Member__c=tectTechnician.Id;
            wo1.SVMXC__zip__c='560005';
            lstWO.add(wo1);
            
            SVMXC__Service_Order__c wo2 = new SVMXC__Service_Order__c();
            wo2.SVMXC__Primary_Territory__c = testTer.Id;
            wo2.SVMXC__Group_Member__c=tectTechnician.Id;
            wo2.SVMXC__zip__c='560005';
            lstWO.add(wo2);
            SVMXC__Service_Order__c wo3 = new SVMXC__Service_Order__c();
            wo3.SVMXC__Primary_Territory__c = testTer.Id;
            wo3.SVMXC__Group_Member__c=tectTechnician.Id;
            wo3.SVMXC__zip__c='560005';
            lstWO.add(wo3);
                    
            insert lstWO;
            
            SVMXC__Service_Order__c createdWO1= [Select Name from SVMXC__Service_Order__c where id =: wo.id];
            SVMXC__Service_Order__c createdWO2= [Select Name from SVMXC__Service_Order__c where id =: wo1.id];
            SVMXC__Service_Order__c createdWO3= [Select Name from SVMXC__Service_Order__c where id =: wo2.id];
            SVMXC__Service_Order__c createdWO4= [Select Name from SVMXC__Service_Order__c where id =: wo3.id];

            
            createSFEvent(createdWO1.id);
            createSFEvent(createdWO3.id);
            
            createSVMXECOEVENT(createdWO2.id);
            createSVMXECOEVENT(createdWO4.id);
            
            List<WSCH_Provider_ECO_Push_Stubs.WorkItem> workItems = new List<WSCH_Provider_ECO_Push_Stubs.WorkItem>();
            WSCH_Provider_ECO_Push_Stubs.WorkItem workItem = new WSCH_Provider_ECO_Push_Stubs.WorkItem();
            workItem.id = createdWO1.Name;
            workItem.type = 'JOB';
            workItem.booking = null;
            workItem.ignored=true;
            workItems.add(workItem);
            
            WSCH_Provider_ECO_Push_Stubs.WorkItem workItem1 = new WSCH_Provider_ECO_Push_Stubs.WorkItem();
            workItem1.id = null;
            workItem1.type = 'JOB';
            workItem1.booking = null;
            workItem1.ignored=false;
            workItems.add(workItem1);
            
            WSCH_Provider_ECO_Push_Stubs.WorkItem workItem2 = new WSCH_Provider_ECO_Push_Stubs.WorkItem();
            workItem2.id = createdWO3.Name;
            workItem2.type = 'JOB';
            workItem2.booking = null;
            workItem2.ignored=false;
            workItems.add(workItem2);
            
            WSCH_Provider_ECO_Push_Stubs.WorkItem workItem3 = new WSCH_Provider_ECO_Push_Stubs.WorkItem();
            workItem3.id = createdWO4.Name;
            workItem3.type = 'JOB';
            workItem3.booking = null;
            workItem3.ignored=true;
            workItems.add(workItem3);
            
            WSCH_Provider_ECO_Push_Stubs.WorkItem workItem4 = new WSCH_Provider_ECO_Push_Stubs.WorkItem();
            workItem4.id = createdWO2.Name;
            workItem4.type = 'JOB';
            workItem4.booking = null;
            workItem4.ignored=false;
            workItems.add(workItem4);
      
           WSCH_Provider_ECO_Push_Stubs.PushRequest pushRequest = new WSCH_Provider_ECO_Push_Stubs.PushRequest();
           pushRequest.changeTime = '2017-05-01 00:41';
           pushRequest.workItems = workItems;
           pushRequest.state = 'ON_UNASSIGNED';
           pushRequest.errorcode = '[No Error!]';
           
           WSCH_AuditLogger.isLinxMetricLogEnabled  = true;
           WSCH_Provider_ECO_ChangedItems_Helper.doProcessRequest(pushRequest);
         }
             
         //private supporting methods
        private static Event createSFEvent(String techId){
            Event ev = new Event();
            ev.EventSubtype  = 'Event';
            ev.StartDateTime = system.today();
            ev.EndDateTime = system.today() + 1;
            ev.WhatId = techId;
            insert ev;
            return ev;
        }
        
        private  static SVMXC__SVMX_Event__c createSVMXECOEVENT(String technician){
        SVMXC__SVMX_Event__c svmxEv = new SVMXC__SVMX_Event__c();
        svmxEv.Name = 'EVMX_EV_UT';
        svmxEv.SVMXC__WhatId__c =  technician;
        svmxEv.SVMXC__StartDateTime__c= system.today();
        svmxEv.SVMXC__EndDateTime__c = system.today() + 1;
        
         insert svmxEv;
         return svmxEv;
      }
        
        private static SVMXC__Service_Group_Members__c createECOTechnician(String terId){
            SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
            technician.Name = 'ECO_Tech_UT';
            technician.SVMXC__City__c = 'Bangalore';
            technician.SVMXC__Country__c = 'India';
            technician.SVMXC__Zip__c = '560030';
            technician.SVMXC__Service_Territory__c = terId;
            technician.SVMXC__Service_Group__c= createServiceGroupId();
            insert technician;
            return technician;
        }
        
         private static String createServiceGroupId(){
         SVMXC__Service_Group__c segroup = new SVMXC__Service_Group__c();
         segroup.Name = 'TestGroup-UT';
         insert segroup;
         return segroup.id;
        }
        
         private static SVMXC__Territory__c createECOTerritory(){
            SVMXC__Territory__c ecoTeritory = new SVMXC__Territory__c();
             ecoTeritory.Name = 'Ter-UT';
             insert ecoTeritory;
             return ecoTeritory;
        }
        
        
        private static void createSettings(){
            
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
                
                //Create a Dispatch Management Module
                SVMXC__ServiceMax_Processes__c modProc_COMM = new SVMXC__ServiceMax_Processes__c();
                modProc_COMM.RecordTypeId = modTypeId;
                modProc_COMM.SVMXC__ModuleID__c = 'DCON';
                modProc_COMM.SVMXC__Name__c = 'Dispatch Management';
                modProc_COMM.SVMXC__IsStandard__c = true;
                modProc_COMM.SVMXC__Description__c = 'TEST MODULE DESCRIPTION';
                modProc_COMM.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                Database.upsert(modProc_COMM);
                
                //adding GLOB001 Process SubModule
                SVMXC__ServiceMax_Processes__c subModProc_DCON004 = new SVMXC__ServiceMax_Processes__c();
                subModProc_DCON004.RecordTypeId = subModTypeId;
                subModProc_DCON004.SVMXC__SubmoduleID__c = 'DCON004';
                subModProc_DCON004.SVMXC__Name__c = 'Linx for ServicePower';
                subModProc_DCON004.SVMXC__IsStandard__c = true;
                subModProc_DCON004.SVMXC__Module__c = modProc_COMM.id;
                subModProc_DCON004.SVMXC__Description__c = 'TEST SUBMODULE DESCRIPTION';
                subModProc_DCON004.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                Database.upsert(subModProc_DCON004);
                
             SVMXC__ServiceMax_Processes__c settingProc_DCON004_SET021 = new SVMXC__ServiceMax_Processes__c();
                settingProc_DCON004_SET021.RecordTypeId = setTypeId;
                settingProc_DCON004_SET021.SVMXC__SettingID__c = 'SET021';
                settingProc_DCON004_SET021.SVMXC__Data_Type__c = 'Boolean';
                settingProc_DCON004_SET021.SVMXC__Default_Value__c = 'true';
                settingProc_DCON004_SET021.SVMXC__Setting_Type__c = 'Global';
                settingProc_DCON004_SET021.SVMXC__Search_Order__c = 'Global';
                settingProc_DCON004_SET021.SVMXC__Active__c = true;
                settingProc_DCON004_SET021.SVMXC__IsStandard__c = true;
                settingProc_DCON004_SET021.SVMXC__Values__c = 'TRUE~|~FALSE';
                settingProc_DCON004_SET021.SVMXC__Submodule__c = subModProc_DCON004.id;
                settingProc_DCON004_SET021.SVMXC__SubmoduleID__c = 'DCON004';
                settingProc_DCON004_SET021.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
                settingProc_DCON004_SET021.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                Database.upsert(settingProc_DCON004_SET021);
        
        }
        
        
        static testMethod void testPerformanceMetrics() {
            SVMXC__Territory__c testTer = createECOTerritory();
            SVMXC__Service_Group_Members__c tectTechnician = createECOTechnician(testTer.id);
            SVMXC__Service_Group_Members__c tectTechnician1 = createECOTechnician(testTer.id);
            Event event = createSFEvent(tectTechnician.id);
            DateTime todayDate = system.now();
            
            SVMXC__ServiceMax_Processes__c woDP = createECODispatchProcess(testTer.id);
            
            SVMXC__Service_Order__c wo1 = new SVMXC__Service_Order__c();
            wo1.SVMXC__Primary_Territory__c = testTer.Id;
            wo1.SVMXC__Group_Member__c=tectTechnician.Id;
            wo1.SVMXC__zip__c='560005';
            wo1.SVMXC__Preferred_Start_Time__c = todayDate;
            wo1.SVMXC__Preferred_End_Time__c = todayDate;
            wo1.SVMXC__Scheduled_Date_Time__c = todayDate;
            wo1.SVMXC__Driving_Time__c = 5;
            wo1.SVMXC__Driving_Time__c = 2;
            wo1.SVMXC__Preferred_Technician__c=tectTechnician.id;
            wo1.SVMXC__Group_Member__c = tectTechnician.id;
            wo1.SVMXC__Dispatch_Process__c = woDP.id;
            insert wo1;
            SVMXC__Service_Order__c createdWO1= [Select Name from SVMXC__Service_Order__c where id =: wo1.id];
            
            List<WSCH_Provider_ECO_Push_Stubs.WorkItem> workItems = new List<WSCH_Provider_ECO_Push_Stubs.WorkItem>();
            WSCH_Provider_ECO_Push_Stubs.WorkItem workItem = new WSCH_Provider_ECO_Push_Stubs.WorkItem();
            workItem.id = createdWO1.Name;
            workItem.type = 'JOB';
            workItem.booking = null;
            workItem.ignored=true;
            workItems.add(workItem);

           WSCH_Provider_ECO_Push_Stubs.PushRequest pushRequest = new WSCH_Provider_ECO_Push_Stubs.PushRequest();
           pushRequest.changeTime = '2016-11-18 05:26';
           pushRequest.workItems = workItems;
           pushRequest.state = 'ON_DISPATCH';
           pushRequest.errorcode = '[No Error!]';
           
           WSCH_AuditLogger.isLinxMetricLogEnabled  = true;
           WSCH_Provider_ECO_ChangedItems_Helper.doProcessRequest(pushRequest);
           
           DateTime pushTime = WSCH_DateUtils.parseSPDateTimeGmt(pushRequest.changeTime);
           DateTime datetimeToday = WSCH_DateUtils.parseSPDateTimeGmt(pushRequest.changeTime);
           
           WSCH_AuditLogger.isLinxMetricLogEnabled  = true;
           WSCH_Provider_ECO_ChangedItems_Helper.createPerformanceMetricsLog(createdWO1.Name,datetimeToday,pushTime,'ON_DISPATCH',null);
           
           List<String> wos = new List<String>();
           wos.add(createdWO1.Name);
           WSCH_Provider_ECO_ChangedItems_Helper.updateWOintoMetrics(wos);
           
            wo1 = new SVMXC__Service_Order__c();
            wo1.SVMXC__Primary_Territory__c = testTer.Id;
            wo1.SVMXC__Group_Member__c=tectTechnician.Id;
            wo1.SVMXC__zip__c='560005';
            wo1.SVMXC__Preferred_Start_Time__c = system.now().addminutes(10);
            wo1.SVMXC__Preferred_End_Time__c = system.now().addminutes(15);
            wo1.SVMXC__Scheduled_Date_Time__c = system.now().addminutes(5);
            wo1.SVMXC__Driving_Time__c = 5;
            wo1.SVMXC__Driving_Time__c = 2;
            wo1.SVMXC__Preferred_Technician__c=tectTechnician.id;
            wo1.SVMXC__Dispatch_Process__c = woDP.id;
            wo1.SVMXC__Group_Member__c = tectTechnician1.id;
            insert wo1;
            SVMXC__Service_Order__c createdWO2= [Select Name from SVMXC__Service_Order__c where id =: wo1.id];
            WSCH_AuditLogger.isLinxMetricLogEnabled  = true;WSCH_Provider_ECO_ChangedItems_Helper.createPerformanceMetricsLog(createdWO2.Name,datetimeToday,pushTime,'ON_DISPATCH','Error');
            wos = new List<String>();
            wos.add(createdWO2.Name);
            WSCH_Provider_ECO_ChangedItems_Helper.updateWOintoMetrics(wos);
            
            wo1 = new SVMXC__Service_Order__c();
            wo1.SVMXC__Primary_Territory__c = testTer.Id;
            wo1.SVMXC__Group_Member__c=tectTechnician.Id;
            wo1.SVMXC__zip__c='560005';
            wo1.SVMXC__Preferred_Start_Time__c = system.now().addminutes(10);
            wo1.SVMXC__Preferred_End_Time__c = system.now().addminutes(15);
            wo1.SVMXC__Scheduled_Date_Time__c = system.now().addminutes(20);
            wo1.SVMXC__Driving_Time__c = 5;
            wo1.SVMXC__Driving_Time__c = 2;
            wo1.SVMXC__Preferred_Technician__c=tectTechnician.id;
            wo1.SVMXC__Dispatch_Process__c = woDP.id;
            wo1.SVMXC__Group_Member__c = tectTechnician1.id;
            insert wo1;
             createdWO2= [Select Name from SVMXC__Service_Order__c where id =: wo1.id];
            WSCH_AuditLogger.isLinxMetricLogEnabled  = true;WSCH_Provider_ECO_ChangedItems_Helper.createPerformanceMetricsLog(createdWO2.Name,datetimeToday,pushTime,'ON_DISPATCH','Error');
            wos = new List<String>();
            wos.add(createdWO2.Name);
            WSCH_Provider_ECO_ChangedItems_Helper.updateWOintoMetrics(wos);
           
           WSCH_Provider_ECO_ChangedItems_Helper.createPerformanceMetricsLog(wo1.Name,datetimeToday,pushTime,'ON_FAILURE','Connection Issue');
           WSCH_Provider_ECO_ChangedItems_Helper.createPerformanceMetricsLog(wo1.Name,datetimeToday,pushTime,'ON_FAILURE',null);
           WSCH_Provider_ECO_ChangedItems_Helper.createPerformanceMetricsUnassignedWO(wos,datetimeToday,pushTime,'ON_UNASSIGNED','Connection Issue');
           WSCH_Provider_ECO_ChangedItems_Helper.createPerformanceMetricsUnassignedWO(wos,datetimeToday,pushTime,'ON_UNASSIGNED',null);
           

         }
    
        private static WSCH_Provider_ECO_Push_Stubs.Booking createBooking(){
        WSCH_Provider_ECO_Push_Stubs.Booking booking  = new WSCH_Provider_ECO_Push_Stubs.Booking();
        booking.start = '2016-11-22 03:30';
         booking.end_x = '2016-11-22 04:30';
         booking.arr = '2016-11-22 03:30';
         booking.idleDuration = 1.2;
         booking.driveDuration = 1.3;
        booking.visitDuration = 2.5;
            
            return booking;
         
        }
        
      private static SVMXC__SVMX_Optimizer__c createOptimizer(String eventId){
         SVMXC__SVMX_Optimizer__c obj = new SVMXC__SVMX_Optimizer__c();
         obj.SVMXC__WhatType__c = 'NON_WO_EVENT';
          obj.SVMXC__WhatId__c = eventId;
          obj.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CREATE_EVENT' ;
         insert obj;
            return obj;
       }
       
     private static SVMXC__ServiceMax_Processes__c createECODispatchProcess(String terId){
      SVMXC__ServiceMax_Processes__c dprocess = new SVMXC__ServiceMax_Processes__c();
      dprocess.SVMXC__Dispatch_Method__c = 'Real Time Optimization';
      dprocess.SVMXC__Dispatch_Process_Status__c ='Complete';
      dprocess.SVMXC__Dispatch_Timezone__c= 'Asia/Colombo';
      dprocess.SVMXC__Name__c = 'Process-UT';
      dprocess.RecordTypeId = getDispatchProcessRecordId();
      dprocess.SVMXC__Territory__c = terId;
      
      insert dprocess;
      return dprocess;
    }
    
      private static String getDispatchProcessRecordId(){
      String dispatchProcessRecordType;
      RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' ];
      for(RecordType rt : rts)
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               dispatchProcessRecordType = rt.ID;
        }
        return dispatchProcessRecordType;
      
    }
    }