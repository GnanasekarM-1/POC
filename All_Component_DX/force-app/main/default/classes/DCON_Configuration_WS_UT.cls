@isTest
Private class DCON_Configuration_WS_UT {
    static testMethod void DCON_Configuration_WS_UT_Test()
    {
        COMM_SecurityUtils.getInstance().isSecurityCheckEnabled = false;
        User u = [SELECT id,LocaleSidKey from User where id = :UserInfo.getUserId()];
        StaticResource DefaultSetting = new StaticResource();
        DefaultSetting = [Select Name, Body From StaticResource where Name= 'DCON_UI_Settings'];
        //Start Test
        test.starttest();
        system.assert(u.Id!=null);    
        DCON_Configuration_WS.DCON_GetUserType_WS(u.Id);  
        DCON_Configuration_WS.DCON_GetUserType_WS('trycatch');
        try
        {
        DCON_Configuration_WS.DCON_Restore_DCSettings_WS('trycatch');
        }catch(exception ex){}
        DCON_Configuration_WS.DCON_Retrieve_Display_Tags_WS(u.Id);      
        DCON_Configuration_WS.DCON_Retrieve_Settings_WS(u.Id);
        DCON_Configuration_WS.DCON_Retrieve_User_Settings_WS(u.Id);
        u.SVMXC__Dispatch_Console_Settings__c = null;
        update u;
        DCON_Configuration_WS.DCON_Retrieve_User_Settings_WS(u.Id);
        DCON_Configuration_WS.SVMX_StringMap s = new DCON_Configuration_WS.SVMX_StringMap('UT','UTVALUE');
        DCON_Configuration_WS.DCON_Update_User_Settings_WS(u.Id, DefaultSetting.Body.toString());
        DCON_Configuration_WS.DCON_Restore_DCSettings_WS(u.Id);
        DCON_Configuration_WS.DCON_GetLocalDate_WS(u.Id);
        DCON_Configuration_WS.SVMX_BuisnessHourAttribute bh = new DCON_Configuration_WS.SVMX_BuisnessHourAttribute('Friday', string.valueof(system.now().time()), string.valueof(system.now().time().addhours(1)));
        list<BusinessHours> BHour = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'Test';
        team.SVMXC__Active__c = true;
        insert team;
        
        SVMXC__Territory__c Teritory = new SVMXC__Territory__c();
        Teritory.SVMXC__Territory_s_Business_Hours__c  = BHour[0].Id;
        insert Teritory;
        
        SVMXC__Service_Group_Members__c Tech = new SVMXC__Service_Group_Members__c();
        Tech.Name = 'Test Tech';
        Tech.SVMXC__Active__c = true;
        Tech.SVMXC__Service_Group__c = team.Id;
        Tech.SVMXC__Working_Hours__c = BHour[0].Id;
        Tech.SVMXC__Salesforce_User__c = Userinfo.getUserId();
        Tech.SVMXC__Service_Territory__c = Teritory.Id;
        insert Tech;
        
        
        DCON_Configuration_WS.GetEvent_BuisnessHour(Tech.Id);
        DCON_Configuration_WS.getDateTimeInTimezone(system.now().dateGmt(), system.now().timeGmt(), 'Asia/Calcutta');
        DCON_Configuration_WS.EventExistinBusinessHour(Tech.Id,system.now(), 'Asia/Calcutta');
        Tech.SVMXC__Working_Hours__c = null;
        update Tech;
        DCON_Configuration_WS.EventExistinBusinessHour(Tech.Id,system.now(), 'Asia/Calcutta');
        
        string K;
        string v;
        DCON_Configuration_WS.SVMX_StringMap stringMap = new DCON_Configuration_WS.SVMX_StringMap(k,v);
        DCON_Configuration_WS.SVMX_Response res = new DCON_Configuration_WS.SVMX_Response();
        DCON_Configuration_WS.SVMX_getDispatcherList_WS(stringMap);
        
        // For super dispatcher
        SVMXC__Dispatcher_Access__c dispatcherAccess = new SVMXC__Dispatcher_Access__c();
        dispatcherAccess.SVMXC__Territory__c = Teritory.Id;
        dispatcherAccess.SVMXC__Dispatcher__c = u.Id;
        insert dispatcherAccess;
        
        User u2 = [SELECT id,LocaleSidKey from User where id != :UserInfo.getUserId() limit 1];
        SVMXC__Dispatcher_Access__c dispatcherAccess2 = new SVMXC__Dispatcher_Access__c();
        dispatcherAccess2.SVMXC__Territory__c = Teritory.Id;
        dispatcherAccess2.SVMXC__Service_Team__c = team.Id;
        dispatcherAccess2.SVMXC__Dispatcher__c = u2.Id;
        insert dispatcherAccess2;
        
        stringMap.Value = u.Id;
        DCON_Configuration_WS.SVMX_getDispatcherList_WS(stringMap);
        dispatcherAccess.SVMXC__Service_Team__c = team.Id;
        dispatcherAccess.SVMXC__Territory__c = null;
        update dispatcherAccess;
        DCON_Configuration_WS.SVMX_getDispatcherList_WS(stringMap);
        dispatcherAccess.SVMXC__Territory__c = Teritory.Id;
        update dispatcherAccess;
        DCON_Configuration_WS.SVMX_getDispatcherList_WS(stringMap);
        DCON_Configuration_WS.DCON_getObjectFieldList_WS();
        
        stringMap.ValueList = new List<String>{u2.Id};
        stringMap.dcSetting = new Dcon_DeployUserSetting.DCUserSettings();
        DCON_Configuration_WS.SVMX_DeployUIConfiguration_WS(stringMap);
        
        DCON_Configuration_WS.DCON_GetAllTimeZone_WS(u.Id);
        
        DCON_Configuration_WS.SVMX_StringMap dcUserSetReq = new DCON_Configuration_WS.SVMX_StringMap('UT','UTVALUE');      
        dcUserSetReq.woViewType = 'All';
        dcUserSetReq.columnInfo = 'Account';
        dcUserSetReq.Key = 'work';
        dcUserSetReq.Value = '1234';
        dcUserSetReq.ValueList = new List<String>{u2.Id};
        dcUserSetReq.dcSetting = new Dcon_DeployUserSetting.DCUserSettings();
        dcUserSetReq.Value = u.Id;
        DCON_Configuration_WS.SVMX_Response resp = DCON_DeployUserSetting.deploySelectivelyDCUSerSetting(dcUserSetReq);
        
        test.stoptest();
    } 
    
    static testMethod void DCON_EventWarnings_WS_UT1()
    {
        list<BusinessHours> BHour = [ select WednesdayStartTime, WednesdayEndTime, TuesdayStartTime, TuesdayEndTime, ThursdayStartTime, ThursdayEndTime, SundayStartTime, SundayEndTime, SaturdayStartTime, SaturdayEndTime, MondayStartTime, MondayEndTime, IsDefault, IsActive, Id, FridayStartTime, FridayEndTime from BusinessHours where isDefault = true limit 1];
        
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'Test';
        team.SVMXC__Active__c = true;
        insert team;
        
        SVMXC__Territory__c Teritory = new SVMXC__Territory__c();
        Teritory.SVMXC__Territory_s_Business_Hours__c  = BHour[0].Id;
        insert Teritory;
        
        SVMXC__Service_Group_Members__c Tech = new SVMXC__Service_Group_Members__c();
        Tech.Name = 'Test Tech';
        Tech.SVMXC__Active__c = true;
        Tech.SVMXC__Service_Group__c = team.Id;
        //Tech.SVMXC__Working_Hours__c = BHour[0].Id;
        Tech.SVMXC__Salesforce_User__c = Userinfo.getUserId();
        Tech.SVMXC__Service_Territory__c = Teritory.Id;
        insert Tech;
        
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c();
        objWorkOrder = new SVMXC__Service_Order__c (
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c = 'Medium',
                                            SVMXC__Order_Type__c= 'Field Service',
                                            SVMXC__Scheduled_Date__c = system.today(),
                                            SVMXC__Locked_By_DC__c = true,
                                            SVMXC__Group_Member__c = Tech.Id,
                                            SVMXC__Preferred_Business_Hours__c = BHour[0].Id
                                            );
        insert objWorkOrder;
        
        SVMXC__SVMX_Event__c SMAX_Event = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2016-02-12 00:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2016-02-12 06:00:00'),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2016-02-12 20:00:00').addHours(1),
                                                    SVMXC__Technician__c = Tech.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id,
                                                    SVMXC__Service_Duration__c = 60
                                                    );
        insert SMAX_Event;
        
        DCON_Configuration_WS.DCEventWarningReq_WP request = new DCON_Configuration_WS.DCEventWarningReq_WP();
        DCON_Configuration_WS.DCEventWarningResp_WP response = new DCON_Configuration_WS.DCEventWarningResp_WP();
        DateTime eventStartDT = SMAX_Event.SVMXC__StartDateTime__c;
        DateTime eventEndDT = SMAX_Event.SVMXC__EndDateTime__c;
        request.TechId = Tech.Id;
        request.WorkOrderId = objWorkOrder.Id;
        request.timeZone = 'Asia/Calcutta';
        request.EventStartDateTime = eventStartDT;
        request.EventEndDateTime = eventEndDT;
        request.isMachineAccessHrsEnabled = true;
        request.isBusinessHrsEnabled = true;
        
        try
        {
            response = DCON_Configuration_WS.DCON_EventWarnings_WS(request);
        }
        catch(exception ex){}
    }
}