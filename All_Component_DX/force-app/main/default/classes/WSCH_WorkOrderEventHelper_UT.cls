@isTest(seeAllData = true)
public with sharing class WSCH_WorkOrderEventHelper_UT {

    private static SVMXC__Service_Order__c workorder;

   //================================================ TestCase1 =============================================//
    static testMethod void WSCH_WorkOrderEventHelper_UT_Test()
    {
        COMM_SecurityUtils.getInstance().isSecurityCheckEnabled = false;
        Profile Prof = [Select p.Id From Profile p where Name like 'System Administrator' limit 1][0];
        User objU;
        objU = new User(
            LastName = 'objULastName',
            Alias = 'obAlias',
            Email = 'objUAlias@example.com',
            Username = 'objUAliasUSRNM@example.com',
            CommunityNickname  = 'objUNick',
            IsActive = true,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = Prof.Id,
            LanguageLocaleKey = 'en_US',
            Department = 'Corporate Sales');
        insert objU;
        
        //Profile Prof = [Select p.Id From Profile p where Name like 'System Administrator' limit 1][0];
        //List<User> usrList = [SELECT ID, UserName, ProfileId FROM User WHERE ProfileId != :Prof.id AND isActive=true LIMIT 1];

        workorder = new SVMXC__Service_Order__c(
                                        SVMXC__Order_Status__c = 'Open',
                                        SVMXC__Priority__c = 'Medium',
                                        SVMXC__Order_Type__c = 'Field Service',
                                        SVMXC__zip__c='560001',
                                        SVMXC__City__c='Bangalore',
                                        ownerID = objU.id,
                                        //ownerID = usrList[0].id,
                                        SVMXC__Clock_Paused_Forever__c= false,
                                        SVMXC__Customer_Down__c= false,
                                        SVMXC__IsPartnerRecord__c= false,
                                        SVMXC__Is_PM_Work_Order__c= false,
                                        SVMXC__Is_SLA_Calculated__c= false,
                                        SVMXC__OptiMax_Error_Occurred__c= false,
                                        SVMXC__PM_Tasks_Created__c= false,
                                        SVMXC__SLA_Clock_Paused__c= false,
                                        SVMXC__Apply_Business_Hours_For_OptiMax__c= false,
                                        SVMXC__Locked_By_DC__c= false,
                                        SVMXC__Perform_Auto_Entitlement__c= false,
                                        SVMXC__Invoice_Created__c= false,
                                        SVMXC__Is_Service_Covered__c= false,
                                        SVMXC__Is_Entitlement_Performed__c= false,
                                        SVMXC__Is_Exported__c= false,
                                        SVMXC__Drip__c= false,
                                        SVMXC__Schedule_As_A_Dependent_Work_Order__c= false,
                                        SVMXC__SM_Ok_To_Arrive_Early__c = false,
                                        SVMXC__SM_In_Jeopardy__c = false,
                                        SVMXC__SM_Crew_Assignment__c = false,
                                        SVMXC__SM_Multi_resource__c = false,
                                        SVMXC__SM_Is_Change_Order__c = false
                                         );

        insert workorder;
        List<SVMXC__Service_Order__c> workOrders = new List<SVMXC__Service_Order__c>();
        workOrders.add(workorder);

        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'testTeam';

        insert team;

        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'John';
        technician.SVMXC__Optimizer_External_ID__c = 'TM001';
        technician.SVMXC__Service_Group__c  = team.Id;

        insert technician;

        //SVMXC__Service_Group_Members__c tech = [SELECT Id,Name FROM SVMXC__Service_Order__c WHERE Id =: workOrder1.Id];
        //workOrder2.SVMXC__Zip__c = '75001';
        List <String> lstStrFlds = new List<String>();
        
        Test.startTest();

        WSCH_WorkOrderResponse response = new WSCH_WorkOrderResponse();
        WSCH_TechnicianEvent techEvent = new WSCH_TechnicianEvent();
        List<WSCH_TechnicianEvent> techEventList = new List<WSCH_TechnicianEvent>();

        techEvent.setArrivalDateTime(DateTime.now().addHours(1));
        techEvent.setDispatchStatus('Tentative');
        techEvent.setFinishDateTime(DateTime.now().addHours(2));
        techEvent.setStartDateTime(DateTime.now());
        //techEvent.setTechnicianExternalID('TM001');
        techEvent.setTechnicianExternalID(technician.SVMXC__Optimizer_External_ID__c);
        techEvent.setWorkOrderID(workorder.Id);
        techEventList.add(techEvent);

        response.setLstTechEvent(techEventList);
        response.setLstWorkOrder(workOrders);

        WSCH_WorkOrderEventHelper.processWorkOrderResponse(response);
        
        WSCH_Provider_SP_DispatchClientHelper.updateDripFeedList(workOrders, true);
        lstStrFlds = WSCH_Provider_SP_DispatchClientHelper.fetchQueryFields('SVMXC__Service_Order__c');
        WSCH_Provider_SP_DispatchClientHelper.updateObject(lstStrFlds, true, workOrders);
        WSCH_Provider_SP_DispatchClientHelper.updateObject(lstStrFlds, false, workOrders);
        
        technician.SVMXC__Salesforce_User__c = objU.Id;
        //technician.SVMXC__Salesforce_User__c = usrList[0].id;
        update technician;
        workorder.SVMXC__OptiMax_Status__c = 'OPT_COMPLETED';
        update workorder;
        WSCH_WorkOrderEventHelper.processWorkOrderResponse(response);
        WSCH_WorkOrderEventHelper.unscheduleWorkOrder(workorder);

        Test.stopTest();
    }
}