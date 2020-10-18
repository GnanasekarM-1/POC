public with sharing class WSCH_Provider_ECO_AppointmentWindowSetup {
    
    public List<TimeWindowWrapper> timeWindowList{get;set;}
    public List<AppointmentTypeWrapper> appointmentTypeList{get;set;}
    
    public String appointmentTypeName{get;set;}
    public String appointmentTypeDescription{get;set;}
    
    public String selectedLookupId{get;set;}
    public String selectedLookupName{get;set;}
    
    public Integer rowNumber{get;set;}
    public Integer timeWindowListSize{get;set;}
    
    public Boolean isNewWindow{get;set;}
    public Boolean displayEditPage{get;set;}

    public List<SVMXC__SM_Appointment_Window__c> appointmentTypeDefinitionsToSaveList;
    public List<SVMXC__SM_Appointment_Window__c> appointmentTypeDefinitionsToSaveTempList;
    public List<SVMXC__SM_Appointment_Window__c> timeWindowsToSaveList;
    public List<SVMXC__SM_Appointment_Window__c> appointmentTypeDefinitionsToDeleteList;

    
    public Map<Id,SVMXC__SM_Appointment_Window__c> timeWindowMap;
    public Map<String,String> appointmentWindowRecordTypeNameToIdMap;
    public Map<String,SVMXC__SM_Appointment_Window__c> availableApptTypeDefToTimeWndwMap;

    SVMXC__SM_Appointment_Window__c selectedApptType;

    public Boolean isNewApptType;
    public Boolean isEditApptType;
    
    //Constructor
    public WSCH_Provider_ECO_AppointmentWindowSetup() {
        
        displayEditPage = false;
        isNewApptType = false;
        isEditApptType = false;

        //Fetch Available Appointment Types
        appointmentTypeList = new List<AppointmentTypeWrapper>();
        
        for(SVMXC__SM_Appointment_Window__c availableAppointmentType:[Select id,Name, SVMXC__SM_Appointment_Type_Description__c, SVMXC__SM_Appointment_Type_Name__c
                From SVMXC__SM_Appointment_Window__c Where RecordType.Name = 'Appointment Type']) {
            AppointmentTypeWrapper appointmentType = new AppointmentTypeWrapper();
            appointmentType.isSelected = false;
            appointmentType.appointmentType = availableAppointmentType;
            appointmentTypeList.add(appointmentType);
        }
        
        
        
        //Fetching all available Time Windows
        timeWindowMap = new Map<Id,SVMXC__SM_Appointment_Window__c>([Select id,RecordTypeId,SVMXC__SM_Window_Start_Time__c,SVMXC__SM_Window_End_Time__c,SVMXC__SM_Appointment_Type_Description__c From SVMXC__SM_Appointment_Window__c Where RecordType.Name = 'Time Window']);
        
        //get record type names and their ids
        appointmentWindowRecordTypeNameToIdMap = new Map<String,String>();
        for(RecordTypeInfo info: SVMXC__SM_Appointment_Window__c.SObjectType.getDescribe().getRecordTypeInfos()) {
            appointmentWindowRecordTypeNameToIdMap.put(info.getName(),info.getRecordTypeId());
        }
    }
    
    
    public void newAppointmentType() {
        displayEditPage = true;
        isNewApptType = true;
        isEditApptType = false;

        //Adding a default row with blank values for new Appointment Type
        timeWindowList = new List<TimeWindowWrapper>();
        TimeWindowWrapper timeWindow = new TimeWindowWrapper();
        timeWindow.isLookup = true;
        timeWindow.allowEdit = true;
        timeWindow.timeWindow = new SVMXC__SM_Appointment_Window__c();
        timeWindowList.add(timeWindow);
        timeWindowListSize = timeWindowList.size();
    
    }
    
    public PageReference editAppointmentType() {
        
        appointmentTypeDefinitionsToDeleteList = new List<SVMXC__SM_Appointment_Window__c>();
        //Check for multiple selection
        Integer selectedCount = 0;
        
        for(AppointmentTypeWrapper AT : AppointmentTypeList) {
            if (AT.isSelected) {
                selectedCount = selectedCount + 1;
                selectedApptType = AT.appointmentType;
            }
            if (selectedCount > 1) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTAG019()));
                return null;
            }
        }

        if (selectedCount == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTAG020()));
            return null;
        }

        displayEditPage = true;
        isNewApptType = false;
        isEditApptType = true;

        
        appointmentTypeName = selectedApptType.name;
        appointmentTypeDescription = selectedApptType.SVMXC__SM_Appointment_Type_Description__c;

        List<SVMXC__SM_Appointment_Window__c> availableAppointmentTypeDefinitionList = [Select Id, SVMXC__SM_Time_Window__c, SVMXC__SM_Time_Window__r.Name, 
                                                                                              SVMXC__SM_Time_Window__r.SVMXC__SM_Window_Start_Time__c, SVMXC__SM_Time_Window__r.SVMXC__SM_Window_End_Time__c
                                                                                       From SVMXC__SM_Appointment_Window__c Where SVMXC__SM_Appointment_Type__c =: SelectedApptType.Id and
                                                                                            RecordType.Name = 'Appointment Type Definition'];

        timeWindowList = new List<TimeWindowWrapper>();
        availableApptTypeDefToTimeWndwMap = new Map<String,SVMXC__SM_Appointment_Window__c>();

        for(SVMXC__SM_Appointment_Window__c ATD : AvailableAppointmentTypeDefinitionList) {
            availableApptTypeDefToTimeWndwMap.put(ATD.SVMXC__SM_Time_Window__c, ATD);
            TimeWindowWrapper AW = new TimeWindowWrapper();
            AW.isLookup = false;
            AW.allowEdit = false;
            AW.timeWindow = new SVMXC__SM_Appointment_Window__c();
            AW.timeWindow.SVMXC__SM_Time_Window__c = ATD.SVMXC__SM_Time_Window__c;
            AW.timeWindow.Name = ATD.SVMXC__SM_Time_Window__r.Name;
            AW.timeWindow.SVMXC__SM_Window_Start_Time__c = ATD.SVMXC__SM_Time_Window__r.SVMXC__SM_Window_Start_Time__c;
            AW.timeWindow.SVMXC__SM_Window_End_Time__c = ATD.SVMXC__SM_Time_Window__r.SVMXC__SM_Window_End_Time__c;
            
            timeWindowList.add(AW);
        }
        timeWindowListSize = timeWindowList.size();

        return null;
    }
    
    public PageReference deleteAppointmentType() {
        appointmentTypeDefinitionsToDeleteList = new List<SVMXC__SM_Appointment_Window__c>();

        //Check for multiple selection
        Integer selectedCount = 0;
        for(AppointmentTypeWrapper AT : AppointmentTypeList) {
            if (AT.IsSelected) {
                selectedCount = selectedCount + 1;
                selectedApptType = AT.appointmentType;
            }
            if (SelectedCount > 1) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTAG019()));
                return null;
            }
        }

        if (SelectedCount == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTAG020()));
            return null;
        }

        Savepoint sp = Database.setSavepoint();

        try {

            appointmentTypeDefinitionsToDeleteList = [Select Id From SVMXC__SM_Appointment_Window__c Where SVMXC__SM_Appointment_Type__c =: SelectedApptType.Id and
                                                                                            RecordType.Name = 'Appointment Type Definition'];

            if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SM_Appointment_Window__c')){      //SDL-SVMX-DELETE-FLS-ENFORCED
                Delete selectedApptType;
                if (appointmentTypeDefinitionsToDeleteList.size() > 0) {
                    Delete appointmentTypeDefinitionsToDeleteList;
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                return null;
            }
            PageReference pg = new PageReference('/apex/SVMXC__WSCH_Provider_ECO_AppointmentWindowSetup');
            pg.setRedirect(true);
            return pg;

        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('*****Exception****'+e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            return null;
        }
        
    
    }
    
    public PageReference backToSetup() {
         //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
        String url='';
        if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
            url = '/lightning/n/SVMXC__ServiceMax_Setup';
        }else{
            url ='/apex/SVMXC__CONF_SetupHome';
        }
        PageReference pg = new PageReference(url);
        pg.setRedirect(true);
        return pg;
    }
    
    //Action method for Save button
    public PageReference save() {
        
        timeWindowsToSaveList = new List<SVMXC__SM_Appointment_Window__c>();
        
        appointmentTypeDefinitionsToSaveList = new List<SVMXC__SM_Appointment_Window__c>();
        appointmentTypeDefinitionsToSaveTempList = new List<SVMXC__SM_Appointment_Window__c>();
        SVMXC__SM_Appointment_Window__c appointmentType = new SVMXC__SM_Appointment_Window__c();
        
        Map<String,String> timeSlotsMap = new Map<String,String>();
        for(SVMXC__SM_Appointment_Window__c TW : [Select id,name,SVMXC__SM_Window_Start_Time__c,SVMXC__SM_Window_End_Time__c,SVMXC__SM_Time_Window_Name__c From SVMXC__SM_Appointment_Window__c Where RecordType.Name = 'Time Window']) {
            timeSlotsMap.put(TW.SVMXC__SM_Window_Start_Time__c+TW.SVMXC__SM_Window_End_Time__c,TW.id);
        }
        
        Set<String> timeSlotsSet = new Set<String>();
        timeSlotsSet = timeSlotsMap.keySet();
        
        Savepoint sp = Database.setSavepoint();
        String strInvalidTimeWindows = '';

        if (IsNewApptType) { // Save New Appointment Type Logic


            appointmentType.Name = appointmentTypeName;
            appointmentType.SVMXC__SM_Appointment_Type_Name__c = appointmentTypeName;
            appointmentType.SVMXC__SM_Appointment_Type_Description__c = appointmentTypeDescription;
            appointmentType.RecordTypeId = appointmentWindowRecordTypeNameToIdMap.get('Appointment Type');
            
            
            try{
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(appointmentType, COMM_SecurityUtils.Access.Createable)){      //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    Insert appointmentType;
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                }
                for(TimeWindowWrapper AW : timeWindowList) {
                                
                    SVMXC__SM_Appointment_Window__c appointmentTypeDefinition = new SVMXC__SM_Appointment_Window__c();
                    SVMXC__SM_Appointment_Window__c timeWindow = new SVMXC__SM_Appointment_Window__c();
                    appointmentTypeDefinition.SVMXC__SM_Appointment_Type__c = appointmentType.id;
                    appointmentTypeDefinition.name = AppointmentType.Name + '-' + AW.TimeWindow.Name;
                    appointmentTypeDefinition.RecordTypeId = appointmentWindowRecordTypeNameToIdMap.get('Appointment Type Definition');
                    if(AW.isLookup) {
                        appointmentTypeDefinition.SVMXC__SM_Time_Window__c = AW.timeWindow.SVMXC__SM_Time_Window__c;
                        appointmentTypeDefinitionsToSaveList.add(appointmentTypeDefinition);
                    } else {
                        if(timeSlotsSet.contains(AW.timeWindow.SVMXC__SM_Window_Start_Time__c+AW.TimeWindow.SVMXC__SM_Window_End_Time__c)) {
                            String errormsg = getTAG026();
                            String timeWindowName = AW.timeWindow.name;
                            errorMsg = errorMsg.replace('xxxxxxxx',timeWindowName);
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
                            Database.rollback(sp);
                            return null;
                        }
                        timeWindow.name = AW.timeWindow.name;
                        timeWindow.SVMXC__SM_Time_Window_Name__c = AW.timeWindow.name;
                        timeWindow.SVMXC__SM_Window_Start_Time__c = AW.timeWindow.SVMXC__SM_Window_Start_Time__c;
                        timeWindow.SVMXC__SM_Window_End_Time__c = AW.TimeWindow.SVMXC__SM_Window_End_Time__c;
                        
                        //if the timewindow does not contain ':', append it. For example if user enters 9, make it 9:00
                        if(!timeWindow.SVMXC__SM_Window_Start_Time__c.contains(':')) {
                            timeWindow.SVMXC__SM_Window_Start_Time__c = timeWindow.SVMXC__SM_Window_Start_Time__c + ':00';
                        }
                        
                        if(!timeWindow.SVMXC__SM_Window_End_Time__c.contains(':')) {
                            timeWindow.SVMXC__SM_Window_End_Time__c = timeWindow.SVMXC__SM_Window_End_Time__c + ':00';
                        }
                        
                        //below method validates if the timewindow is valid or not
                        if(!WSCH_Provider_ECO_ManageTimeWindows.isTimeWindowValid(timeWindow.SVMXC__SM_Window_Start_Time__c, timeWindow.SVMXC__SM_Window_End_Time__c)) {
                            if(String.isEmpty(strInvalidTimeWindows)) {
                                strInvalidTimeWindows = strInvalidTimeWindows + timeWindow.SVMXC__SM_Time_Window_Name__c;
                            } else {
                                strInvalidTimeWindows = strInvalidTimeWindows + ',' + timeWindow.SVMXC__SM_Time_Window_Name__c;
                            }
                        }
                        system.debug('WSCH_Provider_ECO_ManageTimeWindows::isTimeWindowValid:strInvalidTimeWindows - ' + strInvalidTimeWindows);
                        WSCH_AuditLogger.debug('WSCH_Provider_ECO_ManageTimeWindows::isTimeWindowValid:strInvalidTimeWindows - ' + strInvalidTimeWindows);
                        WSCH_AuditLogger.finish();
                        
                        timeWindow.RecordTypeId = AppointmentWindowRecordTypeNameToIdMap.get('Time Window');
                        timeWindowsToSaveList.add(timeWindow);
                        appointmentTypeDefinitionsToSaveTempList.add(appointmentTypeDefinition);
                    }
                }
                
                if(String.isNotEmpty(strInvalidTimeWindows)) {
                    String errorMsg = 'Following Time Windows have start time later than end time - ';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg + strInvalidTimeWindows));
                    return null;
                }
                
                if(timeWindowsToSaveList.size() > 0){
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(timeWindowsToSaveList, COMM_SecurityUtils.Access.Createable)){        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        System.debug('Inserting TimeWindowsToSaveList :' +TimeWindowsToSaveList.size());
                        Insert timeWindowsToSaveList;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        return null;
                    }
                }
                
                if(appointmentTypeDefinitionsToSaveTempList.size() > 0){
                    for(integer i = 0;i < appointmentTypeDefinitionsToSaveTempList.size();i++) {
                        appointmentTypeDefinitionsToSaveTempList[i].SVMXC__SM_Time_Window__c = timeWindowsToSaveList[i].Id;
                    }
                    appointmentTypeDefinitionsToSaveList.addAll(appointmentTypeDefinitionsToSaveTempList);
                }
                
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(appointmentTypeDefinitionsToSaveList, COMM_SecurityUtils.Access.Createable)){     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    System.debug('Insert Appointment Type Definition '+appointmentTypeDefinitionsToSaveList.size());
                    Insert appointmentTypeDefinitionsToSaveList;
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    return null;
                }
                
                PageReference pg = new PageReference('/apex/SVMXC__WSCH_Provider_ECO_AppointmentWindowSetup');
                pg.setRedirect(true);
                return pg;
            } catch (DMLException e) {
                Database.rollback(sp);
                System.debug('*****Exception****'+e.getStackTraceString());
                System.debug('*****Exception****'+e.getMessage());
                String errorMsg = '';
                if(e.getMessage().contains('DUPLICATE_VALUE') && e.getMessage().contains('SVMXC__SM_Appointment_Type_Name__c')) {
                    errorMsg = getTAG022();
                } else if (e.getMessage().contains('DUPLICATE_VALUE') && e.getMessage().contains('SVMXC__SM_Time_Window_Name__c')) {
                    errorMsg = getTAG023();
                    Integer failedRow = e.getDmlIndex(0);
                    String timeWindowName = timeWindowsToSaveList[failedRow].name;
                    errorMsg = errorMsg.replace('xxxxxxxx',timeWindowName);
                } else {
                    errorMsg = e.getMessage();
                }
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
                return null;
            } catch (Exception e) {
                Database.rollback(sp);
                System.debug('*****Exception****'+e.getStackTraceString());
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
                return null;
            }
        } else if (IsEditApptType) {  // Update Appointment Type logic

            selectedApptType.Name = appointmentTypeName;
            selectedApptType.SVMXC__SM_Appointment_Type_Name__c = appointmentTypeName;
            selectedApptType.SVMXC__SM_Appointment_Type_Description__c = appointmentTypeDescription;
              
            //AppointmentType.Id = SelectedApptType.Id;

            try {
                
                for(TimeWindowWrapper AW : TimeWindowList) {
                    
                    SVMXC__SM_Appointment_Window__c appointmentTypeDefinition = new SVMXC__SM_Appointment_Window__c();
                    SVMXC__SM_Appointment_Window__c timeWindow = new SVMXC__SM_Appointment_Window__c();
                    appointmentTypeDefinition.SVMXC__SM_Appointment_Type__c = selectedApptType.id;
                    appointmentTypeDefinition.Name = SelectedApptType.Name + '-' + AW.timeWindow.name;
                    appointmentTypeDefinition.RecordTypeId = appointmentWindowRecordTypeNameToIdMap.get('Appointment Type Definition');

                    if (AW.allowEdit) {
                        if (AW.isLookup) {
                            appointmentTypeDefinition.SVMXC__SM_Time_Window__c = AW.timeWindow.SVMXC__SM_Time_Window__c;
                            appointmentTypeDefinitionsToSaveList.add(appointmentTypeDefinition);
                        } else {
                            if(timeSlotsSet.contains(AW.timeWindow.SVMXC__SM_Window_Start_Time__c+AW.TimeWindow.SVMXC__SM_Window_End_Time__c)) {
                                String errormsg = getTAG026();
                                String timeWindowName = AW.timeWindow.name;
                                errorMsg = errorMsg.replace('xxxxxxxx',timeWindowName);
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
                                Database.rollback(sp);
                                return null;
                            }
                            timeWindow.name = AW.timeWindow.name;
                            timeWindow.SVMXC__SM_Time_Window_Name__c = AW.timeWindow.name;
                            timeWindow.SVMXC__SM_Window_Start_Time__c = AW.timeWindow.SVMXC__SM_Window_Start_Time__c;
                            timeWindow.SVMXC__SM_Window_End_Time__c = AW.timeWindow.SVMXC__SM_Window_End_Time__c;
                            
                            //if the timewindow does not contain ':', append it. For example if user enters 9, make it 9:00
                            if(!timeWindow.SVMXC__SM_Window_Start_Time__c.contains(':')) {
                                timeWindow.SVMXC__SM_Window_Start_Time__c = timeWindow.SVMXC__SM_Window_Start_Time__c + ':00';
                            }
                            
                            if(!timeWindow.SVMXC__SM_Window_End_Time__c.contains(':')) {
                                timeWindow.SVMXC__SM_Window_End_Time__c = timeWindow.SVMXC__SM_Window_End_Time__c + ':00';
                            }
                            
                            //below method validates if the timewindow is valid or not
                            if(!WSCH_Provider_ECO_ManageTimeWindows.isTimeWindowValid(timeWindow.SVMXC__SM_Window_Start_Time__c, timeWindow.SVMXC__SM_Window_End_Time__c)) {
                                if(String.isEmpty(strInvalidTimeWindows)) {
                                    strInvalidTimeWindows = strInvalidTimeWindows + timeWindow.SVMXC__SM_Time_Window_Name__c;
                                } else {
                                    strInvalidTimeWindows = strInvalidTimeWindows + ',' + timeWindow.SVMXC__SM_Time_Window_Name__c;
                                }
                            }
                            system.debug('WSCH_Provider_ECO_ManageTimeWindows::isTimeWindowValid:strInvalidTimeWindows - ' + strInvalidTimeWindows);
                            WSCH_AuditLogger.debug('WSCH_Provider_ECO_ManageTimeWindows::isTimeWindowValid:strInvalidTimeWindows - ' + strInvalidTimeWindows);
                            WSCH_AuditLogger.finish();
                            
                            timeWindow.RecordTypeId = appointmentWindowRecordTypeNameToIdMap.get('Time Window');
                            timeWindowsToSaveList.add(timeWindow);
                            appointmentTypeDefinitionsToSaveTempList.add(appointmentTypeDefinition);
                        }
                    } 
                }
                
                if(String.isNotEmpty(strInvalidTimeWindows)) {
                    String errorMsg = 'Following Time Windows have start time later than end time - ';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg + strInvalidTimeWindows));
                    return null;
                }

                if(TimeWindowsToSaveList.size() > 0){
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(timeWindowsToSaveList, COMM_SecurityUtils.Access.Createable)){        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        System.debug('Inserting TimeWindowsToSaveList :' +timeWindowsToSaveList.size());
                        Insert timeWindowsToSaveList;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        return null;
                    }
                }
                
                if(appointmentTypeDefinitionsToSaveTempList.size() > 0){
                    for(integer i = 0;i < appointmentTypeDefinitionsToSaveTempList.size();i++) {
                        appointmentTypeDefinitionsToSaveTempList[i].SVMXC__SM_Time_Window__c = timeWindowsToSaveList[i].Id;
                    }
                    appointmentTypeDefinitionsToSaveList.addAll(AppointmentTypeDefinitionsToSaveTempList);
                }

                if(appointmentTypeDefinitionsToDeleteList.size() > 0) {
                    if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SM_Appointment_Window__c')){      //SDL-SVMX-DELETE-FLS-ENFORCED
                        Delete appointmentTypeDefinitionsToDeleteList;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        return null;
                    }
                }
                
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(appointmentTypeDefinitionsToSaveList, COMM_SecurityUtils.Access.Createable)){ //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    System.debug('Insert Appointment Type Definition '+appointmentTypeDefinitionsToSaveList.size());
                    Insert appointmentTypeDefinitionsToSaveList;
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    return null;
                }

                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(selectedApptType, COMM_SecurityUtils.Access.Updateable)){     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    
                    Update selectedApptType;
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    return null;
                }
                
                PageReference pg = new PageReference('/apex/SVMXC__WSCH_Provider_ECO_AppointmentWindowSetup');
                pg.setRedirect(true);
                return pg;

            } catch (DMLException e) {
                Database.rollback(sp);
                System.debug('*****Exception****'+e.getStackTraceString());
                System.debug('*****Exception****'+e.getMessage());
                String errorMsg = '';
                if(e.getMessage().contains('DUPLICATE_VALUE') && e.getMessage().contains('SVMXC__SM_Appointment_Type_Name__c')) {
                    errorMsg = getTAG022();
                } else if (e.getMessage().contains('DUPLICATE_VALUE') && e.getMessage().contains('SVMXC__SM_Time_Window_Name__c')) {
                    errorMsg = getTAG023();
                    Integer failedRow = e.getDmlIndex(0);
                    String timeWindowName = timeWindowsToSaveList[failedRow].name;
                    errorMsg = errorMsg.replace('xxxxxxxx',timeWindowName);
                } else {
                    errorMsg = e.getMessage();
                }
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
                return null;
            } catch (Exception e) {
                Database.rollback(sp);
                System.debug('*****Exception****'+e.getStackTraceString());
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
                return null;
            }

        }
        return null;
    }

    
    public PageReference cancel() {
        displayEditPage = false;
        isNewApptType = false;
        isEditApptType = false;
        appointmentTypeName = '';
        appointmentTypeDescription = '';
        return null;
    }
    
    
    public void addTimeWindows() {
        TimeWindowWrapper timeWindow = new TimeWindowWrapper();
        if(!isNewWindow){
            timeWindow.isLookup = true;
        } else {
            timeWindow.isLookup = false;
        }
        timeWindow.allowEdit = true;
        timeWindow.timeWindow = new SVMXC__SM_Appointment_Window__c();
        timeWindowList.add(timeWindow);
        timeWindowListSize = timeWindowList.size();
    }
    
    //Method to remove rows of Time Windows
    public void removeTimeWindows() {
        if(isEditApptType){
            
            String timeWindowId = timeWindowList[rowNumber].timeWindow.SVMXC__SM_Time_Window__c;
            System.debug('*****AvailableApptTypeDefToArvlWndwMap*****'+availableApptTypeDefToTimeWndwMap);
            System.debug('*****TimeWindowId*****'+timeWindowId);
            if(timeWindowId != null){
                appointmentTypeDefinitionsToDeleteList.add(availableApptTypeDefToTimeWndwMap.get(timeWindowId));
            }
            System.debug('*****AppointmentTypeDefinitionsToDeleteList*****'+appointmentTypeDefinitionsToDeleteList);
        }
        
        
        timeWindowList.remove(rowNumber);
        timeWindowListSize = timeWindowList.size();
    }
    
   
    
    public PageReference fetchTimeWindowData() {
        try {
            System.debug('In fetch');
            String startTime = timeWindowMap.get(selectedLookupId).SVMXC__SM_Window_Start_Time__c;
            String endTime = timeWindowMap.get(selectedLookupId).SVMXC__SM_Window_End_Time__c;
            String description = timeWindowMap.get(selectedLookupId).SVMXC__SM_Appointment_Type_Description__c;
            String recordTypeId = timeWindowMap.get(selectedLookupId).RecordTypeId;
            
            timeWindowList[rowNumber].timeWindow.SVMXC__SM_Time_Window__c = selectedLookupId;
            timeWindowList[rowNumber].timeWindow.Name = selectedLookupName;
            timeWindowList[rowNumber].timeWindow.SVMXC__SM_Window_Start_Time__c = startTime;
            timeWindowList[rowNumber].timeWindow.SVMXC__SM_Window_End_Time__c = endTime;
            timeWindowList[rowNumber].timeWindow.SVMXC__SM_Appointment_Type_Description__c = description;
            timeWindowList[rowNumber].timeWindow.RecordTypeId = recordTypeId;
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
        }
            
        
        return null;
    }
    
    public PageReference mangeTimeWIndows() {
        PageReference pg = new PageReference('/apex/SVMXC__WSCH_Provider_ECO_ManageTimeWindows');
        pg.setRedirect(true);
        return pg;
    }
    
    public class AppointmentTypeWrapper {
        public boolean isSelected{get;set;}
        public SVMXC__SM_Appointment_Window__c appointmentType{get;set;}
    }
    
    public class TimeWindowWrapper {
        public boolean isLookup{get;set;}
        public boolean allowEdit{get;set;}
        public SVMXC__SM_Appointment_Window__c timeWindow{get;set;}
    }
    
    
    //Getter methods for custom labels.
    public string getTAG001() {return system.label.OMAX004_TAG001;} //New Appointment Type
    public string getTAG002() {return system.label.OMAX004_TAG002;} //Edit Appointment Type
    public string getTAG003() {return system.label.OMAX004_TAG003;} //Delete Appointment Type
    public string getTAG004() {return system.label.OMAX004_TAG004;} //Back To Setup Home
    public string getTAG005() {return system.label.OMAX004_TAG005;} //Select
    public string getTAG006() {return system.label.OMAX004_TAG006;} //Appointment Type Name
    public string getTAG007() {return system.label.OMAX004_TAG007;} //Description
    public string getTAG008() {return system.label.OMAX004_TAG008;} //Save
    public string getTAG009() {return system.label.OMAX004_TAG009;} //Cancel
    public string getTAG010() {return system.label.OMAX004_TAG010;} //Appointment Type Details
    public string getTAG011() {return system.label.OMAX004_TAG011;} //Time Windows
    public string getTAG012() {return system.label.OMAX004_TAG012;} //Time Window Name
    public string getTAG013() {return system.label.OMAX004_TAG013;} //Start Time
    public string getTAG014() {return system.label.OMAX004_TAG014;} //End Time
    public string getTAG015() {return system.label.OMAX004_TAG015;} //Actions
    public string getTAG016() {return system.label.OMAX004_TAG016;} //Remove
    public string getTAG017() {return system.label.OMAX004_TAG017;} //Add New
    public string getTAG018() {return system.label.OMAX004_TAG018;} //Add Existing
    public string getTAG019() {return system.label.OMAX004_TAG019;} //Please select only one Appointment Type to perform this operation
    public string getTAG020() {return system.label.OMAX004_TAG020;} //Please select an Appointment Type to perform this operation
    public string getTAG021() {return system.label.OMAX004_TAG049;} //Appointment Type Name
    public string getTAG022() {return system.label.OMAX004_TAG052;} //Error: This Appointment type is a duplicate, please cancel to edit the existing record, or change the name of this record if you wish to create a new Appointment Type.
    public string getTAG023() {return system.label.OMAX004_TAG053;} // Error: This Time Window already exists. Please either use the add existing button and associate (xxxxxxxx), or change the name of this new Time Window.
    public string getTAG024() {return system.label.OMAX004_TAG058;} //Appointment Types
    public string getTAG025() {return system.label.OMAX004_TAG059;} //Manage Time Windows
    public string getTAG026() {return system.label.OMAX004_TAG086;} //This Time Window already exists (xxxxxxxx). Please change the start or end time of this new Time Window.
}