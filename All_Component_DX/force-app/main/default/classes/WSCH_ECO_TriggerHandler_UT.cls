@isTest(seeAllData = false)
private class WSCH_ECO_TriggerHandler_UT{

    static testMethod void WSCH_ECO_TriggerHandler_UT_UnitTest() { 
    
            Test.startTest();
            
            createOptimizationSettings();

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

            SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
            svmxprocess.SVMXC__Name__c = 'Linx for ServicePower 1';
            svmxprocess.RecordTypeId = DispatchProRecordTypeId;
            svmxprocess.SVMXC__Dispatch_Process_Status__c='Complete';
            svmxprocess.SVMXC__Dispatch_Method__c='Real Time Optimization';
            insert svmxprocess;

            SVMXC__ServiceMax_Processes__c svmxprocess1 = new SVMXC__ServiceMax_Processes__c();
            svmxprocess1.SVMXC__Name__c = 'Real Time Optimization test';
            svmxprocess1.RecordTypeId = DispatchProRecordTypeId;
            svmxprocess1.SVMXC__Dispatch_Process_Status__c='Complete';
            svmxprocess1.SVMXC__Dispatch_Method__c='Real Time Optimization';
            insert svmxprocess1;
            
            BusinessHours lstOfBusinessHours1;
            lstOfBusinessHours1 = [SELECT Id,IsActive,IsDefault,MondayStartTime,MondayEndTime,
                               TuesdayStartTime,TuesdayEndTime,WednesdayStartTime,WednesdayEndTime,
                               ThursdayStartTime,ThursdayEndTime,FridayStartTime,FridayEndTime,SaturdayStartTime,
                               SaturdayEndTime,SundayStartTime,SundayEndTime FROM BusinessHours
                               WHERE IsDefault = TRUE AND IsActive = TRUE Limit 1];

            SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
            oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
            oConf.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
            oConf.SVMXC__Display_Type__c = 'STRING';
            oConf.SVMXC__Operand__c='asdfgg';
            oConf.SVMXC__Operator__c='eq';
            oConf.RecordTypeId = ExpressionRTypeId;
            oConf.SVMXC__Sequence__c=1;
            oConf.SVMXC__Expression_Rule__c = svmxprocess.id;
            insert oConf;

            SVMXC__Territory__c territory = new SVMXC__Territory__c();
            territory.name = 'South Central Region';
            territory.SVMXC__Optimizer_External_ID__c = 'SOU';
            insert territory;
            
            SVMXC__Territory__c territory1 = new SVMXC__Territory__c();
            territory1.name = 'California';
            territory1.SVMXC__Optimizer_External_ID__c = 'CA';
            insert territory1;

            SVMXC__SVMX_Jobs__c objSVMXJob = new SVMXC__SVMX_Jobs__c();
            objSVMXJob.SVMXC__SVMX_Process__c = svmxprocess.id;
            objSVMXJob.SVMXC__Territory__c = territory.Id;
            objSVMXJob.SVMXC__OptiMax_Message__c = 'Running';
            objSVMXJob.SVMXC__Start_Time__c = system.now();
            objSVMXJob.SVMXC__Initiated_By__c = Userinfo.getUserId();
            objSVMXJob.SVMXC__Status__c = '100';
            objSVMXJob.SVMXC__Type__c = 'ECO';            
            
            
            SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
            team.Name = 'testTeam';
            insert team;
            
            SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
            technician.Name = 'John';
            technician.SVMXC__Service_Group__c  = team.Id;
            technician.SVMXC__Service_Territory__c = territory.Id;
            insert technician;
            
            SVMXC__Service_Group_Members__c technician1 = new SVMXC__Service_Group_Members__c();
            technician1.Name = 'Max';
            technician1.SVMXC__Service_Group__c  = team.Id;
            technician1.SVMXC__Service_Territory__c = territory.Id;
            insert technician1;

            //list<SVMXC__Service_Order__c> workOrders = new list<SVMXC__Service_Order__c>();
            
            /*SVMXC__Dependency_Management__c dependencyManagement = new SVMXC__Dependency_Management__c();
            dependencyManagement.SVMXC__Dependency_Group_Name__c = 'BDG-01';*/
            
            Datetime nowTime = Datetime.now();
            Datetime scheduleTime = nowTime.addHours(24);
            
            SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
            workOrder.SVMXC__Zip__c = '75001';
            workOrder.SVMXC__Order_Status__c='Open';
            //workOrder.SVMXC__Group_Member__c = Tech.id;
            workOrder.SVMXC__Scheduled_Date_Time__c = scheduleTime;
            workOrder.SVMXC__Dispatch_Process__c =  svmxprocess.id;
            workOrder.SVMXC__OptiMax_Error_Occurred__c = false;
            workOrder.SVMXC__Locked_By_DC__c = false;
            workOrder.SVMXC__Service_Duration__c = 3600;
            workOrder.SVMXC__OptiMax_Status__c ='';
            workOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CREATE_WO';
            workOrder.SVMXC__Primary_Territory__c=territory.Id;
            workOrder.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
            workOrder.SVMXC__Acknowledged_By_Technician_Date_Time__c=DateTime.now();
            workOrder.SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 10;
            //workOrders.add(workOrder);
            
            SVMXC__Service_Order__c woEco = new SVMXC__Service_Order__c();
            woEco.SVMXC__Zip__c = '75001';
            woEco.SVMXC__Order_Status__c='Open';
            woEco.SVMXC__Dispatch_Process__c =  svmxprocess1.id;
            woEco.SVMXC__OptiMax_Error_Occurred__c = false;
            woEco.SVMXC__Locked_By_DC__c = false;
            woEco.SVMXC__Service_Duration__c = 3600;
            woEco.SVMXC__OptiMax_Status__c ='';
            woEco.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CREATE_WO';
            woEco.SVMXC__Primary_Territory__c=territory1.Id;

            SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
            workOrder1.SVMXC__Zip__c = '75001';
            workOrder1.SVMXC__Order_Status__c='Open';
            //workOrder1.SVMXC__Group_Member__c = Tech.id;
            workOrder1.SVMXC__Scheduled_Date_Time__c = nowTime;
            workOrder1.SVMXC__Dispatch_Process__c =  svmxprocess.id;
            workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
            workOrder1.SVMXC__Locked_By_DC__c = true;
            workOrder1.SVMXC__Service_Duration__c = 3600;
            workOrder1.SVMXC__OptiMax_Status__c = '';
            workOrder1.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CREATE_WO';
            workOrder1.SVMXC__Primary_Territory__c=territory.Id;
            workOrder1.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
            workOrder1.SVMXC__Acknowledged_By_Technician_Date_Time__c=DateTime.now();
            workOrder1.SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 10;
            workOrder1.SVMXC__Dependency_Group__c = null;
            //workOrders.add(workOrder1);
            //insert workOrders;
            
        
            /*SVMXC__Service_Order__c workOrder2 = new SVMXC__Service_Order__c();
            workOrder2.SVMXC__Zip__c = '75001';
            workOrder2.SVMXC__Order_Status__c='Open';
            //workOrder1.SVMXC__Group_Member__c = Tech.id;
            workOrder2.SVMXC__Scheduled_Date_Time__c = nowTime;
            workOrder2.SVMXC__Dispatch_Process__c =  svmxprocess.id;
            workOrder2.SVMXC__OptiMax_Error_Occurred__c = false;
            workOrder2.SVMXC__Locked_By_DC__c = true;
            workOrder2.SVMXC__Service_Duration__c = 3600;
            workOrder2.SVMXC__OptiMax_Status__c = '';
            workOrder2.SVMXC__Scheduling_Change_Token__c = '';
            workOrder2.SVMXC__Primary_Territory__c=territory.Id;
            workOrder2.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
            workOrder2.SVMXC__Acknowledged_By_Technician_Date_Time__c=DateTime.now();
            workOrder2.SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 10;
            workOrder2.SVMXC__Dependency_Group__c = dependencyManagement.id;*/
            //workOrders.add(workOrder2);

            //Mock the webservice call.
            //Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
            //createOptimizationSettings('OptiMax,ServicePower', 'True');
            //WSCH_TriggerHandler.doQualifyWorkorder(workOrders);

            list<SVMXC__Service_Order__c> newWOs = new list<SVMXC__Service_Order__c>();
            list<SVMXC__Service_Order__c> oldWOs = new list<SVMXC__Service_Order__c>();
            list<SVMXC__Service_Order__c> ecoWOs = new list<SVMXC__Service_Order__c>();
            newWOs.add(workOrder1);
            //newWOs.add(workOrder2);
            oldWOs.add(workOrder);
            //oldWOs.add(woEco);
            ecoWOs.add(woEco);
            ecoWOs.add(workOrder1);
            WSCH_ECO_TriggerHandler.doQualifyWorkorderEco(ecoWOs);
            
                    
            WSCH_ECO_TriggerHandler.doQualifyWorkorderEco(newWOs);
            
            List<String> qualifiedWOIds = new List<String>();
            qualifiedWOIds.add(workOrder.Id);
            WSCH_ECO_TriggerHandler.updateWorkOrders(qualifiedWOIds, WSCH_ECO_Constants.STATUS_OPT_BATCH, 'CHANGE_CREATE_WO');
            
            WSCH_ECO_TriggerHandler.manageWorkOrders(qualifiedWOIds);
            
            //createOptimizationSettings('OptiMax,ServicePower', 'True');
            WSCH_ECO_TriggerHandler.identifyAPIAndOptimizeEco(newWOs, oldWOs);
            WSCH_ECO_TriggerHandler.isFixWO(workOrder1,workOrder);
            
            Map<Id,SVMXC__ServiceMax_Processes__c> mapSVMXProcess = new Map<Id,SVMXC__ServiceMax_Processes__c>();
            
            mapSVMXProcess.putAll([SELECT Id from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Dispatch Process' and SVMXC__Dispatch_Process_Status__c = 'Complete'
            and SVMXC__Dispatch_Method__c ='Real Time Optimization' order by SVMXC__Sequence__c]);
            
            WSCH_ECO_TriggerHandler.markChangeToken(workOrder1, workOrder, mapSVMXProcess);
            
            workOrder1.SVMXC__Order_Status__c='Canceled';
            WSCH_ECO_TriggerHandler.markChangeToken(workOrder1, workOrder, mapSVMXProcess);
            
            workOrder1.SVMXC__Order_Status__c='Open';
            workOrder1.SVMXC__Locked_By_DC__c = false;
            workOrder1.SVMXC__Zip__c = '75002';
            WSCH_ECO_TriggerHandler.markChangeToken(workOrder1, workOrder, mapSVMXProcess);
            
            workOrder1.SVMXC__Zip__c = '75001';
            workOrder.SVMXC__Skill_Set__c = '';
            workOrder1.SVMXC__Skill_Set__c = 'Skill Set';
            WSCH_ECO_TriggerHandler.markChangeToken(workOrder1, workOrder, mapSVMXProcess);
            
            workOrder1.SVMXC__Service_Duration__c = 3601;
            workOrder1.SVMXC__Skill_Set__c = '';
            WSCH_ECO_TriggerHandler.markChangeToken(workOrder1, workOrder, mapSVMXProcess);
            
            workOrder1.SVMXC__Preferred_Technician__c = technician.Id;
            workOrder.SVMXC__Preferred_Technician__c = technician1.Id;
            workOrder1.SVMXC__Service_Duration__c = 3600;
            WSCH_ECO_TriggerHandler.markChangeToken(workOrder1, workOrder, mapSVMXProcess);
            
            workOrder1.SVMXC__Preferred_Business_Hours__c = lstOfBusinessHours1.Id;
            workOrder.SVMXC__Preferred_Business_Hours__c  = null;
            workOrder.SVMXC__Preferred_Technician__c = technician.Id;
            WSCH_ECO_TriggerHandler.markChangeToken(workOrder1, workOrder, mapSVMXProcess);
            
            workOrder.SVMXC__Preferred_Business_Hours__c  = lstOfBusinessHours1.Id;
            workOrder1.SVMXC__Preferred_Start_Time__c = system.now().addDays(-2);
            workOrder.SVMXC__Preferred_Start_Time__c = null;
            WSCH_ECO_TriggerHandler.markChangeToken(workOrder1, workOrder, mapSVMXProcess);
            
            workOrder1.SVMXC__Preferred_Start_Time__c = null;
            workOrder1.SVMXC__Preferred_End_Time__c = system.now().addDays(5);
            workOrder.SVMXC__Preferred_End_Time__c = system.now().addDays(3);
            WSCH_ECO_TriggerHandler.markChangeToken(workOrder1, workOrder, mapSVMXProcess);
            
            workOrder.SVMXC__Preferred_End_Time__c = system.now().addDays(5);
            workOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_RESOURCE_PREFERENCE';
            WSCH_ECO_TriggerHandler.markChangeToken(workOrder1, workOrder, mapSVMXProcess);
            
            workOrder.SVMXC__Scheduling_Change_Token__c = '';
            workOrder.SVMXC__Locked_By_DC__c = true;
            WSCH_ECO_TriggerHandler.markChangeToken(workOrder1, workOrder, mapSVMXProcess);
            
            WSCH_ECO_TriggerHandler.isBookJobWO(workOrder1, mapSVMXProcess);
            //WSCH_ECO_TriggerHandler.isCustomFieldChange(workOrder1, workOrder, 'BookJob');
            WSCH_ECO_TriggerHandler.isAddressInfoChange(workOrder1, workOrder);
            WSCH_ECO_TriggerHandler.getBookJobFieldsFromSettings();
            //WSCH_ECO_TriggerHandler.getUpdateJobFieldsFromSettings();
            WSCH_ECO_TriggerHandler.getCustomFieldsFromSettings();
            WSCH_ECO_TriggerHandler.isAppointmentWO(workOrder1);
            WSCH_ECO_TriggerHandler.isForceScheduleBookedWO(workOrder);
            
            workOrder1.SVMXC__Order_Status__c='Open';
            WSCH_ECO_TriggerHandler.doQualifyCancelWorkorder(newWOs);
            
            WSCH_ECO_TriggerHandler.getQualifiedCancelWOIds(newWOs);
            WSCH_ECO_TriggerHandler.cancelWorkOrders(qualifiedWOIds);
            WSCH_ECO_TriggerHandler.getChangeToken(workOrder1.SVMXC__OptiMax_Status__c,workOrder.SVMXC__Scheduling_Change_Token__c,'CHANGE_JOB_FIXED');
            
            Map<String, Map<String, Object>> oldWOIdFieldValuesMap = new Map<String, Map<String, Object>>();
            Map<String, Object> oldWODetail = new Map<String, Object>();
            workOrder1.SVMXC__Scheduling_Change_Token__c = 'CHANGE_RESOURCE_PREFERENCE';
            oldWODetail.put('SVMXC__OptiMax_Status__c', workOrder1.SVMXC__OptiMax_Status__c);
            oldWODetail.put('SVMXC__Scheduling_Change_Token__c', workOrder1.SVMXC__Scheduling_Change_Token__c);
            oldWODetail.put('WOId', workOrder1);
            oldWOIdFieldValuesMap.put(String.valueOf(workOrder1.id), oldWODetail);
            
            //WSCH_ECO_TriggerHandler.getChangedWOList(newWOs, oldWOIdFieldValuesMap);
            
            Map<String,String> mapWoSchToken = new Map<String,String>();
            mapWoSchToken.put(workOrder1.name, 'CHANGE_CREATE_WO');
            WSCH_ECO_TriggerHandler.createOptTrans(mapWoSchToken);
            WSCH_ECO_TriggerHandler.getSmaxQSetting();
            //WSCH_ECO_TriggerHandler.updateWoOptStatus(workOrder1);
            //WSCH_ECO_TriggerHandler.isCustomFieldChangeSmaxQ(workOrder1, workOrder, 'CHANGE_SCHEDULING_STATUS');
            //WSCH_ECO_TriggerHandler.fetchSetJobFields();
            //WSCH_ECO_TriggerHandler.getEcoWOIds(newWOs);
            //Map<String,SVMXC__Service_Order__c> mapQualifiedWOs = WSCH_ECO_TriggerHandler.getEcoWOIds(newWOs);
            //WSCH_ECO_TriggerHandler.createSVMXJobs(mapQualifiedWOs);
            /*List<SVMXC__ServiceMax_Processes__c> lstSvmxprocess = new List<SVMXC__ServiceMax_Processes__c>();         
            lstSvmxprocess = [SELECT Id from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Dispatch Process' and SVMXC__Dispatch_Process_Status__c = 'Complete'
            and SVMXC__Dispatch_Method__c ='Real Time Optimization' order by SVMXC__Sequence__c];

            if(lstSvmxprocess.size() > 0){
                workOrder1.SVMXC__Dispatch_Process__c =  lstSvmxprocess.get(0).id;
                newWOs.add(workOrder1);
                WSCH_ECO_TriggerHandler.doQualifyWorkorderEco(newWOs);
            }*/
    }
    
    
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
       
