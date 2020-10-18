@isTest
private class DCON_DoubleBooking_UT {   
    static testMethod void checkDoublebookingforTech_UT_Test()
    {
        DCON_DoubleBooking objDCON_DoubleBooking = new DCON_DoubleBooking();
        SVMXC__Service_Order__c objWorkOrder;
        SVMXC__Service_Group__c objTeam;
        SVMXC__Territory__c objTerritory;
        SVMXC__Service_Group_Members__c objTechnician = new SVMXC__Service_Group_Members__c();
        List<SVMXC__Service_Group_Members__c> lstObjTech;
        
        List<Event> lstObjSFEvents = new List<Event>();
        List<SVMXC__SVMX_Event__c> lstObjSVMXEvents = new List<SVMXC__SVMX_Event__c>();
        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        objTeam = new SVMXC__Service_Group__c (Name = 'TEAM 1');
        insert objTeam;
            
        objTerritory = new SVMXC__Territory__c (
                                            Name = 'TERRITORY 1'
                                            );
        insert objTerritory;
        
        objTechnician = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 1' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true
                                            );
                                                
            
                           
            SVMXC__Service_Group_Members__c objTechnician2 = new SVMXC__Service_Group_Members__c (
                                                Name = 'TECH 2' ,
                                                SVMXC__Latitude__c = 40.739582 , 
                                                SVMXC__Longitude__c = -73.980772, 
                                                SVMXC__Service_Group__c = objTeam.Id ,
                                                SVMXC__Service_Territory__c = objTerritory.Id,
                                                SVMXC__Enable_Scheduling__c = true,
                                                SVMXC__Salesforce_User__c = objUser.Id
                                                );
            insert objTechnician2;                 
            insert objTechnician;
            
            objWorkOrder = new SVMXC__Service_Order__c (
                                                SVMXC__Latitude__c = 40.739582 , 
                                                SVMXC__Longitude__c = -73.980772, 
                                                SVMXC__Order_Status__c = 'Open',
                                                SVMXC__Priority__c = 'Medium',
                                                SVMXC__Order_Type__c= 'Field Service',
                                                SVMXC__Scheduled_Date__c = system.today(),
                                                SVMXC__Locked_By_DC__c = true,
                                                SVMXC__Group_Member__c = objTechnician.Id
                                                );
            insert objWorkOrder;
            
            
            
            Event e1 = new Event(ActivityDate = Date.valueOf('2010-02-11 00:00:00'),
                                    StartDateTime = Datetime.valueOf('2010-02-11 01:00:00') ,
                                    ActivityDateTime = Datetime.valueOf('2010-02-11 01:00:00'), 
                                    DurationInMinutes = 60, Subject = 'test', OwnerId = objUser.Id, 
                                    WhatId=objWorkOrder.Id, Description='Test Desc');
            Event e2 = new Event(ActivityDate = Date.valueOf('2010-02-12 00:00:00'), 
                                    StartDateTime = Datetime.valueOf('2010-02-12 01:00:00') ,
                                    ActivityDateTime = Datetime.valueOf('2010-02-12 01:00:00'), 
                                    DurationInMinutes = 60, Subject = 'test', OwnerId = objTechnician.Id, 
                                    WhatId=objWorkOrder.Id, Description='Test Desc');
            Event e3 = new Event(ActivityDate = Date.valueOf('2010-02-11 00:00:00'),
                                    StartDateTime = Datetime.valueOf('2010-02-11 01:00:00') ,
                                    ActivityDateTime = Datetime.valueOf('2010-02-11 01:00:00'), 
                                    DurationInMinutes = 60, Subject = 'test', OwnerId = objUser.Id, 
                                    WhatId=objWorkOrder.Id, Description='Test Desc');
            insert e3;
            Event e4 = new Event(ActivityDate = Date.valueOf('2010-02-19 00:00:00'),
                                    StartDateTime = Datetime.valueOf('2010-02-19 01:00:00') ,
                                    ActivityDateTime = Datetime.valueOf('2010-02-19 01:00:00'), 
                                    DurationInMinutes = 1440, Subject = 'testAllDay', OwnerId = objUser.Id,isAlldayevent=true, 
                                    WhatId=objWorkOrder.Id, Description='Test Desc');
            Event e5 = new Event(ActivityDate = Date.valueOf('2010-02-19 00:00:00'),
                                    StartDateTime = Date.valueOf('2010-02-19 00:00:00') ,
                                    ActivityDateTime = Date.valueOf('2010-02-19 00:00:00') , 
                                    DurationInMinutes = 1440, Subject = 'testAllDay1', OwnerId = objUser.Id,isAlldayevent=true, 
                                    WhatId=objWorkOrder.Id, Description='Test Desc');                           
            insert e5;                              
            lstObjSFEvents.add(e1);
            lstObjSFEvents.add(e2);
            lstObjSFEvents.add(e4);
            
            
             SVMXC__SVMX_Event__c SMAX_Event1 = new SVMXC__SVMX_Event__c(
                                                        SVMXC__ActivityDate__c = Date.valueOf('2010-02-12 00:00:00'), 
                                                        SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'), 
                                                        SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'),
                                                        SVMXC__DurationInMinutes__c = 60,
                                                        SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-12 01:00:00').addHours(1),
                                                        SVMXC__Technician__c = objTechnician.Id,
                                                        SVMXC__WhatId__c = objWorkOrder.Id
                                                        );
            SVMXC__SVMX_Event__c SMAX_Event2 = new SVMXC__SVMX_Event__c(
                                                        SVMXC__ActivityDate__c = Date.valueOf('2010-02-19 00:00:00'), 
                                                        SVMXC__ActivityDateTime__c = Date.valueOf('2010-02-19 00:00:00'), 
                                                        SVMXC__StartDateTime__c = Date.valueOf('2010-02-19 00:00:00'),
                                                        SVMXC__DurationInMinutes__c = 1440,
                                                        SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-12 01:00:00').addHours(1),
                                                        SVMXC__Technician__c = objTechnician.Id,
                                                        SVMXC__WhatId__c = objWorkOrder.Id,
                                                        SVMXC__isAlldayEvent__c =true
                                                        );                                          
            lstObjSVMXEvents.add(SMAX_Event1);
            
