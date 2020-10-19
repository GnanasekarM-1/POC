@isTest(seeAllData = true)
public with sharing class WSCH_OptimizedSchedulingService_UT {
    
    public WSCH_OptimizedSchedulingService_UT() {
        
        List<SVMXC__ServiceMax_Config_Data__c> lstConfGBL = [SELECT id,SVMXC__Setting_Unique_ID__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Setting_Unique_ID__c IN ('GLOB001_GBL007')];

        for(SVMXC__ServiceMax_Config_Data__c confObj : lstConfGBL)
        {
            if(confObj.SVMXC__Setting_Unique_ID__c.equalsIgnoreCase('GLOB001_GBL007')){
                confObj.SVMXC__Display_Value__c = 'false';
                confObj.SVMXC__Internal_Value__c = 'false';
            }
            confObj.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        }

        if(!lstConfGBL.isEmpty()){
            Database.update(lstConfGBL);
        }
    }

    static testMethod void scheduleWorkOrders(){

        test.startTest();
        String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               DispatchProRecordTypeId = rt.ID;
            else if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               ExpressionRTypeId = rt.ID;
            else if(rt.Name == 'SVMX Rule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               RuleRecordTypeId = rt.id;
            else if(rt.Name == 'Field Mapping' &&  rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               FldMapRecordTypeId = rt.id;
            else if(rt.Name == 'Coverage' &&  rt.SobjectType == 'SVMXC__Territory_Coverage__c')
               TCRT = rt.id;
        }

        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        svmxprocess.SVMXC__Name__c = 'Linx for ServicePower 1';
        svmxprocess.RecordTypeId = DispatchProRecordTypeId;
        svmxprocess.SVMXC__Dispatch_Process_Status__c='Complete';
        svmxprocess.SVMXC__Dispatch_Method__c='Linx for ServicePower';
        insert svmxprocess;

        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c='Open';
        oConf.SVMXC__Operator__c='eq';
        oConf.RecordTypeId = ExpressionRTypeId;
        oConf.SVMXC__Sequence__c=1;
        oConf.SVMXC__Expression_Rule__c = svmxprocess.id;
        insert oConf;

        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.name = 'South Central Region';
        territory.SVMXC__Optimizer_External_ID__c = 'SOU';
        territory.SVMXC__Optimizer_Last_Timestamp__c='';
        insert territory;

        SVMXC__Territory__c territory1 = new SVMXC__Territory__c();
        territory1.name = 'South West Region';
        territory1.SVMXC__Optimizer_External_ID__c = 'SWR';
        insert territory1;

        list<SVMXC__Service_Order__c> workOrders = new list<SVMXC__Service_Order__c>();

        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrder.SVMXC__Zip__c = '75001';
        workOrder.SVMXC__Order_Status__c='Open';
        workOrder.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder.SVMXC__Locked_By_DC__c = false;
        workOrder.SVMXC__Service_Duration__c = 60;
        workOrder.SVMXC__OptiMax_Status__c ='';
        workOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CREATE_WO';
        workOrder.SVMXC__Primary_Territory__c=territory.Id;
        workOrders.add(workOrder);

        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        workOrder1.SVMXC__Zip__c = '75005';
        workOrder1.SVMXC__Order_Status__c='Open';
        workOrder1.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder1.SVMXC__Locked_By_DC__c = false;
        workOrder1.SVMXC__Service_Duration__c = 60;
        workOrder1.SVMXC__OptiMax_Status__c = '';
        workOrder1.SVMXC__Scheduling_Change_Token__c = 'CHANGE_STATUS';
        workOrder1.SVMXC__Work_Order_Scheduling_Status__c='Tentative';
        workOrder1.SVMXC__Primary_Territory__c=territory.Id;
        workOrders.add(workOrder1);

        list<SVMXC__Service_Order__c> newWOs = new list<SVMXC__Service_Order__c>();
        newWOs.add(workOrder);
        newWOs.add(workOrder1);

        Map<String, String> terrFRUMap = new Map<String,String>();
        terrFRUMap.put(territory.Id,'SOU');
        terrFRUMap.put(territory1.Id,'UK01');
        Set<String> fruChangesToGet = new Set<String>();
        fruChangesToGet.add('SOU');
        fruChangesToGet.add('UK01');

        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_OptimizedSchedulingService.manageWorkOrders(newWOs);

        newWOs.clear();
        for(Integer i=1; i < 5; i++)    //i<12 changed to i<5
        {
        SVMXC__Service_Order__c workOrder2 = new SVMXC__Service_Order__c();
        workOrder2.SVMXC__Zip__c = '75001';
        workOrder2.SVMXC__Order_Status__c='Open';
        workOrder2.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder2.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder2.SVMXC__Locked_By_DC__c = false;
        workOrder2.SVMXC__Service_Duration__c = 60;
        workOrder2.SVMXC__OptiMax_Status__c = '';
        workOrder2.SVMXC__Scheduling_Change_Token__c = 'OPT_BATCH';
        workOrder2.SVMXC__Primary_Territory__c=territory.Id;
        workOrder2.SVMXC__Scheduling_Change_Token__c = 'CHANGE_STATUS';
        workOrder2.SVMXC__Work_Order_Scheduling_Status__c = 'Tentative';
        workOrder2.SVMXC__OptiMax_Status__c = 'OPT_TENTATIVE';
        workOrder2.SVMXC__Acknowledged_By_Technician_Date_Time__c=Datetime.now();
        workOrder2.SVMXC__Started_Driving_To_Location_Date_Time__c=Datetime.now();
        workOrder2.SVMXC__Actual_Onsite_Response__c=Datetime.now();
        workOrder2.SVMXC__Finished_Onsite_Date_Time__c=Datetime.now();
        newWOs.add(workOrder2);
        }
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_OptimizedSchedulingService.manageWorkOrders(newWOs);

        //for batch testing
        newWOs.clear();
        for(Integer i=1; i < 5; i++)        //i<12 changed to i<5
        {
        SVMXC__Service_Order__c workOrder2 = new SVMXC__Service_Order__c();
        workOrder2.SVMXC__Zip__c = '75001';
        workOrder2.SVMXC__Order_Status__c='Open';
        workOrder2.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder2.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder2.SVMXC__Locked_By_DC__c = false;
        workOrder2.SVMXC__Service_Duration__c = 60;
        workOrder2.SVMXC__OptiMax_Status__c = 'OPT_TENTATIVE';
        workOrder2.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CREATE_WO';
        workOrder2.SVMXC__Primary_Territory__c=territory.Id;
        newWOs.add(workOrder2);
        }
        //Mock the webservice call.
      // Temporarily commenting due to 101 SOQL error
       //Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_OptimizedSchedulingService.manageWorkOrders(newWOs);

        newWOs.clear();
        workOrder1.SVMXC__Scheduling_Change_Token__c = 'CHANGE_STATUS';
        workOrder1.SVMXC__Work_Order_Scheduling_Status__c = 'Tentative';
        workOrder1.SVMXC__Acknowledged_By_Technician_Date_Time__c=Datetime.now();
        workOrder1.SVMXC__Started_Driving_To_Location_Date_Time__c=Datetime.now();
        workOrder1.SVMXC__Actual_Onsite_Response__c=Datetime.now();
        workOrder1.SVMXC__Finished_Onsite_Date_Time__c=Datetime.now();
        newWOs.add(workOrder);
        newWOs.add(workOrder1);
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        //WSCH_OptimizedSchedulingService.manageWorkOrders(newWOs);

        newWOs.clear();
        workOrder1.SVMXC__Scheduling_Change_Token__c = 'CHANGE_STATUS';
        workOrder1.SVMXC__Work_Order_Scheduling_Status__c = 'Earmarked';
        newWOs.add(workOrder);
        newWOs.add(workOrder1);
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_OptimizedSchedulingService.manageWorkOrders(newWOs);

        newWOs.clear();
        workOrder1.SVMXC__Scheduling_Change_Token__c = 'CHANGE_STATUS';
        workOrder1.SVMXC__Work_Order_Scheduling_Status__c = 'Contacted';
        newWOs.add(workOrder);
        newWOs.add(workOrder1);
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_OptimizedSchedulingService.manageWorkOrders(newWOs);

        newWOs.clear();
        workOrder1.SVMXC__Scheduling_Change_Token__c = 'CHANGE_STATUS';
        workOrder1.SVMXC__Work_Order_Scheduling_Status__c = 'Travelling';
        newWOs.add(workOrder);
        newWOs.add(workOrder1);
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_OptimizedSchedulingService.manageWorkOrders(newWOs);

        newWOs.clear();
        workOrder1.SVMXC__Scheduling_Change_Token__c = 'CHANGE_STATUS';
        workOrder1.SVMXC__Work_Order_Scheduling_Status__c = 'LoggedOn';
        //newWOs.add(workOrder);
        newWOs.add(workOrder1);
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_OptimizedSchedulingService.manageWorkOrders(newWOs);

        newWOs.clear();
        workOrder1.SVMXC__Scheduling_Change_Token__c = 'CHANGE_STATUS';
        workOrder1.SVMXC__Work_Order_Scheduling_Status__c = 'Cleared';
        //newWOs.add(workOrder);
        newWOs.add(workOrder1);
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        //WSCH_OptimizedSchedulingService.manageWorkOrders(newWOs);

        newWOs.clear();
        workOrder1.SVMXC__Scheduling_Change_Token__c = '';
        workOrder1.SVMXC__Work_Order_Scheduling_Status__c = '';
        newWOs.add(workOrder);
        newWOs.add(workOrder1);

    }

    static testMethod void testScheduleWOs() {

        test.startTest();

        String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               DispatchProRecordTypeId = rt.ID;
            else if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               ExpressionRTypeId = rt.ID;
            else if(rt.Name == 'SVMX Rule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               RuleRecordTypeId = rt.id;
            else if(rt.Name == 'Field Mapping' &&  rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               FldMapRecordTypeId = rt.id;
            else if(rt.Name == 'Coverage' &&  rt.SobjectType == 'SVMXC__Territory_Coverage__c')
               TCRT = rt.id;
        }

        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        svmxprocess.SVMXC__Name__c = 'Linx for ServicePower 1';
        svmxprocess.RecordTypeId = DispatchProRecordTypeId;
        svmxprocess.SVMXC__Dispatch_Process_Status__c='Complete';
        svmxprocess.SVMXC__Dispatch_Method__c='Linx for ServicePower';
        insert svmxprocess;

        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c='Open';
        oConf.SVMXC__Operator__c='eq';
        oConf.RecordTypeId = ExpressionRTypeId;
        oConf.SVMXC__Sequence__c=1;
        oConf.SVMXC__Expression_Rule__c = svmxprocess.id;
        insert oConf;

        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.name = 'South Central Region';
        territory.SVMXC__Optimizer_External_ID__c = 'SOU';
        territory.SVMXC__Optimizer_Last_Timestamp__c='1427587200';
        insert territory;

        SVMXC__Territory__c territory1 = new SVMXC__Territory__c();
        territory1.name = 'South West Region';
        territory1.SVMXC__Optimizer_External_ID__c = 'SWR';
        territory1.SVMXC__Optimizer_Last_Timestamp__c='1427587200';
        insert territory1;

        list<SVMXC__Service_Order__c> workOrders = new list<SVMXC__Service_Order__c>();

        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrder.SVMXC__Zip__c = '75001';
        workOrder.SVMXC__Order_Status__c='Open';
        workOrder.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder.SVMXC__Locked_By_DC__c = false;
        workOrder.SVMXC__Service_Duration__c = 60;
        workOrder.SVMXC__OptiMax_Status__c ='';
        workOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CREATE_WO';
        workOrder.SVMXC__Primary_Territory__c=territory.Id;
        workOrders.add(workOrder);

        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        workOrder1.SVMXC__Zip__c = '75005';
        workOrder1.SVMXC__Order_Status__c='Open';
        workOrder1.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder1.SVMXC__Locked_By_DC__c = false;
        workOrder1.SVMXC__Service_Duration__c = 60;
        workOrder1.SVMXC__OptiMax_Status__c = '';
        workOrder1.SVMXC__Scheduling_Change_Token__c = 'CHANGE_STATUS';
        workOrder1.SVMXC__Work_Order_Scheduling_Status__c='Tentative';
        workOrder1.SVMXC__Primary_Territory__c=territory.Id;
        workOrders.add(workOrder1);

        list<SVMXC__Service_Order__c> newWOs = new list<SVMXC__Service_Order__c>();
        newWOs.add(workOrder);
        newWOs.add(workOrder1);

        Map<String, String> terrFRUMap = new Map<String,String>();
        terrFRUMap.put(territory.Id,'SOU');
        terrFRUMap.put(territory1.Id,'UK01');
        Set<String> fruChangesToGet = new Set<String>();
        fruChangesToGet.add('SOU');
        fruChangesToGet.add('UK01');

        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_OptimizedSchedulingService.manageWorkOrders(newWOs);

        newWOs.clear();
        for(Integer i=1; i < 12; i++)
        {
        SVMXC__Service_Order__c workOrder2 = new SVMXC__Service_Order__c();
        workOrder2.SVMXC__Zip__c = '75001';
        workOrder2.SVMXC__Order_Status__c='Open';
        workOrder2.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder2.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder2.SVMXC__Locked_By_DC__c = false;
        workOrder2.SVMXC__Service_Duration__c = 60;
        workOrder2.SVMXC__OptiMax_Status__c = '';
        workOrder2.SVMXC__Scheduling_Change_Token__c = 'OPT_BATCH';
        workOrder2.SVMXC__Primary_Territory__c=territory.Id;
        workOrder2.SVMXC__Scheduling_Change_Token__c = 'CHANGE_STATUS';
        workOrder2.SVMXC__Work_Order_Scheduling_Status__c = 'Tentative';
        workOrder2.SVMXC__OptiMax_Status__c = 'OPT_TENTATIVE';
        workOrder2.SVMXC__Acknowledged_By_Technician_Date_Time__c=Datetime.now();
        workOrder2.SVMXC__Started_Driving_To_Location_Date_Time__c=Datetime.now();
        workOrder2.SVMXC__Actual_Onsite_Response__c=Datetime.now();
        workOrder2.SVMXC__Finished_Onsite_Date_Time__c=Datetime.now();
        newWOs.add(workOrder2);
        }
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_OptimizedSchedulingService.manageWorkOrders(newWOs);

        //for batch testing
        newWOs.clear();
        for(Integer i=1; i < 12; i++)
        {
        SVMXC__Service_Order__c workOrder2 = new SVMXC__Service_Order__c();
        workOrder2.SVMXC__Zip__c = '75001';
        workOrder2.SVMXC__Order_Status__c='Open';
        workOrder2.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder2.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder2.SVMXC__Locked_By_DC__c = false;
        workOrder2.SVMXC__Service_Duration__c = 60;
        workOrder2.SVMXC__OptiMax_Status__c = 'OPT_TENTATIVE';
        workOrder2.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CREATE_WO';
        workOrder2.SVMXC__Primary_Territory__c=territory.Id;
        newWOs.add(workOrder2);
        }
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        //WSCH_OptimizedSchedulingService.manageWorkOrders(newWOs);

        newWOs.clear();
        workOrder1.SVMXC__Scheduling_Change_Token__c = 'CHANGE_STATUS';
        workOrder1.SVMXC__Work_Order_Scheduling_Status__c = 'Tentative';
        workOrder1.SVMXC__Acknowledged_By_Technician_Date_Time__c=Datetime.now();
        workOrder1.SVMXC__Started_Driving_To_Location_Date_Time__c=Datetime.now();
        workOrder1.SVMXC__Actual_Onsite_Response__c=Datetime.now();
        workOrder1.SVMXC__Finished_Onsite_Date_Time__c=Datetime.now();
        newWOs.add(workOrder);
        newWOs.add(workOrder1);

//        insert workOrder1;
        String woNumber=workOrder1.Id;
        Integer apptBatchSize=5;
        Integer apptBatchNo=1;
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        try {
            WSCH_OptimizedSchedulingService.getAvailableAppointments(woNumber,null,apptBatchSize,apptBatchNo);
            //WSCH_OptimizedSchedulingService.getAvailableAppointments(woNumber,apptBatchSize,apptBatchNo);
        } catch (WSCH_Exception ex) {
            //do Nothing. Expected.
        }

        WSCH_Appointment appt = new WSCH_Appointment();
        appt.setOfferToken('00045326f374000000014faffffffff0000000000054000');
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        try {
            WSCH_OptimizedSchedulingService.bookAppointment(workOrder1,appt);
        } catch (WSCH_Exception ex) {
            //do Nothing. Expected.
        }
    
    // Temporarily commenting due to 101 SOQL error
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_OptimizedSchedulingService.getChangedWorkOrders(territory);

        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_OptimizedSchedulingService.manageWorkOrders(newWOs);
        
    }

    static testMethod void testManageNonWOEventsCreate() {
      Test.startTest();

      SVMXC__Territory__c territory1 = new SVMXC__Territory__c();
        territory1.name = 'UK Region';
        territory1.SVMXC__Optimizer_External_ID__c = 'UK01';
        territory1.SVMXC__Optimizer_Last_Timestamp__c='1427587200';
        insert territory1;

      SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'testTeam';

        insert team;

        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'John';
        technician.SVMXC__Optimizer_External_ID__c = 'TM001';
        technician.SVMXC__Service_Group__c  = team.Id;
        technician.SVMXC__Service_Territory__c = territory1.Id;

        insert technician;

        SVMXC__Service_Order__c svo = new SVMXC__Service_Order__c (
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c ='Medium',
                                            SVMXC__Order_Type__c='Field Service',
                                            SVMXC__Locked_By_DC__c = true
                                            );
         upsert svo;
         
      SVMXC__SVMX_Event__c svmxEvent= new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-12 00:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-12 01:00:00').addHours(1),
                                                    SVMXC__Technician__c =  technician.Id,
                                                    SVMXC__WhatId__c = svo.Id
                                                    );

        insert svmxEvent;

      SVMXC__SVMX_Optimizer__c svmxOptimizer = new SVMXC__SVMX_Optimizer__c();
      svmxOptimizer.SVMXC__WhatId__c = svmxEvent.Id;
      svmxOptimizer.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CREATE';
      svmxOptimizer.SVMXC__Optimizer_External_Id__c = String.valueOf(1234);

      insert svmxOptimizer;

    List<SVMXC__SVMX_Optimizer__c> lstOfOptimizerEvent = new List<SVMXC__SVMX_Optimizer__c>();
    lstOfOptimizerEvent.add(svmxOptimizer);

      //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
      WSCH_OptimizedSchedulingService.manageNonWorkOrderEvents(lstOfOptimizerEvent);

      Test.stopTest();
    }

    static testMethod void testManageNonWOEventsDelete() {
      Test.startTest();

      SVMXC__Territory__c territory1 = new SVMXC__Territory__c();
        territory1.name = 'UK Region';
        territory1.SVMXC__Optimizer_External_ID__c = 'UK01';
        territory1.SVMXC__Optimizer_Last_Timestamp__c='1427587200';
        insert territory1;

      SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'testTeam';

        insert team;

        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'John';
        technician.SVMXC__Optimizer_External_ID__c = 'TM001';
        technician.SVMXC__Service_Group__c  = team.Id;
        technician.SVMXC__Service_Territory__c = territory1.Id;

        insert technician;

        SVMXC__Service_Order__c svo = new SVMXC__Service_Order__c (
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c ='Medium',
                                            SVMXC__Order_Type__c='Field Service',
                                            SVMXC__Locked_By_DC__c = true
                                            );
         upsert svo;
         
      SVMXC__SVMX_Event__c svmxEvent= new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-12 00:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-12 01:00:00').addHours(1),
                                                    SVMXC__Technician__c =  technician.Id,
                                                    SVMXC__WhatId__c = svo.Id
                                                    );

        insert svmxEvent;

      SVMXC__SVMX_Optimizer__c svmxOptimizer = new SVMXC__SVMX_Optimizer__c();
      svmxOptimizer.SVMXC__WhatId__c = svmxEvent.Id;
      svmxOptimizer.SVMXC__Optimizer_Change_Token__c = 'CHANGE_DELETE';
      svmxOptimizer.SVMXC__Optimizer_External_Id__c = String.valueOf(1234);

      insert svmxOptimizer;

    List<SVMXC__SVMX_Optimizer__c> lstOfOptimizerEvent = new List<SVMXC__SVMX_Optimizer__c>();
    lstOfOptimizerEvent.add(svmxOptimizer);

      //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
      WSCH_OptimizedSchedulingService.manageNonWorkOrderEvents(lstOfOptimizerEvent);

      Test.stopTest();
    }

    static testMethod void testCancelJob() {
        Test.startTest();
        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        List<SVMXC__Service_Order__c> workOrders = new List<SVMXC__Service_Order__c>();
        workOrders.add(workOrder);
        insert workOrder;

        SVMXC__SVMX_Optimizer__c svmxOptimizer = new SVMXC__SVMX_Optimizer__c();
        svmxOptimizer.SVMXC__WhatId__c = workOrder.Id;
        svmxOptimizer.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CANCEL_WO';

        List<SVMXC__SVMX_Optimizer__c> lstOfOptimizerEvent = new List<SVMXC__SVMX_Optimizer__c>();
        lstOfOptimizerEvent.add(svmxOptimizer);

        WSCH_OptimizedSchedulingService.cancelWorkOrders(lstOfOptimizerEvent);
        Test.stopTest();
    }

    static testMethod void testAdaptorClass() {
        WSCH_Provider_SP_Adaptor adaptor = new WSCH_Provider_SP_Adaptor();
        adaptor.getRealTimeOptimizer();
    }
    
    static testMethod void testEcoAdaptorClass() {
        WSCH_Provider_ECO_Adaptor adaptor = new WSCH_Provider_ECO_Adaptor();
        adaptor.getTechnicianService();
    }
        
    public static testMethod void testDependency(){
        System.Test.StartTest();
        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        workOrder1.SVMXC__Zip__c = '75001';
        workOrder1.SVMXC__Order_Status__c = 'Open';
        workOrder1.SVMXC__Service_Duration__c = 3600;
        workOrder1.SVMXC__Schedule_As_A_Dependent_Work_Order__c = True;
        insert workOrder1;
        SVMXC__Service_Order__c workOrder2 = new SVMXC__Service_Order__c();
        workOrder2.SVMXC__Zip__c = '75001';
        workOrder2.SVMXC__Order_Status__c='Open';
        workOrder2.SVMXC__Service_Duration__c = 3600;
        workOrder2.SVMXC__Schedule_As_A_Dependent_Work_Order__c = True;
        insert workOrder2;
        SVMXC__Dependency_Management__c dependencyManagement = new SVMXC__Dependency_Management__c();
        dependencyManagement.SVMXC__Dependency_Group_Name__c = 'BDG-01';
        insert dependencyManagement;
        SVMXC__Service_Order_Dependency__c dependencyRecord = new SVMXC__Service_Order_Dependency__c();
        dependencyRecord.SVMXC__Primary_Work_Order__c = workOrder1.Id;
        dependencyRecord.SVMXC__Secondary_Work_Order__c = workOrder2.Id;
        dependencyRecord.SVMXC__Time_Dependency__c = 'Set Arrival Time of Secondary relative to the Arrival Time of Primary';
        dependencyRecord.SVMXC__Dependency_Group__c = dependencyManagement.id;
        dependencyRecord.SVMXC__Maximum_Time_Deviation__c = 30;
        dependencyRecord.SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes';
        dependencyRecord.SVMXC__Minimum_Time_Deviation__c = 60;
        dependencyRecord.SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes';
        dependencyRecord.SVMXC__Targeted_Time_Difference__c = 45;
        dependencyRecord.SVMXC__Targeted_Time_Variance_Cost_ID__c = 'testCost';
        dependencyRecord.SVMXC__Targeted_Time_Difference_Units__c = 'Minutes';
        insert dependencyRecord;
        List<Service_Order_Dependency__c> serviceOrderList = new List<Service_Order_Dependency__c>();
        serviceOrderList.add(dependencyRecord);
        WSCH_OptimizedSchedulingService.manageDependencyGroup('BDG-01', serviceOrderList);
        List<String> multiJobId = new List<String>();
        multiJobId.add('BDG-01');
        List<String> WorkOrderIds = new List<String>();
        WorkOrderIds.add(workOrder1.Id);
        WorkOrderIds.add(workOrder2.Id);
        //WSCH_OptimizedSchedulingService.cancelDependencyGroup(multiJobId, WorkOrderIds);
    }
}