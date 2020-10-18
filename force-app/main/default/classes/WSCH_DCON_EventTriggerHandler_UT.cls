@isTest(SeeAllData=true)
public with sharing class WSCH_DCON_EventTriggerHandler_UT {
    Public  WSCH_DCON_EventTriggerHandler_UT ()
    {
        List<SVMXC__ServiceMax_Config_Data__c> lst1 = [select id from SVMXC__ServiceMax_Config_Data__c where SVMXC__Setting_Unique_ID__c IN ('GLOB001_GBL007','GLOB001_GBL014','EVER007_SET001','IPRD003_SET007','IPRD003_SET003', 'EVER007_SET002') ];
        
        for(SVMXC__ServiceMax_Config_Data__c l: lst1)
        {
            l.SVMXC__Display_Value__c = 'false';
            l.SVMXC__Internal_Value__c = 'false';
            l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        }
        if(lst1 != null && lst1.size() > 0)
        update lst1; 
        List<SVMXC__ServiceMax_Config_Data__c> lst = [select id, SVMXC__Setting_Unique_ID__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Setting_Unique_ID__c IN ('DCON005_SET006','DCON005_SET011')];
        for(SVMXC__ServiceMax_Config_Data__c l: lst)
            {
               if(l.SVMXC__Setting_Unique_ID__c.equals('DCON005_SET006'))
                {
                    l.SVMXC__Display_Value__c = 'Enabled';
                    l.SVMXC__Internal_Value__c = 'Enabled';
                    l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                }
                else if
                (l.SVMXC__Setting_Unique_ID__c.equals('DCON005_SET011'))
                {
                    l.SVMXC__Display_Value__c = 'ready for dispatch';
                    l.SVMXC__Internal_Value__c = 'ready for dispatch';
                    l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                } 
            }
        if(lst != null && lst.size() > 0)
           update lst;

    }
    static
    {
        WSCH_DCON_EventTriggerHandler_UT obj = new WSCH_DCON_EventTriggerHandler_UT();
    }
    static testMethod void WSCH_DCON_EventTriggerHandler_test() {
        account acc = new account();
        acc.name ='ABC';
        insert acc;
        Test.startTest();
        SVMXC__Territory__c territory1 = new SVMXC__Territory__c();
        territory1.name = 'UK Region';
        territory1.SVMXC__Optimizer_External_ID__c = 'UK01';
        territory1.SVMXC__Optimizer_Last_Timestamp__c='';
        insert territory1;   
        
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'testTeam';
        
        insert team;
        
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'John';
        technician.SVMXC__Optimizer_External_ID__c = 'TM001';
        technician.SVMXC__Service_Group__c  = team.Id;
        technician.SVMXC__Service_Territory__c = territory1.Id;
        technician.SVMXC__Salesforce_User__c = UserInfo.getUserId();
        
        insert technician;
        //START: MEM filed updates
        String usid=UserInfo.getUserId();
        User u = [SELECT id from User where id =: UserInfo.getUserId()];
        Account account = new Account(
                                        Name ='Account',
                                        ShippingStreet='ABC',
                                        ShippingCity='PQR ',
                                        ShippingState = 'XYZ',
                                        ShippingPostalCode='111',
                                        ShippingCountry='XYZ',
                                        BillingStreet='ABC',
                                        BillingCity='PQR ',
                                        BillingState = 'XYZ',
                                        BillingPostalCode='111',
                                        BillingCountry='XYZ'
                                        ); 
        insert account;
        
        SVMXC__Service_Order__c svo = new SVMXC__Service_Order__c (
                                            SVMXC__Company__c = account.Id , 
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c ='Medium',
                                            SVMXC__Order_Type__c='Field Service',
                                            SVMXC__Locked_By_DC__c = true,
                                            SVMXC__SM_Scheduling_Options__c = 'JDM Enabled, LJS Disabled',
                                            SVMXC__SM_Estimated_Duration__c = 7200
                                            );
         upsert svo;
         
        event sfEvent = new event();
        sfEvent.WhatId = svo.Id;
        sfEvent.StartDateTime = DateTime.now();
        sfEvent.EndDateTime = DateTime.now().addHours(1);
        sfEvent.ownerid = userinfo.getuserid();
        sfEvent.SVMXC__Service_Duration__c = 3600;
        sfEvent.DurationInMinutes = 60;
        sfEvent.SVMXC__Driving_Time__c = 0;
        sfEvent.SVMXC__Overhead_Time_Before__c = 0;
        sfEvent.SVMXC__Driving_Time_Home__c = 0;
        sfEvent.SVMXC__Overhead_Time_After__c = 0;
        sfEvent.WhatId = svo.Id;
        insert sfEvent;
        
        event sfEvent2 = new event();
        sfEvent2.WhatId = svo.Id;
        sfEvent2.StartDateTime = DateTime.now();
        sfEvent2.EndDateTime = DateTime.now().addHours(1);
        sfEvent2.ownerid = userinfo.getuserid();
        sfEvent2.SVMXC__Service_Duration__c = 3600;
        sfEvent2.DurationInMinutes = 60;
        sfEvent2.SVMXC__Driving_Time__c = 0;
        sfEvent2.SVMXC__Overhead_Time_Before__c = 0;
        sfEvent2.SVMXC__Driving_Time_Home__c = 0;
        sfEvent2.SVMXC__Overhead_Time_After__c = 0;
        sfEvent2.WhatId = svo.Id;
        
        
        SVMXC__SVMX_Event__c svmxEvent= new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-12 00:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-12 01:00:00').addHours(1),
                                                    SVMXC__Technician__c =  technician.Id,
                                                    SVMXC__Service_Duration__c = 3600,
                                                    SVMXC__WhatId__c = svo.Id,
                                                    SVMXC__Service_Order__c = svo.Id,
                                                    SVMXC__Driving_Time__c = 0,
                                                    SVMXC__Overhead_Time_Before__c = 0,
                                                    SVMXC__Driving_Time_Home__c = 0,
                                                    SVMXC__Overhead_Time_After__c = 0
                                                    );

        insert svmxEvent;
        
        SVMXC__SVMX_Event__c svmxEvent1= new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-12 00:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-12 01:00:00').addHours(1),
                                                    SVMXC__Technician__c =  technician.Id,
                                                    SVMXC__Service_Duration__c = 3600,
                                                    SVMXC__WhatId__c = svo.Id,
                                                    SVMXC__Service_Order__c = svo.Id,
                                                    SVMXC__Driving_Time__c = 0,
                                                    SVMXC__Overhead_Time_Before__c = 0,
                                                    SVMXC__Driving_Time_Home__c = 0,
                                                    SVMXC__Overhead_Time_After__c = 0
                                                    );

        list<SVMXC__SVMX_Event__c> lstSVMXEvent = new list<SVMXC__SVMX_Event__c>();
        list<SVMXC__SVMX_Event__c> lstSVMXEvent1 = new list<SVMXC__SVMX_Event__c>();
        list<Event> lstSFEvent = new list<event>();
        list<Event> lstSFEvent1 = new list<event>();
        lstSVMXEvent.add(svmxEvent);
        lstSFEvent.add(sfEvent);
        
        lstSVMXEvent1.add(svmxEvent1);
        lstSFEvent1.add(sfEvent2);
                
        event sfEvent1 = new event();
        sfEvent1.StartDateTime = DateTime.now();
        sfEvent1.EndDateTime = DateTime.now().addHours(1);
        sfEvent1.ownerid = userinfo.getuserid();
        sfEvent1.SVMXC__Service_Duration__c = 3600;
        sfEvent1.DurationInMinutes = 60;
        sfEvent1.SVMXC__Driving_Time__c = 0;
        sfEvent1.SVMXC__Overhead_Time_Before__c = 0;
        sfEvent1.SVMXC__Driving_Time_Home__c = 0;
        sfEvent1.SVMXC__Overhead_Time_After__c = 0;
        sfEvent1.WhatId = svo.Id;
        lstSFEvent.add(sfEvent1);
        
         
        //START: JDM field updates
        WSCH_DCON_EventTriggerHandler.handleSFEventOnInsert(lstSFEvent1, null);
        WSCH_DCON_EventTriggerHandler.handleSMAXEventOnInsert(lstSVMXEvent1, null);
        
        WSCH_DCON_EventTriggerHandler.handleSFEventOnUpdate(lstSFEvent, lstSFEvent, null);
        WSCH_DCON_EventTriggerHandler.handleSFEventOnDelete(lstSFEvent, null);
        
        //WSCH_DCON_EventTriggerHandler.handleSMAXEventOnUpdate(lstSVMXEvent, lstSVMXEvent, null);
        //WSCH_DCON_EventTriggerHandler.handleSMAXEventOnDelete(lstSVMXEvent, null);
        //END: JDM field updates
        Test.stopTest();
    }   
    }