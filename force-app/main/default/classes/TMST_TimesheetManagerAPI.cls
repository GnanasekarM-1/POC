/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The TMST_TimesheetManagerAPI implements methods to perform Save, Delete & retrieve 
 * Timesheet configurations. Internally, the Timesheet configurations will be saved 
 * in ServiceMax_Processes__c object and scheduler & profile association details are 
 * saved ServiceMax_Config_Data__c object.
 * 
 * <b>Note:</b> Record type 'Timesheet' has been used to save Timesheet configuration's, 
 * record type 'Timesheet Access' has been used to save Profile - Timesheet mapping and
 * record type 'Schedule' has been used to save schedule configuration for Timesheet.
 *
 * @author Ramachandra Mohan
 * @version 15.49100
 * @since 2015
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan      28 Jan 2015     Created.
 *              Ramachandra Mohan      15 Jun 2015     Updated code to support email on success and email om error.
 *              Ramachandra Mohan      15 Jun 2015     Created new method validateEmailAddress().
 * 018603       Ramachandra Mohan      08 Jul 2015     Updated additional validations for Event Type.
 * 017951       Ramachandra Mohan      09 Jul 2015     Updated query to retrieve only non global profiles.
 * 018852       Ramachandra Mohan      10 Jul 2015     Updated query to retrieve and save Timezone.
 *              Ramachandra Mohan      31 Mar 2016     Security fixes.
 * BAC-542      Ramachandra Mohan      02 Aug 2016     Support for Run Now.
 * BAC-549      Ramachandra Mohan      03 Aug 2016     Restrict field validation on End Date only for Weekly period.
 * 035187       Ramachandra Mohan      12 Aug 2016     Additional check to validate active timesheet before batch execution.
 * 035205       Ramachandra Mohan      12 Aug 2016     Moved success message population to outside for loop in executeBatch().
 * 035353       Ramachandra Mohan      17 Aug 2016     Additional check to validate active autofill before batch execution.
 * 035405       Ramachandra Mohan      19 Aug 2016     Updated query to retrieve only one schedule info in executeBatch.
 * 037310       Sachin S               04 Nov 2016     Updated Batch size and batch limit to retrieve from settings.
 * BAC-1276     Sourabh Singh          19 Dec 2016     changes to support prior time sheet entries
 *              Soumyaranjan           12th July 2018   Security Scanned
 * BAC-5189     Soumyaranjan Pati      9th Sept 2019   Configuration Profile Setting to Filter Which Users have Timesheets Processed
 *****************************************************************************************************/
