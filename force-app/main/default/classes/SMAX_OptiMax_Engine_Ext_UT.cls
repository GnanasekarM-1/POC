@isTest(SeeAllData= true)
private class SMAX_OptiMax_Engine_Ext_UT{
    static String dispatchprocessId;
    static String territoryId;
    static String jobId;
    
    static testmethod void SMAX_OptiMax_Engine_Ext()
    {
        // System Assert
             Account testAccount = new Account(name='Test Company Name');
             insert testAccount;
             testAccount.billingcountry='United States';
             testAccount.billingState='California';
             update testAccount;
             // Verify that the billingState field was updated in the database.
             Account updatedAccount = [SELECT billingState FROM Account WHERE Id = :testAccount.Id];
             System.assertEquals('California', updatedAccount.billingState);        
        RecordType RType = [select Id from RecordType where Name=:'Technician'];
        
        Profile Prof = [Select p.Id From Profile p where Name like 'System Administrator' limit 1][0];
        User objU;
        objU = new User(
            LastName = 'objULastName1',
            Alias = 'obAlias1',
            Email = 'objUAlias1@example.com',
            Username = 'objUAliasUSRNM1@example.com',
            CommunityNickname  = 'objUNick1',
            IsActive = true,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = Prof.Id,
            LanguageLocaleKey = 'en_US',
            Department = 'Corporate Sales');
        insert objU;
        
        SVMXC__Service_Group__c Team = new SVMXC__Service_Group__c();
        Team.RecordTypeId = RType.Id;
        Team.Name = 'OS Installation';
        Team.Street__c = '2629 firma lane';
        Team.City__c='east meadow';
        Team.State__c='ny';
        Team.Zip__c='11554';
        Team.Country__c='United States';
        Team.SVMXC__Group_Type__c ='Internal';
        Team.SVMXC__Active__c=true;
        insert Team;
        system.assert(Team.Name!=null);
        system.assert(Team.Street__c!=null);
        
        SVMXC__Territory__c Trtry = new SVMXC__Territory__c();
        Trtry.Name = 'Test Territory';
        insert Trtry;
        system.assert(Trtry.Name!=null);
        
        //BusinessHours objDefTerritoryBH = [select id, TimeZoneSidKey from BusinessHours limit 1];
        BusinessHours objDefTerritoryBH = [select TimeZoneSidKey, WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];
        
        SVMXC__Service_Group_Members__c Techncn = new SVMXC__Service_Group_Members__c();
        Techncn.SVMXC__Service_Group__c=Team.Id;
        Techncn.SVMXC__Working_Hours__c = objDefTerritoryBH.id;
        Techncn.SVMXC__Break_Hours__c = objDefTerritoryBH.id;
        Techncn.SVMXC__Role__c = 'Consultant';
        Techncn.SVMXC__Active__c =true;
        Techncn.Street__c = '2629 firma lane';
        Techncn.City__c='east meadow';
        Techncn.State__c='ny';
        Techncn.Zip__c='11554';
        Techncn.Country__c='United States';
        Techncn.SVMXC__Enable_Scheduling__c=true;
        Techncn.SVMXC__Service_Territory__c=Trtry.Id;
        Techncn.SVMXC__Salesforce_User__c = [SELECT id FROM USER Where IsActive = true limit 1].id;
        insert Techncn;
        system.assert(Techncn.City__c!=null);
        system.assert(Techncn.Street__c!=null);
        
        Product2 prod = new Product2(Name = 'TP');
        insert prod;
        System.assert(prod.Name == 'TP');
        
        SVMXC__ServiceMax_Processes__c pro = new SVMXC__ServiceMax_Processes__c();
        pro.SVMXC__Active__c = true;
        pro.SVMXC__Name__c = 'TestProcess';
        pro.SVMXC__Select__c = true;
        pro.RecordTypeId = [select id from RecordType where Name = 'SVMX Rule'].Id;
        insert pro;
        System.assert(pro.id != null);
        
        SVMXC__Skill__c objSkill = new SVMXC__Skill__c();
        objSkill.SVMXC__Active__c = true;
        objSkill.SVMXC__Select__c = true;
        insert objSkill;
        System.assert(objSkill.id != null);
        
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c();
        objWorkOrder.SVMXC__OptiMax_Status__c = 'xyz';
        objWorkOrder.SVMXC__Product__c = prod.id;
        objWorkOrder.SVMXC__Skill__c = objSkill.id;
        objWorkOrder.SVMXC__Preferred_Technician__c = Techncn.id;
        objWorkOrder.SVMXC__Dispatch_Process__c = pro.id;
        objWorkOrder.SVMXC__Service_Duration__c = 11;
        objWorkOrder.SVMXC__Dispatch_Priority__c = 1;
        objWorkOrder.SVMXC__Preferred_Resource_Priority__c = 1;
        objWorkOrder.SVMXC__Street__c = 'asdf';
        objWorkOrder.SVMXC__City__c = 'qwer';
        objWorkOrder.SVMXC__State__c = 'zxxcc';
        objWorkOrder.SVMXC__Zip__c = '12415632';
        objWorkOrder.SVMXC__Country__c = 'xyz';
        objWorkOrder.SVMXC__Latitude__c = 22;
        objWorkOrder.SVMXC__Longitude__c = 55;
        objWorkOrder.SVMXC__Qualified_Technicians__c = 'gfkdjdh';
        
        SVMXC__Service_Order__c objWorkOrder1 = new SVMXC__Service_Order__c();
        objWorkOrder1.SVMXC__OptiMax_Status__c = 'xyz';
        objWorkOrder1.SVMXC__Product__c = prod.id;
        objWorkOrder1.SVMXC__Skill__c = objSkill.id;
        objWorkOrder1.SVMXC__Preferred_Technician__c = Techncn.id;
        objWorkOrder1.SVMXC__Service_Duration__c = 11;
        objWorkOrder1.SVMXC__Dispatch_Priority__c = 1;
        objWorkOrder1.SVMXC__Preferred_Resource_Priority__c = 1;
        objWorkOrder1.SVMXC__Street__c = 'asdf';
        objWorkOrder1.SVMXC__City__c = 'qwer';
        objWorkOrder1.SVMXC__State__c = 'zxxcc';
        objWorkOrder1.SVMXC__Zip__c = '12415632';
        objWorkOrder1.SVMXC__Country__c = 'xyz';
        objWorkOrder1.SVMXC__Latitude__c = 22;
        objWorkOrder1.SVMXC__Longitude__c = 55;
        objWorkOrder1.SVMXC__Qualified_Technicians__c = 'gfkdjdh';
        List<SVMXC__Service_Order__c> lstServiceOrder = new List<SVMXC__Service_Order__c>();
        lstServiceOrder.add(objWorkOrder);
        lstServiceOrder.add(objWorkOrder1);
        insert lstServiceOrder;
        System.assert(lstServiceOrder.size() == 2);
        
        SMAX_OptiMax_Engine_Ext OptimaxEngine = new SMAX_OptiMax_Engine_Ext();
        SMAX_OptiMax_Engine_Ext.setOrganizationParameters('', '');
        SMAX_OptiMax_Engine_Ext.capacityResult obj1 = new SMAX_OptiMax_Engine_Ext.capacityResult();
        obj1.lstWOsForOptiMax = lstServiceOrder;
        
        List<BusinessHours> bh_L = [ select TimeZoneSidKey, WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];
        Datetime startDateTime = dateTime.now();
        
        set<Date> availableDates_S = new set<Date>();
        availableDates_S.add(Date.today());
        availableDates_S.add((Date.today()).addDays(1));
        availableDates_S.add((Date.today()).addDays(-1));
        
        OptimaxEngine.generateBusinessHourDetails(bh_L, startDateTime, availableDates_S);
        OptimaxEngine.computeIdleTime((DateTime.now()).addDays(-1), (DateTime.now()).addDays(1), Double.valueOf(1.0));
        
        Map<datetime, SMAX_OptiMax_Engine_WS.DblLocation_WP> mapDateLoc = new Map<datetime, SMAX_OptiMax_Engine_WS.DblLocation_WP>();
        mapDateLoc.put(dateTime.now(), new SMAX_OptiMax_Engine_WS.DblLocation_WP('34','45'));
        Map<id, Map<datetime, SMAX_OptiMax_Engine_WS.DblLocation_WP>> mapTechLatitudeLongitude = new Map<id, Map<datetime, SMAX_OptiMax_Engine_WS.DblLocation_WP>>();
        mapTechLatitudeLongitude.put(Techncn.Id, mapDateLoc);
        OptimaxEngine.mapTechLatitudeLongitude = mapTechLatitudeLongitude;
        OptimaxEngine.getLocation_WP(Techncn.Id, (DateTime.now()).addHours(1), (DateTime.now()), 13.0, 77.0);
        OptimaxEngine.getLocation_WP(Techncn.Id, (DateTime.now()).addHours(1), (DateTime.now().addDays(2)), 13.0, 77.0);
        OptimaxEngine.getLocation_WP(Techncn.Id, (DateTime.now()).addHours(1), (DateTime.now().addDays(-2)), 13.0, 77.0);
        
        List<BusinessHours> lstBusHour = new List<BusinessHours>();
        BusinessHours objBusiness  = new BusinessHours();
        objBusiness.MondayStartTime = Time.newInstance(23, 59, 0, 00);
        objBusiness.MondayEndTime = Time.newInstance(23, 59, 0, 00);
        objBusiness.TuesdayStartTime = Time.newInstance(23, 59, 0, 00);
        objBusiness.TuesdayEndTime = Time.newInstance(23, 59, 0, 00);
        objBusiness.WednesdayStartTime = Time.newInstance(23, 59, 0, 00);
        objBusiness.WednesdayEndTime = Time.newInstance(23, 59, 0, 00);
        objBusiness.ThursdayStartTime = Time.newInstance(23, 59, 0, 00);
        objBusiness.ThursdayEndTime = Time.newInstance(23, 59, 0, 00);
        objBusiness.FridayStartTime = Time.newInstance(23, 59, 0, 00);
        objBusiness.FridayEndTime = Time.newInstance(23, 59, 0, 00);
        objBusiness.SaturdayStartTime = Time.newInstance(23, 59, 0, 00);
        objBusiness.SaturdayEndTime = Time.newInstance(23, 59, 0, 00);
        objBusiness.SundayStartTime = Time.newInstance(23, 59, 0, 00);
        objBusiness.SundayEndTime = Time.newInstance(23, 59, 0, 00);
        objBusiness.TimeZoneSidKey = 'America/Los_Angeles';
        lstBusHour.add(objBusiness);
        OptimaxEngine.getCompleteBusinessHour(lstBusHour);
        
        SMAX_OptiMax_Engine_WS.ExecutionTime_WP objExeTimeWP = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(DateTime.newInstance(2008, 12, 1, 12, 30, 2),DateTime.newInstance(2008, 12, 1, 12, 45, 2));
        //SMAX_OptiMax_Engine_Ext.updateExecutionTime(objExeTimeWP, DateTime.newInstance(2008, 12, 1, 12, 30, 2), DateTime.newInstance(2008, 12, 1, 12, 30, 22));
        //SMAX_OptiMax_Engine_Ext.updateExecutionTime(objExeTimeWP, DateTime.newInstance(2008, 12, 1, 12, 20, 2), DateTime.newInstance(2008, 12, 1, 12, 40, 2));
        //SMAX_OptiMax_Engine_Ext.updateExecutionTime(objExeTimeWP, DateTime.newInstance(2008, 12, 1, 12, 20, 2), DateTime.newInstance(2008, 12, 2, 12, 50, 2));
        
        list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstExecutionTime = new list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
        lstExecutionTime.add(objExeTimeWP);
        
        Map<date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> mapDateExe = new Map<date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>();
        mapDateExe.put(Date.today(), lstExecutionTime);
        Map<id, Map<date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>> mapIdExecution = new Map<id, Map<date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>>();
        mapIdExecution.put(Techncn.Id, mapDateExe);
        OptimaxEngine.getAvailablity(mapIdExecution);
        
        List<SMAX_OptiMax_Engine_WS.WorkOrder_WP> lstWorkOrder = new List<SMAX_OptiMax_Engine_WS.WorkOrder_WP>();
        SMAX_OptiMax_Engine_WS.opInitateJobs_WP outputResult = new SMAX_OptiMax_Engine_WS.opInitateJobs_WP();
        String workOrderType = 'NEW';  //'NEW' OR 'ASSIGNED'
        lstWorkOrder.add(new SMAX_OptiMax_Engine_WS.WorkOrder_WP(new SVMXC__Service_Order__c(), lstExecutionTime, workOrderType,null));
        outputResult.workOrder_LWP = lstWorkOrder;
        OptimaxEngine.logInitiateJob(outputResult);
        //OptimaxEngine.updateExecutionTime(lstExecutionTime, lstExecutionTime);
        
        BusinessHours objBusiness1  = new BusinessHours();
        objBusiness1.TimeZoneSidKey = 'Asia/Calcutta';
        BusinessHours objBusiness2  = new BusinessHours();
        objBusiness2.TimeZoneSidKey = 'America/Los_Angeles';
        list<BusinessHours> lstBusinessHours = new list<BusinessHours>();
        lstBusinessHours = [Select Id, Name, IsDefault, IsActive, TimeZoneSidKey, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
                            ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime
                            from BusinessHours limit 9];        
        
        set<Date> availableDates_S1 = new set<Date>();
        availableDates_S1.add(Date.today());
        availableDates_S1.add((Date.today()).addDays(1));
        availableDates_S1.add((Date.today()).addDays(-1));
        OptimaxEngine.techAvailabilityWindow(mapIdExecution, Techncn.Id, lstBusinessHours[0], lstBusinessHours[0], lstExecutionTime, availableDates_S1, null);
        
        List<SVMXC__Service_Group_Members__c> lstOfTechnicians = new List<SVMXC__Service_Group_Members__c>();
        lstOfTechnicians.add(Techncn);
        Map<String, BusinessHours> mapOfBusinessHours = new Map<String, BusinessHours>();
        mapOfBusinessHours.put(lstBusinessHours[0].id, lstBusinessHours[0]);
        mapOfBusinessHours.put(objDefTerritoryBH.id, objDefTerritoryBH);
        
        OptimaxEngine.getTechniciansBreakHoursWindow(lstOfTechnicians, mapOfBusinessHours, availableDates_S1);
        
        SMAX_OptiMax_Engine_WS.ExecutionTime_WP objExeTimeWP1 = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(DateTime.newInstance(2008, 12, 1, 12, 30, 2),DateTime.newInstance(2008, 12, 1, 12, 45, 2));
        SMAX_OptiMax_Engine_WS.ExecutionTime_WP objExeTimeWP2 = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(DateTime.newInstance(2008, 12, 1, 12, 30, 2),DateTime.newInstance(2008, 12, 1, 12, 45, 2));
        List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstInputTimeWindows = new List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
        lstInputTimeWindows.add(objExeTimeWP1);
        lstInputTimeWindows.add(objExeTimeWP2);
        OptimaxEngine.sortExecutionTime(lstInputTimeWindows);

        SVMXC__SVMX_Event__c objEvent = new SVMXC__SVMX_Event__c();
        DateTime dt = DateTime.now();
        objEvent.SVMXC__ActivityDate__c = Date.Today();
        objEvent.SVMXC__ActivityDateTime__c = dt;
        objEvent.SVMXC__StartDateTime__c = dt;
        objEvent.SVMXC__DurationInMinutes__c = 30;
        objEvent.SVMXC__EndDateTime__c = dt.addMinutes(30);
        objEvent.SVMXC__Technician__c = Techncn.id;
        objEvent.Name = 'TestEvent';
        objEvent.SVMXC__Description__c = 'abc';
        objEvent.SVMXC__WhatId__c = String.valueOf(objWorkOrder.id);
        objEvent.SVMXC__Location__c = 'asdf';
        
        SVMXC__SVMX_Event__c objEvent1 = new SVMXC__SVMX_Event__c();
        DateTime dt1 = DateTime.now();
        objEvent1.SVMXC__ActivityDate__c = Date.Today();
        objEvent1.SVMXC__ActivityDateTime__c = dt1;
        objEvent1.SVMXC__StartDateTime__c = dt1;
        objEvent1.SVMXC__DurationInMinutes__c = 20;
        objEvent1.SVMXC__EndDateTime__c = dt1.addMinutes(20);
        objEvent1.SVMXC__Technician__c = Techncn.id;
        objEvent1.Name = 'TestEvent';
        objEvent1.SVMXC__Description__c = 'abc';
        objEvent1.SVMXC__WhatId__c = String.valueOf(objWorkOrder1.id);
        objEvent1.SVMXC__Location__c = 'asdf';
        
        SVMXC__SVMX_Event__c objEvent2 = new SVMXC__SVMX_Event__c();
        DateTime dt2 = DateTime.now();
        objEvent2.SVMXC__ActivityDate__c = Date.Today();
        objEvent2.SVMXC__ActivityDateTime__c = dt2;
        objEvent2.SVMXC__StartDateTime__c = dt2;
        objEvent2.SVMXC__DurationInMinutes__c = 20;
        objEvent2.SVMXC__EndDateTime__c = dt2.addMinutes(20);
        objEvent2.SVMXC__Technician__c = Techncn.id;
        objEvent2.SVMXC__WhatId__c = String.valueOf(objWorkOrder1.id);
        objEvent2.Name = 'TestEvent';
        objEvent2.SVMXC__Description__c = 'abc';
        objEvent2.SVMXC__Location__c = 'asdf,kjlj';
        
         SVMXC__SVMX_Event__c objEvent3 = new SVMXC__SVMX_Event__c();
        DateTime dt3 = DateTime.now();
        objEvent3.SVMXC__ActivityDate__c = Date.Today();
        objEvent3.SVMXC__ActivityDateTime__c = dt3;
        objEvent3.SVMXC__StartDateTime__c = dt3;
        objEvent3.SVMXC__DurationInMinutes__c = 20;
        objEvent3.SVMXC__EndDateTime__c = dt3.addMinutes(20);
        objEvent3.SVMXC__Technician__c = Techncn.id;
        objEvent3.Name = 'TestEvent';
        objEvent3.SVMXC__Description__c = 'abc';
        objEvent3.SVMXC__Location__c = 'asdf,kjlj';
        objEvent3.SVMXC__SM_Status__c = 'Confirmed';
        
        List<SVMXC__SVMX_Event__c> lstSVMXEvent = new List<SVMXC__SVMX_Event__c>();
        lstSVMXEvent.add(objEvent);
        lstSVMXEvent.add(objEvent1);
        lstSVMXEvent.add(objEvent2);
        insert lstSVMXEvent;
        System.assert(lstSVMXEvent.size() == 3);
        
        Event objEve = new Event();
        objEve.ActivityDate = Date.Today();
        DateTime dt7 = DateTime.now();
        objEve.ActivityDateTime = dt7;
        objEve.startDateTime = dt7;
        objEve.endDateTime = dt7.addMinutes(60);
        //objEve.DurationInMinutes = 60;
        objEve.Subject = 'Call';
        objEve.Description = 'avsdf';
        objEve.Location = 'sdafd';
        objEve.WhatId = objWorkOrder.id;
        objEve.IsAllDayEvent = true;
        //objEve.OwnerId = [SELECT id FROM USER Where IsActive = true limit 1].id;
        objEve.OwnerId = objU.Id;
        objEve.IsRecurrence = false;

        Event objEve1 = new Event();
        objEve1.ActivityDate = Date.Today();
        DateTime dt4 = DateTime.now();
        objEve1.ActivityDateTime = dt4;
        objEve1.startDateTime = dt4;
        //objEve1.DurationInMinutes = 50;
        objEve1.Subject = 'Call';
        objEve1.Description = 'avsdf';
        objEve1.Location = 'sdafd';
        objEve1.WhatId = objWorkOrder1.id;
        objEve1.endDateTime = dt4.addMinutes(50);
        objEve1.IsAllDayEvent = true;
        //objEve1.OwnerId = [SELECT id FROM USER Where IsActive = true limit 1].id;
        objEve1.OwnerId = objU.Id;
        objEve1.IsRecurrence = false;
        
        Event objEve2 = new Event();
        objEve2.ActivityDate = Date.Today();
        DateTime dt5 = DateTime.now();
        objEve2.ActivityDateTime = dt5;
        objEve2.startDateTime = dt5;
        //objEve2.DurationInMinutes = 55;
        objEve2.Subject = 'Call';
        objEve2.Description = 'avsdf';
        objEve2.Location = 'sdafd,asdf';
        objEve2.endDateTime = dt5.addMinutes(55);
        objEve2.WhatId = objWorkOrder1.id;
        objEve2.IsAllDayEvent = true;
        //objEve2.OwnerId = [SELECT id FROM USER Where IsActive = true limit 1].id;
        objEve2.OwnerId = objU.Id;
        objEve2.IsRecurrence = false;
        
         Event objEve3 = new Event();
        objEve3.ActivityDate = Date.Today();
        DateTime dt6 = DateTime.now();
        objEve3.ActivityDateTime = dt6;
        objEve3.startDateTime = dt6;
        //objEve3.DurationInMinutes = 55;
        objEve3.Subject = 'Call';
        objEve3.Description = 'avsdf';
        objEve3.Location = 'sdafd,asdf';
        objEve3.endDateTime = dt6.addMinutes(55);
        //objEve3.OwnerId = [SELECT id FROM USER Where IsActive = true limit 1].id;
        objEve3.IsRecurrence = false;
        objEve3.IsAllDayEvent = true;
        objEve3.SVMXC__SM_Status__c = 'Confirmed';
        
        List<Event> lstEvent = new List<Event>();
        lstEvent.add(objEve);
        lstEvent.add(objEve1);
        lstEvent.add(objEve2);
        insert lstEvent;
        //System.assert(lstEvent.size() == 3);
        
        Integer intNoOfDays = 3;
        List<SVMXC__Service_Order__c> lstNewWorkOrders = new List<SVMXC__Service_Order__c>();
        lstNewWorkOrders.add(objWorkOrder);
        lstNewWorkOrders.add(objWorkOrder1);
        Map<String, BusinessHours> mapBusinessHours = new Map<String, BusinessHours>();
        mapBusinessHours.put(objDefTerritoryBH.id, objDefTerritoryBH);
        List<SVMXC__Service_Group_Members__c> lstTechnicians = new List<SVMXC__Service_Group_Members__c>();
        //lstTechnicians.add(Techncn);
        Integer intCapExtendedByDays = 4;
        Decimal decAvgDriveTime = 2.4;
        String strDispatchProcessId = pro.id;
        
        OptimaxEngine.dtmSchedulingHorizonStartDateTime = DateTime.now();
        OptimaxEngine.isFullRun = true;
        //OptimaxEngine.doCapacityComputation(intNoOfDays,lstNewWorkOrders, mapBusinessHours, lstTechnicians, intCapExtendedByDays,decAvgDriveTime, objDefTerritoryBH, strDispatchProcessId);
        
        SVMXC__SM_Overnight_Stay_Policy__c opolicy = createOverNightPolicy();
        SVMXC__Territory__c ter = createTerritory(opolicy);
        SVMXC__Service_Group_Members__c tech = createTechnician(ter,opolicy);        
        SVMXC__Service_Group_Members__c tech1 = createTechnician(ter,opolicy);
        SVMXC__Service_Group_Members__c tech2 = createTechnician(ter,opolicy);
         SVMXC__Service_Group_Members__c techSF = createTechnicianSF(ter,opolicy);
        
        svmxConfirmedOvernightEvent(tech1.id);
        svmxConfirmedOvernightEvent(tech1.id);
        svmxConfirmedOvernightEvent(tech2.id);
        
        lstOfTechnicians.add(tech);
        lstOfTechnicians.add(tech1);
        lstOfTechnicians.add(tech2);
        lstOfTechnicians.add(techSF);
        
        
        //List<String> lstOfTechIds = new List<String>{tech.Id, tech1.Id, tech2.Id, techSF.Id};
        
        /*lstTechnicians = [Select Id, Name, SVMXC__Service_Territory__c, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c, SVMXC__Service_Territory__r.SVMXC__Per_Mile_Cost__c,
                            SVMXC__Service_Territory__r.SVMXC__Per_Hour_Cost__c, SVMXC__Service_Territory__r.SVMXC__Fixed_Cost__c, SVMXC__Service_Territory__r.SVMXC__Max_Hours__c,
                            SVMXC__Service_Territory__r.SVMXC__Average_Speed__c, SVMXC__Service_Territory__r.SVMXC__Max_Daily_Hours__c, SVMXC__Max_Hours__c,
                            SVMXC__Service_Territory__r.SVMXC__Max_Distance__c, 
                            SVMXC__Salesforce_User__c, SVMXC__Salesforce_User__r.IsActive, SVMXC__Fixed_Cost__c, SVMXC__Latitude_Home__c, SVMXC__Longitude_Home__c, SVMXC__Per_hour_Cost__c,
                            SVMXC__Per_Mile_Cost__c, SVMXC__Average_Speed__c, SVMXC__Max_Daily_Hours__c, SVMXC__Max_Distance__c,
                            SVMXC__Working_Hours__c ,SVMXC__Working_Hours__r.IsActive, SVMXC__Break_Hours__r.IsActive,
                            SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Zip__c, SVMXC__Country__c , SVMXC__Break_Hours__c, SVMXC__Enable_Scheduling__c,SVMXC__SM_Overnight_Stay_Policy__c,SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.IsActive, SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__r.TimeZoneSidKey
                            from SVMXC__Service_Group_Members__c  where Id IN: lstOfTechIds];*/
        
        
        
        OptimaxEngine.doCapacityComputation(intNoOfDays,lstNewWorkOrders, mapBusinessHours, lstOfTechnicians, intCapExtendedByDays,decAvgDriveTime, objDefTerritoryBH, strDispatchProcessId);
        
        BusinessHours objBusinessHour = [ select TimeZoneSidKey, WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];
        OptimaxEngine.getNextWorkingHour(objBusinessHour, DateTime.now());
        
        map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP> mapTechniciansOngoingActivity = new map<Id, SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
        mapTechniciansOngoingActivity.put(Techncn.Id, objExeTimeWP);
        SMAX_OptiMax_Engine_Ext.mapTechniciansOngoingActivity = mapTechniciansOngoingActivity;
        
          //Create a map with overnight data
        SVMXC__SM_Overnight_Stay_Policy__c poilcy = createOverNightPolicy();  
        Techncn.SVMXC__SM_Overnight_Stay_Policy__c = poilcy.id;
        update Techncn;
    
        Map<String,SVMXC__SM_Overnight_Stay_Policy__c> techNOvernightPolicy = new Map<String,SVMXC__SM_Overnight_Stay_Policy__c>();
        techNOvernightPolicy.put(Techncn.Id,poilcy);
        
        OptimaxEngine.removeOngoingActivityFromAvailability(Techncn.Id, lstExecutionTime, 30,techNOvernightPolicy);
        OptimaxEngine.getOMAX002TAG038();
    }
    
