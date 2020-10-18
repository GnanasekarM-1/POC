@isTest
private class WSCH_Provider_ECO_ManageTimeWindows_UT {

    static testMethod void testNewTimeWindow() {
        //Testing insert new time window
        insertTestData();
        WSCH_Provider_ECO_ManageTimeWindows mtw = new WSCH_Provider_ECO_ManageTimeWindows();
        mtw.newTimeWindows();
        
        mtw.timeWindowsToSaveList[0].name = 'Test Window';
        mtw.timeWindowsToSaveList[0].SVMXC__SM_Window_Start_Time__c = '08:00';
        mtw.timeWindowsToSaveList[0].SVMXC__SM_Window_End_Time__c = '09:00';
        mtw.addTimeWindow();
        mtw.rowNumber = 1;
        mtw.removeTimeWindow();
        mtw.saveTimeWindows();
        
        
        //Testing Exception for duplicate time slots
        mtw = new WSCH_Provider_ECO_ManageTimeWindows();
        mtw.newTimeWindows();
        
        mtw.timeWindowsToSaveList[0].name = 'Test Window';
        mtw.timeWindowsToSaveList[0].SVMXC__SM_Window_Start_Time__c = '08:00';
        mtw.timeWindowsToSaveList[0].SVMXC__SM_Window_End_Time__c = '09:00';
        mtw.saveTimeWindows();
        
        //Testing exception for duplicate name
        mtw = new WSCH_Provider_ECO_ManageTimeWindows();
        mtw.newTimeWindows();
        
        mtw.timeWindowsToSaveList[0].name = 'Test Window';
        mtw.timeWindowsToSaveList[0].SVMXC__SM_Window_Start_Time__c = '08:30';
        mtw.timeWindowsToSaveList[0].SVMXC__SM_Window_End_Time__c = '09:30';
        mtw.saveTimeWindows();
        
    }
    
    static testMethod void testEditTimeWindow() {
        insertTestData();
        WSCH_Provider_ECO_ManageTimeWindows mtw = new WSCH_Provider_ECO_ManageTimeWindows();
        mtw.timeWindowList[0].isSelected = true;
        mtw.editTimeWindows();
        mtw.saveTimeWindows();
        
        //Test Exception for duplictae time slots
        mtw = new WSCH_Provider_ECO_ManageTimeWindows();
        mtw.newTimeWindows();
        
        mtw.timeWindowsToSaveList[0].name = 'Test Window';
        mtw.timeWindowsToSaveList[0].SVMXC__SM_Window_Start_Time__c = '08:30';
        mtw.timeWindowsToSaveList[0].SVMXC__SM_Window_End_Time__c = '09:30';
        mtw.saveTimeWindows();
        
        mtw = new WSCH_Provider_ECO_ManageTimeWindows();
        mtw.timeWindowList[0].isSelected = true;
        mtw.editTimeWindows();
        if(mtw.timeWindowsToSaveList[0].SVMXC__SM_Window_Start_Time__c != '08:30') {
        	mtw.timeWindowsToSaveList[0].SVMXC__SM_Window_Start_Time__c = '08:30';
        	mtw.timeWindowsToSaveList[0].SVMXC__SM_Window_End_Time__c = '09:30';
        } else {
        	mtw.timeWindowsToSaveList[0].SVMXC__SM_Window_Start_Time__c = '09:00';
        	mtw.timeWindowsToSaveList[0].SVMXC__SM_Window_End_Time__c = '12:00';
        }
        mtw.saveTimeWindows();
    }
    
    static testMethod void testDeleteTimeWindow() {
        insertTestData();
        WSCH_Provider_ECO_ManageTimeWindows mtw = new WSCH_Provider_ECO_ManageTimeWindows();
        mtw.timeWindowList[0].isSelected = true;
        
        mtw.deleteComfirmation();
        mtw.cancel();
        mtw.deleteTimeWindows();
    }
    
    
    static testMethod void testBackToSetup() {
        WSCH_Provider_ECO_ManageTimeWindows mtw = new WSCH_Provider_ECO_ManageTimeWindows();
        mtw.backToAppointmentTypes();
    }
    
    static testMethod void testTags() {
        WSCH_Provider_ECO_ManageTimeWindows mtw = new WSCH_Provider_ECO_ManageTimeWindows();
        mtw.getTAG001();
        mtw.getTAG002();
        mtw.getTAG003();
        mtw.getTAG004();
        mtw.getTAG005();
        mtw.getTAG006();
        mtw.getTAG007();
        mtw.getTAG008();
        mtw.getTAG009();
        mtw.getTAG010();
        mtw.getTAG011();
        mtw.getTAG012();
        mtw.getTAG013();
        mtw.getTAG014();
        mtw.getTAG015();
        mtw.getTAG016();
        mtw.getTAG017();
        mtw.getTAG018();
        mtw.getTAG019();
        mtw.getTAG020();
        mtw.getTAG021();
        mtw.getTAG022();
        mtw.getTAG023();

    }
    
    static testMethod void testSort() {
    	insertTestData();
    	WSCH_Provider_ECO_ManageTimeWindows mtw = new WSCH_Provider_ECO_ManageTimeWindows();
    	mtw.getSortOptions();
    	mtw.sortType = 'Time Window Name - Ascending';
    	mtw.sortList();
    	mtw.sortType = 'Time Window Name - Descending';
    	mtw.sortList();
    	mtw.sortType = 'Start Time - Ascending';
    	mtw.sortList();
    	mtw.sortType = 'Start Time - Descending';
    	mtw.sortList();
    	mtw.sortType = 'End Time - Ascending';
    	mtw.sortList();
    	mtw.sortType = 'End Time - Descending';
    	mtw.sortList();
    	
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
        apptTypeDef = new SVMXC__SM_Appointment_Window__c();
        apptTypeDef.SVMXC__SM_Time_Window__c = timeWindowList[1].id;
        apptTypeDef.SVMXC__SM_Appointment_Type__c = apptTypeList[0].id;
        apptTypeDef.name = apptTypeList[0].name + '-' + timeWindowList[1].name;
        apptTypeDef.RecordTypeId = Schema.SObjectType.SVMXC__SM_Appointment_Window__c.getRecordTypeInfosByName().get('Appointment Type Definition').getRecordTypeId(); 
        apptTypeDefList.add(apptTypeDef);
        Insert apptTypeDefList;
        
    }
    
}