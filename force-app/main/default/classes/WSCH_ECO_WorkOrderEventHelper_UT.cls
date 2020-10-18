@isTest(seeAllData = false)
public with sharing class WSCH_ECO_WorkOrderEventHelper_UT {
    
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
    
    private static String getSVMXRuleRecordId(){
        String svmxRuleRecordType;
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' ];
        for(RecordType rt : rts)
        {
            if(rt.Name == 'SVMX Rule' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               svmxRuleRecordType = rt.ID;
        }
        return svmxRuleRecordType;
        
    }
    
    static testMethod void testECOWorkOrderEventHelper() {
        
        WSCH_ECO_WorkOrderEventHelper woEventHelper = new WSCH_ECO_WorkOrderEventHelper();
        
        WSCH_WorkOrderResponse woResponse = new WSCH_WorkOrderResponse();
        List<SVMXC__Service_Order__c> lstWorkOrder = new List<SVMXC__Service_Order__c>();
        
        list<BusinessHours> lBH = [ select WednesdayStartTime, timeZoneSidKey, WednesdayEndTime, TuesdayStartTime, 
        TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, 
        SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime
         from BusinessHours where IsActive = true limit 1];
        
        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.SVMXC__Active__c = true;
        territory.SVMXC__Territory_s_Business_Hours__c = lBH[0].Id;
        territory.SVMXC__Per_Mile_Cost__c = 1234;
        territory.SVMXC__Max_Distance__c = 2345;
        territory.SVMXC__Average_Speed__c = 4567;
        territory.SVMXC__Fixed_Cost__c = 4366;
        territory.SVMXC__Per_hour_Cost__c = 7373;
        insert territory;
        
        /*SVMXC__SVMX_Jobs__c svmxJob = new SVMXC__SVMX_Jobs__c();
        svmxJob.SVMXC__Territory__c = territory.Id;
        svmxJob.SVMXC__Type__c = 'ECO';
        insert svmxJob;*/
        
        Date dt1 = Date.today();
        dt1 = dt1.addDays(1);
        
        SVMXC__ServiceMax_Processes__c dprocessParent = new SVMXC__ServiceMax_Processes__c();
        dprocessParent.SVMXC__Dispatch_Method__c = 'OptimaxECO';
        dprocessParent.SVMXC__Dispatch_Process_Status__c ='Complete';
        dprocessParent.SVMXC__Dispatch_Timezone__c= 'Asia/Colombo';
        dprocessParent.SVMXC__Name__c = 'Process-UT';
        dprocessParent.RecordTypeId = getDispatchProcessRecordId();
        dprocessParent.SVMXC__End_Date__c = dt1;
        dprocessParent.SVMXC__Calendar_End_Days__c = 4;
        dprocessParent.SVMXC__Full_Run_Unit__c = 'DAYS';
        dprocessParent.SVMXC__Calendar_Start_Days__c = 2;
        dprocessParent.SVMXC__Frequency__c = 2;
        insert dprocessParent;
        
        SVMXC__ServiceMax_Processes__c dprocess = new SVMXC__ServiceMax_Processes__c();
        dprocess.SVMXC__Process__c = dprocessParent.Id;
        dprocess.SVMXC__Rule_Type__c = 'Territory Access';
        dprocess.SVMXC__Territory__c = territory.Id;
        dprocess.RecordTypeId = getSVMXRuleRecordId();
        insert dprocess;
        
        COMM_SecurityUtils.getInstance().isSecurityCheckEnabled = false;
        Profile Prof = [Select p.Id From Profile p where Name like 'System Administrator' limit 1][0];
        User objU;
        objU = new User(
            LastName = 'objULastName',
            Alias = 'obAlias',
            Email = 'objUAlias@example.com',
            Username = 'objUAliasUSRNM@example.com',
            CommunityNickname  = 'objUNick',
            IsActive = true,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = Prof.Id,
            LanguageLocaleKey = 'en_US',
            Department = 'Corporate Sales');
        insert objU;
        
        /*Profile Prof = [Select p.Id From Profile p where Name like 'System Administrator' limit 1][0];
        List<User> usrList = [SELECT ID, UserName, ProfileId FROM User WHERE ProfileId != :Prof.id AND isActive=true LIMIT 1];*/
        
        SVMXC__Service_Order__c workorder1 = new SVMXC__Service_Order__c(
                                        SVMXC__Order_Status__c = 'Open',
                                        SVMXC__Priority__c = 'Medium',
                                        SVMXC__Order_Type__c = 'Field Service',
                                        SVMXC__zip__c='560001',
                                        SVMXC__City__c='Bangalore',
                                        ownerID = objU.id,
                                        //ownerID = usrList[0].id,
                                        SVMXC__Clock_Paused_Forever__c= false,
                                        SVMXC__Customer_Down__c= false,
                                        SVMXC__IsPartnerRecord__c= false,
                                        SVMXC__Is_PM_Work_Order__c= false,
                                        SVMXC__Is_SLA_Calculated__c= false,
                                        SVMXC__OptiMax_Error_Occurred__c= false,
                                        SVMXC__PM_Tasks_Created__c= false,
                                        SVMXC__SLA_Clock_Paused__c= false,
                                        SVMXC__Apply_Business_Hours_For_OptiMax__c= false,
                                        SVMXC__Locked_By_DC__c= false,
                                        SVMXC__Perform_Auto_Entitlement__c= false,
                                        SVMXC__Invoice_Created__c= false,
                                        SVMXC__Is_Service_Covered__c= false,
                                        SVMXC__Is_Entitlement_Performed__c= false,
                                        SVMXC__Is_Exported__c= false,
                                        SVMXC__Drip__c= false,
                                        SVMXC__SM_Ok_To_Arrive_Early__c = false,
                                        SVMXC__Schedule_As_A_Dependent_Work_Order__c= false,
                                        SVMXC__Dispatch_Process__c = dprocessParent.Id,
                                        SVMXC__Primary_Territory__c = territory.Id,
                                        SVMXC__Service_Duration__c = 3600,
                                        SVMXC__Work_Order_Scheduling_Status__c = 'Tentative',
                                        SVMXC__OptiMax_Status__c = 'OPT_TENTATIVE',
                                        //SVMXC__In_Jeopardy__c = false,
                                        SVMXC__SM_In_Jeopardy__c=false
                                        //SVMXC__IsEcoWO__c = true
                                         );

        insert workorder1;
        lstWorkOrder.add(workOrder1);
        
        woResponse.getLstWorkOrder().addAll(lstWorkOrder);
    
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'team1';
        insert team;
        
        /*SVMXC__Service_Group_Members__c technician1 = new SVMXC__Service_Group_Members__c();
        technician1.Name = 'Tech1';
        technician1.SVMXC__Service_Group__c = team.Id;
        insert technician1;*/
        
        SVMXC__Service_Group__c objGroup = new SVMXC__Service_Group__c();
        objGroup.Name = 'TestGroup';
        objGroup.SVMXC__Active__c = true;
        objGroup.SVMXC__Select__c = true;
        insert objGroup;
        
        SVMXC__Service_Group_Members__c objTechnician = new SVMXC__Service_Group_Members__c();
        objTechnician.Name = 'TestTechnician';
        objTechnician.SVMXC__Service_Group__c = objGroup.id;
        objTechnician.SVMXC__Active__c = true;
        objTechnician.SVMXC__City__c = 'Bangalore';
        objTechnician.SVMXC__Service_Territory__c = territory.id;
        objTechnician.SVMXC__Working_Hours__c = lBH[0].id;
        insert objTechnician;
        
        Datetime dt = Datetime.now();
        
        SVMXC__SVMX_Event__c svmxEv = new SVMXC__SVMX_Event__c();
        svmxEv.Name = 'EVMX_EV_UT';
        svmxEv.SVMXC__Technician__c =  objTechnician.id;
        svmxEv.SVMXC__StartDateTime__c= system.today();
        svmxEv.SVMXC__EndDateTime__c = system.today() + 1;
        svmxEv.SVMXC__ActivityDateTime__c = dt;
        svmxEv.SVMXC__DurationInMinutes__c = (((dt +1).getTime()).intValue()/1000/60) - ((dt.getTime()).intValue()/1000/60);
        svmxEv.SVMXC__Service_Duration__c = 3600;
        svmxEv.SVMXC__Driving_Time__c = 60;      
        insert svmxEv;
        
        WSCH_TechnicianEvent techEvent = new WSCH_TechnicianEvent();
        
        
        /*private String technicianExternalID;
        private String dispatchStatus;
        private DateTime startDateTime;
        private DateTime arrivalDateTime;
        private DateTime finishDateTime;
        private String violationMessage;
        private Boolean isFixed;*/
        String workOrderID = workOrder1.Id;
        String technicianID = objTechnician.Id;
        String eventId = svmxEv.Id;
        
        techEvent.setWorkOrderID(workOrderID);
        techEvent.setTechnicianID(technicianID);
        techEvent.setEventId(eventId);
        techEvent.setDispatchStatus('TENTATIVE');
        techEvent.setStartDateTime(system.now().addDays(-3));
        techEvent.setArrivalDateTime(system.now());
        techEvent.setFinishDateTime(system.now().addDays(3));
        techEvent.setDriveDuration(Double.valueOf('12'));
        techEvent.setVisitDuration(Double.valueOf('12'));
        techEvent.setDblLatitude(Double.valueOf('12'));
        techEvent.setDblLongitude(Double.valueOf('12'));
        techEvent.setReturnHomeDrivingTime(Double.valueOf('12'));
        techEvent.setIdleDuration(Double.valueOf('12'));
        
        List<WSCH_TechnicianEvent> lstTechEvent = new List<WSCH_TechnicianEvent>();
        lstTechEvent.add(techEvent);
        woResponse.setLstTechEvent(lstTechEvent);
        woResponse.setIsDispatched(false);
        
        WSCH_ECO_WorkOrderEventHelper.processWorkOrderResponse(woResponse);
    }
    
    static testMethod void testECOWorkOrderEventHelper1() {
        
        WSCH_ECO_WorkOrderEventHelper woEventHelper = new WSCH_ECO_WorkOrderEventHelper();
        
        WSCH_WorkOrderResponse woResponse = new WSCH_WorkOrderResponse();
        List<SVMXC__Service_Order__c> lstWorkOrder = new List<SVMXC__Service_Order__c>();
        
        list<BusinessHours> lBH = [ select WednesdayStartTime, timeZoneSidKey, WednesdayEndTime, TuesdayStartTime, 
        TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, 
        SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime
         from BusinessHours where IsActive = true limit 1];
        
        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.SVMXC__Active__c = true;
        territory.SVMXC__Territory_s_Business_Hours__c = lBH[0].Id;
        territory.SVMXC__Per_Mile_Cost__c = 1234;
        territory.SVMXC__Max_Distance__c = 2345;
        territory.SVMXC__Average_Speed__c = 4567;
        territory.SVMXC__Fixed_Cost__c = 4366;
        territory.SVMXC__Per_hour_Cost__c = 7373;
        insert territory;
        
        /*SVMXC__SVMX_Jobs__c svmxJob = new SVMXC__SVMX_Jobs__c();
        svmxJob.SVMXC__Territory__c = territory.Id;
        svmxJob.SVMXC__Type__c = 'ECO';
        insert svmxJob;*/
        
        Date dt1 = Date.today();
        dt1 = dt1.addDays(1);
        
        SVMXC__ServiceMax_Processes__c dprocessParent = new SVMXC__ServiceMax_Processes__c();
        dprocessParent.SVMXC__Dispatch_Method__c = 'OptimaxECO';
        dprocessParent.SVMXC__Dispatch_Process_Status__c ='Complete';
        dprocessParent.SVMXC__Dispatch_Timezone__c= 'Asia/Colombo';
        dprocessParent.SVMXC__Name__c = 'Process-UT';
        dprocessParent.RecordTypeId = getDispatchProcessRecordId();
        dprocessParent.SVMXC__End_Date__c = dt1;
        dprocessParent.SVMXC__Calendar_End_Days__c = 4;
        dprocessParent.SVMXC__Full_Run_Unit__c = 'DAYS';
        dprocessParent.SVMXC__Calendar_Start_Days__c = 2;
        dprocessParent.SVMXC__Frequency__c = 2;
        insert dprocessParent;
        
        SVMXC__ServiceMax_Processes__c dprocess = new SVMXC__ServiceMax_Processes__c();
        dprocess.SVMXC__Process__c = dprocessParent.Id;
        dprocess.SVMXC__Rule_Type__c = 'Territory Access';
        dprocess.SVMXC__Territory__c = territory.Id;
        dprocess.RecordTypeId = getSVMXRuleRecordId();
        insert dprocess;
        
        COMM_SecurityUtils.getInstance().isSecurityCheckEnabled = false;
        Profile Prof = [Select p.Id From Profile p where Name like 'System Administrator' limit 1][0];
        User objU;
        objU = new User(
            LastName = 'objULastName',
            Alias = 'obAlias',
            Email = 'objUAlias@example.com',
            Username = 'objUAliasUSRNM@example.com',
            CommunityNickname  = 'objUNick',
            IsActive = true,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = Prof.Id,
            LanguageLocaleKey = 'en_US',
            Department = 'Corporate Sales');
        insert objU;
        
        /*Profile Prof = [Select p.Id From Profile p where Name like 'System Administrator' limit 1][0];
        List<User> usrList = [SELECT ID, UserName, ProfileId FROM User WHERE ProfileId != :Prof.id AND isActive=true LIMIT 1];*/
        
        SVMXC__Service_Order__c workorder1 = new SVMXC__Service_Order__c(
                                        SVMXC__Order_Status__c = 'Open',
                                        SVMXC__Priority__c = 'Medium',
                                        SVMXC__Order_Type__c = 'Field Service',
                                        SVMXC__zip__c='560001',
                                        SVMXC__City__c='Bangalore',
                                        ownerID = objU.id,
                                        //ownerID = usrList[0].id,
                                        SVMXC__Clock_Paused_Forever__c= false,
                                        SVMXC__Customer_Down__c= false,
                                        SVMXC__IsPartnerRecord__c= false,
                                        SVMXC__Is_PM_Work_Order__c= false,
                                        SVMXC__Is_SLA_Calculated__c= false,
                                        SVMXC__OptiMax_Error_Occurred__c= false,
                                        SVMXC__PM_Tasks_Created__c= false,
                                        SVMXC__SLA_Clock_Paused__c= false,
                                        SVMXC__Apply_Business_Hours_For_OptiMax__c= false,
                                        SVMXC__Locked_By_DC__c= false,
                                        SVMXC__Perform_Auto_Entitlement__c= false,
                                        SVMXC__Invoice_Created__c= false,
                                        SVMXC__Is_Service_Covered__c= false,
                                        SVMXC__Is_Entitlement_Performed__c= false,
                                        SVMXC__Is_Exported__c= false,
                                        SVMXC__Drip__c= false,
                                        SVMXC__SM_Ok_To_Arrive_Early__c = false,
                                        SVMXC__Schedule_As_A_Dependent_Work_Order__c= false,
                                        SVMXC__Dispatch_Process__c = dprocessParent.Id,
                                        SVMXC__Primary_Territory__c = territory.Id,
                                        SVMXC__Service_Duration__c = 3600,
                                        SVMXC__Work_Order_Scheduling_Status__c = 'Tentative',
                                        SVMXC__OptiMax_Status__c = 'OPT_TENTATIVE',
                                        SVMXC__Scheduling_Change_Token__c = 'CHANGE_JOB_FIXED',
                                        //SVMXC__In_Jeopardy__c=false,
                                        SVMXC__SM_In_Jeopardy__c=false
                                        //SVMXC__IsEcoWO__c = true
                                         );

        insert workorder1;
        lstWorkOrder.add(workOrder1);
        
        woResponse.getLstWorkOrder().addAll(lstWorkOrder);
    
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'team1';
        insert team;
        
        /*SVMXC__Service_Group_Members__c technician1 = new SVMXC__Service_Group_Members__c();
        technician1.Name = 'Tech1';
        technician1.SVMXC__Service_Group__c = team.Id;
        insert technician1;*/
        
        SVMXC__Service_Group__c objGroup = new SVMXC__Service_Group__c();
        objGroup.Name = 'TestGroup';
        objGroup.SVMXC__Active__c = true;
        objGroup.SVMXC__Select__c = true;
        insert objGroup;
        
        User user = [SELECT Id, Name FROM User WHERE Name LIKE '%Zubair%'];
        
        SVMXC__Service_Group_Members__c objTechnician = new SVMXC__Service_Group_Members__c();
        objTechnician.Name = 'TestTechnician';
        objTechnician.SVMXC__Salesforce_User__c = user.Id;
        objTechnician.SVMXC__Service_Group__c = objGroup.id;
        objTechnician.SVMXC__Active__c = true;
        objTechnician.SVMXC__City__c = 'Bangalore';
        objTechnician.SVMXC__Service_Territory__c = territory.id;
        objTechnician.SVMXC__Working_Hours__c = lBH[0].id;
        insert objTechnician;
        
        Datetime dt = Datetime.now();
        
        SVMXC__SVMX_Event__c svmxEv = new SVMXC__SVMX_Event__c();
        svmxEv.Name = 'EVMX_EV_UT';
        svmxEv.SVMXC__Technician__c =  objTechnician.id;
        svmxEv.SVMXC__StartDateTime__c= dt;
        svmxEv.SVMXC__EndDateTime__c = dt + 1;   
        svmxEv.SVMXC__ActivityDateTime__c = dt;
        svmxEv.SVMXC__DurationInMinutes__c = (((dt +1).getTime()).intValue()/1000/60) - ((dt.getTime()).intValue()/1000/60);
        svmxEv.SVMXC__Service_Duration__c = 3600;
        svmxEv.SVMXC__Driving_Time__c = 60;      
        insert svmxEv;
        
        WSCH_TechnicianEvent techEvent = new WSCH_TechnicianEvent();
        
        
        /*private String technicianExternalID;
        private String dispatchStatus;
        private DateTime startDateTime;
        private DateTime arrivalDateTime;
        private DateTime finishDateTime;
        private String violationMessage;
        private Boolean isFixed;*/
        String workOrderID = workOrder1.Id;
        String technicianID = objTechnician.Id;
        String eventId = svmxEv.Id;
        
        techEvent.setWorkOrderID(workOrderID);
        techEvent.setTechnicianID(technicianID);
        techEvent.setEventId(eventId);
        techEvent.setDispatchStatus('TENTATIVE');
        techEvent.setStartDateTime(system.now().addDays(-3));
        techEvent.setArrivalDateTime(system.now());
        techEvent.setFinishDateTime(system.now().addDays(3));
        techEvent.setDriveDuration(Double.valueOf('12'));
        techEvent.setVisitDuration(Double.valueOf('12'));
        techEvent.setDblLatitude(Double.valueOf('12'));
        techEvent.setDblLongitude(Double.valueOf('12'));
        techEvent.setReturnHomeDrivingTime(Double.valueOf('12'));
        techEvent.setIdleDuration(Double.valueOf('12'));
        
        List<WSCH_TechnicianEvent> lstTechEvent = new List<WSCH_TechnicianEvent>();
        lstTechEvent.add(techEvent);
        woResponse.setLstTechEvent(lstTechEvent);
        woResponse.setIsDispatched(false);
        
        WSCH_ECO_WorkOrderEventHelper.processWorkOrderResponse(woResponse);
    }
    
    static testMethod void testEventUpsert() {
        
        Map<String,WSCH_TechnicianEvent> eventIdAndTechEvents = new Map<String,WSCH_TechnicianEvent>();
        
        list<BusinessHours> lBH = [ select WednesdayStartTime, timeZoneSidKey, WednesdayEndTime, TuesdayStartTime, 
        TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, 
        SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime
         from BusinessHours where IsActive = true limit 1];
         
        User user = [SELECT Id, Name FROM User WHERE Name LIKE '%Zubair%'];
         
        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.SVMXC__Active__c = true;
        territory.SVMXC__Territory_s_Business_Hours__c = lBH[0].Id;
        territory.SVMXC__Per_Mile_Cost__c = 1234;
        territory.SVMXC__Max_Distance__c = 2345;
        territory.SVMXC__Average_Speed__c = 4567;
        territory.SVMXC__Fixed_Cost__c = 4366;
        territory.SVMXC__Per_hour_Cost__c = 7373;
        insert territory;
        
        SVMXC__Service_Group__c objGroup = new SVMXC__Service_Group__c();
        objGroup.Name = 'TestGroup';
        objGroup.SVMXC__Active__c = true;
        objGroup.SVMXC__Select__c = true;
        insert objGroup;
        
        SVMXC__Service_Group_Members__c objTechnician = new SVMXC__Service_Group_Members__c();
        objTechnician.Name = 'TestTechnician';
        objTechnician.SVMXC__Salesforce_User__c = user.Id;
        objTechnician.SVMXC__Service_Group__c = objGroup.id;
        objTechnician.SVMXC__Active__c = true;
        objTechnician.SVMXC__City__c = 'Bangalore';
        objTechnician.SVMXC__Service_Territory__c = territory.id;
        objTechnician.SVMXC__Working_Hours__c = lBH[0].id;
        insert objTechnician;
        
        Datetime dt = Datetime.now();
        
        WSCH_TechnicianEvent techEvent1 = new WSCH_TechnicianEvent();
        techEvent1.setStartDateTime(dt);
        techEvent1.setFinishDateTime(dt + 1);
        techEvent1.setDispatchStatus('TENTATIVE');
        techEvent1.setDriveDuration(Double.valueOf('12'));
        techEvent1.setVisitDuration(Double.valueOf('12'));
        techEvent1.setDblLatitude(Double.valueOf('12'));
        techEvent1.setDblLongitude(Double.valueOf('12'));
        techEvent1.setReturnHomeDrivingTime(Double.valueOf('12'));
        techEvent1.setIdleDuration(Double.valueOf('12'));
        
        SVMXC__SVMX_Event__c svmxEv = new SVMXC__SVMX_Event__c();
        svmxEv.Name = 'EVMX_EV_UT';
        svmxEv.SVMXC__Technician__c =  objTechnician.id;
        svmxEv.SVMXC__StartDateTime__c= dt;
        svmxEv.SVMXC__EndDateTime__c = dt + 1;
        svmxEv.SVMXC__ActivityDateTime__c = dt;
        svmxEv.SVMXC__DurationInMinutes__c = WSCH_DateUtils.getDurationInMinutes(techEvent1.getStartDateTime(), techEvent1.getFinishDateTime());
        svmxEv.SVMXC__Service_Duration__c = 3600;
        svmxEv.SVMXC__Driving_Time__c = 60;     
        insert svmxEv;
        
        eventIdAndTechEvents.put(svmxEv.Id, techEvent1);
        
        Event event1 = new Event();
        event1.StartDateTime= dt;
        event1.EndDateTime = dt + 1;       
        event1.Subject = 'Event1';
        event1.ActivityDateTime = dt;
        
        event1.DurationInMinutes = WSCH_DateUtils.getDurationInMinutes(techEvent1.getStartDateTime(), techEvent1.getFinishDateTime());
        event1.SVMXC__Driving_Time__c=60;
        event1.SVMXC__Service_Duration__c = 3600;
        insert event1;
        
        WSCH_TechnicianEvent techEvent2 = new WSCH_TechnicianEvent();
        techEvent2.setStartDateTime(dt);
        techEvent2.setFinishDateTime(dt + 1);
        techEvent2.setDispatchStatus('TENTATIVE');
        techEvent2.setDriveDuration(Double.valueOf('12'));
        techEvent2.setVisitDuration(Double.valueOf('12'));
        techEvent2.setDblLatitude(Double.valueOf('12'));
        techEvent2.setDblLongitude(Double.valueOf('12'));
        techEvent2.setReturnHomeDrivingTime(Double.valueOf('12'));
        techEvent2.setIdleDuration(Double.valueOf('12'));
        
        eventIdAndTechEvents.put(event1.Id, techEvent2);
        
        List<Event> sfEventsToUpsert = new List<Event>();
        List<SVMXC__SVMX_Event__c> svmxEventsToUpsert = new List<SVMXC__SVMX_Event__c>();
        
        WSCH_ECO_WorkOrderEventHelper.updateSFAndSVMXEventsToUpsert(eventIdAndTechEvents, sfEventsToUpsert, svmxEventsToUpsert);
        
        List<SVMXC__SVMX_Optimizer__c> lstOptTrans = new List<SVMXC__SVMX_Optimizer__c>();
        SVMXC__SVMX_Optimizer__c objSVMX_Optimizer = new SVMXC__SVMX_Optimizer__c();
        objSVMX_Optimizer.SVMXC__WhatType__c = 'TECHNICIAN';
        insert objSVMX_Optimizer;
        
        lstOptTrans.add(objSVMX_Optimizer);
        
        WSCH_ECO_WorkOrderEventHelper.updateTechnicianOptimizer(lstOptTrans);
    }
}