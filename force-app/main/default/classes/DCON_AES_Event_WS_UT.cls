@isTest
Private class DCON_AES_Event_WS_UT 
{
    Public  DCON_AES_Event_WS_UT ()
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
        List<SVMXC__ServiceMax_Config_Data__c> lst = [select id, SVMXC__Setting_Unique_ID__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Setting_Unique_ID__c IN ('DCON001_SET038','DCON001_SET039','DCON001_SET040','DCON001_SET041','DCON001_SET042','DCON001_SET043','DCON001_SET044','DCON001_SET045','DCON001_SET046','DCON001_SET047','DCON005_SET006')];
        for(SVMXC__ServiceMax_Config_Data__c l: lst)
            {
                if (l.SVMXC__Setting_Unique_ID__c.equals('DCON001_SET038'))
                {
                    l.SVMXC__Display_Value__c = 'SVMXC__Dispatch_Response__c';
                    l.SVMXC__Internal_Value__c = 'SVMXC__Dispatch_Response__c';
                    l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                }   
                else if
                (l.SVMXC__Setting_Unique_ID__c.equals('DCON001_SET039'))
                {
                    l.SVMXC__Display_Value__c = 'SVMXC__Order_Status__c';
                    l.SVMXC__Internal_Value__c = 'SVMXC__Order_Status__c';
                    l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                }   
                else if
                (l.SVMXC__Setting_Unique_ID__c.equals('DCON001_SET040'))
                {
                    l.SVMXC__Display_Value__c = 'SVMXC__Purpose_of_Visit__c';
                    l.SVMXC__Internal_Value__c = 'SVMXC__Purpose_of_Visit__c';
                    l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                }
                else if
                (l.SVMXC__Setting_Unique_ID__c.equals('DCON001_SET041'))
                {
                    l.SVMXC__Display_Value__c = 'SVMXC__Customer_Down__c';
                    l.SVMXC__Internal_Value__c = 'SVMXC__Customer_Down__c';
                    l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                }
                else if
                (l.SVMXC__Setting_Unique_ID__c.equals('DCON001_SET042'))
                {
                    l.SVMXC__Display_Value__c = 'SVMXC__Finished_Onsite_Date_Time__c';
                    l.SVMXC__Internal_Value__c = 'SVMXC__Finished_Onsite_Date_Time__c';
                    l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                }
                else if
                (l.SVMXC__Setting_Unique_ID__c.equals('DCON001_SET043'))
                {
                    l.SVMXC__Display_Value__c = 'SVMXC__Scheduled_Date__c';
                    l.SVMXC__Internal_Value__c = 'SVMXC__Scheduled_Date__c';
                    l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                }
                else if
                (l.SVMXC__Setting_Unique_ID__c.equals('DCON001_SET044'))
                {
                    l.SVMXC__Display_Value__c = 'SVMXC__Problem_Description__c';
                    l.SVMXC__Internal_Value__c = 'SVMXC__Problem_Description__c';
                    l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                }
                else if
                (l.SVMXC__Setting_Unique_ID__c.equals('DCON001_SET045'))
                {
                    l.SVMXC__Display_Value__c = 'SVMXC__City__c';
                    l.SVMXC__Internal_Value__c = 'SVMXC__City__c';
                    l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                }
                else if
                (l.SVMXC__Setting_Unique_ID__c.equals('DCON001_SET046'))
                {
                    l.SVMXC__Display_Value__c = 'SVMXC__Contact__c';
                    l.SVMXC__Internal_Value__c = 'SVMXC__Contact__c';
                    l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                }
                else if
                (l.SVMXC__Setting_Unique_ID__c.equals('DCON001_SET047'))
                {
                    l.SVMXC__Display_Value__c = 'SVMXC__Country__c';
                    l.SVMXC__Internal_Value__c = 'SVMXC__Country__c';
                    l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                }
                else if
                (l.SVMXC__Setting_Unique_ID__c.equals('DCON005_SET006'))
                {
                    l.SVMXC__Display_Value__c = 'Enabled';
                    l.SVMXC__Internal_Value__c = 'Enabled';
                    l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                }
            }
        if(lst != null && lst.size() > 0)
           update lst;
    }
    static
    {
        DCON_AES_Event_WS_UT obj = new DCON_AES_Event_WS_UT();
    }
    
    static testMethod void DCON_AES_Event_WS_UT_Test()
    {
        DCON_AES_Event_WS.loadDCsetting();
        DCON_AES_Event_WS obj = new DCON_AES_Event_WS();
        User u = [SELECT id from User where id = :UserInfo.getUserId()];
        List<String> TechList = new List<String>();
        
        /*Account objAccount = new Account(
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
        insert objAccount;

        system.assert(objAccount!=null, true);

        Contact objContact = new Contact(LastName='Last',AccountId =objAccount.Id);
        insert objContact;

        system.assert(objContact!=null, true);

        Case objCase = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                        ContactId = objContact.Id,
                                        AccountId = objAccount.Id                                         
                                        ); 
        insert objCase; 

        system.assertEquals(objCase.ContactId, objContact.Id);
        system.assertEquals(objCase.AccountId, objAccount.Id);*/
        
        SVMXC__Service_Group__c SerTeam = new SVMXC__Service_Group__c();
        SerTeam.Name='TeamABC';
        Upsert SerTeam;
        
        List<BusinessHours> lstdefaultbh = [SELECT FridayEndTime,FridayStartTime,Id,IsActive,IsDefault,MondayEndTime,MondayStartTime,Name,SaturdayEndTime,SaturdayStartTime,SundayEndTime,SundayStartTime,ThursdayEndTime,ThursdayStartTime,TimeZoneSidKey,TuesdayEndTime,TuesdayStartTime,WednesdayEndTime,WednesdayStartTime FROM BusinessHours WHERE IsDefault = true];
        
        BusinessHours defaultbh = lstdefaultbh.get(0);  
        
        /*SVMXC__Territory__c objTerritory = new SVMXC__Territory__c (
                                            Name = 'TERRITORY 1', SVMXC__Territory_s_Business_Hours__c = defaultbh.Id
                                            );
        insert objTerritory;*/
        
        List<SVMXC__Service_Group_Members__c> TechList123 = new List<SVMXC__Service_Group_Members__c>();
        SVMXC__Service_Group_Members__c Tech1 = new SVMXC__Service_Group_Members__c();
        Tech1.Name='Tech1';
        Tech1.SVMXC__Service_Group__c=SerTeam.Id;
        Tech1.SVMXC__Enable_Scheduling__c=true;
        Tech1.SVMXC__Active__c = true;
        Tech1.SVMXC__Working_Hours__c = defaultbh.Id;
        
        TechList123.add(Tech1);
        upsert TechList123;
        
        List<String> lsttechId = new List<String>();
        lsttechId.add(String.valueOf(Tech1.Id));
        
        for(SVMXC__Service_Group_Members__c p : TechList123)
        {
            TechList.add(p.Id);
        }
                
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c (
                                            /*SVMXC__Case__c = objCase.Id ,
                                            SVMXC__Company__c = objAccount.Id , 
                                            SVMXC__Contact__c =objContact.Id,*/ 
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c = 'Medium',
                                            SVMXC__Order_Type__c= 'Field Service',
                                            SVMXC__Scheduled_Date__c = system.today(),
                                            SVMXC__Locked_By_DC__c = true,
                                            //SVMXC__Group_Member__c = Tech1.Id,
                                            SVMXC__Preferred_Business_Hours__c = defaultbh.Id,
                                            SVMXC__SM_Estimated_Duration__c = 7200      
                                            );
        insert objWorkOrder;
        
        
        List<SVMXC__SVMX_Event__c> lstObjSVMXEvents = new List<SVMXC__SVMX_Event__c>();
        Date date1 = System.today();
        
        SVMXC__SVMX_Event__c SMAX_Event1 = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = date1.addDays(3), 
                                                    SVMXC__ActivityDateTime__c = DateTime.newInstanceGmt(date1.addDays(1),Time.newInstance(8,45,0,0)), 
                                                    SVMXC__StartDateTime__c = DateTime.newInstanceGmt(date1.addDays(1),Time.newInstance(8,45,0,0)),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__Technician__c = Tech1.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id
                                                    );
        SVMXC__SVMX_Event__c SMAX_Event2 = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = date1.addDays(3), 
                                                    SVMXC__ActivityDateTime__c = DateTime.newInstanceGmt(date1.addDays(1),Time.newInstance(12,45,0,0)), 
                                                    SVMXC__StartDateTime__c = DateTime.newInstanceGmt(date1.addDays(1),Time.newInstance(12,45,0,0)),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__Technician__c = Tech1.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id
                                                    );
        SVMXC__SVMX_Event__c SMAX_Event3 = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = date1.addDays(3), 
                                                    SVMXC__ActivityDateTime__c = DateTime.newInstanceGmt(date1.addDays(1),Time.newInstance(17,45,0,0)), 
                                                    SVMXC__StartDateTime__c = DateTime.newInstanceGmt(date1.addDays(1),Time.newInstance(17,45,0,0)),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__Technician__c = Tech1.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id
                                                    );
        SVMXC__SVMX_Event__c SMAX_Event4 = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = date1.addDays(5), 
                                                    SVMXC__ActivityDateTime__c = DateTime.newInstanceGmt(date1.addDays(5),Time.newInstance(0,0,0,0)), 
                                                    SVMXC__StartDateTime__c = DateTime.newInstanceGmt(date1.addDays(5),Time.newInstance(0,0,0,0)),
                                                    SVMXC__EndDateTime__c = DateTime.newInstanceGmt(date1.addDays(5),Time.newInstance(0,0,0,0)),
                                                    SVMXC__DurationInMinutes__c = 2880,
                                                    SVMXC__Technician__c = Tech1.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id,
                                                    SVMXC__IsAllDayEvent__c = true
                                                    );
                                                    
        lstObjSVMXEvents.add(SMAX_Event1);
        lstObjSVMXEvents.add(SMAX_Event2);
        lstObjSVMXEvents.add(SMAX_Event3);
        lstObjSVMXEvents.add(SMAX_Event4);
        
        //yatheesh
        //insert lstObjSVMXEvents;
        
        list<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue = new list<DCON_Configuration_WS.SVMX_StringMap>();
        lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '0'));
        lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '0'));
        lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '0'));
        DCON_Configuration_WS.SVMX_StringMap datTest1 = new DCON_Configuration_WS.SVMX_StringMap('bb', 'DATE');
        datTest1.DateValue = system.today();
        datTest1.Value = 'DATE';
        lstKeyValue.add(datTest1);
        DCON_Configuration_WS.SVMX_StringMap datTest2 = new DCON_Configuration_WS.SVMX_StringMap('aa', 'DATETIME');
        datTest2.Value = 'DATETIME';
        datTest2.DateTimeValue = system.now();
        lstKeyValue.add(datTest2); 
        List<Event> lstAESEvents = new List<Event>(); 
        Event e5 = new Event(ActivityDate = date1.addDays(-2), 
                                StartDateTime = DateTime.newInstanceGmt(date1.addDays(-2),Time.newInstance(9,45,0,0)),
                                ActivityDateTime = DateTime.newInstanceGmt(date1.addDays(-2),Time.newInstance(9,45,0,0)), 
                                DurationInMinutes = 2520, Subject = 'AES JOB', OwnerId = Tech1.Id, 
                                WhatId=objWorkOrder.Id, Description='test AES JOB');    
        e5.IsAllDayEvent = false;
        e5.SVMXC__Driving_Time_Home__c = 10;
        e5.SVMXC__Overhead_Time_After__c = 0;
        e5.SVMXC__Overhead_Time_Before__c = 0;
        e5.SVMXC__Break_Time_Total__c = 0;
        e5.SVMXC__Driving_Time__c = 10;   
        e5.SVMXC__Service_Duration__c = 151200;
        lstAESEvents.add(e5);
        
        String timeZone = 'Asia/Kolkata';
        Integer eventMinDuration = 60;
        boolean isTechWorkingHrsEnabled = true;
        boolean isMachineWorkingHrsEnabled = false;
        boolean isOverlappingEnabled = false;
        
        DCON_AES_Event_WS.AES_Request req1 = new DCON_AES_Event_WS.AES_Request();
        DCON_AES_Event_WS.AES_Request req;
        DCON_AES_Event_WS.AES_Response resp = new DCON_AES_Event_WS.AES_Response();
                  
              
        req = new DCON_AES_Event_WS.AES_Request(String.valueOf(u.Id),lstAESEvents,timeZone,lsttechId,eventMinDuration,true,true,isOverlappingEnabled,true,lstKeyValue,false,false);
        DCON_AES_Event_WS.DCON_AES_Create_Events_WS(req);
        
        req = new DCON_AES_Event_WS.AES_Request(String.valueOf(u.Id),lstAESEvents,timeZone,lsttechId,eventMinDuration,true,true,isOverlappingEnabled,false,lstKeyValue,false,false);
        DCON_AES_Event_WS.DCON_AES_Create_Events_WS(req);
        
        req = new DCON_AES_Event_WS.AES_Request(String.valueOf(u.Id),lstAESEvents,timeZone,lsttechId,eventMinDuration,false,false,false,false,lstKeyValue,false,false);
        DCON_AES_Event_WS.DCON_AES_Create_Events_WS(req);
        
                
    }
    static testMethod void DCON_AES_Event_WS_UT_Test1()
    {
        DCON_AES_Event_WS obj = new DCON_AES_Event_WS();
        User u = [SELECT id from User where id = :UserInfo.getUserId()];
        List<String> TechList = new List<String>();
        
        /*Account objAccount = new Account(
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
        insert objAccount;

        system.assert(objAccount!=null, true);

        Contact objContact = new Contact(LastName='Last',AccountId =objAccount.Id);
        insert objContact;

        system.assert(objContact!=null, true);

        Case objCase = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                        ContactId = objContact.Id,
                                        AccountId = objAccount.Id                                         
                                        ); 
        insert objCase; 

        system.assertEquals(objCase.ContactId, objContact.Id);
        system.assertEquals(objCase.AccountId, objAccount.Id);*/
        
        SVMXC__Service_Group__c SerTeam = new SVMXC__Service_Group__c();
        SerTeam.Name='TeamABC';
        Upsert SerTeam;
        
        List<BusinessHours> lstdefaultbh = [SELECT FridayEndTime,FridayStartTime,Id,IsActive,IsDefault,MondayEndTime,MondayStartTime,Name,SaturdayEndTime,SaturdayStartTime,SundayEndTime,SundayStartTime,ThursdayEndTime,ThursdayStartTime,TimeZoneSidKey,TuesdayEndTime,TuesdayStartTime,WednesdayEndTime,WednesdayStartTime FROM BusinessHours WHERE IsDefault = true];
        
        BusinessHours defaultbh = lstdefaultbh.get(0);  
        
        /*SVMXC__Territory__c objTerritory = new SVMXC__Territory__c (
                                            Name = 'TERRITORY 1', SVMXC__Territory_s_Business_Hours__c = defaultbh.Id
                                            );
        insert objTerritory;*/
        
        List<SVMXC__Service_Group_Members__c> TechList123 = new List<SVMXC__Service_Group_Members__c>();
        SVMXC__Service_Group_Members__c Tech1 = new SVMXC__Service_Group_Members__c();
        Tech1.Name='Tech1';
        Tech1.SVMXC__Service_Group__c=SerTeam.Id;
        Tech1.SVMXC__Enable_Scheduling__c=true;
        Tech1.SVMXC__Active__c = true;
        Tech1.SVMXC__Working_Hours__c = defaultbh.Id;
        
        TechList123.add(Tech1);
        upsert TechList123;
        List<String> lsttechId = new List<String>();
        lsttechId.add(String.valueOf(Tech1.Id));
        
        for(SVMXC__Service_Group_Members__c p : TechList123)
        {
            TechList.add(p.Id);
        }
                
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c (
                                            /*SVMXC__Case__c = objCase.Id ,
                                            SVMXC__Company__c = objAccount.Id , 
                                            SVMXC__Contact__c =objContact.Id,*/ 
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c = 'Medium',
                                            SVMXC__Order_Type__c= 'Field Service',
                                            SVMXC__Scheduled_Date__c = system.today(),
                                            SVMXC__Locked_By_DC__c = true,
                                            SVMXC__Group_Member__c = Tech1.Id,
                                            SVMXC__Preferred_Business_Hours__c = defaultbh.Id,
                                            SVMXC__SM_Estimated_Duration__c = 7200
                                            );
        insert objWorkOrder;
        
        
        List<Event> lstObjSFEvents = new List<Event>();
        Date date1 = System.today();
        Event e1 = new Event(ActivityDate = date1,
                                StartDateTime = DateTime.newInstanceGmt(date1,Time.newInstance(8,45,0,0)),
                                ActivityDateTime = DateTime.newInstanceGmt(date1,Time.newInstance(8,45,0,0)), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = u.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        Event e2 = new Event(ActivityDate = date1, 
                                StartDateTime = DateTime.newInstanceGmt(date1,Time.newInstance(12,0,0,0)),
                                ActivityDateTime = DateTime.newInstanceGmt(date1,Time.newInstance(12,0,0,0)), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = u.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        Event e3 = new Event(ActivityDate = date1, 
                                StartDateTime = DateTime.newInstanceGmt(date1,Time.newInstance(17,45,0,0)),
                                ActivityDateTime = DateTime.newInstanceGmt(date1,Time.newInstance(17,45,0,0)), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = u.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        Event e4 = new Event(ActivityDate = date1.addDays(1), 
                                StartDateTime = DateTime.newInstanceGmt(date1.addDays(1),Time.newInstance(0,0,0,0)),
                                ActivityDateTime = DateTime.newInstanceGmt(date1.addDays(1),Time.newInstance(0,0,0,0)), 
                                DurationInMinutes = 1440, Subject = 'test', OwnerId = u.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc',IsAllDayEvent=true);                            
        lstObjSFEvents.add(e1);
        lstObjSFEvents.add(e2);
        lstObjSFEvents.add(e3);
        lstObjSFEvents.add(e4);
        
        //yatheesh
        //insert lstObjSFEvents;
        
        list<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue = new list<DCON_Configuration_WS.SVMX_StringMap>();
        lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '0'));
        lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '0'));
        lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '0'));
        DCON_Configuration_WS.SVMX_StringMap datTest1 = new DCON_Configuration_WS.SVMX_StringMap('bb', 'DATE');
        datTest1.DateValue = system.today();
        datTest1.Value = 'DATE';
        lstKeyValue.add(datTest1);
        DCON_Configuration_WS.SVMX_StringMap datTest2 = new DCON_Configuration_WS.SVMX_StringMap('aa', 'DATETIME');
        datTest2.Value = 'DATETIME';
        datTest2.DateTimeValue = system.now();
        lstKeyValue.add(datTest2); 
        List<Event> lstAESEvents = new List<Event>(); 
        Event e5 = new Event(ActivityDate = date1.addDays(-2), 
                                StartDateTime = DateTime.newInstanceGmt(date1.addDays(-2),Time.newInstance(9,45,0,0)),
                                ActivityDateTime = DateTime.newInstanceGmt(date1.addDays(-2),Time.newInstance(9,45,0,0)), 
                                DurationInMinutes = 2520, Subject = 'AES JOB', OwnerId = u.Id, 
                                WhatId=objWorkOrder.Id, Description='test AES JOB');    
        e5.IsAllDayEvent = false;
        e5.SVMXC__Driving_Time_Home__c = 10;
        e5.SVMXC__Overhead_Time_After__c = 0;
        e5.SVMXC__Overhead_Time_Before__c = 0;
        e5.SVMXC__Break_Time_Total__c = 0;
        e5.SVMXC__Driving_Time__c = 10;   
        e5.SVMXC__Service_Duration__c = 151200;
        lstAESEvents.add(e5);
        
        String timeZone = 'Asia/Kolkata';
        Integer eventMinDuration = 60;
        boolean isTechWorkingHrsEnabled = true;
        boolean isMachineWorkingHrsEnabled = false;
        boolean isOverlappingEnabled = false;
        
        DCON_AES_Event_WS.AES_Request req1 = new DCON_AES_Event_WS.AES_Request();
        DCON_AES_Event_WS.AES_Request req;
        req = new DCON_AES_Event_WS.AES_Request(String.valueOf(u.Id),lstAESEvents,timeZone, lsttechId,eventMinDuration,isTechWorkingHrsEnabled,isMachineWorkingHrsEnabled,isOverlappingEnabled,false,lstKeyValue,true,false);
        DCON_AES_Event_WS.AES_Response resp = new DCON_AES_Event_WS.AES_Response();
        
        DCON_AES_Event_WS.DCON_AES_Create_Events_WS(req);
   
        req = new DCON_AES_Event_WS.AES_Request(String.valueOf(u.Id),lstAESEvents,timeZone,lsttechId,eventMinDuration,false,true,true,false,lstKeyValue,true,true);
        DCON_AES_Event_WS.DCON_AES_Create_Events_WS(req);
        
                 
    }
    static testMethod void DCON_AES_Event_WS_UT_Test2()
    {
        DCON_AES_Event_WS.loadDCsetting();
        DCON_AES_Event_WS obj = new DCON_AES_Event_WS();
        User u = [SELECT id from User where id = :UserInfo.getUserId()];
        List<String> TechList = new List<String>();
        
        /*Account objAccount = new Account(
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
        insert objAccount;

        system.assert(objAccount!=null, true);

        Contact objContact = new Contact(LastName='Last',AccountId =objAccount.Id);
        insert objContact;

        system.assert(objContact!=null, true);

        Case objCase = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                        ContactId = objContact.Id,
                                        AccountId = objAccount.Id                                         
                                        ); 
        insert objCase; 

        system.assertEquals(objCase.ContactId, objContact.Id);
        system.assertEquals(objCase.AccountId, objAccount.Id);*/
        
        SVMXC__Service_Group__c SerTeam = new SVMXC__Service_Group__c();
        SerTeam.Name='TeamABC';
        Upsert SerTeam;
        
        List<BusinessHours> lstdefaultbh = [SELECT FridayEndTime,FridayStartTime,Id,IsActive,IsDefault,MondayEndTime,MondayStartTime,Name,SaturdayEndTime,SaturdayStartTime,SundayEndTime,SundayStartTime,ThursdayEndTime,ThursdayStartTime,TimeZoneSidKey,TuesdayEndTime,TuesdayStartTime,WednesdayEndTime,WednesdayStartTime FROM BusinessHours WHERE IsDefault = true];
        
        BusinessHours defaultbh = lstdefaultbh.get(0);  
        
        /*SVMXC__Territory__c objTerritory = new SVMXC__Territory__c (
                                            Name = 'TERRITORY 1', SVMXC__Territory_s_Business_Hours__c = defaultbh.Id
                                            );
        insert objTerritory;*/
        
        List<SVMXC__Service_Group_Members__c> TechList123 = new List<SVMXC__Service_Group_Members__c>();
        SVMXC__Service_Group_Members__c Tech1 = new SVMXC__Service_Group_Members__c();
        Tech1.Name='Tech1';
        Tech1.SVMXC__Service_Group__c=SerTeam.Id;
        Tech1.SVMXC__Enable_Scheduling__c=true;
        Tech1.SVMXC__Active__c = true;
        Tech1.SVMXC__Working_Hours__c = defaultbh.Id;
        
        TechList123.add(Tech1);
        upsert TechList123;
        List<String> lsttechId = new List<String>();
        lsttechId.add(String.valueOf(Tech1.Id));
        
        for(SVMXC__Service_Group_Members__c p : TechList123)
        {
            TechList.add(p.Id);
        }
                
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c (
                                            /*SVMXC__Case__c = objCase.Id ,
                                            SVMXC__Company__c = objAccount.Id , 
                                            SVMXC__Contact__c =objContact.Id, */
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c = 'Medium',
                                            SVMXC__Order_Type__c= 'Field Service',
                                            SVMXC__Scheduled_Date__c = system.today(),
                                            SVMXC__Locked_By_DC__c = true,
                                            //SVMXC__Group_Member__c = Tech1.Id,
                                            SVMXC__Preferred_Business_Hours__c = defaultbh.Id,
                                            SVMXC__SM_Estimated_Duration__c = 7200
                                            );
        insert objWorkOrder;
        
        
        List<SVMXC__SVMX_Event__c> lstObjSVMXEvents = new List<SVMXC__SVMX_Event__c>();
        Date date1 = System.today();
        
        SVMXC__SVMX_Event__c SMAX_Event1 = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = date1.addDays(3), 
                                                    SVMXC__ActivityDateTime__c = DateTime.newInstanceGmt(date1.addDays(1),Time.newInstance(8,45,0,0)), 
                                                    SVMXC__StartDateTime__c = DateTime.newInstanceGmt(date1.addDays(1),Time.newInstance(8,45,0,0)),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__Technician__c = Tech1.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id
                                                    );
        SVMXC__SVMX_Event__c SMAX_Event2 = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = date1.addDays(3), 
                                                    SVMXC__ActivityDateTime__c = DateTime.newInstanceGmt(date1.addDays(1),Time.newInstance(12,45,0,0)), 
                                                    SVMXC__StartDateTime__c = DateTime.newInstanceGmt(date1.addDays(1),Time.newInstance(12,45,0,0)),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__Technician__c = Tech1.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id
                                                    );
        SVMXC__SVMX_Event__c SMAX_Event3 = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = date1.addDays(3), 
                                                    SVMXC__ActivityDateTime__c = DateTime.newInstanceGmt(date1.addDays(1),Time.newInstance(17,45,0,0)), 
                                                    SVMXC__StartDateTime__c = DateTime.newInstanceGmt(date1.addDays(1),Time.newInstance(17,45,0,0)),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__Technician__c = Tech1.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id
                                                    );
        SVMXC__SVMX_Event__c SMAX_Event4 = new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = date1.addDays(5), 
                                                    SVMXC__ActivityDateTime__c = DateTime.newInstanceGmt(date1.addDays(5),Time.newInstance(0,0,0,0)), 
                                                    SVMXC__StartDateTime__c = DateTime.newInstanceGmt(date1.addDays(5),Time.newInstance(0,0,0,0)),
                                                    SVMXC__EndDateTime__c = DateTime.newInstanceGmt(date1.addDays(5),Time.newInstance(0,0,0,0)),
                                                    SVMXC__DurationInMinutes__c = 2880,
                                                    SVMXC__Technician__c = Tech1.Id,
                                                    SVMXC__WhatId__c = objWorkOrder.Id,
                                                    SVMXC__IsAllDayEvent__c = true
                                                    );
                                                    
        lstObjSVMXEvents.add(SMAX_Event1);
        lstObjSVMXEvents.add(SMAX_Event2);
        lstObjSVMXEvents.add(SMAX_Event3);
        lstObjSVMXEvents.add(SMAX_Event4);
        
        insert lstObjSVMXEvents;
        
        list<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue = new list<DCON_Configuration_WS.SVMX_StringMap>();
        lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '0'));
        lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '0'));
        lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '0'));
        DCON_Configuration_WS.SVMX_StringMap datTest1 = new DCON_Configuration_WS.SVMX_StringMap('bb', 'DATE');
        datTest1.DateValue = system.today();
        datTest1.Value = 'DATE';
        lstKeyValue.add(datTest1);
        DCON_Configuration_WS.SVMX_StringMap datTest2 = new DCON_Configuration_WS.SVMX_StringMap('aa', 'DATETIME');
        datTest2.Value = 'DATETIME';
        datTest2.DateTimeValue = system.now();
        lstKeyValue.add(datTest2); 
        List<Event> lstAESEvents = new List<Event>(); 
        Event e5 = new Event(ActivityDate = date1.addDays(-2), 
                                StartDateTime = DateTime.newInstanceGmt(date1.addDays(-2),Time.newInstance(9,45,0,0)),
                                ActivityDateTime = DateTime.newInstanceGmt(date1.addDays(-2),Time.newInstance(9,45,0,0)), 
                                DurationInMinutes = 30, Subject = 'AES JOB', OwnerId = Tech1.Id, 
                                WhatId=objWorkOrder.Id, Description='test AES JOB');    
        e5.IsAllDayEvent = false;
        e5.SVMXC__Driving_Time_Home__c = 5;
        e5.SVMXC__Overhead_Time_After__c = 0;
        e5.SVMXC__Overhead_Time_Before__c = 0;
        e5.SVMXC__Break_Time_Total__c = 0;
        e5.SVMXC__Driving_Time__c = 5;   
        e5.SVMXC__Service_Duration__c = 1800;
        lstAESEvents.add(e5);
        
        String timeZone = 'Asia/Kolkata';
        Integer eventMinDuration = 60;
        boolean isTechWorkingHrsEnabled = true;
        boolean isMachineWorkingHrsEnabled = false;
        boolean isOverlappingEnabled = false;
        
        DCON_AES_Event_WS.AES_Request req1 = new DCON_AES_Event_WS.AES_Request();
        DCON_AES_Event_WS.AES_Request req;
        DCON_AES_Event_WS.AES_Response resp = new DCON_AES_Event_WS.AES_Response();
                  
              
        req = new DCON_AES_Event_WS.AES_Request(String.valueOf(u.Id),lstAESEvents,timeZone,lsttechId,eventMinDuration,true,true,isOverlappingEnabled,true,lstKeyValue,false,false);
        DCON_AES_Event_WS.DCON_AES_Create_Events_WS(req);
        
        req = new DCON_AES_Event_WS.AES_Request(String.valueOf(u.Id),lstAESEvents,timeZone,lsttechId,eventMinDuration,true,true,isOverlappingEnabled,false,lstKeyValue,false,false);
        DCON_AES_Event_WS.DCON_AES_Create_Events_WS(req);
        
        req = new DCON_AES_Event_WS.AES_Request(String.valueOf(u.Id),lstAESEvents,timeZone,lsttechId,eventMinDuration,false,false,false,false,lstKeyValue,false,false);
        DCON_AES_Event_WS.DCON_AES_Create_Events_WS(req);                
    }
    
    static testMethod void DCON_AES_Event_WS_UT_Test3()
    {
        DCON_AES_Event_WS obj = new DCON_AES_Event_WS();
        User u = [SELECT id from User where id = :UserInfo.getUserId()];
        List<String> TechList = new List<String>();
        
        /*Account objAccount = new Account(
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
        insert objAccount;

        system.assert(objAccount!=null, true);

        Contact objContact = new Contact(LastName='Last',AccountId =objAccount.Id);
        insert objContact;

        system.assert(objContact!=null, true);

        Case objCase = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                        ContactId = objContact.Id,
                                        AccountId = objAccount.Id                                         
                                        ); 
        insert objCase; 

        system.assertEquals(objCase.ContactId, objContact.Id);
        system.assertEquals(objCase.AccountId, objAccount.Id); */
        
        SVMXC__Service_Group__c SerTeam = new SVMXC__Service_Group__c();
        SerTeam.Name='TeamABC';
        Upsert SerTeam;
        
        List<BusinessHours> lstdefaultbh = [SELECT FridayEndTime,FridayStartTime,Id,IsActive,IsDefault,MondayEndTime,MondayStartTime,Name,SaturdayEndTime,SaturdayStartTime,SundayEndTime,SundayStartTime,ThursdayEndTime,ThursdayStartTime,TimeZoneSidKey,TuesdayEndTime,TuesdayStartTime,WednesdayEndTime,WednesdayStartTime FROM BusinessHours WHERE IsDefault = true];
        
        BusinessHours defaultbh = lstdefaultbh.get(0);  
        
        /*SVMXC__Territory__c objTerritory = new SVMXC__Territory__c (
                                            Name = 'TERRITORY 1', SVMXC__Territory_s_Business_Hours__c = defaultbh.Id
                                            );
        insert objTerritory;*/
        
        List<SVMXC__Service_Group_Members__c> TechList123 = new List<SVMXC__Service_Group_Members__c>();
        SVMXC__Service_Group_Members__c Tech1 = new SVMXC__Service_Group_Members__c();
        Tech1.Name='Tech1';
        Tech1.SVMXC__Service_Group__c=SerTeam.Id;
        Tech1.SVMXC__Enable_Scheduling__c=true;
        Tech1.SVMXC__Active__c = true;
        Tech1.SVMXC__Working_Hours__c = defaultbh.Id;
        
        TechList123.add(Tech1);
        upsert TechList123;
        List<String> lsttechId = new List<String>();
        lsttechId.add(String.valueOf(Tech1.Id));
        
        for(SVMXC__Service_Group_Members__c p : TechList123)
        {
            TechList.add(p.Id);
        }
                
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c (
                                            /*SVMXC__Case__c = objCase.Id ,
                                            SVMXC__Company__c = objAccount.Id , 
                                            SVMXC__Contact__c =objContact.Id, */
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c = 'Medium',
                                            SVMXC__Order_Type__c= 'Field Service',
                                            SVMXC__Scheduled_Date__c = system.today(),
                                            SVMXC__Locked_By_DC__c = true,
                                            SVMXC__Group_Member__c = Tech1.Id,
                                            SVMXC__Preferred_Business_Hours__c = defaultbh.Id,
                                            SVMXC__SM_Estimated_Duration__c = 7200
                                            );
        insert objWorkOrder;
        
        
        List<Event> lstObjSFEvents = new List<Event>();
        Date date1 = System.today();
        Event e1 = new Event(ActivityDate = date1,
                                StartDateTime = DateTime.newInstanceGmt(date1,Time.newInstance(8,45,0,0)),
                                ActivityDateTime = DateTime.newInstanceGmt(date1,Time.newInstance(8,45,0,0)), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = u.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        Event e2 = new Event(ActivityDate = date1, 
                                StartDateTime = DateTime.newInstanceGmt(date1,Time.newInstance(12,0,0,0)),
                                ActivityDateTime = DateTime.newInstanceGmt(date1,Time.newInstance(12,0,0,0)), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = u.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        Event e3 = new Event(ActivityDate = date1, 
                                StartDateTime = DateTime.newInstanceGmt(date1,Time.newInstance(17,45,0,0)),
                                ActivityDateTime = DateTime.newInstanceGmt(date1,Time.newInstance(17,45,0,0)), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = u.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
        Event e4 = new Event(ActivityDate = date1.addDays(1), 
                                StartDateTime = DateTime.newInstanceGmt(date1.addDays(1),Time.newInstance(0,0,0,0)),
                                ActivityDateTime = DateTime.newInstanceGmt(date1.addDays(1),Time.newInstance(0,0,0,0)), 
                                DurationInMinutes = 1440, Subject = 'test', OwnerId = u.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc',IsAllDayEvent=true);                            
        lstObjSFEvents.add(e1);
        lstObjSFEvents.add(e2);
        lstObjSFEvents.add(e3);
        lstObjSFEvents.add(e4);
        
        insert lstObjSFEvents;
        
        list<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue = new list<DCON_Configuration_WS.SVMX_StringMap>();
        lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '0'));
        lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '0'));
        lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '0'));
        DCON_Configuration_WS.SVMX_StringMap datTest1 = new DCON_Configuration_WS.SVMX_StringMap('bb', 'DATE');
        datTest1.DateValue = system.today();
        datTest1.Value = 'DATE';
        lstKeyValue.add(datTest1);
        DCON_Configuration_WS.SVMX_StringMap datTest2 = new DCON_Configuration_WS.SVMX_StringMap('aa', 'DATETIME');
        datTest2.Value = 'DATETIME';
        datTest2.DateTimeValue = system.now();
        lstKeyValue.add(datTest2); 
        List<Event> lstAESEvents = new List<Event>(); 
        Event e5 = new Event(ActivityDate = date1.addDays(-2), 
                                StartDateTime = DateTime.newInstanceGmt(date1.addDays(-2),Time.newInstance(9,45,0,0)),
                                ActivityDateTime = DateTime.newInstanceGmt(date1.addDays(-2),Time.newInstance(9,45,0,0)), 
                                DurationInMinutes = 30, Subject = 'AES JOB', OwnerId = u.Id, 
                                WhatId=objWorkOrder.Id, Description='test AES JOB');    
        e5.IsAllDayEvent = false;
        e5.SVMXC__Driving_Time_Home__c = 5;
        e5.SVMXC__Overhead_Time_After__c = 0;
        e5.SVMXC__Overhead_Time_Before__c = 0;
        e5.SVMXC__Break_Time_Total__c = 0;
        e5.SVMXC__Driving_Time__c = 5;   
        e5.SVMXC__Service_Duration__c = 1800;
        lstAESEvents.add(e5);
        
        String timeZone = 'Asia/Kolkata';
        Integer eventMinDuration = 60;
        boolean isTechWorkingHrsEnabled = true;
        boolean isMachineWorkingHrsEnabled = false;
        boolean isOverlappingEnabled = false;
        
        DCON_AES_Event_WS.AES_Request req1 = new DCON_AES_Event_WS.AES_Request();
        DCON_AES_Event_WS.AES_Request req;
        req = new DCON_AES_Event_WS.AES_Request(String.valueOf(u.Id),lstAESEvents,timeZone, lsttechId,eventMinDuration,isTechWorkingHrsEnabled,isMachineWorkingHrsEnabled,isOverlappingEnabled,false,lstKeyValue,true,false);
        DCON_AES_Event_WS.AES_Response resp = new DCON_AES_Event_WS.AES_Response();
        
        DCON_AES_Event_WS.DCON_AES_Create_Events_WS(req);

        req = new DCON_AES_Event_WS.AES_Request(String.valueOf(u.Id),lstAESEvents,timeZone,lsttechId,eventMinDuration,false,true,true,false,lstKeyValue,true,true);
        DCON_AES_Event_WS.DCON_AES_Create_Events_WS(req);          
    }
}