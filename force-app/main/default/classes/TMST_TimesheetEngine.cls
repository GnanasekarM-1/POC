/*****************************************************************************
*                       Copyright (C) 2015 ServiceMax, Inc
*                               All rights reserved
*
*****************************************************************************/

/**
* The TMST_TimesheetEngine implements methods to perform create Timesheet Header and Time sheet Entries
* for the Users assigned to the Configutaion process passed. 
* Global variables values i.e setProcessIds, timeSheetRecordType, mapTSProcessScheduler are assigned from SCON_Schedule class 
* method executeTimesheetEngine
* Internally, the Timesheet configurations will be saved 
* in ServiceMax_Processes__c object and scheduler & profile association details are 
* saved ServiceMax_Config_Data__c object.
*
* @author Anchal Sharma
* @version 15.39100
* @since 2015
*/
/*****************************************************************************
*    ID        Name                   Date            Comment
*****************************************************************************
*              Anchal Sharma        18 Jan 2015        Created. 
*              Sourabh Singh        09 Dec 2016        Updated (BAC-1276). Added logic to create Timesheet autofill 
time entries for past time periods 
*              Soumyaranjan Pati   1st Feb 2019         Fixed defect BAC-4543/044977 
*              Jaysukh Patel       6th March 2019       Fixed defect 044981 
*              Soumyaranjan Pati   21st March 2019      Fixed defect BAC-4543/044977 
*           Soumyaranjan Pati       11th Aprl 2019      Fixed BAC-4814/044977
*           Soumyaranjan Pati       16th Aprl 2019      Fixed defect-  045467
*           Soumyaranjan Pati       22nd May 2019       BAC-4865
*           Soumyaranjan Pati       16th Sept 2019      Code changes for BAC-5189
*           Soumyaranjan Pati       26th Dec 2019       BAC-5388
*****************************************************************************/

