/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest()
private class WSCH_LTP_Scheduling_Stubs_UT {

    static testMethod void testLTPstubs() {
        Test.startTest();
        WSCH_LTP_Scheduling_Stubs ltpStubs = new WSCH_LTP_Scheduling_Stubs();
        
        WSCH_LTP_Scheduling_Stubs.InitJobRequest_WP initJobRequest_WP = new WSCH_LTP_Scheduling_Stubs.InitJobRequest_WP();
        initJobRequest_WP.dispatchProcessGuid = 'dpId';
        initJobRequest_WP.territoryGuid = 'territoryId';
        initJobRequest_WP.orgGuid = 'orgId';
        initJobRequest_WP.jobInstanceId = 'jobInstanceId';
        initJobRequest_WP.dispatchMethod = 'dispatchMethod';
        
        WSCH_LTP_Scheduling_Stubs.InitJobResponse_WP initJobResponse_WP = new WSCH_LTP_Scheduling_Stubs.InitJobResponse_WP();
        initJobResponse_WP.jobInstanceId = 'jobInstanceId';
        initJobResponse_WP.jobInstanceGuid = 'jobInstanceGuId';
        
        WSCH_LTP_Scheduling_Stubs.ExecuteJobRequest_WP exeJobRequest_WP = new WSCH_LTP_Scheduling_Stubs.ExecuteJobRequest_WP();
        exeJobRequest_WP.jobInstanceGuid = 'dpId';
        exeJobRequest_WP.jobInstanceId = 'territoryId';
        List<String> workOrderIds = new List<String>();
        List<String> resourceIds = new List<String>();
        List<String> eventIds = new List<String>();
        Map<String, String> parameters = new Map<String, String>();
        exeJobRequest_WP.workOrderIds = workOrderIds;
        exeJobRequest_WP.resourceIds = resourceIds;
        exeJobRequest_WP.eventIds = eventIds;
        exeJobRequest_WP.parameters = parameters;

        List<WSCH_LTP_Scheduling_Stubs.NodeColor_WP> lstNodeColors = new List<WSCH_LTP_Scheduling_Stubs.NodeColor_WP>();
        WSCH_LTP_Scheduling_Stubs.NodeColor_WP nodeColorWP = new WSCH_LTP_Scheduling_Stubs.NodeColor_WP();
        nodeColorWP.id = 123;
        nodeColorWP.colorName = 'test color1'; 
        nodeColorWP.percentage = '20%'; 
        lstNodeColors.add(nodeColorWP);
        WSCH_LTP_Scheduling_Stubs.NodeColor_WP nodeColorWP1 = new WSCH_LTP_Scheduling_Stubs.NodeColor_WP();
        nodeColorWP1.id = 124;
        nodeColorWP1.colorName = 'test color2'; 
        nodeColorWP1.percentage = '40%'; 
        lstNodeColors.add(nodeColorWP1);

        exeJobRequest_WP.nodeColors = lstNodeColors;    
        
        WSCH_LTP_Scheduling_Stubs.Response_WP response_WP = new WSCH_LTP_Scheduling_Stubs.Response_WP();
        response_WP.status = 'test status';
        response_WP.message = 'test message';

        WSCH_LTP_Scheduling_Stubs.SchedulingInputRequest_WP schedulingInputRequest_WP = new WSCH_LTP_Scheduling_Stubs.SchedulingInputRequest_WP();
        schedulingInputRequest_WP.jobInstanceGuid = 'jobInstanceGuId';
        List<String> ids = new List<String>();
        schedulingInputRequest_WP.ids = ids;
    
        WSCH_LTP_Scheduling_Stubs.SchedulingInputResponse_WP schedulingInputResponse_WP = new WSCH_LTP_Scheduling_Stubs.SchedulingInputResponse_WP();
        List<WSCH_LTP_Scheduling_Stubs.WorkOrder_WP> workOrders = new List<WSCH_LTP_Scheduling_Stubs.WorkOrder_WP>();
        List<WSCH_LTP_Scheduling_Stubs.Technician_WP> resources = new List<WSCH_LTP_Scheduling_Stubs.Technician_WP>();
        List<WSCH_LTP_Scheduling_Stubs.TechniciansEvent_WP> technicianEvents= new List<WSCH_LTP_Scheduling_Stubs.TechniciansEvent_WP>();
        schedulingInputResponse_WP.workOrders = workOrders;
        schedulingInputResponse_WP.resources = resources;
        schedulingInputResponse_WP.events = technicianEvents;
        
        WSCH_LTP_Scheduling_Stubs.SchedulingOutputRequest_WP schedulingOutputRequest_WP = new WSCH_LTP_Scheduling_Stubs.SchedulingOutputRequest_WP();
        schedulingOutputRequest_WP.jobInstanceGuid = 'jobInstanceGuId';
        schedulingOutputRequest_WP.exceptionMsg = 'exceptionMsg';
        schedulingOutputRequest_WP.exceptionMsgCode = 1001;
        schedulingOutputRequest_WP.createdDateTime = '';
        schedulingOutputRequest_WP.callStatus ='success';
        List<WSCH_LTP_Scheduling_Stubs.Route_WP> routes = new List<WSCH_LTP_Scheduling_Stubs.Route_WP>();
        List<WSCH_LTP_Scheduling_Stubs.UnscheduledElement_WP> badSchedulingElements = new List<WSCH_LTP_Scheduling_Stubs.UnscheduledElement_WP>();
        List<WSCH_LTP_Scheduling_Stubs.ScheduledElement_WP> resolvedSchedulingElements = new List<WSCH_LTP_Scheduling_Stubs.ScheduledElement_WP>();
        List<WSCH_LTP_Scheduling_Stubs.UnscheduledElement_WP> unassignedSchedulingElements = new List<WSCH_LTP_Scheduling_Stubs.UnscheduledElement_WP>();
        List<WSCH_LTP_Scheduling_Stubs.SchedulingJobStatistic_WP> schedulingJobStatistics = new List<WSCH_LTP_Scheduling_Stubs.SchedulingJobStatistic_WP>();
        schedulingOutputRequest_WP.routes = routes;
        schedulingOutputRequest_WP.badSchedulingElements = badSchedulingElements;
        schedulingOutputRequest_WP.resolvedSchedulingElements = resolvedSchedulingElements;
        schedulingOutputRequest_WP.unassignedSchedulingElements = unassignedSchedulingElements;
        schedulingOutputRequest_WP.schedulingJobStatistics = schedulingJobStatistics;
        
        WSCH_LTP_Scheduling_Stubs.Route_WP route_WP = new WSCH_LTP_Scheduling_Stubs.Route_WP();
        route_WP.routeId = 'routeId';
        route_WP.resourceId = 'resourceId';
        route_WP.startLocationElementId = 'startLocationElementId';
        route_WP.endLocationElementId = 'endLocationElementId';
        List<WSCH_LTP_Scheduling_Stubs.ScheduledElement_WP> scheduledElement_WP1 = new List<WSCH_LTP_Scheduling_Stubs.ScheduledElement_WP>();
        route_WP.scheduledElements = scheduledElement_WP1;
        WSCH_LTP_Scheduling_Stubs.RouteSummary_WP routeSummary_WP1 = new WSCH_LTP_Scheduling_Stubs.RouteSummary_WP();
        route_WP.routeSummary = routeSummary_WP1;
        
        WSCH_LTP_Scheduling_Stubs.RouteSummary_WP routeSummary_WP = new WSCH_LTP_Scheduling_Stubs.RouteSummary_WP();
        routeSummary_WP.startTime = Datetime.now();
        routeSummary_WP.endTime = Datetime.now()+1;
        routeSummary_WP.routeDuration = 30;
        routeSummary_WP.drivingDuration = 60;   
        routeSummary_WP.distance=40;
        routeSummary_WP.serviceDuration=30;
        routeSummary_WP.idleDuration=10;
        routeSummary_WP.returnDriveDuration =10;
        routeSummary_WP.returnDistance=10;  

        WSCH_LTP_Scheduling_Stubs.UnscheduledElement_WP unscheduledElement_WP = new WSCH_LTP_Scheduling_Stubs.UnscheduledElement_WP();
        unscheduledElement_WP.id = 'WO-2938382';
        unscheduledElement_WP.reason = 'unscheduled - bad data';
        unscheduledElement_WP.reasonCode = 3;
        unscheduledElement_WP.unscheduledElementType = 'Resource';
        unscheduledElement_WP.resolvedLatitude = 22.234;
        unscheduledElement_WP.resolvedLongitude = 22.345;         
 
        WSCH_LTP_Scheduling_Stubs.ScheduledElement_WP scheduledElement_WP = new WSCH_LTP_Scheduling_Stubs.ScheduledElement_WP();
        scheduledElement_WP.id = 'WO-2938382';
        scheduledElement_WP.type = 'Event';
        scheduledElement_WP.resolvedLatitude = 22.234;
        scheduledElement_WP.resolvedLongitude = 22.345;         
        WSCH_LTP_Scheduling_Stubs.Booking_WP booking = new WSCH_LTP_Scheduling_Stubs.Booking_WP();
        scheduledElement_WP.booking = booking;
        List<WSCH_LTP_Scheduling_Stubs.Violation_WP> violationsWP = new List<WSCH_LTP_Scheduling_Stubs.Violation_WP>();
        scheduledElement_WP.violations = violationsWP;

        WSCH_LTP_Scheduling_Stubs.Violation_WP violation = new WSCH_LTP_Scheduling_Stubs.Violation_WP();
        violation.type = 'test type';
        violation.value = 'test value';

        WSCH_LTP_Scheduling_Stubs.Booking_WP bookingWP = new WSCH_LTP_Scheduling_Stubs.Booking_WP();
        bookingWP.resource ='';
        bookingWP.startTime = datetime.now();
        bookingWP.driveDuration=10;
        bookingWP.arrivalTime=datetime.now();
        bookingWP.returnDriveDuration =20;
        bookingWP.idleDuration =30;
        bookingWP.serviceDuration =60;
        bookingWP.endTime = datetime.now()+1;
        bookingWP.status ='tentative';

        WSCH_LTP_Scheduling_Stubs.SchedulingJobStatistic_WP schedulingJobStatistic_WP = new WSCH_LTP_Scheduling_Stubs.SchedulingJobStatistic_WP();
        schedulingJobStatistic_WP.name = 'dpId';
        schedulingJobStatistic_WP.value = 'territoryId';
        schedulingJobStatistic_WP.type = 'orgId';
        Test.stopTest();
    }

