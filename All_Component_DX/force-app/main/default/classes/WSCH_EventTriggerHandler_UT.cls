@isTest(SeeAllData=true)
public with sharing class WSCH_EventTriggerHandler_UT {
static testMethod void testNonWOSvmxEventCreate() {
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
        SVMXC__Service_Group_Members__c technician1 = new SVMXC__Service_Group_Members__c();
        technician1.Name = 'John';
        technician1.SVMXC__Optimizer_External_ID__c = 'TM001';
        technician1.SVMXC__Service_Group__c  = team.Id;
        technician1.SVMXC__Service_Territory__c = territory1.Id;
        technician1.SVMXC__Salesforce_User__c = UserInfo.getUserId();
        
        insert technician1;
        
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
                                            SVMXC__SM_Scheduling_Options__c = 'All options disabled'
                                            );
         upsert svo;
        //END: MEM field updates 
        
        
        event sfEvent = new event();
        sfEvent.WhatId = svo.Id;
        sfEvent.StartDateTime = DateTime.now();
        sfEvent.EndDateTime = DateTime.now().addHours(1);
        sfEvent.ownerid = userinfo.getuserid();
        sfEvent.SVMXC__Service_Duration__c = 3600;
        sfEvent.WhatId = svo.Id;
        insert sfEvent;
        
        SVMXC__SVMX_Event__c svmxEvent= new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-12 00:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-12 01:00:00').addHours(1),
                                                    SVMXC__Technician__c =  technician.Id,
                                                    SVMXC__Service_Duration__c = 3600,
                                                    SVMXC__WhatId__c = svo.Id,
                                                    SVMXC__Service_Order__c = svo.Id
                                                    );

        insert svmxEvent;

        list<SVMXC__SVMX_Event__c> lstSVMXEvent = new list<SVMXC__SVMX_Event__c>();
        list<SVMXC__SVMX_Event__c> lstSVMXEvent1 = new list<SVMXC__SVMX_Event__c>();
        list<Event> lstSFEvent = new list<event>();
        lstSVMXEvent.add(svmxEvent);
        lstSFEvent.add(sfEvent);
        WSCH_EventTriggerHandler.handleSFEventInsert(lstSFEvent);
        WSCH_EventTriggerHandler.handleSVMXEventInsert(lstSVMXEvent);
        
        event sfEvent1 = new event();
        sfEvent1.StartDateTime = DateTime.now();
        sfEvent1.EndDateTime = DateTime.now().addHours(1);
        sfEvent1.ownerid = userinfo.getuserid();
        sfEvent1.SVMXC__Service_Duration__c = 3600;
        sfEvent1.WhatId = svo.Id;
        lstSFEvent.add(sfEvent1);
        WSCH_EventTriggerHandler.handleSFEventBeforeInsert(lstSFEvent); 
        
        
       
        svmxEvent.SVMXC__Technician__c = technician1.Id;
        update svmxEvent; 
        lstSVMXEvent1.add(svmxEvent);
        WSCH_EventTriggerHandler.handleSFEventBeforeInsert(lstSFEvent);
        WSCH_EventTriggerHandler.handleSVMXEventUpdate(lstSVMXEvent,lstSVMXEvent1);
        WSCH_EventTriggerHandler.handleSVMXEventDelete(lstSVMXEvent);
        WSCH_EventTriggerHandler.handleSFEventUpdate(lstSFEvent,lstSFEvent);
        WSCH_EventTriggerHandler.handleSFEventDelete(lstSFEvent);
        SVMXC__SVMX_Optimizer__c svmxOptimizer = new SVMXC__SVMX_Optimizer__c();
        svmxOptimizer.SVMXC__WhatId__c = svmxEvent.Id;
        svmxOptimizer.SVMXC__Optimizer_External_Id__c = String.valueOf(1234);
        
        insert svmxOptimizer;
        
        List<String> optimizerIdList = new List<String>();
        optimizerIdList.add(svmxOptimizer.Id);
        
        svmxOptimizer.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CREATE';
        
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_EventTriggerHandler.manageNonWorkOrderEvents(optimizerIdList,null);
        
        SVMXC__SVMX_Optimizer__c svmxOptimizer1 =WSCH_EventTriggerHandler.getOptimizerObject('eventId','CHANGE_CREATE');

        svmxOptimizer.SVMXC__Optimizer_Change_Token__c = 'CHANGE_UPDATE';
        
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_EventTriggerHandler.manageNonWorkOrderEvents(optimizerIdList,null);
                
        Test.stopTest();
    }
}