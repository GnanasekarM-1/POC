global with sharing class SCON_Scheduler implements Schedulable
{
    global static String strCurrFireTime;
    global static String strDay;
    global static String strDate;
    global static String strDispatchTimeZone;
    global boolean isTestClass = false;
    global datetime startTime;
    global void execute(SchedulableContext scSCONScheduler)
    {
        startTime = system.now();
        system.debug('scSCONScheduler'+scSCONScheduler);
        CronTrigger ctSCONScheduler = null;    
        dateTime dtCurrFire;
        integer intBatchLimit = 5, intBatchSize = 1;
        List<SVMXC__ServiceMax_Config_Data__c>  lstSchedules = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c>  lstSchatCurrFireTime = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        if(isTestClass)
        {  
            //This condition is only to make test class success full.
            dtCurrFire = Datetime.now();
            strCurrFireTime = '4:00 PM';
            strDispatchTimeZone = 'Asia/Calcutta';
        }else
        {
            ctSCONScheduler = [SELECT Id, CronExpression, NextFireTime From CronTrigger WHERE Id =: scSCONScheduler.getTriggerId()];
        //  Finding the current fire date time(GMT)
            dtCurrFire = ctSCONScheduler.NextFireTime.addHours(-1);
            strCurrFireTime = dtCurrFire.formatGmt('h:mm a');
        }
        strDay = dtCurrFire.formatGmt('EEEE'); 
        strDate = string.valueOf(dtCurrFire.dayGmt());
        
        system.debug(LoggingLevel.WARN, 'Date: '+ strDate +' : Day: '+ strDay +' : Time: '+ strCurrFireTime);
         // Added SVMXC__Internal_Value__c to SOQL for BAC-5411
        lstSchedules = [Select id, SVMXC__Internal_Value__c, SVMXC__Run_At__c, SVMXC__Schedule_Days__c, SVMXC__Day_To_Run__c, SVMXC__Sequence__c, SVMXC__SM_Prior_Timesheet_Periods__c, 
                                SVMXC__Dispatch_Process__c, SVMXC__Dispatch_Process__r.SVMXC__Name__c, SVMXC__Dispatch_Process__r.SVMXC__ProcessID__c, SVMXC__Active__c, SVMXC__Previous_Execution_Started_On__c, 
                                SVMXC__Dispatch_Process__r.SVMXC__Assign_To_Dispatcher__c, SVMXC__Dispatch_Process__r.RecordType.Name, SVMXC__Dispatch_Process__r.SVMXC__SM_Process_Type__c, SVMXC__Unprocessed__c, SVMXC__Period__c, SVMXC__Previous_Execution_Completed_On__c,
                                SVMXC__Run_Type__c, SVMXC__Enter_Date__c, SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Timezone__c , SVMXC__Schedule_Type__c,SVMXC__Period_Start_On__c, SVMXC__Period_End_On__c 
                                from SVMXC__ServiceMax_Config_Data__c 
                                    where RecordType.Name = 'Schedule' 
                                        AND  SVMXC__Dispatch_Process__r.SVMXC__Active__c = true 
                                            AND (SVMXC__Dispatch_Process__r.RecordType.Name = 'Work Order Billing Process' 
                                                OR SVMXC__Dispatch_Process__r.RecordType.Name = 'Contract Billing Process' 
                                                OR SVMXC__Dispatch_Process__r.RecordType.Name = 'PM Process'  
                                                OR SVMXC__Dispatch_Process__r.RecordType.Name = 'Schedule Header' 
                                                OR SVMXC__Dispatch_Process__r.RecordType.Name = 'Timesheet'
                                                OR SVMXC__Dispatch_Process__r.RecordType.Name = 'SPM Rule')];  
        
        system.debug(LoggingLevel.WARN, 'Number of Schedules at current Fire Time: '+ lstSchedules.size());
        for(SVMXC__ServiceMax_Config_Data__c confdata : lstSchedules)
        {  
            if(confdata.SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Timezone__c == null || confdata.SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Timezone__c == '')
            {
                system.debug('Invalid: Schedule definitions: ' + confdata);
                continue;
            }
            if(confdata.SVMXC__Unprocessed__c == true)
            {
                lstSchatCurrFireTime.Add(confdata);
                continue;
            }           
            //Getting the current fire datetime's time in the time zone given in Schedule information(Dispatch_Timezone)
            if(!isTestClass)
            {
                strDispatchTimeZone = confdata.SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Timezone__c;
                strCurrFireTime = dtCurrFire.format('h:mm a', strDispatchTimeZone); 
            }   
            
            system.debug('TimeZone: ' + confdata.SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Timezone__c);
            system.debug('CurrFireDate: ' + strCurrFireTime);
                
            system.debug(LoggingLevel.WARN, 'strCurrFireTime'+strCurrFireTime+'SVMXC__Run_At__c'+confdata.SVMXC__Run_At__c);
            
            if(confdata.SVMXC__Run_At__c == strCurrFireTime)
            {       
                if(confdata.SVMXC__Run_Type__c == 'Day of Week') 
                {
                    //Getting current fire datetime's day of week in the time zone given in Schedule information(Dispatch_Timezone)
                    strDay = dtCurrFire.format('EEEE', strDispatchTimeZone); 
                    system.debug('Came for Day of week' + confdata.SVMXC__Schedule_Days__c + '----' + strDay);
                    if(confdata.SVMXC__Schedule_Days__c.contains(strDay))
                        lstSchatCurrFireTime.Add(confdata);        
                }   
                else if(confdata.SVMXC__Run_Type__c == 'Date of Month')
                {
                    //Getting current fire datetime's day of month in the time zone given in Schedule information(Dispatch_Timezone)
                    strDate = dtCurrFire.format('d', strDispatchTimeZone);
                    system.debug('Came for Date of month' + confdata.SVMXC__Day_To_Run__c + '------' + strDate);
                    if(confdata.SVMXC__Day_To_Run__c == strDate)
                        lstSchatCurrFireTime.Add(confdata);                                      
                }
            }
        }   
        lstSchedules.clear();
        lstSchedules.addall(lstSchatCurrFireTime);
        system.debug(LoggingLevel.WARN, 'Number of Schedules at current Fire Time: '+ lstSchedules.size()+'lstSchedules val'+lstSchedules);
        
        if(lstSchedules != null && lstSchedules.size() > 0)
        {
            map<string, Map<String, String>> mapSubmoduleIdMapSettingIdValue = new map<string, Map<String, String>>(); 
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
            list<string> lstSubModuleId = new list<string>();
            lstSubModuleId.add('GLOB001');
            lstSubModuleId.add('PINV001');
            lstSubModuleId.add('PINV002');
            lstSubModuleId.add('PINV003');
            lstSubModuleId.add('PREV003');
            lstSubModuleId.add('SFM005');
            lstSubModuleId.add('TMST001'); // Added for 044977 enhancement 
            mapSubmoduleIdMapSettingIdValue = commSettings.SVMX_getSettingList(lstSubModuleId);
            
            map<String,String> mapGlobalSettingIdValue = new map<String,String>(); 
            if(mapSubmoduleIdMapSettingIdValue.containskey('GLOB001'))
                mapGlobalSettingIdValue = mapSubmoduleIdMapSettingIdValue.get('GLOB001'); 
            if(mapGlobalSettingIdValue.containskey('GBL020'))
                intBatchLimit = integer.valueOf(mapGlobalSettingIdValue.get('GBL020'));
            system.debug(LoggingLevel.WARN, 'Batch Limit: ' + intBatchLimit);
            
                
            // For Scheduled SFMs
            map<String,String> mapSFM005SettingIdValue = new map<String,String>();
            if(mapSubmoduleIdMapSettingIdValue.containskey('SFM005'))
                mapSFM005SettingIdValue = mapSubmoduleIdMapSettingIdValue.get('SFM005'); 
            if(mapSFM005SettingIdValue.containsKey('SET001'))
                intBatchSize = integer.valueOf(mapSFM005SettingIdValue.get('SET001'));
            
            try{
                executeScheduleSFMEngine(lstSchedules, intBatchLimit, intBatchSize, startTime);
            }
            catch(Exception ex){
                
            }
            
            //For Work Order Performa Invoice
            intBatchSize = 1;
            map<String,String> mapPINV001SettingIdValue = new map<String,String>();
            if(mapSubmoduleIdMapSettingIdValue.containskey('PINV001'))
                mapPINV001SettingIdValue = mapSubmoduleIdMapSettingIdValue.get('PINV001'); 
            if(mapPINV001SettingIdValue.containsKey('SET001'))
                intBatchSize = integer.valueOf(mapPINV001SettingIdValue.get('SET001'));
              
            try
            { 
                //Processing Work Order Proforma Invoice Generation Engine
                executeWOBillingEngine(lstSchedules, intBatchLimit, intBatchSize);
            }
            catch(Exception ex)
            {
            
            }
            //For Service Contract Proforma Invoice Generation Engine
            intBatchSize = 1;
            map<String,String> mapPINV002SettingIdValue = new map<String,String>();
            if(mapSubmoduleIdMapSettingIdValue.containskey('PINV002'))
                mapPINV002SettingIdValue = mapSubmoduleIdMapSettingIdValue.get('PINV002'); 
            if(mapPINV002SettingIdValue.containsKey('SET001'))
                intBatchSize = integer.valueOf(mapPINV002SettingIdValue.get('SET001'));
              
            try
            {  
                //Processing Service Contract Proforma Invoice Generation Engine
                executeSCBillingEngine(lstSchedules, intBatchLimit, intBatchSize);
            }
            catch(Exception ex)
            {
            
            }
            // For PM Engine
            intBatchSize = 1;
            map<String,String> mapPREV003SettingIdValue = new map<String,String>();
            if(mapSubmoduleIdMapSettingIdValue.containskey('PREV003'))
                mapPREV003SettingIdValue = mapSubmoduleIdMapSettingIdValue.get('PREV003'); 
            /*
                if(mapPINV003SettingIdValue.containsKey('SET001'))
                    intBatchSize = integer.valueOf(mapPINV003SettingIdValue.get('SET001'));
            */        
                
            try
            {  
               //Processing PM Engine
                executePMEngine(lstSchedules, intBatchLimit, mapPREV003SettingIdValue);
            }
            catch(Exception ex)
            {
            
            }
            
            // For Timesheet Engine
            intBatchSize = 1;
            if(!mapSubmoduleIdMapSettingIdValue.containsKey('GBL027') || Boolean.valueOf( mapSubmoduleIdMapSettingIdValue.get('GBL027') ) ) {  
                try
                {  
                     // Added for 044977 enhancement 
                    if(mapSubmoduleIdMapSettingIdValue.containsKey('TMST001')){
                        map<String,String> mapTMSTSettingIdValue = new map<String,String>();
                        mapTMSTSettingIdValue = mapSubmoduleIdMapSettingIdValue.get('TMST001'); 
                        if(mapTMSTSettingIdValue.containsKey('SET001'))
                            intBatchSize = integer.valueOf(mapTMSTSettingIdValue.get('SET001'));
                    }
                    //End for 044977 enhancement
                    //Processing Timesheet Engine
                    executeTimesheetEngine(lstSchedules, intBatchLimit, intBatchSize);
                }
                catch(Exception ex)
                {
                    
                }
            }
            
            //For Counter Reading
            intBatchSize = 1;
            try
            {  
                //Processing Counter Details
                executeCounterBatch(lstSchedules, intBatchLimit, intBatchSize);
            }
            catch(Exception ex)
            {
                
            } 
            
            //For SPM Schedule
            try{
                executeSPMEngine(lstSchedules, intBatchLimit, intBatchSize);
            }
            catch(Exception ex) {
                
                System.debug( LoggingLevel.ERROR, 'Error executing SPM engine; exception: ' + ex.getMessage() );
                System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );                
            }
        }
    }
    
    // T
    public void executeScheduleSFMEngine(List<SVMXC__ServiceMax_Config_Data__c> lstSchedules, integer intBatchLimit, integer intBatchSize,datetime startTime)
    {
        Boolean isUnprocessed = false;
        List<AsyncApexJob> lstApexJob = new List<AsyncApexJob>(); 
        List<SVMXC__ServiceMax_Config_Data__c>  lstSchsToUpdate = new List<SVMXC__ServiceMax_Config_Data__c>();
        Set<String> setProcessIds = new Set<String>();
        SFM_ExecuteScheduledSFM_Batch executeScheduleSFM = new SFM_ExecuteScheduledSFM_Batch();
        executeScheduleSFM.setProIds = new set<string>();
        executeScheduleSFM.dateTimeStart = startTime;
        
        for(SVMXC__ServiceMax_Config_Data__c sch : lstSchedules){
            if(sch.SVMXC__Dispatch_Process__r.RecordType.Name == 'Schedule Header'){
                executeScheduleSFM.setProIds.add(sch.SVMXC__Dispatch_Process__c);
                setProcessIds.add(sch.SVMXC__Dispatch_Process__c);
                lstSchsToUpdate.add(sch);
            }
        }
        
        // For Sum 15, along wth scheduled SFM we are creating schedule services which have schedule type = 'services'. 
        // Therefore, process schedule SFM engine only when Schedule type = null or ''
        List<SVMXC__ServiceMax_Config_Data__c> listSFMSchDetail = [Select ID FROM SVMXC__ServiceMax_Config_Data__c
                                                                            WHERE SVMXC__Dispatch_Process__c IN : setProcessIds 
                                                                                AND RecordType.Name = 'Schedule Detail' AND (SVMXC__Schedule_Type__c = null OR SVMXC__Schedule_Type__c = '')];
        
        lstApexJob = [SELECT Id, Status FROM AsyncApexJob Where JobType = 'BatchApex' AND (Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing')];
        system.debug(LoggingLevel.WARN, system.label.CONF039_TAG025+': '+ lstApexJob.size());
        
        if(listSFMSchDetail != null && listSFMSchDetail.size() > 0){
            if(lstApexJob.size() < intBatchLimit){
                system.debug(LoggingLevel.WARN, system.label.CONF039_TAG026+': '+ executeScheduleSFM.setProIds.size());
                if(executeScheduleSFM.setProIds != null && executeScheduleSFM.setProIds.size() > 0)
                    database.executebatch(executeScheduleSFM, intBatchSize);
                for(SVMXC__ServiceMax_Config_Data__c sch : lstSchsToUpdate)
                    sch.SVMXC__Unprocessed__c = false;
            }
            else{
                for(SVMXC__ServiceMax_Config_Data__c sch : lstSchsToUpdate)
                    sch.SVMXC__Unprocessed__c = true;
                    isUnprocessed = true;
            }
            if(lstSchsToUpdate != null && lstSchsToUpdate.size() > 0)
                update lstSchsToUpdate;
            if(isUnprocessed){
                sendEmailForUnprocessedSchedule(lstSchsToUpdate);
            } 
        }
    }
    
    public void executeWOBillingEngine(List<SVMXC__ServiceMax_Config_Data__c> lstSchedules, integer intBatchLimit, integer intBatchSize)
    {
        List<AsyncApexJob> lstApexJob = new List<AsyncApexJob>(); 
        List<SVMXC__ServiceMax_Config_Data__c>  lstSchsToUpdate = new List<SVMXC__ServiceMax_Config_Data__c>();
        PINV_WOInvoice_Batch batchWOInvClsObj = new PINV_WOInvoice_Batch();
        batchWOInvClsObj.setProIds = new set<string>();
        
        for(SVMXC__ServiceMax_Config_Data__c sch : lstSchedules)
        {
            if(sch.SVMXC__Dispatch_Process__r.RecordType.Name.toUpperCase() == 'WORK ORDER BILLING PROCESS')
            {
                batchWOInvClsObj.setProIds.add(sch.SVMXC__Dispatch_Process__c);
                lstSchsToUpdate.add(sch);
            }
        }
        
        lstApexJob = [SELECT Id, Status FROM AsyncApexJob Where JobType = 'BatchApex' AND (Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing')];
        system.debug(LoggingLevel.WARN, 'Number of Batch Jobs in Processing: '+ lstApexJob.size());
        
        if(lstApexJob.size() < intBatchLimit)
        {
            system.debug(LoggingLevel.WARN, 'Number of WO Billing Processses to batch: '+ batchWOInvClsObj.setProIds.size());
            if(batchWOInvClsObj.setProIds != null && batchWOInvClsObj.setProIds.size() > 0)
                database.executebatch(batchWOInvClsObj, intBatchSize);
            for(SVMXC__ServiceMax_Config_Data__c sch : lstSchsToUpdate)
                sch.SVMXC__Unprocessed__c = false;
        }
        else
        {
            for(SVMXC__ServiceMax_Config_Data__c sch : lstSchsToUpdate)
                sch.SVMXC__Unprocessed__c = true;
        }
        
        if(lstSchsToUpdate != null && lstSchsToUpdate.size() > 0)
            update lstSchsToUpdate;
    }
    
    public void executeSCBillingEngine(List<SVMXC__ServiceMax_Config_Data__c> lstSchedules, integer intBatchLimit, integer intBatchSize)
    {
        List<AsyncApexJob> lstApexJob = new List<AsyncApexJob>(); 
        List<SVMXC__ServiceMax_Config_Data__c>  lstSchsToUpdate = new List<SVMXC__ServiceMax_Config_Data__c>();
        PINV_SCInvoice_Batch batchSCInvClsObj = new PINV_SCInvoice_Batch();
        batchSCInvClsObj.setProIds = new set<string>();
        
        for(SVMXC__ServiceMax_Config_Data__c sch : lstSchedules)
        {
            if(sch.SVMXC__Dispatch_Process__r.RecordType.Name.toUpperCase() == 'CONTRACT BILLING PROCESS')
            {
                batchSCInvClsObj.setProIds.add(sch.SVMXC__Dispatch_Process__c);
                lstSchsToUpdate.add(sch);
            }
        }
        system.debug(LoggingLevel.WARN, 'Number of Contract Billing Processses to batch: '+ batchSCInvClsObj.setProIds.size());
        
        lstApexJob = [SELECT Id, Status FROM AsyncApexJob Where JobType = 'BatchApex' AND (Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing')];
        system.debug(LoggingLevel.WARN, 'Number of Batch Jobs in Processing after adding the WO Billing Engine Batch: '+ lstApexJob.size());
        
        if(lstApexJob.size() < intBatchLimit)
        {
            if(batchSCInvClsObj.setProIds != null && batchSCInvClsObj.setProIds.size() > 0)
                database.executebatch(batchSCInvClsObj, intBatchSize);
            for(SVMXC__ServiceMax_Config_Data__c sch : lstSchsToUpdate)
                    sch.SVMXC__Unprocessed__c = false;
        }
        else
        {
            for(SVMXC__ServiceMax_Config_Data__c sch : lstSchsToUpdate)
                sch.SVMXC__Unprocessed__c = true;
        }
        
        if(lstSchsToUpdate != null && lstSchsToUpdate.size() > 0)
            update lstSchsToUpdate;
    }
    
    
    public void executePMEngine(List<SVMXC__ServiceMax_Config_Data__c> lstSchedules, integer intBatchLimit, Map<String,String> mapPREV003SettingIdValue)
    {   
        integer intBatchSize = 1;
        List<AsyncApexJob> lstApexJob = new List<AsyncApexJob>();
        List<SVMXC__ServiceMax_Config_Data__c>  lstSchsToUpdate = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        
        Set<String> setTimeProcessIds = new Set<String>();
        Set<String> setConditionProcessIds = new Set<String>();
        
        for(SVMXC__ServiceMax_Config_Data__c sch : lstSchedules)
        {
            if(sch.SVMXC__Dispatch_Process__r.RecordType.Name == 'PM PROCESS')
            {
                if(sch.SVMXC__Dispatch_Process__r.SVMXC__SM_Process_Type__c == null || sch.SVMXC__Dispatch_Process__r.SVMXC__SM_Process_Type__c == 'TIME_BASED_PM'){
                    setTimeProcessIds.add(sch.SVMXC__Dispatch_Process__c);
                    

                }else if(sch.SVMXC__Dispatch_Process__r.SVMXC__SM_Process_Type__c == 'CONDITION_BASED_PM'){
                    setConditionProcessIds.add(sch.SVMXC__Dispatch_Process__c);
                    
                }
                lstSchsToUpdate.add(sch);
            }
        }
        system.debug(LoggingLevel.WARN, 'Number of Time Based PM Process to batch: '+ setTimeProcessIds.size());
        system.debug(LoggingLevel.WARN, 'Number of Condition Based PM Process to batch: '+ setConditionProcessIds.size());
        
        lstApexJob = [SELECT Id, Status FROM AsyncApexJob Where JobType = 'BatchApex' AND (Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing')];
        system.debug(LoggingLevel.WARN, 'Number of Batch Jobs in Processing after adding the Contract Billing Engine Batch: '+ lstApexJob.size());
        
        if(lstApexJob.size() < intBatchLimit)
        {
            if(!setTimeProcessIds.isEmpty()){

                if(mapPREV003SettingIdValue.containsKey('SET001'))
                    intBatchSize = integer.valueOf(mapPREV003SettingIdValue.get('SET001'));

                PREV_Engine_Batch batchPREVEngClsObj = new PREV_Engine_Batch();
                batchPREVEngClsObj.setProcessIds = setTimeProcessIds;
                database.executebatch(batchPREVEngClsObj, intBatchSize);
            }

            if(!setConditionProcessIds.isEmpty()){

                if(mapPREV003SettingIdValue.containsKey('SET003'))
                    intBatchSize = integer.valueOf(mapPREV003SettingIdValue.get('SET003'));


                PREV_Conditional_Engine_Batch conditionalEngineBatch = new PREV_Conditional_Engine_Batch();
                conditionalEngineBatch.setProcessIds = setConditionProcessIds;
                database.executebatch(conditionalEngineBatch, intBatchSize);
            }

            for(SVMXC__ServiceMax_Config_Data__c sch : lstSchsToUpdate)
                    sch.SVMXC__Unprocessed__c = false;
        }
        else
        {
            for(SVMXC__ServiceMax_Config_Data__c sch : lstSchsToUpdate)
                sch.SVMXC__Unprocessed__c = true;
        }
        
        if(lstSchsToUpdate != null && lstSchsToUpdate.size() > 0)
            update lstSchsToUpdate;
    }
    
    public void executeTimesheetEngine(List<SVMXC__ServiceMax_Config_Data__c> lstSchedules, integer intBatchLimit, integer intBatchSize){
        Boolean isUnprocessed = false;
        List<AsyncApexJob> lstApexJob = new List<AsyncApexJob>();
        List<SVMXC__ServiceMax_Config_Data__c>  lstSchsToUpdate = new List<SVMXC__ServiceMax_Config_Data__c>();
        for(SVMXC__ServiceMax_Config_Data__c sch : lstSchedules){
            if(sch.SVMXC__Dispatch_Process__r.RecordType.Name == 'Timesheet')
                lstSchsToUpdate.add(sch);
        }
        
        for(SVMXC__ServiceMax_Config_Data__c schRec : lstSchedules){
            lstApexJob = [SELECT Id, Status FROM AsyncApexJob Where JobType = 'BatchApex' AND (Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing')];
            system.debug(LoggingLevel.WARN, 'Number of Batch Jobs in Processing after adding the Timesheet Batch: '+ lstApexJob.size());
            if(schRec.SVMXC__Dispatch_Process__r.RecordType.Name == 'Timesheet'){
                if(lstApexJob.size() < intBatchLimit){
                    TMST_TimesheetEngine batchTSEngClsObj = new TMST_TimesheetEngine();
                    batchTSEngClsObj.setProcessIds = new set<string>();
                    batchTSEngClsObj.mapTSProcessScheduler = new Map<Id, SVMXC__ServiceMax_Config_Data__c>();
                    batchTSEngClsObj.timeSheetRecordType = schRec.SVMXC__Schedule_Type__c;
                    batchTSEngClsObj.setProcessIds.add(schRec.SVMXC__Dispatch_Process__c);
                    batchTSEngClsObj.mapTSProcessScheduler.put(schRec.SVMXC__Dispatch_Process__c, schRec);
                    
                    if(batchTSEngClsObj.setProcessIds != null && batchTSEngClsObj.setProcessIds.size() > 0){
                         database.executebatch(batchTSEngClsObj, intBatchSize);
                    }
                    schRec.SVMXC__Unprocessed__c = false;
                }
                else{
                    schRec.SVMXC__Unprocessed__c = true;
                    isUnprocessed = true;
                }
            }
        } 
        
        if(lstSchsToUpdate != null && lstSchsToUpdate.size() > 0)
            update lstSchsToUpdate;
        
        if(isUnprocessed){
            sendEmailForUnprocessedSchedule(lstSchsToUpdate);
        }
    }
    
    public void executeCounterBatch(List<SVMXC__ServiceMax_Config_Data__c> lstSchedules, integer intBatchLimit, integer intBatchSize){
        Boolean isUnprocessed = false;
        List<AsyncApexJob> lstApexJob = new List<AsyncApexJob>();
        List<SVMXC__ServiceMax_Config_Data__c>  lstSchsToUpdate = new List<SVMXC__ServiceMax_Config_Data__c>();
        Set<String> setProcessIds = new Set<String>();
        
        for(SVMXC__ServiceMax_Config_Data__c sch : lstSchedules)
        {  
            if(sch.SVMXC__Dispatch_Process__r.RecordType.Name == 'Schedule Header')
            {
                setProcessIds.add(sch.SVMXC__Dispatch_Process__c);
                lstSchsToUpdate.add(sch);
            }
        }
        
        List<SVMXC__ServiceMax_Config_Data__c> listServicesSchDetail = [SELECT Id, Namespace__c,Class_Name__c, SVMXC__Batch_Size__c,
                                                                                 Previous_Execution_Completed_On__c, Previous_Execution_Status__c, 
                                                                                 Previous_Execution_Started_On__c, Object_Name__c, 
                                                                                 Expression_Rule__r.Parent_Object_Criteria__c,
                                                                                 SVMXC__Dispatch_Process__r.SVMXC__Name__c, SVMXC__Dispatch_Process__r.SVMXC__ProcessID__c, 
                                                                                 SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Timezone__c, SVMXC__Dispatch_Process__r.SVMXC__Assign_To_Dispatcher__c,
                                                                                 SVMXC__Dispatch_Process__r.SVMXC__Capture_Log__c
                                                                                    FROM SVMXC__ServiceMax_Config_Data__c
                                                                                        WHERE SVMXC__Dispatch_Process__c IN : setProcessIds 
                                                                                            AND RecordType.Name = 'Schedule Detail' AND SVMXC__Schedule_Type__c = 'Services'];
        
        if(listServicesSchDetail != null && listServicesSchDetail.size() > 0){
            for(SVMXC__ServiceMax_Config_Data__c serviceSchedulerec : listServicesSchDetail){
            
            SFM_ScheduledBatch batchCounterReadingObj = new SFM_ScheduledBatch();
            batchCounterReadingObj.scheduleDetailConfig = serviceSchedulerec;
            system.debug(LoggingLevel.WARN, 'Only 1 Schedule detail record is passed to Batch: '+ batchCounterReadingObj.scheduleDetailConfig);
            if(serviceSchedulerec.SVMXC__Batch_Size__c != null)
                intBatchSize = Integer.valueOf(serviceSchedulerec.SVMXC__Batch_Size__c);
            lstApexJob = [SELECT Id, Status FROM AsyncApexJob Where JobType = 'BatchApex' AND (Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing')];
            system.debug(LoggingLevel.WARN, 'Number of Batch Jobs in Processing after adding the Counter Reading Batch: '+ lstApexJob.size());
            if(lstApexJob.size() < intBatchLimit)
            {   
                system.debug(LoggingLevel.WARN, 'Start of batch '+ system.currentTimeMillis());
                if(batchCounterReadingObj.scheduleDetailConfig != null){
                    database.executebatch(batchCounterReadingObj, intBatchSize);
                }
    
                system.debug(LoggingLevel.WARN, 'End of batch '+ system.currentTimeMillis());
                for(SVMXC__ServiceMax_Config_Data__c sch : lstSchsToUpdate)
                        sch.SVMXC__Unprocessed__c = false;
            }
            else
            {
                for(SVMXC__ServiceMax_Config_Data__c sch : lstSchsToUpdate)
                    sch.SVMXC__Unprocessed__c = true;
                isUnprocessed = true;
            }
        }
        }
        
        if(lstSchsToUpdate != null && lstSchsToUpdate.size() > 0)
            update lstSchsToUpdate;
        
        if(isUnprocessed){
            sendEmailForUnprocessedSchedule(lstSchsToUpdate);
        }
    }
    
    public void executeSPMEngine( List<SVMXC__ServiceMax_Config_Data__c> lstSchedules, integer intBatchLimit, integer intBatchSize) {
        
        //Boolean isUnprocessed = false;
        List<AsyncApexJob> lstApexJob = new List<AsyncApexJob>();
        
        List<SVMXC__ServiceMax_Config_Data__c>  lstSchsToUpdate = new List<SVMXC__ServiceMax_Config_Data__c>();
        for(SVMXC__ServiceMax_Config_Data__c sch : lstSchedules) {
            if(sch.SVMXC__Dispatch_Process__r.RecordType.Name == 'SPM Rule') {
                lstSchsToUpdate.add(sch);
            }
        }
        
        system.debug('-------- Schedule' + lstSchsToUpdate);
        
        for(SVMXC__ServiceMax_Config_Data__c sch : lstSchsToUpdate ) {
            
            lstApexJob = [SELECT Id, Status FROM AsyncApexJob Where JobType = 'BatchApex' AND (Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing')];
            system.debug(LoggingLevel.WARN, 'Number of Batch Jobs in Processing after adding the Counter Reading Batch: '+ lstApexJob.size());
            
            String processId = sch.SVMXC__Dispatch_Process__r.SVMXC__ProcessID__c;
            
            if(lstApexJob.size() < intBatchLimit) {
                sch.SVMXC__Unprocessed__c = false;
                if( processId.equalsIgnoreCase( SPM_Schema.Report.FirstTimeFix.Name() ) ) {
                    
                    SPM_FirstTimeFix ftfBatch = new SPM_FirstTimeFix( sch );
                    database.executebatch(ftfBatch);
                } else if( processId.equalsIgnoreCase( SPM_Schema.Report.MeanTimeToRepair.Name() ) ) {
                    
                    SPM_MeanTimeToRepair mttrBatch = new SPM_MeanTimeToRepair( sch );
                    database.executebatch(mttrBatch);
                } else if( processId.equalsIgnoreCase( SPM_Schema.Report.UpDownTime.Name() ) ) {
                    
                    SPM_ContractUpTime upDownTime = new SPM_ContractUpTime( sch );
                    database.executebatch( upDownTime );
                } else if( processId.equalsIgnoreCase(SPM_Schema.Report.ContractPenetration.Name() ) ) {
                    
                    SPM_ContractPenetration contractPenetration = new SPM_ContractPenetration( sch );
                    database.executebatch( contractPenetration );
                } else if( processId.equalsIgnoreCase(SPM_Schema.Report.MeanTimeToComplete.Name() ) ) {
                    
                    SPM_MeanTimeToComplete meanTimeToCompleteEngine = new SPM_MeanTimeToComplete( sch );
                    database.executebatch( meanTimeToCompleteEngine );
                } else if( processId.equalsIgnoreCase(SPM_Schema.Report.AverageResponseTime.Name() ) ) {                    
                    SPM_AverageResponseTime averageResponseTimeEngine = new SPM_AverageResponseTime( sch );
                    database.executebatch( averageResponseTimeEngine );
                } else if( processId.equalsIgnoreCase(SPM_Schema.Report.RepeatVisit.Name() ) ) {                    
                    SPM_Repeat_Visit repeatVisitEngine = new SPM_Repeat_Visit( sch );
                    database.executebatch( repeatVisitEngine );
                } else if( processId.equalsIgnoreCase(SPM_Schema.Report.Utilization.Name() ) ) {                    
                    SPM_TechUtilization  utilizationEngine = new SPM_TechUtilization ( sch );
                    database.executebatch( utilizationEngine );
                } else if( processId.equalsIgnoreCase(SPM_Schema.Report.AccountSummary.Name() ) ) {
                    SPM_Account_Summary accountSummary = new SPM_Account_Summary(sch);
                    database.executebatch( accountSummary, 1 );
                }else if( processId.equalsIgnoreCase(SPM_Schema.Report.MeanTimeBetweenFailure.Name() ) ) {
                    SPM_MeanTimeBetweenFailure mtbf = new SPM_MeanTimeBetweenFailure(sch);
                    database.executebatch( mtbf);
                }
                
            } else {
                
                sch.SVMXC__Unprocessed__c = true;                
                //isUnprocessed = true;
            }
        }
        
        if( !lstSchsToUpdate.isEmpty() ) {
            update lstSchsToUpdate;    
        }
        
        /*    
        if( isUnprocessed ) {
            sendEmailForUnprocessedSchedule(lstSchsToUpdate);
        } */
    }
   
    // This function will send email notification about unprocesses schedules
    public void sendEmailForUnprocessedSchedule(list<SVMXC__ServiceMax_Config_Data__c> lstUnProcessedScheduled){
        map<String,Id> mapScheduleProIdScheduledBy = new map<String,Id>();
        map<String,String> mapScheduleProIdScheduleProName = new map<String,String>();
        map<String,String> mapScheduleProIdScheduleProTimeZone = new map<String,String>();
        list<Messaging.SingleEmailMessage> lstEmail = new list<Messaging.SingleEmailMessage>();
        
        String strSubject = system.Label.CONF039_TAG027;
        String strCommonBody = system.Label.COMM001_TAG093 +'\n\n';
        strCommonBody += system.Label.CONF039_TAG028+'\n\n';
        
        for(SVMXC__ServiceMax_Config_Data__c cofigData : lstUnProcessedScheduled){
            mapScheduleProIdScheduledBy.put(cofigData.SVMXC__Dispatch_Process__r.SVMXC__ProcessID__c,cofigData.SVMXC__Dispatch_Process__r.SVMXC__Assign_To_Dispatcher__c);
            mapScheduleProIdScheduleProName.put(cofigData.SVMXC__Dispatch_Process__r.SVMXC__ProcessID__c,cofigData.SVMXC__Dispatch_Process__r.SVMXC__Name__c);
            mapScheduleProIdScheduleProTimeZone.put(cofigData.SVMXC__Dispatch_Process__r.SVMXC__ProcessID__c,cofigData.SVMXC__Dispatch_Process__r.SVMXC__Dispatch_Timezone__c);
        }
        for(String str : mapScheduleProIdScheduledBy.keyset()){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            String strProcessName = system.Label.CONF039_TAG017+' '+mapScheduleProIdScheduleProName.get(str)+'\n';
            String strProcessId = system.Label.CONF039_TAG018+' '+str+'\n';
            String strBody = strCommonBody + strProcessName + strProcessId+'\n';
            
            strBody += system.Label.CONF039_TAG029+': ' + system.now().format('MM/dd/yyyy HH:mm:ss', mapScheduleProIdScheduleProTimeZone.get(str))+' '+TimeZone.getTimeZone(mapScheduleProIdScheduleProTimeZone.get(str)).getDisplayName()+' ('+mapScheduleProIdScheduleProTimeZone.get(str)+')';

            email.saveAsActivity = false;
            email.setSubject(strSubject);
            email.setTargetObjectId(mapScheduleProIdScheduledBy.get(str));
            email.setPlainTextBody(strBody);
            lstEmail.add(email);
        }
        if(lstEmail != null && lstEmail.size() > 0)
            Messaging.SendEmailResult [] sendEmail = Messaging.sendEmail(lstEmail); 
    }
}