    static testMethod void ValidateWorkOrdersTest()
    {
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c();
        objWorkOrder.SVMXC__OptiMax_Status__c = 'xyz';
        objWorkOrder.SVMXC__Service_Duration__c = NULL;
        objWorkOrder.SVMXC__Dispatch_Priority__c = 0;
        objWorkOrder.SVMXC__Street__c = 'asdf';
        objWorkOrder.SVMXC__City__c = 'qwer';
        objWorkOrder.SVMXC__State__c = 'zxxcc';
        objWorkOrder.SVMXC__Zip__c = NULL;
        objWorkOrder.SVMXC__Country__c = 'xyz';
        objWorkOrder.SVMXC__QTL_Status__c = 'No Qualified Technicians (Disallow)';
        
        Map<String,BusinessHours> mapBHz = new Map<String,BusinessHours>();
        String strDefaultBHourId;
        List<BusinessHours> lBH = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime,TimeZoneSidKey from BusinessHours where isDefault = true limit 1];
        for(BusinessHours bh :lBH){
            mapBHz.put(bh.Id, bh);
            if(bh.IsDefault == TRUE)
                strDefaultBHourId = bh.Id;
        }
        SMAX_OptiMax_Engine_Ext engineExt = new SMAX_OptiMax_Engine_Ext();
        String strErrors = engineExt.doValidateWorkOrder(objWorkOrder,mapBHz,strDefaultBHourId,true);
    }
    
    static testMethod void ParsingInvalidWorkOrdersTest()
    {
        
    //Creating data 
    list<string> lstSettings = new list<string>();        
        lstSettings.add('GLOB001_GBL007');
        List<SVMXC__ServiceMax_Config_Data__c> lstSettingValues = new List<SVMXC__ServiceMax_Config_Data__c>();
        try{
        lstSettingValues = [SELECT SVMXC__Internal_Value__c, SVMXC__Setting_Unique_ID__c FROM SVMXC__ServiceMax_Config_Data__c WHERE recordType.Name = 'Setting Value'
                            AND SVMXC__Setting_Unique_ID__c IN :lstSettings
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' 
                            AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Configuration_Type__c = 'Global' FOR UPDATE
                            ];                          
        lstSettingValues[0].SVMXC__Internal_Value__c='True';
        }catch(exception e){
            system.debug('Exception occured..'+e.getMessage());
        }
        Long timeDiff = 0;
        DateTime firstTime = System.now();
        do
        {
            timeDiff = System.now().getTime() - firstTime.getTime();
        }
        while(timeDiff <= 10000);

        upsert lstSettingValues;
        
        /*try {
            upsert lstSettingValues;
        } catch(System.QueryException ex) {
            boolean repeat = true;
            Integer count = 0;
            while(repeat && count < 10) {
                try {
                    repeat = false;
                    upsert lstSettingValues;
                } catch(System.QueryException ex1) {
                    repeat = true;
                    count ++;
                }
            }
        }*/
       
        //upsert lstSettingValues;
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
              
        SVMXC__SVMX_Jobs__c inProgressJob = new SVMXC__SVMX_Jobs__c(SVMXC__SVMX_Process__c = dispatchprocessId, SVMXC__Territory__c = Territory2.Id, SVMXC__OptiMax_Message__c = 'In Progress');        
        insert inProgressJob;   
        
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c();
        objWorkOrder.SVMXC__OptiMax_Status__c = 'xyz';
        objWorkOrder.SVMXC__Dispatch_Process__c = dispatchprocessId;
        objWorkOrder.SVMXC__Service_Duration__c = NULL;
        objWorkOrder.SVMXC__Dispatch_Priority__c = 0;
        objWorkOrder.SVMXC__Street__c = 'asdf';
        objWorkOrder.SVMXC__City__c = 'qwer';
        objWorkOrder.SVMXC__State__c = 'zxxcc';
        objWorkOrder.SVMXC__Zip__c = NULL;
        objWorkOrder.SVMXC__Country__c = 'xyz';
        objWorkOrder.SVMXC__QTL_Status__c = 'No Qualified Technicians (Disallow)';
        insert objWorkOrder;
        
        SVMXC__Service_Order__c objWorkOrder2 = new SVMXC__Service_Order__c();
        objWorkOrder2.SVMXC__OptiMax_Status__c = 'xyz';
        objWorkOrder2.SVMXC__Dispatch_Process__c = dispatchprocessId;
        objWorkOrder2.SVMXC__Service_Duration__c = NULL;
        objWorkOrder2.SVMXC__Dispatch_Priority__c = 0;
        objWorkOrder2.SVMXC__Street__c = 'asdf';
        objWorkOrder2.SVMXC__City__c = 'qwer';
        objWorkOrder2.SVMXC__State__c = 'zxxcc';
        objWorkOrder2.SVMXC__Zip__c = NULL;
        objWorkOrder2.SVMXC__Country__c = 'xyz';
        objWorkOrder2.SVMXC__QTL_Status__c = 'No Qualified Technicians (Disallow)';
        insert objWorkOrder2;
        
        String strBadWorkOrderDetails='{"workItemName":"'+objWorkOrder.Name+'","workItemId":"'+objWorkOrder.Id+'","errorDetails":[{"errorType":"Dispatch Parameter Error","errorMessage":"Invalid Service Duration"},{"errorType":"Dispatch Parameter Error","errorMessage":"Invalid Zipcode"},{"errorType":"QTL Error","errorMessage":"Workorder disallowed due to No Qualified Technicians computed."}]};';
        
        Attachment objBadWorkOrderAttach = new Attachment(Name = 'Invalid WorkOrders', ParentId = inProgressJob.Id, Body = Blob.valueOf(strBadWorkOrderDetails), IsPrivate = TRUE);
        insert objBadWorkOrderAttach;
            
        Map<String, String> mapInvalidWOErrors = new Map<String, String>();
        string strLogger='';
        Id objSvmxJobId=inProgressJob.Id;
        
        
        SMAX_OptiMax_Engine_Ext engineExt = new SMAX_OptiMax_Engine_Ext();
        mapInvalidWOErrors = engineExt.doCreateWOErrorMap(mapInvalidWOErrors, objSvmxJobId, strLogger);
        
        String strSvmxJobMsg1 = '{"workItemName":"WO-01233625","workItemId":"a1L2I000006DehGUAS","errorDetails":[{"errorType":"Dispatch Parameter Error","errorMessage":"Not a valid address or zipcode"}]};{"workItemName":"WO-01233626","workItemId":"a1L2I000006DehHUAS","errorDetails":[{"errorType":"Dispatch Parameter Error","errorMessage":"Not a valid address or zipcode"}]};';
        mapInvalidWOErrors = engineExt.doCreateWOErrorMap(mapInvalidWOErrors, strSvmxJobMsg1, strLogger);
    }    
        
        
      static testMethod void testOvernight(){
        SMAX_OptiMax_Engine_Ext engineExt = new SMAX_OptiMax_Engine_Ext();
        List<BusinessHours> lBH = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime,TimeZoneSidKey from BusinessHours where isDefault = true limit 1];
        
       engineExt.getDayOfDateTime(system.now());
       //engineExt.returnSameDayEndTime(system.now(),lBH.get(0));
       engineExt.returnDayBHEndTime(system.now(),lBH.get(0));
       
       SVMXC__SM_Overnight_Stay_Policy__c opolicy = createOverNightPolicy();
       SVMXC__Territory__c ter = createTerritory(opolicy);
       SVMXC__Service_Group_Members__c tech = createTechnician(ter.id,opolicy);
       
       Map<String,SVMXC__SM_Overnight_Stay_Policy__c> techNOvernightPolicy = new Map<String,SVMXC__SM_Overnight_Stay_Policy__c>();
       techNOvernightPolicy.put(tech.Id,opolicy);
       
       SMAX_OptiMax_Engine_WS.ExecutionTime_WP objExeTimeWP = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(system.now(),system.now()+1);
       engineExt.isOvernightAllowedThisDay(objExeTimeWP,techNOvernightPolicy,tech.Id);
       
       
       SMAX_OptiMax_Engine_WS.ExecutionTime_WP objExeTimeWP1 = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(system.now()+1,system.now()+1);
       engineExt.isOvernightAllowedThisDay(objExeTimeWP1,techNOvernightPolicy,tech.Id);
           
       SMAX_OptiMax_Engine_WS.ExecutionTime_WP objExeTimeWP2 = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(system.now()+2,system.now()+1);
       engineExt.isOvernightAllowedThisDay(objExeTimeWP2,techNOvernightPolicy,tech.Id);
           
       SMAX_OptiMax_Engine_WS.ExecutionTime_WP objExeTimeWP3 = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(system.now()+3,system.now()+1);
       engineExt.isOvernightAllowedThisDay(objExeTimeWP3,techNOvernightPolicy,tech.Id);
       
      SMAX_OptiMax_Engine_WS.ExecutionTime_WP objExeTimeWP4 = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(system.now()+4,system.now()+1);
       engineExt.isOvernightAllowedThisDay(objExeTimeWP4,techNOvernightPolicy,tech.Id);
       
       SMAX_OptiMax_Engine_WS.ExecutionTime_WP objExeTimeWP5= new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(system.now()+5,system.now()+1);
       engineExt.isOvernightAllowedThisDay(objExeTimeWP5,techNOvernightPolicy,tech.Id);
       
       SMAX_OptiMax_Engine_WS.ExecutionTime_WP objExeTimeWP6= new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(system.now()+6,system.now()+1);
       engineExt.isOvernightAllowedThisDay(objExeTimeWP6,techNOvernightPolicy,tech.Id);
       
       
       SMAX_OptiMax_Engine_WS.DestinationNodes_WP lastnode = new SMAX_OptiMax_Engine_WS.DestinationNodes_WP();
       lastnode.departureTime = system.now()+1;
       lastnode.arraivalTime = system.now();
       
       String techid = tech.id;
       //engineExt.constructOvernightSFEvent(lastnode,techid,lBH.get(0),'12.9442','77.6076',techid,'Tech1');
       //engineExt.constructOvernightSVMXEvent(lastnode,techid,lBH.get(0),'12.9442','77.6076','Tech2');
       
       
       SVMXC__Service_Group_Members__c tech1 = createTechnician(ter.id,opolicy);
       SVMXC__Service_Group_Members__c tech2 = createTechnician(ter.id,opolicy);
       svmxConfirmedOvernightEvent(tech1.id);
       svmxConfirmedOvernightEvent(tech1.id);
       svmxConfirmedOvernightEvent(tech2.id);
       
       SVMXC__Service_Group_Members__c tech3 = createTechnician(ter.id,opolicy);
       SVMXC__Service_Group_Members__c tech4 = createTechnician(ter.id,opolicy);
       sfConfirmedOvernightEvent(tech3.id);
       sfConfirmedOvernightEvent(tech3.id);
       sfConfirmedOvernightEvent(tech4.id);
       
       Set<String> techIds = new Set<String>();
       techIds.add(tech1.id);
       techIds.add(tech2.id);
       techIds.add(tech3.id);
       techIds.add(tech4.id);
        
       //engineExt.getTechnicianConfirmedOvernightEventDates(techIds);
       
       //calculate Overnight stay event start and end datetime
       datetime departureDT = Datetime.now();
       //engineExt.calculateONSStartEndDateTime(departureDT,lBH.get(0),'StartTime');
       //engineExt.calculateONSStartEndDateTime(departureDT,lBH.get(0),'EndTime');
       engineExt.getStartOfTheWeekDt(Datetime.now(), 'Saturday');
       
       engineExt.getOMAX002TAG038();
       engineExt.getOMAX002TAG020();
       engineExt.getOMAX002TAG021();
       engineExt.getOMAX002TAG022();
       engineExt.getOMAX002TAG023();
       engineExt.getOMAX002TAG024();
       engineExt.getOMAX002TAG025();
       engineExt.getOMAX002TAG026();
       engineExt.getOMAX002TAG027();
       engineExt.getOMAX002TAG028();
       
     }
        
       private static SVMXC__SM_Overnight_Stay_Policy__c createOverNightPolicy(){
        SVMXC__SM_Overnight_Stay_Policy__c poicy = new SVMXC__SM_Overnight_Stay_Policy__c();
        poicy.SVMXC__SM_Active__c =  true;
        poicy.SVMXC__SM_Allow_Friday_ONS__c = true;
        poicy.SVMXC__SM_Allow_Monday_ONS__c = true;
        poicy.SVMXC__SM_Allow_Saturday_ONS__c = true;
        poicy.SVMXC__SM_Allow_Sunday_ONS__c = true;
        poicy.SVMXC__SM_Allow_Thursday_ONS__c = true;
        poicy.SVMXC__SM_Allow_Tuesday_ONS__c= true;
        poicy.SVMXC__SM_Allow_Wednesday_ONS__c= true;
        poicy.SVMXC__SM_Consecutive_ONS_Per_Week__c= 2;
        poicy.SVMXC__SM_Total_ONS_Per_Week__c= 4;
        poicy.SVMXC__SM_Drive_Distance_Threshold__c= 20;
        poicy.SVMXC__SM_Drive_Time_Threshold__c= 20;
        poicy.SVMXC__SM_Policy_Override__c= true  ;
        
        insert poicy ;
        return poicy ;
    
    }
     
     private static SVMXC__Territory__c createTerritory(SVMXC__SM_Overnight_Stay_Policy__c oPolicy){
         SVMXC__Territory__c ecoTeritory = new SVMXC__Territory__c();
         ecoTeritory.Name = 'Ter-UT';
         ecoTeritory.SVMXC__SM_Overnight_Stay_Policy__c = oPolicy.id;
         BusinessHours[] bh = [select TimeZoneSidKey, WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];
         if (bh.size() > 0){
            ecoTeritory.SVMXC__Territory_s_Business_Hours__c = bh[0].Id;
            ecoTeritory.SVMXC__Territory_s_Business_Hours__r = bh[0];
         }

         insert ecoTeritory;
         return ecoTeritory;
    }
    
        
    private static SVMXC__Service_Group_Members__c createTechnician(String terId,SVMXC__SM_Overnight_Stay_Policy__c oPolicy){
                           
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'ECO_Tech_UT';
        technician.SVMXC__City__c = 'Bangalore';
        technician.SVMXC__Country__c = 'India';
        technician.SVMXC__Zip__c = '560030';
        technician.SVMXC__Service_Territory__c = terId;
        technician.SVMXC__Service_Group__c= createServiceGroupId();
        technician.SVMXC__SM_Overnight_Stay_Policy__c = oPolicy.id;
        technician.SVMXC__Active__c =true;
        technician.SVMXC__Enable_Scheduling__c=true;
        BusinessHours[] bh = [select TimeZoneSidKey, WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];
        if (bh.size() > 0){
            technician.SVMXC__Working_Hours__c = bh[0].Id;
        }   
        insert technician;
        return technician;
        
    }

    private static SVMXC__Service_Group_Members__c createTechnician(SVMXC__Territory__c ter,SVMXC__SM_Overnight_Stay_Policy__c oPolicy){
                           
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'ECO_Tech_UT';
        technician.SVMXC__City__c = 'Bangalore';
        technician.SVMXC__Country__c = 'India';
        technician.SVMXC__Zip__c = '560030';
        technician.SVMXC__Service_Territory__c = ter.Id;
        technician.SVMXC__Service_Territory__r = ter;
        technician.SVMXC__Service_Group__c= createServiceGroupId();
        technician.SVMXC__SM_Overnight_Stay_Policy__c = oPolicy.id;
        technician.SVMXC__Active__c =true;
        technician.SVMXC__Enable_Scheduling__c=true;
        BusinessHours[] bh = [select TimeZoneSidKey, WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];
        if (bh.size() > 0){
            technician.SVMXC__Working_Hours__c = bh[0].Id;
        }   
        insert technician;
        return technician;
        
    }
    
    private static SVMXC__Service_Group_Members__c createTechnicianSF(SVMXC__Territory__c ter,SVMXC__SM_Overnight_Stay_Policy__c oPolicy){
                           
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'ECO_Tech_UT';
        technician.SVMXC__City__c = 'Bangalore';
        technician.SVMXC__Country__c = 'India';
        technician.SVMXC__Zip__c = '560030';
        technician.SVMXC__Service_Territory__c = ter.Id;
        technician.SVMXC__Service_Territory__r = ter;
        technician.SVMXC__Service_Group__c= createServiceGroupId();
        technician.SVMXC__SM_Overnight_Stay_Policy__c = oPolicy.id;
        technician.SVMXC__Active__c =true;
        technician.SVMXC__Enable_Scheduling__c=true;
        technician.SVMXC__Salesforce_User__c = [SELECT id FROM USER Where IsActive = true limit 1].id;
        BusinessHours[] bh = [select TimeZoneSidKey, WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];
        if (bh.size() > 0){
            technician.SVMXC__Working_Hours__c = bh[0].Id;
        }   
        insert technician;
        return technician;
        
    }
    
    private static String createServiceGroupId(){
     SVMXC__Service_Group__c segroup = new SVMXC__Service_Group__c();
     segroup.Name = 'TestGroup-UT';
     insert segroup;
     return segroup.id;
    }
     
      //private supporting methods
    private static Event createSFEvent(String techId){
        Event ev = new Event();
        //ev.EventSubtype  = 'Event';
        ev.StartDateTime = system.today();
        ev.EndDateTime = system.today() + 1;
        ev.WhatId = techId;
        insert ev;
        return ev;
    }
    
    private  static SVMXC__SVMX_Event__c createSVMXECOEVENT(String technician){
        SVMXC__SVMX_Event__c svmxEv = new SVMXC__SVMX_Event__c();
        svmxEv.Name = 'EVMX_EV_UT';
        svmxEv.SVMXC__Technician__c =  technician;
        svmxEv.SVMXC__StartDateTime__c= system.today();
        svmxEv.SVMXC__EndDateTime__c = system.today() + 1;
        
         insert svmxEv;
         return svmxEv;
    }
    
    
      private  static SVMXC__SVMX_Event__c svmxConfirmedOvernightEvent(String technician){
        SVMXC__SVMX_Event__c svmxEv = new SVMXC__SVMX_Event__c();
        svmxEv.Name = 'EVMX_EV_UT';
        svmxEv.SVMXC__Technician__c =  technician;
        svmxEv.SVMXC__StartDateTime__c= system.today();
        svmxEv.SVMXC__EndDateTime__c = system.today() + 1;
        svmxEv.SVMXC__Type__c = 'Overnight Stay';
        svmxEv.SVMXC__SM_Status__c = 'Confirmed';
        insert svmxEv;
        return svmxEv;
    }
    
      private static Event sfConfirmedOvernightEvent(String techId){
        Event ev = new Event();
        //ev.EventSubtype  = 'Event';
        ev.StartDateTime = system.today();
        ev.EndDateTime = system.today() + 1;
        ev.WhatId = techId;
        ev.Type = 'Overnight Stay';
        ev.SVMXC__SM_Status__c = 'Confirmed';
        insert ev;
        return ev;
    }
    
    static testMethod void getTechConfirmedOvernightEventDates() {
        SVMXC__SM_Overnight_Stay_Policy__c opolicy = createOverNightPolicy();
        SVMXC__Territory__c ter = createTerritory(opolicy);
        SVMXC__Service_Group_Members__c tech1 = createTechnician(ter.id,opolicy);
        SVMXC__Service_Group_Members__c tech2 = createTechnician(ter.id,opolicy);
        
        Event ev = sfConfirmedOvernightEvent(tech1.Id);
        SVMXC__SVMX_Event__c svmxEv = svmxConfirmedOvernightEvent(tech2.Id);
        
        Set<String> scheduledTechSet = new Set<String>();
        scheduledTechSet.add(tech1.Id);
        scheduledTechSet.add(tech2.Id);
                
        SMAX_OptiMax_Engine_Ext  engine_ext = new SMAX_OptiMax_Engine_Ext();
        engine_ext.getTechnicianConfirmedOvernightEventDates(scheduledTechSet);
    }
}