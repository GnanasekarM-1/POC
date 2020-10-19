@isTest(seeAllData = true)
public with sharing class WSCH_Provider_ECO_Stubs_UT {
    
    static testMethod void testECOStubs() {
        
        WSCH_Provider_ECO_Stubs ecoStubs = new WSCH_Provider_ECO_Stubs();
        
        WSCH_Provider_ECO_Stubs.InitJobRequest_WP initJobRequest_WP = new WSCH_Provider_ECO_Stubs.InitJobRequest_WP();
        initJobRequest_WP.dispatchProcessId = '123';
        initJobRequest_WP.territoryId = '234';
        initJobRequest_WP.orgId = '345';
        initJobRequest_WP.svmxVersion = '456';
        initJobRequest_WP.geoCodingEnabled = '567';
        
        WSCH_Provider_ECO_Stubs.ManageWorkOrderRequest_WP manageWorkOrderRequest_WP = new WSCH_Provider_ECO_Stubs.ManageWorkOrderRequest_WP();
        manageWorkOrderRequest_WP.dispatchProcessId = '123';
        manageWorkOrderRequest_WP.territoryId = '234';
        manageWorkOrderRequest_WP.orgId = '345';
        manageWorkOrderRequest_WP.svmxVersion = '456';
        manageWorkOrderRequest_WP.geoCodingEnabled = '567';
        
        WSCH_Provider_ECO_Stubs.ManageTechnicianRequest_WP manageTechnicianRequest_WP = new WSCH_Provider_ECO_Stubs.ManageTechnicianRequest_WP();
        manageTechnicianRequest_WP.dispatchProcessId = '123';
        manageTechnicianRequest_WP.territoryId = '234';
        manageTechnicianRequest_WP.orgId = '345';
        manageTechnicianRequest_WP.svmxVersion = '456';
        manageTechnicianRequest_WP.geoCodingEnabled = '567';
        
        WSCH_Provider_ECO_Stubs.ManageTechnicianEventRequest_WP manageTechnicianEventRequest_WP = new WSCH_Provider_ECO_Stubs.ManageTechnicianEventRequest_WP();
        manageTechnicianEventRequest_WP.dispatchProcessId = '123';
        manageTechnicianEventRequest_WP.territoryId = '234';
        manageTechnicianEventRequest_WP.orgId = '345';
        manageTechnicianEventRequest_WP.svmxVersion = '456';
        manageTechnicianEventRequest_WP.geoCodingEnabled = true;
        
        WSCH_Provider_ECO_Stubs.ManageWorkOrdersResultRequest_WP magWoResRqt_WP = new WSCH_Provider_ECO_Stubs.ManageWorkOrdersResultRequest_WP();        
        magWoResRqt_WP.dispatchProcessGuid = '123';
        magWoResRqt_WP.territoryGuid = 'abc';
        magWoResRqt_WP.orgGuid = '1qw2';
        
        WSCH_Provider_ECO_Stubs.AppointmentOfferRequest_WP apptOfferReq_WP = new WSCH_Provider_ECO_Stubs.AppointmentOfferRequest_WP();
        apptOfferReq_WP.dispatchProcessId = 'abc';
        apptOfferReq_WP.territoryId = '234';
        apptOfferReq_WP.orgId = '334';
        WSCH_Provider_ECO_Stubs.WorkOrder_WP wo_wp = new WSCH_Provider_ECO_Stubs.WorkOrder_WP();
        wo_wp.scheduleFixType = 'type';
        apptOfferReq_WP.workOrder = wo_wp; 
        WSCH_Provider_ECO_Stubs.ApptOfferType_WP apptOffType =  new WSCH_Provider_ECO_Stubs.ApptOfferType_WP(); 
        apptOfferReq_WP.appointmentOfferType = apptOffType;
        
        WSCH_Provider_ECO_Stubs.ArrivalWindow_WP arrWin_WP = new WSCH_Provider_ECO_Stubs.ArrivalWindow_WP();
        arrWin_WP.arrivalWindowName = 'abc';
        arrWin_WP.startTime = '2018-08-30';
        arrWin_WP.endTime = '2018-08-31';
        
        WSCH_Provider_ECO_Stubs.ApptOfferType_WP apptOff_WP = new WSCH_Provider_ECO_Stubs.ApptOfferType_WP();
        apptOff_WP.appointmentOfferTypeName = 'qwe';
        List<WSCH_Provider_ECO_Stubs.ArrivalWindow_WP> arrWin_WPList = new List<WSCH_Provider_ECO_Stubs.ArrivalWindow_WP>();
        arrWin_WPList.add(arrWin_WP);
        apptOff_WP.arrivalWindows = arrWin_WPList;
        
        WSCH_Provider_ECO_Stubs.AppointmentOfferResponse_WP apptOfferRes_WP = new WSCH_Provider_ECO_Stubs.AppointmentOfferResponse_WP();
        apptOfferRes_WP.dispatchProcessId = 'abc';
        apptOfferRes_WP.territoryId = 'abc';
        apptOfferRes_WP.orgId = 'abc';
        apptOfferRes_WP.appointmentOffers = new List<WSCH_Provider_ECO_Stubs.Offer_WP>();
        apptOfferRes_WP.errorMessage = 'abc';
        apptOfferRes_WP.statusCode = 0;
        apptOfferRes_WP.responseWP = new WSCH_Provider_ECO_Stubs.Response_WP();
        
        WSCH_Provider_ECO_Stubs.Offer_WP offer_wp = new WSCH_Provider_ECO_Stubs.Offer_WP();
        offer_wp.startDateTime = '2018-08-30';
        offer_wp.endDateTime = '2018-08-31';
        offer_wp.slotCost = 1.1;
        offer_wp.slotType = 'Low';
        offer_wp.slotCategory = 'Recommended';
        offer_wp.technicians = new List<String>();
        
        WSCH_Provider_ECO_Stubs.BookAppointmentRequest_WP bookApptReq_WP = new WSCH_Provider_ECO_Stubs.BookAppointmentRequest_WP();
        bookApptReq_WP.dispatchProcessId = 'abc';
        bookApptReq_WP.territoryId = 'abc';
        bookApptReq_WP.orgId = 'abc';
        bookApptReq_WP.workOrder = new WSCH_Provider_ECO_Stubs.WorkOrder_WP();
        bookApptReq_WP.slotCost = 33.33;
        bookApptReq_WP.slotCategory = 'Recommended';
        bookApptReq_WP.goAhead = true;
            
        WSCH_Provider_ECO_Stubs.BookAppointmentResponse_WP bookApptRes_WP = new WSCH_Provider_ECO_Stubs.BookAppointmentResponse_WP();
        bookApptRes_WP.dispatchProcessId = 'abc';
        bookApptRes_WP.territoryId = 'abc';
        bookApptRes_WP.orgId = 'abc';
        bookApptRes_WP.workOrderId = 'abc';
        bookApptRes_WP.statusCode =1;
        bookApptRes_WP.responseWP = new WSCH_Provider_ECO_Stubs.Response_WP();
        
        WSCH_Provider_ECO_Stubs.ResumeJobRequest_WP resJobReq_WP = new WSCH_Provider_ECO_Stubs.ResumeJobRequest_WP();
        resJobReq_WP.dispatchProcessGuid = 'abc';
        resJobReq_WP.territoryGuid = 'abc';
        resJobReq_WP.orgGuid = 'abc';
            
        WSCH_Provider_ECO_Stubs.SuspendJobRequest_WP supJobReq_WP = new WSCH_Provider_ECO_Stubs.SuspendJobRequest_WP();
        supJobReq_WP.dispatchProcessGuid = 'abc';
        supJobReq_WP.territoryGuid = 'abc';
        supJobReq_WP.orgGuid = 'abc';

        List<WSCH_Provider_ECO_Stubs.Expertise_WP> lstTechSkill = new List<WSCH_Provider_ECO_Stubs.Expertise_WP>();
        WSCH_Provider_ECO_Stubs.Expertise_WP expertise = new WSCH_Provider_ECO_Stubs.Expertise_WP();
        expertise.validTo=null;
        expertise.validFrom=system.now().dateGmt();
        expertise.id='testskill';
        expertise.level=5.0;
        lstTechSkill.add(expertise);
        WSCH_Provider_ECO_Stubs.Expertise_WP expertise1 = new WSCH_Provider_ECO_Stubs.Expertise_WP();
        expertise1.validTo=system.now().dateGmt()+5;
        expertise1.validFrom=system.now().dateGmt();
        expertise1.id='testskill1';
        expertise1.level=5.0;
        lstTechSkill.add(expertise1);

        WSCH_Provider_ECO_Stubs.WorkOrder_WP workOrder_WP = new WSCH_Provider_ECO_Stubs.WorkOrder_WP();
        workOrder_WP.workOrderId = '123';
        workOrder_WP.requiredProduct = true;
        workOrder_WP.requiredExpertise = lstTechSkill;
        workOrder_WP.address = 'abc';
        workOrder_WP.preferredResourceId = '234';
        workOrder_WP.preferredResourcePriority = 23.456;
        workOrder_WP.priority = 123.456;
        workOrder_WP.visitDuration = 34.78;
        workOrder_WP.importance = 234;
        workOrder_WP.workOrderType = 'job';
        workOrder_WP.operationType = 'type1';
        workOrder_WP.scheduleViolationPenalty = 1.1;
        workOrder_WP.isForceFix = false;
        workOrder_WP.capacityReservationCategory = 'str';
        
        List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> lstOfExecutionTime = new List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
        
        WSCH_Provider_ECO_Stubs.ExecutionTime_WP executionTime_WP1 = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP();
        executionTime_WP1.workingHoursBegin = Datetime.now();
        executionTime_WP1.workingHoursEnd = Datetime.now() + 1;
        lstOfExecutionTime.add(executionTime_WP1);
        
        WSCH_Provider_ECO_Stubs.ExecutionTime_WP executionTime_WP2 = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP();
        executionTime_WP2.workingHoursBegin = Datetime.now();
        executionTime_WP2.workingHoursEnd = Datetime.now() + 1;
        lstOfExecutionTime.add(executionTime_WP2);
        
        Product2 product = new Product2();
        product.Name = 'product';
        insert product;
        
        SVMXC__Skill__c skill = new SVMXC__Skill__c();
        skill.Name = 'skill1';
        insert skill;
        
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'team1';
        insert team;
        
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'Tech1';
        technician.SVMXC__Service_Group__c = team.Id;
        insert technician;
        
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
        objWorkOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_JOB_FIXED';
        objWorkOrder.SVMXC__SM_Capacity_Rule_Name__c = 'rule1';
        objWorkOrder.SVMXC__Qualified_Technicians__c = '[{"valid":true,"tName":"Allen, Brian","tech":"a1DF00000076r5IMAQ","stackRank":8,"skillR":9,"skillO":0.0,"prod":0,"prefType":"Preferred","prefTech":0,"eligibleRuleName":"","eligible":0},{"valid":true,"tName":"Allen, Brian1","tech":"a1DF00000076r6IMAQ","stackRank":8,"skillR":9,"skillO":0.0,"prod":0,"prefType":"Mandatory","prefTech":0,"eligibleRuleName":"","eligible":0},{"valid":true,"tName":"Allen, Brian2","tech":"a1DF00000076r7IMAQ","stackRank":8,"skillR":9,"skillO":0.0,"prod":0,"prefType":"Prohibited","prefTech":0,"eligibleRuleName":"","eligible":0}]'; 
        objWorkOrder.SVMXC__Skill_Set__c = '[{"skillName":"Repair Skill1","skillLevel":5,"skillId":"a1UF0000001YPldMAG","isSkillMandatory":true},{"skillName":"Repair Skill3","skillLevel":0,"skillId":"a1UF0000001YPlnMAG","isSkillMandatory":false},{"skillName":"Repair Skill2","skillLevel":0,"skillId":"a1UF0000001YPliMAG","isSkillMandatory":false}] '; 
        insert objWorkOrder;
        
        workOrder_WP = new WSCH_Provider_ECO_Stubs.WorkOrder_WP(objWorkOrder, lstOfExecutionTime, 'job', 'operationType');
        
        SVMXC__Service_Order__c objWorkOrder2 = new SVMXC__Service_Order__c();
        objWorkOrder2.SVMXC__Product__c = product.Id;
        objWorkOrder2.SVMXC__Skill__c = skill.Id;
        objWorkOrder2.SVMXC__Group_Member__r = technician;
        objWorkOrder2.SVMXC__Service_Duration__c = 3600;
        objWorkOrder2.SVMXC__Dispatch_Priority__c = 0;
        objWorkOrder2.SVMXC__Preferred_Resource_Priority__c = 7899;
        objWorkOrder2.SVMXC__Street__c = 'street1';
        objWorkOrder2.SVMXC__City__c = 'Bangalore';
        objWorkOrder2.SVMXC__State__c = 'Karnataka';
        objWorkOrder2.SVMXC__Zip__c = '560022';
        objWorkOrder2.SVMXC__Country__c = 'India';                
        objWorkOrder2.SVMXC__SM_Schedule_Violation_Penalty__c = 123;
        objWorkOrder2.SVMXC__Qualified_Technicians__c = '[{"valid":true,"tName":"Allen, Brian","tech":"a1DF00000076r5IMAQ","stackRank":8,"skillR":9,"skillO":0.0,"prod":0,"prefType":"Preferred","prefTech":0,"eligibleRuleName":"","eligible":0},{"valid":true,"tName":"Allen, Brian1","tech":"a1DF00000076r6IMAQ","stackRank":8,"skillR":9,"skillO":0.0,"prod":0,"prefType":"Mandatory","prefTech":0,"eligibleRuleName":"","eligible":0},{"valid":true,"tName":"Allen, Brian2","tech":"a1DF00000076r7IMAQ","stackRank":8,"skillR":9,"skillO":0.0,"prod":0,"prefType":"Prohibited","prefTech":0,"eligibleRuleName":"","eligible":0}]'; 
        objWorkOrder2.SVMXC__Skill_Set__c = '[{"skillName":"Repair Skill1","skillLevel":5,"skillId":"a1UF0000001YPldMAG","isSkillMandatory":true},{"skillName":"Repair Skill3","skillLevel":0,"skillId":"a1UF0000001YPlnMAG","isSkillMandatory":false},{"skillName":"Repair Skill2","skillLevel":0,"skillId":"a1UF0000001YPliMAG","isSkillMandatory":false}] '; 
        insert objWorkOrder2;
        
        workOrder_WP = new WSCH_Provider_ECO_Stubs.WorkOrder_WP(objWorkOrder2, lstOfExecutionTime, 'ASSIGNED', 'job');
        workOrder_WP = new WSCH_Provider_ECO_Stubs.WorkOrder_WP(objWorkOrder2, lstOfExecutionTime, 'job', 'remove');

        SVMXC__Service_Order__c objWorkOrder3 = new SVMXC__Service_Order__c();
        objWorkOrder3.SVMXC__Product__c = product.Id;
        objWorkOrder3.SVMXC__Skill__c = skill.Id;
        objWorkOrder3.SVMXC__Group_Member__r = technician;
        objWorkOrder3.SVMXC__Service_Duration__c = 3600;
        objWorkOrder3.SVMXC__Dispatch_Priority__c = 0;
        objWorkOrder3.SVMXC__Preferred_Resource_Priority__c = 7899;
        objWorkOrder3.SVMXC__Street__c = 'street1';
        objWorkOrder3.SVMXC__City__c = 'Bangalore';
        objWorkOrder3.SVMXC__State__c = 'Karnataka';
        objWorkOrder3.SVMXC__Zip__c = '560022';
        objWorkOrder3.SVMXC__Country__c = 'India';                
        objWorkOrder3.SVMXC__SM_Schedule_Violation_Penalty__c = 123;
        objWorkOrder3.SVMXC__Qualified_Technicians__c = 'NULL:ABC'; 
        objWorkOrder3.SVMXC__Skill_Set__c = '[{"skillName":"Repair Skill1","skillLevel":5,"skillId":"a1UF0000001YPldMAG","isSkillMandatory":true},{"skillName":"Repair Skill3","skillLevel":0,"skillId":"a1UF0000001YPlnMAG","isSkillMandatory":false},{"skillName":"Repair Skill2","skillLevel":0,"skillId":"a1UF0000001YPliMAG","isSkillMandatory":false}] '; 
        insert objWorkOrder3;
        
        workOrder_WP = new WSCH_Provider_ECO_Stubs.WorkOrder_WP(objWorkOrder3, lstOfExecutionTime, 'ASSIGNED', 'job');
        workOrder_WP = new WSCH_Provider_ECO_Stubs.WorkOrder_WP(objWorkOrder3, lstOfExecutionTime, 'job', 'remove');
        
        WSCH_Provider_ECO_Stubs.QualifiedTechnician_WP qualifiedTechnician_WP = new WSCH_Provider_ECO_Stubs.QualifiedTechnician_WP('123', 123);
        qualifiedTechnician_WP.preferredResourceId = '123';
        qualifiedTechnician_WP.priority = 123;
        
        WSCH_Provider_ECO_Stubs.Technician_WP technician_WP = new WSCH_Provider_ECO_Stubs.Technician_WP();
        technician_WP.resourceId = '123';
        technician_WP.territoryGuid = '234';
        technician_WP.address = '345';
        technician_WP.currentAddress = '456'; 
        technician_WP.fixedCost = 12.23;
        technician_WP.hourlyCost = 23.34;
        technician_WP.travelUnitCost = 34.45;
        technician_WP.avgTravelSpeed = 45.34;
        //technician_WP.maxWeeklyHours = 56.56;
        technician_WP.maxHours = 12.35;
        technician_WP.maxDistance = 234.45;
        technician_WP.operationType = 'abc';
        
        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.Name = 'Bangalore';
        insert territory;
        
        
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
                
        Double dblOvertimeInSec = 60 * 60;
        technician_WP = new WSCH_Provider_ECO_Stubs.Technician_WP(objTechnician, lstOfExecutionTime, lstTechSkill,'abc',dblOvertimeInSec);
        
        SVMXC__Service_Group_Members__c objTechnician1 = new SVMXC__Service_Group_Members__c();
        objTechnician1.Name = 'Tech1';
        objTechnician1.SVMXC__Fixed_Cost__c = 1234456;
        objTechnician1.SVMXC__Average_Speed__c = 6464646;
        objTechnician1.SVMXC__Max_Distance__c = 535366;
        objTechnician1.SVMXC__Per_hour_Cost__c = null;
        objTechnician1.SVMXC__Per_Mile_Cost__c = 535273;
        objTechnician1.SVMXC__Latitude_Home__c = 12.3732326;
        objTechnician1.SVMXC__Longitude_Home__c = 76.06239789999995;
        objTechnician1.SVMXC__Service_Territory__c = territory.Id;
        objTechnician1.SVMXC__Street__c = 'Street1';
        objTechnician1.SVMXC__City__c = 'Bangalore';
        objTechnician1.SVMXC__State__c = 'Karnataka';
        objTechnician1.SVMXC__Zip__c = '560022';
        objTechnician1.SVMXC__Country__c = 'India';
        objTechnician1.SVMXC__Service_Group__c = team.Id;
        insert objTechnician1;
        
        //Double dblOvertimeInSec = 60 * 60;
        technician_WP = new WSCH_Provider_ECO_Stubs.Technician_WP(objTechnician1, lstOfExecutionTime, lstTechSkill,'abc',dblOvertimeInSec);
        
        WSCH_Provider_ECO_Stubs.TechniciansEvent_WP techniciansEvent_WP = new WSCH_Provider_ECO_Stubs.TechniciansEvent_WP();
        techniciansEvent_WP.territoryId = '123';
        techniciansEvent_WP.preferredResourceId = '234';
        techniciansEvent_WP.eventId = '567';
        techniciansEvent_WP.importance = 125;
        techniciansEvent_WP.address = 'strAddress';
        techniciansEvent_WP.serviceTimes = lstOfExecutionTime;
        techniciansEvent_WP.eventDuration = 12.34;
        techniciansEvent_WP.timeWindowPriority = 23.34;
        techniciansEvent_WP.preferredResourcePriority = 45.57;
        
        //Begin : 22Oct2018 - Added to pass the constructor changes
        techniciansEvent_WP = new WSCH_Provider_ECO_Stubs.TechniciansEvent_WP('123', '234', '567', Datetime.now(), Datetime.now() + 1, 2334, 4557, 125, 'abc',new WSCH_Provider_ECO_Stubs.Location_WP(),'strAddress');
        techniciansEvent_WP = new WSCH_Provider_ECO_Stubs.TechniciansEvent_WP('123', '234', '567', Datetime.now(), Datetime.now() + 1, 2334, 4557, 125, 'abc',new WSCH_Provider_ECO_Stubs.Location_WP(),'strAddress', new Map<String,String>());
        techniciansEvent_WP = new WSCH_Provider_ECO_Stubs.TechniciansEvent_WP('123', '234', '567', Datetime.now(), Datetime.now() + 1, 2334, 4557, 125, 'abc',null,null);
        
        WSCH_Provider_ECO_Stubs.Location_WP location_WP = new WSCH_Provider_ECO_Stubs.Location_WP();
        location_WP.latitude = 234.55;
        location_WP.longitude = 66.77;
        
        location_WP.setlatitude(23344);
        location_WP.setlongitude(55166);
        
        WSCH_Provider_ECO_Stubs.Location_WP location_WP1 = new WSCH_Provider_ECO_Stubs.Location_WP(66444, 144444);
        
        WSCH_Provider_ECO_Stubs.ExecutionTime_WP executionTime_WP = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP();
        executionTime_WP.workingHoursBegin = Datetime.now();
        executionTime_WP.workingHoursEnd = Datetime.now() + 1;
        
        //executionTime_WP.setworkingHoursBegin(Datetime.now());
        //executionTime_WP.setworkingHoursEnd(Datetime.now());
        
        executionTime_WP = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP(Datetime.now(), Datetime.now());
        
        Set<Date> setDates = new Set<Date>();
        Date dt1 = Date.newInstance(2016, 11, 23);
        setDates.add(dt1);
        Date dt2 = Date.newInstance(2016, 11, 24);
        setDates.add(dt2);
        Date dt3 = Date.newInstance(2016, 11, 25);
        setDates.add(dt3);
        
        executionTime_WP.doSplitDays('Asia/Kolkata', setDates);
        
        executionTime_WP.setworkingHoursBegin(Datetime.now());
        executionTime_WP.setworkingHoursEnd(Datetime.now() + 1);
        
        executionTime_WP.doSplitDays('Asia/Kolkata', setDates);
        
        WSCH_Provider_ECO_Stubs.Setting_WP settings_WP = new WSCH_Provider_ECO_Stubs.Setting_WP();
        
        List<WSCH_Provider_ECO_Stubs.ExcSetting_WP> lstOfExcSetting = new List<WSCH_Provider_ECO_Stubs.ExcSetting_WP>();
        WSCH_Provider_ECO_Stubs.ExcSetting_WP excSetting_WP1 = new WSCH_Provider_ECO_Stubs.ExcSetting_WP();
        excSetting_WP1.name = 'abc';
        excSetting_WP1.value = 'cde';
        lstOfExcSetting.add(excSetting_WP1);
        
        settings_WP.Exec_SettingsMap = lstOfExcSetting;
        
        WSCH_Provider_ECO_Stubs.ExcSetting_WP excSetting_WP = new WSCH_Provider_ECO_Stubs.ExcSetting_WP();
        excSetting_WP.name = 'abc';
        excSetting_WP.value = 'cde';
        
        WSCH_Provider_ECO_Stubs.Response_WP response_WP = new WSCH_Provider_ECO_Stubs.Response_WP();
        response_WP.status = 'abc';
        response_WP.message = 'abc';
        
        WSCH_Provider_ECO_Stubs.DeleteScheduleRequest_WP delSchReq = new WSCH_Provider_ECO_Stubs.DeleteScheduleRequest_WP();
        delSchReq.dispatchProcessGuid = 'dpGuid';
        delSchReq.territoryGuid = 'terrGuid';
        delSchReq.orgGuid = 'orgGuid';
        
        List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP> woExeTime = new List<WSCH_Provider_ECO_Stubs.ExecutionTime_WP>();
        WSCH_Provider_ECO_Stubs.ExecutionTime_WP exec_wp = new WSCH_Provider_ECO_Stubs.ExecutionTime_WP();
        exec_wp.workingHoursBegin = system.now();
        exec_wp.workingHoursEnd = system.now();
        
        WSCH_Provider_ECO_Stubs.WorkOrder_WP wo_wp1 = new WSCH_Provider_ECO_Stubs.WorkOrder_WP(objWorkOrder2, woExeTime, 'strWorkOrderType', 'strOperationType', 'scheduleFixType');

        WSCH_Provider_ECO_Stubs.WorkOrder_WP wo_wp2 = new WSCH_Provider_ECO_Stubs.WorkOrder_WP(objWorkOrder2, woExeTime, 'strWorkOrderType', 'strOperationType', 'scheduleFixType', new Map<String, String>());

        //lstTechSkill.add('Id_'+Datetime.now()+'_'+ Datetime.now() + 1);
        
        List<WSCH_Provider_ECO_Stubs.ExcSetting_WP> techParams = new List<WSCH_Provider_ECO_Stubs.ExcSetting_WP>();
        WSCH_Provider_ECO_Stubs.ExcSetting_WP execSet_wp = new WSCH_Provider_ECO_Stubs.ExcSetting_WP();
        execSet_wp.name = 'name';
        execSet_wp.value = 'value';
        techParams.add(execSet_wp);
        
        WSCH_Provider_ECO_Stubs.Technician_WP tech_wp = new WSCH_Provider_ECO_Stubs.Technician_WP(objTechnician1, woExeTime, lstTechSkill, 'strOperationType', Double.valueOf('12'), techParams);
        
        List<WSCH_Provider_ECO_Stubs.WorkOrder_WP> workordersWP = new List<WSCH_Provider_ECO_Stubs.WorkOrder_WP>();
        workordersWP.add(wo_wp1);
        
        List<WSCH_Provider_ECO_Stubs.Technician_WP> techWPs = new List<WSCH_Provider_ECO_Stubs.Technician_WP>();
        techWPs.add(tech_wp);
        
        List<WSCH_Provider_ECO_Stubs.TechniciansEvent_WP> techEvents = new List<WSCH_Provider_ECO_Stubs.TechniciansEvent_WP>();
        
        WSCH_Provider_ECO_Stubs.InitJobRequest_WP initJobRequest_WP1 = new WSCH_Provider_ECO_Stubs.InitJobRequest_WP();
        initJobRequest_WP1.dispatchProcessId = '123';
        initJobRequest_WP1.territoryId = '234';
        initJobRequest_WP1.orgId = '345';
        initJobRequest_WP1.svmxVersion = '456';
        initJobRequest_WP1.geoCodingEnabled = '567';
        initJobRequest_WP1.workOrders = workordersWP;
        initJobRequest_WP1.resources = techWPs;
        initJobRequest_WP1.parameters = techParams;
        initJobRequest_WP1.technicianEvents = techEvents;
        

        WSCH_Provider_ECO_Stubs.Relation_WP relationWP = new WSCH_Provider_ECO_Stubs.Relation_WP();
        relationWP.relationshipType = 'statToFinish';
        relationWP.masterNodeId = 'wo-1234';
        relationWP.resourceDependencyType = 'sameResource';
        relationWP.minimalDeviationSec = 1344;
        relationWP.maximalDeviationSec = 1267;

    }
}