        //adding OptiMax Process Module
        SVMXC__ServiceMax_Processes__c modProc_OMAX = new SVMXC__ServiceMax_Processes__c();
        modProc_OMAX.RecordTypeId = modTypeId;
        modProc_OMAX.SVMXC__ModuleID__c = 'OMAX';
        modProc_OMAX.SVMXC__Name__c = 'OptiMax';
        modProc_OMAX.SVMXC__IsStandard__c = true;
        modProc_OMAX.SVMXC__Description__c = 'TEST MODULE DESCRIPTION';
        modProc_OMAX.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(modProc_OMAX);
       
        //adding DCON004 Process SubModule///////////////////////////
        SVMXC__ServiceMax_Processes__c subModProc_DCON004 = new SVMXC__ServiceMax_Processes__c();
        subModProc_DCON004.RecordTypeId = subModTypeId;
        subModProc_DCON004.SVMXC__SubmoduleID__c = 'DCON004';
        subModProc_DCON004.SVMXC__Name__c = 'Manage OptiMax Settings';
        subModProc_DCON004.SVMXC__IsStandard__c = true;
        subModProc_DCON004.SVMXC__Module__c = modProc_OMAX.id;
        subModProc_DCON004.SVMXC__Description__c = 'TEST SUBMODULE DESCRIPTION';
        subModProc_DCON004.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(subModProc_DCON004);
       