            //insert lstObjSFEvents;
            insert lstObjSVMXEvents;
            DCON_DoubleBooking.checkDoublebookingforTech(lstObjSFEvents, Userinfo.getTimeZone().getID(), User.SObjectType.getDescribe().getKeyPrefix());
            DCON_DoubleBooking.GetExistingSFSVMXEvents(lstObjSFEvents,Userinfo.getTimeZone().getID(),User.SObjectType.getDescribe().getKeyPrefix());
            DCON_DoubleBooking.getmapTechEvent(lstObjSFEvents,lstObjSVMXEvents);
            DCON_DoubleBooking.getOverlappingEventDetails(e3,DCON_DoubleBooking.GetExistingSFSVMXEvents(lstObjSFEvents,Userinfo.getTimeZone().getID(),User.SObjectType.getDescribe().getKeyPrefix()), Userinfo.getTimeZone().getID());
            DCON_DoubleBooking.getTechName(User.SObjectType.getDescribe().getKeyPrefix());
            
            
    }
    
    static testMethod void checkDoublebookingforTech_UT_Test1()
    {
        
        SVMXC__Service_Order__c objWorkOrder;
        SVMXC__Service_Group__c objTeam;
        SVMXC__Territory__c objTerritory;
        SVMXC__Service_Group_Members__c objTechnician = new SVMXC__Service_Group_Members__c();
        List<SVMXC__Service_Group_Members__c> lstObjTech;
        
        List<Event> lstObjSFEvents = new List<Event>();
        List<SVMXC__SVMX_Event__c> lstObjSVMXEvents = new List<SVMXC__SVMX_Event__c>();
        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        objTeam = new SVMXC__Service_Group__c (Name = 'TEAM 1');
        insert objTeam;
            
        objTerritory = new SVMXC__Territory__c (
                                            Name = 'TERRITORY 1'
                                            );
        insert objTerritory;
        
        objTechnician = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 3' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true
                                            );
                                                
            
                           
        SVMXC__Service_Group_Members__c objTechnician2 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 4' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__Salesforce_User__c = objUser.Id
                                            );
        insert objTechnician2;                 
        insert objTechnician;
        
        objWorkOrder = new SVMXC__Service_Order__c (
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c = 'Medium',
                                            SVMXC__Order_Type__c= 'Field Service',
                                            SVMXC__Scheduled_Date__c = system.today(),
                                            SVMXC__Locked_By_DC__c = true,
                                            SVMXC__Group_Member__c = objTechnician.Id
                                            );
        insert objWorkOrder;
        
        
        
        Event e1 = new Event(ActivityDate = Date.valueOf('2010-02-11 00:00:00'),
                                StartDateTime = Datetime.valueOf('2010-02-11 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-11 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = objUser.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        Event e2 = new Event(ActivityDate = Date.valueOf('2010-02-12 00:00:00'), 
                                StartDateTime = Datetime.valueOf('2010-02-12 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-12 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = objTechnician.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        Event e3 = new Event(ActivityDate = Date.valueOf('2010-02-11 00:00:00'),
                                StartDateTime = Datetime.valueOf('2010-02-11 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-11 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = objUser.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        insert e3;
           
        lstObjSFEvents.add(e1);
        lstObjSFEvents.add(e2);
        
            
         SVMXC__SVMX_Event__c SMAX_Event1 = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-12 00:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-12 01:00:00').addHours(1),
                                                    SVMXC__Technician__c = objTechnician.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id
                                                    );
        lstObjSVMXEvents.add(SMAX_Event1);
        
        //insert lstObjSFEvents;
        insert lstObjSVMXEvents;
        List<SVMXC__ServiceMax_Config_Data__c> setting = (new INTF_ConfigSync()).getSettings(new set<string>(), new set<string>(), new set<string>{'DCON001_SET025','DCON001_SET026','DCON001_SET029','DCON001_SET028'}, '');
        
        for (integer i=0; i<setting.size();i++)
        {
            if(setting[i].SVMXC__Setting_Unique_ID__c == 'DCON001_SET026' || setting[i].SVMXC__Setting_Unique_ID__c == 'DCON001_SET028')
                setting[i].SVMXC__Internal_Value__c = 'false';
            if(setting[i].SVMXC__Setting_Unique_ID__c == 'DCON001_SET025' || setting[i].SVMXC__Setting_Unique_ID__c == 'DCON001_SET027')
                setting[i].SVMXC__Internal_Value__c = 'Disallow';
        }
        
        if(setting.size()>0)
            update setting;
    
        DCON_DoubleBooking objDCON_DoubleBooking = new DCON_DoubleBooking();
        system.debug(logginglevel.warn,'    ++++ setting:  '+setting);
        DCON_DoubleBooking.checkDoublebookingforTech(lstObjSFEvents, Userinfo.getTimeZone().getID(), User.SObjectType.getDescribe().getKeyPrefix());
        DCON_DoubleBooking.GetExistingSFSVMXEvents(lstObjSFEvents,Userinfo.getTimeZone().getID(),User.SObjectType.getDescribe().getKeyPrefix());
        DCON_DoubleBooking.getmapTechEvent(lstObjSFEvents,lstObjSVMXEvents);
        DCON_DoubleBooking.getOverlappingEventDetails(e3,DCON_DoubleBooking.GetExistingSFSVMXEvents(lstObjSFEvents,Userinfo.getTimeZone().getID(),User.SObjectType.getDescribe().getKeyPrefix()), Userinfo.getTimeZone().getID());
        DCON_DoubleBooking.getTechName(User.SObjectType.getDescribe().getKeyPrefix());
    }

    static testMethod void checkDoublebookingforTech_UT_Test2()
    {
        
        SVMXC__Service_Order__c objWorkOrder;
        SVMXC__Service_Group__c objTeam;
        SVMXC__Territory__c objTerritory;
        SVMXC__Service_Group_Members__c objTechnician = new SVMXC__Service_Group_Members__c();
        List<SVMXC__Service_Group_Members__c> lstObjTech;
        
        List<Event> lstObjSFEvents = new List<Event>();
        List<SVMXC__SVMX_Event__c> lstObjSVMXEvents = new List<SVMXC__SVMX_Event__c>();
        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        objTeam = new SVMXC__Service_Group__c (Name = 'TEAM 1');
        insert objTeam;
            
        objTerritory = new SVMXC__Territory__c (
                                            Name = 'TERRITORY 1'
                                            );
        insert objTerritory;
        
        objTechnician = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 3' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true
                                            );
                                                
            
                           
        SVMXC__Service_Group_Members__c objTechnician2 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 4' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__Salesforce_User__c = objUser.Id
                                            );
        insert objTechnician2;                 
        insert objTechnician;
        
        objWorkOrder = new SVMXC__Service_Order__c (
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c = 'Medium',
                                            SVMXC__Order_Type__c= 'Field Service',
                                            SVMXC__Scheduled_Date__c = system.today(),
                                            SVMXC__Locked_By_DC__c = true,
                                            SVMXC__Group_Member__c = objTechnician.Id
                                            );
        insert objWorkOrder;
        
        
        
        Event e1 = new Event(ActivityDate = Date.valueOf('2010-02-11 00:00:00'),
                                StartDateTime = Datetime.valueOf('2010-02-11 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-11 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = objUser.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        Event e2 = new Event(ActivityDate = Date.valueOf('2010-02-12 00:00:00'), 
                                StartDateTime = Datetime.valueOf('2010-02-12 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-12 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = objTechnician.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        Event e3 = new Event(ActivityDate = Date.valueOf('2010-02-11 00:00:00'),
                                StartDateTime = Datetime.valueOf('2010-02-11 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-11 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = objUser.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        insert e3;
           
        lstObjSFEvents.add(e1);
        lstObjSFEvents.add(e2);
        
            
         SVMXC__SVMX_Event__c SMAX_Event1 = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-12 00:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-12 01:00:00').addHours(1),
                                                    SVMXC__Technician__c = objTechnician.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id
                                                    );
        lstObjSVMXEvents.add(SMAX_Event1);
        
        //insert lstObjSFEvents;
        insert lstObjSVMXEvents;
        List<SVMXC__ServiceMax_Config_Data__c> setting = (new INTF_ConfigSync()).getSettings(new set<string>(), new set<string>(), new set<string>{'DCON001_SET025','DCON001_SET026','DCON001_SET029','DCON001_SET028'}, '');
        
        for (integer i=0; i<setting.size();i++)
        {
            if(setting[i].SVMXC__Setting_Unique_ID__c == 'DCON001_SET026' || setting[i].SVMXC__Setting_Unique_ID__c == 'DCON001_SET028')
                setting[i].SVMXC__Internal_Value__c = 'true';
            if(setting[i].SVMXC__Setting_Unique_ID__c == 'DCON001_SET025' || setting[i].SVMXC__Setting_Unique_ID__c == 'DCON001_SET027')
                setting[i].SVMXC__Internal_Value__c = 'Disallow';
        }
        
        if(setting.size()>0)
         update setting;
        
        system.debug(logginglevel.warn,'    ++++ setting:  '+setting);
        DCON_DoubleBooking objDCON_DoubleBooking1 = new DCON_DoubleBooking();
        DCON_DoubleBooking.checkDoublebookingforTech(lstObjSFEvents, Userinfo.getTimeZone().getID(), User.SObjectType.getDescribe().getKeyPrefix());
        DCON_DoubleBooking.GetExistingSFSVMXEvents(lstObjSFEvents,Userinfo.getTimeZone().getID(),User.SObjectType.getDescribe().getKeyPrefix());
        DCON_DoubleBooking.getmapTechEvent(lstObjSFEvents,lstObjSVMXEvents);
        DCON_DoubleBooking.getOverlappingEventDetails(e3,DCON_DoubleBooking.GetExistingSFSVMXEvents(lstObjSFEvents,Userinfo.getTimeZone().getID(),User.SObjectType.getDescribe().getKeyPrefix()), Userinfo.getTimeZone().getID());
        DCON_DoubleBooking.getTechName(User.SObjectType.getDescribe().getKeyPrefix());
    }

    static testMethod void checkDoublebookingforTech_UT_Test3()
    {
        SVMXC__Service_Order__c objWorkOrder;
        SVMXC__Service_Group__c objTeam;
        SVMXC__Territory__c objTerritory;
        SVMXC__Service_Group_Members__c objTechnician = new SVMXC__Service_Group_Members__c();
        List<SVMXC__Service_Group_Members__c> lstObjTech;
        
        List<Event> lstObjSFEvents = new List<Event>();
        List<SVMXC__SVMX_Event__c> lstObjSVMXEvents = new List<SVMXC__SVMX_Event__c>();
        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        objTeam = new SVMXC__Service_Group__c (Name = 'TEAM 1');
        insert objTeam;
            
        objTerritory = new SVMXC__Territory__c (
                                            Name = 'TERRITORY 1'
                                            );
        insert objTerritory;
        
        objTechnician = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 3' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true
                                            );
                                                
            
                           
        SVMXC__Service_Group_Members__c objTechnician2 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 4' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__Salesforce_User__c = objUser.Id
                                            );
        insert objTechnician2;                 
        insert objTechnician;
        
        objWorkOrder = new SVMXC__Service_Order__c (
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c = 'Medium',
                                            SVMXC__Order_Type__c= 'Field Service',
                                            SVMXC__Scheduled_Date__c = system.today(),
                                            SVMXC__Locked_By_DC__c = true,
                                            SVMXC__Group_Member__c = objTechnician.Id
                                            );
        insert objWorkOrder;
        
        
        
        Event e1 = new Event(ActivityDate = Date.valueOf('2010-02-11 00:00:00'),
                                StartDateTime = Datetime.valueOf('2010-02-11 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-11 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = objUser.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        Event e2 = new Event(ActivityDate = Date.valueOf('2010-02-12 00:00:00'), 
                                StartDateTime = Datetime.valueOf('2010-02-12 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-12 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = objTechnician.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        Event e3 = new Event(ActivityDate = Date.valueOf('2010-02-11 00:00:00'),
                                StartDateTime = Datetime.valueOf('2010-02-11 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-11 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = objUser.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        insert e3;
           
        lstObjSFEvents.add(e1);
        lstObjSFEvents.add(e2);
        
            
         SVMXC__SVMX_Event__c SMAX_Event1 = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-12 00:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-12 01:00:00').addHours(1),
                                                    SVMXC__Technician__c = objTechnician.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id
                                                    );
        lstObjSVMXEvents.add(SMAX_Event1);
        
        //insert lstObjSFEvents;
        insert lstObjSVMXEvents;
        List<SVMXC__ServiceMax_Config_Data__c> setting = (new INTF_ConfigSync()).getSettings(new set<string>(), new set<string>(), new set<string>{'DCON001_SET025','DCON001_SET026','DCON001_SET029','DCON001_SET028'}, '');
        
        
        for (integer i=0; i<setting.size();i++)
        {
            if(setting[i].SVMXC__Setting_Unique_ID__c == 'DCON001_SET028' )
                setting[i].SVMXC__Internal_Value__c = 'true';
            if(setting[i].SVMXC__Setting_Unique_ID__c == 'DCON001_SET026' )
                setting[i].SVMXC__Internal_Value__c = 'false';
            if(setting[i].SVMXC__Setting_Unique_ID__c == 'DCON001_SET025')
                setting[i].SVMXC__Internal_Value__c = 'Disallow';
            if(setting[i].SVMXC__Setting_Unique_ID__c == 'DCON001_SET027')
                setting[i].SVMXC__Internal_Value__c = 'Allow';
        }
        
        if(setting.size()>0)
            update setting;
        
        //DCON_DoubleBooking objDCON_DoubleBooking2 = new DCON_DoubleBooking();
        system.debug(logginglevel.warn,'    ++++ setting:  '+setting);
        DCON_DoubleBooking.checkDoublebookingforTech(lstObjSFEvents, Userinfo.getTimeZone().getID(), User.SObjectType.getDescribe().getKeyPrefix());
        DCON_DoubleBooking.GetExistingSFSVMXEvents(lstObjSFEvents,Userinfo.getTimeZone().getID(),User.SObjectType.getDescribe().getKeyPrefix());
        DCON_DoubleBooking.getmapTechEvent(lstObjSFEvents,lstObjSVMXEvents);
        DCON_DoubleBooking.getOverlappingEventDetails(e3,DCON_DoubleBooking.GetExistingSFSVMXEvents(lstObjSFEvents,Userinfo.getTimeZone().getID(),User.SObjectType.getDescribe().getKeyPrefix()), Userinfo.getTimeZone().getID());
        DCON_DoubleBooking.getTechName(User.SObjectType.getDescribe().getKeyPrefix());
        
    }
        
    static testMethod void checkDoublebookingforTech_UT_Test4()
    {
        SVMXC__Service_Order__c objWorkOrder;
        SVMXC__Service_Group__c objTeam;
        SVMXC__Territory__c objTerritory;
        SVMXC__Service_Group_Members__c objTechnician = new SVMXC__Service_Group_Members__c();
        List<SVMXC__Service_Group_Members__c> lstObjTech;
        
        List<Event> lstObjSFEvents = new List<Event>();
        List<SVMXC__SVMX_Event__c> lstObjSVMXEvents = new List<SVMXC__SVMX_Event__c>();
        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        objTeam = new SVMXC__Service_Group__c (Name = 'TEAM 1');
        insert objTeam;
            
        objTerritory = new SVMXC__Territory__c (
                                            Name = 'TERRITORY 1'
                                            );
        insert objTerritory;
        
        objTechnician = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 3' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true
                                            );
                                                
            
                           
        SVMXC__Service_Group_Members__c objTechnician2 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 4' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__Salesforce_User__c = objUser.Id
                                            );
        insert objTechnician2;                 
        insert objTechnician;
        
        objWorkOrder = new SVMXC__Service_Order__c (
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c = 'Medium',
                                            SVMXC__Order_Type__c= 'Field Service',
                                            SVMXC__Scheduled_Date__c = system.today(),
                                            SVMXC__Locked_By_DC__c = true,
                                            SVMXC__Group_Member__c = objTechnician.Id
                                            );
        insert objWorkOrder;
        
        
        
        Event e1 = new Event(ActivityDate = Date.valueOf('2010-02-11 00:00:00'),
                                StartDateTime = Datetime.valueOf('2010-02-11 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-11 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = objUser.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        Event e2 = new Event(ActivityDate = Date.valueOf('2010-02-12 00:00:00'), 
                                StartDateTime = Datetime.valueOf('2010-02-12 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-12 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = objTechnician.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        Event e3 = new Event(ActivityDate = Date.valueOf('2010-02-11 00:00:00'),
                                StartDateTime = Datetime.valueOf('2010-02-11 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-11 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = objUser.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        insert e3;
           
        lstObjSFEvents.add(e1);
        lstObjSFEvents.add(e2);
        
            
         SVMXC__SVMX_Event__c SMAX_Event1 = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-12 00:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-12 01:00:00').addHours(1),
                                                    SVMXC__Technician__c = objTechnician.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id
                                                    );
        lstObjSVMXEvents.add(SMAX_Event1);
        
        //insert lstObjSFEvents;
        insert lstObjSVMXEvents;
        List<SVMXC__ServiceMax_Config_Data__c> setting = (new INTF_ConfigSync()).getSettings(new set<string>(), new set<string>(), new set<string>{'DCON001_SET025','DCON001_SET026','DCON001_SET029','DCON001_SET028'}, '');
        
        for (integer i=0; i<setting.size();i++)
        {
            if(setting[i].SVMXC__Setting_Unique_ID__c == 'DCON001_SET026' )
                setting[i].SVMXC__Internal_Value__c = 'true';
            if(setting[i].SVMXC__Setting_Unique_ID__c == 'DCON001_SET027')
                setting[i].SVMXC__Internal_Value__c = 'Allow';
        }
        
        if(setting.size()>0)
            update setting;
        
        DCON_DoubleBooking objDCON_DoubleBooking3 = new DCON_DoubleBooking();
        system.debug(logginglevel.warn,'    ++++ setting:  '+setting);
        DCON_DoubleBooking.checkDoublebookingforTech(lstObjSFEvents, Userinfo.getTimeZone().getID(), User.SObjectType.getDescribe().getKeyPrefix());
        DCON_DoubleBooking.GetExistingSFSVMXEvents(lstObjSFEvents,Userinfo.getTimeZone().getID(),User.SObjectType.getDescribe().getKeyPrefix());
        DCON_DoubleBooking.getmapTechEvent(lstObjSFEvents,lstObjSVMXEvents);
        DCON_DoubleBooking.getOverlappingEventDetails(e3,DCON_DoubleBooking.GetExistingSFSVMXEvents(lstObjSFEvents,Userinfo.getTimeZone().getID(),User.SObjectType.getDescribe().getKeyPrefix()), Userinfo.getTimeZone().getID());
        DCON_DoubleBooking.getTechName(User.SObjectType.getDescribe().getKeyPrefix());
    }
    
    static testMethod void checkDoublebookingforTech_UT_Test5()
    {
        SVMXC__Service_Order__c objWorkOrder;
        SVMXC__Service_Group__c objTeam;
        SVMXC__Territory__c objTerritory;
        SVMXC__Service_Group_Members__c objTechnician = new SVMXC__Service_Group_Members__c();
        List<SVMXC__Service_Group_Members__c> lstObjTech;
        
        List<Event> lstObjSFEvents = new List<Event>();
        List<SVMXC__SVMX_Event__c> lstObjSVMXEvents = new List<SVMXC__SVMX_Event__c>();
        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        objTeam = new SVMXC__Service_Group__c (Name = 'TEAM 1');
        insert objTeam;
            
        objTerritory = new SVMXC__Territory__c (
                                            Name = 'TERRITORY 1'
                                            );
        insert objTerritory;
        
        objTechnician = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 3' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true
                                            );
                                                
            
                           
        SVMXC__Service_Group_Members__c objTechnician2 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 4' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__Salesforce_User__c = objUser.Id
                                            );
        insert objTechnician2;                 
        insert objTechnician;
        
        objWorkOrder = new SVMXC__Service_Order__c (
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c = 'Medium',
                                            SVMXC__Order_Type__c= 'Field Service',
                                            SVMXC__Scheduled_Date__c = system.today(),
                                            SVMXC__Locked_By_DC__c = true,
                                            SVMXC__Group_Member__c = objTechnician.Id
                                            );
        insert objWorkOrder;
        
        
        
        Event e1 = new Event(ActivityDate = Date.valueOf('2010-02-11 00:00:00'),
                                StartDateTime = Datetime.valueOf('2010-02-11 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-11 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = objUser.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        Event e2 = new Event(ActivityDate = Date.valueOf('2010-02-12 00:00:00'), 
                                StartDateTime = Datetime.valueOf('2010-02-12 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-12 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = objTechnician.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        Event e3 = new Event(ActivityDate = Date.valueOf('2010-02-11 00:00:00'),
                                StartDateTime = Datetime.valueOf('2010-02-11 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-11 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = objUser.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        insert e3;
           
        lstObjSFEvents.add(e1);
        lstObjSFEvents.add(e2);
        
            
         SVMXC__SVMX_Event__c SMAX_Event1 = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-12 00:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-12 01:00:00').addHours(1),
                                                    SVMXC__Technician__c = objTechnician.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id
                                                    );
        lstObjSVMXEvents.add(SMAX_Event1);
        
        //insert lstObjSFEvents;
        insert lstObjSVMXEvents;
        List<SVMXC__ServiceMax_Config_Data__c> setting = (new INTF_ConfigSync()).getSettings(new set<string>(), new set<string>(), new set<string>{'DCON001_SET025','DCON001_SET026','DCON001_SET029','DCON001_SET028'}, '');
        
        for (integer i=0; i<setting.size();i++)
        {
            if(setting[i].SVMXC__Setting_Unique_ID__c == 'DCON001_SET028' )
                setting[i].SVMXC__Internal_Value__c = 'true';
            if(setting[i].SVMXC__Setting_Unique_ID__c == 'DCON001_SET026' )
                setting[i].SVMXC__Internal_Value__c = 'false';
            if(setting[i].SVMXC__Setting_Unique_ID__c == 'DCON001_SET025')
                setting[i].SVMXC__Internal_Value__c = 'Disallow';
            if(setting[i].SVMXC__Setting_Unique_ID__c == 'DCON001_SET027')
                setting[i].SVMXC__Internal_Value__c = 'Allow';
        }
        
        if(setting.size()>0)
            update setting;
        
        DCON_DoubleBooking objDCON_DoubleBooking4 = new DCON_DoubleBooking();
        system.debug(logginglevel.warn,'    ++++ setting:  '+setting);
        DCON_DoubleBooking.checkDoublebookingforTech(lstObjSFEvents, Userinfo.getTimeZone().getID(), User.SObjectType.getDescribe().getKeyPrefix());
        DCON_DoubleBooking.GetExistingSFSVMXEvents(lstObjSFEvents,Userinfo.getTimeZone().getID(),User.SObjectType.getDescribe().getKeyPrefix());
        DCON_DoubleBooking.getmapTechEvent(lstObjSFEvents,lstObjSVMXEvents);
        DCON_DoubleBooking.getOverlappingEventDetails(e3,DCON_DoubleBooking.GetExistingSFSVMXEvents(lstObjSFEvents,Userinfo.getTimeZone().getID(),User.SObjectType.getDescribe().getKeyPrefix()), Userinfo.getTimeZone().getID());
        DCON_DoubleBooking.getTechName(User.SObjectType.getDescribe().getKeyPrefix());
        DCON_DoubleBooking.getWOEvents(lstObjSFEvents);
        DCON_DoubleBooking.getWOEvents(lstObjSVMXEvents);
    }
    
        static testMethod void checkDoublebookingforTech_UT_Test6()
    {
        SVMXC__Service_Order__c objWorkOrder;
        SVMXC__Service_Group__c objTeam;
        SVMXC__Territory__c objTerritory;
        SVMXC__Service_Group_Members__c objTechnician = new SVMXC__Service_Group_Members__c();
        List<SVMXC__Service_Group_Members__c> lstObjTech;
        
        List<Event> lstObjSFEvents = new List<Event>();
        List<SVMXC__SVMX_Event__c> lstObjSVMXEvents = new List<SVMXC__SVMX_Event__c>();
        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        objTeam = new SVMXC__Service_Group__c (Name = 'TEAM 1');
        insert objTeam;
            
        objTerritory = new SVMXC__Territory__c (
                                            Name = 'TERRITORY 1'
                                            );
        insert objTerritory;
        
        objTechnician = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 3' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true
                                            );
                                                
            
                           
        SVMXC__Service_Group_Members__c objTechnician2 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 4' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__Salesforce_User__c = objUser.Id
                                            );
        insert objTechnician2;                 
        insert objTechnician;
        
        objWorkOrder = new SVMXC__Service_Order__c (
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c = 'Medium',
                                            SVMXC__Order_Type__c= 'Field Service',
                                            SVMXC__Scheduled_Date__c = system.today(),
                                            SVMXC__Locked_By_DC__c = true,
                                            SVMXC__Group_Member__c = objTechnician.Id
                                            );
        insert objWorkOrder;
        
        
        
        Event e1 = new Event(ActivityDate = Date.valueOf('2010-02-11 00:00:00'),
                                StartDateTime = Datetime.valueOf('2010-02-11 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-11 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = objUser.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        Event e2 = new Event(ActivityDate = Date.valueOf('2010-02-12 00:00:00'), 
                                StartDateTime = Datetime.valueOf('2010-02-12 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-12 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = objTechnician.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        Event e3 = new Event(ActivityDate = Date.valueOf('2010-02-11 00:00:00'),
                                StartDateTime = Datetime.valueOf('2010-02-11 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-11 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = objUser.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        insert e3;
           
        lstObjSFEvents.add(e1);
        lstObjSFEvents.add(e2);
        
            
         SVMXC__SVMX_Event__c SMAX_Event1 = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-12 00:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-12 01:00:00').addHours(1),
                                                    SVMXC__Technician__c = objTechnician.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id
                                                    );
        lstObjSVMXEvents.add(SMAX_Event1);
        
        //insert lstObjSFEvents;
        insert lstObjSVMXEvents;
        List<SVMXC__ServiceMax_Config_Data__c> setting = (new INTF_ConfigSync()).getSettings(new set<string>(), new set<string>(), new set<string>{'DCON001_SET025','DCON001_SET026','DCON001_SET029','DCON001_SET028'}, '');
        
        for (integer i=0; i<setting.size();i++)
        {
            if(setting[i].SVMXC__Setting_Unique_ID__c == 'DCON001_SET028' )
                setting[i].SVMXC__Internal_Value__c = 'true';
            if(setting[i].SVMXC__Setting_Unique_ID__c == 'DCON001_SET026' )
                setting[i].SVMXC__Internal_Value__c = 'true';
            if(setting[i].SVMXC__Setting_Unique_ID__c == 'DCON001_SET025')
                setting[i].SVMXC__Internal_Value__c = 'Disallow';
            if(setting[i].SVMXC__Setting_Unique_ID__c == 'DCON001_SET027')
                setting[i].SVMXC__Internal_Value__c = 'Allow';
        }
        
        if(setting.size()>0)
            update setting;
    
        DCON_DoubleBooking objDCON_DoubleBooking5 = new DCON_DoubleBooking();
        system.debug(logginglevel.warn,'    ++++ setting:  '+setting);
        
        DCON_DoubleBooking.checkDoublebookingforTech(lstObjSFEvents, Userinfo.getTimeZone().getID(), User.SObjectType.getDescribe().getKeyPrefix());
        DCON_DoubleBooking.GetExistingSFSVMXEvents(lstObjSFEvents,Userinfo.getTimeZone().getID(),User.SObjectType.getDescribe().getKeyPrefix());
        DCON_DoubleBooking.getmapTechEvent(lstObjSFEvents,lstObjSVMXEvents);
        DCON_DoubleBooking.getOverlappingEventDetails(e3,DCON_DoubleBooking.GetExistingSFSVMXEvents(lstObjSFEvents,Userinfo.getTimeZone().getID(),User.SObjectType.getDescribe().getKeyPrefix()), Userinfo.getTimeZone().getID());
        DCON_DoubleBooking.getTechName(User.SObjectType.getDescribe().getKeyPrefix());
        DCON_DoubleBooking.getWOEvents(lstObjSFEvents);
        DCON_DoubleBooking.getWOEvents(lstObjSVMXEvents);
    }
    
    static testMethod void checkDoublebookingforTech_UT_Test7()
    {
        SVMXC__Service_Order__c objWorkOrder;
        SVMXC__Service_Group__c objTeam;
        SVMXC__Territory__c objTerritory;
        SVMXC__Service_Group_Members__c objTechnician = new SVMXC__Service_Group_Members__c();
        List<SVMXC__Service_Group_Members__c> lstObjTech;
        
        List<Event> lstObjSFEvents = new List<Event>();
        List<SVMXC__SVMX_Event__c> lstObjSVMXEvents = new List<SVMXC__SVMX_Event__c>();
        User objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        objTeam = new SVMXC__Service_Group__c (Name = 'TEAM 1');
        insert objTeam;
            
        objTerritory = new SVMXC__Territory__c (
                                            Name = 'TERRITORY 1'
                                            );
        insert objTerritory;
        
        objTechnician = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 3' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true
                                            );
                                                
            
                           
        SVMXC__Service_Group_Members__c objTechnician2 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 4' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__Salesforce_User__c = objUser.Id
                                            );
        insert objTechnician2;                 
        insert objTechnician;
        
        objWorkOrder = new SVMXC__Service_Order__c (
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c = 'Medium',
                                            SVMXC__Order_Type__c= 'Field Service',
                                            SVMXC__Scheduled_Date__c = system.today(),
                                            SVMXC__Locked_By_DC__c = true,
                                            SVMXC__Group_Member__c = objTechnician.Id
                                            );
        insert objWorkOrder;
        
        
        
        Event e1 = new Event(ActivityDate = Date.valueOf('2010-02-11 00:00:00'),
                                StartDateTime = Datetime.valueOf('2010-02-11 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-11 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = objUser.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        Event e2 = new Event(ActivityDate = Date.valueOf('2010-02-12 00:00:00'), 
                                StartDateTime = Datetime.valueOf('2010-02-12 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-12 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = objTechnician.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        Event e3 = new Event(ActivityDate = Date.valueOf('2010-02-11 00:00:00'),
                                StartDateTime = Datetime.valueOf('2010-02-11 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-11 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = objUser.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        insert e3;
           
        lstObjSFEvents.add(e1);
        lstObjSFEvents.add(e2);
        
            
         SVMXC__SVMX_Event__c SMAX_Event1 = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-12 00:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-12 01:00:00').addHours(1),
                                                    SVMXC__Technician__c = objTechnician.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id
                                                    );
        lstObjSVMXEvents.add(SMAX_Event1);
        
        //insert lstObjSFEvents;
        insert lstObjSVMXEvents;
        List<SVMXC__ServiceMax_Config_Data__c> setting = (new INTF_ConfigSync()).getSettings(new set<string>(), new set<string>(), new set<string>{'DCON001_SET025','DCON001_SET026','DCON001_SET029','DCON001_SET028'}, '');
        
        Event e4 = new Event(ActivityDate = Date.valueOf('2010-02-11 00:00:00'),
                                StartDateTime = Datetime.valueOf('2010-02-11 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-11 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = objUser.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        insert e4;
        Event e5 = new Event(ActivityDate = Date.valueOf('2010-02-11 00:00:00'),
                                StartDateTime = Datetime.valueOf('2010-02-11 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-11 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = objTechnician.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        
        lstObjSFEvents.clear();
        lstObjSFEvents.add(e5);
        SVMXC__SVMX_Event__c SMAX_Event2 = new SVMXC__SVMX_Event__c(
                                                SVMXC__ActivityDate__c = Date.valueOf('2010-02-12 00:00:00'), 
                                                SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'), 
                                                SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'),
                                                SVMXC__DurationInMinutes__c = 60,
                                                SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-12 01:00:00').addHours(1),
                                                SVMXC__Technician__c = objTechnician.Id,
                                                SVMXC__WhatId__c = objWorkOrder.Id
                                                );
        lstObjSVMXEvents.clear();
        lstObjSVMXEvents.add(SMAX_Event2);
        
        //insert lstObjSFEvents;
        insert lstObjSVMXEvents;
        for (integer i=0; i<setting.size();i++)
        {
            if(setting[i].SVMXC__Setting_Unique_ID__c == 'DCON001_SET028' )
                setting[i].SVMXC__Internal_Value__c = 'true';
            if(setting[i].SVMXC__Setting_Unique_ID__c == 'DCON001_SET026' )
                setting[i].SVMXC__Internal_Value__c = 'true';
            if(setting[i].SVMXC__Setting_Unique_ID__c == 'DCON001_SET025')
                setting[i].SVMXC__Internal_Value__c = 'Disallow';
            if(setting[i].SVMXC__Setting_Unique_ID__c == 'DCON001_SET027')
                setting[i].SVMXC__Internal_Value__c = 'Disallow';
        }
        
        if(setting.size()>0)
            update setting;
        
        try
        {
            DCON_DoubleBooking objDCON_DoubleBooking6 = new DCON_DoubleBooking();
            system.debug(logginglevel.warn,'    ++++ setting:  '+setting);
            DCON_DoubleBooking.checkDoublebookingforTech(lstObjSFEvents, Userinfo.getTimeZone().getID(), User.SObjectType.getDescribe().getKeyPrefix());
            DCON_DoubleBooking.GetExistingSFSVMXEvents(lstObjSFEvents,Userinfo.getTimeZone().getID(),User.SObjectType.getDescribe().getKeyPrefix());
            
            DCON_DoubleBooking.getmapTechEvent(lstObjSFEvents,lstObjSVMXEvents);
            DCON_DoubleBooking.getOverlappingEventDetails(e3,DCON_DoubleBooking.GetExistingSFSVMXEvents(lstObjSFEvents,Userinfo.getTimeZone().getID(),User.SObjectType.getDescribe().getKeyPrefix()), Userinfo.getTimeZone().getID());
            DCON_DoubleBooking.getTechName(User.SObjectType.getDescribe().getKeyPrefix());
            DCON_DoubleBooking.getWOEvents(lstObjSFEvents);
            DCON_DoubleBooking.getWOEvents(lstObjSVMXEvents);
        }
        catch(exception ex){} 
    }       
}