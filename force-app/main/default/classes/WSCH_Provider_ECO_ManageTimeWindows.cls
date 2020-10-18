/*
 *        Copyright (C) 2017 ServiceMax From GE Digital
 *                    All rights reserved
 *
 */
/**
* This class serves as the controller for Manage Time Windows page
* @Author Anush R G
* @Name WSCH_Provider_ECO_ManageTimeWindows
* @Version Autumn 17
* @Since 2017
*/

public with sharing class WSCH_Provider_ECO_ManageTimeWindows {
    
    public List<TimeWindowWrapper> timeWindowList{get;set;}
    public List<SVMXC__SM_Appointment_Window__c> timeWindowsToSaveList{get;set;}
    public List<SVMXC__SM_Appointment_Window__c> appointmentTypesList{get;set;}
    public List<SVMXC__SM_Appointment_Window__c> timeWindowsToDelete{get;set;}
    
    public boolean displayEditPage{get;set;}
    public boolean isNewTimeWindow{get;set;}
    public boolean showAppointmentTypes{get;set;}
    public boolean isDeleteWindow{get;set;}
    
    public Integer rowNumber{get;set;}
    public Integer timeWindowsToSaveListSize{get;set;}
    
    public Id timeWindowRecTypeId{get;set;}
    
    public List<SelectOption> getSortOptions() {
        List<SelectOption> sortOptions = new List<SelectOption>();

        sortOptions.add(new SelectOption('Time Window Name - Ascending',getTAG027()));
        sortOptions.add(new SelectOption('Time Window Name - Descending',getTAG028()));
        sortOptions.add(new SelectOption('Start Time - Ascending',getTAG029()));
        sortOptions.add(new SelectOption('Start Time - Descending',getTAG030()));
        sortOptions.add(new SelectOption('End Time - Ascending',getTAG031()));
        sortOptions.add(new SelectOption('End Time - Descending',getTAG032()));
        return sortOptions;
    }
    public String sortType{get;set;}
    
    //Constructor
    public WSCH_Provider_ECO_ManageTimeWindows() {
        
        displayEditPage = false;
        showAppointmentTypes = true;
        isDeleteWindow = false;
        
        //Fetch all vailable Time Windows
        timeWindowList = new List<TimeWindowWrapper>();
        
        try{
            timeWindowRecTypeId = Schema.SObjectType.SVMXC__SM_Appointment_Window__c.getRecordTypeInfosByName().get('Time Window').getRecordTypeId();
            for(SVMXC__SM_Appointment_Window__c TW : [Select id,name,SVMXC__SM_Window_Start_Time__c,SVMXC__SM_Window_End_Time__c,SVMXC__SM_Time_Window_Name__c From SVMXC__SM_Appointment_Window__c Where RecordType.Name = 'Time Window' Order By Name Asc]) {
                TimeWindowWrapper timeWindow = new TimeWindowWrapper();
                timeWindow.isSelected = false;
                timeWindow.timeWindow = TW;
                timeWindowList.add(timeWindow);
            }
        } catch(Exception e){
            System.debug('*****Exception****'+e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
        }
        
        
    }
    
    //method to redirect page to creating new Time windows
    public void newTimeWindows() {
        displayEditPage = true;
        isNewTimeWindow = true;
        showAppointmentTypes = false;
        timeWindowsToSaveList = new List<SVMXC__SM_Appointment_Window__c>();
        SVMXC__SM_Appointment_Window__c newTimeWindow = new SVMXC__SM_Appointment_Window__c();
        newTimeWindow.recordTypeId = timeWindowRecTypeId;
        timeWindowsToSaveList.add(newTimeWindow);
        timeWindowsToSaveListSize = timeWindowsToSaveList.size();
    }
    
    //method to redirecting page to edit selected Time Windows
    public void editTimeWindows() {
        timeWindowsToSaveList = new List<SVMXC__SM_Appointment_Window__c>();
        Integer selectedCount = 0;
        for(TimeWindowWrapper TWW : timeWindowList) {
            if(TWW.isSelected) {
                timeWindowsToSaveList.add(TWW.timeWindow);
                selectedCount++;
            }
            if (selectedCount > 1) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTAG018()));
                return;
            }
        }
        if(selectedCount == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTAG010()));
            return;
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, getTAG024()));
        timeWindowsToSaveListSize = timeWindowsToSaveList.size();
        displayEditPage = true;
        isNewTimeWindow = false;
        showAppointmentTypes = true;
        showReleatedAppointmentTypes();
    }
    
    public void deleteComfirmation() {
        timeWindowsToDelete = new List<SVMXC__SM_Appointment_Window__c>();
        Integer selectedCount = 0;
        for(TimeWindowWrapper TWW : timeWindowList) {
            if(TWW.isSelected) {
                timeWindowsToDelete.add(TWW.timeWindow);
                selectedCount++;
            }
            if (selectedCount > 1) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTAG018()));
                return;
            }
        }
        if(selectedCount == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTAG010()));
            return;
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, getTAG011()));
        
        showReleatedAppointmentTypes();
        isDeleteWindow = true;
        showAppointmentTypes = true;
        
    }
    
    //Method to delete selected time windows
    public pageReference deleteTimeWindows() {
        
        
        List<SVMXC__SM_Appointment_Window__c> appointmentTypeDefsToDelete = new List<SVMXC__SM_Appointment_Window__c>();
        Integer selectedCount = 0;
        
        
        Savepoint sp = Database.setSavepoint();
        
        try{
            appointmentTypeDefsToDelete = [Select Id From SVMXC__SM_Appointment_Window__c Where SVMXC__SM_Time_Window__c =:timeWindowsToDelete[0].id and RecordType.Name = 'Appointment Type Definition'];
            if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SM_Appointment_Window__c')){      //SDL-SVMX-DELETE-FLS-ENFORCED
                Delete timeWindowsToDelete;
                if (appointmentTypeDefsToDelete.size() > 0) {
                    Delete appointmentTypeDefsToDelete;
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                return null;
            }
            PageReference pg = new PageReference('/apex/WSCH_Provider_ECO_ManageTimeWindows');
            pg.setRedirect(true);
            return pg;
        } catch(Exception e) {
            Database.rollback(sp);
            System.debug('*****Exception****'+e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            return null;
        }
        
    }
    
    //method to show related Appointment Types of the selected Time Window
    public void showReleatedAppointmentTypes() {
        Id timeWindowId;
        Integer selectedCount = 0;
        for(TimeWindowWrapper TWW : timeWindowList) {
            if(TWW.isSelected) {
                timeWindowId = TWW.timeWIndow.id;
                selectedCount++;
            }
            if (selectedCount > 1) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTAG018()));
                return;
            }
        }
        if(selectedCount == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTAG010()));
            return;
        }
        
        try{
            List<SVMXC__SM_Appointment_Window__c> apptointmentTypesDefsList = new List<SVMXC__SM_Appointment_Window__c>([Select id,SVMXC__SM_Appointment_Type__c from SVMXC__SM_Appointment_Window__c where SVMXC__SM_Time_Window__c =: timeWindowId]);
            Set<Id> appointmentTypesIdSet = new Set<Id>();
            
            for(SVMXC__SM_Appointment_Window__c TW : apptointmentTypesDefsList) {
                appointmentTypesIdSet.add(TW.SVMXC__SM_Appointment_Type__c);
            }
            
            appointmentTypesList = new List<SVMXC__SM_Appointment_Window__c>();
            appointmentTypesList = [Select Id,Name,SVMXC__SM_Appointment_Type_Description__c from SVMXC__SM_Appointment_Window__c where Id in :appointmentTypesIdSet];
        } catch(Exception e) {
            System.debug('*****Exception****'+e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
        }
        
        
    }
    
    //method to redirect to Appointment Types Setup page
    public pageReference backToAppointmentTypes() {
        PageReference pg = new PageReference('/apex/SVMXC__WSCH_Provider_ECO_AppointmentWindowSetup');
        pg.setRedirect(true);
        return pg;
    }
    
    public void removeTimeWindow() {
        timeWindowsToSaveList.remove(rowNumber);
        timeWindowsToSaveListSize = timeWindowsToSaveList.size();
    }
    
    public void addTimeWindow() {
        SVMXC__SM_Appointment_Window__c newTimeWindow = new SVMXC__SM_Appointment_Window__c();
        newTimeWindow.recordTypeId = timeWindowRecTypeId;
        timeWindowsToSaveList.add(newTimeWindow);
        timeWindowsToSaveListSize = timeWindowsToSaveList.size();
    }
    
    
    public PageReference saveTimeWindows() {
        Savepoint sp = Database.setSavepoint();
        try {
            
            Map<String,String> timeSlotsMap = new Map<String,String>();
            for(SVMXC__SM_Appointment_Window__c TW : [Select id,name,SVMXC__SM_Window_Start_Time__c,SVMXC__SM_Window_End_Time__c,SVMXC__SM_Time_Window_Name__c From SVMXC__SM_Appointment_Window__c Where RecordType.Name = 'Time Window']) {
                timeSlotsMap.put(TW.SVMXC__SM_Window_Start_Time__c+TW.SVMXC__SM_Window_End_Time__c,TW.id);
            }
            
            String strInvalidTimeWindows = '';
            Set<String> timeSlotsSet = new Set<String>();
            timeSlotsSet = timeSlotsMap.keySet();
            for(SVMXC__SM_Appointment_Window__c TW : timeWindowsToSaveList) {
                TW.SVMXC__SM_Time_Window_Name__c = TW.name;
                
                //if the timewindow does not contain ':', append it. For example if user enters 9, make it 9:00
                if(!TW.SVMXC__SM_Window_Start_Time__c.contains(':')) {
                    TW.SVMXC__SM_Window_Start_Time__c = TW.SVMXC__SM_Window_Start_Time__c + ':00';
                }
                
                if(!TW.SVMXC__SM_Window_End_Time__c.contains(':')) {
                    TW.SVMXC__SM_Window_End_Time__c = TW.SVMXC__SM_Window_End_Time__c + ':00';
                }
                
                //below method validates if the timewindow is valid or not
                if(!WSCH_Provider_ECO_ManageTimeWindows.isTimeWindowValid(TW.SVMXC__SM_Window_Start_Time__c, TW.SVMXC__SM_Window_End_Time__c)) {
                    if(String.isEmpty(strInvalidTimeWindows)) {
                        strInvalidTimeWindows = strInvalidTimeWindows + TW.SVMXC__SM_Time_Window_Name__c;
                    } else {
                        strInvalidTimeWindows = strInvalidTimeWindows + ',' + TW.SVMXC__SM_Time_Window_Name__c;
                    }
                }
                system.debug('WSCH_Provider_ECO_ManageTimeWindows::isTimeWindowValid:strInvalidTimeWindows - ' + strInvalidTimeWindows);
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_ManageTimeWindows::isTimeWindowValid:strInvalidTimeWindows - ' + strInvalidTimeWindows);
                WSCH_AuditLogger.finish();
                
                if(timeSlotsSet.contains(TW.SVMXC__SM_Window_Start_Time__c+TW.SVMXC__SM_Window_End_Time__c)) {
                    if(TW.id == null) {
                        //put error and return
                        String errormsg = getTAG026();
                        String timeWindowName = TW.name;
                        errorMsg = errorMsg.replace('xxxxxxxx',timeWindowName);
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
                        return null;
                    }
                    if(timeSlotsMap.get(TW.SVMXC__SM_Window_Start_Time__c+TW.SVMXC__SM_Window_End_Time__c) == TW.id) {
                        continue;
                    } else {
                        //put error and return
                        String errormsg = getTAG026();
                        String timeWindowName = TW.name;
                        errorMsg = errorMsg.replace('xxxxxxxx',timeWindowName);
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
                        return null;
                    }
                }
            }
            
            if(String.isNotEmpty(strInvalidTimeWindows)) {
                String errorMsg = 'Following Time Windows have start time later than end time - ';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg + strInvalidTimeWindows));
                return null;
            }
                    
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(timeWindowsToSaveList, COMM_SecurityUtils.Access.Upsertable)){        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                Upsert timeWindowsToSaveList;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                return null;
            }
            PageReference pg = new PageReference('/apex/WSCH_Provider_ECO_ManageTimeWindows');
            pg.setRedirect(true);
            return pg;
        } catch(Exception e) {
            Database.rollback(sp);
            System.debug('*****Exception****'+e.getStackTraceString());
            System.debug('*****Exception****'+e.getMessage());
            String errorMsg = '';
            if (e.getMessage().contains('DUPLICATE_VALUE') && e.getMessage().contains('SVMXC__SM_Time_Window_Name__c')) {
                errorMsg = getTAG017();
                Integer failedRow = e.getDmlIndex(0);
                String timeWindowName = timeWindowsToSaveList[failedRow].name;
                errorMsg = errorMsg.replace('xxxxxxxx',timeWindowName);
            } else {
                errorMsg = e.getMessage();
            }
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
            return null;
        }
    }
    
    public void cancel() {
        displayEditPage = false;
        showAppointmentTypes = true;
        isDeleteWindow = false;
    }
    
    public void sortList() {
        String queryString = 'Select id,name,SVMXC__SM_Window_Start_Time__c,SVMXC__SM_Window_End_Time__c,SVMXC__SM_Time_Window_Name__c From SVMXC__SM_Appointment_Window__c Where RecordType.Name = \'Time Window\' ';
        String orderBy = '';
        
        if(sortType == 'Time Window Name - Ascending') {
            orderBy = 'Order By Name Asc';
        } else if (sortType == 'Time Window Name - Descending') {
            orderBy = 'Order By Name Desc';
        } else if(sortType == 'Start Time - Ascending') {
            orderBy = 'Order By SVMXC__SM_Window_Start_Time__c Asc';
        } else if (sortType == 'Start Time - Descending') {
            orderBy = 'Order By SVMXC__SM_Window_Start_Time__c Desc';
        } else if(sortType == 'End Time - Ascending') {
            orderBy = 'Order By SVMXC__SM_Window_End_Time__c Asc';
        } else if (sortType == 'End Time - Descending') {
            orderBy = 'Order By SVMXC__SM_Window_End_Time__c Desc';
        }
        
        queryString = queryString + orderBy;
        timeWindowList = new List<TimeWindowWrapper>();
        
        try{
            //timeWindowRecTypeId = Schema.SObjectType.SVMXC__SM_Appointment_Window__c.getRecordTypeInfosByName().get('Time Window').getRecordTypeId();
            //List<SVMXC__SM_Appointment_Window__c> timeWindows = 
            for(SVMXC__SM_Appointment_Window__c TW : Database.query(queryString)) {
                TimeWindowWrapper timeWindow = new TimeWindowWrapper();
                timeWindow.isSelected = false;
                timeWindow.timeWindow = TW;
                timeWindowList.add(timeWindow);
            }
        } catch(Exception e){
            System.debug('*****Exception****'+e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
        }
    }
    
    public class TimeWindowWrapper {
        public boolean isSelected{get;set;}
        public SVMXC__SM_Appointment_Window__c timeWindow{get;set;}
    }
    
    public static Boolean isTimeWindowValid(String startTime, String endTime) {
        Boolean isValid = true;
        Integer startTimeInMinutes, endTimeInMinutes;
        
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_ManageTimeWindows::isTimeWindowValid: startTime - ' + startTime);
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_ManageTimeWindows::isTimeWindowValid: endTime - ' + endTime);
        system.debug('WSCH_Provider_ECO_ManageTimeWindows::isTimeWindowValid: startTime - ' + startTime);
        system.debug('WSCH_Provider_ECO_ManageTimeWindows::isTimeWindowValid: endTime - ' + endTime);
        
        if(startTime.contains(':')) {       //11:15
            String[] startTimeSplit = startTime.split(':', -1);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_ManageTimeWindows::isTimeWindowValid: startTimeSplit - ' + startTimeSplit);
            system.debug('WSCH_Provider_ECO_ManageTimeWindows::isTimeWindowValid: startTimeSplit - ' + startTimeSplit);
            if(startTimeSplit.size() == 2) {        // {11, 15}
                if(String.isNotEmpty(startTimeSplit[0]) && String.isNotEmpty(startTimeSplit[1])) {
                    startTimeInMinutes = Integer.valueOf(startTimeSplit[0]) * 60 + Integer.valueOf(startTimeSplit[1]);  //converting the startTime from 11:15 to minutes 675
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_ManageTimeWindows::isTimeWindowValid: startTimeInMinutes - ' + startTimeInMinutes);
                    system.debug('WSCH_Provider_ECO_ManageTimeWindows::isTimeWindowValid: startTimeInMinutes - ' + startTimeInMinutes);
                }
            }
        }
        
        if(endTime.contains(':')) {         //09:15
            String[] endTimeSplit = endTime.split(':', -1);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_ManageTimeWindows::isTimeWindowValid: endTimeSplit - ' + endTimeSplit);
            system.debug('WSCH_Provider_ECO_ManageTimeWindows::isTimeWindowValid: endTimeSplit - ' + endTimeSplit);
            if(endTimeSplit.size() == 2) {
                if(String.isNotEmpty(endTimeSplit[0]) && String.isNotEmpty(endTimeSplit[1])) {
                    endTimeInMinutes =Integer.valueOf(endTimeSplit[0]) * 60 + Integer.valueOf(endTimeSplit[1]);     //converting the endTime from 09:15 to minutes 555
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_ManageTimeWindows::isTimeWindowValid: endTimeInMinutes - ' + endTimeInMinutes);
                    system.debug('WSCH_Provider_ECO_ManageTimeWindows::isTimeWindowValid: endTimeInMinutes - ' + endTimeInMinutes);
                }
            }
        }
        
        if(startTimeInMinutes >= endTimeInMinutes) {        //startTime is greater than endTime, hence it is invalid
            isValid = false;
        }
        return isValid;
    }
    
    public string getTAG001() {return system.label.OMAX004_TAG060;} //New Time Window
    public string getTAG002() {return system.label.OMAX004_TAG061;} //Edit Time Window
    public string getTAG003() {return system.label.OMAX004_TAG062;} //Delete Time Window
    public string getTAG004() {return system.label.OMAX004_TAG063;} //Back To Appointment Types
    public string getTAG005() {return system.label.OMAX004_TAG064;} //Time Windows
    public string getTAG006() {return system.label.OMAX004_TAG065;} //Select
    public string getTAG007() {return system.label.OMAX004_TAG066;} //Time Windaow Name
    public string getTAG008() {return system.label.OMAX004_TAG067;} //Start Time
    public string getTAG009() {return system.label.OMAX004_TAG068;} //End Time
    public string getTAG010() {return system.label.OMAX004_TAG069;} //Please select a Time Window to perform this operation
    public string getTAG011() {return system.label.OMAX004_TAG070;} //This Time Window is utilized by all of the Related Appointment Types listed at the bottom of the page. Deleting this time window will remove it from all of them. Be sure to not delete a time window that others are relying on. If you're unsure, it's always safer to leave the shared Time Window for now, and coordinate with the creator(s) of the other Related Appointment Types before deleting.
    public string getTAG012() {return system.label.OMAX004_TAG071;} //Save
    public string getTAG013() {return system.label.OMAX004_TAG072;} //Cancel
    public string getTAG014() {return system.label.OMAX004_TAG073;} //Actions
    public string getTAG015() {return system.label.OMAX004_TAG074;} //Remove
    public string getTAG016() {return system.label.OMAX004_TAG075;} //Add
    public string getTAG017() {return system.label.OMAX004_TAG076;} //Error: This Time Window already exists - (xxxxxxxx), please change the name of this new Time Window.
    public string getTAG018() {return system.label.OMAX004_TAG077;} //Please select only one Time Window to perform this operation
    public string getTAG019() {return system.label.OMAX004_TAG078;} //Related Appointment Types
    public string getTAG020() {return system.label.OMAX004_TAG079;} //Show Related Appointment Types
    public string getTAG021() {return system.label.OMAX004_TAG080;} //Appointment Type Name
    public string getTAG022() {return system.label.OMAX004_TAG081;} //Description
    public string getTAG023() {return system.label.OMAX004_TAG082;} //Delete
    public string getTAG024() {return system.label.OMAX004_TAG083;} //This Time Window is utilized by all of the Related Appointment Types listed at the bottom of the page. Any changes made to this Time Window will affect all of them. Be sure to not change a time window that others are relying on. If you're unsure, it's always safer to create a new time window for your purposes instead.
    public string getTAG025() {return system.label.OMAX004_TAG085;} //Sort By
    public string getTAG026() {return system.label.OMAX004_TAG086;} //This Time Window already exists (xxxxxxxx). Please change the start or end time of this new Time Window.
    public string getTAG027() {return system.label.OMAX004_TAG087;} //'Time Window Name - Ascending'
    public string getTAG028() {return system.label.OMAX004_TAG088;} //'Time Window Name - Descending'
    public string getTAG029() {return system.label.OMAX004_TAG089;} //'Start Time - Ascending'
    public string getTAG030() {return system.label.OMAX004_TAG090;} //'Start Time - Descending'
    public string getTAG031() {return system.label.OMAX004_TAG091;} //'End Time - Ascending'
    public string getTAG032() {return system.label.OMAX004_TAG092;} //'End Time - Descending'
}