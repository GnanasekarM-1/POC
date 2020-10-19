@isTest
public with sharing class WSCH_Provider_ECO_ApptWindowSetup_UT {
    
    static Map<String,String> AppointmentWindowRecordTypeNameToIdMap;
    
    static testmethod void testAppointmentTypeInsert() {
        system.debug('*****testAppointmentTypeInsert Enter*****');
        insertTestData();
        
        WSCH_Provider_ECO_AppointmentWindowSetup AWS = new WSCH_Provider_ECO_AppointmentWindowSetup();
        
        
        SVMXC__SM_Appointment_Window__c existingtimeWindow = [Select id,Name from SVMXC__SM_Appointment_Window__c where recordtype.name = 'Time Window'][0];
        
        AWS.selectedLookupId = existingtimeWindow.id;
        AWS.selectedLookupName = existingtimeWindow.name;
        AWS.rowNumber = 0;
        
        
        AWS.isNewWindow = false;
        AWS.newAppointmentType();
        AWS.fetchtimeWindowData();
        AWS.addtimeWindows();
        AWS.rowNumber = 1;
        AWS.removetimeWindows();
        
        AWS.rowNumber = 0;
        AWS.isNewWindow = true;
        
        AWS.addtimeWindows();
        AWS.AppointmentTypeName = 'Test Type';
        AWS.AppointmentTypeDescription = 'Test Description';
        
        AWS.timeWindowList[1].timeWindow.name = 'Test window';
        AWS.timeWindowList[1].timeWindow.SVMXC__SM_Window_Start_Time__c = '12:00';
        AWS.timeWindowList[1].timeWindow.SVMXC__SM_Window_End_Time__c = '15:00';
        
        AWS.save();
        AWS.cancel();
        
        //test Exception for duplicate name
        AWS = new WSCH_Provider_ECO_AppointmentWindowSetup();
        existingtimeWindow = [Select id,Name from SVMXC__SM_Appointment_Window__c where recordtype.name = 'Time Window'][0];
        
        AWS.selectedLookupId = existingtimeWindow.id;
        AWS.selectedLookupName = existingtimeWindow.name;
        AWS.rowNumber = 0;
        
        
        AWS.isNewWindow = false;
        AWS.newAppointmentType();
        AWS.fetchtimeWindowData();
        AWS.addtimeWindows();
        AWS.rowNumber = 1;
        AWS.removetimeWindows();
        
        AWS.rowNumber = 0;
        AWS.isNewWindow = true;
        
        AWS.addtimeWindows();
        AWS.AppointmentTypeName = 'Test Type';
        AWS.AppointmentTypeDescription = 'Test Description';
        
        AWS.timeWindowList[1].timeWindow.name = 'Test window';
        AWS.timeWindowList[1].timeWindow.SVMXC__SM_Window_Start_Time__c = '12:00';
        AWS.timeWindowList[1].timeWindow.SVMXC__SM_Window_End_Time__c = '15:00';
        
        AWS.save();
        
        //Test Exception for duplicate slot time
        AWS = new WSCH_Provider_ECO_AppointmentWindowSetup();
        AWS.rowNumber = 0;
        AWS.newAppointmentType();
        AWS.removetimeWindows();
        AWS.isNewWindow = true;
        
        AWS.addtimeWindows();
        AWS.AppointmentTypeName = 'Test Type2';
        AWS.AppointmentTypeDescription = 'Test Description';
        
        AWS.timeWindowList[0].timeWindow.name = 'Test window 3';
        AWS.timeWindowList[0].timeWindow.SVMXC__SM_Window_Start_Time__c = '12:00';
        AWS.timeWindowList[0].timeWindow.SVMXC__SM_Window_End_Time__c = '15:00';
        
        AWS.save();
        //AWS.appointmentTypeList
        //AWS.editAppointmentType();
    }

    static testmethod void testAppointmentTypeEdit() {
        system.debug('*****testAppointmentTypeEdit Enter*****');
        insertTestData();
        WSCH_Provider_ECO_AppointmentWindowSetup AWS = new WSCH_Provider_ECO_AppointmentWindowSetup();

        

        AWS.appointmentTypeList[0].isSelected = true;
        AWS.editAppointmentType();
        AWS.rowNumber = 0;
        AWS.removeTimeWindows();
        AWS.isNewWindow = false;
        AWS.addtimeWindows();
        AWS.selectedLookupId = [Select id from SVMXC__SM_Appointment_Window__c where name = 'Test window2'][0].id;
        AWS.fetchtimeWindowData();
        AWS.isNewWindow = true;
        AWS.addtimeWindows();
        
        AWS.timeWindowList[1].timeWindow.name = 'Test window3456';
        AWS.timeWindowList[1].timeWindow.SVMXC__SM_Window_Start_Time__c = '12:00';
        AWS.timeWindowList[1].timeWindow.SVMXC__SM_Window_End_Time__c = '13:00';
        

        AWS.save();
        
        //Test Duplicate time slots
        AWS = new WSCH_Provider_ECO_AppointmentWindowSetup();

        AWS.appointmentTypeList[0].isSelected = true;
        AWS.editAppointmentType();
        
        AWS.isNewWindow = true;
        AWS.addtimeWindows();
        
        AWS.timeWindowList[2].timeWindow.name = 'Test window3';
        AWS.timeWindowList[2].timeWindow.SVMXC__SM_Window_Start_Time__c = '10:00';
        AWS.timeWindowList[2].timeWindow.SVMXC__SM_Window_End_Time__c = '13:00';
        

        AWS.save();
        
        //Test Duplicate names
        AWS = new WSCH_Provider_ECO_AppointmentWindowSetup();

        AWS.appointmentTypeList[0].isSelected = true;
        AWS.editAppointmentType();
        
        AWS.isNewWindow = true;
        AWS.addtimeWindows();
        
        AWS.timeWindowList[2].timeWindow.name = 'Test window3456';
        AWS.timeWindowList[2].timeWindow.SVMXC__SM_Window_Start_Time__c = '10:30';
        AWS.timeWindowList[2].timeWindow.SVMXC__SM_Window_End_Time__c = '13:30';
        

        AWS.save();


    }

    static testmethod void testAppointmentTypeDelete() {
        system.debug('*****testAppointmentTypeDelete Enter*****');
        insertTestData();
        WSCH_Provider_ECO_AppointmentWindowSetup AWS = new WSCH_Provider_ECO_AppointmentWindowSetup();
        AWS.appointmentTypeList[0].isSelected = true;
        AWS.deleteAppointmentType();
    }
    
    static void insertTestData() {
       
        List<SVMXC__SM_Appointment_Window__c> timeWindowList = new List<SVMXC__SM_Appointment_Window__c>();

        SVMXC__SM_Appointment_Window__c timeWindow = new SVMXC__SM_Appointment_Window__c();
        timeWindow.name = 'Test window1';
        timeWindow.SVMXC__SM_Time_Window_Name__c = 'Test window1';
        timeWindow.SVMXC__SM_Window_Start_Time__c = '09:00';
        timeWindow.SVMXC__SM_Window_End_Time__c = '12:00';
        timeWindow.RecordTypeId = Schema.SObjectType.SVMXC__SM_Appointment_Window__c.getRecordTypeInfosByName().get('Time Window').getRecordTypeId(); 
        timeWindowList.add(timeWindow);
        
        timeWindow = new SVMXC__SM_Appointment_Window__c();
        timeWindow.name = 'Test window2';
        timeWindow.SVMXC__SM_Time_Window_Name__c = 'Test window2';
        timeWindow.SVMXC__SM_Window_Start_Time__c = '10:00';
        timeWindow.SVMXC__SM_Window_End_Time__c = '13:00';
        timeWindow.RecordTypeId = Schema.SObjectType.SVMXC__SM_Appointment_Window__c.getRecordTypeInfosByName().get('Time Window').getRecordTypeId(); 
        timeWindowList.add(timeWindow);
        timeWindow = new SVMXC__SM_Appointment_Window__c();
        Insert timeWindowList;

        List<SVMXC__SM_Appointment_Window__c> apptTypeList = new List<SVMXC__SM_Appointment_Window__c>();
        SVMXC__SM_Appointment_Window__c apptType = new SVMXC__SM_Appointment_Window__c();
        apptType.name = 'Test Type1';
        apptType.SVMXC__SM_Appointment_Type_Name__c = 'Test Type1';
        apptType.SVMXC__SM_Appointment_Type_Description__c = 'Testing';
        apptType.RecordTypeId = Schema.SObjectType.SVMXC__SM_Appointment_Window__c.getRecordTypeInfosByName().get('Appointment Type').getRecordTypeId(); 
        apptTypeList.add(apptType);
        Insert apptTypeList;

        List<SVMXC__SM_Appointment_Window__c> apptTypeDefList = new List<SVMXC__SM_Appointment_Window__c>();
        SVMXC__SM_Appointment_Window__c apptTypeDef = new SVMXC__SM_Appointment_Window__c();
        apptTypeDef.SVMXC__SM_Time_Window__c = timeWindowList[0].id;
        apptTypeDef.SVMXC__SM_Appointment_Type__c = apptTypeList[0].id;
        apptTypeDef.name = apptTypeList[0].name + '-' + timeWindowList[0].name;
        apptTypeDef.RecordTypeId = Schema.SObjectType.SVMXC__SM_Appointment_Window__c.getRecordTypeInfosByName().get('Appointment Type Definition').getRecordTypeId(); 
        apptTypeDefList.add(apptTypeDef);
        Insert apptTypeDefList;

    }
    
    static testMethod void testTags() {
        WSCH_Provider_ECO_AppointmentWindowSetup aws = new WSCH_Provider_ECO_AppointmentWindowSetup();
        aws.getTAG001();
        aws.getTAG002();
        aws.getTAG003();
        aws.getTAG004();
        aws.getTAG005();
        aws.getTAG006();
        aws.getTAG007();
        aws.getTAG008();
        aws.getTAG009();
        aws.getTAG010();
        aws.getTAG011();
        aws.getTAG012();
        aws.getTAG013();
        aws.getTAG014();
        aws.getTAG015();
        aws.getTAG016();
        aws.getTAG017();
        aws.getTAG018();
        aws.getTAG019();
        aws.getTAG020();
        aws.getTAG021();
        aws.getTAG022();
        aws.getTAG023();
        aws.getTAG024();
        aws.backToSetup();
    }
    
}