        //adding DCON004 SET00777 Process Setting
        SVMXC__ServiceMax_Processes__c settingProc_DCON004_SET00777 = new SVMXC__ServiceMax_Processes__c();
        settingProc_DCON004_SET00777.RecordTypeId = setTypeId;
        settingProc_DCON004_SET00777.SVMXC__SettingID__c = 'SET00777';
        settingProc_DCON004_SET00777.SVMXC__Data_Type__c = 'Boolean';
        settingProc_DCON004_SET00777.SVMXC__Default_Value__c = 'True';
        settingProc_DCON004_SET00777.SVMXC__Setting_Type__c = 'Global';
        settingProc_DCON004_SET00777.SVMXC__Search_Order__c = 'Global';
        settingProc_DCON004_SET00777.SVMXC__Active__c = true;
        settingProc_DCON004_SET00777.SVMXC__IsStandard__c = false;
        settingProc_DCON004_SET00777.SVMXC__Values__c = 'TRUE~|~FALSE';
        settingProc_DCON004_SET00777.SVMXC__Submodule__c = subModProc_DCON004.id;
        settingProc_DCON004_SET00777.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
        settingProc_DCON004_SET00777.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(settingProc_DCON004_SET00777);
       
        //associating DCON004 SET00777 Setting Value to a Global profile defined above
        SVMXC__ServiceMax_Config_Data__c conf_DCON004_SET00777 = new SVMXC__ServiceMax_Config_Data__c();
        conf_DCON004_SET00777.RecordTypeId = setValTypeId;
        conf_DCON004_SET00777.SVMXC__Setting_Configuration_Profile__c = confProfile_GLOB001_GBL007.id;
        conf_DCON004_SET00777.SVMXC__Display_Value__c = 'True';
        conf_DCON004_SET00777.SVMXC__Internal_Value__c = 'True';
        conf_DCON004_SET00777.SVMXC__Setting_ID__c = settingProc_DCON004_SET00777.id;
        conf_DCON004_SET00777.SVMXC__Active__c = true; //
        conf_DCON004_SET00777.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(conf_DCON004_SET00777);      



