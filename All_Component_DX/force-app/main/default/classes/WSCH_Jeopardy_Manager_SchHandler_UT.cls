@isTest(SeeAllData=true)
public with sharing class WSCH_Jeopardy_Manager_SchHandler_UT {
    Public  WSCH_Jeopardy_Manager_SchHandler_UT ()
    {}
    static
    {
        WSCH_Jeopardy_Manager_SchHandler_UT obj = new WSCH_Jeopardy_Manager_SchHandler_UT();
    }
    static testMethod void WSCH_Jeopardy_Manager_SchHandler_test() 
    {
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
        
        List<SVMXC__Service_Group_Members__c> lsttech = new List<SVMXC__Service_Group_Members__c>();
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'John';
        technician.SVMXC__Optimizer_External_ID__c = 'TM001';
        technician.SVMXC__Latitude__c = 40.739582; 
        technician.SVMXC__Longitude__c = -73.980772;
        technician.SVMXC__Service_Group__c  = team.Id;
        technician.SVMXC__Service_Territory__c = territory1.Id;
        technician.SVMXC__Enable_Scheduling__c = true;
        technician.SVMXC__Salesforce_User__c = UserInfo.getUserId();
        
        lsttech.add(technician);
        SVMXC__Service_Group_Members__c technician1 = new SVMXC__Service_Group_Members__c();
        technician1.Name = 'John1';
        technician1.SVMXC__Optimizer_External_ID__c = 'TM001';
        technician1.SVMXC__Service_Group__c  = team.Id;
        technician1.SVMXC__Service_Territory__c = territory1.Id;
        technician1.SVMXC__Salesforce_User__c = UserInfo.getUserId();
        
        lsttech.add(technician1);
        insert lsttech;
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
        
        List<String> lstDispProcess = new List<String>();
        lstDispProcess.add('Real Time Optimization');
        lstDispProcess.add('Optimized Batch');
        
        Map<Id,SVMXC__ServiceMax_Processes__c> mapSVMXProcess = new Map<Id,SVMXC__ServiceMax_Processes__c>();
        mapSVMXProcess.putAll([SELECT Id from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Dispatch Process' and SVMXC__Dispatch_Method__c IN : lstDispProcess order by SVMXC__Sequence__c]);
        
        List<Id> dispProcessIds = new List<Id>();
        dispProcessIds.addAll(mapSVMXProcess.keySet());
        
        List<SVMXC__Service_Order__c> lstWo = new List<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c svo = new SVMXC__Service_Order__c (
                                            SVMXC__Company__c = account.Id , 
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c ='Medium',
                                            SVMXC__Order_Type__c='Field Service',
                                            SVMXC__Locked_By_DC__c = true,
                                            SVMXC__SM_Scheduling_Options__c = 'JDM Enabled, LJS Disabled',
                                            SVMXC__SM_Estimated_Duration__c = 7200,
                                            SVMXC__Service_Duration__c = 3600,
                                            SVMXC__Preferred_End_Time__c = system.now(),
                                            SVMXC__Dispatch_Process__c = dispProcessIds.get(0),
                                            SVMXC__Scheduled_Date_Time__c = system.now(),
                                            SVMXC__Work_Order_Scheduling_Status__c = 'Received',
                                            SVMXC__Driving_Time__c = 10
                                            );
         lstWo.add(svo);    
         SVMXC__Service_Order__c svo1 = new SVMXC__Service_Order__c (
                                            SVMXC__Company__c = account.Id , 
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c ='Medium',
                                            SVMXC__Order_Type__c='Field Service',
                                            SVMXC__Locked_By_DC__c = true,
                                            SVMXC__SM_Scheduling_Options__c = 'JDM Enabled, LJS Disabled',
                                            SVMXC__SM_Estimated_Duration__c = 7200,
                                            SVMXC__Service_Duration__c = 3600,
                                            SVMXC__Preferred_End_Time__c = system.now(),
                                            SVMXC__Dispatch_Process__c = dispProcessIds.get(0),
                                            SVMXC__Scheduled_Date_Time__c = system.now(),
                                            SVMXC__Work_Order_Scheduling_Status__c = 'Onsite',
                                            SVMXC__Driving_Time__c = 10,
                                            SVMXC__Group_Member__c = technician.Id,
                                            SVMXC__SM_In_Jeopardy__c = true
                                            );
         lstWo.add(svo1);   
        SVMXC__Service_Order__c svo2 = new SVMXC__Service_Order__c (
                                            SVMXC__Company__c = account.Id , 
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c ='Medium',
                                            SVMXC__Order_Type__c='Field Service',
                                            SVMXC__Locked_By_DC__c = true,
                                            SVMXC__SM_Scheduling_Options__c = 'JDM Enabled, LJS Disabled',
                                            SVMXC__SM_Estimated_Duration__c = 7200,
                                            SVMXC__Service_Duration__c = 3600,
                                            SVMXC__Preferred_End_Time__c = system.now(),
                                            SVMXC__Dispatch_Process__c = dispProcessIds.get(0),
                                            SVMXC__Scheduled_Date_Time__c = system.now(),
                                            SVMXC__Work_Order_Scheduling_Status__c = 'Received',
                                            SVMXC__Driving_Time__c = 10,
                                            SVMXC__Group_Member__c = technician.Id
                                            );
        lstWo.add(svo2);    
        SVMXC__Service_Order__c svo3 = new SVMXC__Service_Order__c (
                                            SVMXC__Company__c = account.Id , 
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c ='Medium',
                                            SVMXC__Order_Type__c='Field Service',
                                            SVMXC__Locked_By_DC__c = true,
                                            SVMXC__SM_Scheduling_Options__c = 'JDM Enabled, LJS Disabled',
                                            SVMXC__SM_Estimated_Duration__c = 7200,
                                            SVMXC__Service_Duration__c = 3600,
                                            SVMXC__Preferred_End_Time__c = system.now(),
                                            SVMXC__Dispatch_Process__c = dispProcessIds.get(0),
                                            SVMXC__Scheduled_Date_Time__c = system.now().addHours(1),
                                            SVMXC__Work_Order_Scheduling_Status__c = 'Received',
                                            SVMXC__Driving_Time__c = 10,
                                            SVMXC__Group_Member__c = technician.Id
                                            );
         lstWo.add(svo3);            
         upsert lstWo; 
         WSCH_Jeopardy_Manager_SchHandler Jm = new WSCH_Jeopardy_Manager_SchHandler();
         WSCH_Jeopardy_Manager_SchHandler.undoJeopardyAfterTechUpdate();
         WSCH_Jeopardy_Manager_SchHandler.getWOInJeopardy_For_Unresourced_Unscheduled();
         WSCH_Jeopardy_Manager_SchHandler.getWOInJeopardy_Scheduled_NotProgressing();
         WSCH_Jeopardy_Manager_SchHandler.getWOInCascadingJeopardy();
    }
}