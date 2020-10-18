/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/
/**
 * The TMST_TimesheetEngineAPI is the service class which will perform like TMST_TimesheetEngine and this is the exclusive web-service which can be called as follows.
 *  SFM custom action or external source via INTF_WebServicesDef
 * This class is a Synchronous class
 * 
 * @author Soumyaranjan Pati
 * @version 20.1
 * @since 2019
 */
/*****************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************
 *   BAC-5143  Soumyaranjan Pati     5th Dec 2019     Created. 
 *****************************************************************************/
public with sharing class TMST_TimesheetEngineAPI {
    Map<Id, List<SVMXC__Service_Order_Line__c>> mapTSHdrWOLines = new Map<Id, List<SVMXC__Service_Order_Line__c>>(); //TS Header id with WO lines
    Map<Id, List<SVMXC__SVMX_Event__c>> mapTSHdrSEvtLines = new Map<Id, List<SVMXC__SVMX_Event__c>>(); //TS Header id, Corrosp SVMX Event lines
    Map<Id, List<Event>> mapTSHdrEvtLines = new Map<Id, List<Event>>(); //TS Header id with Event lines
    Map<Id, List<Task>> mapTSHdrTskLines = new Map<Id, List<Task>>(); //TS Header id with Task lines 
    Map<Id, SVMXC__Timesheet_Day_Entry__c> mapUpdateDailySummaryTotalHours = new Map<Id, SVMXC__Timesheet_Day_Entry__c>();
    Map<Id, List<SVMXC__Timesheet_Day_Entry__c>> mapTimesheetHeaderandTimesheetDayEntry = new Map<Id, List<SVMXC__Timesheet_Day_Entry__c>>();
    Map<Id, List<SVMXC__Timesheet_Entry__c>> mapTimesheetHeaderEntries = new Map<Id, List<SVMXC__Timesheet_Entry__c>>();
    String getTimeZoneFrom = ''; //Added for story BAC-5388 WorkOrder/Technician
    Map<Id,UserTimezoneInfo> mapRecordsWithTimezone = new Map<Id,UserTimezoneInfo>(); //Added for story BAC-5388
    DateTime dateTimeStart = null;
    String woBusinessHour = 'WO Business Hours';
    public UserAutofillInfo userAutofillVar = new UserAutofillInfo();
    public INTF_WebServicesDef.INTF_Response processTimesheetHeaderData(INTF_WebServicesDef.INTF_Request req){
        dateTimeStart = System.Now();
        INTF_WebServicesDef.INTF_Response retValue = new INTF_WebServicesDef.INTF_Response();
        //Check the Timesheet batch is running or not?
        if(!Test.isRunningTest()){ // Added for BAC-5508
            List<AsyncApexJob> countTMSTJobs = [SELECT Status FROM AsyncApexJob WHERE Status != 'Completed' AND JobType = 'BatchApex' AND ApexClass.Name = 'TMST_TimesheetEngine' limit 1];
            if(!countTMSTJobs.isEmpty() && (countTMSTJobs[0].Status.equalsIgnoreCase('Processing') || countTMSTJobs[0].Status.equalsIgnoreCase('Preparing') || countTMSTJobs[0].Status.equalsIgnoreCase('Queued') || countTMSTJobs[0].Status.equalsIgnoreCase('Holding'))){
                retValue.success = false;
                retValue.message = 'TMST_TimesheetEngine is Processing';
                return retValue;
            }
        }
        //
        
        if(req.valueMap != null && req.valueMap.size() > 0){
            //Check CRUD and FLS
            Boolean checkUsersPermission = true;
            try {
                List<String> queryFields;
                queryFields = new List<String> {'SVMXC__Profile__c', 'SVMXC__SM_Scope__c', 'SVMXC__Access_Configuration_Profile__c', 'SVMXC__Dispatch_Process__c'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                queryFields = new List<String> {'SVMXC__Source_Object_Name__c', 'SVMXC__Advance_Expression__c', 'SVMXC__Parent_Object_Criteria__c', 'SVMXC__Event_Type__c', 'SVMXC__Field_Name__c', 'SVMXC__Process__c', 'SVMXC__Parent_Object__c', 'SVMXC__Node_Parent__c', 'SVMXC__Submodule__c', 'SVMXC__Process1__c', 'SVMXC__Process2__c', 'SVMXC__Process3__c', 'SVMXC__Module__c','SVMXC__Active__c'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                queryFields = new List<String> {'SVMXC__Period__c', 'SVMXC__SM_Business_Hours__c', 'SVMXC__Total_Hours__c', 'SVMXC__User__c', 'SVMXC__Start_Date__c', 'SVMXC__End_Date__c'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Timesheet__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                queryFields = new List<String> {'SVMXC__Timesheet__c', 'SVMXC__Timsheet_Day__c', 'SVMXC__IsHoliday__c', 'SVMXC__Total_Hours__c'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Timesheet_Day_Entry__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                queryFields = new List<String> {'SVMXC__Timesheet__c', 'SVMXC__Start_Time__c', 'SVMXC__End_Time__c', 'SVMXC__Salesforce_Event__c', 'SVMXC__ServiceMax_Event__c', 'SVMXC__Task__c', 'SVMXC__Work_Detail__c', 'SVMXC__Duration__c'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Timesheet_Entry__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            } catch (Exception es) {
                retValue.success = false;
                retValue.message = es.getMessage();
                checkUsersPermission = false;
            }
            //End of checking CRUD and FLS
            if(checkUsersPermission){
                List<String> listTSHeaderIds = new List<String>();
                for(SVMXC.INTF_WebservicesDef.SVMXMap mp : req.valueMap){
                    if(mp.key == 'SVMX_RECORDID')
                        listTSHeaderIds.add(mp.value);
                }
                if(!listTSHeaderIds.isEmpty()){
                    List<SVMXC__Timesheet__c> listTSHeaders = [select Id, SVMXC__SM_Business_Hours__c, SVMXC__Start_Date__c, SVMXC__End_Date__c, SVMXC__Status__c, SVMXC__User__c, SVMXC__User__r.Profile.Id from SVMXC__Timesheet__c where Id IN: listTSHeaderIds];
                    try{
                        timeEntryCreation(listTSHeaders[0]);
                    }catch(Exception es){
                        retValue.success = false;
                        retValue.message = es.getMessage(); 
                    }
                }else{
                    retValue.success = false;
                    retValue.message = 'No Records found';
                }
                retValue.success = true;
            }
            
            
        }else{
            retValue.success = false;
            retValue.message = 'No Records found';
        }
        return retValue;
    }
    
    public void timeEntryCreation(SVMXC__Timesheet__c tsHeaderRecord){
        //Get the Config profile details
        List<SVMXC__ServiceMax_Config_Data__c> listOfConfigrationAccess = [SELECT SVMXC__Profile__c, SVMXC__Access_Configuration_Profile__c 
                                                                                     FROM SVMXC__ServiceMax_Config_Data__c
                                                                                     WHERE RecordType.Name = 'Configuration Access' AND SVMXC__Profile__c = :tsHeaderRecord.SVMXC__User__r.Profile.Id];
        if(listOfConfigrationAccess.isEmpty() || listOfConfigrationAccess[0].SVMXC__Access_Configuration_Profile__c == null){
            return;
        }
        //Added SVMXC__Active__c for BAC-5501
        List<SVMXC__ServiceMax_Config_Data__c> listTimesheetAccessProcess = [SELECT Id, SVMXC__SM_Scope__c, SVMXC__Dispatch_Process__c, SVMXC__Dispatch_Process__r.SVMXC__Event_Type__c,
                                                                                     SVMXC__Dispatch_Process__r.SVMXC__SM_Business_Hour_Source__c, 
                                                                                     SVMXC__Dispatch_Process__r.SVMXC__Field_Name__c,
                                                                                     SVMXC__Dispatch_Process__r.Name,
                                                                                     SVMXC__Dispatch_Process__r.SVMXC__ProcessID__c,
                                                                                     SVMXC__Dispatch_Process__r.SVMXC__Process__c, 
                                                                                     SVMXC__Dispatch_Process__r.SVMXC__Parent_Object__c, 
                                                                                     SVMXC__Dispatch_Process__r.SVMXC__Node_Parent__c, 
                                                                                     SVMXC__Dispatch_Process__r.SVMXC__Submodule__c,
                                                                                     SVMXC__Dispatch_Process__r.SVMXC__Process1__c,
                                                                                     SVMXC__Dispatch_Process__r.SVMXC__Process1__r.SVMXC__Source_Object_Name__c,
                                                                                     SVMXC__Dispatch_Process__r.SVMXC__Process2__c,
                                                                                     SVMXC__Dispatch_Process__r.SVMXC__Process2__r.SVMXC__Source_Object_Name__c,
                                                                                     SVMXC__Dispatch_Process__r.SVMXC__Process3__c,
                                                                                     SVMXC__Dispatch_Process__r.SVMXC__Process3__r.SVMXC__Source_Object_Name__c,
                                                                                     SVMXC__Dispatch_Process__r.SVMXC__Module__c,
                                                                                     SVMXC__Dispatch_Process__r.SVMXC__Module__r.SVMXC__Source_Object_Name__c   
                                                                                     FROM SVMXC__ServiceMax_Config_Data__c
                                                                                     WHERE RecordType.Name = 'Timesheet Access' AND SVMXC__Access_Configuration_Profile__c = :listOfConfigrationAccess[0].SVMXC__Access_Configuration_Profile__c and SVMXC__Dispatch_Process__r.RecordType.Name = 'Timesheet' and SVMXC__Dispatch_Process__r.SVMXC__Active__c =: true];
        if(listTimesheetAccessProcess.isEmpty() || listTimesheetAccessProcess[0].SVMXC__Dispatch_Process__c == null || listTimesheetAccessProcess[0].SVMXC__SM_Scope__c == null){
            return;
        }
        // Added for defect- BAC-5500
        SVMXC.TMST_WrapperDef.SalesforceProfileInfo tsWrap = new SVMXC.TMST_WrapperDef.SalesforceProfileInfo();
        tsWrap = (SVMXC.TMST_WrapperDef.SalesforceProfileInfo) JSON.deserialize(listTimesheetAccessProcess[0].SVMXC__SM_Scope__c, SVMXC.TMST_WrapperDef.SalesforceProfileInfo.class);
        Boolean isProfileFound = false;
        for(SVMXC.TMST_WrapperDef.ObjectInfo objectInfoVar: tsWrap.salesforceProfileIds){
            if(listOfConfigrationAccess[0].SVMXC__Profile__c.equalsIgnoreCase(objectInfoVar.Id)){ 
                isProfileFound = true;
            }
        }
        if(!isProfileFound){
            return;
        }
        // BAC-5500
        //Config profile details end
        Date previousEndDate = tsHeaderRecord.SVMXC__Start_Date__c.addDays(-1);
        //Added SVMXC__SM_Time_Zone__c to soql for BAC-5562
        List<SVMXC__Timesheet__c> openTimesheetheader = [SELECT Id, SVMXC__Period__c, SVMXC__SM_Business_Hours__r.TimeZoneSidKey, SVMXC__Total_Hours__c, SVMXC__SM_Business_Hours__c,(SELECT SVMXC__Timesheet__c, SVMXC__Start_Time__c, SVMXC__End_Time__c, SVMXC__Salesforce_Event__c, SVMXC__ServiceMax_Event__c, SVMXC__Task__c, SVMXC__Work_Detail__c, SVMXC__Duration__c, SVMXC__SM_Time_Zone__c FROM SVMXC__Time_Sheet_Entries__r), (SELECT SVMXC__Timesheet__c, SVMXC__Timsheet_Day__c , SVMXC__IsHoliday__c,SVMXC__Total_Hours__c FROM SVMXC__Timesheet_Day_Entries__r), SVMXC__User__r.id, SVMXC__Start_Date__c, SVMXC__End_Date__c from SVMXC__Timesheet__c WHERE (SVMXC__End_Date__c =: previousEndDate OR ID = :tsHeaderRecord.Id) and SVMXC__User__c = :tsHeaderRecord.SVMXC__User__c and SVMXC__Status__c = : TMST_Consts.STRING_OPEN]; 
        
        //
        Map<Id, ID> mapTimesheetEntryWOentries = new Map<Id, Id>();
        Map<Id, ID> mapTimesheetEntrySVMXEvents = new Map<Id, ID>();
        Map<Id, ID> mapTimesheetEntrySFEvents = new Map<Id, ID>();
        Map<Id, ID> mapTimesheetEntrySFTasks = new Map<Id, ID>(); 
        Date tsStartDate = System.today();
        Date tsEndDate = System.today();
        Map<Id, SVMXC__Timesheet__c> maptimesheetHeaderId = new Map<Id, SVMXC__Timesheet__c>();
        
        if(!openTimesheetheader.isEmpty()){   
            List<SVMXC__Timesheet_Entry__c> lstTimeSheetEntry = new List<SVMXC__Timesheet_Entry__c>();
            for(SVMXC__Timesheet__c listOfOpenTimesheetHeader : openTimesheetheader)
            {
                
                lstTimeSheetEntry.addAll(listOfOpenTimesheetHeader.SVMXC__Time_Sheet_Entries__r);
                maptimesheetHeaderId.put(listOfOpenTimesheetHeader.Id, listOfOpenTimesheetHeader);
                mapTimesheetHeaderandTimesheetDayEntry.put(listOfOpenTimesheetHeader.Id, listOfOpenTimesheetHeader.SVMXC__Timesheet_Day_Entries__r);
                mapTimesheetHeaderEntries.put(listOfOpenTimesheetHeader.Id, listOfOpenTimesheetHeader.SVMXC__Time_Sheet_Entries__r);
                //Get the earliest startdate and latest end date
                if(listOfOpenTimesheetHeader.SVMXC__Start_Date__c <= tsStartDate){
                    tsStartDate = listOfOpenTimesheetHeader.SVMXC__Start_Date__c;
                }
                if(listOfOpenTimesheetHeader.SVMXC__End_Date__c >= tsEndDate){
                    tsEndDate = listOfOpenTimesheetHeader.SVMXC__End_Date__c;
                }
                 
                //
            }
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
        //
        //To Do : Check if there is a mapping avaialble for WO, Task, Event/SVMX Event
        String ownership ;
        String eventTypeForProcess = listTimesheetAccessProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Event_Type__c;
        String fieldName = listTimesheetAccessProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Field_Name__c;
        getTimeZoneFrom = listTimesheetAccessProcess[0].SVMXC__Dispatch_Process__r.SVMXC__SM_Business_Hour_Source__c != null ? listTimesheetAccessProcess[0].SVMXC__Dispatch_Process__r.SVMXC__SM_Business_Hour_Source__c : 'Technician Record';
        if(fieldName != null && fieldName != ''){
            Map<String, Schema.SObjectField> sObjVar = Schema.SObjectType.SVMXC__Service_Order_Line__c.fields.getMap();
            List<Schema.SObjectType> technicianObj = sObjVar.get(fieldName.toLowerCase()).getDescribe().getReferenceTo();
            if(String.valueOf(technicianObj[0]).equalsIgnoreCase('SVMXC__SERVICE_GROUP_MEMBERS__C')){
                ownership =  fieldName.substringBefore('__c')+'__r.SVMXC__Salesforce_User__c';
            }else{
                ownership =  fieldName;  
            }
        }
        List<Id> listExpression = new List<Id>();
        Map<String, String> objectExpressions = new Map<String, String>();
        Map<String, ID > listObjectMapping = new Map<String, ID >();
        // As a set up, Process1 (WO), Process2(Task), Prcoess3(Event), Module(SVMX Event) will have all the object Mappings
        if(listTimesheetAccessProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Process1__c !=  null){
            listObjectMapping.put(listTimesheetAccessProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Process1__r.SVMXC__Source_Object_Name__c, listTimesheetAccessProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Process1__c );
        }
        if(listTimesheetAccessProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Process2__c !=  null){
            listObjectMapping.put(listTimesheetAccessProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Process2__r.SVMXC__Source_Object_Name__c, listTimesheetAccessProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Process2__c );
        }
        if(listTimesheetAccessProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Process3__c !=  null){
            listObjectMapping.put(listTimesheetAccessProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Process3__r.SVMXC__Source_Object_Name__c, listTimesheetAccessProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Process3__c);
        }
        if(listTimesheetAccessProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Module__c !=  null){
            listObjectMapping.put(listTimesheetAccessProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Module__r.SVMXC__Source_Object_Name__c, listTimesheetAccessProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Module__c);
        }
        
        // As a set up, Process(WO Expression), Node parent (task Expression), Parent Object (Event Expression), SVMXC__Submodule__c (SVMX Event Expression)
        if(listTimesheetAccessProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Process__c != null)
            listExpression.add(listTimesheetAccessProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Process__c);
        if(listTimesheetAccessProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Parent_Object__c != null)
            listExpression.add(listTimesheetAccessProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Parent_Object__c);
        if(listTimesheetAccessProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Node_Parent__c != null)
            listExpression.add(listTimesheetAccessProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Node_Parent__c);
        if(listTimesheetAccessProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Submodule__c != null)
            listExpression.add(listTimesheetAccessProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Submodule__c);
        
        for(SVMXC__ServiceMax_Processes__c listRule : [SELECT SVMXC__Source_Object_Name__c,
                                                         SVMXC__Advance_Expression__c,
                                                         SVMXC__Parent_Object_Criteria__c
                                                         FROM SVMXC__ServiceMax_Processes__c
                                                         WHERE Id IN :listExpression AND RecordType.Name = 'SVMX Rule']){
                                                             objectExpressions.put(listRule.SVMXC__Source_Object_Name__c, listRule.SVMXC__Parent_Object_Criteria__c);
                                                         }  
        
        //Construct the SOQL
        List<Id> processRecordsForListOFUsers = new List<Id>{tsHeaderRecord.SVMXC__User__c};
        //Added SVMXC__Service_Order__r.SVMXC__Preferred_Business_Hours__r.TimeZoneSidKey to (woQuery and SVMXEventQuery) and WhatId to (taskQuery and SFEventQuery) for BAC-5388
        String woQuery =   'Select Id, SVMXC__Service_Order__r.SVMXC__Preferred_Business_Hours__r.TimeZoneSidKey, SVMXC__Start_Date_and_Time__c,SVMXC__End_Date_and_Time__c, '+ ownership +' FROM SVMXC__Service_Order_Line__c WHERE ' + ownership +' IN : processRecordsForListOFUsers'; 
        String taskQuery = 'Select Id, WhatId, ActivityDate, OwnerId FROM Task WHERE OwnerId IN : processRecordsForListOFUsers';
        String SFEventQuery ='Select Id, WhatId, StartDateTime,EndDateTime, DurationInMinutes, OwnerId FROM Event WHERE OwnerId IN : processRecordsForListOFUsers';
        String SVMXEventQuery ='Select Id, SVMXC__Service_Order__r.SVMXC__Preferred_Business_Hours__r.TimeZoneSidKey, SVMXC__DurationInMinutes__c, SVMXC__StartDateTime__c,SVMXC__EndDateTime__c, SVMXC__Technician__r.Salesforce_User__c FROM SVMXC__SVMX_Event__c WHERE SVMXC__Technician__r.Salesforce_User__c IN : processRecordsForListOFUsers';

        woQuery +=  ' AND (DAY_ONLY(SVMXC__Start_Date_and_Time__c) >= :tsStartDate AND DAY_ONLY(SVMXC__End_Date_and_Time__c) <= :tsEndDate) ';
        taskQuery +=  ' AND (ActivityDate >= :tsStartDate AND ActivityDate <= :tsEndDate) ' ;
        SFEventQuery +=  ' AND (DAY_ONLY(StartDateTime) >= :tsStartDate  AND DAY_ONLY(EndDateTime) <= :tsEndDate) ' ;
        SVMXEventQuery +=  ' AND (DAY_ONLY(SVMXC__StartDateTime__c) >= :tsStartDate AND DAY_ONLY(SVMXC__EndDateTime__c) <= :tsEndDate) ' ;

        if(objectExpressions != null && objectExpressions.get('SVMXC__Service_Order_Line__c') != null)
            woQuery += ' AND ('+ objectExpressions.get('SVMXC__Service_Order_Line__c')+')'; 
        //TODO: No Duration Field in WODetail & Task 

        if(!mapTimesheetEntryWOentries.isEmpty()){
            Set <ID> lstWOLine = mapTimesheetEntryWOentries.keyset();
            woQuery +=' AND Id NOT IN : lstWOLine';
        } 

        if(objectExpressions != null && objectExpressions.get('Task') != null)
            taskQuery += ' AND ('+ objectExpressions.get('Task')+')'; 

        if(!mapTimesheetEntrySFTasks.isEmpty()){
            Set <ID> lsttask = mapTimesheetEntrySFTasks.keyset();
            taskQuery +=' AND Id NOT IN : lsttask';
        }   

        if(objectExpressions != null && objectExpressions.get('Event') != null)
            SFEventQuery += ' AND ('+ objectExpressions.get('Event')+')';

        if(!mapTimesheetEntrySFEvents.isEmpty()){
            Set <ID> listSFEvents = mapTimesheetEntrySFEvents.keyset();
            SFEventQuery +=' AND Id NOT IN : listSFEvents';
        }

        if(objectExpressions != null && objectExpressions.get('SVMXC__SVMX_Event__c') != null)
            SVMXEventQuery += ' AND ('+ objectExpressions.get('SVMXC__SVMX_Event__c')+')';

        if(!mapTimesheetEntrySVMXEvents.isEmpty()){
            Set <ID> lstSVMXEvents = mapTimesheetEntrySVMXEvents.keyset();
            SVMXEventQuery +='AND Id NOT IN : lstSVMXEvents';  
        }

        System.debug(LoggingLevel.WARN,'the SOQL for WD lines woQuery= '+woQuery);

        System.debug(LoggingLevel.WARN,'the SOQL for task lines taskQuery= '+taskQuery);
        System.debug(LoggingLevel.WARN,'the SOQL for events lines SFEventQuery= '+SFEventQuery);
        System.debug(LoggingLevel.WARN,'the SOQL for svmx event lines SVMXEventQuery= '+SVMXEventQuery);
        List<SVMXC__Service_Order_Line__c> userWOLIneList = Database.query(woQuery); // Workdetails SOQL
        System.debug('work details result '+userWOLIneList);
        List<Task> userTaskList = Database.query(taskQuery); //Task SOQL
        System.debug('Task details result '+userTaskList);
        List<Event> userSFEventList;
        if(eventTypeForProcess.toUpperCase() == 'EVENT' || eventTypeForProcess.toUpperCase() == 'BOTH'){
            userSFEventList = Database.query(SFEventQuery); //Salesforce Event SOQL
            System.debug('Salesforce events details result '+userSFEventList);
        }
        List<SVMXC__SVMX_Event__c> userSVMXEventList;
        if(eventTypeForProcess.toUpperCase() == 'SERVICEMAX EVENT' || eventTypeForProcess.toUpperCase() == 'BOTH'){
            userSVMXEventList = Database.query(SVMXEventQuery); // ServiceMax Event SOQL
            System.debug('Servicemax events details result '+userSVMXEventList);
        }
        
        processTechnicianAllRecords(userWOLIneList, userTaskList, userSFEventList, userSVMXEventList, openTimesheetheader);
        //End of SOQL
        //CreateTheTimeEntry
        Map <String, Schema.SObjectType> schemaMap = new Map <String, Schema.SObjectType>();
        Map <String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for(Schema.SObjectType s : gd.values()){
            schemaMap.put(s.getDescribe().getName(),s);
        }
        List<SVMXC__Timesheet_Entry__c> createListTimeSheetEntry = new List<SVMXC__Timesheet_Entry__c>();
        for(SVMXC__Timesheet__c listOfOpenTimesheetHeader : openTimesheetheader){
            if(!mapTSHdrWOLines.isEmpty() && mapTSHdrWOLines.containsKey(listOfOpenTimesheetHeader.id)){
                createListTimeSheetEntry.addAll(createTimesheetEntry (listOfOpenTimesheetHeader, mapTSHdrWOLines.get(listOfOpenTimesheetHeader.id), listObjectMapping.get('SVMXC__Service_Order_Line__c'), schemaMap));
            }
            if(!mapTSHdrTskLines.isEmpty() && mapTSHdrTskLines.containsKey(listOfOpenTimesheetHeader.id)){
                createListTimeSheetEntry.addAll(createTimesheetEntry (listOfOpenTimesheetHeader, mapTSHdrTskLines.get(listOfOpenTimesheetHeader.id), listObjectMapping.get('Task'), schemaMap));
            }
            if(!mapTSHdrEvtLines.isEmpty() && mapTSHdrEvtLines.containsKey(listOfOpenTimesheetHeader.id)){
                createListTimeSheetEntry.addAll(createTimesheetEntry (listOfOpenTimesheetHeader, mapTSHdrEvtLines.get(listOfOpenTimesheetHeader.id), listObjectMapping.get('Event'), schemaMap));
            }
            if(!mapTSHdrSEvtLines.isEmpty() && mapTSHdrSEvtLines.containsKey(listOfOpenTimesheetHeader.id)){
                createListTimeSheetEntry.addAll(createTimesheetEntry (listOfOpenTimesheetHeader, mapTSHdrSEvtLines.get(listOfOpenTimesheetHeader.id), listObjectMapping.get('SVMXC__SVMX_Event__c'), schemaMap));
            }
            
        }
        if(!createListTimeSheetEntry.isEmpty()){
            Integer totalRecord = createListTimeSheetEntry.size();
            List<String> listErrorDetails = new List<String>();
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( createListTimeSheetEntry, COMM_SecurityUtils.Access.Createable ) ) {
            List<Database.UpsertResult> updateResults = Database.upsert(createListTimeSheetEntry, false);
                for(Integer i=0;i<updateResults.size();i++){
                    if (updateResults.get(i).isSuccess()){
                        
                        }else if (!updateResults.get(i).isSuccess()){
                        
                        // DML operation failed
                        mapUpdateDailySummaryTotalHours.remove(createListTimeSheetEntry.get(i).SVMXC__Timesheet_Day__c);
                        Database.Error error = updateResults.get(i).getErrors().get(0);
                        system.debug('Failed record '+createListTimeSheetEntry.get(i));
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
                        if(createListTimeSheetEntry.get(i).SVMXC__Salesforce_Event__c  !=null)
                            errorMessageObject = 'Event '+createListTimeSheetEntry.get(i).SVMXC__Salesforce_Event__c  ;
                        }catch(Exception e){}
                        if(Limits.getHeapSize() <= 5000000){ // Don't add to list if it exceed more than 5MB 
                            listErrorDetails.add(errorMessageObject +'\n'+'Impacted time entry fields: ' + error.getMessage()); // Added for BAC-4865 22nd May
                        }
                        //End for BAC-4865 22nd May
                    }

                }
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( mapUpdateDailySummaryTotalHours.values(), COMM_SecurityUtils.Access.Updateable ) ) {
                update mapUpdateDailySummaryTotalHours.values();
            }else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            // Update only the Timesheet headers, whose time sheet daily summary gor updated.
            for(SVMXC__Timesheet_Day_Entry__c tSDailySummaryRec: mapUpdateDailySummaryTotalHours.values()){
                ID timesheetHeaderID = tSDailySummaryRec.SVMXC__Timesheet__c; 
                SVMXC__Timesheet__c timesheetHeaderRec = maptimesheetHeaderId.get(timesheetHeaderID);
                if(timesheetHeaderRec.SVMXC__Total_Hours__c == null){
                    timesheetHeaderRec.SVMXC__Total_Hours__c = 0;
                }
                // Got All the Timesheet Day entry record for this Header.
                Double headerTotalHours = tSDailySummaryRec.SVMXC__Total_Hours__c; 
                for(SVMXC__Timesheet_Day_Entry__c timeDayEntries :mapTimesheetHeaderandTimesheetDayEntry.get(timesheetHeaderID)){
                    if(timeDayEntries.SVMXC__Total_Hours__c == null){
                        timeDayEntries.SVMXC__Total_Hours__c = 0;
                    }
                    String timesDayEntryID = timeDayEntries.Id;  
                    if(!timesDayEntryID.equalsIgnoreCase(tSDailySummaryRec.id)){
                        headerTotalHours = headerTotalHours + timeDayEntries.SVMXC__Total_Hours__c;
                    }
                }
                
                timesheetHeaderRec.SVMXC__Total_Hours__c =  headerTotalHours; 
                maptimesheetHeaderId.put(timesheetHeaderID, timesheetHeaderRec);
            }
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( maptimesheetHeaderId.values(), COMM_SecurityUtils.Access.Updateable ) ) {
                update maptimesheetHeaderId.values();
            }else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            userAutofillVar.AutoFillStatus = getTAG007();
            //Send mail
            Integer autoFillcountSuccess = 0; 
            Integer autoFillcountFailure = 0; 
            List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
            TimeZone tz = UserInfo.getTimeZone();
            DateTime datetimeEnd = System.now();
            String strEndlog = '', afstrAttachmentlog = '';
            
            strEndlog = strEndlog+'\n\n'+getTAG010()+': '+dateTimeStart.format('MM/dd/yyyy HH:mm:ss', tz.getID())+' '+tz.getDisplayName()+' ('+tz+')';
            strEndlog = strEndlog+'\n'+getTAG011()+': '+datetimeEnd.format('MM/dd/yyyy HH:mm:ss', tz.getID())+' '+tz.getDisplayName()+' ('+tz+')';
            Decimal decCoutTime  = (Decimal.valueOf(((datetimeEnd.day()-dateTimeStart.day())*24*60*60)+((datetimeEnd.hour()-dateTimeStart.hour())*60*60)+((datetimeEnd.minute()-dateTimeStart.minute())*60)+(datetimeEnd.second()-dateTimeStart.second())))/60;
            Decimal decRounded = Math.round(decCoutTime * 100) / 100.0;
            strEndlog = strEndlog+'\n'+getTAG012()+': '+ decRounded.toPlainString();
            String strlogger = '';
            strlogger += '\n'+getTAG004() + ' '+listTimesheetAccessProcess[0].SVMXC__Dispatch_Process__r.Name;
            strlogger = strlogger+'\n'+getTAG022()+' '+listTimesheetAccessProcess[0].SVMXC__Dispatch_Process__r.SVMXC__ProcessID__c;

            if(userAutofillVar.workDetailCount > 0) //Added for BAC-5486
                afstrAttachmentlog += '\n' + getTAG017() +  userAutofillVar.workDetailCount;
            if(userAutofillVar.taskCount > 0)
                afstrAttachmentlog += '\n' + getTAG018() +  userAutofillVar.taskCount;
            if(userAutofillVar.eventCount > 0)
                afstrAttachmentlog += '\n' + getTAG019() +  userAutofillVar.eventCount;
            if(userAutofillVar.svmxEventCount > 0)
                afstrAttachmentlog += '\n' + getTAG020() +  userAutofillVar.svmxEventCount +'\n';
            if(userAutofillVar.AutoFillStatus ==  getTAG007() || userAutofillVar.AutoFillStatus == null){
                autoFillcountSuccess ++ ;
            }
            else{ 
                autoFillcountFailure ++ ;
            }
            

            String afstrLogPass = ''; 
            afstrLogPass = afstrLogPass+'\n\t'+getTAG006()+': '+1;
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
            if(!listErrorDetails.isEmpty()){ 
                afstrAttachmentlog = afstrAttachmentlog +'\n=========================================================\n The error has occurred while processing: \n' +'Timesheet Batch Error Log at' +System.Now().format()+'\n';
                afstrFinaLlogger = afstrFinaLlogger +'\n=========================================================\n The error has occurred while processing: \n' +'Timesheet Batch Error Log at ' +System.Now().format()+'\n';
                for(String errorStringVar: listErrorDetails){
                    afstrAttachmentlog = afstrAttachmentlog + '\n' + errorStringVar + '\n';
                    afstrFinaLlogger = afstrFinaLlogger+ '\n' + errorStringVar + '\n';
                }
            }
            Messaging.EmailFileAttachment Attc = new Messaging.EmailFileAttachment();
            blob attachBlob = Blob.valueOf(afstrAttachmentlog);
            string flename= getTAG014()+'_'+afstrNowDateMail+'.txt';
            Attc.setFileName(flename);
            Attc.setBody(attachBlob);
            Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
            String subject = getTAG021()+' '+afstrNowDateMail;
            email.setSubject(subject);
            email.saveAsActivity = false;
            List<String> lstEmailIDs = new List<String>();
            lstEmailIDs.add(UserInfo.getUserEmail());
            email.setToAddresses(lstEmailIDs);
            email.setPlainTextBody(afstrFinaLlogger);
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{Attc});
            mails.add(email);
            if(mails != null && mails.size() > 0)
                Messaging.sendEmail(mails);
            //End of mail part
        }
    //End TimeEntry
        
    }
    private List<SVMXC__Timesheet_Entry__c> createTimesheetEntry(SVMXC__Timesheet__c listTimesheetHeader, List<SObject> listofRecToPopulate, Id sObjectMappingID, Map <String, Schema.SObjectType> schemaMap){
        List<SVMXC__Timesheet_Entry__c> createListTimeSheetEntryRetVal = new List<SVMXC__Timesheet_Entry__c>();
        if(listofRecToPopulate != null && listofRecToPopulate.size()>0){
            SFM_ApplyMapping applyMapping = new SFM_ApplyMapping();
            Map<String,Sobject> sourceRecIdTargetObjMap = new Map<String,Sobject> (); 
            for(SObject recList : listofRecToPopulate){
                sourceRecIdTargetObjMap.put(recList.Id,  new SVMXC__Timesheet_Entry__c());    
            }
            List <Sobject> appliedMappingRec = applyMapping.getApplyMapping1(sObjectMappingID ,sourceRecIdTargetObjMap, false,schemaMap);
            for(SObject recList : appliedMappingRec){
                System.debug('recList '+recList);
                SVMXC__Timesheet_Entry__c timeSheetEnrty = (SVMXC__Timesheet_Entry__c)recList;
                
                timeSheetEnrty.SVMXC__Timesheet__c = listTimesheetHeader.Id;
                List<SVMXC__Timesheet_Day_Entry__c> listTimesheetDayEntry = mapTimesheetHeaderandTimesheetDayEntry.get(listTimesheetHeader.Id);
                ID timesheetHeaderBusinessHourId = listTimesheetHeader.SVMXC__SM_Business_Hours__c;
                String timeZoneforTSHeader = listTimesheetHeader.SVMXC__SM_Business_Hours__c != null ? listTimesheetHeader.SVMXC__SM_Business_Hours__r.TimeZoneSidKey : UserInfo.getTimeZone().getID();// Added for BAC-4851
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
                System.debug('businessHourId '+timesheetHeaderBusinessHourId);
                timeSheetEnrty.SVMXC__SM_Time_Zone__c = timeZoneforTSHeader; 
                //End for BAC-5388
                //To Do: Duration need to come from Configuration defined by Servicemax Process 
                if(timeSheetEnrty != null && timeSheetEnrty.SVMXC__Duration__c == null && timeSheetEnrty.SVMXC__End_Time__c != null && timeSheetEnrty.SVMXC__Start_Time__c != null){
                    Long milliSec = BusinessHours.diff(timesheetHeaderBusinessHourId, timeSheetEnrty.SVMXC__Start_Time__c,timeSheetEnrty.SVMXC__End_Time__c );
                    timeSheetEnrty.SVMXC__Duration__c = Decimal.valueOf(milliSec).divide(1000*60*60,2);   
                }
                else{
                    if(timeSheetEnrty.SVMXC__Duration__c != null){
                        timeSheetEnrty.SVMXC__Duration__c = timeSheetEnrty.SVMXC__Duration__c;
                    }
                }
                System.debug('timeSheetEnrty '+timeSheetEnrty);
                if(timeSheetEnrty.SVMXC__Start_Time__c != null){
                    Datetime userDT = timeSheetEnrty.SVMXC__Start_Time__c;
                    Date timeSheetEntryStartDate = date.valueOf(userDT.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader));
                    for(SVMXC__Timesheet_Day_Entry__c timesheetDayEntry :  listTimesheetDayEntry){
                        Date timesheetEntryDay = timesheetDayEntry.SVMXC__Timsheet_Day__c; 
                        if(timeSheetEntryStartDate.isSameDay(timesheetEntryDay)){
                            if(timesheetDayEntry.SVMXC__Total_Hours__c == null){
                                timesheetDayEntry.SVMXC__Total_Hours__c = 0;
                            }
                            if(mapUpdateDailySummaryTotalHours.get(timesheetDayEntry.Id) == null){
                                Double dailySummaryTotalHours = timeSheetEnrty.SVMXC__Duration__c;
                                for(SVMXC__Timesheet_Entry__c timeEntries :mapTimesheetHeaderEntries.get(listTimesheetHeader.Id)){
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
                    //Added for BAC-5486
                    if(timeSheetEnrty.get('SVMXC__Work_Detail__c') != null){
                        userAutofillVar.workDetailCount = userAutofillVar.workDetailCount+ 1; 
                    }else if(timeSheetEnrty.get('SVMXC__Task__c') != null){
                        userAutofillVar.taskCount = userAutofillVar.taskCount + 1;
                    }else if(timeSheetEnrty.get('SVMXC__Salesforce_Event__c') != null){
                        userAutofillVar.eventCount = userAutofillVar.eventCount + 1;
                    }else if(timeSheetEnrty.get('SVMXC__ServiceMax_Event__c') != null){
                        userAutofillVar.svmxEventCount = userAutofillVar.svmxEventCount + 1;
                    }
                    //Added for BAC-5486
                    createListTimeSheetEntryRetVal.add(timeSheetEnrty);
                }
                
                System.debug(LoggingLevel.WARN, 'Timesheet Entry Created ' + createListTimeSheetEntryRetVal);
            }
        }
        return createListTimeSheetEntryRetVal;
    }

    private void processTechnicianAllRecords(List<SVMXC__Service_Order_Line__c> userWOLIneList, List<Task> userTaskList, List<Event> userSFEventList, List<SVMXC__SVMX_Event__c> userSVMXEventList, List<SVMXC__Timesheet__c> openTimesheetheader){
        
        for(SVMXC__Timesheet__c openTimesheetHeaderVar : openTimesheetheader){
            String timeZoneforTSHeader = openTimesheetHeaderVar.SVMXC__SM_Business_Hours__c != null ? openTimesheetHeaderVar.SVMXC__SM_Business_Hours__r.TimeZoneSidKey : UserInfo.getTimeZone().getID();
            if(userWOLIneList != null && !userWOLIneList.isEmpty()){
                List<SVMXC__Service_Order_Line__c> lstWOSLine = new List<SVMXC__Service_Order_Line__c>();
                for(SVMXC__Service_Order_Line__c uwl: userWOLIneList){
                    //Added for BAC-5388
                    if(getTimeZoneFrom.equalsIgnoreCase(woBusinessHour)){
                        if(uwl.SVMXC__Service_Order__c == null || uwl.SVMXC__Service_Order__r.SVMXC__Preferred_Business_Hours__c == null){
                            continue;
                        }
                        timeZoneforTSHeader = uwl.SVMXC__Service_Order__r.SVMXC__Preferred_Business_Hours__r.TimeZoneSidKey;
                        UserTimezoneInfo userTZVar = new UserTimezoneInfo();
                        userTZVar.businessHourId = uwl.SVMXC__Service_Order__r.SVMXC__Preferred_Business_Hours__c;
                        userTZVar.timeZoneValue = timeZoneforTSHeader;
                        mapRecordsWithTimezone.put(uwl.id,userTZVar);
                    }
                    // end for BAC-5388
                    if(date.valueOf(uwl.SVMXC__Start_Date_and_Time__c.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)) >= openTimesheetHeaderVar.SVMXC__Start_Date__c 
                        && date.valueOf(uwl.SVMXC__End_Date_and_Time__c.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)) <= openTimesheetHeaderVar.SVMXC__End_Date__c)
                    {
                        lstWOSLine.add(uwl);    
                    }else if( // Added for 045467
                        checkDatesBetweenTSHeaders(date.valueOf(uwl.SVMXC__Start_Date_and_Time__c.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)), openTimesheetHeaderVar.SVMXC__Start_Date__c, openTimesheetHeaderVar.SVMXC__End_Date__c) 
                        && date.valueOf(uwl.SVMXC__End_Date_and_Time__c.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)) > openTimesheetHeaderVar.SVMXC__End_Date__c
                        && date.valueOf(uwl.SVMXC__End_Date_and_Time__c.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)) <= Date.valueOf(System.now().format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)))
                    {
                        lstWOSLine.add(uwl);
                    }
                }
                if(!lstWOSLine.isEmpty()){
                    mapTSHdrWOLines.put(openTimesheetHeaderVar.id,lstWOSLine);
                }
            }      
            if(userTaskList !=null && !userTaskList.isEmpty()){
                //Added for BAC-5388
                Map<ID, SVMXC__Service_Order__c> mapWorkOrders;
                if(getTimeZoneFrom.equalsIgnoreCase(woBusinessHour)){
                    List<Id> lstWoIds = new List<Id>();
                    for(Task ue: userTaskList){
                        if(ue.WhatId != null)
                            lstWoIds.add(ue.WhatId);
                    }
                    if(!lstWoIds.isEmpty()){
                        mapWorkOrders = new Map<ID, SVMXC__Service_Order__c>([SELECT Id, SVMXC__Preferred_Business_Hours__r.TimeZoneSidKey FROM SVMXC__Service_Order__c where ID IN:lstWoIds]);
                    }
                }
                //End for BAC-5388
                List<Task> lstTskLine = new List<Task>();
                for(Task ut: usertaskList){
                    //Added for BAC-5388
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
                    if(ut.ActivityDate >= openTimesheetHeaderVar.SVMXC__Start_Date__c && ut.ActivityDate  <= openTimesheetHeaderVar.SVMXC__End_Date__c)
                    {
                        lstTskLine.add(ut);    
                    }
                }   
                if(!lstTskLine.isEmpty()){
                    mapTSHdrTskLines.put(openTimesheetHeaderVar.id,lstTskLine); 
                }
            }
            if(userSFEventList != null && !userSFEventList.isEmpty()){
                //Added for BAC-5388
                Map<ID, SVMXC__Service_Order__c> mapWorkOrders;
                if(getTimeZoneFrom.equalsIgnoreCase(woBusinessHour)){
                    List<Id> lstWoIds = new List<Id>();
                    for(Event ue: userSFEventList){
                        lstWoIds.add(ue.WhatId);
                    }
                    if(!lstWoIds.isEmpty()){
                        mapWorkOrders = new Map<ID, SVMXC__Service_Order__c>([SELECT Id, SVMXC__Preferred_Business_Hours__r.TimeZoneSidKey FROM SVMXC__Service_Order__c where ID IN:lstWoIds]);
                    }
                }
                //End for BAC-5388
                List<Event> lstEvtLine = new List<Event>();
                for(Event ue: userSFEventList){
                    //Added for BAC-5388
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
                    if(date.valueOf(ue.StartDateTime.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)) >= openTimesheetHeaderVar.SVMXC__Start_Date__c 
                        && date.valueOf(ue.EndDateTime.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)) <= openTimesheetHeaderVar.SVMXC__End_Date__c){
                            lstEvtLine.add(ue);    
                    }else if(checkDatesBetweenTSHeaders(date.valueOf(ue.StartDateTime.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)), openTimesheetHeaderVar.SVMXC__Start_Date__c, openTimesheetHeaderVar.SVMXC__End_Date__c) 
                        && date.valueOf(ue.EndDateTime.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)) > openTimesheetHeaderVar.SVMXC__End_Date__c
                        && date.valueOf(ue.EndDateTime.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)) <= Date.valueOf(System.now().format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)))
                    {
                            lstEvtLine.add(ue);
                    }
                }
                if(!lstEvtLine.isEmpty()){
                    mapTSHdrEvtLines.put(openTimesheetHeaderVar.id,lstEvtLine); 
                }
                    
            } 
            if(userSVMXEventList != null && !userSVMXEventList.isEmpty()){
                List<SVMXC__SVMX_Event__c> lstSEvtLine = new List<SVMXC__SVMX_Event__c>();
                for(SVMXC__SVMX_Event__c use: userSVMXEventList){
                    //Added for BAC-5388
                    if(getTimeZoneFrom.equalsIgnoreCase(woBusinessHour)){
                        if(use.SVMXC__Service_Order__c == null || use.SVMXC__Service_Order__r.SVMXC__Preferred_Business_Hours__c == null){
                            continue;
                        }
                        timeZoneforTSHeader = use.SVMXC__Service_Order__r.SVMXC__Preferred_Business_Hours__r.TimeZoneSidKey;
                        UserTimezoneInfo userTZVar = new UserTimezoneInfo();
                        userTZVar.businessHourId = use.SVMXC__Service_Order__r.SVMXC__Preferred_Business_Hours__c;
                        userTZVar.timeZoneValue = timeZoneforTSHeader;
                        mapRecordsWithTimezone.put(use.id,userTZVar);
                    }
                    // end for BAC-5388
                    if(date.valueOf(use.SVMXC__StartDateTime__c.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)) >= openTimesheetHeaderVar.SVMXC__Start_Date__c 
                        && date.valueOf(use.SVMXC__EndDateTime__c.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)) <= openTimesheetHeaderVar.SVMXC__End_Date__c){
                            lstSEvtLine.add(use);    
                        }else if(checkDatesBetweenTSHeaders(date.valueOf(use.SVMXC__StartDateTime__c.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)), openTimesheetHeaderVar.SVMXC__Start_Date__c, openTimesheetHeaderVar.SVMXC__End_Date__c) 
                            && date.valueOf(use.SVMXC__EndDateTime__c.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)) > openTimesheetHeaderVar.SVMXC__End_Date__c
                            && date.valueOf(use.SVMXC__EndDateTime__c.format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)) <= Date.valueOf(System.now().format('yyyy-MM-dd HH:mm:ss',timeZoneforTSHeader)))
                        {
                            lstSEvtLine.add(use); 
                        }
                }
                if(!lstSEvtLine.isEmpty()){
                    mapTSHdrSEvtLines.put(openTimesheetHeaderVar.id,lstSEvtLine); 
                }                
            }
            System.debug('mapTSHdrSEvtLines '+mapTSHdrSEvtLines);
        }
    }
    // This method is used to know a date is in between two dates
    private boolean checkDatesBetweenTSHeaders(Date tempDate, Date startDate, Date endDate){
        Boolean foundDate = false;
        if(tempDate >= startDate && tempDate <= endDate){
            foundDate = true;
        }
        return foundDate;
    }
    public class UserTimezoneInfo { // To store businesshour along with respected timezone
        public Id businessHourId;
        public String timeZoneValue;
        public UserTimezoneInfo(){

        }
    }
    /* Internal class to get User Autofill Info  */
    public class UserAutofillInfo {
        public Integer workDetailCount = 0; 
        public Integer taskCount = 0; 
        public Integer eventCount = 0; 
        public Integer svmxEventCount = 0;
        public String AutoFillStatus; 
        public UserAutofillInfo (){
            
        }
    }
    private string getTAG001(){return System.label.COMM001_TAG093;}//'NOTE: THIS IS A SYSTEM GENERATED EMAIL. PLEASE DO NOT REPLY TO THIS MESSAGE.'
    private String getTAG004(){return System.label.TMST001_TAG022;} // Scheduled Timesheet Configuration Name:
    private string getTAG006(){return System.label.CONF039_TAG019;} //'Records to Process'
    private string getTAG007(){return System.label.COMM001_TAG096;} //'Success'
    private string getTAG008(){return System.label.COMM001_TAG097;} //'Failed'  
    private string getTAG010(){return System.label.CONF039_TAG038;} //'Scheduler Start Time'
    private string getTAG011(){return System.label.CONF039_TAG039;} //'Scheduler Finish Time' 
    private string getTAG012(){return System.label.CONF039_TAG022;} //'Elapsed Time in minutes'
    private string getTAG014(){return System.label.COMM001_TAG095;} //'Attachment'
    private string getTAG016(){return System.label.TMST001_TAG021;} //Scheduled Timesheet Entry creation has completed with the following results:
    private string getTAG017(){return System.label.TMST001_TAG032;} // No. of Work Details processed
    private string getTAG018(){return System.label.TMST001_TAG033;} // No. of Tasks processed
    private string getTAG019(){return System.label.TMST001_TAG034;} // No. of Salesforce Event processed
    private string getTAG020(){return System.label.TMST001_TAG035;} // No. of ServiceMax Event processed
    private string getTAG021(){return System.label.TMST001_TAG026;} // ServiceMax: Timesheet Entry Scheduled Status on:
    private string getTAG022(){return System.label.TMST001_TAG031;} // Process ID
}