    static testMethod void constructorMethods_UT(){
        Test.startTest();
        Product2 product = new Product2();
        product.Name = 'product';
        insert product;
        
        SVMXC__Skill__c skill = new SVMXC__Skill__c();
        skill.Name = 'skill1';
        insert skill;
        
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'team1';
        insert team;

        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.Name = 'Bangalore';
        insert territory;
        
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'Tech1';
        technician.SVMXC__Service_Group__c = team.Id;
        insert technician;

        WSCH_LTP_Scheduling_Stubs.WorkOrder_WP workOrder_WP = new WSCH_LTP_Scheduling_Stubs.WorkOrder_WP();
        workOrder_WP.workOrderId = '123';
        workOrder_WP.address = 'abc';
        workOrder_WP.assignedResourceId = '234';
        workOrder_WP.serviceDuration = 34.78;
        workOrder_WP.importance = 234;
        workOrder_WP.lockSchedule = 'job';
        workOrder_WP.preferredStart = Datetime.now();
        workOrder_WP.preferredEnd = Datetime.now()+1;
        
        // List<String> expertise = new List<String>();
        // expertise.add('skill1');
        List<WSCH_LTP_Scheduling_Stubs.Expertise_WP> lstTechSkill = new List<WSCH_LTP_Scheduling_Stubs.Expertise_WP>();
        WSCH_LTP_Scheduling_Stubs.Expertise_WP expertise = new WSCH_LTP_Scheduling_Stubs.Expertise_WP();
        expertise.validTo=null;
        expertise.validFrom=system.now().dateGmt();
        expertise.id='testskill';
        expertise.level=5.0;
        lstTechSkill.add(expertise);
        WSCH_LTP_Scheduling_Stubs.Expertise_WP expertise1 = new WSCH_LTP_Scheduling_Stubs.Expertise_WP();
        expertise1.validTo=system.now().dateGmt()+5;
        expertise1.validFrom=system.now().dateGmt();
        expertise1.id='testskill1';
        expertise1.level=5.0;
        lstTechSkill.add(expertise1);
        workOrder_WP.requiredExpertise = lstTechSkill;

        
        List<WSCH_LTP_Scheduling_Stubs.QualifiedTechnician_WP> lstQualifiedTech = new List<WSCH_LTP_Scheduling_Stubs.QualifiedTechnician_WP>();
        WSCH_LTP_Scheduling_Stubs.QualifiedTechnician_WP qualifiedTech = new WSCH_LTP_Scheduling_Stubs.QualifiedTechnician_WP('test Id',10);
        qualifiedTech.id='test Id';
        qualifiedTech.priority = 10;        
        lstQualifiedTech.add(qualifiedTech);

        WSCH_LTP_Scheduling_Stubs.QualifiedTechnician_WP qualifiedTech1 = new WSCH_LTP_Scheduling_Stubs.QualifiedTechnician_WP('test Id1',1);
        qualifiedTech1.id='test Id1';
        qualifiedTech1.priority = 1;
        lstQualifiedTech.add(qualifiedTech1);       
        workOrder_WP.recommendedResources = lstQualifiedTech;

        List<String> bannedResources = new List<String>();
        List<String> mandatoryResources = new List<String>();
        workOrder_WP.bannedResources = bannedResources;
        workOrder_WP.mandatoryResources = mandatoryResources;
        
        List<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP> lstOfExecutionTime = new List<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>();
        
        WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP executionTime_WP1 = new WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP();
        executionTime_WP1.HoursBegin = Datetime.now();
        executionTime_WP1.HoursEnd = Datetime.now() + 1;
        lstOfExecutionTime.add(executionTime_WP1);
        
        WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP executionTime_WP2 = new WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP();
        executionTime_WP2.HoursBegin = Datetime.now();
        executionTime_WP2.HoursEnd = Datetime.now() + 1;
        lstOfExecutionTime.add(executionTime_WP2);
        workOrder_WP.accessHours = lstOfExecutionTime;
        
        WSCH_LTP_Scheduling_Stubs.Location_WP location = new WSCH_LTP_Scheduling_Stubs.Location_WP();
        location.latitude = 21.323832;
        location.longitude = 21.340595;
        workOrder_WP.geoLocation = location;
        workOrder_WP.nodeColor = 'test color1';
        
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c();
        objWorkOrder.SVMXC__Product__c = product.Id;
        objWorkOrder.SVMXC__Skill__c = skill.Id;
        objWorkOrder.SVMXC__Group_Member__r = technician;
        objWorkOrder.SVMXC__Service_Duration__c = 3600;
        objWorkOrder.SVMXC__Dispatch_Priority__c = 100;
        objWorkOrder.SVMXC__Preferred_Resource_Priority__c = 7899;
        objWorkOrder.SVMXC__Street__c = 'street1';
        objWorkOrder.SVMXC__City__c = 'Bangalore';
        objWorkOrder.SVMXC__State__c = 'Karnataka';
        objWorkOrder.SVMXC__Zip__c = '560022';
        objWorkOrder.SVMXC__Country__c = 'India';                
        objWorkOrder.SVMXC__SM_Schedule_Violation_Penalty__c = 123;
        objWorkOrder.SVMXC__Qualified_Technicians__c = '[{"valid":true,"tName":"Allen, Brian","tech":"a1DF00000076r5IMAQ","stackRank":8,"skillR":9,"skillO":0.0,"prod":0,"prefType":"Preferred","prefTech":0,"eligibleRuleName":"","eligible":0},{"valid":true,"tName":"Allen, Brian1","tech":"a1DF00000076r6IMAQ","stackRank":8,"skillR":9,"skillO":0.0,"prod":0,"prefType":"Mandatory","prefTech":0,"eligibleRuleName":"","eligible":0},{"valid":true,"tName":"Allen, Brian2","tech":"a1DF00000076r7IMAQ","stackRank":8,"skillR":9,"skillO":0.0,"prod":0,"prefType":"Prohibited","prefTech":0,"eligibleRuleName":"","eligible":0}]'; 
        objWorkOrder.SVMXC__Skill_Set__c = '[{"skillName":"Repair Skill1","skillLevel":5,"skillId":"a1UF0000001YPldMAG","isSkillMandatory":true},{"skillName":"Repair Skill3","skillLevel":0,"skillId":"a1UF0000001YPlnMAG","isSkillMandatory":false},{"skillName":"Repair Skill2","skillLevel":0,"skillId":"a1UF0000001YPliMAG","isSkillMandatory":false}] '; 
        insert objWorkOrder;
        
        workOrder_WP = new WSCH_LTP_Scheduling_Stubs.WorkOrder_WP(objWorkOrder, lstOfExecutionTime);


        SVMXC__Service_Group_Members__c objTechnician = new SVMXC__Service_Group_Members__c();
        objTechnician.Name = 'Tech1';
        objTechnician.SVMXC__Fixed_Cost__c = 1234456;
        objTechnician.SVMXC__Average_Speed__c = 6464646;
        objTechnician.SVMXC__Max_Distance__c = 535366;
        objTechnician.SVMXC__Per_hour_Cost__c = 477898;
        objTechnician.SVMXC__Per_Mile_Cost__c = 535273;
        objTechnician.SVMXC__Latitude_Home__c = 12.3732326;
        objTechnician.SVMXC__Longitude_Home__c = 76.06239789999995;
        objTechnician.SVMXC__Service_Territory__c = territory.Id;
        objTechnician.SVMXC__Street__c = 'Street1';
        objTechnician.SVMXC__City__c = 'Bangalore';
        objTechnician.SVMXC__State__c = 'Karnataka';
        objTechnician.SVMXC__Zip__c = '560022';
        objTechnician.SVMXC__Country__c = 'India';
        objTechnician.SVMXC__Service_Group__c = team.Id;
        insert objTechnician;
        
        WSCH_LTP_Scheduling_Stubs.Technician_WP technician_WP = new WSCH_LTP_Scheduling_Stubs.Technician_WP();
        technician_WP.resourceId = '123';
        technician_WP.address = '345';
        technician_WP.fixedCost = 12.23;
        technician_WP.hourlyCost = 23.34;
        technician_WP.travelUnitCost = 34.45;
        technician_WP.avgTravelSpeed = 45.34;
        technician_WP.maxHours = 12.35;
        technician_WP.maxDistance = 234.45;
        technician_WP.overTimeTolerance=10;
        technician_WP.driveBeforeShiftStart=60;
        technician_WP.driveAfterShiftEnd=60;
        
        // List<String> expertise1 = new List<String>();
        // expertise1.add('skill1');
        List<WSCH_LTP_Scheduling_Stubs.Expertise_WP> lstTechSkill1 = new List<WSCH_LTP_Scheduling_Stubs.Expertise_WP>();
        WSCH_LTP_Scheduling_Stubs.Expertise_WP expertise2 = new WSCH_LTP_Scheduling_Stubs.Expertise_WP();
        expertise2.validTo=null;
        expertise2.validFrom=system.now().dateGmt();
        expertise2.id='testskill';
        expertise2.level=5.0;
        lstTechSkill.add(expertise2);
        WSCH_LTP_Scheduling_Stubs.Expertise_WP expertise3 = new WSCH_LTP_Scheduling_Stubs.Expertise_WP();
        expertise3.validTo=system.now().dateGmt()+5;
        expertise3.validFrom=system.now().dateGmt();
        expertise3.id='testskill1';
        expertise3.level=5.0;
        lstTechSkill.add(expertise3);
        technician_WP.expertise = lstTechSkill1;

        List<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP> lstOfExecutionTime1 = new List<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP>();
        
        WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP executionTime_WP11 = new WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP();
        executionTime_WP11.HoursBegin = Datetime.now();
        executionTime_WP11.HoursEnd = Datetime.now() + 1;
        lstOfExecutionTime1.add(executionTime_WP11);
        
        executionTime_WP11.setHoursBegin(Datetime.now()); 
        executionTime_WP11.setHoursEnd(Datetime.now()+1); 
        
        WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP executionTime_WP22 = new WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP();
        executionTime_WP22.HoursBegin = Datetime.now();
        executionTime_WP22.HoursEnd = Datetime.now() + 1;
        lstOfExecutionTime1.add(executionTime_WP22);
        technician_WP.workingHours = lstOfExecutionTime1;
        
        Double lat1 = 21.32;
        Double long1 = 21.34;
        WSCH_LTP_Scheduling_Stubs.Location_WP location1 = new WSCH_LTP_Scheduling_Stubs.Location_WP(lat1,long1);
        location1.latitude = 21.323832;
        location1.longitude = 21.340595;
        technician_WP.geoLocation = location;
        location1.setLatitude(lat1);
        location1.setLongitude(long1);

        list<String> lstSkills = new List<String>();
        lstSkills.add('Repair');
        Double dblOvertimeInSec = 60 * 60;

        technician_WP = new WSCH_LTP_Scheduling_Stubs.Technician_WP(objTechnician);

        WSCH_LTP_Scheduling_Stubs.TechniciansEvent_WP techniciansEvent_WP = new WSCH_LTP_Scheduling_Stubs.TechniciansEvent_WP();
        techniciansEvent_WP.assignedResourceId = '123';
        techniciansEvent_WP.eventId = 'Event_sieiddkei_3dd3933';
        //techniciansEvent_WP.importance = 10;
        techniciansEvent_WP.eventDuration = 300;
        techniciansEvent_WP.address = 'Taylors Road, CA';
        techniciansEvent_WP.eventType = 'NonWOEvent';
        techniciansEvent_WP.accessHours = lstOfExecutionTime;
        
        techniciansEvent_WP = new WSCH_LTP_Scheduling_Stubs.TechniciansEvent_WP('123', '234', '567', Datetime.now(), Datetime.now() + 1, 2334, 4557, 125, 'abc',null,null);

        techniciansEvent_WP = new WSCH_LTP_Scheduling_Stubs.TechniciansEvent_WP('12345', '23455', '56788', Datetime.now()+1, Datetime.now() + 2, 5555, 6666, 200, 'abcde',location1,'ford street, CA');
        
        Test.stopTest();
    }
    
    static testMethod void coverageOthers_UT(){
            String strTimeZoneSidKey = 'Asia/Chennai';
            Datetime currentdt = datetime.now();
            Set<Date> setAllowedDates = new Set<Date>();
            Date datStartDate = Date.valueOf(currentdt.format('yyyy-MM-dd', strTimeZoneSidKey));
            setAllowedDates.add(datStartDate);
            currentdt = currentdt.adddays(2);
            Date datEndDate = Date.valueOf(currentdt.format('yyyy-MM-dd', strTimeZoneSidKey));
            setAllowedDates.add(datEndDate);

            WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP executionTime_WP11 = new WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP();
            executionTime_WP11.HoursBegin = Datetime.now();
            executionTime_WP11.HoursEnd = Datetime.now() + 1;
            
            executionTime_WP11.setHoursBegin(Datetime.now()); 
            executionTime_WP11.setHoursEnd(Datetime.now()+1); 

            List<WSCH_LTP_Scheduling_Stubs.ExecutionTime_WP> lstExecutionTime = executionTime_WP11.doSplitDays(strTimeZoneSidKey,setAllowedDates);
            
    }   
}