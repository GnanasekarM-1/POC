/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The SPM_Configuration implements methods to create SPM_Request from JSON, retrieves 
 * data by calling SPM_ConfigurationImpl methods and return response as JSON string.
 * 
 *
 * @author Ramachandra Mohan
 * @version 15.59100
 * @since 2015
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan      08 Oct 2015     Created.
 * 026157       Ramachandra Mohan     29 Mar 2016     Implemented field level validation.
 * 029043       Ramachandra Mohan      06 Apr 2016     Handling change in configuration sequence.
 * BAC-4050     Soumyaranjan Pati      27th June 2018  Security fixes.
 *****************************************************************************************************/
global with sharing class SPM_Configuration {

    /**
     * TODO Include comments
     */
    class SPMJobsInfo {
        
        String recordId;
        String jobName;
        String processId;
        String startTime;
        String endTime;
        String status;
        String attachment;
        String reportName;
        
        public SPMJobsInfo() {}
    }
    
    /**
     * TODO Include comments
     */
    class SPMProcessInfo {
        
        String processId;
        String processName;
        String dashboardId;
        String description;
        Boolean isActive = true;
        
        public String scheduleId;
        
        public String period;
        public Integer dayToRun;
        public String[] weekOn = new String[]{};
        public String timeAt;
        public String timezone;
        public String lastModified;
        public String emailOnSuccess;
        public String emailOnFailure;
                
        List<SPM_ConfigurationDefinition.CalculationMethod> defaultCalculationMethodList = new List<SPM_ConfigurationDefinition.CalculationMethod>();        
        List<SPM_ConfigurationDefinition.CalculationMethod> calculationMethodList = new List<SPM_ConfigurationDefinition.CalculationMethod>();
        
        public SPMProcessInfo(){}
    }
    
    /**
     * 
     */
    class Output {
    
        public Boolean success = true;
        public Boolean warning = false;
        public String message;
        
        public List<SPMProcessInfo> spmProcessInfoList = new List<SPMProcessInfo>();
        public List<SPMJobsInfo> spmJobsInfoList = new List<SPMJobsInfo>();
        public List<SPM_WrapperDef.ObjectInfo> timezoneList = new List<SPM_WrapperDef.ObjectInfo>();
        
        public Output() {}
    }
    
    /**
     * 
     */
    @RemoteAction
    global static Object getSPMJobs( String requestStr ) {
        
        System.debug( LoggingLevel.DEBUG, 'getSPMJobs() - enter; requestStr: ' + requestStr );
        
        Output result = new Output();
        result.success = true;
        
        try {
            SPMProcessInfo processInfo = (SPMProcessInfo) JSON.deserialize( requestStr, SPMProcessInfo.class );
            
            SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().getSPMJobs( processInfo.processId );
            result.success = response.success;
            
            if( result.success ) {
                
                for( SPM_WrapperDef.AuditLogInfo svmxJobs : response.spmJobsList ) {
                    
                    SPMJobsInfo info = new SPMJobsInfo();
                    
                    info.recordId = svmxJobs.jobs.Id;
                    info.jobName = svmxJobs.jobs.Name;
                    info.processId = svmxJobs.jobs.SVMXC__SVMX_Process__c;
                    if( svmxJobs.jobs.SVMXC__Start_Time__c != null )
                        info.startTime = svmxJobs.jobs.SVMXC__Start_Time__c.format();
                    if( svmxJobs.jobs.SVMXC__End_Time__c != null )
                        info.endTime = svmxJobs.jobs.SVMXC__End_Time__c.format();
                    info.status = svmxJobs.jobs.SVMXC__Status__c;
                    info.attachment = svmxJobs.attachmentId;
                    info.reportName = svmxJobs.jobs.SVMXC__Batch_Job__c;
                    
                    result.spmJobsInfoList.add(info);
                }
            } 
            
            result.message = SPM_Utilities.getInstance().buildString( response.messageList, SPM_Consts.LINE_BREAK );
        }
        
        catch( Exception ex ) {
            
            result.success = false;
            result.message = ex.getMessage();
        }
        
        return JSON.serialize( result );
    }
    
    /**
     * 
     */
    @RemoteAction
    global static Object executeBatch( String requestStr ) {
        
        System.debug( LoggingLevel.DEBUG, 'executeBatch() - enter; requestStr: ' + requestStr );
        
        Output result = new Output();
        result.success = true;
        try {
            SPMProcessInfo processInfo = (SPMProcessInfo) JSON.deserialize( requestStr, SPMProcessInfo.class );
            
            SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().executeBatch( processInfo.processId );
            result.success = response.success;
            
            result.message = SPM_Utilities.getInstance().buildString( response.messageList, SPM_Consts.LINE_BREAK );    
        }        
        catch( Exception ex ) {
            
            result.success = false;
            result.message = ex.getMessage();
        }
        
        System.debug( LoggingLevel.DEBUG, 'executeBatch() - exit; requestStr: ' + result );
        
        return JSON.serialize( result );
    }

    /**
     * 
     */
    @RemoteAction
    global static Object getAllScheduleConfiguration( String requestStr ) {
        
        System.debug( LoggingLevel.DEBUG, 'getAllScheduleConfiguration() - enter' );
        
        Output result = new Output();
        result.success = true;
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().getAllScheduleConfiguration();
        result.success = response.success;
        result.message = SPM_Utilities.getInstance().buildString( response.messageList, SPM_Consts.LINE_BREAK );
                
        if( result.success ) {
            
            if( !response.spmProcessDetailsList.isEmpty() ) {
                
                for( SPM_WrapperDef.SPM_ProcessDetails processDetails : response.spmProcessDetailsList) {
                    
                    SPMProcessInfo info = new SPMProcessInfo();
                    
                    info.processId = processDetails.processId;
                    info.processName = processDetails.processName;
                    info.timezone = processDetails.timezone;
                    info.emailOnSuccess = processDetails.emailOnSuccess;
                    info.emailOnFailure = processDetails.emailOnFailure;
                    
                    if( !processDetails.spmDetailsList.isEmpty() ) {
                        
                        SVMXC__ServiceMax_Config_Data__c configData = processDetails.spmDetailsList.get(0);
                        info.scheduleId = configData.Id;
                        info.lastModified = configData.LastModifiedDate.format();
                        info.period = configData.SVMXC__Period__c;
                        if( configData.SVMXC__Day_to_Run__c != null ) {
                          info.dayToRun = Integer.valueOf( configData.SVMXC__Day_to_Run__c );
                        }
                        
                        if( configData.SVMXC__Schedule_Days__c != null ) {
                            info.weekOn = configData.SVMXC__Schedule_Days__c.split( SPM_Consts.SEMICOLON );
                        }                        
                        info.timeAt = configData.SVMXC__Run_At__c;
                    }
                    result.spmProcessInfoList.add(info);
                }
            }
        }
        
        System.debug( LoggingLevel.DEBUG, 'getAllScheduleConfiguration() - exit; result: ' + result);
        
        return JSON.serialize( result );
    }
    
    /**
     * 
     */
    @RemoteAction
    global static Object getSPMConfiguration( String requestStr ) {
        
        System.debug( LoggingLevel.DEBUG, 'getSPMConfiguration() - enter; requestStr: ' + requestStr );
        
        Output result = new Output();
        result.success = true;
        try {
            SPMProcessInfo processInfo = (SPMProcessInfo) JSON.deserialize( requestStr, SPMProcessInfo.class );
            
            SPMProcessInfo info = new SPMProcessInfo();
            info.processId = processInfo.processId;
            info.processName = processInfo.processName;
            
            //info.calculationMethodList = SPM_Utilities.getInstance().getCalculationMethodList( processInfo.processId );
            info.defaultCalculationMethodList = SPM_ConfigurationDefinition.getCalculationMethodList( processInfo.processId );
            
            SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
            SPM_WrapperDef.SPM_ProcessDetails spmProcessDetails = new SPM_WrapperDef.SPM_ProcessDetails();
            spmProcessDetails.processId = processInfo.processId;
            
            request.spmProcessDetailsList.add( spmProcessDetails );
            
            SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().getSPMConfiguration( request );
            result.success = response.success;
            
            if( result.success ) {
                
                if( !response.spmProcessDetailsList.isEmpty() ) {
                    
                    SPM_WrapperDef.SPM_ProcessDetails processDetails = response.spmProcessDetailsList.get(0);
                    
                    if( processDetails.spmDetailsList.isEmpty() ) {
                        info.timezone = UserInfo.getTimeZone().getId();
                    }
                    
                    info.dashboardId = processDetails.dashboardId;
                    info.isActive = processDetails.isActive;
                    
                    for( SVMXC__ServiceMax_Config_Data__c configData : processDetails.spmDetailsList ) {
                        
                        if( configData.SVMXC__RecordType_Name__c == SPM_Consts.SCHEDULE ) {
                            
                            info.timezone = processDetails.timezone;
                            info.emailOnSuccess = processDetails.emailOnSuccess;
                            info.emailOnFailure = processDetails.emailOnFailure;
                            
                            SVMXC__ServiceMax_Config_Data__c scheduleData = processDetails.spmDetailsList.get(0);
                            info.scheduleId = configData.Id;
                            info.lastModified = configData.LastModifiedDate.format();
                            info.period = configData.SVMXC__Period__c;
                            if( configData.SVMXC__Schedule_Days__c != null ) {
                                info.weekOn = configData.SVMXC__Schedule_Days__c.split( SPM_Consts.SEMICOLON );
                            }
                            if( configData.SVMXC__Day_to_Run__c != null ) {
                                info.dayToRun = Integer.valueOf( configData.SVMXC__Day_to_Run__c );
                            }
                            info.timeAt = configData.SVMXC__Run_At__c;
                            
                        } else {
                            SPM_ConfigurationDefinition.CalculationMethod calculationMethod = buildCalculationMethod( result, info.defaultCalculationMethodList, configData.SVMXC__Formula__c );
                            if( calculationMethod != null ) {
                                
                                calculationMethod.lastModifiedOn = configData.LastModifiedDate.format();
                                calculationMethod.recordId = configData.Id;
                                calculationMethod.name = configData.Name;
                                calculationMethod.isActive = configData.SVMXC__Active__c;
                                info.calculationMethodList.add( calculationMethod );
                            }    
                        }
                    }                                
                }
                SPM_Utilities.getInstance().populateConfigurationDetails( info.defaultCalculationMethodList , processInfo.processId);
            }
            result.spmProcessInfoList.add(info);
            result.message = SPM_Utilities.getInstance().buildString( response.messageList, SPM_Consts.LINE_BREAK );
        }

        catch( Exception ex ) {
            
            result.success = false;
            result.message = ex.getMessage();
        }
        
        System.debug( LoggingLevel.DEBUG, 'getSPMConfiguration() - exit; result: ' + result);
        
        return JSON.serialize( result );
    }
    
    /**
     * 
     */
    @RemoteAction
    global static Object getAllSPMProcess( String requestStr ) {
        
        Output result = new Output();
        
        SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().getAllSPMProcess();
        result.success = response.success;
        result.warning = response.warning;
        
        if( response.spmProcessDetailsList != null && !response.spmProcessDetailsList.isEmpty() ) {
            
            for( SPM_WrapperDef.SPM_ProcessDetails spmProcessDetails : response.spmProcessDetailsList ) {
                
                SPMProcessInfo spmProcessInfo = new SPMProcessInfo();
                
                spmProcessInfo.processId = spmProcessDetails.processId;
                spmProcessInfo.processName = spmProcessDetails.processName;
                spmProcessInfo.dashboardId = spmProcessDetails.dashboardId;
                spmProcessInfo.description = spmProcessDetails.description;
                spmProcessInfo.timezone = spmProcessDetails.timezone;
                spmProcessInfo.emailOnSuccess = spmProcessDetails.emailOnSuccess;
                spmProcessInfo.emailOnFailure = spmProcessDetails.emailOnFailure;
                spmProcessInfo.isActive = spmProcessDetails.isActive;
                
                result.spmProcessInfoList.add(spmProcessInfo);
            }    
        }
        
        response = SPM_Utilities.getInstance().getAllTimezones();
        result.timezoneList = response.timezoneList;
        result.message = SPM_Utilities.getInstance().buildString( response.messageList, SPM_Consts.LINE_BREAK );
        
        return JSON.serialize( result );
    }
    
    @RemoteAction
    global static Object deleteCalculationMethod( String requestStr ) {
        
        System.debug( LoggingLevel.DEBUG, requestStr );
        
        Output result = new Output();
        try {
            
            SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
            
            List<SPMProcessInfo> processInfoList = (List<SPMProcessInfo>) JSON.deserialize( requestStr, List<SPMProcessInfo>.class );
            for( SPMProcessInfo processInfo : processInfoList ) {
                
                SPM_WrapperDef.SPM_ProcessDetails spmProcessDetails = new SPM_WrapperDef.SPM_ProcessDetails();
                
                spmProcessDetails.processId = processInfo.processId;
                spmProcessDetails.processName = processInfo.processName;
                
                if( processInfo.calculationMethodList != null ) {                    
                    
                    for( SPM_ConfigurationDefinition.CalculationMethod calculationMethod : processInfo.calculationMethodList) {
                        
                        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();                        
                        configData.Id = calculationMethod.recordId;
                        spmProcessDetails.spmDetailsList.add(configData);
                    }    
                }
                
                request.spmProcessDetailsList.add( spmProcessDetails );
            }
            
            SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().deleteCalculationMethod( request );    
            result.success = response.success;
            result.message = SPM_Utilities.getInstance().buildString( response.messageList, SPM_Consts.LINE_BREAK );
        }
        
        catch( Exception ex ) {
            
            result.success = false;
            result.message = ex.getMessage();
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
        }
        
        return JSON.serialize( result );
    }
    /*
    @RemoteAction
    global static Object saveScheduleConfiguration( String requestStr ) {
        
        System.debug( LoggingLevel.DEBUG, 'Controller saveScheduleConfiguration() - enter; ' + requestStr );
        
        Output result = new Output();
        try {
            
            SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
            
            List<SPMProcessInfo> processInfoList = (List<SPMProcessInfo>) JSON.deserialize( requestStr, List<SPMProcessInfo>.class );
            RecordType spmDetailsRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name = 'SPM Details'];
            
            for( SPMProcessInfo processInfo : processInfoList ) {
                
                SPM_WrapperDef.SPM_ProcessDetails spmProcessDetails = new SPM_WrapperDef.SPM_ProcessDetails();
                
                spmProcessDetails.processId = processInfo.processId;
                spmProcessDetails.processName = processInfo.processName;
                spmProcessDetails.emailOnSuccess = processInfo.emailOnSuccess;
                spmProcessDetails.emailOnFailure = processInfo.emailOnFailure;
                
                if( processInfo.period != null && processInfo.weekOn != null && processInfo.timeAt != null ) {
                    
                    RecordType scheduleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name = 'Schedule'];
                    
                    SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
                    
                    if( processInfo.scheduleId != null ) {
                        scheduleData.Id = (Id) processInfo.scheduleId;    
                    }
                    
                    scheduleData.RecordTypeId = scheduleRecordType.Id;
                    scheduleData.SVMXC__Active__c = true;
                    scheduleData.SVMXC__Run_Type__c = 'Day of Week';                    
                    scheduleData.SVMXC__Period__c = processInfo.period;
                    if( processInfo.period == 'Daily' ) {
                        processInfo.weekOn = new String[] {'Monday','Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'};
                    }
                    scheduleData.SVMXC__Schedule_Days__c = SPM_Utilities.getInstance().buildString( processInfo.weekOn, SPM_Consts.SEMICOLON );
                    scheduleData.SVMXC__Run_At__c = processInfo.timeAt;
                    
                    spmProcessDetails.spmDetailsList.add(scheduleData);
                }
                
                spmProcessDetails.timezone = processInfo.timezone;                
                request.spmProcessDetailsList.add( spmProcessDetails );
            }
            
            SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().saveScheduleConfiguration( request );    
            result.success = response.success;
            result.message = SPM_Utilities.getInstance().buildString( response.messageList, SPM_Consts.LINE_BREAK );
        }
        catch( Exception ex ) {
            
            result.success = false;
            result.message = ex.getMessage();
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString());
        }
        return JSON.serialize( result );
    }
    */
    
    /**
     * 
     */
    @RemoteAction
    global static Object saveSPMConfiguration( String requestStr ) {
        
        System.debug( LoggingLevel.DEBUG, requestStr );
        
        Output result = new Output();
        try {
            
            SPM_WrapperDef.SPM_Request request = new SPM_WrapperDef.SPM_Request();
            
            List<SPMProcessInfo> processInfoList = (List<SPMProcessInfo>) JSON.deserialize( requestStr, List<SPMProcessInfo>.class );
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            RecordType spmDetailsRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name = 'SPM Details' LIMIT 1];
            
            for( SPMProcessInfo processInfo : processInfoList ) {
                
                SPM_WrapperDef.SPM_ProcessDetails spmProcessDetails = new SPM_WrapperDef.SPM_ProcessDetails();
                
                spmProcessDetails.processId = processInfo.processId;
                spmProcessDetails.processName = processInfo.processName;
                spmProcessDetails.timezone = processInfo.timezone;
                spmProcessDetails.emailOnSuccess = processInfo.emailOnSuccess;
                spmProcessDetails.emailOnFailure = processInfo.emailOnFailure;
                spmProcessDetails.isActive = processInfo.isActive;
                
                if( processInfo.calculationMethodList != null && !processInfo.calculationMethodList.isEmpty() ) {
                    
                    for( SPM_ConfigurationDefinition.CalculationMethod calculationMethod : processInfo.calculationMethodList) {
                        
                        if( calculationMethod.appliesTo == null ||  calculationMethod.appliesTo == '' ) {
                            
                            result.success = false;
                          result.message = System.label.SPM002_TAG065 + System.label.SPM003_TAG009;
                            break;
                        }
                        
                        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
                        configData.SVMXC__Formula__c = (String) JSON.serialize( calculationMethod );
                        configData.RecordTypeId = spmDetailsRecordType.Id;
                        configData.Id = calculationMethod.recordId;
                        configData.SVMXC__Active__c = calculationMethod.isActive;
                        spmProcessDetails.spmDetailsList.add(configData);
                    }    
                } else {
                    
                    if( processInfo.timezone == null || processInfo.timezone == '' ) {
                        
                        result.success = false;
                        result.message = System.label.SPM002_TAG065 + System.label.SPM003_TAG018;
                    } else if( processInfo.period == null ) {                        
                        result.success = false;
                        result.message = System.label.SPM002_TAG065 + System.label.SPM003_TAG017;
                    } else if( processInfo.period.equalsIgnoreCase('Weekly') && ( processInfo.weekOn == null || processInfo.weekOn.isEmpty() ) ) {                        
                        result.success = false;
                        result.message = System.label.SPM002_TAG065 + System.label.SPM003_TAG020;
                    } else if( processInfo.timeAt == null || processInfo.timeAt == '' ) {                        
                        result.success = false;
                        result.message = System.label.SPM002_TAG065 + System.label.SPM003_TAG019;
                    }
                    
                    if( result.success ) {
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        RecordType scheduleRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name = :SPM_Consts.SCHEDULE LIMIT 1];
                        SVMXC__ServiceMax_Config_Data__c scheduleData = new SVMXC__ServiceMax_Config_Data__c();
                        if( processInfo.scheduleId != null ) {
                            scheduleData.Id = (Id) processInfo.scheduleId;    
                        }
                        
                        scheduleData.RecordTypeId = scheduleRecordType.Id;
                        scheduleData.SVMXC__Active__c = true;
                        
                        scheduleData.SVMXC__Period__c = processInfo.period;
                        
                        if(scheduleData.SVMXC__Period__c.equalsIgnoreCase('Monthly')){
                            scheduleData.SVMXC__Run_Type__c = 'Date of Month';
                        }
                        else
                            scheduleData.SVMXC__Run_Type__c = 'Day of Week';
                        
                        scheduleData.SVMXC__Day_to_Run__c = String.valueOf(processInfo.dayToRun );
                        scheduleData.SVMXC__Schedule_Days__c = SPM_Utilities.getInstance().buildString( processInfo.weekOn, SPM_Consts.SEMICOLON );
                        scheduleData.SVMXC__Run_At__c = processInfo.timeAt;
                        
                        spmProcessDetails.spmDetailsList.add(scheduleData);    
                    }
                    
                }
                request.spmProcessDetailsList.add( spmProcessDetails );
            }
            
            if( result.success ) {
                
                SPM_WrapperDef.SPM_Response response = new SPM_ConfigurationImpl().saveSPMConfiguration( request );    
                result.success = response.success;
                
                for( SPM_WrapperDef.SPM_ProcessDetails processDetails : response.spmProcessDetailsList ) {
                    
                    for( SVMXC__ServiceMax_Config_Data__c configData : processDetails.spmDetailsList ) {
                        
                        SPM_ConfigurationDefinition.CalculationMethod calculationMethod = new SPM_ConfigurationDefinition.CalculationMethod();
                        calculationMethod.lastModifiedOn = System.now().format();
                        calculationMethod.recordId = configData.Id;
                        
                        SPMProcessInfo processInfo = new SPMProcessInfo(); //processInfoList.get(index);
                        processInfo.calculationMethodList.add( calculationMethod );
                        processInfo.processId = processDetails.processId;
                        processInfo.scheduleId = processDetails.scheduleId;
                        
                        result.spmProcessInfoList.add(processInfo);
                    }    
                }
                
                result.message = SPM_Utilities.getInstance().buildString( response.messageList, SPM_Consts.LINE_BREAK );                
            }
        }
        catch( Exception ex ) {
            result.success = false;
            result.message = ex.getMessage();
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString());
        }
        return JSON.serialize( result );
    }
    
    /**
     * TODO Comments
     */
    private static SPM_ConfigurationDefinition.CalculationMethod buildCalculationMethod( Output result, List<SPM_ConfigurationDefinition.CalculationMethod> calculationMethodList, String configurationJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'buildCalculationMethod() - enter');
        
        SPM_ConfigurationDefinition.CalculationMethod calculationMethod = null;
        
        try {
            SPM_ConfigurationDefinition.CalculationMethod configuredCalculationMethod = 
                (SPM_ConfigurationDefinition.CalculationMethod) JSON.deserialize( configurationJson, SPM_ConfigurationDefinition.CalculationMethod.class );
            
            for( SPM_ConfigurationDefinition.CalculationMethod defaultCalculationMethod : calculationMethodList ) {
                                
                if( configuredCalculationMethod.method == defaultCalculationMethod.method ) {
                    
                    String jsonDefaultCalculationMethod = JSON.serialize(defaultCalculationMethod);
                    calculationMethod = (SPM_ConfigurationDefinition.CalculationMethod) JSON.deserialize( jsonDefaultCalculationMethod, SPM_ConfigurationDefinition.CalculationMethod.class );
                    
                    System.debug( LoggingLevel.DEBUG, 'Default Calculation Method : ' + jsonDefaultCalculationMethod );
                    break;
                }
            }
            
            if( calculationMethod == null ) {
                
                System.debug( LoggingLevel.ERROR, 'Failed to retrieve default Calculation Method.' );
                return null;
            }
            
            if(  configuredCalculationMethod.sourceObjectName == null || 
               !configuredCalculationMethod.sourceObjectName.equalsIgnoreCase( calculationMethod.sourceObjectName ) ) {
                   
                   System.debug( LoggingLevel.ERROR, configuredCalculationMethod.sourceObjectName );
                   System.debug( LoggingLevel.ERROR, calculationMethod.sourceObjectName );
                   return null;
               }
            
            calculationMethod.name = configuredCalculationMethod.name;
            calculationMethod.recordId = configuredCalculationMethod.recordId;
            // TODO condition will be removed
            if( configuredCalculationMethod.method != null )
                calculationMethod.method = configuredCalculationMethod.method;
            
            calculationMethod.appliesTo = configuredCalculationMethod.appliesTo;
            calculationMethod.entryTypeForMTBF = configuredCalculationMethod.entryTypeForMTBF;
            calculationMethod.sourceObjectName = configuredCalculationMethod.sourceObjectName;
            
            SPM_Utilities.getInstance().populateSourceTargetLabelInfo( calculationMethod );
            
            for( SPM_ConfigurationDefinition.ParameterInfo configuredParameterInfo : configuredCalculationMethod.parameterInfoList ) {
                
                for( SPM_ConfigurationDefinition.ParameterInfo parameterInfo : calculationMethod.parameterInfoList ) {
                    
                    if( configuredParameterInfo.sourceObjectField == parameterInfo.sourceObjectField ) {
                        
                        parameterInfo.sourceFieldName = configuredParameterInfo.sourceFieldName;
                        parameterInfo.sourceFieldLabel = configuredParameterInfo.sourceFieldLabel;
                    }
                }
            }
            
            Integer objectMappingSize = configuredCalculationMethod.objectMappingDetailsList.size();
            for( Integer index = 0; index < objectMappingSize; index++ ) {
                
                SPM_ConfigurationDefinition.ObjectMappingDetails objectMappingDetails = configuredCalculationMethod.objectMappingDetailsList.get(index);
                calculationMethod.objectMappingDetailsList.get(index).mapId = objectMappingDetails.mapId;
            }
            
            Integer expressionDetailsSize = configuredCalculationMethod.expressionDetailsList.size();
            System.debug( LoggingLevel.DEBUG, 'Processing configured expressions ' + expressionDetailsSize );
            
            for( Integer index = 0; index < expressionDetailsSize; index++ ) {
                
                SPM_ConfigurationDefinition.ExpressionDetails expressionDetails = configuredCalculationMethod.expressionDetailsList.get(index);
                calculationMethod.expressionDetailsList.get(index).expressionRuleId = expressionDetails.expressionRuleId;
            }
        }
        catch(Exception ex) {
            // TODO
            result.success = false;
            result.message = 'Failed to retrieve SPM configuration.';
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'buildCalculationMethod() - exit');
        }
        
        return calculationMethod;
    }
    
        @RemoteAction
    global static string loadBusinessProcessConfiguration()
    {
        System.debug( LoggingLevel.DEBUG, 'loadBusinessProcessConfiguration() - enter');    
        SPM_ConfigurationDefinition.loadBusinessConfig newLoadConfig = new SPM_ConfigurationDefinition.loadBusinessConfig();
        Map<String,Schema.sObjectType> mapOfAllObjects = Schema.getGlobalDescribe();
        List<String> listOfObjects = new List<String>();
        listOfObjects.add(SPM_Consts.SERVICE_ORDER);
        listOfObjects.add(SPM_Consts.CASEOBJECT);
        listOfObjects.add(SPM_Consts.SERVICEREQUESTOBJECT); 
        Map<String,String> mapOfAccessibleObjects = new Map<String,String>();
        for(String objects:listOfObjects)
        {
            Schema.sObjectType newObjectType = mapOfAllObjects.get(objects);
            Schema.DescribesObjectResult newObjectResult = newObjectType.getDescribe();
            if(newObjectResult.isAccessible())
            {
                mapOfAccessibleObjects.put(newObjectResult.getLabel(),newObjectResult.getName());
            }            
        }

        List<SVMXC__ServiceMax_Config_Data__c> listOfData = SPM_ConfigurationDefinition.getBusinessProcessConfig();
        SPM_ConfigurationDefinition.businessProcessConfig newConfig = new SPM_ConfigurationDefinition.businessProcessConfig();
        if(!listOfData.isEmpty() && listOfData[0].SVMXC__Formula__c!=NULL)               
        {
            newConfig = (SPM_ConfigurationDefinition.businessProcessConfig) JSON.deserialize(listOfData[0].SVMXC__Formula__c,SPM_ConfigurationDefinition.businessProcessConfig.class);
            newLoadConfig.businessProcessConfig = newConfig;
        }
        if(newConfig !=NULL && newConfig.source!=NULL && newConfig.source!='SVMXC__Service_Order__c')
        {
            List<Schema.DescribeFieldResult> describeFieldResultList = SPM_Utilities.getInstance().getDescribeFieldResultList( newConfig.source );
            
            Map<String,String> fieldNameLabelMap = new Map<String,String>();
            for( Schema.DescribeFieldResult describeFieldResult : describeFieldResultList ) {
                fieldNameLabelMap.put( describeFieldResult.getName(), describeFieldResult.getLabel() );
            }  
            
            Map<String,SVMXC__ServiceMax_Config_Data__c> mapOfExpIdAndData = new Map<String,SVMXC__ServiceMax_Config_Data__c>();
            Map<String,List<SPM_ConfigurationDefinition.Expression>> mapOfExpIdAndItsRules = new Map<String,List<SPM_ConfigurationDefinition.Expression>>();
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            List<SVMXC__ServiceMax_Config_Data__c> listOfExpressionsData = [Select Id,SVMXC__Field_Name__c,SVMXC__Sequence__c,SVMXC__Operator__c,SVMXC__Operand__c,SVMXC__Expression_Rule__r.SVMXC__ProcessID__c,SVMXC__Expression_Rule__r.SVMXC__Name__c,SVMXC__Expression_Rule__r.SVMXC__Source_Object_Name__c,SVMXC__Expression_Rule__r.SVMXC__Advance_Expression__c From SVMXC__ServiceMax_Config_Data__c Where SVMXC__Expression_Rule__r.SVMXC__Source_Object_Name__c=:newConfig.source and SVMXC__Expression_Rule__r.RecordType.Name = 'SVMX Rule'];            
            System.debug('What is the output '+listOFExpressionsData);
            SPM_ConfigurationDefinition.ExpressionDetails newDetail = new SPM_ConfigurationDefinition.ExpressionDetails();
            for(SVMXC__ServiceMax_Config_Data__c newData:listOfExpressionsData)
            {
                SPM_ConfigurationDefinition.Expression newExpression = new SPM_ConfigurationDefinition.Expression();
                if(newData.SVMXC__Sequence__c !=NULL)
                {
                    newExpression.sequence = String.valueOf(Math.Round(newData.SVMXC__Sequence__c));
                }
                newExpression.operator = (SPM_Consts.OPERATOR_MAP.containsKey( newData.SVMXC__Operator__c ) ) ? SPM_Consts.OPERATOR_MAP.get(newData.SVMXC__Operator__c ) : newData.SVMXC__Operator__c;
                newExpression.value = newData.SVMXC__Operand__c;
                newExpression.field = ( fieldNameLabelMap.containsKey( newData.SVMXC__Field_Name__c ) ) ? fieldNameLabelMap.get( newData.SVMXC__Field_Name__c ) : newData.SVMXC__Field_Name__c; 
                //newData.SVMXC__Field_Name__c;
                List<SPM_ConfigurationDefinition.Expression> listOfExpressions = new List<SPM_ConfigurationDefinition.Expression>();
                if(mapOfExpIdAndItsRules.containsKey(newData.SVMXC__Expression_Rule__r.SVMXC__ProcessID__c))
                {
                    listOfExpressions = mapOfExpIdAndItsRules.get(newData.SVMXC__Expression_Rule__r.SVMXC__ProcessID__c);
                }
                listOfExpressions.add(newExpression);
                mapOfExpIdAndItsRules.put(newData.SVMXC__Expression_Rule__r.SVMXC__ProcessID__c,listOfExpressions);
                mapOfExpIdAndData.put(newData.SVMXC__Expression_Rule__r.SVMXC__ProcessID__c,newData);
            }
            
            for(String expId:mapOfExpIdAndData.keyset())
            {
                SPM_ConfigurationDefinition.ExpressionRule newRule = new SPM_ConfigurationDefinition.ExpressionRule();
                newRule.expressionRuleId = expId;
                newRule.expressionRuleName = mapOfExpIdAndData.get(expId).SVMXC__Expression_Rule__r.SVMXC__Name__c;
                newRule.advancedExpression=mapOfExpIdAndData.get(expId).SVMXC__Expression_Rule__r.SVMXC__Advance_Expression__c;
                newRule.expressionList.addAll(mapOfExpIdAndItsRules.get(expId));
                
                SPM_ConfigurationDefinition.ExpressionDetails newExpDetails = new SPM_ConfigurationDefinition.ExpressionDetails();                
                newExpDetails.label = expId;
                newExpDetails.expressionRuleId=expId;
                newExpDetails.sourceObjectName=mapOfExpIdAndData.get(expId).SVMXC__Expression_Rule__r.SVMXC__Source_Object_Name__c;
                newExpDetails.expressionRuleList.add(newRule);
                newLoadConfig.expressionDetail.add(newExpDetails);            
            }
        }
        newLoadConfig.sources = new Map<String,String>();
        newLoadConfig.sources.putAll(mapOfAccessibleObjects);
        String returnResponse = JSON.serialize(newLoadConfig);
        System.debug( LoggingLevel.DEBUG, 'loadBusinessProcessConfiguration() - exit');            
        return returnResponse;        
    }  
    
    @RemoteAction
    global static String loadExpressions(String jsonInput)
    {
        System.debug( LoggingLevel.DEBUG, 'loadExpressions() - enter');  
        
        System.debug( LoggingLevel.DEBUG, 'jsonInput - ' + jsonInput);
        SPM_ConfigurationDefinition.loadBusinessConfig newLoadConfig = new SPM_ConfigurationDefinition.loadBusinessConfig();    
        if(jsonInput != NULL && jsonInput != '') {
             List<Schema.DescribeFieldResult> describeFieldResultList = SPM_Utilities.getInstance().getDescribeFieldResultList( jsonInput );
            
            Map<String,String> fieldNameLabelMap = new Map<String,String>();
            for( Schema.DescribeFieldResult describeFieldResult : describeFieldResultList ) {
                fieldNameLabelMap.put( describeFieldResult.getName(), describeFieldResult.getLabel() );
            } 
            
            Map<String,SVMXC__ServiceMax_Config_Data__c> mapOfExpIdAndData = new Map<String,SVMXC__ServiceMax_Config_Data__c>();
            Map<String,List<SPM_ConfigurationDefinition.Expression>> mapOfExpIdAndItsRules = new Map<String,List<SPM_ConfigurationDefinition.Expression>>();
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            List<SVMXC__ServiceMax_Config_Data__c> listOfExpressionsData = [Select Id,SVMXC__Field_Name__c,SVMXC__Sequence__c,SVMXC__Operator__c,SVMXC__Operand__c,SVMXC__Expression_Rule__r.SVMXC__ProcessID__c,SVMXC__Expression_Rule__r.SVMXC__Name__c,SVMXC__Expression_Rule__r.SVMXC__Source_Object_Name__c,SVMXC__Expression_Rule__r.SVMXC__Advance_Expression__c From SVMXC__ServiceMax_Config_Data__c Where SVMXC__Expression_Rule__r.SVMXC__Source_Object_Name__c=:jsoninput and SVMXC__Expression_Rule__r.RecordType.Name = 'SVMX Rule'];            
            System.debug('What is the output '+listOFExpressionsData);
            SPM_ConfigurationDefinition.ExpressionDetails newDetail = new SPM_ConfigurationDefinition.ExpressionDetails();
            for(SVMXC__ServiceMax_Config_Data__c newData:listOfExpressionsData)
            {
                SPM_ConfigurationDefinition.Expression newExpression = new SPM_ConfigurationDefinition.Expression();
                //newExpression.sequence = String.valueOf(newData.SVMXC__Sequence__c);
                if(newData.SVMXC__Sequence__c !=NULL)
                {
                    newExpression.sequence = String.valueOf(Math.Round(newData.SVMXC__Sequence__c));
                }
                //newExpression.operator = newData.SVMXC__Operator__c;
                newExpression.operator = (SPM_Consts.OPERATOR_MAP.containsKey( newData.SVMXC__Operator__c ) ) ? SPM_Consts.OPERATOR_MAP.get(newData.SVMXC__Operator__c ) : newData.SVMXC__Operator__c;
                newExpression.value = newData.SVMXC__Operand__c;
                //newExpression.field = newData.SVMXC__Field_Name__c;
                newExpression.field = ( fieldNameLabelMap.containsKey( newData.SVMXC__Field_Name__c ) ) ? fieldNameLabelMap.get( newData.SVMXC__Field_Name__c ) : newData.SVMXC__Field_Name__c;
                
                List<SPM_ConfigurationDefinition.Expression> listOfExpressions = new List<SPM_ConfigurationDefinition.Expression>();
                if(mapOfExpIdAndItsRules.containsKey(newData.SVMXC__Expression_Rule__r.SVMXC__ProcessID__c))
                {
                    listOfExpressions = mapOfExpIdAndItsRules.get(newData.SVMXC__Expression_Rule__r.SVMXC__ProcessID__c);
                }
                listOfExpressions.add(newExpression);
                mapOfExpIdAndItsRules.put(newData.SVMXC__Expression_Rule__r.SVMXC__ProcessID__c,listOfExpressions);
                mapOfExpIdAndData.put(newData.SVMXC__Expression_Rule__r.SVMXC__ProcessID__c,newData);
            }
            
            for(String expId:mapOfExpIdAndData.keyset())
            {
                SPM_ConfigurationDefinition.ExpressionRule newRule = new SPM_ConfigurationDefinition.ExpressionRule();
                newRule.expressionRuleId = expId;
                newRule.expressionRuleName = mapOfExpIdAndData.get(expId).SVMXC__Expression_Rule__r.SVMXC__Name__c;
                newRule.advancedExpression=mapOfExpIdAndData.get(expId).SVMXC__Expression_Rule__r.SVMXC__Advance_Expression__c;
                newRule.expressionList.addAll(mapOfExpIdAndItsRules.get(expId));
                
                SPM_ConfigurationDefinition.ExpressionDetails newExpDetails = new SPM_ConfigurationDefinition.ExpressionDetails();                
                newExpDetails.label = expId;
                newExpDetails.expressionRuleId=expId;
                newExpDetails.sourceObjectName=mapOfExpIdAndData.get(expId).SVMXC__Expression_Rule__r.SVMXC__Source_Object_Name__c;
                newExpDetails.expressionRuleList.add(newRule);
                newLoadConfig.expressionDetail.add(newExpDetails);            
            } 
            Map<String,Schema.sObjectType> mapOfAllObjects = Schema.getGlobalDescribe();
            List<String> listOfObjects = new List<String>();
            listOfObjects.add(SPM_Consts.SERVICE_ORDER);
            listOfObjects.add(SPM_Consts.CASEOBJECT);
            listOfObjects.add(SPM_Consts.SERVICEREQUESTOBJECT); 
            Map<String,String> mapOfAccessibleObjects = new Map<String,String>();
            for(String objects:listOfObjects)
            {
                Schema.sObjectType newObjectType = mapOfAllObjects.get(objects);
                Schema.DescribesObjectResult newObjectResult = newObjectType.getDescribe();
                if(newObjectResult.isAccessible())
                {
                    mapOfAccessibleObjects.put(newObjectResult.getLabel(),newObjectResult.getName());
                }            
            }
            newLoadConfig.sources = new Map<String,String>();
            newLoadConfig.sources.putAll(mapOfAccessibleObjects);
            newLoadConfig.businessProcessConfig = new SPM_ConfigurationDefinition.businessProcessConfig();
            newLoadConfig.businessProcessConfig.source=jsonInput;                                           
        }
        String returnResponse = JSON.serialize(newLoadConfig);
        System.debug('Response - ' + returnResponse);
        System.debug( LoggingLevel.DEBUG, 'loadExpressions() - exit');                
        return returnResponse;         
    } 
    
    @RemoteAction
    global static void saveBusinessProcessConfiguration (String jsonInput) {  
        System.debug( LoggingLevel.DEBUG, 'SPM_Configuration.saveBusinessProcessConfiguration() - enter');            
        List<SVMXC__ServiceMax_Config_Data__c> listOfData =SPM_ConfigurationDefinition.getBusinessProcessConfig();
        System.debug( LoggingLevel.DEBUG, 'Json sent for saving - ' + jsonInput);
        if(jsonInput !=NULL) {
            System.debug( LoggingLevel.DEBUG, 'Existing Business Process Configuration - ' + listOfData);
            if(listOfData!=NULL && !listOfData.isEmpty()) {
                listOfData[0].SVMXC__Formula__c = jsonInput;
                //update listOfData;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(listOfData, COMM_SecurityUtils.Access.Updateable)) {
          update listOfData;
        } else {
          throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
        }
            }
            else {
                System.debug( LoggingLevel.DEBUG, 'Creating a new Business Process Configuration');
                Id spmRuleId,spmDetailId;
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA           
                for(RecordType newType:[Select Id,SobjectType From RecordType WHERE ((Name = 'SPM Details' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c') OR (Name='SPM Rule' AND SobjectType ='SVMXC__ServiceMax_Processes__c'))]) {
                    if(newType.sObjectType =='SVMXC__ServiceMax_Config_Data__c') {
                        spmDetailId=newType.Id;
                    } else {
                        spmRuleId=newType.Id;
                    }
                }            
            
                SVMXC__ServiceMax_Processes__c  newProcess = new SVMXC__ServiceMax_Processes__c();
                newProcess.SVMXC__Name__c='Business Process Config';
                newProcess.recordTypeId = spmRuleId;
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( newProcess, COMM_SecurityUtils.Access.Createable ) ) {
                    insert newProcess;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                SVMXC__ServiceMax_Config_Data__c newData = new SVMXC__ServiceMax_Config_Data__c();
                newData.SVMXC__Dispatch_Process__c = newProcess.Id;
                newData.SVMXC__Formula__c = jsonInput;
                newData.recordTypeId=spmDetailId;
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( newData, COMM_SecurityUtils.Access.Createable ) ) {
                    insert newData;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                //insert newData;
            }
        }
        System.debug( LoggingLevel.DEBUG, 'SPM_Configuration.saveBusinessProcessConfiguration() - exit');                    
    }
}