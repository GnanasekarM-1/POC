@isTest
Private class DCON_WO_Dependency_WS_UT {
    Public  DCON_WO_Dependency_WS_UT()
    {
        List<SVMXC__ServiceMax_Config_Data__c> lst = [select id, SVMXC__Setting_Unique_ID__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Setting_Unique_ID__c IN ('DCON001_SET038','DCON001_SET039','DCON001_SET040','DCON001_SET041','DCON001_SET042','DCON001_SET043','DCON001_SET044','DCON001_SET045','DCON001_SET046','DCON001_SET047','GLOB001_GBL007','GLOB001_GBL014','EVER007_SET001','IPRD003_SET007','IPRD003_SET003', 'EVER007_SET002')];
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
                else
                {
                    l.SVMXC__Display_Value__c = 'false';
                    l.SVMXC__Internal_Value__c = 'false';
                    l.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                }
            }
        if(lst != null && lst.size() > 0)
           update lst;
    }
    static
    {
        DCON_WO_Dependency_WS_UT obj = new DCON_WO_Dependency_WS_UT();
    }
    static testMethod void DCON_WO_Dependency_WS_UT_Test()
    {
        
         
        String usid=UserInfo.getUserId();
        system.assert(usid!=null);
        User u = [SELECT id from User where id = :UserInfo.getUserId()];
        
        List<SVMXC__Dependency_Management__c> lstdg = new List<SVMXC__Dependency_Management__c>();
        
        SVMXC__Dependency_Management__c dg1 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency1');
        
        SVMXC__Dependency_Management__c dg2 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency2');
        
        SVMXC__Dependency_Management__c dg3 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency3');
        
        SVMXC__Dependency_Management__c dg4 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency4');
        
        SVMXC__Dependency_Management__c dg5 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency5');
        
        SVMXC__Dependency_Management__c dg6 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency6');
        
        lstdg.add(dg1);
        lstdg.add(dg2);
        lstdg.add(dg3);
        lstdg.add(dg4);
        lstdg.add(dg5);
        lstdg.add(dg6);
        
        insert lstdg;
        
        SVMXC__Service_Group__c team1 = new SVMXC__Service_Group__c (
                                            Name = 'TEAM 1'
                                            );
                            
        insert team1;
        
        List<SVMXC__Service_Group_Members__c> lsttech = new List<SVMXC__Service_Group_Members__c>();
        
        SVMXC__Service_Group_Members__c tech1 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 1' ,
                                            SVMXC__Service_Group__c = team1.Id,SVMXC__Salesforce_User__c = u.id);
        SVMXC__Service_Group_Members__c tech2 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 2' ,
                                            SVMXC__Service_Group__c = team1.Id);  
        SVMXC__Service_Group_Members__c tech3 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 3' ,
                                            SVMXC__Service_Group__c = team1.Id);
        SVMXC__Service_Group_Members__c tech4 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 4' ,
                                            SVMXC__Service_Group__c = team1.Id);                                  
        SVMXC__Service_Group_Members__c tech5 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 5' ,
                                            SVMXC__Service_Group__c = team1.Id);
        SVMXC__Service_Group_Members__c tech6 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 6' ,
                                            SVMXC__Service_Group__c = team1.Id);  
        lsttech.add(tech1);
        lsttech.add(tech2);
        lsttech.add(tech3);
        lsttech.add(tech4);
        lsttech.add(tech5);
        lsttech.add(tech6);
        insert lsttech;
        
        List<SVMXC__Service_Order__c> lstwo = new List<SVMXC__Service_Order__c>();  
        SVMXC__Service_Order__c wo1 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech1.Id, SVMXC__Dependency_Group__c = dg1.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo1);
        
        SVMXC__Service_Order__c wo2 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Dependency_Group__c = dg1.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo2);
        
        SVMXC__Service_Order__c wo3 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech2.Id, SVMXC__Dependency_Group__c = dg2.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo3);
        
        SVMXC__Service_Order__c wo4 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Dependency_Group__c = dg2.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo4);
        
        SVMXC__Service_Order__c wo5 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech3.Id, SVMXC__Dependency_Group__c = dg3.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo5);
        
        SVMXC__Service_Order__c wo6 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Dependency_Group__c = dg3.Id, SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo6);
        
        SVMXC__Service_Order__c wo7 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech4.Id, SVMXC__Dependency_Group__c = dg4.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo7);
        
        SVMXC__Service_Order__c wo8 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Dependency_Group__c = dg4.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo8);
        
        SVMXC__Service_Order__c wo9 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech5.Id, SVMXC__Dependency_Group__c = dg5.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo9);
        
        SVMXC__Service_Order__c wo10 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),  SVMXC__Service_Duration__c = 7200,SVMXC__Dependency_Group__c = dg5.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo10);
        
        SVMXC__Service_Order__c wo11 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),  SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech6.Id, SVMXC__Dependency_Group__c = dg6.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo11);
        
        SVMXC__Service_Order__c wo12 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),  SVMXC__Service_Duration__c = 7200,SVMXC__Dependency_Group__c = dg6.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo12);
        
        insert lstwo;
        
        List<SVMXC__Service_Order_Dependency__c> lstdependencies = new List<SVMXC__Service_Order_Dependency__c>();
        SVMXC__Service_Order_Dependency__c dependency1 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg1.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo1.Id, SVMXC__Resource_Dependency__c = 'Same Resource',SVMXC__Secondary_Work_Order__c = wo2.Id,SVMXC__Time_Dependency__c = 'Set Arrival Time of Secondary relative to the Arrival Time of Primary');
        lstdependencies.add(dependency1);
        
        SVMXC__Service_Order_Dependency__c dependency2 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg2.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo3.id,SVMXC__Resource_Dependency__c = 'Same Resource',SVMXC__Secondary_Work_Order__c = wo4.id,SVMXC__Time_Dependency__c = ' Set End Time of Secondary relative to the Arrival Time of Primary');
        lstdependencies.add(dependency2);
        
        SVMXC__Service_Order_Dependency__c dependency3 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg3.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo5.id,SVMXC__Resource_Dependency__c = 'Same Resource',SVMXC__Secondary_Work_Order__c = wo6.id,SVMXC__Time_Dependency__c = 'Set Arrival Time of Secondary relative to the End Time of Primary');
        lstdependencies.add(dependency3);
        
        SVMXC__Service_Order_Dependency__c dependency4 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg4.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo7.id,SVMXC__Resource_Dependency__c = 'Different Resource',SVMXC__Secondary_Work_Order__c = wo8.id,SVMXC__Time_Dependency__c = 'Set End Time of Secondary relative to the End Time of Primary');
        lstdependencies.add(dependency4);
        
        SVMXC__Service_Order_Dependency__c dependency5 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg5.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo9.id,SVMXC__Resource_Dependency__c = 'Different Resource',SVMXC__Secondary_Work_Order__c = wo10.id,SVMXC__Time_Dependency__c = 'Start Unison');
        lstdependencies.add(dependency5);
        
        SVMXC__Service_Order_Dependency__c dependency6 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg6.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo11.id,SVMXC__Resource_Dependency__c = 'Different Resource',SVMXC__Secondary_Work_Order__c = wo12.id,SVMXC__Time_Dependency__c = 'Finish Unison');
        lstdependencies.add(dependency6);
        
        insert lstdependencies;
        
        test.starttest();
        List<Event> lstSFEvents = new List<Event>();
        String timezone = 'GMT';
        Event e1 = new Event(ActivityDate = Date.valueOf('2017-07-31 00:00:00'),
                                StartDateTime = Datetime.valueOf('2017-07-31 11:45:00') ,
                                EndDateTime = Datetime.valueOf('2017-07-31 12:45:00') ,
                                ActivityDateTime = Datetime.valueOf('2017-07-31 11:45:00'), 
                                DurationInMinutes = 60, Subject = 'test1', 
                                WhatId=wo2.id, Description='Test Desc1', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
        lstSFEvents.add(e1);                        
        SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request req1 = new SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request(lstSFEvents,null,timezone,u.id,null);
        System.debug('req:'+ req1);
        DCON_WO_Dependency_WS.Workorder_Dependency_Response response1 = DCON_WO_Dependency_WS.DCON_WO_Dependency_Check_WS(req1);
        System.debug('response:'+ response1);
        
        Event e2 = new Event(ActivityDate = Date.valueOf('2017-07-31 00:00:00'),
                                StartDateTime = Datetime.valueOf('2017-07-31 11:45:00') ,
                                EndDateTime = Datetime.valueOf('2017-07-31 12:45:00') ,
                                ActivityDateTime = Datetime.valueOf('2017-07-31 11:45:00'), 
                                DurationInMinutes = 60, Subject = 'test2', 
                                WhatId=wo4.id, Description='Test Desc2', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
                                
        lstSFEvents.clear();
        lstSFEvents.add(e2);                        
        SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request req2= new SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request(lstSFEvents,null,timezone,u.id,null);
        DCON_WO_Dependency_WS.Workorder_Dependency_Response response2 = DCON_WO_Dependency_WS.DCON_WO_Dependency_Check_WS(req2);
        
        Event e3 = new Event(ActivityDate = Date.valueOf('2017-07-31 00:00:00'),
                                StartDateTime = Datetime.valueOf('2017-07-31 11:45:00') ,
                                EndDateTime = Datetime.valueOf('2017-07-31 12:45:00') ,
                                ActivityDateTime = Datetime.valueOf('2017-07-31 11:45:00'), 
                                DurationInMinutes = 60, Subject = 'test3', 
                                WhatId=wo6.id, Description='Test Desc3', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
        lstSFEvents.clear();
        lstSFEvents.add(e3);                        
        SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request req3 = new SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request(lstSFEvents,null,timezone,u.id,null);
        DCON_WO_Dependency_WS.Workorder_Dependency_Response response3 = DCON_WO_Dependency_WS.DCON_WO_Dependency_Check_WS(req3);                        
                                
        Event e4 = new Event(ActivityDate = Date.valueOf('2017-07-31 00:00:00'),
                                StartDateTime = Datetime.valueOf('2017-07-31 11:45:00') ,
                                EndDateTime = Datetime.valueOf('2017-07-31 12:45:00') ,
                                ActivityDateTime = Datetime.valueOf('2017-07-31 11:45:00'), 
                                DurationInMinutes = 60, Subject = 'test4', 
                                WhatId=wo8.id, Description='Test Desc4', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
        lstSFEvents.clear();
        lstSFEvents.add(e4);                        
        SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request req4 = new SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request(lstSFEvents,null,timezone,u.id,null);
        DCON_WO_Dependency_WS.Workorder_Dependency_Response response4 = DCON_WO_Dependency_WS.DCON_WO_Dependency_Check_WS(req4);
        
        Event e5 = new Event(ActivityDate = Date.valueOf('2017-07-31 00:00:00'),
                                StartDateTime = Datetime.valueOf('2017-07-31 11:45:00') ,
                                EndDateTime = Datetime.valueOf('2017-07-31 12:45:00') ,
                                ActivityDateTime = Datetime.valueOf('2017-07-31 11:45:00'), 
                                DurationInMinutes = 60, Subject = 'test5', 
                                WhatId=wo10.id, Description='Test Desc5', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
        lstSFEvents.clear();
        lstSFEvents.add(e5);                        
        SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request req5 = new SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request(lstSFEvents,null,timezone,u.id,null);
        DCON_WO_Dependency_WS.Workorder_Dependency_Response response5 = DCON_WO_Dependency_WS.DCON_WO_Dependency_Check_WS(req5);    
        
        Event e6 = new Event(ActivityDate = Date.valueOf('2017-07-31 00:00:00'),
                                StartDateTime = Datetime.valueOf('2017-07-31 11:45:00') ,
                                EndDateTime = Datetime.valueOf('2017-07-31 12:45:00') ,
                                ActivityDateTime = Datetime.valueOf('2017-07-31 11:45:00'), 
                                DurationInMinutes = 60, Subject = 'test6', 
                                WhatId=wo12.id, Description='Test Desc6', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
        lstSFEvents.clear();
        lstSFEvents.add(e6);                        
        SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request req6 = new SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request(lstSFEvents,null,timezone,u.id,null);
        DCON_WO_Dependency_WS.Workorder_Dependency_Response response6 = DCON_WO_Dependency_WS.DCON_WO_Dependency_Check_WS(req6);
        
        Event e7 = new Event(ActivityDate = Date.valueOf('2017-07-31 00:00:00'),
                                StartDateTime = Datetime.valueOf('2017-07-31 11:45:00') ,
                                EndDateTime = Datetime.valueOf('2017-07-31 12:45:00') ,
                                ActivityDateTime = Datetime.valueOf('2017-07-31 11:45:00'), 
                                DurationInMinutes = 60, Subject = 'test7', 
                                WhatId=wo2.id, Description='Test Desc7', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
        lstSFEvents.clear();
        lstSFEvents.add(e7); 
        insert lstSFEvents;
        SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request req7 = new SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request(lstSFEvents,null,timezone,u.id,null);
        DCON_WO_Dependency_WS.Workorder_Dependency_Response response7 = DCON_WO_Dependency_WS.DCON_WO_Dependency_Check_WS(req7);    
        
        List<SVMXC__SVMX_Event__c> lstSVMXEvents = new List<SVMXC__SVMX_Event__c>();
        SVMXC__SVMX_Event__c e8 = new SVMXC__SVMX_Event__c(SVMXC__ActivityDate__c = Date.valueOf('2017-07-31 00:00:00'),
                                SVMXC__StartDateTime__c = Datetime.valueOf('2017-07-31 10:00:00') ,
                                SVMXC__EndDateTime__c = Datetime.valueOf('2017-07-31 11:00:00') ,
                                SVMXC__ActivityDateTime__c = Datetime.valueOf('2017-07-31 10:00:00'), 
                                SVMXC__DurationInMinutes__c = 60,
                                SVMXC__Overhead_Time_Before__c =30,
                               
                                SVMXC__Break_Time_Total__c = 30,
                                SVMXC__WhatId__c=wo2.id, SVMXC__Description__c='Test Desc1', SVMXC__Service_Duration__c = 3600,SVMXC__Technician__c = tech1.id);
        lstSVMXEvents.add(e8);                      
        SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request req8 = new SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request(null,lstSVMXEvents,timezone,u.id,null);
        DCON_WO_Dependency_WS.Workorder_Dependency_Response response8 = DCON_WO_Dependency_WS.DCON_WO_Dependency_Check_WS(req8);
                                
        SVMXC__SVMX_Event__c e9 = new SVMXC__SVMX_Event__c(SVMXC__ActivityDate__c = Date.valueOf('2017-07-31 00:00:00'),
                                SVMXC__StartDateTime__c = Datetime.valueOf('2017-07-31 10:00:00') ,
                                SVMXC__EndDateTime__c = Datetime.valueOf('2017-07-31 11:00:00') ,
                                SVMXC__ActivityDateTime__c = Datetime.valueOf('2017-07-31 10:00:00'), 
                                SVMXC__DurationInMinutes__c = 60, 
                                SVMXC__WhatId__c=wo4.id, SVMXC__Description__c='Test Desc2', SVMXC__Service_Duration__c = 3600,SVMXC__Technician__c = tech2.id);
        lstSVMXEvents.clear();
        lstSVMXEvents.add(e9);                      
        SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request req9 = new SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request(null,lstSVMXEvents,timezone,u.id,null);
        DCON_WO_Dependency_WS.Workorder_Dependency_Response response9 = DCON_WO_Dependency_WS.DCON_WO_Dependency_Check_WS(req9);
                                
        SVMXC__SVMX_Event__c e10 = new SVMXC__SVMX_Event__c(SVMXC__ActivityDate__c = Date.valueOf('2017-07-31 00:00:00'),
                                SVMXC__StartDateTime__c = Datetime.valueOf('2017-07-31 10:00:00') ,
                                SVMXC__EndDateTime__c = Datetime.valueOf('2017-07-31 11:00:00') ,
                                SVMXC__ActivityDateTime__c = Datetime.valueOf('2017-07-31 10:00:00'), 
                                SVMXC__DurationInMinutes__c = 60, 
                                SVMXC__WhatId__c=wo6.id, SVMXC__Description__c='Test Desc3', SVMXC__Service_Duration__c = 3600,SVMXC__Technician__c = tech3.id);
        lstSVMXEvents.clear();
        lstSVMXEvents.add(e10);                     
        SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request req10 = new SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request(null,lstSVMXEvents,timezone,u.id,null);
        DCON_WO_Dependency_WS.Workorder_Dependency_Response response10 = DCON_WO_Dependency_WS.DCON_WO_Dependency_Check_WS(req10);                      
                                
        SVMXC__SVMX_Event__c e11 = new SVMXC__SVMX_Event__c(SVMXC__ActivityDate__c = Date.valueOf('2017-07-31 00:00:00'),
                                SVMXC__StartDateTime__c = Datetime.valueOf('2017-07-31 10:00:00') ,
                                SVMXC__EndDateTime__c = Datetime.valueOf('2017-07-31 11:00:00') ,
                                SVMXC__ActivityDateTime__c = Datetime.valueOf('2017-07-31 10:00:00'), 
                                SVMXC__DurationInMinutes__c = 60, 
                                SVMXC__WhatId__c=wo8.id, SVMXC__Description__c='Test Desc4', SVMXC__Service_Duration__c = 3600,SVMXC__Technician__c = tech1.id);
        lstSVMXEvents.clear();
        lstSVMXEvents.add(e11);                     
        SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request req12 = new SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request(null,lstSVMXEvents,timezone,u.id,null);
        DCON_WO_Dependency_WS.Workorder_Dependency_Response response12 = DCON_WO_Dependency_WS.DCON_WO_Dependency_Check_WS(req12);
                                
        SVMXC__SVMX_Event__c e12 = new SVMXC__SVMX_Event__c(SVMXC__ActivityDate__c = Date.valueOf('2017-07-31 00:00:00'),
                                SVMXC__StartDateTime__c = Datetime.valueOf('2017-07-31 10:00:00') ,
                                SVMXC__EndDateTime__c = Datetime.valueOf('2017-07-31 11:00:00') ,
                                SVMXC__ActivityDateTime__c = Datetime.valueOf('2017-07-31 10:00:00'), 
                                SVMXC__DurationInMinutes__c = 60, 
                                SVMXC__WhatId__c=wo10.id, SVMXC__Description__c='Test Desc5', SVMXC__Service_Duration__c = 3600,SVMXC__Technician__c = tech2.id);
        lstSVMXEvents.clear();
        lstSVMXEvents.add(e12);                     
        SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request req13 = new SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request(null,lstSVMXEvents,timezone,u.id,null);
        DCON_WO_Dependency_WS.Workorder_Dependency_Response response13 = DCON_WO_Dependency_WS.DCON_WO_Dependency_Check_WS(req13);
                                
        SVMXC__SVMX_Event__c e13 = new SVMXC__SVMX_Event__c(SVMXC__ActivityDate__c = Date.valueOf('2017-07-31 00:00:00'),
                                SVMXC__StartDateTime__c = Datetime.valueOf('2017-07-31 10:00:00') ,
                                SVMXC__EndDateTime__c = Datetime.valueOf('2017-07-31 11:00:00') ,
                                SVMXC__ActivityDateTime__c = Datetime.valueOf('2017-07-31 10:00:00'), 
                                SVMXC__DurationInMinutes__c = 60, 
                                SVMXC__WhatId__c=wo12.id, SVMXC__Description__c='Test Desc6', SVMXC__Service_Duration__c = 3600,SVMXC__Technician__c = tech3.id);
        lstSVMXEvents.clear();
        lstSVMXEvents.add(e13);                     
        SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request req14 = new SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request(null,lstSVMXEvents,timezone,u.id,null);
        DCON_WO_Dependency_WS.Workorder_Dependency_Response response14 = DCON_WO_Dependency_WS.DCON_WO_Dependency_Check_WS(req14);
                                
        SVMXC__SVMX_Event__c e14 = new SVMXC__SVMX_Event__c(SVMXC__ActivityDate__c = Date.valueOf('2017-07-31 00:00:00'),
                                SVMXC__StartDateTime__c = Datetime.valueOf('2017-07-31 10:00:00') ,
                                SVMXC__EndDateTime__c = Datetime.valueOf('2017-07-31 11:00:00') ,
                                SVMXC__ActivityDateTime__c = Datetime.valueOf('2017-07-31 10:00:00'), 
                                SVMXC__DurationInMinutes__c = 60, 
                                SVMXC__WhatId__c=wo8.id, SVMXC__Description__c='Test Desc7', SVMXC__Service_Duration__c = 3600,SVMXC__Technician__c = tech4.id);
        lstSVMXEvents.clear();
        lstSVMXEvents.add(e14);  
        insert lstSVMXEvents;
        SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request req15 = new SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request(null,lstSVMXEvents,timezone,u.id,null);
        DCON_WO_Dependency_WS.Workorder_Dependency_Response response15 = DCON_WO_Dependency_WS.DCON_WO_Dependency_Check_WS(req15); 
        
        test.stoptest();
    }
    static testMethod void DCON_WO_Dependency_WS_UT_Test2()
    {
        
         
        String usid=UserInfo.getUserId();
        system.assert(usid!=null);
        User u = [SELECT id from User where id = :UserInfo.getUserId()];
        
        List<SVMXC__Dependency_Management__c> lstdg = new List<SVMXC__Dependency_Management__c>();
        
        SVMXC__Dependency_Management__c dg7 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency1');
        
        SVMXC__Dependency_Management__c dg8 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency2');
        
        SVMXC__Dependency_Management__c dg9 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency3');
        
        SVMXC__Dependency_Management__c dg10 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency4');
        
        SVMXC__Dependency_Management__c dg11 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency5');
        
        SVMXC__Dependency_Management__c dg12 = new SVMXC__Dependency_Management__c (SVMXC__Description__c ='DC testing dependency6');
        
        lstdg.add(dg7);
        lstdg.add(dg8);
        lstdg.add(dg9);
        lstdg.add(dg10);
        lstdg.add(dg11);
        lstdg.add(dg12);
        
        insert lstdg;
        
        SVMXC__Service_Group__c team2 = new SVMXC__Service_Group__c (
                                            Name = 'TEAM 2'
                                            );
                            
        insert team2;
        
        List<SVMXC__Service_Group_Members__c> lsttech = new List<SVMXC__Service_Group_Members__c>();
        
        SVMXC__Service_Group_Members__c tech7 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 7' ,
                                            SVMXC__Service_Group__c = team2.Id,SVMXC__Salesforce_User__c = u.id);
        SVMXC__Service_Group_Members__c tech8 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 8' ,
                                            SVMXC__Service_Group__c = team2.Id);  
        SVMXC__Service_Group_Members__c tech9 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 9' ,
                                            SVMXC__Service_Group__c = team2.Id);
        SVMXC__Service_Group_Members__c tech10 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 10' ,
                                            SVMXC__Service_Group__c = team2.Id);                                  
        SVMXC__Service_Group_Members__c tech11 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 11' ,
                                            SVMXC__Service_Group__c = team2.Id);
        SVMXC__Service_Group_Members__c tech12 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 12' ,
                                            SVMXC__Service_Group__c = team2.Id);  
        lsttech.add(tech7);
        lsttech.add(tech8);
        lsttech.add(tech9);
        lsttech.add(tech10);
        lsttech.add(tech11);
        lsttech.add(tech12);
        insert lsttech;
        List<String> lw = new List<String>();
        List<SVMXC__Service_Order__c> lstwo = new List<SVMXC__Service_Order__c>(); 
          
        SVMXC__Service_Order__c wo21 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech7.Id, SVMXC__Dependency_Group__c = dg7.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo21);
        
        
        SVMXC__Service_Order__c wo22 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Dependency_Group__c = dg7.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo22);
        
        
        SVMXC__Service_Order__c wo23 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech8.Id, SVMXC__Dependency_Group__c = dg8.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo23);
        
        
        SVMXC__Service_Order__c wo24 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Dependency_Group__c = dg8.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo24);
        
        
        SVMXC__Service_Order__c wo25 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech9.Id, SVMXC__Dependency_Group__c = dg9.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo25);
        
        
        SVMXC__Service_Order__c wo26 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Dependency_Group__c = dg9.Id, SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo26);
        
        SVMXC__Service_Order__c wo27 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech10.Id, SVMXC__Dependency_Group__c = dg10.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo27);
        
        SVMXC__Service_Order__c wo28 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Dependency_Group__c = dg10.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo28);
       
        
        SVMXC__Service_Order__c wo29 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),   SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech11.Id, SVMXC__Dependency_Group__c = dg11.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo29);
        
        
        SVMXC__Service_Order__c wo30 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),  SVMXC__Service_Duration__c = 7200,SVMXC__Dependency_Group__c = dg11.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo30);
        
        SVMXC__Service_Order__c wo31 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),  SVMXC__Service_Duration__c = 7200, SVMXC__Group_Member__c = tech12.Id, SVMXC__Dependency_Group__c = dg12.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo31);
                
        SVMXC__Service_Order__c wo32 = new SVMXC__Service_Order__c (SVMXC__Scheduled_Date_Time__c = Datetime.valueOf('2017-07-31 10:00:00'),  SVMXC__Service_Duration__c = 7200,SVMXC__Dependency_Group__c = dg12.Id , SVMXC__Locked_By_DC__c = true);
        lstwo.add(wo32);
       
        insert lstwo;
        for(SVMXC__Service_Order__c lws : lstwo)
        {
            lw.add(lws.id);
        }
        
        List<SVMXC__Service_Order_Dependency__c> lstdependencies = new List<SVMXC__Service_Order_Dependency__c>();
        SVMXC__Service_Order_Dependency__c dependency7 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg7.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo21.Id, SVMXC__Resource_Dependency__c = 'Same Resource',SVMXC__Secondary_Work_Order__c = wo22.Id,SVMXC__Time_Dependency__c = 'Set Arrival Time of Secondary relative to the Arrival Time of Primary');
        lstdependencies.add(dependency7);
        
        SVMXC__Service_Order_Dependency__c dependency8 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg8.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo23.id,SVMXC__Resource_Dependency__c = 'Same Resource',SVMXC__Secondary_Work_Order__c = wo24.id,SVMXC__Time_Dependency__c = ' Set End Time of Secondary relative to the Arrival Time of Primary');
        lstdependencies.add(dependency8);
        
        SVMXC__Service_Order_Dependency__c dependency9 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg9.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo25.id,SVMXC__Resource_Dependency__c = 'Same Resource',SVMXC__Secondary_Work_Order__c = wo26.id,SVMXC__Time_Dependency__c = 'Set Arrival Time of Secondary relative to the End Time of Primary');
        lstdependencies.add(dependency9);
        
        SVMXC__Service_Order_Dependency__c dependency10 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg10.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo27.id,SVMXC__Resource_Dependency__c = 'Different Resource',SVMXC__Secondary_Work_Order__c = wo28.id,SVMXC__Time_Dependency__c = 'Set End Time of Secondary relative to the End Time of Primary');
        lstdependencies.add(dependency10);
        
        SVMXC__Service_Order_Dependency__c dependency11 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg11.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo29.id,SVMXC__Resource_Dependency__c = 'Different Resource',SVMXC__Secondary_Work_Order__c = wo30.id,SVMXC__Time_Dependency__c = 'Start Unison');
        lstdependencies.add(dependency11);
        
        SVMXC__Service_Order_Dependency__c dependency12 = new SVMXC__Service_Order_Dependency__c(SVMXC__Dependency_Group__c = dg12.Id,SVMXC__Maximum_Time_Deviation__c = 60,SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes',SVMXC__Minimum_Time_Deviation__c = 30,SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes',SVMXC__Primary_Work_Order__c = wo31.id,SVMXC__Resource_Dependency__c = 'Different Resource',SVMXC__Secondary_Work_Order__c = wo32.id,SVMXC__Time_Dependency__c = 'Finish Unison');
        lstdependencies.add(dependency12);
        
        insert lstdependencies;
        
        test.starttest();
        List<Event> lstSFEvents = new List<Event>();
        String timezone = 'GMT';
        List<SVMXC__SVMX_Event__c> lstSVMXEvents = new List<SVMXC__SVMX_Event__c>();
        SVMXC__SVMX_Event__c e21 = new SVMXC__SVMX_Event__c(SVMXC__ActivityDate__c = Date.valueOf('2017-07-31 00:00:00'),
                                SVMXC__StartDateTime__c = Datetime.valueOf('2017-07-31 10:00:00') ,
                                SVMXC__EndDateTime__c = Datetime.valueOf('2017-07-31 11:00:00') ,
                                SVMXC__ActivityDateTime__c = Datetime.valueOf('2017-07-31 10:00:00'), 
                                SVMXC__DurationInMinutes__c = 60, 
                                SVMXC__Driving_Time_Home__c = 30,
                                SVMXC__Driving_Time__c=30,
                                SVMXC__Overhead_Time_Before__c =30,
                                SVMXC__Overhead_Time_After__c = 30,
                                SVMXC__Break_Time_Total__c = 30,
                                SVMXC__Service_Order__c=wo22.id, SVMXC__Description__c='Test Desc6', SVMXC__Service_Duration__c = 3600,SVMXC__Technician__c = tech9.id);
        lstSVMXEvents.add(e21);
        insert lstSVMXEvents;
        system.debug('inserted lstsvmxevents');
                               
        SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request req11 = new SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request(null,null,timezone,u.id,lw);
        System.debug('req:'+ req11);
        //DCON_WO_Dependency_WS.Workorder_Dependency_Response response11 = DCON_WO_Dependency_WS.DCON_WO_Get_Dependency_Details_WS(req11);
        //System.debug('response:'+ response11);
        
        Event e22 = new Event(ActivityDate = Date.valueOf('2017-09-30 00:00:00'),
                                StartDateTime = Datetime.valueOf('2017-09-30 11:45:00') ,
                                EndDateTime = Datetime.valueOf('2017-09-30 12:45:00') ,
                                ActivityDateTime = Datetime.valueOf('2017-09-30 11:45:00'), 
                                SVMXC__Overhead_Time_Before__c =30,
                                SVMXC__Overhead_Time_After__c = 30,
                              SVMXC__Driving_Time_Home__c = 30,
                              SVMXC__Driving_Time__c=30,
                                SVMXC__Break_Time_Total__c = 30,
                                DurationInMinutes = 60, Subject = 'test2', 
                                
                                WhatId=wo24.id, Description='Test Desc2', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
                                
        
        lstSFEvents.add(e22);                        
        
        SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request req12= new SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request(null,null,timezone,u.id,lw);
        //DCON_WO_Dependency_WS.Workorder_Dependency_Response response12 = DCON_WO_Dependency_WS.DCON_WO_Get_Dependency_Details_WS(req12);
        
        Event e23 = new Event(ActivityDate = Date.valueOf('2017-09-30 00:00:00'),
                                StartDateTime = Datetime.valueOf('2017-09-30 11:45:00') ,
                                EndDateTime = Datetime.valueOf('2017-09-30 12:45:00') ,
                                ActivityDateTime = Datetime.valueOf('2017-09-30 11:45:00'), 
                                DurationInMinutes = 60, Subject = 'test3', 
                                WhatId=wo26.id, Description='Test Desc3', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
        
        lstSFEvents.add(e23);                        
        SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request req13 = new SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request(null,null,timezone,u.id,lw);
        //DCON_WO_Dependency_WS.Workorder_Dependency_Response response13 = DCON_WO_Dependency_WS.DCON_WO_Get_Dependency_Details_WS(req13);                        
                                
        Event e24 = new Event(ActivityDate = Date.valueOf('2017-09-30 00:00:00'),
                                StartDateTime = Datetime.valueOf('2017-09-30 11:45:00') ,
                                EndDateTime = Datetime.valueOf('2017-09-30 12:45:00') ,
                                ActivityDateTime = Datetime.valueOf('2017-09-30 11:45:00'), 
                                DurationInMinutes = 60, Subject = 'test4', 
                                WhatId=wo28.id, Description='Test Desc4', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
        lstSFEvents.add(e24);                        
        SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request req14 = new SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request(null,null,timezone,u.id,lw);
        //DCON_WO_Dependency_WS.Workorder_Dependency_Response response14 = DCON_WO_Dependency_WS.DCON_WO_Get_Dependency_Details_WS(req14);
        
        Event e25 = new Event(ActivityDate = Date.valueOf('2017-09-30 00:00:00'),
                                StartDateTime = Datetime.valueOf('2017-09-30 11:45:00') ,
                                EndDateTime = Datetime.valueOf('2017-09-30 12:45:00') ,
                                ActivityDateTime = Datetime.valueOf('2017-09-30 11:45:00'), 
                                DurationInMinutes = 60, Subject = 'test5', 
                                WhatId=wo30.id, Description='Test Desc5', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
        lstSFEvents.add(e25);                        
        SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request req15 = new SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request(null,null,timezone,u.id,lw);
        //DCON_WO_Dependency_WS.Workorder_Dependency_Response response15 = DCON_WO_Dependency_WS.DCON_WO_Get_Dependency_Details_WS(req15);    
        
        Event e26 = new Event(ActivityDate = Date.valueOf('2017-09-30 00:00:00'),
                                StartDateTime = Datetime.valueOf('2017-09-30 11:45:00') ,
                                EndDateTime = Datetime.valueOf('2017-09-30 12:45:00') ,
                                ActivityDateTime = Datetime.valueOf('2017-09-30 11:45:00'), 
                                DurationInMinutes = 60, Subject = 'test6', 
                                WhatId=wo32.id, Description='Test Desc6', SVMXC__Service_Duration__c = 3600, ownerId = u.id);
        lstSFEvents.add(e26);  
        insert lstSFEvents;
        SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request req16 = new SVMXC.DCON_WO_Dependency_WS.Workorder_Dependency_Request(null,null,timezone,u.id,lw);
        //DCON_WO_Dependency_WS.Workorder_Dependency_Response response16 = DCON_WO_Dependency_WS.DCON_WO_Get_Dependency_Details_WS(req16);          
        List<DCON_WO_Dependency_WS.Dependency_Details> response = DCON_WO_Dependency_WS.DCON_WO_Get_Dependency_Details_WS(req11);
        test.stoptest();
    }
}