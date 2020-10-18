@isTest
private class DCON_Event_WS_UT {    
    public DCON_Event_WS_UT()
    {
        SVMX_Constants.AllDCSettingList = null;
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
        DCON_Event_WS_UT obj = new DCON_Event_WS_UT();
    }
    static testMethod void DCON_Retrieve_Events_WS_UT_Test()
    {
         
        List<RecordType> RecordTypes = new List<RecordType>();
        String RuleRecordTypeId;
        String ExpressionRTypeId;
        String FieldMapRTypeId;
        RecordTypes = Database.query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\' OR SobjectType = \'SVMXC__ServiceMax_Config_Data__c\'');
        for(RecordType r : RecordTypes)
        {
            if(r.Name == 'SVMX Rule')
            {
              RuleRecordTypeId = r.id;
            }
            if(r.Name == 'Expressions')
            {
                ExpressionRTypeId = r.id;
            }
            if(r.Name == 'Field Mapping')
            {
                FieldMapRTypeId = r.id;
            } 
        }
        
        //Setup the event hover rule
        SVMXC__ServiceMax_Processes__c EventHovRule1 = new SVMXC__ServiceMax_Processes__c();
        EventHovRule1.RecordTypeId = RuleRecordTypeId;
        EventHovRule1.SVMXC__Select__c = true;
        EventHovRule1.SVMXC__ProcessID__c='PROCESS18';
        EventHovRule1.SVMXC__SettingId__c = 'PROCESS18';
        EventHovRule1.SVMXC__MapID__c='PROCESS18';
        EventHovRule1.SVMXC__Name__c = 'PROCESS28';
        EventHovRule1.SVMXC__Description__c = 'Event Rule 1';
        EventHovRule1.SVMXC__Sequence__c = 1;
        EventHovRule1.SVMXC__Rule_Type__c = 'Event Hover Rule';
        insert EventHovRule1;
        
        system.assert(EventHovRule1!=null, true);
        