global with sharing class TMST_TimesheetEngine implements Database.Batchable<sObject>,Database.Stateful{
    
    global Set<String> setProcessIds = new Set<String>();
    global String timeSheetRecordType ; 
    global Map<Id, SVMXC__ServiceMax_Config_Data__c> mapTSProcessScheduler = new Map<Id, SVMXC__ServiceMax_Config_Data__c>();
    
    public DateTime dateTimeStart = null;
    Map<Id, SVMXC__ServiceMax_Processes__c> timeSheetProcess = new Map<Id, SVMXC__ServiceMax_Processes__c>(); 
    //Map <Id, Id> mapUserandTMProcess = new Map <Id, Id>();       // Map User and TimeSheet Configuration Process BAC-4814/044977
    List<SVMXC__Timesheet__c> updateInvalidTimesheetHeaders = new List<SVMXC__Timesheet__c>();
    //Map<Id, Id> mapUserTimesheetHeaderRec = new Map<Id, Id>();
    Map<Id, SVMXC__Timesheet__c> maptimesheetHeaderId = new Map<Id, SVMXC__Timesheet__c>();
    
    //(BAC-1276):Sourabh:9Dec2016:Added 5 new variables as below
    Map<Id, List<Id>> mapUserTimesheetHeaders = new Map<Id, List<Id>>(); // (user id, List TS header Ids)
    Map<Id, List<SVMXC__Service_Order_Line__c>> mapTSHdrWOLines = new Map<Id, List<SVMXC__Service_Order_Line__c>>(); //TS Header id, Corrosp WO lines
    Map<Id, List<SVMXC__SVMX_Event__c>> mapTSHdrSEvtLines = new Map<Id, List<SVMXC__SVMX_Event__c>>(); //TS Header id, Corrosp SVMX Event lines
    Map<Id, List<Event>> mapTSHdrEvtLines = new Map<Id, List<Event>>(); //TS Header id, Corrosp Event lines
    Map<Id, List<Task>> mapTSHdrTskLines = new Map<Id, List<Task>>(); //TS Header id, Corrosp Task lines   
    
    Map <Id, Map<String, Id>> mapProcessObjectMapping = new Map <Id, Map<String, Id>>();
    Map<Id, List<SVMXC__Timesheet_Day_Entry__c>> mapTimesheetHeaderandTimesheetDayEntry = new Map<Id, List<SVMXC__Timesheet_Day_Entry__c>>();
    Map<Id, List<SVMXC__Timesheet_Entry__c>> mapTimesheetHeaderEntries = new Map<Id, List<SVMXC__Timesheet_Entry__c>>();
    Map <Id, List<SVMXC__Timesheet__c>> mapUserIDTimesheetHeader = new Map <Id, List<SVMXC__Timesheet__c>>();
    String emailBody = '';
    Map <Id, List<User>> mapProcessUsers = new  Map <Id, List<User>>();
    Map<Id, UserAutofillInfo> mapUserIDUserAutofillInfo = new  Map<Id, UserAutofillInfo>();
    Map<Id, SVMXC__Timesheet_Day_Entry__c> mapUpdateDailySummaryTotalHours = new Map<Id, SVMXC__Timesheet_Day_Entry__c>();
    Map<Id, SVMXC__Service_Group_Members__c> mapUserTechnician = new Map<Id, SVMXC__Service_Group_Members__c>();
    Map<Id, BusinessHoursInfo> mapBusinesshoursIdValues = new Map<Id, BusinessHoursInfo>();
    Map<ID, ID> mapTimesheetProfileandProcess = new Map<ID, ID>(); // BAC-4814/044977
    Map<ID, ID> mapTimesheetConfigProfileandSFProfile = new Map<ID, ID>(); // BAC-4814/044977
    List<Holiday> listOfAllDayHoliday = new List<Holiday>();
    
    List<Holiday> lstOfPartialHoliday = new List<Holiday>();
    BusinessHours defaultBusinessHours; 
    Date Startdate; 
    Date Enddate; 
    List<String> listErrorDetails = new List<String>(); //BAC-4865
    Map<Id,UserTimezoneInfo> mapRecordsWithTimezone = new Map<Id,UserTimezoneInfo>(); //Added for story BAC-5388
    String woBusinessHour = 'WO Business Hours'; //Added for story BAC-5388
    
    /*
    Start method is all about getting List of Users for Timesheet Configuration Passed. 
    For timeSheetRecordType = TimesheetAutofill, we need all the object mappings, expressions based on which autofill of records need to happen ; 
    We are defining the batch scope for User. Therefore, list of users will be passed to execute method.
    */
    global Iterable<sObject> start(Database.BatchableContext TSEngine){
        
        try {
            //List<String> listOfSalesforceProfile = new List<String>();// Added for BAC-5189 // Commented for BAC-5314
            Map<String,SVMXC__ServiceMax_Config_Data__c> listOfSalesforceProfile = new Map<String,SVMXC__ServiceMax_Config_Data__c>();// Added for BAC-5314
            List<SVMXC__ServiceMax_Config_Data__c> listOfTimesheetAccessConfigData = new List<SVMXC__ServiceMax_Config_Data__c> (); //Added for BAC-5314
            List<User> listUser = new List<User> (); //Added for BAC-4866
            Startdate = System.today();
            if(dateTimeStart == null)
                dateTimeStart = System.now();
            //Map<ID, ID> mapTimesheetProfileandProcess = new Map<ID, ID>(); //BAC-4814/044977
            Map<Id, Map<String, String>> mapProcessExpressions = new Map<Id, Map<String, String>>();
            List<Id> listBusinesshoursId = new List<Id>();
            //Added SVMXC__SM_Scope__c to SOQL for BAC-5189
            //Added SVMXC__SM_Business_Hour_Source__c for BAC-5388
            for(SVMXC__ServiceMax_Processes__c svmxTimesheet : [SELECT SVMXC__SM_Business_Hour_Source__c, SVMXC__Process__c, SVMXC__Allow_Override__c,Name,
                                                                SVMXC__Parent_Object__c, SVMXC__Parent_Object__r.RecordType.Name,SVMXC__Parent_Object__r.SVMXC__Source_Object_Name__c,
                                                                SVMXC__Node_Parent__c, SVMXC__Node_Parent__r.RecordType.Name,SVMXC__Node_Parent__r.SVMXC__Source_Object_Name__c,
                                                                SVMXC__Module__c, SVMXC__Module__r.RecordType.Name, SVMXC__Module__r.SVMXC__Source_Object_Name__c,
                                                                SVMXC__Submodule__c, SVMXC__Submodule__r.RecordType.Name, SVMXC__Submodule__r.SVMXC__Source_Object_Name__c,
                                                                SVMXC__Process1__c, SVMXC__Process1__r.RecordType.Name, SVMXC__Process1__r.SVMXC__Source_Object_Name__c,
                                                                SVMXC__Process2__c, SVMXC__Process2__r.RecordType.Name, SVMXC__Process2__r.SVMXC__Source_Object_Name__c,
                                                                SVMXC__Process3__c, SVMXC__Process3__r.RecordType.Name, SVMXC__Process3__r.SVMXC__Source_Object_Name__c,
                                                                SVMXC__Email_On_Success__c, SVMXC__ProcessID__c, SVMXC__Field_Name__c, SVMXC__Business_Hours__c,
                                                                SVMXC__Notify_Technician__c,SVMXC__Email_On_Error__c, SVMXC__End_Date__c, SVMXC__Start_Date__c,
                                                                SVMXC__Event_Type__c, SVMXC__Business_Hours__r.IsActive, 
                                                                (SELECT SVMXC__Access_Configuration_Profile__c, 
                                                                 SVMXC__Access_Configuration_Profile__r.Id,
                                                                 SVMXC__Dispatch_Process__c, SVMXC__SM_Scope__c  
                                                                 FROM  SVMXC__ServiceMax_Config_Data__r  
                                                                 WHERE RecordType.Name = 'Timesheet Access')
                                                                FROM SVMXC__ServiceMax_Processes__c 
                                                                WHERE RecordType.Name = 'Timesheet' AND SVMXC__Active__c = true AND ID IN :setProcessIds]){
                                                                    
                                                                    
                                                                    for(SVMXC__ServiceMax_Config_Data__c configData: svmxTimesheet.SVMXC__ServiceMax_Config_Data__r){
                                                                        mapTimesheetProfileandProcess.put(configData.SVMXC__Access_Configuration_Profile__r.Id, svmxTimesheet.ID);
                                                                        if(configData.SVMXC__SM_Scope__c != null) //Added for BAC-5189
                                                                                listOfSalesforceProfile.put(configData.SVMXC__SM_Scope__c, configData);
                                                                    }
                                                                    timeSheetProcess.put(svmxTimesheet.id, svmxTimesheet);
                                                                    // Anchal 28 March, Defect 028734 fix
                                                                    if(svmxTimesheet.SVMXC__Business_Hours__r.IsActive){
                                                                        listBusinesshoursId.add(svmxTimesheet.SVMXC__Business_Hours__c);
                                                                    }
                                                                }
            
            System.debug(LoggingLevel.WARN, 'List of Prcoesses with record type Timesheet :' + timeSheetProcess);
            if(timeSheetProcess != null && timeSheetProcess.size()> 0){
                List<SVMXC__ServiceMax_Config_Data__c> listOfConfigrationAccess = [SELECT SVMXC__Profile__c, SVMXC__Access_Configuration_Profile__c 
                                                                                   FROM SVMXC__ServiceMax_Config_Data__c
                                                                                   WHERE RecordType.Name = 'Configuration Access' AND SVMXC__Access_Configuration_Profile__c IN :mapTimesheetProfileandProcess.keyset()];                                                                            
                
                List<Id> listProfileID = new List <ID> (); 
                              
                for (SVMXC__ServiceMax_Config_Data__c configAccessrec: listOfConfigrationAccess){
                    //listProfileID.add(configAccessrec.SVMXC__Profile__c); // Commented for BAC-5189
                    mapTimesheetConfigProfileandSFProfile.put(configAccessrec.SVMXC__Profile__c, configAccessrec.SVMXC__Access_Configuration_Profile__c);
                    if(Test.isRunningTest()){ //Added for BAC-5189
                        listProfileID.add(configAccessrec.SVMXC__Profile__c); 
                    }
                }
                //Added for Added for BAC-5189
                for(String sfdcIds : listOfSalesforceProfile.keySet()){
                    try{
                        SVMXC.TMST_WrapperDef.SalesforceProfileInfo tsWrap = new SVMXC.TMST_WrapperDef.SalesforceProfileInfo();
                        tsWrap = (SVMXC.TMST_WrapperDef.SalesforceProfileInfo) JSON.deserialize(sfdcIds, SVMXC.TMST_WrapperDef.SalesforceProfileInfo.class);
                        List<SVMXC.TMST_WrapperDef.ObjectInfo> salesforceProfileIdsTemp = new List<SVMXC.TMST_WrapperDef.ObjectInfo>(); //Added for BAC-5314
                        for(SVMXC.TMST_WrapperDef.ObjectInfo objectInfoVar: tsWrap.salesforceProfileIds){
                            if(mapTimesheetConfigProfileandSFProfile.containsKey(objectInfoVar.Id)){ // Added for BAC-5313
                                listProfileID.add(Id.valueOf(objectInfoVar.Id));
                                salesforceProfileIdsTemp.add(objectInfoVar); //Added for BAC-5314
                            }
                        }
                    //Added for BAC-5314
                    if(salesforceProfileIdsTemp.size() != tsWrap.salesforceProfileIds.size()){
                        SVMXC.TMST_WrapperDef.SalesforceProfileInfo tsWrapTemp = new SVMXC.TMST_WrapperDef.SalesforceProfileInfo();
                        tsWrapTemp.salesforceProfileIds = salesforceProfileIdsTemp;
                        SVMXC__ServiceMax_Config_Data__c configDataTemp = listOfSalesforceProfile.get(sfdcIds);
                        configDataTemp.SVMXC__SM_Scope__c = JSON.serialize(tsWrapTemp);
                        listOfTimesheetAccessConfigData.add(configDataTemp);

                    }
                    //End for BAC-5314
                    }catch(Exception e){
                        System.debug('Exception '+e);
                    }
                }               
                if(listOfTimesheetAccessConfigData.size() > 0){
                    upsert listOfTimesheetAccessConfigData;
                }
                //End for Added for BAC-5189  
                listUser = [SELECT Id, ProfileId , User.FirstName, Email, User.LastName
                            FROM User
                            WHERE ProfileId IN :listProfileID  AND isActive = true];
                
                // Find technicians for the users
                for(SVMXC__Service_Group_Members__c listTechnicians : [Select Id, SVMXC__Working_Hours__c, SVMXC__Salesforce_User__c, SVMXC__Working_Hours__r.isActive
                                                                       FROM SVMXC__Service_Group_Members__c
                                                                       WHERE SVMXC__Salesforce_User__c IN:listUser AND SVMXC__Active__c = true]){
                                                                           
                                                                           mapUserTechnician.put(listTechnicians.SVMXC__Salesforce_User__c, listTechnicians);  
                                                                           if(listTechnicians.SVMXC__Working_Hours__r.isActive){
                                                                               listBusinesshoursId.add(listTechnicians.SVMXC__Working_Hours__c);
                                                                           }
                                                                       }
                
                defaultBusinessHours = [Select Id from BusinessHours WHERE isDefault = true];
                listBusinesshoursId.add(defaultBusinessHours.Id);
                // List of BusinessHours can never be null
                for(BusinessHours businessHourRec: [Select FridayEndTime, FridayStartTime, Id, IsActive, MondayEndTime, MondayStartTime,
                                                    Name, SaturdayEndTime, SaturdayStartTime, SundayEndTime, SundayStartTime,
                                                    ThursdayEndTime, ThursdayStartTime, TimeZoneSidKey, TuesdayEndTime, TuesdayStartTime,
                                                    WednesdayEndTime,WednesdayStartTime FROM BusinessHours WHERE ID IN :listBusinesshoursId]){
                                                        BusinessHoursInfo calculateBusinessHours = new BusinessHoursInfo();
                                                        calculateBusinessHours.BusinessHoursId = businessHourRec.Id;
                                                        calculateBusinessHours.mapDayToWorkingHours = new Map <String, Decimal>();
                                                        calculateBusinessHours.mapDayToStartEndTime = new Map<String, Map <String, Time>>();
                                                        calculateBusinessHours.businessHourRecDetail = businessHourRec;
                                                        // Monday Calculation
                                                        Decimal MondayWorkingHours = 0; 
                                                        if(businessHourRec.MondayStartTime != null && businessHourRec.MondayEndTime != null){
                                                            MondayWorkingHours = (businessHourRec.MondayEndTime.hour() - businessHourRec.MondayStartTime.hour()) + Decimal.valueOf(businessHourRec.MondayEndTime.minute() - businessHourRec.MondayStartTime.minute()).divide(60,2);
                                                            if(!(MondayWorkingHours > 0))
                                                                MondayWorkingHours = 24; 
                                                        }
                                                        
                                                        
                                                        calculateBusinessHours.mapDayToWorkingHours.put('Monday', MondayWorkingHours);
                                                        calculateBusinessHours.mapDayToStartEndTime.put('Monday', new Map<String, Time>{'startTime' => businessHourRec.MondayStartTime, 'endTime' => businessHourRec.MondayEndTime});
                                                        
                                                        // Tuesday Calculation
                                                        Decimal TuesdayWorkingHours = 0; 
                                                        if(businessHourRec.TuesdayStartTime != null && businessHourRec.TuesdayEndTime != null){
                                                            TuesdayWorkingHours = (businessHourRec.TuesdayEndTime.hour() - businessHourRec.TuesdayStartTime.hour()) + Decimal.valueOf(businessHourRec.TuesdayEndTime.minute() - businessHourRec.TuesdayStartTime.minute()).divide(60,2);
                                                            if(!(TuesdayWorkingHours > 0))
                                                                TuesdayWorkingHours = 24; 
                                                        }
                                                        
                                                        calculateBusinessHours.mapDayToWorkingHours.put('Tuesday', TuesdayWorkingHours);
                                                        calculateBusinessHours.mapDayToStartEndTime.put('Tuesday', new Map<String, Time>{'startTime' => businessHourRec.TuesdayStartTime, 'endTime' => businessHourRec.TuesdayEndTime});
                                                        
                                                        // Wednesday Calculation
                                                        Decimal WednesdayWorkingHours = 0; 
                                                        if(businessHourRec.WednesdayStartTime != null && businessHourRec.WednesdayEndTime != null){
                                                            WednesdayWorkingHours = (businessHourRec.WednesdayEndTime.hour() - businessHourRec.WednesdayStartTime.hour()) + Decimal.valueOf(businessHourRec.WednesdayEndTime.minute() - businessHourRec.WednesdayStartTime.minute()).divide(60,2);
                                                            if(!(WednesdayWorkingHours > 0))
                                                                WednesdayWorkingHours = 24;
                                                        }
                                                        
                                                        
                                                        calculateBusinessHours.mapDayToWorkingHours.put('Wednesday', WednesdayWorkingHours);
                                                        calculateBusinessHours.mapDayToStartEndTime.put('Wednesday', new Map<String, Time>{'startTime' => businessHourRec.WednesdayStartTime, 'endTime' => businessHourRec.WednesdayEndTime});
                                                        
                                                        // Thrusday Calculation
                                                        Decimal ThursdayWorkingHours = 0; 
                                                        if(businessHourRec.ThursdayStartTime != null && businessHourRec.ThursdayEndTime != null){
                                                            ThursdayWorkingHours = (businessHourRec.ThursdayEndTime.hour() - businessHourRec.ThursdayStartTime.hour()) + Decimal.valueOf(businessHourRec.ThursdayEndTime.minute() - businessHourRec.ThursdayStartTime.minute()).divide(60,2);
                                                            if(!(ThursdayWorkingHours > 0))
                                                                ThursdayWorkingHours = 24;
                                                        }
                                                        
                                                        
                                                        calculateBusinessHours.mapDayToWorkingHours.put('Thursday', ThursdayWorkingHours);
                                                        calculateBusinessHours.mapDayToStartEndTime.put('Thursday', new Map<String, Time>{'startTime' => businessHourRec.ThursdayStartTime, 'endTime' => businessHourRec.ThursdayEndTime});
                                                        
                                                        // Friday Calculation
                                                        Decimal FridayWorkingHours = 0; 
                                                        if(businessHourRec.FridayStartTime != null && businessHourRec.FridayEndTime != null){
                                                            FridayWorkingHours = (businessHourRec.FridayEndTime.hour() - businessHourRec.FridayStartTime.hour()) + Decimal.valueOf(businessHourRec.FridayEndTime.minute() - businessHourRec.FridayStartTime.minute()).divide(60,2);
                                                            if(!(FridayWorkingHours > 0))
                                                                FridayWorkingHours = 24;
                                                        }
                                                        
                                                        
                                                        calculateBusinessHours.mapDayToWorkingHours.put('Friday', FridayWorkingHours);
                                                        calculateBusinessHours.mapDayToStartEndTime.put('Friday', new Map<String, Time>{'startTime' => businessHourRec.FridayStartTime, 'endTime' => businessHourRec.FridayEndTime});
                                                        
                                                        
                                                        // Saturday Calculation  
                                                        Decimal SaturdayWorkingHours = 0;
                                                        if(businessHourRec.SaturdayStartTime != null && businessHourRec.SaturdayEndTime != null){
                                                            SaturdayWorkingHours = (businessHourRec.SaturdayEndTime.hour() - businessHourRec.SaturdayStartTime.hour()) + Decimal.valueOf(businessHourRec.SaturdayEndTime.minute() - businessHourRec.SaturdayStartTime.minute()).divide(60,2);
                                                            if(!(SaturdayWorkingHours > 0))
                                                                SaturdayWorkingHours = 24;
                                                        }
                                                        
                                                        
                                                        calculateBusinessHours.mapDayToWorkingHours.put('Saturday', SaturdayWorkingHours);
                                                        calculateBusinessHours.mapDayToStartEndTime.put('Saturday', new Map<String, Time>{'startTime' => businessHourRec.SaturdayStartTime, 'endTime' => businessHourRec.SaturdayEndTime});
                                                        
                                                        
                                                        // Sunday Calculation 
                                                        Decimal SundayWorkingHours = 0;
                                                        if(businessHourRec.SundayStartTime != null && businessHourRec.SundayEndTime != null) {
                                                            SundayWorkingHours = (businessHourRec.SundayEndTime.hour() - businessHourRec.SundayStartTime.hour()) + Decimal.valueOf(businessHourRec.SundayEndTime.minute() - businessHourRec.SundayStartTime.minute()).divide(60,2);
                                                            if(!(SundayWorkingHours > 0))
                                                                SundayWorkingHours = 24; 
                                                        }
                                                        
                                                        
                                                        calculateBusinessHours.mapDayToWorkingHours.put('Sunday', SundayWorkingHours);
                                                        calculateBusinessHours.mapDayToStartEndTime.put('Sunday', new Map<String, Time>{'startTime' => businessHourRec.SundayStartTime, 'endTime' => businessHourRec.SundayEndTime});
                                                        
                                                        
                                                        mapBusinesshoursIdValues.put(businessHourRec.Id, calculateBusinessHours);
                                                    }
                
                
                for(Holiday eachHoliday : [SELECT ActivityDate,IsRecurrence,CreatedDate,EndTimeInMinutes,Id,IsAllDay,Name,StartTimeInMinutes,RecurrenceEndDateOnly,RecurrenceStartDate FROM Holiday]) {
                    if(!eachHoliday.isAllDay) {
                        lstOfPartialHoliday.add(eachHoliday);
                    }
                    else{
                        listOfAllDayHoliday.add(eachHoliday);
                    }
                }
                
                
                
                return listUser;
            }
            else
                return null;
        }
        catch(Exception ex){
            throw ex; 
        }
    }
    
    /*
    For the List of users passed to execute method based on Batch size, Time sheet Header or Time Sheet Entries will be created. 
    Time Sheet Header is created, when timeSheetRecordType == 'TIMESHEETHEADER'
    Time Sheet Autofill is created, when timeSheetRecordType == 'TIMESHEETAUTOFILL'
    BAC-1276:sourabh:9dec2016: Code updated to consider prior time periods
    */
    global void execute(Database.BatchableContext TSEngine, List<sObject> scope){
        //Create Timesheet Header for All the users based on Configuration Defined.
        //Moved code as part of BAC-4814/044977
        
        Map <Id, Id> mapUserandTMProcess = new Map <Id, Id>();
        Map <Id, List<User>> mapProcessUsersTemp = new  Map <Id, List<User>>();
        for(sObject usRec : scope){
            //User userObj = new User();
            User userObj = (User)usRec;
            //System.debug('userObj '+userObj);
            Id processIDUser = mapTimesheetProfileandProcess.get(mapTimesheetConfigProfileandSFProfile.get(userObj.ProfileId));
            mapUserandTMProcess.put(userObj.ID, processIDUser); 
            if(mapProcessUsersTemp != null && mapProcessUsersTemp.get(processIDUser) != null)
                mapProcessUsersTemp.get(processIDUser).add(userObj);
            else{
                List <User> listuserObj = new List<User>();
                listuserObj.add(userObj);
                mapProcessUsersTemp.put(processIDUser,listuserObj );
            }
            //Added for BAC-4865 22nd May
            if(mapProcessUsers.size()>0 && mapProcessUsers.containsKey(processIDUser)){
                mapProcessUsers.get(processIDUser).add(userObj);
            }else{
                mapProcessUsers.putAll(mapProcessUsersTemp);
            }
        }
        for(Id varKey: mapProcessUsers.keySet()){// Get the unique users
            Set<User> tempSet = new Set<User>();
            tempSet.addAll(mapProcessUsers.get(varKey));
            List<User> tempSetList = new List<User>();
            tempSetList.addAll(tempSet);
            mapProcessUsers.put(varKey,tempSetList);
        }
        for(Id varKey: mapProcessUsersTemp.keySet()){// Get the unique users
            Set<User> tempSet = new Set<User>();
            tempSet.addAll(mapProcessUsersTemp.get(varKey));
            List<User> tempSetList = new List<User>();
            tempSetList.addAll(tempSet);
            mapProcessUsersTemp.put(varKey,tempSetList);
        }
        //mapProcessUsers.putAll(mapProcessUsersTemp); //Commented for BAC-4865 22nd May
        System.debug(LoggingLevel.WARN, 'List of Users in every ServiceMax Process passed :' + mapProcessUsersTemp.size());
        //
        if(timeSheetRecordType != null && timeSheetRecordType.toUpperCase() == 'TIMESHEETHEADER'){
            List<SVMXC__Timesheet__c> insertTimesheetHeader = new List<SVMXC__Timesheet__c>();
            List<SVMXC__Timesheet_Day_Entry__c> insertUserTimesheetDayEntry = new List <SVMXC__Timesheet_Day_Entry__c> ();
            for(sObject userRec: scope) {
                User userObj = new User();
                userObj = (User)userRec; 
                List<SVMXC__Timesheet__c> listUserTimesheetHeader = createUserTimesheetHeader (userObj, mapUserandTMProcess); //Added mapProcessUsersTemp for BAC-4814/044977 
                if(listUserTimesheetHeader != null && listUserTimesheetHeader.size() > 0)
                    insertTimesheetHeader.addAll(listUserTimesheetHeader);    
                
            }
            System.debug(LoggingLevel.WARN, 'Timesheet Header Created for all the Users ' + insertTimesheetHeader.size());
            
            if(insertTimesheetHeader != null && insertTimesheetHeader.size() > 0){
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( insertTimesheetHeader, COMM_SecurityUtils.Access.Createable ) ) {
                    insert insertTimesheetHeader;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                for(SVMXC__Timesheet__c usertimeSheetDayEntryRec: insertTimesheetHeader){
                    Integer numberDaysDue = usertimeSheetDayEntryRec.SVMXC__Start_Date__c.daysBetween(usertimeSheetDayEntryRec.SVMXC__End_Date__c);
                    
                    BusinessHoursInfo identifyTheDay = mapBusinesshoursIdValues.get(usertimeSheetDayEntryRec.SVMXC__SM_Business_Hours__c);
                    //system.debug(identifyTheDay);
                    String timeZone = identifyTheDay.businessHourRecDetail.TimeZoneSidKey; 
                    // Get all the holidays between Start & End Date of Timesheet Header
                    
                    // Map should contain list of holidays for a particular day in ascending order.
                    Map<Date, List<HolidayTime>> mapDateStartTimeEndTime = new Map<Date, List<HolidayTime>>();
                    
                    
                    COMM_BusinessHourUtils classInstance = new COMM_BusinessHourUtils(); 
                    List<COMM_BusinessHourUtils.HolidayDateAndTime>listHolidayTimings = classInstance.getHolidaysForBS(identifyTheDay.businessHourRecDetail, listOfAllDayHoliday, lstOfPartialHoliday, usertimeSheetDayEntryRec.SVMXC__Start_Date__c,usertimeSheetDayEntryRec.SVMXC__End_Date__c); 
                    
                    for(COMM_BusinessHourUtils.HolidayDateAndTime eachHoliday: listHolidayTimings ){
                        // We are coverting the GMT DateTime string received in DateTimeformat
                        // Convert the DateTime to local format using .format(). But it returns result in String, so we have convert it back to Datetime field.
                        Map<String, Time> mapHoliDayTimings = new Map<String, Time>();
                        DateTime startDateGMT = DateTime.valueOfGmt((eachHoliday.startDateTime+'Z').replace('T', ' '));
                        DateTime endDateGMT = DateTime.valueOfGmt((eachHoliday.endDateTime+'Z').replace('T', ' ')); 
                        
                        DateTime startDateLocal = DateTime.valueofGmt(startDateGMT.format('yyyy-MM-dd HH:mm:ss', timeZone ));
                        DateTime endDateLocal = DateTime.valueofGmt(endDateGMT.format('yyyy-MM-dd HH:mm:ss', timeZone ));
                        
                        
                        String day = DateTime.newInstance(startDateLocal.dateGMT(),Time.newInstance(0,0,0,0)).format('EEEE');
                        
                        Map<String, Time> mapBusineesHourStartEndTime = identifyTheDay.mapDayToStartEndTime.get(day);
                        
                        // At any point in time, Holiday time is to be updated with holiday starting from BusinessStart Time and ending by Bussiness End Time
                        Time startTime = Time.newInstance(0,0,0,0);
                        
                        if(startDateLocal.timeGmt() < mapBusineesHourStartEndTime.get('startTime')){
                            // Check if startTime is greater then end time or not. If yes, don't update Start Time 
                            startTime = mapBusineesHourStartEndTime.get('startTime');
                        }
                        else{
                            if((mapBusineesHourStartEndTime.get('endTime') != Time.newInstance(0,0,0,0)) && (startDateLocal.timeGmt() > mapBusineesHourStartEndTime.get('endTime'))){
                                startTime = mapBusineesHourStartEndTime.get('endTime');  
                            }
                            else{
                                startTime = startDateLocal.timeGmt(); 
                            }
                        }
                        
                        // Only for End time, we need to check if the business hours are 24 hours working or not
                        Time endTime = Time.newInstance(0,0,0,0);
                        if(mapBusineesHourStartEndTime.get('endTime') != Time.newInstance(0,0,0,0)){
                            if(endDateLocal.timeGmt() > mapBusineesHourStartEndTime.get('endTime')){
                                endTime= mapBusineesHourStartEndTime.get('endTime'); 
                            }
                            else{
                                if(endDateLocal.timeGmt() < mapBusineesHourStartEndTime.get('startTime')){
                                    endTime = mapBusineesHourStartEndTime.get('startTime');
                                }
                                else{
                                    endTime = endDateLocal.timeGmt();     
                                }
                            }
                        }
                        else{
                            endTime = endDateLocal.timeGmt();   
                        }
                        
                        HolidayTime addHolidayTime = new HolidayTime(startTime ,endTime );
                        
                        if(mapDateStartTimeEndTime != null && mapDateStartTimeEndTime.get(startDateLocal.dateGMT()) != null){
                            mapDateStartTimeEndTime.get(startDateLocal.dateGMT()).add(addHolidayTime);
                        }
                        else{
                            List<HolidayTime> newList = new List<HolidayTime>();
                            newList.add(addHolidayTime) ;
                            mapDateStartTimeEndTime.put(startDateLocal.dateGMT(), newList);
                        }
                    }
                    
                   // System.debug(LoggingLevel.WARN, 'List of Holidays for a Particular Day: ' +mapDateStartTimeEndTime);
                    
                    // mapDateStartTimeEndTime might contain overlapping list of holidays. Therfore, we need to remove 
                    // overlapping holidays to get correct working hours for a day
                    
                    if(mapDateStartTimeEndTime != null && mapDateStartTimeEndTime.size() > 0) {
                        for(Date holidayDate: mapDateStartTimeEndTime.keyset()){
                            List<HolidayTime> holidayListForDate = mapDateStartTimeEndTime.get(holidayDate);
                            List<HolidayTime> mergedholidayListForDate = new List<HolidayTime>(); 
                            
                            Time baseStartTime = holidayListForDate.get(0).startTime ; 
                            Time baseEndTime = holidayListForDate.get(0).endTime;
                            
                            for(integer i=1; i < holidayListForDate.size() ; i++){
                                HolidayTime holidayStartEndTime = holidayListForDate.get(i);
                                Time iterationStart = holidayStartEndTime.startTime;
                                Time iterationEnd = holidayStartEndTime.endTime;
                                
                                if(iterationStart > baseEndTime){
                                    // update my base
                                    HolidayTime holidayBase = new HolidayTime(baseStartTime, baseEndTime);
                                    mergedholidayListForDate.add(holidayBase);
                                    baseStartTime = iterationStart;
                                    baseEndTime   = iterationEnd;
                                    
                                } else if(iterationStart <= baseEndTime && iterationEnd > baseEndTime){
                                    // update my base end
                                    baseEndTime = iterationEnd;
                                }
                            }
                            
                            // Always put the last base values into the map
                            HolidayTime holidayBase = new HolidayTime(baseStartTime, baseEndTime);
                            mergedholidayListForDate.add(holidayBase);
                            
                            mapDateStartTimeEndTime.put(holidayDate, mergedholidayListForDate);
                        }
                    }
                    
                    System.debug(LoggingLevel.WARN, 'List of Holidays after removing overlapping and duplicate Holidays: ' +mapDateStartTimeEndTime);
                    
                    
                    for(integer i=0; i < = numberDaysDue ; i++){
                        SVMXC__Timesheet_Day_Entry__c createTimesheetDayEntry = new SVMXC__Timesheet_Day_Entry__c();
                        createTimesheetDayEntry.SVMXC__Timesheet__c = usertimeSheetDayEntryRec.id;
                        createTimesheetDayEntry.SVMXC__Timsheet_Day__c = usertimeSheetDayEntryRec.SVMXC__Start_Date__c.addDays(i);
                        
                        // All the days will be created based on User's Timezone
                        String day = DateTime.newInstance(createTimesheetDayEntry.SVMXC__Timsheet_Day__c,Time.newInstance(0,0,0,0)).format('EEEE');
                        // If working hours are 0, then it's holiday
                        if(usertimeSheetDayEntryRec.SVMXC__SM_Business_Hours__c != null){
                            createTimesheetDayEntry.SVMXC__SM_Working_Minutes__c = identifyTheDay.mapDayToWorkingHours.get(day)*60;  
                        }
                        
                        
                        // If it's not Holiday, find the partial Holidays
                        if(createTimesheetDayEntry.SVMXC__SM_Working_Minutes__c != 0){
                            if(mapDateStartTimeEndTime != null && mapDateStartTimeEndTime.get(createTimesheetDayEntry.SVMXC__Timsheet_Day__c) != null){
                                for(HolidayTime holiDayTimingsDate : mapDateStartTimeEndTime.get(createTimesheetDayEntry.SVMXC__Timsheet_Day__c)) {
                                    
                                    Time holidayStartTime = holiDayTimingsDate.startTime;
                                    Time holidayEndTime = holiDayTimingsDate.endTime; 
                                    Integer holidayInMins = math.abs(Integer.valueOf(holidayEndTime.hour()-holidayStartTime.hour())*60) +  Integer.valueOf(holidayEndTime.minute() - holidayStartTime.minute()) ;
                                    
                                    if(holidayInMins >= createTimesheetDayEntry.SVMXC__SM_Working_Minutes__c){
                                        createTimesheetDayEntry.SVMXC__SM_Working_Minutes__c = 0;
                                    } 
                                    else{
                                        holidayInMins = math.abs(Integer.valueOf(holidayEndTime.hour()-holidayStartTime.hour())*60) + Integer.valueOf(holidayEndTime.minute() - holidayStartTime.minute());   
                                        //Defect Fix 30021
                                        // if 24 hour holiday is present, then reduce 1 min as we calculate hours from 00:00 to 23:59
                                        if(holidayInMins == 1439){
                                            holidayInMins += 1;
                                        }
                                        //system.debug(holidayInMins);
                                        createTimesheetDayEntry.SVMXC__SM_Working_Minutes__c -= holidayInMins; 
                                    }
                                }
                            }
                        }
                        if(createTimesheetDayEntry.SVMXC__SM_Working_Minutes__c == 0 ){
                            createTimesheetDayEntry.SVMXC__IsHoliday__c = true; 
                        } 
                        insertUserTimesheetDayEntry.add(createTimesheetDayEntry);    
                    }
                }
                
                if( insertUserTimesheetDayEntry != null && insertUserTimesheetDayEntry.size() > 0)
                    insert insertUserTimesheetDayEntry;
                
                System.debug(LoggingLevel.WARN, 'Multiple Timesheet Day Entry Record created for every Timesheet Header ' + insertUserTimesheetDayEntry.size());
            }
            
            if(updateInvalidTimesheetHeaders != null && updateInvalidTimesheetHeaders.size()> 0)
                update updateInvalidTimesheetHeaders;
            
            System.debug(LoggingLevel.WARN, 'Update Invalid Timesheet Header for User ' + updateInvalidTimesheetHeaders.size());
        }
        try{
        //Get all the Timesheet header and details
        getTimesheetHeaderandDetailsforUsers(mapUserandTMProcess, mapProcessUsersTemp);
        //end of if 'TIMESHEETAUTOFILL'
        if(timeSheetRecordType != null && timeSheetRecordType.toUpperCase() == 'TIMESHEETAUTOFILL'){
            Map <String, Schema.SObjectType> schemaMap = new Map <String, Schema.SObjectType>();
            Map <String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            for(Schema.SObjectType s : gd.values()){
                schemaMap.put(s.getDescribe().getName(),s);
            }
            
            List<SVMXC__Timesheet_Entry__c> createListTimeSheetEntry = new List<SVMXC__Timesheet_Entry__c>();
            for(sObject userRec: scope) 
            {           
                User userObj = new User();
                userObj = (User)userRec; 
                UserAutofillInfo userInfoInst = new UserAutofillInfo(userObj);
                String eventType = timeSheetProcess.get(mapUserandTMProcess.get(userRec.Id)).SVMXC__Event_Type__c;
                //Get the Configuration Process assosiated to User  
                ID assosiatedProcessBusinessHours = timeSheetProcess.get(mapUserandTMProcess.get(userRec.Id)).SVMXC__Business_Hours__c;
                String getTimeZoneFrom = timeSheetProcess.get(mapUserandTMProcess.get(userRec.Id)).SVMXC__SM_Business_Hour_Source__c != null ? timeSheetProcess.get(mapUserandTMProcess.get(userRec.Id)).SVMXC__SM_Business_Hour_Source__c : 'Technician Record'; //Added for story BAC-5388
                Map<String, Id> mapObjectMappingIds = mapProcessObjectMapping.get(mapUserandTMProcess.get(userRec.Id));
                
                if(mapUserTimesheetHeaders != null && mapUserTimesheetHeaders.get(userObj.Id)!= null && mapUserTimesheetHeaders.get(userObj.Id).size() > 0 
                   && mapObjectMappingIds != null && mapObjectMappingIds.get('SVMXC__Service_Order_Line__c') != null)
                {
                    emailBody += 'Work Order Line type of Entries to be created. ';
                    List<SVMXC__Service_Order_Line__c> listUserWOLines;
                    for(Id TSID : mapUserTimesheetHeaders.get(userObj.ID))
                    {
                        listUserWOLines = mapTSHdrWOLines.get(TSID);
                        if(listUserWOLines != null && listUserWOLines.size() > 0)
                        {      
                            System.debug(LoggingLevel.WARN, 'Create Timesheet Entry for Work Detail= ' + listUserWOLines.size());
                            userInfoInst.workDetailCount += listUserWOLines.size();
                            //createTimesheetEntry (TSID, listUserWOLines, mapObjectMappingIds.get('SVMXC__Service_Order_Line__c'), createListTimeSheetEntry, assosiatedProcessBusinessHours, schemaMap, getTimeZoneFrom); //Commented for 047019
                            createTimesheetEntry (TSID, listUserWOLines, mapObjectMappingIds.get('SVMXC__Service_Order_Line__c'), createListTimeSheetEntry, assosiatedProcessBusinessHours, schemaMap, getTimeZoneFrom, 'SVMXC__Service_Order_Line__c'); //Added for 047019
                        } 
                    }    
                }
                
                if(mapUserTimesheetHeaders != null && mapUserTimesheetHeaders.get(userObj.Id)!= null && mapUserTimesheetHeaders.get(userObj.Id).size() > 0 
                   && mapObjectMappingIds != null && mapObjectMappingIds.get('Task') != null )
                {
                    List<Task> listUserTasks; 
                    emailBody += 'Task type of Entries to be created. ';
                    for(Id TSID : mapUserTimesheetHeaders.get(userObj.ID))
                    {
                        listUserTasks = mapTSHdrTskLines.get(TSID);
                        if(listUserTasks != null && listUserTasks.size() > 0)
                        {   
                            System.debug(LoggingLevel.WARN, 'Create Timesheet Entry for Task=' + listUserTasks.size());
                            userInfoInst.taskCount += listUserTasks.size();
                            //createTimesheetEntry (TSID, listUserTasks, mapObjectMappingIds.get('Task'), createListTimeSheetEntry, assosiatedProcessBusinessHours,schemaMap, getTimeZoneFrom); //Commented for 047019
                            createTimesheetEntry (TSID, listUserTasks, mapObjectMappingIds.get('Task'), createListTimeSheetEntry, assosiatedProcessBusinessHours,schemaMap, getTimeZoneFrom, 'Task'); //Added for 047019
                        } 
                    }    
                }
                
                if((eventType.toUpperCase() == 'EVENT' || eventType.toUpperCase() == 'BOTH') && mapUserTimesheetHeaders != null && mapUserTimesheetHeaders.get(userObj.Id)!= null && mapUserTimesheetHeaders.get(userObj.Id).size() > 0 
                   && mapObjectMappingIds != null && mapObjectMappingIds.get('Event') != null)
                {
                    List<Event> listUserSFEvents; 
                    for(Id TSID : mapUserTimesheetHeaders.get(userObj.ID))
                    {
                        listUserSFEvents = mapTSHdrEvtLines.get(TSID);
                        if(listUserSFEvents != null && listUserSFEvents.size() > 0)
                        {   
                            System.debug(LoggingLevel.WARN, 'Create Timesheet Entry for Event= ' + listUserSFEvents.size());
                            userInfoInst.eventCount += listUserSFEvents.size();
                            //createTimesheetEntry (TSID, listUserSFEvents, mapObjectMappingIds.get('Event'), createListTimeSheetEntry, assosiatedProcessBusinessHours, schemaMap, getTimeZoneFrom); //Commented for 047019
                            createTimesheetEntry (TSID, listUserSFEvents, mapObjectMappingIds.get('Event'), createListTimeSheetEntry, assosiatedProcessBusinessHours, schemaMap, getTimeZoneFrom, 'Event'); //Added for 047019
                        } 
                    }    
                }
                
                if((eventType.toUpperCase() == 'SERVICEMAX EVENT' || eventType.toUpperCase() == 'BOTH') && mapUserTimesheetHeaders != null && mapUserTimesheetHeaders.get(userObj.Id)!= null && mapUserTimesheetHeaders.get(userObj.Id).size() > 0 
                   && mapObjectMappingIds != null && mapObjectMappingIds.get('SVMXC__SVMX_Event__c') != null )
                {
                    List<SVMXC__SVMX_Event__c> listUserSVMXEvents; 
                    emailBody += 'ServiceMax Event type of Entries to be created. ';
                    for(Id TSID : mapUserTimesheetHeaders.get(userObj.ID))
                    {
                        listUserSVMXEvents = mapTSHdrSEvtLines.get(TSID);
                        if(listUserSVMXEvents != null && listUserSVMXEvents.size() > 0)
                        {   
                            System.debug(LoggingLevel.WARN, 'Create Timesheet Entry for SVMX Event ' + listUserSVMXEvents.size());
                            userInfoInst.svmxEventCount += listUserSVMXEvents.size();
                            //createTimesheetEntry (TSID, listUserSVMXEvents, mapObjectMappingIds.get('SVMXC__SVMX_Event__c'), createListTimeSheetEntry, assosiatedProcessBusinessHours, schemaMap, getTimeZoneFrom); //Commented for 047019
                            createTimesheetEntry (TSID, listUserSVMXEvents, mapObjectMappingIds.get('SVMXC__SVMX_Event__c'), createListTimeSheetEntry, assosiatedProcessBusinessHours, schemaMap, getTimeZoneFrom, 'SVMXC__SVMX_Event__c'); //Added for 047019
                        } 
                    }                       
                }
                mapUserIDUserAutofillInfo.put(userRec.ID, userInfoInst);
            }
            System.debug(logginglevel.WARN, 'Creating Timesheet Entry '+createListTimeSheetEntry.size());
            if(createListTimeSheetEntry != null && createListTimeSheetEntry.size() > 0){
                try{
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( createListTimeSheetEntry, COMM_SecurityUtils.Access.Createable ) ) {
                        //insert createListTimeSheetEntry; //Commented for BAC-4865
                        //Added for BAC-4865
                        List<Database.UpsertResult> updateResults = Database.upsert(createListTimeSheetEntry, false);
                        for(Integer i=0;i<updateResults.size();i++){
                            if (updateResults.get(i).isSuccess()){
                                
                                }else if (!updateResults.get(i).isSuccess()){
                                // DML operation failed
                                mapUpdateDailySummaryTotalHours.remove(createListTimeSheetEntry.get(i).SVMXC__Timesheet_Day__c);
                                Database.Error error = updateResults.get(i).getErrors().get(0);
                                system.debug('Failed record '+createListTimeSheetEntry.get(i));
                                //listErrorDetails.add('The error has occurred while processing: '+'\n'+createListTimeSheetEntry.get(i) +'\n'+' Impacted time entry fields: ' + error.getMessage()); // Commented for BAC-4865 22nd May
                                //Added for BAC-4865 22nd May
                                String errorMessageObject = '';
                                try{
                                if(createListTimeSheetEntry.get(i).SVMXC__Work_Detail__c !=null)
                                    errorMessageObject = 'Work Detail '+createListTimeSheetEntry.get(i).SVMXC__Work_Detail__c;
                                }catch(Exception e){}
                                try{
                                if(createListTimeSheetEntry.get(i).SVMXC__Task__c !=null)
                                    errorMessageObject = 'Task '+createListTimeSheetEntry.get(i).SVMXC__Task__c;
                                }catch(Exception e){}
                                try{
                                if(createListTimeSheetEntry.get(i).SVMXC__ServiceMax_Event__c !=null)
                                    errorMessageObject = 'ServiceMax Event '+createListTimeSheetEntry.get(i).SVMXC__ServiceMax_Event__c;
                                }catch(Exception e){}
                                try{
                                if(createListTimeSheetEntry.get(i).SVMXC__Salesforce_Event__c    !=null)
                                    errorMessageObject = 'Event '+createListTimeSheetEntry.get(i).SVMXC__Salesforce_Event__c    ;
                                }catch(Exception e){}
                                if(Limits.getHeapSize() <= 5000000){ // Don't add to list if it exceed more than 5MB 
                                    listErrorDetails.add(errorMessageObject +'\n'+'Impacted time entry fields: ' + error.getMessage()); // Added for BAC-4865 22nd May
                                }
                                //End for BAC-4865 22nd May
                            }

                        }
                        
                        //Added for BAC-4865
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    
                    
                    update mapUpdateDailySummaryTotalHours.values();
                    // Update only the Timesheet headers, whose time sheet daily summary gor updated.
                    for(SVMXC__Timesheet_Day_Entry__c tSDailySummaryRec: mapUpdateDailySummaryTotalHours.values()){
                        ID timesheetHeaderID = tSDailySummaryRec.SVMXC__Timesheet__c; 
                        //system.debug(maptimesheetHeaderId.get(timesheetHeaderID)); 
                        SVMXC__Timesheet__c timesheetHeaderRec = maptimesheetHeaderId.get(timesheetHeaderID);
                        if(timesheetHeaderRec.SVMXC__Total_Hours__c == null){
                            timesheetHeaderRec.SVMXC__Total_Hours__c = 0;
                        }
                        // Got All the Timesheet Day entry record for this Header.
                        Double headerTotalHours = tSDailySummaryRec.SVMXC__Total_Hours__c; 
                        for(SVMXC__Timesheet_Day_Entry__c timeDayEntries :mapTimesheetHeaderandTimesheetDayEntry.get(timesheetHeaderID)){
                            //System.debug(logginglevel.WARN, 'timeDayEntries '+ timeDayEntries);
                            if(timeDayEntries.SVMXC__Total_Hours__c == null){
                                timeDayEntries.SVMXC__Total_Hours__c = 0;
                            }
                            String timesDayEntryID = timeDayEntries.Id;  
                            //System.debug(logginglevel.WARN, 'timeDayEntries '+ timesDayEntryID);
                            
                            if(!timesDayEntryID.equalsIgnoreCase(tSDailySummaryRec.id)){
                                headerTotalHours = headerTotalHours + timeDayEntries.SVMXC__Total_Hours__c;
                            }
                        }
                        
                        timesheetHeaderRec.SVMXC__Total_Hours__c =  headerTotalHours; 
                        maptimesheetHeaderId.put(timesheetHeaderID, timesheetHeaderRec);
                    }
                    //System.debug(logginglevel.WARN, 'maptimesheetHeaderId '+maptimesheetHeaderId);
                    update maptimesheetHeaderId.values();
                    
                    for(Id userAutofillId : mapUserIDUserAutofillInfo.keyset()){
                        UserAutofillInfo updateUserAutofillInfo = mapUserIDUserAutofillInfo.get(userAutofillId);
                        updateUserAutofillInfo.AutoFillStatus = getTAG007(); 
                    }
                }
                catch(Exception ex){
                    System.debug(logginglevel.WARN, 'on catch of autofill schedule record insert : '+ex.getMessage());
                    for(Id userAutofillId : mapUserIDUserAutofillInfo.keyset()){
                        UserAutofillInfo updateUserAutofillInfo = mapUserIDUserAutofillInfo.get(userAutofillId);
                        updateUserAutofillInfo.AutoFillStatus = getTAG008(); 
                    }
                }
            }
        }
        }catch(Exception ex){
            System.debug('Exception in execute method '+ex);
        }finally{ //Added for BAC-4814/044977 //TODO
                    mapUserandTMProcess.clear();
                    mapProcessObjectMapping.clear();
                    maptimesheetHeaderId.clear();
                    mapUpdateDailySummaryTotalHours.clear();
                    mapTimesheetHeaderandTimesheetDayEntry.clear();
                    mapTimesheetHeaderEntries.clear();
                    mapUserTimesheetHeaders.clear();
                    mapTSHdrWOLines.clear(); // Added for BAC-4866
                    mapTSHdrSEvtLines.clear(); // Added for BAC-4866
                    mapTSHdrEvtLines.clear(); // Added for BAC-4866
                    mapTSHdrTskLines.clear(); // Added for BAC-4866
                    mapRecordsWithTimezone.clear(); //Added for story BAC-5388
        }
    }
    
    /*
    After all the Processing is done for creating Time Sheet Header & Time Sheet Entry, need to send email to customer 
    saying the processing has been done.
    This method takes care of sending email to user for the processed data.
    */
    global void finish(Database.BatchableContext BC){
        if(updateInvalidTimesheetHeaders != null && updateInvalidTimesheetHeaders.size() >0)
            update updateInvalidTimesheetHeaders; 
        // For evry User I will get the Userid, List of Timesheet Header Created
        TimeZone tz = UserInfo.getTimeZone();
        DateTime datetimeEnd = System.now();
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        Boolean isAttachLog = true;
        try
        {   
            String strlogger = '';
            List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
            for(SVMXC__ServiceMax_Processes__c svmxProcess : timeSheetProcess.values()){
                Boolean notifyTechnician = svmxProcess.SVMXC__Notify_Technician__c;
                List<User> listUsersInProcess = mapProcessUsers.get(svmxProcess.id);
                List<String> lstEmailIDs = new List<String>();
                lstEmailIDs.add(svmxProcess.SVMXC__Email_On_Success__c);
                strlogger += '\n'+getTAG004() + ' '+svmxProcess.Name;
                strlogger = strlogger+'\n'+getTAG022()+' '+svmxProcess.SVMXC__ProcessID__c;
                
                String strEndlog = '';
                strEndlog = strEndlog+'\n\n'+getTAG010()+': '+dateTimeStart.format('MM/dd/yyyy HH:mm:ss', tz.getID())+' '+tz.getDisplayName()+' ('+tz+')';
                strEndlog = strEndlog+'\n'+getTAG011()+': '+datetimeEnd.format('MM/dd/yyyy HH:mm:ss', tz.getID())+' '+tz.getDisplayName()+' ('+tz+')';
                Decimal decCoutTime  = (Decimal.valueOf(((datetimeEnd.day()-dateTimeStart.day())*24*60*60)+((datetimeEnd.hour()-dateTimeStart.hour())*60*60)+((datetimeEnd.minute()-dateTimeStart.minute())*60)+(datetimeEnd.second()-dateTimeStart.second())))/60;
                Decimal decRounded = Math.round(decCoutTime * 100) / 100.0;
                strEndlog = strEndlog+'\n'+getTAG012()+': '+ decRounded.toPlainString();
                
                if(timeSheetRecordType != null && timeSheetRecordType.toUpperCase() == 'TIMESHEETHEADER'){
                    String strLogPass = '';
                    String strAttachmentlog = ''; 
                    Integer countSuccess = 0; 
                    Integer countFailure = 0; 
                    for(User technicianRec: mapProcessUsers.get(svmxProcess.id)){
                        if(mapUserIDTimesheetHeader != null && mapUserIDTimesheetHeader.get(technicianRec.ID) != null ){
                            countSuccess ++ ; 
                        }
                        if(notifyTechnician){
                            String userStrSubject = getTAG002() + ' ';  
                            String userEmailContent = '';
                            Messaging.SingleEmailMessage objSingleEmailMsg = new Messaging.SingleEmailMessage();  
                            List<SVMXC__Timesheet__c> userTimesheetHeader = mapUserIDTimesheetHeader.get(technicianRec.ID);
                            Integer count = 0; 
                            strAttachmentlog += '\n\n' +technicianRec.FirstName + ' ' +  technicianRec.LastName + ' : ' ; 
                            if(userTimesheetHeader != null && userTimesheetHeader.size() > 0){
                                for(SVMXC__Timesheet__c tSRec : userTimesheetHeader){ 
                                    if(count == 0)
                                        userStrSubject += DateTime.newInstance(tSRec.SVMXC__Start_Date__c.year(), tSRec.SVMXC__Start_Date__c.month(), tSRec.SVMXC__Start_Date__c.day()).format('MM/dd/yyyy') + ' - '+ DateTime.newInstance(tSRec.SVMXC__End_Date__c.year(), tSRec.SVMXC__End_Date__c.month(), tSRec.SVMXC__End_Date__c.day()).format('MM/dd/yyyy'); 
                                    else{
                                        userStrSubject += ' ; ' + tSRec.SVMXC__Start_Date__c.format() + ' - '+ tSRec.SVMXC__End_Date__c.format(); 
                                    }
                                    userEmailContent +=  '\n\n'+ getTAG002() + ' '+DateTime.newInstance(tSRec.SVMXC__Start_Date__c.year(), tSRec.SVMXC__Start_Date__c.month(), tSRec.SVMXC__Start_Date__c.day()).format('MM/dd/yyyy')+ ' - '+ DateTime.newInstance(tSRec.SVMXC__End_Date__c.year(), tSRec.SVMXC__End_Date__c.month(), tSRec.SVMXC__End_Date__c.day()).format('MM/dd/yyyy') + '. \n' +getTAG003();
                                    userEmailContent += baseURL + '/' + tSRec.id ; 
                                    userEmailContent += '\n';
                                    
                                    strAttachmentlog += +'\n'+ DateTime.newInstance(tSRec.SVMXC__Start_Date__c.year(), tSRec.SVMXC__Start_Date__c.month(), tSRec.SVMXC__Start_Date__c.day()).format('MM/dd/yyyy') + ' - '+ DateTime.newInstance(tSRec.SVMXC__End_Date__c.year(), tSRec.SVMXC__End_Date__c.month(), tSRec.SVMXC__End_Date__c.day()).format('MM/dd/yyyy') + ' , '+  baseURL + '/' + tSRec.id ; 
                                    count++; 
                                }
                                
                                objSingleEmailMsg.setTargetObjectId(technicianRec.Id);
                                objSingleEmailMsg.setSubject(userStrSubject);
                                objSingleEmailMsg.setBccSender(false);
                                objSingleEmailMsg.setUseSignature(false);
                                objSingleEmailMsg.saveAsActivity = false;
                                
                                if(userEmailContent != '' && userEmailContent != null)
                                    objSingleEmailMsg.setPlainTextBody(userEmailContent);
                                else{
                                    objSingleEmailMsg.setPlainTextBody('An error occured while creating records for User ' + technicianRec.FirstName + ' '+ technicianRec.LastName);
                                }
                                mails.add(objSingleEmailMsg);
                            }
                        }
                    }
                    if(mapProcessUsers.get(svmxProcess.id) != null && listUsersInProcess.size() != countSuccess)
                        countFailure = listUsersInProcess.size() - countSuccess; 
                    
                    if(countFailure > 0 && !svmxProcess.SVMXC__Email_On_Success__c.equals(svmxProcess.SVMXC__Email_On_Error__c))
                        lstEmailIDs.add(svmxProcess.SVMXC__Email_On_Error__c);
                    
                    strLogPass = strLogPass+'\n\t'+getTAG006()+': '+listUsersInProcess.size();
                    strLogPass = strLogPass+'\n\t'+getTAG007()+': '+countSuccess;
                    strLogPass = strLogPass+'\n\t'+getTAG008()+': '+countFailure;
                    
                    strlogger = strlogger+strLogPass;
                    
                    strAttachmentlog = strlogger+'\n=========================================================\n'+ strAttachmentlog;
                    strlogger = strlogger+strEndlog;
                    strAttachmentlog = strAttachmentlog+'\n=========================================================\n'+strEndlog;
                    
                    String strFinaLlogger = getTAG001()+'\n';
                    strFinaLlogger = strFinaLlogger+'\n'+getTAG013();
                    strFinaLlogger = strFinaLlogger+strlogger;
                    strFinaLlogger = strFinaLlogger+'\n\n'+getTAG010();
                    String strNowDateMail =  datetimeEnd.format('MM/dd/yyyy', tz.getID());
                    
                    Messaging.EmailFileAttachment Attc = new Messaging.EmailFileAttachment();
                    blob attachBlob = Blob.valueOf(strAttachmentlog);
                    string flename= getTAG014()+'_'+strNowDateMail+'.txt';
                    Attc.setFileName(flename);
                    Attc.setBody(attachBlob);
                    Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
                    String subject = getTAG015()+' '+strNowDateMail;
                    email.setSubject(subject);
                    email.saveAsActivity = false;
                    email.setToAddresses(lstEmailIDs);
                    email.setPlainTextBody(strFinaLlogger);
                    email.setFileAttachments(new Messaging.EmailFileAttachment[]{Attc});
                    mails.add(email);
                    
                }
                else if(timeSheetRecordType != null && timeSheetRecordType.toUpperCase() == 'TIMESHEETAUTOFILL'){
                    String afstrLogPass = ''; 
                    String afstrAttachmentlog = '';
                    Integer autoFillcountSuccess = 0; 
                    Integer autoFillcountFailure = 0; 
                    for(User technicianRec: mapProcessUsers.get(svmxProcess.id)){
                        if(mapUserIDUserAutofillInfo != null && mapUserIDUserAutofillInfo.get(technicianRec.ID) != null){
                            UserAutofillInfo fetchUserAutofillInfo = mapUserIDUserAutofillInfo.get(technicianRec.ID); 
                            afstrAttachmentlog += '\n' + technicianRec.FirstName +' '+ technicianRec.LastName; 
                            /*Commented for BAC-4865 22nd May
                            afstrAttachmentlog += '\n' + getTAG017() +  fetchUserAutofillInfo.workDetailCount;
                            afstrAttachmentlog += '\n' + getTAG018() +  fetchUserAutofillInfo.taskCount;
                            afstrAttachmentlog += '\n' + getTAG019() +  fetchUserAutofillInfo.eventCount;
                            afstrAttachmentlog += '\n' + getTAG020() +  fetchUserAutofillInfo.svmxEventCount +'\n';
                            */
                            //Added for BAC-4865 22nd May
                            if(fetchUserAutofillInfo.workDetailCount > 0)
                                afstrAttachmentlog += '\n' + getTAG017() +  fetchUserAutofillInfo.workDetailCount;
                            if(fetchUserAutofillInfo.taskCount > 0)
                                afstrAttachmentlog += '\n' + getTAG018() +  fetchUserAutofillInfo.taskCount;
                            if(fetchUserAutofillInfo.eventCount > 0)
                                afstrAttachmentlog += '\n' + getTAG019() +  fetchUserAutofillInfo.eventCount;
                            if(fetchUserAutofillInfo.svmxEventCount > 0)
                                afstrAttachmentlog += '\n' + getTAG020() +  fetchUserAutofillInfo.svmxEventCount +'\n';
                            //End for BAC-4865 22nd May
                            if(fetchUserAutofillInfo.AutoFillStatus ==  getTAG007() || fetchUserAutofillInfo.AutoFillStatus == null){
                                autoFillcountSuccess ++ ;
                            }
                            else{ 
                                autoFillcountFailure ++ ;
                            }
                        }
                    }
                    
                    if(autoFillcountFailure > 0 && !svmxProcess.SVMXC__Email_On_Success__c.equalsIgnoreCase(svmxProcess.SVMXC__Email_On_Error__c))
                        lstEmailIDs.add(svmxProcess.SVMXC__Email_On_Error__c);
                    
                    afstrLogPass = afstrLogPass+'\n\t'+getTAG006()+': '+listUsersInProcess.size();
                    afstrLogPass = afstrLogPass+'\n\t'+getTAG007()+': '+autoFillcountSuccess;
                    afstrLogPass = afstrLogPass+'\n\t'+getTAG008()+': '+autoFillcountFailure;
                    
                    strlogger = strlogger+afstrLogPass;
                    
                    afstrAttachmentlog = strlogger+'\n=========================================================\n'+ afstrAttachmentlog;
                    strlogger = strlogger+strEndlog;
                    afstrAttachmentlog = afstrAttachmentlog+'\n=========================================================\n'+strEndlog;
                    
                    String afstrFinaLlogger = getTAG001()+'\n';
                    afstrFinaLlogger = afstrFinaLlogger+'\n'+getTAG016();
                    afstrFinaLlogger = afstrFinaLlogger+strlogger;
                    afstrFinaLlogger = afstrFinaLlogger+'\n\n'+getTAG010();
                    String afstrNowDateMail =  datetimeEnd.format('MM/dd/yyyy', tz.getID());
                    
                    //Added for BAC-4865 22nd May
                    if(listErrorDetails.size() > 0){ 
                        afstrAttachmentlog = afstrAttachmentlog +'\n=========================================================\n The error has occurred while processing: \n' +'Timesheet Batch Error Log at ' +System.Now().format()+'\n';
                        afstrFinaLlogger = afstrFinaLlogger +'\n=========================================================\n The error has occurred while processing: \n' +'Timesheet Batch Error Log at ' +System.Now().format()+'\n';
                        for(String errorStringVar: listErrorDetails){
                            afstrAttachmentlog = afstrAttachmentlog + '\n' + errorStringVar + '\n';
                            afstrFinaLlogger = afstrFinaLlogger+ '\n' + errorStringVar + '\n';
                        }
                    }
                    //End for BAC-4865
                    
                    Messaging.EmailFileAttachment Attc = new Messaging.EmailFileAttachment();
                    blob attachBlob = Blob.valueOf(afstrAttachmentlog);
                    string flename= getTAG014()+'_'+afstrNowDateMail+'.txt';
                    Attc.setFileName(flename);
                    Attc.setBody(attachBlob);
                    Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
                    String subject = getTAG021()+' '+afstrNowDateMail;
                    email.setSubject(subject);
                    email.saveAsActivity = false;
                    email.setToAddresses(lstEmailIDs);
                    email.setPlainTextBody(afstrFinaLlogger);
                    email.setFileAttachments(new Messaging.EmailFileAttachment[]{Attc});
                    mails.add(email);
                }
            }
            
            if(mails != null && mails.size() > 0)
                Messaging.sendEmail(mails);
        }
        catch(Exception ex)
        {
            system.debug(LoggingLevel.WARN, 'Email Exception: ' + ex.getMessage());
        }       
    }
    
    public List<SVMXC__Timesheet__c> createUserTimesheetHeader(User userRec, Map <Id, Id> mapUserandTMProcessTemp){
        SVMXC__ServiceMax_Processes__c timesheetProcessRec = timeSheetProcess.get(mapUserandTMProcessTemp.get(userRec.Id)); //BAC-4814/044977 used mapUserandTMProcessTemp
        SVMXC__ServiceMax_Config_Data__c configDataRec = mapTSProcessScheduler.get(mapUserandTMProcessTemp.get(userRec.Id)); //BAC-4814/044977 used mapUserandTMProcessTemp
        
        /*
        Logic - Input is always one user
        Method is expected to create 2 time sheet headers for the user. First time sheet is in the current period
        and the second one is in the next time period (week/month). It should handle scenarios where the job is run
        multiple times on the same day or within the same time period (week/month). It should also handle scenarios
        where the time sheet configuration was changed eg: customer moves from week wise to month wise.

        0. If the configuration of the time sheets has changed then we need to inactivate existing ones
        1. Determine current time frame and next 
        2. Check if the user has a timesheet record (irrespective of status) for the current and next time period
        3a. Possible scenarios - No current time sheet
        Create two time sheets one for current and one for next 
        3b. Possible scenarios - Yes current but no next 
        Create one time sheet for next

        */
        
        // 1. Determine current time frame and next 
        Integer startFromDate = Integer.valueOf(configDataRec.SVMXC__Period_Start_On__c); 
        calculateTimesheetHeaderStartDateEndDate(Startdate ,configDataRec, startFromDate, null);
        Date currentStartDateTimeFrame = Startdate; 
        Date currentEndDateTimeFrame = Enddate;
        Date nextStartDateTimeFrame = currentEndDateTimeFrame.addDays(1); 
        List<SVMXC__Timesheet__c> listUserTimesheetHeader  = new List<SVMXC__Timesheet__c>();    
        
        System.debug(LoggingLevel.WARN, 'Timesheet Header to be created only when Today >= Congigured Started Date  :' + Startdate + '---' + EndDate);
        if(Startdate >= timesheetProcessRec.SVMXC__Start_Date__c && EndDate <= timesheetProcessRec.SVMXC__End_Date__c){
            // 0 -  If the configuration of the time sheets has changed then we need to inactivate existing ones. Inactivate all open timesheets.
            List<SVMXC__Timesheet__c> existingUserTimeSheets = [SELECT SVMXC__User__c,  
                                                                SVMXC__Start_Date__c, 
                                                                SVMXC__End_Date__c,
                                                                SVMXC__Status__c, 
                                                                SVMXC__Period__c,
                                                                SVMXC__Submitted_On__c
                                                                FROM SVMXC__Timesheet__c 
                                                                WHERE SVMXC__Status__c =: TMST_Consts.STRING_OPEN AND SVMXC__User__c = :userRec.Id];
            
            List <SVMXC__Timesheet__c> listInvalidTimesheets = new List <SVMXC__Timesheet__c>();
            for(SVMXC__Timesheet__c configPeriodModified : existingUserTimeSheets){
                if(configPeriodModified.SVMXC__Period__c != configDataRec.SVMXC__Period__c){
                    configPeriodModified.SVMXC__Status__c = 'Invalid';
                    listInvalidTimesheets.add(configPeriodModified);
                }
            }
            
            if(listInvalidTimesheets != null && listInvalidTimesheets.size() >0)
                update listInvalidTimesheets;
            
            List<String> lstHeaderStatusValues = String.isNotBlank(configDataRec.SVMXC__Internal_Value__c) 
                ? configDataRec.SVMXC__Internal_Value__c.split(',') 
                : new List<String>{TMST_Consts.STRING_OPEN}; //Added for BAC-5411
            //Commented SVMXC__Status__c = 'Open' and added SVMXC__Status__c IN:lstHeaderStatusValues to SOQL  for BAC-5411
            List<SVMXC__Timesheet__c> timesheetTimeframe = [SELECT SVMXC__User__c,  
                                                            SVMXC__Start_Date__c, 
                                                            SVMXC__End_Date__c,
                                                            SVMXC__Status__c, 
                                                            SVMXC__Period__c,
                                                            SVMXC__Submitted_On__c
                                                            FROM SVMXC__Timesheet__c 
                                                            WHERE SVMXC__Status__c IN:lstHeaderStatusValues AND SVMXC__User__c = :userRec.Id AND ((SVMXC__Start_Date__c <= :currentStartDateTimeFrame AND SVMXC__End_Date__c >= :currentStartDateTimeFrame ) 
                                                                                                                                  OR (SVMXC__Start_Date__c <= :nextStartDateTimeFrame AND SVMXC__End_Date__c >= :nextStartDateTimeFrame) )];
            
            System.debug(LoggingLevel.WARN, 'No of Timesheet Headers present for User  :' + userRec.FirstName + ' - '+ timesheetTimeframe.size());
            
            List<SVMXC__Timesheet__c> listCurrentTimesheet = new List<SVMXC__Timesheet__c>();
            List<SVMXC__Timesheet__c> listNextTimesheet = new List<SVMXC__Timesheet__c>();
            for(SVMXC__Timesheet__c configPeriodModified : timesheetTimeframe){
                if(configPeriodModified.SVMXC__Start_Date__c <= currentStartDateTimeFrame && configPeriodModified.SVMXC__End_Date__c >= currentStartDateTimeFrame){
                    listCurrentTimesheet.add(configPeriodModified);
                }
                
                if(configPeriodModified.SVMXC__Start_Date__c <= nextStartDateTimeFrame && configPeriodModified.SVMXC__End_Date__c >= nextStartDateTimeFrame){
                    listNextTimesheet.add(configPeriodModified); 
                }
            }
            
            System.debug(LoggingLevel.WARN, 'Existing Timesheet header for User  :' + userRec.FirstName + ' - '+ listCurrentTimesheet.size());
            //System.debug(LoggingLevel.WARN, 'Future Timesheet header for User  :' + userRec.FirstName + ' - '+ listNextTimesheet.size());
            
            // If the User already have current timesheetHeader, then create only next one
            if(listCurrentTimesheet != null && listCurrentTimesheet.size() > 0){
                if(listNextTimesheet == null || listNextTimesheet.size() == 0){
                    calculateTimesheetHeaderStartDateEndDate(listCurrentTimesheet[0].SVMXC__End_Date__c ,configDataRec, 1, null);
                    SVMXC__Timesheet__c createTimesheetHeader =  new SVMXC__Timesheet__c();
                    createTimesheetHeader.SVMXC__Start_Date__c = Startdate; 
                    createTimesheetHeader.SVMXC__End_Date__c = Enddate;
                    createTimesheetHeader.SVMXC__Status__c = TMST_Consts.STRING_OPEN;
                    createTimesheetHeader.SVMXC__User__c = userRec.Id;
                    createTimesheetHeader.OwnerID = userRec.Id;
                    createTimesheetHeader.SVMXC__Period__c = configDataRec.SVMXC__Period__c;
                    Id BusinessHoursId ;
                    
                    
                    // If the user assosiated to Timesheet is a Technician, then get Technician Business Hours
                    // Else Use the Timesheet Process Business Hours, if this is also null, use Org Default Business Hours.
                    if(mapUserTechnician != null && mapUserTechnician.size() >0 && mapUserTechnician.get(userRec.Id) != null && mapUserTechnician.get(userRec.Id).SVMXC__Working_Hours__c != null && mapUserTechnician.get(userRec.Id).SVMXC__Working_Hours__r.IsActive){
                        BusinessHoursId = mapUserTechnician.get(userRec.Id).SVMXC__Working_Hours__c;
                    }
                    else if(timesheetProcessRec.SVMXC__Business_Hours__c != null && timesheetProcessRec.SVMXC__Business_Hours__r.isActive){
                        BusinessHoursId = timesheetProcessRec.SVMXC__Business_Hours__c;
                    }else{
                        BusinessHoursId = defaultBusinessHours.Id;
                    }
                    
                    createTimesheetHeader.SVMXC__SM_Business_Hours__c = BusinessHoursId; 
                    listUserTimesheetHeader.add(createTimesheetHeader);
                }
            }
            
            if(listCurrentTimesheet == null || listCurrentTimesheet.size() == 0 ){
                for(integer j=0; j <= 1 ; j++){  
                    if(EndDate <= timesheetProcessRec.SVMXC__End_Date__c){
                        //Added for 044977 
                        if(j==0)
                            calculateTimesheetHeaderStartDateEndDateforNewUser(Startdate ,configDataRec, startFromDate, null);  
                        //Added for 044977 
                        SVMXC__Timesheet__c createTimesheetHeader =  new SVMXC__Timesheet__c();
                        createTimesheetHeader.SVMXC__Start_Date__c = Startdate;
                        createTimesheetHeader.SVMXC__End_Date__c = Enddate;
                        createTimesheetHeader.SVMXC__Status__c = TMST_Consts.STRING_OPEN;
                        createTimesheetHeader.SVMXC__User__c = userRec.Id;
                        createTimesheetHeader.OwnerID = userRec.Id;
                        createTimesheetHeader.SVMXC__Period__c = configDataRec.SVMXC__Period__c;
                        Id BusinessHoursId ;
                        if(mapUserTechnician != null && mapUserTechnician.size() >0 && mapUserTechnician.get(userRec.Id) != null && mapUserTechnician.get(userRec.Id).SVMXC__Working_Hours__c != null && mapUserTechnician.get(userRec.Id).SVMXC__Working_Hours__r.IsActive){
                            BusinessHoursId = mapUserTechnician.get(userRec.Id).SVMXC__Working_Hours__c;
                        }
                        else if(timesheetProcessRec.SVMXC__Business_Hours__c != null && timesheetProcessRec.SVMXC__Business_Hours__r.isActive){
                            BusinessHoursId = timesheetProcessRec.SVMXC__Business_Hours__c;
                        }else{
                            BusinessHoursId = defaultBusinessHours.Id;
                        }
                        createTimesheetHeader.SVMXC__SM_Business_Hours__c = BusinessHoursId; 
                        listUserTimesheetHeader.add(createTimesheetHeader); 
                    }
                    
                    if (configDataRec.SVMXC__Period__c.equalsIgnoreCase('bi-monthly')){
                        calculateTimesheetHeaderStartDateEndDate(Enddate ,configDataRec, 1, Startdate);
                    }
                    else{
                        calculateTimesheetHeaderStartDateEndDate(Enddate ,configDataRec, 1, null); 
                    }
                }
            }
            
            Startdate = Date.today(); 
            mapUserIDTimesheetHeader.put(userRec.Id, listUserTimesheetHeader);
            return listUserTimesheetHeader;
        }
        
        return null;
    }
    
    /*
    Method is used explicity to calculate the Start Date and End Date of Timesheet header.
    */
    public void calculateTimesheetHeaderStartDateEndDate(Date startDatepassed, SVMXC__ServiceMax_Config_Data__c configDataRec, Integer startFromDate, Date biMonthlyStartDate){
        Startdate = startDatepassed.addDays(startFromDate);
        
        //Story BAC-549: 
        //For monthly - use salesforce addMonths method
        //For Bi-monthly - Add 15 days for the 1st timesheet header, for 2nd timesheet header add 16 days. 
        
        if(configDataRec.SVMXC__Period__c.equalsIgnoreCase('weekly')){
            Integer endToDate = Integer.valueOf(configDataRec.SVMXC__Period_End_On__c);
            Enddate =  Startdate.addDays(endToDate) ;
        }
        else if (configDataRec.SVMXC__Period__c.equalsIgnoreCase('monthly')){
            Enddate =  Startdate.addMonths(1) ;
            Enddate = Enddate.addDays(-1);
        }
        else if (configDataRec.SVMXC__Period__c.equalsIgnoreCase('bi-monthly')){
            if(biMonthlyStartDate != null){
                Enddate = biMonthlyStartDate.addMonths(1);
                Enddate = Enddate.addDays(-1);
            }
            else{
                Enddate = Startdate.addDays(14);
            }
        }
    }
    /*
    Method is used explicity to calculate the Start Date and End Date of Timesheet header.
    */
    public void calculateTimesheetHeaderStartDateEndDateforNewUser(Date startDatepassed, SVMXC__ServiceMax_Config_Data__c configDataRec, Integer startFromDate, Date biMonthlyStartDate){
        List<String> weekDays = new List<String>();
        if(configDataRec.SVMXC__Schedule_Days__c != null)
            weekDays = configDataRec.SVMXC__Schedule_Days__c.split(';');
        if(weekDays.size() == 1 && configDataRec.SVMXC__Period__c.equalsIgnoreCase('weekly')){
            Startdate = startDatepassed.addDays(-startDateforTimesheet(configDataRec, weekDays));
            
            
            //System.debug('calculateTimesheetHeaderStartDateEndDate configDataRec '+configDataRec);
            //Story BAC-549: 
            //For monthly - use salesforce addMonths method
            //For Bi-monthly - Add 15 days for the 1st timesheet header, for 2nd timesheet header add 16 days. 
            
            if(configDataRec.SVMXC__Period__c.equalsIgnoreCase('weekly')){
                Integer endToDate = Integer.valueOf(configDataRec.SVMXC__Period_End_On__c);
                Enddate =  Startdate.addDays(endToDate) ;
            }
            else if (configDataRec.SVMXC__Period__c.equalsIgnoreCase('monthly')){
                Enddate =  Startdate.addMonths(1) ;
                Enddate = Enddate.addDays(-1);
            }
            else if (configDataRec.SVMXC__Period__c.equalsIgnoreCase('bi-monthly')){
                if(biMonthlyStartDate != null){
                    Enddate = biMonthlyStartDate.addMonths(1);
                    Enddate = Enddate.addDays(-1);
                }
                else{
                    Enddate = Startdate.addDays(14);
                }
            }
        }
    }
    
    public Integer startDateforTimesheet(SVMXC__ServiceMax_Config_Data__c configDataRec, List<String> weekDays){
        Integer newStartDate;
        
        String theRundateofWeek = weekDays.get(weekDays.size()-1);
        //System.debug('theRundateofWeek '+theRundateofWeek);
        Datetime dt = System.now();
        String dayOfWeek = dt.format('EEEE', configDataRec.SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Timezone__c); 
        
        System.debug('theRundateofWeek '+theRundateofWeek +' dayOfWeek '+dayOfWeek);
        newStartDate = calculateDatebetweenTwoWeekdays(theRundateofWeek, dayOfWeek);
        //System.debug('newStartDate ' +newStartDate);
        return newStartDate;
    }
    //Method two calculate date difference between two weekday
    public Integer calculateDatebetweenTwoWeekdays(String startWeekDay, String endWeekDay){
        List<String> allWeekDays = new List<String>{'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'};
            Integer cont;
        Boolean flg = false;
        if(startWeekDay.equalsIgnoreCase(endWeekDay))
            return 0;
        for(String s: allWeekDays){
            if(s.equalsIgnoreCase(startWeekDay)){
                cont = 0;
                flg = true;
            }
            if(flg){
                
                if(s.equalsIgnoreCase(endWeekDay)){
                    return cont;
                }
                cont++;
            }
        }
        return 0;
    }
    /*
    Method is used to get the qualified Timesheet header and details for a given set of users.
    */
    public void getTimesheetHeaderandDetailsforUsers(Map<Id, Id> mapUserandTMProcessTemp,Map<Id, List<User>> mapProcessUsersTempVal){
        //Below code moved from start method BAC-4814/044977
        Map<Id, Map<String, String>> mapProcessExpressions = new Map<Id, Map<String, String>>();
        Integer numPeriods = 0; 
        Date dxs = System.today(); //TODO proper variable name
        Date dxe = System.today();
        if(timeSheetRecordType != null && timeSheetRecordType.toUpperCase()  == 'TIMESHEETAUTOFILL'){ 
            //System.debug(LoggingLevel.WARN, 'Processed only when Timesheet Schedule Type is ' + timeSheetRecordType);
            
            for(SVMXC__ServiceMax_Processes__c autoFillRecords : timeSheetProcess.values()){
                Boolean doAutofill = mapTSProcessScheduler.get(autoFillRecords.id).SVMXC__Active__c;
                
                //get number of prior period timesheets to process
                if(Test.isRunningTest())
                    numPeriods = 0;
                else
                {
                    //set no. of prior periods to 0 if it is blank,(example, as for existing autofill config records)
                    if(String.isBlank(String.valueOf(mapTSProcessScheduler.get(autoFillRecords.id).SVMXC__SM_Prior_Timesheet_Periods__c)))
                        numPeriods = 0;
                    else
                        numPeriods = Integer.ValueOf(mapTSProcessScheduler.get(autoFillRecords.id).SVMXC__SM_Prior_Timesheet_Periods__c); 
                }
                System.debug(LoggingLevel.WARN, 'Number of prior timesheet autofills to process: ' + numPeriods);
                if(doAutofill){
                    Map<String, ID > listObjectMapping = new Map<String, ID >();
                    List<ID> listExpression = new List <ID>();
                    Map<String, String> mapObjectandExpression = new Map<String, String>();
                    
                    // As a set up, Process1 (WO), Process2(Task), Prcoess3(Event), Module(SVMX Event) will have all the object Mappings
                    if(autoFillRecords.SVMXC__Process1__c !=  null){
                        listObjectMapping.put(autoFillRecords.SVMXC__Process1__r.SVMXC__Source_Object_Name__c, autoFillRecords.SVMXC__Process1__c );
                    }
                    if(autoFillRecords.SVMXC__Process2__c !=  null){
                        listObjectMapping.put(autoFillRecords.SVMXC__Process2__r.SVMXC__Source_Object_Name__c, autoFillRecords.SVMXC__Process2__c );
                    }
                    if(autoFillRecords.SVMXC__Process3__c !=  null){
                        listObjectMapping.put(autoFillRecords.SVMXC__Process3__r.SVMXC__Source_Object_Name__c, autoFillRecords.SVMXC__Process3__c);
                    }
                    if(autoFillRecords.SVMXC__Module__c !=  null){
                        listObjectMapping.put(autoFillRecords.SVMXC__Module__r.SVMXC__Source_Object_Name__c, autoFillRecords.SVMXC__Module__c);
                    }
                    
                    if(listObjectMapping != null && listObjectMapping.size() > 0)
                        mapProcessObjectMapping.put(autoFillRecords.Id, listObjectMapping);
                    
                    // As a set up, Process(WO Expression), Node parent (task Expression), Parent Object (Event Expression), SVMXC__Submodule__c (SVMX Event Expression)
                    if(autoFillRecords.SVMXC__Process__c != null)
                        listExpression.add(autoFillRecords.SVMXC__Process__c);
                    if(autoFillRecords.SVMXC__Parent_Object__c != null)
                        listExpression.add(autoFillRecords.SVMXC__Parent_Object__c);
                    if(autoFillRecords.SVMXC__Node_Parent__c != null)
                        listExpression.add(autoFillRecords.SVMXC__Node_Parent__c);
                    if(autoFillRecords.SVMXC__Submodule__c != null)
                        listExpression.add(autoFillRecords.SVMXC__Submodule__c);
                    
                    
                    for(SVMXC__ServiceMax_Processes__c listRule : [SELECT SVMXC__Source_Object_Name__c,
                                                                   SVMXC__Advance_Expression__c,
                                                                   SVMXC__Parent_Object_Criteria__c
                                                                   FROM SVMXC__ServiceMax_Processes__c
                                                                   WHERE Id IN :listExpression AND RecordType.Name = 'SVMX Rule']){
                                                                       mapObjectandExpression.put(listRule.SVMXC__Source_Object_Name__c, listRule.SVMXC__Parent_Object_Criteria__c);
                                                                   }  
                    
                    if(mapObjectandExpression != null && mapObjectandExpression.size() > 0)
                        mapProcessExpressions.put(autoFillRecords.Id, mapObjectandExpression);
                }
            }
            System.debug(LoggingLevel.WARN, 'Expressions passed in Servicemax Process ' + mapProcessExpressions.size());
            System.debug(LoggingLevel.WARN, 'Object Mappings passed in Servicemax Process ' + mapProcessObjectMapping.size());
            
            Map<Id, ID> mapTimesheetEntryWOentries = new Map<Id, Id>();
            Map<Id, ID> mapTimesheetEntrySVMXEvents = new Map<Id, ID>();
            Map<Id, ID> mapTimesheetEntrySFEvents = new Map<Id, ID>();
            Map<Id, ID> mapTimesheetEntrySFTasks = new Map<Id, ID>(); 
            List <Id> listLatestUserTS = new List <Id>();
            
            Integer numLimit = numPeriods+1; //no.of prior periods + 1 for current timesheet    
            Date dtStrtDtLimit =  Startdate.addMonths(-numLimit) ;//take the oldest possible prior startdate
            
            List<User> usersRecentTSList = [SELECT Id, Username,
                                            (SELECT Id,SVMXC__End_Date__c,SVMXC__Start_Date__c 
                                             FROM SVMXC__TimeSheets__r 
                                             WHERE SVMXC__Status__c =: TMST_Consts.STRING_OPEN  
                                             AND SVMXC__Start_Date__c <= :Startdate 
                                             AND SVMXC__Start_Date__c >= :dtStrtDtLimit
                                             ORDER BY SVMXC__Start_Date__c DESC 
                                             LIMIT :numLimit
                                            )
                                            FROM User
                                            WHERE Id IN :mapUserandTMProcessTemp.keyset()];
            if(usersRecentTSList != null && usersRecentTSList.size() > 0){
                
                //logic to get the oldest start date to determine condition for fetching valid open timesheet headers  
                
                for(User u:usersRecentTSList)
                {
                    for(SVMXC__TimeSheet__c t:u.SVMXC__TimeSheets__r)
                    {
                        // Defect Fix 044981
                        if(t.SVMXC__Start_Date__c<=dxs ){
                            dxs = t.SVMXC__Start_Date__c;
                        }
                        if(t.SVMXC__End_Date__c>= dxe){
                            dxe = t.SVMXC__End_Date__c;
                        } 
                        listLatestUserTS.add(t.id);                             
                    }
                }
                
                
                Integer intDays = dxs.daysBetween(dxe);
                if(intDays<=7 && intDays>0) //weekly
                    dtStrtDtLimit = dxs.addDays(-7*numLimit);
                else if (intDays > 20) //monthly
                {
                    dtStrtDtLimit = dxs.addDays(-28*numlimit);
                }
                else if(intDays > 10) //bimonthly    
                    dtStrtDtLimit = dxs.addDays(-16*numLimit);
                
                
            }
            System.debug('dxs = '+dxs);   
            System.debug('dxe = '+dxe); 
            System.debug('Limits.getCpuTime - '+ Limits.getCpuTime());
            //SOQL fetches all valid Timesheet headers for given input conditions
            //Added SVMXC__SM_Business_Hours__r.TimeZoneSidKey field to SOQL for BAC-4851
            //Added SVMXC__SM_Time_Zone__c to soql for BAC-5562
            List<SVMXC__Timesheet__c> openTimesheetheader = [SELECT Id, SVMXC__SM_Business_Hours__r.TimeZoneSidKey, SVMXC__Total_Hours__c, SVMXC__SM_Business_Hours__c,(SELECT SVMXC__Timesheet__c, SVMXC__Start_Time__c, SVMXC__End_Time__c, SVMXC__Salesforce_Event__c, SVMXC__ServiceMax_Event__c, SVMXC__Task__c, SVMXC__Work_Detail__c, SVMXC__Duration__c, SVMXC__SM_Time_Zone__c FROM SVMXC__Time_Sheet_Entries__r), (SELECT SVMXC__Timesheet__c, SVMXC__Timsheet_Day__c , SVMXC__IsHoliday__c,SVMXC__Total_Hours__c FROM SVMXC__Timesheet_Day_Entries__r), SVMXC__User__r.id, SVMXC__Start_Date__c, SVMXC__End_Date__c from SVMXC__Timesheet__c WHERE ID IN :listLatestUserTS and SVMXC__Start_Date__c >= :dtStrtDtLimit and SVMXC__Status__c =: TMST_Consts.STRING_OPEN]; 
            if(openTimesheetheader != null && openTimesheetheader.size() > 0)
            {   
                List<SVMXC__Timesheet_Entry__c> lstTimeSheetEntry = new List<SVMXC__Timesheet_Entry__c>();
                Date openTSStartDate = System.today(); // Added for BAC-5324
                for(SVMXC__Timesheet__c listOfOpenTimesheetHeader : openTimesheetheader)
                {
                    
                    maptimesheetHeaderId.put(listOfOpenTimesheetHeader.Id, listOfOpenTimesheetHeader);  
                    mapTimesheetHeaderandTimesheetDayEntry.put(listOfOpenTimesheetHeader.Id, listOfOpenTimesheetHeader.SVMXC__Timesheet_Day_Entries__r); 
                    //mapUserTimesheetHeaderRec.put(listOfOpenTimesheetHeader.id,listOfOpenTimesheetHeader.SVMXC__User__r.Id);
                    mapTimesheetHeaderEntries.put(listOfOpenTimesheetHeader.Id, listOfOpenTimesheetHeader.SVMXC__Time_Sheet_Entries__r); 
                    lstTimeSheetEntry.addAll(listOfOpenTimesheetHeader.SVMXC__Time_Sheet_Entries__r);
                    
                    
                    if(!mapUserTimesheetHeaders.containsKey(listOfOpenTimesheetHeader.SVMXC__User__r.Id))
                        mapUserTimesheetHeaders.put(listOfOpenTimesheetHeader.SVMXC__User__r.Id, new List<Id>());
                    mapUserTimesheetHeaders.get(listOfOpenTimesheetHeader.SVMXC__User__r.Id).add(listOfOpenTimesheetHeader.Id);
                    if(openTSStartDate > listOfOpenTimesheetHeader.SVMXC__Start_Date__c){ // Added for BAC-5324
                        openTSStartDate = listOfOpenTimesheetHeader.SVMXC__Start_Date__c;
                    }   
                    
                }
                dtStrtDtLimit = openTSStartDate; // Added for BAC-5324
                for(SVMXC__Timesheet_Entry__c timesheetEntryRec : lstTimeSheetEntry) {
                    if(timesheetEntryRec.SVMXC__Work_Detail__c !=  null){
                        mapTimesheetEntryWOentries.put(timesheetEntryRec.SVMXC__Work_Detail__c, timesheetEntryRec.SVMXC__Timesheet__c);
                    }
                    
                    if(timesheetEntryRec.SVMXC__ServiceMax_Event__c != null){
                        mapTimesheetEntrySVMXEvents.put(timesheetEntryRec.SVMXC__ServiceMax_Event__c, timesheetEntryRec.SVMXC__Timesheet__c);
                    }
                    
                    if(timesheetEntryRec.SVMXC__Salesforce_Event__c != null){
                        mapTimesheetEntrySFEvents.put(timesheetEntryRec.SVMXC__Salesforce_Event__c, timesheetEntryRec.SVMXC__Timesheet__c); 
                    }
                    
                    
                    if(timesheetEntryRec.SVMXC__Task__c != null){
                        mapTimesheetEntrySFTasks.put(timesheetEntryRec.SVMXC__Task__c, timesheetEntryRec.SVMXC__Timesheet__c); 
                    } 
                }
            }
            // End BAC-4543/044977
            System.debug(LoggingLevel.WARN, 'Open Timesheet Header details for the Users ' + maptimesheetHeaderId.size());
            System.debug(LoggingLevel.WARN, 'List of Timesheet Entries for Open Timesheet Header ' + mapTimesheetHeaderandTimesheetDayEntry.size());
            
            String ownership ; 
            Boolean isReferenced = false;
            for(Id processId : mapProcessUsersTempVal.keyset()){
                //Added for BAC-4866
                Map<String, Set<SVMXC__Service_Order_Line__c>> mapUserWODLine = new Map<String, Set<SVMXC__Service_Order_Line__c>>();
                Map<Id, Set<Task>> mapUserTask = new Map<Id, Set<Task>>();
                Map<Id, Set<Event>> mapUserSFEvents = new Map<Id, Set<Event>>();
                Map<Id, Set<SVMXC__SVMX_Event__c>> mapUserSVMXEvents = new Map<Id, Set<SVMXC__SVMX_Event__c>>();
                //Added for BAC-4866
                List<User> processRecordsForListOFUsers =  mapProcessUsersTempVal.get(processId);
                Map<String, String> objectExpressions  = mapProcessExpressions.get(processId);
                
                String eventTypeForProcess = timeSheetProcess.get(processId).SVMXC__Event_Type__c;
                String getTimeZoneFrom = timeSheetProcess.get(processId).SVMXC__SM_Business_Hour_Source__c != null ? timeSheetProcess.get(processId).SVMXC__SM_Business_Hour_Source__c : 'Technician Record'; // Added for BAC-5388
                //To Do : Check if there is a mapping avaialble for WO, Task, Event/SVMX Event
                String fieldName = timeSheetProcess.get(processId).SVMXC__Field_Name__c;
                //System.debug(LoggingLevel.WARN, 'Work Detail Ownership defined by Autofill ' + fieldName);
                if(fieldName != null && fieldName != ''){
                    Map<String, Schema.SObjectField> M = Schema.SObjectType.SVMXC__Service_Order_Line__c.fields.getMap();
                    List<Schema.SObjectType> technicianObj = M.get(fieldName.toLowerCase()).getDescribe().getReferenceTo();
                    if(String.valueOf(technicianObj[0]).equalsIgnoreCase('SVMXC__SERVICE_GROUP_MEMBERS__C')){
                        ownership =  fieldName.substringBefore('__c')+'__r.SVMXC__Salesforce_User__c';
                        isReferenced = true;
                    }
                    else{
                        ownership =  fieldName;  
                    }
                }     
                
                //System.debug(LoggingLevel.WARN, 'Work Detail Ownership defined by Autofill ' + ownership);
                
                /*The problem faced is: We need to query WO Line/Task/Event records only for the latest Timesheetheader for a Configuration Process.
                All the users related to particular Timesheet Configuration process will have same type of timesheet Header. 
                Therefore, get one user to identify the start date and end date. This user should have all available timesheet headers created ie have
                max number of Timesheet headers open*/
                
                User userTimesheetHeader = processRecordsForListOFUsers.get(0);
                
                Date timesheetStartDate =system.today();
                Date timesheetEnddate =system.today(); 
                Map<Date, Date> mapTSstartEndDates =new Map<Date, Date>();
                List<Id> lstTH = new List<Id>();
                Integer k = 0;
                
                for(User u:processRecordsForListOFUsers)
                {
                    if((mapUserTimesheetHeaders.get(u.id)!=null) && (k < mapUserTimesheetHeaders.get(u.id).size()))
                    {
                        userTimesheetHeader = u;
                        k = mapUserTimesheetHeaders.get(u.id).size();
                    }
                }
                
                if(mapUserTimesheetHeaders.get(userTimesheetHeader.id) != null)
                {
                    for(id idd:mapUserTimesheetHeaders.get(userTimesheetHeader.id))
                    {
                        mapTSstartEndDates.put(maptimesheetHeaderId.get(idd).SVMXC__Start_Date__c, maptimesheetHeaderId.get(idd).SVMXC__End_Date__c);                     
                    }
                }
                
                /**  Defect fix - 020830
                RC - While comparing the start and end date, consider only Date value using DAY_ONLY() method. 
                Similar change is done to Salesforce event, Servicemax event and work detail
                BAC-1276:sourabh:9dec2016: updated SOQLs for Work Detail, Task, Event, SVMX Event to consider prior time periods
                **/
                 //Added SVMXC__Service_Order__r.SVMXC__Preferred_Business_Hours__r.TimeZoneSidKey to (woQuery and SVMXEventQuery) and WhatId to (taskQuery and SFEventQuery) for BAC-5388
                String woQuery =   'Select Id, SVMXC__Service_Order__r.SVMXC__Preferred_Business_Hours__r.TimeZoneSidKey, SVMXC__Start_Date_and_Time__c,SVMXC__End_Date_and_Time__c, '+ ownership +' FROM SVMXC__Service_Order_Line__c WHERE ' + ownership +' IN :processRecordsForListOFUsers '; 
                String taskQuery = 'Select Id, WhatId, ActivityDate, OwnerId FROM Task WHERE OwnerId IN :processRecordsForListOFUsers ';
                String SFEventQuery ='Select Id, WhatId, StartDateTime,EndDateTime, DurationInMinutes, OwnerId FROM Event WHERE OwnerId IN :processRecordsForListOFUsers ';
                String SVMXEventQuery ='Select Id, SVMXC__Service_Order__r.SVMXC__Preferred_Business_Hours__r.TimeZoneSidKey, SVMXC__DurationInMinutes__c, SVMXC__StartDateTime__c,SVMXC__EndDateTime__c, SVMXC__Technician__r.Salesforce_User__c FROM SVMXC__SVMX_Event__c WHERE SVMXC__Technician__r.Salesforce_User__c IN :processRecordsForListOFUsers ';
                
                
                
                woQuery +=  ' AND (DAY_ONLY(SVMXC__Start_Date_and_Time__c) >= :dtStrtDtLimit AND DAY_ONLY(SVMXC__End_Date_and_Time__c) <= :dxe) ';
                taskQuery +=  ' AND (ActivityDate >= :dtStrtDtLimit AND ActivityDate <= :dxe) ' ;
                SFEventQuery +=  ' AND (DAY_ONLY(StartDateTime) >= :dtStrtDtLimit  AND DAY_ONLY(EndDateTime) <= :dxe) ' ;
                SVMXEventQuery +=  ' AND (DAY_ONLY(SVMXC__StartDateTime__c) >= :dtStrtDtLimit AND DAY_ONLY(SVMXC__EndDateTime__c) <= :dxe) ' ;
                
                system.debug('dtStrtDtLimit = '+ dtStrtDtLimit);
                system.debug('dxs = '+ dxs);
                
                
                if(objectExpressions != null && objectExpressions.get('SVMXC__Service_Order_Line__c') != null)
                    woQuery += ' AND ('+ objectExpressions.get('SVMXC__Service_Order_Line__c')+')'; 
                //TODO: No Duration Field in WODetail & Task 
                
                if(mapTimesheetEntryWOentries != null && mapTimesheetEntryWOentries.size() > 0){
                    Set <ID> lstWOLine = mapTimesheetEntryWOentries.keyset(); 
                    woQuery +=' AND Id NOT IN : lstWOLine';
                } 
                
                if(objectExpressions != null && objectExpressions.get('Task') != null)
                    taskQuery += ' AND ('+ objectExpressions.get('Task')+')'; 
                
                if(mapTimesheetEntrySFTasks != null && mapTimesheetEntrySFTasks.size() > 0){
                    Set <ID> lsttask = mapTimesheetEntrySFTasks.keyset();
                    taskQuery +=' AND Id NOT IN : lsttask';
                }   
                
                if(objectExpressions != null && objectExpressions.get('Event') != null)
                    SFEventQuery += ' AND ('+ objectExpressions.get('Event')+')';
                
                if(mapTimesheetEntrySFEvents != null && mapTimesheetEntrySFEvents.size() > 0){
                    Set <ID> listSFEvents = mapTimesheetEntrySFEvents.keyset();
                    SFEventQuery +=' AND Id NOT IN : listSFEvents';
                }
                
                if(objectExpressions != null && objectExpressions.get('SVMXC__SVMX_Event__c') != null)
                    SVMXEventQuery += ' AND ('+ objectExpressions.get('SVMXC__SVMX_Event__c')+')';
                
                if(mapTimesheetEntrySVMXEvents != null && mapTimesheetEntrySVMXEvents.size() > 0){
                    Set <ID> lstSVMXEvents = mapTimesheetEntrySVMXEvents.keyset();
                    SVMXEventQuery +='AND Id NOT IN : lstSVMXEvents';  
                }
                
                System.debug(LoggingLevel.WARN,'the SOQL for WD lines woQuery= '+woQuery);
                System.debug(LoggingLevel.WARN,'the SOQL for task lines taskQuery= '+taskQuery);
                System.debug(LoggingLevel.WARN,'the SOQL for events lines SFEventQuery= '+SFEventQuery);
                System.debug(LoggingLevel.WARN,'the SOQL for svmx event lines SVMXEventQuery= '+SVMXEventQuery);
                
                if(ownership != null)
                {  
                    //System.debug(LoggingLevel.WARN,'processRecordsForListOFUsers= '+processRecordsForListOFUsers);
                    
                    List<SVMXC__Service_Order_Line__c> userWOLIneList = Database.query(woQuery); 
                    System.debug(LoggingLevel.WARN, 'Work Details for which there is no Entry in Timesheet Entry ' + userWOLIneList.size());
                    
                    if(userWOLIneList != null && userWOLIneList.size() > 0)
                    {
                        for(SVMXC__Service_Order_Line__c userWODLine: userWOLIneList)
                        {
                            String ownershipId; 
                            if(isReferenced)
                            { 
                                ownershipId = String.valueof(userWODLine.SVMXC__Group_Member__r.SVMXC__Salesforce_User__c);
                            }
                            else{
                                ownershipId = String.valueof(userWODLine.get(ownership));
                            }
                            //system.debug(ownershipId + mapUserWODLine);
                            
                            if(mapUserWODLine != null && mapUserWODLine.size() > 0 && mapUserWODLine.get(ownershipId) != null)
                            {
                                mapUserWODLine.get(ownershipId).add(userWODLine);     
                            } 
                            else{
                                Set<SVMXC__Service_Order_Line__c> setWoLines = new Set<SVMXC__Service_Order_Line__c>();
                                setWoLines.add(userWODLine);
                                mapUserWODLine.put(ownershipId, setWoLines);
                            }
                        }
                    }
                    
                    //System.debug(LoggingLevel.WARN, 'Work Detail per User ' + mapUserWODLine);
                    
                    List<SVMXC__Service_Order_Line__c> lstWOSLine;
                    Set<SVMXC__Service_Order_Line__c> setSSOLine;
                    if(mapUserWODLine.size() > 0){ //Added for BAC-4866
                        for(SVMXC__Timesheet__c t : openTimesheetheader)//for each open TS header
                        {
                            String timeZoneforTSHeader = maptimesheetHeaderId.get(t.id).SVMXC__SM_Business_Hours__c != null ? maptimesheetHeaderId.get(t.id).SVMXC__SM_Business_Hours__r.TimeZoneSidKey : UserInfo.getTimeZone().getID();// Added for BAC-4851
                            lstWOSLine = new List<SVMXC__Service_Order_Line__c>();
                            for(SVMXC__Service_Order_Line__c uwl: userWOLIneList)
                            {
                                setSSOLine = mapUserWODLine.get(t.SVMXC__User__r.Id); 
                                //Added for BAC-5388  and BAC-5504
                                if(getTimeZoneFrom.equalsIgnoreCase(woBusinessHour)){
                                    if(uwl.SVMXC__Service_Order__c == null || uwl.SVMXC__Service_Order__r.SVMXC__Preferred_Business_Hours__c == null){ //Changed && to || for BAC-5502
                                        continue;
                                    }
                                    timeZoneforTSHeader = uwl.SVMXC__Service_Order__r.SVMXC__Preferred_Business_Hours__r.TimeZoneSidKey;
                                    UserTimezoneInfo userTZVar = new UserTimezoneInfo();
                                    userTZVar.businessHourId = uwl.SVMXC__Service_Order__r.SVMXC__Preferred_Business_Hours__c;
                                    userTZVar.timeZoneValue = timeZoneforTSHeader;
                                    mapRecordsWithTimezone.put(uwl.id,userTZVar);
                                }
                                // end for BAC-5388
                                // Added for BAC-4851
                                if(setSSOLine!=null)
                                {           
                                    if(setSSOLine.contains(uwl) && date.valueOf(uwl.SVMXC__Start_Date_and_Time__c.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)) >= t.SVMXC__Start_Date__c && date.valueOf(uwl.SVMXC__End_Date_and_Time__c.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)) <= t.SVMXC__End_Date__c)
                                    {
                                        lstWOSLine.add(uwl);    
                                    }else if( // Added for 045467
                                        setSSOLine.contains(uwl) 
                                        && checkDatesBetweenTSHeaders(date.valueOf(uwl.SVMXC__Start_Date_and_Time__c.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)), t.SVMXC__Start_Date__c, t.SVMXC__End_Date__c) 
                                        && date.valueOf(uwl.SVMXC__End_Date_and_Time__c.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)) > t.SVMXC__End_Date__c
                                        && date.valueOf(uwl.SVMXC__End_Date_and_Time__c.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)) <= Date.valueOf(System.now().format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)))
                                    {
                                        //System.debug(' inside elif lstWOSLine');
                                        lstWOSLine.add(uwl);
                                    }
                                }
                                //End BAC-4851
                            }   
                            if(lstWOSLine!=null && lstWOSLine.size()>0)
                                mapTSHdrWOLines.put(t.id,lstWOSLine); 
                        }
                    }
                    System.debug(LoggingLevel.WARN, 'mapTSHdrWOLines = ' + mapTSHdrWOLines.size()); 
                    
                    
                }
                List<Task> usertaskList = Database.query(taskQuery);
                System.debug(LoggingLevel.WARN, 'Tasks for which there is no Entry in Timesheet Entry ' + usertaskList.size());
                Map<ID, SVMXC__Service_Order__c> mapWorkOrders = new Map<ID, SVMXC__Service_Order__c>(); //Added for BAC-5388
                if(usertaskList != null && usertaskList.size() > 0){
                     List<Id> lstWoIds = new List<Id>(); //Added for BAC-5388
                    for(Task usertask: usertaskList){
                         lstWoIds.add(usertask.WhatId); //Added for BAC-5388
                        if(mapUserTask != null && mapUserTask.size() > 0 && mapUserTask.get(usertask.OwnerId) != null){
                            mapUserTask.get(usertask.OwnerId).add(usertask);     
                        } 
                        else{
                            Set<Task> setTask = new Set<Task>();
                            setTask.add(usertask);
                            mapUserTask.put(usertask.OwnerId, setTask);
                        }        
                    }
                    if(getTimeZoneFrom.equalsIgnoreCase(woBusinessHour) && lstWoIds.size() > 0){ //Added for BAC-5388
                        mapWorkOrders = new Map<ID, SVMXC__Service_Order__c>([SELECT Id, SVMXC__Preferred_Business_Hours__r.TimeZoneSidKey FROM SVMXC__Service_Order__c where ID IN:lstWoIds]);
                    }
                }
                
                System.debug(LoggingLevel.WARN, 'Task per User ' + mapUserTask.size());
                List<Task> lstTskLine;
                Set<Task> setTskLin;
                if(mapUserTask.size() > 0){ //Added for BAC-4866
                    for(SVMXC__Timesheet__c t : openTimesheetheader)//for each open TS header
                    {
                        lstTskLine = new List<Task>();
                        for(Task ut: usertaskList)
                        {
                            //Added for BAC-5388 and BAC-5504
                            if(getTimeZoneFrom.equalsIgnoreCase(woBusinessHour)){
                                if(mapWorkOrders.isEmpty() || !mapWorkOrders.containsKey(ut.WhatId) || mapWorkOrders.get(ut.WhatId).SVMXC__Preferred_Business_Hours__r.TimeZoneSidKey == null){
                                    continue;
                                }
                                UserTimezoneInfo userTZVar = new UserTimezoneInfo();
                                userTZVar.businessHourId = mapWorkOrders.get(ut.WhatId).SVMXC__Preferred_Business_Hours__c;
                                userTZVar.timeZoneValue = mapWorkOrders.get(ut.WhatId).SVMXC__Preferred_Business_Hours__r.TimeZoneSidKey;
                                mapRecordsWithTimezone.put(ut.id,userTZVar);
                            }
                            // end for BAC-5388
                            setTskLin = mapUserTask.get(t.SVMXC__User__r.Id); 
                            if(setTskLin!=null)
                            {           
                                if(setTskLin.contains(ut) && ut.ActivityDate >= t.SVMXC__Start_Date__c && ut.ActivityDate  <= t.SVMXC__End_Date__c)
                                {
                                    lstTskLine.add(ut);    
                                }
                            }
                        }   
                        if(lstTskLine!=null && lstTskLine.size()>0)
                            mapTSHdrTskLines.put(t.id,lstTskLine); 
                    }
                }
                System.debug(LoggingLevel.WARN, 'mapTSHdrTskLines = ' + mapTSHdrTskLines.size()); 
                
                if(eventTypeForProcess.toUpperCase() == 'EVENT' || eventTypeForProcess.toUpperCase() == 'BOTH')
                {
                    List<Event> userSFEventsList = Database.query(SFEventQuery);
                    System.debug(LoggingLevel.WARN, 'Event for which there is no Entry in Timesheet Entry ' + userSFEventsList.size());
                    if(userSFEventsList != null && userSFEventsList.size() > 0){
                        List<Id> lstWoIds = new List<Id>(); //Added for BAC-5388
                        for(Event userSFEvents: userSFEventsList){
                            lstWoIds.add(userSFEvents.WhatId);
                            if(mapUserSFEvents != null && mapUserSFEvents.size() > 0 && mapUserSFEvents.get(userSFEvents.OwnerId) != null){
                                mapUserSFEvents.get(userSFEvents.OwnerId).add(userSFEvents);     
                            } 
                            else{
                                Set<Event> setSFEvents = new Set<Event>();
                                setSFEvents.add(userSFEvents);
                                mapUserSFEvents.put(userSFEvents.OwnerId, setSFEvents);
                            }      
                        }
                        if(getTimeZoneFrom.equalsIgnoreCase(woBusinessHour) && lstWoIds.size() > 0){ //Added for BAC-5388
                            mapWorkOrders.clear();
                            mapWorkOrders = new Map<ID, SVMXC__Service_Order__c>([SELECT Id, SVMXC__Preferred_Business_Hours__r.TimeZoneSidKey FROM SVMXC__Service_Order__c where ID IN:lstWoIds]);
                        }
                    }
                    
                    //System.debug(LoggingLevel.WARN, 'Event per User ' + mapUserSFEvents);
                    List<Event> lstEvtLine;
                    Set<Event> setEvtLin;
                    if(mapUserSFEvents.size() > 0){ //Added for BAC-4866
                        for(SVMXC__Timesheet__c t : openTimesheetheader)//for each open TS header
                        {
                            String timeZoneforTSHeader = maptimesheetHeaderId.get(t.id).SVMXC__SM_Business_Hours__c != null ? maptimesheetHeaderId.get(t.id).SVMXC__SM_Business_Hours__r.TimeZoneSidKey : UserInfo.getTimeZone().getID();// Added for BAC-4851
                            lstEvtLine = new List<Event>();
                            for(Event ue: userSFEventsList)
                            {
                                //Added for BAC-5388 and BAC-5504
                                if(getTimeZoneFrom.equalsIgnoreCase(woBusinessHour)){
                                    if(mapWorkOrders.isEmpty() || !mapWorkOrders.containsKey(ue.WhatId) || mapWorkOrders.get(ue.WhatId).SVMXC__Preferred_Business_Hours__r.TimeZoneSidKey == null){
                                        continue;
                                    }
                                    timeZoneforTSHeader = mapWorkOrders.get(ue.WhatId).SVMXC__Preferred_Business_Hours__r.TimeZoneSidKey;
                                    UserTimezoneInfo userTZVar = new UserTimezoneInfo();
                                    userTZVar.businessHourId = mapWorkOrders.get(ue.WhatId).SVMXC__Preferred_Business_Hours__c;
                                    userTZVar.timeZoneValue = timeZoneforTSHeader;
                                    mapRecordsWithTimezone.put(ue.id,userTZVar);
                                }
                                // end for BAC-5388
                                setEvtLin =  mapUserSFEvents.get(t.SVMXC__User__r.Id);
                                //Added for for BAC-4851
                                if(setEvtLin!=null)
                                {           
                                    if(setEvtLin.contains(ue) && date.valueOf(ue.StartDateTime.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)) >= t.SVMXC__Start_Date__c && date.valueOf(ue.EndDateTime.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)) <= t.SVMXC__End_Date__c)
                                    {
                                        lstEvtLine.add(ue);    
                                    }else if( // Added for 045467
                                        setEvtLin.contains(ue) 
                                        && checkDatesBetweenTSHeaders(date.valueOf(ue.StartDateTime.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)), t.SVMXC__Start_Date__c, t.SVMXC__End_Date__c) 
                                        && date.valueOf(ue.EndDateTime.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)) > t.SVMXC__End_Date__c
                                        && date.valueOf(ue.EndDateTime.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)) <= Date.valueOf(System.now().format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)))
                                    {
                                        //System.debug(' inside elif lstEvtLine');
                                        lstEvtLine.add(ue);
                                    }
                                }
                                //End for for BAC-4851
                            }   
                            if(lstEvtLine!=null && lstEvtLine.size()>0)
                                mapTSHdrEvtLines.put(t.id,lstEvtLine); 
                        }
                    }
                    //System.debug(LoggingLevel.WARN, 'mapTSHdrEvtLines = ' + mapTSHdrEvtLines);   
                }
                
                if(eventTypeForProcess.toUpperCase() == 'SERVICEMAX EVENT' || eventTypeForProcess.toUpperCase() == 'BOTH')
                {
                    List<SVMXC__SVMX_Event__c> userSVMXEventsList = Database.query(SVMXEventQuery);
                    System.debug(LoggingLevel.WARN, 'SVMX Event for which there is no Entry in Timesheet Entry ' + userSVMXEventsList.size());
                    if(userSVMXEventsList != null && userSVMXEventsList.size() > 0){
                        for(SVMXC__SVMX_Event__c userSVMXEvents: userSVMXEventsList){
                            if(mapUserSVMXEvents != null && mapUserSVMXEvents.size() > 0 && mapUserSVMXEvents.get(userSVMXEvents.SVMXC__Technician__r.Salesforce_User__c) != null){
                                mapUserSVMXEvents.get(userSVMXEvents.SVMXC__Technician__r.Salesforce_User__c).add(userSVMXEvents);     
                            } 
                            else{
                                Set<SVMXC__SVMX_Event__c> setSVMXEvents = new Set<SVMXC__SVMX_Event__c>();
                                setSVMXEvents.add(userSVMXEvents);
                                mapUserSVMXEvents.put(userSVMXEvents.SVMXC__Technician__r.Salesforce_User__c, setSVMXEvents);
                            }    
                        }
                    }
                    
                    //System.debug(LoggingLevel.WARN, 'SVMX Event per User ' + mapUserSVMXEvents);
                    
                    List<SVMXC__SVMX_Event__c> lstSEvtLine;
                    Set<SVMXC__SVMX_Event__c> setSEvtlin;
                    if(mapUserSVMXEvents.size() > 0){ //Added for BAC-4866
                        for(SVMXC__Timesheet__c t : openTimesheetheader)//for each open TS header
                        {
                            String timeZoneforTSHeader = maptimesheetHeaderId.get(t.id).SVMXC__SM_Business_Hours__c != null ? maptimesheetHeaderId.get(t.id).SVMXC__SM_Business_Hours__r.TimeZoneSidKey : UserInfo.getTimeZone().getID();// Added for BAC-4851
                            lstSEvtLine = new List<SVMXC__SVMX_Event__c>();
                            for(SVMXC__SVMX_Event__c use: userSVMXEventsList)
                            {
                                //Added for BAC-5388 and BAC-5504
                                if(getTimeZoneFrom.equalsIgnoreCase(woBusinessHour)){
                                    if(use.SVMXC__Service_Order__c == null || use.SVMXC__Service_Order__r.SVMXC__Preferred_Business_Hours__c == null){ //Changed && to || for BAC-5502
                                        continue;
                                    }
                                    timeZoneforTSHeader = use.SVMXC__Service_Order__r.SVMXC__Preferred_Business_Hours__r.TimeZoneSidKey;
                                    UserTimezoneInfo userTZVar = new UserTimezoneInfo();
                                    userTZVar.businessHourId = use.SVMXC__Service_Order__r.SVMXC__Preferred_Business_Hours__c;
                                    userTZVar.timeZoneValue = timeZoneforTSHeader;
                                    mapRecordsWithTimezone.put(use.id,userTZVar);
                                }
                                // end for BAC-5388
                                setSEvtlin = mapUserSVMXEvents.get(t.SVMXC__User__r.Id);
                                //Added for BAC-4851
                                if(setSEvtlin!=null)
                                {           
                                    if(setSEvtlin.contains(use) && date.valueOf(use.SVMXC__StartDateTime__c.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)) >= t.SVMXC__Start_Date__c && date.valueOf(use.SVMXC__EndDateTime__c.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)) <= t.SVMXC__End_Date__c)
                                    {
                                        lstSEvtLine.add(use);    
                                    }else if( // Added for 045467
                                        setSEvtlin.contains(use) 
                                        && checkDatesBetweenTSHeaders(date.valueOf(use.SVMXC__StartDateTime__c.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)), t.SVMXC__Start_Date__c, t.SVMXC__End_Date__c) 
                                        && date.valueOf(use.SVMXC__EndDateTime__c.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)) > t.SVMXC__End_Date__c
                                        && date.valueOf(use.SVMXC__EndDateTime__c.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)) <= Date.valueOf(System.now().format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)))
                                    {
                                        //System.debug(' inside elif lstSEvtLine');
                                        lstSEvtLine.add(use); 
                                    }
                                }
                                //End for BAC-4851
                            }   
                            if(lstSEvtLine!=null && lstSEvtLine.size()>0)
                                mapTSHdrSEvtLines.put(t.id,lstSEvtLine); 
                        }
                    }
                    System.debug(LoggingLevel.WARN, 'mapTSHdrSEvtLines = ' + mapTSHdrSEvtLines.size()); 
                }
            }   
        }//end of if 'TIMESHEETAUTOFILL'
    }
    // This method is used to know a date is in between two dates
    private boolean checkDatesBetweenTSHeaders(Date tempDate, Date startDate, Date endDate){
        Boolean foundDate = false;
        if(tempDate >= startDate && tempDate <= endDate){
            foundDate = true;
        }
        return foundDate;
    }
    /*
    Method creates Time Sheet Entry for all the records passed to the method for 1 user at a time.
    */
    public void createTimesheetEntry(ID listTimesheetHeader, List<SObject> listofRecToPopulate, Id sObjectMappingID, List<SVMXC__Timesheet_Entry__c> createListTimeSheetEntry, Id processBusinessHours, Map <String, Schema.SObjectType> schemaMap, String getTimeZoneFrom, String sourceObjectforMapping){
        SFM_ApplyMapping applyMapping = new SFM_ApplyMapping();
        if(listofRecToPopulate != null && listofRecToPopulate.size()>0){
            Map<String,Sobject> SourceRecIdTargetObjMap = new Map<String,Sobject> (); 
            for(SObject recList : listofRecToPopulate){
                SourceRecIdTargetObjMap.put(recList.Id,  new SVMXC__Timesheet_Entry__c());    
            }
            //List <Sobject> appliedMappingRec = applyMapping.getApplyMapping1(sObjectMappingID ,SourceRecIdTargetObjMap, false,schemaMap); //Commented for 047019
            List <Sobject> appliedMappingRec = applyMapping.applyMappingForDetail(sObjectMappingID, SourceRecIdTargetObjMap, false, schemaMap, sourceObjectforMapping, 'SVMXC__Timesheet_Entry__c', null).values(); //Added for 047019
            
            for(SObject recList : appliedMappingRec){
                SVMXC__Timesheet_Entry__c timeSheetEnrty = (SVMXC__Timesheet_Entry__c)recList;
                timeSheetEnrty.SVMXC__Timesheet__c = listTimesheetHeader;
                List<SVMXC__Timesheet_Day_Entry__c> listTimesheetDayEntry = mapTimesheetHeaderandTimesheetDayEntry.get(listTimesheetHeader);
                ID TimesheetHeaderBusinessHourId = maptimesheetHeaderId.get(listTimesheetHeader).SVMXC__SM_Business_Hours__c;
                String timeZoneforTSHeader = maptimesheetHeaderId.get(listTimesheetHeader).SVMXC__SM_Business_Hours__c != null ? maptimesheetHeaderId.get(listTimesheetHeader).SVMXC__SM_Business_Hours__r.TimeZoneSidKey : UserInfo.getTimeZone().getID();// Added for BAC-4851
                // Added for BAC-5388
                if(getTimeZoneFrom.equalsIgnoreCase(woBusinessHour) && !mapRecordsWithTimezone.isEmpty()){
                    if(timeSheetEnrty.get('SVMXC__Work_Detail__c') != null && mapRecordsWithTimezone.containsKey(timeSheetEnrty.SVMXC__Work_Detail__c)){
                            timeZoneforTSHeader = mapRecordsWithTimezone.get(timeSheetEnrty.SVMXC__Work_Detail__c).timeZoneValue;
                            timesheetHeaderBusinessHourId = mapRecordsWithTimezone.get(timeSheetEnrty.SVMXC__Work_Detail__c).businessHourId;
                    }else if(timeSheetEnrty.get('SVMXC__Task__c') != null && mapRecordsWithTimezone.containsKey(timeSheetEnrty.SVMXC__Task__c)){
                            timeZoneforTSHeader = mapRecordsWithTimezone.get(timeSheetEnrty.SVMXC__Task__c).timeZoneValue;
                            timesheetHeaderBusinessHourId = mapRecordsWithTimezone.get(timeSheetEnrty.SVMXC__Task__c).businessHourId;
                    }else if(timeSheetEnrty.get('SVMXC__Salesforce_Event__c') != null && mapRecordsWithTimezone.containsKey(timeSheetEnrty.SVMXC__Salesforce_Event__c)){
                            timeZoneforTSHeader = mapRecordsWithTimezone.get(timeSheetEnrty.SVMXC__Salesforce_Event__c).timeZoneValue;
                            timesheetHeaderBusinessHourId = mapRecordsWithTimezone.get(timeSheetEnrty.SVMXC__Salesforce_Event__c).businessHourId;
                    }else if(timeSheetEnrty.get('SVMXC__ServiceMax_Event__c') != null && mapRecordsWithTimezone.containsKey(timeSheetEnrty.SVMXC__ServiceMax_Event__c)){
                            timeZoneforTSHeader = mapRecordsWithTimezone.get(timeSheetEnrty.SVMXC__ServiceMax_Event__c).timeZoneValue;
                            timesheetHeaderBusinessHourId = mapRecordsWithTimezone.get(timeSheetEnrty.SVMXC__ServiceMax_Event__c).businessHourId;
                    }

                }
                timeSheetEnrty.SVMXC__SM_Time_Zone__c = timeZoneforTSHeader; 
                //End for BAC-5388
                //To Do: Duration need to come from Configuration defined by Servicemax Process 
                if(timeSheetEnrty != null && timeSheetEnrty.SVMXC__Duration__c == null && timeSheetEnrty.SVMXC__End_Time__c != null && timeSheetEnrty.SVMXC__Start_Time__c != null){
                    Long milliSec = BusinessHours.diff(TimesheetHeaderBusinessHourId, timeSheetEnrty.SVMXC__Start_Time__c,timeSheetEnrty.SVMXC__End_Time__c );
                    timeSheetEnrty.SVMXC__Duration__c = Decimal.valueOf(milliSec).divide(1000*60*60,2);   
                }
                else{
                    if(timeSheetEnrty.SVMXC__Duration__c != null)
                        timeSheetEnrty.SVMXC__Duration__c = timeSheetEnrty.SVMXC__Duration__c;
                }
                
                if(timeSheetEnrty.SVMXC__Start_Time__c != null){
                    //Date timeSheetEntryStartDate = timeSheetEnrty.SVMXC__Start_Time__c.Date(); Commented for BAC-4851
                    //Added for BAC-4851
                    Datetime userDT = timeSheetEnrty.SVMXC__Start_Time__c;
                    Date timeSheetEntryStartDate = date.valueOf(userDT.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader));
                    //System.debug('timeSheetEnrty.SVMXC__Start_Time__c myDate '+timeSheetEntryStartDate);
                    //End for BAC-4851
                    for(SVMXC__Timesheet_Day_Entry__c timesheetDayEntry :  listTimesheetDayEntry){
                        Date timesheetEntryDay = timesheetDayEntry.SVMXC__Timsheet_Day__c; 
                        if(timeSheetEntryStartDate.isSameDay(timesheetEntryDay)){
                            if(timesheetDayEntry.SVMXC__Total_Hours__c == null)
                                timesheetDayEntry.SVMXC__Total_Hours__c = 0;
                            
                            if(mapUpdateDailySummaryTotalHours.get(timesheetDayEntry.Id) == null){
                                Double dailySummaryTotalHours = timeSheetEnrty.SVMXC__Duration__c;
                                for(SVMXC__Timesheet_Entry__c timeEntries :mapTimesheetHeaderEntries.get(listTimesheetHeader)){
                                    //Date timesEntryStartDay = timeEntries.SVMXC__Start_Time__c.Date(); Commented for BAC-4851
                                    // Added for BAC-4851
                                    //System.debug('timeSheetEnrty '+timeEntries);
                                    Datetime userDTDay = timeEntries.SVMXC__Start_Time__c;
                                    //Added for BAC-5562
                                    Date timesEntryStartDay;
                                    if(timeEntries.SVMXC__SM_Time_Zone__c != null){
                                        timesEntryStartDay = date.valueOf(userDTDay.format('yyyy-MM-dd HH:mm:ss',timeEntries.SVMXC__SM_Time_Zone__c));
                                    }else{
                                        timesEntryStartDay = date.valueOf(userDTDay.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader));
                                    }
                                    //End
                                    //Date timesEntryStartDay = date.valueOf(userDTDay.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)); // Commented for BAC-5562
                                    // End BAC-4851
                                    if(timeSheetEntryStartDate.isSameDay(timesEntryStartDay) && timeEntries.SVMXC__Duration__c != null){
                                        if(dailySummaryTotalHours > 0) //Added if condition for BAC-5511
                                            dailySummaryTotalHours = dailySummaryTotalHours + timeEntries.SVMXC__Duration__c;
                                    }
                                }
                                if(dailySummaryTotalHours > 0) //Added if condition for BAC-5511
                                    timesheetDayEntry.SVMXC__Total_Hours__c =  dailySummaryTotalHours; 
                                
                                mapUpdateDailySummaryTotalHours.put(timesheetDayEntry.Id, timesheetDayEntry);
                            }
                            else{
                                timesheetDayEntry.SVMXC__Total_Hours__c = mapUpdateDailySummaryTotalHours.get(timesheetDayEntry.Id).SVMXC__Total_Hours__c +timeSheetEnrty.SVMXC__Duration__c; 
                                mapUpdateDailySummaryTotalHours.put(timesheetDayEntry.Id, timesheetDayEntry);
                            }
                            timeSheetEnrty.SVMXC__Timesheet_Day__c = timesheetDayEntry.id;
                            break; 
                        }    
                    }
                }
                
                if(timeSheetEnrty.SVMXC__Duration__c != null && timeSheetEnrty.SVMXC__Timesheet_Day__c != null) {
                    createListTimeSheetEntry.add(timeSheetEnrty);
                }
                
                System.debug(LoggingLevel.WARN, 'Timesheet Entry Created ' + createListTimeSheetEntry);
            }
        }
    }
    
    
    /* Internal class to get User Autofill Info  */
    public class UserAutofillInfo {
        public Integer workDetailCount = 0; 
        public Integer taskCount = 0; 
        public Integer eventCount = 0; 
        public Integer svmxEventCount = 0;
        public String AutoFillStatus; 
        User technicianRec ; 
        public UserAutofillInfo (User userRec){
            this.technicianRec = userRec;
        }
    }
    public class UserTimezoneInfo { // To store businesshour along with respected timezone
        public Id businessHourId;
        public String timeZoneValue;
        public UserTimezoneInfo(){

        }
    }
    /* Store BusinessHour Information */
    public class BusinessHoursInfo{
        public Id BusinessHoursId;
        public BusinessHours businessHourRecDetail; 
        public Map<String, Decimal> mapDayToWorkingHours;
        public Map<String, Map<String, Time>> mapDayToStartEndTime;
    }
    
    /* Store StartTime and End time for Holiday */
    public class HolidayTime{
        Time startTime;
        Time endTime;
        
        HolidayTime(Time startTime, Time endTime){
            this.startTime = startTime;
            this.endTime = endTime;
        }
    }   
    
    
    public string getTAG001(){return System.label.COMM001_TAG093;}//'NOTE: THIS IS A SYSTEM GENERATED EMAIL. PLEASE DO NOT REPLY TO THIS MESSAGE.'
    public static String getTAG002(){return System.label.TMST001_TAG023;} //You have a new timesheet available for the week of
    public String getTAG003(){return System.label.TMST001_TAG024;} // To access the timesheet, please click on the following link:
    public String getTAG004(){return System.label.TMST001_TAG022;} // Scheduled Timesheet Configuration Name: 
    public string getTAG005(){return System.label.TMST001_TAG025;} //'Scheduled Timesheet Configuration Process Id:'
    public string getTAG006(){return System.label.CONF039_TAG019;} //'Records to Process'
    public string getTAG007(){return System.label.COMM001_TAG096;} //'Success'
    public string getTAG008(){return System.label.COMM001_TAG097;} //'Failed'
    public string getTAG010(){return System.label.CONF039_TAG038;} //'Scheduler Start Time'
    public string getTAG011(){return System.label.CONF039_TAG039;} //'Scheduler Finish Time' 
    public string getTAG012(){return System.label.CONF039_TAG022;} //'Elapsed Time in minutes'
    public string getTAG013(){return System.label.TMST001_TAG020;} //'Scheduled Timesheet Header creation has completed with the following results:'
    public string getTAG014(){return System.label.COMM001_TAG095;} //'Attachment'
    public string getTAG015(){return System.label.TMST001_TAG025;} //ServiceMax: Timesheet Header Scheduled Status on:
    public string getTAG016(){return System.label.TMST001_TAG021;} //Scheduled Timesheet Entry creation has completed with the following results:
    public string getTAG017(){return System.label.TMST001_TAG032;} // No. of Work Details processed
    public string getTAG018(){return System.label.TMST001_TAG033;} // No. of Tasks processed
    public string getTAG019(){return System.label.TMST001_TAG034;} // No. of Salesforce Event processed
    public string getTAG020(){return System.label.TMST001_TAG035;} // No. of ServiceMax Event processed
    public string getTAG021(){return System.label.TMST001_TAG026;} // ServiceMax: Timesheet Entry Scheduled Status on:
    public string getTAG022(){return System.label.TMST001_TAG031;} // Process ID
    
}