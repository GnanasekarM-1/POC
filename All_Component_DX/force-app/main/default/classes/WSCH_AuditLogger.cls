/**
    A simple logger class is used to abstract the events being logged to the object.
    The logger acts as a static reference, collecting the log messages in the current request scope,
    and writes them to the log object at the end of the computation.
    The basic operation of the logger is as a collector of log messages.
    The object is initialized when the request starts processing.
    During execution the API code calls log or error methods any number of times,
    which are stored in the static collection. When the operations complete,
    the logger saves a single entry with the details of all the log messages in a single record.
**/
public with sharing class WSCH_AuditLogger {

    /**
        This list contains all the logs logged during the transaction.
    **/
    public static Integer logSequence=1;
    public static List<String> logs = new List<String>();
    public static List<String> rcaLogs = new List<String>();
    
    public static Map<String,List<String>> logsMap = new Map<String,List<String>>();
    
    
    /**
        This list contains all the logs logged during the transaction.
    **/
    private static List<String> debugAheadlogs = new List<String>();

    /**
        Contain the logging level. Will be fetched from org settings.
        In Log settings it is string, at the time of initialization, will be converted to int.
    **/
    private static Integer logLevel;

    /**
        Maintains the debug logging levels
    **/
    private static Map<String,Integer> logLevelsMap = new Map<String,Integer> {'ERROR'=>1,'WARN'=>2,'INFO'=>3,'DEBUG'=>4,'RCA'=>5};
    
     private static Map<String,Integer> logContextMap = new Map<String,Integer> {'DEBUG'=>0,'RCA'=>1};

    /**
        Contains whether logging is enabled or not for this organization. Will be fetched from org settings.
    **/
    private static boolean isLogEnabled = false;

    /**
        Contains the default log level.
    **/
    private static String defaultLogLevel = 'info';

    /**
        Private Constructor to not allow instance creation of this class.
    **/
    private WSCH_AuditLogger() {}

    /**
     This field represents the Logger Level configured for the organization.
    **/
    private static String settingsLogLevel;
    
    /**
     * This field stores the Log Category of the Current Log.
     **/
    private static Integer logCategory =4;
   
    /**
     This field represents the context of the log. Whether it is a Work Order log or Non Work Order log.
    **/
    private static String strLogContext = '';

    /**
     This field represents the CPU Time of the log. Whether it is a Work Order log or Non Work Order log.
    **/
    private static Integer intApexCpuTime = 0;
    
    /**
     This field represents the API name of the log. Whether it is a Work Order log or Non Work Order log.
    **/
    private static String strAPIName = '';
    
    /**
     Boolean variable to check if error has occurred
    **/
    public static boolean isError = false;
    
    /**
     Variable to check if logging has been enabled for LinxMetrics
    **/
    public static boolean isLinxMetricLogEnabled = false;
    
    public static String strActiveProvider='OPTIMAXECO'; 
    
     private static boolean isRCALogEnabled = false;
     
     private static String dispatchProcess;
     private static String territory;
    
    /**
        Get the isLogEnabled status and logging level from Settings and initialise for this transaction.
    **/
    static {
        strActiveProvider = WSCH_CommonUtils.getActiveRealTimeOptimizationEngine();
        if(String.isNotBlank(strActiveProvider) && strActiveProvider.equals('SERVICEPOWER')){
            isLogEnabled = WSCH_CommonUtils.getSettingValue('DCON004', 'SET003') != NULL ? Boolean.valueOf(WSCH_CommonUtils.getSettingValue('DCON004', 'SET003')) : false;
           
            settingsLogLevel = WSCH_CommonUtils.getSettingValue('DCON004', 'SET004');           
        }else if(String.isNotBlank(strActiveProvider) && strActiveProvider.equals('OPTIMAXECO')){
            isLogEnabled = WSCH_CommonUtils.getSettingValue('OMAX004', 'SET001') != NULL ? Boolean.valueOf(WSCH_CommonUtils.getSettingValue('OMAX004', 'SET001')) : false;
            settingsLogLevel = WSCH_CommonUtils.getSettingValue('OMAX004', 'SET002');
        }
        
        if(settingsLogLevel == null) {
           settingsLogLevel = defaultLogLevel;
        }

        logLevel = logLevelsMap.get(settingsLogLevel.toUpperCase());
        
        isLinxMetricLogEnabled = isLinxMetricsEnabled();
        /*isLogEnabled = false;
        executeReturn();*/
    }
    
    /*public static void executeReturn() {
        return;
    }*/

    /**
        Add the message to the static log List<String>. Hence allowing one log for one transaction.
        Logging happens only when isLogEnabled is true and logging level is more than equal to info(3).
    **/
    public static void info(String message) {
        addLogMessage('INFO',message);
    }

    /**
        Add the message to the static log List<String>. Hence allowing one log for one transaction.
        Logging happens only when isLogEnabled is true and logging level is more than equal to error(1).
    **/
    public static void error(String message) {
        addLogMessage('ERROR',message);
    }

    /**
        Add the message to the static log List<String>. Hence allowing one log for one transaction.
        Logging happens only when isLogEnabled is true and logging level is more than equal to warn(2).
    **/
    public static void warn(String message) {
        addLogMessage('WARN',message);
    }

    /**
        Add the message to the static log List<String>. Hence allowing one log for one transaction.
        Logging happens only when isLogEnabled is true and logging level is more than equal to debug(4).
    **/
    public static void debug(String message) {
       addLogMessage('DEBUG',message);
    }

    public static void rca(String message) {
       addLogMessage('RCA',message);
    }

    /**
        Will clear all the messages logged as part of this transaction.
    **/
    public static void clear() {
        logs.clear();
        rcaLogs.clear();
    }

    /**
        Will clear all the messages logged as part of this transaction.
    **/
    public static void clearDebugAheadLogs() {
        debugAheadlogs.clear();
    }
    
    public static void finish() {
        system.debug('Invoking the Finish method of Logging :- '+System.isFuture());
        if (isLogEnabled) {
            if(!WSCH_AuditLogger.isError) {
                if(!Test.isRunningTest())
                    doLevelLogging();
            } else {
                if(!Test.isRunningTest())
                    doErrorLogging();
            }
        }
    }

    public static void doLevelLogging(){
        createLogs(logs,'DEBUG');
        createLogs(rcaLogs,'RCA');
        clear(); //Clear Logs
        clearDebugAheadLogs();  
        
        //SVMX_RCALoggingController be = new SVMX_RCALoggingController();
        //database.executeBatch(be,100);    
        
    }
    
    
        
     public static void doErrorLogging(){
        createLogs(debugAheadlogs,'DEBUG'); //DMl CAll
        createLogs(rcaLogs,'RCA');
        WSCH_AuditLogger.isError = false;
        clear();
        clearDebugAheadLogs();
    }
    
    
    public static void createLogs(List<String> debugLogs,String logCtxt) {
        Integer maxMessageLength = Schema.SObjectType.SVMXC__SVMX_Job_Logs__c.fields.SVMXC__Message__c.getLength();
        if(debugLogs.size() > 0) {
            String logString = String.join(debugLogs, '\n');
            while (logString.length() > maxMessageLength) {
                String splitedLogString = logString.subString(0, maxMessageLength);
                String logId = saveLogs(splitedLogString,logCtxt);
                logString = 'Continued from log Id ' + logId + '... ' + logString.subString(maxMessageLength);
            }
            //TODO convert this below method into futurecall method.
         saveLogs(logString,logCtxt);
 
    }
    }
 
     public static String saveLogs(String logMsg,String logCtxt) {

        SVMXC__SVMX_Job_Logs__c svmxLogs = new SVMXC__SVMX_Job_Logs__c();
        svmxLogs.SVMXC__Message__c = logMsg;
        svmxLogs.SVMXC__Log_level__c = logContextMap.get(logCtxt);
        svmxLogs.SVMXC__Log_Category__c =  logCtxt;
        svmxLogs.SVMXC__Log_Timestamp__c = DateTime.now();
        svmxLogs.SVMXC__Type__c='ServicePower';
        if(String.isNotBlank(strActiveProvider) && strActiveProvider.equals('OPTIMAXECO')){
            svmxLogs.SVMXC__Type__c='OptiMax';
        }
        svmxLogs.SVMXC__Log_Context__c = strLogContext;
        svmxLogs.SVMXC__Apex_CPU_Time__c = intApexCpuTime;
        svmxLogs.SVMXC__Operation__c = strAPIName;
        //TODO make callout instead of saving in svmx job logs.
        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(svmxLogs, COMM_SecurityUtils.Access.Createable)){     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            insert svmxLogs;
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
        }
        return svmxLogs.Id;
    }
    
     
    public static void insertJobLogs(List<SVMXC__SVMX_Job_Logs__c> jobLogsList ){
         if(COMM_SecurityUtils.getInstance().verifyFieldAccess(jobLogsList, COMM_SecurityUtils.Access.Createable)){     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            insert jobLogsList;
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
        }
    }

    /**
      This method would return the date formate required for the each logger message.
    **/
    public static String getLoggerDateTime(){
        String strDateTime;
        strDateTime = DateTime.now().format('dd/MM/yyyy hh:mm:ss.mmm');
        return strDateTime;
    }

    /**
      This method is used to add the log message to the List.
    **/
    public static void addLogMessage(String level , String logMessage) {
        /* Capturing the logs into debugAheadLogs which is used in case of exceptions */
        //debugAheadlogs.add('\n['+getLoggerDateTime() +'] ['+level+'] '+logMessage);
        debugAheadlogs.add('\n'+logMessage);
        if(level.equalsIgnoreCase('ERROR')) {
            WSCH_AuditLogger.isError = true;
        }
        if(isLogEnabled && level.equalsIgnoreCase('RCA')) {
           rcaLogs.add('\n'+logMessage);
            
        }else{
        if (isLogEnabled && logLevel >= logLevelsMap.get(level.toUpperCase())) {
            logs.add('\n'+logMessage);
            /**
            * Also, this method sets the category level for Log.
            * Highest Priority is given to ERROR.
            * The Order of priority is ERROR -> WARN -> INFO -> DEBUG.
            * The Default Log Category is DEBUG. If the Current Category is Higher than DEBUG,
            * the Log Category is Updated with the Current Log Category.
             **/
            if(logCategory >= logLevelsMap.get(level.toUpperCase())){
                logCategory = logLevelsMap.get(level.toUpperCase());
            }
        }
        }
        
        //RCA Functionality
       // List<String> logsList;
       // if(isLogEnabled){
       //   if(logsMap.containsKey(level)){
       //       logsList = logsMap.get(level);
       //   }else{
       //       logsList = new List<String>();
       //   }
       //   logsList.add(logMessage);
       //   logsMap.put(level,logsList);
       //   
        //}
        
    }
    /**
     * This method fetches the KEY from logLevelsMap as per the VALUE passed. 
     **/
    public Static String getLogCatMap(Integer intKey){
        String returnLogCat = 'DEBUG';
        for(String mapKey: logLevelsMap.KeySet()){
            if(intKey == logLevelsMap.get(mapKey))
                returnLogCat = mapKey.toUpperCase();
        }
        return returnLogCat;
    }
    /**
     * Method to set the LogContext variable
    **/
    public Static void setLogContext(String strLogCont){
        strLogContext = strLogCont;
    }
    /**
     * Method to set the Apex CPU Time variable
     **/
    public Static void setApexCPUTime(Integer intCPUTime){
        intApexCpuTime = intCPUTime;
    }
    
    /**
     * Method to set the API name
    **/
    public static void setAPIName(String strAPI) {
        strAPIName = strAPI;
    }
    
        /** 
     * Performance metrics collections implementation Starts.
     **/
     
     /**
        Map to hold the performance metrics collected with respect to each work order.
        Key of the map will be the work order name and values will be appended with growing log collected over time.
    **/
    private static Map<String,String> performanceMetricsMap = new Map<String,String>();
    
    public static Map<String,String> getPreformancMetricsMap(){
        return performanceMetricsMap;
    }
    
    public static void appendMetrics(String workOrderName, String metricsPrefix, Datetime timeMetric, Long timeInMillies) {
        
        if (!isLinxMetricLogEnabled){
            return;
        }
        
        //Initialise the metrics messages to be saved.
        String metrics = metricsPrefix + '_';
        
        //Check and append date and time or a Long in millies to the message
        if(timeMetric != null) {
            metrics = metricsPrefix + ' : "' + timeMetric.format('dd-MM-yyyy hh:mm:ss') + '"';
        } else if (timeInMillies != null) {
            metrics = metricsPrefix + ' : "' + String.valueOf(timeInMillies)+ '"';
        }
        
        //Check if for the work order already collection started append accordingly.
        if (performanceMetricsMap.containsKey(workOrderName)) {
            
            String existingMetrics =  performanceMetricsMap.get(workOrderName);
            existingMetrics = existingMetrics + ', ' + metrics;
            performanceMetricsMap.put(workOrderName,existingMetrics);
        } else {
            performanceMetricsMap.put(workOrderName,metrics);
        }
    }
    
     //Overloaded the method to include a string variable also in the metrics
    public static void appendMetrics(String workOrderName, String metricsPrefix, Datetime timeMetric, Long timeInMillies,String strValue) {
        if (!isLinxMetricLogEnabled){
            return;
        }
        
        //Initialise the metrics messages to be saved.
        String metrics = metricsPrefix + '_';
        
        //Check and append date and time or a Long in millies to the message
        if(timeMetric != null) {
            metrics = metricsPrefix + ' : "' + String.valueOf(timeMetric) + '"';
        } else if (timeInMillies != null) {
            metrics = metricsPrefix + ' : "' + String.valueOf(timeInMillies)+ '"';
        }else if (strValue != null){
            metrics = metricsPrefix + ' : "' +strValue+ '"';
        }
        
        //Check if for the work order already collection started append accordingly.
        if (performanceMetricsMap.containsKey(workOrderName)) {
            
            String existingMetrics =  performanceMetricsMap.get(workOrderName);
            existingMetrics = existingMetrics + ', ' + metrics;
            performanceMetricsMap.put(workOrderName,existingMetrics);
        } else {
            performanceMetricsMap.put(workOrderName,metrics);
        }
    }
    
    
    
    public static void savePerformanceMetricsForECO(){
        debug('savePerformanceMetricsForECO'+performanceMetricsMap);
        if (performanceMetricsMap.isEmpty()) {
            return;
        }
        WSCH_AuditLogger.debug('savePerformanceMetricsForECO::isLinxMetricLogEnabled - ' + isLinxMetricLogEnabled);
        if(!isLinxMetricLogEnabled){
            return;
        }
        
        List<SVMXC__SVMX_Job_Logs__c> toBeUpsertedLogs = new List<SVMXC__SVMX_Job_Logs__c>();
      
        //Add new metrics
        String metricMsg;
        for (String woName : performanceMetricsMap.keySet()) {
            SVMXC__SVMX_Job_Logs__c svmxLogs = new SVMXC__SVMX_Job_Logs__c();
            svmxLogs.SVMXC__Type__c='ECOPerformanceMetrics';
            svmxLogs.SVMXC__Log_Context__c = woName;
            svmxLogs.SVMXC__Log_Timestamp__c = DateTime.now();
            metricMsg = performanceMetricsMap.get(woName);
            svmxLogs.SVMXC__Message__c = metricMsg;
            svmxLogs.SVMXC__Client_Version__c = metricMsg.split(',').get(3).split(':',2).get(1).remove('"');
            //svmxLogs.SVMXC__Event_Name__c = metricMsg.split(',').get(4).split(':',2).get(1).remove('"');
            toBeUpsertedLogs.add(svmxLogs);
        }
        
        //upsert all the logs.
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( toBeUpsertedLogs, COMM_SecurityUtils.Access.Upsertable) ) {     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            upsert toBeUpsertedLogs;
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
        }
        
    }
    
     public static void saveECORequestJson(String requestJSON){
         debug('saveECORequestJson request :- '+requestJSON);
         String requestJ = requestJSON;
        String dpId = extractDispatchProcessFromRequestJson(requestJ);
        List<SVMXC__SVMX_Job_Logs__c> toBeUpsertedLogs = new List<SVMXC__SVMX_Job_Logs__c>();
        SVMXC__SVMX_Job_Logs__c svmxLogs;
        
        Integer maxMessageLength = Schema.SObjectType.SVMXC__SVMX_Job_Logs__c.fields.SVMXC__Message__c.getLength();
        debug('saveECORequestJson maxMessageLength :- '+maxMessageLength);
        List<String> splitRequestJsonList = new List<String>();
        String splitLogString;
        if(requestJ.length() > maxMessageLength){
         while (requestJ.length() > maxMessageLength) {
            splitLogString = requestJ.subString(0, maxMessageLength);
            splitRequestJsonList.add(splitLogString);
         }
        }else{
            debug('One Log is sufficient');
            splitRequestJsonList.add(requestJ);
        }
         
         debug('saveECORequestJson maxMessageLength :- '+splitRequestJsonList.size());
         
        list<aggregateResult> aggResults = [SELECT MAX(SVMXC__Client_Version__c)maxIteration FROM SVMXC__SVMX_Job_Logs__c WHERE SVMXC__Event_Name__c = :dpId AND SVMXC__Type__c='ECORequestJson'];      //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        Object msg = aggResults[0].get('maxIteration');
        Integer msgint = 1; 
        if(msg != null){
            msgint = (Integer.valueOf(msg)) +1; 
        }
        
        
         debug('saveECORequestJson msgint :- '+msgint);
    
         for(String splitJson : splitRequestJsonList){
             svmxLogs = new SVMXC__SVMX_Job_Logs__c();
             svmxLogs.SVMXC__Type__c='ECORequestJson';
             svmxLogs.SVMXC__Event_Name__c = dpId;
             svmxLogs.SVMXC__Client_Version__c = String.valueOf(msgint);
             svmxLogs.SVMXC__Message__c = splitJson;
             toBeUpsertedLogs.add(svmxLogs);
         }
        
        //upsert all the logs.
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( toBeUpsertedLogs, COMM_SecurityUtils.Access.Upsertable) ) {     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            upsert toBeUpsertedLogs;
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
        }
        
    }
    
    private static String extractDispatchProcessFromRequestJson(String requestJson){
     String dpId;
     WSCH_Provider_ECO_Stubs.ManageWorkOrderRequest_WP manageWoRequest = (WSCH_Provider_ECO_Stubs.ManageWorkOrderRequest_WP)JSON.deserialize(requestJson, WSCH_Provider_ECO_Stubs.ManageWorkOrderRequest_WP.class);   
     dpId = manageWoRequest.dispatchProcessId;
     debug('extractDispatchProcessFromRequestJson dpId '+dpId);
     return dpId;
    }
    
    
    
     public static void savePerformanceMetrics(){
        
        if (performanceMetricsMap.isEmpty()) {
            return;
        }
        
        WSCH_AuditLogger.debug('savePerformanceMetrics::isLinxMetricLogEnabled - ' + isLinxMetricLogEnabled);
        if(!isLinxMetricLogEnabled){
            return;
        }
        
        List<SVMXC__SVMX_Job_Logs__c> toBeUpsertedLogs = new List<SVMXC__SVMX_Job_Logs__c>();
        Set<String> metricsForWos = performanceMetricsMap.keySet();
        List<SVMXC__SVMX_Job_Logs__c> collectedWOLogs = [SELECT Id,SVMXC__Log_Context__c,SVMXC__Message__c from SVMXC__SVMX_Job_Logs__c WHERE SVMXC__Type__c = 'PerformanceMetrics' AND SVMXC__Log_Context__c IN :metricsForWos];       //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        //Append to existing metrics
        for (SVMXC__SVMX_Job_Logs__c svmxLog : collectedWOLogs) {
            svmxLog.SVMXC__Message__c = svmxLog.SVMXC__Message__c + ', ' + performanceMetricsMap.remove(svmxLog.SVMXC__Log_Context__c);
            toBeUpsertedLogs.add(svmxLog);
        }
        
        //Add new metrics
        for (String woName : performanceMetricsMap.keySet()) {
            SVMXC__SVMX_Job_Logs__c svmxLogs = new SVMXC__SVMX_Job_Logs__c();
            svmxLogs.SVMXC__Type__c='PerformanceMetrics';
            svmxLogs.SVMXC__Log_Context__c = woName;
            svmxLogs.SVMXC__Log_Timestamp__c = DateTime.now();
            svmxLogs.SVMXC__Message__c = performanceMetricsMap.get(woName);
            toBeUpsertedLogs.add(svmxLogs);
        }
        
        //upsert all the logs.
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( toBeUpsertedLogs, COMM_SecurityUtils.Access.Upsertable) ) {     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            upsert toBeUpsertedLogs;
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
        }
        
    }
    
    public static void initPerfomanceMetrics(){
        performanceMetricsMap.clear();
    }
    
    public static boolean isLinxMetricsEnabled() {
        boolean isEnabled = WSCH_CommonUtils.getSettingValue('DCON004', 'SET021') != NULL ? Boolean.valueOf(WSCH_CommonUtils.getSettingValue('DCON004', 'SET021')) : false;
        //boolean isEnabled = WSCH_CommonUtils.getSettingValue('DCON004', 'SET00444') != NULL ? Boolean.valueOf(WSCH_CommonUtils.getSettingValue('DCON004', 'SET00444')) : false;
        //WSCH_AuditLogger.debug('isLinxMetricsEnabled - ' + WSCH_CommonUtils.getSettingValue('DCON004', 'SET021'));
        return isEnabled;
    }

   
    
   /** 
     * Performance metrics collections implementation Ends.
     **/ 

    public static void setLogEnabled(boolean logEnabled){
        isLogEnabled =logEnabled;
    }
    
    
    public static void logGovernerLimits(String msg){
      List<String> rcaEntriesItems=new List<String>();
      List<String> governerLimitsStr = new List<String>();
      governerLimitsStr.add('Lets check the Governer Limits  :- '+msg);
      governerLimitsStr.add('Queries in Limit :-   '+Limits.getQueries());
      governerLimitsStr.add('Heap Size :- Consumed:   '+Limits.getHeapSize()+'  ; Limit:   '+Limits.getLimitHeapSize());
      governerLimitsStr.add('CPU time :- Consumed:    '+Limits.getCpuTime()+'  ; Limit:   '+Limits.getLimitCpuTime());
      String governerLimitMsg=String.join(governerLimitsStr,'\n');
      addLogMessage('RCA',governerLimitMsg);
    
    }

    
    public static String fetchTeritoryName(String territoryID){
    String teritoryName;
     List<SVMXC__Territory__c> territories = [Select Id,name From SVMXC__Territory__c where Id = : territoryID];
     if(null!=territories && territories.size()>0){
        teritoryName = territories.get(0).name;
     }
      return teritoryName;
    
    }
    
    
    public static String fetchDispatchProcessName(String dpID){
    List<SVMXC__ServiceMax_Processes__c> dispatchProcesses = [SELECT Id, SVMXC__Name__c FROM SVMXC__ServiceMax_Processes__c   where  SVMXC__Record_Type_Name__c='Dispatch Process' and id =: dpID ];
    String dispatchProcessName ;
    if(dispatchProcesses!=null && dispatchProcesses.size()>0 ){
        dispatchProcessName= dispatchProcesses.get(0).SVMXC__Name__c;
            }
    return  dispatchProcessName;
    }
    
}