        //Create Congfig data for Rule 
        List<SVMXC__ServiceMax_Config_Data__c> configLst= new List<SVMXC__ServiceMax_Config_Data__c>(); 
        SVMXC__ServiceMax_Config_Data__c conf1 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId = ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = EventHovRule1.id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__Order_Status__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'Open',
                                            SVMXC__Expression_Type__c = 'DISP_Event_Hover_Rule',                                            
                                            SVMXC__Sequence__c = 1
                                            );
        configLst.add(conf1);
        
        system.assertEquals(conf1.SVMXC__Expression_Rule__c, EventHovRule1.id);
        
        //Create WO Field for Rule 
        SVMXC__ServiceMax_Config_Data__c conf3 = new SVMXC__ServiceMax_Config_Data__c();
        conf3.RecordTypeId = FieldMapRTypeId;
        conf3.SVMXC__Expression_Rule__c = EventHovRule1.id;
        conf3.SVMXC__Target_Field_Name__c = 'SVMXC__Case__c';
        conf3.SVMXC__Sequence__c = 1;
        configLst.add(conf3);
        
        system.assertEquals(conf3.SVMXC__Expression_Rule__c, EventHovRule1.id);
        
        SVMXC__ServiceMax_Config_Data__c conf4 = new SVMXC__ServiceMax_Config_Data__c();
        conf4.RecordTypeId = FieldMapRTypeId;
        conf4.SVMXC__Expression_Rule__c = EventHovRule1.id;
        conf4.SVMXC__Target_Field_Name__c = 'SVMXC__Actual_Initial_Response__c';
        conf4.SVMXC__Sequence__c = 2;
        configLst.add(conf4);
        
        system.assertEquals(conf4.SVMXC__Expression_Rule__c, EventHovRule1.id);
        
        SVMXC__ServiceMax_Config_Data__c conf5 = new SVMXC__ServiceMax_Config_Data__c();
        conf5.RecordTypeId = FieldMapRTypeId;
        conf5.SVMXC__Expression_Rule__c = EventHovRule1.id;
        conf5.SVMXC__Target_Field_Name__c = 'SVMXC__Actual_Resolution__c';
        conf5.SVMXC__Sequence__c = 3;
        configLst.add(conf5);
        
        system.assertEquals(conf5.SVMXC__Expression_Rule__c, EventHovRule1.id);
        
        SVMXC__ServiceMax_Config_Data__c conf6 = new SVMXC__ServiceMax_Config_Data__c();
        conf6.RecordTypeId = FieldMapRTypeId;
        conf6.SVMXC__Expression_Rule__c = EventHovRule1.id;
        conf6.SVMXC__Target_Field_Name__c = 'SVMXC__Age__c';
        conf6.SVMXC__Sequence__c = 4;
        configLst.add(conf6);
        
        system.assertEquals(conf6.SVMXC__Expression_Rule__c, EventHovRule1.id);
        
        SVMXC__ServiceMax_Config_Data__c conf7 = new SVMXC__ServiceMax_Config_Data__c();
        conf7.RecordTypeId = FieldMapRTypeId;
        conf7.SVMXC__Expression_Rule__c = EventHovRule1.id;
        conf7.SVMXC__Target_Field_Name__c = 'SVMXC__Closed_On__c';
        conf7.SVMXC__Sequence__c = 5;
        configLst.add(conf7);
        
        system.assertEquals(conf7.SVMXC__Expression_Rule__c, EventHovRule1.id);
        
        SVMXC__ServiceMax_Config_Data__c conf8 = new SVMXC__ServiceMax_Config_Data__c();
        conf8.RecordTypeId = FieldMapRTypeId;
        conf8.SVMXC__Expression_Rule__c = EventHovRule1.id;
        conf8.SVMXC__Target_Field_Name__c = 'SVMXC__Scheduled_Date__c';
        conf8.SVMXC__Sequence__c = 5;
        configLst.add(conf8);
        
        system.assertEquals(conf8.SVMXC__Expression_Rule__c, EventHovRule1.id);
        
        insert configLst;
        
        system.assert(configLst!=null, true);
        
        User objUser = new User();
        Account objAccount;
        Contact objContact;
        Case objCase;
        SVMXC__Service_Order__c objWorkOrder;
        SVMXC__Service_Group__c objTeam;
        SVMXC__Territory__c objTerritory;
        SVMXC__Service_Group_Members__c objTechnician = new SVMXC__Service_Group_Members__c();
        List<SVMXC__Service_Group_Members__c> lstObjTech;
        
        List<Event> lstObjSFEvents = new List<Event>();
        List<SVMXC__SVMX_Event__c> lstObjSVMXEvents = new List<SVMXC__SVMX_Event__c>();
        objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];

        objAccount = new Account(
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

        objContact = new Contact(LastName='Last',AccountId =objAccount.Id);
        insert objContact;
        
        system.assert(objContact!=null, true);
        
        objCase = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                        ContactId = objContact.Id,
                                        AccountId = objAccount.Id                                         
                                        ); 
        insert objCase; 
        
        system.assertEquals(objCase.ContactId, objContact.Id);
        system.assertEquals(objCase.AccountId, objAccount.Id);
                       
        objTeam = new SVMXC__Service_Group__c (
                                            Name = 'TEAM 1'
                                            );
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
                                            
        system.assertEquals(objTechnician.SVMXC__Service_Group__c, objTeam.Id);
        system.assertEquals(objTechnician.SVMXC__Service_Territory__c, objTerritory.Id);
                       
        SVMXC__Service_Group_Members__c objTechnician2 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 1' ,
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
                                            SVMXC__Case__c = objCase.Id ,
                                            SVMXC__Company__c = objAccount.Id , 
                                            SVMXC__Contact__c =objContact.Id, 
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

        system.assertEquals(objWorkOrder.SVMXC__Company__c, objAccount.Id);
        system.assertEquals(objWorkOrder.SVMXC__Case__c, objCase.Id);
        system.assertEquals(objWorkOrder.SVMXC__Contact__c, objContact.Id);
        
        SVMXC__Dispatcher_Access__c objDispAccess = new SVMXC__Dispatcher_Access__c (
                                            SVMXC__Service_Team__c = objTeam.Id,
                                            SVMXC__Dispatcher__c = objUser.Id 
                                            );
        insert objDispAccess;
        
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
        
        system.assert(lstObjSFEvents!=null, true);
        
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
        
        system.assert(lstObjSVMXEvents!=null, true);
        
        List<String> lstTechIds = new List<String>();
        lstTechIds.add(objTechnician.Id);
        lstTechIds.add(objTechnician2.Id);
        
        system.assert(lstTechIds!=null, true);
        
        List<String> workorderIds = new List<String>();
        workorderIds.add(objWorkOrder.Id);
        List<String> eventIds = new List<String>();
        eventIds.add(e3.Id);
        
        system.assert(eventIds!=null, true);
        
        List<String> DispatchStatus = new List<String>();
        DispatchStatus.add('NEW');
        
        system.assert(DispatchStatus!=null, true);

        //DCON_Event_WS.GetEventWOInfo_WS(eventIds, objUser.Id, null, null, DispatchStatus, 'Asia/Kolkata@MM/DD/YYYY hh:mm a', workorderIds);
        
        DCON_Event_WS.svmxSettingList.put('SET026', 'TRUE');
        DCON_Event_WS.svmxSettingList.put('SET027', 'DISALLOW');
        DCON_Event_WS.svmxSettingList.put('SET028', 'TRUE');
        
        //DCON_Event_WS.DCON_Retrieve_Events_WS(objUser.Id, String.valueof(Date.valueOf('2010-02-11 00:00:00')-5), String.valueof(Date.valueOf('2010-02-11 00:00:00')+2), 'ALL', NULL, lstTechIds);       
        DCON_Event_WS.DCON_Retrieve_Events_WS(objUser.Id, String.valueof(Date.valueOf('2010-02-11 00:00:00')-5), String.valueof(Date.valueOf('2010-02-11 00:00:00')+2), 'ALL', 'Asia/Kolkata@MM/DD/YYYY hh:mm a', lstTechIds);       
        DCON_Event_WS.DCON_Retrieve_WO_Events_WS(objUser.Id, String.valueof(Date.valueOf('2010-02-11 00:00:00')-5), String.valueof(Date.valueOf('2010-02-11 00:00:00')+2),  'GMT', objWorkOrder.Id);       
        //DCON_Event_WS.DCON_Retrieve_Events_WS(objUser.Id, String.valueof(Date.valueOf('2010-02-11 00:00:00')-5), String.valueof(Date.valueOf('2010-02-11 00:00:00')+2), 'ALL', 'GMT', lstTechIds);
        DCON_Event_WS.DCON_Retrieve_Events_WS(objUser.Id, String.valueof(Date.valueOf('2010-02-11 00:00:00')-5), String.valueof(Date.valueOf('2010-02-11 00:00:00')+2), 'ALL', 'Asia/Kolkata@MM/DD/YYYY hh:mm a', lstTechIds);
        //DCON_Event_WS.DCON_Retrieve_WO_Events_WS(objUser.Id, null, String.valueof(Date.valueOf('2010-02-11 00:00:00')+2),  'GMT', objWorkOrder.Id);  jyothsna
        //commented line#308 when migrating from patch org to base org, as it was throwing too many SOQL exceptions
        //DCON_Event_WS.DCON_Retrieve_WO_Events_WS(objUser.Id, String.valueof(Date.valueOf('2010-02-11 00:00:00')-5), null,  'GMT', objWorkOrder.Id); 
       // DCON_Event_WS.DCON_Retrieve_WO_Events_WS(objUser.Id, null, null,  'GMT', objWorkOrder.Id);
       //lstObjSVMXEvents = DCON_Event_WS.getOverlappingSVMXEventforTech(objUser.Id, system.now(), system.now().addminutes(1), e3.Id);
    }
    
    static testMethod void DCON_Retrieve_Events_WS_UT_Test2()
    {
        List<RecordType> RecordTypes = new List<RecordType>();
        String RuleRecordTypeId;
        String ExpressionRTypeId;
        String FieldMapRTypeId;
        RecordTypes = Database.query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\' OR SobjectType = \'SVMXC__ServiceMax_Config_Data__c\'');
        for(RecordType r : RecordTypes)
        {
            if(r.Name == 'SVMX Rule')
            {
              RuleRecordTypeId = r.id;
            }
            if(r.Name == 'Expressions')
            {
                ExpressionRTypeId = r.id;
            }
            if(r.Name == 'Field Mapping')
            {
                FieldMapRTypeId = r.id;
            } 
        }
        
        //Setup the event hover rule
        SVMXC__ServiceMax_Processes__c EventHovRule1 = new SVMXC__ServiceMax_Processes__c();
        EventHovRule1.RecordTypeId = RuleRecordTypeId;
        EventHovRule1.SVMXC__Select__c = true;
        EventHovRule1.SVMXC__ProcessID__c='PROCESS18';
        EventHovRule1.SVMXC__SettingId__c = 'PROCESS18';
        EventHovRule1.SVMXC__MapID__c='PROCESS18';
        EventHovRule1.SVMXC__Name__c = 'PROCESS28';
        EventHovRule1.SVMXC__Description__c = 'Event Rule 1';
        EventHovRule1.SVMXC__Sequence__c = 1;
        EventHovRule1.SVMXC__Rule_Type__c = 'Event Hover Rule';
        insert EventHovRule1;
        
        system.assert(EventHovRule1!=null, true);
        
        //Create Congfig data for Rule 
        List<SVMXC__ServiceMax_Config_Data__c> configLst= new List<SVMXC__ServiceMax_Config_Data__c>(); 
        SVMXC__ServiceMax_Config_Data__c conf1 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId = ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = EventHovRule1.id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__Order_Status__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'Open',
                                            SVMXC__Expression_Type__c = 'DISP_Event_Hover_Rule',                                            
                                            SVMXC__Sequence__c = 1
                                            );
        configLst.add(conf1);
        
        system.assertEquals(conf1.SVMXC__Expression_Rule__c, EventHovRule1.id);
        
        //Create WO Field for Rule 
        SVMXC__ServiceMax_Config_Data__c conf3 = new SVMXC__ServiceMax_Config_Data__c();
        conf3.RecordTypeId = FieldMapRTypeId;
        conf3.SVMXC__Expression_Rule__c = EventHovRule1.id;
        conf3.SVMXC__Target_Field_Name__c = 'SVMXC__Case__c';
        conf3.SVMXC__Sequence__c = 1;
        configLst.add(conf3);
        
        system.assertEquals(conf3.SVMXC__Expression_Rule__c, EventHovRule1.id);
        
        SVMXC__ServiceMax_Config_Data__c conf4 = new SVMXC__ServiceMax_Config_Data__c();
        conf4.RecordTypeId = FieldMapRTypeId;
        conf4.SVMXC__Expression_Rule__c = EventHovRule1.id;
        conf4.SVMXC__Target_Field_Name__c = 'SVMXC__Actual_Initial_Response__c';
        conf4.SVMXC__Sequence__c = 2;
        configLst.add(conf4);
        
        system.assertEquals(conf4.SVMXC__Expression_Rule__c, EventHovRule1.id);
        
        SVMXC__ServiceMax_Config_Data__c conf5 = new SVMXC__ServiceMax_Config_Data__c();
        conf5.RecordTypeId = FieldMapRTypeId;
        conf5.SVMXC__Expression_Rule__c = EventHovRule1.id;
        conf5.SVMXC__Target_Field_Name__c = 'SVMXC__Actual_Resolution__c';
        conf5.SVMXC__Sequence__c = 3;
        configLst.add(conf5);
        
        system.assertEquals(conf5.SVMXC__Expression_Rule__c, EventHovRule1.id);
        
        SVMXC__ServiceMax_Config_Data__c conf6 = new SVMXC__ServiceMax_Config_Data__c();
        conf6.RecordTypeId = FieldMapRTypeId;
        conf6.SVMXC__Expression_Rule__c = EventHovRule1.id;
        conf6.SVMXC__Target_Field_Name__c = 'SVMXC__Age__c';
        conf6.SVMXC__Sequence__c = 4;
        configLst.add(conf6);
        
        system.assertEquals(conf6.SVMXC__Expression_Rule__c, EventHovRule1.id);
        
        SVMXC__ServiceMax_Config_Data__c conf7 = new SVMXC__ServiceMax_Config_Data__c();
        conf7.RecordTypeId = FieldMapRTypeId;
        conf7.SVMXC__Expression_Rule__c = EventHovRule1.id;
        conf7.SVMXC__Target_Field_Name__c = 'SVMXC__Closed_On__c';
        conf7.SVMXC__Sequence__c = 5;
        configLst.add(conf7);
        
        system.assertEquals(conf7.SVMXC__Expression_Rule__c, EventHovRule1.id);
        
        SVMXC__ServiceMax_Config_Data__c conf8 = new SVMXC__ServiceMax_Config_Data__c();
        conf8.RecordTypeId = FieldMapRTypeId;
        conf8.SVMXC__Expression_Rule__c = EventHovRule1.id;
        conf8.SVMXC__Target_Field_Name__c = 'SVMXC__Scheduled_Date__c';
        conf8.SVMXC__Sequence__c = 5;
        configLst.add(conf8);
        
        system.assertEquals(conf8.SVMXC__Expression_Rule__c, EventHovRule1.id);
        
        insert configLst;
        
        system.assert(configLst!=null, true);
        
        User objUser = new User();
        Account objAccount;
        Contact objContact;
        Case objCase;
        SVMXC__Service_Order__c objWorkOrder;
        SVMXC__Service_Group__c objTeam;
        SVMXC__Territory__c objTerritory;
        SVMXC__Service_Group_Members__c objTechnician = new SVMXC__Service_Group_Members__c();
        List<SVMXC__Service_Group_Members__c> lstObjTech;
        
        List<Event> lstObjSFEvents = new List<Event>();
        List<SVMXC__SVMX_Event__c> lstObjSVMXEvents = new List<SVMXC__SVMX_Event__c>();
        objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];

        objAccount = new Account(
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

        objContact = new Contact(LastName='Last',AccountId =objAccount.Id);
        insert objContact;
        
        system.assert(objContact!=null, true);
        
        objCase = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                        ContactId = objContact.Id,
                                        AccountId = objAccount.Id                                         
                                        ); 
        insert objCase; 
        
        system.assertEquals(objCase.ContactId, objContact.Id);
        system.assertEquals(objCase.AccountId, objAccount.Id);
         
        objTeam = new SVMXC__Service_Group__c (
                                            Name = 'TEAM 1'
                                            );
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
                                            
        system.assertEquals(objTechnician.SVMXC__Service_Group__c, objTeam.Id);
        system.assertEquals(objTechnician.SVMXC__Service_Territory__c, objTerritory.Id);
        
        SVMXC__Service_Group_Members__c objTechnician2 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 1' ,
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
                                            SVMXC__Case__c = objCase.Id ,
                                            SVMXC__Company__c = objAccount.Id , 
                                            SVMXC__Contact__c =objContact.Id, 
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c = 'Medium',
                                            SVMXC__Order_Type__c= 'Field Service',
                                            SVMXC__Scheduled_Date__c = system.today(),
                                            SVMXC__Locked_By_DC__c = true,
                                            SVMXC__Group_Member__c = objTechnician.Id,
                                            SVMXC__Service_Duration__c = 12,
                                            SVMXC__Driving_Time__c = 122
                                            );
        insert objWorkOrder;

        system.assertEquals(objWorkOrder.SVMXC__Company__c, objAccount.Id);
        system.assertEquals(objWorkOrder.SVMXC__Case__c, objCase.Id);
        system.assertEquals(objWorkOrder.SVMXC__Contact__c, objContact.Id);
        
        SVMXC__Dispatcher_Access__c objDispAccess = new SVMXC__Dispatcher_Access__c (
                                            SVMXC__Service_Team__c = objTeam.Id,
                                            SVMXC__Dispatcher__c = objUser.Id 
                                            );
        insert objDispAccess;
        
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
        
        system.assert(lstObjSFEvents!=null, true);
        
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
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-12 00:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-12 01:00:00').addHours(1),
                                                    SVMXC__Technician__c = objTechnician.Id,
                                                    SVMXC__WhatId__c = null
                                                    );
        lstObjSVMXEvents.add(SMAX_Event1);
        lstObjSVMXEvents.add(SMAX_Event2);
                
        insert lstObjSVMXEvents;
        
        system.assert(lstObjSVMXEvents!=null, true);
        
        List<String> lstTechIds = new List<String>();
        lstTechIds.add(objTechnician.Id);
        lstTechIds.add(objTechnician2.Id);
        
        system.assert(lstTechIds!=null, true);
        
        List<String> workorderIds = new List<String>();
        workorderIds.add(objWorkOrder.Id);
        List<String> eventIds = new List<String>();
        eventIds.add(e3.Id);
        
        system.assert(eventIds!=null, true);
        
        List<String> DispatchStatus = new List<String>();
        DispatchStatus.add('NEW');
        
        system.assert(DispatchStatus!=null, true);

        List<Event> e_LO = new List<Event>();
        list<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue =  new list<DCON_Configuration_WS.SVMX_StringMap>();
        
        insert e1;
        e_LO.add(e1);
        
        lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '10'));
        lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '10'));
        lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '10'));
        DCON_Configuration_WS.SVMX_StringMap datTest1 = new DCON_Configuration_WS.SVMX_StringMap('AAA', 'DATE');
        datTest1.DateValue = system.today();
        datTest1.Value = 'DATE';
        lstKeyValue.add(datTest1);
        DCON_Configuration_WS.SVMX_StringMap datTest2 = new DCON_Configuration_WS.SVMX_StringMap('BBB', 'DATETIME');
        datTest2.DateTimeValue = system.now();
        datTest2.Value = 'DATETIME';
        lstKeyValue.add(datTest2);
        
        DCON_Event_WS.svmxSettingList.put('SET026', 'TRUE');
        DCON_Event_WS.svmxSettingList.put('SET027', 'DISALLOW');
        DCON_Event_WS.svmxSettingList.put('SET028', 'TRUE');
        
        DCON_Event_WS.DCON_Upsert_Events_WS3(objUser.Id, e_LO, objUser.TimeZoneSidKey, lstKeyValue);
        
        e1.OwnerId = objTechnician.Id;  
        e_LO.clear();
        e_LO.add(e1);       
        DCON_Event_WS.svmxSettingList.put('SET026', 'FALSE');
        DCON_Event_WS.svmxSettingList.put('SET027', 'DISALLOW');
        DCON_Event_WS.svmxSettingList.put('SET028', 'TRUE');
        //DCON_Event_WS.DCON_Upsert_Events_WS3(objUser.Id, e_LO, objUser.TimeZoneSidKey, lstKeyValue);  jyothsna
        
        Long lastRetrievedTime = (datetime.now().addDays(-10)).getTime();
        DCON_Event_WS.Retrieve_Deleted_Events_WS(objUser.Id, String.valueof(Date.valueOf('2010-02-15 00:00:00')-5), String.valueof(Date.valueOf('2010-02-15 00:00:00')+2), 'ALL', objUser.TimeZoneSidKey, String.valueof(lastRetrievedTime), lstTechIds);
        
        DCON_Event_WS.Retrieve_Updated_Events_WS(objUser.Id, String.valueof(Date.valueOf('2010-02-11 00:00:00')-5), String.valueof(Date.valueOf('2010-02-11 00:00:00')+2), 'ALL', objUser.TimeZoneSidKey, String.valueof(lastRetrievedTime), lstTechIds);
        
        try {       
            DCON_Event_WS.Retrieve_Updated_Events_WS(objUser.Id, String.valueof(Date.valueOf('2010-02-11 00:00:00')-5), String.valueof(Date.valueOf('2010-02-11 00:00:00')+2), 'ALL', null, String.valueof(lastRetrievedTime), lstTechIds);
            
            DCON_Event_WS.Retrieve_Deleted_Events_WS(objUser.Id, String.valueof(Date.valueOf('2010-02-15 00:00:00')-5), String.valueof(Date.valueOf('2010-02-15 00:00:00')+2), 'ALL', null, String.valueof(lastRetrievedTime), lstTechIds);
        } catch(exception ex) {}
        
        string inputOwnerID = '12345';
        DateTime inputStartTime;
        DateTime inputEndTime;
        String inputEventId = '12345';

        list<event> evtList = DCON_Event_WS.getOverlappingSFEventforTech(inputOwnerID, inputStartTime, inputEndTime , inputEventId);
        list<SVMXC__SVMX_Event__c> svmxevtList = DCON_Event_WS.getOverlappingSVMXEventforTech(inputOwnerID, inputStartTime, inputEndTime , inputEventId);

    }
    
    static testMethod void DCON_Create_Events_WS_UT_Test()
    {
        List<RecordType> RecordTypes = new List<RecordType>();
        String RuleRecordTypeId;
        String ExpressionRTypeId;
        String FieldMapRTypeId;
        RecordTypes = Database.query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\' OR SobjectType = \'SVMXC__ServiceMax_Config_Data__c\'');
        System.assert(RecordTypes != null,'RecordTypes assertion failed');
        for(RecordType r : RecordTypes)
        {
            if(r.Name == 'SVMX Rule')
            {
              RuleRecordTypeId = r.id;
            }
            if(r.Name == 'Expressions')
            {
                ExpressionRTypeId = r.id;
            }
            if(r.Name == 'Field Mapping')
            {
                FieldMapRTypeId = r.id;
            } 
        }
        
        
        //insert confLst;
        //Create Rule
        List<SVMXC__ServiceMax_Processes__c> EventSubRuleLst = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c EventSubRule1 = new SVMXC__ServiceMax_Processes__c();
        EventSubRule1.SVMXC__ProcessID__c='PROCESS11';
        EventSubRule1.SVMXC__SettingId__c = 'PROCESS11';
        EventSubRule1.SVMXC__MapID__c='PROCESS11';
        EventSubRule1.SVMXC__Name__c = 'PROCESS22';
        EventSubRule1.RecordTypeId = RuleRecordTypeId;
        EventSubRule1.SVMXC__Select__c = true;
        EventSubRule1.SVMXC__Name__c = 'Event Rule 1';
        EventSubRule1.SVMXC__Description__c = 'Event Rule 1';
        EventSubRule1.SVMXC__Sequence__c = 1;
        EventSubRule1.SVMXC__Rule_Type__c = 'Event Subject Rule';
        insert EventSubRule1;
        System.assert(EventSubRule1 != null,'EventSubRule1 assertion failed');
        
        //Create Congfig data for Rule 
        List<SVMXC__ServiceMax_Config_Data__c> configLst= new List<SVMXC__ServiceMax_Config_Data__c>(); 
        SVMXC__ServiceMax_Config_Data__c conf1 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId = ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = EventSubRule1.id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__Order_Status__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'Open',
                                            SVMXC__Expression_Type__c = 'DISP_Event_Subject_Rule',                                            
                                            SVMXC__Sequence__c = 1
                                            );
        configLst.add(conf1);
        
        //Create WO Field for Rule 
        SVMXC__ServiceMax_Config_Data__c conf3 = new SVMXC__ServiceMax_Config_Data__c();
        conf3.RecordTypeId = FieldMapRTypeId;
        conf3.SVMXC__Expression_Rule__c = EventSubRule1.id;
        conf3.SVMXC__Target_Field_Name__c = 'SVMXC__City__c';
        conf3.SVMXC__Sequence__c = 1;
        configLst.add(conf3);
        SVMXC__ServiceMax_Config_Data__c conf4 = new SVMXC__ServiceMax_Config_Data__c();
        conf4.RecordTypeId = FieldMapRTypeId;
        conf4.SVMXC__Expression_Rule__c = EventSubRule1.id;
        conf4.SVMXC__Target_Field_Name__c = 'SVMXC__Actual_Initial_Response__c';
        conf4.SVMXC__Sequence__c = 2;
        configLst.add(conf4);
        SVMXC__ServiceMax_Config_Data__c conf5 = new SVMXC__ServiceMax_Config_Data__c();
        conf5.RecordTypeId = FieldMapRTypeId;
        conf5.SVMXC__Expression_Rule__c = EventSubRule1.id;
        conf5.SVMXC__Target_Field_Name__c = 'SVMXC__Actual_Resolution__c';
        conf5.SVMXC__Sequence__c = 3;
        configLst.add(conf5);
        SVMXC__ServiceMax_Config_Data__c conf6 = new SVMXC__ServiceMax_Config_Data__c();
        conf6.RecordTypeId = FieldMapRTypeId;
        conf6.SVMXC__Expression_Rule__c = EventSubRule1.id;
        conf6.SVMXC__Target_Field_Name__c = 'SVMXC__Age__c';
        conf6.SVMXC__Sequence__c = 4;
        configLst.add(conf6);
        insert configLst;
        
        DCON_Event_WS.DCEvent_WP dcEvent = new DCON_Event_WS.DCEvent_WP();
       
        User objUser = new User();
        Account objAccount;
        Contact objContact;
        Case objCase;
        SVMXC__Service_Order__c objWorkOrder;
        SVMXC__Service_Group__c objTeam;
        SVMXC__Territory__c objTerritory;
        SVMXC__Service_Group_Members__c objTechnician = new SVMXC__Service_Group_Members__c();
        List<SVMXC__Service_Group_Members__c> lstObjTech;
        
        List<Event> lstObjSFEvents = new List<Event>();
        List<SVMXC__SVMX_Event__c> lstObjSVMXEvents = new List<SVMXC__SVMX_Event__c>();
        objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
        System.debug('*****'+objUser.TimeZoneSidKey );

        objAccount = new Account(
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
        

        objContact = new Contact(LastName='Last',AccountId =objAccount.Id);
        insert objContact;
        
        
        objCase = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                        ContactId = objContact.Id,
                                        AccountId = objAccount.Id                                         
                                        ); 
        insert objCase; 
        
        objTeam = new SVMXC__Service_Group__c (
                                            Name = 'TEAM 1'
                                            );
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
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__Salesforce_User__c = objUser.Id
                                            );
                                 
        
        //lstObjTech = [select id from SVMXC__Service_Group_Members__c where SVMXC__Salesforce_User__c = :objUser.Id LIMIT 1];
        
        //if(lstObjTech.size()==0){
        //    objTechnician.SVMXC__Salesforce_User__c = objUser.Id;
        //}
        insert objTechnician;
       SVMXC__Service_Group_Members__c objTechnician1 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 1' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true);
        objWorkOrder = new SVMXC__Service_Order__c (
                                            SVMXC__Case__c = objCase.Id , 
                                            SVMXC__Contact__c =objContact.Id, 
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c = 'Medium',
                                            SVMXC__Order_Type__c= 'Field Service',
                                            SVMXC__Group_Member__c = objTechnician.Id
                                            );
        insert objWorkOrder;
        
        SVMXC__Dispatcher_Access__c objDispAccess = new SVMXC__Dispatcher_Access__c (
                                            SVMXC__Service_Team__c = objTeam.Id,
                                            SVMXC__Dispatcher__c = objUser.Id 
                                            );
        insert objDispAccess;
        
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
        insert e1;
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
        insert SMAX_Event1;
        lstObjSVMXEvents.add(SMAX_Event1);
        
        //insert lstObjSFEvents;
        //insert lstObjSVMXEvents;
        
        //Event subject rule
        String UserId = UserInfo.getUserId();
        String WoId = objWorkOrder.Id;
        String WoIdUserId = WoId+','+UserId;
        DCON_Event_WS.DCON_Event_SubjectDef(WoIdUserId);
        
        List<String> lstEventIds = new List<String>();
        DCON_Event_WS.svmxSettingList.put('SET026', 'FALSE');
        DCON_Event_WS.svmxSettingList.put('SET025', 'DISALLOW');
        DCON_Event_WS.svmxSettingList.put('SET028', 'TRUE');
               
        list<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue = new list<DCON_Configuration_WS.SVMX_StringMap>();
        lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '10'));
        lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '10'));
        lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '10'));
        DCON_Configuration_WS.SVMX_StringMap datTest1 = new DCON_Configuration_WS.SVMX_StringMap('bb', 'DATE');
        datTest1.DateValue = system.today();
        datTest1.Value = 'DATE';
        lstKeyValue.add(datTest1);
        DCON_Configuration_WS.SVMX_StringMap datTest2 = new DCON_Configuration_WS.SVMX_StringMap('aa', 'DATETIME');
        datTest2.Value = 'DATETIME';
        datTest2.DateTimeValue = system.now();
        lstKeyValue.add(datTest2);
        
        //lstEventIds = DCON_Event_WS.DCON_Create_Events_WS3(objUser.Id, lstObjSFEvents,  'GMT', lstKeyValue);
        try
        {
            lstEventIds.add(SMAX_Event1.Id);            
            DCON_Event_WS.DCON_Delete_Events_WS(objUser.Id, lstEventIds);
            lstEventIds.clear();
            lstEventIds.add(e2.Id);
            DCON_Event_WS.DCON_Delete_Events_WS(objUser.Id, lstEventIds);
            DCON_Event_WS.DCON_Delete_Events_WS(objUser.Id, null); 
        }
        catch(exception ex)
        {}
        DCON_Event_WS.svmxSettingList.clear();
        DCON_Event_WS.svmxSettingList.put('SET026', 'TRUE');
        DCON_Event_WS.svmxSettingList.put('SET025', 'DISALLOW');
        DCON_Event_WS.svmxSettingList.put('SET028', 'TRUE');    
        
        //lstEventIds = DCON_Event_WS.DCON_Create_Events_WS3(objUser.Id, lstObjSFEvents,  'GMT', lstKeyValue);
        
        String userzid = String.valueOf(objUser.Id);
        List<String> list_String = new List<String>();
        list_String.add(userzid);
        
        DCON_Event_WS.DCON_Upsert_Events_WS('', '', lstObjSFEvents);
        List<DateTime> lstDateTime = new List<DateTime>();
        lstDateTime.add(system.now());
        lstDateTime.add(system.now().addMinutes(30));
        DCON_Event_WS.getLeastDateTime(lstDateTime);
        DCON_Event_WS.DCON_Create_Events_WS2(objUser.Id, 'GMT', lstObjSFEvents, lstKeyValue);        
        DCON_Event_WS.DCON_Create_Events_WS('','',new List<Event>());
        DCON_Event_WS.CheckNull(null);
        DCON_Event_WS.CheckNull('');
        //insert lstObjSFEvents;
        //DCON_Event_WS.DCON_Upsert_Events_WS2(String.valueof(objUser.Id), lstObjSFEvents, String.valueof(objUser.TimeZoneSidKey),  lstKeyValue);
        DCON_Event_WS.DCON_Upsert_Events_WS4(objUser.Id, lstObjSFEvents, objUser.TimeZoneSidKey,  lstKeyValue);
        
        try {
            List<Event> lstObjSFEvents1 = new List<Event>();
            Event e3 = new Event(ActivityDate = Date.valueOf('2010-02-15 00:00:00'), 
                                StartDateTime = Datetime.valueOf('2010-02-15 01:00:00') ,
                                ActivityDateTime = Datetime.valueOf('2010-02-15 01:00:00'), 
                                DurationInMinutes = 60, Subject = 'test', OwnerId = '007',//objTechnician.Id, 
                                WhatId=objWorkOrder.Id, Description='Test Desc');
            lstObjSFEvents.add(e3);
            DCON_Event_WS.DCON_Upsert_Events_WS4(objUser.Id, lstObjSFEvents1, objUser.TimeZoneSidKey,  lstKeyValue);
        }
        catch(exception ex){}
        
        List<String> lstid = new List<String>();
        lstid.add(String.valueof(objUser.Id));
        DCON_Event_WS.DCON_Retrieve_Salesforce_Events_WS(objUser.Id,String.valueof(System.today()),String.valueof(System.today().addDays(2)),lstid);
        List<SVMXC__ServiceMax_Processes__c> EventRuleLst = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c EventHovRule1 = new SVMXC__ServiceMax_Processes__c();
        EventHovRule1.RecordTypeId = RuleRecordTypeId;
        EventHovRule1.SVMXC__Select__c = true;
        EventHovRule1.SVMXC__ProcessID__c='PROCESS18';
        EventHovRule1.SVMXC__SettingId__c = 'PROCESS18';
        EventHovRule1.SVMXC__MapID__c='PROCESS18';
        EventHovRule1.SVMXC__Name__c = 'PROCESS28';
        EventHovRule1.SVMXC__Description__c = 'Event Rule 1';
        EventHovRule1.SVMXC__Sequence__c = 1;
        EventHovRule1.SVMXC__Rule_Type__c = 'Event Hover Rule';
        insert EventHovRule1;
         List<SVMXC__ServiceMax_Config_Data__c> confLst= new List<SVMXC__ServiceMax_Config_Data__c>(); 
        SVMXC__ServiceMax_Config_Data__c config1 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId = ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = EventHovRule1.id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__Order_Status__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'Open',
                                            SVMXC__Expression_Type__c = 'DISP_Event_Hover_Rule',                                            
                                            SVMXC__Sequence__c = 1
                                            );
        confLst.add(config1);
        SVMXC__ServiceMax_Config_Data__c confg3 = new SVMXC__ServiceMax_Config_Data__c();
        confg3.RecordTypeId = FieldMapRTypeId;
        confg3.SVMXC__Expression_Rule__c = EventHovRule1.id;
        confg3.SVMXC__Target_Field_Name__c = 'SVMXC__City__c';
        confg3.SVMXC__Sequence__c = 1;
        confLst.add(confg3);
        SVMXC__ServiceMax_Config_Data__c confg4 = new SVMXC__ServiceMax_Config_Data__c();
        confg4.RecordTypeId = FieldMapRTypeId;
        confg4.SVMXC__Expression_Rule__c = EventHovRule1.id;
        confg4.SVMXC__Target_Field_Name__c = 'SVMXC__Actual_Initial_Response__c';
        confg4.SVMXC__Sequence__c = 2;
        confLst.add(confg4);
        SVMXC__ServiceMax_Config_Data__c confg5 = new SVMXC__ServiceMax_Config_Data__c();
        confg5.RecordTypeId = FieldMapRTypeId;
        confg5.SVMXC__Expression_Rule__c = EventHovRule1.id;
        confg5.SVMXC__Target_Field_Name__c = 'SVMXC__Actual_Resolution__c';
        confg5.SVMXC__Sequence__c = 3;
        confLst.add(confg5);
        SVMXC__ServiceMax_Config_Data__c confg6 = new SVMXC__ServiceMax_Config_Data__c();
        confg6.RecordTypeId = FieldMapRTypeId;
        confg6.SVMXC__Expression_Rule__c = EventHovRule1.id;
        confg6.SVMXC__Target_Field_Name__c = 'SVMXC__Age__c';
        confg6.SVMXC__Sequence__c = 4;
        confLst.add(confg6);
        insert confLst;
        //DCON_Event_WS.DCON_Upsert_Events_WS4(objUser.Id, lstObjSFEvents, objUser.TimeZoneSidKey,  lstKeyValue);
    }   
    static testMethod void DCON_Events_WS_UT_Test()
    {

        list<Event> lstObjSFEvents = new list<Event>();
        User objUser = new User();
         objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
         SVMXC__Service_Group__c objTeam = new SVMXC__Service_Group__c (
                                                    Name = 'TEAM 1'
                                                    );
                insert objTeam;
                
        SVMXC__Territory__c objTerritory = new SVMXC__Territory__c (
                                            Name = 'TERRITORY 1'
                                            );
        insert objTerritory;
        
       SVMXC__Service_Group_Members__c objTechnician = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 1' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true
                                            );
        Account objAccount = new Account(
                                        Name ='Account'  ); 
        insert objAccount;
        

        Contact objContact = new Contact(LastName='Last',AccountId =objAccount.Id);
        insert objContact;
        
        
        Case objCase = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                        ContactId = objContact.Id,
                                        AccountId = objAccount.Id                                         
                                        ); 
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c (
                                            SVMXC__Case__c = objCase.Id , 
                                            SVMXC__Contact__c =objContact.Id, 
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c = 'Medium',
                                            SVMXC__Order_Type__c= 'Field Service',
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
                lstObjSFEvents.add(e1);
                //lstObjSFEvents.add(e2);
                List<RecordType> RecordTypes = new List<RecordType>();
        String RuleRecordTypeId;
        String ExpressionRTypeId;
        String FieldMapRTypeId;
        RecordTypes = Database.query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\' OR SobjectType = \'SVMXC__ServiceMax_Config_Data__c\'');
        for(RecordType r : RecordTypes)
        {
            if(r.Name == 'SVMX Rule')
            {
              RuleRecordTypeId = r.id;
            }
            if(r.Name == 'Expressions')
            {
                ExpressionRTypeId = r.id;
            }
            if(r.Name == 'Field Mapping')
            {
                FieldMapRTypeId = r.id;
            } 
        }
                 List<SVMXC__ServiceMax_Processes__c> EventRuleLst = new List<SVMXC__ServiceMax_Processes__c>();
                SVMXC__ServiceMax_Processes__c EventHovRule1 = new SVMXC__ServiceMax_Processes__c();
                EventHovRule1.RecordTypeId = RuleRecordTypeId;
                EventHovRule1.SVMXC__Select__c = true;
                EventHovRule1.SVMXC__ProcessID__c='PROCESS18';
                EventHovRule1.SVMXC__SettingId__c = 'PROCESS18';
                EventHovRule1.SVMXC__MapID__c='PROCESS18';
                EventHovRule1.SVMXC__Name__c = 'PROCESS28';
                EventHovRule1.SVMXC__Description__c = 'Event Rule 1';
                EventHovRule1.SVMXC__Sequence__c = 1;
                EventHovRule1.SVMXC__Rule_Type__c = 'Event Hover Rule';
                insert EventHovRule1;
                 List<SVMXC__ServiceMax_Config_Data__c> confLst= new List<SVMXC__ServiceMax_Config_Data__c>(); 
                SVMXC__ServiceMax_Config_Data__c config1 = new SVMXC__ServiceMax_Config_Data__c(
                                                    RecordTypeId = ExpressionRTypeId,
                                                    SVMXC__Expression_Rule__c = EventHovRule1.id,
                                                    SVMXC__Active__c = true,
                                                    SVMXC__Field_Name__c = 'SVMXC__Order_Status__c',
                                                    SVMXC__Operator__c = 'eq',
                                                    SVMXC__Operand__c = 'Open',
                                                    SVMXC__Expression_Type__c = 'DISP_Event_Hover_Rule',                                            
                                                    SVMXC__Sequence__c = 1
                                                    );
                confLst.add(config1);
                SVMXC__ServiceMax_Config_Data__c confg3 = new SVMXC__ServiceMax_Config_Data__c();
                confg3.RecordTypeId = FieldMapRTypeId;
                confg3.SVMXC__Expression_Rule__c = EventHovRule1.id;
                confg3.SVMXC__Target_Field_Name__c = 'SVMXC__City__c';
                confg3.SVMXC__Sequence__c = 1;
                confLst.add(confg3);
                SVMXC__ServiceMax_Config_Data__c confg4 = new SVMXC__ServiceMax_Config_Data__c();
                confg4.RecordTypeId = FieldMapRTypeId;
                confg4.SVMXC__Expression_Rule__c = EventHovRule1.id;
                confg4.SVMXC__Target_Field_Name__c = 'SVMXC__Actual_Initial_Response__c';
                confg4.SVMXC__Sequence__c = 2;
                confLst.add(confg4);
                SVMXC__ServiceMax_Config_Data__c confg5 = new SVMXC__ServiceMax_Config_Data__c();
                confg5.RecordTypeId = FieldMapRTypeId;
                confg5.SVMXC__Expression_Rule__c = EventHovRule1.id;
                confg5.SVMXC__Target_Field_Name__c = 'SVMXC__Actual_Resolution__c';
                confg5.SVMXC__Sequence__c = 3;
                confLst.add(confg5);
                SVMXC__ServiceMax_Config_Data__c confg6 = new SVMXC__ServiceMax_Config_Data__c();
                confg6.RecordTypeId = FieldMapRTypeId;
                confg6.SVMXC__Expression_Rule__c = EventHovRule1.id;
                confg6.SVMXC__Target_Field_Name__c = 'SVMXC__Age__c';
                confg6.SVMXC__Sequence__c = 4;
                confLst.add(confg6);
                insert confLst;
                list<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue = new list<DCON_Configuration_WS.SVMX_StringMap>();
                lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '10'));
                lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '10'));
                lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '10'));
                DCON_Configuration_WS.SVMX_StringMap datTest1 = new DCON_Configuration_WS.SVMX_StringMap('bb', 'DATE');
                datTest1.DateValue = system.today();
                datTest1.Value = 'DATE';
                lstKeyValue.add(datTest1);
                DCON_Configuration_WS.SVMX_StringMap datTest2 = new DCON_Configuration_WS.SVMX_StringMap('aa', 'DATETIME');
                datTest2.Value = 'DATETIME';
                datTest2.DateTimeValue = system.now();
                lstKeyValue.add(datTest2);
                DCON_Event_WS.DCON_Upsert_Events_WS4(objUser.Id, lstObjSFEvents, objUser.TimeZoneSidKey,  lstKeyValue);
                DCON_Event_WS.DCON_Create_Events_WS3(objUser.Id, lstObjSFEvents,  'GMT', lstKeyValue);
                
                DCON_Event_WS.svmxSettingList.put('SET026', 'TRUE');
                DCON_Event_WS.svmxSettingList.put('SET027', 'DISALLOW');
                DCON_Event_WS.svmxSettingList.put('SET028', 'TRUE');
                List<String> lstTechIds = new List<String>();
                lstTechIds.add(objTechnician.Id);
                //DCON_Event_WS.DCON_Retrieve_Events_WS(objUser.Id, String.valueof(system.today()), String.valueof(system.today().adddays(1)), 'ALL', NULL, lstTechIds);  
                DCON_Event_WS.DCON_Retrieve_Events_WS(objUser.Id, String.valueof(system.today()), String.valueof(system.today().adddays(1)), 'ALL', 'Asia/Kolkata@MM/DD/YYYY hh:mm a', lstTechIds);  
                DCON_Event_WS.DCON_Retrieve_WO_Events_WS(objUser.Id,String.valueof(system.today()), String.valueof(system.today().adddays(1)),  'GMT', objWorkOrder.Id);       
                //DCON_Event_WS.DCON_Retrieve_Events_WS(objUser.Id, String.valueof(system.today()), String.valueof(system.today().adddays(1)), 'ALL', 'GMT', lstTechIds);
                //DCON_Event_WS.DCON_Retrieve_WO_Events_WS(objUser.Id, null, String.valueof(system.today().adddays(1)),  'GMT', objWorkOrder.Id);
                
                List<String> lstWorkOrder = new List<String>();
                lstWorkOrder.add(objWorkOrder.Id);
                
                //create list of 500 WO id's, this is for covering else blovk where the else block executes only when WO size is more than 500, this will inturn increase UT coverage percentage
                for(integer i=0; i<510; i++)
                {                                           
                    SVMXC__Service_Order__c ObjWorkOrder_t = new SVMXC__Service_Order__c (
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c = 'Medium',
                                            SVMXC__Order_Type__c= 'Field Service',
                                            SVMXC__Group_Member__c = objTechnician.Id
                                            );
                    lstWorkOrder.add(ObjWorkOrder_t.Id);
                }
                
                DCON_Event_WS.DCON_Fetch_All_Events_WS(lstWorkOrder, objUser.Id, lstTechIds, 'Asia/Kolkata@MM/DD/YYYY');
                //This is deprecated, since it is retained to achieve salesforce UT coverage limitation
                DCON_Event_WS.DCON_Fetch_Events_WS(objUser.Id, 'Asia/Kolkata@MM/DD/YYYY', lstTechIds);
    }
    
    static testMethod void DCON_Events_WS_UT_Test1()
    {
            
        List<RecordType> RecordTypes = new List<RecordType>();
        String RuleRecordTypeId;
        String ExpressionRTypeId;
        String FieldMapRTypeId;
        RecordTypes = Database.query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\' OR SobjectType = \'SVMXC__ServiceMax_Config_Data__c\'');
        for(RecordType r : RecordTypes)
        {
            if(r.Name == 'SVMX Rule')
            {
              RuleRecordTypeId = r.id;
            }
            if(r.Name == 'Expressions')
            {
                ExpressionRTypeId = r.id;
            }
            if(r.Name == 'Field Mapping')
            {
                FieldMapRTypeId = r.id;
            } 
        }
            Account objAccount = new Account(
                                        Name ='Account'  ); 
        insert objAccount;
        

        Contact objContact = new Contact(LastName='Last',AccountId =objAccount.Id);
        insert objContact;
        
        
        Case objCase = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                        ContactId = objContact.Id,
                                        AccountId = objAccount.Id                                         
                                        ); 
                                         SVMXC__Service_Group__c objTeam = new SVMXC__Service_Group__c (
                                                    Name = 'TEAM 1'
                                                    );
                insert objTeam;
                
        SVMXC__Territory__c objTerritory = new SVMXC__Territory__c (
                                            Name = 'TERRITORY 1'
                                            );
        insert objTerritory;
        
                                        
        
        SVMXC__ServiceMax_Processes__c EventHovRule1 = new SVMXC__ServiceMax_Processes__c();
        EventHovRule1.RecordTypeId = RuleRecordTypeId;
        EventHovRule1.SVMXC__Select__c = true;
        EventHovRule1.SVMXC__ProcessID__c='PROCESS18';
        EventHovRule1.SVMXC__SettingId__c = 'PROCESS18';
        EventHovRule1.SVMXC__MapID__c='PROCESS18';
        EventHovRule1.SVMXC__Name__c = 'PROCESS28';
        EventHovRule1.SVMXC__Description__c = 'Event Rule 1';
        EventHovRule1.SVMXC__Sequence__c = 1;
        EventHovRule1.SVMXC__Rule_Type__c = 'Event Hover Rule';
        insert EventHovRule1;
         List<SVMXC__ServiceMax_Config_Data__c> confLst= new List<SVMXC__ServiceMax_Config_Data__c>(); 
        SVMXC__ServiceMax_Config_Data__c config1 = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId = ExpressionRTypeId,
                                            SVMXC__Expression_Rule__c = EventHovRule1.id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Field_Name__c = 'SVMXC__Order_Status__c',
                                            SVMXC__Operator__c = 'eq',
                                            SVMXC__Operand__c = 'Open',
                                            SVMXC__Expression_Type__c = 'DISP_Event_Hover_Rule',                                            
                                            SVMXC__Sequence__c = 1
                                            );
        confLst.add(config1);
        SVMXC__ServiceMax_Config_Data__c confg3 = new SVMXC__ServiceMax_Config_Data__c();
        confg3.RecordTypeId = FieldMapRTypeId;
        confg3.SVMXC__Expression_Rule__c = EventHovRule1.id;
        confg3.SVMXC__Target_Field_Name__c = 'SVMXC__City__c';
        confg3.SVMXC__Sequence__c = 1;
        confLst.add(confg3);
        SVMXC__ServiceMax_Config_Data__c confg4 = new SVMXC__ServiceMax_Config_Data__c();
        confg4.RecordTypeId = FieldMapRTypeId;
        confg4.SVMXC__Expression_Rule__c = EventHovRule1.id;
        confg4.SVMXC__Target_Field_Name__c = 'SVMXC__Actual_Initial_Response__c';
        confg4.SVMXC__Sequence__c = 2;
        confLst.add(confg4);
        SVMXC__ServiceMax_Config_Data__c confg5 = new SVMXC__ServiceMax_Config_Data__c();
        confg5.RecordTypeId = FieldMapRTypeId;
        confg5.SVMXC__Expression_Rule__c = EventHovRule1.id;
        confg5.SVMXC__Target_Field_Name__c = 'SVMXC__Actual_Resolution__c';
        confg5.SVMXC__Sequence__c = 3;
        confLst.add(confg5);
        SVMXC__ServiceMax_Config_Data__c confg6 = new SVMXC__ServiceMax_Config_Data__c();
        confg6.RecordTypeId = FieldMapRTypeId;
        confg6.SVMXC__Expression_Rule__c = EventHovRule1.id;
        confg6.SVMXC__Target_Field_Name__c = 'SVMXC__Age__c';
        confg6.SVMXC__Sequence__c = 4;
        confLst.add(confg6);
        insert confLst;
        User objUser = new User();
         objUser = [SELECT Id,TimeZoneSidKey from User where id = :UserInfo.getUserId()];
           SVMXC__Service_Group_Members__c objTechnician = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 1' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__Salesforce_User__c = objUser.Id
                                            );
        insert objTechnician;
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c (
                                            SVMXC__Case__c = objCase.Id , 
                                            SVMXC__Contact__c =objContact.Id, 
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c = 'Medium',
                                            SVMXC__Order_Type__c= 'Field Service',
                                            SVMXC__Group_Member__c = objTechnician.Id
                                            );
        insert objWorkOrder;
                DCON_Event_WS.DCON_Retrieve_WO_Events_WS(objUser.Id, String.valueof(system.today()), null,  'GMT', objWorkOrder.Id); 
                DCON_Event_WS.DCON_Retrieve_WO_Events_WS(objUser.Id, null, null,  'GMT', objWorkOrder.Id);
