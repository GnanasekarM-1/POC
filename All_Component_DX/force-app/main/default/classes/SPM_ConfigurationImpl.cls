/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The SPM_ConfigurationImpl implements methods to perform Save, Update and 
 * retrieve operations on SPM configurations. This class also has implementation
 * to save/update schedules.
 *
 * @author Ramachandra Mohan
 * @version 15.59100
 * @since 2015
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan      08 Oct 2015     Created.
 *              Ramachandra Mohan      31 Mar 2016     Security fixes.
 *              Soumyaranjan Pati      25th Oct 2017   MTBF Related Code Added
 * BAC-4050     Soumyaranjan Pati      27th June 2018  Security fixes.
 *              Soumyaranjan Pati       21st Dec 2018   Support Salesforce file BAC-4043
 *****************************************************************************************************/

public with sharing class SPM_ConfigurationImpl {
    
    /**
     * Class constructor to create instance of this class.
     */
    public SPM_ConfigurationImpl() {
    }
    /**
     * Map to hold Report Process Id and corresponding Custom label text for handling translation
     */
    private Map<String, String> processIdVsReportNameMap = new Map<String, String>
    {
        'FirstTimeFix'          =>  System.Label.SPM002_TAG066,
        'MeanTimeToRepair'      =>  System.Label.SPM002_TAG067,
        'UpDownTime'            =>  System.Label.SPM002_TAG068,
        'ContractPenetration'   =>  System.Label.SPM002_TAG069,
        'MeanTimeToComplete'    =>  System.Label.SPM002_TAG070,
        'AverageResponseTime'   =>  System.Label.SPM002_TAG071,
        'Utilization'           =>  System.Label.SPM002_TAG072,
        'RepeatVisit'           =>  System.Label.SPM002_TAG073,
        'AccountSummary'        =>  System.Label.SPM002_TAG074,
        'MeanTimeBetweenFailure' => System.Label.SPM002_TAG079 //For MTBF Changes
    };
    
    /**
     * This method is used to retrieve saved SPM configuration for specified reports. This method
     * also retrieves schedule informations for each SPM processes.
     * 
     * @param request SPM_WrapperDef.SPM_Request class instance with list of processId's to be retrieved.
     * @return SPM_WrapperDef.SPM_Response class instance with request status and success/error message's.
     * 
     * @exception QueryException if failed to query configuration details.
     * @exception Exception any other exceptions
     */
    public SPM_WrapperDef.SPM_Response getSPMConfiguration( SPM_WrapperDef.SPM_Request request ) {
        
        System.debug( LoggingLevel.DEBUG, 'getSPMConfiguration() - enter; request: ' + request );
        
        SPM_WrapperDef.SPM_Response response = new SPM_WrapperDef.SPM_Response();
        response.success = true;
        
        // Request validation.
        if( request == null || request.spmProcessDetailsList == null || request.spmProcessDetailsList.isEmpty() ) {
            
            response.success = false;
            response.messageList.add( System.Label.SPM001_TAG004 );
            
            return response;
        }
        
        // Get all requested process Id's.
        Set<String> processIdSet = new Set<String>();        
        for( SPM_WrapperDef.SPM_ProcessDetails spmProcessDetails : request.spmProcessDetailsList ) {
            // Populate all valid SPM process Id's.
            if( spmProcessDetails != null && spmProcessDetails.processId != null ) {                
                processIdSet.add( spmProcessDetails.processId );
            } else {
                // Not success=false, Process all valid id's.
                response.warning = true;
                response.messageList.add( System.Label.SPM001_TAG004 );
                
                System.debug( LoggingLevel.ERROR, 'Invalid SPM process details in request.');
            }
        }
        
        // Process only if atleast one valid process Id exists in request.
        if( processIdSet.isEmpty() ) {
            
            response.success = false;
            response.messageList.add( System.Label.SPM001_TAG004 );
            
            return response;
        }
        
        try {
            
            List<String> queryFields = new List<String> {'Id', 'SVMXC__ProcessID__c', 'SVMXC__Name__c', 'SVMXC__Dispatch_Timezone__c', 'SVMXC__Email_On_Success__c', 'SVMXC__Email_On_Error__c', 'SVMXC__Active__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            // Retrieve requested SPM process informations.
            Map<Id,SVMXC__ServiceMax_Processes__c> spmProcessMap = new Map<Id,SVMXC__ServiceMax_Processes__c>();
            spmProcessMap.putAll( [SELECT Id, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Dispatch_Timezone__c, SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c, SVMXC__Active__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__ProcessID__c IN :processIdSet ] );
            
            // Validating servicemax process records with reqiested process id's exists or not.
            if( spmProcessMap.isEmpty() ) {
                
                response.success = false;
                response.messageList.add( System.Label.SPM001_TAG008 + processIdSet );
                
                return response;
            }
            
            queryFields = new List<String> {'Id', 'Name', 'LastModifiedDate', 'SVMXC__RecordType_Name__c', 'SVMXC__Dispatch_Process__c', 'SVMXC__Formula__c', 'SVMXC__Period__c', 'SVMXC__Schedule_Days__c', 'SVMXC__Run_At__c', 'SVMXC__Day_to_Run__c', 'SVMXC__Active__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            // Retrieve all configuration data for requested process Id's.
            List<SVMXC__ServiceMax_Config_Data__c> configDataList = [ SELECT Id, Name, LastModifiedDate, SVMXC__RecordType_Name__c, SVMXC__Dispatch_Process__c, SVMXC__Formula__c, SVMXC__Period__c, SVMXC__Schedule_Days__c, SVMXC__Run_At__c, SVMXC__Day_to_Run__c, SVMXC__Active__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Dispatch_Process__c != null AND SVMXC__Dispatch_Process__r.SVMXC__ProcessID__c IN :processIdSet AND (RecordType.Name = 'SPM Details' OR RecordType.Name = 'Schedule' ) ];
            
            // Return response with proper error message if no configuration data 
            // exists for requested process Id's.
            if( !configDataList.isEmpty() ) {
                
                // Populate SPM report process Id vs list of configuration data map.
                Map<Id,List<SVMXC__ServiceMax_Config_Data__c>> responseConfigurationMap = new Map<Id,List<SVMXC__ServiceMax_Config_Data__c>>(); 
                for( SVMXC__ServiceMax_Config_Data__c configData : configDataList ) {
                    
                    // Create list of configuration data if not exists.
                    if( !responseConfigurationMap.containsKey(configData.SVMXC__Dispatch_Process__c) ) {
                        responseConfigurationMap.put( configData.SVMXC__Dispatch_Process__c, new List<SVMXC__ServiceMax_Config_Data__c>() );
                    }
                    responseConfigurationMap.get(configData.SVMXC__Dispatch_Process__c).add( configData );
                }
                
                // For each SPM process, create SPM_WrapperDef.SPM_ProcessDetails object instance 
                // and update configuration data list. Add created process details to response object.
                for( Id recordId : responseConfigurationMap.keySet() ) {
                    
                    SPM_WrapperDef.SPM_ProcessDetails processDetails = new SPM_WrapperDef.SPM_ProcessDetails();            
                    processDetails.spmDetailsList = responseConfigurationMap.get( recordId );
                    
                    SVMXC__ServiceMax_Processes__c process = spmProcessMap.get( recordId );
                    queryFields = new List<String> {'Id'};
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( 'Dashboard', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                        
                        String title = '%' + process.SVMXC__Name__c + '%';
                        List<Dashboard> dashboardList = [SELECT Id FROM Dashboard WHERE Folder.Name = 'SPM Dashboard' AND Title LIKE :title];
                        if( !dashboardList.isEmpty() ) {
                            processDetails.dashboardId = dashboardList[0].Id;
                        }
                    }
                                        
                    processDetails.processId = process.SVMXC__ProcessID__c;
                    processDetails.timezone = process.SVMXC__Dispatch_Timezone__c;
                    processDetails.emailOnSuccess = process.SVMXC__Email_On_Success__c;
                    processDetails.emailOnFailure = process.SVMXC__Email_On_Error__c;
                    processDetails.isActive = process.SVMXC__Active__c;
                    
                    response.spmProcessDetailsList.add( processDetails );
                }                
            } else {
                // Updating warning message if calculation methods are not configured for requested process.
                response.warning = true;
                response.messageList.add( System.Label.SPM001_TAG006 + processIdSet );
                System.debug( LoggingLevel.WARN, 'No calculation methods configured for process: ' + processIdSet );
            }
        }
        
        catch( QueryException ex ) {
            
            response.success = false;
            response.messageList.add( System.Label.SPM001_TAG009 );
            
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
        }
        
        catch( Exception ex ) {
            
            response.success = false;
            response.messageList.add( System.Label.SPM001_TAG015 );
            
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getSPMConfiguration() - exit' );    
        }        
        
        return response;
    }
    
    /**
     * This method is used to retrieve all schedule informations for SPM processes.
     * 
     * @return Returns SPM_WrapperDef.SPM_Response instance with configured schedule 
     * information for all the SPM processes.
     * 
     * @exception QueryException if failed to query schedule informations.
     * @exception Exception any other exceptions.
     */
    public SPM_WrapperDef.SPM_Response getAllScheduleConfiguration() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllScheduleConfiguration() - enter' );
        
        SPM_WrapperDef.SPM_Response response = new SPM_WrapperDef.SPM_Response();
        response.success = true;
        
        try {
            
            List<String> queryFields = new List<String> {'Id', 'SVMXC__ProcessId__c', 'SVMXC__Name__c', 'SVMXC__Dispatch_Timezone__c', 'SVMXC__Email_On_Success__c', 'SVMXC__Email_On_Error__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            List<SVMXC__ServiceMax_Processes__c> processList = [ SELECT Id, SVMXC__ProcessId__c, SVMXC__Name__c, SVMXC__Dispatch_Timezone__c, SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name = 'SPM Rule' ORDER BY SVMXC__Sequence__c ];
            
            if( processList.isEmpty() ) {
                
                System.debug( LoggingLevel.ERROR, 'SPM processes not exists in this org. Please install the required seed and try again.' );
                
                response.success = false;
                response.messageList.add( System.Label.SPM001_TAG016 );
                return response;
            }
            
            queryFields = new List<String> {'Id', 'LastModifiedDate', 'SVMXC__Dispatch_Process__c', 'SVMXC__Period__c', 'SVMXC__Schedule_Days__c', 'SVMXC__Run_At__c', 'SVMXC__Day_to_Run__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            // Retrieve all configuration data for requested process Id's.
            List<SVMXC__ServiceMax_Config_Data__c> configDataList = [ SELECT Id, LastModifiedDate, SVMXC__Dispatch_Process__c, SVMXC__Period__c, SVMXC__Schedule_Days__c, SVMXC__Run_At__c, SVMXC__Day_to_Run__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Dispatch_Process__c IN :processList AND RecordType.Name = 'Schedule' ];
            
            if( !configDataList.isEmpty() ) {
                
                // Populate dispatch process vs config data map.
                Map<Id,SVMXC__ServiceMax_Config_Data__c> processConfigDataMap = new Map<Id,SVMXC__ServiceMax_Config_Data__c>();
                for( SVMXC__ServiceMax_Config_Data__c configData : configDataList ) {
                    processConfigDataMap.put( configData.SVMXC__Dispatch_Process__c, configData);
                }
                
                // For each process, retrieve timezone, email on success, email on failure informations 
                // from process and all other details like period, time at etc from config data.
                for( SVMXC__ServiceMax_Processes__c process : processList ) {
                    
                    SPM_WrapperDef.SPM_ProcessDetails processDetails = new SPM_WrapperDef.SPM_ProcessDetails();
                    
                    processDetails.processId = process.SVMXC__ProcessId__c;
                    //processDetails.processName = process.SVMXC__Name__c;
                    processDetails.processName = processIdVsReportNameMap.containsKey(process.SVMXC__ProcessID__c) ? processIdVsReportNameMap.get(process.SVMXC__ProcessID__c) : process.SVMXC__Name__c;
                    processDetails.timezone = process.SVMXC__Dispatch_Timezone__c;
                    processDetails.emailOnSuccess = process.SVMXC__Email_On_Success__c;
                    processDetails.emailOnFailure = process.SVMXC__Email_On_Error__c;
                    
                    if( processConfigDataMap.containsKey(process.Id) ) {
                        processDetails.spmDetailsList.add(processConfigDataMap.get( process.Id) );    
                    }                
                    response.spmProcessDetailsList.add( processDetails );
                }
            } else {
                
                // Updating warning message if calculation methods are not configured for requested process.
                response.warning = true;
                response.messageList.add( System.Label.SPM001_TAG007 );
                System.debug( LoggingLevel.WARN, 'None of the process has configured schedule details.');
            }
        }
        
        catch( QueryException ex ) {
            
            response.success = false;
            response.messageList.add( System.Label.SPM001_TAG011 );
            
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
        }
        
        catch( Exception ex ) {
            
            response.success = false;
            response.messageList.add( System.Label.SPM001_TAG015 );
            
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getSPMConfiguration() - exit; response: ' + response );    
        }        
        
        return response;
    }
    
    /**
     * This method is used to retrieve all configured SPM processes.
     * 
     * @return Returns instance of SPM_WrapperDef.SPM_Response with SPM process details.
     * 
     * @exception QueryException if failed to query process informations.
     * @exception Exception Any other exceptions.
     */
    public SPM_WrapperDef.SPM_Response getAllSPMProcess() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllSPMProcess() - enter' );
        
        SPM_WrapperDef.SPM_Response response = new SPM_WrapperDef.SPM_Response();
        response.success = true;
        
        try {
            
            List<String> queryFields = new List<String> {'Id', 'SVMXC__Name__c', 'SVMXC__ProcessID__c', 'SVMXC__Active__c', 'SVMXC__Description__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            initializeProcesses();
            // Retrieve all processes of type SPM Rule.
            List<SVMXC__ServiceMax_Processes__c> spmProcessList = [SELECT Id, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Active__c, SVMXC__Description__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Name__c != null AND SVMXC__ProcessID__c != null AND RecordType.Name = 'SPM Rule' ORDER BY SVMXC__Sequence__c];
            if( spmProcessList == null || spmProcessList.isEmpty() ) {
                
                response.success = false;
                response.messageList.add( System.Label.SPM001_TAG016 );
                
                return response;
            }
            
            // Create SPM_WrapperDef.SPM_ProcessDetails instance and populate process informations. 
            // Add process details to response.
            for( SVMXC__ServiceMax_Processes__c process : spmProcessList ) {
                
                SPM_WrapperDef.SPM_ProcessDetails spmProcessDetails = new SPM_WrapperDef.SPM_ProcessDetails();
                
                queryFields = new List<String> {'Id'};
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( 'Dashboard', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    
                    String title = '%' + process.SVMXC__Name__c + '%';
                    List<Dashboard> dashboardList = [SELECT Id FROM Dashboard WHERE Folder.Name = 'SPM Dashboard' AND Title LIKE :title];
                    if( !dashboardList.isEmpty() ) {
                        spmProcessDetails.dashboardId = dashboardList[0].Id;
                    }
                }
                
                spmProcessDetails.processId = process.SVMXC__ProcessID__c;
                //spmProcessDetails.processName = process.SVMXC__Name__c;
                spmProcessDetails.processName = processIdVsReportNameMap.containsKey(process.SVMXC__ProcessID__c) ? processIdVsReportNameMap.get(process.SVMXC__ProcessID__c) : process.SVMXC__Name__c;
                spmProcessDetails.isActive = process.SVMXC__Active__c;
                spmProcessDetails.description = process.SVMXC__Description__c;
                
                response.spmProcessDetailsList.add( spmProcessDetails );
            }    
            initConfigurationForAccountSummary(); 
        }
        
        catch( QueryException ex ) {
            
            response.success = false;
            response.messageList.add( System.Label.SPM001_TAG012 );
            
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
        }
        
        catch( Exception ex ) {
            
            response.success = false;
            response.messageList.add( System.Label.SPM001_TAG015 );
            
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllSPMProcess() - exit' );    
        }
        
        return response;
    }
    private void processMTBFRecordonly(id metricsRecordTypeId){
         List<SVMXC__ServiceMax_Processes__c> metrics = new List<SVMXC__ServiceMax_Processes__c>();
          metrics.add(new SVMXC__ServiceMax_Processes__c(
           RecordTypeId = metricsRecordTypeId,
            SVMXC__ProcessID__c = SPM_Schema.Report.MeanTimeBetweenFailure.name(),
            SVMXC__Name__c = System.Label.SPM002_TAG079,
            SVMXC__Description__c = System.Label.SPM002_TAG079,
            SVMXC__Sequence__c = 10,
            SVMXC__Active__c = true
        ));
        
        System.debug( LoggingLevel.DEBUG,'SPM Metrics count - ' + metrics.size());
        System.debug( LoggingLevel.DEBUG, 'SPM_ConfigurationImpl.initializeProcesses() - exit' );
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA   
        insert metrics;
    }
    
    /**
     * Intializes all the SPM Metrics processes. Previously it was accomplished through seed.
     * SPR-17 Changes.
     **/
    private void initializeProcesses() {
       System.debug( LoggingLevel.DEBUG, 'SPM_ConfigurationImpl.initializeProcesses() - enter' );  
       
       //Handle exceptions.
       Boolean checkProcessData=false;
       //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
       List<SVMXC__ServiceMax_Processes__c> processList = [SELECT Id, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Active__c, SVMXC__Description__c 
                                                            FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Name__c != null AND SVMXC__ProcessID__c != null 
                                                            AND SVMXC__Active__c=true  AND RecordType.Name = 'SPM Rule' ORDER BY SVMXC__Sequence__c];
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        RecordType recordTypeForMetrics = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'SPM Rule'];
        System.debug( LoggingLevel.INFO, 'Existing Processes - ' + processList.size());
        if( processList != null && !processList.isEmpty() ) {
            System.debug( LoggingLevel.INFO, 'All the SPM Processes are initialized' );
                if(processList.size()==9){
                    processMTBFRecordonly(recordTypeForMetrics.id);
                }
            return;
        }
            
       //Load the record type for creating the SPM Metrics list.
       // RecordType recordTypeForMetrics = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'SPM Rule'];
        
        //Add all the Metrics details to the code base.
        List<SVMXC__ServiceMax_Processes__c> metrics = new List<SVMXC__ServiceMax_Processes__c>();
        
        //FirstTimeFix
        metrics.add(new SVMXC__ServiceMax_Processes__c(
            RecordTypeId = recordTypeForMetrics.id,
            SVMXC__ProcessID__c = SPM_Schema.Report.FirstTimeFix.name(),
            SVMXC__Name__c = System.Label.SPM002_TAG066,
            SVMXC__Description__c = System.Label.SPM002_TAG066,
            SVMXC__Sequence__c = 1,
            SVMXC__Active__c = true
        ));
        
        //MeanTimeToRepair
        metrics.add(new SVMXC__ServiceMax_Processes__c(
            RecordTypeId = recordTypeForMetrics.id,
            SVMXC__ProcessID__c = SPM_Schema.Report.MeanTimeToRepair.name(),
            SVMXC__Name__c = System.Label.SPM002_TAG067,
            SVMXC__Description__c = System.Label.SPM002_TAG067,
            SVMXC__Sequence__c = 2,
            SVMXC__Active__c = true
        ));
        
        //UpDownTime
        metrics.add(new SVMXC__ServiceMax_Processes__c(
            RecordTypeId = recordTypeForMetrics.id,
            SVMXC__ProcessID__c = SPM_Schema.Report.UpDownTime.name(),
            SVMXC__Name__c = System.Label.SPM002_TAG068,
            SVMXC__Description__c = System.Label.SPM002_TAG068,
            SVMXC__Sequence__c = 3,
            SVMXC__Active__c = true
        ));
        
        //Attach Rate
        metrics.add(new SVMXC__ServiceMax_Processes__c(
            RecordTypeId = recordTypeForMetrics.id,
            SVMXC__ProcessID__c = SPM_Schema.Report.ContractPenetration.name(),
            SVMXC__Name__c = System.Label.SPM002_TAG069,
            SVMXC__Description__c = System.Label.SPM002_TAG069,
            SVMXC__Sequence__c = 4,
            SVMXC__Active__c = true
        ));
        
        //MeanTimeToComplete
        metrics.add(new SVMXC__ServiceMax_Processes__c(
            RecordTypeId = recordTypeForMetrics.id,
            SVMXC__ProcessID__c = SPM_Schema.Report.MeanTimeToComplete.name(),
            SVMXC__Name__c = System.Label.SPM002_TAG070,
            SVMXC__Description__c = System.Label.SPM002_TAG070,
            SVMXC__Sequence__c = 5,
            SVMXC__Active__c = true
        ));
        
        //AverageResponseTime
        metrics.add(new SVMXC__ServiceMax_Processes__c(
            RecordTypeId = recordTypeForMetrics.id,
            SVMXC__ProcessID__c = SPM_Schema.Report.AverageResponseTime.name(),
            SVMXC__Name__c = System.Label.SPM002_TAG071,
            SVMXC__Description__c = System.Label.SPM002_TAG071,
            SVMXC__Sequence__c = 6,
            SVMXC__Active__c = true
        ));
        
        //Technician Utilization
        metrics.add(new SVMXC__ServiceMax_Processes__c(
            RecordTypeId = recordTypeForMetrics.id,
            SVMXC__ProcessID__c = SPM_Schema.Report.Utilization.name(),
            SVMXC__Name__c = System.Label.SPM002_TAG072,
            SVMXC__Description__c = System.Label.SPM002_TAG072,
            SVMXC__Sequence__c = 7,
            SVMXC__Active__c = true
        ));
        
        //RepeatVisit
        metrics.add(new SVMXC__ServiceMax_Processes__c(
            RecordTypeId = recordTypeForMetrics.id,
            SVMXC__ProcessID__c = SPM_Schema.Report.RepeatVisit.name(),
            SVMXC__Name__c = System.Label.SPM002_TAG073,
            SVMXC__Description__c = System.Label.SPM002_TAG073,
            SVMXC__Sequence__c = 8,
            SVMXC__Active__c = true
        ));
        
        //AccountSummary
        metrics.add(new SVMXC__ServiceMax_Processes__c(
            RecordTypeId = recordTypeForMetrics.id,
            SVMXC__ProcessID__c = SPM_Schema.Report.AccountSummary.name(),
            SVMXC__Name__c = System.Label.SPM002_TAG074,
            SVMXC__Description__c = System.Label.SPM002_TAG074,
            SVMXC__Sequence__c = 9,
            SVMXC__Active__c = true
        ));
        //Mean Time Between Failure
        metrics.add(new SVMXC__ServiceMax_Processes__c(
            RecordTypeId = recordTypeForMetrics.id,
            SVMXC__ProcessID__c = SPM_Schema.Report.MeanTimeBetweenFailure.name(),
            SVMXC__Name__c = System.Label.SPM002_TAG079,
            SVMXC__Description__c = System.Label.SPM002_TAG079,
            SVMXC__Sequence__c = 10,
            SVMXC__Active__c = true
        ));
        
        System.debug( LoggingLevel.DEBUG,'SPM Metrics count - ' + metrics.size());
        System.debug( LoggingLevel.DEBUG, 'SPM_ConfigurationImpl.initializeProcesses() - exit' );
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        insert metrics;
    }
    /**
     * Configuration for Account Summary Flow is read-only and cannot be seeded through AC Tool.        
     * For now we will create it through the code.
     * TODO - In the next release this will be removed and seeded through the AC Tool.      
     **/    
    private void initConfigurationForAccountSummary() {     
        System.debug( LoggingLevel.DEBUG, 'initConfigurationForAccountSummary() - enter' );
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        List<SVMXC__ServiceMax_Processes__c> spmProcessList = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Name__c != null AND       
                                                                 SVMXC__ProcessID__c = 'AccountSummary' AND RecordType.Name = 'SPM Rule'];      
                    
        if(spmProcessList.size() > 0) {     
            Id processId = spmProcessList.get(0).Id;        
            System.debug( LoggingLevel.DEBUG, 'processId - ' + processId);      
            Integer count = [SELECT count() FROM SVMXC__ServiceMax_Config_Data__c WHERE RecordType.Name = 'SPM Details'     
                            and SVMXC__Dispatch_Process__c = :processId ];      
             System.debug( LoggingLevel.DEBUG, 'Existing Configuration Count - ' + count);      
            if(count == 0) {
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                RecordType configRecordType = [Select Id From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'SPM Details'];      
                System.debug( LoggingLevel.DEBUG, 'configRecordType - ' + configRecordType);        
                String calculationMethod = '{"targetObjectName":"SVMXC__SPM_Account_Summary__c","targetObjectLabel":"SPM - Account Summary","sourceObjectName":"SVMXC__ServiceMax_Processes__c","sourceObjectLabel":"ServiceMax Processes","recordId":"a10F0000007h0TvIAI","parameterInfoList":[],"objectMappingDetailsList":[],"name":"CN-0003723482","methodDisplayName":null,"method":null,"lastModifiedOn":"7/19/2016 5:41 PM","isActive":true,"expressionDetailsList":[],"appliesTo":"Compute Account Summary"}';      
                        
                SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();       
                configData.RecordTypeId = configRecordType.Id;      
                configData.SVMXC__Dispatch_Process__c = processId;      
                configData.SVMXC__Formula__c = calculationMethod;       
                configData.SVMXC__Active__c = true;     
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA        
                insert configData;      
                System.debug( LoggingLevel.DEBUG, 'New Configuration Created');     
            } else {        
                System.debug( LoggingLevel.DEBUG, 'Configuration Exists for Account Summary Process');      
            }       
        }       
        System.debug( LoggingLevel.DEBUG, 'initConfigurationForAccountSummary() - exit' );      
    }
    
    /**
     * This method is used to save/update SPM configuration and schedule details.
     * 
     * @param request Instance of SPM_WrapperDef.SPM_Request object with one or more 
     *                configuration data to be saved.
     * @return Returns SPM_WrapperDef.SPM_Response object instance with success/failure message.
     * 
     * @exception QueryException if failed to query process informations.
     * @exception DMLException if failed to delete/insert/update requested configuration informations.
     * @exception Exception Any other exceptions.
     */
    public SPM_WrapperDef.SPM_Response saveSPMConfiguration( SPM_WrapperDef.SPM_Request request ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveSPMConfiguration() - enter; request: ' + request );
        
        SPM_WrapperDef.SPM_Response response = new SPM_WrapperDef.SPM_Response();
        response.success = true;
        
        // Check for valid request.
        if( request == null || request.spmProcessDetailsList == null || request.spmProcessDetailsList.isEmpty() ) {
            
            response.success = false;
            response.messageList.add( System.Label.SPM001_TAG004 );
            
            return response;
        }
        
        // Create unique list of process Id's from request.
        Map<String, SPM_WrapperDef.SPM_ProcessDetails> processIdDetailMap = new Map<String, SPM_WrapperDef.SPM_ProcessDetails>();
        for( SPM_WrapperDef.SPM_ProcessDetails spmProcessDetails : request.spmProcessDetailsList ) {
            // Check for valid process details and process id's in request.
            if( spmProcessDetails != null && spmProcessDetails.processId != null ) {
                processIdDetailMap.put( spmProcessDetails.processId, spmProcessDetails );    
            } else {
                System.debug( LoggingLevel.ERROR, 'Invalid process detail or processId in request.' );
            }
        }
        
        // Process if atleast one valid process id exists in request.
        if( processIdDetailMap.isEmpty() ) {
            
            response.success = false;
            response.messageList.add( System.Label.SPM001_TAG004 );
            
            return response;
        }
        
        // Create save point, which will be used to rollback in case of any failure on DML operations.
        Savepoint sp = Database.setSavepoint();
        
        try {
            
            List<String> queryFields = new List<String> {'Id', 'SVMXC__ProcessID__c', 'SVMXC__Dispatch_Timezone__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            // Retrieve requested SPM process informations.
            Map<Id,SVMXC__ServiceMax_Processes__c> spmProcessMap = new Map<Id,SVMXC__ServiceMax_Processes__c>();
            spmProcessMap.putAll( [SELECT Id, SVMXC__ProcessID__c, SVMXC__Dispatch_Timezone__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__ProcessID__c IN :processIdDetailMap.keySet() ] );
            
            // Validate servicemax process records for requested process id's exists or not.
            if( spmProcessMap.isEmpty() ) {
                
                response.success = false;
                response.messageList.add( System.Label.SPM001_TAG008 + processIdDetailMap.keySet() );
                
                return response;
            }
            
            // Populate process Id vs record Id map. also update timezone with user timezone.
            // Timezone will be used by SCON scheduler to schedule SPM reports.
            Map<String,Id> processIdMap = new Map<String,Id>();
            for( SVMXC__ServiceMax_Processes__c spmProcess : spmProcessMap.values() ) {
                
                processIdMap.put( spmProcess.SVMXC__ProcessID__c, spmProcess.ID );
                
                if( processIdDetailMap.get(spmProcess.SVMXC__ProcessID__c).timezone != null ) {
                    
                    spmProcess.SVMXC__Dispatch_Timezone__c = processIdDetailMap.get(spmProcess.SVMXC__ProcessID__c).timezone;
                    spmProcess.SVMXC__Email_On_Success__c = processIdDetailMap.get(spmProcess.SVMXC__ProcessID__c).emailOnSuccess;
                    spmProcess.SVMXC__Email_On_Error__c = processIdDetailMap.get(spmProcess.SVMXC__ProcessID__c).emailOnFailure;
                }
                
                spmProcess.SVMXC__Active__c = true;
            }
            
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( spmProcessMap.values(), COMM_SecurityUtils.Access.Updateable ) ) {
                // Update servicemax process record with timezone and email informations.
                update spmProcessMap.values();
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            // For each configuration data from request, set the SPM process id.
            // Populate list of all configuration data to be inserted.            
            List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
            for( SPM_WrapperDef.SPM_ProcessDetails spmProcessDetails : request.spmProcessDetailsList ) {
                
                for( SVMXC__ServiceMax_Config_Data__c configData : spmProcessDetails.spmDetailsList ) {
                    
                    configData.SVMXC__Dispatch_Process__c = processIdMap.get( spmProcessDetails.processId );                    
                    configDataList.add(configData);
                }
            }
            
            // Insert new configuration details.
            if( !configDataList.isEmpty() ) { 
                
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( configDataList, COMM_SecurityUtils.Access.Upsertable ) ) {
                    // Update servicemax process record with timezone and email informations.
                    upsert configDataList;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
            
            // Populate response object with config data record id's.
            SPM_WrapperDef.SPM_ProcessDetails processDetails = new SPM_WrapperDef.SPM_ProcessDetails();
            for( SVMXC__ServiceMax_Config_Data__c configData : configDataList ) {
                
                if( configData.SVMXC__Period__c != null ) {
                    processDetails.scheduleId = configData.Id;
                } else {
                    SVMXC__ServiceMax_Processes__c spmProcess = spmProcessMap.get( configData.SVMXC__Dispatch_Process__c );
                    processDetails.processId = spmProcess.SVMXC__ProcessID__c;
                    processDetails.spmDetailsList.add( configData );    
                }
            }
            
            response.spmProcessDetailsList.add( processDetails );
            
            response.messageList.add( System.Label.SPM001_TAG001 );    
        }
        
        catch( QueryException ex ) {
            
            response.success = false;
            response.messageList.add( System.Label.SPM001_TAG012 );
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
        }
        
        catch( DMLException ex ) {
            
            Database.rollback( sp );
            
            response.success = false;
            response.messageList.add( System.Label.SPM001_TAG010 );
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
        }
        
        catch( Exception ex ) {
            
            Database.rollback( sp );
            
            response.success = false;
            response.messageList.add( System.Label.SPM001_TAG015 );
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveSPMConfiguration() - exit' );    
        }
        
        return response;
    }
    
    /**
     * This method is used to save schedule configurations. The timezone, email on success 
     * and email on failure informations are saved on servicemax processes and schedule informations 
     * are saved in config data.
     * 
     * @param request Instance of SPM_WrapperDef.SPM_Request with process and schedule informations to be saved.
     * @return Returns instance of SPM_WrapperDef.SPM_Response with status and info/error messages.
     * 
     * @exception QueryException if failed to retrieve SPM process informations.
     * @exception DMLException if failed to insert/upsert schedule details.
     * @exception Exception
     */
    public SPM_WrapperDef.SPM_Response saveScheduleConfiguration( SPM_WrapperDef.SPM_Request request ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveScheduleConfiguration() - enter; request: ' + request );
        
        SPM_WrapperDef.SPM_Response response = new SPM_WrapperDef.SPM_Response();
        response.success = true;
        
        // Check for valid request.
        if( request == null || request.spmProcessDetailsList == null || request.spmProcessDetailsList.isEmpty() ) {
            
            response.success = false;
            response.messageList.add( System.Label.SPM001_TAG004 );
            
            return response;
        }
        
        // Create unique list of process Id's from request.
        Map<String, SPM_WrapperDef.SPM_ProcessDetails> processIdDetailMap = new Map<String, SPM_WrapperDef.SPM_ProcessDetails>();
        for( SPM_WrapperDef.SPM_ProcessDetails spmProcessDetails : request.spmProcessDetailsList ) {            
            if( spmProcessDetails != null && spmProcessDetails.processId != null ) {
                processIdDetailMap.put( spmProcessDetails.processId, spmProcessDetails );    
            } else {
                System.debug( LoggingLevel.ERROR, 'Invalid process detail or processId in request.' );
            }
        }
        
        // Process if atleast one valid schedule configuration with process info exists.
        if( processIdDetailMap.isEmpty() ) {
            
            response.success = false;
            response.messageList.add( System.Label.SPM001_TAG004 );
            
            return response;
        }
        
        // Create save point, which will be used to rollback in case of any failure on DML operations.
        Savepoint sp = Database.setSavepoint();
        
        try {
            
            List<String> queryFields = new List<String> {'Id', 'SVMXC__Email_On_Success__c', 'SVMXC__Email_On_Error__c', 'SVMXC__ProcessID__c', 'SVMXC__Dispatch_Timezone__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            // Retrieve requested SPM process informations.
            List<SVMXC__ServiceMax_Processes__c> spmProcessList = [SELECT Id, SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c, SVMXC__ProcessID__c, SVMXC__Dispatch_Timezone__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__ProcessID__c IN :processIdDetailMap.keySet() ];
            
            if( spmProcessList.isEmpty() ) {
                
                response.success = false;
                response.messageList.add( System.Label.SPM001_TAG008 + processIdDetailMap.keySet() );
                
                return response;
            }
            
            // Populate process Id vs record Id map. also update timezone with user timezone.
            // Timezone will be used by SCON scheduler to schedule SPM reports.
            Map<String,Id> processIdMap = new Map<String,Id>();
            for( SVMXC__ServiceMax_Processes__c spmProcess : spmProcessList ) {
                
                processIdMap.put( spmProcess.SVMXC__ProcessID__c, spmProcess.ID );
                
                spmProcess.SVMXC__Email_On_Success__c = processIdDetailMap.get(spmProcess.SVMXC__ProcessID__c).emailOnSuccess;
                spmProcess.SVMXC__Email_On_Error__c = processIdDetailMap.get(spmProcess.SVMXC__ProcessID__c).emailOnFailure;
                spmProcess.SVMXC__Dispatch_Timezone__c = processIdDetailMap.get(spmProcess.SVMXC__ProcessID__c).timezone;
            }
            
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( spmProcessList, COMM_SecurityUtils.Access.Updateable ) ) {
                // Update servicemax process record with timezone and email informations.
                update spmProcessList;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
            for( SPM_WrapperDef.SPM_ProcessDetails spmProcessDetails : request.spmProcessDetailsList ) {
                
                for( SVMXC__ServiceMax_Config_Data__c configData : spmProcessDetails.spmDetailsList ) {
                    
                    configData.SVMXC__Dispatch_Process__c = processIdMap.get( spmProcessDetails.processId );                    
                    configDataList.add(configData);
                }
            }
                        
            // Insert new or update existing schedule configuration details.
            if( !configDataList.isEmpty() ) {
                
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( configDataList, COMM_SecurityUtils.Access.Upsertable ) ) {
                    upsert configDataList; 
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
            
            // Populate config data record id's to response.
            SPM_WrapperDef.SPM_ProcessDetails configData = new SPM_WrapperDef.SPM_ProcessDetails();            
            configData.spmDetailsList = configDataList;
            response.spmProcessDetailsList.add( configData );
            
            response.messageList.add( System.Label.SPM001_TAG003 );    
        }
        
        catch( QueryException ex ) {
            
            response.success = false;
            response.messageList.add( System.Label.SPM001_TAG012 );
            
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
        }
        
        catch( DMLException ex ) {
            
            Database.rollback( sp );
            
            response.success = false;
            response.messageList.add( System.Label.SPM001_TAG017 );
            
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
        }
        
        catch( Exception ex ) {
            
            Database.rollback( sp );
            
            response.success = false;
            response.messageList.add( System.Label.SPM001_TAG015 );
            
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveScheduleConfiguration() - exit' );    
        }
        
        return response;
    }
    
    /**
     * This method is used to delete requested calculation method configurations.
     * 
     * @param request Instance of SPM_WrapperDef.SPM_Request with config data record id's to be deleted.
     * @return Returns SPM_WrapperDef.SPM_Response instance with request status and info/error messages.
     * 
     * @exceptions DMLException if failed to delete SPM configuration.
     * @exception Exception
     */
    public SPM_WrapperDef.SPM_Response deleteCalculationMethod( SPM_WrapperDef.SPM_Request request ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteCalculationMethod() - enter; request: ' + request );
        
        SPM_WrapperDef.SPM_Response response = new SPM_WrapperDef.SPM_Response();
        response.success = true;
        
        // Check for valid request.
        if( request == null || request.spmProcessDetailsList == null || request.spmProcessDetailsList.isEmpty() ) {
            
            response.success = false;
            response.messageList.add( System.Label.SPM001_TAG004 );
            
            return response;
        }
        
        // Create save point, which will be used to rollback in case of any failure on DML operations.
        Savepoint sp = Database.setSavepoint();
        
        try {
            List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
            for( SPM_WrapperDef.SPM_ProcessDetails spmProcessDetails : request.spmProcessDetailsList ) {
                
                for( SVMXC__ServiceMax_Config_Data__c configData : spmProcessDetails.spmDetailsList ) {
                    // Populate only valid configuration data records.
                    if( configData != null ) {                        
                        configDataList.add(configData);    
                    } else {
                        System.debug( LoggingLevel.ERROR, 'Invalid configuration data in request.' );
                    }
                }
            }
            
            // Check for valid configuration data from request.            
            if( configDataList.isEmpty() ) {
                
                response.success = false;
                response.messageList.add( System.Label.SPM001_TAG004 );
                return response;
            }
            
            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                
                // Delete requested config data record.
                delete configDataList;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            response.messageList.add( System.Label.SPM001_TAG002 );                    
        }
        
        catch( DMLException ex ) {
            
            Database.rollback( sp );
            
            response.success = false;
            response.messageList.add( System.Label.SPM001_TAG018 );
            
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
        }
        
        catch( Exception ex ) {
            
            Database.rollback( sp );
            
            response.success = false;
            response.messageList.add( System.Label.SPM001_TAG015 );
            
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteCalculationMethod() - exit' );    
        }
        
        return response;
    }
    
    /**
     * This method is used to retrieve all SPM Jobs records. The jobs which has been created a 
     * month back will be purged by default. The duration will be configured via settings.
     * 
     * @returns Returns SPM_WrapperDef.SPM_Response instance with spm jobs record details.
     * 
     * @exception DMLException if failed to purge jobs records.
     * @exception QueryException if failed to query jobs or attachment records.
     * @exception Exception
     */
    public SPM_WrapperDef.SPM_Response getSPMJobs( String processId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getSPMJobs() - enter; processId: '+ processId );
        
        SPM_WrapperDef.SPM_Response response = new SPM_WrapperDef.SPM_Response();
        response.success = true;
        
        // Check for valid request.
        if( processId == null ) {
            
            response.success = false;
            response.messageList.add( System.Label.SPM001_TAG004 );
            
            return response;
        }
        
        SavePoint sp = Database.setSavepoint();
        
        try {
            Integer purgeDuration = 1;// default purge duration in months
            
            // TODO update purge duration from Setting values.
            
            // Purging jobs records, defaults to one month.
            Datetime retailRecordsFrom = System.now().addMonths( (purgeDuration * -1) );
            
            List<String> queryFields = new List<String> { 'Id', 'Name', 'SVMXC__Batch_Job__c', 'SVMXC__SVMX_Process__c', 'SVMXC__Start_Time__c', 'SVMXC__End_Time__c', 'SVMXC__Status__c' };
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SVMX_Jobs__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            // Retrieve all jobs older than the configured purge duration.
            Map<Id, SVMXC__SVMX_Jobs__c> purgeJobsMap = new Map<Id, SVMXC__SVMX_Jobs__c>();
            purgeJobsMap.putAll( [SELECT ID FROM SVMXC__SVMX_Jobs__c WHERE SVMXC__Type__c = 'SPM Schedule' AND CreatedDate < :retailRecordsFrom limit 10000] );
            
             //Added for BAC-4043
            Boolean isSalesforcefileEnabled = COMM_FileHandlerUtilities.checkFileSetting();
            if(isSalesforcefileEnabled && purgeJobsMap.size()>0){
                List<Id> lstParentIds = new List<Id>();
                lstParentIds.addAll(purgeJobsMap.keySet());
                List<ContentDocumentLink> lstCDL = COMM_FileHandlerUtilities.getAllContentDocumentsLinks(null, lstParentIds);
                List<Id> listContentDocumentIds = new List<Id>();
                for(ContentDocumentLink cdlVar: lstCDL){
                    listContentDocumentIds.add(cdlVar.ContentDocumentId);
                }
                COMM_FileHandlerUtilities.deleteContentDocument(listContentDocumentIds);
            }
            //Added for BAC-4043
            
            queryFields = new List<String> {'Id'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'Attachment', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'Attachment' ) ) {
                
                // Remove all attachment assocuated to the purge job log records.
                delete [ SELECT Id FROM Attachment WHERE ParentId IN :purgeJobsMap.keySet() ];
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__SVMX_Jobs__c' ) ) {                
                // Purge job log records.
                delete purgeJobsMap.values();
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            // Retrieve all SPM jobs records by Created date order.
            Map<Id, SPM_WrapperDef.AuditLogInfo> spmJobsMap = new Map<Id, SPM_WrapperDef.AuditLogInfo>();
            List<SVMXC__SVMX_Jobs__c> jobsList = [ SELECT Id, Name, SVMXC__Batch_Job__c, SVMXC__SVMX_Process__c, SVMXC__Start_Time__c, SVMXC__End_Time__c, SVMXC__Status__c 
                                                    FROM SVMXC__SVMX_Jobs__c 
                                                    WHERE SVMXC__Type__c = 'SPM Schedule' 
                                                    AND SVMXC__SVMX_Process__r.SVMXC__ProcessID__c = :processId  
                                                    ORDER BY CreatedDate DESC NULLS LAST];
            
            // Populate records to response.
            for( SVMXC__SVMX_Jobs__c jobs : jobsList ) {
                
                SPM_WrapperDef.AuditLogInfo info = new SPM_WrapperDef.AuditLogInfo();
                info.jobs = jobs;            
                spmJobsMap.put( jobs.Id, info );
            }
            
            queryFields = new List<String> {'Id', 'ParentId'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'Attachment', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            // Retrieve attachments for all queried jobs.
            List<Attachment> attachmentList = [ SELECT Id, ParentId FROM Attachment WHERE ParentId IN :spmJobsMap.keySet() ];
            // Populate attachment Id's to respective jobs.
            for( Attachment attach : attachmentList ) {
                // 
                if( spmJobsMap.containsKey( attach.ParentId ) ) {
                    spmJobsMap.get( attach.ParentId ).attachmentId = attach.Id;
                }
            }
            //Added for BAC-4043 
            if(isSalesforcefileEnabled && spmJobsMap.size()>0){
                List<Id> lstParentIds = new List<Id>();
                lstParentIds.addAll(spmJobsMap.keySet());
                List<ContentDocumentLink> lstCDL = COMM_FileHandlerUtilities.getAllContentDocumentsLinks(null, lstParentIds);
                //System.debug('lstCDL  '+lstCDL);
                Map<Id,Id> mapParentIdCDids = new Map<Id,Id>();
                for(ContentDocumentLink cdlVar: lstCDL){
                    mapParentIdCDids.put(cdlVar.LinkedEntityId, cdlVar.ContentDocument.LatestPublishedVersionId);
                }
                System.debug('mapParentIdCDids '+mapParentIdCDids);
                for( Id parentId : mapParentIdCDids.keySet() ) {
                // 
                    if( mapParentIdCDids.containsKey( parentId ) ) {
                        spmJobsMap.get( parentId ).attachmentId = mapParentIdCDids.get(parentId);
                    }
                }
                //System.debug('spmJobsMap '+spmJobsMap);
            }
            //Added for BAC-4043
            response.spmJobsList.addAll( spmJobsMap.values() );    
        }
        
        catch( QueryException ex ) {
            
            Database.rollback( sp );
            
            response.success = false;
            response.messageList.add( System.Label.SPM001_TAG013 );
            
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
        }
        
        catch( DMLException ex ) {
            
            Database.rollback( sp );
            
            response.success = false;
            response.messageList.add( System.Label.SPM001_TAG014 );
            
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
        }
        
        catch( Exception ex ) {
            
            Database.rollback( sp );
            
            response.success = false;
            response.messageList.add( System.Label.SPM001_TAG015 );
            
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getSPMJobs() - exit' );    
        }
        
        return response;
    }
    
    /**
     * TODO comments
     */
    public SPM_WrapperDef.SPM_Response executeBatch( String processId ) {
        
        System.debug( LoggingLevel.DEBUG, 'executeBatch() - enter; processId: '+ processId );
        
        SPM_WrapperDef.SPM_Response response = new SPM_WrapperDef.SPM_Response();
        response.success = true;
        if(processId != null)
        {
            try {
                
                List<String> queryFields = new List<String> {'id','SVMXC__Dispatch_Process__c', 'SVMXC__Active__c', 'SVMXC__Enter_Date__c', 'SVMXC__Unprocessed__c', 'SVMXC__Period__c', 'SVMXC__Previous_Execution_Completed_On__c', 'SVMXC__Run_Type__c', 'SVMXC__Schedule_Type__c', 'SVMXC__Previous_Execution_Started_On__c', 'SVMXC__Period_Start_On__c', 'SVMXC__Period_End_On__c' };
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                List<SVMXC__ServiceMax_Config_Data__c> listScheduleDetail = [Select id,SVMXC__Dispatch_Process__c, SVMXC__Dispatch_Process__r.SVMXC__Name__c, SVMXC__Dispatch_Process__r.SVMXC__ProcessID__c, SVMXC__Active__c, SVMXC__Enter_Date__c,
                                                                               SVMXC__Dispatch_Process__r.SVMXC__Assign_To_Dispatcher__c, SVMXC__Dispatch_Process__r.RecordType.Name, SVMXC__Unprocessed__c, SVMXC__Period__c, SVMXC__Previous_Execution_Completed_On__c,
                                                                               SVMXC__Run_Type__c, SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Timezone__c , SVMXC__Schedule_Type__c, SVMXC__Previous_Execution_Started_On__c, SVMXC__Period_Start_On__c, SVMXC__Period_End_On__c 
                                                                               from SVMXC__ServiceMax_Config_Data__c 
                                                                               WHERE RecordType.Name = 'Schedule'
                                                                               AND SVMXC__Dispatch_Process__r.SVMXC__ProcessID__c =: processId];
                if(listScheduleDetail != null && listScheduleDetail.size() > 0) {
                    
                    queryFields = new List<String> {'Id', 'Status'};
                    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'AsyncApexJob', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    
                    List<AsyncApexJob> lstApexJob = new List<AsyncApexJob>();
                    lstApexJob = [SELECT Id, Status FROM AsyncApexJob Where JobType = 'BatchApex' AND (Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing')];
                    if(lstApexJob.size() < 5){
                        try{
                            if( processId.equalsIgnoreCase(SPM_Schema.Report.FirstTimeFix.Name() ) ) {
                                SPM_FirstTimeFix ftfBatch = new SPM_FirstTimeFix( listScheduleDetail[0] );
                                database.executebatch(ftfBatch);
                            } else if( processId.equalsIgnoreCase( SPM_Schema.Report.MeanTimeToRepair.Name() ) ) {
                                SPM_MeanTimeToRepair mttrBatch = new SPM_MeanTimeToRepair( listScheduleDetail[0] );
                                database.executebatch(mttrBatch);
                            } else if( processId.equalsIgnoreCase( SPM_Schema.Report.UpDownTime.Name() ) ) {
                                SPM_ContractUpTime upDownTime = new SPM_ContractUpTime( listScheduleDetail[0] );
                                database.executebatch( upDownTime );
                            } else if( processId.equalsIgnoreCase(SPM_Schema.Report.ContractPenetration.Name() ) ) {
                                SPM_ContractPenetration contractPenetration = new SPM_ContractPenetration( listScheduleDetail[0] );
                                database.executebatch( contractPenetration );
                            } else if( processId.equalsIgnoreCase(SPM_Schema.Report.Utilization.Name() ) ) {
                                SPM_TechUtilization techUtilization = new SPM_TechUtilization( listScheduleDetail[0] );
                                database.executebatch( techUtilization );
                            }  else if( processId.equalsIgnoreCase(SPM_Schema.Report.MeanTimeToComplete.Name() ) ) {
                                SPM_MeanTimeToComplete MeanTimeToComplete = new SPM_MeanTimeToComplete( listScheduleDetail[0] );
                                database.executebatch( MeanTimeToComplete );
                            } else if( processId.equalsIgnoreCase(SPM_Schema.Report.AverageResponseTime.Name() ) ) {
                                SPM_AverageResponseTime averateResponseTime = new SPM_AverageResponseTime( listScheduleDetail[0] );
                                database.executebatch( averateResponseTime );
                            } else if( processId.equalsIgnoreCase(SPM_Schema.Report.RepeatVisit.Name() ) ) {
                                SPM_Repeat_Visit repeatVisitEngine = new SPM_Repeat_Visit( listScheduleDetail[0] );
                                database.executebatch( repeatVisitEngine );
                            } else if( processId.equalsIgnoreCase(SPM_Schema.Report.AccountSummary.Name() ) ) {     
                                SPM_Account_Summary accountSummary = new SPM_Account_Summary(listScheduleDetail[0]);        
                                database.executebatch( accountSummary, 1 ); 
                            } else if( processId.equalsIgnoreCase(SPM_Schema.Report.MeanTimeBetweenFailure.Name() ) ) {
                                SPM_MeanTimeBetweenFailure mtbf = new SPM_MeanTimeBetweenFailure(listScheduleDetail[0]);
                                database.executebatch( mtbf);
                            }else {
                                response.success = false;
                                response.messageList.add( System.Label.SPM001_TAG004 );
                            }
                            
                        }
                        catch(Exception ex) {
                            response.success = false;
                            response.messageList.add( System.label.SPM001_TAG020 );
                        }
                    }
                    else{
                        response.success = false;
                        response.messageList.add( System.label.SPM001_TAG020 );
                    }
                } else {
                    response.success = false;
                    response.messageList.add( System.label.SPM001_TAG007 + processId );
                }
            }
            catch( QueryException ex ) {
                
                response.success = false;
                response.messageList.add( System.Label.SPM001_TAG013 );
                
                System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
            }
            catch(Exception ex) {
                
                response.success = false;
                response.messageList.add( System.Label.SPM001_TAG015 );
                
                System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
            }
                     
        } else {
            response.success = false;
            response.messageList.add( System.Label.SPM001_TAG004 );
        }  
        
        if (response.success) {
            response.messageList.add( System.label.SPM001_TAG019 );
        }
        
                        
        return response;
    }
}