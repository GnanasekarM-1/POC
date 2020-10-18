/*****************************************************************************
   *                       Copyright (C) 2015 ServiceMax, Inc
   *                               All rights reserved
   *
   *****************************************************************************/
   //FLS and CRUD check is not required as this class is running in batch mode
  /**
   * 
   * This class creates data for the Contract Up Time report. Here source is the contract.
   * Here we captures Up time detail records in object as a master record and Down Time 
   * detail records as child records.
   *
   * @author Manish Kushwah
   * @version 15.59101
   * @since 2015
   */
  /*****************************************************************************************************
   *    ID        Name                   Date            Comment
   *****************************************************************************************************
   *              Manish Kushwah         14 Oct 2015     Created. 
   *              Manish Kushwah         01 Apr 2016     Security fixes. 
   *              Soumyaranjan Pati      10th Nov 2017   Contract uptime - Trending(ANA-1374) V.01
   * BAC-4050     Soumyaranjan Pati      27th June 2018  Security fixes.
   *****************************************************************************************************/

  global with sharing class SPM_ContractUpTime extends SPM_AbstractBatch {
    global final Integer MILLI_SEC_TO_MINUTES = 60000;
    global final String NEW_VALUE = 'NEW';
    global final String OLD_VALUE = 'OLD';
    global DateTime dtLastExecutionDateTime = Date.today().addMonths(-1).toStartOfMonth();
    public SVMXC__ServiceMax_Config_Data__c scheduleConfigData;
    public final String WORK_ORDER = 'Work Order';
    public final String DOWN_TIME = 'Down Time';
    public Datetime currentBatchRunDatetime;
    private Map<String, Map<String, Date>> mapUniqueIdVsContractStartEndDate = new Map<String, Map<String, Date>>();
    
    /**
     * Class constructor to create instance of this class.
     */
    global SPM_ContractUpTime( SVMXC__ServiceMax_Config_Data__c scheduleData ) {         
      super( SPM_Schema.Report.UpDownTime, scheduleData );
      this.scheduleConfigData = scheduleData;
    }
    
    /**
     * This is abtract class method which is override for setting up
     * initial configuration like : whereClause, IgnoreNullCheck
     */
    global override void initBatchConfiguration() {        
      System.debug( LoggingLevel.DEBUG, 'SPM_ContractUpTime.initBatchConfiguration() - enter' );       
      //Added by Soumyaranjan for Trending
            
            currentBatchRunDatetime=System.Now();
            
            //End Trending
      Integer numberOfDays = getNumberOfDaysToQualifyRecords();
      if(numberOfDays == null)
        numberOfDays = 365;
      
      if(scheduleConfigData != null){
        if(scheduleConfigData.SVMXC__Enter_Date__c == null)
          scheduleConfigData.SVMXC__Enter_Date__c = System.today();
        
        numberOfDays += scheduleConfigData.SVMXC__Enter_Date__c.daysBetween(System.today());
        /*if(scheduleConfigData.SVMXC__Previous_Execution_Started_On__c != null && scheduleConfigData.SVMXC__Enter_Date__c != null){
          numberOfDays += scheduleConfigData.SVMXC__Enter_Date__c.daysBetween(scheduleConfigData.SVMXC__Previous_Execution_Started_On__c.Date());
        }*/
      }
      System.debug( LoggingLevel.DEBUG, 'numberOfDays: '+numberOfDays);
      Datetime CreatedDateTimeForContract = System.Now().addDays( (numberOfDays * -1) );
      System.debug( LoggingLevel.DEBUG, 'CreatedDateTimeForContract: '+CreatedDateTimeForContract);
      
      //Consider only those contracts that are active within this settting configured number of days.
      String tempWhereClause = ' CreatedDate >= ' + CreatedDateTimeForContract.formatGmt(SPM_Consts.DEFAULT_DATETIME_FORMAT) + ' AND SVMXC__Active__c = true';
      setWhereClause(tempWhereClause);
      addIgnoreNullCheckField(SPM_Schema.Field.BusinessHours);

      System.debug( LoggingLevel.DEBUG, 'SPM_ContractUpTime.initBatchConfiguration() - exit' );
    }
    
    /**
     * Use this method to log in case of any errors addError( Id sourceRecordId, String errorMessage )
     * This method handles source record(Contract records) for processing Up and Down time records.
     *
     */
    global override void handleRecords( List<SObject> records ) {
      System.debug( LoggingLevel.DEBUG, 'SPM_ContractUpTime.handleRecords() - enter; records: ' + records.size() );
       if(records.size() == 0) {
        System.debug( LoggingLevel.INFO, 'No contracts available in this execution');
        return;
      }
      
      //Fetching Calculation method name and Configuration name
      String strCalculationMethod = getCalculationMethodName();
      String strConfigurationName = getConfigurationName();
      
      //Querying default business hour for the organisation
      BusinessHours objBusinessHours = [SELECT Id From BusinessHours Where IsDefault=true];
      
      //Creating a map of Contract Ids and Business hour Ids.
      Map<String, String> mapContractIdVsBusiHourId = new Map<String, String>();
      for(SObject record : records){
        String strBusinesssHourId = (Id)getSourceObjectFieldValue(record, SPM_Schema.Field.BusinessHours);
        String strContractId = (Id)getSourceObjectFieldValue(record, SPM_Schema.Field.Id);
        mapContractIdVsBusiHourId.put(strContractId, strBusinesssHourId);
      }
      
      //Calling method populateUpTimeDetails() for creating Up Time detail records.
      List<SVMXC__SPM_Contract_Up_Time__c> lstUpTimeDetail = new List<SVMXC__SPM_Contract_Up_Time__c>();
      //Added for Trending
      Map<String, List<SVMXC__SPM_Contract_Up_Time__c>> mapOldNewVsListOfUpTimeDetail;
            Map<SVMXC__SPM_Contract_Up_Time__c,SVMXC__SPM_Contract_Up_Time__c> mapOfContractUpTimetoUpsert=new Map<SVMXC__SPM_Contract_Up_Time__c,SVMXC__SPM_Contract_Up_Time__c>();
            System.debug('getTrendingEnabledValue() '+getTrendingEnabledValue());
           
         
      if(getTrendingEnabledValue()){
      
                mapOldNewVsListOfUpTimeDetail = this.populateUpTimeDetailsforTrending(records, objBusinessHours.id, mapContractIdVsBusiHourId, strCalculationMethod, strConfigurationName);
            }else{
                mapOldNewVsListOfUpTimeDetail = this.populateUpTimeDetails(records, objBusinessHours.id, mapContractIdVsBusiHourId, strCalculationMethod, strConfigurationName);
            }
      //End Trending
      System.debug( LoggingLevel.DEBUG, 'Contract uptime records count - '+mapOldNewVsListOfUpTimeDetail.size());
      
      //Inserting Up Time detail records for the key NEW_VALUE in the map mapOldNewVsListOfUpTimeDetail and creating list lstUpTimeDetail
      //to collecting new and existing up time records
      if(mapOldNewVsListOfUpTimeDetail != null && mapOldNewVsListOfUpTimeDetail.size()>0){
        if(mapOldNewVsListOfUpTimeDetail.containsKey(NEW_VALUE)){
          lstUpTimeDetail = mapOldNewVsListOfUpTimeDetail.get(NEW_VALUE);
        }
        if(mapOldNewVsListOfUpTimeDetail.containsKey(OLD_VALUE)){
          lstUpTimeDetail.addAll(mapOldNewVsListOfUpTimeDetail.get(OLD_VALUE));
        }
        if(lstUpTimeDetail != null && lstUpTimeDetail.size() > 0){
          addInfo('Number of SPM Contract Uptime records processed(Inserted or Updated): '+lstUpTimeDetail.size());
          if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstUpTimeDetail, COMM_SecurityUtils.Access.Upsertable)) {
            // upsert lstUpTimeDetail;
                        for(SVMXC__SPM_Contract_Up_Time__c uptime:lstUpTimeDetail){
                            mapOfContractUpTimetoUpsert.put(uptime,uptime);
                        }
                        upsert mapOfContractUpTimetoUpsert.values();
          } else {
            throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
          }
        }
      }
      mapOldNewVsListOfUpTimeDetail.clear();
      
      //Calling method populateDownTimeList() for creating Down Time detail records and then we are inerting.
      List<SVMXC__SPM_Down_Time_Detail__c> listDownTimeDetails = new List<SVMXC__SPM_Down_Time_Detail__c>();
      if(getTrendingEnabledValue()){
    
                listDownTimeDetails = this.populateDownTimeListforTrending(lstUpTimeDetail, objBusinessHours.id, mapContractIdVsBusiHourId);
            }else{
                listDownTimeDetails = this.populateDownTimeList(lstUpTimeDetail, objBusinessHours.id, mapContractIdVsBusiHourId);
            }
            System.debug( LoggingLevel.DEBUG, 'Downtime records count - '+listDownTimeDetails.size());
            
            if(listDownTimeDetails != null && listDownTimeDetails.size() > 0){
                addInfo('Number of SPM DownTimes records processed(Inserted or Updated): '+listDownTimeDetails.size());
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(listDownTimeDetails, COMM_SecurityUtils.Access.Upsertable)) {
                    upsert listDownTimeDetails;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
                }
            }
      
      System.debug( LoggingLevel.DEBUG, 'SPM_ContractUpTime.handleRecords() - exit' );
    }
    
    /**
     * This method creates a map of (Key, List<UpTime>). It may have two value:
     * 1. (NEW_VALUE, List)------> 2. (OLD_VALUE, List)
     * It will create Up Time detail records only once in a month for the previous records and for every run in the same month.
     */
    private Map<String, List<SVMXC__SPM_Contract_Up_Time__c>> populateUpTimeDetails(List<SObject> records, String defaultBusinessHourId, Map<String, String> mapContractIdVsBusiHourId, String strCalculationMethod, String strConfigurationName){
      System.debug( LoggingLevel.DEBUG, 'SPM_ContractUpTime.populateUpTimeDetails() - enter' );
      Map<String, List<SVMXC__SPM_Contract_Up_Time__c>> mapOldNewVsListOfUpTimeDetail = new Map<String, List<SVMXC__SPM_Contract_Up_Time__c>>();
      Map<String, SObject> mapContractIdVsCRecord = new Map<String, SObject>();
      
      //Creating map of contract id and their record
      if(records != null) {
        for(SObject record : records) {
          String strContractId = (Id)getSourceObjectFieldValue(record, SPM_Schema.Field.Id);
          mapContractIdVsCRecord.put(strContractId, record);
        }
        System.debug( LoggingLevel.DEBUG, 'Contracts records size: '+records.size());
        addInfo('Contracts records size: '+records.size());
      }
      if(mapContractIdVsCRecord.size() > 0) {
        //Querying covered product for the fetched contract ids.
        List<String> queryFields = new List<String> {'SVMXC__Installed_Product__c', 'SVMXC__Start_Date__c','SVMXC__End_Date__c','SVMXC__Service_Contract__c'};
        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__Service_Contract_Products__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
          throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        //Criteria to load the Covered Products.
                String criteria = getExpressionCriteria(SPM_Schema.ExpressionType.FilterCriteria);
                System.debug( LoggingLevel.DEBUG, 'criteria - '+ criteria);
                Set<String> contractIds = mapContractIdVsCRecord.keySet();
                System.debug( LoggingLevel.DEBUG, 'contractIds - '+ contractIds);
                
                String query ='SELECT SVMXC__Installed_Product__c, SVMXC__Start_Date__c, SVMXC__End_Date__c, SVMXC__Service_Contract__c FROM '+
                            'SVMXC__Service_Contract_Products__c WHERE SVMXC__Service_Contract__c IN: contractIds AND SVMXC__Installed_Product__c != null';
                
                if(criteria != null && criteria != '') {
                   //query = query +' AND ' + criteria;
                   query = query +' AND (' + criteria + ') ';
                }
                System.debug( LoggingLevel.DEBUG, 'Query - '+ query);
                List<SVMXC__Service_Contract_Products__c> lstCoveredProducts = Database.query(query);
                System.debug( LoggingLevel.DEBUG, 'Loaded Covered-Products count - ' + lstCoveredProducts.size());
                
                
        //List<SVMXC__Service_Contract_Products__c> lstCoveredProducts = [SELECT SVMXC__Installed_Product__c, SVMXC__Start_Date__c, SVMXC__End_Date__c, SVMXC__Service_Contract__c FROM SVMXC__Service_Contract_Products__c WHERE SVMXC__Service_Contract__c IN: mapContractIdVsCRecord.keySet() AND SVMXC__Installed_Product__c != null];
        
        //Creating set of Installed Product ids
        Set<String> setIBIds = new Set<String>();
        for(SVMXC__Service_Contract_Products__c objCoveredProduct : lstCoveredProducts)
          setIBIds.add(objCoveredProduct.SVMXC__Installed_Product__c);
        System.debug( LoggingLevel.DEBUG, 'setIBIds: '+setIBIds);
        
        //Querying existing up time records based on Contract id and IB id
        queryFields = new List<String> {'Id', 'SVMXC__Installed_Product__c','SVMXC__Contract__c','SVMXC__Gauranteed_Up_Time__c','SVMXC__Start_Date__c','SVMXC__End_Date__c'};
        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__SPM_Contract_Up_Time__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
          throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        List<SVMXC__SPM_Contract_Up_Time__c> lstExistingUpTimeRecord = [SELECT Id, SVMXC__Installed_Product__c, SVMXC__Contract__c, SVMXC__Gauranteed_Up_Time__c, SVMXC__Start_Date__c, SVMXC__End_Date__c FROM SVMXC__SPM_Contract_Up_Time__c WHERE SVMXC__Installed_Product__c IN: setIBIds AND SVMXC__Contract__c IN: mapContractIdVsCRecord.keySet() AND SVMXC__Start_Date__c != null AND SVMXC__End_Date__c != null];
        
        //Logic to get Start and End date of previous month
        Date lstMonthDate =  Date.today().addMonths(-1);
        Date firstDate = lstMonthDate.toStartOfMonth();
        Date lastDate = firstDate.addDays(date.daysInMonth(lstMonthDate.year() , lstMonthDate.month())  - 1);
        
        //Creating map of UniqueKey and existing Up-Time detail record.
        //Here unique key is combination of contract id and Top-level id.
        Map<String, SVMXC__SPM_Contract_Up_Time__c> mapUniqueIdVsUpTimeRecord = new Map<String, SVMXC__SPM_Contract_Up_Time__c>();
        for(SVMXC__SPM_Contract_Up_Time__c objUpTime : lstExistingUpTimeRecord) {
          if(objUpTime.SVMXC__Start_Date__c == firstDate && objUpTime.SVMXC__End_Date__c == lastDate){
            //Creating UniqueKey by concatenating Contract ID and IB Id
            String strUniqueKey = objUpTime.SVMXC__Contract__c +''+ objUpTime.SVMXC__Installed_Product__c;
            mapUniqueIdVsUpTimeRecord.put(strUniqueKey, objUpTime);
          }
        }
        System.debug( LoggingLevel.DEBUG, 'mapUniqueIdVsUpTimeRecord size: '+mapUniqueIdVsUpTimeRecord.size());
        
        if(lstCoveredProducts != null && lstCoveredProducts.size() > 0) {
          for(SVMXC__Service_Contract_Products__c objCovPro : lstCoveredProducts) {
            if(mapContractIdVsCRecord.containsKey(objCovPro.SVMXC__Service_Contract__c)) {
              SObject objContract = mapContractIdVsCRecord.get(objCovPro.SVMXC__Service_Contract__c);
              String strAccountId = (Id) getSourceObjectFieldValue(objContract, SPM_Schema.Field.Account);
              String strUniqueKey = objCovPro.SVMXC__Service_Contract__c +''+ objCovPro.SVMXC__Installed_Product__c;
              
              //Get the start date and end date from covered-product. IF not present then get it from contract.
              Datetime startDate = (Datetime) getSourceObjectFieldValue(objCovPro, SPM_Schema.Field.StartDate);
              Datetime endDate = (Datetime) getSourceObjectFieldValue(objCovPro, SPM_Schema.Field.EndDate);
              if(startDate == null || endDate == null) {
                startDate = (Datetime) getSourceObjectFieldValue(objContract, SPM_Schema.Field.StartDate);
                endDate = (Datetime) getSourceObjectFieldValue(objContract, SPM_Schema.Field.EndDate);
              }
              
              //Creating a Map of UniqueKey and Map of Start and End date of Contract and going to use it for Validity of Downtime
              Map<String, Date> mapContractStartEndDate = new Map<String, Date>{'START'=>startDate.Date(),'END'=>endDate.Date()};
              mapUniqueIdVsContractStartEndDate.put(strUniqueKey, mapContractStartEndDate);
              
              //Getting business hour id from service contract (by default it is set to default business hour)
              String strContractId = (Id)getSourceObjectFieldValue(objContract, SPM_Schema.Field.Id);
              String objBusinessHoursId = '';
              if(mapContractIdVsBusiHourId != null && mapContractIdVsBusiHourId.size()>0 && mapContractIdVsBusiHourId.containsKey(strContractId) && mapContractIdVsBusiHourId.get(strContractId) != null){
                objBusinessHoursId = mapContractIdVsBusiHourId.get(strContractId);
              }
              else
                objBusinessHoursId = defaultBusinessHourId;
              
              //Updating start and end date of previous month based on starting and ending of covered product OR contract
              Long GauranteedUpTime = 0;
              if(startDate != null && endDate != null && (startDate <= lastDate || endDate >= firstDate)){
                if(firstDate > startDate)
                  startDate = firstDate;
                if(lastDate < endDate)
                  endDate = lastDate;
                //endDate = endDate.addDays(1).addSeconds(-1); Commented to fix defect 026052
                endDate = endDate.addDays(1);
                GauranteedUpTime = (Long)(BusinessHours.diff(objBusinessHoursId, startDate, endDate)/MILLI_SEC_TO_MINUTES);
              }
              
              //Checking for existing Up-Time detail record by using uniquekey. If it's not there we are creating new and //collecting in the map mapOldNewVsListOfUpTimeDetail with key as NEW_VALUE.
              //If it's there, we are collecting existing record in the same map with key as OLD_VALUE
              if(!(mapUniqueIdVsUpTimeRecord != null && mapUniqueIdVsUpTimeRecord.size() > 0 && mapUniqueIdVsUpTimeRecord.containsKey(strUniqueKey))) {
                if(GauranteedUpTime > 0) {
                  //Create the instance of the Parent Object.
                  SVMXC__SPM_Contract_Up_Time__c upTimeDetail = new SVMXC__SPM_Contract_Up_Time__c();
                  upTimeDetail.SVMXC__Installed_Product__c = objCovPro.SVMXC__Installed_Product__c;
                  upTimeDetail.SVMXC__Contract__c = objCovPro.SVMXC__Service_Contract__c;                                
                  upTimeDetail.SVMXC__Account__c = strAccountId;
                  upTimeDetail.SVMXC__Gauranteed_Up_Time__c = GauranteedUpTime;
                  upTimeDetail.SVMXC__Start_Date__c = firstDate;
                  upTimeDetail.SVMXC__End_Date__c = lastDate;
                  upTimeDetail.SVMXC__Configuration_Name__c = strConfigurationName;
                  upTimeDetail.SVMXC__Calculation_Method__c = strCalculationMethod;
                  
                  performFieldMapping(mapContractIdVsCRecord.get(objCovPro.SVMXC__Service_Contract__c), upTimeDetail); //Added for perform mapping
                  
                  if(!mapOldNewVsListOfUpTimeDetail.containsKey(NEW_VALUE))
                    mapOldNewVsListOfUpTimeDetail.put(NEW_VALUE, new List<SVMXC__SPM_Contract_Up_Time__c>());
                  mapOldNewVsListOfUpTimeDetail.get(NEW_VALUE).add(upTimeDetail);
                }
              }
              else if(mapUniqueIdVsUpTimeRecord != null && mapUniqueIdVsUpTimeRecord.size() > 0 && mapUniqueIdVsUpTimeRecord.containsKey(strUniqueKey)) {
                if(!mapOldNewVsListOfUpTimeDetail.containsKey(OLD_VALUE))
                  mapOldNewVsListOfUpTimeDetail.put(OLD_VALUE, new List<SVMXC__SPM_Contract_Up_Time__c>());
                SVMXC__SPM_Contract_Up_Time__c objContractUpTime = mapUniqueIdVsUpTimeRecord.get(strUniqueKey);
                if(GauranteedUpTime > 0) 
                  objContractUpTime.SVMXC__Gauranteed_Up_Time__c = GauranteedUpTime;
                objContractUpTime.SVMXC__Configuration_Name__c = strConfigurationName;
                objContractUpTime.SVMXC__Calculation_Method__c = strCalculationMethod;
                
                performFieldMapping(mapContractIdVsCRecord.get(objContractUpTime.SVMXC__Contract__c), objContractUpTime); //Added for perform mapping
                
                mapOldNewVsListOfUpTimeDetail.get(OLD_VALUE).add(objContractUpTime);
              }
            }
          }
        }
      }
      System.debug( LoggingLevel.DEBUG, 'SPM_ContractUpTime.populateUpTimeDetails() - exit' );
      return mapOldNewVsListOfUpTimeDetail;
    }
     
     
    /**
     * Populates the down time details of the Installation-Base by iterating through the entitled work-orders. 
     */
    private List <SVMXC__SPM_Down_Time_Detail__c> populateDownTimeList(List <SVMXC__SPM_Contract_Up_Time__c> lstUpTimeDetail, String defaultBusinessHourId, Map<String, String> mapContractIdVsBusiHourId) {
      System.debug( LoggingLevel.DEBUG, 'SPM_ContractUpTime.populateDownTimeList() - enter' );
      List<SVMXC__SPM_Down_Time_Detail__c> listDownTimeDetails = new List<SVMXC__SPM_Down_Time_Detail__c>();
      Set<String> setCoveredInstalledProduct = new Set<String>();
      Set<String> setContractId = new Set<String>();
      Set<String> setWOId = new Set<String>();
      Map<String, List<SVMXC__Service_Order__c>> mapIBCONidVsListWO = new Map<String, List<SVMXC__Service_Order__c>>();
      Map<String, List<SVMXC__Down_Time__c>> mapWOidVsListDownTime = new Map<String, List<SVMXC__Down_Time__c>>();
      Set<String> setUpTimeIds = new Set<String>();
      String configuredIBapiName = getSourceObjectField(SPM_Schema.Field.InstallProduct);
      System.debug( LoggingLevel.DEBUG, 'configuredIBapiName: '+configuredIBapiName);
      
      //Added for the user story SPM-243(Enhancement)
      String configuredStartDateApiName = getSourceObjectField(SPM_Schema.Field.CreatedDate);
      String configuredClosedDateApiName = getSourceObjectField(SPM_Schema.Field.ClosedOn);
      String strDownTimeFrom = getSourceObjectField(SPM_Schema.Field.considerDownTimeFrom);
      System.debug( LoggingLevel.DEBUG, 'configuredStartDateApiName: '+configuredStartDateApiName);
      System.debug( LoggingLevel.DEBUG, 'configuredClosedDateApiName: '+configuredClosedDateApiName);
      System.debug( LoggingLevel.DEBUG, 'strDownTimeFrom: '+strDownTimeFrom);

      //Creating sets of IB ids, Contract ids and Up-Time detail record ids
      for(SVMXC__SPM_Contract_Up_Time__c upTimeDetail: lstUpTimeDetail){
        setCoveredInstalledProduct.add(upTimeDetail.SVMXC__Installed_Product__c);
        setContractId.add(upTimeDetail.SVMXC__Contract__c);
        setUpTimeIds.add(upTimeDetail.id);
      }
      
      //Logic to get Start and End date of previous month
      Time tm = Time.newInstance(0,0,0,0);
      Date lstMonthDate =  Date.today().addMonths(-1);
      Date firstDate = lstMonthDate.toStartOfMonth();  
      Date lastDate = firstDate.addDays(date.daysInMonth(lstMonthDate.year() , lstMonthDate.month()) -1);
      DateTime firstDateTime = Datetime.newInstance(firstDate, tm);
      DateTime lastDateTime = Datetime.newInstance(lastDate.addDays(1), tm);
      System.debug(firstDateTime  + ' ------ ' + lastDateTime);
      
      List<String> queryFields = new List<String> {'Id', 'SVMXC__Is_PM_Work_Order__c','SVMXC__Service_Contract__c'};
      queryFields.add(configuredIBapiName);
      
      String strWorkOrderQuery = 'SELECT Id, SVMXC__Is_PM_Work_Order__c, SVMXC__Service_Contract__c, '+ configuredIBapiName +' FROM SVMXC__Service_Order__c WHERE '+configuredIBapiName+' IN: setCoveredInstalledProduct AND SVMXC__Service_Contract__c IN: setContractId';
      
      if(configuredClosedDateApiName != null && configuredStartDateApiName != null){
        queryFields.add(configuredClosedDateApiName);
        queryFields.add(configuredStartDateApiName);
        strWorkOrderQuery = 'SELECT Id, SVMXC__Is_PM_Work_Order__c, SVMXC__Service_Contract__c, '+ configuredClosedDateApiName +', '+ configuredIBapiName +', '+ configuredStartDateApiName +' FROM SVMXC__Service_Order__c WHERE '+configuredIBapiName+' IN: setCoveredInstalledProduct AND SVMXC__Service_Contract__c IN: setContractId';
      }
      
      if(strDownTimeFrom != null && strDownTimeFrom.equalsIgnoreCase(WORK_ORDER) && configuredClosedDateApiName != null && configuredStartDateApiName != null){
        strWorkOrderQuery += ' AND '+configuredStartDateApiName+' != null AND '+configuredClosedDateApiName+' != null AND '+configuredClosedDateApiName+' >=:  firstDateTime AND '+configuredClosedDateApiName+' <=: lastDateTime';
      }
      
      if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__Service_Order__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
      }
      
      //Fetching where clause from the configuration
      String whereClause = getExpressionCriteria( SPM_Schema.ExpressionType.WorkOrderCriteria);
      System.debug( LoggingLevel.DEBUG, 'whereClause: '+whereClause);
      
      if(whereClause != null && whereClause != '' && whereClause.length()>0)
        strWorkOrderQuery += ' AND (' + whereClause + ')';
      System.debug( LoggingLevel.DEBUG, 'strWorkOrderQuery: '+strWorkOrderQuery);
      
      List<SVMXC__Service_Order__c> lstWorkOrders = new List<SVMXC__Service_Order__c>();
      if(strWorkOrderQuery != null && strWorkOrderQuery.length()>0)
        lstWorkOrders = Database.query(strWorkOrderQuery);
      
      //Collecting Work order Ids and creating map of UniqueKey(Combination of Top-level IB id and Contract id) and list of WO
      if(lstWorkOrders != null && lstWorkOrders.size()>0){
        System.debug( LoggingLevel.DEBUG, 'lstWorkOrders size: '+lstWorkOrders.size());
        addInfo('Number of Work Orders: '+lstWorkOrders.size());
        for(SVMXC__Service_Order__c objWO : lstWorkOrders){
          setWOId.add(objWO.id);
          
          //Creating unique by concatenating Top Level ID and Contract Id
          String strUniqueKey = objWO.SVMXC__Service_Contract__c +''+ objWO.get(configuredIBapiName);
          if(!mapIBCONidVsListWO.containsKey(strUniqueKey))
            mapIBCONidVsListWO.put(strUniqueKey, new List<SVMXC__Service_Order__c>());
          mapIBCONidVsListWO.get(strUniqueKey).add(objWO);
        }
      }
      System.debug( LoggingLevel.DEBUG, 'mapIBCONidVsListWO size: '+mapIBCONidVsListWO.size());
      
      //Querying Downtime records based on Qualified WO ids and Start time greater than LastExecutionDate
      List<SVMXC__Down_Time__c> lstDownTime;
      if(strDownTimeFrom == null || (strDownTimeFrom != null && strDownTimeFrom.equalsIgnoreCase(DOWN_TIME))){
        queryFields = new List<String> {'SVMXC__duration__c', 'SVMXC__Start_Time__c','SVMXC__End_Time__c','SVMXC__Service_Order__c'};
        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__Down_Time__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
          throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        lstDownTime = [SELECT SVMXC__duration__c, SVMXC__Start_Time__c, SVMXC__End_Time__c, SVMXC__Service_Order__c FROM SVMXC__Down_Time__c WHERE SVMXC__Service_Order__c IN: setWOId AND SVMXC__Start_Time__c <=: lastDateTime AND SVMXC__Start_Time__c >=: firstDateTime];
        System.debug( LoggingLevel.DEBUG, 'lstDownTime size: '+lstDownTime.size());
        addInfo('Total Number of DownTimes for all qualified work order: '+lstDownTime.size());
        
        //Creating map of Work order Ids and List of Downtime
        for(SVMXC__Down_Time__c objDT : lstDownTime){
          if(!mapWOidVsListDownTime.containsKey(objDT.SVMXC__Service_Order__c))
            mapWOidVsListDownTime.put(objDT.SVMXC__Service_Order__c, new List<SVMXC__Down_Time__c>());
          mapWOidVsListDownTime.get(objDT.SVMXC__Service_Order__c).add(objDT);
        }
      }
      
      //Querying existing Down Time Detail records based on Work order ids and Up-Time record ids
      queryFields = new List<String> {'Id', 'SVMXC__Down_Time__c','SVMXC__Work_Order__c','SVMXC__Down_On__c','SVMXC__Up_Time_Detail__c'};
      if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__SPM_Down_Time_Detail__c', queryFields, COMM_SecurityUtils.Access.Accessible)){
        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
      }
      List<SVMXC__SPM_Down_Time_Detail__c> lstExistingDownTimeDetail = [SELECT Id, SVMXC__Down_Time__c, SVMXC__Work_Order__c, SVMXC__Down_On__c, SVMXC__Up_Time_Detail__c FROM SVMXC__SPM_Down_Time_Detail__c WHERE SVMXC__Work_Order__c IN: setWOId AND SVMXC__Up_Time_Detail__c IN: setUpTimeIds];
      
      if(lstExistingDownTimeDetail.size()>0){
        //Deleting all the SPM down time records for the qualified SPM UpTime records.
        //If the engine runs with configuration DOWN_TIME and creates some entries with different dates then we cannot identify which downtime we have to update when engine runs with configuration WORK_ORDER.So we will delete all the down time records which was created in the first engine run and create again all the downTime records.
        delete lstExistingDownTimeDetail;
        lstExistingDownTimeDetail.clear();
      }
      
      for(SVMXC__SPM_Contract_Up_Time__c upTimeDetail: lstUpTimeDetail){
        //Getting business hour id from service contract (by default it is set to default business hour)
        String strContractId = upTimeDetail.SVMXC__Contract__c;
        String objBusinessHoursId = '';
        if(mapContractIdVsBusiHourId != null && mapContractIdVsBusiHourId.size()>0 && mapContractIdVsBusiHourId.containsKey(strContractId) && mapContractIdVsBusiHourId.get(strContractId) != null){
          objBusinessHoursId = mapContractIdVsBusiHourId.get(strContractId);
        }
        else
          objBusinessHoursId = defaultBusinessHourId;
        
        //Fetching Work orders from the map based on uniquekey
        String strUniqueKey = upTimeDetail.SVMXC__Contract__c +''+ upTimeDetail.SVMXC__Installed_Product__c;
        lstWorkOrders = new List<SVMXC__Service_Order__c>();
        if(mapIBCONidVsListWO.containsKey(strUniqueKey))
          lstWorkOrders = mapIBCONidVsListWO.get(strUniqueKey);
        
        for(SVMXC__Service_Order__c objWorkOrder : lstWorkOrders){
          Map<Date, Long> mapStartTimeVsDownTimeSum = new Map<Date, Long>();
          Map<Date, SVMXC__SPM_Down_Time_Detail__c> mapDateVsNewDownTimeRecord = new Map<Date, SVMXC__SPM_Down_Time_Detail__c>();
          
          //Added for the user story SPM-243
          if(strDownTimeFrom != null && strDownTimeFrom.equalsIgnoreCase(WORK_ORDER) && configuredClosedDateApiName != null && configuredStartDateApiName != null){
            Long duration = 0;
            DateTime dtCreatedDateTime = (DateTime)objWorkOrder.get(configuredStartDateApiName);
            DateTime dtClosedDateTime = (DateTime)objWorkOrder.get(configuredClosedDateApiName);
            if(dtClosedDateTime != null)
              duration = (Long)(BusinessHours.diff(objBusinessHoursId, dtCreatedDateTime, dtClosedDateTime)/MILLI_SEC_TO_MINUTES);
            
            if(duration > 0){
              SVMXC__SPM_Down_Time_Detail__c downTimeDetail = new SVMXC__SPM_Down_Time_Detail__c();
              downTimeDetail.SVMXC__Up_Time_Detail__c = upTimeDetail.id;
              downTimeDetail.SVMXC__Down_On__c = dtCreatedDateTime.date();
              downTimeDetail.SVMXC__Down_Time__c = duration;
              downTimeDetail.SVMXC__Is_PM_Work_Order__c = objWorkOrder.SVMXC__Is_PM_Work_Order__c;
              downTimeDetail.SVMXC__Work_Order__c = objWorkOrder.id;
              listDownTimeDetails.add(downTimeDetail);
            }
          }
          else{
            //Fetching Down time records from the map based on Work order ids
            lstDownTime = new List<SVMXC__Down_Time__c>();
            if(mapWOidVsListDownTime != null && mapWOidVsListDownTime.containsKey(objWorkOrder.id))
              lstDownTime = mapWOidVsListDownTime.get(objWorkOrder.id);
            
            //Calculating Downtime value
            for(SVMXC__Down_Time__c downTime: lstDownTime){
              //Checking whether the Downtime is captured within the contract period or not
              if(mapUniqueIdVsContractStartEndDate.containsKey(strUniqueKey)){
                Map<String, Date> tempMap = mapUniqueIdVsContractStartEndDate.get(strUniqueKey);
                Date startDate = tempMap.get('START');
                Date endDate = tempMap.get('END');
                if(downTime.SVMXC__Start_Time__c.Date() < startDate || downTime.SVMXC__Start_Time__c.Date() > endDate){
                  continue;
                }
              }
              
              //Calculating Downtime value
              Long duration = 0;
              if(downTime.SVMXC__duration__c != null && downTime.SVMXC__duration__c > 0)
                duration = (Long)downTime.SVMXC__duration__c;
              else if(downTime.SVMXC__Start_Time__c != null && downTime.SVMXC__End_Time__c != null){
                DateTime tempEndTime;
                if(downTime.SVMXC__End_Time__c > lastDateTime)
                  tempEndTime = lastDateTime;
                else
                  tempEndTime = downTime.SVMXC__End_Time__c;
                duration = (Long)(BusinessHours.diff(objBusinessHoursId, downTime.SVMXC__Start_Time__c, tempEndTime)/MILLI_SEC_TO_MINUTES);
              }
              if(downTime.SVMXC__Start_Time__c != null){
                Date dtTemp = downTime.SVMXC__Start_Time__c.date();
                if(!mapDateVsNewDownTimeRecord.containsKey(dtTemp)){
                  SVMXC__SPM_Down_Time_Detail__c downTimeDetail = new SVMXC__SPM_Down_Time_Detail__c();
                  downTimeDetail.SVMXC__Down_On__c = dtTemp;
                  downTimeDetail.SVMXC__Down_Time__c = duration;
                  downTimeDetail.SVMXC__Is_PM_Work_Order__c = objWorkOrder.SVMXC__Is_PM_Work_Order__c;
                  downTimeDetail.SVMXC__Up_Time_Detail__c = upTimeDetail.id;
                  downTimeDetail.SVMXC__Work_Order__c = objWorkOrder.id;
                  mapDateVsNewDownTimeRecord.put(dtTemp, downTimeDetail);
                }
                else{
                  SVMXC__SPM_Down_Time_Detail__c downTimeDetail = mapDateVsNewDownTimeRecord.get(dtTemp);
                  downTimeDetail.SVMXC__Down_Time__c = downTimeDetail.SVMXC__Down_Time__c + duration;
                  mapDateVsNewDownTimeRecord.put(dtTemp, downTimeDetail);
                }
              }
            }
          }
          
          if(mapDateVsNewDownTimeRecord != null && mapDateVsNewDownTimeRecord.size() > 0){
            listDownTimeDetails.addAll(mapDateVsNewDownTimeRecord.values());
          }
        }
      }
      System.debug( LoggingLevel.DEBUG, 'SPM_ContractUpTime.populateDownTimeList() - exit' );
      return listDownTimeDetails;
    }
    /**
         * This method creates a map of (Key, List<UpTime>). It may have two value:
         * 1. (NEW_VALUE, List)------> 2. (OLD_VALUE, List)
         * It will create Up Time Trending detail records only once in a month for the previous records and for every run in the same month.
         */
        private Map<String, List<SVMXC__SPM_Contract_Up_Time__c>> populateUpTimeDetailsforTrending(List<SObject> records, String defaultBusinessHourId, Map<String, String> mapContractIdVsBusiHourId, String strCalculationMethod, String strConfigurationName){
            System.debug( LoggingLevel.DEBUG, 'SPM_ContractUpTime.populateUpTimeDetails() - enter' );
            Map<String, List<SVMXC__SPM_Contract_Up_Time__c>> mapOldNewVsListOfUpTimeDetail = new Map<String, List<SVMXC__SPM_Contract_Up_Time__c>>();
            Map<String, SObject> mapContractIdVsCRecord = new Map<String, SObject>();
            
            //Creating map of contract id and their record
            if(records != null) {
                for(SObject record : records) {
                    String strContractId = (Id)getSourceObjectFieldValue(record, SPM_Schema.Field.Id);
                    mapContractIdVsCRecord.put(strContractId, record);
                }
                System.debug( LoggingLevel.DEBUG, 'Contracts records size: '+records.size());
                addInfo('Contracts records size: '+records.size());
            }
            if(mapContractIdVsCRecord.size() > 0) {
                //Querying covered product for the fetched contract ids.
                List<String> queryFields = new List<String> {'SVMXC__Installed_Product__c', 'SVMXC__Start_Date__c','SVMXC__End_Date__c','SVMXC__Service_Contract__c'};
                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__Service_Contract_Products__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                //Criteria to load the Covered Products.
                String criteria = getExpressionCriteria(SPM_Schema.ExpressionType.FilterCriteria);
                System.debug( LoggingLevel.DEBUG, 'criteria - '+ criteria);
                Set<String> contractIds = mapContractIdVsCRecord.keySet();
                System.debug( LoggingLevel.DEBUG, 'contractIds - '+ contractIds);
                
                String query ='SELECT SVMXC__Installed_Product__c, SVMXC__Start_Date__c, SVMXC__End_Date__c, SVMXC__Service_Contract__c FROM '+
                            'SVMXC__Service_Contract_Products__c WHERE SVMXC__Service_Contract__c IN: contractIds AND SVMXC__Installed_Product__c != null';
                
                if(criteria != null && criteria != '') {
                   //query = query +' AND ' + criteria;
                   query = query +' AND (' + criteria + ') ';
                }
                System.debug( LoggingLevel.DEBUG, 'Query - '+ query);
                List<SVMXC__Service_Contract_Products__c> lstCoveredProducts = Database.query(query);
                System.debug( LoggingLevel.DEBUG, 'Loaded Covered-Products count - ' + lstCoveredProducts.size());
                
        
                // List<SVMXC__Service_Contract_Products__c> lstCoveredProducts = [SELECT SVMXC__Installed_Product__c, SVMXC__Start_Date__c, SVMXC__End_Date__c, SVMXC__Service_Contract__c 
                //             FROM SVMXC__Service_Contract_Products__c WHERE SVMXC__Service_Contract__c IN: mapContractIdVsCRecord.keySet() AND SVMXC__Installed_Product__c != null];
                
                //Creating set of Installed Product ids
                Set<String> setIBIds = new Set<String>();
                for(SVMXC__Service_Contract_Products__c objCoveredProduct : lstCoveredProducts)
                    setIBIds.add(objCoveredProduct.SVMXC__Installed_Product__c);
                System.debug( LoggingLevel.DEBUG, 'setIBIds: '+setIBIds);
                
                //Querying existing up time records based on Contract id and IB id
                queryFields = new List<String> {'Id', 'SVMXC__Installed_Product__c','SVMXC__Contract__c','SVMXC__Gauranteed_Up_Time__c','SVMXC__Start_Date__c','SVMXC__End_Date__c'};
                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__SPM_Contract_Up_Time__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                
                //Logic to get Start and End date of previous month
                Date lstMonthDate =  Date.today().addMonths(-1);
                Date firstDate = lstMonthDate.toStartOfMonth();
                Date lastDate = firstDate.addDays(date.daysInMonth(lstMonthDate.year() , lstMonthDate.month())  - 1);
                
                
                if(lstCoveredProducts != null && lstCoveredProducts.size() > 0) {
                    for(SVMXC__Service_Contract_Products__c objCovPro : lstCoveredProducts) {
                        if(mapContractIdVsCRecord.containsKey(objCovPro.SVMXC__Service_Contract__c)) {
                            SObject objContract = mapContractIdVsCRecord.get(objCovPro.SVMXC__Service_Contract__c);
                            String strAccountId = (Id) getSourceObjectFieldValue(objContract, SPM_Schema.Field.Account);
                            String strUniqueKey = objCovPro.SVMXC__Service_Contract__c +''+ objCovPro.SVMXC__Installed_Product__c;
                            
                            //Get the start date and end date from covered-product. IF not present then get it from contract.
                            Datetime startDate = (Datetime) getSourceObjectFieldValue(objCovPro, SPM_Schema.Field.StartDate);
                            Datetime endDate = (Datetime) getSourceObjectFieldValue(objCovPro, SPM_Schema.Field.EndDate);
                            if(startDate == null || endDate == null) {
                                startDate = (Datetime) getSourceObjectFieldValue(objContract, SPM_Schema.Field.StartDate);
                                endDate = (Datetime) getSourceObjectFieldValue(objContract, SPM_Schema.Field.EndDate);
                            }
                            
                            //Creating a Map of UniqueKey and Map of Start and End date of Contract and going to use it for Validity of Downtime
                            Map<String, Date> mapContractStartEndDate = new Map<String, Date>{'START'=>startDate.Date(),'END'=>endDate.Date()};
                            mapUniqueIdVsContractStartEndDate.put(strUniqueKey, mapContractStartEndDate);
                            
                            //Getting business hour id from service contract (by default it is set to default business hour)
                            String strContractId = (Id)getSourceObjectFieldValue(objContract, SPM_Schema.Field.Id);
                            String objBusinessHoursId = '';
                            if(mapContractIdVsBusiHourId != null && mapContractIdVsBusiHourId.size()>0 && mapContractIdVsBusiHourId.containsKey(strContractId) && mapContractIdVsBusiHourId.get(strContractId) != null){
                                objBusinessHoursId = mapContractIdVsBusiHourId.get(strContractId);
                            }
                            else
                                objBusinessHoursId = defaultBusinessHourId;
                            
                            //Updating start and end date of previous month based on starting and ending of covered product OR contract
                            Long GauranteedUpTime = 0;
                            if(startDate != null && endDate != null && (startDate <= lastDate || endDate >= firstDate)){
                                if(firstDate > startDate)
                                    startDate = firstDate;
                                if(lastDate < endDate)
                                    endDate = lastDate;
                                //endDate = endDate.addDays(1).addSeconds(-1); Commented to fix defect 026052
                                endDate = endDate.addDays(1);
                                GauranteedUpTime = (Long)(BusinessHours.diff(objBusinessHoursId, startDate, endDate)/MILLI_SEC_TO_MINUTES);
                            }
                            
                            //Checking for existing Up-Time detail record by using uniquekey. If it's not there we are creating new and //collecting in the map mapOldNewVsListOfUpTimeDetail with key as NEW_VALUE.
                            //If it's there, we are collecting existing record in the same map with key as OLD_VALUE
                            
                                if(GauranteedUpTime > 0) {
                                    //Create the instance of the Parent Object.
                                    SVMXC__SPM_Contract_Up_Time__c upTimeDetail = new SVMXC__SPM_Contract_Up_Time__c();
                                    upTimeDetail.SVMXC__Installed_Product__c = objCovPro.SVMXC__Installed_Product__c;
                                    upTimeDetail.SVMXC__Contract__c = objCovPro.SVMXC__Service_Contract__c;                                
                                    upTimeDetail.SVMXC__Account__c = strAccountId;
                                    upTimeDetail.SVMXC__Gauranteed_Up_Time__c = GauranteedUpTime;
                                    upTimeDetail.SVMXC__Start_Date__c = firstDate;
                                    upTimeDetail.SVMXC__End_Date__c = lastDate;
                                    upTimeDetail.SVMXC__Configuration_Name__c = strConfigurationName;
                                    upTimeDetail.SVMXC__Calculation_Method__c = strCalculationMethod;
                                    upTimeDetail.SVMXC__Run_On__c=currentBatchRunDatetime;
                                    
                                    performFieldMapping(mapContractIdVsCRecord.get(objCovPro.SVMXC__Service_Contract__c), upTimeDetail); //Added for perform mapping
                                    
                                    if(!mapOldNewVsListOfUpTimeDetail.containsKey(NEW_VALUE))
                                        mapOldNewVsListOfUpTimeDetail.put(NEW_VALUE, new List<SVMXC__SPM_Contract_Up_Time__c>());
                                    mapOldNewVsListOfUpTimeDetail.get(NEW_VALUE).add(upTimeDetail);
                                }
                            
                            
                        }
                    }
                }
            }
            System.debug( LoggingLevel.DEBUG, 'SPM_ContractUpTime.populateUpTimeDetails() - exit' );
            return mapOldNewVsListOfUpTimeDetail;
        }
       
       
        /**
         * Populates the down time details for Trending of the Installation-Base by iterating through the entitled work-orders. 
         */
        private List <SVMXC__SPM_Down_Time_Detail__c> populateDownTimeListforTrending(List <SVMXC__SPM_Contract_Up_Time__c> lstUpTimeDetail, String defaultBusinessHourId, Map<String, String> mapContractIdVsBusiHourId) {
            System.debug( LoggingLevel.DEBUG, 'SPM_ContractUpTime.populateDownTimeList() - enter' );
            List<SVMXC__SPM_Down_Time_Detail__c> listDownTimeDetails = new List<SVMXC__SPM_Down_Time_Detail__c>();
            Set<String> setCoveredInstalledProduct = new Set<String>();
            Set<String> setContractId = new Set<String>();
            Set<String> setWOId = new Set<String>();
            Map<String, List<SVMXC__Service_Order__c>> mapIBCONidVsListWO = new Map<String, List<SVMXC__Service_Order__c>>();
            Map<String, List<SVMXC__Down_Time__c>> mapWOidVsListDownTime = new Map<String, List<SVMXC__Down_Time__c>>();
            Set<String> setUpTimeIds = new Set<String>();
            String configuredIBapiName = getSourceObjectField(SPM_Schema.Field.InstallProduct);
            System.debug( LoggingLevel.DEBUG, 'configuredIBapiName: '+configuredIBapiName);
            
            //Added for the user story SPM-243(Enhancement)
            String configuredStartDateApiName = getSourceObjectField(SPM_Schema.Field.CreatedDate);
            String configuredClosedDateApiName = getSourceObjectField(SPM_Schema.Field.ClosedOn);
            String strDownTimeFrom = getSourceObjectField(SPM_Schema.Field.considerDownTimeFrom);
            System.debug( LoggingLevel.DEBUG, 'configuredStartDateApiName: '+configuredStartDateApiName);
            System.debug( LoggingLevel.DEBUG, 'configuredClosedDateApiName: '+configuredClosedDateApiName);
            System.debug( LoggingLevel.DEBUG, 'strDownTimeFrom: '+strDownTimeFrom);

            //Creating sets of IB ids, Contract ids and Up-Time detail record ids
            for(SVMXC__SPM_Contract_Up_Time__c upTimeDetail: lstUpTimeDetail){
                setCoveredInstalledProduct.add(upTimeDetail.SVMXC__Installed_Product__c);
                setContractId.add(upTimeDetail.SVMXC__Contract__c);
                setUpTimeIds.add(upTimeDetail.id);
            }
            
            //Logic to get Start and End date of previous month
            Time tm = Time.newInstance(0,0,0,0);
            Date lstMonthDate =  Date.today().addMonths(-1);
            Date firstDate = lstMonthDate.toStartOfMonth();  
            Date lastDate = firstDate.addDays(date.daysInMonth(lstMonthDate.year() , lstMonthDate.month()) -1);
            DateTime firstDateTime = Datetime.newInstance(firstDate, tm);
            DateTime lastDateTime = Datetime.newInstance(lastDate.addDays(1), tm);
            System.debug(firstDateTime  + ' ------ ' + lastDateTime);
            
            List<String> queryFields = new List<String> {'Id', 'SVMXC__Is_PM_Work_Order__c','SVMXC__Service_Contract__c'};
            queryFields.add(configuredIBapiName);
            
            String strWorkOrderQuery = 'SELECT Id, SVMXC__Is_PM_Work_Order__c, SVMXC__Service_Contract__c, '+ configuredIBapiName +' FROM SVMXC__Service_Order__c WHERE '+configuredIBapiName+' IN: setCoveredInstalledProduct AND SVMXC__Service_Contract__c IN: setContractId';
            
            if(configuredClosedDateApiName != null && configuredStartDateApiName != null){
                queryFields.add(configuredClosedDateApiName);
                queryFields.add(configuredStartDateApiName);
                strWorkOrderQuery = 'SELECT Id, SVMXC__Is_PM_Work_Order__c, SVMXC__Service_Contract__c, '+ configuredClosedDateApiName +', '+ configuredIBapiName +', '+ configuredStartDateApiName +' FROM SVMXC__Service_Order__c WHERE '+configuredIBapiName+' IN: setCoveredInstalledProduct AND SVMXC__Service_Contract__c IN: setContractId';
            }
            
            if(strDownTimeFrom != null && strDownTimeFrom.equalsIgnoreCase(WORK_ORDER) && configuredClosedDateApiName != null && configuredStartDateApiName != null){
                strWorkOrderQuery += ' AND '+configuredStartDateApiName+' != null AND '+configuredClosedDateApiName+' != null AND '+configuredClosedDateApiName+' >=:  firstDateTime AND '+configuredClosedDateApiName+' <=: lastDateTime';
            }
            
            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__Service_Order__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            //Fetching where clause from the configuration
            String whereClause = getExpressionCriteria( SPM_Schema.ExpressionType.WorkOrderCriteria);
            System.debug( LoggingLevel.DEBUG, 'whereClause: '+whereClause);
            
            if(whereClause != null && whereClause != '' && whereClause.length()>0)
                strWorkOrderQuery += ' AND (' + whereClause + ')';
            System.debug( LoggingLevel.DEBUG, 'strWorkOrderQuery: '+strWorkOrderQuery);
            
            List<SVMXC__Service_Order__c> lstWorkOrders = new List<SVMXC__Service_Order__c>();
            if(strWorkOrderQuery != null && strWorkOrderQuery.length()>0)
                lstWorkOrders = Database.query(strWorkOrderQuery);
            
            //Collecting Work order Ids and creating map of UniqueKey(Combination of Top-level IB id and Contract id) and list of WO
            if(lstWorkOrders != null && lstWorkOrders.size()>0){
                System.debug( LoggingLevel.DEBUG, 'lstWorkOrders size: '+lstWorkOrders.size());
                addInfo('Number of Work Orders: '+lstWorkOrders.size());
                for(SVMXC__Service_Order__c objWO : lstWorkOrders){
                    setWOId.add(objWO.id);
                    
                    //Creating unique by concatenating Top Level ID and Contract Id
                    String strUniqueKey = objWO.SVMXC__Service_Contract__c +''+ objWO.get(configuredIBapiName);
                    if(!mapIBCONidVsListWO.containsKey(strUniqueKey))
                        mapIBCONidVsListWO.put(strUniqueKey, new List<SVMXC__Service_Order__c>());
                    mapIBCONidVsListWO.get(strUniqueKey).add(objWO);
                }
            }
            System.debug( LoggingLevel.DEBUG, 'mapIBCONidVsListWO size: '+mapIBCONidVsListWO.size());
            
            //Querying Downtime records based on Qualified WO ids and Start time greater than LastExecutionDate
            List<SVMXC__Down_Time__c> lstDownTime;
            if(strDownTimeFrom == null || (strDownTimeFrom != null && strDownTimeFrom.equalsIgnoreCase(DOWN_TIME))){
                queryFields = new List<String> {'SVMXC__duration__c', 'SVMXC__Start_Time__c','SVMXC__End_Time__c','SVMXC__Service_Order__c'};
                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__Down_Time__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                lstDownTime = [SELECT SVMXC__duration__c, SVMXC__Start_Time__c, SVMXC__End_Time__c, SVMXC__Service_Order__c FROM SVMXC__Down_Time__c WHERE SVMXC__Service_Order__c IN: setWOId AND SVMXC__Start_Time__c <=: lastDateTime AND SVMXC__Start_Time__c >=: firstDateTime];
                System.debug( LoggingLevel.DEBUG, 'lstDownTime size: '+lstDownTime.size());
                addInfo('Total Number of DownTimes for all qualified work order: '+lstDownTime.size());
                
                //Creating map of Work order Ids and List of Downtime
                for(SVMXC__Down_Time__c objDT : lstDownTime){
                    if(!mapWOidVsListDownTime.containsKey(objDT.SVMXC__Service_Order__c))
                        mapWOidVsListDownTime.put(objDT.SVMXC__Service_Order__c, new List<SVMXC__Down_Time__c>());
                    mapWOidVsListDownTime.get(objDT.SVMXC__Service_Order__c).add(objDT);
                }
            }
            
            //Querying existing Down Time Detail records based on Work order ids and Up-Time record ids
            queryFields = new List<String> {'Id', 'SVMXC__Down_Time__c','SVMXC__Work_Order__c','SVMXC__Down_On__c','SVMXC__Up_Time_Detail__c'};
            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__SPM_Down_Time_Detail__c', queryFields, COMM_SecurityUtils.Access.Accessible)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            List<SVMXC__SPM_Down_Time_Detail__c> lstExistingDownTimeDetail = [SELECT Id, SVMXC__Down_Time__c, SVMXC__Work_Order__c, SVMXC__Down_On__c, SVMXC__Up_Time_Detail__c FROM SVMXC__SPM_Down_Time_Detail__c WHERE SVMXC__Work_Order__c IN: setWOId AND SVMXC__Up_Time_Detail__c IN: setUpTimeIds];
            
            if(lstExistingDownTimeDetail.size()>0){
                //Deleting all the SPM down time records for the qualified SPM UpTime records.
                //If the engine runs with configuration DOWN_TIME and creates some entries with different dates then we cannot identify which downtime we have to update when engine runs with configuration WORK_ORDER.So we will delete all the down time records which was created in the first engine run and create again all the downTime records.
                delete lstExistingDownTimeDetail;
                lstExistingDownTimeDetail.clear();
            }
            
            for(SVMXC__SPM_Contract_Up_Time__c upTimeDetail: lstUpTimeDetail){
                //Getting business hour id from service contract (by default it is set to default business hour)
                String strContractId = upTimeDetail.SVMXC__Contract__c;
                String objBusinessHoursId = '';
                if(mapContractIdVsBusiHourId != null && mapContractIdVsBusiHourId.size()>0 && mapContractIdVsBusiHourId.containsKey(strContractId) && mapContractIdVsBusiHourId.get(strContractId) != null){
                    objBusinessHoursId = mapContractIdVsBusiHourId.get(strContractId);
                }
                else
                    objBusinessHoursId = defaultBusinessHourId;
                
                //Fetching Work orders from the map based on uniquekey
                String strUniqueKey = upTimeDetail.SVMXC__Contract__c +''+ upTimeDetail.SVMXC__Installed_Product__c;
                lstWorkOrders = new List<SVMXC__Service_Order__c>();
                if(mapIBCONidVsListWO.containsKey(strUniqueKey))
                    lstWorkOrders = mapIBCONidVsListWO.get(strUniqueKey);
                
                for(SVMXC__Service_Order__c objWorkOrder : lstWorkOrders){
                    Map<Date, Long> mapStartTimeVsDownTimeSum = new Map<Date, Long>();
                    Map<Date, SVMXC__SPM_Down_Time_Detail__c> mapDateVsNewDownTimeRecord = new Map<Date, SVMXC__SPM_Down_Time_Detail__c>();
                    
                    //Added for the user story SPM-243
                    if(strDownTimeFrom != null && strDownTimeFrom.equalsIgnoreCase(WORK_ORDER) && configuredClosedDateApiName != null && configuredStartDateApiName != null){
                        Long duration = 0;
                        DateTime dtCreatedDateTime = (DateTime)objWorkOrder.get(configuredStartDateApiName);
                        DateTime dtClosedDateTime = (DateTime)objWorkOrder.get(configuredClosedDateApiName);
                        if(dtClosedDateTime != null)
                            duration = (Long)(BusinessHours.diff(objBusinessHoursId, dtCreatedDateTime, dtClosedDateTime)/MILLI_SEC_TO_MINUTES);
                        
                        if(duration > 0){
                            SVMXC__SPM_Down_Time_Detail__c downTimeDetail = new SVMXC__SPM_Down_Time_Detail__c();
                            downTimeDetail.SVMXC__Up_Time_Detail__c = upTimeDetail.id;
                            downTimeDetail.SVMXC__Down_On__c = dtCreatedDateTime.date();
                            downTimeDetail.SVMXC__Down_Time__c = duration;
                            downTimeDetail.SVMXC__Is_PM_Work_Order__c = objWorkOrder.SVMXC__Is_PM_Work_Order__c;
                            downTimeDetail.SVMXC__Work_Order__c = objWorkOrder.id;
                            downTimeDetail.SVMXC__Run_On__c=currentBatchRunDatetime;
                            listDownTimeDetails.add(downTimeDetail);
                        }
                    }
                    else{
                        //Fetching Down time records from the map based on Work order ids
                        lstDownTime = new List<SVMXC__Down_Time__c>();
                        if(mapWOidVsListDownTime != null && mapWOidVsListDownTime.containsKey(objWorkOrder.id))
                            lstDownTime = mapWOidVsListDownTime.get(objWorkOrder.id);
                        
                        //Calculating Downtime value
                        for(SVMXC__Down_Time__c downTime: lstDownTime){
                            //Checking whether the Downtime is captured within the contract period or not
                            if(mapUniqueIdVsContractStartEndDate.containsKey(strUniqueKey)){
                                Map<String, Date> tempMap = mapUniqueIdVsContractStartEndDate.get(strUniqueKey);
                                Date startDate = tempMap.get('START');
                                Date endDate = tempMap.get('END');
                                if(downTime.SVMXC__Start_Time__c.Date() < startDate || downTime.SVMXC__Start_Time__c.Date() > endDate){
                                    continue;
                                }
                            }
                            
                            //Calculating Downtime value
                            Long duration = 0;
                            if(downTime.SVMXC__duration__c != null && downTime.SVMXC__duration__c > 0)
                                duration = (Long)downTime.SVMXC__duration__c;
                            else if(downTime.SVMXC__Start_Time__c != null && downTime.SVMXC__End_Time__c != null){
                                DateTime tempEndTime;
                                if(downTime.SVMXC__End_Time__c > lastDateTime)
                                    tempEndTime = lastDateTime;
                                else
                                    tempEndTime = downTime.SVMXC__End_Time__c;
                                duration = (Long)(BusinessHours.diff(objBusinessHoursId, downTime.SVMXC__Start_Time__c, tempEndTime)/MILLI_SEC_TO_MINUTES);
                            }
                            if(downTime.SVMXC__Start_Time__c != null){
                                Date dtTemp = downTime.SVMXC__Start_Time__c.date();
                                SVMXC__SPM_Down_Time_Detail__c downTimeDetail = new SVMXC__SPM_Down_Time_Detail__c();
                                    downTimeDetail.SVMXC__Down_On__c = dtTemp;
                                    downTimeDetail.SVMXC__Down_Time__c = duration;
                                    downTimeDetail.SVMXC__Is_PM_Work_Order__c = objWorkOrder.SVMXC__Is_PM_Work_Order__c;
                                    downTimeDetail.SVMXC__Up_Time_Detail__c = upTimeDetail.id;
                                    downTimeDetail.SVMXC__Work_Order__c = objWorkOrder.id;
                                    downTimeDetail.SVMXC__Run_On__c=currentBatchRunDatetime;
                                    mapDateVsNewDownTimeRecord.put(dtTemp, downTimeDetail);
                                
                                
                            }
                        }
                    }
                    
                    if(mapDateVsNewDownTimeRecord != null && mapDateVsNewDownTimeRecord.size() > 0){
                        listDownTimeDetails.addAll(mapDateVsNewDownTimeRecord.values());
                    }
                }
            }
            System.debug( LoggingLevel.DEBUG, 'SPM_ContractUpTime.populateDownTimeList() - exit' );
            return listDownTimeDetails;
        }
    /**
     * 
     */
    global override void onFinishComplete() {
      System.debug( LoggingLevel.DEBUG, 'SPM_ContractUpTime.onFinishComplete()' );
    }
  }