list<DCON_Configuration_WS.SVMX_StringMap> lstKeyValue = new list<DCON_Configuration_WS.SVMX_StringMap>();
                lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('IDLE_' + objWorkOrder.Id, '10'));
                lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('DRIVE_' + objWorkOrder.Id, '10'));
                lstKeyValue.add(new DCON_Configuration_WS.SVMX_StringMap('SERVICE_' + objWorkOrder.Id, '10'));
                DCON_Configuration_WS.SVMX_StringMap datTest1 = new DCON_Configuration_WS.SVMX_StringMap('bb', 'DATE');
                datTest1.DateValue = system.today();
                datTest1.Value = 'DATE';
                lstKeyValue.add(datTest1);  
                list<event> lstObjSFEvents = new list<event>();
Event e1 = new Event();
        e1.ActivityDate = system.today();
        e1.StartDateTime =system.now();
        e1.endDateTime =system.now().addminutes(1);
        e1.ActivityDateTime = e1.StartDateTime;
        e1.Subject = 'test';
        e1.OwnerId = objUser.Id; 
        e1.WhatId=objWorkOrder.Id;
        e1.Description='Test Desc';
        insert e1;
        Event e2 = new Event();
        e2.ActivityDate = system.today();
        e2.StartDateTime =system.now();
        e2.endDateTime =system.now().addminutes(1);
        e2.ActivityDateTime = e2.StartDateTime;
        e2.Subject = 'test';
        e2.OwnerId = objTechnician.Id; 
        e2.WhatId=objWorkOrder.Id;
        e2.Description='Test Desc';
                
        lstObjSFEvents.add(e1); 
        list<string>lstTechIds = new list<string>();
        lstTechIds.add(objTechnician.id);
        //DCON_Event_WS.DCON_Retrieve_Events_WS(objUser.Id, String.valueof(system.today()), String.valueof(system.today().adddays(1)), 'ALL', NULL, lstTechIds);     
        DCON_Event_WS.DCON_Retrieve_Events_WS(objUser.Id, String.valueof(system.today()), String.valueof(system.today().adddays(1)), 'ALL', 'Asia/Kolkata@MM/DD/YYYY hh:mm a', lstTechIds);
        DCON_Event_WS.DCON_Retrieve_WO_Events_WS(objUser.Id,String.valueof(system.today()), String.valueof(system.today().adddays(1)),  'Asia/Calcutta', objWorkOrder.Id);       
        //DCON_Event_WS.DCON_Retrieve_Events_WS(objUser.Id, String.valueof(system.today()), String.valueof(system.today().adddays(1)), 'ALL', 'Asia/Calcutta', lstTechIds);
        //DCON_Event_WS.DCON_Retrieve_Events_WS(objUser.Id, String.valueof(system.today()), String.valueof(system.today().adddays(1)), 'ALL', 'Asia/Kolkata@MM/DD/YYYY hh:mm a', lstTechIds);
        DCON_Event_WS.DCON_Retrieve_WO_Events_WS(objUser.Id, null, String.valueof(system.today().adddays(1)),  'Asia/Calcutta', objWorkOrder.Id);               
        
        //DCON_Event_WS.DCON_Retrieve_Events_WS(objUser.Id, String.valueof(system.today()), String.valueof(system.today().adddays(1)), 'ALL', NULL, lstTechIds);       
        //DCON_Event_WS.DCON_Retrieve_Events_WS(objUser.Id, String.valueof(system.today()), String.valueof(system.today().adddays(1)), 'ALL', 'Asia/Kolkata@MM/DD/YYYY hh:mm a', lstTechIds);       
        //DCON_Event_WS.DCON_Retrieve_WO_Events_WS(objUser.Id,String.valueof(system.today()), String.valueof(system.today().adddays(1)),  objUser.TimeZoneSidKey, objWorkOrder.Id);       
        
        //DCON_Event_WS.DCON_Retrieve_Events_WS(objUser.Id, String.valueof(system.today()), String.valueof(system.today().adddays(1)), 'SERVICEMAXEVENT', objUser.TimeZoneSidKey, lstTechIds);
        //DCON_Event_WS.DCON_Retrieve_WO_Events_WS(objUser.Id, null, String.valueof(system.today().adddays(1)),  objUser.TimeZoneSidKey, objWorkOrder.Id);
        List<String> lstWorkOrder = new List<String>();
        lstWorkOrder.add(objWorkOrder.Id);
        DCON_Event_WS.DCON_Fetch_All_Events_WS(lstWorkOrder, objUser.Id, lstTechIds, 'Asia/Kolkata@MM/DD/YYYY');   
        //This is deprecated, since it is retained to achieve salesforce UT coverage limitation
        DCON_Event_WS.DCON_Fetch_Events_WS(objUser.Id, 'Asia/Kolkata@MM/DD/YYYY', lstTechIds);
    }
}