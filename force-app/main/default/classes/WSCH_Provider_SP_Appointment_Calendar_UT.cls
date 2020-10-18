/**
UT class for WSCH_Provider_SP_Appointments_Calendar
**/
@isTest
(SeeAllData = false)
public with sharing class WSCH_Provider_SP_Appointment_Calendar_UT {

    public Integer APPT_MAX_SIZE = 99;
    
    public WSCH_Provider_SP_Appointment_Calendar_UT() {
        /*List<SVMXC__ServiceMax_Config_Data__c> lst = [select id from SVMXC__ServiceMax_Config_Data__c where SVMXC__Setting_Unique_ID__c IN ('GLOB001_GBL007')];
        
        for(SVMXC__ServiceMax_Config_Data__c confObj : lst)
        {
            confObj.SVMXC__Display_Value__c = 'true';
            confObj.SVMXC__Internal_Value__c = 'true';
            confObj.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        }
        if(lst != null && lst.size() > 0)
        update lst;*/ 
    }
    
    //static {
        //WSCH_Provider_SP_Appointment_Calendar_UT apptCalUT = new WSCH_Provider_SP_Appointment_Calendar_UT();
        
        /*SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CREATE_WO';
        //workOrder.Name = 'WO-1234';
        insert workOrder;
        
        WSCH_Provider_SP_Appointments_Calendar apptCalController = new WSCH_Provider_SP_Appointments_Calendar();
        apptCalController.strWORecordID = workOrder.Id;
        apptCalController.strWorkOrderID = workOrder.Name;*/
    //}

    static TestMethod void getWOApptsAndBookAppts() {
        System.debug(logginglevel.ERROR,'###INSIDE getWOApptsAndBookAppts');
        //createTechFieldSettings();
        //WSCH_TestDataFactory.createTechFieldSettings('Name,SVMXC__Email__c');
        //WSCH_TestDataFactory.createOptimizationSettings('OptiMax,ServicePower', 'True');
        
        System.debug(logginglevel.ERROR,'****UT_DCON003_SET0004 ' + String.valueof(WSCH_CommonUtils.getSettingValue('DCON003','SET004')));
        
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
        BusinessHours lstOfBusinessHours1;
        lstOfBusinessHours1 = [SELECT Id,IsActive,IsDefault,MondayStartTime,MondayEndTime,
                               TuesdayStartTime,TuesdayEndTime,WednesdayStartTime,WednesdayEndTime,
                               ThursdayStartTime,ThursdayEndTime,FridayStartTime,FridayEndTime,SaturdayStartTime,
                               SaturdayEndTime,SundayStartTime,SundayEndTime FROM BusinessHours
                               WHERE IsDefault = TRUE AND IsActive = TRUE LIMIT 1];
        
        SVMXC__Service_Level__c slaone=new SVMXC__Service_Level__c(
            Name='Test one',
            SVMXC__Description__c='Test one Description',
            SVMXC__Active__c =true,
            SVMXC__Initial_Response_Tracked_On__c = 'Case'  , 
            SVMXC__Select__c=true,        
            SVMXC__Business_Hours__c = lstOfBusinessHours1.id         
        );
        insert slaone;

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
        //workOrder1.SVMXC__Locked_By_DC__c = false;

        workOrder1.SVMXC__Service_Duration__c = 60;
        //workOrder1.SVMXC__OptiMax_Status__c ='';
        workOrder1.SVMXC__Scheduling_Change_Token__c = '';
        workOrder1.SVMXC__Primary_Territory__c=territory.Id;

        workOrder1.SVMXC__Locked_By_DC__c = true;        
        workOrder1.SVMXC__Work_Order_Scheduling_Status__c = null;
        workOrder1.SVMXC__OptiMax_Status__c =null;
        workOrder1.SVMXC__SLA_Terms__c = slaone.id;

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

        WSCH_Provider_SP_Appointments_Calendar woApptController = new WSCH_Provider_SP_Appointments_Calendar();
        
        WSCH_Provider_SP_Appointments_Calendar.getBusinessHoursByWO(workOrder1);
        WSCH_Provider_SP_Appointments_Calendar.getWOBusinessHours(workOrder1);

        woApptController.strXMLData = strXMLData;
        woApptController.selectedRowId = '0';
        woApptController.strWORecordID = workOrder1.Id;   //'1234';   //workOrder2.Id;
        woApptController.strWorkOrderID = workOrder1.Name;
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
        slot.setEndDateTime(DateTime.now().adddays(7));
        slot.setIntTimeZoneOffset(60);
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
        PageReference testPage = new pagereference('/apex/WSCH_Provider_SP_Appointments_Calendar');
        String woName = [SELECT Name FROM SVMXC__Service_Order__c WHERE ID =: workOrder1.Id LIMIT 1].NAME;
        testPage.getParameters().put('woNumber', woName);
        testPage.getParameters().put('workorderID', workOrder1.Id);

        Test.setCurrentPage(testPage);

        woApptController.buildResponseData();
            /*List<SVMXC__ServiceMax_Config_Data__c> lstsetting = new List<SVMXC__ServiceMax_Config_Data__c>();

        lstsetting = new INTF_ConfigSync().getSettings(new set<string>(), new set<string>(), new set<string>{'DCON003_SET00004'}, '');
         for (integer i=0; i<lstsetting.size();i++)
            {
                lstsetting[i].SVMXC__Display_Value__c = 'List'  ;
                lstsetting[i].SVMXC__Internal_Value__c = 'List'  ;
                lstsetting[i].SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15) ));
            }
            if(lstsetting.size()>0)
            update lstsetting;*/
        //woApptController.buildListData();
        //woApptController.buildResponseData();
        //woApptController.viewMoreApp ointments();
        try{woApptController.createRows(appointmentList);}catch(exception e){}

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
        slot.setIntTimeZoneOffset(60);
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
        //woApptController.buildResponseData();

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
        //woApptController.buildResponseData();
        //woApptController.cancelAppointment();
        try{woApptController.cancelAppointment();}catch(exception e){}
        try{woApptController.bookJob();}catch(exception e){}
        try{woApptController.buildListData();}catch(exception e){}
        try{woApptController.createEventsJson(appointmentList);}catch(exception e){}
        try{WSCH_Provider_SP_Appointments_Calendar.getAppointmentHook();}catch(exception e){}
        try{woApptController.viewMoreAppointments();}catch(exception e){}
        

        //Test with different combination of boolean values
        woApptController.strXMLData = '';
        woApptController.isBookApptFailed = false;
        woApptController.isBookApptExecuted = false;
        woApptController.isBookApptSuccess = false;

        Test.stopTest();
    }
    static TestMethod void getWOApptsAndBookAppts1() {

        Test.startTest();
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
        
        

        WSCH_Provider_SP_Appointments_Calendar woApptController = new WSCH_Provider_SP_Appointments_Calendar();
        woApptController.strXMLData = '<?xml version="1.0" encoding="UTF-8"?>'+ '<rows>'+
        '<row   id="1"><cell></cell> <cell> first </cell><cell> second </cell><cell>' +
        'third</cell><cell> fourth</cell></row>'+ '<row id="2"><cell></cell>' +
        '<cell> first </cell><cell> second </cell><cell> third</cell><cell>fourth</cell></row></rows>';
                PageReference testPage = new pagereference('/apex/WSCH_Provider_SP_Appointments_Calendar');
        String woName = [SELECT Name FROM SVMXC__Service_Order__c WHERE ID =: workOrder1.Id LIMIT 1].NAME;
    testPage.getParameters().put('woNumber', woName);
    testPage.getParameters().put('workorderID', workOrder1.Id);
    Test.setCurrentPage(testPage);
        woApptController.strOfferApptErrorMsg = 'Offer Appointment successful';
        woApptController.strBookApptErrorMsg = 'Book appointment failed';
        woApptController.isBookApptFailed = true;
        woApptController.isBookApptExecuted = true;
        woApptController.isBookApptSuccess = false;
        woApptController.strBookApptSuccessMsg = 'Book appointment successful';
        //woApptController.pageLoad();

       
        //Test with status code = 0 and all boolean values set to true
        //WSCH_AppointmentsResponse res = WSCH_OptimizedSchedulingService.getAvailableAppointments(workOrder2.Id, 5, 1);
        WSCH_AppointmentsResponse res = new WSCH_AppointmentsResponse();
        res.statusCode=0;
        res.statusMessage='status message';
        WSCH_Appointment slot = new WSCH_Appointment();
        slot.setStartDateTime(DateTime.now());
        slot.setEndDateTime(DateTime.now().adddays(7));
        slot.setIntTimeZoneOffset(60);
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

        //Test.startTest();

        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());

            /*List<SVMXC__ServiceMax_Config_Data__c> lstsetting = new List<SVMXC__ServiceMax_Config_Data__c>();

        lstsetting = new INTF_ConfigSync().getSettings(new set<string>(), new set<string>(), new set<string>{'DCON003_SET00004'}, '');
         for (integer i=0; i<lstsetting.size();i++)
            {
                lstsetting[i].SVMXC__Display_Value__c = 'List'  ;
                lstsetting[i].SVMXC__Internal_Value__c = 'List'  ;
                lstsetting[i].SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15) ));
            }
            if(lstsetting.size()>0)
            update lstsetting;*/
        

        woApptController.buildResponseData();
        //woApptController.buildListData();
        //woApptController.buildResponseData();
        //woApptController.viewMoreApp ointments();

        //Test.stopTest();
        
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

        WSCH_Provider_SP_Appointments_Calendar woApptController = new WSCH_Provider_SP_Appointments_Calendar();

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
        //woApptController.viewMoreAppointments();

        Test.stopTest();
    }

    static TestMethod void testCustomTagMethods() {

        Test.startTest();

        WSCH_Provider_SP_Appointments_Calendar.getTAG001();
        WSCH_Provider_SP_Appointments_Calendar.getTAG002();
        WSCH_Provider_SP_Appointments_Calendar.getTAG003();
        WSCH_Provider_SP_Appointments_Calendar.getTAG004();
        WSCH_Provider_SP_Appointments_Calendar.getTAG005();
        WSCH_Provider_SP_Appointments_Calendar.getTAG006();
        WSCH_Provider_SP_Appointments_Calendar.getTAG007();
        WSCH_Provider_SP_Appointments_Calendar.getTAG008();
        WSCH_Provider_SP_Appointments_Calendar.getTAG009();
        WSCH_Provider_SP_Appointments_Calendar.getTAG010();
        WSCH_Provider_SP_Appointments_Calendar.getTAG011();
        WSCH_Provider_SP_Appointments_Calendar.getTAG012();
        WSCH_Provider_SP_Appointments_Calendar.getTAG013();
        WSCH_Provider_SP_Appointments_Calendar.getTAG014();
        WSCH_Provider_SP_Appointments_Calendar.getTAG015();
        WSCH_Provider_SP_Appointments_Calendar.getTAG016();
        WSCH_Provider_SP_Appointments_Calendar.getTAG017();
        WSCH_Provider_SP_Appointments_Calendar.getTAG018();
        WSCH_Provider_SP_Appointments_Calendar.getTAG019();
        WSCH_Provider_SP_Appointments_Calendar.getTAG020();
        WSCH_Provider_SP_Appointments_Calendar.getTAG021();
        WSCH_Provider_SP_Appointments_Calendar.getTAG022();
        WSCH_Provider_SP_Appointments_Calendar.getTAG023();
        WSCH_Provider_SP_Appointments_Calendar.getTAG024();
        WSCH_Provider_SP_Appointments_Calendar.getTAG025();
        WSCH_Provider_SP_Appointments_Calendar.getTAG026();
        WSCH_Provider_SP_Appointments_Calendar.getTAG027();
        WSCH_Provider_SP_Appointments_Calendar.getTAG028();
        WSCH_Provider_SP_Appointments_Calendar.getTAG029();
        WSCH_Provider_SP_Appointments_Calendar.getTAG030();
        WSCH_Provider_SP_Appointments_Calendar.getTAG031();
        WSCH_Provider_SP_Appointments_Calendar.getTAG032();
        WSCH_Provider_SP_Appointments_Calendar.getTAG033();
        WSCH_Provider_SP_Appointments_Calendar.getTAG034();
        WSCH_Provider_SP_Appointments_Calendar.getTAG037();
        WSCH_Provider_SP_Appointments_Calendar.getTAG038();
        WSCH_Provider_SP_Appointments_Calendar.getTAG039();
        WSCH_Provider_SP_Appointments_Calendar.getTAG040();
        WSCH_Provider_SP_Appointments_Calendar.getTAG041();
        WSCH_Provider_SP_Appointments_Calendar.getTAG042();
        WSCH_Provider_SP_Appointments_Calendar.getTAG043();
        WSCH_Provider_SP_Appointments_Calendar.getTAG044();
        WSCH_Provider_SP_Appointments_Calendar.getTAG045();
        WSCH_Provider_SP_Appointments_Calendar.getTAG046();
        WSCH_Provider_SP_Appointments_Calendar.getTAG047();
        WSCH_Provider_SP_Appointments_Calendar.getTAG048();
        WSCH_Provider_SP_Appointments_Calendar.getTAG049();
        WSCH_Provider_SP_Appointments_Calendar.getTAG050();
        WSCH_Provider_SP_Appointments_Calendar.getTAG051();
        WSCH_Provider_SP_Appointments_Calendar.getTAG052();
        WSCH_Provider_SP_Appointments_Calendar.getTAG053();
        WSCH_Provider_SP_Appointments_Calendar.getTAG054();
        WSCH_Provider_SP_Appointments_Calendar.getTAG055();
        WSCH_Provider_SP_Appointments_Calendar.getTAG056();
        WSCH_Provider_SP_Appointments_Calendar.getTAG057();
        WSCH_Provider_SP_Appointments_Calendar.getTAG058();
        WSCH_Provider_SP_Appointments_Calendar.getTAG059();
        WSCH_Provider_SP_Appointments_Calendar.getTAG060();
        WSCH_Provider_SP_Appointments_Calendar.getTAG061();
        WSCH_Provider_SP_Appointments_Calendar.getTAG062();
        WSCH_Provider_SP_Appointments_Calendar.getTAG063();
        WSCH_Provider_SP_Appointments_Calendar.getTAG064();
        WSCH_Provider_SP_Appointments_Calendar.getTAG065();
        WSCH_Provider_SP_Appointments_Calendar.getTAG066();
        WSCH_Provider_SP_Appointments_Calendar.getTAG067();
        WSCH_Provider_SP_Appointments_Calendar.getTAG068();
        WSCH_Provider_SP_Appointments_Calendar.getTAG069();
        WSCH_Provider_SP_Appointments_Calendar.getTAG070();
        WSCH_Provider_SP_Appointments_Calendar.getTAG071();
        WSCH_Provider_SP_Appointments_Calendar.getTAG072();
        

        WSCH_Provider_SP_Appointments_Calendar controller = new WSCH_Provider_SP_Appointments_Calendar();
        controller.getAppointmentsTitle();
        controller.getDisplayViewMore();
        controller.getHLPTITLE();
        controller.getHLPURL();

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

        WSCH_Provider_SP_Appointments_Calendar woApptController = new WSCH_Provider_SP_Appointments_Calendar();
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
        
        WSCH_Provider_SP_Appointments_Calendar controller = new WSCH_Provider_SP_Appointments_Calendar();
        controller.strTimeZone = 'Asia/Colombo';

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
        workOrder1.SVMXC__Appointment_Promised_Time_Slot__c = '07:30 - 11:00, Thursday, 2014-12-25, false, 2014-12-25, 2014-12-25, -1, 2014-12-25 07:30:00, 2014-12-25 11:00:00';

        insert workOrder1;

        String strWORecordID = String.valueOf(workOrder1.Id);

        WSCH_Provider_SP_Appointments_Calendar woApptController = new WSCH_Provider_SP_Appointments_Calendar();
        //woApptController.getCurrentAppointment(strWORecordID);
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

        WSCH_Provider_SP_Appointments_Calendar woApptController = new WSCH_Provider_SP_Appointments_Calendar();
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
        WSCH_Provider_SP_Appointments_Calendar woApptController = new WSCH_Provider_SP_Appointments_Calendar();

        woApptController.strXMLData = null;
        woApptController.isBookApptFailed = false;
        woApptController.isBookApptExecuted = false;
        woApptController.getIsBookApptSuccess();
        woApptController.getIsBookApptFailure();

        woApptController.isForceBookJob = true;
        woApptController.isDisplayForceBookMsg = true;
        woApptController.getIsBookApptSuccess();

        woApptController.getDisplayViewMore();
        woApptController.getIsEarlyArrival();
        //woApptController.getIsDisplayTechName();
        woApptController.getIsEnableHelpText();
        woApptController.getIsEnableCancelAppt();
        woApptController.getIsEnableFetchApptByStartEndDt();
        woApptController.getIsEnableUnresourcedTray();
        //woApptController.pageLoad();
        woApptController.getUserLocaleKey();
        woApptController.getUserOrgID();
        woApptController.getUserID();
        woApptController.calendarStartDate = 'calendarStartDate';
        woApptController.bookedTechnician = 'bookedTechnician';
        woApptController.bookedTimings = 'bookedTimings';
        woApptController.strForceBookMsg = 'strForceBookMsg';
        WSCH_Provider_SP_Appointments_Calendar.getIPAD004_TAG018();
        WSCH_Provider_SP_Appointments_Calendar.getTAG161();
        WSCH_Provider_SP_Appointments_Calendar.getTAG117();
        WSCH_Provider_SP_Appointments_Calendar.getTAG118();
        test.stopTest();
    }
    public static void createTechFieldSettings(){
        System.debug(logginglevel.ERROR,'###INSIDE createTechFieldSettings');
        String confProfileTypeId = '';
        String setValTypeId = '';
        String setTypeId = '';
        String subModTypeId = '';
        String modTypeId = '';
        List<SVMXC__ServiceMax_Processes__c> lstInsProcDrip = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Config_Data__c> lstInsConfDrip = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        RecordType[] recTypeId = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : recTypeId) //Loop to take a record type at a time
        {
            if(rt.Name == 'Configuration Profile' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                confProfileTypeId = rt.ID;
            else if(rt.Name == 'Setting Value' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                setValTypeId = rt.ID;
            else if(rt.Name == 'Settings' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                setTypeId = rt.id;
            else if(rt.Name == 'Submodule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                subModTypeId = rt.id;
            else if(rt.Name == 'Module' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                modTypeId = rt.id;
        }
        
        //adding DCON Process Module
        SVMXC__ServiceMax_Processes__c modProc_DCON = new SVMXC__ServiceMax_Processes__c();
        modProc_DCON.RecordTypeId = modTypeId;
        modProc_DCON.SVMXC__ModuleID__c = 'DCON';
        modProc_DCON.SVMXC__Name__c = 'Dispatch Management';
        modProc_DCON.SVMXC__IsStandard__c = true;
        modProc_DCON.SVMXC__Description__c = 'TEST MODULE DESCRIPTION';
        modProc_DCON.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.insert(modProc_DCON);
        
        //adding DCON003 Process SubModule
        SVMXC__ServiceMax_Processes__c subModProc_DCON003 = new SVMXC__ServiceMax_Processes__c();
        subModProc_DCON003.RecordTypeId = subModTypeId;
        subModProc_DCON003.SVMXC__SubmoduleID__c = 'DCON003';
        subModProc_DCON003.SVMXC__Name__c = 'Appointment Booking';
        subModProc_DCON003.SVMXC__IsStandard__c = true;
        subModProc_DCON003.SVMXC__Module__c = modProc_DCON.id;
        subModProc_DCON003.SVMXC__Description__c = 'TEST SUBMODULE DESCRIPTION';
        subModProc_DCON003.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.insert(subModProc_DCON003);
        
        //adding DCON003 SET004 Process Setting
        SVMXC__ServiceMax_Processes__c settingProc_DCON003_SET004 = new SVMXC__ServiceMax_Processes__c();
        settingProc_DCON003_SET004.RecordTypeId = setTypeId;
        settingProc_DCON003_SET004.SVMXC__SettingID__c = 'SET004';
        settingProc_DCON003_SET004.SVMXC__Data_Type__c = 'Text';
        settingProc_DCON003_SET004.SVMXC__Default_Value__c = 'Name';
        settingProc_DCON003_SET004.SVMXC__Setting_Type__c = 'Group';
        settingProc_DCON003_SET004.SVMXC__Search_Order__c = 'Group,Global';
        settingProc_DCON003_SET004.SVMXC__Active__c = true;
        settingProc_DCON003_SET004.SVMXC__IsStandard__c = true;
        settingProc_DCON003_SET004.SVMXC__Values__c = 'Name';
        settingProc_DCON003_SET004.SVMXC__Submodule__c = subModProc_DCON003.id;
        settingProc_DCON003_SET004.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
        settingProc_DCON003_SET004.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.insert(settingProc_DCON003_SET004);        
        
        //adding DCON003 SET004 Configuration Profile
        SVMXC__ServiceMax_Config_Data__c confProfile_DCON003_SET004 = new SVMXC__ServiceMax_Config_Data__c();
        confProfile_DCON003_SET004.SVMXC__Profile_Name__c = 'TestSvmxPro';
        confProfile_DCON003_SET004.RecordTypeId = confProfileTypeId;
        confProfile_DCON003_SET004.SVMXC__Configuration_Type__c = 'Global';
        confProfile_DCON003_SET004.SVMXC__Active__c = true;
        confProfile_DCON003_SET004.SVMXC__IsDefault__c = true;
        confProfile_DCON003_SET004.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.insert(confProfile_DCON003_SET004);
        
        //adding DCON003 SET004 Setting Value
        SVMXC__ServiceMax_Config_Data__c confDrip_DCON003_SET004 = new SVMXC__ServiceMax_Config_Data__c();
        confDrip_DCON003_SET004.RecordTypeId = setValTypeId;
        confDrip_DCON003_SET004.SVMXC__Setting_Configuration_Profile__c = confProfile_DCON003_SET004.id;
        confDrip_DCON003_SET004.SVMXC__Display_Value__c = 'Name';
        confDrip_DCON003_SET004.SVMXC__Internal_Value__c = 'Name';
        confDrip_DCON003_SET004.SVMXC__Setting_ID__c = settingProc_DCON003_SET004.id;
        confDrip_DCON003_SET004.SVMXC__Active__c = true; //
        confDrip_DCON003_SET004.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.insert(confDrip_DCON003_SET004);
        
        System.debug(logginglevel.ERROR,'#$#$DCON003_SET0004 ' + String.valueof(WSCH_CommonUtils.getSettingValue('DCON003','SET004')));
    }
}