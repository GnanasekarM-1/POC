/*****************************************************************************
 *                       Copyright (C) 2016 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * This class helps to generate the metrics for technicians utilization using Events created from Optimax Run
 * 
 * Utilization is computed on daily basis for the technicians using the user's configuration
 *
 * @author Praveen.R
 * @version 1.0
 * @since 2016
 */
global class SPM_Scheduling_Technician_Utilization implements Database.Batchable<SObject>, Database.Stateful {

    /**
     * Holds the reference to the query being exeuted.
     **/
    private String query = '';
    
    /**
     * Holds the reference to audit log file.
     **/
    private SPM_Scheduling_AuditLog auditLog;
    
    private Set<String> processNames = new Set<String>();
    
    private Set<String> technicians = new Set<String>();
    
    private Set<String> territories = new Set<String>();
    
    /**
     * Constructor having the logic to set the query reference.
     **/
    global SPM_Scheduling_Technician_Utilization(String value) {
        this.query = value;
    } 
    
    public void setAuditLog(SPM_Scheduling_AuditLog auditLogInstance) {
        this.auditLog = auditLogInstance;
    }
    
    
    /**
     * Holds the reference to the available activity types.
     **/
    private Set<String> activityTypesForAvailableHours;
    
    /**
     * Holds the reference to the productive activity types.
     **/
    private Set<String> activityTypesForProductiveHours;
    
    /**
     * Method to start the batch operation. Triggers the query execution.
     **/
    global Database.QueryLocator start(Database.BatchableContext context) {
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Technician_Utilization.start()' );
        system.debug('Query: ' + query);
        auditLog.startTime = System.now();
        return Database.getQueryLocator(query);
    }

    /**
     * Invoked for every batch by the SF engine.
     **/
    global void execute(Database.BatchableContext context, List<SObject> records) {  
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Technician_Utilization.execute() - enter' );
        
        if( records == null || records.isEmpty() ) {
            
            System.debug( LoggingLevel.ERROR, 'Execute method called with no records');
            auditLog.addFailureMessage( 'No records were loaded for processing');
            return;
        }
        populteActivityTypesForAvailableHours();
        populteActivityTypesForProductiveHours();
        
        auditLog.totalRecordsCount += records.size();
        
        Set<Id> jobIds = new Set<Id>();
        Set<Id> technicianIds = new Set<Id>();
        //Set<Id> territoryIds = new Set<Id>();
        for(SObject record: records) {
            jobIds.add((Id)record.get('SVMXC__SM_JobId__c'));
            technicianIds.add((Id)record.get('SVMXC__SM_Technician__c'));
        }
        Map<Id, List<SVMXC__SM_Scheduling_Job_Summary__c>> jobsMap = loadJobSummary(jobIds);
        //Load the technicians and their territories associated with the Events.
        Map<Id, SVMXC__Service_Group_Members__c> techniciansMap = populateTechnicians(technicianIds);
        Map<id,BusinessHours> businessHoursMap = this.populateBusinessHours(techniciansMap.values());
        
        //Populate the jobConstrains Map.
        Map<Id, Id> jobConstrainsMap = createJobConstraints(jobsMap);
        
        //Compute the utilization in batches.
        List<SVMXC__SM_Scheduling_Event_Summary__c> eventSummary = (List<SVMXC__SM_Scheduling_Event_Summary__c>)records;
        //List<SVMXC__SPM_Scheduling_Technician_Utilization__c> utilization = new List<SVMXC__SPM_Scheduling_Technician_Utilization__c>();
        
        Map<String, SVMXC__SPM_Scheduling_Technician_Utilization__c> utilizationMap = new Map<String, SVMXC__SPM_Scheduling_Technician_Utilization__c>();
        List<SM_Scheduling_Event_Summary__c> events = new List<SM_Scheduling_Event_Summary__c>();
        			
        //Querying default business hour for the organisation
		BusinessHours orgBusinessHours = [SELECT Id From BusinessHours Where IsDefault=true];


        Decimal productiveTime = 0;
        Decimal availableTime = 0;
        Decimal workingMinutes = 0;
        Integer driveTime = 0;
        Integer overHeadTime = 0;
        Decimal breakTime = 0;
        String eventType = '';
        Decimal productiveDuration = 0; //sourceEvent.SVMXC__Event_Duration__c;
        Decimal availableDuration = 0;
        BusinessHours configuredBusinessHours = null;
        Datetime eventDateTime = null;
        String day = '';

        SVMXC__SPM_Scheduling_Technician_Utilization__c techUtilization;
        SVMXC__Service_Group_Members__c technician;
        Id businessHourId;
        for(SM_Scheduling_Event_Summary__c sourceEvent: eventSummary) {
            String technicianId = sourceEvent.SVMXC__SM_Technician__c;
            Date eventDate = sourceEvent.SVMXC__SM_Event_Date__c;
            String key = technicianId + String.valueOf(eventDate) + String.valueOf(sourceEvent.SVMXC__SM_JobId__c);
            
            if(utilizationMap.containsKey(key)) {
                techUtilization = utilizationMap.get(key);
            } else {
                techUtilization = new SVMXC__SPM_Scheduling_Technician_Utilization__c();
                 //For the first time all the tech and job related information is empty. Populate all this information here. 
           
                //Set the drive time.
                techUtilization.SVMXC__Horizon_Date__c = eventDate;
                
                //populate job related information
                techUtilization.SVMXC__JobId__c = sourceEvent.SVMXC__SM_JobId__c;
                
                System.debug(LoggingLevel.DEBUG, 'Dispatch Process Name - '+sourceEvent.SVMXC__SM_JobId__r.SVMXC__SVMX_Process__r.SVMXC__Name__c);
                SVMXC__SM_Scheduling_Job_Summary__c jobSummary = jobsMap.get(sourceEvent.SVMXC__SM_JobId__c)[0];
                techUtilization.SVMXC__Dispatch_Process_Id__c = sourceEvent.SVMXC__SM_JobId__r.SVMXC__SVMX_Process__c;
                techUtilization.SVMXC__Dispatch_Process_Name__c = sourceEvent.SVMXC__SM_JobId__r.SVMXC__SVMX_Process__r.SVMXC__Name__c;
                techUtilization.SVMXC__Job_Execution_Start_Time__c = sourceEvent.SVMXC__SM_JobId__r.SVMXC__Start_Time__c;
                
            
                //populate technician related information.
                technician = techniciansMap.get(technicianId);
                techUtilization.SVMXC__Technician__c = technician.Id;
                techUtilization.SVMXC__Service_Team__c = technician.SVMXC__Service_Group__r.Name;
                techUtilization.SVMXC__Territory__c = technician.SVMXC__Service_Territory__r.Name;
                
                
                //populate working minutes and available time for the day.
                businessHourId = technician.SVMXC__Working_Hours__c;
                if(businessHourId == null) { //If the value is not configured at the tech level then we get it from territory level.
                    businessHourId = technician.SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c;
                    if(businessHourId == null) {
                        businessHourId = orgBusinessHours.id;
                    }
                }
                

                configuredBusinessHours = businessHoursMap.get(businessHourid);
                eventDateTime = (DateTime) eventDate;
                day = eventDateTime.format('EEEE');
                workingMinutes = calculateTime(day, configuredBusinessHours);
                availableTime = workingMinutes;
                
                businessHourId = technician.SVMXC__Overtime_Hours__c;
                if(businessHourId != null) {
                    configuredBusinessHours = businessHoursMap.get(businessHourid);
                    availableTime += calculateTime(day, configuredBusinessHours);
                }
                
                //If there are any break hours defined then we get the value in minutes and deduct from available time entry.
                businessHourId = technician.SVMXC__Break_Hours__c;
                if(businessHourId == null) { //If the break-hours is not configured at the tech level then we get it from territory level.
                    businessHourId = technician.SVMXC__Service_Territory__r.SVMXC__Break_Hours__c;
                }
                if(businessHourId != null) {
                    configuredBusinessHours = businessHoursMap.get(businessHourid);
                    breakTime = calculateTime(day, configuredBusinessHours);
                    availableTime -= breakTime;
                }
                //set the available and working minutes details.
                techUtilization.SVMXC__Working_Minutes__c = workingMinutes;
                techUtilization.SVMXC__Available_Time__c = availableTime;
                
                
                
                //For Auditing purpose
                this.processNames.add(techUtilization.SVMXC__Dispatch_Process_Name__c);
                this.technicians.add(technician.Name);
                this.territories.add(techUtilization.SVMXC__Territory__c);
            }
            
            
           //update the break time.
           if(techUtilization.SVMXC__Break_Minutes__c == null) {
               techUtilization.SVMXC__Break_Minutes__c = sourceEvent.SVMXC__SM_Break_Minutes__c;
           } else {
               techUtilization.SVMXC__Break_Minutes__c += sourceEvent.SVMXC__SM_Break_Minutes__c;
           }
           
           //update the over-head time.
           if(techUtilization.SVMXC__Overhead_Time__c == null) {
               techUtilization.SVMXC__Overhead_Time__c = sourceEvent.SVMXC__SM_Overhead_time__c;
           } else {
               techUtilization.SVMXC__Overhead_Time__c += sourceEvent.SVMXC__SM_Overhead_time__c;
           }
           
            
            //Add Logic to update the productive and available time entries. Reset the value before computation.
            eventType = sourceEvent.SVMXC__SM_Event_Type__c;
            productiveDuration = 0; //sourceEvent.SVMXC__Event_Duration__c;
            availableDuration = 0;
            
            if(eventType == null || String.isBlank(eventType)) { //This is a WO Event.
                if(!activityTypesForProductiveHours.contains(SPM_Consts.DRIVE_TIME_ACTIVITY)) {
                    productiveDuration = sourceEvent.SVMXC__SM_Event_Duration__c - sourceEvent.SVMXC__SM_Drive_Time__c;
                } else {
                    productiveDuration = sourceEvent.SVMXC__SM_Event_Duration__c;
                }
                
                //Add up the service time from all the WO Events.
                if(techUtilization.SVMXC__Service_Time__c != null) {
                    techUtilization.SVMXC__Service_Time__c += sourceEvent.SVMXC__SM_Event_Duration__c - sourceEvent.SVMXC__SM_Drive_Time__c;
                } else {
                    techUtilization.SVMXC__Service_Time__c = sourceEvent.SVMXC__SM_Event_Duration__c - sourceEvent.SVMXC__SM_Drive_Time__c;
                }
                
                //Add up the drive time from all the WO Events.
                if(techUtilization.SVMXC__Drive_Time__c != null) {
                    techUtilization.SVMXC__Drive_Time__c += sourceEvent.SVMXC__SM_Drive_Time__c;
                } else {
                    techUtilization.SVMXC__Drive_Time__c = sourceEvent.SVMXC__SM_Drive_Time__c;
                }
            } else if(eventType == SPM_Consts.EXTERNAL_WORK_ORDER_ACTIVITY) { //External WO Events Flow.
                if(activityTypesForProductiveHours.contains(eventType)) {
                    if(activityTypesForProductiveHours.contains(SPM_Consts.DRIVE_TIME_ACTIVITY)) {
                        productiveDuration = sourceEvent.SVMXC__SM_Event_Duration__c;
                    } else {
                        productiveDuration = sourceEvent.SVMXC__SM_Event_Duration__c - sourceEvent.SVMXC__SM_Drive_Time__c;
                    }
                }
                
                if(!activityTypesForAvailableHours.contains(SPM_Consts.EXTERNAL_WORK_ORDER_ACTIVITY)) {
                    availableDuration = (sourceEvent.SVMXC__SM_Event_Duration__c * -1);
                 }
                 
                //Add up the service time from all the External-WO Events.
                if(techUtilization.SVMXC__Service_Time__c != null) {
                    techUtilization.SVMXC__Service_Time__c += sourceEvent.SVMXC__SM_Event_Duration__c - sourceEvent.SVMXC__SM_Drive_Time__c;
                } else {
                    techUtilization.SVMXC__Service_Time__c = sourceEvent.SVMXC__SM_Event_Duration__c - sourceEvent.SVMXC__SM_Drive_Time__c;
                }
                
                //Add up the drive time from all the External-WO Events.
                if(techUtilization.SVMXC__Drive_Time__c != null) {
                    techUtilization.SVMXC__Drive_Time__c += sourceEvent.SVMXC__SM_Drive_Time__c;
                } else {
                    techUtilization.SVMXC__Drive_Time__c = sourceEvent.SVMXC__SM_Drive_Time__c;
                }
            
            } else { //Non-WO Events flow.
                
                 //if(activityTypesForProductiveHours.contains(SPM_Consts.DRIVE_TIME_ACTIVITY)) {
                 if(activityTypesForProductiveHours.contains(eventType) && activityTypesForAvailableHours.contains(eventType)) {
                    productiveDuration = sourceEvent.SVMXC__SM_Event_Duration__c;
                 } else {
                     if(!activityTypesForAvailableHours.contains(eventType)) {
                        availableDuration = (sourceEvent.SVMXC__SM_Event_Duration__c * -1);
                     }
                 }
                 
                 //Capture the Non-WO Event durations
                if(techUtilization.SVMXC__Non_Work_Order_Events_Time__c != null) {
                    techUtilization.SVMXC__Non_Work_Order_Events_Time__c += sourceEvent.SVMXC__SM_Event_Duration__c;
                } else {
                    techUtilization.SVMXC__Non_Work_Order_Events_Time__c = sourceEvent.SVMXC__SM_Event_Duration__c;
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'Technician - ' + technician.Name + ' <==> On - ' + eventDate + ' <==> Event Type - ' + eventType 
                                                + ' <=> Available Duration - ' + availableDuration + ' <=> Productive Duration - ' + productiveDuration);
                                                
            if(techUtilization.SVMXC__Available_Time__c != null) {
                techUtilization.SVMXC__Available_Time__c += availableDuration;
            } else {
                techUtilization.SVMXC__Available_Time__c = availableDuration;
            }
            
            if(techUtilization.SVMXC__Productive_Time__c != null) {
                techUtilization.SVMXC__Productive_Time__c += productiveDuration;
            } else {
                techUtilization.SVMXC__Productive_Time__c = productiveDuration;
            }
            
            //If the event doesn't belong to productive hours category then we consider it for Non-Productive category.
            if(productiveDuration == 0) {
                if(techUtilization.SVMXC__Non_Productive_Time_Value__c != null) {
                    techUtilization.SVMXC__Non_Productive_Time_Value__c += sourceEvent.SVMXC__SM_Event_Duration__c;
                } else {
                    techUtilization.SVMXC__Non_Productive_Time_Value__c = sourceEvent.SVMXC__SM_Event_Duration__c;
                }
            }
            
            
            //Reference to the parent object.
            //techUtilization.SVMXC__SPM_Schedul_Tech_Utilization_Constraints__c = jobConstrainsMap.get((Id)(records.get(0).get('SVMXC__SM_JobId__c')));
            techUtilization.SVMXC__SPM_Schedul_Tech_Utilization_Constraints__c = jobConstrainsMap.get(sourceEvent.SVMXC__SM_JobId__c);
            
            //populate other values as well and add it to the map.
            utilizationMap.put(key, techUtilization);
        }
        //insert the computation into the Utilization table.
        //insert utilizationMap.values();
        List<SVMXC__SPM_Scheduling_Technician_Utilization__c> utilizations = utilizationMap.values();
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( utilizations, COMM_SecurityUtils.Access.Createable ) ) {
            insert utilizations;
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Technician_Utilization.execute() - exit' );
    }
    
    
    /**
     * Method to populate the activity types for available hours.
     **/
    private void populteActivityTypesForAvailableHours() {
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Technician_Utilization.populteActivityTypesForAvailableHours() - enter' );
        String availableActivities = SPM_Utilities.getInstance().loadConfigurationValue('availableHours'); 
        System.debug( LoggingLevel.DEBUG, 'availableActivities - ' + availableActivities);
        activityTypesForAvailableHours = new Set<String>(availableActivities.split(','));
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Technician_Utilization.populteActivityTypesForAvailableHours() - exit' );
        
    }
    
    /**
     * Method to populate the activity types for productive hours.
     **/
    private void populteActivityTypesForProductiveHours() {
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Technician_Utilization.populteActivityTypesForProductiveHours() - enter' );
        String productiveHours = SPM_Utilities.getInstance().loadConfigurationValue('productiveHours'); 
        System.debug( LoggingLevel.DEBUG, 'productiveHours - ' + productiveHours);
        activityTypesForProductiveHours = new Set<String>(productiveHours.split(',')); 
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Technician_Utilization.populteActivityTypesForProductiveHours() - exit' );
       
    }
    
    
    /**
     * Method to create constrains for the list of job summary records. Returns a map of jobId and ConstraintId. 
     **/
    private Map<Id, Id> createJobConstraints(Map<Id, List<SVMXC__SM_Scheduling_Job_Summary__c>> jobsMap) {
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Technician_Utilization.createJobConstraints() - enter' );
        Set<Id> jobIds = jobsMap.keySet();
        
        System.debug(LoggingLevel.DEBUG, 'Creating constraint records for the jobs - ' + jobIds);
        
        //Create a map of job and constraints and return.
        Map<Id, Id> jobConstrainsMap = new Map<Id, Id>();
        
        //Check for user access before quering the fields.
        List<String> queryFields = new List<String> {'Id','SVMXC__JobId__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SPM_Schedul_Tech_Utilization_Constraints__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        for(SVMXC__SPM_Schedul_Tech_Utilization_Constraints__c record : 
                [select id, SVMXC__JobId__c from SVMXC__SPM_Schedul_Tech_Utilization_Constraints__c where SVMXC__JobId__c in :jobIds]) {
                    System.debug( LoggingLevel.DEBUG, 'Tech-util constrain already created for the job - ' + record.SVMXC__JobId__c);
            jobConstrainsMap.put(record.SVMXC__JobId__c, record.Id);
        }
        
        
        List<SVMXC__SPM_Schedul_Tech_Utilization_Constraints__c> constrains = new List<SVMXC__SPM_Schedul_Tech_Utilization_Constraints__c>();
        SVMXC__SPM_Schedul_Tech_Utilization_Constraints__c constraint;
        for(Id jobId: jobIds) {
            if(!jobConstrainsMap.containsKey(jobId)) {
                SVMXC__SM_Scheduling_Job_Summary__c jobSummary = jobsMap.get(jobId)[0];
                constraint = createConstraint(jobSummary);
                constrains.add(constraint);
            }
        }
        
        System.debug( LoggingLevel.DEBUG, 'Job constraint records created - ' + constrains);
        
        if(constrains.size() > 0) {
            System.debug( LoggingLevel.DEBUG, 'New tech-util constrains record need to be created for - '+constrains);
            //insert constrains to the database.
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( constrains, COMM_SecurityUtils.Access.Createable ) ) {
                insert constrains;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            //insert constrains;
            
            for(SVMXC__SPM_Schedul_Tech_Utilization_Constraints__c record: constrains) {
                jobConstrainsMap.put(record.SVMXC__JobId__c, record.Id);
            }
        } else {
            System.debug( LoggingLevel.DEBUG, 'No new tech-util constrains record needs to be creted');
        }
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Technician_Utilization.createJobConstraints() - exit' );
        return jobConstrainsMap;
    }
    
    /**
     * Method to create a Constraint record using the job-summary record.
     **/
    private SVMXC__SPM_Schedul_Tech_Utilization_Constraints__c createConstraint(SVMXC__SM_Scheduling_Job_Summary__c jobSummary) {
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Technician_Utilization.createConstraint() - enter' );
        
        System.debug( LoggingLevel.DEBUG, 'Creating a new constrain record - ' + jobSummary.SVMXC__SM_JobId__c);
        
        SVMXC__SPM_Schedul_Tech_Utilization_Constraints__c constraint = 
            new SVMXC__SPM_Schedul_Tech_Utilization_Constraints__c();
        constraint.SVMXC__Horizon_End_Date__c = jobSummary.SVMXC__SM_Horizon_End_Date__c;
        constraint.SVMXC__Horizon_Start_Date__c = jobSummary.SVMXC__SM_Horizon_Start_Date__c;
        constraint.SVMXC__JobId__c = jobSummary.SVMXC__SM_JobId__c;
        constraint.SVMXC__Dispatch_Process_Name__c = jobSummary.SVMXC__SM_Dispatch_Process_Name__c;
        constraint.SVMXC__Total_Events_Count__c = jobSummary.SVMXC__SM_JobId__r.SVMXC__Sent_Events_Count__c;
        

        constraint.SVMXC__Overall_Drive_Time__c = 
            jobSummary.SVMXC__SM_Dispatch_Process_Id__r.SVMXC__Weight_Route_Distance__c ;
        constraint.SVMXC__Overhead_time__c = 
            jobSummary.SVMXC__SM_Dispatch_Process_Id__r.SVMXC__Weight_Route_Time__c;
        constraint.SVMXC__Preferred_Technician__c = 
            jobSummary.SVMXC__SM_Dispatch_Process_Id__r.SVMXC__Weight_Preferred_Technician__c;
        
        
        //Populatethe priority from the Process Table.
        List<SVMXC__ServiceMax_Processes__c> processes = [select SVMXC__Name__c, SVMXC__Description__c from SVMXC__ServiceMax_Processes__c where 
            SVMXC__Record_Type_Name__c = 'SVMX Rule' and SVMXC__Rule_Type__c = 'Priortization' 
            and SVMXC__Process__c = :jobSummary.SVMXC__SM_Dispatch_Process_Id__c  Order By SVMXC__Name__c];
            
        System.debug( LoggingLevel.DEBUG, 'Priority processes - ' + processes);
        for(SVMXC__ServiceMax_Processes__c process: processes) {
            if(process.SVMXC__Name__c == 'P1') {
                constraint.SVMXC__Priority1__c = process.SVMXC__Description__c;
            } else if(process.SVMXC__Name__c == 'P2') {
                constraint.SVMXC__Priority2__c = process.SVMXC__Description__c;
            } else if(process.SVMXC__Name__c == 'P3') {
                constraint.SVMXC__Priority3__c = process.SVMXC__Description__c;
            } else if(process.SVMXC__Name__c == 'P4') {
                constraint.SVMXC__Priority4__c = process.SVMXC__Description__c;
            }
        }
        
        constraint.SVMXC__Product_Specialization__c = 
            jobSummary.SVMXC__SM_Dispatch_Process_Id__r.SVMXC__Weight_Product_Specialization__c;
        
        constraint.SVMXC__Qualified_Technician__c = 
            jobSummary.SVMXC__SM_Dispatch_Process_Id__r.SVMXC__Weight_Node_Type__c;
        constraint.SVMXC__Skill_Match__c = 
            jobSummary.SVMXC__SM_Dispatch_Process_Id__r.SVMXC__Weight_Skill_Match__c;
        constraint.SVMXC__SLA__c = 
            jobSummary.SVMXC__SM_Dispatch_Process_Id__r.SVMXC__Weight_Time_Window__c;
        
        constraint.SVMXC__Travel_Cost__c = 
            jobSummary.SVMXC__SM_Dispatch_Process_Id__r.SVMXC__Weight_Total_Distance__c;

        constraint.SVMXC__Technician_Eligibility__c = 
            jobSummary.SVMXC__SM_Dispatch_Process_Id__r.SVMXC__Weight_Tech_Eligibility__c;
        
        constraint.SVMXC__Submitted_Work_Orders_Count__c = 
            jobSummary.SVMXC__SM_JobId__r.SVMXC__Sent_Work_Orders__c;
        
        constraint.SVMXC__Processed_Work_Orders_Count__c = 
            jobSummary.SVMXC__SM_JobId__r.SVMXC__Scheduled_Work_Orders__c;
        
        constraint.SVMXC__Technicians_Count__c = 
            jobSummary.SVMXC__SM_JobId__r.SVMXC__Sent_Resources__c;
        
        constraint.SVMXC__Total_Events_Count__c = 
            jobSummary.SVMXC__SM_JobId__r.SVMXC__Sent_Events_Count__c;     
            
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Technician_Utilization.createConstraint() - exit' );
        return constraint;
    }
    
    /**
     * Method to load the job details along with the Optimax Dispatch Process details for the passed in jobIds.
     * 
     * @param jobIds - list of jobIds for which deails are loaded.
     **/
    private Map<Id, List<SVMXC__SM_Scheduling_Job_Summary__c>> loadJobSummary(Set<Id> jobIds) {
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Technician_Utilization.jobIds() - enter' );
        
        //Check for user access before quering the fields.
        List<String> queryFields = new List<String> {'SVMXC__SM_Dispatch_Process_Id__c',' SVMXC__SM_Dispatch_Process_Name__c','SVMXC__SM_Horizon_End_Date__c',
                                                    'SVMXC__SM_Horizon_Start_Date__c','SVMXC__SM_Job_End_Time__c','SVMXC__SM_Job_Start_Time__c','SVMXC__SM_JobId__c','SVMXC__SM_Territory__c',
                                                    'SVMXC__SM_Dispatch_Process_Id__r.SVMXC__Weight_Route_Time__c','SVMXC__SM_Dispatch_Process_Id__r.SVMXC__Weight_Preferred_Technician__c',
                                                    'SVMXC__SM_Dispatch_Process_Id__r.SVMXC__Weight_Product_Specialization__c','SVMXC__SM_Dispatch_Process_Id__r.SVMXC__Weight_Node_Type__c',
                                                    'SVMXC__SM_Dispatch_Process_Id__r.SVMXC__Weight_Skill_Match__c','SVMXC__SM_Dispatch_Process_Id__r.SVMXC__Weight_Time_Window__c',
                                                    'SVMXC__SM_Dispatch_Process_Id__r.SVMXC__Weight_Total_Distance__c','SVMXC__SM_Dispatch_Process_Id__r.SVMXC__Weight_Tech_Eligibility__c',
                                                    'SVMXC__SM_JobId__r.SVMXC__Sent_Work_Orders__c','SVMXC__SM_JobId__r.SVMXC__Scheduled_Work_Orders__c','SVMXC__SM_JobId__r.SVMXC__Sent_Resources__c',
                                                    'SVMXC__SM_JobId__r.SVMXC__Sent_Events_Count__c','SVMXC__SM_Dispatch_Process_Id__r.SVMXC__Weight_Route_Distance__c'};
        
        
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SM_Scheduling_Job_Summary__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        
        List<SVMXC__SM_Scheduling_Job_Summary__c> jobs = 
                            [SELECT 
                            SVMXC__SM_Dispatch_Process_Id__c, SVMXC__SM_Dispatch_Process_Name__c,
                             SVMXC__SM_Horizon_End_Date__c,SVMXC__SM_Horizon_Start_Date__c,SVMXC__SM_Job_End_Time__c,
                             SVMXC__SM_Job_Start_Time__c, 
                             SVMXC__SM_JobId__c,SVMXC__SM_Territory__c, 
                             SVMXC__SM_Dispatch_Process_Id__r.SVMXC__Weight_Route_Time__c,
                             SVMXC__SM_Dispatch_Process_Id__r.SVMXC__Weight_Preferred_Technician__c,
                             SVMXC__SM_Dispatch_Process_Id__r.SVMXC__Weight_Product_Specialization__c,
                             SVMXC__SM_Dispatch_Process_Id__r.SVMXC__Weight_Node_Type__c,
                             SVMXC__SM_Dispatch_Process_Id__r.SVMXC__Weight_Skill_Match__c,
                             SVMXC__SM_Dispatch_Process_Id__r.SVMXC__Weight_Time_Window__c,
                             SVMXC__SM_Dispatch_Process_Id__r.SVMXC__Weight_Total_Distance__c,
                             SVMXC__SM_Dispatch_Process_Id__r.SVMXC__Weight_Tech_Eligibility__c,
                             SVMXC__SM_JobId__r.SVMXC__Sent_Work_Orders__c,
                             SVMXC__SM_JobId__r.SVMXC__Scheduled_Work_Orders__c,
                             SVMXC__SM_JobId__r.SVMXC__Sent_Resources__c,
                             SVMXC__SM_JobId__r.SVMXC__Sent_Events_Count__c,
                             SVMXC__SM_Dispatch_Process_Id__r.SVMXC__Weight_Route_Distance__c FROM SVMXC__SM_Scheduling_Job_Summary__c 
                             WHERE SVMXC__SM_JobId__c IN: jobIds ORDER BY SVMXC__SM_JobId__c];
        
        //Create a map of jobId and its list of assoicated tech records.
        Map<Id, List<SVMXC__SM_Scheduling_Job_Summary__c>> jobMap = new Map<Id, List<SVMXC__SM_Scheduling_Job_Summary__c>>();
        List<SVMXC__SM_Scheduling_Job_Summary__c> mappedJobs;
        
        
        for(SVMXC__SM_Scheduling_Job_Summary__c job: jobs) {
            Id recordId = job.SVMXC__SM_JobId__c;
            if(jobMap.containsKey(recordId)) {
                mappedJobs = jobMap.get(recordId);
                mappedJobs.add(job);
            } else {
                mappedJobs = new List<SVMXC__SM_Scheduling_Job_Summary__c>();
                mappedJobs.add(job);
                jobMap.put(recordId, mappedJobs);
            }
        }
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Technician_Utilization.loadJobSummary() - exit' );
        return jobMap;
    }
    
    /**
     * This method calculates break time on a given day for a particular business hour. 
     * 
     * @param - Day of the week (String),BusniessHour record.
     * @return - break time in minutes(Long);
     **/
    public Long calculateTime(String day, BusinessHours bizHour) {
        System.debug( LoggingLevel.DEBUG, 'calculateTime() - enter' );
        System.debug(LoggingLevel.DEBUG, 'bizHour - ' + bizHour);
        Long timeValue = 0;
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

        
        if(isNull){
            timeValue = 0;
        } else if(is24Hours) {
            timeValue = 1440;
        } else {
            timeValue = hours*60 + minutes;
        }
        System.debug( LoggingLevel.DEBUG, 'Calculated Time() - ' + timeValue);
        System.debug( LoggingLevel.DEBUG, 'calculateTime() - exit' );
        return timeValue;
    }
    
    /**
     * This method returns a map containing businesshour id as key and businesshours as values for passed list of technicians. 
     * 
     * @param - list of technicians records
     * @return - map of businesshours entries with the key as businesshour id.
     **/
    private Map<Id,BusinessHours> populateBusinessHours(List<SVMXC__Service_Group_Members__c> records) {
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Technician_Utilization.populateBusinessHours() - enter' );
        
        Set<Id> businessHourIdList = new Set<Id>();
        for(SObject tempObject: records) {
            SVMXC__Service_Group_Members__c technician = (SVMXC__Service_Group_Members__c) tempObject;
            businessHourIdList.add(technician.SVMXC__Break_Hours__c);
            businessHourIdList.add(technician.SVMXC__Working_Hours__c);
            businessHourIdList.add(technician.SVMXC__Overtime_Hours__c);
            businessHourIdList.add(technician.SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c);
            businessHourIdList.add(technician.SVMXC__Service_Territory__r.SVMXC__Break_Hours__c);
        }
        
        //Also add the org's default Business Hours List
        BusinessHours orgBusinessHours = [SELECT Id From BusinessHours Where IsDefault=true];
        businessHourIdList.add(orgBusinessHours.Id);
        
        System.debug( LoggingLevel.DEBUG, 'Number of BusinessHours() - ' + businessHourIdList.size());
        Map<Id,BusinessHours> businessHoursMap = new Map<Id,BusinessHours>([SELECT FridayEndTime,FridayStartTime,Id,MondayEndTime,MondayStartTime,Name,SaturdayEndTime,
                                                                                   SaturdayStartTime,SundayEndTime,SundayStartTime,ThursdayEndTime,ThursdayStartTime,
                                                                                   TimeZoneSidKey,TuesdayEndTime,TuesdayStartTime,WednesdayEndTime,WednesdayStartTime
                                                                            FROM BusinessHours 
                                                                            WHERE Id IN : businessHourIdList]);
        
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Technician_Utilization.populateBusinessHours() - exit');     
        return businessHoursMap;   
    }
    
    /**
     * This method is used to load technicians details for the passed in technician Ids.
     * 
     * @param  technicianIds - list of technicians.
     * @return Map containing technicians with their Ids.
     */
    private Map<Id, SVMXC__Service_Group_Members__c> populateTechnicians(Set<Id> technicianIds) {
        
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Technician_Utilization.populateTechnicians() - enter' );
        
        
        //Check for user access before quering the fields.
        List<String> queryFields = new List<String> {'Id','Name','SVMXC__Working_Hours__c','SVMXC__Break_Hours__c','SVMXC__Overtime_Hours__c','SVMXC__Service_Group__r.name',
                                                    'SVMXC__Service_Territory__r.name','SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c',
                                                    'SVMXC__Service_Territory__r.SVMXC__Break_Hours__c'};
        
        
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Service_Group_Members__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        
        Map<Id, SVMXC__Service_Group_Members__c> technicianMap = new Map<Id, SVMXC__Service_Group_Members__c>(
                [select Id, Name,SVMXC__Working_Hours__c , SVMXC__Break_Hours__c,SVMXC__Overtime_Hours__c, 
                 SVMXC__Service_Group__r.name, SVMXC__Service_Territory__r.name, 
                 SVMXC__Service_Territory__r.SVMXC__Territory_s_Business_Hours__c,
                 SVMXC__Service_Territory__r.SVMXC__Break_Hours__c 
                 from SVMXC__Service_Group_Members__c where Id IN: technicianIds]);
        
        System.debug( LoggingLevel.DEBUG, 'Number of Techicians() - ' + technicianMap.size());
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Technician_Utilization.populateTechnicians() - exit' );
        return technicianMap;
    }
    
    
    global void finish(Database.BatchableContext context) {
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Technician_Utilization.finish() - enter' );
        
        //Add the dispatch process names, territory and technician info.
        if(this.processNames.size() > 0) {
            auditLog.addMessage('Dispatch Processes - ' + this.processNames);
            auditLog.addMessage('Technicians - ' + this.technicians);
            auditLog.addMessage('Territories - ' + this.territories);
        }
        auditLog.addMessage('Total Number of Events Processed - ' + auditLog.totalRecordsCount);
        auditLog.addMessage('Report Generation Start Time - ' + auditLog.startTime);
        auditLog.addMessage('Report Generation End Time - ' + System.now());
        auditLog.addMessage('Report generation success status - '+ auditLog.isSuccess);
        auditLog.addMessage('Time taken to generate the report (in ms) - '+ (System.now().getTime() - auditLog.startTime.getTime()));
        auditLog.addMessage('User initiating the report - ' + UserInfo.getName());
        String emailId = '';
        if( !Test.isRunningTest() ) { //Temp Fix
            //parse the configuration and extract the emailId.
            emailId = SPM_Utilities.getInstance().loadConfigurationValue('emailId'); 
        }
        auditLog.saveAuditAndSendMessage(emailId, 'SPM Scheduled Technician Utilization');
        
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Technician_Utilization.finish() - exit' );
    }
}