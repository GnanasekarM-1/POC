/*****************************************************************************
 *                       Copyright (C) 2016 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * Class for exposing Scheduling functionalities as web services for the UI
 * 
 *
 * @author Praveen, Divya, Somabha
 * @version 1.0
 * @since 2016
 */
global with sharing class SPM_Scheduling_Service {
    
    /**
     * Inner class which holds response structure.
     */
    public class Output {
        public Boolean success = true;
        public Boolean warning = false;
        public String message;
        public Object data;
        public Object processList;
        public Object availableHoursList;
        public Object productiveHoursList;
        public Output() {}
    }
    

    public SPM_Scheduling_Service(){}
    
    
    /**
     * [processLatestRun - Triggers compute utilization on the latest job run]
     * @param  requestStr        [user input - empty]
     * @return                   [message showing the status of job run]
     */
    @RemoteAction
    global static Object processLatestRun( String requestStr ) {
        
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Service.processLatestRun() - enter; requestStr: ' + requestStr );
        Output result = new Output();
        
        try {
            SPM_Scheduling_Action actionClass = new SPM_Scheduling_Action();
            result.message = actionClass.reportLatestRun();
            result.success = true;
            //result.message = 'Technician Utilization triggered on the latest Scheduling job run';
        } catch(Exception ex) {
            result.success = false;
            result.message = ex.getMessage();
            System.debug( LoggingLevel.ERROR, ex.getMessage());
        }
        
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Service.processLatestRun() - exit; response: ' + result );
        
        return JSON.serialize( result );
    }
    
    /**
     * [purgeLatestRun - Triggers purge on the latest job run. Related data is deleted from
     * job summary and technician utilization tables.]
     * @param  requestStr        [user input - empty]
     * @return                   [message showing the status of purge job]
     */
    @RemoteAction
    global static Object purgeLatestRun( String requestStr ) {
        
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Service.purgeLatestRun() - enter; requestStr: ' + requestStr );
        
        Output result = new Output();
        result.success = false;
        try {
            SPM_Scheduling_Action actionClass = new SPM_Scheduling_Action();
            result.message = actionClass.purgeLatestRun();
            result.success = true;
            //result.message = 'Purge triggered on the latest Scheduling job run';
        } catch(Exception ex) {
             result.success = false;
            result.message = ex.getMessage();
            System.debug( LoggingLevel.ERROR, ex.getMessage());
        }
        
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Service.purgeLatestRun() - exit; response: ' + result );
        
        return JSON.serialize( result );
    }
    
    /**
     * [getJobsList - Returns a list of jobs that satisfies the filter criteria 
     * specified in the user input]
     * @param  requestStr        [user input - json string that has details of startDate,
     * endDate and dispatchProcessName]
     * @return                   [list of jobs]
     */
    @RemoteAction
    global static Object getJobsList( String requestStr ) {
        
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Service.getJobsList() - enter; requestStr: ' + requestStr );
        
        String startDate ,endDate, processName ,tempText, isPurge;
        if(requestStr != null || requestStr != ''){
            JSONParser jsonParser = JSON.createParser(requestStr);
            while(jsonParser.nextToken()!=null){
                tempText = jsonParser.getText();
                
                if(tempText == 'startDate'){
                        jsonParser.nextToken();
                        startDate = jsonParser.getText();
                } else if(tempText == 'endDate'){
                        jsonParser.nextToken();
                        endDate = jsonParser.getText();
                } else if(tempText == 'processName'){
                        jsonParser.nextToken();
                        processName = jsonParser.getText();
                } else if(tempText == 'isPurge'){
                        jsonParser.nextToken();
                        isPurge = jsonParser.getText();
                }
            }
        }
        
        Output result = new Output();
        result.success = false;
         
        if(startDate != null && !String.isBlank(startDate)
           && endDate != null && !String.isBlank(endDate)
           && processName != null && !String.isBlank(processName)) {
           try {
               Date startDateValue = Date.valueOf(startDate);
               Date endDateValue = Date.valueOf(endDate);
               SPM_Scheduling_Action actionClass = new SPM_Scheduling_Action();
               List<Map<String, String>> jobsList = null;
            //   if(isPurge == 'true') {
            //       jobsList = actionClass.getJobsForPurging(startDateValue, endDateValue, processName);
            //   } else {
            //       jobsList = actionClass.getJobs(startDateValue, endDateValue, processName);
            //   }
               jobsList = actionClass.getJobs(startDateValue, endDateValue, processName);
               result.data = jobsList;
               result.success = true;
           } catch(Exception ex) {
                result.success = false;
        		result.message = ex.getMessage();
           }
        } else {
            result.success = true;
            result.message = System.label.SPM001_TAG025; //'Not all Parameters present for processing the action';
            
        }
			 
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Service.getJobsList() - exit; response: ' + result );
        
        return JSON.serialize( result );
    }
    
    /**
     * [loadDispatchProcessNames - Returns a list of dispatch process names]
     * @param  requestStr        [user input - empty]
     * @return                   [list of dispatch process names]
     */
    @RemoteAction
    global static Object loadDispatchProcessNames(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Service.loadDispatchProcessNames() - enter');
        Output result = new Output();
        
        try {
            SPM_Scheduling_Action actionClass = new SPM_Scheduling_Action();
            
            List<String> dispatchProcessNameList = actionClass.getDispatchProcessList();
           	result.data = dispatchProcessNameList;
            result.success = true;
            result.message = 'Loaded dispatch process names';
        } catch(Exception ex) {
            result.success = false;
            result.message = ex.getMessage();
            System.debug( LoggingLevel.ERROR, ex.getMessage());
        }
        
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Service.loadDispatchProcessNames() - exit; response: ' + result );
        
        return JSON.serialize( result );
    }

    /**
     * [reportSelectedRuns - Triggers compute utilization on the list of job id's in the request]
     * @param  requestStr        [user input - list of job id's]
     * @return                   [message showing status of compute utilzation on the selected jobs]
     */
    @RemoteAction
    global static Object reportSelectedRuns(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Service.reportSelectedRuns() - enter , input = '+requestStr);
        Output result = new Output();
        
        try {
            String tempText;
            if(requestStr != null || requestStr != ''){
                JSONParser jsonParser = JSON.createParser(requestStr);
                while(jsonParser.nextToken()!=null){
                    tempText = jsonParser.getText();
                    
                    if(tempText == 'jobsId'){
                        jsonParser.nextToken();
                        tempText = jsonParser.getText();
                        break;
                    }
                   
                }
        	} 
            //get jobs list from string
            System.debug(LoggingLevel.DEBUG,'start = '+tempText);
            List<String> jobsIdList = new List<String>();
			for(String jobId : tempText.split(','))
			{
				jobsIdList.add(jobId);
			}
            System.debug('jobsIdList = '+jobsIdList);
            SPM_Scheduling_Action actionClass = new SPM_Scheduling_Action();
            
            actionClass.reportSelectedRuns(jobsIdList) ;
           	
            result.success = true;
            result.message = System.label.SPM001_TAG026; //'Technician Utilization triggered on the Scheduling jobs';
        } catch(Exception ex) {
            result.success = false;
            result.message = ex.getMessage();
            System.debug( LoggingLevel.ERROR, ex.getMessage());
        }
        
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Service.reportSelectedRuns() - exit; response: ' + result );
        
        return JSON.serialize( result );
    }
    
    /**
     * [purgeSelectedRuns - Triggers purge data on the list of job id's in the request]
     * @param  requestStr        [user input - list of job id's]
     * @return                   [message showing status of purge data on the selected jobs]
     */
    @RemoteAction
    global static Object purgeSelectedRuns(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Service.purgeSelectedRuns() - enter , input = '+requestStr);
        Output result = new Output();
        
        try {
            String tempText;
            if(requestStr != null || requestStr != ''){
                JSONParser jsonParser = JSON.createParser(requestStr);
                while(jsonParser.nextToken()!=null){
                    tempText = jsonParser.getText();
                    
                    if(tempText == 'jobsId'){
                        jsonParser.nextToken();
                        tempText = jsonParser.getText();
                        break;
                    }
                   
                }
        	} 
            //get jobs list from string
            System.debug(LoggingLevel.DEBUG,'job list as string = '+tempText);
            List<String> jobsIdList = new List<String>();
			for(String jobId : tempText.split(','))
			{
				jobsIdList.add(jobId);
			}
            System.debug('jobsIdList = '+jobsIdList);
            SPM_Scheduling_Action actionClass = new SPM_Scheduling_Action();
            
            actionClass.purgeData(jobsIdList) ;
           	
            result.success = true;
            result.message = System.label.SPM001_TAG027; //'Purge triggered on the Scheduling jobs';
        } catch(Exception ex) {
            result.success = false;
            result.message = ex.getMessage();
            System.debug( LoggingLevel.ERROR, ex.getMessage());
        }
        
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Service.purgeSelectedRuns() - exit; response: ' + result );
        
        return JSON.serialize( result );
    }
    
    /**
     * [loadConfiguration - loads configuration specific data to display on the settings page]
     * @param  requestStr        [user input - empty]
     * @return                   [json string with configuration string, available hours list,
     * productive hours list and dispatch process names list]
     */
    @RemoteAction
    global static Object loadConfiguration(String requestStr)  {
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Service.loadConfiguration() - enter' );
        Output result = new Output();
        try {
            
            SPM_Scheduling_Action actionClass = new SPM_Scheduling_Action();
            
            String configData = actionClass.loadConfiguration() ;
           	List<String> dispatchProcessList = actionClass.getDispatchProcessList();
            List<String> eventTypeList= actionClass.getEventTypes();
            List<String> availableHoursList = new List<String>(eventTypeList);
            List<String> productiveHoursList = new List<String>(eventTypeList);
            
            productiveHoursList.add(SPM_Consts.DRIVE_TIME_ACTIVITY);
            Object configDataStr = null;
            if(String.isNotEmpty(configData)){
            	configDataStr = JSON.deserializeUntyped(configData);
            }
            result.data = configDataStr;
            result.success = true;
            result.processList = dispatchProcessList;
            result.productiveHoursList=productiveHoursList;
            result.availableHoursList=availableHoursList;
            
        } catch(Exception ex) {
            result.success = false;
            result.message = ex.getMessage();
            System.debug( LoggingLevel.ERROR, ex.getMessage());
        }
        
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Service.loadConfiguration() - exit; response: ' + result );
        
        return JSON.serialize( result );
    }
    
    /**
     * [saveConfiguration - triggers save configuration for the given input config json ]
     * @param  requestStr        [user input - configuration json]
     * @return                   [message showing status of save configuration]
     */
    @RemoteAction
    global static Object saveConfiguration(String requestStr)  {
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Service.saveConfiguration() - enter , requestStr=' +requestStr);
        Output result = new Output();
        
        try {
            
            if(requestStr != null || requestStr != ''){
              
                SPM_Scheduling_Action actionClass = new SPM_Scheduling_Action();
                String message = actionClass.saveConfiguration(requestStr);
                result.success = true;
                result.message = message;
            }
            else{
                result.success = false;
                result.message = 'Invalid input';
            }
        } catch(Exception ex) {
            result.success = false;
            result.message = ex.getMessage();
            System.debug( LoggingLevel.ERROR, ex.getMessage());
        }
        
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_Service.saveConfiguration() - exit; response: ' + result );
        
        return JSON.serialize( result );
    }
}