/* Security Scanned */
public with sharing class TMST_TimesheetManagerAPI {
 
    /** 
     * Regular expression to validate email address.
     * Source: http://www.regular-expressions.info/email.html
     */
    private static String EMAIL_REGULAR_EXPRESSION = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; 
    private Map<Id,String> timesheetConfigProfileswithSFIdMap = new Map<Id,String>(); // Added for BAC-5189
    /**
     * Constructs TMST_TimesheetManagerAPI class instance.
     */
    public TMST_TimesheetManagerAPI() {
    }
    
    /**
     * This method is used to delete Timesheet configuration for all requested Timesheet 
     * process Id's in TMST_Request. The scheduler and profile mapping associatd to the 
     * timesheet also removed from the ServiceMax_Config_Data object.
     *
     * @param request The TMST_WrapperDef.TMST_Request object instance which contains list of timesheet 
     * Ids for which timesheet processes to be removed. 
     *
     * @return TMST_WrapperDef.TMST_Response This method returns response object with success=true 
     * if successfully deleted atleast one process from requested process Id's, Otherwise success=false, 
     * If delete operation failed to delete all timesheet configurations along with schedule & profile 
     * mapping details or any DML/Query exceptions.
     *
     * @exception QueryException On query execution error.
     * @exception DMLException On insert/delete/upsert error.
     */
    public TMST_WrapperDef.TMST_Response deleteTimesheetProcess( TMST_WrapperDef.TMST_Request request ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteTimesheetProcess() - enter; request = ' + request );        
        TMST_WrapperDef.TMST_Response response = new TMST_WrapperDef.TMST_Response();
        
        /*
         * TMST_WrapperDef.TMST_Request object instance validation. The delete operation at least need 
         * one valid timesheet process Id.
         */
        if( request == null || request.timesheetConfigurationList == null || request.timesheetConfigurationList.isEmpty() ) {
        
            System.debug( LoggingLevel.ERROR, 'deleteTimesheetProcess() : Null request or Empty timesheet configuration list in request.' );
            
            response.success = false;
            response.messageList.add( System.label.TMST001_TAG001 );
            
            return response;
        }
        
        System.debug( LoggingLevel.DEBUG, 'deleteTimesheetProcess() : Retrieving processIDs from request.' );
        
        /* Get all timesheet process Id's from request which needs to be deleted. */
        List<String> timesheetIdList = new List<String>();
        
        for( TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration : request.timesheetConfigurationList ) {
        
            if( timesheetConfiguration.timesheetProcess == null || 
                timesheetConfiguration.timesheetProcess.SVMXC__ProcessID__c == null ||
                timesheetConfiguration.timesheetProcess.SVMXC__ProcessID__c == '' ) {
            
                System.debug( LoggingLevel.ERROR, 'deleteTimesheetProcess() : Null timesheetProcess or processID value in request.' );
            
                response.success = false;
                response.messageList.add( System.label.TMST001_TAG001 );
            
                return response;
            }
            timesheetIdList.add( timesheetConfiguration.timesheetProcess.SVMXC__ProcessID__c );            
        }
        
        System.debug( LoggingLevel.DEBUG, 'deleteTimesheetProcess() : Deleting Timesheet processes ' + timesheetIdList );
        
        Savepoint sp = Database.setSavepoint();
        
        try {
        
            List<String> queryFields = new List<String> {'Id', 'SVMXC__Name__c', 'SVMXC__ProcessID__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            /* Retrieve all Timesheet process for requested list of process Id's. */
            Map<Id,SVMXC__ServiceMax_Processes__c> timesheetProcessMap = new Map<Id,SVMXC__ServiceMax_Processes__c>();
            timesheetProcessMap.putAll( [SELECT Id, SVMXC__Name__c, SVMXC__ProcessID__c FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name =: TMST_Consts.RECORD_TYPE_TIMESHEET AND SVMXC__ProcessID__c IN :timesheetIdList ] );
            
            if( timesheetProcessMap.isEmpty() ) {        

                System.debug( LoggingLevel.ERROR, 'deleteTimesheetProcess() : Timesheet processes not exists for given process Ids.' );
                
                response.success = false;
                response.messageList.add( System.label.TMST001_TAG003 + timesheetIdList );
            
                return response;
            }
            
            if( !COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            queryFields = new List<String> {'Id', 'SVMXC__Dispatch_Process__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            /*
             * Delete all associated schedule and profile association configurations from ServiceMax_Config_Data__c 
             * for requested Timesheet process Id's. 
             */
            delete [ SELECT Id, SVMXC__Dispatch_Process__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Dispatch_Process__c IN :timesheetProcessMap.keySet() AND ( SVMXC__RecordType_Name__c =: TMST_Consts.RECORD_TYPE_TIMESHEET_ACCESS OR SVMXC__RecordType_Name__c =: TMST_Consts.RECORD_TYPE_SCHEDULE ) ];
            System.debug( LoggingLevel.INFO, 'deleteTimesheetProcess() : Successfully deleted schedule & profile associations.' );
            
            System.debug( LoggingLevel.DEBUG, 'deleteTimesheetProcess() : Deleting Timesheet processes, schedule and profile access details.' );
            
            if( !COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Processes__c' ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            /* Delete all Timesheet process record from ServiceMax_Processes__c for requested process Ids. */
            delete timesheetProcessMap.values();            
            System.debug( LoggingLevel.INFO, 'deleteTimesheetProcess() : Successfully deleted Timesheet processes.' );
        }
        
        catch( QueryException ex ) {
        
            System.debug( LoggingLevel.ERROR, 'deleteTimesheetProcess() : Failed to retrieve Timesheet processes ' + ex.getMessage() );
            
            Database.rollback( sp );
            
            response.success = false;
            response.messageList.add( System.label.TMST001_TAG002 + ex.getMessage() );
        }
        
        catch( DMLException ex ) {
        
            System.debug( LoggingLevel.ERROR, 'deleteTimesheetProcess() : Failed to delete Timesheet processes. ' + ex.getMessage() );
            
            Database.rollback( sp );
            
            response.success = false;
            response.messageList.add( System.label.TMST001_TAG004 + ex.getMessage() );
        }
        
        catch( Exception ex ) {
        
            System.debug( LoggingLevel.ERROR, 'deleteTimesheetProcess() : Exception while deleting timesheet process.' + ex.getMessage() );
            
            Database.rollback( sp );
            
            response.success = false;
            response.messageList.add( System.label.TMST001_TAG006 + ex.getMessage() );
        }
        
        System.debug( LoggingLevel.DEBUG, 'deleteTimesheetProcess() - exit' );
        
        return response;
    }
      //Added for BAC-5314
    private void updateTimesheetAccessProfileData(){
    List<SVMXC__ServiceMax_Config_Data__c> listConfigData = [SELECT Id, RecordType.Name, SVMXC__Profile__c,SVMXC__Access_Configuration_Profile__c, SVMXC__SM_Scope__c, SVMXC__Dispatch_Process__c FROM  SVMXC__ServiceMax_Config_Data__c WHERE (RecordType.Name = 'Timesheet Access' and SVMXC__Dispatch_Process__r.RecordType.Name = 'Timesheet') OR (RecordType.Name = 'Configuration Access')];
    Map<String, List<String>> mapTimesheetConfigProfileandSFProfile = new Map<String, List<String>>();
    Map<String,SVMXC__ServiceMax_Config_Data__c> listOfSalesforceProfile = new Map<String,SVMXC__ServiceMax_Config_Data__c>();
    List<SVMXC__ServiceMax_Config_Data__c> listOfTimesheetAccessConfigData = new List<SVMXC__ServiceMax_Config_Data__c> ();
    for(SVMXC__ServiceMax_Config_Data__c configVar:listConfigData){
        if(configVar.RecordType.Name.equalsIgnoreCase('Timesheet Access')){
          if(configVar.SVMXC__SM_Scope__c != null)
            listOfSalesforceProfile.put(configVar.SVMXC__SM_Scope__c, configVar);
        }
        if(configVar.RecordType.Name.equalsIgnoreCase('Configuration Access') && configVar.SVMXC__Access_Configuration_Profile__c != null && configVar.SVMXC__Profile__c !=null){
          
          if(!mapTimesheetConfigProfileandSFProfile.containsKey(configVar.SVMXC__Access_Configuration_Profile__c)){
            mapTimesheetConfigProfileandSFProfile.put(configVar.SVMXC__Access_Configuration_Profile__c, new List<String>());
          }
          mapTimesheetConfigProfileandSFProfile.get(configVar.SVMXC__Access_Configuration_Profile__c).add(configVar.SVMXC__Profile__c);
          
          
        }
    }
    System.debug('mapTimesheetConfigProfileandSFProfile '+mapTimesheetConfigProfileandSFProfile);
    for(String sfdcIds : listOfSalesforceProfile.keySet()){
    SVMXC.TMST_WrapperDef.SalesforceProfileInfo tsWrap = new SVMXC.TMST_WrapperDef.SalesforceProfileInfo();
    tsWrap = (SVMXC.TMST_WrapperDef.SalesforceProfileInfo) JSON.deserialize(sfdcIds, SVMXC.TMST_WrapperDef.SalesforceProfileInfo.class);
    List<SVMXC.TMST_WrapperDef.ObjectInfo> salesforceProfileIdsTemp = new List<SVMXC.TMST_WrapperDef.ObjectInfo>(); 
        for(SVMXC.TMST_WrapperDef.ObjectInfo objectInfoVar: tsWrap.salesforceProfileIds){
          if(mapTimesheetConfigProfileandSFProfile.containsKey(listOfSalesforceProfile.get(sfdcIds).SVMXC__Access_Configuration_Profile__c) && mapTimesheetConfigProfileandSFProfile.get(listOfSalesforceProfile.get(sfdcIds).SVMXC__Access_Configuration_Profile__c).contains(objectInfoVar.Id)){ 
            salesforceProfileIdsTemp.add(objectInfoVar); 
          }
          
        }

        if( tsWrap.salesforceProfileIds.size() > salesforceProfileIdsTemp.size()){
          SVMXC.TMST_WrapperDef.SalesforceProfileInfo tsWrapTemp = new SVMXC.TMST_WrapperDef.SalesforceProfileInfo();
          tsWrapTemp.salesforceProfileIds = salesforceProfileIdsTemp;
          SVMXC__ServiceMax_Config_Data__c configDataTemp = listOfSalesforceProfile.get(sfdcIds);
          configDataTemp.SVMXC__SM_Scope__c = JSON.serialize(tsWrapTemp);
          listOfTimesheetAccessConfigData.add(configDataTemp);
          
        }
    }

    System.debug('listOfTimesheetAccessConfigData '+listOfTimesheetAccessConfigData);
    if(listOfTimesheetAccessConfigData.size() > 0){
      upsert listOfTimesheetAccessConfigData;
    }
    }
    /**
     * This method is used to retrieve all timesheet processes from ServiceMax_Processes__c and 
     * its configuration details from ServiceMax_Config_Data__c objects.
     *
     * @return TMST_WrapperDef.TMST_Response Returns response object with list of timesheet processes 
     * and its configuration data. All the configuration profiles will also be populated to the 
     * response which is used to map profiles to timesheet processes.
     *
     * @exception QueryException On query execution error.
     */
    public TMST_WrapperDef.TMST_Response getAllTimesheetProcess() {
        updateTimesheetAccessProfileData(); //Added for BAC-5314 Update the Timesheet access config data if admin had changed the ServiceMax config profile
    
        System.debug( LoggingLevel.DEBUG, 'getAllTimesheetProcess() - enter' );
        
        TMST_WrapperDef.TMST_Response response = new TMST_WrapperDef.TMST_Response();
                 
        try {
            //Added SVMXC__SM_Business_Hour_Source__c to SOQL for BAC-5388
            List<String> queryFields = new List<String> {'Id', 'SVMXC__SM_Business_Hour_Source__c', 'LastModifiedDate', 'SVMXC__Name__c', 'SVMXC__ProcessID__c', 'SVMXC__Description__c', 'SVMXC__Active__c', 'SVMXC__Notify_technician__c', 'SVMXC__Business_Hours__c', 'SVMXC__Event_Type__c', 'SVMXC__Field_Name__c', 'SVMXC__Start_Date__c', 'SVMXC__End_Date__c', 'SVMXC__Process__c', 'SVMXC__Process1__c', 'SVMXC__Process2__c', 'SVMXC__Process3__c', 'SVMXC__Parent_Object__c', 'SVMXC__Node_Parent__c', 'SVMXC__Submodule__c', 'SVMXC__Module__c', 'SVMXC__Email_On_Success__c', 'SVMXC__Email_On_Error__c', 'SVMXC__Dispatch_Timezone__c'  };
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            /* Retrieve all timesheet process records from ServiceMax_Processes__c object. */
            Map<Id,SVMXC__ServiceMax_Processes__c> timesheetProcessMap = new Map<Id,SVMXC__ServiceMax_Processes__c>();
            timesheetProcessMap.putAll( [SELECT Id, SVMXC__SM_Business_Hour_Source__c, LastModifiedDate, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Active__c, SVMXC__Notify_technician__c, SVMXC__Business_Hours__c, SVMXC__Event_Type__c, SVMXC__Field_Name__c, SVMXC__Start_Date__c, SVMXC__End_Date__c, SVMXC__Process__c, SVMXC__Process1__c, SVMXC__Process2__c, SVMXC__Process3__c, SVMXC__Parent_Object__c, SVMXC__Node_Parent__c, SVMXC__Submodule__c, SVMXC__Module__c, SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c, SVMXC__Dispatch_Timezone__c FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name =: TMST_Consts.RECORD_TYPE_TIMESHEET ] );
            
            System.debug( LoggingLevel.DEBUG, 'getAllTimesheetProcess() : Number of Timesheet processes = '+  timesheetProcessMap.size() );
            
            queryFields = new List<String> {'Id', 'SVMXC__Internal_Value__c', 'SVMXC__Profile__c', 'SVMXC__SM_Scope__c', 'SVMXC__Dispatch_Process__c', 'SVMXC__Period__c', 'SVMXC__Access_Configuration_Profile__c', 'SVMXC__RecordType_Name__c', 'SVMXC__Profile_Name__c', 'SVMXC__Description__c', 'SVMXC__Active__c', 'SVMXC__Schedule_Days__c', 'SVMXC__Run_At__c', 'SVMXC__Day_to_Run__c', 'SVMXC__Schedule_Type__c', 'SVMXC__Sequence__c', 'SVMXC__Period_Start_On__c', 'SVMXC__Period_End_On__c', 'SVMXC__Run_Type__c',  'SVMXC__SM_Prior_Timesheet_Periods__c' };
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            /*
             * Retrieve all schedule and profile access configurations from ServiceMax_Config_Data__c 
             * for retrieved Timesheet processes. 
             */
            //Added order by SVMXC__Sequence__c for BAC-4864
            //Added SVMXC__Internal_Value__c to SOQL for BAC-5411
            //Added OR ( SVMXC__RecordType_Name__c =: TMST_Consts.RECORD_TYPE_CONFIGURATION_ACCESS AND SVMXC__Access_Configuration_Profile__c !=null AND SVMXC__Access_Configuration_Profile__r.SVMXC__RecordType_Name__c =: TMST_Consts.RECORD_TYPE_CONFIGURATION_PROFILE ) in where clause and SVMXC__Profile__c,SVMXC__SM_Scope__c in SOQL for BAC-5189
            List<SVMXC__ServiceMax_Config_Data__c> configurationDataList = [ SELECT Id, SVMXC__Internal_Value__c, SVMXC__Profile__c, SVMXC__SM_Scope__c, SVMXC__Dispatch_Process__c, SVMXC__Period__c, SVMXC__SM_Prior_Timesheet_Periods__c,  SVMXC__Access_Configuration_Profile__c, SVMXC__RecordType_Name__c, SVMXC__Profile_Name__c, SVMXC__Description__c, SVMXC__Active__c, SVMXC__Schedule_Days__c, SVMXC__Run_At__c, SVMXC__Day_to_Run__c, SVMXC__Schedule_Type__c, SVMXC__Sequence__c, SVMXC__Period_Start_On__c, SVMXC__Period_End_On__c, SVMXC__Run_Type__c FROM SVMXC__ServiceMax_Config_Data__c WHERE ( SVMXC__Dispatch_Process__c IN :timesheetProcessMap.keySet() AND ( SVMXC__RecordType_Name__c =: TMST_Consts.RECORD_TYPE_SCHEDULE OR SVMXC__RecordType_Name__c =: TMST_Consts.RECORD_TYPE_TIMESHEET_ACCESS ) ) OR ( SVMXC__RecordType_Name__c =: TMST_Consts.RECORD_TYPE_CONFIGURATION_PROFILE AND SVMXC__Configuration_Type__c =: TMST_Consts.CONFIGURATION_TYPE_GROUP ) OR ( SVMXC__RecordType_Name__c =: TMST_Consts.RECORD_TYPE_CONFIGURATION_ACCESS AND SVMXC__Access_Configuration_Profile__c !=null AND SVMXC__Access_Configuration_Profile__r.SVMXC__RecordType_Name__c =: TMST_Consts.RECORD_TYPE_CONFIGURATION_PROFILE ) order by SVMXC__Sequence__c];

            Map<Id, List<SVMXC__ServiceMax_Config_Data__c>> timesheetProcessScheduleMap = new Map<Id, List<SVMXC__ServiceMax_Config_Data__c>>();
            Map<Id, List<SVMXC__ServiceMax_Config_Data__c>> timesheetProfileAssociationMap = new Map<Id, List<SVMXC__ServiceMax_Config_Data__c>>();
            Map<Id, TMST_WrapperDef.TMST_TimesheetAccess> configurationProfileMap = new Map<Id,TMST_WrapperDef.TMST_TimesheetAccess>();
            Map<String, String> salesforceConfigurationProfileMap = new Map<String, String>(); // Added for BAC-5189
            Map<Id,TMST_WrapperDef.SalesforceProfileAssociation> mapTmstMang = new Map<Id,TMST_WrapperDef.SalesforceProfileAssociation>(); // Added for BAC-5189
            /*
             * Populate timesheet schedule, profile access and configuration profile maps 
             * from retrieved configuration data list.
             */
            for( SVMXC__ServiceMax_Config_Data__c configurationData : configurationDataList ) {
            
                if( configurationData.SVMXC__RecordType_Name__c.equalsIgnoreCase( TMST_Consts.RECORD_TYPE_SCHEDULE ) ) {  
                    
                    if( ! timesheetProcessScheduleMap.containsKey( configurationData.SVMXC__Dispatch_Process__c ) ) {
                        timesheetProcessScheduleMap.put(configurationData.SVMXC__Dispatch_Process__c, new List<SVMXC__ServiceMax_Config_Data__c>());
                    }

                    timesheetProcessScheduleMap.get( configurationData.SVMXC__Dispatch_Process__c ).add( configurationData );                         
                } else if( configurationData.SVMXC__RecordType_Name__c.equalsIgnoreCase( TMST_Consts.RECORD_TYPE_TIMESHEET_ACCESS ) ) {
                
                    /*
                     * One timesheet process may have list of profiles associated to it. 
                     * Create list of ServiceMax_Config_Data__c object for each timesheet process.
                     */
                    if( !timesheetProfileAssociationMap.containsKey( configurationData.SVMXC__Dispatch_Process__c ) ) {
                        timesheetProfileAssociationMap.put( configurationData.SVMXC__Dispatch_Process__c, new List<SVMXC__ServiceMax_Config_Data__c>() );    
                    }
                    
                    timesheetProfileAssociationMap.get( configurationData.SVMXC__Dispatch_Process__c ).add( configurationData );
                } else if( configurationData.SVMXC__RecordType_Name__c.equalsIgnoreCase( TMST_Consts.RECORD_TYPE_CONFIGURATION_PROFILE ) ) {
                    
                    /*
                     * Populating all configuration profiles to map. This data will be used in client 
                     * to assign one or more profiles to timesheet processes.
                     */
                    TMST_WrapperDef.TMST_TimesheetAccess timesheetAccess = new TMST_WrapperDef.TMST_TimesheetAccess();                                
                    timesheetAccess.configProfile = configurationData;
                            
                    configurationProfileMap.put( configurationData.Id, timesheetAccess );
                }
                if( configurationData.SVMXC__RecordType_Name__c.equalsIgnoreCase( TMST_Consts.RECORD_TYPE_CONFIGURATION_ACCESS ) ) { // Added for BAC-5189
                    
                    /*
                     * Populating all salesforce profiles to map. This data will be used in client 
                     * to assign one or more profiles to timesheet processes.
                     */
                     salesforceConfigurationProfileMap.put(configurationData.SVMXC__Profile__c, configurationData.SVMXC__Access_Configuration_Profile__c);
                    
                }
            }
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            for(Profile pro: [select id, Name, Description from Profile where id IN: salesforceConfigurationProfileMap.keySet()]){ // Added for BAC-5189
                TMST_WrapperDef.SalesforceProfileAssociation tmstMang = new TMST_WrapperDef.SalesforceProfileAssociation();
                tmstMang.profileId = pro.id;
                tmstMang.profileName = pro.Name;
                tmstMang.description = pro.Description;
                tmstMang.timesheetProcessId = String.valueOf(salesforceConfigurationProfileMap.get(pro.id));
                tmstMang.leaf = true;
                mapTmstMang.put(pro.id,tmstMang);
                
            }
            /* Populate all timesheet processes and associated schedule, profile access details into response object. */
            for( SVMXC__ServiceMax_Processes__c timesheetProcess : timesheetProcessMap.values() ) {
        
                TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration = new TMST_WrapperDef.TMST_TimesheetConfiguration();
                timesheetConfiguration.timesheetProcess = timesheetProcess;
                
                /*
                 * Populate schedule and autofill schedule data for timesheet process if exists. One schedule and 
                 * at-least one profile must be associated to each timesheet process. Warn user in case of invalid data in database.
                 */
                if( timesheetProcessScheduleMap.containsKey( timesheetProcess.Id ) ) {                    
                    timesheetConfiguration.scheduleDetailsList = timesheetProcessScheduleMap.get( timesheetProcess.Id );
                } else {
                    
                    //response.warning = true;
                    //response.messageList.add( 'WARNING: Schedule details not exists for Timesheet Process ' + timesheetProcess.SVMXC__Name__c );
                    System.debug( LoggingLevel.WARN, 'Schedule details not exists for Timesheet Process ' + timesheetProcess.SVMXC__Name__c  );
                }
                
                /* Performe field level validations on timesheet process and configuration. */
                if( !validateTimesheetProcess( response, timesheetConfiguration.timesheetProcess, timesheetConfiguration.scheduleDetailsList ) ) {
                    
                    System.debug( LoggingLevel.ERROR, 'getAllTimesheetProcess() : Data validation failed ' + response.messageList );
                    continue;
                }
                
                /*
                 * Populate all profile associations for each timesheet process. At-least one profile 
                 * must be mapped to each timesheet process.
                 */
                if( timesheetProfileAssociationMap.containsKey( timesheetProcess.Id ) ) {
                
                    List<SVMXC__ServiceMax_Config_Data__c> profileAccessList = timesheetProfileAssociationMap.get( timesheetProcess.Id );
                    
                    for( SVMXC__ServiceMax_Config_Data__c profileAccess : profileAccessList ) {
                    
                        /*
                         * Check whether salesforce Id assigned to timesheet is a valid configuration profile 
                         * record Id or not. Warn user if the Id is an invalid configuration profile record Id.
                         */
                        if( configurationProfileMap.containsKey( profileAccess.SVMXC__Access_Configuration_Profile__c ) ) {
                        
                            TMST_WrapperDef.TMST_TimesheetAccess timesheetAccess = configurationProfileMap.get( profileAccess.SVMXC__Access_Configuration_Profile__c );
                            //Start Added for BAC-5189
                            SVMXC__ServiceMax_Config_Data__c configProfileTemp = new SVMXC__ServiceMax_Config_Data__c();
                            configProfileTemp = timesheetAccess.configProfile;
                            configProfileTemp.SVMXC__SM_Scope__c = profileAccess.SVMXC__SM_Scope__c;
                            timesheetAccess.configProfile = configProfileTemp;
                            //End Added for BAC-5189

                            timesheetAccess.timesheetProcessId = timesheetProcess.SVMXC__ProcessID__c;
                            timesheetAccess.timesheetProcessName  = timesheetProcess.SVMXC__Name__c;
                            
                            timesheetConfiguration.assignedProfilesList.add( timesheetAccess );
                        } else {
                        
                            response.warning = true;
                            response.messageList.add( 'Invalid profile id ' + profileAccess.SVMXC__Access_Configuration_Profile__c + ' in timesheet process ' + timesheetProcess.SVMXC__Name__c );
                            continue;
                        }
                    }
                } else {                
                    System.debug( LoggingLevel.WARN, System.label.TMST001_TAG007 + timesheetProcess.SVMXC__Name__c );
                }
            
                response.timesheetConfigurationList.add( timesheetConfiguration );                    
            }
            response.salesforceProfileIds.addAll(mapTmstMang.values()); // Added for BAC-5189
            response.profileAssociationList = configurationProfileMap.values();
        }
        
        catch( QueryException ex ) {
        
            System.debug( LoggingLevel.ERROR, 'getAllTimesheetProcess() : Failed to retrieve Timesheet process records.' + ex.getMessage() );
                    
            response.success = false;
            response.messageList.add( System.label.TMST001_TAG002 + ex.getMessage() );
        }
        
        catch( Exception ex ) {
        
            System.debug( LoggingLevel.ERROR, 'getAllTimesheetProcess() : Exception while retrieving timesheet process.' + ex.getMessage() );
            
            response.success = false;
            response.messageList.add( System.label.TMST001_TAG006 + ex.getMessage() );
        }
        
        System.debug( LoggingLevel.DEBUG, 'getAllTimesheetProcess() - exit' );        
        return response;
    }
    
    /**
     * This method is used to save Timesheet processes to ServiceMax_Processes__c object and respective 
     * schedule & profile access informations into ServiceMax_Config_Data__c objects.
     *
     * @param request The TMST_WrapperDef.TMST_Request object instance which has timesheet process 
     * informations to be saved.
     *
     * @return TMST_WrapperDef.TMST_Response This method returns response object with success=true 
     * if successfully saved all requested timesheet processes, Otherwise success=false.
     *
     * @exception QueryException On query execution error.
     * @exception DMLException On insert/delete/upsert error.
     */
    public TMST_WrapperDef.TMST_Response saveTimesheetConfiguration( TMST_WrapperDef.TMST_Request request ) {
    
        System.debug( LoggingLevel.DEBUG, 'saveTimesheetConfiguration() - enter; request = ' + request );        
        TMST_WrapperDef.TMST_Response response = new TMST_WrapperDef.TMST_Response();
        
        /*
         * Request object instance validation. At-least one timesheet process data must exists 
         * to continue save operation.
         */
        if( request == null || request.timesheetConfigurationList == null || request.timesheetConfigurationList.isEmpty() ) {
        
            System.debug( LoggingLevel.ERROR, 'saveTimesheetConfiguration() : Null request or Empty timesheet configuration list in request.' );
            
            response.success = false;
            response.messageList.add( System.label.TMST001_TAG001 );
            
            return response;
        }
        
        /* Populate timesheet process and schedule detail map from request. */
        Map<String,SVMXC__ServiceMax_Processes__c> timesheetProcessInputMap = new Map<String,SVMXC__ServiceMax_Processes__c>();
        Map<String,List<SVMXC__ServiceMax_Config_Data__c>> scheduleConfigDataInputMap = new Map<String,List<SVMXC__ServiceMax_Config_Data__c>>();
        Map<String,List<Id>> timesheetAssignedProfilesMap = new Map<String,List<Id>>();
        
        for( TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration : request.timesheetConfigurationList ) {
        
            if( timesheetConfiguration == null || timesheetConfiguration.timesheetProcess == null ) {
            
                System.debug( LoggingLevel.ERROR, 'saveTimesheetConfiguration() : Null timesheet configuration or timesheetProcess in request.' );
                
                response.success = false;
                response.messageList.add( System.label.TMST001_TAG001 );
            
                return response;
            }
            
            /*
             * Generate timesheet process Id if not exists. New timesheet process record will be created 
             * for timesheet process with null/empty process Id request.  
             */
            if( timesheetConfiguration.timesheetProcess.SVMXC__ProcessID__c == null || timesheetConfiguration.timesheetProcess.SVMXC__ProcessID__c == '' ) {

                if( timesheetConfiguration.timesheetProcess.SVMXC__Name__c != null ) {
                    
                    Integer endIndex = Math.min( timesheetConfiguration.timesheetProcess.SVMXC__Name__c.length(), TMST_Consts.MIN_TEXT_LENGTH );
                    timesheetConfiguration.timesheetProcess.SVMXC__ProcessID__c = timesheetConfiguration.timesheetProcess.SVMXC__Name__c.substring(0, endIndex) + System.currentTimeMillis();
                               
                    System.debug( LoggingLevel.INFO, 'Generated timesheet process Id ' + timesheetConfiguration.timesheetProcess.SVMXC__ProcessID__c );    
                }                
            }
            
            /*
             * At-least one profile must be assigned to each timesheet process. The timesheet process 
             * will be of no use without profiles associated to it.  
             */
            if( timesheetConfiguration.assignedProfilesList != null && !timesheetConfiguration.assignedProfilesList.isEmpty() ) {
            
                List<Id> profileIdList = new List<Id>();
                for( TMST_WrapperDef.TMST_TimesheetAccess timesheetAccess : timesheetConfiguration.assignedProfilesList ) {
                
                    /* Check for valid timesheet access instance with profile id. */
                    if( timesheetAccess != null && timesheetAccess.configProfile != null && timesheetAccess.configProfile.Id != null ) {
                        profileIdList.add( timesheetAccess.configProfile.Id );
                        timesheetConfigProfileswithSFIdMap.put(timesheetAccess.configProfile.Id, timesheetAccess.configProfile.SVMXC__SM_Scope__c); // Added for BAC-5189
                    } else {

                        response.success = false;
                        response.messageList.add( System.label.TMST001_TAG007 + timesheetAccess );
                        
                        return response;
                    }
                }
                
                /* Populate list of mapped profiles for each timesheet process. */
                timesheetAssignedProfilesMap.put( timesheetConfiguration.timesheetProcess.SVMXC__ProcessID__c, profileIdList );
            } else if( timesheetConfiguration.timesheetProcess.SVMXC__Active__c ) {
            
                response.success = false;
                response.messageList.add( System.label.TMST001_TAG007 + timesheetConfiguration.timesheetProcess.SVMXC__Name__c );
                continue;
            }
            
            /* Performe field level validations on timesheet process and configuration. */
            if( !validateTimesheetProcess( response, timesheetConfiguration.timesheetProcess, timesheetConfiguration.scheduleDetailsList ) ) {
                
                System.debug( LoggingLevel.ERROR, 'saveTimesheetConfiguration() : Data validation failed ' + response.messageList );
                response.success = false;
                return response;
            }
            
            /* Populate timesheet process and schedule map. */
            timesheetProcessInputMap.put( timesheetConfiguration.timesheetProcess.SVMXC__ProcessID__c, timesheetConfiguration.timesheetProcess );            
            scheduleConfigDataInputMap.put( timesheetConfiguration.timesheetProcess.SVMXC__ProcessID__c, timesheetConfiguration.scheduleDetailsList );
        }
        
        System.debug( LoggingLevel.DEBUG, 'saveTimesheetConfiguration() : Timesheet Processes ' + timesheetProcessInputMap.values() );
        System.debug( LoggingLevel.DEBUG, 'saveTimesheetConfiguration() : Schedule Details ' + scheduleConfigDataInputMap.values() );
        
        /*
         * Set save point, which will be used to rollback when DML operations are 
         * failed to save timesheet or schedule details.
         */
        Savepoint sp = Database.setSavepoint();
        
        try {
        
            /*
             * Populate record type map for all required record types. i.e 'Timesheet', 'Timesheet Access', 
             * 'Schedule' & 'Configuration Profile'.
             */
            Map<String,RecordType> recordTypeMap = buildRecordTypeMap();
            
            /* Upsert timesheet processes and get list of SObject for all updated and created timesheet processes. */
            List<SVMXC__ServiceMax_Processes__c> timesheetProcessList = upsertTimesheetProcess( timesheetProcessInputMap, recordTypeMap, response );            
            System.debug( LoggingLevel.INFO, 'saveTimesheetConfiguration() : Successfully created/updated Timesheet processes.' );
            
            /* Populate Id vs Timesheet process object map which will be used to create schedule detail records. */
            Map<Id,SVMXC__ServiceMax_Processes__c> idTimesheetProcessMap = new Map<Id,SVMXC__ServiceMax_Processes__c>();             
                
            for( SVMXC__ServiceMax_Processes__c resultTimesheetProcess : timesheetProcessList ) {
                idTimesheetProcessMap.put( resultTimesheetProcess.Id, resultTimesheetProcess );
            }
            
            /*
             * Once Timesheet process successfully saved then save schedule and profile access details 
             * for each Timesheet process.
             */
            upsertTimesheetConfigurationData( idTimesheetProcessMap, scheduleConfigDataInputMap, timesheetAssignedProfilesMap, recordTypeMap );
            System.debug( LoggingLevel.INFO, 'saveTimesheetConfiguration() : Successfully created/updated schedule details.' );                        
        }
        
        catch( QueryException ex ) {
            
            System.debug( LoggingLevel.ERROR, 'saveTimesheetConfiguration() : Failed to retrieve timesheet process.' + ex.getMessage() );
            
            Database.rollback( sp );
                                
            response.success = false;
            response.messageList.add( System.label.TMST001_TAG002 + ex.getMessage() );
        }
        
        catch( DMLException ex ) {
        
            System.debug( LoggingLevel.ERROR, 'saveTimesheetConfiguration() : Failed to save timesheet process or schedule details.' + ex.getMessage() );
            
            Database.rollback( sp );
            
            response.success = false;
            response.messageList.add( System.label.TMST001_TAG005 + ex.getMessage() );
        }
        
        catch( Exception ex ) {
        
            System.debug( LoggingLevel.ERROR, 'saveTimesheetConfiguration() : Exception while saving timesheet process.' + ex.getMessage() );
            
            Database.rollback( sp );
            
            response.success = false;
            response.messageList.add( System.label.TMST001_TAG006 + ex.getMessage() );
        }
        
        System.debug( LoggingLevel.DEBUG, 'saveTimesheetConfiguration() - exit' );
        
        return response;
    }
    
    /**
     * @brief This method is used to execute timesheet auto-fill engine interactively.
     * 
     * @param request The TMST_WrapperDef.TMST_Request object instance with timesheet processId.
     * Timesheet header batch will be executed when scheduleType == 'TIMESHEETHEADER' and time entry 
     * batch will be executed when scheduleType == 'TIMESHEETAUTOFILL'.
     *
     * @return TMST_WrapperDef.TMST_Response This method returns response object with success=true 
     * if successfully started timesheed engine for given timesheet process, Otherwise success=false.
     */
    public TMST_WrapperDef.TMST_Response executeBatch( TMST_WrapperDef.TMST_Request request ) {
        
        System.debug( LoggingLevel.DEBUG, 'executeBatch() - enter');
        
        TMST_WrapperDef.TMST_Response response = new TMST_WrapperDef.TMST_Response();
        response.success = true;
        
        /*
         * TMST_WrapperDef.TMST_Request object instance validation. The delete operation at least need 
         * one valid timesheet process Id.
         */
        if( request == null || request.timesheetConfigurationList == null || request.timesheetConfigurationList.isEmpty() ) {
        
            System.debug( LoggingLevel.ERROR, 'executeBatch() : Null request or Empty timesheet configuration list in request.' );
            
            response.success = false;
            response.messageList.add( System.label.TMST001_TAG001 );
            
            return response;
        }
        
        /* Get timesheet process Id's and schedule type from request for which batch to be executed */
        String processID;
        String scheduleType;
        
        for( TMST_WrapperDef.TMST_TimesheetConfiguration timesheetConfiguration : request.timesheetConfigurationList ) {
        
            // Validate required parameters in request. Need process id and valid schedule 
            // type to start timesheet engine.
            if( timesheetConfiguration.timesheetProcess == null || 
                timesheetConfiguration.timesheetProcess.SVMXC__ProcessID__c == null ||
                timesheetConfiguration.timesheetProcess.SVMXC__ProcessID__c == '' || 
                timesheetConfiguration.scheduleType == null ||
                ( !timesheetConfiguration.scheduleType.equalsIgnoreCase(TMST_Consts.SCHEDULE_TYPE_TIMESHEET_HEADER) &&
                  !timesheetConfiguration.scheduleType.equalsIgnoreCase(TMST_Consts.SCHEDULE_TYPE_TIMESHEET_AUTOFILL) ) ) {
            
                System.debug( LoggingLevel.ERROR, 'executeBatch() : Required arguments not valid in request.' );
                      
                response.success = false;
                response.messageList.add( System.label.TMST001_TAG001 );
            
                return response;
            }
        
            // Currently support one process per run now call. Break the loop once one process id 
            // has been fetched from the request.
            processID = timesheetConfiguration.timesheetProcess.SVMXC__ProcessID__c;
            scheduleType = timesheetConfiguration.scheduleType;
            
            System.debug( LoggingLevel.DEBUG, 'executeBatch() : Retrieved processId and scheduleType. processId=' + processID + '; scheduleType=' + scheduleType );
            break;
        }
        
        //Retrieve number of active apex jobs. Salesforce can execute only 5 parallel batches at a given time.
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        Integer apexJobCount = [SELECT count() FROM AsyncApexJob Where JobType = 'BatchApex' AND (Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing')];
        System.debug( LoggingLevel.DEBUG, 'executeBatch() : Available apex jobs: ' + apexJobCount );
        
        //Settings to set batch queue and batch size
        integer maxBatchLimit = 5,batchSize = 1;
        map<string, Map<String, String>> mapSubmoduleIdMapSettingIdValue = new SVMXC.COMM_Utils_ManageSettings().SVMX_getSettingList(new List<String>{'GLOB001','TMST001'}); //SFM005 --> TMST001 for Timesheet
        map<String,String> mapGlobalSettingIdValue = new map<String,String>(); 
        if(mapSubmoduleIdMapSettingIdValue.containsKey('GLOB001') && mapSubmoduleIdMapSettingIdValue.get('GLOB001') != null ) {
            mapGlobalSettingIdValue = mapSubmoduleIdMapSettingIdValue.get('GLOB001');
        }
        if(mapGlobalSettingIdValue.containsKey('GBL020') && mapGlobalSettingIdValue.get('GBL020') != null){
            maxBatchLimit = integer.valueOf(mapGlobalSettingIdValue.get('GBL020'));
        }

        mapGlobalSettingIdValue = new map<String,String>(); 
        if(mapSubmoduleIdMapSettingIdValue.containsKey('TMST001') && mapSubmoduleIdMapSettingIdValue.get('TMST001') != null ) {
            mapGlobalSettingIdValue = mapSubmoduleIdMapSettingIdValue.get('TMST001');
        }
        if(mapGlobalSettingIdValue.containsKey('SET001') && mapGlobalSettingIdValue.get('SET001') != null){
            batchSize = integer.valueOf(mapGlobalSettingIdValue.get('SET001'));
        }        
        
        if( apexJobCount < maxBatchLimit) {
            
            // Retrieve all schedule details for requested process id and schedule type.
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            //Added SVMXC__Internal_Value__c to SOQL for BAC-5411
           //Philipse timesheet(044977 ) added SVMXC__Schedule_Days__c, SVMXC__Day_to_Run__c, SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Timezone__c
            List<SVMXC__ServiceMax_Config_Data__c> scheduleList = [Select SVMXC__Internal_Value__c, SVMXC__Schedule_Days__c, SVMXC__Day_to_Run__c, SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Timezone__c, SVMXC__SM_Prior_Timesheet_Periods__c, SVMXC__Dispatch_Process__c, SVMXC__Active__c, SVMXC__Period_Start_On__c, SVMXC__Period_End_On__c, SVMXC__Period__c, SVMXC__Schedule_Type__c, SVMXC__Dispatch_Process__r.SVMXC__Active__c FROM SVMXC__ServiceMax_Config_Data__c WHERE RecordType.Name = :TMST_Consts.RECORD_TYPE_SCHEDULE AND SVMXC__Dispatch_Process__r.RecordType.Name = :TMST_Consts.RECORD_TYPE_TIMESHEET AND SVMXC__Dispatch_Process__r.SVMXC__ProcessID__c = :processID AND SVMXC__Schedule_Type__c = :scheduleType LIMIT 1];
            
            // Process only if schedule configured for requested process id.
            if( !scheduleList.isEmpty() ) {
                
                // Start executing back for each configured schedule details.
                System.debug( LoggingLevel.DEBUG, 'executeBatch() : Executing batch for each schedule information.' );
                for( SVMXC__ServiceMax_Config_Data__c scheduleRecord : scheduleList ) {
                    
                    if( scheduleRecord.SVMXC__Dispatch_Process__r.SVMXC__Active__c == false ) {
                        
                        response.success = false;
                        response.messageList.add( System.Label.TMST001_TAG039 );
                        break;
                    }
                    
                    if( scheduleRecord.SVMXC__Active__c == false ) {
                        
                        response.success = false;
                        response.messageList.add( System.Label.TMST001_TAG040 );
                        break;
                    }
                    
                    TMST_TimesheetEngine timesheetEngine = new TMST_TimesheetEngine();                    
                    
                    timesheetEngine.timeSheetRecordType = scheduleRecord.SVMXC__Schedule_Type__c;
                    timesheetEngine.setProcessIds.add(scheduleRecord.SVMXC__Dispatch_Process__c);
                    timesheetEngine.mapTSProcessScheduler.put(scheduleRecord.SVMXC__Dispatch_Process__c, scheduleRecord);
                    
                    try {
                        
                        System.debug( LoggingLevel.DEBUG, 'executeBatch() : executing timesheet engine batch.' );

                        // Start batch with default batch size. (200)
                        database.executebatch( timesheetEngine, batchSize );                        
                    }
                    catch(Exception ex ) {
                        
                        System.debug( LoggingLevel.ERROR, 'executeBatch() : Failed to execute batch' );
                        
                        response.success = false;
                        response.messageList.add( System.Label.TMST001_TAG037 );
                    }                    
                }
                
                if( response.success ) {
                    response.messageList.add( System.Label.TMST001_TAG036 );
                }
            } else {
                
                System.debug( LoggingLevel.ERROR, 'executeBatch() : No schedule details configured for timesheet. processID=' + processId );
                
                response.success = false;
                response.messageList.add( System.Label.TMST001_TAG038 );
            }
        } else {
            
            System.debug( LoggingLevel.ERROR, 'executeBatch() : Apex Jobs queue is full.' );
            
            response.success = false;
            response.messageList.add( System.Label.TMST001_TAG037 );
        }
        
        System.debug( LoggingLevel.DEBUG, 'executeBatch() - exit');
        
        return response;
    }
    
    /**
     * This private method is used to upsert schedule and profile mapping details for each timesheet 
     * process. The record for schedule will be created for each Timesheet process, if not exists, 
     * even if the schedule details are not configured in request. The timesheet access record will
     * be created only if the profile mapping configuration exists in request.
     *
     * @param idTimesheetProcessMap Id vs timesheet process map after timesheet process upsert.
     * @param scheduleConfigDataInputMap Schedule configuration for each timesheet process from request.
     * @param timesheetAssignedProfilesMap List of assigned configuration profile id's for each 
     * timesheet process from request. 
     * @param recordTypeMap Record type SObjects for records 'Timesheet', 'Timesheet Access', 'Schedule' & 'Configuration Profiles'.
     *
     * @return List<SVMXC__ServiceMax_Config_Data__c> This method returns list of 
     * ServiceMax_Config_Data__c after upsert.
     */
    private List<SVMXC__ServiceMax_Config_Data__c> upsertTimesheetConfigurationData( Map<Id,SVMXC__ServiceMax_Processes__c> idTimesheetProcessMap, Map<String,List<SVMXC__ServiceMax_Config_Data__c>> scheduleConfigDataInputMap, Map<String,List<Id>> timesheetAssignedProfilesMap, Map<String,RecordType> recordTypeMap ) {
    
        System.debug( LoggingLevel.DEBUG, 'upsertTimesheetConfigurationData() - enter' );
        
        /* Populate unique list of profile Id's which is used to query timesheet access records. */
        Set<Id> uniqueProfileIdSet = new Set<Id>();
        for( List<Id> idList : timesheetAssignedProfilesMap.values() ) {        
            uniqueProfileIdSet.addAll( idList );            
        }
        
        List<String> queryFields = new List<String> {'Id', 'SVMXC__RecordType_Name__c', 'SVMXC__Profile_Name__c', 'SVMXC__Dispatch_Process__c', 'SVMXC__Access_Configuration_Profile__c', 'SVMXC__Schedule_Type__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        /*
         * Retrieve all existing schedule detail records from ServiceMax Config Data 
         * and populate dispatch process vs schedule details object map.
         * Dispatch process id is reference to Timesheet process salesforce Id.
         */   
         //SDL-SVMX-READ-FLS-ENFORCED
        List<SVMXC__ServiceMax_Config_Data__c> configurationDataList = [ SELECT Id, SVMXC__RecordType_Name__c, SVMXC__Profile_Name__c, SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__c, SVMXC__Schedule_Type__c FROM SVMXC__ServiceMax_Config_Data__c WHERE ( SVMXC__Dispatch_Process__c IN :idTimesheetProcessMap.keySet() AND SVMXC__RecordType_Name__c =: TMST_Consts.RECORD_TYPE_SCHEDULE ) OR ( SVMXC__RecordType_Name__c =: TMST_Consts.RECORD_TYPE_TIMESHEET_ACCESS AND ( SVMXC__Access_Configuration_Profile__c IN :uniqueProfileIdSet OR SVMXC__Dispatch_Process__c IN :idTimesheetProcessMap.keySet() ) ) OR ( SVMXC__RecordType_Name__c =: TMST_Consts.RECORD_TYPE_CONFIGURATION_PROFILE AND SVMXC__Configuration_Type__c =:TMST_Consts.CONFIGURATION_TYPE_GROUP) ];
        
        // Map to populate existing records from database.    
        Map<String, Map<Id, SVMXC__ServiceMax_Config_Data__c>> timesheetProcessScheduleConfigDataMap =  new Map<String, Map<Id,SVMXC__ServiceMax_Config_Data__c>>();
        Map<Id, SVMXC__ServiceMax_Config_Data__c> profileToTimesheetAccessMap = new Map<Id, SVMXC__ServiceMax_Config_Data__c>();        
        Map<Id, SVMXC__ServiceMax_Config_Data__c> configurationProfileNameMap = new Map<Id, SVMXC__ServiceMax_Config_Data__c>();
        Map<Id, SVMXC__ServiceMax_Config_Data__c> removeConfigDataMap = new Map<Id, SVMXC__ServiceMax_Config_Data__c>();
        
        for( SVMXC__ServiceMax_Config_Data__c configurationData : configurationDataList ) {
        
            if( configurationData.SVMXC__RecordType_Name__c.equalsIgnoreCase( TMST_Consts.RECORD_TYPE_SCHEDULE ) ) {
            
                if( configurationData.SVMXC__Schedule_Type__c != null ) {
                
                    if( ! timesheetProcessScheduleConfigDataMap.containsKey( configurationData.SVMXC__Dispatch_Process__c ) ) {
                        timesheetProcessScheduleConfigDataMap.put( configurationData.SVMXC__Dispatch_Process__c, new Map<Id,SVMXC__ServiceMax_Config_Data__c>() );
                    }
                    
                    /* Populating schedule configuration from ServiceMax_Config_Data__c object. */
                    timesheetProcessScheduleConfigDataMap.get( configurationData.SVMXC__Dispatch_Process__c).put( configurationData.Id, configurationData );
                    removeConfigDataMap.put( configurationData.Id, configurationData );
                }
            } else if( configurationData.SVMXC__RecordType_Name__c.equalsIgnoreCase( TMST_Consts.RECORD_TYPE_TIMESHEET_ACCESS ) ) {
            
                /*
                 * Timesheet access record will become invalid if one of dispatch process or access 
                 * configuration fields has null/empty value. Ignoring such records from database.
                 */
                if( configurationData.SVMXC__Dispatch_Process__c != null && 
                    configurationData.SVMXC__Access_Configuration_Profile__c != null ) {
                    
                    /*
                     * Single profile associated to multiple timesheet processes in single request. 
                     * In this scenario, First profile mapping will be considered.
                     */
                    if( !profileToTimesheetAccessMap.containsKey( configurationData.SVMXC__Access_Configuration_Profile__c ) ) {
                        profileToTimesheetAccessMap.put( configurationData.SVMXC__Access_Configuration_Profile__c, configurationData);
                    } else {
                        System.debug( LoggingLevel.WARN, 'Profile has been associated to multiple Timesheet Process. profileId : ' + configurationData.SVMXC__Access_Configuration_Profile__c );
                    }
                } else {
                    System.debug( LoggingLevel.WARN, 'Invalid Timesheet access record. Id : ' + configurationData.Id );
                } 
                
            } else if( configurationData.SVMXC__RecordType_Name__c.equalsIgnoreCase( TMST_Consts.RECORD_TYPE_CONFIGURATION_PROFILE ) ) {
            
                /* Check for invalid profile record in salesforce database. */
                if( configurationData.SVMXC__Profile_Name__c != null ) {
                    configurationProfileNameMap.put( configurationData.Id, configurationData );
                } else {
                    System.debug( LoggingLevel.WARN, 'Invalid Configuration profile record. Id : ' + configurationData.Id );
                }
            }
        }
        
        RecordType scheduleRecordType = recordTypeMap.get( TMST_Consts.RECORD_TYPE_SCHEDULE );
        RecordType timesheetAccessRecordType = recordTypeMap.get( TMST_Consts.RECORD_TYPE_TIMESHEET_ACCESS );
        
        List<SVMXC__ServiceMax_Config_Data__c> scheduleConfigDataSaveList = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        /* Update schedule and timesheet access records or create one if record not exists. */
        for( SVMXC__ServiceMax_Processes__c timesheetProcess : idTimesheetProcessMap.values() ) {
            
            /* Create configuration data record for schedule if not exists in ServiceMax_Config_Data__c object. */
            if( !timesheetProcessScheduleConfigDataMap.containsKey( timesheetProcess.Id ) ) {
                timesheetProcessScheduleConfigDataMap.put( timesheetProcess.Id, new Map<Id, SVMXC__ServiceMax_Config_Data__c>() );
            }
            
            /* Update fiels values for schedule record with values from request. */
            // TODO set other field values
            
            List<SVMXC__ServiceMax_Config_Data__c> scheduleConfigDataRequestList = scheduleConfigDataInputMap.get( timesheetProcess.SVMXC__ProcessID__c );  
            Map<Id,SVMXC__ServiceMax_Config_Data__c> scheduleConfigDataMap = timesheetProcessScheduleConfigDataMap.get( timesheetProcess.Id );
            
            for( SVMXC__ServiceMax_Config_Data__c scheduleConfigDataRequest : scheduleConfigDataRequestList ) {
                
                SVMXC__ServiceMax_Config_Data__c scheduleConfigData = scheduleConfigDataMap.get( scheduleConfigDataRequest.Id );
                
                if( scheduleConfigData == null ) {
                    scheduleConfigData = new SVMXC__ServiceMax_Config_Data__c( SVMXC__Dispatch_Process__c = timesheetProcess.Id, RecordTypeId = scheduleRecordType.Id );
                }
                
                scheduleConfigData.SVMXC__Schedule_Type__c = scheduleConfigDataRequest.SVMXC__Schedule_Type__c;
                scheduleConfigData.SVMXC__Period__c = scheduleConfigDataRequest.SVMXC__Period__c;
                scheduleConfigData.SVMXC__SM_Prior_Timesheet_Periods__c = scheduleConfigDataRequest.SVMXC__SM_Prior_Timesheet_Periods__c;
                scheduleConfigData.SVMXC__Schedule_Days__c = scheduleConfigDataRequest.SVMXC__Schedule_Days__c;
                scheduleConfigData.SVMXC__Run_At__c = scheduleConfigDataRequest.SVMXC__Run_At__c;
                scheduleConfigData.SVMXC__Active__c = scheduleConfigDataRequest.SVMXC__Active__c;
                scheduleConfigData.SVMXC__Day_to_Run__c = scheduleConfigDataRequest.SVMXC__Day_to_Run__c;
                scheduleConfigData.SVMXC__Run_Type__c = scheduleConfigDataRequest.SVMXC__Run_Type__c;
                scheduleConfigData.SVMXC__Sequence__c = scheduleConfigDataRequest.SVMXC__Sequence__c;
                scheduleConfigData.SVMXC__Period_Start_On__c = scheduleConfigDataRequest.SVMXC__Period_Start_On__c;
                scheduleConfigData.SVMXC__Period_End_On__c = scheduleConfigDataRequest.SVMXC__Period_End_On__c;
                scheduleConfigData.SVMXC__Internal_Value__c = scheduleConfigDataRequest.SVMXC__Internal_Value__c; // Added for BAC-5411
                //scheduleConfigData.SVMXC__Run_Frequency__c = scheduleConfigDataRequest.SVMXC__Run_Frequency__c;
                
                scheduleConfigDataSaveList.add( scheduleConfigData );
                
                if( scheduleConfigData.Id != null ) {
                    removeConfigDataMap.remove( scheduleConfigData.Id );
                }
            }
            
            /* Update timesheet access record or create new record if not exists. */
            if( timesheetAssignedProfilesMap.containsKey( timesheetProcess.SVMXC__ProcessID__c ) ) {
            
                /* Loop through list of assigned profiles for each timesheet process. */
                for( Id profileId : timesheetAssignedProfilesMap.get( timesheetProcess.SVMXC__ProcessID__c ) ) {
                
                    /* Checking whether the assigned profile id exists in global list of configuration profiles. */
                    if( configurationProfileNameMap.containsKey( profileId ) ) {
                    
                        /* Crete new timesheet access record if not exists in ServiceMax_Config_Data__c object. */
                        if( !profileToTimesheetAccessMap.containsKey( profileId ) ) {
                        
                            SVMXC__ServiceMax_Config_Data__c newProfileAccess = new SVMXC__ServiceMax_Config_Data__c();
                            newProfileAccess.RecordTypeId = timesheetAccessRecordType.Id;
                            newProfileAccess.SVMXC__Access_Configuration_Profile__c = profileId;
                            
                            profileToTimesheetAccessMap.put( profileId, newProfileAccess );
                        }
                        
                        /* Map this timesheet process to existion of newly created timesheet access record. */
                        profileToTimesheetAccessMap.get( profileId ).SVMXC__Dispatch_Process__c = timesheetProcess.Id; 
                        if(timesheetConfigProfileswithSFIdMap.containsKey(profileId)){ // Added for BAC-5189
                            profileToTimesheetAccessMap.get( profileId ).SVMXC__SM_Scope__c = timesheetConfigProfileswithSFIdMap.get(profileId);
                        }
                    } else {
                        // TODO error handling
                    }                    
                }
            }
        }
        
        /*
         * Temp list to have all schedule and timesheet access records to be upserted at one go. 
         * Just to reduce number of DML operations
         */
        List<SVMXC__ServiceMax_Config_Data__c> upsertList = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        upsertList.addAll( scheduleConfigDataSaveList );
        upsertList.addAll( profileToTimesheetAccessMap.values() );
        
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( upsertList, COMM_SecurityUtils.Access.Upsertable ) ) {
            
            /* Upsert schedule and profile access records to ServiceMax_Config_Data__c object. */
            //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
            upsert upsertList;
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        queryFields = new List<String> {'Id'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        /*
         * Remove timesheet access records whose configuration profile mapping has been removed from 
         * timesheet process.
         */
         //SDL-SVMX-READ-FLS-ENFORCED
        List<SVMXC__ServiceMax_Config_Data__c> removeConfigDataList = [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c =: TMST_Consts.RECORD_TYPE_TIMESHEET_ACCESS AND SVMXC__Access_Configuration_Profile__c NOT IN :uniqueProfileIdSet AND SVMXC__Dispatch_Process__c IN :idTimesheetProcessMap.keySet() ];
        removeConfigDataList.addAll( removeConfigDataMap.values() );
        
        if( ! removeConfigDataList.isEmpty() ) {
        
            System.debug( LoggingLevel.DEBUG, 'upsertTimesheetConfigurationData() - Deleting profile access records which has no mapping and removed schedulings.' );
            
            if( !COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            //SDL-SVMX-DELETE-FLS-ENFORCED
            delete removeConfigDataList;
        }
        
        System.debug( LoggingLevel.DEBUG, 'upsertTimesheetConfigurationData() - exit' );
        
        return upsertList;
    }
    
    /**
     * This private method is used to upsert Timesheet process record. The record for 
     * Timesheet process will be created, if not exists, Otherwise the Timesheed process 
     * record will be updated with field values specified in request.
     *
     * @param timesheetProcessInputMap Map to timesheet process Id vs timesheet process which 
     * needs to be saved.
     * @param recordTypeMap Record type SObjects for records 'Timesheet', 'Timesheet Access', 
     * 'Schedule' & 'Configuration Profiles'.
     * @param response TMST_WrapperDef.TMST_Response instance to populate response status and messages.
     *
     * @return List<SVMXC__ServiceMax_Processes__c> This method returns upserted list of SVMXC__ServiceMax_Processes__c.
     */
    private List<SVMXC__ServiceMax_Processes__c> upsertTimesheetProcess( Map<String,SVMXC__ServiceMax_Processes__c> timesheetProcessInputMap, Map<String,RecordType> recordTypeMap, TMST_WrapperDef.TMST_Response response ) {
    
        System.debug( LoggingLevel.DEBUG, 'upsertTimesheetProcess() - enter' );
        
        RecordType timesheetRecordType = recordTypeMap.get(TMST_Consts.RECORD_TYPE_TIMESHEET);
        
        List<String> queryFields = new List<String> {'Id', 'LastModifiedDate', 'SVMXC__Name__c', 'SVMXC__ProcessID__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        /* Retrieve all timesheet process records for given process Id's. */   
        //SDL-SVMX-READ-FLS-ENFORCED
        List<SVMXC__ServiceMax_Processes__c> timesheetProcessList = [SELECT Id, LastModifiedDate, SVMXC__Name__c, SVMXC__ProcessID__c FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name =: TMST_Consts.RECORD_TYPE_TIMESHEET AND SVMXC__ProcessID__c IN :timesheetProcessInputMap.keySet()];
        Map<String,SVMXC__ServiceMax_Processes__c> timesheetProcessMap = new Map<String,SVMXC__ServiceMax_Processes__c>();
            
        for( SVMXC__ServiceMax_Processes__c timesheetProcess : timesheetProcessList ) {
            timesheetProcessMap.put( timesheetProcess.SVMXC__ProcessID__c, timesheetProcess );
        }
        
        /* For each timesheet process, update field with values from request or create Timesheet process if not exists. */
        for( SVMXC__ServiceMax_Processes__c timesheetProcessInput : timesheetProcessInputMap.values() ) {
            
            String timesheetProcessId = timesheetProcessInput.SVMXC__ProcessID__c;
                
            if( !timesheetProcessMap.containsKey( timesheetProcessId ) ) {
                timesheetProcessMap.put( timesheetProcessId, new SVMXC__ServiceMax_Processes__c() );
            } 
                                
            SVMXC__ServiceMax_Processes__c timesheetProcess = timesheetProcessMap.get( timesheetProcessId );
            
            /* Updating fields with values from request for each timesheet process. */                
            timesheetProcess.SVMXC__Name__c = timesheetProcessInput.SVMXC__Name__c;
            timesheetProcess.SVMXC__ProcessID__c = timesheetProcessInput.SVMXC__ProcessID__c;
            timesheetProcess.RecordTypeId = timesheetRecordType.Id;
            timesheetProcess.SVMXC__Description__c = timesheetProcessInput.SVMXC__Description__c;
            timesheetProcess.SVMXC__Active__c = timesheetProcessInput.SVMXC__Active__c;
            timesheetProcess.SVMXC__Email_On_Success__c = timesheetProcessInput.SVMXC__Email_On_Success__c;
            timesheetProcess.SVMXC__Email_On_Error__c = timesheetProcessInput.SVMXC__Email_On_Error__c;
            /*
            timesheetProcess.SVMXC__Max_Hours_Per_Period__c = timesheetProcessInput.SVMXC__Max_Hours_Per_Period__c;
            timesheetProcess.SVMXC__Max_Hours_Per_Day__c = timesheetProcessInput.SVMXC__Max_Hours_Per_Day__c;
            timesheetProcess.SVMXC__Min_Hours_Per_Period__c = timesheetProcessInput.SVMXC__Min_Hours_Per_Period__c;
            timesheetProcess.SVMXC__Min_Hours_Per_Day__c = timesheetProcessInput.SVMXC__Min_Hours_Per_Day__c;
            timesheetProcess.SVMXC__Min_Increment__c = timesheetProcessInput.SVMXC__Min_Increment__c;
            */
            timesheetProcess.SVMXC__SM_Business_Hour_Source__c = timesheetProcessInput.SVMXC__SM_Business_Hour_Source__c; //Added for BAC-5388
            timesheetProcess.SVMXC__Notify_technician__c = timesheetProcessInput.SVMXC__Notify_technician__c;            
            timesheetProcess.SVMXC__Start_Date__c = timesheetProcessInput.SVMXC__Start_Date__c;
            timesheetProcess.SVMXC__End_Date__c = timesheetProcessInput.SVMXC__End_Date__c;
            timesheetProcess.SVMXC__Business_Hours__c = timesheetProcessInput.SVMXC__Business_Hours__c;          
            timesheetProcess.SVMXC__Event_Type__c = timesheetProcessInput.SVMXC__Event_Type__c;
            timesheetProcess.SVMXC__Field_Name__c = timesheetProcessInput.SVMXC__Field_Name__c;
            
            timesheetProcess.SVMXC__Process__c = timesheetProcessInput.SVMXC__Process__c;
            timesheetProcess.SVMXC__Process1__c = timesheetProcessInput.SVMXC__Process1__c;
            timesheetProcess.SVMXC__Process2__c = timesheetProcessInput.SVMXC__Process2__c;
            timesheetProcess.SVMXC__Process3__c = timesheetProcessInput.SVMXC__Process3__c;
            timesheetProcess.SVMXC__Parent_Object__c = timesheetProcessInput.SVMXC__Parent_Object__c;
            timesheetProcess.SVMXC__Node_Parent__c = timesheetProcessInput.SVMXC__Node_Parent__c;
            timesheetProcess.SVMXC__Submodule__c = timesheetProcessInput.SVMXC__Submodule__c;
            timesheetProcess.SVMXC__Module__c = timesheetProcessInput.SVMXC__Module__c;
            
            timesheetProcess.SVMXC__Dispatch_Timezone__c = timesheetProcessInput.SVMXC__Dispatch_Timezone__c;
        }
        
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( timesheetProcessMap.values(), COMM_SecurityUtils.Access.Upsertable ) ) {
            
            /* Upsert Timesheet process record to ServiceMax_Processes__c object. */  
            //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
            upsert timesheetProcessMap.values();
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        System.debug( LoggingLevel.DEBUG, 'upsertTimesheetProcess() - exit' );
        
        return timesheetProcessMap.values();
    }
    
    /**
     * This method is used to build record type name vs record type object.
     *
     * @return Map<String,RecordType> RecordType object instances for type 'Timesheet', 'Timesheet Access', 
     * 'Schedule' & 'Configuration Profiles'
     */
    private Map<String,RecordType> buildRecordTypeMap() {
    
        List<String> queryFields = new List<String> {'Id', 'Name'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'RecordType', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        //SDL-SVMX-READ-FLS-ENFORCED
        List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType WHERE (SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND ( Name =: TMST_Consts.RECORD_TYPE_SCHEDULE OR Name =: TMST_Consts.RECORD_TYPE_TIMESHEET_ACCESS ) ) OR ( SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name =: TMST_Consts.RECORD_TYPE_TIMESHEET ) ];
        Map<String,RecordType> recordTypeMap = new Map<String,RecordType>();
            
        for( RecordType type : recordTypeList ) {
            recordTypeMap.put( type.Name, type );
        }
        
        return recordTypeMap;        
    }
    
    /**
     * This method is used to validate timesheet process, schedule and timesheet access records.
     *
     * @param response TMST_WrapperDef.TMST_Response object instance used to update error/warning if any.
     * @param timesheetProcess ServiceMax_Processes__c object instance to be validated for Timesheet.
     * @param scheduleDetailsList ServiceMax_Config_Date__c object instance to be validated for schedule.
     *
     * @return Boolean Returns true of timesheet process and configuration data are successfully 
     * validated, Otherwise returns false. Error/Warning messages will be updated in response object.
     */
    private Boolean validateTimesheetProcess( TMST_WrapperDef.TMST_Response response, 
            SVMXC__ServiceMax_Processes__c timesheetProcess, 
            List<SVMXC__ServiceMax_Config_Data__c> scheduleDetailsList ) {
    
        System.debug( LoggingLevel.DEBUG, 'validateTimesheetProcess() - enter; Timesheet Process: ' + timesheetProcess );
        
        Boolean isValid = true;
        
        /* Validating Timesheet process name.*/
        if( !isValidateFieldValue( timesheetProcess.SVMXC__Name__c ) ) {
        
            isValid = false;
            response.messageList.add( System.label.TMST001_TAG009 + System.label.TMST002_TAG005 );
        } else if( timesheetProcess.SVMXC__Name__c.length() < TMST_Consts.MIN_TEXT_LENGTH || timesheetProcess.SVMXC__Name__c.length() > TMST_Consts.MAX_TEXT_LENGTH ) {
            
            isValid = false;
            response.messageList.add( System.label.TMST001_TAG010 );
        }
        
        // TODO : Remove this condition if description is not mandatory.
        /* Validating Timesheet process description. */
        if( !isValidateFieldValue( timesheetProcess.SVMXC__Description__c ) ) {
        
            isValid = false;
            response.messageList.add( System.label.TMST001_TAG009 + System.label.TMST002_TAG018 );
        } else if ( timesheetProcess.SVMXC__Description__c.length() > TMST_Consts.MAX_LONG_TEXT_LENGTH ) {
            
            isValid = false;
            response.messageList.add( System.label.TMST001_TAG011 );
        }
        
        /* Validate process Id */
        if( !isValidateFieldValue( timesheetProcess.SVMXC__ProcessID__c ) ) {
        
            isValid = false;
            response.messageList.add( System.label.TMST001_TAG009 + System.label.TMST001_TAG031 + timesheetProcess.SVMXC__ProcessID__c );
        }
        
         /* Validating success/error email format.*/
        if( isValidateFieldValue( timesheetProcess.SVMXC__Email_On_Success__c ) && !validateEmailAddress( timesheetProcess.SVMXC__Email_On_Success__c ) ) {
            
            isValid = false;
            response.messageList.add( System.label.TMST001_TAG009 + System.label.TMST002_TAG038 );
        }
                
        if( isValidateFieldValue( timesheetProcess.SVMXC__Email_On_Error__c ) && !validateEmailAddress( timesheetProcess.SVMXC__Email_On_Error__c ) ) {
            
            isValid = false;
            response.messageList.add( System.label.TMST001_TAG009 + System.label.TMST002_TAG039 );
        }
        
        /* To activate configured Timesheet process, Timesheet must be configured with 
         * schedule details and atleast one profile.
         */
        if( timesheetProcess.SVMXC__Active__c != null && timesheetProcess.SVMXC__Active__c ) {
            
            if( !isValidateFieldValue( timesheetProcess.SVMXC__Dispatch_Timezone__c ) ) {
                
                isValid = false;
                response.messageList.add( System.label.TMST001_TAG009 + System.label.TMST002_TAG030 );
            }
            
            if( scheduleDetailsList != null ) {
                
                if( timesheetProcess.SVMXC__Start_Date__c == null || timesheetProcess.SVMXC__End_Date__c == null ) {
                    isValid = false;
                    response.messageList.add( System.label.TMST001_TAG009 + System.label.TMST002_TAG035 + '/' + System.label.TMST002_TAG036 );
                }
                
                if( !beforeActiveValidation( response, timesheetProcess, scheduleDetailsList ) ) {
                    isValid = false;
                }                               
            } else {
                isValid = false;
                response.messageList.add( System.label.TMST001_TAG008 + timesheetProcess.SVMXC__Name__c );
            }
        }
                
        if( timesheetProcess.SVMXC__Start_Date__c != null && 
            timesheetProcess.SVMXC__End_Date__c != null && 
            timesheetProcess.SVMXC__Start_Date__c > timesheetProcess.SVMXC__End_Date__c ) {
                       
             isValid = false;
             response.messageList.add( System.label.TMST001_TAG012 );
        }
                
        if( !validateScheduleData( response, scheduleDetailsList ) ) {
            isValid = false;
        }
        
        System.debug( LoggingLevel.DEBUG, 'validateTimesheetProcess() - exit' );
        
        return isValid;
    }
    
    /**
     * This method is used to validate schedule field data.
     *
     * @param response TMST_WrapperDef.TMST_Response object instance used to update error/warning if any.     
     * @param scheduleDetailsList ServiceMax_Config_Date__c object instance to be validated for schedule.
     *
     * @return Boolean Returns true if configuration data are successfully validated, Otherwise returns false. 
     * Error/Warning messages will be updated in response object.
     */
    private Boolean validateScheduleData( TMST_WrapperDef.TMST_Response response, List<SVMXC__ServiceMax_Config_Data__c> scheduleDetailsList ) {
        
        System.debug( LoggingLevel.DEBUG, 'validateScheduleData() - enter' );
        
        Boolean isValid = true;
        
        if( scheduleDetailsList != null ) {
                    
            for( SVMXC__ServiceMax_Config_Data__c scheduleDetails: scheduleDetailsList ) {
                        
                if( ! isValidateFieldValue( scheduleDetails.SVMXC__Schedule_Type__c ) ||
                    (! scheduleDetails.SVMXC__Schedule_Type__c.equalsIgnoreCase( TMST_Consts.SCHEDULE_TYPE_TIMESHEET_AUTOFILL ) &&
                     ! scheduleDetails.SVMXC__Schedule_Type__c.equalsIgnoreCase( TMST_Consts.SCHEDULE_TYPE_TIMESHEET_HEADER ) ) ) {
                            
                    isValid = false;
                    response.messageList.add( System.label.TMST001_TAG009 + '[SVMXC__Schedule_Type__c]: ' + scheduleDetails.SVMXC__Schedule_Type__c );
                }
                
                if( isValidateFieldValue( scheduleDetails.SVMXC__Run_Type__c ) ) {
                    if( !scheduleDetails.SVMXC__Run_Type__c.equalsIgnoreCase( TMST_Consts.RUN_TYPE_DAY_OF_WEEK ) && !scheduleDetails.SVMXC__Run_Type__c.equalsIgnoreCase( TMST_Consts.RUN_TYPE_DATE_OF_MONTH ) ) {
                        isValid = false;
                        response.messageList.add( System.label.TMST001_TAG009 + '[SVMXC__Run_Type__c]: ' + scheduleDetails.SVMXC__Run_Type__c );
                    }
                }
                
                if( isValidateFieldValue( scheduleDetails.SVMXC__Schedule_Days__c ) ) {
                    
                    String[] scheduleDaysArray = scheduleDetails.SVMXC__Schedule_Days__c.split( TMST_Consts.SEMICOLON );
                    for( String scheduleDays: scheduleDaysArray ) {
                        
                        if( ! TMST_Consts.WEEK_STRING_TO_ID_MAP.containsKey( scheduleDays ) ) {
                    
                            isValid = false;
                            response.messageList.add( System.label.TMST001_TAG009 + System.label.TMST002_TAG023 );
                        }
                    }
                }
                
                if( isValidateFieldValue( scheduleDetails.SVMXC__Day_to_Run__c ) ) {
                    
                    Integer value = getIntValue( scheduleDetails.SVMXC__Day_to_Run__c );
                    if( value < TMST_Consts.MIN_DATE_VALUE || value > TMST_Consts.MAX_DATE_VALUE ) {
                        
                        isValid = false;
                        response.messageList.add( System.label.TMST001_TAG009 + System.label.TMST002_TAG025 );
                    }
                }
                
                if( isValidateFieldValue( scheduleDetails.SVMXC__Run_At__c ) &&
                    ! TMST_Consts.TIMEAT_STRING_TO_ID_MAP.containsKey( scheduleDetails.SVMXC__Run_At__c ) ) {
                                
                    isValid = false;
                    response.messageList.add( System.label.TMST001_TAG009 + System.label.TMST002_TAG029 );
                }
                
                if( isValidateFieldValue( scheduleDetails.SVMXC__Period__c ) && 
                    ! TMST_Consts.PERIOD_RUN_TYPE_MAP.containsKey( scheduleDetails.SVMXC__Period__c ) ) {
                        
                        isValid = false;
                        response.messageList.add( System.label.TMST001_TAG009 + System.label.TMST002_TAG021 );
                }
                
                if( isValidateFieldValue( scheduleDetails.SVMXC__Period_Start_On__c ) &&
                    ( scheduleDetails.SVMXC__Period_Start_On__c < 0 || scheduleDetails.SVMXC__Period_Start_On__c > TMST_Consts.MAX_INTEGER_VALUE ) ) {
                        
                    isValid = false;
                    response.messageList.add( System.label.TMST001_TAG009 + System.label.TMST002_TAG035 );
                }

                if( isValidateFieldValue( scheduleDetails.SVMXC__Period__c ) &&
                    scheduleDetails.SVMXC__Period__c.equalsIgnoreCase( TMST_Consts.PERIOD_WEEKLY ) &&
                    isValidateFieldValue( scheduleDetails.SVMXC__Period_End_On__c ) &&
                    ( scheduleDetails.SVMXC__Period_End_On__c < 0  || scheduleDetails.SVMXC__Period_End_On__c > TMST_Consts.MAX_INTEGER_VALUE ) ) {
                        
                    isValid = false;
                    response.messageList.add( System.label.TMST001_TAG009 + System.label.TMST002_TAG036 );
                }   
                
                if( isValidateFieldValue( scheduleDetails.SVMXC__Period__c ) &&
                    scheduleDetails.SVMXC__Period__c.equalsIgnoreCase( TMST_Consts.PERIOD_WEEKLY ) && 
                     isValidateFieldValue( scheduleDetails.SVMXC__Period_Start_On__c ) &&
                    isValidateFieldValue( scheduleDetails.SVMXC__Period_End_On__c ) ) {
                        
                        if( scheduleDetails.SVMXC__Period_Start_On__c > scheduleDetails.SVMXC__Period_End_On__c ) {
                            
                            isValid = false;
                            response.messageList.add( System.label.TMST001_TAG013 );
                        }
                }
                
                /*
                if( isValidateFieldValue( scheduleDetails.SVMXC__Period__c ) && 
                    TMST_Consts.PERIOD_RUN_TYPE_MAP.containsKey( scheduleDetails.SVMXC__Period__c ) &&
                    isValidateFieldValue( scheduleDetails.SVMXC__Run_Frequency__c ) ) {
                        
                        if( scheduleDetails.SVMXC__Period__c.equalsIgnoreCase(TMST_Consts.PERIOD_DAILY) &&
                            ( scheduleDetails.SVMXC__Run_Frequency__c < TMST_Consts.MIN_RUN_EVERY_DAY_VALUE || 
                              scheduleDetails.SVMXC__Run_Frequency__c > TMST_Consts.MAX_RUN_EVERY_DAY_VALUE ) ) {
                            
                            isValid = false;
                            response.messageList.add( System.label.TMST001_TAG009 + '[SVMXC__Run_Frequency__c]: ' + scheduleDetails.SVMXC__Run_Frequency__c );
                        }
                        
                        if( scheduleDetails.SVMXC__Period__c.equalsIgnoreCase( TMST_Consts.PERIOD_WEEKLY ) &&
                            ( scheduleDetails.SVMXC__Run_Frequency__c < TMST_Consts.MIN_RUN_EVERY_WEEKLY_VALUE || 
                              scheduleDetails.SVMXC__Run_Frequency__c > TMST_Consts.MAX_RUN_EVERY_WEEKLY_VALUE ) ) {
                            
                            isValid = false;
                            response.messageList.add( System.label.TMST001_TAG009 + '[SVMXC__Run_Frequency__c]: ' + scheduleDetails.SVMXC__Run_Frequency__c );
                        }
                        
                        if( scheduleDetails.SVMXC__Period__c.equalsIgnoreCase( TMST_Consts.PERIOD_MONTHLY ) &&
                            ( scheduleDetails.SVMXC__Run_Frequency__c < TMST_Consts.MIN_RUN_EVERY_MONTH_VALUE || 
                              scheduleDetails.SVMXC__Run_Frequency__c > TMST_Consts.MAX_RUN_EVERY_MONTH_VALUE ) ) {
                            
                            isValid = false;
                            response.messageList.add( System.label.TMST001_TAG009 + '[SVMXC__Run_Frequency__c]: ' + scheduleDetails.SVMXC__Run_Frequency__c );
                        }
                }
*/
            }
        }
        
        System.debug( LoggingLevel.DEBUG, 'validateScheduleData() - exit' );
        
        return isValid;
    }
    
    /**
     * This method is used to validate active timesheet process, schedule and timesheet access records.
     *
     * @param response TMST_WrapperDef.TMST_Response object instance used to update error/warning if any.
     * @param timesheetProcess ServiceMax_Processes__c object instance to be validated for Timesheet.     
     * @param scheduleDetailsList ServiceMax_Config_Date__c object instance to be validated for schedule.
     *
     * @return Boolean Returns true if timesheet process and configuration data are successfully 
     * validated, Otherwise returns false. Error/Warning messages will be updated in response object.
     */
    private Boolean beforeActiveValidation( TMST_WrapperDef.TMST_Response response, SVMXC__ServiceMax_Processes__c timesheetProcess, List<SVMXC__ServiceMax_Config_Data__c> scheduleDetailsList ) {
        
        System.debug( LoggingLevel.DEBUG, 'beforeActiveValidation() - enter' );
        
        Boolean isValid = true;
        
        for( SVMXC__ServiceMax_Config_Data__c scheduleDetails: scheduleDetailsList ) {
            
            /* If active value is false then skip the validation */
            if( scheduleDetails.SVMXC__Active__c != null && !scheduleDetails.SVMXC__Active__c ) {
                continue;
            }
            
            if( isValidateFieldValue( scheduleDetails.SVMXC__Schedule_Type__c ) ) {
                /* Atleast one expression or mapping must be configured for autofill. */
                if( scheduleDetails.SVMXC__Schedule_Type__c.equalsIgnoreCase( TMST_Consts.SCHEDULE_TYPE_TIMESHEET_AUTOFILL ) ) {
                    
                    if( timesheetProcess.SVMXC__Process__c == null && timesheetProcess.SVMXC__Process1__c == null &&
                       timesheetProcess.SVMXC__Process2__c == null && timesheetProcess.SVMXC__Process3__c == null &&
                       timesheetProcess.SVMXC__Parent_Object__c == null && timesheetProcess.SVMXC__Node_Parent__c == null &&
                       timesheetProcess.SVMXC__Submodule__c == null && timesheetProcess.SVMXC__Module__c == null ) {
                           
                           isValid = false;
                           response.messageList.add( System.label.TMST001_TAG014 ); 
                       }
                    
                    if( ( isValidateFieldValue( timesheetProcess.SVMXC__Process__c ) && !isValidateFieldValue( timesheetProcess.SVMXC__Process1__c ) ) ||
                       ( !isValidateFieldValue( timesheetProcess.SVMXC__Process__c ) && isValidateFieldValue( timesheetProcess.SVMXC__Process1__c ) )) {
                           
                           isValid = false;                                  
                           response.messageList.add( System.label.TMST001_TAG027 );
                       }
                    
                    if( isValidateFieldValue( timesheetProcess.SVMXC__Event_Type__c ) ) {
                        
                        if( !timesheetProcess.SVMXC__Event_Type__c.equalsIgnoreCase( TMST_Consts.EVENT_TYPE_BOTH ) ) {
                            
                            if( ( isValidateFieldValue( timesheetProcess.SVMXC__Parent_Object__c ) && !isValidateFieldValue( timesheetProcess.SVMXC__Process3__c ) ) ||
                               ( !isValidateFieldValue( timesheetProcess.SVMXC__Parent_Object__c ) && isValidateFieldValue( timesheetProcess.SVMXC__Process3__c ) )) {
                                   
                                   isValid = false;                                  
                                   response.messageList.add( System.label.TMST001_TAG028 );
                               }
                            
                            if( ( isValidateFieldValue( timesheetProcess.SVMXC__Submodule__c ) && !isValidateFieldValue( timesheetProcess.SVMXC__Module__c ) ) ||
                               ( !isValidateFieldValue( timesheetProcess.SVMXC__Submodule__c ) && isValidateFieldValue( timesheetProcess.SVMXC__Module__c ) )) {
                                   
                                   isValid = false;                                  
                                   response.messageList.add( System.label.TMST001_TAG029 );
                               }    
                        } else if( timesheetProcess.SVMXC__Event_Type__c.equalsIgnoreCase( TMST_Consts.EVENT_TYPE_BOTH ) ) {
                            
                            if( !isValidateFieldValue( timesheetProcess.SVMXC__Parent_Object__c ) || !isValidateFieldValue( timesheetProcess.SVMXC__Process3__c ) ) {
                                
                                isValid = false;                                  
                                response.messageList.add( System.label.TMST001_TAG028 );
                            }
                            
                            if( !isValidateFieldValue( timesheetProcess.SVMXC__Submodule__c ) || !isValidateFieldValue( timesheetProcess.SVMXC__Module__c ) ) {
                                
                                isValid = false;                                  
                                response.messageList.add( System.label.TMST001_TAG029 );
                            }
                        }   
                    }                    
                    
                    if( ( isValidateFieldValue( timesheetProcess.SVMXC__Node_Parent__c ) && !isValidateFieldValue( timesheetProcess.SVMXC__Process2__c ) ) ||
                       ( !isValidateFieldValue( timesheetProcess.SVMXC__Node_Parent__c ) && isValidateFieldValue( timesheetProcess.SVMXC__Process2__c ) )) {
                           
                           isValid = false;                                  
                           response.messageList.add( System.label.TMST001_TAG030 );
                       }
                }
            }
                    
            if( isValidateFieldValue( scheduleDetails.SVMXC__Period__c ) && TMST_Consts.PERIOD_RUN_TYPE_MAP.containsKey( scheduleDetails.SVMXC__Period__c ) ) {
                
                if( isValidateFieldValue( scheduleDetails.SVMXC__Run_Type__c ) ) {
                    
                    if( scheduleDetails.SVMXC__Period__c.equalsIgnoreCase( TMST_Consts.PERIOD_DAILY ) ||
                        scheduleDetails.SVMXC__Period__c.equalsIgnoreCase( TMST_Consts.PERIOD_WEEKLY ) ) {
                            
                            if( !scheduleDetails.SVMXC__Run_Type__c.equalsIgnoreCase( TMST_Consts.RUN_TYPE_DAY_OF_WEEK ) ) {
                                
                                isValid = false;
                                response.messageList.add( System.label.TMST001_TAG009 + '[SVMXC__Run_Type__c]: ' + scheduleDetails.SVMXC__Run_Type__c );
                            }
                    }
                    
                    if( scheduleDetails.SVMXC__Period__c.equalsIgnoreCase( TMST_Consts.PERIOD_MONTHLY ) ||
                        scheduleDetails.SVMXC__Period__c.equalsIgnoreCase( TMST_Consts.PERIOD_BI_MONTHLY ) ) {
                            
                            if( !scheduleDetails.SVMXC__Run_Type__c.equalsIgnoreCase( TMST_Consts.RUN_TYPE_DATE_OF_MONTH ) ) {
                                
                                isValid = false;
                                response.messageList.add( System.label.TMST001_TAG009 + '[SVMXC__Run_Type__c]: ' + scheduleDetails.SVMXC__Run_Type__c );
                            }
                    }
                } else {
                    isValid = false;
                    response.messageList.add( System.label.TMST001_TAG009 + '[SVMXC__Run_Type__c]: ' + scheduleDetails.SVMXC__Run_Type__c );
                }
                
                if( scheduleDetails.SVMXC__Period__c.equalsIgnoreCase( TMST_Consts.PERIOD_DAILY ) ) {
                    
                    if( isValidateFieldValue( scheduleDetails.SVMXC__Schedule_Type__c ) ) {
                        
                        /* Period Daily is only supported in Autofill schedule. */
                        if( scheduleDetails.SVMXC__Schedule_Type__c.equalsIgnoreCase( TMST_Consts.SCHEDULE_TYPE_TIMESHEET_HEADER ) ) {
                            
                            isValid = false;
                            response.messageList.add( System.label.TMST001_TAG009 + System.label.TMST002_TAG021 );
                        }
                    } else {
                        isValid = false;
                        response.messageList.add( System.label.TMST001_TAG009 + '[SVMXC__Schedule_Type__c]: ' + scheduleDetails.SVMXC__Schedule_Type__c );
                    }
                    
                    /* If schedule period is Weekly then schedule days field must be populated.*/
                    if( !isValidateFieldValue( scheduleDetails.SVMXC__Schedule_Days__c ) ) {
                        
                        isValid = false;
                        response.messageList.add( System.label.TMST001_TAG009 + System.label.TMST002_TAG023 );
                    }
                    
                    /* If schedule period is monthly then day to run field must be populated.*/
                    /*if( !isValidateFieldValue( scheduleDetails.SVMXC__Run_Frequency__c ) ) {
                        
                        isValid = false;
                        response.messageList.add( System.label.TMST001_TAG009 + '[SVMXC__Run_Frequency__c]: ' + scheduleDetails.SVMXC__Run_Frequency__c );
                    } */                         
                } else if( scheduleDetails.SVMXC__Period__c.equalsIgnoreCase( TMST_Consts.PERIOD_WEEKLY ) ) {
                    
                    /* If schedule period is Weekly then schedule days field must be populated.*/
                    if( !isValidateFieldValue( scheduleDetails.SVMXC__Schedule_Days__c ) ) {
                        
                        isValid = false;
                        response.messageList.add( System.label.TMST001_TAG009 + System.label.TMST002_TAG023 );
                    }
                    
                    // TODO Run Every field validation.
                } else if( scheduleDetails.SVMXC__Period__c.equalsIgnoreCase( TMST_Consts.PERIOD_MONTHLY ) ) {
                    
                    /* If schedule period is monthly then day to run field must be populated.*/
                    if( !isValidateFieldValue( scheduleDetails.SVMXC__Day_to_Run__c ) ) {
                        
                        isValid = false;
                        response.messageList.add( System.label.TMST001_TAG009 + System.label.TMST002_TAG025 );
                    }
                } else if( scheduleDetails.SVMXC__Period__c.equalsIgnoreCase( TMST_Consts.PERIOD_BI_MONTHLY ) ) {
                    
                    /* If schedule period is monthly then day to run field must be populated.*/
                    if( !isValidateFieldValue( scheduleDetails.SVMXC__Day_to_Run__c ) ) {
                        
                        isValid = false;
                        response.messageList.add( System.label.TMST001_TAG009 + System.label.TMST002_TAG025 );
                    }
                } 
            } else {
                    
                isValid = false;
                response.messageList.add( System.label.TMST001_TAG009 + System.label.TMST002_TAG021 );
            }
            
            /* Validating Timesheet schedule run at. */
            if( !isValidateFieldValue( scheduleDetails.SVMXC__Run_At__c ) ) {
                
                isValid = false;
                response.messageList.add( System.label.TMST001_TAG009 + System.label.TMST002_TAG029 );
            }
        }
        
        System.debug( LoggingLevel.DEBUG, 'beforeActiveValidation() - exit' );
        
        return isValid;
    }
    
    /**
     * This private method is used to validate field value.
     *
     * @param value String value to be validated.
     * @return Returns true if value is not null and not empty, Otherwise, returns false.
     */
    private Boolean isValidateFieldValue( String value ) {
        return ( value != null && value.trim().length() > 0 );
    }
    
    /**
     * This private method is used to validate field value.
     *
     * @param value Decimal value to be validated.
     * @return Returns true if value is not null, Otherwise, returns false.
     */
    private Boolean isValidateFieldValue( Decimal value ) {
        return ( value != null );
    }
    
    /**
     * This private method is used to Convert String value to Integer.
     *
     * @param value String value to be converted to Integer.
     * @return Returns converted Integer value on success, Otherwise, returns -1.
     */
    private Integer getIntValue( String value ) {
        
        Integer retValue = -1;
        try {
            retValue = Integer.valueOf( value );            
        }        
        catch( Exception ex ) {
            retValue = -1;
        }
        
        return retValue;
    }
    
    /**
     * This method is used to validate email address format.
     * 
     * @param email Email address to be validated.
     * @return Returns true if valid email address, Otherwise, returns false.
     */
    private Boolean validateEmailAddress( String email ) {
        
        Boolean isValid = true;
        
        try {
            isValid = Pattern.matches( EMAIL_REGULAR_EXPRESSION, email );
        }
        
        catch( Exception ex ) {                
            System.debug(LoggingLevel.ERROR, 'Exception validating email address. Error: ' + ex.getMessage() );
            isValid = false;
        }
        
        return isValid;
    }
}