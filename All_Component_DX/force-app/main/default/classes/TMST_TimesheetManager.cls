/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The TMST_TimesheetManager implements methods to convert JSON request to
 * TMST_WrapperDef.TMST_Request and TMST_WrapperDef.TMST_Response back to JSON
 * String. This controller methods are invoked by TimesheetManage Visual force
 * page. 
 * 
 * @author Ramachandra Mohan
 * @version 15.49100
 * @since 2015
 */
/*****************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************
 *              Ramachandra Mohan      18 Mar 2015     Created. 
 * 018852       Ramachandra Mohan      10 Jul 2015     Support to retrieve/save timezone.
 * 028541       Ramachandra Mohan      29 Mar 2016     Validation for inactive business hours.
 * BAC-542      Ramachandra Mohan      02 Aug 2016     Support for Run Now.
 * SER-6232     Sourabh Singh          06 Dec 2016     Commented out code for Bi monthly second 
 *                                                     recurrence config record creation 
 * BAC-1276     Sourabh Singh          19 Dec 2016     changes to support prior time sheet entries
 *  BAC-4864    Soumyaranjan Pati       10th May 2019   Timesheet ehancement for autofill
 *BAC-5149      Soumyaranjan Pati      20th Aug 2019    Timesheet Autofill Engine - Increase daily batch executions from 4 to 6
 * BAC-5189     Soumyaranjan Pati       9th Sept 2019   Configuration Profile Setting to Filter Which Users have Timesheets Processed
 * BAC-5411     Soumyaranjan Pati       4th Dec 2019    Timesheet Scheduler Engine improvement 
 *****************************************************************************/