        //'OMAX004','SET003'
       
        //adding DCON004 Process SubModule///////////////////////////
        SVMXC__ServiceMax_Processes__c subModProc_OMAX004 = new SVMXC__ServiceMax_Processes__c();
        subModProc_OMAX004.RecordTypeId = subModTypeId;
        subModProc_OMAX004.SVMXC__SubmoduleID__c = 'OMAX004';
        subModProc_OMAX004.SVMXC__Name__c = 'Manage OptiMax Settings';
        subModProc_OMAX004.SVMXC__IsStandard__c = true;
        subModProc_OMAX004.SVMXC__Module__c = modProc_OMAX.id;
        subModProc_OMAX004.SVMXC__Description__c = 'TEST SUBMODULE DESCRIPTION';
        subModProc_OMAX004.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(subModProc_OMAX004);
       
        //adding OMAX004 SET003 Process Setting
        SVMXC__ServiceMax_Processes__c settingProc_OMAX004_SET003 = new SVMXC__ServiceMax_Processes__c();
        settingProc_OMAX004_SET003.RecordTypeId = setTypeId;
        settingProc_OMAX004_SET003.SVMXC__SettingID__c = 'SET003';
        settingProc_OMAX004_SET003.SVMXC__Data_Type__c = 'Text';
        settingProc_OMAX004_SET003.SVMXC__Default_Value__c = 'SVMXC__Customer_Down__c,SVMXC__Is_SLA_Calculated__c';
        settingProc_OMAX004_SET003.SVMXC__Setting_Type__c = 'Global';
        settingProc_OMAX004_SET003.SVMXC__Search_Order__c = 'Global';
        settingProc_OMAX004_SET003.SVMXC__Active__c = true;
        settingProc_OMAX004_SET003.SVMXC__IsStandard__c = false;
        settingProc_OMAX004_SET003.SVMXC__Values__c = 'SVMXC__Customer_Down__c,SVMXC__Is_SLA_Calculated__c';
        settingProc_OMAX004_SET003.SVMXC__Submodule__c = subModProc_OMAX004.id;
        settingProc_OMAX004_SET003.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
        settingProc_OMAX004_SET003.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(settingProc_OMAX004_SET003);
       
