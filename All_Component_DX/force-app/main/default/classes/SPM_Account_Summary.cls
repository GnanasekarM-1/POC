/*****************************************************************************
 *                       Copyright (C) 2016 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/
//FLS and CRUD check is not required as this class is running in batch mode
/**
 * This class is used to generate the Summary metrics for all the flows.
 * 
 *
 * @author Praveen.R
 * @version 1.0
 * @since 2016
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Praveen.R           26 Jul 2016     Created.
 *              Soumyaranjan Pati   6th Dec 2017    Added Trending setting and changes the logic to take latest record
 *****************************************************************************************************/
global with sharing class SPM_Account_Summary extends SPM_AbstractBatch {
    
     /**
      * Reference to the schedule configuration object.
      */
    public SVMXC__ServiceMax_Config_Data__c scheduleConfigData;
    
    /**
     * Holds the reference to the configuration Map.
     **/
    private Map<String, String> configurationsMap = new Map<String, String>();
    
    /**
     * Holds the reference to the total count of records.
     **/
    private Integer totalRecordsProcessedCount = 0;
    
    /**
     * Constructor for initializing the Schedule information for this report.
     */
    global SPM_Account_Summary( SVMXC__ServiceMax_Config_Data__c scheduleData ) {
        super(SPM_Schema.Report.AccountSummary, scheduleData);  
        this.scheduleConfigData = scheduleData;
    }
    
   /**
     * Initializes all the configuration associated with the passed in process.
     * 
     * @param processId - Id of the Process Record
     */
    private void initConfigurationMap(String processId) {
        System.debug( LoggingLevel.DEBUG, 'SPM_Account_Summary.initConfigurationMap() - enter - '+processId );

        List<SVMXC__ServiceMax_Config_Data__c> configurations = [select Name, SVMXC__Formula__c from SVMXC__ServiceMax_Config_Data__c 
                                                                    where SVMXC__Dispatch_Process__c = :processId and RecordType.Name != 'Schedule'];
                                                                    
        System.debug( LoggingLevel.DEBUG,'loaded processes - ' + configurations);
        configurationsMap.clear(); // Clear the existing configurations and re-populate it.
        
        String description = '';
        for(SVMXC__ServiceMax_Config_Data__c config: configurations) {
           String formula = config.SVMXC__Formula__c;
           if(!String.isEmpty(formula)) {
               JSONParser parser = JSON.createParser(formula);
               while (parser.nextToken() != null) {
                   if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'appliesTo')) {
                       
                       parser.nextToken(); //Get the value.
                       description = parser.getText();
                       configurationsMap.put(config.Name, description);
                   }
               }
           }
       }
       System.debug( LoggingLevel.DEBUG,'configurations loaded - ' + configurationsMap);
       System.debug( LoggingLevel.DEBUG, 'SPM_Account_Summary.initConfigurationMap() - exit' );
    }
    
    /**
     * Loads the list of processes of type 'SPM Rule' from the Process Table. We will ignore the 
     * tech-Utilization report as it is at the organization level and not account level.
     */ 
    global override void initBatchConfiguration() {
        System.debug( LoggingLevel.DEBUG, 'SPM_Account_Summary.initBatchConfiguration() - enter' );
        String entryCriteria = 'SVMXC__Record_Type_Name__c = \'SPM Rule\' and SVMXC__ProcessID__c != \'Utilization\'and SVMXC__ProcessID__c != \'AccountSummary\'';
        setWhereClause( entryCriteria );
        System.debug( LoggingLevel.DEBUG, 'SPM_Account_Summary.initBatchConfiguration() - exit' );
    }
    
    /**
     * Construct the where clause for loading the older data.
     * 
     * @param  includeLastModifiedDate - If true then we will consider only those records that were modified from previous run.
     * @return                         - Where Clause
     */
    private String createWhereClause(Boolean includeLastModifiedDate) {
        System.debug( LoggingLevel.DEBUG, 'createWhereClause() - enter' );
        
        Integer numberOfDays = getNumberOfDaysToQualifyRecords();
        if( numberOfDays == null ) numberOfDays = 60;
        
        Datetime previousExecution = System.now().addDays( (numberOfDays * -1) );
        String entryCriteria = 'CreatedDate >= ' + previousExecution.formatGmt( SPM_Consts.DEFAULT_DATETIME_FORMAT );
        
        if(includeLastModifiedDate) {
            if( scheduleData != null && scheduleData.SVMXC__Previous_Execution_Completed_On__c != null ) {
                previousExecution = scheduleData.SVMXC__Previous_Execution_Completed_On__c;
                System.debug( LoggingLevel.DEBUG, 'previousExecution - ' + previousExecution);
                entryCriteria = entryCriteria + ' AND LastModifiedDate >= ' + previousExecution.formatGmt( SPM_Consts.DEFAULT_DATETIME_FORMAT_AM_PM );
            }
        }
        
        setWhereClause( entryCriteria );
        System.debug( LoggingLevel.DEBUG, 'Entry Criteria - '+ entryCriteria );
        System.debug( LoggingLevel.DEBUG, 'createWhereClause() - exit' );
        return entryCriteria;
    }
    
    /**
     * Computes the Account Summary Information from MTTC Table.
     * 
     * @return - Computed summary map 
     */
    public Map<String, SVMXC__SPM_Account_Summary__c> populateMTTCSummary() {
        System.debug( LoggingLevel.DEBUG, 'SPM_Account_Summary.populateMTTCSummary() - enter; records' );
        String selectQuery = 'select SVMXC__Service_Delivered_On__c, SVMXC__Account__c, count(id) recordCount, sum(SVMXC__Completion_Time__c) totalMinutes, SVMXC__Configuration_Name__c, SVMXC__Calculation_Method__c FROM SVMXC__SPM_Mean_Time_To_Complete__c';
        String whereClause = ' where ' + createWhereClause(true);
        String groupByClause = ' group by SVMXC__Configuration_Name__c, SVMXC__Calculation_Method__c, SVMXC__Account__c, SVMXC__Service_Delivered_On__c';
        String orderByClause = ' order by SVMXC__Service_Delivered_On__c';
        
        String finalQuery = selectQuery + whereClause + groupByClause + orderByClause;
        
        System.debug( LoggingLevel.DEBUG, 'Query - ' + finalQuery);
        
        
        SVMXC__SPM_Account_Summary__c summaryRecord;
        Map<String, SVMXC__SPM_Account_Summary__c> summaryMap = new Map<String, SVMXC__SPM_Account_Summary__c>();
        
        Set<String> accountIds = new Set<String>();
        Set<Date> dates = new Set<Date>();
        Set<Date> fixedOnDates = new Set<Date>();
        Set<String> configurationNames = new Set<String>();
        
        List<SObject> records = Database.query(finalQuery);
        totalRecordsProcessedCount += records.size();
        addInfo( 'Total Processed Records : ' + records.size() );
        for(SObject currentRecord : records) {  
            System.debug( LoggingLevel.DEBUG,'Record - '+currentRecord);
            String accountId = (String)currentRecord.get('SVMXC__Account__c');
            String configurationName = (String)currentRecord.get('SVMXC__Configuration_Name__c');
            Date beginDate = SPM_Utilities.getInstance().getBeginDateOfMonth((Date)currentRecord.get('SVMXC__Service_Delivered_On__c'));
            Date endDate = SPM_Utilities.getInstance().getEndDateOfMonth((Date)currentRecord.get('SVMXC__Service_Delivered_On__c'));
            Integer recordCount = Integer.valueOf(currentRecord.get('recordCount'));
            //Update the set with the loaded data.
            accountIds.add(accountId);
            dates.add(beginDate);
            configurationNames.add(configurationName);
            
            //generate a map with the key as accountId-startDate-configurationName
            String key = SPM_Utilities.getInstance().createNewSummaryKey(accountId, beginDate.format(), configurationName);
            if(summaryMap.containsKey(key)) {
                summaryRecord = summaryMap.get(key);
                summaryRecord.SVMXC__Total_Record_Count__c = summaryRecord.SVMXC__Total_Record_Count__c + recordCount;
                summaryRecord.SVMXC__Value__c = summaryRecord.SVMXC__Value__c + Integer.valueOf(currentRecord.get('totalMinutes'));
                summaryRecord.SVMXC__Metric_Value__c = summaryRecord.SVMXC__Value__c / summaryRecord.SVMXC__Total_Record_Count__c;
            } else {
                String description = configurationsMap.get(configurationName); 
                summaryRecord = SPM_Utilities.getInstance().createSummaryRecord(accountId, configurationName, (String)currentRecord.get('SVMXC__Calculation_Method__c'), description, beginDate, endDate, System.Label.SPM004_TAG002, recordCount);
                summaryRecord.SVMXC__Value__c = Integer.valueOf(currentRecord.get('totalMinutes'));
                summaryRecord.SVMXC__Metric_Value__c = summaryRecord.SVMXC__Value__c / recordCount;
            }
            summaryMap.put(key, summaryRecord);
        }
        addInfo( 'Total Summary Records : ' + summaryMap.size() );
        SPM_Utilities.getInstance().mergeBatchWithExistingSummary(accountIds, dates, configurationNames, summaryMap, true);
        System.debug( LoggingLevel.DEBUG, 'populateMTTCSummary - Summary Map ' + summaryMap);
        return summaryMap;
    }
    
    /**
     * Computes the Account Summary Information from ART Table.
     * 
     * @return - Computed summary map 
     */
    public Map<String, SVMXC__SPM_Account_Summary__c> populateARTSummary() {
        System.debug( LoggingLevel.DEBUG, 'SPM_Account_Summary.populateARTSummary() - enter; records' );
        String selectQuery = 'select SVMXC__Service_Delivered_On__c, SVMXC__Account__c, count(id) recordCount,'+ 
                             'sum(SVMXC__Actual_Initial_Response_Time__c) initialResponse, sum(SVMXC__Actual_Onsite_Response_Time__c) onsiteResponse,'+ 
                             'sum(SVMXC__Actual_Resolution_Time__c) resolutionTime,sum(SVMXC__Actual_Restoration_Time__c) restorationTime,'+
                             'SVMXC__Configuration_Name__c, SVMXC__Calculation_Method__c FROM SVMXC__SPM_Average_Response_Time__c';
        String whereClause = ' where ' + createWhereClause(true);
        // String whereClause = ' ';
        String groupByClause = ' group by SVMXC__Configuration_Name__c, SVMXC__Calculation_Method__c, SVMXC__Account__c, SVMXC__Service_Delivered_On__c';
        String orderByClause = ' order by SVMXC__Service_Delivered_On__c';
        
        String finalQuery = selectQuery + whereClause + groupByClause + orderByClause;
        
        System.debug( LoggingLevel.DEBUG, 'Query - ' + finalQuery);
        
        
        SVMXC__SPM_Account_Summary__c summaryRecord;
        Map<String, SVMXC__SPM_Account_Summary__c> summaryMap = new Map<String, SVMXC__SPM_Account_Summary__c>();
        
        Set<String> accountIds = new Set<String>();
        Set<Date> dates = new Set<Date>();
        Set<Date> fixedOnDates = new Set<Date>();
        Set<String> configurationNames = new Set<String>();
        
        String initialResponse = 'Initial Response Time';
        String onsiteResponse = 'Onsite Response Time';
        String resolutionTime = 'Resolution Time';
        String restorationTime = 'Restoration Time';
    
        String configuration1 = '';
        String configuration2 = '';
        String configuration3 = '';
        String configuration4 = '';
    
        List<SObject> records = Database.query(finalQuery);
        totalRecordsProcessedCount += records.size();
        addInfo( 'Total Processed Records : ' + records.size() );
        for(SObject currentRecord : records) {  
            System.debug( LoggingLevel.DEBUG,'Record - '+currentRecord);
            String accountId = (String)currentRecord.get('SVMXC__Account__c');
            String configurationName = (String)currentRecord.get('SVMXC__Configuration_Name__c');
            String description = configurationsMap.get(configurationName); 
            Date beginDate = SPM_Utilities.getInstance().getBeginDateOfMonth((Date)currentRecord.get('SVMXC__Service_Delivered_On__c'));
            Date endDate = SPM_Utilities.getInstance().getEndDateOfMonth((Date)currentRecord.get('SVMXC__Service_Delivered_On__c'));
            Integer recordCount = Integer.valueOf(currentRecord.get('recordCount'));
            //Update the set with the loaded data.
            accountIds.add(accountId);
            dates.add(beginDate);
            
            configuration1 = configurationName + '$'+ initialResponse;
            configuration2 = configurationName + '$'+ onsiteResponse;
            configuration3 = configurationName + '$'+ resolutionTime;
            configuration4 = configurationName + '$'+ restorationTime;
            configurationNames.add(configuration1);
            configurationNames.add(configuration2);
            configurationNames.add(configuration3);
            configurationNames.add(configuration4);
            
            
            populateARTIndividualSummary(accountId, configuration1, (String)currentRecord.get('SVMXC__Calculation_Method__c'), 
                                        description, beginDate, endDate, System.Label.SPM004_TAG002, (Decimal)currentRecord.get('initialResponse'), recordCount, summaryMap);
            populateARTIndividualSummary(accountId, configuration2, (String)currentRecord.get('SVMXC__Calculation_Method__c'), 
                                        description, beginDate, endDate, System.Label.SPM004_TAG002, (Decimal)currentRecord.get('onsiteResponse'), recordCount, summaryMap);
            populateARTIndividualSummary(accountId, configuration3, (String)currentRecord.get('SVMXC__Calculation_Method__c'), 
                                        description, beginDate, endDate, System.Label.SPM004_TAG002, (Decimal)currentRecord.get('resolutionTime'), recordCount, summaryMap);
            populateARTIndividualSummary(accountId, configuration4, (String)currentRecord.get('SVMXC__Calculation_Method__c'), 
                                        description, beginDate, endDate, System.Label.SPM004_TAG002, (Decimal)currentRecord.get('restorationTime'), recordCount, summaryMap);
            
            
        }
        addInfo( 'Total Summary Records : ' + summaryMap.size() );
        SPM_Utilities.getInstance().mergeBatchWithExistingSummary(accountIds, dates, configurationNames, summaryMap, true);
        System.debug( LoggingLevel.DEBUG, 'populateARTSummary - Summary Map ' + summaryMap);
        return summaryMap;
    }
    
    /**
     * Populates the Account Summary Information for each response type.
     * 
     * @return - Computed summary map 
     */
    private void populateARTIndividualSummary(String accountId, String configurationName, String calculationMethod, String description, Date beginDate, 
                                Date endDate, String unit, Decimal value, Integer recordCount, Map<String, SVMXC__SPM_Account_Summary__c> summaryMap) {
        
        System.debug( LoggingLevel.DEBUG,'value being set - ' + value);
        
        //If there is no reading for a response type then we don't make an entry in the summary table.
        if(value == null)  {
            return;
        }
        
        String key = SPM_Utilities.getInstance().createNewSummaryKey(accountId, beginDate.format(), configurationName);
        SVMXC__SPM_Account_Summary__c summaryRecord;
            if(summaryMap.containsKey(key)) {
                summaryRecord = summaryMap.get(key);
                summaryRecord.SVMXC__Total_Record_Count__c = summaryRecord.SVMXC__Total_Record_Count__c + recordCount;
                summaryRecord.SVMXC__Value__c = summaryRecord.SVMXC__Value__c + value;
                summaryRecord.SVMXC__Metric_Value__c = summaryRecord.SVMXC__Value__c / summaryRecord.SVMXC__Total_Record_Count__c;
            } else {
                summaryRecord = SPM_Utilities.getInstance().createSummaryRecord(accountId, configurationName, calculationMethod, description, beginDate, endDate, System.Label.SPM004_TAG002, recordCount);
                summaryRecord.SVMXC__Value__c = value;
                summaryRecord.SVMXC__Metric_Value__c = summaryRecord.SVMXC__Value__c / recordCount;
            }
            summaryMap.put(key, summaryRecord);
            
    }
    
    /**
     * Populates the Account Summary Information using MTTR data.
     * 
     * @return - Computed summary map 
     */
    public Map<String, SVMXC__SPM_Account_Summary__c> populateMTTRSummary() {
        System.debug( LoggingLevel.DEBUG, 'SPM_Account_Summary.populateMTTRSummary() - enter; records' );
        String selectQuery = 'select SVMXC__Service_Delivered_On_Date__c, SVMXC__Account__c, count(id) recordCount,' + 
                             'sum(SVMXC__Dead_Time__c) deadTime, sum(SVMXC__Labor_Time__c) labourTime, SVMXC__Configuration_Name__c,'+ 
                             'SVMXC__Calculation_Method__c FROM SVMXC__SPM_Mean_Time_To_Repair__c';
                             
        String whereClause = ' where ' + createWhereClause(true);
        // String whereClause = ' ';
        String groupByClause = ' group by SVMXC__Configuration_Name__c, SVMXC__Calculation_Method__c, SVMXC__Account__c, SVMXC__Service_Delivered_On_Date__c';
        String orderByClause = ' order by SVMXC__Service_Delivered_On_Date__c';
        
        String finalQuery = selectQuery + whereClause + groupByClause + orderByClause;
        
        System.debug( LoggingLevel.DEBUG, 'Query - ' + finalQuery);
        
        
        SVMXC__SPM_Account_Summary__c summaryRecord;
        Map<String, SVMXC__SPM_Account_Summary__c> summaryMap = new Map<String, SVMXC__SPM_Account_Summary__c>();
        
        Set<String> accountIds = new Set<String>();
        Set<Date> dates = new Set<Date>();
        Set<Date> fixedOnDates = new Set<Date>();
        Set<String> configurationNames = new Set<String>();
        
        List<SObject> records = Database.query(finalQuery);
        totalRecordsProcessedCount += records.size();
        addInfo( 'Total Processed Records : ' + records.size() );
        for(SObject currentRecord : records) {  
            System.debug( LoggingLevel.DEBUG,'Record - '+currentRecord);
            String accountId = (String)currentRecord.get('SVMXC__Account__c');
            String configurationName = (String)currentRecord.get('SVMXC__Configuration_Name__c');
            Date beginDate = SPM_Utilities.getInstance().getBeginDateOfMonth((Date)currentRecord.get('SVMXC__Service_Delivered_On_Date__c'));
            Date endDate = SPM_Utilities.getInstance().getEndDateOfMonth((Date)currentRecord.get('SVMXC__Service_Delivered_On_Date__c'));
            Integer recordCount = Integer.valueOf(currentRecord.get('recordCount'));
            //Update the set with the loaded data.
            accountIds.add(accountId);
            dates.add(beginDate);
            configurationNames.add(configurationName);
            
            //generate a map with the key as accountId-startDate-configurationName
            String key = SPM_Utilities.getInstance().createNewSummaryKey(accountId, beginDate.format(), configurationName);
            Integer value = Integer.valueOf(currentRecord.get('labourTime')) - Integer.valueOf(currentRecord.get('deadTime'));
            if(summaryMap.containsKey(key)) {
                summaryRecord = summaryMap.get(key);
                summaryRecord.SVMXC__Total_Record_Count__c = summaryRecord.SVMXC__Total_Record_Count__c + recordCount;
                summaryRecord.SVMXC__Value__c = summaryRecord.SVMXC__Value__c + value;
                summaryRecord.SVMXC__Metric_Value__c = summaryRecord.SVMXC__Value__c / summaryRecord.SVMXC__Total_Record_Count__c;
            } else {
                String description = configurationsMap.get(configurationName); 
                summaryRecord = SPM_Utilities.getInstance().createSummaryRecord(accountId, configurationName, (String)currentRecord.get('SVMXC__Calculation_Method__c'), description, beginDate, endDate, System.Label.SPM004_TAG002, recordCount);
                summaryRecord.SVMXC__Value__c = value;
                summaryRecord.SVMXC__Metric_Value__c = summaryRecord.SVMXC__Value__c / recordCount;
            }
            summaryMap.put(key, summaryRecord);
        }
        addInfo( 'Total Summary Records : ' + summaryMap.size() );
        SPM_Utilities.getInstance().mergeBatchWithExistingSummary(accountIds, dates, configurationNames, summaryMap, true);
        System.debug( LoggingLevel.DEBUG, 'populateMTTRSummary - Summary Map ' + summaryMap);
        return summaryMap;
    }
    
    /**
     * Populates the Account Summary Information from contract uptime table.
     * 
     * @return - Computed summary map 
     */
    public Map<String, SVMXC__SPM_Account_Summary__c> populateContractUpTimeSummary() {
        System.debug( LoggingLevel.DEBUG, 'SPM_Account_Summary.populateContractUpTimeSummary() - enter; getTrendingEnabledValue()'+getTrendingEnabledValue() );
        System.debug( LoggingLevel.DEBUG, 'SPM_Account_Summary.populateContractUpTimeSummary() - enter; records' );
        String selectQuery = 'select SVMXC__Start_Date__c, SVMXC__Account__c, count(id) recordCount,' + 
                             'sum(SVMXC__Total_Down_Time__c) downTime, sum(SVMXC__Gauranteed_Up_Time__c) uptimeTime, SVMXC__Configuration_Name__c,'+ 
                             'SVMXC__Calculation_Method__c FROM SVMXC__SPM_Contract_Up_Time__c';
                             
        String whereClause = ' where ' + createWhereClause(false);
        String trendingWhereClause='';
        Datetime runDatetime;
        if(getTrendingEnabledValue()){
        
            List<SVMXC__SPM_Contract_Up_Time__c> listContractUpTime=[select id,SVMXC__Run_On__c from SVMXC__SPM_Contract_Up_Time__c where SVMXC__Run_On__c!=null order by SVMXC__Run_On__c  DESC limit 1];
            if(listContractUpTime.size()>0){
                runDatetime = listContractUpTime[0].SVMXC__Run_On__c;
                trendingWhereClause=' and SVMXC__Run_On__c =: runDatetime';
            }
        }
        String groupByClause = ' group by SVMXC__Configuration_Name__c, SVMXC__Calculation_Method__c, SVMXC__Account__c, SVMXC__Start_Date__c';
        String orderByClause = ' order by SVMXC__Start_Date__c';
        
        String finalQuery = selectQuery + whereClause + trendingWhereClause + groupByClause + orderByClause;
        
        System.debug( LoggingLevel.DEBUG, 'Query - ' + finalQuery);
        
        
        SVMXC__SPM_Account_Summary__c summaryRecord;
        Map<String, SVMXC__SPM_Account_Summary__c> summaryMap = new Map<String, SVMXC__SPM_Account_Summary__c>();
        
        Set<String> accountIds = new Set<String>();
        Set<Date> dates = new Set<Date>();
        Set<Date> fixedOnDates = new Set<Date>();
        Set<String> configurationNames = new Set<String>();
        
        List<SObject> records = Database.query(finalQuery);
        totalRecordsProcessedCount += records.size();
        addInfo( 'Total Processed Records : ' + records.size() );
        for(SObject currentRecord : records) {  
            System.debug( LoggingLevel.DEBUG,'Record - '+currentRecord);
            String accountId = (String)currentRecord.get('SVMXC__Account__c');
            String configurationName = (String)currentRecord.get('SVMXC__Configuration_Name__c');
            Date beginDate = (Date)currentRecord.get('SVMXC__Start_Date__c');
            Date endDate = SPM_Utilities.getInstance().getEndDateOfMonth((Date)currentRecord.get('SVMXC__Start_Date__c'));
            Integer recordCount = Integer.valueOf(currentRecord.get('recordCount'));
            //Update the set with the loaded data.
            accountIds.add(accountId);
            dates.add(beginDate);
            configurationNames.add(configurationName);
            
            //generate a map with the key as accountId-startDate-configurationName
            String key = SPM_Utilities.getInstance().createNewSummaryKey(accountId, beginDate.format(), configurationName);
            if(getTrendingEnabledValue()){
            key=key+runDatetime.format('yyyyMMddHHmmss');
            System.debug('runDatetime '+runDatetime);
            }
            Integer value = Integer.valueOf(currentRecord.get('uptimeTime')) - Integer.valueOf(currentRecord.get('downTime'));
            if(summaryMap.containsKey(key)) {
                summaryRecord = summaryMap.get(key);
                summaryRecord.SVMXC__Total_Record_Count__c = summaryRecord.SVMXC__Total_Record_Count__c + recordCount;
                summaryRecord.SVMXC__Value__c = summaryRecord.SVMXC__Value__c + value;
                Decimal newValue = value / Integer.valueOf(currentRecord.get('uptimeTime'));
                summaryRecord.SVMXC__Metric_Value__c = ((summaryRecord.SVMXC__Metric_Value__c + newValue) / 2) * 100;
            } else {
                String description = configurationsMap.get(configurationName); 
                summaryRecord = SPM_Utilities.getInstance().createSummaryRecord(accountId, configurationName, (String)currentRecord.get('SVMXC__Calculation_Method__c'), description, beginDate, endDate, System.Label.SPM004_TAG001, recordCount);
                summaryRecord.SVMXC__Value__c = value;
                summaryRecord.SVMXC__Metric_Value__c = (summaryRecord.SVMXC__Value__c / Integer.valueOf(currentRecord.get('uptimeTime'))) * 100;
            }
            System.debug( LoggingLevel.DEBUG,'Metric Value - ' + summaryRecord.SVMXC__Metric_Value__c);
            summaryMap.put(key, summaryRecord);
        }
        addInfo( 'Total Summary Records : ' + summaryMap.size() );
        SPM_Utilities.getInstance().overrideExistingSummary(accountIds, dates, configurationNames, summaryMap);
        System.debug( LoggingLevel.DEBUG, 'populateContractUpTimeSummary - Summary Map ' + summaryMap);
        return summaryMap;
    }
    
    /**
     * Computes the Account Summary Information from FTF, RepeatVisit and Attach Rate.
     * 
     * @return - Computed summary map 
     */
    private Map<String, SVMXC__SPM_Account_Summary__c> populateValidRateSummary(String sourceTableAPI, String dateFieldAPI, String validityCondition, Boolean appendToExisting) {
        System.debug( LoggingLevel.DEBUG, 'SPM_Account_Summary.populateValidRateSummary() - enter()' );
        String selectQuery = 'SELECT '+ dateFieldAPI + ', SVMXC__Account__c,SVMXC__Configuration_Name__c, SVMXC__Calculation_Method__c, count(id) totalCount FROM ' + sourceTableAPI;
        String whereClause = ' where ' + createWhereClause(appendToExisting);
        String groupByClause = ' group by SVMXC__Configuration_Name__c, SVMXC__Calculation_Method__c, SVMXC__Account__c, ' + dateFieldAPI;
        String orderByClause = ' order by ' + dateFieldAPI;
        
        //Added Soumyaranjan to get the latest Run Date data for Trending
        String trendingWhereClause='';
        Datetime runDatetime;
        if(sourceTableAPI=='SVMXC__SPM_Contract_Penetration__c' && getTrendingEnabledValue()){
            
        
            List<SVMXC__SPM_Contract_Penetration__c> listContractUpTime=[select id,SVMXC__Run_On__c from SVMXC__SPM_Contract_Penetration__c where SVMXC__Run_On__c!=null order by SVMXC__Run_On__c  DESC limit 1];
            if(listContractUpTime.size()>0){
                runDatetime = listContractUpTime[0].SVMXC__Run_On__c;
                trendingWhereClause=' and SVMXC__Run_On__c =: runDatetime';
            }
        }
        //End
        String finalQuery = selectQuery + whereClause + trendingWhereClause + groupByClause + orderByClause;
        
        System.debug( LoggingLevel.DEBUG, 'Query - ' + finalQuery);
        
        
        SVMXC__SPM_Account_Summary__c summaryRecord;
        Map<String, SVMXC__SPM_Account_Summary__c> summaryMap = new Map<String, SVMXC__SPM_Account_Summary__c>();
        
        Set<String> accountIds = new Set<String>();
        Set<Date> dates = new Set<Date>();
        Set<Date> fixedOnDates = new Set<Date>();
        Set<String> configurationNames = new Set<String>();
        
        List<SObject> records = Database.query(finalQuery);
        System.debug( LoggingLevel.DEBUG, 'Loaded Records count - ' + records.size());
        totalRecordsProcessedCount += records.size();
        addInfo( 'Total Processed Records : ' + records.size() );
        
        for(SObject currentRecord : records) {  
            String accountId = (String)currentRecord.get('SVMXC__Account__c');
            String configurationName = (String)currentRecord.get('SVMXC__Configuration_Name__c');
            Date beginDate = SPM_Utilities.getInstance().getBeginDateOfMonth((Date)currentRecord.get(dateFieldAPI));
            Date endDate = SPM_Utilities.getInstance().getEndDateOfMonth((Date)currentRecord.get(dateFieldAPI));
            
            fixedOnDates.add((Date)currentRecord.get(dateFieldAPI));
            Integer totalCount = Integer.valueOf(currentRecord.get('totalCount'));
            //Update the set with the loaded data.
            accountIds.add(accountId);
            dates.add(beginDate);
            configurationNames.add(configurationName);
            
            //generate a map with the key as accountId-startDate-configurationName
            String key = SPM_Utilities.getInstance().createNewSummaryKey(accountId, beginDate.format(), configurationName);
            if(sourceTableAPI=='SVMXC__SPM_Contract_Penetration__c' && getTrendingEnabledValue()){
            key=key+runDatetime.format('yyyyMMddHHmmss');
            System.debug('runDatetime '+runDatetime);
            }
            if(summaryMap.containsKey(key)) {
                summaryRecord = summaryMap.get(key);
                summaryRecord.SVMXC__Total_Record_Count__c = summaryRecord.SVMXC__Total_Record_Count__c + totalCount;
            } else {
                String description = configurationsMap.get(configurationName);
                summaryRecord = SPM_Utilities.getInstance().createSummaryRecord(accountId, configurationName, (String)currentRecord.get('SVMXC__Calculation_Method__c'), description, beginDate, endDate, System.Label.SPM004_TAG001, totalCount);
            }
            summaryMap.put(key, summaryRecord);
        }
        addInfo( 'Total Summary Records : ' + summaryMap.size() );
        System.debug( LoggingLevel.DEBUG, 'Initial Summary Map ' + summaryMap);
        if(sourceTableAPI=='SVMXC__SPM_Contract_Penetration__c' && getTrendingEnabledValue()){
            populateValidCountTrending(accountIds, fixedOnDates, configurationNames, summaryMap, sourceTableAPI, dateFieldAPI, validityCondition, appendToExisting,runDatetime);
        }else{
            populateValidCount(accountIds, fixedOnDates, configurationNames, summaryMap, sourceTableAPI, dateFieldAPI, validityCondition, appendToExisting);
        }
        System.debug( LoggingLevel.DEBUG, 'Updated Summary Map ' + summaryMap);
        if(appendToExisting) {
            SPM_Utilities.getInstance().mergeBatchWithExistingSummary(accountIds, dates, configurationNames, summaryMap, false);
        } else {
            SPM_Utilities.getInstance().overrideExistingSummary(accountIds, dates, configurationNames, summaryMap);
        }
        System.debug( LoggingLevel.DEBUG, 'Final - Summary Map ' + summaryMap);
        System.debug( LoggingLevel.DEBUG, 'SPM_Account_Summary.populateValidRateSummary() - exit()' );
        return summaryMap;
    }
    
    /**
     * Computes the Valid count for the Account Summary Records from FTF, RepeatVisit and Attach Rate tables.
     * 
     * @return - Computed summary map 
     */
     private void populateValidCount(Set<String> accountIds, Set<Date> dates, Set<String> configurationNames, Map<String, SVMXC__SPM_Account_Summary__c> summaryMap,
                                         String sourceTableAPI, String dateFieldAPI, String validityCondition, Boolean appendToExisting) {
        System.debug( LoggingLevel.DEBUG, 'SPM_Account_Summary.populateValidCount() - enter()' );
        
        String selectQuery = 'SELECT '+ dateFieldAPI + ', SVMXC__Account__c,SVMXC__Configuration_Name__c, SVMXC__Calculation_Method__c, count(id) validCount FROM ' + sourceTableAPI;
        String whereClause = ' where ' + createWhereClause(appendToExisting) + ' and '+ validityCondition +' and  SVMXC__Account__c IN :accountIds and '+ dateFieldAPI + ' IN :dates and SVMXC__Configuration_Name__c IN :configurationNames';
        String groupByClause = ' group by SVMXC__Configuration_Name__c, SVMXC__Calculation_Method__c, SVMXC__Account__c, ' + dateFieldAPI;
        String orderByClause = ' order by '+ dateFieldAPI;
        
        String finalQuery = selectQuery + whereClause + groupByClause + orderByClause;
        
        System.debug( LoggingLevel.DEBUG, 'Query - ' + finalQuery);
        
        
        SVMXC__SPM_Account_Summary__c summaryRecord;
        List<SObject> records = Database.query(finalQuery);
        
        for(SObject currentRecord : records) {  
            // currentRecord = (SVMXC__SPM_First_Time_Fix__c) record;
            String accountId = (String)currentRecord.get('SVMXC__Account__c');
            String configurationName = (String)currentRecord.get('SVMXC__Configuration_Name__c');
            Date beginDate = SPM_Utilities.getInstance().getBeginDateOfMonth((Date)currentRecord.get(dateFieldAPI));
            Date endDate = SPM_Utilities.getInstance().getEndDateOfMonth((Date)currentRecord.get(dateFieldAPI));
            
            Integer validCount = Integer.valueOf(currentRecord.get('validCount'));
            
            
            //generate a map with the key as accountId-startDate-configurationName
            String key = SPM_Utilities.getInstance().createNewSummaryKey(accountId, beginDate.format(), configurationName);
            summaryRecord = summaryMap.get(key);
            if(summaryRecord.SVMXC__Value__c != null) {
                summaryRecord.SVMXC__Value__c = summaryRecord.SVMXC__Value__c + validCount;
            } else {
                summaryRecord.SVMXC__Value__c = summaryRecord.SVMXC__Value__c;
            }
            summaryRecord.SVMXC__Metric_Value__c = ((summaryRecord.SVMXC__Value__c / summaryRecord.SVMXC__Total_Record_Count__c) * 100);
            summaryMap.put(key, summaryRecord);
        }
        System.debug( LoggingLevel.DEBUG, 'SPM_Account_Summary.populateValidCount() - exit()' );
    }
    /**
     * Computes the Valid count for the Account Summary Records from FTF, RepeatVisit and Attach Rate tables for Trending.
     * 
     * @return - Computed summary map 
     */
     private void populateValidCountTrending(Set<String> accountIds, Set<Date> dates, Set<String> configurationNames, Map<String, SVMXC__SPM_Account_Summary__c> summaryMap,
                                         String sourceTableAPI, String dateFieldAPI, String validityCondition, Boolean appendToExisting, Datetime runOn) {
        System.debug( LoggingLevel.DEBUG, 'SPM_Account_Summary.populateValidCount() - enter()' );
        
        String selectQuery = 'SELECT '+ dateFieldAPI + ', SVMXC__Account__c,SVMXC__Configuration_Name__c, SVMXC__Calculation_Method__c, count(id) validCount FROM ' + sourceTableAPI;
        String whereClause = ' where ' + createWhereClause(appendToExisting) + ' and '+ validityCondition +' and  SVMXC__Account__c IN :accountIds and '+ dateFieldAPI + ' IN :dates and SVMXC__Configuration_Name__c IN :configurationNames';
        String groupByClause = ' group by SVMXC__Configuration_Name__c, SVMXC__Calculation_Method__c, SVMXC__Account__c, ' + dateFieldAPI;
        String orderByClause = ' order by '+ dateFieldAPI;
        String trendingWhereCl=' and SVMXC__Run_On__c =: runOn';
        String finalQuery = selectQuery + whereClause + trendingWhereCl + groupByClause + orderByClause;
        
        System.debug( LoggingLevel.DEBUG, 'Query - ' + finalQuery);
        
        
        SVMXC__SPM_Account_Summary__c summaryRecord;
        List<SObject> records = Database.query(finalQuery);
        
        for(SObject currentRecord : records) {  
            // currentRecord = (SVMXC__SPM_First_Time_Fix__c) record;
            String accountId = (String)currentRecord.get('SVMXC__Account__c');
            String configurationName = (String)currentRecord.get('SVMXC__Configuration_Name__c');
            Date beginDate = SPM_Utilities.getInstance().getBeginDateOfMonth((Date)currentRecord.get(dateFieldAPI));
            Date endDate = SPM_Utilities.getInstance().getEndDateOfMonth((Date)currentRecord.get(dateFieldAPI));
            
            Integer validCount = Integer.valueOf(currentRecord.get('validCount'));
            
            
            //generate a map with the key as accountId-startDate-configurationName
            String key = SPM_Utilities.getInstance().createNewSummaryKey(accountId, beginDate.format(), configurationName);
            key=key+runOn.format('yyyyMMddHHmmss');
            summaryRecord = summaryMap.get(key);
            if(summaryRecord.SVMXC__Value__c != null) {
                summaryRecord.SVMXC__Value__c = summaryRecord.SVMXC__Value__c + validCount;
            } else {
                summaryRecord.SVMXC__Value__c = summaryRecord.SVMXC__Value__c;
            }
            summaryRecord.SVMXC__Metric_Value__c = ((summaryRecord.SVMXC__Value__c / summaryRecord.SVMXC__Total_Record_Count__c) * 100);
            summaryMap.put(key, summaryRecord);
        }
        System.debug( LoggingLevel.DEBUG, 'SPM_Account_Summary.populateValidCount() - exit()' );
    }
    
    /**
     * Current batch of records performing the summary computation.
     */
    global override void handleRecords( List<SObject> records ) {
        
        System.debug( LoggingLevel.DEBUG, 'SPM_Account_Summary.handleRecords() - enter; records: ' + records.size() );
        SVMXC__ServiceMax_Processes__c currentRecord;
        Map<String, SVMXC__SPM_Account_Summary__c> summaryMap = new Map<String, SVMXC__SPM_Account_Summary__c>();
        
        for(SObject record : records) {  
            currentRecord = (SVMXC__ServiceMax_Processes__c) record;
            System.debug( LoggingLevel.DEBUG, 'currentRecord inside the batch - '+currentRecord);
            if( currentRecord.SVMXC__ProcessID__c.equalsIgnoreCase(SPM_Schema.Report.FirstTimeFix.Name() ) ) {
                addInfo( 'Processing "First Time Fix" records');
                initConfigurationMap(currentRecord.Id);
                summaryMap = populateValidRateSummary('SVMXC__SPM_First_Time_Fix__c', 'SVMXC__Fixed_On__c', 'SVMXC__Is_Fixed_First_Time__c = true', true);
            } else if( currentRecord.SVMXC__ProcessID__c.equalsIgnoreCase(SPM_Schema.Report.RepeatVisit.Name() ) ) {
                addInfo( 'Processing "Repeat Visit" records');
                initConfigurationMap(currentRecord.Id);
                summaryMap = populateValidRateSummary('SVMXC__SPM_Repeat_Visit__c', 'SVMXC__First_Incident_On__c', 'SVMXC__Is_Repeat_Visit__c = true', false);
            } else if( currentRecord.SVMXC__ProcessID__c.equalsIgnoreCase(SPM_Schema.Report.MeanTimeToComplete.Name() ) ) {
                addInfo( 'Processing "Mean Time To Complete" records');
                initConfigurationMap(currentRecord.Id);
                summaryMap = populateMTTCSummary();
            } else if( currentRecord.SVMXC__ProcessID__c.equalsIgnoreCase(SPM_Schema.Report.MeanTimeToRepair.Name() ) ) {
                addInfo( 'Processing "Mean Time To Repair" records');
                initConfigurationMap(currentRecord.Id);
                summaryMap = populateMTTRSummary();
            } else if( currentRecord.SVMXC__ProcessID__c.equalsIgnoreCase(SPM_Schema.Report.ContractPenetration.Name() ) ) {
                addInfo( 'Processing "Attach Rate" records');
                initConfigurationMap(currentRecord.Id);
                summaryMap = populateValidRateSummary('SVMXC__SPM_Contract_Penetration__c', 'SVMXC__Processed_On__c', 'SVMXC__Covered_By__c != \'Not Covered\'', false);
            } else if( currentRecord.SVMXC__ProcessID__c.equalsIgnoreCase(SPM_Schema.Report.UpDownTime.Name() ) ) {
                addInfo( 'Processing "Contract Uptime" records');
                initConfigurationMap(currentRecord.Id);
                summaryMap = populateContractUpTimeSummary();
            } else if( currentRecord.SVMXC__ProcessID__c.equalsIgnoreCase(SPM_Schema.Report.AverageResponseTime.Name() ) ) {
                addInfo( 'Processing "Average Response Time" records');
                initConfigurationMap(currentRecord.Id);
                summaryMap = populateARTSummary();
            } 
        }
        
        if( !summaryMap.isEmpty() ) {
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( summaryMap.values(), COMM_SecurityUtils.Access.Createable ) ) {
                upsert summaryMap.values();
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        }
        
        System.debug( LoggingLevel.DEBUG, 'SPM_Account_Summary.handleRecords() - exit' );
    }
    
    
    /**
     * Invoked after all the batches are processed. We update the total-records processed before sending the message.
     */
    global override void onFinishComplete() {
        setTotalProcessedRecordsCount(totalRecordsProcessedCount);
        System.debug( LoggingLevel.DEBUG, 'onFinishComplete()' );
    }
}