global with sharing class TMST_TimesheetManager {
 
    class ProfileAssociation {
    
        public String profileId;
        public String profileName;
        public String description;
        public Boolean status;

        public String timesheetProcessId;
        public String timesheetProcessName;
        public List<TMST_WrapperDef.SalesforceProfileAssociation> ProfileAssociation = new List<TMST_WrapperDef.SalesforceProfileAssociation>(); // Added for BAC-5189
        public ProfileAssociation() {}
    }
    
    class AutofillInfo {
    
        public String period;
        public String[] weekOn = new String[]{};
        public Integer timeAt;
        public Integer pPeriods; //added BAC-1276:19Dec2016:Sourabh
        public Integer dayToRun;
        public Integer hourFrequency; //Added for the story BAC-4863
        public String timezoneSource; //Added for BAC-5388
        public Decimal runEvery;
        public Decimal startOfPeriodDate;
        public Decimal endOfPeriodDate;
        public String scheduleId;
        public String secondRecurrenceScheduleId;        
        public Integer secondRecurrenceDay;
        public String startingon;
        public String continuingthrough;        
        public String eventType;
        public String workDetailOwnership;        
        
        public String workDetailsCriteria;
        public String taskCriteria;
        public String eventCriteria;
        public String workDetailTimeEntryMapping;
        public String taskTimeEntryMapping;
        public String eventTimeEntryMapping;
        public String servicemaxEventCriteria;
        public String servicemaxEventTimeEntryMapping;
        
        public Boolean status;   
        
        public AutofillInfo() {}
    }
    
    class TimesheetInfo {
    
        public String timesheetProcessId;
        public String timesheetName;
        public String period;
        public Boolean status;
        public String lastModified;
        public String description;
        public Boolean notifyOnTimesheetCreation;
        public Boolean showWeekends;
        public String emailOnSuccess;
        public String emailOnError;
        public String timezone;
        public String businessHoursName;
        
        // to support run now.
        public String scheduleType;
        /*
        public Decimal minimumIncrement;
        public Decimal minimumHoursPerPeriod;
        public Decimal minimumHoursPerDay;
        public Decimal maximumHoursPerPeriod;
        public Decimal maximumHoursPerDay;
        public Integer thresholdHoursPerPeriod;
        public Integer thresholdHoursPerDay;
        */
        public Integer dayToRun;
        public Decimal runEvery;
        public Decimal startOfPeriodDate;
        public Decimal endOfPeriodDate;
        public String scheduleId;
        public String secondRecurrenceScheduleId;        
        public Integer secondRecurrenceDay;
        public Boolean allowAutofill;        
        public String[] weekOn = new String[]{};
        public List<String> tsHeaderStatus = new List<String>();  //Added for BAC-5411
        public Integer timeAt;
        public String startingon;
        public String continuingthrough;
        
        public AutofillInfo autofillInfo;
        
        public List<ProfileAssociation> assignedProfilesList = new List<ProfileAssociation>();
        
        public TimesheetInfo() {
            autofillInfo = new AutofillInfo();
        }
    }
    
    class Output {
    
        public Boolean success;
        public Boolean warning;
        public String message;
        
        public List<TimesheetInfo> timesheetInfoList = new List<TimesheetInfo>();
        public List<ProfileAssociation> profileAssociationList = new List<ProfileAssociation>();
        public List<TMST_WrapperDef.ObjectInfo> businessHoursList = new List<TMST_WrapperDef.ObjectInfo>();        
        public List<TMST_WrapperDef.ObjectInfo> workDetailOwnershipList = new List<TMST_WrapperDef.ObjectInfo>();
        public List<TMST_WrapperDef.ObjectInfo> timezoneList = new List<TMST_WrapperDef.ObjectInfo>();
        public List<TMST_WrapperDef.ObjectInfo> priorPeriodList = new List<TMST_WrapperDef.ObjectInfo>(); //added BAC-1276:19Dec2016:Sourabh
        
        public List<TMST_WrapperDef.ObjectInfo> workDetailsMappingList = new List<TMST_WrapperDef.ObjectInfo>();
        public List<TMST_WrapperDef.ObjectInfo> workDetailsRuleList = new List<TMST_WrapperDef.ObjectInfo>();
        public List<TMST_WrapperDef.ObjectInfo> taskMappingList = new List<TMST_WrapperDef.ObjectInfo>();
        public List<TMST_WrapperDef.ObjectInfo> taskRuleList = new List<TMST_WrapperDef.ObjectInfo>();
        public List<TMST_WrapperDef.ObjectInfo> eventMappingList = new List<TMST_WrapperDef.ObjectInfo>();
        public List<TMST_WrapperDef.ObjectInfo> eventRuleList = new List<TMST_WrapperDef.ObjectInfo>();
        public List<TMST_WrapperDef.ObjectInfo> servicemaxEventMappingList = new List<TMST_WrapperDef.ObjectInfo>();
        public List<TMST_WrapperDef.ObjectInfo> servicemaxEventRuleList = new List<TMST_WrapperDef.ObjectInfo>();
        public Map<String,String> tsHeaderStatusMap = new Map<String,String>();  //Added for BAC-5411
        
        public Output() {
        }
    }
    
    /**
     * This method is used to retrieve current user information for the Org.
     * 
     * @return Returns user information in JSON format.
     */
    public String getUserInfo(){

       return JSON.serialize( new SVMXC.SFMDeliveryServiceImpl().getUserInfoInternal() );
    }
    
    public TMST_TimesheetManager() {}
    
    @RemoteAction
    global static Object executeBatch( String requestStr ) {
    
        System.debug( LoggingLevel.DEBUG, 'executeBatch() - enter; request= ' + requestStr );
        
        Output result = new Output();

        try {
            
            TimesheetInfo tsRequestInfo = (TimesheetInfo) JSON.deserialize( requestStr, TimesheetInfo.class );
            
            TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = new TMST_WrapperDef.TMST_TimesheetConfiguration();
            timesheetConfiguration.timesheetProcess.SVMXC__ProcessID__c = tsRequestInfo.timesheetProcessId;
            timesheetConfiguration.scheduleType = tsRequestInfo.scheduleType;
            
            TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();
            request.timesheetConfigurationList.add( timesheetConfiguration );
            
            TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
            TMST_WrapperDef.TMST_Response response = timesheetManager.executeBatch( request );
            result.success = response.success;
            result.message = TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK );
        }
        catch( Exception ex ) {
            
            result.success = false;
            result.message = System.Label.TMST001_TAG006;
        }
        
        System.debug( LoggingLevel.DEBUG, 'executeBatch() - exit' );
        
        return JSON.serialize( result );
    }
    
    @RemoteAction
    global static Object getObjectMappingAndSVMXRules( String requestStr ) {
    
        System.debug( LoggingLevel.DEBUG, 'getObjectMappingAndSVMXRules() - enter; request= ' + requestStr );
        
        Output result = new Output();

        TMST_WrapperDef.TMST_Response response = TMST_TimesheetUtils.getInstance().getObjectMappingAndSVMXRules();
        result.success = response.success;
        result.warning = response.warning;
        result.message = TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK );
        
        if( result.success ) {
            
            result.workDetailsMappingList = response.workDetailsMappingList; 
            result.workDetailsRuleList = response.workDetailsRuleList;
        
            result.taskMappingList = response.taskMappingList;
            result.taskRuleList = response.taskRuleList;
        
            result.eventMappingList = response.eventMappingList;
            result.eventRuleList = response.eventRuleList;
            
            result.servicemaxEventMappingList = response.servicemaxEventMappingList;
            result.servicemaxEventRuleList = response.servicemaxEventRuleList;
        }
        
        System.debug( LoggingLevel.DEBUG, 'getObjectMappingAndSVMXRules() - exit' );
        
        return JSON.serialize( result );
    }
    
    @RemoteAction
    global static Object getWorkDetailOwnership( String requestStr ) {
        System.debug( LoggingLevel.DEBUG, 'getWorkDetailOwnership() - enter; request= ' + requestStr );
        
        Output result = new Output();

        TMST_WrapperDef.TMST_Response response = TMST_TimesheetUtils.getInstance().getWorkDetailOwnership();
        result.success = response.success;
        result.warning = response.warning;
        result.message = TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK );
        
        try {
        
            if( result.success ) {
            
                for( TMST_WrapperDef.TMST_WorkDetailOwnership workDetailOwnership : response.workDetailOwnershipList  ) {
                
                    TMST_WrapperDef.ObjectInfo wdo = new TMST_WrapperDef.ObjectInfo();
                    wdo.Id = workDetailOwnership.labelName;
                    wdo.name = workDetailOwnership.apiName;
                    
                    result.workDetailOwnershipList.add( wdo );
                }
            }
        }
        
        catch( System.Exception ex ) {
        
            result.success = false;
            result.message = System.Label.TMST001_TAG006;
        }
        
        System.debug( LoggingLevel.DEBUG, 'getWorkDetailOwnership() - exit' );
        
        return JSON.serialize( result );
    }
    
    @RemoteAction
    global static Object getAllTimezones( String requestStr ) {
    
        System.debug( LoggingLevel.DEBUG, 'getAllTimezones() - enter; request= ' + requestStr );
        
        Output result = new Output();

        TMST_WrapperDef.TMST_Response response = TMST_TimesheetUtils.getInstance().getAllTimezones();
        result.success = response.success;
        result.warning = response.warning;
        result.message = TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK );
        
        try {        
            if( result.success ) {            
                result.timezoneList = response.timezoneList;
            }
        }
        
        catch( System.Exception ex ) {
        
            result.success = false;
            result.message = System.Label.TMST001_TAG006;
            
            System.debug( LoggingLevel.ERROR, 'getAllTimezones() : ' + ex.getMessage() );
        }
        
        System.debug( LoggingLevel.DEBUG, 'getAllTimezones() - exit' );
        
        return JSON.serialize( result );
    }

    @RemoteAction //added BAC-1276:19Dec2016:Sourabh
    global static Object getPickValues(String requestStr) 
     {
          System.debug( LoggingLevel.DEBUG, 'getPickValues() - enter; request= ' + requestStr );
          Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(requestStr);
          String fieldname = (String)m.get('fieldName');
          String objectname = (String)m.get('objName');

          Output result = new Output();
        TMST_WrapperDef.TMST_Response response = TMST_TimesheetUtils.getInstance().getPickValues(objectname,fieldname);
        result.success = response.success;
        result.warning = response.warning;
        result.message = TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK );
        
        try {        
            if( result.success ) 
            {   
                //Please add similar if block for every new object and picklist field you call the getPickValues method for
                if(objectname =='SVMXC__ServiceMax_Config_Data__c' && fieldname == 'SVMXC__SM_Prior_Timesheet_Periods__c')
                   result.priorPeriodList = response.priorPeriodList;
            }
        }
        catch( System.Exception ex ) 
            {
             result.success = false;
             result.message = System.Label.TMST001_TAG006; 
             System.debug( LoggingLevel.ERROR, 'getPickValues() : ' + ex.getMessage() );
            }
        
        System.debug( LoggingLevel.DEBUG, 'getPickValues() - exit' );        
        return JSON.serialize( result );
     }
    
    @RemoteAction
    global static Object getBusinessHours( String requestStr ) {
    
        System.debug( LoggingLevel.DEBUG, 'getBusinessHours() - enter; request= ' + requestStr );
        
        Output result = new Output();

        TMST_WrapperDef.TMST_Response response = TMST_TimesheetUtils.getInstance().getBusinessHours();
        result.success = response.success;
        result.warning = response.warning;
        result.message = TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK );
        
        try {
        
            if( result.success ) {
            
                for( BusinessHours tmstBusinessHours : response.businessHoursList ) {
                    
                    TMST_WrapperDef.ObjectInfo tmstBusinessHour = new TMST_WrapperDef.ObjectInfo();
                    tmstBusinessHour.Id = tmstBusinessHours.Id;
                    tmstBusinessHour.name = tmstBusinessHours.Name;
                    
                    result.businessHoursList.add( tmstBusinessHour );
                }
            }
        }
        
        catch( System.Exception ex ) {
        
            result.success = false;
            result.message = System.Label.TMST001_TAG006;
        }
        
        System.debug( LoggingLevel.DEBUG, 'getBusinessHours() - exit' );
        
        return JSON.serialize( result );
    }
    
    @RemoteAction
    global static Object getAllTimesheetProcess( String requestStr ) {
    
        System.debug( LoggingLevel.DEBUG, 'getAllTimesheetProcess() - enter; request= ' + requestStr );
        
        Output result = new Output();
        
        TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
        TMST_WrapperDef.TMST_Response response = timesheetManager.getAllTimesheetProcess();
        result.success = response.success;
        result.warning = response.warning;
        result.message = TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK );
        
        try {
        
            if( result.success ) {
                //Added for BAC-5411
                result.tsHeaderStatusMap = TMST_TimesheetUtils.getStatusPickListValue();
                //End for BAC-5411
                Map<Id,BusinessHours> activeBusinessHoursMap = new Map<Id, BusinessHours>();
                activeBusinessHoursMap.putAll( [SELECT Id,Name FROM BusinessHours WHERE IsActive = true] );
                //Started Added for BAC-5189
                Map<String, List<TMST_WrapperDef.SalesforceProfileAssociation>> mapProcesswithSalesforceProfile = new Map<String, List<TMST_WrapperDef.SalesforceProfileAssociation>>();
                for(TMST_WrapperDef.SalesforceProfileAssociation sfdcProfile: response.salesforceProfileIds){
                        TMST_WrapperDef.SalesforceProfileAssociation sfdcWrapVar = new TMST_WrapperDef.SalesforceProfileAssociation();
                        sfdcWrapVar.profileId = sfdcProfile.profileId;
                        sfdcWrapVar.profileName = sfdcProfile.profileName;
                        sfdcWrapVar.description = sfdcProfile.description;
                        sfdcWrapVar.leaf = sfdcProfile.leaf;
                        sfdcWrapVar.timesheetProcessId = sfdcProfile.timesheetProcessId;
                        sfdcWrapVar.timesheetProcessName = sfdcProfile.timesheetProcessName;
                        if(mapProcesswithSalesforceProfile.containsKey(sfdcProfile.timesheetProcessId)){
                            mapProcesswithSalesforceProfile.get(sfdcProfile.timesheetProcessId).add(sfdcWrapVar);
                        }else{
                            List<TMST_WrapperDef.SalesforceProfileAssociation> listSfdcWrapp = new List<TMST_WrapperDef.SalesforceProfileAssociation>();
                            listSfdcWrapp.add(sfdcWrapVar);
                            mapProcesswithSalesforceProfile.put(sfdcProfile.timesheetProcessId, listSfdcWrapp);
                        }   
                  }
                 
                System.debug('mapProcesswithSalesforceProfile '+mapProcesswithSalesforceProfile);
                //End Added for BAC-5189
                for( TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration : response.timesheetConfigurationList ) {
                
                    TimesheetInfo tsInfo = new TimesheetInfo();
                    tsInfo.timesheetName = timesheetConfiguration.timesheetProcess.SVMXC__Name__c;
                    tsInfo.timesheetProcessId = timesheetConfiguration.timesheetProcess.SVMXC__ProcessID__c;
                    tsInfo.description = timesheetConfiguration.timesheetProcess.SVMXC__Description__c;
                    tsInfo.status = timesheetConfiguration.timesheetProcess.SVMXC__Active__c;
                    tsInfo.emailOnSuccess = timesheetConfiguration.timesheetProcess.SVMXC__Email_On_Success__c;
                    tsInfo.emailOnError = timesheetConfiguration.timesheetProcess.SVMXC__Email_On_Error__c;
                    
                    /*
                    tsInfo.maximumHoursPerPeriod = timesheetConfiguration.timesheetProcess.SVMXC__Max_Hours_Per_Period__c;
                    tsInfo.maximumHoursPerDay = timesheetConfiguration.timesheetProcess.SVMXC__Max_Hours_Per_Day__c;
                    tsInfo.minimumHoursPerPeriod = timesheetConfiguration.timesheetProcess.SVMXC__Min_Hours_Per_Period__c;
                    tsInfo.minimumHoursPerDay = timesheetConfiguration.timesheetProcess.SVMXC__Min_Hours_Per_Day__c;
                    tsInfo.minimumIncrement = timesheetConfiguration.timesheetProcess.SVMXC__Min_Increment__c;
                    */
                    tsInfo.notifyOnTimesheetCreation = timesheetConfiguration.timesheetProcess.SVMXC__Notify_technician__c;
                    tsInfo.lastModified = String.valueof( timesheetConfiguration.timesheetProcess.LastModifiedDate.date() );
                    tsInfo.startingon = String.valueof( timesheetConfiguration.timesheetProcess.SVMXC__Start_Date__c );
                    tsInfo.continuingthrough = String.valueof( timesheetConfiguration.timesheetProcess.SVMXC__End_Date__c );
                    tsInfo.timezone = timesheetConfiguration.timesheetProcess.SVMXC__Dispatch_Timezone__c;
                    
                    if( activeBusinessHoursMap.containsKey(timesheetConfiguration.timesheetProcess.SVMXC__Business_Hours__c) ) {
                        tsInfo.businessHoursName = timesheetConfiguration.timesheetProcess.SVMXC__Business_Hours__c;    
                    }
                    tsInfo.autofillInfo.timezoneSource = timesheetConfiguration.timesheetProcess.SVMXC__SM_Business_Hour_Source__c != null ? timesheetConfiguration.timesheetProcess.SVMXC__SM_Business_Hour_Source__c : 'Technician Record'; //Added for BAC-5388
                    tsInfo.autofillInfo.eventType = timesheetConfiguration.timesheetProcess.SVMXC__Event_Type__c;
                    tsInfo.autofillInfo.workDetailOwnership = timesheetConfiguration.timesheetProcess.SVMXC__Field_Name__c;
                    
                    tsInfo.autofillInfo.workDetailsCriteria = timesheetConfiguration.timesheetProcess.SVMXC__Process__c;
                    tsInfo.autofillInfo.taskCriteria = timesheetConfiguration.timesheetProcess.SVMXC__Node_Parent__c;
                    tsInfo.autofillInfo.eventCriteria = timesheetConfiguration.timesheetProcess.SVMXC__Parent_Object__c;
                    tsInfo.autofillInfo.workDetailTimeEntryMapping = timesheetConfiguration.timesheetProcess.SVMXC__Process1__c;
                    tsInfo.autofillInfo.taskTimeEntryMapping = timesheetConfiguration.timesheetProcess.SVMXC__Process2__c;
                    tsInfo.autofillInfo.eventTimeEntryMapping = timesheetConfiguration.timesheetProcess.SVMXC__Process3__c;
                    tsInfo.autofillInfo.servicemaxEventCriteria = timesheetConfiguration.timesheetProcess.SVMXC__Submodule__c;
                    tsInfo.autofillInfo.servicemaxEventTimeEntryMapping = timesheetConfiguration.timesheetProcess.SVMXC__Module__c;
                    Map<String,Integer> mapHourFrequencyAutofill = new Map<String,Integer>();
                    for( SVMXC__ServiceMax_Config_Data__c scheduleDetails: timesheetConfiguration.scheduleDetailsList ) {
                        
                        if( scheduleDetails.SVMXC__Schedule_Type__c.equalsIgnoreCase( TMST_Consts.SCHEDULE_TYPE_TIMESHEET_HEADER ) ) {
                        
                            tsInfo.period = scheduleDetails.SVMXC__Period__c;
                            
                            //tsInfo.weekOn = TMST_Consts.WEEK_STRING_TO_ID_MAP.get( scheduleDetails.SVMXC__Schedule_Days__c );
                            if( scheduleDetails.SVMXC__Schedule_Days__c != null ) {
                                tsInfo.weekOn = scheduleDetails.SVMXC__Schedule_Days__c.split( TMST_Consts.SEMICOLON );    
                            }
                            //Added for BAC-5411
                            if( scheduleDetails.SVMXC__Internal_Value__c != null ) {
                                tsInfo.tsHeaderStatus = scheduleDetails.SVMXC__Internal_Value__c.split(',');    
                            }else{
                                List<String> listStatusTemp = new List<String>{'Open'};
                                tsInfo.tsHeaderStatus = listStatusTemp;   
                            }
                            //End for BAC-5411                            
                            tsInfo.timeAt = TMST_Consts.TIMEAT_STRING_TO_ID_MAP.get( scheduleDetails.SVMXC__Run_At__c );
                            tsInfo.startOfPeriodDate = scheduleDetails.SVMXC__Period_Start_On__c;
                            tsInfo.endOfPeriodDate = scheduleDetails.SVMXC__Period_End_On__c;
                            //tsInfo.runEvery = scheduleDetails.SVMXC__Run_Frequency__c;
                                
                            if( scheduleDetails.SVMXC__Sequence__c == 1 ) {
                                
                                tsInfo.scheduleId = scheduleDetails.Id;
                                if( scheduleDetails.SVMXC__Day_to_Run__c != null ) {
                                    tsInfo.dayToRun = Integer.valueOf( scheduleDetails.SVMXC__Day_to_Run__c );
                                }
                            } else if( scheduleDetails.SVMXC__Sequence__c == 2 ) {
                                
                                tsInfo.secondRecurrenceScheduleId = scheduleDetails.Id;
                                if( scheduleDetails.SVMXC__Day_to_Run__c != null ) {
                                    tsInfo.secondRecurrenceDay = Integer.valueOf( scheduleDetails.SVMXC__Day_to_Run__c );
                                }
                            }                            
                        } else if( scheduleDetails.SVMXC__Schedule_Type__c.equalsIgnoreCase( TMST_Consts.SCHEDULE_TYPE_TIMESHEET_AUTOFILL ) ) {
                            
                            tsInfo.autofillInfo.period = scheduleDetails.SVMXC__Period__c;
                            //tsInfo.autofillInfo.weekOn = TMST_Consts.WEEK_STRING_TO_ID_MAP.get( scheduleDetails.SVMXC__Schedule_Days__c );
                            if( scheduleDetails.SVMXC__Schedule_Days__c != null ) {
                                tsInfo.autofillInfo.weekOn = scheduleDetails.SVMXC__Schedule_Days__c.split( TMST_Consts.SEMICOLON );    
                            }
                            tsInfo.autofillInfo.timeAt = TMST_Consts.TIMEAT_STRING_TO_ID_MAP.get( scheduleDetails.SVMXC__Run_At__c );
                            tsInfo.autofillInfo.startOfPeriodDate = scheduleDetails.SVMXC__Period_Start_On__c;
                            tsInfo.autofillInfo.endOfPeriodDate = scheduleDetails.SVMXC__Period_End_On__c;
                           
                           if( scheduleDetails.SVMXC__SM_Prior_Timesheet_Periods__c != null )
                                    tsInfo.autofillInfo.pPeriods = Integer.valueOf(scheduleDetails.SVMXC__SM_Prior_Timesheet_Periods__c);
                            //tsInfo.autofillInfo.runEvery = scheduleDetails.SVMXC__Run_Frequency__c;
                            
                            if( scheduleDetails.SVMXC__Sequence__c == 1 ) {
                                
                                tsInfo.autofillInfo.scheduleId = scheduleDetails.Id;
                                if( scheduleDetails.SVMXC__Day_to_Run__c != null ) {
                                    tsInfo.autofillInfo.dayToRun = Integer.valueOf( scheduleDetails.SVMXC__Day_to_Run__c );
                                }
                            } else if( scheduleDetails.SVMXC__Sequence__c == 2 ) {
                                
                                tsInfo.autofillInfo.secondRecurrenceScheduleId = scheduleDetails.Id;
                                if( scheduleDetails.SVMXC__Day_to_Run__c != null ) {
                                    tsInfo.autofillInfo.secondRecurrenceDay = Integer.valueOf( scheduleDetails.SVMXC__Day_to_Run__c );
                                }
                            }
                            if( scheduleDetails.SVMXC__Run_Type__c.equalsIgnoreCase('Day of Week') && scheduleDetails.SVMXC__Day_to_Run__c == '1'  ) { // Added for BAC-4864
                                tsInfo.autofillInfo.hourFrequency = Integer.valueOf( scheduleDetails.SVMXC__Sequence__c );
                                if(mapHourFrequencyAutofill.size() == 0){
                                    mapHourFrequencyAutofill.put(String.valueOf(scheduleDetails.SVMXC__Dispatch_Process__c)+scheduleDetails.SVMXC__Day_to_Run__c+scheduleDetails.SVMXC__Schedule_Type__c,tsInfo.autofillInfo.timeAt);
                                }
                                if(mapHourFrequencyAutofill.containsKey(String.valueOf(scheduleDetails.SVMXC__Dispatch_Process__c)+scheduleDetails.SVMXC__Day_to_Run__c+scheduleDetails.SVMXC__Schedule_Type__c))
                                    tsInfo.autofillInfo.timeAt = mapHourFrequencyAutofill.get(String.valueOf(scheduleDetails.SVMXC__Dispatch_Process__c)+scheduleDetails.SVMXC__Day_to_Run__c+scheduleDetails.SVMXC__Schedule_Type__c);
                            } // End for BAC-4864
                            
                            tsInfo.autofillInfo.status = scheduleDetails.SVMXC__Active__c;
                        }
                    }
                    
                    for( TMST_WrapperDef.TMST_TimesheetAccess assignedProfile : timesheetConfiguration.assignedProfilesList ) {
                        List<TMST_WrapperDef.SalesforceProfileAssociation> profileAssociationTemp = new List<TMST_WrapperDef.SalesforceProfileAssociation>(); //Added for BAC-5189
                        ProfileAssociation profileAssociation = new ProfileAssociation();
                        profileAssociation.profileId = assignedProfile.configProfile.Id;
                        profileAssociation.profileName = assignedProfile.configProfile.SVMXC__Profile_Name__c;
                        profileAssociation.description = assignedProfile.configProfile.SVMXC__Description__c;
                        profileAssociation.status = assignedProfile.configProfile.SVMXC__Active__c;
        
                        profileAssociation.timesheetProcessId = assignedProfile.timesheetProcessId;
                        profileAssociation.timesheetProcessName = assignedProfile.timesheetProcessName;
                        // Added for BAC-5189
                        if(assignedProfile.configProfile.SVMXC__SM_Scope__c != null){
                            System.debug('assignedProfile.configProfile.SVMXC__Profile_Name__c '+assignedProfile.configProfile.SVMXC__Profile_Name__c);
                            System.debug('assignedProfile.configProfile.SVMXC__SM_Scope__c '+assignedProfile.configProfile.SVMXC__SM_Scope__c);
                            SVMXC.TMST_WrapperDef.SalesforceProfileInfo tsWrap = new SVMXC.TMST_WrapperDef.SalesforceProfileInfo();
                            tsWrap = (SVMXC.TMST_WrapperDef.SalesforceProfileInfo) JSON.deserialize(assignedProfile.configProfile.SVMXC__SM_Scope__c, SVMXC.TMST_WrapperDef.SalesforceProfileInfo.class);
                            //List<SVMXC.TMST_WrapperDef.ObjectInfo> salesforceProfileIds = new List<SVMXC.TMST_WrapperDef.ObjectInfo>();
                            List<SVMXC.TMST_WrapperDef.ObjectInfo> salesforceProfileIds = tsWrap.salesforceProfileIds;
                            for(SVMXC.TMST_WrapperDef.ObjectInfo objectInfoVar: salesforceProfileIds){
                                TMST_WrapperDef.SalesforceProfileAssociation sfdcWrapVar = new TMST_WrapperDef.SalesforceProfileAssociation();

                                sfdcWrapVar.description = '';
                                sfdcWrapVar.leaf = true;
                                sfdcWrapVar.timesheetProcessId = assignedProfile.timesheetProcessId;
                                sfdcWrapVar.timesheetProcessName = assignedProfile.timesheetProcessName;

                                sfdcWrapVar.profileId = objectInfoVar.Id;
                                sfdcWrapVar.profileName = objectInfoVar.name;
                                System.debug('sfdcWrapVar '+sfdcWrapVar);
                                profileAssociationTemp.add(sfdcWrapVar);
                            }
                        }
                        profileAssociation.ProfileAssociation = profileAssociationTemp;
                        //End Added for BAC-5189
                        tsInfo.assignedProfilesList.add( profileAssociation );
                    }
                    
                    result.timesheetInfoList.add( tsInfo );
                }
                
                for( TMST_WrapperDef.TMST_TimesheetAccess timesheetAccess : response.profileAssociationList ) {
                
                    ProfileAssociation profileAssociation = new ProfileAssociation();
                    profileAssociation.profileId = timesheetAccess.configProfile.Id;
                    profileAssociation.profileName = timesheetAccess.configProfile.SVMXC__Profile_Name__c;
                    profileAssociation.description = timesheetAccess.configProfile.SVMXC__Description__c;
                    profileAssociation.status = timesheetAccess.configProfile.SVMXC__Active__c;
        
                    profileAssociation.timesheetProcessId = timesheetAccess.timesheetProcessId;
                    profileAssociation.timesheetProcessName = timesheetAccess.timesheetProcessName;
                    if(mapProcesswithSalesforceProfile.containsKey(timesheetAccess.configProfile.Id)){ // Added for BAC-5189
                        profileAssociation.ProfileAssociation = mapProcesswithSalesforceProfile.get(timesheetAccess.configProfile.Id);
                    }
            
                    result.profileAssociationList.add( profileAssociation );
                }
            }        
        }
        
        catch( System.Exception ex ) {
        
            result.success = false;
            result.message = 'Internal server error : ' + ex.getMessage();
        }
        
        System.debug( LoggingLevel.DEBUG, 'getAllTimesheetProcess() - exit' );
        
        return JSON.serialize( result );
    }
    
    @RemoteAction
    global static Object deleteTimesheetProcess( String requestStr ) {
    
        System.debug( 'deleteTimesheetProcess() - requestStr ' + requestStr );
        
        Output result = new Output();
        
        if( requestStr == null ) {
        
            result.success = false;
            result.message = 'Invalid Argument';
            
            return JSON.serialize( result );
        }
        
        try {
        
            TimesheetInfo tsRequestInfo = (TimesheetInfo) JSON.deserialize( requestStr, TimesheetInfo.class );
            
            TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = new TMST_WrapperDef.TMST_TimesheetConfiguration();
            timesheetConfiguration.timesheetProcess.SVMXC__ProcessID__c = tsRequestInfo.timesheetProcessId;
            
            TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();
            request.timesheetConfigurationList.add( timesheetConfiguration );
            
            TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
            TMST_WrapperDef.TMST_Response response = timesheetManager.deleteTimesheetProcess( request );
            result.success = response.success;
            result.warning = response.warning;
            result.message = TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK );
        }
        
        catch( System.JSONException ex ) {
        
            result.success = false;
            result.message = 'Invalid JSON request : ' + ex.getMessage();
        } 
        
        catch( System.Exception ex ) {
        
            result.success = false;
            result.message = 'Internal server error : ' + ex.getMessage();
        }
        
        return JSON.serialize( result );
    }
    
    @RemoteAction
    global static Object saveTimesheetConfiguration( String requestStr ) {
    
        System.debug( 'saveTimesheetConfiguration() - requestStr ' + requestStr );
        
        Output result = new Output();
        
        if( requestStr == null ) {
        
            result.success = false;
            result.message = 'Invalid Argument';
            
            return JSON.serialize( result );
        }
        
        try {
        
            TimesheetInfo tsRequestInfo = (TimesheetInfo) JSON.deserialize( requestStr, TimesheetInfo.class );  
            
            TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = new TMST_WrapperDef.TMST_TimesheetConfiguration();
            timesheetConfiguration.timesheetProcess.SVMXC__Name__c = tsRequestInfo.timesheetName;
            timesheetConfiguration.timesheetProcess.SVMXC__ProcessID__c = tsRequestInfo.timesheetProcessId;
            timesheetConfiguration.timesheetProcess.SVMXC__Description__c = tsRequestInfo.description;
            timesheetConfiguration.timesheetProcess.SVMXC__Active__c = tsRequestInfo.status;
            timesheetConfiguration.timesheetProcess.SVMXC__Email_On_Success__c = tsRequestInfo.emailOnSuccess;
            timesheetConfiguration.timesheetProcess.SVMXC__Email_On_Error__c = tsRequestInfo.emailOnError;
            
            /*
            timesheetConfiguration.timesheetProcess.SVMXC__Max_Hours_Per_Period__c = tsRequestInfo.maximumHoursPerPeriod;
            timesheetConfiguration.timesheetProcess.SVMXC__Max_Hours_Per_Day__c = tsRequestInfo.maximumHoursPerDay;
            timesheetConfiguration.timesheetProcess.SVMXC__Min_Hours_Per_Period__c = tsRequestInfo.minimumHoursPerPeriod;
            timesheetConfiguration.timesheetProcess.SVMXC__Min_Hours_Per_Day__c = tsRequestInfo.minimumHoursPerDay;
            timesheetConfiguration.timesheetProcess.SVMXC__Min_Increment__c = tsRequestInfo.minimumIncrement;
            */
            timesheetConfiguration.timesheetProcess.SVMXC__Notify_technician__c = tsRequestInfo.notifyOnTimesheetCreation;
            if( tsRequestInfo.startingon != null ) {
                timesheetConfiguration.timesheetProcess.SVMXC__Start_Date__c = Date.valueOf( tsRequestInfo.startingon );
            }
            if( tsRequestInfo.continuingthrough != null ) {
                timesheetConfiguration.timesheetProcess.SVMXC__End_Date__c = Date.valueOf( tsRequestInfo.continuingthrough );
            }
            
            timesheetConfiguration.timesheetProcess.SVMXC__Dispatch_Timezone__c = tsRequestInfo.timezone;
            timesheetConfiguration.timesheetProcess.SVMXC__Business_Hours__c = tsRequestInfo.businessHoursName;
            
            if( tsRequestInfo.autofillInfo != null ) {
            
                timesheetConfiguration.timesheetProcess.SVMXC__SM_Business_Hour_Source__c = tsRequestInfo.autofillInfo.timezoneSource; // Added for BAC-5388
                timesheetConfiguration.timesheetProcess.SVMXC__Event_Type__c = tsRequestInfo.autofillInfo.eventType;
                timesheetConfiguration.timesheetProcess.SVMXC__Field_Name__c = tsRequestInfo.autofillInfo.workDetailOwnership;
                
                timesheetConfiguration.timesheetProcess.SVMXC__Process__c = tsRequestInfo.autofillInfo.workDetailsCriteria;
                timesheetConfiguration.timesheetProcess.SVMXC__Node_Parent__c = tsRequestInfo.autofillInfo.taskCriteria;
                timesheetConfiguration.timesheetProcess.SVMXC__Parent_Object__c = tsRequestInfo.autofillInfo.eventCriteria;
                timesheetConfiguration.timesheetProcess.SVMXC__Process1__c = tsRequestInfo.autofillInfo.workDetailTimeEntryMapping;
                timesheetConfiguration.timesheetProcess.SVMXC__Process2__c = tsRequestInfo.autofillInfo.taskTimeEntryMapping;
                timesheetConfiguration.timesheetProcess.SVMXC__Process3__c = tsRequestInfo.autofillInfo.eventTimeEntryMapping;
                timesheetConfiguration.timesheetProcess.SVMXC__Submodule__c = tsRequestInfo.autofillInfo.servicemaxEventCriteria;
                timesheetConfiguration.timesheetProcess.SVMXC__Module__c = tsRequestInfo.autofillInfo.servicemaxEventTimeEntryMapping;
            }
            
            SVMXC__ServiceMax_Config_Data__c scheduleDetails = new SVMXC__ServiceMax_Config_Data__c( SVMXC__Active__c = true, SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_HEADER );
            
            scheduleDetails.SVMXC__Period__c = tsRequestInfo.period;
            
            if( scheduleDetails.SVMXC__Period__c != null ) {
                scheduleDetails.SVMXC__Run_Type__c = TMST_Consts.PERIOD_RUN_TYPE_MAP.get(scheduleDetails.SVMXC__Period__c);    
            }
            
            //scheduleDetails.SVMXC__Schedule_Days__c = TMST_Consts.WEEK_Id_TO_STRING_MAP.get( tsRequestInfo.weekOn );
            if( tsRequestInfo.weekOn != null ) {
                scheduleDetails.SVMXC__Schedule_Days__c = TMST_TimesheetUtils.getInstance().buildString( tsRequestInfo.weekOn, TMST_Consts.SEMICOLON );
            }
            //Added for BAC-5411
            if(tsRequestInfo.tsHeaderStatus != null){
                scheduleDetails.SVMXC__Internal_Value__c = TMST_TimesheetUtils.getInstance().buildString( tsRequestInfo.tsHeaderStatus, ',' );
            }//End for BAC-5411
            scheduleDetails.SVMXC__Run_At__c = TMST_Consts.TIMEAT_ID_TO_STRING_MAP.get( tsRequestInfo.timeAt );
            scheduleDetails.SVMXC__Period_Start_On__c = tsRequestInfo.startOfPeriodDate;
            scheduleDetails.SVMXC__Period_End_On__c = tsRequestInfo.endOfPeriodDate;
            //scheduleDetails.SVMXC__Run_Frequency__c = tsRequestInfo.runEvery;
            
            if( tsRequestInfo.dayToRun != null ) {
                scheduleDetails.SVMXC__Day_to_Run__c = String.valueOf( tsRequestInfo.dayToRun );
            }
            scheduleDetails.SVMXC__Sequence__c = 1;
            scheduleDetails.SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_HEADER;
            scheduleDetails.Id = tsRequestInfo.scheduleId;
            
            timesheetConfiguration.scheduleDetailsList.add( scheduleDetails );
            
          // Code updated below : 19/Jan/2017:Defect#038670-added 15 days to create second schedule record           
          if( scheduleDetails.SVMXC__Period__c != null && 
                scheduleDetails.SVMXC__Period__c.equalsIgnoreCase( TMST_Consts.PERIOD_BI_MONTHLY ) ) {
                
                SVMXC__ServiceMax_Config_Data__c secondScheduleDetails = scheduleDetails.clone();
                secondScheduleDetails.SVMXC__Sequence__c = 2;
               // if( tsRequestInfo.secondRecurrenceDay != null ) {
                    Integer iDay = Integer.ValueOf(secondScheduleDetails.SVMXC__Day_to_Run__c)+15;
                    if(iDay > TMST_Consts.MAX_DATE_VALUE)
                        iDay = iDay - TMST_Consts.MAX_DATE_VALUE;
                        
                    secondScheduleDetails.SVMXC__Day_to_Run__c = String.valueOf(iDay);
               //  }
                secondScheduleDetails.Id = tsRequestInfo.secondRecurrenceScheduleId;
                scheduleDetails.SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_HEADER;
                
                timesheetConfiguration.scheduleDetailsList.add( secondScheduleDetails );
            }
        
            
            if( tsRequestInfo.autofillInfo != null ) {
                
                scheduleDetails = new SVMXC__ServiceMax_Config_Data__c( SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_AUTOFILL );
                
                scheduleDetails.SVMXC__Period__c = tsRequestInfo.autofillInfo.period;
              //added:14-Dec-2016:Sourabh-to capture prior timesheet periods       
                scheduleDetails.SVMXC__SM_Prior_Timesheet_Periods__c = String.valueOf(tsRequestInfo.autofillInfo.pPeriods);

                if( scheduleDetails.SVMXC__Period__c != null ) {
                    scheduleDetails.SVMXC__Run_Type__c = TMST_Consts.PERIOD_RUN_TYPE_MAP.get(scheduleDetails.SVMXC__Period__c);    
                }
                //scheduleDetails.SVMXC__Schedule_Days__c = TMST_Consts.WEEK_Id_TO_STRING_MAP.get( tsRequestInfo.autofillInfo.weekOn );
                if( tsRequestInfo.autofillInfo.weekOn != null ) {
                    scheduleDetails.SVMXC__Schedule_Days__c = TMST_TimesheetUtils.getInstance().buildString( tsRequestInfo.autofillInfo.weekOn, TMST_Consts.SEMICOLON );
                }
                scheduleDetails.SVMXC__Run_At__c = TMST_Consts.TIMEAT_ID_TO_STRING_MAP.get( tsRequestInfo.autofillInfo.timeAt );
                scheduleDetails.SVMXC__Day_to_Run__c = String.valueOf( tsRequestInfo.autofillInfo.dayToRun );
                scheduleDetails.SVMXC__Active__c = tsRequestInfo.autofillInfo.status;
                scheduleDetails.SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_AUTOFILL;
                scheduleDetails.SVMXC__Sequence__c = 1;
                scheduleDetails.SVMXC__Period_Start_On__c = tsRequestInfo.autofillInfo.startOfPeriodDate;
                scheduleDetails.SVMXC__Period_End_On__c = tsRequestInfo.autofillInfo.endOfPeriodDate;
                //scheduleDetails.SVMXC__Run_Frequency__c = tsRequestInfo.autofillInfo.runEvery;
                
                timesheetConfiguration.scheduleDetailsList.add( scheduleDetails );
                
                if( scheduleDetails.SVMXC__Period__c != null && 
                    scheduleDetails.SVMXC__Period__c.equalsIgnoreCase( TMST_Consts.PERIOD_BI_MONTHLY ) ) {
                
                    SVMXC__ServiceMax_Config_Data__c secondScheduleDetails = scheduleDetails.clone();
                    secondScheduleDetails.SVMXC__Sequence__c = 2;
                    secondScheduleDetails.SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_AUTOFILL;
                    secondScheduleDetails.SVMXC__Day_to_Run__c = String.valueOf( tsRequestInfo.autofillInfo.secondRecurrenceDay );
                    secondScheduleDetails.Id = tsRequestInfo.autofillInfo.secondRecurrenceScheduleId;
                    
                    timesheetConfiguration.scheduleDetailsList.add( secondScheduleDetails );
                }
                //Added for BAC-4864
                if( scheduleDetails.SVMXC__Period__c != null && 
                    scheduleDetails.SVMXC__Period__c.equalsIgnoreCase( TMST_Consts.PERIOD_DAILY ) && tsRequestInfo.autofillInfo.hourFrequency != null) {
                    Integer hrFrequency = Integer.valueOf(tsRequestInfo.autofillInfo.hourFrequency);
                    
                        Integer autoFillSequence = 1;
                        Integer runTimeInt = Integer.valueOf(tsRequestInfo.autofillInfo.timeAt);
                        String runAutofilTime = TMST_Consts.TIMEAT_ID_TO_STRING_MAP.get( tsRequestInfo.autofillInfo.timeAt );
                        for(Integer i=1; i< hrFrequency; i++){
                            SVMXC__ServiceMax_Config_Data__c secondScheduleDetails = scheduleDetails.clone();
                            secondScheduleDetails.SVMXC__Sequence__c = autoFillSequence + i;
                            secondScheduleDetails.SVMXC__Schedule_Type__c = TMST_Consts.SCHEDULE_TYPE_TIMESHEET_AUTOFILL;
                            secondScheduleDetails.SVMXC__Day_to_Run__c = String.valueOf( tsRequestInfo.autofillInfo.dayToRun );
                            Integer actualRunTime = 0;
                            if(hrFrequency == 2){
                                actualRunTime = runTimeInt+12;
                            }else if(hrFrequency == 3){
                                actualRunTime = runTimeInt+(8*i);
                            }else if(hrFrequency == 4){
                                actualRunTime = runTimeInt+(6*i);
                            }else if(hrFrequency == 6){ //Added for BAC-5149
                                actualRunTime = runTimeInt+(4*i);
                            }
                            if(actualRunTime > 24){
                                actualRunTime = math.mod(actualRunTime,24);
                            }
                            secondScheduleDetails.SVMXC__Run_At__c = TMST_Consts.TIMEAT_ID_TO_STRING_MAP.get( actualRunTime );
                            System.debug('secondScheduleDetails '+secondScheduleDetails);
                            timesheetConfiguration.scheduleDetailsList.add( secondScheduleDetails );
                        }
                    
                }
                //End for BAC-4864
            }
            
            if( tsRequestInfo.assignedProfilesList != null ) {
                for( ProfileAssociation profileAssociation : tsRequestInfo.assignedProfilesList ) {
                
                    TMST_WrapperDef.TMST_TimesheetAccess assignedProfile = new TMST_WrapperDef.TMST_TimesheetAccess();
                                    
                    assignedProfile.configProfile.Id = profileAssociation.profileId;
                    assignedProfile.configProfile.SVMXC__Profile_Name__c = profileAssociation.profileName;
                    assignedProfile.configProfile.SVMXC__Description__c = profileAssociation.description;
                    assignedProfile.configProfile.SVMXC__Active__c = profileAssociation.status;
                    //Added for BAC-5189
                    if(profileAssociation.ProfileAssociation != null){
                        TMST_WrapperDef.SalesforceProfileInfo sfdcProfileInfoWrap = new TMST_WrapperDef.SalesforceProfileInfo();
                        List<TMST_WrapperDef.ObjectInfo> listSFDCProfiles = new List<TMST_WrapperDef.ObjectInfo>();
                        for(TMST_WrapperDef.SalesforceProfileAssociation sfProfileIds : profileAssociation.ProfileAssociation){
                            TMST_WrapperDef.ObjectInfo wrapObjectInfo = new TMST_WrapperDef.ObjectInfo();
                            wrapObjectInfo.Id = sfProfileIds.profileId;
                            wrapObjectInfo.name = sfProfileIds.profileName;
                            listSFDCProfiles.add(wrapObjectInfo);
                        }
                        sfdcProfileInfoWrap.salesforceProfileIds = listSFDCProfiles;
                        assignedProfile.configProfile.SVMXC__SM_Scope__c = JSON.serialize(sfdcProfileInfoWrap);
                    }
                    //End for BAC-5189
                    timesheetConfiguration.assignedProfilesList.add( assignedProfile );
                }
            }
            
            TMST_WrapperDef.TMST_Request request = new TMST_WrapperDef.TMST_Request();
            request.timesheetConfigurationList.add( timesheetConfiguration );
            
            TMST_TimesheetManagerAPI timesheetManager = new TMST_TimesheetManagerAPI();
            TMST_WrapperDef.TMST_Response response = timesheetManager.saveTimesheetConfiguration( request );
            
            result.success = response.success;
            result.warning = response.warning;
            result.message = TMST_TimesheetUtils.getInstance().buildString( response.messageList, TMST_Consts.LINE_BREAK );
        }
        
        catch( System.JSONException ex ) {
        
            result.success = false;
            result.message = 'Invalid JSON request : ' + ex.getMessage();
        }
        
        catch( System.Exception ex ) {
        
            result.success = false;
            result.message = 'Internal server error : ' + ex.getMessage();
        }
            
        return JSON.serialize( result );
    }
}