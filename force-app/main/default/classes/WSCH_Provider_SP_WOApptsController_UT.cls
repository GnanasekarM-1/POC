/**
UT class for WSCH_Provider_SP_WOApptsController
**/
@isTest(seeAllData = true)
public with sharing class WSCH_Provider_SP_WOApptsController_UT {

    public Integer APPT_MAX_SIZE = 99;

    static TestMethod void getWOApptsAndBookAppts() {

        String strXMLData = '<?xml version="1.0" encoding="UTF-8"?>'+ '<rows>'+
        '<row   id="1"><cell></cell> <cell> first </cell><cell> second </cell><cell>' +
        'third</cell><cell> fourth</cell></row>'+ '<row id="2"><cell></cell>' +
        '<cell> first </cell><cell> second </cell><cell> third</cell><cell>fourth</cell></row></rows>';
        String selectedRowId = '2';
        String strWorkOrderID = '67890';
        String strWORecordID = '1234';
        String strOfferApptErrorMsg = 'Offer Appointment successful';
        String strBookApptErrorMsg = 'Book appointment failed';
        List<WSCH_Appointment> lstOfTechnicianSlot;
        //boolean isBookApptFailed = true;
        //boolean isBookApptExecuted = true;
        //boolean isBookApptSuccess = true;
        //Map<String,String> mapOfWeekDays = new Map<String,String>();
        Map<String, String> mapOfWeekDays = new Map<String, String>();
        Map<String, String> mapOfPromiseType = new Map<String, String>();

        //Test.startTest();

        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.name = 'South Central Region';
        territory.SVMXC__Optimizer_External_ID__c = 'SOU';
        insert territory;

        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        workOrder1.SVMXC__Zip__c = '98001';
        workOrder1.SVMXC__Order_Status__c='Open';
        //workOrder.SVMXC__Group_Member__c = Tech.id;
        //workOrder.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder1.SVMXC__Locked_By_DC__c = false;
        workOrder1.SVMXC__Service_Duration__c = 60;
        workOrder1.SVMXC__OptiMax_Status__c ='';
        workOrder1.SVMXC__Scheduling_Change_Token__c = '';
        workOrder1.SVMXC__Primary_Territory__c=territory.Id;

        insert workOrder1;

        //System.debug('workOrder1 ' + workOrder1);
        //System.debug('workOrder1.Id ' + workOrder1.Id);
        //System.debug('workOrder1.SVMXC__Zip__c :' + workOrder1.SVMXC__Zip__c);

        SVMXC__Service_Order__c workOrder2 = [SELECT Id,Name,SVMXC__City__c,SVMXC__Zip__c FROM SVMXC__Service_Order__c WHERE Id =: workOrder1.Id];
        workOrder2.SVMXC__Zip__c = '75001';

        update workOrder2;

        //System.debug('workOrder2.Id ' + workOrder2.Id);
        //System.debug('workOrder2 ' + workOrder2);
        //System.debug('workOrder2.SVMXC__Zip__c: ' + workOrder2.SVMXC__Zip__c);

        WSCH_Provider_SP_WOApptsController woApptController = new WSCH_Provider_SP_WOApptsController();

        woApptController.strXMLData = strXMLData;
        woApptController.selectedRowId = '0';
        woApptController.strWORecordID = workOrder2.Id;   //'1234';   //workOrder2.Id;
        woApptController.strWorkOrderID = workOrder2.Name;
        woApptController.strOfferApptErrorMsg = 'Offer Appointment successful';
        woApptController.strBookApptErrorMsg = 'Book appointment failed';
        woApptController.isBookApptFailed = true;
        woApptController.isBookApptExecuted = true;
        woApptController.isBookApptSuccess = false;
        woApptController.strBookApptSuccessMsg = 'Book appointment successful';

        mapOfWeekDays = woApptController.getWeekDay();
        mapOfWeekDays.get('mon');
        mapOfWeekDays.get('tue');
        mapOfWeekDays.get('wed');
        mapOfWeekDays.get('thu');
        mapOfWeekDays.get('fri');
        mapOfWeekDays.get('sat');
        mapOfWeekDays.get('sun');

        mapOfPromiseType = woApptController.getPromiseType();
        mapOfPromiseType.get('D');
        mapOfPromiseType.get('T');
        mapOfPromiseType.get('P');

        //Test with status code = 0 and all boolean values set to true
        //WSCH_AppointmentsResponse res = WSCH_OptimizedSchedulingService.getAvailableAppointments(workOrder2.Id, 5, 1);
        WSCH_AppointmentsResponse res = new WSCH_AppointmentsResponse();
        res.statusCode=0;
        res.statusMessage='status message';
        WSCH_Appointment slot = new WSCH_Appointment();
        slot.setStartDateTime(DateTime.now());
        slot.setEndDateTime(DateTime.now());
        List<WSCH_Appointment> appointmentList = new List<WSCH_Appointment>();
        appointmentList.add(slot);
        res.appointmentList=appointmentList;
        woApptController.lstOfTechnicianSlot = appointmentList;

        woApptController.cancelApptSelection();
        woApptController.getIsBookApptFailure();
        woApptController.getIsBookApptSuccess();
        woApptController.getIsWOApptEmpty();
        woApptController.saveSelectedAppt();
        woApptController.cancelApptSelection();
        woApptController.navigateToWorkOrder();

        Test.startTest();

        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        woApptController.buildResponseData();
        woApptController.bookAppointment();
        //woApptController.viewMoreAppointments();


        //Test with status code = 1 and all boolean values set to false
        woApptController.strXMLData = '';
        woApptController.isBookApptFailed = false;
        woApptController.isBookApptExecuted = true;
        woApptController.isBookApptSuccess = true;

        res = new WSCH_AppointmentsResponse();
        res.statusCode=1;
        res.statusMessage='status message';
        slot = new WSCH_Appointment();
        slot.setStartDateTime(DateTime.now());
        slot.setEndDateTime(DateTime.now());
        appointmentList = new List<WSCH_Appointment>();
        appointmentList.add(slot);
        res.appointmentList=appointmentList;
        woApptController.lstOfTechnicianSlot = res.appointmentList;

        woApptController.cancelApptSelection();
        woApptController.getIsBookApptFailure();
        woApptController.getIsBookApptSuccess();
        woApptController.getIsWOApptEmpty();
        woApptController.saveSelectedAppt();
        woApptController.cancelApptSelection();
        woApptController.navigateToWorkOrder();
        woApptController.bookAppointment();
        woApptController.buildResponseData();

        //Test with different combination of boolean values
        woApptController.strXMLData = '';
        woApptController.isBookApptFailed = false;
        woApptController.isBookApptExecuted = false;
        woApptController.isBookApptSuccess = false;

        woApptController.cancelApptSelection();
        woApptController.getIsBookApptFailure();
        woApptController.getIsBookApptSuccess();
        woApptController.getIsWOApptEmpty();
        woApptController.saveSelectedAppt();
        woApptController.cancelApptSelection();
        woApptController.navigateToWorkOrder();
        woApptController.bookAppointment();
        woApptController.buildResponseData();

        //Test with different combination of boolean values
        woApptController.strXMLData = '';
        woApptController.isBookApptFailed = false;
        woApptController.isBookApptExecuted = false;
        woApptController.isBookApptSuccess = false;
        
        //woApptController.createRows(strXMLData, appointmentList);
        Test.stopTest();
    }

    static TestMethod void testViewMoreAppts() {

        //Test.startTest();

        String strXMLData = '<?xml version="1.0" encoding="UTF-8"?>'+ '<rows>'+
        '<row   id="1"><cell></cell> <cell> first </cell><cell> second </cell><cell>' +
        'third</cell><cell> fourth</cell></row>'+ '<row id="2"><cell></cell>' +
        '<cell> first </cell><cell> second </cell><cell> third</cell><cell>fourth</cell></row></rows>';
        String selectedRowId = '2';
        String strWorkOrderID = '67890';
        String strWORecordID = '1234';
        String strOfferApptErrorMsg = 'Offer Appointment successful';
        String strBookApptErrorMsg = 'Book appointment failed';
        List<WSCH_Appointment> lstOfTechnicianSlot;
        //boolean isBookApptFailed = true;
        //boolean isBookApptExecuted = true;
        //boolean isBookApptSuccess = true;
        //Map<String,String> mapOfWeekDays = new Map<String,String>();
        Map<String, String> mapOfWeekDays = new Map<String, String>();
        Map<String, String> mapOfPromiseType = new Map<String, String>();

        //Test.startTest();

        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.name = 'South Central Region';
        territory.SVMXC__Optimizer_External_ID__c = 'SOU';
        insert territory;

        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        workOrder1.SVMXC__Zip__c = '98001';
        workOrder1.SVMXC__Order_Status__c='Open';
        //workOrder.SVMXC__Group_Member__c = Tech.id;
        //workOrder.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder1.SVMXC__Locked_By_DC__c = false;
        workOrder1.SVMXC__Service_Duration__c = 60;
        workOrder1.SVMXC__OptiMax_Status__c ='';
        workOrder1.SVMXC__Scheduling_Change_Token__c = '';
        workOrder1.SVMXC__Primary_Territory__c=territory.Id;

        insert workOrder1;

        //System.debug('workOrder1 ' + workOrder1);
        //System.debug('workOrder1.Id ' + workOrder1.Id);
        //System.debug('workOrder1.SVMXC__Zip__c :' + workOrder1.SVMXC__Zip__c);

        SVMXC__Service_Order__c workOrder2 = [SELECT Id,Name,SVMXC__City__c,SVMXC__Zip__c FROM SVMXC__Service_Order__c WHERE Id =: workOrder1.Id];
        workOrder2.SVMXC__Zip__c = '75001';

        update workOrder2;

        //System.debug('workOrder2.Id ' + workOrder2.Id);
        //System.debug('workOrder2 ' + workOrder2);
        //System.debug('workOrder2.SVMXC__Zip__c: ' + workOrder2.SVMXC__Zip__c);

        WSCH_Provider_SP_WOApptsController woApptController = new WSCH_Provider_SP_WOApptsController();

        woApptController.strXMLData = strXMLData;
        woApptController.selectedRowId = '0';
        woApptController.strWORecordID = workOrder2.Id;   //'1234';   //workOrder2.Id;
        woApptController.strWorkOrderID = workOrder2.Name;
        woApptController.strOfferApptErrorMsg = 'Offer Appointment successful';
        woApptController.strBookApptErrorMsg = 'Book appointment failed';
        woApptController.isBookApptFailed = true;
        woApptController.isBookApptExecuted = true;
        woApptController.isBookApptSuccess = false;
        woApptController.strBookApptSuccessMsg = 'Book appointment successful';

        mapOfWeekDays = woApptController.getWeekDay();
        mapOfWeekDays.get('mon');
        mapOfWeekDays.get('tue');
        mapOfWeekDays.get('wed');
        mapOfWeekDays.get('thu');
        mapOfWeekDays.get('fri');
        mapOfWeekDays.get('sat');
        mapOfWeekDays.get('sun');

        mapOfPromiseType = woApptController.getPromiseType();
        mapOfPromiseType.get('D');
        mapOfPromiseType.get('T');
        mapOfPromiseType.get('P');

        //Test with status code = 0 and all boolean values set to true
        //WSCH_AppointmentsResponse res = WSCH_OptimizedSchedulingService.getAvailableAppointments(workOrder2.Id, 5, 1);
        WSCH_AppointmentsResponse res = new WSCH_AppointmentsResponse();
        res.statusCode=0;
        res.statusMessage='status message';
        WSCH_Appointment slot = new WSCH_Appointment();
        List<WSCH_Appointment> appointmentList = new List<WSCH_Appointment>();
        appointmentList.add(slot);
        res.appointmentList=appointmentList;
        woApptController.lstOfTechnicianSlot = appointmentList;

        woApptController.cancelApptSelection();
        woApptController.getIsBookApptFailure();
        woApptController.getIsBookApptSuccess();
        woApptController.getIsWOApptEmpty();
        woApptController.saveSelectedAppt();
        woApptController.cancelApptSelection();
        woApptController.navigateToWorkOrder();
        woApptController.getIsMoreApptEmpty();

        Test.startTest();

        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        woApptController.viewMoreAppointments();

        Test.stopTest();
    }

    static TestMethod void testCustomTagMethods() {

        Test.startTest();

        WSCH_Provider_SP_WOApptsController.getTAG001();
        WSCH_Provider_SP_WOApptsController.getTAG002();
        WSCH_Provider_SP_WOApptsController.getTAG003();
        WSCH_Provider_SP_WOApptsController.getTAG004();
        WSCH_Provider_SP_WOApptsController.getTAG005();
        WSCH_Provider_SP_WOApptsController.getTAG006();
        WSCH_Provider_SP_WOApptsController.getTAG007();
        WSCH_Provider_SP_WOApptsController.getTAG008();
        WSCH_Provider_SP_WOApptsController.getTAG009();
        WSCH_Provider_SP_WOApptsController.getTAG010();
        WSCH_Provider_SP_WOApptsController.getTAG011();
        WSCH_Provider_SP_WOApptsController.getTAG012();
        WSCH_Provider_SP_WOApptsController.getTAG013();
        WSCH_Provider_SP_WOApptsController.getTAG014();
        WSCH_Provider_SP_WOApptsController.getTAG015();
        WSCH_Provider_SP_WOApptsController.getTAG016();
        WSCH_Provider_SP_WOApptsController.getTAG017();
        WSCH_Provider_SP_WOApptsController.getTAG018();
        WSCH_Provider_SP_WOApptsController.getTAG019();
        WSCH_Provider_SP_WOApptsController.getTAG020();
        WSCH_Provider_SP_WOApptsController.getTAG021();
        WSCH_Provider_SP_WOApptsController.getTAG022();
        WSCH_Provider_SP_WOApptsController.getTAG023();
        WSCH_Provider_SP_WOApptsController.getTAG024();
        WSCH_Provider_SP_WOApptsController.getTAG025();
        WSCH_Provider_SP_WOApptsController.getTAG026();
        WSCH_Provider_SP_WOApptsController.getTAG027();
        WSCH_Provider_SP_WOApptsController.getTAG028();
        WSCH_Provider_SP_WOApptsController.getTAG029();
        WSCH_Provider_SP_WOApptsController.getTAG030();
        WSCH_Provider_SP_WOApptsController.getTAG031();
        WSCH_Provider_SP_WOApptsController.getTAG032();
        WSCH_Provider_SP_WOApptsController.getTAG033();
        WSCH_Provider_SP_WOApptsController.getTAG034();
        WSCH_Provider_SP_WOApptsController.getTAG037();

        WSCH_Provider_SP_WOApptsController controller = new WSCH_Provider_SP_WOApptsController();
        controller.getAppointmentsTitle();
        controller.getDisplayViewMore();

        Test.stopTest();
    }

    static TestMethod void testForceBookJob() {

        Test.startTest();

        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.name = 'South Central Region';
        territory.SVMXC__Optimizer_External_ID__c = 'SOU';
        insert territory;

        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        workOrder1.SVMXC__Zip__c = '98001';
        workOrder1.SVMXC__Order_Status__c='Open';
        //workOrder.SVMXC__Group_Member__c = Tech.id;
        workOrder1.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder1.SVMXC__Locked_By_DC__c = false;
        workOrder1.SVMXC__Service_Duration__c = 60;
        workOrder1.SVMXC__OptiMax_Status__c ='';
        workOrder1.SVMXC__Scheduling_Change_Token__c = '';
        workOrder1.SVMXC__Primary_Territory__c=territory.Id;

        insert workOrder1;

        String strWORecordID = String.valueOf(workOrder1.Id);

        boolean isForceBook = true;

        WSCH_Provider_SP_WOApptsController woApptController = new WSCH_Provider_SP_WOApptsController();
        woApptController.getIsForceBookJob();
        woApptController.setIsForceBookJob(isForceBook);
        woApptController.getIsDisplayForceBookMsg();

        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        woApptController.forceSchedule();

        Test.stopTest();

    }

    static TestMethod void testGetCurrentAppointment() {
        Test.startTest();

        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.name = 'South Central Region';
        territory.SVMXC__Optimizer_External_ID__c = 'SOU';
        insert territory;

        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        workOrder1.SVMXC__Zip__c = '98001';
        workOrder1.SVMXC__Order_Status__c='Open';
        //workOrder.SVMXC__Group_Member__c = Tech.id;
        workOrder1.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder1.SVMXC__Locked_By_DC__c = false;
        workOrder1.SVMXC__Service_Duration__c = 60;
        workOrder1.SVMXC__OptiMax_Status__c ='';
        workOrder1.SVMXC__Scheduling_Change_Token__c = '';
        workOrder1.SVMXC__Primary_Territory__c=territory.Id;

        insert workOrder1;

        String strWORecordID = String.valueOf(workOrder1.Id);

        WSCH_Provider_SP_WOApptsController woApptController = new WSCH_Provider_SP_WOApptsController();
        woApptController.getCurrentAppointment(strWORecordID);
        woApptController.getIsDisplayCurrentAppt();

        Test.stopTest();
    }

    static TestMethod void testIsWOValidToGetAppointments() {

        Test.startTest();

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
        svmxprocess.SVMXC__Dispatch_Process_Status__c='Complete';
        svmxprocess.SVMXC__Dispatch_Method__c='Optimax';
        svmxprocess.RecordTypeId = DispatchProRecordTypeId;
        insert svmxprocess;

        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrder.SVMXC__Locked_By_DC__c = false;
        workOrder.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        insert workOrder;

        WSCH_Provider_SP_WOApptsController woApptController = new WSCH_Provider_SP_WOApptsController();
        woApptController.isWOValidToGetAppointments(workOrder);

        workOrder.SVMXC__Locked_By_DC__c = true;
        workOrder.SVMXC__Work_Order_Scheduling_Status__c = 'dispatched';
        update workOrder;
        woApptController.isWOValidToGetAppointments(workOrder);

        workOrder.SVMXC__OptiMax_Status__c = 'OPT_PENDING';
        workOrder.SVMXC__Work_Order_Scheduling_Status__c = null;
        update workOrder;
        woApptController.isWOValidToGetAppointments(workOrder);
        
        Test.stopTest();
    }

    static TestMethod void testMoreMethods() {
        test.startTest();
        WSCH_Provider_SP_WOApptsController woApptController = new WSCH_Provider_SP_WOApptsController();

        woApptController.strXMLData = null;
        woApptController.isBookApptFailed = false;
        woApptController.isBookApptExecuted = false;
        woApptController.getIsBookApptSuccess();
        woApptController.getIsBookApptFailure();

        woApptController.isForceBookJob = true;
        woApptController.isDisplayForceBookMsg = true;
        woApptController.getIsBookApptSuccess();

        woApptController.getDisplayViewMore();
        test.stopTest();
    }
}