        //associating DCON004 SET00777 Setting Value to a Global profile defined above
        SVMXC__ServiceMax_Config_Data__c conf_OMAX004_SET003 = new SVMXC__ServiceMax_Config_Data__c();
        conf_OMAX004_SET003.RecordTypeId = setValTypeId;
        conf_OMAX004_SET003.SVMXC__Setting_Configuration_Profile__c = confProfile_GLOB001_GBL007.id;
        conf_OMAX004_SET003.SVMXC__Display_Value__c = 'SVMXC__Customer_Down__c,SVMXC__Is_SLA_Calculated__c';
        conf_OMAX004_SET003.SVMXC__Internal_Value__c = 'SVMXC__Customer_Down__c,SVMXC__Is_SLA_Calculated__c';
        conf_OMAX004_SET003.SVMXC__Setting_ID__c = settingProc_OMAX004_SET003.id;
        conf_OMAX004_SET003.SVMXC__Active__c = true; //
        conf_OMAX004_SET003.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(conf_OMAX004_SET003);      

        //adding GLOB001 GBL010 Process Setting
        /*SVMXC__ServiceMax_Processes__c settingProc_GLOB001_GBL010 = new SVMXC__ServiceMax_Processes__c();
        settingProc_GLOB001_GBL010.RecordTypeId = setTypeId;
        settingProc_GLOB001_GBL010.SVMXC__SettingID__c = 'GBL010';
        settingProc_GLOB001_GBL010.SVMXC__Data_Type__c = 'Boolean';
        settingProc_GLOB001_GBL010.SVMXC__Default_Value__c = 'True';
        settingProc_GLOB001_GBL010.SVMXC__Setting_Type__c = 'Global';
        settingProc_GLOB001_GBL010.SVMXC__Search_Order__c = 'Global';
        settingProc_GLOB001_GBL010.SVMXC__Active__c = true;
        settingProc_GLOB001_GBL010.SVMXC__IsStandard__c = true;
        settingProc_GLOB001_GBL010.SVMXC__Values__c = 'TRUE~|~FALSE';
        settingProc_GLOB001_GBL010.SVMXC__Submodule__c = subModProc_GLOB001.id;
        settingProc_GLOB001_GBL010.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
        settingProc_GLOB001_GBL010.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(settingProc_GLOB001_GBL010);        
        
        //adding GLOB001 GBL010 Configuration Profile
        SVMXC__ServiceMax_Config_Data__c confProfile_GLOB001_GBL010 = new SVMXC__ServiceMax_Config_Data__c();
        confProfile_GLOB001_GBL010.SVMXC__Profile_Name__c = 'TestSvmxGLB';
        confProfile_GLOB001_GBL010.RecordTypeId = confProfileTypeId;
        confProfile_GLOB001_GBL010.SVMXC__Configuration_Type__c = 'Global';
        confProfile_GLOB001_GBL010.SVMXC__Active__c = true;
        confProfile_GLOB001_GBL010.SVMXC__IsDefault__c = true;
        confProfile_GLOB001_GBL010.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(confProfile_GLOB001_GBL010);
        
        //adding GLOB001 GBL010 Setting Value
        SVMXC__ServiceMax_Config_Data__c conf_GLOB001_GBL010 = new SVMXC__ServiceMax_Config_Data__c();
        conf_GLOB001_GBL010.RecordTypeId = setValTypeId;
        conf_GLOB001_GBL010.SVMXC__Setting_Configuration_Profile__c = confProfile_GLOB001_GBL010.id;
        conf_GLOB001_GBL010.SVMXC__Display_Value__c = 'https://optimax-dev.servicemax.com:7343/optimax/optimization';
        conf_GLOB001_GBL010.SVMXC__Internal_Value__c = 'https://optimax-dev.servicemax.com:7343/optimax/optimization';
        conf_GLOB001_GBL010.SVMXC__Setting_ID__c = settingProc_GLOB001_GBL010.id;
        conf_GLOB001_GBL010.SVMXC__Active__c = true; //
        conf_GLOB001_GBL010.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(conf_GLOB001_GBL010);*/


