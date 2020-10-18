@isTest
(SeeAllData=false)
public with sharing class WSCH_CommonUtils_UT {

    static testMethod void WSCH_CommonUtils_UT_Test(){
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
        svmxprocess.SVMXC__Dispatch_Method__c='Linx for ServicePower';
        insert svmxprocess;

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

       list<SVMXC__Service_Order__c> workOrders = new list<SVMXC__Service_Order__c>();

        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrder.SVMXC__Zip__c = '75001';
        workOrder.SVMXC__Order_Status__c='Open';
        //workOrder.SVMXC__Group_Member__c = Tech.id;
        //workOrder.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder.SVMXC__Locked_By_DC__c = false;
        workOrder.SVMXC__Service_Duration__c = 60;
        workOrder.SVMXC__OptiMax_Status__c ='';
        workOrder.SVMXC__Scheduling_Change_Token__c = '';
        workOrder.SVMXC__Primary_Territory__c=territory.Id;
        workOrders.add(workOrder);

        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        workOrder1.SVMXC__Zip__c = '75005';
        workOrder1.SVMXC__Order_Status__c='Open';
        //workOrder1.SVMXC__Group_Member__c = Tech.id;
        //workOrder1.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder1.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder1.SVMXC__Locked_By_DC__c = false;
        workOrder1.SVMXC__Service_Duration__c = 60;
        workOrder1.SVMXC__OptiMax_Status__c = '';
        workOrder1.SVMXC__Scheduling_Change_Token__c = '';
        workOrder1.SVMXC__Primary_Territory__c=territory.Id;
        workOrders.add(workOrder1);
        insert workOrders;

        String strWoId=workOrder.Id;
        //WSCH_CommonUtils.fetchWorkOrderById(strWoId);

        List<String> woIdlist = new List<String>();
        woIdlist.add(strWoId);
        //WSCH_CommonUtils.fetchWorkOrders(woIdList);

        DateTime startDateTime = System.now().addMinutes(10);
        DateTime endDateTime = System.now().addMinutes(55);
        //WSCH_CommonUtils.getDurationInMinutes(startDateTime, endDateTime);

        String spDateTime = '2014-02-18T16:30';
        //WSCH_CommonUtils.getPSTDateTime(spDateTime);
        //WSCH_CommonUtils.getSFDateTime(spDatetime);

        String spDispatchStatus='Tentative';
        WSCH_CommonUtils.getServiceMaxJobStatus(spDispatchStatus);

        String svmxDispatchStatus='Dispatched';
        WSCH_CommonUtils.getServicePowerJobStatus(svmxDispatchStatus);


        /*DateTime sfDateTime = System.now();
        WSCH_CommonUtils.getSPDateTime(sfDateTime);*/

        WSCH_CommonUtils.getTerritoryFRUMap(workOrders);

        /*DateTime dateTimeObj = System.now();
        String strConvertType='SP';
        WSCH_CommonUtils.parseDateTime(dateTimeObj, strConvertType);

        String strDateTime='2014-02-18T16:30';
        strConvertType='SM';
        WSCH_CommonUtils.parseDateTime(strDateTime, strConvertType);*/

        event SFevent = new event();
        SFevent.DurationInMinutes = 60;
        SFevent.ActivityDateTime = system.now();
        SFevent.StartDateTime = SFevent.ActivityDateTime;
        insert SFevent;
        SVMXC__Service_Group__c objTeam = new SVMXC__Service_Group__c (
                                                    Name = 'TEAM 1'
                                                    );
                insert objTeam;
        SVMXC__Territory__c objTerritory = new SVMXC__Territory__c (
                                            Name = 'TERRITORY 1'
                                            );
        insert objTerritory;

       SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 1' ,
                                            SVMXC__Latitude__c = 40.739582 ,
                                            SVMXC__Longitude__c = -73.980772,
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true
                                            );
        insert tech1;
        SVMXC__SVMX_Event__c svmxEvent= new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-12 00:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-12 01:00:00').addHours(1),
                                                    SVMXC__Technician__c =  tech1.Id,
                                                    SVMXC__WhatId__c = Schema.Sobjecttype.SVMXC__SVMX_Event__c.getKeyPrefix()
                                                    );

        insert svmxEvent;

        SVMXC__SVMX_Optimizer__c objSVMX_Optimizer = new SVMXC__SVMX_Optimizer__c();
        objSVMX_Optimizer.SVMXC__WhatId__c = svmxevent.id;
        objSVMX_Optimizer.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CREATE';
        insert objSVMX_Optimizer;
        List<String> eventIdList = new List<String> ();
        eventIdList.add(objSVMX_Optimizer.id);
        WSCH_CommonUtils.fetchSVMXOptimizerById(eventIdList);

        WSCH_CommonUtils.fetchSVMXEventObjectById(svmxevent.id);
        WSCH_CommonUtils.fetchSFEventObjectById(SFevent.id);

        SVMXC__Service_Group_Members__c tech = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 1' ,
                                            SVMXC__Latitude__c = 40.739582 ,
                                            SVMXC__Longitude__c = -73.980772,
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__Salesforce_User__c = UserInfo.getUserId()
                                            );
        insert tech;
        WSCH_CommonUtils.fetchTechnicianById(tech.id);
        WSCH_CommonUtils.fetchSFUserTechnicianId(UserInfo.getUserId());

        list<SVMXC__SVMX_Optimizer__c> lstSVMXoptimizer = new list<SVMXC__SVMX_Optimizer__c>();
        lstSVMXoptimizer.add(objSVMX_Optimizer);
        WSCH_CommonUtils.getTerritoryFRUMap(lstSVMXoptimizer);
        WSCH_CommonUtils.getNonWOEventTechnician(objSVMX_Optimizer);

        WSCH_CommonUtils.isSFEvent(objSVMX_Optimizer);
        WSCH_CommonUtils.getSettingValue('GLOB001','GBL022');
        objSVMX_Optimizer.SVMXC__WhatId__c = SFevent.id;
        WSCH_CommonUtils.getNonWOEventTechnician(objSVMX_Optimizer);
        //WSCH_CommonUtils.getCurrentTimeStamp();
        SVMXC__Service_Order__c objWO = new SVMXC__Service_Order__c();
        insert objWO;
        WSCH_CommonUtils.fetchWorkOrderById(objWO.id);

        WSCH_CommonUtils.getContinuousDP();
        
        List<String> woIDs = new List<String>();
        woIDs.add(String.Valueof(workOrders[0].Id));
        String qry = 'Name';
        
        test.startTest();
        WSCH_CommonUtils.fetchWorkOrders(woIDs);
        WSCH_CommonUtils.fetchRequiredField(woIDs, qry);
        WSCH_CommonUtils.fetchRequiredFieldById(String.Valueof(workOrders[0].Id), qry);
        //WSCH_CommonUtils.fetchWorkOrderByName(workOrders[0].Name);
        WSCH_CommonUtils.getWorkItemId(qry, workOrders[0]);
        
        List<String> fieldValues = new List<String>();
        fieldValues.add(workOrders[0].Name);
        Set<String> whatIds = new Set<String>();
        whatIds.add(String.Valueof(workOrders[0].Id));
        WSCH_CommonUtils.getWorkItemIds(qry, fieldValues);
        WSCH_CommonUtils.fetchSVMXOptimizerByWhatId(woIDs);
        WSCH_CommonUtils.fetchSFEventByWhatId(whatIds);
        WSCH_CommonUtils.fetchSVMXEventByWhatId(whatIds);
        WSCH_CommonUtils.fetchOptimizerByExtId('SOU');
        WSCH_CommonUtils.startSyncScheduler();
        
        WSCH_CommonUtils.getDispatchProcessIdByName(svmxprocess.SVMXC__Name__c);
        WSCH_CommonUtils.fetchTerritoryIdByExternalId('SOU');
        WSCH_CommonUtils.fetchExternalIdByTerritoryId(String.valueof(territory.Id));
        WSCH_CommonUtils.isEventValid(objSVMX_Optimizer);
        
        test.StopTest();

    }
    
    static testMethod void testClosedHours() {
        
        test.startTest();
        
        List<BusinessHours> lstOfBusinessHours1;
        lstOfBusinessHours1 = [SELECT Id,IsActive,TimeZoneSidKey,IsDefault,MondayStartTime,MondayEndTime,
                                TuesdayStartTime,TuesdayEndTime,WednesdayStartTime,WednesdayEndTime,
                                ThursdayStartTime,ThursdayEndTime,FridayStartTime,FridayEndTime,SaturdayStartTime,
                                SaturdayEndTime,SundayStartTime,SundayEndTime FROM BusinessHours
                                WHERE IsDefault = TRUE AND IsActive = TRUE];

        BusinessHours businessHoursObj = lstOfBusinessHours1.get(0);

        Date startDate = Date.newInstance(2015, 2, 14);
        Date endDate = Date.newInstance(2015, 2, 21);
        
        Integer tzOffsetinMinutes = 360, startTimeMins = 780, endTimeMins = 900;
        WSCH_CommonUtils.getClosedHours(startDate, endDate, businessHoursObj, null); //sending tzOffsetinMinutes as null
        WSCH_CommonUtils.getDateTimeRangeForAllDayHoliday(startDate, businessHoursObj, tzOffSetinMinutes);
        WSCH_CommonUtils.getDateTimeRangeForAllDayHoliday(startDate, businessHoursObj, null);
        WSCH_CommonUtils.getDateTimeRangeForPartDayHoliday(startDate, startTimeMins, endTimeMins, businessHoursObj, tzOffSetinMinutes);
        WSCH_CommonUtils.getDateTimeRangeForPartDayHoliday(startDate, startTimeMins, endTimeMins, businessHoursObj, null);
        
        List<Holiday> lstOfHolidays = new List<Holiday>();
        
        //allDay = true and recurrence = true
        Date activityDate1 = Date.newInstance(2015, 2, 17);
        Holiday holiday1 = new Holiday();
        holiday1.ActivityDate = activityDate1;
        holiday1.IsAllDay = true;
        holiday1.IsRecurrence = true;
        holiday1.Name = 'pongal';
        holiday1.RecurrenceEndDateOnly = null;
        holiday1.RecurrenceStartDate = activityDate1;
        
        lstOfHolidays.add(holiday1);
        WSCH_CommonUtils.getClosedHoursForHolidays(startDate, endDate, businessHoursObj, tzOffsetinMinutes, lstOfHolidays);
        WSCH_CommonUtils.getClosedHoursForHolidays(startDate, endDate, businessHoursObj, null, lstOfHolidays);
        
        //allDay = true and recurrence = false
        Holiday holiday11 = new Holiday();
        holiday11.ActivityDate = activityDate1;
        holiday11.IsAllDay = true;
        holiday11.IsRecurrence = false;
        holiday11.Name = 'pongal';
        holiday11.RecurrenceEndDateOnly = null;
        holiday11.RecurrenceStartDate = null;
        
        lstOfHolidays.clear();
        lstOfHolidays.add(holiday11);
        WSCH_CommonUtils.getClosedHoursForHolidays(startDate, endDate, businessHoursObj, tzOffsetinMinutes, lstOfHolidays);
        WSCH_CommonUtils.getClosedHoursForHolidays(startDate, endDate, businessHoursObj, null, lstOfHolidays);
        
        //allDay = false and recurrence = false
        Date activityDate2 = Date.newInstance(2015, 2, 17);
        Holiday holiday2 = new Holiday();
        holiday2.ActivityDate = activityDate2;
        holiday2.StartTimeInMinutes = 780;
        holiday2.EndTimeInMinutes = 900;
        holiday2.IsAllDay = false;
        holiday2.IsRecurrence = false;
        holiday2.Name = 'bandh';
        holiday2.RecurrenceEndDateOnly = null;
        holiday2.RecurrenceStartDate = null;
        
        lstOfHolidays.clear();
        lstOfHolidays.add(holiday2);
        WSCH_CommonUtils.getClosedHoursForHolidays(startDate, endDate, businessHoursObj, tzOffsetinMinutes, lstOfHolidays);
        WSCH_CommonUtils.getClosedHoursForHolidays(startDate, endDate, businessHoursObj, null, lstOfHolidays);
        
        //allDay = false and recurrence = true
        Date activityDate3 = Date.newInstance(2015, 2, 17);
        Holiday holiday3 = new Holiday();
        holiday3.ActivityDate = activityDate3;
        holiday3.StartTimeInMinutes = 780;
        holiday3.EndTimeInMinutes = 900;
        holiday3.IsAllDay = false;
        holiday3.IsRecurrence = true;
        holiday3.Name = 'bandh';
        holiday3.RecurrenceEndDateOnly = null;
        holiday3.RecurrenceStartDate = activityDate3;
        
        lstOfHolidays.clear();
        lstOfHolidays.add(holiday3);
        WSCH_CommonUtils.getClosedHoursForHolidays(startDate, endDate, businessHoursObj, tzOffsetinMinutes, lstOfHolidays);
        WSCH_CommonUtils.getClosedHoursForHolidays(startDate, endDate, businessHoursObj, null, lstOfHolidays);
        
        //allDay = false and recurrence = true
        Date activityDate4 = Date.newInstance(2015, 2, 17);
        Holiday holiday4 = new Holiday();
        holiday4.ActivityDate = activityDate4;
        holiday4.StartTimeInMinutes = 780;
        holiday4.EndTimeInMinutes = 900;
        holiday4.IsAllDay = false;
        holiday4.IsRecurrence = true;
        holiday4.Name = 'bandh';
        holiday4.RecurrenceEndDateOnly = null;
        holiday4.RecurrenceStartDate = null;
        
        lstOfHolidays.clear();
        lstOfHolidays.add(holiday4);
        WSCH_CommonUtils.getClosedHoursForHolidays(startDate, endDate, businessHoursObj, tzOffsetinMinutes, lstOfHolidays);
        WSCH_CommonUtils.getClosedHoursForHolidays(startDate, endDate, businessHoursObj, null, lstOfHolidays);
        
        test.stopTest();
    }
    
    static testMethod void testSetOptimizerErrorText() {
        
        test.startTest();
        
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrder.SVMXC__OptiMax_Error_Text__c = 'error text';
        String errorText = 'error text';
        
        WSCH_CommonUtils.setOptimizerErrorText(workOrder, errorText);
        
        test.stopTest();
    }
    
    static testMethod void testDeleteWORelatedEventOnCancel() {
        
        test.startTest();
        Set<SVMXC__Service_Order__c> setWOs = new Set<SVMXC__Service_Order__c>();
        
        SVMXC__Service_Group__c objTeam = new SVMXC__Service_Group__c (
                                                    Name = 'TEAM 1'
                                                    );
        insert objTeam;
        
        SVMXC__Territory__c objTerritory = new SVMXC__Territory__c (
                                            Name = 'TERRITORY 1'
                                            );
        insert objTerritory;

        SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 1' ,
                                            SVMXC__Latitude__c = 40.739582 ,
                                            SVMXC__Longitude__c = -73.980772,
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true
                                            );
        insert tech1;
                                            
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CANCEL_WO';
        workOrder.SVMXC__Service_Group__c = objTeam.id;
        workOrder.SVMXC__Group_Member__c = tech1.id;
        insert workOrder;
        
        setWOs.add(workOrder);
        
        WSCH_CommonUtils.deleteWORelatedEventsOnCancel(setWOs);
        
        test.stopTest();              
    }
    
    static testMethod void testGlobalUtilValMap() {
    
        test.startTest();
        WSCH_CommonUtils.globalUtilValMap  = new Map<String,String>();
        WSCH_CommonUtils.globalUtilValMap.put('one','1');
        
        WSCH_CommonUtils.getGlobalUtilValMap('one');
        WSCH_CommonUtils.putGlobalUtilValMap('two','2');
        
        WSCH_CommonUtils.globalUtilValMap = null;
        WSCH_CommonUtils.putGlobalUtilValMap('two','2');
        
        test.stopTest();
    }
    
    static testMethod void testGetMapOfWorkOrders() {
        test.startTest();
        List<SVMXC__Service_Order__c> lstOfWorkOrders = new List<SVMXC__Service_Order__c>();
        
        SVMXC__Service_Order__c wo1 = new SVMXC__Service_Order__c();
        wo1.SVMXC__Zip__c = '560001';
                        
        lstOfWorkOrders.add(wo1);
        insert lstOfWorkOrders;
        
        WSCH_CommonUtils.strSetOfUpdateableFields = new Set<String>();
        WSCH_CommonUtils.strSetOfUpdateableFields.add('SVMXC__Zip__c');
        WSCH_CommonUtils.getMapOfWorkOrders(null, lstOfWorkOrders);
        
        WSCH_CommonUtils.getUpdateableWo(lstOfWorkOrders);
        
        String woName = 'wo_111';        
        List<String> woNameList = new List<String>();
        woNameList.add(woName);
        WSCH_CommonUtils.fetchWorkOrdersByName(woNameList);
        
        //WSCH_CommonUtils.fetchWorkOrderByName('123');
        
        /*SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        workOrder1.SVMXC__Zip__c = '75005';
        insert workOrder1;
        
        WSCH_CommonUtils.fetchSVMXOptimizerByWhatId(workOrder1.id);*/        
                
        lstOfWorkOrders = null;
        WSCH_CommonUtils.getMapOfWorkOrders(null, lstOfWorkOrders);
        
        WSCH_CommonUtils.resolveOptimaxStatus('OPT_COMPLETED', 'OPT_COMPLETED');
        
        SVMXC__Dependency_Management__c depManagement = new SVMXC__Dependency_Management__c();
        depManagement.SVMXC__Error_Text__c = 'hello';
        insert depManagement;
        WSCH_CommonUtils.setOptimizerErrorText(depManagement, 'error text');
        
        test.stopTest();
    }
    
    static testMethod void testgetDPHorizonStartAndEndDates() {
        
        Test.startTest();
        String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
        String dispatchProcessRecordType;
        
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
        
        RecordType[] rtDP = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' ];
        for(RecordType rt : rtDP)
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               dispatchProcessRecordType = rt.ID;
        }
        
        String svmxRuleRecordType;
        RecordType[] rtRule = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' ];
        for(RecordType rt : rtRule)
        {
            if(rt.Name == 'SVMX Rule' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               svmxRuleRecordType = rt.ID;
        }
        
        Date dt = Date.today();
        dt = dt.addDays(1);

        SVMXC__ServiceMax_Processes__c dprocessParent = new SVMXC__ServiceMax_Processes__c();
        dprocessParent.SVMXC__Dispatch_Method__c = 'Real Time Optimization';
        dprocessParent.SVMXC__Dispatch_Process_Status__c ='Complete';
        dprocessParent.SVMXC__Dispatch_Timezone__c= 'Asia/Colombo';
        dprocessParent.SVMXC__Name__c = 'Process-UT';
        dprocessParent.RecordTypeId = dispatchProcessRecordType;
        dprocessParent.SVMXC__End_Date__c = dt;
        dprocessParent.SVMXC__Calendar_End_Days__c = 4;
        dprocessParent.SVMXC__Full_Run_Unit__c = 'DAYS';
        dprocessParent.SVMXC__Calendar_Start_Days__c = 2;
        dprocessParent.SVMXC__Frequency__c = 2;
        insert dprocessParent;
        
        SVMXC__ServiceMax_Processes__c dprocess = new SVMXC__ServiceMax_Processes__c();
        dprocess.SVMXC__Process__c = dprocessParent.Id;
        dprocess.SVMXC__Rule_Type__c = 'Territory Access';
        dprocess.SVMXC__Territory__c = territory.Id;
        dprocess.RecordTypeId = svmxRuleRecordType;
        insert dprocess;
        
        system.debug('dpId - ' + dprocessParent.Id + 'terId - ' + territory.Id);
        
        WSCH_CommonUtils.getDPHorizonStartAndEndDates(dprocessParent, lBH[0]);
        WSCH_CommonUtils.getDPHorizonStartAndEndDatesForLTP(dprocessParent, lBH[0]);
        
        Test.stopTest();
    }
}