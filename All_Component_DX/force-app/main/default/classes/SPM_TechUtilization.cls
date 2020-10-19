/*****************************************************************************
 *                       Copyright (C) 2016 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/
//FLS and CRUD check is not required as this class is running batch mode
/**
 * This class helps to generate the metrics for technicians utilization using Timesheet as a source.
 * 
 * For all the eligible timesheet, we get the logged hours information on daily basis and populate the content into the utilization object.
 *
 * @author Praveen.R
 * @version 1.0
 * @since 2016
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Praveen.R           07 Jan 2016     Created.
 * 029309       Ramachandra Mohan   12 Apr 2016     Fixed 'Too many SOQL' issue on performing mapping.
 *****************************************************************************************************/
global with sharing class SPM_TechUtilization extends SPM_AbstractBatch {
    
     /**
      * Holds the reference to the configuration object for this Metrics.
      */
    private SVMXC__ServiceMax_Config_Data__c scheduleConfigData;

    /**
     * Used for calculating the minutes from milli seconds.
     */
    private final Integer MILLI_SEC_TO_MINUTES = 60000;
    
    /**
     * Global constructor invoke while this class is initalized.
     */
    global SPM_TechUtilization( SVMXC__ServiceMax_Config_Data__c scheduleData ) {        
        super(SPM_Schema.Report.Utilization, scheduleData);  
        this.scheduleConfigData = scheduleData;
    }
    
    /**
     * Holds the name of the calculation method for which this metrics is getting generated.
     */
    private String calculationMethodName;

    /**
     * This method is called when the class is invoked by the engine for the first time.
     */ 
    global override void initBatchConfiguration() {
        
        System.debug( LoggingLevel.DEBUG, 'initBatchConfiguration() - enter' );
        //calculationMethodName = getCalculationMethodName();
        //System.debug( LoggingLevel.DEBUG, 'Calculation method name used for generating the Utilization Metrics - ' + calculationMethodName);
                 
        //Get the configured start date range from the configuration.
        Integer numberOfDays = getNumberOfDaysToQualifyRecords();        
        if( numberOfDays == null ) {
            numberOfDays = 120;        
        }

        Datetime previousExecution = System.now().addDays((numberOfDays * -1));        
        String entryCriteria = 'CreatedDate >= ' + previousExecution.formatGmt(SPM_Consts.DEFAULT_DATETIME_FORMAT);
        
        if( scheduleData != null && scheduleData.SVMXC__Previous_Execution_Started_On__c != null ) {            
            previousExecution = scheduleData.SVMXC__Previous_Execution_Started_On__c;
            entryCriteria = entryCriteria + ' AND LastModifiedDate >= ' + previousExecution.formatGmt(SPM_Consts.DEFAULT_DATETIME_FORMAT);
        }         

        setWhereClause(entryCriteria);        
        System.debug( LoggingLevel.DEBUG, 'initBatchConfiguration() - exit' );
    }
    
    /**
     * Apex Batch engine invokes this method for processing the records.
     * 
     * @param records - List of retireved records chunk processed in batches.
     */
    global override void handleRecords(List<SObject> records) {        
        
        System.debug(LoggingLevel.DEBUG, 'handleRecords() - enter; records count: ' + records.size());
        calculationMethodName = getCalculationMethodName();
        System.debug( LoggingLevel.DEBUG, 'Calculation method name used for generating the Utilization Metrics - ' + calculationMethodName);

        if(records.size() == 0) {
            System.debug( LoggingLevel.INFO, 'No tiemsheets were loaded for execution');
            return;
        }               
        
        Map<String, String> mapTimesheetIdAndDailySummary = new Map<String, String>();
        List<String> timesheetIds = new List<String>();
        for(SObject record : records) {
            String strTimesheetId = (Id)getSourceObjectFieldValue(record, SPM_Schema.Field.Id);
            timesheetIds.add(strTimesheetId);          
        }

        //Load the Daily-Summary and Timesheet for the qualified Timesheets.
        Map<String, List<SVMXC__Timesheet_Day_Entry__c>> mapOfDailySummary = this.populateDailySummary(timesheetIds);
        Map<String, List<SVMXC__Timesheet_Entry__c>> mapOfTimeEntries = this.populateTimeEntries(timesheetIds);

        //Load the technican, manager information for the users associated with the timesheets.
        List<String> listOfTimesheetUsers = this.populateUsers(records);
        Map<String, SVMXC__Service_Group_Members__c> mapOfUserTechnicians = this.populateTechnicians(listOfTimesheetUsers);
        Map<String, String> mapOfUserManagers = this.populateUserManagers(listOfTimesheetUsers);

        //Populate the existing utilization records. Needed for insert/update operation based on the presence.
        Map<String, SVMXC__SPM_Utilization__c> existingUtilizationMap = this.populateExistingUtilizationRecords(mapOfDailySummary.values());
        
        //List to hold the utilization objects derived from the Timesheet and its related object.
        List<SVMXC__SPM_Utilization__c> listOfUtilization = new List<SVMXC__SPM_Utilization__c>();   

        //Get the Non-Productive activity types.
        Set<String> nonProductiveActivities = getNonProductiveActivityTypes();     
        //Set<String> leaveActivities = new Set<String> {'PTO', 'Sick Leave'};
        Set<String> leaveActivities = getLeaveActivityTypes(); 

        //Map to hold business hour id and corresponding business hour record.(Added by Anush 21/03/2016 defect fix: 028495)    
        Map<id,BusinessHours> businessHoursMap = this.populateBusinessHours(mapOfUserTechnicians.values());

        Decimal breakTime = 0;
        Decimal productiveTime = 0;
        Decimal nonProductiveTime = 0;
        Decimal driveTime = 0;
        Decimal leaveHours = 0;
        
        //Iterate through the timesheet and dialy summary object entries and populate the data into metrics object. 
        for(SObject record : records) {            
            SVMXC__Timesheet__c timesheet = (SVMXC__Timesheet__c)record; 
            String salesforceUser = timesheet.SVMXC__User__c;
            List<SVMXC__Timesheet_Day_Entry__c> dailySummaryRecords = mapOfDailySummary.get(timesheet.Id);
            System.debug( LoggingLevel.DEBUG, 'dailySummaryRecords: ' + dailySummaryRecords.size());
            for(SVMXC__Timesheet_Day_Entry__c summary: dailySummaryRecords) {                
                System.debug( LoggingLevel.DEBUG, 'Time entries: ' + mapOfTimeEntries.keySet());

                if(existingUtilizationMap.containsKey(summary.Id)) {
                    System.debug( LoggingLevel.DEBUG, 'This summary record will be ignored as the Utilization is already computed for it - '+summary.Id);
                    continue;
                }

                String key = timesheet.Id +''+ summary.Id;
                System.debug( LoggingLevel.DEBUG, 'Timeentry key: ' + key);
                List<SVMXC__Timesheet_Entry__c> timeEntries = mapOfTimeEntries.get(key);
                productiveTime = 0;
                nonProductiveTime = 0;
                driveTime = 0;
                leaveHours = 0;
                if(timeEntries != null) {
                    for(SVMXC__Timesheet_Entry__c entry: timeEntries) {
                        System.debug( LoggingLevel.DEBUG, 'Activity - '+entry.SVMXC__Activity__c);
                        System.debug( LoggingLevel.DEBUG, 'Entry type  - '+entry.SVMXC__SM_Type__c);

                        if(entry.SVMXC__Activity__c == 'Travel') {
                            System.debug( LoggingLevel.DEBUG, 'Entry type  - Going as Travel - '+entry.SVMXC__Duration__c);
                            driveTime += entry.SVMXC__Duration__c;
                        } else {
                            //TODO - Based on the configuration, we need to segregate Productive and Non-Productive work-type.
                            if(leaveActivities.contains(entry.SVMXC__SM_Type__c)) {
                                System.debug( LoggingLevel.DEBUG, 'Entry type  - Going as Leave - '+entry.SVMXC__Duration__c);
                                leaveHours += entry.SVMXC__Duration__c;
                            } else if(nonProductiveActivities.contains(entry.SVMXC__SM_Type__c)) {
                                System.debug( LoggingLevel.DEBUG, 'Entry type  - Going as Non-Productive - '+entry.SVMXC__Duration__c);
                                nonProductiveTime += entry.SVMXC__Duration__c;
                            } else {
                                System.debug( LoggingLevel.DEBUG, 'Entry type  - Going as Productive - '+entry.SVMXC__Duration__c);
                                productiveTime += entry.SVMXC__Duration__c;                                
                            }
                        }
                    }
                }
                System.debug( LoggingLevel.DEBUG, 'Productive Time for the day: ' + summary.SVMXC__Timsheet_Day__c + ' is: '+productiveTime);
                //Check if a record was already created for the dialy summary object being considered. 
                //If present use it or else Create a object under the utlization object.
                SVMXC__SPM_Utilization__c utilization = new SVMXC__SPM_Utilization__c();                

                //Populate the values from dailySummary object.
                utilization.SVMXC__Timesheet_Daily_Summary__c = summary.Id;
                utilization.SVMXC__Utilization_On__c = summary.SVMXC__Timsheet_Day__c;
                if(summary.SVMXC__SM_Working_Minutes__c != null) {
                    utilization.SVMXC__Working_Minutes__c = summary.SVMXC__SM_Working_Minutes__c;
                }

                //Populate the captured hours from time-entry object.
                utilization.SVMXC__Drive_Time__c = driveTime * 60;
                utilization.SVMXC__Productive_Time__c = productiveTime * 60;
                utilization.SVMXC__Non_Productive_Time__c = nonProductiveTime * 60;
                utilization.SVMXC__Off_Time__c = leaveHours * 60;

                //Populate the manager details.
                String manager = mapOfUserManagers.get(timesheet.SVMXC__User__c);                
                if(manager != null) {
                    utilization.SVMXC__Service_Manager__c = manager;                    
                } else {
                    System.debug( LoggingLevel.DEBUG, 'No Manger is associated with the user - '+timesheet.SVMXC__User__c);
                }   

                //populate the details pertaining to the technician.
                utilization.SVMXC__User__c = salesforceUser; 

                if(mapOfUserTechnicians.containsKey((salesforceUser))) {
                    SVMXC__Service_Group_Members__c technician = mapOfUserTechnicians.get(salesforceUser);
                    utilization.SVMXC__Service_Team__c =   technician.SVMXC__Service_Group__c;   
                    utilization.SVMXC__Country__c = technician.SVMXC__Country__c;
                    utilization.SVMXC__Technician__c =   technician.Id;              
                                        
                    //Get the Break-Time based on the user configuration.
                    breakTime = 0;
                    String value = getSourceObjectField(SPM_Schema.Field.BreakTime);
                    System.debug( LoggingLevel.DEBUG, '**** Break Configuration ****' + value);
                    if(value == 'Break Duration') {
                        breakTime = Integer.valueOf(technician.SVMXC__Break_Duration__c);
                        if(!(breakTime > 0)) { //Set to blank when break-duration is blank. Hence we need to over-ride with 0
                            breakTime = 0;
                        }
                    } else {
                        String businessHourId = technician.SVMXC__Break_Hours__c;
                        if(businessHourId != null) {
                            //Date startDate = summary.SVMXC__Timsheet_Day__c;
                            //Datetime startDateTime = DateTime.newInstanceGmt(startDate.year(), startDate.month(), startDate.day());
                            //Datetime endDate = summary.SVMXC__Timsheet_Day__c.addDays(1);
                            String summaryDay = summary.SVMXC__Day_of_the_Week__c;
                            BusinessHours breakBusinessHours = businessHoursMap.get(businessHourid);
                            breakTime = this.calculateBreakTime(summaryDay, breakBusinessHours);
                        }
                    }
                    utilization.SVMXC__Break_Minutes__c = breakTime;
                    //28209 - Added for mapping support. This is open only for technician and hence added here.                    
                    performFieldMapping(technician, utilization);
                }                              

                //Set the current calaculation method. Used while rendering the report.
                utilization.SVMXC__Calculation_Method__c = calculationMethodName;
                utilization.SVMXC__Configuration_Name__c = getConfigurationName();

                listOfUtilization.add(utilization);                
            }
        }

        if(!listOfUtilization.isEmpty()) {            
            //Save all the recorded utilization records on a daily basis. Bulk insert operation.
            upsert listOfUtilization;            
        }

        System.debug( LoggingLevel.DEBUG, 'handleRecords() - exit' );
    }


    /**
     * This method is used to return the list of activity types for calculating leaves.
     * 
     * @return - List of selected leave type values.
     */
    private Set<String> getLeaveActivityTypes() {
        System.debug( LoggingLevel.DEBUG, 'getLeaveActivityTypes() - enter' );
        String value = getSourceObjectField(SPM_Schema.Field.Leaves);        
        System.debug( LoggingLevel.DEBUG, 'Leave ActivityTypes Types - '+value);
        Set<String> leaveOptions = new Set<String>();
        if(value.length() > 0) {
            List<String> values = value.split(';');
            for(String tempValue: values) {                
                leaveOptions.add(tempValue);
            }
        }
        System.debug( LoggingLevel.DEBUG, 'Leave ActivityTypes as a list - '+leaveOptions);
        System.debug( LoggingLevel.DEBUG, 'getLeaveActivityTypes() - exit' );
        return leaveOptions;
    }


    /**
     * This method is used to return the list of selected non-productive activity types.
     * 
     * @return - List of selected non-productive values.
     */
    private Set<String> getNonProductiveActivityTypes() {
        System.debug( LoggingLevel.DEBUG, 'getNonProductiveActivityTypes() - enter' );
        String value = getSourceObjectField(SPM_Schema.Field.NonProductiveTime);
        //String value = 'Meeting';
        System.debug( LoggingLevel.DEBUG, 'NonProductiveActivity Types - '+value);
        Set<String> nonProductiveValues = new Set<String>();
        if(value.length() > 0) {
            List<String> values = value.split(';');
            for(String tempValue: values) {                
                nonProductiveValues.add(tempValue);
            }
        }
        System.debug( LoggingLevel.DEBUG, 'NonProductiveActivity Types as a list - '+nonProductiveValues);
        System.debug( LoggingLevel.DEBUG, 'getNonProductiveActivityTypes() - exit' );
        return nonProductiveValues;
    }


    /**
     * Load the list of saved Utilization report data. Used during upsert operation.
     * 
     * @param  dailySummaryListRecords - List of loaded daily-summary record.
     * @return Map of utlization objects with its id as a key.                       
     */
    private Map<String, SVMXC__SPM_Utilization__c> populateExistingUtilizationRecords(
        List<List<SVMXC__Timesheet_Day_Entry__c>> dailySummaryListRecords) {
        System.debug( LoggingLevel.DEBUG, 'populateExistingUtilizationRecords() - enter' );

        Map<String, SVMXC__SPM_Utilization__c> mapOfExistingUtilizationRecords = 
                new Map<String, SVMXC__SPM_Utilization__c>();
        if(dailySummaryListRecords.size() == 0) {
            return mapOfExistingUtilizationRecords;
        }
        List<String> Ids = new List<String>();
        //Get the Ids of list of DailySummary records.
        for(List<SVMXC__Timesheet_Day_Entry__c> dailySummaryRecords: dailySummaryListRecords) {
            for(SVMXC__Timesheet_Day_Entry__c summary: dailySummaryRecords) {
                Ids.add(summary.Id);
            }
        }
                
        //Query the data-base and load the existing records. This is done to support upsert operation.
        
        List<SVMXC__SPM_Utilization__c> listOfUtilization = [select Id, SVMXC__Timesheet_Daily_Summary__c, 
            SVMXC__Utilization_On__c, SVMXC__Working_Minutes__c, SVMXC__Drive_Time__c, 
            SVMXC__Productive_Time__c, SVMXC__User__c, SVMXC__Service_Team__c, SVMXC__Country__c, 
            SVMXC__Technician__c, SVMXC__Service_Manager__c from SVMXC__SPM_Utilization__c where 
            SVMXC__Timesheet_Daily_Summary__c IN: Ids and SVMXC__Calculation_Method__c =: calculationMethodName];
        
        /*List<SVMXC__SPM_Utilization__c> listOfUtilization = null;*/
        if(listOfUtilization.size() > 0) {
            for(SVMXC__SPM_Utilization__c utilization: listOfUtilization) {
                mapOfExistingUtilizationRecords.put(utilization.SVMXC__Timesheet_Daily_Summary__c, utilization);            
            }
        }
        System.debug( LoggingLevel.DEBUG, 'Number of existing utilization records () - '+mapOfExistingUtilizationRecords.size());
        System.debug( LoggingLevel.DEBUG, 'populateExistingUtilizationRecords() - exit' );
        return mapOfExistingUtilizationRecords;
    }

    /**
     * This method is used to load the list of user-ids associated with the timesheets.
     * 
     * @param  records - list of timesheet records.
     * @return list of userIds.
     */
    private List<String> populateUsers(List<SObject> records) {
        System.debug( LoggingLevel.DEBUG, 'populateUsers() - enter' );
        List<String> users = new List<String>();
        for(SObject tempObject: records) {
            SVMXC__Timesheet__c timesheet = (SVMXC__Timesheet__c) tempObject;
            users.add(timesheet.SVMXC__User__c);
        }
        System.debug( LoggingLevel.DEBUG, 'Number of Users() - ' + users.size());
        System.debug( LoggingLevel.DEBUG, 'populateUsers() - exit');     
        return users;   
    }

    /**
     * This method is used to load the list of technicians associated with the users present in the Timesheet table.
     * 
     * @param  userIds - list of userids present in the timesheets
     * @return Map containing technicians with userId.
     */
    private Map<String, SVMXC__Service_Group_Members__c> populateTechnicians(List<String> userIds) {
        
        System.debug( LoggingLevel.DEBUG, 'populateTechnicians() - enter' );
        
        Set<String> mappingFieldSet = getMappingFields();
        mappingFieldSet.addAll( new List<String> { 'Id', 'Name', 'SVMXC__Salesforce_User__c', 'SVMXC__Country__c','SVMXC__Break_Duration__c', 'SVMXC__Break_Hours__c', 'SVMXC__Service_Group__r.name' } );
        
        String fields = SPM_Utilities.getInstance().buildString( mappingFieldSet, ',');
        //Get the list of technicians for the passed in users.
        String queryString = 'select '+ fields +' from SVMXC__Service_Group_Members__c where SVMXC__Salesforce_User__c IN: userIds';// and SVMXC__Active__c =: isTechnicianActive';
        
        List<SVMXC__Service_Group_Members__c> technicians = Database.query(queryString);       
        
        Map<String, SVMXC__Service_Group_Members__c> mapOfUserTechnician = new Map<String, SVMXC__Service_Group_Members__c>();
        for(SVMXC__Service_Group_Members__c technician: technicians) {
            mapOfUserTechnician.put(technician.SVMXC__Salesforce_User__c, technician);
        }
        System.debug( LoggingLevel.DEBUG, 'Number of Techicians() - ' + mapOfUserTechnician.size());
        System.debug( LoggingLevel.DEBUG, 'populateTechnicians() - exit' );
        return mapOfUserTechnician;
    }

    /**
     * This method loads the managers associated with the passed in Salesforce UserIds.
     * 
     * @param  userIds - list of userids present in the timesheets
     * @return Map containing Manager-Id with userId.
     */
    private Map<String, String> populateUserManagers(List<String> userIds) {
        System.debug( LoggingLevel.DEBUG, 'populateUserManagers() - enter' );
        //Get the managers information from the salesforce's standard object.
        List<User> users = [SELECT Id, Manager.Name FROM User where Id IN:userIds];
        Map<String, String> mapOfUserManager = new Map<String, String>();
        for(User userObject: users) {
            mapOfUserManager.put(userObject.Id, userObject.Manager.Id);
        }        
        System.debug( LoggingLevel.DEBUG, 'populateUserManagers() - exit' );
        return mapOfUserManager;
    }


    /**
     * This method returns a map containing daily-summary records for the passed in timesheetIds.
     * 
     * @param - list of timesheet Ids
     * @return - map of timesheet daily-summary records with the timesheet-Id
     **/
    private Map<String, List<SVMXC__Timesheet_Day_Entry__c>> populateDailySummary(List<String> timesheetIds) {
        System.debug( LoggingLevel.DEBUG, 'populateDailySummary() - enter' );
        
        //TODO - Uncomment after build.        
        List<SVMXC__Timesheet_Day_Entry__c> timeEntries = [select id, SVMXC__Timesheet__c, 
            SVMXC__Timsheet_Day__c, SVMXC__SM_Working_Minutes__c,SVMXC__Day_of_the_Week__c from 
            SVMXC__Timesheet_Day_Entry__c where SVMXC__Timesheet__c IN: timesheetIds];
        
        //List<SVMXC__Timesheet_Day_Entry__c> timeEntries = null;

        //List<SVMXC__Timesheet_Day_Entry__c> timeEntries = null;
        Map<String, List<SVMXC__Timesheet_Day_Entry__c>> mapOfDailySummary = new Map<String, List<SVMXC__Timesheet_Day_Entry__c>>();
        List<SVMXC__Timesheet_Day_Entry__c> listOfDailySummary; 
        for(SVMXC__Timesheet_Day_Entry__c entry: timeEntries) {                               
            String key = entry.SVMXC__Timesheet__c; 
            if(mapOfDailySummary.containsKey(key)) {
                listOfDailySummary = mapOfDailySummary.get(key);
                listOfDailySummary.add(entry);
            } else {
                listOfDailySummary = new List<SVMXC__Timesheet_Day_Entry__c>();
                listOfDailySummary.add(entry);
            }
            mapOfDailySummary.put(key, listOfDailySummary);
        }
        System.debug( LoggingLevel.DEBUG, 'Number of daily summary records() - ' + mapOfDailySummary.size());
        System.debug( LoggingLevel.DEBUG, 'populateDailySummary() - exit' );
        return mapOfDailySummary;
    }


    /**
     * This method returns a map containing timeEntries for the passed in timesheetIds.
     * 
     * @param - list of timesheet Ids
     * @return - map of timesheet entries with the key as timesheetId+DailySummaryId.
     **/
    private Map<String, List<SVMXC__Timesheet_Entry__c>> populateTimeEntries(List<String> timesheetIds) {
        System.debug( LoggingLevel.DEBUG, 'populateTimeEntries() - enter' );
        
        
        //TODO - Deleting the Type column for the build to succed.   
             
        List<SVMXC__Timesheet_Entry__c> timeEntries = [select id, SVMXC__Duration__c, SVMXC__SM_Type__c, 
            SVMXC__Timesheet_Day__c, SVMXC__Timesheet__c, SVMXC__Activity__c  from SVMXC__Timesheet_Entry__c 
            where SVMXC__Timesheet__c IN: timesheetIds];
        
            
        //List<SVMXC__Timesheet_Entry__c> timeEntries = null;

        Map<String, List<SVMXC__Timesheet_Entry__c>> mapTimeEntries = new Map<String, List<SVMXC__Timesheet_Entry__c>>();
        List<SVMXC__Timesheet_Entry__c> listOfEntriesPerDay; 
        for(SVMXC__Timesheet_Entry__c entry: timeEntries) {            
            String timesheetId = entry.SVMXC__Timesheet__c;
            String dailySummaryTimesheetId = entry.SVMXC__Timesheet_Day__c;
            //Key is combination of timesheeId and dailySummaryId
            String key = timesheetId + dailySummaryTimesheetId;
            if(mapTimeEntries.containsKey(key)) {
                listOfEntriesPerDay = mapTimeEntries.get(key);
                listOfEntriesPerDay.add(entry);
            } else {
                listOfEntriesPerDay = new List<SVMXC__Timesheet_Entry__c>();
                listOfEntriesPerDay.add(entry);
            }
            mapTimeEntries.put(key, listOfEntriesPerDay);
        }
        System.debug( LoggingLevel.DEBUG, 'Number of time entry records() - '+mapTimeEntries.size());
        System.debug( LoggingLevel.DEBUG, 'populateTimeEntries() - exit');
        return mapTimeEntries;
    }

    /**
     * This method returns a map containing businesshour id as key and businesshours as values for passed list of technicians. (Anush - Defect : 028495)
     * 
     * @param - list of technicians records
     * @return - map of businesshours entries with the key as businesshour id.
     **/
    private Map<Id,BusinessHours> populateBusinessHours(List<SVMXC__Service_Group_Members__c> records) {
        System.debug( LoggingLevel.DEBUG, 'populateBusinessHours() - enter' );
        Set<Id> businessHourIdList = new Set<Id>();
        for(SObject tempObject: records) {
            SVMXC__Service_Group_Members__c technician = (SVMXC__Service_Group_Members__c) tempObject;
            businessHourIdList.add(technician.SVMXC__Break_Hours__c);
        }
        Map<Id,BusinessHours> businessHoursMap = new Map<Id,BusinessHours>([SELECT FridayEndTime,FridayStartTime,Id,MondayEndTime,MondayStartTime,Name,SaturdayEndTime,
                                                                                   SaturdayStartTime,SundayEndTime,SundayStartTime,ThursdayEndTime,ThursdayStartTime,
                                                                                   TimeZoneSidKey,TuesdayEndTime,TuesdayStartTime,WednesdayEndTime,WednesdayStartTime
                                                                            FROM BusinessHours 
                                                                            WHERE Id IN : businessHourIdList]);
        System.debug( LoggingLevel.DEBUG, 'Number of BusinessHours() - ' + businessHourIdList.size());
        System.debug( LoggingLevel.DEBUG, 'populateUsers() - exit');     
        return businessHoursMap;   
    }

    /**
     * This method calculates break time on a given day for a particular business hour. (Anush - Defect : 028495)
     * 
     * @param - Day of the week (String),BusniessHour record.
     * @return - break time in minutes(Long);
     **/
    @TestVisible
    private Long calculateBreakTime(String day, BusinessHours bizHour) {
        System.debug( LoggingLevel.DEBUG, 'calculateBreakTime() - enter' );
        Long breakTime = 0;
        Long hours;
        Long minutes;
        Time timeAt12 = Time.newInstance(0, 0, 0, 0);
        Boolean is24Hours = false; 
        Boolean isNull = false;
        
        Time startTime;
        Time endTime;
        

        if(!Test.isRunningTest()) {
            startTime = (Time)bizHour.get(day+'startTime');
            endTime = (Time)bizhour.get(day+'endTime');
        } else {
            if(day == 'day1') {
                startTime = Time.newInstance(0, 0, 0, 0);
                endTime = Time.newInstance(0, 0, 0, 0);
            } else if(day == 'day2') {
                startTime = Time.newInstance(23, 0, 0, 0);
                endTime = Time.newInstance(0, 0, 0, 0);
            } else if(day == 'day3') {
                startTime = Time.newInstance(0, 0, 0, 0);
                endTime = Time.newInstance(1, 0, 0, 0);
            } else if(day == 'day4') {
                startTime = Time.newInstance(13, 0, 0, 0);
                endTime = Time.newInstance(14, 0, 0, 0);
            }
        }

        if(endTime != null && startTime != null) {
            if(endTime != timeAt12 && startTime != timeAt12) {
                hours = endTime.hour() - startTime.hour();
                minutes = endTime.minute() - startTime.minute();
            } 
            else if(endTime != timeAt12 && startTime == timeAt12) {
                hours = endTime.hour() - startTime.hour();
                minutes = endTime.minute() - startTime.minute();
            }
            else if(endTime == timeAt12 && startTime != timeAt12) {
                hours = 24 - startTime.hour();
                minutes = endTime.minute() - startTime.minute();
            } else {
                is24Hours = true;
            }            
        } else {
            isNull = true;
        }
        
        if (isNull){
            breakTime = 0;
        } else if (is24Hours) {
            breakTime = 1440;
        } else {
            breakTime = hours*60 + minutes;
        }
        System.debug( LoggingLevel.DEBUG, 'Calculated break Time() - ' + breakTime);
        System.debug( LoggingLevel.DEBUG, 'calculateBreakTime() - exit' );
        return breakTime;
    }

    /**
     * Invoked after the batch operation is completed.
     */
    global override void onFinishComplete() {
        System.debug( LoggingLevel.DEBUG, 'SPM_TechUtilization.onFinishComplete()' );
    }
}