        /*//adding DCON004 Process SubModule///////////////////////////             
        //adding DCON004 SET009 Process Setting
        SVMXC__ServiceMax_Processes__c settingProc_DCON004_SET009 = new SVMXC__ServiceMax_Processes__c();
        settingProc_DCON004_SET009.RecordTypeId = setTypeId;
        settingProc_DCON004_SET009.SVMXC__SettingID__c = 'SET009';
        settingProc_DCON004_SET009.SVMXC__Data_Type__c = 'Boolean';
        settingProc_DCON004_SET009.SVMXC__Default_Value__c = 'True';
        settingProc_DCON004_SET009.SVMXC__Setting_Type__c = 'Global';
        settingProc_DCON004_SET009.SVMXC__Search_Order__c = 'Global';
        settingProc_DCON004_SET009.SVMXC__Active__c = true;
        settingProc_DCON004_SET009.SVMXC__IsStandard__c = false;
        settingProc_DCON004_SET009.SVMXC__Values__c = 'TRUE~|~FALSE';
        settingProc_DCON004_SET009.SVMXC__Submodule__c = subModProc_DCON004.id;
        settingProc_DCON004_SET009.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
        settingProc_DCON004_SET009.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(settingProc_DCON004_SET009);
       
        //associating DCON004 SET009 Setting Value to a Global profile defined above
        SVMXC__ServiceMax_Config_Data__c conf_DCON004_SET009 = new SVMXC__ServiceMax_Config_Data__c();
        conf_DCON004_SET009.RecordTypeId = setValTypeId;
        conf_DCON004_SET009.SVMXC__Setting_Configuration_Profile__c = confProfile_GLOB001_GBL007.id;
        conf_DCON004_SET009.SVMXC__Display_Value__c = 'True';
        conf_DCON004_SET009.SVMXC__Internal_Value__c = 'True';
        conf_DCON004_SET009.SVMXC__Setting_ID__c = settingProc_DCON004_SET009.id;
        conf_DCON004_SET009.SVMXC__Active__c = true; //
        conf_DCON004_SET009.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(conf_DCON004_SET009);   

        //adding DCON004 SET008 Process Setting
        SVMXC__ServiceMax_Processes__c settingProc_DCON004_SET008 = new SVMXC__ServiceMax_Processes__c();
        settingProc_DCON004_SET008.RecordTypeId = setTypeId;
        settingProc_DCON004_SET008.SVMXC__SettingID__c = 'SET008';
        settingProc_DCON004_SET008.SVMXC__Data_Type__c = 'Boolean';
        settingProc_DCON004_SET008.SVMXC__Default_Value__c = 'True';
        settingProc_DCON004_SET008.SVMXC__Setting_Type__c = 'Global';
        settingProc_DCON004_SET008.SVMXC__Search_Order__c = 'Global';
        settingProc_DCON004_SET008.SVMXC__Active__c = true;
        settingProc_DCON004_SET008.SVMXC__IsStandard__c = false;
        settingProc_DCON004_SET008.SVMXC__Values__c = 'TRUE~|~FALSE';
        settingProc_DCON004_SET008.SVMXC__Submodule__c = subModProc_DCON004.id;
        settingProc_DCON004_SET008.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
        settingProc_DCON004_SET008.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(settingProc_DCON004_SET008);
       
        //associating DCON004 SET009 Setting Value to a Global profile defined above
        SVMXC__ServiceMax_Config_Data__c conf_DCON004_SET008 = new SVMXC__ServiceMax_Config_Data__c();
        conf_DCON004_SET008.RecordTypeId = setValTypeId;
        conf_DCON004_SET008.SVMXC__Setting_Configuration_Profile__c = confProfile_GLOB001_GBL007.id;
        conf_DCON004_SET008.SVMXC__Display_Value__c = 'True';
        conf_DCON004_SET008.SVMXC__Internal_Value__c = 'True';
        conf_DCON004_SET008.SVMXC__Setting_ID__c = settingProc_DCON004_SET008.id;
        conf_DCON004_SET008.SVMXC__Active__c = true; //
        conf_DCON004_SET008.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(conf_DCON004_SET008); */        
    }
    
    static testMethod void testDependencyWOs() {
            Test.startTest();
            
            createOptimizationSettings();

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

            SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
            svmxprocess.SVMXC__Name__c = 'UT DispatchProcess';
            svmxprocess.RecordTypeId = DispatchProRecordTypeId;
            svmxprocess.SVMXC__Dispatch_Process_Status__c='Complete';
            svmxprocess.SVMXC__Dispatch_Method__c='Optimized Batch';
            insert svmxprocess;

            BusinessHours lstOfBusinessHours1;
            lstOfBusinessHours1 = [SELECT Id,IsActive,IsDefault,MondayStartTime,MondayEndTime,
                               TuesdayStartTime,TuesdayEndTime,WednesdayStartTime,WednesdayEndTime,
                               ThursdayStartTime,ThursdayEndTime,FridayStartTime,FridayEndTime,SaturdayStartTime,
                               SaturdayEndTime,SundayStartTime,SundayEndTime FROM BusinessHours
                               WHERE IsDefault = TRUE AND IsActive = TRUE Limit 1];

            SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
            oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
            oConf.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
            oConf.SVMXC__Display_Type__c = 'STRING';
            oConf.SVMXC__Operand__c='asdfgg';
            oConf.SVMXC__Operator__c='eq';
            oConf.RecordTypeId = ExpressionRTypeId;
            oConf.SVMXC__Sequence__c=1;
            oConf.SVMXC__Expression_Rule__c = svmxprocess.id;
            insert oConf;

            SVMXC__Territory__c territory = new SVMXC__Territory__c();
            territory.name = 'South Central Region';
            territory.SVMXC__Optimizer_External_ID__c = 'SOU';
            insert territory;
            
            SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
            team.Name = 'testTeam';
            insert team;
            
            SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
            technician.Name = 'John';
            technician.SVMXC__Service_Group__c  = team.Id;
            technician.SVMXC__Service_Territory__c = territory.Id;
            insert technician;
            
            SVMXC__Service_Group_Members__c technician1 = new SVMXC__Service_Group_Members__c();
            technician1.Name = 'Max';
            technician1.SVMXC__Service_Group__c  = team.Id;
            technician1.SVMXC__Service_Territory__c = territory.Id;
            insert technician1;

            //list<SVMXC__Service_Order__c> workOrders = new list<SVMXC__Service_Order__c>();
            
            SVMXC__Dependency_Management__c dependencyManagement = new SVMXC__Dependency_Management__c();
            dependencyManagement.SVMXC__Dependency_Group_Name__c = 'BDG-01';
            insert dependencyManagement;
            
            Datetime nowTime = Datetime.now();
            Datetime scheduleTime = nowTime.addHours(24);
            
            list<SVMXC__Service_Order__c> newWOs = new list<SVMXC__Service_Order__c>();
            list<SVMXC__Service_Order__c> oldWOs = new list<SVMXC__Service_Order__c>();
                        
            SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
            workOrder.SVMXC__Zip__c = '75001';
            workOrder.SVMXC__Order_Status__c='Open';
            //workOrder.SVMXC__Group_Member__c = Tech.id;
            workOrder.SVMXC__Scheduled_Date_Time__c = scheduleTime;
            workOrder.SVMXC__Dispatch_Process__c =  svmxprocess.id;
            workOrder.SVMXC__OptiMax_Error_Occurred__c = false;
            workOrder.SVMXC__Locked_By_DC__c = false;
            workOrder.SVMXC__Service_Duration__c = 3600;
            workOrder.SVMXC__OptiMax_Status__c ='';
            workOrder.SVMXC__Scheduling_Change_Token__c = '';
            workOrder.SVMXC__Primary_Territory__c=territory.Id;
            workOrder.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
            workOrder.SVMXC__Dependency_Group__c = dependencyManagement.Id;
            newWOs.add(workOrder);
            
            SVMXC__Service_Order__c workOrderN = new SVMXC__Service_Order__c();
            workOrderN.SVMXC__Zip__c = '75001';
            workOrderN.SVMXC__Order_Status__c='Open';
            //workOrder.SVMXC__Group_Member__c = Tech.id;
            workOrderN.SVMXC__Scheduled_Date_Time__c = scheduleTime;
            workOrderN.SVMXC__Dispatch_Process__c =  svmxprocess.id;
            workOrderN.SVMXC__OptiMax_Error_Occurred__c = false;
            workOrderN.SVMXC__Locked_By_DC__c = false;
            workOrderN.SVMXC__Service_Duration__c = 3600;
            workOrderN.SVMXC__OptiMax_Status__c ='';
            workOrderN.SVMXC__Scheduling_Change_Token__c = '';
            workOrderN.SVMXC__Primary_Territory__c=territory.Id;
            workOrderN.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
            workOrderN.SVMXC__Dependency_Group__c = dependencyManagement.Id;
            oldWOs.add(workOrderN);
                        
            SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
            workOrder1.SVMXC__Zip__c = '75001';
            workOrder1.SVMXC__Order_Status__c='Open';
            workOrder1.SVMXC__Scheduled_Date_Time__c = nowTime;
            workOrder1.SVMXC__Dispatch_Process__c =  svmxprocess.id;
            workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
            workOrder1.SVMXC__Locked_By_DC__c = true;
            workOrder1.SVMXC__Service_Duration__c = 3600;
            workOrder1.SVMXC__OptiMax_Status__c = '';
            workOrder1.SVMXC__Scheduling_Change_Token__c = '';
            workOrder1.SVMXC__Primary_Territory__c=territory.Id;
            workOrder1.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
            workOrder1.SVMXC__Acknowledged_By_Technician_Date_Time__c=DateTime.now();
            workOrder1.SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 10;
            workOrder1.SVMXC__Dependency_Group__c = null;
            newWOs.add(workOrder1);

            SVMXC__Service_Order__c workOrder2 = new SVMXC__Service_Order__c();
            workOrder2.SVMXC__Zip__c = '75001';
            workOrder2.SVMXC__Order_Status__c='Open';
            workOrder2.SVMXC__Scheduled_Date_Time__c = nowTime;
            workOrder2.SVMXC__Dispatch_Process__c =  svmxprocess.id;
            workOrder2.SVMXC__OptiMax_Error_Occurred__c = false;
            workOrder2.SVMXC__Locked_By_DC__c = true;
            workOrder2.SVMXC__Service_Duration__c = 3600;
            workOrder2.SVMXC__OptiMax_Status__c = '';
            workOrder2.SVMXC__Scheduling_Change_Token__c = '';
            workOrder2.SVMXC__Primary_Territory__c=territory.Id;
            workOrder2.SVMXC__Schedule_As_A_Dependent_Work_Order__c = false;
            workOrder2.SVMXC__Acknowledged_By_Technician_Date_Time__c=DateTime.now();
            workOrder2.SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 10;
            workOrder2.SVMXC__Dependency_Group__c = dependencyManagement.Id;
            oldWOs.add(workOrder2);
            //insert workOrders;

            WSCH_ECO_TriggerHandler.identifyAPIAndOptimizeEco(newWOs, oldWOs);
            String eachWODetail='WO Number:WO3938348';
            Map<String, Object> oldWODetail = new Map<String, Object>();
            oldWODetail.put('WOId', String.ValueOf('WO-398372'));
            Map<String, Map<String, Object>> oldWOIdFieldValuesMap = new Map<String, Map<String, Object>>();
            oldWOIdFieldValuesMap.put(String.valueOf(oldWODetail.get('WOId')),oldWODetail);
            
            WSCH_ECO_TriggerHandler.getChangedWOList(newWOs, oldWOIdFieldValuesMap);
            
            SVMXC__SVMX_Event__c svmxEv = new SVMXC__SVMX_Event__c();
            DateTime dt = DateTime.now();
            svmxEv.Name = 'EVMX_EV_UT';
            svmxEv.SVMXC__Technician__c =  technician1.Id;
            svmxEv.SVMXC__StartDateTime__c= dt;
            svmxEv.SVMXC__EndDateTime__c = dt.addMinutes(30);
            svmxEv.SVMXC__WhatId__c = workOrder1.Id;
            insert svmxEv;
            
            Event ev = new Event();
            ev.EventSubtype  = 'Event';
            ev.StartDateTime = system.today();
            ev.EndDateTime = system.today();
            ev.WhatId = workOrder2.Id;
            insert ev;
            
            List<String> listWOIds = new List<String>();
            listWOIds.add(workOrder1.id);
            listWOIds.add(workOrder2.id);
            WSCH_ECO_TriggerHandler.checkMultiSVMXEventsInWO(listWOIds); 
            WSCH_ECO_TriggerHandler.checkMultiSFEventsInWO(listWOIds);
            WSCH_ECO_TriggerHandler.lockedByDCTrueToFalse(oldWOs);
            WSCH_ECO_TriggerHandler.deleteOptRcrdsAndManageworkorderCallout(listWOIds,oldWOs);
    }
       
}